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

//  Description:  XU SPR - per thread register slice
//
//*****************************************************************************
`include "tri_a2o.vh"
module xu_spr_tspr
#(
   parameter                    hvmode = 1,
   parameter                    a2mode = 1
)(
   input [0:`NCLK_WIDTH-1] nclk,

   // CHIP IO
   input                        an_ac_ext_interrupt,
   input                        an_ac_crit_interrupt,
   input                        an_ac_perf_interrupt,
   input                        an_ac_hang_pulse,
   output                       ac_tc_machine_check,
   input                        an_ac_external_mchk,
   input                        instr_trace_mode,

   input                        d_mode_dc,
   input [0:0]                  delay_lclkr_dc,
   input [0:0]                  mpw1_dc_b,
   input                        mpw2_dc_b,
   input                        ccfg_sl_force,
   input                        ccfg_sl_thold_0_b,
   input                        dcfg_sl_force,
   input                        dcfg_sl_thold_0_b,
   input                        func_sl_force,
   input                        func_sl_thold_0_b,
   input                        func_slp_sl_force,
   input                        func_slp_sl_thold_0_b,
   input                        func_nsl_force,
   input                        func_nsl_thold_0_b,
   input                        sg_0,
   input                        scan_in,
   output                       scan_out,
   input                        ccfg_scan_in,
   output                       ccfg_scan_out,
   input                        dcfg_scan_in,
   output                       dcfg_scan_out,

   input                        cspr_tspr_rf1_act,

   // Read Interface
   input [0:31]                 cspr_tspr_ex1_instr,
   input                        cspr_tspr_ex2_tid,
   output [64-`GPR_WIDTH:63]       tspr_cspr_ex3_tspr_rt,

   // Write Interface
   input [64-`GPR_WIDTH:63]        ex2_spr_wd,
   input                        ex3_spr_we,

   input                        cspr_tspr_dec_dbg_dis,

   // Illegal SPR
   output                       tspr_cspr_illeg_mtspr_b,
   output                       tspr_cspr_illeg_mfspr_b,
   output                       tspr_cspr_hypv_mtspr,
   output                       tspr_cspr_hypv_mfspr,

   // Interrupt Interface
   input                        iu_xu_rfi,
   input                        iu_xu_rfgi,
   input                        iu_xu_rfci,
   input                        iu_xu_rfmci,
   input                        iu_xu_act,
   input                        iu_xu_int,
   input                        iu_xu_gint,
   input                        iu_xu_cint,
   input                        iu_xu_mcint,
   input [62-`EFF_IFAR_ARCH:61]       iu_xu_nia,
   input [0:16]                 iu_xu_esr,
   input [0:14]                 iu_xu_mcsr,
   input [0:18]                 iu_xu_dbsr,
   input [64-`GPR_WIDTH:63]        iu_xu_dear,
   input                        iu_xu_dear_update,
   input                        iu_xu_dbsr_update,
   input                        iu_xu_esr_update,
   input                        iu_xu_force_gsrr,
   input                        iu_xu_dbsr_ude,
   input                        iu_xu_dbsr_ide,
   output                       xu_iu_dbsr_ide,
   output                       int_rest_act,
   output [62-`EFF_IFAR_ARCH:61]      int_rest_ifar,
   input [62-`EFF_IFAR_WIDTH:61] ex2_ifar,

   // Async Interrupt Req Interface
   output                       xu_iu_external_mchk,
   output                       xu_iu_ext_interrupt,
   output                       xu_iu_dec_interrupt,
   output                       xu_iu_udec_interrupt,
   output                       xu_iu_perf_interrupt,
   output                       xu_iu_fit_interrupt,
   output                       xu_iu_crit_interrupt,
   output                       xu_iu_wdog_interrupt,
   output                       xu_iu_gwdog_interrupt,
   output                       xu_iu_gfit_interrupt,
   output                       xu_iu_gdec_interrupt,

   input                        cspr_tspr_sleep_mask,
   input                        cspr_tspr_crit_mask,
   input                        cspr_tspr_wdog_mask,
   input                        cspr_tspr_dec_mask,
   input                        cspr_tspr_udec_mask,
   input                        cspr_tspr_perf_mask,
   input                        cspr_tspr_fit_mask,
   input                        cspr_tspr_ext_mask,

   output                       tspr_cspr_pm_wake_up,
   output [0:2]                 tspr_cspr_async_int,

   output                       tspr_cspr_ex2_np1_flush,

   // DBELL Int
   input [50:63]                cspr_tspr_dbell_pirtag,
   output                       tspr_cspr_gpir_match,

   input [0:9]                  cspr_tspr_timebase_taps,
   input                        timer_update,

   // Debug
   output                       xu_iu_iac1_en,
   output                       xu_iu_iac2_en,
   output                       xu_iu_iac3_en,
   output                       xu_iu_iac4_en,
   output                       tspr_cspr_freeze_timers,

   // Run State
   output                       xu_iu_single_instr_mode,
   output                       xu_iu_raise_iss_pri,
   output                       xu_pc_stop_dnh_instr,

   // LiveLock
   input                        iu_xu_instr_cpl,
   input                        cspr_tspr_llen,
   input                        cspr_tspr_llpri,
   output                       tspr_cspr_lldet,
   output                       tspr_cspr_llpulse,
   output                       xu_pc_err_llbust_attempt,
   output                       xu_pc_err_llbust_failed,
   input                        pc_xu_inj_llbust_attempt,
   input                        pc_xu_inj_llbust_failed,

   // Resets
   input                        pc_xu_inj_wdt_reset,
   input                        reset_wd_complete,
   input                        reset_1_complete,
   input                        reset_2_complete,
   input                        reset_3_complete,
   output                       reset_1_request,
   output                       reset_2_request,
   output                       reset_3_request,
   output                       reset_wd_request,
   output                       xu_pc_err_wdt_reset,

   // MSR Override
   input                        cspr_tspr_ram_active,
   input                        cspr_tspr_msrovride_en,
   input                        pc_xu_msrovride_pr,
   input                        pc_xu_msrovride_gs,
   input                        pc_xu_msrovride_de,

   // SIAR
   input                        pc_xu_spr_cesr1_pmae,
   output                       xu_pc_perfmon_alert,

   // SPRs
   input                        spr_dbcr0_edm,
   output                       tspr_epcr_icm,
   output                       tspr_epcr_gicm,
   output                       tspr_msr_de,
   output                       tspr_msr_cm,
   output                       tspr_msr_pr,
   output                       tspr_msr_is,
   output                       tspr_msr_gs,
   output                       tspr_msr_ee,
   output                       tspr_msr_ce,
   output                       tspr_msr_me,
   output                       tspr_msr_fe0,
   output                       tspr_msr_fe1,
   output                       tspr_fp_precise,
   output                       tspr_epcr_extgs,
   input [4:4]                  cspr_xucr0_clkg_ctl,
   input                        cspr_ccr4_en_dnh,
   output [0:`GPR_WIDTH-1]         spr_dvc1,
   output [0:`GPR_WIDTH-1]         spr_dvc2,
	output                              spr_dbcr0_idm,
	output                              spr_dbcr0_icmp,
	output                              spr_dbcr0_brt,
	output                              spr_dbcr0_irpt,
	output                              spr_dbcr0_trap,
	output [0:1]                        spr_dbcr0_dac1,
	output [0:1]                        spr_dbcr0_dac2,
	output                              spr_dbcr0_ret,
	output [0:1]                        spr_dbcr0_dac3,
	output [0:1]                        spr_dbcr0_dac4,
	output                              spr_dbcr1_iac12m,
	output                              spr_dbcr1_iac34m,
	output                              spr_epcr_dtlbgs,
	output                              spr_epcr_itlbgs,
	output                              spr_epcr_dsigs,
	output                              spr_epcr_isigs,
	output                              spr_epcr_duvd,
	output                              spr_epcr_dgtmi,
	output                              xu_mm_spr_epcr_dmiuh,
	output                              spr_msr_ucle,
	output                              spr_msr_spv,
	output                              spr_msr_fp,
	output                              spr_msr_ds,
	output                              spr_msrp_uclep,

   output [0:11]                tspr_debug,

   // Power
   inout                        vdd,
   inout                        gnd
);

   localparam                   DEX2 = 0;
   localparam                   DEX3 = 0;
   localparam                   DEX4 = 0;
   localparam                   DEX5 = 0;
   localparam                   DEX6 = 0;
   localparam                   DWR = 0;
   localparam                   DX = 0;
	// SPR Bit Constants
	localparam MSR_CM                   = 50;
	localparam MSR_GS                   = 51;
	localparam MSR_UCLE                 = 52;
	localparam MSR_SPV                  = 53;
	localparam MSR_CE                   = 54;
	localparam MSR_EE                   = 55;
	localparam MSR_PR                   = 56;
	localparam MSR_FP                   = 57;
	localparam MSR_ME                   = 58;
	localparam MSR_FE0                  = 59;
	localparam MSR_DE                   = 60;
	localparam MSR_FE1                  = 61;
	localparam MSR_IS                   = 62;
	localparam MSR_DS                   = 63;
	localparam MSRP_UCLEP               = 62;
	localparam MSRP_DEP                 = 63;
	// SPR Registers
	wire [62:63]                  ccr3_d,                   ccr3_q;
	wire [64-(`EFF_IFAR_ARCH):63] csrr0_d,                  csrr0_q;
	wire [50:63]                  csrr1_d,                  csrr1_q;
	wire [43:63]                  dbcr0_d,                  dbcr0_q;
	wire [46:63]                  dbcr1_d,                  dbcr1_q;
	wire [44:63]                  dbsr_d,                   dbsr_q;
	wire [64-(`GPR_WIDTH):63]     dear_d,                   dear_q;
	wire [32:63]                  dec_d,                    dec_q;
	wire [32:63]                  decar_d,                  decar_q;
	wire [49:63]                  dnhdr_d,                  dnhdr_q;
	wire [54:63]                  epcr_d,                   epcr_q;
	wire [47:63]                  esr_d,                    esr_q;
	wire [64-(`GPR_WIDTH):63]     gdear_d,                  gdear_q;
	wire [32:63]                  gdec_d,                   gdec_q;
	wire [32:63]                  gdecar_d,                 gdecar_q;
	wire [47:63]                  gesr_d,                   gesr_q;
	wire [32:63]                  gpir_d,                   gpir_q;
	wire [64-(`EFF_IFAR_ARCH):63] gsrr0_d,                  gsrr0_q;
	wire [50:63]                  gsrr1_d,                  gsrr1_q;
	wire [54:63]                  gtcr_d,                   gtcr_q;
	wire [60:63]                  gtsr_d,                   gtsr_q;
	wire [49:63]                  mcsr_d,                   mcsr_q;
	wire [64-(`EFF_IFAR_ARCH):63] mcsrr0_d,                 mcsrr0_q;
	wire [50:63]                  mcsrr1_d,                 mcsrr1_q;
	wire [50:63]                  msr_d,                    msr_q;
	wire [62:63]                  msrp_d,                   msrp_q;
	wire [62-(`EFF_IFAR_ARCH):63] siar_d,                   siar_q;
	wire [64-(`EFF_IFAR_ARCH):63] srr0_d,                   srr0_q;
	wire [50:63]                  srr1_d,                   srr1_q;
	wire [52:63]                  tcr_d,                    tcr_q;
	wire [59:63]                  tsr_d,                    tsr_q;
	wire [32:63]                  udec_d,                   udec_q;
	wire [59:63]                  xucr1_d,                  xucr1_q;
   wire [64-(`GPR_WIDTH):63]       dvc1_d;
   wire [64-(`GPR_WIDTH):63]       dvc1_q;
   wire [64-(`GPR_WIDTH):63]       dvc2_d;
   wire [64-(`GPR_WIDTH):63]       dvc2_q;
   // FUNC Scanchain
	localparam csrr0_offset                   = 0;
	localparam csrr1_offset                   = csrr0_offset                   + `EFF_IFAR_ARCH*a2mode;
	localparam dbcr1_offset                   = csrr1_offset                   + 14*a2mode;
	localparam dbsr_offset                    = dbcr1_offset                   + 18;
	localparam dear_offset                    = dbsr_offset                    + 20;
	localparam dec_offset                     = dear_offset                    + `GPR_WIDTH;
	localparam decar_offset                   = dec_offset                     + 32;
	localparam epcr_offset                    = decar_offset                   + 32*a2mode;
	localparam esr_offset                     = epcr_offset                    + 10*hvmode;
	localparam gdear_offset                   = esr_offset                     + 17;
	localparam gdec_offset                    = gdear_offset                   + `GPR_WIDTH*hvmode;
	localparam gdecar_offset                  = gdec_offset                    + 32*hvmode;
	localparam gesr_offset                    = gdecar_offset                  + 32*hvmode;
	localparam gpir_offset                    = gesr_offset                    + 17*hvmode;
	localparam gsrr0_offset                   = gpir_offset                    + 32*hvmode;
	localparam gsrr1_offset                   = gsrr0_offset                   + `EFF_IFAR_ARCH*hvmode;
	localparam gtcr_offset                    = gsrr1_offset                   + 14*hvmode;
	localparam gtsr_offset                    = gtcr_offset                    + 10*hvmode;
	localparam mcsr_offset                    = gtsr_offset                    + 4*hvmode;
	localparam mcsrr0_offset                  = mcsr_offset                    + 15*a2mode;
	localparam mcsrr1_offset                  = mcsrr0_offset                  + `EFF_IFAR_ARCH*a2mode;
	localparam msrp_offset                    = mcsrr1_offset                  + 14*a2mode;
	localparam siar_offset                    = msrp_offset                    + 2*hvmode;
	localparam srr0_offset                    = siar_offset                    + `EFF_IFAR_ARCH+2;
	localparam srr1_offset                    = srr0_offset                    + `EFF_IFAR_ARCH;
	localparam tcr_offset                     = srr1_offset                    + 14;
	localparam tsr_offset                     = tcr_offset                     + 12*a2mode;
	localparam udec_offset                    = tsr_offset                     + 5*a2mode;
	localparam last_reg_offset                = udec_offset                    + 32*a2mode;
   // BCFG Scanchain
	localparam last_reg_offset_bcfg           = 1;
   // CCFG Scanchain
	localparam ccr3_offset_ccfg               = 0;
	localparam msr_offset_ccfg                = ccr3_offset_ccfg               + 2;
	localparam xucr1_offset_ccfg              = msr_offset_ccfg                + 14;
	localparam last_reg_offset_ccfg           = xucr1_offset_ccfg              + 5;
   // DCFG Scanchain
	localparam dbcr0_offset_dcfg              = 0;
	localparam dnhdr_offset_dcfg              = dbcr0_offset_dcfg              + 21;
	localparam last_reg_offset_dcfg           = dnhdr_offset_dcfg              + 15;
   // Latches
   wire                          iu_xu_act_q                                           ; // input=>iu_xu_act                  , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire [1:2]                    exx_act_q,                 exx_act_d                  ; // input=>exx_act_d                  , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          ex2_is_mfmsr_q,            ex1_is_mfmsr               ; // input=>ex1_is_mfmsr               , act=>exx_act(1)  , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                          ex2_wrtee_q,               ex1_is_wrtee               ; // input=>ex1_is_wrtee               , act=>exx_act(1)  , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                          ex2_wrteei_q,              ex1_is_wrteei              ; // input=>ex1_is_wrteei              , act=>exx_act(1)  , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                          ex2_dnh_q,                 ex1_is_dnh                 ; // input=>ex1_is_dnh                 , act=>exx_act(1)  , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                          ex2_is_mtmsr_q,            ex1_is_mtmsr               ; // input=>ex1_is_mtmsr               , act=>exx_act(1)  , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                          ex2_is_mtspr_q,            ex1_is_mtspr               ; // input=>ex1_is_mtspr               , act=>exx_act(1)  , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire [6:20]                   ex2_instr_q,               ex2_instr_d                ; // input=>ex2_instr_d                , act=>exx_act(1)  , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
   wire                          ex3_is_mtspr_q                                        ; // input=>ex2_is_mtspr_q             , act=>exx_act(2)  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire [6:20]                   ex3_instr_q                                           ; // input=>ex2_instr_q                , act=>exx_act(2)  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          ex3_wrtee_q                                           ; // input=>ex2_wrtee_q                , act=>exx_act(2)  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          ex3_wrteei_q                                          ; // input=>ex2_wrteei_q               , act=>exx_act(2)  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          ex3_dnh_q                                             ; // input=>ex2_dnh_q                  , act=>exx_act(2)  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          ex3_is_mtmsr_q                                        ; // input=>ex2_is_mtmsr_q             , act=>exx_act(2)  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iu_rfi_q                                              ; // input=>iu_xu_rfi                  , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iu_rfgi_q                                             ; // input=>iu_xu_rfgi                 , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iu_rfci_q                                             ; // input=>iu_xu_rfci                 , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iu_rfmci_q                                            ; // input=>iu_xu_rfmci                , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iu_int_q                                              ; // input=>iu_xu_int                  , act=>iu_int_act  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iu_gint_q                                             ; // input=>iu_xu_gint                 , act=>iu_int_act  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iu_cint_q                                             ; // input=>iu_xu_cint                 , act=>iu_int_act  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iu_mcint_q                                            ; // input=>iu_xu_mcint                , act=>iu_int_act  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire [64-`GPR_WIDTH:63]       iu_dear_q                                             ; // input=>iu_xu_dear                 , act=>iu_xu_dear_update , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire [62-`EFF_IFAR_ARCH:61]   iu_nia_q                                              ; // input=>iu_xu_nia                  , act=>iu_nia_act        , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire [0:16]                   iu_esr_q                                              ; // input=>iu_xu_esr                  , act=>iu_xu_esr_update  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire [0:14]                   iu_mcsr_q                                             ; // input=>iu_xu_mcsr                 , act=>iu_int_act        , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire [0:18]                   iu_dbsr_q                                             ; // input=>iu_xu_dbsr                 , act=>iu_xu_dbsr_update , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iu_dear_update_q                                      ; // input=>iu_xu_dear_update          , act=>iu_int_act  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iu_dbsr_update_q                                      ; // input=>iu_xu_dbsr_update          , act=>iu_int_act  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iu_esr_update_q                                       ; // input=>iu_xu_esr_update           , act=>iu_int_act  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iu_force_gsrr_q                                       ; // input=>iu_xu_force_gsrr           , act=>iu_int_act  , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iu_dbsr_ude_q                                         ; // input=>iu_xu_dbsr_ude             , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iu_dbsr_ide_q                                         ; // input=>iu_xu_dbsr_ide             , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire [64-`GPR_WIDTH:63]       ex3_spr_wd_q                                          ; // input=>ex2_spr_wd                 , act=>exx_act_data(2), scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire [0:`GPR_WIDTH/8-1]       ex3_tid_rpwr_q,            ex3_tid_rpwr_d             ; // input=>ex3_tid_rpwr_d             , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire [64-`GPR_WIDTH:63]       ex3_tspr_rt_q,             ex3_tspr_rt_d              ; // input=>ex3_tspr_rt_d              , act=>exx_act_data(2), scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          fit_tb_tap_q,              fit_tb_tap_d               ; // input=>fit_tb_tap_d               , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          wdog_tb_tap_q,             wdog_tb_tap_d              ; // input=>wdog_tb_tap_d              , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          gfit_tb_tap_q,             gfit_tb_tap_d              ; // input=>gfit_tb_tap_d              , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          gwdog_tb_tap_q,            gwdog_tb_tap_d             ; // input=>gwdog_tb_tap_d             , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire [0:3]                    hang_pulse_q,              hang_pulse_d               ; // input=>hang_pulse_d               , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          lltap_q,                   lltap_d                    ; // input=>lltap_d                    , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire [0:1]                    llcnt_q,                   llcnt_d                    ; // input=>llcnt_d                    , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          msrovride_pr_q                                        ; // input=>pc_xu_msrovride_pr         , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          msrovride_gs_q                                        ; // input=>pc_xu_msrovride_gs         , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          msrovride_de_q                                        ; // input=>pc_xu_msrovride_de         , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          an_ac_ext_interrupt_q                                 ; // input=>an_ac_ext_interrupt        , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          an_ac_crit_interrupt_q                                ; // input=>an_ac_crit_interrupt       , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          an_ac_perf_interrupt_q                                ; // input=>an_ac_perf_interrupt       , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          an_ac_perf_interrupt2_q                               ; // input=>an_ac_perf_interrupt_q     , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire [0:2]                    mux_msr_gs_q,              mux_msr_gs_d               ; // input=>mux_msr_gs_d               , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire [0:0]                    mux_msr_pr_q,              mux_msr_pr_d               ; // input=>mux_msr_pr_d               , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          err_llbust_attempt_q,      err_llbust_attempt_d       ; // input=>err_llbust_attempt_d       , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          err_llbust_failed_q,       err_llbust_failed_d        ; // input=>err_llbust_failed_d        , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          inj_llbust_attempt_q                                  ; // input=>pc_xu_inj_llbust_attempt   , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          inj_llbust_failed_q                                   ; // input=>pc_xu_inj_llbust_failed    , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          an_ac_external_mchk_q                                 ; // input=>an_ac_external_mchk        , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          mchk_interrupt_q,          mchk_interrupt             ; // input=>mchk_interrupt             , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          crit_interrupt_q,          crit_interrupt             ; // input=>crit_interrupt             , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          wdog_interrupt_q,          wdog_interrupt             ; // input=>wdog_interrupt             , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          dec_interrupt_q,           dec_interrupt              ; // input=>dec_interrupt              , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          udec_interrupt_q,          udec_interrupt             ; // input=>udec_interrupt             , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          perf_interrupt_q,          perf_interrupt             ; // input=>perf_interrupt             , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          fit_interrupt_q,           fit_interrupt              ; // input=>fit_interrupt              , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          ext_interrupt_q,           ext_interrupt              ; // input=>ext_interrupt              , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          gwdog_interrupt_q,         gwdog_interrupt            ; // input=>gwdog_interrupt            , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          gdec_interrupt_q,          gdec_interrupt             ; // input=>gdec_interrupt             , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          gfit_interrupt_q,          gfit_interrupt             ; // input=>gfit_interrupt             , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          single_instr_mode_q,       single_instr_mode_d        ; // input=>single_instr_mode_d        , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          single_instr_mode_2_q                                 ; // input=>single_instr_mode_q        , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          machine_check_q,           machine_check_d            ; // input=>machine_check_d            , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          raise_iss_pri_q,           raise_iss_pri_d            ; // input=>raise_iss_pri_d            , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          raise_iss_pri_2_q                                     ; // input=>raise_iss_pri_q            , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          pc_xu_inj_wdt_reset_q                                 ; // input=>pc_xu_inj_wdt_reset        , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          err_wdt_reset_q,           err_wdt_reset_d            ; // input=>err_wdt_reset_d            , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire                          ram_active_q                                          ; // input=>cspr_tspr_ram_active       , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire [0:9]                    timebase_taps_q                                       ; // input=>cspr_tspr_timebase_taps    , act=>1'b1           , scan=>Y, sleep=>Y, ring=>func, needs_sreset=>1
   wire [0:1]                    dbsr_mrr_q,dbsr_mrr_d                                 ; // input=>dbsr_mrr_d                 , act=>dbsr_mrr_act, scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire [0:1]                    tsr_wrs_q,tsr_wrs_d                                   ; // input=>tsr_wrs_d                  , act=>tsr_wrs_act , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iac1_en_q,iac1_en_d                                   ; // input=>iac1_en_d                  , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iac2_en_q,iac2_en_d                                   ; // input=>iac2_en_d                  , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iac3_en_q,iac3_en_d                                   ; // input=>iac3_en_d                  , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          iac4_en_q,iac4_en_d                                   ; // input=>iac4_en_d                  , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          ex3_dnh_val_q                                         ; // input=>ex3_dnh                    , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire                          an_ac_perf_interrupt_edge_q                           ; // input=>an_ac_perf_interrupt_edge  , act=>1'b1           , scan=>Y, sleep=>N, ring=>func, needs_sreset=>1
   wire [0:15]                   spare_0_q,                 spare_0_d                  ; // input=>spare_0_d                  , act=>1'b1,
   // Scanchain
   localparam dvc1_offset                                = last_reg_offset;
   localparam dvc2_offset                                = dvc1_offset                    + `GPR_WIDTH * a2mode;
   localparam iu_xu_act_offset                           = dvc2_offset                    + `GPR_WIDTH * a2mode;
   localparam exx_act_offset                             = iu_xu_act_offset               + 1;
   localparam ex2_is_mfmsr_offset                        = exx_act_offset                 + 2;
   localparam ex2_wrtee_offset                           = ex2_is_mfmsr_offset            + 1;
   localparam ex2_wrteei_offset                          = ex2_wrtee_offset               + 1;
   localparam ex2_dnh_offset                             = ex2_wrteei_offset              + 1;
   localparam ex2_is_mtmsr_offset                        = ex2_dnh_offset                 + 1;
   localparam ex2_is_mtspr_offset                        = ex2_is_mtmsr_offset            + 1;
   localparam ex2_instr_offset                           = ex2_is_mtspr_offset            + 1;
   localparam ex3_is_mtspr_offset                        = ex2_instr_offset               + 15;
   localparam ex3_instr_offset                           = ex3_is_mtspr_offset            + 1;
   localparam ex3_wrtee_offset                           = ex3_instr_offset               + 15;
   localparam ex3_wrteei_offset                          = ex3_wrtee_offset               + 1;
   localparam ex3_dnh_offset                             = ex3_wrteei_offset              + 1;
   localparam ex3_is_mtmsr_offset                        = ex3_dnh_offset                 + 1;
   localparam iu_rfi_offset                              = ex3_is_mtmsr_offset            + 1;
   localparam iu_rfgi_offset                             = iu_rfi_offset                  + 1;
   localparam iu_rfci_offset                             = iu_rfgi_offset                 + 1;
   localparam iu_rfmci_offset                            = iu_rfci_offset                 + 1;
   localparam iu_int_offset                              = iu_rfmci_offset                + 1;
   localparam iu_gint_offset                             = iu_int_offset                  + 1;
   localparam iu_cint_offset                             = iu_gint_offset                 + 1;
   localparam iu_mcint_offset                            = iu_cint_offset                 + 1;
   localparam iu_dear_offset                             = iu_mcint_offset                + 1;
   localparam iu_nia_offset                              = iu_dear_offset                 + `GPR_WIDTH;
   localparam iu_esr_offset                              = iu_nia_offset                  + `EFF_IFAR_ARCH;
   localparam iu_mcsr_offset                             = iu_esr_offset                  + 17;
   localparam iu_dbsr_offset                             = iu_mcsr_offset                 + 15;
   localparam iu_dear_update_offset                      = iu_dbsr_offset                 + 19;
   localparam iu_dbsr_update_offset                      = iu_dear_update_offset          + 1;
   localparam iu_esr_update_offset                       = iu_dbsr_update_offset          + 1;
   localparam iu_force_gsrr_offset                       = iu_esr_update_offset           + 1;
	localparam iu_dbsr_ude_offset                         = iu_force_gsrr_offset           + 1;
	localparam iu_dbsr_ide_offset                         = iu_dbsr_ude_offset             + 1;
   localparam ex3_spr_wd_offset                          = iu_dbsr_ide_offset             + 1;
   localparam ex3_tid_rpwr_offset                        = ex3_spr_wd_offset              + `GPR_WIDTH;
   localparam ex3_tspr_rt_offset                         = ex3_tid_rpwr_offset            + `GPR_WIDTH/8;
   localparam fit_tb_tap_offset                          = ex3_tspr_rt_offset             + `GPR_WIDTH;
   localparam wdog_tb_tap_offset                         = fit_tb_tap_offset              + 1;
   localparam gfit_tb_tap_offset                         = wdog_tb_tap_offset             + 1;
   localparam gwdog_tb_tap_offset                        = gfit_tb_tap_offset             + 1;
   localparam hang_pulse_offset                          = gwdog_tb_tap_offset            + 1;
   localparam lltap_offset                               = hang_pulse_offset              + 4;
   localparam llcnt_offset                               = lltap_offset                   + 1;
   localparam msrovride_pr_offset                        = llcnt_offset                   + 2;
   localparam msrovride_gs_offset                        = msrovride_pr_offset            + 1;
   localparam msrovride_de_offset                        = msrovride_gs_offset            + 1;
   localparam an_ac_ext_interrupt_offset                 = msrovride_de_offset            + 1;
   localparam an_ac_crit_interrupt_offset                = an_ac_ext_interrupt_offset     + 1;
   localparam an_ac_perf_interrupt_offset                = an_ac_crit_interrupt_offset    + 1;
   localparam an_ac_perf_interrupt2_offset               = an_ac_perf_interrupt_offset    + 1;
   localparam mux_msr_gs_offset                          = an_ac_perf_interrupt2_offset   + 1;
   localparam mux_msr_pr_offset                          = mux_msr_gs_offset              + 3;
   localparam err_llbust_attempt_offset                  = mux_msr_pr_offset              + 1;
   localparam err_llbust_failed_offset                   = err_llbust_attempt_offset      + 1;
   localparam inj_llbust_attempt_offset                  = err_llbust_failed_offset       + 1;
   localparam inj_llbust_failed_offset                   = inj_llbust_attempt_offset      + 1;
   localparam an_ac_external_mchk_offset                 = inj_llbust_failed_offset       + 1;
   localparam mchk_interrupt_offset                      = an_ac_external_mchk_offset     + 1;
   localparam crit_interrupt_offset                      = mchk_interrupt_offset          + 1;
   localparam wdog_interrupt_offset                      = crit_interrupt_offset          + 1;
   localparam dec_interrupt_offset                       = wdog_interrupt_offset          + 1;
   localparam udec_interrupt_offset                      = dec_interrupt_offset           + 1;
   localparam perf_interrupt_offset                      = udec_interrupt_offset          + 1;
   localparam fit_interrupt_offset                       = perf_interrupt_offset          + 1;
   localparam ext_interrupt_offset                       = fit_interrupt_offset           + 1;
   localparam gwdog_interrupt_offset                     = ext_interrupt_offset           + 1;
   localparam gdec_interrupt_offset                      = gwdog_interrupt_offset         + 1;
   localparam gfit_interrupt_offset                      = gdec_interrupt_offset          + 1;
   localparam single_instr_mode_offset                   = gfit_interrupt_offset          + 1;
   localparam single_instr_mode_2_offset                 = single_instr_mode_offset       + 1;
   localparam machine_check_offset                       = single_instr_mode_2_offset     + 1;
   localparam raise_iss_pri_offset                       = machine_check_offset           + 1;
   localparam raise_iss_pri_2_offset                     = raise_iss_pri_offset           + 1;
   localparam pc_xu_inj_wdt_reset_offset                 = raise_iss_pri_2_offset         + 1;
   localparam err_wdt_reset_offset                       = pc_xu_inj_wdt_reset_offset     + 1;
   localparam ram_active_offset                          = err_wdt_reset_offset           + 1;
   localparam timebase_taps_offset                       = ram_active_offset              + 1;
   localparam dbsr_mrr_offset                            = timebase_taps_offset           + 10;
   localparam tsr_wrs_offset                             = dbsr_mrr_offset                + 2;
   localparam iac1_en_offset                             = tsr_wrs_offset                 + 2;
   localparam iac2_en_offset                             = iac1_en_offset                 + 1;
   localparam iac3_en_offset                             = iac2_en_offset                 + 1;
   localparam iac4_en_offset                             = iac3_en_offset                 + 1;
   localparam ex3_dnh_val_offset                         = iac4_en_offset                 + 1;
	localparam an_ac_perf_interrupt_edge_offset           = ex3_dnh_val_offset             + 1;
   localparam spare_0_offset                             = an_ac_perf_interrupt_edge_offset + 1;
   localparam scan_right                                 = spare_0_offset                 + 16;
   wire [0:scan_right-1]         siv;
   wire [0:scan_right-1]         sov;
   localparam                    scan_right_ccfg = last_reg_offset_ccfg;
   wire [0:scan_right_ccfg-1]    siv_ccfg;
   wire [0:scan_right_ccfg-1]    sov_ccfg;
   localparam                    scan_right_dcfg = last_reg_offset_dcfg;
   wire [0:scan_right_dcfg-1]    siv_dcfg;
   wire [0:scan_right_dcfg-1]    sov_dcfg;
   // Signals
   wire [00:63]                  tidn;
   wire [0:`NCLK_WIDTH-1]        spare_0_lclk;
   wire                          spare_0_d1clk;
   wire                          spare_0_d2clk;
   wire                          ex1_opcode_is_31;
   wire                          ex1_opcode_is_19;
   wire [11:20]                  ex2_instr;
   wire                          ex2_is_mfmsr;
   wire                          ex1_is_mfspr;
   wire                          ex3_is_mtspr;
   wire [11:20]                  ex3_instr;
   wire                          ex3_is_mtmsr;
   wire                          iu_any_int;
   wire                          iu_any_hint;
   wire [50:63]                  ex3_msr_di2;
   wire [50:63]                  ex3_msr_mask;
   wire [50:63]                  ex3_msr_mux;
   wire [50:63]                  ex3_msr_in;
   wire [50:63]                  ex3_csrr1_d;
   wire [50:63]                  ex3_mcsrr1_d;
   wire [50:63]                  ex3_gsrr1_d;
   wire [50:63]                  ex3_srr1_d;
   wire [50:63]                  iu_rfgi_msr;
   wire                          ex3_dec_zero;
   wire                          ex3_dec_upper_zero;
   wire                          ex3_gdec_zero;
   wire                          ex3_gdec_upper_zero;
   wire                          ex3_udec_zero;
   wire                          ex3_udec_upper_zero;
   wire                          ex3_set_tsr_udis;
   wire                          ex3_set_tsr_dis;
   wire                          ex3_set_tsr_fis;
   wire                          ex3_set_tsr_wis;
   wire                          ex3_set_tsr_enw;
   wire [59:63]                  ex3_set_tsr;
   wire                          ex3_set_gtsr_dis;
   wire                          ex3_set_gtsr_fis;
   wire                          ex3_set_gtsr_wis;
   wire                          ex3_set_gtsr_enw;
   wire [60:63]                  ex3_set_gtsr;
   wire [64-`GPR_WIDTH:63]       ex3_spr_wd;
   wire                          wdog_pulse;
   wire                          gwdog_pulse;
   wire                          lltbtap;
   wire                          llpulse;
   wire                          llreset;
   wire [0:1]                    llstate;
   wire                          set_dbsr_ide;
   wire [44:63]                  set_dbsr;
   wire                          gdec_running;
   wire                          dec_running;
   wire                          udec_running;
   wire                          dbcr0_freeze_timers;
   wire                          dbsr_event;
   wire                          mux_msr_gs;
   wire                          mux_msr_pr;
   wire                          hang_pulse;
   wire [64-(`GPR_WIDTH):63]     dear_di;
   wire                          ex2_srr0_re2;
   wire                          ex2_gsrr0_re2;
   wire                          ex2_csrr0_re2;
   wire                          ex2_mcsrr0_re2;
   wire [1:4]                    iac_us_en;
   wire [1:4]                    iac_er_en;
   wire                          udec_en;
   wire                          ex3_wrteei;
   wire                          ex3_wrtee;
   wire [0:1]                    reset_complete;
   wire                          wdog_reset_1;
   wire                          wdog_reset_2;
   wire                          wdog_reset_3;
   wire [0:9]                    tb_tap_edge;
   wire [1:2]                    exx_act;
   wire [1:2]                    exx_act_data;
   wire                          iu_int_act;
   wire                          dbsr_mrr_act;
   wire                          tsr_wrs_act;
   wire                          reset_complete_act;
   wire                          ex3_gint_nia_sel;
   wire [62-`EFF_IFAR_ARCH:61]   ex2_iar;
   wire [62-`EFF_IFAR_ARCH:61]   ex2_iar_p4;
   wire [62-(`EFF_IFAR_ARCH):63] siar_di;
   wire [44:63]                  dbsr_di;
   wire                          mux_msr_de;
   wire                          iu_nia_act;
   wire                          ex3_dnh;
   wire [60:63]                  gtsr_di;
   wire                          an_ac_perf_interrupt_edge;
   wire                          dvc1_act;
   wire                          dvc2_act;
   (* analysis_not_referenced="true" *)
   wire                          unused_do_bits;

   // Data
	wire                             spr_ccr3_en_eepri;
	wire                             spr_ccr3_si;
	wire                             spr_csrr1_cm;
	wire [0:1]                       spr_dbcr0_rst;
	wire                             spr_dbcr0_iac1;
	wire                             spr_dbcr0_iac2;
	wire                             spr_dbcr0_iac3;
	wire                             spr_dbcr0_iac4;
	wire                             spr_dbcr0_ft;
	wire [0:1]                       spr_dbcr1_iac1us;
	wire [0:1]                       spr_dbcr1_iac1er;
	wire [0:1]                       spr_dbcr1_iac2us;
	wire [0:1]                       spr_dbcr1_iac2er;
	wire [0:1]                       spr_dbcr1_iac3us;
	wire [0:1]                       spr_dbcr1_iac3er;
	wire [0:1]                       spr_dbcr1_iac4us;
	wire [0:1]                       spr_dbcr1_iac4er;
	wire                             spr_dbsr_ide;
	wire                             spr_epcr_extgs;
	wire                             spr_epcr_icm;
	wire                             spr_epcr_gicm;
	wire                             spr_gsrr1_cm;
	wire [0:1]                       spr_gtcr_wp;
	wire [0:1]                       spr_gtcr_wrc;
	wire                             spr_gtcr_wie;
	wire                             spr_gtcr_die;
	wire [0:1]                       spr_gtcr_fp;
	wire                             spr_gtcr_fie;
	wire                             spr_gtcr_are;
	wire                             spr_gtsr_enw;
	wire                             spr_gtsr_wis;
	wire                             spr_gtsr_dis;
	wire                             spr_gtsr_fis;
	wire                             spr_mcsrr1_cm;
	wire                             spr_msr_cm;
	wire                             spr_msr_gs;
	wire                             spr_msr_ce;
	wire                             spr_msr_ee;
	wire                             spr_msr_pr;
	wire                             spr_msr_me;
	wire                             spr_msr_fe0;
	wire                             spr_msr_de;
	wire                             spr_msr_fe1;
	wire                             spr_msr_is;
	wire                             spr_srr1_cm;
	wire [0:1]                       spr_tcr_wp;
	wire [0:1]                       spr_tcr_wrc;
	wire                             spr_tcr_wie;
	wire                             spr_tcr_die;
	wire [0:1]                       spr_tcr_fp;
	wire                             spr_tcr_fie;
	wire                             spr_tcr_are;
	wire                             spr_tcr_udie;
	wire                             spr_tcr_ud;
	wire                             spr_tsr_enw;
	wire                             spr_tsr_wis;
	wire                             spr_tsr_dis;
	wire                             spr_tsr_fis;
	wire                             spr_tsr_udis;
	wire [0:2]                       spr_xucr1_ll_tb_sel;
	wire                             spr_xucr1_ll_sel;
	wire                             spr_xucr1_ll_en;
	wire [62:63]                     ex3_ccr3_di;
	wire [64-(`EFF_IFAR_ARCH):63]    ex3_csrr0_di;
	wire [50:63]                     ex3_csrr1_di;
	wire [43:63]                     ex3_dbcr0_di;
	wire [46:63]                     ex3_dbcr1_di;
	wire [44:63]                     ex3_dbsr_di;
	wire [64-(`GPR_WIDTH):63]        ex3_dear_di;
	wire [32:63]                     ex3_dec_di;
	wire [32:63]                     ex3_decar_di;
	wire [49:63]                     ex3_dnhdr_di;
	wire [54:63]                     ex3_epcr_di;
	wire [47:63]                     ex3_esr_di;
	wire [64-(`GPR_WIDTH):63]        ex3_gdear_di;
	wire [32:63]                     ex3_gdec_di;
	wire [32:63]                     ex3_gdecar_di;
	wire [47:63]                     ex3_gesr_di;
	wire [32:63]                     ex3_gpir_di;
	wire [64-(`EFF_IFAR_ARCH):63]    ex3_gsrr0_di;
	wire [50:63]                     ex3_gsrr1_di;
	wire [54:63]                     ex3_gtcr_di;
	wire [60:63]                     ex3_gtsr_di;
	wire [49:63]                     ex3_mcsr_di;
	wire [64-(`EFF_IFAR_ARCH):63]    ex3_mcsrr0_di;
	wire [50:63]                     ex3_mcsrr1_di;
	wire [50:63]                     ex3_msr_di;
	wire [62:63]                     ex3_msrp_di;
	wire [62-(`EFF_IFAR_ARCH):63]    ex3_siar_di;
	wire [64-(`EFF_IFAR_ARCH):63]    ex3_srr0_di;
	wire [50:63]                     ex3_srr1_di;
	wire [52:63]                     ex3_tcr_di;
	wire [59:63]                     ex3_tsr_di;
	wire [32:63]                     ex3_udec_di;
	wire [59:63]                     ex3_xucr1_di;
	wire
		ex2_ccr3_rdec  , ex2_csrr0_rdec , ex2_csrr1_rdec , ex2_dbcr0_rdec
		, ex2_dbcr1_rdec , ex2_dbsr_rdec  , ex2_dear_rdec  , ex2_dec_rdec
		, ex2_decar_rdec , ex2_dnhdr_rdec , ex2_epcr_rdec  , ex2_esr_rdec
		, ex2_gdear_rdec , ex2_gdec_rdec  , ex2_gdecar_rdec, ex2_gesr_rdec
		, ex2_gpir_rdec  , ex2_gsrr0_rdec , ex2_gsrr1_rdec , ex2_gtcr_rdec
		, ex2_gtsr_rdec  , ex2_iar_rdec   , ex2_mcsr_rdec  , ex2_mcsrr0_rdec
		, ex2_mcsrr1_rdec, ex2_msrp_rdec  , ex2_siar_rdec  , ex2_srr0_rdec
		, ex2_srr1_rdec  , ex2_tcr_rdec   , ex2_tsr_rdec   , ex2_udec_rdec
		, ex2_xucr1_rdec ;
	wire
		ex2_ccr3_re    , ex2_csrr0_re   , ex2_csrr1_re   , ex2_dbcr0_re
		, ex2_dbcr1_re   , ex2_dbsr_re    , ex2_dear_re    , ex2_dec_re
		, ex2_decar_re   , ex2_dnhdr_re   , ex2_epcr_re    , ex2_esr_re
		, ex2_gdear_re   , ex2_gdec_re    , ex2_gdecar_re  , ex2_gesr_re
		, ex2_gpir_re    , ex2_gsrr0_re   , ex2_gsrr1_re   , ex2_gtcr_re
		, ex2_gtsr_re    , ex2_iar_re     , ex2_mcsr_re    , ex2_mcsrr0_re
		, ex2_mcsrr1_re  , ex2_msrp_re    , ex2_siar_re    , ex2_srr0_re
		, ex2_srr1_re    , ex2_tcr_re     , ex2_tsr_re     , ex2_udec_re
		, ex2_xucr1_re   ;
   wire ex2_pir_rdec;
	wire
		ex2_ccr3_we    , ex2_csrr0_we   , ex2_csrr1_we   , ex2_dbcr0_we
		, ex2_dbcr1_we   , ex2_dbsr_we    , ex2_dbsrwr_we  , ex2_dear_we
		, ex2_dec_we     , ex2_decar_we   , ex2_dnhdr_we   , ex2_epcr_we
		, ex2_esr_we     , ex2_gdear_we   , ex2_gdec_we    , ex2_gdecar_we
		, ex2_gesr_we    , ex2_gpir_we    , ex2_gsrr0_we   , ex2_gsrr1_we
		, ex2_gtcr_we    , ex2_gtsr_we    , ex2_gtsrwr_we  , ex2_iar_we
		, ex2_mcsr_we    , ex2_mcsrr0_we  , ex2_mcsrr1_we  , ex2_msrp_we
		, ex2_siar_we    , ex2_srr0_we    , ex2_srr1_we    , ex2_tcr_we
		, ex2_tsr_we     , ex2_udec_we    , ex2_xucr1_we   ;
	wire
		ex2_ccr3_wdec  , ex2_csrr0_wdec , ex2_csrr1_wdec , ex2_dbcr0_wdec
		, ex2_dbcr1_wdec , ex2_dbsr_wdec  , ex2_dbsrwr_wdec, ex2_dear_wdec
		, ex2_dec_wdec   , ex2_decar_wdec , ex2_dnhdr_wdec , ex2_epcr_wdec
		, ex2_esr_wdec   , ex2_gdear_wdec , ex2_gdec_wdec  , ex2_gdecar_wdec
		, ex2_gesr_wdec  , ex2_gpir_wdec  , ex2_gsrr0_wdec , ex2_gsrr1_wdec
		, ex2_gtcr_wdec  , ex2_gtsr_wdec  , ex2_gtsrwr_wdec, ex2_iar_wdec
		, ex2_mcsr_wdec  , ex2_mcsrr0_wdec, ex2_mcsrr1_wdec, ex2_msrp_wdec
		, ex2_siar_wdec  , ex2_srr0_wdec  , ex2_srr1_wdec  , ex2_tcr_wdec
		, ex2_tsr_wdec   , ex2_udec_wdec  , ex2_xucr1_wdec ;
	wire
		ex3_ccr3_we    , ex3_csrr0_we   , ex3_csrr1_we   , ex3_dbcr0_we
		, ex3_dbcr1_we   , ex3_dbsr_we    , ex3_dbsrwr_we  , ex3_dear_we
		, ex3_dec_we     , ex3_decar_we   , ex3_dnhdr_we   , ex3_epcr_we
		, ex3_esr_we     , ex3_gdear_we   , ex3_gdec_we    , ex3_gdecar_we
		, ex3_gesr_we    , ex3_gpir_we    , ex3_gsrr0_we   , ex3_gsrr1_we
		, ex3_gtcr_we    , ex3_gtsr_we    , ex3_gtsrwr_we  , ex3_iar_we
		, ex3_mcsr_we    , ex3_mcsrr0_we  , ex3_mcsrr1_we  , ex3_msr_we
		, ex3_msrp_we    , ex3_siar_we    , ex3_srr0_we    , ex3_srr1_we
		, ex3_tcr_we     , ex3_tsr_we     , ex3_udec_we    , ex3_xucr1_we   ;
	wire
		ex3_ccr3_wdec  , ex3_csrr0_wdec , ex3_csrr1_wdec , ex3_dbcr0_wdec
		, ex3_dbcr1_wdec , ex3_dbsr_wdec  , ex3_dbsrwr_wdec, ex3_dear_wdec
		, ex3_dec_wdec   , ex3_decar_wdec , ex3_dnhdr_wdec , ex3_epcr_wdec
		, ex3_esr_wdec   , ex3_gdear_wdec , ex3_gdec_wdec  , ex3_gdecar_wdec
		, ex3_gesr_wdec  , ex3_gpir_wdec  , ex3_gsrr0_wdec , ex3_gsrr1_wdec
		, ex3_gtcr_wdec  , ex3_gtsr_wdec  , ex3_gtsrwr_wdec, ex3_iar_wdec
		, ex3_mcsr_wdec  , ex3_mcsrr0_wdec, ex3_mcsrr1_wdec, ex3_msr_wdec
		, ex3_msrp_wdec  , ex3_siar_wdec  , ex3_srr0_wdec  , ex3_srr1_wdec
		, ex3_tcr_wdec   , ex3_tsr_wdec   , ex3_udec_wdec  , ex3_xucr1_wdec ;
	wire
		ccr3_act       , csrr0_act      , csrr1_act      , dbcr0_act
		, dbcr1_act      , dbsr_act       , dear_act       , dec_act
		, decar_act      , dnhdr_act      , epcr_act       , esr_act
		, gdear_act      , gdec_act       , gdecar_act     , gesr_act
		, gpir_act       , gsrr0_act      , gsrr1_act      , gtcr_act
		, gtsr_act       , iar_act        , mcsr_act       , mcsrr0_act
		, mcsrr1_act     , msr_act        , msrp_act       , siar_act
		, srr0_act       , srr1_act       , tcr_act        , tsr_act
		, udec_act       , xucr1_act      ;
	wire [0:64]
		ccr3_do        , csrr0_do       , csrr1_do       , dbcr0_do
		, dbcr1_do       , dbsr_do        , dear_do        , dec_do
		, decar_do       , dnhdr_do       , epcr_do        , esr_do
		, gdear_do       , gdec_do        , gdecar_do      , gesr_do
		, gpir_do        , gsrr0_do       , gsrr1_do       , gtcr_do
		, gtsr_do        , iar_do         , mcsr_do        , mcsrr0_do
		, mcsrr1_do      , msr_do         , msrp_do        , siar_do
		, srr0_do        , srr1_do        , tcr_do         , tsr_do
		, udec_do        , xucr1_do       ;

   //!! Bugspray Include: xu_spr_tspr;
   //## figtree_source: xu_spr_tspr.fig;

   assign tidn             = {64{1'b0}};

   assign exx_act_d        = {cspr_tspr_rf1_act, exx_act[1:1]};

   assign exx_act[1]       = exx_act_q[1];
   assign exx_act[2]       = exx_act_q[2];

   assign exx_act_data[1]  = exx_act[1];
   assign exx_act_data[2]  = exx_act[2];

   assign iu_int_act       = iu_xu_act | iu_xu_act_q | cspr_xucr0_clkg_ctl[4];

   // Decode
   assign ex1_opcode_is_19 = cspr_tspr_ex1_instr[0:5] == 6'b010011;
   assign ex1_opcode_is_31 = cspr_tspr_ex1_instr[0:5] == 6'b011111;
   assign ex1_is_mfspr     = (ex1_opcode_is_31 & cspr_tspr_ex1_instr[21:30] == 10'b0101010011);     // 31/339
   assign ex1_is_mtspr     = (ex1_opcode_is_31 & cspr_tspr_ex1_instr[21:30] == 10'b0111010011);     // 31/467
   assign ex1_is_mfmsr     = (ex1_opcode_is_31 & cspr_tspr_ex1_instr[21:30] == 10'b0001010011);     // 31/083
   assign ex1_is_mtmsr     = (ex1_opcode_is_31 & cspr_tspr_ex1_instr[21:30] == 10'b0010010010);     // 31/146
   assign ex1_is_wrtee     = (ex1_opcode_is_31 & cspr_tspr_ex1_instr[21:30] == 10'b0010000011);     // 31/131
   assign ex1_is_wrteei    = (ex1_opcode_is_31 & cspr_tspr_ex1_instr[21:30] == 10'b0010100011);     // 31/163
   assign ex1_is_dnh       = (ex1_opcode_is_19 & cspr_tspr_ex1_instr[21:30] == 10'b0011000110);     // 19/198

   assign ex2_instr_d      = (ex1_is_mfspr | ex1_is_mtspr | ex1_is_wrteei | ex1_is_dnh)==1'b1 ? cspr_tspr_ex1_instr[6:20] : 15'b0;

   assign ex2_instr        = ex2_instr_q[11:20];
   assign ex2_is_mfmsr     = ex2_is_mfmsr_q;

   assign ex3_is_mtspr     = ex3_is_mtspr_q;
   assign ex3_instr        = ex3_instr_q[11:20];
   assign ex3_is_mtmsr     = ex3_is_mtmsr_q;
   assign ex3_spr_wd       = ex3_spr_wd_q;

   assign iu_any_int       = iu_int_q | iu_cint_q | iu_mcint_q | iu_gint_q;
   assign iu_any_hint      = iu_int_q | iu_cint_q | iu_mcint_q;
   assign ex3_wrteei       = ex3_spr_we & ex3_wrteei_q;
   assign ex3_wrtee        = ex3_spr_we & ex3_wrtee_q;
   assign ex3_dnh          = ex3_spr_we & ex3_dnh_q & cspr_ccr4_en_dnh;
   assign xu_pc_stop_dnh_instr = ex3_dnh_val_q;

   assign ex3_tid_rpwr_d   = {`GPR_WIDTH/8{cspr_tspr_ex2_tid}};

   assign tb_tap_edge      = cspr_tspr_timebase_taps & (~timebase_taps_q);

   assign iu_nia_act       = iu_int_act | ex1_is_mfspr | an_ac_perf_interrupt_edge;

   assign ex2_iar_p4       = {iu_nia_q[62-`EFF_IFAR_ARCH:61-`EFF_IFAR_WIDTH],ex2_ifar[62-`EFF_IFAR_WIDTH:61]} + `EFF_IFAR_ARCH'd1;

   // SPR Input Control
   // CCR3
   assign ex2_iar[62-`EFF_IFAR_ARCH:61] = (ram_active_q == 1'b1) ? iu_nia_q[62 - `EFF_IFAR_ARCH:61] :
                                                                  {(ex2_iar_p4[62-`EFF_IFAR_ARCH:31] & {32{spr_msr_cm}}),ex2_iar_p4[32:61]};
   assign ccr3_act         = ex3_ccr3_we;
   assign ccr3_d           = ex3_ccr3_di;

   // CSRR0
   assign csrr0_act        = ex3_csrr0_we | iu_cint_q;

   // CSRR1
   assign csrr0_d          = (iu_cint_q == 1'b1) ? iu_nia_q : ex3_csrr0_di;
   assign csrr1_act        = ex3_csrr1_we | iu_cint_q;

   generate
      if (`GPR_WIDTH == 64)
      begin : csrr1_gen_64
         assign ex3_csrr1_d   = ex3_csrr1_di;
      end
   endgenerate
   generate
      if (`GPR_WIDTH == 32)
      begin : csrr1_gen_32
         assign ex3_csrr1_d[MSR_CM]          = 1'b0;
         assign ex3_csrr1_d[MSR_GS:MSR_DS]   = ex3_csrr1_di[MSR_GS:MSR_DS];
      end
   endgenerate

   assign csrr1_d          = (iu_cint_q == 1'b1) ? msr_q : ex3_csrr1_d;

   // DBCR0
   assign dbcr0_act        = ex3_dbcr0_we;
   assign dbcr0_d          = ex3_dbcr0_di;

   // DBCR1
   assign dbcr1_act        = ex3_dbcr1_we;
   assign dbcr1_d          = ex3_dbcr1_di;

   // DBSR
   assign reset_complete_act = |(reset_complete);

   assign dbsr_mrr_act     = reset_complete_act | ex3_dbsr_we | ex3_dbsrwr_we;

   assign dbsr_mrr_d       = (reset_complete_act == 1'b1)   ? reset_complete :
                             (ex3_dbsrwr_we == 1'b1)        ? ex3_spr_wd[34:35] :
                                                             (dbsr_mrr_q & (~ex3_spr_wd[34:35]));

   assign dbsr_act         = ex3_dbsr_we | ex3_dbsrwr_we | iu_dbsr_update_q | iu_dbsr_ude_q;

   // BRT and ICMP event can never set IDE.
   assign set_dbsr_ide     = ((iu_dbsr_q[0] | |iu_dbsr_q[3:18]) & ~msr_q[60]) | iu_dbsr_ide_q;
   assign set_dbsr         = {set_dbsr_ide, (iu_dbsr_q[0] | iu_dbsr_ude_q), iu_dbsr_q[1:18]};

   assign dbsr_d           = dbsr_di | (set_dbsr & {20{(iu_dbsr_update_q | iu_dbsr_ude_q)}});
   assign dbsr_di          = (ex3_dbsrwr_we == 1'b1) ? ex3_dbsr_di :
                             (ex3_dbsr_we == 1'b1)   ? (dbsr_q & (~ex3_dbsr_di)) :
                                                        dbsr_q;

   // DEAR
   assign dear_act         = ex3_dear_we | (iu_dear_update_q & ~iu_gint_q);

   assign dear_di          = (iu_dear_update_q == 1'b1) ? iu_dear_q : ex3_dear_di;
   assign dear_d           = dear_di;

   // DVC1 (shadow)
   assign dvc1_act         = 1'b0;
   assign dvc1_d           = ex3_spr_wd[64 - (`GPR_WIDTH):63];

   // DVC2 (shadow)
   assign dvc2_act         = 1'b0;
   assign dvc2_d           = ex3_spr_wd[64 - (`GPR_WIDTH):63];

   // GDEAR
   assign gdear_act        = ex3_gdear_we | (iu_dear_update_q & iu_gint_q);

   assign gdear_d          = dear_di;

   // DEC
   assign dec_running      = timer_update & ~(~spr_tcr_are & ex3_dec_zero) & ~cspr_tspr_dec_dbg_dis & ~dbcr0_freeze_timers;

   assign dec_act          = ex3_dec_we | dec_running;

   assign dec_d            = (ex3_dec_we == 1'b1)                       ? ex3_dec_di :
                             ((ex3_set_tsr_dis & spr_tcr_are) == 1'b1)  ? decar_q :
                                                                          dec_q - 1;

   // GDEC
   assign gdec_running     = timer_update & ~(~spr_gtcr_are & ex3_gdec_zero) & ~cspr_tspr_dec_dbg_dis & ~dbcr0_freeze_timers;

   assign gdec_act         = ex3_gdec_we | gdec_running;

   assign gdec_d           = (ex3_gdec_we == 1'b1)                         ? ex3_gdec_di :
                             ((ex3_set_gtsr_dis & spr_gtcr_are) == 1'b1)   ? gdecar_q :
                                                                             gdec_q - 1;

   // UDEC
   assign udec_running     = timer_update & ~ex3_udec_zero & ~cspr_tspr_dec_dbg_dis & ~dbcr0_freeze_timers;

   assign udec_act         = ex3_udec_we | udec_running;

   assign udec_d           = (ex3_udec_we == 1'b1) ? ex3_udec_di : udec_q - 1;

   // DECAR
   assign decar_act        = ex3_decar_we;
   assign decar_d          = ex3_decar_di;

   // DECAR
   assign gdecar_act       = ex3_gdecar_we;
   assign gdecar_d         = ex3_gdecar_di;

   // DNHDR
   assign dnhdr_act        = ex3_dnhdr_we | ex3_dnh;
   assign dnhdr_d          = (ex3_dnh_q == 1'b1) ? ex3_instr_q[6:20] : ex3_dnhdr_di;

   // EPCR
   assign epcr_act         = ex3_epcr_we;
   assign epcr_d           = ex3_epcr_di;

   // ESR
   assign esr_act          = ex3_esr_we | (iu_esr_update_q & iu_int_q);

   assign esr_d            = (iu_esr_update_q == 1'b1)   ? iu_esr_q :
                             (ex3_esr_we == 1'b1)        ? ex3_esr_di :
                                                           esr_q;

   // GESR
   assign gesr_act         = ex3_gesr_we | (iu_esr_update_q & iu_gint_q);

   assign gesr_d           = (iu_esr_update_q == 1'b1)   ? iu_esr_q :
                             (ex3_gesr_we == 1'b1)       ? ex3_gesr_di :
                                                           gesr_q;

   // GPIR
   assign gpir_act         = ex3_gpir_we;
   assign gpir_d           = ex3_gpir_di;

   // IAR
   assign iar_act          = ex3_iar_we;

   // MCSR
   assign mcsr_act         = ex3_mcsr_we | iu_mcint_q;

   assign mcsr_d           = (iu_mcint_q == 1'b1)        ? iu_mcsr_q :
                             (ex3_mcsr_we == 1'b1)       ? ex3_mcsr_di :
                                                           mcsr_q;

   // MCSRR0
   assign mcsrr0_act       = ex3_mcsrr0_we | iu_mcint_q;

   // MCSRR1
   assign mcsrr0_d         = (iu_mcint_q == 1'b1) ? iu_nia_q : ex3_mcsrr0_di;
   assign mcsrr1_act       = ex3_mcsrr1_we | iu_mcint_q;

   generate
      if (`GPR_WIDTH == 64)
      begin : mcsrr1_gen_64
         assign ex3_mcsrr1_d  = ex3_mcsrr1_di;
      end
   endgenerate
   generate
      if (`GPR_WIDTH == 32)
      begin : mcsrr1_gen_32
         assign ex3_mcsrr1_d[MSR_CM]         = 1'b0;
         assign ex3_mcsrr1_d[MSR_GS:MSR_DS]  = ex3_mcsrr1_di[MSR_GS:MSR_DS];
      end
   endgenerate

   // MSR
   assign mcsrr1_d         = (iu_mcint_q == 1'b1) ? msr_q : ex3_mcsrr1_d;
   assign msr_act          = ex3_wrteei | ex3_wrtee | iu_any_hint | iu_gint_q | iu_rfi_q | iu_rfgi_q | iu_rfci_q | iu_rfmci_q | ex3_msr_we;

   // CM GS UCLE SPV CE EE PR FP ME FE0 DE FE1 IS DS
   // 50 51 52   53  54 55 56 57 58 59  60 61  62 63
   //       X                           X             MSRP

   assign ex3_msr_di2[MSR_UCLE]        = ((msrp_q[MSRP_UCLEP] & msr_q[MSR_GS]) == 1'b1)   ? msr_q[MSR_UCLE] : ex3_msr_di[MSR_UCLE];
   assign ex3_msr_di2[MSR_DE]          = ((msrp_q[MSRP_DEP] & msr_q[MSR_GS]) == 1'b1)     ? msr_q[MSR_DE]   : ex3_msr_di[MSR_DE];
   assign ex3_msr_di2[MSR_CM]          = ex3_msr_di[MSR_CM];
   assign ex3_msr_di2[MSR_GS]          = ex3_msr_di[MSR_GS] | msr_q[MSR_GS];
   assign ex3_msr_di2[MSR_SPV:MSR_FE0] = ex3_msr_di[MSR_SPV:MSR_FE0];
   assign ex3_msr_di2[MSR_FE1:MSR_DS]  = ex3_msr_di[MSR_FE1:MSR_DS];

   // 0 leave unchanged
   // 1 clear
   assign ex3_msr_mask[MSR_CM]         = 1'b0;		                                             // CM
   assign ex3_msr_mask[MSR_GS]         = iu_any_hint;		                                       // GS
   assign ex3_msr_mask[MSR_UCLE]       = iu_any_hint | (iu_gint_q & (~msrp_q[MSRP_UCLEP]));		// UCLE
   assign ex3_msr_mask[MSR_SPV]        = iu_any_int;		                                       // SPV
   assign ex3_msr_mask[MSR_CE]         = iu_mcint_q | iu_cint_q;		                           // CE
   assign ex3_msr_mask[MSR_EE]         = iu_any_int;		                                       // EE
   assign ex3_msr_mask[MSR_PR:MSR_FP]  = {2{iu_any_int}};		                                 // PR,FP
   assign ex3_msr_mask[MSR_ME]         = iu_mcint_q;		                                       // ME
   assign ex3_msr_mask[MSR_FE0]        = iu_any_int;		                                       // FE0
   assign ex3_msr_mask[MSR_DE]         = iu_mcint_q | iu_cint_q;		                           // DE
   assign ex3_msr_mask[MSR_FE1:MSR_DS] = {3{iu_any_int}};		                                 // FE1,IS,DS

   assign ex3_msr_mux = ({iu_rfi_q, iu_rfgi_q, iu_rfci_q, iu_rfmci_q, ex3_msr_we} == 5'b10000) ? srr1_q :
                        ({iu_rfi_q, iu_rfgi_q, iu_rfci_q, iu_rfmci_q, ex3_msr_we} == 5'b01000) ? iu_rfgi_msr :
                        ({iu_rfi_q, iu_rfgi_q, iu_rfci_q, iu_rfmci_q, ex3_msr_we} == 5'b00100) ? csrr1_q :
                        ({iu_rfi_q, iu_rfgi_q, iu_rfci_q, iu_rfmci_q, ex3_msr_we} == 5'b00010) ? mcsrr1_q :
                        ({iu_rfi_q, iu_rfgi_q, iu_rfci_q, iu_rfmci_q, ex3_msr_we} == 5'b00001) ? ex3_msr_di2 :
                                                                                                 msr_q;
   assign ex3_msr_in[51:54]            = ex3_msr_mux[51:54];
   assign ex3_msr_in[56:63]            = ex3_msr_mux[56:63];

   assign ex3_msr_in[MSR_CM]           = ({iu_any_hint, iu_gint_q} == 2'b10) ? spr_epcr_icm :
                                         ({iu_any_hint, iu_gint_q} == 2'b01) ? spr_epcr_gicm :
                                                                               ex3_msr_mux[MSR_CM];

   assign ex3_msr_in[MSR_EE]           = ({ex3_wrteei, ex3_wrtee} == 2'b10)  ? ex3_instr_q[16] :
                                         ({ex3_wrteei, ex3_wrtee} == 2'b01)  ? ex3_spr_wd[48] :
                                                                               ex3_msr_mux[MSR_EE];
   generate
      if (`GPR_WIDTH == 64)
      begin : msr_gen_64
         assign msr_d = ex3_msr_in & ~ex3_msr_mask;
      end
   endgenerate
   generate
      if (`GPR_WIDTH == 32)
      begin : msr_gen_32
         assign msr_d[MSR_CM]          = 1'b0;
         assign msr_d[MSR_GS:MSR_DS]   = ex3_msr_in[MSR_GS:MSR_DS] & ~ex3_msr_mask[MSR_GS:MSR_DS];
      end
   endgenerate

   // rfgi msr
   assign iu_rfgi_msr[MSR_CM]             = gsrr1_q[MSR_CM];
   assign iu_rfgi_msr[MSR_SPV:MSR_FE0]    = gsrr1_q[MSR_SPV:MSR_FE0];
   assign iu_rfgi_msr[MSR_FE1:MSR_DS]     = gsrr1_q[MSR_FE1:MSR_DS];
   assign iu_rfgi_msr[MSR_GS]             = ((msr_q[MSR_GS]) == 1'b1)                        ? msr_q[MSR_GS]   : gsrr1_q[MSR_GS];
   assign iu_rfgi_msr[MSR_UCLE]           = ((msrp_q[MSRP_UCLEP] & msr_q[MSR_GS]) == 1'b1)   ? msr_q[MSR_UCLE] : gsrr1_q[MSR_UCLE];
   assign iu_rfgi_msr[MSR_DE]             = ((msrp_q[MSRP_DEP] & msr_q[MSR_GS]) == 1'b1)     ? msr_q[MSR_DE]   : gsrr1_q[MSR_DE];

   // MSRP
   assign msrp_act         = ex3_msrp_we;
   assign msrp_d           = ex3_msrp_di;

   // SIAR
   assign an_ac_perf_interrupt_edge       = (an_ac_perf_interrupt_q & (~an_ac_perf_interrupt2_q));
   assign xu_pc_perfmon_alert             = an_ac_perf_interrupt_edge_q;

   assign siar_act         = ex3_siar_we | (an_ac_perf_interrupt_edge_q & pc_xu_spr_cesr1_pmae);

   assign siar_di          = {iu_nia_q, spr_msr_gs, spr_msr_pr};

   assign siar_d           = (an_ac_perf_interrupt_edge_q == 1'b1) ? siar_di : ex3_siar_di;

   // SRR0
   assign srr0_act         = ex3_srr0_we | (iu_int_q & ~iu_force_gsrr_q);

   // SRR1
   assign srr1_act         = ex3_srr1_we | (iu_int_q & ~iu_force_gsrr_q);
   assign srr0_d           = (iu_int_q == 1'b1) ? iu_nia_q : ex3_srr0_di;

   generate
      if (`GPR_WIDTH == 64)
      begin : srr1_gen_64
         assign ex3_srr1_d = ex3_srr1_di;
      end
   endgenerate
   generate
      if (`GPR_WIDTH == 32)
      begin : srr1_gen_32
         assign ex3_srr1_d[MSR_CM]           = 1'b0;
         assign ex3_srr1_d[MSR_GS:MSR_DS]    = ex3_srr1_di[MSR_GS:MSR_DS];
      end
   endgenerate

   // GSRR0
   assign srr1_d           = (iu_int_q == 1'b1) ? msr_q : ex3_srr1_d;
   assign ex3_gint_nia_sel = iu_gint_q | (iu_int_q & iu_force_gsrr_q);

   assign gsrr0_act        = ex3_gsrr0_we | ex3_gint_nia_sel;

   // GSRR1
   assign gsrr1_act        = ex3_gsrr1_we | ex3_gint_nia_sel;
   assign gsrr0_d          = (ex3_gint_nia_sel == 1'b1) ? iu_nia_q : ex3_gsrr0_di;

   generate
      if (`GPR_WIDTH == 64)
      begin : gsrr1_gen_64
         assign ex3_gsrr1_d = ex3_gsrr1_di;
      end
   endgenerate
   generate
      if (`GPR_WIDTH == 32)
      begin : gsrr1_gen_32
         assign ex3_gsrr1_d[MSR_CM]          = 1'b0;
         assign ex3_gsrr1_d[MSR_GS:MSR_DS]   = ex3_gsrr1_di[MSR_GS:MSR_DS];
      end
   endgenerate

   assign gsrr1_d          = (ex3_gint_nia_sel == 1'b1) ? msr_q : ex3_gsrr1_d;

   // TCR
   assign tcr_act          = ex3_tcr_we;
   assign tcr_d            = ex3_tcr_di;

   // GTCR
   assign gtcr_act         = ex3_gtcr_we;
   assign gtcr_d           = ex3_gtcr_di;

   // TSR
   assign tsr_wrs_act      = (reset_wd_complete & reset_complete_act) | ex3_tsr_we;

   assign tsr_wrs_d        = ((reset_wd_complete & reset_complete_act) == 1'b1) ? reset_complete : (tsr_wrs_q & (~ex3_spr_wd[34:35]));

   assign tsr_act          = 1'b1;

   assign tsr_d            = ex3_set_tsr | (tsr_q & ~(ex3_tsr_di & {5{ex3_tsr_we}}));

   // GTSR
   assign gtsr_act         = 1'b1;

   assign gtsr_di          = gtsr_q & ~(ex3_gtsr_di & {4{ex3_gtsr_we}});

   assign gtsr_d           = ex3_set_gtsr | ((ex3_gtsrwr_we == 1'b1) ? ex3_gtsr_di : gtsr_di);

   // XUCR1
   assign xucr1_act        = ex3_xucr1_we;
   assign xucr1_d          = ex3_xucr1_di;

   // LiveLock Buster!
   // assign cspr_tspr_timebase_taps[8] = tbl_q[32 + 23];   //  9           x
   // assign cspr_tspr_timebase_taps[7] = tbl_q[32 + 11];   // 21           x
   // assign cspr_tspr_timebase_taps[6] = tbl_q[32 + 7];    // 25           x
   // assign cspr_tspr_timebase_taps[5] = tbl_q[32 + 21];   // 11     x     x
   // assign cspr_tspr_timebase_taps[4] = tbl_q[32 + 17];   // 15     x     x
   // assign cspr_tspr_timebase_taps[3] = tbl_q[32 + 13];   // 19     x     x     x
   // assign cspr_tspr_timebase_taps[2] = tbl_q[32 + 9];    // 23     x     x     x
   // assign cspr_tspr_timebase_taps[1] = tbl_q[32 + 5];    // 27           x     x
   // assign cspr_tspr_timebase_taps[0] = tbl_q[32 + 1];    // 31                 x
   // assign cspr_tspr_timebase_taps[9] = tbl_q[32 + 7];    // 29                 x   -- Replaced 1 for wdog

   assign lltbtap = (spr_xucr1_ll_tb_sel == 3'b000) ? tb_tap_edge[8] :  // 9
                    (spr_xucr1_ll_tb_sel == 3'b001) ? tb_tap_edge[5] :  // 11
                    (spr_xucr1_ll_tb_sel == 3'b010) ? tb_tap_edge[4] :  // 15
                    (spr_xucr1_ll_tb_sel == 3'b011) ? tb_tap_edge[3] :  // 19
                    (spr_xucr1_ll_tb_sel == 3'b100) ? tb_tap_edge[7] :  // 21
                    (spr_xucr1_ll_tb_sel == 3'b101) ? tb_tap_edge[2] :  // 23
                    (spr_xucr1_ll_tb_sel == 3'b110) ? tb_tap_edge[6] :  // 25
                                                      tb_tap_edge[1];   // 27

   assign hang_pulse_d     = {an_ac_hang_pulse, hang_pulse_q[0:2]};
   assign hang_pulse       = hang_pulse_q[2] & (~hang_pulse_q[3]);

   assign lltap_d          = (spr_xucr1_ll_sel == 1'b1) ? hang_pulse : lltbtap;		// Stop if counter == "10"

   // Gate off if disabled
   assign llpulse          = ~llcnt_q[0] & cspr_tspr_llen & spr_xucr1_ll_en & lltap_q;		// Don't pulse if stopped

   assign llreset          = (iu_xu_instr_cpl & ~((inj_llbust_attempt_q & ~llcnt_q[0]) | inj_llbust_failed_q)) | ~cspr_tspr_llen;

   assign llcnt_d = ({llpulse, llreset} == 2'b01) ? 2'b00 :
                    ({llpulse, llreset} == 2'b11) ? 2'b00 :
                    ({llpulse, llreset} == 2'b10) ? llcnt_q + 2'd1 :
                                                    llcnt_q;

   assign tspr_cspr_lldet     = llcnt_q[0] & spr_xucr1_ll_en;
   assign tspr_cspr_llpulse   = llpulse;

   assign llstate[0]          = llcnt_q[0];
   assign llstate[1]          = llcnt_q[1] | (llcnt_q[0] & (~cspr_tspr_llpri));

   // Raise the priority for threads that are in livelock
   // Raise the priroity for threads with EE=0
   assign raise_iss_pri_d     = (~spr_msr_ee & spr_ccr3_en_eepri) | (llcnt_q[0] & cspr_tspr_llpri & spr_xucr1_ll_en);
   assign xu_iu_raise_iss_pri = raise_iss_pri_2_q;

   assign err_llbust_attempt_d   = llstate[0] & ~llstate[1];
   assign err_llbust_failed_d    = llstate[0] & cspr_tspr_llen & spr_xucr1_ll_en & lltap_q & cspr_tspr_llpri;


   tri_direct_err_rpt #(.WIDTH(2)) xu_spr_tspr_llbust_err_rpt(
      .vd(vdd),
      .gd(gnd),
      .err_in({err_llbust_attempt_q,      err_llbust_failed_q}),
      .err_out({xu_pc_err_llbust_attempt, xu_pc_err_llbust_failed})
   );

   // Decrementer Logic
   assign ex3_dec_upper_zero  = ~|dec_q[32:62];
   assign ex3_set_tsr_dis     = dec_running & ex3_dec_upper_zero & dec_q[63];
   assign ex3_dec_zero        = ex3_dec_upper_zero & ~dec_q[63];

   assign ex3_gdec_upper_zero = ~|gdec_q[32:62];
   assign ex3_set_gtsr_dis    = gdec_running & ex3_gdec_upper_zero & gdec_q[63];
   assign ex3_gdec_zero       = ex3_gdec_upper_zero & ~gdec_q[63];

   assign ex3_udec_upper_zero = ~|udec_q[32:62];
   assign ex3_set_tsr_udis    = udec_running & ex3_udec_upper_zero & udec_q[63];
   assign ex3_udec_zero       = ex3_udec_upper_zero & ~udec_q[63];

   // Fixed Interval Timer logic

   assign fit_tb_tap_d        = (spr_tcr_fp == 2'b00) ? tb_tap_edge[5] :
                                (spr_tcr_fp == 2'b01) ? tb_tap_edge[4] :
                                (spr_tcr_fp == 2'b10) ? tb_tap_edge[3] :
                                                        tb_tap_edge[2];
   assign ex3_set_tsr_fis = fit_tb_tap_q;

   assign gfit_tb_tap_d       = (spr_gtcr_fp == 2'b00) ? tb_tap_edge[5] :
                                (spr_gtcr_fp == 2'b01) ? tb_tap_edge[4] :
                                (spr_gtcr_fp == 2'b10) ? tb_tap_edge[3] :
                                                         tb_tap_edge[2];
   assign ex3_set_gtsr_fis    = gfit_tb_tap_q;

   // Watchdog Timer Logic

   assign wdog_tb_tap_d       = (spr_tcr_wp == 2'b00) ? tb_tap_edge[3] :
                                (spr_tcr_wp == 2'b01) ? tb_tap_edge[2] :
                                (spr_tcr_wp == 2'b10) ? tb_tap_edge[9] :
                                                        tb_tap_edge[0];

   assign wdog_pulse          = wdog_tb_tap_q | pc_xu_inj_wdt_reset_q;

   assign gwdog_tb_tap_d      = (spr_gtcr_wp == 2'b00) ? tb_tap_edge[3] :
                                (spr_gtcr_wp == 2'b01) ? tb_tap_edge[2] :
                                (spr_gtcr_wp == 2'b10) ? tb_tap_edge[9] :
                                                         tb_tap_edge[0];

   assign gwdog_pulse         = gwdog_tb_tap_q | pc_xu_inj_wdt_reset_q;

   assign ex3_set_tsr_enw     = wdog_pulse & ~spr_tsr_enw;
   assign ex3_set_tsr_wis     = wdog_pulse & spr_tsr_enw & (~spr_tsr_wis);

   assign ex3_set_tsr         = {ex3_set_tsr_enw, ex3_set_tsr_wis, ex3_set_tsr_dis, ex3_set_tsr_fis, ex3_set_tsr_udis};

   assign ex3_set_gtsr_enw    = gwdog_pulse & (~spr_gtsr_enw);
   assign ex3_set_gtsr_wis    = gwdog_pulse & spr_gtsr_enw & (~spr_gtsr_wis);

   assign ex3_set_gtsr        = {ex3_set_gtsr_enw, ex3_set_gtsr_wis, ex3_set_gtsr_dis, ex3_set_gtsr_fis};

   // Resets
   assign reset_complete      = (reset_3_complete == 1'b1) ? 2'b11 :
                                (reset_2_complete == 1'b1) ? 2'b10 :
                                (reset_1_complete == 1'b1) ? 2'b01 :
                                                             2'b00;

   assign wdog_reset_1        = spr_tsr_enw & spr_tsr_wis &  (spr_tcr_wrc == 2'b01);
   assign wdog_reset_2        = spr_tsr_enw & spr_tsr_wis &  (spr_tcr_wrc == 2'b10);
   assign wdog_reset_3        = spr_tsr_enw & spr_tsr_wis &  (spr_tcr_wrc == 2'b11);
   assign reset_wd_request    = spr_tsr_enw & spr_tsr_wis & ~(spr_tcr_wrc == 2'b00);

   assign reset_1_request     = wdog_reset_1 | (spr_dbcr0_rst == 2'b01);
   assign reset_2_request     = wdog_reset_2 | (spr_dbcr0_rst == 2'b10);
   assign reset_3_request     = wdog_reset_3 | (spr_dbcr0_rst == 2'b11);
   assign err_wdt_reset_d     = (spr_tsr_enw & spr_tsr_wis) & |(spr_tcr_wrc);


   tri_direct_err_rpt #(.WIDTH(1)) xu_spr_tspr_wdt_err_rpt(
      .vd(vdd),
      .gd(gnd),
      .err_in(err_wdt_reset_q),
      .err_out(xu_pc_err_wdt_reset)
   );

   // DBCR0[FT] Freeze timers
   assign dbcr0_freeze_timers     = spr_dbcr0_ft & (spr_dbsr_ide | dbsr_event);
   assign tspr_cspr_freeze_timers = dbcr0_freeze_timers;

   // Debug Enables

   assign iac_us_en[1] = ((~spr_dbcr1_iac1us[0]) & (~spr_dbcr1_iac1us[1])) | (spr_dbcr1_iac1us[0] & (spr_dbcr1_iac1us[1] ~^ spr_msr_pr));
   assign iac_us_en[2] = ((~spr_dbcr1_iac2us[0]) & (~spr_dbcr1_iac2us[1])) | (spr_dbcr1_iac2us[0] & (spr_dbcr1_iac2us[1] ~^ spr_msr_pr));
   assign iac_us_en[3] = ((~spr_dbcr1_iac3us[0]) & (~spr_dbcr1_iac3us[1])) | (spr_dbcr1_iac3us[0] & (spr_dbcr1_iac3us[1] ~^ spr_msr_pr));
   assign iac_us_en[4] = ((~spr_dbcr1_iac4us[0]) & (~spr_dbcr1_iac4us[1])) | (spr_dbcr1_iac4us[0] & (spr_dbcr1_iac4us[1] ~^ spr_msr_pr));
   assign iac_er_en[1] = ((~spr_dbcr1_iac1er[0]) & (~spr_dbcr1_iac1er[1])) | (spr_dbcr1_iac1er[0] & (spr_dbcr1_iac1er[1] ~^ spr_msr_is));
   assign iac_er_en[2] = ((~spr_dbcr1_iac2er[0]) & (~spr_dbcr1_iac2er[1])) | (spr_dbcr1_iac2er[0] & (spr_dbcr1_iac2er[1] ~^ spr_msr_is));
   assign iac_er_en[3] = ((~spr_dbcr1_iac3er[0]) & (~spr_dbcr1_iac3er[1])) | (spr_dbcr1_iac3er[0] & (spr_dbcr1_iac3er[1] ~^ spr_msr_is));
   assign iac_er_en[4] = ((~spr_dbcr1_iac4er[0]) & (~spr_dbcr1_iac4er[1])) | (spr_dbcr1_iac4er[0] & (spr_dbcr1_iac4er[1] ~^ spr_msr_is));

   assign iac1_en_d     = spr_dbcr0_iac1 & iac_us_en[1] & iac_er_en[1];
   assign iac2_en_d     = spr_dbcr0_iac2 & iac_us_en[2] & iac_er_en[2];
   assign iac3_en_d     = spr_dbcr0_iac3 & iac_us_en[3] & iac_er_en[3];
   assign iac4_en_d     = spr_dbcr0_iac4 & iac_us_en[4] & iac_er_en[4];
   assign xu_iu_iac1_en = iac1_en_q;
   assign xu_iu_iac2_en = iac2_en_q;
   assign xu_iu_iac3_en = iac3_en_q;
   assign xu_iu_iac4_en = iac4_en_q;

   // Async Interrupts
   assign xu_iu_crit_interrupt   = cspr_tspr_sleep_mask & crit_interrupt_q;
   assign xu_iu_gwdog_interrupt  = cspr_tspr_sleep_mask & gwdog_interrupt_q;
   assign xu_iu_wdog_interrupt   = cspr_tspr_sleep_mask & wdog_interrupt_q;
   assign xu_iu_gdec_interrupt   = cspr_tspr_sleep_mask & gdec_interrupt_q;
   assign xu_iu_dec_interrupt    = cspr_tspr_sleep_mask & dec_interrupt_q;
   assign xu_iu_udec_interrupt   = cspr_tspr_sleep_mask & udec_interrupt_q;
   assign xu_iu_perf_interrupt   = cspr_tspr_sleep_mask & perf_interrupt_q;
   assign xu_iu_fit_interrupt    = cspr_tspr_sleep_mask & fit_interrupt_q;
   assign xu_iu_gfit_interrupt   = cspr_tspr_sleep_mask & gfit_interrupt_q;
   assign xu_iu_ext_interrupt    = cspr_tspr_sleep_mask & ext_interrupt_q;
   assign xu_iu_external_mchk    = cspr_tspr_sleep_mask & mchk_interrupt_q;

   assign mchk_interrupt      = cspr_tspr_crit_mask & an_ac_external_mchk_q   & (spr_msr_gs | spr_msr_me);
   assign crit_interrupt      = cspr_tspr_crit_mask & an_ac_crit_interrupt_q  & (spr_msr_gs | spr_msr_ce);
   assign wdog_interrupt      = cspr_tspr_wdog_mask & spr_tsr_wis             & (spr_msr_gs | spr_msr_ce) & spr_tcr_wie;
   assign dec_interrupt       = cspr_tspr_dec_mask  & spr_tsr_dis             & (spr_msr_gs | spr_msr_ee) & spr_tcr_die;
   assign udec_interrupt      = cspr_tspr_udec_mask & spr_tsr_udis            & (spr_msr_gs | spr_msr_ee) & spr_tcr_udie;
   assign perf_interrupt      = cspr_tspr_perf_mask & an_ac_perf_interrupt_q  & (spr_msr_gs | spr_msr_ee);
   assign fit_interrupt       = cspr_tspr_fit_mask  & spr_tsr_fis             & (spr_msr_gs | spr_msr_ee) & spr_tcr_fie;
   assign ext_interrupt       = cspr_tspr_ext_mask  & an_ac_ext_interrupt_q   & ((spr_epcr_extgs & spr_msr_gs & spr_msr_ee) | (~spr_epcr_extgs & (spr_msr_gs | spr_msr_ee)));

   assign gwdog_interrupt     = cspr_tspr_wdog_mask & spr_gtsr_wis            & (spr_msr_gs & spr_msr_ce) & spr_gtcr_wie;
   assign gdec_interrupt      = cspr_tspr_dec_mask  & spr_gtsr_dis            & (spr_msr_gs & spr_msr_ee) & spr_gtcr_die;
   assign gfit_interrupt      = cspr_tspr_fit_mask  & spr_gtsr_fis            & (spr_msr_gs & spr_msr_ee) & spr_gtcr_fie;

   assign tspr_cspr_pm_wake_up   =  mchk_interrupt_q |
                                    crit_interrupt_q |
                                    wdog_interrupt_q |
                                    dec_interrupt_q |
                                    udec_interrupt_q |
                                    perf_interrupt_q |
                                    fit_interrupt_q |
                                    ext_interrupt_q |
                                    gwdog_interrupt_q |
                                    gdec_interrupt_q |
                                    gfit_interrupt_q;

   assign tspr_cspr_async_int = {an_ac_ext_interrupt_q, an_ac_crit_interrupt_q, an_ac_perf_interrupt_q};

   assign tspr_cspr_gpir_match = cspr_tspr_dbell_pirtag == gpir_do[51:64];

   // MSR Override

   assign mux_msr_pr = (cspr_tspr_msrovride_en == 1'b1) ? msrovride_pr_q : spr_msr_pr;
   assign mux_msr_gs = (cspr_tspr_msrovride_en == 1'b1) ? msrovride_gs_q : spr_msr_gs;
   assign mux_msr_de = (cspr_tspr_msrovride_en == 1'b1) ? msrovride_de_q : spr_msr_de;

   assign mux_msr_gs_d = {3{mux_msr_gs}};
   assign mux_msr_pr_d = {1{mux_msr_pr}};

   assign udec_en = ram_active_q | spr_tcr_ud;

   generate
      if (`EFF_IFAR_ARCH > 30)
      begin : int_rest_ifar_gen
         assign int_rest_ifar[62-`EFF_IFAR_ARCH:31]   =  (srr0_q[64-`EFF_IFAR_ARCH:33]    & {`EFF_IFAR_ARCH-30{(iu_rfi_q   & spr_srr1_cm)}})     |
                                                         (gsrr0_q[64-`EFF_IFAR_ARCH:33]   & {`EFF_IFAR_ARCH-30{(iu_rfgi_q  & spr_gsrr1_cm)}})    |
                                                         (csrr0_q[64-`EFF_IFAR_ARCH:33]   & {`EFF_IFAR_ARCH-30{(iu_rfci_q  & spr_csrr1_cm)}})    |
                                                         (mcsrr0_q[64-`EFF_IFAR_ARCH:33]  & {`EFF_IFAR_ARCH-30{(iu_rfmci_q & spr_mcsrr1_cm)}})   ;
      end
   endgenerate
   assign int_rest_ifar[32:61] =    (srr0_q[34:63]    & {30{iu_rfi_q}})  |
                                    (gsrr0_q[34:63]   & {30{iu_rfgi_q}}) |
                                    (csrr0_q[34:63]   & {30{iu_rfci_q}}) |
                                    (mcsrr0_q[34:63]  & {30{iu_rfmci_q}});

   assign int_rest_act = iu_rfi_q | iu_rfgi_q | iu_rfci_q | iu_rfmci_q;

   // IO signal assignments
   assign tspr_epcr_icm       = spr_epcr_icm;
   assign tspr_epcr_gicm      = spr_epcr_gicm;
   assign tspr_msr_de         = mux_msr_de;
   assign tspr_msr_cm         = spr_msr_cm;
   assign tspr_msr_is         = spr_msr_is;
   assign tspr_msr_gs         = mux_msr_gs_q[2];
   assign tspr_msr_pr         = mux_msr_pr_q[0];
   assign tspr_msr_ee         = spr_msr_ee;
   assign tspr_msr_ce         = spr_msr_ce;
   assign tspr_msr_me         = spr_msr_me;
   assign tspr_msr_fe0        = spr_msr_fe0;
   assign tspr_msr_fe1        = spr_msr_fe1;
   assign tspr_fp_precise     = spr_msr_fe0 | spr_msr_fe1;
   assign tspr_epcr_extgs     = spr_epcr_extgs;
   assign dbsr_event          = |(dbsr_q[45:63]);
   assign xu_iu_dbsr_ide      = spr_dbsr_ide & dbsr_event & spr_msr_de & dbcr0_q[43] & ~(epcr_q[59] & ~spr_msr_gs & ~spr_msr_pr);
   assign single_instr_mode_d = spr_ccr3_si | spr_msr_fe0 | spr_msr_fe1 | instr_trace_mode;
   assign xu_iu_single_instr_mode = single_instr_mode_2_q;
   assign machine_check_d     = |(mcsr_q);
   assign ac_tc_machine_check = machine_check_q;
   assign tspr_cspr_ex2_np1_flush = ex2_is_mtspr_q & (ex2_dbcr0_wdec | ex2_epcr_wdec);

   // Debug
   assign tspr_debug = {12{1'b0}};

   assign ex2_srr0_re2     = iu_rfi_q;
   assign ex2_gsrr0_re2    = iu_rfgi_q;
   assign ex2_csrr0_re2    = iu_rfci_q;
   assign ex2_mcsrr0_re2   = iu_rfmci_q;

   generate
      if (a2mode == 0 & hvmode == 0)
      begin : readmux_00
			assign ex3_tspr_rt_d =
			(ccr3_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr3_re            }}) |
			(dbcr0_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_dbcr0_re           }}) |
			(dbcr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_dbcr1_re           }}) |
			(dbsr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_dbsr_re            }}) |
			(dear_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_dear_re            }}) |
			(dec_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_dec_re             }}) |
			(dnhdr_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_dnhdr_re           }}) |
			(esr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_esr_re             }}) |
			(iar_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_iar_re             }}) |
			(msr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_is_mfmsr           }}) |
			(siar_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_siar_re            }}) |
			(srr0_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{(ex2_srr0_re | ex2_srr0_re2)}}) |
			(srr1_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_srr1_re            }}) |
			(xucr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xucr1_re           }});
      end
   endgenerate
   generate
      if (a2mode == 0 & hvmode == 1)
      begin : readmux_01
			assign ex3_tspr_rt_d =
			(ccr3_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr3_re            }}) |
			(dbcr0_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_dbcr0_re           }}) |
			(dbcr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_dbcr1_re           }}) |
			(dbsr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_dbsr_re            }}) |
			(dear_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_dear_re            }}) |
			(dec_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_dec_re             }}) |
			(dnhdr_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_dnhdr_re           }}) |
			(epcr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_epcr_re            }}) |
			(esr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_esr_re             }}) |
			(gdear_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_gdear_re           }}) |
			(gdec_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_gdec_re            }}) |
			(gdecar_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{ex2_gdecar_re          }}) |
			(gesr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_gesr_re            }}) |
			(gpir_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_gpir_re            }}) |
			(gsrr0_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{(ex2_gsrr0_re | ex2_gsrr0_re2)}}) |
			(gsrr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_gsrr1_re           }}) |
			(gtcr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_gtcr_re            }}) |
			(gtsr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_gtsr_re            }}) |
			(iar_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_iar_re             }}) |
			(msr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_is_mfmsr           }}) |
			(msrp_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_msrp_re            }}) |
			(siar_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_siar_re            }}) |
			(srr0_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{(ex2_srr0_re | ex2_srr0_re2)}}) |
			(srr1_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_srr1_re            }}) |
			(xucr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xucr1_re           }});
      end
   endgenerate
   generate
      if (a2mode == 1 & hvmode == 0)
      begin : readmux_10
			assign ex3_tspr_rt_d =
			(ccr3_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr3_re            }}) |
			(csrr0_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{(ex2_csrr0_re | ex2_csrr0_re2)}}) |
			(csrr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_csrr1_re           }}) |
			(dbcr0_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_dbcr0_re           }}) |
			(dbcr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_dbcr1_re           }}) |
			(dbsr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_dbsr_re            }}) |
			(dear_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_dear_re            }}) |
			(dec_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_dec_re             }}) |
			(decar_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_decar_re           }}) |
			(dnhdr_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_dnhdr_re           }}) |
			(esr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_esr_re             }}) |
			(iar_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_iar_re             }}) |
			(mcsr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_mcsr_re            }}) |
			(mcsrr0_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{(ex2_mcsrr0_re | ex2_mcsrr0_re2)}}) |
			(mcsrr1_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{ex2_mcsrr1_re          }}) |
			(msr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_is_mfmsr           }}) |
			(siar_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_siar_re            }}) |
			(srr0_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{(ex2_srr0_re | ex2_srr0_re2)}}) |
			(srr1_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_srr1_re            }}) |
			(tcr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_tcr_re             }}) |
			(tsr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_tsr_re             }}) |
			(udec_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_udec_re            }}) |
			(xucr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xucr1_re           }});
      end
   endgenerate
   generate
      if (a2mode == 1 & hvmode == 1)
      begin : readmux_11
			assign ex3_tspr_rt_d =
			(ccr3_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_ccr3_re            }}) |
			(csrr0_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{(ex2_csrr0_re | ex2_csrr0_re2)}}) |
			(csrr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_csrr1_re           }}) |
			(dbcr0_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_dbcr0_re           }}) |
			(dbcr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_dbcr1_re           }}) |
			(dbsr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_dbsr_re            }}) |
			(dear_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_dear_re            }}) |
			(dec_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_dec_re             }}) |
			(decar_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_decar_re           }}) |
			(dnhdr_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_dnhdr_re           }}) |
			(epcr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_epcr_re            }}) |
			(esr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_esr_re             }}) |
			(gdear_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_gdear_re           }}) |
			(gdec_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_gdec_re            }}) |
			(gdecar_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{ex2_gdecar_re          }}) |
			(gesr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_gesr_re            }}) |
			(gpir_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_gpir_re            }}) |
			(gsrr0_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{(ex2_gsrr0_re | ex2_gsrr0_re2)}}) |
			(gsrr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_gsrr1_re           }}) |
			(gtcr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_gtcr_re            }}) |
			(gtsr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_gtsr_re            }}) |
			(iar_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_iar_re             }}) |
			(mcsr_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_mcsr_re            }}) |
			(mcsrr0_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{(ex2_mcsrr0_re | ex2_mcsrr0_re2)}}) |
			(mcsrr1_do[65-`GPR_WIDTH:64]          & {`GPR_WIDTH{ex2_mcsrr1_re          }}) |
			(msr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_is_mfmsr           }}) |
			(msrp_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_msrp_re            }}) |
			(siar_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_siar_re            }}) |
			(srr0_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{(ex2_srr0_re | ex2_srr0_re2)}}) |
			(srr1_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_srr1_re            }}) |
			(tcr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_tcr_re             }}) |
			(tsr_do[65-`GPR_WIDTH:64]             & {`GPR_WIDTH{ex2_tsr_re             }}) |
			(udec_do[65-`GPR_WIDTH:64]            & {`GPR_WIDTH{ex2_udec_re            }}) |
			(xucr1_do[65-`GPR_WIDTH:64]           & {`GPR_WIDTH{ex2_xucr1_re           }});
      end
   endgenerate

   generate
   genvar i;
      for (i=0;i<`GPR_WIDTH;i=i+1)
      begin : ex3_tid_rpwr_gen
         assign tspr_cspr_ex3_tspr_rt[i] = ex3_tspr_rt_q[i] & ex3_tid_rpwr_q[i % (`GPR_WIDTH/8)];
      end
   endgenerate

   // Reads
   assign ex2_pir_rdec        = (ex2_instr[11:20] == 10'b1111001000);	 //  286
	assign ex2_ccr3_rdec       = (ex2_instr[11:20] == 10'b1010111111);   // 1013
	assign ex2_csrr0_rdec      = (ex2_instr[11:20] == 10'b1101000001);   //   58
	assign ex2_csrr1_rdec      = (ex2_instr[11:20] == 10'b1101100001);   //   59
	assign ex2_dbcr0_rdec      = (ex2_instr[11:20] == 10'b1010001001);   //  308
	assign ex2_dbcr1_rdec      = (ex2_instr[11:20] == 10'b1010101001);   //  309
	assign ex2_dbsr_rdec       = (ex2_instr[11:20] == 10'b1000001001);   //  304
	assign ex2_dear_rdec       = (ex2_instr[11:20] == 10'b1110100001);   //   61
	assign ex2_dec_rdec        = (ex2_instr[11:20] == 10'b1011000000);   //   22
	assign ex2_decar_rdec      = (ex2_instr[11:20] == 10'b1011000001);   //   54
	assign ex2_dnhdr_rdec      = (ex2_instr[11:20] == 10'b1011111010);   //  855
	assign ex2_epcr_rdec       = (ex2_instr[11:20] == 10'b1001101001);   //  307
	assign ex2_esr_rdec        = (ex2_instr[11:20] == 10'b1111000001);   //   62
	assign ex2_gdear_rdec      = (ex2_instr[11:20] == 10'b1110101011);   //  381
	assign ex2_gdec_rdec       = (ex2_instr[11:20] == 10'b1011001011);   //  374
	assign ex2_gdecar_rdec     = (ex2_instr[11:20] == 10'b1010100001);   //   53
	assign ex2_gesr_rdec       = (ex2_instr[11:20] == 10'b1111101011);   //  383
	assign ex2_gpir_rdec       = (ex2_instr[11:20] == 10'b1111001011);   //  382
	assign ex2_gsrr0_rdec      = (ex2_instr[11:20] == 10'b1101001011);   //  378
	assign ex2_gsrr1_rdec      = (ex2_instr[11:20] == 10'b1101101011);   //  379
	assign ex2_gtcr_rdec       = (ex2_instr[11:20] == 10'b1011101011);   //  375
	assign ex2_gtsr_rdec       = (ex2_instr[11:20] == 10'b1100001011);   //  376
	assign ex2_iar_rdec        = (ex2_instr[11:20] == 10'b1001011011);   //  882
	assign ex2_mcsr_rdec       = (ex2_instr[11:20] == 10'b1110010001);   //  572
	assign ex2_mcsrr0_rdec     = (ex2_instr[11:20] == 10'b1101010001);   //  570
	assign ex2_mcsrr1_rdec     = (ex2_instr[11:20] == 10'b1101110001);   //  571
	assign ex2_msrp_rdec       = (ex2_instr[11:20] == 10'b1011101001);   //  311
	assign ex2_siar_rdec       = (ex2_instr[11:20] == 10'b1110011000);   //  796
	assign ex2_srr0_rdec       = (ex2_instr[11:20] == 10'b1101000000);   //   26
	assign ex2_srr1_rdec       = (ex2_instr[11:20] == 10'b1101100000);   //   27
	assign ex2_tcr_rdec        = (ex2_instr[11:20] == 10'b1010001010);   //  340
	assign ex2_tsr_rdec        = (ex2_instr[11:20] == 10'b1000001010);   //  336
	assign ex2_udec_rdec       = udec_en &
                                (ex2_instr[11:20] == 10'b0011010001);   //  550
	assign ex2_xucr1_rdec      = (ex2_instr[11:20] == 10'b1001111010);   //  851
	assign ex2_ccr3_re         =  ex2_ccr3_rdec;
	assign ex2_csrr0_re        =  ex2_csrr0_rdec;
	assign ex2_csrr1_re        =  ex2_csrr1_rdec;
	assign ex2_dbcr0_re        =  ex2_dbcr0_rdec;
	assign ex2_dbcr1_re        =  ex2_dbcr1_rdec;
	assign ex2_dbsr_re         =  ex2_dbsr_rdec;
	assign ex2_dear_re         =  ex2_dear_rdec      & ~mux_msr_gs_q[0];
	assign ex2_dec_re          =  ex2_dec_rdec       & ~mux_msr_gs_q[0];
	assign ex2_decar_re        =  ex2_decar_rdec     & ~mux_msr_gs_q[0];
	assign ex2_dnhdr_re        =  ex2_dnhdr_rdec;
	assign ex2_epcr_re         =  ex2_epcr_rdec;
	assign ex2_esr_re          =  ex2_esr_rdec       & ~mux_msr_gs_q[0];
	assign ex2_gdear_re        = (ex2_gdear_rdec     | (ex2_dear_rdec   & mux_msr_gs_q[0]));
	assign ex2_gdec_re         = (ex2_gdec_rdec      | (ex2_dec_rdec    & mux_msr_gs_q[0]));
	assign ex2_gdecar_re       = (ex2_gdecar_rdec    | (ex2_decar_rdec  & mux_msr_gs_q[0]));
	assign ex2_gesr_re         = (ex2_gesr_rdec      | (ex2_esr_rdec    & mux_msr_gs_q[0]));
	assign ex2_gpir_re         = (ex2_gpir_rdec      | (ex2_pir_rdec    & mux_msr_gs_q[0]));
	assign ex2_gsrr0_re        = (ex2_gsrr0_rdec     | (ex2_srr0_rdec   & mux_msr_gs_q[0]));
	assign ex2_gsrr1_re        = (ex2_gsrr1_rdec     | (ex2_srr1_rdec   & mux_msr_gs_q[0]));
	assign ex2_gtcr_re         = (ex2_gtcr_rdec      | (ex2_tcr_rdec    & mux_msr_gs_q[0]));
	assign ex2_gtsr_re         = (ex2_gtsr_rdec      | (ex2_tsr_rdec    & mux_msr_gs_q[0]));
	assign ex2_iar_re          =  ex2_iar_rdec;
	assign ex2_mcsr_re         =  ex2_mcsr_rdec;
	assign ex2_mcsrr0_re       =  ex2_mcsrr0_rdec;
	assign ex2_mcsrr1_re       =  ex2_mcsrr1_rdec;
	assign ex2_msrp_re         =  ex2_msrp_rdec;
	assign ex2_siar_re         =  ex2_siar_rdec;
	assign ex2_srr0_re         =  ex2_srr0_rdec      & ~mux_msr_gs_q[0];
	assign ex2_srr1_re         =  ex2_srr1_rdec      & ~mux_msr_gs_q[0];
	assign ex2_tcr_re          =  ex2_tcr_rdec       & ~mux_msr_gs_q[0];
	assign ex2_tsr_re          =  ex2_tsr_rdec       & ~mux_msr_gs_q[0];
	assign ex2_udec_re         =  ex2_udec_rdec;
	assign ex2_xucr1_re        =  ex2_xucr1_rdec;

   // Writes
	assign ex2_ccr3_wdec       = ex2_ccr3_rdec;
	assign ex2_csrr0_wdec      = ex2_csrr0_rdec;
	assign ex2_csrr1_wdec      = ex2_csrr1_rdec;
	assign ex2_dbcr0_wdec      = ex2_dbcr0_rdec;
	assign ex2_dbcr1_wdec      = ex2_dbcr1_rdec;
	assign ex2_dbsr_wdec       = ex2_dbsr_rdec;
	assign ex2_dbsrwr_wdec     = (ex2_instr[11:20] == 10'b1001001001);   //  306
	assign ex2_dear_wdec       = ex2_dear_rdec;
	assign ex2_dec_wdec        = ex2_dec_rdec;
	assign ex2_decar_wdec      = ex2_decar_rdec;
	assign ex2_dnhdr_wdec      = ex2_dnhdr_rdec;
	assign ex2_epcr_wdec       = ex2_epcr_rdec;
	assign ex2_esr_wdec        = ex2_esr_rdec;
	assign ex2_gdear_wdec      = ex2_gdear_rdec;
	assign ex2_gdec_wdec       = ex2_gdec_rdec;
	assign ex2_gdecar_wdec     = ex2_gdecar_rdec;
	assign ex2_gesr_wdec       = ex2_gesr_rdec;
	assign ex2_gpir_wdec       = (ex2_instr[11:20] == 10'b1111001011);   //  382
	assign ex2_gsrr0_wdec      = ex2_gsrr0_rdec;
	assign ex2_gsrr1_wdec      = ex2_gsrr1_rdec;
	assign ex2_gtcr_wdec       = ex2_gtcr_rdec;
	assign ex2_gtsr_wdec       = ex2_gtsr_rdec;
	assign ex2_gtsrwr_wdec     = (ex2_instr[11:20] == 10'b1110000001);   //   60
	assign ex2_iar_wdec        = ex2_iar_rdec;
	assign ex2_mcsr_wdec       = ex2_mcsr_rdec;
	assign ex2_mcsrr0_wdec     = ex2_mcsrr0_rdec;
	assign ex2_mcsrr1_wdec     = ex2_mcsrr1_rdec;
	assign ex2_msrp_wdec       = ex2_msrp_rdec;
	assign ex2_siar_wdec       = ex2_siar_rdec;
	assign ex2_srr0_wdec       = ex2_srr0_rdec;
	assign ex2_srr1_wdec       = ex2_srr1_rdec;
	assign ex2_tcr_wdec        = ex2_tcr_rdec;
	assign ex2_tsr_wdec        = ex2_tsr_rdec;
	assign ex2_udec_wdec       = udec_en &
                                ex2_udec_rdec;
	assign ex2_xucr1_wdec      = ex2_xucr1_rdec;
	assign ex2_ccr3_we         =  ex2_ccr3_wdec;
	assign ex2_csrr0_we        =  ex2_csrr0_wdec;
	assign ex2_csrr1_we        =  ex2_csrr1_wdec;
	assign ex2_dbcr0_we        =  ex2_dbcr0_wdec;
	assign ex2_dbcr1_we        =  ex2_dbcr1_wdec;
	assign ex2_dbsr_we         =  ex2_dbsr_wdec;
	assign ex2_dbsrwr_we       =  ex2_dbsrwr_wdec;
	assign ex2_dear_we         =  ex2_dear_wdec      & ~mux_msr_gs_q[1];
	assign ex2_dec_we          =  ex2_dec_wdec       & ~mux_msr_gs_q[1];
	assign ex2_decar_we        =  ex2_decar_wdec     & ~mux_msr_gs_q[1];
	assign ex2_dnhdr_we        =  ex2_dnhdr_wdec;
	assign ex2_epcr_we         =  ex2_epcr_wdec;
	assign ex2_esr_we          =  ex2_esr_wdec       & ~mux_msr_gs_q[1];
	assign ex2_gdear_we        = (ex2_gdear_wdec     | (ex2_dear_wdec   & mux_msr_gs_q[1]));
	assign ex2_gdec_we         = (ex2_gdec_wdec      | (ex2_dec_wdec    & mux_msr_gs_q[1]));
	assign ex2_gdecar_we       = (ex2_gdecar_wdec    | (ex2_decar_wdec  & mux_msr_gs_q[1]));
	assign ex2_gesr_we         = (ex2_gesr_wdec      | (ex2_esr_wdec    & mux_msr_gs_q[1]));
	assign ex2_gpir_we         =  ex2_gpir_wdec;
	assign ex2_gsrr0_we        = (ex2_gsrr0_wdec     | (ex2_srr0_wdec   & mux_msr_gs_q[1]));
	assign ex2_gsrr1_we        = (ex2_gsrr1_wdec     | (ex2_srr1_wdec   & mux_msr_gs_q[1]));
	assign ex2_gtcr_we         = (ex2_gtcr_wdec      | (ex2_tcr_wdec    & mux_msr_gs_q[1]));
	assign ex2_gtsr_we         = (ex2_gtsr_wdec      | (ex2_tsr_wdec    & mux_msr_gs_q[1]));
	assign ex2_gtsrwr_we       =  ex2_gtsrwr_wdec;
	assign ex2_iar_we          =  ex2_iar_wdec;
	assign ex2_mcsr_we         =  ex2_mcsr_wdec;
	assign ex2_mcsrr0_we       =  ex2_mcsrr0_wdec;
	assign ex2_mcsrr1_we       =  ex2_mcsrr1_wdec;
	assign ex2_msrp_we         =  ex2_msrp_wdec;
	assign ex2_siar_we         =  ex2_siar_wdec;
	assign ex2_srr0_we         =  ex2_srr0_wdec      & ~mux_msr_gs_q[1];
	assign ex2_srr1_we         =  ex2_srr1_wdec      & ~mux_msr_gs_q[1];
	assign ex2_tcr_we          =  ex2_tcr_wdec       & ~mux_msr_gs_q[1];
	assign ex2_tsr_we          =  ex2_tsr_wdec       & ~mux_msr_gs_q[1];
	assign ex2_udec_we         =  ex2_udec_wdec;
	assign ex2_xucr1_we        =  ex2_xucr1_wdec;

   // Write Enable
	assign ex3_ccr3_wdec       = (ex3_instr[11:20] == 10'b1010111111);   // 1013
	assign ex3_csrr0_wdec      = (ex3_instr[11:20] == 10'b1101000001);   //   58
	assign ex3_csrr1_wdec      = (ex3_instr[11:20] == 10'b1101100001);   //   59
	assign ex3_dbcr0_wdec      = (ex3_instr[11:20] == 10'b1010001001);   //  308
	assign ex3_dbcr1_wdec      = (ex3_instr[11:20] == 10'b1010101001);   //  309
	assign ex3_dbsr_wdec       = (ex3_instr[11:20] == 10'b1000001001);   //  304
	assign ex3_dbsrwr_wdec     = (ex3_instr[11:20] == 10'b1001001001);   //  306
	assign ex3_dear_wdec       = (ex3_instr[11:20] == 10'b1110100001);   //   61
	assign ex3_dec_wdec        = (ex3_instr[11:20] == 10'b1011000000);   //   22
	assign ex3_decar_wdec      = (ex3_instr[11:20] == 10'b1011000001);   //   54
	assign ex3_dnhdr_wdec      = (ex3_instr[11:20] == 10'b1011111010);   //  855
	assign ex3_epcr_wdec       = (ex3_instr[11:20] == 10'b1001101001);   //  307
	assign ex3_esr_wdec        = (ex3_instr[11:20] == 10'b1111000001);   //   62
	assign ex3_gdear_wdec      = (ex3_instr[11:20] == 10'b1110101011);   //  381
	assign ex3_gdec_wdec       = (ex3_instr[11:20] == 10'b1011001011);   //  374
	assign ex3_gdecar_wdec     = (ex3_instr[11:20] == 10'b1010100001);   //   53
	assign ex3_gesr_wdec       = (ex3_instr[11:20] == 10'b1111101011);   //  383
	assign ex3_gpir_wdec       = (ex3_instr[11:20] == 10'b1111001011);   //  382
	assign ex3_gsrr0_wdec      = (ex3_instr[11:20] == 10'b1101001011);   //  378
	assign ex3_gsrr1_wdec      = (ex3_instr[11:20] == 10'b1101101011);   //  379
	assign ex3_gtcr_wdec       = (ex3_instr[11:20] == 10'b1011101011);   //  375
	assign ex3_gtsr_wdec       = (ex3_instr[11:20] == 10'b1100001011);   //  376
	assign ex3_gtsrwr_wdec     = (ex3_instr[11:20] == 10'b1110000001);   //   60
	assign ex3_iar_wdec        = (ex3_instr[11:20] == 10'b1001011011);   //  882
	assign ex3_mcsr_wdec       = (ex3_instr[11:20] == 10'b1110010001);   //  572
	assign ex3_mcsrr0_wdec     = (ex3_instr[11:20] == 10'b1101010001);   //  570
	assign ex3_mcsrr1_wdec     = (ex3_instr[11:20] == 10'b1101110001);   //  571
	assign ex3_msr_wdec        =  ex3_is_mtmsr;
	assign ex3_msrp_wdec       = (ex3_instr[11:20] == 10'b1011101001);   //  311
	assign ex3_siar_wdec       = (ex3_instr[11:20] == 10'b1110011000);   //  796
	assign ex3_srr0_wdec       = (ex3_instr[11:20] == 10'b1101000000);   //   26
	assign ex3_srr1_wdec       = (ex3_instr[11:20] == 10'b1101100000);   //   27
	assign ex3_tcr_wdec        = (ex3_instr[11:20] == 10'b1010001010);   //  340
	assign ex3_tsr_wdec        = (ex3_instr[11:20] == 10'b1000001010);   //  336
	assign ex3_udec_wdec       = udec_en &
                                (ex3_instr[11:20] == 10'b0011010001);   //  550
	assign ex3_xucr1_wdec      = (ex3_instr[11:20] == 10'b1001111010);   //  851
	assign ex3_ccr3_we        = ex3_spr_we & ex3_is_mtspr &  ex3_ccr3_wdec;
	assign ex3_csrr0_we       = ex3_spr_we & ex3_is_mtspr &  ex3_csrr0_wdec;
	assign ex3_csrr1_we       = ex3_spr_we & ex3_is_mtspr &  ex3_csrr1_wdec;
	assign ex3_dbcr0_we       = ex3_spr_we & ex3_is_mtspr &  ex3_dbcr0_wdec;
	assign ex3_dbcr1_we       = ex3_spr_we & ex3_is_mtspr &  ex3_dbcr1_wdec;
	assign ex3_dbsr_we        = ex3_spr_we & ex3_is_mtspr &  ex3_dbsr_wdec;
	assign ex3_dbsrwr_we      = ex3_spr_we & ex3_is_mtspr &  ex3_dbsrwr_wdec;
	assign ex3_dear_we        = ex3_spr_we & ex3_is_mtspr &  ex3_dear_wdec      & ~mux_msr_gs_q[1];
	assign ex3_dec_we         = ex3_spr_we & ex3_is_mtspr &  ex3_dec_wdec       & ~mux_msr_gs_q[1];
	assign ex3_decar_we       = ex3_spr_we & ex3_is_mtspr &  ex3_decar_wdec     & ~mux_msr_gs_q[1];
	assign ex3_dnhdr_we       = ex3_spr_we & ex3_is_mtspr &  ex3_dnhdr_wdec;
	assign ex3_epcr_we        = ex3_spr_we & ex3_is_mtspr &  ex3_epcr_wdec;
	assign ex3_esr_we         = ex3_spr_we & ex3_is_mtspr &  ex3_esr_wdec       & ~mux_msr_gs_q[1];
	assign ex3_gdear_we       = ex3_spr_we & ex3_is_mtspr & (ex3_gdear_wdec     | (ex3_dear_wdec   & mux_msr_gs_q[1]));
	assign ex3_gdec_we        = ex3_spr_we & ex3_is_mtspr & (ex3_gdec_wdec      | (ex3_dec_wdec    & mux_msr_gs_q[1]));
	assign ex3_gdecar_we      = ex3_spr_we & ex3_is_mtspr & (ex3_gdecar_wdec    | (ex3_decar_wdec  & mux_msr_gs_q[1]));
	assign ex3_gesr_we        = ex3_spr_we & ex3_is_mtspr & (ex3_gesr_wdec      | (ex3_esr_wdec    & mux_msr_gs_q[1]));
	assign ex3_gpir_we        = ex3_spr_we & ex3_is_mtspr &  ex3_gpir_wdec;
	assign ex3_gsrr0_we       = ex3_spr_we & ex3_is_mtspr & (ex3_gsrr0_wdec     | (ex3_srr0_wdec   & mux_msr_gs_q[1]));
	assign ex3_gsrr1_we       = ex3_spr_we & ex3_is_mtspr & (ex3_gsrr1_wdec     | (ex3_srr1_wdec   & mux_msr_gs_q[1]));
	assign ex3_gtcr_we        = ex3_spr_we & ex3_is_mtspr & (ex3_gtcr_wdec      | (ex3_tcr_wdec    & mux_msr_gs_q[1]));
	assign ex3_gtsr_we        = ex3_spr_we & ex3_is_mtspr & (ex3_gtsr_wdec      | (ex3_tsr_wdec    & mux_msr_gs_q[1]));
	assign ex3_gtsrwr_we      = ex3_spr_we & ex3_is_mtspr &  ex3_gtsrwr_wdec;
	assign ex3_iar_we         = ex3_spr_we & ex3_is_mtspr &  ex3_iar_wdec;
	assign ex3_mcsr_we        = ex3_spr_we & ex3_is_mtspr &  ex3_mcsr_wdec;
	assign ex3_mcsrr0_we      = ex3_spr_we & ex3_is_mtspr &  ex3_mcsrr0_wdec;
	assign ex3_mcsrr1_we      = ex3_spr_we & ex3_is_mtspr &  ex3_mcsrr1_wdec;
	assign ex3_msr_we         = ex3_spr_we &                      ex3_msr_wdec;
	assign ex3_msrp_we        = ex3_spr_we & ex3_is_mtspr &  ex3_msrp_wdec;
	assign ex3_siar_we        = ex3_spr_we & ex3_is_mtspr &  ex3_siar_wdec;
	assign ex3_srr0_we        = ex3_spr_we & ex3_is_mtspr &  ex3_srr0_wdec      & ~mux_msr_gs_q[1];
	assign ex3_srr1_we        = ex3_spr_we & ex3_is_mtspr &  ex3_srr1_wdec      & ~mux_msr_gs_q[1];
	assign ex3_tcr_we         = ex3_spr_we & ex3_is_mtspr &  ex3_tcr_wdec       & ~mux_msr_gs_q[1];
	assign ex3_tsr_we         = ex3_spr_we & ex3_is_mtspr &  ex3_tsr_wdec       & ~mux_msr_gs_q[1];
	assign ex3_udec_we        = ex3_spr_we & ex3_is_mtspr &  ex3_udec_wdec;
	assign ex3_xucr1_we       = ex3_spr_we & ex3_is_mtspr &  ex3_xucr1_wdec;

   // Illegal SPR checks
   generate
      if (a2mode == 0 & hvmode == 0)
      begin : ill_spr_00
         assign tspr_cspr_illeg_mtspr_b =
                             ex2_ccr3_wdec        | ex2_dbcr0_wdec       | ex2_dbcr1_wdec
                           | ex2_dbsr_wdec        | ex2_dear_wdec        | ex2_dec_wdec
                           | ex2_dnhdr_wdec       | ex2_esr_wdec         | ex2_iar_wdec
                           | ex2_siar_wdec        | ex2_srr0_wdec        | ex2_srr1_wdec
                           | ex2_xucr1_wdec       ;

         assign tspr_cspr_illeg_mfspr_b =
                             ex2_ccr3_rdec        | ex2_dbcr0_rdec       | ex2_dbcr1_rdec
                           | ex2_dbsr_rdec        | ex2_dear_rdec        | ex2_dec_rdec
                           | ex2_dnhdr_rdec       | ex2_esr_rdec         | ex2_iar_rdec
                           | ex2_siar_rdec        | ex2_srr0_rdec        | ex2_srr1_rdec
                           | ex2_xucr1_rdec       ;

         assign tspr_cspr_hypv_mtspr =
                             ex2_ccr3_we          | ex2_dbcr0_we         | ex2_dbcr1_we
                           | ex2_dbsr_we          | ex2_dnhdr_we         | ex2_iar_we
                           | ex2_xucr1_we         ;

         assign tspr_cspr_hypv_mfspr =
                             ex2_ccr3_re          | ex2_dbcr0_re         | ex2_dbcr1_re
                           | ex2_dbsr_re          | ex2_dnhdr_re         | ex2_iar_re
                           | ex2_xucr1_re         ;
      end
   endgenerate

   generate
      if (a2mode == 0 & hvmode == 1)
      begin : ill_spr_01
         assign tspr_cspr_illeg_mtspr_b =
                             ex2_ccr3_wdec        | ex2_dbcr0_wdec       | ex2_dbcr1_wdec
                           | ex2_dbsr_wdec        | ex2_dbsrwr_wdec      | ex2_dear_wdec
                           | ex2_dec_wdec         | ex2_dnhdr_wdec       | ex2_epcr_wdec
                           | ex2_esr_wdec         | ex2_gdear_wdec       | ex2_gdec_wdec
                           | ex2_gdecar_wdec      | ex2_gesr_wdec        | ex2_gpir_wdec
                           | ex2_gsrr0_wdec       | ex2_gsrr1_wdec       | ex2_gtcr_wdec
                           | ex2_gtsr_wdec        | ex2_gtsrwr_wdec      | ex2_iar_wdec
                           | ex2_msrp_wdec        | ex2_siar_wdec        | ex2_srr0_wdec
                           | ex2_srr1_wdec        | ex2_xucr1_wdec       ;

         assign tspr_cspr_illeg_mfspr_b =
                             ex2_ccr3_rdec        | ex2_dbcr0_rdec       | ex2_dbcr1_rdec
                           | ex2_dbsr_rdec        | ex2_dear_rdec        | ex2_dec_rdec
                           | ex2_dnhdr_rdec       | ex2_epcr_rdec        | ex2_esr_rdec
                           | ex2_gdear_rdec       | ex2_gdec_rdec        | ex2_gdecar_rdec
                           | ex2_gesr_rdec        | ex2_gpir_rdec        | ex2_gsrr0_rdec
                           | ex2_gsrr1_rdec       | ex2_gtcr_rdec        | ex2_gtsr_rdec
                           | ex2_iar_rdec         | ex2_msrp_rdec        | ex2_siar_rdec
                           | ex2_srr0_rdec        | ex2_srr1_rdec        | ex2_xucr1_rdec       ;

         assign tspr_cspr_hypv_mtspr =
                             ex2_ccr3_we          | ex2_dbcr0_we         | ex2_dbcr1_we
                           | ex2_dbsr_we          | ex2_dbsrwr_we        | ex2_dnhdr_we
                           | ex2_epcr_we          | ex2_gpir_we          | ex2_gtsrwr_we
                           | ex2_iar_we           | ex2_msrp_we          | ex2_xucr1_we         ;

         assign tspr_cspr_hypv_mfspr =
                             ex2_ccr3_re          | ex2_dbcr0_re         | ex2_dbcr1_re
                           | ex2_dbsr_re          | ex2_dnhdr_re         | ex2_epcr_re
                           | ex2_iar_re           | ex2_msrp_re          | ex2_xucr1_re         ;
      end
   endgenerate

   generate
      if (a2mode == 1 & hvmode == 0)
      begin : ill_spr_10
         assign tspr_cspr_illeg_mtspr_b =
                             ex2_ccr3_wdec        | ex2_csrr0_wdec       | ex2_csrr1_wdec
                           | ex2_dbcr0_wdec       | ex2_dbcr1_wdec       | ex2_dbsr_wdec
                           | ex2_dear_wdec        | ex2_dec_wdec         | ex2_decar_wdec
                           | ex2_dnhdr_wdec       | ex2_esr_wdec         | ex2_iar_wdec
                           | ex2_mcsr_wdec        | ex2_mcsrr0_wdec      | ex2_mcsrr1_wdec
                           | ex2_siar_wdec        | ex2_srr0_wdec        | ex2_srr1_wdec
                           | ex2_tcr_wdec         | ex2_tsr_wdec         | ex2_udec_wdec
                           | ex2_xucr1_wdec       ;

         assign tspr_cspr_illeg_mfspr_b =
                             ex2_ccr3_rdec        | ex2_csrr0_rdec       | ex2_csrr1_rdec
                           | ex2_dbcr0_rdec       | ex2_dbcr1_rdec       | ex2_dbsr_rdec
                           | ex2_dear_rdec        | ex2_dec_rdec         | ex2_decar_rdec
                           | ex2_dnhdr_rdec       | ex2_esr_rdec         | ex2_iar_rdec
                           | ex2_mcsr_rdec        | ex2_mcsrr0_rdec      | ex2_mcsrr1_rdec
                           | ex2_siar_rdec        | ex2_srr0_rdec        | ex2_srr1_rdec
                           | ex2_tcr_rdec         | ex2_tsr_rdec         | ex2_udec_rdec
                           | ex2_xucr1_rdec       ;

         assign tspr_cspr_hypv_mtspr =
                             ex2_ccr3_we          | ex2_csrr0_we         | ex2_csrr1_we
                           | ex2_dbcr0_we         | ex2_dbcr1_we         | ex2_dbsr_we
                           | ex2_dnhdr_we         | ex2_iar_we           | ex2_mcsr_we
                           | ex2_mcsrr0_we        | ex2_mcsrr1_we        | ex2_xucr1_we         ;

         assign tspr_cspr_hypv_mfspr =
                             ex2_ccr3_re          | ex2_csrr0_re         | ex2_csrr1_re
                           | ex2_dbcr0_re         | ex2_dbcr1_re         | ex2_dbsr_re
                           | ex2_dnhdr_re         | ex2_iar_re           | ex2_mcsr_re
                           | ex2_mcsrr0_re        | ex2_mcsrr1_re        | ex2_xucr1_re         ;
      end
   endgenerate

   generate
      if (a2mode == 1 & hvmode == 1)
      begin : ill_spr_11
         assign tspr_cspr_illeg_mtspr_b =
                             ex2_ccr3_wdec        | ex2_csrr0_wdec       | ex2_csrr1_wdec
                           | ex2_dbcr0_wdec       | ex2_dbcr1_wdec       | ex2_dbsr_wdec
                           | ex2_dbsrwr_wdec      | ex2_dear_wdec        | ex2_dec_wdec
                           | ex2_decar_wdec       | ex2_dnhdr_wdec       | ex2_epcr_wdec
                           | ex2_esr_wdec         | ex2_gdear_wdec       | ex2_gdec_wdec
                           | ex2_gdecar_wdec      | ex2_gesr_wdec        | ex2_gpir_wdec
                           | ex2_gsrr0_wdec       | ex2_gsrr1_wdec       | ex2_gtcr_wdec
                           | ex2_gtsr_wdec        | ex2_gtsrwr_wdec      | ex2_iar_wdec
                           | ex2_mcsr_wdec        | ex2_mcsrr0_wdec      | ex2_mcsrr1_wdec
                           | ex2_msrp_wdec        | ex2_siar_wdec        | ex2_srr0_wdec
                           | ex2_srr1_wdec        | ex2_tcr_wdec         | ex2_tsr_wdec
                           | ex2_udec_wdec        | ex2_xucr1_wdec       ;

         assign tspr_cspr_illeg_mfspr_b =
                             ex2_ccr3_rdec        | ex2_csrr0_rdec       | ex2_csrr1_rdec
                           | ex2_dbcr0_rdec       | ex2_dbcr1_rdec       | ex2_dbsr_rdec
                           | ex2_dear_rdec        | ex2_dec_rdec         | ex2_decar_rdec
                           | ex2_dnhdr_rdec       | ex2_epcr_rdec        | ex2_esr_rdec
                           | ex2_gdear_rdec       | ex2_gdec_rdec        | ex2_gdecar_rdec
                           | ex2_gesr_rdec        | ex2_gpir_rdec        | ex2_gsrr0_rdec
                           | ex2_gsrr1_rdec       | ex2_gtcr_rdec        | ex2_gtsr_rdec
                           | ex2_iar_rdec         | ex2_mcsr_rdec        | ex2_mcsrr0_rdec
                           | ex2_mcsrr1_rdec      | ex2_msrp_rdec        | ex2_siar_rdec
                           | ex2_srr0_rdec        | ex2_srr1_rdec        | ex2_tcr_rdec
                           | ex2_tsr_rdec         | ex2_udec_rdec        | ex2_xucr1_rdec       ;

         assign tspr_cspr_hypv_mtspr =
                             ex2_ccr3_we          | ex2_csrr0_we         | ex2_csrr1_we
                           | ex2_dbcr0_we         | ex2_dbcr1_we         | ex2_dbsr_we
                           | ex2_dbsrwr_we        | ex2_dnhdr_we         | ex2_epcr_we
                           | ex2_gpir_we          | ex2_gtsrwr_we        | ex2_iar_we
                           | ex2_mcsr_we          | ex2_mcsrr0_we        | ex2_mcsrr1_we
                           | ex2_msrp_we          | ex2_xucr1_we         ;

         assign tspr_cspr_hypv_mfspr =
                             ex2_ccr3_re          | ex2_csrr0_re         | ex2_csrr1_re
                           | ex2_dbcr0_re         | ex2_dbcr1_re         | ex2_dbsr_re
                           | ex2_dnhdr_re         | ex2_epcr_re          | ex2_iar_re
                           | ex2_mcsr_re          | ex2_mcsrr0_re        | ex2_mcsrr1_re
                           | ex2_msrp_re          | ex2_xucr1_re         ;
      end
   endgenerate

	assign spr_ccr3_en_eepri           = ccr3_q[62];
	assign spr_ccr3_si                 = ccr3_q[63];
	assign spr_csrr1_cm                = csrr1_q[50];
	assign spr_dbcr0_idm               = dbcr0_q[43];
	assign spr_dbcr0_rst               = dbcr0_q[44:45];
	assign spr_dbcr0_icmp              = dbcr0_q[46];
	assign spr_dbcr0_brt               = dbcr0_q[47];
	assign spr_dbcr0_irpt              = dbcr0_q[48];
	assign spr_dbcr0_trap              = dbcr0_q[49];
	assign spr_dbcr0_iac1              = dbcr0_q[50];
	assign spr_dbcr0_iac2              = dbcr0_q[51];
	assign spr_dbcr0_iac3              = dbcr0_q[52];
	assign spr_dbcr0_iac4              = dbcr0_q[53];
	assign spr_dbcr0_dac1              = dbcr0_q[54:55];
	assign spr_dbcr0_dac2              = dbcr0_q[56:57];
	assign spr_dbcr0_ret               = dbcr0_q[58];
	assign spr_dbcr0_dac3              = dbcr0_q[59:60];
	assign spr_dbcr0_dac4              = dbcr0_q[61:62];
	assign spr_dbcr0_ft                = dbcr0_q[63];
	assign spr_dbcr1_iac1us            = dbcr1_q[46:47];
	assign spr_dbcr1_iac1er            = dbcr1_q[48:49];
	assign spr_dbcr1_iac2us            = dbcr1_q[50:51];
	assign spr_dbcr1_iac2er            = dbcr1_q[52:53];
	assign spr_dbcr1_iac12m            = dbcr1_q[54];
	assign spr_dbcr1_iac3us            = dbcr1_q[55:56];
	assign spr_dbcr1_iac3er            = dbcr1_q[57:58];
	assign spr_dbcr1_iac4us            = dbcr1_q[59:60];
	assign spr_dbcr1_iac4er            = dbcr1_q[61:62];
	assign spr_dbcr1_iac34m            = dbcr1_q[63];
	assign spr_dbsr_ide                = dbsr_q[44];
	assign spr_epcr_extgs              = epcr_q[54];
	assign spr_epcr_dtlbgs             = epcr_q[55];
	assign spr_epcr_itlbgs             = epcr_q[56];
	assign spr_epcr_dsigs              = epcr_q[57];
	assign spr_epcr_isigs              = epcr_q[58];
	assign spr_epcr_duvd               = epcr_q[59];
	assign spr_epcr_icm                = epcr_q[60];
	assign spr_epcr_gicm               = epcr_q[61];
	assign spr_epcr_dgtmi              = epcr_q[62];
	assign xu_mm_spr_epcr_dmiuh        = epcr_q[63];
	assign spr_gsrr1_cm                = gsrr1_q[50];
	assign spr_gtcr_wp                 = gtcr_q[54:55];
	assign spr_gtcr_wrc                = gtcr_q[56:57];
	assign spr_gtcr_wie                = gtcr_q[58];
	assign spr_gtcr_die                = gtcr_q[59];
	assign spr_gtcr_fp                 = gtcr_q[60:61];
	assign spr_gtcr_fie                = gtcr_q[62];
	assign spr_gtcr_are                = gtcr_q[63];
	assign spr_gtsr_enw                = gtsr_q[60];
	assign spr_gtsr_wis                = gtsr_q[61];
	assign spr_gtsr_dis                = gtsr_q[62];
	assign spr_gtsr_fis                = gtsr_q[63];
	assign spr_mcsrr1_cm               = mcsrr1_q[50];
	assign spr_msr_cm                  = msr_q[50];
	assign spr_msr_gs                  = msr_q[51];
	assign spr_msr_ucle                = msr_q[52];
	assign spr_msr_spv                 = msr_q[53];
	assign spr_msr_ce                  = msr_q[54];
	assign spr_msr_ee                  = msr_q[55];
	assign spr_msr_pr                  = msr_q[56];
	assign spr_msr_fp                  = msr_q[57];
	assign spr_msr_me                  = msr_q[58];
	assign spr_msr_fe0                 = msr_q[59];
	assign spr_msr_de                  = msr_q[60];
	assign spr_msr_fe1                 = msr_q[61];
	assign spr_msr_is                  = msr_q[62];
	assign spr_msr_ds                  = msr_q[63];
	assign spr_msrp_uclep              = msrp_q[62];
	assign spr_srr1_cm                 = srr1_q[50];
	assign spr_tcr_wp                  = tcr_q[52:53];
	assign spr_tcr_wrc                 = tcr_q[54:55];
	assign spr_tcr_wie                 = tcr_q[56];
	assign spr_tcr_die                 = tcr_q[57];
	assign spr_tcr_fp                  = tcr_q[58:59];
	assign spr_tcr_fie                 = tcr_q[60];
	assign spr_tcr_are                 = tcr_q[61];
	assign spr_tcr_udie                = tcr_q[62];
	assign spr_tcr_ud                  = tcr_q[63];
	assign spr_tsr_enw                 = tsr_q[59];
	assign spr_tsr_wis                 = tsr_q[60];
	assign spr_tsr_dis                 = tsr_q[61];
	assign spr_tsr_fis                 = tsr_q[62];
	assign spr_tsr_udis                = tsr_q[63];
	assign spr_xucr1_ll_tb_sel         = xucr1_q[59:61];
	assign spr_xucr1_ll_sel            = xucr1_q[62];
	assign spr_xucr1_ll_en             = xucr1_q[63];

	// CCR3
	assign ex3_ccr3_di     = { ex3_spr_wd[62:62]                , //EN_EEPRI
                              ex3_spr_wd[63:63]                }; //SI

	assign ccr3_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:61]                      , /////
                              ccr3_q[62:62]                    , //EN_EEPRI
                              ccr3_q[63:63]                    }; //SI
	// CSRR0
	assign ex3_csrr0_di    = { ex3_spr_wd[62-(`EFF_IFAR_ARCH):61]}; //SRR0

	assign csrr0_do        = { tidn[0:62-(`EFF_IFAR_ARCH)]      ,
                              csrr0_q[64-(`EFF_IFAR_ARCH):63]  , //SRR0
                              tidn[62:63]                      }; /////
	// CSRR1
	assign ex3_csrr1_di    = { ex3_spr_wd[32:32]                , //CM
                              ex3_spr_wd[35:35]                , //GS
                              ex3_spr_wd[37:37]                , //UCLE
                              ex3_spr_wd[38:38]                , //SPV
                              ex3_spr_wd[46:46]                , //CE
                              ex3_spr_wd[48:48]                , //EE
                              ex3_spr_wd[49:49]                , //PR
                              ex3_spr_wd[50:50]                , //FP
                              ex3_spr_wd[51:51]                , //ME
                              ex3_spr_wd[52:52]                , //FE0
                              ex3_spr_wd[54:54]                , //DE
                              ex3_spr_wd[55:55]                , //FE1
                              ex3_spr_wd[58:58]                , //IS
                              ex3_spr_wd[59:59]                }; //DS

	assign csrr1_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              csrr1_q[50:50]                   , //CM
                              tidn[33:34]                      , /////
                              csrr1_q[51:51]                   , //GS
                              tidn[36:36]                      , /////
                              csrr1_q[52:52]                   , //UCLE
                              csrr1_q[53:53]                   , //SPV
                              tidn[39:45]                      , /////
                              csrr1_q[54:54]                   , //CE
                              tidn[47:47]                      , /////
                              csrr1_q[55:55]                   , //EE
                              csrr1_q[56:56]                   , //PR
                              csrr1_q[57:57]                   , //FP
                              csrr1_q[58:58]                   , //ME
                              csrr1_q[59:59]                   , //FE0
                              tidn[53:53]                      , /////
                              csrr1_q[60:60]                   , //DE
                              csrr1_q[61:61]                   , //FE1
                              tidn[56:57]                      , /////
                              csrr1_q[62:62]                   , //IS
                              csrr1_q[63:63]                   , //DS
                              tidn[60:63]                      }; /////
	// DBCR0
	assign ex3_dbcr0_di    = { ex3_spr_wd[33:33]                , //IDM
                              ex3_spr_wd[34:35]                , //RST
                              ex3_spr_wd[36:36]                , //ICMP
                              ex3_spr_wd[37:37]                , //BRT
                              ex3_spr_wd[38:38]                , //IRPT
                              ex3_spr_wd[39:39]                , //TRAP
                              ex3_spr_wd[40:40]                , //IAC1
                              ex3_spr_wd[41:41]                , //IAC2
                              ex3_spr_wd[42:42]                , //IAC3
                              ex3_spr_wd[43:43]                , //IAC4
                              ex3_spr_wd[44:45]                , //DAC1
                              ex3_spr_wd[46:47]                , //DAC2
                              ex3_spr_wd[48:48]                , //RET
                              ex3_spr_wd[59:60]                , //DAC3
                              ex3_spr_wd[61:62]                , //DAC4
                              ex3_spr_wd[63:63]                }; //FT

	assign dbcr0_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              spr_dbcr0_edm                    , //EDM
                              dbcr0_q[43:43]                   , //IDM
                              dbcr0_q[44:45]                   , //RST
                              dbcr0_q[46:46]                   , //ICMP
                              dbcr0_q[47:47]                   , //BRT
                              dbcr0_q[48:48]                   , //IRPT
                              dbcr0_q[49:49]                   , //TRAP
                              dbcr0_q[50:50]                   , //IAC1
                              dbcr0_q[51:51]                   , //IAC2
                              dbcr0_q[52:52]                   , //IAC3
                              dbcr0_q[53:53]                   , //IAC4
                              dbcr0_q[54:55]                   , //DAC1
                              dbcr0_q[56:57]                   , //DAC2
                              dbcr0_q[58:58]                   , //RET
                              tidn[49:58]                      , /////
                              dbcr0_q[59:60]                   , //DAC3
                              dbcr0_q[61:62]                   , //DAC4
                              dbcr0_q[63:63]                   }; //FT
	// DBCR1
	assign ex3_dbcr1_di    = { ex3_spr_wd[32:33]                , //IAC1US
                              ex3_spr_wd[34:35]                , //IAC1ER
                              ex3_spr_wd[36:37]                , //IAC2US
                              ex3_spr_wd[38:39]                , //IAC2ER
                              ex3_spr_wd[41:41]                , //IAC12M
                              ex3_spr_wd[48:49]                , //IAC3US
                              ex3_spr_wd[50:51]                , //IAC3ER
                              ex3_spr_wd[52:53]                , //IAC4US
                              ex3_spr_wd[54:55]                , //IAC4ER
                              ex3_spr_wd[57:57]                }; //IAC34M

	assign dbcr1_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              dbcr1_q[46:47]                   , //IAC1US
                              dbcr1_q[48:49]                   , //IAC1ER
                              dbcr1_q[50:51]                   , //IAC2US
                              dbcr1_q[52:53]                   , //IAC2ER
                              tidn[40:40]                      , /////
                              dbcr1_q[54:54]                   , //IAC12M
                              tidn[42:47]                      , /////
                              dbcr1_q[55:56]                   , //IAC3US
                              dbcr1_q[57:58]                   , //IAC3ER
                              dbcr1_q[59:60]                   , //IAC4US
                              dbcr1_q[61:62]                   , //IAC4ER
                              tidn[56:56]                      , /////
                              dbcr1_q[63:63]                   , //IAC34M
                              tidn[58:63]                      }; /////
	// DBSR
	assign ex3_dbsr_di     = { ex3_spr_wd[32:32]                , //IDE
                              ex3_spr_wd[33:33]                , //UDE
                              ex3_spr_wd[36:36]                , //ICMP
                              ex3_spr_wd[37:37]                , //BRT
                              ex3_spr_wd[38:38]                , //IRPT
                              ex3_spr_wd[39:39]                , //TRAP
                              ex3_spr_wd[40:40]                , //IAC1
                              ex3_spr_wd[41:41]                , //IAC2
                              ex3_spr_wd[42:42]                , //IAC3
                              ex3_spr_wd[43:43]                , //IAC4
                              ex3_spr_wd[44:44]                , //DAC1R
                              ex3_spr_wd[45:45]                , //DAC1W
                              ex3_spr_wd[46:46]                , //DAC2R
                              ex3_spr_wd[47:47]                , //DAC2W
                              ex3_spr_wd[48:48]                , //RET
                              ex3_spr_wd[59:59]                , //DAC3R
                              ex3_spr_wd[60:60]                , //DAC3W
                              ex3_spr_wd[61:61]                , //DAC4R
                              ex3_spr_wd[62:62]                , //DAC4W
                              ex3_spr_wd[63:63]                }; //IVC

	assign dbsr_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              dbsr_q[44:44]                    , //IDE
                              dbsr_q[45:45]                    , //UDE
                              dbsr_mrr_q[0:1]                  , //MRR
                              dbsr_q[46:46]                    , //ICMP
                              dbsr_q[47:47]                    , //BRT
                              dbsr_q[48:48]                    , //IRPT
                              dbsr_q[49:49]                    , //TRAP
                              dbsr_q[50:50]                    , //IAC1
                              dbsr_q[51:51]                    , //IAC2
                              dbsr_q[52:52]                    , //IAC3
                              dbsr_q[53:53]                    , //IAC4
                              dbsr_q[54:54]                    , //DAC1R
                              dbsr_q[55:55]                    , //DAC1W
                              dbsr_q[56:56]                    , //DAC2R
                              dbsr_q[57:57]                    , //DAC2W
                              dbsr_q[58:58]                    , //RET
                              tidn[49:58]                      , /////
                              dbsr_q[59:59]                    , //DAC3R
                              dbsr_q[60:60]                    , //DAC3W
                              dbsr_q[61:61]                    , //DAC4R
                              dbsr_q[62:62]                    , //DAC4W
                              dbsr_q[63:63]                    }; //IVC
	// DEAR
	assign ex3_dear_di     = { ex3_spr_wd[64-(`GPR_WIDTH):63]   }; //DEAR

	assign dear_do         = { tidn[0:64-(`GPR_WIDTH)]          ,
                              dear_q[64-(`GPR_WIDTH):63]       }; //DEAR
	// DEC
	assign ex3_dec_di      = { ex3_spr_wd[32:63]                }; //DEC

	assign dec_do          = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              dec_q[32:63]                     }; //DEC
	// DECAR
	assign ex3_decar_di    = { ex3_spr_wd[32:63]                }; //DECAR

	assign decar_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              decar_q[32:63]                   }; //DECAR
	// DNHDR
	assign ex3_dnhdr_di    = { ex3_spr_wd[48:52]                , //DUI
                              ex3_spr_wd[54:63]                }; //DUIS

	assign dnhdr_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:47]                      , /////
                              dnhdr_q[49:53]                   , //DUI
                              tidn[53:53]                      , /////
                              dnhdr_q[54:63]                   }; //DUIS
	// EPCR
	assign ex3_epcr_di     = { ex3_spr_wd[32:32]                , //EXTGS
                              ex3_spr_wd[33:33]                , //DTLBGS
                              ex3_spr_wd[34:34]                , //ITLBGS
                              ex3_spr_wd[35:35]                , //DSIGS
                              ex3_spr_wd[36:36]                , //ISIGS
                              ex3_spr_wd[37:37]                , //DUVD
                              ex3_spr_wd[38:38]                , //ICM
                              ex3_spr_wd[39:39]                , //GICM
                              ex3_spr_wd[40:40]                , //DGTMI
                              ex3_spr_wd[41:41]                }; //DMIUH

	assign epcr_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              epcr_q[54:54]                    , //EXTGS
                              epcr_q[55:55]                    , //DTLBGS
                              epcr_q[56:56]                    , //ITLBGS
                              epcr_q[57:57]                    , //DSIGS
                              epcr_q[58:58]                    , //ISIGS
                              epcr_q[59:59]                    , //DUVD
                              epcr_q[60:60]                    , //ICM
                              epcr_q[61:61]                    , //GICM
                              epcr_q[62:62]                    , //DGTMI
                              epcr_q[63:63]                    , //DMIUH
                              tidn[42:63]                      }; /////
	// ESR
	assign ex3_esr_di      = { ex3_spr_wd[36:36]                , //PIL
                              ex3_spr_wd[37:37]                , //PPR
                              ex3_spr_wd[38:38]                , //PTR
                              ex3_spr_wd[39:39]                , //FP
                              ex3_spr_wd[40:40]                , //ST
                              ex3_spr_wd[42:42]                , //DLK0
                              ex3_spr_wd[43:43]                , //DLK1
                              ex3_spr_wd[44:44]                , //AP
                              ex3_spr_wd[45:45]                , //PUO
                              ex3_spr_wd[46:46]                , //BO
                              ex3_spr_wd[47:47]                , //PIE
                              ex3_spr_wd[49:49]                , //UCT
                              ex3_spr_wd[53:53]                , //DATA
                              ex3_spr_wd[54:54]                , //TLBI
                              ex3_spr_wd[55:55]                , //PT
                              ex3_spr_wd[56:56]                , //SPV
                              ex3_spr_wd[57:57]                }; //EPID

	assign esr_do          = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:35]                      , /////
                              esr_q[47:47]                     , //PIL
                              esr_q[48:48]                     , //PPR
                              esr_q[49:49]                     , //PTR
                              esr_q[50:50]                     , //FP
                              esr_q[51:51]                     , //ST
                              tidn[41:41]                      , /////
                              esr_q[52:52]                     , //DLK0
                              esr_q[53:53]                     , //DLK1
                              esr_q[54:54]                     , //AP
                              esr_q[55:55]                     , //PUO
                              esr_q[56:56]                     , //BO
                              esr_q[57:57]                     , //PIE
                              tidn[48:48]                      , /////
                              esr_q[58:58]                     , //UCT
                              tidn[50:52]                      , /////
                              esr_q[59:59]                     , //DATA
                              esr_q[60:60]                     , //TLBI
                              esr_q[61:61]                     , //PT
                              esr_q[62:62]                     , //SPV
                              esr_q[63:63]                     , //EPID
                              tidn[58:63]                      }; /////
	// GDEAR
	assign ex3_gdear_di    = { ex3_spr_wd[64-(`GPR_WIDTH):63]   }; //GDEAR

	assign gdear_do        = { tidn[0:64-(`GPR_WIDTH)]          ,
                              gdear_q[64-(`GPR_WIDTH):63]      }; //GDEAR
	// GDEC
	assign ex3_gdec_di     = { ex3_spr_wd[32:63]                }; //DEC

	assign gdec_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              gdec_q[32:63]                    }; //DEC
	// GDECAR
	assign ex3_gdecar_di   = { ex3_spr_wd[32:63]                }; //DECAR

	assign gdecar_do       = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              gdecar_q[32:63]                  }; //DECAR
	// GESR
	assign ex3_gesr_di     = { ex3_spr_wd[36:36]                , //PIL
                              ex3_spr_wd[37:37]                , //PPR
                              ex3_spr_wd[38:38]                , //PTR
                              ex3_spr_wd[39:39]                , //FP
                              ex3_spr_wd[40:40]                , //ST
                              ex3_spr_wd[42:42]                , //DLK0
                              ex3_spr_wd[43:43]                , //DLK1
                              ex3_spr_wd[44:44]                , //AP
                              ex3_spr_wd[45:45]                , //PUO
                              ex3_spr_wd[46:46]                , //BO
                              ex3_spr_wd[47:47]                , //PIE
                              ex3_spr_wd[49:49]                , //UCT
                              ex3_spr_wd[53:53]                , //DATA
                              ex3_spr_wd[54:54]                , //TLBI
                              ex3_spr_wd[55:55]                , //PT
                              ex3_spr_wd[56:56]                , //SPV
                              ex3_spr_wd[57:57]                }; //EPID

	assign gesr_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:35]                      , /////
                              gesr_q[47:47]                    , //PIL
                              gesr_q[48:48]                    , //PPR
                              gesr_q[49:49]                    , //PTR
                              gesr_q[50:50]                    , //FP
                              gesr_q[51:51]                    , //ST
                              tidn[41:41]                      , /////
                              gesr_q[52:52]                    , //DLK0
                              gesr_q[53:53]                    , //DLK1
                              gesr_q[54:54]                    , //AP
                              gesr_q[55:55]                    , //PUO
                              gesr_q[56:56]                    , //BO
                              gesr_q[57:57]                    , //PIE
                              tidn[48:48]                      , /////
                              gesr_q[58:58]                    , //UCT
                              tidn[50:52]                      , /////
                              gesr_q[59:59]                    , //DATA
                              gesr_q[60:60]                    , //TLBI
                              gesr_q[61:61]                    , //PT
                              gesr_q[62:62]                    , //SPV
                              gesr_q[63:63]                    , //EPID
                              tidn[58:63]                      }; /////
	// GPIR
	assign ex3_gpir_di     = { ex3_spr_wd[32:49]                , //VPTAG
                              ex3_spr_wd[50:63]                }; //DBTAG

	assign gpir_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              gpir_q[32:49]                    , //VPTAG
                              gpir_q[50:63]                    }; //DBTAG
	// GSRR0
	assign ex3_gsrr0_di    = { ex3_spr_wd[62-(`EFF_IFAR_ARCH):61]}; //GSRR0

	assign gsrr0_do        = { tidn[0:62-(`EFF_IFAR_ARCH)]      ,
                              gsrr0_q[64-(`EFF_IFAR_ARCH):63]  , //GSRR0
                              tidn[62:63]                      }; /////
	// GSRR1
	assign ex3_gsrr1_di    = { ex3_spr_wd[32:32]                , //CM
                              ex3_spr_wd[35:35]                , //GS
                              ex3_spr_wd[37:37]                , //UCLE
                              ex3_spr_wd[38:38]                , //SPV
                              ex3_spr_wd[46:46]                , //CE
                              ex3_spr_wd[48:48]                , //EE
                              ex3_spr_wd[49:49]                , //PR
                              ex3_spr_wd[50:50]                , //FP
                              ex3_spr_wd[51:51]                , //ME
                              ex3_spr_wd[52:52]                , //FE0
                              ex3_spr_wd[54:54]                , //DE
                              ex3_spr_wd[55:55]                , //FE1
                              ex3_spr_wd[58:58]                , //IS
                              ex3_spr_wd[59:59]                }; //DS

	assign gsrr1_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              gsrr1_q[50:50]                   , //CM
                              tidn[33:34]                      , /////
                              gsrr1_q[51:51]                   , //GS
                              tidn[36:36]                      , /////
                              gsrr1_q[52:52]                   , //UCLE
                              gsrr1_q[53:53]                   , //SPV
                              tidn[39:45]                      , /////
                              gsrr1_q[54:54]                   , //CE
                              tidn[47:47]                      , /////
                              gsrr1_q[55:55]                   , //EE
                              gsrr1_q[56:56]                   , //PR
                              gsrr1_q[57:57]                   , //FP
                              gsrr1_q[58:58]                   , //ME
                              gsrr1_q[59:59]                   , //FE0
                              tidn[53:53]                      , /////
                              gsrr1_q[60:60]                   , //DE
                              gsrr1_q[61:61]                   , //FE1
                              tidn[56:57]                      , /////
                              gsrr1_q[62:62]                   , //IS
                              gsrr1_q[63:63]                   , //DS
                              tidn[60:63]                      }; /////
	// GTCR
	assign ex3_gtcr_di     = { ex3_spr_wd[32:33]                , //WP
                              ex3_spr_wd[34:35]                , //WRC
                              ex3_spr_wd[36:36]                , //WIE
                              ex3_spr_wd[37:37]                , //DIE
                              ex3_spr_wd[38:39]                , //FP
                              ex3_spr_wd[40:40]                , //FIE
                              ex3_spr_wd[41:41]                }; //ARE

	assign gtcr_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              gtcr_q[54:55]                    , //WP
                              gtcr_q[56:57]                    , //WRC
                              gtcr_q[58:58]                    , //WIE
                              gtcr_q[59:59]                    , //DIE
                              gtcr_q[60:61]                    , //FP
                              gtcr_q[62:62]                    , //FIE
                              gtcr_q[63:63]                    , //ARE
                              tidn[42:63]                      }; /////
	// GTSR
	assign ex3_gtsr_di     = { ex3_spr_wd[32:32]                , //ENW
                              ex3_spr_wd[33:33]                , //WIS
                              ex3_spr_wd[36:36]                , //DIS
                              ex3_spr_wd[37:37]                }; //FIS

	assign gtsr_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              gtsr_q[60:60]                    , //ENW
                              gtsr_q[61:61]                    , //WIS
                              tsr_wrs_q[0:1]                   , //WRS
                              gtsr_q[62:62]                    , //DIS
                              gtsr_q[63:63]                    , //FIS
                              tidn[38:63]                      }; /////
	// IAR
	assign iar_do          = { tidn[0:64-(`EFF_IFAR_ARCH+2)]    ,
                              ex2_iar[62-`EFF_IFAR_ARCH:61]    , //IAR
                              tidn[62:63]                      }; /////
	// MCSR
	assign ex3_mcsr_di     = { ex3_spr_wd[48:48]                , //DPOVR
                              ex3_spr_wd[49:49]                , //DDMH
                              ex3_spr_wd[50:50]                , //TLBIVAXSR
                              ex3_spr_wd[51:51]                , //TLBLRUPE
                              ex3_spr_wd[52:52]                , //IL2ECC
                              ex3_spr_wd[53:53]                , //DL2ECC
                              ex3_spr_wd[54:54]                , //DDPE
                              ex3_spr_wd[55:55]                , //EXT
                              ex3_spr_wd[56:56]                , //DCPE
                              ex3_spr_wd[57:57]                , //IEMH
                              ex3_spr_wd[58:58]                , //DEMH
                              ex3_spr_wd[59:59]                , //TLBMH
                              ex3_spr_wd[60:60]                , //IEPE
                              ex3_spr_wd[61:61]                , //DEPE
                              ex3_spr_wd[62:62]                }; //TLBPE

	assign mcsr_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:47]                      , /////
                              mcsr_q[49:49]                    , //DPOVR
                              mcsr_q[50:50]                    , //DDMH
                              mcsr_q[51:51]                    , //TLBIVAXSR
                              mcsr_q[52:52]                    , //TLBLRUPE
                              mcsr_q[53:53]                    , //IL2ECC
                              mcsr_q[54:54]                    , //DL2ECC
                              mcsr_q[55:55]                    , //DDPE
                              mcsr_q[56:56]                    , //EXT
                              mcsr_q[57:57]                    , //DCPE
                              mcsr_q[58:58]                    , //IEMH
                              mcsr_q[59:59]                    , //DEMH
                              mcsr_q[60:60]                    , //TLBMH
                              mcsr_q[61:61]                    , //IEPE
                              mcsr_q[62:62]                    , //DEPE
                              mcsr_q[63:63]                    , //TLBPE
                              tidn[63:63]                      }; /////
	// MCSRR0
	assign ex3_mcsrr0_di   = { ex3_spr_wd[62-(`EFF_IFAR_ARCH):61]}; //SRR0

	assign mcsrr0_do       = { tidn[0:62-(`EFF_IFAR_ARCH)]      ,
                              mcsrr0_q[64-(`EFF_IFAR_ARCH):63] , //SRR0
                              tidn[62:63]                      }; /////
	// MCSRR1
	assign ex3_mcsrr1_di   = { ex3_spr_wd[32:32]                , //CM
                              ex3_spr_wd[35:35]                , //GS
                              ex3_spr_wd[37:37]                , //UCLE
                              ex3_spr_wd[38:38]                , //SPV
                              ex3_spr_wd[46:46]                , //CE
                              ex3_spr_wd[48:48]                , //EE
                              ex3_spr_wd[49:49]                , //PR
                              ex3_spr_wd[50:50]                , //FP
                              ex3_spr_wd[51:51]                , //ME
                              ex3_spr_wd[52:52]                , //FE0
                              ex3_spr_wd[54:54]                , //DE
                              ex3_spr_wd[55:55]                , //FE1
                              ex3_spr_wd[58:58]                , //IS
                              ex3_spr_wd[59:59]                }; //DS

	assign mcsrr1_do       = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              mcsrr1_q[50:50]                  , //CM
                              tidn[33:34]                      , /////
                              mcsrr1_q[51:51]                  , //GS
                              tidn[36:36]                      , /////
                              mcsrr1_q[52:52]                  , //UCLE
                              mcsrr1_q[53:53]                  , //SPV
                              tidn[39:45]                      , /////
                              mcsrr1_q[54:54]                  , //CE
                              tidn[47:47]                      , /////
                              mcsrr1_q[55:55]                  , //EE
                              mcsrr1_q[56:56]                  , //PR
                              mcsrr1_q[57:57]                  , //FP
                              mcsrr1_q[58:58]                  , //ME
                              mcsrr1_q[59:59]                  , //FE0
                              tidn[53:53]                      , /////
                              mcsrr1_q[60:60]                  , //DE
                              mcsrr1_q[61:61]                  , //FE1
                              tidn[56:57]                      , /////
                              mcsrr1_q[62:62]                  , //IS
                              mcsrr1_q[63:63]                  , //DS
                              tidn[60:63]                      }; /////
	// MSR
	assign ex3_msr_di      = { ex3_spr_wd[32:32]                , //CM
                              ex3_spr_wd[35:35]                , //GS
                              ex3_spr_wd[37:37]                , //UCLE
                              ex3_spr_wd[38:38]                , //SPV
                              ex3_spr_wd[46:46]                , //CE
                              ex3_spr_wd[48:48]                , //EE
                              ex3_spr_wd[49:49]                , //PR
                              ex3_spr_wd[50:50]                , //FP
                              ex3_spr_wd[51:51]                , //ME
                              ex3_spr_wd[52:52]                , //FE0
                              ex3_spr_wd[54:54]                , //DE
                              ex3_spr_wd[55:55]                , //FE1
                              ex3_spr_wd[58:58]                , //IS
                              ex3_spr_wd[59:59]                }; //DS

	assign msr_do          = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              msr_q[50:50]                     , //CM
                              tidn[33:34]                      , /////
                              msr_q[51:51]                     , //GS
                              tidn[36:36]                      , /////
                              msr_q[52:52]                     , //UCLE
                              msr_q[53:53]                     , //SPV
                              tidn[39:45]                      , /////
                              msr_q[54:54]                     , //CE
                              tidn[47:47]                      , /////
                              msr_q[55:55]                     , //EE
                              msr_q[56:56]                     , //PR
                              msr_q[57:57]                     , //FP
                              msr_q[58:58]                     , //ME
                              msr_q[59:59]                     , //FE0
                              tidn[53:53]                      , /////
                              msr_q[60:60]                     , //DE
                              msr_q[61:61]                     , //FE1
                              tidn[56:57]                      , /////
                              msr_q[62:62]                     , //IS
                              msr_q[63:63]                     , //DS
                              tidn[60:63]                      }; /////
	// MSRP
	assign ex3_msrp_di     = { ex3_spr_wd[37:37]                , //UCLEP
                              ex3_spr_wd[54:54]                }; //DEP

	assign msrp_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:36]                      , /////
                              msrp_q[62:62]                    , //UCLEP
                              tidn[38:53]                      , /////
                              msrp_q[63:63]                    , //DEP
                              tidn[55:63]                      }; /////
	// SIAR
	assign ex3_siar_di     = { ex3_spr_wd[62-(`EFF_IFAR_ARCH):61], //IAR
                              ex3_spr_wd[62:62]                , //GS
                              ex3_spr_wd[63:63]                }; //PR

	assign siar_do         = { tidn[0:62-(`EFF_IFAR_ARCH)]      ,
                              siar_q[62-(`EFF_IFAR_ARCH):61]   , //IAR
                              siar_q[62:62]                    , //GS
                              siar_q[63:63]                    }; //PR
	// SRR0
	assign ex3_srr0_di     = { ex3_spr_wd[62-(`EFF_IFAR_ARCH):61]}; //SRR0

	assign srr0_do         = { tidn[0:62-(`EFF_IFAR_ARCH)]      ,
                              srr0_q[64-(`EFF_IFAR_ARCH):63]   , //SRR0
                              tidn[62:63]                      }; /////
	// SRR1
	assign ex3_srr1_di     = { ex3_spr_wd[32:32]                , //CM
                              ex3_spr_wd[35:35]                , //GS
                              ex3_spr_wd[37:37]                , //UCLE
                              ex3_spr_wd[38:38]                , //SPV
                              ex3_spr_wd[46:46]                , //CE
                              ex3_spr_wd[48:48]                , //EE
                              ex3_spr_wd[49:49]                , //PR
                              ex3_spr_wd[50:50]                , //FP
                              ex3_spr_wd[51:51]                , //ME
                              ex3_spr_wd[52:52]                , //FE0
                              ex3_spr_wd[54:54]                , //DE
                              ex3_spr_wd[55:55]                , //FE1
                              ex3_spr_wd[58:58]                , //IS
                              ex3_spr_wd[59:59]                }; //DS

	assign srr1_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              srr1_q[50:50]                    , //CM
                              tidn[33:34]                      , /////
                              srr1_q[51:51]                    , //GS
                              tidn[36:36]                      , /////
                              srr1_q[52:52]                    , //UCLE
                              srr1_q[53:53]                    , //SPV
                              tidn[39:45]                      , /////
                              srr1_q[54:54]                    , //CE
                              tidn[47:47]                      , /////
                              srr1_q[55:55]                    , //EE
                              srr1_q[56:56]                    , //PR
                              srr1_q[57:57]                    , //FP
                              srr1_q[58:58]                    , //ME
                              srr1_q[59:59]                    , //FE0
                              tidn[53:53]                      , /////
                              srr1_q[60:60]                    , //DE
                              srr1_q[61:61]                    , //FE1
                              tidn[56:57]                      , /////
                              srr1_q[62:62]                    , //IS
                              srr1_q[63:63]                    , //DS
                              tidn[60:63]                      }; /////
	// TCR
	assign ex3_tcr_di      = { ex3_spr_wd[32:33]                , //WP
                              ex3_spr_wd[34:35]                , //WRC
                              ex3_spr_wd[36:36]                , //WIE
                              ex3_spr_wd[37:37]                , //DIE
                              ex3_spr_wd[38:39]                , //FP
                              ex3_spr_wd[40:40]                , //FIE
                              ex3_spr_wd[41:41]                , //ARE
                              ex3_spr_wd[42:42]                , //UDIE
                              ex3_spr_wd[51:51]                }; //UD

	assign tcr_do          = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tcr_q[52:53]                     , //WP
                              tcr_q[54:55]                     , //WRC
                              tcr_q[56:56]                     , //WIE
                              tcr_q[57:57]                     , //DIE
                              tcr_q[58:59]                     , //FP
                              tcr_q[60:60]                     , //FIE
                              tcr_q[61:61]                     , //ARE
                              tcr_q[62:62]                     , //UDIE
                              tidn[43:50]                      , /////
                              tcr_q[63:63]                     , //UD
                              tidn[52:63]                      }; /////
	// TSR
	assign ex3_tsr_di      = { ex3_spr_wd[32:32]                , //ENW
                              ex3_spr_wd[33:33]                , //WIS
                              ex3_spr_wd[36:36]                , //DIS
                              ex3_spr_wd[37:37]                , //FIS
                              ex3_spr_wd[38:38]                }; //UDIS

	assign tsr_do          = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tsr_q[59:59]                     , //ENW
                              tsr_q[60:60]                     , //WIS
                              tsr_wrs_q[0:1]                   , //WRS
                              tsr_q[61:61]                     , //DIS
                              tsr_q[62:62]                     , //FIS
                              tsr_q[63:63]                     , //UDIS
                              tidn[39:63]                      }; /////
	// UDEC
	assign ex3_udec_di     = { ex3_spr_wd[32:63]                }; //UDEC

	assign udec_do         = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              udec_q[32:63]                    }; //UDEC
	// XUCR1
	assign ex3_xucr1_di    = { ex3_spr_wd[57:59]                , //LL_TB_SEL
                              ex3_spr_wd[62:62]                , //LL_SEL
                              ex3_spr_wd[63:63]                }; //LL_EN

	assign xucr1_do        = { tidn[0:0]                        ,
                              tidn[0:31]                       , /////
                              tidn[32:56]                      , /////
                              xucr1_q[59:61]                   , //LL_TB_SEL
                              llstate[0:1]                     , //LL_STATE
                              xucr1_q[62:62]                   , //LL_SEL
                              xucr1_q[63:63]                   }; //LL_EN

	// Unused Signals
	assign unused_do_bits = |{
		ccr3_do[0:64-`GPR_WIDTH]
		,csrr0_do[0:64-`GPR_WIDTH]
		,csrr1_do[0:64-`GPR_WIDTH]
		,dbcr0_do[0:64-`GPR_WIDTH]
		,dbcr1_do[0:64-`GPR_WIDTH]
		,dbsr_do[0:64-`GPR_WIDTH]
		,dear_do[0:64-`GPR_WIDTH]
		,dec_do[0:64-`GPR_WIDTH]
		,decar_do[0:64-`GPR_WIDTH]
		,dnhdr_do[0:64-`GPR_WIDTH]
		,epcr_do[0:64-`GPR_WIDTH]
		,esr_do[0:64-`GPR_WIDTH]
		,gdear_do[0:64-`GPR_WIDTH]
		,gdec_do[0:64-`GPR_WIDTH]
		,gdecar_do[0:64-`GPR_WIDTH]
		,gesr_do[0:64-`GPR_WIDTH]
		,gpir_do[0:64-`GPR_WIDTH]
		,gsrr0_do[0:64-`GPR_WIDTH]
		,gsrr1_do[0:64-`GPR_WIDTH]
		,gtcr_do[0:64-`GPR_WIDTH]
		,gtsr_do[0:64-`GPR_WIDTH]
		,iar_do[0:64-`GPR_WIDTH]
		,mcsr_do[0:64-`GPR_WIDTH]
		,mcsrr0_do[0:64-`GPR_WIDTH]
		,mcsrr1_do[0:64-`GPR_WIDTH]
		,msr_do[0:64-`GPR_WIDTH]
		,msrp_do[0:64-`GPR_WIDTH]
		,siar_do[0:64-`GPR_WIDTH]
		,srr0_do[0:64-`GPR_WIDTH]
		,srr1_do[0:64-`GPR_WIDTH]
		,tcr_do[0:64-`GPR_WIDTH]
		,tsr_do[0:64-`GPR_WIDTH]
		,udec_do[0:64-`GPR_WIDTH]
		,xucr1_do[0:64-`GPR_WIDTH]
		};

   // Unused Signals
   assign unused2 = |{ex2_siar_we,ex2_dear_we,ex2_dec_we,ex2_gdec_we,ex2_gdecar_we,ex2_gtsr_we,ex2_gtsrwr_we,ex2_gtcr_we,ex2_esr_we,ex2_gdear_we,ex2_gesr_we,ex2_gsrr0_we,ex2_gsrr1_we,ex2_srr0_we,ex2_srr1_we,ex2_udec_we,cspr_tspr_ex1_instr[6:10],cspr_tspr_ex1_instr[31],ex3_gdear_di,exx_act_data[1],iar_act};

   assign spr_dvc1 = dvc1_q[64-(`GPR_WIDTH):63];
   assign spr_dvc2 = dvc2_q[64 - (`GPR_WIDTH):63];

   // SPR Latch Instances
     tri_ser_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ccr3_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(ccr3_act),
        .force_t(ccfg_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(ccfg_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv_ccfg[ccr3_offset_ccfg:ccr3_offset_ccfg + 2 - 1]),
        .scout(sov_ccfg[ccr3_offset_ccfg:ccr3_offset_ccfg + 2 - 1]),
        .din(ccr3_d),
        .dout(ccr3_q)
     );
