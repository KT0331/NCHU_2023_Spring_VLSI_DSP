#ifndef SRC_READ_DATA_H_
#define SRC_READ_DATA_H_

//data size define
#define IFMAP_SIZE 65536
#define OFMAP_SIZE 131072

//store data
u8 *ifmap;
u8 ifmap0[IFMAP_SIZE];

u16 *gfmap;
u16 gfmap0[OFMAP_SIZE];

u32 *ofmap;
u32 data_out[OFMAP_SIZE];

int READ_DATA0();
int READ_DATA1();
int WRITE_DATA0();

#endif /* SRC_READ_DATA_H_ */
