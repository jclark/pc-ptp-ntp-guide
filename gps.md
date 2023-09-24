# GPS receivers

With a PC, it's generally more convenient to use GPS receiver that has its own case, rather than
one that is designed to be put inside a case with a computer. This allows you to see the blinking
PPS LED.

My top recommendation is the BG7TBL TS-1: this provides a high-quality timing receiver, in a separate case, at an inexpensive price.

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

![image](https://github.com/jclark/pc-ptp-ntp-guide/assets/499966/988ce3cb-a99d-4d3a-8375-b1d3c18d26db)
![image](https://github.com/jclark/pc-ptp-ntp-guide/assets/499966/936d8750-d2ce-48f6-a77c-d22ac8f9d105)
![image](https://github.com/jclark/pc-ptp-ntp-guide/assets/499966/ff458374-a414-4c3a-ab8f-6c5a054f6114)

## ArduSimple simpleRTK2B M.2 ZED-F9P

The [simpleRTK2B M.2](https://www.ardusimple.com/product/simplertk2b-m-2/) fits into a M.2 E-key slot, which is the kind of slot PCs have for Wifi cards.

The module is a u-blox ZED-F9P. It's designed for precise positioning (RTK), but it also supports time mode.
This is a dual band (L1/L2) module. It's a step up in both price and performance from the LEA-M8T used in the TS-1.

The USB port on the ZED-F9P will be exposed as a USB device in Linux, typically `/dev/ttyACM0`.

If you are using the ZED-F9P purely for timing purposes, you might want to downgrade to firmware
HPG 1.12, since that version is the last version that provides the quantization error in UBX-TIM-TP messages
(at least versions 1.13 and 1.32 don't provide this).

Note that this needs a dual band antenna for best performance.

![image](https://github.com/jclark/pc-ptp-ntp-guide/assets/499966/9029f825-af84-4ebe-9e39-e6bc7f919eda)

## ZED-F9T USB Dongle

The GNSS OEM Store (in Latvia) sell a [USB dongle with a ZED-F9T](https://gnss.store/zed-f9t-timing-gnss-modules/108-16-elt0095.html) inside. It has two SMA connectors: one for the antenna
and one for PPS output. The case is semi-transparent and has a PPS LED. There are two versions:
one is L1-L2 dual band, and the other is L1-L5 dual band.

It's quite bulky and is likely to block adjacent USB ports. I recommend using it with a short USB A 2.0 male to female extension cable.

This option is very convenient and the ZED-F9T is the best available timing GPS receiver (as of 2023),
so it's a good option, but it is expensive (€220).

The antenna connecttor is the lower one in this photo.

![image](https://github.com/jclark/pc-ptp-ntp-guide/assets/499966/f9debe6c-405c-4b8d-8106-fc305634375e)

## In-case module with USB-to-TTL converter

This is the cheapest option. It combines 

- a GPS module, with the following properties
   - very cheap
   - very small
   - not a fake
   - no case
   - TTL-level pins
   - 0.1" (2.54mm) pins compatible with Dupont connectors
   - PPS pin
   - SMA female antenna connector
   - default speed of 9600 baud (ts2phc in LinuxPTP 3.x only supports 9600 baud)
- a USB to TTL converter

Suitable boards are available very cheaply, so this is the cheapest option.

These need to be wired up as follows:

| Color | GPS pin | USB to TTL pin | i210 pin  |
| --- | --- | --- | --- |
| black | GND | GND | - |
| red | VCC | VCC | - |
| green | TXD | RXD | - | 
| white | RXD | TXD | - |
| yellow | PPS | - | SDP0 | 
| grey | - | GND | GND |

![image](https://github.com/jclark/pc-ptp-ntp-guide/assets/499966/57ca2181-8ed0-42aa-9729-a9ba714faef8)

In the photo, I'm using

* [Waveshare USB to TTL converter with CH343G](https://www.waveshare.com/product/usb-to-ttl-b.htm) (about $10 w/ shipping from AliExpress); there's also a [version using the FT232RL](https://www.waveshare.com/usb-to-ttl.htm)
* [WAVGAT ATGM332D 5N1 GPS module](https://www.aliexpress.com/item/1005004402839841.html) (about $10 w/ shipping); you can get a GPS antenna at the same time for another $4

Note that two GND connections are needed to the USB-to-TTL converter, and the Waveshare converter has two GND pins, which makes it the convenient choice here.

The Waveshare converter comes with a cable with Dupont connectors, but it is likely to be too short. I'm using some separate Dupont female-female jumpers to wire things up.

This shows the rear when it's fully assembled. The GPS antenna is attached directly to the SMA connector on the module.
I've used a [M3 female magnetic screw](https://www.aliexpress.com/item/1005005091559659.html) to attach the module to the backplate.
This setup is rather vulnerable to the antenna cable being yanked: I recommend clamping the antenna cable to the table.

![image](https://github.com/jclark/pc-ptp-ntp-guide/assets/499966/c0b39851-f717-4587-b162-61d32517f4ba)


