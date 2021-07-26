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

//
//  Description: Pervasive Core FIR + Error Reporting Function
//
//*****************************************************************************

module pcq_regs_fir(
// Include model build parameters
`include "tri_a2o.vh"

   inout                           vdd,
   inout                           gnd,
   input  [0:`NCLK_WIDTH-1]        nclk,
   input                           lcb_clkoff_dc_b,
   input                           lcb_mpw1_dc_b,
   input                           lcb_mpw2_dc_b,
   input                           lcb_delay_lclkr_dc,
   input                           lcb_act_dis_dc,
   input                           lcb_sg_0,
   input                           lcb_func_slp_sl_thold_0,
   input                           lcb_cfg_slp_sl_thold_0,
   input                           cfgslp_d1clk,
   input                           cfgslp_d2clk,
   input  [0:`NCLK_WIDTH-1]        cfgslp_lclk,
   input                           cfg_slat_d2clk,
   input  [0:`NCLK_WIDTH-1]        cfg_slat_lclk,
   input                           bcfg_scan_in,
   output                          bcfg_scan_out,
   input                           func_scan_in,
   output                          func_scan_out,
   // SCOM Satellite Interface
   input                           sc_active,
   input                           sc_wr_q,
   input  [0:63]                   sc_addr_v,
   input  [0:63]                   sc_wdata,
   output [0:63]                   sc_rdata,
   // FIR and Error Signals
   output [0:2]                    ac_an_checkstop,
   output [0:2]                    ac_an_local_checkstop,
   output [0:2]                    ac_an_recov_err,
   output                          ac_an_trace_error,
   output                          rg_rg_any_fir_xstop,
   output                          ac_an_livelock_active,
   input                           an_ac_checkstop,
   input                           iu_pc_err_icache_parity,
   input                           iu_pc_err_icachedir_parity,
   input                           iu_pc_err_icachedir_multihit,
   input                           lq_pc_err_dcache_parity,
   input                           lq_pc_err_dcachedir_ldp_parity,
   input                           lq_pc_err_dcachedir_stp_parity,
   input                           lq_pc_err_dcachedir_ldp_multihit,
   input                           lq_pc_err_dcachedir_stp_multihit,
   input                           iu_pc_err_ierat_parity,
   input                           iu_pc_err_ierat_multihit,
   input                     	   iu_pc_err_btb_parity,
   input                           lq_pc_err_derat_parity,
   input                           lq_pc_err_derat_multihit,
   input                           mm_pc_err_tlb_parity,
   input                           mm_pc_err_tlb_multihit,
   input                           mm_pc_err_tlb_lru_parity,
   input                           mm_pc_err_local_snoop_reject,
   input                           lq_pc_err_l2intrf_ecc,
   input                           lq_pc_err_l2intrf_ue,
   input                           lq_pc_err_invld_reld,
   input                           lq_pc_err_l2credit_overrun,
   input  [0:1]                    scom_reg_par_checks,
   input                           scom_sat_fsm_error,
   input                           scom_ack_error,
   input                           lq_pc_err_prefetcher_parity,
   input                           lq_pc_err_relq_parity,
   input  [0:`THREADS-1]           xu_pc_err_sprg_ecc,
   input  [0:`THREADS-1]           xu_pc_err_sprg_ue,
   input  [0:`THREADS-1]           xu_pc_err_regfile_parity,
   input  [0:`THREADS-1]           xu_pc_err_regfile_ue,
   input  [0:`THREADS-1]           lq_pc_err_regfile_parity,
   input  [0:`THREADS-1]           lq_pc_err_regfile_ue,
   input  [0:`THREADS-1]           fu_pc_err_regfile_parity,
   input  [0:`THREADS-1]           fu_pc_err_regfile_ue,
   input  [0:`THREADS-1]     	   iu_pc_err_cpArray_parity,
   input  [0:`THREADS-1]           iu_pc_err_ucode_illegal,
   input  [0:`THREADS-1]           iu_pc_err_mchk_disabled,
   input  [0:`THREADS-1]           xu_pc_err_llbust_attempt,
   input  [0:`THREADS-1]           xu_pc_err_llbust_failed,
   input  [0:`THREADS-1]           xu_pc_err_wdt_reset,
   input  [0:`THREADS-1]           iu_pc_err_debug_event,
   input                           rg_rg_ram_mode,
   output                          rg_rg_ram_mode_xstop,
   input                           rg_rg_xstop_report_ovride,
   output [0:`THREADS-1]           rg_rg_xstop_err,
   input                           sc_parity_error_inject,
   output [0:22+9*(`THREADS-1)]    rg_rg_errinj_shutoff,
   input                           rg_rg_maxRecErrCntrValue,
   output                          rg_rg_gateRecErrCntr,
   input  [0:31]		   errDbg_out,
   // Trace/Trigger Signals
   output [0:27]                   dbg_fir0_err,
   output [0:19]                   dbg_fir1_err,
   output [0:19]      		   dbg_fir2_err,
   output [0:14]    		   dbg_fir_misc
);

//=====================================================================
// Signal Declarations
//=====================================================================
   // FIR0 Init Values
   parameter                      FIR0_WIDTH = 28;
   parameter                      FIR0_INIT = 28'h0000000;
   parameter                      FIR0MASK_INIT = 28'hFFFFFFF;
   parameter                      FIR0MASK_PAR_INIT = 1'b0;
   parameter                      FIR0ACT0_INIT = 28'h0000390;
   parameter                      FIR0ACT0_PAR_INIT = 1'b0;
   parameter                      FIR0ACT1_INIT = 28'hFFFFFFE;
   parameter                      FIR0ACT1_PAR_INIT = 1'b1;
   // FIR1 Init Values
   parameter                      FIR1_WIDTH = 20;
   parameter                      FIR1_INIT = 20'h00000;
   parameter                      FIR1MASK_INIT = 20'hFFFFF;
   parameter                      FIR1MASK_PAR_INIT = 1'b0;
   parameter                      FIR1ACT0_INIT = 20'h55660;
   parameter                      FIR1ACT0_PAR_INIT = 1'b0;
   parameter                      FIR1ACT1_INIT = 20'hFFFE0;
   parameter                      FIR1ACT1_PAR_INIT = 1'b1;
   // FIR2 Init Values
`ifdef THREADS1
   parameter                      FIR2_WIDTH = 1;
   parameter                      FIR2_INIT = 1'b0;
   parameter                      FIR2MASK_INIT = 1'b1;
   parameter                      FIR2MASK_PAR_INIT = 1'b1;
   parameter                      FIR2ACT0_INIT = 1'b0;
   parameter                      FIR2ACT0_PAR_INIT = 1'b0;
   parameter                      FIR2ACT1_INIT = 1'b0;
   parameter                      FIR2ACT1_PAR_INIT = 1'b0;
`else
   parameter                      FIR2_WIDTH = 20;
   parameter                      FIR2_INIT = 20'h00000;
   parameter                      FIR2MASK_INIT = 20'hFFFFF;
   parameter                      FIR2MASK_PAR_INIT = 1'b0;
   parameter                      FIR2ACT0_INIT = 20'h55660;
   parameter                      FIR2ACT0_PAR_INIT = 1'b0;
   parameter                      FIR2ACT1_INIT = 20'hFFFE0;
   parameter                      FIR2ACT1_PAR_INIT = 1'b1;
`endif
   // Common Init Values
   parameter                      SCPAR_ERR_RPT_WIDTH = 11;
   parameter                      SCPAR_RPT_RESET_VALUE = 11'b00000000000;
   parameter                      SCACK_ERR_RPT_WIDTH = 2;
   parameter                      SCACK_RPT_RESET_VALUE = 2'b00;
   parameter                      SCRDATA_SIZE = 64;

   // Scan Ring Ordering:
   parameter                      FIR0_BCFG_SIZE = 3 * (FIR0_WIDTH + 1) + FIR0_WIDTH;
   parameter                      FIR1_BCFG_SIZE = 3 * (FIR1_WIDTH + 1) + FIR1_WIDTH;
   parameter                      FIR2_BCFG_SIZE = 3 * (FIR2_WIDTH + 1) + FIR2_WIDTH;
   parameter                      FIR0_FUNC_SIZE = 5;
   parameter                      FIR1_FUNC_SIZE = 5;
   parameter                      FIR2_FUNC_SIZE = 5;
   parameter                      ERROUT_FUNC_SIZE = 30;
   // START OF BCFG SCAN CHAIN ORDERING
   parameter                      BCFG_FIR0_OFFSET = 0;
   parameter                      BCFG_FIR1_OFFSET = BCFG_FIR0_OFFSET + FIR0_BCFG_SIZE;
   parameter                      BCFG_FIR2_OFFSET = BCFG_FIR1_OFFSET + FIR1_BCFG_SIZE;
   parameter                      BCFG_ERPT1_HLD_OFFSET = BCFG_FIR2_OFFSET + FIR2_BCFG_SIZE;
   parameter                      BCFG_ERPT1_MSK_OFFSET = BCFG_ERPT1_HLD_OFFSET + SCPAR_ERR_RPT_WIDTH;
   parameter                      BCFG_ERPT2_HLD_OFFSET = BCFG_ERPT1_MSK_OFFSET + SCPAR_ERR_RPT_WIDTH;
   parameter                      BCFG_ERPT2_MSK_OFFSET = BCFG_ERPT2_HLD_OFFSET + SCACK_ERR_RPT_WIDTH;
   parameter                      BCFG_RIGHT = BCFG_ERPT2_MSK_OFFSET + SCACK_ERR_RPT_WIDTH - 1;
   // END OF BCFG SCAN CHAIN ORDERING
   // START OF FUNC SCAN CHAIN ORDERING
   parameter                      FUNC_FIR0_OFFSET = 0;
   parameter                      FUNC_FIR1_OFFSET = FUNC_FIR0_OFFSET + FIR0_FUNC_SIZE;
   parameter                      FUNC_FIR2_OFFSET = FUNC_FIR1_OFFSET + FIR1_FUNC_SIZE;
   parameter                      FUNC_ERROUT_OFFSET = FUNC_FIR2_OFFSET + FIR2_FUNC_SIZE;
   parameter                      FUNC_F0ERR_OFFSET = FUNC_ERROUT_OFFSET + ERROUT_FUNC_SIZE;
   parameter                      FUNC_F1ERR_OFFSET = FUNC_F0ERR_OFFSET + FIR0_WIDTH;
   parameter                      FUNC_F2ERR_OFFSET = FUNC_F1ERR_OFFSET + FIR1_WIDTH;
   parameter                      FUNC_RIGHT = FUNC_F2ERR_OFFSET + FIR2_WIDTH - 1;
   // end of func scan chain ordering

   //---------------------------------------------------------------------
   // Basic/Misc signals
   wire                           tidn;
   wire                           tiup;
   wire [0:31]                    tidn_32;
   // Clocks
   wire                           func_d1clk;
   wire                           func_d2clk;
   wire [0:`NCLK_WIDTH-1]         func_lclk;
   wire                           func_thold_b;
   wire                           func_force;
   // SCOM
   wire [0:63]                    scomErr_errDbg_status;
   wire [0:SCPAR_ERR_RPT_WIDTH-1] sc_reg_par_err_in;
   wire [0:SCPAR_ERR_RPT_WIDTH-1] sc_reg_par_err_out;
   wire [0:SCPAR_ERR_RPT_WIDTH-1] sc_reg_par_err_out_q;
   wire [0:SCPAR_ERR_RPT_WIDTH-1] sc_reg_par_err_hold;
   wire                           scom_reg_parity_err;
   wire                           fir_regs_parity_err;
   wire [0:SCACK_ERR_RPT_WIDTH-1] sc_reg_ack_err_in;
   wire [0:SCACK_ERR_RPT_WIDTH-1] sc_reg_ack_err_out;
   wire [0:SCACK_ERR_RPT_WIDTH-1] sc_reg_ack_err_out_q;
   wire [0:SCACK_ERR_RPT_WIDTH-1] sc_reg_ack_err_hold;
   wire                           scom_reg_ack_err;
   // FIR0
   wire [0:FIR0_WIDTH-1]          fir0_errors;
   wire [0:FIR0_WIDTH-1]          fir0_errors_q;
   wire [0:FIR0_WIDTH-1]          fir0_fir_out;
   wire [0:FIR0_WIDTH-1]          fir0_act0_out;
   wire [0:FIR0_WIDTH-1]          fir0_act1_out;
   wire [0:FIR0_WIDTH-1]          fir0_mask_out;
   wire [0:FIR0_WIDTH-1]          fir0_scrdata;
   wire [0:31]                    fir0_fir_scom_out;
   wire [0:31]                    fir0_act0_scom_out;
   wire [0:31]                    fir0_act1_scom_out;
   wire [0:31]                    fir0_mask_scom_out;
   wire                           fir0_xstop_err;
   wire                           fir0_recov_err;
   wire                           fir0_lxstop_mchk;
   wire                           fir0_trace_error;
   wire                           fir0_block_on_checkstop;
   wire [0:2]                     fir0_fir_parity_check;
   wire [0:FIR0_WIDTH-1]          fir0_recoverable_errors;
   wire [0:1]                     fir0_recov_err_in;
   wire [0:1]                     fir0_recov_err_q;
   wire                           fir0_recov_err_pulse;
   wire [32:32+FIR0_WIDTH-1]      fir0_enabled_checkstops;
   // FIR1
   wire [0:FIR1_WIDTH-1]          fir1_errors;
   wire [0:FIR1_WIDTH-1]          fir1_errors_q;
   wire [0:FIR1_WIDTH-1]          fir1_fir_out;
   wire [0:FIR1_WIDTH-1]          fir1_act0_out;
   wire [0:FIR1_WIDTH-1]          fir1_act1_out;
   wire [0:FIR1_WIDTH-1]          fir1_mask_out;
   wire [0:FIR1_WIDTH-1]          fir1_scrdata;
   wire [0:31]                    fir1_fir_scom_out;
   wire [0:31]                    fir1_act0_scom_out;
   wire [0:31]                    fir1_act1_scom_out;
   wire [0:31]                    fir1_mask_scom_out;
   wire                           fir1_xstop_err;
   wire                           fir1_recov_err;
   wire                           fir1_lxstop_mchk;
   wire                           fir1_trace_error;
   wire                           fir1_block_on_checkstop;
   wire [0:2]                     fir1_fir_parity_check;
   wire [0:FIR1_WIDTH-1]          fir1_recoverable_errors;
   wire [0:1]                     fir1_recov_err_in;
   wire [0:1]                     fir1_recov_err_q;
   wire                           fir1_recov_err_pulse;
   wire [32:32+FIR1_WIDTH-1]      fir1_enabled_checkstops;
   // FIR2
   wire [0:FIR2_WIDTH-1]          fir2_errors;
   wire [0:FIR2_WIDTH-1]          fir2_errors_q;
   wire [0:FIR2_WIDTH-1]          fir2_fir_out;
   wire [0:FIR2_WIDTH-1]          fir2_act0_out;
   wire [0:FIR2_WIDTH-1]          fir2_act1_out;
   wire [0:FIR2_WIDTH-1]          fir2_mask_out;
   wire [0:FIR2_WIDTH-1]          fir2_scrdata;
   wire [0:31]                    fir2_fir_scom_out;
   wire [0:31]                    fir2_act0_scom_out;
   wire [0:31]                    fir2_act1_scom_out;
   wire [0:31]                    fir2_mask_scom_out;
   wire                           fir2_xstop_err;
   wire                           fir2_recov_err;
   wire                           fir2_lxstop_mchk;
   wire                           fir2_trace_error;
   wire                           fir2_block_on_checkstop;
   wire [0:2]                     fir2_fir_parity_check;
   wire [0:FIR2_WIDTH-1]          fir2_recoverable_errors;
   wire [0:1]                     fir2_recov_err_in;
   wire [0:1]                     fir2_recov_err_q;
   wire                           fir2_recov_err_pulse;
   wire [32:32+FIR2_WIDTH-1]      fir2_enabled_checkstops;
   // Error Inject Shutoff
   wire                           injoff_icache_parity;
   wire                           injoff_icachedir_parity;
   wire                           injoff_icachedir_multihit;
   wire                           injoff_dcache_parity;
   wire                           injoff_dcachedir_ldp_parity;
   wire                           injoff_dcachedir_stp_parity;
   wire                           injoff_dcachedir_ldp_multihit;
   wire                           injoff_dcachedir_stp_multihit;
   wire                           injoff_scomreg_parity;
   wire                           injoff_prefetcher_parity;
   wire				  injoff_relq_parity;
   wire                           injoff_sprg_ecc_t0;
   wire                           injoff_fx0regfile_par_t0;
   wire                           injoff_fx1regfile_par_t0;
   wire                           injoff_lqregfile_par_t0;
   wire                           injoff_furegfile_par_t0;
   wire				  injoff_cpArray_par_t0;
   wire                           injoff_llbust_attempt_t0;
   wire                           injoff_llbust_failed_t0;
   wire                           injoff_sprg_ecc_t1;
   wire                           injoff_fx0regfile_par_t1;
   wire                           injoff_fx1regfile_par_t1;
   wire                           injoff_lqregfile_par_t1;
   wire                           injoff_furegfile_par_t1;
   wire				  injoff_cpArray_par_t1;
   wire                           injoff_llbust_attempt_t1;
   wire                           injoff_llbust_failed_t1;
   wire [0:22+9*(`THREADS-1)]     error_inject_shutoff;
   // MISC
   wire [0:2]                     recov_err_int;
   wire [0:2]                     xstop_err_int;
   wire [0:2]                     xstop_err_q;
   wire [0:2]                     xstop_out_d;
   wire [0:2]                     xstop_out_q;
   wire [0:2]                     lxstop_err_int;
   wire [0:2]                     lxstop_out_d;
   wire [0:2]                     lxstop_out_q;
   wire                           xstop_err_common;
   wire [0:`THREADS-1]            xstop_err_per_thread;
   wire [0:1] 			  dbg_thread_xstop_err;
   wire                           any_fir_xstop_int;
   wire                           an_ac_checkstop_q;
   wire                           maxRecErrCntrValue_errrpt;
   wire                           block_xstop_in_ram_mode;
   wire                           livelock_active_d;
   wire                           livelock_active_q;
   wire [0:BCFG_RIGHT]            bcfg_siv;
   wire [0:BCFG_RIGHT]            bcfg_sov;
   wire [0:FUNC_RIGHT]            func_siv;
   wire [0:FUNC_RIGHT]            func_sov;


// Get rid of sinkless net messages
// synopsys translate_off
(* analysis_not_referenced="true" *)
// synopsys translate_on
   wire                           unused_signals;
   assign unused_signals = ((|fir0_scrdata) | (|fir1_scrdata) | (|fir2_scrdata )    | fir0_recoverable_errors[0]  |
   			     sc_addr_v[9]   |  sc_addr_v[19]  | (|sc_addr_v[29:63]) | (|sc_wdata[0:31]));



//---------------------------------------------------------------------
//!! Bugspray Include: pcq_regs_fir;


   assign tiup = 1'b1;
   assign tidn = 1'b0;
   assign tidn_32 = {32{1'b0}};


//=====================================================================
// FIR0 Instantiation
//=====================================================================
   pcq_local_fir2 #(
		    .WIDTH(FIR0_WIDTH),
		    .IMPL_LXSTOP_MCHK(1'b1),
                    .USE_RECOV_RESET(1'b0),
		    .FIR_INIT(FIR0_INIT),
		    .FIR_MASK_INIT(FIR0MASK_INIT),
		    .FIR_MASK_PAR_INIT(FIR0MASK_PAR_INIT),
		    .FIR_ACTION0_INIT(FIR0ACT0_INIT),
		    .FIR_ACTION0_PAR_INIT(FIR0ACT0_PAR_INIT),
		    .FIR_ACTION1_INIT(FIR0ACT1_INIT),
		    .FIR_ACTION1_PAR_INIT(FIR0ACT1_PAR_INIT)
		    ) FIR0(
      //  Global lines for clocking and scan control
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .lcb_clkoff_dc_b(lcb_clkoff_dc_b),
      .lcb_mpw1_dc_b(lcb_mpw1_dc_b),
      .lcb_mpw2_dc_b(lcb_mpw2_dc_b),
      .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc),
      .lcb_act_dis_dc(lcb_act_dis_dc),
      .lcb_sg_0(lcb_sg_0),
      .lcb_func_slp_sl_thold_0(lcb_func_slp_sl_thold_0),	// not power-managed
      .lcb_cfg_slp_sl_thold_0(lcb_cfg_slp_sl_thold_0),		// not power-managed
      .mode_scan_siv(bcfg_siv[BCFG_FIR0_OFFSET:BCFG_FIR0_OFFSET + FIR0_BCFG_SIZE - 1]),
      .mode_scan_sov(bcfg_sov[BCFG_FIR0_OFFSET:BCFG_FIR0_OFFSET + FIR0_BCFG_SIZE - 1]),
      .func_scan_siv(func_siv[FUNC_FIR0_OFFSET:FUNC_FIR0_OFFSET + FIR0_FUNC_SIZE - 1]),
      .func_scan_sov(func_sov[FUNC_FIR0_OFFSET:FUNC_FIR0_OFFSET + FIR0_FUNC_SIZE - 1]),
      // external interface
      .error_in(fir0_errors_q),					// needs to be directly off a latch for timing
      .xstop_err(fir0_xstop_err),				// checkstop   output to Global FIR
      .recov_err(fir0_recov_err),				// recoverable output to Global FIR
      .lxstop_mchk(fir0_lxstop_mchk),				// use ONLY if impl_lxstop_mchk = true
      .trace_error(fir0_trace_error),				// connect to error_input of closest trdata macro
      .sys_xstop_in(fir0_block_on_checkstop),			// freeze FIR on other checkstop errors
      .recov_reset(tidn),					// only needed if use_recov_reset = true
      .fir_out(fir0_fir_out),					// output of current FIR state if needed
      .act0_out(fir0_act0_out),					// output of current FIR ACT0 if needed
      .act1_out(fir0_act1_out),					// output of current FIR ACT1 if needed
      .mask_out(fir0_mask_out),					// output of current FIR MASK if needed
      // scom register connections
      .sc_parity_error_inject(sc_parity_error_inject),		// Force parity error
      .sc_active(sc_active),
      .sc_wr_q(sc_wr_q),
      .sc_addr_v(sc_addr_v[0:8]),
      .sc_wdata(sc_wdata[32:32 + FIR0_WIDTH - 1]),
      .sc_rdata(fir0_scrdata),
      .fir_parity_check(fir0_fir_parity_check)
   );

   //---------------------------------------------------------------------
   // Error Input Facility
   assign fir0_errors = {
     maxRecErrCntrValue_errrpt,		iu_pc_err_icache_parity,	   //  0:1
     iu_pc_err_icachedir_parity,	iu_pc_err_icachedir_multihit,      //  2:3
     lq_pc_err_dcache_parity,		lq_pc_err_dcachedir_ldp_parity,    //  4:5
     lq_pc_err_dcachedir_stp_parity,	lq_pc_err_dcachedir_ldp_multihit,  //  6:7
     lq_pc_err_dcachedir_stp_multihit,	iu_pc_err_ierat_parity,		   //  8:9
     iu_pc_err_ierat_multihit,		lq_pc_err_derat_parity,            // 10:11
     lq_pc_err_derat_multihit,		mm_pc_err_tlb_parity,              // 12:13
     mm_pc_err_tlb_multihit,		mm_pc_err_tlb_lru_parity,          // 14:15
     mm_pc_err_local_snoop_reject,	lq_pc_err_l2intrf_ecc,             // 16:17
     lq_pc_err_l2intrf_ue,		lq_pc_err_invld_reld,              // 18:19
     lq_pc_err_l2credit_overrun,	scom_reg_parity_err,               // 20:21
     scom_reg_ack_err,			fir_regs_parity_err,               // 22:23
     lq_pc_err_prefetcher_parity,	lq_pc_err_relq_parity,		   // 24:25
     iu_pc_err_btb_parity,		fir0_errors_q[27]		   // 26:27  (spares: wrapback dout=>din)
   };

   //---------------------------------------------------------------------
   // Block FIR on checkstop (external input or from other FIRs)
   assign fir0_block_on_checkstop = an_ac_checkstop_q | xstop_err_q[1] | xstop_err_q[2];


//=====================================================================
// FIR1 Instantiation
//=====================================================================
   pcq_local_fir2 #(
		    .WIDTH(FIR1_WIDTH),
		    .IMPL_LXSTOP_MCHK(1'b1),
                    .USE_RECOV_RESET(1'b0),
		    .FIR_INIT(FIR1_INIT),
		    .FIR_MASK_INIT(FIR1MASK_INIT),
		    .FIR_MASK_PAR_INIT(FIR1MASK_PAR_INIT),
		    .FIR_ACTION0_INIT(FIR1ACT0_INIT),
		    .FIR_ACTION0_PAR_INIT(FIR1ACT0_PAR_INIT),
		    .FIR_ACTION1_INIT(FIR1ACT1_INIT),
		    .FIR_ACTION1_PAR_INIT(FIR1ACT1_PAR_INIT)
		    ) FIR1(
      //  Global lines for clocking and scan control
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .lcb_clkoff_dc_b(lcb_clkoff_dc_b),
      .lcb_mpw1_dc_b(lcb_mpw1_dc_b),
      .lcb_mpw2_dc_b(lcb_mpw2_dc_b),
      .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc),
      .lcb_act_dis_dc(lcb_act_dis_dc),
      .lcb_sg_0(lcb_sg_0),
      .lcb_func_slp_sl_thold_0(lcb_func_slp_sl_thold_0),	// not power-managed
      .lcb_cfg_slp_sl_thold_0(lcb_cfg_slp_sl_thold_0),		// not power-managed
      .mode_scan_siv(bcfg_siv[BCFG_FIR1_OFFSET:BCFG_FIR1_OFFSET + FIR1_BCFG_SIZE - 1]),
      .mode_scan_sov(bcfg_sov[BCFG_FIR1_OFFSET:BCFG_FIR1_OFFSET + FIR1_BCFG_SIZE - 1]),
      .func_scan_siv(func_siv[FUNC_FIR1_OFFSET:FUNC_FIR1_OFFSET + FIR1_FUNC_SIZE - 1]),
      .func_scan_sov(func_sov[FUNC_FIR1_OFFSET:FUNC_FIR1_OFFSET + FIR1_FUNC_SIZE - 1]),
      // external interface
      .error_in(fir1_errors_q),					// needs to be directly off a latch for timing
      .xstop_err(fir1_xstop_err),				// checkstop   output to Global FIR
      .recov_err(fir1_recov_err),				// recoverable output to Global FIR
      .lxstop_mchk(fir1_lxstop_mchk),				// use ONLY if impl_lxstop_mchk = true
      .trace_error(fir1_trace_error),				// connect to error_input of closest trdata macro
      .sys_xstop_in(fir1_block_on_checkstop),			// freeze FIR on other checkstop errors
      .recov_reset(tidn),					// only needed if use_recov_reset = true
      .fir_out(fir1_fir_out),					// output of current FIR state if needed
      .act0_out(fir1_act0_out),					// output of current FIR ACT0 if needed
      .act1_out(fir1_act1_out),					// output of current FIR ACT1 if needed
      .mask_out(fir1_mask_out),					// output of current FIR MASK if needed
      // scom register connections
      .sc_parity_error_inject(sc_parity_error_inject),		// Force parity error
      .sc_active(sc_active),
      .sc_wr_q(sc_wr_q),
      .sc_addr_v(sc_addr_v[10:18]),
      .sc_wdata(sc_wdata[32:32 + FIR1_WIDTH - 1]),
      .sc_rdata(fir1_scrdata),
      .fir_parity_check(fir1_fir_parity_check)
   );

   //---------------------------------------------------------------------
   // Error Input Facility
   assign fir1_errors = {
     xu_pc_err_sprg_ecc[0],			xu_pc_err_sprg_ue[0],		//  0:1
     xu_pc_err_regfile_parity[0],		xu_pc_err_regfile_ue[0],	//  2:3
     lq_pc_err_regfile_parity[0],		lq_pc_err_regfile_ue[0],	//  4:5
     fu_pc_err_regfile_parity[0],		fu_pc_err_regfile_ue[0],	//  6:7
     iu_pc_err_cpArray_parity[0],		iu_pc_err_ucode_illegal[0],	//  8:9
     iu_pc_err_mchk_disabled[0],		xu_pc_err_llbust_attempt[0],    // 10:11
     xu_pc_err_llbust_failed[0],		xu_pc_err_wdt_reset[0],         // 12:13
     iu_pc_err_debug_event[0],			fir1_errors_q[15:19]		// 14:19  (spares: wrapback dout=>din)
   };

   //---------------------------------------------------------------------
   // Block FIR on checkstop (external input or from other FIRs)
   assign fir1_block_on_checkstop = an_ac_checkstop_q | xstop_err_q[0] | xstop_err_q[2];


//=====================================================================
// FIR2 Instantiation
//=====================================================================
   pcq_local_fir2 #(
		    .WIDTH(FIR2_WIDTH),
		    .IMPL_LXSTOP_MCHK(1'b1),
                    .USE_RECOV_RESET(1'b0),
		    .FIR_INIT(FIR2_INIT),
		    .FIR_MASK_INIT(FIR2MASK_INIT),
		    .FIR_MASK_PAR_INIT(FIR2MASK_PAR_INIT),
		    .FIR_ACTION0_INIT(FIR2ACT0_INIT),
		    .FIR_ACTION0_PAR_INIT(FIR2ACT0_PAR_INIT),
		    .FIR_ACTION1_INIT(FIR2ACT1_INIT),
		    .FIR_ACTION1_PAR_INIT(FIR2ACT1_PAR_INIT)
		    ) FIR2(
      //  Global lines for clocking and scan control
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .lcb_clkoff_dc_b(lcb_clkoff_dc_b),
      .lcb_mpw1_dc_b(lcb_mpw1_dc_b),
      .lcb_mpw2_dc_b(lcb_mpw2_dc_b),
      .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc),
      .lcb_act_dis_dc(lcb_act_dis_dc),
      .lcb_sg_0(lcb_sg_0),
      .lcb_func_slp_sl_thold_0(lcb_func_slp_sl_thold_0),	// not power-managed
      .lcb_cfg_slp_sl_thold_0(lcb_cfg_slp_sl_thold_0),		// not power-managed
      .mode_scan_siv(bcfg_siv[BCFG_FIR2_OFFSET:BCFG_FIR2_OFFSET + FIR2_BCFG_SIZE - 1]),
      .mode_scan_sov(bcfg_sov[BCFG_FIR2_OFFSET:BCFG_FIR2_OFFSET + FIR2_BCFG_SIZE - 1]),
      .func_scan_siv(func_siv[FUNC_FIR2_OFFSET:FUNC_FIR2_OFFSET + FIR2_FUNC_SIZE - 1]),
      .func_scan_sov(func_sov[FUNC_FIR2_OFFSET:FUNC_FIR2_OFFSET + FIR2_FUNC_SIZE - 1]),
      // external interface
      .error_in(fir2_errors_q),					// needs to be directly off a latch for timing
      .xstop_err(fir2_xstop_err),				// checkstop   output to Global FIR
      .recov_err(fir2_recov_err),				// recoverable output to Global FIR
      .lxstop_mchk(fir2_lxstop_mchk),				// use ONLY if impl_lxstop_mchk = true
      .trace_error(fir2_trace_error),				// connect to error_input of closest trdata macro
      .sys_xstop_in(fir2_block_on_checkstop),			// freeze FIR on other checkstop errors
      .recov_reset(tidn),					// only needed if use_recov_reset = true
      .fir_out(fir2_fir_out),					// output of current FIR state if needed
      .act0_out(fir2_act0_out),					// output of current FIR ACT0 if needed
      .act1_out(fir2_act1_out),					// output of current FIR ACT1 if needed
      .mask_out(fir2_mask_out),					// output of current FIR MASK if needed
      // scom register connections
      .sc_parity_error_inject(sc_parity_error_inject),		// Force parity error
      .sc_active(sc_active),
      .sc_wr_q(sc_wr_q),
      .sc_addr_v(sc_addr_v[20:28]),
      .sc_wdata(sc_wdata[32:32 + FIR2_WIDTH - 1]),
      .sc_rdata(fir2_scrdata),
      .fir_parity_check(fir2_fir_parity_check)
   );

   //---------------------------------------------------------------------
   // Error Input Facility
   generate
      if (`THREADS == 1)
      begin : FIR2ERR_1T
         assign fir2_errors = 1'b0;
      end
   endgenerate

   generate
      if (`THREADS == 2)
      begin : FIR2ERR_2T
         assign fir2_errors = {
	  xu_pc_err_sprg_ecc[1],	xu_pc_err_sprg_ue[1],		   //  0:1
	  xu_pc_err_regfile_parity[1],	xu_pc_err_regfile_ue[1],           //  2:3
	  lq_pc_err_regfile_parity[1],	lq_pc_err_regfile_ue[1],           //  4:5
	  fu_pc_err_regfile_parity[1],	fu_pc_err_regfile_ue[1],           //  6:7
	  iu_pc_err_cpArray_parity[1],	iu_pc_err_ucode_illegal[1],        //  8:9
	  iu_pc_err_mchk_disabled[1],	xu_pc_err_llbust_attempt[1],       // 10:11
	  xu_pc_err_llbust_failed[1],	xu_pc_err_wdt_reset[1],            // 12:13
	  iu_pc_err_debug_event[1],	fir2_errors_q[15:19]		   // 14:19  (spares: wrapback dout=>din)
	};
      end
   endgenerate

   //---------------------------------------------------------------------
   // Block FIR on checkstop (external input or from other FIRs)
   assign fir2_block_on_checkstop = an_ac_checkstop_q | xstop_err_q[0] | xstop_err_q[1];

//=====================================================================
// SCOM Register Read
//=====================================================================
   assign scomErr_errDbg_status   =  {	sc_reg_par_err_hold[0:SCPAR_ERR_RPT_WIDTH - 1],
                                	sc_reg_ack_err_hold[0:SCACK_ERR_RPT_WIDTH - 1],
                                	{32-(SCPAR_ERR_RPT_WIDTH+SCACK_ERR_RPT_WIDTH) {1'b0}},
					errDbg_out
                              	     };

   assign fir0_fir_scom_out  = {fir0_fir_out,  {32-FIR0_WIDTH {1'b0}}};
   assign fir0_act0_scom_out = {fir0_act0_out, {32-FIR0_WIDTH {1'b0}}};
   assign fir0_act1_scom_out = {fir0_act1_out, {32-FIR0_WIDTH {1'b0}}};
   assign fir0_mask_scom_out = {fir0_mask_out, {32-FIR0_WIDTH {1'b0}}};

   assign fir1_fir_scom_out  = {fir1_fir_out,  {32-FIR1_WIDTH {1'b0}}};
   assign fir1_act0_scom_out = {fir1_act0_out, {32-FIR1_WIDTH {1'b0}}};
   assign fir1_act1_scom_out = {fir1_act1_out, {32-FIR1_WIDTH {1'b0}}};
   assign fir1_mask_scom_out = {fir1_mask_out, {32-FIR1_WIDTH {1'b0}}};

   assign fir2_fir_scom_out  = {fir2_fir_out,  {32-FIR2_WIDTH {1'b0}}};
   assign fir2_act0_scom_out = {fir2_act0_out, {32-FIR2_WIDTH {1'b0}}};
   assign fir2_act1_scom_out = {fir2_act1_out, {32-FIR2_WIDTH {1'b0}}};
   assign fir2_mask_scom_out = {fir2_mask_out, {32-FIR2_WIDTH {1'b0}}};

   assign sc_rdata[0:SCRDATA_SIZE-1] =
                   ({SCRDATA_SIZE {sc_addr_v[0] }} & {tidn_32, fir0_fir_scom_out })	     |
                   ({SCRDATA_SIZE {sc_addr_v[3] }} & {tidn_32, fir0_act0_scom_out})	     |
                   ({SCRDATA_SIZE {sc_addr_v[4] }} & {tidn_32, fir0_act1_scom_out})	     |
                   ({SCRDATA_SIZE {sc_addr_v[6] }} & {tidn_32, fir0_mask_scom_out})	     |
                   ({SCRDATA_SIZE {sc_addr_v[10]}} & {tidn_32, fir1_fir_scom_out })	     |
                   ({SCRDATA_SIZE {sc_addr_v[13]}} & {tidn_32, fir1_act0_scom_out})	     |
                   ({SCRDATA_SIZE {sc_addr_v[14]}} & {tidn_32, fir1_act1_scom_out})	     |
                   ({SCRDATA_SIZE {sc_addr_v[16]}} & {tidn_32, fir1_mask_scom_out})	     |
                   ({SCRDATA_SIZE {sc_addr_v[20]}} & {tidn_32, fir2_fir_scom_out })	     |
                   ({SCRDATA_SIZE {sc_addr_v[23]}} & {tidn_32, fir2_act0_scom_out})	     |
                   ({SCRDATA_SIZE {sc_addr_v[24]}} & {tidn_32, fir2_act1_scom_out})	     |
                   ({SCRDATA_SIZE {sc_addr_v[26]}} & {tidn_32, fir2_mask_scom_out})	     |
                   ({SCRDATA_SIZE {sc_addr_v[5] }} &  scomErr_errDbg_status)		     |
                   ({SCRDATA_SIZE {sc_addr_v[19]}} & {fir0_fir_scom_out, fir1_fir_scom_out}) ;


//=====================================================================
// Error Related Signals
//=====================================================================
   // SCOM parity error reporting macro
   assign sc_reg_par_err_in = {scom_reg_par_checks, fir0_fir_parity_check, fir1_fir_parity_check, fir2_fir_parity_check};

   assign scom_reg_parity_err = (|sc_reg_par_err_out[0:1]);
   assign fir_regs_parity_err = (|sc_reg_par_err_out[2:10]);

   tri_err_rpt #(.WIDTH(SCPAR_ERR_RPT_WIDTH), .MASK_RESET_VALUE(SCPAR_RPT_RESET_VALUE), .INLINE(1'b0)) scom_err(
   // use to bundle error reporting checkers of the same exact type
      .vd(vdd),
      .gd(gnd),
      .err_d1clk(cfgslp_d1clk),		// CAUTION: if LCB uses powersavings,
      .err_d2clk(cfgslp_d2clk),		//          errors must always get reported
      .err_lclk(cfgslp_lclk),
      .err_scan_in(bcfg_siv[ BCFG_ERPT1_HLD_OFFSET:BCFG_ERPT1_HLD_OFFSET + SCPAR_ERR_RPT_WIDTH - 1]),
      .err_scan_out(bcfg_sov[BCFG_ERPT1_HLD_OFFSET:BCFG_ERPT1_HLD_OFFSET + SCPAR_ERR_RPT_WIDTH - 1]),
      .mode_dclk(cfg_slat_d2clk),
      .mode_lclk(cfg_slat_lclk),
      .mode_scan_in(bcfg_siv[ BCFG_ERPT1_MSK_OFFSET:BCFG_ERPT1_MSK_OFFSET + SCPAR_ERR_RPT_WIDTH - 1]),
      .mode_scan_out(bcfg_sov[BCFG_ERPT1_MSK_OFFSET:BCFG_ERPT1_MSK_OFFSET + SCPAR_ERR_RPT_WIDTH - 1]),
      .err_in(sc_reg_par_err_in),
      .err_out(sc_reg_par_err_out),
      .hold_out(sc_reg_par_err_hold)
   );

   //---------------------------------------------------------------------
   // SCOM control error reporting macro
   assign sc_reg_ack_err_in = {scom_ack_error, scom_sat_fsm_error};
   assign scom_reg_ack_err  = (|sc_reg_ack_err_out);

   tri_err_rpt #(.WIDTH(SCACK_ERR_RPT_WIDTH), .MASK_RESET_VALUE(SCACK_RPT_RESET_VALUE), .INLINE(1'b0)) sc_ack_err(
      // use to bundle error reporting checkers of the same exact type
      .vd(vdd),
      .gd(gnd),
      .err_d1clk(cfgslp_d1clk),		// CAUTION: if LCB uses powersavings,
      .err_d2clk(cfgslp_d2clk),		//          errors must always get reported
      .err_lclk(cfgslp_lclk),
      .err_scan_in(bcfg_siv[ BCFG_ERPT2_HLD_OFFSET:BCFG_ERPT2_HLD_OFFSET + SCACK_ERR_RPT_WIDTH - 1]),
      .err_scan_out(bcfg_sov[BCFG_ERPT2_HLD_OFFSET:BCFG_ERPT2_HLD_OFFSET + SCACK_ERR_RPT_WIDTH - 1]),
      .mode_dclk(cfg_slat_d2clk),
      .mode_lclk(cfg_slat_lclk),
      .mode_scan_in(bcfg_siv[ BCFG_ERPT2_MSK_OFFSET:BCFG_ERPT2_MSK_OFFSET + SCACK_ERR_RPT_WIDTH - 1]),
      .mode_scan_out(bcfg_sov[BCFG_ERPT2_MSK_OFFSET:BCFG_ERPT2_MSK_OFFSET + SCACK_ERR_RPT_WIDTH - 1]),
      .err_in(sc_reg_ack_err_in),
      .err_out(sc_reg_ack_err_out),
      .hold_out(sc_reg_ack_err_hold)
   );

   //---------------------------------------------------------------------
   // Other error reporting macros

   tri_direct_err_rpt #(.WIDTH(1)) misc_dir_err(
      .vd(vdd),
      .gd(gnd),
      .err_in(rg_rg_maxRecErrCntrValue),
      .err_out(maxRecErrCntrValue_errrpt)
   );

   //---------------------------------------------------------------------
   // Error related facilities used in other functions
   // FIR0 Errors that increment the recoverable error counter (Act0=0; Act1=1)
   assign fir0_recoverable_errors = fir0_errors_q & (~fir0_act0_out) & fir0_act1_out & (~fir0_mask_out);
   // Leaving maxRecErrCntrValue (FIR0(0)) out of input that gates recoverable error counter.
   assign fir0_recov_err_in[0] = (|fir0_recoverable_errors[1:FIR0_WIDTH - 1]);
   assign fir0_recov_err_in[1] = fir0_recov_err_q[0];
   // Only indicates 1 recoverable error pulse if error input active multiple cycles
   assign fir0_recov_err_pulse = fir0_recov_err_q[0] & (~fir0_recov_err_q[1]);

   // FIR1 Errors that increment the recoverable error counter (Act0=0; Act1=1)
   assign fir1_recoverable_errors = fir1_errors_q & (~fir1_act0_out) & fir1_act1_out & (~fir1_mask_out);
   assign fir1_recov_err_in[0] = (|fir1_recoverable_errors);
   assign fir1_recov_err_in[1] = fir1_recov_err_q[0];
   // Only indicates 1 recoverable error pulse if error input active multiple cycles
   assign fir1_recov_err_pulse = fir1_recov_err_q[0] & (~fir1_recov_err_q[1]);

   // FIR2 Errors that increment the recoverable error counter (Act0=0; Act1=1)
   assign fir2_recoverable_errors = fir2_errors_q & (~fir2_act0_out) & fir2_act1_out & (~fir2_mask_out);
   assign fir2_recov_err_in[0] = (|fir2_recoverable_errors);
   assign fir2_recov_err_in[1] = fir2_recov_err_q[0];
   // Only indicates 1 recoverable error pulse if error input active multiple cycles
   assign fir2_recov_err_pulse = fir2_recov_err_q[0] & (~fir2_recov_err_q[1]);

   // Combined recoverable error signal from all the FIRs
   assign recov_err_int = {fir0_recov_err, fir1_recov_err, fir2_recov_err};

   // Enabled checkstop (system and local) errors used to stop failing thread  (Act0=1; Act1=X)
   assign fir0_enabled_checkstops = fir0_fir_out & fir0_act0_out & (~fir0_mask_out);
   assign fir1_enabled_checkstops = fir1_fir_out & fir1_act0_out & (~fir1_mask_out);
   assign fir2_enabled_checkstops = fir2_fir_out & fir2_act0_out & (~fir2_mask_out);

   //---------------------------------------------------------------------
   // Determines how errors will force failing thread(s) to stop if configured as checkstop:
   // This is based on the error bit definition in each FIR (thread specific or per core).
   //
   // Per core     FIR0
   // T0           FIR1
   // T1           FIR2
   //
   assign xstop_err_common = (|fir0_enabled_checkstops);

   assign xstop_err_per_thread[0] = xstop_err_common | (|fir1_enabled_checkstops);

   generate
      if (`THREADS == 2)
      begin : THRDXSTOP_2T
         assign xstop_err_per_thread[1] = xstop_err_common | (|fir2_enabled_checkstops);
      end
   endgenerate

   //---------------------------------------------------------------------
   // Report xstop + lxstop errors to Chiplet FIR.  Can bypass in Ram mode if override signal active.
   assign xstop_err_int[0:2]  = {fir0_xstop_err,   fir1_xstop_err,   fir2_xstop_err};
   assign lxstop_err_int[0:2] = {fir0_lxstop_mchk, fir1_lxstop_mchk, fir2_lxstop_mchk};

   assign any_fir_xstop_int = (|xstop_err_int[0:2]) | (|lxstop_err_int[0:2]);

   assign block_xstop_in_ram_mode = rg_rg_xstop_report_ovride & rg_rg_ram_mode;
   assign xstop_out_d[0:2]  = (block_xstop_in_ram_mode == 1'b0) ? xstop_err_int[0:2]  : 3'b000 ;
   assign lxstop_out_d[0:2] = (block_xstop_in_ram_mode == 1'b0) ? lxstop_err_int[0:2] : 3'b000 ;

   //---------------------------------------------------------------------
   // Error injection shutoff control signals
   assign injoff_icache_parity		= fir0_errors_q[1];
   assign injoff_icachedir_parity	= fir0_errors_q[2];
   assign injoff_icachedir_multihit	= fir0_errors_q[3];
   assign injoff_dcache_parity		= fir0_errors_q[4];
   assign injoff_dcachedir_ldp_parity	= fir0_errors_q[5];
   assign injoff_dcachedir_stp_parity	= fir0_errors_q[6];
   assign injoff_dcachedir_ldp_multihit	= fir0_errors_q[7];
   assign injoff_dcachedir_stp_multihit	= fir0_errors_q[8];
   assign injoff_scomreg_parity		= fir0_errors_q[21];
   assign injoff_prefetcher_parity	= fir0_errors_q[24];
   assign injoff_relq_parity		= fir0_errors_q[25];

   assign injoff_sprg_ecc_t0		= fir1_errors_q[0];
   assign injoff_fx0regfile_par_t0	= fir1_errors_q[2];
   assign injoff_fx1regfile_par_t0	= fir1_errors_q[2];
   assign injoff_lqregfile_par_t0	= fir1_errors_q[4];
   assign injoff_furegfile_par_t0	= fir1_errors_q[6];
   assign injoff_cpArray_par_t0		= fir1_errors_q[8];
   assign injoff_llbust_attempt_t0	= fir1_errors_q[11];
   assign injoff_llbust_failed_t0	= fir1_errors_q[12];

   assign error_inject_shutoff[0:22] = {
                injoff_icache_parity,		injoff_icachedir_parity,	injoff_icachedir_multihit,	//   0:2
		injoff_dcache_parity,		injoff_dcachedir_ldp_parity,	injoff_dcachedir_stp_parity,	//   3:5
		injoff_dcachedir_ldp_multihit,	injoff_dcachedir_stp_multihit,	injoff_scomreg_parity,          //   6:8
		injoff_prefetcher_parity,	injoff_relq_parity,		2'b00,                          //   9:12
                injoff_sprg_ecc_t0,             injoff_fx0regfile_par_t0,	injoff_fx1regfile_par_t0,	//  13:15
                injoff_lqregfile_par_t0,        injoff_furegfile_par_t0,	injoff_llbust_attempt_t0,	//  16:18
                injoff_llbust_failed_t0,        injoff_cpArray_par_t0,		2'b00 };			//  19:22


   generate
      if (`THREADS == 1)
      begin : ERRINJOFF_2T_BYP
         assign injoff_sprg_ecc_t1		= 1'b0;
         assign injoff_fx0regfile_par_t1	= 1'b0;
         assign injoff_fx1regfile_par_t1	= 1'b0;
         assign injoff_lqregfile_par_t1		= 1'b0;
         assign injoff_furegfile_par_t1		= 1'b0;
         assign injoff_llbust_attempt_t1	= 1'b0;
         assign injoff_llbust_failed_t1		= 1'b0;
      end
   endgenerate

   generate
      if (`THREADS > 1)
      begin : ERRINJOFF_2T
         assign injoff_sprg_ecc_t1		= fir2_errors_q[0];
         assign injoff_fx0regfile_par_t1	= fir2_errors_q[2];
         assign injoff_fx1regfile_par_t1	= fir2_errors_q[2];
         assign injoff_lqregfile_par_t1		= fir2_errors_q[4];
         assign injoff_furegfile_par_t1		= fir2_errors_q[6];
	 assign injoff_cpArray_par_t1		= fir2_errors_q[8];
         assign injoff_llbust_attempt_t1	= fir2_errors_q[11];
         assign injoff_llbust_failed_t1		= fir2_errors_q[12];

         assign error_inject_shutoff[23:31] = {
	           injoff_sprg_ecc_t1,		injoff_fx0regfile_par_t1,   injoff_fx1regfile_par_t1,	//  23:25
		   injoff_lqregfile_par_t1,	injoff_furegfile_par_t1,    injoff_llbust_attempt_t1,	//  26:28
		   injoff_llbust_failed_t1,	injoff_cpArray_par_t1,	    1'b0 };			//  29:31
      end
   endgenerate

   //---------------------------------------------------------------------
   // Livelock error pulses; ORed together and sent to L2 hang detect logic.
   assign livelock_active_d =  (|xu_pc_err_llbust_attempt) | (|xu_pc_err_llbust_failed);

//=====================================================================
// Output Assignments
//=====================================================================
   assign ac_an_checkstop	= xstop_out_q[0:2];

   assign ac_an_local_checkstop	= lxstop_out_q[0:2];

   assign ac_an_recov_err	= recov_err_int[0:2];

   assign ac_an_trace_error	= fir0_trace_error | fir1_trace_error | fir2_trace_error;

   assign rg_rg_xstop_err	= xstop_err_per_thread[0:`THREADS - 1];

   assign rg_rg_any_fir_xstop	= any_fir_xstop_int;

   assign rg_rg_ram_mode_xstop	= rg_rg_ram_mode & any_fir_xstop_int;

   assign rg_rg_errinj_shutoff	= error_inject_shutoff;

   assign rg_rg_gateRecErrCntr	= fir0_recov_err_pulse | fir1_recov_err_pulse | fir2_recov_err_pulse;

   assign ac_an_livelock_active	= livelock_active_q;

//=====================================================================
// Trace/Trigger Signals
//=====================================================================
   assign dbg_fir0_err = fir0_errors_q;

   assign dbg_fir1_err = fir1_errors_q;


   assign dbg_fir_misc =
   	  {
	    xstop_err_int[0:2],					//  0:2
	    lxstop_err_int[0:2],				//  3:5
	    recov_err_int[0:2],					//  6:8
	    fir0_recov_err_pulse,		       	    	//  9
	    fir1_recov_err_pulse,		       	    	// 10
	    fir2_recov_err_pulse,		       	    	// 11
	    block_xstop_in_ram_mode,		       	    	// 12
	    dbg_thread_xstop_err[0:1]		            	// 13:14
         };


   generate
      if (`THREADS == 1)
      	begin : DBG_1T
   	 assign dbg_fir2_err 		= {FIR1_WIDTH {1'b0}};
	 assign dbg_thread_xstop_err	= {xstop_err_per_thread[0], 1'b0};
      	end
      else
       	begin : DBG_2T
  	 assign dbg_fir2_err 		= fir2_errors_q;
	 assign dbg_thread_xstop_err	= xstop_err_per_thread[0:1];
      	end
   endgenerate


//=====================================================================
// Latches
//=====================================================================
   tri_nlat_scan #(.WIDTH(ERROUT_FUNC_SIZE), .INIT({ERROUT_FUNC_SIZE {1'b0}})) error_out(
      .d1clk(func_d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(func_lclk),
      .d2clk(func_d2clk),
      .scan_in(func_siv[ FUNC_ERROUT_OFFSET:FUNC_ERROUT_OFFSET + ERROUT_FUNC_SIZE - 1]),
      .scan_out(func_sov[FUNC_ERROUT_OFFSET:FUNC_ERROUT_OFFSET + ERROUT_FUNC_SIZE - 1]),

      .din({xstop_err_int,	xstop_out_d,		 lxstop_out_d,
	    fir0_recov_err_in,	fir1_recov_err_in,	 fir2_recov_err_in,
            an_ac_checkstop,	sc_reg_par_err_out,	 sc_reg_ack_err_out,
	    livelock_active_d 	}),


      .q(  {xstop_err_q,	xstop_out_q,		 lxstop_out_q,
	    fir0_recov_err_q,	fir1_recov_err_q,	 fir2_recov_err_q,
            an_ac_checkstop_q,	sc_reg_par_err_out_q,    sc_reg_ack_err_out_q,
	    livelock_active_q 	})
   );

   tri_nlat_scan #(.WIDTH(FIR0_WIDTH), .INIT(FIR0_INIT)) f0err_out(
      .d1clk(func_d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(func_lclk),
      .d2clk(func_d2clk),
      .scan_in(func_siv[ FUNC_F0ERR_OFFSET:FUNC_F0ERR_OFFSET + FIR0_WIDTH - 1]),
      .scan_out(func_sov[FUNC_F0ERR_OFFSET:FUNC_F0ERR_OFFSET + FIR0_WIDTH - 1]),
      .din(fir0_errors),
      .q(fir0_errors_q)
   );

   tri_nlat_scan #(.WIDTH(FIR1_WIDTH), .INIT(FIR1_INIT)) f1err_out(
      .d1clk(func_d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(func_lclk),
      .d2clk(func_d2clk),
      .scan_in(func_siv[ FUNC_F1ERR_OFFSET:FUNC_F1ERR_OFFSET + FIR1_WIDTH - 1]),
      .scan_out(func_sov[FUNC_F1ERR_OFFSET:FUNC_F1ERR_OFFSET + FIR1_WIDTH - 1]),
      .din(fir1_errors),
      .q(fir1_errors_q)
   );

   tri_nlat_scan #(.WIDTH(FIR2_WIDTH), .INIT(FIR2_INIT)) f2err_out(
      .d1clk(func_d1clk),
      .vd(vdd),
      .gd(gnd),
      .lclk(func_lclk),
      .d2clk(func_d2clk),
      .scan_in(func_siv[ FUNC_F2ERR_OFFSET:FUNC_F2ERR_OFFSET + FIR2_WIDTH - 1]),
      .scan_out(func_sov[FUNC_F2ERR_OFFSET:FUNC_F2ERR_OFFSET + FIR2_WIDTH - 1]),
      .din(fir2_errors),
      .q(fir2_errors_q)
   );

   //=====================================================================
   // LCBs
   //=====================================================================
   // functional ring regs; NOT power managed
   tri_lcbor  func_lcbor(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(lcb_func_slp_sl_thold_0),
      .sg(lcb_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(func_force),
      .thold_b(func_thold_b)
   );

   tri_lcbnd  func_lcb(
      .act(tiup),		// not power saved
      .vd(vdd),
      .gd(gnd),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .nclk(nclk),
      .force_t(func_force),
      .sg(lcb_sg_0),
      .thold_b(func_thold_b),
      .d1clk(func_d1clk),
      .d2clk(func_d2clk),
      .lclk(func_lclk)
   );

   //=====================================================================
   // Scan Connections
   //=====================================================================
   assign bcfg_siv[0:BCFG_RIGHT] = {bcfg_scan_in, bcfg_sov[0:BCFG_RIGHT - 1]};
   assign bcfg_scan_out = bcfg_sov[BCFG_RIGHT];

   assign func_siv[0:FUNC_RIGHT] = {func_scan_in, func_sov[0:FUNC_RIGHT - 1]};
   assign func_scan_out = func_sov[FUNC_RIGHT];


endmodule
