# NICs with PPS input

## i210

The most commonly used network card with a PPS input is the [Intel I210-T1](https://www.intel.com/content/www/us/en/products/sku/68668/intel-ethernet-server-adapter-i210t1/specifications.html). Although it's a 10-year old product, it remains an excellent choice. Its Linux driver (igb) has solid, mature PTP support.
There's an openly available data sheet that provides complete programming information
(the data sheet for the i225 is not openly available).

As well as the original Intel cards, there are OEM versions that work fine and
are cheaper, but you need to choose ones that have the same layout as the Intel
original and include the 6-pin SDP header. The only visual difference betweens
between the OEM version and the Intel original are
- the OEM version does not have the Intel logo, and
- with the OEM version, the board attaches to the bracket using two screws, whereas the Intel
original uses a screw at the bottom and a hook at the top.

The OEM cards are [available from AliExpress](https://www.aliexpress.com/item/1005002592570089.html) for $18 plus shipping.

If you want to be sure to get the original Intel card, you can buy from 
[Mouser](https://www.mouser.com/c/?q=i210-T1).

## Connecting the PPS signal

The i210-T1 card has a 3x2 male pin header, which expose the Software Defined
Pins (SDP) of the i210 controller. 
The pin header has a pitch of 2.54mm (0.1") and is compatible with Dupont female connectors.
Orienting the card with the RJ45 connector on the left, as shown in the photo below,
the top right pin is SDP0, the middle right pin is SDP1, and the middle left pin is GND.

TODO: Get clear about the other pins. Top left is probably GND.
Bottom right might be SDP2. Bottom left is probably not GND.

The method described here directly connects the pins on the i210 to the PPS signal,
without providing any electrical isolation. The pins expect a 3.3V TTL-level signal
not a 5V signal. You need to ensure that the PPS signal is 3.3V.
Directly connecting a 3.3V PPS signal works for me, but I'm not an electrical engineer,
and I do not have a good understanding of the risks (if any) involved here.
So proceed at your own risk.
Here is a [description](https://linuxptp.sourceforge.net/i210-rework/i210-rework.html)
of connecting via a RS232-TTL converter. (My understanding
is that using a RS232-TTL converter like this allows you to safely connect
a 5V PPS signal.)

TODO: Need to understand and make recommendations regarding grounding.
There are a number of things that we could do that might help.
The connection between the GPS and the PC could be made via a PCI bracket
(as described below),
which would establish a ground connection to the case.
The GPS could be powered via a USB port on the PC.
The PC could be one that is powered via a separate AC/DC converter, which
would mean it has a floating ground.

PPS signals on external GPS receivers are usually coaxial connectors, typically SMA.
Note that the connectors conventionally used for wifi antennas are RP-SMA, which
is not compatible with SMA: with RP-SMA connectors, the connector with the screw thread on the outside has a pin; with SMA, it's a hole.

There are a couple of ways to connect to an external receiver with an SMA PPS output,
such as the BG7TBL TS-1. 
The simplest way is to use a direct cable connection. You can buy a suitable
cable on eBay. They are called an [SMA male to Dupont female RG316 test cable](https://www.ebay.com/itm/275501972350).

A neater solution is to use a PCI bracket with a hole for an SMA connector:
these are designed for use with antennas of wifi cards.
You can buy them on [AliExpress](https://www.aliexpress.com/item/1005005341638856.htm);
they are available in full height, or half height, and with two or three holes.
This requires a spare slot in the case close to the slot used by the i210.
Then use a short cable (a pigtail) from the hole in the bracket to i210:
this is called an [SMA female bulhead to Dupont female RG316 test cable](https://www.ebay.com/itm/275501976151). Then you can connect the GPS receiver using a normal SMA male to SMA male
cable.

The test cables I have bought are wired so that black is the shield and red is the inner conductor. This means the black wire needs to be plugged into a GND pin on the SDP headers,
and the red wire needs to be plugged into SDP0 or SDP1.

This photo shows the OEM version of the i210-T1 with red attached to SDP0 and black attached
to GND.

![image](https://github.com/jclark/pc-ptp-ntp-guide/assets/499966/1c7e6b94-62c1-41f1-8697-64ddf9322a3c)


## i225

The i225-T1 card provides access to software-defined pins similar to the i210,
but the adapter just provides though-hole solder pads rather than physical pins;
so in order to make use of these a header needs to be soldered on.
Timebeat sells a [i225-T1](https://store.timebeat.app/products/intel-i225-t1-with-sdp-headers-and-a-u-fl-breakout-board) with the header already soldered on and a breakout board providing U.FL connectors.

The big advantage of the i225 is that it supports [PTM](ptm.md)
when used with a suitable motherboard.

## i226

The i226-T1 is in the process of being launched.

The photo in the [product brief](https://cdrdv2.intel.com/v1/dl/getContent/765669) looks exactly the same as the i225-T1.
So I would expect that a header can be soldered on in the same way.

## High-end NICs

These are quite a few expensive options (more than $1000). They all have a SMA connector on the bracket, and so they are easy to connect to a GPS receiver using an SMA male-male coaxial cable.

* Intel E810-XXVDA4T
* [OCP-TAP Timecard](https://store.timebeat.app/collections/ocp-tap)
* NVidia [ConnectX-6 DX](https://docs.nvidia.com/networking/display/ConnectX6DxEN/Introduction) models with SMA PPS input eg MCX623106PN-CDAT or MCX623106TN-CDAT
* [Cisco Nexus K35-S](https://www.cisco.com/c/en/us/products/collateral/interfaces-modules/nexus-smartnic/datasheet-c78-743825.html)
