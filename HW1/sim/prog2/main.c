int main(void){
  extern int mul1;
  extern int mul2;
  extern int _test_start;

  int H1,H2,L1,L2;
  int mul_LL,mul_LH,mul_HL,mul_HH;
  int mul_M;
  
  H1 = mul1 >> 16;
  H2 = mul2 >> 16;
  L1 = mul1 & 0x0000ffff;
  L2 = mul2 & 0x0000ffff;

  mul_LL = L1 * L2;
  mul_LH = L1 * H2;
  mul_HL = H1 * L2;
  mul_HH = H1 * H2;
  
  mul_M = mul_LH + mul_HL;

  *(&_test_start) = mul_LL+ ((mul_M & 0x0000ffff) << 16);
  *((&_test_start)+1) = mul_HH + (mul_M >> 16);
}
