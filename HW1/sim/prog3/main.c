int main(void) {
	unsigned extern int div1;
	unsigned extern int div2;
	unsigned extern int _test_start;
	
    while( div1!=0 && div2!=0 ){
		if(div2 > div1){
            div2 = div2 % div1;
        }
        else if(div1 >= div2){
            div1 = div1 % div2;
        }
	}

	if(div2 < div1){
		*(&_test_start) = div1;
		}
	else{
		*(&_test_start) = div2;
	}
  return 0;
}