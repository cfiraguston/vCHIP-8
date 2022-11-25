#ifndef __CHIP8_H__
#define __CHIP8_H__

#define ADDRESS_START_OF_FONT		0x0		// Fonts [0-9A-F] starts at offset 0
#define ADDRESS_START_OF_PROGRAM	0x200	// 512 bytes offset start of program

void initChip8(void);
void runChip8(void);

#endif	/* __CHIP8_H__ */
