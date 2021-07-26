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
//* TITLE: Instruction Effective to Real Address Translation
//* NAME: iuq_ic_ierat.v
//*********************************************************************

`include "tri_a2o.vh"

module iuq_ic_ierat(
   // POWER PINS
   inout                             gnd,
   inout                             vdd,
   inout                             vcs,

   // CLOCK and CLOCKCONTROL ports
    (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]           nclk,
   input                             pc_iu_init_reset,
   input                             tc_ccflush_dc,
   input                             tc_scan_dis_dc_b,
   input                             tc_scan_diag_dc,
   input                             tc_lbist_en_dc,
   input                             an_ac_atpg_en_dc,
   input                             an_ac_grffence_en_dc,

   input                             lcb_d_mode_dc,
   input                             lcb_clkoff_dc_b,
   input                             lcb_act_dis_dc,
   input [0:1]                       lcb_mpw1_dc_b,
   input                             lcb_mpw2_dc_b,
   input [0:1]                       lcb_delay_lclkr_dc,

   input                             pc_iu_func_sl_thold_2,
   input                             pc_iu_func_slp_sl_thold_2,
   input                             pc_iu_func_slp_nsl_thold_2,
   input                             pc_iu_cfg_slp_sl_thold_2,
   input                             pc_iu_regf_slp_sl_thold_2,
   input                             pc_iu_time_sl_thold_2,
   input                             pc_iu_sg_2,
   input                             pc_iu_fce_2,

   input                             cam_clkoff_b,
   input                             cam_act_dis,
   input                             cam_d_mode,
   input [0:4]                       cam_delay_lclkr,
   input [0:4]                       cam_mpw1_b,
   input                             cam_mpw2_b,

    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:1]                       ac_func_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:1]                      ac_func_scan_out,
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                             ac_ccfg_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                            ac_ccfg_scan_out,
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                             func_scan_in_cam,          // unique to iu
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                            func_scan_out_cam,         // unique to iu
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                             time_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                            time_scan_out,
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:4]                       regf_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:4]                      regf_scan_out,

  // Functional ports
   // act control
   input                             spr_ic_clockgate_dis,
   // ttypes
   input                             iu_ierat_iu0_val,          // xu has 4 vals, no thdid
   input [0:`THREADS-1]              iu_ierat_iu0_thdid,
   input [0:51]                      iu_ierat_iu0_ifar,         // xu used GPR_WIDTH_ENC
   input                             iu_ierat_iu0_nonspec,
   input                             iu_ierat_iu0_prefetch,

   input [0:`THREADS-1]              iu_ierat_iu0_flush,
   input [0:`THREADS-1]              iu_ierat_iu1_flush,        // latched and is output below iu_mm_ierat_flush

   // ordered instructions
   input [0:`THREADS-1]              xu_iu_val,
   input                             xu_iu_is_eratre,
   input                             xu_iu_is_eratwe,
   input                             xu_iu_is_eratsx,
   input                             xu_iu_is_eratilx,
   input [0:1]                       xu_iu_ws,
   input [0:3]                       xu_iu_ra_entry,
   input [64-`GPR_WIDTH:63]          xu_iu_rs_data,             // eratwe
   input [64-`GPR_WIDTH:51]          xu_iu_rb,                  // eratsx
   output [64-`GPR_WIDTH:63]         iu_xu_ex4_data,            // eratre

   output                            iu_xu_ord_read_done,
   output                            iu_xu_ord_write_done,
   output                            iu_xu_ord_par_err,

   // context synchronizing event
   input                             cp_ic_is_isync,
   input                             cp_ic_is_csync,

   // reload from mmu
   input [0:4]                       mm_iu_ierat_rel_val,       // bit 4 is hit/miss
   input [0:131]                     mm_iu_ierat_rel_data,
   output [0:`THREADS-1]             ierat_iu_hold_req,

   // I$ snoop
   input                             iu_ierat_iu1_back_inv,
   input                             iu_ierat_ium1_back_inv,    // ???

   // tlbivax or tlbilx snoop
   input                             mm_iu_ierat_snoop_coming,
   input                             mm_iu_ierat_snoop_val,
   input [0:25]                      mm_iu_ierat_snoop_attr,
   input [0:51]                      mm_iu_ierat_snoop_vpn,
   output                            iu_mm_ierat_snoop_ack,

   // pipeline controls
   input [0:`THREADS-1]              xu_iu_flush,
   input [0:`THREADS-1]              br_iu_flush,
   // all tied to cp_flush
   input [0:`THREADS-1]              xu_rf1_flush,
   input [0:`THREADS-1]              xu_ex1_flush,
   input [0:`THREADS-1]              xu_ex2_flush,
   input [0:`THREADS-1]              xu_ex3_flush,
   input [0:`THREADS-1]              xu_ex4_flush,
   input [0:`THREADS-1]              xu_ex5_flush,

   // cam _np2 ports
   output [22:51]                    ierat_iu_iu2_rpn,
   output [0:4]                      ierat_iu_iu2_wimge,
   output [0:3]                      ierat_iu_iu2_u,            // wlc, attr, vf   not needed ?
   output                            ierat_iu_iu2_miss,
   output                            ierat_iu_iu2_isi,
   output [0:2]                      ierat_iu_iu2_error,
   output                            ierat_iu_iu2_multihit,

   output                            ierat_iu_cam_change,

   output                            iu_pc_err_ierat_multihit,
   output                            iu_pc_err_ierat_parity,

   // erat request to mmu
   output                            iu_mm_ierat_req,
   output                            iu_mm_ierat_req_nonspec,
   output [0:`THREADS-1]             iu_mm_ierat_thdid,
   output [0:3]                      iu_mm_ierat_state,
   output [0:13]                     iu_mm_ierat_tid,
   output [0:`THREADS-1]             iu_mm_ierat_flush,         // latched version of iu_mm_ierat_flush input above
                                                                // may not be needed,  MMU can tie to cp_flush
   // write interface to mmucr0,1
   output [0:17]                     iu_mm_ierat_mmucr0,
   output [0:`THREADS-1]             iu_mm_ierat_mmucr0_we,
   output [0:3]                      iu_mm_ierat_mmucr1,
   output [0:`THREADS-1]             iu_mm_ierat_mmucr1_we,
   output [0:`THREADS-1]             iu_mm_perf_itlb,

   // spr's
   input [0:`THREADS-1]              xu_iu_msr_hv,
   input [0:`THREADS-1]              xu_iu_msr_pr,
   input [0:`THREADS-1]              xu_iu_msr_is,
   input [0:`THREADS-1]              xu_iu_msr_cm,
   input                             xu_iu_hid_mmu_mode,
   input                             xu_iu_spr_ccr2_ifrat,
   input [0:8]                       xu_iu_spr_ccr2_ifratsc,
   input                             xu_iu_xucr4_mmu_mchk,

   output [0:`THREADS-1]             ierat_iu_iu2_flush_req,    // xu only had ex3_n_flush out
                                                                // local flush for timing
   output                            iu_xu_ord_n_flush_req,

   input [0:13]                      mm_iu_t0_ierat_pid,
   input [0:19]                      mm_iu_t0_ierat_mmucr0,
 `ifndef THREADS1
   input [0:13]                      mm_iu_t1_ierat_pid,
   input [0:19]                      mm_iu_t1_ierat_mmucr0,
 `endif
   input [0:8]                       mm_iu_ierat_mmucr1,

   // debug
   input                             pc_iu_trace_bus_enable,
   output [0:87]                     ierat_iu_debug_group0,
   output [0:87]                     ierat_iu_debug_group1,
   output [0:87]                     ierat_iu_debug_group2,
   output [0:87]                     ierat_iu_debug_group3
);

   //--------------------------
   // constants
   //--------------------------
   // Field/Signal sizes
   parameter                         ttype_width = 3;
   parameter                         state_width = 4;
   parameter                         pid_width = 14;
   parameter                         pid_width_erat = 8;
   parameter                         extclass_width = 2;
   parameter                         tlbsel_width = 2;
   parameter                         epn_width = 52;
   parameter                         vpn_width = 61;
   parameter                         rpn_width = 30;    // real_addr_width-12
   parameter                         ws_width = 2;
   parameter                         ra_entry_width = 4;
   parameter                         rs_data_width = 64;        // 32 or 64 for n-bit design (not cm mode)
   parameter                         data_out_width = 64;       // 32 or 64 for n-bit design (not cm mode)
   parameter                         error_width = 3;
   parameter                         cam_data_width = 84;
   parameter                         array_data_width = 68;     // 16x143 version
   parameter                         num_entry = 16;
   parameter                         num_entry_log2 = 4;
   parameter                         por_seq_width = 3;
   parameter                         watermark_width = 4;
   parameter                         eptr_width = 4;
   parameter                         lru_width = 15;
   parameter                         bcfg_width = 123;
   parameter                         check_parity = 1;                                          // 1=erat parity implemented in rtx

   parameter                         MMU_Mode_Value = 1'b0;
   parameter [0:1]                   TlbSel_Tlb   = 2'b00;
   parameter [0:1]                   TlbSel_IErat = 2'b10;
   parameter [0:1]                   TlbSel_DErat = 2'b11;

   parameter [0:2]                   CAM_PgSize_1GB  = 3'b110;
   parameter [0:2]                   CAM_PgSize_16MB = 3'b111;
   parameter [0:2]                   CAM_PgSize_1MB  = 3'b101;
   parameter [0:2]                   CAM_PgSize_64KB = 3'b011;
   parameter [0:2]                   CAM_PgSize_4KB  = 3'b001;
   parameter [0:3]                   WS0_PgSize_1GB  = 4'b1010;
   parameter [0:3]                   WS0_PgSize_16MB = 4'b0111;
   parameter [0:3]                   WS0_PgSize_1MB  = 4'b0101;
   parameter [0:3]                   WS0_PgSize_64KB = 4'b0011;
   parameter [0:3]                   WS0_PgSize_4KB  = 4'b0001;

   parameter                         eratpos_epn      = 0;
   parameter                         eratpos_x        = 52;
   parameter                         eratpos_size     = 53;
   parameter                         eratpos_v        = 56;
   parameter                         eratpos_thdid    = 57;
   parameter                         eratpos_class    = 61;
   parameter                         eratpos_extclass = 63;
   parameter                         eratpos_wren     = 65;
   parameter                         eratpos_rpnrsvd  = 66;
   parameter                         eratpos_rpn      = 70;
   parameter                         eratpos_r        = 100;
   parameter                         eratpos_c        = 101;
   parameter                         eratpos_relsoon  = 102;
   parameter                         eratpos_wlc      = 103;
   parameter                         eratpos_resvattr = 105;
   parameter                         eratpos_vf       = 106;
   parameter                         eratpos_ubits    = 107;
   parameter                         eratpos_wimge    = 111;
   parameter                         eratpos_usxwr    = 116;
   parameter                         eratpos_gs       = 122;
   parameter                         eratpos_ts       = 123;
   parameter                         eratpos_tid      = 124;  // 8 bits

   parameter [0:2]                   PorSeq_Idle = 3'b000;
   parameter [0:2]                   PorSeq_Stg1 = 3'b001;
   parameter [0:2]                   PorSeq_Stg2 = 3'b011;
   parameter [0:2]                   PorSeq_Stg3 = 3'b010;
   parameter [0:2]                   PorSeq_Stg4 = 3'b110;
   parameter [0:2]                   PorSeq_Stg5 = 3'b100;
   parameter [0:2]                   PorSeq_Stg6 = 3'b101;
   parameter [0:2]                   PorSeq_Stg7 = 3'b111;

   parameter [0:num_entry_log2-1]    Por_Wr_Entry_Num1 = 4'b1110;
   parameter [0:num_entry_log2-1]    Por_Wr_Entry_Num2 = 4'b1111;

   // wr_cam_data -----------------------------------------------------------------
   //  0:51   - EPN
   //  52     - X
   //  53:55  - SIZE
   //  56     - V
   //  57:60  - ThdID
   //  61:62  - Class
   //  63:64  - ExtClass | TID_NZ
   //  65     - TGS
   //  66     - TS
   //  67:74  - TID
   //  75:78  - epn_cmpmasks:  34_39, 40_43, 44_47, 48_51
   //  79:82  - xbit_cmpmasks: 34_51, 40_51, 44_51, 48_51
   //  83     - parity for 75:82

   parameter [0:83]     Por_Wr_Cam_Data1 = {52'b0000000000000000000000000000000011111111111111111111, 1'b0, 3'b001, 1'b1, 4'b1111, 2'b00, 2'b00, 2'b00, 8'b00000000, 8'b11110000, 1'b0};
   parameter [0:83]     Por_Wr_Cam_Data2 = {52'b0000000000000000000000000000000000000000000000000000, 1'b0, 3'b001, 1'b1, 4'b1111, 2'b00, 2'b10, 2'b00, 8'b00000000, 8'b11110000, 1'b0};

   // 16x143 version, 42b RA
   // wr_array_data
   //  0:29  - RPN
   //  30:31  - R,C
   //  32:33  - WLC
   //  34     - ResvAttr
   //  35     - VF
   //  36:39  - U0-U3
   //  40:44  - WIMGE
   //  45:47  - UX,UW,UR
   //  48:50  - SX,SW,SR
   //  45:46  - UX,SX
   //  47:48  - UW,SW
   //  49:50  - UR,SR
   //  51:60  - CAM parity
   //  61:67  - Array parity

   parameter [0:67]     Por_Wr_Array_Data1 = {30'b111111111111111111111111111111, 2'b00, 4'b0000, 4'b0000, 5'b01010, 2'b01, 2'b00, 2'b01, 10'b0000001000, 7'b0000000};
   parameter [0:67]     Por_Wr_Array_Data2 = {30'b000000000000000000000000000000, 2'b00, 4'b0000, 4'b0000, 5'b01010, 2'b01, 2'b00, 2'b01, 10'b0000001010, 7'b0000000};

   parameter                         ex1_valid_offset = 0;
   parameter                         ex1_ttype_offset = ex1_valid_offset + `THREADS;
   parameter                         ex1_ws_offset = ex1_ttype_offset + ttype_width;
   parameter                         ex1_ra_entry_offset = ex1_ws_offset + ws_width;
   parameter                         ex1_state_offset = ex1_ra_entry_offset + ra_entry_width;
   parameter                         ex1_pid_offset = ex1_state_offset + state_width;
   parameter                         ex1_extclass_offset = ex1_pid_offset + pid_width;
   parameter                         ex1_tlbsel_offset = ex1_extclass_offset + extclass_width;

   parameter                         ex2_valid_offset = ex1_tlbsel_offset + tlbsel_width;
   parameter                         ex2_ttype_offset = ex2_valid_offset + `THREADS;
   parameter                         ex2_ws_offset = ex2_ttype_offset + ttype_width;
   parameter                         ex2_ra_entry_offset = ex2_ws_offset + ws_width;
   parameter                         ex2_state_offset = ex2_ra_entry_offset + ra_entry_width;
   parameter                         ex2_pid_offset = ex2_state_offset + state_width;
   parameter                         ex2_extclass_offset = ex2_pid_offset + pid_width;
   parameter                         ex2_tlbsel_offset = ex2_extclass_offset + extclass_width;

   parameter                         ex3_valid_offset = ex2_tlbsel_offset + tlbsel_width;
   parameter                         ex3_ttype_offset = ex3_valid_offset + `THREADS;
   parameter                         ex3_ws_offset = ex3_ttype_offset + ttype_width;
   parameter                         ex3_ra_entry_offset = ex3_ws_offset + ws_width;
   parameter                         ex3_state_offset = ex3_ra_entry_offset + ra_entry_width;
   parameter                         ex3_pid_offset = ex3_state_offset + state_width;
   parameter                         ex3_extclass_offset = ex3_pid_offset + pid_width;
   parameter                         ex3_tlbsel_offset = ex3_extclass_offset + extclass_width;
   parameter                         ex3_eratsx_data_offset = ex3_tlbsel_offset + tlbsel_width;

   parameter                         ex4_valid_offset = ex3_eratsx_data_offset + 2 + num_entry_log2;
   parameter                         ex4_ttype_offset = ex4_valid_offset + `THREADS;
   parameter                         ex4_ws_offset = ex4_ttype_offset + ttype_width;
   parameter                         ex4_ra_entry_offset = ex4_ws_offset + ws_width;
   parameter                         ex4_state_offset = ex4_ra_entry_offset + ra_entry_width;
   parameter                         ex4_pid_offset = ex4_state_offset + state_width;
   parameter                         ex4_extclass_offset = ex4_pid_offset + pid_width;
   parameter                         ex4_tlbsel_offset = ex4_extclass_offset + extclass_width;
   parameter                         ex4_data_out_offset = ex4_tlbsel_offset + tlbsel_width;

   parameter                         ex5_valid_offset = ex4_data_out_offset + data_out_width;
   parameter                         ex5_ttype_offset = ex5_valid_offset + `THREADS;
   parameter                         ex5_ws_offset = ex5_ttype_offset + ttype_width;
   parameter                         ex5_ra_entry_offset = ex5_ws_offset + ws_width;
   parameter                         ex5_state_offset = ex5_ra_entry_offset + ra_entry_width;
   parameter                         ex5_pid_offset = ex5_state_offset + state_width;
   parameter                         ex5_extclass_offset = ex5_pid_offset + pid_width;
   parameter                         ex5_tlbsel_offset = ex5_extclass_offset + extclass_width;
   parameter                         ex5_data_in_offset = ex5_tlbsel_offset + tlbsel_width;

   parameter                         ex6_valid_offset = ex5_data_in_offset + rs_data_width;
   parameter                         ex6_ttype_offset = ex6_valid_offset + `THREADS;
   parameter                         ex6_ws_offset = ex6_ttype_offset + ttype_width;
   parameter                         ex6_ra_entry_offset = ex6_ws_offset + ws_width;
   parameter                         ex6_state_offset = ex6_ra_entry_offset + ra_entry_width;
   parameter                         ex6_pid_offset = ex6_state_offset + state_width;
   parameter                         ex6_extclass_offset = ex6_pid_offset + pid_width;
   parameter                         ex6_tlbsel_offset = ex6_extclass_offset + extclass_width;
   parameter                         ex6_data_in_offset = ex6_tlbsel_offset + tlbsel_width;

   parameter                         iu1_flush_enab_offset = ex6_data_in_offset + rs_data_width;
   parameter                         iu2_n_flush_req_offset = iu1_flush_enab_offset + 1;
   parameter                         hold_req_offset = iu2_n_flush_req_offset + `THREADS;
   parameter                         tlb_miss_offset = hold_req_offset + `THREADS;
   parameter                         tlb_flushed_offset = tlb_miss_offset + `THREADS;
   parameter                         tlb_req_inprogress_offset = tlb_flushed_offset + `THREADS;
   parameter                         iu1_valid_offset = tlb_req_inprogress_offset + `THREADS;
   parameter                         iu1_state_offset = iu1_valid_offset + `THREADS;
   parameter                         iu1_pid_offset = iu1_state_offset + state_width;
   parameter                         iu1_nonspec_offset = iu1_pid_offset + pid_width;
   parameter                         iu1_prefetch_offset = iu1_nonspec_offset + 1;
   parameter                         iu2_prefetch_offset = iu1_prefetch_offset + 1;
   parameter                         iu2_valid_offset = iu2_prefetch_offset + 1;
   parameter                         iu2_state_offset = iu2_valid_offset + `THREADS;
   parameter                         iu2_pid_offset = iu2_state_offset + state_width;
   parameter                         iu2_nonspec_offset = iu2_pid_offset + pid_width;
   parameter                         iu2_miss_offset = iu2_nonspec_offset + 1;
   parameter                         iu2_multihit_offset = iu2_miss_offset + 2;
   parameter                         iu2_parerr_offset = iu2_multihit_offset + 2;
   parameter                         iu2_isi_offset = iu2_parerr_offset + 2;
   parameter                         iu2_tlbreq_offset = iu2_isi_offset + 6;
   parameter                         iu2_perf_itlb_offset = iu2_tlbreq_offset + 1;
   parameter                         iu2_multihit_b_pt_offset = iu2_perf_itlb_offset + `THREADS;
   parameter                         iu2_first_hit_entry_pt_offset = iu2_multihit_b_pt_offset + num_entry;
   parameter                         iu2_cam_cmp_data_offset = iu2_first_hit_entry_pt_offset + num_entry - 1;
   parameter                         iu2_array_cmp_data_offset = iu2_cam_cmp_data_offset + cam_data_width;
   parameter                         ex4_rd_cam_data_offset = iu2_array_cmp_data_offset + array_data_width;
   parameter                         ex4_rd_array_data_offset = ex4_rd_cam_data_offset + cam_data_width;
   parameter                         ex3_parerr_offset = ex4_rd_array_data_offset + array_data_width;
   parameter                         ex4_parerr_offset = ex3_parerr_offset + `THREADS + 1;
   parameter                         ex4_ieen_offset = ex4_parerr_offset + `THREADS + 3;
   parameter                         ex5_ieen_offset = ex4_ieen_offset + `THREADS + num_entry_log2;
   parameter                         ex6_ieen_offset = ex5_ieen_offset + `THREADS + num_entry_log2;
   parameter                         mmucr1_offset = ex6_ieen_offset + `THREADS + num_entry_log2;
   parameter                         rpn_holdreg_offset = mmucr1_offset + 9;
   parameter                         entry_valid_offset = rpn_holdreg_offset + 64 * `THREADS;
   parameter                         entry_match_offset = entry_valid_offset + 16;
   parameter                         watermark_offset = entry_match_offset + 16;
   parameter                         eptr_offset = watermark_offset + watermark_width;
   parameter                         lru_offset = eptr_offset + eptr_width;
   parameter                         lru_update_event_offset = lru_offset + lru_width;
   parameter                         lru_debug_offset = lru_update_event_offset + 10;
   parameter                         iu_xu_ord_write_done_offset = lru_debug_offset + 24;
   parameter                         iu_xu_ord_read_done_offset = iu_xu_ord_write_done_offset + 1;
   parameter                         iu_xu_ord_par_err_offset = iu_xu_ord_read_done_offset + 1;
   parameter                         cp_ic_csinv_comp_offset = iu_xu_ord_par_err_offset + 1;
   parameter                         scan_right_0 = cp_ic_csinv_comp_offset + 4 - 1;
   // NOTE:  scan_right_0 is maxed out! use scan_right_1 chain for new additions!

   parameter                         snoop_val_offset = 0;
   parameter                         spare_a_offset = snoop_val_offset + 3;
   parameter                         snoop_attr_offset = spare_a_offset + 16;
   parameter                         snoop_addr_offset = snoop_attr_offset + 26;
   parameter                         spare_b_offset = snoop_addr_offset + epn_width;
   parameter                         por_seq_offset = spare_b_offset + 16;
   parameter                         tlb_rel_val_offset = por_seq_offset + 3;
   parameter                         tlb_rel_data_offset = tlb_rel_val_offset + 5;
   parameter                         iu_mm_ierat_flush_offset = tlb_rel_data_offset + 132;
   parameter                         iu_xu_ierat_ex2_flush_offset = iu_mm_ierat_flush_offset + `THREADS;
   parameter                         ccr2_frat_paranoia_offset = iu_xu_ierat_ex2_flush_offset + `THREADS;
   parameter                         ccr2_notlb_offset = ccr2_frat_paranoia_offset + 10;
   parameter                         xucr4_mmu_mchk_offset = ccr2_notlb_offset + 1;
   parameter                         mchk_flash_inv_offset = xucr4_mmu_mchk_offset + 1;
   parameter                         ex7_valid_offset = mchk_flash_inv_offset + 4;
   parameter                         ex7_ttype_offset = ex7_valid_offset + `THREADS;
   parameter                         ex7_tlbsel_offset = ex7_ttype_offset + ttype_width;
   parameter                         iu1_debug_offset = ex7_tlbsel_offset + 2;
   parameter                         iu2_debug_offset = iu1_debug_offset + 11;

   parameter                         iu1_stg_act_offset = iu2_debug_offset + 17;
   parameter                         iu2_stg_act_offset = iu1_stg_act_offset + 1;
   parameter                         iu3_stg_act_offset = iu2_stg_act_offset + 1;
   parameter                         ex1_stg_act_offset = iu3_stg_act_offset + 1;
   parameter                         ex2_stg_act_offset = ex1_stg_act_offset + 1;
   parameter                         ex3_stg_act_offset = ex2_stg_act_offset + 1;
   parameter                         ex4_stg_act_offset = ex3_stg_act_offset + 1;
   parameter                         ex5_stg_act_offset = ex4_stg_act_offset + 1;
   parameter                         ex6_stg_act_offset = ex5_stg_act_offset + 1;
   parameter                         ex7_stg_act_offset = ex6_stg_act_offset + 1;
   parameter                         tlb_rel_act_offset = ex7_stg_act_offset + 1;
   parameter                         snoop_act_offset = tlb_rel_act_offset + 1;
   parameter                         iu_pc_err_ierat_multihit_offset = snoop_act_offset + 1;
   parameter                         iu_pc_err_ierat_parity_offset = iu_pc_err_ierat_multihit_offset + 1;
   parameter                         trace_bus_enable_offset = iu_pc_err_ierat_parity_offset + 1;
   parameter                         an_ac_grffence_en_dc_offset = trace_bus_enable_offset + 1;
   parameter                         scan_right_1 = an_ac_grffence_en_dc_offset + 1 - 1;

   parameter                         bcfg_offset = 0;
   parameter                         boot_scan_right = bcfg_offset + bcfg_width - 1;

   //--------------------------
   // signals
   //--------------------------
   //@@  Signal Declarations
   wire [1:19]                       cam_mask_bits_pt;
   wire [1:15]                       iu1_first_hit_entry_pt;
   wire [1:16]                       iu1_multihit_b_pt;
   wire [1:17]                       lru_rmt_vec_pt;
   wire [1:80]                       lru_set_reset_vec_pt;
   wire [1:15]                       lru_watermark_mask_pt;
   wire [1:15]                       lru_way_encode_pt;


   // Latch signals
   wire [0:`THREADS-1]               ex1_valid_d;
   wire [0:`THREADS-1]               ex1_valid_q;
   wire [0:ttype_width-1]            ex1_ttype_d;
   wire [0:ttype_width-1]            ex1_ttype_q;
   wire [0:ws_width-1]               ex1_ws_d;
   wire [0:ws_width-1]               ex1_ws_q;
   wire [0:ra_entry_width-1]         ex1_ra_entry_d;
   wire [0:ra_entry_width-1]         ex1_ra_entry_q;
   wire [0:state_width-1]            ex1_state_d;
   wire [0:state_width-1]            ex1_state_q;
   wire [0:pid_width-1]              ex1_pid_d;
   wire [0:pid_width-1]              ex1_pid_q;
   reg [0:extclass_width-1]          ex1_extclass_d;
   wire [0:extclass_width-1]         ex1_extclass_q;
   reg [0:tlbsel_width-1]            ex1_tlbsel_d;
   wire [0:tlbsel_width-1]           ex1_tlbsel_q;

   wire [0:`THREADS-1]               ex2_valid_d;
   wire [0:`THREADS-1]               ex2_valid_q;
   wire [0:ttype_width-1]            ex2_ttype_d;
   wire [0:ttype_width-1]            ex2_ttype_q;
   wire [0:ws_width-1]               ex2_ws_d;
   wire [0:ws_width-1]               ex2_ws_q;
   wire [0:ra_entry_width-1]         ex2_ra_entry_d;
   wire [0:ra_entry_width-1]         ex2_ra_entry_q;
   wire [0:state_width-1]            ex2_state_d;
   wire [0:state_width-1]            ex2_state_q;
   wire [0:pid_width-1]              ex2_pid_d;
   wire [0:pid_width-1]              ex2_pid_q;
   wire [0:extclass_width-1]         ex2_extclass_d;
   wire [0:extclass_width-1]         ex2_extclass_q;
   wire [0:tlbsel_width-1]           ex2_tlbsel_d;
   wire [0:tlbsel_width-1]           ex2_tlbsel_q;

   wire [0:`THREADS-1]               ex3_valid_d;
   wire [0:`THREADS-1]               ex3_valid_q;
   wire [0:ttype_width-1]            ex3_ttype_d;
   wire [0:ttype_width-1]            ex3_ttype_q;
   wire [0:ws_width-1]               ex3_ws_d;
   wire [0:ws_width-1]               ex3_ws_q;
   wire [0:ra_entry_width-1]         ex3_ra_entry_d;
   wire [0:ra_entry_width-1]         ex3_ra_entry_q;
   wire [0:state_width-1]            ex3_state_d;
   wire [0:state_width-1]            ex3_state_q;
   wire [0:pid_width-1]              ex3_pid_d;
   wire [0:pid_width-1]              ex3_pid_q;
   wire [0:extclass_width-1]         ex3_extclass_d;
   wire [0:extclass_width-1]         ex3_extclass_q;
   wire [0:tlbsel_width-1]           ex3_tlbsel_d;
   wire [0:tlbsel_width-1]           ex3_tlbsel_q;
   wire [0:2+num_entry_log2-1]       ex3_eratsx_data_d;
   wire [0:2+num_entry_log2-1]       ex3_eratsx_data_q;

   wire [0:`THREADS-1]               ex4_valid_d;
   wire [0:`THREADS-1]               ex4_valid_q;
   wire [0:ttype_width-1]            ex4_ttype_d;
   wire [0:ttype_width-1]            ex4_ttype_q;
   wire [0:ws_width-1]               ex4_ws_d;
   wire [0:ws_width-1]               ex4_ws_q;
   wire [0:ra_entry_width-1]         ex4_ra_entry_d;
   wire [0:ra_entry_width-1]         ex4_ra_entry_q;
   wire [0:state_width-1]            ex4_state_d;
   wire [0:state_width-1]            ex4_state_q;
   wire [0:pid_width-1]              ex4_pid_d;
   wire [0:pid_width-1]              ex4_pid_q;
   wire [0:extclass_width-1]         ex4_extclass_d;
   wire [0:extclass_width-1]         ex4_extclass_q;
   wire [0:tlbsel_width-1]           ex4_tlbsel_d;
   wire [0:tlbsel_width-1]           ex4_tlbsel_q;
   wire [64-data_out_width:63]       ex4_data_out_d;
   wire [64-data_out_width:63]       ex4_data_out_q;

   wire [0:`THREADS-1]               ex5_valid_d;
   wire [0:`THREADS-1]               ex5_valid_q;
   wire [0:ttype_width-1]            ex5_ttype_d;
   wire [0:ttype_width-1]            ex5_ttype_q;
   wire [0:ws_width-1]               ex5_ws_d;
   wire [0:ws_width-1]               ex5_ws_q;
   wire [0:ra_entry_width-1]         ex5_ra_entry_d;
   wire [0:ra_entry_width-1]         ex5_ra_entry_q;
   wire [0:state_width-1]            ex5_state_d;
   wire [0:state_width-1]            ex5_state_q;
   wire [0:pid_width-1]              ex5_pid_d;
   wire [0:pid_width-1]              ex5_pid_q;
   wire [0:extclass_width-1]         ex5_extclass_d;
   wire [0:extclass_width-1]         ex5_extclass_q;
   wire [0:tlbsel_width-1]           ex5_tlbsel_d;
   wire [0:tlbsel_width-1]           ex5_tlbsel_q;
   wire [64-rs_data_width:63]        ex5_data_in_d;
   wire [64-rs_data_width:63]        ex5_data_in_q;

   wire [0:`THREADS-1]               ex6_valid_d;
   wire [0:`THREADS-1]               ex6_valid_q;
   wire [0:ttype_width-1]            ex6_ttype_d;
   wire [0:ttype_width-1]            ex6_ttype_q;
   wire [0:ws_width-1]               ex6_ws_d;
   wire [0:ws_width-1]               ex6_ws_q;
   wire [0:ra_entry_width-1]         ex6_ra_entry_d;
   wire [0:ra_entry_width-1]         ex6_ra_entry_q;
   reg [0:state_width-1]             ex6_state_d;
   wire [0:state_width-1]            ex6_state_q;
   reg [0:pid_width-1]               ex6_pid_d;
   wire [0:pid_width-1]              ex6_pid_q;
   reg [0:extclass_width-1]          ex6_extclass_d;
   wire [0:extclass_width-1]         ex6_extclass_q;
   reg [0:tlbsel_width-1]            ex6_tlbsel_d;
   wire [0:tlbsel_width-1]           ex6_tlbsel_q;
   wire [64-rs_data_width:63]        ex6_data_in_d;
   wire [64-rs_data_width:63]        ex6_data_in_q;

   wire [0:`THREADS-1]               ex7_valid_d;
   wire [0:`THREADS-1]               ex7_valid_q;
   wire [0:ttype_width-1]            ex7_ttype_d;
   wire [0:ttype_width-1]            ex7_ttype_q;
   wire [0:tlbsel_width-1]           ex7_tlbsel_d;
   wire [0:tlbsel_width-1]           ex7_tlbsel_q;

   wire [0:`THREADS-1]               iu1_valid_d;
   wire [0:`THREADS-1]               iu1_valid_q;
   wire [0:state_width-1]            iu1_state_d;
   wire [0:state_width-1]            iu1_state_q;
   reg [0:pid_width-1]               iu1_pid_d;
   wire [0:pid_width-1]              iu1_pid_q;
   wire [0:`THREADS-1]               iu2_valid_d;
   wire [0:`THREADS-1]               iu2_valid_q;
   wire [0:`THREADS-1]               iu2_perf_itlb_d, iu2_perf_itlb_q;
   wire [0:state_width-1]            iu2_state_d;
   wire [0:state_width-1]            iu2_state_q;
   wire [0:pid_width-1]              iu2_pid_d;
   wire [0:pid_width-1]              iu2_pid_q;
   wire                              iu1_prefetch_d;
   wire                              iu1_prefetch_q;
   wire                              iu2_prefetch_d;
   wire                              iu2_prefetch_q;
   wire                              iu1_nonspec_d;
   wire                              iu1_nonspec_q;
   wire                              iu2_nonspec_d;
   wire                              iu2_nonspec_q;

    (* NO_MODIFICATION="TRUE" *)
   wire                              iu1_flush_enab_d;
   wire                              iu1_flush_enab_q;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:`THREADS-1]               iu2_n_flush_req_d;
   wire [0:`THREADS-1]               iu2_n_flush_req_q;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:`THREADS-1]               hold_req_d;
   wire [0:`THREADS-1]               hold_req_q;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:`THREADS-1]               tlb_miss_d;
   wire [0:`THREADS-1]               tlb_miss_q;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:`THREADS-1]               tlb_flushed_d;
   wire [0:`THREADS-1]               tlb_flushed_q;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:`THREADS-1]               tlb_req_inprogress_d;
   wire [0:`THREADS-1]               tlb_req_inprogress_q;

    (* NO_MODIFICATION="TRUE" *)
   wire                              iu2_tlbreq_d;
   wire                              iu2_tlbreq_q;
   wire [0:1]                        iu2_miss_d;
   wire [0:1]                        iu2_miss_q;
   wire [0:1]                        iu2_multihit_d;
   wire [0:1]                        iu2_multihit_q;
   wire [0:1]                        iu2_parerr_d;
   wire [0:1]                        iu2_parerr_q;
   wire [0:5]                        iu2_isi_d;
   wire [0:5]                        iu2_isi_q;
   wire [0:10]                       iu1_debug_d;
   wire [0:10]                       iu1_debug_q;
   wire [0:16]                       iu2_debug_d;
   wire [0:16]                       iu2_debug_q;

   wire [1:num_entry]                iu2_multihit_b_pt_d;
   wire [1:num_entry]                iu2_multihit_b_pt_q;
   wire [1:num_entry-1]              iu2_first_hit_entry_pt_d;
   wire [1:num_entry-1]              iu2_first_hit_entry_pt_q;
   wire [0:cam_data_width-1]         iu2_cam_cmp_data_d;
   wire [0:cam_data_width-1]         iu2_cam_cmp_data_q;
   wire [0:array_data_width-1]       iu2_array_cmp_data_d;
   wire [0:array_data_width-1]       iu2_array_cmp_data_q;

   wire [0:cam_data_width-1]         ex4_rd_cam_data_d;
   wire [0:cam_data_width-1]         ex4_rd_cam_data_q;
   wire [0:array_data_width-1]       ex4_rd_array_data_d;
   wire [0:array_data_width-1]       ex4_rd_array_data_q;

   reg [0:2]                         por_seq_d;
   wire [0:2]                        por_seq_q;

   wire [0:`THREADS]                 ex3_parerr_d;
   wire [0:`THREADS]                 ex3_parerr_q;
   wire [0:`THREADS+2]               ex4_parerr_d;
   wire [0:`THREADS+2]               ex4_parerr_q;

   wire [0:`THREADS+num_entry_log2-1] ex4_ieen_d;
   wire [0:`THREADS+num_entry_log2-1] ex4_ieen_q;
   wire [0:`THREADS+num_entry_log2-1] ex5_ieen_d;
   wire [0:`THREADS+num_entry_log2-1] ex5_ieen_q;
   wire [0:`THREADS+num_entry_log2-1] ex6_ieen_d;
   wire [0:`THREADS+num_entry_log2-1] ex6_ieen_q;
   wire [0:8]                        mmucr1_d;
   wire [0:8]                        mmucr1_q;

   wire [0:63]                       rpn_holdreg_d[0:`THREADS-1];
   wire [0:63]                       rpn_holdreg_q[0:`THREADS-1];
   reg [0:63]                        ex6_rpn_holdreg;

   wire [0:watermark_width-1]        watermark_d;
   wire [0:watermark_width-1]        watermark_q;
   wire [0:eptr_width-1]             eptr_d;
   wire [0:eptr_width-1]             eptr_q;
   wire [1:lru_width]                lru_d;
   wire [1:lru_width]                lru_q;
   wire [0:9]                        lru_update_event_d;
   wire [0:9]                        lru_update_event_q;
   wire [0:23]                       lru_debug_d;
   wire [0:23]                       lru_debug_q;

   wire [0:2]                        snoop_val_d;
   wire [0:2]                        snoop_val_q;
   wire [0:25]                       snoop_attr_d;
   wire [0:25]                       snoop_attr_q;
   wire [52-epn_width:51]            snoop_addr_d;
   wire [52-epn_width:51]            snoop_addr_q;

   wire [0:4]                        tlb_rel_val_d;     // bit 4 is hit/miss
   wire [0:4]                        tlb_rel_val_q;
   wire [0:131]                      tlb_rel_data_d;    // bit 65 is write enab
   wire [0:131]                      tlb_rel_data_q;
   wire [0:`THREADS-1]               iu_mm_ierat_flush_d;       // flush for ierat requests to mmu
   wire [0:`THREADS-1]               iu_mm_ierat_flush_q;
   wire [0:`THREADS-1]               iu_xu_ierat_ex2_flush_d;   // flush for eratsx collision with I$ back_inv
   wire [0:`THREADS-1]               iu_xu_ierat_ex2_flush_q;
   wire [0:9]                        ccr2_frat_paranoia_d;      // bit9=enable, force ra=ea bypass
   wire [0:9]                        ccr2_frat_paranoia_q;
   wire                              ccr2_notlb_q;
   wire                              xucr4_mmu_mchk_q;
   wire [0:3]                        mchk_flash_inv_d;
   wire [0:3]                        mchk_flash_inv_q;
   wire                              mchk_flash_inv_enab;

   wire [0:31]                       spare_q;

   wire [0:bcfg_width-1]             bcfg_q;            // boot config ring values
   wire [0:bcfg_width-1]             bcfg_q_b;

   // logic signals
    (* NO_MODIFICATION="TRUE" *)
   wire                              iu2_isi_sig;
    (* NO_MODIFICATION="TRUE" *)
   wire                              iu2_miss_sig;
    (* NO_MODIFICATION="TRUE" *)
   wire                              iu2_parerr_sig;
    (* NO_MODIFICATION="TRUE" *)
   wire                              iu2_multihit_sig;
    (* NO_MODIFICATION="TRUE" *)
   wire                              iu1_multihit;
    (* NO_MODIFICATION="TRUE" *)
   wire                              iu1_multihit_b;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:num_entry_log2-1]         iu1_first_hit_entry;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:num_entry_log2-1]         iu2_first_hit_entry;
    (* NO_MODIFICATION="TRUE" *)
   wire                              iu2_multihit_enab;
    (* NO_MODIFICATION="TRUE" *)
   reg [0:1]                         por_wr_cam_val;
    (* NO_MODIFICATION="TRUE" *)
   reg [0:1]                         por_wr_array_val;
    (* NO_MODIFICATION="TRUE" *)
   reg [0:cam_data_width-1]          por_wr_cam_data;
    (* NO_MODIFICATION="TRUE" *)
   reg [0:array_data_width-1]        por_wr_array_data;
    (* NO_MODIFICATION="TRUE" *)
   reg [0:num_entry_log2-1]          por_wr_entry;
    (* NO_MODIFICATION="TRUE" *)
   reg [0:`THREADS-1]                por_hold_req;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:num_entry_log2-1]         lru_way_encode;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:lru_width]                lru_rmt_vec;
    (* NO_MODIFICATION="TRUE" *)
   wire [1:lru_width]                lru_reset_vec;
    (* NO_MODIFICATION="TRUE" *)
   wire [1:lru_width]                lru_set_vec;
   wire [1:lru_width]                lru_op_vec;
   wire [1:lru_width]                lru_vp_vec;
    (* NO_MODIFICATION="TRUE" *)
   wire [1:lru_width]                lru_eff;
   wire [0:lru_width]                lru_watermark_mask;
   wire [0:lru_width]                entry_valid_watermarked;

   wire [0:eptr_width-1]             eptr_p1;
   wire                              ex1_ieratre;
   wire                              ex1_ieratwe;
   wire                              ex1_ieratsx;
   wire                              ex3_parerr_enab;
   wire                              ex4_parerr_enab;
   wire                              ex3_ieratwe;
   wire                              ex4_ieratwe;
   wire                              ex5_ieratwe;
   wire                              ex6_ieratwe;
   wire                              ex7_ieratwe;
   wire                              ex5_ieratwe_ws0;
   wire                              ex6_ieratwe_ws3;

   (* NO_MODIFICATION="TRUE" *)
   wire [50:67]                      iu2_cmp_data_calc_par;   // bit 50 is cmp/x mask parity on epn side

    (* NO_MODIFICATION="TRUE" *)
   wire                              iu2_cmp_data_parerr_epn;
    (* NO_MODIFICATION="TRUE" *)
   wire                              iu2_cmp_data_parerr_rpn;
    (* NO_MODIFICATION="TRUE" *)
   wire [50:67]                      ex4_rd_data_calc_par;    // bit 50 is cmp/x mask parity on epn side
    (* NO_MODIFICATION="TRUE" *)
   wire                              ex4_rd_data_parerr_epn;
    (* NO_MODIFICATION="TRUE" *)
   wire                              ex4_rd_data_parerr_rpn;

    (* analysis_not_referenced="true" *)
   wire [0:29]                       unused_dc;


   wire [0:19]                       ierat_mmucr0[0:`THREADS-1];
   wire [0:`THREADS-1]               mmucr0_gs_vec;
   wire [0:`THREADS-1]               mmucr0_ts_vec;
   wire [0:13]                       ierat_pid[0:`THREADS-1];

   wire [0:3]                        tlb_rel_cmpmask;
   wire [0:3]                        tlb_rel_xbitmask;
   wire                              tlb_rel_maskpar;
   wire [0:3]                        ex6_data_cmpmask;
   wire [0:3]                        ex6_data_xbitmask;
   wire                              ex6_data_maskpar;

   wire [0:51]                       comp_addr_mux1;
   wire                              comp_addr_mux1_sel;
   wire                              lru_way_is_written;
   wire                              lru_way_is_hit_entry;

   // Added for timing changes
   reg [0:pid_width-1]               ex1_pid_0;
   reg [0:pid_width-1]               ex1_pid_1;


   // CAM/Array signals
   // Read Port
    (* NO_MODIFICATION="TRUE" *)
   wire                              rd_val;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:3]                        rw_entry;
   // Write Port
    (* NO_MODIFICATION="TRUE" *)
   wire [51:67]                      wr_array_par;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:array_data_width-1-10-7]  wr_array_data_nopar;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:array_data_width-1]       wr_array_data;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:cam_data_width-1]         wr_cam_data;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:1]                        wr_array_val;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:1]                        wr_cam_val;
    (* NO_MODIFICATION="TRUE" *)
   wire                              wr_val_early;  // act pin for write port
   // CAM Port
    (* NO_MODIFICATION="TRUE" *)
   wire                              comp_request;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:51]                       comp_addr;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:1]                        addr_enable;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:2]                        comp_pgsize;
    (* NO_MODIFICATION="TRUE" *)
   wire                              pgsize_enable;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:1]                        comp_class;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:2]                        class_enable;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:1]                        comp_extclass;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:1]                        extclass_enable;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:1]                        comp_state;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:1]                        state_enable;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:3]                        comp_thdid;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:1]                        thdid_enable;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:7]                        comp_pid;
    (* NO_MODIFICATION="TRUE" *)
   wire                              pid_enable;
    (* NO_MODIFICATION="TRUE" *)
   wire                              comp_invalidate;
    (* NO_MODIFICATION="TRUE" *)
   wire                              flash_invalidate;
   // Array Outputs
    (* NO_MODIFICATION="TRUE" *)
   wire [0:array_data_width-1]       array_cmp_data;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:array_data_width-1]       rd_array_data;
   // CAM Outputs
    (* NO_MODIFICATION="TRUE" *)
   wire [0:cam_data_width-1]         cam_cmp_data;
    (* NO_MODIFICATION="TRUE" *)
   wire                              cam_hit;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:3]                        cam_hit_entry;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:15]                       entry_match;
   wire [0:15]                       entry_match_q;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:15]                       entry_valid;
   wire [0:15]                       entry_valid_q;
    (* NO_MODIFICATION="TRUE" *)
   wire [0:cam_data_width-1]         rd_cam_data;


   wire [0:2]                        cam_pgsize;
   wire [0:3]                        ws0_pgsize;

   // new cam _np2 signals
   wire                              bypass_mux_enab_np1;
   wire [0:20]                       bypass_attr_np1;
   wire [0:20]                       attr_np2;
   wire [22:51]                      rpn_np2;

   // Pervasive
   wire                              pc_sg_1;
   wire                              pc_sg_0;
   wire                              pc_func_sl_thold_1;
   wire                              pc_func_sl_thold_0;
   wire                              pc_func_sl_thold_0_b;
   wire                              pc_func_slp_sl_thold_1;
   wire                              pc_func_slp_sl_thold_0;
   wire                              pc_func_slp_sl_thold_0_b;
   wire                              pc_func_sl_force;
   wire                              pc_func_slp_sl_force;
   wire                              pc_cfg_slp_sl_thold_1;
   wire                              pc_cfg_slp_sl_thold_0;
   wire                              pc_cfg_slp_sl_thold_0_b;
   wire                              pc_cfg_slp_sl_force;
   wire                              lcb_dclk;
   wire [0:`NCLK_WIDTH-1]            lcb_lclk;
   wire                              init_alias;

  // Clock Gating
   wire                              iu1_stg_act_d;
   wire                              iu1_stg_act_q;
   wire                              iu2_stg_act_d;
   wire                              iu2_stg_act_q;
   wire                              iu3_stg_act_d;
   wire                              iu3_stg_act_q;
   wire                              ex1_stg_act_d;
   wire                              ex1_stg_act_q;
   wire                              ex2_stg_act_d;
   wire                              ex2_stg_act_q;
   wire                              ex3_stg_act_d;
   wire                              ex3_stg_act_q;
   wire                              ex4_stg_act_d;
   wire                              ex4_stg_act_q;
   wire                              ex5_stg_act_d;
   wire                              ex5_stg_act_q;
   wire                              ex6_stg_act_d;
   wire                              ex6_stg_act_q;
   wire                              ex7_stg_act_d;
   wire                              ex7_stg_act_q;
   wire                              iu1_cmp_data_act;
   wire                              iu1_grffence_act;
   wire                              iu1_or_iu2_grffence_act;
   wire                              iu2_or_iu3_grffence_act;
   wire                              ex3_rd_data_act;
   wire                              ex3_data_out_act;
   wire                              ex2_grffence_act;
   wire                              ex3_grffence_act;
   wire                              an_ac_grffence_en_dc_q;
   wire                              trace_bus_enable_q;
   wire                              entry_valid_act;
   wire                              entry_match_act;
   wire                              not_grffence_act;
   wire                              notlb_grffence_act;
   wire                              tlb_rel_act_d;
   wire                              tlb_rel_act_q;
   wire                              tlb_rel_act;
   wire                              snoop_act_q;
   wire                              iu_pc_err_ierat_multihit_d;
   wire                              iu_pc_err_ierat_multihit_q;
   wire                              iu_pc_err_ierat_parity_d;
   wire                              iu_pc_err_ierat_parity_q;
   wire                              lru_update_act;
   wire                              debug_grffence_act;
   wire                              eratsx_data_act;
   wire                              iu_xu_ord_write_done_d, iu_xu_ord_write_done_q;
   wire                              iu_xu_ord_read_done_d, iu_xu_ord_read_done_q;
   wire                              iu_xu_ord_par_err_d, iu_xu_ord_par_err_q;
   wire [0:3]                        cp_ic_csinv_comp_d;
   wire [0:3]                        cp_ic_csinv_comp_q;
   wire                              csinv_complete;

   wire [0:scan_right_0]             siv_0;
   wire [0:scan_right_0]             sov_0;
   wire [0:scan_right_1]             siv_1;
   wire [0:scan_right_1]             sov_1;
   wire [0:boot_scan_right]          bsiv;
   wire [0:boot_scan_right]          bsov;

   wire                              tiup;

   //@@ START OF EXECUTABLE CODE FOR IUQ_IC_IERAT

   //## figtree_source: iuq_ic_ierat.fig;

   //  ttype <= 0:eratre & 1:eratwe & 2:eratsx & 3:eratilx & 4:csync & 5:isync;
   // ERAT Operation is Complete
   assign iu_xu_ord_write_done_d = (|(ex4_valid_q & (~(xu_iu_flush)))) & (ex4_ttype_q[0] | ex4_ttype_q[2]);  // ERATRE/ERATSX Completed
   assign iu_xu_ord_read_done_d = (|(ex4_valid_q & (~(xu_iu_flush)))) & ex4_ttype_q[1];
   assign iu_xu_ord_write_done = iu_xu_ord_write_done_q;
   assign iu_xu_ord_read_done = iu_xu_ord_read_done_q;

   //---------------------------------------------------------------------
   // ACT Generation
   //---------------------------------------------------------------------

   assign iu1_stg_act_d = comp_request | spr_ic_clockgate_dis;
   assign iu2_stg_act_d = iu1_stg_act_q;
   assign iu3_stg_act_d = iu2_stg_act_q;

   assign ex1_stg_act_d = (|(xu_iu_val)) | spr_ic_clockgate_dis;
   assign ex2_stg_act_d = ex1_stg_act_q;
   assign ex3_stg_act_d = ex2_stg_act_q;
   assign ex4_stg_act_d = ex3_stg_act_q;
   assign ex5_stg_act_d = ex4_stg_act_q;
   assign ex6_stg_act_d = ex5_stg_act_q;
   assign ex7_stg_act_d = ex6_stg_act_q;

   assign iu1_cmp_data_act = iu1_stg_act_q & (~(an_ac_grffence_en_dc));
   assign iu1_grffence_act = iu1_stg_act_q & (~(an_ac_grffence_en_dc));
   assign iu1_or_iu2_grffence_act = (iu1_stg_act_q | iu2_stg_act_q) & (~(an_ac_grffence_en_dc));
   assign iu2_or_iu3_grffence_act = (iu2_stg_act_q | iu3_stg_act_q) & (~(an_ac_grffence_en_dc));

   assign ex2_grffence_act = ex2_stg_act_q & (~(an_ac_grffence_en_dc));

   assign ex3_rd_data_act  = ex3_stg_act_q & (~(an_ac_grffence_en_dc));
   assign ex3_data_out_act = ex3_stg_act_q & (~(an_ac_grffence_en_dc));
   assign ex3_grffence_act = ex3_stg_act_q & (~(an_ac_grffence_en_dc));

   assign entry_valid_act  = (~an_ac_grffence_en_dc);
   assign entry_match_act  = (~an_ac_grffence_en_dc);
   assign not_grffence_act = (~an_ac_grffence_en_dc);

   assign lru_update_act = ex6_stg_act_q | ex7_stg_act_q | lru_update_event_q[4] | lru_update_event_q[8] | flash_invalidate | ex6_ieratwe_ws3;
   assign notlb_grffence_act = ((~(ccr2_notlb_q)) | spr_ic_clockgate_dis) & (~(an_ac_grffence_en_dc));
   assign debug_grffence_act = trace_bus_enable_q & (~(an_ac_grffence_en_dc));
   assign eratsx_data_act = (iu1_stg_act_q | ex2_stg_act_q) & (~(an_ac_grffence_en_dc));

   //---------------------------------------------------------------------
   // Logic
   //---------------------------------------------------------------------
   //tidn <= '0';
   assign tiup = 1'b1;
   assign init_alias = pc_iu_init_reset;  // high active

   // timing latches for the reloads
   assign tlb_rel_val_d = mm_iu_ierat_rel_val;    // std_ulogic_vector(0 to 4); -- bit 4 is hit/miss
   assign tlb_rel_data_d = mm_iu_ierat_rel_data;  //std_ulogic_vector(0 to 131);
   assign tlb_rel_act_d = mm_iu_ierat_rel_data[eratpos_relsoon];  // reload coming from tlb, asserted tag0 thru tag6 in tlb
   assign tlb_rel_act = (tlb_rel_act_q & (~(ccr2_notlb_q)));      // reload coming from tlb, gated with notlb

   // timing latches for the ifrat delusional paranoia real mode
   assign ccr2_frat_paranoia_d[0:8] = xu_iu_spr_ccr2_ifratsc;
   assign ccr2_frat_paranoia_d[9] = xu_iu_spr_ccr2_ifrat;   // enable paranoia

   assign cp_ic_csinv_comp_d[0] = cp_ic_is_csync;  // this is iuq_cpl csync complete pulse, qualified with valid
   assign cp_ic_csinv_comp_d[1] = cp_ic_is_isync;  // this is iuq_cpl isync complete pulse, qualified with valid

   //  mmucr1_q: 0-IRRE, 1-REE, 2-CEE, 3-csync_dis, 4-isync_dis, 5:6-IPEI, 7:8-ICTID/ITTID
   assign cp_ic_csinv_comp_d[2] = ((mmucr1_q[3] == 1'b0) & (ccr2_notlb_q == MMU_Mode_Value)) ? cp_ic_csinv_comp_q[0] :    // mmu mode, csync allowed
                                  1'b0;
   assign cp_ic_csinv_comp_d[3] = ((mmucr1_q[4] == 1'b0) & (ccr2_notlb_q == MMU_Mode_Value)) ? cp_ic_csinv_comp_q[1] :    // mmu mode, isync allowed
                                  1'b0;

   //------------------------------------------------
   assign ex1_valid_d = xu_iu_val & (~(xu_rf1_flush));
   assign ex1_ttype_d[0:ttype_width - 1] = {xu_iu_is_eratre, xu_iu_is_eratwe, xu_iu_is_eratsx};
   assign ex1_ws_d = xu_iu_ws;
   assign ex1_ra_entry_d = {ra_entry_width{1'b0}};

   assign ierat_mmucr0[0]  = mm_iu_t0_ierat_mmucr0;
   assign mmucr0_gs_vec[0] = mm_iu_t0_ierat_mmucr0[2];
   assign mmucr0_ts_vec[0] = mm_iu_t0_ierat_mmucr0[3];
   assign ierat_pid[0]     = mm_iu_t0_ierat_pid;

 `ifndef THREADS1
   assign ierat_mmucr0[1]  = mm_iu_t1_ierat_mmucr0;
   assign mmucr0_gs_vec[1] = mm_iu_t1_ierat_mmucr0[2];
   assign mmucr0_ts_vec[1] = mm_iu_t1_ierat_mmucr0[3];
   assign ierat_pid[1]     = mm_iu_t1_ierat_pid;
 `endif

   //always @(ierat_mmucr0 or ierat_pid or rpn_holdreg_q or xu_iu_val or ex6_valid_q or iu_ierat_iu0_thdid)
   always @ (*)
   begin: tidSpr
      reg [0:13]                        pid_0;
      reg [0:13]                        pid_1;
      reg [0:1]                         extclass;
      reg [0:1]                         tlbsel;
      reg [0:63]                        rpnHold;
      reg [0:13]                        iu1_pid;
      (* analysis_not_referenced="true" *)
      integer                           tid;

      pid_0    = 14'b0;
      pid_1    = 14'b0;
      extclass = 2'b0;
      tlbsel   = 2'b0;
      rpnHold  = 64'b0;
      iu1_pid  = 14'b0;
      for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
      begin
         pid_0    = (ierat_mmucr0[tid][6:19] & {14{xu_iu_val[tid]}}) | pid_0;
         pid_1    = (ierat_pid[tid]          & {14{xu_iu_val[tid]}}) | pid_1;
         extclass = (ierat_mmucr0[tid][0:1]  & { 2{xu_iu_val[tid]}}) | extclass;
         tlbsel   = (ierat_mmucr0[tid][4:5]  & { 2{xu_iu_val[tid]}}) | tlbsel;
         rpnHold  = (rpn_holdreg_q[tid]      & {64{ex6_valid_q[tid]}}) | rpnHold;
         iu1_pid  = (ierat_pid[tid]          & {14{iu_ierat_iu0_thdid[tid]}}) | iu1_pid;
      end
      ex1_pid_0       <= pid_0;
      ex1_pid_1       <= pid_1;
      ex1_extclass_d  <= extclass;
      ex1_tlbsel_d    <= tlbsel;
      ex6_rpn_holdreg <= rpnHold;
      iu1_pid_d       <= iu1_pid;
   end

   assign iu1_nonspec_d = iu_ierat_iu0_nonspec;
   assign iu1_prefetch_d = iu_ierat_iu0_prefetch;

   // state: 0:pr 1:hs 2:ds 3:cm
   assign ex1_state_d[0] = |(xu_iu_msr_pr & xu_iu_val);
   assign ex1_state_d[1] = ((|(xu_iu_msr_hv  & xu_iu_val)) & (~xu_iu_is_eratsx)) |
                           ((|(mmucr0_gs_vec & xu_iu_val)) &   xu_iu_is_eratsx);
   assign ex1_state_d[2] = ((|(xu_iu_msr_is  & xu_iu_val)) & (~xu_iu_is_eratsx)) |
                           ((|(mmucr0_ts_vec & xu_iu_val)) &   xu_iu_is_eratsx);
   assign ex1_state_d[3] = |(xu_iu_msr_cm & xu_iu_val);

   //-----------------------------------------

   // mmucr0: 0:1-ECL|TID_NZ, 2:3-tgs/ts, 4:5-tlbsel, 6:19-tid,

   assign ex1_pid_d = (xu_iu_is_eratsx == 1'b1) ? ex1_pid_0 :
                      ex1_pid_1;

   assign iu2_nonspec_d = iu1_nonspec_q;
   assign iu2_prefetch_d = iu1_prefetch_q;

   assign ex1_ieratre = (|(ex1_valid_q[0:`THREADS - 1])) & ex1_ttype_q[0] & ex1_tlbsel_q[0] & (~ex1_tlbsel_q[1]);
   assign ex1_ieratwe = (|(ex1_valid_q[0:`THREADS - 1])) & ex1_ttype_q[1] & ex1_tlbsel_q[0] & (~ex1_tlbsel_q[1]);
   assign ex1_ieratsx = (|(ex1_valid_q[0:`THREADS - 1])) & ex1_ttype_q[2] & ex1_tlbsel_q[0] & (~ex1_tlbsel_q[1]);

   //------------------------------------------------
   assign ex2_valid_d = ex1_valid_q & (~(xu_ex1_flush));
   assign ex2_ttype_d = ex1_ttype_q;
   assign ex2_ws_d = ex1_ws_q;
   assign ex2_ra_entry_d = xu_iu_ra_entry;
   assign ex2_state_d = ex1_state_q;
   assign ex2_pid_d = ex1_pid_q;
   assign ex2_extclass_d = ex1_extclass_q;
   assign ex2_tlbsel_d = ex1_tlbsel_q;

   //------------------------------------------------
   assign ex3_valid_d = ex2_valid_q & (~(xu_ex2_flush)) & (~(iu_xu_ierat_ex2_flush_q));
   assign ex3_ra_entry_d = (ex2_ttype_q[2] == 1'b1) ? iu1_first_hit_entry :  // eratsx
                           ex2_ra_entry_q;
   assign ex3_ttype_d = ex2_ttype_q;
   assign ex3_ws_d = ex2_ws_q;
   assign ex3_tlbsel_d = ex2_tlbsel_q;
   assign ex3_extclass_d = ex2_extclass_q;
   // state: 0:pr 1:hs 2:ds 3:cm
   assign ex3_state_d = ex2_state_q;
   assign ex3_pid_d = ex2_pid_q;

   assign ex3_ieratwe = (|(ex3_valid_q)) & ex3_ttype_q[1] & ex3_tlbsel_q[0] & (~ex3_tlbsel_q[1]);

   //------------------------------------------------
   assign ex4_valid_d = ex3_valid_q & (~(xu_ex3_flush));
   assign ex4_ttype_d = ex3_ttype_q;
   assign ex4_ws_d = ex3_ws_q;
   assign ex4_ra_entry_d = ex3_ra_entry_q;
   assign ex4_tlbsel_d = ex3_tlbsel_q;
   // muxes for eratre and sending mmucr0 ExtClass,State,TID
   assign ex4_extclass_d = ((|(ex3_valid_q)) == 1'b1 & ex3_ttype_q[0] == 1'b1 & ex3_ws_q == 2'b00) ? rd_cam_data[63:64] :   // eratre, WS=0
                           ex3_extclass_q;
   // state: 0:pr 1:hs 2:ds 3:cm
   assign ex4_state_d = ((|(ex3_valid_q)) == 1'b1 & ex3_ttype_q[0] == 1'b1 & ex3_ws_q == 2'b00) ? {ex3_state_q[0], rd_cam_data[65:66], ex3_state_q[3]} :  // eratre, WS=0
                        ex3_state_q;
   assign ex4_pid_d = ((|(ex3_valid_q)) == 1'b1 & ex3_ttype_q[0] == 1'b1 & ex3_ws_q == 2'b00) ? {rd_cam_data[61:62], rd_cam_data[57:60], rd_cam_data[67:74]} :  // class | thdid | tid -> 14-bit tid    // eratre, WS=0
                      ex3_pid_q;
   assign ex4_ieratwe = (|(ex4_valid_q)) & ex4_ttype_q[1] & ex4_tlbsel_q[0] & (~ex4_tlbsel_q[1]);

   //------------------------------------------------
   assign ex5_valid_d = ex4_valid_q & (~(xu_ex4_flush));
   assign ex5_ws_d = ex4_ws_q;
   assign ex5_ra_entry_d = ex4_ra_entry_q;

   //  ttype <= 0:eratre & 1:eratwe & 2:eratsx & 3:eratilx & 4:csync & 5:isync;
   assign ex5_ttype_d = ex4_ttype_q;

   // mmucr0: 0:1-ECL|TID_NZ, 2:3-tgs/ts, 4:5-tlbsel, 6:19-tid,
   assign ex5_extclass_d = ex4_extclass_q;

   // state: 0:pr 1:hs 2:ds 3:cm
   assign ex5_state_d = ex4_state_q;
   assign ex5_pid_d = ex4_pid_q;
   assign ex5_tlbsel_d = ex4_tlbsel_q;

   assign ex5_data_in_d = xu_iu_rs_data;

   assign ex5_ieratwe     = (|(ex5_valid_q)) & ex5_ttype_q[1] & ex5_tlbsel_q[0] & (~ex5_tlbsel_q[1]);
   assign ex5_ieratwe_ws0 = (|(ex5_valid_q)) & ex5_ttype_q[1] & ex5_tlbsel_q[0] & (~ex5_tlbsel_q[1]) & (~|(ex5_ws_q));

   //------------------------------------------------
   assign ex6_valid_d = ex5_valid_q & (~(xu_ex5_flush));
   assign ex6_ws_d = ex5_ws_q;
   assign ex6_ra_entry_d = ex5_ra_entry_q;

   assign ex6_ttype_d = ex5_ttype_q;

   //always @(ex5_valid_q or ex5_ieratwe_ws0 or ierat_mmucr0 or mmucr0_gs_vec or mmucr0_ts_vec or xu_iu_msr_pr or //xu_iu_msr_cm or ex5_extclass_q or ex5_state_q or ex5_pid_q or ex5_tlbsel_q)
   always @ (*)
   begin: tidEx6
      reg [0:13]                        pid;
      reg [0:3]                         state;
      reg [0:1]                         extclass;
      reg [0:1]                         tlbsel;
      (* analysis_not_referenced="true" *)
      integer                           tid;

      pid      = 14'b0;
      state    =  4'b0;
      extclass =  2'b0;
      tlbsel   =  2'b0;
      // mmucr0: 0:1-ECL|TID_NZ, 2:3-tgs/ts, 4:5-tlbsel, 6:19-tid,
      // state: 0:pr 1:hs 2:ds 3:cm
      for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
      begin
         extclass = (ierat_mmucr0[tid][0:1] & {2{ex5_valid_q[tid]}}) | extclass;
         state    = ({xu_iu_msr_pr[tid], mmucr0_gs_vec[tid], mmucr0_ts_vec[tid], xu_iu_msr_cm[tid]} & {4{ex5_valid_q[tid]}}) | state;
         tlbsel   = (ierat_mmucr0[tid][4:5] & {2{ex5_valid_q[tid]}}) | tlbsel;
         pid      = (ierat_mmucr0[tid][6:19] & {14{ex5_valid_q[tid]}}) | pid;
      end
      ex6_extclass_d <= (extclass &  {2{ex5_ieratwe_ws0}}) | (ex5_extclass_q &  {2{~(ex5_ieratwe_ws0)}});
      ex6_state_d    <= (state    &  {4{ex5_ieratwe_ws0}}) | (ex5_state_q    &  {4{~(ex5_ieratwe_ws0)}});
      ex6_pid_d      <= (pid      & {14{ex5_ieratwe_ws0}}) | (ex5_pid_q      & {14{~(ex5_ieratwe_ws0)}});
      ex6_tlbsel_d   <= (tlbsel   &  {2{ex5_ieratwe_ws0}}) | (ex5_tlbsel_q   &  {2{~(ex5_ieratwe_ws0)}});
   end

   assign ex6_data_in_d = ex5_data_in_q;

   assign ex6_ieratwe = (|(ex6_valid_q)) & ex6_ttype_q[1] & ex6_tlbsel_q[0] & (~ex6_tlbsel_q[1]);

   //------------------------------------------------
   // for flushing
   assign ex7_valid_d = ex6_valid_q;
   assign ex7_ttype_d = ex6_ttype_q;
   assign ex7_tlbsel_d = ex6_tlbsel_q;

   assign ex7_ieratwe = (|(ex7_valid_q)) & ex7_ttype_q[1] & ex7_tlbsel_q[0] & (~ex7_tlbsel_q[1]);

   // adding local iu2 flush request for timing
   assign iu1_valid_d = iu_ierat_iu0_thdid & {`THREADS{iu_ierat_iu0_val}} & (~(iu_ierat_iu0_flush)) & (~(xu_iu_flush | br_iu_flush)) & (~(iu2_n_flush_req_q));

   // state: 0:pr 1:hs 2:ds 3:cm
   assign iu1_state_d[0] = |(xu_iu_msr_pr & iu_ierat_iu0_thdid);
   assign iu1_state_d[1] = |(xu_iu_msr_hv & iu_ierat_iu0_thdid);
   assign iu1_state_d[2] = |(xu_iu_msr_is & iu_ierat_iu0_thdid);
   assign iu1_state_d[3] = |(xu_iu_msr_cm & iu_ierat_iu0_thdid);

   // adding local iu2 flush request for timing
   assign iu2_valid_d = iu1_valid_q & (~(iu_ierat_iu1_flush)) & (~(xu_iu_flush | br_iu_flush)) & (~(iu2_n_flush_req_q));
   assign iu2_state_d = iu1_state_q;
   assign iu2_pid_d = iu1_pid_q;

   assign iu_mm_ierat_flush_d = iu_ierat_iu1_flush;

   assign mmucr1_d = mm_iu_ierat_mmucr1;

// formation of iu1 phase multihit complement signal
/*
//table_start
?TABLE iu1_multihit_b LISTING(final) OPTIMIZE PARMS(ON-SET);
*INPUTS*==============*OUTPUTS*==========*
|                     |                  |
| entry_match         |  iu1_multihit_b  |
| |                   |  |               |
| |                   |  |               |
| |                   |  |               |
| |         111111    |  |               |
| 0123456789012345    |  |               |
*TYPE*================+==================+
| PPPPPPPPPPPPPPPP    |  P               |
*OPTIMIZE*----------->|  A               |
*TERMS*===============+==================+
| 0000000000000000    |  1               |  no hit
| 1000000000000000    |  1               |  exactly one hit
| 0100000000000000    |  1               |  exactly one hit
| 0010000000000000    |  1               |  exactly one hit
| 0001000000000000    |  1               |  exactly one hit
| 0000100000000000    |  1               |  exactly one hit
| 0000010000000000    |  1               |  exactly one hit
| 0000001000000000    |  1               |  exactly one hit
| 0000000100000000    |  1               |  exactly one hit
| 0000000010000000    |  1               |  exactly one hit
| 0000000001000000    |  1               |  exactly one hit
| 0000000000100000    |  1               |  exactly one hit
| 0000000000010000    |  1               |  exactly one hit
| 0000000000001000    |  1               |  exactly one hit
| 0000000000000100    |  1               |  exactly one hit
| 0000000000000010    |  1               |  exactly one hit
| 0000000000000001    |  1               |  exactly one hit
*END*=================+==================+
?TABLE END iu1_multihit_b;
//table_end
*/


   assign iu1_multihit = (~iu1_multihit_b);
   assign iu2_multihit_b_pt_d = iu1_multihit_b_pt;
   assign iu2_multihit_enab = (~|(iu2_multihit_b_pt_q));


// Encoder for the iu1 phase first hit entry number
/*
//table_start
?TABLE iu1_first_hit_entry LISTING(final) OPTIMIZE PARMS(ON-SET);
*INPUTS*==============*OUTPUTS*==============*
|                     |                      |
| entry_match         |  iu1_first_hit_entry |
| |                   |  |                   |
| |                   |  |                   |
| |                   |  |                   |
| |         111111    |  |                   |
| 0123456789012345    |  0123                |
*TYPE*================+======================+
| PPPPPPPPPPPPPPPP    |  PPPP                |
*OPTIMIZE*----------->|  AAAA                |
*TERMS*===============+======================+
| 1---------------    |  0000                |
| 01--------------    |  0001                |
| 001-------------    |  0010                |
| 0001------------    |  0011                |
| 00001-----------    |  0100                |
| 000001----------    |  0101                |
| 0000001---------    |  0110                |
| 00000001--------    |  0111                |
| 000000001-------    |  1000                |
| 0000000001------    |  1001                |
| 00000000001-----    |  1010                |
| 000000000001----    |  1011                |
| 0000000000001---    |  1100                |
| 00000000000001--    |  1101                |
| 000000000000001-    |  1110                |
| 0000000000000001    |  1111                |
*END*=================+======================+
?TABLE END iu1_first_hit_entry;
//table_end
*/

   assign iu2_first_hit_entry_pt_d = iu1_first_hit_entry_pt;
   assign iu2_first_hit_entry[0] = (iu2_first_hit_entry_pt_q[1] | iu2_first_hit_entry_pt_q[2] | iu2_first_hit_entry_pt_q[3] | iu2_first_hit_entry_pt_q[4] | iu2_first_hit_entry_pt_q[5] | iu2_first_hit_entry_pt_q[6] | iu2_first_hit_entry_pt_q[7] | iu2_first_hit_entry_pt_q[8]);
   assign iu2_first_hit_entry[1] = (iu2_first_hit_entry_pt_q[1] | iu2_first_hit_entry_pt_q[2] | iu2_first_hit_entry_pt_q[3] | iu2_first_hit_entry_pt_q[4] | iu2_first_hit_entry_pt_q[9] | iu2_first_hit_entry_pt_q[10] | iu2_first_hit_entry_pt_q[11] | iu2_first_hit_entry_pt_q[12]);
   assign iu2_first_hit_entry[2] = (iu2_first_hit_entry_pt_q[1] | iu2_first_hit_entry_pt_q[2] | iu2_first_hit_entry_pt_q[5] | iu2_first_hit_entry_pt_q[6] | iu2_first_hit_entry_pt_q[9] | iu2_first_hit_entry_pt_q[10] | iu2_first_hit_entry_pt_q[13] | iu2_first_hit_entry_pt_q[14]);
   assign iu2_first_hit_entry[3] = (iu2_first_hit_entry_pt_q[1] | iu2_first_hit_entry_pt_q[3] | iu2_first_hit_entry_pt_q[5] | iu2_first_hit_entry_pt_q[7] | iu2_first_hit_entry_pt_q[9] | iu2_first_hit_entry_pt_q[11] | iu2_first_hit_entry_pt_q[13] | iu2_first_hit_entry_pt_q[15]);

   assign iu2_cam_cmp_data_d = cam_cmp_data;
   assign iu2_array_cmp_data_d = array_cmp_data;

   assign iu2_miss_d[0] = ( (|(iu1_valid_q & (~(iu_ierat_iu1_flush)) & (~(xu_iu_flush | br_iu_flush)) & (~(iu2_n_flush_req_q)))) &
                            (~iu1_flush_enab_q) & (~ccr2_frat_paranoia_q[9]) & (~iu_ierat_iu1_back_inv) );
   assign iu2_miss_d[1] = (~cam_hit);
   assign iu2_miss_sig = iu2_miss_q[0] & iu2_miss_q[1];

   assign iu2_multihit_d[0] = (cam_hit & iu1_multihit &
                                 (|(iu1_valid_q & (~(iu_ierat_iu1_flush)) & (~(xu_iu_flush | br_iu_flush)) & (~(iu2_n_flush_req_q)))) &
                                 (~iu1_flush_enab_q) & (~ccr2_frat_paranoia_q[9]));
   assign iu2_multihit_d[1] = iu1_multihit;
   assign iu2_multihit_sig = iu2_multihit_q[0] & iu2_multihit_q[1];

   assign iu2_parerr_d[0] = (cam_hit & iu1_multihit_b &
                               (|(iu1_valid_q & (~(iu_ierat_iu1_flush)) & (~(xu_iu_flush | br_iu_flush)) & (~(iu2_n_flush_req_q)))) &
                               (~iu1_flush_enab_q) & (~ccr2_frat_paranoia_q[9]));  // txlate parity error
   assign iu2_parerr_d[1] = (cam_hit & iu1_multihit_b &
                               (|(iu1_valid_q & (~(iu_ierat_iu1_flush)) & (~(xu_iu_flush | br_iu_flush)) & (~(iu2_n_flush_req_q)))) &
                               (~iu1_flush_enab_q) & (~ccr2_frat_paranoia_q[9]));  // txlate parity error
   assign iu2_parerr_sig = (iu2_parerr_q[0] & iu2_cmp_data_parerr_epn) |   // txlate epn parity error
                           (iu2_parerr_q[1] & iu2_cmp_data_parerr_rpn);

   // 16x143 version, 42b RA
   // wr_array_data
   //  0:29  - RPN
   //  30:31  - R,C
   //  32:33  - WLC
   //  34     - ResvAttr
   //  35     - VF
   //  36:39  - U0-U3
   //  40:44  - WIMGE
   // attribute re-ordering
   //  45:46  - UX,SX
   //  47:48  - UW,SW
   //  49:50  - UR,SR
   //  51:60  - CAM parity
   //  61:67  - Array parity

   // mmucr1_q: 0-IRRE, 1-REE, 2-CEE, 3-csync_dis, 4-isync_dis, 5:6-IPEI, 7:8-ICTID/ITTID
   // state: 0:pr 1:hs 2:ds 3:cm

   assign iu2_isi_d[0] = ( (|(iu1_valid_q & (~(iu_ierat_iu1_flush)) & (~(xu_iu_flush | br_iu_flush)) & (~(iu2_n_flush_req_q)))) &
                           cam_hit &
                              (~iu1_flush_enab_q) & iu1_state_q[0] & (~ccr2_frat_paranoia_q[9]) );
                             // not user executable
   assign iu2_isi_d[2] = ( (|(iu1_valid_q & (~(iu_ierat_iu1_flush)) & (~(xu_iu_flush | br_iu_flush)) & (~(iu2_n_flush_req_q)))) &
                           cam_hit &
                              (~iu1_flush_enab_q) & (~iu1_state_q[0]) & (~ccr2_frat_paranoia_q[9]) );
                             // not supervisor executable
   assign iu2_isi_d[4] = ( (|(iu1_valid_q & (~(iu_ierat_iu1_flush)) & (~(xu_iu_flush | br_iu_flush)) & (~(iu2_n_flush_req_q)))) &
                           cam_hit &
                              (~iu1_flush_enab_q) & mmucr1_q[1] & (~ccr2_frat_paranoia_q[9]) );
                             // R=0 when reference exception enabled
   assign iu2_isi_d[1] = (~array_cmp_data[45]);
   assign iu2_isi_d[3] = (~array_cmp_data[46]);
   assign iu2_isi_d[5] = (~array_cmp_data[30]);
   assign iu2_isi_sig = (iu2_isi_q[0] & iu2_isi_q[1]) |
                        (iu2_isi_q[2] & iu2_isi_q[3]) |
                        (iu2_isi_q[4] & iu2_isi_q[5]);

   assign ex3_eratsx_data_d = {iu1_multihit, cam_hit, iu1_first_hit_entry};     // ex2 phase data out of cam for eratsx

   assign ex3_parerr_d[0:`THREADS - 1] = ex2_valid_q & (~(xu_ex2_flush)) & (~(iu_xu_ierat_ex2_flush_q));

   assign ex3_parerr_d[`THREADS] = ( cam_hit & iu1_multihit_b & ex2_ttype_q[2] & ex2_tlbsel_q[0] & (~(ex2_tlbsel_q[1])) &     // eratsx epn parity error
                                     (~(ex3_ieratwe | ex4_ieratwe | ex5_ieratwe | ex6_ieratwe | ex7_ieratwe)) &
                                     (|(ex2_valid_q & (~(xu_ex2_flush)) & (~(iu_xu_ierat_ex2_flush_q)))) );
   assign ex3_parerr_enab = ex3_parerr_q[`THREADS] & iu2_cmp_data_parerr_epn;

   assign ex4_rd_array_data_d = rd_array_data;
   assign ex4_rd_cam_data_d = rd_cam_data;

   assign ex4_parerr_d[0:`THREADS - 1] = ex3_valid_q & (~(xu_ex3_flush));

   assign ex4_parerr_d[`THREADS] = (ex3_ttype_q[0] & (~ex3_ws_q[0]) & (~ex3_ws_q[1]) & ex3_tlbsel_q[0] & (~ex3_tlbsel_q[1]) &
                                    (~tlb_rel_act_q) &
                                    (~(ex4_ieratwe | ex5_ieratwe | ex6_ieratwe)));               // eratre, epn ws=0

   assign ex4_parerr_d[`THREADS + 1] = (ex3_ttype_q[0] & (^ex3_ws_q) & ex3_tlbsel_q[0] & (~ex3_tlbsel_q[1]) &
                                        (~tlb_rel_act_q) &
                                        (~(ex4_ieratwe | ex5_ieratwe | ex6_ieratwe)));          // eratre, rpn ws=1 or 2

   assign ex4_parerr_d[`THREADS + 2] = |(ex3_parerr_q[0:`THREADS - 1]) & ex3_parerr_enab;


   assign ex4_parerr_enab = (ex4_parerr_q[`THREADS]     & ex4_rd_data_parerr_epn) |
                            (ex4_parerr_q[`THREADS + 1] & ex4_rd_data_parerr_rpn);

   assign iu_xu_ord_par_err_d = ex4_parerr_q[`THREADS + 2] | (|(ex4_parerr_q[0:`THREADS-1]) & ex4_parerr_enab);  // eratsx or eratre parerr
   assign iu_xu_ord_par_err = iu_xu_ord_par_err_q;

   assign ex4_ieen_d[0:`THREADS - 1] = (ex3_ttype_q[2] == 1'b1) ? (ex3_parerr_q[0:`THREADS-1] & {`THREADS{ex3_parerr_enab}} & (~(xu_ex3_flush))) :  // eratsx
                                       ((iu2_multihit_sig == 1'b1) | (iu2_parerr_sig == 1'b1)) ? (iu2_valid_q & (~iu2_n_flush_req_q)) :  // fetch with multihit or parerr
                                       {`THREADS{1'b0}};

   assign ex4_ieen_d[`THREADS:`THREADS + num_entry_log2 - 1] = (ex3_ttype_q[2] == 1'b1) ? ex3_eratsx_data_q[2:2 + num_entry_log2 - 1] :  // eratsx, first hit entry
                                                               ((ex3_ttype_q[0] == 1'b1) & (ex3_ws_q == 2'b00) & (ex3_tlbsel_q == TlbSel_IErat)) ? ex3_ra_entry_q :  // eratre, epn ws=0
                                                               ((ex3_ttype_q[0] == 1'b1) & ((ex3_ws_q == 2'b01) | (ex3_ws_q == 2'b10)) & (ex3_tlbsel_q == TlbSel_IErat)) ? ex3_ra_entry_q :  // eratre, rpn ws=1 or 2
                                                               ((iu2_multihit_sig == 1'b1) | (iu2_parerr_sig == 1'b1)) ? ex3_eratsx_data_q[2:2 + num_entry_log2 - 1] :  // fetch with multihit or parerr
                                                               {num_entry_log2{1'b0}};

   assign ex5_ieen_d[0:`THREADS - 1] = (ex4_ieen_q[0:`THREADS - 1] & (~(xu_ex4_flush))) |                                 // eratsx, or fetch
                                       (ex4_parerr_q[0:`THREADS - 1] & {`THREADS{ex4_parerr_enab}} & (~(xu_ex4_flush)));  // eratre
   // eratsx, or fetch
   assign ex5_ieen_d[`THREADS:`THREADS + num_entry_log2 - 1] = ex4_ieen_q[`THREADS:`THREADS + num_entry_log2 - 1];

   assign ex6_ieen_d = {( ex5_ieen_q[0:`THREADS - 1] & (~(xu_ex5_flush)) & (~{`THREADS{mchk_flash_inv_q[3]}}) ), ex5_ieen_q[`THREADS:`THREADS + num_entry_log2 - 1]};

   assign mchk_flash_inv_d[0] = |(iu2_valid_q & (~(xu_iu_flush | br_iu_flush)) & (~(iu2_n_flush_req_q)));   // iu2 phase
   assign mchk_flash_inv_d[1] = iu2_parerr_sig;   // iu2 phase, parerr on fetch and cam hit
   assign mchk_flash_inv_d[2] = iu2_multihit_sig; // iu2 phase, multihit on fetch and cam hit
   assign mchk_flash_inv_d[3] = mchk_flash_inv_enab;
   // mchk_flash_inv_q[3] ex5_ieen phase gates mmucr1 updates when h/w recovery flash invalidates erat

   assign mchk_flash_inv_enab = mchk_flash_inv_q[0] & (mchk_flash_inv_q[1] | mchk_flash_inv_q[2]) & (~(ccr2_notlb_q)) & (~(xucr4_mmu_mchk_q));  // iu3 phase, parerr/multihit on fetch and tlb mode and mmu_mchk disabled

   assign iu1_flush_enab_d = (((tlb_rel_val_q[0:3] != 4'b0000) & (tlb_rel_val_q[4] == 1'b1)) | tlb_rel_act_q)  |  // tlb hit reload
                             (snoop_val_q[0:1] == 2'b11)  |  // invalidate snoop
                             ((|(ex1_valid_q[0:`THREADS - 1])) & ex1_ttype_q[2] & (ex1_tlbsel_q == TlbSel_IErat)) |  // eratsx
                             ((|(ex6_valid_q[0:`THREADS - 1])) & ex6_ttype_q[1] & (ex6_ws_q == 2'b00) & (ex6_tlbsel_q == TlbSel_IErat)) |   // eratwe WS=0
                             (csinv_complete | mchk_flash_inv_enab);  // csync or isync enabled and complete, or mchk flash inval due to parerr/multihit

   // adding local iu2 flush request for timing
   assign iu2_n_flush_req_d = (iu1_flush_enab_q == 1'b1) ? (iu1_valid_q & (~(iu_ierat_iu1_flush | xu_iu_flush | br_iu_flush | iu2_n_flush_req_q))) :  // delayed iu0 flush enable
                              ((cam_hit == 1'b0) & (ccr2_notlb_q == MMU_Mode_Value) & (ccr2_frat_paranoia_q[9] == 1'b0) & (iu1_prefetch_q == 1'b0))? (iu1_valid_q & (~(iu_ierat_iu1_flush | xu_iu_flush | br_iu_flush | iu2_n_flush_req_q)) & (~(tlb_miss_q))):
                              {`THREADS{1'b0}};

   // adding local iu2 flush request for timing
   // adding frat paranoia for ra=ea

   // tlb-mode sequence of events:
   //   1) non-prefetch ierat miss sets hold and flushes op via iu2_n_flush_req_q,
   //   2) request sent to tlb,
   //   3) tlb-reload hit/miss,
   //   4) hold is cleared, tlb-miss sets tlb_miss_q=1, tlb-hit writes erat
   //   5) replay of op clears tlb_miss_q if set, erat miss sets hold again but no flush this time
   generate
   begin : xhdl1
     genvar  tid;
     for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
     begin : holdTid
       assign hold_req_d[tid] = (por_hold_req[tid] == 1'b1) ? 1'b1 :
                                (ccr2_frat_paranoia_q[9] == 1'b1) ? 1'b0 :
                                ((xu_iu_flush[tid] == 1'b1 | br_iu_flush[tid] == 1'b1 | iu_ierat_iu1_flush[tid] == 1'b1) & tlb_req_inprogress_d[tid] == 1'b0) ? 1'b0 :
                                (tlb_rel_val_q[tid] == 1'b1 & ccr2_notlb_q == MMU_Mode_Value) ? 1'b0 :   // any tlb reload clears hold
                                (cam_hit == 1'b0 & iu1_valid_q[tid] == 1'b1 &
                                 iu1_prefetch_q == 1'b0 &
                                 iu_ierat_iu1_flush[tid] == 1'b0 & xu_iu_flush[tid] == 1'b0 & br_iu_flush[tid] == 1'b0 & iu1_flush_enab_q == 1'b0 &
                                 iu2_n_flush_req_q[tid] == 1'b0 & ccr2_notlb_q == MMU_Mode_Value) ? 1'b1 :    // any non-flushed, non-prefetch cam miss
                                hold_req_q[tid];

       assign tlb_miss_d[tid] = (ccr2_notlb_q != MMU_Mode_Value | por_seq_q != PorSeq_Idle | ccr2_frat_paranoia_q[9] == 1'b1) ? 1'b0 :
                                (xu_iu_flush[tid] == 1'b1 | br_iu_flush[tid] == 1'b1) ? 1'b0 :
                                (iu1_valid_q[tid] == 1'b1 & iu_ierat_iu1_flush[tid] == 1'b0 & xu_iu_flush[tid] == 1'b0 & br_iu_flush[tid] == 1'b0 & iu1_flush_enab_q == 1'b0 &
                                        iu2_n_flush_req_q[tid] == 1'b0 & tlb_miss_q[tid] == 1'b1) ? 1'b0 :   // replay of previous tlb miss
                                (tlb_rel_val_q[tid] == 1'b1 & tlb_rel_val_q[4] == 1'b0 & tlb_miss_q[tid] == 1'b0 & tlb_flushed_q[tid] == 1'b0) ? hold_req_q[tid] :   // tlb-miss reload
                                tlb_miss_q[tid];

       assign tlb_flushed_d[tid] = (tlb_req_inprogress_d[tid] == 1'b1 & (xu_iu_flush[tid] == 1'b1 | br_iu_flush[tid] == 1'b1 | iu_ierat_iu1_flush[tid] == 1'b1)) ? 1'b1 :
                                   (tlb_rel_val_q[tid] == 1'b1) ? 1'b0 :
                                   tlb_flushed_q[tid];

       assign tlb_req_inprogress_d[tid] = (ccr2_frat_paranoia_q[9] == 1'b1 | por_hold_req[tid] == 1'b1 | ccr2_notlb_q != MMU_Mode_Value | tlb_rel_val_q[tid] == 1'b1) ? 1'b0 :  // mode, por, or tlb reload
                                          (xu_iu_flush[tid] == 1'b0 & br_iu_flush[tid] == 1'b0 & iu2_valid_q[tid] == 1'b1 & hold_req_q[tid] == 1'b0) ? 1'b0 :   // erat miss flush from xu is gone and iu is running again
                                          (iu2_tlbreq_q == 1'b1 & iu2_valid_q[tid] == 1'b1 & ccr2_notlb_q == MMU_Mode_Value) ? 1'b1 :  // tlb service request for this thread
                                          tlb_req_inprogress_q[tid];
     end
   end
   endgenerate

   assign iu2_tlbreq_d = (cam_hit == 1'b0 & iu1_flush_enab_q == 1'b0 & ccr2_notlb_q == MMU_Mode_Value & ccr2_frat_paranoia_q[9] == 1'b0 & iu_ierat_iu1_back_inv == 1'b0 &
                          iu1_prefetch_q == 1'b0 &
                          (|(iu1_valid_q & (~(iu_ierat_iu1_flush)) & (~(xu_iu_flush | br_iu_flush)) & (~(iu2_n_flush_req_q)) & (~(tlb_miss_q)) & (~(hold_req_q)))) == 1'b1) ? 1'b1 :
                         1'b0;

   assign snoop_val_d[0] = (snoop_val_q[0] == 1'b0) ? mm_iu_ierat_snoop_val :
                           (tlb_rel_val_q[4] == 1'b0 & snoop_val_q[1] == 1'b1) ? 1'b0 :  // no tlb hit reload, and no I$ backinv
                           snoop_val_q[0];
   assign snoop_val_d[1] = (~iu_ierat_ium1_back_inv);
   assign snoop_val_d[2] = (tlb_rel_val_q[4] == 1'b1 | snoop_val_q[1] == 1'b0) ? 1'b0 :  // a tlb hit reload, or I$ backinv
                           snoop_val_q[0];
   assign snoop_attr_d = (snoop_val_q[0] == 1'b0) ? mm_iu_ierat_snoop_attr :
                         snoop_attr_q;
   assign snoop_addr_d = (snoop_val_q[0] == 1'b0) ? mm_iu_ierat_snoop_vpn :
                         snoop_addr_q;
   assign iu_mm_ierat_snoop_ack = snoop_val_q[2];


   generate
   begin : xhdl2
     genvar  tid;
     for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
     begin : rpnTid
       if (rs_data_width == 64)
       begin : gen64_holdreg
         assign rpn_holdreg_d[tid][0:19] = (ex6_valid_q[tid] == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_ws_q == 2'b01 & ex6_tlbsel_q == TlbSel_IErat & ex6_state_q[3] == 1'b1) ? ex6_data_in_q[0:19] :   // eratwe WS=1, cm=64b
                                           (ex6_valid_q[tid] == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_ws_q == 2'b10 & ex6_tlbsel_q == TlbSel_IErat & ex6_state_q[3] == 1'b0) ? ex6_data_in_q[32:51] :   // eratwe WS=2, cm=32b
                                           rpn_holdreg_q[tid][0:19];     // hold value;
         assign rpn_holdreg_d[tid][20:31] = (ex6_valid_q[tid] == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_ws_q == 2'b01 & ex6_tlbsel_q == TlbSel_IErat & ex6_state_q[3] == 1'b1) ? ex6_data_in_q[20:31] :  // eratwe WS=1, cm=64b
                                            (ex6_valid_q[tid] == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_ws_q == 2'b01 & ex6_tlbsel_q == TlbSel_IErat & ex6_state_q[3] == 1'b0) ? ex6_data_in_q[52:63] :  // eratwe WS=1, cm=32b
                                            rpn_holdreg_q[tid][20:31];    // hold value;
         assign rpn_holdreg_d[tid][32:51] = (ex6_valid_q[tid] == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_ws_q == 2'b01 & ex6_tlbsel_q == TlbSel_IErat & ex6_state_q[3] == 1'b1) ? ex6_data_in_q[32:51] :    // eratwe WS=1, cm=64b
                                            (ex6_valid_q[tid] == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_ws_q == 2'b01 & ex6_tlbsel_q == TlbSel_IErat & ex6_state_q[3] == 1'b0) ? ex6_data_in_q[32:51] :  // eratwe WS=2, cm=32b
                                            rpn_holdreg_q[tid][32:51];    // hold value;
         assign rpn_holdreg_d[tid][52:63] = (ex6_valid_q[tid] == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_ws_q == 2'b01 & ex6_tlbsel_q == TlbSel_IErat & ex6_state_q[3] == 1'b1) ? ex6_data_in_q[52:63] :    // eratwe WS=1, cm=64b
                                            (ex6_valid_q[tid] == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_ws_q == 2'b10 & ex6_tlbsel_q == TlbSel_IErat & ex6_state_q[3] == 1'b0) ? ex6_data_in_q[52:63] :  // eratwe WS=2, cm=32b
                                            rpn_holdreg_q[tid][52:63];    // hold value;
       end
     end
   end
   endgenerate

   assign ex6_ieratwe_ws3 = (|(ex6_valid_q[0:`THREADS - 1])) & ex6_ttype_q[1] & (ex6_ws_q == 2'b11) & (ex6_tlbsel_q == TlbSel_IErat);  // eratwe WS=3

   assign watermark_d = (ex6_ieratwe_ws3 == 1'b1) ? ex6_data_in_q[64-watermark_width:63] :   // eratwe WS=3
                        watermark_q;     // hold value;

   assign eptr_d = ((ex6_ieratwe_ws3 == 1'b1 | csinv_complete == 1'b1) & mmucr1_q[0] == 1'b1) ? {eptr_width{1'b0}} :  // write watermark and round-robin mode
                   ((eptr_q == 4'b1111 | eptr_q == watermark_q) &
                    ( ((|(ex6_valid_q[0:`THREADS - 1])) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_ws_q == 2'b00 & ex6_tlbsel_q == TlbSel_IErat & mmucr1_q[0] == 1'b1) |  // eratwe WS=0, max rollover, or watermark rollover
                      (tlb_rel_val_q[0:3] != 4'b0000 & tlb_rel_val_q[4] == 1'b1 & tlb_rel_data_q[eratpos_wren] == 1'b1 & mmucr1_q[0] == 1'b1))) ? {eptr_width{1'b0}} :  // tlb reload write, max rollover, or watermark rollover
                   ( ((|(ex6_valid_q[0:`THREADS - 1])) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_ws_q == 2'b00 & ex6_tlbsel_q == TlbSel_IErat & mmucr1_q[0] == 1'b1) |  // eratwe WS=0, increment
                    (tlb_rel_val_q[0:3] != 4'b0000 & tlb_rel_val_q[4] == 1'b1 & tlb_rel_data_q[eratpos_wren] == 1'b1 & mmucr1_q[0] == 1'b1) ) ? eptr_p1 :   // tlb reload write, increment
                   eptr_q;

   assign eptr_p1 = (eptr_q == 4'b0000) ? 4'b0001 :
                    (eptr_q == 4'b0001) ? 4'b0010 :
                    (eptr_q == 4'b0010) ? 4'b0011 :
                    (eptr_q == 4'b0011) ? 4'b0100 :
                    (eptr_q == 4'b0100) ? 4'b0101 :
                    (eptr_q == 4'b0101) ? 4'b0110 :
                    (eptr_q == 4'b0110) ? 4'b0111 :
                    (eptr_q == 4'b0111) ? 4'b1000 :
                    (eptr_q == 4'b1000) ? 4'b1001 :
                    (eptr_q == 4'b1001) ? 4'b1010 :
                    (eptr_q == 4'b1010) ? 4'b1011 :
                    (eptr_q == 4'b1011) ? 4'b1100 :
                    (eptr_q == 4'b1100) ? 4'b1101 :
                    (eptr_q == 4'b1101) ? 4'b1110 :
                    (eptr_q == 4'b1110) ? 4'b1111 :
                                          4'b0000;

   assign lru_way_is_written   = lru_way_encode == ex6_ra_entry_q;
   assign lru_way_is_hit_entry = lru_way_encode == iu1_first_hit_entry;

   // lru_update_event
   // 0: tlb reload
   // 1: invalidate snoop
   // 2: csync or isync enabled
   // 3: eratwe WS=0
   // 4: fetch hit
   // 5: iu2 cam write type events
   // 6: iu2 cam invalidate type events
   // 7: iu2 cam translation type events
   // 8: iu2, superset of non-translation events

   assign lru_update_event_d[0] = ( tlb_rel_data_q[eratpos_wren] & (|(tlb_rel_val_q[0:3])) & tlb_rel_val_q[4] );  // tlb reload

   assign lru_update_event_d[1] = ( snoop_val_q[0] & snoop_val_q[1] );  // invalidate snoop

   assign lru_update_event_d[2] = ( csinv_complete );  // csync or isync enabled and completed

   assign lru_update_event_d[3] = ( (|(ex6_valid_q[0:`THREADS-1])) & ex6_ttype_q[1] & (~ex6_ws_q[0]) & (~ex6_ws_q[1]) & ex6_tlbsel_q[0] & (~ex6_tlbsel_q[1]) & lru_way_is_written );  // eratwe WS=0, lru=target

   assign lru_update_event_d[4] = ( (|(iu1_valid_q & (~(iu_ierat_iu1_flush)) & (~(xu_iu_flush | br_iu_flush)) & (~(iu2_n_flush_req_q)))) &
                                    (~iu1_flush_enab_q) & cam_hit & lru_way_is_hit_entry );  // fetch hit with no error or flush, lru=hit

   assign lru_update_event_d[5] = lru_update_event_q[0] | lru_update_event_q[3];  // 5: iu2 cam write type events

   assign lru_update_event_d[6] = lru_update_event_q[1] | lru_update_event_q[2];  // 6: iu2 cam invalidate type events

   assign lru_update_event_d[7] = ( (|(iu1_valid_q & (~(iu_ierat_iu1_flush)) & (~(xu_iu_flush | br_iu_flush)) & (~(iu2_n_flush_req_q)))) &
                                    (~iu1_flush_enab_q) & cam_hit & lru_way_is_hit_entry );  // 7: iu2 cam translation type events
   assign lru_update_event_d[8] = lru_update_event_q[0] | lru_update_event_q[1] | lru_update_event_q[2] | lru_update_event_q[3];  // iu2, non-fetch superset

   assign lru_update_event_d[9] = ( (|(tlb_rel_val_q[0:3])) & tlb_rel_val_q[4] & tlb_rel_data_q[eratpos_wren] ) |  // tlb reload
                                  ( (|(ex6_valid_q[0:`THREADS - 1]) & ex6_ttype_q[1] & ex6_ws_q == 2'b00 & ex6_tlbsel_q == TlbSel_IErat) ) |  // i-eratwe WS=0
                                  ( snoop_val_q[0] & snoop_val_q[1] ) |  // invalidate snoop
                                  csinv_complete |  // csync or isync enabled and completed
                                  mchk_flash_inv_enab;  // mcheck flash invalidate

   assign lru_d[1] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :  // write watermark and not round-robin mode, or flash inv all v bits
                     (lru_reset_vec[1] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[1] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                     (lru_set_vec[1] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[1] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                     lru_q[1];
   assign lru_eff[1] = (lru_vp_vec[1] & lru_op_vec[1]) | (lru_q[1] & (~lru_op_vec[1]));
   assign lru_d[2] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :
                     (lru_reset_vec[2] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[2] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                     (lru_set_vec[2] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[2] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                     lru_q[2];
   assign lru_eff[2] = (lru_vp_vec[2] & lru_op_vec[2]) | (lru_q[2] & (~lru_op_vec[2]));
   assign lru_d[3] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :
                     (lru_reset_vec[3] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[3] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                     (lru_set_vec[3] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[3] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                     lru_q[3];
   assign lru_eff[3] = (lru_vp_vec[3] & lru_op_vec[3]) | (lru_q[3] & (~lru_op_vec[3]));
   assign lru_d[4] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :
                     (lru_reset_vec[4] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[4] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                     (lru_set_vec[4] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[4] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                     lru_q[4];
   assign lru_eff[4] = (lru_vp_vec[4] & lru_op_vec[4]) | (lru_q[4] & (~lru_op_vec[4]));
   assign lru_d[5] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :
                     (lru_reset_vec[5] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[5] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                     (lru_set_vec[5] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[5] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                     lru_q[5];
   assign lru_eff[5] = (lru_vp_vec[5] & lru_op_vec[5]) | (lru_q[5] & (~lru_op_vec[5]));
   assign lru_d[6] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :
                     (lru_reset_vec[6] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[6] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                     (lru_set_vec[6] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[6] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                     lru_q[6];
   assign lru_eff[6] = (lru_vp_vec[6] & lru_op_vec[6]) | (lru_q[6] & (~lru_op_vec[6]));
   assign lru_d[7] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :
                     (lru_reset_vec[7] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[7] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                     (lru_set_vec[7] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[7] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                     lru_q[7];
   assign lru_eff[7] = (lru_vp_vec[7] & lru_op_vec[7]) | (lru_q[7] & (~lru_op_vec[7]));
   assign lru_d[8] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :
                     (lru_reset_vec[8] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[8] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                     (lru_set_vec[8] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[8] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                     lru_q[8];
   assign lru_eff[8] = (lru_vp_vec[8] & lru_op_vec[8]) | (lru_q[8] & (~lru_op_vec[8]));
   assign lru_d[9] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :
                     (lru_reset_vec[9] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[9] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                     (lru_set_vec[9] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[9] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                     lru_q[9];
   assign lru_eff[9] = (lru_vp_vec[9] & lru_op_vec[9]) | (lru_q[9] & (~lru_op_vec[9]));
   assign lru_d[10] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :
                      (lru_reset_vec[10] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[10] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                      (lru_set_vec[10] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[10] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                      lru_q[10];
   assign lru_eff[10] = (lru_vp_vec[10] & lru_op_vec[10]) | (lru_q[10] & (~lru_op_vec[10]));
   assign lru_d[11] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :
                      (lru_reset_vec[11] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[11] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                      (lru_set_vec[11] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[11] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                      lru_q[11];
   assign lru_eff[11] = (lru_vp_vec[11] & lru_op_vec[11]) | (lru_q[11] & (~lru_op_vec[11]));
   assign lru_d[12] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :
                      (lru_reset_vec[12] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[12] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                      (lru_set_vec[12] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[12] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                      lru_q[12];
   assign lru_eff[12] = (lru_vp_vec[12] & lru_op_vec[12]) | (lru_q[12] & (~lru_op_vec[12]));
   assign lru_d[13] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :
                      (lru_reset_vec[13] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[13] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                      (lru_set_vec[13] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[13] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                      lru_q[13];
   assign lru_eff[13] = (lru_vp_vec[13] & lru_op_vec[13]) | (lru_q[13] & (~lru_op_vec[13]));
   assign lru_d[14] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :
                      (lru_reset_vec[14] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[14] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                      (lru_set_vec[14] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[14] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                      lru_q[14];
   assign lru_eff[14] = (lru_vp_vec[14] & lru_op_vec[14]) | (lru_q[14] & (~lru_op_vec[14]));
   assign lru_d[15] = ((ex6_ieratwe_ws3 == 1'b1 & mmucr1_q[0] == 1'b0) | flash_invalidate == 1'b1) ? 1'b0 :
                      (lru_reset_vec[15] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[15] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b0 :
                      (lru_set_vec[15] == 1'b1 & mmucr1_q[0] == 1'b0 & lru_op_vec[15] == 1'b0 & ccr2_frat_paranoia_q[9] == 1'b0 & (lru_update_event_q[8] == 1'b1 | (lru_update_event_q[4] & (~(iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig))) == 1'b1)) ? 1'b1 :
                      lru_q[15];
   assign lru_eff[15] = (lru_vp_vec[15] & lru_op_vec[15]) | (lru_q[15] & (~lru_op_vec[15]));

   // RMT override enable:  Op= OR(all RMT entries below and left of p) XOR OR(all RMT entries below and right of p)
   assign lru_op_vec[1] = (lru_rmt_vec[0] | lru_rmt_vec[1] | lru_rmt_vec[2] | lru_rmt_vec[3] | lru_rmt_vec[4] | lru_rmt_vec[5] | lru_rmt_vec[6] | lru_rmt_vec[7]) ^ (lru_rmt_vec[8] | lru_rmt_vec[9] | lru_rmt_vec[10] | lru_rmt_vec[11] | lru_rmt_vec[12] | lru_rmt_vec[13] | lru_rmt_vec[14] | lru_rmt_vec[15]);
   assign lru_op_vec[2] = (lru_rmt_vec[0] | lru_rmt_vec[1] | lru_rmt_vec[2] | lru_rmt_vec[3]) ^ (lru_rmt_vec[4] | lru_rmt_vec[5] | lru_rmt_vec[6] | lru_rmt_vec[7]);
   assign lru_op_vec[3] = (lru_rmt_vec[8] | lru_rmt_vec[9] | lru_rmt_vec[10] | lru_rmt_vec[11]) ^ (lru_rmt_vec[12] | lru_rmt_vec[13] | lru_rmt_vec[14] | lru_rmt_vec[15]);
   assign lru_op_vec[4] = (lru_rmt_vec[0] | lru_rmt_vec[1]) ^ (lru_rmt_vec[2] | lru_rmt_vec[3]);
   assign lru_op_vec[5] = (lru_rmt_vec[4] | lru_rmt_vec[5]) ^ (lru_rmt_vec[6] | lru_rmt_vec[7]);
   assign lru_op_vec[6] = (lru_rmt_vec[8] | lru_rmt_vec[9]) ^ (lru_rmt_vec[10] | lru_rmt_vec[11]);
   assign lru_op_vec[7] = (lru_rmt_vec[12] | lru_rmt_vec[13]) ^ (lru_rmt_vec[14] | lru_rmt_vec[15]);
   assign lru_op_vec[8] = lru_rmt_vec[0] ^ lru_rmt_vec[1];
   assign lru_op_vec[9] = lru_rmt_vec[2] ^ lru_rmt_vec[3];
   assign lru_op_vec[10] = lru_rmt_vec[4] ^ lru_rmt_vec[5];
   assign lru_op_vec[11] = lru_rmt_vec[6] ^ lru_rmt_vec[7];
   assign lru_op_vec[12] = lru_rmt_vec[8] ^ lru_rmt_vec[9];
   assign lru_op_vec[13] = lru_rmt_vec[10] ^ lru_rmt_vec[11];
   assign lru_op_vec[14] = lru_rmt_vec[12] ^ lru_rmt_vec[13];
   assign lru_op_vec[15] = lru_rmt_vec[14] ^ lru_rmt_vec[15];

   // RMT override value: Vp= OR(all RMT entries below and right of p)
   assign lru_vp_vec[1] = (lru_rmt_vec[8] | lru_rmt_vec[9] | lru_rmt_vec[10] | lru_rmt_vec[11] | lru_rmt_vec[12] | lru_rmt_vec[13] | lru_rmt_vec[14] | lru_rmt_vec[15]);
   assign lru_vp_vec[2] = (lru_rmt_vec[4] | lru_rmt_vec[5] | lru_rmt_vec[6] | lru_rmt_vec[7]);
   assign lru_vp_vec[3] = (lru_rmt_vec[12] | lru_rmt_vec[13] | lru_rmt_vec[14] | lru_rmt_vec[15]);
   assign lru_vp_vec[4] = (lru_rmt_vec[2] | lru_rmt_vec[3]);
   assign lru_vp_vec[5] = (lru_rmt_vec[6] | lru_rmt_vec[7]);
   assign lru_vp_vec[6] = (lru_rmt_vec[10] | lru_rmt_vec[11]);
   assign lru_vp_vec[7] = (lru_rmt_vec[14] | lru_rmt_vec[15]);
   assign lru_vp_vec[8] = lru_rmt_vec[1];
   assign lru_vp_vec[9] = lru_rmt_vec[3];
   assign lru_vp_vec[10] = lru_rmt_vec[5];
   assign lru_vp_vec[11] = lru_rmt_vec[7];
   assign lru_vp_vec[12] = lru_rmt_vec[9];
   assign lru_vp_vec[13] = lru_rmt_vec[11];
   assign lru_vp_vec[14] = lru_rmt_vec[13];
   assign lru_vp_vec[15] = lru_rmt_vec[15];

   // mmucr1_q: 0-IRRE, 1-REE, 2-CEE, 3-csync_dis, 4-isync_dis, 5:6-IPEI, 7:8-ICTID/ITTID

// Encoder for the LRU watermark psuedo-RMT
/*
//table_start
?TABLE lru_rmt_vec LISTING(final) OPTIMIZE PARMS(ON-SET, OFF-SET);
*INPUTS*==================*OUTPUTS*============*
|                         |                    |
| mmucr1_q                |  lru_rmt_vec       |
| |         watermark_q   |  |                 |
| |         |             |  |                 |
| |         |             |  |                 |
| |         |             |  |         111111  |
| 012345678 0123          |  0123456789012345  |
*TYPE*====================+====================+
| PPPPPPPPP PPPP          |  PPPPPPPPPPPPPPPP  |
*OPTIMIZE*--------------->|  AAAAAAAAAAAAAAAA  |
*TERMS*===================+====================+
| 1-------- ----          |  1111111111111111  |  round-robin enabled
| 0-------- 0000          |  1000000000000000  |
| 0-------- 0001          |  1100000000000000  |
| 0-------- 0010          |  1110000000000000  |
| 0-------- 0011          |  1111000000000000  |
| 0-------- 0100          |  1111100000000000  |
| 0-------- 0101          |  1111110000000000  |
| 0-------- 0110          |  1111111000000000  |
| 0-------- 0111          |  1111111100000000  |
| 0-------- 1000          |  1111111110000000  |
| 0-------- 1001          |  1111111111000000  |
| 0-------- 1010          |  1111111111100000  |
| 0-------- 1011          |  1111111111110000  |
| 0-------- 1100          |  1111111111111000  |
| 0-------- 1101          |  1111111111111100  |
| 0-------- 1110          |  1111111111111110  |
| 0-------- 1111          |  1111111111111111  |
*END*=====================+====================+
?TABLE END lru_rmt_vec;
//table_end
*/

/*
//table_start
?TABLE lru_watermark_mask LISTING(final) OPTIMIZE PARMS(ON-SET, OFF-SET);
*INPUTS*==================*OUTPUTS*===============*
|                         |                       |
| mmucr1_q                |  lru_watermark_mask   |
| |         watermark_q   |  |                    |
| |         |             |  |                    |
| |         |             |  |                    |
| |         |             |  |         111111     |
| 012345678 0123          |  0123456789012345     |
*TYPE*====================+=======================+
| PPPPPPPPP PPPP          |  PPPPPPPPPPPPPPPP     |
*OPTIMIZE*--------------->|  AAAAAAAAAAAAAAAA     |
*TERMS*===================+=======================+
| --------- 0000          |  0111111111111111     |
| --------- 0001          |  0011111111111111     |
| --------- 0010          |  0001111111111111     |
| --------- 0011          |  0000111111111111     |
| --------- 0100          |  0000011111111111     |
| --------- 0101          |  0000001111111111     |
| --------- 0110          |  0000000111111111     |
| --------- 0111          |  0000000011111111     |
| --------- 1000          |  0000000001111111     |
| --------- 1001          |  0000000000111111     |
| --------- 1010          |  0000000000011111     |
| --------- 1011          |  0000000000001111     |
| --------- 1100          |  0000000000000111     |
| --------- 1101          |  0000000000000011     |
| --------- 1110          |  0000000000000001     |
| --------- 1111          |  0000000000000000     |
*END*=====================+=======================+
?TABLE END lru_watermark_mask;
//table_end
*/

   assign entry_valid_watermarked = entry_valid_q | lru_watermark_mask;

   // lru_update_event
   // 0: tlb reload
   // 1: invalidate snoop
   // 2: csync or isync enabled
   // 3: eratwe WS=0
   // 4: fetch hit
   // 5: iu2 cam write type events
   // 6: iu2 cam invalidate type events
   // 7: iu2 cam translation type events
   // 8: superset, ex2
   // 9: superset, delayed to ex3

// logic for the LRU reset and set bit vectors
/*
//table_start
?TABLE lru_set_reset_vec LISTING(final) OPTIMIZE PARMS(ON-SET);
*INPUTS*======================================================*OUTPUTS*===========================*
|                                                             |                                   |
| lru_update_event_q                                          |  lru_reset_vec                    |
| |         entry_valid_watermarked                           |  |                lru_set_vec     |
| |         |                lru_q                            |  |                |               |
| |         |                |               entry_match_q    |  |                |               |
| |         |                |               |                |  |                |               |
| |         |         111111 |        111111 |         111111 |  |        111111  |        111111 |
| 012345678 0123456789012345 123456789012345 0123456789012345 |  123456789012345  123456789012345 |
*TYPE*========================================================+===================================+
| PPPPPPPPP PPPPPPPPPPPPPPPP PPPPPPPPPPPPPPP PPPPPPPPPPPPPPPP |  PPPPPPPPPPPPPPP  PPPPPPPPPPPPPPP |
*OPTIMIZE*--------------------------------------------------->|  AAAAAAAAAAAAAAA  BBBBBBBBBBBBBBB |
*TERMS*=======================================================+===================================+
| --------- 0--------------- --------------- ---------------- |  11-1---1-------  00-0---0------- |  cam not full, point to a nonvalid entry
| --------- 10-------------- --------------- ---------------- |  11-1---0-------  00-0---1------- |
| --------- 110------------- --------------- ---------------- |  11-0----1------  00-1----0------ |
| --------- 1110------------ --------------- ---------------- |  11-0----0------  00-1----1------ |
| --------- 11110----------- --------------- ---------------- |  10--1----1-----  01--0----0----- |
| --------- 111110---------- --------------- ---------------- |  10--1----0-----  01--0----1----- |
| --------- 1111110--------- --------------- ---------------- |  10--0-----1----  01--1-----0---- |
| --------- 11111110-------- --------------- ---------------- |  10--0-----0----  01--1-----1---- |
| --------- 111111110------- --------------- ---------------- |  0-1--1-----1---  1-0--0-----0--- |
| --------- 1111111110------ --------------- ---------------- |  0-1--1-----0---  1-0--0-----1--- |
| --------- 11111111110----- --------------- ---------------- |  0-1--0------1--  1-0--1------0-- |
| --------- 111111111110---- --------------- ---------------- |  0-1--0------0--  1-0--1------1-- |
| --------- 1111111111110--- --------------- ---------------- |  0-0---1------1-  1-1---0------0- |
| --------- 11111111111110-- --------------- ---------------- |  0-0---1------0-  1-1---0------1- |
| --------- 111111111111110- --------------- ---------------- |  0-0---0-------1  1-1---1-------0 |
| --------- 1111111111111110 --------------- ---------------- |  0-0---0-------0  1-1---1-------1 |
| -----1--- 1111111111111111 00-0---0------- ---------------- |  00-0---0-------  11-1---1------- |  cam full, write moves away from current lru
| -----1--- 1111111111111111 00-0---1------- ---------------- |  00-0---1-------  11-1---0------- |
| -----1--- 1111111111111111 00-1----0------ ---------------- |  00-1----0------  11-0----1------ |
| -----1--- 1111111111111111 00-1----1------ ---------------- |  00-1----1------  11-0----0------ |
| -----1--- 1111111111111111 01--0----0----- ---------------- |  01--0----0-----  10--1----1----- |
| -----1--- 1111111111111111 01--0----1----- ---------------- |  01--0----1-----  10--1----0----- |
| -----1--- 1111111111111111 01--1-----0---- ---------------- |  01--1-----0----  10--0-----1---- |
| -----1--- 1111111111111111 01--1-----1---- ---------------- |  01--1-----1----  10--0-----0---- |
| -----1--- 1111111111111111 1-0--0-----0--- ---------------- |  1-0--0-----0---  0-1--1-----1--- |
| -----1--- 1111111111111111 1-0--0-----1--- ---------------- |  1-0--0-----1---  0-1--1-----0--- |
| -----1--- 1111111111111111 1-0--1------0-- ---------------- |  1-0--1------0--  0-1--0------1-- |
| -----1--- 1111111111111111 1-0--1------1-- ---------------- |  1-0--1------1--  0-1--0------0-- |
| -----1--- 1111111111111111 1-1---0------0- ---------------- |  1-1---0------0-  0-0---1------1- |
| -----1--- 1111111111111111 1-1---0------1- ---------------- |  1-1---0------1-  0-0---1------0- |
| -----1--- 1111111111111111 1-1---1-------0 ---------------- |  1-1---1-------0  0-0---0-------1 |
| -----1--- 1111111111111111 1-1---1-------1 ---------------- |  1-1---1-------1  0-0---0-------0 |
| -----001- 1111111111111111 --------------- 1--------------- |  00-0---0-------  11-1---1------- |  cam full, hit moves away from match entr
| -----001- 1111111111111111 --------------- 01-------------- |  00-0---1-------  11-1---0------- |
| -----001- 1111111111111111 --------------- 001------------- |  00-1----0------  11-0----1------ |
| -----001- 1111111111111111 --------------- 0001------------ |  00-1----1------  11-0----0------ |
| -----001- 1111111111111111 --------------- 00001----------- |  01--0----0-----  10--1----1----- |
| -----001- 1111111111111111 --------------- 000001---------- |  01--0----1-----  10--1----0----- |
| -----001- 1111111111111111 --------------- 0000001--------- |  01--1-----0----  10--0-----1---- |
| -----001- 1111111111111111 --------------- 00000001-------- |  01--1-----1----  10--0-----0---- |
| -----001- 1111111111111111 --------------- 000000001------- |  1-0--0-----0---  0-1--1-----1--- |
| -----001- 1111111111111111 --------------- 0000000001------ |  1-0--0-----1---  0-1--1-----0--- |
| -----001- 1111111111111111 --------------- 00000000001----- |  1-0--1------0--  0-1--0------1-- |
| -----001- 1111111111111111 --------------- 000000000001---- |  1-0--1------1--  0-1--0------0-- |
| -----001- 1111111111111111 --------------- 0000000000001--- |  1-1---0------0-  0-0---1------1- |
| -----001- 1111111111111111 --------------- 00000000000001-- |  1-1---0------1-  0-0---1------0- |
| -----001- 1111111111111111 --------------- 000000000000001- |  1-1---1-------0  0-0---0-------1 |
| -----001- 1111111111111111 --------------- 0000000000000001 |  1-1---1-------1  0-0---0-------0 |
*END*=========================================================+===================================+
?TABLE END lru_set_reset_vec;
//table_end
*/


// Encoder for the LRU selected entry
/*
//table_start
?TABLE lru_way_encode LISTING(final) OPTIMIZE PARMS(ON-SET, OFF-SET);
*INPUTS*==========================*OUTPUTS*==========*
|                                 |                  |
| mmucr1_q                        |  lru_way_encode  |
| |         lru_eff               |  |               |
| |         |                     |  |               |
| |         |                     |  |               |
| |         |        111111       |  |               |
| 012345678 123456789012345       |  0123            |
*TYPE*============================+==================+
| PPPPPPPPP PPPPPPPPPPPPPPP       |  PPPP            |
*OPTIMIZE*----------------------->|  AAAA            |
*TERMS*===========================+==================+
| --------- 00-0---0-------       |  0000            |
| --------- 00-0---1-------       |  0001            |
| --------- 00-1----0------       |  0010            |
| --------- 00-1----1------       |  0011            |
| --------- 01--0----0-----       |  0100            |
| --------- 01--0----1-----       |  0101            |
| --------- 01--1-----0----       |  0110            |
| --------- 01--1-----1----       |  0111            |
| --------- 1-0--0-----0---       |  1000            |
| --------- 1-0--0-----1---       |  1001            |
| --------- 1-0--1------0--       |  1010            |
| --------- 1-0--1------1--       |  1011            |
| --------- 1-1---0------0-       |  1100            |
| --------- 1-1---0------1-       |  1101            |
| --------- 1-1---1-------0       |  1110            |
| --------- 1-1---1-------1       |  1111            |
*END*=============================+==================+
?TABLE END lru_way_encode;
//table_end
*/

   // power-on reset sequencer to load initial erat entries
   always @(por_seq_q or init_alias or bcfg_q[0:106])
   begin: Por_Sequencer
      por_wr_cam_val    <= 2'b0;
      por_wr_array_val  <= 2'b0;
      por_wr_cam_data   <= {cam_data_width{1'b0}};
      por_wr_array_data <= {array_data_width{1'b0}};
      por_wr_entry      <= {num_entry_log2{1'b0}};

      case (por_seq_q)
         // install initial erat entry sequencer
         PorSeq_Idle :
            begin
               por_wr_cam_val   <= 2'b0;
               por_wr_array_val <= 2'b0;
               por_hold_req <= {`THREADS{init_alias}};

               if (init_alias == 1'b1)   // reset is asserted
                  por_seq_d <= PorSeq_Stg1;
               else
                  por_seq_d <= PorSeq_Idle;
            end
         PorSeq_Stg1 :
            begin
            // let cam see the reset gone
               por_wr_cam_val <= 2'b0;
               por_wr_array_val <= 2'b0;
               por_seq_d <= PorSeq_Stg2;
               por_hold_req <= {`THREADS{1'b1}};
            end

         PorSeq_Stg2 :
            begin
            // write cam entry 0
               por_wr_cam_val <= {2{1'b1}};
               por_wr_array_val <= {2{1'b1}};
               por_wr_entry <= Por_Wr_Entry_Num1;
               por_wr_cam_data <= {bcfg_q[0:51], Por_Wr_Cam_Data1[52:83]};
               // 16x143 version, 42b RA
               // wr_array_data
               //  0:29  - RPN
               //  30:31  - R,C
               //  32:33  - WLC
               //  34     - ResvAttr
               //  35     - VF
               //  36:39  - U0-U3
               //  40:44  - WIMGE
               //  45:46  - UX,SX
               //  47:48  - UW,SW
               //  49:50  - UR,SR
               //  51:60  - CAM parity
               //  61:67  - Array parity
               por_wr_array_data <= {bcfg_q[52:81], Por_Wr_Array_Data1[30:35], bcfg_q[82:85], Por_Wr_Array_Data1[40:43], bcfg_q[86], Por_Wr_Array_Data1[45:67]};  // 16x143 version
               por_hold_req <= {`THREADS{1'b1}};
               por_seq_d <= PorSeq_Stg3;
            end

         PorSeq_Stg3 :
            begin
            // de-assert the cam write
               por_wr_cam_val <= 2'b0;
               por_wr_array_val <= 2'b0;
               por_hold_req <= {`THREADS{1'b1}};
               por_seq_d <= PorSeq_Stg4;
            end

         PorSeq_Stg4 :
            begin
            // write cam entry 1
               por_wr_cam_val <= {2{1'b1}};
               por_wr_array_val <= {2{1'b1}};
               por_wr_entry <= Por_Wr_Entry_Num2;
               por_wr_cam_data <= Por_Wr_Cam_Data2;

               por_wr_array_data <= {bcfg_q[52:61], bcfg_q[87:106], Por_Wr_Array_Data2[30:35], bcfg_q[82:85], Por_Wr_Array_Data2[40:43], bcfg_q[86], Por_Wr_Array_Data2[45:67]};  // same 22:31, unique 32:51
               por_hold_req <= {`THREADS{1'b1}};
               por_seq_d <= PorSeq_Stg5;
            end

         PorSeq_Stg5 :
            begin
            // de-assert the cam write
               por_wr_cam_val <= 2'b0;
               por_wr_array_val <= 2'b0;
               por_hold_req <= {`THREADS{1'b1}};
               por_seq_d <= PorSeq_Stg6;
            end

         PorSeq_Stg6 :
            begin
            // release thread hold
               por_wr_cam_val <= 2'b0;
               por_wr_array_val <= 2'b0;
               por_hold_req <= {`THREADS{1'b0}};
               por_seq_d <= PorSeq_Stg7;
            end

         PorSeq_Stg7 :
            begin
            // all done.. hang out here until reset removed
               por_wr_cam_val <= 2'b0;
               por_wr_array_val <= 2'b0;
               por_hold_req <= {`THREADS{1'b0}};

               if (init_alias == 1'b0)  // reset removed, go idle
                  por_seq_d <= PorSeq_Idle;
               else
                  por_seq_d <= PorSeq_Stg7;
            end

         default :
            por_seq_d <= PorSeq_Idle;  // go idle
      endcase
   end

   assign cam_pgsize[0:2] = (CAM_PgSize_1GB  & {3{ex6_data_in_q[56:59] == WS0_PgSize_1GB }}) |
                            (CAM_PgSize_16MB & {3{ex6_data_in_q[56:59] == WS0_PgSize_16MB}}) |
                            (CAM_PgSize_1MB  & {3{ex6_data_in_q[56:59] == WS0_PgSize_1MB }}) |
                            (CAM_PgSize_64KB & {3{ex6_data_in_q[56:59] == WS0_PgSize_64KB}}) |
                            (CAM_PgSize_4KB  & {3{~((ex6_data_in_q[56:59] == WS0_PgSize_1GB)  |
                                                    (ex6_data_in_q[56:59] == WS0_PgSize_16MB) |
                                                    (ex6_data_in_q[56:59] == WS0_PgSize_1MB)  |
                                                    (ex6_data_in_q[56:59] == WS0_PgSize_64KB))}});

   assign ws0_pgsize[0:3] = (WS0_PgSize_1GB  & {4{rd_cam_data[53:55] == CAM_PgSize_1GB }}) |
                            (WS0_PgSize_16MB & {4{rd_cam_data[53:55] == CAM_PgSize_16MB}}) |
                            (WS0_PgSize_1MB  & {4{rd_cam_data[53:55] == CAM_PgSize_1MB }}) |
                            (WS0_PgSize_64KB & {4{rd_cam_data[53:55] == CAM_PgSize_64KB}}) |
                            (WS0_PgSize_4KB  & {4{rd_cam_data[53:55] == CAM_PgSize_4KB }});

   // CAM control signal assignments
   // ttype: eratre & eratwe & eratsx & erativax;
   // mmucr1_q: 0-IRRE, 1-REE, 2-CEE, 3-csync_dis, 4-isync_dis, 5:6-IPEI, 7:8-ICTID/ITTID

   assign csinv_complete = |(cp_ic_csinv_comp_q[2:3]);  // csync or isync enabled and complete

   assign rd_val = (|(ex2_valid_q)) & ex2_ttype_q[0] & (ex2_tlbsel_q == TlbSel_IErat);  // eratre ttype

   assign rw_entry = (por_wr_entry   & {4{|(por_seq_q)}}) |
                     (eptr_q         & {4{(|(tlb_rel_val_q[0:3])) & tlb_rel_val_q[4] &   mmucr1_q[0]}}) |   // tlb hit reload, rrobin mode
                     (lru_way_encode & {4{(|(tlb_rel_val_q[0:3])) & tlb_rel_val_q[4] & (~mmucr1_q[0])}}) |   // tlb hit reload LRU
                     (eptr_q         & {4{(|(ex6_valid_q[0:`THREADS-1])) & ex6_ttype_q[1] & (ex6_tlbsel_q == TlbSel_IErat) & (~tlb_rel_val_q[4]) & mmucr1_q[0]}}) |   // eratwe, rrobin mode
                     (ex6_ra_entry_q & {4{(|(ex6_valid_q[0:`THREADS-1])) & ex6_ttype_q[1] & (ex6_tlbsel_q == TlbSel_IErat) & (~tlb_rel_val_q[4]) & (~mmucr1_q[0])}}) |   // eratwe
                     (ex2_ra_entry_q & {4{(|(ex2_valid_q)) & ex2_ttype_q[0] & (~( (|(ex6_valid_q[0:`THREADS - 1])) & ex6_ttype_q[1] & (ex6_tlbsel_q == TlbSel_IErat))) & (~tlb_rel_val_q[4])}});  // eratre

   // Write Port
   //  wr_cam_val(0) -> epn(0:51), xbit, size(0:2), V, ThdID, class(0:1), cmpmask(0:7), cmpmask_par
   //  wr_cam_val(1) -> extclass, tid_nz, gs, as, pid(6:13)
   assign wr_cam_val = (por_seq_q != PorSeq_Idle) ? por_wr_cam_val :
                       (csinv_complete == 1'b1) ? 2'b0 :    // csync or isync enabled and complete
                       (tlb_rel_val_q[0:3] != 4'b0000 & tlb_rel_val_q[4] == 1'b1) ? {2{tlb_rel_data_q[eratpos_wren]}} :   // tlb hit reload
                       ((|(ex6_valid_q[0:`THREADS-1])) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_ws_q == 2'b00 & ex6_tlbsel_q == TlbSel_IErat) ? {2{1'b1}} :   // eratwe WS=0
                       2'b0;

   // write port act pin
   assign wr_val_early = (|(por_seq_q)) |
                         (|(tlb_req_inprogress_q)) |
                         ( (|(ex5_valid_q)) & ex5_ttype_q[1] & (ex5_ws_q == 2'b00) & (ex5_tlbsel_q == TlbSel_IErat)) |   // ex5 eratwe WS=0
                         ( (|(ex6_valid_q[0:`THREADS - 1])) & ex6_ttype_q[1] & (ex6_ws_q == 2'b00) & (ex6_tlbsel_q == TlbSel_IErat));   // ex6 eratwe WS=0

   //state <= PR & GS or mmucr0(8) & IS or mmucr0(9)

   // tlb_low_data
   //  0:51  - EPN
   //  52:55  - SIZE (4b)
   //  56:59  - ThdID
   //  60:61  - Class
   //  62  - ExtClass
   //  63  - TID_NZ
   //  64:65  - reserved (2b)
   //  66:73  - 8b for LPID
   //  74:83  - parity 10bits

   // wr_ws0_data (LO)
   //  0:51  - EPN
   //  52:53  - Class
   //  54  - V
   //  55  - X
   //  56:59  - SIZE
   //  60:63  - ThdID

   // wr_cam_data
   //  0:51  - EPN
   //  52  - X
   //  53:55  - SIZE
   //  56  - V
   //  57:60  - ThdID
   //  61:62  - Class
   //  63:64  - ExtClass | TID_NZ
   //  65  - TGS
   //  66  - TS
   //  67:74  - TID
   //  75:78  - epn_cmpmasks:  34_39, 40_43, 44_47, 48_51
   //  79:82  - xbit_cmpmasks: 34_51, 40_51, 44_51, 48_51
   //  83  - parity for 75:82

   //--------- this is what the erat expects on reload bus
   //  0:51  - EPN
   //  52  - X
   //  53:55  - SIZE
   //  56  - V
   //  57:60  - ThdID
   //  61:62  - Class
   //  63:64  - ExtClass | TID_NZ
   //  65  - write enable

   //  0:3 66:69 - reserved RPN
   //  4:33 70:99 - RPN
   //  34:35 100:101 - R,C
   //  36 102 - reserved
   //  37:38 103:104 - WLC
   //  39 105 - ResvAttr
   //  40 106 - VF
   //  41:44 107:110 - U0-U3
   //  45:49 111:115 - WIMGE
   //  50:51 116:117 - UX,SX
   //  52:53 118:119 - UW,SW
   //  54:55 120:121 - UR,SR
   //  56 122 - GS
   //  57 123 - TS
   //  58:65 124:131 - TID lsbs

   // mmucr1_q: 0-IRRE, 1-REE, 2-CEE, 3-csync_dis, 4-isync_dis, 5:6-IPEI, 7:8-ICTID/ITTID

   generate
      if (rs_data_width == 64)
      begin : gen64_wr_cam_data
         assign wr_cam_data = (por_wr_cam_data & {84{(por_seq_q[0] | por_seq_q[1] | por_seq_q[2])}}) |
                              (({tlb_rel_data_q[0:64], tlb_rel_data_q[122:131], tlb_rel_cmpmask[0:3], tlb_rel_xbitmask[0:3], tlb_rel_maskpar}) &
                              ({84{((tlb_rel_val_q[0] | tlb_rel_val_q[1] | tlb_rel_val_q[2] | tlb_rel_val_q[3]) & tlb_rel_val_q[4])}})) |
                              (({(ex6_data_in_q[0:31] & ({32{ex6_state_q[3]}})), ex6_data_in_q[32:51],
                                  ex6_data_in_q[55], cam_pgsize[0:2], ex6_data_in_q[54],
                                 (({ex6_data_in_q[60:61], 2'b00} & {4{~(mmucr1_q[8])}}) | (ex6_pid_q[pid_width-12 : pid_width-9] & {4{mmucr1_q[8]}})),
                                 (( ex6_data_in_q[52:53] & {2{~(mmucr1_q[7])}}) | (ex6_pid_q[pid_width-14 : pid_width-13] & {2{mmucr1_q[7]}})),
                                  ex6_extclass_q, ex6_state_q[1:2], ex6_pid_q[pid_width - 8:pid_width - 1],
                               ex6_data_cmpmask[0:3], ex6_data_xbitmask[0:3], ex6_data_maskpar}) &
                               ({84{(|(ex6_valid_q[0:`THREADS - 1]) & ex6_ttype_q[1] & (~ex6_ws_q[0]) & (~ex6_ws_q[1]) & (~tlb_rel_val_q[4]))}}));
      end
   endgenerate

   generate
      if (rs_data_width == 32)
      begin : gen32_wr_cam_data
         assign wr_cam_data = (por_wr_cam_data & ({84{(por_seq_q[0] | por_seq_q[1] | por_seq_q[2])}})) |
                              (({tlb_rel_data_q[0:64], tlb_rel_data_q[122:131], tlb_rel_cmpmask[0:3], tlb_rel_xbitmask[0:3], tlb_rel_maskpar}) &
                              ({84{((tlb_rel_val_q[0] | tlb_rel_val_q[1] | tlb_rel_val_q[2] | tlb_rel_val_q[3]) & tlb_rel_val_q[4])}})) |
                              (({({32{1'b0}}), ex6_data_in_q[32:51], ex6_data_in_q[55], cam_pgsize[0:2], ex6_data_in_q[54],
                              (({ex6_data_in_q[60:61], 2'b00} & {4{~(mmucr1_q[8])}}) | (ex6_pid_q[pid_width-12 : pid_width-9] & {4{(mmucr1_q[8])}})),
                              (( ex6_data_in_q[52:53] & {2{~(mmucr1_q[7])}}) | (ex6_pid_q[pid_width-14 : pid_width-13] & {2{(mmucr1_q[7])}})),
                              ex6_extclass_q, ex6_state_q[1:2], ex6_pid_q[pid_width - 8:pid_width - 1], ex6_data_cmpmask[0:3], ex6_data_xbitmask[0:3], ex6_data_maskpar}) &
                              ({84{(|(ex6_valid_q[0:`THREADS - 1]) & ex6_ttype_q[1] & (~ex6_ws_q[0]) & (~ex6_ws_q[1]) & (~tlb_rel_val_q[4]))}}));
      end
   endgenerate

   //             cmpmask(0)    (1)     (2)    (3)    xbitmask(0)    (1)    (2)    (3)
   //   xbit  pgsize      34_39  40_43  44_47  48_51           34_39  40_43  44_47  48_51    size
   //    0     001          1      1      1      1               0      0      0      0       4K
   //    0     011          1      1      1      0               0      0      0      0       64K
   //    0     101          1      1      0      0               0      0      0      0       1M
   //    0     111          1      0      0      0               0      0      0      0       16M
   //    0     110          0      0      0      0               0      0      0      0       1G
   //    1     001          1      1      1      1               0      0      0      0       4K
   //    1     011          1      1      1      0               0      0      0      1       64K
   //    1     101          1      1      0      0               0      0      1      0       1M
   //    1     111          1      0      0      0               0      1      0      0       16M
   //    1     110          0      0      0      0               1      0      0      0       1G


// Encoder for the cam compare mask bits write data
/*
//table_start
?TABLE cam_mask_bits LISTING(final) OPTIMIZE PARMS(ON-SET, OFF-SET);
*INPUTS*==================*OUTPUTS*===================================*
|                         |                                           |
| tlb_rel_data_q          |  tlb_rel_cmpmask                          |
| |    ex6_data_in_q      |  |    tlb_rel_xbitmask                    |
| |    |                  |  |    |    tlb_rel_maskpar                |
| |    |                  |  |    |    |  ex6_data_cmpmask            |
| |    |                  |  |    |    |  |    ex6_data_xbitmask      |
| |    |                  |  |    |    |  |    |    ex6_data_maskpar  |
| |    |                  |  |    |    |  |    |    |                 |
| 5555 55555              |  |    |    |  |    |    |                 |
| 2345 56789              |  0123 0123 |  0123 0123 |                 |
*TYPE*====================+===========================================+
| PPPP PPPPP              |  PPPP PPPP P  PPPP PPPP P                 |
*OPTIMIZE*--------------->|  AAAA AAAA A  AAAA AAAA A                 |
*TERMS*===================+===========================================+
| 0001 -----              |  1111 0000 0  ---- ---- -                 |  tlb reload, xbit=0, 4K
| 0011 -----              |  1110 0000 1  ---- ---- -                 |  tlb reload, xbit=0, 64K
| 0101 -----              |  1100 0000 0  ---- ---- -                 |  tlb reload, xbit=0, 1M
| 0111 -----              |  1000 0000 1  ---- ---- -                 |  tlb reload, xbit=0, 16M
| 0110 -----              |  0000 0000 0  ---- ---- -                 |  tlb reload, xbit=0, 1G
| 1001 -----              |  1111 0000 0  ---- ---- -                 |  tlb reload, xbit=1, no xmask, 4K
| 1011 -----              |  1110 0001 0  ---- ---- -                 |  tlb reload, xbit=1, xmask_48_51=1, 64K
| 1101 -----              |  1100 0010 1  ---- ---- -                 |  tlb reload, xbit=1, xmask_44_51=1, 1M
| 1111 -----              |  1000 0100 0  ---- ---- -                 |  tlb reload, xbit=1, xmask_40_51=1, 16M
| 1110 -----              |  0000 1000 1  ---- ---- -                 |  tlb reload, xbit=1, xmask_34_51=1, 1G
| ---- 00001              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=0, 4K
| ---- 00011              |  ---- ---- -  1110 0000 1                 |  eratwe, xbit=0, 64K
| ---- 00101              |  ---- ---- -  1100 0000 0                 |  eratwe, xbit=0, 1M
| ---- 00111              |  ---- ---- -  1000 0000 1                 |  eratwe, xbit=0, 16M
| ---- 01010              |  ---- ---- -  0000 0000 0                 |  eratwe, xbit=0, 1G
| ---- 00000              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=0, default to 4K
| ---- 00010              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=0, default to 4K
| ---- 00100              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=0, default to 4K
| ---- 00110              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=0, default to 4K
| ---- 01000              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=0, default to 4K
| ---- 01001              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=0, default to 4K
| ---- 01011              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=0, default to 4K
| ---- 01100              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=0, default to 4K
| ---- 01101              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=0, default to 4K
| ---- 01110              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=0, default to 4K
| ---- 01111              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=0, default to 4K
| ---- 10001              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=1, no xmask, 4K
| ---- 10011              |  ---- ---- -  1110 0001 0                 |  eratwe, xbit=1, xmask_48_51=1, 64K
| ---- 10101              |  ---- ---- -  1100 0010 1                 |  eratwe, xbit=1, xmask_44_51=1, 1M
| ---- 10111              |  ---- ---- -  1000 0100 0                 |  eratwe, xbit=1, xmask_40_51=1, 16M
| ---- 11010              |  ---- ---- -  0000 1000 1                 |  eratwe, xbit=1, xmask_34_51=1, 1G
| ---- 10000              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=1, default to 4K
| ---- 10010              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=1, default to 4K
| ---- 10100              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=1, default to 4K
| ---- 10110              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=1, default to 4K
| ---- 11000              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=1, default to 4K
| ---- 11001              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=1, default to 4K
| ---- 11011              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=1, default to 4K
| ---- 11100              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=1, default to 4K
| ---- 11101              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=1, default to 4K
| ---- 11110              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=1, default to 4K
| ---- 11111              |  ---- ---- -  1111 0000 0                 |  eratwe, xbit=1, default to 4K
*END*=====================+===========================================+
?TABLE END cam_mask_bits;
//table_end
*/

//assign_start

assign iu1_multihit_b_pt[1] =
    (({ entry_match[1] , entry_match[2] ,
    entry_match[3] , entry_match[4] ,
    entry_match[5] , entry_match[6] ,
    entry_match[7] , entry_match[8] ,
    entry_match[9] , entry_match[10] ,
    entry_match[11] , entry_match[12] ,
    entry_match[13] , entry_match[14] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[2] =
    (({ entry_match[0] , entry_match[2] ,
    entry_match[3] , entry_match[4] ,
    entry_match[5] , entry_match[6] ,
    entry_match[7] , entry_match[8] ,
    entry_match[9] , entry_match[10] ,
    entry_match[11] , entry_match[12] ,
    entry_match[13] , entry_match[14] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[3] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[3] , entry_match[4] ,
    entry_match[5] , entry_match[6] ,
    entry_match[7] , entry_match[8] ,
    entry_match[9] , entry_match[10] ,
    entry_match[11] , entry_match[12] ,
    entry_match[13] , entry_match[14] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[4] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[4] ,
    entry_match[5] , entry_match[6] ,
    entry_match[7] , entry_match[8] ,
    entry_match[9] , entry_match[10] ,
    entry_match[11] , entry_match[12] ,
    entry_match[13] , entry_match[14] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[5] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[5] , entry_match[6] ,
    entry_match[7] , entry_match[8] ,
    entry_match[9] , entry_match[10] ,
    entry_match[11] , entry_match[12] ,
    entry_match[13] , entry_match[14] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[6] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[6] ,
    entry_match[7] , entry_match[8] ,
    entry_match[9] , entry_match[10] ,
    entry_match[11] , entry_match[12] ,
    entry_match[13] , entry_match[14] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[7] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[7] , entry_match[8] ,
    entry_match[9] , entry_match[10] ,
    entry_match[11] , entry_match[12] ,
    entry_match[13] , entry_match[14] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[8] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[8] ,
    entry_match[9] , entry_match[10] ,
    entry_match[11] , entry_match[12] ,
    entry_match[13] , entry_match[14] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[9] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[9] , entry_match[10] ,
    entry_match[11] , entry_match[12] ,
    entry_match[13] , entry_match[14] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[10] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] , entry_match[10] ,
    entry_match[11] , entry_match[12] ,
    entry_match[13] , entry_match[14] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[11] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] , entry_match[9] ,
    entry_match[11] , entry_match[12] ,
    entry_match[13] , entry_match[14] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[12] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] , entry_match[9] ,
    entry_match[10] , entry_match[12] ,
    entry_match[13] , entry_match[14] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[13] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] , entry_match[9] ,
    entry_match[10] , entry_match[11] ,
    entry_match[13] , entry_match[14] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[14] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] , entry_match[9] ,
    entry_match[10] , entry_match[11] ,
    entry_match[12] , entry_match[14] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[15] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] , entry_match[9] ,
    entry_match[10] , entry_match[11] ,
    entry_match[12] , entry_match[13] ,
    entry_match[15] }) === 15'b000000000000000);
assign iu1_multihit_b_pt[16] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] , entry_match[9] ,
    entry_match[10] , entry_match[11] ,
    entry_match[12] , entry_match[13] ,
    entry_match[14] }) === 15'b000000000000000);
assign iu1_multihit_b =
    (iu1_multihit_b_pt[1] | iu1_multihit_b_pt[2]
     | iu1_multihit_b_pt[3] | iu1_multihit_b_pt[4]
     | iu1_multihit_b_pt[5] | iu1_multihit_b_pt[6]
     | iu1_multihit_b_pt[7] | iu1_multihit_b_pt[8]
     | iu1_multihit_b_pt[9] | iu1_multihit_b_pt[10]
     | iu1_multihit_b_pt[11] | iu1_multihit_b_pt[12]
     | iu1_multihit_b_pt[13] | iu1_multihit_b_pt[14]
     | iu1_multihit_b_pt[15] | iu1_multihit_b_pt[16]
    );

//assign_end
//assign_start

assign iu1_first_hit_entry_pt[1] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] , entry_match[9] ,
    entry_match[10] , entry_match[11] ,
    entry_match[12] , entry_match[13] ,
    entry_match[14] , entry_match[15]
     }) === 16'b0000000000000001);
assign iu1_first_hit_entry_pt[2] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] , entry_match[9] ,
    entry_match[10] , entry_match[11] ,
    entry_match[12] , entry_match[13] ,
    entry_match[14] }) === 15'b000000000000001);
assign iu1_first_hit_entry_pt[3] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] , entry_match[9] ,
    entry_match[10] , entry_match[11] ,
    entry_match[12] , entry_match[13]
     }) === 14'b00000000000001);
assign iu1_first_hit_entry_pt[4] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] , entry_match[9] ,
    entry_match[10] , entry_match[11] ,
    entry_match[12] }) === 13'b0000000000001);
assign iu1_first_hit_entry_pt[5] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] , entry_match[9] ,
    entry_match[10] , entry_match[11]
     }) === 12'b000000000001);
assign iu1_first_hit_entry_pt[6] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] , entry_match[9] ,
    entry_match[10] }) === 11'b00000000001);
assign iu1_first_hit_entry_pt[7] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] , entry_match[9]
     }) === 10'b0000000001);
assign iu1_first_hit_entry_pt[8] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7] ,
    entry_match[8] }) === 9'b000000001);
assign iu1_first_hit_entry_pt[9] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] , entry_match[7]
     }) === 8'b00000001);
