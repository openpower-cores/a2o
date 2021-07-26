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

//********************************************************************
//*
//* TITLE: Instruction Select
//*
//* NAME: iuq_ic_select.v
//*
//*********************************************************************

`include "tri_a2o.vh"

module iuq_ic_select(
   inout                            vdd,
   inout                            gnd,

    (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]          nclk,
   input                            pc_iu_func_sl_thold_0_b,
   input                            pc_iu_func_slp_sl_thold_0_b,
   input                            pc_iu_sg_0,
   input                            force_t,
   input                            funcslp_force,
   input                            d_mode,
   input                            delay_lclkr,
   input                            mpw1_b,
   input                            mpw2_b,
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                            func_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                           func_scan_out,

   input [0:`THREADS-1]             pc_iu_ram_active,
   input [0:`THREADS-1]             pc_iu_pm_fetch_halt,
   input [0:`THREADS-1]             xu_iu_run_thread,
   input [0:`THREADS-1]             cp_ic_stop,
   input [0:`THREADS-1]             xu_iu_msr_cm,		// 0=32bit, 1=64bit address mode

   input [0:`THREADS-1]             cp_flush,
   input [0:`THREADS-1]             cp_flush_into_uc,
   input [0:`THREADS-1]             br_iu_redirect,
   input [62-`EFF_IFAR_ARCH:61]     br_iu_bta,
   input [62-`EFF_IFAR_ARCH:61]     cp_iu0_t0_flush_ifar,
 `ifndef THREADS1
   input [62-`EFF_IFAR_ARCH:61]     cp_iu0_t1_flush_ifar,
 `endif
   input [0:`THREADS-1]             cp_iu0_flush_2ucode,
   input [0:`THREADS-1]             cp_iu0_flush_2ucode_type,
   input [0:`THREADS-1]             cp_iu0_flush_nonspec,

   output [0:`THREADS-1]            ic_cp_nonspec_hit,

   input                            an_ac_back_inv,		// Arrives 1 cycle before addr
   input [64-`REAL_IFAR_WIDTH:57]   an_ac_back_inv_addr,
   input                            an_ac_back_inv_target,	// connect to bit(0); arrives 1 cycle before addr

   input                            spr_ic_prefetch_dis,
   input                            spr_ic_ierat_byp_dis,

   input                            spr_ic_idir_read,
   input [51:57]                    spr_ic_idir_row,

   output [3:8]                     ic_perf_t0_event,
 `ifndef THREADS1
   output [3:8]                     ic_perf_t1_event,
 `endif

   output                           iu_ierat_iu0_val,
   output [0:`THREADS-1]            iu_ierat_iu0_thdid,
   output [0:51]                    iu_ierat_iu0_ifar,
   output                           iu_ierat_iu0_nonspec,
   output                           iu_ierat_iu0_prefetch,
   output [0:`THREADS-1]            iu_ierat_flush,
   output                           iu_ierat_ium1_back_inv,
   input [0:`THREADS-1]             ierat_iu_hold_req,
   input [0:`THREADS-1]             ierat_iu_iu2_flush_req,
   input                            ierat_iu_iu2_miss,
   input                            ierat_iu_cam_change,

   // MMU Connections
   input [0:`THREADS-1]             mm_iu_hold_req,
   input [0:`THREADS-1]             mm_iu_hold_done,
   input [0:`THREADS-1]             mm_iu_bus_snoop_hold_req,
   input [0:`THREADS-1]             mm_iu_bus_snoop_hold_done,

   // ICBI Interface to IU
   input [0:`THREADS-1]             lq_iu_icbi_val,
   input [64-`REAL_IFAR_WIDTH:57]   lq_iu_icbi_addr,
   output [0:`THREADS-1]            iu_lq_icbi_complete,

   // IU IC Miss
   input [0:`THREADS-1]             icm_ics_iu0_preload_val,
   input [50:59]                    icm_ics_iu0_preload_ifar,
   input [0:`THREADS-1]             icm_ics_prefetch_req,
   input [0:`THREADS-1]             icm_ics_prefetch_sm_idle,

   input [0:`THREADS-1]             icm_ics_hold_thread,
   input                            icm_ics_hold_iu0,
   input                            icm_ics_iu3_miss_match,
   input [0:`THREADS-1]             icm_ics_iu3_ecc_fp_cancel,

   output [46:52]                   ics_icm_iu0_t0_ifar,
 `ifndef THREADS1
   output [46:52]                   ics_icm_iu0_t1_ifar,
 `endif
   output                           ics_icm_iu0_inval,
   output [51:57]                   ics_icm_iu0_inval_addr,
   output [0:`THREADS-1]            ics_icm_iu2_flush,

   // IU IC Dir
   output                           ics_icd_dir_rd_act,
   output [0:1]                     ics_icd_data_rd_act,
   output                           ics_icd_iu0_valid,
   output [0:`THREADS-1]            ics_icd_iu0_tid,
   output [62-`EFF_IFAR_ARCH:61]    ics_icd_iu0_ifar,
   output                           ics_icd_iu0_index51,
   output                           ics_icd_iu0_inval,
   output                           ics_icd_iu0_2ucode,
   output                           ics_icd_iu0_2ucode_type,
   output                           ics_icd_iu0_prefetch,
   output                           ics_icd_iu0_read_erat,
   output                           ics_icd_iu0_spr_idir_read,

   output [0:`THREADS-1]            ics_icd_iu1_flush,
   output [0:`THREADS-1]            ics_icd_iu2_flush,
   input                            icd_ics_iu1_valid,
   input [0:`THREADS-1]             icd_ics_iu1_tid,
   input [62-`EFF_IFAR_WIDTH:61]    icd_ics_iu1_ifar,
   input                            icd_ics_iu1_2ucode,
   input                            icd_ics_iu1_2ucode_type,
   input [0:`THREADS-1]             icd_ics_iu1_read_erat,
   input [0:`THREADS-1]             icd_ics_iu3_miss_flush,
   input [0:`THREADS-1]             icd_ics_iu2_wrong_ra_flush,
   input [0:`THREADS-1]             icd_ics_iu2_cam_etc_flush,
   input [62-`EFF_IFAR_WIDTH:61]    icd_ics_iu2_ifar_eff,
   input                            icd_ics_iu2_2ucode,
   input                            icd_ics_iu2_2ucode_type,
   input                            icd_ics_iu2_valid,
   input [0:`THREADS-1]             icd_ics_iu2_read_erat_error,
   input [0:`THREADS-1]             icd_ics_iu3_parity_flush,
   input [62-`EFF_IFAR_WIDTH:61]    icd_ics_iu3_ifar,
   input                            icd_ics_iu3_2ucode,
   input                            icd_ics_iu3_2ucode_type,

   // BP
   output [0:`THREADS-1]            ic_bp_iu0_val,
   output [50:59]                   ic_bp_iu0_ifar,
   output [0:`THREADS-1]            ic_bp_iu2_flush,

   //iu5 hold/redirect
   input [0:`THREADS-1]             bp_ic_iu2_redirect,
   input [0:`THREADS-1]             bp_ic_iu3_redirect,
   input [0:`THREADS-1]             bp_ic_iu4_redirect,
   input [62-`EFF_IFAR_WIDTH:61]    bp_ic_t0_redirect_ifar,
 `ifndef THREADS1
   input [62-`EFF_IFAR_WIDTH:61]    bp_ic_t1_redirect_ifar,
 `endif

   // ucode
   input [0:`THREADS-1]             uc_ic_hold,
   input [0:`THREADS-1]             uc_iu4_flush,
   input [62-`EFF_IFAR_WIDTH:61]    uc_iu4_t0_flush_ifar,
 `ifndef THREADS1
   input [62-`EFF_IFAR_WIDTH:61]    uc_iu4_t1_flush_ifar,
 `endif

   //Instruction Buffer
 `ifndef THREADS1
   input [0:`IBUFF_DEPTH/4-1]       ib_ic_t1_need_fetch,
 `endif
   input [0:`IBUFF_DEPTH/4-1]       ib_ic_t0_need_fetch,

   input                            event_bus_enable
);

   // iuq_ic_select

   localparam [0:31]               value_1 = 32'h00000001;

   parameter                       an_ac_back_inv_offset = 0;
   parameter                       an_ac_back_inv_target_offset = an_ac_back_inv_offset + 1;
   parameter                       an_ac_back_inv_addr_offset = an_ac_back_inv_target_offset + 1;
   parameter                       spr_idir_read_offset = an_ac_back_inv_addr_offset + `REAL_IFAR_WIDTH - 6;
   parameter                       spr_idir_row_offset = spr_idir_read_offset + 1;
   parameter                       oldest_prefetch_offset = spr_idir_row_offset + 7;
   parameter                       iu0_need_prefetch_offset = oldest_prefetch_offset + `THREADS - 1;
   parameter                       iu0_prefetch_ifar_offset = iu0_need_prefetch_offset + `THREADS;
   parameter                       lq_iu_icbi_val_offset = iu0_prefetch_ifar_offset + (`THREADS) * (`EFF_IFAR_WIDTH - 4);
   parameter                       lq_iu_icbi_addr_offset = lq_iu_icbi_val_offset + `THREADS * `THREADS;		//4
   parameter                       back_inv_offset = lq_iu_icbi_addr_offset + (`THREADS) * (`REAL_IFAR_WIDTH - 6);
   parameter                       back_inv_icbi_offset = back_inv_offset + 1;
   parameter                       xu_iu_msr_cm_offset = back_inv_icbi_offset + `THREADS;
   parameter                       xu_iu_msr_cm2_offset = xu_iu_msr_cm_offset + `THREADS;
   parameter                       xu_iu_msr_cm3_offset = xu_iu_msr_cm2_offset + `THREADS;
   parameter                       xu_iu_run_thread_offset = xu_iu_msr_cm3_offset + `THREADS;
   parameter                       cp_ic_stop_offset = xu_iu_run_thread_offset + `THREADS;		//2
   parameter                       pc_iu_pm_fetch_halt_offset = cp_ic_stop_offset + `THREADS;		//2
   parameter                       ierat_hold_offset = pc_iu_pm_fetch_halt_offset + `THREADS;		//2
   parameter                       iu0_2ucode_offset = ierat_hold_offset + `THREADS;		//2
   parameter                       iu0_2ucode_type_offset = iu0_2ucode_offset + `THREADS;		//2
   parameter                       iu0_flip_index51_offset = iu0_2ucode_type_offset + `THREADS;		//2
   parameter                       iu0_last_tid_sent_offset = iu0_flip_index51_offset + `THREADS;		//2
   parameter                       iu0_sent_offset = iu0_last_tid_sent_offset + 1 * (`THREADS - 1);		//1
   parameter                       iu0_ifar_offset = iu0_sent_offset + `THREADS * 3 * (`IBUFF_DEPTH/4);
   parameter                       stored_erat_ifar_offset = iu0_ifar_offset + `THREADS * `EFF_IFAR_ARCH;
   parameter                       stored_erat_valid_offset = stored_erat_ifar_offset + `THREADS * (`EFF_IFAR_WIDTH - 10);
   parameter                       mm_hold_req_offset = stored_erat_valid_offset + `THREADS;
   parameter                       mm_bus_snoop_hold_req_offset = mm_hold_req_offset + `THREADS;		//2
   parameter                       cp_flush_offset = mm_bus_snoop_hold_req_offset + `THREADS;		//2
   parameter                       cp_flush_into_uc_offset = cp_flush_offset + `THREADS;		//2
   parameter                       cp_flush_ifar_offset = cp_flush_into_uc_offset + `THREADS;		//2
   parameter                       cp_flush_2ucode_offset = cp_flush_ifar_offset + `THREADS * `EFF_IFAR_ARCH;
   parameter                       cp_flush_2ucode_type_offset = cp_flush_2ucode_offset + `THREADS;		//2
   parameter                       cp_flush_nonspec_offset = cp_flush_2ucode_type_offset + `THREADS;		//2
   parameter                       br_iu_redirect_offset = cp_flush_nonspec_offset + `THREADS;		//2
   parameter                       br_iu_bta_offset = br_iu_redirect_offset + `THREADS;		//2
   parameter                       next_fetch_nonspec_offset = br_iu_bta_offset + `EFF_IFAR_ARCH;
   parameter                       iu1_nonspec_offset = next_fetch_nonspec_offset + `THREADS;
   parameter                       iu2_nonspec_offset = iu1_nonspec_offset + `THREADS;
   parameter                       perf_event_offset = iu2_nonspec_offset + `THREADS;
   parameter                       scan_right = perf_event_offset + `THREADS * 6 - 1;

   wire                             tiup;

   // Latch inputs
   wire                             an_ac_back_inv_d;
   wire                             an_ac_back_inv_l2;

   wire                             an_ac_back_inv_target_d;
   wire                             an_ac_back_inv_target_l2;

   wire [64-`REAL_IFAR_WIDTH:57]    an_ac_back_inv_addr_d;
   wire [64-`REAL_IFAR_WIDTH:57]    an_ac_back_inv_addr_l2;

   wire                             spr_idir_read_d;
   wire                             spr_idir_read_l2;

   wire [51:57]                     spr_idir_row_d;
   wire [51:57]                     spr_idir_row_l2;

   wire                             oldest_prefetch_d;
   wire                             oldest_prefetch_l2;

   wire [0:`THREADS-1]              iu0_need_prefetch_d;
   wire [0:`THREADS-1]              iu0_need_prefetch_l2;

   wire [62-`EFF_IFAR_WIDTH:57]     iu0_prefetch_ifar_d[0:`THREADS-1];
   wire [62-`EFF_IFAR_WIDTH:57]     iu0_prefetch_ifar_l2[0:`THREADS-1];

   wire [0:`THREADS*`THREADS-1]     lq_iu_icbi_val_d;		// 2*2
   wire [0:`THREADS*`THREADS-1]     lq_iu_icbi_val_l2;		// 2*2

   wire [64-`REAL_IFAR_WIDTH:57]    lq_iu_icbi_addr_d[0:`THREADS-1];
   wire [64-`REAL_IFAR_WIDTH:57]    lq_iu_icbi_addr_l2[0:`THREADS-1];

   wire                             back_inv_d;
   wire                             back_inv_l2;

   wire [0:`THREADS-1]              back_inv_icbi_d;
   wire [0:`THREADS-1]              back_inv_icbi_l2;

   wire [0:`THREADS-1]              xu_iu_run_thread_d;
   wire [0:`THREADS-1]              xu_iu_run_thread_l2;

   wire [0:`THREADS-1]              xu_iu_msr_cm_d;
   wire [0:`THREADS-1]              xu_iu_msr_cm_l2;

   wire [0:`THREADS-1]              xu_iu_msr_cm2_d;
   wire [0:`THREADS-1]              xu_iu_msr_cm2_l2;

   wire [0:`THREADS-1]              xu_iu_msr_cm3_d;
   wire [0:`THREADS-1]              xu_iu_msr_cm3_l2;

   wire [0:`THREADS-1]              cp_ic_stop_d;
   wire [0:`THREADS-1]              cp_ic_stop_l2;

   wire [0:`THREADS-1]              pc_iu_pm_fetch_halt_d;
   wire [0:`THREADS-1]              pc_iu_pm_fetch_halt_l2;

   wire [0:`THREADS-1]              ierat_hold_d;
   wire [0:`THREADS-1]              ierat_hold_l2;

   // Current IFARs for each of the threads
   reg [62-`EFF_IFAR_ARCH:61]       iu0_ifar_temp[0:`THREADS-1];
   wire [62-`EFF_IFAR_ARCH:61]      iu0_ifar_d[0:`THREADS-1];
   wire [62-`EFF_IFAR_ARCH:61]      iu0_ifar_l2[0:`THREADS-1];

   reg [0:`THREADS-1]               iu0_2ucode_d;
   wire [0:`THREADS-1]              iu0_2ucode_l2;
   reg [0:`THREADS-1]               iu0_2ucode_type_d;
   wire [0:`THREADS-1]              iu0_2ucode_type_l2;

   wire [0:`THREADS-1]              iu0_flip_index51_d;
   wire [0:`THREADS-1]              iu0_flip_index51_l2;

   wire [62-`EFF_IFAR_WIDTH:51]     stored_erat_ifar_d[0:`THREADS-1];
   wire [62-`EFF_IFAR_WIDTH:51]     stored_erat_ifar_l2[0:`THREADS-1];
   wire [0:`THREADS-1]              stored_erat_valid_d;
   wire [0:`THREADS-1]              stored_erat_valid_l2;

   wire [0:`THREADS-1]              mm_hold_req_d;
   wire [0:`THREADS-1]              mm_hold_req_l2;

   wire [0:`THREADS-1]              mm_bus_snoop_hold_req_d;
   wire [0:`THREADS-1]              mm_bus_snoop_hold_req_l2;

   wire [0:`THREADS-1]              cp_flush_l2;
   wire [0:`THREADS-1]              cp_flush_into_uc_l2;
   wire [0:`THREADS-1]              br_iu_redirect_d;
   wire [62-`EFF_IFAR_ARCH:61]      cp_flush_ifar_d[0:`THREADS-1];
   wire [0:`THREADS-1]              br_iu_redirect_l2;
   wire [62-`EFF_IFAR_ARCH:61]      br_iu_bta_l2;
   wire [62-`EFF_IFAR_ARCH:61]      cp_flush_ifar_l2[0:`THREADS-1];
   wire [0:`THREADS-1]              cp_flush_2ucode_l2;
   wire [0:`THREADS-1]              cp_flush_2ucode_type_l2;
   wire [0:`THREADS-1]              cp_flush_nonspec_l2;

   wire [0:`THREADS-1]              next_fetch_nonspec_d;
   wire [0:`THREADS-1]              next_fetch_nonspec_l2;

   wire [0:`THREADS-1]              iu1_nonspec_d;
   wire [0:`THREADS-1]              iu2_nonspec_d;
   wire [0:`THREADS-1]              iu1_nonspec_l2;
   wire [0:`THREADS-1]              iu2_nonspec_l2;

   wire                             iu0_last_tid_sent_d;
   wire                             iu0_last_tid_sent_l2;

   // Used to keep track of the commands in flight to IB
   reg [0:2]                        iu0_sent_d[0:`THREADS-1][0:(`IBUFF_DEPTH/4)-1];
   wire [0:2]                       iu0_sent_l2[0:`THREADS-1][0:(`IBUFF_DEPTH/4)-1];

   wire [3:8]                       perf_event_d[0:`THREADS-1];
   wire [3:8]                       perf_event_l2[0:`THREADS-1];

   wire [62-`EFF_IFAR_WIDTH:61]     bp_ic_redirect_ifar[0:`THREADS-1];
   wire [62-`EFF_IFAR_WIDTH:61]     uc_iu4_flush_ifar[0:`THREADS-1];
   wire [0:`IBUFF_DEPTH/4-1]        ib_ic_need_fetch[0:`THREADS-1];


   wire [62-`EFF_IFAR_WIDTH:57]     new_prefetch_ifar;
   wire                             prefetch_wrap;
   wire [0:`THREADS-1]              msr_cm_changed;
   wire [0:`THREADS-1]              oldest_prefetch_v;
   wire [0:`THREADS-1]              iu2_prefetch_retry;
   wire [0:`THREADS-1]              iu0_prefetch_ifar_act;
   wire [0:`THREADS-1]              prefetch_addr_outside_range;
   wire [0:`THREADS-1]              flush_prefetch;
   wire [0:`THREADS-1]              prefetch_ready;
   wire [0:`THREADS-1]              next_prefetch;
   wire [0:`THREADS-1]              send_prefetch;

   wire                             back_inv_addr_act;

   wire [0:`THREADS-1]              toggle_flip;

   wire [0:`THREADS-1]              iu0_need_new_erat;
   wire [0:`THREADS-1]              clear_erat_valid;
   wire [0:`THREADS-1]              stored_erat_act;
   wire [0:`THREADS-1]              iu0_cross_4k_fetch;
   wire [0:`THREADS-1]              iu0_cross_4k_prefetch;
   wire [0:`THREADS-1]              iu0_cross_4k;
   wire [0:`THREADS-1]              iu0_read_erat;

   wire [0:`THREADS-1]              hold_thread;
   wire [0:`THREADS-1]              hold_thread_perf_lite;
   wire [0:`THREADS-1]              hold_prefetch;
   wire                             iu0_erat_valid;
   wire [0:`THREADS-1]              iu0_erat_tid;

   wire [0:`THREADS-1]              need_fetch_reduce;
   reg [0:(`IBUFF_DEPTH/4)-1]       need_fetch[0:`THREADS-1];
   reg [0:(`IBUFF_DEPTH/4)-1]       next_fetch[0:`THREADS-1];
   reg [0:(`IBUFF_DEPTH/4)-2]       shift1_sent[0:`THREADS-1];
   reg [0:`THREADS-1]               shift1_sent_reduce;
   reg [0:(`IBUFF_DEPTH/4)-3]       shift2_sent[0:`THREADS-1];
   reg [0:`THREADS-1]               shift2_sent_reduce;

   reg [0:`THREADS-1]               set_sent;
   wire [0:`THREADS-1]              thread_ready;
   wire                             iu0_valid;
   wire [0:`THREADS-1]              iu0_tid;
   wire [0:`THREADS-1]              iu0_flush;
   wire [0:`THREADS-1]              iu1_flush;
   wire [0:`THREADS-1]              iu2_flush;
   wire [0:`THREADS-1]              iu3_flush;
   wire [0:`THREADS-1]              iu1_ecc_flush;

   wire [0:1]                       data_rd_act;

   wire [62-`EFF_IFAR_ARCH:61]      iu0_ifar;

   wire                             block_spr_idir_read;

   // scan
   wire [0:scan_right]              siv;
   wire [0:scan_right]              sov;

   // BEGIN

   //tidn <= '0';
   assign tiup = 1'b1;

   assign br_iu_redirect_d = br_iu_redirect & (~(cp_flush_l2));

   assign cp_flush_ifar_d[0]     = cp_iu0_t0_flush_ifar;
   assign bp_ic_redirect_ifar[0] = bp_ic_t0_redirect_ifar;
   assign uc_iu4_flush_ifar[0]   = uc_iu4_t0_flush_ifar;
   assign ib_ic_need_fetch[0]    = ib_ic_t0_need_fetch;
  `ifndef THREADS1
     assign cp_flush_ifar_d[1]     = cp_iu0_t1_flush_ifar;
     assign bp_ic_redirect_ifar[1] = bp_ic_t1_redirect_ifar;
     assign uc_iu4_flush_ifar[1]   = uc_iu4_t1_flush_ifar;
     assign ib_ic_need_fetch[1]    = ib_ic_t1_need_fetch;
  `endif

   // Added logic for Erat invalidates
   assign mm_hold_req_d = (mm_iu_hold_req | mm_hold_req_l2) & (~(mm_iu_hold_done));

   assign mm_bus_snoop_hold_req_d = (mm_iu_bus_snoop_hold_req | mm_bus_snoop_hold_req_l2) & (~(mm_iu_bus_snoop_hold_done));

   //---------------------------------------------------------------------
   // SPR IDir Read
   //---------------------------------------------------------------------
   assign block_spr_idir_read = back_inv_l2 | icm_ics_hold_iu0;

   assign spr_idir_read_d = spr_ic_idir_read | (spr_idir_read_l2 & block_spr_idir_read);	// Invalidates & dir writes have priority

   assign spr_idir_row_d = spr_ic_idir_row;

   assign ics_icd_iu0_spr_idir_read = spr_idir_read_l2 & (~block_spr_idir_read);

   //---------------------------------------------------------------------
   // Prefetch
   //---------------------------------------------------------------------
   assign new_prefetch_ifar = icd_ics_iu2_ifar_eff[62 - `EFF_IFAR_WIDTH:57] + value_1[36-`EFF_IFAR_WIDTH:31];	// ??? Need to change if cls = 128 B
   assign prefetch_wrap = ~|(new_prefetch_ifar);

   // Prefetch request based off of old msr_cm value could occur two cycles after change, so need 3 latches
   assign msr_cm_changed = (xu_iu_msr_cm_d ^ xu_iu_msr_cm_l2) |        // prefetch request same cycle or earlier
                           (xu_iu_msr_cm_l2 ^ xu_iu_msr_cm2_l2) |      // prefetch request 1 cycle after change
                           (xu_iu_msr_cm2_l2 ^ xu_iu_msr_cm3_l2);      // prefetch request 2 cycles after change

   // icm_ics_prefetch_req & (ierat_iu_iu2_flush_req and iu2_prefetch) are mutually exclusive,
   // since you cannot have both iu2_valid & iu2_prefetch at the same time
   // Check iu0_need_prefetch=0 to make sure newer prefetch req didn't sneak in last two cycles
   assign oldest_prefetch_d = ((icm_ics_prefetch_req[`THREADS - 1] | iu2_prefetch_retry[0]) == 1'b1) ? 1'b0 : 		// Thread 1 or Thr 0 when single thread
                              ((icm_ics_prefetch_req[0] | iu2_prefetch_retry[`THREADS - 1]) == 1'b1) ? 1'b1 :
                              oldest_prefetch_l2;

   assign oldest_prefetch_v[0] = (~oldest_prefetch_l2);

  `ifndef THREADS1   // THREADS > 1
     assign oldest_prefetch_v[`THREADS - 1] = oldest_prefetch_l2;
  `endif

   generate
   begin : xhdl1
     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : gen_prefetch
       assign iu2_prefetch_retry[i] = (ierat_iu_iu2_flush_req[i] | icd_ics_iu2_cam_etc_flush[i]) & (~icd_ics_iu2_valid) & (~iu0_need_prefetch_l2[i]);

       assign iu0_need_prefetch_d[i] = ((icm_ics_prefetch_req[i] & (~prefetch_wrap)) |          // don't wrap around
                                        (iu0_need_prefetch_l2[i] & (~send_prefetch[i]) & (~flush_prefetch[i])) |
                                        (iu2_prefetch_retry[i] & (~flush_prefetch[i])))  &
                                       (~spr_ic_prefetch_dis) & (~msr_cm_changed[i]);

       assign iu0_prefetch_ifar_act[i] = (icm_ics_prefetch_req[i] & (~prefetch_wrap)) | iu2_prefetch_retry[i];

       assign iu0_prefetch_ifar_d[i] = (icd_ics_iu2_valid == 1'b1) ? new_prefetch_ifar :
                                       icd_ics_iu2_ifar_eff[62 - `EFF_IFAR_WIDTH:57]; 	// prefetch collision w/ ierat op (ierat_iu_iu2_flush_req)

       assign prefetch_addr_outside_range[i] = bp_ic_redirect_ifar[i][46:52] != iu0_prefetch_ifar_l2[i][46:52];
       assign flush_prefetch[i] = cp_flush_l2[i] | br_iu_redirect_l2[i] | (bp_ic_iu4_redirect[i] & prefetch_addr_outside_range[i]);
     end
   end
   endgenerate

   assign prefetch_ready = iu0_need_prefetch_l2 & icm_ics_prefetch_sm_idle & (~hold_prefetch);

   assign next_prefetch = ((&(prefetch_ready)) == 1'b1) ? oldest_prefetch_v :   // both are valid, choose oldest
                          prefetch_ready; 		// 1 or 0 are valid

   assign send_prefetch = next_prefetch & (~flush_prefetch);

   //---------------------------------------------------------------------
   // IU0
   //---------------------------------------------------------------------
   assign an_ac_back_inv_d = an_ac_back_inv;
   assign an_ac_back_inv_target_d = an_ac_back_inv_target;
   assign an_ac_back_inv_addr_d = an_ac_back_inv_addr;
   assign back_inv_addr_act = an_ac_back_inv_l2 & an_ac_back_inv_target_l2;

   generate
   begin
     if (`THREADS == 1)
     begin : gen_icbi_val_t1
       assign lq_iu_icbi_val_d[0] = lq_iu_icbi_val[0] | (lq_iu_icbi_val_l2[0] & an_ac_back_inv_l2 & an_ac_back_inv_target_l2);
     end

     // Two-deep buffer, with 2 bits for Thread0&1
     if (`THREADS == 2)
     begin : gen_icbi_val_t2
       assign lq_iu_icbi_val_d[0:`THREADS - 1] = ((an_ac_back_inv_l2 & an_ac_back_inv_target_l2 &
                                                   (|(lq_iu_icbi_val_l2[0:`THREADS - 1]))) == 1'b1) ? lq_iu_icbi_val_l2[0:`THREADS - 1] :
                                                 ((|(lq_iu_icbi_val_l2[2:3])) == 1'b1)              ? lq_iu_icbi_val_l2[2:3] :
                                                                                                      lq_iu_icbi_val;

       assign lq_iu_icbi_val_d[2:3] = (an_ac_back_inv_l2 & an_ac_back_inv_target_l2 & (|(lq_iu_icbi_val_l2[2:3])) == 1'b1)    ? lq_iu_icbi_val_l2[2:3] :
                                      (an_ac_back_inv_l2 & an_ac_back_inv_target_l2 & (|(lq_iu_icbi_val_l2[0:`THREADS - 1])) == 1'b1) ? lq_iu_icbi_val :
                                      2'b00;
     end

     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : gen_icbi_addr
       assign lq_iu_icbi_addr_d[i] = lq_iu_icbi_addr;
     end
   end
   endgenerate

   assign iu_lq_icbi_complete = {`THREADS{~(an_ac_back_inv_l2 & an_ac_back_inv_target_l2)}} & lq_iu_icbi_val_l2[0:`THREADS - 1];

   assign back_inv_d = (an_ac_back_inv_l2 & an_ac_back_inv_target_l2) | (|(lq_iu_icbi_val_l2[0:`THREADS - 1]));
   assign back_inv_icbi_d = {`THREADS{~(an_ac_back_inv_l2 & an_ac_back_inv_target_l2)}} & lq_iu_icbi_val_l2[0:`THREADS - 1];

   assign iu_ierat_ium1_back_inv = back_inv_d;

   assign xu_iu_msr_cm_d = xu_iu_msr_cm;
   assign xu_iu_msr_cm2_d = xu_iu_msr_cm_l2;
   assign xu_iu_msr_cm3_d = xu_iu_msr_cm2_l2;

   assign xu_iu_run_thread_d = xu_iu_run_thread;
   assign cp_ic_stop_d = cp_ic_stop;
   assign pc_iu_pm_fetch_halt_d = pc_iu_pm_fetch_halt;

   assign ierat_hold_d = ierat_iu_hold_req;

   // This keeps track of the commands in flight to IB
   // Note: icm_ics_iu0_preload_val should only be on if hold_thread='1' because of icm_ics_hold_iu0

   //always @(iu0_sent_l2 or ib_ic_need_fetch or iu0_tid or need_fetch or next_fetch or shift1_sent or shift1_sent_reduce or shift2_sent or shift2_sent_reduce or set_sent or iu0_flush or iu1_flush or iu2_flush or icm_ics_iu0_preload_val)
   always @ (*)
   begin: sent_proc
     reg [0:1]          any_sent[0:`THREADS-1];		//(`THREADS)(0 to 1);
     reg                any_lower_fetch;
      (* analysis_not_referenced="true" *)
     integer  t;
      (* analysis_not_referenced="true" *)
     integer  i;
      (* analysis_not_referenced="true" *)
     integer  j;

     for (t = 0; t < `THREADS; t = t + 1)
     begin
       for (i = 0; i < `IBUFF_DEPTH/4; i = i + 1)
         need_fetch[t][i] = ib_ic_need_fetch[t][i] & (~|(iu0_sent_l2[t][i]));

       next_fetch[t][0] = need_fetch[t][0];
       for (i = 1; i < `IBUFF_DEPTH/4; i = i + 1)
       begin
         any_lower_fetch = 0;
         for (j=0; j < i; j = j + 1)
         begin
           any_lower_fetch = need_fetch[t][j] | any_lower_fetch;
         end

         next_fetch[t][i] = need_fetch[t][i] & (~any_lower_fetch);
       end

       // need to shift as buffer gets emptier
       for (i = 0; i < ((`IBUFF_DEPTH/4) - 1); i = i + 1)
         shift1_sent[t][i] = next_fetch[t][i] & (|(iu0_sent_l2[t][i + 1]));
       shift1_sent_reduce[t] = |(shift1_sent[t]);

       for (i = 0; i < ((`IBUFF_DEPTH/4) - 2); i = i + 1)
         shift2_sent[t][i] = next_fetch[t][i] & (|(iu0_sent_l2[t][i + 2]));
       shift2_sent_reduce[t] = |(shift2_sent[t]);

       any_sent[t] = 2'b00;
       for (i = 0; i < `IBUFF_DEPTH/4; i = i + 1)
       begin
         any_sent[t][0] = any_sent[t][0] | iu0_sent_l2[t][i][0];
         any_sent[t][1] = any_sent[t][1] | iu0_sent_l2[t][i][1];
       end

       set_sent[t] = (iu0_tid[t] | icm_ics_iu0_preload_val[t]) & (~iu0_flush[t]);

       for (i = 0; i < `IBUFF_DEPTH/4; i = i + 1)
         iu0_sent_d[t][i] = iu0_sent_l2[t][i];

       if (shift1_sent_reduce[t] == 1'b1)		// shift 1
       begin
         for (i = 0; i < `IBUFF_DEPTH/4; i = i + 1)
         begin
           // swap with current last position
           if (any_sent[t][0] == 1'b1)
             iu0_sent_d[t][i][0] = set_sent[t] & iu0_sent_l2[t][i][0];
           else if (any_sent[t][1] == 1'b1)
             iu0_sent_d[t][i][0] = set_sent[t] & iu0_sent_l2[t][i][1];
           else
             iu0_sent_d[t][i][0] = set_sent[t] & iu0_sent_l2[t][i][2];
         end

         // shift down
         for (i = 0; i < ((`IBUFF_DEPTH/4) - 1); i = i + 1)
         begin
           iu0_sent_d[t][i][1] = iu0_sent_l2[t][i + 1][0] & (~(iu1_flush[t]));
           iu0_sent_d[t][i][2] = iu0_sent_l2[t][i + 1][1] & (~(iu2_flush[t]));
         end
         iu0_sent_d[t][(`IBUFF_DEPTH/4) - 1][1] = 1'b0;
         iu0_sent_d[t][(`IBUFF_DEPTH/4) - 1][2] = 1'b0;
       end

       else if (shift2_sent_reduce[t] == 1'b1)		// shift 2
       begin
         for (i = 0; i < ((`IBUFF_DEPTH/4) - 1); i = i + 1)
         begin
           // swap with current last position & shift down one
           if (any_sent[t][0] == 1'b1)
             iu0_sent_d[t][i][0] = set_sent[t] & iu0_sent_l2[t][i + 1][0];
           else if (any_sent[t][1] == 1'b1)
             iu0_sent_d[t][i][0] = set_sent[t] & iu0_sent_l2[t][i + 1][1];
           else
             iu0_sent_d[t][i][0] = set_sent[t] & iu0_sent_l2[t][i + 1][2];
         end
         iu0_sent_d[t][(`IBUFF_DEPTH/4) - 1][0] = 1'b0;

         // shift down
         for (i = 0; i < ((`IBUFF_DEPTH/4) - 2); i = i + 1)
         begin
           iu0_sent_d[t][i][1] = iu0_sent_l2[t][i + 2][0] & (~(iu1_flush[t]));
           iu0_sent_d[t][i][2] = iu0_sent_l2[t][i + 2][1] & (~(iu2_flush[t]));
         end
         iu0_sent_d[t][(`IBUFF_DEPTH/4) - 1][1] = 1'b0;
         iu0_sent_d[t][(`IBUFF_DEPTH/4) - 1][2] = 1'b0;

         iu0_sent_d[t][(`IBUFF_DEPTH/4) - 2][1] = 1'b0;
         iu0_sent_d[t][(`IBUFF_DEPTH/4) - 2][2] = 1'b0;
       end

       else
       begin
         // no shifting
         for (i = 0; i < `IBUFF_DEPTH/4; i = i + 1)
         begin
           iu0_sent_d[t][i][0] = set_sent[t] & next_fetch[t][i];
                      //(next_fetch(i) and not(hold_thread) and not(iu0_flush)) or
                      //(next_load(i) and not (iu0_flush));
           iu0_sent_d[t][i][1] = iu0_sent_l2[t][i][0] & (~(iu1_flush[t]));
           iu0_sent_d[t][i][2] = iu0_sent_l2[t][i][1] & (~(iu2_flush[t]));
         end
       end
     end  // t loop
   end

   assign thread_ready = need_fetch_reduce & (~hold_thread);

  `ifdef THREADS1             //(`THREADS == 1)
      assign iu0_tid[0] = thread_ready[0];
  `endif
  `ifndef THREADS1            //(`THREADS == 2)
      assign iu0_tid[0] = thread_ready[0] & ((iu0_last_tid_sent_l2 == 1'b1) | ((~thread_ready[1])));
      assign iu0_tid[1] = thread_ready[1] & ((iu0_last_tid_sent_l2 == 1'b0) | ((~thread_ready[0])));
  `endif

   assign iu0_last_tid_sent_d = (iu0_valid == 1'b1) ? iu0_tid[`THREADS - 1] :
                                                      iu0_last_tid_sent_l2;

   // We drop hold thread on the last beat of data, so there's 1 cycle where we might have sent the next ifar
   assign iu1_ecc_flush = {`THREADS{icd_ics_iu1_valid}} & icd_ics_iu1_tid & icm_ics_iu3_ecc_fp_cancel;

   always @ (*)
   begin: iu0_ifar_proc
      (* analysis_not_referenced="true" *)
      integer  i;

      iu0_2ucode_d = iu0_2ucode_l2;
      iu0_2ucode_type_d = iu0_2ucode_type_l2;

      for (i = 0; i < `THREADS; i = i + 1)
      begin
         iu0_ifar_temp[i] = iu0_ifar_l2[i];

         if ((cp_flush_l2[i] == 1'b1) & (cp_flush_into_uc_l2[i] == 1'b0))
         begin
            iu0_ifar_temp[i] = cp_flush_ifar_l2[i];
            iu0_2ucode_d[i] = cp_flush_2ucode_l2[i] & (~pc_iu_ram_active[i]);
            iu0_2ucode_type_d[i] = cp_flush_2ucode_type_l2[i] & (~pc_iu_ram_active[i]);
         end
         else if ((cp_flush_l2[i] == 1'b1) & (cp_flush_into_uc_l2[i] == 1'b1))
         begin
            iu0_ifar_temp[i] = cp_flush_ifar_l2[i] + 1;
            iu0_2ucode_d[i] = 1'b0;
            iu0_2ucode_type_d[i] = 1'b0;
         end
         else if (br_iu_redirect_l2[i] == 1'b1)
         begin
            iu0_ifar_temp[i] = br_iu_bta_l2;
            iu0_2ucode_d[i] = 1'b0;
            iu0_2ucode_type_d[i] = 1'b0;
         end
         else if (uc_iu4_flush[i] == 1'b1)
         begin
            iu0_ifar_temp[i] = {iu0_ifar_l2[i][62-`EFF_IFAR_ARCH:62-`EFF_IFAR_WIDTH-1], uc_iu4_flush_ifar[i]};
            iu0_2ucode_d[i] = 1'b0;
            iu0_2ucode_type_d[i] = 1'b0;
         end
         else if (bp_ic_iu4_redirect[i] == 1'b1)
         begin
            iu0_ifar_temp[i] = {iu0_ifar_l2[i][62-`EFF_IFAR_ARCH:62-`EFF_IFAR_WIDTH-1], bp_ic_redirect_ifar[i]};
            iu0_2ucode_d[i] = 1'b0;
            iu0_2ucode_type_d[i] = 1'b0;
         end
         else if (icd_ics_iu3_parity_flush[i] == 1'b1 | (icd_ics_iu3_miss_flush[i] & icm_ics_iu3_miss_match))
         begin
            iu0_ifar_temp[i] = {iu0_ifar_l2[i][62-`EFF_IFAR_ARCH:62-`EFF_IFAR_WIDTH-1], icd_ics_iu3_ifar};
            iu0_2ucode_d[i] = icd_ics_iu3_2ucode;
            iu0_2ucode_type_d[i] = icd_ics_iu3_2ucode_type;
         end
         else if (icd_ics_iu3_miss_flush[i] == 1'b1)		// and not icm_ics_iu2_miss_match
         begin
            iu0_ifar_temp[i] = {iu0_ifar_l2[i][62-`EFF_IFAR_ARCH:62-`EFF_IFAR_WIDTH-1], (icd_ics_iu3_ifar[62-`EFF_IFAR_WIDTH:59] + value_1[34-`EFF_IFAR_WIDTH:31]), 2'b00};
            iu0_2ucode_d[i] = 1'b0;
            iu0_2ucode_type_d[i] = 1'b0;
         end
         else if ((bp_ic_iu3_redirect[i] == 1'b1) & (icm_ics_iu3_ecc_fp_cancel[i] == 1'b0))
         begin
            iu0_ifar_temp[i] = {iu0_ifar_l2[i][62-`EFF_IFAR_ARCH:62-`EFF_IFAR_WIDTH-1], bp_ic_redirect_ifar[i]};
            iu0_2ucode_d[i] = 1'b0;
            iu0_2ucode_type_d[i] = 1'b0;
         end
         // for ierat flush, only update ifar if iu2_valid (i.e. not iu2_prefetch)
         else if ((((ierat_iu_iu2_flush_req[i] | icd_ics_iu2_cam_etc_flush[i]) & icd_ics_iu2_valid) |
                   icd_ics_iu2_wrong_ra_flush[i]) == 1'b1)
         begin
            iu0_ifar_temp[i] = {iu0_ifar_l2[i][62-`EFF_IFAR_ARCH:62-`EFF_IFAR_WIDTH-1], icd_ics_iu2_ifar_eff};
            iu0_2ucode_d[i] = icd_ics_iu2_2ucode;
            iu0_2ucode_type_d[i] = icd_ics_iu2_2ucode_type;
         end
         else if ((bp_ic_iu2_redirect[i] == 1'b1) & (icm_ics_iu3_ecc_fp_cancel[i] == 1'b0))
         begin
            iu0_ifar_temp[i] = {iu0_ifar_l2[i][62-`EFF_IFAR_ARCH:62-`EFF_IFAR_WIDTH-1], bp_ic_redirect_ifar[i]};
            iu0_2ucode_d[i] = 1'b0;
            iu0_2ucode_type_d[i] = 1'b0;
         end
         else if(iu1_ecc_flush[i] == 1'b1)
         begin
	   iu0_ifar_temp[i] = {iu0_ifar_l2[i][62-`EFF_IFAR_ARCH:62-`EFF_IFAR_WIDTH-1], icd_ics_iu1_ifar};
           iu0_2ucode_d[i] = icd_ics_iu1_2ucode;
           iu0_2ucode_type_d[i] = icd_ics_iu1_2ucode_type;
         end
         else if (iu0_tid[i] == 1'b1)
         begin
            iu0_ifar_temp[i] = {iu0_ifar_l2[i][62-`EFF_IFAR_ARCH:62-`EFF_IFAR_WIDTH-1], (iu0_ifar_l2[i][62-`EFF_IFAR_WIDTH:59] + value_1[34-`EFF_IFAR_WIDTH:31]), 2'b00};
            iu0_2ucode_d[i] = 1'b0;
            iu0_2ucode_type_d[i] = 1'b0;
         end
      end
   end   // iu0_ifar_proc

   generate
   begin : xhdl4
     genvar  t;
     for (t = 0; t < `THREADS; t = t + 1)
     begin : thread_iu0_ifar_mask
       genvar  i;
       for (i = (62 - `EFF_IFAR_ARCH); i < 62; i = i + 1)
       begin : iu0_ifar0_mask
         if (i < 32)
         begin
           assign iu0_ifar_d[t][i] = (xu_iu_msr_cm[t] & iu0_ifar_temp[t][i]);
         end
         if (i >= 32)
         begin
           assign iu0_ifar_d[t][i] = iu0_ifar_temp[t][i];
         end
       end
     end
   end
   endgenerate

   assign toggle_flip = icd_ics_iu2_wrong_ra_flush & (~ierat_iu_iu2_flush_req) & (~iu3_flush);
   assign iu0_flip_index51_d = (  toggle_flip  & (~iu0_flip_index51_l2)) |
                               ((~toggle_flip) &   iu0_flip_index51_l2);

   //---------------------------------------------------------------------
   // Stored ERAT
   //---------------------------------------------------------------------
   // Keep 42:51 to compare, and flush if cp or br flush

   generate
   begin : xhdl5
     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : stored_erat_gen
       assign stored_erat_act[i] = iu0_read_erat[i] & (~spr_ic_ierat_byp_dis);
       assign stored_erat_ifar_d[i] = iu0_ifar[62-`EFF_IFAR_WIDTH:51];

       assign iu0_cross_4k_fetch[i] = (iu0_ifar_l2[i][62-`EFF_IFAR_WIDTH:51] != stored_erat_ifar_l2[i]);
       assign iu0_cross_4k_prefetch[i] = (iu0_prefetch_ifar_l2[i][62-`EFF_IFAR_WIDTH:51] != stored_erat_ifar_l2[i]);

       assign iu0_cross_4k[i] = (iu0_tid[i] & iu0_cross_4k_fetch[i]) |
                                (next_prefetch[i] & iu0_cross_4k_prefetch[i]);

       assign iu0_read_erat[i] = (iu0_erat_valid & iu0_erat_tid[i]) &
           ((~stored_erat_valid_l2[i]) | iu0_need_new_erat[i] | next_fetch_nonspec_l2[i] | spr_ic_ierat_byp_dis);

       // This is a subset of clear_erat_valid that does not include any of the flush terms
       // (because we would be dropping fetch anyways if it is flushed).  For timing & helps power.
       assign iu0_need_new_erat[i] = (iu0_cross_4k[i] & (~bp_ic_iu4_redirect[i])) |
                           ierat_iu_cam_change | icd_ics_iu2_read_erat_error[i];

       assign clear_erat_valid[i] = cp_flush_l2[i] | br_iu_redirect_l2[i] | (iu0_cross_4k[i] & (~bp_ic_iu4_redirect[i])) |       // Might be on new page
           ierat_iu_cam_change | icd_ics_iu2_read_erat_error[i] |
           (icd_ics_iu2_valid & ierat_iu_iu2_flush_req[i]) |
           (icd_ics_iu1_read_erat[i] & iu1_flush[i]);		// not going to be stored

       assign stored_erat_valid_d[i] = (~spr_ic_ierat_byp_dis) &
               ((iu0_read_erat[i] & (~iu0_flush[i])) | (stored_erat_valid_l2[i] & (~clear_erat_valid[i])));
     end
   end
   endgenerate

   assign ics_icd_iu0_read_erat = |(iu0_read_erat);

   //---------------------------------------------------------------------
   // Outputs
   //---------------------------------------------------------------------
   // ???? Do I want to split up threaded/non-threaded signals?
   generate
   begin : xhdl6
     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : hold_t
       assign hold_thread[i] = (~xu_iu_run_thread_l2[i] & ~next_fetch_nonspec_l2[i]) | cp_ic_stop_l2[i] | pc_iu_pm_fetch_halt_l2[i] | mm_hold_req_l2[i] | mm_bus_snoop_hold_req_l2[i] |
                               ierat_hold_l2[i] | back_inv_l2 | icm_ics_hold_iu0 | spr_idir_read_l2 | uc_ic_hold[i] | icm_ics_hold_thread[i];

       // Everything except icm_ics_hold_iu0
       assign hold_thread_perf_lite[i] = (~xu_iu_run_thread_l2[i] & ~next_fetch_nonspec_l2[i]) | cp_ic_stop_l2[i] | pc_iu_pm_fetch_halt_l2[i] | mm_hold_req_l2[i] | mm_bus_snoop_hold_req_l2[i] |
                               ierat_hold_l2[i] | back_inv_l2 | spr_idir_read_l2 | uc_ic_hold[i] | icm_ics_hold_thread[i];

       assign hold_prefetch[i] = (~xu_iu_run_thread_l2[i]) | cp_ic_stop_l2[i] | pc_iu_pm_fetch_halt_l2[i] | mm_hold_req_l2[i] | mm_bus_snoop_hold_req_l2[i]  |
                               ierat_hold_l2[i] | back_inv_l2 | icm_ics_hold_iu0 | spr_idir_read_l2 | (|(need_fetch_reduce & (~hold_thread)));
     end

     //genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : gen_need_fetch_reduce
       assign need_fetch_reduce[i] = |(need_fetch[i]);
     end
   end
   endgenerate

   assign iu0_erat_valid = |(need_fetch_reduce & (~hold_thread)) | (|(prefetch_ready));
   assign iu0_erat_tid = iu0_tid | next_prefetch;
   assign iu_ierat_iu0_val = |(iu0_read_erat);
   assign iu_ierat_iu0_thdid = iu0_erat_tid;
   assign iu_ierat_iu0_prefetch = |(prefetch_ready) & (~(|(need_fetch_reduce & (~hold_thread))));

   generate
   begin : xhdl8
     genvar  i;
     for (i = 0; i < 52; i = i + 1)
     begin : ierat_ifar
       if (i < 62 - `EFF_IFAR_ARCH)
         assign iu_ierat_iu0_ifar[i] = 1'b0;
       if (i >= 62 - `EFF_IFAR_ARCH)
         assign iu_ierat_iu0_ifar[i] = iu0_ifar[i];
     end
   end
   endgenerate

   assign next_fetch_nonspec_d = (~cp_flush) &
       (cp_flush_nonspec_l2 | (next_fetch_nonspec_l2 & (~iu0_tid)) |
        ({`THREADS{icd_ics_iu2_valid}} & ierat_iu_iu2_flush_req & iu2_nonspec_l2));
   assign iu_ierat_iu0_nonspec = |(next_fetch_nonspec_l2 & iu0_tid);

   assign iu1_nonspec_d = {`THREADS{iu0_erat_valid}} & iu0_erat_tid & next_fetch_nonspec_l2 & (~cp_flush);
   assign iu2_nonspec_d = iu1_nonspec_l2 & (~cp_flush);

   // Tell CP if nonspec hit in ierat
   assign ic_cp_nonspec_hit = iu2_nonspec_l2 & ~{`THREADS{ierat_iu_iu2_miss}} &
      ~cp_flush_l2 & ~({`THREADS{icd_ics_iu2_valid}} & ierat_iu_iu2_flush_req & iu2_nonspec_l2);

   assign iu_ierat_flush = cp_flush_l2 | uc_iu4_flush | icd_ics_iu3_miss_flush | ({`THREADS{icd_ics_iu2_valid}} & icd_ics_iu2_cam_etc_flush) |
       icd_ics_iu2_wrong_ra_flush | icd_ics_iu3_parity_flush | (bp_ic_iu2_redirect & (~icm_ics_iu3_ecc_fp_cancel)) | (bp_ic_iu3_redirect & (~icm_ics_iu3_ecc_fp_cancel)) | bp_ic_iu4_redirect | br_iu_redirect_l2 | iu1_ecc_flush;
   assign ics_icm_iu2_flush = cp_flush_l2 | uc_iu4_flush | icd_ics_iu3_parity_flush |
      (bp_ic_iu3_redirect & (~icm_ics_iu3_ecc_fp_cancel) & (~icd_ics_iu3_miss_flush)) | bp_ic_iu4_redirect | br_iu_redirect_l2;
   assign ics_icd_iu1_flush = cp_flush_l2 | uc_iu4_flush | ({`THREADS{icd_ics_iu2_valid}} & (ierat_iu_iu2_flush_req | icd_ics_iu2_cam_etc_flush)) |
       icd_ics_iu3_miss_flush | icd_ics_iu2_wrong_ra_flush | icd_ics_iu3_parity_flush | (bp_ic_iu2_redirect & (~icm_ics_iu3_ecc_fp_cancel)) | (bp_ic_iu3_redirect & (~icm_ics_iu3_ecc_fp_cancel)) | bp_ic_iu4_redirect | br_iu_redirect_l2 | iu1_ecc_flush;
   assign ics_icd_iu2_flush = cp_flush_l2 | uc_iu4_flush | ierat_iu_iu2_flush_req | icd_ics_iu2_cam_etc_flush | icd_ics_iu3_miss_flush | icd_ics_iu2_wrong_ra_flush | (bp_ic_iu3_redirect & (~icm_ics_iu3_ecc_fp_cancel)) | icd_ics_iu3_parity_flush | bp_ic_iu4_redirect | br_iu_redirect_l2;

   assign ic_bp_iu2_flush = ierat_iu_iu2_flush_req | icd_ics_iu2_cam_etc_flush | icd_ics_iu2_wrong_ra_flush;

   assign iu0_flush = cp_flush_l2 | uc_iu4_flush | ({`THREADS{icd_ics_iu2_valid}} & (ierat_iu_iu2_flush_req | icd_ics_iu2_cam_etc_flush)) |
       icd_ics_iu3_miss_flush | icd_ics_iu2_wrong_ra_flush | icd_ics_iu3_parity_flush | (bp_ic_iu2_redirect & (~icm_ics_iu3_ecc_fp_cancel)) | (bp_ic_iu3_redirect & (~icm_ics_iu3_ecc_fp_cancel)) | bp_ic_iu4_redirect | br_iu_redirect_l2 | iu1_ecc_flush;

   assign iu1_flush = cp_flush_l2 | uc_iu4_flush | ierat_iu_iu2_flush_req | ({`THREADS{icd_ics_iu2_valid}} & icd_ics_iu2_cam_etc_flush) |
       icd_ics_iu3_miss_flush | icd_ics_iu2_wrong_ra_flush | icd_ics_iu3_parity_flush | (bp_ic_iu2_redirect & (~icm_ics_iu3_ecc_fp_cancel)) | (bp_ic_iu3_redirect & (~icm_ics_iu3_ecc_fp_cancel)) | bp_ic_iu4_redirect | br_iu_redirect_l2 | iu1_ecc_flush;

   assign iu2_flush = cp_flush_l2 | uc_iu4_flush | ierat_iu_iu2_flush_req | ({`THREADS{icd_ics_iu2_valid}} & icd_ics_iu2_cam_etc_flush) |
       icd_ics_iu3_miss_flush | icd_ics_iu2_wrong_ra_flush | icd_ics_iu3_parity_flush | (bp_ic_iu3_redirect & (~icm_ics_iu3_ecc_fp_cancel)) | bp_ic_iu4_redirect | br_iu_redirect_l2;

	 assign iu3_flush = cp_flush_l2 | uc_iu4_flush | icd_ics_iu3_parity_flush | bp_ic_iu4_redirect | br_iu_redirect_l2 |
	     (icd_ics_iu3_miss_flush & {`THREADS{icm_ics_iu3_miss_match}});   // used by toggle_flip.  If miss matches, will use old page; if miss hits, next address should be the same that caused wrong_ra, so want to flip for new page

   assign ics_icm_iu0_t0_ifar = iu0_ifar_l2[0][46:52];
  `ifndef THREADS1
     assign ics_icm_iu0_t1_ifar = iu0_ifar_l2[1][46:52];
  `endif

   assign ics_icd_dir_rd_act = |(need_fetch_reduce & (~(hold_thread))) | back_inv_l2 | (spr_idir_read_l2 & ~icm_ics_hold_iu0) | (|(prefetch_ready));
   assign data_rd_act[0] = (iu0_tid[0] & (~(iu0_ifar_l2[0][51] ^ iu0_flip_index51_l2[0]))) | (iu0_tid[`THREADS - 1] & (~(iu0_ifar_l2[`THREADS - 1][51] ^ iu0_flip_index51_l2[`THREADS - 1])));
   assign data_rd_act[1] = (iu0_tid[0] & (iu0_ifar_l2[0][51] ^ iu0_flip_index51_l2[0])) | (iu0_tid[`THREADS - 1] & (iu0_ifar_l2[`THREADS - 1][51] ^ iu0_flip_index51_l2[`THREADS - 1]));
   assign ics_icd_data_rd_act = data_rd_act;

   assign iu0_valid = |(iu0_tid & (~iu0_flush));
   assign ics_icd_iu0_valid = iu0_valid;
   assign ics_icd_iu0_tid = iu0_tid | next_prefetch;

   generate
   begin
     if (`THREADS == 1)
     begin : gen_bp_iu0_val_t0
       assign ic_bp_iu0_val[0] = iu0_tid[0] | icm_ics_iu0_preload_val[0];
     end

     if (`THREADS == 2)
     begin : gen_bp_iu0_val
       assign ic_bp_iu0_val[0] = (iu0_tid[0] & (~icm_ics_iu0_preload_val[`THREADS - 1])) | icm_ics_iu0_preload_val[0];
       assign ic_bp_iu0_val[`THREADS - 1] = (iu0_tid[`THREADS - 1] & (~icm_ics_iu0_preload_val[0])) | icm_ics_iu0_preload_val[`THREADS - 1];
     end
   end
   endgenerate

   assign ic_bp_iu0_ifar = (|(icm_ics_iu0_preload_val) == 1'b1) ? icm_ics_iu0_preload_ifar[50:59] :
                           (iu0_tid[0] == 1'b1)                 ? iu0_ifar_l2[0][50:59] :
                                                                  iu0_ifar_l2[`THREADS - 1][50:59];

   generate
   begin
     if (`EFF_IFAR_ARCH > (`REAL_IFAR_WIDTH-2))
     begin : iu0_ifar_gen0

       assign iu0_ifar = ({`EFF_IFAR_ARCH{(~(back_inv_l2 | spr_idir_read_l2)) & iu0_tid[0]}} & iu0_ifar_l2[0]) |
                         ({`EFF_IFAR_ARCH{(~(back_inv_l2 | spr_idir_read_l2)) & iu0_tid[`THREADS-1]}} & iu0_ifar_l2[`THREADS-1]) |	  // should be duplicate if 1 thread
                         ({ {(`EFF_IFAR_ARCH - `REAL_IFAR_WIDTH + 2){1'b0}}, ({(`REAL_IFAR_WIDTH-6){(back_inv_l2 & (~|(back_inv_icbi_l2)))}} & an_ac_back_inv_addr_l2), 4'b0000 }) |
                         ({ {(`EFF_IFAR_ARCH - `REAL_IFAR_WIDTH + 2){1'b0}}, ({(`REAL_IFAR_WIDTH-6){back_inv_icbi_l2[0]}} & lq_iu_icbi_addr_l2[0]), 4'b0000 }) |   // back_inv_l2 includes back_inv_icbi_l2, was redundant
                         ({ {(`EFF_IFAR_ARCH - `REAL_IFAR_WIDTH + 2){1'b0}}, ({(`REAL_IFAR_WIDTH-6){back_inv_icbi_l2[`THREADS - 1]}} & lq_iu_icbi_addr_l2[`THREADS - 1]), 4'b0000}) |
                         ({ {(`EFF_IFAR_ARCH - 11){1'b0}}, ({7{(~(back_inv_l2)) & spr_idir_read_l2}} & spr_idir_row_l2), 4'b0000}) |
                         ({ ({(`EFF_IFAR_ARCH-4){next_prefetch[0]}} & {iu0_ifar_l2[0][62-`EFF_IFAR_ARCH:62-`EFF_IFAR_WIDTH-1], iu0_prefetch_ifar_l2[0]}), 4'b0000}) |
                         ({ ({(`EFF_IFAR_ARCH-4){next_prefetch[`THREADS - 1]}} & {iu0_ifar_l2[`THREADS-1][62-`EFF_IFAR_ARCH:62-`EFF_IFAR_WIDTH-1], iu0_prefetch_ifar_l2[`THREADS-1]}), 4'b0000});
     end

     if (`EFF_IFAR_ARCH <= (`REAL_IFAR_WIDTH-2))
     begin : iu0_ifar_gen1
       assign iu0_ifar = ({`EFF_IFAR_ARCH{(~(back_inv_l2 | spr_idir_read_l2)) & iu0_tid[0]}} & iu0_ifar_l2[0]) |
                         ({`EFF_IFAR_ARCH{(~(back_inv_l2 | spr_idir_read_l2)) & iu0_tid[`THREADS-1]}} & iu0_ifar_l2[`THREADS-1]) |
                         ({ ({`EFF_IFAR_ARCH-4{back_inv_l2 & (~|(back_inv_icbi_l2))}} & an_ac_back_inv_addr_l2[62-`EFF_IFAR_ARCH:57]), 4'b0000}) |
                         ({ ({`EFF_IFAR_ARCH-4{back_inv_icbi_l2[0]}} & lq_iu_icbi_addr_l2[0][62-`EFF_IFAR_ARCH:57]), 4'b0000}) |		// back_inv_l2 includes back_inv_icbi_l2, was redundant
                         ({ ({`EFF_IFAR_ARCH-4{back_inv_icbi_l2[`THREADS-1]}} & lq_iu_icbi_addr_l2[`THREADS-1][62-`EFF_IFAR_ARCH:57]), 4'b0000}) |
                         ({ {(`EFF_IFAR_ARCH - 11){1'b0}}, ({7{(~(back_inv_l2)) & spr_idir_read_l2}} & spr_idir_row_l2), 4'b0000}) |
                         ({ ({(`EFF_IFAR_ARCH-4){next_prefetch[0]}} & {iu0_ifar_l2[0][62-`EFF_IFAR_ARCH:62-`EFF_IFAR_WIDTH-1], iu0_prefetch_ifar_l2[0]}), 4'b0000}) |
                         ({ ({(`EFF_IFAR_ARCH-4){next_prefetch[`THREADS-1]}} & {iu0_ifar_l2[`THREADS-1][62-`EFF_IFAR_ARCH:62-`EFF_IFAR_WIDTH-1], iu0_prefetch_ifar_l2[`THREADS-1]}), 4'b0000});
     end
   end
   endgenerate

   assign ics_icd_iu0_ifar = iu0_ifar;
   assign ics_icd_iu0_index51 = ( ((~(back_inv_l2 | spr_idir_read_l2)) & iu0_tid[0]) & (iu0_ifar_l2[0][51] ^ iu0_flip_index51_l2[0])) |
                                ( ((~(back_inv_l2 | spr_idir_read_l2)) & iu0_tid[`THREADS - 1]) & (iu0_ifar_l2[`THREADS - 1][51] ^ iu0_flip_index51_l2[`THREADS - 1])) |	// should be duplicate if `THREADS=1
                                ( (back_inv_l2 & (~|(back_inv_icbi_l2))) & an_ac_back_inv_addr_l2[51]) |
                                ( back_inv_icbi_l2[0] & lq_iu_icbi_addr_l2[0][51]) |   // back_inv_l2 includes back_inv_icbi_l2, was redundant
                                ( back_inv_icbi_l2[`THREADS - 1] & lq_iu_icbi_addr_l2[`THREADS - 1][51]) |
                                ( ((~(back_inv_l2)) & spr_idir_read_l2) & spr_idir_row_l2[51]) |
                                ( next_prefetch[0] & (iu0_prefetch_ifar_l2[0][51] ^ iu0_flip_index51_l2[0])) |
                                ( next_prefetch[`THREADS - 1] & (iu0_prefetch_ifar_l2[`THREADS - 1][51] ^ iu0_flip_index51_l2[`THREADS - 1]));

   assign ics_icd_iu0_2ucode = |(iu0_2ucode_l2 & iu0_tid);
   assign ics_icd_iu0_2ucode_type = |(iu0_2ucode_type_l2 & iu0_tid);

   assign ics_icd_iu0_inval = back_inv_l2;
   assign ics_icm_iu0_inval = back_inv_l2;

   assign ics_icm_iu0_inval_addr = ( {7{back_inv_l2 & (~|(back_inv_icbi_l2))}} & an_ac_back_inv_addr_l2[51:57]) |
                                   ( {7{back_inv_icbi_l2[0]}}                  & lq_iu_icbi_addr_l2[0][51:57]) |
                                   ( {7{back_inv_icbi_l2[`THREADS - 1]}}       & lq_iu_icbi_addr_l2[`THREADS - 1][51:57]);

   // Block prefetch if new prefetch req on this thread
   assign ics_icd_iu0_prefetch = |(send_prefetch & ~(icm_ics_prefetch_req & ~{`THREADS{prefetch_wrap}}));

   //---------------------------------------------------------------------
   // Performance Events
   //---------------------------------------------------------------------

   generate
   begin : xhdl9
     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : perf
       // Reload Collisions - Blocked by reload writing into the cache
       assign perf_event_d[i][3] = icm_ics_hold_iu0 & need_fetch_reduce[i] & ~hold_thread_perf_lite[i];

       // IU0 Redirected - any flush condition
       assign perf_event_d[i][4] = iu0_flush[i];

       // Various flushes: BP iu2, BP iu3, BP iu4, uc
       assign perf_event_d[i][5] = bp_ic_iu2_redirect[i] & ~icm_ics_iu3_ecc_fp_cancel[i];
       assign perf_event_d[i][6] = bp_ic_iu3_redirect[i] & ~icm_ics_iu3_ecc_fp_cancel[i];
       assign perf_event_d[i][7] = bp_ic_iu4_redirect[i];
       assign perf_event_d[i][8] = uc_iu4_flush[i];
     end
   end
   endgenerate

   assign ic_perf_t0_event = perf_event_l2[0];
 `ifndef THREADS1
     assign ic_perf_t1_event = perf_event_l2[1];
 `endif

   //---------------------------------------------------------------------
   // Latches
   //---------------------------------------------------------------------

   tri_rlmlatch_p #(.INIT(0)) an_ac_back_inv_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[an_ac_back_inv_offset]),
      .scout(sov[an_ac_back_inv_offset]),
      .din(an_ac_back_inv_d),
      .dout(an_ac_back_inv_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) an_ac_back_inv_target_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[an_ac_back_inv_target_offset]),
      .scout(sov[an_ac_back_inv_target_offset]),
      .din(an_ac_back_inv_target_d),
      .dout(an_ac_back_inv_target_l2)
   );

   tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH-6), .INIT(0)) an_ac_back_inv_addr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(back_inv_addr_act),		//back_inv_d,
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[an_ac_back_inv_addr_offset:an_ac_back_inv_addr_offset + (`REAL_IFAR_WIDTH-6) - 1]),
      .scout(sov[an_ac_back_inv_addr_offset:an_ac_back_inv_addr_offset + (`REAL_IFAR_WIDTH-6) - 1]),
      .din(an_ac_back_inv_addr_d),
      .dout(an_ac_back_inv_addr_l2)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_idir_read_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[spr_idir_read_offset]),
      .scout(sov[spr_idir_read_offset]),
      .din(spr_idir_read_d),
      .dout(spr_idir_read_l2)
   );

   tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(0)) spr_idir_row_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[spr_idir_row_offset:spr_idir_row_offset + 7 - 1]),
      .scout(sov[spr_idir_row_offset:spr_idir_row_offset + 7 - 1]),
      .din(spr_idir_row_d),
      .dout(spr_idir_row_l2)
   );

   generate
   begin
     if (`THREADS == 1)
     begin : gen_oldest_t1
        assign oldest_prefetch_l2 = oldest_prefetch_d & 1'b0;
     end

     if (`THREADS > 1)
     begin : gen_oldest_t2
       tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) oldest_prefetch_latch(
          .vd(vdd),
          .gd(gnd),
          .nclk(nclk),
          .act(tiup),
          .thold_b(pc_iu_func_sl_thold_0_b),
          .sg(pc_iu_sg_0),
          .force_t(force_t),
          .delay_lclkr(delay_lclkr),
          .mpw1_b(mpw1_b),
          .mpw2_b(mpw2_b),
          .d_mode(d_mode),
          .scin(siv[oldest_prefetch_offset]),
          .scout(sov[oldest_prefetch_offset]),
          .din(oldest_prefetch_d),
          .dout(oldest_prefetch_l2)
       );
     end
   end
   endgenerate

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu0_need_prefetch_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu0_need_prefetch_offset:iu0_need_prefetch_offset + `THREADS - 1]),
      .scout(sov[iu0_need_prefetch_offset:iu0_need_prefetch_offset + `THREADS - 1]),
      .din(iu0_need_prefetch_d),
      .dout(iu0_need_prefetch_l2)
   );

   generate
   begin : xhdl10
     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : t
       tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH-4), .INIT(0)) iu0_prefetch_ifar_latch(
          .vd(vdd),
          .gd(gnd),
          .nclk(nclk),
          .act(iu0_prefetch_ifar_act[i]),
          .thold_b(pc_iu_func_sl_thold_0_b),
          .sg(pc_iu_sg_0),
          .force_t(force_t),
          .delay_lclkr(delay_lclkr),
          .mpw1_b(mpw1_b),
          .mpw2_b(mpw2_b),
          .d_mode(d_mode),
          .scin(siv[iu0_prefetch_ifar_offset + i * (`EFF_IFAR_WIDTH-4):iu0_prefetch_ifar_offset + ((i + 1) * (`EFF_IFAR_WIDTH-4)) - 1]),
          .scout(sov[iu0_prefetch_ifar_offset + i * (`EFF_IFAR_WIDTH-4):iu0_prefetch_ifar_offset + ((i + 1) * (`EFF_IFAR_WIDTH-4)) - 1]),
          .din(iu0_prefetch_ifar_d[i]),
          .dout(iu0_prefetch_ifar_l2[i])
       );
     end
   end
   endgenerate

   tri_rlmreg_p #(.WIDTH((`THREADS*`THREADS-1+1)), .INIT(0)) lq_iu_icbi_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[lq_iu_icbi_val_offset:lq_iu_icbi_val_offset + (`THREADS*`THREADS-1+1) - 1]),
      .scout(sov[lq_iu_icbi_val_offset:lq_iu_icbi_val_offset + (`THREADS*`THREADS-1+1) - 1]),
      .din(lq_iu_icbi_val_d),
      .dout(lq_iu_icbi_val_l2)
   );

   generate
   begin : xhdl11
     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : t
       tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH-6), .INIT(0)) lq_iu_icbi_addr_latch(
          .vd(vdd),
          .gd(gnd),
          .nclk(nclk),
          .act(lq_iu_icbi_val[i]),
          .thold_b(pc_iu_func_sl_thold_0_b),
          .sg(pc_iu_sg_0),
          .force_t(force_t),
          .delay_lclkr(delay_lclkr),
          .mpw1_b(mpw1_b),
          .mpw2_b(mpw2_b),
          .d_mode(d_mode),
          .scin(siv[lq_iu_icbi_addr_offset + i * (`REAL_IFAR_WIDTH-6):lq_iu_icbi_addr_offset + ((i + 1) * (`REAL_IFAR_WIDTH-6)) - 1]),
          .scout(sov[lq_iu_icbi_addr_offset + i * (`REAL_IFAR_WIDTH-6):lq_iu_icbi_addr_offset + ((i + 1) * (`REAL_IFAR_WIDTH-6)) - 1]),
          .din(lq_iu_icbi_addr_d[i]),
          .dout(lq_iu_icbi_addr_l2[i])
       );
     end
   end
   endgenerate

   tri_rlmlatch_p #(.INIT(0)) back_inv_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[back_inv_offset]),
      .scout(sov[back_inv_offset]),
      .din(back_inv_d),
      .dout(back_inv_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) back_inv_icbi_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[back_inv_icbi_offset:back_inv_icbi_offset + `THREADS - 1]),
      .scout(sov[back_inv_icbi_offset:back_inv_icbi_offset + `THREADS - 1]),
      .din(back_inv_icbi_d),
      .dout(back_inv_icbi_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) xu_iu_run_thread_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[xu_iu_run_thread_offset:xu_iu_run_thread_offset + `THREADS - 1]),
      .scout(sov[xu_iu_run_thread_offset:xu_iu_run_thread_offset + `THREADS - 1]),
      .din(xu_iu_run_thread_d),
      .dout(xu_iu_run_thread_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) xu_iu_msr_cm_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[xu_iu_msr_cm_offset:xu_iu_msr_cm_offset + `THREADS - 1]),
      .scout(sov[xu_iu_msr_cm_offset:xu_iu_msr_cm_offset + `THREADS - 1]),
      .din(xu_iu_msr_cm_d),
      .dout(xu_iu_msr_cm_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) xu_iu_msr_cm2_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[xu_iu_msr_cm2_offset:xu_iu_msr_cm2_offset + `THREADS - 1]),
      .scout(sov[xu_iu_msr_cm2_offset:xu_iu_msr_cm2_offset + `THREADS - 1]),
      .din(xu_iu_msr_cm2_d),
      .dout(xu_iu_msr_cm2_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) xu_iu_msr_cm3_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[xu_iu_msr_cm3_offset:xu_iu_msr_cm3_offset + `THREADS - 1]),
      .scout(sov[xu_iu_msr_cm3_offset:xu_iu_msr_cm3_offset + `THREADS - 1]),
      .din(xu_iu_msr_cm3_d),
      .dout(xu_iu_msr_cm3_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) cp_ic_stop_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[cp_ic_stop_offset:cp_ic_stop_offset + `THREADS - 1]),
      .scout(sov[cp_ic_stop_offset:cp_ic_stop_offset + `THREADS - 1]),
      .din(cp_ic_stop_d),
      .dout(cp_ic_stop_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) pc_iu_pm_fetch_halt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[pc_iu_pm_fetch_halt_offset:pc_iu_pm_fetch_halt_offset + `THREADS - 1]),
      .scout(sov[pc_iu_pm_fetch_halt_offset:pc_iu_pm_fetch_halt_offset + `THREADS - 1]),
      .din(pc_iu_pm_fetch_halt_d),
      .dout(pc_iu_pm_fetch_halt_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ierat_hold_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[ierat_hold_offset:ierat_hold_offset + `THREADS - 1]),
      .scout(sov[ierat_hold_offset:ierat_hold_offset + `THREADS - 1]),
      .din(ierat_hold_d),
      .dout(ierat_hold_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu0_2ucode_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu0_2ucode_offset:iu0_2ucode_offset + `THREADS - 1]),
      .scout(sov[iu0_2ucode_offset:iu0_2ucode_offset + `THREADS - 1]),
      .din(iu0_2ucode_d),
      .dout(iu0_2ucode_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu0_2ucode_type_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu0_2ucode_type_offset:iu0_2ucode_type_offset + `THREADS - 1]),
      .scout(sov[iu0_2ucode_type_offset:iu0_2ucode_type_offset + `THREADS - 1]),
      .din(iu0_2ucode_type_d),
      .dout(iu0_2ucode_type_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu0_flip_index51_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu0_flip_index51_offset:iu0_flip_index51_offset + `THREADS - 1]),
      .scout(sov[iu0_flip_index51_offset:iu0_flip_index51_offset + `THREADS - 1]),
      .din(iu0_flip_index51_d),
      .dout(iu0_flip_index51_l2)
   );

   generate
   begin
     if (`THREADS == 1)
     begin : gen_last_tid_t1
        assign iu0_last_tid_sent_l2 = 1'b0 & iu0_last_tid_sent_d;
     end

     if (`THREADS > 1)
     begin : gen_last_tid_t2
       tri_rlmlatch_p #(.INIT(0)) iu0_last_tid_sent_latch(
          .vd(vdd),
          .gd(gnd),
          .nclk(nclk),
          .act(tiup),
          .thold_b(pc_iu_func_sl_thold_0_b),
          .sg(pc_iu_sg_0),
          .force_t(force_t),
          .delay_lclkr(delay_lclkr),
          .mpw1_b(mpw1_b),
          .mpw2_b(mpw2_b),
          .d_mode(d_mode),
          .scin(siv[iu0_last_tid_sent_offset]),
          .scout(sov[iu0_last_tid_sent_offset]),
          .din(iu0_last_tid_sent_d),
          .dout(iu0_last_tid_sent_l2)
       );
     end
   end
   endgenerate

   generate
   begin : xhdl13
     genvar  t;
     for (t = 0; t < `THREADS; t = t + 1)
     begin : th
       genvar  i;
       for (i = 0; i < `IBUFF_DEPTH/4; i = i + 1)
       begin : ibuff
         tri_rlmreg_p #(.WIDTH(3), .INIT(0)) iu0_sent_latch(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(tiup),
            .thold_b(pc_iu_func_sl_thold_0_b),
            .sg(pc_iu_sg_0),
            .force_t(force_t),
            .delay_lclkr(delay_lclkr),
            .mpw1_b(mpw1_b),
            .mpw2_b(mpw2_b),
            .d_mode(d_mode),
            .scin(siv[iu0_sent_offset + (t * (`IBUFF_DEPTH/4) + i) * 3:iu0_sent_offset + (t * (`IBUFF_DEPTH/4) + i + 1) * 3 - 1]),
            .scout(sov[iu0_sent_offset + (t * (`IBUFF_DEPTH/4) + i) * 3:iu0_sent_offset + (t * (`IBUFF_DEPTH/4) + i + 1) * 3 - 1]),
            .din(iu0_sent_d[t][i]),
            .dout(iu0_sent_l2[t][i])
         );
       end
     end
   end
   endgenerate

   // IU0
   generate
   begin : xhdl14
     genvar  t;
     for (t = 0; t < `THREADS; t = t + 1)
     begin : th
       genvar  i;
       for (i = 0; i < `EFF_IFAR_ARCH; i = i + 1)
       begin : q_gen
         if((62-`EFF_IFAR_ARCH+i) > 31)
           tri_rlmlatch_p #(.INIT(1), .NEEDS_SRESET(1)) iu0_ifar_latch(
              .vd(vdd),
              .gd(gnd),
              .nclk(nclk),
              .act(tiup),
              .thold_b(pc_iu_func_slp_sl_thold_0_b),
              .sg(pc_iu_sg_0),
              .force_t(funcslp_force),
              .delay_lclkr(delay_lclkr),
              .mpw1_b(mpw1_b),
              .mpw2_b(mpw2_b),
              .d_mode(d_mode),
              .scin(siv[iu0_ifar_offset + t * `EFF_IFAR_ARCH + i]),
              .scout(sov[iu0_ifar_offset + t * `EFF_IFAR_ARCH + i]),
              .din(iu0_ifar_d[t][62 - `EFF_IFAR_ARCH + i]),
              .dout(iu0_ifar_l2[t][62 - `EFF_IFAR_ARCH + i])
           );
         else
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu0_ifar_latch(
              .vd(vdd),
              .gd(gnd),
              .nclk(nclk),
              .act(tiup),
              .thold_b(pc_iu_func_slp_sl_thold_0_b),
              .sg(pc_iu_sg_0),
              .force_t(funcslp_force),
              .delay_lclkr(delay_lclkr),
              .mpw1_b(mpw1_b),
              .mpw2_b(mpw2_b),
              .d_mode(d_mode),
              .scin(siv[iu0_ifar_offset + t * `EFF_IFAR_ARCH + i]),
              .scout(sov[iu0_ifar_offset + t * `EFF_IFAR_ARCH + i]),
              .din(iu0_ifar_d[t][62 - `EFF_IFAR_ARCH + i]),
              .dout(iu0_ifar_l2[t][62 - `EFF_IFAR_ARCH + i])
           );
       end
     end
   end
   endgenerate

   generate
   begin : xhdl15
     if (`INCLUDE_IERAT_BYPASS == 0)
     begin : gen0
       genvar  i;
       for (i = 0; i < `THREADS; i = i + 1)
       begin : t
         assign stored_erat_ifar_l2[i] = gate_and(1'b0, stored_erat_ifar_d[i]);		// ..._d part is to get rid of unused warnings
         assign stored_erat_valid_l2[i] = gate_and(1'b0, stored_erat_valid_d[i]);		// '0'
       end

       assign sov[stored_erat_ifar_offset:stored_erat_valid_offset + `THREADS - 1] = siv[stored_erat_ifar_offset:stored_erat_valid_offset + `THREADS - 1];
     end

     if (`INCLUDE_IERAT_BYPASS == 1)
     begin : gen1
       genvar  i;
       for (i = 0; i < `THREADS; i = i + 1)
       begin : t
         tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH-10), .INIT(0)) stored_erat_ifar_latch(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(stored_erat_act[i]),
            .thold_b(pc_iu_func_sl_thold_0_b),
            .sg(pc_iu_sg_0),
            .force_t(force_t),
            .delay_lclkr(delay_lclkr),
            .mpw1_b(mpw1_b),
            .mpw2_b(mpw2_b),
            .d_mode(d_mode),
            .scin(siv[stored_erat_ifar_offset + i * (`EFF_IFAR_WIDTH-10):stored_erat_ifar_offset + ((i + 1) * (`EFF_IFAR_WIDTH-10)) - 1]),
            .scout(sov[stored_erat_ifar_offset + i * (`EFF_IFAR_WIDTH-10):stored_erat_ifar_offset + ((i + 1) * (`EFF_IFAR_WIDTH-10)) - 1]),
            .din(stored_erat_ifar_d[i]),
            .dout(stored_erat_ifar_l2[i])
         );
       end
     end

     tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) stored_erat_valid_latch(
        .vd(vdd),
        .gd(gnd),
        .nclk(nclk),
        .act(tiup),
        .thold_b(pc_iu_func_slp_sl_thold_0_b),
        .sg(pc_iu_sg_0),
        .force_t(funcslp_force),
        .delay_lclkr(delay_lclkr),
        .mpw1_b(mpw1_b),
        .mpw2_b(mpw2_b),
        .d_mode(d_mode),
        .scin(siv[stored_erat_valid_offset:stored_erat_valid_offset + `THREADS - 1]),
        .scout(sov[stored_erat_valid_offset:stored_erat_valid_offset + `THREADS - 1]),
        .din(stored_erat_valid_d),
        .dout(stored_erat_valid_l2)
      );
   end
   endgenerate

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) mm_hold_req_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[mm_hold_req_offset:mm_hold_req_offset + `THREADS - 1]),
      .scout(sov[mm_hold_req_offset:mm_hold_req_offset + `THREADS - 1]),
      .din(mm_hold_req_d),
      .dout(mm_hold_req_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) mm_bus_snoop_hold_req_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[mm_bus_snoop_hold_req_offset:mm_bus_snoop_hold_req_offset + `THREADS - 1]),
      .scout(sov[mm_bus_snoop_hold_req_offset:mm_bus_snoop_hold_req_offset + `THREADS - 1]),
      .din(mm_bus_snoop_hold_req_d),
      .dout(mm_bus_snoop_hold_req_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) cp_flush_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
      .scout(sov[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
      .din(cp_flush),
      .dout(cp_flush_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) cp_flush_into_uc_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[cp_flush_into_uc_offset:cp_flush_into_uc_offset + `THREADS - 1]),
      .scout(sov[cp_flush_into_uc_offset:cp_flush_into_uc_offset + `THREADS - 1]),
      .din(cp_flush_into_uc),
      .dout(cp_flush_into_uc_l2)
    );

   generate
   begin : xhdl17
      genvar  i;
      for (i = 0; i < `THREADS; i = i + 1)
      begin : t
        tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0)) cp_flush_ifar_latch(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(tiup),
           .thold_b(pc_iu_func_slp_sl_thold_0_b),
           .sg(pc_iu_sg_0),
           .force_t(funcslp_force),
           .delay_lclkr(delay_lclkr),
           .mpw1_b(mpw1_b),
           .mpw2_b(mpw2_b),
           .d_mode(d_mode),
           .scin(siv[cp_flush_ifar_offset + i * `EFF_IFAR_ARCH:cp_flush_ifar_offset + (i + 1) * `EFF_IFAR_ARCH - 1]),
           .scout(sov[cp_flush_ifar_offset + i * `EFF_IFAR_ARCH:cp_flush_ifar_offset + (i + 1) * `EFF_IFAR_ARCH - 1]),
           .din(cp_flush_ifar_d[i]),
           .dout(cp_flush_ifar_l2[i])
        );
     end
   end
   endgenerate

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) cp_flush_2ucode_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[cp_flush_2ucode_offset:cp_flush_2ucode_offset + `THREADS - 1]),
      .scout(sov[cp_flush_2ucode_offset:cp_flush_2ucode_offset + `THREADS - 1]),
      .din(cp_iu0_flush_2ucode),
      .dout(cp_flush_2ucode_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) cp_flush_2ucode_type_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[cp_flush_2ucode_type_offset:cp_flush_2ucode_type_offset + `THREADS - 1]),
      .scout(sov[cp_flush_2ucode_type_offset:cp_flush_2ucode_type_offset + `THREADS - 1]),
      .din(cp_iu0_flush_2ucode_type),
      .dout(cp_flush_2ucode_type_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) cp_flush_nonspec_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[cp_flush_nonspec_offset:cp_flush_nonspec_offset + `THREADS - 1]),
      .scout(sov[cp_flush_nonspec_offset:cp_flush_nonspec_offset + `THREADS - 1]),
      .din(cp_iu0_flush_nonspec),
      .dout(cp_flush_nonspec_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) br_iu_redirect_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[br_iu_redirect_offset:br_iu_redirect_offset + `THREADS - 1]),
      .scout(sov[br_iu_redirect_offset:br_iu_redirect_offset + `THREADS - 1]),
      .din(br_iu_redirect_d),
      .dout(br_iu_redirect_l2)
   );

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0)) br_iu_bta_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[br_iu_bta_offset:br_iu_bta_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[br_iu_bta_offset:br_iu_bta_offset + `EFF_IFAR_ARCH - 1]),
      .din(br_iu_bta),
      .dout(br_iu_bta_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) next_fetch_nonspec_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[next_fetch_nonspec_offset:next_fetch_nonspec_offset + `THREADS - 1]),
      .scout(sov[next_fetch_nonspec_offset:next_fetch_nonspec_offset + `THREADS - 1]),
      .din(next_fetch_nonspec_d),
      .dout(next_fetch_nonspec_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu1_nonspec_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu1_nonspec_offset:iu1_nonspec_offset + `THREADS - 1]),
      .scout(sov[iu1_nonspec_offset:iu1_nonspec_offset + `THREADS - 1]),
      .din(iu1_nonspec_d),
      .dout(iu1_nonspec_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu2_nonspec_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu2_nonspec_offset:iu2_nonspec_offset + `THREADS - 1]),
      .scout(sov[iu2_nonspec_offset:iu2_nonspec_offset + `THREADS - 1]),
      .din(iu2_nonspec_d),
      .dout(iu2_nonspec_l2)
   );

   generate
   begin : xhdl18
      genvar  i;
      for (i = 0; i < `THREADS; i = i + 1)
      begin : t
        tri_rlmreg_p #(.WIDTH(6), .INIT(0)) perf_event_latch(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(event_bus_enable),
           .thold_b(pc_iu_func_sl_thold_0_b),
           .sg(pc_iu_sg_0),
           .force_t(force_t),
           .delay_lclkr(delay_lclkr),
           .mpw1_b(mpw1_b),
           .mpw2_b(mpw2_b),
           .d_mode(d_mode),
           .scin(siv[perf_event_offset + i * 6:perf_event_offset + (i + 1) * 6 - 1]),
           .scout(sov[perf_event_offset + i * 6:perf_event_offset + (i + 1) * 6 - 1]),
           .din(perf_event_d[i]),
           .dout(perf_event_l2[i])
        );
     end
   end
   endgenerate

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv[0:scan_right] = {sov[1:scan_right], func_scan_in};
   assign func_scan_out = sov[0];

endmodule
