unsigned int *copy_addr; // = &_test_start;
unsigned int copy_count = 0;
const unsigned int sensor_size = 64;
volatile unsigned int *sensor_addr = (int *) 0x10000000;
void copy () {
  int i;
  for (i = 0; i < sensor_size; i++) { // Copy data from sensor controller to DM
    *(copy_addr + i) = sensor_addr[i];
  }
  copy_addr += sensor_size; // Update copy address
  copy_count++;    // Increase copy count
  sensor_addr[0x80] = 1; // Enable sctrl_clear
  sensor_addr[0x80] = 0; // Disable sctrl_clear
  if (copy_count == 8) {
    asm("li t6, 0x80");
    asm("csrc mstatus, t6"); // Disable MPIE of mstatus
  }
  return;
}

int main(void) {
	unsigned int * _PE_addr        = (unsigned int *) 0x30000000;
	//unsigned int * _DRAM_img_start = (unsigned int *) 0x20101000;
	unsigned int * _DRAM_img_start = (unsigned int *) 0x20101000;
	unsigned int * _DRAM_ans_start = (unsigned int *) 0x201fff00;
	
	unsigned int frame_data;
	unsigned int start_address;
	unsigned int data_address;
	unsigned int max_value;
	unsigned int max_x;
	unsigned int max_y;
	//320(x)*240(y)
	unsigned int current_left_top_x = 75;
	unsigned int current_left_top_y = 131;
	
	unsigned int garbage;
	
	for(unsigned int frame_num = 0; frame_num < 3; frame_num++)
	{
		//start_address = frame_num * 320 * 240;
		start_address = (frame_num << 16) + (frame_num << 13) + (frame_num << 11) + (frame_num << 10) ; 
		if(frame_num > 0)
		{
			for(unsigned int y = 0; y < 32; y++)
			{	
				for(unsigned int x = 0; x < 32; x++)
				{
					data_address = start_address + ((current_left_top_y + y) << 8) + ((current_left_top_y + y) << 6) + current_left_top_x + x;
					frame_data = *(_DRAM_img_start + data_address);
					*(_PE_addr + (y << 5) + x) = frame_data;
				}
			}
			//Activate PartB
			*(_PE_addr + 0x00001000) = 0x00000002;
			for(unsigned int i = 0; i < 100; i++)
			{
				garbage = i;
			}
			max_value = 0;
			for(unsigned int y = 0; y < 32; y++)
			{
				for(unsigned int x = 0; x < 32; x++)
				{
					data_address = (y << 5) + x;
					if(*(_PE_addr + data_address) > max_value)
					{
						max_value = *(_PE_addr + data_address);
						max_x = x;
						max_y = y;
					}
				}
			}
			current_left_top_x = current_left_top_x + max_x - 16;
			current_left_top_y = current_left_top_y + max_y - 16;
		}
		*(_DRAM_ans_start + (frame_num << 1) + 0) = current_left_top_x;
		*(_DRAM_ans_start + (frame_num << 1) + 1) = current_left_top_y;
		
		//PartA data movement
		for(unsigned int y = 0; y < 32; y++)
		{	
			for(unsigned int x = 0; x < 32; x++)
			{
				data_address = start_address + ((current_left_top_y + y) << 8) + ((current_left_top_y + y) << 6) + current_left_top_x + x;
				frame_data = *(_DRAM_img_start + data_address);
				*(_PE_addr + (y << 5) + x) = frame_data;
			}
		}
		//Activate PartA
		*(_PE_addr + 0x00001000) = 0x00000001;
	}
	
	return 0;
}