generate
	if (a2mode == 1) begin : csrr0_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) csrr0_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(csrr0_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[csrr0_offset:csrr0_offset + `EFF_IFAR_ARCH - 1]),
        .scout(sov[csrr0_offset:csrr0_offset + `EFF_IFAR_ARCH - 1]),
        .din(csrr0_d),
        .dout(csrr0_q)
     );
	end
	if (a2mode == 0) begin : csrr0_latch_tie
		assign csrr0_q         = {`EFF_IFAR_ARCH{1'b0}};
	end
endgenerate
generate
	if (a2mode == 1) begin : csrr1_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(14), .INIT(0), .NEEDS_SRESET(1)) csrr1_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(csrr1_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[csrr1_offset:csrr1_offset + 14 - 1]),
        .scout(sov[csrr1_offset:csrr1_offset + 14 - 1]),
        .din(csrr1_d),
        .dout(csrr1_q)
     );
	end
	if (a2mode == 0) begin : csrr1_latch_tie
		assign csrr1_q         = {14{1'b0}};
	end
endgenerate
     tri_ser_rlmreg_p #(.WIDTH(21), .INIT(0), .NEEDS_SRESET(1)) dbcr0_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dbcr0_act),
        .force_t(dcfg_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(dcfg_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv_dcfg[dbcr0_offset_dcfg:dbcr0_offset_dcfg + 21 - 1]),
        .scout(sov_dcfg[dbcr0_offset_dcfg:dbcr0_offset_dcfg + 21 - 1]),
        .din(dbcr0_d),
        .dout(dbcr0_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(18), .INIT(0), .NEEDS_SRESET(1)) dbcr1_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dbcr1_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[dbcr1_offset:dbcr1_offset + 18 - 1]),
        .scout(sov[dbcr1_offset:dbcr1_offset + 18 - 1]),
        .din(dbcr1_d),
        .dout(dbcr1_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(20), .INIT(0), .NEEDS_SRESET(1)) dbsr_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dbsr_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[dbsr_offset:dbsr_offset + 20 - 1]),
        .scout(sov[dbsr_offset:dbsr_offset + 20 - 1]),
        .din(dbsr_d),
        .dout(dbsr_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) dear_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dear_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[dear_offset:dear_offset + `GPR_WIDTH - 1]),
        .scout(sov[dear_offset:dear_offset + `GPR_WIDTH - 1]),
        .din(dear_d),
        .dout(dear_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(2147483647), .NEEDS_SRESET(1)) dec_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dec_act),
        .force_t(func_slp_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_slp_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[dec_offset:dec_offset + 32 - 1]),
        .scout(sov[dec_offset:dec_offset + 32 - 1]),
        .din(dec_d),
        .dout(dec_q)
     );
generate
	if (a2mode == 1) begin : decar_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(2147483647), .NEEDS_SRESET(1)) decar_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(decar_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[decar_offset:decar_offset + 32 - 1]),
        .scout(sov[decar_offset:decar_offset + 32 - 1]),
        .din(decar_d),
        .dout(decar_q)
     );
	end
	if (a2mode == 0) begin : decar_latch_tie
		assign decar_q         = {32{1'b0}};
	end
endgenerate
     tri_ser_rlmreg_p #(.WIDTH(15), .INIT(0), .NEEDS_SRESET(1)) dnhdr_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(dnhdr_act),
        .force_t(dcfg_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(dcfg_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv_dcfg[dnhdr_offset_dcfg:dnhdr_offset_dcfg + 15 - 1]),
        .scout(sov_dcfg[dnhdr_offset_dcfg:dnhdr_offset_dcfg + 15 - 1]),
        .din(dnhdr_d),
        .dout(dnhdr_q)
     );
generate
	if (hvmode == 1) begin : epcr_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) epcr_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(epcr_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[epcr_offset:epcr_offset + 10 - 1]),
        .scout(sov[epcr_offset:epcr_offset + 10 - 1]),
        .din(epcr_d),
        .dout(epcr_q)
     );
	end
	if (hvmode == 0) begin : epcr_latch_tie
		assign epcr_q          = {10{1'b0}};
	end
endgenerate
     tri_ser_rlmreg_p #(.WIDTH(17), .INIT(0), .NEEDS_SRESET(1)) esr_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(esr_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[esr_offset:esr_offset + 17 - 1]),
        .scout(sov[esr_offset:esr_offset + 17 - 1]),
        .din(esr_d),
        .dout(esr_q)
     );
generate
	if (hvmode == 1) begin : gdear_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) gdear_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(gdear_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[gdear_offset:gdear_offset + `GPR_WIDTH - 1]),
        .scout(sov[gdear_offset:gdear_offset + `GPR_WIDTH - 1]),
        .din(gdear_d),
        .dout(gdear_q)
     );
	end
	if (hvmode == 0) begin : gdear_latch_tie
		assign gdear_q         = {`GPR_WIDTH{1'b0}};
	end
endgenerate
generate
	if (hvmode == 1) begin : gdec_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(2147483647), .NEEDS_SRESET(1)) gdec_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(gdec_act),
        .force_t(func_slp_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_slp_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[gdec_offset:gdec_offset + 32 - 1]),
        .scout(sov[gdec_offset:gdec_offset + 32 - 1]),
        .din(gdec_d),
        .dout(gdec_q)
     );
	end
	if (hvmode == 0) begin : gdec_latch_tie
		assign gdec_q          = {32{1'b0}};
	end
endgenerate
generate
	if (hvmode == 1) begin : gdecar_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(2147483647), .NEEDS_SRESET(1)) gdecar_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(gdecar_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[gdecar_offset:gdecar_offset + 32 - 1]),
        .scout(sov[gdecar_offset:gdecar_offset + 32 - 1]),
        .din(gdecar_d),
        .dout(gdecar_q)
     );
	end
	if (hvmode == 0) begin : gdecar_latch_tie
		assign gdecar_q        = {32{1'b0}};
	end
endgenerate
generate
	if (hvmode == 1) begin : gesr_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(17), .INIT(0), .NEEDS_SRESET(1)) gesr_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(gesr_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[gesr_offset:gesr_offset + 17 - 1]),
        .scout(sov[gesr_offset:gesr_offset + 17 - 1]),
        .din(gesr_d),
        .dout(gesr_q)
     );
	end
	if (hvmode == 0) begin : gesr_latch_tie
		assign gesr_q          = {17{1'b0}};
	end
endgenerate
generate
	if (hvmode == 1) begin : gpir_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) gpir_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(gpir_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[gpir_offset:gpir_offset + 32 - 1]),
        .scout(sov[gpir_offset:gpir_offset + 32 - 1]),
        .din(gpir_d),
        .dout(gpir_q)
     );
	end
	if (hvmode == 0) begin : gpir_latch_tie
		assign gpir_q          = {32{1'b0}};
	end
endgenerate
generate
	if (hvmode == 1) begin : gsrr0_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) gsrr0_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(gsrr0_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[gsrr0_offset:gsrr0_offset + `EFF_IFAR_ARCH - 1]),
        .scout(sov[gsrr0_offset:gsrr0_offset + `EFF_IFAR_ARCH - 1]),
        .din(gsrr0_d),
        .dout(gsrr0_q)
     );
	end
	if (hvmode == 0) begin : gsrr0_latch_tie
		assign gsrr0_q         = {`EFF_IFAR_ARCH{1'b0}};
	end
endgenerate
generate
	if (hvmode == 1) begin : gsrr1_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(14), .INIT(0), .NEEDS_SRESET(1)) gsrr1_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(gsrr1_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[gsrr1_offset:gsrr1_offset + 14 - 1]),
        .scout(sov[gsrr1_offset:gsrr1_offset + 14 - 1]),
        .din(gsrr1_d),
        .dout(gsrr1_q)
     );
	end
	if (hvmode == 0) begin : gsrr1_latch_tie
		assign gsrr1_q         = {14{1'b0}};
	end
endgenerate
generate
	if (hvmode == 1) begin : gtcr_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) gtcr_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(gtcr_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[gtcr_offset:gtcr_offset + 10 - 1]),
        .scout(sov[gtcr_offset:gtcr_offset + 10 - 1]),
        .din(gtcr_d),
        .dout(gtcr_q)
     );
	end
	if (hvmode == 0) begin : gtcr_latch_tie
		assign gtcr_q          = {10{1'b0}};
	end
endgenerate
generate
	if (hvmode == 1) begin : gtsr_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) gtsr_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(gtsr_act),
        .force_t(func_slp_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_slp_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[gtsr_offset:gtsr_offset + 4 - 1]),
        .scout(sov[gtsr_offset:gtsr_offset + 4 - 1]),
        .din(gtsr_d),
        .dout(gtsr_q)
     );
	end
	if (hvmode == 0) begin : gtsr_latch_tie
		assign gtsr_q          = {4{1'b0}};
	end
endgenerate
generate
	if (a2mode == 1) begin : mcsr_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(15), .INIT(0), .NEEDS_SRESET(1)) mcsr_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(mcsr_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[mcsr_offset:mcsr_offset + 15 - 1]),
        .scout(sov[mcsr_offset:mcsr_offset + 15 - 1]),
        .din(mcsr_d),
        .dout(mcsr_q)
     );
	end
	if (a2mode == 0) begin : mcsr_latch_tie
		assign mcsr_q          = {15{1'b0}};
	end
endgenerate
generate
	if (a2mode == 1) begin : mcsrr0_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) mcsrr0_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(mcsrr0_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[mcsrr0_offset:mcsrr0_offset + `EFF_IFAR_ARCH - 1]),
        .scout(sov[mcsrr0_offset:mcsrr0_offset + `EFF_IFAR_ARCH - 1]),
        .din(mcsrr0_d),
        .dout(mcsrr0_q)
     );
	end
	if (a2mode == 0) begin : mcsrr0_latch_tie
		assign mcsrr0_q        = {`EFF_IFAR_ARCH{1'b0}};
	end
endgenerate
generate
	if (a2mode == 1) begin : mcsrr1_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(14), .INIT(0), .NEEDS_SRESET(1)) mcsrr1_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(mcsrr1_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[mcsrr1_offset:mcsrr1_offset + 14 - 1]),
        .scout(sov[mcsrr1_offset:mcsrr1_offset + 14 - 1]),
        .din(mcsrr1_d),
        .dout(mcsrr1_q)
     );
	end
	if (a2mode == 0) begin : mcsrr1_latch_tie
		assign mcsrr1_q        = {14{1'b0}};
	end
endgenerate
     tri_ser_rlmreg_p #(.WIDTH(14), .INIT(0), .NEEDS_SRESET(1)) msr_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(msr_act),
        .force_t(ccfg_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(ccfg_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv_ccfg[msr_offset_ccfg:msr_offset_ccfg + 14 - 1]),
        .scout(sov_ccfg[msr_offset_ccfg:msr_offset_ccfg + 14 - 1]),
        .din(msr_d),
        .dout(msr_q)
     );
generate
	if (hvmode == 1) begin : msrp_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) msrp_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(msrp_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[msrp_offset:msrp_offset + 2 - 1]),
        .scout(sov[msrp_offset:msrp_offset + 2 - 1]),
        .din(msrp_d),
        .dout(msrp_q)
     );
	end
	if (hvmode == 0) begin : msrp_latch_tie
		assign msrp_q          = {2{1'b0}};
	end
endgenerate
     tri_ser_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH+2), .INIT(0), .NEEDS_SRESET(1)) siar_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(siar_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[siar_offset:siar_offset + `EFF_IFAR_ARCH+2 - 1]),
        .scout(sov[siar_offset:siar_offset + `EFF_IFAR_ARCH+2 - 1]),
        .din(siar_d),
        .dout(siar_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) srr0_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(srr0_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[srr0_offset:srr0_offset + `EFF_IFAR_ARCH - 1]),
        .scout(sov[srr0_offset:srr0_offset + `EFF_IFAR_ARCH - 1]),
        .din(srr0_d),
        .dout(srr0_q)
     );
     tri_ser_rlmreg_p #(.WIDTH(14), .INIT(0), .NEEDS_SRESET(1)) srr1_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(srr1_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[srr1_offset:srr1_offset + 14 - 1]),
        .scout(sov[srr1_offset:srr1_offset + 14 - 1]),
        .din(srr1_d),
        .dout(srr1_q)
     );
