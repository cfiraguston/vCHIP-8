#ifndef __KEYBOARD_H__
#define __KEYBOARD_H__

#include "Chip8Types.h"

#define NUM_OF_KEYPAD	16		// 16 key keypad

#define KEY_NOT_PRESSED	0x00
#define KEY_PRESSED		0x01

#define KEY_NONE		0x00
#define KEY_DOWN		0x01
#define KEY_UP			0x02
#define KEY_RIGHT		0x04
#define KEY_LEFT		0x08
#define KEY_START		0x10
#define KEY_SELECT		0x20
#define KEY_B			0x40
#define KEY_A			0x80

uint8_t getNumOfKeys();
uint8_t getKey(uint8_t key);
void initKeypadMap(uint8_t keys[NUM_OF_KEYPAD]);
void processPress();
void initPress();

#endif	/* __KEYBOARD_H__ */
