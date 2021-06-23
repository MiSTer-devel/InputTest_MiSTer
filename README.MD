# InputTest_MiSTer

## Overview

A custom mini-system running an input test utility.  Shows all possible MiSTer inputs simultaneously!

## System architecture 

A simple 8-bit computer with a 40x30 character display, each character can be set to one of 256 colours

Components:
 - Z80 CPU (tv80 by Guy Hutchison, based on VHDL T80 core by Daniel Wallner)
 - jtframe_vtimer for VGA timing (from JTFRAME by Jotego)
 - 16Kb program ROM
 - 16Kb work RAM
 - 2Kb character ROM (uses standard MiSTer bitmap font)
 - 2Kb character RAM
 - 2Kb colour RAM

## Memory Map

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
