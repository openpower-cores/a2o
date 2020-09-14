// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

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
   
   output       ex2_lvl3_shdcd000;		
   output       ex2_lvl3_shdcd016;		
   output       ex2_lvl3_shdcd032;		
   output       ex2_lvl3_shdcd048;		
   output       ex2_lvl3_shdcd064;		
   output       ex2_lvl3_shdcd080;		
   output       ex2_lvl3_shdcd096;		
   output       ex2_lvl3_shdcd112;		
   output       ex2_lvl3_shdcd128;		
   output       ex2_lvl3_shdcd144;		
   output       ex2_lvl3_shdcd160;		
   output       ex2_lvl3_shdcd176;		
   output       ex2_lvl3_shdcd192;		
   output       ex2_lvl3_shdcd208;		
   output       ex2_lvl3_shdcd224;		
   output       ex2_lvl3_shdcd240;		
   
   
   
   
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
   
   
   assign ex2_a_expo_b[2:13] = (~f_byp_alg_ex2_a_expo[2:13]);
   assign ex2_c_expo_b[2:13] = (~f_byp_alg_ex2_c_expo[2:13]);
   assign ex2_b_expo_b[1:13] = (~f_byp_alg_ex2_b_expo[1:13]);
   
   assign ex2_ack_s[1] = (~(f_byp_alg_ex2_a_expo[1] ^ f_byp_alg_ex2_c_expo[1]));		
   assign ex2_ack_s[2] = (~(f_byp_alg_ex2_a_expo[2] ^ f_byp_alg_ex2_c_expo[2]));		
   assign ex2_ack_s[3] = (~(f_byp_alg_ex2_a_expo[3] ^ f_byp_alg_ex2_c_expo[3]));		
   assign ex2_ack_s[4] = (f_byp_alg_ex2_a_expo[4] ^ f_byp_alg_ex2_c_expo[4]);		
   assign ex2_ack_s[5] = (f_byp_alg_ex2_a_expo[5] ^ f_byp_alg_ex2_c_expo[5]);		
   assign ex2_ack_s[6] = (f_byp_alg_ex2_a_expo[6] ^ f_byp_alg_ex2_c_expo[6]);		
   assign ex2_ack_s[7] = (f_byp_alg_ex2_a_expo[7] ^ f_byp_alg_ex2_c_expo[7]);		
   assign ex2_ack_s[8] = (~(f_byp_alg_ex2_a_expo[8] ^ f_byp_alg_ex2_c_expo[8]));		
   assign ex2_ack_s[9] = (~(f_byp_alg_ex2_a_expo[9] ^ f_byp_alg_ex2_c_expo[9]));		
   assign ex2_ack_s[10] = (~(f_byp_alg_ex2_a_expo[10] ^ f_byp_alg_ex2_c_expo[10]));		
   assign ex2_ack_s[11] = (f_byp_alg_ex2_a_expo[11] ^ f_byp_alg_ex2_c_expo[11]);		
   assign ex2_ack_s[12] = (~(f_byp_alg_ex2_a_expo[12] ^ f_byp_alg_ex2_c_expo[12]));		
   assign ex2_ack_s[13] = (f_byp_alg_ex2_a_expo[13] ^ f_byp_alg_ex2_c_expo[13]);		
   
   assign ex2_ack_c[1] = (~(ex2_a_expo_b[2] & ex2_c_expo_b[2]));		
   assign ex2_ack_c[2] = (~(ex2_a_expo_b[3] & ex2_c_expo_b[3]));		
   assign ex2_ack_c[3] = (~(ex2_a_expo_b[4] | ex2_c_expo_b[4]));		
   assign ex2_ack_c[4] = (~(ex2_a_expo_b[5] | ex2_c_expo_b[5]));		
   assign ex2_ack_c[5] = (~(ex2_a_expo_b[6] | ex2_c_expo_b[6]));		
   assign ex2_ack_c[6] = (~(ex2_a_expo_b[7] | ex2_c_expo_b[7]));		
   assign ex2_ack_c[7] = (~(ex2_a_expo_b[8] & ex2_c_expo_b[8]));		
   assign ex2_ack_c[8] = (~(ex2_a_expo_b[9] & ex2_c_expo_b[9]));		
   assign ex2_ack_c[9] = (~(ex2_a_expo_b[10] & ex2_c_expo_b[10]));		
   assign ex2_ack_c[10] = (~(ex2_a_expo_b[11] | ex2_c_expo_b[11]));		
   assign ex2_ack_c[11] = (~(ex2_a_expo_b[12] & ex2_c_expo_b[12]));		
   assign ex2_ack_c[12] = (~(ex2_a_expo_b[13] | ex2_c_expo_b[13]));		
   
   tri_csa32 sha32_01( 
      .vd(vdd),
      .gd(gnd),				
      .a(ex2_b_expo_b[1]),		
      .b(ex2_ack_s[1]),		
      .c(ex2_ack_c[1]),		
      .sum(ex2_alg_sx[1]),		
      .car(ex2_alg_cx[0])		
   );
   
   tri_csa32 sha32_02( 
      .vd(vdd),
      .gd(gnd),				
      .a(ex2_b_expo_b[2]),		
      .b(ex2_ack_s[2]),		
      .c(ex2_ack_c[2]),		
      .sum(ex2_alg_sx[2]),		
      .car(ex2_alg_cx[1])		
   );
   
   tri_csa32 sha32_03( 
      .vd(vdd),
      .gd(gnd),				
      .a(ex2_b_expo_b[3]),		
      .b(ex2_ack_s[3]),		
      .c(ex2_ack_c[3]),		
      .sum(ex2_alg_sx[3]),		
      .car(ex2_alg_cx[2])		
   );
   
   tri_csa32 sha32_04( 
      .vd(vdd),
      .gd(gnd),				
      .a(ex2_b_expo_b[4]),		
      .b(ex2_ack_s[4]),		
      .c(ex2_ack_c[4]),		
      .sum(ex2_alg_sx[4]),		
      .car(ex2_alg_cx[3])		
   );
   
   tri_csa32 sha32_05( 
      .vd(vdd),
      .gd(gnd),				
      .a(ex2_b_expo_b[5]),		
      .b(ex2_ack_s[5]),		
      .c(ex2_ack_c[5]),		
      .sum(ex2_alg_sx[5]),		
      .car(ex2_alg_cx[4])		
   );
   
   tri_csa32 sha32_06( 
      .vd(vdd),
      .gd(gnd),				
      .a(ex2_b_expo_b[6]),		
      .b(ex2_ack_s[6]),		
      .c(ex2_ack_c[6]),		
      .sum(ex2_alg_sx[6]),		
      .car(ex2_alg_cx[5])		
   );
   
   tri_csa32 sha32_07( 
      .vd(vdd),
      .gd(gnd),				
      .a(ex2_b_expo_b[7]),		
      .b(ex2_ack_s[7]),		
      .c(ex2_ack_c[7]),		
      .sum(ex2_alg_sx[7]),		
      .car(ex2_alg_cx[6])		
   );
   
   tri_csa32 sha32_08( 
      .vd(vdd),
      .gd(gnd),				
      .a(ex2_b_expo_b[8]),		
      .b(ex2_ack_s[8]),		
      .c(ex2_ack_c[8]),		
      .sum(ex2_alg_sx[8]),		
      .car(ex2_alg_cx[7])		
   );
   
   tri_csa32 sha32_09( 
      .vd(vdd),
      .gd(gnd),				
      .a(ex2_b_expo_b[9]),		
      .b(ex2_ack_s[9]),		
      .c(ex2_ack_c[9]),		
      .sum(ex2_alg_sx[9]),		
      .car(ex2_alg_cx[8])		
   );
   
   tri_csa32 sha32_10( 
      .vd(vdd),
      .gd(gnd),				
      .a(ex2_b_expo_b[10]),		
      .b(ex2_ack_s[10]),		
      .c(ex2_ack_c[10]),		
      .sum(ex2_alg_sx[10]),		
      .car(ex2_alg_cx[9])		
   );
   
   tri_csa32 sha32_11( 
      .vd(vdd),
      .gd(gnd),				
      .a(ex2_b_expo_b[11]),		
      .b(ex2_ack_s[11]),		
      .c(ex2_ack_c[11]),		
      .sum(ex2_alg_sx[11]),		
      .car(ex2_alg_cx[10])		
   );
   
   tri_csa32 sha32_12( 
      .vd(vdd),
      .gd(gnd),				
      .a(ex2_b_expo_b[12]),		
      .b(ex2_ack_s[12]),		
      .c(ex2_ack_c[12]),		
      .sum(ex2_alg_sx[12]),		
      .car(ex2_alg_cx[11])		
   );
   
   tri_csa32 sha32_13( 
      .vd(vdd),
      .gd(gnd),				
      .a(ex2_b_expo_b[13]),		
      .b(ex2_ack_s[13]),		
      .c(tidn),		
      .sum(ex2_alg_sx[13]),		
      .car(ex2_alg_cx[12])		
   );
   
   
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
   
   
   assign ex2_g02_12 = (~ex2_alg_add_g_b[12]);		
   assign ex2_g02_12_b = (~ex2_g02_12);		
   
   assign ex2_bsha_13_b = (~ex2_alg_sx[13]);		
   assign ex2_bsha_13 = (~ex2_bsha_13_b);		
   assign ex2_bsha_12_b = (~ex2_alg_add_p[12]);
   assign ex2_bsha_12 = (~ex2_bsha_12_b);		
   
   assign ex2_lv2_ci11n_en_b = (~(ex2_sel_special_b & ex2_g02_12_b));
   assign ex2_lv2_ci11p_en_b = (~(ex2_sel_special_b & ex2_g02_12));
   assign ex2_lv2_ci11n_en = (~(ex2_lv2_ci11n_en_b));		
   assign ex2_lv2_ci11p_en = (~(ex2_lv2_ci11p_en_b));		
   
   
   assign ex2_g02_10 = (~(ex2_alg_add_g_b[10] & (ex2_alg_add_t_b[10] | ex2_alg_add_g_b[11])));		
   assign ex2_t02_10 = (~(ex2_alg_add_t_b[10] | ex2_alg_add_t_b[11]));		
   assign ex2_g04_10_b = (~(ex2_g02_10 | (ex2_t02_10 & ex2_g02_12)));		
   
   assign ex2_lv2_g11_x = (~(ex2_alg_add_g_b[11]));
   assign ex2_lv2_g11_b = (~(ex2_lv2_g11_x));
   assign ex2_lv2_g11 = (~(ex2_lv2_g11_b));		
   assign ex2_lv2_k11_b = (~(ex2_alg_add_t_b[11]));
   assign ex2_lv2_k11 = (~(ex2_lv2_k11_b));		
   assign ex2_lv2_p11_b = (~(ex2_alg_add_p[11]));
   assign ex2_lv2_p11 = (~(ex2_lv2_p11_b));		
   assign ex2_lv2_p10_b = (~(ex2_alg_add_p[10]));		
   assign ex2_lv2_p10 = (~(ex2_lv2_p10_b));		
   
   
   assign ex2_g04_10 = (~ex2_g04_10_b);		
   
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
   
   assign ex2_g08_6 = (~(ex2_g04_6_b & (ex2_t04_6_b | ex2_g04_10_b)));		
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
   
   assign ex2_bsha_6 = (~(ex2_alg_add_p[6] ^ ex2_alg_add_c_b[7]));		
   assign ex2_bsha_7 = (~(ex2_alg_add_p[7] ^ ex2_alg_add_c_b[8]));		
   assign ex2_bsha_8 = (~(ex2_alg_add_p[8] ^ ex2_alg_add_c_b[9]));		
   assign ex2_bsha_9 = (~(ex2_alg_add_p[9] ^ ex2_alg_add_c_b[10]));		
   
   assign ex2_bsha_6_i = (~ex2_bsha_6);
   assign ex2_bsha_7_i = (~ex2_bsha_7);
   assign ex2_bsha_8_i = (~ex2_bsha_8);
   assign ex2_bsha_9_i = (~ex2_bsha_9);
   
   assign ex2_bsha_6_o = (~ex2_bsha_6_i);
   assign ex2_bsha_7_o = (~ex2_bsha_7_i);
   assign ex2_bsha_8_o = (~ex2_bsha_8_i);
   assign ex2_bsha_9_o = (~ex2_bsha_9_i);
   
   
   assign ex2_g02_2 = (~(ex2_alg_add_g_b[2] & (ex2_alg_add_t_b[2] | ex2_alg_add_g_b[3])));		
   assign ex2_g02_4 = (~(ex2_alg_add_g_b[4] & (ex2_alg_add_t_b[4] | ex2_alg_add_g_b[5])));		
   
   assign ex2_t02_2 = (~((ex2_alg_add_t_b[2] | ex2_alg_add_t_b[3])));		
   assign ex2_t02_4 = (~(ex2_alg_add_g_b[4] & (ex2_alg_add_t_b[4] | ex2_alg_add_t_b[5])));		
   
   assign ex2_g04_2_b = (~(ex2_g02_2 | (ex2_t02_2 & ex2_g02_4)));		
   assign ex2_t04_2_b = (~(ex2_g02_2 | (ex2_t02_2 & ex2_t02_4)));		
   
   assign ex2_ones_2t3_b = (~(ex2_alg_add_p[2] & ex2_alg_add_p[3]));		
   assign ex2_ones_4t5_b = (~(ex2_alg_add_p[4] & ex2_alg_add_p[5]));		
   assign ex2_ones_2t5 = (~(ex2_ones_2t3_b | ex2_ones_4t5_b));		
   assign ex2_ones_2t5_b = (~(ex2_ones_2t5));
   
   assign ex2_zero_2_b = (~(ex2_alg_add_p[2] ^ ex2_alg_add_t_b[3]));		
   assign ex2_zero_3_b = (~(ex2_alg_add_p[3] ^ ex2_alg_add_t_b[4]));		
   assign ex2_zero_4_b = (~(ex2_alg_add_p[4] ^ ex2_alg_add_t_b[5]));		
   assign ex2_zero_5 = (~(ex2_alg_add_p[5]));		
   assign ex2_zero_5_b = (~(ex2_zero_5));		
   assign ex2_zero_2t3 = (~(ex2_zero_2_b | ex2_zero_3_b));		
   assign ex2_zero_4t5 = (~(ex2_zero_4_b | ex2_zero_5_b));		
   assign ex2_zero_2t5_b = (~(ex2_zero_2t3 & ex2_zero_4t5));		
   
   
   assign pos_if_pco6 = (ex2_alg_add_p[1] ^ ex2_t04_2_b);
   assign pos_if_nco6 = (ex2_alg_add_p[1] ^ ex2_g04_2_b);
   assign pos_if_pco6_b = (~pos_if_pco6);
   assign pos_if_nco6_b = (~pos_if_nco6);
   
   assign unf_if_nco6_b = (~(pos_if_nco6 & ex2_zero_2t5_b));
   assign unf_if_pco6_b = (~(pos_if_pco6 & ex2_ones_2t5_b));
   
   assign ex2_g08_6_b = (~ex2_g08_6);
   assign ex2_bsha_pos = (~((pos_if_pco6_b & ex2_g08_6) | (pos_if_nco6_b & ex2_g08_6_b)));		
   assign ex2_sh_ovf_b = (~((pos_if_pco6_b & ex2_g08_6) | (pos_if_nco6_b & ex2_g08_6_b)));		
   assign ex2_sh_unf_x = (~((unf_if_pco6_b & ex2_g08_6) | (unf_if_nco6_b & ex2_g08_6_b)));
   assign ex2_bsha_neg = (~(ex2_bsha_pos));
   assign ex2_bsha_neg_o = (~(ex2_bsha_pos));
   assign ex2_sh_ovf = (~(ex2_sh_ovf_b));
   
   
   assign ex2_lvl1_shdcd000_b = (~(ex2_bsha_12_b & ex2_bsha_13_b));
   assign ex2_lvl1_shdcd001_b = (~(ex2_bsha_12_b & ex2_bsha_13));
   assign ex2_lvl1_shdcd002_b = (~(ex2_bsha_12 & ex2_bsha_13_b));
   assign ex2_lvl1_shdcd003_b = (~(ex2_bsha_12 & ex2_bsha_13));
   
   
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
   
   assign ex2_lvl3_shdcd000 = (~(ex2_67_dcd00_b | ex2_89_dcd00_b));		
   assign ex2_lvl3_shdcd016 = (~(ex2_67_dcd00_b | ex2_89_dcd01_b));		
   assign ex2_lvl3_shdcd032 = (~(ex2_67_dcd00_b | ex2_89_dcd10_b));		
   assign ex2_lvl3_shdcd048 = (~(ex2_67_dcd00_b | ex2_89_dcd11_b));		
   assign ex2_lvl3_shdcd064 = (~(ex2_67_dcd01_b | ex2_89_dcd00_b));		
   assign ex2_lvl3_shdcd080 = (~(ex2_67_dcd01_b | ex2_89_dcd01_b));		
   assign ex2_lvl3_shdcd096 = (~(ex2_67_dcd01_b | ex2_89_dcd10_b));		
   assign ex2_lvl3_shdcd112 = (~(ex2_67_dcd01_b | ex2_89_dcd11_b));		
   assign ex2_lvl3_shdcd128 = (~(ex2_67_dcd10_b | ex2_89_dcd00_b));		
   assign ex2_lvl3_shdcd144 = (~(ex2_67_dcd10_b | ex2_89_dcd01_b));		
   assign ex2_lvl3_shdcd160 = (~(ex2_67_dcd10_b | ex2_89_dcd10_b));		
   assign ex2_lvl3_shdcd176 = (~(ex2_67_dcd10_b | ex2_89_dcd11_b));		
   assign ex2_lvl3_shdcd192 = (~(ex2_67_dcd11_b | ex2_89_dcd00_b));		
   assign ex2_lvl3_shdcd208 = (~(ex2_67_dcd11_b | ex2_89_dcd01_b));		
   assign ex2_lvl3_shdcd224 = (~(ex2_67_dcd11_b | ex2_89_dcd10_b));		
   assign ex2_lvl3_shdcd240 = (~(ex2_67_dcd11_b | ex2_89_dcd11_b));		
   
endmodule
