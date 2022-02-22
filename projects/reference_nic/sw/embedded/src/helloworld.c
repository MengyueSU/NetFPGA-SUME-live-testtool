/*
 * Copyright (c) 2015 Digilent Inc.
 * Copyright (c) 2015 Tinghui Wang (Steve)
 * All rights reserved.
 *
 *  File:
 *        sw/embedded/src/helloworld.c
 *
 *  Project:
 *       Reference project
 *
 * Author:
 *        Tinghui Wang (Steve)
 *
 *  Description:
 *        Reference project main function.
 *
 * @NETFPGA_LICENSE_HEADER_START@
 *
 * Licensed to NetFPGA C.I.C. (NetFPGA) under one or more contributor
 * license agreements.  See the NOTICE file distributed with this work for
 * additional information regarding copyright ownership.  NetFPGA licenses this
 * file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
 * "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at:
 *
 *   http://www.netfpga-cic.org
 *
 * Unless required by applicable law or agreed to in writing, Work distributed
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * @NETFPGA_LICENSE_HEADER_END@
 *
*/


#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "string.h"
#include "xiic.h"
#include "xintc.h"
#include "xil_types.h"
#include "platform.h"
#include "mb_interface.h"
#include "xuartlite_l.h"
//#include "data_exchange.h"

#define TRIGGER
#define COUNTER
//#define WRITE_OUT
#define IIC_DEVICE_ID               XPAR_IIC_0_DEVICE_ID
#define INTC_DEVICE_ID              XPAR_INTC_0_DEVICE_ID
#define IIC_INTR_ID                 XPAR_INTC_0_IIC_0_VEC_ID
#define ADDR_READ_IP                XPAR_AXI_EXTRACTION_0_S00_AXI_BASEADDR
#define ADDR_WRITE_IP               XPAR_AXI_INSERTION_0_S00_AXI_BASEADDR

#ifdef WRITE_OUT
#define ADDR_WRITE_OUT_IP               XPAR_AXI_INSERTION_1_S00_AXI_BASEADDR
#endif
#ifdef TRIGGER
#define ADDR_TRIGGER_IP 			XPAR_AXI_TRIGGER_0_S00_AXI_BASEADDR
#endif

#ifdef COUNTER
#define ADDR_COUNTER_IP 			XPAR_AXI_COUNTER_0_S00_AXI_BASEADDR
#endif

XIic IicInstance;		/* The instance of the IIC device. */
XIntc InterruptController;	/* The instance of the Interrupt Controller. */

/*
 * printTestResult
 *
 * Print "Passed/Failed" for some test category based on the auto test return value
 */
/*void printTestResult (char* testName, XStatus result) {
	int dotLen = 40 - strlen(testName);
	int i;

	xil_printf("%s", testName);
	for(i = 0; i < dotLen; i++) {
		xil_printf(".");
	}

	if(result == XST_SUCCESS) {
		xil_printf("Passed\r\n");
	} else {
		xil_printf("Failed\r\n");
	}
	return;
}
*/
/*
 * runAutoTest
 *
 * Test all the interface supported by the project automatically
 */
//void runAutoTest(void) {}

/*
 * runManualTest
 *
 * Provide a menu for user to test each interface manually 
 */
/*
void runManualTest(void) {
	xil_printf("\r\n");
	while(1) {
		xil_printf("---- NetFPGA-SUME Manual Test Menu ----\r\n");
		xil_printf("p: Read Power Info\r\n");
		xil_printf("b: Back to Main Menu\r\n");
		xil_printf("Select: ");
		char cmd = XUartLite_RecvByte(XPAR_UARTLITE_0_BASEADDR);
		xil_printf("%c\r\n", cmd);
		switch (cmd) {
			case 'p':
				pmReadInfo();
				break;
			case 'b':
				return;
			default:
				break;
		}
		xil_printf("\r\n");
	}
}
*/
unsigned int le_to_be(unsigned int data){
	
	unsigned int res = 0;
	res = ((data & (unsigned int)0x000000ff) << 24u) + ((data & (unsigned int)0x0000ff00) << 8u) + ((data & (unsigned int)0x00ff0000) >> 8u) + ((data & (unsigned int)0xff000000) >> 24u);
	return res;
}		