assign iu1_first_hit_entry_pt[10] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5] ,
    entry_match[6] }) === 7'b0000001);
assign iu1_first_hit_entry_pt[11] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] , entry_match[5]
     }) === 6'b000001);
assign iu1_first_hit_entry_pt[12] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3] ,
    entry_match[4] }) === 5'b00001);
assign iu1_first_hit_entry_pt[13] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] , entry_match[3]
     }) === 4'b0001);
assign iu1_first_hit_entry_pt[14] =
    (({ entry_match[0] , entry_match[1] ,
    entry_match[2] }) === 3'b001);
assign iu1_first_hit_entry_pt[15] =
    (({ entry_match[0] , entry_match[1]
     }) === 2'b01);
assign iu1_first_hit_entry[0] =
    (iu1_first_hit_entry_pt[1] | iu1_first_hit_entry_pt[2]
     | iu1_first_hit_entry_pt[3] | iu1_first_hit_entry_pt[4]
     | iu1_first_hit_entry_pt[5] | iu1_first_hit_entry_pt[6]
     | iu1_first_hit_entry_pt[7] | iu1_first_hit_entry_pt[8]
    );
assign iu1_first_hit_entry[1] =
    (iu1_first_hit_entry_pt[1] | iu1_first_hit_entry_pt[2]
     | iu1_first_hit_entry_pt[3] | iu1_first_hit_entry_pt[4]
     | iu1_first_hit_entry_pt[9] | iu1_first_hit_entry_pt[10]
     | iu1_first_hit_entry_pt[11] | iu1_first_hit_entry_pt[12]
    );
assign iu1_first_hit_entry[2] =
    (iu1_first_hit_entry_pt[1] | iu1_first_hit_entry_pt[2]
     | iu1_first_hit_entry_pt[5] | iu1_first_hit_entry_pt[6]
     | iu1_first_hit_entry_pt[9] | iu1_first_hit_entry_pt[10]
     | iu1_first_hit_entry_pt[13] | iu1_first_hit_entry_pt[14]
    );
assign iu1_first_hit_entry[3] =
    (iu1_first_hit_entry_pt[1] | iu1_first_hit_entry_pt[3]
     | iu1_first_hit_entry_pt[5] | iu1_first_hit_entry_pt[7]
     | iu1_first_hit_entry_pt[9] | iu1_first_hit_entry_pt[11]
     | iu1_first_hit_entry_pt[13] | iu1_first_hit_entry_pt[15]
    );

//assign_end
//assign_start

assign lru_rmt_vec_pt[1] =
    (({ watermark_q[0] , watermark_q[1] ,
    watermark_q[2] , watermark_q[3]
     }) === 4'b1111);
assign lru_rmt_vec_pt[2] =
    (({ watermark_q[1] , watermark_q[2] ,
    watermark_q[3] }) === 3'b111);
assign lru_rmt_vec_pt[3] =
    (({ watermark_q[0] , watermark_q[2] ,
    watermark_q[3] }) === 3'b111);
assign lru_rmt_vec_pt[4] =
    (({ watermark_q[2] , watermark_q[3]
     }) === 2'b11);
assign lru_rmt_vec_pt[5] =
    (({ watermark_q[0] , watermark_q[1] ,
    watermark_q[3] }) === 3'b111);
assign lru_rmt_vec_pt[6] =
    (({ watermark_q[1] , watermark_q[3]
     }) === 2'b11);
assign lru_rmt_vec_pt[7] =
    (({ watermark_q[0] , watermark_q[3]
     }) === 2'b11);
assign lru_rmt_vec_pt[8] =
    (({ watermark_q[3] }) === 1'b1);
assign lru_rmt_vec_pt[9] =
    (({ watermark_q[0] , watermark_q[1] ,
    watermark_q[2] }) === 3'b111);
assign lru_rmt_vec_pt[10] =
    (({ watermark_q[1] , watermark_q[2]
     }) === 2'b11);
assign lru_rmt_vec_pt[11] =
    (({ watermark_q[0] , watermark_q[2]
     }) === 2'b11);
assign lru_rmt_vec_pt[12] =
    (({ watermark_q[2] }) === 1'b1);
assign lru_rmt_vec_pt[13] =
    (({ watermark_q[0] , watermark_q[1]
     }) === 2'b11);
assign lru_rmt_vec_pt[14] =
    (({ watermark_q[1] }) === 1'b1);
assign lru_rmt_vec_pt[15] =
    (({ watermark_q[0] }) === 1'b1);
assign lru_rmt_vec_pt[16] =
    (({ mmucr1_q[0] }) === 1'b1);
assign lru_rmt_vec_pt[17] =
    1'b1;
assign lru_rmt_vec[0] =
    (lru_rmt_vec_pt[17]);
assign lru_rmt_vec[1] =
    (lru_rmt_vec_pt[8] | lru_rmt_vec_pt[12]
     | lru_rmt_vec_pt[14] | lru_rmt_vec_pt[15]
     | lru_rmt_vec_pt[16]);
assign lru_rmt_vec[2] =
    (lru_rmt_vec_pt[12] | lru_rmt_vec_pt[14]
     | lru_rmt_vec_pt[15] | lru_rmt_vec_pt[16]
    );
assign lru_rmt_vec[3] =
    (lru_rmt_vec_pt[4] | lru_rmt_vec_pt[14]
     | lru_rmt_vec_pt[15] | lru_rmt_vec_pt[16]
    );
assign lru_rmt_vec[4] =
    (lru_rmt_vec_pt[14] | lru_rmt_vec_pt[15]
     | lru_rmt_vec_pt[16]);
assign lru_rmt_vec[5] =
    (lru_rmt_vec_pt[6] | lru_rmt_vec_pt[10]
     | lru_rmt_vec_pt[15] | lru_rmt_vec_pt[16]
    );
assign lru_rmt_vec[6] =
    (lru_rmt_vec_pt[10] | lru_rmt_vec_pt[15]
     | lru_rmt_vec_pt[16]);
assign lru_rmt_vec[7] =
    (lru_rmt_vec_pt[2] | lru_rmt_vec_pt[15]
     | lru_rmt_vec_pt[16]);
assign lru_rmt_vec[8] =
    (lru_rmt_vec_pt[15] | lru_rmt_vec_pt[16]
    );
assign lru_rmt_vec[9] =
    (lru_rmt_vec_pt[7] | lru_rmt_vec_pt[11]
     | lru_rmt_vec_pt[13] | lru_rmt_vec_pt[16]
    );
assign lru_rmt_vec[10] =
    (lru_rmt_vec_pt[11] | lru_rmt_vec_pt[13]
     | lru_rmt_vec_pt[16]);
assign lru_rmt_vec[11] =
    (lru_rmt_vec_pt[3] | lru_rmt_vec_pt[13]
     | lru_rmt_vec_pt[16]);
assign lru_rmt_vec[12] =
    (lru_rmt_vec_pt[13] | lru_rmt_vec_pt[16]
    );
assign lru_rmt_vec[13] =
    (lru_rmt_vec_pt[5] | lru_rmt_vec_pt[9]
     | lru_rmt_vec_pt[16]);
assign lru_rmt_vec[14] =
    (lru_rmt_vec_pt[9] | lru_rmt_vec_pt[16]
    );
assign lru_rmt_vec[15] =
    (lru_rmt_vec_pt[1] | lru_rmt_vec_pt[16]
    );

//assign_end
//assign_start

assign lru_watermark_mask_pt[1] =
    (({ watermark_q[0] , watermark_q[1] ,
    watermark_q[2] , watermark_q[3]
     }) === 4'b0000);
assign lru_watermark_mask_pt[2] =
    (({ watermark_q[1] , watermark_q[2] ,
    watermark_q[3] }) === 3'b000);
assign lru_watermark_mask_pt[3] =
    (({ watermark_q[0] , watermark_q[2] ,
    watermark_q[3] }) === 3'b000);
assign lru_watermark_mask_pt[4] =
    (({ watermark_q[2] , watermark_q[3]
     }) === 2'b00);
assign lru_watermark_mask_pt[5] =
    (({ watermark_q[0] , watermark_q[1] ,
    watermark_q[3] }) === 3'b000);
assign lru_watermark_mask_pt[6] =
    (({ watermark_q[1] , watermark_q[3]
     }) === 2'b00);
assign lru_watermark_mask_pt[7] =
    (({ watermark_q[0] , watermark_q[3]
     }) === 2'b00);
assign lru_watermark_mask_pt[8] =
    (({ watermark_q[3] }) === 1'b0);
assign lru_watermark_mask_pt[9] =
    (({ watermark_q[0] , watermark_q[1] ,
    watermark_q[2] }) === 3'b000);
assign lru_watermark_mask_pt[10] =
    (({ watermark_q[1] , watermark_q[2]
     }) === 2'b00);
assign lru_watermark_mask_pt[11] =
    (({ watermark_q[0] , watermark_q[2]
     }) === 2'b00);
assign lru_watermark_mask_pt[12] =
    (({ watermark_q[2] }) === 1'b0);
assign lru_watermark_mask_pt[13] =
    (({ watermark_q[0] , watermark_q[1]
     }) === 2'b00);
assign lru_watermark_mask_pt[14] =
    (({ watermark_q[1] }) === 1'b0);
assign lru_watermark_mask_pt[15] =
    (({ watermark_q[0] }) === 1'b0);
assign lru_watermark_mask[0] =
    1'b0;
assign lru_watermark_mask[1] =
    (lru_watermark_mask_pt[1]);
assign lru_watermark_mask[2] =
    (lru_watermark_mask_pt[9]);
assign lru_watermark_mask[3] =
    (lru_watermark_mask_pt[5] | lru_watermark_mask_pt[9]
    );
assign lru_watermark_mask[4] =
    (lru_watermark_mask_pt[13]);
assign lru_watermark_mask[5] =
    (lru_watermark_mask_pt[3] | lru_watermark_mask_pt[13]
    );
assign lru_watermark_mask[6] =
    (lru_watermark_mask_pt[11] | lru_watermark_mask_pt[13]
    );
assign lru_watermark_mask[7] =
    (lru_watermark_mask_pt[7] | lru_watermark_mask_pt[11]
     | lru_watermark_mask_pt[13]);
assign lru_watermark_mask[8] =
    (lru_watermark_mask_pt[15]);
assign lru_watermark_mask[9] =
    (lru_watermark_mask_pt[2] | lru_watermark_mask_pt[15]
    );
assign lru_watermark_mask[10] =
    (lru_watermark_mask_pt[10] | lru_watermark_mask_pt[15]
    );
assign lru_watermark_mask[11] =
    (lru_watermark_mask_pt[6] | lru_watermark_mask_pt[10]
     | lru_watermark_mask_pt[15]);
assign lru_watermark_mask[12] =
    (lru_watermark_mask_pt[14] | lru_watermark_mask_pt[15]
    );
assign lru_watermark_mask[13] =
    (lru_watermark_mask_pt[4] | lru_watermark_mask_pt[14]
     | lru_watermark_mask_pt[15]);
assign lru_watermark_mask[14] =
    (lru_watermark_mask_pt[12] | lru_watermark_mask_pt[14]
     | lru_watermark_mask_pt[15]);
assign lru_watermark_mask[15] =
    (lru_watermark_mask_pt[8] | lru_watermark_mask_pt[12]
     | lru_watermark_mask_pt[14] | lru_watermark_mask_pt[15]
    );

//assign_end
//assign_start

assign lru_set_reset_vec_pt[1] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] , entry_match_q[6] ,
    entry_match_q[7] , entry_match_q[8] ,
    entry_match_q[9] , entry_match_q[10] ,
    entry_match_q[11] , entry_match_q[12] ,
    entry_match_q[13] , entry_match_q[14] ,
    entry_match_q[15] }) === 35'b00111111111111111110000000000000001);
assign lru_set_reset_vec_pt[2] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] , entry_match_q[6] ,
    entry_match_q[7] , entry_match_q[8] ,
    entry_match_q[9] , entry_match_q[10] ,
    entry_match_q[11] , entry_match_q[12] ,
    entry_match_q[13] , entry_match_q[14]
     }) === 34'b0011111111111111111000000000000001);
assign lru_set_reset_vec_pt[3] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_match_q[0] , entry_match_q[1] ,
    entry_match_q[2] , entry_match_q[3] ,
    entry_match_q[4] , entry_match_q[5] ,
    entry_match_q[6] , entry_match_q[7] ,
    entry_match_q[8] , entry_match_q[9] ,
    entry_match_q[10] , entry_match_q[11] ,
    entry_match_q[12] , entry_match_q[13] ,
    entry_match_q[14] }) === 33'b001111111111111111000000000000001);
assign lru_set_reset_vec_pt[4] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] , entry_match_q[6] ,
    entry_match_q[7] , entry_match_q[8] ,
    entry_match_q[9] , entry_match_q[10] ,
    entry_match_q[11] , entry_match_q[12] ,
    entry_match_q[13] }) === 33'b001111111111111111100000000000001);
assign lru_set_reset_vec_pt[5] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] , entry_match_q[6] ,
    entry_match_q[7] , entry_match_q[8] ,
    entry_match_q[9] , entry_match_q[10] ,
    entry_match_q[11] , entry_match_q[13]
     }) === 30'b001111111111111110000000000001);
assign lru_set_reset_vec_pt[6] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] , entry_match_q[6] ,
    entry_match_q[7] , entry_match_q[8] ,
    entry_match_q[9] , entry_match_q[10] ,
    entry_match_q[11] , entry_match_q[12]
     }) === 32'b00111111111111111110000000000001);
assign lru_set_reset_vec_pt[7] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] , entry_match_q[6] ,
    entry_match_q[7] , entry_match_q[8] ,
    entry_match_q[9] , entry_match_q[10] ,
    entry_match_q[11] }) === 31'b0011111111111111111000000000001);
assign lru_set_reset_vec_pt[8] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] , entry_match_q[6] ,
    entry_match_q[7] , entry_match_q[11]
     }) === 24'b001111111111111000000001);
assign lru_set_reset_vec_pt[9] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] , entry_match_q[6] ,
    entry_match_q[7] , entry_match_q[8] ,
    entry_match_q[9] , entry_match_q[10]
     }) === 30'b001111111111111111100000000001);
assign lru_set_reset_vec_pt[10] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] , entry_match_q[6] ,
    entry_match_q[7] , entry_match_q[8] ,
    entry_match_q[9] }) === 29'b00111111111111111110000000001);
assign lru_set_reset_vec_pt[11] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] , entry_match_q[6] ,
    entry_match_q[7] , entry_match_q[9]
     }) === 28'b0011111111111111111000000001);
assign lru_set_reset_vec_pt[12] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] , entry_match_q[6] ,
    entry_match_q[7] , entry_match_q[8]
     }) === 28'b0011111111111111111000000001);
