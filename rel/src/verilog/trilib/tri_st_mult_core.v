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

//  Description:  XU Multiplier Top
//
//*****************************************************************************

// #####################################################################
// ## multiplier with intermediate latches and output latches.
// ## feedback so that 4 32bit multiplies emulate a 64 bit multiply
// #####################################################################

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
   // Pervasive ---------------------------------------
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

   input            ex3_act;		// for latches at end of first  multiply cycle
   input            ex4_act;		// for latches at end of second multiply cycle

   // Numbers to multiply (with separate sign bit) ---------------------------
   input            ex3_bs_lo_sign;		// input data to multiply
   input            ex3_bd_lo_sign;		// input data to multiply
   input [0:31]     ex3_bd_lo;		// input data to multiply
   input [0:31]     ex3_bs_lo;		// input data to multiply

   // Feedback recirculation for multiple cycle multiply ---------------------
   input [196:264]  ex4_recycle_s;		//compressor feedback
   input [196:263]  ex4_recycle_c;		//compressor feedback

   // result vectors ---------------(adder 0:63 uses my number 200:263)
   output [196:264] ex5_pp5_0s_out;		// compressor output to adder
   output [196:263] ex5_pp5_0c_out;		// compressor output to adder


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

   //***********************************
   //** booth decoders
   //***********************************


   tri_st_mult_boothdcd bd_00(
      .i0(ex3_bd_lo_sign),		//i--
      .i1(ex3_bd_lo[0]),		//i--
      .i2(ex3_bd_lo[1]),		//i--
      .s_neg(ex3_bd_neg[0]),		//o--
      .s_x(ex3_bd_sh0[0]),		//o--
      .s_x2(ex3_bd_sh1[0])		//o--
   );

   tri_st_mult_boothdcd bd_01(
      .i0(ex3_bd_lo[1]),		//i--
      .i1(ex3_bd_lo[2]),		//i--
      .i2(ex3_bd_lo[3]),		//i--
      .s_neg(ex3_bd_neg[1]),		//o--
      .s_x(ex3_bd_sh0[1]),		//o--
      .s_x2(ex3_bd_sh1[1])		//o--
   );

   tri_st_mult_boothdcd bd_02(
      .i0(ex3_bd_lo[3]),		//i--
      .i1(ex3_bd_lo[4]),		//i--
      .i2(ex3_bd_lo[5]),		//i--
      .s_neg(ex3_bd_neg[2]),		//o--
      .s_x(ex3_bd_sh0[2]),		//o--
      .s_x2(ex3_bd_sh1[2])		//o--
   );

   tri_st_mult_boothdcd bd_03(
      .i0(ex3_bd_lo[5]),		//i--
      .i1(ex3_bd_lo[6]),		//i--
      .i2(ex3_bd_lo[7]),		//i--
      .s_neg(ex3_bd_neg[3]),		//o--
      .s_x(ex3_bd_sh0[3]),		//o--
      .s_x2(ex3_bd_sh1[3])		//o--
   );

   tri_st_mult_boothdcd bd_04(
      .i0(ex3_bd_lo[7]),		//i--
      .i1(ex3_bd_lo[8]),		//i--
      .i2(ex3_bd_lo[9]),		//i--
      .s_neg(ex3_bd_neg[4]),		//o--
      .s_x(ex3_bd_sh0[4]),		//o--
      .s_x2(ex3_bd_sh1[4])		//o--
   );

   tri_st_mult_boothdcd bd_05(
      .i0(ex3_bd_lo[9]),		//i--
      .i1(ex3_bd_lo[10]),		//i--
      .i2(ex3_bd_lo[11]),		//i--
      .s_neg(ex3_bd_neg[5]),		//o--
      .s_x(ex3_bd_sh0[5]),		//o--
      .s_x2(ex3_bd_sh1[5])		//o--
   );

   tri_st_mult_boothdcd bd_06(
      .i0(ex3_bd_lo[11]),		//i--
      .i1(ex3_bd_lo[12]),		//i--
      .i2(ex3_bd_lo[13]),		//i--
      .s_neg(ex3_bd_neg[6]),		//o--
      .s_x(ex3_bd_sh0[6]),		//o--
      .s_x2(ex3_bd_sh1[6])		//o--
   );

   tri_st_mult_boothdcd bd_07(
      .i0(ex3_bd_lo[13]),		//i--
      .i1(ex3_bd_lo[14]),		//i--
      .i2(ex3_bd_lo[15]),		//i--
      .s_neg(ex3_bd_neg[7]),		//o--
      .s_x(ex3_bd_sh0[7]),		//o--
      .s_x2(ex3_bd_sh1[7])		//o--
   );

   tri_st_mult_boothdcd bd_08(
      .i0(ex3_bd_lo[15]),		//i--
      .i1(ex3_bd_lo[16]),		//i--
      .i2(ex3_bd_lo[17]),		//i--
      .s_neg(ex3_bd_neg[8]),		//o--
      .s_x(ex3_bd_sh0[8]),		//o--
      .s_x2(ex3_bd_sh1[8])		//o--
   );

   tri_st_mult_boothdcd bd_09(
      .i0(ex3_bd_lo[17]),		//i--
      .i1(ex3_bd_lo[18]),		//i--
      .i2(ex3_bd_lo[19]),		//i--
      .s_neg(ex3_bd_neg[9]),		//o--
      .s_x(ex3_bd_sh0[9]),		//o--
      .s_x2(ex3_bd_sh1[9])		//o--
   );

   tri_st_mult_boothdcd bd_10(
      .i0(ex3_bd_lo[19]),		//i--
      .i1(ex3_bd_lo[20]),		//i--
      .i2(ex3_bd_lo[21]),		//i--
      .s_neg(ex3_bd_neg[10]),		//o--
      .s_x(ex3_bd_sh0[10]),		//o--
      .s_x2(ex3_bd_sh1[10])		//o--
   );

   tri_st_mult_boothdcd bd_11(
      .i0(ex3_bd_lo[21]),		//i--
      .i1(ex3_bd_lo[22]),		//i--
      .i2(ex3_bd_lo[23]),		//i--
      .s_neg(ex3_bd_neg[11]),		//o--
      .s_x(ex3_bd_sh0[11]),		//o--
      .s_x2(ex3_bd_sh1[11])		//o--
   );

   tri_st_mult_boothdcd bd_12(
      .i0(ex3_bd_lo[23]),		//i--
      .i1(ex3_bd_lo[24]),		//i--
      .i2(ex3_bd_lo[25]),		//i--
      .s_neg(ex3_bd_neg[12]),		//o--
      .s_x(ex3_bd_sh0[12]),		//o--
      .s_x2(ex3_bd_sh1[12])		//o--
   );

   tri_st_mult_boothdcd bd_13(
      .i0(ex3_bd_lo[25]),		//i--
      .i1(ex3_bd_lo[26]),		//i--
      .i2(ex3_bd_lo[27]),		//i--
      .s_neg(ex3_bd_neg[13]),		//o--
      .s_x(ex3_bd_sh0[13]),		//o--
      .s_x2(ex3_bd_sh1[13])		//o--
   );

   tri_st_mult_boothdcd bd_14(
      .i0(ex3_bd_lo[27]),		//i--
      .i1(ex3_bd_lo[28]),		//i--
      .i2(ex3_bd_lo[29]),		//i--
      .s_neg(ex3_bd_neg[14]),		//o--
      .s_x(ex3_bd_sh0[14]),		//o--
      .s_x2(ex3_bd_sh1[14])		//o--
   );

   tri_st_mult_boothdcd bd_15(
      .i0(ex3_bd_lo[29]),		//i--
      .i1(ex3_bd_lo[30]),		//i--
      .i2(ex3_bd_lo[31]),		//i--
      .s_neg(ex3_bd_neg[15]),		//o--
      .s_x(ex3_bd_sh0[15]),		//o--
      .s_x2(ex3_bd_sh1[15])		//o--
   );

   tri_st_mult_boothdcd bd_16(
      .i0(ex3_bd_lo[31]),		//i--
      .i1(1'b0),		//i--
      .i2(1'b0),		//i--
      .s_neg(ex3_bd_neg[16]),		//o--
      .s_x(ex3_bd_sh0[16]),		//o--
      .s_x2(ex3_bd_sh1[16])		//o--
   );

   //***********************************
   //** booth muxes
   //***********************************


   tri_st_mult_boothrow br_00(
      .s_neg(ex3_bd_neg[0]),		//i--
      .s_x(ex3_bd_sh0[0]),		//i--
      .s_x2(ex3_bd_sh1[0]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_00_out[0:32]),		//o--
      .hot_one(ex3_hot_one[0])		//o--
   );

   tri_st_mult_boothrow br_01(
      .s_neg(ex3_bd_neg[1]),		//i--
      .s_x(ex3_bd_sh0[1]),		//i--
      .s_x2(ex3_bd_sh1[1]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_01_out[0:32]),		//o--
      .hot_one(ex3_hot_one[1])		//o--
   );

   tri_st_mult_boothrow br_02(
      .s_neg(ex3_bd_neg[2]),		//i--
      .s_x(ex3_bd_sh0[2]),		//i--
      .s_x2(ex3_bd_sh1[2]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_02_out[0:32]),		//o--
      .hot_one(ex3_hot_one[2])		//o--
   );

   tri_st_mult_boothrow br_03(
      .s_neg(ex3_bd_neg[3]),		//i--
      .s_x(ex3_bd_sh0[3]),		//i--
      .s_x2(ex3_bd_sh1[3]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_03_out[0:32]),		//o--
      .hot_one(ex3_hot_one[3])		//o--
   );

   tri_st_mult_boothrow br_04(
      .s_neg(ex3_bd_neg[4]),		//i--
      .s_x(ex3_bd_sh0[4]),		//i--
      .s_x2(ex3_bd_sh1[4]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_04_out[0:32]),		//o--
      .hot_one(ex3_hot_one[4])		//o--
   );

   tri_st_mult_boothrow br_05(
      .s_neg(ex3_bd_neg[5]),		//i--
      .s_x(ex3_bd_sh0[5]),		//i--
      .s_x2(ex3_bd_sh1[5]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_05_out[0:32]),		//o--
      .hot_one(ex3_hot_one[5])		//o--
   );

   tri_st_mult_boothrow br_06(
      .s_neg(ex3_bd_neg[6]),		//i--
      .s_x(ex3_bd_sh0[6]),		//i--
      .s_x2(ex3_bd_sh1[6]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_06_out[0:32]),		//o--
      .hot_one(ex3_hot_one[6])		//o--
   );

   tri_st_mult_boothrow br_07(
      .s_neg(ex3_bd_neg[7]),		//i--
      .s_x(ex3_bd_sh0[7]),		//i--
      .s_x2(ex3_bd_sh1[7]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_07_out[0:32]),		//o--
      .hot_one(ex3_hot_one[7])		//o--
   );

   tri_st_mult_boothrow br_08(
      .s_neg(ex3_bd_neg[8]),		//i--
      .s_x(ex3_bd_sh0[8]),		//i--
      .s_x2(ex3_bd_sh1[8]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_08_out[0:32]),		//o--
      .hot_one(ex3_hot_one[8])		//o--
   );

   tri_st_mult_boothrow br_09(
      .s_neg(ex3_bd_neg[9]),		//i--
      .s_x(ex3_bd_sh0[9]),		//i--
      .s_x2(ex3_bd_sh1[9]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_09_out[0:32]),		//o--
      .hot_one(ex3_hot_one[9])		//o--
   );

   tri_st_mult_boothrow br_10(
      .s_neg(ex3_bd_neg[10]),		//i--
      .s_x(ex3_bd_sh0[10]),		//i--
      .s_x2(ex3_bd_sh1[10]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_10_out[0:32]),		//o--
      .hot_one(ex3_hot_one[10])		//o--
   );

   tri_st_mult_boothrow br_11(
      .s_neg(ex3_bd_neg[11]),		//i--
      .s_x(ex3_bd_sh0[11]),		//i--
      .s_x2(ex3_bd_sh1[11]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_11_out[0:32]),		//o--
      .hot_one(ex3_hot_one[11])		//o--
   );

   tri_st_mult_boothrow br_12(
      .s_neg(ex3_bd_neg[12]),		//i--
      .s_x(ex3_bd_sh0[12]),		//i--
      .s_x2(ex3_bd_sh1[12]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_12_out[0:32]),		//o--
      .hot_one(ex3_hot_one[12])		//o--
   );

   tri_st_mult_boothrow br_13(
      .s_neg(ex3_bd_neg[13]),		//i--
      .s_x(ex3_bd_sh0[13]),		//i--
      .s_x2(ex3_bd_sh1[13]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_13_out[0:32]),		//o--
      .hot_one(ex3_hot_one[13])		//o--
   );

   tri_st_mult_boothrow br_14(
      .s_neg(ex3_bd_neg[14]),		//i--
      .s_x(ex3_bd_sh0[14]),		//i--
      .s_x2(ex3_bd_sh1[14]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_14_out[0:32]),		//o--
      .hot_one(ex3_hot_one[14])		//o--
   );

   tri_st_mult_boothrow br_15(
      .s_neg(ex3_bd_neg[15]),		//i--
      .s_x(ex3_bd_sh0[15]),		//i--
      .s_x2(ex3_bd_sh1[15]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_15_out[0:32]),		//o--
      .hot_one(ex3_hot_one[15])		//o--
   );

   tri_st_mult_boothrow br_16(
      .s_neg(ex3_bd_neg[16]),		//i--
      .s_x(ex3_bd_sh0[16]),		//i--
      .s_x2(ex3_bd_sh1[16]),		//i--
      .sign_bit_adj(ex3_bs_lo_sign),		//i--
      .x(ex3_bs_lo[0:31]),		//i--
      .q(ex3_br_16_out[0:32]),		//o--
      .hot_one(ex3_hot_one[16])		//o--
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

   assign ex3_br_00_add = (~(ex3_br_00_sign_xor & (ex3_bd_sh0[0] | ex3_bd_sh1[0])));		// add
   assign ex3_br_01_add = (~(ex3_br_01_sign_xor & (ex3_bd_sh0[1] | ex3_bd_sh1[1])));		// add
   assign ex3_br_02_add = (~(ex3_br_02_sign_xor & (ex3_bd_sh0[2] | ex3_bd_sh1[2])));		// add
   assign ex3_br_03_add = (~(ex3_br_03_sign_xor & (ex3_bd_sh0[3] | ex3_bd_sh1[3])));		// add
   assign ex3_br_04_add = (~(ex3_br_04_sign_xor & (ex3_bd_sh0[4] | ex3_bd_sh1[4])));		// add
   assign ex3_br_05_add = (~(ex3_br_05_sign_xor & (ex3_bd_sh0[5] | ex3_bd_sh1[5])));		// add
   assign ex3_br_06_add = (~(ex3_br_06_sign_xor & (ex3_bd_sh0[6] | ex3_bd_sh1[6])));		// add
   assign ex3_br_07_add = (~(ex3_br_07_sign_xor & (ex3_bd_sh0[7] | ex3_bd_sh1[7])));		// add
   assign ex3_br_08_add = (~(ex3_br_08_sign_xor & (ex3_bd_sh0[8] | ex3_bd_sh1[8])));		// add
   assign ex3_br_09_add = (~(ex3_br_09_sign_xor & (ex3_bd_sh0[9] | ex3_bd_sh1[9])));		// add
   assign ex3_br_10_add = (~(ex3_br_10_sign_xor & (ex3_bd_sh0[10] | ex3_bd_sh1[10])));		// add
   assign ex3_br_11_add = (~(ex3_br_11_sign_xor & (ex3_bd_sh0[11] | ex3_bd_sh1[11])));		// add
   assign ex3_br_12_add = (~(ex3_br_12_sign_xor & (ex3_bd_sh0[12] | ex3_bd_sh1[12])));		// add
   assign ex3_br_13_add = (~(ex3_br_13_sign_xor & (ex3_bd_sh0[13] | ex3_bd_sh1[13])));		// add
   assign ex3_br_14_add = (~(ex3_br_14_sign_xor & (ex3_bd_sh0[14] | ex3_bd_sh1[14])));		// add
   assign ex3_br_15_add = (~(ex3_br_15_sign_xor & (ex3_bd_sh0[15] | ex3_bd_sh1[15])));		// add
   assign ex3_br_16_add = (~(ex3_br_16_sign_xor & (ex3_bd_sh0[16] | ex3_bd_sh1[16])));		// add
   assign ex3_br_16_sub = ex3_br_16_sign_xor & (ex3_bd_sh0[16] | ex3_bd_sh1[16]);		// sub

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

   //***********************************
   //** compression level 1
   //***********************************
   //===    g1 : for i in 196 to 264 generate
   //===        csa1_0: entity c_prism_csa32 generic map( btr => "MLT32_X1_A12TH" ) port map(
   //===           a       => ex3_pp0_17(i)     ,--i--
   //===           b       => ex3_pp0_00(i)     ,--i--
   //===           c       => ex3_pp0_01(i)     ,--i--
   //===           sum     => ex3_pp1_0s(i)     ,--o--
   //===           car     => ex3_pp1_0cex3_pp1_0c(23(i-1)  );--o--
   //===        csa1_1: entity c_prism_csa32 generic map( btr => "MLT32_X1_A12TH" ) port map(
   //===           a       => ex3_pp0_02(i)     ,--i--
   //===           b       => ex3_pp0_03(i)     ,--i--
   //===           c       => ex3_pp0_04(i)     ,--i--
   //===           sum     => ex3_pp1_1s(i)     ,--o--
   //===           car     => ex3_pp1_1c(i-1)  );--o--
   //===        csa1_2: entity c_prism_csa32 generic map( btr => "MLT32_X1_A12TH" ) port map(
   //===           a       => ex3_pp0_05(i)     ,--i--
   //===           b       => ex3_pp0_06(i)     ,--i--
   //===           c       => ex3_pp0_07(i)     ,--i--
   //===           sum     => ex3_pp1_2s(i)     ,--o--
   //===           car     => ex3_pp1_2c(i-1)  );--o--
   //===        csa1_3: entity c_prism_csa32 generic map( btr => "MLT32_X1_A12TH" ) port map(
   //===           a       => ex3_pp0_08(i)     ,--i--
   //===           b       => ex3_pp0_09(i)     ,--i--
   //===           c       => ex3_pp0_10(i)     ,--i--
   //===           sum     => ex3_pp1_3s(i)     ,--o--
   //===           car     => ex3_pp1_3c(i-1)  );--o--
   //===        csa1_4: entity c_prism_csa32 generic map( btr => "MLT32_X1_A12TH" ) port map(
   //===           a       => ex3_pp0_11(i)     ,--i--
   //===           b       => ex3_pp0_12(i)     ,--i--
   //===           c       => ex3_pp0_13(i)     ,--i--
   //===           sum     => ex3_pp1_4s(i)     ,--o--
   //===           car     => ex3_pp1_4c(i-1)  );--o--
   //===        csa1_5: entity c_prism_csa32 generic map( btr => "MLT32_X1_A12TH" ) port map(
   //===           a       => ex3_pp0_14(i)     ,--i--
   //===           b       => ex3_pp0_15(i)     ,--i--
   //===           c       => ex3_pp0_16(i)     ,--i--
   //===           sum     => ex3_pp1_5s(i)     ,--o--
   //===           car     => ex3_pp1_5c(i-1)  );--o--
   //===    end generate;
   //===       ex3_pp1_0c(264) <= 0 ;
   //===       ex3_pp1_1c(264) <= 0 ;
   //===       ex3_pp1_2c(264) <= 0 ;
   //===       ex3_pp1_3c(264) <= 0 ;
   //===       ex3_pp1_4c(264) <= 0 ;
   //===       ex3_pp1_5c(264) <= 0 ;

   //----- <csa1_0> -----

   assign ex3_pp1_0s[236] = ex3_pp0_01[236];		//pass_s
   assign ex3_pp1_0s[235] = 0;		//pass_none
   assign ex3_pp1_0c[234] = ex3_pp0_01[234];		//pass_cs
   assign ex3_pp1_0s[234] = ex3_pp0_00[234];		//pass_cs
   assign ex3_pp1_0c[233] = 0;		//pass_s
   assign ex3_pp1_0s[233] = ex3_pp0_01[233];		//pass_s
   assign ex3_pp1_0c[232] = 0;		//wr_csa32

      	// MLT32_X1_A12TH
   tri_csa32 csa1_0_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_00[232]),		//i--
      .b(ex3_pp0_01[232]),		//i--
      .c(ex3_pp0_17[232]),		//i--
      .sum(ex3_pp1_0s[232]),		//o--
      .car(ex3_pp1_0c[231])		//o--
   );

   tri_csa22 csa1_0_231(
      .a(ex3_pp0_00[231]),		//i--
      .b(ex3_pp0_01[231]),		//i--
      .sum(ex3_pp1_0s[231]),		//o--
      .car(ex3_pp1_0c[230])		//o--
   );

   tri_csa22 csa1_0_230(
      .a(ex3_pp0_00[230]),		//i--
      .b(ex3_pp0_01[230]),		//i--
      .sum(ex3_pp1_0s[230]),		//o--
      .car(ex3_pp1_0c[229])		//o--
   );

   tri_csa22 csa1_0_229(
      .a(ex3_pp0_00[229]),		//i--
      .b(ex3_pp0_01[229]),		//i--
      .sum(ex3_pp1_0s[229]),		//o--
      .car(ex3_pp1_0c[228])		//o--
   );

   tri_csa22 csa1_0_228(
      .a(ex3_pp0_00[228]),		//i--
      .b(ex3_pp0_01[228]),		//i--
      .sum(ex3_pp1_0s[228]),		//o--
      .car(ex3_pp1_0c[227])		//o--
   );

   tri_csa22 csa1_0_227(
      .a(ex3_pp0_00[227]),		//i--
      .b(ex3_pp0_01[227]),		//i--
      .sum(ex3_pp1_0s[227]),		//o--
      .car(ex3_pp1_0c[226])		//o--
   );

   tri_csa22 csa1_0_226(
      .a(ex3_pp0_00[226]),		//i--
      .b(ex3_pp0_01[226]),		//i--
      .sum(ex3_pp1_0s[226]),		//o--
      .car(ex3_pp1_0c[225])		//o--
   );

   tri_csa22 csa1_0_225(
      .a(ex3_pp0_00[225]),		//i--
      .b(ex3_pp0_01[225]),		//i--
      .sum(ex3_pp1_0s[225]),		//o--
      .car(ex3_pp1_0c[224])		//o--
   );

   tri_csa22 csa1_0_224(
      .a(ex3_pp0_00[224]),		//i--
      .b(ex3_pp0_01[224]),		//i--
      .sum(ex3_pp1_0s[224]),		//o--
      .car(ex3_pp1_0c[223])		//o--
   );

   tri_csa22 csa1_0_223(
      .a(ex3_pp0_00[223]),		//i--
      .b(ex3_pp0_01[223]),		//i--
      .sum(ex3_pp1_0s[223]),		//o--
      .car(ex3_pp1_0c[222])		//o--
   );

   tri_csa22 csa1_0_222(
      .a(ex3_pp0_00[222]),		//i--
      .b(ex3_pp0_01[222]),		//i--
      .sum(ex3_pp1_0s[222]),		//o--
      .car(ex3_pp1_0c[221])		//o--
   );

   tri_csa22 csa1_0_221(
      .a(ex3_pp0_00[221]),		//i--
      .b(ex3_pp0_01[221]),		//i--
      .sum(ex3_pp1_0s[221]),		//o--
      .car(ex3_pp1_0c[220])		//o--
   );

   tri_csa22 csa1_0_220(
      .a(ex3_pp0_00[220]),		//i--
      .b(ex3_pp0_01[220]),		//i--
      .sum(ex3_pp1_0s[220]),		//o--
      .car(ex3_pp1_0c[219])		//o--
   );

   tri_csa22 csa1_0_219(
      .a(ex3_pp0_00[219]),		//i--
      .b(ex3_pp0_01[219]),		//i--
      .sum(ex3_pp1_0s[219]),		//o--
      .car(ex3_pp1_0c[218])		//o--
   );

   tri_csa22 csa1_0_218(
      .a(ex3_pp0_00[218]),		//i--
      .b(ex3_pp0_01[218]),		//i--
      .sum(ex3_pp1_0s[218]),		//o--
      .car(ex3_pp1_0c[217])		//o--
   );

   tri_csa22 csa1_0_217(
      .a(ex3_pp0_00[217]),		//i--
      .b(ex3_pp0_01[217]),		//i--
      .sum(ex3_pp1_0s[217]),		//o--
      .car(ex3_pp1_0c[216])		//o--
   );

   tri_csa22 csa1_0_216(
      .a(ex3_pp0_00[216]),		//i--
      .b(ex3_pp0_01[216]),		//i--
      .sum(ex3_pp1_0s[216]),		//o--
      .car(ex3_pp1_0c[215])		//o--
   );

   tri_csa22 csa1_0_215(
      .a(ex3_pp0_00[215]),		//i--
      .b(ex3_pp0_01[215]),		//i--
      .sum(ex3_pp1_0s[215]),		//o--
      .car(ex3_pp1_0c[214])		//o--
   );

   tri_csa22 csa1_0_214(
      .a(ex3_pp0_00[214]),		//i--
      .b(ex3_pp0_01[214]),		//i--
      .sum(ex3_pp1_0s[214]),		//o--
      .car(ex3_pp1_0c[213])		//o--
   );

   tri_csa22 csa1_0_213(
      .a(ex3_pp0_00[213]),		//i--
      .b(ex3_pp0_01[213]),		//i--
      .sum(ex3_pp1_0s[213]),		//o--
      .car(ex3_pp1_0c[212])		//o--
   );

   tri_csa22 csa1_0_212(
      .a(ex3_pp0_00[212]),		//i--
      .b(ex3_pp0_01[212]),		//i--
      .sum(ex3_pp1_0s[212]),		//o--
      .car(ex3_pp1_0c[211])		//o--
   );

   tri_csa22 csa1_0_211(
      .a(ex3_pp0_00[211]),		//i--
      .b(ex3_pp0_01[211]),		//i--
      .sum(ex3_pp1_0s[211]),		//o--
      .car(ex3_pp1_0c[210])		//o--
   );

   tri_csa22 csa1_0_210(
      .a(ex3_pp0_00[210]),		//i--
      .b(ex3_pp0_01[210]),		//i--
      .sum(ex3_pp1_0s[210]),		//o--
      .car(ex3_pp1_0c[209])		//o--
   );

   tri_csa22 csa1_0_209(
      .a(ex3_pp0_00[209]),		//i--
      .b(ex3_pp0_01[209]),		//i--
      .sum(ex3_pp1_0s[209]),		//o--
      .car(ex3_pp1_0c[208])		//o--
   );

   tri_csa22 csa1_0_208(
      .a(ex3_pp0_00[208]),		//i--
      .b(ex3_pp0_01[208]),		//i--
      .sum(ex3_pp1_0s[208]),		//o--
      .car(ex3_pp1_0c[207])		//o--
   );

   tri_csa22 csa1_0_207(
      .a(ex3_pp0_00[207]),		//i--
      .b(ex3_pp0_01[207]),		//i--
      .sum(ex3_pp1_0s[207]),		//o--
      .car(ex3_pp1_0c[206])		//o--
   );

   tri_csa22 csa1_0_206(
      .a(ex3_pp0_00[206]),		//i--
      .b(ex3_pp0_01[206]),		//i--
      .sum(ex3_pp1_0s[206]),		//o--
      .car(ex3_pp1_0c[205])		//o--
   );

   tri_csa22 csa1_0_205(
      .a(ex3_pp0_00[205]),		//i--
      .b(ex3_pp0_01[205]),		//i--
      .sum(ex3_pp1_0s[205]),		//o--
      .car(ex3_pp1_0c[204])		//o--
   );

   tri_csa22 csa1_0_204(
      .a(ex3_pp0_00[204]),		//i--
      .b(ex3_pp0_01[204]),		//i--
      .sum(ex3_pp1_0s[204]),		//o--
      .car(ex3_pp1_0c[203])		//o--
   );

   tri_csa22 csa1_0_203(
      .a(ex3_pp0_00[203]),		//i--
      .b(ex3_pp0_01[203]),		//i--
      .sum(ex3_pp1_0s[203]),		//o--
      .car(ex3_pp1_0c[202])		//o--
   );

   tri_csa22 csa1_0_202(
      .a(ex3_pp0_00[202]),		//i--
      .b(ex3_pp0_01[202]),		//i--
      .sum(ex3_pp1_0s[202]),		//o--
      .car(ex3_pp1_0c[201])		//o--
   );

   tri_csa22 csa1_0_201(
      .a(ex3_pp0_00[201]),		//i--
      .b(ex3_pp0_01[201]),		//i--
      .sum(ex3_pp1_0s[201]),		//o--
      .car(ex3_pp1_0c[200])		//o--
   );

   tri_csa22 csa1_0_200(
      .a(ex3_pp0_00[200]),		//i--
      .b(ex3_pp0_01[200]),		//i--
      .sum(ex3_pp1_0s[200]),		//o--
      .car(ex3_pp1_0c[199])		//o--
   );
   assign ex3_pp1_0s[199] = ex3_pp0_00[199];		//pass_x_s
   assign ex3_pp1_0s[198] = ex3_pp0_00[198];		//pass_s

   //----- <csa1_1> -----

   assign ex3_pp1_1s[242] = ex3_pp0_04[242];		//pass_s
   assign ex3_pp1_1s[241] = 0;		//pass_none
   assign ex3_pp1_1c[240] = ex3_pp0_04[240];		//pass_cs
   assign ex3_pp1_1s[240] = ex3_pp0_03[240];		//pass_cs
   assign ex3_pp1_1c[239] = 0;		//pass_s
   assign ex3_pp1_1s[239] = ex3_pp0_04[239];		//pass_s
   assign ex3_pp1_1c[238] = 0;		//wr_csa32


   tri_csa32 csa1_1_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[238]),		//i--
      .b(ex3_pp0_03[238]),		//i--
      .c(ex3_pp0_04[238]),		//i--
      .sum(ex3_pp1_1s[238]),		//o--
      .car(ex3_pp1_1c[237])		//o--
   );

   tri_csa22 csa1_1_237(
      .a(ex3_pp0_03[237]),		//i--
      .b(ex3_pp0_04[237]),		//i--
      .sum(ex3_pp1_1s[237]),		//o--
      .car(ex3_pp1_1c[236])		//o--
   );


   tri_csa32 csa1_1_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[236]),		//i--
      .b(ex3_pp0_03[236]),		//i--
      .c(ex3_pp0_04[236]),		//i--
      .sum(ex3_pp1_1s[236]),		//o--
      .car(ex3_pp1_1c[235])		//o--
   );

   tri_csa32 csa1_1_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[235]),		//i--
      .b(ex3_pp0_03[235]),		//i--
      .c(ex3_pp0_04[235]),		//i--
      .sum(ex3_pp1_1s[235]),		//o--
      .car(ex3_pp1_1c[234])		//o--
   );


   tri_csa32 csa1_1_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[234]),		//i--
      .b(ex3_pp0_03[234]),		//i--
      .c(ex3_pp0_04[234]),		//i--
      .sum(ex3_pp1_1s[234]),		//o--
      .car(ex3_pp1_1c[233])		//o--
   );


   tri_csa32 csa1_1_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[233]),		//i--
      .b(ex3_pp0_03[233]),		//i--
      .c(ex3_pp0_04[233]),		//i--
      .sum(ex3_pp1_1s[233]),		//o--
      .car(ex3_pp1_1c[232])		//o--
   );


   tri_csa32 csa1_1_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[232]),		//i--
      .b(ex3_pp0_03[232]),		//i--
      .c(ex3_pp0_04[232]),		//i--
      .sum(ex3_pp1_1s[232]),		//o--
      .car(ex3_pp1_1c[231])		//o--
   );


   tri_csa32 csa1_1_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[231]),		//i--
      .b(ex3_pp0_03[231]),		//i--
      .c(ex3_pp0_04[231]),		//i--
      .sum(ex3_pp1_1s[231]),		//o--
      .car(ex3_pp1_1c[230])		//o--
   );


   tri_csa32 csa1_1_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[230]),		//i--
      .b(ex3_pp0_03[230]),		//i--
      .c(ex3_pp0_04[230]),		//i--
      .sum(ex3_pp1_1s[230]),		//o--
      .car(ex3_pp1_1c[229])		//o--
   );


   tri_csa32 csa1_1_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[229]),		//i--
      .b(ex3_pp0_03[229]),		//i--
      .c(ex3_pp0_04[229]),		//i--
      .sum(ex3_pp1_1s[229]),		//o--
      .car(ex3_pp1_1c[228])		//o--
   );


   tri_csa32 csa1_1_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[228]),		//i--
      .b(ex3_pp0_03[228]),		//i--
      .c(ex3_pp0_04[228]),		//i--
      .sum(ex3_pp1_1s[228]),		//o--
      .car(ex3_pp1_1c[227])		//o--
   );


   tri_csa32 csa1_1_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[227]),		//i--
      .b(ex3_pp0_03[227]),		//i--
      .c(ex3_pp0_04[227]),		//i--
      .sum(ex3_pp1_1s[227]),		//o--
      .car(ex3_pp1_1c[226])		//o--
   );


   tri_csa32 csa1_1_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[226]),		//i--
      .b(ex3_pp0_03[226]),		//i--
      .c(ex3_pp0_04[226]),		//i--
      .sum(ex3_pp1_1s[226]),		//o--
      .car(ex3_pp1_1c[225])		//o--
   );


   tri_csa32 csa1_1_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[225]),		//i--
      .b(ex3_pp0_03[225]),		//i--
      .c(ex3_pp0_04[225]),		//i--
      .sum(ex3_pp1_1s[225]),		//o--
      .car(ex3_pp1_1c[224])		//o--
   );


   tri_csa32 csa1_1_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[224]),		//i--
      .b(ex3_pp0_03[224]),		//i--
      .c(ex3_pp0_04[224]),		//i--
      .sum(ex3_pp1_1s[224]),		//o--
      .car(ex3_pp1_1c[223])		//o--
   );


   tri_csa32 csa1_1_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[223]),		//i--
      .b(ex3_pp0_03[223]),		//i--
      .c(ex3_pp0_04[223]),		//i--
      .sum(ex3_pp1_1s[223]),		//o--
      .car(ex3_pp1_1c[222])		//o--
   );


   tri_csa32 csa1_1_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[222]),		//i--
      .b(ex3_pp0_03[222]),		//i--
      .c(ex3_pp0_04[222]),		//i--
      .sum(ex3_pp1_1s[222]),		//o--
      .car(ex3_pp1_1c[221])		//o--
   );


   tri_csa32 csa1_1_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[221]),		//i--
      .b(ex3_pp0_03[221]),		//i--
      .c(ex3_pp0_04[221]),		//i--
      .sum(ex3_pp1_1s[221]),		//o--
      .car(ex3_pp1_1c[220])		//o--
   );


   tri_csa32 csa1_1_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[220]),		//i--
      .b(ex3_pp0_03[220]),		//i--
      .c(ex3_pp0_04[220]),		//i--
      .sum(ex3_pp1_1s[220]),		//o--
      .car(ex3_pp1_1c[219])		//o--
   );


   tri_csa32 csa1_1_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[219]),		//i--
      .b(ex3_pp0_03[219]),		//i--
      .c(ex3_pp0_04[219]),		//i--
      .sum(ex3_pp1_1s[219]),		//o--
      .car(ex3_pp1_1c[218])		//o--
   );


   tri_csa32 csa1_1_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[218]),		//i--
      .b(ex3_pp0_03[218]),		//i--
      .c(ex3_pp0_04[218]),		//i--
      .sum(ex3_pp1_1s[218]),		//o--
      .car(ex3_pp1_1c[217])		//o--
   );


   tri_csa32 csa1_1_217(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[217]),		//i--
      .b(ex3_pp0_03[217]),		//i--
      .c(ex3_pp0_04[217]),		//i--
      .sum(ex3_pp1_1s[217]),		//o--
      .car(ex3_pp1_1c[216])		//o--
   );


   tri_csa32 csa1_1_216(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[216]),		//i--
      .b(ex3_pp0_03[216]),		//i--
      .c(ex3_pp0_04[216]),		//i--
      .sum(ex3_pp1_1s[216]),		//o--
      .car(ex3_pp1_1c[215])		//o--
   );


   tri_csa32 csa1_1_215(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[215]),		//i--
      .b(ex3_pp0_03[215]),		//i--
      .c(ex3_pp0_04[215]),		//i--
      .sum(ex3_pp1_1s[215]),		//o--
      .car(ex3_pp1_1c[214])		//o--
   );


   tri_csa32 csa1_1_214(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[214]),		//i--
      .b(ex3_pp0_03[214]),		//i--
      .c(ex3_pp0_04[214]),		//i--
      .sum(ex3_pp1_1s[214]),		//o--
      .car(ex3_pp1_1c[213])		//o--
   );


   tri_csa32 csa1_1_213(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[213]),		//i--
      .b(ex3_pp0_03[213]),		//i--
      .c(ex3_pp0_04[213]),		//i--
      .sum(ex3_pp1_1s[213]),		//o--
      .car(ex3_pp1_1c[212])		//o--
   );


   tri_csa32 csa1_1_212(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[212]),		//i--
      .b(ex3_pp0_03[212]),		//i--
      .c(ex3_pp0_04[212]),		//i--
      .sum(ex3_pp1_1s[212]),		//o--
      .car(ex3_pp1_1c[211])		//o--
   );


   tri_csa32 csa1_1_211(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[211]),		//i--
      .b(ex3_pp0_03[211]),		//i--
      .c(ex3_pp0_04[211]),		//i--
      .sum(ex3_pp1_1s[211]),		//o--
      .car(ex3_pp1_1c[210])		//o--
   );


   tri_csa32 csa1_1_210(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[210]),		//i--
      .b(ex3_pp0_03[210]),		//i--
      .c(ex3_pp0_04[210]),		//i--
      .sum(ex3_pp1_1s[210]),		//o--
      .car(ex3_pp1_1c[209])		//o--
   );


   tri_csa32 csa1_1_209(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[209]),		//i--
      .b(ex3_pp0_03[209]),		//i--
      .c(ex3_pp0_04[209]),		//i--
      .sum(ex3_pp1_1s[209]),		//o--
      .car(ex3_pp1_1c[208])		//o--
   );


   tri_csa32 csa1_1_208(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[208]),		//i--
      .b(ex3_pp0_03[208]),		//i--
      .c(ex3_pp0_04[208]),		//i--
      .sum(ex3_pp1_1s[208]),		//o--
      .car(ex3_pp1_1c[207])		//o--
   );


   tri_csa32 csa1_1_207(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[207]),		//i--
      .b(ex3_pp0_03[207]),		//i--
      .c(ex3_pp0_04[207]),		//i--
      .sum(ex3_pp1_1s[207]),		//o--
      .car(ex3_pp1_1c[206])		//o--
   );


   tri_csa32 csa1_1_206(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_02[206]),		//i--
      .b(ex3_pp0_03[206]),		//i--
      .c(ex3_pp0_04[206]),		//i--
      .sum(ex3_pp1_1s[206]),		//o--
      .car(ex3_pp1_1c[205])		//o--
   );

   tri_csa22 csa1_1_205(
      .a(ex3_pp0_02[205]),		//i--
      .b(ex3_pp0_03[205]),		//i--
      .sum(ex3_pp1_1s[205]),		//o--
      .car(ex3_pp1_1c[204])		//o--
   );

   tri_csa22 csa1_1_204(
      .a(ex3_pp0_02[204]),		//i--
      .b(ex3_pp0_03[204]),		//i--
      .sum(ex3_pp1_1s[204]),		//o--
      .car(ex3_pp1_1c[203])		//o--
   );
   assign ex3_pp1_1s[203] = ex3_pp0_02[203];		//pass_x_s
   assign ex3_pp1_1s[202] = ex3_pp0_02[202];		//pass_s

   //----- <csa1_2> -----

   assign ex3_pp1_2s[248] = ex3_pp0_07[248];		//pass_s
   assign ex3_pp1_2s[247] = 0;		//pass_none
   assign ex3_pp1_2c[246] = ex3_pp0_07[246];		//pass_cs
   assign ex3_pp1_2s[246] = ex3_pp0_06[246];		//pass_cs
   assign ex3_pp1_2c[245] = 0;		//pass_s
   assign ex3_pp1_2s[245] = ex3_pp0_07[245];		//pass_s
   assign ex3_pp1_2c[244] = 0;		//wr_csa32


   tri_csa32 csa1_2_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[244]),		//i--
      .b(ex3_pp0_06[244]),		//i--
      .c(ex3_pp0_07[244]),		//i--
      .sum(ex3_pp1_2s[244]),		//o--
      .car(ex3_pp1_2c[243])		//o--
   );

   tri_csa22 csa1_2_243(
      .a(ex3_pp0_06[243]),		//i--
      .b(ex3_pp0_07[243]),		//i--
      .sum(ex3_pp1_2s[243]),		//o--
      .car(ex3_pp1_2c[242])		//o--
   );


   tri_csa32 csa1_2_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[242]),		//i--
      .b(ex3_pp0_06[242]),		//i--
      .c(ex3_pp0_07[242]),		//i--
      .sum(ex3_pp1_2s[242]),		//o--
      .car(ex3_pp1_2c[241])		//o--
   );


   tri_csa32 csa1_2_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[241]),		//i--
      .b(ex3_pp0_06[241]),		//i--
      .c(ex3_pp0_07[241]),		//i--
      .sum(ex3_pp1_2s[241]),		//o--
      .car(ex3_pp1_2c[240])		//o--
   );


   tri_csa32 csa1_2_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[240]),		//i--
      .b(ex3_pp0_06[240]),		//i--
      .c(ex3_pp0_07[240]),		//i--
      .sum(ex3_pp1_2s[240]),		//o--
      .car(ex3_pp1_2c[239])		//o--
   );


   tri_csa32 csa1_2_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[239]),		//i--
      .b(ex3_pp0_06[239]),		//i--
      .c(ex3_pp0_07[239]),		//i--
      .sum(ex3_pp1_2s[239]),		//o--
      .car(ex3_pp1_2c[238])		//o--
   );


   tri_csa32 csa1_2_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[238]),		//i--
      .b(ex3_pp0_06[238]),		//i--
      .c(ex3_pp0_07[238]),		//i--
      .sum(ex3_pp1_2s[238]),		//o--
      .car(ex3_pp1_2c[237])		//o--
   );


   tri_csa32 csa1_2_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[237]),		//i--
      .b(ex3_pp0_06[237]),		//i--
      .c(ex3_pp0_07[237]),		//i--
      .sum(ex3_pp1_2s[237]),		//o--
      .car(ex3_pp1_2c[236])		//o--
   );


   tri_csa32 csa1_2_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[236]),		//i--
      .b(ex3_pp0_06[236]),		//i--
      .c(ex3_pp0_07[236]),		//i--
      .sum(ex3_pp1_2s[236]),		//o--
      .car(ex3_pp1_2c[235])		//o--
   );


   tri_csa32 csa1_2_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[235]),		//i--
      .b(ex3_pp0_06[235]),		//i--
      .c(ex3_pp0_07[235]),		//i--
      .sum(ex3_pp1_2s[235]),		//o--
      .car(ex3_pp1_2c[234])		//o--
   );


   tri_csa32 csa1_2_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[234]),		//i--
      .b(ex3_pp0_06[234]),		//i--
      .c(ex3_pp0_07[234]),		//i--
      .sum(ex3_pp1_2s[234]),		//o--
      .car(ex3_pp1_2c[233])		//o--
   );


   tri_csa32 csa1_2_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[233]),		//i--
      .b(ex3_pp0_06[233]),		//i--
      .c(ex3_pp0_07[233]),		//i--
      .sum(ex3_pp1_2s[233]),		//o--
      .car(ex3_pp1_2c[232])		//o--
   );


   tri_csa32 csa1_2_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[232]),		//i--
      .b(ex3_pp0_06[232]),		//i--
      .c(ex3_pp0_07[232]),		//i--
      .sum(ex3_pp1_2s[232]),		//o--
      .car(ex3_pp1_2c[231])		//o--
   );


   tri_csa32 csa1_2_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[231]),		//i--
      .b(ex3_pp0_06[231]),		//i--
      .c(ex3_pp0_07[231]),		//i--
      .sum(ex3_pp1_2s[231]),		//o--
      .car(ex3_pp1_2c[230])		//o--
   );


   tri_csa32 csa1_2_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[230]),		//i--
      .b(ex3_pp0_06[230]),		//i--
      .c(ex3_pp0_07[230]),		//i--
      .sum(ex3_pp1_2s[230]),		//o--
      .car(ex3_pp1_2c[229])		//o--
   );


   tri_csa32 csa1_2_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[229]),		//i--
      .b(ex3_pp0_06[229]),		//i--
      .c(ex3_pp0_07[229]),		//i--
      .sum(ex3_pp1_2s[229]),		//o--
      .car(ex3_pp1_2c[228])		//o--
   );


   tri_csa32 csa1_2_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[228]),		//i--
      .b(ex3_pp0_06[228]),		//i--
      .c(ex3_pp0_07[228]),		//i--
      .sum(ex3_pp1_2s[228]),		//o--
      .car(ex3_pp1_2c[227])		//o--
   );


   tri_csa32 csa1_2_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[227]),		//i--
      .b(ex3_pp0_06[227]),		//i--
      .c(ex3_pp0_07[227]),		//i--
      .sum(ex3_pp1_2s[227]),		//o--
      .car(ex3_pp1_2c[226])		//o--
   );


   tri_csa32 csa1_2_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[226]),		//i--
      .b(ex3_pp0_06[226]),		//i--
      .c(ex3_pp0_07[226]),		//i--
      .sum(ex3_pp1_2s[226]),		//o--
      .car(ex3_pp1_2c[225])		//o--
   );


   tri_csa32 csa1_2_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[225]),		//i--
      .b(ex3_pp0_06[225]),		//i--
      .c(ex3_pp0_07[225]),		//i--
      .sum(ex3_pp1_2s[225]),		//o--
      .car(ex3_pp1_2c[224])		//o--
   );


   tri_csa32 csa1_2_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[224]),		//i--
      .b(ex3_pp0_06[224]),		//i--
      .c(ex3_pp0_07[224]),		//i--
      .sum(ex3_pp1_2s[224]),		//o--
      .car(ex3_pp1_2c[223])		//o--
   );


   tri_csa32 csa1_2_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[223]),		//i--
      .b(ex3_pp0_06[223]),		//i--
      .c(ex3_pp0_07[223]),		//i--
      .sum(ex3_pp1_2s[223]),		//o--
      .car(ex3_pp1_2c[222])		//o--
   );


   tri_csa32 csa1_2_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[222]),		//i--
      .b(ex3_pp0_06[222]),		//i--
      .c(ex3_pp0_07[222]),		//i--
      .sum(ex3_pp1_2s[222]),		//o--
      .car(ex3_pp1_2c[221])		//o--
   );


   tri_csa32 csa1_2_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[221]),		//i--
      .b(ex3_pp0_06[221]),		//i--
      .c(ex3_pp0_07[221]),		//i--
      .sum(ex3_pp1_2s[221]),		//o--
      .car(ex3_pp1_2c[220])		//o--
   );


   tri_csa32 csa1_2_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[220]),		//i--
      .b(ex3_pp0_06[220]),		//i--
      .c(ex3_pp0_07[220]),		//i--
      .sum(ex3_pp1_2s[220]),		//o--
      .car(ex3_pp1_2c[219])		//o--
   );


   tri_csa32 csa1_2_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[219]),		//i--
      .b(ex3_pp0_06[219]),		//i--
      .c(ex3_pp0_07[219]),		//i--
      .sum(ex3_pp1_2s[219]),		//o--
      .car(ex3_pp1_2c[218])		//o--
   );


   tri_csa32 csa1_2_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[218]),		//i--
      .b(ex3_pp0_06[218]),		//i--
      .c(ex3_pp0_07[218]),		//i--
      .sum(ex3_pp1_2s[218]),		//o--
      .car(ex3_pp1_2c[217])		//o--
   );


   tri_csa32 csa1_2_217(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[217]),		//i--
      .b(ex3_pp0_06[217]),		//i--
      .c(ex3_pp0_07[217]),		//i--
      .sum(ex3_pp1_2s[217]),		//o--
      .car(ex3_pp1_2c[216])		//o--
   );


   tri_csa32 csa1_2_216(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[216]),		//i--
      .b(ex3_pp0_06[216]),		//i--
      .c(ex3_pp0_07[216]),		//i--
      .sum(ex3_pp1_2s[216]),		//o--
      .car(ex3_pp1_2c[215])		//o--
   );


   tri_csa32 csa1_2_215(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[215]),		//i--
      .b(ex3_pp0_06[215]),		//i--
      .c(ex3_pp0_07[215]),		//i--
      .sum(ex3_pp1_2s[215]),		//o--
      .car(ex3_pp1_2c[214])		//o--
   );


   tri_csa32 csa1_2_214(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[214]),		//i--
      .b(ex3_pp0_06[214]),		//i--
      .c(ex3_pp0_07[214]),		//i--
      .sum(ex3_pp1_2s[214]),		//o--
      .car(ex3_pp1_2c[213])		//o--
   );


   tri_csa32 csa1_2_213(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[213]),		//i--
      .b(ex3_pp0_06[213]),		//i--
      .c(ex3_pp0_07[213]),		//i--
      .sum(ex3_pp1_2s[213]),		//o--
      .car(ex3_pp1_2c[212])		//o--
   );


   tri_csa32 csa1_2_212(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_05[212]),		//i--
      .b(ex3_pp0_06[212]),		//i--
      .c(ex3_pp0_07[212]),		//i--
      .sum(ex3_pp1_2s[212]),		//o--
      .car(ex3_pp1_2c[211])		//o--
   );

   tri_csa22 csa1_2_211(
      .a(ex3_pp0_05[211]),		//i--
      .b(ex3_pp0_06[211]),		//i--
      .sum(ex3_pp1_2s[211]),		//o--
      .car(ex3_pp1_2c[210])		//o--
   );

   tri_csa22 csa1_2_210(
      .a(ex3_pp0_05[210]),		//i--
      .b(ex3_pp0_06[210]),		//i--
      .sum(ex3_pp1_2s[210]),		//o--
      .car(ex3_pp1_2c[209])		//o--
   );
   assign ex3_pp1_2s[209] = ex3_pp0_05[209];		//pass_x_s
   assign ex3_pp1_2s[208] = ex3_pp0_05[208];		//pass_s

   //----- <csa1_3> -----

   assign ex3_pp1_3s[254] = ex3_pp0_10[254];		//pass_s
   assign ex3_pp1_3s[253] = 0;		//pass_none
   assign ex3_pp1_3c[252] = ex3_pp0_10[252];		//pass_cs
   assign ex3_pp1_3s[252] = ex3_pp0_09[252];		//pass_cs
   assign ex3_pp1_3c[251] = 0;		//pass_s
   assign ex3_pp1_3s[251] = ex3_pp0_10[251];		//pass_s
   assign ex3_pp1_3c[250] = 0;		//wr_csa32


   tri_csa32 csa1_3_250(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[250]),		//i--
      .b(ex3_pp0_09[250]),		//i--
      .c(ex3_pp0_10[250]),		//i--
      .sum(ex3_pp1_3s[250]),		//o--
      .car(ex3_pp1_3c[249])		//o--
   );

   tri_csa22 csa1_3_249(
      .a(ex3_pp0_09[249]),		//i--
      .b(ex3_pp0_10[249]),		//i--
      .sum(ex3_pp1_3s[249]),		//o--
      .car(ex3_pp1_3c[248])		//o--
   );


   tri_csa32 csa1_3_248(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[248]),		//i--
      .b(ex3_pp0_09[248]),		//i--
      .c(ex3_pp0_10[248]),		//i--
      .sum(ex3_pp1_3s[248]),		//o--
      .car(ex3_pp1_3c[247])		//o--
   );


   tri_csa32 csa1_3_247(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[247]),		//i--
      .b(ex3_pp0_09[247]),		//i--
      .c(ex3_pp0_10[247]),		//i--
      .sum(ex3_pp1_3s[247]),		//o--
      .car(ex3_pp1_3c[246])		//o--
   );


   tri_csa32 csa1_3_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[246]),		//i--
      .b(ex3_pp0_09[246]),		//i--
      .c(ex3_pp0_10[246]),		//i--
      .sum(ex3_pp1_3s[246]),		//o--
      .car(ex3_pp1_3c[245])		//o--
   );


   tri_csa32 csa1_3_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[245]),		//i--
      .b(ex3_pp0_09[245]),		//i--
      .c(ex3_pp0_10[245]),		//i--
      .sum(ex3_pp1_3s[245]),		//o--
      .car(ex3_pp1_3c[244])		//o--
   );


   tri_csa32 csa1_3_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[244]),		//i--
      .b(ex3_pp0_09[244]),		//i--
      .c(ex3_pp0_10[244]),		//i--
      .sum(ex3_pp1_3s[244]),		//o--
      .car(ex3_pp1_3c[243])		//o--
   );


   tri_csa32 csa1_3_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[243]),		//i--
      .b(ex3_pp0_09[243]),		//i--
      .c(ex3_pp0_10[243]),		//i--
      .sum(ex3_pp1_3s[243]),		//o--
      .car(ex3_pp1_3c[242])		//o--
   );


   tri_csa32 csa1_3_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[242]),		//i--
      .b(ex3_pp0_09[242]),		//i--
      .c(ex3_pp0_10[242]),		//i--
      .sum(ex3_pp1_3s[242]),		//o--
      .car(ex3_pp1_3c[241])		//o--
   );


   tri_csa32 csa1_3_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[241]),		//i--
      .b(ex3_pp0_09[241]),		//i--
      .c(ex3_pp0_10[241]),		//i--
      .sum(ex3_pp1_3s[241]),		//o--
      .car(ex3_pp1_3c[240])		//o--
   );


   tri_csa32 csa1_3_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[240]),		//i--
      .b(ex3_pp0_09[240]),		//i--
      .c(ex3_pp0_10[240]),		//i--
      .sum(ex3_pp1_3s[240]),		//o--
      .car(ex3_pp1_3c[239])		//o--
   );


   tri_csa32 csa1_3_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[239]),		//i--
      .b(ex3_pp0_09[239]),		//i--
      .c(ex3_pp0_10[239]),		//i--
      .sum(ex3_pp1_3s[239]),		//o--
      .car(ex3_pp1_3c[238])		//o--
   );


   tri_csa32 csa1_3_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[238]),		//i--
      .b(ex3_pp0_09[238]),		//i--
      .c(ex3_pp0_10[238]),		//i--
      .sum(ex3_pp1_3s[238]),		//o--
      .car(ex3_pp1_3c[237])		//o--
   );


   tri_csa32 csa1_3_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[237]),		//i--
      .b(ex3_pp0_09[237]),		//i--
      .c(ex3_pp0_10[237]),		//i--
      .sum(ex3_pp1_3s[237]),		//o--
      .car(ex3_pp1_3c[236])		//o--
   );


   tri_csa32 csa1_3_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[236]),		//i--
      .b(ex3_pp0_09[236]),		//i--
      .c(ex3_pp0_10[236]),		//i--
      .sum(ex3_pp1_3s[236]),		//o--
      .car(ex3_pp1_3c[235])		//o--
   );


   tri_csa32 csa1_3_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[235]),		//i--
      .b(ex3_pp0_09[235]),		//i--
      .c(ex3_pp0_10[235]),		//i--
      .sum(ex3_pp1_3s[235]),		//o--
      .car(ex3_pp1_3c[234])		//o--
   );


   tri_csa32 csa1_3_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[234]),		//i--
      .b(ex3_pp0_09[234]),		//i--
      .c(ex3_pp0_10[234]),		//i--
      .sum(ex3_pp1_3s[234]),		//o--
      .car(ex3_pp1_3c[233])		//o--
   );


   tri_csa32 csa1_3_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[233]),		//i--
      .b(ex3_pp0_09[233]),		//i--
      .c(ex3_pp0_10[233]),		//i--
      .sum(ex3_pp1_3s[233]),		//o--
      .car(ex3_pp1_3c[232])		//o--
   );


   tri_csa32 csa1_3_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[232]),		//i--
      .b(ex3_pp0_09[232]),		//i--
      .c(ex3_pp0_10[232]),		//i--
      .sum(ex3_pp1_3s[232]),		//o--
      .car(ex3_pp1_3c[231])		//o--
   );


   tri_csa32 csa1_3_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[231]),		//i--
      .b(ex3_pp0_09[231]),		//i--
      .c(ex3_pp0_10[231]),		//i--
      .sum(ex3_pp1_3s[231]),		//o--
      .car(ex3_pp1_3c[230])		//o--
   );


   tri_csa32 csa1_3_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[230]),		//i--
      .b(ex3_pp0_09[230]),		//i--
      .c(ex3_pp0_10[230]),		//i--
      .sum(ex3_pp1_3s[230]),		//o--
      .car(ex3_pp1_3c[229])		//o--
   );


   tri_csa32 csa1_3_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[229]),		//i--
      .b(ex3_pp0_09[229]),		//i--
      .c(ex3_pp0_10[229]),		//i--
      .sum(ex3_pp1_3s[229]),		//o--
      .car(ex3_pp1_3c[228])		//o--
   );


   tri_csa32 csa1_3_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[228]),		//i--
      .b(ex3_pp0_09[228]),		//i--
      .c(ex3_pp0_10[228]),		//i--
      .sum(ex3_pp1_3s[228]),		//o--
      .car(ex3_pp1_3c[227])		//o--
   );


   tri_csa32 csa1_3_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[227]),		//i--
      .b(ex3_pp0_09[227]),		//i--
      .c(ex3_pp0_10[227]),		//i--
      .sum(ex3_pp1_3s[227]),		//o--
      .car(ex3_pp1_3c[226])		//o--
   );


   tri_csa32 csa1_3_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[226]),		//i--
      .b(ex3_pp0_09[226]),		//i--
      .c(ex3_pp0_10[226]),		//i--
      .sum(ex3_pp1_3s[226]),		//o--
      .car(ex3_pp1_3c[225])		//o--
   );


   tri_csa32 csa1_3_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[225]),		//i--
      .b(ex3_pp0_09[225]),		//i--
      .c(ex3_pp0_10[225]),		//i--
      .sum(ex3_pp1_3s[225]),		//o--
      .car(ex3_pp1_3c[224])		//o--
   );


   tri_csa32 csa1_3_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[224]),		//i--
      .b(ex3_pp0_09[224]),		//i--
      .c(ex3_pp0_10[224]),		//i--
      .sum(ex3_pp1_3s[224]),		//o--
      .car(ex3_pp1_3c[223])		//o--
   );


   tri_csa32 csa1_3_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[223]),		//i--
      .b(ex3_pp0_09[223]),		//i--
      .c(ex3_pp0_10[223]),		//i--
      .sum(ex3_pp1_3s[223]),		//o--
      .car(ex3_pp1_3c[222])		//o--
   );


   tri_csa32 csa1_3_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[222]),		//i--
      .b(ex3_pp0_09[222]),		//i--
      .c(ex3_pp0_10[222]),		//i--
      .sum(ex3_pp1_3s[222]),		//o--
      .car(ex3_pp1_3c[221])		//o--
   );


   tri_csa32 csa1_3_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[221]),		//i--
      .b(ex3_pp0_09[221]),		//i--
      .c(ex3_pp0_10[221]),		//i--
      .sum(ex3_pp1_3s[221]),		//o--
      .car(ex3_pp1_3c[220])		//o--
   );


   tri_csa32 csa1_3_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[220]),		//i--
      .b(ex3_pp0_09[220]),		//i--
      .c(ex3_pp0_10[220]),		//i--
      .sum(ex3_pp1_3s[220]),		//o--
      .car(ex3_pp1_3c[219])		//o--
   );


   tri_csa32 csa1_3_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[219]),		//i--
      .b(ex3_pp0_09[219]),		//i--
      .c(ex3_pp0_10[219]),		//i--
      .sum(ex3_pp1_3s[219]),		//o--
      .car(ex3_pp1_3c[218])		//o--
   );


   tri_csa32 csa1_3_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_08[218]),		//i--
      .b(ex3_pp0_09[218]),		//i--
      .c(ex3_pp0_10[218]),		//i--
      .sum(ex3_pp1_3s[218]),		//o--
      .car(ex3_pp1_3c[217])		//o--
   );

   tri_csa22 csa1_3_217(
      .a(ex3_pp0_08[217]),		//i--
      .b(ex3_pp0_09[217]),		//i--
      .sum(ex3_pp1_3s[217]),		//o--
      .car(ex3_pp1_3c[216])		//o--
   );

   tri_csa22 csa1_3_216(
      .a(ex3_pp0_08[216]),		//i--
      .b(ex3_pp0_09[216]),		//i--
      .sum(ex3_pp1_3s[216]),		//o--
      .car(ex3_pp1_3c[215])		//o--
   );
   assign ex3_pp1_3s[215] = ex3_pp0_08[215];		//pass_x_s
   assign ex3_pp1_3s[214] = ex3_pp0_08[214];		//pass_s

   //----- <csa1_4> -----

   assign ex3_pp1_4s[260] = ex3_pp0_13[260];		//pass_s
   assign ex3_pp1_4s[259] = 0;		//pass_none
   assign ex3_pp1_4c[258] = ex3_pp0_13[258];		//pass_cs
   assign ex3_pp1_4s[258] = ex3_pp0_12[258];		//pass_cs
   assign ex3_pp1_4c[257] = 0;		//pass_s
   assign ex3_pp1_4s[257] = ex3_pp0_13[257];		//pass_s
   assign ex3_pp1_4c[256] = 0;		//wr_csa32


   tri_csa32 csa1_4_256(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[256]),		//i--
      .b(ex3_pp0_12[256]),		//i--
      .c(ex3_pp0_13[256]),		//i--
      .sum(ex3_pp1_4s[256]),		//o--
      .car(ex3_pp1_4c[255])		//o--
   );

   tri_csa22 csa1_4_255(
      .a(ex3_pp0_12[255]),		//i--
      .b(ex3_pp0_13[255]),		//i--
      .sum(ex3_pp1_4s[255]),		//o--
      .car(ex3_pp1_4c[254])		//o--
   );


   tri_csa32 csa1_4_254(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[254]),		//i--
      .b(ex3_pp0_12[254]),		//i--
      .c(ex3_pp0_13[254]),		//i--
      .sum(ex3_pp1_4s[254]),		//o--
      .car(ex3_pp1_4c[253])		//o--
   );


   tri_csa32 csa1_4_253(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[253]),		//i--
      .b(ex3_pp0_12[253]),		//i--
      .c(ex3_pp0_13[253]),		//i--
      .sum(ex3_pp1_4s[253]),		//o--
      .car(ex3_pp1_4c[252])		//o--
   );


   tri_csa32 csa1_4_252(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[252]),		//i--
      .b(ex3_pp0_12[252]),		//i--
      .c(ex3_pp0_13[252]),		//i--
      .sum(ex3_pp1_4s[252]),		//o--
      .car(ex3_pp1_4c[251])		//o--
   );


   tri_csa32 csa1_4_251(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[251]),		//i--
      .b(ex3_pp0_12[251]),		//i--
      .c(ex3_pp0_13[251]),		//i--
      .sum(ex3_pp1_4s[251]),		//o--
      .car(ex3_pp1_4c[250])		//o--
   );


   tri_csa32 csa1_4_250(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[250]),		//i--
      .b(ex3_pp0_12[250]),		//i--
      .c(ex3_pp0_13[250]),		//i--
      .sum(ex3_pp1_4s[250]),		//o--
      .car(ex3_pp1_4c[249])		//o--
   );


   tri_csa32 csa1_4_249(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[249]),		//i--
      .b(ex3_pp0_12[249]),		//i--
      .c(ex3_pp0_13[249]),		//i--
      .sum(ex3_pp1_4s[249]),		//o--
      .car(ex3_pp1_4c[248])		//o--
   );


   tri_csa32 csa1_4_248(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[248]),		//i--
      .b(ex3_pp0_12[248]),		//i--
      .c(ex3_pp0_13[248]),		//i--
      .sum(ex3_pp1_4s[248]),		//o--
      .car(ex3_pp1_4c[247])		//o--
   );


   tri_csa32 csa1_4_247(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[247]),		//i--
      .b(ex3_pp0_12[247]),		//i--
      .c(ex3_pp0_13[247]),		//i--
      .sum(ex3_pp1_4s[247]),		//o--
      .car(ex3_pp1_4c[246])		//o--
   );


   tri_csa32 csa1_4_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[246]),		//i--
      .b(ex3_pp0_12[246]),		//i--
      .c(ex3_pp0_13[246]),		//i--
      .sum(ex3_pp1_4s[246]),		//o--
      .car(ex3_pp1_4c[245])		//o--
   );


   tri_csa32 csa1_4_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[245]),		//i--
      .b(ex3_pp0_12[245]),		//i--
      .c(ex3_pp0_13[245]),		//i--
      .sum(ex3_pp1_4s[245]),		//o--
      .car(ex3_pp1_4c[244])		//o--
   );


   tri_csa32 csa1_4_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[244]),		//i--
      .b(ex3_pp0_12[244]),		//i--
      .c(ex3_pp0_13[244]),		//i--
      .sum(ex3_pp1_4s[244]),		//o--
      .car(ex3_pp1_4c[243])		//o--
   );


   tri_csa32 csa1_4_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[243]),		//i--
      .b(ex3_pp0_12[243]),		//i--
      .c(ex3_pp0_13[243]),		//i--
      .sum(ex3_pp1_4s[243]),		//o--
      .car(ex3_pp1_4c[242])		//o--
   );


   tri_csa32 csa1_4_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[242]),		//i--
      .b(ex3_pp0_12[242]),		//i--
      .c(ex3_pp0_13[242]),		//i--
      .sum(ex3_pp1_4s[242]),		//o--
      .car(ex3_pp1_4c[241])		//o--
   );


   tri_csa32 csa1_4_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[241]),		//i--
      .b(ex3_pp0_12[241]),		//i--
      .c(ex3_pp0_13[241]),		//i--
      .sum(ex3_pp1_4s[241]),		//o--
      .car(ex3_pp1_4c[240])		//o--
   );


   tri_csa32 csa1_4_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[240]),		//i--
      .b(ex3_pp0_12[240]),		//i--
      .c(ex3_pp0_13[240]),		//i--
      .sum(ex3_pp1_4s[240]),		//o--
      .car(ex3_pp1_4c[239])		//o--
   );


   tri_csa32 csa1_4_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[239]),		//i--
      .b(ex3_pp0_12[239]),		//i--
      .c(ex3_pp0_13[239]),		//i--
      .sum(ex3_pp1_4s[239]),		//o--
      .car(ex3_pp1_4c[238])		//o--
   );


   tri_csa32 csa1_4_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[238]),		//i--
      .b(ex3_pp0_12[238]),		//i--
      .c(ex3_pp0_13[238]),		//i--
      .sum(ex3_pp1_4s[238]),		//o--
      .car(ex3_pp1_4c[237])		//o--
   );


   tri_csa32 csa1_4_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[237]),		//i--
      .b(ex3_pp0_12[237]),		//i--
      .c(ex3_pp0_13[237]),		//i--
      .sum(ex3_pp1_4s[237]),		//o--
      .car(ex3_pp1_4c[236])		//o--
   );


   tri_csa32 csa1_4_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[236]),		//i--
      .b(ex3_pp0_12[236]),		//i--
      .c(ex3_pp0_13[236]),		//i--
      .sum(ex3_pp1_4s[236]),		//o--
      .car(ex3_pp1_4c[235])		//o--
   );


   tri_csa32 csa1_4_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[235]),		//i--
      .b(ex3_pp0_12[235]),		//i--
      .c(ex3_pp0_13[235]),		//i--
      .sum(ex3_pp1_4s[235]),		//o--
      .car(ex3_pp1_4c[234])		//o--
   );


   tri_csa32 csa1_4_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[234]),		//i--
      .b(ex3_pp0_12[234]),		//i--
      .c(ex3_pp0_13[234]),		//i--
      .sum(ex3_pp1_4s[234]),		//o--
      .car(ex3_pp1_4c[233])		//o--
   );


   tri_csa32 csa1_4_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[233]),		//i--
      .b(ex3_pp0_12[233]),		//i--
      .c(ex3_pp0_13[233]),		//i--
      .sum(ex3_pp1_4s[233]),		//o--
      .car(ex3_pp1_4c[232])		//o--
   );


   tri_csa32 csa1_4_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[232]),		//i--
      .b(ex3_pp0_12[232]),		//i--
      .c(ex3_pp0_13[232]),		//i--
      .sum(ex3_pp1_4s[232]),		//o--
      .car(ex3_pp1_4c[231])		//o--
   );


   tri_csa32 csa1_4_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[231]),		//i--
      .b(ex3_pp0_12[231]),		//i--
      .c(ex3_pp0_13[231]),		//i--
      .sum(ex3_pp1_4s[231]),		//o--
      .car(ex3_pp1_4c[230])		//o--
   );


   tri_csa32 csa1_4_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[230]),		//i--
      .b(ex3_pp0_12[230]),		//i--
      .c(ex3_pp0_13[230]),		//i--
      .sum(ex3_pp1_4s[230]),		//o--
      .car(ex3_pp1_4c[229])		//o--
   );


   tri_csa32 csa1_4_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[229]),		//i--
      .b(ex3_pp0_12[229]),		//i--
      .c(ex3_pp0_13[229]),		//i--
      .sum(ex3_pp1_4s[229]),		//o--
      .car(ex3_pp1_4c[228])		//o--
   );


   tri_csa32 csa1_4_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[228]),		//i--
      .b(ex3_pp0_12[228]),		//i--
      .c(ex3_pp0_13[228]),		//i--
      .sum(ex3_pp1_4s[228]),		//o--
      .car(ex3_pp1_4c[227])		//o--
   );


   tri_csa32 csa1_4_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[227]),		//i--
      .b(ex3_pp0_12[227]),		//i--
      .c(ex3_pp0_13[227]),		//i--
      .sum(ex3_pp1_4s[227]),		//o--
      .car(ex3_pp1_4c[226])		//o--
   );


   tri_csa32 csa1_4_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[226]),		//i--
      .b(ex3_pp0_12[226]),		//i--
      .c(ex3_pp0_13[226]),		//i--
      .sum(ex3_pp1_4s[226]),		//o--
      .car(ex3_pp1_4c[225])		//o--
   );


   tri_csa32 csa1_4_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[225]),		//i--
      .b(ex3_pp0_12[225]),		//i--
      .c(ex3_pp0_13[225]),		//i--
      .sum(ex3_pp1_4s[225]),		//o--
      .car(ex3_pp1_4c[224])		//o--
   );


   tri_csa32 csa1_4_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_11[224]),		//i--
      .b(ex3_pp0_12[224]),		//i--
      .c(ex3_pp0_13[224]),		//i--
      .sum(ex3_pp1_4s[224]),		//o--
      .car(ex3_pp1_4c[223])		//o--
   );

   tri_csa22 csa1_4_223(
      .a(ex3_pp0_11[223]),		//i--
      .b(ex3_pp0_12[223]),		//i--
      .sum(ex3_pp1_4s[223]),		//o--
      .car(ex3_pp1_4c[222])		//o--
   );

   tri_csa22 csa1_4_222(
      .a(ex3_pp0_11[222]),		//i--
      .b(ex3_pp0_12[222]),		//i--
      .sum(ex3_pp1_4s[222]),		//o--
      .car(ex3_pp1_4c[221])		//o--
   );
   assign ex3_pp1_4s[221] = ex3_pp0_11[221];		//pass_x_s
   assign ex3_pp1_4s[220] = ex3_pp0_11[220];		//pass_s

   //----- <csa1_5> -----

   assign ex3_pp1_5c[264] = ex3_pp0_16[264];		//pass_cs
   assign ex3_pp1_5s[264] = ex3_pp0_15[264];		//pass_cs
   assign ex3_pp1_5c[263] = 0;		//pass_s
   assign ex3_pp1_5s[263] = ex3_pp0_16[263];		//pass_s
   assign ex3_pp1_5c[262] = 0;		//wr_csa32


   tri_csa32 csa1_5_262(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[262]),		//i--
      .b(ex3_pp0_15[262]),		//i--
      .c(ex3_pp0_16[262]),		//i--
      .sum(ex3_pp1_5s[262]),		//o--
      .car(ex3_pp1_5c[261])		//o--
   );

   tri_csa22 csa1_5_261(
      .a(ex3_pp0_15[261]),		//i--
      .b(ex3_pp0_16[261]),		//i--
      .sum(ex3_pp1_5s[261]),		//o--
      .car(ex3_pp1_5c[260])		//o--
   );

   tri_csa32 csa1_5_260(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[260]),		//i--
      .b(ex3_pp0_15[260]),		//i--
      .c(ex3_pp0_16[260]),		//i--
      .sum(ex3_pp1_5s[260]),		//o--
      .car(ex3_pp1_5c[259])		//o--
   );


   tri_csa32 csa1_5_259(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[259]),		//i--
      .b(ex3_pp0_15[259]),		//i--
      .c(ex3_pp0_16[259]),		//i--
      .sum(ex3_pp1_5s[259]),		//o--
      .car(ex3_pp1_5c[258])		//o--
   );


   tri_csa32 csa1_5_258(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[258]),		//i--
      .b(ex3_pp0_15[258]),		//i--
      .c(ex3_pp0_16[258]),		//i--
      .sum(ex3_pp1_5s[258]),		//o--
      .car(ex3_pp1_5c[257])		//o--
   );


   tri_csa32 csa1_5_257(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[257]),		//i--
      .b(ex3_pp0_15[257]),		//i--
      .c(ex3_pp0_16[257]),		//i--
      .sum(ex3_pp1_5s[257]),		//o--
      .car(ex3_pp1_5c[256])		//o--
   );


   tri_csa32 csa1_5_256(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[256]),		//i--
      .b(ex3_pp0_15[256]),		//i--
      .c(ex3_pp0_16[256]),		//i--
      .sum(ex3_pp1_5s[256]),		//o--
      .car(ex3_pp1_5c[255])		//o--
   );


   tri_csa32 csa1_5_255(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[255]),		//i--
      .b(ex3_pp0_15[255]),		//i--
      .c(ex3_pp0_16[255]),		//i--
      .sum(ex3_pp1_5s[255]),		//o--
      .car(ex3_pp1_5c[254])		//o--
   );


   tri_csa32 csa1_5_254(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[254]),		//i--
      .b(ex3_pp0_15[254]),		//i--
      .c(ex3_pp0_16[254]),		//i--
      .sum(ex3_pp1_5s[254]),		//o--
      .car(ex3_pp1_5c[253])		//o--
   );


   tri_csa32 csa1_5_253(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[253]),		//i--
      .b(ex3_pp0_15[253]),		//i--
      .c(ex3_pp0_16[253]),		//i--
      .sum(ex3_pp1_5s[253]),		//o--
      .car(ex3_pp1_5c[252])		//o--
   );


   tri_csa32 csa1_5_252(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[252]),		//i--
      .b(ex3_pp0_15[252]),		//i--
      .c(ex3_pp0_16[252]),		//i--
      .sum(ex3_pp1_5s[252]),		//o--
      .car(ex3_pp1_5c[251])		//o--
   );


   tri_csa32 csa1_5_251(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[251]),		//i--
      .b(ex3_pp0_15[251]),		//i--
      .c(ex3_pp0_16[251]),		//i--
      .sum(ex3_pp1_5s[251]),		//o--
      .car(ex3_pp1_5c[250])		//o--
   );


   tri_csa32 csa1_5_250(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[250]),		//i--
      .b(ex3_pp0_15[250]),		//i--
      .c(ex3_pp0_16[250]),		//i--
      .sum(ex3_pp1_5s[250]),		//o--
      .car(ex3_pp1_5c[249])		//o--
   );


   tri_csa32 csa1_5_249(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[249]),		//i--
      .b(ex3_pp0_15[249]),		//i--
      .c(ex3_pp0_16[249]),		//i--
      .sum(ex3_pp1_5s[249]),		//o--
      .car(ex3_pp1_5c[248])		//o--
   );


   tri_csa32 csa1_5_248(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[248]),		//i--
      .b(ex3_pp0_15[248]),		//i--
      .c(ex3_pp0_16[248]),		//i--
      .sum(ex3_pp1_5s[248]),		//o--
      .car(ex3_pp1_5c[247])		//o--
   );


   tri_csa32 csa1_5_247(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[247]),		//i--
      .b(ex3_pp0_15[247]),		//i--
      .c(ex3_pp0_16[247]),		//i--
      .sum(ex3_pp1_5s[247]),		//o--
      .car(ex3_pp1_5c[246])		//o--
   );


   tri_csa32 csa1_5_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[246]),		//i--
      .b(ex3_pp0_15[246]),		//i--
      .c(ex3_pp0_16[246]),		//i--
      .sum(ex3_pp1_5s[246]),		//o--
      .car(ex3_pp1_5c[245])		//o--
   );


   tri_csa32 csa1_5_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[245]),		//i--
      .b(ex3_pp0_15[245]),		//i--
      .c(ex3_pp0_16[245]),		//i--
      .sum(ex3_pp1_5s[245]),		//o--
      .car(ex3_pp1_5c[244])		//o--
   );


   tri_csa32 csa1_5_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[244]),		//i--
      .b(ex3_pp0_15[244]),		//i--
      .c(ex3_pp0_16[244]),		//i--
      .sum(ex3_pp1_5s[244]),		//o--
      .car(ex3_pp1_5c[243])		//o--
   );


   tri_csa32 csa1_5_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[243]),		//i--
      .b(ex3_pp0_15[243]),		//i--
      .c(ex3_pp0_16[243]),		//i--
      .sum(ex3_pp1_5s[243]),		//o--
      .car(ex3_pp1_5c[242])		//o--
   );


   tri_csa32 csa1_5_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[242]),		//i--
      .b(ex3_pp0_15[242]),		//i--
      .c(ex3_pp0_16[242]),		//i--
      .sum(ex3_pp1_5s[242]),		//o--
      .car(ex3_pp1_5c[241])		//o--
   );


   tri_csa32 csa1_5_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[241]),		//i--
      .b(ex3_pp0_15[241]),		//i--
      .c(ex3_pp0_16[241]),		//i--
      .sum(ex3_pp1_5s[241]),		//o--
      .car(ex3_pp1_5c[240])		//o--
   );


   tri_csa32 csa1_5_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[240]),		//i--
      .b(ex3_pp0_15[240]),		//i--
      .c(ex3_pp0_16[240]),		//i--
      .sum(ex3_pp1_5s[240]),		//o--
      .car(ex3_pp1_5c[239])		//o--
   );


   tri_csa32 csa1_5_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[239]),		//i--
      .b(ex3_pp0_15[239]),		//i--
      .c(ex3_pp0_16[239]),		//i--
      .sum(ex3_pp1_5s[239]),		//o--
      .car(ex3_pp1_5c[238])		//o--
   );


   tri_csa32 csa1_5_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[238]),		//i--
      .b(ex3_pp0_15[238]),		//i--
      .c(ex3_pp0_16[238]),		//i--
      .sum(ex3_pp1_5s[238]),		//o--
      .car(ex3_pp1_5c[237])		//o--
   );


   tri_csa32 csa1_5_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[237]),		//i--
      .b(ex3_pp0_15[237]),		//i--
      .c(ex3_pp0_16[237]),		//i--
      .sum(ex3_pp1_5s[237]),		//o--
      .car(ex3_pp1_5c[236])		//o--
   );


   tri_csa32 csa1_5_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[236]),		//i--
      .b(ex3_pp0_15[236]),		//i--
      .c(ex3_pp0_16[236]),		//i--
      .sum(ex3_pp1_5s[236]),		//o--
      .car(ex3_pp1_5c[235])		//o--
   );


   tri_csa32 csa1_5_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[235]),		//i--
      .b(ex3_pp0_15[235]),		//i--
      .c(ex3_pp0_16[235]),		//i--
      .sum(ex3_pp1_5s[235]),		//o--
      .car(ex3_pp1_5c[234])		//o--
   );


   tri_csa32 csa1_5_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[234]),		//i--
      .b(ex3_pp0_15[234]),		//i--
      .c(ex3_pp0_16[234]),		//i--
      .sum(ex3_pp1_5s[234]),		//o--
      .car(ex3_pp1_5c[233])		//o--
   );


   tri_csa32 csa1_5_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[233]),		//i--
      .b(ex3_pp0_15[233]),		//i--
      .c(ex3_pp0_16[233]),		//i--
      .sum(ex3_pp1_5s[233]),		//o--
      .car(ex3_pp1_5c[232])		//o--
   );


   tri_csa32 csa1_5_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[232]),		//i--
      .b(ex3_pp0_15[232]),		//i--
      .c(ex3_pp0_16[232]),		//i--
      .sum(ex3_pp1_5s[232]),		//o--
      .car(ex3_pp1_5c[231])		//o--
   );


   tri_csa32 csa1_5_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[231]),		//i--
      .b(ex3_pp0_15[231]),		//i--
      .c(ex3_pp0_16[231]),		//i--
      .sum(ex3_pp1_5s[231]),		//o--
      .car(ex3_pp1_5c[230])		//o--
   );


   tri_csa32 csa1_5_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[230]),		//i--
      .b(ex3_pp0_15[230]),		//i--
      .c(ex3_pp0_16[230]),		//i--
      .sum(ex3_pp1_5s[230]),		//o--
      .car(ex3_pp1_5c[229])		//o--
   );


   tri_csa32 csa1_5_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp0_14[229]),		//i--
      .b(ex3_pp0_15[229]),		//i--
      .c(ex3_pp0_16[229]),		//i--
      .sum(ex3_pp1_5s[229]),		//o--
      .car(ex3_pp1_5c[228])		//o--
   );

   tri_csa22 csa1_5_228(
      .a(ex3_pp0_14[228]),		//i--
      .b(ex3_pp0_15[228]),		//i--
      .sum(ex3_pp1_5s[228]),		//o--
      .car(ex3_pp1_5c[227])		//o--
   );
   assign ex3_pp1_5s[227] = ex3_pp0_14[227];		//pass_x_s
   assign ex3_pp1_5s[226] = ex3_pp0_14[226];		//pass_s

   //***********************************
   //** compression level 2
   //***********************************

   // g2 : for i in 196 to 264 generate

   // csa2_0: entity c_prism_csa42 generic map( btr => "MLT42_X1_A12TH" ) port map(
   //    a    => ex3_pp1_0s(i)                          ,--i--
   //    b    => ex3_pp1_0c(i)                          ,--i--
   //    c    => ex3_pp1_1s(i)                          ,--i--
   //    d    => ex3_pp1_1c(i)                          ,--i--
   //    ki   => ex3_pp2_0k(i)                          ,--i--
   //    ko   => ex3_pp2_0k(i - 1)                      ,--o--
   //    sum  => ex3_pp2_0s(i)                          ,--o--
   //    car  => ex3_pp2_0c(i - 1)                     );--o--
   //
   // csa2_1: entity c_prism_csa42 generic map( btr => "MLT42_X1_A12TH" ) port map(
   //    a    => ex3_pp1_2s(i)                          ,--i--
   //    b    => ex3_pp1_2c(i)                          ,--i--
   //    c    => ex3_pp1_3s(i)                          ,--i--
   //    d    => ex3_pp1_3c(i)                          ,--i--
   //    ki   => ex3_pp2_1k(i)                          ,--i--
   //    ko   => ex3_pp2_1k(i - 1)                      ,--o--
   //    sum  => ex3_pp2_1s(i)                          ,--o--
   //    car  => ex3_pp2_1c(i - 1)                     );--o--
   //
   // csa2_2: entity c_prism_csa42 generic map( btr => "MLT42_X1_A12TH" ) port map(
   //    a    => ex3_pp1_4s(i)                          ,--i--
   //    b    => ex3_pp1_4c(i)                          ,--i--
   //    c    => ex3_pp1_5s(i)                          ,--i--
   //    d    => ex3_pp1_5c(i)                          ,--i--
   //    ki   => ex3_pp2_2k(i)                          ,--i--
   //    ko   => ex3_pp2_2k(i - 1)                      ,--o--
   //    sum  => ex3_pp2_2s(i)                          ,--o--
   //    car  => ex3_pp2_2c(i - 1)                     );--o--
   //
   // end generate;

   //----- <csa2_0> -----

   assign ex3_pp2_0s[242] = ex3_pp1_1s[242];		//pass_s
   assign ex3_pp2_0s[241] = 0;		//pass_none
   assign ex3_pp2_0c[240] = ex3_pp1_1s[240];		//pass_cs
   assign ex3_pp2_0s[240] = ex3_pp1_1c[240];		//pass_cs
   assign ex3_pp2_0c[239] = 0;		//pass_s
   assign ex3_pp2_0s[239] = ex3_pp1_1s[239];		//pass_s
   assign ex3_pp2_0c[238] = 0;		//pass_s
   assign ex3_pp2_0s[238] = ex3_pp1_1s[238];		//pass_s
   assign ex3_pp2_0c[237] = ex3_pp1_1s[237];		//pass_cs
   assign ex3_pp2_0s[237] = ex3_pp1_1c[237];		//pass_cs
   assign ex3_pp2_0c[236] = 0;		//wr_csa32


   tri_csa32 csa2_0_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0s[236]),		//i--
      .b(ex3_pp1_1c[236]),		//i--
      .c(ex3_pp1_1s[236]),		//i--
      .sum(ex3_pp2_0s[236]),		//o--
      .car(ex3_pp2_0c[235])		//o--
   );

   tri_csa22 csa2_0_235(
      .a(ex3_pp1_1c[235]),		//i--
      .b(ex3_pp1_1s[235]),		//i--
      .sum(ex3_pp2_0s[235]),		//o--
      .car(ex3_pp2_0c[234])		//o--
   );
   assign ex3_pp2_0k[234] = 0;		//start_k

         	// MLT42_X1_A12TH
   tri_csa42 csa2_0_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[234]),		//i--
      .b(ex3_pp1_0s[234]),		//i--
      .c(ex3_pp1_1c[234]),		//i--
      .d(ex3_pp1_1s[234]),		//i--
      .ki(ex3_pp2_0k[234]),		//i--
      .ko(ex3_pp2_0k[233]),		//o--
      .sum(ex3_pp2_0s[234]),		//o--
      .car(ex3_pp2_0c[233])		//o--
   );


   tri_csa42 csa2_0_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0s[233]),		//i--
      .b(ex3_pp1_1c[233]),		//i--
      .c(ex3_pp1_1s[233]),		//i--
      .d(1'b0),		//i--
      .ki(ex3_pp2_0k[233]),		//i--
      .ko(ex3_pp2_0k[232]),		//o--
      .sum(ex3_pp2_0s[233]),		//o--
      .car(ex3_pp2_0c[232])		//o--
   );


   tri_csa42 csa2_0_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0s[232]),		//i--
      .b(ex3_pp1_1c[232]),		//i--
      .c(ex3_pp1_1s[232]),		//i--
      .d(1'b0),		//i--
      .ki(ex3_pp2_0k[232]),		//i--
      .ko(ex3_pp2_0k[231]),		//o--
      .sum(ex3_pp2_0s[232]),		//o--
      .car(ex3_pp2_0c[231])		//o--
   );


   tri_csa42 csa2_0_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[231]),		//i--
      .b(ex3_pp1_0s[231]),		//i--
      .c(ex3_pp1_1c[231]),		//i--
      .d(ex3_pp1_1s[231]),		//i--
      .ki(ex3_pp2_0k[231]),		//i--
      .ko(ex3_pp2_0k[230]),		//o--
      .sum(ex3_pp2_0s[231]),		//o--
      .car(ex3_pp2_0c[230])		//o--
   );


   tri_csa42 csa2_0_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[230]),		//i--
      .b(ex3_pp1_0s[230]),		//i--
      .c(ex3_pp1_1c[230]),		//i--
      .d(ex3_pp1_1s[230]),		//i--
      .ki(ex3_pp2_0k[230]),		//i--
      .ko(ex3_pp2_0k[229]),		//o--
      .sum(ex3_pp2_0s[230]),		//o--
      .car(ex3_pp2_0c[229])		//o--
   );


   tri_csa42 csa2_0_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[229]),		//i--
      .b(ex3_pp1_0s[229]),		//i--
      .c(ex3_pp1_1c[229]),		//i--
      .d(ex3_pp1_1s[229]),		//i--
      .ki(ex3_pp2_0k[229]),		//i--
      .ko(ex3_pp2_0k[228]),		//o--
      .sum(ex3_pp2_0s[229]),		//o--
      .car(ex3_pp2_0c[228])		//o--
   );


   tri_csa42 csa2_0_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[228]),		//i--
      .b(ex3_pp1_0s[228]),		//i--
      .c(ex3_pp1_1c[228]),		//i--
      .d(ex3_pp1_1s[228]),		//i--
      .ki(ex3_pp2_0k[228]),		//i--
      .ko(ex3_pp2_0k[227]),		//o--
      .sum(ex3_pp2_0s[228]),		//o--
      .car(ex3_pp2_0c[227])		//o--
   );


   tri_csa42 csa2_0_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[227]),		//i--
      .b(ex3_pp1_0s[227]),		//i--
      .c(ex3_pp1_1c[227]),		//i--
      .d(ex3_pp1_1s[227]),		//i--
      .ki(ex3_pp2_0k[227]),		//i--
      .ko(ex3_pp2_0k[226]),		//o--
      .sum(ex3_pp2_0s[227]),		//o--
      .car(ex3_pp2_0c[226])		//o--
   );


   tri_csa42 csa2_0_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[226]),		//i--
      .b(ex3_pp1_0s[226]),		//i--
      .c(ex3_pp1_1c[226]),		//i--
      .d(ex3_pp1_1s[226]),		//i--
      .ki(ex3_pp2_0k[226]),		//i--
      .ko(ex3_pp2_0k[225]),		//o--
      .sum(ex3_pp2_0s[226]),		//o--
      .car(ex3_pp2_0c[225])		//o--
   );


   tri_csa42 csa2_0_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[225]),		//i--
      .b(ex3_pp1_0s[225]),		//i--
      .c(ex3_pp1_1c[225]),		//i--
      .d(ex3_pp1_1s[225]),		//i--
      .ki(ex3_pp2_0k[225]),		//i--
      .ko(ex3_pp2_0k[224]),		//o--
      .sum(ex3_pp2_0s[225]),		//o--
      .car(ex3_pp2_0c[224])		//o--
   );


   tri_csa42 csa2_0_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[224]),		//i--
      .b(ex3_pp1_0s[224]),		//i--
      .c(ex3_pp1_1c[224]),		//i--
      .d(ex3_pp1_1s[224]),		//i--
      .ki(ex3_pp2_0k[224]),		//i--
      .ko(ex3_pp2_0k[223]),		//o--
      .sum(ex3_pp2_0s[224]),		//o--
      .car(ex3_pp2_0c[223])		//o--
   );


   tri_csa42 csa2_0_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[223]),		//i--
      .b(ex3_pp1_0s[223]),		//i--
      .c(ex3_pp1_1c[223]),		//i--
      .d(ex3_pp1_1s[223]),		//i--
      .ki(ex3_pp2_0k[223]),		//i--
      .ko(ex3_pp2_0k[222]),		//o--
      .sum(ex3_pp2_0s[223]),		//o--
      .car(ex3_pp2_0c[222])		//o--
   );


   tri_csa42 csa2_0_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[222]),		//i--
      .b(ex3_pp1_0s[222]),		//i--
      .c(ex3_pp1_1c[222]),		//i--
      .d(ex3_pp1_1s[222]),		//i--
      .ki(ex3_pp2_0k[222]),		//i--
      .ko(ex3_pp2_0k[221]),		//o--
      .sum(ex3_pp2_0s[222]),		//o--
      .car(ex3_pp2_0c[221])		//o--
   );


   tri_csa42 csa2_0_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[221]),		//i--
      .b(ex3_pp1_0s[221]),		//i--
      .c(ex3_pp1_1c[221]),		//i--
      .d(ex3_pp1_1s[221]),		//i--
      .ki(ex3_pp2_0k[221]),		//i--
      .ko(ex3_pp2_0k[220]),		//o--
      .sum(ex3_pp2_0s[221]),		//o--
      .car(ex3_pp2_0c[220])		//o--
   );


   tri_csa42 csa2_0_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[220]),		//i--
      .b(ex3_pp1_0s[220]),		//i--
      .c(ex3_pp1_1c[220]),		//i--
      .d(ex3_pp1_1s[220]),		//i--
      .ki(ex3_pp2_0k[220]),		//i--
      .ko(ex3_pp2_0k[219]),		//o--
      .sum(ex3_pp2_0s[220]),		//o--
      .car(ex3_pp2_0c[219])		//o--
   );


   tri_csa42 csa2_0_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[219]),		//i--
      .b(ex3_pp1_0s[219]),		//i--
      .c(ex3_pp1_1c[219]),		//i--
      .d(ex3_pp1_1s[219]),		//i--
      .ki(ex3_pp2_0k[219]),		//i--
      .ko(ex3_pp2_0k[218]),		//o--
      .sum(ex3_pp2_0s[219]),		//o--
      .car(ex3_pp2_0c[218])		//o--
   );


   tri_csa42 csa2_0_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[218]),		//i--
      .b(ex3_pp1_0s[218]),		//i--
      .c(ex3_pp1_1c[218]),		//i--
      .d(ex3_pp1_1s[218]),		//i--
      .ki(ex3_pp2_0k[218]),		//i--
      .ko(ex3_pp2_0k[217]),		//o--
      .sum(ex3_pp2_0s[218]),		//o--
      .car(ex3_pp2_0c[217])		//o--
   );


   tri_csa42 csa2_0_217(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[217]),		//i--
      .b(ex3_pp1_0s[217]),		//i--
      .c(ex3_pp1_1c[217]),		//i--
      .d(ex3_pp1_1s[217]),		//i--
      .ki(ex3_pp2_0k[217]),		//i--
      .ko(ex3_pp2_0k[216]),		//o--
      .sum(ex3_pp2_0s[217]),		//o--
      .car(ex3_pp2_0c[216])		//o--
   );


   tri_csa42 csa2_0_216(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[216]),		//i--
      .b(ex3_pp1_0s[216]),		//i--
      .c(ex3_pp1_1c[216]),		//i--
      .d(ex3_pp1_1s[216]),		//i--
      .ki(ex3_pp2_0k[216]),		//i--
      .ko(ex3_pp2_0k[215]),		//o--
      .sum(ex3_pp2_0s[216]),		//o--
      .car(ex3_pp2_0c[215])		//o--
   );


   tri_csa42 csa2_0_215(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[215]),		//i--
      .b(ex3_pp1_0s[215]),		//i--
      .c(ex3_pp1_1c[215]),		//i--
      .d(ex3_pp1_1s[215]),		//i--
      .ki(ex3_pp2_0k[215]),		//i--
      .ko(ex3_pp2_0k[214]),		//o--
      .sum(ex3_pp2_0s[215]),		//o--
      .car(ex3_pp2_0c[214])		//o--
   );


   tri_csa42 csa2_0_214(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[214]),		//i--
      .b(ex3_pp1_0s[214]),		//i--
      .c(ex3_pp1_1c[214]),		//i--
      .d(ex3_pp1_1s[214]),		//i--
      .ki(ex3_pp2_0k[214]),		//i--
      .ko(ex3_pp2_0k[213]),		//o--
      .sum(ex3_pp2_0s[214]),		//o--
      .car(ex3_pp2_0c[213])		//o--
   );


   tri_csa42 csa2_0_213(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[213]),		//i--
      .b(ex3_pp1_0s[213]),		//i--
      .c(ex3_pp1_1c[213]),		//i--
      .d(ex3_pp1_1s[213]),		//i--
      .ki(ex3_pp2_0k[213]),		//i--
      .ko(ex3_pp2_0k[212]),		//o--
      .sum(ex3_pp2_0s[213]),		//o--
      .car(ex3_pp2_0c[212])		//o--
   );


   tri_csa42 csa2_0_212(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[212]),		//i--
      .b(ex3_pp1_0s[212]),		//i--
      .c(ex3_pp1_1c[212]),		//i--
      .d(ex3_pp1_1s[212]),		//i--
      .ki(ex3_pp2_0k[212]),		//i--
      .ko(ex3_pp2_0k[211]),		//o--
      .sum(ex3_pp2_0s[212]),		//o--
      .car(ex3_pp2_0c[211])		//o--
   );


   tri_csa42 csa2_0_211(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[211]),		//i--
      .b(ex3_pp1_0s[211]),		//i--
      .c(ex3_pp1_1c[211]),		//i--
      .d(ex3_pp1_1s[211]),		//i--
      .ki(ex3_pp2_0k[211]),		//i--
      .ko(ex3_pp2_0k[210]),		//o--
      .sum(ex3_pp2_0s[211]),		//o--
      .car(ex3_pp2_0c[210])		//o--
   );


   tri_csa42 csa2_0_210(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[210]),		//i--
      .b(ex3_pp1_0s[210]),		//i--
      .c(ex3_pp1_1c[210]),		//i--
      .d(ex3_pp1_1s[210]),		//i--
      .ki(ex3_pp2_0k[210]),		//i--
      .ko(ex3_pp2_0k[209]),		//o--
      .sum(ex3_pp2_0s[210]),		//o--
      .car(ex3_pp2_0c[209])		//o--
   );


   tri_csa42 csa2_0_209(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[209]),		//i--
      .b(ex3_pp1_0s[209]),		//i--
      .c(ex3_pp1_1c[209]),		//i--
      .d(ex3_pp1_1s[209]),		//i--
      .ki(ex3_pp2_0k[209]),		//i--
      .ko(ex3_pp2_0k[208]),		//o--
      .sum(ex3_pp2_0s[209]),		//o--
      .car(ex3_pp2_0c[208])		//o--
   );


   tri_csa42 csa2_0_208(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[208]),		//i--
      .b(ex3_pp1_0s[208]),		//i--
      .c(ex3_pp1_1c[208]),		//i--
      .d(ex3_pp1_1s[208]),		//i--
      .ki(ex3_pp2_0k[208]),		//i--
      .ko(ex3_pp2_0k[207]),		//o--
      .sum(ex3_pp2_0s[208]),		//o--
      .car(ex3_pp2_0c[207])		//o--
   );


   tri_csa42 csa2_0_207(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[207]),		//i--
      .b(ex3_pp1_0s[207]),		//i--
      .c(ex3_pp1_1c[207]),		//i--
      .d(ex3_pp1_1s[207]),		//i--
      .ki(ex3_pp2_0k[207]),		//i--
      .ko(ex3_pp2_0k[206]),		//o--
      .sum(ex3_pp2_0s[207]),		//o--
      .car(ex3_pp2_0c[206])		//o--
   );


   tri_csa42 csa2_0_206(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[206]),		//i--
      .b(ex3_pp1_0s[206]),		//i--
      .c(ex3_pp1_1c[206]),		//i--
      .d(ex3_pp1_1s[206]),		//i--
      .ki(ex3_pp2_0k[206]),		//i--
      .ko(ex3_pp2_0k[205]),		//o--
      .sum(ex3_pp2_0s[206]),		//o--
      .car(ex3_pp2_0c[205])		//o--
   );


   tri_csa42 csa2_0_205(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[205]),		//i--
      .b(ex3_pp1_0s[205]),		//i--
      .c(ex3_pp1_1c[205]),		//i--
      .d(ex3_pp1_1s[205]),		//i--
      .ki(ex3_pp2_0k[205]),		//i--
      .ko(ex3_pp2_0k[204]),		//o--
      .sum(ex3_pp2_0s[205]),		//o--
      .car(ex3_pp2_0c[204])		//o--
   );


   tri_csa42 csa2_0_204(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[204]),		//i--
      .b(ex3_pp1_0s[204]),		//i--
      .c(ex3_pp1_1c[204]),		//i--
      .d(ex3_pp1_1s[204]),		//i--
      .ki(ex3_pp2_0k[204]),		//i--
      .ko(ex3_pp2_0k[203]),		//o--
      .sum(ex3_pp2_0s[204]),		//o--
      .car(ex3_pp2_0c[203])		//o--
   );


   tri_csa42 csa2_0_203(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[203]),		//i--
      .b(ex3_pp1_0s[203]),		//i--
      .c(ex3_pp1_1c[203]),		//i--
      .d(ex3_pp1_1s[203]),		//i--
      .ki(ex3_pp2_0k[203]),		//i--
      .ko(ex3_pp2_0k[202]),		//o--
      .sum(ex3_pp2_0s[203]),		//o--
      .car(ex3_pp2_0c[202])		//o--
   );


   tri_csa42 csa2_0_202(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[202]),		//i--
      .b(ex3_pp1_0s[202]),		//i--
      .c(ex3_pp1_1s[202]),		//i--
      .d(1'b0),		//i--
      .ki(ex3_pp2_0k[202]),		//i--
      .ko(ex3_pp2_0k[201]),		//o--
      .sum(ex3_pp2_0s[202]),		//o--
      .car(ex3_pp2_0c[201])		//o--
   );


   tri_csa32 csa2_0_201(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_0c[201]),		//i--
      .b(ex3_pp1_0s[201]),		//i--
      .c(ex3_pp2_0k[201]),		//i--
      .sum(ex3_pp2_0s[201]),		//o--
      .car(ex3_pp2_0c[200])		//o--
   );

   tri_csa22 csa2_0_200(
      .a(ex3_pp1_0c[200]),		//i--
      .b(ex3_pp1_0s[200]),		//i--
      .sum(ex3_pp2_0s[200]),		//o--
      .car(ex3_pp2_0c[199])		//o--
   );

   tri_csa22 csa2_0_199(
      .a(ex3_pp1_0c[199]),		//i--
      .b(ex3_pp1_0s[199]),		//i--
      .sum(ex3_pp2_0s[199]),		//o--
      .car(ex3_pp2_0c[198])		//o--
   );
   assign ex3_pp2_0s[198] = ex3_pp1_0s[198];		//pass_x_s

   //----- <csa2_1> -----

   assign ex3_pp2_1s[254] = ex3_pp1_3s[254];		//pass_s
   assign ex3_pp2_1s[253] = 0;		//pass_none
   assign ex3_pp2_1c[252] = ex3_pp1_3s[252];		//pass_cs
   assign ex3_pp2_1s[252] = ex3_pp1_3c[252];		//pass_cs
   assign ex3_pp2_1c[251] = 0;		//pass_s
   assign ex3_pp2_1s[251] = ex3_pp1_3s[251];		//pass_s
   assign ex3_pp2_1c[250] = 0;		//pass_s
   assign ex3_pp2_1s[250] = ex3_pp1_3s[250];		//pass_s
   assign ex3_pp2_1c[249] = ex3_pp1_3s[249];		//pass_cs
   assign ex3_pp2_1s[249] = ex3_pp1_3c[249];		//pass_cs
   assign ex3_pp2_1c[248] = 0;		//wr_csa32


   tri_csa32 csa2_1_248(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2s[248]),		//i--
      .b(ex3_pp1_3c[248]),		//i--
      .c(ex3_pp1_3s[248]),		//i--
      .sum(ex3_pp2_1s[248]),		//o--
      .car(ex3_pp2_1c[247])		//o--
   );

   tri_csa22 csa2_1_247(
      .a(ex3_pp1_3c[247]),		//i--
      .b(ex3_pp1_3s[247]),		//i--
      .sum(ex3_pp2_1s[247]),		//o--
      .car(ex3_pp2_1c[246])		//o--
   );
   assign ex3_pp2_1k[246] = 0;		//start_k


   tri_csa42 csa2_1_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[246]),		//i--
      .b(ex3_pp1_2s[246]),		//i--
      .c(ex3_pp1_3c[246]),		//i--
      .d(ex3_pp1_3s[246]),		//i--
      .ki(ex3_pp2_1k[246]),		//i--
      .ko(ex3_pp2_1k[245]),		//o--
      .sum(ex3_pp2_1s[246]),		//o--
      .car(ex3_pp2_1c[245])		//o--
   );


   tri_csa42 csa2_1_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2s[245]),		//i--
      .b(ex3_pp1_3c[245]),		//i--
      .c(ex3_pp1_3s[245]),		//i--
      .d(1'b0),		//i--
      .ki(ex3_pp2_1k[245]),		//i--
      .ko(ex3_pp2_1k[244]),		//o--
      .sum(ex3_pp2_1s[245]),		//o--
      .car(ex3_pp2_1c[244])		//o--
   );


   tri_csa42 csa2_1_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2s[244]),		//i--
      .b(ex3_pp1_3c[244]),		//i--
      .c(ex3_pp1_3s[244]),		//i--
      .d(1'b0),		//i--
      .ki(ex3_pp2_1k[244]),		//i--
      .ko(ex3_pp2_1k[243]),		//o--
      .sum(ex3_pp2_1s[244]),		//o--
      .car(ex3_pp2_1c[243])		//o--
   );


   tri_csa42 csa2_1_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[243]),		//i--
      .b(ex3_pp1_2s[243]),		//i--
      .c(ex3_pp1_3c[243]),		//i--
      .d(ex3_pp1_3s[243]),		//i--
      .ki(ex3_pp2_1k[243]),		//i--
      .ko(ex3_pp2_1k[242]),		//o--
      .sum(ex3_pp2_1s[243]),		//o--
      .car(ex3_pp2_1c[242])		//o--
   );


   tri_csa42 csa2_1_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[242]),		//i--
      .b(ex3_pp1_2s[242]),		//i--
      .c(ex3_pp1_3c[242]),		//i--
      .d(ex3_pp1_3s[242]),		//i--
      .ki(ex3_pp2_1k[242]),		//i--
      .ko(ex3_pp2_1k[241]),		//o--
      .sum(ex3_pp2_1s[242]),		//o--
      .car(ex3_pp2_1c[241])		//o--
   );


   tri_csa42 csa2_1_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[241]),		//i--
      .b(ex3_pp1_2s[241]),		//i--
      .c(ex3_pp1_3c[241]),		//i--
      .d(ex3_pp1_3s[241]),		//i--
      .ki(ex3_pp2_1k[241]),		//i--
      .ko(ex3_pp2_1k[240]),		//o--
      .sum(ex3_pp2_1s[241]),		//o--
      .car(ex3_pp2_1c[240])		//o--
   );


   tri_csa42 csa2_1_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[240]),		//i--
      .b(ex3_pp1_2s[240]),		//i--
      .c(ex3_pp1_3c[240]),		//i--
      .d(ex3_pp1_3s[240]),		//i--
      .ki(ex3_pp2_1k[240]),		//i--
      .ko(ex3_pp2_1k[239]),		//o--
      .sum(ex3_pp2_1s[240]),		//o--
      .car(ex3_pp2_1c[239])		//o--
   );


   tri_csa42 csa2_1_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[239]),		//i--
      .b(ex3_pp1_2s[239]),		//i--
      .c(ex3_pp1_3c[239]),		//i--
      .d(ex3_pp1_3s[239]),		//i--
      .ki(ex3_pp2_1k[239]),		//i--
      .ko(ex3_pp2_1k[238]),		//o--
      .sum(ex3_pp2_1s[239]),		//o--
      .car(ex3_pp2_1c[238])		//o--
   );


   tri_csa42 csa2_1_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[238]),		//i--
      .b(ex3_pp1_2s[238]),		//i--
      .c(ex3_pp1_3c[238]),		//i--
      .d(ex3_pp1_3s[238]),		//i--
      .ki(ex3_pp2_1k[238]),		//i--
      .ko(ex3_pp2_1k[237]),		//o--
      .sum(ex3_pp2_1s[238]),		//o--
      .car(ex3_pp2_1c[237])		//o--
   );


   tri_csa42 csa2_1_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[237]),		//i--
      .b(ex3_pp1_2s[237]),		//i--
      .c(ex3_pp1_3c[237]),		//i--
      .d(ex3_pp1_3s[237]),		//i--
      .ki(ex3_pp2_1k[237]),		//i--
      .ko(ex3_pp2_1k[236]),		//o--
      .sum(ex3_pp2_1s[237]),		//o--
      .car(ex3_pp2_1c[236])		//o--
   );


   tri_csa42 csa2_1_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[236]),		//i--
      .b(ex3_pp1_2s[236]),		//i--
      .c(ex3_pp1_3c[236]),		//i--
      .d(ex3_pp1_3s[236]),		//i--
      .ki(ex3_pp2_1k[236]),		//i--
      .ko(ex3_pp2_1k[235]),		//o--
      .sum(ex3_pp2_1s[236]),		//o--
      .car(ex3_pp2_1c[235])		//o--
   );


   tri_csa42 csa2_1_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[235]),		//i--
      .b(ex3_pp1_2s[235]),		//i--
      .c(ex3_pp1_3c[235]),		//i--
      .d(ex3_pp1_3s[235]),		//i--
      .ki(ex3_pp2_1k[235]),		//i--
      .ko(ex3_pp2_1k[234]),		//o--
      .sum(ex3_pp2_1s[235]),		//o--
      .car(ex3_pp2_1c[234])		//o--
   );


   tri_csa42 csa2_1_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[234]),		//i--
      .b(ex3_pp1_2s[234]),		//i--
      .c(ex3_pp1_3c[234]),		//i--
      .d(ex3_pp1_3s[234]),		//i--
      .ki(ex3_pp2_1k[234]),		//i--
      .ko(ex3_pp2_1k[233]),		//o--
      .sum(ex3_pp2_1s[234]),		//o--
      .car(ex3_pp2_1c[233])		//o--
   );


   tri_csa42 csa2_1_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[233]),		//i--
      .b(ex3_pp1_2s[233]),		//i--
      .c(ex3_pp1_3c[233]),		//i--
      .d(ex3_pp1_3s[233]),		//i--
      .ki(ex3_pp2_1k[233]),		//i--
      .ko(ex3_pp2_1k[232]),		//o--
      .sum(ex3_pp2_1s[233]),		//o--
      .car(ex3_pp2_1c[232])		//o--
   );


   tri_csa42 csa2_1_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[232]),		//i--
      .b(ex3_pp1_2s[232]),		//i--
      .c(ex3_pp1_3c[232]),		//i--
      .d(ex3_pp1_3s[232]),		//i--
      .ki(ex3_pp2_1k[232]),		//i--
      .ko(ex3_pp2_1k[231]),		//o--
      .sum(ex3_pp2_1s[232]),		//o--
      .car(ex3_pp2_1c[231])		//o--
   );


   tri_csa42 csa2_1_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[231]),		//i--
      .b(ex3_pp1_2s[231]),		//i--
      .c(ex3_pp1_3c[231]),		//i--
      .d(ex3_pp1_3s[231]),		//i--
      .ki(ex3_pp2_1k[231]),		//i--
      .ko(ex3_pp2_1k[230]),		//o--
      .sum(ex3_pp2_1s[231]),		//o--
      .car(ex3_pp2_1c[230])		//o--
   );


   tri_csa42 csa2_1_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[230]),		//i--
      .b(ex3_pp1_2s[230]),		//i--
      .c(ex3_pp1_3c[230]),		//i--
      .d(ex3_pp1_3s[230]),		//i--
      .ki(ex3_pp2_1k[230]),		//i--
      .ko(ex3_pp2_1k[229]),		//o--
      .sum(ex3_pp2_1s[230]),		//o--
      .car(ex3_pp2_1c[229])		//o--
   );


   tri_csa42 csa2_1_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[229]),		//i--
      .b(ex3_pp1_2s[229]),		//i--
      .c(ex3_pp1_3c[229]),		//i--
      .d(ex3_pp1_3s[229]),		//i--
      .ki(ex3_pp2_1k[229]),		//i--
      .ko(ex3_pp2_1k[228]),		//o--
      .sum(ex3_pp2_1s[229]),		//o--
      .car(ex3_pp2_1c[228])		//o--
   );


   tri_csa42 csa2_1_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[228]),		//i--
      .b(ex3_pp1_2s[228]),		//i--
      .c(ex3_pp1_3c[228]),		//i--
      .d(ex3_pp1_3s[228]),		//i--
      .ki(ex3_pp2_1k[228]),		//i--
      .ko(ex3_pp2_1k[227]),		//o--
      .sum(ex3_pp2_1s[228]),		//o--
      .car(ex3_pp2_1c[227])		//o--
   );


   tri_csa42 csa2_1_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[227]),		//i--
      .b(ex3_pp1_2s[227]),		//i--
      .c(ex3_pp1_3c[227]),		//i--
      .d(ex3_pp1_3s[227]),		//i--
      .ki(ex3_pp2_1k[227]),		//i--
      .ko(ex3_pp2_1k[226]),		//o--
      .sum(ex3_pp2_1s[227]),		//o--
      .car(ex3_pp2_1c[226])		//o--
   );


   tri_csa42 csa2_1_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[226]),		//i--
      .b(ex3_pp1_2s[226]),		//i--
      .c(ex3_pp1_3c[226]),		//i--
      .d(ex3_pp1_3s[226]),		//i--
      .ki(ex3_pp2_1k[226]),		//i--
      .ko(ex3_pp2_1k[225]),		//o--
      .sum(ex3_pp2_1s[226]),		//o--
      .car(ex3_pp2_1c[225])		//o--
   );


   tri_csa42 csa2_1_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[225]),		//i--
      .b(ex3_pp1_2s[225]),		//i--
      .c(ex3_pp1_3c[225]),		//i--
      .d(ex3_pp1_3s[225]),		//i--
      .ki(ex3_pp2_1k[225]),		//i--
      .ko(ex3_pp2_1k[224]),		//o--
      .sum(ex3_pp2_1s[225]),		//o--
      .car(ex3_pp2_1c[224])		//o--
   );


   tri_csa42 csa2_1_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[224]),		//i--
      .b(ex3_pp1_2s[224]),		//i--
      .c(ex3_pp1_3c[224]),		//i--
      .d(ex3_pp1_3s[224]),		//i--
      .ki(ex3_pp2_1k[224]),		//i--
      .ko(ex3_pp2_1k[223]),		//o--
      .sum(ex3_pp2_1s[224]),		//o--
      .car(ex3_pp2_1c[223])		//o--
   );


   tri_csa42 csa2_1_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[223]),		//i--
      .b(ex3_pp1_2s[223]),		//i--
      .c(ex3_pp1_3c[223]),		//i--
      .d(ex3_pp1_3s[223]),		//i--
      .ki(ex3_pp2_1k[223]),		//i--
      .ko(ex3_pp2_1k[222]),		//o--
      .sum(ex3_pp2_1s[223]),		//o--
      .car(ex3_pp2_1c[222])		//o--
   );


   tri_csa42 csa2_1_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[222]),		//i--
      .b(ex3_pp1_2s[222]),		//i--
      .c(ex3_pp1_3c[222]),		//i--
      .d(ex3_pp1_3s[222]),		//i--
      .ki(ex3_pp2_1k[222]),		//i--
      .ko(ex3_pp2_1k[221]),		//o--
      .sum(ex3_pp2_1s[222]),		//o--
      .car(ex3_pp2_1c[221])		//o--
   );


   tri_csa42 csa2_1_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[221]),		//i--
      .b(ex3_pp1_2s[221]),		//i--
      .c(ex3_pp1_3c[221]),		//i--
      .d(ex3_pp1_3s[221]),		//i--
      .ki(ex3_pp2_1k[221]),		//i--
      .ko(ex3_pp2_1k[220]),		//o--
      .sum(ex3_pp2_1s[221]),		//o--
      .car(ex3_pp2_1c[220])		//o--
   );


   tri_csa42 csa2_1_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[220]),		//i--
      .b(ex3_pp1_2s[220]),		//i--
      .c(ex3_pp1_3c[220]),		//i--
      .d(ex3_pp1_3s[220]),		//i--
      .ki(ex3_pp2_1k[220]),		//i--
      .ko(ex3_pp2_1k[219]),		//o--
      .sum(ex3_pp2_1s[220]),		//o--
      .car(ex3_pp2_1c[219])		//o--
   );


   tri_csa42 csa2_1_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[219]),		//i--
      .b(ex3_pp1_2s[219]),		//i--
      .c(ex3_pp1_3c[219]),		//i--
      .d(ex3_pp1_3s[219]),		//i--
      .ki(ex3_pp2_1k[219]),		//i--
      .ko(ex3_pp2_1k[218]),		//o--
      .sum(ex3_pp2_1s[219]),		//o--
      .car(ex3_pp2_1c[218])		//o--
   );


   tri_csa42 csa2_1_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[218]),		//i--
      .b(ex3_pp1_2s[218]),		//i--
      .c(ex3_pp1_3c[218]),		//i--
      .d(ex3_pp1_3s[218]),		//i--
      .ki(ex3_pp2_1k[218]),		//i--
      .ko(ex3_pp2_1k[217]),		//o--
      .sum(ex3_pp2_1s[218]),		//o--
      .car(ex3_pp2_1c[217])		//o--
   );


   tri_csa42 csa2_1_217(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[217]),		//i--
      .b(ex3_pp1_2s[217]),		//i--
      .c(ex3_pp1_3c[217]),		//i--
      .d(ex3_pp1_3s[217]),		//i--
      .ki(ex3_pp2_1k[217]),		//i--
      .ko(ex3_pp2_1k[216]),		//o--
      .sum(ex3_pp2_1s[217]),		//o--
      .car(ex3_pp2_1c[216])		//o--
   );


   tri_csa42 csa2_1_216(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[216]),		//i--
      .b(ex3_pp1_2s[216]),		//i--
      .c(ex3_pp1_3c[216]),		//i--
      .d(ex3_pp1_3s[216]),		//i--
      .ki(ex3_pp2_1k[216]),		//i--
      .ko(ex3_pp2_1k[215]),		//o--
      .sum(ex3_pp2_1s[216]),		//o--
      .car(ex3_pp2_1c[215])		//o--
   );


   tri_csa42 csa2_1_215(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[215]),		//i--
      .b(ex3_pp1_2s[215]),		//i--
      .c(ex3_pp1_3c[215]),		//i--
      .d(ex3_pp1_3s[215]),		//i--
      .ki(ex3_pp2_1k[215]),		//i--
      .ko(ex3_pp2_1k[214]),		//o--
      .sum(ex3_pp2_1s[215]),		//o--
      .car(ex3_pp2_1c[214])		//o--
   );


   tri_csa42 csa2_1_214(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[214]),		//i--
      .b(ex3_pp1_2s[214]),		//i--
      .c(ex3_pp1_3s[214]),		//i--
      .d(1'b0),		//i--
      .ki(ex3_pp2_1k[214]),		//i--
      .ko(ex3_pp2_1k[213]),		//o--
      .sum(ex3_pp2_1s[214]),		//o--
      .car(ex3_pp2_1c[213])		//o--
   );


   tri_csa32 csa2_1_213(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_2c[213]),		//i--
      .b(ex3_pp1_2s[213]),		//i--
      .c(ex3_pp2_1k[213]),		//i--
      .sum(ex3_pp2_1s[213]),		//o--
      .car(ex3_pp2_1c[212])		//o--
   );

   tri_csa22 csa2_1_212(
      .a(ex3_pp1_2c[212]),		//i--
      .b(ex3_pp1_2s[212]),		//i--
      .sum(ex3_pp2_1s[212]),		//o--
      .car(ex3_pp2_1c[211])		//o--
   );

   tri_csa22 csa2_1_211(
      .a(ex3_pp1_2c[211]),		//i--
      .b(ex3_pp1_2s[211]),		//i--
      .sum(ex3_pp2_1s[211]),		//o--
      .car(ex3_pp2_1c[210])		//o--
   );

   tri_csa22 csa2_1_210(
      .a(ex3_pp1_2c[210]),		//i--
      .b(ex3_pp1_2s[210]),		//i--
      .sum(ex3_pp2_1s[210]),		//o--
      .car(ex3_pp2_1c[209])		//o--
   );

   tri_csa22 csa2_1_209(
      .a(ex3_pp1_2c[209]),		//i--
      .b(ex3_pp1_2s[209]),		//i--
      .sum(ex3_pp2_1s[209]),		//o--
      .car(ex3_pp2_1c[208])		//o--
   );
   assign ex3_pp2_1s[208] = ex3_pp1_2s[208];		//pass_x_s

   //----- <csa2_2> -----


   tri_csa22 csa2_2_264(
      .a(ex3_pp1_5c[264]),		//i--
      .b(ex3_pp1_5s[264]),		//i--
      .sum(ex3_pp2_2s[264]),		//o--
      .car(ex3_pp2_2c[263])		//o--
   );
   assign ex3_pp2_2s[263] = ex3_pp1_5s[263];		//pass_x_s
   assign ex3_pp2_2c[262] = 0;		//pass_s
   assign ex3_pp2_2s[262] = ex3_pp1_5s[262];		//pass_s
   assign ex3_pp2_2c[261] = ex3_pp1_5s[261];		//pass_cs
   assign ex3_pp2_2s[261] = ex3_pp1_5c[261];		//pass_cs
   assign ex3_pp2_2c[260] = 0;		//wr_csa32


   tri_csa32 csa2_2_260(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4s[260]),		//i--
      .b(ex3_pp1_5c[260]),		//i--
      .c(ex3_pp1_5s[260]),		//i--
      .sum(ex3_pp2_2s[260]),		//o--
      .car(ex3_pp2_2c[259])		//o--
   );

   tri_csa22 csa2_2_259(
      .a(ex3_pp1_5c[259]),		//i--
      .b(ex3_pp1_5s[259]),		//i--
      .sum(ex3_pp2_2s[259]),		//o--
      .car(ex3_pp2_2c[258])		//o--
   );
   assign ex3_pp2_2k[258] = 0;		//start_k


   tri_csa42 csa2_2_258(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[258]),		//i--
      .b(ex3_pp1_4s[258]),		//i--
      .c(ex3_pp1_5c[258]),		//i--
      .d(ex3_pp1_5s[258]),		//i--
      .ki(ex3_pp2_2k[258]),		//i--
      .ko(ex3_pp2_2k[257]),		//o--
      .sum(ex3_pp2_2s[258]),		//o--
      .car(ex3_pp2_2c[257])		//o--
   );


   tri_csa42 csa2_2_257(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4s[257]),		//i--
      .b(ex3_pp1_5c[257]),		//i--
      .c(ex3_pp1_5s[257]),		//i--
      .d(1'b0),		//i--
      .ki(ex3_pp2_2k[257]),		//i--
      .ko(ex3_pp2_2k[256]),		//o--
      .sum(ex3_pp2_2s[257]),		//o--
      .car(ex3_pp2_2c[256])		//o--
   );


   tri_csa42 csa2_2_256(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4s[256]),		//i--
      .b(ex3_pp1_5c[256]),		//i--
      .c(ex3_pp1_5s[256]),		//i--
      .d(1'b0),		//i--
      .ki(ex3_pp2_2k[256]),		//i--
      .ko(ex3_pp2_2k[255]),		//o--
      .sum(ex3_pp2_2s[256]),		//o--
      .car(ex3_pp2_2c[255])		//o--
   );


   tri_csa42 csa2_2_255(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[255]),		//i--
      .b(ex3_pp1_4s[255]),		//i--
      .c(ex3_pp1_5c[255]),		//i--
      .d(ex3_pp1_5s[255]),		//i--
      .ki(ex3_pp2_2k[255]),		//i--
      .ko(ex3_pp2_2k[254]),		//o--
      .sum(ex3_pp2_2s[255]),		//o--
      .car(ex3_pp2_2c[254])		//o--
   );


   tri_csa42 csa2_2_254(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[254]),		//i--
      .b(ex3_pp1_4s[254]),		//i--
      .c(ex3_pp1_5c[254]),		//i--
      .d(ex3_pp1_5s[254]),		//i--
      .ki(ex3_pp2_2k[254]),		//i--
      .ko(ex3_pp2_2k[253]),		//o--
      .sum(ex3_pp2_2s[254]),		//o--
      .car(ex3_pp2_2c[253])		//o--
   );


   tri_csa42 csa2_2_253(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[253]),		//i--
      .b(ex3_pp1_4s[253]),		//i--
      .c(ex3_pp1_5c[253]),		//i--
      .d(ex3_pp1_5s[253]),		//i--
      .ki(ex3_pp2_2k[253]),		//i--
      .ko(ex3_pp2_2k[252]),		//o--
      .sum(ex3_pp2_2s[253]),		//o--
      .car(ex3_pp2_2c[252])		//o--
   );


   tri_csa42 csa2_2_252(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[252]),		//i--
      .b(ex3_pp1_4s[252]),		//i--
      .c(ex3_pp1_5c[252]),		//i--
      .d(ex3_pp1_5s[252]),		//i--
      .ki(ex3_pp2_2k[252]),		//i--
      .ko(ex3_pp2_2k[251]),		//o--
      .sum(ex3_pp2_2s[252]),		//o--
      .car(ex3_pp2_2c[251])		//o--
   );


   tri_csa42 csa2_2_251(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[251]),		//i--
      .b(ex3_pp1_4s[251]),		//i--
      .c(ex3_pp1_5c[251]),		//i--
      .d(ex3_pp1_5s[251]),		//i--
      .ki(ex3_pp2_2k[251]),		//i--
      .ko(ex3_pp2_2k[250]),		//o--
      .sum(ex3_pp2_2s[251]),		//o--
      .car(ex3_pp2_2c[250])		//o--
   );


   tri_csa42 csa2_2_250(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[250]),		//i--
      .b(ex3_pp1_4s[250]),		//i--
      .c(ex3_pp1_5c[250]),		//i--
      .d(ex3_pp1_5s[250]),		//i--
      .ki(ex3_pp2_2k[250]),		//i--
      .ko(ex3_pp2_2k[249]),		//o--
      .sum(ex3_pp2_2s[250]),		//o--
      .car(ex3_pp2_2c[249])		//o--
   );


   tri_csa42 csa2_2_249(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[249]),		//i--
      .b(ex3_pp1_4s[249]),		//i--
      .c(ex3_pp1_5c[249]),		//i--
      .d(ex3_pp1_5s[249]),		//i--
      .ki(ex3_pp2_2k[249]),		//i--
      .ko(ex3_pp2_2k[248]),		//o--
      .sum(ex3_pp2_2s[249]),		//o--
      .car(ex3_pp2_2c[248])		//o--
   );


   tri_csa42 csa2_2_248(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[248]),		//i--
      .b(ex3_pp1_4s[248]),		//i--
      .c(ex3_pp1_5c[248]),		//i--
      .d(ex3_pp1_5s[248]),		//i--
      .ki(ex3_pp2_2k[248]),		//i--
      .ko(ex3_pp2_2k[247]),		//o--
      .sum(ex3_pp2_2s[248]),		//o--
      .car(ex3_pp2_2c[247])		//o--
   );


   tri_csa42 csa2_2_247(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[247]),		//i--
      .b(ex3_pp1_4s[247]),		//i--
      .c(ex3_pp1_5c[247]),		//i--
      .d(ex3_pp1_5s[247]),		//i--
      .ki(ex3_pp2_2k[247]),		//i--
      .ko(ex3_pp2_2k[246]),		//o--
      .sum(ex3_pp2_2s[247]),		//o--
      .car(ex3_pp2_2c[246])		//o--
   );


   tri_csa42 csa2_2_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[246]),		//i--
      .b(ex3_pp1_4s[246]),		//i--
      .c(ex3_pp1_5c[246]),		//i--
      .d(ex3_pp1_5s[246]),		//i--
      .ki(ex3_pp2_2k[246]),		//i--
      .ko(ex3_pp2_2k[245]),		//o--
      .sum(ex3_pp2_2s[246]),		//o--
      .car(ex3_pp2_2c[245])		//o--
   );


   tri_csa42 csa2_2_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[245]),		//i--
      .b(ex3_pp1_4s[245]),		//i--
      .c(ex3_pp1_5c[245]),		//i--
      .d(ex3_pp1_5s[245]),		//i--
      .ki(ex3_pp2_2k[245]),		//i--
      .ko(ex3_pp2_2k[244]),		//o--
      .sum(ex3_pp2_2s[245]),		//o--
      .car(ex3_pp2_2c[244])		//o--
   );


   tri_csa42 csa2_2_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[244]),		//i--
      .b(ex3_pp1_4s[244]),		//i--
      .c(ex3_pp1_5c[244]),		//i--
      .d(ex3_pp1_5s[244]),		//i--
      .ki(ex3_pp2_2k[244]),		//i--
      .ko(ex3_pp2_2k[243]),		//o--
      .sum(ex3_pp2_2s[244]),		//o--
      .car(ex3_pp2_2c[243])		//o--
   );


   tri_csa42 csa2_2_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[243]),		//i--
      .b(ex3_pp1_4s[243]),		//i--
      .c(ex3_pp1_5c[243]),		//i--
      .d(ex3_pp1_5s[243]),		//i--
      .ki(ex3_pp2_2k[243]),		//i--
      .ko(ex3_pp2_2k[242]),		//o--
      .sum(ex3_pp2_2s[243]),		//o--
      .car(ex3_pp2_2c[242])		//o--
   );


   tri_csa42 csa2_2_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[242]),		//i--
      .b(ex3_pp1_4s[242]),		//i--
      .c(ex3_pp1_5c[242]),		//i--
      .d(ex3_pp1_5s[242]),		//i--
      .ki(ex3_pp2_2k[242]),		//i--
      .ko(ex3_pp2_2k[241]),		//o--
      .sum(ex3_pp2_2s[242]),		//o--
      .car(ex3_pp2_2c[241])		//o--
   );


   tri_csa42 csa2_2_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[241]),		//i--
      .b(ex3_pp1_4s[241]),		//i--
      .c(ex3_pp1_5c[241]),		//i--
      .d(ex3_pp1_5s[241]),		//i--
      .ki(ex3_pp2_2k[241]),		//i--
      .ko(ex3_pp2_2k[240]),		//o--
      .sum(ex3_pp2_2s[241]),		//o--
      .car(ex3_pp2_2c[240])		//o--
   );


   tri_csa42 csa2_2_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[240]),		//i--
      .b(ex3_pp1_4s[240]),		//i--
      .c(ex3_pp1_5c[240]),		//i--
      .d(ex3_pp1_5s[240]),		//i--
      .ki(ex3_pp2_2k[240]),		//i--
      .ko(ex3_pp2_2k[239]),		//o--
      .sum(ex3_pp2_2s[240]),		//o--
      .car(ex3_pp2_2c[239])		//o--
   );


   tri_csa42 csa2_2_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[239]),		//i--
      .b(ex3_pp1_4s[239]),		//i--
      .c(ex3_pp1_5c[239]),		//i--
      .d(ex3_pp1_5s[239]),		//i--
      .ki(ex3_pp2_2k[239]),		//i--
      .ko(ex3_pp2_2k[238]),		//o--
      .sum(ex3_pp2_2s[239]),		//o--
      .car(ex3_pp2_2c[238])		//o--
   );


   tri_csa42 csa2_2_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[238]),		//i--
      .b(ex3_pp1_4s[238]),		//i--
      .c(ex3_pp1_5c[238]),		//i--
      .d(ex3_pp1_5s[238]),		//i--
      .ki(ex3_pp2_2k[238]),		//i--
      .ko(ex3_pp2_2k[237]),		//o--
      .sum(ex3_pp2_2s[238]),		//o--
      .car(ex3_pp2_2c[237])		//o--
   );


   tri_csa42 csa2_2_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[237]),		//i--
      .b(ex3_pp1_4s[237]),		//i--
      .c(ex3_pp1_5c[237]),		//i--
      .d(ex3_pp1_5s[237]),		//i--
      .ki(ex3_pp2_2k[237]),		//i--
      .ko(ex3_pp2_2k[236]),		//o--
      .sum(ex3_pp2_2s[237]),		//o--
      .car(ex3_pp2_2c[236])		//o--
   );


   tri_csa42 csa2_2_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[236]),		//i--
      .b(ex3_pp1_4s[236]),		//i--
      .c(ex3_pp1_5c[236]),		//i--
      .d(ex3_pp1_5s[236]),		//i--
      .ki(ex3_pp2_2k[236]),		//i--
      .ko(ex3_pp2_2k[235]),		//o--
      .sum(ex3_pp2_2s[236]),		//o--
      .car(ex3_pp2_2c[235])		//o--
   );


   tri_csa42 csa2_2_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[235]),		//i--
      .b(ex3_pp1_4s[235]),		//i--
      .c(ex3_pp1_5c[235]),		//i--
      .d(ex3_pp1_5s[235]),		//i--
      .ki(ex3_pp2_2k[235]),		//i--
      .ko(ex3_pp2_2k[234]),		//o--
      .sum(ex3_pp2_2s[235]),		//o--
      .car(ex3_pp2_2c[234])		//o--
   );


   tri_csa42 csa2_2_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[234]),		//i--
      .b(ex3_pp1_4s[234]),		//i--
      .c(ex3_pp1_5c[234]),		//i--
      .d(ex3_pp1_5s[234]),		//i--
      .ki(ex3_pp2_2k[234]),		//i--
      .ko(ex3_pp2_2k[233]),		//o--
      .sum(ex3_pp2_2s[234]),		//o--
      .car(ex3_pp2_2c[233])		//o--
   );


   tri_csa42 csa2_2_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[233]),		//i--
      .b(ex3_pp1_4s[233]),		//i--
      .c(ex3_pp1_5c[233]),		//i--
      .d(ex3_pp1_5s[233]),		//i--
      .ki(ex3_pp2_2k[233]),		//i--
      .ko(ex3_pp2_2k[232]),		//o--
      .sum(ex3_pp2_2s[233]),		//o--
      .car(ex3_pp2_2c[232])		//o--
   );


   tri_csa42 csa2_2_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[232]),		//i--
      .b(ex3_pp1_4s[232]),		//i--
      .c(ex3_pp1_5c[232]),		//i--
      .d(ex3_pp1_5s[232]),		//i--
      .ki(ex3_pp2_2k[232]),		//i--
      .ko(ex3_pp2_2k[231]),		//o--
      .sum(ex3_pp2_2s[232]),		//o--
      .car(ex3_pp2_2c[231])		//o--
   );


   tri_csa42 csa2_2_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[231]),		//i--
      .b(ex3_pp1_4s[231]),		//i--
      .c(ex3_pp1_5c[231]),		//i--
      .d(ex3_pp1_5s[231]),		//i--
      .ki(ex3_pp2_2k[231]),		//i--
      .ko(ex3_pp2_2k[230]),		//o--
      .sum(ex3_pp2_2s[231]),		//o--
      .car(ex3_pp2_2c[230])		//o--
   );


   tri_csa42 csa2_2_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[230]),		//i--
      .b(ex3_pp1_4s[230]),		//i--
      .c(ex3_pp1_5c[230]),		//i--
      .d(ex3_pp1_5s[230]),		//i--
      .ki(ex3_pp2_2k[230]),		//i--
      .ko(ex3_pp2_2k[229]),		//o--
      .sum(ex3_pp2_2s[230]),		//o--
      .car(ex3_pp2_2c[229])		//o--
   );


   tri_csa42 csa2_2_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[229]),		//i--
      .b(ex3_pp1_4s[229]),		//i--
      .c(ex3_pp1_5c[229]),		//i--
      .d(ex3_pp1_5s[229]),		//i--
      .ki(ex3_pp2_2k[229]),		//i--
      .ko(ex3_pp2_2k[228]),		//o--
      .sum(ex3_pp2_2s[229]),		//o--
      .car(ex3_pp2_2c[228])		//o--
   );


   tri_csa42 csa2_2_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[228]),		//i--
      .b(ex3_pp1_4s[228]),		//i--
      .c(ex3_pp1_5c[228]),		//i--
      .d(ex3_pp1_5s[228]),		//i--
      .ki(ex3_pp2_2k[228]),		//i--
      .ko(ex3_pp2_2k[227]),		//o--
      .sum(ex3_pp2_2s[228]),		//o--
      .car(ex3_pp2_2c[227])		//o--
   );


   tri_csa42 csa2_2_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[227]),		//i--
      .b(ex3_pp1_4s[227]),		//i--
      .c(ex3_pp1_5c[227]),		//i--
      .d(ex3_pp1_5s[227]),		//i--
      .ki(ex3_pp2_2k[227]),		//i--
      .ko(ex3_pp2_2k[226]),		//o--
      .sum(ex3_pp2_2s[227]),		//o--
      .car(ex3_pp2_2c[226])		//o--
   );


   tri_csa42 csa2_2_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[226]),		//i--
      .b(ex3_pp1_4s[226]),		//i--
      .c(ex3_pp1_5s[226]),		//i--
      .d(1'b0),		//i--
      .ki(ex3_pp2_2k[226]),		//i--
      .ko(ex3_pp2_2k[225]),		//o--
      .sum(ex3_pp2_2s[226]),		//o--
      .car(ex3_pp2_2c[225])		//o--
   );


   tri_csa32 csa2_2_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex3_pp1_4c[225]),		//i--
      .b(ex3_pp1_4s[225]),		//i--
      .c(ex3_pp2_2k[225]),		//i--
      .sum(ex3_pp2_2s[225]),		//o--
      .car(ex3_pp2_2c[224])		//o--
   );

   tri_csa22 csa2_2_224(
      .a(ex3_pp1_4c[224]),		//i--
      .b(ex3_pp1_4s[224]),		//i--
      .sum(ex3_pp2_2s[224]),		//o--
      .car(ex3_pp2_2c[223])		//o--
   );

   tri_csa22 csa2_2_223(
      .a(ex3_pp1_4c[223]),		//i--
      .b(ex3_pp1_4s[223]),		//i--
      .sum(ex3_pp2_2s[223]),		//o--
      .car(ex3_pp2_2c[222])		//o--
   );

   tri_csa22 csa2_2_222(
      .a(ex3_pp1_4c[222]),		//i--
      .b(ex3_pp1_4s[222]),		//i--
      .sum(ex3_pp2_2s[222]),		//o--
      .car(ex3_pp2_2c[221])		//o--
   );

   tri_csa22 csa2_2_221(
      .a(ex3_pp1_4c[221]),		//i--
      .b(ex3_pp1_4s[221]),		//i--
      .sum(ex3_pp2_2s[221]),		//o--
      .car(ex3_pp2_2c[220])		//o--
   );
   assign ex3_pp2_2s[220] = ex3_pp1_4s[220];		//pass_x_s

   //---------------------------------------------
   //---------------------------------------------
   //---------------------------------------------

   assign ex4_pp2_0s_din[198:242] = ex3_pp2_0s[198:242];
   assign ex4_pp2_0c_din[198:240] = ex3_pp2_0c[198:240];
   assign ex4_pp2_1s_din[208:254] = ex3_pp2_1s[208:254];
   assign ex4_pp2_1c_din[208:252] = ex3_pp2_1c[208:252];
   assign ex4_pp2_2s_din[220:264] = ex3_pp2_2s[220:264];
   assign ex4_pp2_2c_din[220:263] = ex3_pp2_2c[220:263];

   //==================================================================================
   //== EX3 ( finish compression <6:2> , feedback compression with previous result )
   //==================================================================================

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

   //***********************************
   //** compression level 3
   //***********************************

   // g3 : for i in 196 to 264 generate
   //
   // csa3_0: entity c_prism_csa32  port map(
   //    a       => ex4_pp2_0s(i)      ,--i--
   //    b       => ex4_pp2_0c(i)      ,--i--
   //    c       => ex4_pp2_1s(i)      ,--i--
   //    sum     => ex4_pp3_0s(i)      ,--o--
   //    car     => ex4_pp3_0c(i-1)   );--o--
   //
   // csa3_1: entity c_prism_csa32  port map(
   //   a       => ex4_pp2_1c(i)      ,--i--
   //   b       => ex4_pp2_2s(i)      ,--i--
   //   c       => ex4_pp2_2c(i)      ,--i--
   //   sum     => ex4_pp3_1s(i)      ,--o--
   //   car     => ex4_pp3_1c(i-1)   );--o--
   //
   // end generate;

   //----- <csa3_0> -----

   assign ex4_pp3_0s[252] = ex4_pp2_1c[252];		//pass_s
   assign ex4_pp3_0s[251] = 0;		//pass_none
   assign ex4_pp3_0s[250] = 0;		//pass_none
   assign ex4_pp3_0s[249] = ex4_pp2_1c[249];		//pass_s
   assign ex4_pp3_0s[248] = 0;		//pass_none
   assign ex4_pp3_0s[247] = ex4_pp2_1c[247];		//pass_s
   assign ex4_pp3_0s[246] = ex4_pp2_1c[246];		//pass_s
   assign ex4_pp3_0s[245] = ex4_pp2_1c[245];		//pass_s
   assign ex4_pp3_0s[244] = ex4_pp2_1c[244];		//pass_s
   assign ex4_pp3_0s[243] = ex4_pp2_1c[243];		//pass_s
   assign ex4_pp3_0c[242] = ex4_pp2_1c[242];		//pass_cs
   assign ex4_pp3_0s[242] = ex4_pp2_0s[242];		//pass_cs
   assign ex4_pp3_0c[241] = 0;		//pass_s
   assign ex4_pp3_0s[241] = ex4_pp2_1c[241];		//pass_s
   assign ex4_pp3_0c[240] = 0;		//wr_csa32


   tri_csa32 csa3_0_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[240]),		//i--
      .b(ex4_pp2_0s[240]),		//i--
      .c(ex4_pp2_1c[240]),		//i--
      .sum(ex4_pp3_0s[240]),		//o--
      .car(ex4_pp3_0c[239])		//o--
   );

   tri_csa22 csa3_0_239(
      .a(ex4_pp2_0s[239]),		//i--
      .b(ex4_pp2_1c[239]),		//i--
      .sum(ex4_pp3_0s[239]),		//o--
      .car(ex4_pp3_0c[238])		//o--
   );

   tri_csa22 csa3_0_238(
      .a(ex4_pp2_0s[238]),		//i--
      .b(ex4_pp2_1c[238]),		//i--
      .sum(ex4_pp3_0s[238]),		//o--
      .car(ex4_pp3_0c[237])		//o--
   );


   tri_csa32 csa3_0_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[237]),		//i--
      .b(ex4_pp2_0s[237]),		//i--
      .c(ex4_pp2_1c[237]),		//i--
      .sum(ex4_pp3_0s[237]),		//o--
      .car(ex4_pp3_0c[236])		//o--
   );

   tri_csa22 csa3_0_236(
      .a(ex4_pp2_0s[236]),		//i--
      .b(ex4_pp2_1c[236]),		//i--
      .sum(ex4_pp3_0s[236]),		//o--
      .car(ex4_pp3_0c[235])		//o--
   );


   tri_csa32 csa3_0_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[235]),		//i--
      .b(ex4_pp2_0s[235]),		//i--
      .c(ex4_pp2_1c[235]),		//i--
      .sum(ex4_pp3_0s[235]),		//o--
      .car(ex4_pp3_0c[234])		//o--
   );


   tri_csa32 csa3_0_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[234]),		//i--
      .b(ex4_pp2_0s[234]),		//i--
      .c(ex4_pp2_1c[234]),		//i--
      .sum(ex4_pp3_0s[234]),		//o--
      .car(ex4_pp3_0c[233])		//o--
   );


   tri_csa32 csa3_0_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[233]),		//i--
      .b(ex4_pp2_0s[233]),		//i--
      .c(ex4_pp2_1c[233]),		//i--
      .sum(ex4_pp3_0s[233]),		//o--
      .car(ex4_pp3_0c[232])		//o--
   );


   tri_csa32 csa3_0_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[232]),		//i--
      .b(ex4_pp2_0s[232]),		//i--
      .c(ex4_pp2_1c[232]),		//i--
      .sum(ex4_pp3_0s[232]),		//o--
      .car(ex4_pp3_0c[231])		//o--
   );


   tri_csa32 csa3_0_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[231]),		//i--
      .b(ex4_pp2_0s[231]),		//i--
      .c(ex4_pp2_1c[231]),		//i--
      .sum(ex4_pp3_0s[231]),		//o--
      .car(ex4_pp3_0c[230])		//o--
   );


   tri_csa32 csa3_0_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[230]),		//i--
      .b(ex4_pp2_0s[230]),		//i--
      .c(ex4_pp2_1c[230]),		//i--
      .sum(ex4_pp3_0s[230]),		//o--
      .car(ex4_pp3_0c[229])		//o--
   );


   tri_csa32 csa3_0_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[229]),		//i--
      .b(ex4_pp2_0s[229]),		//i--
      .c(ex4_pp2_1c[229]),		//i--
      .sum(ex4_pp3_0s[229]),		//o--
      .car(ex4_pp3_0c[228])		//o--
   );


   tri_csa32 csa3_0_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[228]),		//i--
      .b(ex4_pp2_0s[228]),		//i--
      .c(ex4_pp2_1c[228]),		//i--
      .sum(ex4_pp3_0s[228]),		//o--
      .car(ex4_pp3_0c[227])		//o--
   );


   tri_csa32 csa3_0_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[227]),		//i--
      .b(ex4_pp2_0s[227]),		//i--
      .c(ex4_pp2_1c[227]),		//i--
      .sum(ex4_pp3_0s[227]),		//o--
      .car(ex4_pp3_0c[226])		//o--
   );


   tri_csa32 csa3_0_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[226]),		//i--
      .b(ex4_pp2_0s[226]),		//i--
      .c(ex4_pp2_1c[226]),		//i--
      .sum(ex4_pp3_0s[226]),		//o--
      .car(ex4_pp3_0c[225])		//o--
   );


   tri_csa32 csa3_0_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[225]),		//i--
      .b(ex4_pp2_0s[225]),		//i--
      .c(ex4_pp2_1c[225]),		//i--
      .sum(ex4_pp3_0s[225]),		//o--
      .car(ex4_pp3_0c[224])		//o--
   );


   tri_csa32 csa3_0_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[224]),		//i--
      .b(ex4_pp2_0s[224]),		//i--
      .c(ex4_pp2_1c[224]),		//i--
      .sum(ex4_pp3_0s[224]),		//o--
      .car(ex4_pp3_0c[223])		//o--
   );


   tri_csa32 csa3_0_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[223]),		//i--
      .b(ex4_pp2_0s[223]),		//i--
      .c(ex4_pp2_1c[223]),		//i--
      .sum(ex4_pp3_0s[223]),		//o--
      .car(ex4_pp3_0c[222])		//o--
   );


   tri_csa32 csa3_0_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[222]),		//i--
      .b(ex4_pp2_0s[222]),		//i--
      .c(ex4_pp2_1c[222]),		//i--
      .sum(ex4_pp3_0s[222]),		//o--
      .car(ex4_pp3_0c[221])		//o--
   );


   tri_csa32 csa3_0_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[221]),		//i--
      .b(ex4_pp2_0s[221]),		//i--
      .c(ex4_pp2_1c[221]),		//i--
      .sum(ex4_pp3_0s[221]),		//o--
      .car(ex4_pp3_0c[220])		//o--
   );


   tri_csa32 csa3_0_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[220]),		//i--
      .b(ex4_pp2_0s[220]),		//i--
      .c(ex4_pp2_1c[220]),		//i--
      .sum(ex4_pp3_0s[220]),		//o--
      .car(ex4_pp3_0c[219])		//o--
   );


   tri_csa32 csa3_0_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[219]),		//i--
      .b(ex4_pp2_0s[219]),		//i--
      .c(ex4_pp2_1c[219]),		//i--
      .sum(ex4_pp3_0s[219]),		//o--
      .car(ex4_pp3_0c[218])		//o--
   );


   tri_csa32 csa3_0_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[218]),		//i--
      .b(ex4_pp2_0s[218]),		//i--
      .c(ex4_pp2_1c[218]),		//i--
      .sum(ex4_pp3_0s[218]),		//o--
      .car(ex4_pp3_0c[217])		//o--
   );


   tri_csa32 csa3_0_217(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[217]),		//i--
      .b(ex4_pp2_0s[217]),		//i--
      .c(ex4_pp2_1c[217]),		//i--
      .sum(ex4_pp3_0s[217]),		//o--
      .car(ex4_pp3_0c[216])		//o--
   );


   tri_csa32 csa3_0_216(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[216]),		//i--
      .b(ex4_pp2_0s[216]),		//i--
      .c(ex4_pp2_1c[216]),		//i--
      .sum(ex4_pp3_0s[216]),		//o--
      .car(ex4_pp3_0c[215])		//o--
   );


   tri_csa32 csa3_0_215(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[215]),		//i--
      .b(ex4_pp2_0s[215]),		//i--
      .c(ex4_pp2_1c[215]),		//i--
      .sum(ex4_pp3_0s[215]),		//o--
      .car(ex4_pp3_0c[214])		//o--
   );


   tri_csa32 csa3_0_214(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[214]),		//i--
      .b(ex4_pp2_0s[214]),		//i--
      .c(ex4_pp2_1c[214]),		//i--
      .sum(ex4_pp3_0s[214]),		//o--
      .car(ex4_pp3_0c[213])		//o--
   );


   tri_csa32 csa3_0_213(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[213]),		//i--
      .b(ex4_pp2_0s[213]),		//i--
      .c(ex4_pp2_1c[213]),		//i--
      .sum(ex4_pp3_0s[213]),		//o--
      .car(ex4_pp3_0c[212])		//o--
   );


   tri_csa32 csa3_0_212(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[212]),		//i--
      .b(ex4_pp2_0s[212]),		//i--
      .c(ex4_pp2_1c[212]),		//i--
      .sum(ex4_pp3_0s[212]),		//o--
      .car(ex4_pp3_0c[211])		//o--
   );


   tri_csa32 csa3_0_211(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[211]),		//i--
      .b(ex4_pp2_0s[211]),		//i--
      .c(ex4_pp2_1c[211]),		//i--
      .sum(ex4_pp3_0s[211]),		//o--
      .car(ex4_pp3_0c[210])		//o--
   );


   tri_csa32 csa3_0_210(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[210]),		//i--
      .b(ex4_pp2_0s[210]),		//i--
      .c(ex4_pp2_1c[210]),		//i--
      .sum(ex4_pp3_0s[210]),		//o--
      .car(ex4_pp3_0c[209])		//o--
   );


   tri_csa32 csa3_0_209(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[209]),		//i--
      .b(ex4_pp2_0s[209]),		//i--
      .c(ex4_pp2_1c[209]),		//i--
      .sum(ex4_pp3_0s[209]),		//o--
      .car(ex4_pp3_0c[208])		//o--
   );


   tri_csa32 csa3_0_208(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_0c[208]),		//i--
      .b(ex4_pp2_0s[208]),		//i--
      .c(ex4_pp2_1c[208]),		//i--
      .sum(ex4_pp3_0s[208]),		//o--
      .car(ex4_pp3_0c[207])		//o--
   );

   tri_csa22 csa3_0_207(
      .a(ex4_pp2_0c[207]),		//i--
      .b(ex4_pp2_0s[207]),		//i--
      .sum(ex4_pp3_0s[207]),		//o--
      .car(ex4_pp3_0c[206])		//o--
   );

   tri_csa22 csa3_0_206(
      .a(ex4_pp2_0c[206]),		//i--
      .b(ex4_pp2_0s[206]),		//i--
      .sum(ex4_pp3_0s[206]),		//o--
      .car(ex4_pp3_0c[205])		//o--
   );

   tri_csa22 csa3_0_205(
      .a(ex4_pp2_0c[205]),		//i--
      .b(ex4_pp2_0s[205]),		//i--
      .sum(ex4_pp3_0s[205]),		//o--
      .car(ex4_pp3_0c[204])		//o--
   );

   tri_csa22 csa3_0_204(
      .a(ex4_pp2_0c[204]),		//i--
      .b(ex4_pp2_0s[204]),		//i--
      .sum(ex4_pp3_0s[204]),		//o--
      .car(ex4_pp3_0c[203])		//o--
   );

   tri_csa22 csa3_0_203(
      .a(ex4_pp2_0c[203]),		//i--
      .b(ex4_pp2_0s[203]),		//i--
      .sum(ex4_pp3_0s[203]),		//o--
      .car(ex4_pp3_0c[202])		//o--
   );

   tri_csa22 csa3_0_202(
      .a(ex4_pp2_0c[202]),		//i--
      .b(ex4_pp2_0s[202]),		//i--
      .sum(ex4_pp3_0s[202]),		//o--
      .car(ex4_pp3_0c[201])		//o--
   );

   tri_csa22 csa3_0_201(
      .a(ex4_pp2_0c[201]),		//i--
      .b(ex4_pp2_0s[201]),		//i--
      .sum(ex4_pp3_0s[201]),		//o--
      .car(ex4_pp3_0c[200])		//o--
   );

   tri_csa22 csa3_0_200(
      .a(ex4_pp2_0c[200]),		//i--
      .b(ex4_pp2_0s[200]),		//i--
      .sum(ex4_pp3_0s[200]),		//o--
      .car(ex4_pp3_0c[199])		//o--
   );

   tri_csa22 csa3_0_199(
      .a(ex4_pp2_0c[199]),		//i--
      .b(ex4_pp2_0s[199]),		//i--
      .sum(ex4_pp3_0s[199]),		//o--
      .car(ex4_pp3_0c[198])		//o--
   );

   tri_csa22 csa3_0_198(
      .a(ex4_pp2_0c[198]),		//i--
      .b(ex4_pp2_0s[198]),		//i--
      .sum(ex4_pp3_0s[198]),		//o--
      .car(ex4_pp3_0c[197])		//o--
   );

   //----- <csa3_1> -----

   assign ex4_pp3_1s[264] = ex4_pp2_2s[264];		//pass_s

   tri_csa22 csa3_1_263(
      .a(ex4_pp2_2c[263]),		//i--
      .b(ex4_pp2_2s[263]),		//i--
      .sum(ex4_pp3_1s[263]),		//o--
      .car(ex4_pp3_1c[262])		//o--
   );
   assign ex4_pp3_1s[262] = ex4_pp2_2s[262];		//pass_x_s
   assign ex4_pp3_1c[261] = ex4_pp2_2s[261];		//pass_cs
   assign ex4_pp3_1s[261] = ex4_pp2_2c[261];		//pass_cs
   assign ex4_pp3_1c[260] = 0;		//pass_s
   assign ex4_pp3_1s[260] = ex4_pp2_2s[260];		//pass_s
   assign ex4_pp3_1c[259] = ex4_pp2_2s[259];		//pass_cs
   assign ex4_pp3_1s[259] = ex4_pp2_2c[259];		//pass_cs
   assign ex4_pp3_1c[258] = ex4_pp2_2s[258];		//pass_cs
   assign ex4_pp3_1s[258] = ex4_pp2_2c[258];		//pass_cs
   assign ex4_pp3_1c[257] = ex4_pp2_2s[257];		//pass_cs
   assign ex4_pp3_1s[257] = ex4_pp2_2c[257];		//pass_cs
   assign ex4_pp3_1c[256] = ex4_pp2_2s[256];		//pass_cs
   assign ex4_pp3_1s[256] = ex4_pp2_2c[256];		//pass_cs
   assign ex4_pp3_1c[255] = ex4_pp2_2s[255];		//pass_cs
   assign ex4_pp3_1s[255] = ex4_pp2_2c[255];		//pass_cs
   assign ex4_pp3_1c[254] = 0;		//wr_csa32


   tri_csa32 csa3_1_254(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[254]),		//i--
      .b(ex4_pp2_2c[254]),		//i--
      .c(ex4_pp2_2s[254]),		//i--
      .sum(ex4_pp3_1s[254]),		//o--
      .car(ex4_pp3_1c[253])		//o--
   );

   tri_csa22 csa3_1_253(
      .a(ex4_pp2_2c[253]),		//i--
      .b(ex4_pp2_2s[253]),		//i--
      .sum(ex4_pp3_1s[253]),		//o--
      .car(ex4_pp3_1c[252])		//o--
   );


   tri_csa32 csa3_1_252(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[252]),		//i--
      .b(ex4_pp2_2c[252]),		//i--
      .c(ex4_pp2_2s[252]),		//i--
      .sum(ex4_pp3_1s[252]),		//o--
      .car(ex4_pp3_1c[251])		//o--
   );


   tri_csa32 csa3_1_251(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[251]),		//i--
      .b(ex4_pp2_2c[251]),		//i--
      .c(ex4_pp2_2s[251]),		//i--
      .sum(ex4_pp3_1s[251]),		//o--
      .car(ex4_pp3_1c[250])		//o--
   );


   tri_csa32 csa3_1_250(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[250]),		//i--
      .b(ex4_pp2_2c[250]),		//i--
      .c(ex4_pp2_2s[250]),		//i--
      .sum(ex4_pp3_1s[250]),		//o--
      .car(ex4_pp3_1c[249])		//o--
   );


   tri_csa32 csa3_1_249(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[249]),		//i--
      .b(ex4_pp2_2c[249]),		//i--
      .c(ex4_pp2_2s[249]),		//i--
      .sum(ex4_pp3_1s[249]),		//o--
      .car(ex4_pp3_1c[248])		//o--
   );


   tri_csa32 csa3_1_248(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[248]),		//i--
      .b(ex4_pp2_2c[248]),		//i--
      .c(ex4_pp2_2s[248]),		//i--
      .sum(ex4_pp3_1s[248]),		//o--
      .car(ex4_pp3_1c[247])		//o--
   );


   tri_csa32 csa3_1_247(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[247]),		//i--
      .b(ex4_pp2_2c[247]),		//i--
      .c(ex4_pp2_2s[247]),		//i--
      .sum(ex4_pp3_1s[247]),		//o--
      .car(ex4_pp3_1c[246])		//o--
   );


   tri_csa32 csa3_1_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[246]),		//i--
      .b(ex4_pp2_2c[246]),		//i--
      .c(ex4_pp2_2s[246]),		//i--
      .sum(ex4_pp3_1s[246]),		//o--
      .car(ex4_pp3_1c[245])		//o--
   );


   tri_csa32 csa3_1_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[245]),		//i--
      .b(ex4_pp2_2c[245]),		//i--
      .c(ex4_pp2_2s[245]),		//i--
      .sum(ex4_pp3_1s[245]),		//o--
      .car(ex4_pp3_1c[244])		//o--
   );


   tri_csa32 csa3_1_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[244]),		//i--
      .b(ex4_pp2_2c[244]),		//i--
      .c(ex4_pp2_2s[244]),		//i--
      .sum(ex4_pp3_1s[244]),		//o--
      .car(ex4_pp3_1c[243])		//o--
   );


   tri_csa32 csa3_1_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[243]),		//i--
      .b(ex4_pp2_2c[243]),		//i--
      .c(ex4_pp2_2s[243]),		//i--
      .sum(ex4_pp3_1s[243]),		//o--
      .car(ex4_pp3_1c[242])		//o--
   );


   tri_csa32 csa3_1_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[242]),		//i--
      .b(ex4_pp2_2c[242]),		//i--
      .c(ex4_pp2_2s[242]),		//i--
      .sum(ex4_pp3_1s[242]),		//o--
      .car(ex4_pp3_1c[241])		//o--
   );


   tri_csa32 csa3_1_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[241]),		//i--
      .b(ex4_pp2_2c[241]),		//i--
      .c(ex4_pp2_2s[241]),		//i--
      .sum(ex4_pp3_1s[241]),		//o--
      .car(ex4_pp3_1c[240])		//o--
   );


   tri_csa32 csa3_1_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[240]),		//i--
      .b(ex4_pp2_2c[240]),		//i--
      .c(ex4_pp2_2s[240]),		//i--
      .sum(ex4_pp3_1s[240]),		//o--
      .car(ex4_pp3_1c[239])		//o--
   );


   tri_csa32 csa3_1_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[239]),		//i--
      .b(ex4_pp2_2c[239]),		//i--
      .c(ex4_pp2_2s[239]),		//i--
      .sum(ex4_pp3_1s[239]),		//o--
      .car(ex4_pp3_1c[238])		//o--
   );


   tri_csa32 csa3_1_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[238]),		//i--
      .b(ex4_pp2_2c[238]),		//i--
      .c(ex4_pp2_2s[238]),		//i--
      .sum(ex4_pp3_1s[238]),		//o--
      .car(ex4_pp3_1c[237])		//o--
   );


   tri_csa32 csa3_1_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[237]),		//i--
      .b(ex4_pp2_2c[237]),		//i--
      .c(ex4_pp2_2s[237]),		//i--
      .sum(ex4_pp3_1s[237]),		//o--
      .car(ex4_pp3_1c[236])		//o--
   );


   tri_csa32 csa3_1_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[236]),		//i--
      .b(ex4_pp2_2c[236]),		//i--
      .c(ex4_pp2_2s[236]),		//i--
      .sum(ex4_pp3_1s[236]),		//o--
      .car(ex4_pp3_1c[235])		//o--
   );


   tri_csa32 csa3_1_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[235]),		//i--
      .b(ex4_pp2_2c[235]),		//i--
      .c(ex4_pp2_2s[235]),		//i--
      .sum(ex4_pp3_1s[235]),		//o--
      .car(ex4_pp3_1c[234])		//o--
   );


   tri_csa32 csa3_1_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[234]),		//i--
      .b(ex4_pp2_2c[234]),		//i--
      .c(ex4_pp2_2s[234]),		//i--
      .sum(ex4_pp3_1s[234]),		//o--
      .car(ex4_pp3_1c[233])		//o--
   );


   tri_csa32 csa3_1_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[233]),		//i--
      .b(ex4_pp2_2c[233]),		//i--
      .c(ex4_pp2_2s[233]),		//i--
      .sum(ex4_pp3_1s[233]),		//o--
      .car(ex4_pp3_1c[232])		//o--
   );


   tri_csa32 csa3_1_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[232]),		//i--
      .b(ex4_pp2_2c[232]),		//i--
      .c(ex4_pp2_2s[232]),		//i--
      .sum(ex4_pp3_1s[232]),		//o--
      .car(ex4_pp3_1c[231])		//o--
   );


   tri_csa32 csa3_1_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[231]),		//i--
      .b(ex4_pp2_2c[231]),		//i--
      .c(ex4_pp2_2s[231]),		//i--
      .sum(ex4_pp3_1s[231]),		//o--
      .car(ex4_pp3_1c[230])		//o--
   );


   tri_csa32 csa3_1_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[230]),		//i--
      .b(ex4_pp2_2c[230]),		//i--
      .c(ex4_pp2_2s[230]),		//i--
      .sum(ex4_pp3_1s[230]),		//o--
      .car(ex4_pp3_1c[229])		//o--
   );


   tri_csa32 csa3_1_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[229]),		//i--
      .b(ex4_pp2_2c[229]),		//i--
      .c(ex4_pp2_2s[229]),		//i--
      .sum(ex4_pp3_1s[229]),		//o--
      .car(ex4_pp3_1c[228])		//o--
   );


   tri_csa32 csa3_1_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[228]),		//i--
      .b(ex4_pp2_2c[228]),		//i--
      .c(ex4_pp2_2s[228]),		//i--
      .sum(ex4_pp3_1s[228]),		//o--
      .car(ex4_pp3_1c[227])		//o--
   );


   tri_csa32 csa3_1_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[227]),		//i--
      .b(ex4_pp2_2c[227]),		//i--
      .c(ex4_pp2_2s[227]),		//i--
      .sum(ex4_pp3_1s[227]),		//o--
      .car(ex4_pp3_1c[226])		//o--
   );


   tri_csa32 csa3_1_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[226]),		//i--
      .b(ex4_pp2_2c[226]),		//i--
      .c(ex4_pp2_2s[226]),		//i--
      .sum(ex4_pp3_1s[226]),		//o--
      .car(ex4_pp3_1c[225])		//o--
   );


   tri_csa32 csa3_1_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[225]),		//i--
      .b(ex4_pp2_2c[225]),		//i--
      .c(ex4_pp2_2s[225]),		//i--
      .sum(ex4_pp3_1s[225]),		//o--
      .car(ex4_pp3_1c[224])		//o--
   );


   tri_csa32 csa3_1_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[224]),		//i--
      .b(ex4_pp2_2c[224]),		//i--
      .c(ex4_pp2_2s[224]),		//i--
      .sum(ex4_pp3_1s[224]),		//o--
      .car(ex4_pp3_1c[223])		//o--
   );


   tri_csa32 csa3_1_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[223]),		//i--
      .b(ex4_pp2_2c[223]),		//i--
      .c(ex4_pp2_2s[223]),		//i--
      .sum(ex4_pp3_1s[223]),		//o--
      .car(ex4_pp3_1c[222])		//o--
   );


   tri_csa32 csa3_1_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[222]),		//i--
      .b(ex4_pp2_2c[222]),		//i--
      .c(ex4_pp2_2s[222]),		//i--
      .sum(ex4_pp3_1s[222]),		//o--
      .car(ex4_pp3_1c[221])		//o--
   );


   tri_csa32 csa3_1_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[221]),		//i--
      .b(ex4_pp2_2c[221]),		//i--
      .c(ex4_pp2_2s[221]),		//i--
      .sum(ex4_pp3_1s[221]),		//o--
      .car(ex4_pp3_1c[220])		//o--
   );


   tri_csa32 csa3_1_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp2_1s[220]),		//i--
      .b(ex4_pp2_2c[220]),		//i--
      .c(ex4_pp2_2s[220]),		//i--
      .sum(ex4_pp3_1s[220]),		//o--
      .car(ex4_pp3_1c[219])		//o--
   );
   assign ex4_pp3_1s[219] = ex4_pp2_1s[219];		//pass_x_s
   //ex4_pp3_1c(218)                  <= 0                             ; --pass_s
   assign ex4_pp3_1s[218] = ex4_pp2_1s[218];		//pass_s
   //ex4_pp3_1c(217)                  <= 0                             ; --pass_s
   assign ex4_pp3_1s[217] = ex4_pp2_1s[217];		//pass_s
   //ex4_pp3_1c(216)                  <= 0                             ; --pass_s
   assign ex4_pp3_1s[216] = ex4_pp2_1s[216];		//pass_s
   //ex4_pp3_1c(215)                  <= 0                             ; --pass_s
   assign ex4_pp3_1s[215] = ex4_pp2_1s[215];		//pass_s
   //ex4_pp3_1c(214)                  <= 0                             ; --pass_s
   assign ex4_pp3_1s[214] = ex4_pp2_1s[214];		//pass_s
   //ex4_pp3_1c(213)                  <= 0                             ; --pass_s
   assign ex4_pp3_1s[213] = ex4_pp2_1s[213];		//pass_s
   //ex4_pp3_1c(212)                  <= 0                             ; --pass_s
   assign ex4_pp3_1s[212] = ex4_pp2_1s[212];		//pass_s
   //ex4_pp3_1c(211)                  <= 0                             ; --pass_s
   assign ex4_pp3_1s[211] = ex4_pp2_1s[211];		//pass_s
   //ex4_pp3_1c(210)                  <= 0                             ; --pass_s
   assign ex4_pp3_1s[210] = ex4_pp2_1s[210];		//pass_s
   //ex4_pp3_1c(209)                  <= 0                             ; --pass_s
   assign ex4_pp3_1s[209] = ex4_pp2_1s[209];		//pass_s
   assign ex4_pp3_1s[208] = ex4_pp2_1s[208];		//pass_s

   //***********************************
   //** compression level 4
   //***********************************

   //    g4 : for i in 196 to 264 generate
   //        csa4_0: entity c_prism_csa42  port map(
   //            a    => ex4_pp3_0s(i)                          ,--i--
   //            b    => ex4_pp3_0c(i)                          ,--i--
   //            c    => ex4_pp3_1s(i)                          ,--i--
   //            d    => ex4_pp3_1c(i)                          ,--i--
   //            ki   => ex4_pp4_0k(i)                          ,--i--
   //            ko   => ex4_pp4_0k(i - 1)                      ,--o--
   //            sum  => ex4_pp4_0s(i)                          ,--o--
   //            car  => ex4_pp4_0c(i - 1)                     );--o--
   //    end generate;
   //       ex4_pp4_0k(264) <= 0 ;
   //       ex4_pp4_0c(264) <= 0 ;

   //----- <csa4_0> -----

   assign ex4_pp4_0s[264] = ex4_pp3_1s[264];		//pass_s
   assign ex4_pp4_0s[263] = ex4_pp3_1s[263];		//pass_s
   assign ex4_pp4_0c[262] = ex4_pp3_1s[262];		//pass_cs
   assign ex4_pp4_0s[262] = ex4_pp3_1c[262];		//pass_cs
   assign ex4_pp4_0c[261] = ex4_pp3_1s[261];		//pass_cs
   assign ex4_pp4_0s[261] = ex4_pp3_1c[261];		//pass_cs
   assign ex4_pp4_0c[260] = 0;		//pass_s
   assign ex4_pp4_0s[260] = ex4_pp3_1s[260];		//pass_s
   assign ex4_pp4_0c[259] = ex4_pp3_1s[259];		//pass_cs
   assign ex4_pp4_0s[259] = ex4_pp3_1c[259];		//pass_cs
   assign ex4_pp4_0c[258] = ex4_pp3_1s[258];		//pass_cs
   assign ex4_pp4_0s[258] = ex4_pp3_1c[258];		//pass_cs
   assign ex4_pp4_0c[257] = ex4_pp3_1s[257];		//pass_cs
   assign ex4_pp4_0s[257] = ex4_pp3_1c[257];		//pass_cs
   assign ex4_pp4_0c[256] = ex4_pp3_1s[256];		//pass_cs
   assign ex4_pp4_0s[256] = ex4_pp3_1c[256];		//pass_cs
   assign ex4_pp4_0c[255] = ex4_pp3_1s[255];		//pass_cs
   assign ex4_pp4_0s[255] = ex4_pp3_1c[255];		//pass_cs
   assign ex4_pp4_0c[254] = 0;		//pass_s
   assign ex4_pp4_0s[254] = ex4_pp3_1s[254];		//pass_s
   assign ex4_pp4_0c[253] = ex4_pp3_1s[253];		//pass_cs
   assign ex4_pp4_0s[253] = ex4_pp3_1c[253];		//pass_cs
   assign ex4_pp4_0c[252] = 0;		//wr_csa32


   tri_csa32 csa4_0_252(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[252]),		//i--
      .b(ex4_pp3_1c[252]),		//i--
      .c(ex4_pp3_1s[252]),		//i--
      .sum(ex4_pp4_0s[252]),		//o--
      .car(ex4_pp4_0c[251])		//o--
   );

   tri_csa22 csa4_0_251(
      .a(ex4_pp3_1c[251]),		//i--
      .b(ex4_pp3_1s[251]),		//i--
      .sum(ex4_pp4_0s[251]),		//o--
      .car(ex4_pp4_0c[250])		//o--
   );

   tri_csa22 csa4_0_250(
      .a(ex4_pp3_1c[250]),		//i--
      .b(ex4_pp3_1s[250]),		//i--
      .sum(ex4_pp4_0s[250]),		//o--
      .car(ex4_pp4_0c[249])		//o--
   );


   tri_csa32 csa4_0_249(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[249]),		//i--
      .b(ex4_pp3_1c[249]),		//i--
      .c(ex4_pp3_1s[249]),		//i--
      .sum(ex4_pp4_0s[249]),		//o--
      .car(ex4_pp4_0c[248])		//o--
   );

   tri_csa22 csa4_0_248(
      .a(ex4_pp3_1c[248]),		//i--
      .b(ex4_pp3_1s[248]),		//i--
      .sum(ex4_pp4_0s[248]),		//o--
      .car(ex4_pp4_0c[247])		//o--
   );


   tri_csa32 csa4_0_247(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[247]),		//i--
      .b(ex4_pp3_1c[247]),		//i--
      .c(ex4_pp3_1s[247]),		//i--
      .sum(ex4_pp4_0s[247]),		//o--
      .car(ex4_pp4_0c[246])		//o--
   );


   tri_csa32 csa4_0_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[246]),		//i--
      .b(ex4_pp3_1c[246]),		//i--
      .c(ex4_pp3_1s[246]),		//i--
      .sum(ex4_pp4_0s[246]),		//o--
      .car(ex4_pp4_0c[245])		//o--
   );


   tri_csa32 csa4_0_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[245]),		//i--
      .b(ex4_pp3_1c[245]),		//i--
      .c(ex4_pp3_1s[245]),		//i--
      .sum(ex4_pp4_0s[245]),		//o--
      .car(ex4_pp4_0c[244])		//o--
   );


   tri_csa32 csa4_0_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[244]),		//i--
      .b(ex4_pp3_1c[244]),		//i--
      .c(ex4_pp3_1s[244]),		//i--
      .sum(ex4_pp4_0s[244]),		//o--
      .car(ex4_pp4_0c[243])		//o--
   );


   tri_csa32 csa4_0_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[243]),		//i--
      .b(ex4_pp3_1c[243]),		//i--
      .c(ex4_pp3_1s[243]),		//i--
      .sum(ex4_pp4_0s[243]),		//o--
      .car(ex4_pp4_0c[242])		//o--
   );
   assign ex4_pp4_0k[242] = 0;		//start_k


   tri_csa42 csa4_0_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[242]),		//i--
      .b(ex4_pp3_0s[242]),		//i--
      .c(ex4_pp3_1c[242]),		//i--
      .d(ex4_pp3_1s[242]),		//i--
      .ki(ex4_pp4_0k[242]),		//i--
      .ko(ex4_pp4_0k[241]),		//o--
      .sum(ex4_pp4_0s[242]),		//o--
      .car(ex4_pp4_0c[241])		//o--
   );


   tri_csa42 csa4_0_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[241]),		//i--
      .b(ex4_pp3_1c[241]),		//i--
      .c(ex4_pp3_1s[241]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp4_0k[241]),		//i--
      .ko(ex4_pp4_0k[240]),		//o--
      .sum(ex4_pp4_0s[241]),		//o--
      .car(ex4_pp4_0c[240])		//o--
   );


   tri_csa42 csa4_0_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0s[240]),		//i--
      .b(ex4_pp3_1c[240]),		//i--
      .c(ex4_pp3_1s[240]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp4_0k[240]),		//i--
      .ko(ex4_pp4_0k[239]),		//o--
      .sum(ex4_pp4_0s[240]),		//o--
      .car(ex4_pp4_0c[239])		//o--
   );


   tri_csa42 csa4_0_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[239]),		//i--
      .b(ex4_pp3_0s[239]),		//i--
      .c(ex4_pp3_1c[239]),		//i--
      .d(ex4_pp3_1s[239]),		//i--
      .ki(ex4_pp4_0k[239]),		//i--
      .ko(ex4_pp4_0k[238]),		//o--
      .sum(ex4_pp4_0s[239]),		//o--
      .car(ex4_pp4_0c[238])		//o--
   );


   tri_csa42 csa4_0_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[238]),		//i--
      .b(ex4_pp3_0s[238]),		//i--
      .c(ex4_pp3_1c[238]),		//i--
      .d(ex4_pp3_1s[238]),		//i--
      .ki(ex4_pp4_0k[238]),		//i--
      .ko(ex4_pp4_0k[237]),		//o--
      .sum(ex4_pp4_0s[238]),		//o--
      .car(ex4_pp4_0c[237])		//o--
   );


   tri_csa42 csa4_0_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[237]),		//i--
      .b(ex4_pp3_0s[237]),		//i--
      .c(ex4_pp3_1c[237]),		//i--
      .d(ex4_pp3_1s[237]),		//i--
      .ki(ex4_pp4_0k[237]),		//i--
      .ko(ex4_pp4_0k[236]),		//o--
      .sum(ex4_pp4_0s[237]),		//o--
      .car(ex4_pp4_0c[236])		//o--
   );


   tri_csa42 csa4_0_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[236]),		//i--
      .b(ex4_pp3_0s[236]),		//i--
      .c(ex4_pp3_1c[236]),		//i--
      .d(ex4_pp3_1s[236]),		//i--
      .ki(ex4_pp4_0k[236]),		//i--
      .ko(ex4_pp4_0k[235]),		//o--
      .sum(ex4_pp4_0s[236]),		//o--
      .car(ex4_pp4_0c[235])		//o--
   );


   tri_csa42 csa4_0_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[235]),		//i--
      .b(ex4_pp3_0s[235]),		//i--
      .c(ex4_pp3_1c[235]),		//i--
      .d(ex4_pp3_1s[235]),		//i--
      .ki(ex4_pp4_0k[235]),		//i--
      .ko(ex4_pp4_0k[234]),		//o--
      .sum(ex4_pp4_0s[235]),		//o--
      .car(ex4_pp4_0c[234])		//o--
   );


   tri_csa42 csa4_0_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[234]),		//i--
      .b(ex4_pp3_0s[234]),		//i--
      .c(ex4_pp3_1c[234]),		//i--
      .d(ex4_pp3_1s[234]),		//i--
      .ki(ex4_pp4_0k[234]),		//i--
      .ko(ex4_pp4_0k[233]),		//o--
      .sum(ex4_pp4_0s[234]),		//o--
      .car(ex4_pp4_0c[233])		//o--
   );


   tri_csa42 csa4_0_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[233]),		//i--
      .b(ex4_pp3_0s[233]),		//i--
      .c(ex4_pp3_1c[233]),		//i--
      .d(ex4_pp3_1s[233]),		//i--
      .ki(ex4_pp4_0k[233]),		//i--
      .ko(ex4_pp4_0k[232]),		//o--
      .sum(ex4_pp4_0s[233]),		//o--
      .car(ex4_pp4_0c[232])		//o--
   );


   tri_csa42 csa4_0_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[232]),		//i--
      .b(ex4_pp3_0s[232]),		//i--
      .c(ex4_pp3_1c[232]),		//i--
      .d(ex4_pp3_1s[232]),		//i--
      .ki(ex4_pp4_0k[232]),		//i--
      .ko(ex4_pp4_0k[231]),		//o--
      .sum(ex4_pp4_0s[232]),		//o--
      .car(ex4_pp4_0c[231])		//o--
   );


   tri_csa42 csa4_0_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[231]),		//i--
      .b(ex4_pp3_0s[231]),		//i--
      .c(ex4_pp3_1c[231]),		//i--
      .d(ex4_pp3_1s[231]),		//i--
      .ki(ex4_pp4_0k[231]),		//i--
      .ko(ex4_pp4_0k[230]),		//o--
      .sum(ex4_pp4_0s[231]),		//o--
      .car(ex4_pp4_0c[230])		//o--
   );


   tri_csa42 csa4_0_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[230]),		//i--
      .b(ex4_pp3_0s[230]),		//i--
      .c(ex4_pp3_1c[230]),		//i--
      .d(ex4_pp3_1s[230]),		//i--
      .ki(ex4_pp4_0k[230]),		//i--
      .ko(ex4_pp4_0k[229]),		//o--
      .sum(ex4_pp4_0s[230]),		//o--
      .car(ex4_pp4_0c[229])		//o--
   );


   tri_csa42 csa4_0_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[229]),		//i--
      .b(ex4_pp3_0s[229]),		//i--
      .c(ex4_pp3_1c[229]),		//i--
      .d(ex4_pp3_1s[229]),		//i--
      .ki(ex4_pp4_0k[229]),		//i--
      .ko(ex4_pp4_0k[228]),		//o--
      .sum(ex4_pp4_0s[229]),		//o--
      .car(ex4_pp4_0c[228])		//o--
   );


   tri_csa42 csa4_0_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[228]),		//i--
      .b(ex4_pp3_0s[228]),		//i--
      .c(ex4_pp3_1c[228]),		//i--
      .d(ex4_pp3_1s[228]),		//i--
      .ki(ex4_pp4_0k[228]),		//i--
      .ko(ex4_pp4_0k[227]),		//o--
      .sum(ex4_pp4_0s[228]),		//o--
      .car(ex4_pp4_0c[227])		//o--
   );


   tri_csa42 csa4_0_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[227]),		//i--
      .b(ex4_pp3_0s[227]),		//i--
      .c(ex4_pp3_1c[227]),		//i--
      .d(ex4_pp3_1s[227]),		//i--
      .ki(ex4_pp4_0k[227]),		//i--
      .ko(ex4_pp4_0k[226]),		//o--
      .sum(ex4_pp4_0s[227]),		//o--
      .car(ex4_pp4_0c[226])		//o--
   );


   tri_csa42 csa4_0_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[226]),		//i--
      .b(ex4_pp3_0s[226]),		//i--
      .c(ex4_pp3_1c[226]),		//i--
      .d(ex4_pp3_1s[226]),		//i--
      .ki(ex4_pp4_0k[226]),		//i--
      .ko(ex4_pp4_0k[225]),		//o--
      .sum(ex4_pp4_0s[226]),		//o--
      .car(ex4_pp4_0c[225])		//o--
   );


   tri_csa42 csa4_0_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[225]),		//i--
      .b(ex4_pp3_0s[225]),		//i--
      .c(ex4_pp3_1c[225]),		//i--
      .d(ex4_pp3_1s[225]),		//i--
      .ki(ex4_pp4_0k[225]),		//i--
      .ko(ex4_pp4_0k[224]),		//o--
      .sum(ex4_pp4_0s[225]),		//o--
      .car(ex4_pp4_0c[224])		//o--
   );


   tri_csa42 csa4_0_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[224]),		//i--
      .b(ex4_pp3_0s[224]),		//i--
      .c(ex4_pp3_1c[224]),		//i--
      .d(ex4_pp3_1s[224]),		//i--
      .ki(ex4_pp4_0k[224]),		//i--
      .ko(ex4_pp4_0k[223]),		//o--
      .sum(ex4_pp4_0s[224]),		//o--
      .car(ex4_pp4_0c[223])		//o--
   );


   tri_csa42 csa4_0_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[223]),		//i--
      .b(ex4_pp3_0s[223]),		//i--
      .c(ex4_pp3_1c[223]),		//i--
      .d(ex4_pp3_1s[223]),		//i--
      .ki(ex4_pp4_0k[223]),		//i--
      .ko(ex4_pp4_0k[222]),		//o--
      .sum(ex4_pp4_0s[223]),		//o--
      .car(ex4_pp4_0c[222])		//o--
   );


   tri_csa42 csa4_0_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[222]),		//i--
      .b(ex4_pp3_0s[222]),		//i--
      .c(ex4_pp3_1c[222]),		//i--
      .d(ex4_pp3_1s[222]),		//i--
      .ki(ex4_pp4_0k[222]),		//i--
      .ko(ex4_pp4_0k[221]),		//o--
      .sum(ex4_pp4_0s[222]),		//o--
      .car(ex4_pp4_0c[221])		//o--
   );


   tri_csa42 csa4_0_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[221]),		//i--
      .b(ex4_pp3_0s[221]),		//i--
      .c(ex4_pp3_1c[221]),		//i--
      .d(ex4_pp3_1s[221]),		//i--
      .ki(ex4_pp4_0k[221]),		//i--
      .ko(ex4_pp4_0k[220]),		//o--
      .sum(ex4_pp4_0s[221]),		//o--
      .car(ex4_pp4_0c[220])		//o--
   );


   tri_csa42 csa4_0_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[220]),		//i--
      .b(ex4_pp3_0s[220]),		//i--
      .c(ex4_pp3_1c[220]),		//i--
      .d(ex4_pp3_1s[220]),		//i--
      .ki(ex4_pp4_0k[220]),		//i--
      .ko(ex4_pp4_0k[219]),		//o--
      .sum(ex4_pp4_0s[220]),		//o--
      .car(ex4_pp4_0c[219])		//o--
   );


   tri_csa42 csa4_0_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[219]),		//i--
      .b(ex4_pp3_0s[219]),		//i--
      .c(ex4_pp3_1c[219]),		//i--
      .d(ex4_pp3_1s[219]),		//i--
      .ki(ex4_pp4_0k[219]),		//i--
      .ko(ex4_pp4_0k[218]),		//o--
      .sum(ex4_pp4_0s[219]),		//o--
      .car(ex4_pp4_0c[218])		//o--
   );


   tri_csa42 csa4_0_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[218]),		//i--
      .b(ex4_pp3_0s[218]),		//i--
      .c(ex4_pp3_1s[218]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp4_0k[218]),		//i--
      .ko(ex4_pp4_0k[217]),		//o--
      .sum(ex4_pp4_0s[218]),		//o--
      .car(ex4_pp4_0c[217])		//o--
   );


   tri_csa42 csa4_0_217(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[217]),		//i--
      .b(ex4_pp3_0s[217]),		//i--
      .c(ex4_pp3_1s[217]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp4_0k[217]),		//i--
      .ko(ex4_pp4_0k[216]),		//o--
      .sum(ex4_pp4_0s[217]),		//o--
      .car(ex4_pp4_0c[216])		//o--
   );


   tri_csa42 csa4_0_216(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[216]),		//i--
      .b(ex4_pp3_0s[216]),		//i--
      .c(ex4_pp3_1s[216]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp4_0k[216]),		//i--
      .ko(ex4_pp4_0k[215]),		//o--
      .sum(ex4_pp4_0s[216]),		//o--
      .car(ex4_pp4_0c[215])		//o--
   );


   tri_csa42 csa4_0_215(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[215]),		//i--
      .b(ex4_pp3_0s[215]),		//i--
      .c(ex4_pp3_1s[215]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp4_0k[215]),		//i--
      .ko(ex4_pp4_0k[214]),		//o--
      .sum(ex4_pp4_0s[215]),		//o--
      .car(ex4_pp4_0c[214])		//o--
   );


   tri_csa42 csa4_0_214(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[214]),		//i--
      .b(ex4_pp3_0s[214]),		//i--
      .c(ex4_pp3_1s[214]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp4_0k[214]),		//i--
      .ko(ex4_pp4_0k[213]),		//o--
      .sum(ex4_pp4_0s[214]),		//o--
      .car(ex4_pp4_0c[213])		//o--
   );


   tri_csa42 csa4_0_213(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[213]),		//i--
      .b(ex4_pp3_0s[213]),		//i--
      .c(ex4_pp3_1s[213]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp4_0k[213]),		//i--
      .ko(ex4_pp4_0k[212]),		//o--
      .sum(ex4_pp4_0s[213]),		//o--
      .car(ex4_pp4_0c[212])		//o--
   );


   tri_csa42 csa4_0_212(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[212]),		//i--
      .b(ex4_pp3_0s[212]),		//i--
      .c(ex4_pp3_1s[212]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp4_0k[212]),		//i--
      .ko(ex4_pp4_0k[211]),		//o--
      .sum(ex4_pp4_0s[212]),		//o--
      .car(ex4_pp4_0c[211])		//o--
   );


   tri_csa42 csa4_0_211(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[211]),		//i--
      .b(ex4_pp3_0s[211]),		//i--
      .c(ex4_pp3_1s[211]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp4_0k[211]),		//i--
      .ko(ex4_pp4_0k[210]),		//o--
      .sum(ex4_pp4_0s[211]),		//o--
      .car(ex4_pp4_0c[210])		//o--
   );


   tri_csa42 csa4_0_210(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[210]),		//i--
      .b(ex4_pp3_0s[210]),		//i--
      .c(ex4_pp3_1s[210]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp4_0k[210]),		//i--
      .ko(ex4_pp4_0k[209]),		//o--
      .sum(ex4_pp4_0s[210]),		//o--
      .car(ex4_pp4_0c[209])		//o--
   );


   tri_csa42 csa4_0_209(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[209]),		//i--
      .b(ex4_pp3_0s[209]),		//i--
      .c(ex4_pp3_1s[209]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp4_0k[209]),		//i--
      .ko(ex4_pp4_0k[208]),		//o--
      .sum(ex4_pp4_0s[209]),		//o--
      .car(ex4_pp4_0c[208])		//o--
   );


   tri_csa42 csa4_0_208(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[208]),		//i--
      .b(ex4_pp3_0s[208]),		//i--
      .c(ex4_pp3_1s[208]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp4_0k[208]),		//i--
      .ko(ex4_pp4_0k[207]),		//o--
      .sum(ex4_pp4_0s[208]),		//o--
      .car(ex4_pp4_0c[207])		//o--
   );


   tri_csa32 csa4_0_207(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp3_0c[207]),		//i--
      .b(ex4_pp3_0s[207]),		//i--
      .c(ex4_pp4_0k[207]),		//i--
      .sum(ex4_pp4_0s[207]),		//o--
      .car(ex4_pp4_0c[206])		//o--
   );

   tri_csa22 csa4_0_206(
      .a(ex4_pp3_0c[206]),		//i--
      .b(ex4_pp3_0s[206]),		//i--
      .sum(ex4_pp4_0s[206]),		//o--
      .car(ex4_pp4_0c[205])		//o--
   );

   tri_csa22 csa4_0_205(
      .a(ex4_pp3_0c[205]),		//i--
      .b(ex4_pp3_0s[205]),		//i--
      .sum(ex4_pp4_0s[205]),		//o--
      .car(ex4_pp4_0c[204])		//o--
   );

   tri_csa22 csa4_0_204(
      .a(ex4_pp3_0c[204]),		//i--
      .b(ex4_pp3_0s[204]),		//i--
      .sum(ex4_pp4_0s[204]),		//o--
      .car(ex4_pp4_0c[203])		//o--
   );

   tri_csa22 csa4_0_203(
      .a(ex4_pp3_0c[203]),		//i--
      .b(ex4_pp3_0s[203]),		//i--
      .sum(ex4_pp4_0s[203]),		//o--
      .car(ex4_pp4_0c[202])		//o--
   );

   tri_csa22 csa4_0_202(
      .a(ex4_pp3_0c[202]),		//i--
      .b(ex4_pp3_0s[202]),		//i--
      .sum(ex4_pp4_0s[202]),		//o--
      .car(ex4_pp4_0c[201])		//o--
   );

   tri_csa22 csa4_0_201(
      .a(ex4_pp3_0c[201]),		//i--
      .b(ex4_pp3_0s[201]),		//i--
      .sum(ex4_pp4_0s[201]),		//o--
      .car(ex4_pp4_0c[200])		//o--
   );

   tri_csa22 csa4_0_200(
      .a(ex4_pp3_0c[200]),		//i--
      .b(ex4_pp3_0s[200]),		//i--
      .sum(ex4_pp4_0s[200]),		//o--
      .car(ex4_pp4_0c[199])		//o--
   );

   tri_csa22 csa4_0_199(
      .a(ex4_pp3_0c[199]),		//i--
      .b(ex4_pp3_0s[199]),		//i--
      .sum(ex4_pp4_0s[199]),		//o--
      .car(ex4_pp4_0c[198])		//o--
   );

   tri_csa22 csa4_0_198(
      .a(ex4_pp3_0c[198]),		//i--
      .b(ex4_pp3_0s[198]),		//i--
      .sum(ex4_pp4_0s[198]),		//o--
      .car(ex4_pp4_0c[197])		//o--
   );
   assign ex4_pp4_0s[197] = ex4_pp3_0c[197];		//pass_x_s

   //***********************************
   //** compression recycle
   //***********************************

   //    g5 : for i in 196 to 264 generate
   //
   //        csa5_0: entity c_prism_csa42  port map(
   //            a    => ex4_pp4_0s(i)                          ,--i--
   //            b    => ex4_pp4_0c(i)                          ,--i--
   //            c    => ex4_recycle_s(i)                       ,--i--
   //            d    => ex4_recycle_c(i)                       ,--i--
   //            ki   => ex4_pp5_0k(i)                          ,--i--
   //            ko   => ex4_pp5_0k(i - 1)                      ,--o--
   //            sum  => ex4_pp5_0s(i)                          ,--o--
   //            car  => ex4_pp5_0c(i - 1)                     );--o--
   //
   //    end generate;
   //
   //       ex4_pp5_0k(264) <= 0 ;
   //       ex4_pp5_0c(264) <= 0 ;

   //----- <csa5_0> -----


   tri_csa22 csa5_0_264(
      .a(ex4_pp4_0s[264]),		//i--
      .b(ex4_recycle_s[264]),		//i--
      .sum(ex4_pp5_0s[264]),		//o--
      .car(ex4_pp5_0c[263])		//o--
   );


   tri_csa32 csa5_0_263(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0s[263]),		//i--
      .b(ex4_recycle_c[263]),		//i--
      .c(ex4_recycle_s[263]),		//i--
      .sum(ex4_pp5_0s[263]),		//o--
      .car(ex4_pp5_0c[262])		//o--
   );
   assign ex4_pp5_0k[262] = 0;		//start_k


   tri_csa42 csa5_0_262(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[262]),		//i--
      .b(ex4_pp4_0s[262]),		//i--
      .c(ex4_recycle_c[262]),		//i--
      .d(ex4_recycle_s[262]),		//i--
      .ki(ex4_pp5_0k[262]),		//i--
      .ko(ex4_pp5_0k[261]),		//o--
      .sum(ex4_pp5_0s[262]),		//o--
      .car(ex4_pp5_0c[261])		//o--
   );


   tri_csa42 csa5_0_261(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[261]),		//i--
      .b(ex4_pp4_0s[261]),		//i--
      .c(ex4_recycle_c[261]),		//i--
      .d(ex4_recycle_s[261]),		//i--
      .ki(ex4_pp5_0k[261]),		//i--
      .ko(ex4_pp5_0k[260]),		//o--
      .sum(ex4_pp5_0s[261]),		//o--
      .car(ex4_pp5_0c[260])		//o--
   );


   tri_csa42 csa5_0_260(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0s[260]),		//i--
      .b(ex4_recycle_c[260]),		//i--
      .c(ex4_recycle_s[260]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp5_0k[260]),		//i--
      .ko(ex4_pp5_0k[259]),		//o--
      .sum(ex4_pp5_0s[260]),		//o--
      .car(ex4_pp5_0c[259])		//o--
   );


   tri_csa42 csa5_0_259(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[259]),		//i--
      .b(ex4_pp4_0s[259]),		//i--
      .c(ex4_recycle_c[259]),		//i--
      .d(ex4_recycle_s[259]),		//i--
      .ki(ex4_pp5_0k[259]),		//i--
      .ko(ex4_pp5_0k[258]),		//o--
      .sum(ex4_pp5_0s[259]),		//o--
      .car(ex4_pp5_0c[258])		//o--
   );


   tri_csa42 csa5_0_258(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[258]),		//i--
      .b(ex4_pp4_0s[258]),		//i--
      .c(ex4_recycle_c[258]),		//i--
      .d(ex4_recycle_s[258]),		//i--
      .ki(ex4_pp5_0k[258]),		//i--
      .ko(ex4_pp5_0k[257]),		//o--
      .sum(ex4_pp5_0s[258]),		//o--
      .car(ex4_pp5_0c[257])		//o--
   );


   tri_csa42 csa5_0_257(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[257]),		//i--
      .b(ex4_pp4_0s[257]),		//i--
      .c(ex4_recycle_c[257]),		//i--
      .d(ex4_recycle_s[257]),		//i--
      .ki(ex4_pp5_0k[257]),		//i--
      .ko(ex4_pp5_0k[256]),		//o--
      .sum(ex4_pp5_0s[257]),		//o--
      .car(ex4_pp5_0c[256])		//o--
   );


   tri_csa42 csa5_0_256(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[256]),		//i--
      .b(ex4_pp4_0s[256]),		//i--
      .c(ex4_recycle_c[256]),		//i--
      .d(ex4_recycle_s[256]),		//i--
      .ki(ex4_pp5_0k[256]),		//i--
      .ko(ex4_pp5_0k[255]),		//o--
      .sum(ex4_pp5_0s[256]),		//o--
      .car(ex4_pp5_0c[255])		//o--
   );


   tri_csa42 csa5_0_255(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[255]),		//i--
      .b(ex4_pp4_0s[255]),		//i--
      .c(ex4_recycle_c[255]),		//i--
      .d(ex4_recycle_s[255]),		//i--
      .ki(ex4_pp5_0k[255]),		//i--
      .ko(ex4_pp5_0k[254]),		//o--
      .sum(ex4_pp5_0s[255]),		//o--
      .car(ex4_pp5_0c[254])		//o--
   );


   tri_csa42 csa5_0_254(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0s[254]),		//i--
      .b(ex4_recycle_c[254]),		//i--
      .c(ex4_recycle_s[254]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp5_0k[254]),		//i--
      .ko(ex4_pp5_0k[253]),		//o--
      .sum(ex4_pp5_0s[254]),		//o--
      .car(ex4_pp5_0c[253])		//o--
   );


   tri_csa42 csa5_0_253(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[253]),		//i--
      .b(ex4_pp4_0s[253]),		//i--
      .c(ex4_recycle_c[253]),		//i--
      .d(ex4_recycle_s[253]),		//i--
      .ki(ex4_pp5_0k[253]),		//i--
      .ko(ex4_pp5_0k[252]),		//o--
      .sum(ex4_pp5_0s[253]),		//o--
      .car(ex4_pp5_0c[252])		//o--
   );


   tri_csa42 csa5_0_252(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0s[252]),		//i--
      .b(ex4_recycle_c[252]),		//i--
      .c(ex4_recycle_s[252]),		//i--
      .d(1'b0),		//i--
      .ki(ex4_pp5_0k[252]),		//i--
      .ko(ex4_pp5_0k[251]),		//o--
      .sum(ex4_pp5_0s[252]),		//o--
      .car(ex4_pp5_0c[251])		//o--
   );


   tri_csa42 csa5_0_251(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[251]),		//i--
      .b(ex4_pp4_0s[251]),		//i--
      .c(ex4_recycle_c[251]),		//i--
      .d(ex4_recycle_s[251]),		//i--
      .ki(ex4_pp5_0k[251]),		//i--
      .ko(ex4_pp5_0k[250]),		//o--
      .sum(ex4_pp5_0s[251]),		//o--
      .car(ex4_pp5_0c[250])		//o--
   );


   tri_csa42 csa5_0_250(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[250]),		//i--
      .b(ex4_pp4_0s[250]),		//i--
      .c(ex4_recycle_c[250]),		//i--
      .d(ex4_recycle_s[250]),		//i--
      .ki(ex4_pp5_0k[250]),		//i--
      .ko(ex4_pp5_0k[249]),		//o--
      .sum(ex4_pp5_0s[250]),		//o--
      .car(ex4_pp5_0c[249])		//o--
   );


   tri_csa42 csa5_0_249(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[249]),		//i--
      .b(ex4_pp4_0s[249]),		//i--
      .c(ex4_recycle_c[249]),		//i--
      .d(ex4_recycle_s[249]),		//i--
      .ki(ex4_pp5_0k[249]),		//i--
      .ko(ex4_pp5_0k[248]),		//o--
      .sum(ex4_pp5_0s[249]),		//o--
      .car(ex4_pp5_0c[248])		//o--
   );


   tri_csa42 csa5_0_248(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[248]),		//i--
      .b(ex4_pp4_0s[248]),		//i--
      .c(ex4_recycle_c[248]),		//i--
      .d(ex4_recycle_s[248]),		//i--
      .ki(ex4_pp5_0k[248]),		//i--
      .ko(ex4_pp5_0k[247]),		//o--
      .sum(ex4_pp5_0s[248]),		//o--
      .car(ex4_pp5_0c[247])		//o--
   );


   tri_csa42 csa5_0_247(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[247]),		//i--
      .b(ex4_pp4_0s[247]),		//i--
      .c(ex4_recycle_c[247]),		//i--
      .d(ex4_recycle_s[247]),		//i--
      .ki(ex4_pp5_0k[247]),		//i--
      .ko(ex4_pp5_0k[246]),		//o--
      .sum(ex4_pp5_0s[247]),		//o--
      .car(ex4_pp5_0c[246])		//o--
   );


   tri_csa42 csa5_0_246(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[246]),		//i--
      .b(ex4_pp4_0s[246]),		//i--
      .c(ex4_recycle_c[246]),		//i--
      .d(ex4_recycle_s[246]),		//i--
      .ki(ex4_pp5_0k[246]),		//i--
      .ko(ex4_pp5_0k[245]),		//o--
      .sum(ex4_pp5_0s[246]),		//o--
      .car(ex4_pp5_0c[245])		//o--
   );


   tri_csa42 csa5_0_245(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[245]),		//i--
      .b(ex4_pp4_0s[245]),		//i--
      .c(ex4_recycle_c[245]),		//i--
      .d(ex4_recycle_s[245]),		//i--
      .ki(ex4_pp5_0k[245]),		//i--
      .ko(ex4_pp5_0k[244]),		//o--
      .sum(ex4_pp5_0s[245]),		//o--
      .car(ex4_pp5_0c[244])		//o--
   );


   tri_csa42 csa5_0_244(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[244]),		//i--
      .b(ex4_pp4_0s[244]),		//i--
      .c(ex4_recycle_c[244]),		//i--
      .d(ex4_recycle_s[244]),		//i--
      .ki(ex4_pp5_0k[244]),		//i--
      .ko(ex4_pp5_0k[243]),		//o--
      .sum(ex4_pp5_0s[244]),		//o--
      .car(ex4_pp5_0c[243])		//o--
   );


   tri_csa42 csa5_0_243(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[243]),		//i--
      .b(ex4_pp4_0s[243]),		//i--
      .c(ex4_recycle_c[243]),		//i--
      .d(ex4_recycle_s[243]),		//i--
      .ki(ex4_pp5_0k[243]),		//i--
      .ko(ex4_pp5_0k[242]),		//o--
      .sum(ex4_pp5_0s[243]),		//o--
      .car(ex4_pp5_0c[242])		//o--
   );


   tri_csa42 csa5_0_242(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[242]),		//i--
      .b(ex4_pp4_0s[242]),		//i--
      .c(ex4_recycle_c[242]),		//i--
      .d(ex4_recycle_s[242]),		//i--
      .ki(ex4_pp5_0k[242]),		//i--
      .ko(ex4_pp5_0k[241]),		//o--
      .sum(ex4_pp5_0s[242]),		//o--
      .car(ex4_pp5_0c[241])		//o--
   );


   tri_csa42 csa5_0_241(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[241]),		//i--
      .b(ex4_pp4_0s[241]),		//i--
      .c(ex4_recycle_c[241]),		//i--
      .d(ex4_recycle_s[241]),		//i--
      .ki(ex4_pp5_0k[241]),		//i--
      .ko(ex4_pp5_0k[240]),		//o--
      .sum(ex4_pp5_0s[241]),		//o--
      .car(ex4_pp5_0c[240])		//o--
   );


   tri_csa42 csa5_0_240(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[240]),		//i--
      .b(ex4_pp4_0s[240]),		//i--
      .c(ex4_recycle_c[240]),		//i--
      .d(ex4_recycle_s[240]),		//i--
      .ki(ex4_pp5_0k[240]),		//i--
      .ko(ex4_pp5_0k[239]),		//o--
      .sum(ex4_pp5_0s[240]),		//o--
      .car(ex4_pp5_0c[239])		//o--
   );


   tri_csa42 csa5_0_239(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[239]),		//i--
      .b(ex4_pp4_0s[239]),		//i--
      .c(ex4_recycle_c[239]),		//i--
      .d(ex4_recycle_s[239]),		//i--
      .ki(ex4_pp5_0k[239]),		//i--
      .ko(ex4_pp5_0k[238]),		//o--
      .sum(ex4_pp5_0s[239]),		//o--
      .car(ex4_pp5_0c[238])		//o--
   );


   tri_csa42 csa5_0_238(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[238]),		//i--
      .b(ex4_pp4_0s[238]),		//i--
      .c(ex4_recycle_c[238]),		//i--
      .d(ex4_recycle_s[238]),		//i--
      .ki(ex4_pp5_0k[238]),		//i--
      .ko(ex4_pp5_0k[237]),		//o--
      .sum(ex4_pp5_0s[238]),		//o--
      .car(ex4_pp5_0c[237])		//o--
   );


   tri_csa42 csa5_0_237(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[237]),		//i--
      .b(ex4_pp4_0s[237]),		//i--
      .c(ex4_recycle_c[237]),		//i--
      .d(ex4_recycle_s[237]),		//i--
      .ki(ex4_pp5_0k[237]),		//i--
      .ko(ex4_pp5_0k[236]),		//o--
      .sum(ex4_pp5_0s[237]),		//o--
      .car(ex4_pp5_0c[236])		//o--
   );


   tri_csa42 csa5_0_236(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[236]),		//i--
      .b(ex4_pp4_0s[236]),		//i--
      .c(ex4_recycle_c[236]),		//i--
      .d(ex4_recycle_s[236]),		//i--
      .ki(ex4_pp5_0k[236]),		//i--
      .ko(ex4_pp5_0k[235]),		//o--
      .sum(ex4_pp5_0s[236]),		//o--
      .car(ex4_pp5_0c[235])		//o--
   );


   tri_csa42 csa5_0_235(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[235]),		//i--
      .b(ex4_pp4_0s[235]),		//i--
      .c(ex4_recycle_c[235]),		//i--
      .d(ex4_recycle_s[235]),		//i--
      .ki(ex4_pp5_0k[235]),		//i--
      .ko(ex4_pp5_0k[234]),		//o--
      .sum(ex4_pp5_0s[235]),		//o--
      .car(ex4_pp5_0c[234])		//o--
   );


   tri_csa42 csa5_0_234(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[234]),		//i--
      .b(ex4_pp4_0s[234]),		//i--
      .c(ex4_recycle_c[234]),		//i--
      .d(ex4_recycle_s[234]),		//i--
      .ki(ex4_pp5_0k[234]),		//i--
      .ko(ex4_pp5_0k[233]),		//o--
      .sum(ex4_pp5_0s[234]),		//o--
      .car(ex4_pp5_0c[233])		//o--
   );


   tri_csa42 csa5_0_233(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[233]),		//i--
      .b(ex4_pp4_0s[233]),		//i--
      .c(ex4_recycle_c[233]),		//i--
      .d(ex4_recycle_s[233]),		//i--
      .ki(ex4_pp5_0k[233]),		//i--
      .ko(ex4_pp5_0k[232]),		//o--
      .sum(ex4_pp5_0s[233]),		//o--
      .car(ex4_pp5_0c[232])		//o--
   );


   tri_csa42 csa5_0_232(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[232]),		//i--
      .b(ex4_pp4_0s[232]),		//i--
      .c(ex4_recycle_c[232]),		//i--
      .d(ex4_recycle_s[232]),		//i--
      .ki(ex4_pp5_0k[232]),		//i--
      .ko(ex4_pp5_0k[231]),		//o--
      .sum(ex4_pp5_0s[232]),		//o--
      .car(ex4_pp5_0c[231])		//o--
   );


   tri_csa42 csa5_0_231(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[231]),		//i--
      .b(ex4_pp4_0s[231]),		//i--
      .c(ex4_recycle_c[231]),		//i--
      .d(ex4_recycle_s[231]),		//i--
      .ki(ex4_pp5_0k[231]),		//i--
      .ko(ex4_pp5_0k[230]),		//o--
      .sum(ex4_pp5_0s[231]),		//o--
      .car(ex4_pp5_0c[230])		//o--
   );


   tri_csa42 csa5_0_230(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[230]),		//i--
      .b(ex4_pp4_0s[230]),		//i--
      .c(ex4_recycle_c[230]),		//i--
      .d(ex4_recycle_s[230]),		//i--
      .ki(ex4_pp5_0k[230]),		//i--
      .ko(ex4_pp5_0k[229]),		//o--
      .sum(ex4_pp5_0s[230]),		//o--
      .car(ex4_pp5_0c[229])		//o--
   );


   tri_csa42 csa5_0_229(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[229]),		//i--
      .b(ex4_pp4_0s[229]),		//i--
      .c(ex4_recycle_c[229]),		//i--
      .d(ex4_recycle_s[229]),		//i--
      .ki(ex4_pp5_0k[229]),		//i--
      .ko(ex4_pp5_0k[228]),		//o--
      .sum(ex4_pp5_0s[229]),		//o--
      .car(ex4_pp5_0c[228])		//o--
   );


   tri_csa42 csa5_0_228(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[228]),		//i--
      .b(ex4_pp4_0s[228]),		//i--
      .c(ex4_recycle_c[228]),		//i--
      .d(ex4_recycle_s[228]),		//i--
      .ki(ex4_pp5_0k[228]),		//i--
      .ko(ex4_pp5_0k[227]),		//o--
      .sum(ex4_pp5_0s[228]),		//o--
      .car(ex4_pp5_0c[227])		//o--
   );


   tri_csa42 csa5_0_227(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[227]),		//i--
      .b(ex4_pp4_0s[227]),		//i--
      .c(ex4_recycle_c[227]),		//i--
      .d(ex4_recycle_s[227]),		//i--
      .ki(ex4_pp5_0k[227]),		//i--
      .ko(ex4_pp5_0k[226]),		//o--
      .sum(ex4_pp5_0s[227]),		//o--
      .car(ex4_pp5_0c[226])		//o--
   );


   tri_csa42 csa5_0_226(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[226]),		//i--
      .b(ex4_pp4_0s[226]),		//i--
      .c(ex4_recycle_c[226]),		//i--
      .d(ex4_recycle_s[226]),		//i--
      .ki(ex4_pp5_0k[226]),		//i--
      .ko(ex4_pp5_0k[225]),		//o--
      .sum(ex4_pp5_0s[226]),		//o--
      .car(ex4_pp5_0c[225])		//o--
   );


   tri_csa42 csa5_0_225(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[225]),		//i--
      .b(ex4_pp4_0s[225]),		//i--
      .c(ex4_recycle_c[225]),		//i--
      .d(ex4_recycle_s[225]),		//i--
      .ki(ex4_pp5_0k[225]),		//i--
      .ko(ex4_pp5_0k[224]),		//o--
      .sum(ex4_pp5_0s[225]),		//o--
      .car(ex4_pp5_0c[224])		//o--
   );


   tri_csa42 csa5_0_224(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[224]),		//i--
      .b(ex4_pp4_0s[224]),		//i--
      .c(ex4_recycle_c[224]),		//i--
      .d(ex4_recycle_s[224]),		//i--
      .ki(ex4_pp5_0k[224]),		//i--
      .ko(ex4_pp5_0k[223]),		//o--
      .sum(ex4_pp5_0s[224]),		//o--
      .car(ex4_pp5_0c[223])		//o--
   );


   tri_csa42 csa5_0_223(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[223]),		//i--
      .b(ex4_pp4_0s[223]),		//i--
      .c(ex4_recycle_c[223]),		//i--
      .d(ex4_recycle_s[223]),		//i--
      .ki(ex4_pp5_0k[223]),		//i--
      .ko(ex4_pp5_0k[222]),		//o--
      .sum(ex4_pp5_0s[223]),		//o--
      .car(ex4_pp5_0c[222])		//o--
   );


   tri_csa42 csa5_0_222(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[222]),		//i--
      .b(ex4_pp4_0s[222]),		//i--
      .c(ex4_recycle_c[222]),		//i--
      .d(ex4_recycle_s[222]),		//i--
      .ki(ex4_pp5_0k[222]),		//i--
      .ko(ex4_pp5_0k[221]),		//o--
      .sum(ex4_pp5_0s[222]),		//o--
      .car(ex4_pp5_0c[221])		//o--
   );


   tri_csa42 csa5_0_221(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[221]),		//i--
      .b(ex4_pp4_0s[221]),		//i--
      .c(ex4_recycle_c[221]),		//i--
      .d(ex4_recycle_s[221]),		//i--
      .ki(ex4_pp5_0k[221]),		//i--
      .ko(ex4_pp5_0k[220]),		//o--
      .sum(ex4_pp5_0s[221]),		//o--
      .car(ex4_pp5_0c[220])		//o--
   );


   tri_csa42 csa5_0_220(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[220]),		//i--
      .b(ex4_pp4_0s[220]),		//i--
      .c(ex4_recycle_c[220]),		//i--
      .d(ex4_recycle_s[220]),		//i--
      .ki(ex4_pp5_0k[220]),		//i--
      .ko(ex4_pp5_0k[219]),		//o--
      .sum(ex4_pp5_0s[220]),		//o--
      .car(ex4_pp5_0c[219])		//o--
   );


   tri_csa42 csa5_0_219(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[219]),		//i--
      .b(ex4_pp4_0s[219]),		//i--
      .c(ex4_recycle_c[219]),		//i--
      .d(ex4_recycle_s[219]),		//i--
      .ki(ex4_pp5_0k[219]),		//i--
      .ko(ex4_pp5_0k[218]),		//o--
      .sum(ex4_pp5_0s[219]),		//o--
      .car(ex4_pp5_0c[218])		//o--
   );


   tri_csa42 csa5_0_218(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[218]),		//i--
      .b(ex4_pp4_0s[218]),		//i--
      .c(ex4_recycle_c[218]),		//i--
      .d(ex4_recycle_s[218]),		//i--
      .ki(ex4_pp5_0k[218]),		//i--
      .ko(ex4_pp5_0k[217]),		//o--
      .sum(ex4_pp5_0s[218]),		//o--
      .car(ex4_pp5_0c[217])		//o--
   );


   tri_csa42 csa5_0_217(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[217]),		//i--
      .b(ex4_pp4_0s[217]),		//i--
      .c(ex4_recycle_c[217]),		//i--
      .d(ex4_recycle_s[217]),		//i--
      .ki(ex4_pp5_0k[217]),		//i--
      .ko(ex4_pp5_0k[216]),		//o--
      .sum(ex4_pp5_0s[217]),		//o--
      .car(ex4_pp5_0c[216])		//o--
   );


   tri_csa42 csa5_0_216(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[216]),		//i--
      .b(ex4_pp4_0s[216]),		//i--
      .c(ex4_recycle_c[216]),		//i--
      .d(ex4_recycle_s[216]),		//i--
      .ki(ex4_pp5_0k[216]),		//i--
      .ko(ex4_pp5_0k[215]),		//o--
      .sum(ex4_pp5_0s[216]),		//o--
      .car(ex4_pp5_0c[215])		//o--
   );


   tri_csa42 csa5_0_215(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[215]),		//i--
      .b(ex4_pp4_0s[215]),		//i--
      .c(ex4_recycle_c[215]),		//i--
      .d(ex4_recycle_s[215]),		//i--
      .ki(ex4_pp5_0k[215]),		//i--
      .ko(ex4_pp5_0k[214]),		//o--
      .sum(ex4_pp5_0s[215]),		//o--
      .car(ex4_pp5_0c[214])		//o--
   );


   tri_csa42 csa5_0_214(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[214]),		//i--
      .b(ex4_pp4_0s[214]),		//i--
      .c(ex4_recycle_c[214]),		//i--
      .d(ex4_recycle_s[214]),		//i--
      .ki(ex4_pp5_0k[214]),		//i--
      .ko(ex4_pp5_0k[213]),		//o--
      .sum(ex4_pp5_0s[214]),		//o--
      .car(ex4_pp5_0c[213])		//o--
   );


   tri_csa42 csa5_0_213(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[213]),		//i--
      .b(ex4_pp4_0s[213]),		//i--
      .c(ex4_recycle_c[213]),		//i--
      .d(ex4_recycle_s[213]),		//i--
      .ki(ex4_pp5_0k[213]),		//i--
      .ko(ex4_pp5_0k[212]),		//o--
      .sum(ex4_pp5_0s[213]),		//o--
      .car(ex4_pp5_0c[212])		//o--
   );


   tri_csa42 csa5_0_212(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[212]),		//i--
      .b(ex4_pp4_0s[212]),		//i--
      .c(ex4_recycle_c[212]),		//i--
      .d(ex4_recycle_s[212]),		//i--
      .ki(ex4_pp5_0k[212]),		//i--
      .ko(ex4_pp5_0k[211]),		//o--
      .sum(ex4_pp5_0s[212]),		//o--
      .car(ex4_pp5_0c[211])		//o--
   );


   tri_csa42 csa5_0_211(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[211]),		//i--
      .b(ex4_pp4_0s[211]),		//i--
      .c(ex4_recycle_c[211]),		//i--
      .d(ex4_recycle_s[211]),		//i--
      .ki(ex4_pp5_0k[211]),		//i--
      .ko(ex4_pp5_0k[210]),		//o--
      .sum(ex4_pp5_0s[211]),		//o--
      .car(ex4_pp5_0c[210])		//o--
   );


   tri_csa42 csa5_0_210(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[210]),		//i--
      .b(ex4_pp4_0s[210]),		//i--
      .c(ex4_recycle_c[210]),		//i--
      .d(ex4_recycle_s[210]),		//i--
      .ki(ex4_pp5_0k[210]),		//i--
      .ko(ex4_pp5_0k[209]),		//o--
      .sum(ex4_pp5_0s[210]),		//o--
      .car(ex4_pp5_0c[209])		//o--
   );


   tri_csa42 csa5_0_209(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[209]),		//i--
      .b(ex4_pp4_0s[209]),		//i--
      .c(ex4_recycle_c[209]),		//i--
      .d(ex4_recycle_s[209]),		//i--
      .ki(ex4_pp5_0k[209]),		//i--
      .ko(ex4_pp5_0k[208]),		//o--
      .sum(ex4_pp5_0s[209]),		//o--
      .car(ex4_pp5_0c[208])		//o--
   );


   tri_csa42 csa5_0_208(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[208]),		//i--
      .b(ex4_pp4_0s[208]),		//i--
      .c(ex4_recycle_c[208]),		//i--
      .d(ex4_recycle_s[208]),		//i--
      .ki(ex4_pp5_0k[208]),		//i--
      .ko(ex4_pp5_0k[207]),		//o--
      .sum(ex4_pp5_0s[208]),		//o--
      .car(ex4_pp5_0c[207])		//o--
   );


   tri_csa42 csa5_0_207(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[207]),		//i--
      .b(ex4_pp4_0s[207]),		//i--
      .c(ex4_recycle_c[207]),		//i--
      .d(ex4_recycle_s[207]),		//i--
      .ki(ex4_pp5_0k[207]),		//i--
      .ko(ex4_pp5_0k[206]),		//o--
      .sum(ex4_pp5_0s[207]),		//o--
      .car(ex4_pp5_0c[206])		//o--
   );


   tri_csa42 csa5_0_206(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[206]),		//i--
      .b(ex4_pp4_0s[206]),		//i--
      .c(ex4_recycle_c[206]),		//i--
      .d(ex4_recycle_s[206]),		//i--
      .ki(ex4_pp5_0k[206]),		//i--
      .ko(ex4_pp5_0k[205]),		//o--
      .sum(ex4_pp5_0s[206]),		//o--
      .car(ex4_pp5_0c[205])		//o--
   );


   tri_csa42 csa5_0_205(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[205]),		//i--
      .b(ex4_pp4_0s[205]),		//i--
      .c(ex4_recycle_c[205]),		//i--
      .d(ex4_recycle_s[205]),		//i--
      .ki(ex4_pp5_0k[205]),		//i--
      .ko(ex4_pp5_0k[204]),		//o--
      .sum(ex4_pp5_0s[205]),		//o--
      .car(ex4_pp5_0c[204])		//o--
   );


   tri_csa42 csa5_0_204(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[204]),		//i--
      .b(ex4_pp4_0s[204]),		//i--
      .c(ex4_recycle_c[204]),		//i--
      .d(ex4_recycle_s[204]),		//i--
      .ki(ex4_pp5_0k[204]),		//i--
      .ko(ex4_pp5_0k[203]),		//o--
      .sum(ex4_pp5_0s[204]),		//o--
      .car(ex4_pp5_0c[203])		//o--
   );


   tri_csa42 csa5_0_203(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[203]),		//i--
      .b(ex4_pp4_0s[203]),		//i--
      .c(ex4_recycle_c[203]),		//i--
      .d(ex4_recycle_s[203]),		//i--
      .ki(ex4_pp5_0k[203]),		//i--
      .ko(ex4_pp5_0k[202]),		//o--
      .sum(ex4_pp5_0s[203]),		//o--
      .car(ex4_pp5_0c[202])		//o--
   );


   tri_csa42 csa5_0_202(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[202]),		//i--
      .b(ex4_pp4_0s[202]),		//i--
      .c(ex4_recycle_c[202]),		//i--
      .d(ex4_recycle_s[202]),		//i--
      .ki(ex4_pp5_0k[202]),		//i--
      .ko(ex4_pp5_0k[201]),		//o--
      .sum(ex4_pp5_0s[202]),		//o--
      .car(ex4_pp5_0c[201])		//o--
   );


   tri_csa42 csa5_0_201(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[201]),		//i--
      .b(ex4_pp4_0s[201]),		//i--
      .c(ex4_recycle_c[201]),		//i--
      .d(ex4_recycle_s[201]),		//i--
      .ki(ex4_pp5_0k[201]),		//i--
      .ko(ex4_pp5_0k[200]),		//o--
      .sum(ex4_pp5_0s[201]),		//o--
      .car(ex4_pp5_0c[200])		//o--
   );


   tri_csa42 csa5_0_200(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[200]),		//i--
      .b(ex4_pp4_0s[200]),		//i--
      .c(ex4_recycle_c[200]),		//i--
      .d(ex4_recycle_s[200]),		//i--
      .ki(ex4_pp5_0k[200]),		//i--
      .ko(ex4_pp5_0k[199]),		//o--
      .sum(ex4_pp5_0s[200]),		//o--
      .car(ex4_pp5_0c[199])		//o--
   );


   tri_csa42 csa5_0_199(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[199]),		//i--
      .b(ex4_pp4_0s[199]),		//i--
      .c(ex4_recycle_c[199]),		//i--
      .d(ex4_recycle_s[199]),		//i--
      .ki(ex4_pp5_0k[199]),		//i--
      .ko(ex4_pp5_0k[198]),		//o--
      .sum(ex4_pp5_0s[199]),		//o--
      .car(ex4_pp5_0c[198])		//o--
   );


   tri_csa42 csa5_0_198(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[198]),		//i--
      .b(ex4_pp4_0s[198]),		//i--
      .c(ex4_recycle_c[198]),		//i--
      .d(ex4_recycle_s[198]),		//i--
      .ki(ex4_pp5_0k[198]),		//i--
      .ko(ex4_pp5_0k[197]),		//o--
      .sum(ex4_pp5_0s[198]),		//o--
      .car(ex4_pp5_0c[197])		//o--
   );


   tri_csa42 csa5_0_197(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_pp4_0c[197]),		//i--
      .b(ex4_pp4_0s[197]),		//i--
      .c(ex4_recycle_c[197]),		//i--
      .d(ex4_recycle_s[197]),		//i--
      .ki(ex4_pp5_0k[197]),		//i--
      .ko(ex4_pp5_0k[196]),		//o--
      .sum(ex4_pp5_0s[197]),		//o--
      .car(ex4_pp5_0c[196])		//o--
   );


   tri_csa32 csa5_0_196(
      .vd(vdd),
      .gd(gnd),
      .a(ex4_recycle_c[196]),		//i--
      .b(ex4_recycle_s[196]),		//i--
      .c(ex4_pp5_0k[196]),		//i--
      .sum(ex4_pp5_0s[196]),		//o--
      .car(ex4_pp5_0c[195])		//o--
   );

   assign ex5_pp5_0s_din[196:264] = ex4_pp5_0s[196:264];
   assign ex5_pp5_0c_din[196:263] = ex4_pp5_0c[196:263];

   //==================================================================================
   //== EX4 (adder ... 64 bit) part of overflow detection
   //==================================================================================

   assign ex5_pp5_0s[196:264] = (~ex5_pp5_0s_q_b[196:264]);
   assign ex5_pp5_0c[196:263] = (~ex5_pp5_0c_q_b[196:263]);

   assign ex5_pp5_0s_out[196:264] = ex5_pp5_0s[196:264];		//output--
   assign ex5_pp5_0c_out[196:263] = ex5_pp5_0c[196:263];		//output--

   //==================================================================================
   //== Pervasive stuff
   //==================================================================================


   tri_lcbnd ex4_lcb(
      .delay_lclkr(delay_lclkr_dc),		//in -- 0 ,
      .mpw1_b(mpw1_dc_b),		//in -- 0 ,
      .mpw2_b(mpw2_dc_b),		//in -- 0 ,
      .force_t(func_sl_force),		//in -- 0 ,
      .nclk(nclk),		//in
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .act(ex3_act),		//in
      .sg(sg_0),		//in
      .thold_b(func_sl_thold_0_b),		//in
      .d1clk(ex4_d1clk),		//out
      .d2clk(ex4_d2clk),		//out
      .lclk(ex4_lclk)		//out
   );


   tri_lcbnd ex5_lcb(
      .delay_lclkr(delay_lclkr_dc),		//in -- 0 ,
      .mpw1_b(mpw1_dc_b),		//in -- 0 ,
      .mpw2_b(mpw2_dc_b),		//in -- 0 ,
      .force_t(func_sl_force),		//in -- 0 ,
      .nclk(nclk),		//in
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .act(ex4_act),		//in
      .sg(sg_0),		//in
      .thold_b(func_sl_thold_0_b),		//in
      .d1clk(ex5_d1clk),		//out
      .d2clk(ex5_d2clk),		//out
      .lclk(ex5_lclk)		//out
   );

   //==================================================================================
   //== Latches
   //==================================================================================


   tri_inv_nlats #(.WIDTH(45), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) ex4_pp2_0s_lat(
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .lclk(ex4_lclk),		//lclk.clk
      .d1clk(ex4_d1clk),
      .d2clk(ex4_d2clk),
      .scanin(ex4_pp2_0s_lat_si),
      .scanout(ex4_pp2_0s_lat_so),
      .d(ex4_pp2_0s_din[198:242]),
      .qb(ex4_pp2_0s_q_b[198:242])
   );

   tri_inv_nlats #(.WIDTH(43), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) ex4_pp2_0c_lat(
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .lclk(ex4_lclk),		//lclk.clk
      .d1clk(ex4_d1clk),
      .d2clk(ex4_d2clk),
      .scanin(ex4_pp2_0c_lat_si),
      .scanout(ex4_pp2_0c_lat_so),
      .d(ex4_pp2_0c_din[198:240]),
      .qb(ex4_pp2_0c_q_b[198:240])
   );


   tri_inv_nlats #(.WIDTH(47), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) ex4_pp2_1s_lat(
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .lclk(ex4_lclk),		//lclk.clk
      .d1clk(ex4_d1clk),
      .d2clk(ex4_d2clk),
      .scanin(ex4_pp2_1s_lat_si),
      .scanout(ex4_pp2_1s_lat_so),
      .d(ex4_pp2_1s_din[208:254]),
      .qb(ex4_pp2_1s_q_b[208:254])
   );


   tri_inv_nlats #(.WIDTH(45), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) ex4_pp2_1c_lat(
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .lclk(ex4_lclk),		//lclk.clk
      .d1clk(ex4_d1clk),
      .d2clk(ex4_d2clk),
      .scanin(ex4_pp2_1c_lat_si),
      .scanout(ex4_pp2_1c_lat_so),
      .d(ex4_pp2_1c_din[208:252]),
      .qb(ex4_pp2_1c_q_b[208:252])
   );


   tri_inv_nlats #(.WIDTH(45), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) ex4_pp2_2s_lat(
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .lclk(ex4_lclk),		//lclk.clk
      .d1clk(ex4_d1clk),
      .d2clk(ex4_d2clk),
      .scanin(ex4_pp2_2s_lat_si),
      .scanout(ex4_pp2_2s_lat_so),
      .d(ex4_pp2_2s_din[220:264]),
      .qb(ex4_pp2_2s_q_b[220:264])
   );


   tri_inv_nlats #(.WIDTH(44), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) ex4_pp2_2c_lat(
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .lclk(ex4_lclk),		//lclk.clk
      .d1clk(ex4_d1clk),
      .d2clk(ex4_d2clk),
      .scanin(ex4_pp2_2c_lat_si),
      .scanout(ex4_pp2_2c_lat_so),
      .d(ex4_pp2_2c_din[220:263]),
      .qb(ex4_pp2_2c_q_b[220:263])
   );


   tri_inv_nlats #(.WIDTH(69), .BTR("NLI0001_X2_A12TH"), .NEEDS_SRESET(0)) ex5_pp5_0s_lat(
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .lclk(ex5_lclk),		//lclk.clk
      .d1clk(ex5_d1clk),
      .d2clk(ex5_d2clk),
      .scanin(ex5_pp5_0s_lat_si),
      .scanout(ex5_pp5_0s_lat_so),
      .d(ex5_pp5_0s_din[196:264]),
      .qb(ex5_pp5_0s_q_b[196:264])
   );


   tri_inv_nlats #(.WIDTH(68), .BTR("NLI0001_X2_A12TH"), .NEEDS_SRESET(0)) ex5_pp5_0c_lat(
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .lclk(ex5_lclk),		//lclk.clk
      .d1clk(ex5_d1clk),
      .d2clk(ex5_d2clk),
      .scanin(ex5_pp5_0c_lat_si),
      .scanout(ex5_pp5_0c_lat_so),
      .d(ex5_pp5_0c_din[196:263]),
      .qb(ex5_pp5_0c_q_b[196:263])
   );

   //==================================================================================
   //== scan string  (serpentine)
   //==================================================================================

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
