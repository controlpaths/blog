/* Project FFT through DMA */

/* DMA libraries */
#include "xaxidma.h"
#include "xparameters.h"
#include "xdebug.h"

/* Math library */
#include "math.h"

/* DMA devices */
#define DMA_DEV_DATA XPAR_AXIDMA_0_DEVICE_ID
#define DMA_DEV_CONFIG XPAR_AXIDMA_1_DEVICE_ID

/* Memory data ranges */
#define DDR_BASE_ADDR XPAR_PSU_DDR_0_S_AXI_BASEADDR
#define CONFIG_PKG_LENGTH 0x4
#define DATA_PKG_LENGTH 0x100
#define N_SAMPLES 64

#define MEM_BASE_ADDR (DDR_BASE_ADDR + 0x1000000)
#define CONFIG_BUFFER_BASE (MEM_BASE_ADDR)
#define TX_BUFFER_BASE (MEM_BASE_ADDR + CONFIG_PKG_LENGTH)
#define RX_BUFFER_BASE	(TX_BUFFER_BASE + DATA_PKG_LENGTH)
#define RX_BUFFER_END	(RX_BUFFER_BASE + DATA_PKG_LENGTH)

/* xFFT configuration */
#define xFFT_FORWARD_nINVERSE 1 /* 1bit */
#define xFFT_SCALE 0x1A /*6bits */

#define xFFT_CONFIG ((xFFT_FORWARD_nINVERSE & 0x1) + ((xFFT_SCALE & 0x3f) << 1))

XAxiDma AxiDma_config; /* DMA1 instance declaration */
XAxiDma AxiDma_data; /* DMA0 instance declaration */

int main(){

	XAxiDma_Config *cfgptr_config; /*dma config configuration */
	XAxiDma_Config *cfgptr_data; /*dma data configuration*/
	int status;
	u32 *config_buffer_ptr; /* pointer to xfft configuration */
	u32 *datatx_buffer_ptr; /* pointer to tx data configuration */
	int *datarx_buffer_ptr; /* pointer to rx data configuration */
	int i;

	/* Signal variables */
	float angle = 0.0; 	/* Angle */
	float angle_inc; /* Angle increment according harmonic to synthesize */

	/* Verification */
	float abs[64];
	float re2;
	float im2;
	int re;
	int im;

	/* Pointer initialization */
	config_buffer_ptr = (u32 *)CONFIG_BUFFER_BASE;
	datatx_buffer_ptr = (u32 *)TX_BUFFER_BASE;
	datarx_buffer_ptr = (int *)RX_BUFFER_BASE;

	/* Read dma configuration */
	cfgptr_config = XAxiDma_LookupConfig(DMA_DEV_CONFIG);
	cfgptr_data = XAxiDma_LookupConfig(DMA_DEV_DATA);

	if (!cfgptr_config || !cfgptr_data) {
		xil_printf("No config found\r\n");
	}

	/* dma device initialization */
	status = XAxiDma_CfgInitialize(&AxiDma_config, cfgptr_config);
	if (status != XST_SUCCESS) {
		xil_printf("Configuration fail on DMA config\r\n");
	}

	status = XAxiDma_CfgInitialize(&AxiDma_data, cfgptr_data);
	if (status != XST_SUCCESS) {
		xil_printf("Configuration fail on DMA data\r\n");
	}

	/* Disable interrupts */
	XAxiDma_IntrDisable(&AxiDma_config, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(&AxiDma_config, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

	XAxiDma_IntrDisable(&AxiDma_data, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(&AxiDma_data, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

	/* Set configuration */
	config_buffer_ptr[0] = (u32)xFFT_CONFIG;

	/* Set signal vector */

	/* Sine signal */
	angle_inc = 2*3.141592/N_SAMPLES;
	for (i=0; i<DATA_PKG_LENGTH; i++){
		datatx_buffer_ptr[i] = (int)(1260*sin(3*angle)) & 0xFFFF;
		angle = angle + angle_inc;
	}

	/* Flush the buffers before the dma transfer */
	Xil_DCacheFlushRange((UINTPTR)config_buffer_ptr, CONFIG_PKG_LENGTH);
	Xil_DCacheFlushRange((UINTPTR)datatx_buffer_ptr, DATA_PKG_LENGTH);
	Xil_DCacheFlushRange((UINTPTR)datarx_buffer_ptr, DATA_PKG_LENGTH);

	/* Transfer configuration */
	status = XAxiDma_SimpleTransfer(&AxiDma_config, (UINTPTR)config_buffer_ptr, CONFIG_PKG_LENGTH, XAXIDMA_DMA_TO_DEVICE);

	if (status != XST_SUCCESS) {
		xil_printf("Configuration sending FAILED\r\n");
		while(1);
	}
	else
		xil_printf("Config data sent\r\n");

	/* Set the dma receiver */
//	status = XAxiDma_SimpleTransfer(&AxiDma_data, (UINTPTR)datarx_buffer_ptr, DATA_PKG_LENGTH, XAXIDMA_DEVICE_TO_DMA);
//
//	if (status != XST_SUCCESS) {
//		xil_printf("Data receive configuration FAILED\r\n");
//		while(1);
//	}

	/* Perform dma transmission */
	status = XAxiDma_SimpleTransfer(&AxiDma_data, (UINTPTR)datatx_buffer_ptr, DATA_PKG_LENGTH, XAXIDMA_DMA_TO_DEVICE);

	if (status != XST_SUCCESS) {
		xil_printf("Data sending FAILED\r\n");
		while(1);
	}
	else
		xil_printf("Data sent\r\n");

	/* This code is only for verification purposes */
	for (i=0; i<N_SAMPLES; i++) {
		if ((datarx_buffer_ptr[i]>>15)&0x1)
			re = (int)((datarx_buffer_ptr[i] & 0xffff))|0xffff0000;
		else
			re = (int)((datarx_buffer_ptr[i] & 0xffff));

		if ((datarx_buffer_ptr[i]>>31)&0x1)
			im = (int)(((datarx_buffer_ptr[i] >> 16) & 0xffff))|0xffff0000;
		else
			im = (int)(((datarx_buffer_ptr[i] >> 16) & 0xffff));

		re2 = (float)(re*re);
		im2 = (float)(im*im);
		abs[i] = sqrt(re2+im2);
	}

	/* Perform dma transmission */
	status = XAxiDma_SimpleTransfer(&AxiDma_data, (UINTPTR)datatx_buffer_ptr, DATA_PKG_LENGTH, XAXIDMA_DMA_TO_DEVICE);

	if (status != XST_SUCCESS) {
		xil_printf("Data sending FAILED\r\n");
		while(1);
	}
	else
		xil_printf("Data sent\r\n");


	xil_printf("Program end\r\n");
	while(1);
}
