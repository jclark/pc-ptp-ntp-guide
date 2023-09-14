# Configuring chrony

[Chrony](https://chrony-project.org/) is an NTP implementation, but it has the ability to take advantage of hardware support designed for PTP in two ways:

- it can read PPS input connected a pin of a PTP hardware clock (e.g. the SYNC_OUT pin on a CM4)
- it can use hardware timestamping

This page is written assuming [Fedora](fedora.md) as the OS.

## PPS input

Chrony can work fine with just the PPS signal from the GPS: the pulse says exactly when a second starts; chrony can figure out which second it is from network sources.

To use the PPS as a source of time, add this line to `/etc/chrony.conf`:

```
refclock PHC /dev/ptp0:extpps:pin=0 width 0.1 poll 0 precision 1e-7 refid PPS
```

Here:

* Usually the PHC (PTP Hardware Clock) refclock expects the PTP Hardware Clock to have been synchronized with PTP; the `extpps` option enables a different mode of operation, in which it reads thes timestamps of pulses on a pin on the PTP hardware clock; it defaults to pin 0, which is what we need.
* `/dev/ptp0` is the device for the PTP hardware clock
* `pin=0` means to use pin 0
* `width 0.1` is the pulse width in seconds.
 * the `refid` option names this refclock `PPS`.

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

Connecting up the serial output from the GPS allows chrony to work even when there is no connection to any other NTP server.


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
sudo cp /lib/systemd/system/gpsd.service /etc/systemd/system/
```

Then edit /etc/systemd/system/gpsd.service as follows.
Delete the line

```
Requires=gpsd.socket
```

and then after the line that says:

```
After=chronyd.service
```

add the line:

```
Requires=chronyd.service
```

This ensures that when chronyd gets restarted, gpsd will also get restarted.

Now do:
```
sudo systemctl daemon-reload
sudo systemctl stop gpsd.socket
sudo systemctl disable gpsd.socket
sudo systemctl start gpsd.service
sudo systemctl enable gpsd.service
```

Now use

```
gpsmon
```

to check that gpsd is seeing the GPS. Use Ctrl-C to exit.

Now add this line to /etc/chrony.conf:

```
refclock SOCK /run/chrony.clk.ttyUSB0.sock poll 3 offset 0 noselect refid UART
```

There's a lot packed into these two lines. Consider the refclock SOCK line first.
 * When gpsd starts reading from /dev/ttyX, it checks for the existence of the socket /run/chrony.clk.ttyX.sock; if this socket exists, then it will send the messages with the current date-time derived from messages received from the GPS over this socket.
 * The refclock SOCK line causes chrony to create the socket in the place where gpsd expects. Chrony will then read date-time messages from that.
 * The `refid UART` option gives the name `UART` to this reference clock.
 * The `offset 0` means that chrony should assume that there are 0 seconds delay between the instant when the second started and the instant when it receives the date-time message for that second through the socket. This is certainly the wrong value. We will figure out the right value below.
 * The `noselect` option means that this refclock is not going to be used as a time source on its own: it's too inaccurate for that. (Instead it's going to be used to supplement the pulse-per-second signal.)

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

The `216ms` tells us the offset we need in the `refclock SOCK` line: 216ms is 0.216s, so we need 0.216 as the offset value.

Now we're ready to put the final tweaks to the two refclock lines. First in the `reflock SOCK` line, we edit the `offset 0` to be e.g. `offset 0.216`.
Then we can add a `lock UART` option to the `refclock PHC` line: this means that the pulse should be combined with the date-time from the UART refclock to provide a complete and accurate time sample.

The refclock lines now look like this:

```
refclock PHC /dev/ptp0:extpps:pin=0 poll 0 width 0.1 precision 1e-7 refid PPS lock UART
refclock SOCK /run/chrony.clk.ttyUSB0.sock poll 3 offset 0.216 noselect refid UART
```

Now we can restart chrony again:

```
sudo systemctl restart chronyd
```

The /run/chrony.clk.ttyX.sock feature was added in gpsd 3.25. Before that, it supported only a /run/chrony.ttyX.sock, which works only for PPS data. If you're using a version of gpsd that does not support /run/chrony.clk.ttyX.sock, then you can instead use the SHM 0 refclock.

```
refclock SHM 0 poll 3 offset 0.216 noselect refid UART
```

## Hardware timestamping

To make chrony use hardware timestamping, we just add the line

```
hwtimestamp enp1s0
```

But this won't work with clients whose NICs have the ability to timestamp only PTP packets.
To support such clients, we also we have to use [NTP-over-PTP](https://datatracker.ietf.org/doc/draft-ietf-ntp-over-ptp/) in order to use hardware timestamping. To enable this, we add the line

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

Chrony only supports NTP-over-PTP between server and client running the same versions of chrony.

