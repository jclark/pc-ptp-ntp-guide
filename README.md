# How to do precision network time synchronization on PC hardware

This is a guide to how to precisely synchronize the clocks of computers on a local area network using inexpensive PC hardware, by making use of hardware designed to support the IEEE 1588 standard for Precision Time Protocol (PTP).

This guide is designed to complement my [guide to using the hardware PTP support on the Raspberry Pi CM4]https://github.com/jclark/rpi-cm4-ptp-guide/).

Many modern, inexpensive NICs include hardware support for PTP. This means that the NIC has its own clock, sometimes called the PTP Hardware Clock (PHC), that can be used to timestamp incoming and outgoing network packets. This hardware support makes it possible to achieve accuracies of less than 100 nanoseconds. However, achieving this level of accuracy requires running a time server on your local area network.
The main goal of this guide is to explain in detail the hardware and software needed to do this, without assuming prior knowledge of time synchronization.

The server needs two specialized pieces of hardware:
- a NIC with a PPS input
- a GPS receiver with a pulse-per-second (PPS) output, connected to the NIC's PPS input

The key is that the NIC can timestamp the pulses received on its PPS input using its clock: this is crucial for ensuring that the level of accuracy of the transfer of time from the GPS to the server is similar to that
from the server to the client.
NICs with this capability are rare: the one most commonly used for this purpose is the Intel i210-T1. 

This guide assumes the use of Linux for the server's operating system, since Linux has by far the best support for PTP hardware.
The obvious approach is for the server to run PTP; in PTP terminology, the server will be performing the role of a PTP grandmaster. The dominant PTP implementation on Linux is [LinuxPTP](https://linuxptp.sourceforge.net/). An alternative approach is for the server to run an NTP server using [chrony](https://chrony-project.org/); although NTP cannot usually achieve the level of precision we are aiming for, chrony can take advantage of PTP hardware support to achieve a much higher level of precision.
PTP hardware support that chrony can make use of will also work for LinuxPTP.
But chrony is a bit easier to work with than LinuxPTP, so it's a good way to get started.

The particular Linux distribution doesn't matter too much: I've tried Debian, Ubuntu and Fedora. But Fedora tends to have the most well-maintained and up-to-date packages for linuxptp and chrony.

In selecting hardware, there's a new feature called Precision Time Measurement (PTM), which is very useful for this application. It allows for precise synchronization between the system clock and the PHC.

Hardware selection and assembly:
* [GPS receivers](gps.md) that work well for this application
* [NICs with PPS input](pps-nics.md), and how to connect to a GPS
* server PC
* more about [PTM](ptm.md) 

Server software configuration:
* [Verify](verify.md) that the NIC and GPS are properly working with the operating system.
* [chrony](chrony.md) - how to set up chrony
* linuxptp


## References
https://chrony-project.org/examples.html#_server_using_reference_clock_on_nic
https://linuxptp.sourceforge.net/i210-rework/i210-rework.html
https://github.com/AaronWebster/igb-pps-guide








