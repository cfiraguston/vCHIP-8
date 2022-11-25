#ifndef __MEMORY_H__
#define __MEMORY_H__

#include "Chip8Types.h"

#define MEMORY_RAM_SIZE				0x1000	// total of 4096 bytes
#define MEMORY_STACK_SIZE			0x20	// total 32 bytes = 16 16-bits addresses values

void initRAM(uint16_t ui16address, uint8_t *pu8data, uint16_t ui16Size);
uint8_t readRAM8(uint16_t address);
void writeRAM8(uint16_t address, uint8_t value);
uint16_t readRAM16(uint16_t address);
void writeRAM16(uint16_t address, uint16_t value);
uint16_t readSTACK16(uint16_t address);
void writeSTACK16(uint16_t address, uint16_t value);

#endif	/* __MEMORY_H__ */
