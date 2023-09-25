# Configuring chrony

[Chrony](https://chrony-project.org/) is an NTP implementation, but it has the ability to take advantage of hardware support designed for PTP in two ways:

- it can read PPS input connected a pin of a PTP hardware clock (e.g. the SYNC_OUT pin on a CM4)
- it can use hardware timestamping

This page is written assuming [Fedora](fedora.md) as the OS.

## PPS input

Chrony can works very well using just the PPS signal from the GPS: the pulse says exactly when a second starts; chrony can figure out which second it is from network sources. Make sure you have chrony set up in way similar to the default getting time from the network, typically using `pool` directive. 

To use the PPS as a source of time, add this line to `/etc/chrony.conf`:

```
refclock PHC /dev/ptp0:extpps:pin=0 poll 0 width 0.1 delay 6e-8 precision 2e-8 refid PPS
```

Here:

* `/dev/ptp0` is the device for the PHC (PTP hardware clock); see [Verify PPS](service-linux.md#verify-pps) section for how to determine this
* the `extpps` option enables a mode of operation in which chrony itself reads the timestamps of pulses on a pin on the PHC; without this option, chrony expects the PHC to have been synchronized to the correct time by another process and just reads the time from the PHC
* `pin=0` says to use pin 0; this is the physical pin that the PPS signal is connected to
* `poll 0` says to use samples immediately rather than store them (since the jitter should be very small)
* `width 0.1` is the pulse width in seconds; see [Pulse Width](service-linux.md#pulse-width) section for how to determine this
* `delay 6e-8` specifies a delay of 60ns; this is suitable for a GPS with an accuracy of 30ns
* `precision 2e-8` specifies a precision of 20ns; this is the approximate expected stability of readings from the PHC
* `refid PPS`  names this refclock `PPS`

To use chrony as a server in your network, you will also need something like:

```
allow 192.168.1.0/24
```

On Fedora, you will also need to add firewall rules:

```
sudo firewall-cmd --add-service ntp
sudo firewall-cmd --add-service ntp --permanent
```

Then restart chrony:

```
sudo systemctl restart chronyd
```

Check that it started OK:

```
sudo systemctl status chronyd
```

Now run

```
chronyc sources
```

It should should a line starting with `#* PPS`. This means it has successfully synced to the PHC refclock.

## Using serial connection from GPS

Connecting up the serial output from the GPS allows chrony to work even when there is no connection to any other NTP server. Unless you have this requirement, I do not recommend doing this: a serial connection to GPS
output is generally less precise and more troublesome than using the internet with NTP.

Install gpsd:

```
sudo dnf install gpsd
```

Edit OPTIONS and USBAUTO lines in `/etc/sysyconfig/gpsd`:

```
OPTIONS="-n /dev/ttyUSB0"
USBAUTO=""
```

Now we are going to tweak the systemd unit file:

```
sudo systemctl edit gpsd.service
```

Then type

```
[Unit]
PartOf=chronyd.service
```

and write out the file and exit the editor.
This installs an override in `/etc/systemd/system/gpsd.service.d/override.conf`,
which ensures that when chronyd gets restarted, gpsd will also get restarted.

Now enable and start the service:

```
sudo systemctl enable --now gpsd.service
```

Now run

```
gpsmon
```

to check that gpsd is seeing the GPS. Use Ctrl-C to exit.

Now add this line to /etc/chrony.conf:

```
refclock SOCK /run/chrony.clk.ttyUSB0.sock offset 0 delay 0.1 poll 0 noselect refid UART
```

The meaning of this line is as follows:
 * the `SOCK` kind of refclock reads date-time samples from a socket 
 * `/run/chrony.clk.ttyUSB0.sock` is the filename of the socket that chrony will create in order to
 receive information from gpsd; when gpsd starts reading from /dev/ttyX, it checks for the existence of the socket /run/chrony.clk.ttyX.sock; if this socket exists, then it will send the messages with the current date-time derived from messages received from the GPS over this socket
 * `offset 0` means that chrony should assume that there are 0 seconds delay between the instant when the second started and the instant when it receives the date-time message for that second through the socket; this is certainly the wrong value; we will figure out the right value below
  * `delay 0.1` means that the difference the minimum offset and maximum offset is 0.1s
  * `poll 0` means samples are used immediately rather than being stored and filtered (we don't need to store since we have `noselect`)
 * `noselect` option means that this refclock is not going to be used as a time source on its own: it's too inaccurate for that. (Instead it's going to be used to supplement the pulse-per-second signal.)
* `refid UART` named this refclock `UART` 

Now

```
sudo systemctl restart chronyd
```

Let this run for a minute or so, and then do

```
chronyc sources
```

You should see lines similar to this:

```
#* PPS                           0   0   377     1     -6ns[  -19ns] +/-  867ns
#? UART                          0   3   377     9   +216ms[ +216ms] +/- 1434us
```

as well as multiple lines for NTP servers.
The `216ms` tells us the offset we need in the `refclock SOCK` line: 216ms is 0.216s, so we need 0.216 as the offset value.


Now we're ready to put the final tweaks to the two refclock lines. First in the `reflock SOCK` line, we edit the `offset 0` to be e.g. `offset 0.216`.
Then we can add a `lock UART` option to the `refclock PHC` line: this means that the pulse should be combined with the date-time from the UART refclock to provide a complete and accurate time sample.

The refclock lines now look like this:

```
refclock PHC /dev/ptp0:extpps:pin=0 poll 0 width 0.1 delay 6e-8 precision 2e-8 refid PPS lock UART
refclock SOCK /run/chrony.clk.ttyUSB0.sock delay 0.1 offset 0.216 poll 0 noselect refid UART
```

TODO: is it better to omit the `lock UART` from the PHC line and omit the `noselect` from the UART line?

Now we can restart chrony again:

```
sudo systemctl restart chronyd
```

The /run/chrony.clk.ttyX.sock feature was added in gpsd 3.25. Before that, it supported only a /run/chrony.ttyX.sock, which works only for PPS data. If you're using a version of gpsd that does not support /run/chrony.clk.ttyX.sock, then you should instead use the SHM 0 refclock.

```
refclock SHM 0 poll 0 delay 0.1 offset 0.216 noselect refid UART
```

## Hardware timestamping

To make chrony use hardware timestamping, we just add the line

```
hwtimestamp enp1s0
```

But this won't work with clients whose NICs have the ability to timestamp only PTP packets.
To support such clients, we also have to use [NTP-over-PTP](https://datatracker.ietf.org/doc/draft-ietf-ntp-over-ptp/) in order to use hardware timestamping. To enable this, we add the line

```
ptpport 319
```

We will also need to add firewall rules to allow inbound traffic on the PTP port:

```
sudo firewall-cmd --add-service ptp
sudo firewall-cmd --add-service ptp --permanent
```

On the client side, you will need something like this:

```
server 192.168.1.2 minpoll 0 maxpoll 0 xleave port 319
hwtimestamp enp1s0 rxfilter ptp
ptpport 319
```

You can also add `extfield F323` to the `server` line to enable chrony's support for
[frequency transfer in NTP](https://mlichvar.fedorapeople.org/ntp-freq-transfer/).

Chrony only supports NTP-over-PTP between server and client running the same versions of chrony.

