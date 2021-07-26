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

//********************************************************************
//*
//* TITLE: Instruction Cache
//*
//* NAME: iuq_ic.v
//*
//*********************************************************************

`include "tri_a2o.vh"

module iuq_ic(
   inout                           vcs,
   inout                           vdd,
   inout                           gnd,
    (* pin_data="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]         nclk,

   input                           tc_ac_ccflush_dc,
   input                           tc_ac_scan_dis_dc_b,
   input                           tc_ac_scan_diag_dc,

   input                           pc_iu_func_sl_thold_2,
   input                           pc_iu_func_slp_sl_thold_2,
   input                           pc_iu_func_nsl_thold_2,		// added for custom cam
   input                           pc_iu_cfg_slp_sl_thold_2,		// for boot config slats
   input                           pc_iu_regf_slp_sl_thold_2,
   input                           pc_iu_time_sl_thold_2,
   input                           pc_iu_abst_sl_thold_2,
   input                           pc_iu_abst_slp_sl_thold_2,
   input                           pc_iu_repr_sl_thold_2,
   input                           pc_iu_ary_nsl_thold_2,
   input                           pc_iu_ary_slp_nsl_thold_2,
   input                           pc_iu_func_slp_nsl_thold_2,
   input                           pc_iu_bolt_sl_thold_2,
   input                           pc_iu_sg_2,
   input                           pc_iu_fce_2,
   input                           clkoff_b,
   input                           act_dis,
   input                           d_mode,
   input                           delay_lclkr,
   input                           mpw1_b,
   input                           mpw2_b,
   input                           g8t_clkoff_b,
   input                           g8t_d_mode,
   input [0:4]                     g8t_delay_lclkr,
   input [0:4]                     g8t_mpw1_b,
   input                           g8t_mpw2_b,
   input                           g6t_clkoff_b,
   input                           g6t_act_dis,
   input                           g6t_d_mode,
   input [0:3]                     g6t_delay_lclkr,
   input [0:4]                     g6t_mpw1_b,
   input                           g6t_mpw2_b,
   input                           cam_clkoff_b,
   input                           cam_act_dis,
   input                           cam_d_mode,
   input [0:4]                     cam_delay_lclkr,
   input [0:4]                     cam_mpw1_b,
   input                           cam_mpw2_b,

    (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                           func_scan_in,
    (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                          func_scan_out,
    (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                           ac_ccfg_scan_in,
    (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                          ac_ccfg_scan_out,
    (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                           time_scan_in,
    (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                          time_scan_out,
    (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                           repr_scan_in,
    (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                          repr_scan_out,
    (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:2]                     abst_scan_in,
    (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:2]                    abst_scan_out,
    (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:4]                     regf_scan_in,
    (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:4]                    regf_scan_out,

   output                          iu_pc_err_icache_parity,
   output                          iu_pc_err_icachedir_parity,
   output                          iu_pc_err_icachedir_multihit,
   output                          iu_pc_err_ierat_multihit,
   output                          iu_pc_err_ierat_parity,

   input                           pc_iu_inj_icache_parity,
   input                           pc_iu_inj_icachedir_parity,
   input                           pc_iu_inj_icachedir_multihit,

   input                           pc_iu_abist_g8t_wenb,
   input                           pc_iu_abist_g8t1p_renb_0,
   input [0:3]                     pc_iu_abist_di_0,
   input                           pc_iu_abist_g8t_bw_1,
   input                           pc_iu_abist_g8t_bw_0,
   input [3:9]                     pc_iu_abist_waddr_0,
   input [1:9]                     pc_iu_abist_raddr_0,
   input                           pc_iu_abist_ena_dc,
   input                           pc_iu_abist_wl128_comp_ena,
   input                           pc_iu_abist_raw_dc_b,
   input [0:3]                     pc_iu_abist_g8t_dcomp,
   input [0:1]                     pc_iu_abist_g6t_bw,
   input [0:3]                     pc_iu_abist_di_g6t_2r,
   input                           pc_iu_abist_wl512_comp_ena,
   input [0:3]                     pc_iu_abist_dcomp_g6t_2r,
   input                           pc_iu_abist_g6t_r_wb,
   input                           an_ac_lbist_ary_wrt_thru_dc,
   input                           an_ac_lbist_en_dc,
   input                           an_ac_atpg_en_dc,
   input                           an_ac_grffence_en_dc,

   input                           pc_iu_bo_enable_3,		// bolt-on ABIST
   input                           pc_iu_bo_reset,
   input                           pc_iu_bo_unload,
   input                           pc_iu_bo_repair,
   input                           pc_iu_bo_shdata,
   input [0:3]                     pc_iu_bo_select,
   output [0:3]                    iu_pc_bo_fail,
   output [0:3]                    iu_pc_bo_diagout,

   // ICBI Interface to IU
   input [0:`THREADS-1]            lq_iu_icbi_val,
   input [64-`REAL_IFAR_WIDTH:57]  lq_iu_icbi_addr,
   output [0:`THREADS-1]           iu_lq_icbi_complete,
   input                           lq_iu_ici_val,

   // ERAT
   input                           pc_iu_init_reset,

   // XU IERAT interface
   input [0:`THREADS-1]            xu_iu_val,
   input                           xu_iu_is_eratre,
   input                           xu_iu_is_eratwe,
   input                           xu_iu_is_eratsx,
   input                           xu_iu_is_eratilx,
   input                           cp_is_isync,
   input                           cp_is_csync,
   input [0:1]                     xu_iu_ws,
   input [0:3]                     xu_iu_ra_entry,

   input [64-`GPR_WIDTH:51]        xu_iu_rb,
   input [64-`GPR_WIDTH:63]        xu_iu_rs_data,
   output                          iu_xu_ord_read_done,
   output                          iu_xu_ord_write_done,
   output                          iu_xu_ord_par_err,
   output                          iu_xu_ord_n_flush_req,
   input [0:`THREADS-1]            xu_iu_msr_hv,
   input [0:`THREADS-1]            xu_iu_msr_pr,
   input [0:`THREADS-1]            xu_iu_msr_is,
   input                           xu_iu_hid_mmu_mode,
   input                           xu_iu_spr_ccr2_ifrat,
   input [0:8]                     xu_iu_spr_ccr2_ifratsc,	// 0:4: wimge, 5:8: u0:3
   input                           xu_iu_xucr4_mmu_mchk,
   output [64-`GPR_WIDTH:63]       iu_xu_ex5_data,

   output                          iu_mm_ierat_req,
   output                          iu_mm_ierat_req_nonspec,
   output [0:51]                   iu_mm_ierat_epn,
   output [0:`THREADS-1]           iu_mm_ierat_thdid,
   output [0:3]                    iu_mm_ierat_state,
   output [0:13]                   iu_mm_ierat_tid,
   output [0:`THREADS-1]           iu_mm_ierat_flush,
   output [0:`THREADS-1]           iu_mm_perf_itlb,

   input [0:4]                     mm_iu_ierat_rel_val,
   input [0:131]                   mm_iu_ierat_rel_data,

   input [0:13]                    mm_iu_t0_ierat_pid,
   input [0:19]                    mm_iu_t0_ierat_mmucr0,
 `ifndef THREADS1
   input [0:13]                    mm_iu_t1_ierat_pid,
   input [0:19]                    mm_iu_t1_ierat_mmucr0,
 `endif
   output [0:17]                   iu_mm_ierat_mmucr0,
   output [0:`THREADS-1]           iu_mm_ierat_mmucr0_we,
   input [0:8]                     mm_iu_ierat_mmucr1,
   output [0:3]                    iu_mm_ierat_mmucr1,
   output [0:`THREADS-1]           iu_mm_ierat_mmucr1_we,

   input                           mm_iu_ierat_snoop_coming,
   input                           mm_iu_ierat_snoop_val,
   input [0:25]                    mm_iu_ierat_snoop_attr,
   input [62-`EFF_IFAR_ARCH:51]    mm_iu_ierat_snoop_vpn,
   output                          iu_mm_ierat_snoop_ack,

   // MMU Connections
   input [0:`THREADS-1]            mm_iu_hold_req,
   input [0:`THREADS-1]            mm_iu_hold_done,
   input [0:`THREADS-1]            mm_iu_bus_snoop_hold_req,
   input [0:`THREADS-1]            mm_iu_bus_snoop_hold_done,

   // SELECT, DIR, & MISS
   input [0:`THREADS-1]            pc_iu_ram_active,
   input [0:`THREADS-1]            pc_iu_pm_fetch_halt,
   input [0:`THREADS-1]            xu_iu_run_thread,
   input [0:`THREADS-1]            cp_ic_stop,
   input [0:`THREADS-1]            xu_iu_msr_cm,

   input [0:`THREADS-1]            iu_flush,
   input [0:`THREADS-1]            br_iu_redirect,
   input [62-`EFF_IFAR_ARCH:61]    br_iu_bta,
   input [0:`THREADS-1]            cp_flush,
   input [0:`THREADS-1]            cp_flush_into_uc,
   input [62-`EFF_IFAR_ARCH:61]    cp_iu0_t0_flush_ifar,
 `ifndef THREADS1
   input [62-`EFF_IFAR_ARCH:61]    cp_iu0_t1_flush_ifar,
 `endif
   input [0:`THREADS-1]            cp_iu0_flush_2ucode,
   input [0:`THREADS-1]            cp_iu0_flush_2ucode_type,
   input [0:`THREADS-1]            cp_iu0_flush_nonspec,

   output [0:`THREADS-1]           ic_cp_nonspec_hit,

   input                           an_ac_back_inv,
   input [64-`REAL_IFAR_WIDTH:57]  an_ac_back_inv_addr,
   input                           an_ac_back_inv_target,	// connect to bit(0)

   input [0:3]                     spr_ic_bp_config,		// (0): bc, (1): bclr, (2): bcctr, (3): sw

   input                           spr_ic_cls,                  // (0): 64B cacheline, (1): 128B cacheline
   input                           spr_ic_prefetch_dis,
   input                           spr_ic_ierat_byp_dis,

   input                           spr_ic_idir_read,
   input [0:1]                     spr_ic_idir_way,
   input [51:57]                   spr_ic_idir_row,
   output                          ic_spr_idir_done,
   output [0:2]                    ic_spr_idir_lru,
   output [0:3]                    ic_spr_idir_parity,
   output                          ic_spr_idir_endian,
   output                          ic_spr_idir_valid,
   output [0:28]                   ic_spr_idir_tag,

   output [0:`THREADS-1]           iu_lq_request,
   output [0:1]                    iu_lq_ctag,
   output [64-`REAL_IFAR_WIDTH:59] iu_lq_ra,
   output [0:4]                    iu_lq_wimge,
   output [0:3]                    iu_lq_userdef,


   input [0:`THREADS-1]            cp_async_block,
   output                          iu_mm_lmq_empty,
   output [0:`THREADS-1]           iu_xu_icache_quiesce,
   output [0:`THREADS-1]           iu_pc_icache_quiesce,

   input                           an_ac_reld_data_vld,
   input [0:4]                     an_ac_reld_core_tag,
   input [58:59]                   an_ac_reld_qw,
   input [0:127]                   an_ac_reld_data,
   input                           an_ac_reld_ecc_err,
   input                           an_ac_reld_ecc_err_ue,

   //iu5 hold/redirect
   input [0:`THREADS-1]            bp_ic_iu2_redirect,
   input [0:`THREADS-1]            bp_ic_iu3_redirect,
   input [0:`THREADS-1]            bp_ic_iu4_redirect,
   input [62-`EFF_IFAR_WIDTH:61]   bp_ic_t0_redirect_ifar,
 `ifndef THREADS1
   input [62-`EFF_IFAR_WIDTH:61]   bp_ic_t1_redirect_ifar,
 `endif

   // iu1
   output [0:`THREADS-1]           ic_bp_iu0_val,
   output [50:59]                  ic_bp_iu0_ifar,

   // iu3
   output [0:3]                    ic_bp_iu2_t0_val,
 `ifndef THREADS1
   output [0:3]                    ic_bp_iu2_t1_val,
 `endif
   output [62-`EFF_IFAR_WIDTH:61]  ic_bp_iu2_ifar,
   output                          ic_bp_iu2_2ucode,
   output                          ic_bp_iu2_2ucode_type,
   output [0:2]                    ic_bp_iu2_error,
   output [0:`THREADS-1]           ic_bp_iu2_flush,
   output [0:`THREADS-1]           ic_bp_iu3_flush,

   // iu3 instruction(0:31) + predecode(32:35)
   output [0:35]                   ic_bp_iu2_0_instr,
   output [0:35]                   ic_bp_iu2_1_instr,
   output [0:35]                   ic_bp_iu2_2_instr,
   output [0:35]                   ic_bp_iu2_3_instr,

   output                          ic_bp_iu3_ecc_err,

   //Instruction Buffer
   input [0:`IBUFF_DEPTH/4-1]      ib_ic_t0_need_fetch,
 `ifndef THREADS1
   input [0:`IBUFF_DEPTH/4-1]      ib_ic_t1_need_fetch,
 `endif

   // ucode
   input [0:`THREADS-1]            uc_iu4_flush,
   input [62-`EFF_IFAR_WIDTH:61]   uc_iu4_t0_flush_ifar,
 `ifndef THREADS1
   input [62-`EFF_IFAR_WIDTH:61]   uc_iu4_t1_flush_ifar,
 `endif
   input [0:`THREADS-1]            uc_ic_hold,

   input                           pc_iu_event_bus_enable,
   input [0:2]			   pc_iu_event_count_mode,


   input [0:24*`THREADS-1]         spr_perf_event_mux_ctrls,
   input [0:20]                    slice_ic_t0_perf_events,
 `ifndef THREADS1
   input [0:20]                    slice_ic_t1_perf_events,
 `endif
   input [0:4*`THREADS-1]          event_bus_in,
   output [0:4*`THREADS-1]         event_bus_out
);

   localparam                      perf_bus_offset = 5;
   localparam                      scan_right = perf_bus_offset + 4*`THREADS - 1;

   wire                            iu_ierat_iu0_val;
   wire [0:`THREADS-1]             iu_ierat_iu0_thdid;
   wire [0:51]                     iu_ierat_iu0_ifar;
   wire                            iu_ierat_iu0_nonspec;
   wire                            iu_ierat_iu0_prefetch;
   wire [0:`THREADS-1]             iu_ierat_flush;
   wire                            iu_ierat_iu1_back_inv;
   wire                            iu_ierat_ium1_back_inv;
   wire [22:51]                    ierat_iu_iu2_rpn;
   wire [0:4]                      ierat_iu_iu2_wimge;
   wire [0:3]                      ierat_iu_iu2_u;
   wire [0:2]                      ierat_iu_iu2_error;
   wire                            ierat_iu_iu2_miss;
   wire                            ierat_iu_iu2_multihit;
   wire                            ierat_iu_cam_change;
   wire                            ierat_iu_iu2_isi;
   wire [0:`THREADS-1]             ierat_iu_hold_req;
   wire [0:`THREADS-1]             ierat_iu_iu2_flush_req;

   wire                            ics_icd_dir_rd_act;
   wire [0:1]                      ics_icd_data_rd_act;
   wire                            ics_icd_iu0_valid;
   wire [0:`THREADS-1]             ics_icd_iu0_tid;
   wire [62-`EFF_IFAR_ARCH:61]     ics_icd_iu0_ifar;
   wire                            ics_icd_iu0_index51;
   wire                            ics_icd_iu0_inval;
   wire                            ics_icd_iu0_2ucode;
   wire                            ics_icd_iu0_2ucode_type;
   wire                            ics_icd_iu0_prefetch;
   wire                            ics_icd_iu0_read_erat;
   wire                            ics_icd_iu0_spr_idir_read;
   wire [0:`THREADS-1]             ics_icd_iu1_flush;
   wire [0:`THREADS-1]             ics_icd_iu2_flush;
   wire                            icd_ics_iu1_valid;
   wire [0:`THREADS-1]             icd_ics_iu1_tid;
   wire [62-`EFF_IFAR_WIDTH:61]    icd_ics_iu1_ifar;
   wire                            icd_ics_iu1_2ucode;
   wire                            icd_ics_iu1_2ucode_type;
   wire [0:`THREADS-1]             icd_ics_iu1_read_erat;
   wire [0:`THREADS-1]             icd_ics_iu3_miss_flush;
   wire [0:`THREADS-1]             icd_ics_iu2_wrong_ra_flush;
   wire [0:`THREADS-1]             icd_ics_iu2_cam_etc_flush;
   wire [62-`EFF_IFAR_WIDTH:61]    icd_ics_iu2_ifar_eff;
   wire                            icd_ics_iu2_2ucode;
   wire                            icd_ics_iu2_2ucode_type;
   wire                            icd_ics_iu2_valid;
   wire [0:`THREADS-1]             icd_ics_iu2_read_erat_error;
   wire [0:`THREADS-1]             icd_ics_iu3_parity_flush;
   wire [62-`EFF_IFAR_WIDTH:61]    icd_ics_iu3_ifar;
   wire                            icd_ics_iu3_2ucode;
   wire                            icd_ics_iu3_2ucode_type;
   wire [0:`THREADS-1]             icm_ics_iu0_preload_val;
   wire [50:59]                    icm_ics_iu0_preload_ifar;
   wire [0:`THREADS-1]             icm_ics_prefetch_req;
   wire [0:`THREADS-1]             icm_ics_prefetch_sm_idle;
   wire [0:`THREADS-1]             icm_ics_hold_thread;
   wire                            icm_ics_hold_iu0;
   wire                            icm_ics_iu3_miss_match;
   wire [0:`THREADS-1]             icm_ics_iu3_ecc_fp_cancel;

   wire [46:52]                    ics_icm_iu0_t0_ifar;
 `ifndef THREADS1
   wire [46:52]                    ics_icm_iu0_t1_ifar;
 `endif
   wire                            ics_icm_iu0_inval;
   wire [51:57]                    ics_icm_iu0_inval_addr;
   wire [0:`THREADS-1]             ics_icm_iu2_flush;

   wire [51:57]                    icm_icd_lru_addr;
   wire                            icm_icd_dir_inval;
   wire                            icm_icd_dir_val;
   wire                            icm_icd_data_write;
   wire [51:59]                    icm_icd_reload_addr;
   wire [0:143]                    icm_icd_reload_data;
   wire [0:3]                      icm_icd_reload_way;
   wire [0:`THREADS-1]             icm_icd_load;
   wire [62-`EFF_IFAR_WIDTH:61]    icm_icd_load_addr;
   wire                            icm_icd_load_2ucode;
   wire                            icm_icd_load_2ucode_type;
   wire                            icm_icd_dir_write;
   wire [64-`REAL_IFAR_WIDTH:57]   icm_icd_dir_write_addr;
   wire                            icm_icd_dir_write_endian;
   wire [0:3]                      icm_icd_dir_write_way;
   wire                            icm_icd_lru_write;
   wire [51:57]                    icm_icd_lru_write_addr;
   wire [0:3]                      icm_icd_lru_write_way;
   wire                            icm_icd_ecc_inval;
   wire [51:57]                    icm_icd_ecc_addr;
   wire [0:3]                      icm_icd_ecc_way;
   wire                            icm_icd_iu3_ecc_fp_cancel;
   wire                            icm_icd_any_reld_r2;
   wire                            icd_icm_miss;
   wire                            icd_icm_prefetch;
   wire [0:`THREADS-1]             icd_icm_tid;
   wire [64-`REAL_IFAR_WIDTH:61]   icd_icm_addr_real;
   wire [62-`EFF_IFAR_WIDTH:51]    icd_icm_addr_eff;
   wire [0:4]                      icd_icm_wimge;
   wire [0:3]                      icd_icm_userdef;
   wire                            icd_icm_2ucode;
   wire                            icd_icm_2ucode_type;
   wire                            icd_icm_iu2_inval;
   wire                            icd_icm_any_iu2_valid;
   wire [0:2]                      icd_icm_row_lru;
   wire [0:3]                      icd_icm_row_val;

   wire [0:87]                     ierat_iu_debug_group0;
   wire [0:87]                     ierat_iu_debug_group1;
   wire [0:87]                     ierat_iu_debug_group2;
   wire [0:87]                     ierat_iu_debug_group3;

   wire [0:`THREADS-1]             br_iu_flush;

   wire [1:63]                     unit_t0_events_in;
   wire				   unit_t0_events_en;

 `ifndef THREADS1
   wire [1:63]                     unit_t1_events_in;
   wire				   unit_t1_events_en;
 `endif

   wire                            pc_iu_func_sl_thold_1;
   wire                            pc_iu_func_sl_thold_0;
   wire                            pc_iu_func_sl_thold_0_b;
   wire                            pc_iu_func_slp_sl_thold_1;
   wire                            pc_iu_func_slp_sl_thold_0;
   wire                            pc_iu_func_slp_sl_thold_0_b;
   wire                            pc_iu_time_sl_thold_1;
   wire                            pc_iu_time_sl_thold_0;
   wire                            pc_iu_abst_sl_thold_1;
   wire                            pc_iu_abst_sl_thold_0;
   wire                            pc_iu_abst_sl_thold_0_b;
   wire                            pc_iu_abst_slp_sl_thold_1;
   wire                            pc_iu_abst_slp_sl_thold_0;
   wire                            pc_iu_repr_sl_thold_1;
   wire                            pc_iu_repr_sl_thold_0;
   wire                            pc_iu_ary_nsl_thold_1;
   wire                            pc_iu_ary_nsl_thold_0;
   wire                            pc_iu_ary_slp_nsl_thold_1;
   wire                            pc_iu_ary_slp_nsl_thold_0;
   wire                            pc_iu_regf_slp_sl_thold_1;
   wire                            pc_iu_regf_slp_sl_thold_0;
   wire                            pc_iu_bolt_sl_thold_1;
   wire                            pc_iu_bolt_sl_thold_0;
   wire                            pc_iu_sg_1;
   wire                            pc_iu_sg_0;
   wire                            force_t;
   wire                            funcslp_force;
   wire                            abst_force;
   wire                            pc_iu_bo_enable_2;

   wire [0:scan_right]             siv;
   wire [0:scan_right]             sov;
   wire [0:1]                      tsiv;		// time scan path
   wire [0:1]                      tsov;		// time scan path
   wire                            func_scan_in_cam;
   wire                            func_scan_out_cam;

   wire [0:1]                      lcb_mpw1_dc_b;
   wire [0:1]                      lcb_delay_lclkr_dc;

   wire [0:11]                     ic_perf_t0_event;
 `ifndef THREADS1
   wire [0:11]                     ic_perf_t1_event;
 `endif
   wire [0:1]                      ic_perf_event;
   wire [0:4*`THREADS-1]           event_bus_out_d;
   wire [0:4*`THREADS-1]           event_bus_out_l2;

   assign br_iu_flush = br_iu_redirect;

   // ??? Temp: Need to connect
   assign lcb_mpw1_dc_b = {2{mpw1_b}};
   assign lcb_delay_lclkr_dc = {2{delay_lclkr}};

   iuq_ic_ierat  iuq_ic_ierat0(
      // POWER PINS
      .gnd(gnd),
      .vdd(vdd),
      .vcs(vdd),

      // CLOCK and CLOCKCONTROL ports
      .nclk(nclk),
      .pc_iu_init_reset(pc_iu_init_reset),
      .tc_ccflush_dc(tc_ac_ccflush_dc),
      .tc_scan_dis_dc_b(tc_ac_scan_dis_dc_b),
      .tc_scan_diag_dc(tc_ac_scan_diag_dc),
      .tc_lbist_en_dc(an_ac_lbist_en_dc),
      .an_ac_atpg_en_dc(an_ac_atpg_en_dc),
      .an_ac_grffence_en_dc(an_ac_grffence_en_dc),
      .lcb_d_mode_dc(d_mode),
      .lcb_clkoff_dc_b(clkoff_b),
      .lcb_act_dis_dc(act_dis),
      .lcb_mpw1_dc_b(lcb_mpw1_dc_b),
      .lcb_mpw2_dc_b(mpw2_b),
      .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc),
      .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
      .pc_iu_func_slp_sl_thold_2(pc_iu_func_slp_sl_thold_2),
      .pc_iu_func_slp_nsl_thold_2(pc_iu_func_slp_nsl_thold_2),
      .pc_iu_cfg_slp_sl_thold_2(pc_iu_func_sl_thold_2),
      .pc_iu_regf_slp_sl_thold_2(pc_iu_regf_slp_sl_thold_2),
      .pc_iu_time_sl_thold_2(pc_iu_time_sl_thold_2),
      .pc_iu_sg_2(pc_iu_sg_2),
      .pc_iu_fce_2(pc_iu_sg_2),
      .cam_clkoff_b(cam_clkoff_b),
      .cam_act_dis(cam_act_dis),
      .cam_d_mode(cam_d_mode),
      .cam_delay_lclkr(cam_delay_lclkr),
      .cam_mpw1_b(cam_mpw1_b),
      .cam_mpw2_b(cam_mpw2_b),
      .ac_func_scan_in(siv[0:1]),
      .ac_func_scan_out(sov[0:1]),
      .ac_ccfg_scan_in(ac_ccfg_scan_in),
      .ac_ccfg_scan_out(ac_ccfg_scan_out),
      .func_scan_in_cam(func_scan_in_cam),
      .func_scan_out_cam(func_scan_out_cam),
      .time_scan_in(tsiv[0]),
      .time_scan_out(tsov[0]),
      .regf_scan_in(regf_scan_in),
      .regf_scan_out(regf_scan_out),

      // Functional ports
      // act control
      .spr_ic_clockgate_dis(1'b0),
      // ttypes
      .iu_ierat_iu0_val(iu_ierat_iu0_val),
      .iu_ierat_iu0_thdid(iu_ierat_iu0_thdid),
      .iu_ierat_iu0_ifar(iu_ierat_iu0_ifar),
      .iu_ierat_iu0_nonspec(iu_ierat_iu0_nonspec),
      .iu_ierat_iu0_prefetch(iu_ierat_iu0_prefetch),

      .iu_ierat_iu0_flush(iu_ierat_flush),
      .iu_ierat_iu1_flush(iu_ierat_flush),

      // ordered instructions
      .xu_iu_val(xu_iu_val),
      .xu_iu_is_eratre(xu_iu_is_eratre),
      .xu_iu_is_eratwe(xu_iu_is_eratwe),
      .xu_iu_is_eratsx(xu_iu_is_eratsx),
      .xu_iu_is_eratilx(xu_iu_is_eratilx),
      .xu_iu_ws(xu_iu_ws),
      .xu_iu_ra_entry(xu_iu_ra_entry),
      .xu_iu_rs_data(xu_iu_rs_data),
      .xu_iu_rb(xu_iu_rb),
      .iu_xu_ex4_data(iu_xu_ex5_data),
      .iu_xu_ord_read_done(iu_xu_ord_read_done),
      .iu_xu_ord_write_done(iu_xu_ord_write_done),
      .iu_xu_ord_par_err(iu_xu_ord_par_err),

      // context synchronizing event
      .cp_ic_is_isync(cp_is_isync),
      .cp_ic_is_csync(cp_is_csync),

      // reload from mmu
      .mm_iu_ierat_rel_val(mm_iu_ierat_rel_val),
      .mm_iu_ierat_rel_data(mm_iu_ierat_rel_data),

      .ierat_iu_hold_req(ierat_iu_hold_req),

      // I$ snoop
      .iu_ierat_iu1_back_inv(iu_ierat_iu1_back_inv),
      .iu_ierat_ium1_back_inv(iu_ierat_ium1_back_inv),

      // tlbivax or tlbilx snoop
      .mm_iu_ierat_snoop_coming(mm_iu_ierat_snoop_coming),
      .mm_iu_ierat_snoop_val(mm_iu_ierat_snoop_val),
      .mm_iu_ierat_snoop_attr(mm_iu_ierat_snoop_attr),
      .mm_iu_ierat_snoop_vpn(mm_iu_ierat_snoop_vpn),
      .iu_mm_ierat_snoop_ack(iu_mm_ierat_snoop_ack),

      // pipeline controls
      .xu_iu_flush(iu_flush),
      .br_iu_flush(br_iu_flush),

      // all tied to cp_flush
      .xu_rf1_flush(cp_flush),
      .xu_ex1_flush(cp_flush),
      .xu_ex2_flush(cp_flush),
      .xu_ex3_flush(cp_flush),
      .xu_ex4_flush(cp_flush),
      .xu_ex5_flush(cp_flush),

      // cam _np2 ports
      .ierat_iu_iu2_rpn(ierat_iu_iu2_rpn),
      .ierat_iu_iu2_wimge(ierat_iu_iu2_wimge),
      .ierat_iu_iu2_u(ierat_iu_iu2_u),

      .ierat_iu_iu2_miss(ierat_iu_iu2_miss),
      .ierat_iu_iu2_isi(ierat_iu_iu2_isi),
      .ierat_iu_iu2_error(ierat_iu_iu2_error),
      .ierat_iu_iu2_multihit(ierat_iu_iu2_multihit),

      .ierat_iu_cam_change(ierat_iu_cam_change),

      .iu_pc_err_ierat_multihit(iu_pc_err_ierat_multihit),
      .iu_pc_err_ierat_parity(iu_pc_err_ierat_parity),

      // noop_touch
      // fir_par,  fir_multihit

      // erat request to mmu
      .iu_mm_ierat_req(iu_mm_ierat_req),
      .iu_mm_ierat_req_nonspec(iu_mm_ierat_req_nonspec),
      .iu_mm_ierat_thdid(iu_mm_ierat_thdid),
      .iu_mm_ierat_state(iu_mm_ierat_state),
      .iu_mm_ierat_tid(iu_mm_ierat_tid),
      .iu_mm_ierat_flush(iu_mm_ierat_flush),
      .iu_mm_perf_itlb(iu_mm_perf_itlb),

      // write interface to mmucr0,1
      .iu_mm_ierat_mmucr0(iu_mm_ierat_mmucr0),
      .iu_mm_ierat_mmucr0_we(iu_mm_ierat_mmucr0_we),
      .iu_mm_ierat_mmucr1(iu_mm_ierat_mmucr1),
      .iu_mm_ierat_mmucr1_we(iu_mm_ierat_mmucr1_we),

      // spr's
      // clkg_ctl
      .xu_iu_msr_hv(xu_iu_msr_hv),
      .xu_iu_msr_pr(xu_iu_msr_pr),
      .xu_iu_msr_is(xu_iu_msr_is),
      .xu_iu_msr_cm(xu_iu_msr_cm),
      .xu_iu_hid_mmu_mode(xu_iu_hid_mmu_mode),
      .xu_iu_spr_ccr2_ifrat(xu_iu_spr_ccr2_ifrat),
      .xu_iu_spr_ccr2_ifratsc(xu_iu_spr_ccr2_ifratsc),
      .xu_iu_xucr4_mmu_mchk(xu_iu_xucr4_mmu_mchk),

      .ierat_iu_iu2_flush_req(ierat_iu_iu2_flush_req),

      .iu_xu_ord_n_flush_req(iu_xu_ord_n_flush_req),

      .mm_iu_t0_ierat_pid(mm_iu_t0_ierat_pid),
      .mm_iu_t0_ierat_mmucr0(mm_iu_t0_ierat_mmucr0),
    `ifndef THREADS1
      .mm_iu_t1_ierat_pid(mm_iu_t1_ierat_pid),
      .mm_iu_t1_ierat_mmucr0(mm_iu_t1_ierat_mmucr0),
    `endif
      .mm_iu_ierat_mmucr1(mm_iu_ierat_mmucr1),

      // debug
      .pc_iu_trace_bus_enable(1'b0),
      .ierat_iu_debug_group0(ierat_iu_debug_group0),
      .ierat_iu_debug_group1(ierat_iu_debug_group1),
      .ierat_iu_debug_group2(ierat_iu_debug_group2),
      .ierat_iu_debug_group3(ierat_iu_debug_group3)
   );


   iuq_ic_select  iuq_ic_select0(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .pc_iu_func_sl_thold_0_b(pc_iu_func_sl_thold_0_b),
      .pc_iu_func_slp_sl_thold_0_b(pc_iu_func_slp_sl_thold_0_b),
      .pc_iu_sg_0(pc_iu_sg_0),
      .force_t(force_t),
      .funcslp_force(funcslp_force),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .func_scan_in(siv[2]),
      .func_scan_out(sov[2]),
      .pc_iu_ram_active(pc_iu_ram_active),
      .pc_iu_pm_fetch_halt(pc_iu_pm_fetch_halt),
      .xu_iu_run_thread(xu_iu_run_thread),
      .cp_ic_stop(cp_ic_stop),
      .xu_iu_msr_cm(xu_iu_msr_cm),
      .cp_flush(iu_flush),
      .cp_flush_into_uc(cp_flush_into_uc),
      .br_iu_redirect(br_iu_redirect),
      .br_iu_bta(br_iu_bta),
      .cp_iu0_t0_flush_ifar(cp_iu0_t0_flush_ifar),
    `ifndef THREADS1
      .cp_iu0_t1_flush_ifar(cp_iu0_t1_flush_ifar),
    `endif
      .cp_iu0_flush_2ucode(cp_iu0_flush_2ucode),
      .cp_iu0_flush_2ucode_type(cp_iu0_flush_2ucode_type),
      .cp_iu0_flush_nonspec(cp_iu0_flush_nonspec),
      .ic_cp_nonspec_hit(ic_cp_nonspec_hit),
      .an_ac_back_inv(an_ac_back_inv),
      .an_ac_back_inv_addr(an_ac_back_inv_addr),
      .an_ac_back_inv_target(an_ac_back_inv_target),
      .spr_ic_prefetch_dis(spr_ic_prefetch_dis),
      .spr_ic_ierat_byp_dis(spr_ic_ierat_byp_dis),
      .spr_ic_idir_read(spr_ic_idir_read),
      .spr_ic_idir_row(spr_ic_idir_row),
      .ic_perf_t0_event(ic_perf_t0_event[3:8]),
    `ifndef THREADS1
      .ic_perf_t1_event(ic_perf_t1_event[3:8]),
    `endif
      .iu_ierat_iu0_val(iu_ierat_iu0_val),
      .iu_ierat_iu0_thdid(iu_ierat_iu0_thdid),
      .iu_ierat_iu0_ifar(iu_ierat_iu0_ifar),
      .iu_ierat_iu0_nonspec(iu_ierat_iu0_nonspec),
      .iu_ierat_iu0_prefetch(iu_ierat_iu0_prefetch),
      .iu_ierat_flush(iu_ierat_flush),
      .iu_ierat_ium1_back_inv(iu_ierat_ium1_back_inv),
      .ierat_iu_hold_req(ierat_iu_hold_req),
      .ierat_iu_iu2_flush_req(ierat_iu_iu2_flush_req),
      .ierat_iu_iu2_miss(ierat_iu_iu2_miss),
      .ierat_iu_cam_change(ierat_iu_cam_change),
      .mm_iu_hold_req(mm_iu_hold_req),
      .mm_iu_hold_done(mm_iu_hold_done),
      .mm_iu_bus_snoop_hold_req(mm_iu_bus_snoop_hold_req),
      .mm_iu_bus_snoop_hold_done(mm_iu_bus_snoop_hold_done),
      .lq_iu_icbi_val(lq_iu_icbi_val),
      .lq_iu_icbi_addr(lq_iu_icbi_addr),
      .iu_lq_icbi_complete(iu_lq_icbi_complete),
      .icm_ics_iu0_preload_val(icm_ics_iu0_preload_val),
      .icm_ics_iu0_preload_ifar(icm_ics_iu0_preload_ifar),
      .icm_ics_prefetch_req(icm_ics_prefetch_req),
      .icm_ics_prefetch_sm_idle(icm_ics_prefetch_sm_idle),
      .icm_ics_hold_thread(icm_ics_hold_thread),
      .icm_ics_hold_iu0(icm_ics_hold_iu0),
      .icm_ics_iu3_miss_match(icm_ics_iu3_miss_match),
      .icm_ics_iu3_ecc_fp_cancel(icm_ics_iu3_ecc_fp_cancel),
      .ics_icm_iu0_t0_ifar(ics_icm_iu0_t0_ifar),
    `ifndef THREADS1
      .ics_icm_iu0_t1_ifar(ics_icm_iu0_t1_ifar),
    `endif
      .ics_icm_iu0_inval(ics_icm_iu0_inval),
      .ics_icm_iu0_inval_addr(ics_icm_iu0_inval_addr),
      .ics_icm_iu2_flush(ics_icm_iu2_flush),
      .ics_icd_dir_rd_act(ics_icd_dir_rd_act),
      .ics_icd_data_rd_act(ics_icd_data_rd_act),
      .ics_icd_iu0_valid(ics_icd_iu0_valid),
      .ics_icd_iu0_tid(ics_icd_iu0_tid),
      .ics_icd_iu0_ifar(ics_icd_iu0_ifar),
      .ics_icd_iu0_index51(ics_icd_iu0_index51),
      .ics_icd_iu0_inval(ics_icd_iu0_inval),
      .ics_icd_iu0_2ucode(ics_icd_iu0_2ucode),
      .ics_icd_iu0_2ucode_type(ics_icd_iu0_2ucode_type),
      .ics_icd_iu0_prefetch(ics_icd_iu0_prefetch),
      .ics_icd_iu0_read_erat(ics_icd_iu0_read_erat),
      .ics_icd_iu0_spr_idir_read(ics_icd_iu0_spr_idir_read),
      .ics_icd_iu1_flush(ics_icd_iu1_flush),
      .ics_icd_iu2_flush(ics_icd_iu2_flush),
      .icd_ics_iu1_valid(icd_ics_iu1_valid),
      .icd_ics_iu1_tid(icd_ics_iu1_tid),
      .icd_ics_iu1_ifar(icd_ics_iu1_ifar),
      .icd_ics_iu1_2ucode(icd_ics_iu1_2ucode),
      .icd_ics_iu1_2ucode_type(icd_ics_iu1_2ucode_type),
      .icd_ics_iu1_read_erat(icd_ics_iu1_read_erat),
      .icd_ics_iu3_miss_flush(icd_ics_iu3_miss_flush),
      .icd_ics_iu2_wrong_ra_flush(icd_ics_iu2_wrong_ra_flush),
      .icd_ics_iu2_cam_etc_flush(icd_ics_iu2_cam_etc_flush),
      .icd_ics_iu2_ifar_eff(icd_ics_iu2_ifar_eff),
      .icd_ics_iu2_2ucode(icd_ics_iu2_2ucode),
      .icd_ics_iu2_2ucode_type(icd_ics_iu2_2ucode_type),
      .icd_ics_iu2_valid(icd_ics_iu2_valid),
      .icd_ics_iu2_read_erat_error(icd_ics_iu2_read_erat_error),
      .icd_ics_iu3_parity_flush(icd_ics_iu3_parity_flush),
      .icd_ics_iu3_ifar(icd_ics_iu3_ifar),
      .icd_ics_iu3_2ucode(icd_ics_iu3_2ucode),
      .icd_ics_iu3_2ucode_type(icd_ics_iu3_2ucode_type),
      .ic_bp_iu0_val(ic_bp_iu0_val),
      .ic_bp_iu0_ifar(ic_bp_iu0_ifar),
      .ic_bp_iu2_flush(ic_bp_iu2_flush),
      .bp_ic_iu2_redirect(bp_ic_iu2_redirect),
      .bp_ic_iu3_redirect(bp_ic_iu3_redirect),
      .bp_ic_iu4_redirect(bp_ic_iu4_redirect),
      .bp_ic_t0_redirect_ifar(bp_ic_t0_redirect_ifar),
    `ifndef THREADS1
      .bp_ic_t1_redirect_ifar(bp_ic_t1_redirect_ifar),
    `endif
      .uc_ic_hold(uc_ic_hold),
      .uc_iu4_flush(uc_iu4_flush),
      .uc_iu4_t0_flush_ifar(uc_iu4_t0_flush_ifar),
    `ifndef THREADS1
      .uc_iu4_t1_flush_ifar(uc_iu4_t1_flush_ifar),
      .ib_ic_t1_need_fetch(ib_ic_t1_need_fetch),
    `endif
      .ib_ic_t0_need_fetch(ib_ic_t0_need_fetch),
      .event_bus_enable(pc_iu_event_bus_enable)
   );


   iuq_ic_dir  iuq_ic_dir0(
      .vcs(vdd),
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .pc_iu_func_sl_thold_0_b(pc_iu_func_sl_thold_0_b),
      .pc_iu_func_slp_sl_thold_0_b(pc_iu_func_slp_sl_thold_0_b),
      .pc_iu_time_sl_thold_0(pc_iu_time_sl_thold_0),
      .pc_iu_repr_sl_thold_0(pc_iu_repr_sl_thold_0),
      .pc_iu_abst_sl_thold_0(pc_iu_abst_sl_thold_0),
      .pc_iu_abst_sl_thold_0_b(pc_iu_abst_sl_thold_0_b),
      .pc_iu_abst_slp_sl_thold_0(pc_iu_abst_slp_sl_thold_0),
      .pc_iu_ary_nsl_thold_0(pc_iu_ary_nsl_thold_0),
      .pc_iu_ary_slp_nsl_thold_0(pc_iu_ary_slp_nsl_thold_0),
      .pc_iu_bolt_sl_thold_0(pc_iu_bolt_sl_thold_0),
      .pc_iu_sg_0(pc_iu_sg_0),
      .pc_iu_sg_1(pc_iu_sg_1),
      .force_t(force_t),
      .funcslp_force(funcslp_force),
      .abst_force(abst_force),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .clkoff_b(clkoff_b),
      .act_dis(act_dis),
      .g8t_clkoff_b(g8t_clkoff_b),
      .g8t_d_mode(g8t_d_mode),
      .g8t_delay_lclkr(g8t_delay_lclkr),
      .g8t_mpw1_b(g8t_mpw1_b),
      .g8t_mpw2_b(g8t_mpw2_b),
      .g6t_clkoff_b(g6t_clkoff_b),
      .g6t_act_dis(g6t_act_dis),
      .g6t_d_mode(g6t_d_mode),
      .g6t_delay_lclkr(g6t_delay_lclkr),
      .g6t_mpw1_b(g6t_mpw1_b),
      .g6t_mpw2_b(g6t_mpw2_b),
      .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
      .tc_ac_scan_dis_dc_b(tc_ac_scan_dis_dc_b),
      .tc_ac_scan_diag_dc(tc_ac_scan_diag_dc),
      .func_scan_in(siv[3]),
      .time_scan_in(tsiv[1]),
      .repr_scan_in(repr_scan_in),
      .abst_scan_in(abst_scan_in),
      .func_scan_out(sov[3]),
      .time_scan_out(tsov[1]),
      .repr_scan_out(repr_scan_out),
      .abst_scan_out(abst_scan_out),
      .spr_ic_cls(spr_ic_cls),
      .spr_ic_ierat_byp_dis(spr_ic_ierat_byp_dis),
      .spr_ic_idir_way(spr_ic_idir_way),
      .ic_spr_idir_done(ic_spr_idir_done),
      .ic_spr_idir_lru(ic_spr_idir_lru),
      .ic_spr_idir_parity(ic_spr_idir_parity),
      .ic_spr_idir_endian(ic_spr_idir_endian),
      .ic_spr_idir_valid(ic_spr_idir_valid),
      .ic_spr_idir_tag(ic_spr_idir_tag),
      .ic_perf_t0_event(ic_perf_t0_event[9:11]),
    `ifndef THREADS1
      .ic_perf_t1_event(ic_perf_t1_event[9:11]),
    `endif
      .ic_perf_event(ic_perf_event),
      .iu_pc_err_icache_parity(iu_pc_err_icache_parity),
      .iu_pc_err_icachedir_parity(iu_pc_err_icachedir_parity),
      .iu_pc_err_icachedir_multihit(iu_pc_err_icachedir_multihit),
      .pc_iu_inj_icache_parity(pc_iu_inj_icache_parity),
      .pc_iu_inj_icachedir_parity(pc_iu_inj_icachedir_parity),
      .pc_iu_inj_icachedir_multihit(pc_iu_inj_icachedir_multihit),
      .pc_iu_abist_g8t_wenb(pc_iu_abist_g8t_wenb),
      .pc_iu_abist_g8t1p_renb_0(pc_iu_abist_g8t1p_renb_0),
      .pc_iu_abist_di_0(pc_iu_abist_di_0),
      .pc_iu_abist_g8t_bw_1(pc_iu_abist_g8t_bw_1),
      .pc_iu_abist_g8t_bw_0(pc_iu_abist_g8t_bw_0),
      .pc_iu_abist_waddr_0(pc_iu_abist_waddr_0),
      .pc_iu_abist_raddr_0(pc_iu_abist_raddr_0),
      .pc_iu_abist_ena_dc(pc_iu_abist_ena_dc),
      .pc_iu_abist_wl128_comp_ena(pc_iu_abist_wl128_comp_ena),
      .pc_iu_abist_raw_dc_b(pc_iu_abist_raw_dc_b),
      .pc_iu_abist_g8t_dcomp(pc_iu_abist_g8t_dcomp),
      .pc_iu_abist_g6t_bw(pc_iu_abist_g6t_bw),
      .pc_iu_abist_di_g6t_2r(pc_iu_abist_di_g6t_2r),
      .pc_iu_abist_wl512_comp_ena(pc_iu_abist_wl512_comp_ena),
      .pc_iu_abist_dcomp_g6t_2r(pc_iu_abist_dcomp_g6t_2r),
      .pc_iu_abist_g6t_r_wb(pc_iu_abist_g6t_r_wb),
      .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
      .pc_iu_bo_enable_2(pc_iu_bo_enable_2),
      .pc_iu_bo_reset(pc_iu_bo_reset),
      .pc_iu_bo_unload(pc_iu_bo_unload),
      .pc_iu_bo_repair(pc_iu_bo_repair),
      .pc_iu_bo_shdata(pc_iu_bo_shdata),
      .pc_iu_bo_select(pc_iu_bo_select),
      .iu_pc_bo_fail(iu_pc_bo_fail),
      .iu_pc_bo_diagout(iu_pc_bo_diagout),
      .iu_mm_ierat_epn(iu_mm_ierat_epn),
      .iu_ierat_iu1_back_inv(iu_ierat_iu1_back_inv),
      .ierat_iu_iu2_rpn(ierat_iu_iu2_rpn),
      .ierat_iu_iu2_wimge(ierat_iu_iu2_wimge),
      .ierat_iu_iu2_u(ierat_iu_iu2_u),
      .ierat_iu_iu2_error(ierat_iu_iu2_error),
      .ierat_iu_iu2_miss(ierat_iu_iu2_miss),
      .ierat_iu_iu2_multihit(ierat_iu_iu2_multihit),
      .ierat_iu_iu2_isi(ierat_iu_iu2_isi),
      .ierat_iu_iu2_flush_req(ierat_iu_iu2_flush_req),
      .ierat_iu_cam_change(ierat_iu_cam_change),
      .lq_iu_ici_val(lq_iu_ici_val),
      .ics_icd_dir_rd_act(ics_icd_dir_rd_act),
      .ics_icd_data_rd_act(ics_icd_data_rd_act),
      .ics_icd_iu0_valid(ics_icd_iu0_valid),
      .ics_icd_iu0_tid(ics_icd_iu0_tid),
      .ics_icd_iu0_ifar(ics_icd_iu0_ifar),
      .ics_icd_iu0_index51(ics_icd_iu0_index51),
      .ics_icd_iu0_inval(ics_icd_iu0_inval),
      .ics_icd_iu0_2ucode(ics_icd_iu0_2ucode),
      .ics_icd_iu0_2ucode_type(ics_icd_iu0_2ucode_type),
      .ics_icd_iu0_prefetch(ics_icd_iu0_prefetch),
      .ics_icd_iu0_read_erat(ics_icd_iu0_read_erat),
      .ics_icd_iu0_spr_idir_read(ics_icd_iu0_spr_idir_read),
      .ics_icd_iu1_flush(ics_icd_iu1_flush),
      .ics_icd_iu2_flush(ics_icd_iu2_flush),
      .icd_ics_iu1_valid(icd_ics_iu1_valid),
      .icd_ics_iu1_tid(icd_ics_iu1_tid),
      .icd_ics_iu1_ifar(icd_ics_iu1_ifar),
      .icd_ics_iu1_2ucode(icd_ics_iu1_2ucode),
      .icd_ics_iu1_2ucode_type(icd_ics_iu1_2ucode_type),
      .icd_ics_iu1_read_erat(icd_ics_iu1_read_erat),
      .icd_ics_iu3_miss_flush(icd_ics_iu3_miss_flush),
      .icd_ics_iu2_wrong_ra_flush(icd_ics_iu2_wrong_ra_flush),
      .icd_ics_iu2_cam_etc_flush(icd_ics_iu2_cam_etc_flush),
      .icd_ics_iu2_ifar_eff(icd_ics_iu2_ifar_eff),
      .icd_ics_iu2_2ucode(icd_ics_iu2_2ucode),
      .icd_ics_iu2_2ucode_type(icd_ics_iu2_2ucode_type),
      .icd_ics_iu2_valid(icd_ics_iu2_valid),
      .icd_ics_iu2_read_erat_error(icd_ics_iu2_read_erat_error),
      .icd_ics_iu3_parity_flush(icd_ics_iu3_parity_flush),
      .icd_ics_iu3_ifar(icd_ics_iu3_ifar),
      .icd_ics_iu3_2ucode(icd_ics_iu3_2ucode),
      .icd_ics_iu3_2ucode_type(icd_ics_iu3_2ucode_type),
      .icm_icd_lru_addr(icm_icd_lru_addr),
      .icm_icd_dir_inval(icm_icd_dir_inval),
      .icm_icd_dir_val(icm_icd_dir_val),
      .icm_icd_data_write(icm_icd_data_write),
      .icm_icd_reload_addr(icm_icd_reload_addr),
      .icm_icd_reload_data(icm_icd_reload_data),
      .icm_icd_reload_way(icm_icd_reload_way),
      .icm_icd_load(icm_icd_load),
      .icm_icd_load_addr(icm_icd_load_addr),
      .icm_icd_load_2ucode(icm_icd_load_2ucode),
      .icm_icd_load_2ucode_type(icm_icd_load_2ucode_type),
      .icm_icd_dir_write(icm_icd_dir_write),
      .icm_icd_dir_write_addr(icm_icd_dir_write_addr),
      .icm_icd_dir_write_endian(icm_icd_dir_write_endian),
      .icm_icd_dir_write_way(icm_icd_dir_write_way),
      .icm_icd_lru_write(icm_icd_lru_write),
      .icm_icd_lru_write_addr(icm_icd_lru_write_addr),
      .icm_icd_lru_write_way(icm_icd_lru_write_way),
      .icm_icd_ecc_inval(icm_icd_ecc_inval),
      .icm_icd_ecc_addr(icm_icd_ecc_addr),
      .icm_icd_ecc_way(icm_icd_ecc_way),
      .icm_icd_iu3_ecc_fp_cancel(icm_icd_iu3_ecc_fp_cancel),
      .icm_icd_any_reld_r2(icm_icd_any_reld_r2),
      .icd_icm_miss(icd_icm_miss),
      .icd_icm_prefetch(icd_icm_prefetch),
      .icd_icm_tid(icd_icm_tid),
      .icd_icm_addr_real(icd_icm_addr_real),
      .icd_icm_addr_eff(icd_icm_addr_eff),
      .icd_icm_wimge(icd_icm_wimge),
      .icd_icm_userdef(icd_icm_userdef),
      .icd_icm_2ucode(icd_icm_2ucode),
      .icd_icm_2ucode_type(icd_icm_2ucode_type),
      .icd_icm_iu2_inval(icd_icm_iu2_inval),
      .icd_icm_any_iu2_valid(icd_icm_any_iu2_valid),
      .icd_icm_row_lru(icd_icm_row_lru),
      .icd_icm_row_val(icd_icm_row_val),
      .ic_bp_iu2_t0_val(ic_bp_iu2_t0_val),
    `ifndef THREADS1
      .ic_bp_iu2_t1_val(ic_bp_iu2_t1_val),
    `endif
      .ic_bp_iu2_ifar(ic_bp_iu2_ifar),
      .ic_bp_iu2_2ucode(ic_bp_iu2_2ucode),
      .ic_bp_iu2_2ucode_type(ic_bp_iu2_2ucode_type),
      .ic_bp_iu2_error(ic_bp_iu2_error),
      .ic_bp_iu3_flush(ic_bp_iu3_flush),
      .ic_bp_iu2_0_instr(ic_bp_iu2_0_instr),
      .ic_bp_iu2_1_instr(ic_bp_iu2_1_instr),
      .ic_bp_iu2_2_instr(ic_bp_iu2_2_instr),
      .ic_bp_iu2_3_instr(ic_bp_iu2_3_instr),
      .event_bus_enable(pc_iu_event_bus_enable)
   );


   iuq_ic_miss  iuq_ic_miss0(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .pc_iu_func_sl_thold_0_b(pc_iu_func_sl_thold_0_b),
      .pc_iu_sg_0(pc_iu_sg_0),
      .force_t(force_t),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scan_in(siv[4]),
      .scan_out(sov[4]),
      .iu_flush(iu_flush),
      .br_iu_redirect(br_iu_redirect),
      .bp_ic_iu4_redirect(bp_ic_iu4_redirect),
      .ic_bp_iu3_ecc_err(ic_bp_iu3_ecc_err),
      .ics_icm_iu0_t0_ifar(ics_icm_iu0_t0_ifar),
    `ifndef THREADS1
      .ics_icm_iu0_t1_ifar(ics_icm_iu0_t1_ifar),
    `endif
      .ics_icm_iu0_inval(ics_icm_iu0_inval),
      .ics_icm_iu0_inval_addr(ics_icm_iu0_inval_addr),
      .ics_icm_iu2_flush(ics_icm_iu2_flush),
      .icm_ics_hold_thread(icm_ics_hold_thread),
      .icm_ics_hold_iu0(icm_ics_hold_iu0),
      .icm_ics_iu3_miss_match(icm_ics_iu3_miss_match),
      .icm_ics_iu3_ecc_fp_cancel(icm_ics_iu3_ecc_fp_cancel),
      .icm_ics_iu0_preload_val(icm_ics_iu0_preload_val),
      .icm_ics_iu0_preload_ifar(icm_ics_iu0_preload_ifar),
      .icm_ics_prefetch_req(icm_ics_prefetch_req),
      .icm_ics_prefetch_sm_idle(icm_ics_prefetch_sm_idle),
      .icm_icd_lru_addr(icm_icd_lru_addr),
      .icm_icd_dir_inval(icm_icd_dir_inval),
      .icm_icd_dir_val(icm_icd_dir_val),
      .icm_icd_data_write(icm_icd_data_write),
      .icm_icd_reload_addr(icm_icd_reload_addr),
      .icm_icd_reload_data(icm_icd_reload_data),
      .icm_icd_reload_way(icm_icd_reload_way),
      .icm_icd_load(icm_icd_load),
      .icm_icd_load_addr(icm_icd_load_addr),
      .icm_icd_load_2ucode(icm_icd_load_2ucode),
      .icm_icd_load_2ucode_type(icm_icd_load_2ucode_type),
      .icm_icd_dir_write(icm_icd_dir_write),
      .icm_icd_dir_write_addr(icm_icd_dir_write_addr),
      .icm_icd_dir_write_endian(icm_icd_dir_write_endian),
      .icm_icd_dir_write_way(icm_icd_dir_write_way),
      .icm_icd_lru_write(icm_icd_lru_write),
      .icm_icd_lru_write_addr(icm_icd_lru_write_addr),
      .icm_icd_lru_write_way(icm_icd_lru_write_way),
      .icm_icd_ecc_inval(icm_icd_ecc_inval),
      .icm_icd_ecc_addr(icm_icd_ecc_addr),
      .icm_icd_ecc_way(icm_icd_ecc_way),
      .icm_icd_iu3_ecc_fp_cancel(icm_icd_iu3_ecc_fp_cancel),
      .icm_icd_any_reld_r2(icm_icd_any_reld_r2),
      .icd_icm_miss(icd_icm_miss),
      .icd_icm_prefetch(icd_icm_prefetch),
      .icd_icm_tid(icd_icm_tid),
      .icd_icm_addr_real(icd_icm_addr_real),
      .icd_icm_addr_eff(icd_icm_addr_eff),
      .icd_icm_wimge(icd_icm_wimge),
      .icd_icm_userdef(icd_icm_userdef),
      .icd_icm_2ucode(icd_icm_2ucode),
      .icd_icm_2ucode_type(icd_icm_2ucode_type),
      .icd_icm_iu2_inval(icd_icm_iu2_inval),
      .icd_icm_any_iu2_valid(icd_icm_any_iu2_valid),
      .icd_icm_row_lru(icd_icm_row_lru),
      .icd_icm_row_val(icd_icm_row_val),
      .ic_perf_t0_event(ic_perf_t0_event[0:2]),
    `ifndef THREADS1
      .ic_perf_t1_event(ic_perf_t1_event[0:2]),
    `endif
      .cp_async_block(cp_async_block),
      .iu_mm_lmq_empty(iu_mm_lmq_empty),
      .iu_xu_icache_quiesce(iu_xu_icache_quiesce),
      .iu_pc_icache_quiesce(iu_pc_icache_quiesce),
      .an_ac_reld_data_vld(an_ac_reld_data_vld),
      .an_ac_reld_core_tag(an_ac_reld_core_tag),
      .an_ac_reld_qw(an_ac_reld_qw),
      .an_ac_reld_data(an_ac_reld_data),
      .an_ac_reld_ecc_err(an_ac_reld_ecc_err),
      .an_ac_reld_ecc_err_ue(an_ac_reld_ecc_err_ue),
      .spr_ic_cls(spr_ic_cls),
      .spr_ic_bp_config(spr_ic_bp_config),
      .iu_lq_request(iu_lq_request),
      .iu_lq_ctag(iu_lq_ctag),
      .iu_lq_ra(iu_lq_ra),
      .iu_lq_wimge(iu_lq_wimge),
      .iu_lq_userdef(iu_lq_userdef),
      .event_bus_enable(pc_iu_event_bus_enable)
   );

   //-----------------------------------------------
   // performance
   //-----------------------------------------------

   assign unit_t0_events_en = (pc_iu_event_count_mode[0] &  xu_iu_msr_pr[0]              ) |	//problem state
                              (pc_iu_event_count_mode[1] & ~xu_iu_msr_pr[0] &  xu_iu_msr_hv[0]) |	//guest supervisor state
                              (pc_iu_event_count_mode[2] & ~xu_iu_msr_pr[0] & ~xu_iu_msr_hv[0]) ;	//hypervisor state

   // events_in(1:63). Decode 0 is used for event_bus_in
   assign unit_t0_events_in = {ic_perf_t0_event[0:11], ic_perf_event[0:1], 1'b0,
                               16'b0,
                               slice_ic_t0_perf_events, 11'b0} &
			       {63{unit_t0_events_en}};

   tri_event_mux1t #(.EVENTS_IN(64), .EVENTS_OUT(4)) iuq_perf0(
       .vd(vdd),
       .gd(gnd),
       .select_bits(spr_perf_event_mux_ctrls[0:23]),
       .unit_events_in(unit_t0_events_in),
       .event_bus_in(event_bus_in[0:3]),
       .event_bus_out(event_bus_out_d[0:3])
   );

 `ifndef THREADS1
   assign unit_t1_events_en = (pc_iu_event_count_mode[0] &  xu_iu_msr_pr[1]                 ) |	//problem state
                              (pc_iu_event_count_mode[1] & ~xu_iu_msr_pr[1] &  xu_iu_msr_hv[1]) |	//guest supervisor state
                              (pc_iu_event_count_mode[2] & ~xu_iu_msr_pr[1] & ~xu_iu_msr_hv[1]) ;	//hypervisor state


   assign unit_t1_events_in = {ic_perf_t1_event[0:11], ic_perf_event[0:1], 1'b0,
                               16'b0,
                               slice_ic_t1_perf_events, 11'b0} &
			       {63{unit_t1_events_en}};

   tri_event_mux1t #(.EVENTS_IN(64), .EVENTS_OUT(4)) iuq_perf1(
       .vd(vdd),
       .gd(gnd),
       .select_bits(spr_perf_event_mux_ctrls[24:47]),
       .unit_events_in(unit_t1_events_in),
       .event_bus_in(event_bus_in[4:7]),
       .event_bus_out(event_bus_out_d[4:7])
   );
 `endif

   tri_rlmreg_p #(.WIDTH(4*`THREADS), .INIT(0)) perf_bus_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[perf_bus_offset:perf_bus_offset + 4*`THREADS - 1]),
      .scout(sov[perf_bus_offset:perf_bus_offset + 4*`THREADS - 1]),
      .din(event_bus_out_d),
      .dout(event_bus_out_l2)
   );

   assign event_bus_out = event_bus_out_l2;

   //-----------------------------------------------
   // pervasive
   //-----------------------------------------------

   tri_plat #(.WIDTH(1)) perv_3to2_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din(pc_iu_bo_enable_3),
      .q(pc_iu_bo_enable_2)
   );

   tri_plat #(.WIDTH(11)) perv_2to1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({pc_iu_func_sl_thold_2,
            pc_iu_func_slp_sl_thold_2,
            pc_iu_time_sl_thold_2,
            pc_iu_repr_sl_thold_2,
            pc_iu_abst_sl_thold_2,
            pc_iu_abst_slp_sl_thold_2,
            pc_iu_ary_nsl_thold_2,
            pc_iu_ary_slp_nsl_thold_2,
            pc_iu_regf_slp_sl_thold_2,
            pc_iu_bolt_sl_thold_2,
            pc_iu_sg_2}),
      .q(  {pc_iu_func_sl_thold_1,
            pc_iu_func_slp_sl_thold_1,
            pc_iu_time_sl_thold_1,
            pc_iu_repr_sl_thold_1,
            pc_iu_abst_sl_thold_1,
            pc_iu_abst_slp_sl_thold_1,
            pc_iu_ary_nsl_thold_1,
            pc_iu_ary_slp_nsl_thold_1,
            pc_iu_regf_slp_sl_thold_1,
            pc_iu_bolt_sl_thold_1,
            pc_iu_sg_1})
   );

   tri_plat #(.WIDTH(11)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({pc_iu_func_sl_thold_1,
            pc_iu_func_slp_sl_thold_1,
            pc_iu_time_sl_thold_1,
            pc_iu_repr_sl_thold_1,
            pc_iu_abst_sl_thold_1,
            pc_iu_abst_slp_sl_thold_1,
            pc_iu_ary_nsl_thold_1,
            pc_iu_ary_slp_nsl_thold_1,
            pc_iu_regf_slp_sl_thold_1,
            pc_iu_bolt_sl_thold_1,
            pc_iu_sg_1}),
      .q(  {pc_iu_func_sl_thold_0,
            pc_iu_func_slp_sl_thold_0,
            pc_iu_time_sl_thold_0,
            pc_iu_repr_sl_thold_0,
            pc_iu_abst_sl_thold_0,
            pc_iu_abst_slp_sl_thold_0,
            pc_iu_ary_nsl_thold_0,
            pc_iu_ary_slp_nsl_thold_0,
            pc_iu_regf_slp_sl_thold_0,
            pc_iu_bolt_sl_thold_0,
            pc_iu_sg_0})
   );

   tri_lcbor  perv_lcbor(
      .clkoff_b(clkoff_b),
      .thold(pc_iu_func_sl_thold_0),
      .sg(pc_iu_sg_0),
      .act_dis(act_dis),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b)
   );

   tri_lcbor  func_slp_lcbor(
      .clkoff_b(clkoff_b),
      .thold(pc_iu_func_slp_sl_thold_0),
      .sg(pc_iu_sg_0),
      .act_dis(act_dis),
      .force_t(funcslp_force),
      .thold_b(pc_iu_func_slp_sl_thold_0_b)
   );

   tri_lcbor  abst_lcbor(
      .clkoff_b(clkoff_b),
      .thold(pc_iu_abst_sl_thold_0),
      .sg(pc_iu_sg_0),
      .act_dis(act_dis),
      .force_t(abst_force),
      .thold_b(pc_iu_abst_sl_thold_0_b)
   );

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign func_scan_in_cam = func_scan_in;
   assign siv = {func_scan_out_cam, sov[0:scan_right-1]};
   assign func_scan_out = sov[scan_right] & tc_ac_scan_dis_dc_b;

   assign tsiv = {time_scan_in, tsov[0]};
   assign time_scan_out = tsov[1] & tc_ac_scan_dis_dc_b;

endmodule
