/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* XILINX CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xiicps.h"
#include "xparameters.h"

#define SSM2603_IIC_ADDRESS		0x1A

static XIicPs iic;

uint8_t I2C_Read1Byte(uint8_t address)
{
	uint8_t SendBuffer[1];
	uint8_t RecvBuffer[1] = {0x00};

	SendBuffer[0] = address;
	XIicPs_MasterSendPolled(&iic, SendBuffer, 1, SSM2603_IIC_ADDRESS);
	while (XIicPs_BusIsBusy(&iic)) {}
	XIicPs_MasterRecvPolled(&iic, RecvBuffer, 1, SSM2603_IIC_ADDRESS);
	while (XIicPs_BusIsBusy(&iic)) {}
	return (RecvBuffer[0]);
}

void I2C_Write1Byte(uint8_t address, uint8_t data)
{
	uint8_t SendBuffer[2];

	SendBuffer[0] = address;
	SendBuffer[1] = data;
	XIicPs_MasterSendPolled(&iic, SendBuffer, 2, SSM2603_IIC_ADDRESS);
	while (XIicPs_BusIsBusy(&iic)) {}
}

int initI2C(void)
{
	XIicPs_Config *Config;
	int Status = XST_SUCCESS;

	Config = XIicPs_LookupConfig(XPAR_XIICPS_0_DEVICE_ID);
	XIicPs_CfgInitialize(&iic, Config, Config->BaseAddress);
	XIicPs_SetSClk(&iic, 100000);

	return Status;
}

#define INIT_COUNT 11*2

uint8_t SSM2603_Init[INIT_COUNT] = {
 30 | 0x00, 0x00 ,    /* R15: RESET */
  0 | 0x01, 0x17 ,    /* R0: L_in vol : LR simul-update, unmute, 0dB */
  2 | 0x01, 0x17 ,    /* R1: R_in vol : LR simul-update, unmute, 0dB */
  4 | 0x01, 0xF9 ,    /* R2: L_HP vol : LR simul-update, zero-cross, 0dB */
  6 | 0x01, 0xF9 ,    /* R3: R_HP vol : LR simul-update, zero-cross, 0dB */
  8 | 0x00, 0x12 ,    /* R4: Analog Audio Path : No Sidetone, No bypass, DAC for Out, Line out for ADC, Mic Mute */
 10 | 0x00, 0x00 ,    /* R5: Digital Path: DAC unmute, De-emphasis 48k, ADC HPF enable */
 12 | 0x00, 0x02 ,    /* R6: Power Down : Only Mic is down*/
 14 | 0x00, 0x4E ,    /* R7: Digital Audio Format : Master, 32bit, I2S */
 16 | 0x00, 0x01 ,    /* R8: Sanmpling Rate, 48kHz, USB mode*/
 18 | 0x00, 0x01      /* R9: Activateion : Active. */
};

void InitSSM2603(void)
{
	int i;
	for (i = 0; i < 11; i++)
		I2C_Write1Byte(SSM2603_Init[i * 2], SSM2603_Init[i * 2 + 1]);
}

int main()
{
    init_platform();
    initI2C();

    xil_printf("Hello World\n\r");

    InitSSM2603();

    cleanup_platform();
    return 0;
}
