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

module fu_alg(
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
   f_alg_si,
   f_alg_so,
   ex1_act,
   ex2_act,
   f_byp_alg_ex2_b_expo,
   f_byp_alg_ex2_a_expo,
   f_byp_alg_ex2_c_expo,
   f_byp_alg_ex2_b_frac,
   f_byp_alg_ex2_b_sign,
   f_fmt_ex2_prod_zero,
   f_fmt_ex2_b_zero,
   f_fmt_ex2_pass_sel,
   f_fmt_ex3_pass_frac,
   f_dcd_ex1_sp,
   f_dcd_ex1_from_integer_b,
   f_dcd_ex1_to_integer_b,
   f_dcd_ex1_word_b,
   f_dcd_ex1_uns_b,
   f_pic_ex2_rnd_to_int,
   f_pic_ex2_frsp_ue1,
   f_pic_ex2_effsub_raw,
   f_pic_ex2_sh_unf_ig_b,
   f_pic_ex2_sh_unf_do,
   f_pic_ex2_sh_ovf_ig_b,
   f_pic_ex2_sh_ovf_do,
   f_pic_ex3_rnd_nr,
   f_pic_ex3_rnd_inf_ok,
   f_alg_ex2_sign_frmw,
   f_alg_ex3_byp_nonflip,
   f_alg_ex3_res,
   f_alg_ex3_sel_byp,
   f_alg_ex3_effsub_eac_b,
   f_alg_ex3_prod_z,
   f_alg_ex3_sh_unf,
   f_alg_ex3_sh_ovf,
   f_alg_ex4_frc_sel_p1,
   f_alg_ex4_sticky,
   f_alg_ex4_int_fr,
   f_alg_ex4_int_fi
);
//   parameter      expand_type = 2;		// 0 - ibm tech, 1 - other );
   inout          vdd;
   inout          gnd;
   input          clkoff_b;		// tiup
   input          act_dis;		// ??tidn??
   input          flush;		// ??tidn??
   input [1:3]    delay_lclkr;		// tidn,
   input [1:3]    mpw1_b;		// tidn,
   input [0:0]    mpw2_b;		// tidn,
   input          sg_1;
   input          thold_1;
   input          fpu_enable;		//dc_act
   input          [0:`NCLK_WIDTH-1] nclk;

   input          f_alg_si;		//perv
   output         f_alg_so;		//perv
   input          ex1_act;		//act
   input          ex2_act;		//act

   input [1:13]   f_byp_alg_ex2_b_expo;
   input [1:13]   f_byp_alg_ex2_a_expo;
   input [1:13]   f_byp_alg_ex2_c_expo;
   input [0:52]   f_byp_alg_ex2_b_frac;
   input          f_byp_alg_ex2_b_sign;

   input          f_fmt_ex2_prod_zero;		// valid and Zero (Madd/Mul)
   input          f_fmt_ex2_b_zero;		// valid and zero (could be denorm, so zero out B)
   input          f_fmt_ex2_pass_sel;
   input [0:52]   f_fmt_ex3_pass_frac;

   input          f_dcd_ex1_sp;
   input          f_dcd_ex1_from_integer_b;		// K, spec, round
   input          f_dcd_ex1_to_integer_b;		// K, spec, round
   input          f_dcd_ex1_word_b;
   input          f_dcd_ex1_uns_b;

   input          f_pic_ex2_rnd_to_int;
   input          f_pic_ex2_frsp_ue1;		// K, spec, round
   input          f_pic_ex2_effsub_raw;		//
   input          f_pic_ex2_sh_unf_ig_b;		// fcfid
   input          f_pic_ex2_sh_unf_do;		// (do not know why want this)
   input          f_pic_ex2_sh_ovf_ig_b;		// fcfid
   input          f_pic_ex2_sh_ovf_do;		// fsel, fpscr, fmr,
   input          f_pic_ex3_rnd_nr;		//
   input          f_pic_ex3_rnd_inf_ok;		// pi/pos, ni/neg

   output         f_alg_ex2_sign_frmw;		// sign bit for from_integer_word_signed
   output         f_alg_ex3_byp_nonflip;
   output [0:162] f_alg_ex3_res;		//sad3/add
   output         f_alg_ex3_sel_byp;		// all eac selects off
   output         f_alg_ex3_effsub_eac_b;		// includes cancelations
   output         f_alg_ex3_prod_z;
   output         f_alg_ex3_sh_unf;		// f_pic
   output         f_alg_ex3_sh_ovf;		// f_pic
   output         f_alg_ex4_frc_sel_p1;		// rounding converts
   output         f_alg_ex4_sticky;		// part of eac control
   output         f_alg_ex4_int_fr;		// f_pic
   output         f_alg_ex4_int_fi;		// f_pic


   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;

   wire           thold_0_b;
   wire           thold_0;
   wire           force_t;
   wire           sg_0;

   wire           ex3_act;

   (* analysis_not_referenced="TRUE" *) // unused
   wire [0:3]     spare_unused;
   //--------------------------------------
   wire [0:4]     act_so;		//SCAN
   wire [0:4]     act_si;		//SCAN
   wire [0:4]     ex2_ctl_so;		//SCAN
   wire [0:4]     ex2_ctl_si;		//SCAN
   wire [0:67]    ex3_shd_so;		//SCAN
   wire [0:67]    ex3_shd_si;
   wire [0:24]    ex3_shc_so;		//SCAN
   wire [0:24]    ex3_shc_si;
   wire [0:14]    ex3_ctl_so;		//SCAN
   wire [0:14]    ex3_ctl_si;		//SCAN
   wire [0:10]    ex4_ctl_so;		//SCAN
   wire [0:10]    ex4_ctl_si;		//SCAN
   //--------------------------------------
   wire           ex2_from_integer;
   wire           ex3_from_integer;
   wire           ex2_to_integer;
   wire           ex2_sel_special;
   wire           ex2_sel_special_b;
   wire           ex3_sel_special_b;
   wire           ex2_sh_ovf;
   wire           ex2_sh_unf_x;
   wire           ex3_sh_unf_x;
   wire           ex2_sel_byp_nonflip;
   wire           ex2_sel_byp_nonflip_lze;
   wire           ex2_from_integer_neg;
   wire           ex2_integer_op;
   wire           ex2_to_integer_neg;
   wire           ex2_negate;
   wire           ex2_effsub_alg;
   wire           ex3_sh_unf;
   wire           ex3_sel_byp;
   wire           ex3_effsub_alg;
   wire           ex3_prd_sel_pos_hi;
   wire           ex3_prd_sel_neg_hi;
   wire           ex3_prd_sel_pos_lo;
   wire           ex3_prd_sel_neg_lo;
   wire           ex3_prd_sel_pos_lohi;
   wire           ex3_prd_sel_neg_lohi;
   wire           ex3_byp_sel_pos;
   wire           ex3_byp_sel_neg;
   wire           ex3_byp_sel_byp_pos;
   wire           ex3_byp_sel_byp_neg;
   wire           ex3_b_sign;
   wire           ex3_to_integer;
   wire [0:67]    ex2_sh_lvl2;
   wire [0:67]    ex3_sh_lvl2;
   wire [0:67]    ex3_sh_lvl2_b;
   wire [6:9]     ex3_bsha;
   wire [0:4]     ex3_sticky_en16_x;
   wire           ex3_xthrm_6_ns_b;
   wire           ex3_xthrm_7_ns_b;
   wire           ex3_xthrm_8_b;
   wire           ex3_xthrm_8a9_b;
   wire           ex3_xthrm_8o9_b;
   wire           ex3_xthrm7o8a9;
   wire           ex3_xthrm7o8;
   wire           ex3_xthrm7o8o9;
   wire           ex3_xthrm7a8a9;
   wire           ex3_xthrm_6_ns;
   wire           ex3_ge176_b;
   wire           ex3_ge160_b;
   wire           ex3_ge144_b;
   wire           ex3_ge128_b;
   wire           ex3_ge112_b;
   wire           ex2_bsha_6;
   wire           ex2_bsha_7;
   wire           ex2_bsha_8;
   wire           ex2_bsha_9;
   wire           ex3_bsha_pos;
   wire [0:162]   ex3_sh_lvl3;
   wire [0:4]     ex3_sticky_or16;
   wire           ex2_b_zero;
   wire           ex3_b_zero;
   wire           ex3_b_zero_b;

   wire           ex2_dp;

   wire           ex3_byp_nonflip_lze;
   wire           ex3_sel_byp_nonflip;
   wire           ex3_prod_zero;
   wire           ex3_sh_ovf_en;
   wire           ex3_sh_unf_en;
   wire           ex3_sh_unf_do;
   wire           ex3_sh_ovf;
   wire           ex3_integer_op;
   wire           ex3_negate;
   wire           ex3_unf_bz;
   wire           ex3_all1_x;
   wire           ex3_ovf_pz;
   wire           ex3_all1_y;
   wire           ex3_sel_special;
   wire           ex1_from_integer;
   wire           ex1_to_integer;
   wire           ex1_dp;
   wire           ex1_uns;
   wire           ex1_word;
   wire           ex2_uns;
   wire           ex2_word;
   wire           ex2_word_from;
   wire           ex3_word_from;
   wire           ex3_rnd_to_int;
   wire           ex2_sign_from;
   wire [0:52]    ex2_b_frac;
   wire [1:13]    ex2_b_expo;
   wire           ex2_b_sign;
   wire           ex2_bsha_neg;
   wire           ex3_bsha_neg;

   wire           ex2_lvl1_shdcd000_b;
   wire           ex2_lvl1_shdcd001_b;
   wire           ex2_lvl1_shdcd002_b;
   wire           ex2_lvl1_shdcd003_b;
   wire           ex2_lvl2_shdcd000;
   wire           ex2_lvl2_shdcd004;
   wire           ex2_lvl2_shdcd008;
   wire           ex2_lvl2_shdcd012;
   wire           ex2_lvl3_shdcd000;
   wire           ex2_lvl3_shdcd016;
   wire           ex2_lvl3_shdcd032;
   wire           ex2_lvl3_shdcd048;
   wire           ex2_lvl3_shdcd064;
   wire           ex2_lvl3_shdcd080;
   wire           ex2_lvl3_shdcd096;
   wire           ex2_lvl3_shdcd112;
   wire           ex2_lvl3_shdcd128;
   wire           ex2_lvl3_shdcd144;
   wire           ex2_lvl3_shdcd160;
   wire           ex2_lvl3_shdcd176;
   wire           ex2_lvl3_shdcd192;		// -64
   wire           ex2_lvl3_shdcd208;		// -48
   wire           ex2_lvl3_shdcd224;		// -32
   wire           ex2_lvl3_shdcd240;		// -16

   wire           ex3_lvl3_shdcd000;
   wire           ex3_lvl3_shdcd016;
   wire           ex3_lvl3_shdcd032;
   wire           ex3_lvl3_shdcd048;
   wire           ex3_lvl3_shdcd064;
   wire           ex3_lvl3_shdcd080;
   wire           ex3_lvl3_shdcd096;
   wire           ex3_lvl3_shdcd112;
   wire           ex3_lvl3_shdcd128;
   wire           ex3_lvl3_shdcd144;
   wire           ex3_lvl3_shdcd160;
   wire           ex3_lvl3_shdcd176;
   wire           ex3_lvl3_shdcd192;
   wire           ex3_lvl3_shdcd208;
   wire           ex3_lvl3_shdcd224;
   wire           ex3_lvl3_shdcd240;

   wire           ex4_int_fr_nr1_b;
   wire           ex4_int_fr_nr2_b;
   wire           ex4_int_fr_ok_b;
   wire           ex4_int_fr;
   wire           ex4_sel_p1_0_b;
   wire           ex4_sel_p1_1_b;
   wire           ex4_sticky_math;
   wire           ex4_sticky_toint;
   wire           ex4_sticky_toint_nr;
   wire           ex4_sticky_toint_ok;
   wire           ex4_frmneg_o_toneg;
   wire           ex4_frmneg_o_topos;
   wire           ex4_lsb_toint_nr;
   wire           ex4_g_math;
   wire           ex4_g_toint;
   wire           ex4_g_toint_nr;
   wire           ex4_g_toint_ok;
   wire           ex3_frmneg;
   wire           ex3_toneg;
   wire           ex3_topos;
   wire           ex3_frmneg_o_toneg;
   wire           ex3_frmneg_o_topos;
   wire           ex3_toint_gate_x;
   wire           ex3_toint_gate_g;
   wire           ex3_toint_gt_nr_x;
   wire           ex3_toint_gt_nr_g;
   wire           ex3_toint_gt_ok_x;
   wire           ex3_toint_gt_ok_g;
   wire           ex3_math_gate_x;
   wire           ex3_math_gate_g;
   wire           ex3_sticky_eac_x;
   wire           ex3_sticky_math;
   wire           ex3_sticky_toint;
   wire           ex3_sticky_toint_nr;
   wire           ex3_sticky_toint_ok;
   wire           ex3_lsb_toint_nr;
   wire           ex3_g_math;
   wire           ex3_g_toint;
   wire           ex3_g_toint_nr;
   wire           ex3_g_toint_ok;
   wire           ex3_sh16_162;
   wire           ex3_sh16_163;
   wire           alg_ex3_d1clk;
   wire           alg_ex3_d2clk;

   wire [0:`NCLK_WIDTH-1]          alg_ex3_lclk;

   wire [6:9]     ex3_bsha_b;
   wire           ex3_bsha_neg_b;
   wire           ex3_sh_ovf_b;
   wire           ex3_sh_unf_x_b;
   wire           ex3_lvl3_shdcd000_b;
   wire           ex3_lvl3_shdcd016_b;
   wire           ex3_lvl3_shdcd032_b;
   wire           ex3_lvl3_shdcd048_b;
   wire           ex3_lvl3_shdcd064_b;
   wire           ex3_lvl3_shdcd080_b;
   wire           ex3_lvl3_shdcd096_b;
   wire           ex3_lvl3_shdcd112_b;
   wire           ex3_lvl3_shdcd128_b;
   wire           ex3_lvl3_shdcd144_b;
   wire           ex3_lvl3_shdcd160_b;
   wire           ex3_lvl3_shdcd176_b;
   wire           ex3_lvl3_shdcd192_b;
   wire           ex3_lvl3_shdcd208_b;
   wire           ex3_lvl3_shdcd224_b;
   wire           ex3_lvl3_shdcd240_b;
   wire           ex3_b_zero_l2_b;
   wire           ex3_prod_zero_b;
   wire           ex3_byp_nonflip_lze_b;
   wire           ex3_sel_byp_nonflip_b;
   wire           ex3_sh_unf_do_b;
   wire           ex3_sh_unf_en_b;
   wire           ex3_sh_ovf_en_b;
   wire           ex3_effsub_alg_b;
   wire           ex3_negate_b;
   wire           ex3_b_sign_b;
   wire           ex3_to_integer_b;
   wire           ex3_from_integer_b;
   wire           ex3_rnd_to_int_b;
   wire           ex3_integer_op_b;
   wire           ex3_word_from_b;
   (* analysis_not_referenced="TRUE" *) // unused
   wire           unused;

   //==##############################################################
   //# map block attributes
   //==##############################################################

   assign unused = ex2_b_expo[1] | ex2_b_expo[2] | ex2_dp | ex3_lvl3_shdcd176;		//latch output
   // latch output

   assign ex2_b_frac[0:52] = f_byp_alg_ex2_b_frac[0:52];		//RENAME
   assign ex2_b_sign = f_byp_alg_ex2_b_sign;		//RENAME
   assign ex2_b_expo[1:13] = f_byp_alg_ex2_b_expo[1:13];		//RENAME

   //==##############################################################
   //# pervasive
   //==##############################################################


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

   //==##############################################################
   //# act
   //==##############################################################



   tri_rlmreg_p #(.WIDTH(5),  .NEEDS_SRESET(0)) act_lat(
      .vd(vdd),
      .gd(gnd),
      .force_t(force_t),		//i-- tidn,
      .d_mode(tiup), //d_mode           => d_mode       ,--i-- tiup,
      .delay_lclkr(delay_lclkr[2]),		//i-- tidn,
      .mpw1_b(mpw1_b[2]),		//i-- tidn,
      .mpw2_b(mpw2_b[0]),		//i-- tidn,
      .nclk(nclk),
      .act(fpu_enable),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(act_so),
      .scin(act_si),
      //-----------------
      .din({  spare_unused[0],
              spare_unused[1],
              ex2_act,
              spare_unused[2],
              spare_unused[3]}),
      //-----------------
      .dout({ spare_unused[0],
              spare_unused[1],
              ex3_act,
              spare_unused[2],
              spare_unused[3]})
   );


   tri_lcbnd  alg_ex3_lcb(
      .delay_lclkr(delay_lclkr[2]),		// tidn ,--in
      .mpw1_b(mpw1_b[2]),		// tidn ,--in
      .mpw2_b(mpw2_b[0]),		// tidn ,--in
      .force_t(force_t),		// tidn ,--in
      .nclk(nclk),		//in
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .act(ex2_act),		//in
      .sg(sg_0),		//in
      .thold_b(thold_0_b),		//in
      .d1clk(alg_ex3_d1clk),		//out
      .d2clk(alg_ex3_d2clk),		//out
      .lclk(alg_ex3_lclk)		//out
   );

   //==##############################################################
   //# ex1 logic
   //==##############################################################

   //#-------------------------------------------------------------
   //# shift amount calculation :start with exponent difference
   //#-------------------------------------------------------------

   //==##############################################################
   //# ex2 latches (from ex1 logic)
   //==##############################################################

   assign ex1_from_integer = (~f_dcd_ex1_from_integer_b);
   assign ex1_to_integer = (~f_dcd_ex1_to_integer_b);
   assign ex1_dp = (~f_dcd_ex1_sp);
   assign ex1_word = (~f_dcd_ex1_word_b);
   assign ex1_uns = (~f_dcd_ex1_uns_b);


   tri_rlmreg_p #(.WIDTH(5),  .NEEDS_SRESET(0)) ex2_ctl_lat(
      .force_t(force_t),		//tidn,
      .d_mode(tiup), //d_mode           => d_mode       ,--tiup,
      .delay_lclkr(delay_lclkr[1]),		//tidn,
      .mpw1_b(mpw1_b[1]),		//tidn,
      .mpw2_b(mpw2_b[0]),		//tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex1_act),
      .scout(ex2_ctl_so),
      .scin(ex2_ctl_si),
      //---------------
      .din({ ex1_from_integer,
             ex1_to_integer,
             ex1_dp,
             ex1_word,
             ex1_uns}),
      //---------------
      .dout({ex2_from_integer,
             ex2_to_integer,
             ex2_dp,
             ex2_word,
             ex2_uns})
   );

   //==##############################################################
   //# ex2 logic
   //==##############################################################


   fu_alg_add  sha(
      .vdd(vdd),
      .gnd(gnd),
      .f_byp_alg_ex2_b_expo(f_byp_alg_ex2_b_expo),		//i--
      .f_byp_alg_ex2_a_expo(f_byp_alg_ex2_a_expo),		//i--
      .f_byp_alg_ex2_c_expo(f_byp_alg_ex2_c_expo),		//i--
      .ex2_sel_special_b(ex2_sel_special_b),		//i--
      .ex2_bsha_6_o(ex2_bsha_6),		//o--
      .ex2_bsha_7_o(ex2_bsha_7),		//o--
      .ex2_bsha_8_o(ex2_bsha_8),		//o--
      .ex2_bsha_9_o(ex2_bsha_9),		//o--
      .ex2_bsha_neg_o(ex2_bsha_neg),		//o--
      .ex2_sh_ovf(ex2_sh_ovf),		//o--
      .ex2_sh_unf_x(ex2_sh_unf_x),		//o--
      .ex2_lvl1_shdcd000_b(ex2_lvl1_shdcd000_b),		//o--
      .ex2_lvl1_shdcd001_b(ex2_lvl1_shdcd001_b),		//o--
      .ex2_lvl1_shdcd002_b(ex2_lvl1_shdcd002_b),		//o--
      .ex2_lvl1_shdcd003_b(ex2_lvl1_shdcd003_b),		//o--
      .ex2_lvl2_shdcd000(ex2_lvl2_shdcd000),		//o--
      .ex2_lvl2_shdcd004(ex2_lvl2_shdcd004),		//o--
      .ex2_lvl2_shdcd008(ex2_lvl2_shdcd008),		//o--
      .ex2_lvl2_shdcd012(ex2_lvl2_shdcd012),		//o--
      .ex2_lvl3_shdcd000(ex2_lvl3_shdcd000),		//o--
      .ex2_lvl3_shdcd016(ex2_lvl3_shdcd016),		//o--
      .ex2_lvl3_shdcd032(ex2_lvl3_shdcd032),		//o--
      .ex2_lvl3_shdcd048(ex2_lvl3_shdcd048),		//o--
      .ex2_lvl3_shdcd064(ex2_lvl3_shdcd064),		//o--
      .ex2_lvl3_shdcd080(ex2_lvl3_shdcd080),		//o--
      .ex2_lvl3_shdcd096(ex2_lvl3_shdcd096),		//o--
      .ex2_lvl3_shdcd112(ex2_lvl3_shdcd112),		//o--
      .ex2_lvl3_shdcd128(ex2_lvl3_shdcd128),		//o--
      .ex2_lvl3_shdcd144(ex2_lvl3_shdcd144),		//o--
      .ex2_lvl3_shdcd160(ex2_lvl3_shdcd160),		//o--
      .ex2_lvl3_shdcd176(ex2_lvl3_shdcd176),		//o--
      .ex2_lvl3_shdcd192(ex2_lvl3_shdcd192),		//o--
      .ex2_lvl3_shdcd208(ex2_lvl3_shdcd208),		//o--
      .ex2_lvl3_shdcd224(ex2_lvl3_shdcd224),		//o--
      .ex2_lvl3_shdcd240(ex2_lvl3_shdcd240)		//o--
   );

   assign ex2_sel_special = ex2_from_integer;
   assign ex2_sel_special_b = (~ex2_from_integer);

   //#-------------------------------------------------
   //# determine bypass selects, operand flip
   //#-------------------------------------------------

   ////----------------------------------
   //// ex2
   ////----------------------------------

   // nan pass
   assign ex2_sel_byp_nonflip_lze = (f_fmt_ex2_pass_sel) | (f_pic_ex2_sh_ovf_do);		// fsel, fpscr, fmr,

   // <<<< move all this stuff to ex3
   assign ex2_sel_byp_nonflip = (f_pic_ex2_frsp_ue1) | (f_fmt_ex2_pass_sel) | (f_pic_ex2_sh_ovf_do);		// nan pass
   // fsel, fpscr, fmr,

   assign ex2_integer_op = ex2_from_integer | (ex2_to_integer & (~f_pic_ex2_rnd_to_int));

   // the negate for from_integer should only catch the last 64 bits (because it is not sign extended)

   assign f_alg_ex2_sign_frmw = ex2_b_frac[21];		// output (for sign logic)

   assign ex2_sign_from = (ex2_from_integer & ex2_word & ex2_b_frac[21]) | (ex2_from_integer & (~ex2_word) & ex2_b_sign);		// 32 from left 52 - 31 = 21

   assign ex2_from_integer_neg = ex2_from_integer & ex2_sign_from & (~ex2_uns);

   assign ex2_word_from = ex2_word & ex2_from_integer;

   assign ex2_to_integer_neg = ex2_to_integer & ex2_b_sign & (~f_pic_ex2_rnd_to_int);

   assign ex2_negate = f_pic_ex2_effsub_raw | ex2_from_integer_neg | ex2_to_integer_neg;		// subtract op

   assign ex2_effsub_alg = f_pic_ex2_effsub_raw & (~f_fmt_ex2_pass_sel);

   assign ex2_b_zero = f_fmt_ex2_b_zero;

   // for sh_unf/b_zero effadd: alg_res = 00...00 (turn off all    selects)
   // for sh_unf/b_zero effsub: alg_res = 11...11 (turn on  pos/neg selects)
   //
   //                           0:52  53:54   55:98   99:163
   // to_int                      0     0       0     ssssss
   // from_int                    0     0       0     ssssss
   // bypass{nan,fmr}             d     0       ?     ??????
   // sh_ov
   // sh_unf
   // effadd
   // effsub

   //#---------------------------------------------------------------
   //# first 2 levels of shifting (1) 0/1/2/3  (2) 0/4/8/12
   //#---------------------------------------------------------------


   fu_alg_sh4  sh4(
      .ex2_lvl1_shdcd000_b(ex2_lvl1_shdcd000_b),		//i--
      .ex2_lvl1_shdcd001_b(ex2_lvl1_shdcd001_b),		//i--
      .ex2_lvl1_shdcd002_b(ex2_lvl1_shdcd002_b),		//i--
      .ex2_lvl1_shdcd003_b(ex2_lvl1_shdcd003_b),		//i--
      .ex2_lvl2_shdcd000(ex2_lvl2_shdcd000),		//i--
      .ex2_lvl2_shdcd004(ex2_lvl2_shdcd004),		//i--
      .ex2_lvl2_shdcd008(ex2_lvl2_shdcd008),		//i--
      .ex2_lvl2_shdcd012(ex2_lvl2_shdcd012),		//i--
      .ex2_sel_special(ex2_sel_special),		//i--
      .ex2_b_sign(ex2_b_sign),		//i--
      .ex2_b_expo(ex2_b_expo[3:13]),		//i--
      .ex2_b_frac(ex2_b_frac[0:52]),		//i--
      .ex2_sh_lvl2(ex2_sh_lvl2[0:67])		//o--
   );

   //==##############################################################
   //# ex3 latches  (from ex2 logic)
   //==##############################################################


   tri_inv_nlats #(.WIDTH(68),   .NEEDS_SRESET(0)) ex3_shd_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(alg_ex3_lclk),		// lclk.clk
      .d1clk(alg_ex3_d1clk),
      .d2clk(alg_ex3_d2clk),
      .scanin(ex3_shd_si),
      .scanout(ex3_shd_so),
      .d(ex2_sh_lvl2[0:67]),
      .qb(ex3_sh_lvl2_b[0:67])
   );

   assign ex3_sh_lvl2[0:67] = (~ex3_sh_lvl2_b[0:67]);


   tri_inv_nlats #(.WIDTH(25),  .NEEDS_SRESET(0)) ex3_shc_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(alg_ex3_lclk),		// lclk.clk
      .d1clk(alg_ex3_d1clk),
      .d2clk(alg_ex3_d2clk),
      .scanin(ex3_shc_si),
      .scanout(ex3_shc_so),
      //-----------------
      .d({ ex2_bsha_neg,
           ex2_sh_ovf,
           ex2_sh_unf_x,
           ex2_sel_special,
           ex2_sel_special_b,
           ex2_bsha_6,
           ex2_bsha_7,
           ex2_bsha_8,
           ex2_bsha_9,
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
           ex2_lvl3_shdcd240}),
      //--------------------
      .qb({ex3_bsha_neg_b,
           ex3_sh_ovf_b,
           ex3_sh_unf_x_b,
           ex3_sel_special_b,
           ex3_sel_special,
           ex3_bsha_b[6],
           ex3_bsha_b[7],
           ex3_bsha_b[8],
           ex3_bsha_b[9],
           ex3_lvl3_shdcd000_b,
           ex3_lvl3_shdcd016_b,
           ex3_lvl3_shdcd032_b,
           ex3_lvl3_shdcd048_b,
           ex3_lvl3_shdcd064_b,
           ex3_lvl3_shdcd080_b,
           ex3_lvl3_shdcd096_b,
           ex3_lvl3_shdcd112_b,
           ex3_lvl3_shdcd128_b,
           ex3_lvl3_shdcd144_b,
           ex3_lvl3_shdcd160_b,
           ex3_lvl3_shdcd176_b,
           ex3_lvl3_shdcd192_b,
           ex3_lvl3_shdcd208_b,
           ex3_lvl3_shdcd224_b,
           ex3_lvl3_shdcd240_b})
   );

   assign ex3_bsha_neg = (~ex3_bsha_neg_b);
   assign ex3_sh_ovf = (~ex3_sh_ovf_b);
   assign ex3_sh_unf_x = (~ex3_sh_unf_x_b);
   assign ex3_bsha[6] = (~ex3_bsha_b[6]);
   assign ex3_bsha[7] = (~ex3_bsha_b[7]);
   assign ex3_bsha[8] = (~ex3_bsha_b[8]);
   assign ex3_bsha[9] = (~ex3_bsha_b[9]);
   assign ex3_lvl3_shdcd000 = (~ex3_lvl3_shdcd000_b);
   assign ex3_lvl3_shdcd016 = (~ex3_lvl3_shdcd016_b);
   assign ex3_lvl3_shdcd032 = (~ex3_lvl3_shdcd032_b);
   assign ex3_lvl3_shdcd048 = (~ex3_lvl3_shdcd048_b);
   assign ex3_lvl3_shdcd064 = (~ex3_lvl3_shdcd064_b);
   assign ex3_lvl3_shdcd080 = (~ex3_lvl3_shdcd080_b);
   assign ex3_lvl3_shdcd096 = (~ex3_lvl3_shdcd096_b);
   assign ex3_lvl3_shdcd112 = (~ex3_lvl3_shdcd112_b);
   assign ex3_lvl3_shdcd128 = (~ex3_lvl3_shdcd128_b);
   assign ex3_lvl3_shdcd144 = (~ex3_lvl3_shdcd144_b);
   assign ex3_lvl3_shdcd160 = (~ex3_lvl3_shdcd160_b);
   assign ex3_lvl3_shdcd176 = (~ex3_lvl3_shdcd176_b);
   assign ex3_lvl3_shdcd192 = (~ex3_lvl3_shdcd192_b);
   assign ex3_lvl3_shdcd208 = (~ex3_lvl3_shdcd208_b);
   assign ex3_lvl3_shdcd224 = (~ex3_lvl3_shdcd224_b);
   assign ex3_lvl3_shdcd240 = (~ex3_lvl3_shdcd240_b);


   tri_inv_nlats #(.WIDTH(15),  .NEEDS_SRESET(0)) ex3_ctl_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(alg_ex3_lclk),		// lclk.clk
      .d1clk(alg_ex3_d1clk),
      .d2clk(alg_ex3_d2clk),
      .scanin(ex3_ctl_si),
      .scanout(ex3_ctl_so),
      //-----------------
      .d({  ex2_b_zero,
            f_fmt_ex2_prod_zero,
            ex2_sel_byp_nonflip_lze,
            ex2_sel_byp_nonflip,
            f_pic_ex2_sh_unf_do,
            f_pic_ex2_sh_unf_ig_b,
            f_pic_ex2_sh_ovf_ig_b,
            ex2_effsub_alg,
            ex2_negate,
            ex2_b_sign,
            ex2_to_integer,
            ex2_from_integer,
            f_pic_ex2_rnd_to_int,
            ex2_integer_op,
            ex2_word_from}),
      //-----------------
      .qb({ ex3_b_zero_l2_b,
            ex3_prod_zero_b,
            ex3_byp_nonflip_lze_b,
            ex3_sel_byp_nonflip_b,
            ex3_sh_unf_do_b,
            ex3_sh_unf_en_b,
            ex3_sh_ovf_en_b,
            ex3_effsub_alg_b,
            ex3_negate_b,
            ex3_b_sign_b,
            ex3_to_integer_b,
            ex3_from_integer_b,
            ex3_rnd_to_int_b,
            ex3_integer_op_b,
            ex3_word_from_b})
   );

   assign ex3_b_zero = (~ex3_b_zero_l2_b);
   assign ex3_prod_zero = (~ex3_prod_zero_b);
   assign ex3_byp_nonflip_lze = (~ex3_byp_nonflip_lze_b);
   assign ex3_sel_byp_nonflip = (~ex3_sel_byp_nonflip_b);
   assign ex3_sh_unf_do = (~ex3_sh_unf_do_b);
   assign ex3_sh_unf_en = (~ex3_sh_unf_en_b);
   assign ex3_sh_ovf_en = (~ex3_sh_ovf_en_b);
   assign ex3_effsub_alg = (~ex3_effsub_alg_b);
   assign ex3_negate = (~ex3_negate_b);
   assign ex3_b_sign = (~ex3_b_sign_b);
   assign ex3_to_integer = (~ex3_to_integer_b);
   assign ex3_from_integer = (~ex3_from_integer_b);
   assign ex3_rnd_to_int = (~ex3_rnd_to_int_b);
   assign ex3_integer_op = (~ex3_integer_op_b);
   assign ex3_word_from = (~ex3_word_from_b);

   //$$  sticky enable for 16 bit groups ------------------------
   //$$
   //$$ ex2_sticky_en16_x(0) <=
   //$$            (ex2_lvl3_shdcd176              ) or -- == 176
   //$$            (ex2_bsha( 6) and  ex2_bsha( 7) ) or -- >= 176
   //$$            (ex2_bsha( 6) and  ex2_bsha( 8) and  ex2_bsha( 9) ) ;  -- >= 176
   //$$ ex2_sticky_en16_x(1) <= ex2_sticky_en16_x(0) or  ex2_lvl3_shdcd160_x ;
   //$$ ex2_sticky_en16_x(2) <= ex2_sticky_en16_x(1) or  ex2_lvl3_shdcd144_x ;
   //$$ ex2_sticky_en16_x(3) <= ex2_sticky_en16_x(2) or  ex2_lvl3_shdcd128_x ;
   //$$ ex2_sticky_en16_x(4) <= ex2_sticky_en16_x(3) or  ex2_lvl3_shdcd112_x ;

   //------------------------------
   // Sticky Bit Thermometer
   //------------------------------
   //    bhsa(6789)
   // 176     1011   GE_176:  6 * (7 | (8*9) )
   // 160     1010   GE_160:  6 * (7 | (8)   )
   // 144     1001   GE_144   6 * (7 | (8|9) )
   // 128     1000   GE_128:  6
   // 112     0111   GE_112:  6 | (7 * (8*9) )

   assign ex3_xthrm_6_ns_b = (~(ex3_bsha[6] & ex3_sel_special_b));
   assign ex3_xthrm_7_ns_b = (~(ex3_bsha[7] & ex3_sel_special_b));
   assign ex3_xthrm_8_b = (~(ex3_bsha[8]));
   assign ex3_xthrm_8a9_b = (~(ex3_bsha[8] & ex3_bsha[9]));
   assign ex3_xthrm_8o9_b = (~(ex3_bsha[8] | ex3_bsha[9]));

   assign ex3_xthrm7o8a9 = (~(ex3_xthrm_7_ns_b & ex3_xthrm_8a9_b));
   assign ex3_xthrm7o8 = (~(ex3_xthrm_7_ns_b & ex3_xthrm_8_b));
   assign ex3_xthrm7o8o9 = (~(ex3_xthrm_7_ns_b & ex3_xthrm_8o9_b));
   assign ex3_xthrm7a8a9 = (~(ex3_xthrm_7_ns_b | ex3_xthrm_8a9_b));
   assign ex3_xthrm_6_ns = (~(ex3_xthrm_6_ns_b));

   assign ex3_ge176_b = (~(ex3_xthrm_6_ns & ex3_xthrm7o8a9));
   assign ex3_ge160_b = (~(ex3_xthrm_6_ns & ex3_xthrm7o8));
   assign ex3_ge144_b = (~(ex3_xthrm_6_ns & ex3_xthrm7o8o9));
   assign ex3_ge128_b = (~(ex3_xthrm_6_ns));
   assign ex3_ge112_b = (~(ex3_xthrm_6_ns | ex3_xthrm7a8a9));

   assign ex3_sticky_en16_x[0] = (~ex3_ge176_b);
   assign ex3_sticky_en16_x[1] = (~ex3_ge160_b);
   assign ex3_sticky_en16_x[2] = (~ex3_ge144_b);
   assign ex3_sticky_en16_x[3] = (~ex3_ge128_b);
   assign ex3_sticky_en16_x[4] = (~ex3_ge112_b);

   assign ex3_b_zero_b = (~ex3_b_zero);

   assign f_alg_ex3_byp_nonflip = ex3_byp_nonflip_lze;
   assign f_alg_ex3_sel_byp = ex3_sel_byp;		//output-- all eac selects off
   assign f_alg_ex3_effsub_eac_b = (~ex3_effsub_alg);		//output-- includes cancelations
   assign f_alg_ex3_prod_z = ex3_prod_zero;		//output
   assign f_alg_ex3_sh_unf = ex3_sh_unf;		//output--f_pic--
   assign f_alg_ex3_sh_ovf = ex3_ovf_pz;		//output--f_pic--

   //==##############################################################
   //# ex3 logic
   //==##############################################################

   //#-------------------------------------------------
   //# start sticky (passed 163 ... passed 162 for math, but need guard for fcti rounding)
   //#-------------------------------------------------


   fu_alg_or16  or16(
      .ex3_sh_lvl2(ex3_sh_lvl2[0:67]),		//i--
      .ex3_sticky_or16(ex3_sticky_or16[0:4])		//o--
   );

   //#-------------------------------------------------
   //# finish shifting
   //#-------------------------------------------------
   // this looks more like a 53:1 mux than a shifter to shrink it, and lower load on selects
   // real implementation should be nand/nand/nor ... ?? integrate nor into latch ??


   fu_alg_sh16  sh16(
      .ex3_lvl3_shdcd000(ex3_lvl3_shdcd000),		//i--
      .ex3_lvl3_shdcd016(ex3_lvl3_shdcd016),		//i--
      .ex3_lvl3_shdcd032(ex3_lvl3_shdcd032),		//i--
      .ex3_lvl3_shdcd048(ex3_lvl3_shdcd048),		//i--
      .ex3_lvl3_shdcd064(ex3_lvl3_shdcd064),		//i--
      .ex3_lvl3_shdcd080(ex3_lvl3_shdcd080),		//i--
      .ex3_lvl3_shdcd096(ex3_lvl3_shdcd096),		//i--
      .ex3_lvl3_shdcd112(ex3_lvl3_shdcd112),		//i--
      .ex3_lvl3_shdcd128(ex3_lvl3_shdcd128),		//i--
      .ex3_lvl3_shdcd144(ex3_lvl3_shdcd144),		//i--
      .ex3_lvl3_shdcd160(ex3_lvl3_shdcd160),		//i--
      .ex3_lvl3_shdcd192(ex3_lvl3_shdcd192),		//i--
      .ex3_lvl3_shdcd208(ex3_lvl3_shdcd208),		//i--
      .ex3_lvl3_shdcd224(ex3_lvl3_shdcd224),		//i--
      .ex3_lvl3_shdcd240(ex3_lvl3_shdcd240),		//i--
      .ex3_sel_special(ex3_sel_special),		//i--
      .ex3_sh_lvl2(ex3_sh_lvl2[0:67]),		//i-- [0:63] is also data for from integer
      .ex3_sh16_162(ex3_sh16_162),		//o--
      .ex3_sh16_163(ex3_sh16_163),		//o--
      .ex3_sh_lvl3(ex3_sh_lvl3[0:162])		//o--
   );

   //==---------------------------------------------
   //== finish bypass controls
   //==----------------------------------------------

   assign ex3_ovf_pz = ex3_prod_zero | (ex3_sh_ovf & ex3_sh_ovf_en & (~ex3_b_zero));
   assign ex3_sel_byp = ex3_sel_byp_nonflip | ex3_ovf_pz;
   assign ex3_all1_y = ex3_negate & ex3_ovf_pz;
   assign ex3_all1_x = ex3_negate & ex3_unf_bz;
   assign ex3_sh_unf = ex3_sh_unf_do | (ex3_sh_unf_en & ex3_sh_unf_x & (~ex3_prod_zero));
   assign ex3_unf_bz = ex3_b_zero | ex3_sh_unf;

   assign ex3_byp_sel_byp_pos = (ex3_sel_byp_nonflip) | (ex3_ovf_pz & (~ex3_integer_op) & (~ex3_negate) & (~ex3_unf_bz)) | (ex3_ovf_pz & (~ex3_integer_op) & ex3_all1_x);

   assign ex3_byp_sel_byp_neg = (~ex3_sel_byp_nonflip) & ex3_ovf_pz & (~ex3_integer_op) & ex3_negate;

   assign ex3_byp_sel_pos = ((~ex3_sel_byp) & (~ex3_integer_op) & (~ex3_negate) & (~ex3_unf_bz)) | ((~ex3_sel_byp) & (~ex3_integer_op) & ex3_all1_x);
   assign ex3_byp_sel_neg = ((~ex3_sel_byp) & (~ex3_integer_op) & ex3_negate);

   assign ex3_prd_sel_pos_hi = ex3_prd_sel_pos_lo & (~ex3_integer_op);
   assign ex3_prd_sel_neg_hi = ex3_prd_sel_neg_lo & (~ex3_integer_op);

   assign ex3_prd_sel_pos_lohi = ex3_prd_sel_pos_lo & (~ex3_word_from);
   assign ex3_prd_sel_neg_lohi = ex3_prd_sel_neg_lo & (~ex3_word_from);

   assign ex3_prd_sel_pos_lo = ((~ex3_sel_byp_nonflip) & (~ex3_ovf_pz) & (~ex3_unf_bz) & (~ex3_negate)) | ((~ex3_sel_byp_nonflip) & ex3_all1_x) | ((~ex3_sel_byp_nonflip) & ex3_all1_y);
   assign ex3_prd_sel_neg_lo = ((~ex3_sel_byp_nonflip) & ex3_negate);

   //#-------------------------------------------------
   //# bypass mux & operand flip
   //#-------------------------------------------------
   //# integer operation positions
   //#         32          32
   //#       99:130    131:162


   fu_alg_bypmux  bymx(
      .ex3_byp_sel_byp_neg(ex3_byp_sel_byp_neg),		//i--
      .ex3_byp_sel_byp_pos(ex3_byp_sel_byp_pos),		//i--
      .ex3_byp_sel_neg(ex3_byp_sel_neg),		//i--
      .ex3_byp_sel_pos(ex3_byp_sel_pos),		//i--
      .ex3_prd_sel_neg_hi(ex3_prd_sel_neg_hi),		//i--
      .ex3_prd_sel_neg_lo(ex3_prd_sel_neg_lo),		//i--
      .ex3_prd_sel_neg_lohi(ex3_prd_sel_neg_lohi),		//i--
      .ex3_prd_sel_pos_hi(ex3_prd_sel_pos_hi),		//i--
      .ex3_prd_sel_pos_lo(ex3_prd_sel_pos_lo),		//i--
      .ex3_prd_sel_pos_lohi(ex3_prd_sel_pos_lohi),		//i--
      .ex3_sh_lvl3(ex3_sh_lvl3[0:162]),		//i--
      .f_fmt_ex3_pass_frac(f_fmt_ex3_pass_frac[0:52]),		//i--
      .f_alg_ex3_res(f_alg_ex3_res[0:162])		//o--
   );

   //#-------------------------------------------------
   //# finish sticky
   //#-------------------------------------------------

   assign ex3_frmneg = ex3_from_integer & ex3_negate;		//need +1 as part of negate
   assign ex3_toneg = (ex3_to_integer & (~ex3_rnd_to_int) & ex3_b_sign);		//reverse rounding for toint/neg
   assign ex3_topos = (ex3_to_integer & (~ex3_rnd_to_int) & (~ex3_b_sign)) | ex3_rnd_to_int;
   assign ex3_frmneg_o_toneg = ex3_frmneg | ex3_toneg;
   assign ex3_frmneg_o_topos = ex3_frmneg | ex3_topos;

   assign ex3_math_gate_x = (~ex3_sel_byp_nonflip) & ex3_b_zero_b & (~ex3_ovf_pz);
   assign ex3_toint_gate_x = ex3_to_integer & ex3_b_zero_b;
   assign ex3_toint_gt_nr_x = ex3_to_integer & ex3_b_zero_b & f_pic_ex3_rnd_nr;
   assign ex3_toint_gt_ok_x = ex3_to_integer & ex3_b_zero_b & f_pic_ex3_rnd_inf_ok;

   assign ex3_math_gate_g = (~ex3_sel_byp_nonflip) & (~ex3_ovf_pz) & ex3_b_zero_b & (ex3_prd_sel_pos_lo | ex3_prd_sel_neg_lo);
   assign ex3_toint_gate_g = ex3_to_integer & (~ex3_ovf_pz) & (~ex3_sh_unf) & ex3_b_zero_b;
   assign ex3_toint_gt_nr_g = ex3_to_integer & (~ex3_ovf_pz) & (~ex3_sh_unf) & ex3_b_zero_b & f_pic_ex3_rnd_nr;
   assign ex3_toint_gt_ok_g = ex3_to_integer & (~ex3_ovf_pz) & (~ex3_sh_unf) & ex3_b_zero_b & f_pic_ex3_rnd_inf_ok;

   assign ex3_bsha_pos = (~ex3_bsha_neg);

   assign ex3_sticky_eac_x = ((ex3_sh_unf | ex3_sticky_en16_x[0]) & ex3_sticky_or16[0] & ex3_bsha_pos) | ((ex3_sh_unf | ex3_sticky_en16_x[1]) & ex3_sticky_or16[1] & ex3_bsha_pos) | ((ex3_sh_unf | ex3_sticky_en16_x[2]) & ex3_sticky_or16[2] & ex3_bsha_pos) | ((ex3_sh_unf | ex3_sticky_en16_x[3]) & ex3_sticky_or16[3] & ex3_bsha_pos) | ((ex3_sh_unf | ex3_sticky_en16_x[4]) & ex3_sticky_or16[4] & ex3_bsha_pos);		// shift underflow enables all sticky

   assign ex3_sticky_math = ex3_sticky_eac_x & ex3_math_gate_x;
   assign ex3_sticky_toint = ex3_sticky_eac_x & ex3_toint_gate_x;
   assign ex3_sticky_toint_nr = ex3_sticky_eac_x & ex3_toint_gt_nr_x;
   assign ex3_sticky_toint_ok = ex3_sticky_eac_x & ex3_toint_gt_ok_x;

   // round-to-int goes up if guard is ON (this fakes it out)
   assign ex3_lsb_toint_nr = (ex3_sh16_162 | ex3_rnd_to_int) & ex3_toint_gt_nr_g;

   assign ex3_g_math = ex3_sh16_163 & ex3_math_gate_g;
   assign ex3_g_toint = ex3_sh16_163 & ex3_toint_gate_g;
   assign ex3_g_toint_nr = ex3_sh16_163 & ex3_toint_gt_nr_g;
   assign ex3_g_toint_ok = ex3_sh16_163 & ex3_toint_gt_ok_g;

   //==##############################################################
   //# ex4 latches  (from ex3 logic)
   //==##############################################################


   tri_rlmreg_p #(.WIDTH(11),  .NEEDS_SRESET(0)) ex4_ctl_lat(
      .force_t(force_t),		//tidn,
      .d_mode(tiup), //d_mode           => d_mode       ,--tiup,
      .delay_lclkr(delay_lclkr[3]),		//tidn,
      .mpw1_b(mpw1_b[3]),		//tidn,
      .mpw2_b(mpw2_b[0]),		//tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex3_act),
      .scout(ex4_ctl_so),
      .scin(ex4_ctl_si),
      //---------------
      .din({ ex3_sticky_math,
             ex3_sticky_toint,
             ex3_sticky_toint_nr,
             ex3_sticky_toint_ok,
             ex3_frmneg_o_toneg,
             ex3_frmneg_o_topos,
             ex3_lsb_toint_nr,
             ex3_g_math,
             ex3_g_toint,
             ex3_g_toint_nr,
             ex3_g_toint_ok}),
      //--------------
      .dout({ ex4_sticky_math,
              ex4_sticky_toint,
              ex4_sticky_toint_nr,
              ex4_sticky_toint_ok,
              ex4_frmneg_o_toneg,
              ex4_frmneg_o_topos,
              ex4_lsb_toint_nr,
              ex4_g_math,
              ex4_g_toint,
              ex4_g_toint_nr,
              ex4_g_toint_ok})
   );

   //==##############################################################
   //== ex4 logic
   //==##############################################################

   assign f_alg_ex4_sticky = ex4_sticky_math | ex4_g_math;		//output--
   assign f_alg_ex4_int_fi = ex4_sticky_toint | ex4_g_toint;		//outpt--

   assign ex4_int_fr_nr1_b = (~(ex4_g_toint_nr & ex4_sticky_toint_nr));
   assign ex4_int_fr_nr2_b = (~(ex4_g_toint_nr & ex4_lsb_toint_nr));
   assign ex4_int_fr_ok_b = (~(ex4_g_toint_ok | ex4_sticky_toint_ok));
   assign ex4_int_fr = (~(ex4_int_fr_nr1_b & ex4_int_fr_nr2_b & ex4_int_fr_ok_b));
   assign f_alg_ex4_int_fr = ex4_int_fr;		//output-- f_pic

   assign ex4_sel_p1_0_b = (~((~ex4_int_fr) & ex4_frmneg_o_toneg));
   assign ex4_sel_p1_1_b = (~(ex4_int_fr & ex4_frmneg_o_topos));
   assign f_alg_ex4_frc_sel_p1 = (~(ex4_sel_p1_0_b & ex4_sel_p1_1_b));		//output-- rounding converts

   //==##############################################################
   //# scan string
   //==##############################################################

   assign ex2_ctl_si[0:4] = {ex2_ctl_so[1:4], f_alg_si};		//SCAN
   assign ex3_shd_si[0:67] = {ex3_shd_so[1:67], ex2_ctl_so[0]};		//SCAN
   assign ex3_shc_si[0:24] = {ex3_shc_so[1:24], ex3_shd_so[0]};		//SCAN
   assign ex3_ctl_si[0:14] = {ex3_ctl_so[1:14], ex3_shc_so[0]};		//SCAN
   assign ex4_ctl_si[0:10] = {ex4_ctl_so[1:10], ex3_ctl_so[0]};		//SCAN
   assign act_si[0:4] = {act_so[1:4], ex4_ctl_so[0]};		//SCAN
   assign f_alg_so = act_so[0];		//SCAN

endmodule
