# Server PCs


## HP thin client

The HP T740 thin client is [available on eBay](https://www.ebay.com/itm/145079601430)
for about $200. It is unusual in that it has single PCIe slot
that accepts standard low-profile cards on a standard low-profile bracket,
while being only 2L in size.

It also has an M.2 wifi slot.

## Lenovo tiny

Some Lenovo tiny PCs have a slot into which you can put a riser that accepts
low-profile PCIe cards, but without their bracket.

I recommend buying a second-hand M720q. These are widely available.
Try to get one without a wifi card.

You will also need to get a kit which has the riser, a cover plate with an opening
(sometimes sold as a baffle or a bezel) and some screws. The Lenovo
part number is 01AJ940 (this is just the riser, I believe). These are available from
[AliExpress](https://www.aliexpress.com/item/1005004237346189.html) or eBay (search for
01AJ940).

The cover plate is designed for a 4-port i350 card. This means that the opening
is bigger than necessary for a single RJ45 card. More importantly, the cover plate
has a clip that is designed to retain a low-profile card that occupies the full-height
of the low-profile bracket. The i210 card is shorter and so the clip does not work
to keep it in place. Improvisation is therefore necessary to keep the clip in place.

The rear of the PC has a small hole that can accept an SMA female bulkhead connector.
In models without wifi cards, the hole is covered by a disc with a little slit, which
can be pushed out with a screwdriver. We can then fit a pigtail with an SMA female bulkhead
into this hole.

This shows a build using an i210 and the ArduSimple M.2 card. There is U.FL to SMA female
bulkhead cable going from the rear of the computer to the antenna input on the M.2
card. The i210 is fitted with the breakout board from Timebeat. I've put
a piece of Kapton tape on top, since the breakout board can come into contact with the case
(electrical tape would probably have been better).
There is then a U.FL connector
going from this breakout board to the PPS connector on the M.2 card.
I've improvised a way to keep the i210 in place using a couple of pieces
cut off the corner of a stripboard.

![image](https://github.com/jclark/pc-ptp-ntp-guide/assets/499966/baf3fb0c-8c73-48d3-aa22-6b9aa61ddcf7)

## Pre-built PC