
int main(void)
{
  extern int array_addr[];
  extern int array_size;;
  extern int _test_start;
  int i;  
  int j;
  int k;
  int tmp;
  for(j=0;j<array_size-1;j++)
  {
    for(k=0;k<=array_size-2-j;k++)
    {
      if(array_addr[k]>array_addr[k+1])
      {
		tmp = array_addr[k];
		array_addr[k] = array_addr[k+1];
		array_addr[k+1] = tmp;
      }
    }
  } 
  for(i = 0; i<array_size; i++)
  {
      *((&_test_start)+i) = array_addr[i];
  }
  
  return 0;
}




