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

//  Description:  XU Rotate/Logical Unit
//
//*****************************************************************************

`include "tri_a2o.vh"

module tri_st_rot(
   nclk,
   vdd,
   gnd,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   func_sl_force,
   func_sl_thold_0_b,
   sg_0,
   scan_in,
   scan_out,
   ex1_act,
   ex1_instr,
   ex2_isel_fcn,
   ex2_sel_rot_log,
   ex2_rs0_b,
   ex2_rs1_b,
   ex2_alu_rt,
   ex3_rt,
   ex2_log_rt,
   ex3_xer_ca,
   ex3_cr_eq
);
   input [0:`NCLK_WIDTH-1] nclk;
   inout                 vdd;
   inout                 gnd;
   input                 d_mode_dc;
   input                 delay_lclkr_dc;
   input                 mpw1_dc_b;
   input                 mpw2_dc_b;
   input                 func_sl_force;
   input                 func_sl_thold_0_b;
   input                 sg_0;
   input                 scan_in;
   output                scan_out;

   input                 ex1_act;
   input [0:31]          ex1_instr;

   input [0:3]           ex2_isel_fcn;
   output                ex2_sel_rot_log;

   // Source Inputs
   input [0:63]          ex2_rs0_b;		//rb/ra
   input [0:63]          ex2_rs1_b;		//rs

   // Other ALU Inputs for muxing
   input [0:63]          ex2_alu_rt;

   // EX2 Bypass Tap
   output [0:63]         ex3_rt;
   // EX1 Bypass Tap (logicals only)
   output [0:63]         ex2_log_rt;

   output                ex3_xer_ca;

   output [0:1]          ex3_cr_eq;

   //!! bugspray include: tri_st_rot


   // Latches
   wire                  ex2_act_q;		// input=>ex1_act                      ,act=>1
   wire [0:5]            ex2_mb_ins_q;		// input=>ex1_mb_ins                   ,act=>ex1_act
   wire [0:5]            ex2_me_ins_b_q;		// input=>ex1_me_ins_b                 ,act=>ex1_act
   wire [0:5]            ex2_sh_amt_q;		// input=>ex1_sh_amt                   ,act=>ex1_act
   wire [0:2]            ex2_sh_right_q;		// input=>ex1_sh_rgt_vec               ,act=>ex1_act
   wire [0:2]            ex1_sh_right_vec;
   wire [0:1]            ex2_sh_word_q;		// input=>ex1_sh_word_vec              ,act=>ex1_act
   wire [0:1]            ex1_sh_word_vec;
   wire                  ex2_zm_ins_q;		// input=>ex1_zm_ins                   ,act=>ex1_act
   wire                  ex2_chk_shov_wd_q;		// input=>ex1_chk_shov_wd              ,act=>ex1_act
   wire                  ex2_chk_shov_dw_q;		// input=>ex1_chk_shov_dw              ,act=>ex1_act
   wire                  ex2_use_sh_amt_hi_q;		//                                      act=>ex1_act
   wire                  ex1_use_sh_amt_hi;
   wire                  ex2_use_sh_amt_lo_q;		//                                      act=>ex1_act
   wire                  ex1_use_sh_amt_lo;
   wire                  ex2_use_rb_amt_hi_q;		// input=>ex1_use_rb_amt_hi            ,act=>ex1_act
   wire                  ex2_use_rb_amt_lo_q;		// input=>ex1_use_rb_amt_lo            ,act=>ex1_act
   wire                  ex2_use_me_rb_hi_q;		// input=>ex1_use_me_rb_hi             ,act=>ex1_act
   wire                  ex2_use_me_rb_lo_q;		// input=>ex1_use_me_rb_lo             ,act=>ex1_act
   wire                  ex2_use_mb_rb_hi_q;		// input=>ex1_use_mb_rb_hi             ,act=>ex1_act
   wire                  ex2_use_mb_rb_lo_q;		// input=>ex1_use_mb_rb_lo             ,act=>ex1_act
   wire                  ex2_use_me_ins_hi_q;		// input=>ex1_use_me_ins_hi            ,act=>ex1_act
   wire                  ex2_use_me_ins_lo_q;		// input=>ex1_use_me_ins_lo            ,act=>ex1_act
   wire                  ex2_use_mb_ins_hi_q;		// input=>ex1_use_mb_ins_hi            ,act=>ex1_act
   wire                  ex2_use_mb_ins_lo_q;		// input=>ex1_use_mb_ins_lo            ,act=>ex1_act
   wire                  ex2_ins_prtyw_q;		// input=>ex1_ins_prtyw                ,act=>ex1_act
   wire                  ex2_ins_prtyd_q;		// input=>ex1_ins_prtyd                ,act=>ex1_act
   wire                  ex2_mb_gt_me_q;		// input=>ex1_mb_gt_me                 ,act=>ex1_act
   wire                  ex2_cmp_byte_q;		// input=>ex1_cmp_byt                  ,act=>ex1_act
   wire                  ex2_sgnxtd_byte_q;		// input=>ex1_sgnxtd_byte              ,act=>ex1_act
   wire                  ex2_sgnxtd_half_q;		// input=>ex1_sgnxtd_half              ,act=>ex1_act
   wire                  ex2_sgnxtd_wd_q;		// input=>ex1_sgnxtd_wd                ,act=>ex1_act
   wire                  ex2_sra_wd_q;		// input=>ex1_sra_wd                   ,act=>ex1_act
   wire                  ex2_sra_dw_q;		// input=>ex1_sra_dw                   ,act=>ex1_act
   wire [0:3]            ex2_log_fcn_q;		// input=>ex2_log_fcn_d                ,act=>ex1_act
   wire [0:3]            ex2_log_fcn_d;
   wire                  ex2_sel_rot_log_q;		// input=>ex1_sel_rot_log              ,act=>ex1_act
   wire                  ex3_sh_word_q;		// input=>ex2_sh_word_q(1)             ,act=>ex2_act_q
   wire [0:63]           ex3_rotate_b_q;		//                                      act=>ex2_act_q
   wire [0:63]           ex2_result;
   wire [0:63]           ex3_result_b_q;		//                                      act=>ex2_act_q
   wire [0:63]           ex2_rotate;
   wire [0:63]           ex3_mask_b_q;		//                                      act=>ex2_act_q
   wire [0:63]           ex2_mask;
   wire [0:0]            ex3_sra_se_q;		//                                      act=>ex2_act_q
   wire [0:0]            ex2_sra_se;
   wire [0:0]            dummy_q;
   // Scanchains
   localparam            ex2_act_offset = 0;
   localparam            ex2_mb_ins_offset = ex2_act_offset + 1;
   localparam            ex2_me_ins_b_offset = ex2_mb_ins_offset + 6;
   localparam            ex2_sh_amt_offset = ex2_me_ins_b_offset + 6;
   localparam            ex2_sh_right_offset = ex2_sh_amt_offset + 6;
   localparam            ex2_sh_word_offset = ex2_sh_right_offset + 3;
   localparam            ex2_zm_ins_offset = ex2_sh_word_offset + 2;
   localparam            ex2_chk_shov_wd_offset = ex2_zm_ins_offset + 1;
   localparam            ex2_chk_shov_dw_offset = ex2_chk_shov_wd_offset + 1;
   localparam            ex2_use_sh_amt_hi_offset = ex2_chk_shov_dw_offset + 1;
   localparam            ex2_use_sh_amt_lo_offset = ex2_use_sh_amt_hi_offset + 1;
   localparam            ex2_use_rb_amt_hi_offset = ex2_use_sh_amt_lo_offset + 1;
   localparam            ex2_use_rb_amt_lo_offset = ex2_use_rb_amt_hi_offset + 1;
   localparam            ex2_use_me_rb_hi_offset = ex2_use_rb_amt_lo_offset + 1;
   localparam            ex2_use_me_rb_lo_offset = ex2_use_me_rb_hi_offset + 1;
   localparam            ex2_use_mb_rb_hi_offset = ex2_use_me_rb_lo_offset + 1;
   localparam            ex2_use_mb_rb_lo_offset = ex2_use_mb_rb_hi_offset + 1;
   localparam            ex2_use_me_ins_hi_offset = ex2_use_mb_rb_lo_offset + 1;
   localparam            ex2_use_me_ins_lo_offset = ex2_use_me_ins_hi_offset + 1;
   localparam            ex2_use_mb_ins_hi_offset = ex2_use_me_ins_lo_offset + 1;
   localparam            ex2_use_mb_ins_lo_offset = ex2_use_mb_ins_hi_offset + 1;
   localparam            ex2_ins_prtyw_offset = ex2_use_mb_ins_lo_offset + 1;
   localparam            ex2_ins_prtyd_offset = ex2_ins_prtyw_offset + 1;
   localparam            ex2_mb_gt_me_offset = ex2_ins_prtyd_offset + 1;
   localparam            ex2_cmp_byte_offset = ex2_mb_gt_me_offset + 1;
   localparam            ex2_sgnxtd_byte_offset = ex2_cmp_byte_offset + 1;
   localparam            ex2_sgnxtd_half_offset = ex2_sgnxtd_byte_offset + 1;
   localparam            ex2_sgnxtd_wd_offset = ex2_sgnxtd_half_offset + 1;
   localparam            ex2_sra_wd_offset = ex2_sgnxtd_wd_offset + 1;
   localparam            ex2_sra_dw_offset = ex2_sra_wd_offset + 1;
   localparam            ex2_log_fcn_offset = ex2_sra_dw_offset + 1;
   localparam            ex2_sel_rot_log_offset = ex2_log_fcn_offset + 4;
   localparam            ex3_sh_word_offset = ex2_sel_rot_log_offset + 1;
   localparam            ex3_rotate_b_offset = ex3_sh_word_offset + 1;
   localparam            ex3_result_b_offset = ex3_rotate_b_offset + 64;
   localparam            ex3_mask_b_offset = ex3_result_b_offset + 64;
   localparam            ex3_sra_se_offset = ex3_mask_b_offset + 64;
   localparam            dummy_offset = ex3_sra_se_offset + 1;
   localparam            scan_right = dummy_offset + 1;
   wire [0:scan_right-1] siv;
   wire [0:scan_right-1] sov;
   wire [0:`NCLK_WIDTH-1] rot_lclk_int;
   wire                  rot_d1clk_int;
   wire                  rot_d2clk_int;
   wire                  ex2_zm;
   wire [0:5]            ex2_use_sh_amt;
   wire [0:5]            ex2_use_rb_amt;
   wire [0:5]            ex2_use_me_rb;
   wire [0:5]            ex2_use_mb_rb;
   wire [0:5]            ex2_use_me_ins;
   wire [0:5]            ex2_use_mb_ins;
   wire [0:5]            ex2_sh_amt0_b;
   wire [0:5]            ex2_sh_amt1_b;
   wire [0:5]            ex2_sh_amt;
   wire [0:5]            ex2_mb0_b;
   wire [0:5]            ex2_mb1_b;
   wire [0:5]            ex2_mb;
   wire [0:5]            ex2_me0;
   wire [0:5]            ex2_me1;
   wire [0:5]            ex2_me_b;
   wire [0:63]           ex2_mask_b;
   wire [0:63]           ex2_insert;
   wire                  ex2_sel_add;
   wire [0:63]           ex2_msk_rot_b;
   wire [0:63]           ex2_msk_ins_b;
   wire [0:63]           ex2_msk_rot;
   wire [0:63]           ex2_msk_ins;
   wire [0:63]           ex2_result_0_b;
   wire [0:63]           ex2_result_1_b;
   wire [0:63]           ex2_result_2_b;
   wire [0:63]           ca_root_b;
   wire                  ca_or_hi;
   wire                  ca_or_lo;
   wire                  ex2_act_unqiue;
   wire [0:63]           ex2_ins_rs0;
   wire [0:63]           ex2_ins_rs1;
   wire [0:63]           ex2_rot_rs0;
   wire [57:63]          ex2_rot_rs1;
   wire [0:63]           ex3_result_q;
   wire [0:63]           ex3_rotate_q;
   wire                  ex1_zm_ins;
   wire [0:5]            ex1_mb_ins;
   wire [0:5]            ex1_me_ins_b;
   wire [0:5]            ex1_sh_amt;
   wire                  ex1_sh_right;
   wire                  ex1_sh_word;
   wire                  ex1_use_rb_amt_hi;
   wire                  ex1_use_rb_amt_lo;
   wire                  ex1_use_me_rb_hi;
   wire                  ex1_use_me_rb_lo;
   wire                  ex1_use_mb_rb_hi;
   wire                  ex1_use_mb_rb_lo;
   wire                  ex1_use_me_ins_hi;
   wire                  ex1_use_me_ins_lo;
   wire                  ex1_use_mb_ins_hi;
   wire                  ex1_use_mb_ins_lo;
   wire                  ex1_ins_prtyw;
   wire                  ex1_ins_prtyd;
   wire                  ex1_chk_shov_wd;
   wire                  ex1_chk_shov_dw;
   wire                  ex1_mb_gt_me;
   wire                  ex1_cmp_byt;
   wire                  ex1_sgnxtd_byte;
   wire                  ex1_sgnxtd_half;
   wire                  ex1_sgnxtd_wd;
   wire                  ex1_sra_wd;
   wire                  ex1_sra_dw;
   wire [0:3]            ex1_log_fcn;
   wire [0:3]            ex2_log_fcn;
   wire                  ex1_sel_rot_log;

   //-------------------------------------------------------------------
   // Source Buffering
   //-------------------------------------------------------------------
   assign ex2_ins_rs0 = (~ex2_rs0_b);
   assign ex2_ins_rs1 = (~ex2_rs1_b);
   assign ex2_rot_rs0 = (~ex2_rs0_b);
   assign ex2_rot_rs1 = (~ex2_rs1_b[57:63]);

   //-------------------------------------------------------------------
   // Rotator / merge control generation
   //-------------------------------------------------------------------

   tri_st_rot_dec dec(
      .i(ex1_instr),
      .ex1_zm_ins(ex1_zm_ins),
      .ex1_mb_ins(ex1_mb_ins),
      .ex1_me_ins_b(ex1_me_ins_b),
      .ex1_sh_amt(ex1_sh_amt),
      .ex1_sh_right(ex1_sh_right),
      .ex1_sh_word(ex1_sh_word),
      .ex1_use_rb_amt_hi(ex1_use_rb_amt_hi),
      .ex1_use_rb_amt_lo(ex1_use_rb_amt_lo),
      .ex1_use_me_rb_hi(ex1_use_me_rb_hi),
      .ex1_use_me_rb_lo(ex1_use_me_rb_lo),
      .ex1_use_mb_rb_hi(ex1_use_mb_rb_hi),
      .ex1_use_mb_rb_lo(ex1_use_mb_rb_lo),
      .ex1_use_me_ins_hi(ex1_use_me_ins_hi),
      .ex1_use_me_ins_lo(ex1_use_me_ins_lo),
      .ex1_use_mb_ins_hi(ex1_use_mb_ins_hi),
      .ex1_use_mb_ins_lo(ex1_use_mb_ins_lo),
      .ex1_ins_prtyw(ex1_ins_prtyw),
      .ex1_ins_prtyd(ex1_ins_prtyd),
      .ex1_chk_shov_wd(ex1_chk_shov_wd),
      .ex1_chk_shov_dw(ex1_chk_shov_dw),
      .ex1_mb_gt_me(ex1_mb_gt_me),
      .ex1_cmp_byt(ex1_cmp_byt),
      .ex1_sgnxtd_byte(ex1_sgnxtd_byte),
      .ex1_sgnxtd_half(ex1_sgnxtd_half),
      .ex1_sgnxtd_wd(ex1_sgnxtd_wd),
      .ex1_sra_dw(ex1_sra_dw),
      .ex1_sra_wd(ex1_sra_wd),
      .ex1_log_fcn(ex1_log_fcn),
      .ex1_sel_rot_log(ex1_sel_rot_log)
   );

   assign ex1_sh_right_vec = {3{ex1_sh_right}};
   assign ex1_sh_word_vec  = {2{ex1_sh_word}};
   assign ex1_use_sh_amt_hi = (~ex1_use_rb_amt_hi);
   assign ex1_use_sh_amt_lo = (~ex1_use_rb_amt_lo);

   assign ex2_use_sh_amt = {ex2_use_sh_amt_hi_q, {5{ex2_use_sh_amt_lo_q}}};
   assign ex2_use_rb_amt = {ex2_use_rb_amt_hi_q, {5{ex2_use_rb_amt_lo_q}}};
   assign ex2_use_me_rb  = {ex2_use_me_rb_hi_q,  {5{ex2_use_me_rb_lo_q}}};
   assign ex2_use_mb_rb  = {ex2_use_mb_rb_hi_q,  {5{ex2_use_mb_rb_lo_q}}};
   assign ex2_use_me_ins = {ex2_use_me_ins_hi_q, {5{ex2_use_me_ins_lo_q}}};
   assign ex2_use_mb_ins = {ex2_use_mb_ins_hi_q, {5{ex2_use_mb_ins_lo_q}}};

   // instr does not use the rotator (dont care if adder used)
   assign ex2_zm = (ex2_zm_ins_q) | (ex2_chk_shov_wd_q & ex2_rot_rs1[58]) | (ex2_chk_shov_dw_q & ex2_rot_rs1[57]);		//       word shift with amount from RB <amount shifts out all the bits>
   // doubleword shift with amount from RB <amount shifts out all the bits>

   assign ex2_sh_amt0_b = ~(ex2_rot_rs1[58:63] & ex2_use_rb_amt);
   assign ex2_sh_amt1_b = ~(ex2_sh_amt_q & ex2_use_sh_amt);

   assign ex2_sh_amt = ~(ex2_sh_amt0_b & ex2_sh_amt1_b);

   assign ex2_mb0_b = ~(ex2_rot_rs1[58:63] & ex2_use_mb_rb);
   assign ex2_mb1_b = ~(ex2_mb_ins_q & ex2_use_mb_ins);

   assign ex2_mb = ~(ex2_mb0_b & ex2_mb1_b);

   assign ex2_me0 = ~(ex2_rot_rs1[58:63] & ex2_use_me_rb);
   assign ex2_me1 = ~(ex2_me_ins_b_q & ex2_use_me_ins);

   assign ex2_me_b = ~(ex2_me0 & ex2_me1);

   //-------------------------------------------------------------------
   // Mask unit
   //-------------------------------------------------------------------

   tri_st_rot_mask msk(
      .mb(ex2_mb),
      .me_b(ex2_me_b),
      .zm(ex2_zm),
      .mb_gt_me(ex2_mb_gt_me_q),
      .mask(ex2_mask)
   );

   //-------------------------------------------------------------------
   // Insert data (includes logicals, sign extend, cmpb)
   //-------------------------------------------------------------------
   assign ex2_log_fcn_d = ex1_log_fcn;
   assign ex2_log_fcn = ex2_log_fcn_q | ex2_isel_fcn;


   tri_st_rot_ins ins(
      .ins_log_fcn(ex2_log_fcn),
      .ins_cmp_byt(ex2_cmp_byte_q),
      .ins_sra_dw(ex2_sra_dw_q),
      .ins_sra_wd(ex2_sra_wd_q),
      .ins_xtd_byte(ex2_sgnxtd_byte_q),
      .ins_xtd_half(ex2_sgnxtd_half_q),
      .ins_xtd_wd(ex2_sgnxtd_wd_q),
      .ins_prtyw(ex2_ins_prtyw_q),
      .ins_prtyd(ex2_ins_prtyd_q),
      .data0_i(ex2_ins_rs0),
      .data1_i(ex2_ins_rs1),
      .mrg_byp_log(ex2_log_rt),
      .res_ins(ex2_insert)
   );

   //-------------------------------------------------------------------
   // Rotate unit
   //-------------------------------------------------------------------

   tri_st_rot_rol64 rol64(
      .word(ex2_sh_word_q),
      .right(ex2_sh_right_q),
      .amt(ex2_sh_amt),
      .data_i(ex2_rot_rs0),
      .res_rot(ex2_rotate)
   );

   //-------------------------------------------------------------------
   // Final muxing
   //-------------------------------------------------------------------
   assign ex2_mask_b = (~ex2_mask);
   assign ex2_sel_add = (~ex2_sel_rot_log_q);

   assign ex2_msk_rot_b = ~(ex2_mask & {64{ex2_sel_rot_log_q}});
   assign ex2_msk_ins_b = ~(ex2_mask_b & {64{ex2_sel_rot_log_q}});

   assign ex2_msk_rot = (~ex2_msk_rot_b);
   assign ex2_msk_ins = (~ex2_msk_ins_b);

   assign ex2_result_0_b = ~(ex2_rotate & ex2_msk_rot);
   assign ex2_result_1_b = ~(ex2_insert & ex2_msk_ins);
   assign ex2_result_2_b = ~(ex2_alu_rt & {64{ex2_sel_add}});
   assign ex2_result = (~(ex2_result_0_b & ex2_result_1_b & ex2_result_2_b));

   assign ex3_result_q = (~ex3_result_b_q);

   assign ex3_rt = ex3_result_q;

   //-------------------------------------------------------------------
   // CA Generation
   //-------------------------------------------------------------------

   tri_st_or3232_b or3232(
      .d_b(ca_root_b),
      .or_hi(ca_or_hi),
      .or_lo(ca_or_lo)
   );

   assign ex3_rotate_q = (~ex3_rotate_b_q);
   assign ca_root_b = (~(ex3_rotate_q & ex3_mask_b_q));

   assign ex2_sra_se[0] = (ex2_ins_rs0[0] & (~ex2_sh_word_q[0])) | (ex2_ins_rs0[32] & ex2_sh_word_q[0]);

   assign ex3_xer_ca = (ca_or_lo & ex3_sra_se_q[0] & ex3_sh_word_q) | ((ca_or_lo | ca_or_hi) & ex3_sra_se_q[0] & (~ex3_sh_word_q));

   assign ex3_cr_eq = {ca_or_hi, ca_or_lo};

   assign ex2_sel_rot_log = ex2_sel_rot_log_q;

   // To generate a unique LCB for placement
   assign ex2_act_unqiue = ex2_act_q | dummy_q[0];

   //-------------------------------------------------------------------
   // Latch Instances
   //-------------------------------------------------------------------

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_act_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_act_offset]),
      .scout(sov[ex2_act_offset]),
      .din(ex1_act),
      .dout(ex2_act_q)
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) ex2_mb_ins_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_mb_ins_offset:ex2_mb_ins_offset + 6 - 1]),
      .scout(sov[ex2_mb_ins_offset:ex2_mb_ins_offset + 6 - 1]),
      .din(ex1_mb_ins),
      .dout(ex2_mb_ins_q)
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) ex2_me_ins_b_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_me_ins_b_offset:ex2_me_ins_b_offset + 6 - 1]),
      .scout(sov[ex2_me_ins_b_offset:ex2_me_ins_b_offset + 6 - 1]),
      .din(ex1_me_ins_b),
      .dout(ex2_me_ins_b_q)
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) ex2_sh_amt_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_sh_amt_offset:ex2_sh_amt_offset + 6 - 1]),
      .scout(sov[ex2_sh_amt_offset:ex2_sh_amt_offset + 6 - 1]),
      .din(ex1_sh_amt),
      .dout(ex2_sh_amt_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex2_sh_right_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_sh_right_offset:ex2_sh_right_offset + 3 - 1]),
      .scout(sov[ex2_sh_right_offset:ex2_sh_right_offset + 3 - 1]),
      .din(ex1_sh_right_vec),
      .dout(ex2_sh_right_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex2_sh_word_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_sh_word_offset:ex2_sh_word_offset + 2 - 1]),
      .scout(sov[ex2_sh_word_offset:ex2_sh_word_offset + 2 - 1]),
      .din(ex1_sh_word_vec),
      .dout(ex2_sh_word_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_zm_ins_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_zm_ins_offset]),
      .scout(sov[ex2_zm_ins_offset]),
      .din(ex1_zm_ins),
      .dout(ex2_zm_ins_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_chk_shov_wd_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_chk_shov_wd_offset]),
      .scout(sov[ex2_chk_shov_wd_offset]),
      .din(ex1_chk_shov_wd),
      .dout(ex2_chk_shov_wd_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_chk_shov_dw_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_chk_shov_dw_offset]),
      .scout(sov[ex2_chk_shov_dw_offset]),
      .din(ex1_chk_shov_dw),
      .dout(ex2_chk_shov_dw_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_use_sh_amt_hi_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_use_sh_amt_hi_offset]),
      .scout(sov[ex2_use_sh_amt_hi_offset]),
      .din(ex1_use_sh_amt_hi),
      .dout(ex2_use_sh_amt_hi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_use_sh_amt_lo_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_use_sh_amt_lo_offset]),
      .scout(sov[ex2_use_sh_amt_lo_offset]),
      .din(ex1_use_sh_amt_lo),
      .dout(ex2_use_sh_amt_lo_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_use_rb_amt_hi_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_use_rb_amt_hi_offset]),
      .scout(sov[ex2_use_rb_amt_hi_offset]),
      .din(ex1_use_rb_amt_hi),
      .dout(ex2_use_rb_amt_hi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_use_rb_amt_lo_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_use_rb_amt_lo_offset]),
      .scout(sov[ex2_use_rb_amt_lo_offset]),
      .din(ex1_use_rb_amt_lo),
      .dout(ex2_use_rb_amt_lo_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_use_me_rb_hi_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_use_me_rb_hi_offset]),
      .scout(sov[ex2_use_me_rb_hi_offset]),
      .din(ex1_use_me_rb_hi),
      .dout(ex2_use_me_rb_hi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_use_me_rb_lo_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_use_me_rb_lo_offset]),
      .scout(sov[ex2_use_me_rb_lo_offset]),
      .din(ex1_use_me_rb_lo),
      .dout(ex2_use_me_rb_lo_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_use_mb_rb_hi_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_use_mb_rb_hi_offset]),
      .scout(sov[ex2_use_mb_rb_hi_offset]),
      .din(ex1_use_mb_rb_hi),
      .dout(ex2_use_mb_rb_hi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_use_mb_rb_lo_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_use_mb_rb_lo_offset]),
      .scout(sov[ex2_use_mb_rb_lo_offset]),
      .din(ex1_use_mb_rb_lo),
      .dout(ex2_use_mb_rb_lo_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_use_me_ins_hi_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_use_me_ins_hi_offset]),
      .scout(sov[ex2_use_me_ins_hi_offset]),
      .din(ex1_use_me_ins_hi),
      .dout(ex2_use_me_ins_hi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_use_me_ins_lo_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_use_me_ins_lo_offset]),
      .scout(sov[ex2_use_me_ins_lo_offset]),
      .din(ex1_use_me_ins_lo),
      .dout(ex2_use_me_ins_lo_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_use_mb_ins_hi_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_use_mb_ins_hi_offset]),
      .scout(sov[ex2_use_mb_ins_hi_offset]),
      .din(ex1_use_mb_ins_hi),
      .dout(ex2_use_mb_ins_hi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_use_mb_ins_lo_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_use_mb_ins_lo_offset]),
      .scout(sov[ex2_use_mb_ins_lo_offset]),
      .din(ex1_use_mb_ins_lo),
      .dout(ex2_use_mb_ins_lo_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ins_prtyw_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ins_prtyw_offset]),
      .scout(sov[ex2_ins_prtyw_offset]),
      .din(ex1_ins_prtyw),
      .dout(ex2_ins_prtyw_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ins_prtyd_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ins_prtyd_offset]),
      .scout(sov[ex2_ins_prtyd_offset]),
      .din(ex1_ins_prtyd),
      .dout(ex2_ins_prtyd_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_mb_gt_me_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_mb_gt_me_offset]),
      .scout(sov[ex2_mb_gt_me_offset]),
      .din(ex1_mb_gt_me),
      .dout(ex2_mb_gt_me_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_cmp_byte_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_cmp_byte_offset]),
      .scout(sov[ex2_cmp_byte_offset]),
      .din(ex1_cmp_byt),
      .dout(ex2_cmp_byte_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sgnxtd_byte_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_sgnxtd_byte_offset]),
      .scout(sov[ex2_sgnxtd_byte_offset]),
      .din(ex1_sgnxtd_byte),
      .dout(ex2_sgnxtd_byte_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sgnxtd_half_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_sgnxtd_half_offset]),
      .scout(sov[ex2_sgnxtd_half_offset]),
      .din(ex1_sgnxtd_half),
      .dout(ex2_sgnxtd_half_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sgnxtd_wd_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_sgnxtd_wd_offset]),
      .scout(sov[ex2_sgnxtd_wd_offset]),
      .din(ex1_sgnxtd_wd),
      .dout(ex2_sgnxtd_wd_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sra_wd_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_sra_wd_offset]),
      .scout(sov[ex2_sra_wd_offset]),
      .din(ex1_sra_wd),
      .dout(ex2_sra_wd_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sra_dw_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_sra_dw_offset]),
      .scout(sov[ex2_sra_dw_offset]),
      .din(ex1_sra_dw),
      .dout(ex2_sra_dw_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex2_log_fcn_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_log_fcn_offset:ex2_log_fcn_offset + 4 - 1]),
      .scout(sov[ex2_log_fcn_offset:ex2_log_fcn_offset + 4 - 1]),
      .din(ex2_log_fcn_d),
      .dout(ex2_log_fcn_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sel_rot_log_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_sel_rot_log_offset]),
      .scout(sov[ex2_sel_rot_log_offset]),
      .din(ex1_sel_rot_log),
      .dout(ex2_sel_rot_log_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_sh_word_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_sh_word_offset]),
      .scout(sov[ex3_sh_word_offset]),
      .din(ex2_sh_word_q[1]),
      .dout(ex3_sh_word_q)
   );
   //-------------------------------------------------------------------
   // Placed Latches
   //-------------------------------------------------------------------

   tri_lcbnd ex3_mrg_lcb(
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act_unqiue),
      .nclk(nclk),
      .force_t(func_sl_force),
      .thold_b(func_sl_thold_0_b),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .sg(sg_0),
      .lclk(rot_lclk_int),
      .d1clk(rot_d1clk_int),
      .d2clk(rot_d2clk_int)
   );


   tri_inv_nlats #(.WIDTH(64), .BTR("NLI0001_X1_A12TH"), .INIT(0)) rot_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(rot_lclk_int),
      .d1clk(rot_d1clk_int),
      .d2clk(rot_d2clk_int),
      .scanin(siv[ex3_rotate_b_offset:ex3_rotate_b_offset + 64 - 1]),
      .scanout(sov[ex3_rotate_b_offset:ex3_rotate_b_offset + 64 - 1]),
      .d(ex2_rotate),
      .qb(ex3_rotate_b_q)
   );

   tri_inv_nlats #(.WIDTH(64), .BTR("NLI0001_X2_A12TH"), .INIT(0)) res_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(rot_lclk_int),
      .d1clk(rot_d1clk_int),
      .d2clk(rot_d2clk_int),
      .scanin(siv[ex3_result_b_offset:ex3_result_b_offset + 64 - 1]),
      .scanout(sov[ex3_result_b_offset:ex3_result_b_offset + 64 - 1]),
      .d(ex2_result),
      .qb(ex3_result_b_q)
   );

   tri_inv_nlats #(.WIDTH(64), .BTR("NLI0001_X1_A12TH"), .INIT(0)) msk_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(rot_lclk_int),
      .d1clk(rot_d1clk_int),
      .d2clk(rot_d2clk_int),
      .scanin(siv[ex3_mask_b_offset:ex3_mask_b_offset + 64 - 1]),
      .scanout(sov[ex3_mask_b_offset:ex3_mask_b_offset + 64 - 1]),
      .d(ex2_mask),
      .qb(ex3_mask_b_q)
   );
   //-------------------------------------------------------------------
   // End Placed Latches
   //-------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_sra_se_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_sra_se_offset:ex3_sra_se_offset + 1 - 1]),
      .scout(sov[ex3_sra_se_offset:ex3_sra_se_offset + 1 - 1]),
      .din(ex2_sra_se),
      .dout(ex3_sra_se_q)
   );


   tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) dummy_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(1'b0),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[dummy_offset:dummy_offset + 1 - 1]),
      .scout(sov[dummy_offset:dummy_offset + 1 - 1]),
      .din(dummy_q),
      .dout(dummy_q)
   );

   assign siv[0:scan_right - 1] = {sov[1:scan_right - 1], scan_in};
   assign scan_out = sov[0];



endmodule