unsigned int be_to_le(unsigned int data){
	unsigned int res = 0;
	res = ((data >> 24u) & (unsigned int)0x000000ff) + ((data >> 8u) & (unsigned int)0x0000ff00) + ((data << 8u) & (unsigned int)0x00ff0000) + ((data << 24u) & (unsigned int)0xff000000);
	return res;
}		

unsigned int read_from_ip(int base, int addr){
	unsigned int readdata = Xil_In32((int)base + (addr*4));
	return readdata;
}

void print_insertion_block_level(void){
	int count = read_from_ip(ADDR_WRITE_IP,0);
	xil_printf("%08x", count);
    return;
}

void print_extraction_block_level(void){
	int count = read_from_ip(ADDR_READ_IP,0);
	xil_printf("%08x", count);
    return;
}
#ifdef TRIGGER
void print_trigger_block_level(void){
	int count = read_from_ip(ADDR_TRIGGER_IP,0);
	xil_printf("%08x", count);
    return 0;
	//xil_printf("Read: %08x, Data count: %i, counter: %08x, full: %x, empty: %x\n\r", count, (count & 0x3ff), counter, (count & 0x2000), (count & 0x1000));
	//xil_printf("Capture: %08x, Data count: %i, counter: %08x, full: %x, empty: %x\n\r", count, (((count & 0x7ff0000)) >> 16) , counter, (count & 0x20000000), (count & 0x10000000));
}
#endif
#ifdef WRITE_OUT
void print_insertion_out_block_level(void){
	int count = read_from_ip(ADDR_WRITE_OUT_IP,0);
	xil_printf("%08x", count);
    return;
}

void write_to_out_ip(int addr, int data){
	Xil_Out32(((int)ADDR_WRITE_OUT_IP + (addr*4)), data);
	return 0;
}
#endif

#ifdef COUNTER
void print_counter_block_level(void){
	int count = read_from_ip(ADDR_COUNTER_IP,0);
	xil_printf("%08x", count);
    return 0;
	//xil_printf("Read: %08x, Data count: %i, counter: %08x, full: %x, empty: %x\n\r", count, (count & 0x3ff), counter, (count & 0x2000), (count & 0x1000));
	//xil_printf("Capture: %08x, Data count: %i, counter: %08x, full: %x, empty: %x\n\r", count, (((count & 0x7ff0000)) >> 16) , counter, (count & 0x20000000), (count & 0x10000000));
}
#endif


void init_fifo_read(void){
    while(!(read_from_ip(ADDR_READ_IP,0) & 0x1000)){
        read_from_ip(ADDR_READ_IP,14);
    }
	xil_printf("OK");
    return 0;
}

void write_to_ip(int addr, int data){
	Xil_Out32(((int)ADDR_WRITE_IP + (addr*4)), data);
	return 0;
}





