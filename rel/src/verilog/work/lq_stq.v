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

//
//  Description:  Store Queue
//
//*****************************************************************************

// ##########################################################################################
// Contents
// 1) Load Queue
// 2) Store
// 3) Load/Store Queue Control
// ##########################################################################################

`include "tri_a2o.vh"

  // `define                                                   `EXPAND_TYPE   2;
  // `define                                                   `GPR_WIDTH_ENC   6;		// Register Mode 5   32bit, 6   64bit
  // `define                                                   `STQ_ENTRIES   12;		// Store Queue Size
  // `define                                                   STQ_FWD_ENTRIES   4;		// number of stq entries that can be forwarded from
  // `define                                                   `STQ_ENTRIES_ENC   4;		// Store Queue Encoded Size
  // `define                                                   STQ_DATA_SIZE   64;		// 64 or 128 Bit store data sizes supported
  // `define                                                   `ITAG_SIZE_ENC   7;		// ITAG size
  // `define                                                   `CR_POOL_ENC   5;		// Encode of CR rename pool size
  // `define                                                   `GPR_POOL_ENC   6;
  // `define                                                   AXU_SPARE_ENC   3;
  // `define                                                   THREADS_POOL_ENC   1;
  // `define                                                   DC_SIZE   15;		// 14  > 16K L1D$, 15  > 32K L1D$
  // `define                                                   CL_SIZE   6;		// 6  > 64B CLINE, 7  > 128B CLINE
  // `define                                                   REAL_IFAR_WIDTH   42;		// real addressing bits
  // `define                                                   `THREADS   2;
  // `define                                                   LMQ_ENTRIES   8;

module lq_stq(
   rv_lq_rv1_i0_vld,
   rv_lq_rv1_i0_ucode_preissue,
   rv_lq_rv1_i0_s3_t,
   rv_lq_rv1_i0_rte_sq,
   rv_lq_rv1_i0_itag,
   rv_lq_rv1_i1_vld,
   rv_lq_rv1_i1_ucode_preissue,
   rv_lq_rv1_i1_s3_t,
   rv_lq_rv1_i1_rte_sq,
   rv_lq_rv1_i1_itag,
   rv_lq_vld,
   rv_lq_isLoad,
   xu1_lq_ex2_stq_val,
   xu1_lq_ex2_stq_itag,
   xu1_lq_ex2_stq_dvc1_cmp,
   xu1_lq_ex2_stq_dvc2_cmp,
   ctl_lsq_ex4_xu1_data,
   xu1_lq_ex3_illeg_lswx,
   xu1_lq_ex3_strg_noop,
   xu_lq_axu_ex_stq_val,
   xu_lq_axu_ex_stq_itag,
   xu_lq_axu_exp1_stq_data,
   ctl_lsq_ex2_itag,
   ctl_lsq_ex2_thrd_id,
   ctl_lsq_ex3_byte_en,
   ctl_lsq_ex3_p_addr,
   ctl_lsq_ex3_algebraic,
   ctl_lsq_ex2_streq_val,
   ctl_lsq_ex4_streq_val,
   ctl_lsq_ex3_ldreq_val,
   ctl_lsq_ex3_pfetch_val,
   ctl_lsq_ex3_wchkall_val,
   ctl_lsq_ex3_opsize,
   ctl_lsq_ex4_p_addr,
   ctl_lsq_ex4_cline_chk,
   ctl_lsq_ex4_wimge,
   ctl_lsq_ex4_byte_swap,
   ctl_lsq_ex4_is_sync,
   ctl_lsq_ex4_all_thrd_chk,
   ctl_lsq_ex4_is_store,
   ctl_lsq_ex4_is_resv,
   ctl_lsq_ex4_is_mfgpr,
   ctl_lsq_ex4_is_icswxr,
   ctl_lsq_ex4_is_icbi,
   ctl_lsq_ex4_is_inval_op,
   ctl_lsq_ex4_dreq_val,
   ctl_lsq_ex4_has_data,
   ctl_lsq_ex4_send_l2,
   ctl_lsq_ex4_watch_clr,
   ctl_lsq_ex4_watch_clr_all,
   ctl_lsq_ex4_mtspr_trace,
   ctl_lsq_ex4_is_cinval,
   ctl_lsq_ex5_lock_clr,
   ctl_lsq_ex5_ttype,
   ctl_lsq_ex5_axu_val,
   ctl_lsq_ex5_is_epid,
   ctl_lsq_ex5_usr_def,
   ctl_lsq_ex5_l_fld,
   ctl_lsq_ex5_tgpr,
   ctl_lsq_ex5_dvc,
   ctl_lsq_ex5_dacrw,
   ctl_lsq_ex5_load_hit,
   ctl_lsq_ex5_flush_req,
   ctl_lsq_rv1_dir_rd_val,
   ldq_stq_ldm_cpl,
   ldq_stq_ex5_ldm_hit,
   ldq_stq_ex5_ldm_entry,
   ldq_stq_stq4_dir_upd,
   ldq_stq_stq4_cclass,
   stq_odq_i0_stTag,
   stq_odq_i1_stTag,
   stq_odq_stq4_stTag_inval,
   stq_odq_stq4_stTag,
   odq_stq_ex2_nxt_oldest_val,
   odq_stq_ex2_nxt_oldest_stTag,
   odq_stq_ex2_nxt_youngest_val,
   odq_stq_ex2_nxt_youngest_stTag,
   odq_stq_resolved,
   odq_stq_stTag,
   ctl_lsq_spr_dvc1_dbg,
   ctl_lsq_spr_dvc2_dbg,
   ctl_lsq_spr_dbcr2_dvc1m,
   ctl_lsq_spr_dbcr2_dvc1be,
   ctl_lsq_spr_dbcr2_dvc2m,
   ctl_lsq_spr_dbcr2_dvc2be,
   ctl_lsq_dbg_int_en,
   iu_lq_cp_next_val,
   iu_lq_cp_next_itag,
   iu_lq_cp_flush,
   iu_lq_i0_completed,
   iu_lq_i0_completed_itag,
   iu_lq_i1_completed,
   iu_lq_i1_completed_itag,
   lsq_ctl_stq_cpl_ready,
   lsq_ctl_stq_cpl_ready_itag,
   lsq_ctl_stq_cpl_ready_tid,
   lsq_ctl_stq_n_flush,
   lsq_ctl_stq_np1_flush,
   lsq_ctl_stq_exception_val,
   lsq_ctl_stq_exception,
   lsq_ctl_stq_dacrw,
   ctl_lsq_stq_cpl_blk,
   ctl_lsq_ex_pipe_full,
   stq_ldq_empty,
   arb_stq_cred_avail,
   xu_lq_spr_xucr0_cls,
   iu_lq_spr_iucr0_icbi_ack,
   ctl_lsq_spr_lsucr0_sca,
   ctl_lsq_spr_lsucr0_dfwd,
   ldq_stq_rel1_blk_store,
   stq_hold_all_req,
   stq_rv_set_hold,
   stq_rv_clr_hold,
   lsq_ctl_ex5_stq_restart,
   lsq_ctl_ex5_stq_restart_miss,
   stq_arb_st_req_avail,
   stq_arb_stq3_cmmt_val,
   stq_arb_stq3_cmmt_reject,
   stq_arb_stq3_req_val,
   stq_arb_stq3_tid,
   stq_arb_stq3_usrDef,
   stq_arb_stq3_wimge,
   stq_arb_stq3_p_addr,
   stq_arb_stq3_ttype,
   stq_arb_stq3_opSize,
   stq_arb_stq3_byteEn,
   stq_arb_stq3_cTag,
   stq_arb_stq1_byte_swap,
   stq_arb_stq1_thrd_id,
   stq_dat_stq1_stg_act,
   lsq_dat_stq1_val,
   lsq_dat_stq1_mftgpr_val,
   lsq_dat_stq1_store_val,
   lsq_dat_stq1_byte_en,
   stq_arb_stq1_axu_val,
   stq_arb_stq1_epid_val,
   stq_arb_stq1_opSize,
   stq_arb_stq1_p_addr,
   stq_arb_stq1_wimge_i,
   stq_arb_stq1_store_data,
   stq_ctl_stq1_stg_act,
   lsq_ctl_stq1_val,
   lsq_ctl_stq1_mftgpr_val,
   lsq_ctl_stq1_mfdpf_val,
   lsq_ctl_stq1_mfdpa_val,
   lsq_ctl_stq1_lock_clr,
   lsq_ctl_stq1_watch_clr,
   lsq_ctl_stq1_l_fld,
   lsq_ctl_stq1_inval,
   lsq_ctl_stq1_dci_val,
   lsq_ctl_stq1_store_val,
   lsq_ctl_stq4_xucr0_cul,
   lsq_ctl_stq5_itag,
   lsq_ctl_stq5_tgpr,
   ctl_lsq_stq4_perr_reject,
   lsq_ctl_ex3_strg_val,
   lsq_ctl_ex3_strg_noop,
   lsq_ctl_ex3_illeg_lswx,
   lsq_ctl_ex3_ct_val,
   lsq_ctl_ex3_be_ct,
   lsq_ctl_ex3_le_ct,
   lsq_ctl_stq1_resv,
   stq_stq2_blk_req,
   lsq_ctl_ex5_fwd_data,
   lsq_ctl_ex5_fwd_val,
   lsq_ctl_ex6_stq_events,
   lsq_perv_stq_events,
   lsq_ctl_sync_in_stq,
   lsq_ctl_sync_done,
   sq_iu_credit_free,
   an_ac_sync_ack,
   lq_iu_icbi_val,
   lq_iu_icbi_addr,
   iu_lq_icbi_complete,
   lq_iu_ici_val,
   l2_back_inv_val,
   l2_back_inv_addr,
   an_ac_back_inv,
   an_ac_back_inv_target_bit3,
   an_ac_back_inv_addr,
   an_ac_back_inv_addr_lo,
   an_ac_stcx_complete,
   an_ac_stcx_pass,
   an_ac_icbi_ack,
   an_ac_icbi_ack_thread,
   an_ac_coreid,
   xu_lq_xer_cp_rd,
   lq_xu_cr_l2_we,
   lq_xu_cr_l2_wa,
   lq_xu_cr_l2_wd,
   stq_arb_release_itag_vld,
   stq_arb_release_itag,
   stq_arb_release_tid,
   vdd,
   gnd,
   nclk,
   sg_0,
   func_sl_thold_0_b,
   func_sl_force,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   scan_in,
   scan_out
);

   //   IU interface to RV for instruction insertion
   // port 0
   input [0:`THREADS-1]                                        rv_lq_rv1_i0_vld;
   input                                                       rv_lq_rv1_i0_ucode_preissue;
   input [0:2]                                                 rv_lq_rv1_i0_s3_t;
   input                                                       rv_lq_rv1_i0_rte_sq;
   input [0:`ITAG_SIZE_ENC-1]                                  rv_lq_rv1_i0_itag;

   // port 1
   input [0:`THREADS-1]                                        rv_lq_rv1_i1_vld;
   input                                                       rv_lq_rv1_i1_ucode_preissue;
   input [0:2]                                                 rv_lq_rv1_i1_s3_t;
   input                                                       rv_lq_rv1_i1_rte_sq;
   input [0:`ITAG_SIZE_ENC-1]                                  rv_lq_rv1_i1_itag;

   // LQ RV Snoop
   input [0:`THREADS-1]                                        rv_lq_vld;
   input                                                       rv_lq_isLoad;

   // FXU0 Data interface
   input [0:`THREADS-1]                                        xu1_lq_ex2_stq_val;
   input [0:`ITAG_SIZE_ENC-1]                                  xu1_lq_ex2_stq_itag;
   input [(64-(2**`GPR_WIDTH_ENC))/8:7]                        xu1_lq_ex2_stq_dvc1_cmp;
   input [(64-(2**`GPR_WIDTH_ENC))/8:7]                        xu1_lq_ex2_stq_dvc2_cmp;
   input [64-(2**`GPR_WIDTH_ENC):63]                           ctl_lsq_ex4_xu1_data;
   input                                                       xu1_lq_ex3_illeg_lswx;
   input                                                       xu1_lq_ex3_strg_noop;

   // AXU Data interface
   input [0:`THREADS-1]                                        xu_lq_axu_ex_stq_val;
   input [0:`ITAG_SIZE_ENC-1]                                  xu_lq_axu_ex_stq_itag;
   input [(128-`STQ_DATA_SIZE):127]                            xu_lq_axu_exp1_stq_data;

   // Store Request Control (data into q)
   input [0:`ITAG_SIZE_ENC-1]                                  ctl_lsq_ex2_itag;
   input [0:`THREADS-1]                                        ctl_lsq_ex2_thrd_id;
   input [0:15]                                                ctl_lsq_ex3_byte_en;
   input [58:63]                                               ctl_lsq_ex3_p_addr;
   input                                                       ctl_lsq_ex3_algebraic;
   input [0:`THREADS-1]                                        ctl_lsq_ex2_streq_val;
   input [0:`THREADS-1]                                        ctl_lsq_ex4_streq_val;
   input [0:`THREADS-1]                                        ctl_lsq_ex3_ldreq_val;
   input                                                       ctl_lsq_ex3_pfetch_val;
   input [0:`THREADS-1]                                        ctl_lsq_ex3_wchkall_val;
   input [0:2]                                                 ctl_lsq_ex3_opsize;
   input [64-`REAL_IFAR_WIDTH:63]                              ctl_lsq_ex4_p_addr;
   input                                                       ctl_lsq_ex4_cline_chk;		// cacheline op
   input [0:4]                                                 ctl_lsq_ex4_wimge;
   input                                                       ctl_lsq_ex4_byte_swap;
   input                                                       ctl_lsq_ex4_is_sync;
   input                                                       ctl_lsq_ex4_all_thrd_chk;
   input                                                       ctl_lsq_ex4_is_store;
   input                                                       ctl_lsq_ex4_is_resv;
   input                                                       ctl_lsq_ex4_is_mfgpr;
   input                                                       ctl_lsq_ex4_is_icswxr;
   input                                                       ctl_lsq_ex4_is_icbi;
   input                                                       ctl_lsq_ex4_is_inval_op;
   input                                                       ctl_lsq_ex4_dreq_val;
   input                                                       ctl_lsq_ex4_has_data;
   input                                                       ctl_lsq_ex4_send_l2;
   input                                                       ctl_lsq_ex4_watch_clr;
   input                                                       ctl_lsq_ex4_watch_clr_all;
   input                                                       ctl_lsq_ex4_mtspr_trace;
   input                                                       ctl_lsq_ex4_is_cinval;
   input                                                       ctl_lsq_ex5_lock_clr;
   input [0:5]                                                 ctl_lsq_ex5_ttype;
   input                                                       ctl_lsq_ex5_axu_val;		// XU;AXU type operation
   input                                                       ctl_lsq_ex5_is_epid;
   input [0:3]                                                 ctl_lsq_ex5_usr_def;
   input [0:1]                                                 ctl_lsq_ex5_l_fld;
   input [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  ctl_lsq_ex5_tgpr;
   input [0:1]                                                 ctl_lsq_ex5_dvc;
   input [0:3]                                                 ctl_lsq_ex5_dacrw;
   input                                                       ctl_lsq_ex5_load_hit;
   input                                                       ctl_lsq_ex5_flush_req;
   input                                                       ctl_lsq_rv1_dir_rd_val;

   input [0:`LMQ_ENTRIES-1]                                    ldq_stq_ldm_cpl;
   input [0:`LMQ_ENTRIES-1]                                    ldq_stq_ex5_ldm_hit;
   input [0:`LMQ_ENTRIES-1]                                    ldq_stq_ex5_ldm_entry;
   input                                                       ldq_stq_stq4_dir_upd;
   input [64-(`DC_SIZE-3):57]                                  ldq_stq_stq4_cclass;

   // Age Detection
   // store tag used when instruction was inserted to store queue
   output [0:`STQ_ENTRIES_ENC-1]                               stq_odq_i0_stTag;
   output [0:`STQ_ENTRIES_ENC-1]                               stq_odq_i1_stTag;

   // store tag is committed; remove from order queue and dont compare against it
   output                                                      stq_odq_stq4_stTag_inval;
   output [0:`STQ_ENTRIES_ENC-1]                               stq_odq_stq4_stTag;

   // order queue closest oldest store to the ex2 load request
   input                                                       odq_stq_ex2_nxt_oldest_val;
   input [0:`STQ_ENTRIES-1]                                    odq_stq_ex2_nxt_oldest_stTag;

   // order queue closest youngest store to the ex2 load request
   input                                                       odq_stq_ex2_nxt_youngest_val;
   input [0:`STQ_ENTRIES-1]                                    odq_stq_ex2_nxt_youngest_stTag;

   // store tag is resolved from odq allow stq to commit
   input                                                       odq_stq_resolved;
   input [0:`STQ_ENTRIES-1]                                    odq_stq_stTag;

   // Interface with Local SPR's
   input [64-(2**`GPR_WIDTH_ENC):63]                           ctl_lsq_spr_dvc1_dbg;
   input [64-(2**`GPR_WIDTH_ENC):63]                           ctl_lsq_spr_dvc2_dbg;
   input [0:2*`THREADS-1]                                      ctl_lsq_spr_dbcr2_dvc1m;
   input [0:8*`THREADS-1]                                      ctl_lsq_spr_dbcr2_dvc1be;
   input [0:2*`THREADS-1]                                      ctl_lsq_spr_dbcr2_dvc2m;
   input [0:8*`THREADS-1]                                      ctl_lsq_spr_dbcr2_dvc2be;
   input [0:`THREADS-1]                                        ctl_lsq_dbg_int_en;

   // Completion Inputs
   input [0:`THREADS-1]                                        iu_lq_cp_next_val;
   input [0:(`ITAG_SIZE_ENC*`THREADS)-1]                       iu_lq_cp_next_itag;
   input [0:`THREADS-1]                                        iu_lq_cp_flush;
   input [0:`THREADS-1]                                        iu_lq_i0_completed;
   input [0:(`ITAG_SIZE_ENC*`THREADS)-1]                       iu_lq_i0_completed_itag;
   input [0:`THREADS-1]                                        iu_lq_i1_completed;
   input [0:(`ITAG_SIZE_ENC*`THREADS)-1]                       iu_lq_i1_completed_itag;

   // Store Queue Completion Report
   output                                                      lsq_ctl_stq_cpl_ready;
   output [0:`ITAG_SIZE_ENC-1]                                 lsq_ctl_stq_cpl_ready_itag;
   output [0:`THREADS-1]                                       lsq_ctl_stq_cpl_ready_tid;
   output                                                      lsq_ctl_stq_n_flush;
   output                                                      lsq_ctl_stq_np1_flush;
   output                                                      lsq_ctl_stq_exception_val;
   output [0:5]                                                lsq_ctl_stq_exception;
   output [0:3]                                                lsq_ctl_stq_dacrw;
   input                                                       ctl_lsq_stq_cpl_blk;
   input                                                       ctl_lsq_ex_pipe_full;

   // Store Queue is empty
   output [0:`THREADS-1]                                       stq_ldq_empty;

   // L2 Credits Available
   input                                                       arb_stq_cred_avail;

   // Data Cache Config
   input                                                       xu_lq_spr_xucr0_cls;		// Data Cache Line Size Mode

   // ICBI ACK Enable
   input                                                       iu_lq_spr_iucr0_icbi_ack;

   // LSUCR0 Config Bits
   input [0:2]                                                 ctl_lsq_spr_lsucr0_sca;
   input                                                       ctl_lsq_spr_lsucr0_dfwd;

   // Interface to Store Queue (reload block)
   input                                                       ldq_stq_rel1_blk_store;

   // Reservation station hold (times for forcing a hole)
   output                                                      stq_hold_all_req;

   // Reservation station set barrier indicator
   output                                                      stq_rv_set_hold;
   output [0:`THREADS-1]                                       stq_rv_clr_hold;

   // STORE Queue RESTART indicator
   output                                                      lsq_ctl_ex5_stq_restart;
   output                                                      lsq_ctl_ex5_stq_restart_miss;

   // STQ Request to the L2
   output                                                      stq_arb_st_req_avail;
   output                                                      stq_arb_stq3_cmmt_val;
   output                                                      stq_arb_stq3_cmmt_reject;
   output                                                      stq_arb_stq3_req_val;
   output [0:1]                                                stq_arb_stq3_tid;
   output reg [0:3]                                            stq_arb_stq3_usrDef;
   output reg [0:4]                                            stq_arb_stq3_wimge;
   output reg [64-`REAL_IFAR_WIDTH:63]                         stq_arb_stq3_p_addr;
   output [0:5]                                                stq_arb_stq3_ttype;
   output reg [0:2]                                            stq_arb_stq3_opSize;
   output reg [0:15]                                           stq_arb_stq3_byteEn;
   output [0:4]                                                stq_arb_stq3_cTag;
   output reg                                                  stq_arb_stq1_byte_swap;
   output reg [0:`THREADS-1]                                   stq_arb_stq1_thrd_id;

   // Store Commit Data Control
   output                                                      stq_dat_stq1_stg_act;		// ACT Pin for DAT
   output                                                      lsq_dat_stq1_val;
   output                                                      lsq_dat_stq1_mftgpr_val;
   output reg                                                  lsq_dat_stq1_store_val;
   output reg [0:15]                                           lsq_dat_stq1_byte_en;
   output reg                                                  stq_arb_stq1_axu_val;
   output reg                                                  stq_arb_stq1_epid_val;
   output reg [0:2]                                            stq_arb_stq1_opSize;
   output [64-`REAL_IFAR_WIDTH:63]                             stq_arb_stq1_p_addr;
   output reg                                                  stq_arb_stq1_wimge_i;
   output reg [(128-`STQ_DATA_SIZE):127]                       stq_arb_stq1_store_data;

   // Store Commit Directory Control
   output                                                      stq_ctl_stq1_stg_act;		// ACT Pin for CTL
   output                                                      lsq_ctl_stq1_val;
   output                                                      lsq_ctl_stq1_mftgpr_val;
   output                                                      lsq_ctl_stq1_mfdpf_val;
   output                                                      lsq_ctl_stq1_mfdpa_val;
   output reg                                                  lsq_ctl_stq1_lock_clr;
   output reg                                                  lsq_ctl_stq1_watch_clr;
   output reg [0:1]                                            lsq_ctl_stq1_l_fld;
   output reg                                                  lsq_ctl_stq1_inval;
   output                                                      lsq_ctl_stq1_dci_val;
   output reg                                                  lsq_ctl_stq1_store_val;
   output                                                      lsq_ctl_stq4_xucr0_cul;
   output reg [0:`ITAG_SIZE_ENC-1]                             lsq_ctl_stq5_itag;
   output reg [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1] lsq_ctl_stq5_tgpr;
   input                                                       ctl_lsq_stq4_perr_reject;

   // Illegal LSWX has been determined
   output                                                      lsq_ctl_ex3_strg_val;		// STQ has checked XER valid
   output                                                      lsq_ctl_ex3_strg_noop;		// STQ detected a noop of LSWX/STSWX
   output                                                      lsq_ctl_ex3_illeg_lswx;		// STQ detected illegal form of LSWX
   output                                                      lsq_ctl_ex3_ct_val;		    // ICSWX Data is valid
   output [0:5]                                                lsq_ctl_ex3_be_ct;		    // Big Endian Coprocessor Type Select
   output [0:5]                                                lsq_ctl_ex3_le_ct;		    // Little Endian Coprocessor Type Select

   // Store Commit Control
   output reg                                                  lsq_ctl_stq1_resv;
   output                                                      stq_stq2_blk_req;

   output [(128-`STQ_DATA_SIZE):127]                           lsq_ctl_ex5_fwd_data;
   output                                                      lsq_ctl_ex5_fwd_val;
   output [0:1]                                                lsq_ctl_ex6_stq_events;
   output [0:(3*`THREADS)+2]                                   lsq_perv_stq_events;

   output                                                      lsq_ctl_sync_in_stq;
   output                                                      lsq_ctl_sync_done;

   output [0:`THREADS-1]                                       sq_iu_credit_free;

   input [0:`THREADS-1]                                        an_ac_sync_ack;

   // ICBI interface
   output [0:`THREADS-1]                                       lq_iu_icbi_val;
   output [64-`REAL_IFAR_WIDTH:57]                             lq_iu_icbi_addr;
   input [0:`THREADS-1]                                        iu_lq_icbi_complete;

   // ICI Interace
   output                                                      lq_iu_ici_val;

   // Back-Invalidate Valid
   input                                                       l2_back_inv_val;
   input [64-(`DC_SIZE-3):63-`CL_SIZE]                         l2_back_inv_addr;

   // L2 Interface Back Invalidate
   input                                                       an_ac_back_inv;
   input                                                       an_ac_back_inv_target_bit3;
   input [58:60]                                               an_ac_back_inv_addr;
   input [62:63]                                               an_ac_back_inv_addr_lo;

   // Stcx Complete
   input [0:`THREADS-1]                                        an_ac_stcx_complete;
   input [0:`THREADS-1]                                        an_ac_stcx_pass;

   // ICBI ACK
   input                                                       an_ac_icbi_ack;
   input [0:1]                                                 an_ac_icbi_ack_thread;

   // Core ID
   input [6:7]                                                 an_ac_coreid;

   // STCX/ICSWX CR Update
   input [0:`THREADS-1]                                        xu_lq_xer_cp_rd;
   output                                                      lq_xu_cr_l2_we;
   output [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]                 lq_xu_cr_l2_wa;
   output [0:3]                                                lq_xu_cr_l2_wd;

   // Reload Itag Complete
   output                                                      stq_arb_release_itag_vld;
   output [0:`ITAG_SIZE_ENC-1]                                 stq_arb_release_itag;
   output [0:`THREADS-1]                                       stq_arb_release_tid;

   // Pervasive


   inout                                                       vdd;


   inout                                                       gnd;

   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

   input [0:`NCLK_WIDTH-1]                                     nclk;
   input                                                       sg_0;
   input                                                       func_sl_thold_0_b;
   input                                                       func_sl_force;
   input                                                       d_mode_dc;
   input                                                       delay_lclkr_dc;
   input                                                       mpw1_dc_b;
   input                                                       mpw2_dc_b;

   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

   input                                                       scan_in;

   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

   output                                                      scan_out;

   parameter                                                   tiup = 1'b1;
   parameter                                                   tidn = 1'b0;
   parameter                                                   RI = 64 - `REAL_IFAR_WIDTH;
   parameter                                                   AXU_TARGET_ENC = `AXU_SPARE_ENC + `GPR_POOL_ENC + `THREADS_POOL_ENC;

   // Latches
   wire                                                        rv_lq_vld_d;		// input=>rv_lq_vld_d               ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        rv_lq_vld_q;
   wire                                                        rv_lq_ld_vld_d;		// input=>rv_lq_ld_vld_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        rv_lq_ld_vld_q;
   wire                                                        ex0_dir_rd_val_d;    // input=>ex0_dir_rd_val_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex0_dir_rd_val_q;

   wire [0:`THREADS-1] 					       rv0_cp_flush_q;		// input=>rv0_cp_flush_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1] 					       rv0_cp_flush_d;
   wire [0:`THREADS-1] 					       rv1_cp_flush_q;		// input=>rv1_cp_flush_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1] 					       rv1_cp_flush_d;
   wire [0:`THREADS-1] 					       rv1_i0_vld;
   wire                                                        rv1_i0_flushed;
   wire [0:`THREADS-1] 					       rv1_i1_vld;
   wire                                                        rv1_i1_flushed;
   wire [0:`THREADS-1] 					       ex0_i0_vld_q;		// input=>rv2_i0_vld_q              ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex0_i0_flushed_q;		// input=rv2_i0_flushed             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`ITAG_SIZE_ENC-1] 				       ex0_i0_itag_q;		// input=>rv2_i0_itag_q             ,act=>rv2_i0_act           ,scan=>Y ,needs_sreset=>0
   wire [0:`THREADS-1] 					       ex0_i1_vld_q;		// input=>rv2_i1_vld_q              ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex0_i1_flushed_q;		// input=rv2_i1_flushed             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`ITAG_SIZE_ENC-1] 				       ex0_i1_itag_q;		// input=>rv2_i1_itag_q             ,act=>rv2_i1_act           ,scan=>Y ,needs_sreset=>0
   wire [0:`THREADS-1] 					       ex1_i0_vld_q;		// input=>rv2_i0_vld_q              ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex1_i0_flushed_q;		// input=rv2_i0_flushed             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`ITAG_SIZE_ENC-1] 				       ex1_i0_itag_q;		// input=>rv2_i0_itag_q             ,act=>rv2_i0_act           ,scan=>Y ,needs_sreset=>0
   wire [0:`THREADS-1] 					       ex1_i1_vld_q;		// input=>rv2_i1_vld_q              ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex1_i1_flushed_q;		// input=rv2_i1_flushed             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`ITAG_SIZE_ENC-1] 				       ex1_i1_itag_q;		// input=>rv2_i1_itag_q             ,act=>rv2_i1_act           ,scan=>Y ,needs_sreset=>0
   wire [0:`STQ_ENTRIES-1] 				       stqe_alloc_ptr_q;		// input=>stqe_alloc_ptr_d          ,act=>stq_alloc_val(0)    ,scan=>Y ,needs_sreset=>1 ,init=>2**(`STQ_ENTRIES-1)
   wire [0:`STQ_ENTRIES-1] 				       stqe_alloc_ptr_d;
   wire [0:`STQ_ENTRIES-1] 				       stqe_alloc_d;		// input=>stqe_alloc_d              ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES] 				       stqe_alloc_q;		// input=>stqe_alloc_d              ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1] 				       stqe_addr_val_d;		// input=>stqe_addr_val_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES] 				       stqe_addr_val_q;		// input=>stqe_addr_val_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1] 				       stqe_fwd_addr_val_d;		// input=>stqe_fwd_addr_val_d       ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES] 				       stqe_fwd_addr_val_q;		// input=>stqe_fwd_addr_val_d       ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1] 				       stqe_data_val_d;		// input=>stqe_data_val_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES] 				       stqe_data_val_q;		// input=>stqe_data_val_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1] 				       stqe_data_nxt_d;		// input=>stqe_data_nxt_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES] 				       stqe_data_nxt_q;		// input=>stqe_data_nxt_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1] 				       stqe_illeg_lswx_d;		// input=>stqe_illeg_lswx_d         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES] 				       stqe_illeg_lswx_q;		// input=>stqe_illeg_lswx_d         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1] 				       stqe_strg_noop_d;		// input=>stqe_strg_noop_d          ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES] 				       stqe_strg_noop_q;		// input=>stqe_strg_noop_d          ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1] 				       stqe_ready_sent_d;		// input=>stqe_ready_sent_d         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES] 				       stqe_ready_sent_q;		// input=>stqe_ready_sent_d         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1] 				       stqe_odq_resolved_d;		// input=>stqe_odq_resolved_d       ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES] 				       stqe_odq_resolved_q;		// input=>stqe_odq_resolved_d       ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1] 				       stqe_compl_rcvd_d;		// input=>stqe_compl_rcvd_d         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES] 				       stqe_compl_rcvd_q;		// input=>stqe_compl_rcvd_d         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1] 				       stqe_have_cp_next_d;		// input=>stqe_have_cp_next_d       ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES] 				       stqe_have_cp_next_q;		// input=>stqe_have_cp_next_d       ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1] 				       stqe_need_ready_ptr_d;		// input=>stqe_need_ready_ptr_d     ,act=>stqe_need_ready_act  ,scan=>Y ,needs_sreset=>1 ,init=>2**(`STQ_ENTRIES-1)
   wire [0:`STQ_ENTRIES] 				       stqe_need_ready_ptr_q;		// input=>stqe_need_ready_ptr_d     ,act=>stqe_need_ready_act  ,scan=>Y ,needs_sreset=>1 ,init=>2**(`STQ_ENTRIES-1)
   wire [0:`STQ_ENTRIES-1] 				       stqe_flushed_d;		// input=>stqe_flushed_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES] 				       stqe_flushed_q;		// input=>stqe_flushed_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1] 				       stqe_ack_rcvd_d;		// input=>stqe_ack_rcvd_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES] 				       stqe_ack_rcvd_q;		// input=>stqe_ack_rcvd_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`LMQ_ENTRIES-1] 				       stqe_lmqhit_d[0:`STQ_ENTRIES-1];		// input=>stqe_lmqhit_d             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:`LMQ_ENTRIES-1] 				       stqe_lmqhit_q[0:`STQ_ENTRIES];		// input=>stqe_lmqhit_d             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:`STQ_ENTRIES-1] 				       stqe_need_ext_ack_d;		// input=>stqe_need_ext_ack_d       ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:`STQ_ENTRIES] 				       stqe_need_ext_ack_q;		// input=>stqe_need_ext_ack_d       ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:`STQ_ENTRIES-1] 				       stqe_blk_loads_d;		// input=>stqe_blk_loads_d          ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:`STQ_ENTRIES] 				       stqe_blk_loads_q;		// input=>stqe_blk_loads_d          ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:`STQ_ENTRIES-1]                     stqe_all_thrd_chk_d;     // input=>stqe_all_thrd_chk_d       ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:`STQ_ENTRIES]                       stqe_all_thrd_chk_q;     // input=>stqe_all_thrd_chk_d       ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:`ITAG_SIZE_ENC-1] 				       stqe_itag_d[0:`STQ_ENTRIES-1];		// input=>stqe_itag_d               ,act=>stqe_itag_act(i)     ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:`ITAG_SIZE_ENC-1] 				       stqe_itag_q[0:`STQ_ENTRIES];		// input=>stqe_itag_d               ,act=>stqe_itag_act(i)     ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [64-`REAL_IFAR_WIDTH:63] 			       stqe_addr_d[0:`STQ_ENTRIES-1];		// input=>ctl_lsq_ex4_p_addr        ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [64-`REAL_IFAR_WIDTH:63] 			       stqe_addr_q[0:`STQ_ENTRIES];		// input=>ctl_lsq_ex4_p_addr        ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:15] 						       stqe_rotcmp_d[0:`STQ_ENTRIES-1];		// input=>stq_rotcmp,               ,act=>ex3_addr_act(i)      ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:15] 						       stqe_rotcmp_q[0:`STQ_ENTRIES];		// input=>stq_rotcmp,               ,act=>ex3_addr_act(i)      ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:`STQ_ENTRIES-1]                                      stqe_cline_chk_d;		// input=>ctl_lsq_ex4_cline_chk     ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_cline_chk_q;		// input=>ctl_lsq_ex4_cline_chk     ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:5]                                                  stqe_ttype_d[0:`STQ_ENTRIES-1];		// input=>ctl_lsq_ex5_ttype         ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:5]                                                  stqe_ttype_q[0:`STQ_ENTRIES];		// input=>ctl_lsq_ex5_ttype         ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:15]                                                 stqe_byte_en_d[0:`STQ_ENTRIES-1];		// input=>ctl_lsq_ex3_byte_en       ,act=>ex3_addr_act(i)      ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:15]                                                 stqe_byte_en_q[0:`STQ_ENTRIES];		// input=>ctl_lsq_ex3_byte_en       ,act=>ex3_addr_act(i)      ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:4]                                                  stqe_wimge_d[0:`STQ_ENTRIES-1];		// input=>ctl_lsq_ex4_wimge         ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:4]                                                  stqe_wimge_q[0:`STQ_ENTRIES];		// input=>ctl_lsq_ex4_wimge         ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:`STQ_ENTRIES-1]                                      stqe_byte_swap_d;		// input=>ctl_lsq_ex4_byte_swap     ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_byte_swap_q;		// input=>ctl_lsq_ex4_byte_swap     ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:2]                                                  stqe_opsize_d[0:`STQ_ENTRIES-1];		// input=>ex4_req_opsize_q          ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:2]                                                  stqe_opsize_q[0:`STQ_ENTRIES];		// input=>ex4_req_opsize_q          ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:`STQ_ENTRIES-1]                                      stqe_axu_val_d;		// input=>ctl_lsq_ex5_axu_val       ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_axu_val_q;		// input=>ctl_lsq_ex5_axu_val       ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>
   wire [0:`STQ_ENTRIES-1]                                      stqe_epid_val_d;		// input=>ctl_lsq_ex5_is_epid       ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_epid_val_q;		// input=>ctl_lsq_ex5_is_epid       ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:3]                                                  stqe_usr_def_d[0:`STQ_ENTRIES-1];		// input=>ctl_lsq_ex5_usr_def       ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:3]                                                  stqe_usr_def_q[0:`STQ_ENTRIES];		// input=>ctl_lsq_ex5_usr_def       ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:`STQ_ENTRIES-1]                                      stqe_is_store_d;		// input=>ctl_lsq_ex4_is_store      ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_is_store_q;		// input=>ctl_lsq_ex4_is_store      ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES-1]                                      stqe_is_sync_d;		// input=>ctl_lsq_ex4_is_sync       ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_is_sync_q;		// input=>ctl_lsq_ex4_is_sync       ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES-1]                                      stqe_is_resv_d;		// input=>ctl_lsq_ex4_is_resv       ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES-1]                                      stqe_is_icswxr_d;		// input=>ctl_lsq_ex4_is_icswxr     ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES-1]                                      stqe_is_icbi_d;		// input=>ctl_lsq_ex4_is_icbi       ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES-1]                                      stqe_is_inval_op_d;		// input=>ctl_lsq_ex4_is_inval_op   ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES-1]                                      stqe_dreq_val_d;		// input=>ctl_lsq_ex4_dreq_val      ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_dreq_val_q;		// input=>ctl_lsq_ex4_dreq_val      ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES-1]                                      stqe_has_data_d;		// input=>ctl_lsq_ex4_has_data      ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES-1]                                      stqe_send_l2_d;		// input=>ctl_lsq_ex4_send_l2       ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES-1]                                      stqe_watch_clr_d;		// input=>ctl_lsq_ex4_watch_clr     ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_is_resv_q;		// input=>ctl_lsq_ex4_is_resv       ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_is_icswxr_q;		// input=>ctl_lsq_ex4_is_icswxr     ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_is_icbi_q;		// input=>ctl_lsq_ex4_is_icbi       ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_is_inval_op_q;		// input=>ctl_lsq_ex4_is_inval_op   ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_has_data_q;		// input=>ctl_lsq_ex4_has_data      ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_send_l2_q;		// input=>ctl_lsq_ex4_send_l2       ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_watch_clr_q;		// input=>ctl_lsq_ex4_watch_clr     ,act=>ex4_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES-1]                                      stqe_lock_clr_d;		// input=>ctl_lsq_ex5_lock_clr      ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:`STQ_ENTRIES]                                        stqe_lock_clr_q;		// input=>ctl_lsq_ex5_lock_clr      ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i
   wire [0:1]                                                  stqe_l_fld_d[0:`STQ_ENTRIES-1];		// input=>ctl_lsq_ex5_l_fld         ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:1]                                                  stqe_l_fld_q[0:`STQ_ENTRIES];		// input=>ctl_lsq_ex5_l_fld         ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:`THREADS-1]                                          stqe_thrd_id_d[0:`STQ_ENTRIES-1];		// input=>stqe_thrd_id_d            ,act=>stqe_itag_act(i)     ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:`THREADS-1]                                          stqe_thrd_id_q[0:`STQ_ENTRIES];		// input=>stqe_thrd_id_d            ,act=>stqe_itag_act(i)     ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:AXU_TARGET_ENC-1]                                   stqe_tgpr_d[0:`STQ_ENTRIES-1];		// input=>ctl_lsq_ex5_tgpr          ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:AXU_TARGET_ENC-1]                                   stqe_tgpr_q[0:`STQ_ENTRIES];		// input=>ctl_lsq_ex5_tgpr          ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:1]                                                  stqe_dvc_en_d[0:`STQ_ENTRIES-1];		// input=>ctl_lsq_ex5_dvc           ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:1]                                                  stqe_dvc_en_q[0:`STQ_ENTRIES];		// input=>ctl_lsq_ex5_dvc           ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:3]                                                  stqe_dacrw_d[0:`STQ_ENTRIES-1];		// input=>ctl_lsq_ex5_dacrw         ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:3]                                                  stqe_dacrw_q[0:`STQ_ENTRIES];		// input=>ctl_lsq_ex5_dacrw         ,act=>ex5_addr_act(i)    ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:1]                                                  stqe_dvcr_cmpr_q[0:`STQ_ENTRIES];		// input=>stqe_dvcr_cmpr_d          ,act=>tiup                 ,scan=>Y ,needs_sreset=>1 ,iterator=>i ,array=>Y
   wire [0:1]                                                  stqe_dvcr_cmpr_d[0:`STQ_ENTRIES-1];
   wire [0:`STQ_ENTRIES-1]                                      stqe_qHit_held_q;		// input=>stqe_qHit_held_d          ,act=>tiup                 ,scan=>Y ,needs_sreset=>1 ,iterator=>i
   wire [0:`STQ_ENTRIES-1]                                      stqe_qHit_held_d;
   wire [0:`STQ_ENTRIES-1]                                      stqe_held_early_clr_d;		// input=>stqe_held_early_clr_d     ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES]                                        stqe_held_early_clr_q;		// input=>stqe_held_early_clr_d     ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [(128-`STQ_DATA_SIZE):127]                              stqe_data1_d[0:`STQ_ENTRIES-1];		// input=>stqe_data1_d,             ,act=>stqe_data_val(i)     ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [(128-`STQ_DATA_SIZE):127]                              stqe_data1_q[0:`STQ_ENTRIES];		// input=>stqe_data1_d,             ,act=>stqe_data_val(i)     ,scan=>Y ,needs_sreset=>0 ,iterator=>i ,array=>Y
   wire [0:`STQ_ENTRIES-1]                                      ex4_fxu1_data_ptr_q;		// input=>ex4_fxu1_data_ptr_d       ,act=>ex3_fxu1_val         ,scan=>Y ,needs_sreset=>0
   wire [0:`STQ_ENTRIES-1]                                      ex4_fxu1_data_ptr_d;
   wire [0:`STQ_ENTRIES-1]                                      ex4_axu_data_ptr_q;		// input=>ex4_axu_data_ptr_d        ,act=>ex3_axu_val          ,scan=>Y ,needs_sreset=>0
   wire [0:`STQ_ENTRIES-1]                                      ex4_axu_data_ptr_d;
   wire [(128-`STQ_DATA_SIZE):127]                              ex4_fu_data_q;		// input=>xu_lq_axu_exp1_stq_data   ,act=>ex3_axu_val          ,scan=>Y ,needs_sreset=>0
   wire [0:`THREADS-1]                                          cp_flush_q;		// input=>iu_lq_cp_flush            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          cp_next_val_q;		// input=>iu_lq_cp_next_val         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`ITAG_SIZE_ENC-1]                                    cp_next_itag_q[0:`THREADS-1];	// input=>iu_lq_cp_next_itag        ,act=>iu_lq_cp_next_val    ,scan=>Y ,needs_sreset=>0
   wire [0:`THREADS-1]                                          cp_i0_completed_q;		// input=>iu_lq_i0_completed        ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`ITAG_SIZE_ENC-1]                                    cp_i0_completed_itag_q[0:`THREADS-1];	// input=>iu_lq_i0_completed_itag   ,act=>iu_lq_i0_completed   ,scan=>Y ,needs_sreset=>0
   wire [0:`THREADS-1]                                          cp_i1_completed_q;		// input=>iu_lq_i1_completed        ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`ITAG_SIZE_ENC-1]                                    cp_i1_completed_itag_q[0:`THREADS-1];	// input=>iu_lq_i1_completed_itag   ,act=>iu_lq_i1_completed   ,scan=>Y ,needs_sreset=>0
   wire                                                        stq_cpl_need_hold_q;		// input=>stq_cpl_need_hold_d       ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq_cpl_need_hold_d;
   wire [0:`THREADS-1]                                          iu_lq_icbi_complete_q;		// input=>iu_lq_icbi_complete       ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq2_cmmt_flushed_q;		// input=>stq1_cmmt_flushed         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq1_cmmt_flushed;
   wire                                                        stq3_cmmt_flushed_q;		// input=>stq1_cmmt_flushed         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq4_cmmt_flushed_q;		// input=>stq1_cmmt_flushed         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq5_cmmt_flushed_q;		// input=>stq1_cmmt_flushed         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq6_cmmt_flushed_q;		// input=>stq1_cmmt_flushed         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq7_cmmt_flushed_q;		// input=>stq1_cmmt_flushed         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1]                                      stq1_cmmt_ptr_q;		// input=>stq1_cmmt_ptr_d           ,act=>stq1_cmmt_act        ,scan=>Y ,needs_sreset=>1 ,init=>2**(`STQ_ENTRIES-1)
   wire [0:`STQ_ENTRIES-1]                                      stq1_cmmt_ptr_d;
   wire [0:`STQ_ENTRIES-1]                                      stq2_cmmt_ptr_q;		// input=>stq1_cmmt_ptr_q           ,act=>stq1_cmmt_act        ,scan=>Y ,needs_sreset=>0
   wire [0:`STQ_ENTRIES-1]                                      stq2_cmmt_ptr_d;
   wire [0:`STQ_ENTRIES-1]                                      stq3_cmmt_ptr_q;		// input=>stq2_cmmt_ptr_q           ,act=>stq2_cmmt_val_q      ,scan=>Y ,needs_sreset=>0
   wire [0:`STQ_ENTRIES-1]                                      stq3_cmmt_ptr_d;
   wire [0:`STQ_ENTRIES-1]                                      stq4_cmmt_ptr_q;		// input=>stq3_cmmt_ptr_q           ,act=>stq3_cmmt_val_q      ,scan=>Y ,needs_sreset=>0
   wire [0:`STQ_ENTRIES-1]                                      stq4_cmmt_ptr_d;
   wire [0:`STQ_ENTRIES-1]                                      stq5_cmmt_ptr_q;		// input=>stq4_cmmt_ptr_q           ,act=>stq4_cmmt_val_q      ,scan=>Y ,needs_sreset=>0
   wire [0:`STQ_ENTRIES-1]                                      stq5_cmmt_ptr_d;
   wire [0:`STQ_ENTRIES-1]                                      stq6_cmmt_ptr_q;		// input=>stq5_cmmt_ptr_q           ,act=>stq5_cmmt_val_q      ,scan=>Y ,needs_sreset=>0
   wire [0:`STQ_ENTRIES-1]                                      stq6_cmmt_ptr_d;
   wire [0:`STQ_ENTRIES-1]                                      stq7_cmmt_ptr_q;		// input=>stq7_cmmt_ptr_d           ,act=>stq6_cmmt_val_q      ,scan=>Y ,needs_sreset=>0
   wire [0:`STQ_ENTRIES-1]                                      stq7_cmmt_ptr_d;
   wire                                                        stq2_cmmt_val_q;		// input=>stq1_cmmt_val             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq1_cmmt_val;
   wire                                                        stq3_cmmt_val_q;		// input=>stq2_cmmt_val             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq2_cmmt_val;
   wire                                                        stq4_cmmt_val_q;		// input=>stq3_cmmt_val_q           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq5_cmmt_val_q;		// input=>stq4_cmmt_val_q           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq6_cmmt_val_q;		// input=>stq5_cmmt_val_q           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq7_cmmt_val_q;		// input=>stq6_cmmt_val_q           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ext_ack_queue_v_q;		// input=>ext_ack_queue_v_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ext_ack_queue_v_d;
   wire [0:`THREADS-1]                                          ext_ack_queue_sync_q;		// input=>ext_ack_queue_sync_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ext_ack_queue_sync_d;
   wire [0:`THREADS-1]                                          ext_ack_queue_stcx_q;		// input=>ext_ack_queue_stcx_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ext_ack_queue_stcx_d;
   wire [0:`THREADS-1]                                          ext_ack_queue_icswxr_q;		// input=>ext_ack_queue_icswxr_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ext_ack_queue_icswxr_d;
   wire [0:`ITAG_SIZE_ENC-1]                                    ext_ack_queue_itag_q[0:`THREADS-1];		// input=>ext_ack_queue_itag_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`ITAG_SIZE_ENC-1]                                    ext_ack_queue_itag_d[0:`THREADS-1];
   wire [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]                      ext_ack_queue_cr_wa_q[0:`THREADS-1];		// input=>ext_ack_queue_cr_wa_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]                      ext_ack_queue_cr_wa_d[0:`THREADS-1];
   wire [0:3]                                                  ext_ack_queue_dacrw_det_q[0:`THREADS-1];		// input=>ext_ack_queue_dacrw_det_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:3]                                                  ext_ack_queue_dacrw_det_d[0:`THREADS-1];
   wire [0:`THREADS-1]                                          ext_ack_queue_dacrw_rpt_q;		// input=>ext_ack_queue_dacrw_rpt_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ext_ack_queue_dacrw_rpt_d;
   wire                                                        stq2_mftgpr_val_q;		// input=>stq2_mftgpr_val_d         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq2_mftgpr_val_d;
   wire [0:2]                                                  stq2_rtry_cnt_q;		// input=>stq2_rtry_cnt_d           ,act=>stq2_rtry_cnt_act    ,scan=>Y ,needs_sreset=>1
   wire [0:2]                                                  stq2_rtry_cnt_d;
   wire                                                        ex5_stq_restart_q;		// input=>ex5_stq_restart_d         ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex5_stq_restart_d;
   wire                                                        ex5_stq_restart_miss_q;		// input=>ex5_stq_restart_miss_d    ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex5_stq_restart_miss_d;
   wire [0:`STQ_FWD_ENTRIES-2]                                  stq_fwd_pri_mask_d;
   wire [0:`STQ_FWD_ENTRIES-1]                                  stq_fwd_pri_mask_q;
   wire                                                        ex5_fwd_val_q;		// input=>ex5_fwd_val_d             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex5_fwd_val_d;
   wire [(128-`STQ_DATA_SIZE):127]                              ex5_fwd_data_q;		// input=>ex5_fwd_data_d            ,act=>ex4_ldreq_val_q      ,scan=>Y ,needs_sreset=>1
   reg [(128-`STQ_DATA_SIZE):127]                               ex5_fwd_data_d;
   wire [0:`STQ_ENTRIES]                                        ex4_set_stq_q;		// input=>ex3_addr_act              ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES]                                        ex5_set_stq_q;		// input=>ex4_set_stq_q            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ex4_ldreq_val_q;		// input=>ex3_ldreq_val             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ex3_ldreq_val;
   wire                                                         ex4_pfetch_val_q;       // input=>ex4_pfetch_val_d          ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                         ex4_pfetch_val_d;
   wire [0:`THREADS-1]                                          ex3_streq_val_q;		// input=>ex2_streq_val             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ex2_streq_val;
   wire [0:`THREADS-1]                                          ex5_streq_val_q;		// input=>ex4_streq_val             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ex4_streq_val;
   wire [0:`THREADS-1]                                          ex4_wchkall_val_q;		// input=>ex3_wchkall_val           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ex3_wchkall_val;
   wire [0:`THREADS-1]                                          hwsync_ack_q;		// input=>hwsync_ack                ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          hwsync_ack;
   wire [0:`THREADS-1]                                          lwsync_ack_q;		// input=>lwsync_ack                ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          lwsync_ack;
   wire                                                        icswxr_ack_q;		// input=>icswxr_ack                ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        icswxr_ack;
   wire                                                        icswxr_ack_dly1_q;	// input=>icswxr_ack_q              ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          local_instr_ack_q;		// input=>local_instr_ack           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          local_instr_ack;
   wire [0:`THREADS-1]                                          resv_ack_q;		// input=>resv_ack                  ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          resv_ack_d;
   wire [0:`THREADS-1]                                          stcx_pass_q;		// input=>stcx_ack                  ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          icbi_ack_q;		// input=>icbi_ack                  ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          icbi_ack;
   wire [0:`THREADS-1]                                          icbi_val_q;		// input=>icbi_val_d                ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          icbi_val_d;
   wire [RI:57]                                                icbi_addr_q;		// input=>icbi_addr_d               ,act=>stq2_cmmt_val_q      ,scan=>Y ,needs_sreset=>1
   reg [RI:57]                                                 icbi_addr_d;
   wire                                                        ici_val_q;		// input=>ici_val_d                 ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ici_val_d;
   wire [0:`THREADS-1]                                          credit_free_q;		// input=>credit_free_d             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          credit_free_d;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_agecmp_q;		// input=>ex3_fwd_agecmp            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_agecmp_d;
   wire [0:`ITAG_SIZE_ENC-1]                                    ex3_req_itag_q;		// input=>ctl_lsq_ex2_itag          ,act=>tiup                 ,scan=>Y ,needs_sreset=>0
   wire [0:`ITAG_SIZE_ENC-1]                                    ex4_req_itag_q;		// input=>ex3_req_itag_q          ,act=>tiup                 ,scan=>Y ,needs_sreset=>0
   wire [0:15]                                                 ex4_req_byte_en_q;		// input=>ctl_lsq_ex3_byte_en       ,act=>ex3_req_act          ,scan=>Y ,needs_sreset=>1
   wire [58:63]                                                ex4_req_p_addr_l_q;		// input=>ctl_lsq_ex3_p_addr        ,act=>ex3_req_act          ,scan=>Y ,needs_sreset=>1
   wire [0:2]                                                  ex4_req_opsize_q;		// input=>ctl_lsq_ex3_opsize        ,act=>ex3_req_act          ,scan=>Y ,needs_sreset=>1
   wire                                                        ex4_req_algebraic_q;		// input=>ctl_lsq_ex3_algebraic     ,act=>ex3_req_act          ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ex3_req_thrd_id_q;		// input=>ctl_lsq_ex2_thrd_id       ,act=>ex3_req_act          ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ex4_req_thrd_id_q;		// input=>ex3_req_thrd_id_q         ,act=>ex3_req_act          ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ex5_req_thrd_id_q;		// input=>ex4_req_thrd_id_q         ,act=>tiup          ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          thrd_held_d;		// input=>thrd_held_d               ,act=>tiup          ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          thrd_held_q;
   wire [0:`THREADS-1]                                          rv0_cr_hole_q;		// input=>rv0_cr_hole_d             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          rv0_cr_hole_d;
   wire [0:`THREADS-1]                                          rv1_cr_hole_q;		// input=>rv1_cr_hole_d             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          rv1_cr_hole_d;
   wire [0:`THREADS-1]                                          ex0_cr_hole_q;		// input=>ex0_cr_hole_d             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ex0_cr_hole_d;
   wire [0:`THREADS-1]                                          cr_ack_q;		// input=>cr_ack_d                  ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          cr_ack_d;
   wire                                                        sync_ack_save_q;		// input=>sync_ack_save             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        sync_ack_save_d;
   wire                                                        cr_we_q;		// input=>cr_we_d                   ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        cr_we_d;
   wire [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]                      cr_wa_q;		// input=>cr_wa_d                   ,act=>cr_we_d              ,scan=>Y ,needs_sreset=>0
   reg [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]                       cr_wa_d;
   wire [0:3]                                                  cr_wd_q;		// input=>cr_wd_d                   ,act=>cr_we_d              ,scan=>Y ,needs_sreset=>0
   wire [0:3]                                                  cr_wd_d;
   wire [0:`THREADS-1]                                          stcx_thrd_fail_q;   // input=>stcx_thrd_fail_d       ,act=>tiup              ,scan=>Y ,needs_sreset=>0
   wire [0:`THREADS-1]                                          stcx_thrd_fail_d;
   wire                                                         stq3_cmmt_attmpt_q; // input=>stq3_cmmt_attmpt_d       ,act=>tiup              ,scan=>Y ,needs_sreset=>0
   wire                                                         stq3_cmmt_attmpt_d;
   wire                                                         stq_need_hole_q;    // input=>stq_need_hole_d       ,act=>tiup              ,scan=>Y ,needs_sreset=>0
   wire                                                         stq_need_hole_d;
   wire [0:`THREADS-1]                                          icswxr_thrd_busy_q;   // input=>icswxr_thrd_busy_d       ,act=>tiup              ,scan=>Y ,needs_sreset=>0
   wire [0:`THREADS-1]                                          icswxr_thrd_busy_d;
   wire [0:`THREADS-1]                                          icswxr_thrd_nbusy_q;   // input=>icswxr_thrd_nbusy_d       ,act=>tiup              ,scan=>Y ,needs_sreset=>0
   wire [0:`THREADS-1]                                          icswxr_thrd_nbusy_d;
   wire [0:`THREADS-1]                                          any_ack_hold_q;		// input=>any_ack_hold_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          any_ack_hold_d;
   wire [0:`THREADS-1]                                          any_ack_val_ok_q;		// input=>any_ack_val_ok_d          ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          any_ack_val_ok_d;
   wire [0:`THREADS-1]                                          arb_release_itag_vld_q;		// input=>arb_release_itag_vld             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          arb_release_itag_vld_d;
   wire                                                        spr_xucr0_cls_q;		// input=>spr_xucr0_cls_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        spr_xucr0_cls_d;
   wire                                                        spr_iucr0_icbi_ack_q;		// input=>spr_iucr0_icbi_ack_d      ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        spr_iucr0_icbi_ack_d;
   wire                                                        spr_lsucr0_dfwd_q ;          // input=>spr_lsucr0_dfwd_d      ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        spr_lsucr0_dfwd_d ;
   wire                                                        ex5_thrd_match_restart_q;    // input=>ex5_thrd_match_restart_d   ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex5_thrd_match_restart_d;
   wire                                                        ex6_thrd_match_restart_q;    // input=>ex6_thrd_match_restart_d   ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex6_thrd_match_restart_d;
   wire                                                        ex5_thrd_nomatch_restart_q;  // input=>ex5_thrd_nomatch_restart_d   ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex5_thrd_nomatch_restart_d;
   wire                                                        ex6_thrd_nomatch_restart_q;  // input=>ex6_thrd_nomatch_restart_d   ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex6_thrd_nomatch_restart_d;
   wire [0:`STQ_ENTRIES-1]                                      ex5_older_ldmiss_d;		// input=>ex5_older_ldmiss_d        ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES]                                        ex5_older_ldmiss_q;		// input=>ex5_older_ldmiss_d        ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex4_fxu1_illeg_lswx_q;		// input=>ex4_fxu1_illeg_lswx_d     ,act=>ex3_fxu0_val         ,scan=>Y ,needs_sreset=>0
   wire                                                        ex4_fxu1_illeg_lswx_d;
   wire                                                        ex4_fxu1_strg_noop_q;		// input=>ex4_fxu1_strg_noop_d      ,act=>ex3_fxu0_val         ,scan=>Y ,needs_sreset=>0
   wire                                                        ex4_fxu1_strg_noop_d;
   wire [0:`THREADS-1]                                          ex3_fxu1_val_q;		// input=>ex3_fxu1_val_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ex3_fxu1_val_d;
   wire [0:`ITAG_SIZE_ENC-1]                                    ex3_fxu1_itag_q;		// input=>ex3_fxu1_itag_d           ,act=>ex2_fxu1_val         ,scan=>Y ,needs_sreset=>0
   wire [0:`ITAG_SIZE_ENC-1]                                    ex3_fxu1_itag_d;
   wire [0:((2**`GPR_WIDTH_ENC)/8)-1]                           ex3_fxu1_dvc1_cmp_q;		// input=>ex3_fxu1_dvc1_cmp_d           ,act=>ex2_fxu1_val         ,scan=>Y ,needs_sreset=>0
   wire [0:((2**`GPR_WIDTH_ENC)/8)-1]                           ex3_fxu1_dvc1_cmp_d;
   wire [0:((2**`GPR_WIDTH_ENC)/8)-1]                           ex3_fxu1_dvc2_cmp_q;		// input=>ex3_fxu1_dvc2_cmp_d           ,act=>ex2_fxu1_val         ,scan=>Y ,needs_sreset=>0
   wire [0:((2**`GPR_WIDTH_ENC)/8)-1]                           ex3_fxu1_dvc2_cmp_d;
   wire [0:`THREADS-1]                                          ex4_fxu1_val_q;		// input=>ex4_fxu1_val_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ex4_fxu1_val_d;
   wire [0:`THREADS-1]                                          ex3_axu_val_q;		// input=>ex3_axu_val_d             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ex3_axu_val_d;
   wire [0:`ITAG_SIZE_ENC-1]                                    ex3_axu_itag_q;		// input=>ex3_axu_itag_d            ,act=>ex2_axu_val          ,scan=>Y ,needs_sreset=>0
   wire [0:`ITAG_SIZE_ENC-1]                                    ex3_axu_itag_d;
   wire [0:`THREADS-1]                                          ex4_axu_val_q;		// input=>ex4_axu_val_d             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          ex4_axu_val_d;
   wire [0:`STQ_ENTRIES-1]                                      ex5_qHit_set_oth_d;		// input=>ex5_qHit_set_oth_d        ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES]                                        ex5_qHit_set_oth_q;		// input=>ex5_qHit_set_oth_d        ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1]                                      ex5_qHit_set_miss_q;		// input=>ex5_qHit_set_miss_d       ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1]                                      ex5_qHit_set_miss_d;
   wire [0:`THREADS-1]                                          iu_icbi_ack_q;		// input=>iu_icbi_ack_d             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          iu_icbi_ack_d;
   wire [0:`THREADS-1]                                          l2_icbi_ack_q;		// input=>l2_icbi_ack_d             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          l2_icbi_ack_d;
   wire                                                        rv1_binv_val_q;		// input=>rv1_binv_val_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        rv1_binv_val_d;
   wire                                                        ex0_binv_val_q;		// input=>ex0_binv_val_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex0_binv_val_d;
   wire                                                        ex1_binv_val_q;		// input=>ex1_binv_val_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex1_binv_val_d;
   wire                                                        ex2_binv_val_q;		// input=>ex2_binv_val_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex2_binv_val_d;
   wire                                                        ex3_binv_val_q;		// input=>ex3_binv_val_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        ex3_binv_val_d;
   wire [64-(`DC_SIZE-3):63-`CL_SIZE]                            rv1_binv_addr_q;		// input=>rv1_binv_addr_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [64-(`DC_SIZE-3):63-`CL_SIZE]                            rv1_binv_addr_d;
   wire [64-(`DC_SIZE-3):63-`CL_SIZE]                            ex0_binv_addr_q;		// input=>ex0_binv_addr_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [64-(`DC_SIZE-3):63-`CL_SIZE]                            ex0_binv_addr_d;
   wire [64-(`DC_SIZE-3):63-`CL_SIZE]                            ex1_binv_addr_q;		// input=>ex1_binv_addr_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [64-(`DC_SIZE-3):63-`CL_SIZE]                            ex1_binv_addr_d;
   wire [64-(`DC_SIZE-3):63-`CL_SIZE]                            ex2_binv_addr_q;		// input=>ex2_binv_addr_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [64-(`DC_SIZE-3):63-`CL_SIZE]                            ex2_binv_addr_d;
   wire [64-(`DC_SIZE-3):63-`CL_SIZE]                            ex3_binv_addr_q;		// input=>ex3_binv_addr_d           ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [64-(`DC_SIZE-3):63-`CL_SIZE]                            ex3_binv_addr_d;
   wire                                                        stq2_binv_blk_cclass_q;		// input=>stq2_binv_blk_cclass_d    ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq2_binv_blk_cclass_d;
   wire                                                        stq2_ici_val_q;		// input=>stq2_ici_val_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq2_ici_val_d;
   wire                                                        stq4_xucr0_cul_q;    // input=>stq4_xucr0_cul_d     ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq4_xucr0_cul_d;
   wire                                                        stq2_reject_dci_q;   // input=>stq2_reject_dci_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq2_reject_dci_d;
   wire                                                        stq3_cmmt_reject_q;  // input=>stq3_cmmt_reject_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq3_cmmt_reject_d;
   wire                                                        stq2_dci_val_q;      // input=>stq2_dci_val_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq2_dci_val_d;
   wire                                                        stq3_cmmt_dci_val_q; // input=>stq3_cmmt_dci_val_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq3_cmmt_dci_val_d;
   wire                                                        stq4_cmmt_dci_val_q; // input=>stq4_cmmt_dci_val_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq4_cmmt_dci_val_d;
   wire                                                        stq5_cmmt_dci_val_q; // input=>stq5_cmmt_dci_val_d            ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire                                                        stq5_cmmt_dci_val_d;
   wire [0:`STQ_ENTRIES-1]                                      ex3_nxt_oldest_q;		// input=>ex3_nxt_oldest_d          ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1]                                      ex3_nxt_oldest_d;
   wire [0:`STQ_ENTRIES-1]                                      stq_tag_val_q;		// input=>stq_tag_val_d             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1]                                      stq_tag_val_d;
   wire [0:`STQ_ENTRIES-1]                                      stq_tag_ptr_q[0:`STQ_ENTRIES-1];		// input=>stq_tag_ptr_d             ,act=>tiup                 ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES-1]                                      stq_tag_ptr_d[0:`STQ_ENTRIES-1];
   wire [0:`STQ_ENTRIES_ENC-1]                                  stq4_cmmt_tag_q;		// input=>stq4_cmmt_tag_d           ,act=>stq3_cmmt_val_q      ,scan=>Y ,needs_sreset=>1
   wire [0:`STQ_ENTRIES_ENC-1]                                  stq4_cmmt_tag_d;
   wire [0:`THREADS-1]                                          dbg_int_en_q;           // input=>dbg_int_en_d           ,act=>tiup      ,scan=>Y ,needs_sreset=>1
   wire [0:`THREADS-1]                                          dbg_int_en_d;


   parameter                                                   rv_lq_vld_offset = 0;
   parameter                                                   rv_lq_ld_vld_offset = rv_lq_vld_offset + 1;
   parameter                                                   ex0_dir_rd_val_offset = rv_lq_ld_vld_offset + 1;
   parameter                                                   rv0_cp_flush_offset = ex0_dir_rd_val_offset + 1;
   parameter                                                   rv1_cp_flush_offset = rv0_cp_flush_offset + `THREADS;
   parameter                                                   ex0_i0_vld_offset = rv1_cp_flush_offset + `THREADS;
   parameter                                                   ex0_i0_flushed_offset = ex0_i0_vld_offset + `THREADS;
   parameter                                                   ex0_i0_itag_offset = ex0_i0_flushed_offset + 1;
   parameter                                                   ex0_i1_vld_offset = ex0_i0_itag_offset + `ITAG_SIZE_ENC;
   parameter                                                   ex0_i1_flushed_offset = ex0_i1_vld_offset + `THREADS;
   parameter                                                   ex0_i1_itag_offset = ex0_i1_flushed_offset + 1;
   parameter                                                   ex1_i0_vld_offset = ex0_i1_itag_offset + `ITAG_SIZE_ENC;
   parameter                                                   ex1_i0_flushed_offset = ex1_i0_vld_offset + `THREADS;
   parameter                                                   ex1_i0_itag_offset = ex1_i0_flushed_offset + 1;
   parameter                                                   ex1_i1_vld_offset = ex1_i0_itag_offset + `ITAG_SIZE_ENC;
   parameter                                                   ex1_i1_flushed_offset = ex1_i1_vld_offset + `THREADS;
   parameter                                                   ex1_i1_itag_offset = ex1_i1_flushed_offset + 1;
   parameter                                                   stqe_alloc_ptr_offset = ex1_i1_itag_offset + `ITAG_SIZE_ENC;
   parameter                                                   stqe_alloc_offset = stqe_alloc_ptr_offset + `STQ_ENTRIES;
   parameter                                                   stqe_addr_val_offset = stqe_alloc_offset + `STQ_ENTRIES;
   parameter                                                   stqe_fwd_addr_val_offset = stqe_addr_val_offset + `STQ_ENTRIES;
   parameter                                                   stqe_rotcmp_offset = stqe_fwd_addr_val_offset + `STQ_ENTRIES;
   parameter                                                   stqe_data_val_offset = stqe_rotcmp_offset + 16 * `STQ_ENTRIES;
   parameter                                                   stqe_data_nxt_offset = stqe_data_val_offset + `STQ_ENTRIES;
   parameter                                                   stqe_illeg_lswx_offset = stqe_data_nxt_offset + `STQ_ENTRIES;
   parameter                                                   stqe_strg_noop_offset = stqe_illeg_lswx_offset + `STQ_ENTRIES;
   parameter                                                   stqe_ready_sent_offset = stqe_strg_noop_offset + `STQ_ENTRIES;
   parameter                                                   stqe_odq_resolved_offset = stqe_ready_sent_offset + `STQ_ENTRIES;
   parameter                                                   stqe_compl_rcvd_offset = stqe_odq_resolved_offset + `STQ_ENTRIES;
   parameter                                                   stqe_have_cp_next_offset = stqe_compl_rcvd_offset + `STQ_ENTRIES;
   parameter                                                   stqe_need_ready_ptr_offset = stqe_have_cp_next_offset + `STQ_ENTRIES;
   parameter                                                   stqe_flushed_offset = stqe_need_ready_ptr_offset + `STQ_ENTRIES;
   parameter                                                   stqe_ack_rcvd_offset = stqe_flushed_offset + `STQ_ENTRIES;
   parameter                                                   stqe_lmqhit_offset = stqe_ack_rcvd_offset + `STQ_ENTRIES;
   parameter                                                   stqe_need_ext_ack_offset = stqe_lmqhit_offset + `LMQ_ENTRIES * `STQ_ENTRIES;
   parameter                                                   stqe_blk_loads_offset = stqe_need_ext_ack_offset + `STQ_ENTRIES;
   parameter                                                   stqe_all_thrd_chk_offset = stqe_blk_loads_offset + `STQ_ENTRIES;
   parameter                                                   stqe_itag_offset = stqe_all_thrd_chk_offset + `STQ_ENTRIES;
   parameter                                                   stqe_addr_offset = stqe_itag_offset + `ITAG_SIZE_ENC * `STQ_ENTRIES;
   parameter                                                   stqe_cline_chk_offset = stqe_addr_offset + `REAL_IFAR_WIDTH * `STQ_ENTRIES;
   parameter                                                   stqe_ttype_offset = stqe_cline_chk_offset + `STQ_ENTRIES;
   parameter                                                   stqe_byte_en_offset = stqe_ttype_offset + 6 * `STQ_ENTRIES;
   parameter                                                   stqe_byte_swap_offset = stqe_byte_en_offset + 16 * `STQ_ENTRIES;
   parameter                                                   stqe_wimge_offset = stqe_byte_swap_offset + `STQ_ENTRIES;
   parameter                                                   stqe_opsize_offset = stqe_wimge_offset + 5 * `STQ_ENTRIES;
   parameter                                                   stqe_axu_val_offset = stqe_opsize_offset + 3 * `STQ_ENTRIES;
   parameter                                                   stqe_epid_val_offset = stqe_axu_val_offset + `STQ_ENTRIES;
   parameter                                                   stqe_usr_def_offset = stqe_epid_val_offset + `STQ_ENTRIES;
   parameter                                                   stqe_is_store_offset = stqe_usr_def_offset + 4 * `STQ_ENTRIES;
   parameter                                                   stqe_is_sync_offset = stqe_is_store_offset + `STQ_ENTRIES;
   parameter                                                   stqe_is_resv_offset = stqe_is_sync_offset + `STQ_ENTRIES;
   parameter                                                   stqe_is_icswxr_offset = stqe_is_resv_offset + `STQ_ENTRIES;
   parameter                                                   stqe_is_icbi_offset = stqe_is_icswxr_offset + `STQ_ENTRIES;
   parameter                                                   stqe_is_inval_op_offset = stqe_is_icbi_offset + `STQ_ENTRIES;
   parameter                                                   stqe_dreq_val_offset = stqe_is_inval_op_offset + `STQ_ENTRIES;
   parameter                                                   stqe_has_data_offset = stqe_dreq_val_offset + `STQ_ENTRIES;
   parameter                                                   stqe_send_l2_offset = stqe_has_data_offset + `STQ_ENTRIES;
   parameter                                                   stqe_lock_clr_offset = stqe_send_l2_offset + `STQ_ENTRIES;
   parameter                                                   stqe_watch_clr_offset = stqe_lock_clr_offset + `STQ_ENTRIES;
   parameter                                                   stqe_l_fld_offset = stqe_watch_clr_offset + `STQ_ENTRIES;
   parameter                                                   stqe_thrd_id_offset = stqe_l_fld_offset + 2 * `STQ_ENTRIES;
   parameter                                                   stqe_tgpr_offset = stqe_thrd_id_offset + `THREADS * `STQ_ENTRIES;
   parameter                                                   stqe_dvc_en_offset = stqe_tgpr_offset + AXU_TARGET_ENC * `STQ_ENTRIES;
   parameter                                                   stqe_dacrw_offset = stqe_dvc_en_offset + 2 * `STQ_ENTRIES;
   parameter                                                   stqe_dvcr_cmpr_offset = stqe_dacrw_offset + 4 * `STQ_ENTRIES;
   parameter                                                   stqe_qHit_held_offset = stqe_dvcr_cmpr_offset + 2 * `STQ_ENTRIES;
   parameter                                                   stqe_held_early_clr_offset = stqe_qHit_held_offset + `STQ_ENTRIES;
   parameter                                                   stqe_data1_offset = stqe_held_early_clr_offset + `STQ_ENTRIES;
   parameter                                                   ex4_fxu1_data_ptr_offset = stqe_data1_offset + `STQ_DATA_SIZE * `STQ_ENTRIES;
   parameter                                                   ex4_axu_data_ptr_offset = ex4_fxu1_data_ptr_offset + `STQ_ENTRIES;
   parameter                                                   ex4_fu_data_offset = ex4_axu_data_ptr_offset + `STQ_ENTRIES;
   parameter                                                   cp_flush_offset = ex4_fu_data_offset + `STQ_DATA_SIZE;
   parameter                                                   cp_next_val_offset = cp_flush_offset + `THREADS;
   parameter                                                   cp_next_itag_offset = cp_next_val_offset + `THREADS;
   parameter                                                   cp_i0_completed_offset = cp_next_itag_offset + `THREADS * `ITAG_SIZE_ENC;
   parameter                                                   cp_i0_completed_itag_offset = cp_i0_completed_offset + `THREADS;
   parameter                                                   cp_i1_completed_offset = cp_i0_completed_itag_offset + `THREADS * `ITAG_SIZE_ENC;
   parameter                                                   cp_i1_completed_itag_offset = cp_i1_completed_offset + `THREADS;
   parameter                                                   stq_cpl_need_hold_offset = cp_i1_completed_itag_offset + `THREADS * `ITAG_SIZE_ENC;
   parameter                                                   iu_lq_icbi_complete_offset = stq_cpl_need_hold_offset + 1;
   parameter                                                   iu_icbi_ack_offset = iu_lq_icbi_complete_offset + `THREADS;
   parameter                                                   l2_icbi_ack_offset = iu_icbi_ack_offset + `THREADS;
   parameter                                                   rv1_binv_val_offset = l2_icbi_ack_offset + `THREADS;
   parameter                                                   ex0_binv_val_offset = rv1_binv_val_offset + 1;
   parameter                                                   ex1_binv_val_offset = ex0_binv_val_offset + 1;
   parameter                                                   ex2_binv_val_offset = ex1_binv_val_offset + 1;
   parameter                                                   ex3_binv_val_offset = ex2_binv_val_offset + 1;
   parameter                                                   rv1_binv_addr_offset = ex3_binv_val_offset + 1;
   parameter                                                   ex0_binv_addr_offset = rv1_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1);
   parameter                                                   ex1_binv_addr_offset = ex0_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1);
   parameter                                                   ex2_binv_addr_offset = ex1_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1);
   parameter                                                   ex3_binv_addr_offset = ex2_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1);
   parameter                                                   stq2_binv_blk_cclass_offset = ex3_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1);
   parameter                                                   stq2_ici_val_offset = stq2_binv_blk_cclass_offset + 1;
   parameter                                                   stq4_xucr0_cul_offset = stq2_ici_val_offset + 1;
   parameter                                                   stq2_reject_dci_offset = stq4_xucr0_cul_offset + 1;
   parameter                                                   stq3_cmmt_reject_offset = stq2_reject_dci_offset + 1;
   parameter                                                   stq2_dci_val_offset = stq3_cmmt_reject_offset + 1;
   parameter                                                   stq3_cmmt_dci_val_offset = stq2_dci_val_offset + 1;
   parameter                                                   stq4_cmmt_dci_val_offset = stq3_cmmt_dci_val_offset + 1;
   parameter                                                   stq5_cmmt_dci_val_offset = stq4_cmmt_dci_val_offset + 1;
   parameter                                                   stq2_cmmt_flushed_offset = stq5_cmmt_dci_val_offset + 1;
   parameter                                                   stq3_cmmt_flushed_offset = stq2_cmmt_flushed_offset + 1;
   parameter                                                   stq4_cmmt_flushed_offset = stq3_cmmt_flushed_offset + 1;
   parameter                                                   stq5_cmmt_flushed_offset = stq4_cmmt_flushed_offset + 1;
   parameter                                                   stq6_cmmt_flushed_offset = stq5_cmmt_flushed_offset + 1;
   parameter                                                   stq7_cmmt_flushed_offset = stq6_cmmt_flushed_offset + 1;
   parameter                                                   stq1_cmmt_ptr_offset = stq7_cmmt_flushed_offset + 1;
   parameter                                                   stq2_cmmt_ptr_offset = stq1_cmmt_ptr_offset + `STQ_ENTRIES;
   parameter                                                   stq3_cmmt_ptr_offset = stq2_cmmt_ptr_offset + `STQ_ENTRIES;
   parameter                                                   stq4_cmmt_ptr_offset = stq3_cmmt_ptr_offset + `STQ_ENTRIES;
   parameter                                                   stq5_cmmt_ptr_offset = stq4_cmmt_ptr_offset + `STQ_ENTRIES;
   parameter                                                   stq6_cmmt_ptr_offset = stq5_cmmt_ptr_offset + `STQ_ENTRIES;
   parameter                                                   stq7_cmmt_ptr_offset = stq6_cmmt_ptr_offset + `STQ_ENTRIES;
   parameter                                                   stq2_cmmt_val_offset = stq7_cmmt_ptr_offset + `STQ_ENTRIES;
   parameter                                                   stq3_cmmt_val_offset = stq2_cmmt_val_offset + 1;
   parameter                                                   stq4_cmmt_val_offset = stq3_cmmt_val_offset + 1;
   parameter                                                   stq5_cmmt_val_offset = stq4_cmmt_val_offset + 1;
   parameter                                                   stq6_cmmt_val_offset = stq5_cmmt_val_offset + 1;
   parameter                                                   stq7_cmmt_val_offset = stq6_cmmt_val_offset + 1;
   parameter                                                   ext_ack_queue_v_offset = stq7_cmmt_val_offset + 1;
   parameter                                                   ext_ack_queue_sync_offset = ext_ack_queue_v_offset + `THREADS;
   parameter                                                   ext_ack_queue_stcx_offset = ext_ack_queue_sync_offset + `THREADS;
   parameter                                                   ext_ack_queue_icswxr_offset = ext_ack_queue_stcx_offset + `THREADS;
   parameter                                                   ext_ack_queue_itag_offset = ext_ack_queue_icswxr_offset + `THREADS;
   parameter                                                   ext_ack_queue_cr_wa_offset = ext_ack_queue_itag_offset + `ITAG_SIZE_ENC * `THREADS;
   parameter                                                   ext_ack_queue_dacrw_det_offset = ext_ack_queue_cr_wa_offset + (`CR_POOL_ENC+`THREADS_POOL_ENC) * `THREADS;
   parameter                                                   ext_ack_queue_dacrw_rpt_offset = ext_ack_queue_dacrw_det_offset + 4 * `THREADS;
   parameter                                                   stq2_mftgpr_val_offset = ext_ack_queue_dacrw_rpt_offset + `THREADS;
   parameter                                                   stq2_rtry_cnt_offset = stq2_mftgpr_val_offset + 1;
   parameter                                                   ex5_stq_restart_offset = stq2_rtry_cnt_offset + 3;
   parameter                                                   ex5_stq_restart_miss_offset = ex5_stq_restart_offset + 1;
   parameter                                                   stq_fwd_pri_mask_offset = ex5_stq_restart_miss_offset + 1;
   parameter                                                   ex5_fwd_val_offset = stq_fwd_pri_mask_offset + (`STQ_FWD_ENTRIES-1);
   parameter                                                   ex5_fwd_data_offset = ex5_fwd_val_offset + 1;
   parameter                                                   ex4_set_stq_offset = ex5_fwd_data_offset + `STQ_DATA_SIZE;
   parameter                                                   ex5_set_stq_offset = ex4_set_stq_offset + `STQ_ENTRIES;
   parameter                                                   ex4_ldreq_val_offset = ex5_set_stq_offset + `STQ_ENTRIES;
   parameter                                                   ex4_pfetch_val_offset = ex4_ldreq_val_offset + `THREADS;
   parameter                                                   ex3_streq_val_offset = ex4_pfetch_val_offset + 1;
   parameter                                                   ex5_streq_val_offset = ex3_streq_val_offset + `THREADS;
   parameter                                                   ex4_wchkall_val_offset = ex5_streq_val_offset + `THREADS;
   parameter                                                   hwsync_ack_offset = ex4_wchkall_val_offset + `THREADS;
   parameter                                                   lwsync_ack_offset = hwsync_ack_offset + `THREADS;
   parameter                                                   icswxr_ack_offset = lwsync_ack_offset + `THREADS;
   parameter                                                   icswxr_ack_dly1_offset = icswxr_ack_offset + 1;
   parameter                                                   local_instr_ack_offset = icswxr_ack_dly1_offset + 1;
   parameter                                                   resv_ack_offset = local_instr_ack_offset + `THREADS;
   parameter                                                   stcx_pass_offset = resv_ack_offset + `THREADS;
   parameter                                                   icbi_ack_offset = stcx_pass_offset + `THREADS;
   parameter                                                   icbi_val_offset = icbi_ack_offset + `THREADS;
   parameter                                                   icbi_addr_offset = icbi_val_offset + `THREADS;
   parameter                                                   ici_val_offset = icbi_addr_offset + (57-RI+1);
   parameter                                                   credit_free_offset = ici_val_offset + 1;
   parameter                                                   ex4_fwd_agecmp_offset = credit_free_offset + `THREADS;
   parameter                                                   ex3_req_itag_offset = ex4_fwd_agecmp_offset + `STQ_ENTRIES;
   parameter                                                   ex4_req_itag_offset = ex3_req_itag_offset + `ITAG_SIZE_ENC;
   parameter                                                   ex4_req_byte_en_offset = ex4_req_itag_offset + `ITAG_SIZE_ENC;
   parameter                                                   ex4_req_p_addr_l_offset = ex4_req_byte_en_offset + 16;
   parameter                                                   ex4_req_opsize_offset = ex4_req_p_addr_l_offset + 6;
   parameter                                                   ex4_req_algebraic_offset = ex4_req_opsize_offset + 3;
   parameter                                                   ex3_req_thrd_id_offset = ex4_req_algebraic_offset + 1;
   parameter                                                   ex4_req_thrd_id_offset = ex3_req_thrd_id_offset + `THREADS;
   parameter                                                   ex5_req_thrd_id_offset = ex4_req_thrd_id_offset + `THREADS;
   parameter                                                   thrd_held_offset = ex5_req_thrd_id_offset + `THREADS;
   parameter                                                   rv0_cr_hole_offset = thrd_held_offset + `THREADS;
   parameter                                                   rv1_cr_hole_offset = rv0_cr_hole_offset + `THREADS;
   parameter                                                   ex0_cr_hole_offset = rv1_cr_hole_offset + `THREADS;
   parameter                                                   cr_ack_offset = ex0_cr_hole_offset + `THREADS;
   parameter                                                   sync_ack_save_offset = cr_ack_offset + `THREADS;
   parameter                                                   cr_we_offset = sync_ack_save_offset + 1;
   parameter                                                   cr_wa_offset = cr_we_offset + 1;
   parameter                                                   cr_wd_offset = cr_wa_offset + (`CR_POOL_ENC+`THREADS_POOL_ENC-1+1);
   parameter                                                   stcx_thrd_fail_offset = cr_wd_offset + 4;
   parameter                                                   icswxr_thrd_busy_offset = stcx_thrd_fail_offset + `THREADS;
   parameter                                                   icswxr_thrd_nbusy_offset = icswxr_thrd_busy_offset + `THREADS;
   parameter                                                   stq3_cmmt_attmpt_offset = icswxr_thrd_nbusy_offset + `THREADS;
   parameter                                                   stq_need_hole_offset = stq3_cmmt_attmpt_offset + 1;
   parameter                                                   any_ack_hold_offset = stq_need_hole_offset + 1;
   parameter                                                   any_ack_val_ok_offset = any_ack_hold_offset + `THREADS;
   parameter                                                   arb_release_itag_vld_offset = any_ack_val_ok_offset + `THREADS;
   parameter                                                   spr_xucr0_cls_offset = arb_release_itag_vld_offset + `THREADS;
   parameter                                                   spr_iucr0_icbi_ack_offset = spr_xucr0_cls_offset + 1;
   parameter                                                   spr_lsucr0_dfwd_offset = spr_iucr0_icbi_ack_offset + 1;
   parameter                                                   ex5_thrd_match_restart_offset = spr_lsucr0_dfwd_offset + 1;
   parameter                                                   ex6_thrd_match_restart_offset = ex5_thrd_match_restart_offset + 1;
   parameter                                                   ex5_thrd_nomatch_restart_offset = ex6_thrd_match_restart_offset + 1;
   parameter                                                   ex6_thrd_nomatch_restart_offset = ex5_thrd_nomatch_restart_offset + 1;
   parameter                                                   ex5_older_ldmiss_offset = ex6_thrd_nomatch_restart_offset + 1;

   parameter                                                   ex4_fxu1_illeg_lswx_offset = ex5_older_ldmiss_offset + `STQ_ENTRIES;
   parameter                                                   ex4_fxu1_strg_noop_offset = ex4_fxu1_illeg_lswx_offset + 1;
   parameter                                                   ex3_fxu1_val_offset = ex4_fxu1_strg_noop_offset + 1;
   parameter                                                   ex3_fxu1_itag_offset = ex3_fxu1_val_offset + `THREADS;
   parameter                                                   ex3_fxu1_dvc1_cmp_offset = ex3_fxu1_itag_offset + `ITAG_SIZE_ENC;
   parameter                                                   ex3_fxu1_dvc2_cmp_offset = ex3_fxu1_dvc1_cmp_offset + (((2**`GPR_WIDTH_ENC)/8)-1-0+1);
   parameter                                                   ex4_fxu1_val_offset = ex3_fxu1_dvc2_cmp_offset + (((2**`GPR_WIDTH_ENC)/8)-1-0+1);
   parameter                                                   ex3_axu_val_offset = ex4_fxu1_val_offset + `THREADS;
   parameter                                                   ex3_axu_itag_offset = ex3_axu_val_offset + `THREADS;
   parameter                                                   ex4_axu_val_offset = ex3_axu_itag_offset + `ITAG_SIZE_ENC;
   parameter                                                   ex5_qHit_set_oth_offset = ex4_axu_val_offset + `THREADS;
   parameter                                                   ex5_qHit_set_miss_offset = ex5_qHit_set_oth_offset + `STQ_ENTRIES;
   parameter                                                   ex3_nxt_oldest_offset = ex5_qHit_set_miss_offset + `STQ_ENTRIES;
   parameter                                                   stq_tag_val_offset = ex3_nxt_oldest_offset + `STQ_ENTRIES;
   parameter                                                   stq_tag_ptr_offset = stq_tag_val_offset + `STQ_ENTRIES;
   parameter                                                   stq4_cmmt_tag_offset = stq_tag_ptr_offset + `STQ_ENTRIES * `STQ_ENTRIES;
   parameter                                                   dbg_int_en_offset =  stq4_cmmt_tag_offset + `STQ_ENTRIES_ENC;
   parameter                                                   scan_right = dbg_int_en_offset + `THREADS;



   wire [0:scan_right-1]                                       siv;
   wire [0:scan_right-1]                                       sov;

      // Signals
   wire                                                        spr_xucr0_64cls;
   wire                                                        a2_icbi_ack_en;
   wire                                                        ex3_req_act;
   wire [0:8]                                                  stqe_state[0:`STQ_ENTRIES-1];
   reg  [0:`STQ_ENTRIES]                                        set_stqe_odq_resolved;
   wire [0:`STQ_ENTRIES-1]                                      stqe_ready_state;
   wire [0:`STQ_ENTRIES-1]                                      stqe_ready_ctl_act;
   wire [0:`STQ_ENTRIES-1]                                      stqe_ready_dat_act;
   wire [0:`STQ_ENTRIES]                                        stq7_entry_delete;
   wire                                                        stq_push_down;
   wire [0:`STQ_ENTRIES-1]                                      stqe_need_ready_ptr_r1;
   wire [0:`STQ_ENTRIES-1]                                      stqe_need_ready_ptr_l1;
   wire [0:1]                                                  stqe_need_ready_ptr_sel;
   wire [0:`STQ_ENTRIES-1]                                      stqe_need_ready;
   wire [0:`STQ_ENTRIES-1]                                      stqe_need_ready_blk;
   wire [0:`STQ_ENTRIES-1]                                      stqe_need_ready_rpt;
   wire [0:`STQ_ENTRIES]                                        cp_i0_itag_cmp;
   wire [0:`STQ_ENTRIES]                                        cp_i1_itag_cmp;
   wire                                                        rv1_i0_drop_req;
   wire                                                        rv1_i1_drop_req;
   wire                                                        rv1_i0_act;
   wire                                                        rv1_i1_act;
   wire                                                        stq_alloc_sel;
   wire                                                        stq_act;
   wire [0:1]                                                  stq_alloc_val;
   wire [0:1]                                                  stq_alloc_flushed;
   wire [0:`ITAG_SIZE_ENC-1]                                    stqe_alloc_itag0;
   wire [0:`ITAG_SIZE_ENC-1]                                    stqe_alloc_itag1;
   wire [0:`THREADS-1]                                          stq_alloc_thrd_id0;
   wire [0:`THREADS-1]                                          stq_alloc_thrd_id1;
   wire [0:`STQ_ENTRIES-1]                                      stqe_alloc_ptr_r1;
   wire [0:`STQ_ENTRIES-1]                                      stqe_alloc_ptr_r2;
   wire [0:`STQ_ENTRIES-1]                                      stqe_alloc_ptr_l1;
   wire [0:`STQ_ENTRIES-1]                                      stqe_alloc_i0_wrt_ptr;
   wire [0:`STQ_ENTRIES-1]                                      stqe_alloc_i1_wrt_ptr;
   wire [0:2]                                                  stqe_alloc_ptr_sel;
   wire [0:`STQ_ENTRIES-1]                                      stqe_wrt_new;
   wire                                                        stq1_cmmt_act;
   wire [0:`STQ_ENTRIES-1]                                      stq1_cmmt_ptr_r1;
   wire [0:`STQ_ENTRIES-1]                                      stq1_cmmt_ptr_l1;
   wire [0:2]                                                  stq1_cmmt_ptr_sel;
   wire [0:`STQ_ENTRIES-1]                                      stq2_cmmt_ptr_l1;
   wire [0:`STQ_ENTRIES-1]                                      stq2_cmmt_ptr_remove;
   wire [64-(`DC_SIZE-3):57]                                    stq1_cclass;
   wire                                                        stq1_rel_blk_cclass;
   wire                                                        stq1_binv1_cclass_m;
   wire                                                        stq1_binv2_cclass_m;
   wire                                                        stq1_binv3_cclass_m;
   wire                                                        stq1_binv_blk_cclass;
   wire                                                        stq1_binv_wclrall;
   wire                                                        stq2_reject_val;
   wire                                                        stq2_reject_rv_coll;
   wire                                                        stq2_cmmt_reject;
   wire                                                        stqe0_icswxdot_val;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_addrcmp_hi;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_addrcmp_lo;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_addrcmp;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_sel;
   reg  [0:`STQ_FWD_ENTRIES-1]                                  fwd_pri_mask;
   reg  [0:`STQ_FWD_ENTRIES-1]                                  ex4_stqe_match_addr;
   reg  [0:`STQ_FWD_ENTRIES-1]                                  ex4_stqe_match;
   reg  [0:`STQ_FWD_ENTRIES-1]                                  stq_mask;
   wire [0:`STQ_ENTRIES-1]                                      stqe_fwd_enable;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_entry;
   wire                                                        ex4_fwd_val;
   wire [0:`STQ_FWD_ENTRIES-1]                                  ex4_fwd_chk_fail;
   wire [`STQ_FWD_ENTRIES:`STQ_ENTRIES-1]                        ex4_nofwd_entry;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_restart_entry;
   wire                                                        ex4_fwd_restart;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_endian_mux;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_is_store_mux;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_is_cline_chk;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_is_miss_chk;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_is_larx_chk;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_is_blk_load_chk;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_is_gload_chk;
   wire [0:`STQ_ENTRIES-1]                                      stqe_rej_newer_gload;
   wire [0:`STQ_ENTRIES-1]                                      stqe_rej_other;
   wire [0:`STQ_ENTRIES-1]                                      stqe_rej_cline_chk;
   wire [0:`STQ_ENTRIES-1]                                      stqe_rej_cline_miss;
   wire [0:`STQ_ENTRIES-1]                                      stqe_rej_wchkall;
   wire [0:`STQ_ENTRIES-1]                                      stqe_rej_hit_no_fwd;
   wire [0:`STQ_ENTRIES]                                        set_hold_early_clear;
   wire [0:`STQ_ENTRIES]                                        ex5_qHit_set_miss;
   wire [0:`STQ_ENTRIES-1]                                      ex4_qHit_set_oth;
   wire [0:`STQ_ENTRIES-1]                                      ex4_qHit_set_miss;
   wire [0:`STQ_ENTRIES-1]                                      ex4_older_ldmiss;
   wire [0:`STQ_ENTRIES-1]                                      ex4_fwd_rej_guarded;
   wire [0:`STQ_ENTRIES-1]                                      stqe_itag_act;
   wire [0:`STQ_ENTRIES]                                        stqe_data_val;
   wire [0:`STQ_ENTRIES-1]                                      stqe_data_act;
   wire [0:`STQ_ENTRIES]                                        ex3_stq_data_val;
   wire [0:`STQ_ENTRIES-1]                                      stqe_fxu1_data_sel;
   wire [0:`STQ_ENTRIES-1]                                      stqe_axu_data_sel;
   wire [0:`STQ_ENTRIES]                                        stqe_fxu1_dvcr_val;
   wire [0:`STQ_ENTRIES-1]                                      stqe_fxu1_data_val;
   wire [0:`STQ_ENTRIES-1]                                      stqe_axu_data_val;
   wire [0:`STQ_ENTRIES-1]                                      ex3_fxu1_data_ptr;
   wire                                                        cpl_ready;
   wire                                                        skip_ready;
   wire [0:`STQ_ENTRIES-1]                                      stqe_skip_ready;
   reg [0:`ITAG_SIZE_ENC-1]                                     cpl_ready_itag;
   wire [0:`ITAG_SIZE_ENC-1]                                    cpl_ready_itag_final;
   reg [0:`ITAG_SIZE_ENC-1]                                     ext_act_queue_itag;
   reg [0:3]                                                   ext_act_queue_dacrw_det;
   reg                                                         ext_act_queue_dacrw_rpt;
   reg [0:`ITAG_SIZE_ENC-1]                                     stq_ext_act_itag;
   reg [0:3]                                                   stq_ext_act_dacrw_det;
   reg                                                         stq_ext_act_dacrw_rpt;
   reg [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]                       stq_ext_act_cr_wa;
   reg [0:`THREADS-1]                                           cpl_ready_thrd_id;
   wire [0:`THREADS-1]                                          cpl_ready_tid_final;
   reg [0:5]                                                   cpl_ttype;
   reg                                                         cpl_dreq_val;
   wire                                                        dacrw_report;
   wire [0:3]                                                  dacrw_det;
   wire [0:`STQ_ENTRIES-1]                                      stqe_guarded;
   wire [0:`STQ_ENTRIES-1]                                      ex3_fwd_agecmp;
   wire                                                        ex3_ex4_agecmp;
   wire                                                        ex3_ex4_agecmp_sametid;
   wire                                                        ex3_ex4_byte_en_hit;
   wire                                                        ex4_rej_newer_gload;
   wire                                                        stqe_need_ready_act;
   wire                                                        stqe_need_ready_next;
   wire                                                        stq2_rtry_cnt_act;
   wire                                                        rtry_cnt_reset;
   wire                                                        ex4_rej_other;
   wire                                                        ex4_rej_sync_pending;
   wire                                                        ex4_rej_cline_chk;
   wire                                                        ex4_rej_cline_miss;
   wire                                                        ex4_rej_wchkall;
   wire                                                        ex4_thrd_match_restart;
   wire                                                        ex4_thrd_nomatch_restart;
   wire [0:`STQ_ENTRIES-1]                                      stqe_l_zero;
   wire [0:`STQ_ENTRIES]                                        stqe_flushed;
   wire [0:`STQ_ENTRIES]                                        stqe_alloc_flushed;
   wire [0:`THREADS-1]                                          any_ack_val;
   wire [0:`THREADS-1]                                          any_ack_rcvd;
   wire [0:`STQ_ENTRIES-1]                                      ex4_byte_en_ok;
   wire [0:`STQ_ENTRIES-1]                                      ex4_byte_en_miss;
   wire [0:`STQ_ENTRIES-1]                                      ex4_1byte_chk_ok;
   wire [0:`STQ_ENTRIES-1]                                      ex4_byte_chk_ok;
   wire [0:`STQ_ENTRIES-1]                                      ex4_thrd_match;
   wire [0:`STQ_ENTRIES-1]                                      ex4_thrd_id_ok;
   wire [0:`STQ_ENTRIES-1]                                      stqe_flush_cmp;
   wire [0:`STQ_ENTRIES]                                        stqe_compl_rcvd;
   wire [0:`THREADS-1]                                          ex5_streq_val;
   wire [0:`THREADS-1]                                          ex3_streq_val;
   wire [0:`THREADS-1]                                          ex4_ldreq_val;
   wire [0:`THREADS-1]                                          ex4_wchkall_val;
   wire                                                        ex3_streq_valid;
   wire                                                        ex4_streq_valid;
   wire                                                        ex5_streq_valid;
   wire                                                        ex4_ldreq_valid;
   wire                                                        ex3_pfetch_val;
   wire                                                        ex4_wchkall_valid;
   wire                                                        ex4_fwd_hit;
   wire                                                        ex0_i0_flushed;
   wire                                                        ex0_i1_flushed;
   wire                                                        ex1_i0_flushed;
   wire                                                        ex1_i1_flushed;
   reg [0:`THREADS-1]                                          stq_empty;
   wire [0:`STQ_ENTRIES-1]                                      stq_chk_alloc;
   wire [0:`THREADS-1]                                          cr_ack;
   wire [0:`THREADS-1]                                          sync_ack;
   wire [0:`THREADS-1]                                          cr_thrd;
   wire [0:`THREADS-1]                                          cr_block;
   wire [0:`THREADS-1]                                          resv_ack;
   wire [0:`THREADS-1]                                          stcx_pass;
   wire                                                        cr_xer_so;
   wire                                                        cr_stcx_pass;
   wire [0:`THREADS-1]                                          icswxr_ack_val;
   wire [0:`THREADS-1]                                          icswxr_ack_thrd;
   wire [0:`THREADS-1]                                          sync_ack_all;
   wire [0:`THREADS-1]                                          perf_stq_stcx_fail;
   wire [0:`THREADS-1]                                          perf_stq_icswxr_nbusy;
   wire [0:`THREADS-1]                                          perf_stq_icswxr_busy;
   wire                                                         perf_stq_cmmt_attmpt;
   wire                                                         perf_stq_cmmt_val;
   wire                                                         perf_stq_need_hole;
   wire [0:15]                                                 stq_rotcmp;
   wire [0:`STQ_ENTRIES]                                        ex3_agecmp;
   wire [0:3]                                                  ex4_rot_sel_be[0:`STQ_ENTRIES-1];
   wire [0:3]                                                  ex4_rot_sel_le[0:`STQ_ENTRIES-1];
   wire [0:3]                                                  ex4_rot_sel[0:`STQ_ENTRIES-1];
   wire [(128-`STQ_DATA_SIZE):127]                              stqe_fwd_data[0:`STQ_ENTRIES-1];
   wire [0:63]                                                 stqe_data1_swzl[0:`STQ_ENTRIES-1];
   wire [0:63]                                                 ex4_fwd_data1[0:`STQ_ENTRIES-1];
   wire [0:63]                                                 ex4_fwd_data1_swzl[0:`STQ_ENTRIES-1];
   wire [0:7]                                                  ex4_se_b[0:`STQ_ENTRIES-1];
   wire [0:`STQ_ENTRIES-1]                                      ex4_se;
   wire [0:`STQ_ENTRIES-1]                                      ex4_sext;
   wire [0:3]                                                  ex4_rot_mask;
   wire [0:4]                                                  ex4_req_opsize_1hot;
   wire                                                        ex4_req_opsize1;
   wire [0:3]                                                  ex4_hw_addr_cmp[0:`STQ_ENTRIES-1];
   wire [0:3]                                                  ex4_rev_rot_sel[0:`STQ_ENTRIES-1];
   wire [0:3]                                                  ex4_shft_rot_sel[0:`STQ_ENTRIES-1];
   wire [0:3]                                                  ex4_sext8_le_sel[0:`STQ_ENTRIES-1];
   wire [0:3]                                                  ex4_sext4_le_sel[0:`STQ_ENTRIES-1];
   wire [0:3]                                                  ex4_sext2_le_sel[0:`STQ_ENTRIES-1];
   wire [0:3]                                                  ex4_sext_le_sel[0:`STQ_ENTRIES-1];
   wire [0:3]                                                  ex4_sext_sel[0:`STQ_ENTRIES-1];
   wire [0:3]                                                  stqe_rotcmp_val[0:`STQ_ENTRIES-1];
   wire [0:`STQ_ENTRIES-1]                                      stqe_opsize8;
   wire [0:`STQ_ENTRIES-1]                                      stqe_opsize4;
   wire [0:`STQ_ENTRIES-1]                                      stqe_opsize2;
   wire [0:`STQ_ENTRIES-1]                                      stqe_opsize1;
   wire [0:`STQ_ENTRIES-1]                                      ex4_opsize8_be;
   wire [0:`STQ_ENTRIES-1]                                      ex4_opsize4_be;
   wire [0:`STQ_ENTRIES-1]                                      ex4_opsize2_be;
   wire [0:`STQ_ENTRIES-1]                                      ex4_opsize1_be;
   wire [0:`STQ_ENTRIES-1]                                      ex4_opsize8_le;
   wire [0:`STQ_ENTRIES-1]                                      ex4_opsize4_le;
   wire [0:`STQ_ENTRIES-1]                                      ex4_opsize2_le;
   wire [0:`STQ_ENTRIES-1]                                      ex4_opsize1_le;
   wire [0:2]                                                  ex3_opsize_1hot;
   wire [0:3]                                                  ex3_rotcmp2_fld;
   wire [0:3]                                                  ex3_rotcmp3_fld;
   wire                                                        stq1_cmmt_dreq_val;
   wire                                                        stq3_cmmt_dreq_val;
   wire                                                        stq1_cmmt_send_l2;
   wire                                                        stq3_cmmt_send_l2;
   wire                                                        stq1_cmmt_dvc_val;
   wire                                                        stq3_cmmt_dvc_val;
   reg [64-`REAL_IFAR_WIDTH:63]                                 stq1_p_addr;
   reg [0:5]                                                   stq1_ttype;
   wire                                                        stq1_mftgpr_val;
   reg                                                         stq1_wclr_all;
   reg [0:`THREADS-1]                                           stq2_thrd_id;
   reg [0:5]                                                   stq3_ttype;
   reg [0:`THREADS-1]                                           stq3_tid;
   reg [0:1]                                                   stq3_tid_enc;
   wire [0:`STQ_ENTRIES-1]                                      ex3_data_val;
   wire [0:`STQ_ENTRIES-1]                                      ex3_illeg_lswx;
   wire [0:`STQ_ENTRIES-1]                                      ex3_strg_noop;
   reg  [0:1]                                                  fxu1_spr_dbcr2_dvc1m;
   reg  [0:1]                                                  fxu1_spr_dbcr2_dvc2m;
   reg  [8-(2**`GPR_WIDTH_ENC)/8:7]                             fxu1_spr_dbcr2_dvc1be;
   reg  [8-(2**`GPR_WIDTH_ENC)/8:7]                             fxu1_spr_dbcr2_dvc2be;
   wire                                                        ex3_fxu1_dvc1r_cmpr;
   wire                                                        ex3_fxu1_dvc2r_cmpr;
   wire [0:1]                                                  ex3_fxu1_dvcr_cmpr;
   wire [0:`STQ_ENTRIES-1]                                      stqe_dacrw_det0;
   wire [0:`STQ_ENTRIES-1]                                      stqe_dacrw_det1;
   wire [0:`STQ_ENTRIES-1]                                      stqe_dacrw_det2;
   wire [0:`STQ_ENTRIES-1]                                      stqe_dacrw_det3;
   wire [0:`STQ_ENTRIES-1]                                      stqe_dvc_int_det;
   wire [0:`STQ_ENTRIES-1]                                      stq2_cmmt_entry;
   wire [0:`STQ_ENTRIES-1]                                      stq3_cmmt_entry;
   wire [0:`STQ_ENTRIES-1]                                      stq4_cmmt_entry;
   wire [0:`STQ_ENTRIES-1]                                      stq5_cmmt_entry;
   wire [0:`STQ_ENTRIES-1]                                      stq6_cmmt_entry;
   wire [0:`STQ_ENTRIES-1]                                      stq7_cmmt_entry;
   wire [0:`STQ_ENTRIES-1]                                      stqe_cmmt_entry;
   wire [0:`STQ_ENTRIES-1]                                      stqe_qHit_held_set;
   wire [0:`STQ_ENTRIES]                                        stqe_qHit_held_mux;
   wire [0:`STQ_ENTRIES]                                        stqe_qHit_held_clr;
   wire [0:1]                                                  stqe_qHit_held_ctrl[0:`STQ_ENTRIES-1];
   wire [0:`THREADS-1]                                          set_hold_thread;
   wire                                                        ex5_stq_set_hold;
   wire [0:`THREADS-1]                                          clr_hold_thread;
   wire [0:`STQ_ENTRIES]                                        stqe_need_ready_flushed;
   wire                                                        ex2_fxu1_val;
   wire                                                        ex3_fxu1_val;
   wire                                                        ex2_axu_val;
   wire                                                        ex3_axu_val;
   wire [0:11]                                                 stqe_icswx_ct_sel[0:`STQ_ENTRIES-1];
   reg [0:11]                                                  ex3_ct_sel;
   reg [0:1]                                                   ex4_thrd_id_enc;
   wire [64-`REAL_IFAR_WIDTH:63]                                ex4_p_addr_ovrd;
   wire                                                         stq2_cmmt_dci_val;
   wire                                                         stq_dci_inprog;
   wire                                                         stq_reject_dci_coll;
   wire                                                         stq3_dcblc_instr;
   wire                                                         stq3_icblc_instr;
   reg [0:5]                                                   stq6_ttype;
   reg [0:`THREADS-1]                                           stq6_tid;
   wire                                                        stq6_dci;
   wire                                                        stq6_ici;
   reg                                                         stq6_wclr_all_val;
   wire                                                        stq6_icswxnr;
   wire                                                        stq6_mftgpr;
   wire                                                        stq6_local_ack_val;
   wire [0:`THREADS-1]                                          l2_icbi_ack;
   wire [0:`STQ_ENTRIES-1]                                      stqe_valid_sync;
   wire [0:`THREADS-1]                                          stqe_tid_inuse[0:`STQ_ENTRIES-1];
   wire [0:`STQ_ENTRIES]                                        stq_cp_next_val;
   wire [0:`STQ_ENTRIES-1]                                      stq_i0_comp_val;
   wire [0:`STQ_ENTRIES-1]                                      stq_i1_comp_val;
   wire [0:`STQ_ENTRIES-1]                                      ex3_set_stq;
   wire [0:`STQ_ENTRIES-1]                                      ex3_addr_act;
   wire [0:`STQ_ENTRIES-1]                                      ex4_set_stq;
   wire [0:`STQ_ENTRIES-1]                                      ex4_addr_act;
   wire [0:`STQ_ENTRIES-1]                                      ex5_set_stq;
   wire [0:`STQ_ENTRIES-1]                                      ex5_addr_act;
   wire [(128-`STQ_DATA_SIZE):127]                              stqe_data1_mux[0:`STQ_ENTRIES];
   wire                                                        rv_hold;
   wire [0:2]                                                  stq2_rtry_cnt_incr;
   reg  [0:`ITAG_SIZE_ENC-1]                                    stq_cp_next_itag[0:`STQ_ENTRIES];
   reg [0:`ITAG_SIZE_ENC-1]                                     stq_i0_comp_itag[0:`STQ_ENTRIES-1];
   reg [0:`ITAG_SIZE_ENC-1]                                     stq_i1_comp_itag[0:`STQ_ENTRIES-1];
   reg [0:`STQ_ENTRIES-1]                                       ex2_nxt_oldest_ptr;
   reg [0:`STQ_ENTRIES-1]                                       ex2_nxt_youngest_ptr;
   wire                                                        ex2_no_nxt_match;
   wire [0:`STQ_ENTRIES-1]                                      ex2_no_nxt_oldest;
   wire [0:`STQ_ENTRIES-1]                                      ex2_nxt_youngest_shft;
   wire [0:`STQ_ENTRIES-1]                                      ex2_nxt_oldest;
   wire [0:`STQ_ENTRIES-1]                                      stq_tag_available;
   wire [0:`STQ_ENTRIES-1]                                      stq_wrt_i0_ptr;
   wire [0:`STQ_ENTRIES-1]                                      stq_wrt_i1_ptr;
   wire [0:`STQ_ENTRIES-1]                                      stq_wrt_i0_mux;
   reg  [0:`STQ_ENTRIES_ENC-1] 					  stq_tag_i0_entry;
   reg  [0:`STQ_ENTRIES_ENC-1] 					  stq_tag_i1_entry;
   wire [0:`STQ_ENTRIES-1] 					  stq_tag_act;
   wire [0:`STQ_ENTRIES-1] 					  stq_tag_inval;
   wire [0:`STQ_ENTRIES-1] 					  stq_tag_i0_upd_val;
   wire [0:`STQ_ENTRIES-1] 					  stq_tag_i1_upd_val;
   wire [0:`STQ_ENTRIES-1] 					  stq_tag_i0_stq_sel;
   wire [0:`STQ_ENTRIES-1] 					  stq_tag_i1_stq_sel;
   wire [0:`STQ_ENTRIES-1] 					  stq_tag_ptr_compr[0:`STQ_ENTRIES-1];
   wire [0:2] 							  stq_tag_ptr_ctrl[0:`STQ_ENTRIES-1];
   wire [0:`STQ_ENTRIES-1] 					  stq3_cmmt_tag_entry;
   reg  [0:`STQ_ENTRIES_ENC-1] 					  stq3_cmmt_tag;

   // these wires are to convert the ports at the top to an array of itags
   wire [0:`ITAG_SIZE_ENC-1]         iu_lq_cp_next_itag_int[0:`THREADS-1];
   wire [0:`ITAG_SIZE_ENC-1]         iu_lq_i0_completed_itag_int[0:`THREADS-1];
   wire [0:`ITAG_SIZE_ENC-1]         iu_lq_i1_completed_itag_int[0:`THREADS-1];
   wire [0:1]                        ctl_lsq_spr_dbcr2_dvc1m_int[0:`THREADS-1];
   wire [0:7]                        ctl_lsq_spr_dbcr2_dvc1be_int[0:`THREADS-1];
   wire [0:1]                        ctl_lsq_spr_dbcr2_dvc2m_int[0:`THREADS-1];
   wire [0:7]                        ctl_lsq_spr_dbcr2_dvc2be_int[0:`THREADS-1];


   //!! Bugspray Include: lq_stq

   // This is used to convert the wide vector port inputs into an internal 2 dimesional array format
   generate
      begin : ports
         genvar tid;
         for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
           begin : convert
             assign iu_lq_cp_next_itag_int[tid]      = iu_lq_cp_next_itag[`ITAG_SIZE_ENC*tid:(`ITAG_SIZE_ENC*(tid+1))-1];
             assign iu_lq_i0_completed_itag_int[tid] = iu_lq_i0_completed_itag[`ITAG_SIZE_ENC*tid:(`ITAG_SIZE_ENC*(tid+1))-1];
             assign iu_lq_i1_completed_itag_int[tid] = iu_lq_i1_completed_itag[`ITAG_SIZE_ENC*tid:(`ITAG_SIZE_ENC*(tid+1))-1];
             assign ctl_lsq_spr_dbcr2_dvc1m_int[tid] = ctl_lsq_spr_dbcr2_dvc1m[2*tid:(2*(tid+1))-1];
             assign ctl_lsq_spr_dbcr2_dvc2m_int[tid] = ctl_lsq_spr_dbcr2_dvc2m[2*tid:(2*(tid+1))-1];
             assign ctl_lsq_spr_dbcr2_dvc1be_int[tid] = ctl_lsq_spr_dbcr2_dvc1be[8*tid:8*(tid+1)-1];
             assign ctl_lsq_spr_dbcr2_dvc2be_int[tid] = ctl_lsq_spr_dbcr2_dvc2be[8*tid:8*(tid+1)-1];
           end
      end
   endgenerate

   // Allocate an entry in the Queue off IU dispatch, insert itag
   // Do itag lookup to determine, queue entry, when data/address are available
   // When both address & data are ready for any entry, send lsq_ctl_cpl_ready for that entry
   //    obviously start with the oldest entry
   // Completion will then report itag_complete
   // IF
   //    arb_stq_cred_avail=1
   //    ldq_stq_rel1_blk_store=0
   // THEN
   //    Initiate STQ Commit
   //       starts with asserting stq commit pipe interface
   //       if rv issues at stq2, retry the stq interface (sink will cancel)
   //       drive L2 at stq3
   //       delete entry at stq7
   //       free sq credit

   // DONT CP flush stuff that have itag_complete

   //<<FIX>>
   assign ex3_req_act = 1'b1;

   //------------------------------------------------------------------------------
   // XU Config Bits
   //------------------------------------------------------------------------------

   // XUCR0[CLS] 128 Byte Cacheline Enabled
   // 1 => 128 Byte Cacheline
   // 0 => 64 Byte Cacheline
   assign spr_xucr0_cls_d = xu_lq_spr_xucr0_cls;
   assign spr_xucr0_64cls = (~spr_xucr0_cls_q);

   // IUCR0[ICBI_ACK_EN] ICBI L2 Acknoledge Enable
   // 1 => ICBI Acknowledged by the L2
   // 0 => ICBI Acknowledged by the A2
   assign spr_iucr0_icbi_ack_d = iu_lq_spr_iucr0_icbi_ack;
   assign a2_icbi_ack_en = (~spr_iucr0_icbi_ack_q);

   // LSUCR0[DFWD] Store Data Forwarding is Disabled
   // 1 => Store Data Forwarding is Disabled
   // 0 => Store Data Forwarding is Enabled
   assign spr_lsucr0_dfwd_d = ctl_lsq_spr_lsucr0_dfwd;

   //------------------------------------------------------------------------------
   // Back-Invalidate In Progress
   //------------------------------------------------------------------------------
   // Back-Invalidate in the LQ pipeline
   assign rv1_binv_val_d = l2_back_inv_val;
   assign ex0_binv_val_d = rv1_binv_val_q;
   assign ex1_binv_val_d = ex0_binv_val_q;
   assign ex2_binv_val_d = ex1_binv_val_q;
   assign ex3_binv_val_d = ex2_binv_val_q;

   assign rv1_binv_addr_d = l2_back_inv_addr;
   assign ex0_binv_addr_d = rv1_binv_addr_q;
   assign ex1_binv_addr_d = ex0_binv_addr_q;
   assign ex2_binv_addr_d = ex1_binv_addr_q;
   assign ex3_binv_addr_d = ex2_binv_addr_q;

   //------------------------------------------------------------------------------
   // STQ TAG Mapping
   //------------------------------------------------------------------------------

   // Determine Which entries are available for updating
   assign stq_tag_available = (~stq_tag_val_q);

   // I0 starts at the beginning of the TAG queue and works its way to the end, it looks for the first available
   assign stq_wrt_i0_ptr[0] = stq_tag_available[0];
   generate
      begin : xhdl0
         genvar                                                      stq;
         for (stq = 1; stq <= `STQ_ENTRIES - 1; stq = stq + 1)
           begin : stqI0Wrt
              assign stq_wrt_i0_ptr[stq] = &(~stq_tag_available[0:stq - 1]) & stq_tag_available[stq];
           end
      end
   endgenerate

   // I1 starts at the end of the TAG queue and works its way to the beginning, it looks for the first available entry
   assign stq_wrt_i1_ptr[`STQ_ENTRIES - 1] = stq_tag_available[`STQ_ENTRIES - 1];
   generate
      begin : xhdl1
         genvar                                                      stq;
         for (stq = 0; stq <= `STQ_ENTRIES - 2; stq = stq + 1)
           begin : stqI1Wrt
              assign stq_wrt_i1_ptr[stq] = &(~stq_tag_available[stq + 1:`STQ_ENTRIES - 1]) & stq_tag_available[stq];
           end
      end
   endgenerate

    // Generate STQ TAG Entry Encoded

    always @(*)
    begin: stqTag
       reg [0:`STQ_ENTRIES_ENC-1]                                   entryI0;
       reg [0:`STQ_ENTRIES_ENC-1]                                   entryI1;
       reg [0:`STQ_ENTRIES_ENC-1]                                   cmmtTag;
       integer                                                     stq;
       entryI0 = 0;
       entryI1 = 0;
       cmmtTag = 0;
       for (stq = 0; stq <= `STQ_ENTRIES - 1; stq = stq + 1)
       begin
          entryI0 = (stq & {`STQ_ENTRIES_ENC{stq_wrt_i0_ptr[stq]}}) | entryI0;
          entryI1 = (stq & {`STQ_ENTRIES_ENC{stq_wrt_i1_ptr[stq]}}) | entryI1;
          cmmtTag = (stq & {`STQ_ENTRIES_ENC{stq3_cmmt_tag_entry[stq]}}) | cmmtTag;
       end
       stq_tag_i0_entry <= entryI0;
       stq_tag_i1_entry <= entryI1;
       stq3_cmmt_tag <= cmmtTag;
    end

    generate
       begin : xhdl2
          genvar                                                      stq;
          for (stq = 0; stq <= `STQ_ENTRIES - 1; stq = stq + 1)
          begin : stqTagAlloc
             // STQ TAG Alloc is valid
             assign stq_tag_act[stq] = stq_tag_i0_upd_val[stq] | stq_tag_i1_upd_val[stq] | stq_tag_val_q[stq];
             assign stq_tag_inval[stq] = |(stq_tag_ptr_q[stq] & stq7_entry_delete[0:`STQ_ENTRIES - 1]);
             assign stq_tag_i0_upd_val[stq] = stq_wrt_i0_ptr[stq] & |(ex1_i0_vld_q);
             assign stq_tag_i1_upd_val[stq] = stq_wrt_i1_ptr[stq] & |(ex1_i1_vld_q);
             assign stq_tag_val_d[stq] = stq_tag_i0_upd_val[stq] | stq_tag_i1_upd_val[stq] | (stq_tag_val_q[stq] & (~stq_tag_inval[stq]));

             // wrt_i0 needs to be wrt_i1 when ex1_i1_vld and not ex1_i0_vld, since wrt_i1_ptr is being set valid and alloc_i0_wrt_ptr is valid

             // STQ TAG Alloc Control
             // I0 is updating the Store Queue
             assign stq_wrt_i0_mux[stq] = (stq_alloc_sel == 1'b1) ? stq_wrt_i1_ptr[stq] :
                                                                    stq_wrt_i0_ptr[stq];
             assign stq_tag_i0_stq_sel[stq] = stq_wrt_i0_mux[stq] & stq_alloc_val[0];
             assign stq_tag_ptr_ctrl[stq][0] = stq_tag_i0_stq_sel[stq];

             // I1 is updating the Store Queue
             assign stq_tag_i1_stq_sel[stq] = stq_wrt_i1_ptr[stq] & stq_alloc_val[1];
             assign stq_tag_ptr_ctrl[stq][1] = stq_tag_i1_stq_sel[stq];

             // Store Queue is compressing, need to compress all pointers
             assign stq_tag_ptr_ctrl[stq][2] = stq_push_down;

             // Compress each pointer in the STQ TAG Alloc Array
             assign stq_tag_ptr_compr[stq] = {stq_tag_ptr_q[stq][1:`STQ_ENTRIES - 1], 1'b0};

             // TAG Points to the STQ Entry
             // We should never see ctrl = 110 or ctrl = 111, will need bugspray

             // STQ TAG will is committing, should be a 1-hot, will need bugspray
             assign stq_tag_ptr_d[stq] = (stq_tag_ptr_ctrl[stq] == 3'b100) ? stqe_alloc_i0_wrt_ptr :
                                         (stq_tag_ptr_ctrl[stq] == 3'b101) ? stqe_alloc_i0_wrt_ptr :
                                         (stq_tag_ptr_ctrl[stq] == 3'b010) ? stqe_alloc_i1_wrt_ptr :
                                         (stq_tag_ptr_ctrl[stq] == 3'b011) ? stqe_alloc_i1_wrt_ptr :
                                         (stq_tag_ptr_ctrl[stq] == 3'b001) ? stq_tag_ptr_compr[stq] :
                                                                             stq_tag_ptr_q[stq];
             assign stq3_cmmt_tag_entry[stq] = |(stq_tag_ptr_q[stq] & stq3_cmmt_ptr_q) & stq_tag_val_q[stq];
          end
       end
   endgenerate

   // Order Queue Update with STQ TAG
   assign stq_odq_i0_stTag = stq_tag_i0_entry;
   assign stq_odq_i1_stTag = stq_tag_i1_entry;

   // Order Queue invalidated STQ TAG
   assign stq4_cmmt_tag_d = stq3_cmmt_tag;
   assign stq_odq_stq4_stTag_inval = stq4_cmmt_val_q;
   assign stq_odq_stq4_stTag = stq4_cmmt_tag_q;

   //------------------------------------------------------------------------------
   // STQ Entry Allocation
   //------------------------------------------------------------------------------
   assign stq_alloc_val[0] = |(ex1_i0_vld_q) | |(ex1_i1_vld_q);
   assign stq_alloc_val[1] = |(ex1_i0_vld_q) & |(ex1_i1_vld_q);

   assign stq_alloc_sel = (~(|(ex1_i0_vld_q))) & |(ex1_i1_vld_q);

   assign stq_act = stq_alloc_val[0] | |(stqe_alloc_q) | stq2_cmmt_flushed_q | stq3_cmmt_flushed_q | stq4_cmmt_flushed_q | stq5_cmmt_flushed_q | stq6_cmmt_flushed_q | stq7_cmmt_flushed_q;

   assign stqe_alloc_itag0 = (stq_alloc_sel == 1'b1) ? ex1_i1_itag_q :
                                                       ex1_i0_itag_q;

   assign stq_alloc_flushed[0] = (stq_alloc_sel == 1'b1) ? ex1_i1_flushed :
                                                           ex1_i0_flushed;

   assign stq_alloc_thrd_id0 = (stq_alloc_sel == 1'b1) ? ex1_i1_vld_q :
                                                         ex1_i0_vld_q;
   assign stq_alloc_thrd_id1 = ex1_i1_vld_q;
   assign stqe_alloc_itag1 = ex1_i1_itag_q;
   assign stq_alloc_flushed[1] = ex1_i1_flushed;

   assign stqe_alloc_ptr_r1 = {1'b0, stqe_alloc_ptr_q[0:`STQ_ENTRIES - 2]};
   assign stqe_alloc_ptr_r2 = {1'b0, stqe_alloc_ptr_r1[0:`STQ_ENTRIES - 2]};
   assign stqe_alloc_ptr_l1 = {stqe_alloc_ptr_q[1:`STQ_ENTRIES - 1], ((~(|(stqe_alloc_ptr_q))))};

   assign stqe_alloc_ptr_sel = {stq_alloc_val[0:1], stq_push_down};
   //                         stqe_alloc_ptr_q     when "011",  can't happen
   //                         stqe_alloc_ptr_r1    when "010",  can't happen
   // "000"

   assign stqe_alloc_ptr_d = (stqe_alloc_ptr_sel == 3'b111) ? stqe_alloc_ptr_r1 :
                             (stqe_alloc_ptr_sel == 3'b110) ? stqe_alloc_ptr_r2 :
                             (stqe_alloc_ptr_sel == 3'b101) ? stqe_alloc_ptr_q :
                             (stqe_alloc_ptr_sel == 3'b100) ? stqe_alloc_ptr_r1 :
                             (stqe_alloc_ptr_sel == 3'b001) ? stqe_alloc_ptr_l1 :
                                                              stqe_alloc_ptr_q;
   assign stqe_alloc_i0_wrt_ptr = (stq_push_down == 1'b0) ? stqe_alloc_ptr_q :
                                                            stqe_alloc_ptr_l1;

   assign stqe_alloc_i1_wrt_ptr = (stq_push_down == 1'b0) ? stqe_alloc_ptr_r1 :
                                                            stqe_alloc_ptr_q;

   // Thread Quiesced OR reduce
   always @(*) begin: tidQuiesce
      reg [0:`THREADS-1]                                      tidQ;

      (* analysis_not_referenced="true" *)

      integer                                                 stq;
      tidQ = {`THREADS{1'b0}};
      for (stq=0; stq<`STQ_ENTRIES; stq=stq+1) begin
         tidQ = (stqe_tid_inuse[stq]) | tidQ;
      end
      stq_empty <= ~tidQ;
   end

   assign stq_ldq_empty = stq_empty & ~ext_ack_queue_v_q;

   assign stq_chk_alloc = (~stqe_alloc_q[0:`STQ_ENTRIES - 1]) & (~stqe_alloc_ptr_q) & (stq1_cmmt_ptr_q | stqe_need_ready_ptr_q[0:`STQ_ENTRIES - 1] | ex4_fxu1_data_ptr_q);

   //------------------------------------------------------------------------------
   // STQ Completion Request Pointer
   //------------------------------------------------------------------------------
   assign stqe_need_ready_ptr_r1 = {1'b0, stqe_need_ready_ptr_q[0:`STQ_ENTRIES - 2]};
   assign stqe_need_ready_ptr_l1 = {stqe_need_ready_ptr_q[1:`STQ_ENTRIES - 1], ((~(|(stqe_need_ready_ptr_q))))};

   assign stqe_need_ready_ptr_sel = {stqe_need_ready_next, stq_push_down};

   assign stqe_need_ready_ptr_d = (stqe_need_ready_ptr_sel == 2'b10) ? stqe_need_ready_ptr_r1 :
                                  (stqe_need_ready_ptr_sel == 2'b01) ? stqe_need_ready_ptr_l1 :
                                                                       stqe_need_ready_ptr_q[0:`STQ_ENTRIES - 1];
   assign stqe_need_ready_blk = {`STQ_ENTRIES{ctl_lsq_stq_cpl_blk}};
   assign stqe_need_ready_rpt = stqe_addr_val_q[0:`STQ_ENTRIES - 1] &
                                (stqe_data_nxt_q[0:`STQ_ENTRIES - 1] | (~stqe_has_data_q[0:`STQ_ENTRIES - 1])) &
                                (stqe_have_cp_next_q[0:`STQ_ENTRIES - 1] | (~stqe_need_ext_ack_q[0:`STQ_ENTRIES - 1])) &
                                (~stqe_ready_sent_q[0:`STQ_ENTRIES - 1]) &
                                (~stqe_flushed_q[0:`STQ_ENTRIES - 1]);

   assign stq_cpl_need_hold_d = ctl_lsq_ex_pipe_full & ctl_lsq_stq_cpl_blk & (|(stqe_need_ready_rpt) | |(ext_ack_queue_v_q));

   assign stqe_need_ready = stqe_need_ready_rpt & (~stqe_need_ready_blk);

   assign stqe_need_ready_flushed = stqe_flushed_q & stqe_need_ready_ptr_q & stqe_need_ready_ptr_q & (~stqe_ready_sent_q);

   assign stqe_need_ready_next = |(stqe_need_ready_flushed) | cpl_ready | skip_ready;
   assign stqe_need_ready_act = stqe_need_ready_next | stq_push_down;

   assign cpl_ready = (~(|(cp_flush_q & cpl_ready_tid_final))) & (~(|(any_ack_val))) & |(stqe_need_ready & stqe_need_ready_ptr_q[0:`STQ_ENTRIES - 1] & (stqe_dreq_val_q[0:`STQ_ENTRIES - 1] | stqe_dvc_int_det | ((~stqe_need_ext_ack_q[0:`STQ_ENTRIES - 1]))));

   generate
      begin : xhdl3
         genvar                                                      i;
         for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
         begin : skip_ready_gen
            assign stqe_skip_ready[i] = (~(|(cp_flush_q & stqe_thrd_id_q[i]))) & (stqe_need_ready_rpt[i] & stqe_need_ready_ptr_q[i] & stqe_need_ext_ack_q[i]);
         end
      end
   endgenerate
   assign skip_ready = |(stqe_skip_ready);

   assign dacrw_det[0] = |(stqe_dacrw_det0 & stqe_need_ready_ptr_q[0:`STQ_ENTRIES - 1]);
   assign dacrw_det[1] = |(stqe_dacrw_det1 & stqe_need_ready_ptr_q[0:`STQ_ENTRIES - 1]);
   assign dacrw_det[2] = |(stqe_dacrw_det2 & stqe_need_ready_ptr_q[0:`STQ_ENTRIES - 1]);
   assign dacrw_det[3] = |(stqe_dacrw_det3 & stqe_need_ready_ptr_q[0:`STQ_ENTRIES - 1]);
   assign dacrw_report = |(stqe_dvc_int_det & stqe_need_ready_ptr_q[0:`STQ_ENTRIES - 1]);

   // Qualified with lsq_ctl_cpl_ready in lq_ldq
   assign lsq_ctl_stq_cpl_ready = cpl_ready | |(any_ack_val);

   assign cpl_ready_itag_final = (any_ack_val == {`THREADS{1'b0}}) ? cpl_ready_itag :
                                                      ext_act_queue_itag;
   assign lsq_ctl_stq_cpl_ready_itag = cpl_ready_itag_final;

   assign cpl_ready_tid_final = (any_ack_val == {`THREADS{1'b0}}) ? cpl_ready_thrd_id :
                                                     any_ack_val;
   assign lsq_ctl_stq_cpl_ready_tid = cpl_ready_tid_final;

   assign lsq_ctl_stq_exception_val = 0;
   assign lsq_ctl_stq_exception = 0;
   assign lsq_ctl_stq_n_flush = (any_ack_val == {`THREADS{1'b0}}) ? dacrw_report :
                                                     ext_act_queue_dacrw_rpt;
   assign lsq_ctl_stq_dacrw = (any_ack_val == {`THREADS{1'b0}}) ? dacrw_det :
                                                   ext_act_queue_dacrw_det;

   // We may want to add syncs here for single thread, when we go to 2 `THREADS, flushing may not matter
   //                                      DCI                     ICI
   assign lsq_ctl_stq_np1_flush = ((cpl_ttype == 6'b101111) | (cpl_ttype == 6'b101110)) & (~cpl_dreq_val);

   //------------------------------------------------------------------------------
   // L2 Acks
   //------------------------------------------------------------------------------
   // (probably overkill on the latches here, but I'll leave it)
   assign hwsync_ack = an_ac_sync_ack;		//  and or_reduce(stqe_is_sync_q(0 to `STQ_ENTRIES-1) and     stqe_l_zero and                     stqe_need_ready_ptr_q(0 to `STQ_ENTRIES-1));

   generate
      begin : xhdl4
         genvar                                                      t;
         for (t = 0; t <= `THREADS - 1; t = t + 1)
           begin : sync_thrd_gen
              assign lwsync_ack[t] = stq6_cmmt_val_q & |(stqe_is_sync_q[0:`STQ_ENTRIES - 1] & (~stqe_l_zero) & stq6_cmmt_ptr_q & stqe_need_ext_ack_q[0:`STQ_ENTRIES - 1]) & stq6_tid[t];
              assign local_instr_ack[t] = stq6_cmmt_val_q & |((~stqe_dreq_val_q[0:`STQ_ENTRIES - 1]) & stq6_cmmt_ptr_q & stqe_need_ext_ack_q[0:`STQ_ENTRIES - 1]) & stq6_local_ack_val & stq6_tid[t];
              assign icswxr_ack_thrd[t] = an_ac_back_inv_addr_lo[62:63] == t;

              assign l2_icbi_ack_d[t] = (((an_ac_icbi_ack_thread == t) & an_ac_icbi_ack) | l2_icbi_ack_q[t]) & (~icbi_ack[t]);
           end
      end
   endgenerate

   assign icswxr_ack = an_ac_back_inv & an_ac_back_inv_target_bit3;
   assign icswxr_ack_val = icswxr_ack_thrd & {`THREADS{icswxr_ack_q}};

   assign resv_ack_d[0] =  an_ac_stcx_complete[0] | (resv_ack_q[0] & icswxr_ack_dly1_q);
   assign resv_ack[0]   = (an_ac_stcx_complete[0] & ~icswxr_ack_q) | (resv_ack_q[0] & icswxr_ack_dly1_q);
   generate
      if (`THREADS == 2)
        begin : res_ack_t1
           assign resv_ack_d[1] = an_ac_stcx_complete[1] | (resv_ack_q[1] & (resv_ack_q[0] | icswxr_ack_dly1_q));
           assign resv_ack[1] = (an_ac_stcx_complete[1] & (~an_ac_stcx_complete[0]) & ~icswxr_ack_q) | (resv_ack_q[1] & (resv_ack_q[0] | icswxr_ack_dly1_q));
        end
   endgenerate

   // Dont need thread indicator for now, may change if the store queue design
   // changes for multiple `THREADS
   assign iu_icbi_ack_d = (iu_lq_icbi_complete_q | iu_icbi_ack_q) & (~icbi_ack);

   assign l2_icbi_ack = {`THREADS{a2_icbi_ack_en}} | l2_icbi_ack_q;
   assign icbi_ack = iu_icbi_ack_q & l2_icbi_ack & ext_ack_queue_v_q;
   assign sync_ack_all = hwsync_ack_q | lwsync_ack_q | icbi_ack_q | local_instr_ack_q;

   assign sync_ack_save_d = &(sync_ack_all);

   assign sync_ack[0] = sync_ack_all[0];
   generate		// this logic only works for 1 or 2 `THREADS
      begin : xhdl5
         genvar                                                      t;
         for (t = 1; t <= `THREADS - 1; t = t + 1)
           begin : sync_ack_thrd_gen
              assign sync_ack[t] = (sync_ack_all[t] & (~sync_ack_all[t - 1])) | sync_ack_save_q;
           end
      end
   endgenerate

   assign lsq_ctl_sync_done = |(hwsync_ack_q | lwsync_ack_q);

   // These guys have to fight over cr completion bus.
   // Do not release if ldq_stq_rel1_blk_store=1
   assign cr_block = {`THREADS{ldq_stq_rel1_blk_store}} | (~ex0_cr_hole_q);

   assign cr_ack_d = (icswxr_ack_val | resv_ack_q) | (cr_ack_q & (~cr_ack));

   assign cr_ack[0] = cr_ack_q[0] & (~cr_block[0]) & (~(|(sync_ack_all)));
   generate		// this logic only works for 1 or 2 `THREADS
      begin : xhdl6
         genvar                                                      t;
         for (t = 1; t <= `THREADS - 1; t = t + 1)
         begin : cr_ack_thrd_gen
            assign cr_ack[t] = cr_ack_q[t] & (~(cr_ack_q[t - 1] & (~cr_block[t - 1]))) & (~cr_block[t]) & (~(|(sync_ack_all)));
         end
      end
   endgenerate

   // Local Ack for the following instructions
   // These are instructions that require CP_NEXT to execute
   // and have no dependency on another unit for an ACK
   // 1) DCI
   // 2) ICI
   // 3) WCLR_ALL
   // 4) ICSWX
   // 5) MFTGPR
   assign stq6_dci = (stq6_ttype == 6'b101111);
   assign stq6_ici = (stq6_ttype == 6'b101110);
   assign stq6_icswxnr = (stq6_ttype == 6'b100110);
   assign stq6_mftgpr = (stq6_ttype == 6'b111000);
   assign stq6_local_ack_val = stq6_dci | stq6_ici | stq6_wclr_all_val | stq6_icswxnr | stq6_mftgpr;
   assign any_ack_rcvd = cr_ack | sync_ack;

   assign any_ack_hold_d = any_ack_rcvd | (any_ack_hold_q & (~({`THREADS{(~ctl_lsq_stq_cpl_blk)}} & any_ack_val)));

   assign any_ack_val[0] = any_ack_hold_q[0] & (~ctl_lsq_stq_cpl_blk);

   generate		// this logic only works for 1 or 2 `THREADS
      begin : xhdl7
         genvar                                                      t;
         for (t = 1; t <= `THREADS - 1; t = t + 1)
         begin : any_ack_val_thrd_gen
            assign any_ack_val[t] = any_ack_hold_q[t] & (~any_ack_hold_q[t - 1]) & (~ctl_lsq_stq_cpl_blk);
         end
      end
   endgenerate

   assign any_ack_val_ok_d = any_ack_val;

   // Request a hole until the ack is released, REL1 Block could be on.
   // Kill the request once cr_ack=1
   assign rv0_cr_hole_d = icswxr_ack_val | resv_ack_q | (rv0_cr_hole_q & (~(arb_release_itag_vld_q & {`THREADS{(~ctl_lsq_stq_cpl_blk)}})));
   assign rv1_cr_hole_d = rv0_cr_hole_q & (~(arb_release_itag_vld_q & {`THREADS{(~ctl_lsq_stq_cpl_blk)}}));
   assign ex0_cr_hole_d = rv1_cr_hole_q & (~(arb_release_itag_vld_q & {`THREADS{(~ctl_lsq_stq_cpl_blk)}}));

   // RV release itag
   assign arb_release_itag_vld_d = cr_ack | (arb_release_itag_vld_q & {`THREADS{ctl_lsq_stq_cpl_blk}});
   assign stq_arb_release_itag_vld = |(arb_release_itag_vld_q) & (~ctl_lsq_stq_cpl_blk);
   assign stq_arb_release_itag = cpl_ready_itag_final;
   assign stq_arb_release_tid = cpl_ready_tid_final;

   assign stcx_pass = an_ac_stcx_complete & an_ac_stcx_pass;

   // Delay icswx back_inv comes a cycle late
   assign cr_we_d = icswxr_ack_q | |(resv_ack);

   assign cr_thrd = icswxr_ack_val | resv_ack;

   assign cr_xer_so = |(xu_lq_xer_cp_rd & cr_thrd);
   assign cr_stcx_pass = |((stcx_pass | stcx_pass_q) & cr_thrd);

   assign cr_wd_d = (icswxr_ack_q == 1'b1) ? {an_ac_back_inv_addr[58:60], 1'b0} :
                                             {2'b00, cr_stcx_pass, cr_xer_so};
   assign lq_xu_cr_l2_we = cr_we_q;
   assign lq_xu_cr_l2_wa = cr_wa_q;
   assign lq_xu_cr_l2_wd = cr_wd_q;

   //------------------------------------------------------------------------------
   // Performance Events
   //------------------------------------------------------------------------------
   assign icswxr_thrd_busy_d    = icswxr_ack_val & {`THREADS{ an_ac_back_inv_addr[59]}};
   assign icswxr_thrd_nbusy_d   = icswxr_ack_val & {`THREADS{~an_ac_back_inv_addr[59]}};
   assign stcx_thrd_fail_d      = resv_ack & ~icswxr_ack_val & {`THREADS{~cr_stcx_pass}};
   assign stq3_cmmt_attmpt_d    = stq2_cmmt_val_q;
   assign stq_need_hole_d       = rv_hold | stq_cpl_need_hold_q;
   assign perf_stq_icswxr_busy  = icswxr_thrd_busy_q;
   assign perf_stq_icswxr_nbusy = icswxr_thrd_nbusy_q;
   assign perf_stq_stcx_fail    = stcx_thrd_fail_q;
   assign perf_stq_cmmt_attmpt  = stq3_cmmt_attmpt_q;
   assign perf_stq_cmmt_val     = stq3_cmmt_val_q;
   assign perf_stq_need_hole    = stq_need_hole_q;

   assign lsq_perv_stq_events = {perf_stq_cmmt_attmpt, perf_stq_cmmt_val,     perf_stq_need_hole,
                                 perf_stq_stcx_fail,   perf_stq_icswxr_nbusy, perf_stq_icswxr_busy};

   //------------------------------------------------------------------------------
   // STQ Commit Pipe
   //------------------------------------------------------------------------------
   assign rv_lq_vld_d = |(rv_lq_vld);
   assign rv_lq_ld_vld_d = |(rv_lq_vld) & rv_lq_isLoad;
   assign ex0_dir_rd_val_d = ctl_lsq_rv1_dir_rd_val;

   assign stq1_cmmt_act = stq2_cmmt_reject | stq1_cmmt_val | stq1_cmmt_flushed | stq_push_down;
   assign stq1_cclass = {stq1_p_addr[64 - (`DC_SIZE - 3):56], (stq1_p_addr[57] | spr_xucr0_cls_q)};
   assign stq1_rel_blk_cclass = (stq1_cclass == ldq_stq_stq4_cclass) & ldq_stq_stq4_dir_upd;
   assign stq1_binv1_cclass_m = (stq1_cclass == ex1_binv_addr_q) & ex1_binv_val_q;
   assign stq1_binv2_cclass_m = (stq1_cclass == ex2_binv_addr_q) & ex2_binv_val_q;
   assign stq1_binv3_cclass_m = (stq1_cclass == ex3_binv_addr_q) & ex3_binv_val_q;
   assign stq1_binv_wclrall = (ex1_binv_val_q | ex2_binv_val_q | ex3_binv_val_q) & stq1_wclr_all;
   assign stq1_binv_blk_cclass = stq1_binv1_cclass_m | stq1_binv2_cclass_m | stq1_binv3_cclass_m | stq1_binv_wclrall;
   assign stq2_binv_blk_cclass_d = stq1_binv_blk_cclass | stq1_rel_blk_cclass;

   assign stq1_cmmt_val = (~stq2_cmmt_reject) & |(stqe_ready_state & stq1_cmmt_ptr_q);
   assign stq1_cmmt_flushed = (~stq2_cmmt_reject) & |(stqe_flushed_q[0:`STQ_ENTRIES - 1] & stq1_cmmt_ptr_q);
   assign stq1_cmmt_dreq_val = |(stqe_dreq_val_q[0:`STQ_ENTRIES - 1] & stq1_cmmt_ptr_q);
   assign stq1_cmmt_dvc_val = |(stqe_dvc_int_det & stq1_cmmt_ptr_q);
   assign stq1_cmmt_send_l2 = |(stqe_send_l2_q[0:`STQ_ENTRIES - 1] & stq1_cmmt_ptr_q);
   assign stq3_cmmt_send_l2 = |(stqe_send_l2_q[0:`STQ_ENTRIES - 1] & stq3_cmmt_ptr_q);
   assign stq3_cmmt_dreq_val = |(stqe_dreq_val_q[0:`STQ_ENTRIES - 1] & stq3_cmmt_ptr_q);
   assign stq3_cmmt_dvc_val = |(stqe_dvc_int_det & stq3_cmmt_ptr_q);
   assign stq2_cmmt_ptr_remove = stq2_cmmt_ptr_q & (stqe_dreq_val_q[0:`STQ_ENTRIES - 1] | stqe_dvc_int_det | ((~stqe_need_ext_ack_q[0:`STQ_ENTRIES - 1])));

   assign stq1_cmmt_ptr_r1 = {1'b0, stq1_cmmt_ptr_q[0:`STQ_ENTRIES - 2]};
   assign stq1_cmmt_ptr_l1 = {stq1_cmmt_ptr_q[1:`STQ_ENTRIES - 1], ((~(|(stq1_cmmt_ptr_q))))};
   assign stq2_cmmt_ptr_l1 = {stq2_cmmt_ptr_q[1:`STQ_ENTRIES - 1], ((~(|(stq2_cmmt_ptr_q))))};

   assign stq1_cmmt_ptr_sel = {stq2_cmmt_reject, (stq1_cmmt_val | stq1_cmmt_flushed), stq_push_down};
   // "000"

   assign stq1_cmmt_ptr_d = (stq1_cmmt_ptr_sel == 3'b100) ? stq2_cmmt_ptr_q :
                            (stq1_cmmt_ptr_sel == 3'b110) ? stq2_cmmt_ptr_q :
                            (stq1_cmmt_ptr_sel == 3'b101) ? stq2_cmmt_ptr_l1 :
                            (stq1_cmmt_ptr_sel == 3'b111) ? stq2_cmmt_ptr_l1 :
                            (stq1_cmmt_ptr_sel == 3'b001) ? stq1_cmmt_ptr_l1 :
                            (stq1_cmmt_ptr_sel == 3'b011) ? stq1_cmmt_ptr_q :
                            (stq1_cmmt_ptr_sel == 3'b010) ? stq1_cmmt_ptr_r1 :
                                                            stq1_cmmt_ptr_q;
   assign stq2_cmmt_ptr_d = (stq_push_down == 1'b0) ? stq1_cmmt_ptr_q :
                                                      stq1_cmmt_ptr_l1;

   assign stq3_cmmt_ptr_d = (stq_push_down == 1'b0) ? stq2_cmmt_ptr_q :
                                                      {stq2_cmmt_ptr_q[1:`STQ_ENTRIES - 1], ((~(|(stq2_cmmt_ptr_q))))};

   assign stq4_cmmt_ptr_d = (stq_push_down == 1'b0) ? stq3_cmmt_ptr_q :
                                                      {stq3_cmmt_ptr_q[1:`STQ_ENTRIES - 1], ((~(|(stq3_cmmt_ptr_q))))};

   assign stq5_cmmt_ptr_d = (stq_push_down == 1'b0) ? stq4_cmmt_ptr_q :
                                                      {stq4_cmmt_ptr_q[1:`STQ_ENTRIES - 1], ((~(|(stq4_cmmt_ptr_q))))};

   assign stq6_cmmt_ptr_d = (stq_push_down == 1'b0) ? stq5_cmmt_ptr_q :
                                                      {stq5_cmmt_ptr_q[1:`STQ_ENTRIES - 1], ((~(|(stq5_cmmt_ptr_q))))};

   // Fix for mftgpr colliding with a store update form issued by RV
   // every other store commit request should only be rejected if
   // RV issued a load
   // XUDBG0 command in the LQ pipeline
   assign stq2_reject_rv_coll = (rv_lq_vld_q & stq2_mftgpr_val_q) | (rv_lq_ld_vld_q) | ex0_dir_rd_val_q;
   assign stq2_reject_dci_d   = stq_reject_dci_coll;
   assign stq2_reject_val     = stq2_reject_rv_coll | stq2_binv_blk_cclass_q | stq2_reject_dci_q | ctl_lsq_stq4_perr_reject;
   assign stq2_cmmt_reject = stq2_cmmt_val_q & stq2_reject_val;
   assign stq3_cmmt_reject_d = stq2_cmmt_reject;
   assign stq2_cmmt_val = stq2_cmmt_val_q & (~stq2_reject_val);
   assign stq_stq2_blk_req = stq2_cmmt_reject;

   assign stqe0_icswxdot_val = stqe_is_icswxr_q[0] & (stqe_ttype_q[0] == 6'b100111);

   generate
      begin : xhdl8
         genvar                                                      t;
         for (t = 0; t <= `THREADS - 1; t = t + 1)
         begin : ext_ack_queue_gen
            assign ext_ack_queue_v_d[t] = (stq7_cmmt_val_q & stqe_need_ext_ack_q[0] & stqe_thrd_id_q[0][t] & (~stqe_ack_rcvd_q[0])) |
                                          (ext_ack_queue_v_q[t] & (~any_ack_val[t]));

            assign ext_ack_queue_sync_d[t] = (stq7_cmmt_val_q & stqe_need_ext_ack_q[0] & stqe_thrd_id_q[0][t] & stqe_is_sync_q[0]) |
                                             (ext_ack_queue_sync_q[t] & (~any_ack_val[t]));

            assign ext_ack_queue_stcx_d[t] = (stq7_cmmt_val_q & stqe_need_ext_ack_q[0] & stqe_thrd_id_q[0][t] & stqe_is_resv_q[0]) |
                                             (ext_ack_queue_stcx_q[t] & (~any_ack_val[t]));

            assign ext_ack_queue_icswxr_d[t] = (stq7_cmmt_val_q & stqe_need_ext_ack_q[0] & stqe_thrd_id_q[0][t] & stqe_is_icswxr_q[0] & stqe0_icswxdot_val) |
                                               (ext_ack_queue_icswxr_q[t] & (~any_ack_val[t]));

            assign ext_ack_queue_itag_d[t] = ((stq7_cmmt_val_q & stqe_need_ext_ack_q[0] & stqe_thrd_id_q[0][t]) == 1'b1) ? stqe_itag_q[0] :
                                                                                                                           ext_ack_queue_itag_q[t];

            assign ext_ack_queue_cr_wa_d[t] = ((stq7_cmmt_val_q & stqe_need_ext_ack_q[0] & stqe_thrd_id_q[0][t]) == 1'b1) ? stqe_tgpr_q[0][AXU_TARGET_ENC - (`CR_POOL_ENC + `THREADS_POOL_ENC):AXU_TARGET_ENC - 1] :
                                                                                                                             ext_ack_queue_cr_wa_q[t];

            assign ext_ack_queue_dacrw_det_d[t] = ((stq7_cmmt_val_q & stqe_need_ext_ack_q[0] & stqe_thrd_id_q[0][t]) == 1'b1) ? stqe_dacrw_q[0] :
                                                                                                                                ext_ack_queue_dacrw_det_q[t];

            assign ext_ack_queue_dacrw_rpt_d[t] = ((stq7_cmmt_val_q & stqe_need_ext_ack_q[0] & stqe_thrd_id_q[0][t]) == 1'b1) ? stqe_dvc_int_det[0] :
                                                                                                                                ext_ack_queue_dacrw_rpt_q[t];
         end
      end
   endgenerate


   always @(*)
   begin: ext_act_queue_thrd_sel_proc
      reg [0:`ITAG_SIZE_ENC-1]                                     itag;
      reg [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]                       cr_wa;
      reg [0:3]                                                   dacrw_det;
      reg                                                         dacrw_rpt;
      integer                                                     t;
      itag = 0;
      cr_wa = 0;
      dacrw_det = 0;
      dacrw_rpt = 0;

      for (t = 0; t <= `THREADS - 1; t = t + 1)
      begin
         itag = (ext_ack_queue_itag_q[t] & {`ITAG_SIZE_ENC{(any_ack_val[t] & ext_ack_queue_v_q[t])}})    |
                (stq_ext_act_itag        & {`ITAG_SIZE_ENC{(any_ack_val[t] & (~ext_ack_queue_v_q[t]))}}) | itag;

         cr_wa = (ext_ack_queue_cr_wa_q[t] & {`CR_POOL_ENC+`THREADS_POOL_ENC{(cr_thrd[t] & ext_ack_queue_v_q[t])}})    |
                 (stq_ext_act_cr_wa        & {`CR_POOL_ENC+`THREADS_POOL_ENC{(cr_thrd[t] & (~ext_ack_queue_v_q[t]))}}) | cr_wa;

         dacrw_det = (ext_ack_queue_dacrw_det_q[t] & {4{(any_ack_val[t] & ext_ack_queue_v_q[t])}})    |
                     (stq_ext_act_dacrw_det        & {4{(any_ack_val[t] & (~ext_ack_queue_v_q[t]))}}) | dacrw_det;

         dacrw_rpt = (ext_ack_queue_dacrw_rpt_q[t] & (any_ack_val[t] & ext_ack_queue_v_q[t]))    |
                     (stq_ext_act_dacrw_rpt        & (any_ack_val[t] & (~ext_ack_queue_v_q[t]))) | dacrw_rpt;
      end

      ext_act_queue_itag <= itag;
      cr_wa_d <= cr_wa;
      ext_act_queue_dacrw_det <= dacrw_det;
      ext_act_queue_dacrw_rpt <= dacrw_rpt;
   end

   // Count number of flushes, force a hole once the threshold is reached
   assign stq2_rtry_cnt_act = stq2_cmmt_val_q | rtry_cnt_reset;
   assign stq2_rtry_cnt_incr = stq2_rtry_cnt_q + 3'b001;

   assign stq2_rtry_cnt_d = (((~(stq2_reject_rv_coll)) | rtry_cnt_reset) == 1'b1) ? 3'b110 :
                                                                                    stq2_rtry_cnt_incr;
   assign rtry_cnt_reset = stq2_rtry_cnt_q == 3'b111;
   assign rv_hold = (stq2_rtry_cnt_incr == 3'b111) & (stq2_cmmt_val_q & stq2_reject_rv_coll);
   assign stq_hold_all_req = rv_hold | |(rv0_cr_hole_q) | stq_cpl_need_hold_q;
   assign ex5_stq_set_hold = |(stqe_qHit_held_set & (~stqe_qHit_held_clr[0:`STQ_ENTRIES - 1]));
   assign set_hold_thread = ex5_req_thrd_id_q & {`THREADS{ex5_stq_set_hold}};
   assign stq_rv_set_hold = ex5_stq_set_hold;
   assign thrd_held_d = set_hold_thread | (thrd_held_q & (~clr_hold_thread));
   assign clr_hold_thread = (thrd_held_q & {`THREADS{ |(stqe_qHit_held_clr[0:`STQ_ENTRIES - 1] & stqe_qHit_held_q)}}) |
                            (thrd_held_q & {`THREADS{ |(any_ack_val_ok_q)}});
   assign stq_rv_clr_hold = clr_hold_thread;

   // STQ Commit Valids
   assign lsq_ctl_stq1_val = stq1_cmmt_val & (~(stq1_cmmt_dreq_val | stq1_cmmt_dvc_val));
   assign lsq_dat_stq1_val = stq1_cmmt_val & (~(stq1_cmmt_dreq_val | stq1_cmmt_dvc_val));
   assign stq_ctl_stq1_stg_act = |(stqe_ready_ctl_act) & ~stq1_rel_blk_cclass;
   assign stq_dat_stq1_stg_act = |(stqe_ready_dat_act);
   assign stq_arb_st_req_avail = stq1_cmmt_val & (~(stq1_cmmt_dreq_val | stq1_cmmt_dvc_val)) & stq1_cmmt_send_l2;
   assign stq_arb_stq3_req_val = stq3_cmmt_val_q & (~(stq3_cmmt_dreq_val | stq3_cmmt_dvc_val)) & stq3_cmmt_send_l2;
   assign stq_arb_stq3_cmmt_val    = stq3_cmmt_val_q;
   assign stq_arb_stq3_cmmt_reject = stq3_cmmt_reject_q;

   // Temp fix
   assign sq_iu_credit_free = credit_free_q;
   // fix for requests that have DREQ_VAL and NEED_EXT_ACK set, also want to drop requests if DVC_INT_EN is set
   assign credit_free_d = (stq2_thrd_id & {`THREADS{ ((stq2_cmmt_val & |(stq2_cmmt_ptr_remove)) | stq2_cmmt_flushed_q)}}) | any_ack_val;

   assign lq_iu_icbi_addr = icbi_addr_q;
   assign lq_iu_icbi_val = icbi_val_q;
   // dont want to send ICBI request to the IU if DREQ_VAL is set
   assign icbi_val_d = stq2_thrd_id & {`THREADS{ (stq2_cmmt_val & |(stq2_cmmt_ptr_q & stqe_is_icbi_q[0:`STQ_ENTRIES - 1] & (~stqe_dreq_val_q[0:`STQ_ENTRIES - 1]))) }};

   assign stq2_dci_val_d = stq1_cmmt_val & (stq1_ttype == 6'b101111);
   assign stq2_cmmt_dci_val   = stq2_cmmt_val & stq2_dci_val_q & |(stq2_cmmt_ptr_q & (~stqe_dreq_val_q[0:`STQ_ENTRIES - 1]));
   assign stq3_cmmt_dci_val_d = stq2_cmmt_dci_val;
   assign stq4_cmmt_dci_val_d = stq3_cmmt_dci_val_q;
   assign stq5_cmmt_dci_val_d = stq4_cmmt_dci_val_q;
   assign stq_reject_dci_coll = stq2_cmmt_dci_val;
   assign stq_dci_inprog      = stq3_cmmt_dci_val_q | stq4_cmmt_dci_val_q | stq5_cmmt_dci_val_q;
   assign stq2_ici_val_d = (stq1_ttype == 6'b101110);
   assign ici_val_d = stq2_cmmt_val & stq2_ici_val_q & |(stq2_cmmt_ptr_q & (~stqe_dreq_val_q[0:`STQ_ENTRIES - 1]));
   assign lq_iu_ici_val = ici_val_q;

   // need to set XUCR0[CUL] for a dcblc/icblc that is being dropped
   assign stq3_dcblc_instr = (stq3_ttype == 6'b100101);
   assign stq3_icblc_instr = (stq3_ttype == 6'b100100);
   assign stq4_xucr0_cul_d = stq3_cmmt_val_q & stq3_cmmt_dreq_val & (stq3_dcblc_instr | stq3_icblc_instr);

   // Kill the pointer for instructions that require an external ack
   // Want to delete the entry if DVC_INT_EN is set

   assign stq7_cmmt_ptr_d = (stq_push_down == 1'b0) ? stq6_cmmt_ptr_q :
                                                      {stq6_cmmt_ptr_q[1:`STQ_ENTRIES - 1], 1'b0};

   assign stq7_entry_delete[0:`STQ_ENTRIES - 1] = (stq2_cmmt_ptr_q & {`STQ_ENTRIES{stq2_cmmt_flushed_q}}) |
                                                 (stq7_cmmt_ptr_q & {`STQ_ENTRIES{stq7_cmmt_val_q}});

   assign stq_push_down = stq7_cmmt_flushed_q | (stq7_cmmt_val_q & stq7_cmmt_ptr_q[0]);

   // since the stq is pushed down in stq7, the stq3 commit pointer will never be higher than 4

   assign stq_arb_stq3_cTag[2:4] = (stq3_cmmt_ptr_q[0:4] == 5'b10000) ? 3'b000 :
                                   (stq3_cmmt_ptr_q[0:4] == 5'b01000) ? 3'b001 :
                                   (stq3_cmmt_ptr_q[0:4] == 5'b00100) ? 3'b010 :
                                   (stq3_cmmt_ptr_q[0:4] == 5'b00010) ? 3'b011 :
                                   (stq3_cmmt_ptr_q[0:4] == 5'b00001) ? 3'b100 :
                                                                        3'b111;
   assign stq_arb_stq3_cTag[0:1] = 2'b00;

   assign stq1_mftgpr_val = (stq1_ttype == 6'b111000);
   assign stq2_mftgpr_val_d = stq1_mftgpr_val;
   assign lsq_dat_stq1_mftgpr_val = stq1_mftgpr_val;
   assign lsq_ctl_stq1_mftgpr_val = stq1_mftgpr_val;
   assign lsq_ctl_stq1_mfdpf_val = (stq1_ttype == 6'b011000);
   assign lsq_ctl_stq1_mfdpa_val = (stq1_ttype == 6'b010000);
   assign lsq_ctl_stq1_dci_val = (stq1_ttype == 6'b101111);
   assign stq_arb_stq3_ttype = stq3_ttype;
   assign stq_arb_stq3_tid = stq3_tid_enc;
   assign lsq_ctl_stq4_xucr0_cul = stq4_xucr0_cul_q;

   // Generate Encode Thread ID

   always @(*)
     begin: tidMulti
        reg [0:1]                                                   stqTid;
        integer                                                     tid;
        stqTid = 0;
        for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
          stqTid = (tid & stq3_tid[tid]) | stqTid;

        stq3_tid_enc <= stqTid;
     end

   //------------------------------------------------------------------------------
   //------------------------------------------------------------------------------
   // mtspr_trace Logic
   //------------------------------------------------------------------------------
   //------------------------------------------------------------------------------

   // Encode Thread ID

   always @(*)
     begin: tidEnc
        reg [0:1]                                                   tenc;
        integer                                                     tid;
        tenc = 0;
        for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
          tenc = (tid & ex4_req_thrd_id_q[tid]) | tenc;

        ex4_thrd_id_enc <= tenc;
     end

   // 32bit Real Address MTSPR TRACE Muxing
   generate
      if (`REAL_IFAR_WIDTH == 32)
        begin : ra32bit
           assign ex4_p_addr_ovrd[49:63] = ctl_lsq_ex4_p_addr[49:63];

           assign ex4_p_addr_ovrd[32:33] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[32:33] :
                                                                               ex4_thrd_id_enc;

           assign ex4_p_addr_ovrd[34:43] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[34:43] :
                                                                               ctl_lsq_ex4_p_addr[50:59];

           assign ex4_p_addr_ovrd[44] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[44] :
                                                                            1'b0;

           assign ex4_p_addr_ovrd[45] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[45] :
                                                                            ctl_lsq_ex4_p_addr[60];

           assign ex4_p_addr_ovrd[46] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[46] :
                                                                            ctl_lsq_ex4_p_addr[63];

           assign ex4_p_addr_ovrd[47] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[47] :
                                                                            ctl_lsq_ex4_p_addr[62];
           assign ex4_p_addr_ovrd[48] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[48] :
                                                                            ctl_lsq_ex4_p_addr[61];
        end
   endgenerate

   // greater than 32bit Real Address MTSPR TRACE Muxing
   generate
      if (`REAL_IFAR_WIDTH > 32)
        begin : raN32bit
           assign ex4_p_addr_ovrd[64 - `REAL_IFAR_WIDTH:29] = ctl_lsq_ex4_p_addr[64 - `REAL_IFAR_WIDTH:29];
           assign ex4_p_addr_ovrd[49:63] = ctl_lsq_ex4_p_addr[49:63];

           assign ex4_p_addr_ovrd[30:31] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[30:31] :
                                                                               an_ac_coreid;

           assign ex4_p_addr_ovrd[32:33] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[32:33] :
                                                                               ex4_thrd_id_enc;

           assign ex4_p_addr_ovrd[34:43] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[34:43] :
                                                                               ctl_lsq_ex4_p_addr[50:59];

           assign ex4_p_addr_ovrd[44] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[44] :
                                                                            1'b0;

           assign ex4_p_addr_ovrd[45] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[45] :
                                                                            ctl_lsq_ex4_p_addr[60];

           assign ex4_p_addr_ovrd[46] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[46] :
                                                                            ctl_lsq_ex4_p_addr[63];

           assign ex4_p_addr_ovrd[47] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[47] :
                                                                            ctl_lsq_ex4_p_addr[62];
           assign ex4_p_addr_ovrd[48] = (ctl_lsq_ex4_mtspr_trace == 1'b0) ? ctl_lsq_ex4_p_addr[48] :
                                                                            ctl_lsq_ex4_p_addr[61];
        end
   endgenerate

   //------------------------------------------------------------------------------
   //------------------------------------------------------------------------------
   // STQ Address Entries
   //------------------------------------------------------------------------------
   //------------------------------------------------------------------------------

   // the offset is determined by the size of the store operation in EX3
   assign ex3_opsize_1hot[0] = ctl_lsq_ex3_opsize == 3'b101;		//8B
   assign ex3_opsize_1hot[1] = ctl_lsq_ex3_opsize == 3'b100;		//4B
   assign ex3_opsize_1hot[2] = ctl_lsq_ex3_opsize == 3'b010;		//2B
   assign ex3_rotcmp2_fld = {1'b0, (3'b100 & {3{ex3_opsize_1hot[0]}})};
   assign ex3_rotcmp3_fld = {1'b0, ((3'b110 & {3{ ex3_opsize_1hot[0]}}) | (3'b010 & {3{ex3_opsize_1hot[1]}}))};
   assign stq_rotcmp[0:3] = ctl_lsq_ex3_p_addr[60:63];
   assign stq_rotcmp[4:7] = stq_rotcmp[0:3] + 4'b0010; // + 2;
   assign stq_rotcmp[8:11] = stq_rotcmp[0:3] + ex3_rotcmp2_fld;
   assign stq_rotcmp[12:15] = stq_rotcmp[0:3] + ex3_rotcmp3_fld;

   // create dummy blank stq entry to pushdown on the top of the queue
   assign stqe_thrd_id_q[`STQ_ENTRIES] = 0;
   assign stqe_itag_q[`STQ_ENTRIES] = 0;
   assign stqe_lmqhit_q[`STQ_ENTRIES] = 0;
   assign ex5_older_ldmiss_q[`STQ_ENTRIES] = 0;
   assign stqe_rotcmp_q[`STQ_ENTRIES] = 0;
   assign stqe_byte_en_q[`STQ_ENTRIES] = 0;
   assign stqe_addr_q[`STQ_ENTRIES] = 0;
   assign stqe_wimge_q[`STQ_ENTRIES] = 0;
   assign stqe_opsize_q[`STQ_ENTRIES] = 0;
   assign stqe_ttype_q[`STQ_ENTRIES] = 0;
   assign stqe_usr_def_q[`STQ_ENTRIES] = 0;
   assign stqe_l_fld_q[`STQ_ENTRIES] = 0;
   assign stqe_tgpr_q[`STQ_ENTRIES] = 0;
   assign stqe_dvc_en_q[`STQ_ENTRIES] = 0;
   assign stqe_dacrw_q[`STQ_ENTRIES] = 0;
   assign stqe_data1_q[`STQ_ENTRIES] = 0;
   assign stqe_data1_mux[`STQ_ENTRIES] = 0;
   assign ex5_set_stq_q[`STQ_ENTRIES] = 0;
   assign ex4_set_stq_q[`STQ_ENTRIES] = 0;
   assign stqe_alloc_q[`STQ_ENTRIES] = 0;
   assign stqe_flushed_q[`STQ_ENTRIES] = 0;
   assign stqe_ack_rcvd_q[`STQ_ENTRIES] = 0;
   assign stq7_entry_delete[`STQ_ENTRIES] = 0;
   assign stqe_have_cp_next_q[`STQ_ENTRIES] = 0;
   assign stqe_addr_val_q[`STQ_ENTRIES] = 0;
   assign stqe_fwd_addr_val_q[`STQ_ENTRIES] = 0;
   assign stqe_ready_sent_q[`STQ_ENTRIES] = 0;
   assign stqe_need_ready_ptr_q[`STQ_ENTRIES] = 0;
   assign stqe_compl_rcvd_q[`STQ_ENTRIES] = 0;
   assign stqe_compl_rcvd[`STQ_ENTRIES] = 0;
   assign cp_i0_itag_cmp[`STQ_ENTRIES] = 0;
   assign cp_i1_itag_cmp[`STQ_ENTRIES] = 0;
   assign stqe_flushed[`STQ_ENTRIES] = 0;
   assign stqe_alloc_flushed[`STQ_ENTRIES] = 0;
   assign stqe_need_ext_ack_q[`STQ_ENTRIES] = 0;
   assign stqe_blk_loads_q[`STQ_ENTRIES] = 0;
   assign stqe_all_thrd_chk_q[`STQ_ENTRIES] = 0;
   assign stqe_cline_chk_q[`STQ_ENTRIES] = 0;
   assign stqe_byte_swap_q[`STQ_ENTRIES] = 0;
   assign stqe_is_store_q[`STQ_ENTRIES] = 0;
   assign stqe_is_sync_q[`STQ_ENTRIES] = 0;
   assign stqe_is_resv_q[`STQ_ENTRIES] = 0;
   assign stqe_is_icswxr_q[`STQ_ENTRIES] = 0;
   assign stqe_is_icbi_q[`STQ_ENTRIES] = 0;
   assign stqe_is_inval_op_q[`STQ_ENTRIES] = 0;
   assign stqe_dreq_val_q[`STQ_ENTRIES] = 0;
   assign stqe_has_data_q[`STQ_ENTRIES] = 0;
   assign stqe_send_l2_q[`STQ_ENTRIES] = 0;
   assign stqe_watch_clr_q[`STQ_ENTRIES] = 0;
   assign stqe_axu_val_q[`STQ_ENTRIES] = 0;
   assign stqe_epid_val_q[`STQ_ENTRIES] = 0;
   assign stqe_lock_clr_q[`STQ_ENTRIES] = 0;
   assign stqe_data_val[`STQ_ENTRIES] = 0;
   assign stqe_fxu1_dvcr_val[`STQ_ENTRIES] = 0;
   assign stqe_dvcr_cmpr_q[`STQ_ENTRIES] = 2'b0;
   assign stqe_data_nxt_q[`STQ_ENTRIES] = 0;
   assign ex3_stq_data_val[`STQ_ENTRIES] = 0;
   assign stqe_data_val_q[`STQ_ENTRIES] = 0;
   assign stqe_illeg_lswx_q[`STQ_ENTRIES] = 0;
   assign stqe_strg_noop_q[`STQ_ENTRIES] = 0;
   assign ex3_agecmp[`STQ_ENTRIES] = 0;
   assign stqe_qHit_held_mux[`STQ_ENTRIES] = 0;
   assign stqe_held_early_clr_q[`STQ_ENTRIES] = 0;
   assign set_hold_early_clear[`STQ_ENTRIES] = 0;
   assign stqe_qHit_held_clr[`STQ_ENTRIES] = 0;
   assign stq_cp_next_val[`STQ_ENTRIES] = 0;
   assign stqe_odq_resolved_q[`STQ_ENTRIES] = 0;
   assign ex5_qHit_set_oth_q[`STQ_ENTRIES] = 0;
   assign ex5_qHit_set_miss[`STQ_ENTRIES] = 0;

   always @(stq_push_down)
     begin: dummy
        stq_cp_next_itag[`STQ_ENTRIES] <= 0;
        set_stqe_odq_resolved[`STQ_ENTRIES] <= 0;
     end


   always @(*)
     begin: odq_sttagMux
        reg [0:`STQ_ENTRIES-1]                                       odq_resolved_ptr;
        integer                                                     stq;
        odq_resolved_ptr = 0;
        for (stq = 0; stq <= `STQ_ENTRIES - 1; stq = stq + 1)
          odq_resolved_ptr = (stq_tag_ptr_q[stq] & {`STQ_ENTRIES{odq_stq_stTag[stq]}}) | odq_resolved_ptr;

        set_stqe_odq_resolved[0:`STQ_ENTRIES - 1] <= odq_resolved_ptr & {`STQ_ENTRIES{odq_stq_resolved}};
     end

   generate
      begin : xhdl9
         genvar                                                      i;
         for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
           begin : stq_addr_entry_gen

              assign stqe_odq_resolved_d[i] = (stq_push_down == 1'b0) ? (set_stqe_odq_resolved[i]     | stqe_odq_resolved_q[i])     & (~stq7_entry_delete[i]) :
                                                                        (set_stqe_odq_resolved[i + 1] | stqe_odq_resolved_q[i + 1]) & (~stq7_entry_delete[i + 1]);

              assign stqe_state[i] = {stqe_alloc_q[i],
                                      stqe_addr_val_q[i],
                                      (stqe_data_val_q[i] | (~stqe_has_data_q[i])),
                                      (stqe_compl_rcvd_q[i] | stqe_need_ext_ack_q[i]),
                                      (stqe_have_cp_next_q[i] | (~stqe_need_ext_ack_q[i])),
                                      arb_stq_cred_avail,
                                      stqe_odq_resolved_q[i],
                                      (~(|(stqe_lmqhit_q[i]))),
                                      (~(ldq_stq_rel1_blk_store | stq_dci_inprog))};

              assign stqe_ready_state[i] = (~stqe_flushed_q[i]) & &(stqe_state[i]);

              assign stqe_ready_ctl_act[i] = &({stqe_alloc_q[i],
                                                stqe_addr_val_q[i],
                                                (stqe_data_val_q[i] | (~stqe_has_data_q[i])),
                                                (stqe_compl_rcvd_q[i] | stqe_need_ext_ack_q[i]),
                                                (stqe_have_cp_next_q[i] | (~stqe_need_ext_ack_q[i])),
                                                (~(|(stqe_lmqhit_q[i]))),
                                                (~stqe_flushed_q[i])});

              assign stqe_ready_dat_act[i] = &({stqe_alloc_q[i],
                                                stqe_addr_val_q[i],
                                                (stqe_data_val_q[i]),
                                                (stqe_compl_rcvd_q[i] | stqe_need_ext_ack_q[i]),
                                                (stqe_have_cp_next_q[i] | (~stqe_need_ext_ack_q[i])),
                                                (~(|(stqe_lmqhit_q[i]))),
                                                (~stqe_flushed_q[i])});

              assign stqe_lmqhit_d[i] = (stq_push_down == 1'b0) ? ((ldq_stq_ex5_ldm_hit & {`LMQ_ENTRIES{ex5_set_stq_q[i]}}) |
                                                                     (ldq_stq_ex5_ldm_entry & {`LMQ_ENTRIES{ex5_older_ldmiss_q[i]}}) |
                                                                     stqe_lmqhit_q[i]) & (~ldq_stq_ldm_cpl) :
                                                                  ((ldq_stq_ex5_ldm_hit & {`LMQ_ENTRIES{ex5_set_stq_q[i + 1]}}) |
                                                                      (ldq_stq_ex5_ldm_entry & {`LMQ_ENTRIES{ex5_older_ldmiss_q[i + 1]}}) |
                                                                      stqe_lmqhit_q[i + 1]) & (~ldq_stq_ldm_cpl);

              assign stqe_wrt_new[i] = (stqe_alloc_i0_wrt_ptr[i] & stq_alloc_val[0]) | (stqe_alloc_i1_wrt_ptr[i] & stq_alloc_val[1]);

              assign stqe_thrd_id_d[i] = (stq_alloc_thrd_id0 & {`THREADS{stqe_alloc_i0_wrt_ptr[i]}}) |
                                         (stq_alloc_thrd_id1 & {`THREADS{stqe_alloc_i1_wrt_ptr[i]}}) |
                                         (stqe_thrd_id_q[i + 1] & {`THREADS{(~stqe_wrt_new[i])}});

              assign stqe_tid_inuse[i] = stqe_thrd_id_q[i] & {`THREADS{stqe_alloc_q[i]}};

              assign stqe_itag_act[i] = stqe_wrt_new[i] | stq_push_down;

              assign stqe_alloc_d[i] = stqe_wrt_new[i] |
                                      (stqe_alloc_q[i + 1] & (~stq7_entry_delete[i + 1]) & stq_push_down) |
                                      (stqe_alloc_q[i] & (~stq7_entry_delete[i]) & (~stq_push_down));

              assign stqe_itag_d[i] = (stqe_alloc_itag0   & {`ITAG_SIZE_ENC{(stqe_alloc_i0_wrt_ptr[i] & stq_alloc_val[0])}}) |
                                      (stqe_alloc_itag1   & {`ITAG_SIZE_ENC{(stqe_alloc_i1_wrt_ptr[i] & stq_alloc_val[1])}}) |
                                      (stqe_itag_q[i + 1] & {`ITAG_SIZE_ENC{(~stqe_wrt_new[i])}});

              // Report back to LDQ on LSWX status
              assign ex3_data_val[i] = stqe_data_val_q[i] & (stqe_itag_q[i] == ex3_req_itag_q) & (stqe_thrd_id_q[i] == ex3_req_thrd_id_q) & (~(stqe_flushed_q[i] | stqe_compl_rcvd_q[i]));
              assign ex3_illeg_lswx[i] = stqe_data_val_q[i] & (stqe_itag_q[i] == ex3_req_itag_q) & (stqe_thrd_id_q[i] == ex3_req_thrd_id_q) & ((~stqe_compl_rcvd_q[i])) & stqe_illeg_lswx_q[i];
              assign ex3_strg_noop[i] = stqe_data_val_q[i] & (stqe_itag_q[i] == ex3_req_itag_q) & (stqe_thrd_id_q[i] == ex3_req_thrd_id_q) & ((~stqe_compl_rcvd_q[i])) & stqe_strg_noop_q[i];

              // ITAG Compare for CP_NEXT
              assign stq_cp_next_val[i] = |(cp_next_val_q & stqe_thrd_id_q[i]);


              always @(*)
              begin: cp_next_itag_p
                 reg [0:`ITAG_SIZE_ENC-1]                                     itag;
                 integer                                                     tid;
                 itag = 0;
                 for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
                    itag = (cp_next_itag_q[tid] & {`ITAG_SIZE_ENC{stqe_thrd_id_q[i][tid]}}) | itag;

                 stq_cp_next_itag[i] <= itag;
              end

              assign stqe_have_cp_next_d[i] = (stq_push_down == 1'b0) ? ((stq_cp_next_val[i] & stqe_alloc_q[i] & (stqe_itag_q[i] == stq_cp_next_itag[i])) |
                                                                           stqe_have_cp_next_q[i]) & (~(stq7_entry_delete[i] | stqe_flushed_q[i])) :
                                                                        ((stq_cp_next_val[i + 1] & stqe_alloc_q[i + 1] & (stqe_itag_q[i + 1] == stq_cp_next_itag[i + 1])) |
                                                                           stqe_have_cp_next_q[i + 1]) & (~(stq7_entry_delete[i + 1] | stqe_flushed_q[i + 1]));

              // Address Valid
              assign ex3_set_stq[i] = (stq_push_down == 1'b0) ? ex3_streq_valid & stqe_alloc_q[i] & (stqe_itag_q[i] == ex3_req_itag_q) &
                                                                   (stqe_thrd_id_q[i] == ex3_req_thrd_id_q) & (~(stqe_flushed_q[i] | stqe_compl_rcvd_q[i])) :
                                                                ex3_streq_valid & stqe_alloc_q[i + 1] & (stqe_itag_q[i + 1] == ex3_req_itag_q) &
                                                                   (stqe_thrd_id_q[i + 1] == ex3_req_thrd_id_q) & (~(stqe_flushed_q[i + 1] | stqe_compl_rcvd_q[i + 1]));

              assign ex3_addr_act[i] = ex3_set_stq[i] | stq_push_down;

              assign ex4_addr_act[i] = ex4_set_stq_q[i] | stq_push_down;

              assign ex4_set_stq[i] = (ex4_set_stq_q[i] & (~stq_push_down)) | (ex4_set_stq_q[i + 1] & stq_push_down);

              assign ex5_addr_act[i] = ex5_set_stq_q[i] | stq_push_down;

              assign ex5_set_stq[i] = (ex5_set_stq_q[i] & (~stq_push_down)) | (ex5_set_stq_q[i + 1] & stq_push_down);

              assign stqe_rotcmp_d[i] = (ex3_set_stq[i] == 1'b1) ? stq_rotcmp :
                                                                   stqe_rotcmp_q[i + 1];

              assign stqe_byte_en_d[i] = (ex3_set_stq[i] == 1'b1) ? ctl_lsq_ex3_byte_en :
                                                                    stqe_byte_en_q[i + 1];

              assign stqe_addr_d[i] = (ex4_set_stq[i] == 1'b1) ? ex4_p_addr_ovrd :
                                                                 stqe_addr_q[i + 1];

              assign stqe_cline_chk_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_cline_chk :
                                                                      stqe_cline_chk_q[i + 1];

              assign stqe_wimge_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_wimge :
                                                                  stqe_wimge_q[i + 1];

              assign stqe_byte_swap_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_byte_swap :
                                                                      stqe_byte_swap_q[i + 1];

              assign stqe_opsize_d[i] = (ex4_set_stq[i] == 1'b1) ? ex4_req_opsize_q :
                                                                   stqe_opsize_q[i + 1];

              assign stqe_is_store_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_is_store :
                                                                     stqe_is_store_q[i + 1];

              assign stqe_is_sync_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_is_sync :
                                                                    stqe_is_sync_q[i + 1];

              assign stqe_is_resv_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_is_resv :
                                                                    stqe_is_resv_q[i + 1];

              assign stqe_is_icswxr_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_is_icswxr :
                                                                      stqe_is_icswxr_q[i + 1];

              assign stqe_is_icbi_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_is_icbi :
                                                                    stqe_is_icbi_q[i + 1];

              assign stqe_is_inval_op_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_is_inval_op :
                                                                        stqe_is_inval_op_q[i + 1];

              assign stqe_dreq_val_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_dreq_val :
                                                                     stqe_dreq_val_q[i + 1];

              assign stqe_has_data_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_has_data :
                                                                     stqe_has_data_q[i + 1];

              assign stqe_send_l2_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_send_l2 :
                                                                    stqe_send_l2_q[i + 1];

              assign stqe_watch_clr_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_watch_clr :
                                                                      stqe_watch_clr_q[i + 1];

              assign stqe_ttype_d[i] = (ex5_set_stq[i] == 1'b1) ? ctl_lsq_ex5_ttype :
                                                                  stqe_ttype_q[i + 1];

              assign stqe_axu_val_d[i] = (ex5_set_stq[i] == 1'b1) ? ctl_lsq_ex5_axu_val :
                                                                    stqe_axu_val_q[i + 1];

              assign stqe_epid_val_d[i] = (ex5_set_stq[i] == 1'b1) ? ctl_lsq_ex5_is_epid :
                                                                     stqe_epid_val_q[i + 1];

              assign stqe_usr_def_d[i] = (ex5_set_stq[i] == 1'b1) ? ctl_lsq_ex5_usr_def :
                                                                    stqe_usr_def_q[i + 1];

              assign stqe_lock_clr_d[i] = (ex5_set_stq[i] == 1'b1) ? ctl_lsq_ex5_lock_clr :
                                                                     stqe_lock_clr_q[i + 1];

              assign stqe_l_fld_d[i] = (ex5_set_stq[i] == 1'b1) ? ctl_lsq_ex5_l_fld :
                                                                  stqe_l_fld_q[i + 1];

              assign stqe_tgpr_d[i] = (ex5_set_stq[i] == 1'b1) ? ctl_lsq_ex5_tgpr :
                                                                 stqe_tgpr_q[i + 1];

              assign stqe_dvc_en_d[i] = (ex5_set_stq[i] == 1'b1) ? ctl_lsq_ex5_dvc :
                                                                   stqe_dvc_en_q[i + 1];

              assign stqe_dacrw_d[i] = (ex5_set_stq[i] == 1'b1) ? ctl_lsq_ex5_dacrw :
                                                                  stqe_dacrw_q[i + 1];

              assign stqe_addr_val_d[i] = (stq_push_down == 1'b0) ? ((ex5_streq_valid & ex5_set_stq_q[i])     | (stqe_addr_val_q[i]     & (~stq7_entry_delete[i])))     & (~(stqe_flushed_q[i])) :
                                                                    ((ex5_streq_valid & ex5_set_stq_q[i + 1]) | (stqe_addr_val_q[i + 1] & (~stq7_entry_delete[i + 1]))) & (~(stqe_flushed_q[i + 1]));

              // fix for forwarding store data to load
              assign stqe_fwd_addr_val_d[i] = (stq_push_down == 1'b0) ? ((ex4_streq_valid & ex4_set_stq_q[i])     | (stqe_fwd_addr_val_q[i]     & (~stq7_entry_delete[i])))     & (~(stqe_flushed_q[i])) :
                                                                        ((ex4_streq_valid & ex4_set_stq_q[i + 1]) | (stqe_fwd_addr_val_q[i + 1] & (~stq7_entry_delete[i + 1]))) & (~(stqe_flushed_q[i + 1]));

              // This indicates ready has been sent to cpl
              // Can be delated unless addl checking desired???
              assign stqe_ready_sent_d[i] = (stq_push_down == 1'b0) ? ((cpl_ready & stqe_need_ready_ptr_q[i])     | stqe_ready_sent_q[i]     | stqe_need_ready_flushed[i])     & (~stq7_entry_delete[i]) :
                                                                      ((cpl_ready & stqe_need_ready_ptr_q[i + 1]) | stqe_ready_sent_q[i + 1] | stqe_need_ready_flushed[i + 1]) & (~stq7_entry_delete[i + 1]);

              // Snoop Completion Busses for itags which are "complete"
              assign stq_i0_comp_val[i] = |(cp_i0_completed_q & stqe_thrd_id_q[i]);
              assign stq_i1_comp_val[i] = |(cp_i1_completed_q & stqe_thrd_id_q[i]);


              always @(*)
                begin: complete_itag_p
                   reg [0:`ITAG_SIZE_ENC-1]                                     i0_itag;
                   reg [0:`ITAG_SIZE_ENC-1] 				       i1_itag;
                   integer                                                     tid;
                   i0_itag = 0;
                   i1_itag = 0;
                   for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
		     begin
                        i0_itag = (cp_i0_completed_itag_q[tid] & {`ITAG_SIZE_ENC{stqe_thrd_id_q[i][tid]}}) | i0_itag;
                        i1_itag = (cp_i1_completed_itag_q[tid] & {`ITAG_SIZE_ENC{stqe_thrd_id_q[i][tid]}}) | i1_itag;
		     end
                   stq_i0_comp_itag[i] <= i0_itag;
                   stq_i1_comp_itag[i] <= i1_itag;
                end

              assign cp_i0_itag_cmp[i] = stqe_alloc_q[i] & (stqe_itag_q[i] == stq_i0_comp_itag[i]) & (~stqe_compl_rcvd_q[i]);
              assign cp_i1_itag_cmp[i] = stqe_alloc_q[i] & (stqe_itag_q[i] == stq_i1_comp_itag[i]) & (~stqe_compl_rcvd_q[i]);

              assign stqe_compl_rcvd[i] = ((stq_i0_comp_val[i] & cp_i0_itag_cmp[i] & stqe_ready_sent_q[i] & (~stqe_flushed_q[i])) |
                                          (stq_i1_comp_val[i] & cp_i1_itag_cmp[i] & stqe_ready_sent_q[i] & (~stqe_flushed_q[i]))) |
                                          (stqe_compl_rcvd_q[i] & (~stq7_entry_delete[i]));

              assign stqe_compl_rcvd_d[i] = (stq_push_down == 1'b0) ? stqe_compl_rcvd[i] :
                                                                      stqe_compl_rcvd[i + 1];

              assign stqe_flush_cmp[i] = |(cp_flush_q & stqe_thrd_id_q[i]);

              assign stqe_flushed[i] = stqe_alloc_q[i] & (~stqe_compl_rcvd[i]) & stqe_flush_cmp[i];

              assign stqe_alloc_flushed[i] = (stqe_alloc_ptr_q[i] & stq_alloc_val[0] & stq_alloc_flushed[0]) | (stqe_alloc_ptr_r1[i] & stq_alloc_val[1] & stq_alloc_flushed[1]);

              assign stqe_flushed_d[i] = (stq_push_down == 1'b0) ? (stqe_flushed[i]     | stqe_alloc_flushed[i]     | stqe_flushed_q[i])     & (~stq7_entry_delete[i]) :
                                                                   (stqe_flushed[i + 1] | stqe_alloc_flushed[i + 1] | stqe_flushed_q[i + 1]) & (~stq7_entry_delete[i + 1]);

              assign stqe_need_ext_ack_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_is_sync | ctl_lsq_ex4_is_icbi | ctl_lsq_ex4_is_icswxr | ctl_lsq_ex4_is_resv |
                                                                            ctl_lsq_ex4_is_mfgpr | ctl_lsq_ex4_is_cinval | ctl_lsq_ex4_watch_clr_all :
                                                                         stqe_need_ext_ack_q[i + 1];

              assign stqe_blk_loads_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_is_sync | ctl_lsq_ex4_is_resv | ctl_lsq_ex4_is_cinval | ctl_lsq_ex4_watch_clr_all :
                                                                      stqe_blk_loads_q[i + 1];


              assign stqe_all_thrd_chk_d[i] = (ex4_set_stq[i] == 1'b1) ? ctl_lsq_ex4_all_thrd_chk: stqe_all_thrd_chk_q[i + 1];

              assign stqe_l_zero[i] = stqe_l_fld_q[i][0:1] == 2'b00;

              assign stqe_valid_sync[i] = stqe_is_sync_q[i] & stqe_alloc_q[i] & (~stqe_flushed_q[i]);

              assign stqe_ack_rcvd_d[i] = (stq_push_down == 1'b0) ? (((any_ack_val_ok_q == stqe_thrd_id_q[i])     & stqe_need_ext_ack_q[i]     & stqe_have_cp_next_q[i]     &
                                                                        (~stqe_is_icbi_q[i]))     | stqe_ack_rcvd_q[i]) :
                                                                    (((any_ack_val_ok_q == stqe_thrd_id_q[i + 1]) & stqe_need_ext_ack_q[i + 1] & stqe_have_cp_next_q[i + 1] &
                                                                        (~stqe_is_icbi_q[i + 1])) | stqe_ack_rcvd_q[i + 1]);
           end
      end
   endgenerate

   // drop prefetches when a sync in valid in the stq
   assign lsq_ctl_sync_in_stq = |(stqe_valid_sync) | |(ext_ack_queue_sync_q);

   // LQ Pipe checking for illegal lswx received by SQ
   assign lsq_ctl_ex3_strg_val = |(ex3_data_val);
   assign lsq_ctl_ex3_illeg_lswx = |(ex3_illeg_lswx);
   assign lsq_ctl_ex3_strg_noop = |(ex3_strg_noop);
   assign lsq_ctl_ex3_ct_val = |(ex3_data_val);
   assign lsq_ctl_ex3_be_ct = ex3_ct_sel[0:5];
   assign lsq_ctl_ex3_le_ct = ex3_ct_sel[6:11];

   //------------------------------------------------------------------------------
   // Multi-Thread Age Detection
   //------------------------------------------------------------------------------
   // Multi-Thread Age Detection
   // Following Table should explain the idea behind other `THREADS Age Determination
   // Oldest Youngest   Result
   //  0       0        All Stores with addr_val in Store Queue are oldest
   //  0       1        Stores are older from Youngest_Itag as upper bound, but not including Youngest_Itag, used in case Oldest_Itag is not in ODQ
   //  1       0        Stores are older from Oldest_Itag as upper bound, including Oldest_Itag
   //  1       1        Stores are older from Oldest_Itag as upper bound, including Oldest_Itag
   // Need to validate the oldest entries
   generate
      begin : xhdl10
         genvar                                                      stq;
         for (stq = 0; stq <= `STQ_ENTRIES - 1; stq = stq + 1)
           begin : ageExpand
              assign ex3_agecmp[stq] = |(ex3_nxt_oldest_q[stq:`STQ_ENTRIES - 1]) | ex3_pfetch_val;
           end
      end
   endgenerate

   // Muxing TAG Pointer

   always @(*)
     begin: sttagMux
        reg [0:`STQ_ENTRIES-1]                                       oldest;
        reg [0:`STQ_ENTRIES-1] 					    youngest;
        integer                                                     stq;
        oldest = 0;
        youngest = 0;
        for (stq = 0; stq <= `STQ_ENTRIES - 1; stq = stq + 1)
          begin
             oldest   = (stq_tag_ptr_q[stq] & {`STQ_ENTRIES{odq_stq_ex2_nxt_oldest_stTag[stq]}})   | oldest;
             youngest = (stq_tag_ptr_q[stq] & {`STQ_ENTRIES{odq_stq_ex2_nxt_youngest_stTag[stq]}}) | youngest;
          end
        ex2_nxt_oldest_ptr <= oldest;
        ex2_nxt_youngest_ptr <= youngest;
     end

   assign ex2_no_nxt_match = (~(odq_stq_ex2_nxt_oldest_val | odq_stq_ex2_nxt_youngest_val));
   assign ex2_no_nxt_oldest = (stqe_addr_val_q[0:`STQ_ENTRIES - 1] & (~stqe_flushed_q[0:`STQ_ENTRIES - 1])) & {`STQ_ENTRIES{ex2_no_nxt_match}};

   // Need to shift youngest pointer since we care of everything below this entry
   assign ex2_nxt_youngest_shft = {ex2_nxt_youngest_ptr[1:`STQ_ENTRIES - 1], 1'b0};

   // Oldest Pointer is the OR of oldest_itag pointer with youngest_itag_shifted pointer and with no_oldest_youngest pointer
   assign ex2_nxt_oldest = ex2_nxt_oldest_ptr | ex2_nxt_youngest_shft | ex2_no_nxt_oldest;
   assign ex3_nxt_oldest_d = (stq_push_down == 1'b0) ? ex2_nxt_oldest :
                                                       ({ex2_nxt_oldest[1:`STQ_ENTRIES - 1], 1'b0});

   //------------------------------------------------------------------------------
   // Data Forwarding
   //------------------------------------------------------------------------------
   // For some sizes, we could rotate too far and not leave enough data
   assign ex4_rot_mask = (ex4_req_opsize_q == 3'b001) ? 4'b0000 :       // 1B       None
                         (ex4_req_opsize_q == 3'b010) ? 4'b1111 : 		// 2B       Any
                         (ex4_req_opsize_q == 3'b100) ? 4'b1110 :       // 4B       Sel3 will not leave 4B of data
                         (ex4_req_opsize_q == 3'b101) ? 4'b1000 :       // 8B       Exact Match Only
                         (ex4_req_opsize_q == 3'b110) ? 4'b1000 :       // 16B      Exact Match Only
                                                        4'b0000;

   assign ex4_req_opsize_1hot[0] = ex4_req_opsize_q == 3'b110;		// 16B
   assign ex4_req_opsize_1hot[1] = ex4_req_opsize_q == 3'b101;		// 8B
   assign ex4_req_opsize_1hot[2] = ex4_req_opsize_q == 3'b100;		// 4B
   assign ex4_req_opsize_1hot[3] = ex4_req_opsize_q == 3'b010;		// 2B
   assign ex4_req_opsize_1hot[4] = ex4_req_opsize_q == 3'b001;		// 1B
   assign ex4_req_opsize1        = ~ex4_req_opsize_q[0] & ex4_req_opsize_q[2];

   generate begin : xhdl12
     genvar                                                      i;
     genvar                                                      b;

     for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1) begin : stq_fwd_gen
       if ((58 - RI) == 36) begin : bitStack36
        // Address Compare for data forwarding
        tri_addrcmp stq_fwd_addrcmp(
	   	  .enable_lsb(spr_xucr0_64cls),
	   	  .d0(stqe_addr_q[i][RI:57]),
	   	  .d1(ctl_lsq_ex4_p_addr[RI:57]),
	   	  .eq(ex4_fwd_addrcmp_hi[i]));
       end

       if ((58 - RI) != 36) begin : nobitStack
         assign ex4_fwd_addrcmp_hi[i] = (({stqe_addr_q[i][RI:56], (stqe_addr_q[i][57] & spr_xucr0_64cls)}) == ({ctl_lsq_ex4_p_addr[RI:56], (ctl_lsq_ex4_p_addr[57] & spr_xucr0_64cls)}));
       end

       assign ex4_fwd_addrcmp_lo[i] = stqe_addr_q[i][58:59] == ex4_req_p_addr_l_q[58:59];
       assign ex4_fwd_addrcmp[i] = ex4_fwd_addrcmp_hi[i] & ex4_fwd_addrcmp_lo[i];

       // Check that Thread ID matches
       assign ex4_thrd_match[i] = |(ex4_req_thrd_id_q & stqe_thrd_id_q[i]) | stqe_all_thrd_chk_q[i];

       // Check that they are from the same thread or from different thread that has received its commit report
       assign ex4_thrd_id_ok[i] = ex4_thrd_match[i] | stqe_compl_rcvd_q[i];

       // Check the address for inclusivity based on the opsize
       assign ex4_byte_en_ok[i] = ~(|(ex4_req_byte_en_q & (~stqe_byte_en_q[i])));
       assign ex4_byte_en_miss[i] = ~(|(ex4_req_byte_en_q & stqe_byte_en_q[i]));

       // If they are byte misaligned, we can't rotate.
       // For some sizes, we could rotate too far and not leave enough data
       // 1Byte load can forward only from a 1Byte store to the same address
       assign ex4_1byte_chk_ok[i] = ex4_hw_addr_cmp[i][3] & stqe_opsize1[i] & ex4_req_opsize1;      //1Byte request only
       assign ex4_byte_chk_ok[i]  = |(ex4_hw_addr_cmp[i] & ex4_rot_mask) |                          //All Byte Combination greater than 1Byte requests
                                     (ex4_1byte_chk_ok[i]);

       // need to mask off offsets that dont reflect the size of the store
	   assign stqe_rotcmp_val[i][0] = stqe_opsize_q[i][0] & stqe_opsize_q[i][2];		// 8B requests
	   assign stqe_rotcmp_val[i][1] = stqe_opsize_q[i][0] & stqe_opsize_q[i][2];		// 8B requests
	   assign stqe_rotcmp_val[i][2] = stqe_opsize_q[i][0];		                        // 8B/4B requests
	   assign stqe_rotcmp_val[i][3] = |(stqe_opsize_q[i]);		                        // 8B/4B/2B/1B requests
	   assign stqe_opsize8[i] =  stqe_opsize_q[i][0] &  stqe_opsize_q[i][2];
	   assign stqe_opsize4[i] =  stqe_opsize_q[i][0] & ~stqe_opsize_q[i][2];
	   assign stqe_opsize2[i] = ~stqe_opsize_q[i][0] &  stqe_opsize_q[i][1];
	   assign stqe_opsize1[i] = ~stqe_opsize_q[i][0] &  stqe_opsize_q[i][2];

	   assign ex4_hw_addr_cmp[i][0] = (ex4_req_p_addr_l_q[60:63] == stqe_rotcmp_q[i][0:3])   & stqe_rotcmp_val[i][0];
       assign ex4_hw_addr_cmp[i][1] = (ex4_req_p_addr_l_q[60:63] == stqe_rotcmp_q[i][4:7])   & stqe_rotcmp_val[i][1];
	   assign ex4_hw_addr_cmp[i][2] = (ex4_req_p_addr_l_q[60:63] == stqe_rotcmp_q[i][8:11])  & stqe_rotcmp_val[i][2];
	   assign ex4_hw_addr_cmp[i][3] = (ex4_req_p_addr_l_q[60:63] == stqe_rotcmp_q[i][12:15]) & stqe_rotcmp_val[i][3];

       assign ex4_opsize8_be[i] = ex4_req_opsize_1hot[1] & ~stqe_byte_swap_q[i];
	   assign ex4_opsize4_be[i] = ex4_req_opsize_1hot[2] & ~stqe_byte_swap_q[i];
	   assign ex4_opsize2_be[i] = ex4_req_opsize_1hot[3] & ~stqe_byte_swap_q[i];
	   assign ex4_opsize1_be[i] = ex4_req_opsize_1hot[4] & ~stqe_byte_swap_q[i];
	   assign ex4_opsize8_le[i] = ex4_req_opsize_1hot[1] &  stqe_byte_swap_q[i];
	   assign ex4_opsize4_le[i] = ex4_req_opsize_1hot[2] &  stqe_byte_swap_q[i];
	   assign ex4_opsize2_le[i] = ex4_req_opsize_1hot[3] &  stqe_byte_swap_q[i];
	   assign ex4_opsize1_le[i] = ex4_req_opsize_1hot[4] &  stqe_byte_swap_q[i];

       assign ex4_rot_sel_be[i][0] = (ex4_opsize8_be[i] & ex4_hw_addr_cmp[i][0]) | (ex4_opsize4_be[i] & ex4_hw_addr_cmp[i][2]) |
                                     (ex4_opsize2_be[i] & ex4_hw_addr_cmp[i][3]) | (ex4_opsize1_be[i] & ex4_hw_addr_cmp[i][3]);
       assign ex4_rot_sel_be[i][1] = (ex4_opsize4_be[i] & ex4_hw_addr_cmp[i][1]) | (ex4_opsize2_be[i] & ex4_hw_addr_cmp[i][2]);
       assign ex4_rot_sel_be[i][2] = (ex4_opsize4_be[i] & ex4_hw_addr_cmp[i][0]) | (ex4_opsize2_be[i] & ex4_hw_addr_cmp[i][1]);
       assign ex4_rot_sel_be[i][3] = (ex4_opsize2_be[i] & ex4_hw_addr_cmp[i][0]);

       assign ex4_rot_sel_le[i][0] = ((stqe_opsize8[i] & (ex4_opsize8_le[i] | ex4_opsize4_le[i] | ex4_opsize2_le[i])) & ex4_hw_addr_cmp[i][0]) |
                                     ((stqe_opsize4[i] & (ex4_opsize4_le[i] | ex4_opsize2_le[i])) & ex4_hw_addr_cmp[i][2]) |
                                     (stqe_opsize2[i]  & ex4_opsize2_le[i] & ex4_hw_addr_cmp[i][3]) |
                                     (stqe_opsize1[i]  & ex4_opsize1_le[i] & ex4_hw_addr_cmp[i][3]);
	   assign ex4_rot_sel_le[i][1] = ((stqe_opsize8[i] & (ex4_opsize4_le[i] | ex4_opsize2_le[i])) & ex4_hw_addr_cmp[i][1]) |
                                     ((stqe_opsize4[i] & (ex4_opsize2_le[i])) & ex4_hw_addr_cmp[i][3]);
	   assign ex4_rot_sel_le[i][2] = ((stqe_opsize8[i] & (ex4_opsize4_le[i] | ex4_opsize2_le[i])) & ex4_hw_addr_cmp[i][2]);
	   assign ex4_rot_sel_le[i][3] = ((stqe_opsize8[i] & (ex4_opsize2_le[i])) & ex4_hw_addr_cmp[i][3]);

	   assign ex4_rot_sel[i] = ex4_rot_sel_le[i] | ex4_rot_sel_be[i];

       // Little Endian Sign Extension Byte Select
       // StoreSize8        | HW_CMP | SEXT_SEL
       //--------------------------------------
       // LoadSize4         | 1000   | 0010
       // LoadSize2         | 1000   | 0001
       // LoadSize4         | 0100   | 0100
       // LoadSize2         | 0100   | 0010
       // LoadSize4         | 0010   | 1000
       // LoadSize2         | 0010   | 0100
       // LoadSize2         | 0001   | 1000
       //--------------------------------------
       // StoreSize4        | HW_CMP | SEXT_SEL
       //--------------------------------------
       // LoadSize4         | 0010   | 0010
       // LoadSize2         | 0010   | 0001
       // LoadSize2         | 0001   | 0001
       //--------------------------------------
       // StoreSize2        | HW_CMP | SEXT_SEL
       //--------------------------------------
       // LoadSize2         | 0001   | 0001

       assign ex4_rev_rot_sel[i]       = {ex4_hw_addr_cmp[i][3], ex4_hw_addr_cmp[i][2], ex4_hw_addr_cmp[i][1], ex4_hw_addr_cmp[i][0]};
       assign ex4_shft_rot_sel[i]      = {ex4_rev_rot_sel[i][1:3], 1'b0};
       assign ex4_sext8_le_sel[i]      = (ex4_rev_rot_sel[i]  & {4{(ex4_opsize2_le[i] & stqe_opsize8[i])}}) |
                                         (ex4_shft_rot_sel[i] & {4{(ex4_opsize4_le[i] & stqe_opsize8[i])}});
       assign ex4_sext4_le_sel[i][0:1] = 2'b00;
       assign ex4_sext4_le_sel[i][2]   = stqe_opsize4[i] & (ex4_opsize4_le[i] | (ex4_opsize2_le[i] & ex4_hw_addr_cmp[i][3]));
       assign ex4_sext4_le_sel[i][3]   = stqe_opsize4[i] & ex4_opsize2_le[i] & ex4_hw_addr_cmp[i][2];
       assign ex4_sext2_le_sel[i][0:2] = 3'b000;
       assign ex4_sext2_le_sel[i][3]   = stqe_opsize2[i];
       assign ex4_sext_le_sel[i]       = ex4_sext8_le_sel[i] | ex4_sext4_le_sel[i] | ex4_sext2_le_sel[i];
       assign ex4_sext_sel[i]          = ex4_sext_le_sel[i] | (ex4_hw_addr_cmp[i] & {4{(~stqe_byte_swap_q[i])}});

       assign ex4_sext[i] = (ex4_sext_sel[i][0:3] == 4'b1000) ? stqe_data1_q[i][64] :
                            (ex4_sext_sel[i][0:3] == 4'b0100) ? stqe_data1_q[i][80] :
                            (ex4_sext_sel[i][0:3] == 4'b0010) ? stqe_data1_q[i][96] :
                            (ex4_sext_sel[i][0:3] == 4'b0001) ? stqe_data1_q[i][112] :
                                                                1'b0;
       assign ex4_se[i] = ex4_req_algebraic_q & ex4_sext[i];
       assign ex4_se_b[i][0:7] = {8{(~ex4_se[i])}};

       for (b = 0; b <= 7; b = b + 1) begin : rotate_gen
         assign stqe_data1_swzl[i][b * 8:(b * 8) + 7] = {stqe_data1_q[i][b + 64],  stqe_data1_q[i][b + 72], stqe_data1_q[i][b + 80],
                                                         stqe_data1_q[i][b + 88],  stqe_data1_q[i][b + 96], stqe_data1_q[i][b + 104],
                                                         stqe_data1_q[i][b + 112], stqe_data1_q[i][b + 120]};

         assign ex4_fwd_data1[i][b * 8:(b * 8) + 7] = {ex4_fwd_data1_swzl[i][b + 0],  ex4_fwd_data1_swzl[i][b + 8],  ex4_fwd_data1_swzl[i][b + 16],
                                                       ex4_fwd_data1_swzl[i][b + 24], ex4_fwd_data1_swzl[i][b + 32], ex4_fwd_data1_swzl[i][b + 40],
                                                       ex4_fwd_data1_swzl[i][b + 48], ex4_fwd_data1_swzl[i][b + 56]};


         lq_stq_rot rotate(
           .rot_sel(ex4_rot_sel[i]),
           .mask(ex4_req_opsize_1hot[1:4]),
           .se_b(ex4_se_b[i][b]),
           .rot_data(stqe_data1_swzl[i][b * 8:(b * 8) + 7]),
           .data_rot(ex4_fwd_data1_swzl[i][b * 8:(b * 8) + 7])
         );
       end

       // OrderQ will indicate which entries are older
       // itag age Compare for data forwarding
       //   stq_fwd_agecmp : entity tri.tri_agecmp
       //   generic map(size => `ITAG_SIZE_ENC)
       //   port map (
       //      a           => ex3_req_itag_q,            -- Incoming Load
       //      b           => stqe_itag_q(i),            -- Store Entry
       //      a_newer_b   => ex3_agecmp_itag(i)         -- Load newer than Store?
       //      );

       // If COMMIT report has been recieved, entry is always the oldest automatically
       assign ex3_fwd_agecmp[i] = ex3_agecmp[i];

       assign ex4_fwd_agecmp_d[i] = (stq_push_down == 1'b0) ? ex3_agecmp[i] :
                                                              ex3_agecmp[i + 1];

       assign stqe_guarded[i] = stqe_wimge_q[i][3];

       assign ex4_fwd_endian_mux[i] = (~(ctl_lsq_ex4_byte_swap ^ stqe_byte_swap_q[i]));
       assign ex4_fwd_is_store_mux[i] = stqe_is_store_q[i] & (~(stqe_cline_chk_q[i] | ctl_lsq_ex4_cline_chk));
       assign ex4_fwd_is_cline_chk[i]    = stqe_fwd_addr_val_q[i] & ex4_fwd_addrcmp_hi[i] & (stqe_cline_chk_q[i] | ctl_lsq_ex4_cline_chk);
       assign ex4_fwd_is_miss_chk[i]     = stqe_fwd_addr_val_q[i] & ex4_fwd_addrcmp_hi[i];
       assign ex4_fwd_is_larx_chk[i]     = stqe_fwd_addr_val_q[i] & ex4_thrd_match[i] & ctl_lsq_ex4_is_resv;
       assign ex4_fwd_is_blk_load_chk[i] = stqe_fwd_addr_val_q[i] & ex4_thrd_match[i] & stqe_blk_loads_q[i];
       assign ex4_fwd_is_gload_chk[i]    = stqe_fwd_addr_val_q[i] & ex4_thrd_match[i] & stqe_guarded[i] & ctl_lsq_ex4_wimge[3];
       assign ex4_fwd_rej_guarded[i]     = ctl_lsq_ex4_wimge[3];

       assign stqe_rej_newer_gload[i] = stqe_fwd_addr_val_q[i] & ex4_fwd_agecmp_q[i] & ex4_ldreq_valid & ex4_fwd_is_gload_chk[i];
       assign stqe_rej_other[i]       = stqe_fwd_addr_val_q[i] & ex4_fwd_agecmp_q[i] & ex4_ldreq_valid & ex4_fwd_is_blk_load_chk[i];
       assign stqe_rej_cline_chk[i]   = stqe_fwd_addr_val_q[i] & ex4_fwd_agecmp_q[i] & ex4_ldreq_valid & ex4_fwd_is_cline_chk[i];
       assign stqe_rej_cline_miss[i]  = stqe_fwd_addr_val_q[i] & ex4_fwd_agecmp_q[i] & ex4_ldreq_valid & ex4_fwd_is_miss_chk[i];
       assign stqe_rej_wchkall[i]     = stqe_fwd_addr_val_q[i] & ex4_fwd_agecmp_q[i] & ex4_wchkall_valid;

       assign stqe_rej_hit_no_fwd[i] = ex4_fwd_sel[i] & ex4_fwd_restart_entry[i] & ex4_ldreq_valid;

	    if (i > `STQ_FWD_ENTRIES - 1) begin : hold_nonfwd
		   assign set_hold_early_clear[i] = ex4_nofwd_entry[i] & ex4_ldreq_valid;
		end
	    if (i < `STQ_FWD_ENTRIES) begin : hold_nodata
		   assign set_hold_early_clear[i] = ex4_fwd_sel[i] & (~stqe_data_val_q[i]) & ex4_ldreq_valid;
		end
	   end
      end
   endgenerate

   // Entry Address compared down to the 16 Byte boundary
   assign ex4_fwd_sel = ex4_fwd_addrcmp & ex4_fwd_agecmp_q & stqe_fwd_addr_val_q[0:`STQ_ENTRIES - 1] & (~ex4_byte_en_miss);

   // itag age Compare for data forwarding
   tri_agecmp #(.SIZE(`ITAG_SIZE_ENC)) nxt_stq_fwd_agecmp(
       .a(ex3_req_itag_q),		        // Incoming Load
	   .b(ex4_req_itag_q),		        // being written into next Store Entry
	   .a_newer_b(ex3_ex4_agecmp));     // Load newer than Store?

   assign ex3_ex4_agecmp_sametid = ex3_ex4_agecmp & |(ex3_req_thrd_id_q & ex4_req_thrd_id_q);
   assign ex3_ex4_byte_en_hit = |(ctl_lsq_ex3_byte_en & ex4_req_byte_en_q);

   // compare the forwardable entries to each other to determine the forwarding priority mask
   generate begin : fwd_pri_gen_l1
     genvar                                                      i;
     for (i = 0; i <= `STQ_FWD_ENTRIES - 1; i = i + 1) begin : fwd_pri_gen_l1
       always @(*) begin: fwd_pri_gen_l2
         reg [(i+1):`STQ_FWD_ENTRIES]   match;
         reg [(i+1):`STQ_FWD_ENTRIES]   match_addr;
         reg [(i+1):`STQ_FWD_ENTRIES]   match_incom_addr;
         reg [(i+1):`STQ_FWD_ENTRIES]   match_stqe_addr;
         reg [(i+1):`STQ_FWD_ENTRIES]   match_chk_val;
         reg [(i+1):`STQ_FWD_ENTRIES]   stqe_byte_en_hit;
         reg [(i+1):`STQ_FWD_ENTRIES]   ex4_set_byte_en_hit;
         integer                        j;
         match = 0;
         match_addr = 0;
         match_incom_addr = 0;
         match_stqe_addr = 0;
         match_chk_val = 0;
         stqe_byte_en_hit = 0;
         ex4_set_byte_en_hit = 0;
         for (j = i + 1; j <= `STQ_FWD_ENTRIES; j = j + 1) begin
           stqe_byte_en_hit[j]    = stqe_fwd_addr_val_q[j] & |(ctl_lsq_ex3_byte_en & stqe_byte_en_q[j]);
           ex4_set_byte_en_hit[j] = ex4_set_stq_q[j] & ex3_ex4_byte_en_hit;
           match_incom_addr[j]    = ex4_fwd_addrcmp[i] & ex4_set_stq_q[j];     // incoming address matched against my entry i
           match_stqe_addr[j]     = (({stqe_addr_q[i][RI:56], (stqe_addr_q[i][57] & spr_xucr0_64cls)}) ==
                                     ({stqe_addr_q[j][RI:56], (stqe_addr_q[j][57] & spr_xucr0_64cls)})) & (stqe_addr_q[i][58:59] == stqe_addr_q[j][58:59]);
           match_addr[j]          = match_incom_addr[j] | match_stqe_addr[j];
           match_chk_val[j]       = (stqe_fwd_addr_val_q[i] | ex4_set_stq_q[i]) & (stqe_byte_en_hit[j] | ex4_set_byte_en_hit[j]) & ex3_fwd_agecmp[j];
           match[j]               = (match_addr[j] | ex4_fwd_addrcmp[j]) & match_chk_val[j];
         end
         stq_mask[i] <= |(match);

         // dont think the ODQ age needs to be taken into account, since the store is in ex4, if it were from the other thread,
         // the store wont be in a commit state and the load request should be restarted
         ex4_stqe_match_addr[i] <= ex4_fwd_addrcmp[i] & stqe_fwd_addr_val_q[i] & |(ex4_set_stq_q);
         ex4_stqe_match[i]      <= (ex4_stqe_match_addr[i] & ex3_ex4_byte_en_hit & ex3_fwd_agecmp[i]);
         fwd_pri_mask[i]        <= stq_mask[i];
       end
     end
   end endgenerate

   assign stq_fwd_pri_mask_d = (stq_push_down == 1'b0) ? fwd_pri_mask[0:`STQ_FWD_ENTRIES - 2] :
                                                         fwd_pri_mask[1:`STQ_FWD_ENTRIES - 1];

   // Entries non-address checks passed
   assign stqe_fwd_enable = {`STQ_ENTRIES{~spr_lsucr0_dfwd_q}};
   assign ex4_fwd_entry = ex4_byte_en_ok & ex4_byte_chk_ok & ex4_thrd_id_ok & stqe_data_val_q[0:`STQ_ENTRIES - 1] & ex4_fwd_endian_mux & ex4_fwd_is_store_mux & ~ex4_fwd_rej_guarded & stqe_fwd_enable;
   assign ex4_fwd_val = |(ex4_fwd_sel[0:`STQ_FWD_ENTRIES - 1] & ex4_fwd_entry[0:`STQ_FWD_ENTRIES - 1]);

   // Check that we wanted to forward from the Forwadable Entries
   // but couldnt due to forward checks
   assign ex4_fwd_chk_fail = ex4_fwd_sel[0:`STQ_FWD_ENTRIES - 1] & (~ex4_fwd_entry[0:`STQ_FWD_ENTRIES - 1]);

   // Check that we wanted to forward from the Non-Forwadable Entries, need to restart if
   // we hit against those
   assign ex4_nofwd_entry = ex4_fwd_sel[`STQ_FWD_ENTRIES:`STQ_ENTRIES - 1];

   // Restart scenarios
   assign ex4_fwd_restart_entry = {ex4_fwd_chk_fail, ex4_nofwd_entry};
   assign ex4_fwd_restart = |(ex4_fwd_restart_entry);

   assign ex4_fwd_hit = |(ex4_fwd_sel);

   // ENDIAN, EX$_GUARDED, and NON-STORE rejects are included in the fwd_entry logic now

   // These special rejects occur regardless of address collision
   assign ex4_rej_newer_gload = |(stqe_fwd_addr_val_q[0:`STQ_ENTRIES - 1] & ex4_fwd_agecmp_q & ex4_fwd_is_gload_chk);       // Store Op is guarded
   assign ex4_rej_other       = |(stqe_fwd_addr_val_q[0:`STQ_ENTRIES - 1] & ex4_fwd_agecmp_q & ex4_fwd_is_blk_load_chk);	// Store Op is a STCX, DCI, ICI, SYNC, MBAR, WCLR ALL
   assign ex4_rej_cline_chk   = |(stqe_fwd_addr_val_q[0:`STQ_ENTRIES - 1] & ex4_fwd_agecmp_q & ex4_fwd_is_cline_chk);		// Store Op affects entire cacheline
   assign ex4_rej_cline_miss  = |(stqe_fwd_addr_val_q[0:`STQ_ENTRIES - 1] & ex4_fwd_agecmp_q & ex4_fwd_is_miss_chk);		// Store Op should reject a loadmiss

   // Determine Restart based on thread
   assign ex4_thrd_match_restart   = |(((ex4_fwd_agecmp_q & (ex4_fwd_is_cline_chk | ex4_fwd_is_miss_chk | ex4_fwd_is_gload_chk | ex4_fwd_is_blk_load_chk)) |
                                         ex4_fwd_restart_entry) &  ex4_thrd_match) | ex4_rej_sync_pending;
   assign ex4_thrd_nomatch_restart = |(((ex4_fwd_agecmp_q & (ex4_fwd_is_cline_chk | ex4_fwd_is_miss_chk)) | ex4_fwd_restart_entry) & ~ex4_thrd_match);
   assign ex5_thrd_match_restart_d   = ex4_thrd_match_restart;
   assign ex6_thrd_match_restart_d   = ex5_thrd_match_restart_q;
   assign ex5_thrd_nomatch_restart_d = ex4_thrd_nomatch_restart;
   assign ex6_thrd_nomatch_restart_d = ex5_thrd_nomatch_restart_q;

   // LARX/GuardedLoad check is added for the case where a larx/guardedload went out for a thread, it got an ECC error,
   // reported completion without a flush, a store can commit to the L1/L2 before the resend
   // of the LARX/GuardedLoad completes
   assign ex4_older_ldmiss = (ex4_fwd_is_miss_chk | ex4_fwd_is_larx_chk | ex4_fwd_is_blk_load_chk | ex4_fwd_is_gload_chk) & (~ex4_fwd_agecmp_q);
   assign ex5_older_ldmiss_d = (stq_push_down == 1'b0) ? ex4_older_ldmiss :
                                                        {ex4_older_ldmiss[1:`STQ_ENTRIES - 1], 1'b0};

   assign ex4_rej_wchkall = |(stqe_fwd_addr_val_q[0:`STQ_ENTRIES - 1] & ex4_fwd_agecmp_q);		// WCHKALL colliding with older instructions in store queue,
   // need to guarantee all watch effects have completed
   assign ex4_rej_sync_pending = |(ex4_req_thrd_id_q & (ext_ack_queue_sync_q | ext_ack_queue_stcx_q));

   assign ex5_stq_restart_d = ((ex4_ldreq_valid | ex4_pfetch_val_q) & (ex4_fwd_restart | ex4_rej_newer_gload |
                                                  ex4_rej_other | ex4_rej_cline_chk | ex4_rej_sync_pending)) |
                              (ex4_wchkall_valid & ex4_rej_wchkall);
   assign ex5_stq_restart_miss_d = (ex4_ldreq_valid | ex4_pfetch_val_q) & ex4_rej_cline_miss & (~ex4_fwd_val);		// cacheline compared and I am not forwarding
   assign ex5_fwd_val_d = ex4_ldreq_valid & ex4_fwd_val;

   assign ex4_qHit_set_oth = (stqe_rej_newer_gload | stqe_rej_other | stqe_rej_cline_chk | stqe_rej_wchkall | stqe_rej_hit_no_fwd) & (~stqe_cmmt_entry);
   assign ex4_qHit_set_miss = stqe_rej_cline_miss & (~stqe_cmmt_entry);

   assign ex5_qHit_set_oth_d = (stq_push_down == 1'b0) ? ex4_qHit_set_oth :
                                                        {ex4_qHit_set_oth[1:`STQ_ENTRIES - 1], 1'b0};

   assign ex5_qHit_set_miss_d = (stq_push_down == 1'b0) ? ex4_qHit_set_miss :
                                                         {ex4_qHit_set_miss[1:`STQ_ENTRIES - 1], 1'b0};

   assign ex5_qHit_set_miss[0:`STQ_ENTRIES - 1] = ex5_qHit_set_miss_q & {`STQ_ENTRIES{(~(ctl_lsq_ex5_load_hit | ex5_fwd_val_q))}};

   assign lsq_ctl_ex5_stq_restart = ex5_stq_restart_q;
   assign lsq_ctl_ex5_stq_restart_miss = ex5_stq_restart_miss_q;
   assign lsq_ctl_ex5_fwd_val = ex5_fwd_val_q;
   assign lsq_ctl_ex5_fwd_data = ex5_fwd_data_q;
   assign lsq_ctl_ex6_stq_events = {ex6_thrd_match_restart_q, ex6_thrd_nomatch_restart_q};

   //------------------------------------------------------------------------------
   //------------------------------------------------------------------------------
   // FXU0 SPR Mux Select
   //------------------------------------------------------------------------------
   //------------------------------------------------------------------------------
   // Thread Select
   //fxu0StTid : process (ex4_fxu0_val_q, ctl_lsq_spr_dbcr2_dvc1m, ctl_lsq_spr_dbcr2_dvc1be,
   //                  ctl_lsq_spr_dbcr2_dvc2m, ctl_lsq_spr_dbcr2_dvc2be)
   //  variable dvc1m        :std_ulogic_vector(0 to 1);
   //  variable dvc2m        :std_ulogic_vector(0 to 1);
   //  variable dvc1be       :std_ulogic_vector(8-(2**`GPR_WIDTH_ENC)/8 to 7);
   //  variable dvc2be       :std_ulogic_vector(8-(2**`GPR_WIDTH_ENC)/8 to 7);
   //begin
   //  dvc1m  := (others=>'0');
   //  dvc2m  := (others=>'0');
   //  dvc1be := (others=>'0');
   //  dvc2be := (others=>'0');
   //  for tid in 0 to `THREADS-1 loop
   //    dvc1m  := gate(ctl_lsq_spr_dbcr2_dvc1m(2*tid to 2*tid+1), ex4_fxu0_val_q(tid)) or dvc1m;
   //    dvc2m  := gate(ctl_lsq_spr_dbcr2_dvc2m(2*tid to 2*tid+1), ex4_fxu0_val_q(tid)) or dvc2m;
   //    dvc1be := gate(ctl_lsq_spr_dbcr2_dvc1be(tid*8+(8-fxu0_spr_dbcr2_dvc1be'length) to tid*8+7), ex4_fxu0_val_q(tid)) or dvc1be;
   //    dvc2be := gate(ctl_lsq_spr_dbcr2_dvc2be(tid*8+(8-fxu0_spr_dbcr2_dvc2be'length) to tid*8+7), ex4_fxu0_val_q(tid)) or dvc2be;
   //  end loop;
   //  fxu0_spr_dbcr2_dvc1m  <= dvc1m;
   //  fxu0_spr_dbcr2_dvc2m  <= dvc2m;
   //  fxu0_spr_dbcr2_dvc1be <= dvc1be;
   //  fxu0_spr_dbcr2_dvc2be <= dvc2be;
   //end process fxu0StTid;

   //------------------------------------------------------------------------------
   //------------------------------------------------------------------------------
   // FXU1 SPR Mux Select
   //------------------------------------------------------------------------------
   //------------------------------------------------------------------------------
   // Thread Select

   always @(*)
   begin: fxu1StTid
      reg [0:1]                                                   dvc1m;
      reg [0:1]                                                   dvc2m;
      reg [8-(2**`GPR_WIDTH_ENC)/8:7]                              dvc1be;
      reg [8-(2**`GPR_WIDTH_ENC)/8:7]                              dvc2be;
      integer                                                     tid;
      dvc1m = 0;
      dvc2m = 0;
      dvc1be = 0;
      dvc2be = 0;
      for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
      begin
         dvc1m  = (ctl_lsq_spr_dbcr2_dvc1m_int[tid]  & {2{ex3_fxu1_val_q[tid]}}) | dvc1m;
         dvc2m  = (ctl_lsq_spr_dbcr2_dvc2m_int[tid]  & {2{ex3_fxu1_val_q[tid]}}) | dvc2m;
         dvc1be = (ctl_lsq_spr_dbcr2_dvc1be_int[tid][8-(2**`GPR_WIDTH_ENC)/8:7] & {((2**`GPR_WIDTH_ENC)/8){ex3_fxu1_val_q[tid]}}) | dvc1be;
         dvc2be = (ctl_lsq_spr_dbcr2_dvc2be_int[tid][8-(2**`GPR_WIDTH_ENC)/8:7] & {((2**`GPR_WIDTH_ENC)/8){ex3_fxu1_val_q[tid]}}) | dvc2be;
      end
      fxu1_spr_dbcr2_dvc1m <= dvc1m;
      fxu1_spr_dbcr2_dvc2m <= dvc2m;
      fxu1_spr_dbcr2_dvc1be <= dvc1be;
      fxu1_spr_dbcr2_dvc2be <= dvc2be;
   end

   lq_spr_dvccmp #(.REGSIZE((2 ** `GPR_WIDTH_ENC))) fxu1DVC1St(
								   .en(tiup),
								   .en00(tidn),
								   .cmp(ex3_fxu1_dvc1_cmp_q),
								   .dvcm(fxu1_spr_dbcr2_dvc1m),
								   .dvcbe(fxu1_spr_dbcr2_dvc1be),
								   .dvc_cmpr(ex3_fxu1_dvc1r_cmpr)
								   );


   lq_spr_dvccmp #(.REGSIZE((2 ** `GPR_WIDTH_ENC))) fxu1DVC2St(
								   .en(tiup),
								   .en00(tidn),
								   .cmp(ex3_fxu1_dvc2_cmp_q),
								   .dvcm(fxu1_spr_dbcr2_dvc2m),
								   .dvcbe(fxu1_spr_dbcr2_dvc2be),
								   .dvc_cmpr(ex3_fxu1_dvc2r_cmpr)
								   );
   assign ex3_fxu1_dvcr_cmpr = {ex3_fxu1_dvc1r_cmpr, ex3_fxu1_dvc2r_cmpr};
   assign dbg_int_en_d = ctl_lsq_dbg_int_en;

   //------------------------------------------------------------------------------
   //------------------------------------------------------------------------------
   // ICSWX Coprocessor CT Mux Select
   //------------------------------------------------------------------------------
   //------------------------------------------------------------------------------
   // ITAG Select

   always @(*)
     begin: icswxCt
        reg [0:11]                                                  ctSel;
        integer                                                     stq;
        ctSel = 0;
        for (stq = 0; stq <= `STQ_ENTRIES - 1; stq = stq + 1)
          ctSel = (stqe_icswx_ct_sel[stq] & {12{ex3_data_val[stq]}}) | ctSel;

        ex3_ct_sel <= ctSel;
     end

     //------------------------------------------------------------------------------
     //------------------------------------------------------------------------------
     // STQ Data Entries
     //------------------------------------------------------------------------------
     //------------------------------------------------------------------------------
     // FXU0 Data interfaces
     assign ex4_fxu1_illeg_lswx_d = xu1_lq_ex3_illeg_lswx;
     assign ex4_fxu1_strg_noop_d = xu1_lq_ex3_strg_noop;

     // FXU1 Data interfaces
     assign ex2_fxu1_val = |(xu1_lq_ex2_stq_val);
     assign ex3_fxu1_val_d = xu1_lq_ex2_stq_val & (~cp_flush_q);
     assign ex3_fxu1_itag_d = xu1_lq_ex2_stq_itag;
     assign ex3_fxu1_val = |(ex3_fxu1_val_q);
     assign ex3_fxu1_dvc1_cmp_d = xu1_lq_ex2_stq_dvc1_cmp;
     assign ex3_fxu1_dvc2_cmp_d = xu1_lq_ex2_stq_dvc2_cmp;
     assign ex4_fxu1_val_d = ex3_fxu1_val_q & (~cp_flush_q);

     // AXU Data interfaces
     assign ex2_axu_val = |(xu_lq_axu_ex_stq_val);
     assign ex3_axu_val_d = xu_lq_axu_ex_stq_val & (~cp_flush_q);
     assign ex3_axu_itag_d = xu_lq_axu_ex_stq_itag;
     assign ex3_axu_val = |(ex3_axu_val_q);
     assign ex4_axu_val_d = ex3_axu_val_q & (~cp_flush_q);

   generate
      begin : xhdl14
         genvar                                                      i;
         for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
           begin : stq_data_entry_gen
              assign ex3_fxu1_data_ptr[i] = (stqe_alloc_q[i]     & (ex3_fxu1_itag_q == stqe_itag_q[i])     & |(ex3_fxu1_val_q & stqe_thrd_id_q[i])     & (~stqe_compl_rcvd_q[i])     & (~stq_push_down)) |
                                            (stqe_alloc_q[i + 1] & (ex3_fxu1_itag_q == stqe_itag_q[i + 1]) & |(ex3_fxu1_val_q & stqe_thrd_id_q[i + 1]) & (~stqe_compl_rcvd_q[i + 1]) & stq_push_down);
              assign ex4_fxu1_data_ptr_d[i] = ex3_fxu1_data_ptr[i];
              assign ex4_axu_data_ptr_d[i] = (stqe_alloc_q[i]     & (ex3_axu_itag_q == stqe_itag_q[i])     & (ex3_axu_val_q == stqe_thrd_id_q[i])     & (~stqe_compl_rcvd_q[i])     & (~stq_push_down)) |
                                             (stqe_alloc_q[i + 1] & (ex3_axu_itag_q == stqe_itag_q[i + 1]) & (ex3_axu_val_q == stqe_thrd_id_q[i + 1]) & (~stqe_compl_rcvd_q[i + 1]) & stq_push_down);

              assign ex3_stq_data_val[i] = (stqe_alloc_q[i] & (ex3_fxu1_itag_q == stqe_itag_q[i]) & ((ex3_fxu1_val_q & (~cp_flush_q)) == stqe_thrd_id_q[i])) |
                                           (stqe_alloc_q[i] & (ex3_axu_itag_q == stqe_itag_q[i])  & ((ex3_axu_val_q  & (~cp_flush_q)) == stqe_thrd_id_q[i]));

              assign stqe_data_val[i] = stqe_fxu1_data_val[i] | stqe_axu_data_val[i];
              assign stqe_data_act[i] = stqe_data_val[i] | stq_push_down;

              assign stqe_fxu1_dvcr_val[i] = stqe_alloc_q[i] & (ex3_fxu1_itag_q == stqe_itag_q[i]) & |(ex3_fxu1_val_q & stqe_thrd_id_q[i]) & ~stqe_compl_rcvd_q[i];
              assign stqe_fxu1_data_val[i] = ex4_fxu1_data_ptr_q[i] & stqe_alloc_q[i] & |(ex4_fxu1_val_q & (~cp_flush_q));
              assign stqe_axu_data_val[i] = ex4_axu_data_ptr_q[i] & stqe_alloc_q[i] & |(ex4_axu_val_q & (~cp_flush_q));

              assign stqe_fxu1_data_sel[i] = ex4_fxu1_data_ptr_q[i] & |(ex4_fxu1_val_q);
              assign stqe_axu_data_sel[i] = ex4_axu_data_ptr_q[i] & |(ex4_axu_val_q);

              assign stqe_data_nxt_d[i] = ((ex3_stq_data_val[i]     | stqe_data_nxt_q[i])     & (~(stq7_entry_delete[i]     | stqe_flushed_q[i]))     & (~stq_push_down)) |
                                          ((ex3_stq_data_val[i + 1] | stqe_data_nxt_q[i + 1]) & (~(stq7_entry_delete[i + 1] | stqe_flushed_q[i + 1])) & stq_push_down);
              assign stqe_data_val_d[i] = ((stqe_data_val[i]     | stqe_data_val_q[i])     & (~(stq7_entry_delete[i]     | stqe_flushed_q[i]))     & (~stq_push_down)) |
                                          ((stqe_data_val[i + 1] | stqe_data_val_q[i + 1]) & (~(stq7_entry_delete[i + 1] | stqe_flushed_q[i + 1])) & stq_push_down);
              assign stqe_illeg_lswx_d[i] = (((stqe_data_val[i]     & ex4_fxu1_illeg_lswx_q) | stqe_illeg_lswx_q[i])     & (~(stq7_entry_delete[i]     | stqe_flushed_q[i]))     & (~stq_push_down)) |
                                            (((stqe_data_val[i + 1] & ex4_fxu1_illeg_lswx_q) | stqe_illeg_lswx_q[i + 1]) & (~(stq7_entry_delete[i + 1] | stqe_flushed_q[i + 1])) & stq_push_down);
              assign stqe_strg_noop_d[i] = (((stqe_data_val[i]     & ex4_fxu1_strg_noop_q) | stqe_strg_noop_q[i])     & (~(stq7_entry_delete[i]     | stqe_flushed_q[i]))     & (~stq_push_down)) |
                                           (((stqe_data_val[i + 1] & ex4_fxu1_strg_noop_q) | stqe_strg_noop_q[i + 1]) & (~(stq7_entry_delete[i + 1] | stqe_flushed_q[i + 1])) & stq_push_down);

              // Data Value Compare Control
              assign stqe_dvcr_cmpr_d[i] = (((ex3_fxu1_dvcr_cmpr & {2{stqe_fxu1_dvcr_val[i]  }}) | stqe_dvcr_cmpr_q[i])   & {2{~stq_push_down}}) |
                                           (((ex3_fxu1_dvcr_cmpr & {2{stqe_fxu1_dvcr_val[i+1]}}) | stqe_dvcr_cmpr_q[i+1]) & {2{ stq_push_down}});

              assign stqe_dacrw_det0[i] = stqe_dacrw_q[i][0] | (stqe_dvcr_cmpr_q[i][0] & stqe_dvc_en_q[i][0]);
              assign stqe_dacrw_det1[i] = stqe_dacrw_q[i][1] | (stqe_dvcr_cmpr_q[i][1] & stqe_dvc_en_q[i][1]);
              assign stqe_dacrw_det2[i] = stqe_dacrw_q[i][2];
              assign stqe_dacrw_det3[i] = stqe_dacrw_q[i][3];

              // Debug Interrupt Detected
              assign stqe_dvc_int_det[i] = (stqe_dacrw_det0[i] | stqe_dacrw_det1[i] | stqe_dacrw_det2[i] | stqe_dacrw_det3[i]) & |(stqe_thrd_id_q[i] & dbg_int_en_q);

              // Logic for SET_HOLD and CLR_HOLD to the Reservation station
              // Request was restarted due to hitting against store queue entry
              assign stq2_cmmt_entry[i] = stqe_qHit_held_clr[i];
              assign stq3_cmmt_entry[i] = stq3_cmmt_ptr_q[i] & stq3_cmmt_val_q;
              assign stq4_cmmt_entry[i] = stq4_cmmt_ptr_q[i] & stq4_cmmt_val_q;
              assign stq5_cmmt_entry[i] = stq5_cmmt_ptr_q[i] & stq5_cmmt_val_q;
              assign stq6_cmmt_entry[i] = stq6_cmmt_ptr_q[i] & stq6_cmmt_val_q;
              assign stq7_cmmt_entry[i] = stq7_cmmt_ptr_q[i] & stq7_cmmt_val_q;
              assign stqe_cmmt_entry[i] = stq2_cmmt_entry[i] | stq3_cmmt_entry[i] | stq4_cmmt_entry[i] | stq5_cmmt_entry[i] | stq6_cmmt_entry[i] | stq7_cmmt_entry[i];
              assign stqe_qHit_held_set[i] = (ex5_qHit_set_oth_q[i] | ex5_qHit_set_miss[i]) & (~(|(ex5_qHit_set_oth_q[i + 1:`STQ_ENTRIES] | ex5_qHit_set_miss[i + 1:`STQ_ENTRIES])));		// only set for highest stq entry

              if (i < `STQ_FWD_ENTRIES)
              begin : clr_fwd_entries
                 assign stqe_qHit_held_clr[i] = (stq2_cmmt_ptr_remove[i] & stq2_cmmt_val) |
                                                (stq2_cmmt_ptr_q[i] & stq2_cmmt_flushed_q) |
                                                (stqe_need_ext_ack_q[i] & (any_ack_val_ok_q == stqe_thrd_id_q[i])) |
                                                (stqe_held_early_clr_q[i] & (stqe_data_nxt_q[i] | stqe_data_val_q[i]));
              end

              if (i == `STQ_FWD_ENTRIES)
              begin : clr_next_fwd_entry
                 assign stqe_qHit_held_clr[i] = (stq2_cmmt_ptr_remove[i] & stq2_cmmt_val) |
                                                (stq2_cmmt_ptr_q[i] & stq2_cmmt_flushed_q) |
                                                (stqe_need_ext_ack_q[i] & (any_ack_val_ok_q == stqe_thrd_id_q[i])) |
                                                (stqe_held_early_clr_q[i] & stqe_data_val_q[i] & stq2_cmmt_val & stq2_cmmt_ptr_remove[i-`STQ_FWD_ENTRIES]);
              end

              if (i > `STQ_FWD_ENTRIES)
              begin : clr_nonfwd_entries
                 assign stqe_qHit_held_clr[i] = (stq2_cmmt_ptr_remove[i] & stq2_cmmt_val) |
                                                (stq2_cmmt_ptr_q[i] & stq2_cmmt_flushed_q) |
                                                (stqe_need_ext_ack_q[i] & (any_ack_val_ok_q == stqe_thrd_id_q[i])) |
                                                (stqe_held_early_clr_q[i] & stqe_data_val_q[i] & stq2_cmmt_val & stq2_cmmt_ptr_remove[i-`STQ_FWD_ENTRIES]);
              end

              assign stqe_qHit_held_ctrl[i] = {stqe_qHit_held_set[i], stqe_qHit_held_clr[i]};

              assign stqe_qHit_held_mux[i] = (stqe_qHit_held_ctrl[i] == 2'b00) ? stqe_qHit_held_q[i] :
                                             (stqe_qHit_held_ctrl[i] == 2'b10) ? 1'b1 :
                                                                                 1'b0;
              assign stqe_qHit_held_d[i] = (stq_push_down == 1'b0) ? stqe_qHit_held_mux[i] :
                                                                     stqe_qHit_held_mux[i + 1];

              assign stqe_held_early_clr_d[i] = (stq_push_down == 1'b0) ? set_hold_early_clear[i]     | (stqe_held_early_clr_q[i]     & (~stqe_qHit_held_clr[i])) :
                                                                          set_hold_early_clear[i + 1] | (stqe_held_early_clr_q[i + 1] & (~stqe_qHit_held_clr[i + 1]));

              // ICSWX CT mux select fields
              assign stqe_icswx_ct_sel[i] = {stqe_data1_q[i][106:111], stqe_data1_q[i][114:119]};

              if (`STQ_DATA_SIZE == 64)
                begin : stqData64
                   assign stqe_fwd_data[i] = ex4_fwd_data1[i];

                   if ((2 ** `GPR_WIDTH_ENC) == 64)
                     begin : fxDat64
                        assign stqe_data1_mux[i] = (ctl_lsq_ex4_xu1_data  & {64{(stqe_fxu1_data_sel[i])}}) |
                                                   (ex4_fu_data_q[64:127] & {64{(stqe_axu_data_sel[i])}});
                     end

                   if ((2 ** `GPR_WIDTH_ENC) == 32)
                     begin : fxDat32
                        assign stqe_data1_mux[i][64:95] = ex4_fu_data_q[64:95];
                        assign stqe_data1_mux[i][96:127] = (ctl_lsq_ex4_xu1_data  & {32{(stqe_fxu1_data_sel[i])}}) |
                                                           (ex4_fu_data_q[96:127] & {32{(stqe_axu_data_sel[i])}});
                     end
		end

	      if (`STQ_DATA_SIZE == 128)
		begin : stqData128
		   assign stqe_fwd_data[i][0:63] = stqe_data1_q[i][0:63];
		   assign stqe_fwd_data[i][64:127] = ex4_fwd_data1[i];
		   assign stqe_data1_mux[i][0:63] = ex4_fu_data_q[0:63];

		   if ((2 ** `GPR_WIDTH_ENC) == 64)
		     begin : fxDat64
			assign stqe_data1_mux[i][64:127] = (ctl_lsq_ex4_xu1_data  & {64{(stqe_fxu1_data_sel[i])}}) |
                                                           (ex4_fu_data_q[64:127] & {64{(stqe_axu_data_sel[i])}});
		     end

		   if ((2 ** `GPR_WIDTH_ENC) == 32)
		     begin : fxDat32
			assign stqe_data1_mux[i][64:95] = ex4_fu_data_q[64:95];
			assign stqe_data1_mux[i][96:127] = (ctl_lsq_ex4_xu1_data  & {32{(stqe_fxu1_data_sel[i])}}) |
                                                           (ex4_fu_data_q[96:127] & {32{(stqe_axu_data_sel[i])}});
		     end
		end

	      assign stqe_data1_d[i] = (stq_push_down == 1'b0)                                  ? stqe_data1_mux[i] :
				       ((stq_push_down == 1'b1 & stqe_data_val[i + 1] == 1'b1)) ? stqe_data1_mux[i + 1] :
				                                                                  stqe_data1_q[i + 1];
	   end
      end
   endgenerate

   //------------------------------------------------------------------------------
   // interface staging / Flushing
   //------------------------------------------------------------------------------
   // stq2
   // stq3         ex0  ----
   // stq4         rv2
   // stq5         rv1
   // stq5         rv0
   // stq6         iu6
   // stq7         iu5

   assign rv1_i0_act = |(rv_lq_rv1_i0_vld);
   assign rv1_i1_act = |(rv_lq_rv1_i1_vld);
   assign ex0_i0_act = |(ex0_i0_vld_q);
   assign ex0_i1_act = |(ex0_i1_vld_q);

   assign rv1_i0_vld = rv_lq_rv1_i0_vld & {`THREADS{rv_lq_rv1_i0_rte_sq}};
   assign rv1_i1_vld = rv_lq_rv1_i1_vld & {`THREADS{rv_lq_rv1_i1_rte_sq}};

   // Need to return credits right away for ucode preissued stores, except for preissued ucode indexed load/store string ops
   assign rv1_i0_drop_req = rv_lq_rv1_i0_rte_sq & rv_lq_rv1_i0_ucode_preissue & (~(rv_lq_rv1_i0_s3_t == 3'b100));
   assign rv1_i1_drop_req = rv_lq_rv1_i1_rte_sq & rv_lq_rv1_i1_ucode_preissue & (~(rv_lq_rv1_i1_s3_t == 3'b100));

   assign rv0_cp_flush_d = cp_flush_q;
   assign rv1_cp_flush_d = rv0_cp_flush_q;

   assign rv1_i0_flushed = |(rv1_i0_vld & (cp_flush_q | rv0_cp_flush_q | rv1_cp_flush_q | {`THREADS{rv1_i0_drop_req}}));
   assign rv1_i1_flushed = |(rv1_i1_vld & (cp_flush_q | rv0_cp_flush_q | rv1_cp_flush_q | {`THREADS{rv1_i1_drop_req}}));

   assign ex0_i0_flushed = ex0_i0_flushed_q | |(ex0_i0_vld_q & cp_flush_q);
   assign ex0_i1_flushed = ex0_i1_flushed_q | |(ex0_i1_vld_q & cp_flush_q);

   assign ex1_i0_flushed = ex1_i0_flushed_q | |(ex1_i0_vld_q & cp_flush_q);
   assign ex1_i1_flushed = ex1_i1_flushed_q | |(ex1_i1_vld_q & cp_flush_q);

   assign ex2_streq_val = ctl_lsq_ex2_streq_val & (~cp_flush_q);
   assign ex3_streq_val = ex3_streq_val_q & (~cp_flush_q);
   assign ex4_streq_val = ctl_lsq_ex4_streq_val & (~cp_flush_q);
   assign ex5_streq_val = ex5_streq_val_q & (~(cp_flush_q | {`THREADS{ctl_lsq_ex5_flush_req}}));

   assign ex3_ldreq_val = ctl_lsq_ex3_ldreq_val & (~cp_flush_q);
   assign ex4_ldreq_val = ex4_ldreq_val_q & (~cp_flush_q);

   assign ex3_pfetch_val   = ctl_lsq_ex3_pfetch_val;
   assign ex4_pfetch_val_d = ex3_pfetch_val;

   assign ex4_ldreq_valid = |(ex4_ldreq_val);
   assign ex3_streq_valid = |(ex3_streq_val_q);
   assign ex4_streq_valid = |(ex4_streq_val);
   assign ex5_streq_valid = |(ex5_streq_val);

   assign ex3_wchkall_val = ctl_lsq_ex3_wchkall_val & (~cp_flush_q);
   assign ex4_wchkall_val = ex4_wchkall_val_q & (~cp_flush_q);
   assign ex4_wchkall_valid = |(ex4_wchkall_val);

   //------------------------------------------------------------------------------
   // Generate Muxing  Zzzzzzzzzzzz
   //------------------------------------------------------------------------------

   always @(*)
     begin: cpl_ready_mux_proc
        integer                                                     i;
        cpl_ready_itag <= 0;
        cpl_ready_thrd_id <= 0;
        stq_ext_act_itag <= 0;
        stq_ext_act_dacrw_det <= 0;
        stq_ext_act_cr_wa <= 0;
        cpl_ttype <= 0;
        cpl_dreq_val <= 1'b0;
        stq_ext_act_dacrw_rpt <= 1'b0;

        for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
          begin
             if (stqe_need_ready_ptr_q[i] == 1'b1)
               begin
                  cpl_ready_itag <= stqe_itag_q[i];
                  cpl_ready_thrd_id <= stqe_thrd_id_q[i];
                  cpl_ttype <= stqe_ttype_q[i];
                  cpl_dreq_val <= stqe_dreq_val_q[i];
               end
             if ((stqe_need_ext_ack_q[i] == 1'b1) & (stqe_thrd_id_q[i] == any_ack_val))
               begin
                  stq_ext_act_itag <= stqe_itag_q[i];
                  stq_ext_act_dacrw_det <= stqe_dacrw_q[i];
                  stq_ext_act_dacrw_rpt <= stqe_dvc_int_det[i];
               end
             if ((stqe_need_ext_ack_q[i] == 1'b1) & (stqe_thrd_id_q[i] == cr_thrd))
               stq_ext_act_cr_wa <= stqe_tgpr_q[i][AXU_TARGET_ENC - (`CR_POOL_ENC + `THREADS_POOL_ENC):AXU_TARGET_ENC - 1];
          end
     end


    always @(*)
    begin: stq1_mux_proc
       integer                                                     i;
       stq_arb_stq1_axu_val <= 0;
       stq_arb_stq1_epid_val <= 0;
       lsq_dat_stq1_byte_en <= 0;
       stq_arb_stq1_opSize <= 0;
       stq_arb_stq1_wimge_i <= 0;
       lsq_ctl_stq1_lock_clr <= 0;
       lsq_ctl_stq1_watch_clr <=0;
       lsq_ctl_stq1_l_fld <= 0;
       lsq_ctl_stq1_inval <= 0;
       stq1_p_addr <= 0;
       stq_arb_stq1_thrd_id <= 0;
       lsq_ctl_stq1_resv <= 0;
       lsq_dat_stq1_store_val <= 0;
       lsq_ctl_stq1_store_val <= 0;
       stq_arb_stq1_byte_swap <= 0;
       stq_arb_stq1_store_data <= 0;
       stq1_ttype <= 0;
       stq1_wclr_all <= 0;

       for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
          if (stq1_cmmt_ptr_q[i] == 1'b1)
          begin
             stq_arb_stq1_axu_val <= stqe_axu_val_q[i];
             stq_arb_stq1_epid_val <= stqe_epid_val_q[i];
             lsq_dat_stq1_byte_en <= stqe_byte_en_q[i];
             stq_arb_stq1_opSize <= stqe_opsize_q[i];
             stq_arb_stq1_wimge_i <= stqe_wimge_q[i][1];
             lsq_ctl_stq1_lock_clr <= stqe_lock_clr_q[i];
             lsq_ctl_stq1_watch_clr <= stqe_watch_clr_q[i];
             lsq_ctl_stq1_l_fld <= stqe_l_fld_q[i];
             lsq_ctl_stq1_inval <= stqe_is_inval_op_q[i];
             stq1_p_addr <= stqe_addr_q[i];
             stq_arb_stq1_thrd_id <= stqe_thrd_id_q[i];
             lsq_ctl_stq1_resv <= stqe_is_resv_q[i];
             lsq_dat_stq1_store_val <= stqe_is_store_q[i];
             lsq_ctl_stq1_store_val <= stqe_is_store_q[i];
             stq_arb_stq1_byte_swap <= stqe_byte_swap_q[i];
             stq_arb_stq1_store_data <= stqe_data1_q[i];
             stq1_ttype <= stqe_ttype_q[i];
             stq1_wclr_all <= stqe_watch_clr_q[i] & (~stqe_l_fld_q[i][0]);
          end
       end

       assign stq_arb_stq1_p_addr = stq1_p_addr;


       always @(*)
       begin: stq2_mux_proc
          integer                                                     i;

          stq2_thrd_id <= 0;
          icbi_addr_d <= 0;

          for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
             if (stq2_cmmt_ptr_q[i] == 1'b1)
             begin
                stq2_thrd_id <= stqe_thrd_id_q[i];
                icbi_addr_d <= stqe_addr_q[i][RI:57];
             end
       end


       always @(*)
         begin: stq3_mux_proc
            integer                                                     i;

            stq_arb_stq3_wimge <= 0;
            stq_arb_stq3_p_addr <= 0;
            stq_arb_stq3_opSize <= 0;
            stq_arb_stq3_usrDef <= 0;
            stq_arb_stq3_byteEn <= 0;
            stq3_ttype <= 0;
            stq3_tid <= 0;

            for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
	      if (stq3_cmmt_ptr_q[i] == 1'b1)
		  begin
                     stq_arb_stq3_wimge <= stqe_wimge_q[i];
                     stq_arb_stq3_p_addr <= stqe_addr_q[i];
                     stq_arb_stq3_opSize <= stqe_opsize_q[i];
                     stq_arb_stq3_usrDef <= stqe_usr_def_q[i];
                     stq_arb_stq3_byteEn <= stqe_byte_en_q[i];
                     stq3_ttype <= stqe_ttype_q[i];
                     stq3_tid <= stqe_thrd_id_q[i];
		  end
            end


   always @(*)
     begin: stq5_mux_proc
        integer                                                     i;

        lsq_ctl_stq5_itag <= 0;
        lsq_ctl_stq5_tgpr <= 0;

        for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
          if (stq5_cmmt_ptr_q[i] == 1'b1)
            begin
               lsq_ctl_stq5_itag <= stqe_itag_q[i];
               lsq_ctl_stq5_tgpr <= stqe_tgpr_q[i];
            end
     end


     always @(*)
     begin: stq6_mux_proc
        integer                                                     i;

        stq6_ttype <= 0;
        stq6_tid <= 0;
        stq6_wclr_all_val <= 0;

        for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
           if (stq6_cmmt_ptr_q[i] == 1'b1)
           begin
              stq6_ttype <= stqe_ttype_q[i];
              stq6_wclr_all_val <= stqe_watch_clr_q[i] & (~stqe_l_fld_q[i][0]);
              stq6_tid <= stqe_thrd_id_q[i];
           end
     end

   assign stq_fwd_pri_mask_q[`STQ_FWD_ENTRIES - 1] = 1'b0;


   always @(*)
     begin: stq_data_mux_proc
        integer                                                     i;
        ex5_fwd_data_d <= 0;

        for (i = 0; i <= `STQ_FWD_ENTRIES - 1; i = i + 1)
          if ((ex4_fwd_sel[i] & (~stq_fwd_pri_mask_q[i])) == 1'b1)
            ex5_fwd_data_d <= stqe_fwd_data[i];
     end

//------------------------------------------------------------------------------
// Latch Instances
//------------------------------------------------------------------------------

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rv_lq_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rv_lq_vld_offset]),
   .scout(sov[rv_lq_vld_offset]),
   .din(rv_lq_vld_d),
   .dout(rv_lq_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rv_lq_ld_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rv_lq_ld_vld_offset]),
   .scout(sov[rv_lq_ld_vld_offset]),
   .din(rv_lq_ld_vld_d),
   .dout(rv_lq_ld_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_dir_rd_val_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_dir_rd_val_offset]),
   .scout(sov[ex0_dir_rd_val_offset]),
   .din(ex0_dir_rd_val_d),
   .dout(ex0_dir_rd_val_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) rv0_cp_flush_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rv0_cp_flush_offset:rv0_cp_flush_offset + `THREADS - 1]),
   .scout(sov[rv0_cp_flush_offset:rv0_cp_flush_offset + `THREADS - 1]),
   .din(rv0_cp_flush_d),
   .dout(rv0_cp_flush_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) rv1_cp_flush_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rv1_cp_flush_offset:rv1_cp_flush_offset + `THREADS - 1]),
   .scout(sov[rv1_cp_flush_offset:rv1_cp_flush_offset + `THREADS - 1]),
   .din(rv1_cp_flush_d),
   .dout(rv1_cp_flush_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex0_i0_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_i0_vld_offset:ex0_i0_vld_offset + `THREADS - 1]),
   .scout(sov[ex0_i0_vld_offset:ex0_i0_vld_offset + `THREADS - 1]),
   .din(rv1_i0_vld),
   .dout(ex0_i0_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i0_flushed_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_i0_flushed_offset]),
   .scout(sov[ex0_i0_flushed_offset]),
   .din(rv1_i0_flushed),
   .dout(ex0_i0_flushed_q)
);

tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex0_i0_itag_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(rv1_i0_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_i0_itag_offset:ex0_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[ex0_i0_itag_offset:ex0_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(rv_lq_rv1_i0_itag),
   .dout(ex0_i0_itag_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex0_i1_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_i1_vld_offset:ex0_i1_vld_offset + `THREADS - 1]),
   .scout(sov[ex0_i1_vld_offset:ex0_i1_vld_offset + `THREADS - 1]),
   .din(rv1_i1_vld),
   .dout(ex0_i1_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i1_flushed_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_i1_flushed_offset]),
   .scout(sov[ex0_i1_flushed_offset]),
   .din(rv1_i1_flushed),
   .dout(ex0_i1_flushed_q)
);

tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex0_i1_itag_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(rv1_i1_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_i1_itag_offset:ex0_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[ex0_i1_itag_offset:ex0_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(rv_lq_rv1_i1_itag),
   .dout(ex0_i1_itag_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex1_i0_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_i0_vld_offset:ex1_i0_vld_offset + `THREADS - 1]),
   .scout(sov[ex1_i0_vld_offset:ex1_i0_vld_offset + `THREADS - 1]),
   .din(ex0_i0_vld_q),
   .dout(ex1_i0_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_i0_flushed_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_i0_flushed_offset]),
   .scout(sov[ex1_i0_flushed_offset]),
   .din(ex0_i0_flushed),
   .dout(ex1_i0_flushed_q)
);

tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex1_i0_itag_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex0_i0_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_i0_itag_offset:ex1_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[ex1_i0_itag_offset:ex1_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(ex0_i0_itag_q),
   .dout(ex1_i0_itag_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex1_i1_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_i1_vld_offset:ex1_i1_vld_offset + `THREADS - 1]),
   .scout(sov[ex1_i1_vld_offset:ex1_i1_vld_offset + `THREADS - 1]),
   .din(ex0_i1_vld_q),
   .dout(ex1_i1_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_i1_flushed_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_i1_flushed_offset]),
   .scout(sov[ex1_i1_flushed_offset]),
   .din(ex0_i1_flushed),
   .dout(ex1_i1_flushed_q)
);

tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex1_i1_itag_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex0_i1_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_i1_itag_offset:ex1_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[ex1_i1_itag_offset:ex1_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(ex0_i1_itag_q),
   .dout(ex1_i1_itag_q)
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(2 ** (`STQ_ENTRIES - 1)), .NEEDS_SRESET(1)) stqe_alloc_ptr_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stq_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_alloc_ptr_offset:stqe_alloc_ptr_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_alloc_ptr_offset:stqe_alloc_ptr_offset + `STQ_ENTRIES - 1]),
   .din(stqe_alloc_ptr_d),
   .dout(stqe_alloc_ptr_q)
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stqe_alloc_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stq_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_alloc_offset:stqe_alloc_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_alloc_offset:stqe_alloc_offset + `STQ_ENTRIES - 1]),
   .din(stqe_alloc_d),
   .dout(stqe_alloc_q[0:`STQ_ENTRIES - 1])
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stqe_addr_val_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stq_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_addr_val_offset:stqe_addr_val_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_addr_val_offset:stqe_addr_val_offset + `STQ_ENTRIES - 1]),
   .din(stqe_addr_val_d),
   .dout(stqe_addr_val_q[0:`STQ_ENTRIES - 1])
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stqe_fwd_addr_val_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stq_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_fwd_addr_val_offset:stqe_fwd_addr_val_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_fwd_addr_val_offset:stqe_fwd_addr_val_offset + `STQ_ENTRIES - 1]),
   .din(stqe_fwd_addr_val_d),
   .dout(stqe_fwd_addr_val_q[0:`STQ_ENTRIES - 1])
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stqe_data_val_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stq_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_data_val_offset:stqe_data_val_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_data_val_offset:stqe_data_val_offset + `STQ_ENTRIES - 1]),
   .din(stqe_data_val_d),
   .dout(stqe_data_val_q[0:`STQ_ENTRIES - 1])
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stqe_data_nxt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stq_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_data_nxt_offset:stqe_data_nxt_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_data_nxt_offset:stqe_data_nxt_offset + `STQ_ENTRIES - 1]),
   .din(stqe_data_nxt_d),
   .dout(stqe_data_nxt_q[0:`STQ_ENTRIES - 1])
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stqe_illeg_lswx_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stq_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_illeg_lswx_offset:stqe_illeg_lswx_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_illeg_lswx_offset:stqe_illeg_lswx_offset + `STQ_ENTRIES - 1]),
   .din(stqe_illeg_lswx_d),
   .dout(stqe_illeg_lswx_q[0:`STQ_ENTRIES - 1])
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stqe_strg_noop_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stq_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_strg_noop_offset:stqe_strg_noop_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_strg_noop_offset:stqe_strg_noop_offset + `STQ_ENTRIES - 1]),
   .din(stqe_strg_noop_d),
   .dout(stqe_strg_noop_q[0:`STQ_ENTRIES - 1])
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stqe_ready_sent_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stq_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_ready_sent_offset:stqe_ready_sent_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_ready_sent_offset:stqe_ready_sent_offset + `STQ_ENTRIES - 1]),
   .din(stqe_ready_sent_d),
   .dout(stqe_ready_sent_q[0:`STQ_ENTRIES - 1])
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stqe_odq_resolved_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stq_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_odq_resolved_offset:stqe_odq_resolved_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_odq_resolved_offset:stqe_odq_resolved_offset + `STQ_ENTRIES - 1]),
   .din(stqe_odq_resolved_d),
   .dout(stqe_odq_resolved_q[0:`STQ_ENTRIES - 1])
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stqe_compl_rcvd_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stq_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_compl_rcvd_offset:stqe_compl_rcvd_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_compl_rcvd_offset:stqe_compl_rcvd_offset + `STQ_ENTRIES - 1]),
   .din(stqe_compl_rcvd_d),
   .dout(stqe_compl_rcvd_q[0:`STQ_ENTRIES - 1])
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stqe_have_cp_next_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stq_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_have_cp_next_offset:stqe_have_cp_next_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_have_cp_next_offset:stqe_have_cp_next_offset + `STQ_ENTRIES - 1]),
   .din(stqe_have_cp_next_d),
   .dout(stqe_have_cp_next_q[0:`STQ_ENTRIES - 1])
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(2 ** (`STQ_ENTRIES - 1)), .NEEDS_SRESET(1)) stqe_need_ready_ptr_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stqe_need_ready_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_need_ready_ptr_offset:stqe_need_ready_ptr_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_need_ready_ptr_offset:stqe_need_ready_ptr_offset + `STQ_ENTRIES - 1]),
   .din(stqe_need_ready_ptr_d),
   .dout(stqe_need_ready_ptr_q[0:`STQ_ENTRIES - 1])
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stqe_flushed_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stq_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_flushed_offset:stqe_flushed_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_flushed_offset:stqe_flushed_offset + `STQ_ENTRIES - 1]),
   .din(stqe_flushed_d),
   .dout(stqe_flushed_q[0:`STQ_ENTRIES - 1])
);

tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stqe_ack_rcvd_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(stq_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stqe_ack_rcvd_offset:stqe_ack_rcvd_offset + `STQ_ENTRIES - 1]),
   .scout(sov[stqe_ack_rcvd_offset:stqe_ack_rcvd_offset + `STQ_ENTRIES - 1]),
   .din(stqe_ack_rcvd_d),
   .dout(stqe_ack_rcvd_q[0:`STQ_ENTRIES - 1])
);
generate
   begin : xhdl15
      genvar                                                      i;
      for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
      begin : stqe_lmqhit_latch_gen

         tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stqe_lmqhit_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(stq_act),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[stqe_lmqhit_offset + `LMQ_ENTRIES * i:stqe_lmqhit_offset + `LMQ_ENTRIES * (i + 1) - 1]),
            .scout(sov[stqe_lmqhit_offset + `LMQ_ENTRIES * i:stqe_lmqhit_offset + `LMQ_ENTRIES * (i + 1) - 1]),
            .din(stqe_lmqhit_d[i]),
            .dout(stqe_lmqhit_q[i])
         );
      end
   end
endgenerate
generate
   begin : xhdl16
      genvar                                                      i;
      for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
      begin : stqe_need_ext_ack_latch_gen

         tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_need_ext_ack_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(ex4_addr_act[i]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[stqe_need_ext_ack_offset + i:stqe_need_ext_ack_offset + i]),
            .scout(sov[stqe_need_ext_ack_offset + i:stqe_need_ext_ack_offset + i]),
            .din(stqe_need_ext_ack_d[i]),
            .dout(stqe_need_ext_ack_q[i])
         );
      end
   end
   endgenerate

generate
   begin : stqe_blk_loads_latch_gen
      genvar                                                      i;
      for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1) begin : stqe_blk_loads_latch_gen

         tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_blk_loads_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(ex4_addr_act[i]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[stqe_blk_loads_offset + i:stqe_blk_loads_offset + i]),
            .scout(sov[stqe_blk_loads_offset + i:stqe_blk_loads_offset + i]),
            .din(stqe_blk_loads_d[i]),
            .dout(stqe_blk_loads_q[i])
         );
      end
   end
   endgenerate

generate
   begin : xhdl57
      genvar                                                      i;
      for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
      begin : stqe_all_thrd_chk_latch_gen

         tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_all_thrd_chk_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(ex4_addr_act[i]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[stqe_all_thrd_chk_offset + i:stqe_all_thrd_chk_offset + i]),
            .scout(sov[stqe_all_thrd_chk_offset + i:stqe_all_thrd_chk_offset + i]),
            .din(stqe_all_thrd_chk_d[i]),
            .dout(stqe_all_thrd_chk_q[i])
         );
      end
   end
   endgenerate

   generate
   begin : xhdl17
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
     begin : stqe_itag_latch_gen

       tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1))
       stqe_itag_latch(
                       .nclk(nclk),
                       .vd(vdd),
                       .gd(gnd),
                       .act(stqe_itag_act[i]),
                       .force_t(func_sl_force),
                       .d_mode(d_mode_dc),
                       .delay_lclkr(delay_lclkr_dc),
                       .mpw1_b(mpw1_dc_b),
                       .mpw2_b(mpw2_dc_b),
                       .thold_b(func_sl_thold_0_b),
                       .sg(sg_0),
                       .scin(siv[stqe_itag_offset + `ITAG_SIZE_ENC * i:stqe_itag_offset + `ITAG_SIZE_ENC * (i + 1) - 1]),
                       .scout(sov[stqe_itag_offset + `ITAG_SIZE_ENC * i:stqe_itag_offset + `ITAG_SIZE_ENC * (i + 1) - 1]),
                       .din(stqe_itag_d[i]),
                       .dout(stqe_itag_q[i])
                       );
     end
   end
   endgenerate
   generate
   begin : xhdl18
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
     begin : stqe_addr_latch_gen

       tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) stqe_addr_latch(
                       .nclk(nclk),
                       .vd(vdd),
                       .gd(gnd),
                       .act(ex4_addr_act[i]),
                       .force_t(func_sl_force),
                       .d_mode(d_mode_dc),
                       .delay_lclkr(delay_lclkr_dc),
                       .mpw1_b(mpw1_dc_b),
                       .mpw2_b(mpw2_dc_b),
                       .thold_b(func_sl_thold_0_b),
                       .sg(sg_0),
                       .scin(siv[stqe_addr_offset + `REAL_IFAR_WIDTH * i:stqe_addr_offset + `REAL_IFAR_WIDTH * (i + 1) - 1]),
                       .scout(sov[stqe_addr_offset + `REAL_IFAR_WIDTH * i:stqe_addr_offset + `REAL_IFAR_WIDTH * (i + 1) - 1]),
                       .din(stqe_addr_d[i]),
                       .dout(stqe_addr_q[i])
                       );
     end
   end
   endgenerate
   generate
   begin : xhdl19
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
     begin : stqe_rotcmp_latch_gen

       tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) stqe_rotcmp_latch(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(ex3_addr_act[i]),
                         .force_t(func_sl_force),
                         .d_mode(d_mode_dc),
                         .delay_lclkr(delay_lclkr_dc),
                         .mpw1_b(mpw1_dc_b),
                         .mpw2_b(mpw2_dc_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[stqe_rotcmp_offset + 16 * i:stqe_rotcmp_offset + 16 * (i + 1) - 1]),
                         .scout(sov[stqe_rotcmp_offset + 16 * i:stqe_rotcmp_offset + 16 * (i + 1) - 1]),
                         .din(stqe_rotcmp_d[i]),
                         .dout(stqe_rotcmp_q[i])
                         );
     end
   end
   endgenerate
   generate
   begin : xhdl20
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_cline_chk_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_cline_chk_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(ex4_addr_act[i]),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[stqe_cline_chk_offset + i:stqe_cline_chk_offset + i]),
                            .scout(sov[stqe_cline_chk_offset + i:stqe_cline_chk_offset + i]),
                            .din(stqe_cline_chk_d[i]),
                            .dout(stqe_cline_chk_q[i])
                            );
     end
   end
   endgenerate
   generate
   begin : xhdl21
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_ttype_latch_gen

       tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) stqe_ttype_latch(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(ex5_addr_act[i]),
                        .force_t(func_sl_force),
                        .d_mode(d_mode_dc),
                        .delay_lclkr(delay_lclkr_dc),
                        .mpw1_b(mpw1_dc_b),
                        .mpw2_b(mpw2_dc_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[stqe_ttype_offset + 6 * i:stqe_ttype_offset + 6 * (i + 1) - 1]),
                        .scout(sov[stqe_ttype_offset + 6 * i:stqe_ttype_offset + 6 * (i + 1) - 1]),
                        .din(stqe_ttype_d[i]),
                        .dout(stqe_ttype_q[i])
                        );
     end
   end
   endgenerate
   generate
   begin : xhdl22
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_byte_en_latch_gen

       tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) stqe_byte_en_latch(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(ex3_addr_act[i]),
                          .force_t(func_sl_force),
                          .d_mode(d_mode_dc),
                          .delay_lclkr(delay_lclkr_dc),
                          .mpw1_b(mpw1_dc_b),
                          .mpw2_b(mpw2_dc_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[stqe_byte_en_offset + 16 * i:stqe_byte_en_offset + 16 * (i + 1) - 1]),
                          .scout(sov[stqe_byte_en_offset + 16 * i:stqe_byte_en_offset + 16 * (i + 1) - 1]),
                          .din(stqe_byte_en_d[i]),
                          .dout(stqe_byte_en_q[i])
                          );
     end
   end
   endgenerate
   generate
   begin : xhdl23
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_wimge_latch_gen

       tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) stqe_wimge_latch(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(ex4_addr_act[i]),
                        .force_t(func_sl_force),
                        .d_mode(d_mode_dc),
                        .delay_lclkr(delay_lclkr_dc),
                        .mpw1_b(mpw1_dc_b),
                        .mpw2_b(mpw2_dc_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[stqe_wimge_offset + 5 * i:stqe_wimge_offset + 5 * (i + 1) - 1]),
                        .scout(sov[stqe_wimge_offset + 5 * i:stqe_wimge_offset + 5 * (i + 1) - 1]),
                        .din(stqe_wimge_d[i]),
                        .dout(stqe_wimge_q[i])
                        );
     end
   end
   endgenerate
   generate
   begin : xhdl24
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_byte_swap_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_byte_swap_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(ex4_addr_act[i]),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[stqe_byte_swap_offset + i:stqe_byte_swap_offset + i]),
                            .scout(sov[stqe_byte_swap_offset + i:stqe_byte_swap_offset + i]),
                            .din(stqe_byte_swap_d[i]),
                            .dout(stqe_byte_swap_q[i])
                            );
     end
   end
   endgenerate
   generate
   begin : xhdl25
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_opsize_latch_gen

       tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) stqe_opsize_latch(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(ex4_addr_act[i]),
                         .force_t(func_sl_force),
                         .d_mode(d_mode_dc),
                         .delay_lclkr(delay_lclkr_dc),
                         .mpw1_b(mpw1_dc_b),
                         .mpw2_b(mpw2_dc_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[stqe_opsize_offset + 3 * i:stqe_opsize_offset + 3 * (i + 1) - 1]),
                         .scout(sov[stqe_opsize_offset + 3 * i:stqe_opsize_offset + 3 * (i + 1) - 1]),
                         .din(stqe_opsize_d[i]),
                         .dout(stqe_opsize_q[i])
                         );
     end
   end
   endgenerate
   generate
   begin : xhdl26
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_axu_val_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_axu_val_latch(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(ex5_addr_act[i]),
                          .force_t(func_sl_force),
                          .d_mode(d_mode_dc),
                          .delay_lclkr(delay_lclkr_dc),
                          .mpw1_b(mpw1_dc_b),
                          .mpw2_b(mpw2_dc_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[stqe_axu_val_offset + i:stqe_axu_val_offset + i]),
                          .scout(sov[stqe_axu_val_offset + i:stqe_axu_val_offset + i]),
                          .din(stqe_axu_val_d[i]),
                          .dout(stqe_axu_val_q[i])
                          );
     end
   end
   endgenerate
   generate
   begin : xhdl27
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_epid_val_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_epid_val_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(ex5_addr_act[i]),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[stqe_epid_val_offset + i:stqe_epid_val_offset + i]),
                           .scout(sov[stqe_epid_val_offset + i:stqe_epid_val_offset + i]),
                           .din(stqe_epid_val_d[i]),
                           .dout(stqe_epid_val_q[i])
                           );
     end
   end
   endgenerate
   generate
   begin : xhdl28
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_usr_def_latch_gen

       tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) stqe_usr_def_latch(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(ex5_addr_act[i]),
                          .force_t(func_sl_force),
                          .d_mode(d_mode_dc),
                          .delay_lclkr(delay_lclkr_dc),
                          .mpw1_b(mpw1_dc_b),
                          .mpw2_b(mpw2_dc_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[stqe_usr_def_offset + 4 * i:stqe_usr_def_offset + 4 * (i + 1) - 1]),
                          .scout(sov[stqe_usr_def_offset + 4 * i:stqe_usr_def_offset + 4 * (i + 1) - 1]),
                          .din(stqe_usr_def_d[i]),
                          .dout(stqe_usr_def_q[i])
                          );
     end
   end
   endgenerate
   generate
   begin : xhdl29
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_is_store_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_is_store_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(ex4_addr_act[i]),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[stqe_is_store_offset + i:stqe_is_store_offset + i]),
                           .scout(sov[stqe_is_store_offset + i:stqe_is_store_offset + i]),
                           .din(stqe_is_store_d[i]),
                           .dout(stqe_is_store_q[i])
                           );
     end
   end
   endgenerate
   generate
   begin : xhdl30
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_is_sync_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_is_sync_latch(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(ex4_addr_act[i]),
                          .force_t(func_sl_force),
                          .d_mode(d_mode_dc),
                          .delay_lclkr(delay_lclkr_dc),
                          .mpw1_b(mpw1_dc_b),
                          .mpw2_b(mpw2_dc_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[stqe_is_sync_offset + i:stqe_is_sync_offset + i]),
                          .scout(sov[stqe_is_sync_offset + i:stqe_is_sync_offset + i]),
                          .din(stqe_is_sync_d[i]),
                          .dout(stqe_is_sync_q[i])
                          );
     end
   end
   endgenerate
   generate
   begin : xhdl31
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_is_resv_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_is_resv_latch(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(ex4_addr_act[i]),
                          .force_t(func_sl_force),
                          .d_mode(d_mode_dc),
                          .delay_lclkr(delay_lclkr_dc),
                          .mpw1_b(mpw1_dc_b),
                          .mpw2_b(mpw2_dc_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[stqe_is_resv_offset + i:stqe_is_resv_offset + i]),
                          .scout(sov[stqe_is_resv_offset + i:stqe_is_resv_offset + i]),
                          .din(stqe_is_resv_d[i]),
                          .dout(stqe_is_resv_q[i])
                          );
     end
   end
   endgenerate
   generate
   begin : xhdl32
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_is_icswxr_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_is_icswxr_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(ex4_addr_act[i]),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[stqe_is_icswxr_offset + i:stqe_is_icswxr_offset + i]),
                            .scout(sov[stqe_is_icswxr_offset + i:stqe_is_icswxr_offset + i]),
                            .din(stqe_is_icswxr_d[i]),
                            .dout(stqe_is_icswxr_q[i])
                            );
     end
   end
   endgenerate
   generate
   begin : xhdl33
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_is_icbi_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_is_icbi_latch(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(ex4_addr_act[i]),
                          .force_t(func_sl_force),
                          .d_mode(d_mode_dc),
                          .delay_lclkr(delay_lclkr_dc),
                          .mpw1_b(mpw1_dc_b),
                          .mpw2_b(mpw2_dc_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[stqe_is_icbi_offset + i:stqe_is_icbi_offset + i]),
                          .scout(sov[stqe_is_icbi_offset + i:stqe_is_icbi_offset + i]),
                          .din(stqe_is_icbi_d[i]),
                          .dout(stqe_is_icbi_q[i])
                          );
     end
   end
   endgenerate
   generate
   begin : xhdl34
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_is_inval_op_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_is_inval_op_latch(
                              .nclk(nclk),
                              .vd(vdd),
                              .gd(gnd),
                              .act(ex4_addr_act[i]),
                              .force_t(func_sl_force),
                              .d_mode(d_mode_dc),
                              .delay_lclkr(delay_lclkr_dc),
                              .mpw1_b(mpw1_dc_b),
                              .mpw2_b(mpw2_dc_b),
                              .thold_b(func_sl_thold_0_b),
                              .sg(sg_0),
                              .scin(siv[stqe_is_inval_op_offset + i:stqe_is_inval_op_offset + i]),
                              .scout(sov[stqe_is_inval_op_offset + i:stqe_is_inval_op_offset + i]),
                              .din(stqe_is_inval_op_d[i]),
                              .dout(stqe_is_inval_op_q[i])
                              );
     end
   end
   endgenerate
   generate
   begin : xhdl35
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_dreq_val_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_dreq_val_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(ex4_addr_act[i]),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[stqe_dreq_val_offset + i:stqe_dreq_val_offset + i]),
                           .scout(sov[stqe_dreq_val_offset + i:stqe_dreq_val_offset + i]),
                           .din(stqe_dreq_val_d[i]),
                           .dout(stqe_dreq_val_q[i])
                           );
     end
   end
   endgenerate
   generate
   begin : xhdl36
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_has_data_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_has_data_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(ex4_addr_act[i]),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[stqe_has_data_offset + i:stqe_has_data_offset + i]),
                           .scout(sov[stqe_has_data_offset + i:stqe_has_data_offset + i]),
                           .din(stqe_has_data_d[i]),
                           .dout(stqe_has_data_q[i])
                           );
     end
   end
   endgenerate
   generate
   begin : xhdl37
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_send_l2_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_send_l2_latch(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(ex4_addr_act[i]),
                          .force_t(func_sl_force),
                          .d_mode(d_mode_dc),
                          .delay_lclkr(delay_lclkr_dc),
                          .mpw1_b(mpw1_dc_b),
                          .mpw2_b(mpw2_dc_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[stqe_send_l2_offset + i:stqe_send_l2_offset + i]),
                          .scout(sov[stqe_send_l2_offset + i:stqe_send_l2_offset + i]),
                          .din(stqe_send_l2_d[i]),
                          .dout(stqe_send_l2_q[i])
                          );
     end
   end
   endgenerate
   generate
   begin : xhdl38
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_lock_clr_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_lock_clr_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(ex5_addr_act[i]),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[stqe_lock_clr_offset + i:stqe_lock_clr_offset + i]),
                           .scout(sov[stqe_lock_clr_offset + i:stqe_lock_clr_offset + i]),
                           .din(stqe_lock_clr_d[i]),
                           .dout(stqe_lock_clr_q[i])
                           );
     end
   end
   endgenerate
   generate
   begin : xhdl39
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_watch_clr_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_watch_clr_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(ex4_addr_act[i]),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[stqe_watch_clr_offset + i:stqe_watch_clr_offset + i]),
                            .scout(sov[stqe_watch_clr_offset + i:stqe_watch_clr_offset + i]),
                            .din(stqe_watch_clr_d[i]),
                            .dout(stqe_watch_clr_q[i])
                            );
     end
   end
   endgenerate
   generate
   begin : xhdl40
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
     begin : stqe_l_fld_latch_gen

       tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) stqe_l_fld_latch(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(ex5_addr_act[i]),
                        .force_t(func_sl_force),
                        .d_mode(d_mode_dc),
                        .delay_lclkr(delay_lclkr_dc),
                        .mpw1_b(mpw1_dc_b),
                        .mpw2_b(mpw2_dc_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[stqe_l_fld_offset + 2 * i:stqe_l_fld_offset + 2 * (i + 1) - 1]),
                        .scout(sov[stqe_l_fld_offset + 2 * i:stqe_l_fld_offset + 2 * (i + 1) - 1]),
                        .din(stqe_l_fld_d[i]),
                        .dout(stqe_l_fld_q[i])
                        );
     end
   end
   endgenerate
   generate
   begin : xhdl41
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
     begin : stqe_thrd_id_latch_gen

       tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stqe_thrd_id_latch(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(stqe_itag_act[i]),
                          .force_t(func_sl_force),
                          .d_mode(d_mode_dc),
                          .delay_lclkr(delay_lclkr_dc),
                          .mpw1_b(mpw1_dc_b),
                          .mpw2_b(mpw2_dc_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[stqe_thrd_id_offset + `THREADS * i:stqe_thrd_id_offset + `THREADS * (i + 1) - 1]),
                          .scout(sov[stqe_thrd_id_offset + `THREADS * i:stqe_thrd_id_offset + `THREADS * (i + 1) - 1]),
                          .din(stqe_thrd_id_d[i]),
                          .dout(stqe_thrd_id_q[i])
                          );
     end
   end
   endgenerate
   generate
   begin : xhdl42
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
     begin : stqe_tgpr_latch_gen

       tri_rlmreg_p #(.WIDTH(AXU_TARGET_ENC), .INIT(0), .NEEDS_SRESET(1)) stqe_tgpr_latch(
                       .nclk(nclk),
                       .vd(vdd),
                       .gd(gnd),
                       .act(ex5_addr_act[i]),
                       .force_t(func_sl_force),
                       .d_mode(d_mode_dc),
                       .delay_lclkr(delay_lclkr_dc),
                       .mpw1_b(mpw1_dc_b),
                       .mpw2_b(mpw2_dc_b),
                       .thold_b(func_sl_thold_0_b),
                       .sg(sg_0),
                       .scin(siv[stqe_tgpr_offset + AXU_TARGET_ENC * i:stqe_tgpr_offset + AXU_TARGET_ENC * (i + 1) - 1]),
                       .scout(sov[stqe_tgpr_offset + AXU_TARGET_ENC * i:stqe_tgpr_offset + AXU_TARGET_ENC * (i + 1) - 1]),
                       .din(stqe_tgpr_d[i]),
                       .dout(stqe_tgpr_q[i])
                       );
     end
   end
   endgenerate
   generate
   begin : xhdl43
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
     begin : stqe_dvc_en_latch_gen

       tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) stqe_dvc_en_latch(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(ex5_addr_act[i]),
                         .force_t(func_sl_force),
                         .d_mode(d_mode_dc),
                         .delay_lclkr(delay_lclkr_dc),
                         .mpw1_b(mpw1_dc_b),
                         .mpw2_b(mpw2_dc_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[stqe_dvc_en_offset + 2 * i:stqe_dvc_en_offset + 2 * (i + 1) - 1]),
                         .scout(sov[stqe_dvc_en_offset + 2 * i:stqe_dvc_en_offset + 2 * (i + 1) - 1]),
                         .din(stqe_dvc_en_d[i]),
                         .dout(stqe_dvc_en_q[i])
                         );
     end
   end
   endgenerate
   generate
   begin : xhdl44
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
     begin : stqe_dacrw_latch_gen

       tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) stqe_dacrw_latch(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(ex5_addr_act[i]),
                        .force_t(func_sl_force),
                        .d_mode(d_mode_dc),
                        .delay_lclkr(delay_lclkr_dc),
                        .mpw1_b(mpw1_dc_b),
                        .mpw2_b(mpw2_dc_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[stqe_dacrw_offset + 4 * i:stqe_dacrw_offset + 4 * (i + 1) - 1]),
                        .scout(sov[stqe_dacrw_offset + 4 * i:stqe_dacrw_offset + 4 * (i + 1) - 1]),
                        .din(stqe_dacrw_d[i]),
                        .dout(stqe_dacrw_q[i])
                        );
     end
   end
   endgenerate
   generate
   begin : xhdl45
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES - 1; i = i + 1)
     begin : stqe_dvcr_cmpr_latch_gen

       tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) stqe_dvcr_cmpr_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(stq_act),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[stqe_dvcr_cmpr_offset + 2 * i:stqe_dvcr_cmpr_offset + 2 * (i + 1) - 1]),
                            .scout(sov[stqe_dvcr_cmpr_offset + 2 * i:stqe_dvcr_cmpr_offset + 2 * (i + 1) - 1]),
                            .din(stqe_dvcr_cmpr_d[i]),
                            .dout(stqe_dvcr_cmpr_q[i])
                            );
     end
   end
   endgenerate
   generate
   begin : xhdl47
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_qHit_held_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_qHit_held_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(stq_act),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[stqe_qHit_held_offset + i:stqe_qHit_held_offset + i]),
                            .scout(sov[stqe_qHit_held_offset + i:stqe_qHit_held_offset + i]),
                            .din(stqe_qHit_held_d[i]),
                            .dout(stqe_qHit_held_q[i])
                            );
     end
   end
   endgenerate
   generate
   begin : xhdl48
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_held_early_clr_latch_gen

       tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stqe_held_early_clr_latch(
                                 .nclk(nclk),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .act(stq_act),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[stqe_held_early_clr_offset + i:stqe_held_early_clr_offset + i]),
                                 .scout(sov[stqe_held_early_clr_offset + i:stqe_held_early_clr_offset + i]),
                                 .din(stqe_held_early_clr_d[i]),
                                 .dout(stqe_held_early_clr_q[i])
                                 );
     end
   end
   endgenerate
   generate
   begin : xhdl49
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stqe_data1_latch_gen

       tri_rlmreg_p #(.WIDTH(`STQ_DATA_SIZE), .INIT(0), .NEEDS_SRESET(1)) stqe_data1_latch(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(stqe_data_act[i]),
                        .force_t(func_sl_force),
                        .d_mode(d_mode_dc),
                        .delay_lclkr(delay_lclkr_dc),
                        .mpw1_b(mpw1_dc_b),
                        .mpw2_b(mpw2_dc_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[stqe_data1_offset + `STQ_DATA_SIZE * i:stqe_data1_offset + `STQ_DATA_SIZE * (i + 1) - 1]),
                        .scout(sov[stqe_data1_offset + `STQ_DATA_SIZE * i:stqe_data1_offset + `STQ_DATA_SIZE * (i + 1) - 1]),
                        .din(stqe_data1_d[i]),
                        .dout(stqe_data1_q[i])
                        );
     end
   end
   endgenerate

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   ex4_fxu1_data_ptr_latch(
                                 .nclk(nclk),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .act(ex3_fxu1_val),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[ex4_fxu1_data_ptr_offset:ex4_fxu1_data_ptr_offset + `STQ_ENTRIES - 1]),
                                 .scout(sov[ex4_fxu1_data_ptr_offset:ex4_fxu1_data_ptr_offset + `STQ_ENTRIES - 1]),
                                 .din(ex4_fxu1_data_ptr_d),
                                 .dout(ex4_fxu1_data_ptr_q)
                                 );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   ex4_axu_data_ptr_latch(
                                .nclk(nclk),
                                .vd(vdd),
                                .gd(gnd),
                                .act(ex3_axu_val),
                                .force_t(func_sl_force),
                                .d_mode(d_mode_dc),
                                .delay_lclkr(delay_lclkr_dc),
                                .mpw1_b(mpw1_dc_b),
                                .mpw2_b(mpw2_dc_b),
                                .thold_b(func_sl_thold_0_b),
                                .sg(sg_0),
                                .scin(siv[ex4_axu_data_ptr_offset:ex4_axu_data_ptr_offset + `STQ_ENTRIES - 1]),
                                .scout(sov[ex4_axu_data_ptr_offset:ex4_axu_data_ptr_offset + `STQ_ENTRIES - 1]),
                                .din(ex4_axu_data_ptr_d),
                                .dout(ex4_axu_data_ptr_q)
                                );

     tri_rlmreg_p #(.WIDTH((`STQ_DATA_SIZE)), .INIT(0), .NEEDS_SRESET(1))   ex4_fu_data_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(ex3_axu_val),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[ex4_fu_data_offset:ex4_fu_data_offset + (`STQ_DATA_SIZE) - 1]),
                           .scout(sov[ex4_fu_data_offset:ex4_fu_data_offset + (`STQ_DATA_SIZE) - 1]),
                           .din(xu_lq_axu_exp1_stq_data),
                           .dout(ex4_fu_data_q)
                           );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   cp_flush_latch(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(tiup),
                        .force_t(func_sl_force),
                        .d_mode(d_mode_dc),
                        .delay_lclkr(delay_lclkr_dc),
                        .mpw1_b(mpw1_dc_b),
                        .mpw2_b(mpw2_dc_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
                        .scout(sov[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
                        .din(iu_lq_cp_flush),
                        .dout(cp_flush_q)
                        );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   cp_next_val_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[cp_next_val_offset:cp_next_val_offset + `THREADS - 1]),
                           .scout(sov[cp_next_val_offset:cp_next_val_offset + `THREADS - 1]),
                           .din(iu_lq_cp_next_val),
                           .dout(cp_next_val_q)
                           );

   generate
   begin : xhdl50
     genvar                                                      i;
     for (i = 0; i <= `THREADS-1; i = i + 1)
     begin : cp_next_itag_latch_gen
             tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) cp_next_itag_latch(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(iu_lq_cp_next_val[i]),
                          .force_t(func_sl_force),
                          .d_mode(d_mode_dc),
                          .delay_lclkr(delay_lclkr_dc),
                          .mpw1_b(mpw1_dc_b),
                          .mpw2_b(mpw2_dc_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[cp_next_itag_offset + `ITAG_SIZE_ENC * i:cp_next_itag_offset + `ITAG_SIZE_ENC * (i + 1) - 1]),
                          .scout(sov[cp_next_itag_offset + `ITAG_SIZE_ENC * i:cp_next_itag_offset + `ITAG_SIZE_ENC * (i + 1) - 1]),
                          .din(iu_lq_cp_next_itag_int[i]),
                          .dout(cp_next_itag_q[i])
                          );
     end
   end
   endgenerate

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))     cp_i0_completed_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[cp_i0_completed_offset:cp_i0_completed_offset + `THREADS - 1]),
                           .scout(sov[cp_i0_completed_offset:cp_i0_completed_offset + `THREADS - 1]),
                           .din(iu_lq_i0_completed),
                           .dout(cp_i0_completed_q)
                           );
   generate
   begin : xhdl51
     genvar                                                      i;
     for (i = 0; i <= `THREADS-1; i = i + 1)
     begin : cp_i0_completed_itag_latch_gen
             tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) cp_i0_completed_itag_latch(
                                  .nclk(nclk),
                                  .vd(vdd),
                                  .gd(gnd),
                                  .act(iu_lq_i0_completed[i]),
                                  .force_t(func_sl_force),
                                  .d_mode(d_mode_dc),
                                  .delay_lclkr(delay_lclkr_dc),
                                  .mpw1_b(mpw1_dc_b),
                                  .mpw2_b(mpw2_dc_b),
                                  .thold_b(func_sl_thold_0_b),
                                  .sg(sg_0),
                                  .scin(siv[cp_i0_completed_itag_offset + `ITAG_SIZE_ENC * i:cp_i0_completed_itag_offset + `ITAG_SIZE_ENC * (i + 1) - 1]),
                                  .scout(sov[cp_i0_completed_itag_offset + `ITAG_SIZE_ENC * i:cp_i0_completed_itag_offset + `ITAG_SIZE_ENC * (i + 1) - 1]),
                                  .din(iu_lq_i0_completed_itag_int[i]),
                                  .dout(cp_i0_completed_itag_q[i])
                                  );
     end
   end
   endgenerate

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))     cp_i1_completed_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[cp_i1_completed_offset:cp_i1_completed_offset + `THREADS - 1]),
                           .scout(sov[cp_i1_completed_offset:cp_i1_completed_offset + `THREADS - 1]),
                           .din(iu_lq_i1_completed),
                           .dout(cp_i1_completed_q)
                           );
   generate
   begin : xhdl52
     genvar                                                      i;
     for (i = 0; i <= `THREADS-1; i = i + 1)
     begin : cp_i1_completed_itag_latch_gen

             tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) cp_I1_completed_itag_latch(
                                  .nclk(nclk),
                                  .vd(vdd),
                                  .gd(gnd),
                                  .act(iu_lq_i1_completed[i]),
                                  .force_t(func_sl_force),
                                  .d_mode(d_mode_dc),
                                  .delay_lclkr(delay_lclkr_dc),
                                  .mpw1_b(mpw1_dc_b),
                                  .mpw2_b(mpw2_dc_b),
                                  .thold_b(func_sl_thold_0_b),
                                  .sg(sg_0),
                                  .scin(siv[cp_i1_completed_itag_offset + `ITAG_SIZE_ENC * i:cp_i1_completed_itag_offset + `ITAG_SIZE_ENC * (i + 1) - 1]),
                                  .scout(sov[cp_i1_completed_itag_offset + `ITAG_SIZE_ENC * i:cp_i1_completed_itag_offset + `ITAG_SIZE_ENC * (i + 1) - 1]),
                                  .din(iu_lq_i1_completed_itag_int[i]),
                                  .dout(cp_i1_completed_itag_q[i])
                                  );
     end
   end
   endgenerate

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))     stq_cpl_need_hold_reg(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[stq_cpl_need_hold_offset]),
                           .scout(sov[stq_cpl_need_hold_offset]),
                           .din(stq_cpl_need_hold_d),
                           .dout(stq_cpl_need_hold_q)
                           );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   iu_lq_icbi_complete_latch(
                                   .nclk(nclk),
                                   .vd(vdd),
                                   .gd(gnd),
                                   .act(tiup),
                                   .force_t(func_sl_force),
                                   .d_mode(d_mode_dc),
                                   .delay_lclkr(delay_lclkr_dc),
                                   .mpw1_b(mpw1_dc_b),
                                   .mpw2_b(mpw2_dc_b),
                                   .thold_b(func_sl_thold_0_b),
                                   .sg(sg_0),
                                   .scin(siv[iu_lq_icbi_complete_offset:iu_lq_icbi_complete_offset + `THREADS - 1]),
                                   .scout(sov[iu_lq_icbi_complete_offset:iu_lq_icbi_complete_offset + `THREADS - 1]),
                                   .din(iu_lq_icbi_complete),
                                   .dout(iu_lq_icbi_complete_q)
                                   );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   iu_icbi_ack_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[iu_icbi_ack_offset:iu_icbi_ack_offset + `THREADS - 1]),
                           .scout(sov[iu_icbi_ack_offset:iu_icbi_ack_offset + `THREADS - 1]),
                           .din(iu_icbi_ack_d),
                           .dout(iu_icbi_ack_q)
                           );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   l2_icbi_ack_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[l2_icbi_ack_offset:l2_icbi_ack_offset + `THREADS - 1]),
                           .scout(sov[l2_icbi_ack_offset:l2_icbi_ack_offset + `THREADS - 1]),
                           .din(l2_icbi_ack_d),
                           .dout(l2_icbi_ack_q)
                           );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   rv1_binv_val_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[rv1_binv_val_offset]),
                            .scout(sov[rv1_binv_val_offset]),
                            .din(rv1_binv_val_d),
                            .dout(rv1_binv_val_q)
                            );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex0_binv_val_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[ex0_binv_val_offset]),
                            .scout(sov[ex0_binv_val_offset]),
                            .din(ex0_binv_val_d),
                            .dout(ex0_binv_val_q)
                            );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex1_binv_val_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[ex1_binv_val_offset]),
                            .scout(sov[ex1_binv_val_offset]),
                            .din(ex1_binv_val_d),
                            .dout(ex1_binv_val_q)
                            );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex2_binv_val_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[ex2_binv_val_offset]),
                            .scout(sov[ex2_binv_val_offset]),
                            .din(ex2_binv_val_d),
                            .dout(ex2_binv_val_q)
                            );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex3_binv_val_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[ex3_binv_val_offset]),
                            .scout(sov[ex3_binv_val_offset]),
                            .din(ex3_binv_val_d),
                            .dout(ex3_binv_val_q)
                            );

     tri_rlmreg_p #(.WIDTH(((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1)), .INIT(0), .NEEDS_SRESET(1))   rv1_binv_addr_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(l2_back_inv_val),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[rv1_binv_addr_offset:rv1_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1) - 1]),
                             .scout(sov[rv1_binv_addr_offset:rv1_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1) - 1]),
                             .din(rv1_binv_addr_d),
                             .dout(rv1_binv_addr_q)
                             );

     tri_rlmreg_p #(.WIDTH(((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1)), .INIT(0), .NEEDS_SRESET(1))   ex0_binv_addr_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(rv1_binv_val_q),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[ex0_binv_addr_offset:ex0_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1) - 1]),
                             .scout(sov[ex0_binv_addr_offset:ex0_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1) - 1]),
                             .din(ex0_binv_addr_d),
                             .dout(ex0_binv_addr_q)
                             );

     tri_rlmreg_p #(.WIDTH(((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1)), .INIT(0), .NEEDS_SRESET(1))   ex1_binv_addr_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(ex0_binv_val_q),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[ex1_binv_addr_offset:ex1_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1) - 1]),
                             .scout(sov[ex1_binv_addr_offset:ex1_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1) - 1]),
                             .din(ex1_binv_addr_d),
                             .dout(ex1_binv_addr_q)
                             );

     tri_rlmreg_p #(.WIDTH(((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1)), .INIT(0), .NEEDS_SRESET(1))   ex2_binv_addr_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(ex1_binv_val_q),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[ex2_binv_addr_offset:ex2_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1) - 1]),
                             .scout(sov[ex2_binv_addr_offset:ex2_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1) - 1]),
                             .din(ex2_binv_addr_d),
                             .dout(ex2_binv_addr_q)
                             );

     tri_rlmreg_p #(.WIDTH(((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1)), .INIT(0), .NEEDS_SRESET(1))   ex3_binv_addr_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(ex2_binv_val_q),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[ex3_binv_addr_offset:ex3_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1) - 1]),
                             .scout(sov[ex3_binv_addr_offset:ex3_binv_addr_offset + ((63-`CL_SIZE)-(64-(`DC_SIZE-3))+1) - 1]),
                             .din(ex3_binv_addr_d),
                             .dout(ex3_binv_addr_q)
                             );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq2_binv_blk_cclass_latch(
                                    .nclk(nclk),
                                    .vd(vdd),
                                    .gd(gnd),
                                    .act(stq_act),
                                    .force_t(func_sl_force),
                                    .d_mode(d_mode_dc),
                                    .delay_lclkr(delay_lclkr_dc),
                                    .mpw1_b(mpw1_dc_b),
                                    .mpw2_b(mpw2_dc_b),
                                    .thold_b(func_sl_thold_0_b),
                                    .sg(sg_0),
                                    .scin(siv[stq2_binv_blk_cclass_offset]),
                                    .scout(sov[stq2_binv_blk_cclass_offset]),
                                    .din(stq2_binv_blk_cclass_d),
                                    .dout(stq2_binv_blk_cclass_q)
                                    );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq2_ici_val_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(stq1_cmmt_act),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[stq2_ici_val_offset]),
                            .scout(sov[stq2_ici_val_offset]),
                            .din(stq2_ici_val_d),
                            .dout(stq2_ici_val_q)
                            );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq4_xucr0_cul_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[stq4_xucr0_cul_offset]),
                            .scout(sov[stq4_xucr0_cul_offset]),
                            .din(stq4_xucr0_cul_d),
                            .dout(stq4_xucr0_cul_q)
                            );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq2_reject_dci_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[stq2_reject_dci_offset]),
                            .scout(sov[stq2_reject_dci_offset]),
                            .din(stq2_reject_dci_d),
                            .dout(stq2_reject_dci_q)
                            );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq3_cmmt_reject_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[stq3_cmmt_reject_offset]),
                            .scout(sov[stq3_cmmt_reject_offset]),
                            .din(stq3_cmmt_reject_d),
                            .dout(stq3_cmmt_reject_q)
                            );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq2_dci_val_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(stq1_cmmt_act),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[stq2_dci_val_offset]),
                            .scout(sov[stq2_dci_val_offset]),
                            .din(stq2_dci_val_d),
                            .dout(stq2_dci_val_q)
                            );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq3_cmmt_dci_val_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[stq3_cmmt_dci_val_offset]),
                            .scout(sov[stq3_cmmt_dci_val_offset]),
                            .din(stq3_cmmt_dci_val_d),
                            .dout(stq3_cmmt_dci_val_q)
                            );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq4_cmmt_dci_val_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[stq4_cmmt_dci_val_offset]),
                            .scout(sov[stq4_cmmt_dci_val_offset]),
                            .din(stq4_cmmt_dci_val_d),
                            .dout(stq4_cmmt_dci_val_q)
                            );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq5_cmmt_dci_val_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[stq5_cmmt_dci_val_offset]),
                            .scout(sov[stq5_cmmt_dci_val_offset]),
                            .din(stq5_cmmt_dci_val_d),
                            .dout(stq5_cmmt_dci_val_q)
                            );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq2_cmmt_flushed_latch(
                                 .nclk(nclk),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .act(tiup),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[stq2_cmmt_flushed_offset]),
                                 .scout(sov[stq2_cmmt_flushed_offset]),
                                 .din(stq1_cmmt_flushed),
                                 .dout(stq2_cmmt_flushed_q)
                                 );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq3_cmmt_flushed_latch(
                                 .nclk(nclk),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .act(tiup),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[stq3_cmmt_flushed_offset]),
                                 .scout(sov[stq3_cmmt_flushed_offset]),
                                 .din(stq2_cmmt_flushed_q),
                                 .dout(stq3_cmmt_flushed_q)
                                 );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq4_cmmt_flushed_latch(
                                 .nclk(nclk),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .act(tiup),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[stq4_cmmt_flushed_offset]),
                                 .scout(sov[stq4_cmmt_flushed_offset]),
                                 .din(stq3_cmmt_flushed_q),
                                 .dout(stq4_cmmt_flushed_q)
                                 );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq5_cmmt_flushed_latch(
                                 .nclk(nclk),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .act(tiup),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[stq5_cmmt_flushed_offset]),
                                 .scout(sov[stq5_cmmt_flushed_offset]),
                                 .din(stq4_cmmt_flushed_q),
                                 .dout(stq5_cmmt_flushed_q)
                                 );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq6_cmmt_flushed_latch(
                                 .nclk(nclk),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .act(tiup),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[stq6_cmmt_flushed_offset]),
                                 .scout(sov[stq6_cmmt_flushed_offset]),
                                 .din(stq5_cmmt_flushed_q),
                                 .dout(stq6_cmmt_flushed_q)
                                 );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq7_cmmt_flushed_latch(
                                 .nclk(nclk),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .act(tiup),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[stq7_cmmt_flushed_offset]),
                                 .scout(sov[stq7_cmmt_flushed_offset]),
                                 .din(stq6_cmmt_flushed_q),
                                 .dout(stq7_cmmt_flushed_q)
                                 );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(2 ** (`STQ_ENTRIES - 1)), .NEEDS_SRESET(1))   stq1_cmmt_ptr_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(stq1_cmmt_act),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[stq1_cmmt_ptr_offset:stq1_cmmt_ptr_offset + `STQ_ENTRIES - 1]),
                             .scout(sov[stq1_cmmt_ptr_offset:stq1_cmmt_ptr_offset + `STQ_ENTRIES - 1]),
                             .din(stq1_cmmt_ptr_d),
                             .dout(stq1_cmmt_ptr_q)
                             );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   stq2_cmmt_ptr_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(stq1_cmmt_act),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[stq2_cmmt_ptr_offset:stq2_cmmt_ptr_offset + `STQ_ENTRIES - 1]),
                             .scout(sov[stq2_cmmt_ptr_offset:stq2_cmmt_ptr_offset + `STQ_ENTRIES - 1]),
                             .din(stq2_cmmt_ptr_d),
                             .dout(stq2_cmmt_ptr_q)
                             );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   stq3_cmmt_ptr_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(stq2_cmmt_val_q),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[stq3_cmmt_ptr_offset:stq3_cmmt_ptr_offset + `STQ_ENTRIES - 1]),
                             .scout(sov[stq3_cmmt_ptr_offset:stq3_cmmt_ptr_offset + `STQ_ENTRIES - 1]),
                             .din(stq3_cmmt_ptr_d),
                             .dout(stq3_cmmt_ptr_q)
                             );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   stq4_cmmt_ptr_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(stq3_cmmt_val_q),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[stq4_cmmt_ptr_offset:stq4_cmmt_ptr_offset + `STQ_ENTRIES - 1]),
                             .scout(sov[stq4_cmmt_ptr_offset:stq4_cmmt_ptr_offset + `STQ_ENTRIES - 1]),
                             .din(stq4_cmmt_ptr_d),
                             .dout(stq4_cmmt_ptr_q)
                             );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   stq5_cmmt_ptr_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(stq4_cmmt_val_q),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[stq5_cmmt_ptr_offset:stq5_cmmt_ptr_offset + `STQ_ENTRIES - 1]),
                             .scout(sov[stq5_cmmt_ptr_offset:stq5_cmmt_ptr_offset + `STQ_ENTRIES - 1]),
                             .din(stq5_cmmt_ptr_d),
                             .dout(stq5_cmmt_ptr_q)
                             );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   stq6_cmmt_ptr_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(stq5_cmmt_val_q),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[stq6_cmmt_ptr_offset:stq6_cmmt_ptr_offset + `STQ_ENTRIES - 1]),
                             .scout(sov[stq6_cmmt_ptr_offset:stq6_cmmt_ptr_offset + `STQ_ENTRIES - 1]),
                             .din(stq6_cmmt_ptr_d),
                             .dout(stq6_cmmt_ptr_q)
                             );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   stq7_cmmt_ptr_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(stq6_cmmt_val_q),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[stq7_cmmt_ptr_offset:stq7_cmmt_ptr_offset + `STQ_ENTRIES - 1]),
                             .scout(sov[stq7_cmmt_ptr_offset:stq7_cmmt_ptr_offset + `STQ_ENTRIES - 1]),
                             .din(stq7_cmmt_ptr_d),
                             .dout(stq7_cmmt_ptr_q)
                             );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq2_cmmt_val_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(stq_act),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[stq2_cmmt_val_offset]),
                             .scout(sov[stq2_cmmt_val_offset]),
                             .din(stq1_cmmt_val),
                             .dout(stq2_cmmt_val_q)
                             );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq3_cmmt_val_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(stq_act),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[stq3_cmmt_val_offset]),
                             .scout(sov[stq3_cmmt_val_offset]),
                             .din(stq2_cmmt_val),
                             .dout(stq3_cmmt_val_q)
                             );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq4_cmmt_val_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(stq_act),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[stq4_cmmt_val_offset]),
                             .scout(sov[stq4_cmmt_val_offset]),
                             .din(stq3_cmmt_val_q),
                             .dout(stq4_cmmt_val_q)
                             );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq5_cmmt_val_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(stq_act),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[stq5_cmmt_val_offset]),
                             .scout(sov[stq5_cmmt_val_offset]),
                             .din(stq4_cmmt_val_q),
                             .dout(stq5_cmmt_val_q)
                             );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq6_cmmt_val_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(stq_act),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[stq6_cmmt_val_offset]),
                             .scout(sov[stq6_cmmt_val_offset]),
                             .din(stq5_cmmt_val_q),
                             .dout(stq6_cmmt_val_q)
                             );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq7_cmmt_val_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(stq_act),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[stq7_cmmt_val_offset]),
                             .scout(sov[stq7_cmmt_val_offset]),
                             .din(stq6_cmmt_val_q),
                             .dout(stq7_cmmt_val_q)
                             );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ext_ack_queue_v_latch(
                               .nclk(nclk),
                               .vd(vdd),
                               .gd(gnd),
                               .act(tiup),
                               .force_t(func_sl_force),
                               .d_mode(d_mode_dc),
                               .delay_lclkr(delay_lclkr_dc),
                               .mpw1_b(mpw1_dc_b),
                               .mpw2_b(mpw2_dc_b),
                               .thold_b(func_sl_thold_0_b),
                               .sg(sg_0),
                               .scin(siv[ext_ack_queue_v_offset:ext_ack_queue_v_offset + `THREADS - 1]),
                               .scout(sov[ext_ack_queue_v_offset:ext_ack_queue_v_offset + `THREADS - 1]),
                               .din(ext_ack_queue_v_d),
                               .dout(ext_ack_queue_v_q)
                               );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ext_ack_queue_sync_latch(
                               .nclk(nclk),
                               .vd(vdd),
                               .gd(gnd),
                               .act(tiup),
                               .force_t(func_sl_force),
                               .d_mode(d_mode_dc),
                               .delay_lclkr(delay_lclkr_dc),
                               .mpw1_b(mpw1_dc_b),
                               .mpw2_b(mpw2_dc_b),
                               .thold_b(func_sl_thold_0_b),
                               .sg(sg_0),
                               .scin(siv[ext_ack_queue_sync_offset:ext_ack_queue_sync_offset + `THREADS - 1]),
                               .scout(sov[ext_ack_queue_sync_offset:ext_ack_queue_sync_offset + `THREADS - 1]),
                               .din(ext_ack_queue_sync_d),
                               .dout(ext_ack_queue_sync_q)
                               );
     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ext_ack_queue_stcx_latch(
                               .nclk(nclk),
                               .vd(vdd),
                               .gd(gnd),
                               .act(tiup),
                               .force_t(func_sl_force),
                               .d_mode(d_mode_dc),
                               .delay_lclkr(delay_lclkr_dc),
                               .mpw1_b(mpw1_dc_b),
                               .mpw2_b(mpw2_dc_b),
                               .thold_b(func_sl_thold_0_b),
                               .sg(sg_0),
                               .scin(siv[ext_ack_queue_stcx_offset:ext_ack_queue_stcx_offset + `THREADS - 1]),
                               .scout(sov[ext_ack_queue_stcx_offset:ext_ack_queue_stcx_offset + `THREADS - 1]),
                               .din(ext_ack_queue_stcx_d),
                               .dout(ext_ack_queue_stcx_q)
                               );
     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ext_ack_queue_icswxr_latch(
                               .nclk(nclk),
                               .vd(vdd),
                               .gd(gnd),
                               .act(tiup),
                               .force_t(func_sl_force),
                               .d_mode(d_mode_dc),
                               .delay_lclkr(delay_lclkr_dc),
                               .mpw1_b(mpw1_dc_b),
                               .mpw2_b(mpw2_dc_b),
                               .thold_b(func_sl_thold_0_b),
                               .sg(sg_0),
                               .scin(siv[ext_ack_queue_icswxr_offset:ext_ack_queue_icswxr_offset + `THREADS - 1]),
                               .scout(sov[ext_ack_queue_icswxr_offset:ext_ack_queue_icswxr_offset + `THREADS - 1]),
                               .din(ext_ack_queue_icswxr_d),
                               .dout(ext_ack_queue_icswxr_q)
                               );


   generate
   begin : xhdl53
     genvar                                                      i;
     for (i = 0; i <= `THREADS-1; i = i + 1)
     begin : ext_ack_queue_itag_latch_gen

       tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ext_ack_queue_itag_latch(
                                .nclk(nclk),
                                .vd(vdd),
                                .gd(gnd),
                                .act(tiup),
                                .force_t(func_sl_force),
                                .d_mode(d_mode_dc),
                                .delay_lclkr(delay_lclkr_dc),
                                .mpw1_b(mpw1_dc_b),
                                .mpw2_b(mpw2_dc_b),
                                .thold_b(func_sl_thold_0_b),
                                .sg(sg_0),
                                .scin(siv[ext_ack_queue_itag_offset + `ITAG_SIZE_ENC * i:ext_ack_queue_itag_offset + `ITAG_SIZE_ENC * (i + 1) - 1]),
                                .scout(sov[ext_ack_queue_itag_offset + `ITAG_SIZE_ENC * i:ext_ack_queue_itag_offset + `ITAG_SIZE_ENC * (i + 1) - 1]),
                                .din(ext_ack_queue_itag_d[i]),
                                .dout(ext_ack_queue_itag_q[i])
                                );
     end
   end
   endgenerate
   generate
   begin : xhdl54
     genvar                                                      i;
     for (i = 0; i <= `THREADS-1; i = i + 1)
     begin : ext_ack_queue_cr_wa_latch_gen

       tri_rlmreg_p #(.WIDTH(`CR_POOL_ENC+`THREADS_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) ext_ack_queue_cr_wa_latch(
                                 .nclk(nclk),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .act(tiup),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[ext_ack_queue_cr_wa_offset + (`CR_POOL_ENC+`THREADS_POOL_ENC) * i:ext_ack_queue_cr_wa_offset + (`CR_POOL_ENC+`THREADS_POOL_ENC) * (i + 1) - 1]),
                                 .scout(sov[ext_ack_queue_cr_wa_offset + (`CR_POOL_ENC+`THREADS_POOL_ENC) * i:ext_ack_queue_cr_wa_offset + (`CR_POOL_ENC+`THREADS_POOL_ENC) * (i + 1) - 1]),
                                 .din(ext_ack_queue_cr_wa_d[i]),
                                 .dout(ext_ack_queue_cr_wa_q[i])
                                 );
     end
   end
   endgenerate
   generate
   begin : xhdl55
     genvar                                                      i;
     for (i = 0; i <= `THREADS-1; i = i + 1)
     begin : ext_ack_queue_dacrw_det_latch_gen

       tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ext_ack_queue_dacrw_det_latch(
                                     .nclk(nclk),
                                     .vd(vdd),
                                     .gd(gnd),
                                     .act(tiup),
                                     .force_t(func_sl_force),
                                     .d_mode(d_mode_dc),
                                     .delay_lclkr(delay_lclkr_dc),
                                     .mpw1_b(mpw1_dc_b),
                                     .mpw2_b(mpw2_dc_b),
                                     .thold_b(func_sl_thold_0_b),
                                     .sg(sg_0),
                                     .scin(siv[ext_ack_queue_dacrw_det_offset + 4 * i:ext_ack_queue_dacrw_det_offset + 4 * (i + 1) - 1]),
                                     .scout(sov[ext_ack_queue_dacrw_det_offset + 4 * i:ext_ack_queue_dacrw_det_offset + 4 * (i + 1) - 1]),
                                     .din(ext_ack_queue_dacrw_det_d[i]),
                                     .dout(ext_ack_queue_dacrw_det_q[i])
                                     );
     end
   end
   endgenerate

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))     ext_ack_queue_dacrw_rpt_latch(
                                   .nclk(nclk),
                                   .vd(vdd),
                                   .gd(gnd),
                                   .act(tiup),
                                   .force_t(func_sl_force),
                                   .d_mode(d_mode_dc),
                                   .delay_lclkr(delay_lclkr_dc),
                                   .mpw1_b(mpw1_dc_b),
                                   .mpw2_b(mpw2_dc_b),
                                   .thold_b(func_sl_thold_0_b),
                                   .sg(sg_0),
                                   .scin(siv[ext_ack_queue_dacrw_rpt_offset:ext_ack_queue_dacrw_rpt_offset + `THREADS - 1]),
                                   .scout(sov[ext_ack_queue_dacrw_rpt_offset:ext_ack_queue_dacrw_rpt_offset + `THREADS - 1]),
                                   .din(ext_ack_queue_dacrw_rpt_d),
                                   .dout(ext_ack_queue_dacrw_rpt_q)
                                   );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq2_mftgpr_val_latch(
                               .nclk(nclk),
                               .vd(vdd),
                               .gd(gnd),
                               .act(stq_act),
                               .force_t(func_sl_force),
                               .d_mode(d_mode_dc),
                               .delay_lclkr(delay_lclkr_dc),
                               .mpw1_b(mpw1_dc_b),
                               .mpw2_b(mpw2_dc_b),
                               .thold_b(func_sl_thold_0_b),
                               .sg(sg_0),
                               .scin(siv[stq2_mftgpr_val_offset]),
                               .scout(sov[stq2_mftgpr_val_offset]),
                               .din(stq2_mftgpr_val_d),
                               .dout(stq2_mftgpr_val_q)
                               );

     tri_rlmreg_p #(.WIDTH(3), .INIT(6), .NEEDS_SRESET(1))   stq2_rtry_cnt_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(stq2_rtry_cnt_act),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[stq2_rtry_cnt_offset:stq2_rtry_cnt_offset + 3 - 1]),
                             .scout(sov[stq2_rtry_cnt_offset:stq2_rtry_cnt_offset + 3 - 1]),
                             .din(stq2_rtry_cnt_d),
                             .dout(stq2_rtry_cnt_q)
                             );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex5_stq_restart_latch(
                               .nclk(nclk),
                               .vd(vdd),
                               .gd(gnd),
                               .act(tiup),
                               .force_t(func_sl_force),
                               .d_mode(d_mode_dc),
                               .delay_lclkr(delay_lclkr_dc),
                               .mpw1_b(mpw1_dc_b),
                               .mpw2_b(mpw2_dc_b),
                               .thold_b(func_sl_thold_0_b),
                               .sg(sg_0),
                               .scin(siv[ex5_stq_restart_offset]),
                               .scout(sov[ex5_stq_restart_offset]),
                               .din(ex5_stq_restart_d),
                               .dout(ex5_stq_restart_q)
                               );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex5_stq_restart_miss_latch(
                                    .nclk(nclk),
                                    .vd(vdd),
                                    .gd(gnd),
                                    .act(tiup),
                                    .force_t(func_sl_force),
                                    .d_mode(d_mode_dc),
                                    .delay_lclkr(delay_lclkr_dc),
                                    .mpw1_b(mpw1_dc_b),
                                    .mpw2_b(mpw2_dc_b),
                                    .thold_b(func_sl_thold_0_b),
                                    .sg(sg_0),
                                    .scin(siv[ex5_stq_restart_miss_offset]),
                                    .scout(sov[ex5_stq_restart_miss_offset]),
                                    .din(ex5_stq_restart_miss_d),
                                    .dout(ex5_stq_restart_miss_q)
                                    );

     tri_rlmreg_p #(.WIDTH((`STQ_FWD_ENTRIES-1)), .INIT(0), .NEEDS_SRESET(1))   stq_fwd_pri_mask_latch(
                                .nclk(nclk),
                                .vd(vdd),
                                .gd(gnd),
                                .act(stq_act),
                                .force_t(func_sl_force),
                                .d_mode(d_mode_dc),
                                .delay_lclkr(delay_lclkr_dc),
                                .mpw1_b(mpw1_dc_b),
                                .mpw2_b(mpw2_dc_b),
                                .thold_b(func_sl_thold_0_b),
                                .sg(sg_0),
                                .scin(siv[stq_fwd_pri_mask_offset:stq_fwd_pri_mask_offset + (`STQ_FWD_ENTRIES-1) - 1]),
                                .scout(sov[stq_fwd_pri_mask_offset:stq_fwd_pri_mask_offset + (`STQ_FWD_ENTRIES-1) - 1]),
                                .din(stq_fwd_pri_mask_d),
                                .dout(stq_fwd_pri_mask_q[0:`STQ_FWD_ENTRIES - 2])
                                );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex5_fwd_val_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[ex5_fwd_val_offset]),
                           .scout(sov[ex5_fwd_val_offset]),
                           .din(ex5_fwd_val_d),
                           .dout(ex5_fwd_val_q)
                           );

     tri_rlmreg_p #(.WIDTH((`STQ_DATA_SIZE)), .INIT(0), .NEEDS_SRESET(1))   ex5_fwd_data_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(ex4_ldreq_valid),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[ex5_fwd_data_offset:ex5_fwd_data_offset + `STQ_DATA_SIZE - 1]),
                            .scout(sov[ex5_fwd_data_offset:ex5_fwd_data_offset + `STQ_DATA_SIZE - 1]),
                            .din(ex5_fwd_data_d),
                            .dout(ex5_fwd_data_q)
                            );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   ex4_set_stq_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[ex4_set_stq_offset:ex4_set_stq_offset + `STQ_ENTRIES - 1]),
                           .scout(sov[ex4_set_stq_offset:ex4_set_stq_offset + `STQ_ENTRIES - 1]),
                           .din(ex3_set_stq),
                           .dout(ex4_set_stq_q[0:`STQ_ENTRIES - 1])
                           );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   ex5_set_stq_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[ex5_set_stq_offset:ex5_set_stq_offset + `STQ_ENTRIES - 1]),
                           .scout(sov[ex5_set_stq_offset:ex5_set_stq_offset + `STQ_ENTRIES - 1]),
                           .din(ex4_set_stq[0:`STQ_ENTRIES - 1]),
                           .dout(ex5_set_stq_q[0:`STQ_ENTRIES - 1])
                           );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ex4_ldreq_val_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(tiup),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[ex4_ldreq_val_offset:ex4_ldreq_val_offset + `THREADS - 1]),
                             .scout(sov[ex4_ldreq_val_offset:ex4_ldreq_val_offset + `THREADS - 1]),
                             .din(ex3_ldreq_val),
                             .dout(ex4_ldreq_val_q)
                             );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex4_pfetch_val_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(tiup),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[ex4_pfetch_val_offset]),
                             .scout(sov[ex4_pfetch_val_offset]),
                             .din(ex3_pfetch_val),
                             .dout(ex4_pfetch_val_q)
                             );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ex3_streq_val_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(tiup),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[ex3_streq_val_offset:ex3_streq_val_offset + `THREADS - 1]),
                             .scout(sov[ex3_streq_val_offset:ex3_streq_val_offset + `THREADS - 1]),
                             .din(ex2_streq_val),
                             .dout(ex3_streq_val_q)
                             );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ex5_streq_val_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(tiup),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[ex5_streq_val_offset:ex5_streq_val_offset + `THREADS - 1]),
                             .scout(sov[ex5_streq_val_offset:ex5_streq_val_offset + `THREADS - 1]),
                             .din(ex4_streq_val),
                             .dout(ex5_streq_val_q)
                             );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ex4_wchkall_val_latch(
                               .nclk(nclk),
                               .vd(vdd),
                               .gd(gnd),
                               .act(tiup),
                               .force_t(func_sl_force),
                               .d_mode(d_mode_dc),
                               .delay_lclkr(delay_lclkr_dc),
                               .mpw1_b(mpw1_dc_b),
                               .mpw2_b(mpw2_dc_b),
                               .thold_b(func_sl_thold_0_b),
                               .sg(sg_0),
                               .scin(siv[ex4_wchkall_val_offset:ex4_wchkall_val_offset + `THREADS - 1]),
                               .scout(sov[ex4_wchkall_val_offset:ex4_wchkall_val_offset + `THREADS - 1]),
                               .din(ex3_wchkall_val),
                               .dout(ex4_wchkall_val_q)
                               );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   hwsync_ack_latch(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(tiup),
                          .force_t(func_sl_force),
                          .d_mode(d_mode_dc),
                          .delay_lclkr(delay_lclkr_dc),
                          .mpw1_b(mpw1_dc_b),
                          .mpw2_b(mpw2_dc_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[hwsync_ack_offset:hwsync_ack_offset + `THREADS - 1]),
                          .scout(sov[hwsync_ack_offset:hwsync_ack_offset + `THREADS - 1]),
                          .din(hwsync_ack),
                          .dout(hwsync_ack_q)
                          );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   lwsync_ack_latch(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(tiup),
                          .force_t(func_sl_force),
                          .d_mode(d_mode_dc),
                          .delay_lclkr(delay_lclkr_dc),
                          .mpw1_b(mpw1_dc_b),
                          .mpw2_b(mpw2_dc_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[lwsync_ack_offset:lwsync_ack_offset + `THREADS - 1]),
                          .scout(sov[lwsync_ack_offset:lwsync_ack_offset + `THREADS - 1]),
                          .din(lwsync_ack),
                          .dout(lwsync_ack_q)
                          );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   icswxr_ack_latch(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(tiup),
                          .force_t(func_sl_force),
                          .d_mode(d_mode_dc),
                          .delay_lclkr(delay_lclkr_dc),
                          .mpw1_b(mpw1_dc_b),
                          .mpw2_b(mpw2_dc_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[icswxr_ack_offset]),
                          .scout(sov[icswxr_ack_offset]),
                          .din(icswxr_ack),
                          .dout(icswxr_ack_q)
                          );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   icswxr_ack_dly1_latch(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(tiup),
                          .force_t(func_sl_force),
                          .d_mode(d_mode_dc),
                          .delay_lclkr(delay_lclkr_dc),
                          .mpw1_b(mpw1_dc_b),
                          .mpw2_b(mpw2_dc_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[icswxr_ack_dly1_offset]),
                          .scout(sov[icswxr_ack_dly1_offset]),
                          .din(icswxr_ack_q),
                          .dout(icswxr_ack_dly1_q)
                          );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   local_instr_ack_latch(
                               .nclk(nclk),
                               .vd(vdd),
                               .gd(gnd),
                               .act(tiup),
                               .force_t(func_sl_force),
                               .d_mode(d_mode_dc),
                               .delay_lclkr(delay_lclkr_dc),
                               .mpw1_b(mpw1_dc_b),
                               .mpw2_b(mpw2_dc_b),
                               .thold_b(func_sl_thold_0_b),
                               .sg(sg_0),
                               .scin(siv[local_instr_ack_offset:local_instr_ack_offset + `THREADS - 1]),
                               .scout(sov[local_instr_ack_offset:local_instr_ack_offset + `THREADS - 1]),
                               .din(local_instr_ack),
                               .dout(local_instr_ack_q)
                               );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   resv_ack_latch(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(tiup),
                        .force_t(func_sl_force),
                        .d_mode(d_mode_dc),
                        .delay_lclkr(delay_lclkr_dc),
                        .mpw1_b(mpw1_dc_b),
                        .mpw2_b(mpw2_dc_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[resv_ack_offset:resv_ack_offset + `THREADS - 1]),
                        .scout(sov[resv_ack_offset:resv_ack_offset + `THREADS - 1]),
                        .din(resv_ack_d),
                        .dout(resv_ack_q)
                        );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   stcx_pass_latch(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(tiup),
                         .force_t(func_sl_force),
                         .d_mode(d_mode_dc),
                         .delay_lclkr(delay_lclkr_dc),
                         .mpw1_b(mpw1_dc_b),
                         .mpw2_b(mpw2_dc_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[stcx_pass_offset:stcx_pass_offset + `THREADS - 1]),
                         .scout(sov[stcx_pass_offset:stcx_pass_offset + `THREADS - 1]),
                         .din(stcx_pass),
                         .dout(stcx_pass_q)
                         );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   icbi_ack_latch(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(tiup),
                        .force_t(func_sl_force),
                        .d_mode(d_mode_dc),
                        .delay_lclkr(delay_lclkr_dc),
                        .mpw1_b(mpw1_dc_b),
                        .mpw2_b(mpw2_dc_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[icbi_ack_offset:icbi_ack_offset + `THREADS - 1]),
                        .scout(sov[icbi_ack_offset:icbi_ack_offset + `THREADS - 1]),
                        .din(icbi_ack),
                        .dout(icbi_ack_q)
                        );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   icbi_val_latch(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(tiup),
                        .force_t(func_sl_force),
                        .d_mode(d_mode_dc),
                        .delay_lclkr(delay_lclkr_dc),
                        .mpw1_b(mpw1_dc_b),
                        .mpw2_b(mpw2_dc_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[icbi_val_offset:icbi_val_offset + `THREADS - 1]),
                        .scout(sov[icbi_val_offset:icbi_val_offset + `THREADS - 1]),
                        .din(icbi_val_d),
                        .dout(icbi_val_q)
                        );

     tri_rlmreg_p #(.WIDTH((57-RI+1)), .INIT(0), .NEEDS_SRESET(1))   icbi_addr_latch(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(stq2_cmmt_val_q),
                         .force_t(func_sl_force),
                         .d_mode(d_mode_dc),
                         .delay_lclkr(delay_lclkr_dc),
                         .mpw1_b(mpw1_dc_b),
                         .mpw2_b(mpw2_dc_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[icbi_addr_offset:icbi_addr_offset + (57-RI+1) - 1]),
                         .scout(sov[icbi_addr_offset:icbi_addr_offset + (57-RI+1) - 1]),
                         .din(icbi_addr_d),
                         .dout(icbi_addr_q)
                         );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ici_val_latch(
                       .nclk(nclk),
                       .vd(vdd),
                       .gd(gnd),
                       .act(tiup),
                       .force_t(func_sl_force),
                       .d_mode(d_mode_dc),
                       .delay_lclkr(delay_lclkr_dc),
                       .mpw1_b(mpw1_dc_b),
                       .mpw2_b(mpw2_dc_b),
                       .thold_b(func_sl_thold_0_b),
                       .sg(sg_0),
                       .scin(siv[ici_val_offset]),
                       .scout(sov[ici_val_offset]),
                       .din(ici_val_d),
                       .dout(ici_val_q)
                       );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   credit_free_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[credit_free_offset:credit_free_offset + `THREADS - 1]),
                           .scout(sov[credit_free_offset:credit_free_offset + `THREADS - 1]),
                           .din(credit_free_d),
                           .dout(credit_free_q)
                           );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   ex4_fwd_agecmp_latch(
                              .nclk(nclk),
                              .vd(vdd),
                              .gd(gnd),
                              .act(tiup),
                              .force_t(func_sl_force),
                              .d_mode(d_mode_dc),
                              .delay_lclkr(delay_lclkr_dc),
                              .mpw1_b(mpw1_dc_b),
                              .mpw2_b(mpw2_dc_b),
                              .thold_b(func_sl_thold_0_b),
                              .sg(sg_0),
                              .scin(siv[ex4_fwd_agecmp_offset:ex4_fwd_agecmp_offset + `STQ_ENTRIES - 1]),
                              .scout(sov[ex4_fwd_agecmp_offset:ex4_fwd_agecmp_offset + `STQ_ENTRIES - 1]),
                              .din(ex4_fwd_agecmp_d),
                              .dout(ex4_fwd_agecmp_q)
                              );

     tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1))   ex3_req_itag_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[ex3_req_itag_offset:ex3_req_itag_offset + `ITAG_SIZE_ENC - 1]),
                            .scout(sov[ex3_req_itag_offset:ex3_req_itag_offset + `ITAG_SIZE_ENC - 1]),
                            .din(ctl_lsq_ex2_itag),
                            .dout(ex3_req_itag_q)
                            );

     tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1))   ex4_req_itag_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[ex4_req_itag_offset:ex4_req_itag_offset + `ITAG_SIZE_ENC - 1]),
                            .scout(sov[ex4_req_itag_offset:ex4_req_itag_offset + `ITAG_SIZE_ENC - 1]),
                            .din(ex3_req_itag_q),
                            .dout(ex4_req_itag_q)
                            );

     tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1))   ex4_req_byte_en_latch(
                               .nclk(nclk),
                               .vd(vdd),
                               .gd(gnd),
                               .act(ex3_req_act),
                               .force_t(func_sl_force),
                               .d_mode(d_mode_dc),
                               .delay_lclkr(delay_lclkr_dc),
                               .mpw1_b(mpw1_dc_b),
                               .mpw2_b(mpw2_dc_b),
                               .thold_b(func_sl_thold_0_b),
                               .sg(sg_0),
                               .scin(siv[ex4_req_byte_en_offset:ex4_req_byte_en_offset + 16 - 1]),
                               .scout(sov[ex4_req_byte_en_offset:ex4_req_byte_en_offset + 16 - 1]),
                               .din(ctl_lsq_ex3_byte_en),
                               .dout(ex4_req_byte_en_q)
                               );

     tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1))   ex4_req_p_addr_l_latch(
                                .nclk(nclk),
                                .vd(vdd),
                                .gd(gnd),
                                .act(ex3_req_act),
                                .force_t(func_sl_force),
                                .d_mode(d_mode_dc),
                                .delay_lclkr(delay_lclkr_dc),
                                .mpw1_b(mpw1_dc_b),
                                .mpw2_b(mpw2_dc_b),
                                .thold_b(func_sl_thold_0_b),
                                .sg(sg_0),
                                .scin(siv[ex4_req_p_addr_l_offset:ex4_req_p_addr_l_offset + 6 - 1]),
                                .scout(sov[ex4_req_p_addr_l_offset:ex4_req_p_addr_l_offset + 6 - 1]),
                                .din(ctl_lsq_ex3_p_addr),
                                .dout(ex4_req_p_addr_l_q)
                                );

     tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1))   ex4_req_opsize_latch(
                              .nclk(nclk),
                              .vd(vdd),
                              .gd(gnd),
                              .act(ex3_req_act),
                              .force_t(func_sl_force),
                              .d_mode(d_mode_dc),
                              .delay_lclkr(delay_lclkr_dc),
                              .mpw1_b(mpw1_dc_b),
                              .mpw2_b(mpw2_dc_b),
                              .thold_b(func_sl_thold_0_b),
                              .sg(sg_0),
                              .scin(siv[ex4_req_opsize_offset:ex4_req_opsize_offset + 3 - 1]),
                              .scout(sov[ex4_req_opsize_offset:ex4_req_opsize_offset + 3 - 1]),
                              .din(ctl_lsq_ex3_opsize),
                              .dout(ex4_req_opsize_q)
                              );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex4_req_algebraic_latch(
                                 .nclk(nclk),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .act(ex3_req_act),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[ex4_req_algebraic_offset]),
                                 .scout(sov[ex4_req_algebraic_offset]),
                                 .din(ctl_lsq_ex3_algebraic),
                                 .dout(ex4_req_algebraic_q)
                                 );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ex3_req_thrd_id_latch(
                               .nclk(nclk),
                               .vd(vdd),
                               .gd(gnd),
                               .act(tiup),
                               .force_t(func_sl_force),
                               .d_mode(d_mode_dc),
                               .delay_lclkr(delay_lclkr_dc),
                               .mpw1_b(mpw1_dc_b),
                               .mpw2_b(mpw2_dc_b),
                               .thold_b(func_sl_thold_0_b),
                               .sg(sg_0),
                               .scin(siv[ex3_req_thrd_id_offset:ex3_req_thrd_id_offset + `THREADS - 1]),
                               .scout(sov[ex3_req_thrd_id_offset:ex3_req_thrd_id_offset + `THREADS - 1]),
                               .din(ctl_lsq_ex2_thrd_id),
                               .dout(ex3_req_thrd_id_q)
                               );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ex4_req_thrd_id_latch(
                               .nclk(nclk),
                               .vd(vdd),
                               .gd(gnd),
                               .act(ex3_req_act),
                               .force_t(func_sl_force),
                               .d_mode(d_mode_dc),
                               .delay_lclkr(delay_lclkr_dc),
                               .mpw1_b(mpw1_dc_b),
                               .mpw2_b(mpw2_dc_b),
                               .thold_b(func_sl_thold_0_b),
                               .sg(sg_0),
                               .scin(siv[ex4_req_thrd_id_offset:ex4_req_thrd_id_offset + `THREADS - 1]),
                               .scout(sov[ex4_req_thrd_id_offset:ex4_req_thrd_id_offset + `THREADS - 1]),
                               .din(ex3_req_thrd_id_q),
                               .dout(ex4_req_thrd_id_q)
                               );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ex5_req_thrd_id_latch(
                               .nclk(nclk),
                               .vd(vdd),
                               .gd(gnd),
                               .act(tiup),
                               .force_t(func_sl_force),
                               .d_mode(d_mode_dc),
                               .delay_lclkr(delay_lclkr_dc),
                               .mpw1_b(mpw1_dc_b),
                               .mpw2_b(mpw2_dc_b),
                               .thold_b(func_sl_thold_0_b),
                               .sg(sg_0),
                               .scin(siv[ex5_req_thrd_id_offset:ex5_req_thrd_id_offset + `THREADS - 1]),
                               .scout(sov[ex5_req_thrd_id_offset:ex5_req_thrd_id_offset + `THREADS - 1]),
                               .din(ex4_req_thrd_id_q),
                               .dout(ex5_req_thrd_id_q)
                               );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   thrd_held_latch(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(tiup),
                         .force_t(func_sl_force),
                         .d_mode(d_mode_dc),
                         .delay_lclkr(delay_lclkr_dc),
                         .mpw1_b(mpw1_dc_b),
                         .mpw2_b(mpw2_dc_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[thrd_held_offset:thrd_held_offset + `THREADS - 1]),
                         .scout(sov[thrd_held_offset:thrd_held_offset + `THREADS - 1]),
                         .din(thrd_held_d),
                         .dout(thrd_held_q)
                         );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   rv0_cr_hole_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[rv0_cr_hole_offset:rv0_cr_hole_offset + `THREADS - 1]),
                           .scout(sov[rv0_cr_hole_offset:rv0_cr_hole_offset + `THREADS - 1]),
                           .din(rv0_cr_hole_d),
                           .dout(rv0_cr_hole_q)
                           );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   rv1_cr_hole_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[rv1_cr_hole_offset:rv1_cr_hole_offset + `THREADS - 1]),
                           .scout(sov[rv1_cr_hole_offset:rv1_cr_hole_offset + `THREADS - 1]),
                           .din(rv1_cr_hole_d),
                           .dout(rv1_cr_hole_q)
                           );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ex0_cr_hole_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[ex0_cr_hole_offset:ex0_cr_hole_offset + `THREADS - 1]),
                           .scout(sov[ex0_cr_hole_offset:ex0_cr_hole_offset + `THREADS - 1]),
                           .din(ex0_cr_hole_d),
                           .dout(ex0_cr_hole_q)
                           );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   cr_ack_latch(
                      .nclk(nclk),
                      .vd(vdd),
                      .gd(gnd),
                      .act(tiup),
                      .force_t(func_sl_force),
                      .d_mode(d_mode_dc),
                      .delay_lclkr(delay_lclkr_dc),
                      .mpw1_b(mpw1_dc_b),
                      .mpw2_b(mpw2_dc_b),
                      .thold_b(func_sl_thold_0_b),
                      .sg(sg_0),
                      .scin(siv[cr_ack_offset:cr_ack_offset + `THREADS - 1]),
                      .scout(sov[cr_ack_offset:cr_ack_offset + `THREADS - 1]),
                      .din(cr_ack_d),
                      .dout(cr_ack_q)
                      );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   sync_ack_save_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(tiup),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[sync_ack_save_offset]),
                             .scout(sov[sync_ack_save_offset]),
                             .din(sync_ack_save_d),
                             .dout(sync_ack_save_q)
                             );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   cr_we_latch(
                     .nclk(nclk),
                     .vd(vdd),
                     .gd(gnd),
                     .act(tiup),
                     .force_t(func_sl_force),
                     .d_mode(d_mode_dc),
                     .delay_lclkr(delay_lclkr_dc),
                     .mpw1_b(mpw1_dc_b),
                     .mpw2_b(mpw2_dc_b),
                     .thold_b(func_sl_thold_0_b),
                     .sg(sg_0),
                     .scin(siv[cr_we_offset]),
                     .scout(sov[cr_we_offset]),
                     .din(cr_we_d),
                     .dout(cr_we_q)
                     );

     tri_rlmreg_p #(.WIDTH((`CR_POOL_ENC+`THREADS_POOL_ENC-1+1)), .INIT(0), .NEEDS_SRESET(1))   cr_wa_latch(
                     .nclk(nclk),
                     .vd(vdd),
                     .gd(gnd),
                     .act(cr_we_d),
                     .force_t(func_sl_force),
                     .d_mode(d_mode_dc),
                     .delay_lclkr(delay_lclkr_dc),
                     .mpw1_b(mpw1_dc_b),
                     .mpw2_b(mpw2_dc_b),
                     .thold_b(func_sl_thold_0_b),
                     .sg(sg_0),
                     .scin(siv[cr_wa_offset:cr_wa_offset + (`CR_POOL_ENC+`THREADS_POOL_ENC-1+1) - 1]),
                     .scout(sov[cr_wa_offset:cr_wa_offset + (`CR_POOL_ENC+`THREADS_POOL_ENC-1+1) - 1]),
                     .din(cr_wa_d),
                     .dout(cr_wa_q)
                     );

     tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1))   cr_wd_latch(
                     .nclk(nclk),
                     .vd(vdd),
                     .gd(gnd),
                     .act(cr_we_d),
                     .force_t(func_sl_force),
                     .d_mode(d_mode_dc),
                     .delay_lclkr(delay_lclkr_dc),
                     .mpw1_b(mpw1_dc_b),
                     .mpw2_b(mpw2_dc_b),
                     .thold_b(func_sl_thold_0_b),
                     .sg(sg_0),
                     .scin(siv[cr_wd_offset:cr_wd_offset + 4 - 1]),
                     .scout(sov[cr_wd_offset:cr_wd_offset + 4 - 1]),
                     .din(cr_wd_d),
                     .dout(cr_wd_q)
                     );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   stcx_thrd_fail_latch(
                     .nclk(nclk),
                     .vd(vdd),
                     .gd(gnd),
                     .act(tiup),
                     .force_t(func_sl_force),
                     .d_mode(d_mode_dc),
                     .delay_lclkr(delay_lclkr_dc),
                     .mpw1_b(mpw1_dc_b),
                     .mpw2_b(mpw2_dc_b),
                     .thold_b(func_sl_thold_0_b),
                     .sg(sg_0),
                     .scin(siv[stcx_thrd_fail_offset:stcx_thrd_fail_offset + `THREADS - 1]),
                     .scout(sov[stcx_thrd_fail_offset:stcx_thrd_fail_offset + `THREADS - 1]),
                     .din(stcx_thrd_fail_d),
                     .dout(stcx_thrd_fail_q)
                     );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   icswxr_thrd_busy_latch(
                     .nclk(nclk),
                     .vd(vdd),
                     .gd(gnd),
                     .act(tiup),
                     .force_t(func_sl_force),
                     .d_mode(d_mode_dc),
                     .delay_lclkr(delay_lclkr_dc),
                     .mpw1_b(mpw1_dc_b),
                     .mpw2_b(mpw2_dc_b),
                     .thold_b(func_sl_thold_0_b),
                     .sg(sg_0),
                     .scin(siv[icswxr_thrd_busy_offset:icswxr_thrd_busy_offset + `THREADS - 1]),
                     .scout(sov[icswxr_thrd_busy_offset:icswxr_thrd_busy_offset + `THREADS - 1]),
                     .din(icswxr_thrd_busy_d),
                     .dout(icswxr_thrd_busy_q)
                     );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   icswxr_thrd_nbusy_latch(
                     .nclk(nclk),
                     .vd(vdd),
                     .gd(gnd),
                     .act(tiup),
                     .force_t(func_sl_force),
                     .d_mode(d_mode_dc),
                     .delay_lclkr(delay_lclkr_dc),
                     .mpw1_b(mpw1_dc_b),
                     .mpw2_b(mpw2_dc_b),
                     .thold_b(func_sl_thold_0_b),
                     .sg(sg_0),
                     .scin(siv[icswxr_thrd_nbusy_offset:icswxr_thrd_nbusy_offset + `THREADS - 1]),
                     .scout(sov[icswxr_thrd_nbusy_offset:icswxr_thrd_nbusy_offset + `THREADS - 1]),
                     .din(icswxr_thrd_nbusy_d),
                     .dout(icswxr_thrd_nbusy_q)
                     );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq3_cmmt_attmpt_latch(
                     .nclk(nclk),
                     .vd(vdd),
                     .gd(gnd),
                     .act(tiup),
                     .force_t(func_sl_force),
                     .d_mode(d_mode_dc),
                     .delay_lclkr(delay_lclkr_dc),
                     .mpw1_b(mpw1_dc_b),
                     .mpw2_b(mpw2_dc_b),
                     .thold_b(func_sl_thold_0_b),
                     .sg(sg_0),
                     .scin(siv[stq3_cmmt_attmpt_offset]),
                     .scout(sov[stq3_cmmt_attmpt_offset]),
                     .din(stq3_cmmt_attmpt_d),
                     .dout(stq3_cmmt_attmpt_q)
                     );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   stq_need_hole_latch(
                     .nclk(nclk),
                     .vd(vdd),
                     .gd(gnd),
                     .act(tiup),
                     .force_t(func_sl_force),
                     .d_mode(d_mode_dc),
                     .delay_lclkr(delay_lclkr_dc),
                     .mpw1_b(mpw1_dc_b),
                     .mpw2_b(mpw2_dc_b),
                     .thold_b(func_sl_thold_0_b),
                     .sg(sg_0),
                     .scin(siv[stq_need_hole_offset]),
                     .scout(sov[stq_need_hole_offset]),
                     .din(stq_need_hole_d),
                     .dout(stq_need_hole_q)
                     );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   any_ack_hold_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[any_ack_hold_offset:any_ack_hold_offset + `THREADS - 1]),
                            .scout(sov[any_ack_hold_offset:any_ack_hold_offset + `THREADS - 1]),
                            .din(any_ack_hold_d),
                            .dout(any_ack_hold_q)
                            );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   any_ack_val_ok_latch(
                              .nclk(nclk),
                              .vd(vdd),
                              .gd(gnd),
                              .act(tiup),
                              .force_t(func_sl_force),
                              .d_mode(d_mode_dc),
                              .delay_lclkr(delay_lclkr_dc),
                              .mpw1_b(mpw1_dc_b),
                              .mpw2_b(mpw2_dc_b),
                              .thold_b(func_sl_thold_0_b),
                              .sg(sg_0),
                              .scin(siv[any_ack_val_ok_offset:any_ack_val_ok_offset + `THREADS - 1]),
                              .scout(sov[any_ack_val_ok_offset:any_ack_val_ok_offset + `THREADS - 1]),
                              .din(any_ack_val_ok_d),
                              .dout(any_ack_val_ok_q)
                              );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   arb_release_itag_vld_latch(
                                    .nclk(nclk),
                                    .vd(vdd),
                                    .gd(gnd),
                                    .act(tiup),
                                    .force_t(func_sl_force),
                                    .d_mode(d_mode_dc),
                                    .delay_lclkr(delay_lclkr_dc),
                                    .mpw1_b(mpw1_dc_b),
                                    .mpw2_b(mpw2_dc_b),
                                    .thold_b(func_sl_thold_0_b),
                                    .sg(sg_0),
                                    .scin(siv[arb_release_itag_vld_offset:arb_release_itag_vld_offset + `THREADS - 1]),
                                    .scout(sov[arb_release_itag_vld_offset:arb_release_itag_vld_offset + `THREADS - 1]),
                                    .din(arb_release_itag_vld_d),
                                    .dout(arb_release_itag_vld_q)
                                    );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   spr_xucr0_cls_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(tiup),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[spr_xucr0_cls_offset]),
                             .scout(sov[spr_xucr0_cls_offset]),
                             .din(spr_xucr0_cls_d),
                             .dout(spr_xucr0_cls_q)
                             );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   spr_iucr0_icbi_ack_latch(
                                  .nclk(nclk),
                                  .vd(vdd),
                                  .gd(gnd),
                                  .act(tiup),
                                  .force_t(func_sl_force),
                                  .d_mode(d_mode_dc),
                                  .delay_lclkr(delay_lclkr_dc),
                                  .mpw1_b(mpw1_dc_b),
                                  .mpw2_b(mpw2_dc_b),
                                  .thold_b(func_sl_thold_0_b),
                                  .sg(sg_0),
                                  .scin(siv[spr_iucr0_icbi_ack_offset]),
                                  .scout(sov[spr_iucr0_icbi_ack_offset]),
                                  .din(spr_iucr0_icbi_ack_d),
                                  .dout(spr_iucr0_icbi_ack_q)
                                  );
     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   spr_lsucr0_dfwd_latch(
                                  .nclk(nclk),
                                  .vd(vdd),
                                  .gd(gnd),
                                  .act(tiup),
                                  .force_t(func_sl_force),
                                  .d_mode(d_mode_dc),
                                  .delay_lclkr(delay_lclkr_dc),
                                  .mpw1_b(mpw1_dc_b),
                                  .mpw2_b(mpw2_dc_b),
                                  .thold_b(func_sl_thold_0_b),
                                  .sg(sg_0),
                                  .scin(siv[spr_lsucr0_dfwd_offset]),
                                  .scout(sov[spr_lsucr0_dfwd_offset]),
                                  .din(spr_lsucr0_dfwd_d),
                                  .dout(spr_lsucr0_dfwd_q)
                                  );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex5_thrd_match_restart_latch(
                                  .nclk(nclk),
                                  .vd(vdd),
                                  .gd(gnd),
                                  .act(tiup),
                                  .force_t(func_sl_force),
                                  .d_mode(d_mode_dc),
                                  .delay_lclkr(delay_lclkr_dc),
                                  .mpw1_b(mpw1_dc_b),
                                  .mpw2_b(mpw2_dc_b),
                                  .thold_b(func_sl_thold_0_b),
                                  .sg(sg_0),
                                  .scin(siv[ex5_thrd_match_restart_offset]),
                                  .scout(sov[ex5_thrd_match_restart_offset]),
                                  .din(ex5_thrd_match_restart_d),
                                  .dout(ex5_thrd_match_restart_q)
                                  );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex6_thrd_match_restart_latch(
                                  .nclk(nclk),
                                  .vd(vdd),
                                  .gd(gnd),
                                  .act(tiup),
                                  .force_t(func_sl_force),
                                  .d_mode(d_mode_dc),
                                  .delay_lclkr(delay_lclkr_dc),
                                  .mpw1_b(mpw1_dc_b),
                                  .mpw2_b(mpw2_dc_b),
                                  .thold_b(func_sl_thold_0_b),
                                  .sg(sg_0),
                                  .scin(siv[ex6_thrd_match_restart_offset]),
                                  .scout(sov[ex6_thrd_match_restart_offset]),
                                  .din(ex6_thrd_match_restart_d),
                                  .dout(ex6_thrd_match_restart_q)
                                  );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex5_thrd_nomatch_restart_latch(
                                  .nclk(nclk),
                                  .vd(vdd),
                                  .gd(gnd),
                                  .act(tiup),
                                  .force_t(func_sl_force),
                                  .d_mode(d_mode_dc),
                                  .delay_lclkr(delay_lclkr_dc),
                                  .mpw1_b(mpw1_dc_b),
                                  .mpw2_b(mpw2_dc_b),
                                  .thold_b(func_sl_thold_0_b),
                                  .sg(sg_0),
                                  .scin(siv[ex5_thrd_nomatch_restart_offset]),
                                  .scout(sov[ex5_thrd_nomatch_restart_offset]),
                                  .din(ex5_thrd_nomatch_restart_d),
                                  .dout(ex5_thrd_nomatch_restart_q)
                                  );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex6_thrd_nomatch_restart_latch(
                                  .nclk(nclk),
                                  .vd(vdd),
                                  .gd(gnd),
                                  .act(tiup),
                                  .force_t(func_sl_force),
                                  .d_mode(d_mode_dc),
                                  .delay_lclkr(delay_lclkr_dc),
                                  .mpw1_b(mpw1_dc_b),
                                  .mpw2_b(mpw2_dc_b),
                                  .thold_b(func_sl_thold_0_b),
                                  .sg(sg_0),
                                  .scin(siv[ex6_thrd_nomatch_restart_offset]),
                                  .scout(sov[ex6_thrd_nomatch_restart_offset]),
                                  .din(ex6_thrd_nomatch_restart_d),
                                  .dout(ex6_thrd_nomatch_restart_q)
                                  );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   ex5_older_ldmiss_latch(
                                .nclk(nclk),
                                .vd(vdd),
                                .gd(gnd),
                                .act(tiup),
                                .force_t(func_sl_force),
                                .d_mode(d_mode_dc),
                                .delay_lclkr(delay_lclkr_dc),
                                .mpw1_b(mpw1_dc_b),
                                .mpw2_b(mpw2_dc_b),
                                .thold_b(func_sl_thold_0_b),
                                .sg(sg_0),
                                .scin(siv[ex5_older_ldmiss_offset:ex5_older_ldmiss_offset + `STQ_ENTRIES - 1]),
                                .scout(sov[ex5_older_ldmiss_offset:ex5_older_ldmiss_offset + `STQ_ENTRIES - 1]),
                                .din(ex5_older_ldmiss_d),
                                .dout(ex5_older_ldmiss_q[0:`STQ_ENTRIES - 1])
                                );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex4_fxu1_illeg_lswx_latch(
                                   .nclk(nclk),
                                   .vd(vdd),
                                   .gd(gnd),
                                   .act(ex3_fxu1_val),
                                   .force_t(func_sl_force),
                                   .d_mode(d_mode_dc),
                                   .delay_lclkr(delay_lclkr_dc),
                                   .mpw1_b(mpw1_dc_b),
                                   .mpw2_b(mpw2_dc_b),
                                   .thold_b(func_sl_thold_0_b),
                                   .sg(sg_0),
                                   .scin(siv[ex4_fxu1_illeg_lswx_offset]),
                                   .scout(sov[ex4_fxu1_illeg_lswx_offset]),
                                   .din(ex4_fxu1_illeg_lswx_d),
                                   .dout(ex4_fxu1_illeg_lswx_q)
                                   );

     tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1))   ex4_fxu1_strg_noop_latch(
                                  .nclk(nclk),
                                  .vd(vdd),
                                  .gd(gnd),
                                  .act(ex3_fxu1_val),
                                  .force_t(func_sl_force),
                                  .d_mode(d_mode_dc),
                                  .delay_lclkr(delay_lclkr_dc),
                                  .mpw1_b(mpw1_dc_b),
                                  .mpw2_b(mpw2_dc_b),
                                  .thold_b(func_sl_thold_0_b),
                                  .sg(sg_0),
                                  .scin(siv[ex4_fxu1_strg_noop_offset]),
                                  .scout(sov[ex4_fxu1_strg_noop_offset]),
                                  .din(ex4_fxu1_strg_noop_d),
                                  .dout(ex4_fxu1_strg_noop_q)
                                  );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ex3_fxu1_val_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[ex3_fxu1_val_offset:ex3_fxu1_val_offset + `THREADS - 1]),
                            .scout(sov[ex3_fxu1_val_offset:ex3_fxu1_val_offset + `THREADS - 1]),
                            .din(ex3_fxu1_val_d),
                            .dout(ex3_fxu1_val_q)
                            );

     tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1))   ex3_fxu1_itag_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(ex2_fxu1_val),
                             .force_t(func_sl_force),
                             .d_mode(d_mode_dc),
                             .delay_lclkr(delay_lclkr_dc),
                             .mpw1_b(mpw1_dc_b),
                             .mpw2_b(mpw2_dc_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[ex3_fxu1_itag_offset:ex3_fxu1_itag_offset + `ITAG_SIZE_ENC - 1]),
                             .scout(sov[ex3_fxu1_itag_offset:ex3_fxu1_itag_offset + `ITAG_SIZE_ENC - 1]),
                             .din(ex3_fxu1_itag_d),
                             .dout(ex3_fxu1_itag_q)
                             );

     tri_rlmreg_p #(.WIDTH((((2**`GPR_WIDTH_ENC)/8)-1-0+1)), .INIT(0), .NEEDS_SRESET(1))   ex3_fxu1_dvc1_cmp_latch(
                                 .nclk(nclk),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .act(ex2_fxu1_val),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[ex3_fxu1_dvc1_cmp_offset:ex3_fxu1_dvc1_cmp_offset + (((2**`GPR_WIDTH_ENC)/8)-1-0+1) - 1]),
                                 .scout(sov[ex3_fxu1_dvc1_cmp_offset:ex3_fxu1_dvc1_cmp_offset + (((2**`GPR_WIDTH_ENC)/8)-1-0+1) - 1]),
                                 .din(ex3_fxu1_dvc1_cmp_d),
                                 .dout(ex3_fxu1_dvc1_cmp_q)
                                 );

     tri_rlmreg_p #(.WIDTH((((2**`GPR_WIDTH_ENC)/8)-1-0+1)), .INIT(0), .NEEDS_SRESET(1))   ex3_fxu1_dvc2_cmp_latch(
                                 .nclk(nclk),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .act(ex2_fxu1_val),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[ex3_fxu1_dvc2_cmp_offset:ex3_fxu1_dvc2_cmp_offset + (((2**`GPR_WIDTH_ENC)/8)-1-0+1) - 1]),
                                 .scout(sov[ex3_fxu1_dvc2_cmp_offset:ex3_fxu1_dvc2_cmp_offset + (((2**`GPR_WIDTH_ENC)/8)-1-0+1) - 1]),
                                 .din(ex3_fxu1_dvc2_cmp_d),
                                 .dout(ex3_fxu1_dvc2_cmp_q)
                                 );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ex4_fxu1_val_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[ex4_fxu1_val_offset:ex4_fxu1_val_offset + `THREADS - 1]),
                            .scout(sov[ex4_fxu1_val_offset:ex4_fxu1_val_offset + `THREADS - 1]),
                            .din(ex4_fxu1_val_d),
                            .dout(ex4_fxu1_val_q)
                            );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ex3_axu_val_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[ex3_axu_val_offset:ex3_axu_val_offset + `THREADS - 1]),
                           .scout(sov[ex3_axu_val_offset:ex3_axu_val_offset + `THREADS - 1]),
                           .din(ex3_axu_val_d),
                           .dout(ex3_axu_val_q)
                           );

     tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1))   ex3_axu_itag_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(ex2_axu_val),
                            .force_t(func_sl_force),
                            .d_mode(d_mode_dc),
                            .delay_lclkr(delay_lclkr_dc),
                            .mpw1_b(mpw1_dc_b),
                            .mpw2_b(mpw2_dc_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[ex3_axu_itag_offset:ex3_axu_itag_offset + `ITAG_SIZE_ENC - 1]),
                            .scout(sov[ex3_axu_itag_offset:ex3_axu_itag_offset + `ITAG_SIZE_ENC - 1]),
                            .din(ex3_axu_itag_d),
                            .dout(ex3_axu_itag_q)
                            );

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))   ex4_axu_val_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[ex4_axu_val_offset:ex4_axu_val_offset + `THREADS - 1]),
                           .scout(sov[ex4_axu_val_offset:ex4_axu_val_offset + `THREADS - 1]),
                           .din(ex4_axu_val_d),
                           .dout(ex4_axu_val_q)
                           );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   ex5_qHit_set_oth_latch(
                                .nclk(nclk),
                                .vd(vdd),
                                .gd(gnd),
                                .act(tiup),
                                .force_t(func_sl_force),
                                .d_mode(d_mode_dc),
                                .delay_lclkr(delay_lclkr_dc),
                                .mpw1_b(mpw1_dc_b),
                                .mpw2_b(mpw2_dc_b),
                                .thold_b(func_sl_thold_0_b),
                                .sg(sg_0),
                                .scin(siv[ex5_qHit_set_oth_offset:ex5_qHit_set_oth_offset + `STQ_ENTRIES - 1]),
                                .scout(sov[ex5_qHit_set_oth_offset:ex5_qHit_set_oth_offset + `STQ_ENTRIES - 1]),
                                .din(ex5_qHit_set_oth_d),
                                .dout(ex5_qHit_set_oth_q[0:`STQ_ENTRIES - 1])
                                );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   ex5_qHit_set_miss_latch(
                                 .nclk(nclk),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .act(tiup),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[ex5_qHit_set_miss_offset:ex5_qHit_set_miss_offset + `STQ_ENTRIES - 1]),
                                 .scout(sov[ex5_qHit_set_miss_offset:ex5_qHit_set_miss_offset + `STQ_ENTRIES - 1]),
                                 .din(ex5_qHit_set_miss_d),
                                 .dout(ex5_qHit_set_miss_q)
                                 );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   ex3_nxt_oldest_latch(
                              .nclk(nclk),
                              .vd(vdd),
                              .gd(gnd),
                              .act(tiup),
                              .force_t(func_sl_force),
                              .d_mode(d_mode_dc),
                              .delay_lclkr(delay_lclkr_dc),
                              .mpw1_b(mpw1_dc_b),
                              .mpw2_b(mpw2_dc_b),
                              .thold_b(func_sl_thold_0_b),
                              .sg(sg_0),
                              .scin(siv[ex3_nxt_oldest_offset:ex3_nxt_oldest_offset + `STQ_ENTRIES - 1]),
                              .scout(sov[ex3_nxt_oldest_offset:ex3_nxt_oldest_offset + `STQ_ENTRIES - 1]),
                              .din(ex3_nxt_oldest_d),
                              .dout(ex3_nxt_oldest_q)
                              );

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1))   stq_tag_val_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[stq_tag_val_offset:stq_tag_val_offset + `STQ_ENTRIES - 1]),
                           .scout(sov[stq_tag_val_offset:stq_tag_val_offset + `STQ_ENTRIES - 1]),
                           .din(stq_tag_val_d),
                           .dout(stq_tag_val_q)
                           );
   generate
   begin : xhdl56
     genvar                                                      i;
     for (i = 0; i <= `STQ_ENTRIES-1; i = i + 1)
     begin : stq_tag_ptr_latch_gen

       tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) stq_tag_ptr_latch(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(stq_tag_act[i]),
                         .force_t(func_sl_force),
                         .d_mode(d_mode_dc),
                         .delay_lclkr(delay_lclkr_dc),
                         .mpw1_b(mpw1_dc_b),
                         .mpw2_b(mpw2_dc_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[stq_tag_ptr_offset + `STQ_ENTRIES * i:stq_tag_ptr_offset + `STQ_ENTRIES * (i + 1) - 1]),
                         .scout(sov[stq_tag_ptr_offset + `STQ_ENTRIES * i:stq_tag_ptr_offset + `STQ_ENTRIES * (i + 1) - 1]),
                         .din(stq_tag_ptr_d[i]),
                         .dout(stq_tag_ptr_q[i])
                         );
     end
   end
   endgenerate

     tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES_ENC), .INIT(0), .NEEDS_SRESET(1))     stq4_cmmt_tag_latch(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(stq3_cmmt_val_q),
                         .force_t(func_sl_force),
                         .d_mode(d_mode_dc),
                         .delay_lclkr(delay_lclkr_dc),
                         .mpw1_b(mpw1_dc_b),
                         .mpw2_b(mpw2_dc_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[stq4_cmmt_tag_offset:stq4_cmmt_tag_offset + `STQ_ENTRIES_ENC - 1]),
                         .scout(sov[stq4_cmmt_tag_offset:stq4_cmmt_tag_offset + `STQ_ENTRIES_ENC - 1]),
                         .din(stq4_cmmt_tag_d),
                         .dout(stq4_cmmt_tag_q)
                         );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))     dbg_int_en_latch(
                       .nclk(nclk),
                       .vd(vdd),
                       .gd(gnd),
                       .act(tiup),
                       .force_t(func_sl_force),
                       .d_mode(d_mode_dc),
                       .delay_lclkr(delay_lclkr_dc),
                       .mpw1_b(mpw1_dc_b),
                       .mpw2_b(mpw2_dc_b),
                       .thold_b(func_sl_thold_0_b),
                       .sg(sg_0),
                       .scin(siv[dbg_int_en_offset:dbg_int_en_offset + `THREADS - 1]),
                       .scout(sov[dbg_int_en_offset:dbg_int_en_offset + `THREADS - 1]),
                       .din(dbg_int_en_d),
                       .dout(dbg_int_en_q)
                       );


     assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
     assign scan_out = sov[0];

endmodule
