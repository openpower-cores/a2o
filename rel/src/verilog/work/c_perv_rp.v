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

//  Description: Pervasive Repower Logic

(* recursive_synthesis="0" *)
module c_perv_rp(
// Include model build parameters
`include "tri_a2o.vh"

//   inout                	vdd,
//   inout                	gnd,
   input  [0:`NCLK_WIDTH-1]	nclk,
   //CLOCK CONTROLS
   //Top level clock controls
   input                	an_ac_ccflush_dc,
   input                	rtim_sl_thold_8,
   input                	func_sl_thold_8,
   input                	func_nsl_thold_8,
   input                	ary_nsl_thold_8,
   input                	sg_8,
   input                	fce_8,
   output              		rtim_sl_thold_7,
   output               	func_sl_thold_7,
   output               	func_nsl_thold_7,
   output               	ary_nsl_thold_7,
   output               	sg_7,
   output               	fce_7,
   //Thold inputs from pcq clock controls
   input                	pc_rp_ccflush_out_dc,
   input                	pc_rp_gptr_sl_thold_4,
   input                	pc_rp_time_sl_thold_4,
   input                	pc_rp_repr_sl_thold_4,
   input                	pc_rp_abst_sl_thold_4,
   input                	pc_rp_abst_slp_sl_thold_4,
   input                	pc_rp_regf_sl_thold_4,
   input                	pc_rp_regf_slp_sl_thold_4,
   input                	pc_rp_func_sl_thold_4,
   input                	pc_rp_func_slp_sl_thold_4,
   input                	pc_rp_cfg_sl_thold_4,
   input               		pc_rp_cfg_slp_sl_thold_4,
   input                	pc_rp_func_nsl_thold_4,
   input                	pc_rp_func_slp_nsl_thold_4,
   input                	pc_rp_ary_nsl_thold_4,
   input                	pc_rp_ary_slp_nsl_thold_4,
   input                	pc_rp_rtim_sl_thold_4,
   input                	pc_rp_sg_4,
   input                	pc_rp_fce_4,
   //Thold outputs to the units
   output               	rp_iu_ccflush_dc,
   output               	rp_iu_gptr_sl_thold_3,
   output               	rp_iu_time_sl_thold_3,
   output               	rp_iu_repr_sl_thold_3,
   output               	rp_iu_abst_sl_thold_3,
   output               	rp_iu_abst_slp_sl_thold_3,
   output               	rp_iu_regf_slp_sl_thold_3,
   output               	rp_iu_func_sl_thold_3,
   output               	rp_iu_func_slp_sl_thold_3,
   output               	rp_iu_cfg_sl_thold_3,
   output               	rp_iu_cfg_slp_sl_thold_3,
   output               	rp_iu_func_nsl_thold_3,
   output               	rp_iu_func_slp_nsl_thold_3,
   output               	rp_iu_ary_nsl_thold_3,
   output               	rp_iu_ary_slp_nsl_thold_3,
   output               	rp_iu_sg_3,
   output               	rp_iu_fce_3,
   //
   output               	rp_rv_ccflush_dc,
   output               	rp_rv_gptr_sl_thold_3,
   output               	rp_rv_time_sl_thold_3,
   output               	rp_rv_repr_sl_thold_3,
   output               	rp_rv_abst_sl_thold_3,
   output               	rp_rv_abst_slp_sl_thold_3,
   output               	rp_rv_func_sl_thold_3,
   output                 	rp_rv_func_slp_sl_thold_3,
   output                 	rp_rv_cfg_sl_thold_3,
   output                 	rp_rv_cfg_slp_sl_thold_3,
   output                 	rp_rv_func_nsl_thold_3,
   output                 	rp_rv_func_slp_nsl_thold_3,
   output                 	rp_rv_ary_nsl_thold_3,
   output                 	rp_rv_ary_slp_nsl_thold_3,
   output                 	rp_rv_sg_3,
   output                 	rp_rv_fce_3,
   //
   output               	rp_xu_ccflush_dc,
   output               	rp_xu_gptr_sl_thold_3,
   output               	rp_xu_time_sl_thold_3,
   output               	rp_xu_repr_sl_thold_3,
   output               	rp_xu_abst_sl_thold_3,
   output               	rp_xu_abst_slp_sl_thold_3,
   output               	rp_xu_regf_slp_sl_thold_3,
   output               	rp_xu_func_sl_thold_3,
   output               	rp_xu_func_slp_sl_thold_3,
   output               	rp_xu_cfg_sl_thold_3,
   output               	rp_xu_cfg_slp_sl_thold_3,
   output               	rp_xu_func_nsl_thold_3,
   output               	rp_xu_func_slp_nsl_thold_3,
   output               	rp_xu_ary_nsl_thold_3,
   output               	rp_xu_ary_slp_nsl_thold_3,
   output               	rp_xu_sg_3,
   output               	rp_xu_fce_3,
   //
   output               	rp_lq_ccflush_dc,
   output               	rp_lq_gptr_sl_thold_3,
   output               	rp_lq_time_sl_thold_3,
   output               	rp_lq_repr_sl_thold_3,
   output               	rp_lq_abst_sl_thold_3,
   output               	rp_lq_abst_slp_sl_thold_3,
   output               	rp_lq_regf_slp_sl_thold_3,
   output               	rp_lq_func_sl_thold_3,
   output               	rp_lq_func_slp_sl_thold_3,
   output               	rp_lq_cfg_sl_thold_3,
   output               	rp_lq_cfg_slp_sl_thold_3,
   output               	rp_lq_func_nsl_thold_3,
   output               	rp_lq_func_slp_nsl_thold_3,
   output               	rp_lq_ary_nsl_thold_3,
   output               	rp_lq_ary_slp_nsl_thold_3,
   output               	rp_lq_sg_3,
   output               	rp_lq_fce_3,
   //
   output               	rp_mm_ccflush_dc,
   output               	rp_mm_gptr_sl_thold_3,
   output               	rp_mm_time_sl_thold_3,
   output               	rp_mm_repr_sl_thold_3,
   output               	rp_mm_abst_sl_thold_3,
   output               	rp_mm_abst_slp_sl_thold_3,
   output               	rp_mm_func_sl_thold_3,
   output               	rp_mm_func_slp_sl_thold_3,
   output               	rp_mm_cfg_sl_thold_3,
   output               	rp_mm_cfg_slp_sl_thold_3,
   output               	rp_mm_func_nsl_thold_3,
   output               	rp_mm_func_slp_nsl_thold_3,
   output               	rp_mm_ary_nsl_thold_3,
   output               	rp_mm_ary_slp_nsl_thold_3,
   output               	rp_mm_sg_3,
   output               	rp_mm_fce_3,

   //SCANRING REPOWERING
   input                	pc_bcfg_scan_in,
   output               	pc_bcfg_scan_in_q,
   input                	pc_dcfg_scan_in,
   output               	pc_dcfg_scan_in_q,
   input                	pc_bcfg_scan_out,
   output               	pc_bcfg_scan_out_q,
   input                	pc_ccfg_scan_out,
   output               	pc_ccfg_scan_out_q,
   input                	pc_dcfg_scan_out,
   output               	pc_dcfg_scan_out_q,
   input  [0:1]          	pc_func_scan_in,
   output [0:1]         	pc_func_scan_in_q,
   input  [0:1]          	pc_func_scan_out,
   output [0:1]         	pc_func_scan_out_q,
   //
   input                	fu_abst_scan_in,
   output               	fu_abst_scan_in_q,
   input                	fu_abst_scan_out,
   output               	fu_abst_scan_out_q,
   input                	fu_ccfg_scan_out,
   output               	fu_ccfg_scan_out_q,
   input                	fu_bcfg_scan_out,
   output               	fu_bcfg_scan_out_q,
   input                	fu_dcfg_scan_out,
   output               	fu_dcfg_scan_out_q,
   input  [0:3]          	fu_func_scan_in,
   output [0:3]         	fu_func_scan_in_q,
   input  [0:3]          	fu_func_scan_out,
   output [0:3]         	fu_func_scan_out_q,

   //MISCELLANEOUS FUNCTIONAL SIGNALS
   // node inputs going to pcq
   input                	an_ac_scom_dch,
   input                	an_ac_scom_cch,
   input                	an_ac_checkstop,
   input                	an_ac_debug_stop,
   input  [0:`THREADS-1] 	an_ac_pm_thread_stop,
   input  [0:`THREADS-1] 	an_ac_pm_fetch_halt,
   //
   output               	rp_pc_scom_dch_q,
   output               	rp_pc_scom_cch_q,
   output               	rp_pc_checkstop_q,
   output               	rp_pc_debug_stop_q,
   output [0:`THREADS-1]	rp_pc_pm_thread_stop_q,
   output [0:`THREADS-1]	rp_pc_pm_fetch_halt_q,
   // pcq outputs going to node
   input                	pc_rp_scom_dch,
   input                	pc_rp_scom_cch,
   input  [0:`THREADS-1] 	pc_rp_special_attn,
   input  [0:2]          	pc_rp_checkstop,
   input  [0:2]          	pc_rp_local_checkstop,
   input  [0:2]          	pc_rp_recov_err,
   input                	pc_rp_trace_error,
   input  [0:`THREADS-1] 	pc_rp_pm_thread_running,
   input                	pc_rp_power_managed,
   input                	pc_rp_rvwinkle_mode,
   input                        pc_rp_livelock_active,
   //
   output               	ac_an_scom_dch_q,
   output               	ac_an_scom_cch_q,
   output [0:`THREADS-1]	ac_an_special_attn_q,
   output [0:2]         	ac_an_checkstop_q,
   output [0:2]         	ac_an_local_checkstop_q,
   output [0:2]         	ac_an_recov_err_q,
   output               	ac_an_trace_error_q,
   output [0:`THREADS-1] 	ac_an_pm_thread_running_q,
   output               	ac_an_power_managed_q,
   output               	ac_an_rvwinkle_mode_q,
   output                       ac_an_livelock_active_q,

   // SCAN CHAINS
   input                	scan_diag_dc,
   input                	scan_dis_dc_b,
   input                	func_scan_in,
   input                	gptr_scan_in,
   output               	func_scan_out,
   output               	gptr_scan_out
);


