#include "Keyboard.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include <string.h>

static uint8_t Keypad[NUM_OF_KEYPAD] = {0};
static uint8_t KeyMap[NUM_OF_KEYPAD] = {0};

uint8_t getNumOfKeys()
{
	return NUM_OF_KEYPAD;
}

uint8_t getKey(uint8_t key)
{
	return Keypad[key];
}

void initKeypadMap(uint8_t keys[NUM_OF_KEYPAD])
{
	memcpy(KeyMap, keys, NUM_OF_KEYPAD);
}

void processPress()
{
	uint8_t control = 0;
	uint8_t CurrentKey = 0;
	uint8_t mask = 0x01;

	control = IORD_ALTERA_AVALON_PIO_DATA(PERIPHERY_CONTROL_BASE);

	for (uint8_t idxControl = 0; idxControl < 8; idxControl++)
	{
		CurrentKey = mask << idxControl;
		for (uint8_t idxKey = 0; idxKey < NUM_OF_KEYPAD; idxKey++)
		{
			if (CurrentKey == KeyMap[idxKey])
			{
				if (control & CurrentKey)
				{
					Keypad[idxKey] = KEY_PRESSED;
					//printf("key[%d]=%d\n", idxKey, CurrentKey);
				}
				else
				{
					Keypad[idxKey] = KEY_NOT_PRESSED;
				}
			}
		}
	}
}

void initPress()
{
	for (uint8_t idxKey = 0; idxKey < NUM_OF_KEYPAD; idxKey++)
	{
		Keypad[idxKey] = KEY_NOT_PRESSED;
	}
}
