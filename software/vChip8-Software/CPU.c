#include "CPU.h"
#include "Memory.h"
#include "Display.h"
#include "Keyboard.h"
#include "Chip8Types.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

static uint8_t RegisterV[16];		// 16 general purpose registers
static uint16_t RegisterI;
static uint16_t RegisterPC;			// Program Counter register
static uint8_t RegisterSP;			// Stack Pointer register
static uint8_t RegisterDT;			// Delay Timer register
static uint8_t RegisterST;			// Sound Timer register
static uint16_t OffsetProgram;		// Start of program offset
static uint16_t OffsetFont;			// Fonts offset

static void SYS();
static void CLS();
static void RET();
static void JP(uint16_t address, uint8_t base);
static void CALL(uint16_t address);
static void SE(uint8_t val1, uint8_t val2);
static void SNE(uint8_t val1, uint8_t val2);
static void LD8(uint8_t *dst, uint8_t *src);
static void LD16(uint16_t* dst, uint16_t* src);
static void ADD(uint8_t* dst, uint8_t* src);
static void ADD_NoCarry8(uint8_t* dst, uint8_t* src);
static void ADD_NoCarry16(uint16_t* dst, uint8_t* src);
static void OR(uint8_t* dst, uint8_t* src);
static void AND(uint8_t* dst, uint8_t* src);
static void XOR(uint8_t* dst, uint8_t* src);
static void SUB(uint8_t* dst, uint8_t* src);
static void SHR(uint8_t* dst);
static void SUBN(uint8_t* dst, uint8_t* src);
static void SHL(uint8_t* dst);
static void RND(uint8_t* dst, uint8_t* src);
static void DRW(uint8_t col, uint8_t row, uint8_t size);
static void SKP(uint8_t val);
static void SKNP(uint8_t val);
static void updateTimers();

void initCPU(
		/*Keyboard* Keyboard,
		Display* Display,
		Audio* Audio,*/
		uint16_t offsetProgram,
		uint16_t offsetFont)
{
	OffsetProgram = offsetProgram;
	OffsetFont = offsetFont;

	// initialize all registers to 0
	memset(RegisterV, 0, 0xF);
	RegisterI = 0u;
	RegisterPC = OffsetProgram;
	RegisterSP = 0u;
	RegisterDT = 0u;
	RegisterST = 0u;

	// initialize random seed:
	srand((unsigned int)time(NULL));
}