assign lru_set_reset_vec_pt[13] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] , entry_match_q[6] ,
    entry_match_q[7] , entry_match_q[8]
     }) === 20'b00111111111000000001);
assign lru_set_reset_vec_pt[14] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] , entry_match_q[6] ,
    entry_match_q[7] }) === 27'b001111111111111111100000001);
assign lru_set_reset_vec_pt[15] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_match_q[7]
     }) === 12'b001111111111);
assign lru_set_reset_vec_pt[16] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] , entry_match_q[6]
     }) === 26'b00111111111111111110000001);
assign lru_set_reset_vec_pt[17] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4] ,
    entry_match_q[5] }) === 25'b0011111111111111111000001);
assign lru_set_reset_vec_pt[18] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[5]
     }) === 24'b001111111111111111100001);
assign lru_set_reset_vec_pt[19] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4]
     }) === 24'b001111111111111111100001);
assign lru_set_reset_vec_pt[20] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] , entry_match_q[4]
     }) === 20'b00111111111111100001);
assign lru_set_reset_vec_pt[21] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2] ,
    entry_match_q[3] }) === 23'b00111111111111111110001);
assign lru_set_reset_vec_pt[22] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[3]
     }) === 20'b00111111111111111111);
assign lru_set_reset_vec_pt[23] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2]
     }) === 22'b0011111111111111111001);
