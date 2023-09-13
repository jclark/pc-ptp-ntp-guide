# Precise Time Measurement (PTM)

PTP hardware support allows precise synchronization of GPS with a NIC clock, and allows precise
synchronization over the network between the clock of one NIC and the clock of another NIC.
But almost all computer software is written to make use of the computer's system clock rather than a NIC clock.
This means that we need to synchronize the system clock with NIC clock. 
But PTP doesn't address the problem and in fact this can be turn out to be the weakest link in the chain.

PTM is a PCI Express (PCIe) feature that enables devices on PCIe bus to synchronize their clocks.