void runCPU(void)
{
	// update delay and sound timers
	updateTimers();

	// fetch next instruction
	uint16_t uiCurrentInstruction = readRAM16(RegisterPC);

	// breakdown of instruction
	uint16_t nnn = uiCurrentInstruction & 0x0FFF;
	uint8_t n = uiCurrentInstruction & 0x000F;
	uint8_t nn = uiCurrentInstruction & 0x00FF;
	uint8_t x = (uiCurrentInstruction & 0x0F00) >> 8;
	uint8_t y = (uiCurrentInstruction & 0x00F0) >> 4;
	uint8_t kk = uiCurrentInstruction & 0x00FF;

	// decode instruction
	switch ((uiCurrentInstruction >> 12) & 0x000F)
	{
	case 0x0:
		switch (uiCurrentInstruction & 0x0FFF)
		{
		case 0x0E0:	// 00E0 - CLS
			// Clear the display.
			CLS();
			break;
		case 0xEE:	// 00EE - RET
			// Return from a subroutine.
			RET();
			break;
		default:	// SYS addr
			SYS();
			break;
		}
		break;
	case 0x1:		// 1nnn - JP addr
		// Jump to location nnn.
		JP(nnn, 0);
		break;
	case 0x2:		// 2nnn - CALL addr
		/// Call subroutine at nnn.
		CALL(nnn);
		break;
	case 0x3:		// 3xkk - SE Vx, byte
		// Skip next instruction if Vx = kk.
		SE(RegisterV[x], kk);
		break;
	case 0x4:		// 4xkk - SNE Vx, byte
		// Skip next instruction if Vx != kk.
		SNE(RegisterV[x], kk);
		break;
	case 0x5:		// 5xy0 - SE Vx, Vy
		// Skip next instruction if Vx = Vy.
		SE(RegisterV[x], RegisterV[y]);
		break;
	case 0x6:		// 6xkk - LD Vx, byte
		// Set Vx = kk.
		LD8(&(RegisterV[x]), &kk);
		break;
	case 0x7:		// 7xkk - ADD Vx, byte
		// Set Vx = Vx + kk.
		ADD_NoCarry8(&(RegisterV[x]), &kk);
		break;
	case 0x8:
		switch (n)
		{
		case 0x0:	// 8xy0 - LD Vx, Vy
			// Set Vx = Vy.
			LD8(&(RegisterV[x]), &(RegisterV[y]));
			break;
		case 0x1:	// 8xy1 - OR Vx, Vy
			// Set Vx = Vx OR Vy.
			OR(&(RegisterV[x]), &(RegisterV[y]));
			break;
		case 0x2:	// 8xy2 - AND Vx, Vy
			// Set Vx = Vx AND Vy.
			AND(&(RegisterV[x]), &(RegisterV[y]));
			break;
		case 0x3:	// 8xy3 - XOR Vx, Vy
			// Set Vx = Vx XOR Vy.
			XOR(&(RegisterV[x]), &(RegisterV[y]));
			break;
		case 0x4:	// 8xy4 - ADD Vx, Vy
			// Set Vx = Vx + Vy, set VF = carry.
			ADD(&(RegisterV[x]), &(RegisterV[y]));
			break;
		case 0x5:	// 8xy5 - SUB Vx, Vy
			// Set Vx = Vx - Vy, set VF = NOT borrow.
			SUB(&(RegisterV[x]), &(RegisterV[y]));
			break;
		case 0x6:	// 8xy6 - SHR Vx
			// Set Vx = Vy SHR 1.
			SHR(&(RegisterV[x]));
			break;
		case 0x7:	// 8xy7 - SUBN Vx, Vy
			// Set Vx = Vy - Vx, set VF = NOT borrow.
			SUBN(&(RegisterV[x]), &(RegisterV[y]));
			break;
		case 0xE:	// 8xyE - SHL Vx
			// Set Vx = Vx SHL 1.
			SHL(&(RegisterV[x]));
			break;
		}
		break;
	case 0x9:		// 9xy0 - SNE Vx, Vy
		// Skip next instruction if Vx != Vy.
		SNE(RegisterV[x], RegisterV[y]);
		break;
	case 0xA:		// Annn - LD I, addr
		// Set I = nnn.
		LD16(&RegisterI, (uint16_t *)(&nnn));
		break;
	case 0xB:		// Bnnn - JP V0, addr
		// Jump to location nnn + V0.
		JP(nnn, RegisterV[0]);
		break;
	case 0xC:		// Cxkk - RND Vx, byte
		// Set Vx = random byte AND kk.
		RND(&(RegisterV[x]), &kk);
		break;
	case 0xD:		// Dxyn - DRW Vx, Vy, nibble
		// Display n-byte sprite starting at memory location I at (Vx, Vy), set VF = collision.
		DRW(RegisterV[x], RegisterV[y], n);
		RegisterPC += 2;
		break;
	case 0xE:
		switch (nn)
		{
		case 0x9E:	// Ex9E - SKP Vx
			// Skip next instruction if key with the value of Vx is pressed.
			SKP(RegisterV[x]);
			break;
		case 0xA1:	// ExA1 - SKNP Vx
			// Skip next instruction if key with the value of Vx is not pressed.
			SKNP(RegisterV[x]);
			break;
		default:
			printf("Incorrect opcode: 0x%04X\n", uiCurrentInstruction);
			break;
		}
		break;
	case 0xF:
		switch (nn)
		{
		case 0x07:	// Fx07 - LD Vx, DT
			// Set Vx = delay timer value.
			LD8(&(RegisterV[x]), &RegisterDT);
			break;
		case 0x0A: // Fx0A - LD Vx, K
			for (uint8_t idx = 0; idx < getNumOfKeys(); idx++)
			{
				if (getKey(idx) == KEY_PRESSED)
				{
					RegisterV[x] = idx;
					RegisterPC += 2;
					break;
				}
			}
			break;
		case 0x15:	// Fx15 - LD DT, Vx
			// Set delay timer = Vx.
			LD8(&RegisterDT, &(RegisterV[x]));
			break;
		case 0x18:	// Fx18 - LD ST, Vx
			// Set sound timer = Vx.
			LD8(&RegisterST, &(RegisterV[x]));
/******			Audio->setBeep(RegisterST);*****/
			break;
		case 0x1E:	// Fx1E - ADD I, Vx
			// Set I = I + Vx.
			ADD_NoCarry16(&RegisterI, &(RegisterV[x]));
			break;
		case 0x29:	// Fx29 - LD F, Vx
			// Set I = location of sprite for digit Vx.
			{
				uint16_t offset = OffsetFont + (RegisterV[x] * 5);
				LD16(&RegisterI, &offset);
			}
			break;
		case 0x33:	// Fx33 - LD B, Vx
			// Store BCD representation of Vx in memory locations I, I+1, and I+2.
			writeRAM8(RegisterI, (RegisterV[x] / 100));
			writeRAM8(RegisterI + 1, ((RegisterV[x] / 10) % 10));
			writeRAM8(RegisterI + 2, (RegisterV[x] % 10));
			RegisterPC += 2;
			break;
		case 0x55:	// Fx55 - LD [I], Vx
			// Store registers V0 through Vx in memory starting at location I.
			for (uint8_t idx = 0; idx <= x; idx++)
			{
				// use direct memory access instead of LD command for not incrementing PC
				writeRAM8(RegisterI + idx, RegisterV[idx]);
			}
			//RegisterI = RegisterI + x + 1;
			RegisterPC += 2;
			break;
		case 0x65:	// Fx65 - LD Vx, [I]
			// Read registers V0 through Vx from memory starting at location I.
			for (uint8_t idx = 0; idx <= x; idx++)
			{
				// use direct memory access instead of LD command for not incrementing PC
				RegisterV[idx] = readRAM8(RegisterI + idx);
			}
			//RegisterI = RegisterI + x + 1;
			RegisterPC += 2;
			break;
		default:
			printf("Incorrect opcode: 0x%04X\n", uiCurrentInstruction);
			break;
		}
		break;
	}
}

