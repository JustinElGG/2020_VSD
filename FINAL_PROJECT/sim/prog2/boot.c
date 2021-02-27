
int boot(void)
{
    extern unsigned int _dram_i_start;
    extern unsigned int _dram_i_end;
    extern unsigned int _imem_start;
    
    extern unsigned int __sdata_start;
    extern unsigned int __sdata_end;
    extern unsigned int __sdata_paddr_start;
    
    extern unsigned int __data_start;
    extern unsigned int __data_end;
    extern unsigned int __data_paddr_start;
    

    int i;
    for(i=0; i<=((&_dram_i_end)-(&_dram_i_start)); i++){
      *((&_imem_start)+i) = *((&_dram_i_start)+i);
    }
    
    for(i=0; i<=((&__data_end)-(&__data_start)); i++){
	  *((&__data_start)+i) = *((&__data_paddr_start)+i);
    } 
    
    for(i=0; i<=((&__sdata_end)-(&__sdata_start)); i++){
	  *((&__sdata_start)+i) = *((&__sdata_paddr_start)+i);
    }

	
	return 0;
}

/*
int boot(void){
	extern unsigned int _dram_i_start[];
	extern unsigned int _dram_i_end[];
	extern unsigned int _imem_start[];
	
	//extern unsigned int __sdata_start[];
	//extern unsigned int __sdata_end[];
	//extern unsigned int __sdata_paddr_start[];
	//
	//extern unsigned int __data_start[];
	//extern unsigned int __data_end[];
	//extern unsigned int __data_paddr_start[];
	
	unsigned int i,j,k,size1,size2,size3;

	size1 = _dram_i_end - _dram_i_start;
	//size2 = __data_end - __data_start;
	//size3 = __sdata_end - __sdata_start;
	
	for(i=0;i<=size1;i++){
		*(_imem_start+i) = *(_dram_i_start+i);
	}

	//for(j=0;j<=size2;j++){
	//	*(__data_start+j) = *(__data_paddr_start+j);
	//}
    //
	//
	//for(k=0;k<=size3;k++){
	//	*(__sdata_start+k) = *(__sdata_paddr_start+k);
	//}
	
	return 0;
}
*/