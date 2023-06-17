#include "ff.h"
#include "xaxidma.h"
#include "xparameters.h"
#include "xil_exception.h"
#include "xdebug.h"
#include "read_write_data.h"
#include "math.h"

static FIL fil_file;
static FATFS fatfs;

// file names
// const static char file_input[32] = "dect_img1.dat";
// const static char file_input[32] = "dect_img1_2.dat";
const static char file_input[32] = "test_pic_sdk.dat";
const static char golden_input[32] = "huffman_code_golden_sdk.dat";
const static char file_out[32] = "huffman_code_ans_sdk.dat";
// const static char file_input[32] = "dect_img3.dat";
// const static char file_input[32] = "dect_img3_2.dat";
// const static char file_input[32] = "dect_img4.dat";

// convert function
char str_to_char(char *temp2)
{
    char cal = 0, pow = 1, digit = 0;
    for (int j = 0; j < 2; j++)
    {
        // xil_printf("ori = %c\n", temp2[1-j]);
        if (temp2[1 - j] >= '0' && temp2[1 - j] <= '9') // 0~9
            digit = temp2[1 - j] - '0';
        else // A~F
            digit = temp2[1 - j] - 'A' + 10;
        // xil_printf("digit = %x\n", digit);
        cal += digit * pow;
        // xil_printf("cal = %x\n", cal);
        pow = pow * 16;
    }
    // xil_printf("CAL_NUM = %x  ",cal);
    // xil_printf("temp2 = %x  ",temp2);
    return cal;
}

// read data function
int READ_u8(int size, char **file_name, u8 *out)
{
    FRESULT Res;
    UINT NumBytesRead;

    u8 temp[3];
    char temp1[3];
    //char temp2[2];
    char temp3;
    //char temp4;
    u8 temp5;
    //u8 temp6;

    Res = f_open(&fil_file, file_name, FA_READ);
    if (Res)
    {
        xil_printf("-- Failed at stage 2 --\r\n");
        return XST_FAILURE;
    }

    // Set pointer to beginning of file.
    Res = f_lseek(&fil_file, 0);
    if (Res)
    {
        xil_printf("-- Failed at stage 3 --\r\n");
        return XST_FAILURE;
    }

    // Read data from file.
    for (int i = 0; i < size; i++)
    {
        // 2 character each time(because dat file save in hex form)
        Res = f_read(&fil_file, (void *)temp, 2, &NumBytesRead);
        if(i == 0)
            xil_printf("\nThe first read data is %s\n" ,temp);

        if (Res)
        {
            xil_printf("-- Failed at stage 4 --\r\n");
            return XST_FAILURE;
        }
        temp1[2] = '\0';
        //temp2[1] = '\0';

        for (int j = 0; j < 2; j++)
        {
            temp1[j] = temp[j];
        }
        //for (int j = 0; j < 1; j++)
        //{
        //    temp2[j] = temp[j + 1];
        //}
        //if(i == 0)
        //{
            //xil_printf("temp1[0] = %c\n" ,temp1[0]);
            //xil_printf("temp1[1] = %c\n" ,temp1[1]);
            //xil_printf("%c ,%c\n" ,temp2[0] ,temp2[1]);
        //}

        temp3 = str_to_char(temp1);
        //temp4 = str_to_char(temp2);
        temp5 = temp3;
        //temp6 = temp4;

        //if(i == 0)
        //{
            //xil_printf("The first data after converting is %d\n" ,temp5);
            //xil_printf("%d\n" ,temp6);
        //}

        // 8 bits unsigned int
        //out[i] = (temp5 << 4) + temp6;
        //out[i] = (temp5 * 16) + temp6;
        out[i] = temp5;

        if(i == 0)
            xil_printf("The first data %d will be storage\n" ,out[i]);
        else if(i == (size - 1))
            xil_printf("The last data %d will be storage\r\n" ,out[i]);
    }

    // Close file.
    Res = f_close(&fil_file);
    if (Res)
    {
        xil_printf("-- Failed at stage 5 --\r\n");
        return XST_FAILURE;
    }

    xil_printf("--- read data done ---\n");
}

