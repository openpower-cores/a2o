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


module fu_add(
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
   f_add_si,
   f_add_so,
   ex2_act_b,
   f_sa3_ex4_s,
   f_sa3_ex4_c,
   f_alg_ex4_frc_sel_p1,
   f_alg_ex4_sticky,
   f_alg_ex3_effsub_eac_b,
   f_alg_ex3_prod_z,
   f_pic_ex4_is_gt,
   f_pic_ex4_is_lt,
   f_pic_ex4_is_eq,
   f_pic_ex4_is_nan,
   f_pic_ex4_cmp_sgnpos,
   f_pic_ex4_cmp_sgnneg,
   f_add_ex5_res,
   f_add_ex5_flag_nan,
   f_add_ex5_flag_gt,
   f_add_ex5_flag_lt,
   f_add_ex5_flag_eq,
   f_add_ex5_fpcc_iu,
   f_add_ex5_sign_carry,
   f_add_ex5_to_int_ovf_wd,
   f_add_ex5_to_int_ovf_dw,
   f_add_ex5_sticky
);
 //  parameter      expand_type = 2;		// 0 - ibm tech, 1 - other );

   inout          vdd;
   inout          gnd;
   input          clkoff_b;		// tiup
   input          act_dis;		// ??tidn??
   input          flush;		// ??tidn??
   input [3:4]    delay_lclkr;		// tidn,
   input [3:4]    mpw1_b;		// tidn,
   input [0:0]    mpw2_b;		// tidn,
   input          sg_1;
   input          thold_1;
   input          fpu_enable;		//dc_act
   input  [0:`NCLK_WIDTH-1]         nclk;

   input          f_add_si;		//perv
   output         f_add_so;		//perv
   input          ex2_act_b;		//act

   input [0:162]  f_sa3_ex4_s;		// data
   input [53:161] f_sa3_ex4_c;		// data

   input          f_alg_ex4_frc_sel_p1;		// rounding converts
   input          f_alg_ex4_sticky;		// part of eac control
   input          f_alg_ex3_effsub_eac_b;		// already shut off for algByp
   input          f_alg_ex3_prod_z;

   input          f_pic_ex4_is_gt;		// compare
   input          f_pic_ex4_is_lt;		// compare
   input          f_pic_ex4_is_eq;		// compare
   input          f_pic_ex4_is_nan;		// compare
   input          f_pic_ex4_cmp_sgnpos;		// compare
   input          f_pic_ex4_cmp_sgnneg;		// compare

   output [0:162] f_add_ex5_res;		// RESULT
   output         f_add_ex5_flag_nan;		// compare for fpscr
   output         f_add_ex5_flag_gt;		// compare for fpscr
   output         f_add_ex5_flag_lt;		// compare for fpscr
   output         f_add_ex5_flag_eq;		// compare for fpscr
   output [0:3]   f_add_ex5_fpcc_iu;		// compare for iu
   output         f_add_ex5_sign_carry;		// select sign from product/addend
   output [0:1]   f_add_ex5_to_int_ovf_wd;		// raw data
   output [0:1]   f_add_ex5_to_int_ovf_dw;		// raw data
   output         f_add_ex5_sticky;		// for nrm


   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;

   ////#################################
   ////# sigdef : non-functional
   ////#################################

   wire           thold_0_b;
   wire           thold_0;
   wire           sg_0;
   wire           force_t;

   wire           ex2_act;
   wire           ex3_act;
   wire           ex4_act;

   wire [0:8]     act_si;
   wire [0:8]     act_so;
   wire [0:162]   ex5_res_so;
   wire [0:162]   ex5_res_si;
   wire [0:9]     ex5_cmp_so;
   wire [0:9]     ex5_cmp_si;

   wire [0:3]     spare_unused;

   ////#################################
   ////# sigdef : functional
   ////#################################

   wire [0:162]   ex4_s;
   wire [53:161]  ex4_c;

   wire           ex4_flag_nan;
   wire           ex4_flag_gt;
   wire           ex4_flag_lt;
   wire           ex4_flag_eq;
   wire           ex4_sign_carry;

   wire           ex4_inc_all1;
   wire [1:6]     ex4_inc_byt_c_glb;
   wire [1:6]     ex4_inc_byt_c_glb_b;
   wire [0:52]    ex4_inc_p1;
   wire [0:52]    ex4_inc_p0;

   wire [53:162]  ex4_s_p0;
   wire [53:162]  ex4_s_p1;
   wire [0:162]   ex4_res;

   wire           ex3_effsub;
   wire           ex4_effsub;

   wire           ex3_effadd_npz;
   wire           ex3_effsub_npz;
   wire           ex4_effsub_npz;
   wire           ex4_effadd_npz;
   wire           ex4_flip_inc_p0;
   wire           ex4_flip_inc_p1;
   wire           ex4_inc_sel_p0;
   wire           ex4_inc_sel_p1;

   wire [0:162]   ex5_res;
   wire [0:162]   ex5_res_b;
   wire [0:162]   ex5_res_l2_b;
   wire           ex5_flag_nan_b;
   wire           ex5_flag_gt_b;
   wire           ex5_flag_lt_b;
   wire           ex5_flag_eq_b;
   wire [0:3]     ex5_fpcc_iu_b;
   wire           ex5_sign_carry_b;
   wire           ex5_sticky_b;

   wire [0:6]     ex4_g16;
   wire [0:6]     ex4_t16;
   wire [1:6]     ex4_g128;
   wire [1:6]     ex4_t128;
   wire [1:6]     ex4_g128_b;
   wire [1:6]     ex4_t128_b;
   wire [0:6]     ex4_inc_byt_c_b;
   wire [0:6]     ex4_eac_sel_p0n;
   wire [0:6]     ex4_eac_sel_p0;
   wire [0:6]     ex4_eac_sel_p1;
   wire           ex4_flag_nan_cp1;
   wire           ex4_flag_gt_cp1;
   wire           ex4_flag_lt_cp1;
   wire           ex4_flag_eq_cp1;
   wire           add_ex5_d1clk;
   wire           add_ex5_d2clk;
   wire [0:`NCLK_WIDTH-1]           add_ex5_lclk;

   wire [53:162]  ex4_s_p0n;
   wire [53:162]  ex4_res_p0n_b;
   wire [53:162]  ex4_res_p0_b;
   wire [53:162]  ex4_res_p1_b;
   wire [0:52]    ex4_inc_p0_x;
   wire [0:52]    ex4_inc_p1_x;
   wire [0:52]    ex4_incx_p0_b;
   wire [0:52]    ex4_incx_p1_b;
   wire [53:162]  ex4_sel_a1;
   wire [53:162]  ex4_sel_a2;
   wire [53:162]  ex4_sel_a3;


   ////################################################################
   ////# pervasive
   ////################################################################


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

   ////################################################################
   ////# act
   ////################################################################

   assign ex2_act = (~ex2_act_b);
   assign ex3_effsub = (~f_alg_ex3_effsub_eac_b);
   assign ex3_effsub_npz = (~f_alg_ex3_effsub_eac_b) & (~f_alg_ex3_prod_z);
   assign ex3_effadd_npz = f_alg_ex3_effsub_eac_b & (~f_alg_ex3_prod_z);


   tri_rlmreg_p #(.WIDTH(9), .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),		//i-- tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),		//i-- tidn,
      .mpw1_b(mpw1_b[3]),		//i-- tidn,
      .mpw2_b(mpw2_b[0]),		//i-- tidn,
      .nclk(nclk),
      .act(fpu_enable),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scout(act_so),
      .scin(act_si),
      //-----------------
      .din({  spare_unused[0],
              spare_unused[1],
              ex2_act,
              ex3_act,
              ex3_effsub,
              ex3_effsub_npz,
              ex3_effadd_npz,
              spare_unused[2],
              spare_unused[3]}),
      //-----------------
      .dout({  spare_unused[0],
               spare_unused[1],
               ex3_act,
               ex4_act,
               ex4_effsub,
               ex4_effsub_npz,
               ex4_effadd_npz,
               spare_unused[2],
               spare_unused[3]})
   );


   tri_lcbnd  add_ex5_lcb(
      .delay_lclkr(delay_lclkr[4]),		// tidn ,--in
      .mpw1_b(mpw1_b[4]),	// tidn ,--in
      .mpw2_b(mpw2_b[0]),	// tidn ,--in
      .force_t(force_t),		// tidn ,--in
      .nclk(nclk),		//in
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .act(ex4_act),		//in
      .sg(sg_0),		//in
      .thold_b(thold_0_b),		//in
      .d1clk(add_ex5_d1clk),		//out
      .d2clk(add_ex5_d2clk),		//out
      .lclk(add_ex5_lclk)		//out
   );

   ////################################################################
   ////# ex4 logic
   ////################################################################

   assign ex4_s[0:162] = f_sa3_ex4_s[0:162];
   assign ex4_c[53:161] = f_sa3_ex4_c[53:161];

   //ex4 incrementer-----------------------------------------

   //ex4 incr (global carry)---------------------------------


   fu_add_all1 all1(
      .ex4_inc_byt_c_b(ex4_inc_byt_c_b[0:6]),		//i--
      .ex4_inc_byt_c_glb(ex4_inc_byt_c_glb[1:6]),		//o--
      .ex4_inc_byt_c_glb_b(ex4_inc_byt_c_glb_b[1:6]),		//o--
      .ex4_inc_all1(ex4_inc_all1)		//o--
   );

   //ex4 incr (byte sections) -------------------------------------------------


   fu_loc8inc_lsb inc8_6(
      .co_b(ex4_inc_byt_c_b[6]),		//o--
      .x(ex4_s[48:52]),		//i--
      .s0(ex4_inc_p0[48:52]),		//o--
      .s1(ex4_inc_p1[48:52])		//o--
   );


   fu_loc8inc inc8_5(
      .ci(ex4_inc_byt_c_glb[6]),		//i--
      .ci_b(ex4_inc_byt_c_glb_b[6]),		//i--
      .co_b(ex4_inc_byt_c_b[5]),		//o--
      .x(ex4_s[40:47]),		//i--
      .s0(ex4_inc_p0[40:47]),		//o--
      .s1(ex4_inc_p1[40:47])		//o--
   );


   fu_loc8inc inc8_4(
      .ci(ex4_inc_byt_c_glb[5]),		//i--
      .ci_b(ex4_inc_byt_c_glb_b[5]),		//i--
      .co_b(ex4_inc_byt_c_b[4]),		//o--
      .x(ex4_s[32:39]),		//i--
      .s0(ex4_inc_p0[32:39]),		//o--
      .s1(ex4_inc_p1[32:39])		//o--
   );


   fu_loc8inc inc8_3(
      .ci(ex4_inc_byt_c_glb[4]),		//i--
      .ci_b(ex4_inc_byt_c_glb_b[4]),		//i--
      .co_b(ex4_inc_byt_c_b[3]),		//o--
      .x(ex4_s[24:31]),		//i--
      .s0(ex4_inc_p0[24:31]),		//o--
      .s1(ex4_inc_p1[24:31])		//o--
   );


   fu_loc8inc inc8_2(
      .ci(ex4_inc_byt_c_glb[3]),		//i--
      .ci_b(ex4_inc_byt_c_glb_b[3]),		//i--
      .co_b(ex4_inc_byt_c_b[2]),		//o--
      .x(ex4_s[16:23]),		//i--
      .s0(ex4_inc_p0[16:23]),		//o--
      .s1(ex4_inc_p1[16:23])		//o--
   );


   fu_loc8inc inc8_1(
      .ci(ex4_inc_byt_c_glb[2]),		//i--
      .ci_b(ex4_inc_byt_c_glb_b[2]),		//i--
      .co_b(ex4_inc_byt_c_b[1]),		//o--
      .x(ex4_s[8:15]),		//i--
      .s0(ex4_inc_p0[8:15]),		//o--
      .s1(ex4_inc_p1[8:15])		//o--
   );


   fu_loc8inc inc8_0(
      .ci(ex4_inc_byt_c_glb[1]),		//i--
      .ci_b(ex4_inc_byt_c_glb_b[1]),		//i--
      .co_b(ex4_inc_byt_c_b[0]),		//o--
      .x(ex4_s[0:7]),		//i--
      .s0(ex4_inc_p0[0:7]),		//o--
      .s1(ex4_inc_p1[0:7])		//o--
   );

   //ex4 adder-----------------------------------------------

   // sum[53] is the raw aligner bit
   // car[53] includes the bogus bit
   // position 53 also includes a "1" to push out the bogus bit
   //
   // [0:52] needs "111...111" to push out the bogus bit
   // but the first co of [53] is suppressed instead
   //
   // ex4_53 => s53, c53, "1", ci : 2nd co : s53 * c53 * ci

   // sums
   // [0] 053:068
   // [1] 069:084
   // [2] 085:100
   // [3] 101:116
   // [4] 117:132
   // [5] 133:148
   // [6] 149:164 <162,"1","1">


   fu_hc16pp_msb hc16_0(
      .x(ex4_s[53:68]),		//i--
      .y(ex4_c[53:68]),		//i--
      .ci0(ex4_g128[1]),		//i--
      .ci0_b(ex4_g128_b[1]),		//i--
      .ci1(ex4_t128[1]),		//i--
      .ci1_b(ex4_t128_b[1]),		//i--
      .s0(ex4_s_p0[53:68]),		//o--
      .s1(ex4_s_p1[53:68]),		//o--
      .g16(ex4_g16[0]),		//o--
      .t16(ex4_t16[0])		//o--
   );


   fu_hc16pp hc16_1(
      .x(ex4_s[69:84]),		//i--
      .y(ex4_c[69:84]),		//i--
      .ci0(ex4_g128[2]),		//i--
      .ci0_b(ex4_g128_b[2]),		//i--
      .ci1(ex4_t128[2]),		//i--
      .ci1_b(ex4_t128_b[2]),		//i--
      .s0(ex4_s_p0[69:84]),		//o--
      .s1(ex4_s_p1[69:84]),		//o--
      .g16(ex4_g16[1]),		//o--
      .t16(ex4_t16[1])		//o--
   );


   fu_hc16pp hc16_2(
      .x(ex4_s[85:100]),		//i--
      .y(ex4_c[85:100]),		//i--
      .ci0(ex4_g128[3]),		//i--
      .ci0_b(ex4_g128_b[3]),		//i--
      .ci1(ex4_t128[3]),		//i--
      .ci1_b(ex4_t128_b[3]),		//i--
      .s0(ex4_s_p0[85:100]),		//o--
      .s1(ex4_s_p1[85:100]),		//o--
      .g16(ex4_g16[2]),		//o--
      .t16(ex4_t16[2])		//o--
   );


   fu_hc16pp hc16_3(
      .x(ex4_s[101:116]),		//i--
      .y(ex4_c[101:116]),		//i--
      .ci0(ex4_g128[4]),		//i--
      .ci0_b(ex4_g128_b[4]),		//i--
      .ci1(ex4_t128[4]),		//i--
      .ci1_b(ex4_t128_b[4]),		//i--
      .s0(ex4_s_p0[101:116]),		//o--
      .s1(ex4_s_p1[101:116]),		//o--
      .g16(ex4_g16[3]),		//o--
      .t16(ex4_t16[3])		//o--
   );


   fu_hc16pp hc16_4(
      .x(ex4_s[117:132]),		//i--
      .y(ex4_c[117:132]),		//i--
      .ci0(ex4_g128[5]),		//i--
      .ci0_b(ex4_g128_b[5]),		//i--
      .ci1(ex4_t128[5]),		//i--
      .ci1_b(ex4_t128_b[5]),		//i--
      .s0(ex4_s_p0[117:132]),		//o--
      .s1(ex4_s_p1[117:132]),		//o--
      .g16(ex4_g16[4]),		//o--
      .t16(ex4_t16[4])		//o--
   );


   fu_hc16pp hc16_5(
      .x(ex4_s[133:148]),		//i--
      .y(ex4_c[133:148]),		//i--
      .ci0(ex4_g128[6]),		//i--
      .ci0_b(ex4_g128_b[6]),		//i--
      .ci1(ex4_t128[6]),		//i--
      .ci1_b(ex4_t128_b[6]),		//i--
      .s0(ex4_s_p0[133:148]),		//o--
      .s1(ex4_s_p1[133:148]),		//o--
      .g16(ex4_g16[5]),		//o--
      .t16(ex4_t16[5])		//o--
   );


   fu_hc16pp_lsb hc16_6(
      .x(ex4_s[149:162]),		//i--
      .y(ex4_c[149:161]),		//i--
      .s0(ex4_s_p0[149:162]),		//o--
      .s1(ex4_s_p1[149:162]),		//o--
      .g16(ex4_g16[6]),		//o--
      .t16(ex4_t16[6])		//o--
   );

   //=#########################################################################################
   //=## EACMUX (move the nand3 into technology dependent latch ... latch not yet available)
   //=#########################################################################################

   //------------------------------------------------
   // EACMUX: incrementer bits
   //------------------------------------------------

   assign ex4_inc_p0_x[0:52] = ex4_inc_p0[0:52] ^ {53{ex4_flip_inc_p0}};
   assign ex4_inc_p1_x[0:52] = ex4_inc_p1[0:52] ^ {53{ex4_flip_inc_p1}};

   assign ex4_incx_p0_b[0:52] = (~({53{ex4_inc_sel_p0}} & ex4_inc_p0_x[0:52]));
   assign ex4_incx_p1_b[0:52] = (~({53{ex4_inc_sel_p1}} & ex4_inc_p1_x[0:52]));
   assign ex4_res[0:52] = (~(ex4_incx_p0_b[0:52] & ex4_incx_p1_b[0:52]));

   //------------------------------------------------
   // EACMUX: adder bits
   //------------------------------------------------

   assign ex4_sel_a1[53:68] = {16{ex4_eac_sel_p0n[0]}};		//rename
   assign ex4_sel_a1[69:84] = {16{ex4_eac_sel_p0n[1]}};		//rename
   assign ex4_sel_a1[85:100] = {16{ex4_eac_sel_p0n[2]}};		//rename
   assign ex4_sel_a1[101:116] = {16{ex4_eac_sel_p0n[3]}};		//rename
   assign ex4_sel_a1[117:132] = {16{ex4_eac_sel_p0n[4]}};		//rename
   assign ex4_sel_a1[133:148] = {16{ex4_eac_sel_p0n[5]}};		//rename
   assign ex4_sel_a1[149:162] = {14{ex4_eac_sel_p0n[6]}};		//rename

   assign ex4_sel_a2[53:68] = {16{ex4_eac_sel_p0[0]}};		//rename
   assign ex4_sel_a2[69:84] = {16{ex4_eac_sel_p0[1]}};		//rename
   assign ex4_sel_a2[85:100] = {16{ex4_eac_sel_p0[2]}};		//rename
   assign ex4_sel_a2[101:116] = {16{ex4_eac_sel_p0[3]}};		//rename
   assign ex4_sel_a2[117:132] = {16{ex4_eac_sel_p0[4]}};		//rename
   assign ex4_sel_a2[133:148] = {16{ex4_eac_sel_p0[5]}};		//rename
   assign ex4_sel_a2[149:162] = {14{ex4_eac_sel_p0[6]}};		//rename

   assign ex4_sel_a3[53:68] = {16{ex4_eac_sel_p1[0]}};		//rename
   assign ex4_sel_a3[69:84] = {16{ex4_eac_sel_p1[1]}};		//rename
   assign ex4_sel_a3[85:100] = {16{ex4_eac_sel_p1[2]}};		//rename
   assign ex4_sel_a3[101:116] = {16{ex4_eac_sel_p1[3]}};		//rename
   assign ex4_sel_a3[117:132] = {16{ex4_eac_sel_p1[4]}};		//rename
   assign ex4_sel_a3[133:148] = {16{ex4_eac_sel_p1[5]}};		//rename
   assign ex4_sel_a3[149:162] = {14{ex4_eac_sel_p1[6]}};		//rename

   assign ex4_s_p0n[53:162] = (~(ex4_s_p0[53:162]));
   assign ex4_res_p0n_b[53:162] = (~(ex4_sel_a1[53:162] & ex4_s_p0n[53:162]));
   assign ex4_res_p0_b[53:162] = (~(ex4_sel_a2[53:162] & ex4_s_p0[53:162]));
   assign ex4_res_p1_b[53:162] = (~(ex4_sel_a3[53:162] & ex4_s_p1[53:162]));
   assign ex4_res[53:162] = (~(ex4_res_p0n_b[53:162] & ex4_res_p0_b[53:162] & ex4_res_p1_b[53:162]));

   //=##################################################################################
   //=# global carry chain, eac_selects, compare, sign_carry
   //=##################################################################################


   fu_add_glbc glbc(
      .ex4_g16(ex4_g16[0:6]),		//i--
      .ex4_t16(ex4_t16[0:6]),		//i--
      .ex4_inc_all1(ex4_inc_all1),		//i--
      .ex4_effsub(ex4_effsub),		//i--
      .ex4_effsub_npz(ex4_effsub_npz),		//i--
      .ex4_effadd_npz(ex4_effadd_npz),		//i--
      .f_alg_ex4_frc_sel_p1(f_alg_ex4_frc_sel_p1),		//i--
      .f_alg_ex4_sticky(f_alg_ex4_sticky),		//i--
      .f_pic_ex4_is_nan(f_pic_ex4_is_nan),		//i--
      .f_pic_ex4_is_gt(f_pic_ex4_is_gt),		//i--
      .f_pic_ex4_is_lt(f_pic_ex4_is_lt),		//i--
      .f_pic_ex4_is_eq(f_pic_ex4_is_eq),		//i--
      .f_pic_ex4_cmp_sgnpos(f_pic_ex4_cmp_sgnpos),		//i--
      .f_pic_ex4_cmp_sgnneg(f_pic_ex4_cmp_sgnneg),		//i--
      .ex4_g128(ex4_g128[1:6]),		//o--
      .ex4_g128_b(ex4_g128_b[1:6]),		//o--
      .ex4_t128(ex4_t128[1:6]),		//o--
      .ex4_t128_b(ex4_t128_b[1:6]),		//o--
      .ex4_flip_inc_p0(ex4_flip_inc_p0),		//o--
      .ex4_flip_inc_p1(ex4_flip_inc_p1),		//o--
      .ex4_inc_sel_p0(ex4_inc_sel_p0),		//o--
      .ex4_inc_sel_p1(ex4_inc_sel_p1),		//o--
      .ex4_eac_sel_p0n(ex4_eac_sel_p0n),		//o--
      .ex4_eac_sel_p0(ex4_eac_sel_p0),		//o--
      .ex4_eac_sel_p1(ex4_eac_sel_p1),		//o--
      .ex4_sign_carry(ex4_sign_carry),		//o--
      .ex4_flag_nan_cp1(ex4_flag_nan_cp1),		//o-- duplicate lat driven by unique gate
      .ex4_flag_gt_cp1(ex4_flag_gt_cp1),		//o-- duplicate lat driven by unique gate
      .ex4_flag_lt_cp1(ex4_flag_lt_cp1),		//o-- duplicate lat driven by unique gate
      .ex4_flag_eq_cp1(ex4_flag_eq_cp1),		//o-- duplicate lat driven by unique gate
      .ex4_flag_nan(ex4_flag_nan),		//o--
      .ex4_flag_gt(ex4_flag_gt),		//o--
      .ex4_flag_lt(ex4_flag_lt),		//o--
      .ex4_flag_eq(ex4_flag_eq)		//o--
   );

   ////################################################################
   ////# ex5 latches
   ////################################################################


   tri_inv_nlats #(.WIDTH(53),   .NEEDS_SRESET(0)) ex5_res_hi_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(add_ex5_lclk),		// lclk.clk
      .d1clk(add_ex5_d1clk),
      .d2clk(add_ex5_d2clk),
      .scanin(ex5_res_si[0:52]),
      .scanout(ex5_res_so[0:52]),
      .d(ex4_res[0:52]),
      .qb(ex5_res_l2_b[0:52])		//LAT
   );


   tri_inv_nlats #(.WIDTH(110),  .NEEDS_SRESET(0)) ex5_res_lo_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(add_ex5_lclk),		// lclk.clk
      .d1clk(add_ex5_d1clk),
      .d2clk(add_ex5_d2clk),
      .scanin(ex5_res_si[53:162]),
      .scanout(ex5_res_so[53:162]),
      .d(ex4_res[53:162]),
      .qb(ex5_res_l2_b[53:162])		//LAT
   );

   assign ex5_res[0:162] = (~ex5_res_l2_b[0:162]);
   assign ex5_res_b[0:162] = (~ex5_res[0:162]);
   assign f_add_ex5_res[0:162] = (~ex5_res_b[0:162]);		// output


   tri_inv_nlats #(.WIDTH(10),  .NEEDS_SRESET(0)) ex5_cmp_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(add_ex5_lclk),		// lclk.clk
      .d1clk(add_ex5_d1clk),
      .d2clk(add_ex5_d2clk),
      .scanin(ex5_cmp_si),
      .scanout(ex5_cmp_so),
      //-----------------
      .d({  ex4_flag_lt,
            ex4_flag_lt_cp1,
            ex4_flag_gt,
            ex4_flag_gt_cp1,
            ex4_flag_eq,
            ex4_flag_eq_cp1,
            ex4_flag_nan,
            ex4_flag_nan_cp1,
            ex4_sign_carry,
            f_alg_ex4_sticky}),
      //-----------------
      .qb({  ex5_flag_lt_b,		//LAT
             ex5_fpcc_iu_b[0],		//LAT
             ex5_flag_gt_b,		//LAT
             ex5_fpcc_iu_b[1],		//LAT
             ex5_flag_eq_b,		//LAT
             ex5_fpcc_iu_b[2],		//LAT
             ex5_flag_nan_b,		//LAT
             ex5_fpcc_iu_b[3],		//LAT
             ex5_sign_carry_b,		//LAT
             ex5_sticky_b})		//LAT
   );

   assign f_add_ex5_flag_nan = (~ex5_flag_nan_b);		//output
   assign f_add_ex5_flag_gt = (~ex5_flag_gt_b);		//output
   assign f_add_ex5_flag_lt = (~ex5_flag_lt_b);		//output
   assign f_add_ex5_flag_eq = (~ex5_flag_eq_b);		//output
   assign f_add_ex5_fpcc_iu[0:3] = (~ex5_fpcc_iu_b[0:3]);		//output
   assign f_add_ex5_sign_carry = (~ex5_sign_carry_b);		//output
   assign f_add_ex5_sticky = (~ex5_sticky_b);		//output

   assign f_add_ex5_to_int_ovf_wd[0] = ex5_res[130];		//output
   assign f_add_ex5_to_int_ovf_wd[1] = ex5_res[131];		//output
   assign f_add_ex5_to_int_ovf_dw[0] = ex5_res[98];		//output
   assign f_add_ex5_to_int_ovf_dw[1] = ex5_res[99];		//output

   ////################################################################
   ////# ex5 logic
   ////################################################################

   ////################################################################
   ////# scan string
   ////################################################################

   assign act_si[0:8] = {act_so[1:8], f_add_si};
   assign ex5_res_si[0:162] = {ex5_res_so[1:162], act_so[0]};
   assign ex5_cmp_si[0:9] = {ex5_cmp_so[1:9], ex5_res_so[0]};
   assign f_add_so = ex5_cmp_so[0];

endmodule
