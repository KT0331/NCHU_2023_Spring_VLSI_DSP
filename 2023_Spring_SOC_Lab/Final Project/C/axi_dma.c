/*
 * axi_dma.c
 *
 *  Created on: 2019鉊8鉊��22鉊��
 *      Author: jychen
 */

// axi dma
#include "ff.h"
#include "xaxidma.h"
#include "xparameters.h"
#include "xil_exception.h"
#include "xdebug.h"

/*
 * axi_dma.c
 *
 *  Created on: Aug 24, 2019
 *      Author: CYCHEN
 */

/***************************** Include Files *********************************/

#include "xaxidma.h"
#include "xparameters.h"
#include "xil_exception.h"
#include "xdebug.h"
#include "xstatus.h"
#include "xscugic.h"
#include "axi_dma.h"
#include "sleep.h"
/************************** Constant Definitions *****************************/

/*
 * Device hardware build related constants.
 */

#define DMA_DEV_ID XPAR_AXIDMA_0_DEVICE_ID

#define RX_INTR_ID XPAR_FABRIC_AXIDMA_0_S2MM_INTROUT_VEC_ID
#define TX_INTR_ID XPAR_FABRIC_AXIDMA_0_MM2S_INTROUT_VEC_ID

#define INTC_DEVICE_ID XPAR_SCUGIC_SINGLE_DEVICE_ID

#define INTC XScuGic
#define INTC_HANDLER XScuGic_InterruptHandler

/* Timeout loop counter for reset
 */
#define RESET_TIMEOUT_COUNTER 1000000

/* The interrupt coalescing threshold and delay timer threshold
 * Valid range is 1 to 255
 *
 * We set the coalescing threshold to be the total number of packets.
 * The receive side will only get one completion interrupt for this example.
 */

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/
#ifndef DEBUG
extern void xil_printf(const char *format, ...);
#endif

static void TxIntrHandler(void *Callback);
static void RxIntrHandler(void *Callback);

static int SetupIntrSystem(INTC *IntcInstancePtr,
						   XAxiDma *AxiDmaPtr, u16 TxIntrId, u16 RxIntrId);

/************************** Variable Definitions *****************************/
/*
 * Device instance definitions
 */

static XAxiDma AxiDma; /* Instance of the XAxiDma */

static INTC Intc; /* Instance of the Interrupt Controller */

/*
 * Flags interrupt handlers use to notify the application context the events.
 */

volatile int Error;

/*****************************************************************************/
/**
 *
 * Main function
 *
 * This function is the main entry of the interrupt test. It does the following:
 *	Set up the output terminal if UART16550 is in the hardware build
 *	Initialize the DMA engine
 *	Set up Tx and Rx channels
 *	Set up the interrupt system for the Tx and Rx interrupts
 *	Submit a transfer
 *	Wait for the transfer to finish
 *	Check transfer status
 *	Disable Tx and Rx interrupts
 *	Print test status and exit
 *
 * @param	None
 *
 * @return
 *		- XST_SUCCESS if example finishes successfully
 *		- XST_FAILURE if example fails.
 *
 * @note		None.
 *
 ******************************************************************************/

XAxiDma_Config *Config;
int Status;

volatile int AXI_DMA_TxDone;
volatile int AXI_DMA_RxDone;
void AXI_DMA_Transfer(UINTPTR BuffAddr, u32 Length, int Direction)
{
	/*初始化 AXI DMA IP，包括設置相應的控制寄存器和配置參數。

	配置源地址、目的地址和傳輸長度等參數，以指定要傳輸的數據。

	呼叫 XAxiDma_SimpleTransfer 函式，觸發數據傳輸操作。

	等待數據傳輸完成，可以使用中斷或輪詢等機制進行等待。

	檢查傳輸狀態和錯誤碼，以確保數據傳輸的正確性。*/
	Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)BuffAddr, Length, Direction);
	if (Status != XST_SUCCESS)
	{
		xil_printf("AXI DMA Transfer failed %d\r\n" ,Status);
	}
	else
	{
		xil_printf("AXI DMA Transfer success %d\r\n" ,Status);
	}
}

