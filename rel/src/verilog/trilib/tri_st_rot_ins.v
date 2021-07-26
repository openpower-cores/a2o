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

//  Description:  XU Rotate - Insert Component
//
//*****************************************************************************

module tri_st_rot_ins(
   ins_log_fcn,
   ins_cmp_byt,
   ins_sra_wd,
   ins_sra_dw,
   ins_xtd_byte,
   ins_xtd_half,
   ins_xtd_wd,
   ins_prtyw,
   ins_prtyd,
   data0_i,
   data1_i,
   mrg_byp_log,
   res_ins
);
   input [0:3]   ins_log_fcn;		// use pass ra for rlwimi
   // rs, ra/rb
   // 0000 => "0"
   // 0001 => rs AND  rb
   // 0010 => rs AND !rb
   // 0011 => rs
   // 0100 => !rs and RB
   // 0101 =>         RB
   // 0110 => rs xor  RB
   // 0111 => rs or   RB
   // 1000 => rs nor  RB
   // 1001 => rs xnor RB (use for cmp-byt)
   // 1010 =>        !RB
   // 1011 => rs or  !rb
   // 1100 => !rs
   // 1101 => rs nand !rb, !rs or rb
   // 1110 => rs nand rb   ...
   // 1111 => "1"

   input         ins_cmp_byt;
   input         ins_sra_wd;
   input         ins_sra_dw;

   input         ins_xtd_byte;		// use with xtd
   input         ins_xtd_half;		// use with xtd
   input         ins_xtd_wd;		// use with xtd, sra

   input         ins_prtyw;
   input         ins_prtyd;

   input [0:63]  data0_i;		//data input (rs)
   input [0:63]  data1_i;		//data input (ra|rb)
   output [0:63] mrg_byp_log;
   output [0:63] res_ins;		//insert data (also result of logicals)


   wire [0:63]   mrg_byp_log_b;

   wire [0:63]   res_log;
   wire [0:7]    byt_cmp;
   wire [0:7]    byt_cmp_b;
   wire [0:63]   byt_cmp_bus;
   wire [0:63]   sign_xtd_bus;
   wire [0:63]   xtd_byte_bus;
   wire [0:63]   xtd_half_bus;
   wire [0:63]   xtd_wd_bus;
   wire [0:63]   sra_dw_bus;
   wire [0:63]   sra_wd_bus;
   wire [0:63]   res_ins0_b;
   wire [0:63]   res_ins1_b;
   wire [0:63]   res_ins2_b;
   wire [0:63]   res_log0_b;
   wire [0:63]   res_log1_b;
   wire [0:63]   res_log2_b;
   wire [0:63]   res_log3_b;
   wire [0:63]   res_log_o0;
   wire [0:63]   res_log_o1;
   wire [0:63]   res_log_b;
   wire [0:63]   res_log2;
   wire [0:3]    byt0_cmp2_b;
   wire [0:3]    byt1_cmp2_b;
   wire [0:3]    byt2_cmp2_b;
   wire [0:3]    byt3_cmp2_b;
   wire [0:3]    byt4_cmp2_b;
   wire [0:3]    byt5_cmp2_b;
   wire [0:3]    byt6_cmp2_b;
   wire [0:3]    byt7_cmp2_b;

   wire [0:1]    byt0_cmp4;
   wire [0:1]    byt1_cmp4;
   wire [0:1]    byt2_cmp4;
   wire [0:1]    byt3_cmp4;
   wire [0:1]    byt4_cmp4;
   wire [0:1]    byt5_cmp4;
   wire [0:1]    byt6_cmp4;
   wire [0:1]    byt7_cmp4;

   wire [0:63]   sel_cmp_byt;
   wire [0:63]   sel_cmp_byt_b;

   wire [0:63]   data0_b;
   wire [0:63]   data1_b;
   wire [0:63]   data0;
   wire [0:63]   data1;

   wire          prtyhw0;
   wire          prtyhw1;
   wire          prtyhw2;
   wire          prtyhw3;
   wire          prtyw0;
   wire          prtyw1;
   wire          prtyd;
   wire          prty0;
   wire          prty1;

   assign data0_b = (~data0_i);
   assign data1_b = (~data1_i);
   assign data0 = (~data0_b);
   assign data1 = (~data1_b);

   assign prtyhw0 = data0_i[7] ^ data0_i[15];
   assign prtyhw1 = data0_i[23] ^ data0_i[31];
   assign prtyhw2 = data0_i[39] ^ data0_i[47];
   assign prtyhw3 = data0_i[55] ^ data0_i[63];

   assign prtyw0 = prtyhw0 ^ prtyhw1;
   assign prtyw1 = prtyhw2 ^ prtyhw3;

   assign prtyd = prtyw0 ^ prtyw1;

   assign prty1 = (prtyw1 & ins_prtyw) | (prtyd & ins_prtyd);

   assign prty0 = (prtyw0 & ins_prtyw);

   assign res_log2[31] = res_log[31] | prty0;
   assign res_log2[63] = res_log[63] | prty1;
   assign res_log2[0:30] = res_log[0:30];
   assign res_log2[32:62] = res_log[32:62];

   assign res_log0_b[0:63] = (~({64{ins_log_fcn[0]}} & data0_b[0:63] & data1_b[0:63]));
   assign res_log1_b[0:63] = (~({64{ins_log_fcn[1]}} & data0_b[0:63] & data1[0:63]));
   assign res_log2_b[0:63] = (~({64{ins_log_fcn[2]}} & data0[0:63] & data1_b[0:63]));
   assign res_log3_b[0:63] = (~({64{ins_log_fcn[3]}} & data0[0:63] & data1[0:63]));
   assign res_log_o0[0:63] = (~(res_log0_b[0:63] & res_log1_b[0:63]));
   assign res_log_o1[0:63] = (~(res_log2_b[0:63] & res_log3_b[0:63]));
   assign res_log_b[0:63] = (~(res_log_o0[0:63] | res_log_o1[0:63]));
   assign res_log[0:63] = (~(res_log_b[0:63]));

   assign mrg_byp_log_b[0:63] = (~(res_log[0:63]));
   assign mrg_byp_log[0:63] = (~(mrg_byp_log_b[0:63]));

   assign byt0_cmp2_b[0] = (~(res_log[0] & res_log[1]));
   assign byt0_cmp2_b[1] = (~(res_log[2] & res_log[3]));
   assign byt0_cmp2_b[2] = (~(res_log[4] & res_log[5]));
   assign byt0_cmp2_b[3] = (~(res_log[6] & res_log[7]));
   assign byt1_cmp2_b[0] = (~(res_log[8] & res_log[9]));
   assign byt1_cmp2_b[1] = (~(res_log[10] & res_log[11]));
   assign byt1_cmp2_b[2] = (~(res_log[12] & res_log[13]));
   assign byt1_cmp2_b[3] = (~(res_log[14] & res_log[15]));
   assign byt2_cmp2_b[0] = (~(res_log[16] & res_log[17]));
   assign byt2_cmp2_b[1] = (~(res_log[18] & res_log[19]));
   assign byt2_cmp2_b[2] = (~(res_log[20] & res_log[21]));
   assign byt2_cmp2_b[3] = (~(res_log[22] & res_log[23]));
   assign byt3_cmp2_b[0] = (~(res_log[24] & res_log[25]));
   assign byt3_cmp2_b[1] = (~(res_log[26] & res_log[27]));
   assign byt3_cmp2_b[2] = (~(res_log[28] & res_log[29]));
   assign byt3_cmp2_b[3] = (~(res_log[30] & res_log[31]));
   assign byt4_cmp2_b[0] = (~(res_log[32] & res_log[33]));
   assign byt4_cmp2_b[1] = (~(res_log[34] & res_log[35]));
   assign byt4_cmp2_b[2] = (~(res_log[36] & res_log[37]));
   assign byt4_cmp2_b[3] = (~(res_log[38] & res_log[39]));
   assign byt5_cmp2_b[0] = (~(res_log[40] & res_log[41]));
   assign byt5_cmp2_b[1] = (~(res_log[42] & res_log[43]));
   assign byt5_cmp2_b[2] = (~(res_log[44] & res_log[45]));
   assign byt5_cmp2_b[3] = (~(res_log[46] & res_log[47]));
   assign byt6_cmp2_b[0] = (~(res_log[48] & res_log[49]));
   assign byt6_cmp2_b[1] = (~(res_log[50] & res_log[51]));
   assign byt6_cmp2_b[2] = (~(res_log[52] & res_log[53]));
   assign byt6_cmp2_b[3] = (~(res_log[54] & res_log[55]));
   assign byt7_cmp2_b[0] = (~(res_log[56] & res_log[57]));
   assign byt7_cmp2_b[1] = (~(res_log[58] & res_log[59]));
   assign byt7_cmp2_b[2] = (~(res_log[60] & res_log[61]));
   assign byt7_cmp2_b[3] = (~(res_log[62] & res_log[63]));

   assign byt0_cmp4[0] = (~(byt0_cmp2_b[0] | byt0_cmp2_b[1]));
   assign byt0_cmp4[1] = (~(byt0_cmp2_b[2] | byt0_cmp2_b[3]));
   assign byt1_cmp4[0] = (~(byt1_cmp2_b[0] | byt1_cmp2_b[1]));
   assign byt1_cmp4[1] = (~(byt1_cmp2_b[2] | byt1_cmp2_b[3]));
   assign byt2_cmp4[0] = (~(byt2_cmp2_b[0] | byt2_cmp2_b[1]));
   assign byt2_cmp4[1] = (~(byt2_cmp2_b[2] | byt2_cmp2_b[3]));
   assign byt3_cmp4[0] = (~(byt3_cmp2_b[0] | byt3_cmp2_b[1]));
   assign byt3_cmp4[1] = (~(byt3_cmp2_b[2] | byt3_cmp2_b[3]));
   assign byt4_cmp4[0] = (~(byt4_cmp2_b[0] | byt4_cmp2_b[1]));
   assign byt4_cmp4[1] = (~(byt4_cmp2_b[2] | byt4_cmp2_b[3]));
   assign byt5_cmp4[0] = (~(byt5_cmp2_b[0] | byt5_cmp2_b[1]));
   assign byt5_cmp4[1] = (~(byt5_cmp2_b[2] | byt5_cmp2_b[3]));
   assign byt6_cmp4[0] = (~(byt6_cmp2_b[0] | byt6_cmp2_b[1]));
   assign byt6_cmp4[1] = (~(byt6_cmp2_b[2] | byt6_cmp2_b[3]));
   assign byt7_cmp4[0] = (~(byt7_cmp2_b[0] | byt7_cmp2_b[1]));
   assign byt7_cmp4[1] = (~(byt7_cmp2_b[2] | byt7_cmp2_b[3]));

   assign byt_cmp_b[0] = (~(byt0_cmp4[0] & byt0_cmp4[1]));
   assign byt_cmp_b[1] = (~(byt1_cmp4[0] & byt1_cmp4[1]));
   assign byt_cmp_b[2] = (~(byt2_cmp4[0] & byt2_cmp4[1]));
   assign byt_cmp_b[3] = (~(byt3_cmp4[0] & byt3_cmp4[1]));
   assign byt_cmp_b[4] = (~(byt4_cmp4[0] & byt4_cmp4[1]));
   assign byt_cmp_b[5] = (~(byt5_cmp4[0] & byt5_cmp4[1]));
   assign byt_cmp_b[6] = (~(byt6_cmp4[0] & byt6_cmp4[1]));
   assign byt_cmp_b[7] = (~(byt7_cmp4[0] & byt7_cmp4[1]));

   assign byt_cmp[0] = (~(byt_cmp_b[0]));
   assign byt_cmp[1] = (~(byt_cmp_b[1]));
   assign byt_cmp[2] = (~(byt_cmp_b[2]));
   assign byt_cmp[3] = (~(byt_cmp_b[3]));
   assign byt_cmp[4] = (~(byt_cmp_b[4]));
   assign byt_cmp[5] = (~(byt_cmp_b[5]));
   assign byt_cmp[6] = (~(byt_cmp_b[6]));
   assign byt_cmp[7] = (~(byt_cmp_b[7]));

   assign byt_cmp_bus[0:7]   = {8{byt_cmp[0]}};
   assign byt_cmp_bus[8:15]  = {8{byt_cmp[1]}};
   assign byt_cmp_bus[16:23] = {8{byt_cmp[2]}};
   assign byt_cmp_bus[24:31] = {8{byt_cmp[3]}};
   assign byt_cmp_bus[32:39] = {8{byt_cmp[4]}};
   assign byt_cmp_bus[40:47] = {8{byt_cmp[5]}};
   assign byt_cmp_bus[48:55] = {8{byt_cmp[6]}};
   assign byt_cmp_bus[56:63] = {8{byt_cmp[7]}};

   assign xtd_byte_bus[0:63] = {{57{data0[56]}}, data0[57:63]};
   assign xtd_half_bus[0:63] = {{49{data0[48]}}, data0[49:63]};

   assign xtd_wd_bus[0:63] = {{33{data0[32]}}, data0[33:63]};
   assign sra_wd_bus[0:63] = {64{data0[32]}};		// all the bits for sra
   assign sra_dw_bus[0:63] = {64{data0[0]}};		// all the bits for sra

   assign sign_xtd_bus[0:63] = ({64{ins_xtd_byte}} & xtd_byte_bus[0:63]) |
                               ({64{ins_xtd_half}} & xtd_half_bus[0:63]) |
                               ({64{ins_xtd_wd}}   & xtd_wd_bus[0:63]) |
                               ({64{ins_sra_wd}}   & sra_wd_bus[0:63]) |
                               ({64{ins_sra_dw}}   & sra_dw_bus[0:63]);

   assign sel_cmp_byt   =  {64{ins_cmp_byt}};
   assign sel_cmp_byt_b = ~{64{ins_cmp_byt}};

   assign res_ins0_b[0:63] = (~(sel_cmp_byt & byt_cmp_bus[0:63]));
   assign res_ins1_b[0:63] = (~(sel_cmp_byt_b & res_log2[0:63]));
   assign res_ins2_b[0:63] = (~(sign_xtd_bus[0:63]));

   assign res_ins[0:63] = (~(res_ins0_b[0:63] & res_ins1_b[0:63] & res_ins2_b[0:63]));		//output--



endmodule