assign lru_set_reset_vec_pt[24] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0] ,
    entry_match_q[1] , entry_match_q[2]
     }) === 20'b00111111111111111001);
assign lru_set_reset_vec_pt[25] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    entry_match_q[0] , entry_match_q[1]
     }) === 20'b00111111111111111101);
assign lru_set_reset_vec_pt[26] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[1]
     }) === 20'b00111111111111111111);
assign lru_set_reset_vec_pt[27] =
    (({ lru_update_event_q[5] , lru_update_event_q[6] ,
    lru_update_event_q[7] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , entry_match_q[0]
     }) === 20'b00111111111111111111);
assign lru_set_reset_vec_pt[28] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    lru_q[1] , lru_q[3] ,
    lru_q[7] , lru_q[15]
     }) === 20'b11111111111111111110);
assign lru_set_reset_vec_pt[29] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[3] ,
    lru_q[7] , lru_q[15]
     }) === 20'b11111111111111111111);
assign lru_set_reset_vec_pt[30] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[3] ,
    lru_q[7] , lru_q[14]
     }) === 20'b11111111111111111100);
assign lru_set_reset_vec_pt[31] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[3] ,
    lru_q[7] , lru_q[14]
     }) === 20'b11111111111111111101);
assign lru_set_reset_vec_pt[32] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[3] ,
    lru_q[6] , lru_q[13]
     }) === 20'b11111111111111111010);
