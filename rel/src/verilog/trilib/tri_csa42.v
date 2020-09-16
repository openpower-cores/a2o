// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.


module tri_csa42(
   a,
   b,
   c,
   d,
   ki,
   ko,
   car,
   sum,
   vd,
   gd
);
   input   a;
   input   b;
   input   c;
   input   d;
   input   ki;
   output  ko;
   output  car;
   output  sum;
   (* ANALYSIS_NOT_ASSIGNED="TRUE" *)
   (* ANALYSIS_NOT_REFERENCED="TRUE" *)
   inout   vd;
   (* ANALYSIS_NOT_ASSIGNED="TRUE" *)
   (* ANALYSIS_NOT_REFERENCED="TRUE" *)
   inout   gd;

   wire    s1;

   wire    carn1;
   wire    carn2;
   wire    carn3;
   wire    kon1;
   wire    kon2;
   wire    kon3;

//   assign  s1 = b ^ c ^ d;
   tri_xor3 CSA42_XOR3_1(s1,b,c,d);

//   assign sum = s1 ^ a ^ ki;
   tri_xor3 CSA42_XOR3_2(sum,s1,a,ki);

//   assign car = (s1 & a) | (s1 & ki) | (a & ki);
   tri_nand2 CSA42_NAND2_1(carn1,s1,a);
   tri_nand2 CSA42_NAND2_2(carn2,s1,ki);
   tri_nand2 CSA42_NAND2_3(carn3,a,ki);
   tri_nand3 CSA42_NAND3_4(car,carn1,carn2,carn3);

//   assign ko = (b & c) | (b & d) | (c & d);
   tri_nand2 CSA42_NAND2_5(kon1,b,c);
   tri_nand2 CSA42_NAND2_6(kon2,b,d);
   tri_nand2 CSA42_NAND2_7(kon3,c,d);
   tri_nand3 CSA42_NAND3_8(ko,kon1,kon2,kon3);


endmodule