static void SYS()
{
	printf("Unimplemented SYS\n");
	RegisterPC += 2;
}

// Clear the display.
static void CLS()
{
	clearDisplay();
	RegisterPC += 2;
}

// Return from a subroutine.
static void RET()
{
	RegisterPC = readSTACK16(RegisterSP);
	RegisterPC += 2;
	RegisterSP -= 2;
}

// Jump to location at base + address.
static void JP(uint16_t address, uint8_t base)
{
	RegisterPC = base + address;
}

// Call subroutine at address.
static void CALL(uint16_t address)
{
	RegisterSP += 2;
	writeSTACK16(RegisterSP, RegisterPC);
	RegisterPC = address;
}

// Skip next instruction if val1 = val2.
static void SE(uint8_t val1, uint8_t val2)
{
	if (val1 == val2)
	{
		RegisterPC += 4;
	}
	else
	{
		RegisterPC += 2;
	}
}

// Skip next instruction if val1 != val2.
static void SNE(uint8_t val1, uint8_t val2)
{
	if (val1 != val2)
	{
		RegisterPC += 4;
	}
	else
	{
		RegisterPC += 2;
	}
}

// Set 8-bits dst = src.
static void LD8(uint8_t *dst, uint8_t *src)
{
	*dst = *src;
	RegisterPC += 2;
}

// Set 16-bits dst = src.
static void LD16(uint16_t* dst, uint16_t* src)
{
	*dst = *src;
	RegisterPC += 2;
}

// Set dst = dst + src, VF = 1 if carry, VF = 0 if no carry
static void ADD(uint8_t* dst, uint8_t* src)
{
	*dst = (*dst) + (*src);
	RegisterV[0xF] = (((uint16_t)(*dst) + (uint16_t)(*src)) > 255) ? 0x01 : 0x00;
	RegisterPC += 2;
}

