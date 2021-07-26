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
//* TITLE:
//*
//* NAME: iuq_ic_dir.v
//*
//*********************************************************************

`include "tri_a2o.vh"

module iuq_ic_dir(
   inout                          vcs,
   inout                          vdd,
   inout                          gnd,
    (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]        nclk,
   input                          pc_iu_func_sl_thold_0_b,
   input                          pc_iu_func_slp_sl_thold_0_b,
   input                          pc_iu_time_sl_thold_0,
   input                          pc_iu_repr_sl_thold_0,
   input                          pc_iu_abst_sl_thold_0,
   input                          pc_iu_abst_sl_thold_0_b,
   input                          pc_iu_abst_slp_sl_thold_0,
   input                          pc_iu_ary_nsl_thold_0,
   input                          pc_iu_ary_slp_nsl_thold_0,
   input                          pc_iu_bolt_sl_thold_0,
   input                          pc_iu_sg_0,
   input                          pc_iu_sg_1,
   input                          force_t,
   input                          funcslp_force,
   input                          abst_force,

   input                          d_mode,
   input                          delay_lclkr,
   input                          mpw1_b,
   input                          mpw2_b,
   input                          clkoff_b,
   input                          act_dis,

   input                          g8t_clkoff_b,
   input                          g8t_d_mode,
   input [0:4]                    g8t_delay_lclkr,
   input [0:4]                    g8t_mpw1_b,
   input                          g8t_mpw2_b,

   input                          g6t_clkoff_b,
   input                          g6t_act_dis,
   input                          g6t_d_mode,
   input [0:3]                    g6t_delay_lclkr,
   input [0:4]                    g6t_mpw1_b,
   input                          g6t_mpw2_b,

   input                          tc_ac_ccflush_dc,
   input                          tc_ac_scan_dis_dc_b,
   input                          tc_ac_scan_diag_dc,
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                          func_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                          time_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                          repr_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:2]                    abst_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                         func_scan_out,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                         time_scan_out,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                         repr_scan_out,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:2]                   abst_scan_out,

   input                          spr_ic_cls,		// (0): 64B cacheline, (1): 128B cacheline
   input                          spr_ic_ierat_byp_dis,

   input [0:1]                    spr_ic_idir_way,
   output                         ic_spr_idir_done,
   output [0:2]                   ic_spr_idir_lru,
   output [0:3]                   ic_spr_idir_parity,
   output                         ic_spr_idir_endian,
   output                         ic_spr_idir_valid,
   output [0:28]                  ic_spr_idir_tag,

   output [9:11]                  ic_perf_t0_event,
 `ifndef THREADS1
   output [9:11]                  ic_perf_t1_event,
 `endif
   output [0:1]                   ic_perf_event,

   output                         iu_pc_err_icache_parity,
   output                         iu_pc_err_icachedir_parity,
   output                         iu_pc_err_icachedir_multihit,

   input                          pc_iu_inj_icache_parity,
   input                          pc_iu_inj_icachedir_parity,
   input                          pc_iu_inj_icachedir_multihit,

   input                          pc_iu_abist_g8t_wenb,
   input                          pc_iu_abist_g8t1p_renb_0,
   input [0:3]                    pc_iu_abist_di_0,
   input                          pc_iu_abist_g8t_bw_1,
   input                          pc_iu_abist_g8t_bw_0,
   input [3:9]                    pc_iu_abist_waddr_0,
   input [1:9]                    pc_iu_abist_raddr_0,
   input                          pc_iu_abist_ena_dc,
   input                          pc_iu_abist_wl128_comp_ena,
   input                          pc_iu_abist_raw_dc_b,
   input [0:3]                    pc_iu_abist_g8t_dcomp,
   input [0:1]                    pc_iu_abist_g6t_bw,
   input [0:3]                    pc_iu_abist_di_g6t_2r,
   input                          pc_iu_abist_wl512_comp_ena,
   input [0:3]                    pc_iu_abist_dcomp_g6t_2r,
   input                          pc_iu_abist_g6t_r_wb,
   input                          an_ac_lbist_ary_wrt_thru_dc,

   input                          pc_iu_bo_enable_2,		// bolt-on ABIST
   input                          pc_iu_bo_reset,
   input                          pc_iu_bo_unload,
   input                          pc_iu_bo_repair,
   input                          pc_iu_bo_shdata,
   input [0:3]                    pc_iu_bo_select,
   output [0:3]                   iu_pc_bo_fail,
   output [0:3]                   iu_pc_bo_diagout,

   output [0:51]                  iu_mm_ierat_epn,

   output                         iu_ierat_iu1_back_inv,

   input [64-`REAL_IFAR_WIDTH:51] ierat_iu_iu2_rpn,
   input [0:4]                    ierat_iu_iu2_wimge,
   input [0:3]                    ierat_iu_iu2_u,
   input [0:2]                    ierat_iu_iu2_error,
   input                          ierat_iu_iu2_miss,
   input                          ierat_iu_iu2_multihit,
   input                          ierat_iu_iu2_isi,
   input [0:`THREADS-1]           ierat_iu_iu2_flush_req,
   input                          ierat_iu_cam_change,

   // Cache invalidate
   input                          lq_iu_ici_val,

   // IU IC Select
   input                          ics_icd_dir_rd_act,
   input [0:1]                    ics_icd_data_rd_act,
   input                          ics_icd_iu0_valid,
   input [0:`THREADS-1]           ics_icd_iu0_tid,
   input [62-`EFF_IFAR_ARCH:61]   ics_icd_iu0_ifar,
   input                          ics_icd_iu0_index51,
   input                          ics_icd_iu0_inval,
   input                          ics_icd_iu0_2ucode,
   input                          ics_icd_iu0_2ucode_type,
   input                          ics_icd_iu0_prefetch,
   input                          ics_icd_iu0_read_erat,
   input                          ics_icd_iu0_spr_idir_read,

   input [0:`THREADS-1]           ics_icd_iu1_flush,
   input [0:`THREADS-1]           ics_icd_iu2_flush,
   output                         icd_ics_iu1_valid,
   output [0:`THREADS-1]          icd_ics_iu1_tid,
   output [62-`EFF_IFAR_WIDTH:61] icd_ics_iu1_ifar,
   output                         icd_ics_iu1_2ucode,
   output                         icd_ics_iu1_2ucode_type,
   output [0:`THREADS-1]          icd_ics_iu1_read_erat,
   output [0:`THREADS-1]          icd_ics_iu2_wrong_ra_flush,
   output [0:`THREADS-1]          icd_ics_iu2_cam_etc_flush,
   output [62-`EFF_IFAR_WIDTH:61] icd_ics_iu2_ifar_eff,
   output                         icd_ics_iu2_2ucode,
   output                         icd_ics_iu2_2ucode_type,
   output                         icd_ics_iu2_valid,
   output [0:`THREADS-1]          icd_ics_iu2_read_erat_error,
   output [0:`THREADS-1]          icd_ics_iu3_miss_flush,
   output [0:`THREADS-1]          icd_ics_iu3_parity_flush,
   output [62-`EFF_IFAR_WIDTH:61] icd_ics_iu3_ifar,
   output                         icd_ics_iu3_2ucode,
   output                         icd_ics_iu3_2ucode_type,

   // IU IC Miss
   input [51:57]                  icm_icd_lru_addr,
   input                          icm_icd_dir_inval,
   input                          icm_icd_dir_val,
   input                          icm_icd_data_write,
   input [51:59]                  icm_icd_reload_addr,
   input [0:143]                  icm_icd_reload_data,
   input [0:3]                    icm_icd_reload_way,
   input [0:`THREADS-1]           icm_icd_load,
   input [62-`EFF_IFAR_WIDTH:61]  icm_icd_load_addr,
   input                          icm_icd_load_2ucode,
   input                          icm_icd_load_2ucode_type,
   input                          icm_icd_dir_write,
   input [64-`REAL_IFAR_WIDTH:57] icm_icd_dir_write_addr,
   input                          icm_icd_dir_write_endian,
   input [0:3]                    icm_icd_dir_write_way,
   input                          icm_icd_lru_write,
   input [51:57]                  icm_icd_lru_write_addr,
   input [0:3]                    icm_icd_lru_write_way,
   input                          icm_icd_ecc_inval,
   input [51:57]                  icm_icd_ecc_addr,
   input [0:3]                    icm_icd_ecc_way,
   input                          icm_icd_iu3_ecc_fp_cancel,
   input                          icm_icd_any_reld_r2,

   output                         icd_icm_miss,
   output                         icd_icm_prefetch,
   output [0:`THREADS-1]          icd_icm_tid,
   output [64-`REAL_IFAR_WIDTH:61] icd_icm_addr_real,
   output [62-`EFF_IFAR_WIDTH:51]  icd_icm_addr_eff,
   output [0:4]                   icd_icm_wimge,		// (1): CI
   output [0:3]                   icd_icm_userdef,
   output                         icd_icm_2ucode,
   output                         icd_icm_2ucode_type,
   output                         icd_icm_iu2_inval,
   output                         icd_icm_any_iu2_valid,

   output [0:2]                   icd_icm_row_lru,
   output [0:3]                   icd_icm_row_val,

   //Branch Predict
   // iu3
   output [0:3]                   ic_bp_iu2_t0_val,
 `ifndef THREADS1
     output [0:3]                   ic_bp_iu2_t1_val,
 `endif
   output [62-`EFF_IFAR_WIDTH:61] ic_bp_iu2_ifar,
   output                         ic_bp_iu2_2ucode,
   output                         ic_bp_iu2_2ucode_type,
   output [0:2]                   ic_bp_iu2_error,
   output [0:`THREADS-1]          ic_bp_iu3_flush,

   // iu3 instruction(0:31) + predecode(32:35)
   output [0:35]                  ic_bp_iu2_0_instr,
   output [0:35]                  ic_bp_iu2_1_instr,
   output [0:35]                  ic_bp_iu2_2_instr,
   output [0:35]                  ic_bp_iu2_3_instr,

   input                          event_bus_enable
);

   parameter                      ways = 4;
   parameter                      dir_way_width = 34;
   parameter                      dir_ext_bits = 8 - ((52 - (64 - `REAL_IFAR_WIDTH)) % 8);
   parameter                      dir_parity_width = (52 - (64 - `REAL_IFAR_WIDTH) + dir_ext_bits)/8;


   parameter                      iu1_valid_offset = 0;
   parameter                      iu1_tid_offset = iu1_valid_offset + 1;
   parameter                      iu1_ifar_offset = iu1_tid_offset + `THREADS;
   parameter                      iu1_index51_offset = iu1_ifar_offset + `EFF_IFAR_ARCH;
   parameter                      iu1_inval_offset = iu1_index51_offset + 1;
   parameter                      iu1_prefetch_offset = iu1_inval_offset + 1;
   parameter                      iu1_read_erat_offset = iu1_prefetch_offset + 1;
   parameter                      iu1_2ucode_offset = iu1_read_erat_offset + 1;
   parameter                      iu1_2ucode_type_offset = iu1_2ucode_offset + 1;
   parameter                      iu2_valid_offset = iu1_2ucode_type_offset + 1;
   parameter                      iu2_tid_offset = iu2_valid_offset + 1;
   parameter                      iu2_ifar_eff_offset = iu2_tid_offset + `THREADS;
   parameter                      iu2_index51_offset = iu2_ifar_eff_offset + `EFF_IFAR_ARCH;
   parameter                      iu2_2ucode_offset = iu2_index51_offset + 1;
   parameter                      iu2_2ucode_type_offset = iu2_2ucode_offset + 1;
   parameter                      iu2_inval_offset = iu2_2ucode_type_offset + 1;
   parameter                      iu2_prefetch_offset = iu2_inval_offset + 1;
   parameter                      iu2_read_erat_offset = iu2_prefetch_offset + 1;
   parameter                      iu2_cam_change_etc_offset = iu2_read_erat_offset + 1;
   parameter                      iu2_stored_rpn_offset = iu2_cam_change_etc_offset + 1;
   parameter                      iu2_dir_rd_val_offset = iu2_stored_rpn_offset + `REAL_IFAR_WIDTH-12;
   parameter                      iu2_dir_dataout_offset = iu2_dir_rd_val_offset + 4;
   parameter                      iu3_dir_parity_err_way_offset = iu2_dir_dataout_offset + 1;  //handled in tri
   parameter                      iu2_data_dataout_offset = iu3_dir_parity_err_way_offset + 4;
   parameter                      dir_val_offset = iu2_data_dataout_offset + 1;	//handled in tri
   parameter                      dir_lru_offset = dir_val_offset + (128 * 4);
   parameter                      iu3_miss_flush_offset = dir_lru_offset + (128 * 3);
   parameter                      iu3_tid_offset = iu3_miss_flush_offset + 1;
   parameter                      iu3_ifar_offset = iu3_tid_offset + `THREADS;
   parameter                      iu3_2ucode_offset = iu3_ifar_offset + `EFF_IFAR_WIDTH;
   parameter                      iu3_2ucode_type_offset = iu3_2ucode_offset + 1;
   parameter                      iu3_erat_err_offset = iu3_2ucode_type_offset + 1;
   parameter                      iu3_multihit_err_way_offset = iu3_erat_err_offset + 1;
   parameter                      iu3_multihit_flush_offset = iu3_multihit_err_way_offset + 4;
   parameter                      iu3_data_parity_err_way_offset = iu3_multihit_flush_offset + 1;
   parameter                      iu3_parity_needs_flush_offset = iu3_data_parity_err_way_offset + 4;
   parameter                      iu3_parity_tag_offset = iu3_parity_needs_flush_offset + 1;
   parameter                      ici_val_offset = iu3_parity_tag_offset + 7;
   parameter                      spr_ic_cls_offset = ici_val_offset + 1;
   parameter                      spr_ic_idir_way_offset = spr_ic_cls_offset + 1;
   parameter                      iu1_spr_idir_read_offset = spr_ic_idir_way_offset + 2;
   parameter                      iu2_spr_idir_read_offset = iu1_spr_idir_read_offset + 1;
   parameter                      iu2_spr_idir_lru_offset = iu2_spr_idir_read_offset + 1;
   parameter                      stored_erat_rpn_offset = iu2_spr_idir_lru_offset + 3;
   parameter                      stored_erat_wimge_offset = stored_erat_rpn_offset + (`REAL_IFAR_WIDTH - 12) * `THREADS;
   parameter                      stored_erat_u_offset = stored_erat_wimge_offset + 5 * `THREADS;
   parameter                      perf_instr_count_offset = stored_erat_u_offset + 4 * `THREADS;
   parameter                      perf_t_event_offset = perf_instr_count_offset + 2 * `THREADS;
   parameter                      perf_event_offset = perf_t_event_offset + 3 * `THREADS;
   parameter                      pc_iu_inj_offset = perf_event_offset + 2;
   parameter                      scan_right = pc_iu_inj_offset + 3 - 1;

   wire                           tidn;
   wire                           tiup;

   // Latch inputs
   // IU1 pipeline
   wire                           iu1_valid_d;
   wire                           iu1_valid_l2;
   wire [0:`THREADS-1]            iu1_tid_d;
   wire [0:`THREADS-1]            iu1_tid_l2;
   wire [62-`EFF_IFAR_ARCH:61]    iu1_ifar_d;
   wire [62-`EFF_IFAR_ARCH:61]    iu1_ifar_l2;
   wire                           iu1_index51_d;
   wire                           iu1_index51_l2;
   wire                           iu1_inval_d;
   wire                           iu1_inval_l2;
   wire                           iu1_prefetch_d;
   wire                           iu1_prefetch_l2;
   wire                           iu1_read_erat_d;
   wire                           iu1_read_erat_l2;
   wire                           iu1_2ucode_d;
   wire                           iu1_2ucode_l2;
   wire                           iu1_2ucode_type_d;
   wire                           iu1_2ucode_type_l2;

   // IU2 pipeline
   wire                           iu2_valid_d;
   wire                           iu2_valid_l2;
   wire [0:`THREADS-1]            iu2_tid_d;
   wire [0:`THREADS-1]            iu2_tid_l2;
   wire [62-`EFF_IFAR_ARCH:61]    iu2_ifar_eff_d;
   wire [62-`EFF_IFAR_ARCH:61]    iu2_ifar_eff_l2;
   wire                           iu2_index51_d;
   wire                           iu2_index51_l2;
   wire                           iu2_2ucode_d;
   wire                           iu2_2ucode_l2;
   wire                           iu2_2ucode_type_d;
   wire                           iu2_2ucode_type_l2;
   wire                           iu2_inval_d;
   wire                           iu2_inval_l2;
   wire                           iu2_prefetch_d;
   wire                           iu2_prefetch_l2;
   wire                           iu2_read_erat_d;
   wire                           iu2_read_erat_l2;
   wire                           iu2_cam_change_etc_d;
   wire                           iu2_cam_change_etc_l2;
   reg  [64-`REAL_IFAR_WIDTH:51]  iu2_stored_rpn_d;
   wire [64-`REAL_IFAR_WIDTH:51]  iu2_stored_rpn_l2;
   wire [0:3]                     iu2_dir_rd_val_d;
   wire [0:3]                     iu2_dir_rd_val_l2;
   wire [0:3]                     iu3_dir_parity_err_way_d;
   wire [0:3]                     iu3_dir_parity_err_way_l2;

   // Dir val & LRU
   wire [0:3]                     dir_val_d[0:127];
   wire [0:3]                     dir_val_l2[0:127];
   wire [0:2]                     dir_lru_d[0:127];
   wire [0:2]                     dir_lru_l2[0:127];

   // IU3 pipeline
   wire                           iu3_miss_flush_d;
   wire                           iu3_miss_flush_l2;
   wire [0:3]                     iu3_instr_valid_d;
   wire [0:`THREADS-1]            iu3_tid_d;
   wire [0:`THREADS-1]            iu3_tid_l2;
   wire [62-`EFF_IFAR_WIDTH:61]   iu3_ifar_d;
   wire [62-`EFF_IFAR_WIDTH:61]   iu3_ifar_l2;		//20
   wire                           iu3_2ucode_d;
   wire                           iu3_2ucode_l2;
   wire                           iu3_2ucode_type_d;
   wire                           iu3_2ucode_type_l2;
   wire [0:2]                     iu3_erat_err_d;
   wire [0:0]                     iu3_erat_err_l2;		// Only latch 1 bit
   wire [0:3]                     iu3_multihit_err_way_d;
   wire [0:3]                     iu3_multihit_err_way_l2;
   wire                           iu3_multihit_flush_d;
   wire                           iu3_multihit_flush_l2;
   wire [0:3]                     iu3_data_parity_err_way_d;
   wire [0:3]                     iu3_data_parity_err_way_l2;
   wire                           iu3_parity_needs_flush_d;
   wire                           iu3_parity_needs_flush_l2;
   wire [51:57]                   iu3_parity_tag_d;
   wire [51:57]                   iu3_parity_tag_l2;

   // ICI
   wire                           ici_val_d;
   wire                           ici_val_l2;

   wire                           spr_ic_cls_d;
   wire                           spr_ic_cls_l2;
   wire [0:1]                     spr_ic_idir_way_d;
   wire [0:1]                     spr_ic_idir_way_l2;
   wire                           iu1_spr_idir_read_d;
   wire                           iu1_spr_idir_read_l2;
   wire                           iu2_spr_idir_read_d;
   wire                           iu2_spr_idir_read_l2;
   wire [0:2]                     iu2_spr_idir_lru_d;
   wire [0:2]                     iu2_spr_idir_lru_l2;

   // IERAT Storing
   wire [64-`REAL_IFAR_WIDTH:51]  stored_erat_rpn_d[0:`THREADS-1];
   wire [64-`REAL_IFAR_WIDTH:51]  stored_erat_rpn_l2[0:`THREADS-1];
   wire [0:4]                     stored_erat_wimge_d[0:`THREADS-1];
   wire [0:4]                     stored_erat_wimge_l2[0:`THREADS-1];
   wire [0:3]                     stored_erat_u_d[0:`THREADS-1];
   wire [0:3]                     stored_erat_u_l2[0:`THREADS-1];

   wire [0:1]                     perf_instr_count_d[0:`THREADS-1];
   wire [0:1]                     perf_instr_count_l2[0:`THREADS-1];
   wire [9:11]                    perf_t_event_d[0:`THREADS-1];
   wire [9:11]                    perf_t_event_l2[0:`THREADS-1];
   wire [0:1]                     perf_event_d;
   wire [0:1]                     perf_event_l2;
   wire                           pc_iu_inj_icache_parity_l2;
   wire                           pc_iu_inj_icachedir_parity_l2;
   wire                           pc_iu_inj_icachedir_multihit_l2;

   // Stored IERAT
   wire                           iu2_valid_erat_read;
   wire [0:`THREADS-1]            stored_erat_act;
   wire                           iu1_stored_erat_updating;
   reg [0:4]                      iu2_stored_wimge;
   reg [0:3]                      iu2_stored_u;
   wire [64-`REAL_IFAR_WIDTH:51]  iu2_rpn;
   wire [0:4]                     iu2_wimge;
   wire [0:3]                     iu2_u;
   wire [0:2]                     iu2_ierat_error;

   wire                           iu2_ci;
   wire                           iu2_endian;

   // IDIR
   wire                           dir_rd_act;
   wire                           dir_write;
   wire [0:ways-1]                dir_way;
   wire [0:6]                     dir_wr_addr;
   wire [0:6]                     dir_rd_addr;
   wire [0:dir_parity_width*8-1]  ext_dir_datain;
   wire [0:dir_parity_width-1]    dir_parity_in;
   wire [0:dir_way_width-1]       way_datain;
   wire [0:dir_way_width*ways-1]  dir_datain;
   wire [0:dir_way_width*ways-1]  iu2_dir_dataout;
   wire                           dir_dataout_act;

   wire [51:57]                   iu1_ifar_cacheline;
   reg [0:3]                      dir_rd_val;
   reg [0:2]                      iu1_spr_idir_lru;

   // IDATA
   wire [0:1]                     data_read;
   wire                           data_write;
   wire [0:3]                     data_write_act;
   wire [0:ways-1]                data_way;
   wire [0:8]                     data_addr;
   wire [0:17]                    data_parity_in;
   wire [0:161]                   data_datain;
   wire [0:162*ways-1]            data_dataout;
   wire [0:162*ways-1]            iu2_data_dataout;

   // Compare
   wire [0:3]                     iu2_rd_tag_hit;
   wire [0:3]                     iu2_rd_hit;
   wire [0:3]                     iu2_rd_tag_hit_erat;
   wire [0:3]                     iu2_rd_hit_erat;
   wire [0:3]                     iu2_rd_tag_hit_stored;
   wire [0:3]                     iu2_rd_hit_stored;
   wire                           iu2_dir_miss;
   wire                           iu2_wrong_ra;
   wire                           iu2_cam_change_etc_flush;
   wire [51:57]                   iu2_ifar_eff_cacheline;
   wire [51:57]                   reload_cacheline;
   wire [51:57]                   ecc_inval_cacheline;
   wire [51:57]                   lru_write_cacheline;
   wire [0:3]                     iu3_any_parity_err_way;
   wire                           dir_val_act;
   wire                           iu2_erat_err_lite;
   wire                           iu2_lru_rd_update;
   reg [0:2]                      dir_lru_read[0:127];
   reg [0:2]                      dir_lru_write[0:127];
   wire [0:15]                    dir_lru_act;
   // Check multihit
   wire                           iu2_multihit_err;
   wire                           iu3_multihit_err;
   wire                           iu2_pc_inj_icachedir_multihit;

   // Check parity
   wire [0:dir_parity_width*8-1]  ext_dir_dataout[0:3];
   wire [0:dir_parity_width-1]    dir_parity_out[0:3];
   wire [0:dir_parity_width-1]    dir_parity_err_byte[0:3];
   wire [0:dir_parity_width-1]    gen_dir_parity_out[0:3];

   wire [0:3]                     iu2_dir_parity_err_way;
   wire                           iu2_rd_parity_err;
   wire                           iu3_dir_parity_err;

   wire [0:17]                    data_parity_out[0:3];
   wire [0:17]                    data_parity_err_byte[0:3];
   wire [0:17]                    gen_data_parity_out[0:3];

   wire                           data_parity_err;

   // Update Valid Bit
   reg [0:2]                      return_lru;
   reg [0:3]                      return_val;

   // IU2
   wire                           iu2_rd_miss;
   wire                           iu2_valid_or_load;
   wire [0:35]                    iu2_instr0_cache_rot[0:3];	// 4 ways
   wire [0:35]                    iu2_instr1_cache_rot[0:3];
   wire [0:35]                    iu2_instr2_cache_rot[0:3];
   wire [0:35]                    iu2_instr3_cache_rot[0:3];
   wire [0:35]                    iu2_reload_rot[0:3];		// instructions 0-3
   wire [0:35]                    iu2_hit_rot[0:3];
   wire [0:35]                    iu2_instr[0:3];
   wire [0:3]                     iu2_uc_illegal_cache_rot;
   wire                           iu2_uc_illegal_reload;
   wire                           iu2_uc_illegal_cache;
   wire                           iu2_uc_illegal;

   // performance events
   wire [0:2]                     iu2_instr_count;
   wire [0:2]                     perf_instr_count_new[0:`THREADS-1];

   // abist
   wire                           stage_abist_g8t_wenb;
   wire                           stage_abist_g8t1p_renb_0;
   wire [0:3]                     stage_abist_di_0;
   wire                           stage_abist_g8t_bw_1;
   wire                           stage_abist_g8t_bw_0;
   wire [3:9]                     stage_abist_waddr_0;
   wire [1:9]                     stage_abist_raddr_0;
   wire                           stage_abist_wl128_comp_ena;
   wire [0:3]                     stage_abist_g8t_dcomp;
   wire [0:1]                     stage_abist_g6t_bw;
   wire [0:3]                     stage_abist_di_g6t_2r;
   wire                           stage_abist_wl512_comp_ena;
   wire [0:3]                     stage_abist_dcomp_g6t_2r;
   wire                           stage_abist_g6t_r_wb;

   // scan
   wire [0:scan_right]            siv;
   wire [0:scan_right]            sov;
   wire [0:44]                    abst_siv;
   wire [0:44]                    abst_sov;
   wire [0:1]                     time_siv;
   wire [0:1]                     time_sov;
   wire [0:1]                     repr_siv;
   wire [0:1]                     repr_sov;

   assign tidn = 1'b0;
   assign tiup = 1'b1;

   assign spr_ic_cls_d = spr_ic_cls;
   assign spr_ic_idir_way_d = spr_ic_idir_way;

   //---------------------------------------------------------------------
   // IU1 Latches
   //---------------------------------------------------------------------
   assign iu1_valid_d = ics_icd_iu0_valid;
   assign iu1_tid_d = ics_icd_iu0_tid;
   assign iu1_ifar_d = ics_icd_iu0_ifar;
   assign iu1_index51_d = ics_icd_iu0_index51;
   assign iu1_inval_d = ics_icd_iu0_inval;
   assign iu1_2ucode_d = ics_icd_iu0_2ucode;
   assign iu1_2ucode_type_d = ics_icd_iu0_2ucode_type;
   assign iu1_prefetch_d = ics_icd_iu0_prefetch;
   assign iu1_read_erat_d = ics_icd_iu0_read_erat;
   assign iu1_spr_idir_read_d = ics_icd_iu0_spr_idir_read;

   assign iu_ierat_iu1_back_inv = iu1_inval_l2;

   assign icd_ics_iu1_valid = iu1_valid_l2;
   assign icd_ics_iu1_tid = iu1_tid_l2;
   assign icd_ics_iu1_ifar = iu1_ifar_l2[62-`EFF_IFAR_WIDTH:61];
   assign icd_ics_iu1_2ucode = iu1_2ucode_l2;
   assign icd_ics_iu1_2ucode_type = iu1_2ucode_type_l2;

   //---------------------------------------------------------------------
   // Stored IERAT
   //---------------------------------------------------------------------
   // Keep copy of IERAT output so it is not necessary to read IERAT each time, for power savings
   assign iu2_valid_erat_read = (iu2_valid_l2 | iu2_prefetch_l2) & iu2_read_erat_l2;
   assign stored_erat_act = {`THREADS{iu2_valid_erat_read & (~spr_ic_ierat_byp_dis)}} & iu2_tid_l2;
   assign iu1_stored_erat_updating = |(stored_erat_act & iu1_tid_l2);  //'1' if stored erat is updating in IU2 for same thread that is in IU1

   generate
      begin : xhdl1
      genvar  i;
      for (i = 0; i < `THREADS; i = i + 1)
      begin : erat_val_gen
        assign stored_erat_rpn_d[i]   = ierat_iu_iu2_rpn;
        assign stored_erat_wimge_d[i] = ierat_iu_iu2_wimge;
        assign stored_erat_u_d[i]     = ierat_iu_iu2_u;
      end
    end
    endgenerate

   //---------------------------------------------------------------------
   // ERAT Output
   //---------------------------------------------------------------------
   // Need to mux between threads
   // Need to mux between stored & non-stored

   //always @(iu2_tid_l2 or stored_erat_rpn_l2 or stored_erat_wimge_l2 or stored_erat_u_l2)
   always @ (*)
   begin: stored_erat_proc
      reg [64-`REAL_IFAR_WIDTH:51]   iu1_stored_rpn_calc;
      reg [0:4]                      iu2_stored_wimge_calc;
      reg [0:3]                      iu2_stored_u_calc;
      (* analysis_not_referenced="true" *)
      integer                        i;
      iu1_stored_rpn_calc   = {`REAL_IFAR_WIDTH-12{1'b0}};
      iu2_stored_wimge_calc = 5'b0;
      iu2_stored_u_calc     = 4'b0;

      for (i = 0; i < `THREADS; i = i + 1)
      begin
         iu1_stored_rpn_calc   = iu1_stored_rpn_calc   | ({`REAL_IFAR_WIDTH-12{iu1_tid_l2[i]}} & stored_erat_rpn_l2[i]);
         iu2_stored_wimge_calc = iu2_stored_wimge_calc | ({5{iu2_tid_l2[i]}} & stored_erat_wimge_l2[i]);
         iu2_stored_u_calc     = iu2_stored_u_calc     | ({4{iu2_tid_l2[i]}} & stored_erat_u_l2[i]);
      end
      iu2_stored_rpn_d   <= iu1_stored_erat_updating ? ierat_iu_iu2_rpn : iu1_stored_rpn_calc;
      iu2_stored_wimge <= iu2_stored_wimge_calc;
      iu2_stored_u     <= iu2_stored_u_calc;
   end

   assign iu2_rpn = ((iu2_read_erat_l2 | iu2_inval_l2) == 1'b1) ? ierat_iu_iu2_rpn :
                    iu2_stored_rpn_l2;

   assign iu2_rd_tag_hit = ((iu2_read_erat_l2 | iu2_inval_l2) == 1'b1) ? iu2_rd_tag_hit_erat :
                    iu2_rd_tag_hit_stored;

   assign iu2_rd_hit = ((iu2_read_erat_l2 | iu2_inval_l2) == 1'b1) ? iu2_rd_hit_erat :
                    iu2_rd_hit_stored;

   assign iu2_wimge = ((iu2_read_erat_l2 | iu2_inval_l2) == 1'b1) ? ierat_iu_iu2_wimge :
                      iu2_stored_wimge;

   assign iu2_u = ((iu2_read_erat_l2 | iu2_inval_l2) == 1'b1) ? ierat_iu_iu2_u :
                  iu2_stored_u;

   assign iu2_ierat_error = {3{iu2_read_erat_l2}} & ierat_iu_iu2_error;

   assign iu2_ci = iu2_wimge[1];	// Note: Must check iu2_valid everywhere this is used.  Otherwise, set to 0 if iu2_inval_l2
   assign iu2_endian = iu2_wimge[4];

   // Timing: Moved muxing to ierat, since similar mux exists there

   assign iu2_ifar_eff_d = iu1_ifar_l2;
   assign iu2_index51_d = iu1_index51_l2;

   //---------------------------------------------------------------------
   // Access IDIR, Valid, & LRU
   //---------------------------------------------------------------------
   assign dir_rd_act = ics_icd_dir_rd_act;
   assign dir_write = icm_icd_dir_write;
   assign dir_way = icm_icd_dir_write_way;
   assign dir_wr_addr = {icm_icd_dir_write_addr[51:56], (icm_icd_dir_write_addr[57] & (~spr_ic_cls_l2))};		// Use even row for 128B mode
   assign dir_rd_addr = {ics_icd_iu0_index51, ics_icd_iu0_ifar[52:56], (ics_icd_iu0_ifar[57] & (~(spr_ic_cls_l2 & (~ics_icd_iu0_spr_idir_read))))};

   generate
   begin : xhdl2
     genvar  i;
     for (i = 0; i < dir_parity_width*8; i = i + 1)
     begin : calc_ext_dir_data
       if (i < 51 - (64 - `REAL_IFAR_WIDTH))
         assign ext_dir_datain[i] = icm_icd_dir_write_addr[(64 - `REAL_IFAR_WIDTH) + i];
       if (i == 51 - (64 - `REAL_IFAR_WIDTH))
         assign ext_dir_datain[i] = icm_icd_dir_write_endian;
       if (i > 51 - (64 - `REAL_IFAR_WIDTH))
         assign ext_dir_datain[i] = 1'b0;
     end

     //genvar  i;
     for (i = 0; i < dir_parity_width; i = i + 1)
     begin : gen_dir_parity
       assign dir_parity_in[i] = ^(ext_dir_datain[i * 8:i * 8 + 7]);
     end
   end
   endgenerate

   assign way_datain[0:50 - (64 - `REAL_IFAR_WIDTH)] = icm_icd_dir_write_addr[(64 - `REAL_IFAR_WIDTH):50];
   assign way_datain[51 - (64 - `REAL_IFAR_WIDTH)] = icm_icd_dir_write_endian;
   assign way_datain[52 - (64 - `REAL_IFAR_WIDTH):52 - (64 - `REAL_IFAR_WIDTH) + dir_parity_width - 1] = dir_parity_in;
   generate
      if (52 - (64 - `REAL_IFAR_WIDTH) + dir_parity_width < dir_way_width)
         assign way_datain[52 - (64 - `REAL_IFAR_WIDTH) + dir_parity_width:dir_way_width-1] = {dir_way_width-52+64-`REAL_IFAR_WIDTH-dir_parity_width{1'b0}};
   endgenerate

   assign dir_datain = {way_datain, way_datain, way_datain, way_datain};

   // 0:28 - tag, 29 - endianness, 30:33 - parity
   tri_128x34_4w_1r1w  idir(
      .gnd(gnd),
      .vdd(vdd),
      .vcs(vdd),
      .nclk(nclk),
      .rd_act(dir_rd_act),
      .wr_act(dir_write),
      .sg_0(pc_iu_sg_0),
      .abst_sl_thold_0(pc_iu_abst_slp_sl_thold_0),
      .ary_nsl_thold_0(pc_iu_ary_slp_nsl_thold_0),
      .time_sl_thold_0(pc_iu_time_sl_thold_0),
      .repr_sl_thold_0(pc_iu_repr_sl_thold_0),
      .func_sl_thold_0_b(pc_iu_func_slp_sl_thold_0_b),
      .func_force(funcslp_force),
      .clkoff_dc_b(g8t_clkoff_b),
      .ccflush_dc(tc_ac_ccflush_dc),
      .scan_dis_dc_b(tc_ac_scan_dis_dc_b),
      .scan_diag_dc(tc_ac_scan_diag_dc),
      .d_mode_dc(g8t_d_mode),
      .mpw1_dc_b(g8t_mpw1_b),
      .mpw2_dc_b(g8t_mpw2_b),
      .delay_lclkr_dc(g8t_delay_lclkr),
      .wr_abst_act(stage_abist_g8t_wenb),
      .rd0_abst_act(stage_abist_g8t1p_renb_0),
      .abist_di(stage_abist_di_0),
      .abist_bw_odd(stage_abist_g8t_bw_1),
      .abist_bw_even(stage_abist_g8t_bw_0),
      .abist_wr_adr(stage_abist_waddr_0[3:9]),
      .abist_rd0_adr(stage_abist_raddr_0[3:9]),
      .tc_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
      .abist_ena_1(pc_iu_abist_ena_dc),
      .abist_g8t_rd0_comp_ena(stage_abist_wl128_comp_ena),
      .abist_raw_dc_b(pc_iu_abist_raw_dc_b),
      .obs0_abist_cmp(stage_abist_g8t_dcomp),
      .abst_scan_in({abst_siv[0], abst_siv[2]}),
      .time_scan_in(time_siv[0]),
      .repr_scan_in(repr_siv[0]),
      .func_scan_in(siv[iu2_dir_dataout_offset]),
      .abst_scan_out({abst_sov[0], abst_sov[2]}),
      .time_scan_out(time_sov[0]),
      .repr_scan_out(repr_sov[0]),
      .func_scan_out(sov[iu2_dir_dataout_offset]),
      .lcb_bolt_sl_thold_0(pc_iu_bolt_sl_thold_0),
      .pc_bo_enable_2(pc_iu_bo_enable_2),
      .pc_bo_reset(pc_iu_bo_reset),
      .pc_bo_unload(pc_iu_bo_unload),
      .pc_bo_repair(pc_iu_bo_repair),
      .pc_bo_shdata(pc_iu_bo_shdata),
      .pc_bo_select(pc_iu_bo_select[0:1]),
      .bo_pc_failout(iu_pc_bo_fail[0:1]),
      .bo_pc_diagloop(iu_pc_bo_diagout[0:1]),
      .tri_lcb_mpw1_dc_b(mpw1_b),
      .tri_lcb_mpw2_dc_b(mpw2_b),
      .tri_lcb_delay_lclkr_dc(delay_lclkr),
      .tri_lcb_clkoff_dc_b(clkoff_b),
      .tri_lcb_act_dis_dc(act_dis),
      .wr_way(dir_way),
      .wr_addr(dir_wr_addr),
      .data_in(dir_datain),
      .rd_addr(dir_rd_addr),
      .data_out(iu2_dir_dataout)
   );

   assign dir_dataout_act = iu1_valid_l2 | iu1_inval_l2 | iu1_spr_idir_read_l2 | iu1_prefetch_l2;

   // Muxing the val for directory access
   assign iu1_ifar_cacheline = {iu1_index51_l2, iu1_ifar_l2[52:56],
              (iu1_ifar_l2[57] & (~(spr_ic_cls_l2 & (~iu1_spr_idir_read_l2))))};


   //always @(iu1_ifar_cacheline or dir_val_l2)
   always @(*)
   begin: dir_rd_val_proc
      (* analysis_not_referenced="true" *)
      integer  i;
      dir_rd_val <= 4'b0000;
      for (i = 0; i < 128; i = i + 1)
         if (iu1_ifar_cacheline == i)
            dir_rd_val <= dir_val_l2[i];
   end

   assign iu2_dir_rd_val_d = dir_rd_val;

   assign ic_spr_idir_valid = (spr_ic_idir_way_l2 == 2'b00) ? iu2_dir_rd_val_l2[0] :
                              (spr_ic_idir_way_l2 == 2'b01) ? iu2_dir_rd_val_l2[1] :
                              (spr_ic_idir_way_l2 == 2'b10) ? iu2_dir_rd_val_l2[2] :
                                                              iu2_dir_rd_val_l2[3];

   //always @(iu1_index51_l2 or iu1_ifar_l2 or dir_lru_l2)
   always @ (*)
   begin: iu2_spr_idir_lru_proc
      (* analysis_not_referenced="true" *)
      integer  i;
      iu1_spr_idir_lru <= 3'b000;
      for (i = 0; i < 128; i = i + 1)
         if ({iu1_index51_l2, iu1_ifar_l2[52:57]} == i)
            iu1_spr_idir_lru <= dir_lru_l2[i];
   end

   assign iu2_spr_idir_lru_d = {3{iu1_spr_idir_read_l2}} & iu1_spr_idir_lru;	// gate to reduce switching/power

   assign ic_spr_idir_lru = iu2_spr_idir_lru_l2;

   assign ic_spr_idir_tag = (spr_ic_idir_way_l2 == 2'b00) ? iu2_dir_dataout[0:28] :
                            (spr_ic_idir_way_l2 == 2'b01) ? iu2_dir_dataout[    dir_way_width:    dir_way_width + 28] :
                            (spr_ic_idir_way_l2 == 2'b10) ? iu2_dir_dataout[2 * dir_way_width:2 * dir_way_width + 28] :
                                                            iu2_dir_dataout[3 * dir_way_width:3 * dir_way_width + 28];

   assign ic_spr_idir_endian = (spr_ic_idir_way_l2 == 2'b00) ? iu2_dir_dataout[29] :
                               (spr_ic_idir_way_l2 == 2'b01) ? iu2_dir_dataout[    dir_way_width + 29] :
                               (spr_ic_idir_way_l2 == 2'b10) ? iu2_dir_dataout[2 * dir_way_width + 29] :
                                                               iu2_dir_dataout[3 * dir_way_width + 29];

   assign ic_spr_idir_parity = (spr_ic_idir_way_l2 == 2'b00) ? iu2_dir_dataout[30:33] :
                               (spr_ic_idir_way_l2 == 2'b01) ? iu2_dir_dataout[    dir_way_width + 30:2 * dir_way_width - 1] :
                               (spr_ic_idir_way_l2 == 2'b10) ? iu2_dir_dataout[2 * dir_way_width + 30:3 * dir_way_width - 1] :
                                                               iu2_dir_dataout[3 * dir_way_width + 30:4 * dir_way_width - 1];
   assign ic_spr_idir_done = iu2_spr_idir_read_l2;

   //---------------------------------------------------------------------
   // Access IData
   //---------------------------------------------------------------------
   assign data_read = ics_icd_data_rd_act;
   assign data_write = icm_icd_data_write;
   assign data_way = icm_icd_reload_way;		// write

   assign data_addr = (data_write == 1'b1) ? icm_icd_reload_addr[51:59] :
                      {ics_icd_iu0_index51, ics_icd_iu0_ifar[52:59]};

   assign data_write_act[0] = (data_way[0] | data_way[1]) & (~icm_icd_reload_addr[51]);
   assign data_write_act[1] = (data_way[2] | data_way[3]) & (~icm_icd_reload_addr[51]);
   assign data_write_act[2] = (data_way[0] | data_way[1]) &   icm_icd_reload_addr[51];
   assign data_write_act[3] = (data_way[2] | data_way[3]) &   icm_icd_reload_addr[51];

   generate
   begin : xhdl4
     genvar  i;
     for (i = 0; i < 18; i = i + 1)
     begin : gen_data_parity
       assign data_parity_in[i] = ^(icm_icd_reload_data[i * 8:i * 8 + 7]);
     end
   end
   endgenerate

   assign data_datain = {icm_icd_reload_data, data_parity_in};



   tri_512x162_4w_0  idata(
      .gnd(gnd),
      .vdd(vdd),
      .vcs(vdd),
      .nclk(nclk),
      .ccflush_dc(tc_ac_ccflush_dc),
      .lcb_clkoff_dc_b(g6t_clkoff_b),
      .lcb_d_mode_dc(g6t_d_mode),
      .lcb_act_dis_dc(g6t_act_dis),
      .lcb_ary_nsl_thold_0(pc_iu_ary_nsl_thold_0),
      .lcb_sg_1(pc_iu_sg_1),
      .lcb_abst_sl_thold_0(pc_iu_abst_sl_thold_0),
      .lcb_func_sl_thold_0_b(pc_iu_func_sl_thold_0_b),
      .func_force(force_t),
      .scan_diag_dc(tc_ac_scan_diag_dc),
      .scan_dis_dc_b(tc_ac_scan_dis_dc_b),
      .func_scan_in(siv[iu2_data_dataout_offset]),
      .func_scan_out(sov[iu2_data_dataout_offset]),
      .abst_scan_in({abst_siv[1], abst_siv[3]}),
      .abst_scan_out({abst_sov[1], abst_sov[3]}),
      .lcb_delay_lclkr_np_dc(g6t_delay_lclkr[0]),
      .ctrl_lcb_delay_lclkr_np_dc(g6t_delay_lclkr[1]),
      .dibw_lcb_delay_lclkr_np_dc(g6t_delay_lclkr[2]),
      .ctrl_lcb_mpw1_np_dc_b(g6t_mpw1_b[0]),
      .dibw_lcb_mpw1_np_dc_b(g6t_mpw1_b[1]),
      .lcb_mpw1_pp_dc_b(g6t_mpw1_b[2]),
      .lcb_mpw1_2_pp_dc_b(g6t_mpw1_b[3]),
      .aodo_lcb_delay_lclkr_dc(g6t_delay_lclkr[3]),
      .aodo_lcb_mpw1_dc_b(g6t_mpw1_b[4]),
      .aodo_lcb_mpw2_dc_b(g6t_mpw2_b),
      .lcb_time_sg_0(pc_iu_sg_0),
      .lcb_time_sl_thold_0(pc_iu_time_sl_thold_0),
      .time_scan_in(time_siv[1]),
      .time_scan_out(time_sov[1]),
      .bitw_abist(stage_abist_g6t_bw),
      .lcb_repr_sl_thold_0(pc_iu_repr_sl_thold_0),
      .lcb_repr_sg_0(pc_iu_sg_0),
      .repr_scan_in(repr_siv[1]),
      .repr_scan_out(repr_sov[1]),
      .tc_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
      .abist_en_1(pc_iu_abist_ena_dc),
      .din_abist(stage_abist_di_g6t_2r),
      .abist_cmp_en(stage_abist_wl512_comp_ena),
      .abist_raw_b_dc(pc_iu_abist_raw_dc_b),
      .data_cmp_abist(stage_abist_dcomp_g6t_2r),
      .addr_abist(stage_abist_raddr_0[1:9]),
      .r_wb_abist(stage_abist_g6t_r_wb),
      .write_thru_en_dc(tidn),
      .lcb_bolt_sl_thold_0(pc_iu_bolt_sl_thold_0),
      .pc_bo_enable_2(pc_iu_bo_enable_2),
      .pc_bo_reset(pc_iu_bo_reset),
      .pc_bo_unload(pc_iu_bo_unload),
      .pc_bo_repair(pc_iu_bo_repair),
      .pc_bo_shdata(pc_iu_bo_shdata),
      .pc_bo_select(pc_iu_bo_select[2:3]),
      .bo_pc_failout(iu_pc_bo_fail[2:3]),
      .bo_pc_diagloop(iu_pc_bo_diagout[2:3]),
      .tri_lcb_mpw1_dc_b(mpw1_b),
      .tri_lcb_mpw2_dc_b(mpw2_b),
      .tri_lcb_delay_lclkr_dc(delay_lclkr),
      .tri_lcb_clkoff_dc_b(clkoff_b),
      .tri_lcb_act_dis_dc(act_dis),
      .read_act(data_read),
      .write_act(data_write_act),
      .write_enable(data_write),
      .write_way(data_way),
      .addr(data_addr),
      .data_in(data_datain),
      .data_out(data_dataout)
      );

   assign iu2_data_dataout[0] = data_dataout[0] ^ pc_iu_inj_icache_parity_l2;
   assign iu2_data_dataout[1:162*ways-1] = data_dataout[1:162*ways-1];

   //---------------------------------------------------------------------
   // Compare Tag
   //---------------------------------------------------------------------
   generate
   begin : xhdl5
     genvar  i;
     for (i = 0; i < 4; i = i + 1)
     begin : rd_tag_hit0
       assign iu2_rd_tag_hit_erat[i] = ierat_iu_iu2_rpn[(64 - `REAL_IFAR_WIDTH):50] == iu2_dir_dataout[i * dir_way_width:i * dir_way_width + 50 - (64 - `REAL_IFAR_WIDTH)];

       assign iu2_rd_hit_erat[i] = iu2_dir_rd_val_l2[i] & iu2_rd_tag_hit_erat[i] & (ierat_iu_iu2_rpn[51] == iu2_index51_l2) & (iu2_endian == iu2_dir_dataout[i * dir_way_width + 51 - (64 - `REAL_IFAR_WIDTH)]);

       assign iu2_rd_tag_hit_stored[i] = iu2_stored_rpn_l2[(64 - `REAL_IFAR_WIDTH):50] == iu2_dir_dataout[i * dir_way_width:i * dir_way_width + 50 - (64 - `REAL_IFAR_WIDTH)];

       assign iu2_rd_hit_stored[i] = iu2_dir_rd_val_l2[i] & iu2_rd_tag_hit_stored[i] & (iu2_stored_rpn_l2[51] == iu2_index51_l2) & (iu2_endian == iu2_dir_dataout[i * dir_way_width + 51 - (64 - `REAL_IFAR_WIDTH)]);
     end
   end
   endgenerate


   assign iu2_dir_miss = (~|(iu2_rd_hit));

   assign iu2_wrong_ra = (iu2_rpn[51] != iu2_index51_l2) & (~iu2_ierat_error[0]) & (~iu2_cam_change_etc_flush);
   assign icd_ics_iu2_wrong_ra_flush = {`THREADS{iu2_valid_l2 & iu2_wrong_ra}} & iu2_tid_l2;

   // Cam change is IU1 phase.  Need to flush if cam changes and we didn't read erat.
   // Latch IU1 flushes and do flush in IU2 (less muxing for IU0 ifar). Flush if cam changes & didn't read erat
   assign iu2_cam_change_etc_d = (ierat_iu_cam_change & (~iu1_read_erat_l2)) |
     (ierat_iu_iu2_error[0] & iu2_valid_erat_read & (~iu1_read_erat_l2) & (iu1_tid_l2 == iu2_tid_l2)) |		// Flush next command (IU1) if IU2 error
     (|(ierat_iu_iu2_flush_req & iu1_tid_l2) & (iu1_tid_l2 == iu2_tid_l2));   // Flush next command (IU1) if ierat flush and iu2_prefetch, in order to get the correct iu0_ifar

   assign iu2_cam_change_etc_flush = iu2_cam_change_etc_l2 & (iu2_valid_l2 | iu2_prefetch_l2);
   assign icd_ics_iu2_cam_etc_flush = {`THREADS{iu2_cam_change_etc_flush}} & iu2_tid_l2;

   assign iu2_valid_d = iu1_valid_l2 & (|(iu1_tid_l2 & (~ics_icd_iu1_flush)));

   assign iu2_tid_d = iu1_tid_l2;

   assign iu2_2ucode_d = iu1_2ucode_l2;
   assign iu2_2ucode_type_d = iu1_2ucode_type_l2;

   assign iu2_inval_d = iu1_inval_l2;

   assign iu2_prefetch_d = iu1_prefetch_l2 & (|(iu1_tid_l2 & (~ics_icd_iu1_flush)));

   assign iu2_read_erat_d = iu1_read_erat_l2;

   assign iu2_spr_idir_read_d = iu1_spr_idir_read_l2;

   assign icd_ics_iu1_read_erat       = {`THREADS{(iu1_valid_l2 | iu1_prefetch_l2) & iu1_read_erat_l2}} & iu1_tid_l2;
   assign icd_ics_iu2_read_erat_error = {`THREADS{(iu2_valid_l2 | iu2_prefetch_l2) & iu2_read_erat_l2 & ierat_iu_iu2_error[0]}} & iu2_tid_l2;

   //---------------------------------------------------------------------
   // Check Multihit
   //---------------------------------------------------------------------
   // Set if more than 1 way matches (not 0000, 0001, 0010, 0100, 1000)
   assign iu2_multihit_err = (iu2_valid_l2 | iu2_inval_l2 | iu2_spr_idir_read_l2 | iu2_prefetch_l2) &   // Don't want to set error if array not read this cycle
                         (~((iu2_rd_hit[0:2] == 3'b000) |
                            (({iu2_rd_hit[0:1], iu2_rd_hit[3]}) == 3'b000) |
                            (({iu2_rd_hit[0], iu2_rd_hit[2:3]}) == 3'b000) |
                            (iu2_rd_hit[1:3] == 3'b000)));

   assign iu2_pc_inj_icachedir_multihit = (iu2_valid_l2 | iu2_inval_l2 | iu2_spr_idir_read_l2 | iu2_prefetch_l2) & pc_iu_inj_icachedir_multihit_l2 & (~iu2_dir_miss);

   assign iu3_multihit_err_way_d = ({4{iu2_multihit_err}} & iu2_rd_hit) |
       {4{iu2_pc_inj_icachedir_multihit}};

   assign iu3_multihit_err = |(iu3_multihit_err_way_l2);

   assign iu3_multihit_flush_d = (iu2_multihit_err | (pc_iu_inj_icachedir_multihit_l2 & (~iu2_dir_miss))) & (iu2_valid_l2 & (|(iu2_tid_l2 & (~ics_icd_iu2_flush))) & (~iu2_ci));

   tri_direct_err_rpt #(.WIDTH(1)) err_icachedir_multihit(
      .vd(vdd),
      .gd(gnd),
      .err_in(iu3_multihit_err),
      .err_out(iu_pc_err_icachedir_multihit)
   );

   //---------------------------------------------------------------------
   // Check Parity
   //---------------------------------------------------------------------
   // Dir
   generate
   begin : xhdl9
     genvar  w;
     for (w = 0; w < 4; w = w + 1)
     begin : calc_ext_dir_0
       genvar  i;
       for (i = 0; i < dir_parity_width*8; i = i + 1)
       begin : calc_ext_dir_dataout0
         if (i < 52 - (64 - `REAL_IFAR_WIDTH))
           assign ext_dir_dataout[w][i] = iu2_dir_dataout[i + w * dir_way_width];
         if (i >= 52 - (64 - `REAL_IFAR_WIDTH))
           assign ext_dir_dataout[w][i] = 1'b0;
       end

       assign dir_parity_out[w] = iu2_dir_dataout[w * dir_way_width + 52 - (64 - `REAL_IFAR_WIDTH):w * dir_way_width + 52 - (64 - `REAL_IFAR_WIDTH) + dir_parity_width - 1];

       //genvar  i;
       for (i = 0; i < dir_parity_width; i = i + 1)
       begin : chk_dir_parity
         assign gen_dir_parity_out[w][i] = ^(ext_dir_dataout[w][i * 8:i * 8 + 7]) ^ pc_iu_inj_icachedir_parity_l2;
       end

       assign dir_parity_err_byte[w] = dir_parity_out[w] ^ gen_dir_parity_out[w];

       assign iu2_dir_parity_err_way[w] = (|(dir_parity_err_byte[w])) & iu2_dir_rd_val_l2[w] & (iu2_valid_l2 | iu2_inval_l2 | iu2_spr_idir_read_l2 | iu2_prefetch_l2);		// Don't want to set error if array not read this cycle
     end
   end
   endgenerate

   assign iu2_rd_parity_err = |(iu2_dir_parity_err_way & iu2_rd_hit);

   assign iu3_dir_parity_err_way_d = iu2_dir_parity_err_way;

   assign iu3_dir_parity_err = |(iu3_dir_parity_err_way_l2);


   tri_direct_err_rpt #(.WIDTH(1)) err_icachedir_parity(
      .vd(vdd),
      .gd(gnd),
      .err_in(iu3_dir_parity_err),
      .err_out(iu_pc_err_icachedir_parity)
   );

   //Data
   generate
   begin : xhdl11
     genvar  w;
     for (w = 0; w < 4; w = w + 1)
     begin : data_parity_out_gen
       assign data_parity_out[w] = iu2_data_dataout[w * 162 + 144:w * 162 + 144 + 18 - 1];

       genvar  i;
       for (i = 0; i < 18; i = i + 1)
       begin : chk_data_parity
         assign gen_data_parity_out[w][i] = ^(iu2_data_dataout[w * 162 + i * 8:w * 162 + i * 8 + 7]);
       end

       assign data_parity_err_byte[w] = data_parity_out[w] ^ gen_data_parity_out[w];

       assign iu3_data_parity_err_way_d[w] = (|(data_parity_err_byte[w])) & iu2_dir_rd_val_l2[w] & iu2_valid_l2;
     end
   end
   endgenerate

   assign data_parity_err = |(iu3_data_parity_err_way_l2);


   tri_direct_err_rpt #(.WIDTH(1)) err_icache_parity(
      .vd(vdd),
      .gd(gnd),
      .err_in(data_parity_err),
      .err_out(iu_pc_err_icache_parity)
   );

   assign iu3_parity_needs_flush_d = iu2_valid_l2 & (|(iu2_tid_l2 & (~ics_icd_iu2_flush))) & (~iu2_rd_miss) & (|(iu3_data_parity_err_way_d & iu2_rd_hit));
   assign icd_ics_iu3_parity_flush = {`THREADS{iu3_parity_needs_flush_l2 | iu3_multihit_flush_l2}} & iu3_tid_l2;

   assign iu3_parity_tag_d = {iu2_index51_l2, iu2_ifar_eff_l2[52:56], (iu2_ifar_eff_l2[57] & (~(spr_ic_cls_l2 & (~iu2_spr_idir_read_l2))))};

   //---------------------------------------------------------------------
   // Update LRU
   //---------------------------------------------------------------------
   // For 128B cacheline mode, use even dir rows
   assign iu2_ifar_eff_cacheline = {iu2_index51_l2, iu2_ifar_eff_l2[52:56], (iu2_ifar_eff_l2[57] & (~(spr_ic_cls_l2 & (~iu2_spr_idir_read_l2))))};
   assign reload_cacheline = {icm_icd_reload_addr[51:56], (icm_icd_reload_addr[57] & (~spr_ic_cls_l2))};
   assign ecc_inval_cacheline = {icm_icd_ecc_addr[51:56], (icm_icd_ecc_addr[57] & (~spr_ic_cls_l2))};
   assign lru_write_cacheline = {icm_icd_lru_write_addr[51:56], (icm_icd_lru_write_addr[57] & (~spr_ic_cls_l2))};

   assign iu3_any_parity_err_way = iu3_multihit_err_way_l2 | iu3_dir_parity_err_way_l2 | iu3_data_parity_err_way_l2;

   // ICI Latches
   assign ici_val_d = lq_iu_ici_val;

   // update LRU in IU2 on read hit or dir_write
   generate
   begin : xhdl12
     genvar  a;
     for (a = 0; a < 128; a = a + 1)
     begin : dir_lru_gen
       wire [0:6] index_v7 = a;
       assign dir_lru_d[a] = (icm_icd_lru_write == 1'b0) ? dir_lru_read[a] :
                                                           dir_lru_write[a];

       //always @(dir_lru_l2 or iu2_lru_rd_update or iu2_ifar_eff_cacheline or iu2_way_select_no_par_err or icm_icd_lru_write or lru_write_cacheline or icm_icd_lru_write_way)
       always @ (*)
       begin: lru_proc
         dir_lru_read[a] <= dir_lru_l2[a];
         dir_lru_write[a] <= dir_lru_l2[a];
         if (iu2_lru_rd_update == 1'b1 & (iu2_ifar_eff_cacheline == index_v7))
           dir_lru_read[a] <= ({3{iu2_rd_hit[0]}} & {2'b11, dir_lru_l2[a][2]}) |
                              ({3{iu2_rd_hit[1]}} & {2'b10, dir_lru_l2[a][2]}) |
                              ({3{iu2_rd_hit[2]}} & {1'b0, dir_lru_l2[a][1], 1'b1}) |
                              ({3{iu2_rd_hit[3]}} & {1'b0, dir_lru_l2[a][1], 1'b0});
         if (icm_icd_lru_write == 1'b1 & (lru_write_cacheline == index_v7))
           dir_lru_write[a] <= ({3{icm_icd_lru_write_way[0]}} & {2'b11, dir_lru_l2[a][2]}) |
                               ({3{icm_icd_lru_write_way[1]}} & {2'b10, dir_lru_l2[a][2]}) |
                               ({3{icm_icd_lru_write_way[2]}} & {1'b0, dir_lru_l2[a][1], 1'b1}) |
                               ({3{icm_icd_lru_write_way[3]}} & {1'b0, dir_lru_l2[a][1], 1'b0});
       end

       //---------------------------------------------------------------------
       // Update Valid Bits
       //---------------------------------------------------------------------

       assign dir_val_d[a] =
         ((dir_val_l2[a] &
           (~({4{iu3_parity_tag_l2[51:57] == index_v7}} & iu3_any_parity_err_way))) |		// clear on dir parity, data parity, or multihit error
          ({4{icm_icd_dir_val & (reload_cacheline[51:57] == index_v7)}} & icm_icd_reload_way)) &       // set when writing to this entry
         (~({4{icm_icd_dir_inval & (reload_cacheline[51:57] == index_v7)}} & icm_icd_reload_way)) &    // clear when invalidating way for new reload
         (~({4{icm_icd_ecc_inval & (ecc_inval_cacheline[51:57] == index_v7)}} & icm_icd_ecc_way)) &    // clear when bad ecc on data written last cycle
         (~(({4{iu2_inval_l2 & (iu2_ifar_eff_cacheline[51:57] == index_v7)}} & dir_val_l2[a]) &  iu2_rd_tag_hit)) &      // clear on back_invalidate
         (~({4{ici_val_l2}}));   // clear on ICI
     end
   end
   endgenerate

   generate
   begin : xhdl13
     genvar  a;
     for (a = 0; a < 16; a = a + 1)
     begin : dir_lru_act_gen
       wire [0:3] index_v4 = a;
       assign dir_lru_act[a] = (icm_icd_lru_write & (lru_write_cacheline[51:54] == index_v4)) |
                               (iu2_valid_l2 & (iu2_ifar_eff_cacheline[51:54] == index_v4));
     end
   end
   endgenerate

   assign dir_val_act = ici_val_l2 | (|(iu3_any_parity_err_way)) | icm_icd_any_reld_r2 | icm_icd_ecc_inval | iu2_inval_l2;

   // All erat errors except for erat parity error, for timing
   assign iu2_erat_err_lite = (ierat_iu_iu2_miss | ierat_iu_iu2_multihit | ierat_iu_iu2_isi) & iu2_read_erat_l2;

   // Note: if timing is bad, can remove parity err check
   assign iu2_lru_rd_update = iu2_valid_l2 & (~iu2_erat_err_lite) & (|(iu2_rd_hit)) & (~iu2_rd_parity_err) & (~iu2_multihit_err) & (~pc_iu_inj_icachedir_multihit_l2);

   // ic miss latches the location for data write to prevent data from moving around in Data cache

   //always @(icm_icd_lru_addr or dir_lru_l2)
   always @ (*)
   begin: return_lru_proc
      (* analysis_not_referenced="true" *)
      integer  i;
      return_lru <= 3'b000;
      for (i = 0; i < 128; i = i + 1)
         if (icm_icd_lru_addr[51:57] == i)
            return_lru <= dir_lru_l2[i];
   end

   assign icd_icm_row_lru = return_lru;


   //always @(icm_icd_lru_addr or dir_val_l2)
   always @ (*)
   begin: return_val_proc
      (* analysis_not_referenced="true" *)
      integer  i;
      return_val <= 4'b0000;
      for (i = 0; i < 128; i = i + 1)
         if (icm_icd_lru_addr[51:57] ==i)
            return_val <= dir_val_l2[i];
   end

   assign icd_icm_row_val = return_val;

   //---------------------------------------------------------------------
   // IU2
   //---------------------------------------------------------------------
   // IU2 Output
   generate
   begin : xhdl14
     genvar  i;
     for (i = 0; i < 52; i = i + 1)
     begin : mm_epn
       if (i < (62 - `EFF_IFAR_ARCH))
         assign iu_mm_ierat_epn[i] = 1'b0;
       if (i >= (62 - `EFF_IFAR_ARCH))
         assign iu_mm_ierat_epn[i] = iu2_ifar_eff_l2[i];
     end
   end
   endgenerate

   // Handle Miss
   assign iu2_rd_miss = (iu2_valid_l2 | iu2_prefetch_l2) & (~|(ierat_iu_iu2_flush_req)) &
                        (iu2_dir_miss | iu2_ci | iu2_rd_parity_err) &
                        (~iu2_ierat_error[0]) & (~iu2_cam_change_etc_flush) & (~iu2_wrong_ra) &
                        (~(iu3_miss_flush_l2 & |(iu3_tid_l2 & iu2_tid_l2)));
   assign iu3_miss_flush_d = iu2_rd_miss & (~iu2_prefetch_l2) & (|(iu2_tid_l2 & (~ics_icd_iu2_flush)));
   assign icd_icm_miss = iu2_rd_miss;
   assign icd_icm_prefetch = iu2_prefetch_l2;
   assign icd_icm_tid = iu2_tid_l2;
   assign icd_icm_addr_real = {iu2_rpn[64 - `REAL_IFAR_WIDTH:51], iu2_ifar_eff_l2[52:61]};	// ???? Could use iu2_index51
   assign icd_icm_addr_eff = iu2_ifar_eff_l2[62 - `EFF_IFAR_WIDTH:51];
   assign icd_icm_wimge = iu2_wimge;
   assign icd_icm_userdef = iu2_u;
   assign icd_icm_2ucode = iu2_2ucode_l2;
   assign icd_icm_2ucode_type = iu2_2ucode_type_l2;
   assign icd_icm_iu2_inval = iu2_inval_l2;
   assign icd_icm_any_iu2_valid = iu2_valid_l2 | iu2_prefetch_l2;		// for act's in ic_miss

   assign icd_ics_iu3_miss_flush = {`THREADS{iu3_miss_flush_l2}} & iu3_tid_l2 ;
   assign icd_ics_iu2_ifar_eff = iu2_ifar_eff_l2[62 - `EFF_IFAR_WIDTH:61];
   assign icd_ics_iu2_2ucode = iu2_2ucode_l2;
   assign icd_ics_iu2_2ucode_type = iu2_2ucode_type_l2;
   assign icd_ics_iu2_valid = iu2_valid_l2;

   // Moved flushes to ic_bp_iu2_flush
   // Note: iu2_valid_l2 and icm_icd_load must never be on at same time
   assign iu2_valid_or_load = iu2_valid_l2 | (|(icm_icd_load));

   assign iu3_instr_valid_d[0:3] = ({iu2_valid_or_load, iu3_ifar_d[60:61]} == 3'b100) ? 4'b1111 :
                                   ({iu2_valid_or_load, iu3_ifar_d[60:61]} == 3'b101) ? 4'b1110 :
                                   ({iu2_valid_or_load, iu3_ifar_d[60:61]} == 3'b110) ? 4'b1100 :
                                   ({iu2_valid_or_load, iu3_ifar_d[60:61]} == 3'b111) ? 4'b1000 :
                                                                                        4'b0000;

   assign iu3_tid_d = (iu2_valid_l2 == 1'b1) ? iu2_tid_l2 :
                      icm_icd_load;

   assign iu3_ifar_d = (iu2_valid_l2 == 1'b1) ? iu2_ifar_eff_l2[62 - `EFF_IFAR_WIDTH:61] :
                       icm_icd_load_addr;

   assign iu3_2ucode_d = (iu2_valid_l2 == 1'b1) ? iu2_2ucode_l2 :
                         icm_icd_load_2ucode;

   assign iu3_2ucode_type_d = (iu2_valid_l2 == 1'b1) ? iu2_2ucode_type_l2 :
                              icm_icd_load_2ucode_type;

   assign iu3_erat_err_d = iu2_ierat_error[0:2] & {3{iu2_valid_l2}};

   // Rotate instructions
   generate
   begin : xhdl15
     genvar  w;
     for (w = 0; w < 4; w = w + 1)
     begin : iu2_instr_rot0
       assign iu2_instr0_cache_rot[w] =
       (iu2_ifar_eff_l2[60:61] == 2'b00) ? iu2_data_dataout[w * 162      :w * 162 + 35]  :
       (iu2_ifar_eff_l2[60:61] == 2'b01) ? iu2_data_dataout[w * 162 + 36 :w * 162 + 71]  :
       (iu2_ifar_eff_l2[60:61] == 2'b10) ? iu2_data_dataout[w * 162 + 72 :w * 162 + 107] :
                                           iu2_data_dataout[w * 162 + 108:w * 162 + 143];

       assign iu2_instr1_cache_rot[w] =
           (iu2_ifar_eff_l2[60:61] == 2'b00) ? iu2_data_dataout[w * 162 + 36 :w * 162 + 71]  :
           (iu2_ifar_eff_l2[60:61] == 2'b01) ? iu2_data_dataout[w * 162 + 72 :w * 162 + 107] :
                                               iu2_data_dataout[w * 162 + 108:w * 162 + 143];

       assign iu2_instr2_cache_rot[w] =
           (iu2_ifar_eff_l2[61] == 1'b0) ? iu2_data_dataout[w * 162 + 72 :w * 162 + 107] :
                                           iu2_data_dataout[w * 162 + 108:w * 162 + 143];

       assign iu2_instr3_cache_rot[w] = iu2_data_dataout[w * 162 + 108:w * 162 + 143];

       // Force 2ucode to 0 if branch instructions or no-op.  No other
       // instructions are legal when dynamically changing code.
       // Note: This signal does not include all non-ucode ops - just the ones
       // that will cause problems with flush_2ucode.
       assign iu2_uc_illegal_cache_rot[w] = iu2_instr0_cache_rot[w][32] | (iu2_instr0_cache_rot[w][0:5] == 6'b011000);
     end
   end
   endgenerate

   assign iu2_reload_rot[0] = (icm_icd_load_addr[60:61] == 2'b00) ? icm_icd_reload_data[0:35] :
                              (icm_icd_load_addr[60:61] == 2'b01) ? icm_icd_reload_data[36:71] :
                              (icm_icd_load_addr[60:61] == 2'b10) ? icm_icd_reload_data[72:107] :
                                                                    icm_icd_reload_data[108:143];

   assign iu2_reload_rot[1] = (icm_icd_load_addr[60:61] == 2'b00) ? icm_icd_reload_data[36:71] :
                              (icm_icd_load_addr[60:61] == 2'b01) ? icm_icd_reload_data[72:107] :
                                                                    icm_icd_reload_data[108:143];

   assign iu2_reload_rot[2] = (icm_icd_load_addr[61] == 1'b0) ? icm_icd_reload_data[72:107] :
                                                                icm_icd_reload_data[108:143];

   assign iu2_reload_rot[3] = icm_icd_reload_data[108:143];

   assign iu2_uc_illegal_reload = iu2_reload_rot[0][32] | (iu2_reload_rot[0][0:5] == 6'b011000);

   // Select way hit
   assign iu2_hit_rot[0] = ({36{iu2_rd_hit[0]}} & iu2_instr0_cache_rot[0]) |
                           ({36{iu2_rd_hit[1]}} & iu2_instr0_cache_rot[1]) |
                           ({36{iu2_rd_hit[2]}} & iu2_instr0_cache_rot[2]) |
                           ({36{iu2_rd_hit[3]}} & iu2_instr0_cache_rot[3]);

   assign iu2_hit_rot[1] = ({36{iu2_rd_hit[0]}} & iu2_instr1_cache_rot[0]) |
                           ({36{iu2_rd_hit[1]}} & iu2_instr1_cache_rot[1]) |
                           ({36{iu2_rd_hit[2]}} & iu2_instr1_cache_rot[2]) |
                           ({36{iu2_rd_hit[3]}} & iu2_instr1_cache_rot[3]);

   assign iu2_hit_rot[2] = ({36{iu2_rd_hit[0]}} & iu2_instr2_cache_rot[0]) |
                           ({36{iu2_rd_hit[1]}} & iu2_instr2_cache_rot[1]) |
                           ({36{iu2_rd_hit[2]}} & iu2_instr2_cache_rot[2]) |
                           ({36{iu2_rd_hit[3]}} & iu2_instr2_cache_rot[3]);

   assign iu2_hit_rot[3] = ({36{iu2_rd_hit[0]}} & iu2_instr3_cache_rot[0]) |
                           ({36{iu2_rd_hit[1]}} & iu2_instr3_cache_rot[1]) |
                           ({36{iu2_rd_hit[2]}} & iu2_instr3_cache_rot[2]) |
                           ({36{iu2_rd_hit[3]}} & iu2_instr3_cache_rot[3]);

   assign iu2_uc_illegal_cache = |(iu2_rd_hit & iu2_uc_illegal_cache_rot);

   // Timing: moved xnop to bp
   // Using xori 0,0,0 (xnop) when erat error
   //xnop <= "011010" & ZEROS(6 to 35);

   generate
   begin : xhdl16
     genvar  i;
     for (i = 0; i < 4; i = i + 1)
     begin : gen_instr
       assign iu2_instr[i] = (iu2_valid_l2 == 1'b1) ? iu2_hit_rot[i] :
                                                      iu2_reload_rot[i];
     end
   end
   endgenerate

   assign iu2_uc_illegal = (iu2_valid_l2 == 1'b1) ? iu2_uc_illegal_cache :
                                                    iu2_uc_illegal_reload;

   //---------------------------------------------------------------------
   // IU3
   //---------------------------------------------------------------------

   assign ic_bp_iu2_t0_val = {4{iu3_tid_d[0]}} & iu3_instr_valid_d;
 `ifndef THREADS1
     assign ic_bp_iu2_t1_val = {4{iu3_tid_d[1]}} & iu3_instr_valid_d;
 `endif

   assign ic_bp_iu2_ifar = iu3_ifar_d;
   assign ic_bp_iu2_2ucode = iu3_2ucode_d & (~iu2_uc_illegal);
   assign ic_bp_iu2_2ucode_type = iu3_2ucode_type_d;
   // Moved ecc_err muxing to BP IU3
   assign ic_bp_iu2_error = iu3_erat_err_d;
   assign ic_bp_iu2_0_instr = iu2_instr[0];
   assign ic_bp_iu2_1_instr = iu2_instr[1];
   assign ic_bp_iu2_2_instr = iu2_instr[2];
   assign ic_bp_iu2_3_instr = iu2_instr[3];

   // Moved ic_bp_iu2_flush to iuq_ic_select
   assign ic_bp_iu3_flush = {`THREADS{iu3_miss_flush_l2 | icm_icd_iu3_ecc_fp_cancel | ((iu3_parity_needs_flush_l2 | iu3_multihit_flush_l2) & (~iu3_erat_err_l2[0]))}} & iu3_tid_l2;

   assign icd_ics_iu3_ifar = iu3_ifar_l2;
   assign icd_ics_iu3_2ucode = iu3_2ucode_l2;
   assign icd_ics_iu3_2ucode_type = iu3_2ucode_type_l2;

   //---------------------------------------------------------------------
   // Performance Events
   //---------------------------------------------------------------------
   generate
   begin : xhdl10
     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : gen_perf
       // IERAT Miss
       //      - IU2 ierat miss
       assign perf_t_event_d[i][9] = iu2_valid_l2 & iu2_tid_l2[i] & iu2_read_erat_l2 & ierat_iu_iu2_miss;

       // I-Cache Fetch
       //      - Number of times ICache is read for instruction
       assign perf_t_event_d[i][10] = iu2_valid_l2 & iu2_tid_l2[i];

       // Instructions Fetched
       //      - Number of instructions fetched, divided by 4.
       assign perf_instr_count_new[i][0:2] = {1'b0, perf_instr_count_l2[i][0:1]} + iu2_instr_count;
       assign perf_instr_count_d[i][0:1] = (iu2_valid_l2 & iu2_tid_l2[i]) ? perf_instr_count_new[i][1:2] :
                                                                            perf_instr_count_l2[i];
       assign perf_t_event_d[i][11] = iu2_valid_l2 & iu2_tid_l2[i] & perf_instr_count_new[i][0];
     end
   end
   endgenerate

   assign iu2_instr_count = (iu2_ifar_eff_l2[60:61] == 2'b00) ? 3'b100 :
                            (iu2_ifar_eff_l2[60:61] == 2'b01) ? 3'b011 :
                            (iu2_ifar_eff_l2[60:61] == 2'b10) ? 3'b010 :
                                                                3'b001;

   // Events not per thread
   // L2 Back Invalidates I-Cache
   assign perf_event_d[0] = iu2_inval_l2;

   // L2 Back Invalidates I-Cache - Hits
   assign perf_event_d[1] = iu2_inval_l2 & |(iu2_rd_tag_hit & iu2_dir_rd_val_l2);

   assign ic_perf_t0_event = perf_t_event_l2[0];
 `ifndef THREADS1
     assign ic_perf_t1_event = perf_t_event_l2[1];
 `endif
   assign ic_perf_event = perf_event_l2;

   //---------------------------------------------------------------------
   // Latches
   //---------------------------------------------------------------------

   // IU1
   tri_rlmlatch_p #(.INIT(0)) iu1_valid_latch(
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
      .scin(siv[iu1_valid_offset]),
      .scout(sov[iu1_valid_offset]),
      .din(iu1_valid_d),
      .dout(iu1_valid_l2)
   );

   generate
     if (`THREADS == 1)
     begin : iu1_tid1
       assign iu1_tid_l2 = iu1_tid_d | 1'b1;	// Need to always be '1' when single thread since we aren't latching.
                                                // 'iu1_tid_d' part is to get rid of unused warnings
       assign sov[iu1_tid_offset] = siv[iu1_tid_offset];
     end
   endgenerate

   generate
     if (`THREADS != 1)
     begin : iu1_tid2
       tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu1_tid_latch(
          .vd(vdd),
          .gd(gnd),
          .nclk(nclk),
          .act(dir_rd_act),		// ??? Is this act worth it?  Only tid, 2ucode, & 2ucode_type use for non-slp
          .thold_b(pc_iu_func_sl_thold_0_b),
          .sg(pc_iu_sg_0),
          .force_t(force_t),
          .delay_lclkr(delay_lclkr),
          .mpw1_b(mpw1_b),
          .mpw2_b(mpw2_b),
          .d_mode(d_mode),
          .scin(siv[iu1_tid_offset:iu1_tid_offset + `THREADS - 1]),
          .scout(sov[iu1_tid_offset:iu1_tid_offset + `THREADS - 1]),
          .din(iu1_tid_d),
          .dout(iu1_tid_l2)
       );
     end
   endgenerate

   // Note: Technically, only need REAL_IFAR range during sleep mode
   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(0)) iu1_ifar_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(dir_rd_act),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu1_ifar_offset:iu1_ifar_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[iu1_ifar_offset:iu1_ifar_offset + `EFF_IFAR_ARCH - 1]),
      .din(iu1_ifar_d),
      .dout(iu1_ifar_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu1_index51_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(dir_rd_act),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu1_index51_offset]),
      .scout(sov[iu1_index51_offset]),
      .din(iu1_index51_d),
      .dout(iu1_index51_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu1_inval_latch(
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
      .scin(siv[iu1_inval_offset]),
      .scout(sov[iu1_inval_offset]),
      .din(iu1_inval_d),
      .dout(iu1_inval_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu1_prefetch_latch(
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
      .scin(siv[iu1_prefetch_offset]),
      .scout(sov[iu1_prefetch_offset]),
      .din(iu1_prefetch_d),
      .dout(iu1_prefetch_l2)
   );

   generate
      if (`INCLUDE_IERAT_BYPASS == 0)
      begin : gen_iu1_read_erat0
         assign iu1_read_erat_l2 = 1'b1 | iu1_read_erat_d;
         assign sov[iu1_read_erat_offset] = siv[iu1_read_erat_offset];
      end
   endgenerate

   generate
      if (`INCLUDE_IERAT_BYPASS == 1)
      begin : gen_iu1_read_erat1
         tri_rlmlatch_p #(.INIT(0)) iu1_read_erat_latch(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(dir_rd_act),
            .thold_b(pc_iu_func_sl_thold_0_b),
            .sg(pc_iu_sg_0),
            .force_t(force_t),
            .delay_lclkr(delay_lclkr),
            .mpw1_b(mpw1_b),
            .mpw2_b(mpw2_b),
            .d_mode(d_mode),
            .scin(siv[iu1_read_erat_offset]),
            .scout(sov[iu1_read_erat_offset]),
            .din(iu1_read_erat_d),
            .dout(iu1_read_erat_l2)
         );
      end
   endgenerate

   tri_rlmlatch_p #(.INIT(0)) iu1_2ucode_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(dir_rd_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu1_2ucode_offset]),
      .scout(sov[iu1_2ucode_offset]),
      .din(iu1_2ucode_d),
      .dout(iu1_2ucode_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu1_2ucode_type_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(dir_rd_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu1_2ucode_type_offset]),
      .scout(sov[iu1_2ucode_type_offset]),
      .din(iu1_2ucode_type_d),
      .dout(iu1_2ucode_type_l2)
   );

   // IU2
   tri_rlmlatch_p #(.INIT(0)) iu2_valid_latch(
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
      .scin(siv[iu2_valid_offset]),
      .scout(sov[iu2_valid_offset]),
      .din(iu2_valid_d),
      .dout(iu2_valid_l2)
   );

   generate
      if (`THREADS == 1)
      begin : iu2_tid1
         assign iu2_tid_l2 = iu2_tid_d;
         assign sov[iu2_tid_offset] = siv[iu2_tid_offset];
      end
   endgenerate

   generate
      if (`THREADS != 1)
      begin : iu2_tid2
         tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu2_tid_latch(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(dir_dataout_act),
            .thold_b(pc_iu_func_sl_thold_0_b),
            .sg(pc_iu_sg_0),
            .force_t(force_t),
            .delay_lclkr(delay_lclkr),
            .mpw1_b(mpw1_b),
            .mpw2_b(mpw2_b),
            .d_mode(d_mode),
            .scin(siv[iu2_tid_offset:iu2_tid_offset + `THREADS - 1]),
            .scout(sov[iu2_tid_offset:iu2_tid_offset + `THREADS - 1]),
            .din(iu2_tid_d),
            .dout(iu2_tid_l2)
         );
      end
   endgenerate

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH-10), .INIT(0), .NEEDS_SRESET(0)) iu2_ifar_eff_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(dir_dataout_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu2_ifar_eff_offset:iu2_ifar_eff_offset + `EFF_IFAR_ARCH-10 - 1]),
      .scout(sov[iu2_ifar_eff_offset:iu2_ifar_eff_offset + `EFF_IFAR_ARCH-10 - 1]),
      .din(iu2_ifar_eff_d[62 - `EFF_IFAR_ARCH:51]),
      .dout(iu2_ifar_eff_l2[62 - `EFF_IFAR_ARCH:51])
   );

   // Only need 52:57 in sleep mode
   tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(0)) iu2_ifar_eff_slp_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(dir_dataout_act),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu2_ifar_eff_offset + `EFF_IFAR_ARCH-10:iu2_ifar_eff_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[iu2_ifar_eff_offset + `EFF_IFAR_ARCH-10:iu2_ifar_eff_offset + `EFF_IFAR_ARCH - 1]),
      .din(iu2_ifar_eff_d[52:61]),
      .dout(iu2_ifar_eff_l2[52:61])
   );

   tri_rlmlatch_p #(.INIT(0)) iu2_2ucode_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu1_valid_l2),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu2_2ucode_offset]),
      .scout(sov[iu2_2ucode_offset]),
      .din(iu2_2ucode_d),
      .dout(iu2_2ucode_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu2_2ucode_type_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu1_valid_l2),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu2_2ucode_type_offset]),
      .scout(sov[iu2_2ucode_type_offset]),
      .din(iu2_2ucode_type_d),
      .dout(iu2_2ucode_type_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu2_index51_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(dir_dataout_act),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu2_index51_offset]),
      .scout(sov[iu2_index51_offset]),
      .din(iu2_index51_d),
      .dout(iu2_index51_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu2_inval_latch(
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
      .scin(siv[iu2_inval_offset]),
      .scout(sov[iu2_inval_offset]),
      .din(iu2_inval_d),
      .dout(iu2_inval_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu2_prefetch_latch(
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
      .scin(siv[iu2_prefetch_offset]),
      .scout(sov[iu2_prefetch_offset]),
      .din(iu2_prefetch_d),
      .dout(iu2_prefetch_l2)
   );

   generate
      if (`INCLUDE_IERAT_BYPASS == 0)
      begin : gen_iu2_read_erat0
         assign iu2_read_erat_l2 = 1'b1 | iu2_read_erat_d;
         assign iu2_cam_change_etc_l2 = 1'b0 & iu2_cam_change_etc_d;
         assign sov[iu2_read_erat_offset] = siv[iu2_read_erat_offset];
         assign sov[iu2_cam_change_etc_offset] = siv[iu2_cam_change_etc_offset];
      end
   endgenerate

   generate
      if (`INCLUDE_IERAT_BYPASS == 1)
      begin : gen_iu2_read_erat1
         tri_rlmlatch_p #(.INIT(0)) iu2_read_erat_latch(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(dir_dataout_act),
            .thold_b(pc_iu_func_sl_thold_0_b),
            .sg(pc_iu_sg_0),
            .force_t(force_t),
            .delay_lclkr(delay_lclkr),
            .mpw1_b(mpw1_b),
            .mpw2_b(mpw2_b),
            .d_mode(d_mode),
            .scin(siv[iu2_read_erat_offset]),
            .scout(sov[iu2_read_erat_offset]),
            .din(iu2_read_erat_d),
            .dout(iu2_read_erat_l2)
         );

         tri_rlmlatch_p #(.INIT(0)) iu2_cam_change_etc_latch(
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
            .scin(siv[iu2_cam_change_etc_offset]),
            .scout(sov[iu2_cam_change_etc_offset]),
            .din(iu2_cam_change_etc_d),
            .dout(iu2_cam_change_etc_l2)
         );
      end
   endgenerate

   tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH-12), .INIT(0), .NEEDS_SRESET(0)) iu2_stored_rpn_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(dir_dataout_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu2_stored_rpn_offset:iu2_stored_rpn_offset + `REAL_IFAR_WIDTH-12 - 1]),
      .scout(sov[iu2_stored_rpn_offset:iu2_stored_rpn_offset + `REAL_IFAR_WIDTH-12 - 1]),
      .din(iu2_stored_rpn_d),
      .dout(iu2_stored_rpn_l2)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) iu2_dir_rd_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(dir_dataout_act),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(funcslp_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu2_dir_rd_val_offset:iu2_dir_rd_val_offset + 4 - 1]),
      .scout(sov[iu2_dir_rd_val_offset:iu2_dir_rd_val_offset + 4 - 1]),
      .din(iu2_dir_rd_val_d),
      .dout(iu2_dir_rd_val_l2)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) iu3_dir_parity_err_way_latch(
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
      .scin(siv[iu3_dir_parity_err_way_offset:iu3_dir_parity_err_way_offset + 4 - 1]),
      .scout(sov[iu3_dir_parity_err_way_offset:iu3_dir_parity_err_way_offset + 4 - 1]),
      .din(iu3_dir_parity_err_way_d),
      .dout(iu3_dir_parity_err_way_l2)
   );

   // Dir
   generate
   begin : xhdl17
     genvar  a;
     for (a = 0; a < 128; a = a + 1)
     begin : dir_val_latch_gen

       tri_rlmreg_p #(.WIDTH(4), .INIT(0)) dir_val_latch(
          .vd(vdd),
          .gd(gnd),
          .nclk(nclk),
          .act(dir_val_act),
          .thold_b(pc_iu_func_slp_sl_thold_0_b),
          .sg(pc_iu_sg_0),
          .force_t(funcslp_force),
          .delay_lclkr(delay_lclkr),
          .mpw1_b(mpw1_b),
          .mpw2_b(mpw2_b),
          .d_mode(d_mode),
          .scin(siv[dir_val_offset + 4 * a:(dir_val_offset + 4 * (a + 1)) - 1]),
          .scout(sov[dir_val_offset + 4 * a:(dir_val_offset + 4 * (a + 1)) - 1]),
          .din(dir_val_d[a]),
          .dout(dir_val_l2[a])
       );

       tri_rlmreg_p #(.WIDTH(3), .INIT(0)) dir_lru_latch(
          .vd(vdd),
          .gd(gnd),
          .nclk(nclk),
          .act(dir_lru_act[a/8]),
          .thold_b(pc_iu_func_sl_thold_0_b),
          .sg(pc_iu_sg_0),
          .force_t(force_t),
          .delay_lclkr(delay_lclkr),
          .mpw1_b(mpw1_b),
          .mpw2_b(mpw2_b),
          .d_mode(d_mode),
          .scin(siv[dir_lru_offset + 3 * a:(dir_lru_offset + 3 * (a + 1)) - 1]),
          .scout(sov[dir_lru_offset + 3 * a:(dir_lru_offset + 3 * (a + 1)) - 1]),
          .din(dir_lru_d[a]),
          .dout(dir_lru_l2[a])
       );
     end
   end
   endgenerate

   tri_rlmlatch_p #(.INIT(0)) iu3_miss_flush(
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
      .scin(siv[iu3_miss_flush_offset]),
      .scout(sov[iu3_miss_flush_offset]),
      .din(iu3_miss_flush_d),
      .dout(iu3_miss_flush_l2)
   );

   generate
      if (`THREADS == 1)
      begin : iu3_tid1
         assign iu3_tid_l2 = iu3_tid_d | 1'b1;	// Need to always be '1' when single thread since we aren't latching.
                                                // 'iu3_tid_d' part is to get rid of unused warnings
         assign sov[iu3_tid_offset] = siv[iu3_tid_offset];
      end
   endgenerate

   generate
      if (`THREADS != 1)
      begin : iu3_tid2
         tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu3_tid_latch(
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
            .scin(siv[iu3_tid_offset:iu3_tid_offset + `THREADS - 1]),
            .scout(sov[iu3_tid_offset:iu3_tid_offset + `THREADS - 1]),
            .din(iu3_tid_d),
            .dout(iu3_tid_l2)
         );
      end
   endgenerate

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(0)) iu3_ifar_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu2_valid_l2),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu3_ifar_offset:iu3_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov[iu3_ifar_offset:iu3_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .din(iu3_ifar_d),
      .dout(iu3_ifar_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu3_2ucode_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu2_valid_l2),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu3_2ucode_offset]),
      .scout(sov[iu3_2ucode_offset]),
      .din(iu3_2ucode_d),
      .dout(iu3_2ucode_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu3_2ucode_type_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu2_valid_l2),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu3_2ucode_type_offset]),
      .scout(sov[iu3_2ucode_type_offset]),
      .din(iu3_2ucode_type_d),
      .dout(iu3_2ucode_type_l2)
   );

   tri_rlmreg_p #(.WIDTH(1), .INIT(0)) iu3_erat_err_latch(
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
      .scin(siv[iu3_erat_err_offset:iu3_erat_err_offset + 1 - 1]),
      .scout(sov[iu3_erat_err_offset:iu3_erat_err_offset + 1 - 1]),
      .din(iu3_erat_err_d[0:0]),
      .dout(iu3_erat_err_l2)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) iu3_multihit_err_way_latch(
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
      .scin(siv[iu3_multihit_err_way_offset:iu3_multihit_err_way_offset + 4 - 1]),
      .scout(sov[iu3_multihit_err_way_offset:iu3_multihit_err_way_offset + 4 - 1]),
      .din(iu3_multihit_err_way_d),
      .dout(iu3_multihit_err_way_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu3_multihit_flush_latch(
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
      .scin(siv[iu3_multihit_flush_offset]),
      .scout(sov[iu3_multihit_flush_offset]),
      .din(iu3_multihit_flush_d),
      .dout(iu3_multihit_flush_l2)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) iu3_data_parity_err_way_latch(
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
      .scin(siv[iu3_data_parity_err_way_offset:iu3_data_parity_err_way_offset + 4 - 1]),
      .scout(sov[iu3_data_parity_err_way_offset:iu3_data_parity_err_way_offset + 4 - 1]),
      .din(iu3_data_parity_err_way_d),
      .dout(iu3_data_parity_err_way_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu3_parity_needs_flush_latch(
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
      .scin(siv[iu3_parity_needs_flush_offset]),
      .scout(sov[iu3_parity_needs_flush_offset]),
      .din(iu3_parity_needs_flush_d),
      .dout(iu3_parity_needs_flush_l2)
   );

   tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(0)) iu3_parity_tag_latch(
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
      .scin(siv[iu3_parity_tag_offset:iu3_parity_tag_offset + 7 - 1]),
      .scout(sov[iu3_parity_tag_offset:iu3_parity_tag_offset + 7 - 1]),
      .din(iu3_parity_tag_d),
      .dout(iu3_parity_tag_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) ici_val_latch(
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
      .scin(siv[ici_val_offset]),
      .scout(sov[ici_val_offset]),
      .din(ici_val_d),
      .dout(ici_val_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) spr_ic_cls_latch(
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
      .scin(siv[spr_ic_cls_offset]),
      .scout(sov[spr_ic_cls_offset]),
      .din(spr_ic_cls_d),
      .dout(spr_ic_cls_l2)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) spr_ic_idir_way_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(dir_dataout_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[spr_ic_idir_way_offset:spr_ic_idir_way_offset + 2 - 1]),
      .scout(sov[spr_ic_idir_way_offset:spr_ic_idir_way_offset + 2 - 1]),
      .din(spr_ic_idir_way_d),
      .dout(spr_ic_idir_way_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu1_spr_idir_read_latch(
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
      .scin(siv[iu1_spr_idir_read_offset]),
      .scout(sov[iu1_spr_idir_read_offset]),
      .din(iu1_spr_idir_read_d),
      .dout(iu1_spr_idir_read_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu2_spr_idir_read_latch(
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
      .scin(siv[iu2_spr_idir_read_offset]),
      .scout(sov[iu2_spr_idir_read_offset]),
      .din(iu2_spr_idir_read_d),
      .dout(iu2_spr_idir_read_l2)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) iu2_spr_idir_lru_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(dir_dataout_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu2_spr_idir_lru_offset:iu2_spr_idir_lru_offset + 3 - 1]),
      .scout(sov[iu2_spr_idir_lru_offset:iu2_spr_idir_lru_offset + 3 - 1]),
      .din(iu2_spr_idir_lru_d),
      .dout(iu2_spr_idir_lru_l2)
   );

   generate
   begin : xhdl19
     if (`INCLUDE_IERAT_BYPASS == 0)
     begin : gen0
       genvar  i;
       for (i = 0; i < `THREADS; i = i + 1)
       begin : thr0
         assign stored_erat_rpn_l2[i] = {`REAL_IFAR_WIDTH-12{1'b0}} & stored_erat_rpn_d[i];	// ..._d part is to get rid of unused warnings
         assign stored_erat_wimge_l2[i] = 5'b0 & stored_erat_wimge_d[i];
         assign stored_erat_u_l2[i] = 4'b0 & stored_erat_u_d[i];
       end

       assign sov[stored_erat_rpn_offset:stored_erat_u_offset + 4 * `THREADS - 1] = siv[stored_erat_rpn_offset:stored_erat_u_offset + 4 * `THREADS - 1];
     end

     if (`INCLUDE_IERAT_BYPASS == 1)
     begin : gen1
       genvar  i;
       for (i = 0; i < `THREADS; i = i + 1)
       begin : thr
         tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH-12), .INIT(0)) stored_erat_rpn_latch(
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
            .scin(siv[stored_erat_rpn_offset + i * (`REAL_IFAR_WIDTH-12):stored_erat_rpn_offset + (i + 1) * (`REAL_IFAR_WIDTH-12) - 1]),
            .scout(sov[stored_erat_rpn_offset + i * (`REAL_IFAR_WIDTH-12):stored_erat_rpn_offset + (i + 1) * (`REAL_IFAR_WIDTH-12) - 1]),
            .din(stored_erat_rpn_d[i]),
            .dout(stored_erat_rpn_l2[i])
         );

         tri_rlmreg_p #(.WIDTH(5), .INIT(0)) stored_erat_wimge_latch(
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
            .scin(siv[stored_erat_wimge_offset + i * 5:stored_erat_wimge_offset + (i + 1) * 5 - 1]),
            .scout(sov[stored_erat_wimge_offset + i * 5:stored_erat_wimge_offset + (i + 1) * 5 - 1]),
            .din(stored_erat_wimge_d[i]),
            .dout(stored_erat_wimge_l2[i])
         );

         tri_rlmreg_p #(.WIDTH(4), .INIT(0)) stored_erat_u_latch(
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
            .scin(siv[stored_erat_u_offset + i * 4:stored_erat_u_offset + (i + 1) * 4 - 1]),
            .scout(sov[stored_erat_u_offset + i * 4:stored_erat_u_offset + (i + 1) * 4 - 1]),
            .din(stored_erat_u_d[i]),
            .dout(stored_erat_u_l2[i])
         );
       end
     end
   end
   endgenerate

   generate
   begin : xhdl18
     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : gen_perf_reg
       tri_rlmreg_p #(.WIDTH(2), .INIT(0)) perf_instr_count_latch(
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
          .scin(siv[perf_instr_count_offset + i * 2:perf_instr_count_offset + (i + 1) * 2 - 1]),
          .scout(sov[perf_instr_count_offset + i * 2:perf_instr_count_offset + (i + 1) * 2 - 1]),
          .din(perf_instr_count_d[i]),
          .dout(perf_instr_count_l2[i])
       );

       tri_rlmreg_p #(.WIDTH(3), .INIT(0)) perf_t_event_latch(
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
          .scin(siv[perf_t_event_offset + i * 3:perf_t_event_offset + (i + 1) * 3 - 1]),
          .scout(sov[perf_t_event_offset + i * 3:perf_t_event_offset + (i + 1) * 3 - 1]),
          .din(perf_t_event_d[i]),
          .dout(perf_t_event_l2[i])
       );
     end
   end
   endgenerate

   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) perf_event_latch(
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
      .scin(siv[perf_event_offset:perf_event_offset + 2 - 1]),
      .scout(sov[perf_event_offset:perf_event_offset + 2 - 1]),
      .din(perf_event_d),
      .dout(perf_event_l2)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) pc_iu_inj_latch(
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
      .scin(siv[pc_iu_inj_offset:pc_iu_inj_offset + 3 - 1]),
      .scout(sov[pc_iu_inj_offset:pc_iu_inj_offset + 3 - 1]),
      .din({pc_iu_inj_icache_parity,
            pc_iu_inj_icachedir_parity,
            pc_iu_inj_icachedir_multihit}),
      .dout({pc_iu_inj_icache_parity_l2,
            pc_iu_inj_icachedir_parity_l2,
            pc_iu_inj_icachedir_multihit_l2})
   );

   //---------------------------------------------------------------------
   // abist latches
   //---------------------------------------------------------------------
   tri_rlmreg_p #(.INIT(0), .WIDTH(41), .NEEDS_SRESET(0)) ab_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_abist_ena_dc),
      .thold_b(pc_iu_abst_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(abst_force),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(abst_siv[4:44]),
      .scout(abst_sov[4:44]),
      .din({pc_iu_abist_g8t_wenb, pc_iu_abist_g8t1p_renb_0, pc_iu_abist_di_0,
            pc_iu_abist_g8t_bw_1, pc_iu_abist_g8t_bw_0, pc_iu_abist_waddr_0,
            pc_iu_abist_wl128_comp_ena, pc_iu_abist_g8t_dcomp, pc_iu_abist_raddr_0,
            pc_iu_abist_g6t_bw, pc_iu_abist_di_g6t_2r, pc_iu_abist_wl512_comp_ena,
            pc_iu_abist_dcomp_g6t_2r, pc_iu_abist_g6t_r_wb}),
      .dout({stage_abist_g8t_wenb, stage_abist_g8t1p_renb_0, stage_abist_di_0,
             stage_abist_g8t_bw_1, stage_abist_g8t_bw_0, stage_abist_waddr_0,
             stage_abist_wl128_comp_ena, stage_abist_g8t_dcomp, stage_abist_raddr_0,
             stage_abist_g6t_bw, stage_abist_di_g6t_2r, stage_abist_wl512_comp_ena,
             stage_abist_dcomp_g6t_2r, stage_abist_g6t_r_wb})
   );

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv[0:scan_right] = {sov[1:scan_right], func_scan_in};
   assign func_scan_out = sov[0] & tc_ac_scan_dis_dc_b;
   // Chain 0: WAY01 IDIR & IDATA
   assign abst_siv[0:1] = {abst_sov[1], abst_scan_in[0]};
   assign abst_scan_out[0] = abst_sov[0] & tc_ac_scan_dis_dc_b;

   // Chain 1: WAY23 IDIR & IDATA
   assign abst_siv[2:3] = {abst_sov[3], abst_scan_in[1]};
   assign abst_scan_out[1] = abst_sov[2] & tc_ac_scan_dis_dc_b;

   // Chain 2: AB_REG - tack on to BHT's scan chain
   assign abst_siv[4:44] = {abst_sov[5:44], abst_scan_in[2]};
   assign abst_scan_out[2] = abst_sov[4] & tc_ac_scan_dis_dc_b;

   assign time_siv = {time_sov[1:1], time_scan_in};
   assign time_scan_out = time_sov[0] & tc_ac_scan_dis_dc_b;
   assign repr_siv = {repr_sov[1:1], repr_scan_in};
   assign repr_scan_out = repr_sov[0] & tc_ac_scan_dis_dc_b;

endmodule