generate
	if (a2mode == 1) begin : tcr_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(12), .INIT(0), .NEEDS_SRESET(1)) tcr_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(tcr_act),
        .force_t(func_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[tcr_offset:tcr_offset + 12 - 1]),
        .scout(sov[tcr_offset:tcr_offset + 12 - 1]),
        .din(tcr_d),
        .dout(tcr_q)
     );
	end
	if (a2mode == 0) begin : tcr_latch_tie
		assign tcr_q           = {12{1'b0}};
	end
endgenerate
generate
	if (a2mode == 1) begin : tsr_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) tsr_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(tsr_act),
        .force_t(func_slp_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_slp_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[tsr_offset:tsr_offset + 5 - 1]),
        .scout(sov[tsr_offset:tsr_offset + 5 - 1]),
        .din(tsr_d),
        .dout(tsr_q)
     );
	end
	if (a2mode == 0) begin : tsr_latch_tie
		assign tsr_q           = {5{1'b0}};
	end
endgenerate
generate
	if (a2mode == 1) begin : udec_latch_gen
     tri_ser_rlmreg_p #(.WIDTH(32), .INIT(2147483647), .NEEDS_SRESET(1)) udec_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(udec_act),
        .force_t(func_slp_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(func_slp_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv[udec_offset:udec_offset + 32 - 1]),
        .scout(sov[udec_offset:udec_offset + 32 - 1]),
        .din(udec_d),
        .dout(udec_q)
     );
	end
	if (a2mode == 0) begin : udec_latch_tie
		assign udec_q          = {32{1'b0}};
	end
endgenerate
     tri_ser_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) xucr1_latch(
        .nclk(nclk),.vd(vdd),.gd(gnd),
        .act(xucr1_act),
        .force_t(ccfg_sl_force),
        .d_mode(d_mode_dc),.delay_lclkr(delay_lclkr_dc[DWR]),
        .mpw1_b(mpw1_dc_b[DWR]),.mpw2_b(mpw2_dc_b),
        .thold_b(ccfg_sl_thold_0_b),
        .sg(sg_0),
        .scin(siv_ccfg[xucr1_offset_ccfg:xucr1_offset_ccfg + 5 - 1]),
        .scout(sov_ccfg[xucr1_offset_ccfg:xucr1_offset_ccfg + 5 - 1]),
        .din(xucr1_d),
        .dout(xucr1_q)
     );




   // DVC Shadow SPRs
   generate
      if (a2mode == 1)
      begin : dvc1_latch_gen

         tri_ser_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) dvc1_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(dvc1_act),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc[DWR]),
            .mpw1_b(mpw1_dc_b[DWR]),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[dvc1_offset:dvc1_offset + `GPR_WIDTH - 1]),
            .scout(sov[dvc1_offset:dvc1_offset + `GPR_WIDTH - 1]),
            .din(dvc1_d),
            .dout(dvc1_q)
         );
      end
   endgenerate
   generate
      if (a2mode == 0)
      begin : dvc1_latch_tie
         assign dvc1_q = {64-`GPR_WIDTH-63+1{1'b0}};
      end
   endgenerate
   generate
      if (a2mode == 1)
      begin : dvc2_latch_gen

         tri_ser_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) dvc2_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(dvc2_act),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc[DWR]),
            .mpw1_b(mpw1_dc_b[DWR]),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[dvc2_offset:dvc2_offset + `GPR_WIDTH - 1]),
            .scout(sov[dvc2_offset:dvc2_offset + `GPR_WIDTH - 1]),
            .din(dvc2_d),
            .dout(dvc2_q)
         );
      end
   endgenerate
   generate
      if (a2mode == 0)
      begin : dvc2_latch_tie
         assign dvc2_q = {64-`GPR_WIDTH-63+1{1'b0}};
      end
   endgenerate

   // Latch Instances
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_xu_act_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_xu_act_offset]),
      .scout(sov[iu_xu_act_offset]),
      .din(iu_xu_act),
      .dout(iu_xu_act_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(1),.INIT(0), .NEEDS_SRESET(1)) exx_act_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_act_offset : exx_act_offset + 2-1]),
      .scout(sov[exx_act_offset : exx_act_offset + 2-1]),
      .din(exx_act_d),
      .dout(exx_act_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_is_mfmsr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_mfmsr_offset]),
      .scout(sov[ex2_is_mfmsr_offset]),
      .din(ex1_is_mfmsr),
      .dout(ex2_is_mfmsr_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_wrtee_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_wrtee_offset]),
      .scout(sov[ex2_wrtee_offset]),
      .din(ex1_is_wrtee),
      .dout(ex2_wrtee_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_wrteei_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_wrteei_offset]),
      .scout(sov[ex2_wrteei_offset]),
      .din(ex1_is_wrteei),
      .dout(ex2_wrteei_q)
   );
   tri_regk #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_dnh_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_dnh_offset]),
      .scout(sov[ex2_dnh_offset]),
      .din(ex1_is_dnh),
      .dout(ex2_dnh_q)
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
      .din(ex1_is_mtmsr),
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
   tri_regk #(.WIDTH(15), .OFFSET(6),.INIT(0), .NEEDS_SRESET(1)) ex2_instr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_nsl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_nsl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_instr_offset : ex2_instr_offset + 15-1]),
      .scout(sov[ex2_instr_offset : ex2_instr_offset + 15-1]),
      .din(ex2_instr_d),
      .dout(ex2_instr_q)
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
   tri_rlmreg_p #(.WIDTH(15), .OFFSET(6),.INIT(0), .NEEDS_SRESET(1)) ex3_instr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_instr_offset : ex3_instr_offset + 15-1]),
      .scout(sov[ex3_instr_offset : ex3_instr_offset + 15-1]),
      .din(ex2_instr_q),
      .dout(ex3_instr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_wrtee_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_wrtee_offset]),
      .scout(sov[ex3_wrtee_offset]),
      .din(ex2_wrtee_q),
      .dout(ex3_wrtee_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_wrteei_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_wrteei_offset]),
      .scout(sov[ex3_wrteei_offset]),
      .din(ex2_wrteei_q),
      .dout(ex3_wrteei_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_dnh_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_dnh_offset]),
      .scout(sov[ex3_dnh_offset]),
      .din(ex2_dnh_q),
      .dout(ex3_dnh_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_is_mtmsr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_is_mtmsr_offset]),
      .scout(sov[ex3_is_mtmsr_offset]),
      .din(ex2_is_mtmsr_q),
      .dout(ex3_is_mtmsr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_rfi_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_rfi_offset]),
      .scout(sov[iu_rfi_offset]),
      .din(iu_xu_rfi),
      .dout(iu_rfi_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_rfgi_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_rfgi_offset]),
      .scout(sov[iu_rfgi_offset]),
      .din(iu_xu_rfgi),
      .dout(iu_rfgi_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_rfci_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_rfci_offset]),
      .scout(sov[iu_rfci_offset]),
      .din(iu_xu_rfci),
      .dout(iu_rfci_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_rfmci_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_rfmci_offset]),
      .scout(sov[iu_rfmci_offset]),
      .din(iu_xu_rfmci),
      .dout(iu_rfmci_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_int_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(iu_int_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_int_offset]),
      .scout(sov[iu_int_offset]),
      .din(iu_xu_int),
      .dout(iu_int_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_gint_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(iu_int_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_gint_offset]),
      .scout(sov[iu_gint_offset]),
      .din(iu_xu_gint),
      .dout(iu_gint_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_cint_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(iu_int_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_cint_offset]),
      .scout(sov[iu_cint_offset]),
      .din(iu_xu_cint),
      .dout(iu_cint_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_mcint_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(iu_int_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_mcint_offset]),
      .scout(sov[iu_mcint_offset]),
      .din(iu_xu_mcint),
      .dout(iu_mcint_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) iu_dear_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(iu_xu_dear_update),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[iu_dear_offset : iu_dear_offset + `GPR_WIDTH-1]),
      .scout(sov[iu_dear_offset : iu_dear_offset + `GPR_WIDTH-1]),
      .din(iu_xu_dear),
      .dout(iu_dear_q)
   );
   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .OFFSET(62-`EFF_IFAR_ARCH),.INIT(0), .NEEDS_SRESET(1)) iu_nia_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(iu_nia_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[iu_nia_offset : iu_nia_offset + `EFF_IFAR_ARCH-1]),
      .scout(sov[iu_nia_offset : iu_nia_offset + `EFF_IFAR_ARCH-1]),
      .din(iu_xu_nia),
      .dout(iu_nia_q)
   );
   tri_rlmreg_p #(.WIDTH(17), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) iu_esr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(iu_xu_esr_update),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[iu_esr_offset : iu_esr_offset + 17-1]),
      .scout(sov[iu_esr_offset : iu_esr_offset + 17-1]),
      .din(iu_xu_esr),
      .dout(iu_esr_q)
   );
   tri_rlmreg_p #(.WIDTH(15), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) iu_mcsr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(iu_int_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[iu_mcsr_offset : iu_mcsr_offset + 15-1]),
      .scout(sov[iu_mcsr_offset : iu_mcsr_offset + 15-1]),
      .din(iu_xu_mcsr),
      .dout(iu_mcsr_q)
   );
   tri_rlmreg_p #(.WIDTH(19), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) iu_dbsr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(iu_xu_dbsr_update),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[iu_dbsr_offset : iu_dbsr_offset + 19-1]),
      .scout(sov[iu_dbsr_offset : iu_dbsr_offset + 19-1]),
      .din(iu_xu_dbsr),
      .dout(iu_dbsr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_dear_update_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(iu_int_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_dear_update_offset]),
      .scout(sov[iu_dear_update_offset]),
      .din(iu_xu_dear_update),
      .dout(iu_dear_update_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_dbsr_update_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(iu_int_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_dbsr_update_offset]),
      .scout(sov[iu_dbsr_update_offset]),
      .din(iu_xu_dbsr_update),
      .dout(iu_dbsr_update_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_esr_update_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(iu_int_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_esr_update_offset]),
      .scout(sov[iu_esr_update_offset]),
      .din(iu_xu_esr_update),
      .dout(iu_esr_update_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_force_gsrr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(iu_int_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_force_gsrr_offset]),
      .scout(sov[iu_force_gsrr_offset]),
      .din(iu_xu_force_gsrr),
      .dout(iu_force_gsrr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_dbsr_ude_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_dbsr_ude_offset]),
      .scout(sov[iu_dbsr_ude_offset]),
      .din(iu_xu_dbsr_ude),
      .dout(iu_dbsr_ude_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_dbsr_ide_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iu_dbsr_ide_offset]),
      .scout(sov[iu_dbsr_ide_offset]),
      .din(iu_xu_dbsr_ide),
      .dout(iu_dbsr_ide_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex3_spr_wd_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act_data[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_spr_wd_offset : ex3_spr_wd_offset + `GPR_WIDTH-1]),
      .scout(sov[ex3_spr_wd_offset : ex3_spr_wd_offset + `GPR_WIDTH-1]),
      .din(ex2_spr_wd),
      .dout(ex3_spr_wd_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH/8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_tid_rpwr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_tid_rpwr_offset : ex3_tid_rpwr_offset + `GPR_WIDTH/8-1]),
      .scout(sov[ex3_tid_rpwr_offset : ex3_tid_rpwr_offset + `GPR_WIDTH/8-1]),
      .din(ex3_tid_rpwr_d),
      .dout(ex3_tid_rpwr_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex3_tspr_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_act_data[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_tspr_rt_offset : ex3_tspr_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[ex3_tspr_rt_offset : ex3_tspr_rt_offset + `GPR_WIDTH-1]),
      .din(ex3_tspr_rt_d),
      .dout(ex3_tspr_rt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) fit_tb_tap_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[fit_tb_tap_offset]),
      .scout(sov[fit_tb_tap_offset]),
      .din(fit_tb_tap_d),
      .dout(fit_tb_tap_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) wdog_tb_tap_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[wdog_tb_tap_offset]),
      .scout(sov[wdog_tb_tap_offset]),
      .din(wdog_tb_tap_d),
      .dout(wdog_tb_tap_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) gfit_tb_tap_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[gfit_tb_tap_offset]),
      .scout(sov[gfit_tb_tap_offset]),
      .din(gfit_tb_tap_d),
      .dout(gfit_tb_tap_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) gwdog_tb_tap_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[gwdog_tb_tap_offset]),
      .scout(sov[gwdog_tb_tap_offset]),
      .din(gwdog_tb_tap_d),
      .dout(gwdog_tb_tap_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) hang_pulse_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[hang_pulse_offset : hang_pulse_offset + 4-1]),
      .scout(sov[hang_pulse_offset : hang_pulse_offset + 4-1]),
      .din(hang_pulse_d),
      .dout(hang_pulse_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lltap_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[lltap_offset]),
      .scout(sov[lltap_offset]),
      .din(lltap_d),
      .dout(lltap_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) llcnt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[llcnt_offset : llcnt_offset + 2-1]),
      .scout(sov[llcnt_offset : llcnt_offset + 2-1]),
      .din(llcnt_d),
      .dout(llcnt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) msrovride_pr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[msrovride_pr_offset]),
      .scout(sov[msrovride_pr_offset]),
      .din(pc_xu_msrovride_pr),
      .dout(msrovride_pr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) msrovride_gs_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[msrovride_gs_offset]),
      .scout(sov[msrovride_gs_offset]),
      .din(pc_xu_msrovride_gs),
      .dout(msrovride_gs_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) msrovride_de_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[msrovride_de_offset]),
      .scout(sov[msrovride_de_offset]),
      .din(pc_xu_msrovride_de),
      .dout(msrovride_de_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_ext_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_ext_interrupt_offset]),
      .scout(sov[an_ac_ext_interrupt_offset]),
      .din(an_ac_ext_interrupt),
      .dout(an_ac_ext_interrupt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_crit_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_crit_interrupt_offset]),
      .scout(sov[an_ac_crit_interrupt_offset]),
      .din(an_ac_crit_interrupt),
      .dout(an_ac_crit_interrupt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_perf_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_perf_interrupt_offset]),
      .scout(sov[an_ac_perf_interrupt_offset]),
      .din(an_ac_perf_interrupt),
      .dout(an_ac_perf_interrupt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_perf_interrupt2_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_perf_interrupt2_offset]),
      .scout(sov[an_ac_perf_interrupt2_offset]),
      .din(an_ac_perf_interrupt_q),
      .dout(an_ac_perf_interrupt2_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) mux_msr_gs_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[mux_msr_gs_offset : mux_msr_gs_offset + 3-1]),
      .scout(sov[mux_msr_gs_offset : mux_msr_gs_offset + 3-1]),
      .din(mux_msr_gs_d),
      .dout(mux_msr_gs_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mux_msr_pr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mux_msr_pr_offset]),
      .scout(sov[mux_msr_pr_offset]),
      .din(mux_msr_pr_d),
      .dout(mux_msr_pr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) err_llbust_attempt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[err_llbust_attempt_offset]),
      .scout(sov[err_llbust_attempt_offset]),
      .din(err_llbust_attempt_d),
      .dout(err_llbust_attempt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) err_llbust_failed_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[err_llbust_failed_offset]),
      .scout(sov[err_llbust_failed_offset]),
      .din(err_llbust_failed_d),
      .dout(err_llbust_failed_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) inj_llbust_attempt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[inj_llbust_attempt_offset]),
      .scout(sov[inj_llbust_attempt_offset]),
      .din(pc_xu_inj_llbust_attempt),
      .dout(inj_llbust_attempt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) inj_llbust_failed_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[inj_llbust_failed_offset]),
      .scout(sov[inj_llbust_failed_offset]),
      .din(pc_xu_inj_llbust_failed),
      .dout(inj_llbust_failed_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_external_mchk_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_external_mchk_offset]),
      .scout(sov[an_ac_external_mchk_offset]),
      .din(an_ac_external_mchk),
      .dout(an_ac_external_mchk_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mchk_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mchk_interrupt_offset]),
      .scout(sov[mchk_interrupt_offset]),
      .din(mchk_interrupt),
      .dout(mchk_interrupt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) crit_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[crit_interrupt_offset]),
      .scout(sov[crit_interrupt_offset]),
      .din(crit_interrupt),
      .dout(crit_interrupt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) wdog_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[wdog_interrupt_offset]),
      .scout(sov[wdog_interrupt_offset]),
      .din(wdog_interrupt),
      .dout(wdog_interrupt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dec_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[dec_interrupt_offset]),
      .scout(sov[dec_interrupt_offset]),
      .din(dec_interrupt),
      .dout(dec_interrupt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) udec_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[udec_interrupt_offset]),
      .scout(sov[udec_interrupt_offset]),
      .din(udec_interrupt),
      .dout(udec_interrupt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) perf_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[perf_interrupt_offset]),
      .scout(sov[perf_interrupt_offset]),
      .din(perf_interrupt),
      .dout(perf_interrupt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) fit_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[fit_interrupt_offset]),
      .scout(sov[fit_interrupt_offset]),
      .din(fit_interrupt),
      .dout(fit_interrupt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ext_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ext_interrupt_offset]),
      .scout(sov[ext_interrupt_offset]),
      .din(ext_interrupt),
      .dout(ext_interrupt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) gwdog_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[gwdog_interrupt_offset]),
      .scout(sov[gwdog_interrupt_offset]),
      .din(gwdog_interrupt),
      .dout(gwdog_interrupt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) gdec_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[gdec_interrupt_offset]),
      .scout(sov[gdec_interrupt_offset]),
      .din(gdec_interrupt),
      .dout(gdec_interrupt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) gfit_interrupt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[gfit_interrupt_offset]),
      .scout(sov[gfit_interrupt_offset]),
      .din(gfit_interrupt),
      .dout(gfit_interrupt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) single_instr_mode_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[single_instr_mode_offset]),
      .scout(sov[single_instr_mode_offset]),
      .din(single_instr_mode_d),
      .dout(single_instr_mode_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) single_instr_mode_2_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[single_instr_mode_2_offset]),
      .scout(sov[single_instr_mode_2_offset]),
      .din(single_instr_mode_q),
      .dout(single_instr_mode_2_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) machine_check_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[machine_check_offset]),
      .scout(sov[machine_check_offset]),
      .din(machine_check_d),
      .dout(machine_check_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) raise_iss_pri_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[raise_iss_pri_offset]),
      .scout(sov[raise_iss_pri_offset]),
      .din(raise_iss_pri_d),
      .dout(raise_iss_pri_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) raise_iss_pri_2_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[raise_iss_pri_2_offset]),
      .scout(sov[raise_iss_pri_2_offset]),
      .din(raise_iss_pri_q),
      .dout(raise_iss_pri_2_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_xu_inj_wdt_reset_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[pc_xu_inj_wdt_reset_offset]),
      .scout(sov[pc_xu_inj_wdt_reset_offset]),
      .din(pc_xu_inj_wdt_reset),
      .dout(pc_xu_inj_wdt_reset_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) err_wdt_reset_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[err_wdt_reset_offset]),
      .scout(sov[err_wdt_reset_offset]),
      .din(err_wdt_reset_d),
      .dout(err_wdt_reset_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ram_active_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ram_active_offset]),
      .scout(sov[ram_active_offset]),
      .din(cspr_tspr_ram_active),
      .dout(ram_active_q)
   );
   tri_rlmreg_p #(.WIDTH(10), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) timebase_taps_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[timebase_taps_offset : timebase_taps_offset + 10-1]),
      .scout(sov[timebase_taps_offset : timebase_taps_offset + 10-1]),
      .din(cspr_tspr_timebase_taps),
      .dout(timebase_taps_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) dbsr_mrr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(dbsr_mrr_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[dbsr_mrr_offset : dbsr_mrr_offset + 2-1]),
      .scout(sov[dbsr_mrr_offset : dbsr_mrr_offset + 2-1]),
      .din(dbsr_mrr_d),
      .dout(dbsr_mrr_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) tsr_wrs_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(tsr_wrs_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[tsr_wrs_offset : tsr_wrs_offset + 2-1]),
      .scout(sov[tsr_wrs_offset : tsr_wrs_offset + 2-1]),
      .din(tsr_wrs_d),
      .dout(tsr_wrs_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iac1_en_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iac1_en_offset]),
      .scout(sov[iac1_en_offset]),
      .din(iac1_en_d),
      .dout(iac1_en_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iac2_en_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iac2_en_offset]),
      .scout(sov[iac2_en_offset]),
      .din(iac2_en_d),
      .dout(iac2_en_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iac3_en_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iac3_en_offset]),
      .scout(sov[iac3_en_offset]),
      .din(iac3_en_d),
      .dout(iac3_en_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iac4_en_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[iac4_en_offset]),
      .scout(sov[iac4_en_offset]),
      .din(iac4_en_d),
      .dout(iac4_en_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_dnh_val_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_dnh_val_offset]),
      .scout(sov[ex3_dnh_val_offset]),
      .din(ex3_dnh),
      .dout(ex3_dnh_val_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_perf_interrupt_edge_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_perf_interrupt_edge_offset]),
      .scout(sov[an_ac_perf_interrupt_edge_offset]),
      .din(an_ac_perf_interrupt_edge),
      .dout(an_ac_perf_interrupt_edge_q)
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

   assign siv[0:scan_right - 1] = {sov[1:scan_right - 1], scan_in};
   assign scan_out = sov[0];

   generate
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



endmodule
