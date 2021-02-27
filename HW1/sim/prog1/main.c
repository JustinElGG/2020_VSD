int main(void){
  extern int array_addr;
  extern int array_size;;
  extern int _test_start;
  int addr;  
  int x;
  int read_addr;
  int temp;
  
  
  for(addr = 0; addr < array_size; addr++){
    *((&_test_start)+addr) = *((&array_addr)+addr);
  }
  
  for(x=0; x < array_size - 1; x++){
    for(read_addr = 0; read_addr <= array_size - 2 - x; read_addr++){
      if(*((&_test_start) + read_addr) > *((&_test_start) + read_addr + 1)){
		temp = *((&_test_start) + read_addr);
		*((&_test_start) + read_addr) = *((&_test_start) + read_addr + 1);
		*((&_test_start) + read_addr + 1) = temp;
      }
    }
  }  
}
