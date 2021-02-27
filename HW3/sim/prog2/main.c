
int main(void){      
      extern unsigned char _binary_image_bmp_start;
    //  extern unsigned char _binary_image_bmp_end;
      extern char _binary_image_bmp_size[];
      extern unsigned char _test_start;
      unsigned char b,g,r;  
      int i;
      
      for (i=0;i<(int)_binary_image_bmp_size;i+=3)
      {
        if(i<54)
        {
          b=*(&_binary_image_bmp_start+i);
          g=*((&_binary_image_bmp_start)+i+1);
          r=*((&_binary_image_bmp_start)+i+2);
           *((&_test_start)+i)=b;//temp;
           *((&_test_start)+i+1)=g;//temp;
           *((&_test_start)+i+2)=r;//temp;
        }
        else
        {
          b=*(&_binary_image_bmp_start+i);
          g=*((&_binary_image_bmp_start)+i+1);
          r=*((&_binary_image_bmp_start)+i+2);
          unsigned char temp= (11*b + 59*g + 30*r)/100;
           *((&_test_start)+i)=temp;
           *((&_test_start)+i+1)=temp;  
           *((&_test_start)+i+2)=temp;
        } 
      }          
}