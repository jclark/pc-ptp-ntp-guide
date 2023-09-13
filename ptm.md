# Precise Time Measurement (PTM)

PTP hardware support allows precise synchronization of a GPS with a NIC clock, and allows precise
synchronization over the network between the clock of one NIC and the clock of another NIC.
But almost all computer software is written to make use of the computer's system clock rather than a NIC clock.
This means that the system clock needs to synchronized with the NIC clock,
but PTP deals only with NIC clocks and does not help with this.

PTM is a PCI Express (PCIe) feature that enables devices on the PCIe bus to synchronize their clocks.
In particular, it provides hardware support for precise synchronization of the
NIC clock and the system clock.
At a high-level, it's like PTP, but for the PCIe bus rather than the network.
PTM requires support from both the network card and the computer (specifically the PCIe bus on the motherboard).

The Linux kernel enables applications to take advantage
of PTM using a system call that performs *cross timestamping*, which
means that a single system call fetches both the system time and the
time of a NIC clock simultaneously.
(The system call is the PTP_SYS_OFFSET_PRECISE ioctl.)
You can tell whether a particular NIC supports cross timestamping
by using the `phc_ctl` command from the `linuxptp` package with just the interface name as the argument. The last line of the output will say
`has cross timestamping support` if cross timestamping support is workin for the NIC.
The e1000e driver supports cross timestamping for some on-motherboard NICs,
such as the Intel I219-V, in a device-specific way that does not depend on PTM.
Apart from that, support for cross timestamping is currently based on PTM.

You can also check for PTM support by seaching for `Precision Time Measurement` in the output of `sudo lspci -vv`.
For PTM to work, it needs to be supported by the NIC device and the root complex (host bridge) and any PCI bridges
between them. You can use `lspci -t` to identify the relevant bridges. The driver for the NIC also needs to
have cross timestamping support.