int READ_DATA0()
{
    xil_printf("SD Card Reading...\n");

    FRESULT Res;
    UINT NumBytesRead;
    // indicates the root directory of the SD card
    TCHAR *Path = "0:/";

    // Mount the SD card to the file system
    Res = f_mount(&fatfs, Path, 0);
    if (Res != FR_OK)
    {
        xil_printf("-- Failed at stage 1 --\r\n");
        return XST_FAILURE;
    }

    // Read input data
    Res = READ_u8(IFMAP_SIZE, &file_input, (u8)&ifmap0);

    for (int i = 0; i < OFMAP_SIZE; i++)
    {
        data_out[i] = 0;
    }

    xil_printf("SD Card Reading Done!\n");
    return XST_SUCCESS;
}

int WRITE_DATA0()
{
    xil_printf("SD Card writing...\n");

    FRESULT Res;
    UINT NumBytesRead;
    // indicates the root directory of the SD card
    TCHAR *Path = "0:/";

    // Mount the SD card to the file system
    Res = f_mount(&fatfs, Path, 0);
    if (Res != FR_OK)
    {
        xil_printf("-- Failed at stage 1 --\r\n");
        return XST_FAILURE;
    }

    // Read input data
    Res = WRITE_u16(OFMAP_SIZE, &file_out, (u16)&data_out);

    xil_printf("SD Card writing Done!\n");
    return XST_SUCCESS;
}

// read data function
int WRITE_u16(int size, char **file_name, u16 *out)
{
    FRESULT Res;
    UINT NumBytesRead;

    Res = f_open(&fil_file, file_name, FA_WRITE);
    if (Res)
    {
        xil_printf("-- Failed at stage 2 --\r\n");
        return XST_FAILURE;
    }

    // Set pointer to beginning of file.
    Res = f_lseek(&fil_file, 0);
    if (Res)
    {
        xil_printf("-- Failed at stage 3 --\r\n");
        return XST_FAILURE;
    }

    // Read data from file.
    for (int i = 0; i < size; i++)
    {
        // 16 character each time(because dat file save in hex form)
        Res = f_write(&fil_file, (void *)out, 2, &NumBytesRead);
        if (Res)
        {
            xil_printf("-- Failed at stage 4 --\r\n");
            return XST_FAILURE;
        }
    }

    // Close file.
    Res = f_close(&fil_file);
    if (Res)
    {
        xil_printf("-- Failed at stage 5 --\r\n");
        return XST_FAILURE;
    }

    xil_printf("--- write data done ---\n");
}



// convert function
char str_to_u16(char *temp2)
{
    char cal = 0, pow = 1, digit = 0;
    for (int j = 0; j < 2; j++)
    {
        // xil_printf("ori = %c\n", temp2[1-j]);
        if (temp2[1 - j] >= '0' && temp2[1 - j] <= '9') // 0~9
            digit = temp2[1 - j] - '0';
        else // A~F
            digit = temp2[1 - j] - 'A' + 10;
        // xil_printf("digit = %x\n", digit);
        cal += digit * pow;
        // xil_printf("cal = %x\n", cal);
        pow = pow * 16;
    }
    // xil_printf("CAL_NUM = %x  ",cal);
    // xil_printf("temp2 = %x  ",temp2);
    return cal;
}

