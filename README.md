# OctoChat - a tileable foot keyboard for people or pets

This project is a circuit board that allows one to construct a mechanical keyboard
as large or as small as you like.   From a single key, to potentially 64 keys.

The keyboard connects via I2C - it can connect direct to a raspberry pi, or to a small
microcontroller.   ESP32, ESP8266 and Nordic NRF52 are good choices.  

If you have a board that runs circuitpython such as the Adafruit feather or one of Accelerando's
Redsoil or Hailstone boards you can create a USB or Bluetooth keyboard with the included CircuitPython code.

Accelerando's Stacx project (for the Ardiuino framework) also supports these keys.

## How it works

The PCF8574 IO expander is used.   This chip has 8 pins, each key uses two pins.    A four key board can be made with
one octochat fitted with a PCF8574 and three more octochats *with no chip*.   Each active octochat can control three other passive octochats.   Connections can be chained, so you can add another active octochat into your board.   The PCF8574 supports 16 addresses, so you can have up to 16 active keys, plus up to 48 passive keys.

Each key has one keyswith and one LED.  Program the IO Expander's register with bit pattern 0xFF.   When a key is pressed, that bit will read zero.   To light a LED, program the corresponding bit to a zero.

The outputs of the PCF8574 are arranged thusly

 * D0 - the key on this module (pulled high, low when pressed)
 * D1 - the LED on this module (sink mode, program output low to light the LED)
 * D2 - the key on passive module 2
 * D3 - the LED on passive module 2
 * D4 - the key on passive module 3
 * D5 - the LED on passive module 3
 * D6 - the key on passive module 4
 * D7 - the LED on passive module 4

Each module has two connectors for each passive module, one at 90 degrees and one at 45 degrees.   You should use one or the other, not both.    All the ribbon connectors also relay the I2C SCL and SDA lines, so you can site a new active module anywhere you choose.

## What can I do with it

Make a soundboard for your cat, or dog.

Add foot controls to your PC.

Create assistive tech for the disabled.

Control machinery (I use one to control vacuum pickup and fume extraction at my soldering station).



