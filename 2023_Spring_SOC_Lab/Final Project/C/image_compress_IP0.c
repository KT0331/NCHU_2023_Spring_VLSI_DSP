#include "image_compress_IP0.h"

#include "xaxidma.h"
#include "xparameters.h"
#include "xil_exception.h"
#include "xdebug.h"
/***************************** Include Files *********************************/
#include "xaxidma.h"
#include "xparameters.h"
#include "xil_exception.h"
#include "xdebug.h"
#include "xstatus.h"
#include "xscugic.h"
#include "axi_dma.h"
#include "sleep.h"

#include "read_write_data.h"
#include "xtime_l.h"

void TX_DATA(int size, u8 *fmap)
{
    AXI_DMA_TxDone = 0;
    AXI_DMA_RxDone = 0;
    Xil_DCacheFlushRange((UINTPTR)(fmap), size * 8);

    AXI_DMA_Transfer((UINTPTR)(fmap), size, XAXIDMA_DMA_TO_DEVICE);
    while (!AXI_DMA_TxDone)
    {
    }
    xil_printf("\n--- TX ifmap done ---");
}

void RX_DATA(int size, u16 *fmap)
{
    AXI_DMA_TxDone = 0;
    AXI_DMA_RxDone = 0;
    Xil_DCacheFlushRange((UINTPTR)(fmap), size * 8);

    AXI_DMA_Transfer((UINTPTR)(fmap), size * 8, XAXIDMA_DEVICE_TO_DMA);

    while(!AXI_DMA_RxDone)
    {
    }
    xil_printf("\n--- RX ofmap done ---");
}

/***************************** Main Function *********************************/
int image_compress_IP0()
{
    XTime start, end;
    u32 time_used;
    XTime_GetTime(&start);

    xil_printf("\nStart image_compress_IP0...\r\n");
    TX_DATA(IFMAP_SIZE, (u8)&ifmap0);

    RX_DATA(OFMAP_SIZE, (u32)&data_out);

    xil_printf("\nimage_compress_IP0 done!");

    XTime_GetTime(&end);
    time_used = ((end - start) * 1000000) / (COUNTS_PER_SECOND);
    xil_printf("\nTime used: %d us\r\n", time_used);
}

/**************************** Verify Function ********************************/
int verify()
{
	int i;
    for(i = 0; i < OFMAP_SIZE; i++)
    {
        if(data_out[i] != gfmap0[i])
        {
            xil_printf("\nReceive data is %d at %d\n", data_out[i], i);
            xil_printf("Golden data is %d at %d\n", gfmap0[i], i);
            break;
        }
    }

    if(i == OFMAP_SIZE)
    {
    	xil_printf("Verify Ending\n");
    	xil_printf("There are no error in your design\n");
    	xil_printf("\nCongratulations!!! The circuit has passed verification");
    }
    else
    {
        xil_printf("Oops!!! There are some errors in your design");
    }
}
