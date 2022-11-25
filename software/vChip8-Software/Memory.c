#include "Memory.h"
#include <string.h>

uint8_t RAM[MEMORY_RAM_SIZE] = {0};
uint8_t STACK[MEMORY_STACK_SIZE] = {0};

void initRAM(alt_u16 ui16address, alt_u8 *pu8data, alt_u16 ui16Size)
{
	memcpy(&(RAM[ui16address]), pu8data, ui16Size);
}

uint8_t readRAM8(uint16_t address)
{
	return RAM[address];
}

void writeRAM8(uint16_t address, uint8_t value)
{
	RAM[address] = value;
}

uint16_t readRAM16(uint16_t address)
{
	uint16_t uiRetVal = 0;
	// data is stored in memory as big-endian
	uiRetVal = (RAM[address] << 8) | (RAM[address + 1]);
	return uiRetVal;
}

void writeRAM16(uint16_t address, uint16_t value)
{
	RAM[address] = (value & 0xFF00) >> 8;
	RAM[address + 1] = (value & 0x00FF);
}

uint16_t readSTACK16(uint16_t address)
{
	uint16_t uiRetVal = 0;
	// data is stored in memory as big-endian
	uiRetVal = (STACK[address] << 8) | (STACK[address + 1]);
	return uiRetVal;
}

void writeSTACK16(uint16_t address, uint16_t value)
{
	STACK[address] = (value & 0xFF00) >> 8;
	STACK[address + 1] = (value & 0x00FF);
}

