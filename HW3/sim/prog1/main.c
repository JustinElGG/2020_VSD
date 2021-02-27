void swap(int *a, int *b)
{
    int temp = *a;
    *a = *b;
    *b = temp;
}
int Partition(int *arr, int front, int end)
{
    int pivot = arr[end];
    int i = front -1;
    for (int j = front; j < end; j++) 
	{
        if (arr[j] < pivot) 
		{
            i++;
            swap(&arr[i], &arr[j]);
        }
    }
    i++;
    swap(&arr[i], &arr[end]);
    return i;
}
void QuickSort(int *arr, int front, int end)
{
    if (front < end)
	{
        int pivot = Partition(arr, front, end);
        QuickSort(arr, front, pivot - 1);
        QuickSort(arr, pivot + 1, end);
    }
}

int main(void)
{
	extern int array_addr;
	extern int array_size;
	extern int _test_start;
	
	int read_addr_1; 
	int data[128];
	int temp;
	
	for(int i=0;i<array_size;i+=2)  
	{
		read_addr_1=i>>1;
		temp=*(&array_addr+read_addr_1);
		temp=temp<<16;
		temp=temp>>16;
		data[i]=temp;
	}

	for(int i=1;i<array_size;i+=2) 
	{
		read_addr_1=i>>1;
		temp=*(&array_addr+read_addr_1);
		temp=temp>>16;
		data[i]=temp;
	}
	
	QuickSort(data,0,array_size-1);
	
	for(int i=0;i<array_size;i++)
	{
        read_addr_1=i>>1;
        if((i&0x00000001) == 0)   
        {
            *(&_test_start+read_addr_1) = (data[i] & 0x0000ffff);
        }
		else                          
        {
            *(&_test_start+read_addr_1)=*(&_test_start+read_addr_1)+(data[i]<<16);
        }
	}
	
	return 0;
}