// read data function
int READ_u16(int size, char **file_name, u16 *out)
{
    FRESULT Res;
    UINT NumBytesRead;

    u8 temp[6];
    //u8 temp_0[2];
    char temp1[3];
    char temp2[3];
    char temp3;
    char temp4;
    u16 temp5;
    u16 temp6;

    Res = f_open(&fil_file, file_name, FA_READ);
    if (Res)
    {
        xil_printf("-- Failed at stage 2 --\r\n");
        return XST_FAILURE;
    }

    // Set pointer to beginning of file.
    Res = f_lseek(&fil_file, 0);
    if (Res)
    {
        xil_printf("-- Failed at stage 3 --\r\n");
        return XST_FAILURE;
    }

    // Read data from file.
    for (int i = 0; i < size; i++)
    {
        // 2 character each time(because dat file save in hex form)
        Res = f_read(&fil_file, (void *)temp, 4, &NumBytesRead);
        //Res = f_read(&fil_file, (void *)temp_0, 2, &NumBytesRead);
        //if(i == 0)
        //{
        //    xil_printf("\nThe first read data is %s\n" ,temp);
        //    xil_printf("%c\n" ,temp[0]);
        //    xil_printf("%c\n" ,temp[1]);
        //    xil_printf("%c\n" ,temp[2]);
        //    xil_printf("%c\n" ,temp[3]);
        //    xil_printf("\nThe first read data is %s\n" ,temp_0);
        //    xil_printf("%c\n" ,temp_0[0]);
        //    xil_printf("%c\n" ,temp_0[1]);
        //}

        if (Res)
        {
            xil_printf("-- Failed at stage 4 --\r\n");
            return XST_FAILURE;
        }
        temp1[2] = '\0';
        temp2[2] = '\0';

        for (int j = 0; j < 2; j++)
        {
            temp1[j] = temp[j];
            temp2[j] = temp[j+2];
        }
        //for (int j = 0; j < 1; j++)
        //{
        //    temp2[j] = temp[j + 1];
        //}
        //if(i == 0)
        //{
        //    xil_printf("temp1[0] = %c\n" ,temp1[0]);
        //    xil_printf("temp1[1] = %c\n" ,temp1[1]);
        //    xil_printf("temp1[2] = %c\n" ,temp1[2]);
        //    xil_printf("temp1[3] = %c\n" ,temp1[3]);
        //    xil_printf("temp2[0] = %c\n" ,temp2[0]);
        //    xil_printf("temp2[1] = %c\n" ,temp2[1]);
            //xil_printf("%c ,%c\n" ,temp2[0] ,temp2[1]);
        //}

        temp3 = str_to_u16(temp1);
        temp4 = str_to_u16(temp2);
        temp5 = temp3 & 0x00FF;
        temp6 = temp4 & 0x00FF;

        //if(i == 0)
        //{
        //    xil_printf("temp5 = %d\n" ,temp5);
        //    xil_printf("temp6 = %d\n" ,temp6);
        //}

        // 16 bits unsigned int
        out[i] = (temp5 << 8) + temp6;
        //out[i] = (temp5 * 256) + temp6;
        //out[i] = temp5;

        if(i == 0)
            xil_printf("The first data %d will be storage\n" ,out[i]);
        else if(i == (size - 1))
            xil_printf("The last data %d will be storage\r\n" ,out[i]);
    }

    // Close file.
    Res = f_close(&fil_file);
    if (Res)
    {
        xil_printf("-- Failed at stage 5 --\r\n");
        return XST_FAILURE;
    }

    xil_printf("--- read data done ---\n");
}

int READ_DATA1()
{
    xil_printf("SD Card Reading...\n");
    xil_printf("Golden Pattern Reading...\n");

    FRESULT Res;
    UINT NumBytesRead;
    // indicates the root directory of the SD card
    TCHAR *Path = "0:/";

    // Mount the SD card to the file system
    Res = f_mount(&fatfs, Path, 0);
    if (Res != FR_OK)
    {
        xil_printf("-- Failed at stage 1 --\r\n");
        return XST_FAILURE;
    }

    // Read input data
    Res = READ_u16(OFMAP_SIZE, &golden_input, (u32)&gfmap0);

    xil_printf("SD Card Reading Done!\n");
    return XST_SUCCESS;
}
