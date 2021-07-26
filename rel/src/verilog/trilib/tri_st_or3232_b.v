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

//  Description:  XU Merge Or-Reduce Component
//
//*****************************************************************************
module tri_st_or3232_b(
   d_b,
   or_hi,
   or_lo
);

   input [0:63] d_b;		//data
   output       or_hi;		// upper 32 ORed together
   output       or_lo;          // lower 32 ORed together


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

   assign or_hi = ca_or_lv5[0];		// rename
   assign or_lo = ca_or_lv5[1];		// rename

// ///////// in placement order //////////////////////////////////////////////
//  u_ca_or_00: ca_or_lv1  ( 0) <= not( d_b  ( 0) and d_b  ( 1) );
//  u_ca_or_01: ca_or_lv2_b( 0) <= not( ca_or_lv1  ( 0) or  ca_or_lv1  ( 1) );
//  u_ca_or_02: ca_or_lv1  ( 1) <= not( d_b  ( 2) and d_b  ( 3) );
//  u_ca_or_03: ca_or_lv3  ( 0) <= not( ca_or_lv2_b( 0) and ca_or_lv2_b( 1) );
//  u_ca_or_04: ca_or_lv1  ( 2  <= not( d_b  ( 4) and d_b  ( 5) );
//  u_ca_or_05: ca_or_lv2_b( 1) <= not( ca_or_lv1  ( 2) or  ca_or_lv1  ( 3) );
//  u_ca_or_06: ca_or_lv1  ( 3) <= not( d_b  ( 6) and d_b  ( 7) );
//  u_ca_or_07: ca_or_lv4_b( 0) <= not( ca_or_lv3  ( 0) or  ca_or_lv3  ( 1) );
//  u_ca_or_08: ca_or_lv1  ( 4) <= not( d_b  ( 8) and d_b  ( 9) );
//  u_ca_or_09: ca_or_lv2_b( 2) <= not( ca_or_lv1  ( 4) or  ca_or_lv1  ( 5) );
//  u_ca_or_10: ca_or_lv1  ( 5) <= not( d_b  (10) and d_b  (11) );
//  u_ca_or_11: ca_or_lv3  ( 1) <= not( ca_or_lv2_b( 2) and ca_or_lv2_b( 3) );
//  u_ca_or_12: ca_or_lv1  ( 6) <= not( d_b  (12) and d_b  (13) );
//  u_ca_or_13: ca_or_lv2_b( 3) <= not( ca_or_lv1  ( 6) or  ca_or_lv1  ( 7) );
//  u_ca_or_14: ca_or_lv1  ( 7) <= not( d_b  (14) and d_b  (15) );
//  u_ca_or_15: ca_or_lv5  ( 0) <= not( ca_or_lv4_b( 0) and ca_or_lv4_b( 1) );
//  u_ca_or_16: ca_or_lv1  ( 8) <= not( d_b  (16) and d_b  (17) );
//  u_ca_or_17: ca_or_lv2_b( 4) <= not( ca_or_lv1  ( 8) or  ca_or_lv1  ( 9) );
//  u_ca_or_18: ca_or_lv1  ( 9) <= not( d_b  (18) and d_b  (19) );
//  u_ca_or_19: ca_or_lv3  ( 2) <= not( ca_or_lv2_b( 4) and ca_or_lv2_b( 5) );
//  u_ca_or_20: ca_or_lv1  (10) <= not( d_b  (20) and d_b  (21) );
//  u_ca_or_21: ca_or_lv2_b( 5) <= not( ca_or_lv1  (10) or  ca_or_lv1  (11) );
//  u_ca_or_22: ca_or_lv1  (11) <= not( d_b  (22) and d_b  (23) );
//  u_ca_or_23: ca_or_lv4_b( 1) <= not( ca_or_lv3  ( 2) or  ca_or_lv3  ( 3) );
//  u_ca_or_24: ca_or_lv1  (12) <= not( d_b  (24) and d_b  (25) );
//  u_ca_or_25: ca_or_lv2_b( 6) <= not( ca_or_lv1  (12) or  ca_or_lv1  (13) );
//  u_ca_or_26: ca_or_lv1  (13) <= not( d_b  (26) and d_b  (27) );
//  u_ca_or_27: ca_or_lv3  ( 3) <= not( ca_or_lv2_b( 6) and ca_or_lv2_b( 7) );
//  u_ca_or_28: ca_or_lv1  (14) <= not( d_b  (28) and d_b  (29) );
//  u_ca_or_29: ca_or_lv2_b( 7) <= not( ca_or_lv1  (14) or  ca_or_lv1  (15) );
//  u_ca_or_30: ca_or_lv1  (15) <= not( d_b  (30) and d_b  (31) );
//  u_ca_or_32: ca_or_lv1  (16) <= not( d_b  (32) and d_b  (33) );
//  u_ca_or_33: ca_or_lv2_b( 8) <= not( ca_or_lv1  (16) or  ca_or_lv1  (17) );
//  u_ca_or_34: ca_or_lv1  (17) <= not( d_b  (34) and d_b  (35) );
//  u_ca_or_35: ca_or_lv3  ( 4) <= not( ca_or_lv2_b( 8) and ca_or_lv2_b( 9) );
//  u_ca_or_36: ca_or_lv1  (18) <= not( d_b  (36) and d_b  (37) );
//  u_ca_or_37: ca_or_lv2_b( 9) <= not( ca_or_lv1  (18) or  ca_or_lv1  (19) );
//  u_ca_or_38: ca_or_lv1  (19) <= not( d_b  (38) and d_b  (39) );
//  u_ca_or_39: ca_or_lv4_b( 2) <= not( ca_or_lv3  ( 4) or  ca_or_lv3  ( 5) );
//  u_ca_or_40: ca_or_lv1  (20) <= not( d_b  (40) and d_b  (41) );
//  u_ca_or_41: ca_or_lv2_b(10) <= not( ca_or_lv1  (20) or  ca_or_lv1  (21) );
//  u_ca_or_42: ca_or_lv1  (21) <= not( d_b  (42) and d_b  (43) );
//  u_ca_or_43: ca_or_lv3  ( 5) <= not( ca_or_lv2_b(10) and ca_or_lv2_b(11) );
//  u_ca_or_44: ca_or_lv1  (22) <= not( d_b  (44) and d_b  (45) );
//  u_ca_or_45: ca_or_lv2_b(11) <= not( ca_or_lv1  (22) or  ca_or_lv1  (23) );
//  u_ca_or_46: ca_or_lv1  (23) <= not( d_b  (46) and d_b  (47) );
//  u_ca_or_47: ca_or_lv5  ( 1) <= not( ca_or_lv4_b( 2) and ca_or_lv4_b( 3) );
//  u_ca_or_48: ca_or_lv1  (24) <= not( d_b  (48) and d_b  (49) );
//  u_ca_or_49: ca_or_lv2_b(12) <= not( ca_or_lv1  (24) or  ca_or_lv1  (25) );
//  u_ca_or_50: ca_or_lv1  (25) <= not( d_b  (50) and d_b  (51) );
//  u_ca_or_51: ca_or_lv3  ( 6) <= not( ca_or_lv2_b(12) and ca_or_lv2_b(13) );
//  u_ca_or_52: ca_or_lv1  (26) <= not( d_b  (52) and d_b  (53) );
//  u_ca_or_53: ca_or_lv2_b(13) <= not( ca_or_lv1  (26) or  ca_or_lv1  (27) );
//  u_ca_or_54: ca_or_lv1  (27) <= not( d_b  (54) and d_b  (55) );
//  u_ca_or_55: ca_or_lv4_b( 3) <= not( ca_or_lv3  ( 6) or  ca_or_lv3  ( 7) );
//  u_ca_or_56: ca_or_lv1  (28) <= not( d_b  (56) and d_b  (57) );
//  u_ca_or_57: ca_or_lv2_b(14) <= not( ca_or_lv1  (28) or  ca_or_lv1  (29) );
//  u_ca_or_58: ca_or_lv1  (29) <= not( d_b  (58) and d_b  (59) );
//  u_ca_or_59: ca_or_lv3  ( 7) <= not( ca_or_lv2_b(14) and ca_or_lv2_b(15) );
//  u_ca_or_60: ca_or_lv1  (30) <= not( d_b  (60) and d_b  (61) );
//  u_ca_or_61: ca_or_lv2_b(15) <= not( ca_or_lv1  (30) or  ca_or_lv1  (31) );
//  u_ca_or_62: ca_or_lv1  (31) <= not( d_b  (62) and d_b  (63) );
//
// -- --

endmodule
