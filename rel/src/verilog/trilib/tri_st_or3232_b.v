// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

module tri_st_or3232_b(
   d_b,
   or_hi,
   or_lo
);
   
   input [0:63] d_b;		
   output       or_hi;		
   output       or_lo;          

   
   wire [0:31]  ca_or_lv1;
   wire [0:15]  ca_or_lv2_b;
   wire [0:7]   ca_or_lv3;
   wire [0:3]   ca_or_lv4_b;
   wire [0:1]   ca_or_lv5;


   assign ca_or_lv1[0] = (~(d_b[0] & d_b[1]));
   assign ca_or_lv1[1] = (~(d_b[2] & d_b[3]));
   assign ca_or_lv1[2] = (~(d_b[4] & d_b[5]));
   assign ca_or_lv1[3] = (~(d_b[6] & d_b[7]));
   assign ca_or_lv1[4] = (~(d_b[8] & d_b[9]));
   assign ca_or_lv1[5] = (~(d_b[10] & d_b[11]));
   assign ca_or_lv1[6] = (~(d_b[12] & d_b[13]));
   assign ca_or_lv1[7] = (~(d_b[14] & d_b[15]));
   assign ca_or_lv1[8] = (~(d_b[16] & d_b[17]));
   assign ca_or_lv1[9] = (~(d_b[18] & d_b[19]));
   assign ca_or_lv1[10] = (~(d_b[20] & d_b[21]));
   assign ca_or_lv1[11] = (~(d_b[22] & d_b[23]));
   assign ca_or_lv1[12] = (~(d_b[24] & d_b[25]));
   assign ca_or_lv1[13] = (~(d_b[26] & d_b[27]));
   assign ca_or_lv1[14] = (~(d_b[28] & d_b[29]));
   assign ca_or_lv1[15] = (~(d_b[30] & d_b[31]));
   assign ca_or_lv1[16] = (~(d_b[32] & d_b[33]));
   assign ca_or_lv1[17] = (~(d_b[34] & d_b[35]));
   assign ca_or_lv1[18] = (~(d_b[36] & d_b[37]));
   assign ca_or_lv1[19] = (~(d_b[38] & d_b[39]));
   assign ca_or_lv1[20] = (~(d_b[40] & d_b[41]));
   assign ca_or_lv1[21] = (~(d_b[42] & d_b[43]));
   assign ca_or_lv1[22] = (~(d_b[44] & d_b[45]));
   assign ca_or_lv1[23] = (~(d_b[46] & d_b[47]));
   assign ca_or_lv1[24] = (~(d_b[48] & d_b[49]));
   assign ca_or_lv1[25] = (~(d_b[50] & d_b[51]));
   assign ca_or_lv1[26] = (~(d_b[52] & d_b[53]));
   assign ca_or_lv1[27] = (~(d_b[54] & d_b[55]));
   assign ca_or_lv1[28] = (~(d_b[56] & d_b[57]));
   assign ca_or_lv1[29] = (~(d_b[58] & d_b[59]));
   assign ca_or_lv1[30] = (~(d_b[60] & d_b[61]));
   assign ca_or_lv1[31] = (~(d_b[62] & d_b[63]));

   assign ca_or_lv2_b[0] = (~(ca_or_lv1[0] | ca_or_lv1[1]));
   assign ca_or_lv2_b[1] = (~(ca_or_lv1[2] | ca_or_lv1[3]));
   assign ca_or_lv2_b[2] = (~(ca_or_lv1[4] | ca_or_lv1[5]));
   assign ca_or_lv2_b[3] = (~(ca_or_lv1[6] | ca_or_lv1[7]));
   assign ca_or_lv2_b[4] = (~(ca_or_lv1[8] | ca_or_lv1[9]));
   assign ca_or_lv2_b[5] = (~(ca_or_lv1[10] | ca_or_lv1[11]));
   assign ca_or_lv2_b[6] = (~(ca_or_lv1[12] | ca_or_lv1[13]));
   assign ca_or_lv2_b[7] = (~(ca_or_lv1[14] | ca_or_lv1[15]));
   assign ca_or_lv2_b[8] = (~(ca_or_lv1[16] | ca_or_lv1[17]));
   assign ca_or_lv2_b[9] = (~(ca_or_lv1[18] | ca_or_lv1[19]));
   assign ca_or_lv2_b[10] = (~(ca_or_lv1[20] | ca_or_lv1[21]));
   assign ca_or_lv2_b[11] = (~(ca_or_lv1[22] | ca_or_lv1[23]));
   assign ca_or_lv2_b[12] = (~(ca_or_lv1[24] | ca_or_lv1[25]));
   assign ca_or_lv2_b[13] = (~(ca_or_lv1[26] | ca_or_lv1[27]));
   assign ca_or_lv2_b[14] = (~(ca_or_lv1[28] | ca_or_lv1[29]));
   assign ca_or_lv2_b[15] = (~(ca_or_lv1[30] | ca_or_lv1[31]));

   assign ca_or_lv3[0] = (~(ca_or_lv2_b[0] & ca_or_lv2_b[1]));
   assign ca_or_lv3[1] = (~(ca_or_lv2_b[2] & ca_or_lv2_b[3]));
   assign ca_or_lv3[2] = (~(ca_or_lv2_b[4] & ca_or_lv2_b[5]));
   assign ca_or_lv3[3] = (~(ca_or_lv2_b[6] & ca_or_lv2_b[7]));
   assign ca_or_lv3[4] = (~(ca_or_lv2_b[8] & ca_or_lv2_b[9]));
   assign ca_or_lv3[5] = (~(ca_or_lv2_b[10] & ca_or_lv2_b[11]));
   assign ca_or_lv3[6] = (~(ca_or_lv2_b[12] & ca_or_lv2_b[13]));
   assign ca_or_lv3[7] = (~(ca_or_lv2_b[14] & ca_or_lv2_b[15]));

   assign ca_or_lv4_b[0] = (~(ca_or_lv3[0] | ca_or_lv3[1]));
   assign ca_or_lv4_b[1] = (~(ca_or_lv3[2] | ca_or_lv3[3]));
   assign ca_or_lv4_b[2] = (~(ca_or_lv3[4] | ca_or_lv3[5]));
   assign ca_or_lv4_b[3] = (~(ca_or_lv3[6] | ca_or_lv3[7]));

   assign ca_or_lv5[0] = (~(ca_or_lv4_b[0] & ca_or_lv4_b[1]));
   assign ca_or_lv5[1] = (~(ca_or_lv4_b[2] & ca_or_lv4_b[3]));

   assign or_hi = ca_or_lv5[0];		
   assign or_lo = ca_or_lv5[1];		
      

endmodule