//=====================================================================
// Signal Declarations
//=====================================================================
   // FUNC Scan Ring
   parameter            	FUNC2_T0_SIZE = 23;
   parameter            	FUNC2_T1_SIZE = 4 * (`THREADS - 1);
   // start of func scan chain ordering
   parameter            	FUNC2_T0_OFFSET = 0;
   parameter            	FUNC2_T1_OFFSET = FUNC2_T0_OFFSET + FUNC2_T0_SIZE;
   parameter            	FUNC_RIGHT = FUNC2_T1_OFFSET + FUNC2_T1_SIZE - 1;
   // end of func scan chain ordering

   // Power signals
   wire 			   vdd;
   wire 			   gnd;
   assign vdd = 1'b1;
   assign gnd = 1'b0;

   // Clock and Scan Signals
   wire [0:FUNC_RIGHT]  	func_siv;
   wire [0:FUNC_RIGHT]  	func_sov;
   //
   wire                 	slat_force;
   wire                 	func_slat_thold_b;
   wire                 	func_slat_d2clk;
   wire [0:`NCLK_WIDTH-1]       func_slat_lclk;
   wire                 	abst_slat_thold_b;
   wire                 	abst_slat_d2clk;
   wire [0:`NCLK_WIDTH-1]       abst_slat_lclk;
   wire                 	cfg_slat_thold_b;
   wire                 	cfg_slat_d2clk;
   wire [0:`NCLK_WIDTH-1]       cfg_slat_lclk;
   //
   wire                 	sg_3_int;
   wire                 	func_sl_thold_3_int;
   wire                 	func_slp_sl_thold_3_int;
   wire                 	abst_sl_thold_3_int;
   wire                 	gptr_sl_thold_3_int;
   wire                 	cfg_sl_thold_3_int;
   wire                 	sg_2;
   wire                 	func_sl_thold_2;
   wire                 	func_slp_sl_thold_2;
   wire                 	abst_sl_thold_2;
   wire                 	gptr_sl_thold_2;
   wire                 	cfg_sl_thold_2;
   wire                 	sg_1;
   wire                 	func_sl_thold_1;
   wire                 	func_slp_sl_thold_1;
   wire                 	gptr_sl_thold_1;
   wire                 	abst_sl_thold_1;
   wire                 	cfg_sl_thold_1;
   wire                 	sg_0;
   wire                 	func_sl_thold_0;
   wire                 	func_sl_thold_0_b;
   wire                 	force_func;
   wire                 	func_slp_sl_thold_0;
   wire                 	func_slp_sl_thold_0_b;
   wire                 	force_func_slp;
   wire                 	gptr_sl_thold_0;
   wire                 	abst_sl_thold_0;
   wire                 	abst_sl_thold_0_b;
   wire                 	force_abst;
   wire                 	cfg_sl_thold_0;
   //
   wire                 	clkoff_b;
   wire                 	act_dis;
   wire                 	d_mode;
   wire [0:4]           	delay_lclkr;
   wire [0:4]           	mpw1_b;
   wire                 	mpw2_b;

