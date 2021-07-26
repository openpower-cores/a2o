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

//  Description:  XU SPR - per core registers & array
//
//*****************************************************************************
`include "tri_a2o.vh"
module xu_spr_cspr
#(
   parameter                             hvmode = 1,
   parameter                             a2mode = 1,
   parameter                             spr_xucr0_init = 1120
)(
   input [0:`NCLK_WIDTH-1] nclk,

   // CHIP IO
   input [0:`THREADS-1]                   an_ac_reservation_vld,
   input                                  an_ac_tb_update_enable,
   input                                  an_ac_tb_update_pulse,
   input [0:`THREADS-1]                   an_ac_sleep_en,
   input [54:61]                          an_ac_coreid,
   input [32:35]                          an_ac_chipid_dc,
   input [8:15]                           spr_pvr_version_dc,
   input [12:15]                          spr_pvr_revision_dc,
   input [16:19]                          spr_pvr_revision_minor_dc,
   input                                  pc_xu_instr_trace_mode,
   input [0:1]                            pc_xu_instr_trace_tid,
   output [0:`THREADS-1]                  instr_trace_mode,

   input                                  d_mode_dc,
   input [0:0]                            delay_lclkr_dc,
   input [0:0]                            mpw1_dc_b,
   input                                  mpw2_dc_b,

   input                                  bcfg_sl_force,
   input                                  bcfg_sl_thold_0_b,
   input                                  bcfg_slp_sl_force,
   input                                  bcfg_slp_sl_thold_0_b,
   input                                  ccfg_sl_force,
   input                                  ccfg_sl_thold_0_b,
   input                                  ccfg_slp_sl_force,
   input                                  ccfg_slp_sl_thold_0_b,
   input                                  dcfg_sl_force,
   input                                  dcfg_sl_thold_0_b,
   input                                  func_sl_force,
   input                                  func_sl_thold_0_b,
   input                                  func_slp_sl_force,
   input                                  func_slp_sl_thold_0_b,
   input                                  func_nsl_force,
   input                                  func_nsl_thold_0_b,
   input                                  sg_0,
   input [0:1]                            scan_in,
   output [0:1]                           scan_out,
   input                                  bcfg_scan_in,
   output                                 bcfg_scan_out,
   input                                  ccfg_scan_in,
   output                                 ccfg_scan_out,
   input                                  dcfg_scan_in,
   output                                 dcfg_scan_out,

   output                                 cspr_tspr_rf1_act,

   // Decode
   input [0:`THREADS-1]                   rv_xu_vld,
   input                                  rv_xu_ex0_ord,
   input [0:31]                           rv_xu_ex0_instr,
   input [62-`EFF_IFAR_WIDTH:61]          rv_xu_ex0_ifar,
   output [62-`EFF_IFAR_WIDTH:61]         ex2_ifar,

   output                                 spr_xu_ord_read_done,
   output                                 spr_xu_ord_write_done,
   input                                  xu_spr_ord_ready,
   input [0:`THREADS-1]                   flush,

   // Read Data
   input [0:`GPR_WIDTH*`THREADS-1]        tspr_cspr_ex3_tspr_rt,
   output [64-`GPR_WIDTH:63]              spr_xu_ex4_rd_data,

   // Write Data
   input [64-`GPR_WIDTH:63]               xu_spr_ex2_rs1,
   output [0:`THREADS-1]                  cspr_tspr_ex3_spr_we,
   output [64-`GPR_WIDTH:64+8-(64/`GPR_WIDTH)] ex3_spr_wd_out,

   // SPRT Interface
   output [0:`THREADS-1]                  cspr_tspr_ex2_tid,
   output [0:31]                          cspr_tspr_ex1_instr,
   output [0:`THREADS-1]                  cspr_tspr_dec_dbg_dis,

   // Illegal SPR
   input [0:`THREADS-1]                   tspr_cspr_illeg_mtspr_b,
   input [0:`THREADS-1]                   tspr_cspr_illeg_mfspr_b,
   input [0:`THREADS-1]                   tspr_cspr_hypv_mtspr,
   input [0:`THREADS-1]                   tspr_cspr_hypv_mfspr,

   // Array SPRs
   output                                 cspr_aspr_ex3_we,
   output [0:5]                           cspr_aspr_ex3_waddr,
   output                                 cspr_aspr_ex1_re,
   output [0:5]                           cspr_aspr_ex1_raddr,
   input [64-`GPR_WIDTH:72-(64/`GPR_WIDTH)] aspr_cspr_ex2_rdata,

   // Slow SPR Bus
   output                                 xu_slowspr_val_out,
   output                                 xu_slowspr_rw_out,
   output [0:1]                           xu_slowspr_etid_out,
   output [11:20]                         xu_slowspr_addr_out,
   output [64-`GPR_WIDTH:63]              xu_slowspr_data_out,

   // DCR Bus
   output                                 ac_an_dcr_act,
   output                                 ac_an_dcr_val,
   output                                 ac_an_dcr_read,
   output                                 ac_an_dcr_user,
   output [0:1]                           ac_an_dcr_etid,
   output [11:20]                         ac_an_dcr_addr,
   output [64-`GPR_WIDTH:63]              ac_an_dcr_data,

   // Trap
   output                                 spr_dec_ex4_spr_hypv,
   output                                 spr_dec_ex4_spr_illeg,
   output                                 spr_dec_ex4_spr_priv,
   output                                 spr_dec_ex4_np1_flush,

   output [0:9]                           cspr_tspr_timebase_taps,
   output                                 timer_update,

   // Run State
   input                                  pc_xu_pm_hold_thread,
   input [0:`THREADS-1]                   iu_xu_stop,
   output [0:`THREADS-1]                  xu_iu_run_thread,
   output [0:`THREADS-1]                  xu_pc_spr_ccr0_we,
   output [0:1]                           xu_pc_spr_ccr0_pme,

   // Quiesce
   input [0:`THREADS-1]                   iu_xu_quiesce,
   input [0:`THREADS-1]                   iu_xu_icache_quiesce,
   input [0:`THREADS-1]                   lq_xu_quiesce,
   input [0:`THREADS-1]                   mm_xu_quiesce,
   input [0:`THREADS-1]                   bx_xu_quiesce,
   output [0:`THREADS-1]                  xu_pc_running,

   // PCCR0
   input                                  pc_xu_extirpts_dis_on_stop,
   input                                  pc_xu_timebase_dis_on_stop,
   input                                  pc_xu_decrem_dis_on_stop,

   // PERF
   input [0:2]                            pc_xu_event_count_mode,
   input                                  pc_xu_event_bus_enable,
   input  [0:4*`THREADS-1]                xu_event_bus_in,
   output [0:4*`THREADS-1]                xu_event_bus_out,
   input [0:`THREADS-1]                   div_spr_running,
   input [0:`THREADS-1]                   mul_spr_running,


   // MSR Override
   input [0:`THREADS-1]                   pc_xu_ram_active,
   input                                  pc_xu_msrovride_enab,
   output [0:`THREADS-1]                  cspr_tspr_msrovride_en,
   output [0:`THREADS-1]                  cspr_tspr_ram_active,

   // LiveLock
   output [0:`THREADS-1]                  cspr_tspr_llen,
   output [0:`THREADS-1]                  cspr_tspr_llpri,
   input [0:`THREADS-1]                   tspr_cspr_lldet,
   input [0:`THREADS-1]                   tspr_cspr_llpulse,

   // Reset
   input                                  pc_xu_reset_wd_complete,
   input                                  pc_xu_reset_3_complete,
   input                                  pc_xu_reset_2_complete,
   input                                  pc_xu_reset_1_complete,
   output                                 reset_wd_complete,
   output                                 reset_3_complete,
   output                                 reset_2_complete,
   output                                 reset_1_complete,

   // Async Interrupt Masking
   output [0:`THREADS-1]                  cspr_tspr_crit_mask,
   output [0:`THREADS-1]                  cspr_tspr_ext_mask,
   output [0:`THREADS-1]                  cspr_tspr_dec_mask,
   output [0:`THREADS-1]                  cspr_tspr_fit_mask,
   output [0:`THREADS-1]                  cspr_tspr_wdog_mask,
   output [0:`THREADS-1]                  cspr_tspr_udec_mask,
   output [0:`THREADS-1]                  cspr_tspr_perf_mask,
   output                                 cspr_tspr_sleep_mask,

   input [0:`THREADS-1]                   tspr_cspr_pm_wake_up,

   // More Async Interrupts
   output [0:`THREADS-1]                  xu_iu_dbell_interrupt,
   output [0:`THREADS-1]                  xu_iu_cdbell_interrupt,
   output [0:`THREADS-1]                  xu_iu_gdbell_interrupt,
   output [0:`THREADS-1]                  xu_iu_gcdbell_interrupt,
   output [0:`THREADS-1]                  xu_iu_gmcdbell_interrupt,
   input [0:`THREADS-1]                   iu_xu_dbell_taken,
   input [0:`THREADS-1]                   iu_xu_cdbell_taken,
   input [0:`THREADS-1]                   iu_xu_gdbell_taken,
   input [0:`THREADS-1]                   iu_xu_gcdbell_taken,
   input [0:`THREADS-1]                   iu_xu_gmcdbell_taken,

   // DBELL Int
   input                                  lq_xu_dbell_val,
   input [0:4]                            lq_xu_dbell_type,
   input                                  lq_xu_dbell_brdcast,
   input                                  lq_xu_dbell_lpid_match,
   input [50:63]                          lq_xu_dbell_pirtag,
   output [50:63]                         cspr_tspr_dbell_pirtag,
   input [0:`THREADS-1]                   tspr_cspr_gpir_match,

   // Parity
   output [0:`THREADS-1]                  xu_pc_err_sprg_ecc,
   output [0:`THREADS-1]                  xu_pc_err_sprg_ue,
   input [0:`THREADS-1]                   pc_xu_inj_sprg_ecc,

   // Debug
   input [0:`THREADS-1]                   tspr_cspr_freeze_timers,
   input [0:3*`THREADS-1]                 tspr_cspr_async_int,

   input [0:`THREADS-1]                   tspr_cspr_ex2_np1_flush,

   output [0:`THREADS-1]                  xu_iu_msrovride_enab,
   input                                  lq_xu_spr_xucr0_cslc_xuop,
   input                                  lq_xu_spr_xucr0_cslc_binv,
   input                                  lq_xu_spr_xucr0_clo,
   input                                  lq_xu_spr_xucr0_cul,
   output                                 cspr_ccr2_en_pc,
   output                                 cspr_ccr4_en_dnh,
   input [0:`THREADS-1]                   tspr_msr_ee,
   input [0:`THREADS-1]                   tspr_msr_ce,
   input [0:`THREADS-1]                   tspr_msr_me,
   input [0:`THREADS-1]                   tspr_msr_gs,
   input [0:`THREADS-1]                   tspr_msr_pr,
   output [0:4]                           cspr_xucr0_clkg_ctl,
   output                                 xu_lsu_spr_xucr0_clfc,
   output [0:31]                          spr_xesr1,
   output [0:31]                          spr_xesr2,
   output [0:`THREADS-1]                  perf_event_en,
	output                              spr_ccr2_en_dcr,
	output                              spr_ccr2_en_trace,
	output [0:8]                        spr_ccr2_ifratsc,
	output                              spr_ccr2_ifrat,
	output [0:8]                        spr_ccr2_dfratsc,
	output                              spr_ccr2_dfrat,
	output                              spr_ccr2_ucode_dis,
	output [0:3]                        spr_ccr2_ap,
	output                              spr_ccr2_en_attn,
	output                              spr_ccr2_en_ditc,
	output                              spr_ccr2_en_icswx,
	output                              spr_ccr2_notlb,
	output [0:3]                        spr_xucr0_trace_um,
	output                              xu_lsu_spr_xucr0_mbar_ack,
	output                              xu_lsu_spr_xucr0_tlbsync,
	output                              spr_xucr0_cls,
	output                              xu_lsu_spr_xucr0_aflsta,
	output                              spr_xucr0_mddp,
	output                              xu_lsu_spr_xucr0_cred,
	output                              xu_lsu_spr_xucr0_rel,
	output                              spr_xucr0_mdcp,
	output                              xu_lsu_spr_xucr0_flsta,
	output                              xu_lsu_spr_xucr0_l2siw,
	output                              xu_lsu_spr_xucr0_flh2l2,
	output                              xu_lsu_spr_xucr0_dcdis,
	output                              xu_lsu_spr_xucr0_wlk,
	output                              spr_xucr4_mmu_mchk,
	output                              spr_xucr4_mddmh,

   output [0:39]                          cspr_debug0,
   output [0:63]                          cspr_debug1,

   // Power
   inout                                  vdd,
   inout                                  gnd
);

   localparam                             DEX0 = 0;
   localparam                             DEX1 = 0;
   localparam                             DEX2 = 0;
   localparam                             DEX3 = 0;
   localparam                             DEX4 = 0;
   localparam                             DEX5 = 0;
   localparam                             DEX6 = 0;
   localparam                             DWR = 0;
   localparam                             DX = 0;
   localparam                             a2hvmode = ((a2mode + hvmode) % 1);
   // Types
   // SPR Registers
	// SPR Registers
	wire [62:63]                  ccr0_d,                   ccr0_q;
	wire [40:63]                  ccr1_d,                   ccr1_q;
	wire [32:63]                  ccr2_d,                   ccr2_q;
	wire [63:63]                  ccr4_d,                   ccr4_q;
	wire [32:63]                  tbl_d,                    tbl_q;
	wire [32:63]                  tbu_d,                    tbu_q;
	wire [64-(`THREADS):63]       tens_d,                   tens_q;
	wire [32:63]                  xesr1_d,                  xesr1_q;
	wire [32:63]                  xesr2_d,                  xesr2_q;
	wire [38:63]                  xucr0_d,                  xucr0_q;
	wire [60:63]                  xucr4_d,                  xucr4_q;
   // FUNC Scanchain
	localparam ccr1_offset                    = 0;
	localparam tbl_offset                     = ccr1_offset                    + 24;
	localparam tbu_offset                     = tbl_offset                     + 32;
	localparam xesr1_offset                   = tbu_offset                     + 32;
	localparam xesr2_offset                   = xesr1_offset                   + 32;
	localparam last_reg_offset                = xesr2_offset                   + 32;
   // BCFG Scanchain
	localparam ccr0_offset_bcfg               = 0;
	localparam tens_offset_bcfg               = ccr0_offset_bcfg               + 2;
	localparam last_reg_offset_bcfg           = tens_offset_bcfg               + `THREADS;
   // CCFG Scanchain
	localparam ccr2_offset_ccfg               = 0;
	localparam ccr4_offset_ccfg               = ccr2_offset_ccfg               + 32;
	localparam xucr0_offset_ccfg              = ccr4_offset_ccfg               + 1;
	localparam last_reg_offset_ccfg           = xucr0_offset_ccfg              + 26;
   // DCFG Scanchain
	localparam xucr4_offset_dcfg              = 0;
	localparam last_reg_offset_dcfg           = xucr4_offset_dcfg              + 4;
   // Latches
   wire  [1:4]                exx_act_q,                  exx_act_d                  ;  // input=>exx_act_d                 , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       ex0_val_q,                  rv2_val                    ;  // input=>rv2_val                   , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       ex1_val_q,                  ex0_val                    ;  // input=>ex0_val                   , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex1_aspr_act_q,             ex1_aspr_act_d             ;  // input=>ex1_aspr_act_d            , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:1]                ex1_aspr_tid_q,             ex1_aspr_tid_d             ;  // input=>ex1_aspr_tid_d            , act=>exx_act[0]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:1]                ex1_tid_q,                  ex0_tid                    ;  // input=>ex0_tid                   , act=>exx_act[0]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:31]               ex1_instr_q                                            ;  // input=>rv_xu_ex0_instr           , act=>exx_act[0]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:0]                ex1_msr_gs_q,               ex1_msr_gs_d               ;  // input=>ex1_msr_gs_d              , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       ex2_val_q,                  ex1_val                    ;  // input=>ex1_val                   , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex2_val_rd_q,               ex2_val_rd_d               ;  // input=>ex2_val_rd_d              , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex2_val_wr_q,               ex2_val_wr_d               ;  // input=>ex2_val_wr_d              , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:1]                ex2_tid_q                                              ;  // input=>ex1_tid_q                 , act=>exx_act[1]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:3]                ex2_aspr_addr_q,            ex1_aspr_addr              ;  // input=>ex1_aspr_addr             , act=>exx_act[1]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex2_is_mfspr_q,             ex1_is_mfspr               ;  // input=>ex1_is_mfspr              , act=>exx_act[1]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex2_is_mftb_q,              ex1_is_mftb                ;  // input=>ex1_is_mftb               , act=>exx_act[1]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex2_is_mtmsr_q,             ex2_is_mtmsr_d             ;  // input=>ex1_is_mtmsr              , act=>exx_act[1]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex2_is_mtspr_q,             ex1_is_mtspr               ;  // input=>ex1_is_mtspr              , act=>exx_act[1]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex2_is_wait_q,              ex1_is_wait                ;  // input=>ex1_is_wait               , act=>exx_act[1]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex2_priv_instr_q,           ex1_priv_instr             ;  // input=>ex1_priv_instr            , act=>exx_act[1]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex2_hypv_instr_q,           ex1_hypv_instr             ;  // input=>ex1_hypv_instr            , act=>exx_act[1]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire  [9:10]               ex2_wait_wc_q                                          ;  // input=>ex1_instr_q[9:10]         , act=>exx_act[1]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex2_is_msgclr_q,            ex1_is_msgclr              ;  // input=>ex1_is_msgclr             , act=>exx_act[1]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire  [11:20]              ex2_instr_q,                ex2_instr_d                ;  // input=>ex2_instr_d               , act=>exx_act[1]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:0]                ex2_msr_gs_q                                           ;  // input=>ex1_msr_gs_q              , act=>1'b1              , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex2_tenc_we_q,              ex1_tenc_we                ;  // input=>ex1_tenc_we               , act=>exx_act[1]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex2_ccr0_we_q,              ex1_ccr0_we                ;  // input=>ex1_ccr0_we               , act=>exx_act[1]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire  [2-`GPR_WIDTH/32:1]  ex2_aspr_re_q,              ex1_aspr_re                ;  // input=>ex1_aspr_re               , act=>exx_act[1]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex2_dnh_q,                  ex1_dnh                    ;  // input=>ex1_dnh                   , act=>exx_act[1]
   wire  [0:`THREADS-1]       ex3_val_q,                  ex2_val                    ;  // input=>ex2_val                   , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex3_val_rd_q,               ex3_val_rd_d               ;  // input=>ex3_val_rd_d              , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex3_sspr_wr_val_q,          ex2_sspr_wr_val            ;  // input=>ex2_sspr_wr_val           , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex3_sspr_rd_val_q,          ex2_sspr_rd_val            ;  // input=>ex2_sspr_rd_val           , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex3_spr_we_q,               ex3_spr_we_d               ;  // input=>ex3_spr_we_d              , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex3_aspr_we_q,              ex3_aspr_we_d              ;  // input=>ex3_aspr_we_d             , act=>exx_act[2]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:3]                ex3_aspr_addr_q,            ex3_aspr_addr_d            ;  // input=>ex3_aspr_addr_d           , act=>ex2_aspr_addr_act  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:1]                ex3_tid_q                                              ;  // input=>ex2_tid_q                 , act=>exx_act[2]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [64-`GPR_WIDTH:72-(64/`GPR_WIDTH)] ex3_aspr_rdata_q, ex3_aspr_rdata_d       ;  // input=>ex3_aspr_rdata_d          , act=>exx_act_data[2], scan=>Y, sleep=>N, ring=>func, needs_sreset=>1, size=>`GPR_WIDTH+8
   wire                       ex3_is_mtspr_q                                         ;  // input=>ex2_is_mtspr_q            , act=>exx_act[2]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [9:10]               ex3_wait_wc_q                                          ;  // input=>ex2_wait_wc_q             , act=>exx_act[2]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex3_is_msgclr_q                                        ;  // input=>ex2_is_msgclr_q           , act=>exx_act[2]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [11:20]              ex3_instr_q,                ex3_instr_d                ;  // input=>ex3_instr_d               , act=>exx_act[2]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [64-`GPR_WIDTH:63]   ex3_cspr_rt_q,              ex2_cspr_rt                ;  // input=>ex2_cspr_rt               , act=>exx_act_data[2], scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex3_hypv_spr_q,             ex3_hypv_spr_d             ;  // input=>ex3_hypv_spr_d            , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex3_illeg_spr_q,            ex3_illeg_spr_d            ;  // input=>ex3_illeg_spr_d           , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex3_priv_spr_q,             ex3_priv_spr_d             ;  // input=>ex3_priv_spr_d            , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [64-`GPR_WIDTH:64+8-(64/`GPR_WIDTH)]   ex3_rt_q,       ex3_rt_d             ;  // input=>ex3_rt_d                  , act=>ex3_rt_act     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1, size=>`GPR_WIDTH+8
   wire                       ex3_wait_q                                             ;  // input=>ex2_is_wait_q             , act=>exx_act[2]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:3]                ex3_aspr_ce_addr_q                                     ;  // input=>ex2_aspr_addr_q           , act=>exx_act[2]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [2-`GPR_WIDTH/32:1]  ex3_aspr_re_q                                          ;  // input=>ex2_aspr_re_q             , act=>exx_act[2]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       ex4_val_q                                              ;  // input=>ex3_val                   , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [2-`GPR_WIDTH/32:1]  ex4_aspr_re_q                                          ;  // input=>ex3_aspr_re_q             , act=>exx_act[3]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [64-`GPR_WIDTH:63]   ex4_spr_rt_q,               ex3_spr_rt                 ;  // input=>ex3_spr_rt                , act=>exx_act_data[3], scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [64-`GPR_WIDTH:63]   ex4_corr_rdata_q,           ex3_corr_rdata             ;  // input=>ex3_corr_rdata            , act=>exx_act_data[3], scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`GPR_WIDTH/8]     ex4_sprg_ce_q,              ex4_sprg_ce_d              ;  // input=>ex4_sprg_ce_d             , act=>1'b1              , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:3]                ex4_aspr_ce_addr_q                                     ;  // input=>ex3_aspr_ce_addr_q        , act=>ex3_sprg_ce    , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex4_hypv_spr_q                                         ;  // input=>ex3_hypv_spr_q            , act=>exx_act[3]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex4_illeg_spr_q                                        ;  // input=>ex3_illeg_spr_q           , act=>exx_act[3]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex4_priv_spr_q                                         ;  // input=>ex3_priv_spr_q            , act=>exx_act[3]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex4_np1_flush_q,            ex4_np1_flush_d            ;  // input=>ex4_np1_flush_d           , act=>exx_act[3]     , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       ex5_sprg_ce_q,              ex4_sprg_ce                ;  // input=>ex4_sprg_ce               , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex4_sprg_ue_q,              ex4_sprg_ue_d              ;  // input=>ex4_sprg_ue_d             , act=>1'b1              , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       ex5_sprg_ue_q,              ex4_sprg_ue                ;  // input=>ex4_sprg_ue               , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       cpl_dbell_taken_q                                      ;  // input=>iu_xu_dbell_taken         , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       cpl_cdbell_taken_q                                     ;  // input=>iu_xu_cdbell_taken        , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       cpl_gdbell_taken_q                                     ;  // input=>iu_xu_gdbell_taken        , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       cpl_gcdbell_taken_q                                    ;  // input=>iu_xu_gcdbell_taken       , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       cpl_gmcdbell_taken_q                                   ;  // input=>iu_xu_gmcdbell_taken      , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       set_xucr0_cslc_q,           set_xucr0_cslc_d           ;  // input=>set_xucr0_cslc_d          , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       set_xucr0_cul_q,            set_xucr0_cul_d            ;  // input=>set_xucr0_cul_d           , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       set_xucr0_clo_q,            set_xucr0_clo_d            ;  // input=>set_xucr0_clo_d           , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       ex3_np1_flush_q,            ex3_np1_flush_d            ;  // input=>ex3_np1_flush_d           , act=>exx_act[2]     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       running_q,                  running_d                  ;  // input=>running_d                 , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       llpri_q,                    llpri_d                    ;  // input=>llpri_d                   , act=>llpri_inc      , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1, init=>2**(``THREADS-1)
   wire  [0:`THREADS-1]       dec_dbg_dis_q,              dec_dbg_dis_d              ;  // input=>dec_dbg_dis_d             , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       tb_dbg_dis_q,               tb_dbg_dis_d               ;  // input=>tb_dbg_dis_d              , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       tb_act_q,                   tb_act_d                   ;  // input=>tb_act_d                  , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       ext_dbg_dis_q,              ext_dbg_dis_d              ;  // input=>ext_dbg_dis_d             , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       msrovride_enab_q                                       ;  // input=>pc_xu_msrovride_enab      , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       waitimpl_val_q,             waitimpl_val_d             ;  // input=>waitimpl_val_d            , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       waitrsv_val_q,              waitrsv_val_d              ;  // input=>waitrsv_val_d             , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       an_ac_reservation_vld_q                                ;  // input=>an_ac_reservation_vld     , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       an_ac_sleep_en_q                                       ;  // input=>an_ac_sleep_en            , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [54:61]              an_ac_coreid_q                                         ;  // input=>an_ac_coreid              , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       tb_update_enable_q                                     ;  // input=>an_ac_tb_update_enable    , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       tb_update_pulse_q                                      ;  // input=>an_ac_tb_update_pulse     , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       tb_update_pulse_1_q                                    ;  // input=>tb_update_pulse_q         , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       pc_xu_reset_wd_complete_q                              ;  // input=>pc_xu_reset_wd_complete   , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       pc_xu_reset_3_complete_q                               ;  // input=>pc_xu_reset_3_complete    , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       pc_xu_reset_2_complete_q                               ;  // input=>pc_xu_reset_2_complete    , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       pc_xu_reset_1_complete_q                               ;  // input=>pc_xu_reset_1_complete    , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       lq_xu_dbell_val_q                                      ;  // input=>lq_xu_dbell_val           , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:4]                lq_xu_dbell_type_q                                     ;  // input=>lq_xu_dbell_type          , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       lq_xu_dbell_brdcast_q                                  ;  // input=>lq_xu_dbell_brdcast       , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       lq_xu_dbell_lpid_match_q                               ;  // input=>lq_xu_dbell_lpid_match    , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [50:63]              lq_xu_dbell_pirtag_q                                   ;  // input=>lq_xu_dbell_pirtag        , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       dbell_present_q,            dbell_present_d            ;  // input=>dbell_present_d           , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       cdbell_present_q,           cdbell_present_d           ;  // input=>cdbell_present_d          , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       gdbell_present_q,           gdbell_present_d           ;  // input=>gdbell_present_d          , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       gcdbell_present_q,          gcdbell_present_d          ;  // input=>gcdbell_present_d         , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       gmcdbell_present_q,         gmcdbell_present_d         ;  // input=>gmcdbell_present_d        , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       xucr0_clfc_q,               xucr0_clfc_d               ;  // input=>xucr0_clfc_d              , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       iu_run_thread_q,            iu_run_thread_d            ;  // input=>iu_run_thread_d           , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       inj_sprg_ecc_q                                         ;  // input=>pc_xu_inj_sprg_ecc        , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       dbell_interrupt_q,          dbell_interrupt            ;  // input=>dbell_interrupt           , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       cdbell_interrupt_q,         cdbell_interrupt           ;  // input=>cdbell_interrupt          , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       gdbell_interrupt_q,         gdbell_interrupt           ;  // input=>gdbell_interrupt          , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       gcdbell_interrupt_q,        gcdbell_interrupt          ;  // input=>gcdbell_interrupt         , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       gmcdbell_interrupt_q,       gmcdbell_interrupt         ;  // input=>gmcdbell_interrupt        , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       iu_quiesce_q                                           ;  // input=>iu_xu_quiesce             , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       iu_icache_quiesce_q                                    ;  // input=>iu_xu_icache_quiesce      , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       lsu_quiesce_q                                          ;  // input=>lq_xu_quiesce             , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       mm_quiesce_q                                           ;  // input=>mm_xu_quiesce             , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       bx_quiesce_q                                           ;  // input=>bx_xu_quiesce             , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       quiesce_q,                  quiesce_d                  ;  // input=>quiesce_d                 , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       quiesced_q,                 quiesced_d                 ;  // input=>quiesced_d                , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       instr_trace_mode_q                                     ;  // input=>pc_xu_instr_trace_mode    , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:1]                instr_trace_tid_q                                      ;  // input=>pc_xu_instr_trace_tid     , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       timer_update_q                                         ;  // input=>timer_update_int          , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       spr_xu_ord_read_done_q,    spr_xu_ord_read_done_d      ;  // input=>spr_xu_ord_read_done_d    , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       spr_xu_ord_write_done_q,   spr_xu_ord_write_done_d     ;  // input=>spr_xu_ord_write_done_d   , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       xu_spr_ord_ready_q                                     ;  // input=>xu_spr_ord_ready          , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex4_sspr_val_q                                         ;  // input=>ex3_sspr_val              , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       flush_q                                                ;  // input=>flush                     , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire  [62-`EFF_IFAR_WIDTH:61]  ex1_ifar_q                                         ;  // input=>rv_xu_ex0_ifar            , act=>exx_act[0]     , scan=>Y, sleep=>N, needs_sreset=>1
   wire  [62-`EFF_IFAR_WIDTH:61]  ex2_ifar_q                                         ;  // input=>ex1_ifar_q                , act=>exx_act[1]     , scan=>Y, sleep=>N, needs_sreset=>1
   wire  [0:`THREADS-1]       ram_active_q                                           ;  // input=>pc_xu_ram_active          , act=>1'b1
   wire  [0:4]                timer_div_q,                timer_div_d                ;  // input=>timer_div_d               , act=>timer_div_act  , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:`THREADS-1]       msrovride_enab_2_q,         msrovride_enab             ;  // input=>msrovride_enab            , act=>1'b1
   wire  [0:`THREADS-1]       msrovride_enab_3_q                                     ;  // input=>msrovride_enab_2_q        , act=>1'b1
   wire                       ex3_wait_flush_q,           ex3_wait_flush_d           ;  // input=>ex3_wait_flush_d          , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       ex4_wait_flush_q,           ex4_wait_flush_d           ;  // input=>ex4_wait_flush_d          , act=>1'b1              , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                       pc_xu_pm_hold_thread_q                                 ;  // input=>pc_xu_pm_hold_thread      , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                       power_savings_on_q,         power_savings_on_d         ;  // input=>power_savings_on_d        , act=>1'b1              , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire [0:4*`THREADS-1]      perf_event_bus_q,           perf_event_bus_d           ;  // input=>perf_event_bus_d          , act=>pc_xu_event_bus_enable   , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire [0:`THREADS-1]        perf_event_en_q,            perf_event_en_d            ;  // input=>perf_event_en_d           , act=>pc_xu_event_bus_enable   , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire  [0:15]               spare_0_q,                  spare_0_d                  ;  // input=>spare_0_d                 , act=>1'b1   ,
   // Scanchains
   localparam exx_act_offset                             = last_reg_offset;
   localparam ex0_val_offset                             = exx_act_offset                 + 4;
   localparam ex1_val_offset                             = ex0_val_offset                 + `THREADS;
   localparam ex1_aspr_act_offset                        = ex1_val_offset                 + `THREADS;
   localparam ex1_aspr_tid_offset                        = ex1_aspr_act_offset            + 1;
   localparam ex1_tid_offset                             = ex1_aspr_tid_offset            + 2;
   localparam ex1_instr_offset                           = ex1_tid_offset                 + 2;
   localparam ex1_msr_gs_offset                          = ex1_instr_offset               + 32;
   localparam ex2_val_offset                             = ex1_msr_gs_offset              + 1;
   localparam ex2_val_rd_offset                          = ex2_val_offset                 + `THREADS;
   localparam ex2_val_wr_offset                          = ex2_val_rd_offset              + 1;
   localparam ex2_tid_offset                             = ex2_val_wr_offset              + 1;
   localparam ex2_aspr_addr_offset                       = ex2_tid_offset                 + 2;
   localparam ex2_is_mfspr_offset                        = ex2_aspr_addr_offset           + 4;
   localparam ex2_is_mftb_offset                         = ex2_is_mfspr_offset            + 1;
   localparam ex2_is_mtmsr_offset                        = ex2_is_mftb_offset             + 1;
   localparam ex2_is_mtspr_offset                        = ex2_is_mtmsr_offset            + 1;
   localparam ex2_is_wait_offset                         = ex2_is_mtspr_offset            + 1;
   localparam ex2_priv_instr_offset                      = ex2_is_wait_offset             + 1;
   localparam ex2_hypv_instr_offset                      = ex2_priv_instr_offset          + 1;
   localparam ex2_wait_wc_offset                         = ex2_hypv_instr_offset          + 1;
   localparam ex2_is_msgclr_offset                       = ex2_wait_wc_offset             + 2;
   localparam ex2_instr_offset                           = ex2_is_msgclr_offset           + 1;
   localparam ex2_msr_gs_offset                          = ex2_instr_offset               + 10;
   localparam ex2_tenc_we_offset                         = ex2_msr_gs_offset              + 1;
   localparam ex2_ccr0_we_offset                         = ex2_tenc_we_offset             + 1;
   localparam ex2_aspr_re_offset                         = ex2_ccr0_we_offset             + 1;
	localparam ex2_dnh_offset                             = ex2_aspr_re_offset             + `GPR_WIDTH/32;
   localparam ex3_val_offset                             = ex2_dnh_offset                 + 1;
   localparam ex3_val_rd_offset                          = ex3_val_offset                 + `THREADS;
   localparam ex3_sspr_wr_val_offset                     = ex3_val_rd_offset              + 1;
   localparam ex3_sspr_rd_val_offset                     = ex3_sspr_wr_val_offset         + 1;
   localparam ex3_spr_we_offset                          = ex3_sspr_rd_val_offset         + 1;
   localparam ex3_aspr_we_offset                         = ex3_spr_we_offset              + 1;
   localparam ex3_aspr_addr_offset                       = ex3_aspr_we_offset             + 1;
   localparam ex3_tid_offset                             = ex3_aspr_addr_offset           + 4;
   localparam ex3_aspr_rdata_offset                      = ex3_tid_offset                 + 2;
   localparam ex3_is_mtspr_offset                        = ex3_aspr_rdata_offset          + `GPR_WIDTH+8;
   localparam ex3_wait_wc_offset                         = ex3_is_mtspr_offset            + 1;
   localparam ex3_is_msgclr_offset                       = ex3_wait_wc_offset             + 2;
   localparam ex3_instr_offset                           = ex3_is_msgclr_offset           + 1;
   localparam ex3_cspr_rt_offset                         = ex3_instr_offset               + 10;
   localparam ex3_hypv_spr_offset                        = ex3_cspr_rt_offset             + `GPR_WIDTH;
   localparam ex3_illeg_spr_offset                       = ex3_hypv_spr_offset            + 1;
   localparam ex3_priv_spr_offset                        = ex3_illeg_spr_offset           + 1;
   localparam ex3_rt_offset                              = ex3_priv_spr_offset            + 1;
   localparam ex3_wait_offset                            = ex3_rt_offset                  + `GPR_WIDTH+8;
   localparam ex3_aspr_ce_addr_offset                    = ex3_wait_offset                + 1;
   localparam ex3_aspr_re_offset                         = ex3_aspr_ce_addr_offset        + 4;
   localparam ex4_val_offset                             = ex3_aspr_re_offset             + `GPR_WIDTH/32;
   localparam ex4_aspr_re_offset                         = ex4_val_offset                 + `THREADS;
   localparam ex4_spr_rt_offset                          = ex4_aspr_re_offset             + `GPR_WIDTH/32;
   localparam ex4_corr_rdata_offset                      = ex4_spr_rt_offset              + `GPR_WIDTH;
   localparam ex4_sprg_ce_offset                         = ex4_corr_rdata_offset          + `GPR_WIDTH;
   localparam ex4_aspr_ce_addr_offset                    = ex4_sprg_ce_offset             + `GPR_WIDTH/8+1;
   localparam ex4_hypv_spr_offset                        = ex4_aspr_ce_addr_offset        + 4;
   localparam ex4_illeg_spr_offset                       = ex4_hypv_spr_offset            + 1;
   localparam ex4_priv_spr_offset                        = ex4_illeg_spr_offset           + 1;
   localparam ex4_np1_flush_offset                       = ex4_priv_spr_offset            + 1;
   localparam ex5_sprg_ce_offset                         = ex4_np1_flush_offset           + 1;
	localparam ex4_sprg_ue_offset                         = ex5_sprg_ce_offset             + `THREADS;
	localparam ex5_sprg_ue_offset                         = ex4_sprg_ue_offset             + 1;
   localparam cpl_dbell_taken_offset                     = ex5_sprg_ue_offset             + `THREADS;
   localparam cpl_cdbell_taken_offset                    = cpl_dbell_taken_offset         + `THREADS;
   localparam cpl_gdbell_taken_offset                    = cpl_cdbell_taken_offset        + `THREADS;
   localparam cpl_gcdbell_taken_offset                   = cpl_gdbell_taken_offset        + `THREADS;
   localparam cpl_gmcdbell_taken_offset                  = cpl_gcdbell_taken_offset       + `THREADS;
   localparam set_xucr0_cslc_offset                      = cpl_gmcdbell_taken_offset      + `THREADS;
   localparam set_xucr0_cul_offset                       = set_xucr0_cslc_offset          + 1;
   localparam set_xucr0_clo_offset                       = set_xucr0_cul_offset           + 1;
   localparam ex3_np1_flush_offset                       = set_xucr0_clo_offset           + 1;
   localparam running_offset                             = ex3_np1_flush_offset           + 1;
   localparam llpri_offset                               = running_offset                 + `THREADS;
   localparam dec_dbg_dis_offset                         = llpri_offset                   + `THREADS;
   localparam tb_dbg_dis_offset                          = dec_dbg_dis_offset             + `THREADS;
   localparam tb_act_offset                              = tb_dbg_dis_offset              + 1;
   localparam ext_dbg_dis_offset                         = tb_act_offset                  + 1;
   localparam msrovride_enab_offset                      = ext_dbg_dis_offset             + `THREADS;
   localparam waitimpl_val_offset                        = msrovride_enab_offset          + 1;
   localparam waitrsv_val_offset                         = waitimpl_val_offset            + `THREADS;
   localparam an_ac_reservation_vld_offset               = waitrsv_val_offset             + `THREADS;
   localparam an_ac_sleep_en_offset                      = an_ac_reservation_vld_offset   + `THREADS;
   localparam an_ac_coreid_offset                        = an_ac_sleep_en_offset          + `THREADS;
   localparam tb_update_enable_offset                    = an_ac_coreid_offset            + 8;
   localparam tb_update_pulse_offset                     = tb_update_enable_offset        + 1;
   localparam tb_update_pulse_1_offset                   = tb_update_pulse_offset         + 1;
   localparam pc_xu_reset_wd_complete_offset             = tb_update_pulse_1_offset       + 1;
   localparam pc_xu_reset_3_complete_offset              = pc_xu_reset_wd_complete_offset + 1;
   localparam pc_xu_reset_2_complete_offset              = pc_xu_reset_3_complete_offset  + 1;
   localparam pc_xu_reset_1_complete_offset              = pc_xu_reset_2_complete_offset  + 1;
   localparam lq_xu_dbell_val_offset                     = pc_xu_reset_1_complete_offset  + 1;
   localparam lq_xu_dbell_type_offset                    = lq_xu_dbell_val_offset         + 1;
   localparam lq_xu_dbell_brdcast_offset                 = lq_xu_dbell_type_offset        + 5;
   localparam lq_xu_dbell_lpid_match_offset              = lq_xu_dbell_brdcast_offset     + 1;
   localparam lq_xu_dbell_pirtag_offset                  = lq_xu_dbell_lpid_match_offset  + 1;
   localparam dbell_present_offset                       = lq_xu_dbell_pirtag_offset      + 14;
   localparam cdbell_present_offset                      = dbell_present_offset           + `THREADS;
   localparam gdbell_present_offset                      = cdbell_present_offset          + `THREADS;
   localparam gcdbell_present_offset                     = gdbell_present_offset          + `THREADS;
   localparam gmcdbell_present_offset                    = gcdbell_present_offset         + `THREADS;
   localparam xucr0_clfc_offset                          = gmcdbell_present_offset        + `THREADS;
   localparam iu_run_thread_offset                       = xucr0_clfc_offset              + 1;
   localparam inj_sprg_ecc_offset                        = iu_run_thread_offset           + `THREADS;
   localparam dbell_interrupt_offset                     = inj_sprg_ecc_offset            + `THREADS;
   localparam cdbell_interrupt_offset                    = dbell_interrupt_offset         + `THREADS;
   localparam gdbell_interrupt_offset                    = cdbell_interrupt_offset        + `THREADS;
   localparam gcdbell_interrupt_offset                   = gdbell_interrupt_offset        + `THREADS;
   localparam gmcdbell_interrupt_offset                  = gcdbell_interrupt_offset       + `THREADS;
   localparam iu_quiesce_offset                          = gmcdbell_interrupt_offset      + `THREADS;
	localparam iu_icache_quiesce_offset                   = iu_quiesce_offset              + `THREADS;
   localparam lsu_quiesce_offset                         = iu_icache_quiesce_offset       + `THREADS;
   localparam mm_quiesce_offset                          = lsu_quiesce_offset             + `THREADS;
   localparam bx_quiesce_offset                          = mm_quiesce_offset              + `THREADS;
   localparam quiesce_offset                             = bx_quiesce_offset              + `THREADS;
   localparam quiesced_offset                            = quiesce_offset                 + `THREADS;
   localparam instr_trace_mode_offset                    = quiesced_offset                + `THREADS;
   localparam instr_trace_tid_offset                     = instr_trace_mode_offset        + 1;
   localparam timer_update_offset                        = instr_trace_tid_offset         + 2;
   localparam spr_xu_ord_read_done_offset                = timer_update_offset            + 1;
   localparam spr_xu_ord_write_done_offset               = spr_xu_ord_read_done_offset    + 1;
   localparam xu_spr_ord_ready_offset                    = spr_xu_ord_write_done_offset   + 1;
   localparam ex4_sspr_val_offset                        = xu_spr_ord_ready_offset        + 1;
   localparam flush_offset                               = ex4_sspr_val_offset            + 1;
   localparam ex1_ifar_offset                            = flush_offset                   + `THREADS;
   localparam ex2_ifar_offset                            = ex1_ifar_offset                + `EFF_IFAR_WIDTH;
   localparam ram_active_offset                          = ex2_ifar_offset                + `EFF_IFAR_WIDTH;
   localparam timer_div_offset                           = ram_active_offset              + `THREADS;
   localparam msrovride_enab_2_offset                    = timer_div_offset               + 5;
   localparam msrovride_enab_3_offset                    = msrovride_enab_2_offset        + `THREADS;
	localparam ex3_wait_flush_offset                      = msrovride_enab_3_offset        + `THREADS;
	localparam ex4_wait_flush_offset                      = ex3_wait_flush_offset          + 1;
	localparam pc_xu_pm_hold_thread_offset                = ex4_wait_flush_offset          + 1;
	localparam power_savings_on_offset                    = pc_xu_pm_hold_thread_offset    + 1;
	localparam perf_event_bus_offset                      = power_savings_on_offset        + 1;
	localparam perf_event_en_offset                       = perf_event_bus_offset          + 4*`THREADS;
   localparam spare_0_offset                             = perf_event_en_offset           + `THREADS;
   localparam quiesced_ctr_offset                        = spare_0_offset                 + 16;
   localparam scan_right                                 = quiesced_ctr_offset            + 1;
   wire [0:scan_right-1]                 siv;
   wire [0:scan_right-1]                 sov;


   wire  [0:`THREADS-1]       ccr0_we_q,                  ccr0_we_d                  ;  // input=>ccr0_we_d                 , act=>1'b1              , scan=>Y, sleep=>Y, ring=>bcfg, needs_sreset=>1
	localparam ccr0_we_offset_bcfg                        = last_reg_offset_bcfg;
	localparam scan_right_bcfg                            = ccr0_we_offset_bcfg            + `THREADS;
   wire [0:scan_right_bcfg-1]            siv_bcfg;
   wire [0:scan_right_bcfg-1]            sov_bcfg;
   localparam                            scan_right_ccfg = last_reg_offset_ccfg;
   wire [0:scan_right_ccfg-1]            siv_ccfg;
   wire [0:scan_right_ccfg-1]            sov_ccfg;
   localparam                            scan_right_dcfg = last_reg_offset_dcfg;
   wire [0:scan_right_dcfg-1]            siv_dcfg;
   wire [0:scan_right_dcfg-1]            sov_dcfg;
   // Signals
   wire [00:63]                           tidn;
   wire [0:`NCLK_WIDTH-1]                 spare_0_lclk;
   wire                                   spare_0_d1clk;
   wire                                   spare_0_d2clk;
   wire [00:63]                           tb;
   wire                                   ex1_opcode_is_31;
   wire                                   ex1_opcode_is_19;
   wire                                   ex1_is_mfcr;
   wire                                   ex1_is_mtcrf;
   wire                                   ex1_is_dnh;
   wire                                   ex1_is_mfmsr;
   wire                                   ex3_sspr_val;
   wire [0:`THREADS-1]                    ex2_tid;
   wire                                   ex2_illeg_mfspr;
   wire                                   ex2_illeg_mtspr;
   wire                                   ex2_illeg_mftb;
   wire                                   ex2_hypv_mfspr;
   wire                                   ex2_hypv_mtspr;
   wire [11:20]                           ex1_instr;
   wire [11:20]                           ex2_instr;
   wire [11:20]                           ex3_instr;
   wire                                   ex2_slowspr_range_priv;
   wire                                   ex2_slowspr_range_hypv;
   wire                                   ex2_slowspr_range;
   wire [0:`THREADS-1]                    ex2_wait_flush;
   wire [0:`THREADS-1]                    ex2_ccr0_flush;
   wire [0:`THREADS-1]                    ex2_tenc_flush;
   wire [0:`THREADS-1]                    ex2_xucr0_flush;
   wire [64-`GPR_WIDTH:63]                ex3_tspr_rt;
   wire [64-`GPR_WIDTH:63]                ex3_cspr_rt;
   wire [0:`THREADS-1]                    ex3_tid;
   wire [64-`GPR_WIDTH:63]                ex2_rt;
   wire [64-`GPR_WIDTH:63]                ex2_rt_inj;
   wire                                   llunmasked;
   wire                                   llmasked;
   wire                                   llpulse;
   wire                                   llpres;
   wire                                   llpri_inc;
   wire [0:`THREADS-1]                    llmask;
   wire [0:`THREADS-1]                    pm_wake_up;
   wire [0:3]                             ccr0_we;
   wire [0:`THREADS-1]                    ccr0_wen, ccr0_we_di;
   wire                                   dbell_pir_match;
   wire [0:`THREADS-1]                    dbell_pir_thread;
   wire [0:`THREADS-1]                    spr_ccr0_we_rev;
   wire [0:`THREADS-1]                    spr_tens_ten_rev;
   wire [0:`THREADS-1]                    set_dbell;
   wire [0:`THREADS-1]                    clr_dbell;
   wire [0:`THREADS-1]                    set_cdbell;
   wire [0:`THREADS-1]                    clr_cdbell;
   wire [0:`THREADS-1]                    set_gdbell;
   wire [0:`THREADS-1]                    clr_gdbell;
   wire [0:`THREADS-1]                    set_gcdbell;
   wire [0:`THREADS-1]                    clr_gcdbell;
   wire [0:`THREADS-1]                    set_gmcdbell;
   wire [0:`THREADS-1]                    clr_gmcdbell;
   wire                                   tb_update_pulse;
   wire [0:`THREADS-1]                    spr_tensr;
   wire                                   ex3_is_mtspr;
   wire [0:63]                            tb_q;
   wire [0:`THREADS-1]                    crit_mask;
   wire [0:`THREADS-1]                    base_mask;
   wire [0:`THREADS-1]                    dec_mask;
   wire [0:`THREADS-1]                    fit_mask;
   wire [0:`THREADS-1]                    ex3_wait;
   wire [38:63]                           xucr0_di;
   wire [64-`GPR_WIDTH:72-(64/`GPR_WIDTH)] ex2_eccgen_data;
   wire [64:72-(64/`GPR_WIDTH)]           ex2_eccgen_syn;
   wire [64:72-(64/`GPR_WIDTH)]           ex3_eccchk_syn;
   wire [64:72-(64/`GPR_WIDTH)]           ex3_eccchk_syn_b;
   wire                                   ex2_is_mfsspr_b;
   wire                                   encorr;
   wire                                   ex3_sprg_ce, ex3_sprg_ue;
   wire                                   ex2_aspr_we;
   wire [64-`GPR_WIDTH:63]                ex4_aspr_rt;
   wire [0:`THREADS-1]                    quiesce_ctr_zero_b;
   wire [0:`THREADS-1]                    quiesce_b_q;
   wire [0:`THREADS-1]                    running;
   wire                                   timer_update_int;
   wire [0:4]                             exx_act;
   wire [1:3]                             exx_act_data;
   wire                                   ex0_act;
   wire                                   ex2_inj_ecc;
   wire [32:47]                           version;
   wire [48:63]                           revision;
   wire [0:`THREADS-1]                    instr_trace_tid;
   wire [0:`THREADS-1]                    ex3_val;
   wire [0:3]                             ex2_aspr_addr;
   wire                                   ex1_spr_rd;
   wire                                   ex1_spr_wr;
   wire                                   flush_int;
   wire                                   ex2_flush;
   wire                                   ex3_flush;
   wire                                   ex1_valid;
   wire                                   ex1_is_wrtee;
   wire                                   ex1_is_wrteei;
   wire                                   ord_ready;
   wire                                   ex2_msr_pr;
   wire                                   ex2_msr_gs;
   wire                                   timer_div_act;
   wire [0:4]                             timer_div;
   wire                                   ex3_spr_we;
   wire                                   ex2_aspr_addr_act;
   wire                                   ex3_rt_act;
   wire [0:`THREADS-1]                    ex2_np1_flush;
   wire                                   power_savings_en, power_savings_on;
   (* analysis_not_referenced="true" *)
   wire                                   unused_do_bits;

   // Data
	wire [0:1]                       spr_ccr0_pme;
	wire [0:3]                       spr_ccr0_we;
	wire                             spr_ccr2_en_dcr_int;
	wire                             spr_ccr2_en_pc;
	wire                             spr_ccr4_en_dnh;
	wire [0:`THREADS-1]              spr_tens_ten;
	wire [0:4]                       spr_xucr0_clkg_ctl;
	wire                             spr_xucr0_tcs;
	wire [0:1]                       spr_xucr4_tcd;
	wire [62:63]                     ex3_ccr0_di;
	wire [40:63]                     ex3_ccr1_di;
	wire [32:63]                     ex3_ccr2_di;
	wire [63:63]                     ex3_ccr4_di;
	wire [32:63]                     ex3_tbl_di;
	wire [32:63]                     ex3_tbu_di;
	wire [64-(`THREADS):63]          ex3_tens_di;
	wire [32:63]                     ex3_xesr1_di;
	wire [32:63]                     ex3_xesr2_di;
	wire [38:63]                     ex3_xucr0_di;
	wire [60:63]                     ex3_xucr4_di;
	wire
		ex1_gsprg0_re  , ex1_gsprg1_re  , ex1_gsprg2_re  , ex1_gsprg3_re
		, ex1_sprg0_re   , ex1_sprg1_re   , ex1_sprg2_re   , ex1_sprg3_re
		, ex1_sprg4_re   , ex1_sprg5_re   , ex1_sprg6_re   , ex1_sprg7_re
		, ex1_sprg8_re   , ex1_vrsave_re  ;
	wire
		ex1_gsprg0_rdec, ex1_gsprg1_rdec, ex1_gsprg2_rdec, ex1_gsprg3_rdec
		, ex1_sprg0_rdec , ex1_sprg1_rdec , ex1_sprg2_rdec , ex1_sprg3_rdec
		, ex1_sprg4_rdec , ex1_sprg5_rdec , ex1_sprg6_rdec , ex1_sprg7_rdec
		, ex1_sprg8_rdec , ex1_vrsave_rdec;
   wire ex2_sprg8_re;
	wire
		ex2_ccr0_re    , ex2_ccr1_re    , ex2_ccr2_re    , ex2_ccr4_re
		, ex2_cir_re     , ex2_pir_re     , ex2_pvr_re     , ex2_tb_re
		, ex2_tbu_re     , ex2_tenc_re    , ex2_tens_re    , ex2_tensr_re
		, ex2_tir_re     , ex2_xesr1_re   , ex2_xesr2_re   , ex2_xucr0_re
		, ex2_xucr4_re   ;
	wire
		ex2_acop_re    , ex2_axucr0_re  , ex2_cpcr0_re   , ex2_cpcr1_re
		, ex2_cpcr2_re   , ex2_cpcr3_re   , ex2_cpcr4_re   , ex2_cpcr5_re
		, ex2_dac1_re    , ex2_dac2_re    , ex2_dac3_re    , ex2_dac4_re
		, ex2_dbcr2_re   , ex2_dbcr3_re   , ex2_dscr_re    , ex2_dvc1_re
		, ex2_dvc2_re    , ex2_eheir_re   , ex2_eplc_re    , ex2_epsc_re
		, ex2_eptcfg_re  , ex2_givpr_re   , ex2_hacop_re   , ex2_iac1_re
		, ex2_iac2_re    , ex2_iac3_re    , ex2_iac4_re    , ex2_immr_re
		, ex2_imr_re     , ex2_iucr0_re   , ex2_iucr1_re   , ex2_iucr2_re
		, ex2_iudbg0_re  , ex2_iudbg1_re  , ex2_iudbg2_re  , ex2_iulfsr_re
		, ex2_iullcr_re  , ex2_ivpr_re    , ex2_lesr1_re   , ex2_lesr2_re
		, ex2_lper_re    , ex2_lperu_re   , ex2_lpidr_re   , ex2_lratcfg_re
		, ex2_lratps_re  , ex2_lsucr0_re  , ex2_mas0_re    , ex2_mas0_mas1_re
		, ex2_mas1_re    , ex2_mas2_re    , ex2_mas2u_re   , ex2_mas3_re
		, ex2_mas4_re    , ex2_mas5_re    , ex2_mas5_mas6_re, ex2_mas6_re
		, ex2_mas7_re    , ex2_mas7_mas3_re, ex2_mas8_re    , ex2_mas8_mas1_re
		, ex2_mmucfg_re  , ex2_mmucr0_re  , ex2_mmucr1_re  , ex2_mmucr2_re
		, ex2_mmucr3_re  , ex2_mmucsr0_re , ex2_pesr_re    , ex2_pid_re
		, ex2_ppr32_re   , ex2_sramd_re   , ex2_tlb0cfg_re , ex2_tlb0ps_re
		, ex2_xucr2_re   , ex2_xudbg0_re  , ex2_xudbg1_re  , ex2_xudbg2_re  ;
	wire
		ex2_ccr0_we    , ex2_ccr1_we    , ex2_ccr2_we    , ex2_ccr4_we
		, ex2_tbl_we     , ex2_tbu_we     , ex2_tenc_we    , ex2_tens_we
		, ex2_trace_we   , ex2_xesr1_we   , ex2_xesr2_we   , ex2_xucr0_we
		, ex2_xucr4_we   ;
	wire
		ex2_acop_we    , ex2_axucr0_we  , ex2_cpcr0_we   , ex2_cpcr1_we
		, ex2_cpcr2_we   , ex2_cpcr3_we   , ex2_cpcr4_we   , ex2_cpcr5_we
		, ex2_dac1_we    , ex2_dac2_we    , ex2_dac3_we    , ex2_dac4_we
		, ex2_dbcr2_we   , ex2_dbcr3_we   , ex2_dscr_we    , ex2_dvc1_we
		, ex2_dvc2_we    , ex2_eheir_we   , ex2_eplc_we    , ex2_epsc_we
		, ex2_givpr_we   , ex2_hacop_we   , ex2_iac1_we    , ex2_iac2_we
		, ex2_iac3_we    , ex2_iac4_we    , ex2_immr_we    , ex2_imr_we
		, ex2_iucr0_we   , ex2_iucr1_we   , ex2_iucr2_we   , ex2_iudbg0_we
		, ex2_iulfsr_we  , ex2_iullcr_we  , ex2_ivpr_we    , ex2_lesr1_we
		, ex2_lesr2_we   , ex2_lper_we    , ex2_lperu_we   , ex2_lpidr_we
		, ex2_lsucr0_we  , ex2_mas0_we    , ex2_mas0_mas1_we, ex2_mas1_we
		, ex2_mas2_we    , ex2_mas2u_we   , ex2_mas3_we    , ex2_mas4_we
		, ex2_mas5_we    , ex2_mas5_mas6_we, ex2_mas6_we    , ex2_mas7_we
		, ex2_mas7_mas3_we, ex2_mas8_we    , ex2_mas8_mas1_we, ex2_mmucr0_we
		, ex2_mmucr1_we  , ex2_mmucr2_we  , ex2_mmucr3_we  , ex2_mmucsr0_we
		, ex2_pesr_we    , ex2_pid_we     , ex2_ppr32_we   , ex2_xucr2_we
		, ex2_xudbg0_we  ;
	wire
		ex2_gsprg0_we  , ex2_gsprg1_we  , ex2_gsprg2_we  , ex2_gsprg3_we
		, ex2_sprg0_we   , ex2_sprg1_we   , ex2_sprg2_we   , ex2_sprg3_we
		, ex2_sprg4_we   , ex2_sprg5_we   , ex2_sprg6_we   , ex2_sprg7_we
		, ex2_sprg8_we   , ex2_vrsave_we  ;
	wire
		ex2_ccr0_rdec  , ex2_ccr1_rdec  , ex2_ccr2_rdec  , ex2_ccr4_rdec
		, ex2_cir_rdec   , ex2_pir_rdec   , ex2_pvr_rdec   , ex2_tb_rdec
		, ex2_tbu_rdec   , ex2_tenc_rdec  , ex2_tens_rdec  , ex2_tensr_rdec
		, ex2_tir_rdec   , ex2_xesr1_rdec , ex2_xesr2_rdec , ex2_xucr0_rdec
		, ex2_xucr4_rdec ;
	wire
		ex2_acop_rdec  , ex2_axucr0_rdec, ex2_cpcr0_rdec , ex2_cpcr1_rdec
		, ex2_cpcr2_rdec , ex2_cpcr3_rdec , ex2_cpcr4_rdec , ex2_cpcr5_rdec
		, ex2_dac1_rdec  , ex2_dac2_rdec  , ex2_dac3_rdec  , ex2_dac4_rdec
		, ex2_dbcr2_rdec , ex2_dbcr3_rdec , ex2_dscr_rdec  , ex2_dvc1_rdec
		, ex2_dvc2_rdec  , ex2_eheir_rdec , ex2_eplc_rdec  , ex2_epsc_rdec
		, ex2_eptcfg_rdec, ex2_givpr_rdec , ex2_hacop_rdec , ex2_iac1_rdec
		, ex2_iac2_rdec  , ex2_iac3_rdec  , ex2_iac4_rdec  , ex2_immr_rdec
		, ex2_imr_rdec   , ex2_iucr0_rdec , ex2_iucr1_rdec , ex2_iucr2_rdec
		, ex2_iudbg0_rdec, ex2_iudbg1_rdec, ex2_iudbg2_rdec, ex2_iulfsr_rdec
		, ex2_iullcr_rdec, ex2_ivpr_rdec  , ex2_lesr1_rdec , ex2_lesr2_rdec
		, ex2_lper_rdec  , ex2_lperu_rdec , ex2_lpidr_rdec , ex2_lratcfg_rdec
		, ex2_lratps_rdec, ex2_lsucr0_rdec, ex2_mas0_rdec  , ex2_mas0_mas1_rdec
		, ex2_mas1_rdec  , ex2_mas2_rdec  , ex2_mas2u_rdec , ex2_mas3_rdec
		, ex2_mas4_rdec  , ex2_mas5_rdec  , ex2_mas5_mas6_rdec, ex2_mas6_rdec
		, ex2_mas7_rdec  , ex2_mas7_mas3_rdec, ex2_mas8_rdec  , ex2_mas8_mas1_rdec
		, ex2_mmucfg_rdec, ex2_mmucr0_rdec, ex2_mmucr1_rdec, ex2_mmucr2_rdec
		, ex2_mmucr3_rdec, ex2_mmucsr0_rdec, ex2_pesr_rdec  , ex2_pid_rdec
		, ex2_ppr32_rdec , ex2_sramd_rdec , ex2_tlb0cfg_rdec, ex2_tlb0ps_rdec
		, ex2_xucr2_rdec , ex2_xudbg0_rdec, ex2_xudbg1_rdec, ex2_xudbg2_rdec;
	wire
		ex2_gsprg0_rdec, ex2_gsprg1_rdec, ex2_gsprg2_rdec, ex2_gsprg3_rdec
		, ex2_sprg0_rdec , ex2_sprg1_rdec , ex2_sprg2_rdec , ex2_sprg3_rdec
		, ex2_sprg4_rdec , ex2_sprg5_rdec , ex2_sprg6_rdec , ex2_sprg7_rdec
		, ex2_sprg8_rdec , ex2_vrsave_rdec;
	wire
		ex2_ccr0_wdec  , ex2_ccr1_wdec  , ex2_ccr2_wdec  , ex2_ccr4_wdec
		, ex2_tbl_wdec   , ex2_tbu_wdec   , ex2_tenc_wdec  , ex2_tens_wdec
		, ex2_trace_wdec , ex2_xesr1_wdec , ex2_xesr2_wdec , ex2_xucr0_wdec
		, ex2_xucr4_wdec ;
	wire
		ex2_gsprg0_wdec, ex2_gsprg1_wdec, ex2_gsprg2_wdec, ex2_gsprg3_wdec
		, ex2_sprg0_wdec , ex2_sprg1_wdec , ex2_sprg2_wdec , ex2_sprg3_wdec
		, ex2_sprg4_wdec , ex2_sprg5_wdec , ex2_sprg6_wdec , ex2_sprg7_wdec
		, ex2_sprg8_wdec , ex2_vrsave_wdec;
	wire
		ex2_acop_wdec  , ex2_axucr0_wdec, ex2_cpcr0_wdec , ex2_cpcr1_wdec
		, ex2_cpcr2_wdec , ex2_cpcr3_wdec , ex2_cpcr4_wdec , ex2_cpcr5_wdec
		, ex2_dac1_wdec  , ex2_dac2_wdec  , ex2_dac3_wdec  , ex2_dac4_wdec
		, ex2_dbcr2_wdec , ex2_dbcr3_wdec , ex2_dscr_wdec  , ex2_dvc1_wdec
		, ex2_dvc2_wdec  , ex2_eheir_wdec , ex2_eplc_wdec  , ex2_epsc_wdec
		, ex2_givpr_wdec , ex2_hacop_wdec , ex2_iac1_wdec  , ex2_iac2_wdec
		, ex2_iac3_wdec  , ex2_iac4_wdec  , ex2_immr_wdec  , ex2_imr_wdec
		, ex2_iucr0_wdec , ex2_iucr1_wdec , ex2_iucr2_wdec , ex2_iudbg0_wdec
		, ex2_iulfsr_wdec, ex2_iullcr_wdec, ex2_ivpr_wdec  , ex2_lesr1_wdec
		, ex2_lesr2_wdec , ex2_lper_wdec  , ex2_lperu_wdec , ex2_lpidr_wdec
		, ex2_lsucr0_wdec, ex2_mas0_wdec  , ex2_mas0_mas1_wdec, ex2_mas1_wdec
		, ex2_mas2_wdec  , ex2_mas2u_wdec , ex2_mas3_wdec  , ex2_mas4_wdec
		, ex2_mas5_wdec  , ex2_mas5_mas6_wdec, ex2_mas6_wdec  , ex2_mas7_wdec
		, ex2_mas7_mas3_wdec, ex2_mas8_wdec  , ex2_mas8_mas1_wdec, ex2_mmucr0_wdec
		, ex2_mmucr1_wdec, ex2_mmucr2_wdec, ex2_mmucr3_wdec, ex2_mmucsr0_wdec
		, ex2_pesr_wdec  , ex2_pid_wdec   , ex2_ppr32_wdec , ex2_xucr2_wdec
		, ex2_xudbg0_wdec;
	wire
		ex3_ccr0_we    , ex3_ccr1_we    , ex3_ccr2_we    , ex3_ccr4_we
		, ex3_tbl_we     , ex3_tbu_we     , ex3_tenc_we    , ex3_tens_we
		, ex3_xesr1_we   , ex3_xesr2_we   , ex3_xucr0_we   , ex3_xucr4_we   ;
	wire
		ex3_ccr0_wdec  , ex3_ccr1_wdec  , ex3_ccr2_wdec  , ex3_ccr4_wdec
		, ex3_tbl_wdec   , ex3_tbu_wdec   , ex3_tenc_wdec  , ex3_tens_wdec
		, ex3_xesr1_wdec , ex3_xesr2_wdec , ex3_xucr0_wdec , ex3_xucr4_wdec ;
	wire
		ccr0_act       , ccr1_act       , ccr2_act       , ccr4_act
		, cir_act        , pir_act        , pvr_act        , tb_act
		, tbl_act        , tbu_act        , tenc_act       , tens_act
		, tensr_act      , tir_act        , xesr1_act      , xesr2_act
		, xucr0_act      , xucr4_act      ;
	wire [0:64]
		ccr0_do        , ccr1_do        , ccr2_do        , ccr4_do
		, cir_do         , pir_do         , pvr_do         , tb_do
		, tbl_do         , tbu_do         , tenc_do        , tens_do
		, tensr_do       , tir_do         , xesr1_do       , xesr2_do
		, xucr0_do       , xucr4_do       ;


   wire [64-`GPR_WIDTH:64+8-(64/`GPR_WIDTH)] ex3_spr_wd;

   //!! Bugspray Include: xu_spr_cspr;
   //## figtree_source: xu_spr_cspr.fig;

   assign tidn                = {64{1'b0}};

   assign cspr_xucr0_clkg_ctl = spr_xucr0_clkg_ctl;

   assign ex1_aspr_act_d      = ex0_act;

   assign ex0_act             = |ex0_val_q & rv_xu_ex0_ord;
   assign exx_act_d[1:4]      = exx_act[0:3];

   assign exx_act[0]          = ex0_act;
   assign exx_act[1]          = exx_act_q[1];
   assign exx_act[2]          = exx_act_q[2];
   assign exx_act[3]          = exx_act_q[3] | ex3_spr_we_q;
   assign exx_act[4]          = exx_act_q[4];

   // Needs to be on for loads and stores, for the DEAR...
   assign exx_act_data[1]     = exx_act[1];
   assign exx_act_data[2]     = exx_act[2];
   assign exx_act_data[3]     = exx_act[3];

   assign cspr_tspr_rf1_act   = exx_act[0];

   // Decode
   assign ex1_opcode_is_19    = ex1_instr_q[0:5] == 6'b010011;
   assign ex1_opcode_is_31    = ex1_instr_q[0:5] == 6'b011111;
   assign ex1_is_mfspr        = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0101010011);    // 31/339
   assign ex1_is_mtspr        = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0111010011);    // 31/467
   assign ex1_is_mfmsr        = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0001010011);    // 31/083
   assign ex1_is_mtmsr        = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0010010010);    // 31/146
   assign ex1_is_mftb         = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0101110011);    // 31/371
   assign ex1_is_wait         = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0000111110);    // 31/062
   assign ex1_is_msgclr       = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0011101110);    // 31/238
   assign ex1_is_wrtee        = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0010000011);    // 31/131
   assign ex1_is_wrteei       = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0010100011);    // 31/163
   assign ex1_is_mfcr         = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0000010011);    // 31/19
   assign ex1_is_mtcrf        = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0010010000);    // 31/144
   assign ex1_is_dnh          = (ex1_opcode_is_19 & ex1_instr_q[21:30] == 10'b0011000110);    // 19/198

   assign ex1_priv_instr      = ex1_is_mtmsr | ex1_is_mfmsr | ex1_is_wrtee | ex1_is_wrteei | ex1_is_msgclr;

   assign ex1_hypv_instr      = ex1_is_msgclr;

   assign ex1_spr_rd          = ex1_is_mfspr | ex1_is_mfmsr | ex1_is_mftb;
   assign ex1_spr_wr          = ex1_is_mtspr | ex1_is_mtmsr | ex1_is_wrtee |
                               ex1_is_wrteei | ex1_is_msgclr | ex1_is_wait | ex1_is_dnh;

   assign ex2_is_mtmsr_d      = ex1_is_mtmsr | ex1_is_wrtee | ex1_is_wrteei;

   assign rv2_val             = rv_xu_vld & (~flush_q);
   assign ex0_val             = ex0_val_q & (~flush_q) & {`THREADS{rv_xu_ex0_ord}};
   assign ex1_val             = ex1_val_q & (~flush_q);
   assign ex2_val             = ex2_val_q & (~flush_q);
   assign ex3_val             = ex3_val_q & (~flush_q);

   assign ex1_valid           = |(ex1_val);

   assign ex2_flush           = |(ex2_tid & flush_q) & (ex2_val_rd_q | ex2_val_wr_q);
   assign ex3_flush           = |(ex3_tid & flush_q) & (ex3_val_rd_q | ex2_val_wr_q);

   // For CPCRs wait until quiesce

   wire   ord_quiesce         = &lsu_quiesce_q | ~(ex2_is_mtspr_q & (ex2_cpcr0_wdec | ex2_cpcr1_wdec | ex2_cpcr2_wdec | ex2_cpcr3_wdec | ex2_cpcr4_wdec | ex2_cpcr5_wdec)) | ex2_is_wait_q;

   // On exception, do not wait for ord_ready.  No write will occur.
   assign ord_ready           = xu_spr_ord_ready_q | flush_int;

   assign flush_int           = ex3_hypv_spr_q | ex3_illeg_spr_q | ex3_priv_spr_q;

   assign ex2_val_rd_d        = ((ex1_valid & ex1_spr_rd) | ex2_val_rd_q) & ~ex2_flush & ~ex2_val_rd_q;
   assign ex2_val_wr_d        = ((ex1_valid & ex1_spr_wr) | (ex2_val_wr_q & ~ex2_flush & ~(ord_ready & ord_quiesce)));

   assign ex3_val_rd_d        = ex2_val_rd_q & ~ex2_flush;

   assign ex3_spr_we_d        = ex2_val_wr_q & ~ex2_flush & ord_ready & ord_quiesce;
   assign ex3_spr_we          = ex3_spr_we_q & ~flush_int;
   assign cspr_tspr_ex3_spr_we = ex3_tid & {`THREADS{ex3_spr_we}};

   assign ex3_sspr_val        = ((ex3_spr_we & ex3_sspr_wr_val_q) | (ex3_val_rd_q & ex3_sspr_rd_val_q)) & (~(ex3_flush | flush_int));

   assign spr_xu_ord_read_done_d    = ex3_spr_we_q & (~ex3_sspr_wr_val_q | flush_int) & ~ex3_flush;
   assign spr_xu_ord_write_done_d   = ex3_val_rd_q & (~ex3_sspr_rd_val_q | flush_int) & ~ex3_flush;

   assign spr_xu_ord_write_done  = spr_xu_ord_write_done_q & ~ex3_flush;
   assign spr_xu_ord_read_done   = spr_xu_ord_read_done_q  & ~ex3_flush;

   assign ex1_instr        = ex1_instr_q[11:20];
   assign ex2_instr_d      = ex1_instr_q[11:20] & {10{(ex1_is_mfspr | ex1_is_mtspr | ex1_is_wrteei | ex1_is_mftb)}};
   assign ex2_instr        = ex2_instr_q[11:20];
   assign ex3_instr_d      = ex2_instr_q;		// or gate(ex2_dcrn_q,ex2_dcr_val_q);
   assign ex3_instr        = ex3_instr_q[11:20];
   assign ex3_spr_wd       = ex3_rt_q;
   assign ex3_spr_wd_out   = ex3_rt_q;
   assign ex3_is_mtspr     = ex3_is_mtspr_q;
   assign ex2_ifar         = ex2_ifar_q;

   assign ex3_wait         = ex3_tid & {`THREADS{(ex3_spr_we & ex3_wait_q & ex3_wait_flush_q)}};

   assign spr_tens_ten_rev       = reverse_threads(spr_tens_ten);
   assign spr_tensr              = spr_tens_ten | reverse_threads(running);
   assign spr_ccr0_we_rev        = reverse_threads(spr_ccr0_we[4-`THREADS:3]);

// Run State
assign quiesce_b_q   = ~(quiesce_q & ~running_q);
assign quiesce_d     = iu_quiesce_q & iu_icache_quiesce_q & lsu_quiesce_q & mm_quiesce_q & bx_quiesce_q;

assign quiesced_d    = quiesce_q & ~quiesce_ctr_zero_b;

assign xu_pc_running = running;

assign running          = running_q | ~quiesced_q;
assign running_d        = ~(iu_xu_stop | spr_ccr0_we_rev) & spr_tens_ten_rev;
assign iu_run_thread_d  = (running_q & llmask) & ~{`THREADS{power_savings_on}};
assign xu_iu_run_thread = iu_run_thread_q;

assign ex1_tenc_we      = (ex1_instr_q[11:20] == 10'b1011101101);		//  439
assign ex1_ccr0_we      = (ex1_instr_q[11:20] == 10'b1000011111);		// 1008

// Power Management Control
assign xu_pc_spr_ccr0_we   = spr_ccr0_we_rev & quiesced_q;
assign xu_pc_spr_ccr0_pme  = spr_ccr0_pme;

assign power_savings_on    = (power_savings_en | power_savings_on_q);

assign power_savings_on_d  =  power_savings_on & ~(~pc_xu_pm_hold_thread & pc_xu_pm_hold_thread_q);

assign power_savings_en    = ^spr_ccr0_pme &       // Power Management Enabled
                             &spr_ccr0_we_rev &    // Wait Enable = 1
                             &quiesced_q;          // Core Quiesced

// Wakeup Condition Masking

// Reset the mask when running
// Set the mask on a valid wait instruction
// Otherwise hold

// WAIT[WC](0) = Resume on Imp. Specific
// WAIT[WC](1) = Resume on no reservation
generate
   begin : pm_wake_up_gen
      genvar                                t;
      for (t=0;t<=`THREADS-1;t=t+1)
      begin : thread
         assign waitimpl_val_d[t]   = (ex3_wait[t] == 1'b1)    ? ex3_wait_wc_q[9] :
                                      (pm_wake_up[t] == 1'b1)  ? 1'b0 :
                                                                 waitimpl_val_q[t];

         assign waitrsv_val_d[t]    = (ex3_wait[t] == 1'b1)    ? ex3_wait_wc_q[10] :
                                      (pm_wake_up[t] == 1'b1)  ? 1'b0 :
                                                                 waitrsv_val_q[t];

         // Block interrupts (mask=0) if:
         // Stopped via (HW Debug and pc_xu_extirpts_dis_on_stop)=1
         // Stopped via TEN=0
         // Stopped via CCR0=1, unless overriden by CCR1=1 (and wait, if applicable)
         assign crit_mask[t]  = (~(ext_dbg_dis_q[t] | ~spr_tens_ten_rev[t] | (spr_ccr0_we_rev[t] & ~ccr1_q[60-6*t])));
         assign base_mask[t]  = (~(ext_dbg_dis_q[t] | ~spr_tens_ten_rev[t] | (spr_ccr0_we_rev[t] & ~ccr1_q[61-6*t])));
         assign dec_mask[t]   = (~(ext_dbg_dis_q[t] | ~spr_tens_ten_rev[t] | (spr_ccr0_we_rev[t] & ~ccr1_q[62-6*t])));
         assign fit_mask[t]   = (~(ext_dbg_dis_q[t] | ~spr_tens_ten_rev[t] | (spr_ccr0_we_rev[t] & ~ccr1_q[63-6*t])));

         assign cspr_tspr_crit_mask[t] = crit_mask[t];
         assign cspr_tspr_ext_mask[t]  = base_mask[t];
         assign cspr_tspr_dec_mask[t]  = dec_mask[t];
         assign cspr_tspr_fit_mask[t]  = fit_mask[t];
         assign cspr_tspr_wdog_mask[t] = crit_mask[t];
         assign cspr_tspr_udec_mask[t] = dec_mask[t];
         assign cspr_tspr_perf_mask[t] = base_mask[t];

          // Generate Conditional Wait flush
         // Reservation Exists
         assign ex2_wait_flush[t]   = ex2_tid[t] & ex2_is_wait_q &                                                                              // Unconditional Wait
                                    ((ex2_wait_wc_q == 2'b00) | (ex2_wait_wc_q == 2'b01 & an_ac_reservation_vld_q[t] & (~ccr1_q[58-6*t])) |     // Reservation Exists
                                     (ex2_wait_wc_q == 2'b10                            & an_ac_sleep_en_q[t]        & (~ccr1_q[59-6*t])));		// Impl. Specific Exists (Sleep enabled)


         assign ex2_ccr0_flush[t]   = ex2_is_mtspr_q & ex2_ccr0_we_q & xu_spr_ex2_rs1[55-t] & xu_spr_ex2_rs1[63-t];

         assign ex2_tenc_flush[t]   = ex2_is_mtspr_q & ex2_tenc_we_q & xu_spr_ex2_rs1[63-t];

         assign ex2_xucr0_flush[t]  = ex2_is_mtspr_q & ex2_xucr0_wdec;
      end
   end
   endgenerate

   assign cspr_tspr_sleep_mask   = ~power_savings_on_q;

   assign pm_wake_up =  (~an_ac_reservation_vld_q  & waitrsv_val_q) |
                        (~an_ac_sleep_en_q         & waitimpl_val_q) |
                          tspr_cspr_pm_wake_up |
                          dbell_interrupt_q |
                          cdbell_interrupt_q |
                          gdbell_interrupt_q |
                          gcdbell_interrupt_q |
                          gmcdbell_interrupt_q;

   // Debug Timer Disable
   assign tb_dbg_dis_d  = &iu_xu_stop & pc_xu_timebase_dis_on_stop;
   assign dec_dbg_dis_d = iu_xu_stop & {`THREADS{pc_xu_decrem_dis_on_stop}};
   assign ext_dbg_dis_d = iu_xu_stop & {`THREADS{pc_xu_extirpts_dis_on_stop}};

   // LiveLock Priority
   assign cspr_tspr_llen   = running_q;
   assign cspr_tspr_llpri  = llpri_q;
   assign llpres           = |(tspr_cspr_lldet);
   assign llunmasked       = |( llpri_q & tspr_cspr_lldet);
   assign llmasked         = |(~llpri_q & tspr_cspr_lldet);
   assign llpulse          = |( llpri_q & tspr_cspr_llpulse);

   // Increment the hang priority if:
   //    There is a       hang present, but the priority is masking it.
   //    There is another hang present, and there is a hang pulse.
   assign llpri_inc = (llpres & (~llunmasked)) | (llpulse & llmasked & llunmasked);

   generate
      if (`THREADS == 1)
      begin : tid1
         assign llpri_d = 1'b1;
         assign ex0_tid = 2'b00;
         assign ex2_tid = 1'b1;
         assign ex3_tid = 1'b1;
         assign instr_trace_tid = 1'b1;
      end
   endgenerate
   generate
      if (`THREADS == 2)
      begin : tid2
         assign llpri_d = {llpri_q[`THREADS - 1], llpri_q[0:`THREADS - 2]};
         assign ex0_tid = {1'b0, ex0_val_q[1]};
         assign ex2_tid[0] = ~ex2_tid_q[0] & ~ex2_tid_q[1];
         assign ex2_tid[1] = ~ex2_tid_q[0] &  ex2_tid_q[1];
         assign ex3_tid[0] = ~ex3_tid_q[0] & ~ex3_tid_q[1];
         assign ex3_tid[1] = ~ex3_tid_q[0] &  ex3_tid_q[1];
         assign instr_trace_tid[0] = ~instr_trace_tid_q[0] & ~instr_trace_tid_q[1];
         assign instr_trace_tid[1] = ~instr_trace_tid_q[0] &  instr_trace_tid_q[1];
      end
   endgenerate

assign llmask           = (llpri_q & tspr_cspr_lldet) | ~{`THREADS{llpres}};

assign instr_trace_mode = instr_trace_tid & {`THREADS{instr_trace_mode_q}};

assign ex1_msr_gs_d     = {1{|(tspr_msr_gs & ex0_val_q)}};

assign cspr_tspr_ram_active = ram_active_q;

assign cspr_tspr_msrovride_en = msrovride_enab;
assign msrovride_enab         = ram_active_q & {`THREADS{msrovride_enab_q}};

assign xu_iu_msrovride_enab   = msrovride_enab_2_q | msrovride_enab_3_q;

// Perf Events

assign perf_event_en_d  = ( tspr_msr_pr &                {`THREADS{pc_xu_event_count_mode[0]}})  |  // User
                          (~tspr_msr_pr &  tspr_msr_gs & {`THREADS{pc_xu_event_count_mode[1]}})  |  // Guest Supervisor
                          (~tspr_msr_pr & ~tspr_msr_gs & {`THREADS{pc_xu_event_count_mode[2]}})  ;  // Hypervisor


wire [0:16*`THREADS-1] perf_events;
wire [0:0] core_event;
   generate
   begin : perf_count
      genvar                                t;
      for (t = 0; t <= `THREADS - 1; t = t + 1)
      begin : thread
         assign core_event          = perf_event_en_q[t] & running[t];

         assign perf_events[0+16*t] = core_event[0];
         assign perf_events[1+16*t] = perf_event_en_q[t] & running[t];
         assign perf_events[2+16*t] = perf_event_en_q[t] & tb_act_q;
         assign perf_events[3+16*t] = perf_event_en_q[t] & waitrsv_val_q[t];
         assign perf_events[4+16*t] = perf_event_en_q[t] & tspr_cspr_async_int[0+3*t];
         assign perf_events[5+16*t] = perf_event_en_q[t] & tspr_cspr_async_int[1+3*t];
         assign perf_events[6+16*t] = perf_event_en_q[t] & tspr_cspr_async_int[2+3*t];
         assign perf_events[7+16*t] = perf_event_en_q[t] & (cpl_dbell_taken_q[t] | cpl_cdbell_taken_q[t] | cpl_gdbell_taken_q[t] | cpl_gcdbell_taken_q[t] | cpl_gmcdbell_taken_q[t]);
         assign perf_events[8+16*t] = perf_event_en_q[t] & div_spr_running[t];
         assign perf_events[9+16*t] = perf_event_en_q[t] & mul_spr_running[t];
         assign perf_events[10+16*t:15+16*t] = 6'd0;

         tri_event_mux1t #(.EVENTS_IN(16),.EVENTS_OUT(4)) perf_mux (
            .unit_events_in(perf_events[1+16*t:15+16*t]),
            .select_bits(xesr1_q[32+16*t:47+16*t]),
            .event_bus_out(perf_event_bus_d[0+4*t:3+4*t]),
            .event_bus_in(xu_event_bus_in[0+4*t:3+4*t]),
            .vd(vdd),.gd(gnd));

      end
   end
   endgenerate
   assign xu_event_bus_out  = perf_event_bus_q;
   assign spr_xesr1         = xesr1_q;
   assign spr_xesr2         = xesr2_q;
   assign perf_event_en     = perf_event_en_q;

   // SPR Input Control
   // CIR
   assign cir_act          = 1'b0;

   // CCR0
   // CCR0[PME]
   assign ccr0_act         = ex3_ccr0_we;
   assign ccr0_d           = ex3_ccr0_di;

   // CCR0[WE]
   // Generate Bit Mask
   assign ccr0_wen         = ex3_spr_wd[56-`THREADS:55] & {`THREADS{ex3_ccr0_we}};
   // Apply bit-Mask
   assign ccr0_we_di       = (ex3_spr_wd[64-`THREADS:63] & ccr0_wen[0:`THREADS-1]) | (ccr0_we_q[0:`THREADS-1] & (~ccr0_wen[0:`THREADS-1]));
   // Update based upon wake-up
   assign ccr0_we_d        = (ccr0_we_di[0:`THREADS-1] | reverse_threads(ex3_wait[0:`THREADS-1])) & ~(reverse_threads(pm_wake_up[0:`THREADS-1]));
   // Padded version
   assign ccr0_we          = {{4-`THREADS{1'b0}},ccr0_we_q};


   // CCR1
   assign ccr1_act         = ex3_ccr1_we;
   assign ccr1_d           = ex3_ccr1_di;

   // CCR2
   assign ccr2_act         = ex3_ccr2_we;
   assign ccr2_d           = ex3_ccr2_di;

   // CCR4
   assign ccr4_act         = ex3_ccr4_we;
   assign ccr4_d           = ex3_ccr4_di;

   // PIR
   assign pir_act          = 1'b1;

   // PVR
   assign pvr_act          = 1'b1;

   assign version          = {8'h00, spr_pvr_version_dc[8:15]};
   assign revision         = {4'h0, spr_pvr_revision_dc[12:15], 4'h0, spr_pvr_revision_minor_dc[16:19]};

   // TB
   assign tb_update_pulse  = (tb_update_pulse_q ^ tb_update_pulse_1_q);		// Any Edge

   // Update on external signal selected by XUCR0[TCS]
   assign timer_div_act    = tb_update_enable_q & (tb_update_pulse | (~spr_xucr0_tcs));

   assign timer_div_d      = timer_div_q + 5'd1;

   assign timer_div        = (timer_div_q ^ timer_div_d) & {5{timer_div_act}};

   // Select timer clock divide

   assign timer_update_int = (spr_xucr4_tcd == 2'b00) ? timer_div[4] :
                             (spr_xucr4_tcd == 2'b01) ? timer_div[2] :
                             (spr_xucr4_tcd == 2'b10) ? timer_div[1] :
                             timer_div[0];
   assign timer_update     = timer_update_q;

   // Not Stopped via HW DBG (if enabled)
   assign tb_act_d         = ~tb_dbg_dis_q & ~|tspr_cspr_freeze_timers & timer_update_int;		// Timers not frozen due to debug event

   assign tb_act           = tb_act_q;
   assign tb_q             = {tbu_q, tbl_q};
   assign tb               = tb_q + 1;

   // TBL
   assign tbl_act          = tb_act | ex3_tbl_we;
   assign tbl_d            = (ex3_tbl_we == 1'b1) ? ex3_tbl_di : tb[32:63];

   // TBU
   assign tbu_act          = tb_act | ex3_tbu_we;
   assign tbu_d            = (ex3_tbu_we == 1'b1) ? ex3_tbu_di : tb[0:31];

   // TENC
   assign tenc_act         = 1'b1;

   // TENS
   assign tens_act         = ex3_tenc_we | ex3_tens_we;
   assign tens_d           = (ex3_tenc_we == 1'b1) ? (tens_q & ~ex3_tens_di) : (tens_q | ex3_tens_di);

   // TENSR
   assign tensr_act        = 1'b1;

   // TIR
   assign tir_act          = 1'b1;

   // XESR1
   assign xesr1_act        = ex3_xesr1_we;
   assign xesr1_d          = ex3_xesr1_di;

   // XESR2
   assign xesr2_act        = ex3_xesr2_we;
   assign xesr2_d          = ex3_xesr2_di;

   // XUCR0
   assign set_xucr0_cslc_d    = lq_xu_spr_xucr0_cslc_xuop | lq_xu_spr_xucr0_cslc_binv;
   assign set_xucr0_cul_d     = lq_xu_spr_xucr0_cul;
   assign set_xucr0_clo_d     = lq_xu_spr_xucr0_clo;

   assign xucr0_act        = ex3_xucr0_we | set_xucr0_cslc_q | set_xucr0_cul_q | set_xucr0_clo_q;

   assign xucr0_d          = {xucr0_di[38:60],
                             (xucr0_di[61] | set_xucr0_cslc_q),
                             (xucr0_di[62] | set_xucr0_cul_q),
                             (xucr0_di[63] | set_xucr0_clo_q)};

   assign xucr0_di         = (ex3_xucr0_we == 1'b1) ? ex3_xucr0_di : xucr0_q;

   // XUCR4
   assign xucr4_act        = ex3_xucr4_we;
   assign xucr4_d          = ex3_xucr4_di;

   // IO signal assignments

   //        FIT   LL    WDOG
   assign cspr_tspr_timebase_taps[8] = tbl_q[32 + 23];	//  9           x
   assign cspr_tspr_timebase_taps[7] = tbl_q[32 + 11];	// 21           x
   assign cspr_tspr_timebase_taps[6] = tbl_q[32 + 7];		// 25           x
   assign cspr_tspr_timebase_taps[5] = tbl_q[32 + 21];	// 11     x     x
   assign cspr_tspr_timebase_taps[4] = tbl_q[32 + 17];	// 15     x     x
   assign cspr_tspr_timebase_taps[3] = tbl_q[32 + 13];	// 19     x     x     x
   assign cspr_tspr_timebase_taps[2] = tbl_q[32 + 9];		// 23     x     x     x
   assign cspr_tspr_timebase_taps[1] = tbl_q[32 + 5];		// 27           x     x
   assign cspr_tspr_timebase_taps[0] = tbl_q[32 + 1];		// 31                 x
   assign cspr_tspr_timebase_taps[9] = tbl_q[32 + 7];		// 29                 x   -- Replaced 1 for wdog

   assign cspr_tspr_ex2_tid      = ex2_tid;
   assign cspr_tspr_ex1_instr    = ex1_instr_q;
   assign cspr_tspr_dec_dbg_dis  = dec_dbg_dis_q;

   assign reset_wd_complete      = pc_xu_reset_wd_complete_q;
   assign reset_3_complete       = pc_xu_reset_3_complete_q;
   assign reset_2_complete       = pc_xu_reset_2_complete_q;
   assign reset_1_complete       = pc_xu_reset_1_complete_q;

   assign ex1_aspr_tid_d         = ex0_tid;

   assign cspr_aspr_ex3_we       = (ex3_spr_we & ex3_aspr_we_q) | |ex5_sprg_ce_q;
   assign cspr_aspr_ex3_waddr    = {ex3_aspr_addr_q, ex3_tid_q};
   assign cspr_aspr_ex1_re       = ex1_aspr_re[1] & ex1_aspr_act_q;
   assign cspr_aspr_ex1_raddr    = {ex1_aspr_addr, ex1_aspr_tid_q};

   assign xu_slowspr_val_out     = ex4_sspr_val_q;
   assign xu_slowspr_rw_out      = (~ex3_is_mtspr_q);
   assign xu_slowspr_etid_out    = ex3_tid_q;
   assign xu_slowspr_addr_out    = {ex3_instr_q[16:20], ex3_instr_q[11:15]};
   assign xu_slowspr_data_out    = ex3_spr_wd[64 - `GPR_WIDTH:63];

   assign ac_an_dcr_act          = 1'b0;
   assign ac_an_dcr_val          = 1'b0;
   assign ac_an_dcr_read         = 1'b0;
   assign ac_an_dcr_user         = 1'b0;
   assign ac_an_dcr_etid         = {2{1'b0}};
   assign ac_an_dcr_addr         = {10{1'b0}};
   assign ac_an_dcr_data         = {`GPR_WIDTH{1'b0}};

   assign spr_dec_ex4_spr_hypv   = ex4_hypv_spr_q;
   assign spr_dec_ex4_spr_illeg  = ex4_illeg_spr_q;
   assign spr_dec_ex4_spr_priv   = ex4_priv_spr_q;
   assign spr_dec_ex4_np1_flush  = ex4_np1_flush_q | ex4_wait_flush_q | (|ex4_sprg_ue);

   assign dbell_pir_match        = (lq_xu_dbell_pirtag_q[50:61] == pir_do[51:62]);

   assign cspr_tspr_dbell_pirtag = lq_xu_dbell_pirtag_q;

   generate
      begin : dbell
         genvar                                t;
         for (t=0;t<=`THREADS-1;t=t+1)
         begin : thread
            wire [0:1] tid = t;

            assign dbell_pir_thread[t] = lq_xu_dbell_pirtag_q[62:63] == tid;

            assign set_dbell[t]        = lq_xu_dbell_val_q & lq_xu_dbell_type_q == 5'b00000 & lq_xu_dbell_lpid_match_q & (lq_xu_dbell_brdcast_q | (dbell_pir_match & dbell_pir_thread[t]));
            assign set_cdbell[t]       = lq_xu_dbell_val_q & lq_xu_dbell_type_q == 5'b00001 & lq_xu_dbell_lpid_match_q & (lq_xu_dbell_brdcast_q | (dbell_pir_match & dbell_pir_thread[t]));
            assign set_gdbell[t]       = lq_xu_dbell_val_q & lq_xu_dbell_type_q == 5'b00010 & lq_xu_dbell_lpid_match_q & (lq_xu_dbell_brdcast_q | tspr_cspr_gpir_match[t]);
            assign set_gcdbell[t]      = lq_xu_dbell_val_q & lq_xu_dbell_type_q == 5'b00011 & lq_xu_dbell_lpid_match_q & (lq_xu_dbell_brdcast_q | tspr_cspr_gpir_match[t]);
            assign set_gmcdbell[t]     = lq_xu_dbell_val_q & lq_xu_dbell_type_q == 5'b00100 & lq_xu_dbell_lpid_match_q & (lq_xu_dbell_brdcast_q | tspr_cspr_gpir_match[t]);

            assign clr_dbell[t]        = ex3_spr_we & ex3_tid[t] & ex3_is_msgclr_q & (ex3_spr_wd[32:36] == 5'b00000);
            assign clr_cdbell[t]       = ex3_spr_we & ex3_tid[t] & ex3_is_msgclr_q & (ex3_spr_wd[32:36] == 5'b00001);
            assign clr_gdbell[t]       = ex3_spr_we & ex3_tid[t] & ex3_is_msgclr_q & (ex3_spr_wd[32:36] == 5'b00010);
            assign clr_gcdbell[t]      = ex3_spr_we & ex3_tid[t] & ex3_is_msgclr_q & (ex3_spr_wd[32:36] == 5'b00011);
            assign clr_gmcdbell[t]     = ex3_spr_we & ex3_tid[t] & ex3_is_msgclr_q & (ex3_spr_wd[32:36] == 5'b00100);
         end
      end
   endgenerate

   assign dbell_present_d     = set_dbell    | (dbell_present_q      & ~(clr_dbell     | cpl_dbell_taken_q));
   assign cdbell_present_d    = set_cdbell   | (cdbell_present_q     & ~(clr_cdbell    | cpl_cdbell_taken_q));
   assign gdbell_present_d    = set_gdbell   | (gdbell_present_q     & ~(clr_gdbell    | cpl_gdbell_taken_q));
   assign gcdbell_present_d   = set_gcdbell  | (gcdbell_present_q    & ~(clr_gcdbell   | cpl_gcdbell_taken_q));
   assign gmcdbell_present_d  = set_gmcdbell | (gmcdbell_present_q   & ~(clr_gmcdbell  | cpl_gmcdbell_taken_q));

   assign dbell_interrupt     = dbell_present_q       & base_mask & (tspr_msr_ee | tspr_msr_gs);
   assign cdbell_interrupt    = cdbell_present_q      & crit_mask & (tspr_msr_ce | tspr_msr_gs);
   assign gdbell_interrupt    = gdbell_present_q      & base_mask &  tspr_msr_ee & tspr_msr_gs;
   assign gcdbell_interrupt   = gcdbell_present_q     & crit_mask &  tspr_msr_ce & tspr_msr_gs;
   assign gmcdbell_interrupt  = gmcdbell_present_q    & crit_mask &  tspr_msr_me & tspr_msr_gs;

   assign xu_iu_dbell_interrupt     = ~{`THREADS{power_savings_on_q}} & dbell_interrupt_q;
   assign xu_iu_cdbell_interrupt    = ~{`THREADS{power_savings_on_q}} & cdbell_interrupt_q;
   assign xu_iu_gdbell_interrupt    = ~{`THREADS{power_savings_on_q}} & gdbell_interrupt_q;
   assign xu_iu_gcdbell_interrupt   = ~{`THREADS{power_savings_on_q}} & gcdbell_interrupt_q;
   assign xu_iu_gmcdbell_interrupt  = ~{`THREADS{power_savings_on_q}} & gmcdbell_interrupt_q;

   // Debug
   assign cspr_debug0 = {40{1'b0}};
   assign cspr_debug1 = {64{1'b0}};

   // Array ECC Check

   assign ex3_aspr_rdata_d[64-`GPR_WIDTH]                      = aspr_cspr_ex2_rdata[64-`GPR_WIDTH];
   assign ex3_aspr_rdata_d[65-`GPR_WIDTH:72-(64/`GPR_WIDTH)]   = aspr_cspr_ex2_rdata[65-`GPR_WIDTH:72-(64/`GPR_WIDTH)];

   assign ex3_eccchk_syn_b    = ~ex3_eccchk_syn;


   tri_eccgen #(.REGSIZE(`GPR_WIDTH)) xu_spr_rd_eccgen(
      .din(ex3_aspr_rdata_q),
      .syn(ex3_eccchk_syn)
   );


   tri_eccchk #(.REGSIZE(`GPR_WIDTH)) xu_spr_eccchk(
      .din(ex3_aspr_rdata_q[64-`GPR_WIDTH:63]),
      .encorr(encorr),
      .nsyn(ex3_eccchk_syn_b),
      .corrd(ex3_corr_rdata),
      .sbe(ex3_sprg_ce),
      .ue(ex3_sprg_ue)
   );

   assign encorr = 1'b1;

   assign xu_iu_ex3_sprg_ce = 1'b0;
   assign xu_iu_ex3_sprg_ue = 1'b0;


   assign ex4_sprg_ue_d    =                 (|ex3_val_rd_q & |ex3_aspr_re_q & ex3_sprg_ue);

   assign ex4_sprg_ce_d    = {`GPR_WIDTH/8+1{(|ex3_val_rd_q & |ex3_aspr_re_q & ex3_sprg_ce)}};


   tri_direct_err_rpt #(.WIDTH(`THREADS)) xu_spr_cspr_ce_err_rpt(
      .vd(vdd),
      .gd(gnd),
      .err_in(ex5_sprg_ce_q),
      .err_out(xu_pc_err_sprg_ecc)
   );

   tri_direct_err_rpt #(.WIDTH(`THREADS)) xu_spr_cspr_ue_err_rpt(
      .vd(vdd),
      .gd(gnd),
      .err_in(ex5_sprg_ue_q),
      .err_out(xu_pc_err_sprg_ue)
   );

   assign ex4_aspr_rt[32:63] = ex4_corr_rdata_q[32:63] & {32{ex4_aspr_re_q[1]}};
   generate
      if (`GPR_WIDTH > 32)
      begin : aspr_rt
         assign ex4_aspr_rt[64-`GPR_WIDTH:31] = ex4_corr_rdata_q[64-`GPR_WIDTH:31] & {`GPR_WIDTH-32{ex4_aspr_re_q[0]}};
      end
   endgenerate

   `ifdef THREADS1
      assign ex3_tspr_rt = tspr_cspr_ex3_tspr_rt;
   `else
      assign ex3_tspr_rt = tspr_cspr_ex3_tspr_rt[0:`GPR_WIDTH-1] | tspr_cspr_ex3_tspr_rt[`GPR_WIDTH:2*`GPR_WIDTH-1];
   `endif

   assign ex3_cspr_rt         = ex3_cspr_rt_q & {`GPR_WIDTH{(~((ex3_sspr_wr_val_q | ex3_sspr_rd_val_q)))}};

   assign ex3_spr_rt          = ex3_tspr_rt | ex3_cspr_rt;

   assign spr_xu_ex4_rd_data  = ex4_spr_rt_q | ex4_aspr_rt;

   // Fast SPR Read
   generate
      if (a2mode == 0 & hvmode == 0)
      begin : readmux_00
			assign ex2_cspr_rt =
			(ccr0_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr0_re            }}) |
			(ccr1_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr1_re            }}) |
			(ccr2_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr2_re            }}) |
			(ccr4_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr4_re            }}) |
			(cir_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_cir_re             }}) |
			(pir_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_pir_re             }}) |
			(pvr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_pvr_re             }}) |
			(tb_do[65-`GPR_WIDTH:64]              & {`GPR_WIDTH{ex2_tb_re              }}) |
			(tbu_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_tbu_re             }}) |
			(tenc_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_tenc_re            }}) |
			(tens_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_tens_re            }}) |
			(tensr_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_tensr_re           }}) |
			(tir_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_tir_re             }}) |
			(xesr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xesr1_re           }}) |
			(xesr2_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xesr2_re           }}) |
			(xucr0_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xucr0_re           }}) |
			(xucr4_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xucr4_re           }});
      end
   endgenerate
   generate
      if (a2mode == 0 & hvmode == 1)
      begin : readmux_01
			assign ex2_cspr_rt =
			(ccr0_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr0_re            }}) |
			(ccr1_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr1_re            }}) |
			(ccr2_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr2_re            }}) |
			(ccr4_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr4_re            }}) |
			(cir_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_cir_re             }}) |
			(pir_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_pir_re             }}) |
			(pvr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_pvr_re             }}) |
			(tb_do[65-`GPR_WIDTH:64]              & {`GPR_WIDTH{ex2_tb_re              }}) |
			(tbu_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_tbu_re             }}) |
			(tenc_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_tenc_re            }}) |
			(tens_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_tens_re            }}) |
			(tensr_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_tensr_re           }}) |
			(tir_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_tir_re             }}) |
			(xesr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xesr1_re           }}) |
			(xesr2_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xesr2_re           }}) |
			(xucr0_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xucr0_re           }}) |
			(xucr4_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xucr4_re           }});
      end
   endgenerate
   generate
      if (a2mode == 1 & hvmode == 0)
      begin : readmux_10
			assign ex2_cspr_rt =
			(ccr0_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr0_re            }}) |
			(ccr1_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr1_re            }}) |
			(ccr2_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr2_re            }}) |
			(ccr4_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr4_re            }}) |
			(cir_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_cir_re             }}) |
			(pir_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_pir_re             }}) |
			(pvr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_pvr_re             }}) |
			(tb_do[65-`GPR_WIDTH:64]              & {`GPR_WIDTH{ex2_tb_re              }}) |
			(tbu_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_tbu_re             }}) |
			(tenc_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_tenc_re            }}) |
			(tens_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_tens_re            }}) |
			(tensr_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_tensr_re           }}) |
			(tir_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_tir_re             }}) |
			(xesr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xesr1_re           }}) |
			(xesr2_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xesr2_re           }}) |
			(xucr0_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xucr0_re           }}) |
			(xucr4_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xucr4_re           }});
      end
   endgenerate
   generate
      if (a2mode == 1 & hvmode == 1)
      begin : readmux_11
			assign ex2_cspr_rt =
			(ccr0_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr0_re            }}) |
			(ccr1_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr1_re            }}) |
			(ccr2_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr2_re            }}) |
			(ccr4_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr4_re            }}) |
			(cir_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_cir_re             }}) |
			(pir_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_pir_re             }}) |
			(pvr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_pvr_re             }}) |
			(tb_do[65-`GPR_WIDTH:64]              & {`GPR_WIDTH{ex2_tb_re              }}) |
			(tbu_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_tbu_re             }}) |
			(tenc_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_tenc_re            }}) |
			(tens_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_tens_re            }}) |
			(tensr_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_tensr_re           }}) |
			(tir_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_tir_re             }}) |
			(xesr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xesr1_re           }}) |
			(xesr2_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xesr2_re           }}) |
			(xucr0_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xucr0_re           }}) |
			(xucr4_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xucr4_re           }});
      end
   endgenerate

   // Fast SPR Write
	assign ex3_ccr0_wdec       = (ex3_instr[11:20] == 10'b1000011111);   // 1008
	assign ex3_ccr1_wdec       = (ex3_instr[11:20] == 10'b1000111111);   // 1009
	assign ex3_ccr2_wdec       = (ex3_instr[11:20] == 10'b1001011111);   // 1010
	assign ex3_ccr4_wdec       = (ex3_instr[11:20] == 10'b1011011010);   //  854
	assign ex3_tbl_wdec        = (ex3_instr[11:20] == 10'b1110001000);   //  284
	assign ex3_tbu_wdec        = ((ex3_instr[11:20] == 10'b1110101000));  //  285
	assign ex3_tenc_wdec       = (ex3_instr[11:20] == 10'b1011101101);   //  439
	assign ex3_tens_wdec       = (ex3_instr[11:20] == 10'b1011001101);   //  438
	assign ex3_xesr1_wdec      = (ex3_instr[11:20] == 10'b1011011100);   //  918
	assign ex3_xesr2_wdec      = (ex3_instr[11:20] == 10'b1011111100);   //  919
	assign ex3_xucr0_wdec      = (ex3_instr[11:20] == 10'b1011011111);   // 1014
	assign ex3_xucr4_wdec      = (ex3_instr[11:20] == 10'b1010111010);   //  853
	assign ex3_ccr0_we        = ex3_spr_we & ex3_is_mtspr &  ex3_ccr0_wdec;
	assign ex3_ccr1_we        = ex3_spr_we & ex3_is_mtspr &  ex3_ccr1_wdec;
	assign ex3_ccr2_we        = ex3_spr_we & ex3_is_mtspr &  ex3_ccr2_wdec;
	assign ex3_ccr4_we        = ex3_spr_we & ex3_is_mtspr &  ex3_ccr4_wdec;
	assign ex3_tbl_we         = ex3_spr_we & ex3_is_mtspr &  ex3_tbl_wdec;
	assign ex3_tbu_we         = ex3_spr_we & ex3_is_mtspr &  ex3_tbu_wdec;
	assign ex3_tenc_we        = ex3_spr_we & ex3_is_mtspr &  ex3_tenc_wdec;
	assign ex3_tens_we        = ex3_spr_we & ex3_is_mtspr &  ex3_tens_wdec;
	assign ex3_xesr1_we       = ex3_spr_we & ex3_is_mtspr &  ex3_xesr1_wdec;
	assign ex3_xesr2_we       = ex3_spr_we & ex3_is_mtspr &  ex3_xesr2_wdec;
	assign ex3_xucr0_we       = ex3_spr_we & ex3_is_mtspr &  ex3_xucr0_wdec;
	assign ex3_xucr4_we       = ex3_spr_we & ex3_is_mtspr &  ex3_xucr4_wdec;

   // Array Read
	assign ex1_gsprg0_rdec     = (ex1_instr[11:20] == 10'b1000001011);   //  368
	assign ex1_gsprg1_rdec     = (ex1_instr[11:20] == 10'b1000101011);   //  369
	assign ex1_gsprg2_rdec     = (ex1_instr[11:20] == 10'b1001001011);   //  370
	assign ex1_gsprg3_rdec     = (ex1_instr[11:20] == 10'b1001101011);   //  371
	assign ex1_sprg0_rdec      = (ex1_instr[11:20] == 10'b1000001000);   //  272
	assign ex1_sprg1_rdec      = (ex1_instr[11:20] == 10'b1000101000);   //  273
	assign ex1_sprg2_rdec      = (ex1_instr[11:20] == 10'b1001001000);   //  274
	assign ex1_sprg3_rdec      = ((ex1_instr[11:20] == 10'b1001101000) | //  275
                     (ex1_instr[11:20] == 10'b0001101000));  //  259
	assign ex1_sprg4_rdec      = ((ex1_instr[11:20] == 10'b1010001000) | //  276
                     (ex1_instr[11:20] == 10'b0010001000));  //  260
	assign ex1_sprg5_rdec      = ((ex1_instr[11:20] == 10'b1010101000) | //  277
                     (ex1_instr[11:20] == 10'b0010101000));  //  261
	assign ex1_sprg6_rdec      = ((ex1_instr[11:20] == 10'b1011001000) | //  278
                     (ex1_instr[11:20] == 10'b0011001000));  //  262
	assign ex1_sprg7_rdec      = ((ex1_instr[11:20] == 10'b1011101000) | //  279
                     (ex1_instr[11:20] == 10'b0011101000));  //  263
	assign ex1_sprg8_rdec      = (ex1_instr[11:20] == 10'b1110010010);   //  604
	assign ex1_vrsave_rdec     = (ex1_instr[11:20] == 10'b0000001000);   //  256
	assign ex1_gsprg0_re       = (ex1_gsprg0_rdec    | (ex1_sprg0_rdec  & ex1_msr_gs_q[0]));
	assign ex1_gsprg1_re       = (ex1_gsprg1_rdec    | (ex1_sprg1_rdec  & ex1_msr_gs_q[0]));
	assign ex1_gsprg2_re       = (ex1_gsprg2_rdec    | (ex1_sprg2_rdec  & ex1_msr_gs_q[0]));
	assign ex1_gsprg3_re       = (ex1_gsprg3_rdec    | (ex1_sprg3_rdec  & ex1_msr_gs_q[0]));
	assign ex1_sprg0_re        =  ex1_sprg0_rdec     & ~ex1_msr_gs_q[0];
	assign ex1_sprg1_re        =  ex1_sprg1_rdec     & ~ex1_msr_gs_q[0];
	assign ex1_sprg2_re        =  ex1_sprg2_rdec     & ~ex1_msr_gs_q[0];
	assign ex1_sprg3_re        =  ex1_sprg3_rdec     & ~ex1_msr_gs_q[0];
	assign ex1_sprg4_re        =  ex1_sprg4_rdec;
	assign ex1_sprg5_re        =  ex1_sprg5_rdec;
	assign ex1_sprg6_re        =  ex1_sprg6_rdec;
	assign ex1_sprg7_re        =  ex1_sprg7_rdec;
	assign ex1_sprg8_re        =  ex1_sprg8_rdec;
	assign ex1_vrsave_re       =  ex1_vrsave_rdec;

   assign ex1_aspr_re[1] = ex1_is_mfspr & (
                             ex1_gsprg0_re        | ex1_gsprg1_re        | ex1_gsprg2_re
                           | ex1_gsprg3_re        | ex1_sprg0_re         | ex1_sprg1_re
                           | ex1_sprg2_re         | ex1_sprg3_re         | ex1_sprg4_re
                           | ex1_sprg5_re         | ex1_sprg6_re         | ex1_sprg7_re
                           | ex1_sprg8_re         | ex1_vrsave_re        );

   generate
      if (`GPR_WIDTH > 32)
      begin : ex1_aspr_re0_gen
   assign ex1_aspr_re[0] = ex1_aspr_re[1] & ~(
                             ex1_vrsave_re        );
      end
   endgenerate

	assign ex1_aspr_addr	 =
		(4'b0000 & {4{ex1_gsprg0_re     }}) |
		(4'b0001 & {4{ex1_gsprg1_re     }}) |
		(4'b0010 & {4{ex1_gsprg2_re     }}) |
		(4'b0011 & {4{ex1_gsprg3_re     }}) |
		(4'b0100 & {4{ex1_sprg0_re      }}) |
		(4'b0101 & {4{ex1_sprg1_re      }}) |
		(4'b0110 & {4{ex1_sprg2_re      }}) |
		(4'b0111 & {4{ex1_sprg3_re      }}) |
		(4'b1000 & {4{ex1_sprg4_re      }}) |
		(4'b1001 & {4{ex1_sprg5_re      }}) |
		(4'b1010 & {4{ex1_sprg6_re      }}) |
		(4'b1011 & {4{ex1_sprg7_re      }}) |
		(4'b1100 & {4{ex1_sprg8_re      }}) |
		(4'b1101 & {4{ex1_vrsave_re     }});


   // Array Writes

   // Generate ECC
   assign ex2_inj_ecc = |(inj_sprg_ecc_q & ex2_tid) & ~ex4_sprg_ce_q[0];

   assign ex3_aspr_addr_d = (ex4_sprg_ce_q[`GPR_WIDTH/8] == 1'b1) ? ex4_aspr_ce_addr_q : ex2_aspr_addr;


   generate
      genvar                i;
      for (i=0; i<`GPR_WIDTH; i=i+1) begin : ex2_rt_gen
         assign ex2_rt[i] = (ex4_corr_rdata_q[i] &  ex4_sprg_ce_q[i % (`GPR_WIDTH/8)]) |
                            (xu_spr_ex2_rs1[i]   & ~ex4_sprg_ce_q[i % (`GPR_WIDTH/8)]) ;
      end
   endgenerate

   assign ex2_rt_inj[63] = ex2_rt[63] ^ ex2_inj_ecc;
   assign ex2_rt_inj[64-`GPR_WIDTH:62] = ex2_rt[64 - `GPR_WIDTH:62];

   assign ex2_eccgen_data = {ex2_rt, tidn[0:8 - (64/`GPR_WIDTH)]};


   tri_eccgen #(.REGSIZE(`GPR_WIDTH)) xu_spr_wr_eccgen(
      .din(ex2_eccgen_data),
      .syn(ex2_eccgen_syn)
   );

   assign ex2_is_mfsspr_b     = ~ex2_sspr_rd_val;

   assign ex2_aspr_addr_act   = exx_act_data[2] | ex4_sprg_ce_q[0];

   assign ex3_rt_act          = exx_act_data[2] | ex4_sprg_ce_q[0];
   assign ex3_rt_d            = {(ex2_rt_inj & {`GPR_WIDTH{ex2_is_mfsspr_b}}), ex2_eccgen_syn};

   assign ex4_sprg_ue         = ex4_val_q & {`THREADS{ex4_sprg_ue_q}};
   assign ex4_sprg_ce         = ex4_val_q & {`THREADS{ex4_sprg_ce_q[0]}};
   assign ex3_aspr_we_d       = |(ex2_val) & ex2_aspr_we;

   assign ex2_aspr_we = ex2_is_mtspr_q & (
                             ex2_gsprg0_we        | ex2_gsprg1_we        | ex2_gsprg2_we
                           | ex2_gsprg3_we        | ex2_sprg0_we         | ex2_sprg1_we
                           | ex2_sprg2_we         | ex2_sprg3_we         | ex2_sprg4_we
                           | ex2_sprg5_we         | ex2_sprg6_we         | ex2_sprg7_we
                           | ex2_sprg8_we         | ex2_vrsave_we        );

	assign ex2_gsprg0_wdec     = (ex2_instr[11:20] == 10'b1000001011);   //  368
	assign ex2_gsprg1_wdec     = (ex2_instr[11:20] == 10'b1000101011);   //  369
	assign ex2_gsprg2_wdec     = (ex2_instr[11:20] == 10'b1001001011);   //  370
	assign ex2_gsprg3_wdec     = (ex2_instr[11:20] == 10'b1001101011);   //  371
	assign ex2_sprg0_wdec      = (ex2_instr[11:20] == 10'b1000001000);   //  272
	assign ex2_sprg1_wdec      = (ex2_instr[11:20] == 10'b1000101000);   //  273
	assign ex2_sprg2_wdec      = (ex2_instr[11:20] == 10'b1001001000);   //  274
	assign ex2_sprg3_wdec      = ((ex2_instr[11:20] == 10'b1001101000));  //  275
	assign ex2_sprg4_wdec      = ((ex2_instr[11:20] == 10'b1010001000));  //  276
	assign ex2_sprg5_wdec      = ((ex2_instr[11:20] == 10'b1010101000));  //  277
	assign ex2_sprg6_wdec      = ((ex2_instr[11:20] == 10'b1011001000));  //  278
	assign ex2_sprg7_wdec      = ((ex2_instr[11:20] == 10'b1011101000));  //  279
	assign ex2_sprg8_wdec      = (ex2_instr[11:20] == 10'b1110010010);   //  604
	assign ex2_vrsave_wdec     = (ex2_instr[11:20] == 10'b0000001000);   //  256
	assign ex2_gsprg0_we       = (ex2_gsprg0_wdec    | (ex2_sprg0_wdec  & ex2_msr_gs_q[0]));
	assign ex2_gsprg1_we       = (ex2_gsprg1_wdec    | (ex2_sprg1_wdec  & ex2_msr_gs_q[0]));
	assign ex2_gsprg2_we       = (ex2_gsprg2_wdec    | (ex2_sprg2_wdec  & ex2_msr_gs_q[0]));
	assign ex2_gsprg3_we       = (ex2_gsprg3_wdec    | (ex2_sprg3_wdec  & ex2_msr_gs_q[0]));
	assign ex2_sprg0_we        =  ex2_sprg0_wdec     & ~ex2_msr_gs_q[0];
	assign ex2_sprg1_we        =  ex2_sprg1_wdec     & ~ex2_msr_gs_q[0];
	assign ex2_sprg2_we        =  ex2_sprg2_wdec     & ~ex2_msr_gs_q[0];
	assign ex2_sprg3_we        =  ex2_sprg3_wdec     & ~ex2_msr_gs_q[0];
	assign ex2_sprg4_we        =  ex2_sprg4_wdec;
	assign ex2_sprg5_we        =  ex2_sprg5_wdec;
	assign ex2_sprg6_we        =  ex2_sprg6_wdec;
	assign ex2_sprg7_we        =  ex2_sprg7_wdec;
	assign ex2_sprg8_we        =  ex2_sprg8_wdec;
	assign ex2_vrsave_we       =  ex2_vrsave_wdec;

	assign ex2_aspr_addr	 =
		(4'b0000 & {4{ex2_gsprg0_we     }}) |
		(4'b0001 & {4{ex2_gsprg1_we     }}) |
		(4'b0010 & {4{ex2_gsprg2_we     }}) |
		(4'b0011 & {4{ex2_gsprg3_we     }}) |
		(4'b0100 & {4{ex2_sprg0_we      }}) |
		(4'b0101 & {4{ex2_sprg1_we      }}) |
		(4'b0110 & {4{ex2_sprg2_we      }}) |
		(4'b0111 & {4{ex2_sprg3_we      }}) |
		(4'b1000 & {4{ex2_sprg4_we      }}) |
		(4'b1001 & {4{ex2_sprg5_we      }}) |
		(4'b1010 & {4{ex2_sprg6_we      }}) |
		(4'b1011 & {4{ex2_sprg7_we      }}) |
		(4'b1100 & {4{ex2_sprg8_we      }}) |
		(4'b1101 & {4{ex2_vrsave_we     }});

   // Slow SPR
	assign ex2_acop_rdec       = (ex2_instr[11:20] == 10'b1111100000);   //   31
	assign ex2_axucr0_rdec     = (ex2_instr[11:20] == 10'b1000011110);   //  976
	assign ex2_cpcr0_rdec      = (ex2_instr[11:20] == 10'b1000011001);   //  816
	assign ex2_cpcr1_rdec      = (ex2_instr[11:20] == 10'b1000111001);   //  817
	assign ex2_cpcr2_rdec      = (ex2_instr[11:20] == 10'b1001011001);   //  818
	assign ex2_cpcr3_rdec      = (ex2_instr[11:20] == 10'b1010011001);   //  820
	assign ex2_cpcr4_rdec      = (ex2_instr[11:20] == 10'b1010111001);   //  821
	assign ex2_cpcr5_rdec      = (ex2_instr[11:20] == 10'b1011011001);   //  822
	assign ex2_dac1_rdec       = (ex2_instr[11:20] == 10'b1110001001);   //  316
	assign ex2_dac2_rdec       = (ex2_instr[11:20] == 10'b1110101001);   //  317
	assign ex2_dac3_rdec       = (ex2_instr[11:20] == 10'b1000111010);   //  849
	assign ex2_dac4_rdec       = (ex2_instr[11:20] == 10'b1001011010);   //  850
	assign ex2_dbcr2_rdec      = (ex2_instr[11:20] == 10'b1011001001);   //  310
	assign ex2_dbcr3_rdec      = (ex2_instr[11:20] == 10'b1000011010);   //  848
	assign ex2_dscr_rdec       = (ex2_instr[11:20] == 10'b1000100000);   //   17
	assign ex2_dvc1_rdec       = (ex2_instr[11:20] == 10'b1111001001);   //  318
	assign ex2_dvc2_rdec       = (ex2_instr[11:20] == 10'b1111101001);   //  319
	assign ex2_eheir_rdec      = (ex2_instr[11:20] == 10'b1010000001);   //   52
	assign ex2_eplc_rdec       = (ex2_instr[11:20] == 10'b1001111101);   //  947
	assign ex2_epsc_rdec       = (ex2_instr[11:20] == 10'b1010011101);   //  948
	assign ex2_eptcfg_rdec     = (ex2_instr[11:20] == 10'b1111001010);   //  350
	assign ex2_givpr_rdec      = (ex2_instr[11:20] == 10'b1111101101);   //  447
	assign ex2_hacop_rdec      = (ex2_instr[11:20] == 10'b1111101010);   //  351
	assign ex2_iac1_rdec       = (ex2_instr[11:20] == 10'b1100001001);   //  312
	assign ex2_iac2_rdec       = (ex2_instr[11:20] == 10'b1100101001);   //  313
	assign ex2_iac3_rdec       = (ex2_instr[11:20] == 10'b1101001001);   //  314
	assign ex2_iac4_rdec       = (ex2_instr[11:20] == 10'b1101101001);   //  315
	assign ex2_immr_rdec       = (ex2_instr[11:20] == 10'b1000111011);   //  881
	assign ex2_imr_rdec        = (ex2_instr[11:20] == 10'b1000011011);   //  880
	assign ex2_iucr0_rdec      = (ex2_instr[11:20] == 10'b1001111111);   // 1011
	assign ex2_iucr1_rdec      = (ex2_instr[11:20] == 10'b1001111011);   //  883
	assign ex2_iucr2_rdec      = (ex2_instr[11:20] == 10'b1010011011);   //  884
	assign ex2_iudbg0_rdec     = (ex2_instr[11:20] == 10'b1100011011);   //  888
	assign ex2_iudbg1_rdec     = (ex2_instr[11:20] == 10'b1100111011);   //  889
	assign ex2_iudbg2_rdec     = (ex2_instr[11:20] == 10'b1101011011);   //  890
	assign ex2_iulfsr_rdec     = (ex2_instr[11:20] == 10'b1101111011);   //  891
	assign ex2_iullcr_rdec     = (ex2_instr[11:20] == 10'b1110011011);   //  892
	assign ex2_ivpr_rdec       = (ex2_instr[11:20] == 10'b1111100001);   //   63
	assign ex2_lesr1_rdec      = (ex2_instr[11:20] == 10'b1100011100);   //  920
	assign ex2_lesr2_rdec      = (ex2_instr[11:20] == 10'b1100111100);   //  921
	assign ex2_lper_rdec       = (ex2_instr[11:20] == 10'b1100000001);   //   56
	assign ex2_lperu_rdec      = (ex2_instr[11:20] == 10'b1100100001);   //   57
	assign ex2_lpidr_rdec      = (ex2_instr[11:20] == 10'b1001001010);   //  338
	assign ex2_lratcfg_rdec    = (ex2_instr[11:20] == 10'b1011001010);   //  342
	assign ex2_lratps_rdec     = (ex2_instr[11:20] == 10'b1011101010);   //  343
	assign ex2_lsucr0_rdec     = (ex2_instr[11:20] == 10'b1001111001);   //  819
	assign ex2_mas0_rdec       = (ex2_instr[11:20] == 10'b1000010011);   //  624
	assign ex2_mas0_mas1_rdec  = (ex2_instr[11:20] == 10'b1010101011);   //  373
	assign ex2_mas1_rdec       = (ex2_instr[11:20] == 10'b1000110011);   //  625
	assign ex2_mas2_rdec       = (ex2_instr[11:20] == 10'b1001010011);   //  626
	assign ex2_mas2u_rdec      = (ex2_instr[11:20] == 10'b1011110011);   //  631
	assign ex2_mas3_rdec       = (ex2_instr[11:20] == 10'b1001110011);   //  627
	assign ex2_mas4_rdec       = (ex2_instr[11:20] == 10'b1010010011);   //  628
	assign ex2_mas5_rdec       = (ex2_instr[11:20] == 10'b1001101010);   //  339
	assign ex2_mas5_mas6_rdec  = (ex2_instr[11:20] == 10'b1110001010);   //  348
	assign ex2_mas6_rdec       = (ex2_instr[11:20] == 10'b1011010011);   //  630
	assign ex2_mas7_rdec       = (ex2_instr[11:20] == 10'b1000011101);   //  944
	assign ex2_mas7_mas3_rdec  = (ex2_instr[11:20] == 10'b1010001011);   //  372
	assign ex2_mas8_rdec       = (ex2_instr[11:20] == 10'b1010101010);   //  341
	assign ex2_mas8_mas1_rdec  = (ex2_instr[11:20] == 10'b1110101010);   //  349
	assign ex2_mmucfg_rdec     = (ex2_instr[11:20] == 10'b1011111111);   // 1015
	assign ex2_mmucr0_rdec     = (ex2_instr[11:20] == 10'b1110011111);   // 1020
	assign ex2_mmucr1_rdec     = (ex2_instr[11:20] == 10'b1110111111);   // 1021
	assign ex2_mmucr2_rdec     = (ex2_instr[11:20] == 10'b1111011111);   // 1022
	assign ex2_mmucr3_rdec     = (ex2_instr[11:20] == 10'b1111111111);   // 1023
	assign ex2_mmucsr0_rdec    = (ex2_instr[11:20] == 10'b1010011111);   // 1012
	assign ex2_pesr_rdec       = (ex2_instr[11:20] == 10'b1110111011);   //  893
	assign ex2_pid_rdec        = (ex2_instr[11:20] == 10'b1000000001);   //   48
	assign ex2_ppr32_rdec      = (ex2_instr[11:20] == 10'b0001011100);   //  898
	assign ex2_sramd_rdec      = (ex2_instr[11:20] == 10'b1111011011);   //  894
	assign ex2_tlb0cfg_rdec    = (ex2_instr[11:20] == 10'b1000010101);   //  688
	assign ex2_tlb0ps_rdec     = (ex2_instr[11:20] == 10'b1100001010);   //  344
	assign ex2_xucr2_rdec      = (ex2_instr[11:20] == 10'b1100011111);   // 1016
	assign ex2_xudbg0_rdec     = (ex2_instr[11:20] == 10'b1010111011);   //  885
	assign ex2_xudbg1_rdec     = (ex2_instr[11:20] == 10'b1011011011);   //  886
	assign ex2_xudbg2_rdec     = (ex2_instr[11:20] == 10'b1011111011);   //  887
	assign ex2_acop_re         =  ex2_acop_rdec;
	assign ex2_axucr0_re       =  ex2_axucr0_rdec;
	assign ex2_cpcr0_re        =  ex2_cpcr0_rdec;
	assign ex2_cpcr1_re        =  ex2_cpcr1_rdec;
	assign ex2_cpcr2_re        =  ex2_cpcr2_rdec;
	assign ex2_cpcr3_re        =  ex2_cpcr3_rdec;
	assign ex2_cpcr4_re        =  ex2_cpcr4_rdec;
	assign ex2_cpcr5_re        =  ex2_cpcr5_rdec;
	assign ex2_dac1_re         =  ex2_dac1_rdec;
	assign ex2_dac2_re         =  ex2_dac2_rdec;
	assign ex2_dac3_re         =  ex2_dac3_rdec;
	assign ex2_dac4_re         =  ex2_dac4_rdec;
	assign ex2_dbcr2_re        =  ex2_dbcr2_rdec;
	assign ex2_dbcr3_re        =  ex2_dbcr3_rdec;
	assign ex2_dscr_re         =  ex2_dscr_rdec;
	assign ex2_dvc1_re         =  ex2_dvc1_rdec;
	assign ex2_dvc2_re         =  ex2_dvc2_rdec;
	assign ex2_eheir_re        =  ex2_eheir_rdec;
	assign ex2_eplc_re         =  ex2_eplc_rdec;
	assign ex2_epsc_re         =  ex2_epsc_rdec;
	assign ex2_eptcfg_re       =  ex2_eptcfg_rdec;
	assign ex2_givpr_re        =  ex2_givpr_rdec;
	assign ex2_hacop_re        =  ex2_hacop_rdec;
	assign ex2_iac1_re         =  ex2_iac1_rdec;
	assign ex2_iac2_re         =  ex2_iac2_rdec;
	assign ex2_iac3_re         =  ex2_iac3_rdec;
	assign ex2_iac4_re         =  ex2_iac4_rdec;
	assign ex2_immr_re         =  ex2_immr_rdec;
	assign ex2_imr_re          =  ex2_imr_rdec;
	assign ex2_iucr0_re        =  ex2_iucr0_rdec;
	assign ex2_iucr1_re        =  ex2_iucr1_rdec;
	assign ex2_iucr2_re        =  ex2_iucr2_rdec;
	assign ex2_iudbg0_re       =  ex2_iudbg0_rdec;
	assign ex2_iudbg1_re       =  ex2_iudbg1_rdec;
	assign ex2_iudbg2_re       =  ex2_iudbg2_rdec;
	assign ex2_iulfsr_re       =  ex2_iulfsr_rdec;
	assign ex2_iullcr_re       =  ex2_iullcr_rdec;
	assign ex2_ivpr_re         =  ex2_ivpr_rdec;
	assign ex2_lesr1_re        =  ex2_lesr1_rdec;
	assign ex2_lesr2_re        =  ex2_lesr2_rdec;
	assign ex2_lper_re         =  ex2_lper_rdec;
	assign ex2_lperu_re        =  ex2_lperu_rdec;
	assign ex2_lpidr_re        =  ex2_lpidr_rdec;
	assign ex2_lratcfg_re      =  ex2_lratcfg_rdec;
	assign ex2_lratps_re       =  ex2_lratps_rdec;
	assign ex2_lsucr0_re       =  ex2_lsucr0_rdec;
	assign ex2_mas0_re         =  ex2_mas0_rdec;
	assign ex2_mas0_mas1_re    =  ex2_mas0_mas1_rdec;
	assign ex2_mas1_re         =  ex2_mas1_rdec;
	assign ex2_mas2_re         =  ex2_mas2_rdec;
	assign ex2_mas2u_re        =  ex2_mas2u_rdec;
	assign ex2_mas3_re         =  ex2_mas3_rdec;
	assign ex2_mas4_re         =  ex2_mas4_rdec;
	assign ex2_mas5_re         =  ex2_mas5_rdec;
	assign ex2_mas5_mas6_re    =  ex2_mas5_mas6_rdec;
	assign ex2_mas6_re         =  ex2_mas6_rdec;
	assign ex2_mas7_re         =  ex2_mas7_rdec;
	assign ex2_mas7_mas3_re    =  ex2_mas7_mas3_rdec;
	assign ex2_mas8_re         =  ex2_mas8_rdec;
	assign ex2_mas8_mas1_re    =  ex2_mas8_mas1_rdec;
	assign ex2_mmucfg_re       =  ex2_mmucfg_rdec;
	assign ex2_mmucr0_re       =  ex2_mmucr0_rdec;
	assign ex2_mmucr1_re       =  ex2_mmucr1_rdec;
	assign ex2_mmucr2_re       =  ex2_mmucr2_rdec;
	assign ex2_mmucr3_re       =  ex2_mmucr3_rdec;
	assign ex2_mmucsr0_re      =  ex2_mmucsr0_rdec;
	assign ex2_pesr_re         =  ex2_pesr_rdec;
	assign ex2_pid_re          =  ex2_pid_rdec;
	assign ex2_ppr32_re        =  ex2_ppr32_rdec;
	assign ex2_sramd_re        =  ex2_sramd_rdec;
	assign ex2_tlb0cfg_re      =  ex2_tlb0cfg_rdec;
	assign ex2_tlb0ps_re       =  ex2_tlb0ps_rdec;
	assign ex2_xucr2_re        =  ex2_xucr2_rdec;
	assign ex2_xudbg0_re       =  ex2_xudbg0_rdec;
	assign ex2_xudbg1_re       =  ex2_xudbg1_rdec;
	assign ex2_xudbg2_re       =  ex2_xudbg2_rdec;
	assign ex2_acop_wdec       = ex2_acop_rdec;
	assign ex2_axucr0_wdec     = ex2_axucr0_rdec;
	assign ex2_cpcr0_wdec      = ex2_cpcr0_rdec;
	assign ex2_cpcr1_wdec      = ex2_cpcr1_rdec;
	assign ex2_cpcr2_wdec      = ex2_cpcr2_rdec;
	assign ex2_cpcr3_wdec      = ex2_cpcr3_rdec;
	assign ex2_cpcr4_wdec      = ex2_cpcr4_rdec;
	assign ex2_cpcr5_wdec      = ex2_cpcr5_rdec;
	assign ex2_dac1_wdec       = ex2_dac1_rdec;
	assign ex2_dac2_wdec       = ex2_dac2_rdec;
	assign ex2_dac3_wdec       = ex2_dac3_rdec;
	assign ex2_dac4_wdec       = ex2_dac4_rdec;
	assign ex2_dbcr2_wdec      = ex2_dbcr2_rdec;
	assign ex2_dbcr3_wdec      = ex2_dbcr3_rdec;
	assign ex2_dscr_wdec       = ex2_dscr_rdec;
	assign ex2_dvc1_wdec       = ex2_dvc1_rdec;
	assign ex2_dvc2_wdec       = ex2_dvc2_rdec;
	assign ex2_eheir_wdec      = ex2_eheir_rdec;
	assign ex2_eplc_wdec       = ex2_eplc_rdec;
	assign ex2_epsc_wdec       = ex2_epsc_rdec;
	assign ex2_givpr_wdec      = (ex2_instr[11:20] == 10'b1111101101);   //  447
	assign ex2_hacop_wdec      = (ex2_instr[11:20] == 10'b1111101010);   //  351
	assign ex2_iac1_wdec       = ex2_iac1_rdec;
	assign ex2_iac2_wdec       = ex2_iac2_rdec;
	assign ex2_iac3_wdec       = ex2_iac3_rdec;
	assign ex2_iac4_wdec       = ex2_iac4_rdec;
	assign ex2_immr_wdec       = ex2_immr_rdec;
	assign ex2_imr_wdec        = ex2_imr_rdec;
	assign ex2_iucr0_wdec      = ex2_iucr0_rdec;
	assign ex2_iucr1_wdec      = ex2_iucr1_rdec;
	assign ex2_iucr2_wdec      = ex2_iucr2_rdec;
	assign ex2_iudbg0_wdec     = ex2_iudbg0_rdec;
	assign ex2_iulfsr_wdec     = ex2_iulfsr_rdec;
	assign ex2_iullcr_wdec     = ex2_iullcr_rdec;
	assign ex2_ivpr_wdec       = ex2_ivpr_rdec;
	assign ex2_lesr1_wdec      = ex2_lesr1_rdec;
	assign ex2_lesr2_wdec      = ex2_lesr2_rdec;
	assign ex2_lper_wdec       = ex2_lper_rdec;
	assign ex2_lperu_wdec      = ex2_lperu_rdec;
	assign ex2_lpidr_wdec      = ex2_lpidr_rdec;
	assign ex2_lsucr0_wdec     = ex2_lsucr0_rdec;
	assign ex2_mas0_wdec       = ex2_mas0_rdec;
	assign ex2_mas0_mas1_wdec  = ex2_mas0_mas1_rdec;
	assign ex2_mas1_wdec       = ex2_mas1_rdec;
	assign ex2_mas2_wdec       = ex2_mas2_rdec;
	assign ex2_mas2u_wdec      = ex2_mas2u_rdec;
	assign ex2_mas3_wdec       = ex2_mas3_rdec;
	assign ex2_mas4_wdec       = ex2_mas4_rdec;
	assign ex2_mas5_wdec       = ex2_mas5_rdec;
	assign ex2_mas5_mas6_wdec  = ex2_mas5_mas6_rdec;
	assign ex2_mas6_wdec       = ex2_mas6_rdec;
	assign ex2_mas7_wdec       = ex2_mas7_rdec;
	assign ex2_mas7_mas3_wdec  = ex2_mas7_mas3_rdec;
	assign ex2_mas8_wdec       = ex2_mas8_rdec;
	assign ex2_mas8_mas1_wdec  = ex2_mas8_mas1_rdec;
	assign ex2_mmucr0_wdec     = ex2_mmucr0_rdec;
	assign ex2_mmucr1_wdec     = ex2_mmucr1_rdec;
	assign ex2_mmucr2_wdec     = ex2_mmucr2_rdec;
	assign ex2_mmucr3_wdec     = ex2_mmucr3_rdec;
	assign ex2_mmucsr0_wdec    = ex2_mmucsr0_rdec;
	assign ex2_pesr_wdec       = ex2_pesr_rdec;
	assign ex2_pid_wdec        = ex2_pid_rdec;
	assign ex2_ppr32_wdec      = ex2_ppr32_rdec;
	assign ex2_xucr2_wdec      = ex2_xucr2_rdec;
	assign ex2_xudbg0_wdec     = ex2_xudbg0_rdec;
	assign ex2_acop_we         =  ex2_acop_wdec;
	assign ex2_axucr0_we       =  ex2_axucr0_wdec;
	assign ex2_cpcr0_we        =  ex2_cpcr0_wdec;
	assign ex2_cpcr1_we        =  ex2_cpcr1_wdec;
	assign ex2_cpcr2_we        =  ex2_cpcr2_wdec;
	assign ex2_cpcr3_we        =  ex2_cpcr3_wdec;
	assign ex2_cpcr4_we        =  ex2_cpcr4_wdec;
	assign ex2_cpcr5_we        =  ex2_cpcr5_wdec;
	assign ex2_dac1_we         =  ex2_dac1_wdec;
	assign ex2_dac2_we         =  ex2_dac2_wdec;
	assign ex2_dac3_we         =  ex2_dac3_wdec;
	assign ex2_dac4_we         =  ex2_dac4_wdec;
	assign ex2_dbcr2_we        =  ex2_dbcr2_wdec;
	assign ex2_dbcr3_we        =  ex2_dbcr3_wdec;
	assign ex2_dscr_we         =  ex2_dscr_wdec;
	assign ex2_dvc1_we         =  ex2_dvc1_wdec;
	assign ex2_dvc2_we         =  ex2_dvc2_wdec;
	assign ex2_eheir_we        =  ex2_eheir_wdec;
	assign ex2_eplc_we         =  ex2_eplc_wdec;
	assign ex2_epsc_we         =  ex2_epsc_wdec;
	assign ex2_givpr_we        =  ex2_givpr_wdec;
	assign ex2_hacop_we        =  ex2_hacop_wdec;
	assign ex2_iac1_we         =  ex2_iac1_wdec;
	assign ex2_iac2_we         =  ex2_iac2_wdec;
	assign ex2_iac3_we         =  ex2_iac3_wdec;
	assign ex2_iac4_we         =  ex2_iac4_wdec;
	assign ex2_immr_we         =  ex2_immr_wdec;
	assign ex2_imr_we          =  ex2_imr_wdec;
	assign ex2_iucr0_we        =  ex2_iucr0_wdec;
	assign ex2_iucr1_we        =  ex2_iucr1_wdec;
	assign ex2_iucr2_we        =  ex2_iucr2_wdec;
	assign ex2_iudbg0_we       =  ex2_iudbg0_wdec;
	assign ex2_iulfsr_we       =  ex2_iulfsr_wdec;
	assign ex2_iullcr_we       =  ex2_iullcr_wdec;
	assign ex2_ivpr_we         =  ex2_ivpr_wdec;
	assign ex2_lesr1_we        =  ex2_lesr1_wdec;
	assign ex2_lesr2_we        =  ex2_lesr2_wdec;
	assign ex2_lper_we         =  ex2_lper_wdec;
	assign ex2_lperu_we        =  ex2_lperu_wdec;
	assign ex2_lpidr_we        =  ex2_lpidr_wdec;
	assign ex2_lsucr0_we       =  ex2_lsucr0_wdec;
	assign ex2_mas0_we         =  ex2_mas0_wdec;
	assign ex2_mas0_mas1_we    =  ex2_mas0_mas1_wdec;
	assign ex2_mas1_we         =  ex2_mas1_wdec;
	assign ex2_mas2_we         =  ex2_mas2_wdec;
	assign ex2_mas2u_we        =  ex2_mas2u_wdec;
	assign ex2_mas3_we         =  ex2_mas3_wdec;
	assign ex2_mas4_we         =  ex2_mas4_wdec;
	assign ex2_mas5_we         =  ex2_mas5_wdec;
	assign ex2_mas5_mas6_we    =  ex2_mas5_mas6_wdec;
	assign ex2_mas6_we         =  ex2_mas6_wdec;
	assign ex2_mas7_we         =  ex2_mas7_wdec;
	assign ex2_mas7_mas3_we    =  ex2_mas7_mas3_wdec;
	assign ex2_mas8_we         =  ex2_mas8_wdec;
	assign ex2_mas8_mas1_we    =  ex2_mas8_mas1_wdec;
	assign ex2_mmucr0_we       =  ex2_mmucr0_wdec;
	assign ex2_mmucr1_we       =  ex2_mmucr1_wdec;
	assign ex2_mmucr2_we       =  ex2_mmucr2_wdec;
	assign ex2_mmucr3_we       =  ex2_mmucr3_wdec;
	assign ex2_mmucsr0_we      =  ex2_mmucsr0_wdec;
	assign ex2_pesr_we         =  ex2_pesr_wdec;
	assign ex2_pid_we          =  ex2_pid_wdec;
	assign ex2_ppr32_we        =  ex2_ppr32_wdec;
	assign ex2_xucr2_we        =  ex2_xucr2_wdec;
	assign ex2_xudbg0_we       =  ex2_xudbg0_wdec;
   assign ex2_slowspr_range_hypv = ex2_instr[11] & ex2_instr[16:20] == 5'b11110;		// 976-991
   assign ex2_slowspr_range_priv = ex2_instr[11] & ex2_instr[16:20] == 5'b11100 & (~(ex2_xesr1_rdec | ex2_xesr2_rdec));		// 912-927  except  918/919
   assign ex2_slowspr_range = ex2_slowspr_range_priv | ex2_slowspr_range_hypv;

   // mftb encode is only legal for tbr=268,269                        --  "0110-01000"
   assign ex2_illeg_mftb = ex2_is_mftb_q & (~(ex2_instr[11:14] == 4'b0110 & ex2_instr[16:20] == 5'b01000));

   assign ex2_sspr_wr_val = ex2_is_mtspr_q & (ex2_slowspr_range |
                             ex2_acop_we          | ex2_axucr0_we        | ex2_cpcr0_we
                           | ex2_cpcr1_we         | ex2_cpcr2_we         | ex2_cpcr3_we
                           | ex2_cpcr4_we         | ex2_cpcr5_we         | ex2_dac1_we
                           | ex2_dac2_we          | ex2_dac3_we          | ex2_dac4_we
                           | ex2_dbcr2_we         | ex2_dbcr3_we         | ex2_dscr_we
                           | ex2_dvc1_we          | ex2_dvc2_we          | ex2_eheir_we
                           | ex2_eplc_we          | ex2_epsc_we          | ex2_givpr_we
                           | ex2_hacop_we         | ex2_iac1_we          | ex2_iac2_we
                           | ex2_iac3_we          | ex2_iac4_we          | ex2_immr_we
                           | ex2_imr_we           | ex2_iucr0_we         | ex2_iucr1_we
                           | ex2_iucr2_we         | ex2_iudbg0_we        | ex2_iulfsr_we
                           | ex2_iullcr_we        | ex2_ivpr_we          | ex2_lesr1_we
                           | ex2_lesr2_we         | ex2_lper_we          | ex2_lperu_we
                           | ex2_lpidr_we         | ex2_lsucr0_we        | ex2_mas0_we
                           | ex2_mas0_mas1_we     | ex2_mas1_we          | ex2_mas2_we
                           | ex2_mas2u_we         | ex2_mas3_we          | ex2_mas4_we
                           | ex2_mas5_we          | ex2_mas5_mas6_we     | ex2_mas6_we
                           | ex2_mas7_we          | ex2_mas7_mas3_we     | ex2_mas8_we
                           | ex2_mas8_mas1_we     | ex2_mmucr0_we        | ex2_mmucr1_we
                           | ex2_mmucr2_we        | ex2_mmucr3_we        | ex2_mmucsr0_we
                           | ex2_pesr_we          | ex2_pid_we           | ex2_ppr32_we
                           | ex2_xucr2_we         | ex2_xudbg0_we        );

   assign ex2_sspr_rd_val = ex2_is_mfspr_q & (ex2_slowspr_range |
                             ex2_acop_re          | ex2_axucr0_re        | ex2_cpcr0_re
                           | ex2_cpcr1_re         | ex2_cpcr2_re         | ex2_cpcr3_re
                           | ex2_cpcr4_re         | ex2_cpcr5_re         | ex2_dac1_re
                           | ex2_dac2_re          | ex2_dac3_re          | ex2_dac4_re
                           | ex2_dbcr2_re         | ex2_dbcr3_re         | ex2_dscr_re
                           | ex2_dvc1_re          | ex2_dvc2_re          | ex2_eheir_re
                           | ex2_eplc_re          | ex2_epsc_re          | ex2_eptcfg_re
                           | ex2_givpr_re         | ex2_hacop_re         | ex2_iac1_re
                           | ex2_iac2_re          | ex2_iac3_re          | ex2_iac4_re
                           | ex2_immr_re          | ex2_imr_re           | ex2_iucr0_re
                           | ex2_iucr1_re         | ex2_iucr2_re         | ex2_iudbg0_re
                           | ex2_iudbg1_re        | ex2_iudbg2_re        | ex2_iulfsr_re
                           | ex2_iullcr_re        | ex2_ivpr_re          | ex2_lesr1_re
                           | ex2_lesr2_re         | ex2_lper_re          | ex2_lperu_re
                           | ex2_lpidr_re         | ex2_lratcfg_re       | ex2_lratps_re
                           | ex2_lsucr0_re        | ex2_mas0_re          | ex2_mas0_mas1_re
                           | ex2_mas1_re          | ex2_mas2_re          | ex2_mas2u_re
                           | ex2_mas3_re          | ex2_mas4_re          | ex2_mas5_re
                           | ex2_mas5_mas6_re     | ex2_mas6_re          | ex2_mas7_re
                           | ex2_mas7_mas3_re     | ex2_mas8_re          | ex2_mas8_mas1_re
                           | ex2_mmucfg_re        | ex2_mmucr0_re        | ex2_mmucr1_re
                           | ex2_mmucr2_re        | ex2_mmucr3_re        | ex2_mmucsr0_re
                           | ex2_pesr_re          | ex2_pid_re           | ex2_ppr32_re
                           | ex2_sramd_re         | ex2_tlb0cfg_re       | ex2_tlb0ps_re
                           | ex2_xucr2_re         | ex2_xudbg0_re        | ex2_xudbg1_re
                           | ex2_xudbg2_re        );

   // Illegal SPR checks
   assign ex2_sprg8_re = ex2_sprg8_rdec;
	assign ex2_gsprg0_rdec     = (ex2_instr[11:20] == 10'b1000001011);   //  368
	assign ex2_gsprg1_rdec     = (ex2_instr[11:20] == 10'b1000101011);   //  369
	assign ex2_gsprg2_rdec     = (ex2_instr[11:20] == 10'b1001001011);   //  370
	assign ex2_gsprg3_rdec     = (ex2_instr[11:20] == 10'b1001101011);   //  371
	assign ex2_sprg0_rdec      = (ex2_instr[11:20] == 10'b1000001000);   //  272
	assign ex2_sprg1_rdec      = (ex2_instr[11:20] == 10'b1000101000);   //  273
	assign ex2_sprg2_rdec      = (ex2_instr[11:20] == 10'b1001001000);   //  274
	assign ex2_sprg3_rdec      = ((ex2_instr[11:20] == 10'b1001101000) | //  275
                     (ex2_instr[11:20] == 10'b0001101000));  //  259
	assign ex2_sprg4_rdec      = ((ex2_instr[11:20] == 10'b1010001000) | //  276
                     (ex2_instr[11:20] == 10'b0010001000));  //  260
	assign ex2_sprg5_rdec      = ((ex2_instr[11:20] == 10'b1010101000) | //  277
                     (ex2_instr[11:20] == 10'b0010101000));  //  261
	assign ex2_sprg6_rdec      = ((ex2_instr[11:20] == 10'b1011001000) | //  278
                     (ex2_instr[11:20] == 10'b0011001000));  //  262
	assign ex2_sprg7_rdec      = ((ex2_instr[11:20] == 10'b1011101000) | //  279
                     (ex2_instr[11:20] == 10'b0011101000));  //  263
	assign ex2_sprg8_rdec      = (ex2_instr[11:20] == 10'b1110010010);   //  604
	assign ex2_vrsave_rdec     = (ex2_instr[11:20] == 10'b0000001000);   //  256
	assign ex2_ccr0_rdec       = (ex2_instr[11:20] == 10'b1000011111);   // 1008
	assign ex2_ccr1_rdec       = (ex2_instr[11:20] == 10'b1000111111);   // 1009
	assign ex2_ccr2_rdec       = (ex2_instr[11:20] == 10'b1001011111);   // 1010
	assign ex2_ccr4_rdec       = (ex2_instr[11:20] == 10'b1011011010);   //  854
	assign ex2_cir_rdec        = (ex2_instr[11:20] == 10'b1101101000);   //  283
	assign ex2_pir_rdec        = (ex2_instr[11:20] == 10'b1111001000);   //  286
	assign ex2_pvr_rdec        = (ex2_instr[11:20] == 10'b1111101000);   //  287
	assign ex2_tb_rdec         = (ex2_instr[11:20] == 10'b0110001000);   //  268
	assign ex2_tbu_rdec        = ((ex2_instr[11:20] == 10'b0110101000));  //  269
	assign ex2_tenc_rdec       = (ex2_instr[11:20] == 10'b1011101101);   //  439
	assign ex2_tens_rdec       = (ex2_instr[11:20] == 10'b1011001101);   //  438
	assign ex2_tensr_rdec      = (ex2_instr[11:20] == 10'b1010101101);   //  437
	assign ex2_tir_rdec        = (ex2_instr[11:20] == 10'b1111001101);   //  446
	assign ex2_xesr1_rdec      = (ex2_instr[11:20] == 10'b1011011100);   //  918
	assign ex2_xesr2_rdec      = (ex2_instr[11:20] == 10'b1011111100);   //  919
	assign ex2_xucr0_rdec      = (ex2_instr[11:20] == 10'b1011011111);   // 1014
	assign ex2_xucr4_rdec      = (ex2_instr[11:20] == 10'b1010111010);   //  853
	assign ex2_ccr0_re         =  ex2_ccr0_rdec;
	assign ex2_ccr1_re         =  ex2_ccr1_rdec;
	assign ex2_ccr2_re         =  ex2_ccr2_rdec;
	assign ex2_ccr4_re         =  ex2_ccr4_rdec;
	assign ex2_cir_re          =  ex2_cir_rdec;
	assign ex2_pir_re          =  ex2_pir_rdec       & ~ex2_msr_gs_q[0];
	assign ex2_pvr_re          =  ex2_pvr_rdec;
	assign ex2_tb_re           =  ex2_tb_rdec;
	assign ex2_tbu_re          =  ex2_tbu_rdec;
	assign ex2_tenc_re         =  ex2_tenc_rdec;
	assign ex2_tens_re         =  ex2_tens_rdec;
	assign ex2_tensr_re        =  ex2_tensr_rdec;
	assign ex2_tir_re          =  ex2_tir_rdec;
	assign ex2_xesr1_re        =  ex2_xesr1_rdec;
	assign ex2_xesr2_re        =  ex2_xesr2_rdec;
	assign ex2_xucr0_re        =  ex2_xucr0_rdec;
	assign ex2_xucr4_re        =  ex2_xucr4_rdec;
	assign ex2_ccr0_wdec       = ex2_ccr0_rdec;
	assign ex2_ccr1_wdec       = ex2_ccr1_rdec;
	assign ex2_ccr2_wdec       = ex2_ccr2_rdec;
	assign ex2_ccr4_wdec       = ex2_ccr4_rdec;
	assign ex2_tbl_wdec        = (ex2_instr[11:20] == 10'b1110001000);   //  284
	assign ex2_tbu_wdec        = ((ex2_instr[11:20] == 10'b1110101000));  //  285
	assign ex2_tenc_wdec       = ex2_tenc_rdec;
	assign ex2_tens_wdec       = ex2_tens_rdec;
	assign ex2_trace_wdec      = (ex2_instr[11:20] == 10'b0111011111);   // 1006
	assign ex2_xesr1_wdec      = ex2_xesr1_rdec;
	assign ex2_xesr2_wdec      = ex2_xesr2_rdec;
	assign ex2_xucr0_wdec      = ex2_xucr0_rdec;
	assign ex2_xucr4_wdec      = ex2_xucr4_rdec;
	assign ex2_ccr0_we         =  ex2_ccr0_wdec;
	assign ex2_ccr1_we         =  ex2_ccr1_wdec;
	assign ex2_ccr2_we         =  ex2_ccr2_wdec;
	assign ex2_ccr4_we         =  ex2_ccr4_wdec;
	assign ex2_tbl_we          =  ex2_tbl_wdec;
	assign ex2_tbu_we          =  ex2_tbu_wdec;
	assign ex2_tenc_we         =  ex2_tenc_wdec;
	assign ex2_tens_we         =  ex2_tens_wdec;
	assign ex2_trace_we        =  ex2_trace_wdec;
	assign ex2_xesr1_we        =  ex2_xesr1_wdec;
	assign ex2_xesr2_we        =  ex2_xesr2_wdec;
	assign ex2_xucr0_we        =  ex2_xucr0_wdec;
	assign ex2_xucr4_we        =  ex2_xucr4_wdec;

   generate
      if (a2mode == 0 & hvmode == 0)
      begin : ill_spr_00

         assign ex2_illeg_mfspr = ex2_is_mfspr_q & ~(
                             ex2_ccr0_rdec        | ex2_ccr1_rdec        | ex2_ccr2_rdec
                           | ex2_ccr4_rdec        | ex2_cir_rdec         | ex2_pir_rdec
                           | ex2_pvr_rdec         | ex2_tb_rdec          | ex2_tbu_rdec
                           | ex2_tenc_rdec        | ex2_tens_rdec        | ex2_tensr_rdec
                           | ex2_tir_rdec         | ex2_xesr1_rdec       | ex2_xesr2_rdec
                           | ex2_xucr0_rdec       | ex2_xucr4_rdec       |
                             ex2_sprg0_rdec       | ex2_sprg1_rdec       | ex2_sprg2_rdec
                           | ex2_sprg3_rdec       | ex2_sprg4_rdec       | ex2_sprg5_rdec
                           | ex2_sprg6_rdec       | ex2_sprg7_rdec       | ex2_sprg8_rdec
                           | ex2_vrsave_rdec      |
                             ex2_axucr0_rdec      | ex2_cpcr0_rdec       | ex2_cpcr1_rdec
                           | ex2_cpcr2_rdec       | ex2_cpcr3_rdec       | ex2_cpcr4_rdec
                           | ex2_cpcr5_rdec       | ex2_dac3_rdec        | ex2_dac4_rdec
                           | ex2_dbcr3_rdec       | ex2_dscr_rdec        | ex2_eheir_rdec
                           | ex2_iac1_rdec        | ex2_iac2_rdec        | ex2_iucr0_rdec
                           | ex2_iucr1_rdec       | ex2_iucr2_rdec       | ex2_iudbg0_rdec
                           | ex2_iudbg1_rdec      | ex2_iudbg2_rdec      | ex2_iulfsr_rdec
                           | ex2_iullcr_rdec      | ex2_ivpr_rdec        | ex2_lesr1_rdec
                           | ex2_lesr2_rdec       | ex2_lpidr_rdec       | ex2_lsucr0_rdec
                           | ex2_pesr_rdec        | ex2_pid_rdec         | ex2_ppr32_rdec
                           | ex2_sramd_rdec       | ex2_xucr2_rdec       | ex2_xudbg0_rdec
                           | ex2_xudbg1_rdec      | ex2_xudbg2_rdec      |
                           ex2_slowspr_range |
                        |(tspr_cspr_illeg_mfspr_b & ex2_tid));

         assign ex2_illeg_mtspr = ex2_is_mtspr_q & ~(
                             ex2_ccr0_wdec        | ex2_ccr1_wdec        | ex2_ccr2_wdec
                           | ex2_ccr4_wdec        | ex2_tbl_wdec         | ex2_tbu_wdec
                           | ex2_tenc_wdec        | ex2_tens_wdec        | ex2_trace_wdec
                           | ex2_xesr1_wdec       | ex2_xesr2_wdec       | ex2_xucr0_wdec
                           | ex2_xucr4_wdec       |
                             ex2_sprg0_wdec       | ex2_sprg1_wdec       | ex2_sprg2_wdec
                           | ex2_sprg3_wdec       | ex2_sprg4_wdec       | ex2_sprg5_wdec
                           | ex2_sprg6_wdec       | ex2_sprg7_wdec       | ex2_sprg8_wdec
                           | ex2_vrsave_wdec      |
                             ex2_axucr0_wdec      | ex2_cpcr0_wdec       | ex2_cpcr1_wdec
                           | ex2_cpcr2_wdec       | ex2_cpcr3_wdec       | ex2_cpcr4_wdec
                           | ex2_cpcr5_wdec       | ex2_dac3_wdec        | ex2_dac4_wdec
                           | ex2_dbcr3_wdec       | ex2_dscr_wdec        | ex2_eheir_wdec
                           | ex2_iac1_wdec        | ex2_iac2_wdec        | ex2_iucr0_wdec
                           | ex2_iucr1_wdec       | ex2_iucr2_wdec       | ex2_iudbg0_wdec
                           | ex2_iulfsr_wdec      | ex2_iullcr_wdec      | ex2_ivpr_wdec
                           | ex2_lesr1_wdec       | ex2_lesr2_wdec       | ex2_lpidr_wdec
                           | ex2_lsucr0_wdec      | ex2_pesr_wdec        | ex2_pid_wdec
                           | ex2_ppr32_wdec       | ex2_xucr2_wdec       | ex2_xudbg0_wdec      |
                           ex2_slowspr_range |
                        |(tspr_cspr_illeg_mtspr_b & ex2_tid));

         assign ex2_hypv_mfspr = ex2_is_mfspr_q & (
                             ex2_ccr0_re          | ex2_ccr1_re          | ex2_ccr2_re
                           | ex2_ccr4_re          | ex2_tenc_re          | ex2_tens_re
                           | ex2_tensr_re         | ex2_tir_re           | ex2_xucr0_re
                           | ex2_xucr4_re         |
                             ex2_sprg8_re         |
                             ex2_axucr0_re        | ex2_cpcr0_re         | ex2_cpcr1_re
                           | ex2_cpcr2_re         | ex2_cpcr3_re         | ex2_cpcr4_re
                           | ex2_cpcr5_re         | ex2_dac3_re          | ex2_dac4_re
                           | ex2_dbcr3_re         | ex2_eheir_re         | ex2_iac1_re
                           | ex2_iac2_re          | ex2_iucr0_re         | ex2_iucr1_re
                           | ex2_iucr2_re         | ex2_iudbg0_re        | ex2_iudbg1_re
                           | ex2_iudbg2_re        | ex2_iulfsr_re        | ex2_iullcr_re
                           | ex2_ivpr_re          | ex2_lpidr_re         | ex2_lsucr0_re
                           | ex2_xucr2_re         | ex2_xudbg0_re        | ex2_xudbg1_re
                           | ex2_xudbg2_re        |
                           ex2_slowspr_range_hypv |
                        |(tspr_cspr_hypv_mfspr & ex2_tid));

         assign ex2_hypv_mtspr = ex2_is_mtspr_q & (
                             ex2_ccr0_we          | ex2_ccr1_we          | ex2_ccr2_we
                           | ex2_ccr4_we          | ex2_tbl_we           | ex2_tbu_we
                           | ex2_tenc_we          | ex2_tens_we          | ex2_xucr0_we
                           | ex2_xucr4_we         |
                             ex2_sprg8_we         |
                             ex2_axucr0_we        | ex2_cpcr0_we         | ex2_cpcr1_we
                           | ex2_cpcr2_we         | ex2_cpcr3_we         | ex2_cpcr4_we
                           | ex2_cpcr5_we         | ex2_dac3_we          | ex2_dac4_we
                           | ex2_dbcr3_we         | ex2_eheir_we         | ex2_iac1_we
                           | ex2_iac2_we          | ex2_iucr0_we         | ex2_iucr1_we
                           | ex2_iucr2_we         | ex2_iudbg0_we        | ex2_iulfsr_we
                           | ex2_iullcr_we        | ex2_ivpr_we          | ex2_lpidr_we
                           | ex2_lsucr0_we        | ex2_xucr2_we         | ex2_xudbg0_we        |
                           ex2_slowspr_range_hypv |
                        |(tspr_cspr_hypv_mtspr & ex2_tid));

      end
   endgenerate

   generate
      if (a2mode == 0 & hvmode == 1)
      begin : ill_spr_01
         assign ex2_illeg_mfspr = ex2_is_mfspr_q & ~(
                             ex2_ccr0_rdec        | ex2_ccr1_rdec        | ex2_ccr2_rdec
                           | ex2_ccr4_rdec        | ex2_cir_rdec         | ex2_pir_rdec
                           | ex2_pvr_rdec         | ex2_tb_rdec          | ex2_tbu_rdec
                           | ex2_tenc_rdec        | ex2_tens_rdec        | ex2_tensr_rdec
                           | ex2_tir_rdec         | ex2_xesr1_rdec       | ex2_xesr2_rdec
                           | ex2_xucr0_rdec       | ex2_xucr4_rdec       |
                             ex2_gsprg0_rdec      | ex2_gsprg1_rdec      | ex2_gsprg2_rdec
                           | ex2_gsprg3_rdec      | ex2_sprg0_rdec       | ex2_sprg1_rdec
                           | ex2_sprg2_rdec       | ex2_sprg3_rdec       | ex2_sprg4_rdec
                           | ex2_sprg5_rdec       | ex2_sprg6_rdec       | ex2_sprg7_rdec
                           | ex2_sprg8_rdec       | ex2_vrsave_rdec      |
                             ex2_axucr0_rdec      | ex2_cpcr0_rdec       | ex2_cpcr1_rdec
                           | ex2_cpcr2_rdec       | ex2_cpcr3_rdec       | ex2_cpcr4_rdec
                           | ex2_cpcr5_rdec       | ex2_dac3_rdec        | ex2_dac4_rdec
                           | ex2_dbcr3_rdec       | ex2_dscr_rdec        | ex2_eheir_rdec
                           | ex2_eplc_rdec        | ex2_epsc_rdec        | ex2_eptcfg_rdec
                           | ex2_givpr_rdec       | ex2_hacop_rdec       | ex2_iac1_rdec
                           | ex2_iac2_rdec        | ex2_iucr0_rdec       | ex2_iucr1_rdec
                           | ex2_iucr2_rdec       | ex2_iudbg0_rdec      | ex2_iudbg1_rdec
                           | ex2_iudbg2_rdec      | ex2_iulfsr_rdec      | ex2_iullcr_rdec
                           | ex2_ivpr_rdec        | ex2_lesr1_rdec       | ex2_lesr2_rdec
                           | ex2_lper_rdec        | ex2_lperu_rdec       | ex2_lpidr_rdec
                           | ex2_lratcfg_rdec     | ex2_lratps_rdec      | ex2_lsucr0_rdec
                           | ex2_mas0_rdec        | ex2_mas0_mas1_rdec   | ex2_mas1_rdec
                           | ex2_mas2_rdec        | ex2_mas2u_rdec       | ex2_mas3_rdec
                           | ex2_mas4_rdec        | ex2_mas5_rdec        | ex2_mas5_mas6_rdec
                           | ex2_mas6_rdec        | ex2_mas7_rdec        | ex2_mas7_mas3_rdec
                           | ex2_mas8_rdec        | ex2_mas8_mas1_rdec   | ex2_mmucfg_rdec
                           | ex2_mmucr3_rdec      | ex2_mmucsr0_rdec     | ex2_pesr_rdec
                           | ex2_pid_rdec         | ex2_ppr32_rdec       | ex2_sramd_rdec
                           | ex2_tlb0cfg_rdec     | ex2_tlb0ps_rdec      | ex2_xucr2_rdec
                           | ex2_xudbg0_rdec      | ex2_xudbg1_rdec      | ex2_xudbg2_rdec      |
                           ex2_slowspr_range |
                        |(tspr_cspr_illeg_mfspr_b & ex2_tid));

         assign ex2_illeg_mtspr = ex2_is_mtspr_q & ~(
                             ex2_ccr0_wdec        | ex2_ccr1_wdec        | ex2_ccr2_wdec
                           | ex2_ccr4_wdec        | ex2_tbl_wdec         | ex2_tbu_wdec
                           | ex2_tenc_wdec        | ex2_tens_wdec        | ex2_trace_wdec
                           | ex2_xesr1_wdec       | ex2_xesr2_wdec       | ex2_xucr0_wdec
                           | ex2_xucr4_wdec       |
                             ex2_gsprg0_wdec      | ex2_gsprg1_wdec      | ex2_gsprg2_wdec
                           | ex2_gsprg3_wdec      | ex2_sprg0_wdec       | ex2_sprg1_wdec
                           | ex2_sprg2_wdec       | ex2_sprg3_wdec       | ex2_sprg4_wdec
                           | ex2_sprg5_wdec       | ex2_sprg6_wdec       | ex2_sprg7_wdec
                           | ex2_sprg8_wdec       | ex2_vrsave_wdec      |
                             ex2_axucr0_wdec      | ex2_cpcr0_wdec       | ex2_cpcr1_wdec
                           | ex2_cpcr2_wdec       | ex2_cpcr3_wdec       | ex2_cpcr4_wdec
                           | ex2_cpcr5_wdec       | ex2_dac3_wdec        | ex2_dac4_wdec
                           | ex2_dbcr3_wdec       | ex2_dscr_wdec        | ex2_eheir_wdec
                           | ex2_eplc_wdec        | ex2_epsc_wdec        | ex2_givpr_wdec
                           | ex2_hacop_wdec       | ex2_iac1_wdec        | ex2_iac2_wdec
                           | ex2_iucr0_wdec       | ex2_iucr1_wdec       | ex2_iucr2_wdec
                           | ex2_iudbg0_wdec      | ex2_iulfsr_wdec      | ex2_iullcr_wdec
                           | ex2_ivpr_wdec        | ex2_lesr1_wdec       | ex2_lesr2_wdec
                           | ex2_lper_wdec        | ex2_lperu_wdec       | ex2_lpidr_wdec
                           | ex2_lsucr0_wdec      | ex2_mas0_wdec        | ex2_mas0_mas1_wdec
                           | ex2_mas1_wdec        | ex2_mas2_wdec        | ex2_mas2u_wdec
                           | ex2_mas3_wdec        | ex2_mas4_wdec        | ex2_mas5_wdec
                           | ex2_mas5_mas6_wdec   | ex2_mas6_wdec        | ex2_mas7_wdec
                           | ex2_mas7_mas3_wdec   | ex2_mas8_wdec        | ex2_mas8_mas1_wdec
                           | ex2_mmucr3_wdec      | ex2_mmucsr0_wdec     | ex2_pesr_wdec
                           | ex2_pid_wdec         | ex2_ppr32_wdec       | ex2_xucr2_wdec
                           | ex2_xudbg0_wdec      |
                           ex2_slowspr_range |
                        |(tspr_cspr_illeg_mtspr_b & ex2_tid));

         assign ex2_hypv_mfspr = ex2_is_mfspr_q & (
                             ex2_ccr0_re          | ex2_ccr1_re          | ex2_ccr2_re
                           | ex2_ccr4_re          | ex2_tenc_re          | ex2_tens_re
                           | ex2_tensr_re         | ex2_tir_re           | ex2_xucr0_re
                           | ex2_xucr4_re         |
                             ex2_sprg8_re         |
                             ex2_axucr0_re        | ex2_cpcr0_re         | ex2_cpcr1_re
                           | ex2_cpcr2_re         | ex2_cpcr3_re         | ex2_cpcr4_re
                           | ex2_cpcr5_re         | ex2_dac3_re          | ex2_dac4_re
                           | ex2_dbcr3_re         | ex2_eheir_re         | ex2_eptcfg_re
                           | ex2_iac1_re          | ex2_iac2_re          | ex2_iucr0_re
                           | ex2_iucr1_re         | ex2_iucr2_re         | ex2_iudbg0_re
                           | ex2_iudbg1_re        | ex2_iudbg2_re        | ex2_iulfsr_re
                           | ex2_iullcr_re        | ex2_ivpr_re          | ex2_lper_re
                           | ex2_lperu_re         | ex2_lpidr_re         | ex2_lratcfg_re
                           | ex2_lratps_re        | ex2_lsucr0_re        | ex2_mas5_re
                           | ex2_mas5_mas6_re     | ex2_mas8_re          | ex2_mas8_mas1_re
                           | ex2_mmucfg_re        | ex2_mmucsr0_re       | ex2_tlb0cfg_re
                           | ex2_tlb0ps_re        | ex2_xucr2_re         | ex2_xudbg0_re
                           | ex2_xudbg1_re        | ex2_xudbg2_re        |
                           ex2_slowspr_range_hypv |
                        |(tspr_cspr_hypv_mfspr & ex2_tid));

         assign ex2_hypv_mtspr = ex2_is_mtspr_q & (
                             ex2_ccr0_we          | ex2_ccr1_we          | ex2_ccr2_we
                           | ex2_ccr4_we          | ex2_tbl_we           | ex2_tbu_we
                           | ex2_tenc_we          | ex2_tens_we          | ex2_xucr0_we
                           | ex2_xucr4_we         |
                             ex2_sprg8_we         |
                             ex2_axucr0_we        | ex2_cpcr0_we         | ex2_cpcr1_we
                           | ex2_cpcr2_we         | ex2_cpcr3_we         | ex2_cpcr4_we
                           | ex2_cpcr5_we         | ex2_dac3_we          | ex2_dac4_we
                           | ex2_dbcr3_we         | ex2_eheir_we         | ex2_givpr_we
                           | ex2_hacop_we         | ex2_iac1_we          | ex2_iac2_we
                           | ex2_iucr0_we         | ex2_iucr1_we         | ex2_iucr2_we
                           | ex2_iudbg0_we        | ex2_iulfsr_we        | ex2_iullcr_we
                           | ex2_ivpr_we          | ex2_lper_we          | ex2_lperu_we
                           | ex2_lpidr_we         | ex2_lsucr0_we        | ex2_mas5_we
                           | ex2_mas5_mas6_we     | ex2_mas8_we          | ex2_mas8_mas1_we
                           | ex2_mmucsr0_we       | ex2_xucr2_we         | ex2_xudbg0_we        |
                           ex2_slowspr_range_hypv |
                        |(tspr_cspr_hypv_mtspr & ex2_tid));

      end
   endgenerate

   generate
      if (a2mode == 1 & hvmode == 0)
      begin : ill_spr_10
         assign ex2_illeg_mfspr = ex2_is_mfspr_q & ~(
                             ex2_ccr0_rdec        | ex2_ccr1_rdec        | ex2_ccr2_rdec
                           | ex2_ccr4_rdec        | ex2_cir_rdec         | ex2_pir_rdec
                           | ex2_pvr_rdec         | ex2_tb_rdec          | ex2_tbu_rdec
                           | ex2_tenc_rdec        | ex2_tens_rdec        | ex2_tensr_rdec
                           | ex2_tir_rdec         | ex2_xesr1_rdec       | ex2_xesr2_rdec
                           | ex2_xucr0_rdec       | ex2_xucr4_rdec       |
                             ex2_sprg0_rdec       | ex2_sprg1_rdec       | ex2_sprg2_rdec
                           | ex2_sprg3_rdec       | ex2_sprg4_rdec       | ex2_sprg5_rdec
                           | ex2_sprg6_rdec       | ex2_sprg7_rdec       | ex2_sprg8_rdec
                           | ex2_vrsave_rdec      |
                             ex2_acop_rdec        | ex2_axucr0_rdec      | ex2_cpcr0_rdec
                           | ex2_cpcr1_rdec       | ex2_cpcr2_rdec       | ex2_cpcr3_rdec
                           | ex2_cpcr4_rdec       | ex2_cpcr5_rdec       | ex2_dac1_rdec
                           | ex2_dac2_rdec        | ex2_dac3_rdec        | ex2_dac4_rdec
                           | ex2_dbcr2_rdec       | ex2_dbcr3_rdec       | ex2_dscr_rdec
                           | ex2_dvc1_rdec        | ex2_dvc2_rdec        | ex2_eheir_rdec
                           | ex2_iac1_rdec        | ex2_iac2_rdec        | ex2_iac3_rdec
                           | ex2_iac4_rdec        | ex2_immr_rdec        | ex2_imr_rdec
                           | ex2_iucr0_rdec       | ex2_iucr1_rdec       | ex2_iucr2_rdec
                           | ex2_iudbg0_rdec      | ex2_iudbg1_rdec      | ex2_iudbg2_rdec
                           | ex2_iulfsr_rdec      | ex2_iullcr_rdec      | ex2_ivpr_rdec
                           | ex2_lesr1_rdec       | ex2_lesr2_rdec       | ex2_lpidr_rdec
                           | ex2_lsucr0_rdec      | ex2_mmucr0_rdec      | ex2_mmucr1_rdec
                           | ex2_mmucr2_rdec      | ex2_pesr_rdec        | ex2_pid_rdec
                           | ex2_ppr32_rdec       | ex2_sramd_rdec       | ex2_xucr2_rdec
                           | ex2_xudbg0_rdec      | ex2_xudbg1_rdec      | ex2_xudbg2_rdec      |
                           ex2_slowspr_range |
                        |(tspr_cspr_illeg_mfspr_b & ex2_tid));

         assign ex2_illeg_mtspr = ex2_is_mtspr_q & ~(
                             ex2_ccr0_wdec        | ex2_ccr1_wdec        | ex2_ccr2_wdec
                           | ex2_ccr4_wdec        | ex2_tbl_wdec         | ex2_tbu_wdec
                           | ex2_tenc_wdec        | ex2_tens_wdec        | ex2_trace_wdec
                           | ex2_xesr1_wdec       | ex2_xesr2_wdec       | ex2_xucr0_wdec
                           | ex2_xucr4_wdec       |
                             ex2_sprg0_wdec       | ex2_sprg1_wdec       | ex2_sprg2_wdec
                           | ex2_sprg3_wdec       | ex2_sprg4_wdec       | ex2_sprg5_wdec
                           | ex2_sprg6_wdec       | ex2_sprg7_wdec       | ex2_sprg8_wdec
                           | ex2_vrsave_wdec      |
                             ex2_acop_wdec        | ex2_axucr0_wdec      | ex2_cpcr0_wdec
                           | ex2_cpcr1_wdec       | ex2_cpcr2_wdec       | ex2_cpcr3_wdec
                           | ex2_cpcr4_wdec       | ex2_cpcr5_wdec       | ex2_dac1_wdec
                           | ex2_dac2_wdec        | ex2_dac3_wdec        | ex2_dac4_wdec
                           | ex2_dbcr2_wdec       | ex2_dbcr3_wdec       | ex2_dscr_wdec
                           | ex2_dvc1_wdec        | ex2_dvc2_wdec        | ex2_eheir_wdec
                           | ex2_iac1_wdec        | ex2_iac2_wdec        | ex2_iac3_wdec
                           | ex2_iac4_wdec        | ex2_immr_wdec        | ex2_imr_wdec
                           | ex2_iucr0_wdec       | ex2_iucr1_wdec       | ex2_iucr2_wdec
                           | ex2_iudbg0_wdec      | ex2_iulfsr_wdec      | ex2_iullcr_wdec
                           | ex2_ivpr_wdec        | ex2_lesr1_wdec       | ex2_lesr2_wdec
                           | ex2_lpidr_wdec       | ex2_lsucr0_wdec      | ex2_mmucr0_wdec
                           | ex2_mmucr1_wdec      | ex2_mmucr2_wdec      | ex2_pesr_wdec
                           | ex2_pid_wdec         | ex2_ppr32_wdec       | ex2_xucr2_wdec
                           | ex2_xudbg0_wdec      |
                           ex2_slowspr_range |
                        |(tspr_cspr_illeg_mtspr_b & ex2_tid));

         assign ex2_hypv_mfspr = ex2_is_mfspr_q & (
                             ex2_ccr0_re          | ex2_ccr1_re          | ex2_ccr2_re
                           | ex2_ccr4_re          | ex2_tenc_re          | ex2_tens_re
                           | ex2_tensr_re         | ex2_tir_re           | ex2_xucr0_re
                           | ex2_xucr4_re         |
                             ex2_sprg8_re         |
                             ex2_axucr0_re        | ex2_cpcr0_re         | ex2_cpcr1_re
                           | ex2_cpcr2_re         | ex2_cpcr3_re         | ex2_cpcr4_re
                           | ex2_cpcr5_re         | ex2_dac1_re          | ex2_dac2_re
                           | ex2_dac3_re          | ex2_dac4_re          | ex2_dbcr2_re
                           | ex2_dbcr3_re         | ex2_dvc1_re          | ex2_dvc2_re
                           | ex2_eheir_re         | ex2_iac1_re          | ex2_iac2_re
                           | ex2_iac3_re          | ex2_iac4_re          | ex2_immr_re
                           | ex2_imr_re           | ex2_iucr0_re         | ex2_iucr1_re
                           | ex2_iucr2_re         | ex2_iudbg0_re        | ex2_iudbg1_re
                           | ex2_iudbg2_re        | ex2_iulfsr_re        | ex2_iullcr_re
                           | ex2_ivpr_re          | ex2_lpidr_re         | ex2_lsucr0_re
                           | ex2_mmucr0_re        | ex2_mmucr1_re        | ex2_mmucr2_re
                           | ex2_xucr2_re         | ex2_xudbg0_re        | ex2_xudbg1_re
                           | ex2_xudbg2_re        |
                           ex2_slowspr_range_hypv |
                        |(tspr_cspr_hypv_mfspr & ex2_tid));

         assign ex2_hypv_mtspr = ex2_is_mtspr_q & (
                             ex2_ccr0_we          | ex2_ccr1_we          | ex2_ccr2_we
                           | ex2_ccr4_we          | ex2_tbl_we           | ex2_tbu_we
                           | ex2_tenc_we          | ex2_tens_we          | ex2_xucr0_we
                           | ex2_xucr4_we         |
                             ex2_sprg8_we         |
                             ex2_axucr0_we        | ex2_cpcr0_we         | ex2_cpcr1_we
                           | ex2_cpcr2_we         | ex2_cpcr3_we         | ex2_cpcr4_we
                           | ex2_cpcr5_we         | ex2_dac1_we          | ex2_dac2_we
                           | ex2_dac3_we          | ex2_dac4_we          | ex2_dbcr2_we
                           | ex2_dbcr3_we         | ex2_dvc1_we          | ex2_dvc2_we
                           | ex2_eheir_we         | ex2_iac1_we          | ex2_iac2_we
                           | ex2_iac3_we          | ex2_iac4_we          | ex2_immr_we
                           | ex2_imr_we           | ex2_iucr0_we         | ex2_iucr1_we
                           | ex2_iucr2_we         | ex2_iudbg0_we        | ex2_iulfsr_we
                           | ex2_iullcr_we        | ex2_ivpr_we          | ex2_lpidr_we
                           | ex2_lsucr0_we        | ex2_mmucr0_we        | ex2_mmucr1_we
                           | ex2_mmucr2_we        | ex2_xucr2_we         | ex2_xudbg0_we        |
                           ex2_slowspr_range_hypv |
                        |(tspr_cspr_hypv_mtspr & ex2_tid));
      end
   endgenerate

   generate
      if (a2mode == 1 & hvmode == 1)
      begin : ill_spr_11
         assign ex2_illeg_mfspr = ex2_is_mfspr_q & ~(
                             ex2_ccr0_rdec        | ex2_ccr1_rdec        | ex2_ccr2_rdec
                           | ex2_ccr4_rdec        | ex2_cir_rdec         | ex2_pir_rdec
                           | ex2_pvr_rdec         | ex2_tb_rdec          | ex2_tbu_rdec
                           | ex2_tenc_rdec        | ex2_tens_rdec        | ex2_tensr_rdec
                           | ex2_tir_rdec         | ex2_xesr1_rdec       | ex2_xesr2_rdec
                           | ex2_xucr0_rdec       | ex2_xucr4_rdec       |
                             ex2_gsprg0_rdec      | ex2_gsprg1_rdec      | ex2_gsprg2_rdec
                           | ex2_gsprg3_rdec      | ex2_sprg0_rdec       | ex2_sprg1_rdec
                           | ex2_sprg2_rdec       | ex2_sprg3_rdec       | ex2_sprg4_rdec
                           | ex2_sprg5_rdec       | ex2_sprg6_rdec       | ex2_sprg7_rdec
                           | ex2_sprg8_rdec       | ex2_vrsave_rdec      |
                             ex2_acop_rdec        | ex2_axucr0_rdec      | ex2_cpcr0_rdec
                           | ex2_cpcr1_rdec       | ex2_cpcr2_rdec       | ex2_cpcr3_rdec
                           | ex2_cpcr4_rdec       | ex2_cpcr5_rdec       | ex2_dac1_rdec
                           | ex2_dac2_rdec        | ex2_dac3_rdec        | ex2_dac4_rdec
                           | ex2_dbcr2_rdec       | ex2_dbcr3_rdec       | ex2_dscr_rdec
                           | ex2_dvc1_rdec        | ex2_dvc2_rdec        | ex2_eheir_rdec
                           | ex2_eplc_rdec        | ex2_epsc_rdec        | ex2_eptcfg_rdec
                           | ex2_givpr_rdec       | ex2_hacop_rdec       | ex2_iac1_rdec
                           | ex2_iac2_rdec        | ex2_iac3_rdec        | ex2_iac4_rdec
                           | ex2_immr_rdec        | ex2_imr_rdec         | ex2_iucr0_rdec
                           | ex2_iucr1_rdec       | ex2_iucr2_rdec       | ex2_iudbg0_rdec
                           | ex2_iudbg1_rdec      | ex2_iudbg2_rdec      | ex2_iulfsr_rdec
                           | ex2_iullcr_rdec      | ex2_ivpr_rdec        | ex2_lesr1_rdec
                           | ex2_lesr2_rdec       | ex2_lper_rdec        | ex2_lperu_rdec
                           | ex2_lpidr_rdec       | ex2_lratcfg_rdec     | ex2_lratps_rdec
                           | ex2_lsucr0_rdec      | ex2_mas0_rdec        | ex2_mas0_mas1_rdec
                           | ex2_mas1_rdec        | ex2_mas2_rdec        | ex2_mas2u_rdec
                           | ex2_mas3_rdec        | ex2_mas4_rdec        | ex2_mas5_rdec
                           | ex2_mas5_mas6_rdec   | ex2_mas6_rdec        | ex2_mas7_rdec
                           | ex2_mas7_mas3_rdec   | ex2_mas8_rdec        | ex2_mas8_mas1_rdec
                           | ex2_mmucfg_rdec      | ex2_mmucr0_rdec      | ex2_mmucr1_rdec
                           | ex2_mmucr2_rdec      | ex2_mmucr3_rdec      | ex2_mmucsr0_rdec
                           | ex2_pesr_rdec        | ex2_pid_rdec         | ex2_ppr32_rdec
                           | ex2_sramd_rdec       | ex2_tlb0cfg_rdec     | ex2_tlb0ps_rdec
                           | ex2_xucr2_rdec       | ex2_xudbg0_rdec      | ex2_xudbg1_rdec
                           | ex2_xudbg2_rdec      |
                           ex2_slowspr_range |
                        |(tspr_cspr_illeg_mfspr_b & ex2_tid));

         assign ex2_illeg_mtspr = ex2_is_mtspr_q & ~(
                             ex2_ccr0_wdec        | ex2_ccr1_wdec        | ex2_ccr2_wdec
                           | ex2_ccr4_wdec        | ex2_tbl_wdec         | ex2_tbu_wdec
                           | ex2_tenc_wdec        | ex2_tens_wdec        | ex2_trace_wdec
                           | ex2_xesr1_wdec       | ex2_xesr2_wdec       | ex2_xucr0_wdec
                           | ex2_xucr4_wdec       |
                             ex2_gsprg0_wdec      | ex2_gsprg1_wdec      | ex2_gsprg2_wdec
                           | ex2_gsprg3_wdec      | ex2_sprg0_wdec       | ex2_sprg1_wdec
                           | ex2_sprg2_wdec       | ex2_sprg3_wdec       | ex2_sprg4_wdec
                           | ex2_sprg5_wdec       | ex2_sprg6_wdec       | ex2_sprg7_wdec
                           | ex2_sprg8_wdec       | ex2_vrsave_wdec      |
                             ex2_acop_wdec        | ex2_axucr0_wdec      | ex2_cpcr0_wdec
                           | ex2_cpcr1_wdec       | ex2_cpcr2_wdec       | ex2_cpcr3_wdec
                           | ex2_cpcr4_wdec       | ex2_cpcr5_wdec       | ex2_dac1_wdec
                           | ex2_dac2_wdec        | ex2_dac3_wdec        | ex2_dac4_wdec
                           | ex2_dbcr2_wdec       | ex2_dbcr3_wdec       | ex2_dscr_wdec
                           | ex2_dvc1_wdec        | ex2_dvc2_wdec        | ex2_eheir_wdec
                           | ex2_eplc_wdec        | ex2_epsc_wdec        | ex2_givpr_wdec
                           | ex2_hacop_wdec       | ex2_iac1_wdec        | ex2_iac2_wdec
                           | ex2_iac3_wdec        | ex2_iac4_wdec        | ex2_immr_wdec
                           | ex2_imr_wdec         | ex2_iucr0_wdec       | ex2_iucr1_wdec
                           | ex2_iucr2_wdec       | ex2_iudbg0_wdec      | ex2_iulfsr_wdec
                           | ex2_iullcr_wdec      | ex2_ivpr_wdec        | ex2_lesr1_wdec
                           | ex2_lesr2_wdec       | ex2_lper_wdec        | ex2_lperu_wdec
                           | ex2_lpidr_wdec       | ex2_lsucr0_wdec      | ex2_mas0_wdec
                           | ex2_mas0_mas1_wdec   | ex2_mas1_wdec        | ex2_mas2_wdec
                           | ex2_mas2u_wdec       | ex2_mas3_wdec        | ex2_mas4_wdec
                           | ex2_mas5_wdec        | ex2_mas5_mas6_wdec   | ex2_mas6_wdec
                           | ex2_mas7_wdec        | ex2_mas7_mas3_wdec   | ex2_mas8_wdec
                           | ex2_mas8_mas1_wdec   | ex2_mmucr0_wdec      | ex2_mmucr1_wdec
                           | ex2_mmucr2_wdec      | ex2_mmucr3_wdec      | ex2_mmucsr0_wdec
                           | ex2_pesr_wdec        | ex2_pid_wdec         | ex2_ppr32_wdec
                           | ex2_xucr2_wdec       | ex2_xudbg0_wdec      |
                           ex2_slowspr_range |
                        |(tspr_cspr_illeg_mtspr_b & ex2_tid));

         assign ex2_hypv_mfspr = ex2_is_mfspr_q & (
                             ex2_ccr0_re          | ex2_ccr1_re          | ex2_ccr2_re
                           | ex2_ccr4_re          | ex2_tenc_re          | ex2_tens_re
                           | ex2_tensr_re         | ex2_tir_re           | ex2_xucr0_re
                           | ex2_xucr4_re         |
                             ex2_sprg8_re         |
                             ex2_axucr0_re        | ex2_cpcr0_re         | ex2_cpcr1_re
                           | ex2_cpcr2_re         | ex2_cpcr3_re         | ex2_cpcr4_re
                           | ex2_cpcr5_re         | ex2_dac1_re          | ex2_dac2_re
                           | ex2_dac3_re          | ex2_dac4_re          | ex2_dbcr2_re
                           | ex2_dbcr3_re         | ex2_dvc1_re          | ex2_dvc2_re
                           | ex2_eheir_re         | ex2_eptcfg_re        | ex2_iac1_re
                           | ex2_iac2_re          | ex2_iac3_re          | ex2_iac4_re
                           | ex2_immr_re          | ex2_imr_re           | ex2_iucr0_re
                           | ex2_iucr1_re         | ex2_iucr2_re         | ex2_iudbg0_re
                           | ex2_iudbg1_re        | ex2_iudbg2_re        | ex2_iulfsr_re
                           | ex2_iullcr_re        | ex2_ivpr_re          | ex2_lper_re
                           | ex2_lperu_re         | ex2_lpidr_re         | ex2_lratcfg_re
                           | ex2_lratps_re        | ex2_lsucr0_re        | ex2_mas5_re
                           | ex2_mas5_mas6_re     | ex2_mas8_re          | ex2_mas8_mas1_re
                           | ex2_mmucfg_re        | ex2_mmucr0_re        | ex2_mmucr1_re
                           | ex2_mmucr2_re        | ex2_mmucsr0_re       | ex2_tlb0cfg_re
                           | ex2_tlb0ps_re        | ex2_xucr2_re         | ex2_xudbg0_re
                           | ex2_xudbg1_re        | ex2_xudbg2_re        |
                           ex2_slowspr_range_hypv |
                        |(tspr_cspr_hypv_mfspr & ex2_tid));

         assign ex2_hypv_mtspr = ex2_is_mtspr_q & (
                             ex2_ccr0_we          | ex2_ccr1_we          | ex2_ccr2_we
                           | ex2_ccr4_we          | ex2_tbl_we           | ex2_tbu_we
                           | ex2_tenc_we          | ex2_tens_we          | ex2_xucr0_we
                           | ex2_xucr4_we         |
                             ex2_sprg8_we         |
                             ex2_axucr0_we        | ex2_cpcr0_we         | ex2_cpcr1_we
                           | ex2_cpcr2_we         | ex2_cpcr3_we         | ex2_cpcr4_we
                           | ex2_cpcr5_we         | ex2_dac1_we          | ex2_dac2_we
                           | ex2_dac3_we          | ex2_dac4_we          | ex2_dbcr2_we
                           | ex2_dbcr3_we         | ex2_dvc1_we          | ex2_dvc2_we
                           | ex2_eheir_we         | ex2_givpr_we         | ex2_hacop_we
                           | ex2_iac1_we          | ex2_iac2_we          | ex2_iac3_we
                           | ex2_iac4_we          | ex2_immr_we          | ex2_imr_we
                           | ex2_iucr0_we         | ex2_iucr1_we         | ex2_iucr2_we
                           | ex2_iudbg0_we        | ex2_iulfsr_we        | ex2_iullcr_we
                           | ex2_ivpr_we          | ex2_lper_we          | ex2_lperu_we
                           | ex2_lpidr_we         | ex2_lsucr0_we        | ex2_mas5_we
                           | ex2_mas5_mas6_we     | ex2_mas8_we          | ex2_mas8_mas1_we
                           | ex2_mmucr0_we        | ex2_mmucr1_we        | ex2_mmucr2_we
                           | ex2_mmucsr0_we       | ex2_xucr2_we         | ex2_xudbg0_we        |
                           ex2_slowspr_range_hypv |
                        |(tspr_cspr_hypv_mtspr & ex2_tid));
      end
   endgenerate

   assign ex1_dnh          = ex1_valid & ex1_is_dnh & spr_ccr4_en_dnh;

   assign ex3_wait_flush_d = |ex2_wait_flush;

   assign ex2_np1_flush    = (ex2_ccr0_flush | ex2_tenc_flush | ex2_xucr0_flush) & ex2_tid;

   assign ex3_np1_flush_d  = (|tspr_cspr_ex2_np1_flush) | |(ex2_np1_flush) | ex2_dnh_q | (ex2_is_mtspr_q & (ex2_ccr2_wdec | ex2_cpcr0_wdec | ex2_cpcr1_wdec | ex2_cpcr2_wdec | ex2_cpcr3_wdec | ex2_cpcr4_wdec | ex2_cpcr5_wdec |ex2_pid_wdec | ex2_lpidr_wdec | ex2_mmucr1_wdec | ex2_xucr0_wdec | ex2_iucr2_wdec | ex2_mmucsr0_wdec)) | ex2_is_mtmsr_q;

   assign ex4_np1_flush_d  = ex3_spr_we & ex3_np1_flush_q;
   assign ex4_wait_flush_d = ex3_spr_we & ex3_wait_flush_q;

   assign ex2_msr_pr       = |(ex2_tid & tspr_msr_pr);
   assign ex2_msr_gs       = |(ex2_tid & tspr_msr_gs);

   assign ex3_hypv_spr_d   = (ex2_val_rd_q | ex2_val_wr_q) & (~ex2_msr_pr) & ex2_msr_gs & (ex2_hypv_mfspr | ex2_hypv_mtspr | ex2_hypv_instr_q);

   assign ex3_illeg_spr_d  = (ex2_val_rd_q | ex2_val_wr_q) & (((ex2_illeg_mfspr | ex2_illeg_mtspr | ex2_illeg_mftb) & ~(ex2_instr_q[11] & ex2_msr_pr)) | (ex2_hypv_instr_q & ~spr_ccr2_en_pc));

   assign ex3_priv_spr_d   = (ex2_val_rd_q | ex2_val_wr_q) & ex2_msr_pr & ((ex2_instr_q[11] & (ex2_is_mtspr_q | ex2_is_mfspr_q)) | ex2_priv_instr_q);

	assign spr_ccr0_pme                = ccr0_q[62:63];
	assign spr_ccr0_we                 = ccr0_we;
	assign spr_ccr2_en_dcr             = spr_ccr2_en_dcr_int;
	assign spr_ccr2_en_dcr_int         = ccr2_q[32];
	assign spr_ccr2_en_trace           = ccr2_q[33];
	assign spr_ccr2_en_pc              = ccr2_q[34];
	assign spr_ccr2_ifratsc            = ccr2_q[35:43];
	assign spr_ccr2_ifrat              = ccr2_q[44];
	assign spr_ccr2_dfratsc            = ccr2_q[45:53];
	assign spr_ccr2_dfrat              = ccr2_q[54];
	assign spr_ccr2_ucode_dis          = ccr2_q[55];
	assign spr_ccr2_ap                 = ccr2_q[56:59];
	assign spr_ccr2_en_attn            = ccr2_q[60];
	assign spr_ccr2_en_ditc            = ccr2_q[61];
	assign spr_ccr2_en_icswx           = ccr2_q[62];
	assign spr_ccr2_notlb              = ccr2_q[63];
	assign spr_ccr4_en_dnh             = ccr4_q[63];
	assign spr_tens_ten                = tens_q[64-(`THREADS):63];
	assign spr_xucr0_clkg_ctl          = xucr0_q[38:42];
	assign spr_xucr0_trace_um          = xucr0_q[43:46];
	assign xu_lsu_spr_xucr0_mbar_ack   = xucr0_q[47];
	assign xu_lsu_spr_xucr0_tlbsync    = xucr0_q[48];
	assign spr_xucr0_cls               = xucr0_q[49];
	assign xu_lsu_spr_xucr0_aflsta     = xucr0_q[50];
	assign spr_xucr0_mddp              = xucr0_q[51];
	assign xu_lsu_spr_xucr0_cred       = xucr0_q[52];
	assign xu_lsu_spr_xucr0_rel        = xucr0_q[53];
	assign spr_xucr0_mdcp              = xucr0_q[54];
	assign spr_xucr0_tcs               = xucr0_q[55];
	assign xu_lsu_spr_xucr0_flsta      = xucr0_q[56];
	assign xu_lsu_spr_xucr0_l2siw      = xucr0_q[57];
	assign xu_lsu_spr_xucr0_flh2l2     = xucr0_q[58];
	assign xu_lsu_spr_xucr0_dcdis      = xucr0_q[59];
	assign xu_lsu_spr_xucr0_wlk        = xucr0_q[60];
	assign spr_xucr4_mmu_mchk          = xucr4_q[60];
	assign spr_xucr4_mddmh             = xucr4_q[61];
	assign spr_xucr4_tcd               = xucr4_q[62:63];
   assign xucr0_clfc_d = ex3_xucr0_we & ex3_spr_wd[63];
   assign xu_lsu_spr_xucr0_clfc = xucr0_clfc_q;
   assign cspr_ccr2_en_pc = spr_ccr2_en_pc;
   assign cspr_ccr4_en_dnh = spr_ccr4_en_dnh;

	// CCR0
	assign ex3_ccr0_di     = { ex3_spr_wd[32:33]                }; //PME

	assign ccr0_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              ccr0_q[62:63]                    , //PME
                              tidn[34:51]                      , /////
                              4'b0000                          , //WEM
                              tidn[56:59]                      , /////
                              ccr0_we                          }; //WE
	// CCR1
	assign ex3_ccr1_di     = { ex3_spr_wd[34:39]                , //WC3
                              ex3_spr_wd[42:47]                , //WC2
                              ex3_spr_wd[50:55]                , //WC1
                              ex3_spr_wd[58:63]                }; //WC0

	assign ccr1_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:33]                      , /////
                              ccr1_q[40:45]                    , //WC3
                              tidn[40:41]                      , /////
                              ccr1_q[46:51]                    , //WC2
                              tidn[48:49]                      , /////
                              ccr1_q[52:57]                    , //WC1
                              tidn[56:57]                      , /////
                              ccr1_q[58:63]                    }; //WC0
	// CCR2
	assign ex3_ccr2_di     = { ex3_spr_wd[32:32]                , //EN_DCR
                              ex3_spr_wd[33:33]                , //EN_TRACE
                              ex3_spr_wd[34:34]                , //EN_PC
                              ex3_spr_wd[35:43]                , //IFRATSC
                              ex3_spr_wd[44:44]                , //IFRAT
                              ex3_spr_wd[45:53]                , //DFRATSC
                              ex3_spr_wd[54:54]                , //DFRAT
                              ex3_spr_wd[55:55]                , //UCODE_DIS
                              ex3_spr_wd[56:59]                , //AP
                              ex3_spr_wd[60:60]                , //EN_ATTN
                              ex3_spr_wd[61:61]                , //EN_DITC
                              ex3_spr_wd[62:62]                , //EN_ICSWX
                              ex3_spr_wd[63:63]                }; //NOTLB

	assign ccr2_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              ccr2_q[32:32]                    , //EN_DCR
                              ccr2_q[33:33]                    , //EN_TRACE
                              ccr2_q[34:34]                    , //EN_PC
                              ccr2_q[35:43]                    , //IFRATSC
                              ccr2_q[44:44]                    , //IFRAT
                              ccr2_q[45:53]                    , //DFRATSC
                              ccr2_q[54:54]                    , //DFRAT
                              ccr2_q[55:55]                    , //UCODE_DIS
                              ccr2_q[56:59]                    , //AP
                              ccr2_q[60:60]                    , //EN_ATTN
                              ccr2_q[61:61]                    , //EN_DITC
                              ccr2_q[62:62]                    , //EN_ICSWX
                              ccr2_q[63:63]                    }; //NOTLB
	// CCR4
	assign ex3_ccr4_di     = { ex3_spr_wd[63:63]                }; //EN_DNH

	assign ccr4_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:62]                      , /////
                              ccr4_q[63:63]                    }; //EN_DNH
	// CIR
	assign cir_do          = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              an_ac_chipid_dc[32:35]           , //ID
                              tidn[36:63]                      }; /////
	// PIR
	assign pir_do          = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:53]                      , /////
                              an_ac_coreid_q[54:61]            , //CID
                              ex2_tid_q[0:1]                   }; //TID
	// PVR
	assign pvr_do          = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              version[32:47]                   , //VERSION
                              revision[48:63]                  }; //REVISION
	// TB
	assign tb_do           = { tidn[0:0]                        ,
                              tbu_q[32:63]                     , //TBU
                              tbl_q[32:63]                     }; //TBL
	// TBL
	assign ex3_tbl_di      = { ex3_spr_wd[32:63]                }; //TBL

	assign tbl_do          = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tbl_q[32:63]                     }; //TBL
	// TBU
	assign ex3_tbu_di      = { ex3_spr_wd[32:63]                }; //TBU

	assign tbu_do          = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tbu_q[32:63]                     }; //TBU
	// TENC
	assign tenc_do         = { tidn[0:64-`THREADS]              ,
                              tens_q[64-`THREADS:63]           }; //TEN
	// TENS
	assign ex3_tens_di     = { ex3_spr_wd[64-(`THREADS):63]     }; //TEN

	assign tens_do         = { tidn[0:64-(`THREADS)]            ,
                              tens_q[64-(`THREADS):63]         }; //TEN
	// TENSR
	assign tensr_do        = { tidn[0:64-`THREADS]              ,
                              spr_tensr[0:`THREADS-1]          }; //TENSR
	// TIR
	assign tir_do          = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:61]                      , /////
                              ex2_tid_q[0:1]                   }; //TID
	// XESR1
	assign ex3_xesr1_di    = { ex3_spr_wd[32:35]                , //MUXSELEB0
                              ex3_spr_wd[36:39]                , //MUXSELEB1
                              ex3_spr_wd[40:43]                , //MUXSELEB2
                              ex3_spr_wd[44:47]                , //MUXSELEB3
                              ex3_spr_wd[48:51]                , //MUXSELEB4
                              ex3_spr_wd[52:55]                , //MUXSELEB5
                              ex3_spr_wd[56:59]                , //MUXSELEB6
                              ex3_spr_wd[60:63]                }; //MUXSELEB7

	assign xesr1_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              xesr1_q[32:35]                   , //MUXSELEB0
                              xesr1_q[36:39]                   , //MUXSELEB1
                              xesr1_q[40:43]                   , //MUXSELEB2
                              xesr1_q[44:47]                   , //MUXSELEB3
                              xesr1_q[48:51]                   , //MUXSELEB4
                              xesr1_q[52:55]                   , //MUXSELEB5
                              xesr1_q[56:59]                   , //MUXSELEB6
                              xesr1_q[60:63]                   }; //MUXSELEB7
	// XESR2
	assign ex3_xesr2_di    = { ex3_spr_wd[32:35]                , //MUXSELEB0
                              ex3_spr_wd[36:39]                , //MUXSELEB1
                              ex3_spr_wd[40:43]                , //MUXSELEB2
                              ex3_spr_wd[44:47]                , //MUXSELEB3
                              ex3_spr_wd[48:51]                , //MUXSELEB4
                              ex3_spr_wd[52:55]                , //MUXSELEB5
                              ex3_spr_wd[56:59]                , //MUXSELEB6
                              ex3_spr_wd[60:63]                }; //MUXSELEB7

	assign xesr2_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              xesr2_q[32:35]                   , //MUXSELEB0
                              xesr2_q[36:39]                   , //MUXSELEB1
                              xesr2_q[40:43]                   , //MUXSELEB2
                              xesr2_q[44:47]                   , //MUXSELEB3
                              xesr2_q[48:51]                   , //MUXSELEB4
                              xesr2_q[52:55]                   , //MUXSELEB5
                              xesr2_q[56:59]                   , //MUXSELEB6
                              xesr2_q[60:63]                   }; //MUXSELEB7
	// XUCR0
	assign ex3_xucr0_di    = { ex3_spr_wd[32:36]                , //CLKG_CTL
                              ex3_spr_wd[37:40]                , //TRACE_UM
                              ex3_spr_wd[41:41]                , //MBAR_ACK
                              ex3_spr_wd[42:42]                , //TLBSYNC
                              xucr0_q[49:49]                   , //CLS
                              ex3_spr_wd[49:49]                , //AFLSTA
                              ex3_spr_wd[50:50]                , //MDDP
                              ex3_spr_wd[51:51]                , //CRED
                              xucr0_q[53:53]                   , //REL
                              ex3_spr_wd[53:53]                , //MDCP
                              ex3_spr_wd[54:54]                , //TCS
                              ex3_spr_wd[55:55]                , //FLSTA
                              xucr0_q[57:57]                   , //L2SIW
                              xucr0_q[58:58]                   , //FLH2L2
                              ex3_spr_wd[58:58]                , //DCDIS
                              ex3_spr_wd[59:59]                , //WLK
                              ex3_spr_wd[60:60]                , //CSLC
                              ex3_spr_wd[61:61]                , //CUL
                              ex3_spr_wd[62:62]                }; //CLO

	assign xucr0_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              xucr0_q[38:42]                   , //CLKG_CTL
                              xucr0_q[43:46]                   , //TRACE_UM
                              xucr0_q[47:47]                   , //MBAR_ACK
                              xucr0_q[48:48]                   , //TLBSYNC
                              tidn[43:47]                      , /////
                              xucr0_q[49:49]                   , //CLS
                              xucr0_q[50:50]                   , //AFLSTA
                              xucr0_q[51:51]                   , //MDDP
                              xucr0_q[52:52]                   , //CRED
                              xucr0_q[53:53]                   , //REL
                              xucr0_q[54:54]                   , //MDCP
                              xucr0_q[55:55]                   , //TCS
                              xucr0_q[56:56]                   , //FLSTA
                              xucr0_q[57:57]                   , //L2SIW
                              xucr0_q[58:58]                   , //FLH2L2
                              xucr0_q[59:59]                   , //DCDIS
                              xucr0_q[60:60]                   , //WLK
                              xucr0_q[61:61]                   , //CSLC
                              xucr0_q[62:62]                   , //CUL
                              xucr0_q[63:63]                   , //CLO
                              1'b0                             }; //CLFC
	// XUCR4
	assign ex3_xucr4_di    = { ex3_spr_wd[46:46]                , //MMU_MCHK
                              ex3_spr_wd[47:47]                , //MDDMH
                              ex3_spr_wd[56:57]                }; //TCD

	assign xucr4_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:45]                      , /////
                              xucr4_q[60:60]                   , //MMU_MCHK
                              xucr4_q[61:61]                   , //MDDMH
                              tidn[48:55]                      , /////
                              xucr4_q[62:63]                   , //TCD
                              tidn[58:63]                      }; /////

	// Unused Signals
	assign unused_do_bits = |{
		ccr0_do[0:64-`GPR_WIDTH]
		,ccr1_do[0:64-`GPR_WIDTH]
		,ccr2_do[0:64-`GPR_WIDTH]
		,ccr4_do[0:64-`GPR_WIDTH]
		,cir_do[0:64-`GPR_WIDTH]
		,pir_do[0:64-`GPR_WIDTH]
		,pvr_do[0:64-`GPR_WIDTH]
		,tb_do[0:64-`GPR_WIDTH]
		,tbl_do[0:64-`GPR_WIDTH]
		,tbu_do[0:64-`GPR_WIDTH]
		,tenc_do[0:64-`GPR_WIDTH]
		,tens_do[0:64-`GPR_WIDTH]
		,tensr_do[0:64-`GPR_WIDTH]
		,tir_do[0:64-`GPR_WIDTH]
		,xesr1_do[0:64-`GPR_WIDTH]
		,xesr2_do[0:64-`GPR_WIDTH]
		,xucr0_do[0:64-`GPR_WIDTH]
		,xucr4_do[0:64-`GPR_WIDTH]
		};

     tri_ser_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ccr0_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(ccr0_act),
        .force_t(bcfg_slp_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(bcfg_slp_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv_bcfg[ccr0_offset_bcfg:ccr0_offset_bcfg + 2 - 1]),
        .scout(sov_bcfg[ccr0_offset_bcfg:ccr0_offset_bcfg + 2 - 1]),
        .din(ccr0_d),
        .dout(ccr0_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(24), .INIT(3994575), .NEEDS_SRESET(1)) ccr1_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(ccr1_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[ccr1_offset:ccr1_offset + 24 - 1]),
        .scout(sov[ccr1_offset:ccr1_offset + 24 - 1]),
        .din(ccr1_d),
        .dout(ccr1_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(1), .NEEDS_SRESET(1)) ccr2_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(ccr2_act),
        .force_t(ccfg_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(ccfg_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv_ccfg[ccr2_offset_ccfg:ccr2_offset_ccfg + 32 - 1]),
        .scout(sov_ccfg[ccr2_offset_ccfg:ccr2_offset_ccfg + 32 - 1]),
        .din(ccr2_d),
        .dout(ccr2_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ccr4_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(ccr4_act),
        .force_t(ccfg_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(ccfg_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv_ccfg[ccr4_offset_ccfg:ccr4_offset_ccfg + 1 - 1]),
        .scout(sov_ccfg[ccr4_offset_ccfg:ccr4_offset_ccfg + 1 - 1]),
        .din(ccr4_d),
        .dout(ccr4_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) tbl_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(tbl_act),
        .force_t(func_slp_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_slp_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[tbl_offset:tbl_offset + 32 - 1]),
        .scout(sov[tbl_offset:tbl_offset + 32 - 1]),
        .din(tbl_d),
        .dout(tbl_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) tbu_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(tbu_act),
        .force_t(func_slp_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_slp_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[tbu_offset:tbu_offset + 32 - 1]),
        .scout(sov[tbu_offset:tbu_offset + 32 - 1]),
        .din(tbu_d),
        .dout(tbu_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(`THREADS), .INIT(1), .NEEDS_SRESET(1)) tens_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(tens_act),
        .force_t(bcfg_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(bcfg_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv_bcfg[tens_offset_bcfg:tens_offset_bcfg + `THREADS - 1]),
        .scout(sov_bcfg[tens_offset_bcfg:tens_offset_bcfg + `THREADS - 1]),
        .din(tens_d),
        .dout(tens_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) xesr1_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(xesr1_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[xesr1_offset:xesr1_offset + 32 - 1]),
        .scout(sov[xesr1_offset:xesr1_offset + 32 - 1]),
        .din(xesr1_d),
        .dout(xesr1_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) xesr2_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(xesr2_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[xesr2_offset:xesr2_offset + 32 - 1]),
        .scout(sov[xesr2_offset:xesr2_offset + 32 - 1]),
        .din(xesr2_d),
        .dout(xesr2_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(26), .INIT((spr_xucr0_init)), .NEEDS_SRESET(1)) xucr0_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(xucr0_act),
        .force_t(ccfg_slp_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(ccfg_slp_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv_ccfg[xucr0_offset_ccfg:xucr0_offset_ccfg + 26 - 1]),
        .scout(sov_ccfg[xucr0_offset_ccfg:xucr0_offset_ccfg + 26 - 1]),
        .din(xucr0_d),
        .dout(xucr0_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) xucr4_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(xucr4_act),
        .force_t(dcfg_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(dcfg_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv_dcfg[xucr4_offset_dcfg:xucr4_offset_dcfg + 4 - 1]),
        .scout(sov_dcfg[xucr4_offset_dcfg:xucr4_offset_dcfg + 4 - 1]),
        .din(xucr4_d),
        .dout(xucr4_q)
     );



   // Latch Instances
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(1),.INIT(0), .NEEDS_SRESET(1)) exx_act_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_act_offset : exx_act_offset + 4-1]),
      .scout(sov[exx_act_offset : exx_act_offset + 4-1]),
      .din(exx_act_d),
      .dout(exx_act_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex0_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX0]),
      .mpw1_b(mpw1_dc_b[DEX0]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex0_val_offset : ex0_val_offset + `THREADS-1]),
      .scout(sov[ex0_val_offset : ex0_val_offset + `THREADS-1]),
      .din(rv2_val),
      .dout(ex0_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_val_offset : ex1_val_offset + `THREADS-1]),
      .scout(sov[ex1_val_offset : ex1_val_offset + `THREADS-1]),
      .din(ex0_val),
      .dout(ex1_val_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_aspr_act_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex1_aspr_act_offset]),
      .scout(sov[ex1_aspr_act_offset]),
      .din(ex1_aspr_act_d),
      .dout(ex1_aspr_act_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_aspr_tid_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_aspr_tid_offset : ex1_aspr_tid_offset + 2-1]),
      .scout(sov[ex1_aspr_tid_offset : ex1_aspr_tid_offset + 2-1]),
      .din(ex1_aspr_tid_d),
      .dout(ex1_aspr_tid_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_tid_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_tid_offset : ex1_tid_offset + 2-1]),
      .scout(sov[ex1_tid_offset : ex1_tid_offset + 2-1]),
      .din(ex0_tid),
      .dout(ex1_tid_q)
   );
   tri_rlmreg_p #(.WIDTH(32), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_instr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_instr_offset : ex1_instr_offset + 32-1]),
      .scout(sov[ex1_instr_offset : ex1_instr_offset + 32-1]),
      .din(rv_xu_ex0_instr),
      .dout(ex1_instr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_msr_gs_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex1_msr_gs_offset]),
      .scout(sov[ex1_msr_gs_offset]),
      .din(ex1_msr_gs_d),
      .dout(ex1_msr_gs_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_val_offset : ex2_val_offset + `THREADS-1]),
      .scout(sov[ex2_val_offset : ex2_val_offset + `THREADS-1]),
      .din(ex1_val),
      .dout(ex2_val_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_val_rd_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_val_rd_offset]),
      .scout(sov[ex2_val_rd_offset]),
      .din(ex2_val_rd_d),
      .dout(ex2_val_rd_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_val_wr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_val_wr_offset]),
      .scout(sov[ex2_val_wr_offset]),
      .din(ex2_val_wr_d),
      .dout(ex2_val_wr_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_tid_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_tid_offset : ex2_tid_offset + 2-1]),
      .scout(sov[ex2_tid_offset : ex2_tid_offset + 2-1]),
      .din(ex1_tid_q),
      .dout(ex2_tid_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_aspr_addr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_aspr_addr_offset : ex2_aspr_addr_offset + 4-1]),
      .scout(sov[ex2_aspr_addr_offset : ex2_aspr_addr_offset + 4-1]),
      .din(ex1_aspr_addr),
      .dout(ex2_aspr_addr_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_is_mfspr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_mfspr_offset]),
      .scout(sov[ex2_is_mfspr_offset]),
      .din(ex1_is_mfspr),
      .dout(ex2_is_mfspr_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_is_mftb_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_mftb_offset]),
      .scout(sov[ex2_is_mftb_offset]),
      .din(ex1_is_mftb),
      .dout(ex2_is_mftb_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_is_mtmsr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_mtmsr_offset]),
      .scout(sov[ex2_is_mtmsr_offset]),
      .din(ex2_is_mtmsr_d),
      .dout(ex2_is_mtmsr_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_is_mtspr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_mtspr_offset]),
      .scout(sov[ex2_is_mtspr_offset]),
      .din(ex1_is_mtspr),
      .dout(ex2_is_mtspr_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_is_wait_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_wait_offset]),
      .scout(sov[ex2_is_wait_offset]),
      .din(ex1_is_wait),
      .dout(ex2_is_wait_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_priv_instr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_priv_instr_offset]),
      .scout(sov[ex2_priv_instr_offset]),
      .din(ex1_priv_instr),
      .dout(ex2_priv_instr_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_hypv_instr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_hypv_instr_offset]),
      .scout(sov[ex2_hypv_instr_offset]),
      .din(ex1_hypv_instr),
      .dout(ex2_hypv_instr_q)
   );
   tri_regk #(.WIDTH(2), .OFFSET(9),.INIT(0), .NEEDS_SRESET(1)) ex2_wait_wc_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_wait_wc_offset : ex2_wait_wc_offset + 2-1]),
      .scout(sov[ex2_wait_wc_offset : ex2_wait_wc_offset + 2-1]),
      .din(ex1_instr_q[9:10]),
      .dout(ex2_wait_wc_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_is_msgclr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_msgclr_offset]),
      .scout(sov[ex2_is_msgclr_offset]),
      .din(ex1_is_msgclr),
      .dout(ex2_is_msgclr_q)
   );
   tri_regk #(.WIDTH(10), .OFFSET(11),.INIT(0), .NEEDS_SRESET(1)) ex2_instr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_instr_offset : ex2_instr_offset + 10-1]),
      .scout(sov[ex2_instr_offset : ex2_instr_offset + 10-1]),
      .din(ex2_instr_d),
      .dout(ex2_instr_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_msr_gs_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_msr_gs_offset]),
      .scout(sov[ex2_msr_gs_offset]),
      .din(ex1_msr_gs_q),
      .dout(ex2_msr_gs_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_tenc_we_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_tenc_we_offset]),
      .scout(sov[ex2_tenc_we_offset]),
      .din(ex1_tenc_we),
      .dout(ex2_tenc_we_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_ccr0_we_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ccr0_we_offset]),
      .scout(sov[ex2_ccr0_we_offset]),
      .din(ex1_ccr0_we),
      .dout(ex2_ccr0_we_q)
   );
   tri_regk #(.WIDTH(`GPR_WIDTH/32), .OFFSET(2-`GPR_WIDTH/32),.INIT(0), .NEEDS_SRESET(1)) ex2_aspr_re_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_aspr_re_offset : ex2_aspr_re_offset + `GPR_WIDTH/32-1]),
      .scout(sov[ex2_aspr_re_offset : ex2_aspr_re_offset + `GPR_WIDTH/32-1]),
      .din(ex1_aspr_re),
      .dout(ex2_aspr_re_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_dnh_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_dnh_offset]),
      .scout(sov[ex2_dnh_offset]),
      .din(ex1_dnh),
      .dout(ex2_dnh_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_val_offset : ex3_val_offset + `THREADS-1]),
      .scout(sov[ex3_val_offset : ex3_val_offset + `THREADS-1]),
      .din(ex2_val),
      .dout(ex3_val_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_val_rd_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_val_rd_offset]),
      .scout(sov[ex3_val_rd_offset]),
      .din(ex3_val_rd_d),
      .dout(ex3_val_rd_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_sspr_wr_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_sspr_wr_val_offset]),
      .scout(sov[ex3_sspr_wr_val_offset]),
      .din(ex2_sspr_wr_val),
      .dout(ex3_sspr_wr_val_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_sspr_rd_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_sspr_rd_val_offset]),
      .scout(sov[ex3_sspr_rd_val_offset]),
      .din(ex2_sspr_rd_val),
      .dout(ex3_sspr_rd_val_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_spr_we_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_spr_we_offset]),
      .scout(sov[ex3_spr_we_offset]),
      .din(ex3_spr_we_d),
      .dout(ex3_spr_we_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_aspr_we_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_aspr_we_offset]),
      .scout(sov[ex3_aspr_we_offset]),
      .din(ex3_aspr_we_d),
      .dout(ex3_aspr_we_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_aspr_addr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex2_aspr_addr_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_aspr_addr_offset : ex3_aspr_addr_offset + 4-1]),
      .scout(sov[ex3_aspr_addr_offset : ex3_aspr_addr_offset + 4-1]),
      .din(ex3_aspr_addr_d),
      .dout(ex3_aspr_addr_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_tid_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_tid_offset : ex3_tid_offset + 2-1]),
      .scout(sov[ex3_tid_offset : ex3_tid_offset + 2-1]),
      .din(ex2_tid_q),
      .dout(ex3_tid_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH+8), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex3_aspr_rdata_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act_data[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_aspr_rdata_offset : ex3_aspr_rdata_offset + `GPR_WIDTH+8-1]),
      .scout(sov[ex3_aspr_rdata_offset : ex3_aspr_rdata_offset + `GPR_WIDTH+8-1]),
      .din(ex3_aspr_rdata_d),
      .dout(ex3_aspr_rdata_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_is_mtspr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_is_mtspr_offset]),
      .scout(sov[ex3_is_mtspr_offset]),
      .din(ex2_is_mtspr_q),
      .dout(ex3_is_mtspr_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(9),.INIT(0), .NEEDS_SRESET(1)) ex3_wait_wc_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_wait_wc_offset : ex3_wait_wc_offset + 2-1]),
      .scout(sov[ex3_wait_wc_offset : ex3_wait_wc_offset + 2-1]),
      .din(ex2_wait_wc_q),
      .dout(ex3_wait_wc_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_is_msgclr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_is_msgclr_offset]),
      .scout(sov[ex3_is_msgclr_offset]),
      .din(ex2_is_msgclr_q),
      .dout(ex3_is_msgclr_q)
   );
   tri_rlmreg_p #(.WIDTH(10), .OFFSET(11),.INIT(0), .NEEDS_SRESET(1)) ex3_instr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_instr_offset : ex3_instr_offset + 10-1]),
      .scout(sov[ex3_instr_offset : ex3_instr_offset + 10-1]),
      .din(ex3_instr_d),
      .dout(ex3_instr_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex3_cspr_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act_data[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_cspr_rt_offset : ex3_cspr_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[ex3_cspr_rt_offset : ex3_cspr_rt_offset + `GPR_WIDTH-1]),
      .din(ex2_cspr_rt),
      .dout(ex3_cspr_rt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_hypv_spr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_hypv_spr_offset]),
      .scout(sov[ex3_hypv_spr_offset]),
      .din(ex3_hypv_spr_d),
      .dout(ex3_hypv_spr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_illeg_spr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_illeg_spr_offset]),
      .scout(sov[ex3_illeg_spr_offset]),
      .din(ex3_illeg_spr_d),
      .dout(ex3_illeg_spr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_priv_spr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_priv_spr_offset]),
      .scout(sov[ex3_priv_spr_offset]),
      .din(ex3_priv_spr_d),
      .dout(ex3_priv_spr_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH+8), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex3_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex3_rt_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_rt_offset : ex3_rt_offset + `GPR_WIDTH+8-1]),
      .scout(sov[ex3_rt_offset : ex3_rt_offset + `GPR_WIDTH+8-1]),
      .din(ex3_rt_d),
      .dout(ex3_rt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_wait_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_wait_offset]),
      .scout(sov[ex3_wait_offset]),
      .din(ex2_is_wait_q),
      .dout(ex3_wait_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_aspr_ce_addr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_aspr_ce_addr_offset : ex3_aspr_ce_addr_offset + 4-1]),
      .scout(sov[ex3_aspr_ce_addr_offset : ex3_aspr_ce_addr_offset + 4-1]),
      .din(ex2_aspr_addr_q),
      .dout(ex3_aspr_ce_addr_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH/32), .OFFSET(2-`GPR_WIDTH/32),.INIT(0), .NEEDS_SRESET(1)) ex3_aspr_re_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_aspr_re_offset : ex3_aspr_re_offset + `GPR_WIDTH/32-1]),
      .scout(sov[ex3_aspr_re_offset : ex3_aspr_re_offset + `GPR_WIDTH/32-1]),
      .din(ex2_aspr_re_q),
      .dout(ex3_aspr_re_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_val_offset : ex4_val_offset + `THREADS-1]),
      .scout(sov[ex4_val_offset : ex4_val_offset + `THREADS-1]),
      .din(ex3_val),
      .dout(ex4_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH/32), .OFFSET(2-`GPR_WIDTH/32),.INIT(0), .NEEDS_SRESET(1)) ex4_aspr_re_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_aspr_re_offset : ex4_aspr_re_offset + `GPR_WIDTH/32-1]),
      .scout(sov[ex4_aspr_re_offset : ex4_aspr_re_offset + `GPR_WIDTH/32-1]),
      .din(ex3_aspr_re_q),
      .dout(ex4_aspr_re_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex4_spr_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act_data[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_spr_rt_offset : ex4_spr_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[ex4_spr_rt_offset : ex4_spr_rt_offset + `GPR_WIDTH-1]),
      .din(ex3_spr_rt),
      .dout(ex4_spr_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex4_corr_rdata_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act_data[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_corr_rdata_offset : ex4_corr_rdata_offset + `GPR_WIDTH-1]),
      .scout(sov[ex4_corr_rdata_offset : ex4_corr_rdata_offset + `GPR_WIDTH-1]),
      .din(ex3_corr_rdata),
      .dout(ex4_corr_rdata_q)
   );
   tri_regk #(.WIDTH(`GPR_WIDTH/8+1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_sprg_ce_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_sprg_ce_offset : ex4_sprg_ce_offset + `GPR_WIDTH/8+1-1]),
      .scout(sov[ex4_sprg_ce_offset : ex4_sprg_ce_offset + `GPR_WIDTH/8+1-1]),
      .din(ex4_sprg_ce_d),
      .dout(ex4_sprg_ce_q)
   );
   tri_regk #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_aspr_ce_addr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex3_sprg_ce),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_aspr_ce_addr_offset : ex4_aspr_ce_addr_offset + 4-1]),
      .scout(sov[ex4_aspr_ce_addr_offset : ex4_aspr_ce_addr_offset + 4-1]),
      .din(ex3_aspr_ce_addr_q),
      .dout(ex4_aspr_ce_addr_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_hypv_spr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_hypv_spr_offset]),
      .scout(sov[ex4_hypv_spr_offset]),
      .din(ex3_hypv_spr_q),
      .dout(ex4_hypv_spr_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_illeg_spr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_illeg_spr_offset]),
      .scout(sov[ex4_illeg_spr_offset]),
      .din(ex3_illeg_spr_q),
      .dout(ex4_illeg_spr_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_priv_spr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_priv_spr_offset]),
      .scout(sov[ex4_priv_spr_offset]),
      .din(ex3_priv_spr_q),
      .dout(ex4_priv_spr_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_np1_flush_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_np1_flush_offset]),
      .scout(sov[ex4_np1_flush_offset]),
      .din(ex4_np1_flush_d),
      .dout(ex4_np1_flush_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex5_sprg_ce_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_sprg_ce_offset : ex5_sprg_ce_offset + `THREADS-1]),
      .scout(sov[ex5_sprg_ce_offset : ex5_sprg_ce_offset + `THREADS-1]),
      .din(ex4_sprg_ce),
      .dout(ex5_sprg_ce_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_sprg_ue_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_sprg_ue_offset]),
      .scout(sov[ex4_sprg_ue_offset]),
      .din(ex4_sprg_ue_d),
      .dout(ex4_sprg_ue_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex5_sprg_ue_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_sprg_ue_offset : ex5_sprg_ue_offset + `THREADS-1]),
      .scout(sov[ex5_sprg_ue_offset : ex5_sprg_ue_offset + `THREADS-1]),
      .din(ex4_sprg_ue),
      .dout(ex5_sprg_ue_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) cpl_dbell_taken_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[cpl_dbell_taken_offset : cpl_dbell_taken_offset + `THREADS-1]),
      .scout(sov[cpl_dbell_taken_offset : cpl_dbell_taken_offset + `THREADS-1]),
      .din(iu_xu_dbell_taken),
      .dout(cpl_dbell_taken_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) cpl_cdbell_taken_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[cpl_cdbell_taken_offset : cpl_cdbell_taken_offset + `THREADS-1]),
      .scout(sov[cpl_cdbell_taken_offset : cpl_cdbell_taken_offset + `THREADS-1]),
      .din(iu_xu_cdbell_taken),
      .dout(cpl_cdbell_taken_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) cpl_gdbell_taken_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[cpl_gdbell_taken_offset : cpl_gdbell_taken_offset + `THREADS-1]),
      .scout(sov[cpl_gdbell_taken_offset : cpl_gdbell_taken_offset + `THREADS-1]),
      .din(iu_xu_gdbell_taken),
      .dout(cpl_gdbell_taken_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) cpl_gcdbell_taken_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[cpl_gcdbell_taken_offset : cpl_gcdbell_taken_offset + `THREADS-1]),
      .scout(sov[cpl_gcdbell_taken_offset : cpl_gcdbell_taken_offset + `THREADS-1]),
      .din(iu_xu_gcdbell_taken),
      .dout(cpl_gcdbell_taken_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) cpl_gmcdbell_taken_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[cpl_gmcdbell_taken_offset : cpl_gmcdbell_taken_offset + `THREADS-1]),
      .scout(sov[cpl_gmcdbell_taken_offset : cpl_gmcdbell_taken_offset + `THREADS-1]),
      .din(iu_xu_gmcdbell_taken),
      .dout(cpl_gmcdbell_taken_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) set_xucr0_cslc_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[set_xucr0_cslc_offset]),
      .scout(sov[set_xucr0_cslc_offset]),
      .din(set_xucr0_cslc_d),
      .dout(set_xucr0_cslc_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) set_xucr0_cul_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[set_xucr0_cul_offset]),
      .scout(sov[set_xucr0_cul_offset]),
      .din(set_xucr0_cul_d),
      .dout(set_xucr0_cul_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) set_xucr0_clo_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[set_xucr0_clo_offset]),
      .scout(sov[set_xucr0_clo_offset]),
      .din(set_xucr0_clo_d),
      .dout(set_xucr0_clo_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_np1_flush_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_np1_flush_offset]),
      .scout(sov[ex3_np1_flush_offset]),
      .din(ex3_np1_flush_d),
      .dout(ex3_np1_flush_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) running_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[running_offset : running_offset + `THREADS-1]),
      .scout(sov[running_offset : running_offset + `THREADS-1]),
      .din(running_d),
      .dout(running_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(2**(`THREADS-1)), .NEEDS_SRESET(1)) llpri_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(llpri_inc),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[llpri_offset : llpri_offset + `THREADS-1]),
      .scout(sov[llpri_offset : llpri_offset + `THREADS-1]),
      .din(llpri_d),
      .dout(llpri_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) dec_dbg_dis_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[dec_dbg_dis_offset : dec_dbg_dis_offset + `THREADS-1]),
      .scout(sov[dec_dbg_dis_offset : dec_dbg_dis_offset + `THREADS-1]),
      .din(dec_dbg_dis_d),
      .dout(dec_dbg_dis_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tb_dbg_dis_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[tb_dbg_dis_offset]),
      .scout(sov[tb_dbg_dis_offset]),
      .din(tb_dbg_dis_d),
      .dout(tb_dbg_dis_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tb_act_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[tb_act_offset]),
      .scout(sov[tb_act_offset]),
      .din(tb_act_d),
      .dout(tb_act_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ext_dbg_dis_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ext_dbg_dis_offset : ext_dbg_dis_offset + `THREADS-1]),
      .scout(sov[ext_dbg_dis_offset : ext_dbg_dis_offset + `THREADS-1]),
      .din(ext_dbg_dis_d),
      .dout(ext_dbg_dis_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) msrovride_enab_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[msrovride_enab_offset]),
      .scout(sov[msrovride_enab_offset]),
      .din(pc_xu_msrovride_enab),
      .dout(msrovride_enab_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) waitimpl_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[waitimpl_val_offset : waitimpl_val_offset + `THREADS-1]),
      .scout(sov[waitimpl_val_offset : waitimpl_val_offset + `THREADS-1]),
      .din(waitimpl_val_d),
      .dout(waitimpl_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) waitrsv_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[waitrsv_val_offset : waitrsv_val_offset + `THREADS-1]),
      .scout(sov[waitrsv_val_offset : waitrsv_val_offset + `THREADS-1]),
      .din(waitrsv_val_d),
      .dout(waitrsv_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) an_ac_reservation_vld_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[an_ac_reservation_vld_offset : an_ac_reservation_vld_offset + `THREADS-1]),
      .scout(sov[an_ac_reservation_vld_offset : an_ac_reservation_vld_offset + `THREADS-1]),
      .din(an_ac_reservation_vld),
      .dout(an_ac_reservation_vld_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) an_ac_sleep_en_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[an_ac_sleep_en_offset : an_ac_sleep_en_offset + `THREADS-1]),
      .scout(sov[an_ac_sleep_en_offset : an_ac_sleep_en_offset + `THREADS-1]),
      .din(an_ac_sleep_en),
      .dout(an_ac_sleep_en_q)
   );
   tri_rlmreg_p #(.WIDTH(8), .OFFSET(54),.INIT(0), .NEEDS_SRESET(1)) an_ac_coreid_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[an_ac_coreid_offset : an_ac_coreid_offset + 8-1]),
      .scout(sov[an_ac_coreid_offset : an_ac_coreid_offset + 8-1]),
      .din(an_ac_coreid),
      .dout(an_ac_coreid_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tb_update_enable_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[tb_update_enable_offset]),
      .scout(sov[tb_update_enable_offset]),
      .din(an_ac_tb_update_enable),
      .dout(tb_update_enable_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tb_update_pulse_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[tb_update_pulse_offset]),
      .scout(sov[tb_update_pulse_offset]),
      .din(an_ac_tb_update_pulse),
      .dout(tb_update_pulse_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tb_update_pulse_1_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[tb_update_pulse_1_offset]),
      .scout(sov[tb_update_pulse_1_offset]),
      .din(tb_update_pulse_q),
      .dout(tb_update_pulse_1_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_xu_reset_wd_complete_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[pc_xu_reset_wd_complete_offset]),
      .scout(sov[pc_xu_reset_wd_complete_offset]),
      .din(pc_xu_reset_wd_complete),
      .dout(pc_xu_reset_wd_complete_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_xu_reset_3_complete_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[pc_xu_reset_3_complete_offset]),
      .scout(sov[pc_xu_reset_3_complete_offset]),
      .din(pc_xu_reset_3_complete),
      .dout(pc_xu_reset_3_complete_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_xu_reset_2_complete_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[pc_xu_reset_2_complete_offset]),
      .scout(sov[pc_xu_reset_2_complete_offset]),
      .din(pc_xu_reset_2_complete),
      .dout(pc_xu_reset_2_complete_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_xu_reset_1_complete_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[pc_xu_reset_1_complete_offset]),
      .scout(sov[pc_xu_reset_1_complete_offset]),
      .din(pc_xu_reset_1_complete),
      .dout(pc_xu_reset_1_complete_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq_xu_dbell_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[lq_xu_dbell_val_offset]),
      .scout(sov[lq_xu_dbell_val_offset]),
      .din(lq_xu_dbell_val),
      .dout(lq_xu_dbell_val_q)
   );
   tri_rlmreg_p #(.WIDTH(5), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) lq_xu_dbell_type_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[lq_xu_dbell_type_offset : lq_xu_dbell_type_offset + 5-1]),
      .scout(sov[lq_xu_dbell_type_offset : lq_xu_dbell_type_offset + 5-1]),
      .din(lq_xu_dbell_type),
      .dout(lq_xu_dbell_type_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq_xu_dbell_brdcast_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[lq_xu_dbell_brdcast_offset]),
      .scout(sov[lq_xu_dbell_brdcast_offset]),
      .din(lq_xu_dbell_brdcast),
      .dout(lq_xu_dbell_brdcast_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq_xu_dbell_lpid_match_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[lq_xu_dbell_lpid_match_offset]),
      .scout(sov[lq_xu_dbell_lpid_match_offset]),
      .din(lq_xu_dbell_lpid_match),
      .dout(lq_xu_dbell_lpid_match_q)
   );
   tri_rlmreg_p #(.WIDTH(14), .OFFSET(50),.INIT(0), .NEEDS_SRESET(1)) lq_xu_dbell_pirtag_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[lq_xu_dbell_pirtag_offset : lq_xu_dbell_pirtag_offset + 14-1]),
      .scout(sov[lq_xu_dbell_pirtag_offset : lq_xu_dbell_pirtag_offset + 14-1]),
      .din(lq_xu_dbell_pirtag),
      .dout(lq_xu_dbell_pirtag_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) dbell_present_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[dbell_present_offset : dbell_present_offset + `THREADS-1]),
      .scout(sov[dbell_present_offset : dbell_present_offset + `THREADS-1]),
      .din(dbell_present_d),
      .dout(dbell_present_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) cdbell_present_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[cdbell_present_offset : cdbell_present_offset + `THREADS-1]),
      .scout(sov[cdbell_present_offset : cdbell_present_offset + `THREADS-1]),
      .din(cdbell_present_d),
      .dout(cdbell_present_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) gdbell_present_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[gdbell_present_offset : gdbell_present_offset + `THREADS-1]),
      .scout(sov[gdbell_present_offset : gdbell_present_offset + `THREADS-1]),
      .din(gdbell_present_d),
      .dout(gdbell_present_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) gcdbell_present_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[gcdbell_present_offset : gcdbell_present_offset + `THREADS-1]),
      .scout(sov[gcdbell_present_offset : gcdbell_present_offset + `THREADS-1]),
      .din(gcdbell_present_d),
      .dout(gcdbell_present_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) gmcdbell_present_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[gmcdbell_present_offset : gmcdbell_present_offset + `THREADS-1]),
      .scout(sov[gmcdbell_present_offset : gmcdbell_present_offset + `THREADS-1]),
      .din(gmcdbell_present_d),
      .dout(gmcdbell_present_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xucr0_clfc_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[xucr0_clfc_offset]),
      .scout(sov[xucr0_clfc_offset]),
      .din(xucr0_clfc_d),
      .dout(xucr0_clfc_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) iu_run_thread_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[iu_run_thread_offset : iu_run_thread_offset + `THREADS-1]),
      .scout(sov[iu_run_thread_offset : iu_run_thread_offset + `THREADS-1]),
      .din(iu_run_thread_d),
      .dout(iu_run_thread_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) inj_sprg_ecc_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[inj_sprg_ecc_offset : inj_sprg_ecc_offset + `THREADS-1]),
      .scout(sov[inj_sprg_ecc_offset : inj_sprg_ecc_offset + `THREADS-1]),
      .din(pc_xu_inj_sprg_ecc),
      .dout(inj_sprg_ecc_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) dbell_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[dbell_interrupt_offset : dbell_interrupt_offset + `THREADS-1]),
      .scout(sov[dbell_interrupt_offset : dbell_interrupt_offset + `THREADS-1]),
      .din(dbell_interrupt),
      .dout(dbell_interrupt_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) cdbell_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[cdbell_interrupt_offset : cdbell_interrupt_offset + `THREADS-1]),
      .scout(sov[cdbell_interrupt_offset : cdbell_interrupt_offset + `THREADS-1]),
      .din(cdbell_interrupt),
      .dout(cdbell_interrupt_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) gdbell_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[gdbell_interrupt_offset : gdbell_interrupt_offset + `THREADS-1]),
      .scout(sov[gdbell_interrupt_offset : gdbell_interrupt_offset + `THREADS-1]),
      .din(gdbell_interrupt),
      .dout(gdbell_interrupt_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) gcdbell_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[gcdbell_interrupt_offset : gcdbell_interrupt_offset + `THREADS-1]),
      .scout(sov[gcdbell_interrupt_offset : gcdbell_interrupt_offset + `THREADS-1]),
      .din(gcdbell_interrupt),
      .dout(gcdbell_interrupt_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) gmcdbell_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[gmcdbell_interrupt_offset : gmcdbell_interrupt_offset + `THREADS-1]),
      .scout(sov[gmcdbell_interrupt_offset : gmcdbell_interrupt_offset + `THREADS-1]),
      .din(gmcdbell_interrupt),
      .dout(gmcdbell_interrupt_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) iu_quiesce_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[iu_quiesce_offset : iu_quiesce_offset + `THREADS-1]),
      .scout(sov[iu_quiesce_offset : iu_quiesce_offset + `THREADS-1]),
      .din(iu_xu_quiesce),
      .dout(iu_quiesce_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) iu_icache_quiesce_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[iu_icache_quiesce_offset : iu_icache_quiesce_offset + `THREADS-1]),
      .scout(sov[iu_icache_quiesce_offset : iu_icache_quiesce_offset + `THREADS-1]),
      .din(iu_xu_icache_quiesce),
      .dout(iu_icache_quiesce_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) lsu_quiesce_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[lsu_quiesce_offset : lsu_quiesce_offset + `THREADS-1]),
      .scout(sov[lsu_quiesce_offset : lsu_quiesce_offset + `THREADS-1]),
      .din(lq_xu_quiesce),
      .dout(lsu_quiesce_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) mm_quiesce_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[mm_quiesce_offset : mm_quiesce_offset + `THREADS-1]),
      .scout(sov[mm_quiesce_offset : mm_quiesce_offset + `THREADS-1]),
      .din(mm_xu_quiesce),
      .dout(mm_quiesce_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) bx_quiesce_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[bx_quiesce_offset : bx_quiesce_offset + `THREADS-1]),
      .scout(sov[bx_quiesce_offset : bx_quiesce_offset + `THREADS-1]),
      .din(bx_xu_quiesce),
      .dout(bx_quiesce_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) quiesce_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[quiesce_offset : quiesce_offset + `THREADS-1]),
      .scout(sov[quiesce_offset : quiesce_offset + `THREADS-1]),
      .din(quiesce_d),
      .dout(quiesce_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) quiesced_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[quiesced_offset : quiesced_offset + `THREADS-1]),
      .scout(sov[quiesced_offset : quiesced_offset + `THREADS-1]),
      .din(quiesced_d),
      .dout(quiesced_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) instr_trace_mode_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[instr_trace_mode_offset]),
      .scout(sov[instr_trace_mode_offset]),
      .din(pc_xu_instr_trace_mode),
      .dout(instr_trace_mode_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) instr_trace_tid_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[instr_trace_tid_offset : instr_trace_tid_offset + 2-1]),
      .scout(sov[instr_trace_tid_offset : instr_trace_tid_offset + 2-1]),
      .din(pc_xu_instr_trace_tid),
      .dout(instr_trace_tid_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) timer_update_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[timer_update_offset]),
      .scout(sov[timer_update_offset]),
      .din(timer_update_int),
      .dout(timer_update_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xu_ord_read_done_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[spr_xu_ord_read_done_offset]),
      .scout(sov[spr_xu_ord_read_done_offset]),
      .din(spr_xu_ord_read_done_d),
      .dout(spr_xu_ord_read_done_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xu_ord_write_done_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[spr_xu_ord_write_done_offset]),
      .scout(sov[spr_xu_ord_write_done_offset]),
      .din(spr_xu_ord_write_done_d),
      .dout(spr_xu_ord_write_done_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_spr_ord_ready_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[xu_spr_ord_ready_offset]),
      .scout(sov[xu_spr_ord_ready_offset]),
      .din(xu_spr_ord_ready),
      .dout(xu_spr_ord_ready_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_sspr_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_sspr_val_offset]),
      .scout(sov[ex4_sspr_val_offset]),
      .din(ex3_sspr_val),
      .dout(ex4_sspr_val_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) flush_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[flush_offset : flush_offset + `THREADS-1]),
      .scout(sov[flush_offset : flush_offset + `THREADS-1]),
      .din(flush),
      .dout(flush_q)
   );
   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .OFFSET(62-`EFF_IFAR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex1_ifar_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_ifar_offset : ex1_ifar_offset + `EFF_IFAR_WIDTH-1]),
      .scout(sov[ex1_ifar_offset : ex1_ifar_offset + `EFF_IFAR_WIDTH-1]),
      .din(rv_xu_ex0_ifar),
      .dout(ex1_ifar_q)
   );
   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .OFFSET(62-`EFF_IFAR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex2_ifar_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_ifar_offset : ex2_ifar_offset + `EFF_IFAR_WIDTH-1]),
      .scout(sov[ex2_ifar_offset : ex2_ifar_offset + `EFF_IFAR_WIDTH-1]),
      .din(ex1_ifar_q),
      .dout(ex2_ifar_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ram_active_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ram_active_offset : ram_active_offset + `THREADS-1]),
      .scout(sov[ram_active_offset : ram_active_offset + `THREADS-1]),
      .din(pc_xu_ram_active),
      .dout(ram_active_q)
   );
   tri_rlmreg_p #(.WIDTH(5), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) timer_div_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(timer_div_act),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[timer_div_offset : timer_div_offset + 5-1]),
      .scout(sov[timer_div_offset : timer_div_offset + 5-1]),
      .din(timer_div_d),
      .dout(timer_div_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) msrovride_enab_2_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[msrovride_enab_2_offset : msrovride_enab_2_offset + `THREADS-1]),
      .scout(sov[msrovride_enab_2_offset : msrovride_enab_2_offset + `THREADS-1]),
      .din(msrovride_enab),
      .dout(msrovride_enab_2_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) msrovride_enab_3_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[msrovride_enab_3_offset : msrovride_enab_3_offset + `THREADS-1]),
      .scout(sov[msrovride_enab_3_offset : msrovride_enab_3_offset + `THREADS-1]),
      .din(msrovride_enab_2_q),
      .dout(msrovride_enab_3_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_wait_flush_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_wait_flush_offset]),
      .scout(sov[ex3_wait_flush_offset]),
      .din(ex3_wait_flush_d),
      .dout(ex3_wait_flush_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_wait_flush_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_wait_flush_offset]),
      .scout(sov[ex4_wait_flush_offset]),
      .din(ex4_wait_flush_d),
      .dout(ex4_wait_flush_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_xu_pm_hold_thread_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[pc_xu_pm_hold_thread_offset]),
      .scout(sov[pc_xu_pm_hold_thread_offset]),
      .din(pc_xu_pm_hold_thread),
      .dout(pc_xu_pm_hold_thread_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) power_savings_on_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[power_savings_on_offset]),
      .scout(sov[power_savings_on_offset]),
      .din(power_savings_on_d),
      .dout(power_savings_on_q)
   );
   tri_rlmreg_p #(.WIDTH(4*`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) perf_event_bus_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(pc_xu_event_bus_enable),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[perf_event_bus_offset : perf_event_bus_offset + 4*`THREADS-1]),
      .scout(sov[perf_event_bus_offset : perf_event_bus_offset + 4*`THREADS-1]),
      .din(perf_event_bus_d),
      .dout(perf_event_bus_q)
   );
   tri_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) perf_event_en_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(pc_xu_event_bus_enable),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[perf_event_en_offset : perf_event_en_offset + `THREADS-1]),
      .scout(sov[perf_event_en_offset : perf_event_en_offset + `THREADS-1]),
      .din(perf_event_en_d),
      .dout(perf_event_en_q)
   );


   tri_lcbnd spare_0_lcb(
      .vd(vdd),
      .gd(gnd),
      .act(1'b1),
      .nclk(nclk),
      .force_t(func_sl_force),
      .thold_b(func_sl_thold_0_b),
      .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]),
      .mpw2_b(mpw2_dc_b),
      .sg(sg_0),
      .lclk(spare_0_lclk),
      .d1clk(spare_0_d1clk),
      .d2clk(spare_0_d2clk)
   );

   tri_inv_nlats #(.WIDTH(16), .BTR("NLI0001_X2_A12TH"), .INIT(0)) spare_0_latch(
      .vd(vdd),
      .gd(gnd),
      .lclk(spare_0_lclk),
      .d1clk(spare_0_d1clk),
      .d2clk(spare_0_d2clk),
      .scanin(siv[spare_0_offset:spare_0_offset + 16 - 1]),
      .scanout(sov[spare_0_offset:spare_0_offset + 16 - 1]),
      .d(spare_0_d),
      .qb(spare_0_q)
   );
   assign spare_0_d = (~spare_0_q);

   xu_fctr #(.WIDTH(`THREADS), .PASSTHRU(0), .DELAY_WIDTH(4), .CLOCKGATE(1)) quiesced_fctr(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[quiesced_ctr_offset]),
      .scout(sov[quiesced_ctr_offset]),
      .delay(4'b1111),
      .din(quiesce_b_q),
      .dout(quiesce_ctr_zero_b)
   );


   tri_ser_rlmreg_p #(.WIDTH(`THREADS), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ccr0_we_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(bcfg_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(bcfg_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv_bcfg[ccr0_we_offset_bcfg : ccr0_we_offset_bcfg + `THREADS-1]),
      .scout(sov_bcfg[ccr0_we_offset_bcfg : ccr0_we_offset_bcfg + `THREADS-1]),
      .din(ccr0_we_d),
      .dout(ccr0_we_q)
   );



   assign siv[0:399] = {sov[1:399], scan_in[0]};
   assign scan_out[0] = sov[0];

   assign siv[400:scan_right-1] = {sov[401:scan_right-1], scan_in[1]};
   assign scan_out[1] = sov[400];

   generate
      // BCFG
      if (scan_right_bcfg > 1)
      begin : bcfg_l
         assign siv_bcfg[0:scan_right_bcfg - 1] = {sov_bcfg[1:scan_right_bcfg-1], bcfg_scan_in};
         assign bcfg_scan_out = sov_bcfg[0];
      end
      if (scan_right_bcfg == 1)
      begin : bcfg_s
         assign siv_bcfg[0] = bcfg_scan_in;
         assign bcfg_scan_out = sov_bcfg[0];
      end
      if (scan_right_bcfg == 0)
      begin : bcfg_z
         assign bcfg_scan_out = bcfg_scan_in;
      end
      // CCFG
      if (scan_right_ccfg > 1)
      begin : ccfg_l
         assign siv_ccfg[0:scan_right_ccfg - 1] = {sov_ccfg[1:scan_right_ccfg - 1], ccfg_scan_in};
         assign ccfg_scan_out = sov_ccfg[0];
      end
      if (scan_right_ccfg == 1)
      begin : ccfg_s
         assign siv_ccfg[0] = ccfg_scan_in;
         assign ccfg_scan_out = sov_ccfg[0];
      end
      if (scan_right_ccfg == 0)
      begin : ccfg_z
         assign ccfg_scan_out = ccfg_scan_in;
      end
      // DCFG
      if (scan_right_dcfg > 1)
      begin : dcfg_l
         assign siv_dcfg[0:scan_right_dcfg - 1] = {sov_dcfg[1:scan_right_dcfg - 1], dcfg_scan_in};
         assign dcfg_scan_out = sov_dcfg[0];
      end
      if (scan_right_dcfg == 1)
      begin : dcfg_s
         assign siv_dcfg[0] = dcfg_scan_in;
         assign dcfg_scan_out = sov_dcfg[0];
      end
      if (scan_right_dcfg == 0)
      begin : dcfg_z
         assign dcfg_scan_out = dcfg_scan_in;
      end
   endgenerate


   function  [0:`THREADS-1] reverse_threads;
      input [0:`THREADS-1] a;
      integer t;
   begin
      for (t=0;t<`THREADS;t=t+1)
      begin : threads_loop
         reverse_threads[t] = a[`THREADS-1-t];
      end
   end
   endfunction


endmodule
