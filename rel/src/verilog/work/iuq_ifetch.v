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
//* TITLE: Instruction Fetch RLM wrapper
//*
//* NAME: iuq_ifetch.v
//*
//*********************************************************************

`include "tri_a2o.vh"

module iuq_ifetch(
    (* pin_data="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]           nclk,

   input                             tc_ac_ccflush_dc,
   input                             tc_ac_scan_dis_dc_b,
   input                             tc_ac_scan_diag_dc,

   input                             pc_iu_func_sl_thold_2,
   input                             pc_iu_func_slp_sl_thold_2,
   input                             pc_iu_func_nsl_thold_2,		// added for custom cam
   input                             pc_iu_cfg_slp_sl_thold_2,		// for boot config slats
   input                             pc_iu_regf_slp_sl_thold_2,
   input                             pc_iu_time_sl_thold_2,
   input                             pc_iu_abst_sl_thold_2,
   input                             pc_iu_abst_slp_sl_thold_2,
   input                             pc_iu_repr_sl_thold_2,
   input                             pc_iu_ary_nsl_thold_2,
   input                             pc_iu_ary_slp_nsl_thold_2,
   input                             pc_iu_func_slp_nsl_thold_2,
   input                             pc_iu_bolt_sl_thold_2,
   input                             pc_iu_sg_2,
   input                             pc_iu_fce_2,
   input                             clkoff_b,
   input                             act_dis,
   input                             delay_lclkr,
   input                             mpw1_b,
   input                             g8t_clkoff_b,
   input                             g8t_d_mode,
   input [0:4]                       g8t_delay_lclkr,
   input [0:4]                       g8t_mpw1_b,
   input                             g8t_mpw2_b,
   input                             g6t_clkoff_b,
   input                             g6t_act_dis,
   input                             g6t_d_mode,
   input [0:3]                       g6t_delay_lclkr,
   input [0:4]                       g6t_mpw1_b,
   input                             g6t_mpw2_b,
   input                             cam_clkoff_b,
   input                             cam_act_dis,
   input                             cam_d_mode,
   input [0:4]                       cam_delay_lclkr,
   input [0:4]                       cam_mpw1_b,
   input                             cam_mpw2_b,

    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                             func_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                            func_scan_out,
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                             ac_ccfg_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                            ac_ccfg_scan_out,
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                             time_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                            time_scan_out,
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                             repr_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                            repr_scan_out,
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:2]                       abst_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:2]                      abst_scan_out,
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:4]                       regf_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:4]                      regf_scan_out,

   output                            iu_pc_err_icache_parity,
   output                            iu_pc_err_icachedir_parity,
   output                            iu_pc_err_icachedir_multihit,
   output                            iu_pc_err_ierat_multihit,
   output                            iu_pc_err_ierat_parity,

   input                             pc_iu_inj_icache_parity,
   input                             pc_iu_inj_icachedir_parity,
   input                             pc_iu_inj_icachedir_multihit,

   input                             pc_iu_abist_g8t_wenb,
   input                             pc_iu_abist_g8t1p_renb_0,
   input [0:3]                       pc_iu_abist_di_0,
   input                             pc_iu_abist_g8t_bw_1,
   input                             pc_iu_abist_g8t_bw_0,
   input [3:9]                       pc_iu_abist_waddr_0,
   input [1:9]                       pc_iu_abist_raddr_0,
   input                             pc_iu_abist_ena_dc,
   input                             pc_iu_abist_wl128_comp_ena,
   input                             pc_iu_abist_raw_dc_b,
   input [0:3]                       pc_iu_abist_g8t_dcomp,
   input [0:1]                       pc_iu_abist_g6t_bw,
   input [0:3]                       pc_iu_abist_di_g6t_2r,
   input                             pc_iu_abist_wl512_comp_ena,
   input [0:3]                       pc_iu_abist_dcomp_g6t_2r,
   input                             pc_iu_abist_g6t_r_wb,
   input                             an_ac_lbist_ary_wrt_thru_dc,
   input                             an_ac_lbist_en_dc,
   input                             an_ac_atpg_en_dc,
   input                             an_ac_grffence_en_dc,

   input                             pc_iu_bo_enable_3,		// bolt-on ABIST
   input                             pc_iu_bo_reset,
   input                             pc_iu_bo_unload,
   input                             pc_iu_bo_repair,
   input                             pc_iu_bo_shdata,
   input [0:3]                       pc_iu_bo_select,
   output [0:3]                      iu_pc_bo_fail,
   output [0:3]                      iu_pc_bo_diagout,

   // ICBI Interface to IU
   input [0:`THREADS-1]              lq_iu_icbi_val,
   input [64-`REAL_IFAR_WIDTH:57]    lq_iu_icbi_addr,
   output [0:`THREADS-1]             iu_lq_icbi_complete,
   input                             lq_iu_ici_val,
   output                            iu_lq_spr_iucr0_icbi_ack,

   // ERAT
   input                             pc_iu_init_reset,

   // XU IERAT interface
   input [0:`THREADS-1]              xu_iu_val,
   input                             xu_iu_is_eratre,
   input                             xu_iu_is_eratwe,
   input                             xu_iu_is_eratsx,
   input                             xu_iu_is_eratilx,
   input                             cp_is_isync,
   input                             cp_is_csync,
   input [0:1]                       xu_iu_ws,
   input [0:3]                       xu_iu_ra_entry,

   input [64-`GPR_WIDTH:51]          xu_iu_rb,
   input [64-`GPR_WIDTH:63]          xu_iu_rs_data,
   output                            iu_xu_ord_read_done,
   output                            iu_xu_ord_write_done,
   output                            iu_xu_ord_par_err,
   output                            iu_xu_ord_n_flush_req,
   input [0:`THREADS-1]              xu_iu_msr_gs,
   input [0:`THREADS-1]              xu_iu_msr_pr,
   input [0:`THREADS-1]              xu_iu_msr_is,
   input                             xu_iu_hid_mmu_mode,
   input                             xu_iu_spr_ccr2_ifrat,
   input [0:8]                       xu_iu_spr_ccr2_ifratsc,		// 0:4: wimge, 5:8: u0:3
   input                             xu_iu_xucr4_mmu_mchk,
   output [64-`GPR_WIDTH:63]         iu_xu_ex5_data,

   output                            iu_mm_ierat_req,
   output                            iu_mm_ierat_req_nonspec,
   output [0:51]                     iu_mm_ierat_epn,
   output [0:`THREADS-1]             iu_mm_ierat_thdid,
   output [0:3]                      iu_mm_ierat_state,
   output [0:13]                     iu_mm_ierat_tid,
   output [0:`THREADS-1]             iu_mm_ierat_flush,
   output [0:`THREADS-1]             iu_mm_perf_itlb,

   input [0:4]                       mm_iu_ierat_rel_val,
   input [0:131]                     mm_iu_ierat_rel_data,

   input [0:13]                      mm_iu_t0_ierat_pid,
   input [0:19]                      mm_iu_t0_ierat_mmucr0,
 `ifndef THREADS1
   input [0:13]                      mm_iu_t1_ierat_pid,
   input [0:19]                      mm_iu_t1_ierat_mmucr0,
 `endif
   output [0:17]                     iu_mm_ierat_mmucr0,
   output [0:`THREADS-1]             iu_mm_ierat_mmucr0_we,
   input [0:8]                       mm_iu_ierat_mmucr1,
   output [0:3]                      iu_mm_ierat_mmucr1,
   output [0:`THREADS-1]             iu_mm_ierat_mmucr1_we,

   input                             mm_iu_ierat_snoop_coming,
   input                             mm_iu_ierat_snoop_val,
   input [0:25]                      mm_iu_ierat_snoop_attr,
   input [62-`EFF_IFAR_ARCH:51]      mm_iu_ierat_snoop_vpn,
   output                            iu_mm_ierat_snoop_ack,

   // MMU Connections
   input [0:`THREADS-1]              mm_iu_hold_req,
   input [0:`THREADS-1]              mm_iu_hold_done,
   input [0:`THREADS-1]              mm_iu_bus_snoop_hold_req,
   input [0:`THREADS-1]              mm_iu_bus_snoop_hold_done,

   // SELECT, DIR, & MISS
   input [0:`THREADS-1]              pc_iu_pm_fetch_halt,
   input [0:`THREADS-1]              xu_iu_run_thread,
   input [0:`THREADS-1]              cp_ic_stop,
   input [0:`THREADS-1]              xu_iu_msr_cm,

   input [0:`THREADS-1]              iu_flush,
   input [0:`THREADS-1]              br_iu_redirect,
   input [62-`EFF_IFAR_ARCH:61]      br_iu_bta,
   input [0:`THREADS-1]              cp_flush,
   input [62-`EFF_IFAR_ARCH:61]      cp_iu0_t0_flush_ifar,
 `ifndef THREADS1
   input [62-`EFF_IFAR_ARCH:61]      cp_iu0_t1_flush_ifar,
 `endif
   input [0:`THREADS-1]              cp_iu0_flush_2ucode,
   input [0:`THREADS-1]              cp_iu0_flush_2ucode_type,
   input [0:`THREADS-1]              cp_iu0_flush_nonspec,
   input [0:`THREADS-1]              cp_flush_into_uc,
   input [0:`THREADS-1]              cp_uc_np1_flush,
   input [43:61]                     cp_uc_t0_flush_ifar,
 `ifndef THREADS1
   input [43:61]                     cp_uc_t1_flush_ifar,
 `endif
   input [0:`THREADS-1]              cp_uc_credit_free,

   output [0:`THREADS-1]             ic_cp_nonspec_hit,

   input                             an_ac_back_inv,
   input [64-`REAL_IFAR_WIDTH:57]    an_ac_back_inv_addr,
   input                             an_ac_back_inv_target,		// connect to bit(0)

   output [0:`THREADS-1]             iu_lq_request,
   output [0:1]                      iu_lq_ctag,
   output [64-`REAL_IFAR_WIDTH:59]   iu_lq_ra,
   output [0:4]                      iu_lq_wimge,
   output [0:3]                      iu_lq_userdef,

   input                             an_ac_reld_data_vld,
   input [0:4]                       an_ac_reld_core_tag,
   input [58:59]                     an_ac_reld_qw,
   input [0:127]                     an_ac_reld_data,
   input                             an_ac_reld_ecc_err,
   input                             an_ac_reld_ecc_err_ue,

   //Instruction Buffer
   input [0:`IBUFF_DEPTH/4-1]        ib_ic_t0_need_fetch,
 `ifndef THREADS1
   input [0:`IBUFF_DEPTH/4-1]        ib_ic_t1_need_fetch,
 `endif

   input [0:`THREADS-1]              cp_async_block,
   output                            iu_mm_lmq_empty,
   output [0:`THREADS-1]             iu_xu_icache_quiesce,
   output [0:`THREADS-1]             iu_pc_icache_quiesce,

   //---------Branch Predict
   //in from bht
   input [0:1]                       iu2_0_bh0_rd_data,
   input [0:1]                       iu2_1_bh0_rd_data,
   input [0:1]                       iu2_2_bh0_rd_data,
   input [0:1]                       iu2_3_bh0_rd_data,

   input [0:1]                       iu2_0_bh1_rd_data,
   input [0:1]                       iu2_1_bh1_rd_data,
   input [0:1]                       iu2_2_bh1_rd_data,
   input [0:1]                       iu2_3_bh1_rd_data,

   input			     iu2_0_bh2_rd_data,
   input                             iu2_1_bh2_rd_data,
   input                             iu2_2_bh2_rd_data,
   input                             iu2_3_bh2_rd_data,

   //out to bht
   output reg [0:9]                  iu0_bh0_rd_addr,
   output reg [0:9]                  iu0_bh1_rd_addr,
   output reg [0:8]                  iu0_bh2_rd_addr,
   output reg                        iu0_bh0_rd_act,
   output reg                        iu0_bh1_rd_act,
   output reg                        iu0_bh2_rd_act,
   output reg [0:1]                  ex5_bh0_wr_data,
   output reg [0:1]                  ex5_bh1_wr_data,
   output reg                        ex5_bh2_wr_data,
   output reg [0:9]                  ex5_bh0_wr_addr,
   output reg [0:9]                  ex5_bh1_wr_addr,
   output reg [0:8]                  ex5_bh2_wr_addr,
   output reg [0:3]                  ex5_bh0_wr_act,
   output reg [0:3]                  ex5_bh1_wr_act,
   output reg [0:3]                  ex5_bh2_wr_act,

   //in/out to btb
   output reg [0:5]                  iu0_btb_rd_addr,
   output reg                        iu0_btb_rd_act,
   input [0:63]			     iu2_btb_rd_data,
   output reg [0:5]                  ex5_btb_wr_addr,
   output reg                        ex5_btb_wr_act,
   output reg [0:63]	             ex5_btb_wr_data,

   //iu3
   output [0:3]                       bp_ib_iu3_t0_val,
   output [62-`EFF_IFAR_WIDTH:61]     bp_ib_iu3_t0_ifar,
   output [62-`EFF_IFAR_WIDTH:61]     bp_ib_iu3_t0_bta,

   //iu3 instruction(0:31) +
   output [0:69]                      bp_ib_iu3_t0_0_instr,
   output [0:69]                      bp_ib_iu3_t0_1_instr,
   output [0:69]                      bp_ib_iu3_t0_2_instr,
   output [0:69]                      bp_ib_iu3_t0_3_instr,
 `ifndef THREADS1
   output [0:3]                       bp_ib_iu3_t1_val,
   output [62-`EFF_IFAR_WIDTH:61]     bp_ib_iu3_t1_ifar,
   output [62-`EFF_IFAR_WIDTH:61]     bp_ib_iu3_t1_bta,

   //iu3 instruction(0:31) +
   output [0:69]                      bp_ib_iu3_t1_0_instr,
   output [0:69]                      bp_ib_iu3_t1_1_instr,
   output [0:69]                      bp_ib_iu3_t1_2_instr,
   output [0:69]                      bp_ib_iu3_t1_3_instr,
 `endif

   //ex4 update
   input [0:`THREADS-1]              cp_bp_val,
   input [62-`EFF_IFAR_WIDTH:61]     cp_bp_t0_ifar,
   input [0:1]                       cp_bp_t0_bh0_hist,
   input [0:1]                       cp_bp_t0_bh1_hist,
   input [0:1]                       cp_bp_t0_bh2_hist,
 `ifndef THREADS1
   input [62-`EFF_IFAR_WIDTH:61]     cp_bp_t1_ifar,
   input [0:1]                       cp_bp_t1_bh0_hist,
   input [0:1]                       cp_bp_t1_bh1_hist,
   input [0:1]                       cp_bp_t1_bh2_hist,
 `endif
   input [0:`THREADS-1]              cp_bp_br_pred,
   input [0:`THREADS-1]              cp_bp_br_taken,
   input [0:`THREADS-1]              cp_bp_bh_update,
   input [0:`THREADS-1]              cp_bp_bcctr,
   input [0:`THREADS-1]              cp_bp_bclr,
   input [0:`THREADS-1]              cp_bp_getNIA,
   input [0:`THREADS-1]              cp_bp_group,
   input [0:`THREADS-1]              cp_bp_lk,
   input [0:1]                       cp_bp_t0_bh,
   input [62-`EFF_IFAR_WIDTH:61]     cp_bp_t0_bta,
   input [0:9]                       cp_bp_t0_gshare,
   input [0:2]                       cp_bp_t0_ls_ptr,
   input [0:1]                       cp_bp_t0_btb_hist,
 `ifndef THREADS1
   input [0:1]                       cp_bp_t1_bh,
   input [62-`EFF_IFAR_WIDTH:61]     cp_bp_t1_bta,
   input [0:9]                       cp_bp_t1_gshare,
   input [0:2]                       cp_bp_t1_ls_ptr,
   input [0:1]                       cp_bp_t1_btb_hist,
 `endif
   input [0:`THREADS-1]              cp_bp_btb_entry,

   //config bits
   input [0:17]                      br_iu_gshare,
   input [0:2]                       br_iu_ls_ptr,
   input [62-`EFF_IFAR_WIDTH:61]     br_iu_ls_data,
   input                             br_iu_ls_update,

   input [0:`THREADS-1]              xu_iu_msr_de,
   input [0:`THREADS-1]              xu_iu_dbcr0_icmp,
   input [0:`THREADS-1]              xu_iu_dbcr0_brt,
   input [0:`THREADS-1]              xu_iu_iac1_en,
   input [0:`THREADS-1]              xu_iu_iac2_en,
   input [0:`THREADS-1]              xu_iu_iac3_en,
   input [0:`THREADS-1]              xu_iu_iac4_en,
   input [0:`THREADS-1]              lq_iu_spr_dbcr3_ivc,
   input [0:`THREADS-1]              xu_iu_single_instr_mode,
   input [0:`THREADS-1]              xu_iu_raise_iss_pri,

    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:2*`THREADS-1]            bp_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:2*`THREADS-1]           bp_scan_out,

   //-------------RAM
   input [0:31]                      pc_iu_ram_instr,
   input [0:3]                       pc_iu_ram_instr_ext,
   input                             pc_iu_ram_issue,
   input [0:`THREADS-1]              pc_iu_ram_active,

   input                             iu_pc_ram_done,

   input [0:`THREADS-1]              ib_rm_rdy,

   output [0:`THREADS-1]             rm_ib_iu3_val,
   output [0:35]                     rm_ib_iu3_instr,

   input                             ram_scan_in,
   output                            ram_scan_out,

   //-------------UCode
   input [0:`THREADS-1]              uc_scan_in,
   output [0:`THREADS-1]             uc_scan_out,

   output [0:`THREADS-1]             iu_pc_err_ucode_illegal,

   input [0:`THREADS-1]              xu_iu_ucode_xer_val,
   input [57:63]                     xu_iu_ucode_xer,

   input [0:`THREADS-1]              ib_uc_rdy,

   output [0:3]                      uc_ib_iu3_t0_invalid,
   output [0:1]                      uc_ib_t0_val,
 `ifndef THREADS1
   output [0:3]                      uc_ib_iu3_t1_invalid,
   output [0:1]                      uc_ib_t1_val,
 `endif
   output [0:`THREADS-1]             uc_ib_done,
   output [0:`THREADS-1]             uc_ib_iu3_flush_all,

   output [0:31]                     uc_ib_t0_instr0,
   output [0:31]                     uc_ib_t0_instr1,
   output [62-`EFF_IFAR_WIDTH:61]    uc_ib_t0_ifar0,
   output [62-`EFF_IFAR_WIDTH:61]    uc_ib_t0_ifar1,
   output [0:3]                      uc_ib_t0_ext0,
   output [0:3]                      uc_ib_t0_ext1,
 `ifndef THREADS1
   output [0:31]                     uc_ib_t1_instr0,
   output [0:31]                     uc_ib_t1_instr1,
   output [62-`EFF_IFAR_WIDTH:61]    uc_ib_t1_ifar0,
   output [62-`EFF_IFAR_WIDTH:61]    uc_ib_t1_ifar1,
   output [0:3]                      uc_ib_t1_ext0,
   output [0:3]                      uc_ib_t1_ext1,
 `endif

   //--------------SPR
   // inputs from xx
   input                             iu_slowspr_val_in,
   input                             iu_slowspr_rw_in,
   input [0:1]                       iu_slowspr_etid_in,
   input [0:9]                       iu_slowspr_addr_in,
   input [64-`GPR_WIDTH:63]          iu_slowspr_data_in,
   input                             iu_slowspr_done_in,

   // outputs to xx
   output                            iu_slowspr_val_out,
   output                            iu_slowspr_rw_out,
   output [0:1]                      iu_slowspr_etid_out,
   output [0:9]                      iu_slowspr_addr_out,
   output [64-`GPR_WIDTH:63]         iu_slowspr_data_out,
   output                            iu_slowspr_done_out,

   output [0:31]                     spr_dec_mask,
   output [0:31]                     spr_dec_match,
   output [0:`THREADS-1]             spr_single_issue,
   output [0:7]                      iu_au_t0_config_iucr,
 `ifndef THREADS1
   output [0:7]                      iu_au_t1_config_iucr,
 `endif

   input [0:`THREADS-1]              xu_iu_pri_val,
   input [0:2]                       xu_iu_pri,

   input [0:20]                      slice_ic_t0_perf_events,
 `ifndef THREADS1
   input [0:20]                      slice_ic_t1_perf_events,
 `endif
   output [0:31]                     spr_cp_perf_event_mux_ctrls,

   output [64-`GPR_WIDTH:51]         spr_ivpr,
   output [64-`GPR_WIDTH:51]         spr_givpr,

   output [62-`EFF_IFAR_ARCH:61]     spr_iac1,
   output [62-`EFF_IFAR_ARCH:61]     spr_iac2,
   output [62-`EFF_IFAR_ARCH:61]     spr_iac3,
   output [62-`EFF_IFAR_ARCH:61]     spr_iac4,

   output [0:`THREADS-1]             spr_cpcr_we,

   output [0:4]                      spr_t0_cpcr2_fx0_cnt,
   output [0:4]                      spr_t0_cpcr2_fx1_cnt,
   output [0:4]                      spr_t0_cpcr2_lq_cnt,
   output [0:4]                      spr_t0_cpcr2_sq_cnt,
   output [0:4]                      spr_t0_cpcr3_fu0_cnt,
   output [0:4]                      spr_t0_cpcr3_fu1_cnt,
   output [0:6]                      spr_t0_cpcr3_cp_cnt,
   output [0:4]                      spr_t0_cpcr4_fx0_cnt,
   output [0:4]                      spr_t0_cpcr4_fx1_cnt,
   output [0:4]                      spr_t0_cpcr4_lq_cnt,
   output [0:4]                      spr_t0_cpcr4_sq_cnt,
   output [0:4]                      spr_t0_cpcr5_fu0_cnt,
   output [0:4]                      spr_t0_cpcr5_fu1_cnt,
   output [0:6]                      spr_t0_cpcr5_cp_cnt,
 `ifndef THREADS1
   output [0:4]                      spr_t1_cpcr2_fx0_cnt,
   output [0:4]                      spr_t1_cpcr2_fx1_cnt,
   output [0:4]                      spr_t1_cpcr2_lq_cnt,
   output [0:4]                      spr_t1_cpcr2_sq_cnt,
   output [0:4]                      spr_t1_cpcr3_fu0_cnt,
   output [0:4]                      spr_t1_cpcr3_fu1_cnt,
   output [0:6]                      spr_t1_cpcr3_cp_cnt,
   output [0:4]                      spr_t1_cpcr4_fx0_cnt,
   output [0:4]                      spr_t1_cpcr4_fx1_cnt,
   output [0:4]                      spr_t1_cpcr4_lq_cnt,
   output [0:4]                      spr_t1_cpcr4_sq_cnt,
   output [0:4]                      spr_t1_cpcr5_fu0_cnt,
   output [0:4]                      spr_t1_cpcr5_fu1_cnt,
   output [0:6]                      spr_t1_cpcr5_cp_cnt,
 `endif
   output [0:4]                      spr_cpcr0_fx0_cnt,
   output [0:4]                      spr_cpcr0_fx1_cnt,
   output [0:4]                      spr_cpcr0_lq_cnt,
   output [0:4]                      spr_cpcr0_sq_cnt,
   output [0:4]                      spr_cpcr1_fu0_cnt,
   output [0:4]                      spr_cpcr1_fu1_cnt,

   output [0:`THREADS-1]             spr_high_pri_mask,
   output [0:`THREADS-1]             spr_med_pri_mask,
   output [0:5]                      spr_t0_low_pri_count,