// Get rid of sinkless net messages
(* analysis_not_referenced="true" *)
   wire                 	unused;
   assign unused = pc_rp_regf_sl_thold_4 | pc_rp_rtim_sl_thold_4 | d_mode | (|delay_lclkr[1:4]) | (|mpw1_b[1:4]);


// *****************************************************************************
// INTERNALLY USED CLOCK CONTROLS
// *****************************************************************************
   // Thold/Sg Staging latches
   tri_plat #(.WIDTH(6)) perv_4to3_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(pc_rp_ccflush_out_dc),

      .din({pc_rp_func_sl_thold_4,	pc_rp_func_slp_sl_thold_4,	pc_rp_gptr_sl_thold_4,
	    pc_rp_abst_sl_thold_4,	pc_rp_cfg_sl_thold_4,           pc_rp_sg_4  }),

      .q(  {func_sl_thold_3_int, 	func_slp_sl_thold_3_int,	gptr_sl_thold_3_int,
	    abst_sl_thold_3_int,	cfg_sl_thold_3_int,             sg_3_int    })
   );

   tri_plat #(.WIDTH(6)) perv_3to2_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(pc_rp_ccflush_out_dc),

      .din({func_sl_thold_3_int,	func_slp_sl_thold_3_int,	gptr_sl_thold_3_int,
            abst_sl_thold_3_int,	cfg_sl_thold_3_int,		sg_3_int }),

      .q(  {func_sl_thold_2,		func_slp_sl_thold_2,		gptr_sl_thold_2,
            abst_sl_thold_2,		cfg_sl_thold_2,			sg_2 })
   );

   tri_plat #(.WIDTH(6)) perv_2to1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(pc_rp_ccflush_out_dc),

      .din({func_sl_thold_2,		func_slp_sl_thold_2,		gptr_sl_thold_2,
            abst_sl_thold_2,		cfg_sl_thold_2,			sg_2 }),

      .q(  {func_sl_thold_1,		func_slp_sl_thold_1,		gptr_sl_thold_1,
            abst_sl_thold_1,		cfg_sl_thold_1,			sg_1 })
   );

   tri_plat #(.WIDTH(6)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(pc_rp_ccflush_out_dc),

      .din({func_sl_thold_1,		func_slp_sl_thold_1,		gptr_sl_thold_1,
            abst_sl_thold_1,		cfg_sl_thold_1,			sg_1 }),

      .q(  {func_sl_thold_0,		func_slp_sl_thold_0,		gptr_sl_thold_0,
            abst_sl_thold_0,		cfg_sl_thold_0,			sg_0 })
   );

   // LCBCNTRL Macro
   tri_lcbcntl_mac  perv_lcbcntl(
      .vdd(vdd),
      .gnd(gnd),
      .sg(sg_0),
      .nclk(nclk),
      .scan_in(gptr_scan_in),
      .scan_diag_dc(scan_diag_dc),
      .thold(gptr_sl_thold_0),
      .clkoff_dc_b(clkoff_b),
      .delay_lclkr_dc(delay_lclkr[0:4]),
      .act_dis_dc(act_dis),
      .d_mode_dc(d_mode),
      .mpw1_dc_b(mpw1_b[0:4]),
      .mpw2_dc_b(mpw2_b),
      .scan_out(gptr_scan_out)
   );

   // LCBORs
   tri_lcbor  abst_lcbor(
      .clkoff_b(clkoff_b),
      .thold(abst_sl_thold_0),
      .sg(sg_0),
      .act_dis(act_dis),
      .force_t(force_abst),
      .thold_b(abst_sl_thold_0_b)
   );

   tri_lcbor  func_lcbor(
      .clkoff_b(clkoff_b),
      .thold(func_sl_thold_0),
      .sg(sg_0),
      .act_dis(act_dis),
      .force_t(force_func),
      .thold_b(func_sl_thold_0_b)
   );

   tri_lcbor  func_slp_lcbor(
      .clkoff_b(clkoff_b),
      .thold(func_slp_sl_thold_0),
      .sg(sg_0),
      .act_dis(act_dis),
      .force_t(force_func_slp),
      .thold_b(func_slp_sl_thold_0_b)
   );

   // LCBs for scan only staging latches
   assign slat_force = sg_0;
   assign func_slat_thold_b = (~func_sl_thold_0);
   assign abst_slat_thold_b = (~abst_sl_thold_0);
   assign cfg_slat_thold_b = (~cfg_sl_thold_0);

   tri_lcbs  lcbs_func(
      .vd(vdd),
      .gd(gnd),
      .delay_lclkr(delay_lclkr[0]),
      .nclk(nclk),
      .force_t(slat_force),
      .thold_b(func_slat_thold_b),
      .dclk(func_slat_d2clk),
      .lclk(func_slat_lclk)
   );

   tri_lcbs  lcbs_abst(
      .vd(vdd),
      .gd(gnd),
      .delay_lclkr(delay_lclkr[0]),
      .nclk(nclk),
      .force_t(slat_force),
      .thold_b(abst_slat_thold_b),
      .dclk(abst_slat_d2clk),
      .lclk(abst_slat_lclk)
   );

   tri_lcbs  lcbs_cfg(
      .vd(vdd),
      .gd(gnd),
      .delay_lclkr(delay_lclkr[0]),
      .nclk(nclk),
      .force_t(slat_force),
      .thold_b(cfg_slat_thold_b),
      .dclk(cfg_slat_d2clk),
      .lclk(cfg_slat_lclk)
   );