// Set 8-bits dst = dst + src.
static void ADD_NoCarry8(uint8_t* dst, uint8_t* src)
{
	*dst = (*dst) + (*src);
	RegisterPC += 2;
}

// Set 16-bits dst = dst + src.
static void ADD_NoCarry16(uint16_t* dst, uint8_t* src)
{
	*dst = (*dst) + (*src);
	RegisterPC += 2;
}

// Set dst = dst OR src.
static void OR(uint8_t* dst, uint8_t* src)
{
	*dst = (*dst) | (*src);
	RegisterPC += 2;
}

// Set dst = dst AND src.
static void AND(uint8_t* dst, uint8_t* src)
{
	*dst = (*dst) & (*src);
	RegisterPC += 2;
}

// Set dst = dst XOR src.
static void XOR(uint8_t* dst, uint8_t* src)
{
	*dst = (*dst) ^ (*src);
	RegisterPC += 2;
}

// Set dst = dst - src, VF = 1 if no borrow, VF = 0 if borrow.
static void SUB(uint8_t* dst, uint8_t* src)
{
	RegisterV[0xF] = ((*dst) >= (*src)) ? 0x01 : 0x00;
	*dst = (*dst) - (*src);
	RegisterPC += 2;
}

// Set dst shift right by 1, VF = LSB before shift.
static void SHR(uint8_t* dst)
{
	RegisterV[0xF] = (*dst) & 0x01;
	*dst = (*dst) >> 1;
	RegisterPC += 2;
}

// set dst = src - dst, VF = 1 if no borrow, VF = 0 if borrow.
static void SUBN(uint8_t* dst, uint8_t* src)
{
	*dst = (*src) - (*dst);
	RegisterV[0xF] = ((*src) >= (*dst)) ? 0x01 : 0x00;
	RegisterPC += 2;
}

// Set dst shift left by 1, VF = MSB before shift.
static void SHL(uint8_t* dst)
{
	RegisterV[0xF] = ((*dst) & 0x80) >> 7;
	*dst = (*dst) << 1;
	RegisterPC += 2;
}

// dst = random[0..255] AND src
static void RND(uint8_t* dst, uint8_t* src)
{
	*dst = (rand() % 256) & (*src);
	RegisterPC += 2;
}

// Draw sprite at position [col, row]
static void DRW(uint8_t col, uint8_t row, uint8_t size)
{
	RegisterV[0xF] = 0x00;
	for (uint8_t idxY = 0; idxY < size; idxY++)					// go over all bytes composing the sprite
	{
		uint8_t CurrentSpriteByte = readRAM8(RegisterI + idxY);	// read current byte of sprite
		for (uint8_t idxX = 0; idxX < 8; idxX++)				// go over all bits (pixels) in byte
		{
			if ((CurrentSpriteByte & (0x80 >> idxX)) != 0)		//	if current bit is on
			{
				if (getPixel(row + idxY, col + idxX) == 0xFF)	// if pixel is already on
				{
					RegisterV[0xF] = 0x01;						// set VF = 1 since pixel have XOR logic (pixel_on XOR current_on == 0 (unset))
				}
				putPixel(row + idxY, col + idxX, 0xFF);
			}
		}
	}
}

// Skip next instruction if key(val) is pressed, else proceed to next instruction.
static void SKP(uint8_t val)
{
	if (getKey(val) == KEY_PRESSED)
	{
		RegisterPC += 4;
	}
	else
	{
		RegisterPC += 2;
	}
}

// Skip next instruction if key(val) is not pressed, else proceed to next instruction.
static void SKNP(uint8_t val)
{
	if (getKey(val) == KEY_NOT_PRESSED)
	{
		RegisterPC += 4;
	}
	else
	{
		RegisterPC += 2;
	}
}

// Update delay timer and sound timer registers
static void updateTimers()
{
	if (RegisterDT > 0)
	{
		RegisterDT--;
	}
	if (RegisterST > 0)
	{
		RegisterST--;
	}
}
