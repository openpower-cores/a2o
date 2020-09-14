// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.



`include "tri_a2o.vh"

module tri_st_mult_core(
   nclk,
   vdd,
   gnd,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   func_sl_force,
   func_sl_thold_0_b,
   sg_0,
   scan_in,
   scan_out,
   ex3_act,
   ex4_act,
   ex3_bs_lo_sign,
   ex3_bd_lo_sign,
   ex3_bd_lo,
   ex3_bs_lo,
   ex4_recycle_s,
   ex4_recycle_c,
   ex5_pp5_0s_out,
   ex5_pp5_0c_out
);
   input [0:`NCLK_WIDTH-1]  nclk;
   inout            vdd;
   inout            gnd;
   input            delay_lclkr_dc;
   input            mpw1_dc_b;
   input            mpw2_dc_b;
   input            func_sl_force;
   input            func_sl_thold_0_b;
   input            sg_0;
   input            scan_in;
   output           scan_out;
   
   input            ex3_act;		
   input            ex4_act;		
   
   input            ex3_bs_lo_sign;		
   input            ex3_bd_lo_sign;		
   input [0:31]     ex3_bd_lo;		
   input [0:31]     ex3_bs_lo;		
   
   input [196:264]  ex4_recycle_s;		
   input [196:263]  ex4_recycle_c;		
   
   output [196:264] ex5_pp5_0s_out;		
   output [196:263] ex5_pp5_0c_out;		


   wire             ex4_d1clk;
   wire             ex5_d1clk;
   wire             ex4_d2clk;
   wire             ex5_d2clk;
   wire [0:`NCLK_WIDTH-1] ex4_lclk;
   wire [0:`NCLK_WIDTH-1] ex5_lclk;

   wire [198:240]   ex4_pp2_0c_din;
   wire [198:240]   ex4_pp2_0c;
   wire [198:240]   ex4_pp2_0c_q_b;
   wire [198:240]   ex4_pp2_0c_lat_so;
   wire [198:240]   ex4_pp2_0c_lat_si;
   wire [198:242]   ex4_pp2_0s_din;
   wire [198:242]   ex4_pp2_0s;
   wire [198:242]   ex4_pp2_0s_q_b;
   wire [198:242]   ex4_pp2_0s_lat_so;
   wire [198:242]   ex4_pp2_0s_lat_si;
   wire [208:252]   ex4_pp2_1c_din;
   wire [208:252]   ex4_pp2_1c;
   wire [208:252]   ex4_pp2_1c_x;
   wire [208:252]   ex4_pp2_1c_x_b;
   wire [208:252]   ex4_pp2_1c_q_b;
   wire [208:252]   ex4_pp2_1c_lat_so;
   wire [208:252]   ex4_pp2_1c_lat_si;
   wire [208:254]   ex4_pp2_1s_din;
   wire [208:254]   ex4_pp2_1s;
   wire [208:254]   ex4_pp2_1s_x;
   wire [208:254]   ex4_pp2_1s_x_b;
   wire [208:254]   ex4_pp2_1s_q_b;
   wire [208:254]   ex4_pp2_1s_lat_so;
   wire [208:254]   ex4_pp2_1s_lat_si;
   wire [220:263]   ex4_pp2_2c_din;
   wire [220:263]   ex4_pp2_2c;
   wire [220:263]   ex4_pp2_2c_x;
   wire [220:263]   ex4_pp2_2c_x_b;
   wire [220:263]   ex4_pp2_2c_q_b;
   wire [220:263]   ex4_pp2_2c_lat_so;
   wire [220:263]   ex4_pp2_2c_lat_si;
   wire [220:264]   ex4_pp2_2s_din;
   wire [220:264]   ex4_pp2_2s;
   wire [220:264]   ex4_pp2_2s_x;
   wire [220:264]   ex4_pp2_2s_x_b;
   wire [220:264]   ex4_pp2_2s_q_b;
   wire [220:264]   ex4_pp2_2s_lat_so;
   wire [220:264]   ex4_pp2_2s_lat_si;

   wire [196:264]   ex5_pp5_0s_din;
   wire [196:264]   ex5_pp5_0s;
   wire [196:264]   ex5_pp5_0s_q_b;
   wire [196:264]   ex5_pp5_0s_lat_so;
   wire [196:264]   ex5_pp5_0s_lat_si;
   wire [196:263]   ex5_pp5_0c_din;
   wire [196:263]   ex5_pp5_0c;
   wire [196:263]   ex5_pp5_0c_q_b;
   wire [196:263]   ex5_pp5_0c_lat_so;
   wire [196:263]   ex5_pp5_0c_lat_si;

   wire [0:16]      ex3_bd_neg;
   wire [0:16]      ex3_bd_sh0;
   wire [0:16]      ex3_bd_sh1;

   wire [0:32]      ex3_br_00_out;
   wire [0:32]      ex3_br_01_out;
   wire [0:32]      ex3_br_02_out;
   wire [0:32]      ex3_br_03_out;
   wire [0:32]      ex3_br_04_out;
   wire [0:32]      ex3_br_05_out;
   wire [0:32]      ex3_br_06_out;
   wire [0:32]      ex3_br_07_out;
   wire [0:32]      ex3_br_08_out;
   wire [0:32]      ex3_br_09_out;
   wire [0:32]      ex3_br_10_out;
   wire [0:32]      ex3_br_11_out;
   wire [0:32]      ex3_br_12_out;
   wire [0:32]      ex3_br_13_out;
   wire [0:32]      ex3_br_14_out;
   wire [0:32]      ex3_br_15_out;
   wire [0:32]      ex3_br_16_out;
   wire [0:16]      ex3_hot_one;

   wire [199:234]   ex3_pp1_0c;
   wire [198:236]   ex3_pp1_0s;
   wire [203:240]   ex3_pp1_1c;
   wire [202:242]   ex3_pp1_1s;
   wire [209:246]   ex3_pp1_2c;
   wire [208:248]   ex3_pp1_2s;
   wire [215:252]   ex3_pp1_3c;
   wire [214:254]   ex3_pp1_3s;
   wire [221:258]   ex3_pp1_4c;
   wire [220:260]   ex3_pp1_4s;
   wire [227:264]   ex3_pp1_5c;
   wire [226:264]   ex3_pp1_5s;

   wire [198:240]   ex3_pp2_0c;
   wire [198:242]   ex3_pp2_0s;
   wire [208:252]   ex3_pp2_1c;
   wire [208:254]   ex3_pp2_1s;
   wire [220:263]   ex3_pp2_2c;
   wire [220:264]   ex3_pp2_2s;

   wire [201:234]   ex3_pp2_0k;
   wire [213:246]   ex3_pp2_1k;
   wire [225:258]   ex3_pp2_2k;

   wire [197:242]   ex4_pp3_0c;
   wire [198:252]   ex4_pp3_0s;
   wire [219:262]   ex4_pp3_1c;
   wire [208:264]   ex4_pp3_1s;

   wire [207:242]   ex4_pp4_0k;
   wire [197:262]   ex4_pp4_0c;
   wire [197:264]   ex4_pp4_0s;

   wire [196:262]   ex4_pp5_0k;
   wire [195:263]   ex4_pp5_0c;
   wire [196:264]   ex4_pp5_0s;
   wire             ex3_br_00_add;
   wire             ex3_br_01_add;
   wire             ex3_br_02_add;
   wire             ex3_br_03_add;
   wire             ex3_br_04_add;
   wire             ex3_br_05_add;
   wire             ex3_br_06_add;
   wire             ex3_br_07_add;
   wire             ex3_br_08_add;
   wire             ex3_br_09_add;
   wire             ex3_br_10_add;
   wire             ex3_br_11_add;
   wire             ex3_br_12_add;
   wire             ex3_br_13_add;
   wire             ex3_br_14_add;
   wire             ex3_br_15_add;
   wire             ex3_br_16_add;
   wire             ex3_br_16_sub;

   (* analysis_not_referenced="true" *)
   wire             unused_stuff;

   wire [198:234]   ex3_pp0_00;
   wire [200:236]   ex3_pp0_01;
   wire [202:238]   ex3_pp0_02;
   wire [204:240]   ex3_pp0_03;
   wire [206:242]   ex3_pp0_04;
   wire [208:244]   ex3_pp0_05;
   wire [210:246]   ex3_pp0_06;
   wire [212:248]   ex3_pp0_07;
   wire [214:250]   ex3_pp0_08;
   wire [216:252]   ex3_pp0_09;
   wire [218:254]   ex3_pp0_10;
   wire [220:256]   ex3_pp0_11;
   wire [222:258]   ex3_pp0_12;
   wire [224:260]   ex3_pp0_13;
   wire [226:262]   ex3_pp0_14;
   wire [228:264]   ex3_pp0_15;
   wire [229:264]   ex3_pp0_16;
   wire [232:232]   ex3_pp0_17;

   wire             ex3_br_00_sign_xor;
   wire             ex3_br_01_sign_xor;
   wire             ex3_br_02_sign_xor;
   wire             ex3_br_03_sign_xor;
   wire             ex3_br_04_sign_xor;
   wire             ex3_br_05_sign_xor;
   wire             ex3_br_06_sign_xor;
   wire             ex3_br_07_sign_xor;
   wire             ex3_br_08_sign_xor;
   wire             ex3_br_09_sign_xor;
   wire             ex3_br_10_sign_xor;
   wire             ex3_br_11_sign_xor;
   wire             ex3_br_12_sign_xor;
   wire             ex3_br_13_sign_xor;
   wire             ex3_br_14_sign_xor;
   wire             ex3_br_15_sign_xor;
   wire             ex3_br_16_sign_xor;

   wire [0:7]       version;

   assign unused_stuff = ex3_pp1_1s[241] | ex3_pp1_1c[238] | ex3_pp1_1c[239] | ex3_pp1_2s[247] | ex3_pp1_2c[244] | ex3_pp1_2c[245] | ex3_pp1_3s[253] | ex3_pp1_3c[250] | ex3_pp1_3c[251] | ex3_pp1_4s[259] | ex3_pp1_4c[256] | ex3_pp1_4c[257] | ex3_pp1_5c[262] | ex3_pp1_5c[263] | ex4_pp2_0s[241] | ex4_pp2_0c[236] | ex4_pp2_0c[238] | ex4_pp2_0c[239] | ex4_pp2_1s[253] | ex4_pp2_1c[248] | ex4_pp2_1c[250] | ex4_pp2_1c[251] | ex4_pp2_2c[260] | ex4_pp2_2c[262] | ex4_pp3_0s[248] | ex4_pp3_0s[250] | ex4_pp3_0s[251] | ex4_pp3_0c[240] | ex4_pp3_0c[241] | ex4_pp3_1c[254] | ex4_pp3_1c[260] | ex4_pp4_0c[252] | ex4_pp4_0c[254] | ex4_pp4_0c[260] | ex3_pp1_0c[232] | ex3_pp1_0c[233] | ex3_pp0_00[233] | ex3_pp0_01[235] | ex3_pp0_02[237] | ex3_pp0_03[239] | ex3_pp0_04[241] | ex3_pp0_05[243] | ex3_pp0_06[245] | ex3_pp0_07[247] | ex3_pp0_08[249] | ex3_pp0_09[251] | ex3_pp0_10[253] | ex3_pp0_11[255] | ex3_pp0_12[257] | ex3_pp0_13[259] | ex3_pp0_14[261] | ex3_pp0_15[263] | ex3_pp1_0s[235] | ex4_pp5_0c[195] | (|version[0:7]);

   assign version = 8'b00010000;



   tri_st_mult_boothdcd bd_00(
      .i0(ex3_bd_lo_sign),		
      .i1(ex3_bd_lo[0]),		
      .i2(ex3_bd_lo[1]),		
      .s_neg(ex3_bd_neg[0]),		
      .s_x(ex3_bd_sh0[0]),		
      .s_x2(ex3_bd_sh1[0])		
   );

   tri_st_mult_boothdcd bd_01(
      .i0(ex3_bd_lo[1]),		
      .i1(ex3_bd_lo[2]),		
      .i2(ex3_bd_lo[3]),		
      .s_neg(ex3_bd_neg[1]),		
      .s_x(ex3_bd_sh0[1]),		
      .s_x2(ex3_bd_sh1[1])		
   );

   tri_st_mult_boothdcd bd_02(
      .i0(ex3_bd_lo[3]),		
      .i1(ex3_bd_lo[4]),		
      .i2(ex3_bd_lo[5]),		
      .s_neg(ex3_bd_neg[2]),		
      .s_x(ex3_bd_sh0[2]),		
      .s_x2(ex3_bd_sh1[2])		
   );

   tri_st_mult_boothdcd bd_03(
      .i0(ex3_bd_lo[5]),		
      .i1(ex3_bd_lo[6]),		
      .i2(ex3_bd_lo[7]),		
      .s_neg(ex3_bd_neg[3]),		
      .s_x(ex3_bd_sh0[3]),		
      .s_x2(ex3_bd_sh1[3])		
   );

   tri_st_mult_boothdcd bd_04(
      .i0(ex3_bd_lo[7]),		
      .i1(ex3_bd_lo[8]),		
      .i2(ex3_bd_lo[9]),		
      .s_neg(ex3_bd_neg[4]),		
      .s_x(ex3_bd_sh0[4]),		
      .s_x2(ex3_bd_sh1[4])		
   );

   tri_st_mult_boothdcd bd_05(
      .i0(ex3_bd_lo[9]),		
      .i1(ex3_bd_lo[10]),		
      .i2(ex3_bd_lo[11]),		
      .s_neg(ex3_bd_neg[5]),		
      .s_x(ex3_bd_sh0[5]),		
      .s_x2(ex3_bd_sh1[5])		
   );

   tri_st_mult_boothdcd bd_06(
      .i0(ex3_bd_lo[11]),		
      .i1(ex3_bd_lo[12]),		
      .i2(ex3_bd_lo[13]),		
      .s_neg(ex3_bd_neg[6]),		
      .s_x(ex3_bd_sh0[6]),		
      .s_x2(ex3_bd_sh1[6])		
   );

   tri_st_mult_boothdcd bd_07(
      .i0(ex3_bd_lo[13]),		
      .i1(ex3_bd_lo[14]),		
      .i2(ex3_bd_lo[15]),		
      .s_neg(ex3_bd_neg[7]),		
      .s_x(ex3_bd_sh0[7]),		
      .s_x2(ex3_bd_sh1[7])		
   );

   tri_st_mult_boothdcd bd_08(
      .i0(ex3_bd_lo[15]),		
      .i1(ex3_bd_lo[16]),		
      .i2(ex3_bd_lo[17]),		
      .s_neg(ex3_bd_neg[8]),		
      .s_x(ex3_bd_sh0[8]),		
      .s_x2(ex3_bd_sh1[8])		
   );

   tri_st_mult_boothdcd bd_09(
      .i0(ex3_bd_lo[17]),		
      .i1(ex3_bd_lo[18]),		
      .i2(ex3_bd_lo[19]),		
      .s_neg(ex3_bd_neg[9]),		
      .s_x(ex3_bd_sh0[9]),		
      .s_x2(ex3_bd_sh1[9])		
   );

   tri_st_mult_boothdcd bd_10(
      .i0(ex3_bd_lo[19]),		
      .i1(ex3_bd_lo[20]),		
      .i2(ex3_bd_lo[21]),		
      .s_neg(ex3_bd_neg[10]),		
      .s_x(ex3_bd_sh0[10]),		
      .s_x2(ex3_bd_sh1[10])		
   );

   tri_st_mult_boothdcd bd_11(
      .i0(ex3_bd_lo[21]),		
      .i1(ex3_bd_lo[22]),		
      .i2(ex3_bd_lo[23]),		
      .s_neg(ex3_bd_neg[11]),		
      .s_x(ex3_bd_sh0[11]),		
      .s_x2(ex3_bd_sh1[11])		
   );

   tri_st_mult_boothdcd bd_12(
      .i0(ex3_bd_lo[23]),		
      .i1(ex3_bd_lo[24]),		
      .i2(ex3_bd_lo[25]),		
      .s_neg(ex3_bd_neg[12]),		
      .s_x(ex3_bd_sh0[12]),		
      .s_x2(ex3_bd_sh1[12])		
   );

   tri_st_mult_boothdcd bd_13(
      .i0(ex3_bd_lo[25]),		
      .i1(ex3_bd_lo[26]),		
      .i2(ex3_bd_lo[27]),		
      .s_neg(ex3_bd_neg[13]),		
      .s_x(ex3_bd_sh0[13]),		
      .s_x2(ex3_bd_sh1[13])		
   );

   tri_st_mult_boothdcd bd_14(
      .i0(ex3_bd_lo[27]),		
      .i1(ex3_bd_lo[28]),		
      .i2(ex3_bd_lo[29]),		
      .s_neg(ex3_bd_neg[14]),		
      .s_x(ex3_bd_sh0[14]),		
      .s_x2(ex3_bd_sh1[14])		
   );

   tri_st_mult_boothdcd bd_15(
      .i0(ex3_bd_lo[29]),		
      .i1(ex3_bd_lo[30]),		
      .i2(ex3_bd_lo[31]),		
      .s_neg(ex3_bd_neg[15]),		
      .s_x(ex3_bd_sh0[15]),		
      .s_x2(ex3_bd_sh1[15])		
   );

   tri_st_mult_boothdcd bd_16(
      .i0(ex3_bd_lo[31]),		
      .i1(1'b0),		
      .i2(1'b0),		
      .s_neg(ex3_bd_neg[16]),		
      .s_x(ex3_bd_sh0[16]),		
      .s_x2(ex3_bd_sh1[16])		
   );



   tri_st_mult_boothrow br_00(
      .s_neg(ex3_bd_neg[0]),		
      .s_x(ex3_bd_sh0[0]),		
      .s_x2(ex3_bd_sh1[0]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_00_out[0:32]),		
      .hot_one(ex3_hot_one[0])		
   );

   tri_st_mult_boothrow br_01(
      .s_neg(ex3_bd_neg[1]),		
      .s_x(ex3_bd_sh0[1]),		
      .s_x2(ex3_bd_sh1[1]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_01_out[0:32]),		
      .hot_one(ex3_hot_one[1])		
   );

   tri_st_mult_boothrow br_02(
      .s_neg(ex3_bd_neg[2]),		
      .s_x(ex3_bd_sh0[2]),		
      .s_x2(ex3_bd_sh1[2]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_02_out[0:32]),		
      .hot_one(ex3_hot_one[2])		
   );

   tri_st_mult_boothrow br_03(
      .s_neg(ex3_bd_neg[3]),		
      .s_x(ex3_bd_sh0[3]),		
      .s_x2(ex3_bd_sh1[3]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_03_out[0:32]),		
      .hot_one(ex3_hot_one[3])		
   );

   tri_st_mult_boothrow br_04(
      .s_neg(ex3_bd_neg[4]),		
      .s_x(ex3_bd_sh0[4]),		
      .s_x2(ex3_bd_sh1[4]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_04_out[0:32]),		
      .hot_one(ex3_hot_one[4])		
   );

   tri_st_mult_boothrow br_05(
      .s_neg(ex3_bd_neg[5]),		
      .s_x(ex3_bd_sh0[5]),		
      .s_x2(ex3_bd_sh1[5]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_05_out[0:32]),		
      .hot_one(ex3_hot_one[5])		
   );

   tri_st_mult_boothrow br_06(
      .s_neg(ex3_bd_neg[6]),		
      .s_x(ex3_bd_sh0[6]),		
      .s_x2(ex3_bd_sh1[6]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_06_out[0:32]),		
      .hot_one(ex3_hot_one[6])		
   );

   tri_st_mult_boothrow br_07(
      .s_neg(ex3_bd_neg[7]),		
      .s_x(ex3_bd_sh0[7]),		
      .s_x2(ex3_bd_sh1[7]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_07_out[0:32]),		
      .hot_one(ex3_hot_one[7])		
   );

   tri_st_mult_boothrow br_08(
      .s_neg(ex3_bd_neg[8]),		
      .s_x(ex3_bd_sh0[8]),		
      .s_x2(ex3_bd_sh1[8]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_08_out[0:32]),		
      .hot_one(ex3_hot_one[8])		
   );

   tri_st_mult_boothrow br_09(
      .s_neg(ex3_bd_neg[9]),		
      .s_x(ex3_bd_sh0[9]),		
      .s_x2(ex3_bd_sh1[9]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_09_out[0:32]),		
      .hot_one(ex3_hot_one[9])		
   );

   tri_st_mult_boothrow br_10(
      .s_neg(ex3_bd_neg[10]),		
      .s_x(ex3_bd_sh0[10]),		
      .s_x2(ex3_bd_sh1[10]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_10_out[0:32]),		
      .hot_one(ex3_hot_one[10])		
   );

   tri_st_mult_boothrow br_11(
      .s_neg(ex3_bd_neg[11]),		
      .s_x(ex3_bd_sh0[11]),		
      .s_x2(ex3_bd_sh1[11]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_11_out[0:32]),		
      .hot_one(ex3_hot_one[11])		
   );

   tri_st_mult_boothrow br_12(
      .s_neg(ex3_bd_neg[12]),		
      .s_x(ex3_bd_sh0[12]),		
      .s_x2(ex3_bd_sh1[12]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_12_out[0:32]),		
      .hot_one(ex3_hot_one[12])		
   );

   tri_st_mult_boothrow br_13(
      .s_neg(ex3_bd_neg[13]),		
      .s_x(ex3_bd_sh0[13]),		
      .s_x2(ex3_bd_sh1[13]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_13_out[0:32]),		
      .hot_one(ex3_hot_one[13])		
   );

   tri_st_mult_boothrow br_14(
      .s_neg(ex3_bd_neg[14]),		
      .s_x(ex3_bd_sh0[14]),		
      .s_x2(ex3_bd_sh1[14]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_14_out[0:32]),		
      .hot_one(ex3_hot_one[14])		
   );

   tri_st_mult_boothrow br_15(
      .s_neg(ex3_bd_neg[15]),		
      .s_x(ex3_bd_sh0[15]),		
      .s_x2(ex3_bd_sh1[15]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_15_out[0:32]),		
      .hot_one(ex3_hot_one[15])		
   );

   tri_st_mult_boothrow br_16(
      .s_neg(ex3_bd_neg[16]),		
      .s_x(ex3_bd_sh0[16]),		
      .s_x2(ex3_bd_sh1[16]),		
      .sign_bit_adj(ex3_bs_lo_sign),		
      .x(ex3_bs_lo[0:31]),		
      .q(ex3_br_16_out[0:32]),		
      .hot_one(ex3_hot_one[16])		
   );

   assign ex3_br_00_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[0];
   assign ex3_br_01_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[1];
   assign ex3_br_02_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[2];
   assign ex3_br_03_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[3];
   assign ex3_br_04_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[4];
   assign ex3_br_05_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[5];
   assign ex3_br_06_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[6];
   assign ex3_br_07_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[7];
   assign ex3_br_08_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[8];
   assign ex3_br_09_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[9];
   assign ex3_br_10_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[10];
   assign ex3_br_11_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[11];
   assign ex3_br_12_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[12];
   assign ex3_br_13_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[13];
   assign ex3_br_14_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[14];
   assign ex3_br_15_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[15];
   assign ex3_br_16_sign_xor = ex3_bs_lo_sign ^ ex3_bd_neg[16];

   assign ex3_br_00_add = (~(ex3_br_00_sign_xor & (ex3_bd_sh0[0] | ex3_bd_sh1[0])));		
   assign ex3_br_01_add = (~(ex3_br_01_sign_xor & (ex3_bd_sh0[1] | ex3_bd_sh1[1])));		
   assign ex3_br_02_add = (~(ex3_br_02_sign_xor & (ex3_bd_sh0[2] | ex3_bd_sh1[2])));		
   assign ex3_br_03_add = (~(ex3_br_03_sign_xor & (ex3_bd_sh0[3] | ex3_bd_sh1[3])));		
   assign ex3_br_04_add = (~(ex3_br_04_sign_xor & (ex3_bd_sh0[4] | ex3_bd_sh1[4])));		
   assign ex3_br_05_add = (~(ex3_br_05_sign_xor & (ex3_bd_sh0[5] | ex3_bd_sh1[5])));		
   assign ex3_br_06_add = (~(ex3_br_06_sign_xor & (ex3_bd_sh0[6] | ex3_bd_sh1[6])));		
   assign ex3_br_07_add = (~(ex3_br_07_sign_xor & (ex3_bd_sh0[7] | ex3_bd_sh1[7])));		
   assign ex3_br_08_add = (~(ex3_br_08_sign_xor & (ex3_bd_sh0[8] | ex3_bd_sh1[8])));		
   assign ex3_br_09_add = (~(ex3_br_09_sign_xor & (ex3_bd_sh0[9] | ex3_bd_sh1[9])));		
   assign ex3_br_10_add = (~(ex3_br_10_sign_xor & (ex3_bd_sh0[10] | ex3_bd_sh1[10])));		
   assign ex3_br_11_add = (~(ex3_br_11_sign_xor & (ex3_bd_sh0[11] | ex3_bd_sh1[11])));		
   assign ex3_br_12_add = (~(ex3_br_12_sign_xor & (ex3_bd_sh0[12] | ex3_bd_sh1[12])));		
   assign ex3_br_13_add = (~(ex3_br_13_sign_xor & (ex3_bd_sh0[13] | ex3_bd_sh1[13])));		
   assign ex3_br_14_add = (~(ex3_br_14_sign_xor & (ex3_bd_sh0[14] | ex3_bd_sh1[14])));		
   assign ex3_br_15_add = (~(ex3_br_15_sign_xor & (ex3_bd_sh0[15] | ex3_bd_sh1[15])));		
   assign ex3_br_16_add = (~(ex3_br_16_sign_xor & (ex3_bd_sh0[16] | ex3_bd_sh1[16])));		
   assign ex3_br_16_sub = ex3_br_16_sign_xor & (ex3_bd_sh0[16] | ex3_bd_sh1[16]);		

   assign ex3_pp0_00[198] = 1;
   assign ex3_pp0_00[199] = ex3_br_00_add;
   assign ex3_pp0_00[200:232] = ex3_br_00_out[0:32];
   assign ex3_pp0_00[233] = 0;
   assign ex3_pp0_00[234] = ex3_hot_one[1];

   assign ex3_pp0_01[200] = 1;
   assign ex3_pp0_01[201] = ex3_br_01_add;
   assign ex3_pp0_01[202:234] = ex3_br_01_out[0:32];
   assign ex3_pp0_01[235] = 0;
   assign ex3_pp0_01[236] = ex3_hot_one[2];

   assign ex3_pp0_02[202] = 1;
   assign ex3_pp0_02[203] = ex3_br_02_add;
   assign ex3_pp0_02[204:236] = ex3_br_02_out[0:32];
   assign ex3_pp0_02[237] = 0;
   assign ex3_pp0_02[238] = ex3_hot_one[3];

   assign ex3_pp0_03[204] = 1;
   assign ex3_pp0_03[205] = ex3_br_03_add;
   assign ex3_pp0_03[206:238] = ex3_br_03_out[0:32];
   assign ex3_pp0_03[239] = 0;
   assign ex3_pp0_03[240] = ex3_hot_one[4];

   assign ex3_pp0_04[206] = 1;
   assign ex3_pp0_04[207] = ex3_br_04_add;
   assign ex3_pp0_04[208:240] = ex3_br_04_out[0:32];
   assign ex3_pp0_04[241] = 0;
   assign ex3_pp0_04[242] = ex3_hot_one[5];

   assign ex3_pp0_05[208] = 1;
   assign ex3_pp0_05[209] = ex3_br_05_add;
   assign ex3_pp0_05[210:242] = ex3_br_05_out[0:32];
   assign ex3_pp0_05[243] = 0;
   assign ex3_pp0_05[244] = ex3_hot_one[6];

   assign ex3_pp0_06[210] = 1;
   assign ex3_pp0_06[211] = ex3_br_06_add;
   assign ex3_pp0_06[212:244] = ex3_br_06_out[0:32];
   assign ex3_pp0_06[245] = 0;
   assign ex3_pp0_06[246] = ex3_hot_one[7];

   assign ex3_pp0_07[212] = 1;
   assign ex3_pp0_07[213] = ex3_br_07_add;
   assign ex3_pp0_07[214:246] = ex3_br_07_out[0:32];
   assign ex3_pp0_07[247] = 0;
   assign ex3_pp0_07[248] = ex3_hot_one[8];

   assign ex3_pp0_08[214] = 1;
   assign ex3_pp0_08[215] = ex3_br_08_add;
   assign ex3_pp0_08[216:248] = ex3_br_08_out[0:32];
   assign ex3_pp0_08[249] = 0;
   assign ex3_pp0_08[250] = ex3_hot_one[9];

   assign ex3_pp0_09[216] = 1;
   assign ex3_pp0_09[217] = ex3_br_09_add;
   assign ex3_pp0_09[218:250] = ex3_br_09_out[0:32];
   assign ex3_pp0_09[251] = 0;
   assign ex3_pp0_09[252] = ex3_hot_one[10];

   assign ex3_pp0_10[218] = 1;
   assign ex3_pp0_10[219] = ex3_br_10_add;
   assign ex3_pp0_10[220:252] = ex3_br_10_out[0:32];
   assign ex3_pp0_10[253] = 0;
   assign ex3_pp0_10[254] = ex3_hot_one[11];

   assign ex3_pp0_11[220] = 1;
   assign ex3_pp0_11[221] = ex3_br_11_add;
   assign ex3_pp0_11[222:254] = ex3_br_11_out[0:32];
   assign ex3_pp0_11[255] = 0;
   assign ex3_pp0_11[256] = ex3_hot_one[12];

   assign ex3_pp0_12[222] = 1;
   assign ex3_pp0_12[223] = ex3_br_12_add;
   assign ex3_pp0_12[224:256] = ex3_br_12_out[0:32];
   assign ex3_pp0_12[257] = 0;
   assign ex3_pp0_12[258] = ex3_hot_one[13];

   assign ex3_pp0_13[224] = 1;
   assign ex3_pp0_13[225] = ex3_br_13_add;
   assign ex3_pp0_13[226:258] = ex3_br_13_out[0:32];
   assign ex3_pp0_13[259] = 0;
   assign ex3_pp0_13[260] = ex3_hot_one[14];

   assign ex3_pp0_14[226] = 1;
   assign ex3_pp0_14[227] = ex3_br_14_add;
   assign ex3_pp0_14[228:260] = ex3_br_14_out[0:32];
   assign ex3_pp0_14[261] = 0;
   assign ex3_pp0_14[262] = ex3_hot_one[15];

   assign ex3_pp0_15[228] = 1;
   assign ex3_pp0_15[229] = ex3_br_15_add;
   assign ex3_pp0_15[230:262] = ex3_br_15_out[0:32];
   assign ex3_pp0_15[263] = 0;
   assign ex3_pp0_15[264] = ex3_hot_one[16];

   assign ex3_pp0_16[229] = ex3_br_16_add;
   assign ex3_pp0_16[230] = ex3_br_16_sub;
   assign ex3_pp0_16[231] = ex3_br_16_sub;
   assign ex3_pp0_16[232:264] = ex3_br_16_out[0:32];

   assign ex3_pp0_17[232] = ex3_hot_one[0];



   assign ex3_pp1_0s[236] = ex3_pp0_01[236];		
   assign ex3_pp1_0s[235] = 0;		
   assign ex3_pp1_0c[234] = ex3_pp0_01[234];		
   assign ex3_pp1_0s[234] = ex3_pp0_00[234];		
   assign ex3_pp1_0c[233] = 0;		
   assign ex3_pp1_0s[233] = ex3_pp0_01[233];		
   assign ex3_pp1_0c[232] = 0;		


   tri_csa32 csa1_0_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_00[232]),		
      .b(ex3_pp0_01[232]),		
      .c(ex3_pp0_17[232]),		
      .sum(ex3_pp1_0s[232]),		
      .car(ex3_pp1_0c[231])		
   );

   tri_csa22 csa1_0_231(
      .a(ex3_pp0_00[231]),		
      .b(ex3_pp0_01[231]),		
      .sum(ex3_pp1_0s[231]),		
      .car(ex3_pp1_0c[230])		
   );

   tri_csa22 csa1_0_230(
      .a(ex3_pp0_00[230]),		
      .b(ex3_pp0_01[230]),		
      .sum(ex3_pp1_0s[230]),		
      .car(ex3_pp1_0c[229])		
   );

   tri_csa22 csa1_0_229(
      .a(ex3_pp0_00[229]),		
      .b(ex3_pp0_01[229]),		
      .sum(ex3_pp1_0s[229]),		
      .car(ex3_pp1_0c[228])		
   );

   tri_csa22 csa1_0_228(
      .a(ex3_pp0_00[228]),		
      .b(ex3_pp0_01[228]),		
      .sum(ex3_pp1_0s[228]),		
      .car(ex3_pp1_0c[227])		
   );

   tri_csa22 csa1_0_227(
      .a(ex3_pp0_00[227]),		
      .b(ex3_pp0_01[227]),		
      .sum(ex3_pp1_0s[227]),		
      .car(ex3_pp1_0c[226])		
   );

   tri_csa22 csa1_0_226(
      .a(ex3_pp0_00[226]),		
      .b(ex3_pp0_01[226]),		
      .sum(ex3_pp1_0s[226]),		
      .car(ex3_pp1_0c[225])		
   );

   tri_csa22 csa1_0_225(
      .a(ex3_pp0_00[225]),		
      .b(ex3_pp0_01[225]),		
      .sum(ex3_pp1_0s[225]),		
      .car(ex3_pp1_0c[224])		
   );

   tri_csa22 csa1_0_224(
      .a(ex3_pp0_00[224]),		
      .b(ex3_pp0_01[224]),		
      .sum(ex3_pp1_0s[224]),		
      .car(ex3_pp1_0c[223])		
   );

   tri_csa22 csa1_0_223(
      .a(ex3_pp0_00[223]),		
      .b(ex3_pp0_01[223]),		
      .sum(ex3_pp1_0s[223]),		
      .car(ex3_pp1_0c[222])		
   );

   tri_csa22 csa1_0_222(
      .a(ex3_pp0_00[222]),		
      .b(ex3_pp0_01[222]),		
      .sum(ex3_pp1_0s[222]),		
      .car(ex3_pp1_0c[221])		
   );

   tri_csa22 csa1_0_221(
      .a(ex3_pp0_00[221]),		
      .b(ex3_pp0_01[221]),		
      .sum(ex3_pp1_0s[221]),		
      .car(ex3_pp1_0c[220])		
   );

   tri_csa22 csa1_0_220(
      .a(ex3_pp0_00[220]),		
      .b(ex3_pp0_01[220]),		
      .sum(ex3_pp1_0s[220]),		
      .car(ex3_pp1_0c[219])		
   );

   tri_csa22 csa1_0_219(
      .a(ex3_pp0_00[219]),		
      .b(ex3_pp0_01[219]),		
      .sum(ex3_pp1_0s[219]),		
      .car(ex3_pp1_0c[218])		
   );

   tri_csa22 csa1_0_218(
      .a(ex3_pp0_00[218]),		
      .b(ex3_pp0_01[218]),		
      .sum(ex3_pp1_0s[218]),		
      .car(ex3_pp1_0c[217])		
   );

   tri_csa22 csa1_0_217(
      .a(ex3_pp0_00[217]),		
      .b(ex3_pp0_01[217]),		
      .sum(ex3_pp1_0s[217]),		
      .car(ex3_pp1_0c[216])		
   );

   tri_csa22 csa1_0_216(
      .a(ex3_pp0_00[216]),		
      .b(ex3_pp0_01[216]),		
      .sum(ex3_pp1_0s[216]),		
      .car(ex3_pp1_0c[215])		
   );

   tri_csa22 csa1_0_215(
      .a(ex3_pp0_00[215]),		
      .b(ex3_pp0_01[215]),		
      .sum(ex3_pp1_0s[215]),		
      .car(ex3_pp1_0c[214])		
   );

   tri_csa22 csa1_0_214(
      .a(ex3_pp0_00[214]),		
      .b(ex3_pp0_01[214]),		
      .sum(ex3_pp1_0s[214]),		
      .car(ex3_pp1_0c[213])		
   );

   tri_csa22 csa1_0_213(
      .a(ex3_pp0_00[213]),		
      .b(ex3_pp0_01[213]),		
      .sum(ex3_pp1_0s[213]),		
      .car(ex3_pp1_0c[212])		
   );

   tri_csa22 csa1_0_212(
      .a(ex3_pp0_00[212]),		
      .b(ex3_pp0_01[212]),		
      .sum(ex3_pp1_0s[212]),		
      .car(ex3_pp1_0c[211])		
   );

   tri_csa22 csa1_0_211(
      .a(ex3_pp0_00[211]),		
      .b(ex3_pp0_01[211]),		
      .sum(ex3_pp1_0s[211]),		
      .car(ex3_pp1_0c[210])		
   );

   tri_csa22 csa1_0_210(
      .a(ex3_pp0_00[210]),		
      .b(ex3_pp0_01[210]),		
      .sum(ex3_pp1_0s[210]),		
      .car(ex3_pp1_0c[209])		
   );

   tri_csa22 csa1_0_209(
      .a(ex3_pp0_00[209]),		
      .b(ex3_pp0_01[209]),		
      .sum(ex3_pp1_0s[209]),		
      .car(ex3_pp1_0c[208])		
   );

   tri_csa22 csa1_0_208(
      .a(ex3_pp0_00[208]),		
      .b(ex3_pp0_01[208]),		
      .sum(ex3_pp1_0s[208]),		
      .car(ex3_pp1_0c[207])		
   );

   tri_csa22 csa1_0_207(
      .a(ex3_pp0_00[207]),		
      .b(ex3_pp0_01[207]),		
      .sum(ex3_pp1_0s[207]),		
      .car(ex3_pp1_0c[206])		
   );

   tri_csa22 csa1_0_206(
      .a(ex3_pp0_00[206]),		
      .b(ex3_pp0_01[206]),		
      .sum(ex3_pp1_0s[206]),		
      .car(ex3_pp1_0c[205])		
   );

   tri_csa22 csa1_0_205(
      .a(ex3_pp0_00[205]),		
      .b(ex3_pp0_01[205]),		
      .sum(ex3_pp1_0s[205]),		
      .car(ex3_pp1_0c[204])		
   );

   tri_csa22 csa1_0_204(
      .a(ex3_pp0_00[204]),		
      .b(ex3_pp0_01[204]),		
      .sum(ex3_pp1_0s[204]),		
      .car(ex3_pp1_0c[203])		
   );

   tri_csa22 csa1_0_203(
      .a(ex3_pp0_00[203]),		
      .b(ex3_pp0_01[203]),		
      .sum(ex3_pp1_0s[203]),		
      .car(ex3_pp1_0c[202])		
   );

   tri_csa22 csa1_0_202(
      .a(ex3_pp0_00[202]),		
      .b(ex3_pp0_01[202]),		
      .sum(ex3_pp1_0s[202]),		
      .car(ex3_pp1_0c[201])		
   );

   tri_csa22 csa1_0_201(
      .a(ex3_pp0_00[201]),		
      .b(ex3_pp0_01[201]),		
      .sum(ex3_pp1_0s[201]),		
      .car(ex3_pp1_0c[200])		
   );

   tri_csa22 csa1_0_200(
      .a(ex3_pp0_00[200]),		
      .b(ex3_pp0_01[200]),		
      .sum(ex3_pp1_0s[200]),		
      .car(ex3_pp1_0c[199])		
   );
   assign ex3_pp1_0s[199] = ex3_pp0_00[199];		
   assign ex3_pp1_0s[198] = ex3_pp0_00[198];		


   assign ex3_pp1_1s[242] = ex3_pp0_04[242];		
   assign ex3_pp1_1s[241] = 0;		
   assign ex3_pp1_1c[240] = ex3_pp0_04[240];		
   assign ex3_pp1_1s[240] = ex3_pp0_03[240];		
   assign ex3_pp1_1c[239] = 0;		
   assign ex3_pp1_1s[239] = ex3_pp0_04[239];		
   assign ex3_pp1_1c[238] = 0;		


   tri_csa32 csa1_1_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[238]),		
      .b(ex3_pp0_03[238]),		
      .c(ex3_pp0_04[238]),		
      .sum(ex3_pp1_1s[238]),		
      .car(ex3_pp1_1c[237])		
   );

   tri_csa22 csa1_1_237(
      .a(ex3_pp0_03[237]),		
      .b(ex3_pp0_04[237]),		
      .sum(ex3_pp1_1s[237]),		
      .car(ex3_pp1_1c[236])		
   );


   tri_csa32 csa1_1_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[236]),		
      .b(ex3_pp0_03[236]),		
      .c(ex3_pp0_04[236]),		
      .sum(ex3_pp1_1s[236]),		
      .car(ex3_pp1_1c[235])		
   );

   tri_csa32 csa1_1_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[235]),		
      .b(ex3_pp0_03[235]),		
      .c(ex3_pp0_04[235]),		
      .sum(ex3_pp1_1s[235]),		
      .car(ex3_pp1_1c[234])		
   );


   tri_csa32 csa1_1_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[234]),		
      .b(ex3_pp0_03[234]),		
      .c(ex3_pp0_04[234]),		
      .sum(ex3_pp1_1s[234]),		
      .car(ex3_pp1_1c[233])		
   );


   tri_csa32 csa1_1_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[233]),		
      .b(ex3_pp0_03[233]),		
      .c(ex3_pp0_04[233]),		
      .sum(ex3_pp1_1s[233]),		
      .car(ex3_pp1_1c[232])		
   );


   tri_csa32 csa1_1_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[232]),		
      .b(ex3_pp0_03[232]),		
      .c(ex3_pp0_04[232]),		
      .sum(ex3_pp1_1s[232]),		
      .car(ex3_pp1_1c[231])		
   );


   tri_csa32 csa1_1_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[231]),		
      .b(ex3_pp0_03[231]),		
      .c(ex3_pp0_04[231]),		
      .sum(ex3_pp1_1s[231]),		
      .car(ex3_pp1_1c[230])		
   );


   tri_csa32 csa1_1_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[230]),		
      .b(ex3_pp0_03[230]),		
      .c(ex3_pp0_04[230]),		
      .sum(ex3_pp1_1s[230]),		
      .car(ex3_pp1_1c[229])		
   );


   tri_csa32 csa1_1_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[229]),		
      .b(ex3_pp0_03[229]),		
      .c(ex3_pp0_04[229]),		
      .sum(ex3_pp1_1s[229]),		
      .car(ex3_pp1_1c[228])		
   );


   tri_csa32 csa1_1_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[228]),		
      .b(ex3_pp0_03[228]),		
      .c(ex3_pp0_04[228]),		
      .sum(ex3_pp1_1s[228]),		
      .car(ex3_pp1_1c[227])		
   );


   tri_csa32 csa1_1_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[227]),		
      .b(ex3_pp0_03[227]),		
      .c(ex3_pp0_04[227]),		
      .sum(ex3_pp1_1s[227]),		
      .car(ex3_pp1_1c[226])		
   );


   tri_csa32 csa1_1_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[226]),		
      .b(ex3_pp0_03[226]),		
      .c(ex3_pp0_04[226]),		
      .sum(ex3_pp1_1s[226]),		
      .car(ex3_pp1_1c[225])		
   );


   tri_csa32 csa1_1_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[225]),		
      .b(ex3_pp0_03[225]),		
      .c(ex3_pp0_04[225]),		
      .sum(ex3_pp1_1s[225]),		
      .car(ex3_pp1_1c[224])		
   );


   tri_csa32 csa1_1_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[224]),		
      .b(ex3_pp0_03[224]),		
      .c(ex3_pp0_04[224]),		
      .sum(ex3_pp1_1s[224]),		
      .car(ex3_pp1_1c[223])		
   );


   tri_csa32 csa1_1_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[223]),		
      .b(ex3_pp0_03[223]),		
      .c(ex3_pp0_04[223]),		
      .sum(ex3_pp1_1s[223]),		
      .car(ex3_pp1_1c[222])		
   );


   tri_csa32 csa1_1_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[222]),		
      .b(ex3_pp0_03[222]),		
      .c(ex3_pp0_04[222]),		
      .sum(ex3_pp1_1s[222]),		
      .car(ex3_pp1_1c[221])		
   );


   tri_csa32 csa1_1_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[221]),		
      .b(ex3_pp0_03[221]),		
      .c(ex3_pp0_04[221]),		
      .sum(ex3_pp1_1s[221]),		
      .car(ex3_pp1_1c[220])		
   );


   tri_csa32 csa1_1_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[220]),		
      .b(ex3_pp0_03[220]),		
      .c(ex3_pp0_04[220]),		
      .sum(ex3_pp1_1s[220]),		
      .car(ex3_pp1_1c[219])		
   );


   tri_csa32 csa1_1_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[219]),		
      .b(ex3_pp0_03[219]),		
      .c(ex3_pp0_04[219]),		
      .sum(ex3_pp1_1s[219]),		
      .car(ex3_pp1_1c[218])		
   );


   tri_csa32 csa1_1_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[218]),		
      .b(ex3_pp0_03[218]),		
      .c(ex3_pp0_04[218]),		
      .sum(ex3_pp1_1s[218]),		
      .car(ex3_pp1_1c[217])		
   );


   tri_csa32 csa1_1_217(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[217]),		
      .b(ex3_pp0_03[217]),		
      .c(ex3_pp0_04[217]),		
      .sum(ex3_pp1_1s[217]),		
      .car(ex3_pp1_1c[216])		
   );


   tri_csa32 csa1_1_216(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[216]),		
      .b(ex3_pp0_03[216]),		
      .c(ex3_pp0_04[216]),		
      .sum(ex3_pp1_1s[216]),		
      .car(ex3_pp1_1c[215])		
   );


   tri_csa32 csa1_1_215(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[215]),		
      .b(ex3_pp0_03[215]),		
      .c(ex3_pp0_04[215]),		
      .sum(ex3_pp1_1s[215]),		
      .car(ex3_pp1_1c[214])		
   );


   tri_csa32 csa1_1_214(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[214]),		
      .b(ex3_pp0_03[214]),		
      .c(ex3_pp0_04[214]),		
      .sum(ex3_pp1_1s[214]),		
      .car(ex3_pp1_1c[213])		
   );


   tri_csa32 csa1_1_213(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[213]),		
      .b(ex3_pp0_03[213]),		
      .c(ex3_pp0_04[213]),		
      .sum(ex3_pp1_1s[213]),		
      .car(ex3_pp1_1c[212])		
   );


   tri_csa32 csa1_1_212(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[212]),		
      .b(ex3_pp0_03[212]),		
      .c(ex3_pp0_04[212]),		
      .sum(ex3_pp1_1s[212]),		
      .car(ex3_pp1_1c[211])		
   );


   tri_csa32 csa1_1_211(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[211]),		
      .b(ex3_pp0_03[211]),		
      .c(ex3_pp0_04[211]),		
      .sum(ex3_pp1_1s[211]),		
      .car(ex3_pp1_1c[210])		
   );


   tri_csa32 csa1_1_210(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[210]),		
      .b(ex3_pp0_03[210]),		
      .c(ex3_pp0_04[210]),		
      .sum(ex3_pp1_1s[210]),		
      .car(ex3_pp1_1c[209])		
   );


   tri_csa32 csa1_1_209(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[209]),		
      .b(ex3_pp0_03[209]),		
      .c(ex3_pp0_04[209]),		
      .sum(ex3_pp1_1s[209]),		
      .car(ex3_pp1_1c[208])		
   );


   tri_csa32 csa1_1_208(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[208]),		
      .b(ex3_pp0_03[208]),		
      .c(ex3_pp0_04[208]),		
      .sum(ex3_pp1_1s[208]),		
      .car(ex3_pp1_1c[207])		
   );


   tri_csa32 csa1_1_207(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[207]),		
      .b(ex3_pp0_03[207]),		
      .c(ex3_pp0_04[207]),		
      .sum(ex3_pp1_1s[207]),		
      .car(ex3_pp1_1c[206])		
   );


   tri_csa32 csa1_1_206(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[206]),		
      .b(ex3_pp0_03[206]),		
      .c(ex3_pp0_04[206]),		
      .sum(ex3_pp1_1s[206]),		
      .car(ex3_pp1_1c[205])		
   );

   tri_csa22 csa1_1_205(
      .a(ex3_pp0_02[205]),		
      .b(ex3_pp0_03[205]),		
      .sum(ex3_pp1_1s[205]),		
      .car(ex3_pp1_1c[204])		
   );

   tri_csa22 csa1_1_204(
      .a(ex3_pp0_02[204]),		
      .b(ex3_pp0_03[204]),		
      .sum(ex3_pp1_1s[204]),		
      .car(ex3_pp1_1c[203])		
   );
   assign ex3_pp1_1s[203] = ex3_pp0_02[203];		
   assign ex3_pp1_1s[202] = ex3_pp0_02[202];		


   assign ex3_pp1_2s[248] = ex3_pp0_07[248];		
   assign ex3_pp1_2s[247] = 0;		
   assign ex3_pp1_2c[246] = ex3_pp0_07[246];		
   assign ex3_pp1_2s[246] = ex3_pp0_06[246];		
   assign ex3_pp1_2c[245] = 0;		
   assign ex3_pp1_2s[245] = ex3_pp0_07[245];		
   assign ex3_pp1_2c[244] = 0;		


   tri_csa32 csa1_2_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[244]),		
      .b(ex3_pp0_06[244]),		
      .c(ex3_pp0_07[244]),		
      .sum(ex3_pp1_2s[244]),		
      .car(ex3_pp1_2c[243])		
   );

   tri_csa22 csa1_2_243(
      .a(ex3_pp0_06[243]),		
      .b(ex3_pp0_07[243]),		
      .sum(ex3_pp1_2s[243]),		
      .car(ex3_pp1_2c[242])		
   );


   tri_csa32 csa1_2_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[242]),		
      .b(ex3_pp0_06[242]),		
      .c(ex3_pp0_07[242]),		
      .sum(ex3_pp1_2s[242]),		
      .car(ex3_pp1_2c[241])		
   );


   tri_csa32 csa1_2_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[241]),		
      .b(ex3_pp0_06[241]),		
      .c(ex3_pp0_07[241]),		
      .sum(ex3_pp1_2s[241]),		
      .car(ex3_pp1_2c[240])		
   );


   tri_csa32 csa1_2_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[240]),		
      .b(ex3_pp0_06[240]),		
      .c(ex3_pp0_07[240]),		
      .sum(ex3_pp1_2s[240]),		
      .car(ex3_pp1_2c[239])		
   );


   tri_csa32 csa1_2_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[239]),		
      .b(ex3_pp0_06[239]),		
      .c(ex3_pp0_07[239]),		
      .sum(ex3_pp1_2s[239]),		
      .car(ex3_pp1_2c[238])		
   );


   tri_csa32 csa1_2_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[238]),		
      .b(ex3_pp0_06[238]),		
      .c(ex3_pp0_07[238]),		
      .sum(ex3_pp1_2s[238]),		
      .car(ex3_pp1_2c[237])		
   );


   tri_csa32 csa1_2_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[237]),		
      .b(ex3_pp0_06[237]),		
      .c(ex3_pp0_07[237]),		
      .sum(ex3_pp1_2s[237]),		
      .car(ex3_pp1_2c[236])		
   );


   tri_csa32 csa1_2_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[236]),		
      .b(ex3_pp0_06[236]),		
      .c(ex3_pp0_07[236]),		
      .sum(ex3_pp1_2s[236]),		
      .car(ex3_pp1_2c[235])		
   );


   tri_csa32 csa1_2_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[235]),		
      .b(ex3_pp0_06[235]),		
      .c(ex3_pp0_07[235]),		
      .sum(ex3_pp1_2s[235]),		
      .car(ex3_pp1_2c[234])		
   );


   tri_csa32 csa1_2_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[234]),		
      .b(ex3_pp0_06[234]),		
      .c(ex3_pp0_07[234]),		
      .sum(ex3_pp1_2s[234]),		
      .car(ex3_pp1_2c[233])		
   );


   tri_csa32 csa1_2_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[233]),		
      .b(ex3_pp0_06[233]),		
      .c(ex3_pp0_07[233]),		
      .sum(ex3_pp1_2s[233]),		
      .car(ex3_pp1_2c[232])		
   );


   tri_csa32 csa1_2_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[232]),		
      .b(ex3_pp0_06[232]),		
      .c(ex3_pp0_07[232]),		
      .sum(ex3_pp1_2s[232]),		
      .car(ex3_pp1_2c[231])		
   );


   tri_csa32 csa1_2_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[231]),		
      .b(ex3_pp0_06[231]),		
      .c(ex3_pp0_07[231]),		
      .sum(ex3_pp1_2s[231]),		
      .car(ex3_pp1_2c[230])		
   );


   tri_csa32 csa1_2_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[230]),		
      .b(ex3_pp0_06[230]),		
      .c(ex3_pp0_07[230]),		
      .sum(ex3_pp1_2s[230]),		
      .car(ex3_pp1_2c[229])		
   );


   tri_csa32 csa1_2_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[229]),		
      .b(ex3_pp0_06[229]),		
      .c(ex3_pp0_07[229]),		
      .sum(ex3_pp1_2s[229]),		
      .car(ex3_pp1_2c[228])		
   );


   tri_csa32 csa1_2_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[228]),		
      .b(ex3_pp0_06[228]),		
      .c(ex3_pp0_07[228]),		
      .sum(ex3_pp1_2s[228]),		
      .car(ex3_pp1_2c[227])		
   );


   tri_csa32 csa1_2_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[227]),		
      .b(ex3_pp0_06[227]),		
      .c(ex3_pp0_07[227]),		
      .sum(ex3_pp1_2s[227]),		
      .car(ex3_pp1_2c[226])		
   );


   tri_csa32 csa1_2_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[226]),		
      .b(ex3_pp0_06[226]),		
      .c(ex3_pp0_07[226]),		
      .sum(ex3_pp1_2s[226]),		
      .car(ex3_pp1_2c[225])		
   );


   tri_csa32 csa1_2_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[225]),		
      .b(ex3_pp0_06[225]),		
      .c(ex3_pp0_07[225]),		
      .sum(ex3_pp1_2s[225]),		
      .car(ex3_pp1_2c[224])		
   );


   tri_csa32 csa1_2_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[224]),		
      .b(ex3_pp0_06[224]),		
      .c(ex3_pp0_07[224]),		
      .sum(ex3_pp1_2s[224]),		
      .car(ex3_pp1_2c[223])		
   );


   tri_csa32 csa1_2_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[223]),		
      .b(ex3_pp0_06[223]),		
      .c(ex3_pp0_07[223]),		
      .sum(ex3_pp1_2s[223]),		
      .car(ex3_pp1_2c[222])		
   );


   tri_csa32 csa1_2_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[222]),		
      .b(ex3_pp0_06[222]),		
      .c(ex3_pp0_07[222]),		
      .sum(ex3_pp1_2s[222]),		
      .car(ex3_pp1_2c[221])		
   );


   tri_csa32 csa1_2_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[221]),		
      .b(ex3_pp0_06[221]),		
      .c(ex3_pp0_07[221]),		
      .sum(ex3_pp1_2s[221]),		
      .car(ex3_pp1_2c[220])		
   );


   tri_csa32 csa1_2_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[220]),		
      .b(ex3_pp0_06[220]),		
      .c(ex3_pp0_07[220]),		
      .sum(ex3_pp1_2s[220]),		
      .car(ex3_pp1_2c[219])		
   );


   tri_csa32 csa1_2_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[219]),		
      .b(ex3_pp0_06[219]),		
      .c(ex3_pp0_07[219]),		
      .sum(ex3_pp1_2s[219]),		
      .car(ex3_pp1_2c[218])		
   );


   tri_csa32 csa1_2_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[218]),		
      .b(ex3_pp0_06[218]),		
      .c(ex3_pp0_07[218]),		
      .sum(ex3_pp1_2s[218]),		
      .car(ex3_pp1_2c[217])		
   );


   tri_csa32 csa1_2_217(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[217]),		
      .b(ex3_pp0_06[217]),		
      .c(ex3_pp0_07[217]),		
      .sum(ex3_pp1_2s[217]),		
      .car(ex3_pp1_2c[216])		
   );


   tri_csa32 csa1_2_216(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[216]),		
      .b(ex3_pp0_06[216]),		
      .c(ex3_pp0_07[216]),		
      .sum(ex3_pp1_2s[216]),		
      .car(ex3_pp1_2c[215])		
   );


   tri_csa32 csa1_2_215(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[215]),		
      .b(ex3_pp0_06[215]),		
      .c(ex3_pp0_07[215]),		
      .sum(ex3_pp1_2s[215]),		
      .car(ex3_pp1_2c[214])		
   );


   tri_csa32 csa1_2_214(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[214]),		
      .b(ex3_pp0_06[214]),		
      .c(ex3_pp0_07[214]),		
      .sum(ex3_pp1_2s[214]),		
      .car(ex3_pp1_2c[213])		
   );


   tri_csa32 csa1_2_213(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[213]),		
      .b(ex3_pp0_06[213]),		
      .c(ex3_pp0_07[213]),		
      .sum(ex3_pp1_2s[213]),		
      .car(ex3_pp1_2c[212])		
   );


   tri_csa32 csa1_2_212(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[212]),		
      .b(ex3_pp0_06[212]),		
      .c(ex3_pp0_07[212]),		
      .sum(ex3_pp1_2s[212]),		
      .car(ex3_pp1_2c[211])		
   );

   tri_csa22 csa1_2_211(
      .a(ex3_pp0_05[211]),		
      .b(ex3_pp0_06[211]),		
      .sum(ex3_pp1_2s[211]),		
      .car(ex3_pp1_2c[210])		
   );

   tri_csa22 csa1_2_210(
      .a(ex3_pp0_05[210]),		
      .b(ex3_pp0_06[210]),		
      .sum(ex3_pp1_2s[210]),		
      .car(ex3_pp1_2c[209])		
   );
   assign ex3_pp1_2s[209] = ex3_pp0_05[209];		
   assign ex3_pp1_2s[208] = ex3_pp0_05[208];		


   assign ex3_pp1_3s[254] = ex3_pp0_10[254];		
   assign ex3_pp1_3s[253] = 0;		
   assign ex3_pp1_3c[252] = ex3_pp0_10[252];		
   assign ex3_pp1_3s[252] = ex3_pp0_09[252];		
   assign ex3_pp1_3c[251] = 0;		
   assign ex3_pp1_3s[251] = ex3_pp0_10[251];		
   assign ex3_pp1_3c[250] = 0;		


   tri_csa32 csa1_3_250(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[250]),		
      .b(ex3_pp0_09[250]),		
      .c(ex3_pp0_10[250]),		
      .sum(ex3_pp1_3s[250]),		
      .car(ex3_pp1_3c[249])		
   );

   tri_csa22 csa1_3_249(
      .a(ex3_pp0_09[249]),		
      .b(ex3_pp0_10[249]),		
      .sum(ex3_pp1_3s[249]),		
      .car(ex3_pp1_3c[248])		
   );


   tri_csa32 csa1_3_248(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[248]),		
      .b(ex3_pp0_09[248]),		
      .c(ex3_pp0_10[248]),		
      .sum(ex3_pp1_3s[248]),		
      .car(ex3_pp1_3c[247])		
   );


   tri_csa32 csa1_3_247(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[247]),		
      .b(ex3_pp0_09[247]),		
      .c(ex3_pp0_10[247]),		
      .sum(ex3_pp1_3s[247]),		
      .car(ex3_pp1_3c[246])		
   );


   tri_csa32 csa1_3_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[246]),		
      .b(ex3_pp0_09[246]),		
      .c(ex3_pp0_10[246]),		
      .sum(ex3_pp1_3s[246]),		
      .car(ex3_pp1_3c[245])		
   );


   tri_csa32 csa1_3_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[245]),		
      .b(ex3_pp0_09[245]),		
      .c(ex3_pp0_10[245]),		
      .sum(ex3_pp1_3s[245]),		
      .car(ex3_pp1_3c[244])		
   );


   tri_csa32 csa1_3_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[244]),		
      .b(ex3_pp0_09[244]),		
      .c(ex3_pp0_10[244]),		
      .sum(ex3_pp1_3s[244]),		
      .car(ex3_pp1_3c[243])		
   );


   tri_csa32 csa1_3_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[243]),		
      .b(ex3_pp0_09[243]),		
      .c(ex3_pp0_10[243]),		
      .sum(ex3_pp1_3s[243]),		
      .car(ex3_pp1_3c[242])		
   );


   tri_csa32 csa1_3_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[242]),		
      .b(ex3_pp0_09[242]),		
      .c(ex3_pp0_10[242]),		
      .sum(ex3_pp1_3s[242]),		
      .car(ex3_pp1_3c[241])		
   );


   tri_csa32 csa1_3_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[241]),		
      .b(ex3_pp0_09[241]),		
      .c(ex3_pp0_10[241]),		
      .sum(ex3_pp1_3s[241]),		
      .car(ex3_pp1_3c[240])		
   );


   tri_csa32 csa1_3_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[240]),		
      .b(ex3_pp0_09[240]),		
      .c(ex3_pp0_10[240]),		
      .sum(ex3_pp1_3s[240]),		
      .car(ex3_pp1_3c[239])		
   );


   tri_csa32 csa1_3_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[239]),		
      .b(ex3_pp0_09[239]),		
      .c(ex3_pp0_10[239]),		
      .sum(ex3_pp1_3s[239]),		
      .car(ex3_pp1_3c[238])		
   );


   tri_csa32 csa1_3_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[238]),		
      .b(ex3_pp0_09[238]),		
      .c(ex3_pp0_10[238]),		
      .sum(ex3_pp1_3s[238]),		
      .car(ex3_pp1_3c[237])		
   );


   tri_csa32 csa1_3_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[237]),		
      .b(ex3_pp0_09[237]),		
      .c(ex3_pp0_10[237]),		
      .sum(ex3_pp1_3s[237]),		
      .car(ex3_pp1_3c[236])		
   );


   tri_csa32 csa1_3_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[236]),		
      .b(ex3_pp0_09[236]),		
      .c(ex3_pp0_10[236]),		
      .sum(ex3_pp1_3s[236]),		
      .car(ex3_pp1_3c[235])		
   );


   tri_csa32 csa1_3_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[235]),		
      .b(ex3_pp0_09[235]),		
      .c(ex3_pp0_10[235]),		
      .sum(ex3_pp1_3s[235]),		
      .car(ex3_pp1_3c[234])		
   );


   tri_csa32 csa1_3_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[234]),		
      .b(ex3_pp0_09[234]),		
      .c(ex3_pp0_10[234]),		
      .sum(ex3_pp1_3s[234]),		
      .car(ex3_pp1_3c[233])		
   );


   tri_csa32 csa1_3_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[233]),		
      .b(ex3_pp0_09[233]),		
      .c(ex3_pp0_10[233]),		
      .sum(ex3_pp1_3s[233]),		
      .car(ex3_pp1_3c[232])		
   );


   tri_csa32 csa1_3_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[232]),		
      .b(ex3_pp0_09[232]),		
      .c(ex3_pp0_10[232]),		
      .sum(ex3_pp1_3s[232]),		
      .car(ex3_pp1_3c[231])		
   );


   tri_csa32 csa1_3_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[231]),		
      .b(ex3_pp0_09[231]),		
      .c(ex3_pp0_10[231]),		
      .sum(ex3_pp1_3s[231]),		
      .car(ex3_pp1_3c[230])		
   );


   tri_csa32 csa1_3_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[230]),		
      .b(ex3_pp0_09[230]),		
      .c(ex3_pp0_10[230]),		
      .sum(ex3_pp1_3s[230]),		
      .car(ex3_pp1_3c[229])		
   );


   tri_csa32 csa1_3_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[229]),		
      .b(ex3_pp0_09[229]),		
      .c(ex3_pp0_10[229]),		
      .sum(ex3_pp1_3s[229]),		
      .car(ex3_pp1_3c[228])		
   );


   tri_csa32 csa1_3_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[228]),		
      .b(ex3_pp0_09[228]),		
      .c(ex3_pp0_10[228]),		
      .sum(ex3_pp1_3s[228]),		
      .car(ex3_pp1_3c[227])		
   );


   tri_csa32 csa1_3_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[227]),		
      .b(ex3_pp0_09[227]),		
      .c(ex3_pp0_10[227]),		
      .sum(ex3_pp1_3s[227]),		
      .car(ex3_pp1_3c[226])		
   );


   tri_csa32 csa1_3_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[226]),		
      .b(ex3_pp0_09[226]),		
      .c(ex3_pp0_10[226]),		
      .sum(ex3_pp1_3s[226]),		
      .car(ex3_pp1_3c[225])		
   );


   tri_csa32 csa1_3_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[225]),		
      .b(ex3_pp0_09[225]),		
      .c(ex3_pp0_10[225]),		
      .sum(ex3_pp1_3s[225]),		
      .car(ex3_pp1_3c[224])		
   );


   tri_csa32 csa1_3_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[224]),		
      .b(ex3_pp0_09[224]),		
      .c(ex3_pp0_10[224]),		
      .sum(ex3_pp1_3s[224]),		
      .car(ex3_pp1_3c[223])		
   );


   tri_csa32 csa1_3_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[223]),		
      .b(ex3_pp0_09[223]),		
      .c(ex3_pp0_10[223]),		
      .sum(ex3_pp1_3s[223]),		
      .car(ex3_pp1_3c[222])		
   );


   tri_csa32 csa1_3_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[222]),		
      .b(ex3_pp0_09[222]),		
      .c(ex3_pp0_10[222]),		
      .sum(ex3_pp1_3s[222]),		
      .car(ex3_pp1_3c[221])		
   );


   tri_csa32 csa1_3_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[221]),		
      .b(ex3_pp0_09[221]),		
      .c(ex3_pp0_10[221]),		
      .sum(ex3_pp1_3s[221]),		
      .car(ex3_pp1_3c[220])		
   );


   tri_csa32 csa1_3_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[220]),		
      .b(ex3_pp0_09[220]),		
      .c(ex3_pp0_10[220]),		
      .sum(ex3_pp1_3s[220]),		
      .car(ex3_pp1_3c[219])		
   );


   tri_csa32 csa1_3_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[219]),		
      .b(ex3_pp0_09[219]),		
      .c(ex3_pp0_10[219]),		
      .sum(ex3_pp1_3s[219]),		
      .car(ex3_pp1_3c[218])		
   );


   tri_csa32 csa1_3_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[218]),		
      .b(ex3_pp0_09[218]),		
      .c(ex3_pp0_10[218]),		
      .sum(ex3_pp1_3s[218]),		
      .car(ex3_pp1_3c[217])		
   );

   tri_csa22 csa1_3_217(
      .a(ex3_pp0_08[217]),		
      .b(ex3_pp0_09[217]),		
      .sum(ex3_pp1_3s[217]),		
      .car(ex3_pp1_3c[216])		
   );

   tri_csa22 csa1_3_216(
      .a(ex3_pp0_08[216]),		
      .b(ex3_pp0_09[216]),		
      .sum(ex3_pp1_3s[216]),		
      .car(ex3_pp1_3c[215])		
   );
   assign ex3_pp1_3s[215] = ex3_pp0_08[215];		
   assign ex3_pp1_3s[214] = ex3_pp0_08[214];		


   assign ex3_pp1_4s[260] = ex3_pp0_13[260];		
   assign ex3_pp1_4s[259] = 0;		
   assign ex3_pp1_4c[258] = ex3_pp0_13[258];		
   assign ex3_pp1_4s[258] = ex3_pp0_12[258];		
   assign ex3_pp1_4c[257] = 0;		
   assign ex3_pp1_4s[257] = ex3_pp0_13[257];		
   assign ex3_pp1_4c[256] = 0;		


   tri_csa32 csa1_4_256(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[256]),		
      .b(ex3_pp0_12[256]),		
      .c(ex3_pp0_13[256]),		
      .sum(ex3_pp1_4s[256]),		
      .car(ex3_pp1_4c[255])		
   );

   tri_csa22 csa1_4_255(
      .a(ex3_pp0_12[255]),		
      .b(ex3_pp0_13[255]),		
      .sum(ex3_pp1_4s[255]),		
      .car(ex3_pp1_4c[254])		
   );


   tri_csa32 csa1_4_254(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[254]),		
      .b(ex3_pp0_12[254]),		
      .c(ex3_pp0_13[254]),		
      .sum(ex3_pp1_4s[254]),		
      .car(ex3_pp1_4c[253])		
   );


   tri_csa32 csa1_4_253(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[253]),		
      .b(ex3_pp0_12[253]),		
      .c(ex3_pp0_13[253]),		
      .sum(ex3_pp1_4s[253]),		
      .car(ex3_pp1_4c[252])		
   );


   tri_csa32 csa1_4_252(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[252]),		
      .b(ex3_pp0_12[252]),		
      .c(ex3_pp0_13[252]),		
      .sum(ex3_pp1_4s[252]),		
      .car(ex3_pp1_4c[251])		
   );


   tri_csa32 csa1_4_251(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[251]),		
      .b(ex3_pp0_12[251]),		
      .c(ex3_pp0_13[251]),		
      .sum(ex3_pp1_4s[251]),		
      .car(ex3_pp1_4c[250])		
   );


   tri_csa32 csa1_4_250(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[250]),		
      .b(ex3_pp0_12[250]),		
      .c(ex3_pp0_13[250]),		
      .sum(ex3_pp1_4s[250]),		
      .car(ex3_pp1_4c[249])		
   );


   tri_csa32 csa1_4_249(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[249]),		
      .b(ex3_pp0_12[249]),		
      .c(ex3_pp0_13[249]),		
      .sum(ex3_pp1_4s[249]),		
      .car(ex3_pp1_4c[248])		
   );


   tri_csa32 csa1_4_248(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[248]),		
      .b(ex3_pp0_12[248]),		
      .c(ex3_pp0_13[248]),		
      .sum(ex3_pp1_4s[248]),		
      .car(ex3_pp1_4c[247])		
   );


   tri_csa32 csa1_4_247(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[247]),		
      .b(ex3_pp0_12[247]),		
      .c(ex3_pp0_13[247]),		
      .sum(ex3_pp1_4s[247]),		
      .car(ex3_pp1_4c[246])		
   );


   tri_csa32 csa1_4_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[246]),		
      .b(ex3_pp0_12[246]),		
      .c(ex3_pp0_13[246]),		
      .sum(ex3_pp1_4s[246]),		
      .car(ex3_pp1_4c[245])		
   );


   tri_csa32 csa1_4_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[245]),		
      .b(ex3_pp0_12[245]),		
      .c(ex3_pp0_13[245]),		
      .sum(ex3_pp1_4s[245]),		
      .car(ex3_pp1_4c[244])		
   );


   tri_csa32 csa1_4_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[244]),		
      .b(ex3_pp0_12[244]),		
      .c(ex3_pp0_13[244]),		
      .sum(ex3_pp1_4s[244]),		
      .car(ex3_pp1_4c[243])		
   );


   tri_csa32 csa1_4_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[243]),		
      .b(ex3_pp0_12[243]),		
      .c(ex3_pp0_13[243]),		
      .sum(ex3_pp1_4s[243]),		
      .car(ex3_pp1_4c[242])		
   );


   tri_csa32 csa1_4_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[242]),		
      .b(ex3_pp0_12[242]),		
      .c(ex3_pp0_13[242]),		
      .sum(ex3_pp1_4s[242]),		
      .car(ex3_pp1_4c[241])		
   );


   tri_csa32 csa1_4_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[241]),		
      .b(ex3_pp0_12[241]),		
      .c(ex3_pp0_13[241]),		
      .sum(ex3_pp1_4s[241]),		
      .car(ex3_pp1_4c[240])		
   );


   tri_csa32 csa1_4_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[240]),		
      .b(ex3_pp0_12[240]),		
      .c(ex3_pp0_13[240]),		
      .sum(ex3_pp1_4s[240]),		
      .car(ex3_pp1_4c[239])		
   );


   tri_csa32 csa1_4_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[239]),		
      .b(ex3_pp0_12[239]),		
      .c(ex3_pp0_13[239]),		
      .sum(ex3_pp1_4s[239]),		
      .car(ex3_pp1_4c[238])		
   );


   tri_csa32 csa1_4_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[238]),		
      .b(ex3_pp0_12[238]),		
      .c(ex3_pp0_13[238]),		
      .sum(ex3_pp1_4s[238]),		
      .car(ex3_pp1_4c[237])		
   );


   tri_csa32 csa1_4_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[237]),		
      .b(ex3_pp0_12[237]),		
      .c(ex3_pp0_13[237]),		
      .sum(ex3_pp1_4s[237]),		
      .car(ex3_pp1_4c[236])		
   );


   tri_csa32 csa1_4_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[236]),		
      .b(ex3_pp0_12[236]),		
      .c(ex3_pp0_13[236]),		
      .sum(ex3_pp1_4s[236]),		
      .car(ex3_pp1_4c[235])		
   );


   tri_csa32 csa1_4_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[235]),		
      .b(ex3_pp0_12[235]),		
      .c(ex3_pp0_13[235]),		
      .sum(ex3_pp1_4s[235]),		
      .car(ex3_pp1_4c[234])		
   );


   tri_csa32 csa1_4_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[234]),		
      .b(ex3_pp0_12[234]),		
      .c(ex3_pp0_13[234]),		
      .sum(ex3_pp1_4s[234]),		
      .car(ex3_pp1_4c[233])		
   );


   tri_csa32 csa1_4_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[233]),		
      .b(ex3_pp0_12[233]),		
      .c(ex3_pp0_13[233]),		
      .sum(ex3_pp1_4s[233]),		
      .car(ex3_pp1_4c[232])		
   );


   tri_csa32 csa1_4_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[232]),		
      .b(ex3_pp0_12[232]),		
      .c(ex3_pp0_13[232]),		
      .sum(ex3_pp1_4s[232]),		
      .car(ex3_pp1_4c[231])		
   );


   tri_csa32 csa1_4_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[231]),		
      .b(ex3_pp0_12[231]),		
      .c(ex3_pp0_13[231]),		
      .sum(ex3_pp1_4s[231]),		
      .car(ex3_pp1_4c[230])		
   );


   tri_csa32 csa1_4_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[230]),		
      .b(ex3_pp0_12[230]),		
      .c(ex3_pp0_13[230]),		
      .sum(ex3_pp1_4s[230]),		
      .car(ex3_pp1_4c[229])		
   );


   tri_csa32 csa1_4_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[229]),		
      .b(ex3_pp0_12[229]),		
      .c(ex3_pp0_13[229]),		
      .sum(ex3_pp1_4s[229]),		
      .car(ex3_pp1_4c[228])		
   );


   tri_csa32 csa1_4_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[228]),		
      .b(ex3_pp0_12[228]),		
      .c(ex3_pp0_13[228]),		
      .sum(ex3_pp1_4s[228]),		
      .car(ex3_pp1_4c[227])		
   );


   tri_csa32 csa1_4_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[227]),		
      .b(ex3_pp0_12[227]),		
      .c(ex3_pp0_13[227]),		
      .sum(ex3_pp1_4s[227]),		
      .car(ex3_pp1_4c[226])		
   );


   tri_csa32 csa1_4_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[226]),		
      .b(ex3_pp0_12[226]),		
      .c(ex3_pp0_13[226]),		
      .sum(ex3_pp1_4s[226]),		
      .car(ex3_pp1_4c[225])		
   );


   tri_csa32 csa1_4_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[225]),		
      .b(ex3_pp0_12[225]),		
      .c(ex3_pp0_13[225]),		
      .sum(ex3_pp1_4s[225]),		
      .car(ex3_pp1_4c[224])		
   );


   tri_csa32 csa1_4_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[224]),		
      .b(ex3_pp0_12[224]),		
      .c(ex3_pp0_13[224]),		
      .sum(ex3_pp1_4s[224]),		
      .car(ex3_pp1_4c[223])		
   );

   tri_csa22 csa1_4_223(
      .a(ex3_pp0_11[223]),		
      .b(ex3_pp0_12[223]),		
      .sum(ex3_pp1_4s[223]),		
      .car(ex3_pp1_4c[222])		
   );

   tri_csa22 csa1_4_222(
      .a(ex3_pp0_11[222]),		
      .b(ex3_pp0_12[222]),		
      .sum(ex3_pp1_4s[222]),		
      .car(ex3_pp1_4c[221])		
   );
   assign ex3_pp1_4s[221] = ex3_pp0_11[221];		
   assign ex3_pp1_4s[220] = ex3_pp0_11[220];		


   assign ex3_pp1_5c[264] = ex3_pp0_16[264];		
   assign ex3_pp1_5s[264] = ex3_pp0_15[264];		
   assign ex3_pp1_5c[263] = 0;		
   assign ex3_pp1_5s[263] = ex3_pp0_16[263];		
   assign ex3_pp1_5c[262] = 0;		


   tri_csa32 csa1_5_262(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[262]),		
      .b(ex3_pp0_15[262]),		
      .c(ex3_pp0_16[262]),		
      .sum(ex3_pp1_5s[262]),		
      .car(ex3_pp1_5c[261])		
   );

   tri_csa22 csa1_5_261(
      .a(ex3_pp0_15[261]),		
      .b(ex3_pp0_16[261]),		
      .sum(ex3_pp1_5s[261]),		
      .car(ex3_pp1_5c[260])		
   );

   tri_csa32 csa1_5_260(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[260]),		
      .b(ex3_pp0_15[260]),		
      .c(ex3_pp0_16[260]),		
      .sum(ex3_pp1_5s[260]),		
      .car(ex3_pp1_5c[259])		
   );


   tri_csa32 csa1_5_259(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[259]),		
      .b(ex3_pp0_15[259]),		
      .c(ex3_pp0_16[259]),		
      .sum(ex3_pp1_5s[259]),		
      .car(ex3_pp1_5c[258])		
   );


   tri_csa32 csa1_5_258(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[258]),		
      .b(ex3_pp0_15[258]),		
      .c(ex3_pp0_16[258]),		
      .sum(ex3_pp1_5s[258]),		
      .car(ex3_pp1_5c[257])		
   );


   tri_csa32 csa1_5_257(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[257]),		
      .b(ex3_pp0_15[257]),		
      .c(ex3_pp0_16[257]),		
      .sum(ex3_pp1_5s[257]),		
      .car(ex3_pp1_5c[256])		
   );


   tri_csa32 csa1_5_256(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[256]),		
      .b(ex3_pp0_15[256]),		
      .c(ex3_pp0_16[256]),		
      .sum(ex3_pp1_5s[256]),		
      .car(ex3_pp1_5c[255])		
   );


   tri_csa32 csa1_5_255(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[255]),		
      .b(ex3_pp0_15[255]),		
      .c(ex3_pp0_16[255]),		
      .sum(ex3_pp1_5s[255]),		
      .car(ex3_pp1_5c[254])		
   );


   tri_csa32 csa1_5_254(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[254]),		
      .b(ex3_pp0_15[254]),		
      .c(ex3_pp0_16[254]),		
      .sum(ex3_pp1_5s[254]),		
      .car(ex3_pp1_5c[253])		
   );


   tri_csa32 csa1_5_253(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[253]),		
      .b(ex3_pp0_15[253]),		
      .c(ex3_pp0_16[253]),		
      .sum(ex3_pp1_5s[253]),		
      .car(ex3_pp1_5c[252])		
   );


   tri_csa32 csa1_5_252(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[252]),		
      .b(ex3_pp0_15[252]),		
      .c(ex3_pp0_16[252]),		
      .sum(ex3_pp1_5s[252]),		
      .car(ex3_pp1_5c[251])		
   );


   tri_csa32 csa1_5_251(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[251]),		
      .b(ex3_pp0_15[251]),		
      .c(ex3_pp0_16[251]),		
      .sum(ex3_pp1_5s[251]),		
      .car(ex3_pp1_5c[250])		
   );


   tri_csa32 csa1_5_250(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[250]),		
      .b(ex3_pp0_15[250]),		
      .c(ex3_pp0_16[250]),		
      .sum(ex3_pp1_5s[250]),		
      .car(ex3_pp1_5c[249])		
   );


   tri_csa32 csa1_5_249(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[249]),		
      .b(ex3_pp0_15[249]),		
      .c(ex3_pp0_16[249]),		
      .sum(ex3_pp1_5s[249]),		
      .car(ex3_pp1_5c[248])		
   );


   tri_csa32 csa1_5_248(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[248]),		
      .b(ex3_pp0_15[248]),		
      .c(ex3_pp0_16[248]),		
      .sum(ex3_pp1_5s[248]),		
      .car(ex3_pp1_5c[247])		
   );


   tri_csa32 csa1_5_247(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[247]),		
      .b(ex3_pp0_15[247]),		
      .c(ex3_pp0_16[247]),		
      .sum(ex3_pp1_5s[247]),		
      .car(ex3_pp1_5c[246])		
   );


   tri_csa32 csa1_5_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[246]),		
      .b(ex3_pp0_15[246]),		
      .c(ex3_pp0_16[246]),		
      .sum(ex3_pp1_5s[246]),		
      .car(ex3_pp1_5c[245])		
   );


   tri_csa32 csa1_5_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[245]),		
      .b(ex3_pp0_15[245]),		
      .c(ex3_pp0_16[245]),		
      .sum(ex3_pp1_5s[245]),		
      .car(ex3_pp1_5c[244])		
   );


   tri_csa32 csa1_5_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[244]),		
      .b(ex3_pp0_15[244]),		
      .c(ex3_pp0_16[244]),		
      .sum(ex3_pp1_5s[244]),		
      .car(ex3_pp1_5c[243])		
   );


   tri_csa32 csa1_5_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[243]),		
      .b(ex3_pp0_15[243]),		
      .c(ex3_pp0_16[243]),		
      .sum(ex3_pp1_5s[243]),		
      .car(ex3_pp1_5c[242])		
   );


   tri_csa32 csa1_5_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[242]),		
      .b(ex3_pp0_15[242]),		
      .c(ex3_pp0_16[242]),		
      .sum(ex3_pp1_5s[242]),		
      .car(ex3_pp1_5c[241])		
   );


   tri_csa32 csa1_5_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[241]),		
      .b(ex3_pp0_15[241]),		
      .c(ex3_pp0_16[241]),		
      .sum(ex3_pp1_5s[241]),		
      .car(ex3_pp1_5c[240])		
   );


   tri_csa32 csa1_5_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[240]),		
      .b(ex3_pp0_15[240]),		
      .c(ex3_pp0_16[240]),		
      .sum(ex3_pp1_5s[240]),		
      .car(ex3_pp1_5c[239])		
   );


   tri_csa32 csa1_5_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[239]),		
      .b(ex3_pp0_15[239]),		
      .c(ex3_pp0_16[239]),		
      .sum(ex3_pp1_5s[239]),		
      .car(ex3_pp1_5c[238])		
   );


   tri_csa32 csa1_5_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[238]),		
      .b(ex3_pp0_15[238]),		
      .c(ex3_pp0_16[238]),		
      .sum(ex3_pp1_5s[238]),		
      .car(ex3_pp1_5c[237])		
   );


   tri_csa32 csa1_5_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[237]),		
      .b(ex3_pp0_15[237]),		
      .c(ex3_pp0_16[237]),		
      .sum(ex3_pp1_5s[237]),		
      .car(ex3_pp1_5c[236])		
   );


   tri_csa32 csa1_5_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[236]),		
      .b(ex3_pp0_15[236]),		
      .c(ex3_pp0_16[236]),		
      .sum(ex3_pp1_5s[236]),		
      .car(ex3_pp1_5c[235])		
   );


   tri_csa32 csa1_5_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[235]),		
      .b(ex3_pp0_15[235]),		
      .c(ex3_pp0_16[235]),		
      .sum(ex3_pp1_5s[235]),		
      .car(ex3_pp1_5c[234])		
   );


   tri_csa32 csa1_5_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[234]),		
      .b(ex3_pp0_15[234]),		
      .c(ex3_pp0_16[234]),		
      .sum(ex3_pp1_5s[234]),		
      .car(ex3_pp1_5c[233])		
   );


   tri_csa32 csa1_5_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[233]),		
      .b(ex3_pp0_15[233]),		
      .c(ex3_pp0_16[233]),		
      .sum(ex3_pp1_5s[233]),		
      .car(ex3_pp1_5c[232])		
   );


   tri_csa32 csa1_5_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[232]),		
      .b(ex3_pp0_15[232]),		
      .c(ex3_pp0_16[232]),		
      .sum(ex3_pp1_5s[232]),		
      .car(ex3_pp1_5c[231])		
   );


   tri_csa32 csa1_5_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[231]),		
      .b(ex3_pp0_15[231]),		
      .c(ex3_pp0_16[231]),		
      .sum(ex3_pp1_5s[231]),		
      .car(ex3_pp1_5c[230])		
   );


   tri_csa32 csa1_5_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[230]),		
      .b(ex3_pp0_15[230]),		
      .c(ex3_pp0_16[230]),		
      .sum(ex3_pp1_5s[230]),		
      .car(ex3_pp1_5c[229])		
   );


   tri_csa32 csa1_5_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[229]),		
      .b(ex3_pp0_15[229]),		
      .c(ex3_pp0_16[229]),		
      .sum(ex3_pp1_5s[229]),		
      .car(ex3_pp1_5c[228])		
   );

   tri_csa22 csa1_5_228(
      .a(ex3_pp0_14[228]),		
      .b(ex3_pp0_15[228]),		
      .sum(ex3_pp1_5s[228]),		
      .car(ex3_pp1_5c[227])		
   );
   assign ex3_pp1_5s[227] = ex3_pp0_14[227];		
   assign ex3_pp1_5s[226] = ex3_pp0_14[226];		





   assign ex3_pp2_0s[242] = ex3_pp1_1s[242];		
   assign ex3_pp2_0s[241] = 0;		
   assign ex3_pp2_0c[240] = ex3_pp1_1s[240];		
   assign ex3_pp2_0s[240] = ex3_pp1_1c[240];		
   assign ex3_pp2_0c[239] = 0;		
   assign ex3_pp2_0s[239] = ex3_pp1_1s[239];		
   assign ex3_pp2_0c[238] = 0;		
   assign ex3_pp2_0s[238] = ex3_pp1_1s[238];		
   assign ex3_pp2_0c[237] = ex3_pp1_1s[237];		
   assign ex3_pp2_0s[237] = ex3_pp1_1c[237];		
   assign ex3_pp2_0c[236] = 0;		


   tri_csa32 csa2_0_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0s[236]),		
      .b(ex3_pp1_1c[236]),		
      .c(ex3_pp1_1s[236]),		
      .sum(ex3_pp2_0s[236]),		
      .car(ex3_pp2_0c[235])		
   );

   tri_csa22 csa2_0_235(
      .a(ex3_pp1_1c[235]),		
      .b(ex3_pp1_1s[235]),		
      .sum(ex3_pp2_0s[235]),		
      .car(ex3_pp2_0c[234])		
   );
   assign ex3_pp2_0k[234] = 0;		

   tri_csa42 csa2_0_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[234]),		
      .b(ex3_pp1_0s[234]),		
      .c(ex3_pp1_1c[234]),		
      .d(ex3_pp1_1s[234]),		
      .ki(ex3_pp2_0k[234]),		
      .ko(ex3_pp2_0k[233]),		
      .sum(ex3_pp2_0s[234]),		
      .car(ex3_pp2_0c[233])		
   );


   tri_csa42 csa2_0_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0s[233]),		
      .b(ex3_pp1_1c[233]),		
      .c(ex3_pp1_1s[233]),		
      .d(1'b0),		
      .ki(ex3_pp2_0k[233]),		
      .ko(ex3_pp2_0k[232]),		
      .sum(ex3_pp2_0s[233]),		
      .car(ex3_pp2_0c[232])		
   );


   tri_csa42 csa2_0_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0s[232]),		
      .b(ex3_pp1_1c[232]),		
      .c(ex3_pp1_1s[232]),		
      .d(1'b0),		
      .ki(ex3_pp2_0k[232]),		
      .ko(ex3_pp2_0k[231]),		
      .sum(ex3_pp2_0s[232]),		
      .car(ex3_pp2_0c[231])		
   );


   tri_csa42 csa2_0_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[231]),		
      .b(ex3_pp1_0s[231]),		
      .c(ex3_pp1_1c[231]),		
      .d(ex3_pp1_1s[231]),		
      .ki(ex3_pp2_0k[231]),		
      .ko(ex3_pp2_0k[230]),		
      .sum(ex3_pp2_0s[231]),		
      .car(ex3_pp2_0c[230])		
   );


   tri_csa42 csa2_0_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[230]),		
      .b(ex3_pp1_0s[230]),		
      .c(ex3_pp1_1c[230]),		
      .d(ex3_pp1_1s[230]),		
      .ki(ex3_pp2_0k[230]),		
      .ko(ex3_pp2_0k[229]),		
      .sum(ex3_pp2_0s[230]),		
      .car(ex3_pp2_0c[229])		
   );


   tri_csa42 csa2_0_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[229]),		
      .b(ex3_pp1_0s[229]),		
      .c(ex3_pp1_1c[229]),		
      .d(ex3_pp1_1s[229]),		
      .ki(ex3_pp2_0k[229]),		
      .ko(ex3_pp2_0k[228]),		
      .sum(ex3_pp2_0s[229]),		
      .car(ex3_pp2_0c[228])		
   );


   tri_csa42 csa2_0_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[228]),		
      .b(ex3_pp1_0s[228]),		
      .c(ex3_pp1_1c[228]),		
      .d(ex3_pp1_1s[228]),		
      .ki(ex3_pp2_0k[228]),		
      .ko(ex3_pp2_0k[227]),		
      .sum(ex3_pp2_0s[228]),		
      .car(ex3_pp2_0c[227])		
   );


   tri_csa42 csa2_0_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[227]),		
      .b(ex3_pp1_0s[227]),		
      .c(ex3_pp1_1c[227]),		
      .d(ex3_pp1_1s[227]),		
      .ki(ex3_pp2_0k[227]),		
      .ko(ex3_pp2_0k[226]),		
      .sum(ex3_pp2_0s[227]),		
      .car(ex3_pp2_0c[226])		
   );


   tri_csa42 csa2_0_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[226]),		
      .b(ex3_pp1_0s[226]),		
      .c(ex3_pp1_1c[226]),		
      .d(ex3_pp1_1s[226]),		
      .ki(ex3_pp2_0k[226]),		
      .ko(ex3_pp2_0k[225]),		
      .sum(ex3_pp2_0s[226]),		
      .car(ex3_pp2_0c[225])		
   );


   tri_csa42 csa2_0_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[225]),		
      .b(ex3_pp1_0s[225]),		
      .c(ex3_pp1_1c[225]),		
      .d(ex3_pp1_1s[225]),		
      .ki(ex3_pp2_0k[225]),		
      .ko(ex3_pp2_0k[224]),		
      .sum(ex3_pp2_0s[225]),		
      .car(ex3_pp2_0c[224])		
   );


   tri_csa42 csa2_0_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[224]),		
      .b(ex3_pp1_0s[224]),		
      .c(ex3_pp1_1c[224]),		
      .d(ex3_pp1_1s[224]),		
      .ki(ex3_pp2_0k[224]),		
      .ko(ex3_pp2_0k[223]),		
      .sum(ex3_pp2_0s[224]),		
      .car(ex3_pp2_0c[223])		
   );


   tri_csa42 csa2_0_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[223]),		
      .b(ex3_pp1_0s[223]),		
      .c(ex3_pp1_1c[223]),		
      .d(ex3_pp1_1s[223]),		
      .ki(ex3_pp2_0k[223]),		
      .ko(ex3_pp2_0k[222]),		
      .sum(ex3_pp2_0s[223]),		
      .car(ex3_pp2_0c[222])		
   );


   tri_csa42 csa2_0_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[222]),		
      .b(ex3_pp1_0s[222]),		
      .c(ex3_pp1_1c[222]),		
      .d(ex3_pp1_1s[222]),		
      .ki(ex3_pp2_0k[222]),		
      .ko(ex3_pp2_0k[221]),		
      .sum(ex3_pp2_0s[222]),		
      .car(ex3_pp2_0c[221])		
   );


   tri_csa42 csa2_0_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[221]),		
      .b(ex3_pp1_0s[221]),		
      .c(ex3_pp1_1c[221]),		
      .d(ex3_pp1_1s[221]),		
      .ki(ex3_pp2_0k[221]),		
      .ko(ex3_pp2_0k[220]),		
      .sum(ex3_pp2_0s[221]),		
      .car(ex3_pp2_0c[220])		
   );


   tri_csa42 csa2_0_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[220]),		
      .b(ex3_pp1_0s[220]),		
      .c(ex3_pp1_1c[220]),		
      .d(ex3_pp1_1s[220]),		
      .ki(ex3_pp2_0k[220]),		
      .ko(ex3_pp2_0k[219]),		
      .sum(ex3_pp2_0s[220]),		
      .car(ex3_pp2_0c[219])		
   );


   tri_csa42 csa2_0_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[219]),		
      .b(ex3_pp1_0s[219]),		
      .c(ex3_pp1_1c[219]),		
      .d(ex3_pp1_1s[219]),		
      .ki(ex3_pp2_0k[219]),		
      .ko(ex3_pp2_0k[218]),		
      .sum(ex3_pp2_0s[219]),		
      .car(ex3_pp2_0c[218])		
   );


   tri_csa42 csa2_0_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[218]),		
      .b(ex3_pp1_0s[218]),		
      .c(ex3_pp1_1c[218]),		
      .d(ex3_pp1_1s[218]),		
      .ki(ex3_pp2_0k[218]),		
      .ko(ex3_pp2_0k[217]),		
      .sum(ex3_pp2_0s[218]),		
      .car(ex3_pp2_0c[217])		
   );


   tri_csa42 csa2_0_217(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[217]),		
      .b(ex3_pp1_0s[217]),		
      .c(ex3_pp1_1c[217]),		
      .d(ex3_pp1_1s[217]),		
      .ki(ex3_pp2_0k[217]),		
      .ko(ex3_pp2_0k[216]),		
      .sum(ex3_pp2_0s[217]),		
      .car(ex3_pp2_0c[216])		
   );


   tri_csa42 csa2_0_216(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[216]),		
      .b(ex3_pp1_0s[216]),		
      .c(ex3_pp1_1c[216]),		
      .d(ex3_pp1_1s[216]),		
      .ki(ex3_pp2_0k[216]),		
      .ko(ex3_pp2_0k[215]),		
      .sum(ex3_pp2_0s[216]),		
      .car(ex3_pp2_0c[215])		
   );


   tri_csa42 csa2_0_215(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[215]),		
      .b(ex3_pp1_0s[215]),		
      .c(ex3_pp1_1c[215]),		
      .d(ex3_pp1_1s[215]),		
      .ki(ex3_pp2_0k[215]),		
      .ko(ex3_pp2_0k[214]),		
      .sum(ex3_pp2_0s[215]),		
      .car(ex3_pp2_0c[214])		
   );


   tri_csa42 csa2_0_214(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[214]),		
      .b(ex3_pp1_0s[214]),		
      .c(ex3_pp1_1c[214]),		
      .d(ex3_pp1_1s[214]),		
      .ki(ex3_pp2_0k[214]),		
      .ko(ex3_pp2_0k[213]),		
      .sum(ex3_pp2_0s[214]),		
      .car(ex3_pp2_0c[213])		
   );


   tri_csa42 csa2_0_213(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[213]),		
      .b(ex3_pp1_0s[213]),		
      .c(ex3_pp1_1c[213]),		
      .d(ex3_pp1_1s[213]),		
      .ki(ex3_pp2_0k[213]),		
      .ko(ex3_pp2_0k[212]),		
      .sum(ex3_pp2_0s[213]),		
      .car(ex3_pp2_0c[212])		
   );


   tri_csa42 csa2_0_212(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[212]),		
      .b(ex3_pp1_0s[212]),		
      .c(ex3_pp1_1c[212]),		
      .d(ex3_pp1_1s[212]),		
      .ki(ex3_pp2_0k[212]),		
      .ko(ex3_pp2_0k[211]),		
      .sum(ex3_pp2_0s[212]),		
      .car(ex3_pp2_0c[211])		
   );


   tri_csa42 csa2_0_211(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[211]),		
      .b(ex3_pp1_0s[211]),		
      .c(ex3_pp1_1c[211]),		
      .d(ex3_pp1_1s[211]),		
      .ki(ex3_pp2_0k[211]),		
      .ko(ex3_pp2_0k[210]),		
      .sum(ex3_pp2_0s[211]),		
      .car(ex3_pp2_0c[210])		
   );


   tri_csa42 csa2_0_210(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[210]),		
      .b(ex3_pp1_0s[210]),		
      .c(ex3_pp1_1c[210]),		
      .d(ex3_pp1_1s[210]),		
      .ki(ex3_pp2_0k[210]),		
      .ko(ex3_pp2_0k[209]),		
      .sum(ex3_pp2_0s[210]),		
      .car(ex3_pp2_0c[209])		
   );


   tri_csa42 csa2_0_209(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[209]),		
      .b(ex3_pp1_0s[209]),		
      .c(ex3_pp1_1c[209]),		
      .d(ex3_pp1_1s[209]),		
      .ki(ex3_pp2_0k[209]),		
      .ko(ex3_pp2_0k[208]),		
      .sum(ex3_pp2_0s[209]),		
      .car(ex3_pp2_0c[208])		
   );


   tri_csa42 csa2_0_208(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[208]),		
      .b(ex3_pp1_0s[208]),		
      .c(ex3_pp1_1c[208]),		
      .d(ex3_pp1_1s[208]),		
      .ki(ex3_pp2_0k[208]),		
      .ko(ex3_pp2_0k[207]),		
      .sum(ex3_pp2_0s[208]),		
      .car(ex3_pp2_0c[207])		
   );


   tri_csa42 csa2_0_207(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[207]),		
      .b(ex3_pp1_0s[207]),		
      .c(ex3_pp1_1c[207]),		
      .d(ex3_pp1_1s[207]),		
      .ki(ex3_pp2_0k[207]),		
      .ko(ex3_pp2_0k[206]),		
      .sum(ex3_pp2_0s[207]),		
      .car(ex3_pp2_0c[206])		
   );


   tri_csa42 csa2_0_206(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[206]),		
      .b(ex3_pp1_0s[206]),		
      .c(ex3_pp1_1c[206]),		
      .d(ex3_pp1_1s[206]),		
      .ki(ex3_pp2_0k[206]),		
      .ko(ex3_pp2_0k[205]),		
      .sum(ex3_pp2_0s[206]),		
      .car(ex3_pp2_0c[205])		
   );


   tri_csa42 csa2_0_205(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[205]),		
      .b(ex3_pp1_0s[205]),		
      .c(ex3_pp1_1c[205]),		
      .d(ex3_pp1_1s[205]),		
      .ki(ex3_pp2_0k[205]),		
      .ko(ex3_pp2_0k[204]),		
      .sum(ex3_pp2_0s[205]),		
      .car(ex3_pp2_0c[204])		
   );


   tri_csa42 csa2_0_204(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[204]),		
      .b(ex3_pp1_0s[204]),		
      .c(ex3_pp1_1c[204]),		
      .d(ex3_pp1_1s[204]),		
      .ki(ex3_pp2_0k[204]),		
      .ko(ex3_pp2_0k[203]),		
      .sum(ex3_pp2_0s[204]),		
      .car(ex3_pp2_0c[203])		
   );


   tri_csa42 csa2_0_203(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[203]),		
      .b(ex3_pp1_0s[203]),		
      .c(ex3_pp1_1c[203]),		
      .d(ex3_pp1_1s[203]),		
      .ki(ex3_pp2_0k[203]),		
      .ko(ex3_pp2_0k[202]),		
      .sum(ex3_pp2_0s[203]),		
      .car(ex3_pp2_0c[202])		
   );


   tri_csa42 csa2_0_202(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[202]),		
      .b(ex3_pp1_0s[202]),		
      .c(ex3_pp1_1s[202]),		
      .d(1'b0),		
      .ki(ex3_pp2_0k[202]),		
      .ko(ex3_pp2_0k[201]),		
      .sum(ex3_pp2_0s[202]),		
      .car(ex3_pp2_0c[201])		
   );


   tri_csa32 csa2_0_201(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[201]),		
      .b(ex3_pp1_0s[201]),		
      .c(ex3_pp2_0k[201]),		
      .sum(ex3_pp2_0s[201]),		
      .car(ex3_pp2_0c[200])		
   );

   tri_csa22 csa2_0_200(
      .a(ex3_pp1_0c[200]),		
      .b(ex3_pp1_0s[200]),		
      .sum(ex3_pp2_0s[200]),		
      .car(ex3_pp2_0c[199])		
   );

   tri_csa22 csa2_0_199(
      .a(ex3_pp1_0c[199]),		
      .b(ex3_pp1_0s[199]),		
      .sum(ex3_pp2_0s[199]),		
      .car(ex3_pp2_0c[198])		
   );
   assign ex3_pp2_0s[198] = ex3_pp1_0s[198];		


   assign ex3_pp2_1s[254] = ex3_pp1_3s[254];		
   assign ex3_pp2_1s[253] = 0;		
   assign ex3_pp2_1c[252] = ex3_pp1_3s[252];		
   assign ex3_pp2_1s[252] = ex3_pp1_3c[252];		
   assign ex3_pp2_1c[251] = 0;		
   assign ex3_pp2_1s[251] = ex3_pp1_3s[251];		
   assign ex3_pp2_1c[250] = 0;		
   assign ex3_pp2_1s[250] = ex3_pp1_3s[250];		
   assign ex3_pp2_1c[249] = ex3_pp1_3s[249];		
   assign ex3_pp2_1s[249] = ex3_pp1_3c[249];		
   assign ex3_pp2_1c[248] = 0;		


   tri_csa32 csa2_1_248(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2s[248]),		
      .b(ex3_pp1_3c[248]),		
      .c(ex3_pp1_3s[248]),		
      .sum(ex3_pp2_1s[248]),		
      .car(ex3_pp2_1c[247])		
   );

   tri_csa22 csa2_1_247(
      .a(ex3_pp1_3c[247]),		
      .b(ex3_pp1_3s[247]),		
      .sum(ex3_pp2_1s[247]),		
      .car(ex3_pp2_1c[246])		
   );
   assign ex3_pp2_1k[246] = 0;		


   tri_csa42 csa2_1_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[246]),		
      .b(ex3_pp1_2s[246]),		
      .c(ex3_pp1_3c[246]),		
      .d(ex3_pp1_3s[246]),		
      .ki(ex3_pp2_1k[246]),		
      .ko(ex3_pp2_1k[245]),		
      .sum(ex3_pp2_1s[246]),		
      .car(ex3_pp2_1c[245])		
   );


   tri_csa42 csa2_1_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2s[245]),		
      .b(ex3_pp1_3c[245]),		
      .c(ex3_pp1_3s[245]),		
      .d(1'b0),		
      .ki(ex3_pp2_1k[245]),		
      .ko(ex3_pp2_1k[244]),		
      .sum(ex3_pp2_1s[245]),		
      .car(ex3_pp2_1c[244])		
   );


   tri_csa42 csa2_1_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2s[244]),		
      .b(ex3_pp1_3c[244]),		
      .c(ex3_pp1_3s[244]),		
      .d(1'b0),		
      .ki(ex3_pp2_1k[244]),		
      .ko(ex3_pp2_1k[243]),		
      .sum(ex3_pp2_1s[244]),		
      .car(ex3_pp2_1c[243])		
   );


   tri_csa42 csa2_1_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[243]),		
      .b(ex3_pp1_2s[243]),		
      .c(ex3_pp1_3c[243]),		
      .d(ex3_pp1_3s[243]),		
      .ki(ex3_pp2_1k[243]),		
      .ko(ex3_pp2_1k[242]),		
      .sum(ex3_pp2_1s[243]),		
      .car(ex3_pp2_1c[242])		
   );


   tri_csa42 csa2_1_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[242]),		
      .b(ex3_pp1_2s[242]),		
      .c(ex3_pp1_3c[242]),		
      .d(ex3_pp1_3s[242]),		
      .ki(ex3_pp2_1k[242]),		
      .ko(ex3_pp2_1k[241]),		
      .sum(ex3_pp2_1s[242]),		
      .car(ex3_pp2_1c[241])		
   );


   tri_csa42 csa2_1_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[241]),		
      .b(ex3_pp1_2s[241]),		
      .c(ex3_pp1_3c[241]),		
      .d(ex3_pp1_3s[241]),		
      .ki(ex3_pp2_1k[241]),		
      .ko(ex3_pp2_1k[240]),		
      .sum(ex3_pp2_1s[241]),		
      .car(ex3_pp2_1c[240])		
   );


   tri_csa42 csa2_1_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[240]),		
      .b(ex3_pp1_2s[240]),		
      .c(ex3_pp1_3c[240]),		
      .d(ex3_pp1_3s[240]),		
      .ki(ex3_pp2_1k[240]),		
      .ko(ex3_pp2_1k[239]),		
      .sum(ex3_pp2_1s[240]),		
      .car(ex3_pp2_1c[239])		
   );


   tri_csa42 csa2_1_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[239]),		
      .b(ex3_pp1_2s[239]),		
      .c(ex3_pp1_3c[239]),		
      .d(ex3_pp1_3s[239]),		
      .ki(ex3_pp2_1k[239]),		
      .ko(ex3_pp2_1k[238]),		
      .sum(ex3_pp2_1s[239]),		
      .car(ex3_pp2_1c[238])		
   );


   tri_csa42 csa2_1_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[238]),		
      .b(ex3_pp1_2s[238]),		
      .c(ex3_pp1_3c[238]),		
      .d(ex3_pp1_3s[238]),		
      .ki(ex3_pp2_1k[238]),		
      .ko(ex3_pp2_1k[237]),		
      .sum(ex3_pp2_1s[238]),		
      .car(ex3_pp2_1c[237])		
   );


   tri_csa42 csa2_1_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[237]),		
      .b(ex3_pp1_2s[237]),		
      .c(ex3_pp1_3c[237]),		
      .d(ex3_pp1_3s[237]),		
      .ki(ex3_pp2_1k[237]),		
      .ko(ex3_pp2_1k[236]),		
      .sum(ex3_pp2_1s[237]),		
      .car(ex3_pp2_1c[236])		
   );


   tri_csa42 csa2_1_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[236]),		
      .b(ex3_pp1_2s[236]),		
      .c(ex3_pp1_3c[236]),		
      .d(ex3_pp1_3s[236]),		
      .ki(ex3_pp2_1k[236]),		
      .ko(ex3_pp2_1k[235]),		
      .sum(ex3_pp2_1s[236]),		
      .car(ex3_pp2_1c[235])		
   );


   tri_csa42 csa2_1_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[235]),		
      .b(ex3_pp1_2s[235]),		
      .c(ex3_pp1_3c[235]),		
      .d(ex3_pp1_3s[235]),		
      .ki(ex3_pp2_1k[235]),		
      .ko(ex3_pp2_1k[234]),		
      .sum(ex3_pp2_1s[235]),		
      .car(ex3_pp2_1c[234])		
   );


   tri_csa42 csa2_1_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[234]),		
      .b(ex3_pp1_2s[234]),		
      .c(ex3_pp1_3c[234]),		
      .d(ex3_pp1_3s[234]),		
      .ki(ex3_pp2_1k[234]),		
      .ko(ex3_pp2_1k[233]),		
      .sum(ex3_pp2_1s[234]),		
      .car(ex3_pp2_1c[233])		
   );


   tri_csa42 csa2_1_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[233]),		
      .b(ex3_pp1_2s[233]),		
      .c(ex3_pp1_3c[233]),		
      .d(ex3_pp1_3s[233]),		
      .ki(ex3_pp2_1k[233]),		
      .ko(ex3_pp2_1k[232]),		
      .sum(ex3_pp2_1s[233]),		
      .car(ex3_pp2_1c[232])		
   );


   tri_csa42 csa2_1_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[232]),		
      .b(ex3_pp1_2s[232]),		
      .c(ex3_pp1_3c[232]),		
      .d(ex3_pp1_3s[232]),		
      .ki(ex3_pp2_1k[232]),		
      .ko(ex3_pp2_1k[231]),		
      .sum(ex3_pp2_1s[232]),		
      .car(ex3_pp2_1c[231])		
   );


   tri_csa42 csa2_1_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[231]),		
      .b(ex3_pp1_2s[231]),		
      .c(ex3_pp1_3c[231]),		
      .d(ex3_pp1_3s[231]),		
      .ki(ex3_pp2_1k[231]),		
      .ko(ex3_pp2_1k[230]),		
      .sum(ex3_pp2_1s[231]),		
      .car(ex3_pp2_1c[230])		
   );


   tri_csa42 csa2_1_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[230]),		
      .b(ex3_pp1_2s[230]),		
      .c(ex3_pp1_3c[230]),		
      .d(ex3_pp1_3s[230]),		
      .ki(ex3_pp2_1k[230]),		
      .ko(ex3_pp2_1k[229]),		
      .sum(ex3_pp2_1s[230]),		
      .car(ex3_pp2_1c[229])		
   );


   tri_csa42 csa2_1_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[229]),		
      .b(ex3_pp1_2s[229]),		
      .c(ex3_pp1_3c[229]),		
      .d(ex3_pp1_3s[229]),		
      .ki(ex3_pp2_1k[229]),		
      .ko(ex3_pp2_1k[228]),		
      .sum(ex3_pp2_1s[229]),		
      .car(ex3_pp2_1c[228])		
   );


   tri_csa42 csa2_1_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[228]),		
      .b(ex3_pp1_2s[228]),		
      .c(ex3_pp1_3c[228]),		
      .d(ex3_pp1_3s[228]),		
      .ki(ex3_pp2_1k[228]),		
      .ko(ex3_pp2_1k[227]),		
      .sum(ex3_pp2_1s[228]),		
      .car(ex3_pp2_1c[227])		
   );


   tri_csa42 csa2_1_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[227]),		
      .b(ex3_pp1_2s[227]),		
      .c(ex3_pp1_3c[227]),		
      .d(ex3_pp1_3s[227]),		
      .ki(ex3_pp2_1k[227]),		
      .ko(ex3_pp2_1k[226]),		
      .sum(ex3_pp2_1s[227]),		
      .car(ex3_pp2_1c[226])		
   );


   tri_csa42 csa2_1_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[226]),		
      .b(ex3_pp1_2s[226]),		
      .c(ex3_pp1_3c[226]),		
      .d(ex3_pp1_3s[226]),		
      .ki(ex3_pp2_1k[226]),		
      .ko(ex3_pp2_1k[225]),		
      .sum(ex3_pp2_1s[226]),		
      .car(ex3_pp2_1c[225])		
   );


   tri_csa42 csa2_1_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[225]),		
      .b(ex3_pp1_2s[225]),		
      .c(ex3_pp1_3c[225]),		
      .d(ex3_pp1_3s[225]),		
      .ki(ex3_pp2_1k[225]),		
      .ko(ex3_pp2_1k[224]),		
      .sum(ex3_pp2_1s[225]),		
      .car(ex3_pp2_1c[224])		
   );


   tri_csa42 csa2_1_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[224]),		
      .b(ex3_pp1_2s[224]),		
      .c(ex3_pp1_3c[224]),		
      .d(ex3_pp1_3s[224]),		
      .ki(ex3_pp2_1k[224]),		
      .ko(ex3_pp2_1k[223]),		
      .sum(ex3_pp2_1s[224]),		
      .car(ex3_pp2_1c[223])		
   );


   tri_csa42 csa2_1_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[223]),		
      .b(ex3_pp1_2s[223]),		
      .c(ex3_pp1_3c[223]),		
      .d(ex3_pp1_3s[223]),		
      .ki(ex3_pp2_1k[223]),		
      .ko(ex3_pp2_1k[222]),		
      .sum(ex3_pp2_1s[223]),		
      .car(ex3_pp2_1c[222])		
   );


   tri_csa42 csa2_1_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[222]),		
      .b(ex3_pp1_2s[222]),		
      .c(ex3_pp1_3c[222]),		
      .d(ex3_pp1_3s[222]),		
      .ki(ex3_pp2_1k[222]),		
      .ko(ex3_pp2_1k[221]),		
      .sum(ex3_pp2_1s[222]),		
      .car(ex3_pp2_1c[221])		
   );


   tri_csa42 csa2_1_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[221]),		
      .b(ex3_pp1_2s[221]),		
      .c(ex3_pp1_3c[221]),		
      .d(ex3_pp1_3s[221]),		
      .ki(ex3_pp2_1k[221]),		
      .ko(ex3_pp2_1k[220]),		
      .sum(ex3_pp2_1s[221]),		
      .car(ex3_pp2_1c[220])		
   );


   tri_csa42 csa2_1_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[220]),		
      .b(ex3_pp1_2s[220]),		
      .c(ex3_pp1_3c[220]),		
      .d(ex3_pp1_3s[220]),		
      .ki(ex3_pp2_1k[220]),		
      .ko(ex3_pp2_1k[219]),		
      .sum(ex3_pp2_1s[220]),		
      .car(ex3_pp2_1c[219])		
   );


   tri_csa42 csa2_1_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[219]),		
      .b(ex3_pp1_2s[219]),		
      .c(ex3_pp1_3c[219]),		
      .d(ex3_pp1_3s[219]),		
      .ki(ex3_pp2_1k[219]),		
      .ko(ex3_pp2_1k[218]),		
      .sum(ex3_pp2_1s[219]),		
      .car(ex3_pp2_1c[218])		
   );


   tri_csa42 csa2_1_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[218]),		
      .b(ex3_pp1_2s[218]),		
      .c(ex3_pp1_3c[218]),		
      .d(ex3_pp1_3s[218]),		
      .ki(ex3_pp2_1k[218]),		
      .ko(ex3_pp2_1k[217]),		
      .sum(ex3_pp2_1s[218]),		
      .car(ex3_pp2_1c[217])		
   );


   tri_csa42 csa2_1_217(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[217]),		
      .b(ex3_pp1_2s[217]),		
      .c(ex3_pp1_3c[217]),		
      .d(ex3_pp1_3s[217]),		
      .ki(ex3_pp2_1k[217]),		
      .ko(ex3_pp2_1k[216]),		
      .sum(ex3_pp2_1s[217]),		
      .car(ex3_pp2_1c[216])		
   );


   tri_csa42 csa2_1_216(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[216]),		
      .b(ex3_pp1_2s[216]),		
      .c(ex3_pp1_3c[216]),		
      .d(ex3_pp1_3s[216]),		
      .ki(ex3_pp2_1k[216]),		
      .ko(ex3_pp2_1k[215]),		
      .sum(ex3_pp2_1s[216]),		
      .car(ex3_pp2_1c[215])		
   );


   tri_csa42 csa2_1_215(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[215]),		
      .b(ex3_pp1_2s[215]),		
      .c(ex3_pp1_3c[215]),		
      .d(ex3_pp1_3s[215]),		
      .ki(ex3_pp2_1k[215]),		
      .ko(ex3_pp2_1k[214]),		
      .sum(ex3_pp2_1s[215]),		
      .car(ex3_pp2_1c[214])		
   );


   tri_csa42 csa2_1_214(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[214]),		
      .b(ex3_pp1_2s[214]),		
      .c(ex3_pp1_3s[214]),		
      .d(1'b0),		
      .ki(ex3_pp2_1k[214]),		
      .ko(ex3_pp2_1k[213]),		
      .sum(ex3_pp2_1s[214]),		
      .car(ex3_pp2_1c[213])		
   );


   tri_csa32 csa2_1_213(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[213]),		
      .b(ex3_pp1_2s[213]),		
      .c(ex3_pp2_1k[213]),		
      .sum(ex3_pp2_1s[213]),		
      .car(ex3_pp2_1c[212])		
   );

   tri_csa22 csa2_1_212(
      .a(ex3_pp1_2c[212]),		
      .b(ex3_pp1_2s[212]),		
      .sum(ex3_pp2_1s[212]),		
      .car(ex3_pp2_1c[211])		
   );

   tri_csa22 csa2_1_211(
      .a(ex3_pp1_2c[211]),		
      .b(ex3_pp1_2s[211]),		
      .sum(ex3_pp2_1s[211]),		
      .car(ex3_pp2_1c[210])		
   );

   tri_csa22 csa2_1_210(
      .a(ex3_pp1_2c[210]),		
      .b(ex3_pp1_2s[210]),		
      .sum(ex3_pp2_1s[210]),		
      .car(ex3_pp2_1c[209])		
   );

   tri_csa22 csa2_1_209(
      .a(ex3_pp1_2c[209]),		
      .b(ex3_pp1_2s[209]),		
      .sum(ex3_pp2_1s[209]),		
      .car(ex3_pp2_1c[208])		
   );
   assign ex3_pp2_1s[208] = ex3_pp1_2s[208];		



   tri_csa22 csa2_2_264(
      .a(ex3_pp1_5c[264]),		
      .b(ex3_pp1_5s[264]),		
      .sum(ex3_pp2_2s[264]),		
      .car(ex3_pp2_2c[263])		
   );
   assign ex3_pp2_2s[263] = ex3_pp1_5s[263];		
   assign ex3_pp2_2c[262] = 0;		
   assign ex3_pp2_2s[262] = ex3_pp1_5s[262];		
   assign ex3_pp2_2c[261] = ex3_pp1_5s[261];		
   assign ex3_pp2_2s[261] = ex3_pp1_5c[261];		
   assign ex3_pp2_2c[260] = 0;		


   tri_csa32 csa2_2_260(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4s[260]),		
      .b(ex3_pp1_5c[260]),		
      .c(ex3_pp1_5s[260]),		
      .sum(ex3_pp2_2s[260]),		
      .car(ex3_pp2_2c[259])		
   );

   tri_csa22 csa2_2_259(
      .a(ex3_pp1_5c[259]),		
      .b(ex3_pp1_5s[259]),		
      .sum(ex3_pp2_2s[259]),		
      .car(ex3_pp2_2c[258])		
   );
   assign ex3_pp2_2k[258] = 0;		


   tri_csa42 csa2_2_258(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[258]),		
      .b(ex3_pp1_4s[258]),		
      .c(ex3_pp1_5c[258]),		
      .d(ex3_pp1_5s[258]),		
      .ki(ex3_pp2_2k[258]),		
      .ko(ex3_pp2_2k[257]),		
      .sum(ex3_pp2_2s[258]),		
      .car(ex3_pp2_2c[257])		
   );


   tri_csa42 csa2_2_257(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4s[257]),		
      .b(ex3_pp1_5c[257]),		
      .c(ex3_pp1_5s[257]),		
      .d(1'b0),		
      .ki(ex3_pp2_2k[257]),		
      .ko(ex3_pp2_2k[256]),		
      .sum(ex3_pp2_2s[257]),		
      .car(ex3_pp2_2c[256])		
   );


   tri_csa42 csa2_2_256(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4s[256]),		
      .b(ex3_pp1_5c[256]),		
      .c(ex3_pp1_5s[256]),		
      .d(1'b0),		
      .ki(ex3_pp2_2k[256]),		
      .ko(ex3_pp2_2k[255]),		
      .sum(ex3_pp2_2s[256]),		
      .car(ex3_pp2_2c[255])		
   );


   tri_csa42 csa2_2_255(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[255]),		
      .b(ex3_pp1_4s[255]),		
      .c(ex3_pp1_5c[255]),		
      .d(ex3_pp1_5s[255]),		
      .ki(ex3_pp2_2k[255]),		
      .ko(ex3_pp2_2k[254]),		
      .sum(ex3_pp2_2s[255]),		
      .car(ex3_pp2_2c[254])		
   );


   tri_csa42 csa2_2_254(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[254]),		
      .b(ex3_pp1_4s[254]),		
      .c(ex3_pp1_5c[254]),		
      .d(ex3_pp1_5s[254]),		
      .ki(ex3_pp2_2k[254]),		
      .ko(ex3_pp2_2k[253]),		
      .sum(ex3_pp2_2s[254]),		
      .car(ex3_pp2_2c[253])		
   );


   tri_csa42 csa2_2_253(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[253]),		
      .b(ex3_pp1_4s[253]),		
      .c(ex3_pp1_5c[253]),		
      .d(ex3_pp1_5s[253]),		
      .ki(ex3_pp2_2k[253]),		
      .ko(ex3_pp2_2k[252]),		
      .sum(ex3_pp2_2s[253]),		
      .car(ex3_pp2_2c[252])		
   );


   tri_csa42 csa2_2_252(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[252]),		
      .b(ex3_pp1_4s[252]),		
      .c(ex3_pp1_5c[252]),		
      .d(ex3_pp1_5s[252]),		
      .ki(ex3_pp2_2k[252]),		
      .ko(ex3_pp2_2k[251]),		
      .sum(ex3_pp2_2s[252]),		
      .car(ex3_pp2_2c[251])		
   );


   tri_csa42 csa2_2_251(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[251]),		
      .b(ex3_pp1_4s[251]),		
      .c(ex3_pp1_5c[251]),		
      .d(ex3_pp1_5s[251]),		
      .ki(ex3_pp2_2k[251]),		
      .ko(ex3_pp2_2k[250]),		
      .sum(ex3_pp2_2s[251]),		
      .car(ex3_pp2_2c[250])		
   );


   tri_csa42 csa2_2_250(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[250]),		
      .b(ex3_pp1_4s[250]),		
      .c(ex3_pp1_5c[250]),		
      .d(ex3_pp1_5s[250]),		
      .ki(ex3_pp2_2k[250]),		
      .ko(ex3_pp2_2k[249]),		
      .sum(ex3_pp2_2s[250]),		
      .car(ex3_pp2_2c[249])		
   );


   tri_csa42 csa2_2_249(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[249]),		
      .b(ex3_pp1_4s[249]),		
      .c(ex3_pp1_5c[249]),		
      .d(ex3_pp1_5s[249]),		
      .ki(ex3_pp2_2k[249]),		
      .ko(ex3_pp2_2k[248]),		
      .sum(ex3_pp2_2s[249]),		
      .car(ex3_pp2_2c[248])		
   );


   tri_csa42 csa2_2_248(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[248]),		
      .b(ex3_pp1_4s[248]),		
      .c(ex3_pp1_5c[248]),		
      .d(ex3_pp1_5s[248]),		
      .ki(ex3_pp2_2k[248]),		
      .ko(ex3_pp2_2k[247]),		
      .sum(ex3_pp2_2s[248]),		
      .car(ex3_pp2_2c[247])		
   );


   tri_csa42 csa2_2_247(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[247]),		
      .b(ex3_pp1_4s[247]),		
      .c(ex3_pp1_5c[247]),		
      .d(ex3_pp1_5s[247]),		
      .ki(ex3_pp2_2k[247]),		
      .ko(ex3_pp2_2k[246]),		
      .sum(ex3_pp2_2s[247]),		
      .car(ex3_pp2_2c[246])		
   );


   tri_csa42 csa2_2_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[246]),		
      .b(ex3_pp1_4s[246]),		
      .c(ex3_pp1_5c[246]),		
      .d(ex3_pp1_5s[246]),		
      .ki(ex3_pp2_2k[246]),		
      .ko(ex3_pp2_2k[245]),		
      .sum(ex3_pp2_2s[246]),		
      .car(ex3_pp2_2c[245])		
   );


   tri_csa42 csa2_2_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[245]),		
      .b(ex3_pp1_4s[245]),		
      .c(ex3_pp1_5c[245]),		
      .d(ex3_pp1_5s[245]),		
      .ki(ex3_pp2_2k[245]),		
      .ko(ex3_pp2_2k[244]),		
      .sum(ex3_pp2_2s[245]),		
      .car(ex3_pp2_2c[244])		
   );


   tri_csa42 csa2_2_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[244]),		
      .b(ex3_pp1_4s[244]),		
      .c(ex3_pp1_5c[244]),		
      .d(ex3_pp1_5s[244]),		
      .ki(ex3_pp2_2k[244]),		
      .ko(ex3_pp2_2k[243]),		
      .sum(ex3_pp2_2s[244]),		
      .car(ex3_pp2_2c[243])		
   );


   tri_csa42 csa2_2_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[243]),		
      .b(ex3_pp1_4s[243]),		
      .c(ex3_pp1_5c[243]),		
      .d(ex3_pp1_5s[243]),		
      .ki(ex3_pp2_2k[243]),		
      .ko(ex3_pp2_2k[242]),		
      .sum(ex3_pp2_2s[243]),		
      .car(ex3_pp2_2c[242])		
   );


   tri_csa42 csa2_2_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[242]),		
      .b(ex3_pp1_4s[242]),		
      .c(ex3_pp1_5c[242]),		
      .d(ex3_pp1_5s[242]),		
      .ki(ex3_pp2_2k[242]),		
      .ko(ex3_pp2_2k[241]),		
      .sum(ex3_pp2_2s[242]),		
      .car(ex3_pp2_2c[241])		
   );


   tri_csa42 csa2_2_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[241]),		
      .b(ex3_pp1_4s[241]),		
      .c(ex3_pp1_5c[241]),		
      .d(ex3_pp1_5s[241]),		
      .ki(ex3_pp2_2k[241]),		
      .ko(ex3_pp2_2k[240]),		
      .sum(ex3_pp2_2s[241]),		
      .car(ex3_pp2_2c[240])		
   );


   tri_csa42 csa2_2_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[240]),		
      .b(ex3_pp1_4s[240]),		
      .c(ex3_pp1_5c[240]),		
      .d(ex3_pp1_5s[240]),		
      .ki(ex3_pp2_2k[240]),		
      .ko(ex3_pp2_2k[239]),		
      .sum(ex3_pp2_2s[240]),		
      .car(ex3_pp2_2c[239])		
   );


   tri_csa42 csa2_2_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[239]),		
      .b(ex3_pp1_4s[239]),		
      .c(ex3_pp1_5c[239]),		
      .d(ex3_pp1_5s[239]),		
      .ki(ex3_pp2_2k[239]),		
      .ko(ex3_pp2_2k[238]),		
      .sum(ex3_pp2_2s[239]),		
      .car(ex3_pp2_2c[238])		
   );


   tri_csa42 csa2_2_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[238]),		
      .b(ex3_pp1_4s[238]),		
      .c(ex3_pp1_5c[238]),		
      .d(ex3_pp1_5s[238]),		
      .ki(ex3_pp2_2k[238]),		
      .ko(ex3_pp2_2k[237]),		
      .sum(ex3_pp2_2s[238]),		
      .car(ex3_pp2_2c[237])		
   );


   tri_csa42 csa2_2_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[237]),		
      .b(ex3_pp1_4s[237]),		
      .c(ex3_pp1_5c[237]),		
      .d(ex3_pp1_5s[237]),		
      .ki(ex3_pp2_2k[237]),		
      .ko(ex3_pp2_2k[236]),		
      .sum(ex3_pp2_2s[237]),		
      .car(ex3_pp2_2c[236])		
   );


   tri_csa42 csa2_2_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[236]),		
      .b(ex3_pp1_4s[236]),		
      .c(ex3_pp1_5c[236]),		
      .d(ex3_pp1_5s[236]),		
      .ki(ex3_pp2_2k[236]),		
      .ko(ex3_pp2_2k[235]),		
      .sum(ex3_pp2_2s[236]),		
      .car(ex3_pp2_2c[235])		
   );


   tri_csa42 csa2_2_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[235]),		
      .b(ex3_pp1_4s[235]),		
      .c(ex3_pp1_5c[235]),		
      .d(ex3_pp1_5s[235]),		
      .ki(ex3_pp2_2k[235]),		
      .ko(ex3_pp2_2k[234]),		
      .sum(ex3_pp2_2s[235]),		
      .car(ex3_pp2_2c[234])		
   );


   tri_csa42 csa2_2_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[234]),		
      .b(ex3_pp1_4s[234]),		
      .c(ex3_pp1_5c[234]),		
      .d(ex3_pp1_5s[234]),		
      .ki(ex3_pp2_2k[234]),		
      .ko(ex3_pp2_2k[233]),		
      .sum(ex3_pp2_2s[234]),		
      .car(ex3_pp2_2c[233])		
   );


   tri_csa42 csa2_2_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[233]),		
      .b(ex3_pp1_4s[233]),		
      .c(ex3_pp1_5c[233]),		
      .d(ex3_pp1_5s[233]),		
      .ki(ex3_pp2_2k[233]),		
      .ko(ex3_pp2_2k[232]),		
      .sum(ex3_pp2_2s[233]),		
      .car(ex3_pp2_2c[232])		
   );


   tri_csa42 csa2_2_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[232]),		
      .b(ex3_pp1_4s[232]),		
      .c(ex3_pp1_5c[232]),		
      .d(ex3_pp1_5s[232]),		
      .ki(ex3_pp2_2k[232]),		
      .ko(ex3_pp2_2k[231]),		
      .sum(ex3_pp2_2s[232]),		
      .car(ex3_pp2_2c[231])		
   );


   tri_csa42 csa2_2_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[231]),		
      .b(ex3_pp1_4s[231]),		
      .c(ex3_pp1_5c[231]),		
      .d(ex3_pp1_5s[231]),		
      .ki(ex3_pp2_2k[231]),		
      .ko(ex3_pp2_2k[230]),		
      .sum(ex3_pp2_2s[231]),		
      .car(ex3_pp2_2c[230])		
   );


   tri_csa42 csa2_2_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[230]),		
      .b(ex3_pp1_4s[230]),		
      .c(ex3_pp1_5c[230]),		
      .d(ex3_pp1_5s[230]),		
      .ki(ex3_pp2_2k[230]),		
      .ko(ex3_pp2_2k[229]),		
      .sum(ex3_pp2_2s[230]),		
      .car(ex3_pp2_2c[229])		
   );


   tri_csa42 csa2_2_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[229]),		
      .b(ex3_pp1_4s[229]),		
      .c(ex3_pp1_5c[229]),		
      .d(ex3_pp1_5s[229]),		
      .ki(ex3_pp2_2k[229]),		
      .ko(ex3_pp2_2k[228]),		
      .sum(ex3_pp2_2s[229]),		
      .car(ex3_pp2_2c[228])		
   );


   tri_csa42 csa2_2_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[228]),		
      .b(ex3_pp1_4s[228]),		
      .c(ex3_pp1_5c[228]),		
      .d(ex3_pp1_5s[228]),		
      .ki(ex3_pp2_2k[228]),		
      .ko(ex3_pp2_2k[227]),		
      .sum(ex3_pp2_2s[228]),		
      .car(ex3_pp2_2c[227])		
   );


   tri_csa42 csa2_2_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[227]),		
      .b(ex3_pp1_4s[227]),		
      .c(ex3_pp1_5c[227]),		
      .d(ex3_pp1_5s[227]),		
      .ki(ex3_pp2_2k[227]),		
      .ko(ex3_pp2_2k[226]),		
      .sum(ex3_pp2_2s[227]),		
      .car(ex3_pp2_2c[226])		
   );


   tri_csa42 csa2_2_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[226]),		
      .b(ex3_pp1_4s[226]),		
      .c(ex3_pp1_5s[226]),		
      .d(1'b0),		
      .ki(ex3_pp2_2k[226]),		
      .ko(ex3_pp2_2k[225]),		
      .sum(ex3_pp2_2s[226]),		
      .car(ex3_pp2_2c[225])		
   );


   tri_csa32 csa2_2_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[225]),		
      .b(ex3_pp1_4s[225]),		
      .c(ex3_pp2_2k[225]),		
      .sum(ex3_pp2_2s[225]),		
      .car(ex3_pp2_2c[224])		
   );

   tri_csa22 csa2_2_224(
      .a(ex3_pp1_4c[224]),		
      .b(ex3_pp1_4s[224]),		
      .sum(ex3_pp2_2s[224]),		
      .car(ex3_pp2_2c[223])		
   );

   tri_csa22 csa2_2_223(
      .a(ex3_pp1_4c[223]),		
      .b(ex3_pp1_4s[223]),		
      .sum(ex3_pp2_2s[223]),		
      .car(ex3_pp2_2c[222])		
   );

   tri_csa22 csa2_2_222(
      .a(ex3_pp1_4c[222]),		
      .b(ex3_pp1_4s[222]),		
      .sum(ex3_pp2_2s[222]),		
      .car(ex3_pp2_2c[221])		
   );

   tri_csa22 csa2_2_221(
      .a(ex3_pp1_4c[221]),		
      .b(ex3_pp1_4s[221]),		
      .sum(ex3_pp2_2s[221]),		
      .car(ex3_pp2_2c[220])		
   );
   assign ex3_pp2_2s[220] = ex3_pp1_4s[220];		


   assign ex4_pp2_0s_din[198:242] = ex3_pp2_0s[198:242];
   assign ex4_pp2_0c_din[198:240] = ex3_pp2_0c[198:240];
   assign ex4_pp2_1s_din[208:254] = ex3_pp2_1s[208:254];
   assign ex4_pp2_1c_din[208:252] = ex3_pp2_1c[208:252];
   assign ex4_pp2_2s_din[220:264] = ex3_pp2_2s[220:264];
   assign ex4_pp2_2c_din[220:263] = ex3_pp2_2c[220:263];


   assign ex4_pp2_0s[198:242] = (~ex4_pp2_0s_q_b[198:242]);
   assign ex4_pp2_0c[198:240] = (~ex4_pp2_0c_q_b[198:240]);

   assign ex4_pp2_1s_x[208:254] = (~ex4_pp2_1s_q_b[208:254]);		
   assign ex4_pp2_1c_x[208:252] = (~ex4_pp2_1c_q_b[208:252]);		
   assign ex4_pp2_2s_x[220:264] = (~ex4_pp2_2s_q_b[220:264]);		
   assign ex4_pp2_2c_x[220:263] = (~ex4_pp2_2c_q_b[220:263]);		

   assign ex4_pp2_1s_x_b[208:254] = (~ex4_pp2_1s_x[208:254]);		
   assign ex4_pp2_1c_x_b[208:252] = (~ex4_pp2_1c_x[208:252]);		
   assign ex4_pp2_2s_x_b[220:264] = (~ex4_pp2_2s_x[220:264]);		
   assign ex4_pp2_2c_x_b[220:263] = (~ex4_pp2_2c_x[220:263]);		

   assign ex4_pp2_1s[208:254] = (~ex4_pp2_1s_x_b[208:254]);		
   assign ex4_pp2_1c[208:252] = (~ex4_pp2_1c_x_b[208:252]);		
   assign ex4_pp2_2s[220:264] = (~ex4_pp2_2s_x_b[220:264]);		
   assign ex4_pp2_2c[220:263] = (~ex4_pp2_2c_x_b[220:263]);		




   assign ex4_pp3_0s[252] = ex4_pp2_1c[252];		
   assign ex4_pp3_0s[251] = 0;		
   assign ex4_pp3_0s[250] = 0;		
   assign ex4_pp3_0s[249] = ex4_pp2_1c[249];		
   assign ex4_pp3_0s[248] = 0;		
   assign ex4_pp3_0s[247] = ex4_pp2_1c[247];		
   assign ex4_pp3_0s[246] = ex4_pp2_1c[246];		
   assign ex4_pp3_0s[245] = ex4_pp2_1c[245];		
   assign ex4_pp3_0s[244] = ex4_pp2_1c[244];		
   assign ex4_pp3_0s[243] = ex4_pp2_1c[243];		
   assign ex4_pp3_0c[242] = ex4_pp2_1c[242];		
   assign ex4_pp3_0s[242] = ex4_pp2_0s[242];		
   assign ex4_pp3_0c[241] = 0;		
   assign ex4_pp3_0s[241] = ex4_pp2_1c[241];		
   assign ex4_pp3_0c[240] = 0;		


   tri_csa32 csa3_0_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[240]),		
      .b(ex4_pp2_0s[240]),		
      .c(ex4_pp2_1c[240]),		
      .sum(ex4_pp3_0s[240]),		
      .car(ex4_pp3_0c[239])		
   );

   tri_csa22 csa3_0_239(
      .a(ex4_pp2_0s[239]),		
      .b(ex4_pp2_1c[239]),		
      .sum(ex4_pp3_0s[239]),		
      .car(ex4_pp3_0c[238])		
   );

   tri_csa22 csa3_0_238(
      .a(ex4_pp2_0s[238]),		
      .b(ex4_pp2_1c[238]),		
      .sum(ex4_pp3_0s[238]),		
      .car(ex4_pp3_0c[237])		
   );


   tri_csa32 csa3_0_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[237]),		
      .b(ex4_pp2_0s[237]),		
      .c(ex4_pp2_1c[237]),		
      .sum(ex4_pp3_0s[237]),		
      .car(ex4_pp3_0c[236])		
   );

   tri_csa22 csa3_0_236(
      .a(ex4_pp2_0s[236]),		
      .b(ex4_pp2_1c[236]),		
      .sum(ex4_pp3_0s[236]),		
      .car(ex4_pp3_0c[235])		
   );


   tri_csa32 csa3_0_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[235]),		
      .b(ex4_pp2_0s[235]),		
      .c(ex4_pp2_1c[235]),		
      .sum(ex4_pp3_0s[235]),		
      .car(ex4_pp3_0c[234])		
   );


   tri_csa32 csa3_0_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[234]),		
      .b(ex4_pp2_0s[234]),		
      .c(ex4_pp2_1c[234]),		
      .sum(ex4_pp3_0s[234]),		
      .car(ex4_pp3_0c[233])		
   );


   tri_csa32 csa3_0_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[233]),		
      .b(ex4_pp2_0s[233]),		
      .c(ex4_pp2_1c[233]),		
      .sum(ex4_pp3_0s[233]),		
      .car(ex4_pp3_0c[232])		
   );


   tri_csa32 csa3_0_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[232]),		
      .b(ex4_pp2_0s[232]),		
      .c(ex4_pp2_1c[232]),		
      .sum(ex4_pp3_0s[232]),		
      .car(ex4_pp3_0c[231])		
   );


   tri_csa32 csa3_0_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[231]),		
      .b(ex4_pp2_0s[231]),		
      .c(ex4_pp2_1c[231]),		
      .sum(ex4_pp3_0s[231]),		
      .car(ex4_pp3_0c[230])		
   );


   tri_csa32 csa3_0_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[230]),		
      .b(ex4_pp2_0s[230]),		
      .c(ex4_pp2_1c[230]),		
      .sum(ex4_pp3_0s[230]),		
      .car(ex4_pp3_0c[229])		
   );


   tri_csa32 csa3_0_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[229]),		
      .b(ex4_pp2_0s[229]),		
      .c(ex4_pp2_1c[229]),		
      .sum(ex4_pp3_0s[229]),		
      .car(ex4_pp3_0c[228])		
   );


   tri_csa32 csa3_0_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[228]),		
      .b(ex4_pp2_0s[228]),		
      .c(ex4_pp2_1c[228]),		
      .sum(ex4_pp3_0s[228]),		
      .car(ex4_pp3_0c[227])		
   );


   tri_csa32 csa3_0_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[227]),		
      .b(ex4_pp2_0s[227]),		
      .c(ex4_pp2_1c[227]),		
      .sum(ex4_pp3_0s[227]),		
      .car(ex4_pp3_0c[226])		
   );


   tri_csa32 csa3_0_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[226]),		
      .b(ex4_pp2_0s[226]),		
      .c(ex4_pp2_1c[226]),		
      .sum(ex4_pp3_0s[226]),		
      .car(ex4_pp3_0c[225])		
   );


   tri_csa32 csa3_0_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[225]),		
      .b(ex4_pp2_0s[225]),		
      .c(ex4_pp2_1c[225]),		
      .sum(ex4_pp3_0s[225]),		
      .car(ex4_pp3_0c[224])		
   );


   tri_csa32 csa3_0_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[224]),		
      .b(ex4_pp2_0s[224]),		
      .c(ex4_pp2_1c[224]),		
      .sum(ex4_pp3_0s[224]),		
      .car(ex4_pp3_0c[223])		
   );


   tri_csa32 csa3_0_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[223]),		
      .b(ex4_pp2_0s[223]),		
      .c(ex4_pp2_1c[223]),		
      .sum(ex4_pp3_0s[223]),		
      .car(ex4_pp3_0c[222])		
   );


   tri_csa32 csa3_0_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[222]),		
      .b(ex4_pp2_0s[222]),		
      .c(ex4_pp2_1c[222]),		
      .sum(ex4_pp3_0s[222]),		
      .car(ex4_pp3_0c[221])		
   );


   tri_csa32 csa3_0_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[221]),		
      .b(ex4_pp2_0s[221]),		
      .c(ex4_pp2_1c[221]),		
      .sum(ex4_pp3_0s[221]),		
      .car(ex4_pp3_0c[220])		
   );


   tri_csa32 csa3_0_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[220]),		
      .b(ex4_pp2_0s[220]),		
      .c(ex4_pp2_1c[220]),		
      .sum(ex4_pp3_0s[220]),		
      .car(ex4_pp3_0c[219])		
   );


   tri_csa32 csa3_0_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[219]),		
      .b(ex4_pp2_0s[219]),		
      .c(ex4_pp2_1c[219]),		
      .sum(ex4_pp3_0s[219]),		
      .car(ex4_pp3_0c[218])		
   );


   tri_csa32 csa3_0_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[218]),		
      .b(ex4_pp2_0s[218]),		
      .c(ex4_pp2_1c[218]),		
      .sum(ex4_pp3_0s[218]),		
      .car(ex4_pp3_0c[217])		
   );


   tri_csa32 csa3_0_217(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[217]),		
      .b(ex4_pp2_0s[217]),		
      .c(ex4_pp2_1c[217]),		
      .sum(ex4_pp3_0s[217]),		
      .car(ex4_pp3_0c[216])		
   );


   tri_csa32 csa3_0_216(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[216]),		
      .b(ex4_pp2_0s[216]),		
      .c(ex4_pp2_1c[216]),		
      .sum(ex4_pp3_0s[216]),		
      .car(ex4_pp3_0c[215])		
   );


   tri_csa32 csa3_0_215(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[215]),		
      .b(ex4_pp2_0s[215]),		
      .c(ex4_pp2_1c[215]),		
      .sum(ex4_pp3_0s[215]),		
      .car(ex4_pp3_0c[214])		
   );


   tri_csa32 csa3_0_214(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[214]),		
      .b(ex4_pp2_0s[214]),		
      .c(ex4_pp2_1c[214]),		
      .sum(ex4_pp3_0s[214]),		
      .car(ex4_pp3_0c[213])		
   );


   tri_csa32 csa3_0_213(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[213]),		
      .b(ex4_pp2_0s[213]),		
      .c(ex4_pp2_1c[213]),		
      .sum(ex4_pp3_0s[213]),		
      .car(ex4_pp3_0c[212])		
   );


   tri_csa32 csa3_0_212(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[212]),		
      .b(ex4_pp2_0s[212]),		
      .c(ex4_pp2_1c[212]),		
      .sum(ex4_pp3_0s[212]),		
      .car(ex4_pp3_0c[211])		
   );


   tri_csa32 csa3_0_211(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[211]),		
      .b(ex4_pp2_0s[211]),		
      .c(ex4_pp2_1c[211]),		
      .sum(ex4_pp3_0s[211]),		
      .car(ex4_pp3_0c[210])		
   );


   tri_csa32 csa3_0_210(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[210]),		
      .b(ex4_pp2_0s[210]),		
      .c(ex4_pp2_1c[210]),		
      .sum(ex4_pp3_0s[210]),		
      .car(ex4_pp3_0c[209])		
   );


   tri_csa32 csa3_0_209(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[209]),		
      .b(ex4_pp2_0s[209]),		
      .c(ex4_pp2_1c[209]),		
      .sum(ex4_pp3_0s[209]),		
      .car(ex4_pp3_0c[208])		
   );


   tri_csa32 csa3_0_208(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[208]),		
      .b(ex4_pp2_0s[208]),		
      .c(ex4_pp2_1c[208]),		
      .sum(ex4_pp3_0s[208]),		
      .car(ex4_pp3_0c[207])		
   );

   tri_csa22 csa3_0_207(
      .a(ex4_pp2_0c[207]),		
      .b(ex4_pp2_0s[207]),		
      .sum(ex4_pp3_0s[207]),		
      .car(ex4_pp3_0c[206])		
   );

   tri_csa22 csa3_0_206(
      .a(ex4_pp2_0c[206]),		
      .b(ex4_pp2_0s[206]),		
      .sum(ex4_pp3_0s[206]),		
      .car(ex4_pp3_0c[205])		
   );

   tri_csa22 csa3_0_205(
      .a(ex4_pp2_0c[205]),		
      .b(ex4_pp2_0s[205]),		
      .sum(ex4_pp3_0s[205]),		
      .car(ex4_pp3_0c[204])		
   );

   tri_csa22 csa3_0_204(
      .a(ex4_pp2_0c[204]),		
      .b(ex4_pp2_0s[204]),		
      .sum(ex4_pp3_0s[204]),		
      .car(ex4_pp3_0c[203])		
   );

   tri_csa22 csa3_0_203(
      .a(ex4_pp2_0c[203]),		
      .b(ex4_pp2_0s[203]),		
      .sum(ex4_pp3_0s[203]),		
      .car(ex4_pp3_0c[202])		
   );

   tri_csa22 csa3_0_202(
      .a(ex4_pp2_0c[202]),		
      .b(ex4_pp2_0s[202]),		
      .sum(ex4_pp3_0s[202]),		
      .car(ex4_pp3_0c[201])		
   );

   tri_csa22 csa3_0_201(
      .a(ex4_pp2_0c[201]),		
      .b(ex4_pp2_0s[201]),		
      .sum(ex4_pp3_0s[201]),		
      .car(ex4_pp3_0c[200])		
   );

   tri_csa22 csa3_0_200(
      .a(ex4_pp2_0c[200]),		
      .b(ex4_pp2_0s[200]),		
      .sum(ex4_pp3_0s[200]),		
      .car(ex4_pp3_0c[199])		
   );

   tri_csa22 csa3_0_199(
      .a(ex4_pp2_0c[199]),		
      .b(ex4_pp2_0s[199]),		
      .sum(ex4_pp3_0s[199]),		
      .car(ex4_pp3_0c[198])		
   );

   tri_csa22 csa3_0_198(
      .a(ex4_pp2_0c[198]),		
      .b(ex4_pp2_0s[198]),		
      .sum(ex4_pp3_0s[198]),		
      .car(ex4_pp3_0c[197])		
   );


   assign ex4_pp3_1s[264] = ex4_pp2_2s[264];		

   tri_csa22 csa3_1_263(
      .a(ex4_pp2_2c[263]),		
      .b(ex4_pp2_2s[263]),		
      .sum(ex4_pp3_1s[263]),		
      .car(ex4_pp3_1c[262])		
   );
   assign ex4_pp3_1s[262] = ex4_pp2_2s[262];		
   assign ex4_pp3_1c[261] = ex4_pp2_2s[261];		
   assign ex4_pp3_1s[261] = ex4_pp2_2c[261];		
   assign ex4_pp3_1c[260] = 0;		
   assign ex4_pp3_1s[260] = ex4_pp2_2s[260];		
   assign ex4_pp3_1c[259] = ex4_pp2_2s[259];		
   assign ex4_pp3_1s[259] = ex4_pp2_2c[259];		
   assign ex4_pp3_1c[258] = ex4_pp2_2s[258];		
   assign ex4_pp3_1s[258] = ex4_pp2_2c[258];		
   assign ex4_pp3_1c[257] = ex4_pp2_2s[257];		
   assign ex4_pp3_1s[257] = ex4_pp2_2c[257];		
   assign ex4_pp3_1c[256] = ex4_pp2_2s[256];		
   assign ex4_pp3_1s[256] = ex4_pp2_2c[256];		
   assign ex4_pp3_1c[255] = ex4_pp2_2s[255];		
   assign ex4_pp3_1s[255] = ex4_pp2_2c[255];		
   assign ex4_pp3_1c[254] = 0;		


   tri_csa32 csa3_1_254(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[254]),		
      .b(ex4_pp2_2c[254]),		
      .c(ex4_pp2_2s[254]),		
      .sum(ex4_pp3_1s[254]),		
      .car(ex4_pp3_1c[253])		
   );

   tri_csa22 csa3_1_253(
      .a(ex4_pp2_2c[253]),		
      .b(ex4_pp2_2s[253]),		
      .sum(ex4_pp3_1s[253]),		
      .car(ex4_pp3_1c[252])		
   );


   tri_csa32 csa3_1_252(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[252]),		
      .b(ex4_pp2_2c[252]),		
      .c(ex4_pp2_2s[252]),		
      .sum(ex4_pp3_1s[252]),		
      .car(ex4_pp3_1c[251])		
   );


   tri_csa32 csa3_1_251(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[251]),		
      .b(ex4_pp2_2c[251]),		
      .c(ex4_pp2_2s[251]),		
      .sum(ex4_pp3_1s[251]),		
      .car(ex4_pp3_1c[250])		
   );


   tri_csa32 csa3_1_250(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[250]),		
      .b(ex4_pp2_2c[250]),		
      .c(ex4_pp2_2s[250]),		
      .sum(ex4_pp3_1s[250]),		
      .car(ex4_pp3_1c[249])		
   );


   tri_csa32 csa3_1_249(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[249]),		
      .b(ex4_pp2_2c[249]),		
      .c(ex4_pp2_2s[249]),		
      .sum(ex4_pp3_1s[249]),		
      .car(ex4_pp3_1c[248])		
   );


   tri_csa32 csa3_1_248(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[248]),		
      .b(ex4_pp2_2c[248]),		
      .c(ex4_pp2_2s[248]),		
      .sum(ex4_pp3_1s[248]),		
      .car(ex4_pp3_1c[247])		
   );


   tri_csa32 csa3_1_247(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[247]),		
      .b(ex4_pp2_2c[247]),		
      .c(ex4_pp2_2s[247]),		
      .sum(ex4_pp3_1s[247]),		
      .car(ex4_pp3_1c[246])		
   );


   tri_csa32 csa3_1_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[246]),		
      .b(ex4_pp2_2c[246]),		
      .c(ex4_pp2_2s[246]),		
      .sum(ex4_pp3_1s[246]),		
      .car(ex4_pp3_1c[245])		
   );


   tri_csa32 csa3_1_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[245]),		
      .b(ex4_pp2_2c[245]),		
      .c(ex4_pp2_2s[245]),		
      .sum(ex4_pp3_1s[245]),		
      .car(ex4_pp3_1c[244])		
   );


   tri_csa32 csa3_1_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[244]),		
      .b(ex4_pp2_2c[244]),		
      .c(ex4_pp2_2s[244]),		
      .sum(ex4_pp3_1s[244]),		
      .car(ex4_pp3_1c[243])		
   );


   tri_csa32 csa3_1_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[243]),		
      .b(ex4_pp2_2c[243]),		
      .c(ex4_pp2_2s[243]),		
      .sum(ex4_pp3_1s[243]),		
      .car(ex4_pp3_1c[242])		
   );


   tri_csa32 csa3_1_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[242]),		
      .b(ex4_pp2_2c[242]),		
      .c(ex4_pp2_2s[242]),		
      .sum(ex4_pp3_1s[242]),		
      .car(ex4_pp3_1c[241])		
   );


   tri_csa32 csa3_1_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[241]),		
      .b(ex4_pp2_2c[241]),		
      .c(ex4_pp2_2s[241]),		
      .sum(ex4_pp3_1s[241]),		
      .car(ex4_pp3_1c[240])		
   );


   tri_csa32 csa3_1_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[240]),		
      .b(ex4_pp2_2c[240]),		
      .c(ex4_pp2_2s[240]),		
      .sum(ex4_pp3_1s[240]),		
      .car(ex4_pp3_1c[239])		
   );


   tri_csa32 csa3_1_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[239]),		
      .b(ex4_pp2_2c[239]),		
      .c(ex4_pp2_2s[239]),		
      .sum(ex4_pp3_1s[239]),		
      .car(ex4_pp3_1c[238])		
   );


   tri_csa32 csa3_1_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[238]),		
      .b(ex4_pp2_2c[238]),		
      .c(ex4_pp2_2s[238]),		
      .sum(ex4_pp3_1s[238]),		
      .car(ex4_pp3_1c[237])		
   );


   tri_csa32 csa3_1_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[237]),		
      .b(ex4_pp2_2c[237]),		
      .c(ex4_pp2_2s[237]),		
      .sum(ex4_pp3_1s[237]),		
      .car(ex4_pp3_1c[236])		
   );


   tri_csa32 csa3_1_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[236]),		
      .b(ex4_pp2_2c[236]),		
      .c(ex4_pp2_2s[236]),		
      .sum(ex4_pp3_1s[236]),		
      .car(ex4_pp3_1c[235])		
   );


   tri_csa32 csa3_1_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[235]),		
      .b(ex4_pp2_2c[235]),		
      .c(ex4_pp2_2s[235]),		
      .sum(ex4_pp3_1s[235]),		
      .car(ex4_pp3_1c[234])		
   );


   tri_csa32 csa3_1_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[234]),		
      .b(ex4_pp2_2c[234]),		
      .c(ex4_pp2_2s[234]),		
      .sum(ex4_pp3_1s[234]),		
      .car(ex4_pp3_1c[233])		
   );


   tri_csa32 csa3_1_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[233]),		
      .b(ex4_pp2_2c[233]),		
      .c(ex4_pp2_2s[233]),		
      .sum(ex4_pp3_1s[233]),		
      .car(ex4_pp3_1c[232])		
   );


   tri_csa32 csa3_1_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[232]),		
      .b(ex4_pp2_2c[232]),		
      .c(ex4_pp2_2s[232]),		
      .sum(ex4_pp3_1s[232]),		
      .car(ex4_pp3_1c[231])		
   );


   tri_csa32 csa3_1_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[231]),		
      .b(ex4_pp2_2c[231]),		
      .c(ex4_pp2_2s[231]),		
      .sum(ex4_pp3_1s[231]),		
      .car(ex4_pp3_1c[230])		
   );


   tri_csa32 csa3_1_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[230]),		
      .b(ex4_pp2_2c[230]),		
      .c(ex4_pp2_2s[230]),		
      .sum(ex4_pp3_1s[230]),		
      .car(ex4_pp3_1c[229])		
   );


   tri_csa32 csa3_1_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[229]),		
      .b(ex4_pp2_2c[229]),		
      .c(ex4_pp2_2s[229]),		
      .sum(ex4_pp3_1s[229]),		
      .car(ex4_pp3_1c[228])		
   );


   tri_csa32 csa3_1_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[228]),		
      .b(ex4_pp2_2c[228]),		
      .c(ex4_pp2_2s[228]),		
      .sum(ex4_pp3_1s[228]),		
      .car(ex4_pp3_1c[227])		
   );


   tri_csa32 csa3_1_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[227]),		
      .b(ex4_pp2_2c[227]),		
      .c(ex4_pp2_2s[227]),		
      .sum(ex4_pp3_1s[227]),		
      .car(ex4_pp3_1c[226])		
   );


   tri_csa32 csa3_1_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[226]),		
      .b(ex4_pp2_2c[226]),		
      .c(ex4_pp2_2s[226]),		
      .sum(ex4_pp3_1s[226]),		
      .car(ex4_pp3_1c[225])		
   );


   tri_csa32 csa3_1_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[225]),		
      .b(ex4_pp2_2c[225]),		
      .c(ex4_pp2_2s[225]),		
      .sum(ex4_pp3_1s[225]),		
      .car(ex4_pp3_1c[224])		
   );


   tri_csa32 csa3_1_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[224]),		
      .b(ex4_pp2_2c[224]),		
      .c(ex4_pp2_2s[224]),		
      .sum(ex4_pp3_1s[224]),		
      .car(ex4_pp3_1c[223])		
   );


   tri_csa32 csa3_1_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[223]),		
      .b(ex4_pp2_2c[223]),		
      .c(ex4_pp2_2s[223]),		
      .sum(ex4_pp3_1s[223]),		
      .car(ex4_pp3_1c[222])		
   );


   tri_csa32 csa3_1_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[222]),		
      .b(ex4_pp2_2c[222]),		
      .c(ex4_pp2_2s[222]),		
      .sum(ex4_pp3_1s[222]),		
      .car(ex4_pp3_1c[221])		
   );


   tri_csa32 csa3_1_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[221]),		
      .b(ex4_pp2_2c[221]),		
      .c(ex4_pp2_2s[221]),		
      .sum(ex4_pp3_1s[221]),		
      .car(ex4_pp3_1c[220])		
   );


   tri_csa32 csa3_1_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[220]),		
      .b(ex4_pp2_2c[220]),		
      .c(ex4_pp2_2s[220]),		
      .sum(ex4_pp3_1s[220]),		
      .car(ex4_pp3_1c[219])		
   );
   assign ex4_pp3_1s[219] = ex4_pp2_1s[219];		
   assign ex4_pp3_1s[218] = ex4_pp2_1s[218];		
   assign ex4_pp3_1s[217] = ex4_pp2_1s[217];		
   assign ex4_pp3_1s[216] = ex4_pp2_1s[216];		
   assign ex4_pp3_1s[215] = ex4_pp2_1s[215];		
   assign ex4_pp3_1s[214] = ex4_pp2_1s[214];		
   assign ex4_pp3_1s[213] = ex4_pp2_1s[213];		
   assign ex4_pp3_1s[212] = ex4_pp2_1s[212];		
   assign ex4_pp3_1s[211] = ex4_pp2_1s[211];		
   assign ex4_pp3_1s[210] = ex4_pp2_1s[210];		
   assign ex4_pp3_1s[209] = ex4_pp2_1s[209];		
   assign ex4_pp3_1s[208] = ex4_pp2_1s[208];		




   assign ex4_pp4_0s[264] = ex4_pp3_1s[264];		
   assign ex4_pp4_0s[263] = ex4_pp3_1s[263];		
   assign ex4_pp4_0c[262] = ex4_pp3_1s[262];		
   assign ex4_pp4_0s[262] = ex4_pp3_1c[262];		
   assign ex4_pp4_0c[261] = ex4_pp3_1s[261];		
   assign ex4_pp4_0s[261] = ex4_pp3_1c[261];		
   assign ex4_pp4_0c[260] = 0;		
   assign ex4_pp4_0s[260] = ex4_pp3_1s[260];		
   assign ex4_pp4_0c[259] = ex4_pp3_1s[259];		
   assign ex4_pp4_0s[259] = ex4_pp3_1c[259];		
   assign ex4_pp4_0c[258] = ex4_pp3_1s[258];		
   assign ex4_pp4_0s[258] = ex4_pp3_1c[258];		
   assign ex4_pp4_0c[257] = ex4_pp3_1s[257];		
   assign ex4_pp4_0s[257] = ex4_pp3_1c[257];		
   assign ex4_pp4_0c[256] = ex4_pp3_1s[256];		
   assign ex4_pp4_0s[256] = ex4_pp3_1c[256];		
   assign ex4_pp4_0c[255] = ex4_pp3_1s[255];		
   assign ex4_pp4_0s[255] = ex4_pp3_1c[255];		
   assign ex4_pp4_0c[254] = 0;		
   assign ex4_pp4_0s[254] = ex4_pp3_1s[254];		
   assign ex4_pp4_0c[253] = ex4_pp3_1s[253];		
   assign ex4_pp4_0s[253] = ex4_pp3_1c[253];		
   assign ex4_pp4_0c[252] = 0;		


   tri_csa32 csa4_0_252(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[252]),		
      .b(ex4_pp3_1c[252]),		
      .c(ex4_pp3_1s[252]),		
      .sum(ex4_pp4_0s[252]),		
      .car(ex4_pp4_0c[251])		
   );

   tri_csa22 csa4_0_251(
      .a(ex4_pp3_1c[251]),		
      .b(ex4_pp3_1s[251]),		
      .sum(ex4_pp4_0s[251]),		
      .car(ex4_pp4_0c[250])		
   );

   tri_csa22 csa4_0_250(
      .a(ex4_pp3_1c[250]),		
      .b(ex4_pp3_1s[250]),		
      .sum(ex4_pp4_0s[250]),		
      .car(ex4_pp4_0c[249])		
   );


   tri_csa32 csa4_0_249(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[249]),		
      .b(ex4_pp3_1c[249]),		
      .c(ex4_pp3_1s[249]),		
      .sum(ex4_pp4_0s[249]),		
      .car(ex4_pp4_0c[248])		
   );

   tri_csa22 csa4_0_248(
      .a(ex4_pp3_1c[248]),		
      .b(ex4_pp3_1s[248]),		
      .sum(ex4_pp4_0s[248]),		
      .car(ex4_pp4_0c[247])		
   );


   tri_csa32 csa4_0_247(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[247]),		
      .b(ex4_pp3_1c[247]),		
      .c(ex4_pp3_1s[247]),		
      .sum(ex4_pp4_0s[247]),		
      .car(ex4_pp4_0c[246])		
   );


   tri_csa32 csa4_0_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[246]),		
      .b(ex4_pp3_1c[246]),		
      .c(ex4_pp3_1s[246]),		
      .sum(ex4_pp4_0s[246]),		
      .car(ex4_pp4_0c[245])		
   );


   tri_csa32 csa4_0_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[245]),		
      .b(ex4_pp3_1c[245]),		
      .c(ex4_pp3_1s[245]),		
      .sum(ex4_pp4_0s[245]),		
      .car(ex4_pp4_0c[244])		
   );


   tri_csa32 csa4_0_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[244]),		
      .b(ex4_pp3_1c[244]),		
      .c(ex4_pp3_1s[244]),		
      .sum(ex4_pp4_0s[244]),		
      .car(ex4_pp4_0c[243])		
   );


   tri_csa32 csa4_0_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[243]),		
      .b(ex4_pp3_1c[243]),		
      .c(ex4_pp3_1s[243]),		
      .sum(ex4_pp4_0s[243]),		
      .car(ex4_pp4_0c[242])		
   );
   assign ex4_pp4_0k[242] = 0;		


   tri_csa42 csa4_0_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[242]),		
      .b(ex4_pp3_0s[242]),		
      .c(ex4_pp3_1c[242]),		
      .d(ex4_pp3_1s[242]),		
      .ki(ex4_pp4_0k[242]),		
      .ko(ex4_pp4_0k[241]),		
      .sum(ex4_pp4_0s[242]),		
      .car(ex4_pp4_0c[241])		
   );


   tri_csa42 csa4_0_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[241]),		
      .b(ex4_pp3_1c[241]),		
      .c(ex4_pp3_1s[241]),		
      .d(1'b0),		
      .ki(ex4_pp4_0k[241]),		
      .ko(ex4_pp4_0k[240]),		
      .sum(ex4_pp4_0s[241]),		
      .car(ex4_pp4_0c[240])		
   );


   tri_csa42 csa4_0_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[240]),		
      .b(ex4_pp3_1c[240]),		
      .c(ex4_pp3_1s[240]),		
      .d(1'b0),		
      .ki(ex4_pp4_0k[240]),		
      .ko(ex4_pp4_0k[239]),		
      .sum(ex4_pp4_0s[240]),		
      .car(ex4_pp4_0c[239])		
   );


   tri_csa42 csa4_0_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[239]),		
      .b(ex4_pp3_0s[239]),		
      .c(ex4_pp3_1c[239]),		
      .d(ex4_pp3_1s[239]),		
      .ki(ex4_pp4_0k[239]),		
      .ko(ex4_pp4_0k[238]),		
      .sum(ex4_pp4_0s[239]),		
      .car(ex4_pp4_0c[238])		
   );


   tri_csa42 csa4_0_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[238]),		
      .b(ex4_pp3_0s[238]),		
      .c(ex4_pp3_1c[238]),		
      .d(ex4_pp3_1s[238]),		
      .ki(ex4_pp4_0k[238]),		
      .ko(ex4_pp4_0k[237]),		
      .sum(ex4_pp4_0s[238]),		
      .car(ex4_pp4_0c[237])		
   );


   tri_csa42 csa4_0_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[237]),		
      .b(ex4_pp3_0s[237]),		
      .c(ex4_pp3_1c[237]),		
      .d(ex4_pp3_1s[237]),		
      .ki(ex4_pp4_0k[237]),		
      .ko(ex4_pp4_0k[236]),		
      .sum(ex4_pp4_0s[237]),		
      .car(ex4_pp4_0c[236])		
   );


   tri_csa42 csa4_0_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[236]),		
      .b(ex4_pp3_0s[236]),		
      .c(ex4_pp3_1c[236]),		
      .d(ex4_pp3_1s[236]),		
      .ki(ex4_pp4_0k[236]),		
      .ko(ex4_pp4_0k[235]),		
      .sum(ex4_pp4_0s[236]),		
      .car(ex4_pp4_0c[235])		
   );


   tri_csa42 csa4_0_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[235]),		
      .b(ex4_pp3_0s[235]),		
      .c(ex4_pp3_1c[235]),		
      .d(ex4_pp3_1s[235]),		
      .ki(ex4_pp4_0k[235]),		
      .ko(ex4_pp4_0k[234]),		
      .sum(ex4_pp4_0s[235]),		
      .car(ex4_pp4_0c[234])		
   );


   tri_csa42 csa4_0_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[234]),		
      .b(ex4_pp3_0s[234]),		
      .c(ex4_pp3_1c[234]),		
      .d(ex4_pp3_1s[234]),		
      .ki(ex4_pp4_0k[234]),		
      .ko(ex4_pp4_0k[233]),		
      .sum(ex4_pp4_0s[234]),		
      .car(ex4_pp4_0c[233])		
   );


   tri_csa42 csa4_0_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[233]),		
      .b(ex4_pp3_0s[233]),		
      .c(ex4_pp3_1c[233]),		
      .d(ex4_pp3_1s[233]),		
      .ki(ex4_pp4_0k[233]),		
      .ko(ex4_pp4_0k[232]),		
      .sum(ex4_pp4_0s[233]),		
      .car(ex4_pp4_0c[232])		
   );


   tri_csa42 csa4_0_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[232]),		
      .b(ex4_pp3_0s[232]),		
      .c(ex4_pp3_1c[232]),		
      .d(ex4_pp3_1s[232]),		
      .ki(ex4_pp4_0k[232]),		
      .ko(ex4_pp4_0k[231]),		
      .sum(ex4_pp4_0s[232]),		
      .car(ex4_pp4_0c[231])		
   );


   tri_csa42 csa4_0_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[231]),		
      .b(ex4_pp3_0s[231]),		
      .c(ex4_pp3_1c[231]),		
      .d(ex4_pp3_1s[231]),		
      .ki(ex4_pp4_0k[231]),		
      .ko(ex4_pp4_0k[230]),		
      .sum(ex4_pp4_0s[231]),		
      .car(ex4_pp4_0c[230])		
   );


   tri_csa42 csa4_0_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[230]),		
      .b(ex4_pp3_0s[230]),		
      .c(ex4_pp3_1c[230]),		
      .d(ex4_pp3_1s[230]),		
      .ki(ex4_pp4_0k[230]),		
      .ko(ex4_pp4_0k[229]),		
      .sum(ex4_pp4_0s[230]),		
      .car(ex4_pp4_0c[229])		
   );


   tri_csa42 csa4_0_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[229]),		
      .b(ex4_pp3_0s[229]),		
      .c(ex4_pp3_1c[229]),		
      .d(ex4_pp3_1s[229]),		
      .ki(ex4_pp4_0k[229]),		
      .ko(ex4_pp4_0k[228]),		
      .sum(ex4_pp4_0s[229]),		
      .car(ex4_pp4_0c[228])		
   );


   tri_csa42 csa4_0_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[228]),		
      .b(ex4_pp3_0s[228]),		
      .c(ex4_pp3_1c[228]),		
      .d(ex4_pp3_1s[228]),		
      .ki(ex4_pp4_0k[228]),		
      .ko(ex4_pp4_0k[227]),		
      .sum(ex4_pp4_0s[228]),		
      .car(ex4_pp4_0c[227])		
   );


   tri_csa42 csa4_0_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[227]),		
      .b(ex4_pp3_0s[227]),		
      .c(ex4_pp3_1c[227]),		
      .d(ex4_pp3_1s[227]),		
      .ki(ex4_pp4_0k[227]),		
      .ko(ex4_pp4_0k[226]),		
      .sum(ex4_pp4_0s[227]),		
      .car(ex4_pp4_0c[226])		
   );


   tri_csa42 csa4_0_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[226]),		
      .b(ex4_pp3_0s[226]),		
      .c(ex4_pp3_1c[226]),		
      .d(ex4_pp3_1s[226]),		
      .ki(ex4_pp4_0k[226]),		
      .ko(ex4_pp4_0k[225]),		
      .sum(ex4_pp4_0s[226]),		
      .car(ex4_pp4_0c[225])		
   );


   tri_csa42 csa4_0_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[225]),		
      .b(ex4_pp3_0s[225]),		
      .c(ex4_pp3_1c[225]),		
      .d(ex4_pp3_1s[225]),		
      .ki(ex4_pp4_0k[225]),		
      .ko(ex4_pp4_0k[224]),		
      .sum(ex4_pp4_0s[225]),		
      .car(ex4_pp4_0c[224])		
   );


   tri_csa42 csa4_0_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[224]),		
      .b(ex4_pp3_0s[224]),		
      .c(ex4_pp3_1c[224]),		
      .d(ex4_pp3_1s[224]),		
      .ki(ex4_pp4_0k[224]),		
      .ko(ex4_pp4_0k[223]),		
      .sum(ex4_pp4_0s[224]),		
      .car(ex4_pp4_0c[223])		
   );


   tri_csa42 csa4_0_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[223]),		
      .b(ex4_pp3_0s[223]),		
      .c(ex4_pp3_1c[223]),		
      .d(ex4_pp3_1s[223]),		
      .ki(ex4_pp4_0k[223]),		
      .ko(ex4_pp4_0k[222]),		
      .sum(ex4_pp4_0s[223]),		
      .car(ex4_pp4_0c[222])		
   );


   tri_csa42 csa4_0_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[222]),		
      .b(ex4_pp3_0s[222]),		
      .c(ex4_pp3_1c[222]),		
      .d(ex4_pp3_1s[222]),		
      .ki(ex4_pp4_0k[222]),		
      .ko(ex4_pp4_0k[221]),		
      .sum(ex4_pp4_0s[222]),		
      .car(ex4_pp4_0c[221])		
   );


   tri_csa42 csa4_0_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[221]),		
      .b(ex4_pp3_0s[221]),		
      .c(ex4_pp3_1c[221]),		
      .d(ex4_pp3_1s[221]),		
      .ki(ex4_pp4_0k[221]),		
      .ko(ex4_pp4_0k[220]),		
      .sum(ex4_pp4_0s[221]),		
      .car(ex4_pp4_0c[220])		
   );


   tri_csa42 csa4_0_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[220]),		
      .b(ex4_pp3_0s[220]),		
      .c(ex4_pp3_1c[220]),		
      .d(ex4_pp3_1s[220]),		
      .ki(ex4_pp4_0k[220]),		
      .ko(ex4_pp4_0k[219]),		
      .sum(ex4_pp4_0s[220]),		
      .car(ex4_pp4_0c[219])		
   );


   tri_csa42 csa4_0_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[219]),		
      .b(ex4_pp3_0s[219]),		
      .c(ex4_pp3_1c[219]),		
      .d(ex4_pp3_1s[219]),		
      .ki(ex4_pp4_0k[219]),		
      .ko(ex4_pp4_0k[218]),		
      .sum(ex4_pp4_0s[219]),		
      .car(ex4_pp4_0c[218])		
   );


   tri_csa42 csa4_0_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[218]),		
      .b(ex4_pp3_0s[218]),		
      .c(ex4_pp3_1s[218]),		
      .d(1'b0),		
      .ki(ex4_pp4_0k[218]),		
      .ko(ex4_pp4_0k[217]),		
      .sum(ex4_pp4_0s[218]),		
      .car(ex4_pp4_0c[217])		
   );


   tri_csa42 csa4_0_217(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[217]),		
      .b(ex4_pp3_0s[217]),		
      .c(ex4_pp3_1s[217]),		
      .d(1'b0),		
      .ki(ex4_pp4_0k[217]),		
      .ko(ex4_pp4_0k[216]),		
      .sum(ex4_pp4_0s[217]),		
      .car(ex4_pp4_0c[216])		
   );


   tri_csa42 csa4_0_216(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[216]),		
      .b(ex4_pp3_0s[216]),		
      .c(ex4_pp3_1s[216]),		
      .d(1'b0),		
      .ki(ex4_pp4_0k[216]),		
      .ko(ex4_pp4_0k[215]),		
      .sum(ex4_pp4_0s[216]),		
      .car(ex4_pp4_0c[215])		
   );


   tri_csa42 csa4_0_215(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[215]),		
      .b(ex4_pp3_0s[215]),		
      .c(ex4_pp3_1s[215]),		
      .d(1'b0),		
      .ki(ex4_pp4_0k[215]),		
      .ko(ex4_pp4_0k[214]),		
      .sum(ex4_pp4_0s[215]),		
      .car(ex4_pp4_0c[214])		
   );


   tri_csa42 csa4_0_214(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[214]),		
      .b(ex4_pp3_0s[214]),		
      .c(ex4_pp3_1s[214]),		
      .d(1'b0),		
      .ki(ex4_pp4_0k[214]),		
      .ko(ex4_pp4_0k[213]),		
      .sum(ex4_pp4_0s[214]),		
      .car(ex4_pp4_0c[213])		
   );


   tri_csa42 csa4_0_213(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[213]),		
      .b(ex4_pp3_0s[213]),		
      .c(ex4_pp3_1s[213]),		
      .d(1'b0),		
      .ki(ex4_pp4_0k[213]),		
      .ko(ex4_pp4_0k[212]),		
      .sum(ex4_pp4_0s[213]),		
      .car(ex4_pp4_0c[212])		
   );


   tri_csa42 csa4_0_212(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[212]),		
      .b(ex4_pp3_0s[212]),		
      .c(ex4_pp3_1s[212]),		
      .d(1'b0),		
      .ki(ex4_pp4_0k[212]),		
      .ko(ex4_pp4_0k[211]),		
      .sum(ex4_pp4_0s[212]),		
      .car(ex4_pp4_0c[211])		
   );


   tri_csa42 csa4_0_211(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[211]),		
      .b(ex4_pp3_0s[211]),		
      .c(ex4_pp3_1s[211]),		
      .d(1'b0),		
      .ki(ex4_pp4_0k[211]),		
      .ko(ex4_pp4_0k[210]),		
      .sum(ex4_pp4_0s[211]),		
      .car(ex4_pp4_0c[210])		
   );


   tri_csa42 csa4_0_210(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[210]),		
      .b(ex4_pp3_0s[210]),		
      .c(ex4_pp3_1s[210]),		
      .d(1'b0),		
      .ki(ex4_pp4_0k[210]),		
      .ko(ex4_pp4_0k[209]),		
      .sum(ex4_pp4_0s[210]),		
      .car(ex4_pp4_0c[209])		
   );


   tri_csa42 csa4_0_209(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[209]),		
      .b(ex4_pp3_0s[209]),		
      .c(ex4_pp3_1s[209]),		
      .d(1'b0),		
      .ki(ex4_pp4_0k[209]),		
      .ko(ex4_pp4_0k[208]),		
      .sum(ex4_pp4_0s[209]),		
      .car(ex4_pp4_0c[208])		
   );


   tri_csa42 csa4_0_208(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[208]),		
      .b(ex4_pp3_0s[208]),		
      .c(ex4_pp3_1s[208]),		
      .d(1'b0),		
      .ki(ex4_pp4_0k[208]),		
      .ko(ex4_pp4_0k[207]),		
      .sum(ex4_pp4_0s[208]),		
      .car(ex4_pp4_0c[207])		
   );


   tri_csa32 csa4_0_207(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[207]),		
      .b(ex4_pp3_0s[207]),		
      .c(ex4_pp4_0k[207]),		
      .sum(ex4_pp4_0s[207]),		
      .car(ex4_pp4_0c[206])		
   );

   tri_csa22 csa4_0_206(
      .a(ex4_pp3_0c[206]),		
      .b(ex4_pp3_0s[206]),		
      .sum(ex4_pp4_0s[206]),		
      .car(ex4_pp4_0c[205])		
   );

   tri_csa22 csa4_0_205(
      .a(ex4_pp3_0c[205]),		
      .b(ex4_pp3_0s[205]),		
      .sum(ex4_pp4_0s[205]),		
      .car(ex4_pp4_0c[204])		
   );

   tri_csa22 csa4_0_204(
      .a(ex4_pp3_0c[204]),		
      .b(ex4_pp3_0s[204]),		
      .sum(ex4_pp4_0s[204]),		
      .car(ex4_pp4_0c[203])		
   );

   tri_csa22 csa4_0_203(
      .a(ex4_pp3_0c[203]),		
      .b(ex4_pp3_0s[203]),		
      .sum(ex4_pp4_0s[203]),		
      .car(ex4_pp4_0c[202])		
   );

   tri_csa22 csa4_0_202(
      .a(ex4_pp3_0c[202]),		
      .b(ex4_pp3_0s[202]),		
      .sum(ex4_pp4_0s[202]),		
      .car(ex4_pp4_0c[201])		
   );

   tri_csa22 csa4_0_201(
      .a(ex4_pp3_0c[201]),		
      .b(ex4_pp3_0s[201]),		
      .sum(ex4_pp4_0s[201]),		
      .car(ex4_pp4_0c[200])		
   );

   tri_csa22 csa4_0_200(
      .a(ex4_pp3_0c[200]),		
      .b(ex4_pp3_0s[200]),		
      .sum(ex4_pp4_0s[200]),		
      .car(ex4_pp4_0c[199])		
   );

   tri_csa22 csa4_0_199(
      .a(ex4_pp3_0c[199]),		
      .b(ex4_pp3_0s[199]),		
      .sum(ex4_pp4_0s[199]),		
      .car(ex4_pp4_0c[198])		
   );

   tri_csa22 csa4_0_198(
      .a(ex4_pp3_0c[198]),		
      .b(ex4_pp3_0s[198]),		
      .sum(ex4_pp4_0s[198]),		
      .car(ex4_pp4_0c[197])		
   );
   assign ex4_pp4_0s[197] = ex4_pp3_0c[197];		





   tri_csa22 csa5_0_264(
      .a(ex4_pp4_0s[264]),		
      .b(ex4_recycle_s[264]),		
      .sum(ex4_pp5_0s[264]),		
      .car(ex4_pp5_0c[263])		
   );


   tri_csa32 csa5_0_263(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0s[263]),		
      .b(ex4_recycle_c[263]),		
      .c(ex4_recycle_s[263]),		
      .sum(ex4_pp5_0s[263]),		
      .car(ex4_pp5_0c[262])		
   );
   assign ex4_pp5_0k[262] = 0;		


   tri_csa42 csa5_0_262(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[262]),		
      .b(ex4_pp4_0s[262]),		
      .c(ex4_recycle_c[262]),		
      .d(ex4_recycle_s[262]),		
      .ki(ex4_pp5_0k[262]),		
      .ko(ex4_pp5_0k[261]),		
      .sum(ex4_pp5_0s[262]),		
      .car(ex4_pp5_0c[261])		
   );


   tri_csa42 csa5_0_261(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[261]),		
      .b(ex4_pp4_0s[261]),		
      .c(ex4_recycle_c[261]),		
      .d(ex4_recycle_s[261]),		
      .ki(ex4_pp5_0k[261]),		
      .ko(ex4_pp5_0k[260]),		
      .sum(ex4_pp5_0s[261]),		
      .car(ex4_pp5_0c[260])		
   );


   tri_csa42 csa5_0_260(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0s[260]),		
      .b(ex4_recycle_c[260]),		
      .c(ex4_recycle_s[260]),		
      .d(1'b0),		
      .ki(ex4_pp5_0k[260]),		
      .ko(ex4_pp5_0k[259]),		
      .sum(ex4_pp5_0s[260]),		
      .car(ex4_pp5_0c[259])		
   );


   tri_csa42 csa5_0_259(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[259]),		
      .b(ex4_pp4_0s[259]),		
      .c(ex4_recycle_c[259]),		
      .d(ex4_recycle_s[259]),		
      .ki(ex4_pp5_0k[259]),		
      .ko(ex4_pp5_0k[258]),		
      .sum(ex4_pp5_0s[259]),		
      .car(ex4_pp5_0c[258])		
   );


   tri_csa42 csa5_0_258(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[258]),		
      .b(ex4_pp4_0s[258]),		
      .c(ex4_recycle_c[258]),		
      .d(ex4_recycle_s[258]),		
      .ki(ex4_pp5_0k[258]),		
      .ko(ex4_pp5_0k[257]),		
      .sum(ex4_pp5_0s[258]),		
      .car(ex4_pp5_0c[257])		
   );


   tri_csa42 csa5_0_257(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[257]),		
      .b(ex4_pp4_0s[257]),		
      .c(ex4_recycle_c[257]),		
      .d(ex4_recycle_s[257]),		
      .ki(ex4_pp5_0k[257]),		
      .ko(ex4_pp5_0k[256]),		
      .sum(ex4_pp5_0s[257]),		
      .car(ex4_pp5_0c[256])		
   );


   tri_csa42 csa5_0_256(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[256]),		
      .b(ex4_pp4_0s[256]),		
      .c(ex4_recycle_c[256]),		
      .d(ex4_recycle_s[256]),		
      .ki(ex4_pp5_0k[256]),		
      .ko(ex4_pp5_0k[255]),		
      .sum(ex4_pp5_0s[256]),		
      .car(ex4_pp5_0c[255])		
   );


   tri_csa42 csa5_0_255(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[255]),		
      .b(ex4_pp4_0s[255]),		
      .c(ex4_recycle_c[255]),		
      .d(ex4_recycle_s[255]),		
      .ki(ex4_pp5_0k[255]),		
      .ko(ex4_pp5_0k[254]),		
      .sum(ex4_pp5_0s[255]),		
      .car(ex4_pp5_0c[254])		
   );


   tri_csa42 csa5_0_254(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0s[254]),		
      .b(ex4_recycle_c[254]),		
      .c(ex4_recycle_s[254]),		
      .d(1'b0),		
      .ki(ex4_pp5_0k[254]),		
      .ko(ex4_pp5_0k[253]),		
      .sum(ex4_pp5_0s[254]),		
      .car(ex4_pp5_0c[253])		
   );


   tri_csa42 csa5_0_253(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[253]),		
      .b(ex4_pp4_0s[253]),		
      .c(ex4_recycle_c[253]),		
      .d(ex4_recycle_s[253]),		
      .ki(ex4_pp5_0k[253]),		
      .ko(ex4_pp5_0k[252]),		
      .sum(ex4_pp5_0s[253]),		
      .car(ex4_pp5_0c[252])		
   );


   tri_csa42 csa5_0_252(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0s[252]),		
      .b(ex4_recycle_c[252]),		
      .c(ex4_recycle_s[252]),		
      .d(1'b0),		
      .ki(ex4_pp5_0k[252]),		
      .ko(ex4_pp5_0k[251]),		
      .sum(ex4_pp5_0s[252]),		
      .car(ex4_pp5_0c[251])		
   );


   tri_csa42 csa5_0_251(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[251]),		
      .b(ex4_pp4_0s[251]),		
      .c(ex4_recycle_c[251]),		
      .d(ex4_recycle_s[251]),		
      .ki(ex4_pp5_0k[251]),		
      .ko(ex4_pp5_0k[250]),		
      .sum(ex4_pp5_0s[251]),		
      .car(ex4_pp5_0c[250])		
   );


   tri_csa42 csa5_0_250(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[250]),		
      .b(ex4_pp4_0s[250]),		
      .c(ex4_recycle_c[250]),		
      .d(ex4_recycle_s[250]),		
      .ki(ex4_pp5_0k[250]),		
      .ko(ex4_pp5_0k[249]),		
      .sum(ex4_pp5_0s[250]),		
      .car(ex4_pp5_0c[249])		
   );


   tri_csa42 csa5_0_249(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[249]),		
      .b(ex4_pp4_0s[249]),		
      .c(ex4_recycle_c[249]),		
      .d(ex4_recycle_s[249]),		
      .ki(ex4_pp5_0k[249]),		
      .ko(ex4_pp5_0k[248]),		
      .sum(ex4_pp5_0s[249]),		
      .car(ex4_pp5_0c[248])		
   );


   tri_csa42 csa5_0_248(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[248]),		
      .b(ex4_pp4_0s[248]),		
      .c(ex4_recycle_c[248]),		
      .d(ex4_recycle_s[248]),		
      .ki(ex4_pp5_0k[248]),		
      .ko(ex4_pp5_0k[247]),		
      .sum(ex4_pp5_0s[248]),		
      .car(ex4_pp5_0c[247])		
   );


   tri_csa42 csa5_0_247(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[247]),		
      .b(ex4_pp4_0s[247]),		
      .c(ex4_recycle_c[247]),		
      .d(ex4_recycle_s[247]),		
      .ki(ex4_pp5_0k[247]),		
      .ko(ex4_pp5_0k[246]),		
      .sum(ex4_pp5_0s[247]),		
      .car(ex4_pp5_0c[246])		
   );


   tri_csa42 csa5_0_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[246]),		
      .b(ex4_pp4_0s[246]),		
      .c(ex4_recycle_c[246]),		
      .d(ex4_recycle_s[246]),		
      .ki(ex4_pp5_0k[246]),		
      .ko(ex4_pp5_0k[245]),		
      .sum(ex4_pp5_0s[246]),		
      .car(ex4_pp5_0c[245])		
   );


   tri_csa42 csa5_0_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[245]),		
      .b(ex4_pp4_0s[245]),		
      .c(ex4_recycle_c[245]),		
      .d(ex4_recycle_s[245]),		
      .ki(ex4_pp5_0k[245]),		
      .ko(ex4_pp5_0k[244]),		
      .sum(ex4_pp5_0s[245]),		
      .car(ex4_pp5_0c[244])		
   );


   tri_csa42 csa5_0_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[244]),		
      .b(ex4_pp4_0s[244]),		
      .c(ex4_recycle_c[244]),		
      .d(ex4_recycle_s[244]),		
      .ki(ex4_pp5_0k[244]),		
      .ko(ex4_pp5_0k[243]),		
      .sum(ex4_pp5_0s[244]),		
      .car(ex4_pp5_0c[243])		
   );


   tri_csa42 csa5_0_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[243]),		
      .b(ex4_pp4_0s[243]),		
      .c(ex4_recycle_c[243]),		
      .d(ex4_recycle_s[243]),		
      .ki(ex4_pp5_0k[243]),		
      .ko(ex4_pp5_0k[242]),		
      .sum(ex4_pp5_0s[243]),		
      .car(ex4_pp5_0c[242])		
   );


   tri_csa42 csa5_0_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[242]),		
      .b(ex4_pp4_0s[242]),		
      .c(ex4_recycle_c[242]),		
      .d(ex4_recycle_s[242]),		
      .ki(ex4_pp5_0k[242]),		
      .ko(ex4_pp5_0k[241]),		
      .sum(ex4_pp5_0s[242]),		
      .car(ex4_pp5_0c[241])		
   );


   tri_csa42 csa5_0_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[241]),		
      .b(ex4_pp4_0s[241]),		
      .c(ex4_recycle_c[241]),		
      .d(ex4_recycle_s[241]),		
      .ki(ex4_pp5_0k[241]),		
      .ko(ex4_pp5_0k[240]),		
      .sum(ex4_pp5_0s[241]),		
      .car(ex4_pp5_0c[240])		
   );


   tri_csa42 csa5_0_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[240]),		
      .b(ex4_pp4_0s[240]),		
      .c(ex4_recycle_c[240]),		
      .d(ex4_recycle_s[240]),		
      .ki(ex4_pp5_0k[240]),		
      .ko(ex4_pp5_0k[239]),		
      .sum(ex4_pp5_0s[240]),		
      .car(ex4_pp5_0c[239])		
   );


   tri_csa42 csa5_0_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[239]),		
      .b(ex4_pp4_0s[239]),		
      .c(ex4_recycle_c[239]),		
      .d(ex4_recycle_s[239]),		
      .ki(ex4_pp5_0k[239]),		
      .ko(ex4_pp5_0k[238]),		
      .sum(ex4_pp5_0s[239]),		
      .car(ex4_pp5_0c[238])		
   );


   tri_csa42 csa5_0_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[238]),		
      .b(ex4_pp4_0s[238]),		
      .c(ex4_recycle_c[238]),		
      .d(ex4_recycle_s[238]),		
      .ki(ex4_pp5_0k[238]),		
      .ko(ex4_pp5_0k[237]),		
      .sum(ex4_pp5_0s[238]),		
      .car(ex4_pp5_0c[237])		
   );


   tri_csa42 csa5_0_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[237]),		
      .b(ex4_pp4_0s[237]),		
      .c(ex4_recycle_c[237]),		
      .d(ex4_recycle_s[237]),		
      .ki(ex4_pp5_0k[237]),		
      .ko(ex4_pp5_0k[236]),		
      .sum(ex4_pp5_0s[237]),		
      .car(ex4_pp5_0c[236])		
   );


   tri_csa42 csa5_0_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[236]),		
      .b(ex4_pp4_0s[236]),		
      .c(ex4_recycle_c[236]),		
      .d(ex4_recycle_s[236]),		
      .ki(ex4_pp5_0k[236]),		
      .ko(ex4_pp5_0k[235]),		
      .sum(ex4_pp5_0s[236]),		
      .car(ex4_pp5_0c[235])		
   );


   tri_csa42 csa5_0_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[235]),		
      .b(ex4_pp4_0s[235]),		
      .c(ex4_recycle_c[235]),		
      .d(ex4_recycle_s[235]),		
      .ki(ex4_pp5_0k[235]),		
      .ko(ex4_pp5_0k[234]),		
      .sum(ex4_pp5_0s[235]),		
      .car(ex4_pp5_0c[234])		
   );


   tri_csa42 csa5_0_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[234]),		
      .b(ex4_pp4_0s[234]),		
      .c(ex4_recycle_c[234]),		
      .d(ex4_recycle_s[234]),		
      .ki(ex4_pp5_0k[234]),		
      .ko(ex4_pp5_0k[233]),		
      .sum(ex4_pp5_0s[234]),		
      .car(ex4_pp5_0c[233])		
   );


   tri_csa42 csa5_0_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[233]),		
      .b(ex4_pp4_0s[233]),		
      .c(ex4_recycle_c[233]),		
      .d(ex4_recycle_s[233]),		
      .ki(ex4_pp5_0k[233]),		
      .ko(ex4_pp5_0k[232]),		
      .sum(ex4_pp5_0s[233]),		
      .car(ex4_pp5_0c[232])		
   );


   tri_csa42 csa5_0_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[232]),		
      .b(ex4_pp4_0s[232]),		
      .c(ex4_recycle_c[232]),		
      .d(ex4_recycle_s[232]),		
      .ki(ex4_pp5_0k[232]),		
      .ko(ex4_pp5_0k[231]),		
      .sum(ex4_pp5_0s[232]),		
      .car(ex4_pp5_0c[231])		
   );


   tri_csa42 csa5_0_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[231]),		
      .b(ex4_pp4_0s[231]),		
      .c(ex4_recycle_c[231]),		
      .d(ex4_recycle_s[231]),		
      .ki(ex4_pp5_0k[231]),		
      .ko(ex4_pp5_0k[230]),		
      .sum(ex4_pp5_0s[231]),		
      .car(ex4_pp5_0c[230])		
   );


   tri_csa42 csa5_0_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[230]),		
      .b(ex4_pp4_0s[230]),		
      .c(ex4_recycle_c[230]),		
      .d(ex4_recycle_s[230]),		
      .ki(ex4_pp5_0k[230]),		
      .ko(ex4_pp5_0k[229]),		
      .sum(ex4_pp5_0s[230]),		
      .car(ex4_pp5_0c[229])		
   );


   tri_csa42 csa5_0_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[229]),		
      .b(ex4_pp4_0s[229]),		
      .c(ex4_recycle_c[229]),		
      .d(ex4_recycle_s[229]),		
      .ki(ex4_pp5_0k[229]),		
      .ko(ex4_pp5_0k[228]),		
      .sum(ex4_pp5_0s[229]),		
      .car(ex4_pp5_0c[228])		
   );


   tri_csa42 csa5_0_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[228]),		
      .b(ex4_pp4_0s[228]),		
      .c(ex4_recycle_c[228]),		
      .d(ex4_recycle_s[228]),		
      .ki(ex4_pp5_0k[228]),		
      .ko(ex4_pp5_0k[227]),		
      .sum(ex4_pp5_0s[228]),		
      .car(ex4_pp5_0c[227])		
   );


   tri_csa42 csa5_0_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[227]),		
      .b(ex4_pp4_0s[227]),		
      .c(ex4_recycle_c[227]),		
      .d(ex4_recycle_s[227]),		
      .ki(ex4_pp5_0k[227]),		
      .ko(ex4_pp5_0k[226]),		
      .sum(ex4_pp5_0s[227]),		
      .car(ex4_pp5_0c[226])		
   );


   tri_csa42 csa5_0_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[226]),		
      .b(ex4_pp4_0s[226]),		
      .c(ex4_recycle_c[226]),		
      .d(ex4_recycle_s[226]),		
      .ki(ex4_pp5_0k[226]),		
      .ko(ex4_pp5_0k[225]),		
      .sum(ex4_pp5_0s[226]),		
      .car(ex4_pp5_0c[225])		
   );


   tri_csa42 csa5_0_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[225]),		
      .b(ex4_pp4_0s[225]),		
      .c(ex4_recycle_c[225]),		
      .d(ex4_recycle_s[225]),		
      .ki(ex4_pp5_0k[225]),		
      .ko(ex4_pp5_0k[224]),		
      .sum(ex4_pp5_0s[225]),		
      .car(ex4_pp5_0c[224])		
   );


   tri_csa42 csa5_0_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[224]),		
      .b(ex4_pp4_0s[224]),		
      .c(ex4_recycle_c[224]),		
      .d(ex4_recycle_s[224]),		
      .ki(ex4_pp5_0k[224]),		
      .ko(ex4_pp5_0k[223]),		
      .sum(ex4_pp5_0s[224]),		
      .car(ex4_pp5_0c[223])		
   );


   tri_csa42 csa5_0_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[223]),		
      .b(ex4_pp4_0s[223]),		
      .c(ex4_recycle_c[223]),		
      .d(ex4_recycle_s[223]),		
      .ki(ex4_pp5_0k[223]),		
      .ko(ex4_pp5_0k[222]),		
      .sum(ex4_pp5_0s[223]),		
      .car(ex4_pp5_0c[222])		
   );


   tri_csa42 csa5_0_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[222]),		
      .b(ex4_pp4_0s[222]),		
      .c(ex4_recycle_c[222]),		
      .d(ex4_recycle_s[222]),		
      .ki(ex4_pp5_0k[222]),		
      .ko(ex4_pp5_0k[221]),		
      .sum(ex4_pp5_0s[222]),		
      .car(ex4_pp5_0c[221])		
   );


   tri_csa42 csa5_0_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[221]),		
      .b(ex4_pp4_0s[221]),		
      .c(ex4_recycle_c[221]),		
      .d(ex4_recycle_s[221]),		
      .ki(ex4_pp5_0k[221]),		
      .ko(ex4_pp5_0k[220]),		
      .sum(ex4_pp5_0s[221]),		
      .car(ex4_pp5_0c[220])		
   );


   tri_csa42 csa5_0_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[220]),		
      .b(ex4_pp4_0s[220]),		
      .c(ex4_recycle_c[220]),		
      .d(ex4_recycle_s[220]),		
      .ki(ex4_pp5_0k[220]),		
      .ko(ex4_pp5_0k[219]),		
      .sum(ex4_pp5_0s[220]),		
      .car(ex4_pp5_0c[219])		
   );


   tri_csa42 csa5_0_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[219]),		
      .b(ex4_pp4_0s[219]),		
      .c(ex4_recycle_c[219]),		
      .d(ex4_recycle_s[219]),		
      .ki(ex4_pp5_0k[219]),		
      .ko(ex4_pp5_0k[218]),		
      .sum(ex4_pp5_0s[219]),		
      .car(ex4_pp5_0c[218])		
   );


   tri_csa42 csa5_0_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[218]),		
      .b(ex4_pp4_0s[218]),		
      .c(ex4_recycle_c[218]),		
      .d(ex4_recycle_s[218]),		
      .ki(ex4_pp5_0k[218]),		
      .ko(ex4_pp5_0k[217]),		
      .sum(ex4_pp5_0s[218]),		
      .car(ex4_pp5_0c[217])		
   );


   tri_csa42 csa5_0_217(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[217]),		
      .b(ex4_pp4_0s[217]),		
      .c(ex4_recycle_c[217]),		
      .d(ex4_recycle_s[217]),		
      .ki(ex4_pp5_0k[217]),		
      .ko(ex4_pp5_0k[216]),		
      .sum(ex4_pp5_0s[217]),		
      .car(ex4_pp5_0c[216])		
   );


   tri_csa42 csa5_0_216(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[216]),		
      .b(ex4_pp4_0s[216]),		
      .c(ex4_recycle_c[216]),		
      .d(ex4_recycle_s[216]),		
      .ki(ex4_pp5_0k[216]),		
      .ko(ex4_pp5_0k[215]),		
      .sum(ex4_pp5_0s[216]),		
      .car(ex4_pp5_0c[215])		
   );


   tri_csa42 csa5_0_215(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[215]),		
      .b(ex4_pp4_0s[215]),		
      .c(ex4_recycle_c[215]),		
      .d(ex4_recycle_s[215]),		
      .ki(ex4_pp5_0k[215]),		
      .ko(ex4_pp5_0k[214]),		
      .sum(ex4_pp5_0s[215]),		
      .car(ex4_pp5_0c[214])		
   );


   tri_csa42 csa5_0_214(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[214]),		
      .b(ex4_pp4_0s[214]),		
      .c(ex4_recycle_c[214]),		
      .d(ex4_recycle_s[214]),		
      .ki(ex4_pp5_0k[214]),		
      .ko(ex4_pp5_0k[213]),		
      .sum(ex4_pp5_0s[214]),		
      .car(ex4_pp5_0c[213])		
   );


   tri_csa42 csa5_0_213(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[213]),		
      .b(ex4_pp4_0s[213]),		
      .c(ex4_recycle_c[213]),		
      .d(ex4_recycle_s[213]),		
      .ki(ex4_pp5_0k[213]),		
      .ko(ex4_pp5_0k[212]),		
      .sum(ex4_pp5_0s[213]),		
      .car(ex4_pp5_0c[212])		
   );


   tri_csa42 csa5_0_212(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[212]),		
      .b(ex4_pp4_0s[212]),		
      .c(ex4_recycle_c[212]),		
      .d(ex4_recycle_s[212]),		
      .ki(ex4_pp5_0k[212]),		
      .ko(ex4_pp5_0k[211]),		
      .sum(ex4_pp5_0s[212]),		
      .car(ex4_pp5_0c[211])		
   );


   tri_csa42 csa5_0_211(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[211]),		
      .b(ex4_pp4_0s[211]),		
      .c(ex4_recycle_c[211]),		
      .d(ex4_recycle_s[211]),		
      .ki(ex4_pp5_0k[211]),		
      .ko(ex4_pp5_0k[210]),		
      .sum(ex4_pp5_0s[211]),		
      .car(ex4_pp5_0c[210])		
   );


   tri_csa42 csa5_0_210(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[210]),		
      .b(ex4_pp4_0s[210]),		
      .c(ex4_recycle_c[210]),		
      .d(ex4_recycle_s[210]),		
      .ki(ex4_pp5_0k[210]),		
      .ko(ex4_pp5_0k[209]),		
      .sum(ex4_pp5_0s[210]),		
      .car(ex4_pp5_0c[209])		
   );


   tri_csa42 csa5_0_209(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[209]),		
      .b(ex4_pp4_0s[209]),		
      .c(ex4_recycle_c[209]),		
      .d(ex4_recycle_s[209]),		
      .ki(ex4_pp5_0k[209]),		
      .ko(ex4_pp5_0k[208]),		
      .sum(ex4_pp5_0s[209]),		
      .car(ex4_pp5_0c[208])		
   );


   tri_csa42 csa5_0_208(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[208]),		
      .b(ex4_pp4_0s[208]),		
      .c(ex4_recycle_c[208]),		
      .d(ex4_recycle_s[208]),		
      .ki(ex4_pp5_0k[208]),		
      .ko(ex4_pp5_0k[207]),		
      .sum(ex4_pp5_0s[208]),		
      .car(ex4_pp5_0c[207])		
   );


   tri_csa42 csa5_0_207(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[207]),		
      .b(ex4_pp4_0s[207]),		
      .c(ex4_recycle_c[207]),		
      .d(ex4_recycle_s[207]),		
      .ki(ex4_pp5_0k[207]),		
      .ko(ex4_pp5_0k[206]),		
      .sum(ex4_pp5_0s[207]),		
      .car(ex4_pp5_0c[206])		
   );


   tri_csa42 csa5_0_206(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[206]),		
      .b(ex4_pp4_0s[206]),		
      .c(ex4_recycle_c[206]),		
      .d(ex4_recycle_s[206]),		
      .ki(ex4_pp5_0k[206]),		
      .ko(ex4_pp5_0k[205]),		
      .sum(ex4_pp5_0s[206]),		
      .car(ex4_pp5_0c[205])		
   );


   tri_csa42 csa5_0_205(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[205]),		
      .b(ex4_pp4_0s[205]),		
      .c(ex4_recycle_c[205]),		
      .d(ex4_recycle_s[205]),		
      .ki(ex4_pp5_0k[205]),		
      .ko(ex4_pp5_0k[204]),		
      .sum(ex4_pp5_0s[205]),		
      .car(ex4_pp5_0c[204])		
   );


   tri_csa42 csa5_0_204(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[204]),		
      .b(ex4_pp4_0s[204]),		
      .c(ex4_recycle_c[204]),		
      .d(ex4_recycle_s[204]),		
      .ki(ex4_pp5_0k[204]),		
      .ko(ex4_pp5_0k[203]),		
      .sum(ex4_pp5_0s[204]),		
      .car(ex4_pp5_0c[203])		
   );


   tri_csa42 csa5_0_203(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[203]),		
      .b(ex4_pp4_0s[203]),		
      .c(ex4_recycle_c[203]),		
      .d(ex4_recycle_s[203]),		
      .ki(ex4_pp5_0k[203]),		
      .ko(ex4_pp5_0k[202]),		
      .sum(ex4_pp5_0s[203]),		
      .car(ex4_pp5_0c[202])		
   );


   tri_csa42 csa5_0_202(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[202]),		
      .b(ex4_pp4_0s[202]),		
      .c(ex4_recycle_c[202]),		
      .d(ex4_recycle_s[202]),		
      .ki(ex4_pp5_0k[202]),		
      .ko(ex4_pp5_0k[201]),		
      .sum(ex4_pp5_0s[202]),		
      .car(ex4_pp5_0c[201])		
   );


   tri_csa42 csa5_0_201(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[201]),		
      .b(ex4_pp4_0s[201]),		
      .c(ex4_recycle_c[201]),		
      .d(ex4_recycle_s[201]),		
      .ki(ex4_pp5_0k[201]),		
      .ko(ex4_pp5_0k[200]),		
      .sum(ex4_pp5_0s[201]),		
      .car(ex4_pp5_0c[200])		
   );


   tri_csa42 csa5_0_200(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[200]),		
      .b(ex4_pp4_0s[200]),		
      .c(ex4_recycle_c[200]),		
      .d(ex4_recycle_s[200]),		
      .ki(ex4_pp5_0k[200]),		
      .ko(ex4_pp5_0k[199]),		
      .sum(ex4_pp5_0s[200]),		
      .car(ex4_pp5_0c[199])		
   );


   tri_csa42 csa5_0_199(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[199]),		
      .b(ex4_pp4_0s[199]),		
      .c(ex4_recycle_c[199]),		
      .d(ex4_recycle_s[199]),		
      .ki(ex4_pp5_0k[199]),		
      .ko(ex4_pp5_0k[198]),		
      .sum(ex4_pp5_0s[199]),		
      .car(ex4_pp5_0c[198])		
   );


   tri_csa42 csa5_0_198(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[198]),		
      .b(ex4_pp4_0s[198]),		
      .c(ex4_recycle_c[198]),		
      .d(ex4_recycle_s[198]),		
      .ki(ex4_pp5_0k[198]),		
      .ko(ex4_pp5_0k[197]),		
      .sum(ex4_pp5_0s[198]),		
      .car(ex4_pp5_0c[197])		
   );


   tri_csa42 csa5_0_197(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[197]),		
      .b(ex4_pp4_0s[197]),		
      .c(ex4_recycle_c[197]),		
      .d(ex4_recycle_s[197]),		
      .ki(ex4_pp5_0k[197]),		
      .ko(ex4_pp5_0k[196]),		
      .sum(ex4_pp5_0s[197]),		
      .car(ex4_pp5_0c[196])		
   );


   tri_csa32 csa5_0_196(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_recycle_c[196]),		
      .b(ex4_recycle_s[196]),		
      .c(ex4_pp5_0k[196]),		
      .sum(ex4_pp5_0s[196]),		
      .car(ex4_pp5_0c[195])		
   );

   assign ex5_pp5_0s_din[196:264] = ex4_pp5_0s[196:264];
   assign ex5_pp5_0c_din[196:263] = ex4_pp5_0c[196:263];


   assign ex5_pp5_0s[196:264] = (~ex5_pp5_0s_q_b[196:264]);
   assign ex5_pp5_0c[196:263] = (~ex5_pp5_0c_q_b[196:263]);

   assign ex5_pp5_0s_out[196:264] = ex5_pp5_0s[196:264];		
   assign ex5_pp5_0c_out[196:263] = ex5_pp5_0c[196:263];		



   tri_lcbnd ex4_lcb(
      .delay_lclkr(delay_lclkr_dc),		
      .mpw1_b(mpw1_dc_b),		
      .mpw2_b(mpw2_dc_b),		
      .force_t(func_sl_force),		
      .nclk(nclk),		
      .vd(vdd),		
      .gd(gnd),		
      .act(ex3_act),		
      .sg(sg_0),		
      .thold_b(func_sl_thold_0_b),		
      .d1clk(ex4_d1clk),		
      .d2clk(ex4_d2clk),		
      .lclk(ex4_lclk)		
   );


   tri_lcbnd ex5_lcb(
      .delay_lclkr(delay_lclkr_dc),		
      .mpw1_b(mpw1_dc_b),		
      .mpw2_b(mpw2_dc_b),		
      .force_t(func_sl_force),		
      .nclk(nclk),		
      .vd(vdd),		
      .gd(gnd),		
      .act(ex4_act),		
      .sg(sg_0),		
      .thold_b(func_sl_thold_0_b),		
      .d1clk(ex5_d1clk),		
      .d2clk(ex5_d2clk),		
      .lclk(ex5_lclk)		
   );



   tri_inv_nlats #(.WIDTH(45), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) ex4_pp2_0s_lat(
      .vd(vdd),		
      .gd(gnd),		
      .lclk(ex4_lclk),		
      .d1clk(ex4_d1clk),
      .d2clk(ex4_d2clk),
      .scanin(ex4_pp2_0s_lat_si),
      .scanout(ex4_pp2_0s_lat_so),
      .d(ex4_pp2_0s_din[198:242]),
      .qb(ex4_pp2_0s_q_b[198:242])
   );

   tri_inv_nlats #(.WIDTH(43), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) ex4_pp2_0c_lat(
      .vd(vdd),		
      .gd(gnd),		
      .lclk(ex4_lclk),		
      .d1clk(ex4_d1clk),
      .d2clk(ex4_d2clk),
      .scanin(ex4_pp2_0c_lat_si),
      .scanout(ex4_pp2_0c_lat_so),
      .d(ex4_pp2_0c_din[198:240]),
      .qb(ex4_pp2_0c_q_b[198:240])
   );


   tri_inv_nlats #(.WIDTH(47), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) ex4_pp2_1s_lat(
      .vd(vdd),		
      .gd(gnd),		
      .lclk(ex4_lclk),		
      .d1clk(ex4_d1clk),
      .d2clk(ex4_d2clk),
      .scanin(ex4_pp2_1s_lat_si),
      .scanout(ex4_pp2_1s_lat_so),
      .d(ex4_pp2_1s_din[208:254]),
      .qb(ex4_pp2_1s_q_b[208:254])
   );


   tri_inv_nlats #(.WIDTH(45), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) ex4_pp2_1c_lat(
      .vd(vdd),		
      .gd(gnd),		
      .lclk(ex4_lclk),		
      .d1clk(ex4_d1clk),
      .d2clk(ex4_d2clk),
      .scanin(ex4_pp2_1c_lat_si),
      .scanout(ex4_pp2_1c_lat_so),
      .d(ex4_pp2_1c_din[208:252]),
      .qb(ex4_pp2_1c_q_b[208:252])
   );


   tri_inv_nlats #(.WIDTH(45), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) ex4_pp2_2s_lat(
      .vd(vdd),		
      .gd(gnd),		
      .lclk(ex4_lclk),		
      .d1clk(ex4_d1clk),
      .d2clk(ex4_d2clk),
      .scanin(ex4_pp2_2s_lat_si),
      .scanout(ex4_pp2_2s_lat_so),
      .d(ex4_pp2_2s_din[220:264]),
      .qb(ex4_pp2_2s_q_b[220:264])
   );


   tri_inv_nlats #(.WIDTH(44), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) ex4_pp2_2c_lat(
      .vd(vdd),		
      .gd(gnd),		
      .lclk(ex4_lclk),		
      .d1clk(ex4_d1clk),
      .d2clk(ex4_d2clk),
      .scanin(ex4_pp2_2c_lat_si),
      .scanout(ex4_pp2_2c_lat_so),
      .d(ex4_pp2_2c_din[220:263]),
      .qb(ex4_pp2_2c_q_b[220:263])
   );


   tri_inv_nlats #(.WIDTH(69), .BTR("NLI0001_X2_A12TH"), .NEEDS_SRESET(0)) ex5_pp5_0s_lat(
      .vd(vdd),		
      .gd(gnd),		
      .lclk(ex5_lclk),		
      .d1clk(ex5_d1clk),
      .d2clk(ex5_d2clk),
      .scanin(ex5_pp5_0s_lat_si),
      .scanout(ex5_pp5_0s_lat_so),
      .d(ex5_pp5_0s_din[196:264]),
      .qb(ex5_pp5_0s_q_b[196:264])
   );


   tri_inv_nlats #(.WIDTH(68), .BTR("NLI0001_X2_A12TH"), .NEEDS_SRESET(0)) ex5_pp5_0c_lat(
      .vd(vdd),		
      .gd(gnd),		
      .lclk(ex5_lclk),		
      .d1clk(ex5_d1clk),
      .d2clk(ex5_d2clk),
      .scanin(ex5_pp5_0c_lat_si),
      .scanout(ex5_pp5_0c_lat_so),
      .d(ex5_pp5_0c_din[196:263]),
      .qb(ex5_pp5_0c_q_b[196:263])
   );


   assign ex4_pp2_0s_lat_si[198:242] = {scan_in, ex4_pp2_0s_lat_so[198:241]};
   assign ex4_pp2_0c_lat_si[198:240] = {ex4_pp2_0c_lat_so[199:240], ex4_pp2_0s_lat_so[242]};
   assign ex4_pp2_1s_lat_si[208:254] = {ex4_pp2_0c_lat_so[198], ex4_pp2_1s_lat_so[208:253]};
   assign ex4_pp2_1c_lat_si[208:252] = {ex4_pp2_1c_lat_so[209:252], ex4_pp2_1s_lat_so[254]};
   assign ex4_pp2_2s_lat_si[220:264] = {ex4_pp2_1c_lat_so[208], ex4_pp2_2s_lat_so[220:263]};
   assign ex4_pp2_2c_lat_si[220:263] = {ex4_pp2_2c_lat_so[221:263], ex4_pp2_2s_lat_so[264]};

   assign ex5_pp5_0s_lat_si[196:264] = {ex4_pp2_2c_lat_so[220], ex5_pp5_0s_lat_so[196:263]};
   assign ex5_pp5_0c_lat_si[196:263] = {ex5_pp5_0c_lat_so[197:263], ex5_pp5_0s_lat_so[264]};

   assign scan_out = ex5_pp5_0c_lat_so[196];



endmodule