// *****************************************************************************
// CLOCK REPOWERING LOGIC
// *****************************************************************************
   // Stages pcq clock control inputs
   tri_plat #(.WIDTH(6)) pcq_lvl8to7(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(an_ac_ccflush_dc),

      .din({rtim_sl_thold_8,		func_sl_thold_8,		func_nsl_thold_8,
            ary_nsl_thold_8,		sg_8,				fce_8 }),

      .q(  {rtim_sl_thold_7,		func_sl_thold_7,		func_nsl_thold_7,
            ary_nsl_thold_7,		sg_7,				fce_7 })
   );

   // Other units use the ccflush signal after being gated for power-savings operation
   assign rp_iu_ccflush_dc = pc_rp_ccflush_out_dc;
   assign rp_rv_ccflush_dc = pc_rp_ccflush_out_dc;
   assign rp_xu_ccflush_dc = pc_rp_ccflush_out_dc;
   assign rp_lq_ccflush_dc = pc_rp_ccflush_out_dc;
   assign rp_mm_ccflush_dc = pc_rp_ccflush_out_dc;

   // Clock control 4to3 output staging
   tri_plat #(.WIDTH(16)) iu_clkstg_4to3(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(pc_rp_ccflush_out_dc),

      .din({pc_rp_gptr_sl_thold_4,		pc_rp_time_sl_thold_4,		pc_rp_repr_sl_thold_4,
            pc_rp_abst_sl_thold_4,		pc_rp_abst_slp_sl_thold_4,	pc_rp_regf_slp_sl_thold_4,
	    pc_rp_func_sl_thold_4,		pc_rp_func_slp_sl_thold_4,      pc_rp_cfg_sl_thold_4,
	    pc_rp_cfg_slp_sl_thold_4,		pc_rp_func_nsl_thold_4,		pc_rp_func_slp_nsl_thold_4,
	    pc_rp_ary_nsl_thold_4,		pc_rp_ary_slp_nsl_thold_4,	pc_rp_sg_4, pc_rp_fce_4 }),

      .q(  {rp_iu_gptr_sl_thold_3,		rp_iu_time_sl_thold_3,		rp_iu_repr_sl_thold_3,
            rp_iu_abst_sl_thold_3,		rp_iu_abst_slp_sl_thold_3,      rp_iu_regf_slp_sl_thold_3,
	    rp_iu_func_sl_thold_3,		rp_iu_func_slp_sl_thold_3,      rp_iu_cfg_sl_thold_3,
	    rp_iu_cfg_slp_sl_thold_3,		rp_iu_func_nsl_thold_3,		rp_iu_func_slp_nsl_thold_3,
	    rp_iu_ary_nsl_thold_3,		rp_iu_ary_slp_nsl_thold_3,	rp_iu_sg_3, rp_iu_fce_3 })
   );

   tri_plat #(.WIDTH(15)) rv_clkstg_4to3(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(pc_rp_ccflush_out_dc),

      .din({pc_rp_gptr_sl_thold_4,		pc_rp_time_sl_thold_4,		pc_rp_repr_sl_thold_4,
            pc_rp_abst_sl_thold_4,		pc_rp_abst_slp_sl_thold_4,	pc_rp_func_sl_thold_4,
	    pc_rp_func_slp_sl_thold_4,		pc_rp_cfg_sl_thold_4,           pc_rp_cfg_slp_sl_thold_4,
	    pc_rp_func_nsl_thold_4,		pc_rp_func_slp_nsl_thold_4,     pc_rp_ary_nsl_thold_4,
	    pc_rp_ary_slp_nsl_thold_4,		pc_rp_sg_4,		        pc_rp_fce_4 }),

      .q(  {rp_rv_gptr_sl_thold_3,		rp_rv_time_sl_thold_3,		rp_rv_repr_sl_thold_3,
            rp_rv_abst_sl_thold_3,		rp_rv_abst_slp_sl_thold_3,	rp_rv_func_sl_thold_3,
	    rp_rv_func_slp_sl_thold_3,		rp_rv_cfg_sl_thold_3,           rp_rv_cfg_slp_sl_thold_3,
	    rp_rv_func_nsl_thold_3,		rp_rv_func_slp_nsl_thold_3,     rp_rv_ary_nsl_thold_3,
	    rp_rv_ary_slp_nsl_thold_3,		rp_rv_sg_3,		        rp_rv_fce_3 })
   );

   tri_plat #(.WIDTH(16)) xu_clkstg_4to3(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(pc_rp_ccflush_out_dc),

      .din({pc_rp_gptr_sl_thold_4,		pc_rp_time_sl_thold_4,		pc_rp_repr_sl_thold_4,
            pc_rp_abst_sl_thold_4,		pc_rp_abst_slp_sl_thold_4,	pc_rp_regf_slp_sl_thold_4,
	    pc_rp_func_sl_thold_4,		pc_rp_func_slp_sl_thold_4,      pc_rp_cfg_sl_thold_4,
	    pc_rp_cfg_slp_sl_thold_4,		pc_rp_func_nsl_thold_4,         pc_rp_func_slp_nsl_thold_4,
	    pc_rp_ary_nsl_thold_4,		pc_rp_ary_slp_nsl_thold_4,      pc_rp_sg_4, pc_rp_fce_4 }),

      .q(  {rp_xu_gptr_sl_thold_3,		rp_xu_time_sl_thold_3,		rp_xu_repr_sl_thold_3,
            rp_xu_abst_sl_thold_3,		rp_xu_abst_slp_sl_thold_3,	rp_xu_regf_slp_sl_thold_3,
	    rp_xu_func_sl_thold_3,		rp_xu_func_slp_sl_thold_3,      rp_xu_cfg_sl_thold_3,
	    rp_xu_cfg_slp_sl_thold_3,		rp_xu_func_nsl_thold_3,         rp_xu_func_slp_nsl_thold_3,
	    rp_xu_ary_nsl_thold_3,		rp_xu_ary_slp_nsl_thold_3,      rp_xu_sg_3, rp_xu_fce_3 })
   );

   tri_plat #(.WIDTH(16)) lq_clkstg_4to3(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(pc_rp_ccflush_out_dc),

      .din({pc_rp_gptr_sl_thold_4,		pc_rp_time_sl_thold_4,		pc_rp_repr_sl_thold_4,
            pc_rp_abst_sl_thold_4,		pc_rp_abst_slp_sl_thold_4,	pc_rp_regf_slp_sl_thold_4,
	    pc_rp_func_sl_thold_4,		pc_rp_func_slp_sl_thold_4,      pc_rp_cfg_sl_thold_4,
	    pc_rp_cfg_slp_sl_thold_4,		pc_rp_func_nsl_thold_4,         pc_rp_func_slp_nsl_thold_4,
	    pc_rp_ary_nsl_thold_4,		pc_rp_ary_slp_nsl_thold_4,      pc_rp_sg_4, pc_rp_fce_4 }),

      .q(  {rp_lq_gptr_sl_thold_3,		rp_lq_time_sl_thold_3,		rp_lq_repr_sl_thold_3,
            rp_lq_abst_sl_thold_3,		rp_lq_abst_slp_sl_thold_3,	rp_lq_regf_slp_sl_thold_3,
	    rp_lq_func_sl_thold_3,		rp_lq_func_slp_sl_thold_3,      rp_lq_cfg_sl_thold_3,
	    rp_lq_cfg_slp_sl_thold_3,		rp_lq_func_nsl_thold_3,         rp_lq_func_slp_nsl_thold_3,
	    rp_lq_ary_nsl_thold_3,		rp_lq_ary_slp_nsl_thold_3,      rp_lq_sg_3, rp_lq_fce_3 })
   );

   tri_plat #(.WIDTH(15)) mm_clkstg_4to3(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(pc_rp_ccflush_out_dc),

      .din({pc_rp_gptr_sl_thold_4,		pc_rp_time_sl_thold_4,		pc_rp_repr_sl_thold_4,
            pc_rp_abst_sl_thold_4,		pc_rp_abst_slp_sl_thold_4,	pc_rp_func_sl_thold_4,
	    pc_rp_func_slp_sl_thold_4,		pc_rp_cfg_sl_thold_4,           pc_rp_cfg_slp_sl_thold_4,
	    pc_rp_func_nsl_thold_4,		pc_rp_func_slp_nsl_thold_4,	pc_rp_ary_nsl_thold_4,
	    pc_rp_ary_slp_nsl_thold_4,		pc_rp_sg_4,			pc_rp_fce_4 }),

      .q(  {rp_mm_gptr_sl_thold_3,		rp_mm_time_sl_thold_3,		rp_mm_repr_sl_thold_3,
            rp_mm_abst_sl_thold_3,		rp_mm_abst_slp_sl_thold_3,	rp_mm_func_sl_thold_3,
	    rp_mm_func_slp_sl_thold_3,		rp_mm_cfg_sl_thold_3,           rp_mm_cfg_slp_sl_thold_3,
	    rp_mm_func_nsl_thold_3,		rp_mm_func_slp_nsl_thold_3,     rp_mm_ary_nsl_thold_3,
	    rp_mm_ary_slp_nsl_thold_3,		rp_mm_sg_3,		        rp_mm_fce_3 })
   );

