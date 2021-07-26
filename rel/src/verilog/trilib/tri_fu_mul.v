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


module tri_fu_mul(
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
   f_mul_si,
   f_mul_so,
   ex2_act,
   f_fmt_ex2_a_frac,
   f_fmt_ex2_a_frac_17,
   f_fmt_ex2_a_frac_35,
   f_fmt_ex2_c_frac,
   f_mul_ex3_sum,
   f_mul_ex3_car
);

   inout          vdd;
   inout          gnd;
   input          clkoff_b;		// tiup
   input          act_dis;		// ??tidn??
   input          flush;		// ??tidn??
   input          delay_lclkr;		// tidn,
   input          mpw1_b;		// tidn,
   input          mpw2_b;		// tidn,
   input          sg_1;
   input          thold_1;
   input          fpu_enable;		//dc_act
   input  [0:`NCLK_WIDTH-1]         nclk;

   input          f_mul_si;		//perv
   output         f_mul_so;		//perv
   input          ex2_act;		//act

   input [0:52]   f_fmt_ex2_a_frac;		// implicit bit already generated
   input          f_fmt_ex2_a_frac_17;		// new port for replicated bit
   input          f_fmt_ex2_a_frac_35;		// new port for replicated bit
   input [0:53]   f_fmt_ex2_c_frac;		// implicit bit already generated

   output [1:108] f_mul_ex3_sum;
   output [1:108] f_mul_ex3_car;

   // ENTITY


   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;

   wire           thold_0_b;
   wire           thold_0;
   wire           force_t;
   wire           sg_0;
   wire [0:3]     spare_unused;
   //--------------------------------------
   wire [0:3]     act_so;		//SCAN
   wire [0:3]     act_si;
   wire           m92_0_so;
   wire           m92_1_so;
   wire           m92_2_so;
   //--------------------------------------
   wire [36:108]  pp3_05;
   wire [35:108]  pp3_04;
   wire [18:90]   pp3_03;
   wire [17:90]   pp3_02;
   wire [0:72]    pp3_01;
   wire [0:72]    pp3_00;

   wire           hot_one_msb_unused;
   wire           hot_one_74;
   wire           hot_one_92;
   wire           xtd_unused;

   wire [1:108]   pp5_00;
   wire [1:108]   pp5_01;

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


   tri_rlmreg_p #(.WIDTH(4),  .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),		//i-- tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr),		//i-- tidn,
      .mpw1_b(mpw1_b),		//i-- tidn,
      .mpw2_b(mpw2_b),		//i-- tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(fpu_enable),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(act_so),
      .scin(act_si),
      //-----------------
      .din({ spare_unused[0],
             spare_unused[1],
             spare_unused[2],
             spare_unused[3]}),
      //-----------------
      .dout({spare_unused[0],
             spare_unused[1],
             spare_unused[2],
             spare_unused[3]})
   );

   assign act_si[0:3] = {act_so[1:3], m92_2_so};

   assign f_mul_so = act_so[0];

   ////################################################################
   ////# ex2 logic
   ////################################################################

   ////# NUMBERING SYSTEM RELATIVE TO COMPRESSOR TREE
   ////#
   ////#    0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111
   ////#    0000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999000000000
   ////#    0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
   ////#  0 ..DdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..................................................
   ////#  1 ..1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s................................................
   ////#  2 ....1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..............................................
   ////#  3 ......1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s............................................
   ////#  4 ........1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..........................................
   ////#  5 ..........1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s........................................
   ////#  6 ............1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s......................................
   ////#  7 ..............1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s....................................
   ////#  8 ................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..................................

   ////#  9 ..................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s................................
   ////# 10 ....................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..............................
   ////# 11 ......................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s............................
   ////# 12 ........................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..........................
   ////# 13 ..........................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s........................
   ////# 14 ............................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s......................
   ////# 15 ..............................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s....................
   ////# 16 ................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..................
   ////# 17 ..................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s................

   ////# 18 ....................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..............
   ////# 19 ......................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s............
   ////# 20 ........................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..........
   ////# 21 ..........................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s........
   ////# 22 ............................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s......
   ////# 23 ..............................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s....
   ////# 24 ................................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s..
   ////# 25 ..................................................1aDdddddddddddddddddddddddddddddddddddddddddddddddddddddD0s
   ////# 26 ...................................................assDdddddddddddddddddddddddddddddddddddddddddddddddddddddD


   tri_fu_mul_92 #(.inst(2)) m92_2(
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .force_t(force_t),		//i--
      .lcb_delay_lclkr(delay_lclkr),		//i-- tidn
      .lcb_mpw1_b(mpw1_b),		//i-- mpw1_b   others=0
      .lcb_mpw2_b(mpw2_b),		//i-- mpw2_b   others=0
      .thold_b(thold_0_b),		//i--
      .lcb_sg(sg_0),		//i--
      .si(f_mul_si),		//i--
      .so(m92_0_so),		//o--
      .ex2_act(ex2_act),		//i--
      //--------------------
      .c_frac(f_fmt_ex2_c_frac[0:53]),		//i-- Multiplicand (shift me)
      .a_frac({f_fmt_ex2_a_frac[35:52],		//i-- Multiplier   (recode me)
              tidn}),		//i-- Multiplier   (recode me)
      .hot_one_out(hot_one_92),		//o--
      .sum92(pp3_05[36:108]),		//o--
      .car92(pp3_04[35:108])		//o--
   );


   tri_fu_mul_92 #(.inst(1)) m92_1(
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .force_t(force_t),		//i--
      .lcb_delay_lclkr(delay_lclkr),		//i-- tidn
      .lcb_mpw1_b(mpw1_b),		//i-- mpw1_b   others=0
      .lcb_mpw2_b(mpw2_b),		//i-- mpw2_b   others=0
      .thold_b(thold_0_b),		//i--
      .lcb_sg(sg_0),		//i--
      .si(m92_0_so),		//i--
      .so(m92_1_so),		//o-- v
      .ex2_act(ex2_act),		//i--
      //-------------------
      .c_frac(f_fmt_ex2_c_frac[0:53]),		//i-- Multiplicand (shift me)
      .a_frac({f_fmt_ex2_a_frac[17:34],		//i-- Multiplier   (recode me)
               f_fmt_ex2_a_frac_35}),		//i-- Multiplier   (recode me)
      .hot_one_out(hot_one_74),		//o--
      .sum92(pp3_03[18:90]),		//o--
      .car92(pp3_02[17:90])		//o--
   );


   tri_fu_mul_92 #(.inst(0)) m92_0(
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .force_t(force_t),		//i--
      .lcb_delay_lclkr(delay_lclkr),		//i-- tidn
      .lcb_mpw1_b(mpw1_b),		//i-- mpw1_b   others=0
      .lcb_mpw2_b(mpw2_b),		//i-- mpw2_b   others=0
      .thold_b(thold_0_b),		//i--
      .lcb_sg(sg_0),		//i--
      .si(m92_1_so),		//i--
      .so(m92_2_so),		//o--
      .ex2_act(ex2_act),		//i--
      //-------------------
      .c_frac(f_fmt_ex2_c_frac[0:53]),		//i-- Multiplicand (shift me)
      .a_frac({tidn,		//i-- Multiplier (recode me)
               f_fmt_ex2_a_frac[0:16],		//i-- Multiplier (recode me)
               f_fmt_ex2_a_frac_17}),		//i-- Multiplier (recode me)
      .hot_one_out(hot_one_msb_unused),		//o--
      .sum92(pp3_01[0:72]),		//o--
      .car92({xtd_unused,		//o--
              pp3_00[0:72]})		//o--
   );

   ////##################################################
   ////# Compressor Level 4  , 5
   ////##################################################


   tri_fu_mul_62 m62(
      .vdd(vdd),
      .gnd(gnd),
      .hot_one_92(hot_one_92),		//i--
      .hot_one_74(hot_one_74),		//i--
      .pp3_05(pp3_05[36:108]),		//i--
      .pp3_04(pp3_04[35:108]),		//i--
      .pp3_03(pp3_03[18:90]),		//i--
      .pp3_02(pp3_02[17:90]),		//i--
      .pp3_01(pp3_01[0:72]),		//i--
      .pp3_00(pp3_00[0:72]),		//i--

      .sum62(pp5_01[1:108]),		//o--
      .car62(pp5_00[1:108])		//o--
   );

   ////################################################################
   ////# ex3 logic
   ////################################################################

   assign f_mul_ex3_sum[1:108] = pp5_01[1:108];		//output
   assign f_mul_ex3_car[1:108] = pp5_00[1:108];		//output

endmodule