`ifndef THREADS1
   output [0:5]                      spr_t1_low_pri_count,
`endif

   input [0:`THREADS-1]              iu_spr_eheir_update,
   input [0:31]                      iu_spr_t0_eheir,
 `ifndef THREADS1
   input [0:31]                      iu_spr_t1_eheir,
 `endif

   input                             spr_scan_in,
   output                            spr_scan_out,

   //---Performance
   input                             pc_iu_event_bus_enable,
   input [0:2]			     pc_iu_event_count_mode,
   input [0:4*`THREADS-1]            event_bus_in,
   output [0:4*`THREADS-1]           event_bus_out,

   //---Debug
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                             dbg1_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                            dbg1_scan_out,

   input                             pc_iu_trace_bus_enable,
   input  [0:10]                     pc_iu_debug_mux1_ctrls,

   input  [0:31]                     debug_bus_in,
   output [0:31]                     debug_bus_out,
   input  [0:3]                      coretrace_ctrls_in,
   output [0:3]                      coretrace_ctrls_out
);

   wire [0:`THREADS-1]               bp_ic_iu2_redirect;
   wire [0:`THREADS-1]               bp_ic_iu3_redirect;
   wire [0:`THREADS-1]               bp_ic_iu4_redirect;
   wire [62-`EFF_IFAR_WIDTH:61]      bp_ic_redirect_ifar[0:`THREADS-1];
   wire [0:`THREADS-1]               ic_bp_iu0_val;
   wire [50:59]                      ic_bp_iu0_ifar;
   wire [0:2]                        ic_bp_iu2_error;

   wire [0:3]                        ic_bp_iu2_val[0:`THREADS-1];
   wire [62-`EFF_IFAR_WIDTH:61]      ic_bp_iu2_ifar;
   wire                              ic_bp_iu2_2ucode;
   wire                              ic_bp_iu2_2ucode_type;
   wire [0:`THREADS-1]               ic_bp_iu2_flush;
   wire [0:`THREADS-1]               ic_bp_iu3_flush;
   wire [0:35]                       ic_bp_iu2_0_instr;
   wire [0:35]                       ic_bp_iu2_1_instr;
   wire [0:35]                       ic_bp_iu2_2_instr;
   wire [0:35]                       ic_bp_iu2_3_instr;
   wire                              ic_bp_iu3_ecc_err;
   wire [0:`THREADS-1]               uc_ic_hold;
   wire [0:`THREADS-1]               uc_iu4_flush;
   wire [62-`EFF_IFAR_WIDTH:61]      uc_iu4_flush_ifar[0:`THREADS-1];

   wire [0:3]                        spr_ic_bp_config;
   wire [0:5]                        spr_bp_config;
   wire [0:1]                        spr_bp_size;

   wire                              spr_ic_idir_read;
   wire [0:1]                        spr_ic_idir_way;
   wire [51:57]                      spr_ic_idir_row;
   wire                              ic_spr_idir_done;
   wire [0:2]                        ic_spr_idir_lru;
   wire [0:3]                        ic_spr_idir_parity;
   wire                              ic_spr_idir_endian;
   wire                              ic_spr_idir_valid;
   wire [0:28]                       ic_spr_idir_tag;
   wire                              spr_ic_icbi_ack_en;
   wire                              spr_ic_cls;
   wire                              spr_ic_clockgate_dis;
   wire                              spr_ic_prefetch_dis;
   wire                              spr_ic_ierat_byp_dis;
   wire [0:47]                       spr_perf_event_mux_ctrls;

   wire                              d_mode;
   wire                              mpw2_b;

   wire [0:9]                        iu0_bh0_rd_addr_int[0:`THREADS-1];
   wire [0:9]                        iu0_bh1_rd_addr_int[0:`THREADS-1];
   wire [0:8]                        iu0_bh2_rd_addr_int[0:`THREADS-1];
   wire [0:`THREADS-1]               iu0_bh0_rd_act_int;
   wire [0:`THREADS-1]               iu0_bh1_rd_act_int;
   wire [0:`THREADS-1]               iu0_bh2_rd_act_int;
   wire [0:1]                        ex5_bh0_wr_data_int[0:`THREADS-1];
   wire [0:1]                        ex5_bh1_wr_data_int[0:`THREADS-1];
   wire                              ex5_bh2_wr_data_int[0:`THREADS-1];
   wire [0:9]                        ex5_bh0_wr_addr_int[0:`THREADS-1];
   wire [0:9]                        ex5_bh1_wr_addr_int[0:`THREADS-1];
   wire [0:8]                        ex5_bh2_wr_addr_int[0:`THREADS-1];
   wire [0:3]                        ex5_bh0_wr_act_int[0:`THREADS-1];
   wire [0:3]                        ex5_bh1_wr_act_int[0:`THREADS-1];
   wire [0:3]                        ex5_bh2_wr_act_int[0:`THREADS-1];
   wire [0:5]                        iu0_btb_rd_addr_int[0:`THREADS-1];
   wire [0:`THREADS-1]               iu0_btb_rd_act_int;
   wire [0:5]                        ex5_btb_wr_addr_int[0:`THREADS-1];
   wire [0:`THREADS-1]               ex5_btb_wr_act_int;
   wire [0:63]                       ex5_btb_wr_data_int[0:`THREADS-1];

   wire [0:3]                        bp_ib_iu3_val_int[0:`THREADS-1];
   wire [62-`EFF_IFAR_WIDTH:61]      bp_ib_iu3_ifar[0:`THREADS-1];
   wire [62-`EFF_IFAR_WIDTH:61]      bp_ib_iu3_bta[0:`THREADS-1];
   wire [0:69]                       bp_ib_iu3_0_instr[0:`THREADS-1];
   wire [0:69]                       bp_ib_iu3_1_instr[0:`THREADS-1];
   wire [0:69]                       bp_ib_iu3_2_instr[0:`THREADS-1];
   wire [0:69]                       bp_ib_iu3_3_instr[0:`THREADS-1];

   wire [0:`THREADS-1]               spr_single_issue_int;

   wire [62-`EFF_IFAR_WIDTH:61]      cp_bp_ifar[0:`THREADS-1];
   wire [0:1]                        cp_bp_bh0_hist[0:`THREADS-1];
   wire [0:1]                        cp_bp_bh1_hist[0:`THREADS-1];
   wire [0:1]                        cp_bp_bh2_hist[0:`THREADS-1];
   wire [0:1]                        cp_bp_bh[0:`THREADS-1];
   wire [62-`EFF_IFAR_WIDTH:61]      cp_bp_bta[0:`THREADS-1];
   wire [0:9]                        cp_bp_gshare[0:`THREADS-1];
   wire [0:2]                        cp_bp_ls_ptr[0:`THREADS-1];
   wire [0:1]                        cp_bp_btb_hist[0:`THREADS-1];
   wire [43:61]                      cp_uc_flush_ifar[0:`THREADS-1];

   wire [0:3]                        uc_ib_iu3_invalid[0:`THREADS-1];
   wire [0:1]                        uc_ib_val[0:`THREADS-1];
   wire [0:31]                       uc_ib_instr0[0:`THREADS-1];
   wire [0:31]                       uc_ib_instr1[0:`THREADS-1];
   wire [62-`EFF_IFAR_WIDTH:61]      uc_ib_ifar0[0:`THREADS-1];
   wire [62-`EFF_IFAR_WIDTH:61]      uc_ib_ifar1[0:`THREADS-1];
   wire [0:3]                        uc_ib_ext0[0:`THREADS-1];
   wire [0:3]                        uc_ib_ext1[0:`THREADS-1];

   wire [0:31]                       unit_dbg_data0;
   wire [0:31]                       unit_dbg_data1;
   wire [0:31]                       unit_dbg_data2;
   wire [0:31]                       unit_dbg_data3;
   wire [0:31]                       unit_dbg_data4;
   wire [0:31]                       unit_dbg_data5;
   wire [0:31]                       unit_dbg_data6;
   wire [0:31]                       unit_dbg_data7;
   wire [0:31]                       unit_dbg_data8;
   wire [0:31]                       unit_dbg_data9;
   wire [0:31]                       unit_dbg_data10;
   wire [0:31]                       unit_dbg_data11;
   wire [0:31]                       unit_dbg_data12;
   wire [0:31]                       unit_dbg_data13;
   wire [0:31]                       unit_dbg_data14;
   wire [0:31]                       unit_dbg_data15;

   wire                              vdd;
   wire                              gnd;

   assign vdd = 1'b1;
   assign gnd = 1'b0;

   assign iu_lq_spr_iucr0_icbi_ack = spr_ic_icbi_ack_en;
   assign d_mode = 1'b0;
   assign mpw2_b = 1'b1;
   assign spr_single_issue = spr_single_issue_int;
   assign spr_ic_ierat_byp_dis = 1'b0;

   iuq_spr  iuq_spr0(
      .vdd(vdd),
      .gnd(gnd),
      .iu_slowspr_val_in(iu_slowspr_val_in),
      .iu_slowspr_rw_in(iu_slowspr_rw_in),
      .iu_slowspr_etid_in(iu_slowspr_etid_in),
      .iu_slowspr_addr_in(iu_slowspr_addr_in),
      .iu_slowspr_data_in(iu_slowspr_data_in),
      .iu_slowspr_done_in(iu_slowspr_done_in),
      .iu_slowspr_val_out(iu_slowspr_val_out),
      .iu_slowspr_rw_out(iu_slowspr_rw_out),
      .iu_slowspr_etid_out(iu_slowspr_etid_out),
      .iu_slowspr_addr_out(iu_slowspr_addr_out),
      .iu_slowspr_data_out(iu_slowspr_data_out),
      .iu_slowspr_done_out(iu_slowspr_done_out),
      .cp_flush(cp_flush),
      .spr_ic_bp_config(spr_ic_bp_config),
      .spr_bp_config(spr_bp_config),
      .spr_bp_size(spr_bp_size),
      .spr_dec_mask(spr_dec_mask),
      .spr_dec_match(spr_dec_match),
      .spr_single_issue(spr_single_issue_int),
      .iu_au_t0_config_iucr(iu_au_t0_config_iucr),
   `ifndef THREADS1
      .iu_au_t1_config_iucr(iu_au_t1_config_iucr),
   `endif
      .spr_high_pri_mask(spr_high_pri_mask),
      .spr_med_pri_mask(spr_med_pri_mask),
      .spr_t0_low_pri_count(spr_t0_low_pri_count),
   `ifndef THREADS1
      .spr_t1_low_pri_count(spr_t1_low_pri_count),
   `endif
      .xu_iu_raise_iss_pri(xu_iu_raise_iss_pri),
      .xu_iu_pri_val(xu_iu_pri_val),
      .xu_iu_pri(xu_iu_pri),
      .spr_msr_gs(xu_iu_msr_gs),
      .spr_msr_pr(xu_iu_msr_pr),
      .spr_ivpr(spr_ivpr),
      .spr_givpr(spr_givpr),
      .spr_iac1(spr_iac1),
      .spr_iac2(spr_iac2),
      .spr_iac3(spr_iac3),
      .spr_iac4(spr_iac4),
      .spr_cpcr_we(spr_cpcr_we),
      .spr_t0_cpcr2_fx0_cnt(spr_t0_cpcr2_fx0_cnt),
      .spr_t0_cpcr2_fx1_cnt(spr_t0_cpcr2_fx1_cnt),
      .spr_t0_cpcr2_lq_cnt(spr_t0_cpcr2_lq_cnt),
      .spr_t0_cpcr2_sq_cnt(spr_t0_cpcr2_sq_cnt),
      .spr_t0_cpcr3_fu0_cnt(spr_t0_cpcr3_fu0_cnt),
      .spr_t0_cpcr3_fu1_cnt(spr_t0_cpcr3_fu1_cnt),
      .spr_t0_cpcr3_cp_cnt(spr_t0_cpcr3_cp_cnt),
      .spr_t0_cpcr4_fx0_cnt(spr_t0_cpcr4_fx0_cnt),
      .spr_t0_cpcr4_fx1_cnt(spr_t0_cpcr4_fx1_cnt),
      .spr_t0_cpcr4_lq_cnt(spr_t0_cpcr4_lq_cnt),
      .spr_t0_cpcr4_sq_cnt(spr_t0_cpcr4_sq_cnt),
      .spr_t0_cpcr5_fu0_cnt(spr_t0_cpcr5_fu0_cnt),
      .spr_t0_cpcr5_fu1_cnt(spr_t0_cpcr5_fu1_cnt),
      .spr_t0_cpcr5_cp_cnt(spr_t0_cpcr5_cp_cnt),
   `ifndef THREADS1
      .spr_t1_cpcr2_fx0_cnt(spr_t1_cpcr2_fx0_cnt),
      .spr_t1_cpcr2_fx1_cnt(spr_t1_cpcr2_fx1_cnt),
      .spr_t1_cpcr2_lq_cnt(spr_t1_cpcr2_lq_cnt),
      .spr_t1_cpcr2_sq_cnt(spr_t1_cpcr2_sq_cnt),
      .spr_t1_cpcr3_fu0_cnt(spr_t1_cpcr3_fu0_cnt),
      .spr_t1_cpcr3_fu1_cnt(spr_t1_cpcr3_fu1_cnt),
      .spr_t1_cpcr3_cp_cnt(spr_t1_cpcr3_cp_cnt),
      .spr_t1_cpcr4_fx0_cnt(spr_t1_cpcr4_fx0_cnt),
      .spr_t1_cpcr4_fx1_cnt(spr_t1_cpcr4_fx1_cnt),
      .spr_t1_cpcr4_lq_cnt(spr_t1_cpcr4_lq_cnt),
      .spr_t1_cpcr4_sq_cnt(spr_t1_cpcr4_sq_cnt),
      .spr_t1_cpcr5_fu0_cnt(spr_t1_cpcr5_fu0_cnt),
      .spr_t1_cpcr5_fu1_cnt(spr_t1_cpcr5_fu1_cnt),
      .spr_t1_cpcr5_cp_cnt(spr_t1_cpcr5_cp_cnt),
   `endif
      .spr_cpcr0_fx0_cnt(spr_cpcr0_fx0_cnt),
      .spr_cpcr0_fx1_cnt(spr_cpcr0_fx1_cnt),
      .spr_cpcr0_lq_cnt(spr_cpcr0_lq_cnt),
      .spr_cpcr0_sq_cnt(spr_cpcr0_sq_cnt),
      .spr_cpcr1_fu0_cnt(spr_cpcr1_fu0_cnt),
      .spr_cpcr1_fu1_cnt(spr_cpcr1_fu1_cnt),
      .iu_spr_eheir_update(iu_spr_eheir_update),
      .iu_spr_t0_eheir(iu_spr_t0_eheir),
   `ifndef THREADS1
      .iu_spr_t1_eheir(iu_spr_t1_eheir),
   `endif
      .spr_ic_idir_read(spr_ic_idir_read),
      .spr_ic_idir_way(spr_ic_idir_way),
      .spr_ic_idir_row(spr_ic_idir_row),
      .ic_spr_idir_done(ic_spr_idir_done),
      .ic_spr_idir_lru(ic_spr_idir_lru),
      .ic_spr_idir_parity(ic_spr_idir_parity),
      .ic_spr_idir_endian(ic_spr_idir_endian),
      .ic_spr_idir_valid(ic_spr_idir_valid),
      .ic_spr_idir_tag(ic_spr_idir_tag),
      .spr_ic_icbi_ack_en(spr_ic_icbi_ack_en),
      .spr_ic_cls(spr_ic_cls),
      .spr_ic_clockgate_dis(spr_ic_clockgate_dis),
      .spr_ic_prefetch_dis(spr_ic_prefetch_dis),
      .spr_perf_event_mux_ctrls(spr_perf_event_mux_ctrls),
      .spr_cp_perf_event_mux_ctrls(spr_cp_perf_event_mux_ctrls),
      .nclk(nclk),
      .pc_iu_sg_2(pc_iu_sg_2),
      .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
      .clkoff_b(clkoff_b),
      .act_dis(act_dis),
      .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scan_in(spr_scan_in),
      .scan_out(spr_scan_out)
   );


   iuq_ic  iuq_ic0(
      .vcs(vdd),
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
      .tc_ac_scan_dis_dc_b(tc_ac_scan_dis_dc_b),
      .tc_ac_scan_diag_dc(tc_ac_scan_diag_dc),
      .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
      .pc_iu_func_slp_sl_thold_2(pc_iu_func_slp_sl_thold_2),
      .pc_iu_func_nsl_thold_2(pc_iu_func_nsl_thold_2),
      .pc_iu_cfg_slp_sl_thold_2(pc_iu_cfg_slp_sl_thold_2),
      .pc_iu_regf_slp_sl_thold_2(pc_iu_regf_slp_sl_thold_2),
      .pc_iu_time_sl_thold_2(pc_iu_time_sl_thold_2),
      .pc_iu_abst_sl_thold_2(pc_iu_abst_sl_thold_2),
      .pc_iu_abst_slp_sl_thold_2(pc_iu_abst_slp_sl_thold_2),
      .pc_iu_repr_sl_thold_2(pc_iu_repr_sl_thold_2),
      .pc_iu_ary_nsl_thold_2(pc_iu_ary_nsl_thold_2),
      .pc_iu_ary_slp_nsl_thold_2(pc_iu_ary_slp_nsl_thold_2),
      .pc_iu_func_slp_nsl_thold_2(pc_iu_func_slp_nsl_thold_2),
      .pc_iu_bolt_sl_thold_2(pc_iu_bolt_sl_thold_2),
      .pc_iu_sg_2(pc_iu_sg_2),
      .pc_iu_fce_2(pc_iu_fce_2),
      .clkoff_b(clkoff_b),
      .act_dis(act_dis),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
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
      .cam_clkoff_b(cam_clkoff_b),
      .cam_act_dis(cam_act_dis),
      .cam_d_mode(cam_d_mode),
      .cam_delay_lclkr(cam_delay_lclkr),
      .cam_mpw1_b(cam_mpw1_b),
      .cam_mpw2_b(cam_mpw2_b),
      .func_scan_in(func_scan_in),
      .func_scan_out(func_scan_out),
      .ac_ccfg_scan_in(ac_ccfg_scan_in),
      .ac_ccfg_scan_out(ac_ccfg_scan_out),
      .time_scan_in(time_scan_in),
      .time_scan_out(time_scan_out),
      .repr_scan_in(repr_scan_in),
      .repr_scan_out(repr_scan_out),
      .abst_scan_in(abst_scan_in),
      .abst_scan_out(abst_scan_out),
      .regf_scan_in(regf_scan_in),
      .regf_scan_out(regf_scan_out),
      .iu_pc_err_icache_parity(iu_pc_err_icache_parity),
      .iu_pc_err_icachedir_parity(iu_pc_err_icachedir_parity),
      .iu_pc_err_icachedir_multihit(iu_pc_err_icachedir_multihit),
      .iu_pc_err_ierat_multihit(iu_pc_err_ierat_multihit),
      .iu_pc_err_ierat_parity(iu_pc_err_ierat_parity),
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
      .an_ac_lbist_en_dc(an_ac_lbist_en_dc),
      .an_ac_atpg_en_dc(an_ac_atpg_en_dc),
      .an_ac_grffence_en_dc(an_ac_grffence_en_dc),
      .pc_iu_bo_enable_3(pc_iu_bo_enable_3),
      .pc_iu_bo_reset(pc_iu_bo_reset),
      .pc_iu_bo_unload(pc_iu_bo_unload),
      .pc_iu_bo_repair(pc_iu_bo_repair),
      .pc_iu_bo_shdata(pc_iu_bo_shdata),
      .pc_iu_bo_select(pc_iu_bo_select),
      .iu_pc_bo_fail(iu_pc_bo_fail),
      .iu_pc_bo_diagout(iu_pc_bo_diagout),
      .lq_iu_icbi_val(lq_iu_icbi_val),
      .lq_iu_icbi_addr(lq_iu_icbi_addr),
      .iu_lq_icbi_complete(iu_lq_icbi_complete),
      .lq_iu_ici_val(lq_iu_ici_val),
      .pc_iu_init_reset(pc_iu_init_reset),
      .xu_iu_val(xu_iu_val),
      .xu_iu_is_eratre(xu_iu_is_eratre),
      .xu_iu_is_eratwe(xu_iu_is_eratwe),
      .xu_iu_is_eratsx(xu_iu_is_eratsx),
      .xu_iu_is_eratilx(xu_iu_is_eratilx),
      .cp_is_isync(cp_is_isync),
      .cp_is_csync(cp_is_csync),
      .xu_iu_ws(xu_iu_ws),
      .xu_iu_ra_entry(xu_iu_ra_entry),
      .xu_iu_rb(xu_iu_rb),
      .xu_iu_rs_data(xu_iu_rs_data),
      .iu_xu_ord_read_done(iu_xu_ord_read_done),
      .iu_xu_ord_write_done(iu_xu_ord_write_done),
      .iu_xu_ord_par_err(iu_xu_ord_par_err),
      .iu_xu_ord_n_flush_req(iu_xu_ord_n_flush_req),
      .xu_iu_msr_hv(xu_iu_msr_gs),
      .xu_iu_msr_pr(xu_iu_msr_pr),
      .xu_iu_msr_is(xu_iu_msr_is),
      .xu_iu_hid_mmu_mode(xu_iu_hid_mmu_mode),
      .xu_iu_spr_ccr2_ifrat(xu_iu_spr_ccr2_ifrat),
      .xu_iu_spr_ccr2_ifratsc(xu_iu_spr_ccr2_ifratsc),
      .xu_iu_xucr4_mmu_mchk(xu_iu_xucr4_mmu_mchk),
      .iu_xu_ex5_data(iu_xu_ex5_data),
      .iu_mm_ierat_req(iu_mm_ierat_req),
      .iu_mm_ierat_req_nonspec(iu_mm_ierat_req_nonspec),
      .iu_mm_ierat_epn(iu_mm_ierat_epn),
      .iu_mm_ierat_thdid(iu_mm_ierat_thdid),
      .iu_mm_ierat_state(iu_mm_ierat_state),
      .iu_mm_ierat_tid(iu_mm_ierat_tid),
      .iu_mm_ierat_flush(iu_mm_ierat_flush),
      .iu_mm_perf_itlb(iu_mm_perf_itlb),
      .mm_iu_ierat_rel_val(mm_iu_ierat_rel_val),
      .mm_iu_ierat_rel_data(mm_iu_ierat_rel_data),
      .mm_iu_t0_ierat_pid(mm_iu_t0_ierat_pid),
      .mm_iu_t0_ierat_mmucr0(mm_iu_t0_ierat_mmucr0),
   `ifndef THREADS1
      .mm_iu_t1_ierat_pid(mm_iu_t1_ierat_pid),
      .mm_iu_t1_ierat_mmucr0(mm_iu_t1_ierat_mmucr0),
   `endif
      .iu_mm_ierat_mmucr0(iu_mm_ierat_mmucr0),
      .iu_mm_ierat_mmucr0_we(iu_mm_ierat_mmucr0_we),
      .mm_iu_ierat_mmucr1(mm_iu_ierat_mmucr1),
      .iu_mm_ierat_mmucr1(iu_mm_ierat_mmucr1),
      .iu_mm_ierat_mmucr1_we(iu_mm_ierat_mmucr1_we),
      .mm_iu_ierat_snoop_coming(mm_iu_ierat_snoop_coming),
      .mm_iu_ierat_snoop_val(mm_iu_ierat_snoop_val),
      .mm_iu_ierat_snoop_attr(mm_iu_ierat_snoop_attr),
      .mm_iu_ierat_snoop_vpn(mm_iu_ierat_snoop_vpn),
      .iu_mm_ierat_snoop_ack(iu_mm_ierat_snoop_ack),
      .mm_iu_hold_req(mm_iu_hold_req),
      .mm_iu_hold_done(mm_iu_hold_done),
      .mm_iu_bus_snoop_hold_req(mm_iu_bus_snoop_hold_req),
      .mm_iu_bus_snoop_hold_done(mm_iu_bus_snoop_hold_done),
      .pc_iu_ram_active(pc_iu_ram_active),
      .pc_iu_pm_fetch_halt(pc_iu_pm_fetch_halt),
      .xu_iu_run_thread(xu_iu_run_thread),
      .cp_ic_stop(cp_ic_stop),
      .xu_iu_msr_cm(xu_iu_msr_cm),
      .iu_flush(iu_flush),
      .br_iu_redirect(br_iu_redirect),
      .br_iu_bta(br_iu_bta),
      .cp_flush(cp_flush),
      .cp_flush_into_uc(cp_flush_into_uc),
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
      .spr_ic_bp_config(spr_ic_bp_config),
      .spr_ic_cls(spr_ic_cls),
      .spr_ic_prefetch_dis(spr_ic_prefetch_dis),
      .spr_ic_ierat_byp_dis(spr_ic_ierat_byp_dis),
      .spr_ic_idir_read(spr_ic_idir_read),
      .spr_ic_idir_way(spr_ic_idir_way),
      .spr_ic_idir_row(spr_ic_idir_row),
      .ic_spr_idir_done(ic_spr_idir_done),
      .ic_spr_idir_lru(ic_spr_idir_lru),
      .ic_spr_idir_parity(ic_spr_idir_parity),
      .ic_spr_idir_endian(ic_spr_idir_endian),
      .ic_spr_idir_valid(ic_spr_idir_valid),
      .ic_spr_idir_tag(ic_spr_idir_tag),
      .iu_lq_request(iu_lq_request),
      .iu_lq_ctag(iu_lq_ctag),
      .iu_lq_ra(iu_lq_ra),
      .iu_lq_wimge(iu_lq_wimge),
      .iu_lq_userdef(iu_lq_userdef),
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
      .bp_ic_iu2_redirect(bp_ic_iu2_redirect),
      .bp_ic_iu3_redirect(bp_ic_iu3_redirect),
      .bp_ic_iu4_redirect(bp_ic_iu4_redirect),
      .bp_ic_t0_redirect_ifar(bp_ic_redirect_ifar[0]),
   `ifndef THREADS1
      .bp_ic_t1_redirect_ifar(bp_ic_redirect_ifar[1]),
   `endif
      .ic_bp_iu0_val(ic_bp_iu0_val),
      .ic_bp_iu0_ifar(ic_bp_iu0_ifar),
      .ic_bp_iu2_t0_val(ic_bp_iu2_val[0]),
   `ifndef THREADS1
      .ic_bp_iu2_t1_val(ic_bp_iu2_val[1]),
   `endif
      .ic_bp_iu2_ifar(ic_bp_iu2_ifar),
      .ic_bp_iu2_2ucode(ic_bp_iu2_2ucode),
      .ic_bp_iu2_2ucode_type(ic_bp_iu2_2ucode_type),
      .ic_bp_iu2_error(ic_bp_iu2_error),
      .ic_bp_iu2_flush(ic_bp_iu2_flush),
      .ic_bp_iu3_flush(ic_bp_iu3_flush),
      .ic_bp_iu2_0_instr(ic_bp_iu2_0_instr),
      .ic_bp_iu2_1_instr(ic_bp_iu2_1_instr),
      .ic_bp_iu2_2_instr(ic_bp_iu2_2_instr),
      .ic_bp_iu2_3_instr(ic_bp_iu2_3_instr),
      .ic_bp_iu3_ecc_err(ic_bp_iu3_ecc_err),
      .ib_ic_t0_need_fetch(ib_ic_t0_need_fetch),
   `ifndef THREADS1
      .ib_ic_t1_need_fetch(ib_ic_t1_need_fetch),
   `endif
      .uc_iu4_flush(uc_iu4_flush),
      .uc_iu4_t0_flush_ifar(uc_iu4_flush_ifar[0]),
   `ifndef THREADS1
      .uc_iu4_t1_flush_ifar(uc_iu4_flush_ifar[1]),
   `endif
      .uc_ic_hold(uc_ic_hold),
      .pc_iu_event_bus_enable(pc_iu_event_bus_enable),
      .pc_iu_event_count_mode(pc_iu_event_count_mode),
      .spr_perf_event_mux_ctrls(spr_perf_event_mux_ctrls[0:24*`THREADS-1]),
      .slice_ic_t0_perf_events(slice_ic_t0_perf_events),
   `ifndef THREADS1
      .slice_ic_t1_perf_events(slice_ic_t1_perf_events),
   `endif
      .event_bus_in(event_bus_in),
      .event_bus_out(event_bus_out)
   );


   generate
   begin : xhdl0
     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : bp_gen
        iuq_bp  iuq_bp0(
               .iu2_0_bh0_rd_data(iu2_0_bh0_rd_data),
               .iu2_1_bh0_rd_data(iu2_1_bh0_rd_data),
               .iu2_2_bh0_rd_data(iu2_2_bh0_rd_data),
               .iu2_3_bh0_rd_data(iu2_3_bh0_rd_data),
               .iu2_0_bh1_rd_data(iu2_0_bh1_rd_data),
               .iu2_1_bh1_rd_data(iu2_1_bh1_rd_data),
               .iu2_2_bh1_rd_data(iu2_2_bh1_rd_data),
               .iu2_3_bh1_rd_data(iu2_3_bh1_rd_data),
               .iu2_0_bh2_rd_data(iu2_0_bh2_rd_data),
               .iu2_1_bh2_rd_data(iu2_1_bh2_rd_data),
               .iu2_2_bh2_rd_data(iu2_2_bh2_rd_data),
               .iu2_3_bh2_rd_data(iu2_3_bh2_rd_data),
               .iu0_bh0_rd_addr(iu0_bh0_rd_addr_int[i]),
               .iu0_bh1_rd_addr(iu0_bh1_rd_addr_int[i]),
               .iu0_bh2_rd_addr(iu0_bh2_rd_addr_int[i]),
               .iu0_bh0_rd_act(iu0_bh0_rd_act_int[i]),
               .iu0_bh1_rd_act(iu0_bh1_rd_act_int[i]),
               .iu0_bh2_rd_act(iu0_bh2_rd_act_int[i]),
               .ex5_bh0_wr_data(ex5_bh0_wr_data_int[i]),
               .ex5_bh1_wr_data(ex5_bh1_wr_data_int[i]),
               .ex5_bh2_wr_data(ex5_bh2_wr_data_int[i]),
               .ex5_bh0_wr_addr(ex5_bh0_wr_addr_int[i]),
               .ex5_bh1_wr_addr(ex5_bh1_wr_addr_int[i]),
               .ex5_bh2_wr_addr(ex5_bh2_wr_addr_int[i]),
               .ex5_bh0_wr_act(ex5_bh0_wr_act_int[i]),
               .ex5_bh1_wr_act(ex5_bh1_wr_act_int[i]),
               .ex5_bh2_wr_act(ex5_bh2_wr_act_int[i]),
               .iu0_btb_rd_addr(iu0_btb_rd_addr_int[i]),
               .iu0_btb_rd_act(iu0_btb_rd_act_int[i]),
               .iu2_btb_rd_data(iu2_btb_rd_data),
               .ex5_btb_wr_addr(ex5_btb_wr_addr_int[i]),
               .ex5_btb_wr_act(ex5_btb_wr_act_int[i]),
               .ex5_btb_wr_data(ex5_btb_wr_data_int[i]),
               .ic_bp_iu0_val(ic_bp_iu0_val[i]),
               .ic_bp_iu0_ifar(ic_bp_iu0_ifar),
               .ic_bp_iu2_val(ic_bp_iu2_val[i]),
               .ic_bp_iu2_ifar(ic_bp_iu2_ifar),
               .ic_bp_iu2_error(ic_bp_iu2_error),
               .ic_bp_iu2_2ucode(ic_bp_iu2_2ucode),
               .ic_bp_iu2_flush(ic_bp_iu2_flush[i]),
               .ic_bp_iu3_flush(ic_bp_iu3_flush[i]),
               .ic_bp_iu2_0_instr(ic_bp_iu2_0_instr),
               .ic_bp_iu2_1_instr(ic_bp_iu2_1_instr),
               .ic_bp_iu2_2_instr(ic_bp_iu2_2_instr),
               .ic_bp_iu2_3_instr(ic_bp_iu2_3_instr),
               .ic_bp_iu3_ecc_err(ic_bp_iu3_ecc_err),
               .bp_ib_iu3_val(bp_ib_iu3_val_int[i]),
               .bp_ib_iu3_ifar(bp_ib_iu3_ifar[i]),
               .bp_ib_iu3_bta(bp_ib_iu3_bta[i]),
               .bp_ib_iu3_0_instr(bp_ib_iu3_0_instr[i]),
               .bp_ib_iu3_1_instr(bp_ib_iu3_1_instr[i]),
               .bp_ib_iu3_2_instr(bp_ib_iu3_2_instr[i]),
               .bp_ib_iu3_3_instr(bp_ib_iu3_3_instr[i]),
               .bp_ic_iu2_redirect(bp_ic_iu2_redirect[i]),
               .bp_ic_iu3_redirect(bp_ic_iu3_redirect[i]),
               .bp_ic_iu4_redirect(bp_ic_iu4_redirect[i]),
               .bp_ic_redirect_ifar(bp_ic_redirect_ifar[i]),
               .cp_bp_ifar(cp_bp_ifar[i]),
               .cp_bp_val(cp_bp_val[i]),
               .cp_bp_bh0_hist(cp_bp_bh0_hist[i]),
               .cp_bp_bh1_hist(cp_bp_bh1_hist[i]),
               .cp_bp_bh2_hist(cp_bp_bh2_hist[i]),
               .cp_bp_br_pred(cp_bp_br_pred[i]),
               .cp_bp_br_taken(cp_bp_br_taken[i]),
               .cp_bp_bh_update(cp_bp_bh_update[i]),
               .cp_bp_bcctr(cp_bp_bcctr[i]),
               .cp_bp_bclr(cp_bp_bclr[i]),
               .cp_bp_getNIA(cp_bp_getNIA[i]),
               .cp_bp_group(cp_bp_group[i]),
               .cp_bp_lk(cp_bp_lk[i]),
               .cp_bp_bh(cp_bp_bh[i]),
               .cp_bp_bta(cp_bp_bta[i]),
               .cp_bp_gshare(cp_bp_gshare[i]),
               .cp_bp_ls_ptr(cp_bp_ls_ptr[i]),
               .cp_bp_btb_entry(cp_bp_btb_entry[i]),
               .cp_bp_btb_hist(cp_bp_btb_hist[i]),
               .br_iu_gshare(br_iu_gshare),
               .br_iu_ls_ptr(br_iu_ls_ptr),
               .br_iu_ls_data(br_iu_ls_data),
               .br_iu_ls_update(br_iu_ls_update),
               .iu_flush(iu_flush[i]),
               .br_iu_redirect(br_iu_redirect[i]),
               .cp_flush(cp_flush[i]),
               .ib_ic_iu4_redirect(1'b0),
               .uc_iu4_flush(uc_iu4_flush[i]),
               .spr_bp_config(spr_bp_config),
               .spr_bp_size(spr_bp_size),
               .xu_iu_msr_de(xu_iu_msr_de[i]),
               .xu_iu_dbcr0_icmp(xu_iu_dbcr0_icmp[i]),
               .xu_iu_dbcr0_brt(xu_iu_dbcr0_brt[i]),
               .xu_iu_iac1_en(xu_iu_iac1_en[i]),
               .xu_iu_iac2_en(xu_iu_iac2_en[i]),
               .xu_iu_iac3_en(xu_iu_iac3_en[i]),
               .xu_iu_iac4_en(xu_iu_iac4_en[i]),
               .lq_iu_spr_dbcr3_ivc(lq_iu_spr_dbcr3_ivc[i]),
               .xu_iu_single_instr_mode(xu_iu_single_instr_mode[i]),
               .spr_single_issue(spr_single_issue_int[i]),
               .vdd(vdd),
               .gnd(gnd),
               .nclk(nclk),
               .pc_iu_sg_2(pc_iu_sg_2),
               .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
               .clkoff_b(clkoff_b),
               .act_dis(act_dis),
               .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
               .d_mode(d_mode),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .scan_in(bp_scan_in[2 * i:2 * i + 1]),
               .scan_out(bp_scan_out[2 * i:2 * i + 1])
        );
     end
   end
   endgenerate


/*   always @(iu0_bh0_rd_addr_int or iu0_bh0_rd_act_int or iu0_bh1_rd_addr_int or iu0_bh1_rd_act_int or iu0_bh2_rd_addr_int or iu0_bh2_rd_act_int or ex5_bh0_wr_data_int or ex5_bh0_wr_act_int or ex5_bh1_wr_data_int or ex5_bh1_wr_act_int or ex5_bh2_wr_data_int or ex5_bh2_wr_act_int or ex5_bh0_wr_addr_int or ex5_bh1_wr_addr_int or ex5_bh2_wr_addr_int or iu0_btb_rd_addr_int or iu0_btb_rd_act_int or ex5_btb_wr_addr_int or ex5_btb_wr_act_int or ex5_btb_wr_data_int or bp_ib_iu3_ifar or bp_ib_iu3_val_int or bp_ib_iu3_bta or bp_ib_iu3_0_instr or bp_ib_iu3_1_instr or bp_ib_iu3_2_instr or bp_ib_iu3_3_instr)
*/
   always @ (*)
   begin: or_proc
      reg [0:9]                         iu0_bh0_rd_addr_calc;
      reg [0:9]                         iu0_bh1_rd_addr_calc;
      reg [0:8]                         iu0_bh2_rd_addr_calc;
      reg [0:1]                         ex5_bh0_wr_data_calc;
      reg [0:1]                         ex5_bh1_wr_data_calc;
      reg                               ex5_bh2_wr_data_calc;
      reg [0:9]                         ex5_bh0_wr_addr_calc;
      reg [0:9]                         ex5_bh1_wr_addr_calc;
      reg [0:8]                         ex5_bh2_wr_addr_calc;
      reg [0:5]                         iu0_btb_rd_addr_calc;
      reg [0:5]                         ex5_btb_wr_addr_calc;
      reg [0:63]                        ex5_btb_wr_data_calc;
      reg [0:3]                         ex5_bh0_wr_act_calc;
      reg [0:3]                         ex5_bh1_wr_act_calc;
      reg [0:3]                         ex5_bh2_wr_act_calc;
      reg                               ex5_btb_wr_act_calc;
      reg                               iu0_bh0_rd_act_calc;
      reg                               iu0_bh1_rd_act_calc;
      reg                               iu0_bh2_rd_act_calc;
      reg                               iu0_btb_rd_act_calc;
       (* analysis_not_referenced="true" *)
      integer                           i;

      iu0_bh0_rd_addr_calc = 10'b0;
      iu0_bh1_rd_addr_calc = 10'b0;
      iu0_bh2_rd_addr_calc = 9'b0;
      ex5_bh0_wr_data_calc = 2'b0;
      ex5_bh1_wr_data_calc = 2'b0;
      ex5_bh2_wr_data_calc = 1'b0;
      ex5_bh0_wr_addr_calc = 10'b0;
      ex5_bh1_wr_addr_calc = 10'b0;
      ex5_bh2_wr_addr_calc = 9'b0;
      iu0_btb_rd_addr_calc = 6'b0;
      ex5_btb_wr_addr_calc = 6'b0;
      ex5_btb_wr_data_calc = 64'b0;
      ex5_bh0_wr_act_calc = 4'b0;
      ex5_bh1_wr_act_calc = 4'b0;
      ex5_bh2_wr_act_calc = 4'b0;
      ex5_btb_wr_act_calc = 1'b0;
      iu0_bh0_rd_act_calc = 1'b0;
      iu0_bh1_rd_act_calc = 1'b0;
      iu0_bh2_rd_act_calc = 1'b0;
      iu0_btb_rd_act_calc = 1'b0;

      for (i = 0; i < `THREADS; i = i + 1)
      begin

         iu0_bh0_rd_addr_calc = iu0_bh0_rd_addr_calc | (iu0_bh0_rd_addr_int[i] & {10{ic_bp_iu0_val[i]}});
         iu0_bh1_rd_addr_calc = iu0_bh1_rd_addr_calc | (iu0_bh1_rd_addr_int[i] & {10{ic_bp_iu0_val[i]}});
         iu0_bh2_rd_addr_calc = iu0_bh2_rd_addr_calc | (iu0_bh2_rd_addr_int[i] & {9{ic_bp_iu0_val[i]}});
         ex5_bh0_wr_data_calc = ex5_bh0_wr_data_calc | (ex5_bh0_wr_data_int[i] & {2{ (|(ex5_bh0_wr_act_int[i]))}});
         ex5_bh1_wr_data_calc = ex5_bh1_wr_data_calc | (ex5_bh1_wr_data_int[i] & {2{ (|(ex5_bh1_wr_act_int[i]))}});
         ex5_bh2_wr_data_calc = ex5_bh2_wr_data_calc | (ex5_bh2_wr_data_int[i] & {1{ (|(ex5_bh2_wr_act_int[i]))}});
         ex5_bh0_wr_addr_calc = ex5_bh0_wr_addr_calc | (ex5_bh0_wr_addr_int[i] & {10{ (|(ex5_bh0_wr_act_int[i]))}});
         ex5_bh1_wr_addr_calc = ex5_bh1_wr_addr_calc | (ex5_bh1_wr_addr_int[i] & {10{ (|(ex5_bh1_wr_act_int[i]))}});
         ex5_bh2_wr_addr_calc = ex5_bh2_wr_addr_calc | (ex5_bh2_wr_addr_int[i] & {9{ (|(ex5_bh2_wr_act_int[i]))}});
	 iu0_btb_rd_addr_calc = iu0_btb_rd_addr_calc | (iu0_btb_rd_addr_int[i] & {6{ic_bp_iu0_val[i]}});
	 ex5_btb_wr_addr_calc = ex5_btb_wr_addr_calc | (ex5_btb_wr_addr_int[i] & {6{ex5_btb_wr_act_int[i]}});
         ex5_btb_wr_data_calc = ex5_btb_wr_data_calc | (ex5_btb_wr_data_int[i] & {64{ex5_btb_wr_act_int[i]}});

	 ex5_bh0_wr_act_calc = (ex5_bh0_wr_act_calc & {4{~|(ex5_bh0_wr_act_int[i])}}) | ((ex5_bh0_wr_act_int[i]) & {4{~|(ex5_bh0_wr_act_calc)}});
         ex5_bh1_wr_act_calc = (ex5_bh1_wr_act_calc & {4{~|(ex5_bh1_wr_act_int[i])}}) | ((ex5_bh1_wr_act_int[i]) & {4{~|(ex5_bh1_wr_act_calc)}});
         ex5_bh2_wr_act_calc = (ex5_bh2_wr_act_calc & {4{~|(ex5_bh2_wr_act_int[i])}}) | ((ex5_bh2_wr_act_int[i]) & {4{~|(ex5_bh2_wr_act_calc)}});

         ex5_btb_wr_act_calc = ex5_btb_wr_act_calc ^ ex5_btb_wr_act_int[i];
         iu0_bh0_rd_act_calc = iu0_bh0_rd_act_calc ^ iu0_bh0_rd_act_int[i];
         iu0_bh1_rd_act_calc = iu0_bh1_rd_act_calc ^ iu0_bh1_rd_act_int[i];
         iu0_bh2_rd_act_calc = iu0_bh2_rd_act_calc ^ iu0_bh2_rd_act_int[i];
         iu0_btb_rd_act_calc = iu0_btb_rd_act_calc ^ iu0_btb_rd_act_int[i];

      end
      iu0_bh0_rd_addr <= iu0_bh0_rd_addr_calc;
      iu0_bh1_rd_addr <= iu0_bh1_rd_addr_calc;
      iu0_bh2_rd_addr <= iu0_bh2_rd_addr_calc;
      ex5_bh0_wr_data <= ex5_bh0_wr_data_calc;
      ex5_bh1_wr_data <= ex5_bh1_wr_data_calc;
      ex5_bh2_wr_data <= ex5_bh2_wr_data_calc;
      ex5_bh0_wr_addr <= ex5_bh0_wr_addr_calc;
      ex5_bh1_wr_addr <= ex5_bh1_wr_addr_calc;
      ex5_bh2_wr_addr <= ex5_bh2_wr_addr_calc;
      iu0_btb_rd_addr <= iu0_btb_rd_addr_calc;
      ex5_btb_wr_addr <= ex5_btb_wr_addr_calc;
      ex5_btb_wr_data <= ex5_btb_wr_data_calc;
      ex5_bh0_wr_act <= ex5_bh0_wr_act_calc;
      ex5_bh1_wr_act <= ex5_bh1_wr_act_calc;
      ex5_bh2_wr_act <= ex5_bh2_wr_act_calc;
      ex5_btb_wr_act <= ex5_btb_wr_act_calc;
      iu0_bh0_rd_act <= iu0_bh0_rd_act_calc;
      iu0_bh1_rd_act <= iu0_bh1_rd_act_calc;
      iu0_bh2_rd_act <= iu0_bh2_rd_act_calc;
      iu0_btb_rd_act <= iu0_btb_rd_act_calc;
   end

   // For Verilog lack of 2-D ports
   assign bp_ib_iu3_t0_val  = bp_ib_iu3_val_int[0];
   assign bp_ib_iu3_t0_ifar = bp_ib_iu3_ifar[0];
   assign bp_ib_iu3_t0_bta  = bp_ib_iu3_bta[0];
   assign bp_ib_iu3_t0_0_instr = bp_ib_iu3_0_instr[0];
   assign bp_ib_iu3_t0_1_instr = bp_ib_iu3_1_instr[0];
   assign bp_ib_iu3_t0_2_instr = bp_ib_iu3_2_instr[0];
   assign bp_ib_iu3_t0_3_instr = bp_ib_iu3_3_instr[0];
   assign cp_bp_ifar[0]     = cp_bp_t0_ifar;
   assign cp_bp_bh0_hist[0] = cp_bp_t0_bh0_hist;
   assign cp_bp_bh1_hist[0] = cp_bp_t0_bh1_hist;
   assign cp_bp_bh2_hist[0] = cp_bp_t0_bh2_hist;
   assign cp_bp_bh[0]       = cp_bp_t0_bh;
   assign cp_bp_bta[0]      = cp_bp_t0_bta;
   assign cp_bp_gshare[0]   = cp_bp_t0_gshare;
   assign cp_bp_ls_ptr[0]   = cp_bp_t0_ls_ptr;
   assign cp_bp_btb_hist[0] = cp_bp_t0_btb_hist;
   assign cp_uc_flush_ifar[0]  = cp_uc_t0_flush_ifar;
   assign uc_ib_iu3_t0_invalid = uc_ib_iu3_invalid[0];
   assign uc_ib_t0_val      = uc_ib_val[0];
   assign uc_ib_t0_instr0   = uc_ib_instr0[0];
   assign uc_ib_t0_instr1   = uc_ib_instr1[0];
   assign uc_ib_t0_ifar0    = uc_ib_ifar0[0];
   assign uc_ib_t0_ifar1    = uc_ib_ifar1[0];
   assign uc_ib_t0_ext0     = uc_ib_ext0[0];
   assign uc_ib_t0_ext1     = uc_ib_ext1[0];
 `ifndef THREADS1
   assign bp_ib_iu3_t1_val  = bp_ib_iu3_val_int[1];
   assign bp_ib_iu3_t1_ifar = bp_ib_iu3_ifar[1];
   assign bp_ib_iu3_t1_bta  = bp_ib_iu3_bta[1];
   assign bp_ib_iu3_t1_0_instr = bp_ib_iu3_0_instr[1];
   assign bp_ib_iu3_t1_1_instr = bp_ib_iu3_1_instr[1];
   assign bp_ib_iu3_t1_2_instr = bp_ib_iu3_2_instr[1];
   assign bp_ib_iu3_t1_3_instr = bp_ib_iu3_3_instr[1];
   assign cp_bp_ifar[1]     = cp_bp_t1_ifar;
   assign cp_bp_bh0_hist[1] = cp_bp_t1_bh0_hist;
   assign cp_bp_bh1_hist[1] = cp_bp_t1_bh1_hist;
   assign cp_bp_bh2_hist[1] = cp_bp_t1_bh2_hist;
   assign cp_bp_bh[1]       = cp_bp_t1_bh;
   assign cp_bp_bta[1]      = cp_bp_t1_bta;
   assign cp_bp_gshare[1]   = cp_bp_t1_gshare;
   assign cp_bp_ls_ptr[1]   = cp_bp_t1_ls_ptr;
   assign cp_bp_btb_hist[1] = cp_bp_t1_btb_hist;
   assign cp_uc_flush_ifar[1]  = cp_uc_t1_flush_ifar;
   assign uc_ib_iu3_t1_invalid = uc_ib_iu3_invalid[1];
   assign uc_ib_t1_val      = uc_ib_val[1];
   assign uc_ib_t1_instr0   = uc_ib_instr0[1];
   assign uc_ib_t1_instr1   = uc_ib_instr1[1];
   assign uc_ib_t1_ifar0    = uc_ib_ifar0[1];
   assign uc_ib_t1_ifar1    = uc_ib_ifar1[1];
   assign uc_ib_t1_ext0     = uc_ib_ext0[1];
   assign uc_ib_t1_ext1     = uc_ib_ext1[1];
 `endif


   iuq_ram  iuq_ram0(
      .pc_iu_ram_instr(pc_iu_ram_instr),
      .pc_iu_ram_instr_ext(pc_iu_ram_instr_ext),
      .pc_iu_ram_issue(pc_iu_ram_issue),
      .pc_iu_ram_active(pc_iu_ram_active),
      .iu_pc_ram_done(iu_pc_ram_done),
      .cp_flush(cp_flush),
      .ib_rm_rdy(ib_rm_rdy),
      .rm_ib_iu3_val(rm_ib_iu3_val),
      .rm_ib_iu3_instr(rm_ib_iu3_instr),
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .pc_iu_sg_2(pc_iu_sg_2),
      .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
      .clkoff_b(clkoff_b),
      .act_dis(act_dis),
      .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scan_in(ram_scan_in),
      .scan_out(ram_scan_out)
   );

   generate
   begin : xhdl1
      genvar  i;
      for (i = 0; i < `THREADS; i = i + 1)
      begin : uc_gen
         iuq_uc  iuq_uc0(
               .vdd(vdd),
               .gnd(gnd),
               .nclk(nclk),
               .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
               .pc_iu_sg_2(pc_iu_sg_2),
               .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
               .clkoff_b(clkoff_b),
               .act_dis(act_dis),
               .d_mode(d_mode),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .scan_in(uc_scan_in[i]),
               .scan_out(uc_scan_out[i]),
               .iu_pc_err_ucode_illegal(iu_pc_err_ucode_illegal[i]),
               .xu_iu_ucode_xer_val(xu_iu_ucode_xer_val[i]),
               .xu_iu_ucode_xer(xu_iu_ucode_xer),
               .iu_flush(iu_flush[i]),
               .br_iu_redirect(br_iu_redirect[i]),
               .cp_flush_into_uc(cp_flush_into_uc[i]),
               .cp_uc_np1_flush(cp_uc_np1_flush[i]),
               .cp_uc_flush_ifar(cp_uc_flush_ifar[i]),
               .cp_uc_credit_free(cp_uc_credit_free[i]),
               .cp_flush(cp_flush[i]),
               .uc_ic_hold(uc_ic_hold[i]),
               .uc_iu4_flush(uc_iu4_flush[i]),
               .uc_iu4_flush_ifar(uc_iu4_flush_ifar[i]),
               .ic_bp_iu2_val(ic_bp_iu2_val[i]),
               .ic_bp_iu2_ifar(ic_bp_iu2_ifar),
               .ic_bp_iu2_2ucode(ic_bp_iu2_2ucode),
               .ic_bp_iu2_2ucode_type(ic_bp_iu2_2ucode_type),
               .ic_bp_iu2_error(ic_bp_iu2_error[0]),
               .ic_bp_iu2_flush(ic_bp_iu2_flush[i]),
               .ic_bp_iu3_flush(ic_bp_iu3_flush[i]),
               .ic_bp_iu3_ecc_err(ic_bp_iu3_ecc_err),
               .ic_bp_iu2_0_instr(ic_bp_iu2_0_instr[0:33]),
               .ic_bp_iu2_1_instr(ic_bp_iu2_1_instr[0:33]),
               .ic_bp_iu2_2_instr(ic_bp_iu2_2_instr[0:33]),
               .ic_bp_iu2_3_instr(ic_bp_iu2_3_instr[0:33]),
               .bp_ib_iu3_val(bp_ib_iu3_val_int[i]),
               .ib_uc_rdy(ib_uc_rdy[i]),
               .uc_ib_iu3_invalid(uc_ib_iu3_invalid[i]),
               .uc_ib_iu3_flush_all(uc_ib_iu3_flush_all[i]),
               .uc_ib_val(uc_ib_val[i]),
               .uc_ib_done(uc_ib_done[i]),
               .uc_ib_instr0(uc_ib_instr0[i]),
               .uc_ib_instr1(uc_ib_instr1[i]),
               .uc_ib_ifar0(uc_ib_ifar0[i]),
               .uc_ib_ifar1(uc_ib_ifar1[i]),
               .uc_ib_ext0(uc_ib_ext0[i]),
               .uc_ib_ext1(uc_ib_ext1[i])
         );
      end
   end
   endgenerate

   //??? Temp - Need to connect
   assign unit_dbg_data0 = bp_ib_iu3_0_instr[0][0:31];
   assign unit_dbg_data1 = bp_ib_iu3_1_instr[0][0:31];
   assign unit_dbg_data2 = bp_ib_iu3_2_instr[0][0:31];
   assign unit_dbg_data3 = bp_ib_iu3_3_instr[0][0:31];
   assign unit_dbg_data4 = { {30-`EFF_IFAR_WIDTH{1'b0}}, bp_ib_iu3_ifar[0], 2'b0 };
   assign unit_dbg_data5 = { {30-`EFF_IFAR_WIDTH{1'b0}}, bp_ib_iu3_ifar[`THREADS-1], 2'b0 };
   assign unit_dbg_data6 = 32'b0;
   assign unit_dbg_data7 = 32'b0;
   assign unit_dbg_data8 = bp_ib_iu3_0_instr[`THREADS-1][0:31];
   assign unit_dbg_data9 = bp_ib_iu3_1_instr[`THREADS-1][0:31];
   assign unit_dbg_data10 = bp_ib_iu3_2_instr[`THREADS-1][0:31];
   assign unit_dbg_data11 = bp_ib_iu3_3_instr[`THREADS-1][0:31];
   assign unit_dbg_data12 = 32'b0;
   assign unit_dbg_data13 = 32'b0;
   assign unit_dbg_data14 = 32'b0;
   assign unit_dbg_data15 = 32'b0;

   iuq_dbg  iuq_dbg0(
       .vdd(vdd),
       .gnd(gnd),
       .nclk(nclk),
       .thold_2(pc_iu_func_slp_sl_thold_2),
       .pc_iu_sg_2(pc_iu_sg_2),
       .clkoff_b(clkoff_b),
       .act_dis(act_dis),
       .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
       .d_mode(d_mode),
       .delay_lclkr(delay_lclkr),
       .mpw1_b(mpw1_b),
       .mpw2_b(mpw2_b),
       .func_scan_in(dbg1_scan_in),
       .func_scan_out(dbg1_scan_out),
       .unit_dbg_data0(unit_dbg_data0),
       .unit_dbg_data1(unit_dbg_data1),
       .unit_dbg_data2(unit_dbg_data2),
       .unit_dbg_data3(unit_dbg_data3),
       .unit_dbg_data4(unit_dbg_data4),
       .unit_dbg_data5(unit_dbg_data5),
       .unit_dbg_data6(unit_dbg_data6),
       .unit_dbg_data7(unit_dbg_data7),
       .unit_dbg_data8(unit_dbg_data8),
       .unit_dbg_data9(unit_dbg_data9),
       .unit_dbg_data10(unit_dbg_data10),
       .unit_dbg_data11(unit_dbg_data11),
       .unit_dbg_data12(unit_dbg_data12),
       .unit_dbg_data13(unit_dbg_data13),
       .unit_dbg_data14(unit_dbg_data14),
       .unit_dbg_data15(unit_dbg_data15),
       .pc_iu_trace_bus_enable(pc_iu_trace_bus_enable),
       .pc_iu_debug_mux_ctrls(pc_iu_debug_mux1_ctrls),
       .debug_bus_in(debug_bus_in),
       .debug_bus_out(debug_bus_out),
       .coretrace_ctrls_in(coretrace_ctrls_in),
       .coretrace_ctrls_out(coretrace_ctrls_out)
   );

endmodule