// *****************************************************************************
// SCANRING REPOWERING
// *****************************************************************************
   // Staging latches for scan_in/out signals on abist rings
   tri_slat_scan #(.WIDTH(2), .INIT(2'b00)) fu_abst_stg(
      .vd(vdd),
      .gd(gnd),
      .dclk(abst_slat_d2clk),
      .lclk(abst_slat_lclk),
      .scan_in( {fu_abst_scan_in,   fu_abst_scan_out   }),
      .scan_out({fu_abst_scan_in_q, fu_abst_scan_out_q })
   );

   // Staging latches for scan_in/out signals on func rings
   tri_slat_scan #(.WIDTH(4), .INIT(4'b0000)) pc_func_stg(
      .vd(vdd),
      .gd(gnd),
      .dclk(func_slat_d2clk),
      .lclk(func_slat_lclk),
      .scan_in( {pc_func_scan_in[0:1],   pc_func_scan_out[0:1]   }),
      .scan_out({pc_func_scan_in_q[0:1], pc_func_scan_out_q[0:1] })
   );

   tri_slat_scan #(.WIDTH(8), .INIT(8'b00000000)) fu_func_stg(
      .vd(vdd),
      .gd(gnd),
      .dclk(func_slat_d2clk),
      .lclk(func_slat_lclk),
      .scan_in( {fu_func_scan_in[0:3],   fu_func_scan_out[0:3]   }),
      .scan_out({fu_func_scan_in_q[0:3], fu_func_scan_out_q[0:3] })
   );

   // Staging latches for scan_in/out signals on config rings
   tri_slat_scan #(.WIDTH(5), .INIT(5'b00000)) pc_cfg_stg(
      .vd(vdd),
      .gd(gnd),
      .dclk(cfg_slat_d2clk),
      .lclk(cfg_slat_lclk),

      .scan_in( {pc_bcfg_scan_in,	pc_dcfg_scan_in,    pc_bcfg_scan_out,
                 pc_ccfg_scan_out,	pc_dcfg_scan_out   }),

      .scan_out({pc_bcfg_scan_in_q,  	pc_dcfg_scan_in_q,  pc_bcfg_scan_out_q,
	         pc_ccfg_scan_out_q, 	pc_dcfg_scan_out_q })
   );

   tri_slat_scan #(.WIDTH(3), .INIT(3'b000)) fu_cfg_stg(
      .vd(vdd),
      .gd(gnd),
      .dclk(cfg_slat_d2clk),
      .lclk(cfg_slat_lclk),
      .scan_in( {fu_bcfg_scan_out,   fu_ccfg_scan_out,   fu_dcfg_scan_out   }),
      .scan_out({fu_bcfg_scan_out_q, fu_ccfg_scan_out_q, fu_dcfg_scan_out_q })
   );

