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

`timescale 1 ns / 1 ns

   `include "tri_a2o.vh"

module fu_alg_add(
   vdd,
   gnd,
   f_byp_alg_ex2_b_expo,
   f_byp_alg_ex2_a_expo,
   f_byp_alg_ex2_c_expo,
   ex2_sel_special_b,
   ex2_bsha_6_o,
   ex2_bsha_7_o,
   ex2_bsha_8_o,
   ex2_bsha_9_o,
   ex2_bsha_neg_o,
   ex2_sh_ovf,
   ex2_sh_unf_x,
   ex2_lvl1_shdcd000_b,
   ex2_lvl1_shdcd001_b,
   ex2_lvl1_shdcd002_b,
   ex2_lvl1_shdcd003_b,
   ex2_lvl2_shdcd000,
   ex2_lvl2_shdcd004,
   ex2_lvl2_shdcd008,
   ex2_lvl2_shdcd012,
   ex2_lvl3_shdcd000,
   ex2_lvl3_shdcd016,
   ex2_lvl3_shdcd032,
   ex2_lvl3_shdcd048,
   ex2_lvl3_shdcd064,
   ex2_lvl3_shdcd080,
   ex2_lvl3_shdcd096,
   ex2_lvl3_shdcd112,
   ex2_lvl3_shdcd128,
   ex2_lvl3_shdcd144,
   ex2_lvl3_shdcd160,
   ex2_lvl3_shdcd176,
   ex2_lvl3_shdcd192,
   ex2_lvl3_shdcd208,
   ex2_lvl3_shdcd224,
   ex2_lvl3_shdcd240
);
   inout          vdd;
   inout          gnd;
   input [1:13] f_byp_alg_ex2_b_expo;
   input [1:13] f_byp_alg_ex2_a_expo;
   input [1:13] f_byp_alg_ex2_c_expo;

   input        ex2_sel_special_b;

   output       ex2_bsha_6_o;
   output       ex2_bsha_7_o;
   output       ex2_bsha_8_o;
   output       ex2_bsha_9_o;

   output       ex2_bsha_neg_o;
   output       ex2_sh_ovf;
   output       ex2_sh_unf_x;

   output       ex2_lvl1_shdcd000_b;
   output       ex2_lvl1_shdcd001_b;
   output       ex2_lvl1_shdcd002_b;
   output       ex2_lvl1_shdcd003_b;

   output       ex2_lvl2_shdcd000;
   output       ex2_lvl2_shdcd004;
   output       ex2_lvl2_shdcd008;
   output       ex2_lvl2_shdcd012;

   output       ex2_lvl3_shdcd000;		// 0000  +000
   output       ex2_lvl3_shdcd016;		// 0001  +016
   output       ex2_lvl3_shdcd032;		// 0010  +032
   output       ex2_lvl3_shdcd048;		// 0011  +048
   output       ex2_lvl3_shdcd064;		// 0100  +064
   output       ex2_lvl3_shdcd080;		// 0101  +080
   output       ex2_lvl3_shdcd096;		// 0110  +096
   output       ex2_lvl3_shdcd112;		// 0111  +112
   output       ex2_lvl3_shdcd128;		// 1000  +128
   output       ex2_lvl3_shdcd144;		// 1001  +144
   output       ex2_lvl3_shdcd160;		// 1010  +160
   output       ex2_lvl3_shdcd176;		// 1011
   output       ex2_lvl3_shdcd192;		// 1100  -064
   output       ex2_lvl3_shdcd208;		// 1101  -048
   output       ex2_lvl3_shdcd224;		// 1110  -032
   output       ex2_lvl3_shdcd240;		// 1111  -016
   //-----------------------------------------------------------------

   // ENTITY

   parameter    tiup = 1'b1;
   parameter    tidn = 1'b0;
   wire [2:14]  ex2_bsha_sim_c;
   wire [1:13]  ex2_bsha_sim_p;
   wire [2:13]  ex2_bsha_sim_g;
   wire [1:13]  ex2_bsha_sim;

   wire [1:13]  ex2_b_expo_b;
   wire [2:13]  ex2_a_expo_b;
   wire [2:13]  ex2_c_expo_b;
   wire         ex2_bsha_neg;
   wire         ex2_sh_ovf_b;
   wire [1:13]  ex2_alg_sx;

   (* analysis_not_referenced="<0:0>TRUE" *)
   wire [0:12]  ex2_alg_cx;
   wire [1:12]  ex2_alg_add_p;
   wire [2:12]  ex2_alg_add_g_b;
   wire [2:11]  ex2_alg_add_t_b;

   wire         ex2_bsha_6_b;
   wire         ex2_bsha_7_b;
   wire         ex2_bsha_8_b;
   wire         ex2_bsha_9_b;
   wire         ex2_67_dcd00_b;
   wire         ex2_67_dcd01_b;
   wire         ex2_67_dcd10_b;
   wire         ex2_67_dcd11_b;
   wire         ex2_89_dcd00_b;
   wire         ex2_89_dcd01_b;
   wire         ex2_89_dcd10_b;
   wire         ex2_89_dcd11_b;

   wire         ex2_lv2_0pg0_b;
   wire         ex2_lv2_0pg1_b;
   wire         ex2_lv2_0pk0_b;
   wire         ex2_lv2_0pk1_b;
   wire         ex2_lv2_0pp0_b;
   wire         ex2_lv2_0pp1_b;
   wire         ex2_lv2_1pg0_b;
   wire         ex2_lv2_1pg1_b;
   wire         ex2_lv2_1pk0_b;
   wire         ex2_lv2_1pk1_b;
   wire         ex2_lv2_1pp0_b;
   wire         ex2_lv2_1pp1_b;
   wire         ex2_lv2_shdcd000;
   wire         ex2_lv2_shdcd004;
   wire         ex2_lv2_shdcd008;
   wire         ex2_lv2_shdcd012;
   wire         ex2_lvl2_shdcd000_b;
   wire         ex2_lvl2_shdcd004_b;
   wire         ex2_lvl2_shdcd008_b;
   wire         ex2_lvl2_shdcd012_b;

   wire [7:10]  ex2_alg_add_c_b;
   wire         ex2_g02_12;
   wire         ex2_g02_12_b;
   wire         ex2_bsha_13_b;
   wire         ex2_bsha_13;
   wire         ex2_bsha_12_b;
   wire         ex2_bsha_12;
   wire         ex2_lv2_ci11n_en_b;
   wire         ex2_lv2_ci11p_en_b;
   wire         ex2_lv2_ci11n_en;
   wire         ex2_lv2_ci11p_en;
   wire         ex2_g02_10;
   wire         ex2_t02_10;
   wire         ex2_g04_10_b;
   wire         ex2_lv2_g11_x;
   wire         ex2_lv2_g11_b;
   wire         ex2_lv2_g11;
   wire         ex2_lv2_k11_b;
   wire         ex2_lv2_k11;
   wire         ex2_lv2_p11_b;
   wire         ex2_lv2_p11;
   wire         ex2_lv2_p10_b;
   wire         ex2_lv2_p10;
   wire         ex2_g04_10;
   wire         ex2_g02_6;
   wire         ex2_g02_7;
   wire         ex2_g02_8;
   wire         ex2_g02_9;
   wire         ex2_t02_6;
   wire         ex2_t02_7;
   wire         ex2_t02_8;
   wire         ex2_t02_9;
   wire         ex2_g04_6_b;
   wire         ex2_g04_7_b;
   wire         ex2_g04_8_b;
   wire         ex2_g04_9_b;
   wire         ex2_t04_6_b;
   wire         ex2_t04_7_b;
   wire         ex2_t04_8_b;
   wire         ex2_t04_9_b;
   wire         ex2_g08_6;
   wire         ex2_g04_7;
   wire         ex2_g04_8;
   wire         ex2_g04_9;
   wire         ex2_t04_7;
   wire         ex2_t04_8;
   wire         ex2_t04_9;
   wire         ex2_bsha_6;
   wire         ex2_bsha_7;
   wire         ex2_bsha_8;
   wire         ex2_bsha_9;
   wire         ex2_g02_4;
   wire         ex2_g02_2;
   wire         ex2_t02_4;
   wire         ex2_t02_2;
   wire         ex2_g04_2_b;
   wire         ex2_t04_2_b;
   wire         ex2_ones_2t3_b;
   wire         ex2_ones_4t5_b;
   wire         ex2_ones_2t5;
   wire         ex2_ones_2t5_b;
   wire         ex2_zero_2_b;
   wire         ex2_zero_3_b;
   wire         ex2_zero_4_b;
   wire         ex2_zero_5;
   wire         ex2_zero_5_b;
   wire         ex2_zero_2t3;
   wire         ex2_zero_4t5;
   wire         ex2_zero_2t5_b;
   wire         pos_if_pco6;
   wire         pos_if_nco6;
   wire         pos_if_pco6_b;
   wire         pos_if_nco6_b;
   wire         unf_if_nco6_b;
   wire         unf_if_pco6_b;
   wire         ex2_g08_6_b;
   wire         ex2_bsha_pos;
   wire         ex2_bsha_6_i;
   wire         ex2_bsha_7_i;
   wire         ex2_bsha_8_i;
   wire         ex2_bsha_9_i;
   wire [1:13]  ex2_ack_s;
   wire [1:12]  ex2_ack_c;



   //==##############################################################
   //# map block attributes
   //==##############################################################

   //-----------------------------------------------------
   // FOR simulation only : will not generate any logic
   //-----------------------------------------------------

   assign ex2_bsha_sim_p[1:12] = ex2_alg_sx[1:12] ^ ex2_alg_cx[1:12];
   assign ex2_bsha_sim_p[13] = ex2_alg_sx[13];
   assign ex2_bsha_sim_g[2:12] = ex2_alg_sx[2:12] & ex2_alg_cx[2:12];
   assign ex2_bsha_sim_g[13] = tidn;
   assign ex2_bsha_sim[1:13] = ex2_bsha_sim_p[1:13] ^ ex2_bsha_sim_c[2:14];

   assign ex2_bsha_sim_c[14] = tidn;
   assign ex2_bsha_sim_c[13] = ex2_bsha_sim_g[13] | (ex2_bsha_sim_p[13] & ex2_bsha_sim_c[14]);
   assign ex2_bsha_sim_c[12] = ex2_bsha_sim_g[12] | (ex2_bsha_sim_p[12] & ex2_bsha_sim_c[13]);
   assign ex2_bsha_sim_c[11] = ex2_bsha_sim_g[11] | (ex2_bsha_sim_p[11] & ex2_bsha_sim_c[12]);
   assign ex2_bsha_sim_c[10] = ex2_bsha_sim_g[10] | (ex2_bsha_sim_p[10] & ex2_bsha_sim_c[11]);
   assign ex2_bsha_sim_c[9] = ex2_bsha_sim_g[9] | (ex2_bsha_sim_p[9] & ex2_bsha_sim_c[10]);
   assign ex2_bsha_sim_c[8] = ex2_bsha_sim_g[8] | (ex2_bsha_sim_p[8] & ex2_bsha_sim_c[9]);
   assign ex2_bsha_sim_c[7] = ex2_bsha_sim_g[7] | (ex2_bsha_sim_p[7] & ex2_bsha_sim_c[8]);
   assign ex2_bsha_sim_c[6] = ex2_bsha_sim_g[6] | (ex2_bsha_sim_p[6] & ex2_bsha_sim_c[7]);
   assign ex2_bsha_sim_c[5] = ex2_bsha_sim_g[5] | (ex2_bsha_sim_p[5] & ex2_bsha_sim_c[6]);
   assign ex2_bsha_sim_c[4] = ex2_bsha_sim_g[4] | (ex2_bsha_sim_p[4] & ex2_bsha_sim_c[5]);
   assign ex2_bsha_sim_c[3] = ex2_bsha_sim_g[3] | (ex2_bsha_sim_p[3] & ex2_bsha_sim_c[4]);
   assign ex2_bsha_sim_c[2] = ex2_bsha_sim_g[2] | (ex2_bsha_sim_p[2] & ex2_bsha_sim_c[3]);

   //==##############################################################
   //# ex2 logic
   //==##############################################################
   //==--------------------------------------
   //== timing ? long-cut to make sha have correct meaning
   //==--------------------------------------
   // for MADD operations SHA = (Ea+Ec+!Eb) + 1 -bias + 56
   //                           (Ea+Ec+!Eb) + 57 +!bias + 1
   //                           (Ea+Ec+!Eb) + 58 +!bias
   // 0_0011_1111_1111  bias = 1023
   // 1_1100_0000_0000 !bias
   //          11_1010 58
   // -----------------------
   // 1_1100_0011_1010  ( !bias + 58 )
   //
   // leading bit [1] is a sign bit, but the compressor creates bit 0.
   // 13 bits should be enough to hold the entire result, therefore throw away bit 0.

   assign ex2_a_expo_b[2:13] = (~f_byp_alg_ex2_a_expo[2:13]);
   assign ex2_c_expo_b[2:13] = (~f_byp_alg_ex2_c_expo[2:13]);
   assign ex2_b_expo_b[1:13] = (~f_byp_alg_ex2_b_expo[1:13]);

   assign ex2_ack_s[1] = (~(f_byp_alg_ex2_a_expo[1] ^ f_byp_alg_ex2_c_expo[1]));		//K[ 1]==1
   assign ex2_ack_s[2] = (~(f_byp_alg_ex2_a_expo[2] ^ f_byp_alg_ex2_c_expo[2]));		//K[ 2]==1
   assign ex2_ack_s[3] = (~(f_byp_alg_ex2_a_expo[3] ^ f_byp_alg_ex2_c_expo[3]));		//K[ 3]==1
   assign ex2_ack_s[4] = (f_byp_alg_ex2_a_expo[4] ^ f_byp_alg_ex2_c_expo[4]);		//K[ 4]==0
   assign ex2_ack_s[5] = (f_byp_alg_ex2_a_expo[5] ^ f_byp_alg_ex2_c_expo[5]);		//K[ 5]==0
   assign ex2_ack_s[6] = (f_byp_alg_ex2_a_expo[6] ^ f_byp_alg_ex2_c_expo[6]);		//K[ 6]==0
   assign ex2_ack_s[7] = (f_byp_alg_ex2_a_expo[7] ^ f_byp_alg_ex2_c_expo[7]);		//K[ 7]==0
   assign ex2_ack_s[8] = (~(f_byp_alg_ex2_a_expo[8] ^ f_byp_alg_ex2_c_expo[8]));		//K[ 8]==1
   assign ex2_ack_s[9] = (~(f_byp_alg_ex2_a_expo[9] ^ f_byp_alg_ex2_c_expo[9]));		//K[ 9]==1  1
   assign ex2_ack_s[10] = (~(f_byp_alg_ex2_a_expo[10] ^ f_byp_alg_ex2_c_expo[10]));		//K[10]==1  1
   assign ex2_ack_s[11] = (f_byp_alg_ex2_a_expo[11] ^ f_byp_alg_ex2_c_expo[11]);		//K[11]==0
   assign ex2_ack_s[12] = (~(f_byp_alg_ex2_a_expo[12] ^ f_byp_alg_ex2_c_expo[12]));		//K[12]==1
   assign ex2_ack_s[13] = (f_byp_alg_ex2_a_expo[13] ^ f_byp_alg_ex2_c_expo[13]);		//K[13]==0

   // cx00: ex2_ack_c( 0) <= not( ex2_a_expo_b( 1) and  ex2_c_expo_b( 1) ); --K[ 1]==1 +or
   assign ex2_ack_c[1] = (~(ex2_a_expo_b[2] & ex2_c_expo_b[2]));		//K[ 2]==1 +or
   assign ex2_ack_c[2] = (~(ex2_a_expo_b[3] & ex2_c_expo_b[3]));		//K[ 3]==1 +or
   assign ex2_ack_c[3] = (~(ex2_a_expo_b[4] | ex2_c_expo_b[4]));		//K[ 4]==0 +and
   assign ex2_ack_c[4] = (~(ex2_a_expo_b[5] | ex2_c_expo_b[5]));		//K[ 5]==0 +and
   assign ex2_ack_c[5] = (~(ex2_a_expo_b[6] | ex2_c_expo_b[6]));		//K[ 6]==0 +and
   assign ex2_ack_c[6] = (~(ex2_a_expo_b[7] | ex2_c_expo_b[7]));		//K[ 7]==0 +and
   assign ex2_ack_c[7] = (~(ex2_a_expo_b[8] & ex2_c_expo_b[8]));		//K[ 8]==1 +or
   assign ex2_ack_c[8] = (~(ex2_a_expo_b[9] & ex2_c_expo_b[9]));		//K[ 9]==1 +or
   assign ex2_ack_c[9] = (~(ex2_a_expo_b[10] & ex2_c_expo_b[10]));		//K[10]==1 +or
   assign ex2_ack_c[10] = (~(ex2_a_expo_b[11] | ex2_c_expo_b[11]));		//K[11]==0 +and
   assign ex2_ack_c[11] = (~(ex2_a_expo_b[12] & ex2_c_expo_b[12]));		//K[12]==1 +or
   assign ex2_ack_c[12] = (~(ex2_a_expo_b[13] | ex2_c_expo_b[13]));		//K[13]==0

   		// fu_csa32s_h2
   tri_csa32 sha32_01( // #(.btr("MLT32_X1_A12TH")) c_prism_csa32
      .vd(vdd),
      .gd(gnd),
      .a(ex2_b_expo_b[1]),		//i--
      .b(ex2_ack_s[1]),		//i--
      .c(ex2_ack_c[1]),		//i--
      .sum(ex2_alg_sx[1]),		//o--
      .car(ex2_alg_cx[0])		//o--
   );

   tri_csa32 sha32_02( // #(.btr("MLT32_X1_A12TH")) c_prism_csa32
      .vd(vdd),
      .gd(gnd),
      .a(ex2_b_expo_b[2]),		//i--
      .b(ex2_ack_s[2]),		//i--
      .c(ex2_ack_c[2]),		//i--
      .sum(ex2_alg_sx[2]),		//o--
      .car(ex2_alg_cx[1])		//o--
   );

   tri_csa32 sha32_03( // #(.btr("MLT32_X1_A12TH")) c_prism_csa32
      .vd(vdd),
      .gd(gnd),
      .a(ex2_b_expo_b[3]),		//i--
      .b(ex2_ack_s[3]),		//i--
      .c(ex2_ack_c[3]),		//i--
      .sum(ex2_alg_sx[3]),		//o--
      .car(ex2_alg_cx[2])		//o--
   );

   tri_csa32 sha32_04( // #(.btr("MLT32_X1_A12TH")) c_prism_csa32
      .vd(vdd),
      .gd(gnd),
      .a(ex2_b_expo_b[4]),		//i--
      .b(ex2_ack_s[4]),		//i--
      .c(ex2_ack_c[4]),		//i--
      .sum(ex2_alg_sx[4]),		//o--
      .car(ex2_alg_cx[3])		//o--
   );

   tri_csa32 sha32_05( // #(.btr("MLT32_X1_A12TH")) c_prism_csa32
      .vd(vdd),
      .gd(gnd),
      .a(ex2_b_expo_b[5]),		//i--
      .b(ex2_ack_s[5]),		//i--
      .c(ex2_ack_c[5]),		//i--
      .sum(ex2_alg_sx[5]),		//o--
      .car(ex2_alg_cx[4])		//o--
   );

   tri_csa32 sha32_06( // #(.btr("MLT32_X1_A12TH")) c_prism_csa32
      .vd(vdd),
      .gd(gnd),
      .a(ex2_b_expo_b[6]),		//i--
      .b(ex2_ack_s[6]),		//i--
      .c(ex2_ack_c[6]),		//i--
      .sum(ex2_alg_sx[6]),		//o--
      .car(ex2_alg_cx[5])		//o--
   );

   tri_csa32 sha32_07( // #(.btr("MLT32_X1_A12TH")) c_prism_csa32
      .vd(vdd),
      .gd(gnd),
      .a(ex2_b_expo_b[7]),		//i--
      .b(ex2_ack_s[7]),		//i--
      .c(ex2_ack_c[7]),		//i--
      .sum(ex2_alg_sx[7]),		//o--
      .car(ex2_alg_cx[6])		//o--
   );

   tri_csa32 sha32_08( // #(.btr("MLT32_X1_A12TH")) c_prism_csa32
      .vd(vdd),
      .gd(gnd),
      .a(ex2_b_expo_b[8]),		//i--
      .b(ex2_ack_s[8]),		//i--
      .c(ex2_ack_c[8]),		//i--
      .sum(ex2_alg_sx[8]),		//o--
      .car(ex2_alg_cx[7])		//o--
   );

   tri_csa32 sha32_09( // #(.btr("MLT32_X1_A12TH")) c_prism_csa32
      .vd(vdd),
      .gd(gnd),
      .a(ex2_b_expo_b[9]),		//i--
      .b(ex2_ack_s[9]),		//i--
      .c(ex2_ack_c[9]),		//i--
      .sum(ex2_alg_sx[9]),		//o--
      .car(ex2_alg_cx[8])		//o--
   );

   tri_csa32 sha32_10( // #(.btr("MLT32_X1_A12TH")) c_prism_csa32
      .vd(vdd),
      .gd(gnd),
      .a(ex2_b_expo_b[10]),		//i--
      .b(ex2_ack_s[10]),		//i--
      .c(ex2_ack_c[10]),		//i--
      .sum(ex2_alg_sx[10]),		//o--
      .car(ex2_alg_cx[9])		//o--
   );

   tri_csa32 sha32_11( // #(.btr("MLT32_X1_A12TH")) c_prism_csa32
      .vd(vdd),
      .gd(gnd),
      .a(ex2_b_expo_b[11]),		//i--
      .b(ex2_ack_s[11]),		//i--
      .c(ex2_ack_c[11]),		//i--
      .sum(ex2_alg_sx[11]),		//o--
      .car(ex2_alg_cx[10])		//o--
   );

   tri_csa32 sha32_12( // #(.btr("MLT32_X1_A12TH")) c_prism_csa32
      .vd(vdd),
      .gd(gnd),
      .a(ex2_b_expo_b[12]),		//i--
      .b(ex2_ack_s[12]),		//i--
      .c(ex2_ack_c[12]),		//i--
      .sum(ex2_alg_sx[12]),		//o--
      .car(ex2_alg_cx[11])		//o--
   );

   tri_csa32 sha32_13( // #(.btr("MLT32_X1_A12TH")) c_prism_csa32
      .vd(vdd),
      .gd(gnd),
      .a(ex2_b_expo_b[13]),		//i--
      .b(ex2_ack_s[13]),		//i--
      .c(tidn),		//i--
      .sum(ex2_alg_sx[13]),		//o--
      .car(ex2_alg_cx[12])		//o--
   );

   // now finish the add (for sha==0 means shift 0)

   assign ex2_alg_add_p[1] = ex2_alg_sx[1] ^ ex2_alg_cx[1];
   assign ex2_alg_add_p[2] = ex2_alg_sx[2] ^ ex2_alg_cx[2];
   assign ex2_alg_add_p[3] = ex2_alg_sx[3] ^ ex2_alg_cx[3];
   assign ex2_alg_add_p[4] = ex2_alg_sx[4] ^ ex2_alg_cx[4];
   assign ex2_alg_add_p[5] = ex2_alg_sx[5] ^ ex2_alg_cx[5];
   assign ex2_alg_add_p[6] = ex2_alg_sx[6] ^ ex2_alg_cx[6];
   assign ex2_alg_add_p[7] = ex2_alg_sx[7] ^ ex2_alg_cx[7];
   assign ex2_alg_add_p[8] = ex2_alg_sx[8] ^ ex2_alg_cx[8];
   assign ex2_alg_add_p[9] = ex2_alg_sx[9] ^ ex2_alg_cx[9];
   assign ex2_alg_add_p[10] = ex2_alg_sx[10] ^ ex2_alg_cx[10];
   assign ex2_alg_add_p[11] = ex2_alg_sx[11] ^ ex2_alg_cx[11];
   assign ex2_alg_add_p[12] = ex2_alg_sx[12] ^ ex2_alg_cx[12];
   //     ex2_alg_add_p(13)   <= ex2_alg_sx(13);

   //g1_01:  ex2_alg_add_g_b( 1) <= not( ex2_alg_sx( 1) and ex2_alg_cx( 1) );
   assign ex2_alg_add_g_b[2] = (~(ex2_alg_sx[2] & ex2_alg_cx[2]));
   assign ex2_alg_add_g_b[3] = (~(ex2_alg_sx[3] & ex2_alg_cx[3]));
   assign ex2_alg_add_g_b[4] = (~(ex2_alg_sx[4] & ex2_alg_cx[4]));
   assign ex2_alg_add_g_b[5] = (~(ex2_alg_sx[5] & ex2_alg_cx[5]));
   assign ex2_alg_add_g_b[6] = (~(ex2_alg_sx[6] & ex2_alg_cx[6]));
   assign ex2_alg_add_g_b[7] = (~(ex2_alg_sx[7] & ex2_alg_cx[7]));
   assign ex2_alg_add_g_b[8] = (~(ex2_alg_sx[8] & ex2_alg_cx[8]));
   assign ex2_alg_add_g_b[9] = (~(ex2_alg_sx[9] & ex2_alg_cx[9]));
   assign ex2_alg_add_g_b[10] = (~(ex2_alg_sx[10] & ex2_alg_cx[10]));
   assign ex2_alg_add_g_b[11] = (~(ex2_alg_sx[11] & ex2_alg_cx[11]));
   assign ex2_alg_add_g_b[12] = (~(ex2_alg_sx[12] & ex2_alg_cx[12]));

   //t1_01:  ex2_alg_add_t_b( 1) <= not( ex2_alg_sx( 1) or  ex2_alg_cx( 1) );
   assign ex2_alg_add_t_b[2] = (~(ex2_alg_sx[2] | ex2_alg_cx[2]));
   assign ex2_alg_add_t_b[3] = (~(ex2_alg_sx[3] | ex2_alg_cx[3]));
   assign ex2_alg_add_t_b[4] = (~(ex2_alg_sx[4] | ex2_alg_cx[4]));
   assign ex2_alg_add_t_b[5] = (~(ex2_alg_sx[5] | ex2_alg_cx[5]));
   assign ex2_alg_add_t_b[6] = (~(ex2_alg_sx[6] | ex2_alg_cx[6]));
   assign ex2_alg_add_t_b[7] = (~(ex2_alg_sx[7] | ex2_alg_cx[7]));
   assign ex2_alg_add_t_b[8] = (~(ex2_alg_sx[8] | ex2_alg_cx[8]));
   assign ex2_alg_add_t_b[9] = (~(ex2_alg_sx[9] | ex2_alg_cx[9]));
   assign ex2_alg_add_t_b[10] = (~(ex2_alg_sx[10] | ex2_alg_cx[10]));
   assign ex2_alg_add_t_b[11] = (~(ex2_alg_sx[11] | ex2_alg_cx[11]));

   //---------------------------------------------------------------------
   // 12:13 are a decode group  (12,13) are known before adder starts )
   //---------------------------------------------------------------------

   assign ex2_g02_12 = (~ex2_alg_add_g_b[12]);		// main carry chain
   assign ex2_g02_12_b = (~ex2_g02_12);		// main carry chain

   assign ex2_bsha_13_b = (~ex2_alg_sx[13]);		// direct from compressor
   assign ex2_bsha_13 = (~ex2_bsha_13_b);		// to decoder  0/1/2/3
   assign ex2_bsha_12_b = (~ex2_alg_add_p[12]);
   assign ex2_bsha_12 = (~ex2_bsha_12_b);		// to decoder 0/1/2/3

   assign ex2_lv2_ci11n_en_b = (~(ex2_sel_special_b & ex2_g02_12_b));
   assign ex2_lv2_ci11p_en_b = (~(ex2_sel_special_b & ex2_g02_12));
   assign ex2_lv2_ci11n_en = (~(ex2_lv2_ci11n_en_b));		// to decoder 0/4/8/12
   assign ex2_lv2_ci11p_en = (~(ex2_lv2_ci11p_en_b));		// to decoder 0/4/8/12

   //---------------------------------------------------------------------
   // 10:11 are a decode group, do not compute adder result (send signal direct to decode)
   //---------------------------------------------------------------------

   assign ex2_g02_10 = (~(ex2_alg_add_g_b[10] & (ex2_alg_add_t_b[10] | ex2_alg_add_g_b[11])));		//main carry chain
   assign ex2_t02_10 = (~(ex2_alg_add_t_b[10] | ex2_alg_add_t_b[11]));		//main carry chain
   assign ex2_g04_10_b = (~(ex2_g02_10 | (ex2_t02_10 & ex2_g02_12)));		//main carry chain

   assign ex2_lv2_g11_x = (~(ex2_alg_add_g_b[11]));
   assign ex2_lv2_g11_b = (~(ex2_lv2_g11_x));
   assign ex2_lv2_g11 = (~(ex2_lv2_g11_b));		// to decoder 0/4/8/12
   assign ex2_lv2_k11_b = (~(ex2_alg_add_t_b[11]));
   assign ex2_lv2_k11 = (~(ex2_lv2_k11_b));		// to decoder 0/4/8/12
   assign ex2_lv2_p11_b = (~(ex2_alg_add_p[11]));
   assign ex2_lv2_p11 = (~(ex2_lv2_p11_b));		// to decoder 0/4/8/12
   assign ex2_lv2_p10_b = (~(ex2_alg_add_p[10]));		// to decoder 0/4/8/12
   assign ex2_lv2_p10 = (~(ex2_lv2_p10_b));		// to decoder 0/4/8/12

   //---------------------------------------------------------------------
   // 6:9 are a decode group, not used until next cycle: (get add result then decode)
   //----------------------------------------------------------------------

   assign ex2_g04_10 = (~ex2_g04_10_b);		// use this buffered of version to finish the local carry chain

   assign ex2_g02_6 = (~(ex2_alg_add_g_b[6] & (ex2_alg_add_t_b[6] | ex2_alg_add_g_b[7])));
   assign ex2_g02_7 = (~(ex2_alg_add_g_b[7] & (ex2_alg_add_t_b[7] | ex2_alg_add_g_b[8])));
   assign ex2_g02_8 = (~(ex2_alg_add_g_b[8] & (ex2_alg_add_t_b[8] | ex2_alg_add_g_b[9])));
   assign ex2_g02_9 = (~(ex2_alg_add_g_b[9]));
   assign ex2_t02_6 = (~(ex2_alg_add_t_b[6] | ex2_alg_add_t_b[7]));
   assign ex2_t02_7 = (~(ex2_alg_add_t_b[7] | ex2_alg_add_t_b[8]));
   assign ex2_t02_8 = (~(ex2_alg_add_t_b[8] | ex2_alg_add_t_b[9]));
   assign ex2_t02_9 = (~(ex2_alg_add_t_b[9]));

   assign ex2_g04_6_b = (~(ex2_g02_6 | (ex2_t02_6 & ex2_g02_8)));
   assign ex2_g04_7_b = (~(ex2_g02_7 | (ex2_t02_7 & ex2_g02_9)));
   assign ex2_g04_8_b = (~(ex2_g02_8));
   assign ex2_g04_9_b = (~(ex2_g02_9));
   assign ex2_t04_6_b = (~(ex2_t02_6 & ex2_t02_8));
   assign ex2_t04_7_b = (~(ex2_t02_7 & ex2_t02_9));
   assign ex2_t04_8_b = (~(ex2_t02_8));
   assign ex2_t04_9_b = (~(ex2_t02_9));

   assign ex2_g08_6 = (~(ex2_g04_6_b & (ex2_t04_6_b | ex2_g04_10_b)));		//main carry chain
   assign ex2_g04_7 = (~(ex2_g04_7_b));
   assign ex2_g04_8 = (~(ex2_g04_8_b));
   assign ex2_g04_9 = (~(ex2_g04_9_b));
   assign ex2_t04_7 = (~(ex2_t04_7_b));
   assign ex2_t04_8 = (~(ex2_t04_8_b));
   assign ex2_t04_9 = (~(ex2_t04_9_b));

   assign ex2_alg_add_c_b[7] = (~(ex2_g04_7 | (ex2_t04_7 & ex2_g04_10)));
   assign ex2_alg_add_c_b[8] = (~(ex2_g04_8 | (ex2_t04_8 & ex2_g04_10)));
   assign ex2_alg_add_c_b[9] = (~(ex2_g04_9 | (ex2_t04_9 & ex2_g04_10)));
   assign ex2_alg_add_c_b[10] = (~(ex2_g04_10));

   assign ex2_bsha_6 = (~(ex2_alg_add_p[6] ^ ex2_alg_add_c_b[7]));		//to multiple of 16 decoder
   assign ex2_bsha_7 = (~(ex2_alg_add_p[7] ^ ex2_alg_add_c_b[8]));		//to multiple of 16 decoder
   assign ex2_bsha_8 = (~(ex2_alg_add_p[8] ^ ex2_alg_add_c_b[9]));		//to multiple of 16 decoder
   assign ex2_bsha_9 = (~(ex2_alg_add_p[9] ^ ex2_alg_add_c_b[10]));		//to multiple of 16 decoder

   assign ex2_bsha_6_i = (~ex2_bsha_6);
   assign ex2_bsha_7_i = (~ex2_bsha_7);
   assign ex2_bsha_8_i = (~ex2_bsha_8);
   assign ex2_bsha_9_i = (~ex2_bsha_9);

   assign ex2_bsha_6_o = (~ex2_bsha_6_i);
   assign ex2_bsha_7_o = (~ex2_bsha_7_i);
   assign ex2_bsha_8_o = (~ex2_bsha_8_i);
   assign ex2_bsha_9_o = (~ex2_bsha_9_i);

   //-----------------------------------------------------------------------
   // Just need to know if  2/3/4/5 != 0000 for unf, produce that signal directly
   //-----------------------------------------------------------------------

   assign ex2_g02_2 = (~(ex2_alg_add_g_b[2] & (ex2_alg_add_t_b[2] | ex2_alg_add_g_b[3])));		//for carry select
   assign ex2_g02_4 = (~(ex2_alg_add_g_b[4] & (ex2_alg_add_t_b[4] | ex2_alg_add_g_b[5])));		//for carry select

   assign ex2_t02_2 = (~((ex2_alg_add_t_b[2] | ex2_alg_add_t_b[3])));		//for carry select
   assign ex2_t02_4 = (~(ex2_alg_add_g_b[4] & (ex2_alg_add_t_b[4] | ex2_alg_add_t_b[5])));		//for carry select

   assign ex2_g04_2_b = (~(ex2_g02_2 | (ex2_t02_2 & ex2_g02_4)));		//for carry select
   assign ex2_t04_2_b = (~(ex2_g02_2 | (ex2_t02_2 & ex2_t02_4)));		//for carry select

   assign ex2_ones_2t3_b = (~(ex2_alg_add_p[2] & ex2_alg_add_p[3]));		// for unf calculation
   assign ex2_ones_4t5_b = (~(ex2_alg_add_p[4] & ex2_alg_add_p[5]));		// for unf calculation
   assign ex2_ones_2t5 = (~(ex2_ones_2t3_b | ex2_ones_4t5_b));		// for unf calculation
   assign ex2_ones_2t5_b = (~(ex2_ones_2t5));

   assign ex2_zero_2_b = (~(ex2_alg_add_p[2] ^ ex2_alg_add_t_b[3]));		// for unf calc
   assign ex2_zero_3_b = (~(ex2_alg_add_p[3] ^ ex2_alg_add_t_b[4]));		// for unf calc
   assign ex2_zero_4_b = (~(ex2_alg_add_p[4] ^ ex2_alg_add_t_b[5]));		// for unf calc
   assign ex2_zero_5 = (~(ex2_alg_add_p[5]));		// for unf calc
   assign ex2_zero_5_b = (~(ex2_zero_5));		// for unf calc
   assign ex2_zero_2t3 = (~(ex2_zero_2_b | ex2_zero_3_b));		// for unf calc
   assign ex2_zero_4t5 = (~(ex2_zero_4_b | ex2_zero_5_b));		// for unf calc
   assign ex2_zero_2t5_b = (~(ex2_zero_2t3 & ex2_zero_4t5));		// for unf calc

   //--------------------------------------------------------------------------
   // [1] is really the sign bit .. needed to indicate ovf/underflow
   //-----------------------------------------------
   // finish shift underflow
   // if sha > 162 all the bits should become sticky and the aligner output should be zero
   // from 163:255 the shifter does this, so just need to detect the upper bits

   assign pos_if_pco6 = (ex2_alg_add_p[1] ^ ex2_t04_2_b);
   assign pos_if_nco6 = (ex2_alg_add_p[1] ^ ex2_g04_2_b);
   assign pos_if_pco6_b = (~pos_if_pco6);
   assign pos_if_nco6_b = (~pos_if_nco6);

   assign unf_if_nco6_b = (~(pos_if_nco6 & ex2_zero_2t5_b));
   assign unf_if_pco6_b = (~(pos_if_pco6 & ex2_ones_2t5_b));

   assign ex2_g08_6_b = (~ex2_g08_6);
   assign ex2_bsha_pos = (~((pos_if_pco6_b & ex2_g08_6) | (pos_if_nco6_b & ex2_g08_6_b)));		// same as neg
   assign ex2_sh_ovf_b = (~((pos_if_pco6_b & ex2_g08_6) | (pos_if_nco6_b & ex2_g08_6_b)));		// same as neg
   assign ex2_sh_unf_x = (~((unf_if_pco6_b & ex2_g08_6) | (unf_if_nco6_b & ex2_g08_6_b)));
   assign ex2_bsha_neg = (~(ex2_bsha_pos));
   assign ex2_bsha_neg_o = (~(ex2_bsha_pos));
   assign ex2_sh_ovf = (~(ex2_sh_ovf_b));

   //==-------------------------------------------------------------------------------
   //== decode for first level shifter (0/1/2/3)
   //==-------------------------------------------------------------------------------

   assign ex2_lvl1_shdcd000_b = (~(ex2_bsha_12_b & ex2_bsha_13_b));
   assign ex2_lvl1_shdcd001_b = (~(ex2_bsha_12_b & ex2_bsha_13));
   assign ex2_lvl1_shdcd002_b = (~(ex2_bsha_12 & ex2_bsha_13_b));
   assign ex2_lvl1_shdcd003_b = (~(ex2_bsha_12 & ex2_bsha_13));

   //==-------------------------------------------------------------------------------
   //== decode for second level shifter (0/4/8/12)
   //==-------------------------------------------------------------------------------
   // ex2_lvl2_shdcd000 <= not ex2_bsha(10) and not ex2_bsha(11) ;
   // ex2_lvl2_shdcd004 <= not ex2_bsha(10) and     ex2_bsha(11) ;
   // ex2_lvl2_shdcd008 <=     ex2_bsha(10) and not ex2_bsha(11) ;
   // ex2_lvl2_shdcd012 <=     ex2_bsha(10) and     ex2_bsha(11) ;
   //--------------------------------------------------------------------
   //   p10 (11) ci11  DCD           p10   (11) ci11 DCD
   //   !p    k    0   00             !p    k    0   00
   //   !P    p    0   01              p    g    0   00
   //   !p    g    0   10              P    p    1   00
   //
   //    p    k    0   10             !P    p    0   01
   //    P    p    0   11             !p    k    1   01
   //    p    g    0   00              p    g    1   01
   //
   //   !p    k    1   01             !p    g    0   10
   //   !P    p    1   10              p    k    0   10
   //   !p    g    1   11             !P    p    1   10
   //
   //    p    k    1   11              P    p    0   11
   //    P    p    1   00             !p    g    1   11
   //    p    g    1   01              p    k    1   11

   assign ex2_lv2_0pg0_b = (~(ex2_lv2_p10_b & ex2_lv2_g11 & ex2_lv2_ci11n_en));
   assign ex2_lv2_0pg1_b = (~(ex2_lv2_p10_b & ex2_lv2_g11 & ex2_lv2_ci11p_en));
   assign ex2_lv2_0pk0_b = (~(ex2_lv2_p10_b & ex2_lv2_k11 & ex2_lv2_ci11n_en));
   assign ex2_lv2_0pk1_b = (~(ex2_lv2_p10_b & ex2_lv2_k11 & ex2_lv2_ci11p_en));
   assign ex2_lv2_0pp0_b = (~(ex2_lv2_p10_b & ex2_lv2_p11 & ex2_lv2_ci11n_en));
   assign ex2_lv2_0pp1_b = (~(ex2_lv2_p10_b & ex2_lv2_p11 & ex2_lv2_ci11p_en));
   assign ex2_lv2_1pg0_b = (~(ex2_lv2_p10 & ex2_lv2_g11 & ex2_lv2_ci11n_en));
   assign ex2_lv2_1pg1_b = (~(ex2_lv2_p10 & ex2_lv2_g11 & ex2_lv2_ci11p_en));
   assign ex2_lv2_1pk0_b = (~(ex2_lv2_p10 & ex2_lv2_k11 & ex2_lv2_ci11n_en));
   assign ex2_lv2_1pk1_b = (~(ex2_lv2_p10 & ex2_lv2_k11 & ex2_lv2_ci11p_en));
   assign ex2_lv2_1pp0_b = (~(ex2_lv2_p10 & ex2_lv2_p11 & ex2_lv2_ci11n_en));
   assign ex2_lv2_1pp1_b = (~(ex2_lv2_p10 & ex2_lv2_p11 & ex2_lv2_ci11p_en));

   assign ex2_lv2_shdcd000 = (~(ex2_lv2_0pk0_b & ex2_lv2_1pg0_b & ex2_lv2_1pp1_b));
   assign ex2_lv2_shdcd004 = (~(ex2_lv2_0pp0_b & ex2_lv2_0pk1_b & ex2_lv2_1pg1_b));
   assign ex2_lv2_shdcd008 = (~(ex2_lv2_0pg0_b & ex2_lv2_1pk0_b & ex2_lv2_0pp1_b));
   assign ex2_lv2_shdcd012 = (~(ex2_lv2_1pp0_b & ex2_lv2_0pg1_b & ex2_lv2_1pk1_b));

   assign ex2_lvl2_shdcd000_b = (~ex2_lv2_shdcd000);
   assign ex2_lvl2_shdcd004_b = (~ex2_lv2_shdcd004);
   assign ex2_lvl2_shdcd008_b = (~ex2_lv2_shdcd008);
   assign ex2_lvl2_shdcd012_b = (~ex2_lv2_shdcd012);

   assign ex2_lvl2_shdcd000 = (~ex2_lvl2_shdcd000_b);
   assign ex2_lvl2_shdcd004 = (~ex2_lvl2_shdcd004_b);
   assign ex2_lvl2_shdcd008 = (~ex2_lvl2_shdcd008_b);
   assign ex2_lvl2_shdcd012 = (~ex2_lvl2_shdcd012_b);

   //==--------------------------------------------
   //== decode to control ex3 shifting
   //==--------------------------------------------

   assign ex2_bsha_6_b = (~ex2_bsha_6);
   assign ex2_bsha_7_b = (~ex2_bsha_7);
   assign ex2_bsha_8_b = (~ex2_bsha_8);
   assign ex2_bsha_9_b = (~ex2_bsha_9);

   assign ex2_67_dcd00_b = (~(ex2_bsha_6_b & ex2_bsha_7_b));
   assign ex2_67_dcd01_b = (~(ex2_bsha_6_b & ex2_bsha_7));
   assign ex2_67_dcd10_b = (~(ex2_bsha_6 & ex2_bsha_7_b));
   assign ex2_67_dcd11_b = (~(ex2_bsha_6 & ex2_bsha_7 & ex2_bsha_neg));

   assign ex2_89_dcd00_b = (~(ex2_bsha_8_b & ex2_bsha_9_b & ex2_sel_special_b));
   assign ex2_89_dcd01_b = (~(ex2_bsha_8_b & ex2_bsha_9 & ex2_sel_special_b));
   assign ex2_89_dcd10_b = (~(ex2_bsha_8 & ex2_bsha_9_b & ex2_sel_special_b));
   assign ex2_89_dcd11_b = (~(ex2_bsha_8 & ex2_bsha_9 & ex2_sel_special_b));

   assign ex2_lvl3_shdcd000 = (~(ex2_67_dcd00_b | ex2_89_dcd00_b));		// 0000  +000
   assign ex2_lvl3_shdcd016 = (~(ex2_67_dcd00_b | ex2_89_dcd01_b));		// 0001  +016
   assign ex2_lvl3_shdcd032 = (~(ex2_67_dcd00_b | ex2_89_dcd10_b));		// 0010  +032
   assign ex2_lvl3_shdcd048 = (~(ex2_67_dcd00_b | ex2_89_dcd11_b));		// 0011  +048
   assign ex2_lvl3_shdcd064 = (~(ex2_67_dcd01_b | ex2_89_dcd00_b));		// 0100  +064
   assign ex2_lvl3_shdcd080 = (~(ex2_67_dcd01_b | ex2_89_dcd01_b));		// 0101  +080
   assign ex2_lvl3_shdcd096 = (~(ex2_67_dcd01_b | ex2_89_dcd10_b));		// 0110  +096
   assign ex2_lvl3_shdcd112 = (~(ex2_67_dcd01_b | ex2_89_dcd11_b));		// 0111  +112
   assign ex2_lvl3_shdcd128 = (~(ex2_67_dcd10_b | ex2_89_dcd00_b));		// 1000  +128
   assign ex2_lvl3_shdcd144 = (~(ex2_67_dcd10_b | ex2_89_dcd01_b));		// 1001  +144
   assign ex2_lvl3_shdcd160 = (~(ex2_67_dcd10_b | ex2_89_dcd10_b));		// 1010  +160
   assign ex2_lvl3_shdcd176 = (~(ex2_67_dcd10_b | ex2_89_dcd11_b));		// 1011
   assign ex2_lvl3_shdcd192 = (~(ex2_67_dcd11_b | ex2_89_dcd00_b));		// 1100  -064
   assign ex2_lvl3_shdcd208 = (~(ex2_67_dcd11_b | ex2_89_dcd01_b));		// 1101  -048
   assign ex2_lvl3_shdcd224 = (~(ex2_67_dcd11_b | ex2_89_dcd10_b));		// 1110  -032
   assign ex2_lvl3_shdcd240 = (~(ex2_67_dcd11_b | ex2_89_dcd11_b));		// 1111  -016

endmodule
