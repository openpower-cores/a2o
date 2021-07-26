// © IBM Corp. 2020
// Licensed under the Apache License, Version 2.0 (the "License"), as modified by
// the terms below; you may not use the files in this repository except in
// compliance with the License as modified.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Modified Terms:
//
//    1) For the purpose of the patent license granted to you in Section 3 of the
//    License, the "Work" hereby includes implementations of the work of authorship
//    in physical form.
//
//    2) Notwithstanding any terms to the contrary in the License, any licenses
//    necessary for implementation of the Work that are available from OpenPOWER
//    via the Power ISA End User License Agreement (EULA) are explicitly excluded
//    hereunder, and may be obtained from OpenPOWER under the terms and conditions
//    of the EULA.  
//
// Unless required by applicable law or agreed to in writing, the reference design
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
// for the specific language governing permissions and limitations under the License.
// 
// Additional rights, including the ability to physically implement a softcore that
// is compliant with the required sections of the Power ISA Specification, are
// available at no cost under the terms of the OpenPOWER Power ISA EULA, which can be
// obtained (along with the Power ISA) here: https://openpowerfoundation.org. 

//  Description:  XU ALU or reduce component
//
//*****************************************************************************
module tri_st_or3232(
   d,
   or_hi_b,
   or_lo_b
);
   input [0:63] d;		//data
   output       or_hi_b;		// upper 32 ORed together
   output       or_lo_b;                // lower 32 ORed together


   wire [0:31]  or_lv1_b;
   wire [0:15]  or_lv2;
   wire [0:7]   or_lv3_b;
   wire [0:3]   or_lv4;
   wire [0:1]   or_lv5_b;

   assign or_lv1_b[0] = (~(d[0] | d[1]));
   assign or_lv1_b[1] = (~(d[2] | d[3]));
   assign or_lv1_b[2] = (~(d[4] | d[5]));
   assign or_lv1_b[3] = (~(d[6] | d[7]));
   assign or_lv1_b[4] = (~(d[8] | d[9]));
   assign or_lv1_b[5] = (~(d[10] | d[11]));
   assign or_lv1_b[6] = (~(d[12] | d[13]));
   assign or_lv1_b[7] = (~(d[14] | d[15]));
   assign or_lv1_b[8] = (~(d[16] | d[17]));
   assign or_lv1_b[9] = (~(d[18] | d[19]));
   assign or_lv1_b[10] = (~(d[20] | d[21]));
   assign or_lv1_b[11] = (~(d[22] | d[23]));
   assign or_lv1_b[12] = (~(d[24] | d[25]));
   assign or_lv1_b[13] = (~(d[26] | d[27]));
   assign or_lv1_b[14] = (~(d[28] | d[29]));
   assign or_lv1_b[15] = (~(d[30] | d[31]));
   assign or_lv1_b[16] = (~(d[32] | d[33]));
   assign or_lv1_b[17] = (~(d[34] | d[35]));
   assign or_lv1_b[18] = (~(d[36] | d[37]));
   assign or_lv1_b[19] = (~(d[38] | d[39]));
   assign or_lv1_b[20] = (~(d[40] | d[41]));
   assign or_lv1_b[21] = (~(d[42] | d[43]));
   assign or_lv1_b[22] = (~(d[44] | d[45]));
   assign or_lv1_b[23] = (~(d[46] | d[47]));
   assign or_lv1_b[24] = (~(d[48] | d[49]));
   assign or_lv1_b[25] = (~(d[50] | d[51]));
   assign or_lv1_b[26] = (~(d[52] | d[53]));
   assign or_lv1_b[27] = (~(d[54] | d[55]));
   assign or_lv1_b[28] = (~(d[56] | d[57]));
   assign or_lv1_b[29] = (~(d[58] | d[59]));
   assign or_lv1_b[30] = (~(d[60] | d[61]));
   assign or_lv1_b[31] = (~(d[62] | d[63]));

   assign or_lv2[0] = (~(or_lv1_b[0] & or_lv1_b[1]));
   assign or_lv2[1] = (~(or_lv1_b[2] & or_lv1_b[3]));
   assign or_lv2[2] = (~(or_lv1_b[4] & or_lv1_b[5]));
   assign or_lv2[3] = (~(or_lv1_b[6] & or_lv1_b[7]));
   assign or_lv2[4] = (~(or_lv1_b[8] & or_lv1_b[9]));
   assign or_lv2[5] = (~(or_lv1_b[10] & or_lv1_b[11]));
   assign or_lv2[6] = (~(or_lv1_b[12] & or_lv1_b[13]));
   assign or_lv2[7] = (~(or_lv1_b[14] & or_lv1_b[15]));
   assign or_lv2[8] = (~(or_lv1_b[16] & or_lv1_b[17]));
   assign or_lv2[9] = (~(or_lv1_b[18] & or_lv1_b[19]));
   assign or_lv2[10] = (~(or_lv1_b[20] & or_lv1_b[21]));
   assign or_lv2[11] = (~(or_lv1_b[22] & or_lv1_b[23]));
   assign or_lv2[12] = (~(or_lv1_b[24] & or_lv1_b[25]));
   assign or_lv2[13] = (~(or_lv1_b[26] & or_lv1_b[27]));
   assign or_lv2[14] = (~(or_lv1_b[28] & or_lv1_b[29]));
   assign or_lv2[15] = (~(or_lv1_b[30] & or_lv1_b[31]));

   assign or_lv3_b[0] = (~(or_lv2[0] | or_lv2[1]));
   assign or_lv3_b[1] = (~(or_lv2[2] | or_lv2[3]));
   assign or_lv3_b[2] = (~(or_lv2[4] | or_lv2[5]));
   assign or_lv3_b[3] = (~(or_lv2[6] | or_lv2[7]));
   assign or_lv3_b[4] = (~(or_lv2[8] | or_lv2[9]));
   assign or_lv3_b[5] = (~(or_lv2[10] | or_lv2[11]));
   assign or_lv3_b[6] = (~(or_lv2[12] | or_lv2[13]));
   assign or_lv3_b[7] = (~(or_lv2[14] | or_lv2[15]));

   assign or_lv4[0] = (~(or_lv3_b[0] & or_lv3_b[1]));
   assign or_lv4[1] = (~(or_lv3_b[2] & or_lv3_b[3]));
   assign or_lv4[2] = (~(or_lv3_b[4] & or_lv3_b[5]));
   assign or_lv4[3] = (~(or_lv3_b[6] & or_lv3_b[7]));

   assign or_lv5_b[0] = (~(or_lv4[0] | or_lv4[1]));
   assign or_lv5_b[1] = (~(or_lv4[2] | or_lv4[3]));

   assign or_hi_b = or_lv5_b[0];		// rename --output--
   assign or_lo_b = or_lv5_b[1];		// rename --output--

endmodule
