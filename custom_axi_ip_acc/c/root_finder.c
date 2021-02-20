#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"
#include "math.h"
#include "xgpio.h"

int main()
{
  init_platform();

  long square_root_result;
  long root_finder;
  long delay;
  long root_to_find;

	XGpio gpio; /* The Instance of the GPIO Driver */
	XGpio_Initialize(&gpio, XPAR_GPIO_0_DEVICE_ID);
	XGpio_SetDataDirection(&gpio, 1, 0);
	XGpio_DiscreteWrite(&gpio, 1, 0);

	root_to_find = 300;

	while(1){

		XGpio_DiscreteWrite(&gpio, 1, 1);
		Xil_Out32(0x80000000, root_to_find);
		Xil_Out32(0x80000004, 1);
		while((Xil_In32(0x80000008) & 0x1) == 0);
		square_root_result = Xil_In32(0x8000000c);
		Xil_Out32(0x80000004, 0);
		XGpio_DiscreteWrite(&gpio, 1, 0);

		for(delay=0;delay<100;delay++);

		XGpio_DiscreteWrite(&gpio, 1, 1);

		root_finder = 0;
		square_root_result = 0;
		while(root_finder < root_to_find){
			root_finder = square_root_result*square_root_result;
			square_root_result +=1;
		}
		XGpio_DiscreteWrite(&gpio, 1, 0);

		for(delay=0;delay<10000;delay++);
	}

    cleanup_platform();
    return 0;
}