int main()
{
    int Status;

    init_platform();

	xil_printf("NetFPGA-SUME SI5324 Configuration\r\n");

	/*
	 * Setup Iic Instance
	 */
	Status = IicInit(&IicInstance);
	if (Status != XST_SUCCESS) {
		xil_printf("I2C Initialization FAILED\n\r");
		return XST_FAILURE;
	}

	/*
	 * Setup the Interrupt System.
	 */
	Status = SetupInterruptSystem(&IicInstance);
	if (Status != XST_SUCCESS) {
		xil_printf("SetupInterruptSystem FAILED\n\r");
		return XST_FAILURE;
	}

	/*
	 * Enable Iic Bus
	 */
	Status = IicInitPost(&IicInstance);
	if (Status != XST_SUCCESS) {
		xil_printf("I2C Initialization FAILED\n\r");
		return XST_FAILURE;
	}

	config_SI5324();
	while(1){
		char cmd = XUartLite_RecvByte(XPAR_UARTLITE_0_BASEADDR);
		xil_printf("%c\r\n", cmd);
		if(cmd == 'i'){
			init_fifo_read();
		}
		else if(cmd == 'a'){
			print_insertion_block_level();
		}
#ifdef TRIGGER
		else if(cmd == 'c'){
			print_trigger_block_level();
		}
#endif
		else if(cmd == 'b'){
			print_extraction_block_level();
		}
		else if(cmd == 'g'){
			write_to_ip(15, 0x1);
		}
		else if(cmd == 's'){
			write_to_ip(15, 0x0);
		}
		else if(cmd == 'w'){
			char char_data[56] = ""; 
			int i = 0;
			int j = 0;
			for(j=0; j<56;j++){
				char_data[j] = XUartLite_RecvByte(XPAR_UARTLITE_0_BASEADDR);
			}
			for(i = 1; i <= 14; i++){
				int data = (((int)char_data[((i-1)*4)+0] << 24) & 0xFF000000) + (((int)char_data[((i-1)*4)+1] << 16) & 0x00FF0000) + (((int)char_data[((i-1)*4)+2] << 8) & 0x0000FF00) + ((int)char_data[((i-1)*4)+3] & 0x000000FF);
				//sscanf(char_data, "%x", &data);
				//xil_printf("%08x\r\n", data);
				data = be_to_le(data);
				//xil_printf("%08x\r\n", data);
				write_to_ip(i, data);
			}
		}
		else if(cmd == 'r'){
			int i = 0;
			for(i = 1; i <= 14; i++){
				int res = read_from_ip(ADDR_READ_IP,i);
				int res_be = le_to_be(res);
				xil_printf("%08x", res_be);
			}
		}
#ifdef TRIGGER
		else if(cmd == 't'){
			int i = 0;
			for(i = 1; i <= 14; i++){
				int res = read_from_ip(ADDR_TRIGGER_IP,i);
				int res_be = le_to_be(res);
				xil_printf("%08x", res_be);
			}
		}
#endif
#ifdef WRITE_OUT
		else if(cmd == 'o'){
			char char_data[56] = ""; 
			int i = 0;
			int j = 0;
			for(j=0; j<56;j++){
				char_data[j] = XUartLite_RecvByte(XPAR_UARTLITE_0_BASEADDR);
			}
			for(i = 1; i <= 14; i++){
				int data = (((int)char_data[((i-1)*4)+0] << 24) & 0xFF000000) + (((int)char_data[((i-1)*4)+1] << 16) & 0x00FF0000) + (((int)char_data[((i-1)*4)+2] << 8) & 0x0000FF00) + ((int)char_data[((i-1)*4)+3] & 0x000000FF);
				//sscanf(char_data, "%x", &data);
				//xil_printf("%08x\r\n", data);
				data = be_to_le(data);
				//xil_printf("%08x\r\n", data);
				write_to_out_ip(i, data);
			}
		}
		else if(cmd == 'd'){
			print_insertion_out_block_level();
		}
		else if(cmd == 'e'){
			write_to_out_ip(15, 0x1);
		}
		else if(cmd == 'f'){
			write_to_out_ip(15, 0x0);
		}
#endif

#ifdef COUNTER
		else if(cmd == 'h'){
			int i = 0;
			for(i = 1; i <= 2; i++){
				int res = read_from_ip(ADDR_COUNTER_IP,i);
				//int res_be = le_to_be(res);
				xil_printf("%08x", res);
			}
		}
		else if(cmd == 'k'){
			print_counter_block_level();
		}
#endif
		/*else if(cmd == 'w'){
			char char_data[4] = ""; 
			int i = 0;
			for(i=0; i<4;i++){
				char_data[i] = XUartLite_RecvByte(XPAR_UARTLITE_0_BASEADDR);
			}
			for(i = 1; i <= 14; i++){
				char single_data[8];
				memcpy(single_data, (char_data+((i-1)*8)), 8);
				int data = 0;
				sscanf(single_data, "%x", &data);
				xil_printf("%08x\r\n", data);
				data = be_to_le(data);
				xil_printf("%08x\r\n", data);
				write_to_ip(i, data);
			}
		}
		else if(cmd == 'r'){
			char rd_res[112] = "";
			int i = 0;
			for(i = 1; i <= 14; i++){
				char char_res[9] = "";
				int res = read_from_ip(ADDR_READ_IP,i);
				int res_be = le_to_be(res);
				sprintf(char_res,"%08x",res_be);
				memcpy((rd_res+((i-1)*8)), char_res, 8);
			}
			xil_printf("%s", rd_res);
		}
		else if(cmd == 't'){
			char rd_res[112] = "";
			int i = 0;
			for(i = 1; i <= 14; i++){
				char char_res[9] = "";
				int res = read_from_ip(ADDR_TRIGGER_IP,i);
				int res_be = le_to_be(res);
				sprintf(char_res,"%08x",res_be);
				memcpy((rd_res+((i-1)*8)), char_res, 8);
			}
			xil_printf("%s", rd_res);
		}*/




		/*xil_printf("============ NetFPGA-SUME ============\n\r");
		xil_printf("m: Manual Test \r\n");
		xil_printf("u: Read FIFO Used Word \r\n");
		xil_printf("r: Read FIFO Data \r\n");
		xil_printf("t: Check Address 9 \r\n");
		xil_printf("Select: ");
		char cmd = XUartLite_RecvByte(XPAR_UARTLITE_0_BASEADDR);
		xil_printf("%c\r\n", cmd);
		int res = 0;
		int res_be = 0;
		int i = 1;
		switch (cmd) {
			case 'm':
				runManualTest();
				break;
			case 'u':
				res = read_from_ip(0);
				xil_printf("%i, %08x\n\r", res, res);
				xil_printf("Data count: %i, TUSER count: %i\n\r", (res & 0x1ff), ((res >> 16) & 0x1ff));
				break;
			case 'r':
				for(i = 1; i <= 8; i++){
					res = read_from_ip(i);
					res_be = le_to_be(res);
					xil_printf("%i: %08x, %08x\n\r", i, res, res_be);
				}
				xil_printf("TUSER Data\n\r");
				for(i = 9; i <= 12; i++){
					res = read_from_ip(i);
					res_be = le_to_be(res);
					xil_printf("%i: %08x, %08x\n\r", i, res, res_be);
				}

				break;
			case 't':
				res = read_from_ip(13);
				xil_printf("%x\n", res);
				break;
			default:
				break;
		}
		xil_printf("\r\n");*/
		
	}

    return 0;
}

