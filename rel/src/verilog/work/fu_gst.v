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

//==##########################################################################
//==###  FU_GST.VHDL                                                #########
//==###  side pipe for graphics estimates                            #########
//==###  flogefp, fexptefp                                           #########
//==###                                                              #########
//==##########################################################################

module fu_gst(
   vdd,
   gnd,
   clkoff_b,
   act_dis,
   flush,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   sg_1,
   thold_1,
   fpu_enable,
   nclk,
   f_gst_si,
   f_gst_so,
   ex1_act,
   f_fmt_ex2_b_sign_gst,
   f_fmt_ex2_b_expo_gst_b,
   f_fmt_ex2_b_frac_gst,
   f_pic_ex2_floges,
   f_pic_ex2_fexptes,
   f_gst_ex6_logexp_v,
   f_gst_ex6_logexp_sign,
   f_gst_ex6_logexp_exp,
   f_gst_ex6_logexp_fract
);
      `include "tri_a2o.vh"

   inout          vdd;
   inout          gnd;

   input          clkoff_b;		// tiup
   input          act_dis;		// ??tidn??
   input          flush;		// ??tidn??
   input [2:5]    delay_lclkr;		// tidn,
   input [2:5]    mpw1_b;		// tidn,
   input [0:1]    mpw2_b;		// tidn,
   input          sg_1;
   input          thold_1;
   input          fpu_enable;		//dc_act
   input  [0:`NCLK_WIDTH-1] nclk;
   //--------------------------------------------------------------------------
   //
   input          f_gst_si;		//perv  scan
   output         f_gst_so;		//perv  scan

   input          ex1_act;
   //--------------------------------------------------------------------------
   input          f_fmt_ex2_b_sign_gst;
   input [01:13]  f_fmt_ex2_b_expo_gst_b;
   input [01:19]  f_fmt_ex2_b_frac_gst;
   //--------------------------------------------------------------------------
   input          f_pic_ex2_floges;
   input          f_pic_ex2_fexptes;
   //--------------------------------------------------------------------------
   output         f_gst_ex6_logexp_v;
   output         f_gst_ex6_logexp_sign;		// needs to be right off of a latch
   output [01:11] f_gst_ex6_logexp_exp;		// needs to be right off of a latch
   output [00:19] f_gst_ex6_logexp_fract;		// needs to be right off of a latch
   //--------------------------------------------------------------------------

   //==################################################

   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;

   wire           sg_0;
   wire           thold_0_b;
   wire           thold_0;
   wire           force_t;

   //----------------------------------------------------------------------

   wire [0:1]     ex3_gst_ctrl_lat_scout;
   wire [0:1]     ex3_gst_ctrl_lat_scin;
   wire [0:1]     ex4_gst_ctrl_lat_scout;
   wire [0:1]     ex4_gst_ctrl_lat_scin;
   wire [0:3]     ex5_gst_ctrl_lat_scout;
   wire [0:3]     ex5_gst_ctrl_lat_scin;
   wire [0:1]     ex6_gst_ctrl_lat_scout;
   wire [0:1]     ex6_gst_ctrl_lat_scin;
   wire [0:32]    ex3_gst_stage_lat_scout;
   wire [0:32]    ex3_gst_stage_lat_scin;
   wire [0:19]    ex4_gst_stage_lat_scout;
   wire [0:19]    ex4_gst_stage_lat_scin;
   wire [0:23]    ex5_gst_stage_lat_scout;
   wire [0:23]    ex5_gst_stage_lat_scin;
   wire [0:31]    ex6_gst_stage_lat_scout;
   wire [0:31]    ex6_gst_stage_lat_scin;

   wire [1:11]    ex5_log_dp_bias;
   wire           ex5_logof1_specialcase;
   wire           ex4_logof1_specialcase;

   wire           ex5_signbit_din;
   wire           ex6_signbit;
   wire           ex5_log_signbit;

   wire           f1;
   wire           f2;
   wire           f3;
   wire           f4;
   wire           f5;
   wire           f6;
   wire           f7;
   wire           f8;
   wire           f9;
   wire           f10;

   wire           s1;
   wire           s2;
   wire           s3;
   wire           c4;
   wire           c5;
   wire           c6;
   wire           c7;
   wire           a4;
   wire           a5;
   wire           a6;
   wire           a7;
   wire           a8;
   wire           a9;
   wire           a10;
   wire           a11;

   wire [1:11]    ex3_f;
   wire [4:11]    ex3_a;
   wire [4:11]    ex3_c;

   wire [4:7]     ex3_log_fsum;
   wire [3:6]     ex3_log_fcarryin;

   wire           ex3_b_sign;
   wire [1:13]    ex3_b_biased_13exp;
   wire [1:11]    ex3_b_biased_11exp;

   wire [1:11]    ex3_b_ubexp_sum;
   wire [2:11]    ex3_b_ubexp_cout;
   wire [1:11]    ex3_b_ubexp;

   wire [1:19]    ex3_b_fract;

   wire [1:13]    f_fmt_ex2_b_expo_gst;

   wire           ex2_floges;
   wire           ex2_fexptes;
   wire           ex3_floges;
   wire           ex3_fexptes;
   wire           ex4_floges;
   wire           ex4_fexptes;
   wire           ex5_floges;
   wire           ex5_fexptes;
   wire           ex6_floges;
   wire           ex6_fexptes;

   wire [1:11]    ex3_log_a_addend_b;
   wire [1:11]    ex3_log_b_addend_b;

   wire [1:19]    ex4_mantissa;
   wire [1:19]    ex5_mantissa;
   wire [1:19]    ex4_mantissa_precomp;
   wire [1:19]    ex4_mantissa_precomp_b;
   wire [1:19]    ex3_log_mantissa_precomp;
   wire [1:19]    ex4_mantissa_neg;
   wire [1:19]    ex3_mantissa_din;
   wire [0:4]     ex3_shamt;
   wire [0:4]     ex4_shamt;
   wire [0:4]     ex5_shamt;
   wire           ex4_negate;
   wire           ex5_negate;
   wire           ex4_b_sign;

   wire [00:19]   ex3_mantissa_shlev0;
   wire [00:22]   ex3_mantissa_shlev1;		// 0 to 3
   wire [00:34]   ex3_mantissa_shlev2;		// 0 to 12
   wire [00:50]   ex3_mantissa_shlev3;		// 0 to 16

   wire [1:8]     ex3_pow_int;
   wire [1:11]    ex3_pow_frac;

   wire [01:19]   ex5_mantissa_shlev0;
   wire [01:22]   ex5_mantissa_shlev1;		// 0 to 3
   wire [01:34]   ex5_mantissa_shlev2;		// 0 to 12
   wire [01:50]   ex5_mantissa_shlev3;		// 0 to 16

   wire [01:11]   ex5_exponent_a_addend_b;
   wire [01:11]   ex5_exponent_b_addend_b;

   wire [01:11]   ex5_log_a_addend_b;
   wire [01:11]   ex5_log_b_addend_b;
   wire [01:11]   ex5_pow_a_addend_b;
   wire [01:11]   ex5_pow_b_addend_b;

   wire [01:11]   ex5_biased_exponent_result;
   wire [01:11]   ex6_biased_exponent_result;

   wire [01:19]   ex5_log_mantissa_postsh;
   wire [01:19]   ex5_log_fract;
   wire [01:11]   ex5_pow_fract;
   wire [01:11]   ex5_pow_fract_b;
   wire [00:19]   ex5_fract_din;
   wire [00:19]   ex6_fract;

   wire           l1_enc00;
   wire           l1_enc01;
   wire           l1_enc10;
   wire           l1_enc11;
   wire           l2_enc00;
   wire           l2_enc01;
   wire           l2_enc10;
   wire           l2_enc11;
   wire           l3_enc00;
   wire           l3_enc01;
   wire           l1_e00;
   wire           l1_e01;
   wire           l1_e10;
   wire           l1_e11;
   wire           l2_e00;
   wire           l2_e01;
   wire           l2_e10;
   wire           l2_e11;
   wire           l3_e00;
   wire           l3_e01;

   wire [01:11]   ex5_f;
   wire [01:11]   ex5_f_b;

   //----------------------------------------------------------------------
   wire           eb1;		//, eb11
   wire           eb2;
   wire           eb3;
   wire           eb4;
   wire           eb5;
   wire           eb6;
   wire           eb7;
   wire           eb8;
   wire           eb9;
   wire           eb10;

   wire           ea4;
   wire           ea5;
   wire           ea6;
   wire           ea7;
   wire           ea8;
   wire           ea9;
   wire           ea10;
   wire           ea11;
   wire           ec4;
   wire           ec5;
   wire           ec6;
   wire           ec7;
   wire           es1;
   wire           es2;
   wire           es3;
   wire [4:11]    ex5_ea;
   wire [4:11]    ex5_ec;

   wire [1:11]    ex5_addend1;
   wire [1:11]    ex5_addend2;
   wire [1:11]    ex5_addend3;
   wire [1:11]    ex5_fsum;
   wire [1:11]    ex5_fcarryin;
   wire [1:11]    ex5_powf_a_addend_b;
   wire [1:11]    ex5_powf_b_addend_b;

   wire [01:16]   zeros;
   wire           ex3_powsh_no_sat_lft;
   wire           ex3_powsh_no_sat_rgt;


   wire           ex2_act;
   wire           ex3_act;
   wire           ex4_act;
   wire           ex5_act;
   wire [0:7]     act_so;
   wire [0:7]     act_si;

   (* analysis_not_referenced="TRUE" *)
   wire [0:3]     act_spare_unused;

   (* analysis_not_referenced="TRUE" *)
   wire           unused;

   wire [2:11]    ex3_ube_g2_b;
   wire [2:11]    ex3_ube_g4;
   wire [2:11]    ex3_ube_g8_b;
   wire           s2_0;
   wire           s2_1;
   wire           s3_0;
   wire           s3_1;
   wire           sx;

   wire           s7_if_s1;
   wire           s7_if_s20;
   wire           s7_if_s30;
   wire           s7_if_sx;
   wire           s7_if_s31;
   wire           s7_if_s21;
   wire           c6_if_s1;
   wire           c6_if_s20;
   wire           c6_if_s30;
   wire           c6_if_sx;
   wire           c6_if_s31;
   wire           c6_if_s21;

   wire           s6_if_s1;
   wire           s6_if_s20;
   wire           s6_if_s30;
   wire           s6_if_sx;
   wire           s6_if_s31;
   wire           s6_if_s21;
   wire           c5_if_s1;
   wire           c5_if_s20;
   wire           c5_if_s30;
   wire           c5_if_sx;
   wire           c5_if_s31;
   wire           c5_if_s21;

   wire           s5_if_s1;
   wire           s5_if_s20;
   wire           s5_if_s30;
   wire           s5_if_sx;
   wire           s5_if_s31;
   wire           s5_if_s21;
   wire           c4_if_s1;
   wire           c4_if_s20;
   wire           c4_if_s30;
   wire           c4_if_sx;
   wire           c4_if_s31;
   wire           c4_if_s21;

   wire           s4_if_s1;
   wire           s4_if_s20;
   wire           s4_if_s30;
   wire           s4_if_sx;
   wire           s4_if_s31;
   wire           s4_if_s21;
   wire           c3_if_s1;
   wire           c3_if_s20;
   wire           c3_if_s30;
   wire           c3_if_sx;
   wire           c3_if_s31;
   wire           c3_if_s21;

   wire           es4_if_s1;
   wire           es4_if_s20;
   wire           es4_if_s30;
   wire           es4_if_sx;
   wire           es4_if_s31;
   wire           es4_if_s21;
   wire           ec3_if_s1;
   wire           ec3_if_s20;
   wire           ec3_if_s30;
   wire           ec3_if_sx;
   wire           ec3_if_s31;
   wire           ec3_if_s21;

   wire           es5_if_s1;
   wire           es5_if_s20;
   wire           es5_if_s30;
   wire           es5_if_sx;
   wire           es5_if_s31;
   wire           es5_if_s21;
   wire           ec4_if_s1;
   wire           ec4_if_s20;
   wire           ec4_if_s30;
   wire           ec4_if_sx;
   wire           ec4_if_s31;
   wire           ec4_if_s21;

   wire           es6_if_s1;
   wire           es6_if_s20;
   wire           es6_if_s30;
   wire           es6_if_sx;
   wire           es6_if_s31;
   wire           es6_if_s21;
   wire           ec5_if_s1;
   wire           ec5_if_s20;
   wire           ec5_if_s30;
   wire           ec5_if_sx;
   wire           ec5_if_s31;
   wire           ec5_if_s21;

   wire           es7_if_s1;
   wire           es7_if_s20;
   wire           es7_if_s30;
   wire           es7_if_sx;
   wire           es7_if_s31;
   wire           es7_if_s21;
   wire           ec6_if_s1;
   wire           ec6_if_s20;
   wire           ec6_if_s30;
   wire           ec6_if_sx;
   wire           ec6_if_s31;
   wire           ec6_if_s21;
   wire           es2_0;
   wire           es2_1;
   wire           esx;
   wire           es3_0;
   wire           es3_1;

   //==##########################################
   //# pervasive
   //==##########################################

   assign unused = ex3_b_biased_13exp[1] | ex3_b_biased_13exp[2] | ex3_b_ubexp[2] | ex3_b_ubexp[3] |
