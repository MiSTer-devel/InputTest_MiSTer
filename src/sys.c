#pragma once

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

// Memory maps
unsigned char __at(0x6000) input0;
unsigned char __at(0x7000) joystick[24];
unsigned char __at(0x7100) analog[12];
unsigned char __at(0x7200) paddle[6];
unsigned char __at(0x7300) spinner[12];
unsigned char __at(0x8000) chram[2048];
unsigned char __at(0x8800) colram[2048];

// Character map
const unsigned char chram_cols = 64;
const unsigned char chram_rows = 32;
unsigned int chram_size;