void AXI_DMA_Init(void)
{
	// sleep(8);
	xil_printf("\r\n--- axi dma initial --- \r\n");
	Config = XAxiDma_LookupConfig(DMA_DEV_ID);
	if (!Config)
	{
		xil_printf("No config found for %d\r\n", DMA_DEV_ID);
	}

	/* Initialize DMA engine */
	Status = XAxiDma_CfgInitialize(&AxiDma, Config);

	if (Status != XST_SUCCESS)
	{
		xil_printf("Initialization failed %d\r\n", Status);
	}

	if (XAxiDma_HasSg(&AxiDma))
	{
		xil_printf("Device configured as SG mode \r\n");
	}

	/* Set up Interrupt system  */
	Status = SetupIntrSystem(&Intc, &AxiDma, TX_INTR_ID, RX_INTR_ID);
	if (Status != XST_SUCCESS)
	{
		xil_printf("Failed intr setup\r\n");
	}

	/* Disable all interrupts before setup */

	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);

	/* Enable all interrupts */
	XAxiDma_IntrEnable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrEnable(&AxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
}

/*
#define TEST_SIZE 8
u64 Source_TX[TEST_SIZE] = {0};
u64 Source_RX[TEST_SIZE] = {0};
u64 test_data=0x0102030405060700;


static FIL fil_bias;
static FIL fil_ifmap;
static FATFS fatfs;
const static char file_ifmap1[32]        = "new_data.dat";
int IFMAP_SIZE = 16;
u8 ifmap1[16] = {0};
u8 data_out[16] = {0};
*/

/*****************************************************************************/
/*
 *
 * This is the DMA TX Interrupt handler function.
 *
 * It gets the interrupt status from the hardware, acknowledges it, and if any
 * error happens, it resets the hardware. Otherwise, if a completion interrupt
 * is present, then sets the AXI_DMA_TxDone.flag
 *
 * @param	Callback is a pointer to TX channel of the DMA engine.
 *
 * @return	None.
 *
 * @note		None.
 *
 ******************************************************************************/
static void TxIntrHandler(void *Callback)
{

	u32 IrqStatus;
	int TimeOut;
	XAxiDma *AxiDmaInst = (XAxiDma *)Callback;

	/* Read pending interrupts */
	IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DMA_TO_DEVICE);

	/* Acknowledge pending interrupts */

	XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DMA_TO_DEVICE);

	/*
	 * If no interrupt is asserted, we do not do anything
	 */
	if (!(IrqStatus & XAXIDMA_IRQ_ALL_MASK))
	{

		return;
	}

	/*
	 * If error interrupt is asserted, raise error flag, reset the
	 * hardware to recover from the error, and return with no further
	 * processing.
	 */
	if ((IrqStatus & XAXIDMA_IRQ_ERROR_MASK))
	{

		Error = 1;

		/*
		 * Reset should never fail for transmit channel
		 */
		XAxiDma_Reset(AxiDmaInst);

		TimeOut = RESET_TIMEOUT_COUNTER;

		while (TimeOut)
		{
			if (XAxiDma_ResetIsDone(AxiDmaInst))
			{
				break;
			}

			TimeOut -= 1;
		}
		xil_printf("TX timeout=%d \n\r", TimeOut);
		return;
	}

	/*
	 * If Completion interrupt is asserted, then set the AXI_DMA_TxDone flag
	 */
	if ((IrqStatus & XAXIDMA_IRQ_IOC_MASK))
	{

		AXI_DMA_TxDone = 1;
	}
}

/*****************************************************************************/
/*
 *
 * This is the DMA RX interrupt handler function
 *
 * It gets the interrupt status from the hardware, acknowledges it, and if any
 * error happens, it resets the hardware. Otherwise, if a completion interrupt
 * is present, then it sets the AXI_DMA_RxDone flag.
 *
 * @param	Callback is a pointer to RX channel of the DMA engine.
 *
 * @return	None.
 *
 * @note		None.
 *
 ******************************************************************************/