/*****************************************************************************/
/**
* This function setups the interrupt system so interrupts can occur for the
* IIC device. The function is application-specific since the actual system may
* or may not have an interrupt controller. The IIC device could be directly
* connected to a processor without an interrupt controller. The user should
* modify this function to fit the application.
*
* @param	IicInstPtr contains a pointer to the instance of the IIC device
*		which is going to be connected to the interrupt controller.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None.
*
******************************************************************************/
int SetupInterruptSystem(XIic * IicInstPtr)
{
	int Status;

	if (InterruptController.IsStarted == XIL_COMPONENT_IS_STARTED) {
		return XST_SUCCESS;
	}

	/*
	 * Initialize the interrupt controller driver so that it's ready to use.
	 */
	Status = XIntc_Initialize(&InterruptController, INTC_DEVICE_ID);

	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Connect the device driver handler that will be called when an
	 * interrupt for the device occurs, the handler defined above performs
	 * the specific interrupt processing for the device.
	 */
	Status = XIntc_Connect(&InterruptController, IIC_INTR_ID,
			       (XInterruptHandler) XIic_InterruptHandler,
			       IicInstPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Start the interrupt controller so interrupts are enabled for all
	 * devices that cause interrupts.
	 */
	Status = XIntc_Start(&InterruptController, XIN_REAL_MODE);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Enable the interrupts for the IIC device.
	 */
	XIntc_Enable(&InterruptController, IIC_INTR_ID);

	/*
	 * Enable the Microblaze Interrupts.
	 */
	microblaze_enable_interrupts();

	return XST_SUCCESS;
}
