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
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
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

#include "xil_io.h"
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

#include "platform.h"

#define MAT_SIZE 9
#define GPIO_OUT 0x40000000
#define GPIO_IN 0x40000008

int get_value() {
    int value = Xil_In16(GPIO_IN);
    while ((value & 0x8000) == 0) {
        value = Xil_In16(GPIO_IN);
    }
    value = value & 0x00FF;

    Xil_Out16(GPIO_OUT, 0x8000);
    Xil_Out16(GPIO_OUT, 0x0000);

    return value;
}

void send_value(int value) {
    value = value | 0x4000;
    Xil_Out16(GPIO_OUT, value);
    Xil_Out16(GPIO_OUT, 0x0000);
}

int main() {
    init_platform();

    int A[MAT_SIZE];
    int B[MAT_SIZE];
    int C[MAT_SIZE] = { 0 };

    for (size_t i = 0; i < MAT_SIZE; i++) {
        A[i] = get_value();
    }

    for (size_t i = 0; i < MAT_SIZE; i++) {
        B[i] = get_value();
    }

    for (size_t i = 0; i < MAT_SIZE; i++) {
        C[i] = A[i] + B[i];
    }

    for (size_t i = 0; i < MAT_SIZE; i++) {
        send_value(C[i]);
    }

    cleanup_platform();
    return 0;
}
