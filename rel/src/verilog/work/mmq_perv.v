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

// *********************************************************************
//
// This is the ENTITY for mmq_perv (pervasive logic)
//
// *********************************************************************

`timescale 1 ns / 1 ns

`include "tri_a2o.vh"
`include "mmu_a2o.vh"

module mmq_perv(

   inout                                   vdd,
   inout                                   gnd,
    (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]                  nclk,

   input [0:1]  pc_mm_sg_3,
   input [0:1]  pc_mm_func_sl_thold_3,
   input [0:1]  pc_mm_func_slp_sl_thold_3,
   input        pc_mm_gptr_sl_thold_3,
   input        pc_mm_fce_3,

   input        pc_mm_time_sl_thold_3,
   input        pc_mm_repr_sl_thold_3,
   input        pc_mm_abst_sl_thold_3,
   input        pc_mm_abst_slp_sl_thold_3,
   input        pc_mm_cfg_sl_thold_3,
   input        pc_mm_cfg_slp_sl_thold_3,
   input        pc_mm_func_nsl_thold_3,
   input        pc_mm_func_slp_nsl_thold_3,
   input        pc_mm_ary_nsl_thold_3,
   input        pc_mm_ary_slp_nsl_thold_3,

   input        tc_ac_ccflush_dc,
   input        tc_scan_diag_dc,
   input        tc_ac_scan_dis_dc_b,

   output [0:1] pc_sg_0,
   output [0:1] pc_sg_1,
   output [0:1] pc_sg_2,
   output [0:1] pc_func_sl_thold_2,
   output [0:1] pc_func_slp_sl_thold_2,
   output       pc_func_slp_nsl_thold_2,
   output       pc_cfg_sl_thold_2,
   output       pc_cfg_slp_sl_thold_2,
   output       pc_fce_2,

   output       pc_time_sl_thold_0,
   output       pc_repr_sl_thold_0,
   output       pc_abst_sl_thold_0,
   output       pc_abst_slp_sl_thold_0,
   output       pc_ary_nsl_thold_0,
   output       pc_ary_slp_nsl_thold_0,
   output [0:1] pc_func_sl_thold_0,
   output [0:1] pc_func_sl_thold_0_b,
   output [0:1] pc_func_slp_sl_thold_0,
   output [0:1] pc_func_slp_sl_thold_0_b,

   output       lcb_clkoff_dc_b,
   output       lcb_act_dis_dc,
   output       lcb_d_mode_dc,
   output [0:4] lcb_delay_lclkr_dc,
   output [0:4] lcb_mpw1_dc_b,
   output       lcb_mpw2_dc_b,
   output       g6t_gptr_lcb_clkoff_dc_b,
   output       g6t_gptr_lcb_act_dis_dc,
   output       g6t_gptr_lcb_d_mode_dc,
   output [0:4] g6t_gptr_lcb_delay_lclkr_dc,
   output [0:4] g6t_gptr_lcb_mpw1_dc_b,
   output       g6t_gptr_lcb_mpw2_dc_b,
   output       g8t_gptr_lcb_clkoff_dc_b,
   output       g8t_gptr_lcb_act_dis_dc,
   output       g8t_gptr_lcb_d_mode_dc,
   output [0:4] g8t_gptr_lcb_delay_lclkr_dc,
   output [0:4] g8t_gptr_lcb_mpw1_dc_b,
   output       g8t_gptr_lcb_mpw2_dc_b,

   // abist engine controls for arrays from pervasive
   input [0:3]  pc_mm_abist_dcomp_g6t_2r,
   input [0:3]  pc_mm_abist_di_0,
   input [0:3]  pc_mm_abist_di_g6t_2r,
   input        pc_mm_abist_ena_dc,
   input        pc_mm_abist_g6t_r_wb,
   input        pc_mm_abist_g8t1p_renb_0,
   input        pc_mm_abist_g8t_bw_0,
   input        pc_mm_abist_g8t_bw_1,
   input [0:3]  pc_mm_abist_g8t_dcomp,
   input        pc_mm_abist_g8t_wenb,
   input [0:9]  pc_mm_abist_raddr_0,
   input [0:9]  pc_mm_abist_waddr_0,
   input        pc_mm_abist_wl128_comp_ena,

   output       pc_mm_abist_g8t_wenb_q,
   output       pc_mm_abist_g8t1p_renb_0_q,
   output [0:3] pc_mm_abist_di_0_q,
   output       pc_mm_abist_g8t_bw_1_q,
   output       pc_mm_abist_g8t_bw_0_q,
   output [0:9] pc_mm_abist_waddr_0_q,
   output [0:9] pc_mm_abist_raddr_0_q,
   output       pc_mm_abist_wl128_comp_ena_q,
   output [0:3] pc_mm_abist_g8t_dcomp_q,
   output [0:3] pc_mm_abist_dcomp_g6t_2r_q,
   output [0:3] pc_mm_abist_di_g6t_2r_q,
   output       pc_mm_abist_g6t_r_wb_q,

   // BOLT-ON pervasive stuff for asic
   input        pc_mm_bolt_sl_thold_3,
   input        pc_mm_bo_enable_3,		// general bolt-on enable
   output       pc_mm_bolt_sl_thold_0,
   output       pc_mm_bo_enable_2,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input        gptr_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output       gptr_scan_out,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input        time_scan_in,
   output       time_scan_in_int,
   input        time_scan_out_int,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output       time_scan_out,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:9]  func_scan_in,
   output [0:9] func_scan_in_int,
   input [0:9]  func_scan_out_int,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:9] func_scan_out,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input        repr_scan_in,
   output       repr_scan_in_int,
   input        repr_scan_out_int,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output       repr_scan_out,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:1]  abst_scan_in,
   output [0:1] abst_scan_in_int,
   input [0:1]  abst_scan_out_int,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:1] abst_scan_out,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input        bcfg_scan_in,		// config latches that are setup same on all cores
   output       bcfg_scan_in_int,
   input        bcfg_scan_out_int,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output       bcfg_scan_out,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input        ccfg_scan_in,		// config latches that could be setup differently on multiple cores
   output       ccfg_scan_in_int,
   input        ccfg_scan_out_int,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output       ccfg_scan_out,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input        dcfg_scan_in,
   output       dcfg_scan_in_int,
   input        dcfg_scan_out_int,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output       dcfg_scan_out

);

      wire         tidn;
      wire         tiup;

      wire [0:1]   pc_func_sl_thold_2_int;
      wire [0:1]   pc_func_slp_sl_thold_2_int;
      wire [0:1]   pc_sg_2_int;
      wire         pc_gptr_sl_thold_2_int;
      wire         pc_fce_2_int;
      wire         pc_time_sl_thold_2_int;
      wire         pc_repr_sl_thold_2_int;
      wire         pc_abst_sl_thold_2_int;
      wire         pc_abst_slp_sl_thold_2_int;
      wire         pc_cfg_sl_thold_2_int;
      wire         pc_cfg_slp_sl_thold_2_int;
      wire         pc_func_nsl_thold_2_int;
      wire         pc_func_slp_nsl_thold_2_int;
      wire         pc_ary_nsl_thold_2_int;
      wire         pc_ary_slp_nsl_thold_2_int;
      wire         pc_mm_bolt_sl_thold_2_int;

      wire [0:1]   pc_func_sl_thold_1_int;
      wire [0:1]   pc_func_slp_sl_thold_1_int;
      wire [0:1]   pc_sg_1_int;
      wire         pc_gptr_sl_thold_1_int;
      wire         pc_fce_1_int;
      wire         pc_time_sl_thold_1_int;
      wire         pc_repr_sl_thold_1_int;
      wire         pc_abst_sl_thold_1_int;
      wire         pc_abst_slp_sl_thold_1_int;
      wire         pc_cfg_sl_thold_1_int;
      wire         pc_cfg_slp_sl_thold_1_int;
      wire         pc_func_nsl_thold_1_int;
      wire         pc_func_slp_nsl_thold_1_int;
      wire         pc_ary_nsl_thold_1_int;
      wire         pc_ary_slp_nsl_thold_1_int;
      wire         pc_mm_bolt_sl_thold_1_int;

      wire [0:1]   pc_func_sl_thold_0_int;
      wire [0:1]   pc_func_slp_sl_thold_0_int;
      wire [0:1]   pc_sg_0_int;
      wire         pc_gptr_sl_thold_0_int;
      wire         pc_fce_0_int;
      wire         pc_time_sl_thold_0_int;
      wire         pc_repr_sl_thold_0_int;
      wire         pc_abst_sl_thold_0_int;
      wire         pc_abst_slp_sl_thold_0_int;
      wire         pc_cfg_sl_thold_0_int;
      wire         pc_cfg_slp_sl_thold_0_int;
      wire         pc_func_nsl_thold_0_int;
      wire         pc_func_slp_nsl_thold_0_int;
      wire         pc_ary_nsl_thold_0_int;
      wire         pc_ary_slp_nsl_thold_0_int;

      wire [0:1]   pc_func_sl_thold_0_b_int;
      wire [0:1]   pc_func_slp_sl_thold_0_b_int;
      wire [0:1]   pc_func_slp_sl_force_int;
      wire [0:1]   pc_func_sl_force_int;

      wire [0:1]   abst_scan_in_q;
      wire [0:1]   abst_scan_out_q;
      wire         time_scan_in_q;
      wire         time_scan_out_q;
      wire         repr_scan_in_q;
      wire         repr_scan_out_q;
      wire         gptr_scan_in_q;
      wire         gptr_scan_out_int;
      wire         gptr_scan_out_q;
      wire [0:1]   gptr_scan_lcbctrl;
      wire         bcfg_scan_in_q;
      wire         bcfg_scan_out_q;
      wire         ccfg_scan_in_q;
      wire         ccfg_scan_out_q;
      wire         dcfg_scan_in_q;
      wire         dcfg_scan_out_q;
      wire [0:9]   func_scan_in_q;
      wire [0:9]   func_scan_out_q;

      wire [0:1]   slat_force;
      wire         abst_slat_thold_b;
      wire         abst_slat_d2clk;
      wire [0:`NCLK_WIDTH-1]         abst_slat_lclk;
      wire         time_slat_thold_b;
      wire         time_slat_d2clk;
      wire [0:`NCLK_WIDTH-1]         time_slat_lclk;
      wire         repr_slat_thold_b;
      wire         repr_slat_d2clk;
      wire [0:`NCLK_WIDTH-1]         repr_slat_lclk;
      wire         gptr_slat_thold_b;
      wire         gptr_slat_d2clk;
      wire [0:`NCLK_WIDTH-1]         gptr_slat_lclk;
      wire         bcfg_slat_thold_b;
      wire         bcfg_slat_d2clk;
      wire [0:`NCLK_WIDTH-1]         bcfg_slat_lclk;
      wire         ccfg_slat_thold_b;
      wire         ccfg_slat_d2clk;
      wire [0:`NCLK_WIDTH-1]         ccfg_slat_lclk;
      wire         dcfg_slat_thold_b;
      wire         dcfg_slat_d2clk;
      wire [0:`NCLK_WIDTH-1]         dcfg_slat_lclk;
      wire         func_slat_thold_b;
      wire         func_slat_d2clk;
      wire [0:`NCLK_WIDTH-1]         func_slat_lclk;

      wire         pc_abst_sl_thold_0_b;
      wire         pc_abst_sl_force;
      wire [0:4]   lcb_delay_lclkr_dc_int;
      wire         lcb_d_mode_dc_int;
      wire [0:4]   lcb_mpw1_dc_b_int;
      wire         lcb_mpw2_dc_b_int;
      wire         lcb_clkoff_dc_b_int;

      wire [0:41]  abist_siv;
      wire [0:41]  abist_sov;

      (* analysis_not_referenced="true" *)
      wire [0:8]   unused_dc;

      (* analysis_not_referenced="true" *)
      wire [0:3] perv_abst_stg_q, perv_abst_stg_q_b;

      (* analysis_not_referenced="true" *)
      wire [0:1] perv_time_stg_q, perv_time_stg_q_b, perv_repr_stg_q, perv_repr_stg_q_b,
                  perv_gptr_stg_q, perv_gptr_stg_q_b, perv_bcfg_stg_q, perv_bcfg_stg_q_b,
                  perv_ccfg_stg_q, perv_ccfg_stg_q_b, perv_dcfg_stg_q, perv_dcfg_stg_q_b;

      (* analysis_not_referenced="true" *)
      wire [0:19] perv_func_stg_q, perv_func_stg_q_b;

      assign tidn = 1'b0;
      assign tiup = 1'b1;


      tri_plat #(.WIDTH(20)) perv_3to2_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ac_ccflush_dc),
         .din( {pc_mm_sg_3[0:1],
                  pc_mm_func_slp_sl_thold_3[0:1],
                  pc_mm_func_sl_thold_3[0:1],
                  pc_mm_gptr_sl_thold_3,
                  pc_mm_fce_3,
                  pc_mm_time_sl_thold_3,
                  pc_mm_repr_sl_thold_3,
                  pc_mm_abst_sl_thold_3,
                  pc_mm_abst_slp_sl_thold_3,
                  pc_mm_cfg_sl_thold_3,
                  pc_mm_cfg_slp_sl_thold_3,
                  pc_mm_func_nsl_thold_3,
                  pc_mm_func_slp_nsl_thold_3,
                  pc_mm_ary_nsl_thold_3,
                  pc_mm_ary_slp_nsl_thold_3,
                  pc_mm_bolt_sl_thold_3,
                  pc_mm_bo_enable_3} ),

         .q( {pc_sg_2_int[0:1],
               pc_func_slp_sl_thold_2_int[0:1],
               pc_func_sl_thold_2_int[0:1],
               pc_gptr_sl_thold_2_int,
               pc_fce_2_int,
               pc_time_sl_thold_2_int,
               pc_repr_sl_thold_2_int,
               pc_abst_sl_thold_2_int,
               pc_abst_slp_sl_thold_2_int,
               pc_cfg_sl_thold_2_int,
               pc_cfg_slp_sl_thold_2_int,
               pc_func_nsl_thold_2_int,
               pc_func_slp_nsl_thold_2_int,
               pc_ary_nsl_thold_2_int,
               pc_ary_slp_nsl_thold_2_int,
               pc_mm_bolt_sl_thold_2_int,
               pc_mm_bo_enable_2} )
      );


      tri_plat #(.WIDTH(19)) perv_2to1_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ac_ccflush_dc),
         .din( {pc_sg_2_int[0:1],
                 pc_func_slp_sl_thold_2_int[0:1],
                 pc_func_sl_thold_2_int[0:1],
                 pc_gptr_sl_thold_2_int,
                 pc_fce_2_int,
                 pc_time_sl_thold_2_int,
                 pc_repr_sl_thold_2_int,
                 pc_abst_sl_thold_2_int,
                 pc_abst_slp_sl_thold_2_int,
                 pc_cfg_sl_thold_2_int,
                 pc_cfg_slp_sl_thold_2_int,
                 pc_func_nsl_thold_2_int,
                 pc_func_slp_nsl_thold_2_int,
                 pc_ary_nsl_thold_2_int,
                 pc_ary_slp_nsl_thold_2_int,
                 pc_mm_bolt_sl_thold_2_int} ),
         .q( {pc_sg_1_int[0:1],
               pc_func_slp_sl_thold_1_int[0:1],
               pc_func_sl_thold_1_int[0:1],
               pc_gptr_sl_thold_1_int,
               pc_fce_1_int,
               pc_time_sl_thold_1_int,
               pc_repr_sl_thold_1_int,
               pc_abst_sl_thold_1_int,
               pc_abst_slp_sl_thold_1_int,
               pc_cfg_sl_thold_1_int,
               pc_cfg_slp_sl_thold_1_int,
               pc_func_nsl_thold_1_int,
               pc_func_slp_nsl_thold_1_int,
               pc_ary_nsl_thold_1_int,
               pc_ary_slp_nsl_thold_1_int,
               pc_mm_bolt_sl_thold_1_int} )
      );


      tri_plat #(.WIDTH(19)) perv_1to0_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ac_ccflush_dc),
         .din( {pc_sg_1_int[0:1],
                  pc_func_slp_sl_thold_1_int[0:1],
                  pc_func_sl_thold_1_int[0:1],
                  pc_gptr_sl_thold_1_int,
                  pc_fce_1_int,
                  pc_time_sl_thold_1_int,
                  pc_repr_sl_thold_1_int,
                  pc_abst_sl_thold_1_int,
                  pc_abst_slp_sl_thold_1_int,
                  pc_cfg_sl_thold_1_int,
                  pc_cfg_slp_sl_thold_1_int,
                  pc_func_nsl_thold_1_int,
                  pc_func_slp_nsl_thold_1_int,
                  pc_ary_nsl_thold_1_int,
                  pc_ary_slp_nsl_thold_1_int,
                  pc_mm_bolt_sl_thold_1_int} ),
         .q( {pc_sg_0_int[0:1],
               pc_func_slp_sl_thold_0_int[0:1],
               pc_func_sl_thold_0_int[0:1],
               pc_gptr_sl_thold_0_int,
               pc_fce_0_int,
               pc_time_sl_thold_0_int,
               pc_repr_sl_thold_0_int,
               pc_abst_sl_thold_0_int,
               pc_abst_slp_sl_thold_0_int,
               pc_cfg_sl_thold_0_int,
               pc_cfg_slp_sl_thold_0_int,
               pc_func_nsl_thold_0_int,
               pc_func_slp_nsl_thold_0_int,
               pc_ary_nsl_thold_0_int,
               pc_ary_slp_nsl_thold_0_int,
               pc_mm_bolt_sl_thold_0} )
      );

      assign pc_time_sl_thold_0 = pc_time_sl_thold_0_int;
      assign pc_abst_sl_thold_0 = pc_abst_sl_thold_0_int;
      assign pc_abst_slp_sl_thold_0 = pc_abst_slp_sl_thold_0_int;
      assign pc_repr_sl_thold_0 = pc_repr_sl_thold_0_int;
      assign pc_ary_nsl_thold_0 = pc_ary_nsl_thold_0_int;
      assign pc_ary_slp_nsl_thold_0 = pc_ary_slp_nsl_thold_0_int;

      assign pc_func_sl_thold_0 = pc_func_sl_thold_0_int;
      assign pc_func_sl_thold_0_b = pc_func_sl_thold_0_b_int;
      assign pc_func_slp_sl_thold_0 = pc_func_slp_sl_thold_0_int;
      assign pc_func_slp_sl_thold_0_b = pc_func_slp_sl_thold_0_b_int;

      assign pc_sg_0 = pc_sg_0_int;
      assign pc_sg_1 = pc_sg_1_int;
      assign pc_sg_2 = pc_sg_2_int;

      assign pc_func_sl_thold_2 = pc_func_sl_thold_2_int;
      assign pc_func_slp_sl_thold_2 = pc_func_slp_sl_thold_2_int;
      assign pc_func_slp_nsl_thold_2 = pc_func_slp_nsl_thold_2_int;
      assign pc_cfg_sl_thold_2 = pc_cfg_sl_thold_2_int;
      assign pc_cfg_slp_sl_thold_2 = pc_cfg_slp_sl_thold_2_int;
      assign pc_fce_2 = pc_fce_2_int;

      assign lcb_clkoff_dc_b = lcb_clkoff_dc_b_int;
      assign lcb_d_mode_dc = lcb_d_mode_dc_int;
      assign lcb_delay_lclkr_dc = lcb_delay_lclkr_dc_int;
      assign lcb_mpw1_dc_b = lcb_mpw1_dc_b_int;
      assign lcb_mpw2_dc_b = lcb_mpw2_dc_b_int;


      tri_lcbcntl_mac  perv_lcbctrl(
         .vdd(vdd),
         .gnd(gnd),
         .sg(pc_sg_0_int[0]),
         .nclk(nclk),
         .scan_in(gptr_scan_in_q),
         .scan_diag_dc(tc_scan_diag_dc),
         .thold(pc_gptr_sl_thold_0_int),
         .clkoff_dc_b(lcb_clkoff_dc_b_int),
         .delay_lclkr_dc(lcb_delay_lclkr_dc_int[0:4]),
         .act_dis_dc(unused_dc[6]),
         .d_mode_dc(lcb_d_mode_dc_int),
         .mpw1_dc_b(lcb_mpw1_dc_b_int[0:4]),
         .mpw2_dc_b(lcb_mpw2_dc_b_int),
         .scan_out(gptr_scan_lcbctrl[0])
      );


      tri_lcbcntl_array_mac  perv_g6t_gptr_lcbctrl(
         .vdd(vdd),
         .gnd(gnd),
         .sg(pc_sg_0_int[1]),
         .nclk(nclk),
         .scan_in(gptr_scan_lcbctrl[0]),
         .scan_diag_dc(tc_scan_diag_dc),
         .thold(pc_gptr_sl_thold_0_int),
         .clkoff_dc_b(g6t_gptr_lcb_clkoff_dc_b),
         .delay_lclkr_dc(g6t_gptr_lcb_delay_lclkr_dc[0:4]),
         .act_dis_dc(unused_dc[7]),
         .d_mode_dc(g6t_gptr_lcb_d_mode_dc),
         .mpw1_dc_b(g6t_gptr_lcb_mpw1_dc_b[0:4]),
         .mpw2_dc_b(g6t_gptr_lcb_mpw2_dc_b),
         .scan_out(gptr_scan_lcbctrl[1])
      );


      tri_lcbcntl_array_mac  perv_g8t_gptr_lcbctrl(
         .vdd(vdd),
         .gnd(gnd),
         .sg(pc_sg_0_int[1]),
         .nclk(nclk),
         .scan_in(gptr_scan_lcbctrl[1]),
         .scan_diag_dc(tc_scan_diag_dc),
         .thold(pc_gptr_sl_thold_0_int),
         .clkoff_dc_b(g8t_gptr_lcb_clkoff_dc_b),
         .delay_lclkr_dc(g8t_gptr_lcb_delay_lclkr_dc[0:4]),
         .act_dis_dc(unused_dc[8]),
         .d_mode_dc(g8t_gptr_lcb_d_mode_dc),
         .mpw1_dc_b(g8t_gptr_lcb_mpw1_dc_b[0:4]),
         .mpw2_dc_b(g8t_gptr_lcb_mpw2_dc_b),
         .scan_out(gptr_scan_out_int)
      );

      //never disable act pins, they are used functionally
      assign lcb_act_dis_dc = 1'b0;
      assign g8t_gptr_lcb_act_dis_dc = 1'b0;
      assign g6t_gptr_lcb_act_dis_dc = 1'b0;

      assign time_scan_in_int = time_scan_in_q;
      assign repr_scan_in_int = repr_scan_in_q;
      assign func_scan_in_int = func_scan_in_q;
      assign bcfg_scan_in_int = bcfg_scan_in_q;
      assign ccfg_scan_in_int = ccfg_scan_in_q;
      assign dcfg_scan_in_int = dcfg_scan_in_q;

      assign time_scan_out = time_scan_out_q & tc_ac_scan_dis_dc_b;
      assign gptr_scan_out = gptr_scan_out_q & tc_ac_scan_dis_dc_b;
      assign repr_scan_out = repr_scan_out_q & tc_ac_scan_dis_dc_b;
      assign func_scan_out = func_scan_out_q & {10{tc_ac_scan_dis_dc_b}};
      assign abst_scan_out = abst_scan_out_q & {2{tc_ac_scan_dis_dc_b}};
      assign bcfg_scan_out = bcfg_scan_out_q & tc_ac_scan_dis_dc_b;
      assign ccfg_scan_out = ccfg_scan_out_q & tc_ac_scan_dis_dc_b;
      assign dcfg_scan_out = dcfg_scan_out_q & tc_ac_scan_dis_dc_b;

      // LCBs for scan only staging latches
      assign slat_force = pc_sg_0_int;
      assign abst_slat_thold_b = (~pc_abst_sl_thold_0_int);
      assign time_slat_thold_b = (~pc_time_sl_thold_0_int);
      assign repr_slat_thold_b = (~pc_repr_sl_thold_0_int);
      assign gptr_slat_thold_b = (~pc_gptr_sl_thold_0_int);
      assign bcfg_slat_thold_b = (~pc_cfg_sl_thold_0_int);
      assign ccfg_slat_thold_b = (~pc_cfg_sl_thold_0_int);
      assign dcfg_slat_thold_b = (~pc_cfg_sl_thold_0_int);
      assign func_slat_thold_b = (~pc_func_sl_thold_0_int[0]);


      tri_lcbs  perv_lcbs_abst(
         .vd(vdd),
         .gd(gnd),
         .delay_lclkr(lcb_delay_lclkr_dc_int[0]),
         .nclk(nclk),
         .force_t(slat_force[1]),
         .thold_b(abst_slat_thold_b),
         .dclk(abst_slat_d2clk),
         .lclk(abst_slat_lclk)
      );


      tri_slat_scan #(.WIDTH(4), .INIT(4'b0000)) perv_abst_stg(
         .vd(vdd),
         .gd(gnd),
         .dclk(abst_slat_d2clk),
         .lclk(abst_slat_lclk),
         .scan_in( {abst_scan_out_int, abst_scan_in} ),
         .scan_out( {abst_scan_out_q, abst_scan_in_q} ),
         .q( perv_abst_stg_q),
         .q_b( perv_abst_stg_q_b)
      );


      tri_lcbs perv_lcbs_time(
         .vd(vdd),
         .gd(gnd),
         .delay_lclkr(lcb_delay_lclkr_dc_int[0]),
         .nclk(nclk),
         .force_t(slat_force[1]),
         .thold_b(time_slat_thold_b),
         .dclk(time_slat_d2clk),
         .lclk(time_slat_lclk)
      );


      tri_slat_scan #(.WIDTH(2), .INIT(2'b00)) perv_time_stg(
         .vd(vdd),
         .gd(gnd),
         .dclk(time_slat_d2clk),
         .lclk(time_slat_lclk),
         .scan_in( {time_scan_in, time_scan_out_int} ),
         .scan_out( {time_scan_in_q, time_scan_out_q} ),
         .q( perv_time_stg_q),
         .q_b( perv_time_stg_q_b)
      );


      tri_lcbs perv_lcbs_repr(
         .vd(vdd),
         .gd(gnd),
         .delay_lclkr(lcb_delay_lclkr_dc_int[0]),
         .nclk(nclk),
         .force_t(slat_force[1]),
         .thold_b(repr_slat_thold_b),
         .dclk(repr_slat_d2clk),
         .lclk(repr_slat_lclk)
      );


      tri_slat_scan #(.WIDTH(2), .INIT(2'b00)) perv_repr_stg(
         .vd(vdd),
         .gd(gnd),
         .dclk(repr_slat_d2clk),
         .lclk(repr_slat_lclk),
         .scan_in( {repr_scan_in, repr_scan_out_int} ),
         .scan_out( {repr_scan_in_q, repr_scan_out_q} ),
         .q( perv_repr_stg_q),
         .q_b( perv_repr_stg_q_b)
      );


      tri_lcbs perv_lcbs_gptr(
         .vd(vdd),
         .gd(gnd),
         .delay_lclkr(tiup),
         .nclk(nclk),
         .force_t(slat_force[0]),
         .thold_b(gptr_slat_thold_b),
         .dclk(gptr_slat_d2clk),
         .lclk(gptr_slat_lclk)
      );


      tri_slat_scan #(.WIDTH(2), .INIT(2'b00)) perv_gptr_stg(
         .vd(vdd),
         .gd(gnd),
         .dclk(gptr_slat_d2clk),
         .lclk(gptr_slat_lclk),
         .scan_in( {gptr_scan_in, gptr_scan_out_int} ),
         .scan_out( {gptr_scan_in_q, gptr_scan_out_q} ),
         .q( perv_gptr_stg_q),
         .q_b( perv_gptr_stg_q_b)
      );


      tri_lcbs perv_lcbs_bcfg(
         .vd(vdd),
         .gd(gnd),
         .delay_lclkr(lcb_delay_lclkr_dc_int[0]),
         .nclk(nclk),
         .force_t(slat_force[0]),
         .thold_b(bcfg_slat_thold_b),
         .dclk(bcfg_slat_d2clk),
         .lclk(bcfg_slat_lclk)
      );


      tri_slat_scan #(.WIDTH(2), .INIT(2'b00)) perv_bcfg_stg(
         .vd(vdd),
         .gd(gnd),
         .dclk(bcfg_slat_d2clk),
         .lclk(bcfg_slat_lclk),
         .scan_in( {bcfg_scan_in, bcfg_scan_out_int} ),
         .scan_out( {bcfg_scan_in_q, bcfg_scan_out_q} ),
         .q( perv_bcfg_stg_q),
         .q_b( perv_bcfg_stg_q_b)
      );


      tri_lcbs perv_lcbs_ccfg(
         .vd(vdd),
         .gd(gnd),
         .delay_lclkr(lcb_delay_lclkr_dc_int[0]),
         .nclk(nclk),
         .force_t(slat_force[0]),
         .thold_b(ccfg_slat_thold_b),
         .dclk(ccfg_slat_d2clk),
         .lclk(ccfg_slat_lclk)
      );


      tri_slat_scan #(.WIDTH(2), .INIT(2'b00)) perv_ccfg_stg(
         .vd(vdd),
         .gd(gnd),
         .dclk(ccfg_slat_d2clk),
         .lclk(ccfg_slat_lclk),
         .scan_in( {ccfg_scan_in, ccfg_scan_out_int} ),
         .scan_out( {ccfg_scan_in_q, ccfg_scan_out_q} ),
         .q( perv_ccfg_stg_q),
         .q_b( perv_ccfg_stg_q_b)
      );


      tri_lcbs perv_lcbs_dcfg(
         .vd(vdd),
         .gd(gnd),
         .delay_lclkr(lcb_delay_lclkr_dc_int[0]),
         .nclk(nclk),
         .force_t(slat_force[0]),
         .thold_b(dcfg_slat_thold_b),
         .dclk(dcfg_slat_d2clk),
         .lclk(dcfg_slat_lclk)
      );


      tri_slat_scan #(.WIDTH(2), .INIT(2'b00)) perv_dcfg_stg(
         .vd(vdd),
         .gd(gnd),
         .dclk(dcfg_slat_d2clk),
         .lclk(dcfg_slat_lclk),
         .scan_in( {dcfg_scan_in, dcfg_scan_out_int} ),
         .scan_out( {dcfg_scan_in_q, dcfg_scan_out_q} ),
         .q( perv_dcfg_stg_q),
         .q_b( perv_dcfg_stg_q_b)
      );


      tri_lcbs perv_lcbs_func(
         .vd(vdd),
         .gd(gnd),
         .delay_lclkr(lcb_delay_lclkr_dc_int[0]),
         .nclk(nclk),
         .force_t(slat_force[0]),
         .thold_b(func_slat_thold_b),
         .dclk(func_slat_d2clk),
         .lclk(func_slat_lclk)
      );


      tri_slat_scan #(.WIDTH(20), .INIT(20'b00000000000000000000)) perv_func_stg(
         .vd(vdd),
         .gd(gnd),
         .dclk(func_slat_d2clk),
         .lclk(func_slat_lclk),
         .scan_in( {func_scan_out_int, func_scan_in} ),
         .scan_out( {func_scan_out_q, func_scan_in_q} ),
         .q( perv_func_stg_q),
         .q_b( perv_func_stg_q_b)
      );


      tri_lcbor perv_lcbor_func_sl_0(
         .clkoff_b(lcb_clkoff_dc_b_int),
         .thold(pc_func_sl_thold_0_int[0]),
         .sg(pc_sg_0_int[0]),
         .act_dis(tidn),
         .force_t(pc_func_sl_force_int[0]),
         .thold_b(pc_func_sl_thold_0_b_int[0])
      );


      tri_lcbor perv_lcbor_func_sl_1(
         .clkoff_b(lcb_clkoff_dc_b_int),
         .thold(pc_func_sl_thold_0_int[1]),
         .sg(pc_sg_0_int[1]),
         .act_dis(tidn),
         .force_t(pc_func_sl_force_int[1]),
         .thold_b(pc_func_sl_thold_0_b_int[1])
      );


      tri_lcbor perv_lcbor_func_slp_sl_0(
         .clkoff_b(lcb_clkoff_dc_b_int),
         .thold(pc_func_slp_sl_thold_0_int[0]),
         .sg(pc_sg_0_int[0]),
         .act_dis(tidn),
         .force_t(pc_func_slp_sl_force_int[0]),
         .thold_b(pc_func_slp_sl_thold_0_b_int[0])
      );


      tri_lcbor perv_lcbor_func_slp_sl_1(
         .clkoff_b(lcb_clkoff_dc_b_int),
         .thold(pc_func_slp_sl_thold_0_int[1]),
         .sg(pc_sg_0_int[1]),
         .act_dis(tidn),
         .force_t(pc_func_slp_sl_force_int[1]),
         .thold_b(pc_func_slp_sl_thold_0_b_int[1])
      );


      tri_lcbor perv_lcbor_abst_sl(
         .clkoff_b(lcb_clkoff_dc_b_int),
         .thold(pc_abst_sl_thold_0_int),
         .sg(pc_sg_0_int[1]),
         .act_dis(tidn),
         .force_t(pc_abst_sl_force),
         .thold_b(pc_abst_sl_thold_0_b)
      );

      //---------------------------------------------------------------------
      // abist latches
      //---------------------------------------------------------------------


      tri_rlmreg_p #(.INIT(0), .WIDTH(42), .NEEDS_SRESET(0)) abist_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pc_mm_abist_ena_dc),
         .thold_b(pc_abst_sl_thold_0_b),
         .sg(pc_sg_0_int[1]),
         .force_t(pc_abst_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc_int[0]),
         .mpw1_b(lcb_mpw1_dc_b_int[0]),
         .mpw2_b(lcb_mpw2_dc_b_int),
         .d_mode(lcb_d_mode_dc_int),
         .scin(abist_siv[0:41]),
         .scout(abist_sov[0:41]),
         .din(   {pc_mm_abist_g8t_wenb,
                  pc_mm_abist_g8t1p_renb_0,
                  pc_mm_abist_di_0,
                  pc_mm_abist_g8t_bw_1,
                  pc_mm_abist_g8t_bw_0,
                  pc_mm_abist_waddr_0,
                  pc_mm_abist_raddr_0,
                  pc_mm_abist_wl128_comp_ena,
                  pc_mm_abist_g8t_dcomp,
                  pc_mm_abist_dcomp_g6t_2r,
                  pc_mm_abist_di_g6t_2r,
                  pc_mm_abist_g6t_r_wb} ),
         .dout(  {pc_mm_abist_g8t_wenb_q,
                   pc_mm_abist_g8t1p_renb_0_q,
                   pc_mm_abist_di_0_q,
                   pc_mm_abist_g8t_bw_1_q,
                   pc_mm_abist_g8t_bw_0_q,
                   pc_mm_abist_waddr_0_q,
                   pc_mm_abist_raddr_0_q,
                   pc_mm_abist_wl128_comp_ena_q,
                   pc_mm_abist_g8t_dcomp_q,
                   pc_mm_abist_dcomp_g6t_2r_q,
                   pc_mm_abist_di_g6t_2r_q,
                   pc_mm_abist_g6t_r_wb_q} )
      );

      assign abist_siv = {abist_sov[1:41], abst_scan_in_q[0]};
      assign abst_scan_in_int[0] = abist_sov[0];
      assign abst_scan_in_int[1] = abst_scan_in_q[1];

      // unused spare signal assignments
      assign unused_dc[0] = pc_fce_0_int;
      assign unused_dc[1] = pc_cfg_slp_sl_thold_0_int;
      assign unused_dc[2] = pc_func_nsl_thold_0_int;
      assign unused_dc[3] = pc_func_slp_nsl_thold_0_int;
      assign unused_dc[4] = |(pc_func_sl_force_int);
      assign unused_dc[5] = |(pc_func_slp_sl_force_int);


endmodule