static void RxIntrHandler(void *Callback)
{
	u32 IrqStatus;
	int TimeOut;
	XAxiDma *AxiDmaInst = (XAxiDma *)Callback;

	/* Read pending interrupts */
	IrqStatus = XAxiDma_IntrGetIrq(AxiDmaInst, XAXIDMA_DEVICE_TO_DMA);

	/* Acknowledge pending interrupts */
	XAxiDma_IntrAckIrq(AxiDmaInst, IrqStatus, XAXIDMA_DEVICE_TO_DMA);

	/*
	 * If no interrupt is asserted, we do not do anything
	 */
	if (!(IrqStatus & XAXIDMA_IRQ_ALL_MASK))
	{
		return;
	}

	/*
	 * If error interrupt is asserted, raise error flag, reset the
	 * hardware to recover from the error, and return with no further
	 * processing.
	 */
	if ((IrqStatus & XAXIDMA_IRQ_ERROR_MASK))
	{

		Error = 1;

		/* Reset could fail and hang
		 * NEED a way to handle this or do not call it??
		 */
		XAxiDma_Reset(AxiDmaInst);

		TimeOut = RESET_TIMEOUT_COUNTER;

		while (TimeOut)
		{
			if (XAxiDma_ResetIsDone(AxiDmaInst))
			{
				break;
			}

			TimeOut -= 1;
		}
		xil_printf("RX timeout=%d \n\r", TimeOut);
		return;
	}

	/*
	 * If completion interrupt is asserted, then set AXI_DMA_RxDone flag
	 */
	if ((IrqStatus & XAXIDMA_IRQ_IOC_MASK))
	{

		AXI_DMA_RxDone = 1;
	}
}

/*****************************************************************************/
/*
 *
 * This function setups the interrupt system so interrupts can occur for the
 * DMA, it assumes INTC component exists in the hardware system.
 *
 * @param	IntcInstancePtr is a pointer to the instance of the INTC.
 * @param	AxiDmaPtr is a pointer to the instance of the DMA engine
 * @param	TxIntrId is the TX channel Interrupt ID.
 * @param	RxIntrId is the RX channel Interrupt ID.
 *
 * @return
 *		- XST_SUCCESS if successful,
 *		- XST_FAILURE.if not succesful
 *
 * @note		None.
 *
 ******************************************************************************/
static int SetupIntrSystem(INTC *IntcInstancePtr,
						   XAxiDma *AxiDmaPtr, u16 TxIntrId, u16 RxIntrId)
{
	int Status;

	XScuGic_Config *IntcConfig;

	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == IntcConfig)
	{
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig,
								   IntcConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS)
	{
		return XST_FAILURE;
	}

	XScuGic_SetPriorityTriggerType(IntcInstancePtr, TxIntrId, 0xA0, 0x3);

	XScuGic_SetPriorityTriggerType(IntcInstancePtr, RxIntrId, 0xA0, 0x3);
	/*
	 * Connect the device driver handler that will be called when an
	 * interrupt for the device occurs, the handler defined above performs
	 * the specific interrupt processing for the device.
	 */
	Status = XScuGic_Connect(IntcInstancePtr, TxIntrId,
							 (Xil_InterruptHandler)TxIntrHandler,
							 AxiDmaPtr);
	if (Status != XST_SUCCESS)
	{
		return Status;
	}

	Status = XScuGic_Connect(IntcInstancePtr, RxIntrId,
							 (Xil_InterruptHandler)RxIntrHandler,
							 AxiDmaPtr);
	if (Status != XST_SUCCESS)
	{
		return Status;
	}

	XScuGic_Enable(IntcInstancePtr, TxIntrId);
	XScuGic_Enable(IntcInstancePtr, RxIntrId);

	/* Enable interrupts from the hardware */

	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
								 (Xil_ExceptionHandler)INTC_HANDLER,
								 (void *)IntcInstancePtr);

	Xil_ExceptionEnable();

	return XST_SUCCESS;
}
