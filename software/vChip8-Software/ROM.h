#ifndef __ROM_H__
#define __ROM_H__

#include "Chip8Types.h"
#include "Keyboard.h"

typedef struct
{
	uint16_t size;
	uint8_t *data;
	uint8_t *keypad;
} ROMInfo;

uint16_t getROMSize(uint16_t id);
uint8_t *getROMData(uint16_t id);
uint8_t *getROMKeypad(uint16_t id);

#endif	/* __ROM_H__ */
