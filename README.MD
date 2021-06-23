# InputTest_MiSTer

## Overview

A custom mini-system running an input test utility.  Currently shows all standard HPS sourced inputs (joystick, analog, paddle, spinner) simultaneously.

---

## Hardware

A simple bespoke (i.e. I made it up with no real plan) 8-bit system with a 40x30 character display, each character can be set to one of 256 colours

### Components
 - Z80 CPU (tv80 by Guy Hutchison, based on VHDL T80 core by Daniel Wallner)
 - jtframe_vtimer for VGA timing (from JTFRAME by Jotego)
 - 16Kb program ROM (port 1 cpu, port 2 download)
 - 16Kb work RAM (port 1 cpu)
 - 2Kb character ROM (port 1 cpu, port 2 download)
 - 2Kb character RAM (port 1 cpu, port 2 graphics)
 - 2Kb colour RAM (port 1 cpu, port 2 graphics)
 - 3 Memory-mapped IO regions (all read-only).  _Yes I know about MREQ but SFRs are annoying in sdcc so :)_
   - Hardware state (H/V Sync, H/V Blank etc) (8 bytes)
   - joystick_5->0 from HPS (192 bytes)
   - joystick_analog_5->0 from HPS (95 bytes)

### Memory Map
Start|End|Length|Name
---|---|---|---
0x0000|0x3FFF|0x4000|Program ROM
0x4000|0x47FF|0x0800|Char ROM
0x6000|0x6000|0x0001|System inputs (video timings etc)
0x7000|0x70BF|0x00C0|Joystick inputs
0x7100|0x71BF|0x00C0|Analog inputs
0x8000|0x87FF|0x0800|Char RAM
0x8800|0x8FFF|0x0800|Colour RAM
0xC000|0xFFFF|0x4000|Work RAM

---

## Software



