# GPS receivers

My top recommendation is the BG7TBL TS-1: this provides a high-quality timing receiver, in a form that is convenient to
use with a PC, at an inexpensive price.

## BG7TBL TS-1

This became available in 2023. Internally, it uses the u-blox LEA-M8T module. This is a single band module.

It provides a PPS signal on an SMA connector at 3.3V (as required by the i210/i225).

I got mine on [AliExpress](https://www.aliexpress.com/item/1005005753445408.html) for $77. It's also available on eBay.

The power connector is standard 5.5x2.1mm DC barrel connnector, which accepts 5V-12V and requires only 0.3A, so can easily be powered via a dumb USB to DC 5V cable. However,
the board doesn't have a battery, so powering it from the PC over USB means that
a PC power cycle requires a cold start of the GPS.

It provides RS232 DB9 female connection to the UART port on the LEA-M8T. It can be connected
to a PC that does not have a serial port by using an USB 2.0 to RS232 DB9 male converter cable.

Many GPS receivers being sold from China are fakes. But I am confident the one I got is not. The idea behind this product is
to repurpose timing modules originally manufactured for Huawei cellular base stations. These timing modules
are [available on eBay](https://www.ebay.com/itm/333619130232) for about $50 or less, but they require some hard-to-find parts to wire up properly.

![image](https://github.com/jclark/pc-ptp-ntp-guide/assets/499966/9a823dfd-88b9-40d5-9f61-494286e0f4f7)
![image](https://github.com/jclark/pc-ptp-ntp-guide/assets/499966/566971aa-53ad-4f66-a5a1-9ce91d0d62c9)
![image](https://github.com/jclark/pc-ptp-ntp-guide/assets/499966/991155c1-231b-4677-9071-eee3be45c1bf)
![image](https://github.com/jclark/pc-ptp-ntp-guide/assets/499966/86afd267-66da-45be-a105-f538cc3e5b21)

## ArduSimple simpleRTK2B M.2 ZED-F9P

The [simpleRTK2B M.2](https://www.ardusimple.com/product/simplertk2b-m-2/) fits into a M.2 E-key slot, which is the kind of slot PCs have for wifi cards.

The module is a u-blox ZED-F9P. It's designed for precise positioning (RTK), but it also supports time mode.
This is a dual band (L1/L2) module. It's a step up in both price and performance from the LEA-M8T used in the TS-1.

The USB port on the ZED-F9P will be exposed as a USB device in Linux, typically `/dev/ttyACM0`.

Note that this needs a dual band antenna for best performance.
![image](https://github.com/jclark/pc-ptp-ntp-guide/assets/499966/e5f35ce8-30de-4bff-a653-6cb765f83cda)





