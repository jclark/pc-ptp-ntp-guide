# Time server Linux preqrequisites

It's a good idea to make sure that everything is working at the kernel level before trying to set up NTP or PTP.
Part of this is determining the device names that the Linux kernel is using for our hardware.

## Verify PPS

In this section, we will check that the PPS signal into the NIC is working properly.

If the NIC is `enp1s0`, then first do:

```
ethtool -T enp1s0 | grep PTP
```

This will give us the number of the PTP Hardware Clock, which will often be 0.

Make sure the interface is in an UP state.

```
ip link show enp1s0
```

If it's not up, then bring it up with

```
sudo ip link set enp1s0 up
```

Then we can do 

```
echo 1 0 | sudo tee /sys/class/ptp/ptp0/pins/SDP0
```

Replace the `0` in `ptp0` with whatever `ethtool` said was the number.
`SDP0` here is the name of the pin to which the PPS is connected. In the `echo 1 0`, 1 means to use the pin for input and 0 means the pin should use input channel 0.


Now do:
```
echo 0 1 | sudo tee /sys/class/ptp/ptp0/extts_enable
```

This means to enable timestamping of pulses on channel 0. In the `echo 0 1`, 0 means channel 0 and 1 means to enable timestamping.


Now see if we're getting timestamps:

```
sudo cat /sys/class/ptp/ptp0/fifo
```

The `cat` command should output a line, which represents a timestamp of an input pulse and consists of 3 numbers: channel number, which is zero in this case, seconds count, nanoseconds count. Repeating the last command will give lines for successive input timestamps.

If `cat` outputs nothing, then it's not working.

### Pulse width

The i210 and i225 NICs have the quirk that they timestamp both the rising and falling edges of the every pulse. This means that a PPS signal will result
in two timestamps per second. Most GPS receivers default to a pulse width of 0.1s, which means that you should see consecutive timestamps separated alternately
by 0.1s and 0.9s (i.e. 100,000,000 and 900,000,000 nanoseconds).
By looking at the output of `cat` you can determine what the pulse width is.
Both chrony or ts2phc need to be configured with the pulse width for NICs that timestamp both edges.

## Verify GPS

First determine the serial device name:

* a USB-RS232 or USB-TTL converter will usually show up as`/dev/ttyUSB0`, but occasionally may show up as `/dev/ttyACM0`
* an RS232 connection using a DB9 port on the PC will usually show up as `/dev/ttyS0`
* a GPS in M.2 slot will usually be `/dev/ttyACM0`

Obviously you may need to change 0 in the device name to a larger number, if you have multiple such devices.

It's convenient if you are in the `dialout` group so you can access the serial devices

```
sudo usermod -G dialout -a jjc
```

Here `jjc` is your username. You'll need to logout and then login again for this to take effect.

Then do:

```
(stty 9600 -echo -icrnl; cat) </dev/ttyUSB0
```

Here 9600 is the speed. The most common default speed is 9600, but some receivers default to 38400.

You should see  lines starting with `$`.
In particular look for a line starting with `$GPRMC` or `$GNRMC`. The number following that should be the current UTC time;
for example, `025713.00` means `02:57:13.00` UTC.
After another 8 commas, there will be a field that should have the current UTC date;
for example, `140923` means 14th Septemember 2023.

