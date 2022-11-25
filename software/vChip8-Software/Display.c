#include "Display.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include <string.h>

static uint8_t DisplayData[DISPLAY_HEIGHT][DISPLAY_WIDTH] = { 0 };

void putPixel(uint8_t row, uint8_t col, uint8_t val)
{
	DisplayData[row][col] ^= val;
	uint16_t data = (VIDEO_BUFFER_COMMAND_DRAW << 12) |
					((DisplayData[row][col] & 0x01) << 11) |
					(col << 5) |
					row;

	IOWR_ALTERA_AVALON_PIO_DATA(VIDEO_BUFFER_BASE, data);
}

uint8_t getPixel(uint8_t row, uint8_t col)
{
	return DisplayData[row % DISPLAY_HEIGHT][(col % DISPLAY_WIDTH)];
}

void clearDisplay()
{
	uint16_t data = (VIDEO_BUFFER_COMMAND_CLEAR << 12);
	IOWR_ALTERA_AVALON_PIO_DATA(VIDEO_BUFFER_BASE, data);
	memset(DisplayData, 0, DISPLAY_HEIGHT * DISPLAY_WIDTH);
}