// *****************************************************************************
// MISCELLANEOUS FUNCTIONAL SIGNALS
// *****************************************************************************
   tri_rlmreg_p #(.WIDTH(FUNC2_T0_SIZE), .INIT(0)) func2_t0_rp(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(1'b1),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(force_func_slp),
      .delay_lclkr(delay_lclkr[0]),
      .mpw1_b(mpw1_b[0]),
      .mpw2_b(mpw2_b),
      .scin(func_siv[ FUNC2_T0_OFFSET:FUNC2_T0_OFFSET + FUNC2_T0_SIZE - 1]),
      .scout(func_sov[FUNC2_T0_OFFSET:FUNC2_T0_OFFSET + FUNC2_T0_SIZE - 1]),

      .din( {an_ac_scom_dch,            an_ac_scom_cch,              an_ac_checkstop,
      	     an_ac_debug_stop,          pc_rp_scom_dch,              pc_rp_scom_cch,
      	     pc_rp_checkstop,           pc_rp_local_checkstop,       pc_rp_recov_err,
      	     pc_rp_power_managed,       pc_rp_rvwinkle_mode,  	     pc_rp_trace_error,
      	     pc_rp_livelock_active,	an_ac_pm_thread_stop[0],     pc_rp_pm_thread_running[0],
      	     pc_rp_special_attn[0],     an_ac_pm_fetch_halt[0]      }),

      .dout({rp_pc_scom_dch_q,          rp_pc_scom_cch_q,      	     rp_pc_checkstop_q,
      	     rp_pc_debug_stop_q,        ac_an_scom_dch_q,      	     ac_an_scom_cch_q,
      	     ac_an_checkstop_q,         ac_an_local_checkstop_q,     ac_an_recov_err_q,
      	     ac_an_power_managed_q,     ac_an_rvwinkle_mode_q,       ac_an_trace_error_q,
      	     ac_an_livelock_active_q,	rp_pc_pm_thread_stop_q[0],   ac_an_pm_thread_running_q[0],
      	     ac_an_special_attn_q[0],   rp_pc_pm_fetch_halt_q[0]     })
   );

   generate
      if (`THREADS == 2)
      begin : t1_rp
         tri_rlmreg_p #(.WIDTH(FUNC2_T1_SIZE), .INIT(0)) func2_t1_rp(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(1'b1),
            .thold_b(func_slp_sl_thold_0_b),
            .sg(sg_0),
            .force_t(force_func_slp),
            .delay_lclkr(delay_lclkr[0]),
            .mpw1_b(mpw1_b[0]),
            .mpw2_b(mpw2_b),
            .scin(func_siv[ FUNC2_T1_OFFSET:FUNC2_T1_OFFSET + FUNC2_T1_SIZE - 1]),
            .scout(func_sov[FUNC2_T1_OFFSET:FUNC2_T1_OFFSET + FUNC2_T1_SIZE - 1]),

            .din( {an_ac_pm_thread_stop[1],   pc_rp_pm_thread_running[1],    pc_rp_special_attn[1],
	           an_ac_pm_fetch_halt[1]     }),
            .dout({rp_pc_pm_thread_stop_q[1], ac_an_pm_thread_running_q[1],  ac_an_special_attn_q[1],
	    	   rp_pc_pm_fetch_halt_q[1]   })
         );
      end
   endgenerate

// *****************************************************************************
// SCAN RING CONNECTIONS
// *****************************************************************************
   //func ring
   assign func_siv[0:FUNC_RIGHT] = {func_scan_in, func_sov[0:FUNC_RIGHT - 1]};
   assign func_scan_out = func_sov[FUNC_RIGHT] & scan_dis_dc_b;


endmodule