ex3_mantissa_shlev3[0] | ex3_mantissa_shlev3[1] | ex3_mantissa_shlev3[2] | ex3_mantissa_shlev3[3] |
ex3_mantissa_shlev3[4] | ex3_mantissa_shlev3[5] | ex3_mantissa_shlev3[6] | ex3_mantissa_shlev3[7] |
ex3_mantissa_shlev3[27] | ex3_mantissa_shlev3[28] | ex3_mantissa_shlev3[29] | ex3_mantissa_shlev3[30] |
ex3_mantissa_shlev3[31] | ex3_mantissa_shlev3[32] | ex3_mantissa_shlev3[33] | ex3_mantissa_shlev3[34] |
ex3_mantissa_shlev3[35] | ex3_mantissa_shlev3[36] | ex3_mantissa_shlev3[37] | ex3_mantissa_shlev3[38] |
ex3_mantissa_shlev3[39] | ex3_mantissa_shlev3[40] | ex3_mantissa_shlev3[41] | ex3_mantissa_shlev3[42] |
ex3_mantissa_shlev3[43] | ex3_mantissa_shlev3[44] | ex3_mantissa_shlev3[45] | ex3_mantissa_shlev3[46] |
ex3_mantissa_shlev3[47] | ex3_mantissa_shlev3[48] | ex3_mantissa_shlev3[49] | ex3_mantissa_shlev3[50] |
|(ex5_mantissa_shlev3[1:31]) |
          |( ex3_a[4:7]        ) |
          |( ex3_c[4:11]       ) |
          |( ex5_addend1[1:11] ) |
          |( ex5_addend2[1:11] ) |
          |( ex5_addend3[1:11] ) |
          s2                       |
          s3                       |
          es2                      |
          es3                     ;


   tri_plat  thold_reg_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(flush),
      .din(thold_1),
      .q(thold_0)
   );


   tri_plat  sg_reg_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(flush),
      .din(sg_1),
      .q(sg_0)
   );


   tri_lcbor  lcbor_0(
      .clkoff_b(clkoff_b),
      .thold(thold_0),
      .sg(sg_0),
      .act_dis(act_dis),
      .force_t(force_t),
      .thold_b(thold_0_b)
   );

   //==##########################################



   tri_rlmreg_p #(.WIDTH(8),  .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),
      .mpw1_b(mpw1_b[4]),
      .mpw2_b(mpw2_b[0]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(fpu_enable),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(act_so),
      .scin(act_si),
      //-----------------
      .din({act_spare_unused[0],
            act_spare_unused[1],
            ex1_act,
            ex2_act,
            ex3_act,
            ex4_act,
            act_spare_unused[2],
            act_spare_unused[3]}),
      //-----------------
      .dout({act_spare_unused[0],
             act_spare_unused[1],
             ex2_act,
             ex3_act,
             ex4_act,
             ex5_act,
             act_spare_unused[2],
             act_spare_unused[3]})
   );

   //==##########################################

   assign zeros = {16{tidn}};

   assign ex2_floges = f_pic_ex2_floges;
   assign ex2_fexptes = f_pic_ex2_fexptes;

   //---------------------------------------------------------------------

   tri_rlmreg_p #( .WIDTH(2), .NEEDS_SRESET(0)) ex3_gst_ctrl_lat(
      .force_t(force_t),		//d_mode           => tiup,       delay_lclkr      => tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),
      .mpw1_b(mpw1_b[2]),
      .mpw2_b(mpw2_b[0]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(ex2_act),
      //-----------------
      .scout(ex3_gst_ctrl_lat_scout),
      .scin(ex3_gst_ctrl_lat_scin),
      //-----------------
      .din({ex2_floges,
            ex2_fexptes}),
      //-----------------
      .dout({ex3_floges,
             ex3_fexptes})
   );
   //---------------------------------------------------------------------

   //----------------------------------------------------------------------
   //----------------------------------------------------------------------

   assign f_fmt_ex2_b_expo_gst = (~f_fmt_ex2_b_expo_gst_b);

   //---------------------------------------------------------------------

   tri_rlmreg_p #( .WIDTH(33), .NEEDS_SRESET(0)) ex3_gst_stage_lat(
      .force_t(force_t),		//d_mode           => tiup,       delay_lclkr      => tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),
      .mpw1_b(mpw1_b[2]),
      .mpw2_b(mpw2_b[0]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(ex2_act),
      //-----------------
      .scout(ex3_gst_stage_lat_scout),
      .scin(ex3_gst_stage_lat_scin),
      //-----------------
      .din({f_fmt_ex2_b_sign_gst,
            f_fmt_ex2_b_expo_gst,
            f_fmt_ex2_b_frac_gst}),

      //-----------------
      .dout({ex3_b_sign,
             ex3_b_biased_13exp,
             ex3_b_fract})
   );

   //******************************************************************************
   //* LOG ESTIMATE CALCULATION, FRACTIONAL PORTION
   //******************************************************************************

   assign ex3_f[1:11] = ex3_b_fract[1:11];

   assign f1 = ex3_f[1];
   assign f2 = ex3_f[2];
   assign f3 = ex3_f[3];
   assign f4 = ex3_f[4];
   assign f5 = ex3_f[5];
   assign f6 = ex3_f[6];
   assign f7 = ex3_f[7];
   assign f8 = ex3_f[8];
   assign f9 = ex3_f[9];
   assign f10 = ex3_f[10];

   assign s1 = ((~f1) & (~f2) & (~f3) & (~f4));		//0
   //1
   assign s2_0 = ((~f1) & (~f2) & (~f3) & f4) | ((~f1) & (~f2) & f3 & (~f4));		//2
   //3
   assign s3_0 = ((~f1) & (~f2) & f3 & f4) | ((~f1) & f2 & (~f3));		//4,5
   //6,7
   assign sx = ((~f1) & f2 & f3) | (f1 & (~f2) & (~f3) & (~f4));		//8
   //9
   assign s3_1 = (f1 & (~f2) & (~f3) & f4) | (f1 & (~f2) & f3);		//10,11
   assign s2_1 = (f1 & f2);		//12,13,14,15

   assign s2 = s2_0 | s2_1;
   assign s3 = s3_0 | s3_1;

   //------------------------------------------------------------------------------

   assign c4 = sx;
   assign c5 = s3_0 | s3_1;
   assign c6 = sx | s2_0;
   assign c7 = sx | s3_0;

   assign a4 = (s1 & f3) | (s2_0 & f2) | (s2_1 & (~f2));

   assign a5 = (s1 & f4) | (s2_0 & f3) | (s2_1 & (~f3)) | (s3_0 & f2) | (s3_1 & (~f2));

   assign a6 = (s1 & f5) | (s2_0 & f4) | (s2_1 & (~f4)) | (s3_0 & f3) | (s3_1 & (~f3));

   assign a7 = (s1 & f6) | (s2_0 & f5) | (s2_1 & (~f5)) | (s3_0 & f4) | (s3_1 & (~f4));

   assign a8 = (s1 & f7) | (s2_0 & f6) | (s2_1 & (~f6)) | (s3_0 & f5) | (s3_1 & (~f5));

   assign a9 = (s1 & f8) | (s2_0 & f7) | (s2_1 & (~f7)) | (s3_0 & f6) | (s3_1 & (~f6));

   assign a10 = (s1 & f9) | (s2_0 & f8) | (s2_1 & (~f8)) | (s3_0 & f7) | (s3_1 & (~f7));

   assign a11 = (s1 & f10) | (s2_0 & f9) | (s2_1 & (~f9)) | (s3_0 & f8) | (s3_1 & (~f8));

   //------------------------------------------------------------------------------

   assign ex3_a[4:11] = {a4, a5, a6, a7, a8, a9, a10, a11};
   assign ex3_c[4:11] = {c4, c5, c6, c7, tidn, tidn, tidn, tidn};

   //------------------------------------------------------------------------------
   // 3 to 2 compressor
   //------------------------------------------------------------------------------

   assign c3_if_s1 = f4 & f3;
   assign c3_if_s20 = f4 & f2;
   assign c3_if_s30 = tidn;
   assign c3_if_sx = f4;
   assign c3_if_s31 = tidn;
   assign c3_if_s21 = f4 & (~f2);

   assign s4_if_s1 = f4 ^ f3;
   assign s4_if_s20 = f4 ^ f2;
   assign s4_if_s30 = f4;
   assign s4_if_sx = (~f4);
   assign s4_if_s31 = f4;
   assign s4_if_s21 = f4 ^ (~f2);

   assign c4_if_s1 = f5 & f4;
   assign c4_if_s20 = f5 & f3;
   assign c4_if_s30 = f5 | f2;
   assign c4_if_sx = tidn;
   assign c4_if_s31 = f5 | (~f2);
   assign c4_if_s21 = f5 & (~f3);

   assign s5_if_s1 = f5 ^ f4;
   assign s5_if_s20 = f5 ^ f3;
   assign s5_if_s30 = f5 ^ (~f2);
   assign s5_if_sx = f5;
   assign s5_if_s31 = f5 ^ f2;
   assign s5_if_s21 = f5 ^ (~f3);

   assign c5_if_s1 = f6 & f5;
   assign c5_if_s20 = f6 | f4;
   assign c5_if_s30 = f6 & f3;
   assign c5_if_sx = f6;
   assign c5_if_s31 = f6 & (~f3);
   assign c5_if_s21 = f6 & (~f4);

   assign s6_if_s1 = f6 ^ f5;
   assign s6_if_s20 = f6 ^ (~f4);
   assign s6_if_s30 = f6 ^ f3;
   assign s6_if_sx = (~f6);
   assign s6_if_s31 = f6 ^ (~f3);
   assign s6_if_s21 = f6 ^ (~f4);

   assign c6_if_s1 = f7 & f6;
   assign c6_if_s20 = f7 & f5;
   assign c6_if_s30 = f7 | f4;
   assign c6_if_sx = f7;
   assign c6_if_s31 = f7 & (~f4);
   assign c6_if_s21 = f7 & (~f5);

   assign s7_if_s1 = f7 ^ f6;
   assign s7_if_s20 = f7 ^ f5;
   assign s7_if_s30 = f7 ^ (~f4);
   assign s7_if_sx = (~f7);
   assign s7_if_s31 = f7 ^ (~f4);
   assign s7_if_s21 = f7 ^ (~f5);

   assign ex3_log_fsum[4] = (s1 & s4_if_s1) | (s2_0 & s4_if_s20) | (s3_0 & s4_if_s30) | (sx & s4_if_sx) | (s3_1 & s4_if_s31) | (s2_1 & s4_if_s21);

   assign ex3_log_fcarryin[3] = (s1 & c3_if_s1) | (s2_0 & c3_if_s20) | (s3_0 & c3_if_s30) | (sx & c3_if_sx) | (s3_1 & c3_if_s31) | (s2_1 & c3_if_s21);

   assign ex3_log_fsum[5] = (s1 & s5_if_s1) | (s2_0 & s5_if_s20) | (s3_0 & s5_if_s30) | (sx & s5_if_sx) | (s3_1 & s5_if_s31) | (s2_1 & s5_if_s21);

   assign ex3_log_fcarryin[4] = (s1 & c4_if_s1) | (s2_0 & c4_if_s20) | (s3_0 & c4_if_s30) | (sx & c4_if_sx) | (s3_1 & c4_if_s31) | (s2_1 & c4_if_s21);

   assign ex3_log_fsum[6] = (s1 & s6_if_s1) | (s2_0 & s6_if_s20) | (s3_0 & s6_if_s30) | (sx & s6_if_sx) | (s3_1 & s6_if_s31) | (s2_1 & s6_if_s21);

   assign ex3_log_fcarryin[5] = (s1 & c5_if_s1) | (s2_0 & c5_if_s20) | (s3_0 & c5_if_s30) | (sx & c5_if_sx) | (s3_1 & c5_if_s31) | (s2_1 & c5_if_s21);

   assign ex3_log_fsum[7] = (s1 & s7_if_s1) | (s2_0 & s7_if_s20) | (s3_0 & s7_if_s30) | (sx & s7_if_sx) | (s3_1 & s7_if_s31) | (s2_1 & s7_if_s21);

   assign ex3_log_fcarryin[6] = (s1 & c6_if_s1) | (s2_0 & c6_if_s20) | (s3_0 & c6_if_s30) | (sx & c6_if_sx) | (s3_1 & c6_if_s31) | (s2_1 & c6_if_s21);

   assign ex3_log_a_addend_b[1] = (~(ex3_f[1]));
   assign ex3_log_a_addend_b[2] = (~(ex3_f[2]));
   assign ex3_log_a_addend_b[3] = (~(ex3_f[3]));
   assign ex3_log_a_addend_b[4] = (~(ex3_log_fsum[4]));
   assign ex3_log_a_addend_b[5] = (~(ex3_log_fsum[5]));
   assign ex3_log_a_addend_b[6] = (~(ex3_log_fsum[6]));
   assign ex3_log_a_addend_b[7] = (~(ex3_log_fsum[7]));
   assign ex3_log_a_addend_b[8] = (~(ex3_f[8]));
   assign ex3_log_a_addend_b[9] = (~(ex3_f[9]));
   assign ex3_log_a_addend_b[10] = (~(ex3_f[10]));
   assign ex3_log_a_addend_b[11] = (~(ex3_f[11]));

   assign ex3_log_b_addend_b[1] = (~(tidn));
   assign ex3_log_b_addend_b[2] = (~(tidn));
   assign ex3_log_b_addend_b[3] = (~(ex3_log_fcarryin[3]));
   assign ex3_log_b_addend_b[4] = (~(ex3_log_fcarryin[4]));
   assign ex3_log_b_addend_b[5] = (~(ex3_log_fcarryin[5]));
   assign ex3_log_b_addend_b[6] = (~(ex3_log_fcarryin[6]));
   assign ex3_log_b_addend_b[7] = (~(tidn));
   assign ex3_log_b_addend_b[8] = (~(ex3_a[8]));
   assign ex3_log_b_addend_b[9] = (~(ex3_a[9]));
   assign ex3_log_b_addend_b[10] = (~(ex3_a[10]));
   assign ex3_log_b_addend_b[11] = (~(ex3_a[11]));

   //------------------------------------------------------------------------------
   // unbias the exponent
   //------------------------------------------------------------------------------
   // bias is DP, so subtract 1023

   assign ex3_b_biased_11exp[1:11] = ex3_b_biased_13exp[3:13];

   // add -1023 (10000000001)

   assign ex3_b_ubexp_sum[01] = (~ex3_b_biased_11exp[01]);
   assign ex3_b_ubexp_sum[02:10] = ex3_b_biased_11exp[02:10];
   assign ex3_b_ubexp_sum[11] = (~ex3_b_biased_11exp[11]);

   assign ex3_ube_g2_b[11] = (~(ex3_b_biased_11exp[11]));
   assign ex3_ube_g2_b[10] = (~(ex3_b_biased_11exp[10] & ex3_b_biased_11exp[11]));
   assign ex3_ube_g2_b[9] = (~(ex3_b_biased_11exp[9] & ex3_b_biased_11exp[10]));
   assign ex3_ube_g2_b[8] = (~(ex3_b_biased_11exp[8] & ex3_b_biased_11exp[9]));
   assign ex3_ube_g2_b[7] = (~(ex3_b_biased_11exp[7] & ex3_b_biased_11exp[8]));
   assign ex3_ube_g2_b[6] = (~(ex3_b_biased_11exp[6] & ex3_b_biased_11exp[7]));
   assign ex3_ube_g2_b[5] = (~(ex3_b_biased_11exp[5] & ex3_b_biased_11exp[6]));
   assign ex3_ube_g2_b[4] = (~(ex3_b_biased_11exp[4] & ex3_b_biased_11exp[5]));
   assign ex3_ube_g2_b[3] = (~(ex3_b_biased_11exp[3] & ex3_b_biased_11exp[4]));
   assign ex3_ube_g2_b[2] = (~(ex3_b_biased_11exp[2] & ex3_b_biased_11exp[3]));

   assign ex3_ube_g4[11] = (~(ex3_ube_g2_b[11]));
   assign ex3_ube_g4[10] = (~(ex3_ube_g2_b[10]));
   assign ex3_ube_g4[9] = (~(ex3_ube_g2_b[9] | ex3_ube_g2_b[11]));
   assign ex3_ube_g4[8] = (~(ex3_ube_g2_b[8] | ex3_ube_g2_b[10]));
   assign ex3_ube_g4[7] = (~(ex3_ube_g2_b[7] | ex3_ube_g2_b[9]));
   assign ex3_ube_g4[6] = (~(ex3_ube_g2_b[6] | ex3_ube_g2_b[8]));
   assign ex3_ube_g4[5] = (~(ex3_ube_g2_b[5] | ex3_ube_g2_b[7]));
   assign ex3_ube_g4[4] = (~(ex3_ube_g2_b[4] | ex3_ube_g2_b[6]));
   assign ex3_ube_g4[3] = (~(ex3_ube_g2_b[3] | ex3_ube_g2_b[5]));
   assign ex3_ube_g4[2] = (~(ex3_ube_g2_b[2] | ex3_ube_g2_b[4]));

   assign ex3_ube_g8_b[11] = (~(ex3_ube_g4[11]));
   assign ex3_ube_g8_b[10] = (~(ex3_ube_g4[10]));
   assign ex3_ube_g8_b[9] = (~(ex3_ube_g4[9]));
   assign ex3_ube_g8_b[8] = (~(ex3_ube_g4[8]));
   assign ex3_ube_g8_b[7] = (~(ex3_ube_g4[7] & ex3_ube_g4[11]));
   assign ex3_ube_g8_b[6] = (~(ex3_ube_g4[6] & ex3_ube_g4[10]));
   assign ex3_ube_g8_b[5] = (~(ex3_ube_g4[5] & ex3_ube_g4[9]));
   assign ex3_ube_g8_b[4] = (~(ex3_ube_g4[4] & ex3_ube_g4[8]));
   assign ex3_ube_g8_b[3] = (~(ex3_ube_g4[3] & ex3_ube_g4[7]));
   assign ex3_ube_g8_b[2] = (~(ex3_ube_g4[2] & ex3_ube_g4[6]));

   assign ex3_b_ubexp_cout[11] = (~(ex3_ube_g8_b[11]));
   assign ex3_b_ubexp_cout[10] = (~(ex3_ube_g8_b[10]));
   assign ex3_b_ubexp_cout[9] = (~(ex3_ube_g8_b[9]));
   assign ex3_b_ubexp_cout[8] = (~(ex3_ube_g8_b[8]));
   assign ex3_b_ubexp_cout[7] = (~(ex3_ube_g8_b[7]));
   assign ex3_b_ubexp_cout[6] = (~(ex3_ube_g8_b[6]));
   assign ex3_b_ubexp_cout[5] = (~(ex3_ube_g8_b[5]));
   assign ex3_b_ubexp_cout[4] = (~(ex3_ube_g8_b[4]));
   assign ex3_b_ubexp_cout[3] = (~(ex3_ube_g8_b[3] | ex3_ube_g8_b[11]));
   assign ex3_b_ubexp_cout[2] = (~(ex3_ube_g8_b[2] | ex3_ube_g8_b[10]));

   assign ex3_b_ubexp[01:10] = ex3_b_ubexp_sum[01:10] ^ ex3_b_ubexp_cout[02:11];
   assign ex3_b_ubexp[11] = ex3_b_ubexp_sum[11];

   //------------------------------------------------------------------------------

   		// not really an 11 bit adder
   fu_gst_add11 ex3_logadd11(
      .a_b(ex3_log_a_addend_b[1:11]),
      .b_b(ex3_log_b_addend_b[1:11]),
      //------------------------------------------------------
      .s0(ex3_log_mantissa_precomp[9:19])
   );
   //---------------------------------------------------------------------

   assign ex3_log_mantissa_precomp[1:8] = ex3_b_ubexp[4:11];

   //----------------------------------------------------------------------------------------------------------------------
   // for fexptes, shift mantissa based on the exponent (un-normalize)

   assign ex3_mantissa_shlev0[00:19] = {tiup, ex3_b_fract[01:19]};

   assign ex3_shamt[0:4] = {ex3_b_ubexp[1], ex3_b_ubexp[08:11]};

   //timing note: the shift amount comes after the adder to unbias the exponent.
   //             it would be faster to use the biased exponent but use the shift controls different.
   //
   //             1 2 3 4 5 6 7 8 9 A B
   //             0 1 1 1 1 1 1 1 1 1 1  bias =1023
   //             1 0 0 0 0 0 0 0 0 0 1  add -1023 to unbias
   //             for small shifts   unbiased 01 = biased 00
   //             for small shifts   unbiased 10 = biased 01
   //             for small shifts   unbiased 11 = biased 10
   //             for small shifts   unbiased 00 = biased 11

   assign ex3_powsh_no_sat_lft = (~ex3_b_ubexp[2]) & (~ex3_b_ubexp[3]) & (~ex3_b_ubexp[4]) & (~ex3_b_ubexp[5]) & (~ex3_b_ubexp[6]) & (~ex3_b_ubexp[7]);

   assign ex3_powsh_no_sat_rgt = ex3_b_ubexp[2] & ex3_b_ubexp[3] & ex3_b_ubexp[4] & ex3_b_ubexp[5] & ex3_b_ubexp[6] & ex3_b_ubexp[7];

   assign l1_e00 = (~ex3_shamt[3]) & (~ex3_shamt[4]);
   assign l1_e01 = (~ex3_shamt[3]) & ex3_shamt[4];
   assign l1_e10 = ex3_shamt[3] & (~ex3_shamt[4]);
   assign l1_e11 = ex3_shamt[3] & ex3_shamt[4];

   assign l2_e00 = (~ex3_shamt[1]) & (~ex3_shamt[2]);
   assign l2_e01 = (~ex3_shamt[1]) & ex3_shamt[2];
   assign l2_e10 = ex3_shamt[1] & (~ex3_shamt[2]);
   assign l2_e11 = ex3_shamt[1] & ex3_shamt[2];

   assign l3_e00 = (~ex3_shamt[0]) & ex3_powsh_no_sat_lft;
   assign l3_e01 = ex3_shamt[0] & ex3_powsh_no_sat_rgt;		// this means shift Right by 16

   assign ex3_mantissa_shlev1[00:22] = ({zeros[01:03], (ex3_mantissa_shlev0[00:19])} &                   {23{l1_e00}}) |
                                       ({zeros[01:02], ({ex3_mantissa_shlev0[00:19], zeros[01]})} &      {23{l1_e01}}) |
                                       ({zeros[01], ({ex3_mantissa_shlev0[00:19], zeros[01:02]})} &      {23{l1_e10}}) |
                                       (({ex3_mantissa_shlev0[00:19], zeros[01:03]}) &                   {23{l1_e11}});

   assign ex3_mantissa_shlev2[00:34] = ({zeros[01:12], (ex3_mantissa_shlev1[00:22])} &                 {35{l2_e00}}) |
                                       ({zeros[01:08], ({ex3_mantissa_shlev1[00:22], zeros[01:04]})} & {35{l2_e01}}) |
                                       ({zeros[01:04], ({ex3_mantissa_shlev1[00:22], zeros[01:08]})} & {35{l2_e10}}) |
                                       (({ex3_mantissa_shlev1[00:22], zeros[01:12]}) &                 {35{l2_e11}});

   assign ex3_mantissa_shlev3[00:50] = (({ex3_mantissa_shlev2[00:34], zeros[01:16]}) & {51{l3_e00}}) |
                                       ({zeros[01:16], (ex3_mantissa_shlev2[00:34])} & {51{l3_e01}});

   assign ex3_pow_int[1:8] = ex3_mantissa_shlev3[08:15];
   assign ex3_pow_frac[1:11] = ex3_mantissa_shlev3[16:26];

   assign ex3_mantissa_din[1:19] = (({ex3_pow_int[1:8], ex3_pow_frac[1:11]}) & {19{ex3_fexptes}}) |
                                     (ex3_log_mantissa_precomp[1:19] &         {19{ex3_floges}});

   //---------------------------------------------------------------------
   //---------------------------------------------------------------------
   //---------------------------------------------------------------------
   //---------------------------------------------------------------------

   tri_rlmreg_p #( .WIDTH(2), .NEEDS_SRESET(0)) ex4_gst_ctrl_lat(
      .force_t(force_t),		//d_mode           => tiup,       delay_lclkr      => tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),
      .mpw1_b(mpw1_b[3]),
      .mpw2_b(mpw2_b[0]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(ex3_act),
      //-----------------
      .scout(ex4_gst_ctrl_lat_scout),
      .scin(ex4_gst_ctrl_lat_scin),
      //-----------------
      .din({ex3_floges,
            ex3_fexptes}),
      //-----------------
      .dout({ex4_floges,
             ex4_fexptes})
   );
   //---------------------------------------------------------------------


   tri_rlmreg_p #( .WIDTH(20), .NEEDS_SRESET(0)) ex4_gst_stage_lat(
      .force_t(force_t),		//d_mode           => tiup,       delay_lclkr      => tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),
      .mpw1_b(mpw1_b[3]),
      .mpw2_b(mpw2_b[0]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(ex3_act),
      //-----------------
      .scout(ex4_gst_stage_lat_scout),
      .scin(ex4_gst_stage_lat_scin),
      //-----------------
      .din({ex3_mantissa_din,
            ex3_b_sign}),
      //-----------------
      .dout({ex4_mantissa_precomp,
             ex4_b_sign})
   );

   //---------------------------------------------------------------------
   //---------------------------------------------------------------------
   //---------------------------------------------------------------------

   assign ex4_mantissa_precomp_b = (~ex4_mantissa_precomp[1:19]);

   //---------------------------------------------------------------------

   fu_gst_inc19 ex4_log_inc(
      .a(ex4_mantissa_precomp_b[1:19]),
      //------------------------------------------------------
      .o(ex4_mantissa_neg[1:19])
   );
   //---------------------------------------------------------------------

   assign ex4_negate = (ex4_mantissa_precomp[1] & ex4_floges) |
                       (ex4_fexptes &            ex4_b_sign);

   assign ex4_mantissa[1:19] = (ex4_mantissa_neg[1:19] &    {19{ex4_negate}}) |
                         (ex4_mantissa_precomp[1:19] &    {19{(~ex4_negate)}});

   //---------------------------------------------------------------------

   fu_gst_loa ex4_log_loa(
      .a(ex4_mantissa),
      //------------------------------------------------------
      .shamt(ex4_shamt[0:4])
   );
   //---------------------------------------------------------------------

   assign ex4_logof1_specialcase = (~|(ex4_shamt[0:4]));

   //---------------------------------------------------------------------

   tri_rlmreg_p #( .WIDTH(4), .NEEDS_SRESET(0)) ex5_gst_ctrl_lat(
      .force_t(force_t),		//d_mode           => tiup,       delay_lclkr      => tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),
      .mpw1_b(mpw1_b[4]),
      .mpw2_b(mpw2_b[0]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(ex4_act),
      //-----------------
      .scout(ex5_gst_ctrl_lat_scout),
      .scin(ex5_gst_ctrl_lat_scin),
      //-----------------
      .din({ex4_floges,
            ex4_fexptes,
            ex4_negate,
            ex4_logof1_specialcase}),
      //-----------------
      .dout({ex5_floges,
            ex5_fexptes,
            ex5_negate,
            ex5_logof1_specialcase})
   );


   tri_rlmreg_p #( .WIDTH(24), .NEEDS_SRESET(0)) ex5_gst_stage_lat(
      .force_t(force_t),		//d_mode           => tiup,       delay_lclkr      => tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),
      .mpw1_b(mpw1_b[4]),
      .mpw2_b(mpw2_b[0]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(ex4_act),
      //-----------------
      .scout(ex5_gst_stage_lat_scout),
      .scin(ex5_gst_stage_lat_scin),
      //-----------------
      .din({ex4_mantissa,
            ex4_shamt}),
      //-----------------
      .dout({ex5_mantissa,
             ex5_shamt})
   );
   //---------------------------------------------------------------------
   //---------------------------------------------------------------------
   //---------------------------------------------------------------------

   // shift mantissa for log (shamt is set to zeros for exp)
   // log mantissa gets normalized here

   assign ex5_mantissa_shlev0[01:19] = ex5_mantissa[01:19];

   assign l1_enc00 = (~ex5_shamt[3]) & (~ex5_shamt[4]);
   assign l1_enc01 = (~ex5_shamt[3]) & ex5_shamt[4];
   assign l1_enc10 = ex5_shamt[3] & (~ex5_shamt[4]);
   assign l1_enc11 = ex5_shamt[3] & ex5_shamt[4];

   assign l2_enc00 = (~ex5_shamt[1]) & (~ex5_shamt[2]);
   assign l2_enc01 = (~ex5_shamt[1]) & ex5_shamt[2];
   assign l2_enc10 = ex5_shamt[1] & (~ex5_shamt[2]);
   assign l2_enc11 = ex5_shamt[1] & ex5_shamt[2];

   assign l3_enc00 = (~ex5_shamt[0]);
   assign l3_enc01 = ex5_shamt[0];

   assign ex5_mantissa_shlev1[01:22] = ({zeros[01:03], (ex5_mantissa_shlev0[01:19])} &                   {22{l1_enc00}}) |
                                       ({zeros[01:02], ({ex5_mantissa_shlev0[01:19], zeros[01]})} &      {22{l1_enc01}}) |
                                       ({zeros[01], ({ex5_mantissa_shlev0[01:19], zeros[01:02]})} &      {22{l1_enc10}}) |
                                       (({ex5_mantissa_shlev0[01:19], zeros[01:03]}) &                   {22{l1_enc11}});

   assign ex5_mantissa_shlev2[01:34] = ({zeros[01:12], (ex5_mantissa_shlev1[01:22])} &                   {34{l2_enc00}}) |
                                       ({zeros[01:08], ({ex5_mantissa_shlev1[01:22], zeros[01:04]})} &   {34{l2_enc01}}) |
                                       ({zeros[01:04], ({ex5_mantissa_shlev1[01:22], zeros[01:08]})} &   {34{l2_enc10}}) |
                                       (({ex5_mantissa_shlev1[01:22], zeros[01:12]}) &                   {34{l2_enc11}});

   assign ex5_mantissa_shlev3[01:50] = ({zeros[01:16], (ex5_mantissa_shlev2[01:34])} & {50{l3_enc00}}) |
                                       (({ex5_mantissa_shlev2[01:34], zeros[01:16]}) & {50{l3_enc01}});

   assign ex5_log_mantissa_postsh[01:19] = ex5_mantissa_shlev3[32:50];

   //----------------------------------------------------------------------------------------------------------------------
   // pow fract logic

   assign ex5_f[1:11] = ex5_mantissa[9:19];
   // ************************************
   // ** vexptefp fract logic
   // ************************************

   assign eb1 = ex5_f[1];
   assign eb2 = ex5_f[2];
   assign eb3 = ex5_f[3];
   assign eb4 = ex5_f[4];
   assign eb5 = ex5_f[5];
   assign eb6 = ex5_f[6];
   assign eb7 = ex5_f[7];
   assign eb8 = ex5_f[8];
   assign eb9 = ex5_f[9];
   assign eb10 = ex5_f[10];

   assign ex5_f_b[1:11] = (~ex5_f[1:11]);

   //0000 ^s2
   //0001 ^s2
   //0010 ^s2
   //0011 ^s2
   //0100 ^s3
   //0101 ^s3
   //0110 ^s3
   //0111  --
   //1000  --
   //1001  --
   //1010  s3
   //1011  s3
   //1100  s3
   //1101  s2
   //1110  s2
   //1111  s1

   assign es2_0 = ((~eb1) & (~eb2));		//0,1,2,3
   //4,5
   assign es3_0 = ((~eb1) & eb2 & (~eb3)) | ((~eb1) & eb2 & eb3 & (~eb4));		//6
   //7
   assign esx = ((~eb1) & eb2 & eb3 & eb4) | (eb1 & (~eb2) & (~eb3));		//8,9
   //10,11
   assign es3_1 = (eb1 & (~eb2) & eb3) | (eb1 & eb2 & (~eb3) & (~eb4));		//12
   //13
   assign es2_1 = (eb1 & eb2 & (~eb3) & eb4) | (eb1 & eb2 & eb3 & (~eb4));		//14
   assign es1 = (eb1 & eb2 & eb3 & eb4);		//15

   assign es2 = es2_0 | es2_1;
   assign es3 = es3_0 | es3_1;

   assign ec4 = esx;
   assign ec5 = es3_0 | es3_1;
   assign ec6 = esx | es2_1;
   assign ec7 = esx | es3_1;

   //--------------------------------------------------------------------
   // mathematically eliminate the 3:2 compressor <passes verity>
   //--------------------------------------------------------------------
   //<BIT 4>
   //      f1234  |  3:2 inputs (f,c,a)  | 3:2 carry  : sum
   //             |                      |
   // s2_0  0000  | f4    "0"   f2       |  !f4.f2      f4^f2
   // s2_0  0001  | f4    "0"   f2       |  !f4.f2      f4^f2
   // s2_0  0010  | f4    "0"   f2       |  !f4.f2      f4^f2
   // s2_0  0011  | f4    "0"   f2       |  !f4.f2      f4^f2
   //             |                      |
   // s3_0  0100  | f4    "0"  "0"       |   "0"        f4
   // s3_0  0101  | f4    "0"  "0"       |   "0"        f4
   // s3_0  0110  | f4    "0"  "0"       |   "0"        f4
   //             |                      |
   // sx    0111  | f4    "1"  "0"       |  !f4        !f4
   // sx    1000  | f4    "1"  "0"       |  !f4        !f4
   // sx    1001  | f4    "1"  "0"       |  !f4        !f4
   //             |                      |
   // s3_1  1010  | f4    "0"  "0"       |   "0"        f4
   // s3_1  1011  | f4    "0"  "0"       |   "0"        f4
   // s3_1  1100  | f4    "0"  "0"       |   "0"        f4
   //             |                      |
   // s2_1  1101  | f4    "0"  !f2       |  !f4.!f2     f4^!f2
   // s2_1  1110  | f4    "0"  !f2       |  !f4.!f2     f4^!f2
   //             |                      |
   // s1    1111  | f4    "0"  !f3       |  !f4.!f3     f4^!f3
   //---------------------

   assign ec3_if_s20 = (~eb4) & eb2;
   assign ec3_if_s30 = tidn;
   assign ec3_if_sx = (~eb4);
   assign ec3_if_s31 = tidn;
   assign ec3_if_s21 = (~eb4) & (~eb2);
   assign ec3_if_s1 = (~eb4) & (~eb3);

   assign es4_if_s20 = (~eb4) ^ eb2;
   assign es4_if_s30 = (~eb4);
   assign es4_if_sx = eb4;
   assign es4_if_s31 = (~eb4);
   assign es4_if_s21 = (~eb4) ^ (~eb2);
   assign es4_if_s1 = (~eb4) ^ (~eb3);

   assign ec4_if_s20 = (~eb5) & eb3;
   assign ec4_if_s30 = (~eb5) | eb2;
   assign ec4_if_sx = tidn;
   assign ec4_if_s31 = (~eb5) | (~eb2);
   assign ec4_if_s21 = (~eb5) & (~eb3);
   assign ec4_if_s1 = (~eb5) & (~eb4);

   assign es5_if_s20 = (~eb5) ^ eb3;
   assign es5_if_s30 = (~eb5) ^ (~eb2);
   assign es5_if_sx = (~eb5);
   assign es5_if_s31 = (~eb5) ^ eb2;
   assign es5_if_s21 = (~eb5) ^ (~eb3);
   assign es5_if_s1 = (~eb5) ^ (~eb4);

   assign ec5_if_s20 = (~eb6) & eb4;
   assign ec5_if_s30 = (~eb6) & eb3;
   assign ec5_if_sx = (~eb6);
   assign ec5_if_s31 = (~eb6) & (~eb3);
   assign ec5_if_s21 = (~eb6) | (~eb4);
   assign ec5_if_s1 = (~eb6) & (~eb5);

   assign es6_if_s20 = (~eb6) ^ eb4;
   assign es6_if_s30 = (~eb6) ^ eb3;
   assign es6_if_sx = eb6;
   assign es6_if_s31 = (~eb6) ^ (~eb3);
   assign es6_if_s21 = (~eb6) ^ eb4;
   assign es6_if_s1 = (~eb6) ^ (~eb5);

   assign ec6_if_s20 = (~eb7) & eb5;
   assign ec6_if_s30 = (~eb7) & eb4;
   assign ec6_if_sx = (~eb7);
   assign ec6_if_s31 = (~eb7) | (~eb4);
   assign ec6_if_s21 = (~eb7) & (~eb5);
   assign ec6_if_s1 = (~eb7) & (~eb6);

   assign es7_if_s20 = (~eb7) ^ eb5;
   assign es7_if_s30 = (~eb7) ^ eb4;
   assign es7_if_sx = eb7;
   assign es7_if_s31 = (~eb7) ^ eb4;
   assign es7_if_s21 = (~eb7) ^ (~eb5);
   assign es7_if_s1 = (~eb7) ^ (~eb6);

   assign ea4 = (es1 & (~eb3)) | (es2_0 & eb2) | (es2_1 & (~eb2));

   assign ea5 = (es1 & (~eb4)) | (es2_0 & eb3) | (es2_1 & (~eb3)) | (es3_0 & eb2) | (es3_1 & (~eb2));

   assign ea6 = (es1 & (~eb5)) | (es2_0 & eb4) | (es2_1 & (~eb4)) | (es3_0 & eb3) | (es3_1 & (~eb3));

   assign ea7 = (es1 & (~eb6)) | (es2_0 & eb5) | (es2_1 & (~eb5)) | (es3_0 & eb4) | (es3_1 & (~eb4));

   assign ea8 = (es1 & (~eb7)) | (es2_0 & eb6) | (es2_1 & (~eb6)) | (es3_0 & eb5) | (es3_1 & (~eb5));

   assign ea9 = (es1 & (~eb8)) | (es2_0 & eb7) | (es2_1 & (~eb7)) | (es3_0 & eb6) | (es3_1 & (~eb6));

   assign ea10 = (es1 & (~eb9)) | (es2_0 & eb8) | (es2_1 & (~eb8)) | (es3_0 & eb7) | (es3_1 & (~eb7));

   assign ea11 = (es1 & (~eb10)) | (es2_0 & eb9) | (es2_1 & (~eb9)) | (es3_0 & eb8) | (es3_1 & (~eb8));

   //------------------------------------------------------------------------------

   assign ex5_ea[4:11] = {ea4, ea5, ea6, ea7, ea8, ea9, ea10, ea11};
   assign ex5_ec[4:11] = {ec4, ec5, ec6, ec7, zeros[1:4]};

   assign ex5_addend1[1:11] = ex5_f_b[1:11];
   assign ex5_addend2[1:11] = {zeros[1:3], ex5_ea[4:11]};
   assign ex5_addend3[1:11] = {zeros[1:3], ex5_ec[4:11]};

   assign ex5_fsum[1] = ex5_f_b[1];
   assign ex5_fsum[2] = ex5_f_b[2];
   assign ex5_fsum[3] = ex5_f_b[3];
   assign ex5_fsum[4] = (es1 & es4_if_s1) | (es2_0 & es4_if_s20) | (es3_0 & es4_if_s30) | (esx & es4_if_sx) | (es3_1 & es4_if_s31) | (es2_1 & es4_if_s21);
   assign ex5_fsum[5] = (es1 & es5_if_s1) | (es2_0 & es5_if_s20) | (es3_0 & es5_if_s30) | (esx & es5_if_sx) | (es3_1 & es5_if_s31) | (es2_1 & es5_if_s21);
   assign ex5_fsum[6] = (es1 & es6_if_s1) | (es2_0 & es6_if_s20) | (es3_0 & es6_if_s30) | (esx & es6_if_sx) | (es3_1 & es6_if_s31) | (es2_1 & es6_if_s21);
   assign ex5_fsum[7] = (es1 & es7_if_s1) | (es2_0 & es7_if_s20) | (es3_0 & es7_if_s30) | (esx & es7_if_sx) | (es3_1 & es7_if_s31) | (es2_1 & es7_if_s21);
   assign ex5_fsum[8] = ex5_f_b[8];
   assign ex5_fsum[9] = ex5_f_b[9];
   assign ex5_fsum[10] = ex5_f_b[10];
   assign ex5_fsum[11] = ex5_f_b[11];

   assign ex5_fcarryin[1] = tidn;
   assign ex5_fcarryin[2] = tidn;
   assign ex5_fcarryin[3] = (es1 & ec3_if_s1) | (es2_0 & ec3_if_s20) | (es3_0 & ec3_if_s30) | (esx & ec3_if_sx) | (es3_1 & ec3_if_s31) | (es2_1 & ec3_if_s21);
   assign ex5_fcarryin[4] = (es1 & ec4_if_s1) | (es2_0 & ec4_if_s20) | (es3_0 & ec4_if_s30) | (esx & ec4_if_sx) | (es3_1 & ec4_if_s31) | (es2_1 & ec4_if_s21);
   assign ex5_fcarryin[5] = (es1 & ec5_if_s1) | (es2_0 & ec5_if_s20) | (es3_0 & ec5_if_s30) | (esx & ec5_if_sx) | (es3_1 & ec5_if_s31) | (es2_1 & ec5_if_s21);
   assign ex5_fcarryin[6] = (es1 & ec6_if_s1) | (es2_0 & ec6_if_s20) | (es3_0 & ec6_if_s30) | (esx & ec6_if_sx) | (es3_1 & ec6_if_s31) | (es2_1 & ec6_if_s21);
   assign ex5_fcarryin[7] = tidn;
   assign ex5_fcarryin[8] = ea8;
   assign ex5_fcarryin[9] = ea9;
   assign ex5_fcarryin[10] = ea10;
   assign ex5_fcarryin[11] = ea11;

   assign ex5_powf_a_addend_b = (~ex5_fsum[1:11]);
   assign ex5_powf_b_addend_b = (~(ex5_fcarryin[1:11]));


   fu_gst_add11 ex5_powfractadd11(
      .a_b(ex5_powf_a_addend_b),
      .b_b(ex5_powf_b_addend_b),
      //------------------------------------------------------
      .s0(ex5_pow_fract_b)
   );

   assign ex5_pow_fract = (~ex5_pow_fract_b);

   //----------------------------------------------------------------------------------------------------------------------
   // not (dp bias +9)
   assign ex5_log_dp_bias = (11'b01111110111 & {11{(~ex5_logof1_specialcase)}}) |
                            (11'b11111111101 & {11{ex5_logof1_specialcase}});		// results in exp of 000..1, which is zero

   assign ex5_log_a_addend_b[1:11] = {zeros[1:6], ex5_shamt[0:4]};
   assign ex5_log_b_addend_b[1:11] = ex5_log_dp_bias;

   assign ex5_pow_a_addend_b[1:11] = (~({ex5_mantissa[1], ex5_mantissa[1], ex5_mantissa[1], ex5_mantissa[1:8]}));
   assign ex5_pow_b_addend_b[1:11] = 11'b10000000000;		// dp bias

   assign ex5_exponent_a_addend_b = (ex5_log_a_addend_b & {11{ex5_floges}}) |
                                    (ex5_pow_a_addend_b & {11{ex5_fexptes}});

   assign ex5_exponent_b_addend_b = (ex5_log_b_addend_b & {11{ex5_floges}}) |
                                    (ex5_pow_b_addend_b & {11{ex5_fexptes}});

   //---------------------------------------------------------------------


   fu_gst_add11 ex5_explogadd11(
      .a_b(ex5_exponent_a_addend_b),
      .b_b(ex5_exponent_b_addend_b),
      //------------------------------------------------------
      .s0(ex5_biased_exponent_result)
   );
   //---------------------------------------------------------------------

   assign ex5_log_fract = ex5_log_mantissa_postsh[01:19];
   assign ex5_log_signbit = ex5_negate;

   assign ex5_signbit_din = ex5_log_signbit & ex5_floges;

   assign ex5_fract_din = (({((~ex5_logof1_specialcase)), ex5_log_fract[1:19]}) & {20{ex5_floges}}) |
                          (({tiup, ex5_pow_fract[1:11], zeros[1:8]})            & {20{ex5_fexptes}});

   //---------------------------------------------------------------------
   //---------------------------------------------------------------------
   //---------------------------------------------------------------------

   tri_rlmreg_p #( .WIDTH(2), .NEEDS_SRESET(0)) ex6_gst_ctrl_lat(
      .force_t(force_t),		//d_mode           => tiup,       delay_lclkr      => tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[5]),
      .mpw1_b(mpw1_b[5]),
      .mpw2_b(mpw2_b[1]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(ex5_act),
      //-----------------
      .scout(ex6_gst_ctrl_lat_scout),
      .scin(ex6_gst_ctrl_lat_scin),
      //-----------------
      .din({ex5_floges,
            ex5_fexptes}),
      //-----------------
      .dout({ex6_floges,
             ex6_fexptes})
   );


   tri_rlmreg_p #( .WIDTH(32), .NEEDS_SRESET(0)) ex6_gst_stage_lat(
      .force_t(force_t),		//d_mode           => tiup,       delay_lclkr      => tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[5]),
      .mpw1_b(mpw1_b[5]),
      .mpw2_b(mpw2_b[1]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(ex5_act),
      //-----------------
      .scout(ex6_gst_stage_lat_scout),
      .scin(ex6_gst_stage_lat_scin),
      //-----------------
      .din({ex5_signbit_din,
            ex5_biased_exponent_result,
            ex5_fract_din}),
      //-----------------
      .dout({ex6_signbit,
             ex6_biased_exponent_result,
             ex6_fract})
   );

   //---------------------------------------------------------------------
   //---------------------------------------------------------------------
   //---------------------------------------------------------------------

   assign f_gst_ex6_logexp_sign = ex6_signbit;
   assign f_gst_ex6_logexp_exp = ex6_biased_exponent_result;
   assign f_gst_ex6_logexp_fract = ex6_fract;
   assign f_gst_ex6_logexp_v = ex6_floges | ex6_fexptes;

   // todo:  clk gating with acts, gate with log,exp instr decodes, fpu enable, etc

   assign ex3_gst_ctrl_lat_scin[0:1] = {f_gst_si, ex3_gst_ctrl_lat_scout[0]};
   assign ex4_gst_ctrl_lat_scin[0:1] = {ex3_gst_ctrl_lat_scout[1], ex4_gst_ctrl_lat_scout[0]};
   assign ex5_gst_ctrl_lat_scin[0:3] = {ex4_gst_ctrl_lat_scout[1], ex5_gst_ctrl_lat_scout[0:2]};
   assign ex6_gst_ctrl_lat_scin[0:1] = {ex5_gst_ctrl_lat_scout[3], ex6_gst_ctrl_lat_scout[0]};
   assign ex3_gst_stage_lat_scin[0:32] = {ex6_gst_ctrl_lat_scout[1], ex3_gst_stage_lat_scout[0:31]};
   assign ex4_gst_stage_lat_scin[0:19] = {ex3_gst_stage_lat_scout[32], ex4_gst_stage_lat_scout[0:18]};
   assign ex5_gst_stage_lat_scin[0:23] = {ex4_gst_stage_lat_scout[19], ex5_gst_stage_lat_scout[0:22]};
   assign ex6_gst_stage_lat_scin[0:31] = {ex5_gst_stage_lat_scout[23], ex6_gst_stage_lat_scout[0:30]};

   assign act_si[0:7] = {act_so[1:7], ex6_gst_stage_lat_scout[31]};

   assign f_gst_so = act_so[0];

endmodule
