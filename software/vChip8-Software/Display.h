#ifndef __DISPLAY_H__
#define __DISPLAY_H__

#include "Chip8Types.h"

#define VIDEO_BUFFER_COMMAND_DRAW	(0x8)
#define VIDEO_BUFFER_COMMAND_CLEAR	(0xF)

#define DISPLAY_WIDTH		(64U)
#define DISPLAY_HEIGHT		(32U)

void putPixel(uint8_t row, uint8_t col, uint8_t val);
uint8_t getPixel(uint8_t row, uint8_t col);
void clearDisplay();

#endif	/* __DISPLAY_H__ */
