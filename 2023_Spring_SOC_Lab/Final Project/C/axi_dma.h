/*
 * axi_dma.h
 *
 *  Created on: 2019�~8��24��
 *      Author: jychen
 */

#ifndef SRC_AXI_DMA_H_
#define SRC_AXI_DMA_H_
#define PL_START 0x40000000
#define PL_END   0x40000020

void AXI_DMA_Init(void);
void AXI_DMA_Transfer(UINTPTR BuffAddr, u32 Length, int Direction);
// void AXI_DMA_IP_TEST(void);

extern volatile int AXI_DMA_TxDone;
extern volatile int AXI_DMA_RxDone;

#endif /* SRC_AXI_DMA_H_ */