assign lru_set_reset_vec_pt[33] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[3] ,
    lru_q[6] , lru_q[13]
     }) === 20'b11111111111111111011);
assign lru_set_reset_vec_pt[34] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[3] ,
    lru_q[6] , lru_q[12]
     }) === 20'b11111111111111111000);
assign lru_set_reset_vec_pt[35] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[3] ,
    lru_q[6] , lru_q[12]
     }) === 20'b11111111111111111001);
assign lru_set_reset_vec_pt[36] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[2] ,
    lru_q[5] , lru_q[11]
     }) === 20'b11111111111111110110);
assign lru_set_reset_vec_pt[37] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[2] ,
    lru_q[5] , lru_q[11]
     }) === 20'b11111111111111110111);
assign lru_set_reset_vec_pt[38] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[2] ,
    lru_q[5] , lru_q[10]
     }) === 20'b11111111111111110100);
assign lru_set_reset_vec_pt[39] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[2] ,
    lru_q[5] , lru_q[10]
     }) === 20'b11111111111111110101);
assign lru_set_reset_vec_pt[40] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[2] ,
    lru_q[4] , lru_q[9]
     }) === 20'b11111111111111110010);
assign lru_set_reset_vec_pt[41] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[2] ,
    lru_q[4] , lru_q[9]
     }) === 20'b11111111111111110011);
assign lru_set_reset_vec_pt[42] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[2] ,
    lru_q[4] , lru_q[8]
     }) === 20'b11111111111111110000);
assign lru_set_reset_vec_pt[43] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15] ,
    lru_q[1] , lru_q[2] ,
    lru_q[4] , lru_q[8]
     }) === 20'b11111111111111110001);
assign lru_set_reset_vec_pt[44] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , lru_q[1] ,
    lru_q[3] , lru_q[7]
     }) === 18'b111111111111111110);
assign lru_set_reset_vec_pt[45] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , lru_q[1] ,
    lru_q[3] , lru_q[7]
     }) === 18'b111111111111111111);
assign lru_set_reset_vec_pt[46] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , lru_q[1] ,
    lru_q[3] , lru_q[6]
     }) === 18'b111111111111111100);
assign lru_set_reset_vec_pt[47] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , lru_q[1] ,
    lru_q[3] , lru_q[6]
     }) === 18'b111111111111111101);
assign lru_set_reset_vec_pt[48] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , lru_q[1] ,
    lru_q[2] , lru_q[5]
     }) === 18'b111111111111111010);
assign lru_set_reset_vec_pt[49] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , lru_q[1] ,
    lru_q[2] , lru_q[5]
     }) === 18'b111111111111111011);
assign lru_set_reset_vec_pt[50] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , lru_q[1] ,
    lru_q[2] , lru_q[4]
     }) === 18'b111111111111111000);
assign lru_set_reset_vec_pt[51] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , lru_q[1] ,
    lru_q[2] , lru_q[4]
     }) === 18'b111111111111111001);
assign lru_set_reset_vec_pt[52] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , lru_q[1] ,
    lru_q[3] }) === 15'b111111111111110);
assign lru_set_reset_vec_pt[53] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , lru_q[1] ,
    lru_q[3] }) === 15'b111111111111111);
assign lru_set_reset_vec_pt[54] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , lru_q[1] ,
    lru_q[2] }) === 15'b111111111111100);
assign lru_set_reset_vec_pt[55] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , lru_q[1] ,
    lru_q[2] }) === 15'b111111111111101);
assign lru_set_reset_vec_pt[56] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[0] ,
    entry_valid_watermarked[1] , entry_valid_watermarked[2] ,
    entry_valid_watermarked[3] , entry_valid_watermarked[4] ,
    entry_valid_watermarked[5] , entry_valid_watermarked[6] ,
    entry_valid_watermarked[7] , lru_q[1]
     }) === 10'b1111111110);
assign lru_set_reset_vec_pt[57] =
    (({ lru_update_event_q[5] , entry_valid_watermarked[8] ,
    entry_valid_watermarked[9] , entry_valid_watermarked[10] ,
    entry_valid_watermarked[11] , entry_valid_watermarked[12] ,
    entry_valid_watermarked[13] , entry_valid_watermarked[14] ,
    entry_valid_watermarked[15] , lru_q[1]
     }) === 10'b1111111111);
assign lru_set_reset_vec_pt[58] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] , entry_valid_watermarked[15]
     }) === 16'b1111111111111110);
assign lru_set_reset_vec_pt[59] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13] ,
    entry_valid_watermarked[14] }) === 15'b111111111111110);
assign lru_set_reset_vec_pt[60] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] , entry_valid_watermarked[13]
     }) === 14'b11111111111110);
assign lru_set_reset_vec_pt[61] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[13] }) === 13'b1111111111110);
assign lru_set_reset_vec_pt[62] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11] ,
    entry_valid_watermarked[12] }) === 13'b1111111111110);
assign lru_set_reset_vec_pt[63] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] , entry_valid_watermarked[11]
     }) === 12'b111111111110);
assign lru_set_reset_vec_pt[64] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[11] }) === 9'b111111110);
assign lru_set_reset_vec_pt[65] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9] ,
    entry_valid_watermarked[10] }) === 11'b11111111110);
assign lru_set_reset_vec_pt[66] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] , entry_valid_watermarked[9]
     }) === 10'b1111111110);
assign lru_set_reset_vec_pt[67] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[9] }) === 9'b111111110);
assign lru_set_reset_vec_pt[68] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7] ,
    entry_valid_watermarked[8] }) === 9'b111111110);
assign lru_set_reset_vec_pt[69] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] , entry_valid_watermarked[7]
     }) === 8'b11111110);
assign lru_set_reset_vec_pt[70] =
    (({ entry_valid_watermarked[7] }) === 1'b0);
assign lru_set_reset_vec_pt[71] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5] ,
    entry_valid_watermarked[6] }) === 7'b1111110);
assign lru_set_reset_vec_pt[72] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] , entry_valid_watermarked[5]
     }) === 6'b111110);
assign lru_set_reset_vec_pt[73] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[5] }) === 5'b11110);
assign lru_set_reset_vec_pt[74] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3] ,
    entry_valid_watermarked[4] }) === 5'b11110);
assign lru_set_reset_vec_pt[75] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] , entry_valid_watermarked[3]
     }) === 4'b1110);
assign lru_set_reset_vec_pt[76] =
    (({ entry_valid_watermarked[3] }) === 1'b0);
assign lru_set_reset_vec_pt[77] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1] ,
    entry_valid_watermarked[2] }) === 3'b110);
