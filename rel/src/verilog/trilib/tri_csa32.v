// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.


module tri_csa32(
   a,
   b,
   c,
   car,
   sum,
   vd,
   gd
);
   input   a;
   input   b;
   input   c;
   output  car;
   output  sum;
   (* ANALYSIS_NOT_ASSIGNED="TRUE" *)
   (* ANALYSIS_NOT_REFERENCED="TRUE" *)
   inout   vd;
   (* ANALYSIS_NOT_ASSIGNED="TRUE" *)
   (* ANALYSIS_NOT_REFERENCED="TRUE" *)
   inout   gd;

   wire    carn1;
   wire    carn2;   
   wire    carn3;
   
   tri_xor3 CSA42_XOR3_1(sum, a, b, c);
      
   tri_nand2 CSA42_NAND2_1(carn1, a, b);
   tri_nand2 CSA42_NAND2_2(carn2, a, c);
   tri_nand2 CSA42_NAND2_3(carn3, b, c);
   tri_nand3 CSA42_NAND3_4(car, carn1, carn2, carn3);
   
   
endmodule
