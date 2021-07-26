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


module fu_byp(
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
   f_byp_si,
   f_byp_so,
   ex1_act,
   f_dcd_ex1_bypsel_a_res0,
   f_dcd_ex1_bypsel_a_res1,
   f_dcd_ex1_bypsel_a_res2,
   f_dcd_ex1_bypsel_a_load0,
   f_dcd_ex1_bypsel_a_load1,
   f_dcd_ex1_bypsel_a_load2,
   f_dcd_ex1_bypsel_a_reload0,
   f_dcd_ex1_bypsel_a_reload1,
   f_dcd_ex1_bypsel_a_reload2,

   f_dcd_ex1_bypsel_b_res0,
   f_dcd_ex1_bypsel_b_res1,
   f_dcd_ex1_bypsel_b_res2,
   f_dcd_ex1_bypsel_b_load0,
   f_dcd_ex1_bypsel_b_load1,
   f_dcd_ex1_bypsel_b_load2,
   f_dcd_ex1_bypsel_b_reload0,
   f_dcd_ex1_bypsel_b_reload1,
   f_dcd_ex1_bypsel_b_reload2,

   f_dcd_ex1_bypsel_c_res0,
   f_dcd_ex1_bypsel_c_res1,
   f_dcd_ex1_bypsel_c_res2,
   f_dcd_ex1_bypsel_c_load0,
   f_dcd_ex1_bypsel_c_load1,
   f_dcd_ex1_bypsel_c_load2,
   f_dcd_ex1_bypsel_c_reload0,
   f_dcd_ex1_bypsel_c_reload1,
   f_dcd_ex1_bypsel_c_reload2,

   f_dcd_ex1_bypsel_s_res0,
   f_dcd_ex1_bypsel_s_res1,
   f_dcd_ex1_bypsel_s_res2,
   f_dcd_ex1_bypsel_s_load0,
   f_dcd_ex1_bypsel_s_load1,
   f_dcd_ex1_bypsel_s_load2,
   f_dcd_ex1_bypsel_s_reload0,
   f_dcd_ex1_bypsel_s_reload1,
   f_dcd_ex1_bypsel_s_reload2,

   f_rnd_ex7_res_sign,
   f_rnd_ex7_res_expo,
   f_rnd_ex7_res_frac,
   f_dcd_ex1_uc_fc_hulp,
   f_dcd_ex1_div_beg,
   f_dcd_ex1_uc_fa_pos,
   f_dcd_ex1_uc_fc_pos,
   f_dcd_ex1_uc_fb_pos,
   f_dcd_ex1_uc_fc_0_5,
   f_dcd_ex1_uc_fc_1_0,
   f_dcd_ex1_uc_fc_1_minus,
   f_dcd_ex1_uc_fb_1_0,
   f_dcd_ex1_uc_fb_0_75,
   f_dcd_ex1_uc_fb_0_5,
   f_fpr_ex8_frt_sign,
   f_fpr_ex8_frt_expo,
   f_fpr_ex8_frt_frac,
   f_fpr_ex9_frt_sign,
   f_fpr_ex9_frt_expo,
   f_fpr_ex9_frt_frac,

   f_fpr_ex6_load_sign,
   f_fpr_ex6_load_expo,
   f_fpr_ex6_load_frac,
   f_fpr_ex7_load_sign,
   f_fpr_ex7_load_expo,
   f_fpr_ex7_load_frac,
   f_fpr_ex8_load_sign,
   f_fpr_ex8_load_expo,
   f_fpr_ex8_load_frac,

   f_fpr_ex6_reload_sign,
   f_fpr_ex6_reload_expo,
   f_fpr_ex6_reload_frac,
   f_fpr_ex7_reload_sign,
   f_fpr_ex7_reload_expo,
   f_fpr_ex7_reload_frac,
   f_fpr_ex8_reload_sign,
   f_fpr_ex8_reload_expo,
   f_fpr_ex8_reload_frac,

   f_fpr_ex1_a_sign,
   f_fpr_ex1_a_expo,
   f_fpr_ex1_a_frac,
   f_fpr_ex1_c_sign,
   f_fpr_ex1_c_expo,
   f_fpr_ex1_c_frac,
   f_fpr_ex1_b_sign,
   f_fpr_ex1_b_expo,
   f_fpr_ex1_b_frac,
   f_fpr_ex1_s_sign,
   f_fpr_ex1_s_expo,
   f_fpr_ex1_s_frac,
   f_dcd_ex1_aop_valid,
   f_dcd_ex1_cop_valid,
   f_dcd_ex1_bop_valid,
   f_dcd_ex1_sp,
   f_dcd_ex1_to_integer_b,
   f_dcd_ex1_emin_dp,
   f_dcd_ex1_emin_sp,
   f_byp_ex1_s_sign,
   f_byp_ex1_s_expo,
   f_byp_ex1_s_frac,
   f_byp_fmt_ex2_a_expo,
   f_byp_fmt_ex2_c_expo,
   f_byp_fmt_ex2_b_expo,
   f_byp_eie_ex2_a_expo,
   f_byp_eie_ex2_c_expo,
   f_byp_eie_ex2_b_expo,
   f_byp_alg_ex2_a_expo,
   f_byp_alg_ex2_c_expo,
   f_byp_alg_ex2_b_expo,
   f_byp_fmt_ex2_a_sign,
   f_byp_fmt_ex2_c_sign,
   f_byp_fmt_ex2_b_sign,
   f_byp_pic_ex2_a_sign,
   f_byp_pic_ex2_c_sign,
   f_byp_pic_ex2_b_sign,
   f_byp_alg_ex2_b_sign,
   f_byp_fmt_ex2_a_frac,
   f_byp_fmt_ex2_c_frac,
   f_byp_fmt_ex2_b_frac,
   f_byp_alg_ex2_b_frac,
   f_byp_mul_ex2_a_frac,
   f_byp_mul_ex2_a_frac_17,
   f_byp_mul_ex2_a_frac_35,
   f_byp_mul_ex2_c_frac
);
   inout            vdd;
   inout            gnd;
   input            clkoff_b;		// tiup
   input            act_dis;		// ??tidn??
   input            flush;		// ??tidn??
   input            delay_lclkr;		// tidn,
   input            mpw1_b;		// tidn,
   input            mpw2_b;		// tidn,
   input            sg_1;
   input            thold_1;
   input            fpu_enable;		//dc_act
   input  [0:`NCLK_WIDTH-1]           nclk;

   input            f_byp_si;		//perv
   output           f_byp_so;		//perv
   input            ex1_act;		//act

   input            f_dcd_ex1_bypsel_a_res0;
   input            f_dcd_ex1_bypsel_a_res1;
   input            f_dcd_ex1_bypsel_a_res2;
   input            f_dcd_ex1_bypsel_a_load0;
   input            f_dcd_ex1_bypsel_a_load1;
   input            f_dcd_ex1_bypsel_a_load2;
   input            f_dcd_ex1_bypsel_a_reload0;
   input            f_dcd_ex1_bypsel_a_reload1;
   input            f_dcd_ex1_bypsel_a_reload2;

   input            f_dcd_ex1_bypsel_b_res0;
   input            f_dcd_ex1_bypsel_b_res1;
   input            f_dcd_ex1_bypsel_b_res2;
   input            f_dcd_ex1_bypsel_b_load0;
   input            f_dcd_ex1_bypsel_b_load1;
   input            f_dcd_ex1_bypsel_b_load2;
   input            f_dcd_ex1_bypsel_b_reload0;
   input            f_dcd_ex1_bypsel_b_reload1;
   input            f_dcd_ex1_bypsel_b_reload2;

   input            f_dcd_ex1_bypsel_c_res0;
   input            f_dcd_ex1_bypsel_c_res1;
   input            f_dcd_ex1_bypsel_c_res2;
   input            f_dcd_ex1_bypsel_c_load0;
   input            f_dcd_ex1_bypsel_c_load1;
   input            f_dcd_ex1_bypsel_c_load2;
   input            f_dcd_ex1_bypsel_c_reload0;
   input            f_dcd_ex1_bypsel_c_reload1;
   input            f_dcd_ex1_bypsel_c_reload2;

   input            f_dcd_ex1_bypsel_s_res0;
   input            f_dcd_ex1_bypsel_s_res1;
   input            f_dcd_ex1_bypsel_s_res2;
   input            f_dcd_ex1_bypsel_s_load0;
   input            f_dcd_ex1_bypsel_s_load1;
   input            f_dcd_ex1_bypsel_s_load2;
   input            f_dcd_ex1_bypsel_s_reload0;
   input            f_dcd_ex1_bypsel_s_reload1;
   input            f_dcd_ex1_bypsel_s_reload2;

   input            f_rnd_ex7_res_sign;
   input [1:13]     f_rnd_ex7_res_expo;
   input [0:52]     f_rnd_ex7_res_frac;
   input            f_dcd_ex1_uc_fc_hulp;

   input            f_dcd_ex1_div_beg;
   input            f_dcd_ex1_uc_fa_pos;
   input            f_dcd_ex1_uc_fc_pos;
   input            f_dcd_ex1_uc_fb_pos;
   input            f_dcd_ex1_uc_fc_0_5;
   input            f_dcd_ex1_uc_fc_1_0;
   input            f_dcd_ex1_uc_fc_1_minus;
   input            f_dcd_ex1_uc_fb_1_0;
   input            f_dcd_ex1_uc_fb_0_75;
   input            f_dcd_ex1_uc_fb_0_5;

   input            f_fpr_ex8_frt_sign;
   input [1:13]     f_fpr_ex8_frt_expo;
   input [0:52]     f_fpr_ex8_frt_frac;
   input            f_fpr_ex9_frt_sign;
   input [1:13]     f_fpr_ex9_frt_expo;
   input [0:52]     f_fpr_ex9_frt_frac;

   input            f_fpr_ex6_load_sign;
   input [3:13]     f_fpr_ex6_load_expo;
   input [0:52]     f_fpr_ex6_load_frac;
   input            f_fpr_ex7_load_sign;
   input [3:13]     f_fpr_ex7_load_expo;
   input [0:52]     f_fpr_ex7_load_frac;
   input            f_fpr_ex8_load_sign;
   input [3:13]     f_fpr_ex8_load_expo;
   input [0:52]     f_fpr_ex8_load_frac;

   input            f_fpr_ex6_reload_sign;
   input [3:13]     f_fpr_ex6_reload_expo;
   input [0:52]     f_fpr_ex6_reload_frac;
   input            f_fpr_ex7_reload_sign;
   input [3:13]     f_fpr_ex7_reload_expo;
   input [0:52]     f_fpr_ex7_reload_frac;
   input            f_fpr_ex8_reload_sign;
   input [3:13]     f_fpr_ex8_reload_expo;
   input [0:52]     f_fpr_ex8_reload_frac;


   input            f_fpr_ex1_a_sign;
   input [1:13]     f_fpr_ex1_a_expo;
   input [0:52]     f_fpr_ex1_a_frac;		//[0] is implicit bit

   input            f_fpr_ex1_c_sign;
   input [1:13]     f_fpr_ex1_c_expo;
   input [0:52]     f_fpr_ex1_c_frac;		//[0] is implicit bit

   input            f_fpr_ex1_b_sign;
   input [1:13]     f_fpr_ex1_b_expo;
   input [0:52]     f_fpr_ex1_b_frac;		//[0] is implicit bit

   input            f_fpr_ex1_s_sign;
   input [3:13]     f_fpr_ex1_s_expo;
   input [0:52]     f_fpr_ex1_s_frac;		//[0] is implicit bit

   input            f_dcd_ex1_aop_valid;
   input            f_dcd_ex1_cop_valid;
   input            f_dcd_ex1_bop_valid;
   input            f_dcd_ex1_sp;
   input            f_dcd_ex1_to_integer_b;
   input            f_dcd_ex1_emin_dp;
   input            f_dcd_ex1_emin_sp;

   output           f_byp_ex1_s_sign;
   output [3:13]    f_byp_ex1_s_expo;
   output [0:52]    f_byp_ex1_s_frac;

   output [1:13]    f_byp_fmt_ex2_a_expo;
   output [1:13]    f_byp_fmt_ex2_c_expo;
   output [1:13]    f_byp_fmt_ex2_b_expo;
   output [1:13]    f_byp_eie_ex2_a_expo;
   output [1:13]    f_byp_eie_ex2_c_expo;
   output [1:13]    f_byp_eie_ex2_b_expo;
   output [1:13]    f_byp_alg_ex2_a_expo;
   output [1:13]    f_byp_alg_ex2_c_expo;
   output [1:13]    f_byp_alg_ex2_b_expo;

   output           f_byp_fmt_ex2_a_sign;
   output           f_byp_fmt_ex2_c_sign;
   output           f_byp_fmt_ex2_b_sign;
   output           f_byp_pic_ex2_a_sign;
   output           f_byp_pic_ex2_c_sign;
   output           f_byp_pic_ex2_b_sign;
   output           f_byp_alg_ex2_b_sign;

   output [0:52]    f_byp_fmt_ex2_a_frac;
   output [0:52]    f_byp_fmt_ex2_c_frac;
   output [0:52]    f_byp_fmt_ex2_b_frac;
   output [0:52]    f_byp_alg_ex2_b_frac;
   output [0:52]    f_byp_mul_ex2_a_frac;		//mul
   output           f_byp_mul_ex2_a_frac_17;		//mul
   output           f_byp_mul_ex2_a_frac_35;		//mul
   output [0:53]    f_byp_mul_ex2_c_frac;		//mul

   // ENTITY


   parameter        tiup = 1'b1;
   parameter        tidn = 1'b0;
   parameter [1:13] k_emin_dp = 13'b0000000000001;
   parameter [1:13] k_emin_sp = 13'b0001110000001;
   parameter [1:13] k_toint = 13'b0010001101001;
   parameter [1:13] expo_zero = 13'b0000000000001;
   parameter [1:13] expo_bias = 13'b0001111111111;
   parameter [1:13] expo_bias_m1 = 13'b0001111111110;
   //--------------------------------
   // 57-bias is done after Ea+Ec-Eb
   //--------------------------------
   // bias + 162 - 56
   // bias + 106        1023+106 = 1129
   //
   // 0_0011_1111_1111
   //         110 1010 106 =
   //-----------------------------
   // 0 0100 0110 1001
   //-----------------------------

   wire [1:13]      ex1_c_k_expo;
   wire [1:13]      ex1_b_k_expo;
   wire [1:13]      ex1_a_k_expo;
   wire [0:52]      ex1_a_k_frac;
   wire [0:52]      ex1_c_k_frac;
   wire [0:52]      ex1_b_k_frac;

   wire [1:13]      ex1_a_expo_prebyp;
   wire [1:13]      ex1_c_expo_prebyp;
   wire [1:13]      ex1_b_expo_prebyp;
   wire [1:13]      ex1_s_expo_prebyp;
   wire [0:52]      ex1_a_frac_prebyp;
   wire [0:52]      ex1_c_frac_prebyp;
   wire [0:52]      ex1_b_frac_prebyp;
   wire [0:52]      ex1_s_frac_prebyp;
   wire             ex1_a_sign_prebyp;
   wire             ex1_c_sign_prebyp;
   wire             ex1_b_sign_prebyp;
   wire             ex1_s_sign_prebyp;

   wire             ex1_a_sign_pre1_b;
   wire             ex1_a_sign_pre2_b;
   wire             ex1_a_sign_pre;
   wire             ex1_c_sign_pre1_b;
   wire             ex1_c_sign_pre2_b;
   wire             ex1_c_sign_pre;
   wire             ex1_b_sign_pre1_b;
   wire             ex1_b_sign_pre2_b;
   wire             ex1_b_sign_pre;
   wire             ex1_s_sign_pre1_b;
   wire             ex1_s_sign_pre2_b;
   wire             ex1_s_sign_pre;

   wire             aop_valid_sign;
   wire             cop_valid_sign;
   wire             bop_valid_sign;
   wire             aop_valid_plus;
   wire             cop_valid_plus;
   wire             bop_valid_plus;

   wire [0:3]       spare_unused;
   wire             unused;
   wire             thold_0;
   wire             force_t;
   wire             thold_0_b;
   wire             sg_0;

   wire [0:52]      ex2_b_frac_si;
   wire [0:52]      ex2_b_frac_so;
   wire [0:52]      ex2_frac_a_fmt_si;
   wire [0:52]      ex2_frac_a_fmt_so;
   wire [0:52]      ex2_frac_c_fmt_si;
   wire [0:52]      ex2_frac_c_fmt_so;
   wire [0:52]      ex2_frac_b_fmt_si;
   wire [0:52]      ex2_frac_b_fmt_so;
   wire [0:53]      frac_mul_c_si;
   wire [0:53]      frac_mul_c_so;
   wire [0:54]      frac_mul_a_si;
   wire [0:54]      frac_mul_a_so;

   wire [0:13]      ex2_expo_a_eie_si;
   wire [0:13]      ex2_expo_a_eie_so;
   wire [0:13]      ex2_expo_b_eie_si;
   wire [0:13]      ex2_expo_b_eie_so;
   wire [0:13]      ex2_expo_c_eie_si;
   wire [0:13]      ex2_expo_c_eie_so;
   wire [0:13]      ex2_expo_a_fmt_si;
   wire [0:13]      ex2_expo_a_fmt_so;
   wire [0:13]      ex2_expo_b_fmt_si;
   wire [0:13]      ex2_expo_b_fmt_so;
   wire [0:13]      ex2_expo_c_fmt_si;
   wire [0:13]      ex2_expo_c_fmt_so;
   wire [0:13]      ex2_expo_b_alg_si;
   wire [0:13]      ex2_expo_b_alg_so;
   wire [0:12]      ex2_expo_a_alg_si;
   wire [0:12]      ex2_expo_a_alg_so;
   wire [0:12]      ex2_expo_c_alg_si;
   wire [0:12]      ex2_expo_c_alg_so;

   wire [0:3]       act_si;
   wire [0:3]       act_so;


   wire             sel_a_no_byp_s;
   wire             sel_c_no_byp_s;
   wire             sel_b_no_byp_s;
   wire             sel_s_no_byp_s;
   wire             sel_a_res0_s;
   wire             sel_a_res1_s;
   wire             sel_a_load0_s;
   wire             sel_a_reload0_s;
   wire             sel_a_load1_s;
   wire             sel_c_res0_s;
   wire             sel_c_res1_s;
   wire             sel_c_load0_s;
   wire             sel_c_reload0_s;
   wire             sel_c_load1_s;
   wire             sel_b_res0_s;
   wire             sel_b_res1_s;
   wire             sel_b_load0_s;
   wire             sel_b_reload0_s;
   wire             sel_b_load1_s;
   wire             sel_s_res0_s;
   wire             sel_s_res1_s;
   wire             sel_s_load0_s;
   wire             sel_s_reload0_s;
   wire             sel_s_load1_s;

   wire             sel_a_no_byp;
   wire             sel_c_no_byp;
   wire             sel_b_no_byp;
   wire             sel_s_no_byp;

   wire             sel_a_imm;
   wire             sel_a_res0;
   wire             sel_a_res1;
   wire             sel_a_load0;
   wire             sel_a_reload0;
   wire             sel_b_reload0;
   wire             sel_c_reload0;
   wire             sel_s_reload0;

   wire             sel_a_load1;
   wire             sel_c_imm;
   wire             sel_c_res0;
   wire             sel_c_res1;
   wire             sel_c_load0;
   wire             sel_c_load1;
   wire             sel_b_imm;
   wire             sel_b_res0;
   wire             sel_b_res1;
   wire             sel_b_load0;
   wire             sel_b_load1;
   wire             sel_s_imm;
   wire             sel_s_res0;
   wire             sel_s_res1;
   wire             sel_s_load0;
   wire             sel_s_load1;

   wire [1:13]      ex6_load_expo;
   wire [1:13]      ex6_reload_expo;

   wire [0:52]      ex1_b_frac_alg_b;
   wire [0:52]      ex2_b_frac_alg_b;
   wire [0:52]      ex1_a_frac_fmt_b;
   wire [0:52]      ex2_a_frac_fmt_b;
   wire [0:52]      ex1_c_frac_fmt_b;
   wire [0:52]      ex2_c_frac_fmt_b;
   wire [0:52]      ex1_b_frac_fmt_b;
   wire [0:52]      ex2_b_frac_fmt_b;
   wire             ex2_a_frac_mul_17_b;
   wire             ex2_a_frac_mul_35_b;
   wire [0:52]      ex2_a_frac_mul_b;
   wire [0:53]      ex2_c_frac_mul_b;
   wire             ex1_a_frac_mul_17_b;
   wire             ex1_a_frac_mul_35_b;
   wire [0:52]      ex1_a_frac_mul_b;
   wire [0:53]      ex1_c_frac_mul_b;
   wire             ex1_b_sign_alg_b;
   wire             ex2_b_sign_alg_b;
   wire [1:13]      ex1_b_expo_alg_b;
   wire [1:13]      ex2_b_expo_alg_b;
   wire [1:13]      ex1_c_expo_alg_b;
   wire [1:13]      ex2_c_expo_alg_b;
   wire [1:13]      ex1_a_expo_alg_b;
   wire [1:13]      ex2_a_expo_alg_b;
   wire             ex1_a_sign_fmt_b;
   wire             ex2_a_sign_fmt_b;
   wire [1:13]      ex1_a_expo_fmt_b;
   wire [1:13]      ex2_a_expo_fmt_b;
   wire             ex1_c_sign_fmt_b;
   wire             ex2_c_sign_fmt_b;
   wire [1:13]      ex1_c_expo_fmt_b;
   wire [1:13]      ex2_c_expo_fmt_b;
   wire             ex1_b_sign_fmt_b;
   wire             ex2_b_sign_fmt_b;
   wire [1:13]      ex1_b_expo_fmt_b;
   wire [1:13]      ex2_b_expo_fmt_b;
   wire             ex1_a_sign_pic_b;
   wire             ex2_a_sign_pic_b;
   wire [1:13]      ex1_a_expo_eie_b;
   wire [1:13]      ex2_a_expo_eie_b;
   wire             ex1_c_sign_pic_b;
   wire             ex2_c_sign_pic_b;
   wire [1:13]      ex1_c_expo_eie_b;
   wire [1:13]      ex2_c_expo_eie_b;
   wire             ex1_b_sign_pic_b;
   wire             ex2_b_sign_pic_b;
   wire [1:13]      ex1_b_expo_eie_b;
   wire [1:13]      ex2_b_expo_eie_b;
   wire             cop_uc_imm;
   wire             bop_uc_imm;

   wire             ex1_a_sign_fpr;
   wire             ex1_c_sign_fpr;
   wire             ex1_b_sign_fpr;
   wire             ex1_s_sign_fpr;
   wire [1:13]      ex1_a_expo_fpr;
   wire [1:13]      ex1_c_expo_fpr;
   wire [1:13]      ex1_b_expo_fpr;
   wire [1:13]      ex1_s_expo_fpr;
   wire [0:52]      ex1_a_frac_fpr;
   wire [0:52]      ex1_c_frac_fpr;
   wire [0:52]      ex1_b_frac_fpr;
   wire [0:52]      ex1_s_frac_fpr;

   wire             ex7_sign_res_ear;
   wire             ex7_sign_a_res_dly;
   wire             ex7_sign_c_res_dly;
   wire             ex7_sign_b_res_dly;
   wire             ex7_sign_s_res_dly;
   wire             ex6_sign_lod_ear;
   wire             ex6_sign_relod_ear;

   wire             ex7_sign_a_lod_dly;
   wire             ex7_sign_c_lod_dly;
   wire             ex7_sign_b_lod_dly;
   wire             ex7_sign_s_lod_dly;

   wire [1:13]      ex7_expo_res_ear;
   wire [1:13]      ex7_expo_a_res_dly;
   wire [1:13]      ex7_expo_c_res_dly;
   wire [1:13]      ex7_expo_b_res_dly;
   wire [1:13]      ex7_expo_s_res_dly;
   wire [1:13]      ex6_expo_lod_ear;
   wire [1:13]      ex6_expo_relod_ear;
   wire [1:13]      ex7_expo_a_lod_dly;
   wire [1:13]      ex7_expo_c_lod_dly;
   wire [1:13]      ex7_expo_b_lod_dly;
   wire [1:13]      ex7_expo_s_lod_dly;
   wire [0:52]      ex7_frac_res_ear;
   wire [0:52]      ex7_frac_a_res_dly;
   wire [0:52]      ex7_frac_c_res_dly;
   wire [0:52]      ex7_frac_b_res_dly;
   wire [0:52]      ex7_frac_s_res_dly;
   wire [0:52]      ex6_frac_lod_ear;
   wire [0:52]      ex6_frac_relod_ear;
   wire [0:52]      ex7_frac_a_lod_dly;
   wire [0:52]      ex7_frac_c_lod_dly;
   wire [0:52]      ex7_frac_b_lod_dly;
   wire [0:52]      ex7_frac_s_lod_dly;
   wire [1:13]      ex1_a_expo_pre1_b;
   wire [1:13]      ex1_c_expo_pre1_b;
   wire [1:13]      ex1_b_expo_pre1_b;
   wire [1:13]      ex1_s_expo_pre1_b;
   wire [1:13]      ex1_a_expo_pre2_b;
   wire [1:13]      ex1_c_expo_pre2_b;
   wire [1:13]      ex1_b_expo_pre2_b;
   wire [1:13]      ex1_s_expo_pre2_b;
   wire [1:13]      ex1_a_expo_pre3_b;
   wire [1:13]      ex1_c_expo_pre3_b;
   wire [1:13]      ex1_b_expo_pre3_b;
   wire [1:13]      ex1_s_expo_pre3_b;
   wire [1:13]      ex1_a_expo_pre;
   wire [1:13]      ex1_c_expo_pre;
   wire [1:13]      ex1_s_expo_pre;
   wire [1:13]      ex1_b_expo_pre;
   wire [0:52]      ex1_a_frac_pre;
   wire [0:52]      ex1_c_frac_pre;
   wire [0:52]      ex1_b_frac_pre;
   wire [0:52]      ex1_s_frac_pre;
   wire [0:52]      ex1_a_frac_pre1_b;
   wire [0:52]      ex1_a_frac_pre2_b;
   wire [0:52]      ex1_c_frac_pre1_b;
   wire [0:52]      ex1_c_frac_pre2_b;
   wire [0:52]      ex1_c_frac_pre3_b;
   wire [0:52]      ex1_b_frac_pre1_b;
   wire [0:52]      ex1_b_frac_pre2_b;
   wire [0:1]       ex1_b_frac_pre3_b;
   wire [0:52]      ex1_s_frac_pre1_b;
   wire [0:52]      ex1_s_frac_pre2_b;

   wire             byp_ex2_d1clk;
   wire             byp_ex2_d2clk;
   wire  [0:`NCLK_WIDTH-1]            byp_ex2_lclk;
   wire             ex1_c_frac_pre3_hulp_b;
   wire             ex1_hulp_sp;
   wire             ex1_c_frac_pre_hulp;
   wire             ex1_c_frac_prebyp_hulp;

   wire [0:53]      temp_ex1_c_frac_mul;
   wire [0:52]      temp_ex1_a_frac_mul;
   wire             temp_ex1_a_frac_mul_17;
   wire             temp_ex1_a_frac_mul_35;


   // REPOWER_MODE=/SERIAL/

   //AOI22_e5n_sn08b SP/UNDEF
   //AOI22_e5n_sn08b SP/UNDEF
   //AOI22_e5n_sn08b SP/UNDEF
   //AOI22_e5n_sn08b SP/UNDEF

   // unique aoi to latch input


   wire [0:52]      ex2_b_frac_alg;
   wire [0:52]      ex2_b_frac_fmt;
   wire [0:52]      ex2_a_frac_fmt;
   wire [0:52]      ex2_c_frac_fmt;
   wire             ex2_b_sign_alg;
   wire             ex2_b_sign_fmt;
   wire             ex2_a_sign_fmt;
   wire             ex2_c_sign_fmt;
   wire             ex2_b_sign_pic;
   wire             ex2_a_sign_pic;
   wire             ex2_c_sign_pic;
   wire [1:13]      ex2_b_expo_alg;
   wire [1:13]      ex2_a_expo_alg;
   wire [1:13]      ex2_c_expo_alg;
   wire [1:13]      ex2_b_expo_fmt;
   wire [1:13]      ex2_a_expo_fmt;
   wire [1:13]      ex2_c_expo_fmt;
   wire [1:13]      ex2_b_expo_eie;
   wire [1:13]      ex2_a_expo_eie;
   wire [1:13]      ex2_c_expo_eie;

   assign unused = ex1_a_expo_pre3_b[1] | ex1_a_expo_pre3_b[2] | ex1_c_expo_pre3_b[1] | ex1_c_expo_pre3_b[2] | ex1_c_expo_pre3_b[3] | ex1_b_expo_pre3_b[1] |
                   ex1_b_expo_pre3_b[2] | ex1_b_expo_pre3_b[3] | ex1_a_k_expo[1] | ex1_a_k_expo[2] | |(ex1_c_k_expo[1:12]) | |(ex1_b_k_expo[1:3]) |
                   |(ex1_a_k_frac[0:52]) | |(ex1_b_k_frac[2:52]);

   //#=##############################################################
   //# pervasive
   //#=##############################################################


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

   //#=##############################################################
   //# act
   //#=##############################################################


   tri_rlmreg_p #(.WIDTH(4),  .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(fpu_enable),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(act_so),
      .scin(act_si),
      //-----------------
      .din({spare_unused[0],
            spare_unused[1],
            spare_unused[2],
            spare_unused[3]}),
      //-----------------
      .dout({spare_unused[0],
             spare_unused[1],
             spare_unused[2],
             spare_unused[3]})
   );


   tri_lcbnd  byp_ex2_lcb(
      .delay_lclkr(delay_lclkr),		// tidn ,--in
      .mpw1_b(mpw1_b),		// tidn ,--in
      .mpw2_b(mpw2_b),		// tidn ,--in
      .force_t(force_t),		// tidn ,--in
      .nclk(nclk),		//in
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .act(ex1_act),		//in
      .sg(sg_0),		//in
      .thold_b(thold_0_b),		//in
      .d1clk(byp_ex2_d1clk),		//out
      .d2clk(byp_ex2_d2clk),		//out
      .lclk(byp_ex2_lclk)		//out
   );

   //=================================================
   // Constants for the immediate data
   //=================================================

   // k_emin_dp           "0000000000001";
   // k_emin_sp(1 to 13)  "0001110000001";
   // k_toint  (1 to 13)  "0010001101001";

   assign ex1_a_k_expo[1:2] = {tidn, tidn};
   assign ex1_a_k_expo[3:13] = ({11{(~f_dcd_ex1_to_integer_b)}} & k_toint[3:13]) |
                               ({11{f_dcd_ex1_emin_dp}} & k_emin_dp[3:13]) |
                               ({11{f_dcd_ex1_emin_sp}} & k_emin_sp[3:13]);

   // expo_bias     "0001111111111";
   // expo_bias_m1  "0001111111110";

   assign ex1_c_k_expo[1:3] = {tidn, tidn, tidn};
   assign ex1_c_k_expo[4:12] = {9{tiup}};
   // non divide
   // div/sqrt
   assign ex1_c_k_expo[13] = ((~cop_uc_imm) & expo_bias[13]) |
                              (f_dcd_ex1_uc_fc_1_0 & expo_bias[13]) |
                              (f_dcd_ex1_uc_fc_0_5 & expo_bias_m1[13]) |
                              (f_dcd_ex1_uc_fc_1_minus & expo_bias_m1[13]);		// div/sqrt
   // div/sqrt

   // expo_zero(1 to 13)  "0000000000001";
   // expo_bias           "0001111111111";
   // expo_bias_m1        "0001111111110";

   assign ex1_b_k_expo[1:3] = {tidn, tidn, tidn};
   // non divide
   // div/sqrt
   assign ex1_b_k_expo[4:13] = ({10{(~bop_uc_imm)}} & expo_zero[4:13]) |
                                ({10{f_dcd_ex1_uc_fb_1_0}} & expo_bias[4:13]) |
                                ({10{f_dcd_ex1_uc_fb_0_5}} & expo_bias_m1[4:13]) |
                                ({10{f_dcd_ex1_uc_fb_0_75}} & expo_bias_m1[4:13]);		// div/sqrt
   // div/sqrt

   assign ex1_a_k_frac[0:52] = {53{tidn}};

   // c is invalid for divide , a is valid ... but want multiplier output to be zero for divide first step (prenorm)
   assign ex1_c_k_frac[0] = (~f_dcd_ex1_div_beg);		// tiup ;
   assign ex1_c_k_frac[1:52] = {52{f_dcd_ex1_uc_fc_1_minus}};

   assign ex1_b_k_frac[0] = bop_uc_imm;
   assign ex1_b_k_frac[1] = f_dcd_ex1_uc_fb_0_75;
   assign ex1_b_k_frac[2:52] = {51{tidn}};

   //=====================================================================
   // selects for operand bypass muxes (also known as: data forwarding )
   //=====================================================================

   // forcing invalid causes selection of immediate data

   assign cop_uc_imm = f_dcd_ex1_uc_fc_0_5 | f_dcd_ex1_uc_fc_1_0 | f_dcd_ex1_uc_fc_1_minus;
   assign bop_uc_imm = f_dcd_ex1_uc_fb_0_5 | f_dcd_ex1_uc_fb_1_0 | f_dcd_ex1_uc_fb_0_75;

   assign aop_valid_sign = (f_dcd_ex1_aop_valid & (~f_dcd_ex1_uc_fa_pos));		// or (not f_dcd_ex1_sgncpy_b)
   assign cop_valid_sign = (f_dcd_ex1_cop_valid & (~f_dcd_ex1_uc_fc_pos) & (~cop_uc_imm));
   assign bop_valid_sign = (f_dcd_ex1_bop_valid & (~f_dcd_ex1_uc_fb_pos) & (~bop_uc_imm));

   assign aop_valid_plus = (f_dcd_ex1_aop_valid);		// or (not f_dcd_ex1_sgncpy_b) ;
   assign cop_valid_plus = (f_dcd_ex1_cop_valid & (~cop_uc_imm));
   assign bop_valid_plus = (f_dcd_ex1_bop_valid & (~bop_uc_imm));

   assign sel_a_no_byp_s = (~(f_dcd_ex1_bypsel_a_res0 | f_dcd_ex1_bypsel_a_res1 | f_dcd_ex1_bypsel_a_res2 | f_dcd_ex1_bypsel_a_reload0 | f_dcd_ex1_bypsel_a_reload1 | f_dcd_ex1_bypsel_a_reload2 | f_dcd_ex1_bypsel_a_load0 | f_dcd_ex1_bypsel_a_load1 | f_dcd_ex1_bypsel_a_load2 | (~aop_valid_sign)));
   assign sel_c_no_byp_s = (~(f_dcd_ex1_bypsel_c_res0 | f_dcd_ex1_bypsel_c_res1 | f_dcd_ex1_bypsel_c_res2 | f_dcd_ex1_bypsel_c_reload0 | f_dcd_ex1_bypsel_c_reload1 | f_dcd_ex1_bypsel_c_reload2 | f_dcd_ex1_bypsel_c_load0 | f_dcd_ex1_bypsel_c_load1 | f_dcd_ex1_bypsel_c_load2 | (~cop_valid_sign)));
   assign sel_b_no_byp_s = (~(f_dcd_ex1_bypsel_b_res0 | f_dcd_ex1_bypsel_b_res1 | f_dcd_ex1_bypsel_b_res2 | f_dcd_ex1_bypsel_b_reload0 | f_dcd_ex1_bypsel_b_reload1 | f_dcd_ex1_bypsel_b_reload2 | f_dcd_ex1_bypsel_b_load0 | f_dcd_ex1_bypsel_b_load1 | f_dcd_ex1_bypsel_b_load2 | (~bop_valid_sign)));
   assign sel_s_no_byp_s = (~(f_dcd_ex1_bypsel_s_res0 | f_dcd_ex1_bypsel_s_res1 | f_dcd_ex1_bypsel_s_res2 | f_dcd_ex1_bypsel_s_reload0 | f_dcd_ex1_bypsel_s_reload1 | f_dcd_ex1_bypsel_s_reload2 | f_dcd_ex1_bypsel_s_load0 | f_dcd_ex1_bypsel_s_load1 | f_dcd_ex1_bypsel_s_load2 ));

   assign sel_a_no_byp = (~(f_dcd_ex1_bypsel_a_res0 | f_dcd_ex1_bypsel_a_res1 | f_dcd_ex1_bypsel_a_res2 | f_dcd_ex1_bypsel_a_reload0 | f_dcd_ex1_bypsel_a_reload1 | f_dcd_ex1_bypsel_a_reload2 | f_dcd_ex1_bypsel_a_load0 | f_dcd_ex1_bypsel_a_load1 | f_dcd_ex1_bypsel_a_load2 | (~aop_valid_plus)));
   assign sel_c_no_byp = (~(f_dcd_ex1_bypsel_c_res0 | f_dcd_ex1_bypsel_c_res1 | f_dcd_ex1_bypsel_c_res2 | f_dcd_ex1_bypsel_c_reload0 | f_dcd_ex1_bypsel_c_reload1 | f_dcd_ex1_bypsel_c_reload2 | f_dcd_ex1_bypsel_c_load0 | f_dcd_ex1_bypsel_c_load1 | f_dcd_ex1_bypsel_c_load2 | (~cop_valid_plus)));
   assign sel_b_no_byp = (~(f_dcd_ex1_bypsel_b_res0 | f_dcd_ex1_bypsel_b_res1 | f_dcd_ex1_bypsel_b_res2 | f_dcd_ex1_bypsel_b_reload0 | f_dcd_ex1_bypsel_b_reload1 | f_dcd_ex1_bypsel_b_reload2 | f_dcd_ex1_bypsel_b_load0 | f_dcd_ex1_bypsel_b_load1 | f_dcd_ex1_bypsel_b_load2 | (~bop_valid_plus)));
   assign sel_s_no_byp = (~(f_dcd_ex1_bypsel_s_res0 | f_dcd_ex1_bypsel_s_res1 | f_dcd_ex1_bypsel_s_res2 | f_dcd_ex1_bypsel_s_reload0 | f_dcd_ex1_bypsel_s_reload1 | f_dcd_ex1_bypsel_s_reload2 | f_dcd_ex1_bypsel_s_load0 | f_dcd_ex1_bypsel_s_load1 | f_dcd_ex1_bypsel_s_load2));

   assign sel_a_res0_s = aop_valid_sign & f_dcd_ex1_bypsel_a_res0;
   assign sel_a_res1_s = aop_valid_sign & (f_dcd_ex1_bypsel_a_res1 | f_dcd_ex1_bypsel_a_res2);
   assign sel_a_load0_s = aop_valid_sign & f_dcd_ex1_bypsel_a_load0;
   assign sel_a_reload0_s = aop_valid_sign & f_dcd_ex1_bypsel_a_reload0;

   assign sel_a_load1_s = aop_valid_sign & (f_dcd_ex1_bypsel_a_load1 | f_dcd_ex1_bypsel_a_load2 | f_dcd_ex1_bypsel_a_reload1 | f_dcd_ex1_bypsel_a_reload2);

   assign sel_c_res0_s = cop_valid_sign & f_dcd_ex1_bypsel_c_res0;
   assign sel_c_res1_s = cop_valid_sign & (f_dcd_ex1_bypsel_c_res1 | f_dcd_ex1_bypsel_c_res2);
   assign sel_c_load0_s = cop_valid_sign & f_dcd_ex1_bypsel_c_load0;
   assign sel_c_reload0_s = cop_valid_sign & f_dcd_ex1_bypsel_c_reload0;
   assign sel_c_load1_s = cop_valid_sign & (f_dcd_ex1_bypsel_c_load1 | f_dcd_ex1_bypsel_c_load2 | f_dcd_ex1_bypsel_c_reload1 | f_dcd_ex1_bypsel_c_reload2);

   assign sel_b_res0_s = bop_valid_sign & f_dcd_ex1_bypsel_b_res0;
   assign sel_b_res1_s = bop_valid_sign & (f_dcd_ex1_bypsel_b_res1 | f_dcd_ex1_bypsel_b_res2);
   assign sel_b_load0_s = bop_valid_sign & f_dcd_ex1_bypsel_b_load0;
   assign sel_b_reload0_s = bop_valid_sign & f_dcd_ex1_bypsel_b_reload0;
   assign sel_b_load1_s = bop_valid_sign & (f_dcd_ex1_bypsel_b_load1 | f_dcd_ex1_bypsel_b_load2 | f_dcd_ex1_bypsel_b_reload1 | f_dcd_ex1_bypsel_b_reload2);

   assign sel_s_res0_s = f_dcd_ex1_bypsel_s_res0;
   assign sel_s_res1_s = (f_dcd_ex1_bypsel_s_res1 | f_dcd_ex1_bypsel_s_res2);
   assign sel_s_load0_s = f_dcd_ex1_bypsel_s_load0;
   assign sel_s_reload0_s = f_dcd_ex1_bypsel_s_reload0;
   assign sel_s_load1_s = (f_dcd_ex1_bypsel_s_load1 | f_dcd_ex1_bypsel_s_load2 | f_dcd_ex1_bypsel_s_reload1 | f_dcd_ex1_bypsel_s_reload2);

   assign sel_a_imm = (~aop_valid_plus);
   assign sel_a_res0 = aop_valid_plus & f_dcd_ex1_bypsel_a_res0;
   assign sel_a_res1 = aop_valid_plus & (f_dcd_ex1_bypsel_a_res1 | f_dcd_ex1_bypsel_a_res2);
   assign sel_a_load0 = aop_valid_plus &  f_dcd_ex1_bypsel_a_load0;
   assign sel_a_reload0 = aop_valid_plus &  f_dcd_ex1_bypsel_a_reload0;

   assign sel_a_load1 = aop_valid_plus & (f_dcd_ex1_bypsel_a_load1 | f_dcd_ex1_bypsel_a_load2 | f_dcd_ex1_bypsel_a_reload1 | f_dcd_ex1_bypsel_a_reload2);
   //    sel_a_fpr   <=     aop_valid_plus and sel_a_no_byp ;

   assign sel_c_imm = (~cop_valid_plus);
   assign sel_c_res0 = cop_valid_plus & f_dcd_ex1_bypsel_c_res0;
   assign sel_c_res1 = cop_valid_plus & (f_dcd_ex1_bypsel_c_res1 | f_dcd_ex1_bypsel_c_res2);
   assign sel_c_load0 = cop_valid_plus &  f_dcd_ex1_bypsel_c_load0;
   assign sel_c_reload0 = cop_valid_plus &  f_dcd_ex1_bypsel_c_reload0;

   assign sel_c_load1 = cop_valid_plus & (f_dcd_ex1_bypsel_c_load1 | f_dcd_ex1_bypsel_c_load2 | f_dcd_ex1_bypsel_c_reload1 | f_dcd_ex1_bypsel_c_reload2);
   //    sel_c_fpr   <=     cop_valid_plus and sel_c_no_byp ;

   assign sel_b_imm = (~bop_valid_plus);
   assign sel_b_res0 = bop_valid_plus & f_dcd_ex1_bypsel_b_res0;
   assign sel_b_res1 = bop_valid_plus & (f_dcd_ex1_bypsel_b_res1 | f_dcd_ex1_bypsel_b_res2);
   assign sel_b_load0 = bop_valid_plus &  f_dcd_ex1_bypsel_b_load0;
   assign sel_b_reload0 = bop_valid_plus &  f_dcd_ex1_bypsel_b_reload0;

   assign sel_b_load1 = bop_valid_plus & (f_dcd_ex1_bypsel_b_load1 | f_dcd_ex1_bypsel_b_load2 | f_dcd_ex1_bypsel_b_reload1 | f_dcd_ex1_bypsel_b_reload2);
   //    sel_b_fpr   <=     bop_valid_plus and sel_b_no_byp ;

   assign sel_s_imm = 1'b0;
   assign sel_s_res0 = f_dcd_ex1_bypsel_s_res0;
   assign sel_s_res1 = (f_dcd_ex1_bypsel_s_res1 | f_dcd_ex1_bypsel_s_res2);
   assign sel_s_load0 = f_dcd_ex1_bypsel_s_load0;
   assign sel_s_reload0 = f_dcd_ex1_bypsel_s_reload0;
   assign sel_s_load1 = (f_dcd_ex1_bypsel_s_load1 | f_dcd_ex1_bypsel_s_load2 | f_dcd_ex1_bypsel_s_reload1 | f_dcd_ex1_bypsel_s_reload2);
   //    sel_s_fpr   <=     bop_valid_plus and sel_b_no_byp ;

   //------------------------
   // sign bit data forwarding
   //------------------------

   assign ex7_sign_res_ear = f_rnd_ex7_res_sign;		// may need to manually rebuffer
   assign ex7_sign_a_res_dly = (f_fpr_ex8_frt_sign & f_dcd_ex1_bypsel_a_res1) | (f_fpr_ex9_frt_sign & f_dcd_ex1_bypsel_a_res2);
   assign ex7_sign_b_res_dly = (f_fpr_ex8_frt_sign & f_dcd_ex1_bypsel_b_res1) | (f_fpr_ex9_frt_sign & f_dcd_ex1_bypsel_b_res2);
   assign ex7_sign_c_res_dly = (f_fpr_ex8_frt_sign & f_dcd_ex1_bypsel_c_res1) | (f_fpr_ex9_frt_sign & f_dcd_ex1_bypsel_c_res2);
   assign ex7_sign_s_res_dly = (f_fpr_ex8_frt_sign & f_dcd_ex1_bypsel_s_res1) | (f_fpr_ex9_frt_sign & f_dcd_ex1_bypsel_s_res2);
   assign ex6_sign_lod_ear = f_fpr_ex6_load_sign;
   assign ex6_sign_relod_ear = f_fpr_ex6_reload_sign;
   assign ex7_sign_a_lod_dly = (f_fpr_ex7_load_sign & f_dcd_ex1_bypsel_a_load1) | (f_fpr_ex8_load_sign & f_dcd_ex1_bypsel_a_load2 | f_fpr_ex7_reload_sign & f_dcd_ex1_bypsel_a_reload1) | (f_fpr_ex8_reload_sign & f_dcd_ex1_bypsel_a_reload2);
   assign ex7_sign_b_lod_dly = (f_fpr_ex7_load_sign & f_dcd_ex1_bypsel_b_load1) | (f_fpr_ex8_load_sign & f_dcd_ex1_bypsel_b_load2 | f_fpr_ex7_reload_sign & f_dcd_ex1_bypsel_b_reload1) | (f_fpr_ex8_reload_sign & f_dcd_ex1_bypsel_b_reload2);
   assign ex7_sign_c_lod_dly = (f_fpr_ex7_load_sign & f_dcd_ex1_bypsel_c_load1) | (f_fpr_ex8_load_sign & f_dcd_ex1_bypsel_c_load2 | f_fpr_ex7_reload_sign & f_dcd_ex1_bypsel_c_reload1) | (f_fpr_ex8_reload_sign & f_dcd_ex1_bypsel_c_reload2);
   assign ex7_sign_s_lod_dly = (f_fpr_ex7_load_sign & f_dcd_ex1_bypsel_s_load1) | (f_fpr_ex8_load_sign & f_dcd_ex1_bypsel_s_load2 | f_fpr_ex7_reload_sign & f_dcd_ex1_bypsel_s_reload1) | (f_fpr_ex8_reload_sign & f_dcd_ex1_bypsel_s_reload2);

   assign ex1_a_sign_pre1_b = (~((sel_a_res0_s & ex7_sign_res_ear) | (sel_a_res1_s & ex7_sign_a_res_dly)));
   assign ex1_a_sign_pre2_b = (~((sel_a_load0_s & ex6_sign_lod_ear) | (sel_a_reload0_s & ex6_sign_relod_ear) | (sel_a_load1_s & ex7_sign_a_lod_dly)));
   assign ex1_a_sign_pre = (~(ex1_a_sign_pre1_b & ex1_a_sign_pre2_b));

   assign ex1_c_sign_pre1_b = (~((sel_c_res0_s & ex7_sign_res_ear) | (sel_c_res1_s & ex7_sign_c_res_dly)));
   assign ex1_c_sign_pre2_b = (~((sel_c_load0_s & ex6_sign_lod_ear) | (sel_c_reload0_s & ex6_sign_relod_ear) | (sel_c_load1_s & ex7_sign_c_lod_dly)));
   assign ex1_c_sign_pre = (~(ex1_c_sign_pre1_b & ex1_c_sign_pre2_b));

   assign ex1_b_sign_pre1_b = (~((sel_b_res0_s & ex7_sign_res_ear) | (sel_b_res1_s & ex7_sign_b_res_dly)));
   assign ex1_b_sign_pre2_b = (~((sel_b_load0_s & ex6_sign_lod_ear) | (sel_b_reload0_s & ex6_sign_relod_ear) | (sel_b_load1_s & ex7_sign_b_lod_dly)));
   assign ex1_b_sign_pre = (~(ex1_b_sign_pre1_b & ex1_b_sign_pre2_b));

   assign ex1_s_sign_pre1_b = (~((sel_s_res0_s & ex7_sign_res_ear) | (sel_s_res1_s & ex7_sign_s_res_dly)));
   assign ex1_s_sign_pre2_b = (~((sel_s_load0_s & ex6_sign_lod_ear) | (sel_s_reload0_s & ex6_sign_relod_ear) | (sel_s_load1_s & ex7_sign_s_lod_dly)));
   assign ex1_s_sign_pre = (~(ex1_s_sign_pre1_b & ex1_s_sign_pre2_b));

   assign ex1_a_sign_prebyp = ex1_a_sign_pre;		// may need to manually rebuffer
   assign ex1_c_sign_prebyp = ex1_c_sign_pre;		// may need to manually rebuffer
   assign ex1_b_sign_prebyp = ex1_b_sign_pre;		// may need to manually rebuffer
   assign ex1_s_sign_prebyp = ex1_s_sign_pre;		// may need to manually rebuffer

   //------------------------
   // exponent data forwarding
   //------------------------

   assign ex6_load_expo[1:13] = {tidn, tidn, f_fpr_ex6_load_expo[3:13]};
   assign ex6_reload_expo[1:13] = {tidn, tidn, f_fpr_ex6_reload_expo[3:13]};

   assign ex7_expo_res_ear[1:13] = f_rnd_ex7_res_expo[1:13];
   assign ex7_expo_a_res_dly[1:13] = (f_fpr_ex8_frt_expo[1:13] & {13{f_dcd_ex1_bypsel_a_res1}}) | (f_fpr_ex9_frt_expo[1:13] & {13{f_dcd_ex1_bypsel_a_res2}});
   assign ex7_expo_c_res_dly[1:13] = (f_fpr_ex8_frt_expo[1:13] & {13{f_dcd_ex1_bypsel_c_res1}}) | (f_fpr_ex9_frt_expo[1:13] & {13{f_dcd_ex1_bypsel_c_res2}});
   assign ex7_expo_b_res_dly[1:13] = (f_fpr_ex8_frt_expo[1:13] & {13{f_dcd_ex1_bypsel_b_res1}}) | (f_fpr_ex9_frt_expo[1:13] & {13{f_dcd_ex1_bypsel_b_res2}});
   assign ex7_expo_s_res_dly[1:13] = (f_fpr_ex8_frt_expo[1:13] & {13{f_dcd_ex1_bypsel_s_res1}}) | (f_fpr_ex9_frt_expo[1:13] & {13{f_dcd_ex1_bypsel_s_res2}});

   assign ex6_expo_lod_ear[1:13] = ex6_load_expo[1:13];
   assign ex6_expo_relod_ear[1:13] = ex6_reload_expo[1:13];
   assign ex7_expo_a_lod_dly[1:13] =  (({tidn, tidn, f_fpr_ex7_load_expo[3:13]}) & {13{f_dcd_ex1_bypsel_a_load1}}) | (({tidn, tidn, f_fpr_ex8_load_expo[3:13]}) & {13{f_dcd_ex1_bypsel_a_load2}}) | (({tidn, tidn, f_fpr_ex7_reload_expo[3:13]}) & {13{f_dcd_ex1_bypsel_a_reload1}}) | (({tidn, tidn, f_fpr_ex8_reload_expo[3:13]}) & {13{f_dcd_ex1_bypsel_a_reload2}});
   assign ex7_expo_c_lod_dly[1:13] =  (({tidn, tidn, f_fpr_ex7_load_expo[3:13]}) & {13{f_dcd_ex1_bypsel_c_load1}}) | (({tidn, tidn, f_fpr_ex8_load_expo[3:13]}) & {13{f_dcd_ex1_bypsel_c_load2}}) | (({tidn, tidn, f_fpr_ex7_reload_expo[3:13]}) & {13{f_dcd_ex1_bypsel_c_reload1}}) | (({tidn, tidn, f_fpr_ex8_reload_expo[3:13]}) & {13{f_dcd_ex1_bypsel_c_reload2}});
   assign ex7_expo_b_lod_dly[1:13] =  (({tidn, tidn, f_fpr_ex7_load_expo[3:13]}) & {13{f_dcd_ex1_bypsel_b_load1}}) | (({tidn, tidn, f_fpr_ex8_load_expo[3:13]}) & {13{f_dcd_ex1_bypsel_b_load2}}) | (({tidn, tidn, f_fpr_ex7_reload_expo[3:13]}) & {13{f_dcd_ex1_bypsel_b_reload1}}) | (({tidn, tidn, f_fpr_ex8_reload_expo[3:13]}) & {13{f_dcd_ex1_bypsel_b_reload2}});
   assign ex7_expo_s_lod_dly[1:13] =  (({tidn, tidn, f_fpr_ex7_load_expo[3:13]}) & {13{f_dcd_ex1_bypsel_s_load1}}) | (({tidn, tidn, f_fpr_ex8_load_expo[3:13]}) & {13{f_dcd_ex1_bypsel_s_load2}}) | (({tidn, tidn, f_fpr_ex7_reload_expo[3:13]}) & {13{f_dcd_ex1_bypsel_s_reload1}}) | (({tidn, tidn, f_fpr_ex8_reload_expo[3:13]}) & {13{f_dcd_ex1_bypsel_s_reload2}});

   assign ex1_a_expo_pre1_b[1] = (~((sel_a_res0 & ex7_expo_res_ear[1]) | (sel_a_res1 & ex7_expo_a_res_dly[1])));
   assign ex1_a_expo_pre1_b[2] = (~((sel_a_res0 & ex7_expo_res_ear[2]) | (sel_a_res1 & ex7_expo_a_res_dly[2])));
   assign ex1_a_expo_pre1_b[3] = (~((sel_a_res0 & ex7_expo_res_ear[3]) | (sel_a_res1 & ex7_expo_a_res_dly[3])));
   assign ex1_a_expo_pre1_b[4] = (~((sel_a_res0 & ex7_expo_res_ear[4]) | (sel_a_res1 & ex7_expo_a_res_dly[4])));
   assign ex1_a_expo_pre1_b[5] = (~((sel_a_res0 & ex7_expo_res_ear[5]) | (sel_a_res1 & ex7_expo_a_res_dly[5])));
   assign ex1_a_expo_pre1_b[6] = (~((sel_a_res0 & ex7_expo_res_ear[6]) | (sel_a_res1 & ex7_expo_a_res_dly[6])));
   assign ex1_a_expo_pre1_b[7] = (~((sel_a_res0 & ex7_expo_res_ear[7]) | (sel_a_res1 & ex7_expo_a_res_dly[7])));
   assign ex1_a_expo_pre1_b[8] = (~((sel_a_res0 & ex7_expo_res_ear[8]) | (sel_a_res1 & ex7_expo_a_res_dly[8])));
   assign ex1_a_expo_pre1_b[9] = (~((sel_a_res0 & ex7_expo_res_ear[9]) | (sel_a_res1 & ex7_expo_a_res_dly[9])));
   assign ex1_a_expo_pre1_b[10] = (~((sel_a_res0 & ex7_expo_res_ear[10]) | (sel_a_res1 & ex7_expo_a_res_dly[10])));
   assign ex1_a_expo_pre1_b[11] = (~((sel_a_res0 & ex7_expo_res_ear[11]) | (sel_a_res1 & ex7_expo_a_res_dly[11])));
   assign ex1_a_expo_pre1_b[12] = (~((sel_a_res0 & ex7_expo_res_ear[12]) | (sel_a_res1 & ex7_expo_a_res_dly[12])));
   assign ex1_a_expo_pre1_b[13] = (~((sel_a_res0 & ex7_expo_res_ear[13]) | (sel_a_res1 & ex7_expo_a_res_dly[13])));

   assign ex1_c_expo_pre1_b[1] = (~((sel_c_res0 & ex7_expo_res_ear[1]) | (sel_c_res1 & ex7_expo_c_res_dly[1])));
   assign ex1_c_expo_pre1_b[2] = (~((sel_c_res0 & ex7_expo_res_ear[2]) | (sel_c_res1 & ex7_expo_c_res_dly[2])));
   assign ex1_c_expo_pre1_b[3] = (~((sel_c_res0 & ex7_expo_res_ear[3]) | (sel_c_res1 & ex7_expo_c_res_dly[3])));
   assign ex1_c_expo_pre1_b[4] = (~((sel_c_res0 & ex7_expo_res_ear[4]) | (sel_c_res1 & ex7_expo_c_res_dly[4])));
   assign ex1_c_expo_pre1_b[5] = (~((sel_c_res0 & ex7_expo_res_ear[5]) | (sel_c_res1 & ex7_expo_c_res_dly[5])));
   assign ex1_c_expo_pre1_b[6] = (~((sel_c_res0 & ex7_expo_res_ear[6]) | (sel_c_res1 & ex7_expo_c_res_dly[6])));
   assign ex1_c_expo_pre1_b[7] = (~((sel_c_res0 & ex7_expo_res_ear[7]) | (sel_c_res1 & ex7_expo_c_res_dly[7])));
   assign ex1_c_expo_pre1_b[8] = (~((sel_c_res0 & ex7_expo_res_ear[8]) | (sel_c_res1 & ex7_expo_c_res_dly[8])));
   assign ex1_c_expo_pre1_b[9] = (~((sel_c_res0 & ex7_expo_res_ear[9]) | (sel_c_res1 & ex7_expo_c_res_dly[9])));
   assign ex1_c_expo_pre1_b[10] = (~((sel_c_res0 & ex7_expo_res_ear[10]) | (sel_c_res1 & ex7_expo_c_res_dly[10])));
   assign ex1_c_expo_pre1_b[11] = (~((sel_c_res0 & ex7_expo_res_ear[11]) | (sel_c_res1 & ex7_expo_c_res_dly[11])));
   assign ex1_c_expo_pre1_b[12] = (~((sel_c_res0 & ex7_expo_res_ear[12]) | (sel_c_res1 & ex7_expo_c_res_dly[12])));
   assign ex1_c_expo_pre1_b[13] = (~((sel_c_res0 & ex7_expo_res_ear[13]) | (sel_c_res1 & ex7_expo_c_res_dly[13])));

   assign ex1_b_expo_pre1_b[1] = (~((sel_b_res0 & ex7_expo_res_ear[1]) | (sel_b_res1 & ex7_expo_b_res_dly[1])));
   assign ex1_b_expo_pre1_b[2] = (~((sel_b_res0 & ex7_expo_res_ear[2]) | (sel_b_res1 & ex7_expo_b_res_dly[2])));
   assign ex1_b_expo_pre1_b[3] = (~((sel_b_res0 & ex7_expo_res_ear[3]) | (sel_b_res1 & ex7_expo_b_res_dly[3])));
   assign ex1_b_expo_pre1_b[4] = (~((sel_b_res0 & ex7_expo_res_ear[4]) | (sel_b_res1 & ex7_expo_b_res_dly[4])));
   assign ex1_b_expo_pre1_b[5] = (~((sel_b_res0 & ex7_expo_res_ear[5]) | (sel_b_res1 & ex7_expo_b_res_dly[5])));
   assign ex1_b_expo_pre1_b[6] = (~((sel_b_res0 & ex7_expo_res_ear[6]) | (sel_b_res1 & ex7_expo_b_res_dly[6])));
   assign ex1_b_expo_pre1_b[7] = (~((sel_b_res0 & ex7_expo_res_ear[7]) | (sel_b_res1 & ex7_expo_b_res_dly[7])));
   assign ex1_b_expo_pre1_b[8] = (~((sel_b_res0 & ex7_expo_res_ear[8]) | (sel_b_res1 & ex7_expo_b_res_dly[8])));
   assign ex1_b_expo_pre1_b[9] = (~((sel_b_res0 & ex7_expo_res_ear[9]) | (sel_b_res1 & ex7_expo_b_res_dly[9])));
   assign ex1_b_expo_pre1_b[10] = (~((sel_b_res0 & ex7_expo_res_ear[10]) | (sel_b_res1 & ex7_expo_b_res_dly[10])));
   assign ex1_b_expo_pre1_b[11] = (~((sel_b_res0 & ex7_expo_res_ear[11]) | (sel_b_res1 & ex7_expo_b_res_dly[11])));
   assign ex1_b_expo_pre1_b[12] = (~((sel_b_res0 & ex7_expo_res_ear[12]) | (sel_b_res1 & ex7_expo_b_res_dly[12])));
   assign ex1_b_expo_pre1_b[13] = (~((sel_b_res0 & ex7_expo_res_ear[13]) | (sel_b_res1 & ex7_expo_b_res_dly[13])));

   assign ex1_s_expo_pre1_b[1] = (~((sel_s_res0 & ex7_expo_res_ear[1]) | (sel_s_res1 & ex7_expo_s_res_dly[1])));
   assign ex1_s_expo_pre1_b[2] = (~((sel_s_res0 & ex7_expo_res_ear[2]) | (sel_s_res1 & ex7_expo_s_res_dly[2])));
   assign ex1_s_expo_pre1_b[3] = (~((sel_s_res0 & ex7_expo_res_ear[3]) | (sel_s_res1 & ex7_expo_s_res_dly[3])));
   assign ex1_s_expo_pre1_b[4] = (~((sel_s_res0 & ex7_expo_res_ear[4]) | (sel_s_res1 & ex7_expo_s_res_dly[4])));
   assign ex1_s_expo_pre1_b[5] = (~((sel_s_res0 & ex7_expo_res_ear[5]) | (sel_s_res1 & ex7_expo_s_res_dly[5])));
   assign ex1_s_expo_pre1_b[6] = (~((sel_s_res0 & ex7_expo_res_ear[6]) | (sel_s_res1 & ex7_expo_s_res_dly[6])));
   assign ex1_s_expo_pre1_b[7] = (~((sel_s_res0 & ex7_expo_res_ear[7]) | (sel_s_res1 & ex7_expo_s_res_dly[7])));
   assign ex1_s_expo_pre1_b[8] = (~((sel_s_res0 & ex7_expo_res_ear[8]) | (sel_s_res1 & ex7_expo_s_res_dly[8])));
   assign ex1_s_expo_pre1_b[9] = (~((sel_s_res0 & ex7_expo_res_ear[9]) | (sel_s_res1 & ex7_expo_s_res_dly[9])));
   assign ex1_s_expo_pre1_b[10] = (~((sel_s_res0 & ex7_expo_res_ear[10]) | (sel_s_res1 & ex7_expo_s_res_dly[10])));
   assign ex1_s_expo_pre1_b[11] = (~((sel_s_res0 & ex7_expo_res_ear[11]) | (sel_s_res1 & ex7_expo_s_res_dly[11])));
   assign ex1_s_expo_pre1_b[12] = (~((sel_s_res0 & ex7_expo_res_ear[12]) | (sel_s_res1 & ex7_expo_s_res_dly[12])));
   assign ex1_s_expo_pre1_b[13] = (~((sel_s_res0 & ex7_expo_res_ear[13]) | (sel_s_res1 & ex7_expo_s_res_dly[13])));

   assign ex1_a_expo_pre2_b[1] = (~((sel_a_load0 & ex6_expo_lod_ear[1])   | (sel_a_reload0 & ex6_expo_relod_ear[1])  | (sel_a_load1 & ex7_expo_a_lod_dly[1])));
   assign ex1_a_expo_pre2_b[2] = (~((sel_a_load0 & ex6_expo_lod_ear[2])   | (sel_a_reload0 & ex6_expo_relod_ear[2])  | (sel_a_load1 & ex7_expo_a_lod_dly[2])));
   assign ex1_a_expo_pre2_b[3] = (~((sel_a_load0 & ex6_expo_lod_ear[3])   | (sel_a_reload0 & ex6_expo_relod_ear[3])  | (sel_a_load1 & ex7_expo_a_lod_dly[3])));
   assign ex1_a_expo_pre2_b[4] = (~((sel_a_load0 & ex6_expo_lod_ear[4])   | (sel_a_reload0 & ex6_expo_relod_ear[4])  | (sel_a_load1 & ex7_expo_a_lod_dly[4])));
   assign ex1_a_expo_pre2_b[5] = (~((sel_a_load0 & ex6_expo_lod_ear[5])   | (sel_a_reload0 & ex6_expo_relod_ear[5])  | (sel_a_load1 & ex7_expo_a_lod_dly[5])));
   assign ex1_a_expo_pre2_b[6] = (~((sel_a_load0 & ex6_expo_lod_ear[6])   | (sel_a_reload0 & ex6_expo_relod_ear[6])  | (sel_a_load1 & ex7_expo_a_lod_dly[6])));
   assign ex1_a_expo_pre2_b[7] = (~((sel_a_load0 & ex6_expo_lod_ear[7])   | (sel_a_reload0 & ex6_expo_relod_ear[7])  | (sel_a_load1 & ex7_expo_a_lod_dly[7])));
   assign ex1_a_expo_pre2_b[8] = (~((sel_a_load0 & ex6_expo_lod_ear[8])   | (sel_a_reload0 & ex6_expo_relod_ear[8])  | (sel_a_load1 & ex7_expo_a_lod_dly[8])));
   assign ex1_a_expo_pre2_b[9] = (~((sel_a_load0 & ex6_expo_lod_ear[9])   | (sel_a_reload0 & ex6_expo_relod_ear[9])  | (sel_a_load1 & ex7_expo_a_lod_dly[9])));
   assign ex1_a_expo_pre2_b[10] = (~((sel_a_load0 & ex6_expo_lod_ear[10]) | (sel_a_reload0 & ex6_expo_relod_ear[10]) | (sel_a_load1 & ex7_expo_a_lod_dly[10])));
   assign ex1_a_expo_pre2_b[11] = (~((sel_a_load0 & ex6_expo_lod_ear[11]) | (sel_a_reload0 & ex6_expo_relod_ear[11]) | (sel_a_load1 & ex7_expo_a_lod_dly[11])));
   assign ex1_a_expo_pre2_b[12] = (~((sel_a_load0 & ex6_expo_lod_ear[12]) | (sel_a_reload0 & ex6_expo_relod_ear[12]) | (sel_a_load1 & ex7_expo_a_lod_dly[12])));
   assign ex1_a_expo_pre2_b[13] = (~((sel_a_load0 & ex6_expo_lod_ear[13]) | (sel_a_reload0 & ex6_expo_relod_ear[13]) | (sel_a_load1 & ex7_expo_a_lod_dly[13])));

   assign ex1_c_expo_pre2_b[1] = (~((sel_c_load0 & ex6_expo_lod_ear[1])   | (sel_c_reload0 & ex6_expo_relod_ear[1])  | (sel_c_load1 & ex7_expo_c_lod_dly[1])));
   assign ex1_c_expo_pre2_b[2] = (~((sel_c_load0 & ex6_expo_lod_ear[2])   | (sel_c_reload0 & ex6_expo_relod_ear[2])  | (sel_c_load1 & ex7_expo_c_lod_dly[2])));
   assign ex1_c_expo_pre2_b[3] = (~((sel_c_load0 & ex6_expo_lod_ear[3])   | (sel_c_reload0 & ex6_expo_relod_ear[3])  | (sel_c_load1 & ex7_expo_c_lod_dly[3])));
   assign ex1_c_expo_pre2_b[4] = (~((sel_c_load0 & ex6_expo_lod_ear[4])   | (sel_c_reload0 & ex6_expo_relod_ear[4])  | (sel_c_load1 & ex7_expo_c_lod_dly[4])));
   assign ex1_c_expo_pre2_b[5] = (~((sel_c_load0 & ex6_expo_lod_ear[5])   | (sel_c_reload0 & ex6_expo_relod_ear[5])  | (sel_c_load1 & ex7_expo_c_lod_dly[5])));
   assign ex1_c_expo_pre2_b[6] = (~((sel_c_load0 & ex6_expo_lod_ear[6])   | (sel_c_reload0 & ex6_expo_relod_ear[6])  | (sel_c_load1 & ex7_expo_c_lod_dly[6])));
   assign ex1_c_expo_pre2_b[7] = (~((sel_c_load0 & ex6_expo_lod_ear[7])   | (sel_c_reload0 & ex6_expo_relod_ear[7])  | (sel_c_load1 & ex7_expo_c_lod_dly[7])));
   assign ex1_c_expo_pre2_b[8] = (~((sel_c_load0 & ex6_expo_lod_ear[8])   | (sel_c_reload0 & ex6_expo_relod_ear[8])  | (sel_c_load1 & ex7_expo_c_lod_dly[8])));
   assign ex1_c_expo_pre2_b[9] = (~((sel_c_load0 & ex6_expo_lod_ear[9])   | (sel_c_reload0 & ex6_expo_relod_ear[9])  | (sel_c_load1 & ex7_expo_c_lod_dly[9])));
   assign ex1_c_expo_pre2_b[10] = (~((sel_c_load0 & ex6_expo_lod_ear[10]) | (sel_c_reload0 & ex6_expo_relod_ear[10]) | (sel_c_load1 & ex7_expo_c_lod_dly[10])));
   assign ex1_c_expo_pre2_b[11] = (~((sel_c_load0 & ex6_expo_lod_ear[11]) | (sel_c_reload0 & ex6_expo_relod_ear[11]) | (sel_c_load1 & ex7_expo_c_lod_dly[11])));
   assign ex1_c_expo_pre2_b[12] = (~((sel_c_load0 & ex6_expo_lod_ear[12]) | (sel_c_reload0 & ex6_expo_relod_ear[12]) | (sel_c_load1 & ex7_expo_c_lod_dly[12])));
   assign ex1_c_expo_pre2_b[13] = (~((sel_c_load0 & ex6_expo_lod_ear[13]) | (sel_c_reload0 & ex6_expo_relod_ear[13]) | (sel_c_load1 & ex7_expo_c_lod_dly[13])));

   assign ex1_b_expo_pre2_b[1] = (~((sel_b_load0 & ex6_expo_lod_ear[1])   | (sel_b_reload0 & ex6_expo_relod_ear[1])  | (sel_b_load1 & ex7_expo_b_lod_dly[1])));
   assign ex1_b_expo_pre2_b[2] = (~((sel_b_load0 & ex6_expo_lod_ear[2])   | (sel_b_reload0 & ex6_expo_relod_ear[2])  | (sel_b_load1 & ex7_expo_b_lod_dly[2])));
   assign ex1_b_expo_pre2_b[3] = (~((sel_b_load0 & ex6_expo_lod_ear[3])   | (sel_b_reload0 & ex6_expo_relod_ear[3])  | (sel_b_load1 & ex7_expo_b_lod_dly[3])));
   assign ex1_b_expo_pre2_b[4] = (~((sel_b_load0 & ex6_expo_lod_ear[4])   | (sel_b_reload0 & ex6_expo_relod_ear[4])  | (sel_b_load1 & ex7_expo_b_lod_dly[4])));
   assign ex1_b_expo_pre2_b[5] = (~((sel_b_load0 & ex6_expo_lod_ear[5])   | (sel_b_reload0 & ex6_expo_relod_ear[5])  | (sel_b_load1 & ex7_expo_b_lod_dly[5])));
   assign ex1_b_expo_pre2_b[6] = (~((sel_b_load0 & ex6_expo_lod_ear[6])   | (sel_b_reload0 & ex6_expo_relod_ear[6])  | (sel_b_load1 & ex7_expo_b_lod_dly[6])));
   assign ex1_b_expo_pre2_b[7] = (~((sel_b_load0 & ex6_expo_lod_ear[7])   | (sel_b_reload0 & ex6_expo_relod_ear[7])  | (sel_b_load1 & ex7_expo_b_lod_dly[7])));
   assign ex1_b_expo_pre2_b[8] = (~((sel_b_load0 & ex6_expo_lod_ear[8])   | (sel_b_reload0 & ex6_expo_relod_ear[8])  | (sel_b_load1 & ex7_expo_b_lod_dly[8])));
   assign ex1_b_expo_pre2_b[9] = (~((sel_b_load0 & ex6_expo_lod_ear[9])   | (sel_b_reload0 & ex6_expo_relod_ear[9])  | (sel_b_load1 & ex7_expo_b_lod_dly[9])));
   assign ex1_b_expo_pre2_b[10] = (~((sel_b_load0 & ex6_expo_lod_ear[10]) | (sel_b_reload0 & ex6_expo_relod_ear[10]) | (sel_b_load1 & ex7_expo_b_lod_dly[10])));
   assign ex1_b_expo_pre2_b[11] = (~((sel_b_load0 & ex6_expo_lod_ear[11]) | (sel_b_reload0 & ex6_expo_relod_ear[11]) | (sel_b_load1 & ex7_expo_b_lod_dly[11])));
   assign ex1_b_expo_pre2_b[12] = (~((sel_b_load0 & ex6_expo_lod_ear[12]) | (sel_b_reload0 & ex6_expo_relod_ear[12]) | (sel_b_load1 & ex7_expo_b_lod_dly[12])));
   assign ex1_b_expo_pre2_b[13] = (~((sel_b_load0 & ex6_expo_lod_ear[13]) | (sel_b_reload0 & ex6_expo_relod_ear[13]) | (sel_b_load1 & ex7_expo_b_lod_dly[13])));

   assign ex1_s_expo_pre2_b[1] = (~((sel_s_load0 & ex6_expo_lod_ear[1])    | (sel_s_reload0 & ex6_expo_relod_ear[1]) | (sel_s_load1 & ex7_expo_s_lod_dly[1]) )) ;
   assign ex1_s_expo_pre2_b[2] = (~((sel_s_load0 & ex6_expo_lod_ear[2])    | (sel_s_reload0 & ex6_expo_relod_ear[2]) | (sel_s_load1 & ex7_expo_s_lod_dly[2]) )) ;
   assign ex1_s_expo_pre2_b[3] = (~((sel_s_load0 & ex6_expo_lod_ear[3])    | (sel_s_reload0 & ex6_expo_relod_ear[3]) | (sel_s_load1 & ex7_expo_s_lod_dly[3]) )) ;
   assign ex1_s_expo_pre2_b[4] = (~((sel_s_load0 & ex6_expo_lod_ear[4])    | (sel_s_reload0 & ex6_expo_relod_ear[4]) | (sel_s_load1 & ex7_expo_s_lod_dly[4]) )) ;
   assign ex1_s_expo_pre2_b[5] = (~((sel_s_load0 & ex6_expo_lod_ear[5])    | (sel_s_reload0 & ex6_expo_relod_ear[5]) | (sel_s_load1 & ex7_expo_s_lod_dly[5]) )) ;
   assign ex1_s_expo_pre2_b[6] = (~((sel_s_load0 & ex6_expo_lod_ear[6])    | (sel_s_reload0 & ex6_expo_relod_ear[6]) | (sel_s_load1 & ex7_expo_s_lod_dly[6]) )) ;
   assign ex1_s_expo_pre2_b[7] = (~((sel_s_load0 & ex6_expo_lod_ear[7])    | (sel_s_reload0 & ex6_expo_relod_ear[7]) | (sel_s_load1 & ex7_expo_s_lod_dly[7]) )) ;
   assign ex1_s_expo_pre2_b[8] = (~((sel_s_load0 & ex6_expo_lod_ear[8])    | (sel_s_reload0 & ex6_expo_relod_ear[8]) | (sel_s_load1 & ex7_expo_s_lod_dly[8]) )) ;
   assign ex1_s_expo_pre2_b[9] = (~((sel_s_load0 & ex6_expo_lod_ear[9])    | (sel_s_reload0 & ex6_expo_relod_ear[9]) | (sel_s_load1 & ex7_expo_s_lod_dly[9]) )) ;
   assign ex1_s_expo_pre2_b[10] = (~((sel_s_load0 & ex6_expo_lod_ear[10])  | (sel_s_reload0 & ex6_expo_relod_ear[10]) | (sel_s_load1 & ex7_expo_s_lod_dly[10])));
   assign ex1_s_expo_pre2_b[11] = (~((sel_s_load0 & ex6_expo_lod_ear[11])  | (sel_s_reload0 & ex6_expo_relod_ear[11]) | (sel_s_load1 & ex7_expo_s_lod_dly[11])));
   assign ex1_s_expo_pre2_b[12] = (~((sel_s_load0 & ex6_expo_lod_ear[12])  | (sel_s_reload0 & ex6_expo_relod_ear[12]) | (sel_s_load1 & ex7_expo_s_lod_dly[12])));
   assign ex1_s_expo_pre2_b[13] = (~((sel_s_load0 & ex6_expo_lod_ear[13])  | (sel_s_reload0 & ex6_expo_relod_ear[13]) | (sel_s_load1 & ex7_expo_s_lod_dly[13])));

   assign ex1_a_expo_pre3_b[1] = (~(tidn));
   assign ex1_a_expo_pre3_b[2] = (~(tidn));
   assign ex1_a_expo_pre3_b[3] = (~(sel_a_imm & ex1_a_k_expo[3]));
   assign ex1_a_expo_pre3_b[4] = (~(sel_a_imm & ex1_a_k_expo[4]));
   assign ex1_a_expo_pre3_b[5] = (~(sel_a_imm & ex1_a_k_expo[5]));
   assign ex1_a_expo_pre3_b[6] = (~(sel_a_imm & ex1_a_k_expo[6]));
   assign ex1_a_expo_pre3_b[7] = (~(sel_a_imm & ex1_a_k_expo[7]));
   assign ex1_a_expo_pre3_b[8] = (~(sel_a_imm & ex1_a_k_expo[8]));
   assign ex1_a_expo_pre3_b[9] = (~(sel_a_imm & ex1_a_k_expo[9]));
   assign ex1_a_expo_pre3_b[10] = (~(sel_a_imm & ex1_a_k_expo[10]));
   assign ex1_a_expo_pre3_b[11] = (~(sel_a_imm & ex1_a_k_expo[11]));
   assign ex1_a_expo_pre3_b[12] = (~(sel_a_imm & ex1_a_k_expo[12]));
   assign ex1_a_expo_pre3_b[13] = (~(sel_a_imm & ex1_a_k_expo[13]));

   assign ex1_c_expo_pre3_b[1] = (~(tidn));
   assign ex1_c_expo_pre3_b[2] = (~(tidn));
   assign ex1_c_expo_pre3_b[3] = (~(tidn));
   assign ex1_c_expo_pre3_b[4] = (~(sel_c_imm));
   assign ex1_c_expo_pre3_b[5] = (~(sel_c_imm));
   assign ex1_c_expo_pre3_b[6] = (~(sel_c_imm));
   assign ex1_c_expo_pre3_b[7] = (~(sel_c_imm));
   assign ex1_c_expo_pre3_b[8] = (~(sel_c_imm));
   assign ex1_c_expo_pre3_b[9] = (~(sel_c_imm));
   assign ex1_c_expo_pre3_b[10] = (~(sel_c_imm));
   assign ex1_c_expo_pre3_b[11] = (~(sel_c_imm));
   assign ex1_c_expo_pre3_b[12] = (~(sel_c_imm));
   assign ex1_c_expo_pre3_b[13] = (~(sel_c_imm & ex1_c_k_expo[13]));

   assign ex1_b_expo_pre3_b[1] = (~(tidn));
   assign ex1_b_expo_pre3_b[2] = (~(tidn));
   assign ex1_b_expo_pre3_b[3] = (~(tidn));
   assign ex1_b_expo_pre3_b[4] = (~(sel_b_imm & ex1_b_k_expo[4]));
   assign ex1_b_expo_pre3_b[5] = (~(sel_b_imm & ex1_b_k_expo[5]));
   assign ex1_b_expo_pre3_b[6] = (~(sel_b_imm & ex1_b_k_expo[6]));
   assign ex1_b_expo_pre3_b[7] = (~(sel_b_imm & ex1_b_k_expo[7]));
   assign ex1_b_expo_pre3_b[8] = (~(sel_b_imm & ex1_b_k_expo[8]));
   assign ex1_b_expo_pre3_b[9] = (~(sel_b_imm & ex1_b_k_expo[9]));
   assign ex1_b_expo_pre3_b[10] = (~(sel_b_imm & ex1_b_k_expo[10]));
   assign ex1_b_expo_pre3_b[11] = (~(sel_b_imm & ex1_b_k_expo[11]));
   assign ex1_b_expo_pre3_b[12] = (~(sel_b_imm & ex1_b_k_expo[12]));
   assign ex1_b_expo_pre3_b[13] = (~(sel_b_imm & ex1_b_k_expo[13]));

   assign ex1_s_expo_pre3_b[1:13] = {13{tiup}};

   assign ex1_a_expo_pre[1] = (~(ex1_a_expo_pre1_b[1] & ex1_a_expo_pre2_b[1]));
   assign ex1_a_expo_pre[2] = (~(ex1_a_expo_pre1_b[2] & ex1_a_expo_pre2_b[2]));
   assign ex1_a_expo_pre[3] = (~(ex1_a_expo_pre1_b[3] & ex1_a_expo_pre2_b[3] & ex1_a_expo_pre3_b[3]));
   assign ex1_a_expo_pre[4] = (~(ex1_a_expo_pre1_b[4] & ex1_a_expo_pre2_b[4] & ex1_a_expo_pre3_b[4]));
   assign ex1_a_expo_pre[5] = (~(ex1_a_expo_pre1_b[5] & ex1_a_expo_pre2_b[5] & ex1_a_expo_pre3_b[5]));
   assign ex1_a_expo_pre[6] = (~(ex1_a_expo_pre1_b[6] & ex1_a_expo_pre2_b[6] & ex1_a_expo_pre3_b[6]));
   assign ex1_a_expo_pre[7] = (~(ex1_a_expo_pre1_b[7] & ex1_a_expo_pre2_b[7] & ex1_a_expo_pre3_b[7]));
   assign ex1_a_expo_pre[8] = (~(ex1_a_expo_pre1_b[8] & ex1_a_expo_pre2_b[8] & ex1_a_expo_pre3_b[8]));
   assign ex1_a_expo_pre[9] = (~(ex1_a_expo_pre1_b[9] & ex1_a_expo_pre2_b[9] & ex1_a_expo_pre3_b[9]));
   assign ex1_a_expo_pre[10] = (~(ex1_a_expo_pre1_b[10] & ex1_a_expo_pre2_b[10] & ex1_a_expo_pre3_b[10]));
   assign ex1_a_expo_pre[11] = (~(ex1_a_expo_pre1_b[11] & ex1_a_expo_pre2_b[11] & ex1_a_expo_pre3_b[11]));
   assign ex1_a_expo_pre[12] = (~(ex1_a_expo_pre1_b[12] & ex1_a_expo_pre2_b[12] & ex1_a_expo_pre3_b[12]));
   assign ex1_a_expo_pre[13] = (~(ex1_a_expo_pre1_b[13] & ex1_a_expo_pre2_b[13] & ex1_a_expo_pre3_b[13]));

   assign ex1_c_expo_pre[1] = (~(ex1_c_expo_pre1_b[1] & ex1_c_expo_pre2_b[1]));
   assign ex1_c_expo_pre[2] = (~(ex1_c_expo_pre1_b[2] & ex1_c_expo_pre2_b[2]));
   assign ex1_c_expo_pre[3] = (~(ex1_c_expo_pre1_b[3] & ex1_c_expo_pre2_b[3]));
   assign ex1_c_expo_pre[4] = (~(ex1_c_expo_pre1_b[4] & ex1_c_expo_pre2_b[4] & ex1_c_expo_pre3_b[4]));
   assign ex1_c_expo_pre[5] = (~(ex1_c_expo_pre1_b[5] & ex1_c_expo_pre2_b[5] & ex1_c_expo_pre3_b[5]));
   assign ex1_c_expo_pre[6] = (~(ex1_c_expo_pre1_b[6] & ex1_c_expo_pre2_b[6] & ex1_c_expo_pre3_b[6]));
   assign ex1_c_expo_pre[7] = (~(ex1_c_expo_pre1_b[7] & ex1_c_expo_pre2_b[7] & ex1_c_expo_pre3_b[7]));
   assign ex1_c_expo_pre[8] = (~(ex1_c_expo_pre1_b[8] & ex1_c_expo_pre2_b[8] & ex1_c_expo_pre3_b[8]));
   assign ex1_c_expo_pre[9] = (~(ex1_c_expo_pre1_b[9] & ex1_c_expo_pre2_b[9] & ex1_c_expo_pre3_b[9]));
   assign ex1_c_expo_pre[10] = (~(ex1_c_expo_pre1_b[10] & ex1_c_expo_pre2_b[10] & ex1_c_expo_pre3_b[10]));
   assign ex1_c_expo_pre[11] = (~(ex1_c_expo_pre1_b[11] & ex1_c_expo_pre2_b[11] & ex1_c_expo_pre3_b[11]));
   assign ex1_c_expo_pre[12] = (~(ex1_c_expo_pre1_b[12] & ex1_c_expo_pre2_b[12] & ex1_c_expo_pre3_b[12]));
   assign ex1_c_expo_pre[13] = (~(ex1_c_expo_pre1_b[13] & ex1_c_expo_pre2_b[13] & ex1_c_expo_pre3_b[13]));

   assign ex1_b_expo_pre[1] = (~(ex1_b_expo_pre1_b[1] & ex1_b_expo_pre2_b[1]));
   assign ex1_b_expo_pre[2] = (~(ex1_b_expo_pre1_b[2] & ex1_b_expo_pre2_b[2]));
   assign ex1_b_expo_pre[3] = (~(ex1_b_expo_pre1_b[3] & ex1_b_expo_pre2_b[3]));
   assign ex1_b_expo_pre[4] = (~(ex1_b_expo_pre1_b[4] & ex1_b_expo_pre2_b[4] & ex1_b_expo_pre3_b[4]));
   assign ex1_b_expo_pre[5] = (~(ex1_b_expo_pre1_b[5] & ex1_b_expo_pre2_b[5] & ex1_b_expo_pre3_b[5]));
   assign ex1_b_expo_pre[6] = (~(ex1_b_expo_pre1_b[6] & ex1_b_expo_pre2_b[6] & ex1_b_expo_pre3_b[6]));
   assign ex1_b_expo_pre[7] = (~(ex1_b_expo_pre1_b[7] & ex1_b_expo_pre2_b[7] & ex1_b_expo_pre3_b[7]));
   assign ex1_b_expo_pre[8] = (~(ex1_b_expo_pre1_b[8] & ex1_b_expo_pre2_b[8] & ex1_b_expo_pre3_b[8]));
   assign ex1_b_expo_pre[9] = (~(ex1_b_expo_pre1_b[9] & ex1_b_expo_pre2_b[9] & ex1_b_expo_pre3_b[9]));
   assign ex1_b_expo_pre[10] = (~(ex1_b_expo_pre1_b[10] & ex1_b_expo_pre2_b[10] & ex1_b_expo_pre3_b[10]));
   assign ex1_b_expo_pre[11] = (~(ex1_b_expo_pre1_b[11] & ex1_b_expo_pre2_b[11] & ex1_b_expo_pre3_b[11]));
   assign ex1_b_expo_pre[12] = (~(ex1_b_expo_pre1_b[12] & ex1_b_expo_pre2_b[12] & ex1_b_expo_pre3_b[12]));
   assign ex1_b_expo_pre[13] = (~(ex1_b_expo_pre1_b[13] & ex1_b_expo_pre2_b[13] & ex1_b_expo_pre3_b[13]));

   assign ex1_s_expo_pre[1] = (~(ex1_s_expo_pre1_b[1] & ex1_s_expo_pre2_b[1]));
   assign ex1_s_expo_pre[2] = (~(ex1_s_expo_pre1_b[2] & ex1_s_expo_pre2_b[2]));
   assign ex1_s_expo_pre[3] = (~(ex1_s_expo_pre1_b[3] & ex1_s_expo_pre2_b[3]));
   assign ex1_s_expo_pre[4] = (~(ex1_s_expo_pre1_b[4] & ex1_s_expo_pre2_b[4] & ex1_s_expo_pre3_b[4]));
   assign ex1_s_expo_pre[5] = (~(ex1_s_expo_pre1_b[5] & ex1_s_expo_pre2_b[5] & ex1_s_expo_pre3_b[5]));
   assign ex1_s_expo_pre[6] = (~(ex1_s_expo_pre1_b[6] & ex1_s_expo_pre2_b[6] & ex1_s_expo_pre3_b[6]));
   assign ex1_s_expo_pre[7] = (~(ex1_s_expo_pre1_b[7] & ex1_s_expo_pre2_b[7] & ex1_s_expo_pre3_b[7]));
   assign ex1_s_expo_pre[8] = (~(ex1_s_expo_pre1_b[8] & ex1_s_expo_pre2_b[8] & ex1_s_expo_pre3_b[8]));
   assign ex1_s_expo_pre[9] = (~(ex1_s_expo_pre1_b[9] & ex1_s_expo_pre2_b[9] & ex1_s_expo_pre3_b[9]));
   assign ex1_s_expo_pre[10] = (~(ex1_s_expo_pre1_b[10] & ex1_s_expo_pre2_b[10] & ex1_s_expo_pre3_b[10]));
   assign ex1_s_expo_pre[11] = (~(ex1_s_expo_pre1_b[11] & ex1_s_expo_pre2_b[11] & ex1_s_expo_pre3_b[11]));
   assign ex1_s_expo_pre[12] = (~(ex1_s_expo_pre1_b[12] & ex1_s_expo_pre2_b[12] & ex1_s_expo_pre3_b[12]));
   assign ex1_s_expo_pre[13] = (~(ex1_s_expo_pre1_b[13] & ex1_s_expo_pre2_b[13] & ex1_s_expo_pre3_b[13]));

   assign ex1_a_expo_prebyp[1:13] = ex1_a_expo_pre[1:13];		// may need to manually repower
   assign ex1_c_expo_prebyp[1:13] = ex1_c_expo_pre[1:13];		// may need to manually repower
   assign ex1_b_expo_prebyp[1:13] = ex1_b_expo_pre[1:13];		// may need to manually repower
   assign ex1_s_expo_prebyp[1:13] = ex1_s_expo_pre[1:13];		// may need to manually repower

   //------------------------
   // fraction
   //------------------------

   assign ex7_frac_res_ear[0:52] = f_rnd_ex7_res_frac[0:52];
   assign ex7_frac_a_res_dly[0:52] = (f_fpr_ex8_frt_frac[0:52] & {53{f_dcd_ex1_bypsel_a_res1}}) | (f_fpr_ex9_frt_frac[0:52] & {53{f_dcd_ex1_bypsel_a_res2}});
   assign ex7_frac_c_res_dly[0:52] = (f_fpr_ex8_frt_frac[0:52] & {53{f_dcd_ex1_bypsel_c_res1}}) | (f_fpr_ex9_frt_frac[0:52] & {53{f_dcd_ex1_bypsel_c_res2}});
   assign ex7_frac_b_res_dly[0:52] = (f_fpr_ex8_frt_frac[0:52] & {53{f_dcd_ex1_bypsel_b_res1}}) | (f_fpr_ex9_frt_frac[0:52] & {53{f_dcd_ex1_bypsel_b_res2}});
   assign ex7_frac_s_res_dly[0:52] = (f_fpr_ex8_frt_frac[0:52] & {53{f_dcd_ex1_bypsel_s_res1}}) | (f_fpr_ex9_frt_frac[0:52] & {53{f_dcd_ex1_bypsel_s_res2}});
   assign ex6_frac_lod_ear[0:52] = f_fpr_ex6_load_frac[0:52];
   assign ex6_frac_relod_ear[0:52] = f_fpr_ex6_reload_frac[0:52];
   assign ex7_frac_a_lod_dly[0:52] = (f_fpr_ex7_load_frac[0:52] & {53{f_dcd_ex1_bypsel_a_load1}}) | (f_fpr_ex8_load_frac[0:52] & {53{f_dcd_ex1_bypsel_a_load2}}) | (f_fpr_ex7_reload_frac[0:52] & {53{f_dcd_ex1_bypsel_a_reload1}}) | (f_fpr_ex8_reload_frac[0:52] & {53{f_dcd_ex1_bypsel_a_reload2}});
   assign ex7_frac_c_lod_dly[0:52] = (f_fpr_ex7_load_frac[0:52] & {53{f_dcd_ex1_bypsel_c_load1}}) | (f_fpr_ex8_load_frac[0:52] & {53{f_dcd_ex1_bypsel_c_load2}}) | (f_fpr_ex7_reload_frac[0:52] & {53{f_dcd_ex1_bypsel_c_reload1}}) | (f_fpr_ex8_reload_frac[0:52] & {53{f_dcd_ex1_bypsel_c_reload2}});
   assign ex7_frac_b_lod_dly[0:52] = (f_fpr_ex7_load_frac[0:52] & {53{f_dcd_ex1_bypsel_b_load1}}) | (f_fpr_ex8_load_frac[0:52] & {53{f_dcd_ex1_bypsel_b_load2}}) | (f_fpr_ex7_reload_frac[0:52] & {53{f_dcd_ex1_bypsel_b_reload1}}) | (f_fpr_ex8_reload_frac[0:52] & {53{f_dcd_ex1_bypsel_b_reload2}});
   assign ex7_frac_s_lod_dly[0:52] = (f_fpr_ex7_load_frac[0:52] & {53{f_dcd_ex1_bypsel_s_load1}}) | (f_fpr_ex8_load_frac[0:52] & {53{f_dcd_ex1_bypsel_s_load2}}) | (f_fpr_ex7_reload_frac[0:52] & {53{f_dcd_ex1_bypsel_s_reload1}}) | (f_fpr_ex8_reload_frac[0:52] & {53{f_dcd_ex1_bypsel_s_reload2}});

   assign ex1_c_frac_pre3_b[0] = (~(sel_c_imm & ex1_c_k_frac[0]));
   assign ex1_c_frac_pre3_b[1] = (~(sel_c_imm & ex1_c_k_frac[1]));
   assign ex1_c_frac_pre3_b[2] = (~(sel_c_imm & ex1_c_k_frac[2]));
   assign ex1_c_frac_pre3_b[3] = (~(sel_c_imm & ex1_c_k_frac[3]));
   assign ex1_c_frac_pre3_b[4] = (~(sel_c_imm & ex1_c_k_frac[4]));
   assign ex1_c_frac_pre3_b[5] = (~(sel_c_imm & ex1_c_k_frac[5]));
   assign ex1_c_frac_pre3_b[6] = (~(sel_c_imm & ex1_c_k_frac[6]));
   assign ex1_c_frac_pre3_b[7] = (~(sel_c_imm & ex1_c_k_frac[7]));
   assign ex1_c_frac_pre3_b[8] = (~(sel_c_imm & ex1_c_k_frac[8]));
   assign ex1_c_frac_pre3_b[9] = (~(sel_c_imm & ex1_c_k_frac[9]));
   assign ex1_c_frac_pre3_b[10] = (~(sel_c_imm & ex1_c_k_frac[10]));
   assign ex1_c_frac_pre3_b[11] = (~(sel_c_imm & ex1_c_k_frac[11]));
   assign ex1_c_frac_pre3_b[12] = (~(sel_c_imm & ex1_c_k_frac[12]));
   assign ex1_c_frac_pre3_b[13] = (~(sel_c_imm & ex1_c_k_frac[13]));
   assign ex1_c_frac_pre3_b[14] = (~(sel_c_imm & ex1_c_k_frac[14]));
   assign ex1_c_frac_pre3_b[15] = (~(sel_c_imm & ex1_c_k_frac[15]));
   assign ex1_c_frac_pre3_b[16] = (~(sel_c_imm & ex1_c_k_frac[16]));
   assign ex1_c_frac_pre3_b[17] = (~(sel_c_imm & ex1_c_k_frac[17]));
   assign ex1_c_frac_pre3_b[18] = (~(sel_c_imm & ex1_c_k_frac[18]));
   assign ex1_c_frac_pre3_b[19] = (~(sel_c_imm & ex1_c_k_frac[19]));
   assign ex1_c_frac_pre3_b[20] = (~(sel_c_imm & ex1_c_k_frac[20]));
   assign ex1_c_frac_pre3_b[21] = (~(sel_c_imm & ex1_c_k_frac[21]));
   assign ex1_c_frac_pre3_b[22] = (~(sel_c_imm & ex1_c_k_frac[22]));
   assign ex1_c_frac_pre3_b[23] = (~(sel_c_imm & ex1_c_k_frac[23]));
   assign ex1_c_frac_pre3_b[24] = (~(sel_c_imm & ex1_c_k_frac[24]));
   assign ex1_c_frac_pre3_b[25] = (~(sel_c_imm & ex1_c_k_frac[25]));
   assign ex1_c_frac_pre3_b[26] = (~(sel_c_imm & ex1_c_k_frac[26]));
   assign ex1_c_frac_pre3_b[27] = (~(sel_c_imm & ex1_c_k_frac[27]));
   assign ex1_c_frac_pre3_b[28] = (~(sel_c_imm & ex1_c_k_frac[28]));
   assign ex1_c_frac_pre3_b[29] = (~(sel_c_imm & ex1_c_k_frac[29]));
   assign ex1_c_frac_pre3_b[30] = (~(sel_c_imm & ex1_c_k_frac[30]));
   assign ex1_c_frac_pre3_b[31] = (~(sel_c_imm & ex1_c_k_frac[31]));
   assign ex1_c_frac_pre3_b[32] = (~(sel_c_imm & ex1_c_k_frac[32]));
   assign ex1_c_frac_pre3_b[33] = (~(sel_c_imm & ex1_c_k_frac[33]));
   assign ex1_c_frac_pre3_b[34] = (~(sel_c_imm & ex1_c_k_frac[34]));
   assign ex1_c_frac_pre3_b[35] = (~(sel_c_imm & ex1_c_k_frac[35]));
   assign ex1_c_frac_pre3_b[36] = (~(sel_c_imm & ex1_c_k_frac[36]));
   assign ex1_c_frac_pre3_b[37] = (~(sel_c_imm & ex1_c_k_frac[37]));
   assign ex1_c_frac_pre3_b[38] = (~(sel_c_imm & ex1_c_k_frac[38]));
   assign ex1_c_frac_pre3_b[39] = (~(sel_c_imm & ex1_c_k_frac[39]));
   assign ex1_c_frac_pre3_b[40] = (~(sel_c_imm & ex1_c_k_frac[40]));
   assign ex1_c_frac_pre3_b[41] = (~(sel_c_imm & ex1_c_k_frac[41]));
   assign ex1_c_frac_pre3_b[42] = (~(sel_c_imm & ex1_c_k_frac[42]));
   assign ex1_c_frac_pre3_b[43] = (~(sel_c_imm & ex1_c_k_frac[43]));
   assign ex1_c_frac_pre3_b[44] = (~(sel_c_imm & ex1_c_k_frac[44]));
   assign ex1_c_frac_pre3_b[45] = (~(sel_c_imm & ex1_c_k_frac[45]));
   assign ex1_c_frac_pre3_b[46] = (~(sel_c_imm & ex1_c_k_frac[46]));
   assign ex1_c_frac_pre3_b[47] = (~(sel_c_imm & ex1_c_k_frac[47]));
   assign ex1_c_frac_pre3_b[48] = (~(sel_c_imm & ex1_c_k_frac[48]));
   assign ex1_c_frac_pre3_b[49] = (~(sel_c_imm & ex1_c_k_frac[49]));
   assign ex1_c_frac_pre3_b[50] = (~(sel_c_imm & ex1_c_k_frac[50]));
   assign ex1_c_frac_pre3_b[51] = (~(sel_c_imm & ex1_c_k_frac[51]));
   assign ex1_c_frac_pre3_b[52] = (~(sel_c_imm & ex1_c_k_frac[52]));

   assign ex1_c_frac_pre3_hulp_b = (~((sel_c_imm & ex1_c_k_frac[24]) | ex1_hulp_sp));

   assign ex1_hulp_sp = f_dcd_ex1_sp & f_dcd_ex1_uc_fc_hulp;

   assign ex1_b_frac_pre3_b[0] = (~(sel_b_imm & ex1_b_k_frac[0]));
   assign ex1_b_frac_pre3_b[1] = (~(sel_b_imm & ex1_b_k_frac[1]));

   assign ex1_a_frac_pre1_b[0] = (~((sel_a_res0 & ex7_frac_res_ear[0]) | (sel_a_res1 & ex7_frac_a_res_dly[0])));
   assign ex1_a_frac_pre1_b[1] = (~((sel_a_res0 & ex7_frac_res_ear[1]) | (sel_a_res1 & ex7_frac_a_res_dly[1])));
   assign ex1_a_frac_pre1_b[2] = (~((sel_a_res0 & ex7_frac_res_ear[2]) | (sel_a_res1 & ex7_frac_a_res_dly[2])));
   assign ex1_a_frac_pre1_b[3] = (~((sel_a_res0 & ex7_frac_res_ear[3]) | (sel_a_res1 & ex7_frac_a_res_dly[3])));
   assign ex1_a_frac_pre1_b[4] = (~((sel_a_res0 & ex7_frac_res_ear[4]) | (sel_a_res1 & ex7_frac_a_res_dly[4])));
   assign ex1_a_frac_pre1_b[5] = (~((sel_a_res0 & ex7_frac_res_ear[5]) | (sel_a_res1 & ex7_frac_a_res_dly[5])));
   assign ex1_a_frac_pre1_b[6] = (~((sel_a_res0 & ex7_frac_res_ear[6]) | (sel_a_res1 & ex7_frac_a_res_dly[6])));
   assign ex1_a_frac_pre1_b[7] = (~((sel_a_res0 & ex7_frac_res_ear[7]) | (sel_a_res1 & ex7_frac_a_res_dly[7])));
   assign ex1_a_frac_pre1_b[8] = (~((sel_a_res0 & ex7_frac_res_ear[8]) | (sel_a_res1 & ex7_frac_a_res_dly[8])));
   assign ex1_a_frac_pre1_b[9] = (~((sel_a_res0 & ex7_frac_res_ear[9]) | (sel_a_res1 & ex7_frac_a_res_dly[9])));
   assign ex1_a_frac_pre1_b[10] = (~((sel_a_res0 & ex7_frac_res_ear[10]) | (sel_a_res1 & ex7_frac_a_res_dly[10])));
   assign ex1_a_frac_pre1_b[11] = (~((sel_a_res0 & ex7_frac_res_ear[11]) | (sel_a_res1 & ex7_frac_a_res_dly[11])));
   assign ex1_a_frac_pre1_b[12] = (~((sel_a_res0 & ex7_frac_res_ear[12]) | (sel_a_res1 & ex7_frac_a_res_dly[12])));
   assign ex1_a_frac_pre1_b[13] = (~((sel_a_res0 & ex7_frac_res_ear[13]) | (sel_a_res1 & ex7_frac_a_res_dly[13])));
   assign ex1_a_frac_pre1_b[14] = (~((sel_a_res0 & ex7_frac_res_ear[14]) | (sel_a_res1 & ex7_frac_a_res_dly[14])));
   assign ex1_a_frac_pre1_b[15] = (~((sel_a_res0 & ex7_frac_res_ear[15]) | (sel_a_res1 & ex7_frac_a_res_dly[15])));
   assign ex1_a_frac_pre1_b[16] = (~((sel_a_res0 & ex7_frac_res_ear[16]) | (sel_a_res1 & ex7_frac_a_res_dly[16])));
   assign ex1_a_frac_pre1_b[17] = (~((sel_a_res0 & ex7_frac_res_ear[17]) | (sel_a_res1 & ex7_frac_a_res_dly[17])));
   assign ex1_a_frac_pre1_b[18] = (~((sel_a_res0 & ex7_frac_res_ear[18]) | (sel_a_res1 & ex7_frac_a_res_dly[18])));
   assign ex1_a_frac_pre1_b[19] = (~((sel_a_res0 & ex7_frac_res_ear[19]) | (sel_a_res1 & ex7_frac_a_res_dly[19])));
   assign ex1_a_frac_pre1_b[20] = (~((sel_a_res0 & ex7_frac_res_ear[20]) | (sel_a_res1 & ex7_frac_a_res_dly[20])));
   assign ex1_a_frac_pre1_b[21] = (~((sel_a_res0 & ex7_frac_res_ear[21]) | (sel_a_res1 & ex7_frac_a_res_dly[21])));
   assign ex1_a_frac_pre1_b[22] = (~((sel_a_res0 & ex7_frac_res_ear[22]) | (sel_a_res1 & ex7_frac_a_res_dly[22])));
   assign ex1_a_frac_pre1_b[23] = (~((sel_a_res0 & ex7_frac_res_ear[23]) | (sel_a_res1 & ex7_frac_a_res_dly[23])));
   assign ex1_a_frac_pre1_b[24] = (~((sel_a_res0 & ex7_frac_res_ear[24]) | (sel_a_res1 & ex7_frac_a_res_dly[24])));
   assign ex1_a_frac_pre1_b[25] = (~((sel_a_res0 & ex7_frac_res_ear[25]) | (sel_a_res1 & ex7_frac_a_res_dly[25])));
   assign ex1_a_frac_pre1_b[26] = (~((sel_a_res0 & ex7_frac_res_ear[26]) | (sel_a_res1 & ex7_frac_a_res_dly[26])));
   assign ex1_a_frac_pre1_b[27] = (~((sel_a_res0 & ex7_frac_res_ear[27]) | (sel_a_res1 & ex7_frac_a_res_dly[27])));
   assign ex1_a_frac_pre1_b[28] = (~((sel_a_res0 & ex7_frac_res_ear[28]) | (sel_a_res1 & ex7_frac_a_res_dly[28])));
   assign ex1_a_frac_pre1_b[29] = (~((sel_a_res0 & ex7_frac_res_ear[29]) | (sel_a_res1 & ex7_frac_a_res_dly[29])));
   assign ex1_a_frac_pre1_b[30] = (~((sel_a_res0 & ex7_frac_res_ear[30]) | (sel_a_res1 & ex7_frac_a_res_dly[30])));
   assign ex1_a_frac_pre1_b[31] = (~((sel_a_res0 & ex7_frac_res_ear[31]) | (sel_a_res1 & ex7_frac_a_res_dly[31])));
   assign ex1_a_frac_pre1_b[32] = (~((sel_a_res0 & ex7_frac_res_ear[32]) | (sel_a_res1 & ex7_frac_a_res_dly[32])));
   assign ex1_a_frac_pre1_b[33] = (~((sel_a_res0 & ex7_frac_res_ear[33]) | (sel_a_res1 & ex7_frac_a_res_dly[33])));
   assign ex1_a_frac_pre1_b[34] = (~((sel_a_res0 & ex7_frac_res_ear[34]) | (sel_a_res1 & ex7_frac_a_res_dly[34])));
   assign ex1_a_frac_pre1_b[35] = (~((sel_a_res0 & ex7_frac_res_ear[35]) | (sel_a_res1 & ex7_frac_a_res_dly[35])));
   assign ex1_a_frac_pre1_b[36] = (~((sel_a_res0 & ex7_frac_res_ear[36]) | (sel_a_res1 & ex7_frac_a_res_dly[36])));
   assign ex1_a_frac_pre1_b[37] = (~((sel_a_res0 & ex7_frac_res_ear[37]) | (sel_a_res1 & ex7_frac_a_res_dly[37])));
   assign ex1_a_frac_pre1_b[38] = (~((sel_a_res0 & ex7_frac_res_ear[38]) | (sel_a_res1 & ex7_frac_a_res_dly[38])));
   assign ex1_a_frac_pre1_b[39] = (~((sel_a_res0 & ex7_frac_res_ear[39]) | (sel_a_res1 & ex7_frac_a_res_dly[39])));
   assign ex1_a_frac_pre1_b[40] = (~((sel_a_res0 & ex7_frac_res_ear[40]) | (sel_a_res1 & ex7_frac_a_res_dly[40])));
   assign ex1_a_frac_pre1_b[41] = (~((sel_a_res0 & ex7_frac_res_ear[41]) | (sel_a_res1 & ex7_frac_a_res_dly[41])));
   assign ex1_a_frac_pre1_b[42] = (~((sel_a_res0 & ex7_frac_res_ear[42]) | (sel_a_res1 & ex7_frac_a_res_dly[42])));
   assign ex1_a_frac_pre1_b[43] = (~((sel_a_res0 & ex7_frac_res_ear[43]) | (sel_a_res1 & ex7_frac_a_res_dly[43])));
   assign ex1_a_frac_pre1_b[44] = (~((sel_a_res0 & ex7_frac_res_ear[44]) | (sel_a_res1 & ex7_frac_a_res_dly[44])));
   assign ex1_a_frac_pre1_b[45] = (~((sel_a_res0 & ex7_frac_res_ear[45]) | (sel_a_res1 & ex7_frac_a_res_dly[45])));
   assign ex1_a_frac_pre1_b[46] = (~((sel_a_res0 & ex7_frac_res_ear[46]) | (sel_a_res1 & ex7_frac_a_res_dly[46])));
   assign ex1_a_frac_pre1_b[47] = (~((sel_a_res0 & ex7_frac_res_ear[47]) | (sel_a_res1 & ex7_frac_a_res_dly[47])));
   assign ex1_a_frac_pre1_b[48] = (~((sel_a_res0 & ex7_frac_res_ear[48]) | (sel_a_res1 & ex7_frac_a_res_dly[48])));
   assign ex1_a_frac_pre1_b[49] = (~((sel_a_res0 & ex7_frac_res_ear[49]) | (sel_a_res1 & ex7_frac_a_res_dly[49])));
   assign ex1_a_frac_pre1_b[50] = (~((sel_a_res0 & ex7_frac_res_ear[50]) | (sel_a_res1 & ex7_frac_a_res_dly[50])));
   assign ex1_a_frac_pre1_b[51] = (~((sel_a_res0 & ex7_frac_res_ear[51]) | (sel_a_res1 & ex7_frac_a_res_dly[51])));
   assign ex1_a_frac_pre1_b[52] = (~((sel_a_res0 & ex7_frac_res_ear[52]) | (sel_a_res1 & ex7_frac_a_res_dly[52])));

   assign ex1_c_frac_pre1_b[0] = (~((sel_c_res0 & ex7_frac_res_ear[0]) | (sel_c_res1 & ex7_frac_c_res_dly[0])));
   assign ex1_c_frac_pre1_b[1] = (~((sel_c_res0 & ex7_frac_res_ear[1]) | (sel_c_res1 & ex7_frac_c_res_dly[1])));
   assign ex1_c_frac_pre1_b[2] = (~((sel_c_res0 & ex7_frac_res_ear[2]) | (sel_c_res1 & ex7_frac_c_res_dly[2])));
   assign ex1_c_frac_pre1_b[3] = (~((sel_c_res0 & ex7_frac_res_ear[3]) | (sel_c_res1 & ex7_frac_c_res_dly[3])));
   assign ex1_c_frac_pre1_b[4] = (~((sel_c_res0 & ex7_frac_res_ear[4]) | (sel_c_res1 & ex7_frac_c_res_dly[4])));
   assign ex1_c_frac_pre1_b[5] = (~((sel_c_res0 & ex7_frac_res_ear[5]) | (sel_c_res1 & ex7_frac_c_res_dly[5])));
   assign ex1_c_frac_pre1_b[6] = (~((sel_c_res0 & ex7_frac_res_ear[6]) | (sel_c_res1 & ex7_frac_c_res_dly[6])));
   assign ex1_c_frac_pre1_b[7] = (~((sel_c_res0 & ex7_frac_res_ear[7]) | (sel_c_res1 & ex7_frac_c_res_dly[7])));
   assign ex1_c_frac_pre1_b[8] = (~((sel_c_res0 & ex7_frac_res_ear[8]) | (sel_c_res1 & ex7_frac_c_res_dly[8])));
   assign ex1_c_frac_pre1_b[9] = (~((sel_c_res0 & ex7_frac_res_ear[9]) | (sel_c_res1 & ex7_frac_c_res_dly[9])));
   assign ex1_c_frac_pre1_b[10] = (~((sel_c_res0 & ex7_frac_res_ear[10]) | (sel_c_res1 & ex7_frac_c_res_dly[10])));
   assign ex1_c_frac_pre1_b[11] = (~((sel_c_res0 & ex7_frac_res_ear[11]) | (sel_c_res1 & ex7_frac_c_res_dly[11])));
   assign ex1_c_frac_pre1_b[12] = (~((sel_c_res0 & ex7_frac_res_ear[12]) | (sel_c_res1 & ex7_frac_c_res_dly[12])));
   assign ex1_c_frac_pre1_b[13] = (~((sel_c_res0 & ex7_frac_res_ear[13]) | (sel_c_res1 & ex7_frac_c_res_dly[13])));
   assign ex1_c_frac_pre1_b[14] = (~((sel_c_res0 & ex7_frac_res_ear[14]) | (sel_c_res1 & ex7_frac_c_res_dly[14])));
   assign ex1_c_frac_pre1_b[15] = (~((sel_c_res0 & ex7_frac_res_ear[15]) | (sel_c_res1 & ex7_frac_c_res_dly[15])));
   assign ex1_c_frac_pre1_b[16] = (~((sel_c_res0 & ex7_frac_res_ear[16]) | (sel_c_res1 & ex7_frac_c_res_dly[16])));
   assign ex1_c_frac_pre1_b[17] = (~((sel_c_res0 & ex7_frac_res_ear[17]) | (sel_c_res1 & ex7_frac_c_res_dly[17])));
   assign ex1_c_frac_pre1_b[18] = (~((sel_c_res0 & ex7_frac_res_ear[18]) | (sel_c_res1 & ex7_frac_c_res_dly[18])));
   assign ex1_c_frac_pre1_b[19] = (~((sel_c_res0 & ex7_frac_res_ear[19]) | (sel_c_res1 & ex7_frac_c_res_dly[19])));
   assign ex1_c_frac_pre1_b[20] = (~((sel_c_res0 & ex7_frac_res_ear[20]) | (sel_c_res1 & ex7_frac_c_res_dly[20])));
   assign ex1_c_frac_pre1_b[21] = (~((sel_c_res0 & ex7_frac_res_ear[21]) | (sel_c_res1 & ex7_frac_c_res_dly[21])));
   assign ex1_c_frac_pre1_b[22] = (~((sel_c_res0 & ex7_frac_res_ear[22]) | (sel_c_res1 & ex7_frac_c_res_dly[22])));
   assign ex1_c_frac_pre1_b[23] = (~((sel_c_res0 & ex7_frac_res_ear[23]) | (sel_c_res1 & ex7_frac_c_res_dly[23])));
   assign ex1_c_frac_pre1_b[24] = (~((sel_c_res0 & ex7_frac_res_ear[24]) | (sel_c_res1 & ex7_frac_c_res_dly[24])));
   assign ex1_c_frac_pre1_b[25] = (~((sel_c_res0 & ex7_frac_res_ear[25]) | (sel_c_res1 & ex7_frac_c_res_dly[25])));
   assign ex1_c_frac_pre1_b[26] = (~((sel_c_res0 & ex7_frac_res_ear[26]) | (sel_c_res1 & ex7_frac_c_res_dly[26])));
   assign ex1_c_frac_pre1_b[27] = (~((sel_c_res0 & ex7_frac_res_ear[27]) | (sel_c_res1 & ex7_frac_c_res_dly[27])));
   assign ex1_c_frac_pre1_b[28] = (~((sel_c_res0 & ex7_frac_res_ear[28]) | (sel_c_res1 & ex7_frac_c_res_dly[28])));
   assign ex1_c_frac_pre1_b[29] = (~((sel_c_res0 & ex7_frac_res_ear[29]) | (sel_c_res1 & ex7_frac_c_res_dly[29])));
   assign ex1_c_frac_pre1_b[30] = (~((sel_c_res0 & ex7_frac_res_ear[30]) | (sel_c_res1 & ex7_frac_c_res_dly[30])));
   assign ex1_c_frac_pre1_b[31] = (~((sel_c_res0 & ex7_frac_res_ear[31]) | (sel_c_res1 & ex7_frac_c_res_dly[31])));
   assign ex1_c_frac_pre1_b[32] = (~((sel_c_res0 & ex7_frac_res_ear[32]) | (sel_c_res1 & ex7_frac_c_res_dly[32])));
   assign ex1_c_frac_pre1_b[33] = (~((sel_c_res0 & ex7_frac_res_ear[33]) | (sel_c_res1 & ex7_frac_c_res_dly[33])));
   assign ex1_c_frac_pre1_b[34] = (~((sel_c_res0 & ex7_frac_res_ear[34]) | (sel_c_res1 & ex7_frac_c_res_dly[34])));
   assign ex1_c_frac_pre1_b[35] = (~((sel_c_res0 & ex7_frac_res_ear[35]) | (sel_c_res1 & ex7_frac_c_res_dly[35])));
   assign ex1_c_frac_pre1_b[36] = (~((sel_c_res0 & ex7_frac_res_ear[36]) | (sel_c_res1 & ex7_frac_c_res_dly[36])));
   assign ex1_c_frac_pre1_b[37] = (~((sel_c_res0 & ex7_frac_res_ear[37]) | (sel_c_res1 & ex7_frac_c_res_dly[37])));
   assign ex1_c_frac_pre1_b[38] = (~((sel_c_res0 & ex7_frac_res_ear[38]) | (sel_c_res1 & ex7_frac_c_res_dly[38])));
   assign ex1_c_frac_pre1_b[39] = (~((sel_c_res0 & ex7_frac_res_ear[39]) | (sel_c_res1 & ex7_frac_c_res_dly[39])));
   assign ex1_c_frac_pre1_b[40] = (~((sel_c_res0 & ex7_frac_res_ear[40]) | (sel_c_res1 & ex7_frac_c_res_dly[40])));
   assign ex1_c_frac_pre1_b[41] = (~((sel_c_res0 & ex7_frac_res_ear[41]) | (sel_c_res1 & ex7_frac_c_res_dly[41])));
   assign ex1_c_frac_pre1_b[42] = (~((sel_c_res0 & ex7_frac_res_ear[42]) | (sel_c_res1 & ex7_frac_c_res_dly[42])));
   assign ex1_c_frac_pre1_b[43] = (~((sel_c_res0 & ex7_frac_res_ear[43]) | (sel_c_res1 & ex7_frac_c_res_dly[43])));
   assign ex1_c_frac_pre1_b[44] = (~((sel_c_res0 & ex7_frac_res_ear[44]) | (sel_c_res1 & ex7_frac_c_res_dly[44])));
   assign ex1_c_frac_pre1_b[45] = (~((sel_c_res0 & ex7_frac_res_ear[45]) | (sel_c_res1 & ex7_frac_c_res_dly[45])));
   assign ex1_c_frac_pre1_b[46] = (~((sel_c_res0 & ex7_frac_res_ear[46]) | (sel_c_res1 & ex7_frac_c_res_dly[46])));
   assign ex1_c_frac_pre1_b[47] = (~((sel_c_res0 & ex7_frac_res_ear[47]) | (sel_c_res1 & ex7_frac_c_res_dly[47])));
   assign ex1_c_frac_pre1_b[48] = (~((sel_c_res0 & ex7_frac_res_ear[48]) | (sel_c_res1 & ex7_frac_c_res_dly[48])));
   assign ex1_c_frac_pre1_b[49] = (~((sel_c_res0 & ex7_frac_res_ear[49]) | (sel_c_res1 & ex7_frac_c_res_dly[49])));
   assign ex1_c_frac_pre1_b[50] = (~((sel_c_res0 & ex7_frac_res_ear[50]) | (sel_c_res1 & ex7_frac_c_res_dly[50])));
   assign ex1_c_frac_pre1_b[51] = (~((sel_c_res0 & ex7_frac_res_ear[51]) | (sel_c_res1 & ex7_frac_c_res_dly[51])));
   assign ex1_c_frac_pre1_b[52] = (~((sel_c_res0 & ex7_frac_res_ear[52]) | (sel_c_res1 & ex7_frac_c_res_dly[52])));

   assign ex1_b_frac_pre1_b[0] = (~((sel_b_res0 & ex7_frac_res_ear[0]) | (sel_b_res1 & ex7_frac_b_res_dly[0])));
   assign ex1_b_frac_pre1_b[1] = (~((sel_b_res0 & ex7_frac_res_ear[1]) | (sel_b_res1 & ex7_frac_b_res_dly[1])));
   assign ex1_b_frac_pre1_b[2] = (~((sel_b_res0 & ex7_frac_res_ear[2]) | (sel_b_res1 & ex7_frac_b_res_dly[2])));
   assign ex1_b_frac_pre1_b[3] = (~((sel_b_res0 & ex7_frac_res_ear[3]) | (sel_b_res1 & ex7_frac_b_res_dly[3])));
   assign ex1_b_frac_pre1_b[4] = (~((sel_b_res0 & ex7_frac_res_ear[4]) | (sel_b_res1 & ex7_frac_b_res_dly[4])));
   assign ex1_b_frac_pre1_b[5] = (~((sel_b_res0 & ex7_frac_res_ear[5]) | (sel_b_res1 & ex7_frac_b_res_dly[5])));
   assign ex1_b_frac_pre1_b[6] = (~((sel_b_res0 & ex7_frac_res_ear[6]) | (sel_b_res1 & ex7_frac_b_res_dly[6])));
   assign ex1_b_frac_pre1_b[7] = (~((sel_b_res0 & ex7_frac_res_ear[7]) | (sel_b_res1 & ex7_frac_b_res_dly[7])));
   assign ex1_b_frac_pre1_b[8] = (~((sel_b_res0 & ex7_frac_res_ear[8]) | (sel_b_res1 & ex7_frac_b_res_dly[8])));
   assign ex1_b_frac_pre1_b[9] = (~((sel_b_res0 & ex7_frac_res_ear[9]) | (sel_b_res1 & ex7_frac_b_res_dly[9])));
   assign ex1_b_frac_pre1_b[10] = (~((sel_b_res0 & ex7_frac_res_ear[10]) | (sel_b_res1 & ex7_frac_b_res_dly[10])));
   assign ex1_b_frac_pre1_b[11] = (~((sel_b_res0 & ex7_frac_res_ear[11]) | (sel_b_res1 & ex7_frac_b_res_dly[11])));
   assign ex1_b_frac_pre1_b[12] = (~((sel_b_res0 & ex7_frac_res_ear[12]) | (sel_b_res1 & ex7_frac_b_res_dly[12])));
   assign ex1_b_frac_pre1_b[13] = (~((sel_b_res0 & ex7_frac_res_ear[13]) | (sel_b_res1 & ex7_frac_b_res_dly[13])));
   assign ex1_b_frac_pre1_b[14] = (~((sel_b_res0 & ex7_frac_res_ear[14]) | (sel_b_res1 & ex7_frac_b_res_dly[14])));
   assign ex1_b_frac_pre1_b[15] = (~((sel_b_res0 & ex7_frac_res_ear[15]) | (sel_b_res1 & ex7_frac_b_res_dly[15])));
   assign ex1_b_frac_pre1_b[16] = (~((sel_b_res0 & ex7_frac_res_ear[16]) | (sel_b_res1 & ex7_frac_b_res_dly[16])));
   assign ex1_b_frac_pre1_b[17] = (~((sel_b_res0 & ex7_frac_res_ear[17]) | (sel_b_res1 & ex7_frac_b_res_dly[17])));
   assign ex1_b_frac_pre1_b[18] = (~((sel_b_res0 & ex7_frac_res_ear[18]) | (sel_b_res1 & ex7_frac_b_res_dly[18])));
   assign ex1_b_frac_pre1_b[19] = (~((sel_b_res0 & ex7_frac_res_ear[19]) | (sel_b_res1 & ex7_frac_b_res_dly[19])));
   assign ex1_b_frac_pre1_b[20] = (~((sel_b_res0 & ex7_frac_res_ear[20]) | (sel_b_res1 & ex7_frac_b_res_dly[20])));
   assign ex1_b_frac_pre1_b[21] = (~((sel_b_res0 & ex7_frac_res_ear[21]) | (sel_b_res1 & ex7_frac_b_res_dly[21])));
   assign ex1_b_frac_pre1_b[22] = (~((sel_b_res0 & ex7_frac_res_ear[22]) | (sel_b_res1 & ex7_frac_b_res_dly[22])));
   assign ex1_b_frac_pre1_b[23] = (~((sel_b_res0 & ex7_frac_res_ear[23]) | (sel_b_res1 & ex7_frac_b_res_dly[23])));
   assign ex1_b_frac_pre1_b[24] = (~((sel_b_res0 & ex7_frac_res_ear[24]) | (sel_b_res1 & ex7_frac_b_res_dly[24])));
   assign ex1_b_frac_pre1_b[25] = (~((sel_b_res0 & ex7_frac_res_ear[25]) | (sel_b_res1 & ex7_frac_b_res_dly[25])));
   assign ex1_b_frac_pre1_b[26] = (~((sel_b_res0 & ex7_frac_res_ear[26]) | (sel_b_res1 & ex7_frac_b_res_dly[26])));
   assign ex1_b_frac_pre1_b[27] = (~((sel_b_res0 & ex7_frac_res_ear[27]) | (sel_b_res1 & ex7_frac_b_res_dly[27])));
   assign ex1_b_frac_pre1_b[28] = (~((sel_b_res0 & ex7_frac_res_ear[28]) | (sel_b_res1 & ex7_frac_b_res_dly[28])));
   assign ex1_b_frac_pre1_b[29] = (~((sel_b_res0 & ex7_frac_res_ear[29]) | (sel_b_res1 & ex7_frac_b_res_dly[29])));
   assign ex1_b_frac_pre1_b[30] = (~((sel_b_res0 & ex7_frac_res_ear[30]) | (sel_b_res1 & ex7_frac_b_res_dly[30])));
   assign ex1_b_frac_pre1_b[31] = (~((sel_b_res0 & ex7_frac_res_ear[31]) | (sel_b_res1 & ex7_frac_b_res_dly[31])));
   assign ex1_b_frac_pre1_b[32] = (~((sel_b_res0 & ex7_frac_res_ear[32]) | (sel_b_res1 & ex7_frac_b_res_dly[32])));
   assign ex1_b_frac_pre1_b[33] = (~((sel_b_res0 & ex7_frac_res_ear[33]) | (sel_b_res1 & ex7_frac_b_res_dly[33])));
   assign ex1_b_frac_pre1_b[34] = (~((sel_b_res0 & ex7_frac_res_ear[34]) | (sel_b_res1 & ex7_frac_b_res_dly[34])));
   assign ex1_b_frac_pre1_b[35] = (~((sel_b_res0 & ex7_frac_res_ear[35]) | (sel_b_res1 & ex7_frac_b_res_dly[35])));
   assign ex1_b_frac_pre1_b[36] = (~((sel_b_res0 & ex7_frac_res_ear[36]) | (sel_b_res1 & ex7_frac_b_res_dly[36])));
   assign ex1_b_frac_pre1_b[37] = (~((sel_b_res0 & ex7_frac_res_ear[37]) | (sel_b_res1 & ex7_frac_b_res_dly[37])));
   assign ex1_b_frac_pre1_b[38] = (~((sel_b_res0 & ex7_frac_res_ear[38]) | (sel_b_res1 & ex7_frac_b_res_dly[38])));
   assign ex1_b_frac_pre1_b[39] = (~((sel_b_res0 & ex7_frac_res_ear[39]) | (sel_b_res1 & ex7_frac_b_res_dly[39])));
   assign ex1_b_frac_pre1_b[40] = (~((sel_b_res0 & ex7_frac_res_ear[40]) | (sel_b_res1 & ex7_frac_b_res_dly[40])));
   assign ex1_b_frac_pre1_b[41] = (~((sel_b_res0 & ex7_frac_res_ear[41]) | (sel_b_res1 & ex7_frac_b_res_dly[41])));
   assign ex1_b_frac_pre1_b[42] = (~((sel_b_res0 & ex7_frac_res_ear[42]) | (sel_b_res1 & ex7_frac_b_res_dly[42])));
   assign ex1_b_frac_pre1_b[43] = (~((sel_b_res0 & ex7_frac_res_ear[43]) | (sel_b_res1 & ex7_frac_b_res_dly[43])));
   assign ex1_b_frac_pre1_b[44] = (~((sel_b_res0 & ex7_frac_res_ear[44]) | (sel_b_res1 & ex7_frac_b_res_dly[44])));
   assign ex1_b_frac_pre1_b[45] = (~((sel_b_res0 & ex7_frac_res_ear[45]) | (sel_b_res1 & ex7_frac_b_res_dly[45])));
   assign ex1_b_frac_pre1_b[46] = (~((sel_b_res0 & ex7_frac_res_ear[46]) | (sel_b_res1 & ex7_frac_b_res_dly[46])));
   assign ex1_b_frac_pre1_b[47] = (~((sel_b_res0 & ex7_frac_res_ear[47]) | (sel_b_res1 & ex7_frac_b_res_dly[47])));
   assign ex1_b_frac_pre1_b[48] = (~((sel_b_res0 & ex7_frac_res_ear[48]) | (sel_b_res1 & ex7_frac_b_res_dly[48])));
   assign ex1_b_frac_pre1_b[49] = (~((sel_b_res0 & ex7_frac_res_ear[49]) | (sel_b_res1 & ex7_frac_b_res_dly[49])));
   assign ex1_b_frac_pre1_b[50] = (~((sel_b_res0 & ex7_frac_res_ear[50]) | (sel_b_res1 & ex7_frac_b_res_dly[50])));
   assign ex1_b_frac_pre1_b[51] = (~((sel_b_res0 & ex7_frac_res_ear[51]) | (sel_b_res1 & ex7_frac_b_res_dly[51])));
   assign ex1_b_frac_pre1_b[52] = (~((sel_b_res0 & ex7_frac_res_ear[52]) | (sel_b_res1 & ex7_frac_b_res_dly[52])));

   assign ex1_s_frac_pre1_b[0] = (~((sel_s_res0 & ex7_frac_res_ear[0]) | (sel_s_res1 & ex7_frac_s_res_dly[0])));
   assign ex1_s_frac_pre1_b[1] = (~((sel_s_res0 & ex7_frac_res_ear[1]) | (sel_s_res1 & ex7_frac_s_res_dly[1])));
   assign ex1_s_frac_pre1_b[2] = (~((sel_s_res0 & ex7_frac_res_ear[2]) | (sel_s_res1 & ex7_frac_s_res_dly[2])));
   assign ex1_s_frac_pre1_b[3] = (~((sel_s_res0 & ex7_frac_res_ear[3]) | (sel_s_res1 & ex7_frac_s_res_dly[3])));
   assign ex1_s_frac_pre1_b[4] = (~((sel_s_res0 & ex7_frac_res_ear[4]) | (sel_s_res1 & ex7_frac_s_res_dly[4])));
   assign ex1_s_frac_pre1_b[5] = (~((sel_s_res0 & ex7_frac_res_ear[5]) | (sel_s_res1 & ex7_frac_s_res_dly[5])));
   assign ex1_s_frac_pre1_b[6] = (~((sel_s_res0 & ex7_frac_res_ear[6]) | (sel_s_res1 & ex7_frac_s_res_dly[6])));
   assign ex1_s_frac_pre1_b[7] = (~((sel_s_res0 & ex7_frac_res_ear[7]) | (sel_s_res1 & ex7_frac_s_res_dly[7])));
   assign ex1_s_frac_pre1_b[8] = (~((sel_s_res0 & ex7_frac_res_ear[8]) | (sel_s_res1 & ex7_frac_s_res_dly[8])));
   assign ex1_s_frac_pre1_b[9] = (~((sel_s_res0 & ex7_frac_res_ear[9]) | (sel_s_res1 & ex7_frac_s_res_dly[9])));
   assign ex1_s_frac_pre1_b[10] = (~((sel_s_res0 & ex7_frac_res_ear[10]) | (sel_s_res1 & ex7_frac_s_res_dly[10])));
   assign ex1_s_frac_pre1_b[11] = (~((sel_s_res0 & ex7_frac_res_ear[11]) | (sel_s_res1 & ex7_frac_s_res_dly[11])));
   assign ex1_s_frac_pre1_b[12] = (~((sel_s_res0 & ex7_frac_res_ear[12]) | (sel_s_res1 & ex7_frac_s_res_dly[12])));
   assign ex1_s_frac_pre1_b[13] = (~((sel_s_res0 & ex7_frac_res_ear[13]) | (sel_s_res1 & ex7_frac_s_res_dly[13])));
   assign ex1_s_frac_pre1_b[14] = (~((sel_s_res0 & ex7_frac_res_ear[14]) | (sel_s_res1 & ex7_frac_s_res_dly[14])));
   assign ex1_s_frac_pre1_b[15] = (~((sel_s_res0 & ex7_frac_res_ear[15]) | (sel_s_res1 & ex7_frac_s_res_dly[15])));
   assign ex1_s_frac_pre1_b[16] = (~((sel_s_res0 & ex7_frac_res_ear[16]) | (sel_s_res1 & ex7_frac_s_res_dly[16])));
   assign ex1_s_frac_pre1_b[17] = (~((sel_s_res0 & ex7_frac_res_ear[17]) | (sel_s_res1 & ex7_frac_s_res_dly[17])));
   assign ex1_s_frac_pre1_b[18] = (~((sel_s_res0 & ex7_frac_res_ear[18]) | (sel_s_res1 & ex7_frac_s_res_dly[18])));
   assign ex1_s_frac_pre1_b[19] = (~((sel_s_res0 & ex7_frac_res_ear[19]) | (sel_s_res1 & ex7_frac_s_res_dly[19])));
   assign ex1_s_frac_pre1_b[20] = (~((sel_s_res0 & ex7_frac_res_ear[20]) | (sel_s_res1 & ex7_frac_s_res_dly[20])));
   assign ex1_s_frac_pre1_b[21] = (~((sel_s_res0 & ex7_frac_res_ear[21]) | (sel_s_res1 & ex7_frac_s_res_dly[21])));
   assign ex1_s_frac_pre1_b[22] = (~((sel_s_res0 & ex7_frac_res_ear[22]) | (sel_s_res1 & ex7_frac_s_res_dly[22])));
   assign ex1_s_frac_pre1_b[23] = (~((sel_s_res0 & ex7_frac_res_ear[23]) | (sel_s_res1 & ex7_frac_s_res_dly[23])));
   assign ex1_s_frac_pre1_b[24] = (~((sel_s_res0 & ex7_frac_res_ear[24]) | (sel_s_res1 & ex7_frac_s_res_dly[24])));
   assign ex1_s_frac_pre1_b[25] = (~((sel_s_res0 & ex7_frac_res_ear[25]) | (sel_s_res1 & ex7_frac_s_res_dly[25])));
   assign ex1_s_frac_pre1_b[26] = (~((sel_s_res0 & ex7_frac_res_ear[26]) | (sel_s_res1 & ex7_frac_s_res_dly[26])));
   assign ex1_s_frac_pre1_b[27] = (~((sel_s_res0 & ex7_frac_res_ear[27]) | (sel_s_res1 & ex7_frac_s_res_dly[27])));
   assign ex1_s_frac_pre1_b[28] = (~((sel_s_res0 & ex7_frac_res_ear[28]) | (sel_s_res1 & ex7_frac_s_res_dly[28])));
   assign ex1_s_frac_pre1_b[29] = (~((sel_s_res0 & ex7_frac_res_ear[29]) | (sel_s_res1 & ex7_frac_s_res_dly[29])));
   assign ex1_s_frac_pre1_b[30] = (~((sel_s_res0 & ex7_frac_res_ear[30]) | (sel_s_res1 & ex7_frac_s_res_dly[30])));
   assign ex1_s_frac_pre1_b[31] = (~((sel_s_res0 & ex7_frac_res_ear[31]) | (sel_s_res1 & ex7_frac_s_res_dly[31])));
   assign ex1_s_frac_pre1_b[32] = (~((sel_s_res0 & ex7_frac_res_ear[32]) | (sel_s_res1 & ex7_frac_s_res_dly[32])));
   assign ex1_s_frac_pre1_b[33] = (~((sel_s_res0 & ex7_frac_res_ear[33]) | (sel_s_res1 & ex7_frac_s_res_dly[33])));
   assign ex1_s_frac_pre1_b[34] = (~((sel_s_res0 & ex7_frac_res_ear[34]) | (sel_s_res1 & ex7_frac_s_res_dly[34])));
   assign ex1_s_frac_pre1_b[35] = (~((sel_s_res0 & ex7_frac_res_ear[35]) | (sel_s_res1 & ex7_frac_s_res_dly[35])));
   assign ex1_s_frac_pre1_b[36] = (~((sel_s_res0 & ex7_frac_res_ear[36]) | (sel_s_res1 & ex7_frac_s_res_dly[36])));
   assign ex1_s_frac_pre1_b[37] = (~((sel_s_res0 & ex7_frac_res_ear[37]) | (sel_s_res1 & ex7_frac_s_res_dly[37])));
   assign ex1_s_frac_pre1_b[38] = (~((sel_s_res0 & ex7_frac_res_ear[38]) | (sel_s_res1 & ex7_frac_s_res_dly[38])));
   assign ex1_s_frac_pre1_b[39] = (~((sel_s_res0 & ex7_frac_res_ear[39]) | (sel_s_res1 & ex7_frac_s_res_dly[39])));
   assign ex1_s_frac_pre1_b[40] = (~((sel_s_res0 & ex7_frac_res_ear[40]) | (sel_s_res1 & ex7_frac_s_res_dly[40])));
   assign ex1_s_frac_pre1_b[41] = (~((sel_s_res0 & ex7_frac_res_ear[41]) | (sel_s_res1 & ex7_frac_s_res_dly[41])));
   assign ex1_s_frac_pre1_b[42] = (~((sel_s_res0 & ex7_frac_res_ear[42]) | (sel_s_res1 & ex7_frac_s_res_dly[42])));
   assign ex1_s_frac_pre1_b[43] = (~((sel_s_res0 & ex7_frac_res_ear[43]) | (sel_s_res1 & ex7_frac_s_res_dly[43])));
   assign ex1_s_frac_pre1_b[44] = (~((sel_s_res0 & ex7_frac_res_ear[44]) | (sel_s_res1 & ex7_frac_s_res_dly[44])));
   assign ex1_s_frac_pre1_b[45] = (~((sel_s_res0 & ex7_frac_res_ear[45]) | (sel_s_res1 & ex7_frac_s_res_dly[45])));
   assign ex1_s_frac_pre1_b[46] = (~((sel_s_res0 & ex7_frac_res_ear[46]) | (sel_s_res1 & ex7_frac_s_res_dly[46])));
   assign ex1_s_frac_pre1_b[47] = (~((sel_s_res0 & ex7_frac_res_ear[47]) | (sel_s_res1 & ex7_frac_s_res_dly[47])));
   assign ex1_s_frac_pre1_b[48] = (~((sel_s_res0 & ex7_frac_res_ear[48]) | (sel_s_res1 & ex7_frac_s_res_dly[48])));
   assign ex1_s_frac_pre1_b[49] = (~((sel_s_res0 & ex7_frac_res_ear[49]) | (sel_s_res1 & ex7_frac_s_res_dly[49])));
   assign ex1_s_frac_pre1_b[50] = (~((sel_s_res0 & ex7_frac_res_ear[50]) | (sel_s_res1 & ex7_frac_s_res_dly[50])));
   assign ex1_s_frac_pre1_b[51] = (~((sel_s_res0 & ex7_frac_res_ear[51]) | (sel_s_res1 & ex7_frac_s_res_dly[51])));
   assign ex1_s_frac_pre1_b[52] = (~((sel_s_res0 & ex7_frac_res_ear[52]) | (sel_s_res1 & ex7_frac_s_res_dly[52])));

   assign ex1_a_frac_pre2_b[0] = (~((sel_a_load0 & ex6_frac_lod_ear[0])   | (sel_a_reload0 & ex6_frac_relod_ear[0]) | (sel_a_load1 & ex7_frac_a_lod_dly[0])));
   assign ex1_a_frac_pre2_b[1] = (~((sel_a_load0 & ex6_frac_lod_ear[1])   | (sel_a_reload0 & ex6_frac_relod_ear[1]) | (sel_a_load1 & ex7_frac_a_lod_dly[1])));
   assign ex1_a_frac_pre2_b[2] = (~((sel_a_load0 & ex6_frac_lod_ear[2])   | (sel_a_reload0 & ex6_frac_relod_ear[2]) | (sel_a_load1 & ex7_frac_a_lod_dly[2])));
   assign ex1_a_frac_pre2_b[3] = (~((sel_a_load0 & ex6_frac_lod_ear[3])   | (sel_a_reload0 & ex6_frac_relod_ear[3]) | (sel_a_load1 & ex7_frac_a_lod_dly[3])));
   assign ex1_a_frac_pre2_b[4] = (~((sel_a_load0 & ex6_frac_lod_ear[4])   | (sel_a_reload0 & ex6_frac_relod_ear[4]) | (sel_a_load1 & ex7_frac_a_lod_dly[4])));
   assign ex1_a_frac_pre2_b[5] = (~((sel_a_load0 & ex6_frac_lod_ear[5])   | (sel_a_reload0 & ex6_frac_relod_ear[5]) | (sel_a_load1 & ex7_frac_a_lod_dly[5])));
   assign ex1_a_frac_pre2_b[6] = (~((sel_a_load0 & ex6_frac_lod_ear[6])   | (sel_a_reload0 & ex6_frac_relod_ear[6]) | (sel_a_load1 & ex7_frac_a_lod_dly[6])));
   assign ex1_a_frac_pre2_b[7] = (~((sel_a_load0 & ex6_frac_lod_ear[7])   | (sel_a_reload0 & ex6_frac_relod_ear[7]) | (sel_a_load1 & ex7_frac_a_lod_dly[7])));
   assign ex1_a_frac_pre2_b[8] = (~((sel_a_load0 & ex6_frac_lod_ear[8])   | (sel_a_reload0 & ex6_frac_relod_ear[8]) | (sel_a_load1 & ex7_frac_a_lod_dly[8])));
   assign ex1_a_frac_pre2_b[9] = (~((sel_a_load0 & ex6_frac_lod_ear[9])   | (sel_a_reload0 & ex6_frac_relod_ear[9]) | (sel_a_load1 & ex7_frac_a_lod_dly[9])));
   assign ex1_a_frac_pre2_b[10] = (~((sel_a_load0 & ex6_frac_lod_ear[10]) | (sel_a_reload0 & ex6_frac_relod_ear[10]) | (sel_a_load1 & ex7_frac_a_lod_dly[10])));
   assign ex1_a_frac_pre2_b[11] = (~((sel_a_load0 & ex6_frac_lod_ear[11]) | (sel_a_reload0 & ex6_frac_relod_ear[11]) | (sel_a_load1 & ex7_frac_a_lod_dly[11])));
   assign ex1_a_frac_pre2_b[12] = (~((sel_a_load0 & ex6_frac_lod_ear[12]) | (sel_a_reload0 & ex6_frac_relod_ear[12]) | (sel_a_load1 & ex7_frac_a_lod_dly[12])));
   assign ex1_a_frac_pre2_b[13] = (~((sel_a_load0 & ex6_frac_lod_ear[13]) | (sel_a_reload0 & ex6_frac_relod_ear[13]) | (sel_a_load1 & ex7_frac_a_lod_dly[13])));
   assign ex1_a_frac_pre2_b[14] = (~((sel_a_load0 & ex6_frac_lod_ear[14]) | (sel_a_reload0 & ex6_frac_relod_ear[14]) | (sel_a_load1 & ex7_frac_a_lod_dly[14])));
   assign ex1_a_frac_pre2_b[15] = (~((sel_a_load0 & ex6_frac_lod_ear[15]) | (sel_a_reload0 & ex6_frac_relod_ear[15]) | (sel_a_load1 & ex7_frac_a_lod_dly[15])));
   assign ex1_a_frac_pre2_b[16] = (~((sel_a_load0 & ex6_frac_lod_ear[16]) | (sel_a_reload0 & ex6_frac_relod_ear[16]) | (sel_a_load1 & ex7_frac_a_lod_dly[16])));
   assign ex1_a_frac_pre2_b[17] = (~((sel_a_load0 & ex6_frac_lod_ear[17]) | (sel_a_reload0 & ex6_frac_relod_ear[17]) | (sel_a_load1 & ex7_frac_a_lod_dly[17])));
   assign ex1_a_frac_pre2_b[18] = (~((sel_a_load0 & ex6_frac_lod_ear[18]) | (sel_a_reload0 & ex6_frac_relod_ear[18]) | (sel_a_load1 & ex7_frac_a_lod_dly[18])));
   assign ex1_a_frac_pre2_b[19] = (~((sel_a_load0 & ex6_frac_lod_ear[19]) | (sel_a_reload0 & ex6_frac_relod_ear[19]) | (sel_a_load1 & ex7_frac_a_lod_dly[19])));
   assign ex1_a_frac_pre2_b[20] = (~((sel_a_load0 & ex6_frac_lod_ear[20]) | (sel_a_reload0 & ex6_frac_relod_ear[20]) | (sel_a_load1 & ex7_frac_a_lod_dly[20])));
   assign ex1_a_frac_pre2_b[21] = (~((sel_a_load0 & ex6_frac_lod_ear[21]) | (sel_a_reload0 & ex6_frac_relod_ear[21]) | (sel_a_load1 & ex7_frac_a_lod_dly[21])));
   assign ex1_a_frac_pre2_b[22] = (~((sel_a_load0 & ex6_frac_lod_ear[22]) | (sel_a_reload0 & ex6_frac_relod_ear[22]) | (sel_a_load1 & ex7_frac_a_lod_dly[22])));
   assign ex1_a_frac_pre2_b[23] = (~((sel_a_load0 & ex6_frac_lod_ear[23]) | (sel_a_reload0 & ex6_frac_relod_ear[23]) | (sel_a_load1 & ex7_frac_a_lod_dly[23])));
   assign ex1_a_frac_pre2_b[24] = (~((sel_a_load0 & ex6_frac_lod_ear[24]) | (sel_a_reload0 & ex6_frac_relod_ear[24]) | (sel_a_load1 & ex7_frac_a_lod_dly[24])));
   assign ex1_a_frac_pre2_b[25] = (~((sel_a_load0 & ex6_frac_lod_ear[25]) | (sel_a_reload0 & ex6_frac_relod_ear[25]) | (sel_a_load1 & ex7_frac_a_lod_dly[25])));
   assign ex1_a_frac_pre2_b[26] = (~((sel_a_load0 & ex6_frac_lod_ear[26]) | (sel_a_reload0 & ex6_frac_relod_ear[26]) | (sel_a_load1 & ex7_frac_a_lod_dly[26])));
   assign ex1_a_frac_pre2_b[27] = (~((sel_a_load0 & ex6_frac_lod_ear[27]) | (sel_a_reload0 & ex6_frac_relod_ear[27]) | (sel_a_load1 & ex7_frac_a_lod_dly[27])));
   assign ex1_a_frac_pre2_b[28] = (~((sel_a_load0 & ex6_frac_lod_ear[28]) | (sel_a_reload0 & ex6_frac_relod_ear[28]) | (sel_a_load1 & ex7_frac_a_lod_dly[28])));
   assign ex1_a_frac_pre2_b[29] = (~((sel_a_load0 & ex6_frac_lod_ear[29]) | (sel_a_reload0 & ex6_frac_relod_ear[29]) | (sel_a_load1 & ex7_frac_a_lod_dly[29])));
   assign ex1_a_frac_pre2_b[30] = (~((sel_a_load0 & ex6_frac_lod_ear[30]) | (sel_a_reload0 & ex6_frac_relod_ear[30]) | (sel_a_load1 & ex7_frac_a_lod_dly[30])));
   assign ex1_a_frac_pre2_b[31] = (~((sel_a_load0 & ex6_frac_lod_ear[31]) | (sel_a_reload0 & ex6_frac_relod_ear[31]) | (sel_a_load1 & ex7_frac_a_lod_dly[31])));
   assign ex1_a_frac_pre2_b[32] = (~((sel_a_load0 & ex6_frac_lod_ear[32]) | (sel_a_reload0 & ex6_frac_relod_ear[32]) | (sel_a_load1 & ex7_frac_a_lod_dly[32])));
   assign ex1_a_frac_pre2_b[33] = (~((sel_a_load0 & ex6_frac_lod_ear[33]) | (sel_a_reload0 & ex6_frac_relod_ear[33]) | (sel_a_load1 & ex7_frac_a_lod_dly[33])));
   assign ex1_a_frac_pre2_b[34] = (~((sel_a_load0 & ex6_frac_lod_ear[34]) | (sel_a_reload0 & ex6_frac_relod_ear[34]) | (sel_a_load1 & ex7_frac_a_lod_dly[34])));
   assign ex1_a_frac_pre2_b[35] = (~((sel_a_load0 & ex6_frac_lod_ear[35]) | (sel_a_reload0 & ex6_frac_relod_ear[35]) | (sel_a_load1 & ex7_frac_a_lod_dly[35])));
   assign ex1_a_frac_pre2_b[36] = (~((sel_a_load0 & ex6_frac_lod_ear[36]) | (sel_a_reload0 & ex6_frac_relod_ear[36]) | (sel_a_load1 & ex7_frac_a_lod_dly[36])));
   assign ex1_a_frac_pre2_b[37] = (~((sel_a_load0 & ex6_frac_lod_ear[37]) | (sel_a_reload0 & ex6_frac_relod_ear[37]) | (sel_a_load1 & ex7_frac_a_lod_dly[37])));
   assign ex1_a_frac_pre2_b[38] = (~((sel_a_load0 & ex6_frac_lod_ear[38]) | (sel_a_reload0 & ex6_frac_relod_ear[38]) | (sel_a_load1 & ex7_frac_a_lod_dly[38])));
   assign ex1_a_frac_pre2_b[39] = (~((sel_a_load0 & ex6_frac_lod_ear[39]) | (sel_a_reload0 & ex6_frac_relod_ear[39]) | (sel_a_load1 & ex7_frac_a_lod_dly[39])));
   assign ex1_a_frac_pre2_b[40] = (~((sel_a_load0 & ex6_frac_lod_ear[40]) | (sel_a_reload0 & ex6_frac_relod_ear[40]) | (sel_a_load1 & ex7_frac_a_lod_dly[40])));
   assign ex1_a_frac_pre2_b[41] = (~((sel_a_load0 & ex6_frac_lod_ear[41]) | (sel_a_reload0 & ex6_frac_relod_ear[41]) | (sel_a_load1 & ex7_frac_a_lod_dly[41])));
   assign ex1_a_frac_pre2_b[42] = (~((sel_a_load0 & ex6_frac_lod_ear[42]) | (sel_a_reload0 & ex6_frac_relod_ear[42]) | (sel_a_load1 & ex7_frac_a_lod_dly[42])));
   assign ex1_a_frac_pre2_b[43] = (~((sel_a_load0 & ex6_frac_lod_ear[43]) | (sel_a_reload0 & ex6_frac_relod_ear[43]) | (sel_a_load1 & ex7_frac_a_lod_dly[43])));
   assign ex1_a_frac_pre2_b[44] = (~((sel_a_load0 & ex6_frac_lod_ear[44]) | (sel_a_reload0 & ex6_frac_relod_ear[44]) | (sel_a_load1 & ex7_frac_a_lod_dly[44])));
   assign ex1_a_frac_pre2_b[45] = (~((sel_a_load0 & ex6_frac_lod_ear[45]) | (sel_a_reload0 & ex6_frac_relod_ear[45]) | (sel_a_load1 & ex7_frac_a_lod_dly[45])));
   assign ex1_a_frac_pre2_b[46] = (~((sel_a_load0 & ex6_frac_lod_ear[46]) | (sel_a_reload0 & ex6_frac_relod_ear[46]) | (sel_a_load1 & ex7_frac_a_lod_dly[46])));
   assign ex1_a_frac_pre2_b[47] = (~((sel_a_load0 & ex6_frac_lod_ear[47]) | (sel_a_reload0 & ex6_frac_relod_ear[47]) | (sel_a_load1 & ex7_frac_a_lod_dly[47])));
   assign ex1_a_frac_pre2_b[48] = (~((sel_a_load0 & ex6_frac_lod_ear[48]) | (sel_a_reload0 & ex6_frac_relod_ear[48]) | (sel_a_load1 & ex7_frac_a_lod_dly[48])));
   assign ex1_a_frac_pre2_b[49] = (~((sel_a_load0 & ex6_frac_lod_ear[49]) | (sel_a_reload0 & ex6_frac_relod_ear[49]) | (sel_a_load1 & ex7_frac_a_lod_dly[49])));
   assign ex1_a_frac_pre2_b[50] = (~((sel_a_load0 & ex6_frac_lod_ear[50]) | (sel_a_reload0 & ex6_frac_relod_ear[50]) | (sel_a_load1 & ex7_frac_a_lod_dly[50])));
   assign ex1_a_frac_pre2_b[51] = (~((sel_a_load0 & ex6_frac_lod_ear[51]) | (sel_a_reload0 & ex6_frac_relod_ear[51]) | (sel_a_load1 & ex7_frac_a_lod_dly[51])));
   assign ex1_a_frac_pre2_b[52] = (~((sel_a_load0 & ex6_frac_lod_ear[52]) | (sel_a_reload0 & ex6_frac_relod_ear[52]) | (sel_a_load1 & ex7_frac_a_lod_dly[52])));

   assign ex1_c_frac_pre2_b[0] = (~((sel_c_load0 & ex6_frac_lod_ear[0]) | (sel_c_reload0 & ex6_frac_relod_ear[0]) | (sel_c_load1 & ex7_frac_c_lod_dly[0])));
   assign ex1_c_frac_pre2_b[1] = (~((sel_c_load0 & ex6_frac_lod_ear[1]) | (sel_c_reload0 & ex6_frac_relod_ear[1]) | (sel_c_load1 & ex7_frac_c_lod_dly[1])));
   assign ex1_c_frac_pre2_b[2] = (~((sel_c_load0 & ex6_frac_lod_ear[2]) | (sel_c_reload0 & ex6_frac_relod_ear[2]) | (sel_c_load1 & ex7_frac_c_lod_dly[2])));
   assign ex1_c_frac_pre2_b[3] = (~((sel_c_load0 & ex6_frac_lod_ear[3]) | (sel_c_reload0 & ex6_frac_relod_ear[3]) | (sel_c_load1 & ex7_frac_c_lod_dly[3])));
   assign ex1_c_frac_pre2_b[4] = (~((sel_c_load0 & ex6_frac_lod_ear[4]) | (sel_c_reload0 & ex6_frac_relod_ear[4]) | (sel_c_load1 & ex7_frac_c_lod_dly[4])));
   assign ex1_c_frac_pre2_b[5] = (~((sel_c_load0 & ex6_frac_lod_ear[5]) | (sel_c_reload0 & ex6_frac_relod_ear[5]) | (sel_c_load1 & ex7_frac_c_lod_dly[5])));
   assign ex1_c_frac_pre2_b[6] = (~((sel_c_load0 & ex6_frac_lod_ear[6]) | (sel_c_reload0 & ex6_frac_relod_ear[6]) | (sel_c_load1 & ex7_frac_c_lod_dly[6])));
   assign ex1_c_frac_pre2_b[7] = (~((sel_c_load0 & ex6_frac_lod_ear[7]) | (sel_c_reload0 & ex6_frac_relod_ear[7]) | (sel_c_load1 & ex7_frac_c_lod_dly[7])));
   assign ex1_c_frac_pre2_b[8] = (~((sel_c_load0 & ex6_frac_lod_ear[8]) | (sel_c_reload0 & ex6_frac_relod_ear[8]) | (sel_c_load1 & ex7_frac_c_lod_dly[8])));
   assign ex1_c_frac_pre2_b[9] = (~((sel_c_load0 & ex6_frac_lod_ear[9]) | (sel_c_reload0 & ex6_frac_relod_ear[9]) | (sel_c_load1 & ex7_frac_c_lod_dly[9])));
   assign ex1_c_frac_pre2_b[10] = (~((sel_c_load0 & ex6_frac_lod_ear[10]) | (sel_c_reload0 & ex6_frac_relod_ear[10]) | (sel_c_load1 & ex7_frac_c_lod_dly[10])));
   assign ex1_c_frac_pre2_b[11] = (~((sel_c_load0 & ex6_frac_lod_ear[11]) | (sel_c_reload0 & ex6_frac_relod_ear[11]) | (sel_c_load1 & ex7_frac_c_lod_dly[11])));
   assign ex1_c_frac_pre2_b[12] = (~((sel_c_load0 & ex6_frac_lod_ear[12]) | (sel_c_reload0 & ex6_frac_relod_ear[12]) | (sel_c_load1 & ex7_frac_c_lod_dly[12])));
   assign ex1_c_frac_pre2_b[13] = (~((sel_c_load0 & ex6_frac_lod_ear[13]) | (sel_c_reload0 & ex6_frac_relod_ear[13]) | (sel_c_load1 & ex7_frac_c_lod_dly[13])));
   assign ex1_c_frac_pre2_b[14] = (~((sel_c_load0 & ex6_frac_lod_ear[14]) | (sel_c_reload0 & ex6_frac_relod_ear[14]) | (sel_c_load1 & ex7_frac_c_lod_dly[14])));
   assign ex1_c_frac_pre2_b[15] = (~((sel_c_load0 & ex6_frac_lod_ear[15]) | (sel_c_reload0 & ex6_frac_relod_ear[15]) | (sel_c_load1 & ex7_frac_c_lod_dly[15])));
   assign ex1_c_frac_pre2_b[16] = (~((sel_c_load0 & ex6_frac_lod_ear[16]) | (sel_c_reload0 & ex6_frac_relod_ear[16]) | (sel_c_load1 & ex7_frac_c_lod_dly[16])));
   assign ex1_c_frac_pre2_b[17] = (~((sel_c_load0 & ex6_frac_lod_ear[17]) | (sel_c_reload0 & ex6_frac_relod_ear[17]) | (sel_c_load1 & ex7_frac_c_lod_dly[17])));
   assign ex1_c_frac_pre2_b[18] = (~((sel_c_load0 & ex6_frac_lod_ear[18]) | (sel_c_reload0 & ex6_frac_relod_ear[18]) | (sel_c_load1 & ex7_frac_c_lod_dly[18])));
   assign ex1_c_frac_pre2_b[19] = (~((sel_c_load0 & ex6_frac_lod_ear[19]) | (sel_c_reload0 & ex6_frac_relod_ear[19]) | (sel_c_load1 & ex7_frac_c_lod_dly[19])));
   assign ex1_c_frac_pre2_b[20] = (~((sel_c_load0 & ex6_frac_lod_ear[20]) | (sel_c_reload0 & ex6_frac_relod_ear[20]) | (sel_c_load1 & ex7_frac_c_lod_dly[20])));
   assign ex1_c_frac_pre2_b[21] = (~((sel_c_load0 & ex6_frac_lod_ear[21]) | (sel_c_reload0 & ex6_frac_relod_ear[21]) | (sel_c_load1 & ex7_frac_c_lod_dly[21])));
   assign ex1_c_frac_pre2_b[22] = (~((sel_c_load0 & ex6_frac_lod_ear[22]) | (sel_c_reload0 & ex6_frac_relod_ear[22]) | (sel_c_load1 & ex7_frac_c_lod_dly[22])));
   assign ex1_c_frac_pre2_b[23] = (~((sel_c_load0 & ex6_frac_lod_ear[23]) | (sel_c_reload0 & ex6_frac_relod_ear[23]) | (sel_c_load1 & ex7_frac_c_lod_dly[23])));
   assign ex1_c_frac_pre2_b[24] = (~((sel_c_load0 & ex6_frac_lod_ear[24]) | (sel_c_reload0 & ex6_frac_relod_ear[24]) | (sel_c_load1 & ex7_frac_c_lod_dly[24])));
   assign ex1_c_frac_pre2_b[25] = (~((sel_c_load0 & ex6_frac_lod_ear[25]) | (sel_c_reload0 & ex6_frac_relod_ear[25]) | (sel_c_load1 & ex7_frac_c_lod_dly[25])));
   assign ex1_c_frac_pre2_b[26] = (~((sel_c_load0 & ex6_frac_lod_ear[26]) | (sel_c_reload0 & ex6_frac_relod_ear[26]) | (sel_c_load1 & ex7_frac_c_lod_dly[26])));
   assign ex1_c_frac_pre2_b[27] = (~((sel_c_load0 & ex6_frac_lod_ear[27]) | (sel_c_reload0 & ex6_frac_relod_ear[27]) | (sel_c_load1 & ex7_frac_c_lod_dly[27])));
   assign ex1_c_frac_pre2_b[28] = (~((sel_c_load0 & ex6_frac_lod_ear[28]) | (sel_c_reload0 & ex6_frac_relod_ear[28]) | (sel_c_load1 & ex7_frac_c_lod_dly[28])));
   assign ex1_c_frac_pre2_b[29] = (~((sel_c_load0 & ex6_frac_lod_ear[29]) | (sel_c_reload0 & ex6_frac_relod_ear[29]) | (sel_c_load1 & ex7_frac_c_lod_dly[29])));
   assign ex1_c_frac_pre2_b[30] = (~((sel_c_load0 & ex6_frac_lod_ear[30]) | (sel_c_reload0 & ex6_frac_relod_ear[30]) | (sel_c_load1 & ex7_frac_c_lod_dly[30])));
   assign ex1_c_frac_pre2_b[31] = (~((sel_c_load0 & ex6_frac_lod_ear[31]) | (sel_c_reload0 & ex6_frac_relod_ear[31]) | (sel_c_load1 & ex7_frac_c_lod_dly[31])));
   assign ex1_c_frac_pre2_b[32] = (~((sel_c_load0 & ex6_frac_lod_ear[32]) | (sel_c_reload0 & ex6_frac_relod_ear[32]) | (sel_c_load1 & ex7_frac_c_lod_dly[32])));
   assign ex1_c_frac_pre2_b[33] = (~((sel_c_load0 & ex6_frac_lod_ear[33]) | (sel_c_reload0 & ex6_frac_relod_ear[33]) | (sel_c_load1 & ex7_frac_c_lod_dly[33])));
   assign ex1_c_frac_pre2_b[34] = (~((sel_c_load0 & ex6_frac_lod_ear[34]) | (sel_c_reload0 & ex6_frac_relod_ear[34]) | (sel_c_load1 & ex7_frac_c_lod_dly[34])));
   assign ex1_c_frac_pre2_b[35] = (~((sel_c_load0 & ex6_frac_lod_ear[35]) | (sel_c_reload0 & ex6_frac_relod_ear[35]) | (sel_c_load1 & ex7_frac_c_lod_dly[35])));
   assign ex1_c_frac_pre2_b[36] = (~((sel_c_load0 & ex6_frac_lod_ear[36]) | (sel_c_reload0 & ex6_frac_relod_ear[36]) | (sel_c_load1 & ex7_frac_c_lod_dly[36])));
   assign ex1_c_frac_pre2_b[37] = (~((sel_c_load0 & ex6_frac_lod_ear[37]) | (sel_c_reload0 & ex6_frac_relod_ear[37]) | (sel_c_load1 & ex7_frac_c_lod_dly[37])));
   assign ex1_c_frac_pre2_b[38] = (~((sel_c_load0 & ex6_frac_lod_ear[38]) | (sel_c_reload0 & ex6_frac_relod_ear[38]) | (sel_c_load1 & ex7_frac_c_lod_dly[38])));
   assign ex1_c_frac_pre2_b[39] = (~((sel_c_load0 & ex6_frac_lod_ear[39]) | (sel_c_reload0 & ex6_frac_relod_ear[39]) | (sel_c_load1 & ex7_frac_c_lod_dly[39])));
   assign ex1_c_frac_pre2_b[40] = (~((sel_c_load0 & ex6_frac_lod_ear[40]) | (sel_c_reload0 & ex6_frac_relod_ear[40]) | (sel_c_load1 & ex7_frac_c_lod_dly[40])));
   assign ex1_c_frac_pre2_b[41] = (~((sel_c_load0 & ex6_frac_lod_ear[41]) | (sel_c_reload0 & ex6_frac_relod_ear[41]) | (sel_c_load1 & ex7_frac_c_lod_dly[41])));
   assign ex1_c_frac_pre2_b[42] = (~((sel_c_load0 & ex6_frac_lod_ear[42]) | (sel_c_reload0 & ex6_frac_relod_ear[42]) | (sel_c_load1 & ex7_frac_c_lod_dly[42])));
   assign ex1_c_frac_pre2_b[43] = (~((sel_c_load0 & ex6_frac_lod_ear[43]) | (sel_c_reload0 & ex6_frac_relod_ear[43]) | (sel_c_load1 & ex7_frac_c_lod_dly[43])));
   assign ex1_c_frac_pre2_b[44] = (~((sel_c_load0 & ex6_frac_lod_ear[44]) | (sel_c_reload0 & ex6_frac_relod_ear[44]) | (sel_c_load1 & ex7_frac_c_lod_dly[44])));
   assign ex1_c_frac_pre2_b[45] = (~((sel_c_load0 & ex6_frac_lod_ear[45]) | (sel_c_reload0 & ex6_frac_relod_ear[45]) | (sel_c_load1 & ex7_frac_c_lod_dly[45])));
   assign ex1_c_frac_pre2_b[46] = (~((sel_c_load0 & ex6_frac_lod_ear[46]) | (sel_c_reload0 & ex6_frac_relod_ear[46]) | (sel_c_load1 & ex7_frac_c_lod_dly[46])));
   assign ex1_c_frac_pre2_b[47] = (~((sel_c_load0 & ex6_frac_lod_ear[47]) | (sel_c_reload0 & ex6_frac_relod_ear[47]) | (sel_c_load1 & ex7_frac_c_lod_dly[47])));
   assign ex1_c_frac_pre2_b[48] = (~((sel_c_load0 & ex6_frac_lod_ear[48]) | (sel_c_reload0 & ex6_frac_relod_ear[48]) | (sel_c_load1 & ex7_frac_c_lod_dly[48])));
   assign ex1_c_frac_pre2_b[49] = (~((sel_c_load0 & ex6_frac_lod_ear[49]) | (sel_c_reload0 & ex6_frac_relod_ear[49]) | (sel_c_load1 & ex7_frac_c_lod_dly[49])));
   assign ex1_c_frac_pre2_b[50] = (~((sel_c_load0 & ex6_frac_lod_ear[50]) | (sel_c_reload0 & ex6_frac_relod_ear[50]) | (sel_c_load1 & ex7_frac_c_lod_dly[50])));
   assign ex1_c_frac_pre2_b[51] = (~((sel_c_load0 & ex6_frac_lod_ear[51]) | (sel_c_reload0 & ex6_frac_relod_ear[51]) | (sel_c_load1 & ex7_frac_c_lod_dly[51])));
   assign ex1_c_frac_pre2_b[52] = (~((sel_c_load0 & ex6_frac_lod_ear[52]) | (sel_c_reload0 & ex6_frac_relod_ear[52]) | (sel_c_load1 & ex7_frac_c_lod_dly[52])));

   assign ex1_b_frac_pre2_b[0] = (~((sel_b_load0 & ex6_frac_lod_ear[0]) |  (sel_b_reload0 & ex6_frac_relod_ear[0]) |  (sel_b_load1 & ex7_frac_b_lod_dly[0])));
   assign ex1_b_frac_pre2_b[1] = (~((sel_b_load0 & ex6_frac_lod_ear[1]) |  (sel_b_reload0 & ex6_frac_relod_ear[1]) |  (sel_b_load1 & ex7_frac_b_lod_dly[1])));
   assign ex1_b_frac_pre2_b[2] = (~((sel_b_load0 & ex6_frac_lod_ear[2]) |  (sel_b_reload0 & ex6_frac_relod_ear[2]) |  (sel_b_load1 & ex7_frac_b_lod_dly[2])));
   assign ex1_b_frac_pre2_b[3] = (~((sel_b_load0 & ex6_frac_lod_ear[3]) |  (sel_b_reload0 & ex6_frac_relod_ear[3]) |  (sel_b_load1 & ex7_frac_b_lod_dly[3])));
   assign ex1_b_frac_pre2_b[4] = (~((sel_b_load0 & ex6_frac_lod_ear[4]) |  (sel_b_reload0 & ex6_frac_relod_ear[4]) |  (sel_b_load1 & ex7_frac_b_lod_dly[4])));
   assign ex1_b_frac_pre2_b[5] = (~((sel_b_load0 & ex6_frac_lod_ear[5]) |  (sel_b_reload0 & ex6_frac_relod_ear[5]) |  (sel_b_load1 & ex7_frac_b_lod_dly[5])));
   assign ex1_b_frac_pre2_b[6] = (~((sel_b_load0 & ex6_frac_lod_ear[6]) |  (sel_b_reload0 & ex6_frac_relod_ear[6]) |  (sel_b_load1 & ex7_frac_b_lod_dly[6])));
   assign ex1_b_frac_pre2_b[7] = (~((sel_b_load0 & ex6_frac_lod_ear[7]) |  (sel_b_reload0 & ex6_frac_relod_ear[7]) |  (sel_b_load1 & ex7_frac_b_lod_dly[7])));
   assign ex1_b_frac_pre2_b[8] = (~((sel_b_load0 & ex6_frac_lod_ear[8]) |  (sel_b_reload0 & ex6_frac_relod_ear[8]) |  (sel_b_load1 & ex7_frac_b_lod_dly[8])));
   assign ex1_b_frac_pre2_b[9] = (~((sel_b_load0 & ex6_frac_lod_ear[9]) |  (sel_b_reload0 & ex6_frac_relod_ear[9]) |  (sel_b_load1 & ex7_frac_b_lod_dly[9])));
   assign ex1_b_frac_pre2_b[10] = (~((sel_b_load0 & ex6_frac_lod_ear[10]) | (sel_b_reload0 & ex6_frac_relod_ear[10]) | (sel_b_load1 & ex7_frac_b_lod_dly[10])));
   assign ex1_b_frac_pre2_b[11] = (~((sel_b_load0 & ex6_frac_lod_ear[11]) | (sel_b_reload0 & ex6_frac_relod_ear[11]) | (sel_b_load1 & ex7_frac_b_lod_dly[11])));
   assign ex1_b_frac_pre2_b[12] = (~((sel_b_load0 & ex6_frac_lod_ear[12]) | (sel_b_reload0 & ex6_frac_relod_ear[12]) | (sel_b_load1 & ex7_frac_b_lod_dly[12])));
   assign ex1_b_frac_pre2_b[13] = (~((sel_b_load0 & ex6_frac_lod_ear[13]) | (sel_b_reload0 & ex6_frac_relod_ear[13]) | (sel_b_load1 & ex7_frac_b_lod_dly[13])));
   assign ex1_b_frac_pre2_b[14] = (~((sel_b_load0 & ex6_frac_lod_ear[14]) | (sel_b_reload0 & ex6_frac_relod_ear[14]) | (sel_b_load1 & ex7_frac_b_lod_dly[14])));
   assign ex1_b_frac_pre2_b[15] = (~((sel_b_load0 & ex6_frac_lod_ear[15]) | (sel_b_reload0 & ex6_frac_relod_ear[15]) | (sel_b_load1 & ex7_frac_b_lod_dly[15])));
   assign ex1_b_frac_pre2_b[16] = (~((sel_b_load0 & ex6_frac_lod_ear[16]) | (sel_b_reload0 & ex6_frac_relod_ear[16]) | (sel_b_load1 & ex7_frac_b_lod_dly[16])));
   assign ex1_b_frac_pre2_b[17] = (~((sel_b_load0 & ex6_frac_lod_ear[17]) | (sel_b_reload0 & ex6_frac_relod_ear[17]) | (sel_b_load1 & ex7_frac_b_lod_dly[17])));
   assign ex1_b_frac_pre2_b[18] = (~((sel_b_load0 & ex6_frac_lod_ear[18]) | (sel_b_reload0 & ex6_frac_relod_ear[18]) | (sel_b_load1 & ex7_frac_b_lod_dly[18])));
   assign ex1_b_frac_pre2_b[19] = (~((sel_b_load0 & ex6_frac_lod_ear[19]) | (sel_b_reload0 & ex6_frac_relod_ear[19]) | (sel_b_load1 & ex7_frac_b_lod_dly[19])));
   assign ex1_b_frac_pre2_b[20] = (~((sel_b_load0 & ex6_frac_lod_ear[20]) | (sel_b_reload0 & ex6_frac_relod_ear[20]) | (sel_b_load1 & ex7_frac_b_lod_dly[20])));
   assign ex1_b_frac_pre2_b[21] = (~((sel_b_load0 & ex6_frac_lod_ear[21]) | (sel_b_reload0 & ex6_frac_relod_ear[21]) | (sel_b_load1 & ex7_frac_b_lod_dly[21])));
   assign ex1_b_frac_pre2_b[22] = (~((sel_b_load0 & ex6_frac_lod_ear[22]) | (sel_b_reload0 & ex6_frac_relod_ear[22]) | (sel_b_load1 & ex7_frac_b_lod_dly[22])));
   assign ex1_b_frac_pre2_b[23] = (~((sel_b_load0 & ex6_frac_lod_ear[23]) | (sel_b_reload0 & ex6_frac_relod_ear[23]) | (sel_b_load1 & ex7_frac_b_lod_dly[23])));
   assign ex1_b_frac_pre2_b[24] = (~((sel_b_load0 & ex6_frac_lod_ear[24]) | (sel_b_reload0 & ex6_frac_relod_ear[24]) | (sel_b_load1 & ex7_frac_b_lod_dly[24])));
   assign ex1_b_frac_pre2_b[25] = (~((sel_b_load0 & ex6_frac_lod_ear[25]) | (sel_b_reload0 & ex6_frac_relod_ear[25]) | (sel_b_load1 & ex7_frac_b_lod_dly[25])));
   assign ex1_b_frac_pre2_b[26] = (~((sel_b_load0 & ex6_frac_lod_ear[26]) | (sel_b_reload0 & ex6_frac_relod_ear[26]) | (sel_b_load1 & ex7_frac_b_lod_dly[26])));
   assign ex1_b_frac_pre2_b[27] = (~((sel_b_load0 & ex6_frac_lod_ear[27]) | (sel_b_reload0 & ex6_frac_relod_ear[27]) | (sel_b_load1 & ex7_frac_b_lod_dly[27])));
   assign ex1_b_frac_pre2_b[28] = (~((sel_b_load0 & ex6_frac_lod_ear[28]) | (sel_b_reload0 & ex6_frac_relod_ear[28]) | (sel_b_load1 & ex7_frac_b_lod_dly[28])));
   assign ex1_b_frac_pre2_b[29] = (~((sel_b_load0 & ex6_frac_lod_ear[29]) | (sel_b_reload0 & ex6_frac_relod_ear[29]) | (sel_b_load1 & ex7_frac_b_lod_dly[29])));
   assign ex1_b_frac_pre2_b[30] = (~((sel_b_load0 & ex6_frac_lod_ear[30]) | (sel_b_reload0 & ex6_frac_relod_ear[30]) | (sel_b_load1 & ex7_frac_b_lod_dly[30])));
   assign ex1_b_frac_pre2_b[31] = (~((sel_b_load0 & ex6_frac_lod_ear[31]) | (sel_b_reload0 & ex6_frac_relod_ear[31]) | (sel_b_load1 & ex7_frac_b_lod_dly[31])));
   assign ex1_b_frac_pre2_b[32] = (~((sel_b_load0 & ex6_frac_lod_ear[32]) | (sel_b_reload0 & ex6_frac_relod_ear[32]) | (sel_b_load1 & ex7_frac_b_lod_dly[32])));
   assign ex1_b_frac_pre2_b[33] = (~((sel_b_load0 & ex6_frac_lod_ear[33]) | (sel_b_reload0 & ex6_frac_relod_ear[33]) | (sel_b_load1 & ex7_frac_b_lod_dly[33])));
   assign ex1_b_frac_pre2_b[34] = (~((sel_b_load0 & ex6_frac_lod_ear[34]) | (sel_b_reload0 & ex6_frac_relod_ear[34]) | (sel_b_load1 & ex7_frac_b_lod_dly[34])));
   assign ex1_b_frac_pre2_b[35] = (~((sel_b_load0 & ex6_frac_lod_ear[35]) | (sel_b_reload0 & ex6_frac_relod_ear[35]) | (sel_b_load1 & ex7_frac_b_lod_dly[35])));
   assign ex1_b_frac_pre2_b[36] = (~((sel_b_load0 & ex6_frac_lod_ear[36]) | (sel_b_reload0 & ex6_frac_relod_ear[36]) | (sel_b_load1 & ex7_frac_b_lod_dly[36])));
   assign ex1_b_frac_pre2_b[37] = (~((sel_b_load0 & ex6_frac_lod_ear[37]) | (sel_b_reload0 & ex6_frac_relod_ear[37]) | (sel_b_load1 & ex7_frac_b_lod_dly[37])));
   assign ex1_b_frac_pre2_b[38] = (~((sel_b_load0 & ex6_frac_lod_ear[38]) | (sel_b_reload0 & ex6_frac_relod_ear[38]) | (sel_b_load1 & ex7_frac_b_lod_dly[38])));
   assign ex1_b_frac_pre2_b[39] = (~((sel_b_load0 & ex6_frac_lod_ear[39]) | (sel_b_reload0 & ex6_frac_relod_ear[39]) | (sel_b_load1 & ex7_frac_b_lod_dly[39])));
   assign ex1_b_frac_pre2_b[40] = (~((sel_b_load0 & ex6_frac_lod_ear[40]) | (sel_b_reload0 & ex6_frac_relod_ear[40]) | (sel_b_load1 & ex7_frac_b_lod_dly[40])));
   assign ex1_b_frac_pre2_b[41] = (~((sel_b_load0 & ex6_frac_lod_ear[41]) | (sel_b_reload0 & ex6_frac_relod_ear[41]) | (sel_b_load1 & ex7_frac_b_lod_dly[41])));
   assign ex1_b_frac_pre2_b[42] = (~((sel_b_load0 & ex6_frac_lod_ear[42]) | (sel_b_reload0 & ex6_frac_relod_ear[42]) | (sel_b_load1 & ex7_frac_b_lod_dly[42])));
   assign ex1_b_frac_pre2_b[43] = (~((sel_b_load0 & ex6_frac_lod_ear[43]) | (sel_b_reload0 & ex6_frac_relod_ear[43]) | (sel_b_load1 & ex7_frac_b_lod_dly[43])));
   assign ex1_b_frac_pre2_b[44] = (~((sel_b_load0 & ex6_frac_lod_ear[44]) | (sel_b_reload0 & ex6_frac_relod_ear[44]) | (sel_b_load1 & ex7_frac_b_lod_dly[44])));
   assign ex1_b_frac_pre2_b[45] = (~((sel_b_load0 & ex6_frac_lod_ear[45]) | (sel_b_reload0 & ex6_frac_relod_ear[45]) | (sel_b_load1 & ex7_frac_b_lod_dly[45])));
   assign ex1_b_frac_pre2_b[46] = (~((sel_b_load0 & ex6_frac_lod_ear[46]) | (sel_b_reload0 & ex6_frac_relod_ear[46]) | (sel_b_load1 & ex7_frac_b_lod_dly[46])));
   assign ex1_b_frac_pre2_b[47] = (~((sel_b_load0 & ex6_frac_lod_ear[47]) | (sel_b_reload0 & ex6_frac_relod_ear[47]) | (sel_b_load1 & ex7_frac_b_lod_dly[47])));
   assign ex1_b_frac_pre2_b[48] = (~((sel_b_load0 & ex6_frac_lod_ear[48]) | (sel_b_reload0 & ex6_frac_relod_ear[48]) | (sel_b_load1 & ex7_frac_b_lod_dly[48])));
   assign ex1_b_frac_pre2_b[49] = (~((sel_b_load0 & ex6_frac_lod_ear[49]) | (sel_b_reload0 & ex6_frac_relod_ear[49]) | (sel_b_load1 & ex7_frac_b_lod_dly[49])));
   assign ex1_b_frac_pre2_b[50] = (~((sel_b_load0 & ex6_frac_lod_ear[50]) | (sel_b_reload0 & ex6_frac_relod_ear[50]) | (sel_b_load1 & ex7_frac_b_lod_dly[50])));
   assign ex1_b_frac_pre2_b[51] = (~((sel_b_load0 & ex6_frac_lod_ear[51]) | (sel_b_reload0 & ex6_frac_relod_ear[51]) | (sel_b_load1 & ex7_frac_b_lod_dly[51])));
   assign ex1_b_frac_pre2_b[52] = (~((sel_b_load0 & ex6_frac_lod_ear[52]) | (sel_b_reload0 & ex6_frac_relod_ear[52]) | (sel_b_load1 & ex7_frac_b_lod_dly[52])));

   assign ex1_s_frac_pre2_b[0]  = (~((sel_s_load0 & ex6_frac_lod_ear[0]) | (sel_s_reload0 & ex6_frac_relod_ear[0])  | (sel_s_load1 & ex7_frac_s_lod_dly[0])));
   assign ex1_s_frac_pre2_b[1]  = (~((sel_s_load0 & ex6_frac_lod_ear[1]) | (sel_s_reload0 & ex6_frac_relod_ear[1])  | (sel_s_load1 & ex7_frac_s_lod_dly[1])));
   assign ex1_s_frac_pre2_b[2]  = (~((sel_s_load0 & ex6_frac_lod_ear[2]) | (sel_s_reload0 & ex6_frac_relod_ear[2])  | (sel_s_load1 & ex7_frac_s_lod_dly[2])));
   assign ex1_s_frac_pre2_b[3]  = (~((sel_s_load0 & ex6_frac_lod_ear[3]) | (sel_s_reload0 & ex6_frac_relod_ear[3])  | (sel_s_load1 & ex7_frac_s_lod_dly[3])));
   assign ex1_s_frac_pre2_b[4]  = (~((sel_s_load0 & ex6_frac_lod_ear[4]) | (sel_s_reload0 & ex6_frac_relod_ear[4])  | (sel_s_load1 & ex7_frac_s_lod_dly[4])));
   assign ex1_s_frac_pre2_b[5]  = (~((sel_s_load0 & ex6_frac_lod_ear[5]) | (sel_s_reload0 & ex6_frac_relod_ear[5])  | (sel_s_load1 & ex7_frac_s_lod_dly[5])));
   assign ex1_s_frac_pre2_b[6]  = (~((sel_s_load0 & ex6_frac_lod_ear[6]) | (sel_s_reload0 & ex6_frac_relod_ear[6])  | (sel_s_load1 & ex7_frac_s_lod_dly[6])));
   assign ex1_s_frac_pre2_b[7]  = (~((sel_s_load0 & ex6_frac_lod_ear[7]) | (sel_s_reload0 & ex6_frac_relod_ear[7])  | (sel_s_load1 & ex7_frac_s_lod_dly[7])));
   assign ex1_s_frac_pre2_b[8]  = (~((sel_s_load0 & ex6_frac_lod_ear[8]) | (sel_s_reload0 & ex6_frac_relod_ear[8])  | (sel_s_load1 & ex7_frac_s_lod_dly[8])));
   assign ex1_s_frac_pre2_b[9]  = (~((sel_s_load0 & ex6_frac_lod_ear[9]) | (sel_s_reload0 & ex6_frac_relod_ear[9])  | (sel_s_load1 & ex7_frac_s_lod_dly[9])));
   assign ex1_s_frac_pre2_b[10] = (~((sel_s_load0 & ex6_frac_lod_ear[10]) | (sel_s_reload0 & ex6_frac_relod_ear[10]) | (sel_s_load1 & ex7_frac_s_lod_dly[10])));
   assign ex1_s_frac_pre2_b[11] = (~((sel_s_load0 & ex6_frac_lod_ear[11]) | (sel_s_reload0 & ex6_frac_relod_ear[11]) | (sel_s_load1 & ex7_frac_s_lod_dly[11])));
   assign ex1_s_frac_pre2_b[12] = (~((sel_s_load0 & ex6_frac_lod_ear[12]) | (sel_s_reload0 & ex6_frac_relod_ear[12]) | (sel_s_load1 & ex7_frac_s_lod_dly[12])));
   assign ex1_s_frac_pre2_b[13] = (~((sel_s_load0 & ex6_frac_lod_ear[13]) | (sel_s_reload0 & ex6_frac_relod_ear[13]) | (sel_s_load1 & ex7_frac_s_lod_dly[13])));
   assign ex1_s_frac_pre2_b[14] = (~((sel_s_load0 & ex6_frac_lod_ear[14]) | (sel_s_reload0 & ex6_frac_relod_ear[14]) | (sel_s_load1 & ex7_frac_s_lod_dly[14])));
   assign ex1_s_frac_pre2_b[15] = (~((sel_s_load0 & ex6_frac_lod_ear[15]) | (sel_s_reload0 & ex6_frac_relod_ear[15]) | (sel_s_load1 & ex7_frac_s_lod_dly[15])));
   assign ex1_s_frac_pre2_b[16] = (~((sel_s_load0 & ex6_frac_lod_ear[16]) | (sel_s_reload0 & ex6_frac_relod_ear[16]) | (sel_s_load1 & ex7_frac_s_lod_dly[16])));
   assign ex1_s_frac_pre2_b[17] = (~((sel_s_load0 & ex6_frac_lod_ear[17]) | (sel_s_reload0 & ex6_frac_relod_ear[17]) | (sel_s_load1 & ex7_frac_s_lod_dly[17])));
   assign ex1_s_frac_pre2_b[18] = (~((sel_s_load0 & ex6_frac_lod_ear[18]) | (sel_s_reload0 & ex6_frac_relod_ear[18]) | (sel_s_load1 & ex7_frac_s_lod_dly[18])));
   assign ex1_s_frac_pre2_b[19] = (~((sel_s_load0 & ex6_frac_lod_ear[19]) | (sel_s_reload0 & ex6_frac_relod_ear[19]) | (sel_s_load1 & ex7_frac_s_lod_dly[19])));
   assign ex1_s_frac_pre2_b[20] = (~((sel_s_load0 & ex6_frac_lod_ear[20]) | (sel_s_reload0 & ex6_frac_relod_ear[20]) | (sel_s_load1 & ex7_frac_s_lod_dly[20])));
   assign ex1_s_frac_pre2_b[21] = (~((sel_s_load0 & ex6_frac_lod_ear[21]) | (sel_s_reload0 & ex6_frac_relod_ear[21]) | (sel_s_load1 & ex7_frac_s_lod_dly[21])));
   assign ex1_s_frac_pre2_b[22] = (~((sel_s_load0 & ex6_frac_lod_ear[22]) | (sel_s_reload0 & ex6_frac_relod_ear[22]) | (sel_s_load1 & ex7_frac_s_lod_dly[22])));
   assign ex1_s_frac_pre2_b[23] = (~((sel_s_load0 & ex6_frac_lod_ear[23]) | (sel_s_reload0 & ex6_frac_relod_ear[23]) | (sel_s_load1 & ex7_frac_s_lod_dly[23])));
   assign ex1_s_frac_pre2_b[24] = (~((sel_s_load0 & ex6_frac_lod_ear[24]) | (sel_s_reload0 & ex6_frac_relod_ear[24]) | (sel_s_load1 & ex7_frac_s_lod_dly[24])));
   assign ex1_s_frac_pre2_b[25] = (~((sel_s_load0 & ex6_frac_lod_ear[25]) | (sel_s_reload0 & ex6_frac_relod_ear[25]) | (sel_s_load1 & ex7_frac_s_lod_dly[25])));
   assign ex1_s_frac_pre2_b[26] = (~((sel_s_load0 & ex6_frac_lod_ear[26]) | (sel_s_reload0 & ex6_frac_relod_ear[26]) | (sel_s_load1 & ex7_frac_s_lod_dly[26])));
   assign ex1_s_frac_pre2_b[27] = (~((sel_s_load0 & ex6_frac_lod_ear[27]) | (sel_s_reload0 & ex6_frac_relod_ear[27]) | (sel_s_load1 & ex7_frac_s_lod_dly[27])));
   assign ex1_s_frac_pre2_b[28] = (~((sel_s_load0 & ex6_frac_lod_ear[28]) | (sel_s_reload0 & ex6_frac_relod_ear[28]) | (sel_s_load1 & ex7_frac_s_lod_dly[28])));
   assign ex1_s_frac_pre2_b[29] = (~((sel_s_load0 & ex6_frac_lod_ear[29]) | (sel_s_reload0 & ex6_frac_relod_ear[29]) | (sel_s_load1 & ex7_frac_s_lod_dly[29])));
   assign ex1_s_frac_pre2_b[30] = (~((sel_s_load0 & ex6_frac_lod_ear[30]) | (sel_s_reload0 & ex6_frac_relod_ear[30]) | (sel_s_load1 & ex7_frac_s_lod_dly[30])));
   assign ex1_s_frac_pre2_b[31] = (~((sel_s_load0 & ex6_frac_lod_ear[31]) | (sel_s_reload0 & ex6_frac_relod_ear[31]) | (sel_s_load1 & ex7_frac_s_lod_dly[31])));
   assign ex1_s_frac_pre2_b[32] = (~((sel_s_load0 & ex6_frac_lod_ear[32]) | (sel_s_reload0 & ex6_frac_relod_ear[32]) | (sel_s_load1 & ex7_frac_s_lod_dly[32])));
   assign ex1_s_frac_pre2_b[33] = (~((sel_s_load0 & ex6_frac_lod_ear[33]) | (sel_s_reload0 & ex6_frac_relod_ear[33]) | (sel_s_load1 & ex7_frac_s_lod_dly[33])));
   assign ex1_s_frac_pre2_b[34] = (~((sel_s_load0 & ex6_frac_lod_ear[34]) | (sel_s_reload0 & ex6_frac_relod_ear[34]) | (sel_s_load1 & ex7_frac_s_lod_dly[34])));
   assign ex1_s_frac_pre2_b[35] = (~((sel_s_load0 & ex6_frac_lod_ear[35]) | (sel_s_reload0 & ex6_frac_relod_ear[35]) | (sel_s_load1 & ex7_frac_s_lod_dly[35])));
   assign ex1_s_frac_pre2_b[36] = (~((sel_s_load0 & ex6_frac_lod_ear[36]) | (sel_s_reload0 & ex6_frac_relod_ear[36]) | (sel_s_load1 & ex7_frac_s_lod_dly[36])));
   assign ex1_s_frac_pre2_b[37] = (~((sel_s_load0 & ex6_frac_lod_ear[37]) | (sel_s_reload0 & ex6_frac_relod_ear[37]) | (sel_s_load1 & ex7_frac_s_lod_dly[37])));
   assign ex1_s_frac_pre2_b[38] = (~((sel_s_load0 & ex6_frac_lod_ear[38]) | (sel_s_reload0 & ex6_frac_relod_ear[38]) | (sel_s_load1 & ex7_frac_s_lod_dly[38])));
   assign ex1_s_frac_pre2_b[39] = (~((sel_s_load0 & ex6_frac_lod_ear[39]) | (sel_s_reload0 & ex6_frac_relod_ear[39]) | (sel_s_load1 & ex7_frac_s_lod_dly[39])));
   assign ex1_s_frac_pre2_b[40] = (~((sel_s_load0 & ex6_frac_lod_ear[40]) | (sel_s_reload0 & ex6_frac_relod_ear[40]) | (sel_s_load1 & ex7_frac_s_lod_dly[40])));
   assign ex1_s_frac_pre2_b[41] = (~((sel_s_load0 & ex6_frac_lod_ear[41]) | (sel_s_reload0 & ex6_frac_relod_ear[41]) | (sel_s_load1 & ex7_frac_s_lod_dly[41])));
   assign ex1_s_frac_pre2_b[42] = (~((sel_s_load0 & ex6_frac_lod_ear[42]) | (sel_s_reload0 & ex6_frac_relod_ear[42]) | (sel_s_load1 & ex7_frac_s_lod_dly[42])));
   assign ex1_s_frac_pre2_b[43] = (~((sel_s_load0 & ex6_frac_lod_ear[43]) | (sel_s_reload0 & ex6_frac_relod_ear[43]) | (sel_s_load1 & ex7_frac_s_lod_dly[43])));
   assign ex1_s_frac_pre2_b[44] = (~((sel_s_load0 & ex6_frac_lod_ear[44]) | (sel_s_reload0 & ex6_frac_relod_ear[44]) | (sel_s_load1 & ex7_frac_s_lod_dly[44])));
   assign ex1_s_frac_pre2_b[45] = (~((sel_s_load0 & ex6_frac_lod_ear[45]) | (sel_s_reload0 & ex6_frac_relod_ear[45]) | (sel_s_load1 & ex7_frac_s_lod_dly[45])));
   assign ex1_s_frac_pre2_b[46] = (~((sel_s_load0 & ex6_frac_lod_ear[46]) | (sel_s_reload0 & ex6_frac_relod_ear[46]) | (sel_s_load1 & ex7_frac_s_lod_dly[46])));
   assign ex1_s_frac_pre2_b[47] = (~((sel_s_load0 & ex6_frac_lod_ear[47]) | (sel_s_reload0 & ex6_frac_relod_ear[47]) | (sel_s_load1 & ex7_frac_s_lod_dly[47])));
   assign ex1_s_frac_pre2_b[48] = (~((sel_s_load0 & ex6_frac_lod_ear[48]) | (sel_s_reload0 & ex6_frac_relod_ear[48]) | (sel_s_load1 & ex7_frac_s_lod_dly[48])));
   assign ex1_s_frac_pre2_b[49] = (~((sel_s_load0 & ex6_frac_lod_ear[49]) | (sel_s_reload0 & ex6_frac_relod_ear[49]) | (sel_s_load1 & ex7_frac_s_lod_dly[49])));
   assign ex1_s_frac_pre2_b[50] = (~((sel_s_load0 & ex6_frac_lod_ear[50]) | (sel_s_reload0 & ex6_frac_relod_ear[50]) | (sel_s_load1 & ex7_frac_s_lod_dly[50])));
   assign ex1_s_frac_pre2_b[51] = (~((sel_s_load0 & ex6_frac_lod_ear[51]) | (sel_s_reload0 & ex6_frac_relod_ear[51]) | (sel_s_load1 & ex7_frac_s_lod_dly[51])));
   assign ex1_s_frac_pre2_b[52] = (~((sel_s_load0 & ex6_frac_lod_ear[52]) | (sel_s_reload0 & ex6_frac_relod_ear[52]) | (sel_s_load1 & ex7_frac_s_lod_dly[52])));

   assign ex1_a_frac_pre[0] = (~(ex1_a_frac_pre1_b[0] & ex1_a_frac_pre2_b[0]));		//and ex1_a_frac_pre3_b( 0)
   assign ex1_a_frac_pre[1] = (~(ex1_a_frac_pre1_b[1] & ex1_a_frac_pre2_b[1]));		//and ex1_a_frac_pre3_b( 1)
   assign ex1_a_frac_pre[2] = (~(ex1_a_frac_pre1_b[2] & ex1_a_frac_pre2_b[2]));		//and ex1_a_frac_pre3_b( 2)
   assign ex1_a_frac_pre[3] = (~(ex1_a_frac_pre1_b[3] & ex1_a_frac_pre2_b[3]));		//and ex1_a_frac_pre3_b( 3)
   assign ex1_a_frac_pre[4] = (~(ex1_a_frac_pre1_b[4] & ex1_a_frac_pre2_b[4]));		//and ex1_a_frac_pre3_b( 4)
   assign ex1_a_frac_pre[5] = (~(ex1_a_frac_pre1_b[5] & ex1_a_frac_pre2_b[5]));		//and ex1_a_frac_pre3_b( 5)
   assign ex1_a_frac_pre[6] = (~(ex1_a_frac_pre1_b[6] & ex1_a_frac_pre2_b[6]));		//and ex1_a_frac_pre3_b( 6)
   assign ex1_a_frac_pre[7] = (~(ex1_a_frac_pre1_b[7] & ex1_a_frac_pre2_b[7]));		//and ex1_a_frac_pre3_b( 7)
   assign ex1_a_frac_pre[8] = (~(ex1_a_frac_pre1_b[8] & ex1_a_frac_pre2_b[8]));		//and ex1_a_frac_pre3_b( 8)
   assign ex1_a_frac_pre[9] = (~(ex1_a_frac_pre1_b[9] & ex1_a_frac_pre2_b[9]));		//and ex1_a_frac_pre3_b( 9)
   assign ex1_a_frac_pre[10] = (~(ex1_a_frac_pre1_b[10] & ex1_a_frac_pre2_b[10]));		//and ex1_a_frac_pre3_b(10)
   assign ex1_a_frac_pre[11] = (~(ex1_a_frac_pre1_b[11] & ex1_a_frac_pre2_b[11]));		//and ex1_a_frac_pre3_b(11)
   assign ex1_a_frac_pre[12] = (~(ex1_a_frac_pre1_b[12] & ex1_a_frac_pre2_b[12]));		//and ex1_a_frac_pre3_b(12)
   assign ex1_a_frac_pre[13] = (~(ex1_a_frac_pre1_b[13] & ex1_a_frac_pre2_b[13]));		//and ex1_a_frac_pre3_b(13)
   assign ex1_a_frac_pre[14] = (~(ex1_a_frac_pre1_b[14] & ex1_a_frac_pre2_b[14]));		//and ex1_a_frac_pre3_b(14)
   assign ex1_a_frac_pre[15] = (~(ex1_a_frac_pre1_b[15] & ex1_a_frac_pre2_b[15]));		//and ex1_a_frac_pre3_b(15)
   assign ex1_a_frac_pre[16] = (~(ex1_a_frac_pre1_b[16] & ex1_a_frac_pre2_b[16]));		//and ex1_a_frac_pre3_b(16)
   assign ex1_a_frac_pre[17] = (~(ex1_a_frac_pre1_b[17] & ex1_a_frac_pre2_b[17]));		//and ex1_a_frac_pre3_b(17)
   assign ex1_a_frac_pre[18] = (~(ex1_a_frac_pre1_b[18] & ex1_a_frac_pre2_b[18]));		//and ex1_a_frac_pre3_b(18)
   assign ex1_a_frac_pre[19] = (~(ex1_a_frac_pre1_b[19] & ex1_a_frac_pre2_b[19]));		//and ex1_a_frac_pre3_b(19)
   assign ex1_a_frac_pre[20] = (~(ex1_a_frac_pre1_b[20] & ex1_a_frac_pre2_b[20]));		//and ex1_a_frac_pre3_b(20)
   assign ex1_a_frac_pre[21] = (~(ex1_a_frac_pre1_b[21] & ex1_a_frac_pre2_b[21]));		//and ex1_a_frac_pre3_b(21)
   assign ex1_a_frac_pre[22] = (~(ex1_a_frac_pre1_b[22] & ex1_a_frac_pre2_b[22]));		//and ex1_a_frac_pre3_b(22)
   assign ex1_a_frac_pre[23] = (~(ex1_a_frac_pre1_b[23] & ex1_a_frac_pre2_b[23]));		//and ex1_a_frac_pre3_b(23)
   assign ex1_a_frac_pre[24] = (~(ex1_a_frac_pre1_b[24] & ex1_a_frac_pre2_b[24]));		//and ex1_a_frac_pre3_b(24)
   assign ex1_a_frac_pre[25] = (~(ex1_a_frac_pre1_b[25] & ex1_a_frac_pre2_b[25]));		//and ex1_a_frac_pre3_b(25)
   assign ex1_a_frac_pre[26] = (~(ex1_a_frac_pre1_b[26] & ex1_a_frac_pre2_b[26]));		//and ex1_a_frac_pre3_b(26)
   assign ex1_a_frac_pre[27] = (~(ex1_a_frac_pre1_b[27] & ex1_a_frac_pre2_b[27]));		//and ex1_a_frac_pre3_b(27)
   assign ex1_a_frac_pre[28] = (~(ex1_a_frac_pre1_b[28] & ex1_a_frac_pre2_b[28]));		//and ex1_a_frac_pre3_b(28)
   assign ex1_a_frac_pre[29] = (~(ex1_a_frac_pre1_b[29] & ex1_a_frac_pre2_b[29]));		//and ex1_a_frac_pre3_b(29)
   assign ex1_a_frac_pre[30] = (~(ex1_a_frac_pre1_b[30] & ex1_a_frac_pre2_b[30]));		//and ex1_a_frac_pre3_b(30)
   assign ex1_a_frac_pre[31] = (~(ex1_a_frac_pre1_b[31] & ex1_a_frac_pre2_b[31]));		//and ex1_a_frac_pre3_b(31)
   assign ex1_a_frac_pre[32] = (~(ex1_a_frac_pre1_b[32] & ex1_a_frac_pre2_b[32]));		//and ex1_a_frac_pre3_b(32)
   assign ex1_a_frac_pre[33] = (~(ex1_a_frac_pre1_b[33] & ex1_a_frac_pre2_b[33]));		//and ex1_a_frac_pre3_b(33)
   assign ex1_a_frac_pre[34] = (~(ex1_a_frac_pre1_b[34] & ex1_a_frac_pre2_b[34]));		//and ex1_a_frac_pre3_b(34)
   assign ex1_a_frac_pre[35] = (~(ex1_a_frac_pre1_b[35] & ex1_a_frac_pre2_b[35]));		//and ex1_a_frac_pre3_b(35)
   assign ex1_a_frac_pre[36] = (~(ex1_a_frac_pre1_b[36] & ex1_a_frac_pre2_b[36]));		//and ex1_a_frac_pre3_b(36)
   assign ex1_a_frac_pre[37] = (~(ex1_a_frac_pre1_b[37] & ex1_a_frac_pre2_b[37]));		//and ex1_a_frac_pre3_b(37)
   assign ex1_a_frac_pre[38] = (~(ex1_a_frac_pre1_b[38] & ex1_a_frac_pre2_b[38]));		//and ex1_a_frac_pre3_b(38)
   assign ex1_a_frac_pre[39] = (~(ex1_a_frac_pre1_b[39] & ex1_a_frac_pre2_b[39]));		//and ex1_a_frac_pre3_b(39)
   assign ex1_a_frac_pre[40] = (~(ex1_a_frac_pre1_b[40] & ex1_a_frac_pre2_b[40]));		//and ex1_a_frac_pre3_b(40)
   assign ex1_a_frac_pre[41] = (~(ex1_a_frac_pre1_b[41] & ex1_a_frac_pre2_b[41]));		//and ex1_a_frac_pre3_b(41)
   assign ex1_a_frac_pre[42] = (~(ex1_a_frac_pre1_b[42] & ex1_a_frac_pre2_b[42]));		//and ex1_a_frac_pre3_b(42)
   assign ex1_a_frac_pre[43] = (~(ex1_a_frac_pre1_b[43] & ex1_a_frac_pre2_b[43]));		//and ex1_a_frac_pre3_b(43)
   assign ex1_a_frac_pre[44] = (~(ex1_a_frac_pre1_b[44] & ex1_a_frac_pre2_b[44]));		//and ex1_a_frac_pre3_b(44)
   assign ex1_a_frac_pre[45] = (~(ex1_a_frac_pre1_b[45] & ex1_a_frac_pre2_b[45]));		//and ex1_a_frac_pre3_b(45)
   assign ex1_a_frac_pre[46] = (~(ex1_a_frac_pre1_b[46] & ex1_a_frac_pre2_b[46]));		//and ex1_a_frac_pre3_b(46)
   assign ex1_a_frac_pre[47] = (~(ex1_a_frac_pre1_b[47] & ex1_a_frac_pre2_b[47]));		//and ex1_a_frac_pre3_b(47)
   assign ex1_a_frac_pre[48] = (~(ex1_a_frac_pre1_b[48] & ex1_a_frac_pre2_b[48]));		//and ex1_a_frac_pre3_b(48)
   assign ex1_a_frac_pre[49] = (~(ex1_a_frac_pre1_b[49] & ex1_a_frac_pre2_b[49]));		//and ex1_a_frac_pre3_b(49)
   assign ex1_a_frac_pre[50] = (~(ex1_a_frac_pre1_b[50] & ex1_a_frac_pre2_b[50]));		//and ex1_a_frac_pre3_b(50)
   assign ex1_a_frac_pre[51] = (~(ex1_a_frac_pre1_b[51] & ex1_a_frac_pre2_b[51]));		//and ex1_a_frac_pre3_b(51)
   assign ex1_a_frac_pre[52] = (~(ex1_a_frac_pre1_b[52] & ex1_a_frac_pre2_b[52]));		//and ex1_a_frac_pre3_b(52)

   assign ex1_c_frac_pre[0] = (~(ex1_c_frac_pre1_b[0] & ex1_c_frac_pre2_b[0] & ex1_c_frac_pre3_b[0]));
   assign ex1_c_frac_pre[1] = (~(ex1_c_frac_pre1_b[1] & ex1_c_frac_pre2_b[1] & ex1_c_frac_pre3_b[1]));
   assign ex1_c_frac_pre[2] = (~(ex1_c_frac_pre1_b[2] & ex1_c_frac_pre2_b[2] & ex1_c_frac_pre3_b[2]));
   assign ex1_c_frac_pre[3] = (~(ex1_c_frac_pre1_b[3] & ex1_c_frac_pre2_b[3] & ex1_c_frac_pre3_b[3]));
   assign ex1_c_frac_pre[4] = (~(ex1_c_frac_pre1_b[4] & ex1_c_frac_pre2_b[4] & ex1_c_frac_pre3_b[4]));
   assign ex1_c_frac_pre[5] = (~(ex1_c_frac_pre1_b[5] & ex1_c_frac_pre2_b[5] & ex1_c_frac_pre3_b[5]));
   assign ex1_c_frac_pre[6] = (~(ex1_c_frac_pre1_b[6] & ex1_c_frac_pre2_b[6] & ex1_c_frac_pre3_b[6]));
   assign ex1_c_frac_pre[7] = (~(ex1_c_frac_pre1_b[7] & ex1_c_frac_pre2_b[7] & ex1_c_frac_pre3_b[7]));
   assign ex1_c_frac_pre[8] = (~(ex1_c_frac_pre1_b[8] & ex1_c_frac_pre2_b[8] & ex1_c_frac_pre3_b[8]));
   assign ex1_c_frac_pre[9] = (~(ex1_c_frac_pre1_b[9] & ex1_c_frac_pre2_b[9] & ex1_c_frac_pre3_b[9]));
   assign ex1_c_frac_pre[10] = (~(ex1_c_frac_pre1_b[10] & ex1_c_frac_pre2_b[10] & ex1_c_frac_pre3_b[10]));
   assign ex1_c_frac_pre[11] = (~(ex1_c_frac_pre1_b[11] & ex1_c_frac_pre2_b[11] & ex1_c_frac_pre3_b[11]));
   assign ex1_c_frac_pre[12] = (~(ex1_c_frac_pre1_b[12] & ex1_c_frac_pre2_b[12] & ex1_c_frac_pre3_b[12]));
   assign ex1_c_frac_pre[13] = (~(ex1_c_frac_pre1_b[13] & ex1_c_frac_pre2_b[13] & ex1_c_frac_pre3_b[13]));
   assign ex1_c_frac_pre[14] = (~(ex1_c_frac_pre1_b[14] & ex1_c_frac_pre2_b[14] & ex1_c_frac_pre3_b[14]));
   assign ex1_c_frac_pre[15] = (~(ex1_c_frac_pre1_b[15] & ex1_c_frac_pre2_b[15] & ex1_c_frac_pre3_b[15]));
   assign ex1_c_frac_pre[16] = (~(ex1_c_frac_pre1_b[16] & ex1_c_frac_pre2_b[16] & ex1_c_frac_pre3_b[16]));
   assign ex1_c_frac_pre[17] = (~(ex1_c_frac_pre1_b[17] & ex1_c_frac_pre2_b[17] & ex1_c_frac_pre3_b[17]));
   assign ex1_c_frac_pre[18] = (~(ex1_c_frac_pre1_b[18] & ex1_c_frac_pre2_b[18] & ex1_c_frac_pre3_b[18]));
   assign ex1_c_frac_pre[19] = (~(ex1_c_frac_pre1_b[19] & ex1_c_frac_pre2_b[19] & ex1_c_frac_pre3_b[19]));
   assign ex1_c_frac_pre[20] = (~(ex1_c_frac_pre1_b[20] & ex1_c_frac_pre2_b[20] & ex1_c_frac_pre3_b[20]));
   assign ex1_c_frac_pre[21] = (~(ex1_c_frac_pre1_b[21] & ex1_c_frac_pre2_b[21] & ex1_c_frac_pre3_b[21]));
   assign ex1_c_frac_pre[22] = (~(ex1_c_frac_pre1_b[22] & ex1_c_frac_pre2_b[22] & ex1_c_frac_pre3_b[22]));
   assign ex1_c_frac_pre[23] = (~(ex1_c_frac_pre1_b[23] & ex1_c_frac_pre2_b[23] & ex1_c_frac_pre3_b[23]));
   assign ex1_c_frac_pre[24] = (~(ex1_c_frac_pre1_b[24] & ex1_c_frac_pre2_b[24] & ex1_c_frac_pre3_b[24]));
   assign ex1_c_frac_pre[25] = (~(ex1_c_frac_pre1_b[25] & ex1_c_frac_pre2_b[25] & ex1_c_frac_pre3_b[25]));
   assign ex1_c_frac_pre[26] = (~(ex1_c_frac_pre1_b[26] & ex1_c_frac_pre2_b[26] & ex1_c_frac_pre3_b[26]));
   assign ex1_c_frac_pre[27] = (~(ex1_c_frac_pre1_b[27] & ex1_c_frac_pre2_b[27] & ex1_c_frac_pre3_b[27]));
   assign ex1_c_frac_pre[28] = (~(ex1_c_frac_pre1_b[28] & ex1_c_frac_pre2_b[28] & ex1_c_frac_pre3_b[28]));
   assign ex1_c_frac_pre[29] = (~(ex1_c_frac_pre1_b[29] & ex1_c_frac_pre2_b[29] & ex1_c_frac_pre3_b[29]));
   assign ex1_c_frac_pre[30] = (~(ex1_c_frac_pre1_b[30] & ex1_c_frac_pre2_b[30] & ex1_c_frac_pre3_b[30]));
   assign ex1_c_frac_pre[31] = (~(ex1_c_frac_pre1_b[31] & ex1_c_frac_pre2_b[31] & ex1_c_frac_pre3_b[31]));
   assign ex1_c_frac_pre[32] = (~(ex1_c_frac_pre1_b[32] & ex1_c_frac_pre2_b[32] & ex1_c_frac_pre3_b[32]));
   assign ex1_c_frac_pre[33] = (~(ex1_c_frac_pre1_b[33] & ex1_c_frac_pre2_b[33] & ex1_c_frac_pre3_b[33]));
   assign ex1_c_frac_pre[34] = (~(ex1_c_frac_pre1_b[34] & ex1_c_frac_pre2_b[34] & ex1_c_frac_pre3_b[34]));
   assign ex1_c_frac_pre[35] = (~(ex1_c_frac_pre1_b[35] & ex1_c_frac_pre2_b[35] & ex1_c_frac_pre3_b[35]));
   assign ex1_c_frac_pre[36] = (~(ex1_c_frac_pre1_b[36] & ex1_c_frac_pre2_b[36] & ex1_c_frac_pre3_b[36]));
   assign ex1_c_frac_pre[37] = (~(ex1_c_frac_pre1_b[37] & ex1_c_frac_pre2_b[37] & ex1_c_frac_pre3_b[37]));
   assign ex1_c_frac_pre[38] = (~(ex1_c_frac_pre1_b[38] & ex1_c_frac_pre2_b[38] & ex1_c_frac_pre3_b[38]));
   assign ex1_c_frac_pre[39] = (~(ex1_c_frac_pre1_b[39] & ex1_c_frac_pre2_b[39] & ex1_c_frac_pre3_b[39]));
   assign ex1_c_frac_pre[40] = (~(ex1_c_frac_pre1_b[40] & ex1_c_frac_pre2_b[40] & ex1_c_frac_pre3_b[40]));
   assign ex1_c_frac_pre[41] = (~(ex1_c_frac_pre1_b[41] & ex1_c_frac_pre2_b[41] & ex1_c_frac_pre3_b[41]));
   assign ex1_c_frac_pre[42] = (~(ex1_c_frac_pre1_b[42] & ex1_c_frac_pre2_b[42] & ex1_c_frac_pre3_b[42]));
   assign ex1_c_frac_pre[43] = (~(ex1_c_frac_pre1_b[43] & ex1_c_frac_pre2_b[43] & ex1_c_frac_pre3_b[43]));
   assign ex1_c_frac_pre[44] = (~(ex1_c_frac_pre1_b[44] & ex1_c_frac_pre2_b[44] & ex1_c_frac_pre3_b[44]));
   assign ex1_c_frac_pre[45] = (~(ex1_c_frac_pre1_b[45] & ex1_c_frac_pre2_b[45] & ex1_c_frac_pre3_b[45]));
   assign ex1_c_frac_pre[46] = (~(ex1_c_frac_pre1_b[46] & ex1_c_frac_pre2_b[46] & ex1_c_frac_pre3_b[46]));
   assign ex1_c_frac_pre[47] = (~(ex1_c_frac_pre1_b[47] & ex1_c_frac_pre2_b[47] & ex1_c_frac_pre3_b[47]));
   assign ex1_c_frac_pre[48] = (~(ex1_c_frac_pre1_b[48] & ex1_c_frac_pre2_b[48] & ex1_c_frac_pre3_b[48]));
   assign ex1_c_frac_pre[49] = (~(ex1_c_frac_pre1_b[49] & ex1_c_frac_pre2_b[49] & ex1_c_frac_pre3_b[49]));
   assign ex1_c_frac_pre[50] = (~(ex1_c_frac_pre1_b[50] & ex1_c_frac_pre2_b[50] & ex1_c_frac_pre3_b[50]));
   assign ex1_c_frac_pre[51] = (~(ex1_c_frac_pre1_b[51] & ex1_c_frac_pre2_b[51] & ex1_c_frac_pre3_b[51]));
   assign ex1_c_frac_pre[52] = (~(ex1_c_frac_pre1_b[52] & ex1_c_frac_pre2_b[52] & ex1_c_frac_pre3_b[52]));

   assign ex1_c_frac_pre_hulp = (~(ex1_c_frac_pre1_b[24] & ex1_c_frac_pre2_b[24] & ex1_c_frac_pre3_hulp_b));

   assign ex1_b_frac_pre[0] = (~(ex1_b_frac_pre1_b[0] & ex1_b_frac_pre2_b[0] & ex1_b_frac_pre3_b[0]));
   assign ex1_b_frac_pre[1] = (~(ex1_b_frac_pre1_b[1] & ex1_b_frac_pre2_b[1] & ex1_b_frac_pre3_b[1]));
   assign ex1_b_frac_pre[2] = (~(ex1_b_frac_pre1_b[2] & ex1_b_frac_pre2_b[2]));
   assign ex1_b_frac_pre[3] = (~(ex1_b_frac_pre1_b[3] & ex1_b_frac_pre2_b[3]));
   assign ex1_b_frac_pre[4] = (~(ex1_b_frac_pre1_b[4] & ex1_b_frac_pre2_b[4]));
   assign ex1_b_frac_pre[5] = (~(ex1_b_frac_pre1_b[5] & ex1_b_frac_pre2_b[5]));
   assign ex1_b_frac_pre[6] = (~(ex1_b_frac_pre1_b[6] & ex1_b_frac_pre2_b[6]));
   assign ex1_b_frac_pre[7] = (~(ex1_b_frac_pre1_b[7] & ex1_b_frac_pre2_b[7]));
   assign ex1_b_frac_pre[8] = (~(ex1_b_frac_pre1_b[8] & ex1_b_frac_pre2_b[8]));
   assign ex1_b_frac_pre[9] = (~(ex1_b_frac_pre1_b[9] & ex1_b_frac_pre2_b[9]));
   assign ex1_b_frac_pre[10] = (~(ex1_b_frac_pre1_b[10] & ex1_b_frac_pre2_b[10]));
   assign ex1_b_frac_pre[11] = (~(ex1_b_frac_pre1_b[11] & ex1_b_frac_pre2_b[11]));
   assign ex1_b_frac_pre[12] = (~(ex1_b_frac_pre1_b[12] & ex1_b_frac_pre2_b[12]));
   assign ex1_b_frac_pre[13] = (~(ex1_b_frac_pre1_b[13] & ex1_b_frac_pre2_b[13]));
   assign ex1_b_frac_pre[14] = (~(ex1_b_frac_pre1_b[14] & ex1_b_frac_pre2_b[14]));
   assign ex1_b_frac_pre[15] = (~(ex1_b_frac_pre1_b[15] & ex1_b_frac_pre2_b[15]));
   assign ex1_b_frac_pre[16] = (~(ex1_b_frac_pre1_b[16] & ex1_b_frac_pre2_b[16]));
   assign ex1_b_frac_pre[17] = (~(ex1_b_frac_pre1_b[17] & ex1_b_frac_pre2_b[17]));
   assign ex1_b_frac_pre[18] = (~(ex1_b_frac_pre1_b[18] & ex1_b_frac_pre2_b[18]));
   assign ex1_b_frac_pre[19] = (~(ex1_b_frac_pre1_b[19] & ex1_b_frac_pre2_b[19]));
   assign ex1_b_frac_pre[20] = (~(ex1_b_frac_pre1_b[20] & ex1_b_frac_pre2_b[20]));
   assign ex1_b_frac_pre[21] = (~(ex1_b_frac_pre1_b[21] & ex1_b_frac_pre2_b[21]));
   assign ex1_b_frac_pre[22] = (~(ex1_b_frac_pre1_b[22] & ex1_b_frac_pre2_b[22]));
   assign ex1_b_frac_pre[23] = (~(ex1_b_frac_pre1_b[23] & ex1_b_frac_pre2_b[23]));
   assign ex1_b_frac_pre[24] = (~(ex1_b_frac_pre1_b[24] & ex1_b_frac_pre2_b[24]));
   assign ex1_b_frac_pre[25] = (~(ex1_b_frac_pre1_b[25] & ex1_b_frac_pre2_b[25]));
   assign ex1_b_frac_pre[26] = (~(ex1_b_frac_pre1_b[26] & ex1_b_frac_pre2_b[26]));
   assign ex1_b_frac_pre[27] = (~(ex1_b_frac_pre1_b[27] & ex1_b_frac_pre2_b[27]));
   assign ex1_b_frac_pre[28] = (~(ex1_b_frac_pre1_b[28] & ex1_b_frac_pre2_b[28]));
   assign ex1_b_frac_pre[29] = (~(ex1_b_frac_pre1_b[29] & ex1_b_frac_pre2_b[29]));
   assign ex1_b_frac_pre[30] = (~(ex1_b_frac_pre1_b[30] & ex1_b_frac_pre2_b[30]));
   assign ex1_b_frac_pre[31] = (~(ex1_b_frac_pre1_b[31] & ex1_b_frac_pre2_b[31]));
   assign ex1_b_frac_pre[32] = (~(ex1_b_frac_pre1_b[32] & ex1_b_frac_pre2_b[32]));
   assign ex1_b_frac_pre[33] = (~(ex1_b_frac_pre1_b[33] & ex1_b_frac_pre2_b[33]));
   assign ex1_b_frac_pre[34] = (~(ex1_b_frac_pre1_b[34] & ex1_b_frac_pre2_b[34]));
   assign ex1_b_frac_pre[35] = (~(ex1_b_frac_pre1_b[35] & ex1_b_frac_pre2_b[35]));
   assign ex1_b_frac_pre[36] = (~(ex1_b_frac_pre1_b[36] & ex1_b_frac_pre2_b[36]));
   assign ex1_b_frac_pre[37] = (~(ex1_b_frac_pre1_b[37] & ex1_b_frac_pre2_b[37]));
   assign ex1_b_frac_pre[38] = (~(ex1_b_frac_pre1_b[38] & ex1_b_frac_pre2_b[38]));
   assign ex1_b_frac_pre[39] = (~(ex1_b_frac_pre1_b[39] & ex1_b_frac_pre2_b[39]));
   assign ex1_b_frac_pre[40] = (~(ex1_b_frac_pre1_b[40] & ex1_b_frac_pre2_b[40]));
   assign ex1_b_frac_pre[41] = (~(ex1_b_frac_pre1_b[41] & ex1_b_frac_pre2_b[41]));
   assign ex1_b_frac_pre[42] = (~(ex1_b_frac_pre1_b[42] & ex1_b_frac_pre2_b[42]));
   assign ex1_b_frac_pre[43] = (~(ex1_b_frac_pre1_b[43] & ex1_b_frac_pre2_b[43]));
   assign ex1_b_frac_pre[44] = (~(ex1_b_frac_pre1_b[44] & ex1_b_frac_pre2_b[44]));
   assign ex1_b_frac_pre[45] = (~(ex1_b_frac_pre1_b[45] & ex1_b_frac_pre2_b[45]));
   assign ex1_b_frac_pre[46] = (~(ex1_b_frac_pre1_b[46] & ex1_b_frac_pre2_b[46]));
   assign ex1_b_frac_pre[47] = (~(ex1_b_frac_pre1_b[47] & ex1_b_frac_pre2_b[47]));
   assign ex1_b_frac_pre[48] = (~(ex1_b_frac_pre1_b[48] & ex1_b_frac_pre2_b[48]));
   assign ex1_b_frac_pre[49] = (~(ex1_b_frac_pre1_b[49] & ex1_b_frac_pre2_b[49]));
   assign ex1_b_frac_pre[50] = (~(ex1_b_frac_pre1_b[50] & ex1_b_frac_pre2_b[50]));
   assign ex1_b_frac_pre[51] = (~(ex1_b_frac_pre1_b[51] & ex1_b_frac_pre2_b[51]));
   assign ex1_b_frac_pre[52] = (~(ex1_b_frac_pre1_b[52] & ex1_b_frac_pre2_b[52]));

   assign ex1_s_frac_pre[0] = (~(ex1_s_frac_pre1_b[0] & ex1_s_frac_pre2_b[0]));
   assign ex1_s_frac_pre[1] = (~(ex1_s_frac_pre1_b[1] & ex1_s_frac_pre2_b[1]));
   assign ex1_s_frac_pre[2] = (~(ex1_s_frac_pre1_b[2] & ex1_s_frac_pre2_b[2]));
   assign ex1_s_frac_pre[3] = (~(ex1_s_frac_pre1_b[3] & ex1_s_frac_pre2_b[3]));
   assign ex1_s_frac_pre[4] = (~(ex1_s_frac_pre1_b[4] & ex1_s_frac_pre2_b[4]));
   assign ex1_s_frac_pre[5] = (~(ex1_s_frac_pre1_b[5] & ex1_s_frac_pre2_b[5]));
   assign ex1_s_frac_pre[6] = (~(ex1_s_frac_pre1_b[6] & ex1_s_frac_pre2_b[6]));
   assign ex1_s_frac_pre[7] = (~(ex1_s_frac_pre1_b[7] & ex1_s_frac_pre2_b[7]));
   assign ex1_s_frac_pre[8] = (~(ex1_s_frac_pre1_b[8] & ex1_s_frac_pre2_b[8]));
   assign ex1_s_frac_pre[9] = (~(ex1_s_frac_pre1_b[9] & ex1_s_frac_pre2_b[9]));
   assign ex1_s_frac_pre[10] = (~(ex1_s_frac_pre1_b[10] & ex1_s_frac_pre2_b[10]));
   assign ex1_s_frac_pre[11] = (~(ex1_s_frac_pre1_b[11] & ex1_s_frac_pre2_b[11]));
   assign ex1_s_frac_pre[12] = (~(ex1_s_frac_pre1_b[12] & ex1_s_frac_pre2_b[12]));
   assign ex1_s_frac_pre[13] = (~(ex1_s_frac_pre1_b[13] & ex1_s_frac_pre2_b[13]));
   assign ex1_s_frac_pre[14] = (~(ex1_s_frac_pre1_b[14] & ex1_s_frac_pre2_b[14]));
   assign ex1_s_frac_pre[15] = (~(ex1_s_frac_pre1_b[15] & ex1_s_frac_pre2_b[15]));
   assign ex1_s_frac_pre[16] = (~(ex1_s_frac_pre1_b[16] & ex1_s_frac_pre2_b[16]));
   assign ex1_s_frac_pre[17] = (~(ex1_s_frac_pre1_b[17] & ex1_s_frac_pre2_b[17]));
   assign ex1_s_frac_pre[18] = (~(ex1_s_frac_pre1_b[18] & ex1_s_frac_pre2_b[18]));
   assign ex1_s_frac_pre[19] = (~(ex1_s_frac_pre1_b[19] & ex1_s_frac_pre2_b[19]));
   assign ex1_s_frac_pre[20] = (~(ex1_s_frac_pre1_b[20] & ex1_s_frac_pre2_b[20]));
   assign ex1_s_frac_pre[21] = (~(ex1_s_frac_pre1_b[21] & ex1_s_frac_pre2_b[21]));
   assign ex1_s_frac_pre[22] = (~(ex1_s_frac_pre1_b[22] & ex1_s_frac_pre2_b[22]));
   assign ex1_s_frac_pre[23] = (~(ex1_s_frac_pre1_b[23] & ex1_s_frac_pre2_b[23]));
   assign ex1_s_frac_pre[24] = (~(ex1_s_frac_pre1_b[24] & ex1_s_frac_pre2_b[24]));
   assign ex1_s_frac_pre[25] = (~(ex1_s_frac_pre1_b[25] & ex1_s_frac_pre2_b[25]));
   assign ex1_s_frac_pre[26] = (~(ex1_s_frac_pre1_b[26] & ex1_s_frac_pre2_b[26]));
   assign ex1_s_frac_pre[27] = (~(ex1_s_frac_pre1_b[27] & ex1_s_frac_pre2_b[27]));
   assign ex1_s_frac_pre[28] = (~(ex1_s_frac_pre1_b[28] & ex1_s_frac_pre2_b[28]));
   assign ex1_s_frac_pre[29] = (~(ex1_s_frac_pre1_b[29] & ex1_s_frac_pre2_b[29]));
   assign ex1_s_frac_pre[30] = (~(ex1_s_frac_pre1_b[30] & ex1_s_frac_pre2_b[30]));
   assign ex1_s_frac_pre[31] = (~(ex1_s_frac_pre1_b[31] & ex1_s_frac_pre2_b[31]));
   assign ex1_s_frac_pre[32] = (~(ex1_s_frac_pre1_b[32] & ex1_s_frac_pre2_b[32]));
   assign ex1_s_frac_pre[33] = (~(ex1_s_frac_pre1_b[33] & ex1_s_frac_pre2_b[33]));
   assign ex1_s_frac_pre[34] = (~(ex1_s_frac_pre1_b[34] & ex1_s_frac_pre2_b[34]));
   assign ex1_s_frac_pre[35] = (~(ex1_s_frac_pre1_b[35] & ex1_s_frac_pre2_b[35]));
   assign ex1_s_frac_pre[36] = (~(ex1_s_frac_pre1_b[36] & ex1_s_frac_pre2_b[36]));
   assign ex1_s_frac_pre[37] = (~(ex1_s_frac_pre1_b[37] & ex1_s_frac_pre2_b[37]));
   assign ex1_s_frac_pre[38] = (~(ex1_s_frac_pre1_b[38] & ex1_s_frac_pre2_b[38]));
   assign ex1_s_frac_pre[39] = (~(ex1_s_frac_pre1_b[39] & ex1_s_frac_pre2_b[39]));
   assign ex1_s_frac_pre[40] = (~(ex1_s_frac_pre1_b[40] & ex1_s_frac_pre2_b[40]));
   assign ex1_s_frac_pre[41] = (~(ex1_s_frac_pre1_b[41] & ex1_s_frac_pre2_b[41]));
   assign ex1_s_frac_pre[42] = (~(ex1_s_frac_pre1_b[42] & ex1_s_frac_pre2_b[42]));
   assign ex1_s_frac_pre[43] = (~(ex1_s_frac_pre1_b[43] & ex1_s_frac_pre2_b[43]));
   assign ex1_s_frac_pre[44] = (~(ex1_s_frac_pre1_b[44] & ex1_s_frac_pre2_b[44]));
   assign ex1_s_frac_pre[45] = (~(ex1_s_frac_pre1_b[45] & ex1_s_frac_pre2_b[45]));
   assign ex1_s_frac_pre[46] = (~(ex1_s_frac_pre1_b[46] & ex1_s_frac_pre2_b[46]));
   assign ex1_s_frac_pre[47] = (~(ex1_s_frac_pre1_b[47] & ex1_s_frac_pre2_b[47]));
   assign ex1_s_frac_pre[48] = (~(ex1_s_frac_pre1_b[48] & ex1_s_frac_pre2_b[48]));
   assign ex1_s_frac_pre[49] = (~(ex1_s_frac_pre1_b[49] & ex1_s_frac_pre2_b[49]));
   assign ex1_s_frac_pre[50] = (~(ex1_s_frac_pre1_b[50] & ex1_s_frac_pre2_b[50]));
   assign ex1_s_frac_pre[51] = (~(ex1_s_frac_pre1_b[51] & ex1_s_frac_pre2_b[51]));
   assign ex1_s_frac_pre[52] = (~(ex1_s_frac_pre1_b[52] & ex1_s_frac_pre2_b[52]));

   assign ex1_a_frac_prebyp[0:52] = ex1_a_frac_pre[0:52];		// may need to manually repower
   assign ex1_c_frac_prebyp[0:52] = ex1_c_frac_pre[0:52];
   assign ex1_b_frac_prebyp[0:52] = ex1_b_frac_pre[0:52];
   assign ex1_s_frac_prebyp[0:52] = ex1_s_frac_pre[0:52];
   assign ex1_c_frac_prebyp_hulp = ex1_c_frac_pre_hulp;

   assign ex1_a_sign_fpr = f_fpr_ex1_a_sign;		// later on we may map in some inverters
   assign ex1_c_sign_fpr = f_fpr_ex1_c_sign;
   assign ex1_b_sign_fpr = f_fpr_ex1_b_sign;
   assign ex1_s_sign_fpr = f_fpr_ex1_s_sign;
   assign ex1_a_expo_fpr[1:13] = f_fpr_ex1_a_expo[1:13];
   assign ex1_c_expo_fpr[1:13] = f_fpr_ex1_c_expo[1:13];
   assign ex1_b_expo_fpr[1:13] = f_fpr_ex1_b_expo[1:13];
   assign ex1_s_expo_fpr[1:13] = {2'b00, f_fpr_ex1_s_expo[3:13]};
   assign ex1_a_frac_fpr[0:52] = f_fpr_ex1_a_frac[0:52];
   assign ex1_c_frac_fpr[0:52] = f_fpr_ex1_c_frac[0:52];
   assign ex1_b_frac_fpr[0:52] = f_fpr_ex1_b_frac[0:52];
   assign ex1_s_frac_fpr[0:52] = f_fpr_ex1_s_frac[0:52];

   //---------------------------------------------------------------------------------------
   // for the last level, need a seperate copy for each latch for the pass gate rules
   //   (fpr is the late path ... so the mux is hierarchical to speed up that path)
   //---------------------------------------------------------------------------------------

   assign ex1_a_sign_fmt_b = (~((sel_a_no_byp_s & ex1_a_sign_fpr) | ex1_a_sign_prebyp));
   assign ex1_a_sign_pic_b = (~((sel_a_no_byp_s & ex1_a_sign_fpr) | ex1_a_sign_prebyp));
   assign ex1_c_sign_fmt_b = (~((sel_c_no_byp_s & ex1_c_sign_fpr) | ex1_c_sign_prebyp));
   assign ex1_c_sign_pic_b = (~((sel_c_no_byp_s & ex1_c_sign_fpr) | ex1_c_sign_prebyp));
   assign ex1_b_sign_fmt_b = (~((sel_b_no_byp_s & ex1_b_sign_fpr) | ex1_b_sign_prebyp));
   assign ex1_b_sign_pic_b = (~((sel_b_no_byp_s & ex1_b_sign_fpr) | ex1_b_sign_prebyp));
   assign ex1_b_sign_alg_b = (~((sel_b_no_byp_s & ex1_b_sign_fpr) | ex1_b_sign_prebyp));

   assign ex1_a_expo_fmt_b[1:13] = (~(({13{sel_a_no_byp}} & ex1_a_expo_fpr[1:13]) | ex1_a_expo_prebyp[1:13]));
   assign ex1_a_expo_eie_b[1:13] = (~(({13{sel_a_no_byp}} & ex1_a_expo_fpr[1:13]) | ex1_a_expo_prebyp[1:13]));
   assign ex1_a_expo_alg_b[1:13] = (~(({13{sel_a_no_byp}} & ex1_a_expo_fpr[1:13]) | ex1_a_expo_prebyp[1:13]));
   assign ex1_c_expo_fmt_b[1:13] = (~(({13{sel_c_no_byp}} & ex1_c_expo_fpr[1:13]) | ex1_c_expo_prebyp[1:13]));
   assign ex1_c_expo_eie_b[1:13] = (~(({13{sel_c_no_byp}} & ex1_c_expo_fpr[1:13]) | ex1_c_expo_prebyp[1:13]));
   assign ex1_c_expo_alg_b[1:13] = (~(({13{sel_c_no_byp}} & ex1_c_expo_fpr[1:13]) | ex1_c_expo_prebyp[1:13]));
   assign ex1_b_expo_fmt_b[1:13] = (~(({13{sel_b_no_byp}} & ex1_b_expo_fpr[1:13]) | ex1_b_expo_prebyp[1:13]));
   assign ex1_b_expo_eie_b[1:13] = (~(({13{sel_b_no_byp}} & ex1_b_expo_fpr[1:13]) | ex1_b_expo_prebyp[1:13]));
   assign ex1_b_expo_alg_b[1:13] = (~(({13{sel_b_no_byp}} & ex1_b_expo_fpr[1:13]) | ex1_b_expo_prebyp[1:13]));

   assign ex1_a_frac_fmt_b[0:23] = (~(({24{sel_a_no_byp}} & ex1_a_frac_fpr[0:23]) | ex1_a_frac_prebyp[0:23]));
   assign ex1_a_frac_mul_b[0:23] = (~(({24{sel_a_no_byp}} & ex1_a_frac_fpr[0:23]) | ex1_a_frac_prebyp[0:23]));
   assign ex1_a_frac_mul_17_b = (~((sel_a_no_byp & ex1_a_frac_fpr[17]) | ex1_a_frac_prebyp[17]));
   assign ex1_a_frac_fmt_b[24:52] = (~(({29{sel_a_no_byp}} & ex1_a_frac_fpr[24:52]) | ex1_a_frac_prebyp[24:52]));
   assign ex1_a_frac_mul_b[24:52] = (~(({29{sel_a_no_byp}} & ex1_a_frac_fpr[24:52]) | ex1_a_frac_prebyp[24:52]));		//SP/UNDEF and (24 to 52=> sel_a_dp )) );
   assign ex1_a_frac_mul_35_b = (~((sel_a_no_byp & ex1_a_frac_fpr[35]) | ex1_a_frac_prebyp[35]));		//SP/UNDEF and             sel_a_dp  ) );

   assign ex1_c_frac_fmt_b[0:23] = (~(({24{sel_c_no_byp}} & ex1_c_frac_fpr[0:23]) | ex1_c_frac_prebyp[0:23]));
   assign ex1_c_frac_mul_b[0:23] = (~(({24{sel_c_no_byp}} & ex1_c_frac_fpr[0:23]) | ex1_c_frac_prebyp[0:23]));

   assign ex1_c_frac_fmt_b[24] = (~((sel_c_no_byp & ex1_c_frac_fpr[24]) | ex1_c_frac_prebyp[24]));
   assign ex1_c_frac_mul_b[24] = (~((sel_c_no_byp & ex1_c_frac_fpr[24]) | ex1_c_frac_prebyp_hulp));		//SP/UNDEF and (24 to 52=> sel_c_dp )) );

   assign ex1_c_frac_fmt_b[25:52] = (~(({28{sel_c_no_byp}} & ex1_c_frac_fpr[25:52]) | ex1_c_frac_prebyp[25:52]));
   assign ex1_c_frac_mul_b[25:52] = (~(({28{sel_c_no_byp}} & ex1_c_frac_fpr[25:52]) | ex1_c_frac_prebyp[25:52]));		//SP/UNDEF and (25 to 52=> sel_c_dp )) );
   assign ex1_c_frac_mul_b[53] = (~(f_dcd_ex1_uc_fc_hulp & (~f_dcd_ex1_sp)));

   assign ex1_b_frac_fmt_b[0:23] = (~(({24{sel_b_no_byp}} & ex1_b_frac_fpr[0:23]) | ex1_b_frac_prebyp[0:23]));
   assign ex1_b_frac_alg_b[0:23] = (~(({24{sel_b_no_byp}} & ex1_b_frac_fpr[0:23]) | ex1_b_frac_prebyp[0:23]));
   assign ex1_b_frac_fmt_b[24:52] = (~(({29{sel_b_no_byp}} & ex1_b_frac_fpr[24:52]) | ex1_b_frac_prebyp[24:52]));
   assign ex1_b_frac_alg_b[24:52] = (~(({29{sel_b_no_byp}} & ex1_b_frac_fpr[24:52]) | ex1_b_frac_prebyp[24:52]));		//SP/UNDEF ex1_b_frac_prebyp_dp(24 to 52) );

   assign f_byp_ex1_s_sign = ((sel_s_no_byp_s & ex1_s_sign_fpr) | ex1_s_sign_prebyp);
   assign f_byp_ex1_s_expo[3:13] = (({11{sel_s_no_byp}} & ex1_s_expo_fpr[3:13]) | ex1_s_expo_prebyp[3:13]);
   assign f_byp_ex1_s_frac[0:23] = (({24{sel_s_no_byp}} & ex1_s_frac_fpr[0:23]) | ex1_s_frac_prebyp[0:23]);
   assign f_byp_ex1_s_frac[24:52] = (({29{sel_s_no_byp}} & ex1_s_frac_fpr[24:52]) | ex1_s_frac_prebyp[24:52]);		//SP/UNDEF ex1_b_frac_prebyp_dp(24 to 52) );

   //====================================================================
   //== ex2 operand latches
   //====================================================================

   //---------------- FRACTION ---------------------------------------

   //  force            => tidn,
   //  --d_mode           => tiup,
   //  delay_lclkr      => tidn,
   //  mpw1_b           => tidn,
   //  mpw2_b           => tidn,
   //  nclk             => nclk,
   //  act              => ex1_act,
   //  thold_b          => thold_0_b,
   //  sg               => sg_0,


   tri_inv_nlats #(.WIDTH(53),  .NEEDS_SRESET(0)) ex2_frac_b_alg_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in      --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(ex2_b_frac_si),		//in
      .scanout(ex2_b_frac_so),		//in
      .d(ex1_b_frac_alg_b[0:52]),		//in
      .qb(ex2_b_frac_alg[0:52])		//out
   );


   tri_inv_nlats #(.WIDTH(53),   .NEEDS_SRESET(0)) ex2_frac_a_fmt_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in      --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(ex2_frac_a_fmt_si),		//in
      .scanout(ex2_frac_a_fmt_so),		//in
      .d(ex1_a_frac_fmt_b[0:52]),
      .qb(ex2_a_frac_fmt[0:52])
   );


   tri_inv_nlats #(.WIDTH(53),   .NEEDS_SRESET(0)) ex2_frac_c_fmt_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in      --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(ex2_frac_c_fmt_si),		//in
      .scanout(ex2_frac_c_fmt_so),		//in
      .d(ex1_c_frac_fmt_b[0:52]),
      .qb(ex2_c_frac_fmt[0:52])
   );


   tri_inv_nlats #(.WIDTH(53),  .NEEDS_SRESET(0)) ex2_frac_b_fmt_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in      --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(ex2_frac_b_fmt_si),		//in
      .scanout(ex2_frac_b_fmt_so),		//in
      .d(ex1_b_frac_fmt_b[0:52]),
      .qb(ex2_b_frac_fmt[0:52])
   );

   assign ex2_b_frac_alg_b[0:52] = (~ex2_b_frac_alg[0:52]);
   assign ex2_b_frac_fmt_b[0:52] = (~ex2_b_frac_fmt[0:52]);
   assign ex2_c_frac_fmt_b[0:52] = (~ex2_c_frac_fmt[0:52]);
   assign ex2_a_frac_fmt_b[0:52] = (~ex2_a_frac_fmt[0:52]);

   assign temp_ex1_c_frac_mul[0:53] = (~ex1_c_frac_mul_b[0:53]);
   assign temp_ex1_a_frac_mul[0:52] = (~ex1_a_frac_mul_b[0:52]);
   assign temp_ex1_a_frac_mul_17 = (~ex1_a_frac_mul_17_b);
   assign temp_ex1_a_frac_mul_35 = (~ex1_a_frac_mul_35_b);


   tri_inv_nlats #(.WIDTH(54), .NEEDS_SRESET(0)) ex2_frac_c_mul_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in      --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(frac_mul_c_si),		//in
      .scanout(frac_mul_c_so),		//in
      .d({temp_ex1_c_frac_mul[0:52],		//in
           temp_ex1_c_frac_mul[53]}),		//in  -- f_dcd_ex1_uc_fc_hulp,
      .qb(ex2_c_frac_mul_b[0:53])		//out
   );


   tri_inv_nlats #(.WIDTH(55),  .NEEDS_SRESET(0)) ex2_frac_a_mul_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in  --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(frac_mul_a_si),		//in
      .scanout(frac_mul_a_so),		//in
      .d({   temp_ex1_a_frac_mul[0],
             temp_ex1_a_frac_mul[17],
             temp_ex1_a_frac_mul[35],
             temp_ex1_a_frac_mul[1],
             temp_ex1_a_frac_mul[18],
             temp_ex1_a_frac_mul[36],
             temp_ex1_a_frac_mul[2],
             temp_ex1_a_frac_mul[19],
             temp_ex1_a_frac_mul[37],
             temp_ex1_a_frac_mul[3],
             temp_ex1_a_frac_mul[20],
             temp_ex1_a_frac_mul[38],
             temp_ex1_a_frac_mul[4],
             temp_ex1_a_frac_mul[21],
             temp_ex1_a_frac_mul[39],
             temp_ex1_a_frac_mul[5],
             temp_ex1_a_frac_mul[22],
             temp_ex1_a_frac_mul[40],
             temp_ex1_a_frac_mul[6],
             temp_ex1_a_frac_mul[23],
             temp_ex1_a_frac_mul[41],
             temp_ex1_a_frac_mul[7],
             temp_ex1_a_frac_mul[24],
             temp_ex1_a_frac_mul[42],
             temp_ex1_a_frac_mul[8],
             temp_ex1_a_frac_mul[25],
             temp_ex1_a_frac_mul[43],
             temp_ex1_a_frac_mul[9],
             temp_ex1_a_frac_mul[26],
             temp_ex1_a_frac_mul[44],
             temp_ex1_a_frac_mul[10],
             temp_ex1_a_frac_mul[27],
             temp_ex1_a_frac_mul[45],
             temp_ex1_a_frac_mul[11],
             temp_ex1_a_frac_mul[28],
             temp_ex1_a_frac_mul[46],
             temp_ex1_a_frac_mul[12],
             temp_ex1_a_frac_mul[29],
             temp_ex1_a_frac_mul[47],
             temp_ex1_a_frac_mul[13],
             temp_ex1_a_frac_mul[30],
             temp_ex1_a_frac_mul[48],
             temp_ex1_a_frac_mul[14],
             temp_ex1_a_frac_mul[31],
             temp_ex1_a_frac_mul[49],
             temp_ex1_a_frac_mul[15],
             temp_ex1_a_frac_mul[32],
             temp_ex1_a_frac_mul[50],
             temp_ex1_a_frac_mul[16],
             temp_ex1_a_frac_mul[33],
             temp_ex1_a_frac_mul[51],
             temp_ex1_a_frac_mul_17,		// copy of 17 for bit stacking
             temp_ex1_a_frac_mul[34],
             temp_ex1_a_frac_mul[52],
             temp_ex1_a_frac_mul_35}),		// copy of 35 for bit stacking
      //----------------------------------------
      .qb({  ex2_a_frac_mul_b[0],
             ex2_a_frac_mul_b[17],		// real copy of bit 17
             ex2_a_frac_mul_b[35],		// real copy of bit 35
             ex2_a_frac_mul_b[1],
             ex2_a_frac_mul_b[18],
             ex2_a_frac_mul_b[36],
             ex2_a_frac_mul_b[2],
             ex2_a_frac_mul_b[19],
             ex2_a_frac_mul_b[37],
             ex2_a_frac_mul_b[3],
             ex2_a_frac_mul_b[20],
             ex2_a_frac_mul_b[38],
             ex2_a_frac_mul_b[4],
             ex2_a_frac_mul_b[21],
             ex2_a_frac_mul_b[39],
             ex2_a_frac_mul_b[5],
             ex2_a_frac_mul_b[22],
             ex2_a_frac_mul_b[40],
             ex2_a_frac_mul_b[6],
             ex2_a_frac_mul_b[23],
             ex2_a_frac_mul_b[41],
             ex2_a_frac_mul_b[7],
             ex2_a_frac_mul_b[24],
             ex2_a_frac_mul_b[42],
             ex2_a_frac_mul_b[8],
             ex2_a_frac_mul_b[25],
             ex2_a_frac_mul_b[43],
             ex2_a_frac_mul_b[9],
             ex2_a_frac_mul_b[26],
             ex2_a_frac_mul_b[44],
             ex2_a_frac_mul_b[10],
             ex2_a_frac_mul_b[27],
             ex2_a_frac_mul_b[45],
             ex2_a_frac_mul_b[11],
             ex2_a_frac_mul_b[28],
             ex2_a_frac_mul_b[46],
             ex2_a_frac_mul_b[12],
             ex2_a_frac_mul_b[29],
             ex2_a_frac_mul_b[47],
             ex2_a_frac_mul_b[13],
             ex2_a_frac_mul_b[30],
             ex2_a_frac_mul_b[48],
             ex2_a_frac_mul_b[14],
             ex2_a_frac_mul_b[31],
             ex2_a_frac_mul_b[49],
             ex2_a_frac_mul_b[15],
             ex2_a_frac_mul_b[32],
             ex2_a_frac_mul_b[50],
             ex2_a_frac_mul_b[16],
             ex2_a_frac_mul_b[33],
             ex2_a_frac_mul_b[51],
             ex2_a_frac_mul_17_b,		// copy of 17 for bit stacking
             ex2_a_frac_mul_b[34],
             ex2_a_frac_mul_b[52],
             ex2_a_frac_mul_35_b})		// copy of 35 for bit stacking
   );

   assign f_byp_alg_ex2_b_frac[0:52] = (~ex2_b_frac_alg_b[0:52]);
   assign f_byp_fmt_ex2_a_frac[0:52] = (~ex2_a_frac_fmt_b[0:52]);
   assign f_byp_fmt_ex2_c_frac[0:52] = (~ex2_c_frac_fmt_b[0:52]);
   assign f_byp_fmt_ex2_b_frac[0:52] = (~ex2_b_frac_fmt_b[0:52]);
   assign f_byp_mul_ex2_a_frac[0:52] = (~ex2_a_frac_mul_b[0:52]);
   assign f_byp_mul_ex2_a_frac_17 = (~ex2_a_frac_mul_17_b);
   assign f_byp_mul_ex2_a_frac_35 = (~ex2_a_frac_mul_35_b);
   assign f_byp_mul_ex2_c_frac[0:53] = (~ex2_c_frac_mul_b[0:53]);

   //---------------- EXPONENT SIGN ----------------------------------


   tri_inv_nlats #(.WIDTH(14),  .NEEDS_SRESET(0)) ex2_expo_b_alg_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in      --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(ex2_expo_b_alg_si),		//in
      .scanout(ex2_expo_b_alg_so),		//in
      .d({ex1_b_sign_alg_b,
          ex1_b_expo_alg_b[1:13]}),
      .qb({ex2_b_sign_alg,
           ex2_b_expo_alg[1:13]})
   );


   tri_inv_nlats #(.WIDTH(13),   .NEEDS_SRESET(0)) ex2_expo_c_alg_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in      --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(ex2_expo_c_alg_si),		//in
      .scanout(ex2_expo_c_alg_so),		//in
      .d(ex1_c_expo_alg_b[1:13]),
      .qb(ex2_c_expo_alg[1:13])
   );


   tri_inv_nlats #(.WIDTH(13),   .NEEDS_SRESET(0)) ex2_expo_a_alg_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in      --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(ex2_expo_a_alg_si),		//in
      .scanout(ex2_expo_a_alg_so),		//in
      .d(ex1_a_expo_alg_b[1:13]),
      .qb(ex2_a_expo_alg[1:13])
   );


   tri_inv_nlats #(.WIDTH(14),   .NEEDS_SRESET(0)) ex2_expo_b_fmt_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in      --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(ex2_expo_b_fmt_si),		//in
      .scanout(ex2_expo_b_fmt_so),		//in
      .d({ex1_b_sign_fmt_b,
          ex1_b_expo_fmt_b[1:13]}),
      .qb({ex2_b_sign_fmt,
           ex2_b_expo_fmt[1:13]})
   );


   tri_inv_nlats #(.WIDTH(14),  .NEEDS_SRESET(0)) ex2_expo_a_fmt_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in      --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(ex2_expo_a_fmt_si),		//in
      .scanout(ex2_expo_a_fmt_so),		//in
      .d({ex1_a_sign_fmt_b,
          ex1_a_expo_fmt_b[1:13]}),
      .qb({ex2_a_sign_fmt,
           ex2_a_expo_fmt[1:13]})
   );


   tri_inv_nlats #(.WIDTH(14),  .NEEDS_SRESET(0)) ex2_expo_c_fmt_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in      --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(ex2_expo_c_fmt_si),		//in
      .scanout(ex2_expo_c_fmt_so),		//in
      .d({ex1_c_sign_fmt_b,
          ex1_c_expo_fmt_b[1:13]}),
      .qb({ex2_c_sign_fmt,
           ex2_c_expo_fmt[1:13]})
   );


   tri_inv_nlats #(.WIDTH(14), .NEEDS_SRESET(0)) ex2_expo_b_eie_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in      --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(ex2_expo_b_eie_si),		//in
      .scanout(ex2_expo_b_eie_so),		//in
      .d({ex1_b_sign_pic_b,
          ex1_b_expo_eie_b[1:13]}),
      .qb({ex2_b_sign_pic,
          ex2_b_expo_eie[1:13]})
   );


   tri_inv_nlats #(.WIDTH(14),.NEEDS_SRESET(0)) ex2_expo_a_eie_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in      --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(ex2_expo_a_eie_si),		//in
      .scanout(ex2_expo_a_eie_so),		//in
      .d({ex1_a_sign_pic_b,
          ex1_a_expo_eie_b[1:13]}),
      .qb({ex2_a_sign_pic,
           ex2_a_expo_eie[1:13]})
   );


   tri_inv_nlats #(.WIDTH(14), .NEEDS_SRESET(0)) ex2_expo_c_eie_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(byp_ex2_lclk),		//in      --lclk.clk
      .d1clk(byp_ex2_d1clk),		//in
      .d2clk(byp_ex2_d2clk),		//in
      .scanin(ex2_expo_c_eie_si),		//in
      .scanout(ex2_expo_c_eie_so),		//in
      .d({ex1_c_sign_pic_b,
          ex1_c_expo_eie_b[1:13]}),
      .qb({ex2_c_sign_pic,
           ex2_c_expo_eie[1:13]})
   );

   assign ex2_b_sign_alg_b = (~ex2_b_sign_alg);
   assign ex2_b_sign_fmt_b = (~ex2_b_sign_fmt);
   assign ex2_a_sign_fmt_b = (~ex2_a_sign_fmt);
   assign ex2_c_sign_fmt_b = (~ex2_c_sign_fmt);
   assign ex2_b_sign_pic_b = (~ex2_b_sign_pic);
   assign ex2_a_sign_pic_b = (~ex2_a_sign_pic);
   assign ex2_c_sign_pic_b = (~ex2_c_sign_pic);

   assign ex2_b_expo_alg_b[1:13] = (~ex2_b_expo_alg[1:13]);
   assign ex2_c_expo_alg_b[1:13] = (~ex2_c_expo_alg[1:13]);
   assign ex2_a_expo_alg_b[1:13] = (~ex2_a_expo_alg[1:13]);
   assign ex2_b_expo_fmt_b[1:13] = (~ex2_b_expo_fmt[1:13]);
   assign ex2_c_expo_fmt_b[1:13] = (~ex2_c_expo_fmt[1:13]);
   assign ex2_a_expo_fmt_b[1:13] = (~ex2_a_expo_fmt[1:13]);
   assign ex2_b_expo_eie_b[1:13] = (~ex2_b_expo_eie[1:13]);
   assign ex2_c_expo_eie_b[1:13] = (~ex2_c_expo_eie[1:13]);
   assign ex2_a_expo_eie_b[1:13] = (~ex2_a_expo_eie[1:13]);

   assign f_byp_alg_ex2_b_sign = (~ex2_b_sign_alg_b);
   assign f_byp_alg_ex2_b_expo[1:13] = (~ex2_b_expo_alg_b[1:13]);
   assign f_byp_alg_ex2_c_expo[1:13] = (~ex2_c_expo_alg_b[1:13]);
   assign f_byp_alg_ex2_a_expo[1:13] = (~ex2_a_expo_alg_b[1:13]);

   assign f_byp_fmt_ex2_a_sign = (~ex2_a_sign_fmt_b);
   assign f_byp_fmt_ex2_a_expo[1:13] = (~ex2_a_expo_fmt_b[1:13]);
   assign f_byp_fmt_ex2_c_sign = (~ex2_c_sign_fmt_b);
   assign f_byp_fmt_ex2_c_expo[1:13] = (~ex2_c_expo_fmt_b[1:13]);
   assign f_byp_fmt_ex2_b_sign = (~ex2_b_sign_fmt_b);
   assign f_byp_fmt_ex2_b_expo[1:13] = (~ex2_b_expo_fmt_b[1:13]);

   assign f_byp_pic_ex2_a_sign = (~ex2_a_sign_pic_b);
   assign f_byp_eie_ex2_a_expo[1:13] = (~ex2_a_expo_eie_b[1:13]);
   assign f_byp_pic_ex2_c_sign = (~ex2_c_sign_pic_b);
   assign f_byp_eie_ex2_c_expo[1:13] = (~ex2_c_expo_eie_b[1:13]);
   assign f_byp_pic_ex2_b_sign = (~ex2_b_sign_pic_b);
   assign f_byp_eie_ex2_b_expo[1:13] = (~ex2_b_expo_eie_b[1:13]);

   //====================================================================
   //== scan chain
   //====================================================================

   assign act_si[0:3] = {act_so[1:3], f_byp_si};
   assign ex2_b_frac_si[0:52] = {ex2_b_frac_so[1:52], act_so[0]};
   assign ex2_frac_a_fmt_si[0:52] = {ex2_frac_a_fmt_so[1:52], ex2_b_frac_so[0]};
   assign ex2_frac_c_fmt_si[0:52] = {ex2_frac_c_fmt_so[1:52], ex2_frac_a_fmt_so[0]};
   assign ex2_frac_b_fmt_si[0:52] = {ex2_frac_b_fmt_so[1:52], ex2_frac_c_fmt_so[0]};
   assign frac_mul_c_si[0:53] = {frac_mul_c_so[1:53], ex2_frac_b_fmt_so[0]};
   assign frac_mul_a_si[0:54] = {frac_mul_a_so[1:54], frac_mul_c_so[0]};
   assign ex2_expo_a_eie_si[0:13] = {ex2_expo_a_eie_so[1:13], frac_mul_a_so[0]};
   assign ex2_expo_c_eie_si[0:13] = {ex2_expo_c_eie_so[1:13], ex2_expo_a_eie_so[0]};
   assign ex2_expo_b_eie_si[0:13] = {ex2_expo_b_eie_so[1:13], ex2_expo_c_eie_so[0]};
   assign ex2_expo_a_fmt_si[0:13] = {ex2_expo_a_fmt_so[1:13], ex2_expo_b_eie_so[0]};
   assign ex2_expo_c_fmt_si[0:13] = {ex2_expo_c_fmt_so[1:13], ex2_expo_a_fmt_so[0]};
   assign ex2_expo_b_fmt_si[0:13] = {ex2_expo_b_fmt_so[1:13], ex2_expo_c_fmt_so[0]};
   assign ex2_expo_b_alg_si[0:13] = {ex2_expo_b_alg_so[1:13], ex2_expo_b_fmt_so[0]};
   assign ex2_expo_a_alg_si[0:12] = {ex2_expo_a_alg_so[1:12], ex2_expo_b_alg_so[0]};
   assign ex2_expo_c_alg_si[0:12] = {ex2_expo_c_alg_so[1:12], ex2_expo_a_alg_so[0]};
   assign f_byp_so = ex2_expo_c_alg_so[0];

endmodule