assign lru_set_reset_vec_pt[78] =
    (({ entry_valid_watermarked[0] , entry_valid_watermarked[1]
     }) === 2'b10);
assign lru_set_reset_vec_pt[79] =
    (({ entry_valid_watermarked[1] }) === 1'b0);
assign lru_set_reset_vec_pt[80] =
    (({ entry_valid_watermarked[0] }) === 1'b0);
assign lru_reset_vec[1] =
    (lru_set_reset_vec_pt[1] | lru_set_reset_vec_pt[2]
     | lru_set_reset_vec_pt[4] | lru_set_reset_vec_pt[6]
     | lru_set_reset_vec_pt[7] | lru_set_reset_vec_pt[9]
     | lru_set_reset_vec_pt[10] | lru_set_reset_vec_pt[13]
     | lru_set_reset_vec_pt[57] | lru_set_reset_vec_pt[70]
     | lru_set_reset_vec_pt[71] | lru_set_reset_vec_pt[73]
     | lru_set_reset_vec_pt[74] | lru_set_reset_vec_pt[76]
     | lru_set_reset_vec_pt[77] | lru_set_reset_vec_pt[79]
     | lru_set_reset_vec_pt[80]);
assign lru_reset_vec[2] =
    (lru_set_reset_vec_pt[14] | lru_set_reset_vec_pt[16]
     | lru_set_reset_vec_pt[17] | lru_set_reset_vec_pt[20]
     | lru_set_reset_vec_pt[55] | lru_set_reset_vec_pt[76]
     | lru_set_reset_vec_pt[77] | lru_set_reset_vec_pt[79]
     | lru_set_reset_vec_pt[80]);
assign lru_reset_vec[3] =
    (lru_set_reset_vec_pt[1] | lru_set_reset_vec_pt[2]
     | lru_set_reset_vec_pt[4] | lru_set_reset_vec_pt[6]
     | lru_set_reset_vec_pt[53] | lru_set_reset_vec_pt[64]
     | lru_set_reset_vec_pt[65] | lru_set_reset_vec_pt[67]
     | lru_set_reset_vec_pt[68]);
assign lru_reset_vec[4] =
    (lru_set_reset_vec_pt[21] | lru_set_reset_vec_pt[24]
     | lru_set_reset_vec_pt[51] | lru_set_reset_vec_pt[79]
     | lru_set_reset_vec_pt[80]);
assign lru_reset_vec[5] =
    (lru_set_reset_vec_pt[14] | lru_set_reset_vec_pt[16]
     | lru_set_reset_vec_pt[49] | lru_set_reset_vec_pt[73]
     | lru_set_reset_vec_pt[74]);
assign lru_reset_vec[6] =
    (lru_set_reset_vec_pt[7] | lru_set_reset_vec_pt[9]
     | lru_set_reset_vec_pt[47] | lru_set_reset_vec_pt[67]
     | lru_set_reset_vec_pt[68]);
assign lru_reset_vec[7] =
    (lru_set_reset_vec_pt[1] | lru_set_reset_vec_pt[2]
     | lru_set_reset_vec_pt[45] | lru_set_reset_vec_pt[61]
     | lru_set_reset_vec_pt[62]);
assign lru_reset_vec[8] =
    (lru_set_reset_vec_pt[25] | lru_set_reset_vec_pt[43]
     | lru_set_reset_vec_pt[80]);
assign lru_reset_vec[9] =
    (lru_set_reset_vec_pt[21] | lru_set_reset_vec_pt[41]
     | lru_set_reset_vec_pt[77]);
assign lru_reset_vec[10] =
    (lru_set_reset_vec_pt[17] | lru_set_reset_vec_pt[39]
     | lru_set_reset_vec_pt[74]);
assign lru_reset_vec[11] =
    (lru_set_reset_vec_pt[14] | lru_set_reset_vec_pt[37]
     | lru_set_reset_vec_pt[71]);
assign lru_reset_vec[12] =
    (lru_set_reset_vec_pt[10] | lru_set_reset_vec_pt[35]
     | lru_set_reset_vec_pt[68]);
assign lru_reset_vec[13] =
    (lru_set_reset_vec_pt[7] | lru_set_reset_vec_pt[33]
     | lru_set_reset_vec_pt[65]);
assign lru_reset_vec[14] =
    (lru_set_reset_vec_pt[4] | lru_set_reset_vec_pt[31]
     | lru_set_reset_vec_pt[62]);
assign lru_reset_vec[15] =
    (lru_set_reset_vec_pt[1] | lru_set_reset_vec_pt[29]
     | lru_set_reset_vec_pt[59]);
assign lru_set_vec[1] =
    (lru_set_reset_vec_pt[15] | lru_set_reset_vec_pt[16]
     | lru_set_reset_vec_pt[18] | lru_set_reset_vec_pt[19]
     | lru_set_reset_vec_pt[22] | lru_set_reset_vec_pt[23]
     | lru_set_reset_vec_pt[26] | lru_set_reset_vec_pt[27]
     | lru_set_reset_vec_pt[56] | lru_set_reset_vec_pt[58]
     | lru_set_reset_vec_pt[59] | lru_set_reset_vec_pt[60]
     | lru_set_reset_vec_pt[62] | lru_set_reset_vec_pt[63]
     | lru_set_reset_vec_pt[65] | lru_set_reset_vec_pt[66]
     | lru_set_reset_vec_pt[68]);
assign lru_set_vec[2] =
    (lru_set_reset_vec_pt[22] | lru_set_reset_vec_pt[23]
     | lru_set_reset_vec_pt[26] | lru_set_reset_vec_pt[27]
     | lru_set_reset_vec_pt[54] | lru_set_reset_vec_pt[69]
     | lru_set_reset_vec_pt[71] | lru_set_reset_vec_pt[72]
     | lru_set_reset_vec_pt[74]);
assign lru_set_vec[3] =
    (lru_set_reset_vec_pt[8] | lru_set_reset_vec_pt[9]
     | lru_set_reset_vec_pt[11] | lru_set_reset_vec_pt[12]
     | lru_set_reset_vec_pt[52] | lru_set_reset_vec_pt[58]
     | lru_set_reset_vec_pt[59] | lru_set_reset_vec_pt[60]
     | lru_set_reset_vec_pt[62]);
assign lru_set_vec[4] =
    (lru_set_reset_vec_pt[26] | lru_set_reset_vec_pt[27]
     | lru_set_reset_vec_pt[50] | lru_set_reset_vec_pt[75]
     | lru_set_reset_vec_pt[77]);
assign lru_set_vec[5] =
    (lru_set_reset_vec_pt[18] | lru_set_reset_vec_pt[19]
     | lru_set_reset_vec_pt[48] | lru_set_reset_vec_pt[69]
     | lru_set_reset_vec_pt[71]);
assign lru_set_vec[6] =
    (lru_set_reset_vec_pt[11] | lru_set_reset_vec_pt[12]
     | lru_set_reset_vec_pt[46] | lru_set_reset_vec_pt[63]
     | lru_set_reset_vec_pt[65]);
assign lru_set_vec[7] =
    (lru_set_reset_vec_pt[5] | lru_set_reset_vec_pt[6]
     | lru_set_reset_vec_pt[44] | lru_set_reset_vec_pt[58]
     | lru_set_reset_vec_pt[59]);
assign lru_set_vec[8] =
    (lru_set_reset_vec_pt[27] | lru_set_reset_vec_pt[42]
     | lru_set_reset_vec_pt[78]);
assign lru_set_vec[9] =
    (lru_set_reset_vec_pt[23] | lru_set_reset_vec_pt[40]
     | lru_set_reset_vec_pt[75]);
assign lru_set_vec[10] =
    (lru_set_reset_vec_pt[19] | lru_set_reset_vec_pt[38]
     | lru_set_reset_vec_pt[72]);
assign lru_set_vec[11] =
    (lru_set_reset_vec_pt[16] | lru_set_reset_vec_pt[36]
     | lru_set_reset_vec_pt[69]);
assign lru_set_vec[12] =
    (lru_set_reset_vec_pt[12] | lru_set_reset_vec_pt[34]
     | lru_set_reset_vec_pt[66]);
assign lru_set_vec[13] =
    (lru_set_reset_vec_pt[9] | lru_set_reset_vec_pt[32]
     | lru_set_reset_vec_pt[63]);
assign lru_set_vec[14] =
    (lru_set_reset_vec_pt[6] | lru_set_reset_vec_pt[30]
     | lru_set_reset_vec_pt[60]);
assign lru_set_vec[15] =
    (lru_set_reset_vec_pt[3] | lru_set_reset_vec_pt[28]
     | lru_set_reset_vec_pt[58]);

//assign_end
//assign_start

assign lru_way_encode_pt[1] =
    (({ lru_eff[1] , lru_eff[3] ,
    lru_eff[7] , lru_eff[15]
     }) === 4'b1111);
assign lru_way_encode_pt[2] =
    (({ lru_eff[1] , lru_eff[3] ,
    lru_eff[7] , lru_eff[14]
     }) === 4'b1101);
assign lru_way_encode_pt[3] =
    (({ lru_eff[1] , lru_eff[3] ,
    lru_eff[6] , lru_eff[13]
     }) === 4'b1011);
assign lru_way_encode_pt[4] =
    (({ lru_eff[1] , lru_eff[3] ,
    lru_eff[6] , lru_eff[12]
     }) === 4'b1001);
assign lru_way_encode_pt[5] =
    (({ lru_eff[1] , lru_eff[2] ,
    lru_eff[5] , lru_eff[11]
     }) === 4'b0111);
assign lru_way_encode_pt[6] =
    (({ lru_eff[1] , lru_eff[2] ,
    lru_eff[5] , lru_eff[10]
     }) === 4'b0101);
assign lru_way_encode_pt[7] =
    (({ lru_eff[1] , lru_eff[2] ,
    lru_eff[4] , lru_eff[9]
     }) === 4'b0011);
assign lru_way_encode_pt[8] =
    (({ lru_eff[1] , lru_eff[2] ,
    lru_eff[4] , lru_eff[8]
     }) === 4'b0001);
assign lru_way_encode_pt[9] =
    (({ lru_eff[1] , lru_eff[3] ,
    lru_eff[7] }) === 3'b111);
assign lru_way_encode_pt[10] =
    (({ lru_eff[1] , lru_eff[3] ,
    lru_eff[6] }) === 3'b101);
assign lru_way_encode_pt[11] =
    (({ lru_eff[1] , lru_eff[2] ,
    lru_eff[5] }) === 3'b011);
assign lru_way_encode_pt[12] =
    (({ lru_eff[1] , lru_eff[2] ,
    lru_eff[4] }) === 3'b001);
assign lru_way_encode_pt[13] =
    (({ lru_eff[1] , lru_eff[3]
     }) === 2'b11);
assign lru_way_encode_pt[14] =
    (({ lru_eff[1] , lru_eff[2]
     }) === 2'b01);
assign lru_way_encode_pt[15] =
    (({ lru_eff[1] }) === 1'b1);
assign lru_way_encode[0] =
    (lru_way_encode_pt[15]);
assign lru_way_encode[1] =
    (lru_way_encode_pt[13] | lru_way_encode_pt[14]
    );
assign lru_way_encode[2] =
    (lru_way_encode_pt[9] | lru_way_encode_pt[10]
     | lru_way_encode_pt[11] | lru_way_encode_pt[12]
    );
assign lru_way_encode[3] =
    (lru_way_encode_pt[1] | lru_way_encode_pt[2]
     | lru_way_encode_pt[3] | lru_way_encode_pt[4]
     | lru_way_encode_pt[5] | lru_way_encode_pt[6]
     | lru_way_encode_pt[7] | lru_way_encode_pt[8]
    );

//assign_end
//assign_start

assign cam_mask_bits_pt[1] =
    (({ ex6_data_in_q[55] , ex6_data_in_q[56] ,
    ex6_data_in_q[57] , ex6_data_in_q[58] ,
    ex6_data_in_q[59] }) === 5'b11010);
assign cam_mask_bits_pt[2] =
    (({ ex6_data_in_q[56] , ex6_data_in_q[59]
     }) === 2'b00);
assign cam_mask_bits_pt[3] =
    (({ ex6_data_in_q[55] , ex6_data_in_q[56] ,
    ex6_data_in_q[57] , ex6_data_in_q[58] ,
    ex6_data_in_q[59] }) === 5'b10101);
assign cam_mask_bits_pt[4] =
    (({ ex6_data_in_q[55] , ex6_data_in_q[56] ,
    ex6_data_in_q[57] , ex6_data_in_q[58] ,
    ex6_data_in_q[59] }) === 5'b10011);
assign cam_mask_bits_pt[5] =
    (({ ex6_data_in_q[55] , ex6_data_in_q[56] ,
    ex6_data_in_q[57] , ex6_data_in_q[58] ,
    ex6_data_in_q[59] }) === 5'b10111);
assign cam_mask_bits_pt[6] =
    (({ ex6_data_in_q[55] , ex6_data_in_q[56] ,
    ex6_data_in_q[58] , ex6_data_in_q[59]
     }) === 4'b0011);
assign cam_mask_bits_pt[7] =
    (({ ex6_data_in_q[56] , ex6_data_in_q[59]
     }) === 2'b11);
assign cam_mask_bits_pt[8] =
    (({ ex6_data_in_q[57] , ex6_data_in_q[58]
     }) === 2'b00);
assign cam_mask_bits_pt[9] =
    (({ ex6_data_in_q[58] }) === 1'b0);
assign cam_mask_bits_pt[10] =
    (({ ex6_data_in_q[56] , ex6_data_in_q[57]
     }) === 2'b00);
assign cam_mask_bits_pt[11] =
    (({ ex6_data_in_q[56] , ex6_data_in_q[57]
     }) === 2'b11);
assign cam_mask_bits_pt[12] =
    (({ tlb_rel_data_q[52] , tlb_rel_data_q[55]
     }) === 2'b10);
assign cam_mask_bits_pt[13] =
    (({ tlb_rel_data_q[52] , tlb_rel_data_q[53] ,
    tlb_rel_data_q[54] , tlb_rel_data_q[55]
     }) === 4'b1111);
assign cam_mask_bits_pt[14] =
    (({ tlb_rel_data_q[52] , tlb_rel_data_q[54] ,
    tlb_rel_data_q[55] }) === 3'b011);
assign cam_mask_bits_pt[15] =
    (({ tlb_rel_data_q[53] , tlb_rel_data_q[54]
     }) === 2'b00);
assign cam_mask_bits_pt[16] =
    (({ tlb_rel_data_q[52] , tlb_rel_data_q[53] ,
    tlb_rel_data_q[54] }) === 3'b110);
assign cam_mask_bits_pt[17] =
    (({ tlb_rel_data_q[54] }) === 1'b0);
assign cam_mask_bits_pt[18] =
    (({ tlb_rel_data_q[52] , tlb_rel_data_q[53] ,
    tlb_rel_data_q[54] }) === 3'b101);
assign cam_mask_bits_pt[19] =
    (({ tlb_rel_data_q[53] }) === 1'b0);
assign tlb_rel_cmpmask[0] =
    (cam_mask_bits_pt[13] | cam_mask_bits_pt[14]
     | cam_mask_bits_pt[17] | cam_mask_bits_pt[18]
    );
assign tlb_rel_cmpmask[1] =
    (cam_mask_bits_pt[17] | cam_mask_bits_pt[19]
    );
assign tlb_rel_cmpmask[2] =
    (cam_mask_bits_pt[19]);
assign tlb_rel_cmpmask[3] =
    (cam_mask_bits_pt[15]);
assign tlb_rel_xbitmask[0] =
    (cam_mask_bits_pt[12]);
assign tlb_rel_xbitmask[1] =
    (cam_mask_bits_pt[13]);
assign tlb_rel_xbitmask[2] =
    (cam_mask_bits_pt[16]);
assign tlb_rel_xbitmask[3] =
    (cam_mask_bits_pt[18]);
assign tlb_rel_maskpar =
    (cam_mask_bits_pt[12] | cam_mask_bits_pt[14]
     | cam_mask_bits_pt[16]);
assign ex6_data_cmpmask[0] =
    (cam_mask_bits_pt[2] | cam_mask_bits_pt[4]
     | cam_mask_bits_pt[5] | cam_mask_bits_pt[6]
     | cam_mask_bits_pt[7] | cam_mask_bits_pt[9]
     | cam_mask_bits_pt[11]);
assign ex6_data_cmpmask[1] =
    (cam_mask_bits_pt[2] | cam_mask_bits_pt[7]
     | cam_mask_bits_pt[9] | cam_mask_bits_pt[10]
     | cam_mask_bits_pt[11]);
assign ex6_data_cmpmask[2] =
    (cam_mask_bits_pt[2] | cam_mask_bits_pt[7]
     | cam_mask_bits_pt[8] | cam_mask_bits_pt[10]
     | cam_mask_bits_pt[11]);
assign ex6_data_cmpmask[3] =
    (cam_mask_bits_pt[2] | cam_mask_bits_pt[7]
     | cam_mask_bits_pt[8] | cam_mask_bits_pt[11]
    );
assign ex6_data_xbitmask[0] =
    (cam_mask_bits_pt[1]);
assign ex6_data_xbitmask[1] =
    (cam_mask_bits_pt[5]);
assign ex6_data_xbitmask[2] =
    (cam_mask_bits_pt[3]);
assign ex6_data_xbitmask[3] =
    (cam_mask_bits_pt[4]);
assign ex6_data_maskpar =
    (cam_mask_bits_pt[1] | cam_mask_bits_pt[3]
     | cam_mask_bits_pt[6]);

//assign_end

   assign wr_array_val = (por_seq_q != PorSeq_Idle) ? por_wr_array_val :
                         (csinv_complete == 1'b1) ? 2'b0 :   // csync or isync enabled and complete
                         (tlb_rel_val_q[0:3] != 4'b0000 & tlb_rel_val_q[4] == 1'b1) ? {2{tlb_rel_data_q[eratpos_wren]}} :   // tlb hit reload
                         ((|(ex6_valid_q[0:`THREADS - 1])) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_ws_q == 2'b00 & ex6_tlbsel_q == TlbSel_IErat) ? {2{1'b1}} :   // eratwe WS=0
                         2'b0;
   // tlb_high_data
   //  84       -  0      - X-bit
   //  85:87    -  1:3    - reserved (3b)
   //  88:117   -  4:33   - RPN (30b)
   //  118:119  -  34:35  - R,C
   //  120:121  -  36:37  - WLC (2b)
   //  122      -  38     - ResvAttr
   //  123      -  39     - VF
   //  124      -  40     - IND
   //  125:128  -  41:44  - U0-U3
   //  129:133  -  45:49  - WIMGE
   //  134:136  -  50:52  - UX,UW,UR
   //  137:139  -  53:55  - SX,SW,SR
   //  140      -  56  - GS
   //  141      -  57  - TS
   //  142:143  -  58:59  - reserved (2b)
   //  144:149  -  60:65  - 6b TID msbs
   //  150:157  -  66:73  - 8b TID lsbs
   //  158:167  -  74:83  - parity 10bits

   // 16x143 version, 42b RA
   // wr_array_data
   //  0:29  - RPN
   //  30:31  - R,C
   //  32:33  - WLC
   //  34     - ResvAttr
   //  35     - VF
   //  36:39  - U0-U3
   //  40:44  - WIMGE
   //  45:46  - UX,SX
   //  47:48  - UW,SW
   //  49:50  - UR,SR
   //  51:60  - CAM parity
   //  61:67  - Array parity

   // wr_ws1_data (HI)
   //  0:7  - unused
   //  8:9  - WLC
   //  10  - ResvAttr
   //  11  - unused
   //  12:15  - U0-U3
   //  16:17  - R,C
   //  18:21  - unused
   //  22:51  - RPN
   //  52:56  - WIMGE
   //  57  - VF (not supported in ierat)
   //  58:59  - UX,SX
   //  60:61  - UW,SW
   //  62:63  - UR,SR

   assign wr_array_data_nopar = (por_seq_q != PorSeq_Idle) ? por_wr_array_data[0:50] :
                                (tlb_rel_val_q[0:3] != 4'b0000 & tlb_rel_val_q[4] == 1'b1) ? {tlb_rel_data_q[70:101], tlb_rel_data_q[103:121]} :   // tlb hit reload
                                ((|(ex6_valid_q[0:`THREADS - 1])) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_ws_q == 2'b00) ? {ex6_rpn_holdreg[22:51], ex6_rpn_holdreg[16:17], ex6_rpn_holdreg[8:10], 1'b0, ex6_rpn_holdreg[12:15], ex6_rpn_holdreg[52:56], ex6_rpn_holdreg[58:63]} :   // eratwe WS=0
                                {array_data_width-17{1'b0}};

   // PARITY DEF's
   //  wr_cam_val(0) -> cmpmask(0:7), cmpmask_par
   //    cmpmasks(0:7)             - wr_cam_data 75:82  - wr_cam_data(83)  <- parity from table
   //  wr_cam_val(0) -> epn(0:51), xbit, size(0:2), V, ThdID(0:3), class(0:1), array_dat(51:58)
   //    epn(0:7)                  - wr_cam_data 0:7    - wr_array_par(51)
   //    epn(8:15)                 - wr_cam_data 8:15   - wr_array_par(52)
   //    epn(16:23)                - wr_cam_data 16:23  - wr_array_par(53)
   //    epn(24:31)                - wr_cam_data 24:31  - wr_array_par(54)
   //    epn(32:39)                - wr_cam_data 32:39  - wr_array_par(55)
   //    epn(40:47)                - wr_cam_data 40:47  - wr_array_par(56)
   //    epn(48:51),xbit,size(0:2) - wr_cam_data 48:55  - wr_array_par(57)
   //    V,ThdID(0:3),class(0:1)   - wr_cam_data 56:62  - wr_array_par(58)
   assign wr_array_par[51] = ^(wr_cam_data[0:7]);
   assign wr_array_par[52] = ^(wr_cam_data[8:15]);
   assign wr_array_par[53] = ^(wr_cam_data[16:23]);
   assign wr_array_par[54] = ^(wr_cam_data[24:31]);
   assign wr_array_par[55] = ^(wr_cam_data[32:39]);
   assign wr_array_par[56] = ^(wr_cam_data[40:47]);
   assign wr_array_par[57] = ^(wr_cam_data[48:55]);
   assign wr_array_par[58] = ^(wr_cam_data[57:62]);  // leave V-bit 56 out of parity calculation

   //  wr_cam_val(1) -> extclass, tid_nz, gs, as, tid(6:13), array_dat(59:60)
   //    extclass,tid_nz,gs,as     - wr_cam_data 63:66  - wr_array_par(59)
   //    tid(6:13)                 - wr_cam_data 67:74  - wr_array_par(60)
   assign wr_array_par[59] = ^(wr_cam_data[63:66]);
   assign wr_array_par[60] = ^(wr_cam_data[67:74]);

   //  wr_array_val(0) -> rpn(22:51), array_dat(61:64)
   //    rpn(22:27)                          - wr_array_data 0:5    - wr_array_par(61)
   //    rpn(28:35)                          - wr_array_data 6:13   - wr_array_par(62)
   //    rpn(36:43)                          - wr_array_data 14:21  - wr_array_par(63)
   //    rpn(44:51)                          - wr_array_data 22:29  - wr_array_par(64)
   assign wr_array_par[61] = ^(wr_array_data_nopar[0:5]);
   assign wr_array_par[62] = ^(wr_array_data_nopar[6:13]);
   assign wr_array_par[63] = ^(wr_array_data_nopar[14:21]);
   assign wr_array_par[64] = ^(wr_array_data_nopar[22:29]);
   //  wr_array_val(1) -> R,C, WLC(0:1), resvattr, VF, ubits(0:3), wimge(0:4), UX,SX,UW,SW,UR,SR, array_dat(65:67)
   //    R,C,WLC(0:1),resvattr,VF,ubits(0:1) - wr_array_data 30:37  - wr_array_par(65)
   //    ubits(2:3),WIMGE(0:4)               - wr_array_data 38:44  - wr_array_par(66)
   //    UX,SX,UW,SW,UR,SR                   - wr_array_data 45:50  - wr_array_par(67)
   assign wr_array_par[65] = ^(wr_array_data_nopar[30:37]);
   assign wr_array_par[66] = ^(wr_array_data_nopar[38:44]);
   assign wr_array_par[67] = ^(wr_array_data_nopar[45:50]);

   assign wr_array_data[0:50] = wr_array_data_nopar;

   assign wr_array_data[51:67] = ((tlb_rel_val_q[0:3] != 4'b0000 & tlb_rel_val_q[4] == 1'b1) |    // tlb hit reload
                                       por_seq_q != PorSeq_Idle) ?                                // por boot sequence
                                                                   {wr_array_par[51:60], wr_array_par[61:67]} :
                                 // mmucr1_q(5 to 6): IPEI parity error inject on epn or rpn side
                                 ((|(ex6_valid_q[0:`THREADS-1])) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_ws_q == 2'b00) ? {(wr_array_par[51] ^ mmucr1_q[5]), wr_array_par[52:60], (wr_array_par[61] ^ mmucr1_q[6]), wr_array_par[62:67]} :   // eratwe WS=0
                                 17'b0;

   // Parity Checking
   assign unused_dc[22] = lcb_delay_lclkr_dc[1] | lcb_mpw1_dc_b[1];
   assign iu2_cmp_data_calc_par[50] = ^(iu2_cam_cmp_data_q[75:82]);   // cmp/x mask on epn side

   assign iu2_cmp_data_calc_par[51] = ^(iu2_cam_cmp_data_q[0:7]);
   assign iu2_cmp_data_calc_par[52] = ^(iu2_cam_cmp_data_q[8:15]);
   assign iu2_cmp_data_calc_par[53] = ^(iu2_cam_cmp_data_q[16:23]);
   assign iu2_cmp_data_calc_par[54] = ^(iu2_cam_cmp_data_q[24:31]);
   assign iu2_cmp_data_calc_par[55] = ^(iu2_cam_cmp_data_q[32:39]);
   assign iu2_cmp_data_calc_par[56] = ^(iu2_cam_cmp_data_q[40:47]);
   assign iu2_cmp_data_calc_par[57] = ^(iu2_cam_cmp_data_q[48:55]);
   assign iu2_cmp_data_calc_par[58] = ^(iu2_cam_cmp_data_q[57:62]);   // leave V-bit 56 out of parity calc
   assign iu2_cmp_data_calc_par[59] = ^(iu2_cam_cmp_data_q[63:66]);
   assign iu2_cmp_data_calc_par[60] = ^(iu2_cam_cmp_data_q[67:74]);

   assign iu2_cmp_data_calc_par[61] = ^(iu2_array_cmp_data_q[0:5]);
   assign iu2_cmp_data_calc_par[62] = ^(iu2_array_cmp_data_q[6:13]);
   assign iu2_cmp_data_calc_par[63] = ^(iu2_array_cmp_data_q[14:21]);
   assign iu2_cmp_data_calc_par[64] = ^(iu2_array_cmp_data_q[22:29]);
   assign iu2_cmp_data_calc_par[65] = ^(iu2_array_cmp_data_q[30:37]);
   assign iu2_cmp_data_calc_par[66] = ^(iu2_array_cmp_data_q[38:44]);
   assign iu2_cmp_data_calc_par[67] = ^(iu2_array_cmp_data_q[45:50]);


   assign ex4_rd_data_calc_par[50] = ^(ex4_rd_cam_data_q[75:82]);   // cmp/x mask on epn side

   assign ex4_rd_data_calc_par[51] = ^(ex4_rd_cam_data_q[0:7]);
   assign ex4_rd_data_calc_par[52] = ^(ex4_rd_cam_data_q[8:15]);
   assign ex4_rd_data_calc_par[53] = ^(ex4_rd_cam_data_q[16:23]);
   assign ex4_rd_data_calc_par[54] = ^(ex4_rd_cam_data_q[24:31]);
   assign ex4_rd_data_calc_par[55] = ^(ex4_rd_cam_data_q[32:39]);
   assign ex4_rd_data_calc_par[56] = ^(ex4_rd_cam_data_q[40:47]);
   assign ex4_rd_data_calc_par[57] = ^(ex4_rd_cam_data_q[48:55]);
   assign ex4_rd_data_calc_par[58] = ^(ex4_rd_cam_data_q[57:62]);   // leave V-bit 56 out of parity calc
   assign ex4_rd_data_calc_par[59] = ^(ex4_rd_cam_data_q[63:66]);
   assign ex4_rd_data_calc_par[60] = ^(ex4_rd_cam_data_q[67:74]);

   assign ex4_rd_data_calc_par[61] = ^(ex4_rd_array_data_q[0:5]);
   assign ex4_rd_data_calc_par[62] = ^(ex4_rd_array_data_q[6:13]);
   assign ex4_rd_data_calc_par[63] = ^(ex4_rd_array_data_q[14:21]);
   assign ex4_rd_data_calc_par[64] = ^(ex4_rd_array_data_q[22:29]);
   assign ex4_rd_data_calc_par[65] = ^(ex4_rd_array_data_q[30:37]);
   assign ex4_rd_data_calc_par[66] = ^(ex4_rd_array_data_q[38:44]);
   assign ex4_rd_data_calc_par[67] = ^(ex4_rd_array_data_q[45:50]);

   generate
   begin
      if (check_parity == 0)
      begin
         assign iu2_cmp_data_parerr_epn = 1'b0;
         assign iu2_cmp_data_parerr_rpn = 1'b0;
      end
      if (check_parity == 1)
      begin
         assign iu2_cmp_data_parerr_epn = |(iu2_cmp_data_calc_par[50:60] ^ {iu2_cam_cmp_data_q[83], iu2_array_cmp_data_q[51:60]});   // epn side cmp out parity error
         assign iu2_cmp_data_parerr_rpn = |(iu2_cmp_data_calc_par[61:67] ^ iu2_array_cmp_data_q[61:67]);   // rpn side cmp out parity error
      end

      if (check_parity == 0)
      begin
         assign ex4_rd_data_parerr_epn = 1'b0;
         assign ex4_rd_data_parerr_rpn = 1'b0;
      end
      if (check_parity == 1)
      begin
         assign ex4_rd_data_parerr_epn = |(ex4_rd_data_calc_par[50:60] ^ {ex4_rd_cam_data_q[83], ex4_rd_array_data_q[51:60]});   // epn side rd out parity error
         assign ex4_rd_data_parerr_rpn = |(ex4_rd_data_calc_par[61:67] ^ ex4_rd_array_data_q[61:67]);   // rpn side rd out parity error
      end
   end
   endgenerate


   // CAM Port
   assign flash_invalidate = (por_seq_q == PorSeq_Stg1) | mchk_flash_inv_enab;

   assign comp_invalidate = (csinv_complete == 1'b1) ? 1'b1 :   // csync or isync enabled and complete
                            (tlb_rel_val_q[0:3] != 4'b0000 & tlb_rel_val_q[4] == 1'b1) ? 1'b0 :   // tlb hit reload
                            (snoop_val_q[0:1] == 2'b11) ? 1'b1 :   // invalidate snoop
                            1'b0;

   assign comp_request = (csinv_complete) |             // csync or isync enabled and complete
                         (snoop_val_q[0] & snoop_val_q[1] & (~(|(tlb_rel_val_q[0:3]))) ) |      // invalidate snoop
                         (ex1_ieratsx) |                // eratsx
                         (iu_ierat_iu0_val);            // fetch

   generate
      if (rs_data_width == 64)
      begin
         assign comp_addr_mux1 = (snoop_addr_q & {epn_width{snoop_val_q[0] & snoop_val_q[1]}}) |   // invalidate snoop
                                 (xu_iu_rb & {rs_data_width-12{(~(snoop_val_q[0] & snoop_val_q[1])) & ex1_ieratsx}});   // eratsx

         assign comp_addr_mux1_sel = (snoop_val_q[0] & snoop_val_q[1]) | (ex1_ieratsx & snoop_val_q[1]);    // snoop or eratsx

         assign comp_addr = (comp_addr_mux1 & {epn_width{comp_addr_mux1_sel}}) |      // invalidate snoop or eratsx
                            (iu_ierat_iu0_ifar & {epn_width{~comp_addr_mux1_sel}});   // fetch, or I$ back_inv
      end
   endgenerate   // 64-bit model

   assign iu_xu_ierat_ex2_flush_d = (ex1_valid_q & (~(xu_ex1_flush)) & {`THREADS{ex1_ieratsx & (csinv_complete | ~snoop_val_q[1])}}) |
                                    (ex1_valid_q & (~(xu_ex1_flush)) & {`THREADS{(ex1_ieratre | ex1_ieratwe | ex1_ieratsx) & tlb_rel_act_q}});

   assign iu_xu_ord_n_flush_req = |(iu_xu_ierat_ex2_flush_q);

   // snoop_attr:
   //          0 -> Local
   //        1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=epn, 4=class0, 5=class1, 6=class2, 7=class3
   //        4:5 -> GS/TS
   //       6:13 -> TID(6:13)
   //      14:17 -> Size
   //      18    -> reserved for tlb, extclass_enable(0) for erats
   //      19    -> mmucsr0.tlb0fi for tlb, or TID_NZ for erats
   //      20:25 -> TID(0:5)

   assign addr_enable[0] = (~(csinv_complete)) &                // not csync or isync enabled and complete
                           ( (snoop_val_q[0] & snoop_val_q[1] & (~snoop_attr_q[1]) & snoop_attr_q[2] & snoop_attr_q[3]) |   // T=3, va invalidate snoop
                             ( (|(ex1_valid_q[0:`THREADS-1])) & ex1_ttype_q[2] & ex1_tlbsel_q[0] & (~ex1_tlbsel_q[1]) & (~(snoop_val_q[0] & snoop_val_q[1])) ) |   // eratsx, tlbsel=2
                             ( iu_ierat_iu0_val & (~(snoop_val_q[0] & snoop_val_q[1])) ) );    // fetch

   assign addr_enable[1] = (~(csinv_complete)) &                // not csync or isync enabled and complete
                           ( (snoop_val_q[0] & snoop_val_q[1] & snoop_attr_q[0] & (~snoop_attr_q[1]) & snoop_attr_q[2] & snoop_attr_q[3]) |   // Local T=3, va invalidate snoop
                             ( (|(ex1_valid_q[0:`THREADS-1])) & ex1_ttype_q[2] & ex1_tlbsel_q[0] & (~ex1_tlbsel_q[1]) & (~(snoop_val_q[0] & snoop_val_q[1])) ) |   // eratsx, tlbsel=2
                             ( iu_ierat_iu0_val & (~(snoop_val_q[0] & snoop_val_q[1])) ) );    // fetch

   assign comp_pgsize = (snoop_attr_q[14:17] == WS0_PgSize_1GB)  ? CAM_PgSize_1GB :
                        (snoop_attr_q[14:17] == WS0_PgSize_16MB) ? CAM_PgSize_16MB :
                        (snoop_attr_q[14:17] == WS0_PgSize_1MB)  ? CAM_PgSize_1MB :
                        (snoop_attr_q[14:17] == WS0_PgSize_64KB) ? CAM_PgSize_64KB :
                        CAM_PgSize_4KB;

   assign pgsize_enable = (csinv_complete == 1'b1) ? 1'b0 :    // csync or isync enabled and complete
                          (snoop_val_q[0:1] == 2'b11 & snoop_attr_q[0:3] == 4'b0011) ? 1'b1 :    // non-local va-based invalidate snoop
                          1'b0;

   // mmucr1_q: 0-IRRE, 1-REE, 2-CEE, 3-csync_dis, 4-isync_dis, 5:6-IPEI, 7:8-ICTID/ITTID

   assign comp_class = (snoop_attr_q[20:21] & {2{snoop_val_q[0] & snoop_val_q[1] &   mmucr1_q[7]}})  |          // ICTID=1 invalidate snoop
                       (snoop_attr_q[2:3]   & {2{snoop_val_q[0] & snoop_val_q[1] & (~mmucr1_q[7])}}) |          // T=4to7
                       (ex1_pid_q[pid_width - 14:pid_width - 13] & {2{(~(snoop_val_q[0] & snoop_val_q[1])) & mmucr1_q[7] &    ex1_ieratsx}}) |  // ICTID=1 eratsx
                       (iu1_pid_d[pid_width - 14:pid_width - 13] & {2{(~(snoop_val_q[0] & snoop_val_q[1])) & mmucr1_q[7] & (~(ex1_ieratsx))}}); // ICTID=1

   assign class_enable[0] = (mmucr1_q[7] == 1'b1) ? 1'b0 :      // mmucr1.ICTID=1
                            (csinv_complete == 1'b1) ? 1'b0 :   // csync or isync enabled and complete
                            (snoop_val_q[0:1] == 2'b11 & snoop_attr_q[1] == 1'b1) ? 1'b1 :      // T=4to7, class invalidate snoop
                            1'b0;
   assign class_enable[1] = (mmucr1_q[7] == 1'b1) ? 1'b0 :      // mmucr1.ICTID=1
                            (csinv_complete == 1'b1) ? 1'b0 :   // csync or isync enabled and complete
                            (snoop_val_q[0:1] == 2'b11 & snoop_attr_q[1] == 1'b1) ? 1'b1 :      // T=4to7, class invalidate snoop
                            1'b0;
   assign class_enable[2] = (mmucr1_q[7] == 1'b0) ? 1'b0 :      // mmucr1.ICTID=0
                            pid_enable;

   // snoop_attr:
   //          0 -> Local
   //        1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=epn, 4=class0, 5=class1, 6=class2, 7=class3
   //        4:5 -> GS/TS
   //       6:13 -> TID(6:13)
   //      14:17 -> Size
   //      18    -> reserved for tlb, extclass_enable(0) for erats
   //      19    -> mmucsr0.tlb0fi for tlb, or TID_NZ for erats
   //      20:25 -> TID(0:5)
   assign comp_extclass[0] = 1'b0;              //extclass compare value
   assign comp_extclass[1] = snoop_attr_q[19];  //TID_NZ compare value

   assign extclass_enable[0] = csinv_complete |         // csync or isync enabled and complete
                              (snoop_val_q[0] & snoop_val_q[1] & snoop_attr_q[18]);     // any invalidate snoop
   assign extclass_enable[1] = (~csinv_complete) &
                               (snoop_val_q[0] & snoop_val_q[1] & (~snoop_attr_q[1]) & snoop_attr_q[3]);        // any invalidate snoop, compare TID_NZ for inval by pid or va


   // state: 0:pr 1:gs 2:is 3:cm
   // cam state bits are 0:HS, 1:AS
   assign comp_state = (snoop_attr_q[4:5] & {2{snoop_val_q[0] & snoop_val_q[1] & (~snoop_attr_q[1]) & snoop_attr_q[2]}}) |   // attr="01", gs or va snoop;
                       (ex1_state_q[1:2]  & {2{(~(snoop_val_q[0] & snoop_val_q[1])) & ex1_ieratsx}}) |   // eratsx
                       (iu1_state_d[1:2]  & {2{(~(snoop_val_q[0] & snoop_val_q[1])) & (~ex1_ieratsx)}});

   assign state_enable[0] = (~(csinv_complete)) &               // not csync or isync enabled and complete
       ( (snoop_val_q[0] & snoop_val_q[1] & (~snoop_attr_q[1]) & snoop_attr_q[2]) |     // T=2 or 3, gs or va invalidate snoop
         ( (|(ex1_valid_q[0:`THREADS-1])) & ex1_ttype_q[2] & ex1_tlbsel_q[0] & (~ex1_tlbsel_q[1]) & (~(snoop_val_q[0] & snoop_val_q[1])) ) |   // eratsx, tlbsel=2
         ( iu_ierat_iu0_val & (~(snoop_val_q[0] & snoop_val_q[1])) ) );   // fetch

   assign state_enable[1] = (~(csinv_complete)) &               // not csync or isync enabled and complete
       ( (snoop_val_q[0] & snoop_val_q[1] & (~snoop_attr_q[1]) & snoop_attr_q[2] & snoop_attr_q[3]) |     // T=3, va invalidate snoop
         ( (|(ex1_valid_q[0:`THREADS-1])) & ex1_ttype_q[2] & ex1_tlbsel_q[0] & (~ex1_tlbsel_q[1]) & (~(snoop_val_q[0] & snoop_val_q[1])) ) |   // eratsx, tlbsel=2
         ( iu_ierat_iu0_val & (~(snoop_val_q[0] & snoop_val_q[1])) ) );   // fetch

   generate
   begin : xhdl3
     genvar  tid;
     for (tid = 0; tid <= 3; tid = tid + 1)
     begin : compTids
       if (tid < `THREADS)
       begin : validTid
         assign comp_thdid[tid] = (snoop_attr_q[22+tid] & (mmucr1_q[8] & snoop_val_q[0] & snoop_val_q[1])) |    // ITTID=1 invalidate snoop
                                  (ex1_pid_q[pid_width-12+tid] & (mmucr1_q[8] & (~(snoop_val_q[0] & snoop_val_q[1])) & ex1_ieratsx)) |    // ITTID=1 eratsx
                                  (iu1_pid_d[pid_width-12+tid] & (mmucr1_q[8] & (~(snoop_val_q[0] & snoop_val_q[1])) & (~ex1_ieratsx))) |    // ITTID=1
                                  (snoop_val_q[0] & snoop_val_q[1] & (~mmucr1_q[8])) |   // invalidate snoop
                                  (ex1_valid_q[tid] & (ex1_ttype_q[2] & ex1_tlbsel_q[0] & (~ex1_tlbsel_q[1]) & (~(snoop_val_q[0] & snoop_val_q[1])) & (~mmucr1_q[8]))) |   // eratsx
                                  (iu_ierat_iu0_thdid[tid] & (((~|(ex1_valid_q[0:`THREADS - 1])) | (~ex1_ttype_q[2]) | (ex1_tlbsel_q != TlbSel_IErat)) & (~(snoop_val_q[0] & snoop_val_q[1])) & (~mmucr1_q[8])) );
       end
       if (tid >= `THREADS)
       begin : nonValidTid
         assign comp_thdid[tid] = (snoop_attr_q[22+tid] & (mmucr1_q[8] & snoop_val_q[0] & snoop_val_q[1]))  |   // ITTID=1 invalidate snoop
                                  (ex1_pid_q[pid_width-12+tid] & (mmucr1_q[8] & (~(snoop_val_q[0] & snoop_val_q[1])) & ex1_ieratsx)) |    // ITTID=1 eratsx
                                  (iu1_pid_d[pid_width-12+tid] & (mmucr1_q[8] & (~(snoop_val_q[0] & snoop_val_q[1])) & (~ex1_ieratsx))) |    // ITTID=1
                                  (snoop_val_q[0] & snoop_val_q[1] & (~mmucr1_q[8]));    // invalidate snoop
       end
     end
   end
   endgenerate

   assign thdid_enable[0] = ( (iu_ierat_iu0_val | (|(ex1_valid_q[0:`THREADS - 1])) & ex1_ttype_q[2] & ex1_tlbsel_q[0] & (~ex1_tlbsel_q[1])) &
                              ((~mmucr1_q[8]) & (~(snoop_val_q[0] & snoop_val_q[1])) & (~(csinv_complete))) );
   assign thdid_enable[1] = pid_enable & mmucr1_q[8];   // 0 when mmucr1.ITTID=0

   assign comp_pid = (snoop_attr_q[6:13] & {8{snoop_val_q[0] & snoop_val_q[1]}}) |    // invalidate snoop
                     (ex1_pid_q[pid_width-8:pid_width-1] &
                       {8{ (|(ex1_valid_q[0:`THREADS - 1])) & ex1_ttype_q[2] & ex1_tlbsel_q[0] & (~ex1_tlbsel_q[1]) & (~(snoop_val_q[0] & snoop_val_q[1]))}} ) |    // eratsx
                     (iu1_pid_d[pid_width-8:pid_width-1] &
                       {8{( ~( (|(ex1_valid_q[0:`THREADS - 1])) & ex1_ttype_q[2] & ex1_tlbsel_q[0] & (~ex1_tlbsel_q[1])) & (~(snoop_val_q[0] & snoop_val_q[1])))}} );

   assign pid_enable = (~(csinv_complete)) &    // not csync or isync enabled and complete
                       ( (snoop_val_q[0] & snoop_val_q[1] & (~snoop_attr_q[1]) & snoop_attr_q[3]) |    // T=1, pid invalidate snoop, T=3, va invalidate snoop
                         ( (|(ex1_valid_q[0:`THREADS - 1])) & ex1_ttype_q[2] & ex1_tlbsel_q[0] & (~ex1_tlbsel_q[1]) & (~(snoop_val_q[0] & snoop_val_q[1])) ) |    // eratsx, tlbsel=2
                         (iu_ierat_iu0_val & (~(snoop_val_q[0] & snoop_val_q[1]))) );    // fetch

   // wr_cam_data
   //  0:51  - EPN
   //  52  - X
   //  53:55  - SIZE
   //  56  - V
   //  57:60  - ThdID
   //  61:62  - Class
   //  63:64  - ExtClass | TID_NZ
   //  65  - TGS
   //  66  - TS
   //  67:74  - TID
   //  75:78  - epn_cmpmasks:  34_39, 40_43, 44_47, 48_51
   //  79:82  - xbit_cmpmasks: 34_51, 40_51, 44_51, 48_51
   //  83  - parity for 75:82

   // 16x143 version, 42b RA
   // wr_array_data
   //  0:29  - RPN
   //  30:31  - R,C
   //  32:33  - WLC
   //  34     - ResvAttr
   //  35     - VF
   //  36:39  - U0-U3
   //  40:44  - WIMGE
   //  45:46  - UX,SX
   //  47:48  - UW,SW
   //  49:50  - UR,SR
   //  51:60  - CAM parity
   //  61:67  - Array parity

   // wr_ws0_data (LO)
   //  0:51  - EPN
   //  52:53  - Class
   //  54  - V
   //  55  - X
   //  56:59  - SIZE
   //  60:63  - ThdID

   // CAM.ExtClass - MMUCR ExtClass
   // CAM.TS - MMUCR TS
   // CAM.TID - MMUCR TID

   // wr_ws1_data (HI)
   //  0:7  - unused
   //  8:9  - WLC
   //  10  - ResvAttr
   //  11  - unused
   //  12:15  - U0-U3
   //  16:17  - R,C
   //  18:21  - unused
   //  22:51  - RPN
   //  52:56  - WIMGE
   //  57  - VF (not supported in ierat)
   //  58:59  - UX,SX
   //  60:61  - UW,SW
   //  62:63  - UR,SR

   generate
      if (data_out_width == 64)
      begin : gen64_data_out
         assign ex4_data_out_d =
            ( {32'b0, rd_cam_data[32:51],
               (rd_cam_data[61:62] & {2{~(mmucr1_q[7])}}),
                rd_cam_data[56], rd_cam_data[52], ws0_pgsize[0:3],
               (rd_cam_data[57:58] | {2{mmucr1_q[8]}}), 2'b0} &
                {data_out_width{(|(ex3_valid_q)) & ex3_ttype_q[0] & (~ex3_ws_q[0]) & (~ex3_ws_q[1]) & (~ex3_state_q[3])}} ) |   // eratre, WS=0, cm=32b
            ( {32'b0, rd_array_data[10:29], 2'b00, rd_array_data[0:9]} &
                {data_out_width{(|(ex3_valid_q)) & ex3_ttype_q[0] & (~ex3_ws_q[0]) & ex3_ws_q[1] & (~ex3_state_q[3])}} ) |   // eratre, WS=1, cm=32b
            ( {32'b0, 8'b00000000, rd_array_data[32:34], 1'b0, rd_array_data[36:39], rd_array_data[30:31], 2'b00,
               rd_array_data[40:44], 1'b0, rd_array_data[45:50]} &   // VF doesn't exist in ierat
                {data_out_width{(|(ex3_valid_q)) & ex3_ttype_q[0] & ex3_ws_q[0] & (~ex3_ws_q[1]) & (~ex3_state_q[3])}} ) |   // eratre, WS=2, cm=32b
            ( {rd_cam_data[0:51],
              (rd_cam_data[61:62] & {2{~(mmucr1_q[7])}}),
               rd_cam_data[56], rd_cam_data[52], ws0_pgsize[0:3],
              (rd_cam_data[57:58] | {2{mmucr1_q[8]}}), 2'b0} &
                {data_out_width{(|(ex3_valid_q)) & ex3_ttype_q[0] & (~ex3_ws_q[0]) & (~ex3_ws_q[1]) & ex3_state_q[3]}} ) |   // eratre, WS=0, cm=64b
            ( {8'b00000000, rd_array_data[32:34], 1'b0, rd_array_data[36:39], rd_array_data[30:31], 4'b0000, rd_array_data[0:29], rd_array_data[40:44], 1'b0, rd_array_data[45:50]} &    // VF doesn't exist in ierat
                {data_out_width{(|(ex3_valid_q)) & ex3_ttype_q[0] & (~ex3_ws_q[0]) & ex3_ws_q[1] & ex3_state_q[3]}} ) |    // eratre, WS=1, cm=64b
            ( {60'b0, eptr_q} &
                {data_out_width{(|(ex3_valid_q)) & ex3_ttype_q[0] & ex3_ws_q[0] & ex3_ws_q[1] & mmucr1_q[0]}} ) |   // eratre, WS=3, IRRE=1
            ( {60'b0, lru_way_encode} &
                {data_out_width{(|(ex3_valid_q)) & ex3_ttype_q[0] & ex3_ws_q[0] & ex3_ws_q[1] & (~mmucr1_q[0])}} ) |   // eratre, WS=3, IRRE=0
            ( {50'b0, ex3_eratsx_data_q[0:1], 8'b0, ex3_eratsx_data_q[2:2 + num_entry_log2 - 1]} &
                {data_out_width{(|(ex3_valid_q)) & ex3_ttype_q[2]}} );   // eratsx
      end
   endgenerate

   generate
      if (data_out_width == 32)
      begin : gen32_data_out
         assign ex4_data_out_d = (({rd_cam_data[32:51],
                                         (rd_cam_data[61:62] & {2{~(mmucr1_q[7])}}),
                                          rd_cam_data[56], rd_cam_data[52], ws0_pgsize[0:3],
                                         (rd_cam_data[57:58] | {2{mmucr1_q[8]}}), 2'b0}) &
                                             ({data_out_width{(|(ex3_valid_q) & ex3_ttype_q[0] & (~ex3_ws_q[0]) & (~ex3_ws_q[1]))}})) |
                                   (({rd_array_data[10:29], 2'b00, rd_array_data[0:9]}) &
                                             ({data_out_width{(|(ex3_valid_q) & ex3_ttype_q[0] & (~ex3_ws_q[0]) & ex3_ws_q[1])}})) |
                                   (({8'b00000000, rd_array_data[32:34], 1'b0, rd_array_data[36:39], rd_array_data[30:31], 2'b00,
                                      rd_array_data[40:44], 1'b0, rd_array_data[45:50]}) &  // VF doesn't exist in ierat
                                             ({data_out_width{(|(ex3_valid_q) & ex3_ttype_q[0] & ex3_ws_q[0] & (~ex3_ws_q[1]))}})) |
                                   (({({28{1'b0}}), eptr_q}) &
                                             ({data_out_width{(|(ex3_valid_q) & ex3_ttype_q[0] & ex3_ws_q[0] & ex3_ws_q[1] & mmucr1_q[0])}})) |
                                   (({({28{1'b0}}), lru_way_encode}) &
                                             ({data_out_width{(|(ex3_valid_q) & ex3_ttype_q[0] & ex3_ws_q[0] & ex3_ws_q[1] & (~mmucr1_q[0]))}})) |
                                   (({({18{1'b0}}), ex3_eratsx_data_q[0:1], ({8{1'b0}}), ex3_eratsx_data_q[2:2 + num_entry_log2 - 1]}) &
                                             ({data_out_width{(|(ex3_valid_q) & ex3_ttype_q[2])}}));
      end
   endgenerate

   // TIMING FIX RESTRUCTURING   use cam_cmp_data(75:78) cmpmask bits
   //        wr_cam_data(75)   (76)    (77)   (78)           (79)   (80)   (81)   (82)
   //             cmpmask(0)    (1)     (2)    (3)    xbitmask(0)    (1)    (2)    (3)
   //   xbit  pgsize      34_39  40_43  44_47  48_51           34_39  40_43  44_47  48_51    size
   //    0     001          1      1      1      1               0      0      0      0       4K
   //    0     011          1      1      1      0               0      0      0      0       64K
   //    0     101          1      1      0      0               0      0      0      0       1M
   //    0     111          1      0      0      0               0      0      0      0       16M
   //    0     110          0      0      0      0               0      0      0      0       1G

   // new cam _np2  bypass attributes (bit numbering per array)
   //  30:31  - R,C
   //  32:33  - WLC
   //  34  - ResvAttr
   //  35  - VF
   //  36:39  - U0-U3
   //  40:44  - WIMGE
   //  45:46  - UX,SX
   //  47:48  - UW,SW
   //  49:50  - UR,SR

   assign bypass_mux_enab_np1 = (ccr2_frat_paranoia_q[9] | iu_ierat_iu1_back_inv | an_ac_grffence_en_dc);
   assign bypass_attr_np1[0:5] = 6'b0;    // new cam _np1 bypass attributes in
   assign bypass_attr_np1[6:9] = ccr2_frat_paranoia_q[5:8];    // new cam _np1 bypass ubits attributes in
   assign bypass_attr_np1[10:14] = ccr2_frat_paranoia_q[0:4];    // new cam _np1 bypass wimge attributes in
   assign bypass_attr_np1[15:20] = 6'b111111;    // new cam _np1 bypass protection attributes in

   assign ierat_iu_iu2_error[0] = iu2_miss_sig | iu2_multihit_sig | iu2_parerr_sig | iu2_isi_sig;
   assign ierat_iu_iu2_error[1] = iu2_miss_sig | iu2_multihit_sig;
   assign ierat_iu_iu2_error[2] = iu2_miss_sig | iu2_parerr_sig;

   // added these outputs for timing in iuq_ic
   assign ierat_iu_iu2_miss = iu2_miss_sig;
   assign ierat_iu_iu2_multihit = iu2_multihit_sig;
   assign ierat_iu_iu2_isi = iu2_isi_sig;

   assign ierat_iu_hold_req = hold_req_q;
   assign ierat_iu_iu2_flush_req = iu2_n_flush_req_q;
   assign iu_xu_ex4_data = ex4_data_out_q;

   assign iu_mm_ierat_req = iu2_tlbreq_q;
   assign iu_mm_ierat_req_nonspec = iu2_nonspec_q;
   assign iu_mm_ierat_thdid = iu2_valid_q;
   assign iu_mm_ierat_state = iu2_state_q;
   assign iu_mm_ierat_tid = iu2_pid_q;
   assign iu_mm_ierat_flush = iu_mm_ierat_flush_q;

   assign iu_mm_ierat_mmucr0 = {ex6_extclass_q, ex6_state_q[1:2], ex6_pid_q};
   assign iu_mm_ierat_mmucr0_we = ((ex6_ttype_q[0] == 1'b1 & ex6_ws_q == 2'b00 & ex6_tlbsel_q == TlbSel_IErat)) ? ex6_valid_q :
                                  {`THREADS{1'b0}};

   assign iu_mm_ierat_mmucr1 = ex6_ieen_q[`THREADS:`THREADS+num_entry_log2-1];  // error entry found
   assign iu_mm_ierat_mmucr1_we = ex6_ieen_q[0:`THREADS-1];  // eratsx, eratre parity error

   assign iu2_perf_itlb_d = iu1_valid_q;
   assign iu_mm_perf_itlb = iu2_perf_itlb_q & {`THREADS{iu2_miss_sig}};

   assign iu_pc_err_ierat_parity_d = iu2_parerr_sig;

   tri_direct_err_rpt #(.WIDTH(1)) err_ierat_parity(
      .vd(vdd),
      .gd(gnd),
      .err_in(iu_pc_err_ierat_parity_q),
      .err_out(iu_pc_err_ierat_parity)
   );

   assign iu_pc_err_ierat_multihit_d = iu2_multihit_sig;

   tri_direct_err_rpt #(.WIDTH(1)) err_ierat_multihit(
      .vd(vdd),
      .gd(gnd),
      .err_in(iu_pc_err_ierat_multihit_q),
      .err_out(iu_pc_err_ierat_multihit)
   );

   // NOTE: example parity generation/checks in iuq_ic_dir.vhdl or xuq_lsu_dc_arr.vhdl.

   //---------------------------------------------------------------------
   // CAM Instantiation
   //---------------------------------------------------------------------
   //ierat_cam: entity work.tri_cam_16x143_1r1w1c

   tri_cam_16x143_1r1w1c  ierat_cam(
      .gnd(gnd),
      .vdd(vdd),
      .vcs(vcs),
      .nclk(nclk),

      .tc_ccflush_dc(tc_ccflush_dc),
      .tc_scan_dis_dc_b(tc_scan_dis_dc_b),
      .tc_scan_diag_dc(tc_scan_diag_dc),
      .tc_lbist_en_dc(tc_lbist_en_dc),
      .an_ac_atpg_en_dc(an_ac_atpg_en_dc),

      .lcb_d_mode_dc(cam_d_mode),
      .lcb_clkoff_dc_b(cam_clkoff_b),
      .lcb_act_dis_dc(cam_act_dis),
      .lcb_mpw1_dc_b(cam_mpw1_b[0:3]),
      .lcb_mpw2_dc_b(cam_mpw2_b),
      .lcb_delay_lclkr_dc(cam_delay_lclkr[0:3]),

      .pc_sg_2(pc_iu_sg_2),
      .pc_func_slp_sl_thold_2(pc_iu_func_slp_sl_thold_2),
      .pc_func_slp_nsl_thold_2(pc_iu_func_slp_nsl_thold_2),
      .pc_regf_slp_sl_thold_2(pc_iu_regf_slp_sl_thold_2),
      .pc_time_sl_thold_2(pc_iu_time_sl_thold_2),
      .pc_fce_2(pc_iu_fce_2),

      .func_scan_in(func_scan_in_cam),
      .func_scan_out(func_scan_out_cam),
      .regfile_scan_in(regf_scan_in),   // 0:2 -> CAM, 3:4 -> RAM
      .regfile_scan_out(regf_scan_out),
      .time_scan_in(time_scan_in),
      .time_scan_out(time_scan_out),

      .rd_val(rd_val),          // this is actually the internal read act pin
      .rd_val_late(tiup),       // this is actually the internal read functional pin
      .rw_entry(rw_entry),

      .wr_array_data(wr_array_data),
      .wr_cam_data(wr_cam_data),
      .wr_array_val(wr_array_val),      //this is actually the internal write functional pin
      .wr_cam_val(wr_cam_val),          //this is actually the internal write functional pin
      .wr_val_early(wr_val_early),      //this is actually the internal write act pin

      .comp_request(comp_request),
      .comp_addr(comp_addr),
      .addr_enable(addr_enable),
      .comp_pgsize(comp_pgsize),
      .pgsize_enable(pgsize_enable),
      .comp_class(comp_class),
      .class_enable(class_enable),
      .comp_extclass(comp_extclass),
      .extclass_enable(extclass_enable),
      .comp_state(comp_state),
      .state_enable(state_enable),
      .comp_thdid(comp_thdid),
      .thdid_enable(thdid_enable),
      .comp_pid(comp_pid),
      .pid_enable(pid_enable),
      .comp_invalidate(comp_invalidate),
      .flash_invalidate(flash_invalidate),

      .array_cmp_data(array_cmp_data),
      .rd_array_data(rd_array_data),

      .cam_cmp_data(cam_cmp_data),
      .cam_hit(cam_hit),
      .cam_hit_entry(cam_hit_entry),
      .entry_match(entry_match),
      .entry_valid(entry_valid),
      .rd_cam_data(rd_cam_data),

      //--- new ports for IO plus -----------------------
      .bypass_mux_enab_np1(bypass_mux_enab_np1),
      .bypass_attr_np1(bypass_attr_np1),
      .attr_np2(attr_np2),
      .rpn_np2(rpn_np2)
   );

   // bypass attributes (bit numbering per array)
   //  30:31  - R,C
   //  32:33  - WLC
   //  34  - ResvAttr
   //  35  - VF
   //  36:39  - U0-U3
   //  40:44  - WIMGE
   //  45:46  - UX,SX
   //  47:48  - UW,SW
   //  49:50  - UR,SR
   assign ierat_iu_iu2_rpn = rpn_np2;    // erat array will always be 30 bits RPN
   assign ierat_iu_iu2_wimge = attr_np2[10:14];
   assign ierat_iu_iu2_u = attr_np2[6:9];

   assign ierat_iu_cam_change = lru_update_event_q[9];

   // debug bus outputs
   assign iu1_debug_d[0] = comp_request;
   assign iu1_debug_d[1] = comp_invalidate;
   assign iu1_debug_d[2] = csinv_complete;      // comp_request term1, csync or isync enabled and complete
   assign iu1_debug_d[3] = 1'b0;                // comp_request term2, spare
   assign iu1_debug_d[4] = (snoop_val_q[0] & snoop_val_q[1] & (~|(tlb_rel_val_q[0:3])) );   // comp_request term3, invalidate snoop, not reload;
   assign iu1_debug_d[5] = (ex1_ieratsx);       // comp_request term4, eratsx
   assign iu1_debug_d[6] = (iu_ierat_iu0_val);  // comp_request term5, fetch
   assign iu1_debug_d[7] = ( (|(tlb_rel_val_q[0:3])) & tlb_rel_val_q[4] );      // comp_invalidate term2, tlb reload
   assign iu1_debug_d[8] = |(tlb_rel_val_q[0:3]);       // any tlb reload
   assign iu1_debug_d[9] = (snoop_val_q[0] & snoop_val_q[1]);   // any snoop
   assign iu1_debug_d[10] = 1'b0;               // spare

   assign iu2_debug_d[0:10] = iu1_debug_q[0:10];
   assign iu2_debug_d[11:15] = {1'b0, iu1_first_hit_entry};
   assign iu2_debug_d[16] = iu1_multihit;

   assign lru_debug_d[0] = (tlb_rel_data_q[eratpos_wren] & (|(tlb_rel_val_q[0:3])) & tlb_rel_val_q[4]);   // lru update term1: tlb reload
   assign lru_debug_d[1] = (snoop_val_q[0] & snoop_val_q[1]);   //lru update term2: invalidate snoop
   assign lru_debug_d[2] = (csinv_complete);                    // lru update term3: csync or isync enabled and complete
   assign lru_debug_d[3] = ( (|(ex6_valid_q[0:`THREADS-1])) & ex6_ttype_q[1] & (~ex6_ws_q[0]) & (~ex6_ws_q[1]) & ex6_tlbsel_q[0] & (~ex6_tlbsel_q[1]) & lru_way_is_written );   // lru update term4: eratwe WS=0
   assign lru_debug_d[4] = ( (|(iu1_valid_q & (~(iu_ierat_iu1_flush)) & (~(xu_iu_flush | br_iu_flush)) & (~(iu2_n_flush_req_q)))) &
                             (~iu1_flush_enab_q) & cam_hit & lru_way_is_hit_entry );    // lru update term5: fetch hit
   assign lru_debug_d[5:19] = lru_eff;
   assign lru_debug_d[20:23] = lru_way_encode;

   // debug groups:  out std_ulogic_vector(0 to 87);
   assign ierat_iu_debug_group0[0:83]  = iu2_cam_cmp_data_q[0:83];
   assign ierat_iu_debug_group0[84]    = ex3_eratsx_data_q[1];   // cam_hit delayed, iu2 phase in reality
   assign ierat_iu_debug_group0[85]    = iu2_debug_q[0];   // comp_request
   assign ierat_iu_debug_group0[86]    = iu2_debug_q[1];   // comp_invalidate
   assign ierat_iu_debug_group0[87]    = iu2_debug_q[9];   // any snoop

   assign ierat_iu_debug_group1[0:67]  = iu2_array_cmp_data_q[0:67];
   assign ierat_iu_debug_group1[68]    = ex3_eratsx_data_q[1];   // cam_hit delayed, iu2 phase in reality
   assign ierat_iu_debug_group1[69]    = iu2_debug_q[16];   //multihit
   assign ierat_iu_debug_group1[70:74] = iu2_debug_q[11:15];   //iu2 cam_hit_entry
   assign ierat_iu_debug_group1[75] = iu2_debug_q[0];   // comp_request
   assign ierat_iu_debug_group1[76] = iu2_debug_q[1];   // comp_invalidate
   assign ierat_iu_debug_group1[77] = iu2_debug_q[2];   // comp_request term1, csync or isync enabled
   assign ierat_iu_debug_group1[78] = iu2_debug_q[3];   // comp_request term2, write to eplc or epsc, DCTID=0
   assign ierat_iu_debug_group1[79] = iu2_debug_q[4];   // comp_request term3, invalidate snoop, not reload;
   assign ierat_iu_debug_group1[80] = iu2_debug_q[5];   // comp_request term4, eratsx
   assign ierat_iu_debug_group1[81] = iu2_debug_q[6];   // comp_request term5, load or store
   assign ierat_iu_debug_group1[82] = iu2_debug_q[7];   // comp_invalidate term2, tlb reload
   assign ierat_iu_debug_group1[83] = iu2_debug_q[8];   // any tlb reload
   assign ierat_iu_debug_group1[84] = iu2_debug_q[9];   // any snoop
   assign ierat_iu_debug_group1[85] = iu2_debug_q[10];   // spare
   assign ierat_iu_debug_group1[86] = iu2_prefetch_q;   // spare
   assign ierat_iu_debug_group1[87] = lru_update_event_q[7] | lru_update_event_q[8];   // any lru update event

   assign ierat_iu_debug_group2[0:15] = entry_valid_q[0:15];
   assign ierat_iu_debug_group2[16:31] = entry_match_q[0:15];
   assign ierat_iu_debug_group2[32:47] = {1'b0, lru_q[1:15]};
   assign ierat_iu_debug_group2[48:63] = {1'b0, lru_debug_q[5:19]};   // lru_eff(1 to 15)
   assign ierat_iu_debug_group2[64:73] = {lru_update_event_q[0:8], iu2_debug_q[16]};   // update events, multihit
   assign ierat_iu_debug_group2[74:78] = {1'b0, lru_debug_q[20:23]};   // '0' & lru_way_encode
   assign ierat_iu_debug_group2[79:83] = {1'b0, watermark_q[0:3]};
   assign ierat_iu_debug_group2[84] = ex3_eratsx_data_q[1];   // cam_hit delayed
   assign ierat_iu_debug_group2[85] = iu2_debug_q[0];   // comp_request
   assign ierat_iu_debug_group2[86] = iu2_debug_q[1];   // comp_invalidate
   assign ierat_iu_debug_group2[87] = iu2_debug_q[9];   // any snoop

   assign ierat_iu_debug_group3[0] = ex3_eratsx_data_q[1];   // cam_hit delayed
   assign ierat_iu_debug_group3[1] = iu2_debug_q[0];   // comp_request
   assign ierat_iu_debug_group3[2] = iu2_debug_q[1];   // comp_invalidate
   assign ierat_iu_debug_group3[3] = iu2_debug_q[9];   // any snoop
   assign ierat_iu_debug_group3[4:8] = iu2_debug_q[11:15];   // '0' & cam_hit_entry
   assign ierat_iu_debug_group3[9] = lru_update_event_q[7] | lru_update_event_q[8];   // any lru update event
   assign ierat_iu_debug_group3[10:14] = lru_debug_q[0:4];   // lru update terms:  tlb_reload, snoop, csync/isync, eratwe, fetch hit
   assign ierat_iu_debug_group3[15:19] = {1'b0, watermark_q[0:3]};
   assign ierat_iu_debug_group3[20:35] = entry_valid_q[0:15];
   assign ierat_iu_debug_group3[36:51] = entry_match_q[0:15];
   assign ierat_iu_debug_group3[52:67] = {1'b0, lru_q[1:15]};
   assign ierat_iu_debug_group3[68:83] = {1'b0, lru_debug_q[5:19]};   // lru_eff(1 to 15)
   assign ierat_iu_debug_group3[84:87] = lru_debug_q[20:23];   // lru_way_encode


   // unused spare signal assignments
   assign unused_dc[0] = mmucr1_q[2];
   assign unused_dc[1] = iu2_multihit_enab & (|(iu2_first_hit_entry));
   assign unused_dc[2] = ex6_ttype_q[2] & ex6_state_q[0];
   assign unused_dc[3] = |(tlb_rel_data_q[eratpos_rpnrsvd:eratpos_rpnrsvd + 3]);
   assign unused_dc[4] = iu2_cam_cmp_data_q[56] | ex4_rd_cam_data_q[56];
   assign unused_dc[5] = |(attr_np2[0:5]);
   assign unused_dc[6] = |(attr_np2[15:20]);
   assign unused_dc[7] = |(cam_hit_entry);
   assign unused_dc[8] = |(bcfg_q_b[0:15]);
   assign unused_dc[9] = |(bcfg_q_b[16:31]);
   assign unused_dc[10] = |(bcfg_q_b[32:47]);
   assign unused_dc[11] = |(bcfg_q_b[48:51]);
   assign unused_dc[12] = |(bcfg_q_b[52:61]);
   assign unused_dc[13] = |(bcfg_q_b[62:77]);
   assign unused_dc[14] = |(bcfg_q_b[78:81]);
   assign unused_dc[15] = |(bcfg_q_b[82:86]);
   assign unused_dc[16] = |(ex1_ra_entry_q);
   assign unused_dc[17] = xu_iu_is_eratilx;
   assign unused_dc[18] = 1'b0;
   assign unused_dc[19] = pc_func_sl_thold_0_b | pc_func_sl_force;
   assign unused_dc[20] = cam_mpw1_b[4] | cam_delay_lclkr[4];
   assign unused_dc[21] = 1'b0;
   // bit 22 used elsewhere
   assign unused_dc[23] = ex7_ttype_q[0];
   assign unused_dc[24] = ex7_ttype_q[2];
   assign unused_dc[25] = |(por_wr_array_data[51:67]);
   assign unused_dc[26] = |(bcfg_q_b[87:102]);
   assign unused_dc[27] = |(bcfg_q_b[103:106]);
   assign unused_dc[28] = |(bcfg_q[107:122]);
   assign unused_dc[29] = |(bcfg_q_b[107:122]);

   //---------------------------------------------------------------------
   // Latches
   //---------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex1_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex1_valid_offset:ex1_valid_offset + `THREADS - 1]),
      .scout(sov_0[ex1_valid_offset:ex1_valid_offset + `THREADS - 1]),
      .din(ex1_valid_d[0:`THREADS - 1]),
      .dout(ex1_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(ttype_width), .INIT(0), .NEEDS_SRESET(1)) ex1_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex1_ttype_offset:ex1_ttype_offset + ttype_width - 1]),
      .scout(sov_0[ex1_ttype_offset:ex1_ttype_offset + ttype_width - 1]),
      .din(ex1_ttype_d),
      .dout(ex1_ttype_q)
   );

   tri_rlmreg_p #(.WIDTH(ws_width), .INIT(0), .NEEDS_SRESET(1)) ex1_ws_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex1_ws_offset:ex1_ws_offset + ws_width - 1]),
      .scout(sov_0[ex1_ws_offset:ex1_ws_offset + ws_width - 1]),
      .din(ex1_ws_d[0:ws_width - 1]),
      .dout(ex1_ws_q[0:ws_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ra_entry_width), .INIT(0), .NEEDS_SRESET(1)) ex1_ra_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex1_ra_entry_offset:ex1_ra_entry_offset + ra_entry_width - 1]),
      .scout(sov_0[ex1_ra_entry_offset:ex1_ra_entry_offset + ra_entry_width - 1]),
      .din(ex1_ra_entry_d[0:ra_entry_width - 1]),
      .dout(ex1_ra_entry_q[0:ra_entry_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(state_width), .INIT(0), .NEEDS_SRESET(1)) ex1_state_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex1_state_offset:ex1_state_offset + state_width - 1]),
      .scout(sov_0[ex1_state_offset:ex1_state_offset + state_width - 1]),
      .din(ex1_state_d[0:state_width - 1]),
      .dout(ex1_state_q[0:state_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(pid_width), .INIT(0), .NEEDS_SRESET(1)) ex1_pid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex1_pid_offset:ex1_pid_offset + pid_width - 1]),
      .scout(sov_0[ex1_pid_offset:ex1_pid_offset + pid_width - 1]),
      .din(ex1_pid_d),
      .dout(ex1_pid_q)
   );

   tri_rlmreg_p #(.WIDTH(extclass_width), .INIT(0), .NEEDS_SRESET(1)) ex1_extclass_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex1_extclass_offset:ex1_extclass_offset + extclass_width - 1]),
      .scout(sov_0[ex1_extclass_offset:ex1_extclass_offset + extclass_width - 1]),
      .din(ex1_extclass_d[0:extclass_width - 1]),
      .dout(ex1_extclass_q[0:extclass_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(tlbsel_width), .INIT(0), .NEEDS_SRESET(1)) ex1_tlbsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex1_tlbsel_offset:ex1_tlbsel_offset + tlbsel_width - 1]),
      .scout(sov_0[ex1_tlbsel_offset:ex1_tlbsel_offset + tlbsel_width - 1]),
      .din(ex1_tlbsel_d[0:tlbsel_width - 1]),
      .dout(ex1_tlbsel_q[0:tlbsel_width - 1])
   );
   //-----------------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex2_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_valid_offset:ex2_valid_offset + `THREADS - 1]),
      .scout(sov_0[ex2_valid_offset:ex2_valid_offset + `THREADS - 1]),
      .din(ex2_valid_d[0:`THREADS - 1]),
      .dout(ex2_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(ttype_width), .INIT(0), .NEEDS_SRESET(1)) ex2_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_ttype_offset:ex2_ttype_offset + ttype_width - 1]),
      .scout(sov_0[ex2_ttype_offset:ex2_ttype_offset + ttype_width - 1]),
      .din(ex2_ttype_d[0:ttype_width - 1]),
      .dout(ex2_ttype_q[0:ttype_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ws_width), .INIT(0), .NEEDS_SRESET(1)) ex2_ws_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex1_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_ws_offset:ex2_ws_offset + ws_width - 1]),
      .scout(sov_0[ex2_ws_offset:ex2_ws_offset + ws_width - 1]),
      .din(ex2_ws_d[0:ws_width - 1]),
      .dout(ex2_ws_q[0:ws_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ra_entry_width), .INIT(0), .NEEDS_SRESET(1)) ex2_ra_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex1_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_ra_entry_offset:ex2_ra_entry_offset + ra_entry_width - 1]),
      .scout(sov_0[ex2_ra_entry_offset:ex2_ra_entry_offset + ra_entry_width - 1]),
      .din(ex2_ra_entry_d[0:ra_entry_width - 1]),
      .dout(ex2_ra_entry_q[0:ra_entry_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(state_width), .INIT(0), .NEEDS_SRESET(1)) ex2_state_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex1_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_state_offset:ex2_state_offset + state_width - 1]),
      .scout(sov_0[ex2_state_offset:ex2_state_offset + state_width - 1]),
      .din(ex2_state_d[0:state_width - 1]),
      .dout(ex2_state_q[0:state_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(pid_width), .INIT(0), .NEEDS_SRESET(1)) ex2_pid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex1_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_pid_offset:ex2_pid_offset + pid_width - 1]),
      .scout(sov_0[ex2_pid_offset:ex2_pid_offset + pid_width - 1]),
      .din(ex2_pid_d),
      .dout(ex2_pid_q)
   );

   tri_rlmreg_p #(.WIDTH(extclass_width), .INIT(0), .NEEDS_SRESET(1)) ex2_extclass_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex1_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_extclass_offset:ex2_extclass_offset + extclass_width - 1]),
      .scout(sov_0[ex2_extclass_offset:ex2_extclass_offset + extclass_width - 1]),
      .din(ex2_extclass_d[0:extclass_width - 1]),
      .dout(ex2_extclass_q[0:extclass_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(tlbsel_width), .INIT(0), .NEEDS_SRESET(1)) ex2_tlbsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex1_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex2_tlbsel_offset:ex2_tlbsel_offset + tlbsel_width - 1]),
      .scout(sov_0[ex2_tlbsel_offset:ex2_tlbsel_offset + tlbsel_width - 1]),
      .din(ex2_tlbsel_d[0:tlbsel_width - 1]),
      .dout(ex2_tlbsel_q[0:tlbsel_width - 1])
   );

   //-----------------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_valid_offset:ex3_valid_offset + `THREADS - 1]),
      .scout(sov_0[ex3_valid_offset:ex3_valid_offset + `THREADS - 1]),
      .din(ex3_valid_d[0:`THREADS - 1]),
      .dout(ex3_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(ttype_width), .INIT(0), .NEEDS_SRESET(1)) ex3_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_ttype_offset:ex3_ttype_offset + ttype_width - 1]),
      .scout(sov_0[ex3_ttype_offset:ex3_ttype_offset + ttype_width - 1]),
      .din(ex3_ttype_d[0:ttype_width - 1]),
      .dout(ex3_ttype_q[0:ttype_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ws_width), .INIT(0), .NEEDS_SRESET(1)) ex3_ws_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_ws_offset:ex3_ws_offset + ws_width - 1]),
      .scout(sov_0[ex3_ws_offset:ex3_ws_offset + ws_width - 1]),
      .din(ex3_ws_d[0:ws_width - 1]),
      .dout(ex3_ws_q[0:ws_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ra_entry_width), .INIT(0), .NEEDS_SRESET(1)) ex3_ra_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_ra_entry_offset:ex3_ra_entry_offset + ra_entry_width - 1]),
      .scout(sov_0[ex3_ra_entry_offset:ex3_ra_entry_offset + ra_entry_width - 1]),
      .din(ex3_ra_entry_d[0:ra_entry_width - 1]),
      .dout(ex3_ra_entry_q[0:ra_entry_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(state_width), .INIT(0), .NEEDS_SRESET(1)) ex3_state_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_state_offset:ex3_state_offset + state_width - 1]),
      .scout(sov_0[ex3_state_offset:ex3_state_offset + state_width - 1]),
      .din(ex3_state_d[0:state_width - 1]),
      .dout(ex3_state_q[0:state_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(pid_width), .INIT(0), .NEEDS_SRESET(1)) ex3_pid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_pid_offset:ex3_pid_offset + pid_width - 1]),
      .scout(sov_0[ex3_pid_offset:ex3_pid_offset + pid_width - 1]),
      .din(ex3_pid_d),
      .dout(ex3_pid_q)
   );

   tri_rlmreg_p #(.WIDTH(extclass_width), .INIT(0), .NEEDS_SRESET(1)) ex3_extclass_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_extclass_offset:ex3_extclass_offset + extclass_width - 1]),
      .scout(sov_0[ex3_extclass_offset:ex3_extclass_offset + extclass_width - 1]),
      .din(ex3_extclass_d[0:extclass_width - 1]),
      .dout(ex3_extclass_q[0:extclass_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(tlbsel_width), .INIT(0), .NEEDS_SRESET(1)) ex3_tlbsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_tlbsel_offset:ex3_tlbsel_offset + tlbsel_width - 1]),
      .scout(sov_0[ex3_tlbsel_offset:ex3_tlbsel_offset + tlbsel_width - 1]),
      .din(ex3_tlbsel_d[0:tlbsel_width - 1]),
      .dout(ex3_tlbsel_q[0:tlbsel_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(2+num_entry_log2), .INIT(0), .NEEDS_SRESET(1)) ex3_eratsx_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(eratsx_data_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_eratsx_data_offset:ex3_eratsx_data_offset + (2+num_entry_log2) - 1]),
      .scout(sov_0[ex3_eratsx_data_offset:ex3_eratsx_data_offset + (2+num_entry_log2) - 1]),
      .din(ex3_eratsx_data_d[0:2 + num_entry_log2 - 1]),
      .dout(ex3_eratsx_data_q[0:2 + num_entry_log2 - 1])
   );
   //-----------------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_valid_offset:ex4_valid_offset + `THREADS - 1]),
      .scout(sov_0[ex4_valid_offset:ex4_valid_offset + `THREADS - 1]),
      .din(ex4_valid_d[0:`THREADS - 1]),
      .dout(ex4_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(ttype_width), .INIT(0), .NEEDS_SRESET(1)) ex4_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_ttype_offset:ex4_ttype_offset + ttype_width - 1]),
      .scout(sov_0[ex4_ttype_offset:ex4_ttype_offset + ttype_width - 1]),
      .din(ex4_ttype_d[0:ttype_width - 1]),
      .dout(ex4_ttype_q[0:ttype_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ws_width), .INIT(0), .NEEDS_SRESET(1)) ex4_ws_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_ws_offset:ex4_ws_offset + ws_width - 1]),
      .scout(sov_0[ex4_ws_offset:ex4_ws_offset + ws_width - 1]),
      .din(ex4_ws_d[0:ws_width - 1]),
      .dout(ex4_ws_q[0:ws_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ra_entry_width), .INIT(0), .NEEDS_SRESET(1)) ex4_ra_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_ra_entry_offset:ex4_ra_entry_offset + ra_entry_width - 1]),
      .scout(sov_0[ex4_ra_entry_offset:ex4_ra_entry_offset + ra_entry_width - 1]),
      .din(ex4_ra_entry_d[0:ra_entry_width - 1]),
      .dout(ex4_ra_entry_q[0:ra_entry_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(state_width), .INIT(0), .NEEDS_SRESET(1)) ex4_state_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_state_offset:ex4_state_offset + state_width - 1]),
      .scout(sov_0[ex4_state_offset:ex4_state_offset + state_width - 1]),
      .din(ex4_state_d[0:state_width - 1]),
      .dout(ex4_state_q[0:state_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(pid_width), .INIT(0), .NEEDS_SRESET(1)) ex4_pid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_pid_offset:ex4_pid_offset + pid_width - 1]),
      .scout(sov_0[ex4_pid_offset:ex4_pid_offset + pid_width - 1]),
      .din(ex4_pid_d),
      .dout(ex4_pid_q)
   );

   tri_rlmreg_p #(.WIDTH(extclass_width), .INIT(0), .NEEDS_SRESET(1)) ex4_extclass_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_extclass_offset:ex4_extclass_offset + extclass_width - 1]),
      .scout(sov_0[ex4_extclass_offset:ex4_extclass_offset + extclass_width - 1]),
      .din(ex4_extclass_d[0:extclass_width - 1]),
      .dout(ex4_extclass_q[0:extclass_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(tlbsel_width), .INIT(0), .NEEDS_SRESET(1)) ex4_tlbsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_tlbsel_offset:ex4_tlbsel_offset + tlbsel_width - 1]),
      .scout(sov_0[ex4_tlbsel_offset:ex4_tlbsel_offset + tlbsel_width - 1]),
      .din(ex4_tlbsel_d[0:tlbsel_width - 1]),
      .dout(ex4_tlbsel_q[0:tlbsel_width - 1])
   );
   //------------------------------------------------

   tri_rlmreg_p #(.WIDTH(data_out_width), .INIT(0), .NEEDS_SRESET(1)) ex4_data_out_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_data_out_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_data_out_offset:ex4_data_out_offset + data_out_width - 1]),
      .scout(sov_0[ex4_data_out_offset:ex4_data_out_offset + data_out_width - 1]),
      .din(ex4_data_out_d[64 - data_out_width:63]),
      .dout(ex4_data_out_q[64 - data_out_width:63])
   );
   //-----------------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_valid_offset:ex5_valid_offset + `THREADS - 1]),
      .scout(sov_0[ex5_valid_offset:ex5_valid_offset + `THREADS - 1]),
      .din(ex5_valid_d[0:`THREADS - 1]),
      .dout(ex5_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(ttype_width), .INIT(0), .NEEDS_SRESET(1)) ex5_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_ttype_offset:ex5_ttype_offset + ttype_width - 1]),
      .scout(sov_0[ex5_ttype_offset:ex5_ttype_offset + ttype_width - 1]),
      .din(ex5_ttype_d[0:ttype_width - 1]),
      .dout(ex5_ttype_q[0:ttype_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ws_width), .INIT(0), .NEEDS_SRESET(1)) ex5_ws_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_ws_offset:ex5_ws_offset + ws_width - 1]),
      .scout(sov_0[ex5_ws_offset:ex5_ws_offset + ws_width - 1]),
      .din(ex5_ws_d[0:ws_width - 1]),
      .dout(ex5_ws_q[0:ws_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ra_entry_width), .INIT(0), .NEEDS_SRESET(1)) ex5_ra_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_ra_entry_offset:ex5_ra_entry_offset + ra_entry_width - 1]),
      .scout(sov_0[ex5_ra_entry_offset:ex5_ra_entry_offset + ra_entry_width - 1]),
      .din(ex5_ra_entry_d[0:ra_entry_width - 1]),
      .dout(ex5_ra_entry_q[0:ra_entry_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(state_width), .INIT(0), .NEEDS_SRESET(1)) ex5_state_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_state_offset:ex5_state_offset + state_width - 1]),
      .scout(sov_0[ex5_state_offset:ex5_state_offset + state_width - 1]),
      .din(ex5_state_d[0:state_width - 1]),
      .dout(ex5_state_q[0:state_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(pid_width), .INIT(0), .NEEDS_SRESET(1)) ex5_pid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_pid_offset:ex5_pid_offset + pid_width - 1]),
      .scout(sov_0[ex5_pid_offset:ex5_pid_offset + pid_width - 1]),
      .din(ex5_pid_d),
      .dout(ex5_pid_q)
   );

   tri_rlmreg_p #(.WIDTH(extclass_width), .INIT(0), .NEEDS_SRESET(1)) ex5_extclass_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_extclass_offset:ex5_extclass_offset + extclass_width - 1]),
      .scout(sov_0[ex5_extclass_offset:ex5_extclass_offset + extclass_width - 1]),
      .din(ex5_extclass_d[0:extclass_width - 1]),
      .dout(ex5_extclass_q[0:extclass_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(tlbsel_width), .INIT(0), .NEEDS_SRESET(1)) ex5_tlbsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_tlbsel_offset:ex5_tlbsel_offset + tlbsel_width - 1]),
      .scout(sov_0[ex5_tlbsel_offset:ex5_tlbsel_offset + tlbsel_width - 1]),
      .din(ex5_tlbsel_d[0:tlbsel_width - 1]),
      .dout(ex5_tlbsel_q[0:tlbsel_width - 1])
   );
   //------------------------------------------------

   tri_rlmreg_p #(.WIDTH(rs_data_width), .INIT(0), .NEEDS_SRESET(1)) ex5_data_in_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex4_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_data_in_offset:ex5_data_in_offset + rs_data_width - 1]),
      .scout(sov_0[ex5_data_in_offset:ex5_data_in_offset + rs_data_width - 1]),
      .din(ex5_data_in_d[64 - rs_data_width:63]),
      .dout(ex5_data_in_q[64 - rs_data_width:63])
   );
   //-----------------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex6_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_valid_offset:ex6_valid_offset + `THREADS - 1]),
      .scout(sov_0[ex6_valid_offset:ex6_valid_offset + `THREADS - 1]),
      .din(ex6_valid_d[0:`THREADS - 1]),
      .dout(ex6_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(ttype_width), .INIT(0), .NEEDS_SRESET(1)) ex6_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_ttype_offset:ex6_ttype_offset + ttype_width - 1]),
      .scout(sov_0[ex6_ttype_offset:ex6_ttype_offset + ttype_width - 1]),
      .din(ex6_ttype_d[0:ttype_width - 1]),
      .dout(ex6_ttype_q[0:ttype_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ws_width), .INIT(0), .NEEDS_SRESET(1)) ex6_ws_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_ws_offset:ex6_ws_offset + ws_width - 1]),
      .scout(sov_0[ex6_ws_offset:ex6_ws_offset + ws_width - 1]),
      .din(ex6_ws_d[0:ws_width - 1]),
      .dout(ex6_ws_q[0:ws_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(ra_entry_width), .INIT(0), .NEEDS_SRESET(1)) ex6_ra_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_ra_entry_offset:ex6_ra_entry_offset + ra_entry_width - 1]),
      .scout(sov_0[ex6_ra_entry_offset:ex6_ra_entry_offset + ra_entry_width - 1]),
      .din(ex6_ra_entry_d[0:ra_entry_width - 1]),
      .dout(ex6_ra_entry_q[0:ra_entry_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(state_width), .INIT(0), .NEEDS_SRESET(1)) ex6_state_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_state_offset:ex6_state_offset + state_width - 1]),
      .scout(sov_0[ex6_state_offset:ex6_state_offset + state_width - 1]),
      .din(ex6_state_d[0:state_width - 1]),
      .dout(ex6_state_q[0:state_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(pid_width), .INIT(0), .NEEDS_SRESET(1)) ex6_pid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_pid_offset:ex6_pid_offset + pid_width - 1]),
      .scout(sov_0[ex6_pid_offset:ex6_pid_offset + pid_width - 1]),
      .din(ex6_pid_d),
      .dout(ex6_pid_q)
   );

   tri_rlmreg_p #(.WIDTH(extclass_width), .INIT(0), .NEEDS_SRESET(1)) ex6_extclass_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_extclass_offset:ex6_extclass_offset + extclass_width - 1]),
      .scout(sov_0[ex6_extclass_offset:ex6_extclass_offset + extclass_width - 1]),
      .din(ex6_extclass_d[0:extclass_width - 1]),
      .dout(ex6_extclass_q[0:extclass_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(tlbsel_width), .INIT(0), .NEEDS_SRESET(1)) ex6_tlbsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_tlbsel_offset:ex6_tlbsel_offset + tlbsel_width - 1]),
      .scout(sov_0[ex6_tlbsel_offset:ex6_tlbsel_offset + tlbsel_width - 1]),
      .din(ex6_tlbsel_d[0:tlbsel_width - 1]),
      .dout(ex6_tlbsel_q[0:tlbsel_width - 1])
   );

   //------------------------------------------------

   tri_rlmreg_p #(.WIDTH(rs_data_width), .INIT(0), .NEEDS_SRESET(1)) ex6_data_in_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_data_in_offset:ex6_data_in_offset + rs_data_width - 1]),
      .scout(sov_0[ex6_data_in_offset:ex6_data_in_offset + rs_data_width - 1]),
      .din(ex6_data_in_d[64 - rs_data_width:63]),
      .dout(ex6_data_in_q[64 - rs_data_width:63])
   );

   //------------------------------------------------

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex7_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex7_valid_offset:ex7_valid_offset + `THREADS - 1]),
      .scout(sov_1[ex7_valid_offset:ex7_valid_offset + `THREADS - 1]),
      .din(ex7_valid_d[0:`THREADS - 1]),
      .dout(ex7_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(ttype_width), .INIT(0), .NEEDS_SRESET(1)) ex7_ttype_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex7_ttype_offset:ex7_ttype_offset + ttype_width - 1]),
      .scout(sov_1[ex7_ttype_offset:ex7_ttype_offset + ttype_width - 1]),
      .din(ex7_ttype_d[0:ttype_width - 1]),
      .dout(ex7_ttype_q[0:ttype_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(tlbsel_width), .INIT(0), .NEEDS_SRESET(1)) ex7_tlbsel_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex7_tlbsel_offset:ex7_tlbsel_offset + tlbsel_width - 1]),
      .scout(sov_1[ex7_tlbsel_offset:ex7_tlbsel_offset + tlbsel_width - 1]),
      .din(ex7_tlbsel_d[0:tlbsel_width - 1]),
      .dout(ex7_tlbsel_q[0:tlbsel_width - 1])
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu1_flush_enab_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu1_flush_enab_offset]),
      .scout(sov_0[iu1_flush_enab_offset]),
      .din(iu1_flush_enab_d),
      .dout(iu1_flush_enab_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) iu2_n_flush_req_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu1_or_iu2_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_n_flush_req_offset:iu2_n_flush_req_offset + `THREADS - 1]),
      .scout(sov_0[iu2_n_flush_req_offset:iu2_n_flush_req_offset + `THREADS - 1]),
      .din(iu2_n_flush_req_d[0:`THREADS - 1]),
      .dout(iu2_n_flush_req_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(1), .NEEDS_SRESET(1)) hold_req_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(not_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[hold_req_offset:hold_req_offset + `THREADS - 1]),
      .scout(sov_0[hold_req_offset:hold_req_offset + `THREADS - 1]),
      .din(hold_req_d[0:`THREADS - 1]),
      .dout(hold_req_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_miss_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_miss_offset:tlb_miss_offset + `THREADS - 1]),
      .scout(sov_0[tlb_miss_offset:tlb_miss_offset + `THREADS - 1]),
      .din(tlb_miss_d[0:`THREADS - 1]),
      .dout(tlb_miss_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_flushed_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_flushed_offset:tlb_flushed_offset + `THREADS - 1]),
      .scout(sov_0[tlb_flushed_offset:tlb_flushed_offset + `THREADS - 1]),
      .din(tlb_flushed_d[0:`THREADS - 1]),
      .dout(tlb_flushed_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_req_inprogress_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[tlb_req_inprogress_offset:tlb_req_inprogress_offset + `THREADS - 1]),
      .scout(sov_0[tlb_req_inprogress_offset:tlb_req_inprogress_offset + `THREADS - 1]),
      .din(tlb_req_inprogress_d[0:`THREADS - 1]),
      .dout(tlb_req_inprogress_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) iu1_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu1_valid_offset:iu1_valid_offset + `THREADS - 1]),
      .scout(sov_0[iu1_valid_offset:iu1_valid_offset + `THREADS - 1]),
      .din(iu1_valid_d[0:`THREADS - 1]),
      .dout(iu1_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(state_width), .INIT(0), .NEEDS_SRESET(1)) iu1_state_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu1_state_offset:iu1_state_offset + state_width - 1]),
      .scout(sov_0[iu1_state_offset:iu1_state_offset + state_width - 1]),
      .din(iu1_state_d[0:state_width - 1]),
      .dout(iu1_state_q[0:state_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(pid_width), .INIT(0), .NEEDS_SRESET(1)) iu1_pid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu1_pid_offset:iu1_pid_offset + pid_width - 1]),
      .scout(sov_0[iu1_pid_offset:iu1_pid_offset + pid_width - 1]),
      .din(iu1_pid_d),
      .dout(iu1_pid_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu1_nonspec_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu1_nonspec_offset]),
      .scout(sov_0[iu1_nonspec_offset]),
      .din(iu1_nonspec_d),
      .dout(iu1_nonspec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu1_prefetch_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu1_prefetch_offset]),
      .scout(sov_0[iu1_prefetch_offset]),
      .din(iu1_prefetch_d),
      .dout(iu1_prefetch_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) iu2_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_valid_offset:iu2_valid_offset + `THREADS - 1]),
      .scout(sov_0[iu2_valid_offset:iu2_valid_offset + `THREADS - 1]),
      .din(iu2_valid_d[0:`THREADS - 1]),
      .dout(iu2_valid_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) iu2_perf_itlb_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_perf_itlb_offset:iu2_perf_itlb_offset + `THREADS - 1]),
      .scout(sov_0[iu2_perf_itlb_offset:iu2_perf_itlb_offset + `THREADS - 1]),
      .din(iu2_perf_itlb_d[0:`THREADS - 1]),
      .dout(iu2_perf_itlb_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(state_width), .INIT(0), .NEEDS_SRESET(1)) iu2_state_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu1_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_state_offset:iu2_state_offset + state_width - 1]),
      .scout(sov_0[iu2_state_offset:iu2_state_offset + state_width - 1]),
      .din(iu2_state_d[0:state_width - 1]),
      .dout(iu2_state_q[0:state_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(pid_width), .INIT(0), .NEEDS_SRESET(1)) iu2_pid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu1_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_pid_offset:iu2_pid_offset + pid_width - 1]),
      .scout(sov_0[iu2_pid_offset:iu2_pid_offset + pid_width - 1]),
      .din(iu2_pid_d),
      .dout(iu2_pid_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu2_nonspec_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_nonspec_offset]),
      .scout(sov_0[iu2_nonspec_offset]),
      .din(iu2_nonspec_d),
      .dout(iu2_nonspec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu2_prefetch_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_prefetch_offset]),
      .scout(sov_0[iu2_prefetch_offset]),
      .din(iu2_prefetch_d),
      .dout(iu2_prefetch_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) iu2_miss_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu1_or_iu2_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_miss_offset:iu2_miss_offset + 2 - 1]),
      .scout(sov_0[iu2_miss_offset:iu2_miss_offset + 2 - 1]),
      .din(iu2_miss_d),
      .dout(iu2_miss_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) iu2_multihit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu1_or_iu2_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_multihit_offset:iu2_multihit_offset + 2 - 1]),
      .scout(sov_0[iu2_multihit_offset:iu2_multihit_offset + 2 - 1]),
      .din(iu2_multihit_d),
      .dout(iu2_multihit_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) iu2_parerr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu1_or_iu2_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_parerr_offset:iu2_parerr_offset + 2 - 1]),
      .scout(sov_0[iu2_parerr_offset:iu2_parerr_offset + 2 - 1]),
      .din(iu2_parerr_d),
      .dout(iu2_parerr_q)
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) iu2_isi_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(not_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_isi_offset:iu2_isi_offset + 6 - 1]),
      .scout(sov_0[iu2_isi_offset:iu2_isi_offset + 6 - 1]),
      .din(iu2_isi_d),
      .dout(iu2_isi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu2_tlbreq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(notlb_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_tlbreq_offset]),
      .scout(sov_0[iu2_tlbreq_offset]),
      .din(iu2_tlbreq_d),
      .dout(iu2_tlbreq_q)
   );

   tri_rlmreg_p #(.WIDTH(num_entry), .INIT(0), .NEEDS_SRESET(1)) iu2_multihit_b_pt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu1_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_multihit_b_pt_offset:iu2_multihit_b_pt_offset + num_entry - 1]),
      .scout(sov_0[iu2_multihit_b_pt_offset:iu2_multihit_b_pt_offset + num_entry - 1]),
      .din(iu2_multihit_b_pt_d),
      .dout(iu2_multihit_b_pt_q)
   );

   tri_rlmreg_p #(.WIDTH(num_entry-1), .INIT(0), .NEEDS_SRESET(1)) iu2_first_hit_entry_pt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu1_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_first_hit_entry_pt_offset:iu2_first_hit_entry_pt_offset + (num_entry-1) - 1]),
      .scout(sov_0[iu2_first_hit_entry_pt_offset:iu2_first_hit_entry_pt_offset + (num_entry-1) - 1]),
      .din(iu2_first_hit_entry_pt_d),
      .dout(iu2_first_hit_entry_pt_q)
   );

   tri_rlmreg_p #(.WIDTH(cam_data_width), .INIT(0), .NEEDS_SRESET(1)) iu2_cam_cmp_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu1_cmp_data_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_cam_cmp_data_offset:iu2_cam_cmp_data_offset + cam_data_width - 1]),
      .scout(sov_0[iu2_cam_cmp_data_offset:iu2_cam_cmp_data_offset + cam_data_width - 1]),
      .din(iu2_cam_cmp_data_d[0:cam_data_width - 1]),
      .dout(iu2_cam_cmp_data_q[0:cam_data_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(array_data_width), .INIT(0), .NEEDS_SRESET(1)) iu2_array_cmp_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu1_cmp_data_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu2_array_cmp_data_offset:iu2_array_cmp_data_offset + array_data_width - 1]),
      .scout(sov_0[iu2_array_cmp_data_offset:iu2_array_cmp_data_offset + array_data_width - 1]),
      .din(iu2_array_cmp_data_d[0:array_data_width - 1]),
      .dout(iu2_array_cmp_data_q[0:array_data_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(cam_data_width), .INIT(0), .NEEDS_SRESET(1)) ex4_rd_cam_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_rd_data_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_rd_cam_data_offset:ex4_rd_cam_data_offset + cam_data_width - 1]),
      .scout(sov_0[ex4_rd_cam_data_offset:ex4_rd_cam_data_offset + cam_data_width - 1]),
      .din(ex4_rd_cam_data_d[0:cam_data_width - 1]),
      .dout(ex4_rd_cam_data_q[0:cam_data_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(array_data_width), .INIT(0), .NEEDS_SRESET(1)) ex4_rd_array_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex3_rd_data_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_rd_array_data_offset:ex4_rd_array_data_offset + array_data_width - 1]),
      .scout(sov_0[ex4_rd_array_data_offset:ex4_rd_array_data_offset + array_data_width - 1]),
      .din(ex4_rd_array_data_d[0:array_data_width - 1]),
      .dout(ex4_rd_array_data_q[0:array_data_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS+1), .INIT(0), .NEEDS_SRESET(1)) ex3_parerr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(not_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex3_parerr_offset:ex3_parerr_offset + (`THREADS+1) - 1]),
      .scout(sov_0[ex3_parerr_offset:ex3_parerr_offset + (`THREADS+1) - 1]),
      .din(ex3_parerr_d),
      .dout(ex3_parerr_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS+3), .INIT(0), .NEEDS_SRESET(1)) ex4_parerr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_parerr_offset:ex4_parerr_offset + (`THREADS+3) - 1]),
      .scout(sov_0[ex4_parerr_offset:ex4_parerr_offset + (`THREADS+3) - 1]),
      .din(ex4_parerr_d),
      .dout(ex4_parerr_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS+num_entry_log2), .INIT(0), .NEEDS_SRESET(1)) ex4_ieen_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex4_ieen_offset:ex4_ieen_offset + `THREADS+num_entry_log2 - 1]),
      .scout(sov_0[ex4_ieen_offset:ex4_ieen_offset + `THREADS+num_entry_log2 - 1]),
      .din(ex4_ieen_d[0:`THREADS+num_entry_log2 - 1]),
      .dout(ex4_ieen_q[0:`THREADS+num_entry_log2 - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS+num_entry_log2), .INIT(0), .NEEDS_SRESET(1)) ex5_ieen_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex5_ieen_offset:ex5_ieen_offset + `THREADS+num_entry_log2 - 1]),
      .scout(sov_0[ex5_ieen_offset:ex5_ieen_offset + `THREADS+num_entry_log2 - 1]),
      .din(ex5_ieen_d[0:`THREADS+num_entry_log2 - 1]),
      .dout(ex5_ieen_q[0:`THREADS+num_entry_log2 - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS+num_entry_log2), .INIT(0), .NEEDS_SRESET(1)) ex6_ieen_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[ex6_ieen_offset:ex6_ieen_offset + `THREADS+num_entry_log2 - 1]),
      .scout(sov_0[ex6_ieen_offset:ex6_ieen_offset + `THREADS+num_entry_log2 - 1]),
      .din(ex6_ieen_d[0:`THREADS+num_entry_log2 - 1]),
      .dout(ex6_ieen_q[0:`THREADS+num_entry_log2 - 1])
   );

   tri_rlmreg_p #(.WIDTH(9), .INIT(0), .NEEDS_SRESET(1)) mmucr1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[mmucr1_offset:mmucr1_offset + 9 - 1]),
      .scout(sov_0[mmucr1_offset:mmucr1_offset + 9 - 1]),
      .din(mmucr1_d),
      .dout(mmucr1_q)
   );

   generate
   begin : xhdl4
     genvar  tid;
     for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
     begin : rpn_holdreg
       tri_rlmreg_p #(.WIDTH(64), .INIT(0), .NEEDS_SRESET(1)) rpn_holdreg_latch(
          .vd(vdd),
          .gd(gnd),
          .nclk(nclk),
          .act(ex6_stg_act_q),
          .thold_b(pc_func_slp_sl_thold_0_b),
          .sg(pc_sg_0),
          .force_t(pc_func_slp_sl_force),
          .delay_lclkr(lcb_delay_lclkr_dc[0]),
          .mpw1_b(lcb_mpw1_dc_b[0]),
          .mpw2_b(lcb_mpw2_dc_b),
          .d_mode(lcb_d_mode_dc),
          .scin(siv_0[rpn_holdreg_offset + (64 * tid):rpn_holdreg_offset + (64 * (tid + 1)) - 1]),
          .scout(sov_0[rpn_holdreg_offset + (64 * tid):rpn_holdreg_offset + (64 * (tid + 1)) - 1]),
          .din(rpn_holdreg_d[tid][0:63]),
          .dout(rpn_holdreg_q[tid][0:63])
       );
     end
   end
   endgenerate

   tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) entry_valid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(entry_valid_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[entry_valid_offset:entry_valid_offset + 16 - 1]),
      .scout(sov_0[entry_valid_offset:entry_valid_offset + 16 - 1]),
      .din(entry_valid),
      .dout(entry_valid_q)
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) entry_match_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(entry_match_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[entry_match_offset:entry_match_offset + 16 - 1]),
      .scout(sov_0[entry_match_offset:entry_match_offset + 16 - 1]),
      .din(entry_match),
      .dout(entry_match_q)
   );

   tri_rlmreg_p #(.WIDTH(watermark_width), .INIT(13), .NEEDS_SRESET(1)) watermark_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex6_stg_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[watermark_offset:watermark_offset + watermark_width - 1]),
      .scout(sov_0[watermark_offset:watermark_offset + watermark_width - 1]),
      .din(watermark_d[0:watermark_width - 1]),
      .dout(watermark_q[0:watermark_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(eptr_width), .INIT(0), .NEEDS_SRESET(1)) eptr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(mmucr1_q[0]),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[eptr_offset:eptr_offset + eptr_width - 1]),
      .scout(sov_0[eptr_offset:eptr_offset + eptr_width - 1]),
      .din(eptr_d[0:eptr_width - 1]),
      .dout(eptr_q[0:eptr_width - 1])
   );

   tri_rlmreg_p #(.WIDTH(lru_width), .INIT(0), .NEEDS_SRESET(1)) lru_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(lru_update_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[lru_offset:lru_offset + lru_width - 1]),
      .scout(sov_0[lru_offset:lru_offset + lru_width - 1]),
      .din(lru_d[1:lru_width]),
      .dout(lru_q[1:lru_width])
   );

   tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) lru_update_event_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(not_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[lru_update_event_offset:lru_update_event_offset + 10 - 1]),
      .scout(sov_0[lru_update_event_offset:lru_update_event_offset + 10 - 1]),
      .din(lru_update_event_d),
      .dout(lru_update_event_q)
   );

   tri_rlmreg_p #(.WIDTH(24), .INIT(0), .NEEDS_SRESET(1)) lru_debug_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(debug_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[lru_debug_offset:lru_debug_offset + 24 - 1]),
      .scout(sov_0[lru_debug_offset:lru_debug_offset + 24 - 1]),
      .din(lru_debug_d),
      .dout(lru_debug_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_xu_ord_write_done_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu_xu_ord_write_done_offset]),
      .scout(sov_0[iu_xu_ord_write_done_offset]),
      .din(iu_xu_ord_write_done_d),
      .dout(iu_xu_ord_write_done_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_xu_ord_read_done_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu_xu_ord_read_done_offset]),
      .scout(sov_0[iu_xu_ord_read_done_offset]),
      .din(iu_xu_ord_read_done_d),
      .dout(iu_xu_ord_read_done_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_xu_ord_par_err_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[iu_xu_ord_par_err_offset]),
      .scout(sov_0[iu_xu_ord_par_err_offset]),
      .din(iu_xu_ord_par_err_d),
      .dout(iu_xu_ord_par_err_q)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) cp_ic_csinv_comp_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_0[cp_ic_csinv_comp_offset:cp_ic_csinv_comp_offset + 4 - 1]),
      .scout(sov_0[cp_ic_csinv_comp_offset:cp_ic_csinv_comp_offset + 4 - 1]),
      .din(cp_ic_csinv_comp_d),
      .dout(cp_ic_csinv_comp_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) snoop_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),     // keep this as tiup, bit(1) is I$ backinv
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[snoop_val_offset:snoop_val_offset + 3 - 1]),
      .scout(sov_1[snoop_val_offset:snoop_val_offset + 3 - 1]),
      .din(snoop_val_d),
      .dout(snoop_val_q)
   );

   tri_rlmreg_p #(.WIDTH(26), .INIT(0), .NEEDS_SRESET(1)) snoop_attr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(snoop_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[snoop_attr_offset:snoop_attr_offset + 26 - 1]),
      .scout(sov_1[snoop_attr_offset:snoop_attr_offset + 26 - 1]),
      .din(snoop_attr_d),
      .dout(snoop_attr_q)
   );

   tri_rlmreg_p #(.WIDTH(epn_width), .INIT(0), .NEEDS_SRESET(1)) snoop_addr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(snoop_act_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[snoop_addr_offset:snoop_addr_offset + epn_width - 1]),
      .scout(sov_1[snoop_addr_offset:snoop_addr_offset + epn_width - 1]),
      .din(snoop_addr_d[52 - epn_width:51]),
      .dout(snoop_addr_q[52 - epn_width:51])
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) por_seq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[por_seq_offset:por_seq_offset + 3 - 1]),
      .scout(sov_1[por_seq_offset:por_seq_offset + 3 - 1]),
      .din(por_seq_d[0:por_seq_width - 1]),
      .dout(por_seq_q[0:por_seq_width - 1])
   );

   // timing latches for reloads
   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) tlb_rel_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[tlb_rel_val_offset:tlb_rel_val_offset + 5 - 1]),
      .scout(sov_1[tlb_rel_val_offset:tlb_rel_val_offset + 5 - 1]),
      .din(tlb_rel_val_d),
      .dout(tlb_rel_val_q)
   );

   tri_rlmreg_p #(.WIDTH(132), .INIT(0), .NEEDS_SRESET(1)) tlb_rel_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tlb_rel_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[tlb_rel_data_offset:tlb_rel_data_offset + 132 - 1]),
      .scout(sov_1[tlb_rel_data_offset:tlb_rel_data_offset + 132 - 1]),
      .din(tlb_rel_data_d),
      .dout(tlb_rel_data_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) iu_mm_ierat_flush_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[iu_mm_ierat_flush_offset:iu_mm_ierat_flush_offset + `THREADS - 1]),
      .scout(sov_1[iu_mm_ierat_flush_offset:iu_mm_ierat_flush_offset + `THREADS - 1]),
      .din(iu_mm_ierat_flush_d[0:`THREADS - 1]),
      .dout(iu_mm_ierat_flush_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) iu_xu_ierat_ex2_flush_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[iu_xu_ierat_ex2_flush_offset:iu_xu_ierat_ex2_flush_offset + `THREADS - 1]),
      .scout(sov_1[iu_xu_ierat_ex2_flush_offset:iu_xu_ierat_ex2_flush_offset + `THREADS - 1]),
      .din(iu_xu_ierat_ex2_flush_d[0:`THREADS - 1]),
      .dout(iu_xu_ierat_ex2_flush_q[0:`THREADS - 1])
   );

   tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) ccr2_frat_paranoia_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ccr2_frat_paranoia_offset:ccr2_frat_paranoia_offset + 10 - 1]),
      .scout(sov_1[ccr2_frat_paranoia_offset:ccr2_frat_paranoia_offset + 10 - 1]),
      .din(ccr2_frat_paranoia_d),
      .dout(ccr2_frat_paranoia_q)
   );

   tri_rlmlatch_p #(.INIT(1), .NEEDS_SRESET(1)) ccr2_notlb_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ccr2_notlb_offset]),
      .scout(sov_1[ccr2_notlb_offset]),
      .din(xu_iu_hid_mmu_mode),
      .dout(ccr2_notlb_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) mchk_flash_inv_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(iu2_or_iu3_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[mchk_flash_inv_offset:mchk_flash_inv_offset + 4 - 1]),
      .scout(sov_1[mchk_flash_inv_offset:mchk_flash_inv_offset + 4 - 1]),
      .din(mchk_flash_inv_d),
      .dout(mchk_flash_inv_q)
   );

   tri_rlmlatch_p #(.INIT(1), .NEEDS_SRESET(1)) xucr4_mmu_mchk_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[xucr4_mmu_mchk_offset]),
      .scout(sov_1[xucr4_mmu_mchk_offset]),
      .din(xu_iu_xucr4_mmu_mchk),
      .dout(xucr4_mmu_mchk_q)
   );

   tri_rlmreg_p #(.WIDTH(11), .INIT(0), .NEEDS_SRESET(1)) iu1_debug_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(trace_bus_enable_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[iu1_debug_offset:iu1_debug_offset + 11 - 1]),
      .scout(sov_1[iu1_debug_offset:iu1_debug_offset + 11 - 1]),
      .din(iu1_debug_d),
      .dout(iu1_debug_q)
   );

   tri_rlmreg_p #(.WIDTH(17), .INIT(0), .NEEDS_SRESET(1)) iu2_debug_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(debug_grffence_act),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[iu2_debug_offset:iu2_debug_offset + 17 - 1]),
      .scout(sov_1[iu2_debug_offset:iu2_debug_offset + 17 - 1]),
      .din(iu2_debug_d),
      .dout(iu2_debug_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu1_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[iu1_stg_act_offset]),
      .scout(sov_1[iu1_stg_act_offset]),
      .din(iu1_stg_act_d),
      .dout(iu1_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu2_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[iu2_stg_act_offset]),
      .scout(sov_1[iu2_stg_act_offset]),
      .din(iu2_stg_act_d),
      .dout(iu2_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu3_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[iu3_stg_act_offset]),
      .scout(sov_1[iu3_stg_act_offset]),
      .din(iu3_stg_act_d),
      .dout(iu3_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex1_stg_act_offset]),
      .scout(sov_1[ex1_stg_act_offset]),
      .din(ex1_stg_act_d),
      .dout(ex1_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex2_stg_act_offset]),
      .scout(sov_1[ex2_stg_act_offset]),
      .din(ex2_stg_act_d),
      .dout(ex2_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex3_stg_act_offset]),
      .scout(sov_1[ex3_stg_act_offset]),
      .din(ex3_stg_act_d),
      .dout(ex3_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex4_stg_act_offset]),
      .scout(sov_1[ex4_stg_act_offset]),
      .din(ex4_stg_act_d),
      .dout(ex4_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex5_stg_act_offset]),
      .scout(sov_1[ex5_stg_act_offset]),
      .din(ex5_stg_act_d),
      .dout(ex5_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex6_stg_act_offset]),
      .scout(sov_1[ex6_stg_act_offset]),
      .din(ex6_stg_act_d),
      .dout(ex6_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex7_stg_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[ex7_stg_act_offset]),
      .scout(sov_1[ex7_stg_act_offset]),
      .din(ex7_stg_act_d),
      .dout(ex7_stg_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_rel_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[tlb_rel_act_offset]),
      .scout(sov_1[tlb_rel_act_offset]),
      .din(tlb_rel_act_d),
      .dout(tlb_rel_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) snoop_act_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[snoop_act_offset]),
      .scout(sov_1[snoop_act_offset]),
      .din(mm_iu_ierat_snoop_coming),
      .dout(snoop_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_pc_err_ierat_multihit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[iu_pc_err_ierat_multihit_offset]),
      .scout(sov_1[iu_pc_err_ierat_multihit_offset]),
      .din(iu_pc_err_ierat_multihit_d),
      .dout(iu_pc_err_ierat_multihit_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_pc_err_ierat_parity_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[iu_pc_err_ierat_parity_offset]),
      .scout(sov_1[iu_pc_err_ierat_parity_offset]),
      .din(iu_pc_err_ierat_parity_d),
      .dout(iu_pc_err_ierat_parity_q)
   );
   // for debug trace bus latch act

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) trace_bus_enable_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[trace_bus_enable_offset]),
      .scout(sov_1[trace_bus_enable_offset]),
      .din(pc_iu_trace_bus_enable),
      .dout(trace_bus_enable_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_grffence_en_dc_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[an_ac_grffence_en_dc_offset]),
      .scout(sov_1[an_ac_grffence_en_dc_offset]),
      .din(an_ac_grffence_en_dc_q),
      .dout(an_ac_grffence_en_dc_q)
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) spare_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spare_a_offset:spare_a_offset + 15]),
      .scout(sov_1[spare_a_offset:spare_a_offset + 15]),
      .din(spare_q[0:15]),
      .dout(spare_q[0:15])
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) spare_b_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .mpw1_b(lcb_mpw1_dc_b[0]),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv_1[spare_b_offset:spare_b_offset + 15]),
      .scout(sov_1[spare_b_offset:spare_b_offset + 15]),
      .din(spare_q[16:31]),
      .dout(spare_q[16:31])
   );


   //------------------------------------------------
   // scan only latches for boot config
   //------------------------------------------------

   //     epn                                                                  rpn                                   u0:3 E
   //         0                                    31 32                    51 52 54     61 62                    81     86
   //         0                                    31 32                    51 22 24     31 32                    51
   //init => "0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111_1111_11_1111_1111_1111_1111_1111_1111_1111_0000_0",

   tri_slat_scan #(.WIDTH(16), .INIT(`IERAT_BCFG_EPN_0TO15), .RESET_INVERTS_SCAN(1'b1)) bcfg_epn_0to15_latch(
      .vd(vdd),
      .gd(gnd),
      .dclk(lcb_dclk),
      .lclk(lcb_lclk),
      .scan_in(bsiv[bcfg_offset:bcfg_offset + 15]),
      .scan_out(bsov[bcfg_offset:bcfg_offset + 15]),
      .q(bcfg_q[0:15]),
      .q_b(bcfg_q_b[0:15])
   );

   tri_slat_scan #(.WIDTH(16), .INIT(`IERAT_BCFG_EPN_16TO31), .RESET_INVERTS_SCAN(1'b1)) bcfg_epn_16to31_latch(
      .vd(vdd),
      .gd(gnd),
      .dclk(lcb_dclk),
      .lclk(lcb_lclk),
      .scan_in(bsiv[bcfg_offset + 16:bcfg_offset + 31]),
      .scan_out(bsov[bcfg_offset + 16:bcfg_offset + 31]),
      .q(bcfg_q[16:31]),
      .q_b(bcfg_q_b[16:31])
   );

   tri_slat_scan #(.WIDTH(16), .INIT(`IERAT_BCFG_EPN_32TO47), .RESET_INVERTS_SCAN(1'b1)) bcfg_epn_32to47_latch(
      .vd(vdd),
      .gd(gnd),
      .dclk(lcb_dclk),
      .lclk(lcb_lclk),
      .scan_in(bsiv[bcfg_offset + 32:bcfg_offset + 47]),
      .scan_out(bsov[bcfg_offset + 32:bcfg_offset + 47]),
      .q(bcfg_q[32:47]),
      .q_b(bcfg_q_b[32:47])
   );

   tri_slat_scan #(.WIDTH(4), .INIT(`IERAT_BCFG_EPN_48TO51), .RESET_INVERTS_SCAN(1'b1)) bcfg_epn_48to51_latch(
      .vd(vdd),
      .gd(gnd),
      .dclk(lcb_dclk),
      .lclk(lcb_lclk),
      .scan_in(bsiv[bcfg_offset + 48:bcfg_offset + 51]),
      .scan_out(bsov[bcfg_offset + 48:bcfg_offset + 51]),
      .q(bcfg_q[48:51]),
      .q_b(bcfg_q_b[48:51])
   );

   tri_slat_scan #(.WIDTH(10), .INIT(`IERAT_BCFG_RPN_22TO31), .RESET_INVERTS_SCAN(1'b1)) bcfg_rpn_22to31_latch(
      .vd(vdd),
      .gd(gnd),
      .dclk(lcb_dclk),
      .lclk(lcb_lclk),
      .scan_in(bsiv[bcfg_offset + 52:bcfg_offset + 61]),
      .scan_out(bsov[bcfg_offset + 52:bcfg_offset + 61]),
      .q(bcfg_q[52:61]),
      .q_b(bcfg_q_b[52:61])
   );

   tri_slat_scan #(.WIDTH(16), .INIT(`IERAT_BCFG_RPN_32TO47), .RESET_INVERTS_SCAN(1'b1)) bcfg_rpn_32to47_latch(
      .vd(vdd),
      .gd(gnd),
      .dclk(lcb_dclk),
      .lclk(lcb_lclk),
      .scan_in(bsiv[bcfg_offset + 62:bcfg_offset + 77]),
      .scan_out(bsov[bcfg_offset + 62:bcfg_offset + 77]),
      .q(bcfg_q[62:77]),
      .q_b(bcfg_q_b[62:77])
   );

   tri_slat_scan #(.WIDTH(4), .INIT(`IERAT_BCFG_RPN_48TO51), .RESET_INVERTS_SCAN(1'b1)) bcfg_rpn_48to51_latch(
      .vd(vdd),
      .gd(gnd),
      .dclk(lcb_dclk),
      .lclk(lcb_lclk),
      .scan_in(bsiv[bcfg_offset + 78:bcfg_offset + 81]),
      .scan_out(bsov[bcfg_offset + 78:bcfg_offset + 81]),
      .q(bcfg_q[78:81]),
      .q_b(bcfg_q_b[78:81])
   );

   tri_slat_scan #(.WIDTH(5), .INIT(`IERAT_BCFG_ATTR), .RESET_INVERTS_SCAN(1'b1)) bcfg_attr_latch(
      .vd(vdd),
      .gd(gnd),
      .dclk(lcb_dclk),
      .lclk(lcb_lclk),
      .scan_in(bsiv[bcfg_offset + 82:bcfg_offset + 86]),
      .scan_out(bsov[bcfg_offset + 82:bcfg_offset + 86]),
      .q(bcfg_q[82:86]),
      .q_b(bcfg_q_b[82:86])
   );

   tri_slat_scan #(.WIDTH(16), .INIT(`IERAT_BCFG_RPN2_32TO47), .RESET_INVERTS_SCAN(1'b1)) bcfg_rpn2_32to47_latch(
      .vd(vdd),
      .gd(gnd),
      .dclk(lcb_dclk),
      .lclk(lcb_lclk),
      .scan_in(bsiv[bcfg_offset + 87:bcfg_offset + 102]),
      .scan_out(bsov[bcfg_offset + 87:bcfg_offset + 102]),
      .q(bcfg_q[87:102]),
      .q_b(bcfg_q_b[87:102])
   );

   tri_slat_scan #(.WIDTH(4), .INIT(`IERAT_BCFG_RPN2_48TO51), .RESET_INVERTS_SCAN(1'b1)) bcfg_rpn2_48to51_latch(
      .vd(vdd),
      .gd(gnd),
      .dclk(lcb_dclk),
      .lclk(lcb_lclk),
      .scan_in(bsiv[bcfg_offset + 103:bcfg_offset + 106]),
      .scan_out(bsov[bcfg_offset + 103:bcfg_offset + 106]),
      .q(bcfg_q[103:106]),
      .q_b(bcfg_q_b[103:106])
   );

   tri_slat_scan #(.WIDTH(16), .INIT(0), .RESET_INVERTS_SCAN(1'b1)) bcfg_spare_latch(
      .vd(vdd),
      .gd(gnd),
      .dclk(lcb_dclk),
      .lclk(lcb_lclk),
      .scan_in(bsiv[bcfg_offset + 107:bcfg_offset + 122]),
      .scan_out(bsov[bcfg_offset + 107:bcfg_offset + 122]),
      .q(bcfg_q[107:122]),
      .q_b(bcfg_q_b[107:122])
   );

   //------------------------------------------------
   // thold/sg latches
   //------------------------------------------------

   tri_plat #(.WIDTH(4)) perv_2to1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ccflush_dc),
      .din({pc_iu_func_sl_thold_2,
            pc_iu_func_slp_sl_thold_2,
            pc_iu_cfg_slp_sl_thold_2,
            pc_iu_sg_2}),
      .q({pc_func_sl_thold_1,
          pc_func_slp_sl_thold_1,
          pc_cfg_slp_sl_thold_1,
          pc_sg_1})
   );

   tri_plat #(.WIDTH(4)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ccflush_dc),
      .din({pc_func_sl_thold_1,
            pc_func_slp_sl_thold_1,
            pc_cfg_slp_sl_thold_1,
            pc_sg_1}),
      .q({pc_func_sl_thold_0,
          pc_func_slp_sl_thold_0,
          pc_cfg_slp_sl_thold_0,
          pc_sg_0})
   );

   tri_lcbor  perv_lcbor_func_sl(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(pc_func_sl_thold_0),
      .sg(pc_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(pc_func_sl_force),
      .thold_b(pc_func_sl_thold_0_b)
   );

   tri_lcbor  perv_lcbor_func_slp_sl(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(pc_func_slp_sl_thold_0),
      .sg(pc_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(pc_func_slp_sl_force),
      .thold_b(pc_func_slp_sl_thold_0_b)
   );

   //------------------------------------------------
   // local clock buffer for boot config
   //------------------------------------------------

   tri_lcbs  bcfg_lcb(
      .vd(vdd),
      .gd(gnd),
      .delay_lclkr(lcb_delay_lclkr_dc[0]),
      .nclk(nclk),
      .force_t(pc_cfg_slp_sl_force),
      .thold_b(pc_cfg_slp_sl_thold_0_b),
      .dclk(lcb_dclk),
      .lclk(lcb_lclk)
   );

   // these terms in the absence of another lcbor component
   //  that drives the thold_b and force into the bcfg_lcb for slat's
   assign pc_cfg_slp_sl_thold_0_b = (~pc_cfg_slp_sl_thold_0);
   assign pc_cfg_slp_sl_force = pc_sg_0;

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv_0[0:scan_right_0] = {sov_0[1:scan_right_0], ac_func_scan_in[0]};
   assign ac_func_scan_out[0] = sov_0[0];
   assign siv_1[0:scan_right_1] = {sov_1[1:scan_right_1], ac_func_scan_in[1]};
   assign ac_func_scan_out[1] = sov_1[0];
   assign bsiv[0:boot_scan_right] = {bsov[1:boot_scan_right], ac_ccfg_scan_in};
   assign ac_ccfg_scan_out = bsov[0];

endmodule
