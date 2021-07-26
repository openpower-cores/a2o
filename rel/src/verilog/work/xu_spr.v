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

//  Description:  XU SPR - Wrapper
//
//*****************************************************************************
`include "tri_a2o.vh"
module xu_spr
#(
   parameter                           hvmode = 1,
   parameter                           a2mode = 1
)(
   input  [0:`NCLK_WIDTH-1] nclk,

   // CHIP IO
   input  [54:61]                      an_ac_coreid,
   input  [32:35]                      an_ac_chipid_dc,
   input  [8:15]                       spr_pvr_version_dc,
   input  [12:15]                      spr_pvr_revision_dc,
   input  [16:19]                      spr_pvr_revision_minor_dc,
   input  [0:`THREADS-1]               an_ac_ext_interrupt,
   input  [0:`THREADS-1]               an_ac_crit_interrupt,
   input  [0:`THREADS-1]               an_ac_perf_interrupt,
   input  [0:`THREADS-1]               an_ac_reservation_vld,
   input                               an_ac_tb_update_pulse,
   input                               an_ac_tb_update_enable,
   input  [0:`THREADS-1]               an_ac_sleep_en,
   input  [0:`THREADS-1]               an_ac_hang_pulse,
   output [0:`THREADS-1]               ac_tc_machine_check,
   input  [0:`THREADS-1]               an_ac_external_mchk,
   input                               pc_xu_instr_trace_mode,
   input  [0:1]                        pc_xu_instr_trace_tid,

   input                               an_ac_scan_dis_dc_b,
   input                               an_ac_scan_diag_dc,
   input                               pc_xu_ccflush_dc,
   input                               clkoff_dc_b,
   input                               d_mode_dc,
   input                               delay_lclkr_dc,
   input                               mpw1_dc_b,
   input                               mpw2_dc_b,
   input                               func_sl_thold_2,
   input                               func_slp_sl_thold_2,
   input                               func_nsl_thold_2,
   input                               func_slp_nsl_thold_2,
   input                               cfg_sl_thold_2,
   input                               cfg_slp_sl_thold_2,
   input                               ary_nsl_thold_2,
   input                               time_sl_thold_2,
   input                               abst_sl_thold_2,
   input                               repr_sl_thold_2,
   input                               gptr_sl_thold_2,
   input                               bolt_sl_thold_2,
   input                               sg_2,
   input                               fce_2,
   input  [0:`THREADS+1]               func_scan_in,
   output [0:`THREADS+1]               func_scan_out,
   input                               bcfg_scan_in,
   output                              bcfg_scan_out,
   input                               ccfg_scan_in,
   output                              ccfg_scan_out,
   input                               dcfg_scan_in,
   output                              dcfg_scan_out,
   input                               time_scan_in,
   output                              time_scan_out,
   input                               abst_scan_in,
   output                              abst_scan_out,
   input                               repr_scan_in,
   output                              repr_scan_out,
   input                               gptr_scan_in,
   output                              gptr_scan_out,

   // Decode
   input  [0:`THREADS-1]               rv_xu_vld,
   input                               rv_xu_ex0_ord,
   input  [0:31]                       rv_xu_ex0_instr,
   input  [62-`EFF_IFAR_WIDTH:61]      rv_xu_ex0_ifar,

   output                              spr_xu_ord_read_done,
   output                              spr_xu_ord_write_done,
   input                               xu_spr_ord_ready,
   input                               xu_spr_ord_flush,
   input  [0:`THREADS-1]               cp_flush,

   // Read Data
   output [64-`GPR_WIDTH:63]           spr_xu_ex4_rd_data,

   // Write Data
   input  [64-`GPR_WIDTH:63]           xu_spr_ex2_rs1,

   // Interrupt Interface
   input  [0:`THREADS-1]               iu_xu_rfi,
   input  [0:`THREADS-1]               iu_xu_rfgi,
   input  [0:`THREADS-1]               iu_xu_rfci,
   input  [0:`THREADS-1]               iu_xu_rfmci,
   input  [0:`THREADS-1]               iu_xu_act,
   input  [0:`THREADS-1]               iu_xu_int,
   input  [0:`THREADS-1]               iu_xu_gint,
   input  [0:`THREADS-1]               iu_xu_cint,
   input  [0:`THREADS-1]               iu_xu_mcint,
   input  [0:`THREADS-1]               iu_xu_dear_update,
   input  [0:`THREADS-1]               iu_xu_dbsr_update,
   input  [0:`THREADS-1]               iu_xu_esr_update,
   input  [0:`THREADS-1]               iu_xu_force_gsrr,
   input  [0:`THREADS-1]               iu_xu_dbsr_ude,
   input  [0:`THREADS-1]               iu_xu_dbsr_ide,
   output [0:`THREADS-1]               xu_iu_dbsr_ide,

   input   [62-`EFF_IFAR_ARCH:61]      iu_xu_nia_t0,
   input   [0:16]                      iu_xu_esr_t0,
   input   [0:14]                      iu_xu_mcsr_t0,
   input   [0:18]                      iu_xu_dbsr_t0,
   input   [64-`GPR_WIDTH:63]          iu_xu_dear_t0,
   output [62-`EFF_IFAR_ARCH:61]       xu_iu_rest_ifar_t0,

   `ifndef THREADS1
   input   [62-`EFF_IFAR_ARCH:61]      iu_xu_nia_t1,
   input   [0:16]                      iu_xu_esr_t1,
   input   [0:14]                      iu_xu_mcsr_t1,
   input   [0:18]                      iu_xu_dbsr_t1,
   input   [64-`GPR_WIDTH:63]          iu_xu_dear_t1,
   output [62-`EFF_IFAR_ARCH:61]       xu_iu_rest_ifar_t1,
   `endif

   // Async Interrupt Req Interface
   output [0:`THREADS-1]               xu_iu_external_mchk,
   output [0:`THREADS-1]               xu_iu_ext_interrupt,
   output [0:`THREADS-1]               xu_iu_dec_interrupt,
   output [0:`THREADS-1]               xu_iu_udec_interrupt,
   output [0:`THREADS-1]               xu_iu_perf_interrupt,
   output [0:`THREADS-1]               xu_iu_fit_interrupt,
   output [0:`THREADS-1]               xu_iu_crit_interrupt,
   output [0:`THREADS-1]               xu_iu_wdog_interrupt,
   output [0:`THREADS-1]               xu_iu_gwdog_interrupt,
   output [0:`THREADS-1]               xu_iu_gfit_interrupt,
   output [0:`THREADS-1]               xu_iu_gdec_interrupt,
   output [0:`THREADS-1]               xu_iu_dbell_interrupt,
   output [0:`THREADS-1]               xu_iu_cdbell_interrupt,
   output [0:`THREADS-1]               xu_iu_gdbell_interrupt,
   output [0:`THREADS-1]               xu_iu_gcdbell_interrupt,
   output [0:`THREADS-1]               xu_iu_gmcdbell_interrupt,
   input  [0:`THREADS-1]               iu_xu_dbell_taken,
   input  [0:`THREADS-1]               iu_xu_cdbell_taken,
   input  [0:`THREADS-1]               iu_xu_gdbell_taken,
   input  [0:`THREADS-1]               iu_xu_gcdbell_taken,
   input  [0:`THREADS-1]               iu_xu_gmcdbell_taken,

   // DBELL Int
   input                               lq_xu_dbell_val,
   input  [0:4]                        lq_xu_dbell_type,
   input                               lq_xu_dbell_brdcast,
   input                               lq_xu_dbell_lpid_match,
   input  [50:63]                      lq_xu_dbell_pirtag,

   // Slow SPR Bus
   output                              xu_slowspr_val_out,
   output                              xu_slowspr_rw_out,
   output [0:1]                        xu_slowspr_etid_out,
   output [11:20]                      xu_slowspr_addr_out,
   output [64-`GPR_WIDTH:63]           xu_slowspr_data_out,

   // DCR Bus
   output                              ac_an_dcr_act,
   output                              ac_an_dcr_val,
   output                              ac_an_dcr_read,
   output                              ac_an_dcr_user,
   output [0:1]                        ac_an_dcr_etid,
   output [11:20]                      ac_an_dcr_addr,
   output [64-`GPR_WIDTH:63]           ac_an_dcr_data,

   // Trap
   output [0:`THREADS-1]               xu_iu_fp_precise,
   output                              spr_dec_ex4_spr_hypv,
   output                              spr_dec_ex4_spr_illeg,
   output                              spr_dec_ex4_spr_priv,
   output                              spr_dec_ex4_np1_flush,

   // Run State
   input                               pc_xu_pm_hold_thread,
   input  [0:`THREADS-1]               iu_xu_stop,
   output [0:`THREADS-1]               xu_pc_running,
   output [0:`THREADS-1]               xu_iu_run_thread,
   output [0:`THREADS-1]               xu_iu_single_instr_mode,
   output [0:`THREADS-1]               xu_iu_raise_iss_pri,
   output [0:`THREADS-1]               xu_pc_spr_ccr0_we,
   output [0:1]                        xu_pc_spr_ccr0_pme,
   output [0:`THREADS-1]               xu_pc_stop_dnh_instr,

   // Quiesce
   input  [0:`THREADS-1]               iu_xu_quiesce,
   input  [0:`THREADS-1]               iu_xu_icache_quiesce,
   input  [0:`THREADS-1]               lq_xu_quiesce,
   input  [0:`THREADS-1]               mm_xu_quiesce,
   input  [0:`THREADS-1]               bx_xu_quiesce,

   // PCCR0
   input                               pc_xu_extirpts_dis_on_stop,
   input                               pc_xu_timebase_dis_on_stop,
   input                               pc_xu_decrem_dis_on_stop,

   // PERF
   input [0:2]                         pc_xu_event_count_mode,
   input                               pc_xu_event_bus_enable,
   input  [0:4*`THREADS-1]             xu_event_bus_in,
   output [0:4*`THREADS-1]             xu_event_bus_out,
   input [0:`THREADS-1]                div_spr_running,
   input [0:`THREADS-1]                mul_spr_running,

   // MSR Override
   input  [0:`THREADS-1]               pc_xu_ram_active,
   input                               pc_xu_msrovride_enab,
   input                               pc_xu_msrovride_pr,
   input                               pc_xu_msrovride_gs,
   input                               pc_xu_msrovride_de,

   // SIAR
   input  [0:`THREADS-1]               pc_xu_spr_cesr1_pmae,
   output [0:`THREADS-1]               xu_pc_perfmon_alert,


   // LiveLock
   input  [0:`THREADS-1]               iu_xu_instr_cpl,
   output [0:`THREADS-1]               xu_pc_err_llbust_attempt,
   output [0:`THREADS-1]               xu_pc_err_llbust_failed,

   // Resets
   input                               pc_xu_reset_wd_complete,
   input                               pc_xu_reset_1_complete,
   input                               pc_xu_reset_2_complete,
   input                               pc_xu_reset_3_complete,
   output                              ac_tc_reset_1_request,
   output                              ac_tc_reset_2_request,
   output                              ac_tc_reset_3_request,
   output                              ac_tc_reset_wd_request,

   // Err Inject
   input  [0:`THREADS-1]               pc_xu_inj_llbust_attempt,
   input  [0:`THREADS-1]               pc_xu_inj_llbust_failed,
   input  [0:`THREADS-1]               pc_xu_inj_wdt_reset,
   output [0:`THREADS-1]               xu_pc_err_wdt_reset,

   // Parity
   input  [0:`THREADS-1]               pc_xu_inj_sprg_ecc,
   output [0:`THREADS-1]               xu_pc_err_sprg_ecc,
   output [0:`THREADS-1]               xu_pc_err_sprg_ue,

   // SPRs
   output [0:`THREADS-1]               xu_iu_msrovride_enab,

   input  [0:`THREADS-1]               spr_dbcr0_edm,
   output [0:3]                        spr_xucr0_clkg_ctl,
   output [0:`THREADS-1]               xu_iu_iac1_en,
   output [0:`THREADS-1]               xu_iu_iac2_en,
   output [0:`THREADS-1]               xu_iu_iac3_en,
   output [0:`THREADS-1]               xu_iu_iac4_en,
   input                               lq_xu_spr_xucr0_cslc_xuop,
   input                               lq_xu_spr_xucr0_cslc_binv,
   input                               lq_xu_spr_xucr0_clo,
   input                               lq_xu_spr_xucr0_cul,
   output [0:`THREADS-1]               spr_epcr_extgs,
   output [0:`THREADS-1]               spr_epcr_icm,
   output [0:`THREADS-1]               spr_epcr_gicm,
   output [0:`THREADS-1]               spr_msr_de,
   output [0:`THREADS-1]               spr_msr_pr,
   output [0:`THREADS-1]               spr_msr_is,
   output [0:`THREADS-1]               spr_msr_cm,
   output [0:`THREADS-1]               spr_msr_gs,
   output [0:`THREADS-1]               spr_msr_ee,
   output [0:`THREADS-1]               spr_msr_ce,
   output [0:`THREADS-1]               spr_msr_me,
   output [0:`THREADS-1]               spr_msr_fe0,
   output [0:`THREADS-1]               spr_msr_fe1,
   output                              spr_ccr2_en_pc,
   output                              spr_ccr4_en_dnh,
   output                              xu_lsu_spr_xucr0_clfc,
   `ifndef THREADS1
   output [64-`GPR_WIDTH:63]           spr_dvc1_t1,
   output [64-`GPR_WIDTH:63]           spr_dvc2_t1,
   `endif
   output [64-`GPR_WIDTH:63]           spr_dvc1_t0,
   output [64-`GPR_WIDTH:63]           spr_dvc2_t0,
   output [0:31]                       spr_xesr1,
   output [0:31]                       spr_xesr2,
   output [0:`THREADS-1]               perf_event_en,

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
	output [0:`THREADS-1]               spr_dbcr0_idm,
	output [0:`THREADS-1]               spr_dbcr0_icmp,
	output [0:`THREADS-1]               spr_dbcr0_brt,
	output [0:`THREADS-1]               spr_dbcr0_irpt,
	output [0:`THREADS-1]               spr_dbcr0_trap,
	output [0:2*`THREADS-1]             spr_dbcr0_dac1,
	output [0:2*`THREADS-1]             spr_dbcr0_dac2,
	output [0:`THREADS-1]               spr_dbcr0_ret,
	output [0:2*`THREADS-1]             spr_dbcr0_dac3,
	output [0:2*`THREADS-1]             spr_dbcr0_dac4,
	output [0:`THREADS-1]               spr_dbcr1_iac12m,
	output [0:`THREADS-1]               spr_dbcr1_iac34m,
	output [0:`THREADS-1]               spr_epcr_dtlbgs,
	output [0:`THREADS-1]               spr_epcr_itlbgs,
	output [0:`THREADS-1]               spr_epcr_dsigs,
	output [0:`THREADS-1]               spr_epcr_isigs,
	output [0:`THREADS-1]               spr_epcr_duvd,
	output [0:`THREADS-1]               spr_epcr_dgtmi,
	output [0:`THREADS-1]               xu_mm_spr_epcr_dmiuh,
	output [0:`THREADS-1]               spr_msr_ucle,
	output [0:`THREADS-1]               spr_msr_spv,
	output [0:`THREADS-1]               spr_msr_fp,
	output [0:`THREADS-1]               spr_msr_ds,
	output [0:`THREADS-1]               spr_msrp_uclep,

   // BOLT-ON
   input                               bo_enable_2,
   input                               pc_xu_bo_reset,
   input                               pc_xu_bo_unload,
   input                               pc_xu_bo_repair,
   input                               pc_xu_bo_shdata,
   input                               pc_xu_bo_select,
   output                              xu_pc_bo_fail,
   output                              xu_pc_bo_diagout,
   // ABIST
   input                               an_ac_lbist_ary_wrt_thru_dc,
   input                               pc_xu_abist_ena_dc,
   input                               pc_xu_abist_g8t_wenb,
   input  [4:9]                        pc_xu_abist_waddr_0,
   input  [0:3]                        pc_xu_abist_di_0,
   input                               pc_xu_abist_g8t1p_renb_0,
   input  [4:9]                        pc_xu_abist_raddr_0,
   input                               pc_xu_abist_wl32_comp_ena,
   input                               pc_xu_abist_raw_dc_b,
   input  [0:3]                        pc_xu_abist_g8t_dcomp,
   input                               pc_xu_abist_g8t_bw_1,
   input                               pc_xu_abist_g8t_bw_0,

   // Debug
   input                               pc_xu_trace_bus_enable,
   input  [0:10]                       spr_debug_mux_ctrls,
   input  [0:31]             spr_debug_data_in,
   output [0:31]             spr_debug_data_out,

   // Power
   inout                               vcs,
   inout                               vdd,
   inout                               gnd
);

   wire                          reset_1_request_q,         reset_1_request_d          ;
   wire                          reset_2_request_q,         reset_2_request_d          ;
   wire                          reset_3_request_q,         reset_3_request_d          ;
   wire                          reset_wd_request_q,        reset_wd_request_d         ;
   wire [62-`EFF_IFAR_ARCH:61]   int_rest_ifar_q[0:`THREADS-1],int_rest_ifar_d [0:`THREADS-1]; // input=>int_rest_ifar_d      , act=>int_rest_act
   wire                          trace_bus_enable_q                                    ; // input=>pc_xu_trace_bus_enable     , act=>1'b1                    , scan=>Y, sleep=>Y, needs_sreset=>1
   wire [0:10]                   debug_mux_ctrls_q                                     ; // input=>spr_debug_mux_ctrls        , act=>trace_bus_enable_q   , scan=>Y, sleep=>Y, needs_sreset=>1
   wire [0:31]         debug_data_out_q,          debug_data_out_d           ; // input=>debug_data_out_d           , act=>trace_bus_enable_q   , scan=>Y, sleep=>Y, needs_sreset=>1

   // Scanchains
   localparam reset_1_request_offset                     = 0;
   localparam reset_2_request_offset                     = reset_1_request_offset         + 1;
   localparam reset_3_request_offset                     = reset_2_request_offset         + 1;
   localparam reset_wd_request_offset                    = reset_3_request_offset         + 1;
   localparam int_rest_ifar_offset                       = reset_wd_request_offset        + 1;
   localparam trace_bus_enable_offset                    = int_rest_ifar_offset           + `THREADS*`EFF_IFAR_ARCH;
   localparam debug_mux_ctrls_offset                     = trace_bus_enable_offset        + 1;
   localparam debug_data_out_offset                      = debug_mux_ctrls_offset         + 11;
   localparam xu_spr_cspr_offset                         = debug_data_out_offset          + 32;
   localparam scan_right                                 = xu_spr_cspr_offset             + 1;
   wire [0:scan_right-1]         siv;
   wire [0:scan_right-1]         sov;
   // ABST Latches
   wire                          abist_g8t_wenb_q                                      ;		// input=>pc_xu_abist_g8t_wenb   , act=>pc_xu_abist_ena_dc
   wire [4:9]                    abist_waddr_0_q                                       ;		// input=>pc_xu_abist_waddr_0    , act=>pc_xu_abist_ena_dc
   wire [0:3]                    abist_di_0_q                                          ;		// input=>pc_xu_abist_di_0       , act=>pc_xu_abist_ena_dc
   wire                          abist_g8t1p_renb_0_q                                  ;		// input=>pc_xu_abist_g8t1p_renb_0,act=>pc_xu_abist_ena_dc
   wire [4:9]                    abist_raddr_0_q                                       ;		// input=>pc_xu_abist_raddr_0    , act=>pc_xu_abist_ena_dc
   wire                          abist_wl32_comp_ena_q                                 ;		// input=>pc_xu_abist_wl32_comp_ena, act=>pc_xu_abist_ena_dc
   wire [0:3]                    abist_g8t_dcomp_q                                     ;		// input=>pc_xu_abist_g8t_dcomp  , act=>pc_xu_abist_ena_dc
   wire                          abist_g8t_bw_1_q                                      ;		// input=>pc_xu_abist_g8t_bw_1   , act=>pc_xu_abist_ena_dc
   wire                          abist_g8t_bw_0_q                                      ;		// input=>pc_xu_abist_g8t_bw_0   , act=>pc_xu_abist_ena_dc
   // Scanchains
   localparam xu_spr_aspr_offset_abst                    = 1;
   localparam abist_g8t_wenb_offset_abst                 = xu_spr_aspr_offset_abst        + 1;
   localparam abist_waddr_0_offset_abst                  = abist_g8t_wenb_offset_abst     + 1;
   localparam abist_di_0_offset_abst                     = abist_waddr_0_offset_abst      + 6;
   localparam abist_g8t1p_renb_0_offset_abst             = abist_di_0_offset_abst         + 4;
   localparam abist_raddr_0_offset_abst                  = abist_g8t1p_renb_0_offset_abst + 1;
   localparam abist_wl32_comp_ena_offset_abst            = abist_raddr_0_offset_abst      + 6;
   localparam abist_g8t_dcomp_offset_abst                = abist_wl32_comp_ena_offset_abst + 1;
   localparam abist_g8t_bw_1_offset_abst                 = abist_g8t_dcomp_offset_abst    + 4;
   localparam abist_g8t_bw_0_offset_abst                 = abist_g8t_bw_1_offset_abst     + 1;
   localparam scan_right_abst                            = abist_g8t_bw_0_offset_abst     + 2;
   // Scanchain Repower
   wire [0:scan_right_abst-1]    siv_abst;
   wire [0:scan_right_abst-1]    sov_abst;
   wire [0:2]                    siv_bcfg;
   wire [0:2]                    sov_bcfg;
   wire [0:`THREADS+2]           siv_ccfg;
   wire [0:`THREADS+2]           sov_ccfg;
   wire [0:`THREADS+2]           siv_dcfg;
   wire [0:`THREADS+2]           sov_dcfg;
   wire [0:2]                    siv_time;
   wire [0:2]                    sov_time;
   wire [0:2]                    siv_gptr;
   wire [0:2]                    sov_gptr;
   wire [0:2]                    siv_repr;
   wire [0:2]                    sov_repr;
   wire [0:`THREADS+1]           func_scan_rpwr_in;
   wire [0:`THREADS+1]           func_scan_rpwr_out;
   wire [0:`THREADS+1]           func_scan_gate_out;
   // Signals
   wire                          g8t_clkoff_dc_b;
   wire                          g8t_d_mode_dc;
   wire [0:4]                    g8t_mpw1_dc_b;
   wire                          g8t_mpw2_dc_b;
   wire [0:4]                    g8t_delay_lclkr_dc;
   wire                          func_slp_nsl_thold_1;
   wire                          func_nsl_thold_1;
   wire                          func_slp_sl_thold_1;
   wire                          func_sl_thold_1;
   wire                          time_sl_thold_1;
   wire                          abst_sl_thold_1;
   wire                          repr_sl_thold_1;
   wire                          gptr_sl_thold_1;
   wire                          bolt_sl_thold_1;
   wire                          ary_nsl_thold_1;
   wire                          cfg_sl_thold_1;
   wire                          cfg_slp_sl_thold_1;
   wire                          fce_1;
   wire                          sg_1;
   wire                          func_slp_nsl_thold_0;
   wire [0:`THREADS]             func_nsl_thold_0;
   wire [0:`THREADS]             func_slp_sl_thold_0;
   wire [0:`THREADS]             func_sl_thold_0;
   wire [0:`THREADS]             cfg_sl_thold_0;
   wire                          cfg_slp_sl_thold_0;
   wire [0:`THREADS]             fce_0;
   wire [0:`THREADS]             sg_0;
   wire                          cfg_slp_sl_force;
   wire                          cfg_slp_sl_thold_0_b;
   wire                          bcfg_slp_sl_force;
   wire                          bcfg_slp_sl_thold_0_b;
   wire                          ccfg_slp_sl_force;
   wire                          ccfg_slp_sl_thold_0_b;
   wire [0:`THREADS]             cfg_sl_force;
   wire [0:`THREADS]             cfg_sl_thold_0_b;
   wire [0:0]                    bcfg_sl_force;
   wire [0:0]                    bcfg_sl_thold_0_b;
   wire [0:`THREADS]             ccfg_sl_force;
   wire [0:`THREADS]             ccfg_sl_thold_0_b;
   wire [0:`THREADS]             dcfg_sl_force;
   wire [0:`THREADS]             dcfg_sl_thold_0_b;
   wire [0:`THREADS]             func_sl_force;
   wire [0:`THREADS]             func_sl_thold_0_b;
   wire [0:`THREADS]             func_slp_sl_force;
   wire [0:`THREADS]             func_slp_sl_thold_0_b;
   wire [0:`THREADS]             func_nsl_force;
   wire [0:`THREADS]             func_nsl_thold_0_b;
   wire                          func_slp_nsl_force;
   wire                          func_slp_nsl_thold_0_b;
   wire                          repr_sl_thold_0;
   wire                          gptr_sl_thold_0;
   wire                          bolt_sl_thold_0;
   wire                          time_sl_thold_0;
   wire                          abst_sl_force;
   wire                          abst_sl_thold_0;
   wire                          abst_sl_thold_0_b;
   wire                          ary_nsl_thold_0;
   wire                          so_force;
   wire                          abst_so_thold_0_b;
   wire                          bcfg_so_thold_0_b;
   wire                          ccfg_so_thold_0_b;
   wire                          dcfg_so_thold_0_b;
   wire                          time_so_thold_0_b;
   wire                          repr_so_thold_0_b;
   wire                          gptr_so_thold_0_b;
   wire                          func_so_thold_0_b;
   wire [0:31]                   cspr_tspr_ex1_instr;
   wire [0:`THREADS-1]           cspr_tspr_ex2_tid;
   wire [0:9]                    cspr_tspr_timebase_taps;
   wire [0:`GPR_WIDTH*`THREADS-1]tspr_cspr_ex3_tspr_rt;
   wire [0:`THREADS-1]           tspr_cspr_illeg_mtspr_b;
   wire [0:`THREADS-1]           tspr_cspr_illeg_mfspr_b;
   wire [0:`THREADS-1]           tspr_cspr_hypv_mtspr;
   wire [0:`THREADS-1]           tspr_cspr_hypv_mfspr;
   wire [0:`THREADS-1]           tspr_cspr_freeze_timers;
   wire                          cspr_aspr_ex3_we;
   wire [0:5]                    cspr_aspr_ex3_waddr;
   wire                          cspr_aspr_ex1_re;
   wire [0:5]                    cspr_aspr_ex1_raddr;
   wire [64-`GPR_WIDTH:72-(64/`GPR_WIDTH)] aspr_cspr_ex2_rdata;
   wire [0:`THREADS-1]           cspr_tspr_msrovride_en;
   wire [0:`THREADS-1]           cspr_tspr_ram_active;
   wire [0:`THREADS-1]           tspr_epcr_extgs;
   wire [0:`THREADS-1]           tspr_msr_pr;
   wire [0:`THREADS-1]           tspr_msr_is;
   wire [0:`THREADS-1]           tspr_epcr_icm;
   wire [0:`THREADS-1]           tspr_epcr_gicm;
   wire [0:`THREADS-1]           tspr_msr_cm;
   wire [0:`THREADS-1]           tspr_msr_de;
   wire [0:`THREADS-1]           tspr_msr_gs;
   wire [0:`THREADS-1]           tspr_msr_ee;
   wire [0:`THREADS-1]           tspr_msr_ce;
   wire [0:`THREADS-1]           tspr_msr_me;
   wire [0:`THREADS-1]           tspr_msr_fe0;
   wire [0:`THREADS-1]           tspr_msr_fe1;
   wire                          cspr_ccr2_en_pc;
   wire [0:`THREADS-1]           tspr_fp_precise;
   wire [0:`THREADS-1]           cspr_tspr_llen;
   wire [0:`THREADS-1]           cspr_tspr_llpri;
   wire [0:`THREADS-1]           tspr_cspr_lldet;
   wire [0:`THREADS-1]           tspr_cspr_llpulse;
   wire [0:`THREADS-1]           cspr_tspr_dec_dbg_dis;
   wire [0:`THREADS-1]           reset_1_request;
   wire [0:`THREADS-1]           reset_2_request;
   wire [0:`THREADS-1]           reset_3_request;
   wire [0:`THREADS-1]           reset_wd_request;
   wire [0:`THREADS-1]           cspr_tspr_crit_mask;
   wire [0:`THREADS-1]           cspr_tspr_ext_mask;
   wire [0:`THREADS-1]           cspr_tspr_dec_mask;
   wire [0:`THREADS-1]           cspr_tspr_fit_mask;
   wire [0:`THREADS-1]           cspr_tspr_wdog_mask;
   wire [0:`THREADS-1]           cspr_tspr_udec_mask;
   wire [0:`THREADS-1]           cspr_tspr_perf_mask;
   wire [0:`THREADS-1]           tspr_cspr_pm_wake_up;
   wire [0:3*`THREADS-1]         tspr_cspr_async_int;
   wire                          reset_wd_complete;
   wire                          reset_1_complete;
   wire                          reset_2_complete;
   wire                          reset_3_complete;
   wire                          timer_update;
   wire [50:63]                  cspr_tspr_dbell_pirtag;
   wire                          cspr_ccr4_en_dnh;
   wire [0:`THREADS-1]           tspr_cspr_gpir_match;
   wire [64-`GPR_WIDTH:63]       ex2_spr_wd;
   wire [64-`GPR_WIDTH:64+8-(64/`GPR_WIDTH)] ex3_spr_wd;
   wire [0:`THREADS-1]           cspr_tspr_ex3_spr_we;
   wire                          cspr_tspr_rf1_act;
   wire [0:4]                    cspr_xucr0_clkg_ctl;
   wire [0:`THREADS-1]           int_rest_act;
   wire [0:`THREADS-1]           instr_trace_mode;
   wire [0:`THREADS-1]           tspr_cspr_ex2_np1_flush;
   wire [62-`EFF_IFAR_WIDTH:61]  ex2_ifar;
   wire [0:`THREADS-1]           flush;
   wire [0:12*`THREADS-1]        tspr_debug;
   wire [0:39]                   cspr_debug0;
   wire [0:63]                   cspr_debug1;
   wire [0:31]                   dbg_group0;
   wire [0:31]                   dbg_group1;
   wire [0:31]                   dbg_group2;
   wire [0:31]                   dbg_group3;
   wire [0:11]                   trg_group0;
   wire [0:11]                   trg_group1;
   wire [0:11]                   trg_group2;
   wire [0:11]                   trg_group3;

   wire [62-`EFF_IFAR_ARCH:61]   iu_xu_nia    [0:`THREADS-1];
   wire [0:16]                   iu_xu_esr    [0:`THREADS-1];
   wire [0:14]                   iu_xu_mcsr   [0:`THREADS-1];
   wire [0:18]                   iu_xu_dbsr   [0:`THREADS-1];
   wire [64-`GPR_WIDTH:63]       iu_xu_dear   [0:`THREADS-1];
   wire [64-`GPR_WIDTH:63]       spr_dvc1     [0:`THREADS-1];
   wire [64-`GPR_WIDTH:63]       spr_dvc2     [0:`THREADS-1];
   wire                                act_dis = 1'b0;

   //!! Bugspray Include: xu_spr;
   //## figtree_source: xu_spr.fig;

   assign iu_xu_nia[0]        = iu_xu_nia_t0;
   assign iu_xu_esr[0]        = iu_xu_esr_t0;
   assign iu_xu_mcsr[0]       = iu_xu_mcsr_t0;
   assign iu_xu_dbsr[0]       = iu_xu_dbsr_t0;
   assign iu_xu_dear[0]       = iu_xu_dear_t0;
   assign xu_iu_rest_ifar_t0  = int_rest_ifar_q[0];
   assign spr_dvc1_t0         = spr_dvc1[0];
   assign spr_dvc2_t0         = spr_dvc2[0];
   `ifndef THREADS1
   assign iu_xu_nia[1]        = iu_xu_nia_t1;
   assign iu_xu_esr[1]        = iu_xu_esr_t1;
   assign iu_xu_mcsr[1]       = iu_xu_mcsr_t1;
   assign iu_xu_dbsr[1]       = iu_xu_dbsr_t1;
   assign iu_xu_dear[1]       = iu_xu_dear_t1;
   assign xu_iu_rest_ifar_t1  = int_rest_ifar_q[1];
   assign spr_dvc1_t1         = spr_dvc1[1];
   assign spr_dvc2_t1         = spr_dvc2[1];
   `endif


   assign spr_epcr_extgs      = tspr_epcr_extgs;
   assign spr_epcr_icm        = tspr_epcr_icm;
   assign spr_epcr_gicm       = tspr_epcr_gicm;
   assign spr_msr_de          = tspr_msr_de;
   assign spr_msr_pr          = tspr_msr_pr;
   assign spr_msr_is          = tspr_msr_is;
   assign spr_msr_cm          = tspr_msr_cm;
   assign spr_msr_gs          = tspr_msr_gs;
   assign spr_msr_ee          = tspr_msr_ee;
   assign spr_msr_ce          = tspr_msr_ce;
   assign spr_msr_me          = tspr_msr_me;
   assign spr_msr_fe0         = tspr_msr_fe0;
   assign spr_msr_fe1         = tspr_msr_fe1;
   assign xu_iu_fp_precise    = tspr_fp_precise;
   assign reset_1_request_d   = |(reset_1_request);
   assign reset_2_request_d   = |(reset_2_request);
   assign reset_3_request_d   = |(reset_3_request);
   assign reset_wd_request_d  = |(reset_wd_request);
   assign ac_tc_reset_1_request = reset_1_request_q;
   assign ac_tc_reset_2_request = reset_2_request_q;
   assign ac_tc_reset_3_request = reset_3_request_q;
   assign ac_tc_reset_wd_request = reset_wd_request_q;
   assign spr_xucr0_clkg_ctl  = cspr_xucr0_clkg_ctl[0:3];
   assign ex2_spr_wd          = xu_spr_ex2_rs1;
   assign spr_ccr2_en_pc      = cspr_ccr2_en_pc;
   assign spr_ccr4_en_dnh     = cspr_ccr4_en_dnh;
   assign flush               = cp_flush | {`THREADS{xu_spr_ord_flush}};


   xu_spr_cspr #(.hvmode(hvmode), .a2mode(a2mode)) xu_spr_cspr(
      .nclk(nclk),
      // CHIP IO
      .an_ac_sleep_en(an_ac_sleep_en),
      .an_ac_reservation_vld(an_ac_reservation_vld),
      .an_ac_tb_update_enable(an_ac_tb_update_enable),
      .an_ac_tb_update_pulse(an_ac_tb_update_pulse),
      .an_ac_coreid(an_ac_coreid),
      .an_ac_chipid_dc(an_ac_chipid_dc),
      .pc_xu_instr_trace_mode(pc_xu_instr_trace_mode),
      .pc_xu_instr_trace_tid(pc_xu_instr_trace_tid),
      .instr_trace_mode(instr_trace_mode),
      .spr_pvr_version_dc(spr_pvr_version_dc),
      .spr_pvr_revision_dc(spr_pvr_revision_dc),
      .spr_pvr_revision_minor_dc(spr_pvr_revision_minor_dc),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .bcfg_sl_force(bcfg_sl_force[0]),
      .bcfg_sl_thold_0_b(bcfg_sl_thold_0_b[0]),
      .bcfg_slp_sl_force(bcfg_slp_sl_force),
      .bcfg_slp_sl_thold_0_b(bcfg_slp_sl_thold_0_b),
      .ccfg_sl_force(ccfg_sl_force[0]),
      .ccfg_sl_thold_0_b(ccfg_sl_thold_0_b[0]),
      .ccfg_slp_sl_force(ccfg_slp_sl_force),
      .ccfg_slp_sl_thold_0_b(ccfg_slp_sl_thold_0_b),
      .dcfg_sl_force(dcfg_sl_force[0]),
      .dcfg_sl_thold_0_b(dcfg_sl_thold_0_b[0]),
      .func_sl_force(func_sl_force[0]),
      .func_sl_thold_0_b(func_sl_thold_0_b[0]),
      .func_slp_sl_force(func_slp_sl_force[0]),
      .func_slp_sl_thold_0_b(func_slp_sl_thold_0_b[0]),

      .func_nsl_force(func_nsl_force[0]),
      .func_nsl_thold_0_b(func_nsl_thold_0_b[0]),

      .sg_0(sg_0[0]),
      .scan_in({func_scan_rpwr_in[`THREADS],siv[xu_spr_cspr_offset]}),
      .scan_out({func_scan_rpwr_out[`THREADS],sov[xu_spr_cspr_offset]}),
      .bcfg_scan_in(siv_bcfg[1]),
      .bcfg_scan_out(sov_bcfg[1]),
      .ccfg_scan_in(siv_ccfg[1]),
      .ccfg_scan_out(sov_ccfg[1]),
      .dcfg_scan_in(siv_dcfg[1]),
      .dcfg_scan_out(sov_dcfg[1]),
      .cspr_tspr_rf1_act(cspr_tspr_rf1_act),
      // Decode
      .rv_xu_vld(rv_xu_vld),
      .rv_xu_ex0_ord(rv_xu_ex0_ord),
      .rv_xu_ex0_instr(rv_xu_ex0_instr),
      .rv_xu_ex0_ifar(rv_xu_ex0_ifar),
      .ex2_ifar(ex2_ifar),

      .spr_xu_ord_read_done(spr_xu_ord_read_done),
      .spr_xu_ord_write_done(spr_xu_ord_write_done),
      .xu_spr_ord_ready(xu_spr_ord_ready),
      .flush(flush),

      // Read Data
      .tspr_cspr_ex3_tspr_rt(tspr_cspr_ex3_tspr_rt),
      .spr_xu_ex4_rd_data(spr_xu_ex4_rd_data),
      // Write Data
      .xu_spr_ex2_rs1(xu_spr_ex2_rs1),
      .cspr_tspr_ex3_spr_we(cspr_tspr_ex3_spr_we),
      .ex3_spr_wd_out(ex3_spr_wd),
      // SPRT Interface
      .cspr_tspr_ex1_instr(cspr_tspr_ex1_instr),
      .cspr_tspr_ex2_tid(cspr_tspr_ex2_tid),

      .cspr_tspr_timebase_taps(cspr_tspr_timebase_taps),
      .timer_update(timer_update),
      .cspr_tspr_dec_dbg_dis(cspr_tspr_dec_dbg_dis),
      // Illegal SPR
      .tspr_cspr_illeg_mtspr_b(tspr_cspr_illeg_mtspr_b),
      .tspr_cspr_illeg_mfspr_b(tspr_cspr_illeg_mfspr_b),
      .tspr_cspr_hypv_mtspr(tspr_cspr_hypv_mtspr),
      .tspr_cspr_hypv_mfspr(tspr_cspr_hypv_mfspr),
      // Array SPRs
      .cspr_aspr_ex3_we(cspr_aspr_ex3_we),
      .cspr_aspr_ex3_waddr(cspr_aspr_ex3_waddr),
      .cspr_aspr_ex1_re(cspr_aspr_ex1_re),
      .cspr_aspr_ex1_raddr(cspr_aspr_ex1_raddr),
      .aspr_cspr_ex2_rdata(aspr_cspr_ex2_rdata[64 - `GPR_WIDTH:72 - (64/`GPR_WIDTH)]),
      // Slow SPR Bus
      .xu_slowspr_val_out(xu_slowspr_val_out),
      .xu_slowspr_rw_out(xu_slowspr_rw_out),
      .xu_slowspr_etid_out(xu_slowspr_etid_out),
      .xu_slowspr_addr_out(xu_slowspr_addr_out),
      .xu_slowspr_data_out(xu_slowspr_data_out),
      // DCR Bus
      .ac_an_dcr_act(ac_an_dcr_act),
      .ac_an_dcr_val(ac_an_dcr_val),
      .ac_an_dcr_read(ac_an_dcr_read),
      .ac_an_dcr_user(ac_an_dcr_user),
      .ac_an_dcr_etid(ac_an_dcr_etid),
      .ac_an_dcr_addr(ac_an_dcr_addr),
      .ac_an_dcr_data(ac_an_dcr_data),
      // Trap
      .spr_dec_ex4_spr_hypv(spr_dec_ex4_spr_hypv),
      .spr_dec_ex4_spr_illeg(spr_dec_ex4_spr_illeg),
      .spr_dec_ex4_spr_priv(spr_dec_ex4_spr_priv),
      .spr_dec_ex4_np1_flush(spr_dec_ex4_np1_flush),
      // Run State
      .pc_xu_pm_hold_thread(pc_xu_pm_hold_thread),
      .iu_xu_stop(iu_xu_stop),
      .xu_iu_run_thread(xu_iu_run_thread),
      .xu_pc_spr_ccr0_we(xu_pc_spr_ccr0_we),
      .xu_pc_spr_ccr0_pme(xu_pc_spr_ccr0_pme),
      // Quiesce
      .iu_xu_quiesce(iu_xu_quiesce),
      .iu_xu_icache_quiesce(iu_xu_icache_quiesce),
      .lq_xu_quiesce(lq_xu_quiesce),
      .mm_xu_quiesce(mm_xu_quiesce),
      .bx_xu_quiesce(bx_xu_quiesce),
      .xu_pc_running(xu_pc_running),
      // PCCR0
      .pc_xu_extirpts_dis_on_stop(pc_xu_extirpts_dis_on_stop),
      .pc_xu_timebase_dis_on_stop(pc_xu_timebase_dis_on_stop),
      .pc_xu_decrem_dis_on_stop(pc_xu_decrem_dis_on_stop),
      // .PERF(PERF),
      .pc_xu_event_count_mode(pc_xu_event_count_mode),
      .pc_xu_event_bus_enable(pc_xu_event_bus_enable),
      .xu_event_bus_in(xu_event_bus_in),
      .xu_event_bus_out(xu_event_bus_out),
      .div_spr_running(div_spr_running),
      .mul_spr_running(mul_spr_running),
      // MSR Override
      .pc_xu_ram_active(pc_xu_ram_active),
      .pc_xu_msrovride_enab(pc_xu_msrovride_enab),
      .cspr_tspr_msrovride_en(cspr_tspr_msrovride_en),
      .cspr_tspr_ram_active(cspr_tspr_ram_active),
      .xu_iu_msrovride_enab(xu_iu_msrovride_enab),
      // LiveLock
      .cspr_tspr_llen(cspr_tspr_llen),
      .cspr_tspr_llpri(cspr_tspr_llpri),
      .tspr_cspr_lldet(tspr_cspr_lldet),
      .tspr_cspr_llpulse(tspr_cspr_llpulse),
      // Reset
      .pc_xu_reset_wd_complete(pc_xu_reset_wd_complete),
      .pc_xu_reset_1_complete(pc_xu_reset_1_complete),
      .pc_xu_reset_2_complete(pc_xu_reset_2_complete),
      .pc_xu_reset_3_complete(pc_xu_reset_3_complete),
      .reset_wd_complete(reset_wd_complete),
      .reset_1_complete(reset_1_complete),
      .reset_2_complete(reset_2_complete),
      .reset_3_complete(reset_3_complete),
      // Async Interrupt Req Interface
      .cspr_tspr_sleep_mask(cspr_tspr_sleep_mask),
      .cspr_tspr_crit_mask(cspr_tspr_crit_mask),
      .cspr_tspr_ext_mask(cspr_tspr_ext_mask),
      .cspr_tspr_dec_mask(cspr_tspr_dec_mask),
      .cspr_tspr_fit_mask(cspr_tspr_fit_mask),
      .cspr_tspr_wdog_mask(cspr_tspr_wdog_mask),
      .cspr_tspr_udec_mask(cspr_tspr_udec_mask),
      .cspr_tspr_perf_mask(cspr_tspr_perf_mask),
      .tspr_cspr_pm_wake_up(tspr_cspr_pm_wake_up),
      // DBELL
      .xu_iu_dbell_interrupt(xu_iu_dbell_interrupt),
      .xu_iu_cdbell_interrupt(xu_iu_cdbell_interrupt),
      .xu_iu_gdbell_interrupt(xu_iu_gdbell_interrupt),
      .xu_iu_gcdbell_interrupt(xu_iu_gcdbell_interrupt),
      .xu_iu_gmcdbell_interrupt(xu_iu_gmcdbell_interrupt),
      .iu_xu_dbell_taken(iu_xu_dbell_taken),
      .iu_xu_cdbell_taken(iu_xu_cdbell_taken),
      .iu_xu_gdbell_taken(iu_xu_gdbell_taken),
      .iu_xu_gcdbell_taken(iu_xu_gcdbell_taken),
      .iu_xu_gmcdbell_taken(iu_xu_gmcdbell_taken),
      .cspr_tspr_dbell_pirtag(cspr_tspr_dbell_pirtag),
      .tspr_cspr_gpir_match(tspr_cspr_gpir_match),
      .lq_xu_dbell_val(lq_xu_dbell_val),
      .lq_xu_dbell_type(lq_xu_dbell_type),
      .lq_xu_dbell_brdcast(lq_xu_dbell_brdcast),
      .lq_xu_dbell_lpid_match(lq_xu_dbell_lpid_match),
      .lq_xu_dbell_pirtag(lq_xu_dbell_pirtag),
      // Parity
      .pc_xu_inj_sprg_ecc(pc_xu_inj_sprg_ecc),
      .xu_pc_err_sprg_ecc(xu_pc_err_sprg_ecc),
      .xu_pc_err_sprg_ue(xu_pc_err_sprg_ue),
      // Debug
      .tspr_cspr_freeze_timers(tspr_cspr_freeze_timers),
      .tspr_cspr_async_int(tspr_cspr_async_int),
      .tspr_cspr_ex2_np1_flush(tspr_cspr_ex2_np1_flush),
      // SPRs
      .lq_xu_spr_xucr0_cslc_xuop(lq_xu_spr_xucr0_cslc_xuop),
      .lq_xu_spr_xucr0_cslc_binv(lq_xu_spr_xucr0_cslc_binv),
      .lq_xu_spr_xucr0_clo(lq_xu_spr_xucr0_clo),
      .lq_xu_spr_xucr0_cul(lq_xu_spr_xucr0_cul),
      .tspr_msr_gs(tspr_msr_gs),
      .tspr_msr_pr(tspr_msr_pr),
      .tspr_msr_ee(tspr_msr_ee),
      .tspr_msr_ce(tspr_msr_ce),
      .tspr_msr_me(tspr_msr_me),
      .cspr_xucr0_clkg_ctl(cspr_xucr0_clkg_ctl),
      .cspr_ccr2_en_pc(cspr_ccr2_en_pc),
      .cspr_ccr4_en_dnh(cspr_ccr4_en_dnh),
      .xu_lsu_spr_xucr0_clfc(xu_lsu_spr_xucr0_clfc),
      .spr_xesr1(spr_xesr1),
      .spr_xesr2(spr_xesr2),
      .perf_event_en(perf_event_en),
		.spr_ccr2_en_dcr(spr_ccr2_en_dcr),
		.spr_ccr2_en_trace(spr_ccr2_en_trace),
		.spr_ccr2_ifratsc(spr_ccr2_ifratsc),
		.spr_ccr2_ifrat(spr_ccr2_ifrat),
		.spr_ccr2_dfratsc(spr_ccr2_dfratsc),
		.spr_ccr2_dfrat(spr_ccr2_dfrat),
		.spr_ccr2_ucode_dis(spr_ccr2_ucode_dis),
		.spr_ccr2_ap(spr_ccr2_ap),
		.spr_ccr2_en_attn(spr_ccr2_en_attn),
		.spr_ccr2_en_ditc(spr_ccr2_en_ditc),
		.spr_ccr2_en_icswx(spr_ccr2_en_icswx),
		.spr_ccr2_notlb(spr_ccr2_notlb),
		.spr_xucr0_trace_um(spr_xucr0_trace_um),
		.xu_lsu_spr_xucr0_mbar_ack(xu_lsu_spr_xucr0_mbar_ack),
		.xu_lsu_spr_xucr0_tlbsync(xu_lsu_spr_xucr0_tlbsync),
		.spr_xucr0_cls(spr_xucr0_cls),
		.xu_lsu_spr_xucr0_aflsta(xu_lsu_spr_xucr0_aflsta),
		.spr_xucr0_mddp(spr_xucr0_mddp),
		.xu_lsu_spr_xucr0_cred(xu_lsu_spr_xucr0_cred),
		.xu_lsu_spr_xucr0_rel(xu_lsu_spr_xucr0_rel),
		.spr_xucr0_mdcp(spr_xucr0_mdcp),
		.xu_lsu_spr_xucr0_flsta(xu_lsu_spr_xucr0_flsta),
		.xu_lsu_spr_xucr0_l2siw(xu_lsu_spr_xucr0_l2siw),
		.xu_lsu_spr_xucr0_flh2l2(xu_lsu_spr_xucr0_flh2l2),
		.xu_lsu_spr_xucr0_dcdis(xu_lsu_spr_xucr0_dcdis),
		.xu_lsu_spr_xucr0_wlk(xu_lsu_spr_xucr0_wlk),
		.spr_xucr4_mmu_mchk(spr_xucr4_mmu_mchk),
		.spr_xucr4_mddmh(spr_xucr4_mddmh),
      .cspr_debug0(cspr_debug0),
      .cspr_debug1(cspr_debug1),
      // Power
      .vdd(vdd),
      .gnd(gnd)
   );

   generate
      begin : threads
         genvar                              t;
         for (t = 0; t <= `THREADS - 1; t = t + 1)
         begin : thread

            xu_spr_tspr #(.hvmode(hvmode), .a2mode(a2mode)) xu_spr_tspr(
               .nclk(nclk),
               // CHIP IO
               .an_ac_ext_interrupt(an_ac_ext_interrupt[t]),
               .an_ac_crit_interrupt(an_ac_crit_interrupt[t]),
               .an_ac_perf_interrupt(an_ac_perf_interrupt[t]),
               .an_ac_hang_pulse(an_ac_hang_pulse[t]),
               .ac_tc_machine_check(ac_tc_machine_check[t]),
               .an_ac_external_mchk(an_ac_external_mchk[t]),
               .instr_trace_mode(instr_trace_mode[t]),
               // Act
               .d_mode_dc(d_mode_dc),
               .delay_lclkr_dc(delay_lclkr_dc),
               .mpw1_dc_b(mpw1_dc_b),
               .mpw2_dc_b(mpw2_dc_b),
               .func_sl_force(func_sl_force[1 + t]),
               .func_sl_thold_0_b(func_sl_thold_0_b[1 + t]),
               .func_nsl_force(func_nsl_force[1 + t]),
               .func_nsl_thold_0_b(func_nsl_thold_0_b[1 + t]),
               .func_slp_sl_force(func_slp_sl_force[1 + t]),
               .func_slp_sl_thold_0_b(func_slp_sl_thold_0_b[1 + t]),
               .ccfg_sl_force(ccfg_sl_force[1 + t]),
               .ccfg_sl_thold_0_b(ccfg_sl_thold_0_b[1 + t]),
               .dcfg_sl_force(dcfg_sl_force[1 + t]),
               .dcfg_sl_thold_0_b(dcfg_sl_thold_0_b[1 + t]),
               .sg_0(sg_0[1 + t]),
               .scan_in(func_scan_rpwr_in[t]),
               .scan_out(func_scan_rpwr_out[t]),
               .ccfg_scan_in(siv_ccfg[2 + t]),
               .ccfg_scan_out(sov_ccfg[2 + t]),
               .dcfg_scan_in(siv_dcfg[2 + t]),
               .dcfg_scan_out(sov_dcfg[2 + t]),
               .cspr_tspr_rf1_act(cspr_tspr_rf1_act),
               // Read Interface
               .cspr_tspr_ex1_instr(cspr_tspr_ex1_instr),
               .cspr_tspr_ex2_tid(cspr_tspr_ex2_tid[t]),
               .tspr_cspr_ex3_tspr_rt(tspr_cspr_ex3_tspr_rt[`GPR_WIDTH * t:`GPR_WIDTH * (t + 1) - 1]),
               // Write Interface
               .ex2_spr_wd(ex2_spr_wd),
               .ex3_spr_we(cspr_tspr_ex3_spr_we[t]),

               .cspr_tspr_dec_dbg_dis(cspr_tspr_dec_dbg_dis[t]),
               // Illegal SPR
               .tspr_cspr_illeg_mtspr_b(tspr_cspr_illeg_mtspr_b[t]),
               .tspr_cspr_illeg_mfspr_b(tspr_cspr_illeg_mfspr_b[t]),
               .tspr_cspr_hypv_mtspr(tspr_cspr_hypv_mtspr[t]),
               .tspr_cspr_hypv_mfspr(tspr_cspr_hypv_mfspr[t]),
               // Interrupt Interface
               .iu_xu_rfi(iu_xu_rfi[t]),
               .iu_xu_rfgi(iu_xu_rfgi[t]),
               .iu_xu_rfci(iu_xu_rfci[t]),
               .iu_xu_rfmci(iu_xu_rfmci[t]),
               .iu_xu_act(iu_xu_act[t]),
               .iu_xu_int(iu_xu_int[t]),
               .iu_xu_gint(iu_xu_gint[t]),
               .iu_xu_cint(iu_xu_cint[t]),
               .iu_xu_mcint(iu_xu_mcint[t]),
               .iu_xu_nia(iu_xu_nia[t]),
               .iu_xu_esr(iu_xu_esr[t]),
               .iu_xu_mcsr(iu_xu_mcsr[t]),
               .iu_xu_dbsr(iu_xu_dbsr[t]),
               .iu_xu_dear(iu_xu_dear[t]),
               .iu_xu_dear_update(iu_xu_dear_update[t]),
               .iu_xu_dbsr_update(iu_xu_dbsr_update[t]),
               .iu_xu_esr_update(iu_xu_esr_update[t]),
               .iu_xu_force_gsrr(iu_xu_force_gsrr[t]),
               .iu_xu_dbsr_ude(iu_xu_dbsr_ude[t]),
               .iu_xu_dbsr_ide(iu_xu_dbsr_ide[t]),
               .xu_iu_dbsr_ide(xu_iu_dbsr_ide[t]),
               .int_rest_act(int_rest_act[t]),
               .int_rest_ifar(int_rest_ifar_d[t]),
               .ex2_ifar(ex2_ifar),
               // Async Interrupt Req Interface
               .xu_iu_external_mchk(xu_iu_external_mchk[t]),
               .xu_iu_ext_interrupt(xu_iu_ext_interrupt[t]),
               .xu_iu_dec_interrupt(xu_iu_dec_interrupt[t]),
               .xu_iu_udec_interrupt(xu_iu_udec_interrupt[t]),
               .xu_iu_perf_interrupt(xu_iu_perf_interrupt[t]),
               .xu_iu_fit_interrupt(xu_iu_fit_interrupt[t]),
               .xu_iu_crit_interrupt(xu_iu_crit_interrupt[t]),
               .xu_iu_wdog_interrupt(xu_iu_wdog_interrupt[t]),
               .xu_iu_gwdog_interrupt(xu_iu_gwdog_interrupt[t]),
               .xu_iu_gfit_interrupt(xu_iu_gfit_interrupt[t]),
               .xu_iu_gdec_interrupt(xu_iu_gdec_interrupt[t]),
               .cspr_tspr_sleep_mask(cspr_tspr_sleep_mask),
               .cspr_tspr_crit_mask(cspr_tspr_crit_mask[t]),
               .cspr_tspr_ext_mask(cspr_tspr_ext_mask[t]),
               .cspr_tspr_dec_mask(cspr_tspr_dec_mask[t]),
               .cspr_tspr_fit_mask(cspr_tspr_fit_mask[t]),
               .cspr_tspr_wdog_mask(cspr_tspr_wdog_mask[t]),
               .cspr_tspr_udec_mask(cspr_tspr_udec_mask[t]),
               .cspr_tspr_perf_mask(cspr_tspr_perf_mask[t]),
               .tspr_cspr_pm_wake_up(tspr_cspr_pm_wake_up[t]),
               .tspr_cspr_async_int(tspr_cspr_async_int[3 * t:3 * (t + 1) - 1]),
               // DBELL Int
               .cspr_tspr_dbell_pirtag(cspr_tspr_dbell_pirtag),
               .tspr_cspr_gpir_match(tspr_cspr_gpir_match[t]),
               .cspr_tspr_timebase_taps(cspr_tspr_timebase_taps),
               .tspr_cspr_ex2_np1_flush(tspr_cspr_ex2_np1_flush[t]),
               .timer_update(timer_update),
               // Debug
               .xu_iu_iac1_en(xu_iu_iac1_en[t]),
               .xu_iu_iac2_en(xu_iu_iac2_en[t]),
               .xu_iu_iac3_en(xu_iu_iac3_en[t]),
               .xu_iu_iac4_en(xu_iu_iac4_en[t]),
               .tspr_cspr_freeze_timers(tspr_cspr_freeze_timers[t]),
               // Run State
               .xu_iu_single_instr_mode(xu_iu_single_instr_mode[t]),
               .xu_iu_raise_iss_pri(xu_iu_raise_iss_pri[t]),
               .xu_pc_stop_dnh_instr(xu_pc_stop_dnh_instr[t]),
               // LiveLock
               .iu_xu_instr_cpl(iu_xu_instr_cpl[t]),
               .cspr_tspr_llen(cspr_tspr_llen[t]),
               .cspr_tspr_llpri(cspr_tspr_llpri[t]),
               .tspr_cspr_lldet(tspr_cspr_lldet[t]),
               .tspr_cspr_llpulse(tspr_cspr_llpulse[t]),
               .xu_pc_err_llbust_attempt(xu_pc_err_llbust_attempt[t]),
               .xu_pc_err_llbust_failed(xu_pc_err_llbust_failed[t]),
               .pc_xu_inj_llbust_attempt(pc_xu_inj_llbust_attempt[t]),
               .pc_xu_inj_llbust_failed(pc_xu_inj_llbust_failed[t]),
               .pc_xu_inj_wdt_reset(pc_xu_inj_wdt_reset[t]),
               // Resets
               .reset_wd_complete(reset_wd_complete),
               .reset_1_complete(reset_1_complete),
               .reset_2_complete(reset_2_complete),
               .reset_3_complete(reset_3_complete),
               .reset_1_request(reset_1_request[t]),
               .reset_2_request(reset_2_request[t]),
               .reset_3_request(reset_3_request[t]),
               .reset_wd_request(reset_wd_request[t]),
               .xu_pc_err_wdt_reset(xu_pc_err_wdt_reset[t]),
               // MSR Override
               .cspr_tspr_ram_active(cspr_tspr_ram_active[t]),
               .cspr_tspr_msrovride_en(cspr_tspr_msrovride_en[t]),
               .pc_xu_msrovride_pr(pc_xu_msrovride_pr),
               .pc_xu_msrovride_gs(pc_xu_msrovride_gs),
               .pc_xu_msrovride_de(pc_xu_msrovride_de),
               // SIAR
               .pc_xu_spr_cesr1_pmae(pc_xu_spr_cesr1_pmae[t]),
               .xu_pc_perfmon_alert(xu_pc_perfmon_alert[t]),
               // SPRs
               .spr_dbcr0_edm(spr_dbcr0_edm[t]),
               .tspr_epcr_icm(tspr_epcr_icm[t]),
               .tspr_epcr_gicm(tspr_epcr_gicm[t]),
               .tspr_epcr_extgs(tspr_epcr_extgs[t]),
               .tspr_fp_precise(tspr_fp_precise[t]),
               .tspr_msr_de(tspr_msr_de[t]),
               .tspr_msr_pr(tspr_msr_pr[t]),
               .tspr_msr_is(tspr_msr_is[t]),
               .tspr_msr_cm(tspr_msr_cm[t]),
               .tspr_msr_gs(tspr_msr_gs[t]),
               .tspr_msr_ee(tspr_msr_ee[t]),
               .tspr_msr_ce(tspr_msr_ce[t]),
               .tspr_msr_me(tspr_msr_me[t]),
               .tspr_msr_fe0(tspr_msr_fe0[t]),
               .tspr_msr_fe1(tspr_msr_fe1[t]),
               .cspr_xucr0_clkg_ctl(cspr_xucr0_clkg_ctl[4:4]),
               .cspr_ccr4_en_dnh(cspr_ccr4_en_dnh),
               .spr_dvc1(spr_dvc1[t]),
               .spr_dvc2(spr_dvc2[t]),
		.spr_dbcr0_idm(spr_dbcr0_idm[t]),
		.spr_dbcr0_icmp(spr_dbcr0_icmp[t]),
		.spr_dbcr0_brt(spr_dbcr0_brt[t]),
		.spr_dbcr0_irpt(spr_dbcr0_irpt[t]),
		.spr_dbcr0_trap(spr_dbcr0_trap[t]),
		.spr_dbcr0_dac1(spr_dbcr0_dac1[2*t : 2*(t+1)-1]),
		.spr_dbcr0_dac2(spr_dbcr0_dac2[2*t : 2*(t+1)-1]),
		.spr_dbcr0_ret(spr_dbcr0_ret[t]),
		.spr_dbcr0_dac3(spr_dbcr0_dac3[2*t : 2*(t+1)-1]),
		.spr_dbcr0_dac4(spr_dbcr0_dac4[2*t : 2*(t+1)-1]),
		.spr_dbcr1_iac12m(spr_dbcr1_iac12m[t]),
		.spr_dbcr1_iac34m(spr_dbcr1_iac34m[t]),
		.spr_epcr_dtlbgs(spr_epcr_dtlbgs[t]),
		.spr_epcr_itlbgs(spr_epcr_itlbgs[t]),
		.spr_epcr_dsigs(spr_epcr_dsigs[t]),
		.spr_epcr_isigs(spr_epcr_isigs[t]),
		.spr_epcr_duvd(spr_epcr_duvd[t]),
		.spr_epcr_dgtmi(spr_epcr_dgtmi[t]),
		.xu_mm_spr_epcr_dmiuh(xu_mm_spr_epcr_dmiuh[t]),
		.spr_msr_ucle(spr_msr_ucle[t]),
		.spr_msr_spv(spr_msr_spv[t]),
		.spr_msr_fp(spr_msr_fp[t]),
		.spr_msr_ds(spr_msr_ds[t]),
		.spr_msrp_uclep(spr_msrp_uclep[t]),
               .tspr_debug(tspr_debug[12 * t:12 * (t + 1) - 1]),
               // Power
               .vdd(vdd),
               .gnd(gnd)
            );
         end
      end
   endgenerate


   tri_64x72_1r1w xu_spr_aspr(
      .vdd(vdd),
      .vcs(vcs),
      .gnd(gnd),
      .nclk(nclk),
      .sg_0(sg_0[0]),
      .abst_sl_thold_0(abst_sl_thold_0),
      .ary_nsl_thold_0(ary_nsl_thold_0),
      .time_sl_thold_0(time_sl_thold_0),
      .repr_sl_thold_0(repr_sl_thold_0),
      // Reads
      .rd0_act(cspr_aspr_ex1_re),
      .rd0_adr(cspr_aspr_ex1_raddr),
      .do0(aspr_cspr_ex2_rdata),
      // Writes
      .wr_act(cspr_aspr_ex3_we),
      .wr_adr(cspr_aspr_ex3_waddr),
      .di(ex3_spr_wd),
      // Scan
      .abst_scan_in(siv_abst[xu_spr_aspr_offset_abst]),
      .abst_scan_out(sov_abst[xu_spr_aspr_offset_abst]),
      .time_scan_in(siv_time[1]),
      .time_scan_out(sov_time[1]),
      .repr_scan_in(siv_repr[1]),
      .repr_scan_out(sov_repr[1]),
      // Misc Pervasive
      .scan_dis_dc_b(an_ac_scan_dis_dc_b),
      .scan_diag_dc(an_ac_scan_diag_dc),
      .ccflush_dc(pc_xu_ccflush_dc),
      .clkoff_dc_b(g8t_clkoff_dc_b),
      .d_mode_dc(g8t_d_mode_dc),
      .mpw1_dc_b(g8t_mpw1_dc_b),
      .mpw2_dc_b(g8t_mpw2_dc_b),
      .delay_lclkr_dc(g8t_delay_lclkr_dc),
      // BOLT-ON
      .lcb_bolt_sl_thold_0(bolt_sl_thold_0),
      .pc_bo_enable_2(bo_enable_2),		// general bolt-on enable
      .pc_bo_reset(pc_xu_bo_reset),		// reset
      .pc_bo_unload(pc_xu_bo_unload),		// unload sticky bits
      .pc_bo_repair(pc_xu_bo_repair),		// execute sticky bit decode
      .pc_bo_shdata(pc_xu_bo_shdata),		// shift data for timing write and diag loop
      .pc_bo_select(pc_xu_bo_select),		// select for mask and hier writes
      .bo_pc_failout(xu_pc_bo_fail),		// fail/no-fix reg
      .bo_pc_diagloop(xu_pc_bo_diagout),
      .tri_lcb_mpw1_dc_b(mpw1_dc_b),
      .tri_lcb_mpw2_dc_b(mpw2_dc_b),
      .tri_lcb_delay_lclkr_dc(delay_lclkr_dc),
      .tri_lcb_clkoff_dc_b(clkoff_dc_b),
      .tri_lcb_act_dis_dc(act_dis),
      // ABIST
      .abist_bw_odd(abist_g8t_bw_1_q),
      .abist_bw_even(abist_g8t_bw_0_q),
      .tc_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
      .abist_ena_1(pc_xu_abist_ena_dc),
      .wr_abst_act(abist_g8t_wenb_q),
      .abist_wr_adr(abist_waddr_0_q),
      .abist_di(abist_di_0_q),
      .rd0_abst_act(abist_g8t1p_renb_0_q),
      .abist_rd0_adr(abist_raddr_0_q),
      .abist_g8t_rd0_comp_ena(abist_wl32_comp_ena_q),
      .abist_raw_dc_b(pc_xu_abist_raw_dc_b),
      .obs0_abist_cmp(abist_g8t_dcomp_q)
   );


   tri_debug_mux4 xu_debug_mux(
      .select_bits(debug_mux_ctrls_q),
      .trace_data_in(spr_debug_data_in),
      .dbg_group0(dbg_group0),
      .dbg_group1(dbg_group1),
      .dbg_group2(dbg_group2),
      .dbg_group3(dbg_group3),
      .trace_data_out(debug_data_out_d)
   );

   assign dbg_group0 = {32{1'b0}};
   assign dbg_group1 = {32{1'b0}};
   assign dbg_group2 = {32{1'b0}};
   assign dbg_group3 = {32{1'b0}};

   assign spr_debug_data_out = debug_data_out_q;

   // FUNC Latch Instances

   tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) reset_1_request_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(1'b1),
      .force_t(func_nsl_force[0]),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b[0]),
      .sg(sg_0[0]),
      .scin( siv[reset_1_request_offset]),
      .scout(sov[reset_1_request_offset]),
      .din(reset_1_request_d),
      .dout(reset_1_request_q)
   );

   tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) reset_2_request_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(1'b1),
      .force_t(func_nsl_force[0]),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b[0]),
      .sg(sg_0[0]),
      .scin( siv[reset_2_request_offset]),
      .scout(sov[reset_2_request_offset]),
      .din(reset_2_request_d),
      .dout(reset_2_request_q)
   );

   tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) reset_3_request_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(1'b1),
      .force_t(func_nsl_force[0]),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b[0]),
      .sg(sg_0[0]),
      .scin( siv[reset_3_request_offset]),
      .scout(sov[reset_3_request_offset]),
      .din(reset_3_request_d),
      .dout(reset_3_request_q)
   );

   tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) reset_wd_request_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(1'b1),
      .force_t(func_nsl_force[0]),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b[0]),
      .sg(sg_0[0]),
      .scin( siv[reset_wd_request_offset]),
      .scout(sov[reset_wd_request_offset]),
      .din(reset_wd_request_d),
      .dout(reset_wd_request_q)
   );
   generate
      begin : int_rest_ifar_latch_gen
         genvar                              r;
         for (r = 0; r <= `THREADS-1; r = r + 1)
         begin : thread

            tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) int_rest_ifar_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(int_rest_act[r]),
               .force_t(func_sl_force[0]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b[0]),
               .sg(sg_0[0]),
               .scin(siv [int_rest_ifar_offset+r*`EFF_IFAR_ARCH:int_rest_ifar_offset+(r+1)*`EFF_IFAR_ARCH-1]),
               .scout(sov[int_rest_ifar_offset+r*`EFF_IFAR_ARCH:int_rest_ifar_offset+(r+1)*`EFF_IFAR_ARCH-1]),
               .din(int_rest_ifar_d[r]),
               .dout(int_rest_ifar_q[r])
            );
         end
      end
      endgenerate

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) trace_bus_enable_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force[0]),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b[0]),
      .sg(sg_0[0]),
      .scin(siv[trace_bus_enable_offset]),
      .scout(sov[trace_bus_enable_offset]),
      .din(pc_xu_trace_bus_enable),
      .dout(trace_bus_enable_q)
   );
   tri_rlmreg_p #(.WIDTH(11), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) debug_mux_ctrls_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(trace_bus_enable_q),
      .force_t(func_slp_sl_force[0]),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b[0]),
      .sg(sg_0[0]),
      .scin (siv[debug_mux_ctrls_offset : debug_mux_ctrls_offset + 11-1]),
      .scout(sov[debug_mux_ctrls_offset : debug_mux_ctrls_offset + 11-1]),
      .din(spr_debug_mux_ctrls),
      .dout(debug_mux_ctrls_q)
   );
   tri_rlmreg_p #(.WIDTH(32), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) debug_data_out_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(trace_bus_enable_q),
      .force_t(func_slp_sl_force[0]),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b[0]),
      .sg(sg_0[0]),
      .scin (siv[debug_data_out_offset : debug_data_out_offset + 31]),
      .scout(sov[debug_data_out_offset : debug_data_out_offset + 31]),
      .din(debug_data_out_d),
      .dout(debug_data_out_q)
   );

      // ABST Latch Instances

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) abist_g8t_wenb_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(pc_xu_abist_ena_dc),
         .force_t(abst_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(abst_sl_thold_0_b),
         .sg(sg_0[0]),
         .scin(siv_abst[abist_g8t_wenb_offset_abst]),
         .scout(sov_abst[abist_g8t_wenb_offset_abst]),
         .din(pc_xu_abist_g8t_wenb),
         .dout(abist_g8t_wenb_q)
      );

      tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) abist_waddr_0_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(pc_xu_abist_ena_dc),
         .force_t(abst_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(abst_sl_thold_0_b),
         .sg(sg_0[0]),
         .scin(siv_abst[abist_waddr_0_offset_abst:abist_waddr_0_offset_abst + 6 - 1]),
         .scout(sov_abst[abist_waddr_0_offset_abst:abist_waddr_0_offset_abst + 6 - 1]),
         .din(pc_xu_abist_waddr_0),
         .dout(abist_waddr_0_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) abist_di_0_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(pc_xu_abist_ena_dc),
         .force_t(abst_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(abst_sl_thold_0_b),
         .sg(sg_0[0]),
         .scin(siv_abst[abist_di_0_offset_abst:abist_di_0_offset_abst + 4 - 1]),
         .scout(sov_abst[abist_di_0_offset_abst:abist_di_0_offset_abst + 4 - 1]),
         .din(pc_xu_abist_di_0),
         .dout(abist_di_0_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) abist_g8t1p_renb_0_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(pc_xu_abist_ena_dc),
         .force_t(abst_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(abst_sl_thold_0_b),
         .sg(sg_0[0]),
         .scin(siv_abst[abist_g8t1p_renb_0_offset_abst]),
         .scout(sov_abst[abist_g8t1p_renb_0_offset_abst]),
         .din(pc_xu_abist_g8t1p_renb_0),
         .dout(abist_g8t1p_renb_0_q)
      );

      tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) abist_raddr_0_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(pc_xu_abist_ena_dc),
         .force_t(abst_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(abst_sl_thold_0_b),
         .sg(sg_0[0]),
         .scin(siv_abst[abist_raddr_0_offset_abst:abist_raddr_0_offset_abst + 6 - 1]),
         .scout(sov_abst[abist_raddr_0_offset_abst:abist_raddr_0_offset_abst + 6 - 1]),
         .din(pc_xu_abist_raddr_0),
         .dout(abist_raddr_0_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) abist_wl32_comp_ena_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(pc_xu_abist_ena_dc),
         .force_t(abst_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(abst_sl_thold_0_b),
         .sg(sg_0[0]),
         .scin(siv_abst[abist_wl32_comp_ena_offset_abst]),
         .scout(sov_abst[abist_wl32_comp_ena_offset_abst]),
         .din(pc_xu_abist_wl32_comp_ena),
         .dout(abist_wl32_comp_ena_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) abist_g8t_dcomp_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(pc_xu_abist_ena_dc),
         .force_t(abst_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(abst_sl_thold_0_b),
         .sg(sg_0[0]),
         .scin(siv_abst[abist_g8t_dcomp_offset_abst:abist_g8t_dcomp_offset_abst + 4 - 1]),
         .scout(sov_abst[abist_g8t_dcomp_offset_abst:abist_g8t_dcomp_offset_abst + 4 - 1]),
         .din(pc_xu_abist_g8t_dcomp),
         .dout(abist_g8t_dcomp_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) abist_g8t_bw_1_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(pc_xu_abist_ena_dc),
         .force_t(abst_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(abst_sl_thold_0_b),
         .sg(sg_0[0]),
         .scin(siv_abst[abist_g8t_bw_1_offset_abst]),
         .scout(sov_abst[abist_g8t_bw_1_offset_abst]),
         .din(pc_xu_abist_g8t_bw_1),
         .dout(abist_g8t_bw_1_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) abist_g8t_bw_0_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(pc_xu_abist_ena_dc),
         .force_t(abst_sl_force),
         .d_mode(d_mode_dc),
         .delay_lclkr(delay_lclkr_dc),
         .mpw1_b(mpw1_dc_b),
         .mpw2_b(mpw2_dc_b),
         .thold_b(abst_sl_thold_0_b),
         .sg(sg_0[0]),
         .scin(siv_abst[abist_g8t_bw_0_offset_abst]),
         .scout(sov_abst[abist_g8t_bw_0_offset_abst]),
         .din(pc_xu_abist_g8t_bw_0),
         .dout(abist_g8t_bw_0_q)
      );

      tri_regs #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) abst_scan_in_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(delay_lclkr_dc),
         .thold_b(abst_so_thold_0_b),
         .scin(siv_abst[0:0]),
         .scout(sov_abst[0:0])
      );

      tri_regs #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) abst_scan_out_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(delay_lclkr_dc),
         .thold_b(abst_so_thold_0_b),
         .scin(siv_abst[scan_right_abst-1:scan_right_abst-1]),
         .scout(sov_abst[scan_right_abst-1:scan_right_abst-1])
      );

      tri_regs #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) bcfg_scan_in_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(delay_lclkr_dc),
         .thold_b(bcfg_so_thold_0_b),
         .scin(siv_bcfg[0:0]),
         .scout(sov_bcfg[0:0])
      );

      tri_regs #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) bcfg_scan_out_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(delay_lclkr_dc),
         .thold_b(bcfg_so_thold_0_b),
         .scin(siv_bcfg[2:2]),
         .scout(sov_bcfg[2:2])
      );

      tri_regs #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ccfg_scan_in_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(delay_lclkr_dc),
         .thold_b(ccfg_so_thold_0_b),
         .scin(siv_ccfg[0:0]),
         .scout(sov_ccfg[0:0])
      );

      tri_regs #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ccfg_scan_out_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(delay_lclkr_dc),
         .thold_b(ccfg_so_thold_0_b),
         .scin(siv_ccfg[`THREADS+2:`THREADS+2]),
         .scout(sov_ccfg[`THREADS+2:`THREADS+2])
      );

      tri_regs #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) dcfg_scan_in_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(delay_lclkr_dc),
         .thold_b(dcfg_so_thold_0_b),
         .scin(siv_dcfg[0:0]),
         .scout(sov_dcfg[0:0])
      );

      tri_regs #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) dcfg_scan_out_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(delay_lclkr_dc),
         .thold_b(dcfg_so_thold_0_b),
         .scin(siv_dcfg[`THREADS+2:`THREADS+2]),
         .scout(sov_dcfg[`THREADS+2:`THREADS+2])
      );

      tri_regs #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) time_scan_in_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(delay_lclkr_dc),
         .thold_b(time_so_thold_0_b),
         .scin(siv_time[0:0]),
         .scout(sov_time[0:0])
      );

      tri_regs #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) time_scan_out_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(delay_lclkr_dc),
         .thold_b(time_so_thold_0_b),
         .scin(siv_time[2:2]),
         .scout(sov_time[2:2])
      );

      tri_regs #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) repr_scan_in_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(delay_lclkr_dc),
         .thold_b(repr_so_thold_0_b),
         .scin(siv_repr[0:0]),
         .scout(sov_repr[0:0])
      );

      tri_regs #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) repr_scan_out_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(delay_lclkr_dc),
         .thold_b(repr_so_thold_0_b),
         .scin(siv_repr[2:2]),
         .scout(sov_repr[2:2])
      );

      tri_regs #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) gptr_scan_in_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(1'b1),
         .thold_b(gptr_so_thold_0_b),
         .scin(siv_gptr[0:0]),
         .scout(sov_gptr[0:0])
      );

      tri_regs #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) gptr_scan_out_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(1'b1),
         .thold_b(gptr_so_thold_0_b),
         .scin(siv_gptr[2:2]),
         .scout(sov_gptr[2:2])
      );

      tri_regs #(.WIDTH((`THREADS+2)), .INIT(0), .NEEDS_SRESET(1)) func_scan_in_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(delay_lclkr_dc),
         .thold_b(func_so_thold_0_b),
         .scin(func_scan_in),
         .scout(func_scan_rpwr_in)
      );

      tri_regs #(.WIDTH((`THREADS+2)), .INIT(0), .NEEDS_SRESET(1)) func_scan_out_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .force_t(so_force),
         .delay_lclkr(delay_lclkr_dc),
         .thold_b(func_so_thold_0_b),
         .scin(func_scan_rpwr_out),
         .scout(func_scan_gate_out)
      );

      //-----------------------------------------------
      // Pervasive
      //-----------------------------------------------

      tri_lcbcntl_array_mac lcbctrl_g8t(
         .vdd(vdd),
         .gnd(gnd),
         .sg(sg_0[0]),
         .nclk(nclk),
         .scan_diag_dc(an_ac_scan_diag_dc),
         .thold(gptr_sl_thold_0),
         .clkoff_dc_b(g8t_clkoff_dc_b),
         .delay_lclkr_dc(g8t_delay_lclkr_dc[0:4]),
         .act_dis_dc(),
         .d_mode_dc(g8t_d_mode_dc),
         .mpw1_dc_b(g8t_mpw1_dc_b[0:4]),
         .mpw2_dc_b(g8t_mpw2_dc_b),
         .scan_in(siv_gptr[1]),
         .scan_out(sov_gptr[1])
      );


      tri_plat #(.WIDTH(1)) perv_2to1_reg_00 (.din(func_slp_sl_thold_2   ),.q(func_slp_sl_thold_1   ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
      tri_plat #(.WIDTH(1)) perv_2to1_reg_01 (.din(func_sl_thold_2       ),.q(func_sl_thold_1       ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
      tri_plat #(.WIDTH(1)) perv_2to1_reg_02 (.din(func_slp_nsl_thold_2  ),.q(func_slp_nsl_thold_1  ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
      tri_plat #(.WIDTH(1)) perv_2to1_reg_03 (.din(func_nsl_thold_2      ),.q(func_nsl_thold_1      ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
      tri_plat #(.WIDTH(1)) perv_2to1_reg_04 (.din(time_sl_thold_2       ),.q(time_sl_thold_1       ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
      tri_plat #(.WIDTH(1)) perv_2to1_reg_05 (.din(repr_sl_thold_2       ),.q(repr_sl_thold_1       ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
      tri_plat #(.WIDTH(1)) perv_2to1_reg_06 (.din(gptr_sl_thold_2       ),.q(gptr_sl_thold_1       ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
      tri_plat #(.WIDTH(1)) perv_2to1_reg_07 (.din(bolt_sl_thold_2       ),.q(bolt_sl_thold_1       ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
      tri_plat #(.WIDTH(1)) perv_2to1_reg_08 (.din(abst_sl_thold_2       ),.q(abst_sl_thold_1       ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
      tri_plat #(.WIDTH(1)) perv_2to1_reg_09 (.din(ary_nsl_thold_2       ),.q(ary_nsl_thold_1       ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
      tri_plat #(.WIDTH(1)) perv_2to1_reg_10 (.din(cfg_sl_thold_2        ),.q(cfg_sl_thold_1        ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
      tri_plat #(.WIDTH(1)) perv_2to1_reg_11 (.din(cfg_slp_sl_thold_2    ),.q(cfg_slp_sl_thold_1    ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
      tri_plat #(.WIDTH(1)) perv_2to1_reg_12 (.din(sg_2                  ),.q(sg_1                  ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
      tri_plat #(.WIDTH(1)) perv_2to1_reg_13 (.din(fce_2                 ),.q(fce_1                 ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));

      generate
         begin : perv_1to0_reg_gen
            genvar                              t;
            for (t = 0; t <= `THREADS; t = t + 1)
            begin : thread

               tri_plat #(.WIDTH(1)) perv_1to0_reg_0 (.din(func_slp_sl_thold_1),.q(func_slp_sl_thold_0[t] ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
               tri_plat #(.WIDTH(1)) perv_1to0_reg_1 (.din(func_sl_thold_1    ),.q(func_sl_thold_0[t]     ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
               tri_plat #(.WIDTH(1)) perv_1to0_reg_2 (.din(func_nsl_thold_1   ),.q(func_nsl_thold_0[t]    ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
               tri_plat #(.WIDTH(1)) perv_1to0_reg_3 (.din(cfg_sl_thold_1     ),.q(cfg_sl_thold_0[t]      ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
               tri_plat #(.WIDTH(1)) perv_1to0_reg_4 (.din(sg_1               ),.q(sg_0[t]                ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
               tri_plat #(.WIDTH(1)) perv_1to0_reg_5 (.din(fce_1              ),.q(fce_0[t]               ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));


               tri_lcbor perv_lcbor_cfg_sl(
                  .clkoff_b(clkoff_dc_b),
                  .thold(cfg_sl_thold_0[t]),
                  .sg(sg_0[t]),
                  .act_dis(act_dis),
                  .force_t(cfg_sl_force[t]),
                  .thold_b(cfg_sl_thold_0_b[t])
               );


               tri_lcbor perv_lcbor_func_sl(
                  .clkoff_b(clkoff_dc_b),
                  .thold(func_sl_thold_0[t]),
                  .sg(sg_0[t]),
                  .act_dis(act_dis),
                  .force_t(func_sl_force[t]),
                  .thold_b(func_sl_thold_0_b[t])
               );


               tri_lcbor perv_lcbor_func_slp_sl(
                  .clkoff_b(clkoff_dc_b),
                  .thold(func_slp_sl_thold_0[t]),
                  .sg(sg_0[t]),
                  .act_dis(act_dis),
                  .force_t(func_slp_sl_force[t]),
                  .thold_b(func_slp_sl_thold_0_b[t])
               );


               tri_lcbor perv_lcbor_func_nsl(
                  .clkoff_b(clkoff_dc_b),
                  .thold(func_nsl_thold_0[t]),
                  .sg(fce_0[t]),
                  .act_dis(act_dis),
                  .force_t(func_nsl_force[t]),
                  .thold_b(func_nsl_thold_0_b[t])
               );
            end
         end
      endgenerate

   assign ccfg_sl_force = cfg_sl_force;
   assign ccfg_sl_thold_0_b = cfg_sl_thold_0_b;
   assign dcfg_sl_force[0:`THREADS] = cfg_sl_force[0:`THREADS];
   assign dcfg_sl_thold_0_b[0:`THREADS] = cfg_sl_thold_0_b[0:`THREADS];

   assign bcfg_sl_force[0] = cfg_sl_force[0];
   assign bcfg_sl_thold_0_b[0] = cfg_sl_thold_0_b[0];

   assign bcfg_slp_sl_force = cfg_slp_sl_force;
   assign bcfg_slp_sl_thold_0_b = cfg_slp_sl_thold_0_b;
   assign ccfg_slp_sl_force = cfg_slp_sl_force;
   assign ccfg_slp_sl_thold_0_b = cfg_slp_sl_thold_0_b;


   tri_lcbor perv_lcbor_cfg_slp_sl(
      .clkoff_b(clkoff_dc_b),
      .thold(cfg_slp_sl_thold_0),
      .sg(sg_0[0]),
      .act_dis(act_dis),
      .force_t(cfg_slp_sl_force),
      .thold_b(cfg_slp_sl_thold_0_b)
   );


   tri_lcbor perv_lcbor_func_slp_nsl(
      .clkoff_b(clkoff_dc_b),
      .thold(func_slp_nsl_thold_0),
      .sg(fce_0[0]),
      .act_dis(act_dis),
      .force_t(func_slp_nsl_force),
      .thold_b(func_slp_nsl_thold_0_b)
   );


   tri_plat #(.WIDTH(1)) perv_1to0_reg_0 (.din(abst_sl_thold_1      ),.q(abst_sl_thold_0      ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
   tri_plat #(.WIDTH(1)) perv_1to0_reg_1 (.din(ary_nsl_thold_1      ),.q(ary_nsl_thold_0      ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
   tri_plat #(.WIDTH(1)) perv_1to0_reg_2 (.din(time_sl_thold_1      ),.q(time_sl_thold_0      ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
   tri_plat #(.WIDTH(1)) perv_1to0_reg_3 (.din(repr_sl_thold_1      ),.q(repr_sl_thold_0      ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
   tri_plat #(.WIDTH(1)) perv_1to0_reg_4 (.din(gptr_sl_thold_1      ),.q(gptr_sl_thold_0      ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
   tri_plat #(.WIDTH(1)) perv_1to0_reg_5 (.din(bolt_sl_thold_1      ),.q(bolt_sl_thold_0      ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
   tri_plat #(.WIDTH(1)) perv_1to0_reg_6 (.din(func_slp_nsl_thold_1 ),.q(func_slp_nsl_thold_0 ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));
   tri_plat #(.WIDTH(1)) perv_1to0_reg_7 (.din(cfg_slp_sl_thold_1   ),.q(cfg_slp_sl_thold_0   ),.vd(vdd),.gd(gnd),.nclk(nclk),.flush(pc_xu_ccflush_dc));


   tri_lcbor perv_lcbor_abst_sl(
      .clkoff_b(clkoff_dc_b),
      .thold(abst_sl_thold_0),
      .sg(sg_0[0]),
      .act_dis(act_dis),
      .force_t(abst_sl_force),
      .thold_b(abst_sl_thold_0_b)
   );

   assign so_force = sg_0[0];
   assign abst_so_thold_0_b = (~abst_sl_thold_0);
   assign bcfg_so_thold_0_b = (~cfg_sl_thold_0[0]);
   assign ccfg_so_thold_0_b = (~cfg_sl_thold_0[0]);
   assign dcfg_so_thold_0_b = (~cfg_sl_thold_0[0]);
   assign time_so_thold_0_b = (~time_sl_thold_0);
   assign repr_so_thold_0_b = (~repr_sl_thold_0);
   assign gptr_so_thold_0_b = (~gptr_sl_thold_0);
   assign func_so_thold_0_b = (~func_sl_thold_0[0]);

   assign func_scan_out =  an_ac_scan_dis_dc_b==1'b1 ? func_scan_gate_out : {`THREADS+2{1'b0}};

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], func_scan_rpwr_in[`THREADS + 1]};
   assign func_scan_rpwr_out[`THREADS + 1] = sov[0];

   assign siv_abst[0:scan_right_abst-1] = {sov_abst[1:scan_right_abst-1], abst_scan_in};
   assign abst_scan_out = sov_abst[0] & an_ac_scan_dis_dc_b;

   assign siv_bcfg[0:2] = {sov_bcfg[1:2], bcfg_scan_in};
   assign bcfg_scan_out = sov_bcfg[0] & an_ac_scan_dis_dc_b;

   assign siv_ccfg[0:`THREADS+2] = {sov_ccfg[1:`THREADS+2], ccfg_scan_in};
   assign ccfg_scan_out = sov_ccfg[0] & an_ac_scan_dis_dc_b;

   assign siv_dcfg[0:`THREADS+2] = {sov_dcfg[1:`THREADS+2], dcfg_scan_in};
   assign dcfg_scan_out = sov_dcfg[0] & an_ac_scan_dis_dc_b;

   assign siv_time[0:2] = {sov_time[1:2], time_scan_in};
   assign time_scan_out = sov_time[0] & an_ac_scan_dis_dc_b;

   assign siv_repr[0:2] = {sov_repr[1:2], repr_scan_in};
   assign repr_scan_out = sov_repr[0] & an_ac_scan_dis_dc_b;

   assign siv_gptr[0:2] = {sov_gptr[1:2], gptr_scan_in};
   assign gptr_scan_out = sov_gptr[0] & an_ac_scan_dis_dc_b;

endmodule
