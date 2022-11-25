#ifndef __CPU_H__
#define __CPU_H__

#include "alt_types.h"

void initCPU(
		/*Keyboard* Keyboard,
		Display* Display,
		Audio* Audio,*/
		alt_u16 offsetProgram,
		alt_u16 offsetFont);
void runCPU(void);

#endif	/* __CPU_H__ */
