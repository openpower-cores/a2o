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
//* TITLE: Memory Management Unit TLB Input Request Queue from ERATs
//* NAME: mmq_tlb_req.v
//*********************************************************************

`timescale 1 ns / 1 ns

`include "tri_a2o.vh"
`include "mmu_a2o.vh"
`define       REQ_STATE_WIDTH   4

module mmq_tlb_req(

   inout                                   vdd,
   inout                                   gnd,
    (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]                 nclk,

   input                       tc_ccflush_dc,
   input                       tc_scan_dis_dc_b,
   input                       tc_scan_diag_dc,
   input                       tc_lbist_en_dc,
   input                       lcb_d_mode_dc,
   input                       lcb_clkoff_dc_b,
   input                       lcb_act_dis_dc,
   input [0:4]                 lcb_mpw1_dc_b,
   input                       lcb_mpw2_dc_b,
   input [0:4]                 lcb_delay_lclkr_dc,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                       ac_func_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                      ac_func_scan_out,

   input                       pc_sg_2,
   input                       pc_func_sl_thold_2,
   input                       pc_func_slp_sl_thold_2,

   input                       xu_mm_ccr2_notlb_b,
   input                       mmucr2_act_override,
   input [0:`PID_WIDTH-1]       pid0,
`ifdef MM_THREADS2
   input [0:`PID_WIDTH-1]       pid1,
`endif
   input [0:`LPID_WIDTH-1]      lpidr,

   input                            iu_mm_ierat_req,
   input [0:51]                     iu_mm_ierat_epn,
   input [0:`THDID_WIDTH-1]         iu_mm_ierat_thdid,
   input [0:`REQ_STATE_WIDTH-1]     iu_mm_ierat_state,
   input [0:`PID_WIDTH-1]           iu_mm_ierat_tid,
   input [0:`THDID_WIDTH-1]         iu_mm_ierat_flush,
   input                            iu_mm_ierat_req_nonspec,

   input                            xu_mm_derat_req,
   input [64-`RS_DATA_WIDTH:51]     xu_mm_derat_epn,
   input [0:`THDID_WIDTH-1]         xu_mm_derat_thdid,
   input [0:1]                      xu_mm_derat_ttype,
   input [0:`REQ_STATE_WIDTH-1]     xu_mm_derat_state,
   input [0:`PID_WIDTH-1]           xu_mm_derat_tid,
   input [0:`LPID_WIDTH-1]          xu_mm_derat_lpid,

   input                           lq_mm_derat_req_nonspec,
   input [0:`ITAG_SIZE_ENC-1]      lq_mm_derat_req_itag,
   input [0:`EMQ_ENTRIES-1]        lq_mm_derat_req_emq,

   output [0:`PID_WIDTH-1]      ierat_req0_pid,
   output                       ierat_req0_as,
   output                       ierat_req0_gs,
   output [0:`EPN_WIDTH-1]      ierat_req0_epn,
   output [0:`THDID_WIDTH-1]    ierat_req0_thdid,
   output                       ierat_req0_valid,
   output                       ierat_req0_nonspec,

   output [0:`PID_WIDTH-1]      ierat_req1_pid,
   output                       ierat_req1_as,
   output                       ierat_req1_gs,
   output [0:`EPN_WIDTH-1]      ierat_req1_epn,
   output [0:`THDID_WIDTH-1]    ierat_req1_thdid,
   output                       ierat_req1_valid,
   output                       ierat_req1_nonspec,

   output [0:`PID_WIDTH-1]      ierat_req2_pid,
   output                       ierat_req2_as,
   output                       ierat_req2_gs,
   output [0:`EPN_WIDTH-1]      ierat_req2_epn,
   output [0:`THDID_WIDTH-1]    ierat_req2_thdid,
   output                       ierat_req2_valid,
   output                       ierat_req2_nonspec,

   output [0:`PID_WIDTH-1]      ierat_req3_pid,
   output                       ierat_req3_as,
   output                       ierat_req3_gs,
   output [0:`EPN_WIDTH-1]      ierat_req3_epn,
   output [0:`THDID_WIDTH-1]    ierat_req3_thdid,
   output                       ierat_req3_valid,
   output                       ierat_req3_nonspec,

   output [0:`PID_WIDTH-1]      ierat_iu4_pid,
   output                       ierat_iu4_gs,
   output                       ierat_iu4_as,
   output [0:`EPN_WIDTH-1]      ierat_iu4_epn,
   output [0:`THDID_WIDTH-1]    ierat_iu4_thdid,
   output                       ierat_iu4_valid,

   output [0:`LPID_WIDTH-1]     derat_req0_lpid,
   output [0:`PID_WIDTH-1]      derat_req0_pid,
   output                       derat_req0_as,
   output                       derat_req0_gs,
   output [0:`EPN_WIDTH-1]      derat_req0_epn,
   output [0:`THDID_WIDTH-1]    derat_req0_thdid,
   output [0:`EMQ_ENTRIES-1]    derat_req0_emq,
   output                       derat_req0_valid,
   output                       derat_req0_nonspec,

   output [0:`LPID_WIDTH-1]     derat_req1_lpid,
   output [0:`PID_WIDTH-1]      derat_req1_pid,
   output                       derat_req1_as,
   output                       derat_req1_gs,
   output [0:`EPN_WIDTH-1]      derat_req1_epn,
   output [0:`THDID_WIDTH-1]    derat_req1_thdid,
   output [0:`EMQ_ENTRIES-1]    derat_req1_emq,
   output                       derat_req1_valid,
   output                       derat_req1_nonspec,

   output [0:`LPID_WIDTH-1]     derat_req2_lpid,
   output [0:`PID_WIDTH-1]      derat_req2_pid,
   output                       derat_req2_as,
   output                       derat_req2_gs,
   output [0:`EPN_WIDTH-1]      derat_req2_epn,
   output [0:`THDID_WIDTH-1]    derat_req2_thdid,
   output [0:`EMQ_ENTRIES-1]    derat_req2_emq,
   output                       derat_req2_valid,
   output                       derat_req2_nonspec,

   output [0:`LPID_WIDTH-1]     derat_req3_lpid,
   output [0:`PID_WIDTH-1]      derat_req3_pid,
   output                       derat_req3_as,
   output                       derat_req3_gs,
   output [0:`EPN_WIDTH-1]      derat_req3_epn,
   output [0:`THDID_WIDTH-1]    derat_req3_thdid,
   output [0:`EMQ_ENTRIES-1]    derat_req3_emq,
   output                       derat_req3_valid,
   output                       derat_req3_nonspec,

   output [0:`LPID_WIDTH-1]     derat_ex5_lpid,
   output [0:`PID_WIDTH-1]      derat_ex5_pid,
   output                       derat_ex5_gs,
   output                       derat_ex5_as,
   output [0:`EPN_WIDTH-1]      derat_ex5_epn,
   output [0:`THDID_WIDTH-1]    derat_ex5_thdid,
   output                       derat_ex5_valid,

   input [0:`THDID_WIDTH-1]     xu_ex3_flush,
   input [0:`THDID_WIDTH-1]     xu_mm_ex4_flush,
   input [0:`THDID_WIDTH-1]     xu_mm_ex5_flush,
   input [0:`THDID_WIDTH-1]     xu_mm_ierat_miss,
   input [0:`THDID_WIDTH-1]     xu_mm_ierat_flush,

   input [0:6]                  tlb_cmp_ierat_dup_val,
   input [0:6]                  tlb_cmp_derat_dup_val,
   output                       tlb_seq_ierat_req,
   output                       tlb_seq_derat_req,
   input                        tlb_seq_ierat_done,
   input                        tlb_seq_derat_done,

   input                          ierat_req_taken,
   input                          derat_req_taken,
   output [0:`EPN_WIDTH-1]        ierat_req_epn,
   output [0:`PID_WIDTH-1]        ierat_req_pid,
   output [0:`REQ_STATE_WIDTH-1]  ierat_req_state,
   output [0:`THDID_WIDTH-1]      ierat_req_thdid,
   output [0:1]                   ierat_req_dup,
   output                         ierat_req_nonspec,

   output [0:`EPN_WIDTH-1]        derat_req_epn,
   output [0:`PID_WIDTH-1]        derat_req_pid,
   output [0:`LPID_WIDTH-1]       derat_req_lpid,
   output [0:`REQ_STATE_WIDTH-1]  derat_req_state,
   output [0:1]                   derat_req_ttype,
   output [0:`THDID_WIDTH-1]      derat_req_thdid,
   output [0:1]                   derat_req_dup,
   output [0:`ITAG_SIZE_ENC-1]    derat_req_itag,
   output [0:`EMQ_ENTRIES-1]      derat_req_emq,
   output                         derat_req_nonspec,

   output [0:`THDID_WIDTH-1]     tlb_req_quiesce,

   output                      tlb_req_dbg_ierat_iu5_valid_q,
   output [0:1]                tlb_req_dbg_ierat_iu5_thdid,
   output [0:3]                tlb_req_dbg_ierat_iu5_state_q,
   output [0:1]                tlb_req_dbg_ierat_inptr_q,
   output [0:1]                tlb_req_dbg_ierat_outptr_q,
   output [0:3]                tlb_req_dbg_ierat_req_valid_q,
   output [0:3]                tlb_req_dbg_ierat_req_nonspec_q,
   output [0:7]                tlb_req_dbg_ierat_req_thdid,
   output [0:3]                tlb_req_dbg_ierat_req_dup_q,
   output                      tlb_req_dbg_derat_ex6_valid_q,
   output [0:1]                tlb_req_dbg_derat_ex6_thdid,
   output [0:3]                tlb_req_dbg_derat_ex6_state_q,
   output [0:1]                tlb_req_dbg_derat_inptr_q,
   output [0:1]                tlb_req_dbg_derat_outptr_q,
   output [0:3]                tlb_req_dbg_derat_req_valid_q,
   output [0:7]                tlb_req_dbg_derat_req_thdid,
   output [0:7]                tlb_req_dbg_derat_req_ttype_q,
   output [0:3]                tlb_req_dbg_derat_req_dup_q

);


      parameter                   MMU_Mode_Value = 1'b0;
      parameter [0:1]             TlbSel_Tlb = 2'b00;
      parameter [0:1]             TlbSel_IErat = 2'b10;
      parameter [0:1]             TlbSel_DErat = 2'b11;
      parameter                   ierat_req0_valid_offset = 0;
      parameter                   ierat_req0_nonspec_offset = ierat_req0_valid_offset + 1;
      parameter                   ierat_req0_thdid_offset = ierat_req0_nonspec_offset + 1;
      parameter                   ierat_req0_epn_offset = ierat_req0_thdid_offset + `THDID_WIDTH;
      parameter                   ierat_req0_state_offset = ierat_req0_epn_offset + `EPN_WIDTH;
      parameter                   ierat_req0_pid_offset = ierat_req0_state_offset + `REQ_STATE_WIDTH;
      parameter                   ierat_req0_dup_offset = ierat_req0_pid_offset + `PID_WIDTH;
      parameter                   ierat_req1_valid_offset = ierat_req0_dup_offset + 2;
      parameter                   ierat_req1_nonspec_offset = ierat_req1_valid_offset + 1;
      parameter                   ierat_req1_thdid_offset = ierat_req1_nonspec_offset + 1;
      parameter                   ierat_req1_epn_offset = ierat_req1_thdid_offset + `THDID_WIDTH;
      parameter                   ierat_req1_state_offset = ierat_req1_epn_offset + `EPN_WIDTH;
      parameter                   ierat_req1_pid_offset = ierat_req1_state_offset + `REQ_STATE_WIDTH;
      parameter                   ierat_req1_dup_offset = ierat_req1_pid_offset + `PID_WIDTH;
      parameter                   ierat_req2_valid_offset = ierat_req1_dup_offset + 2;
      parameter                   ierat_req2_nonspec_offset = ierat_req2_valid_offset + 1;
      parameter                   ierat_req2_thdid_offset = ierat_req2_nonspec_offset + 1;
      parameter                   ierat_req2_epn_offset = ierat_req2_thdid_offset + `THDID_WIDTH;
      parameter                   ierat_req2_state_offset = ierat_req2_epn_offset + `EPN_WIDTH;
      parameter                   ierat_req2_pid_offset = ierat_req2_state_offset + `REQ_STATE_WIDTH;
      parameter                   ierat_req2_dup_offset = ierat_req2_pid_offset + `PID_WIDTH;
      parameter                   ierat_req3_valid_offset = ierat_req2_dup_offset + 2;
      parameter                   ierat_req3_nonspec_offset = ierat_req3_valid_offset + 1;
      parameter                   ierat_req3_thdid_offset = ierat_req3_nonspec_offset + 1;
      parameter                   ierat_req3_epn_offset = ierat_req3_thdid_offset + `THDID_WIDTH;
      parameter                   ierat_req3_state_offset = ierat_req3_epn_offset + `EPN_WIDTH;
      parameter                   ierat_req3_pid_offset = ierat_req3_state_offset + `REQ_STATE_WIDTH;
      parameter                   ierat_req3_dup_offset = ierat_req3_pid_offset + `PID_WIDTH;
      parameter                   ierat_inptr_offset = ierat_req3_dup_offset + 2;
      parameter                   ierat_outptr_offset = ierat_inptr_offset + 2;
      parameter                   tlb_seq_ierat_req_offset = ierat_outptr_offset + 2;
      parameter                   ierat_iu3_flush_offset = tlb_seq_ierat_req_offset + 1;
      parameter                   xu_mm_ierat_flush_offset = ierat_iu3_flush_offset + `THDID_WIDTH;
      parameter                   xu_mm_ierat_miss_offset = xu_mm_ierat_flush_offset + `THDID_WIDTH;
      parameter                   ierat_iu3_valid_offset = xu_mm_ierat_miss_offset + `THDID_WIDTH;
      parameter                   ierat_iu3_thdid_offset = ierat_iu3_valid_offset + 1;
      parameter                   ierat_iu3_epn_offset = ierat_iu3_thdid_offset + `THDID_WIDTH;
      parameter                   ierat_iu3_state_offset = ierat_iu3_epn_offset + `EPN_WIDTH;
      parameter                   ierat_iu3_pid_offset = ierat_iu3_state_offset + `REQ_STATE_WIDTH;
      parameter                   ierat_iu4_valid_offset = ierat_iu3_pid_offset + `PID_WIDTH;
      parameter                   ierat_iu4_thdid_offset = ierat_iu4_valid_offset + 1;
      parameter                   ierat_iu4_epn_offset = ierat_iu4_thdid_offset + `THDID_WIDTH;
      parameter                   ierat_iu4_state_offset = ierat_iu4_epn_offset + `EPN_WIDTH;
      parameter                   ierat_iu4_pid_offset = ierat_iu4_state_offset + `REQ_STATE_WIDTH;
      parameter                   ierat_iu5_valid_offset = ierat_iu4_pid_offset + `PID_WIDTH;
      parameter                   ierat_iu5_thdid_offset = ierat_iu5_valid_offset + 1;
      parameter                   ierat_iu5_epn_offset = ierat_iu5_thdid_offset + `THDID_WIDTH;
      parameter                   ierat_iu5_state_offset = ierat_iu5_epn_offset + `EPN_WIDTH;
      parameter                   ierat_iu5_pid_offset = ierat_iu5_state_offset + `REQ_STATE_WIDTH;
      parameter                   ierat_iu3_nonspec_offset = ierat_iu5_pid_offset + `PID_WIDTH;
      parameter                   ierat_iu4_nonspec_offset = ierat_iu3_nonspec_offset + 1;
      parameter                   ierat_iu5_nonspec_offset = ierat_iu4_nonspec_offset + 1;
      parameter                   derat_req0_valid_offset = ierat_iu5_nonspec_offset + 1;
      parameter                   derat_req0_thdid_offset = derat_req0_valid_offset + 1;
      parameter                   derat_req0_epn_offset = derat_req0_thdid_offset + `THDID_WIDTH;
      parameter                   derat_req0_state_offset = derat_req0_epn_offset + `EPN_WIDTH;
      parameter                   derat_req0_ttype_offset = derat_req0_state_offset + `REQ_STATE_WIDTH;
      parameter                   derat_req0_pid_offset = derat_req0_ttype_offset + 2;
      parameter                   derat_req0_lpid_offset = derat_req0_pid_offset + `PID_WIDTH;
      parameter                   derat_req0_dup_offset = derat_req0_lpid_offset + `LPID_WIDTH;
      parameter                   derat_req1_valid_offset = derat_req0_dup_offset + 2;
      parameter                   derat_req1_thdid_offset = derat_req1_valid_offset + 1;
      parameter                   derat_req1_epn_offset = derat_req1_thdid_offset + `THDID_WIDTH;
      parameter                   derat_req1_state_offset = derat_req1_epn_offset + `EPN_WIDTH;
      parameter                   derat_req1_ttype_offset = derat_req1_state_offset + `REQ_STATE_WIDTH;
      parameter                   derat_req1_pid_offset = derat_req1_ttype_offset + 2;
      parameter                   derat_req1_lpid_offset = derat_req1_pid_offset + `PID_WIDTH;
      parameter                   derat_req1_dup_offset = derat_req1_lpid_offset + `LPID_WIDTH;
      parameter                   derat_req2_valid_offset = derat_req1_dup_offset + 2;
      parameter                   derat_req2_thdid_offset = derat_req2_valid_offset + 1;
      parameter                   derat_req2_epn_offset = derat_req2_thdid_offset + `THDID_WIDTH;
      parameter                   derat_req2_state_offset = derat_req2_epn_offset + `EPN_WIDTH;
      parameter                   derat_req2_ttype_offset = derat_req2_state_offset + `REQ_STATE_WIDTH;
      parameter                   derat_req2_pid_offset = derat_req2_ttype_offset + 2;
      parameter                   derat_req2_lpid_offset = derat_req2_pid_offset + `PID_WIDTH;
      parameter                   derat_req2_dup_offset = derat_req2_lpid_offset + `LPID_WIDTH;
      parameter                   derat_req3_valid_offset = derat_req2_dup_offset + 2;
      parameter                   derat_req3_thdid_offset = derat_req3_valid_offset + 1;
      parameter                   derat_req3_epn_offset = derat_req3_thdid_offset + `THDID_WIDTH;
      parameter                   derat_req3_state_offset = derat_req3_epn_offset + `EPN_WIDTH;
      parameter                   derat_req3_ttype_offset = derat_req3_state_offset + `REQ_STATE_WIDTH;
      parameter                   derat_req3_pid_offset = derat_req3_ttype_offset + 2;
      parameter                   derat_req3_lpid_offset = derat_req3_pid_offset + `PID_WIDTH;
      parameter                   derat_req3_dup_offset = derat_req3_lpid_offset + `LPID_WIDTH;
      parameter                   derat_inptr_offset = derat_req3_dup_offset + 2;
      parameter                   derat_outptr_offset = derat_inptr_offset + 2;
      parameter                   tlb_seq_derat_req_offset = derat_outptr_offset + 2;
      parameter                   derat_ex4_valid_offset = tlb_seq_derat_req_offset + 1;
      parameter                   derat_ex4_thdid_offset = derat_ex4_valid_offset + 1;
      parameter                   derat_ex4_epn_offset = derat_ex4_thdid_offset + `THDID_WIDTH;
      parameter                   derat_ex4_state_offset = derat_ex4_epn_offset + `EPN_WIDTH;
      parameter                   derat_ex4_ttype_offset = derat_ex4_state_offset + `REQ_STATE_WIDTH;
      parameter                   derat_ex4_pid_offset = derat_ex4_ttype_offset + 2;
      parameter                   derat_ex4_lpid_offset = derat_ex4_pid_offset + `PID_WIDTH;
      parameter                   derat_ex5_valid_offset = derat_ex4_lpid_offset + `LPID_WIDTH;
      parameter                   derat_ex5_thdid_offset = derat_ex5_valid_offset + 1;
      parameter                   derat_ex5_epn_offset = derat_ex5_thdid_offset + `THDID_WIDTH;
      parameter                   derat_ex5_state_offset = derat_ex5_epn_offset + `EPN_WIDTH;
      parameter                   derat_ex5_ttype_offset = derat_ex5_state_offset + `REQ_STATE_WIDTH;
      parameter                   derat_ex5_pid_offset = derat_ex5_ttype_offset + 2;
      parameter                   derat_ex5_lpid_offset = derat_ex5_pid_offset + `PID_WIDTH;
      parameter                   derat_ex6_valid_offset = derat_ex5_lpid_offset + `LPID_WIDTH;
      parameter                   derat_ex6_thdid_offset = derat_ex6_valid_offset + 1;
      parameter                   derat_ex6_epn_offset = derat_ex6_thdid_offset + `THDID_WIDTH;
      parameter                   derat_ex6_state_offset = derat_ex6_epn_offset + `EPN_WIDTH;
      parameter                   derat_ex6_ttype_offset = derat_ex6_state_offset + `REQ_STATE_WIDTH;
      parameter                   derat_ex6_pid_offset = derat_ex6_ttype_offset + 2;
      parameter                   derat_ex6_lpid_offset = derat_ex6_pid_offset + `PID_WIDTH;
      parameter                   derat_ex4_itag_offset = derat_ex6_lpid_offset + `LPID_WIDTH;
      parameter                   derat_ex4_emq_offset = derat_ex4_itag_offset + `ITAG_SIZE_ENC;
      parameter                   derat_ex4_nonspec_offset = derat_ex4_emq_offset + `EMQ_ENTRIES;
      parameter                   derat_ex5_itag_offset = derat_ex4_nonspec_offset + 1;
      parameter                   derat_ex5_emq_offset = derat_ex5_itag_offset + `ITAG_SIZE_ENC;
      parameter                   derat_ex5_nonspec_offset = derat_ex5_emq_offset + `EMQ_ENTRIES;
      parameter                   derat_ex6_itag_offset = derat_ex5_nonspec_offset + 1;
      parameter                   derat_ex6_emq_offset = derat_ex6_itag_offset + `ITAG_SIZE_ENC;
      parameter                   derat_ex6_nonspec_offset = derat_ex6_emq_offset + `EMQ_ENTRIES;
      parameter                   derat_req0_itag_offset = derat_ex6_nonspec_offset + 1;
      parameter                   derat_req0_emq_offset = derat_req0_itag_offset + `ITAG_SIZE_ENC;
      parameter                   derat_req0_nonspec_offset = derat_req0_emq_offset + `EMQ_ENTRIES;
      parameter                   derat_req1_itag_offset = derat_req0_nonspec_offset + 1;
      parameter                   derat_req1_emq_offset = derat_req1_itag_offset + `ITAG_SIZE_ENC;
      parameter                   derat_req1_nonspec_offset = derat_req1_emq_offset + `EMQ_ENTRIES;
      parameter                   derat_req2_itag_offset = derat_req1_nonspec_offset + 1;
      parameter                   derat_req2_emq_offset = derat_req2_itag_offset + `ITAG_SIZE_ENC;
      parameter                   derat_req2_nonspec_offset = derat_req2_emq_offset + `EMQ_ENTRIES;
      parameter                   derat_req3_itag_offset = derat_req2_nonspec_offset + 1;
      parameter                   derat_req3_emq_offset = derat_req3_itag_offset + `ITAG_SIZE_ENC;
      parameter                   derat_req3_nonspec_offset = derat_req3_emq_offset + `EMQ_ENTRIES;
      parameter                   spare_offset = derat_req3_nonspec_offset + 1;
      parameter                   scan_right = spare_offset + 32 - 1;

`ifdef MM_THREADS2
      parameter                      BUGSP_MM_THREADS = 2;
`else
      parameter                      BUGSP_MM_THREADS = 1;
`endif

      // Latch signals
      wire                        ierat_req0_valid_d;
      wire                        ierat_req0_valid_q;
      wire                        ierat_req0_nonspec_d;
      wire                        ierat_req0_nonspec_q;
      wire [0:`THDID_WIDTH-1]      ierat_req0_thdid_d;
      wire [0:`THDID_WIDTH-1]      ierat_req0_thdid_q;
      wire [0:`EPN_WIDTH-1]    ierat_req0_epn_d;
      wire [0:`EPN_WIDTH-1]    ierat_req0_epn_q;
      wire [0:`REQ_STATE_WIDTH-1]      ierat_req0_state_d;
      wire [0:`REQ_STATE_WIDTH-1]      ierat_req0_state_q;
      wire [0:`PID_WIDTH-1]        ierat_req0_pid_d;
      wire [0:`PID_WIDTH-1]        ierat_req0_pid_q;
      wire [0:1]                  ierat_req0_dup_d;
      wire [0:1]                  ierat_req0_dup_q;
      wire                        ierat_req1_valid_d;
      wire                        ierat_req1_valid_q;
      wire                        ierat_req1_nonspec_d;
      wire                        ierat_req1_nonspec_q;
      wire [0:`THDID_WIDTH-1]      ierat_req1_thdid_d;
      wire [0:`THDID_WIDTH-1]      ierat_req1_thdid_q;
      wire [0:`EPN_WIDTH-1]    ierat_req1_epn_d;
      wire [0:`EPN_WIDTH-1]    ierat_req1_epn_q;
      wire [0:`REQ_STATE_WIDTH-1]      ierat_req1_state_d;
      wire [0:`REQ_STATE_WIDTH-1]      ierat_req1_state_q;
      wire [0:`PID_WIDTH-1]        ierat_req1_pid_d;
      wire [0:`PID_WIDTH-1]        ierat_req1_pid_q;
      wire [0:1]                  ierat_req1_dup_d;
      wire [0:1]                  ierat_req1_dup_q;
      wire                        ierat_req2_valid_d;
      wire                        ierat_req2_valid_q;
      wire                        ierat_req2_nonspec_d;
      wire                        ierat_req2_nonspec_q;
      wire [0:`THDID_WIDTH-1]      ierat_req2_thdid_d;
      wire [0:`THDID_WIDTH-1]      ierat_req2_thdid_q;
      wire [0:`EPN_WIDTH-1]    ierat_req2_epn_d;
      wire [0:`EPN_WIDTH-1]    ierat_req2_epn_q;
      wire [0:`REQ_STATE_WIDTH-1]      ierat_req2_state_d;
      wire [0:`REQ_STATE_WIDTH-1]      ierat_req2_state_q;
      wire [0:`PID_WIDTH-1]        ierat_req2_pid_d;
      wire [0:`PID_WIDTH-1]        ierat_req2_pid_q;
      wire [0:1]                  ierat_req2_dup_d;
      wire [0:1]                  ierat_req2_dup_q;
      wire                        ierat_req3_valid_d;
      wire                        ierat_req3_valid_q;
      wire                        ierat_req3_nonspec_d;
      wire                        ierat_req3_nonspec_q;
      wire [0:`THDID_WIDTH-1]      ierat_req3_thdid_d;
      wire [0:`THDID_WIDTH-1]      ierat_req3_thdid_q;
      wire [0:`EPN_WIDTH-1]    ierat_req3_epn_d;
      wire [0:`EPN_WIDTH-1]    ierat_req3_epn_q;
      wire [0:`REQ_STATE_WIDTH-1]      ierat_req3_state_d;
      wire [0:`REQ_STATE_WIDTH-1]      ierat_req3_state_q;
      wire [0:`PID_WIDTH-1]        ierat_req3_pid_d;
      wire [0:`PID_WIDTH-1]        ierat_req3_pid_q;
      wire [0:1]                  ierat_req3_dup_d;
      wire [0:1]                  ierat_req3_dup_q;
      wire                        ierat_iu3_valid_d;
      wire                        ierat_iu3_valid_q;
      wire [0:`THDID_WIDTH-1]      ierat_iu3_thdid_d;
      wire [0:`THDID_WIDTH-1]      ierat_iu3_thdid_q;
      wire [0:`EPN_WIDTH-1]    ierat_iu3_epn_d;
      wire [0:`EPN_WIDTH-1]    ierat_iu3_epn_q;
      wire [0:`REQ_STATE_WIDTH-1]      ierat_iu3_state_d;
      wire [0:`REQ_STATE_WIDTH-1]      ierat_iu3_state_q;
      wire [0:`PID_WIDTH-1]        ierat_iu3_pid_d;
      wire [0:`PID_WIDTH-1]        ierat_iu3_pid_q;
      wire                        ierat_iu3_nonspec_d;
      wire                        ierat_iu3_nonspec_q;
      wire                        ierat_iu4_valid_d;
      wire                        ierat_iu4_valid_q;
      wire [0:`THDID_WIDTH-1]      ierat_iu4_thdid_d;
      wire [0:`THDID_WIDTH-1]      ierat_iu4_thdid_q;
      wire [0:`EPN_WIDTH-1]    ierat_iu4_epn_d;
      wire [0:`EPN_WIDTH-1]    ierat_iu4_epn_q;
      wire [0:`REQ_STATE_WIDTH-1]      ierat_iu4_state_d;
      wire [0:`REQ_STATE_WIDTH-1]      ierat_iu4_state_q;
      wire [0:`PID_WIDTH-1]        ierat_iu4_pid_d;
      wire [0:`PID_WIDTH-1]        ierat_iu4_pid_q;
      wire                        ierat_iu4_nonspec_d;
      wire                        ierat_iu4_nonspec_q;
      wire                        ierat_iu5_valid_d;
      wire                        ierat_iu5_valid_q;
      wire [0:`THDID_WIDTH-1]      ierat_iu5_thdid_d;
      wire [0:`THDID_WIDTH-1]      ierat_iu5_thdid_q;
      wire [0:`EPN_WIDTH-1]    ierat_iu5_epn_d;
      wire [0:`EPN_WIDTH-1]    ierat_iu5_epn_q;
      wire [0:`REQ_STATE_WIDTH-1]      ierat_iu5_state_d;
      wire [0:`REQ_STATE_WIDTH-1]      ierat_iu5_state_q;
      wire [0:`PID_WIDTH-1]        ierat_iu5_pid_d;
      wire [0:`PID_WIDTH-1]        ierat_iu5_pid_q;
      wire                        ierat_iu5_nonspec_d;
      wire                        ierat_iu5_nonspec_q;
      wire [0:`THDID_WIDTH-1]      ierat_iu3_flush_d;
      wire [0:`THDID_WIDTH-1]      ierat_iu3_flush_q;
      wire [0:`THDID_WIDTH-1]      xu_mm_ierat_flush_d;
      wire [0:`THDID_WIDTH-1]      xu_mm_ierat_flush_q;
      wire [0:`THDID_WIDTH-1]      xu_mm_ierat_miss_d;
      wire [0:`THDID_WIDTH-1]      xu_mm_ierat_miss_q;
      wire [0:1]                  ierat_inptr_d;
      wire [0:1]                  ierat_inptr_q;
      wire [0:1]                  ierat_outptr_d;
      wire [0:1]                  ierat_outptr_q;
      wire                        tlb_seq_ierat_req_d;
      wire                        tlb_seq_ierat_req_q;
      wire                        derat_req0_valid_d;
      wire                        derat_req0_valid_q;
      wire [0:`THDID_WIDTH-1]      derat_req0_thdid_d;
      wire [0:`THDID_WIDTH-1]      derat_req0_thdid_q;
      wire [0:`EPN_WIDTH-1]    derat_req0_epn_d;
      wire [0:`EPN_WIDTH-1]    derat_req0_epn_q;
      wire [0:`REQ_STATE_WIDTH-1]      derat_req0_state_d;
      wire [0:`REQ_STATE_WIDTH-1]      derat_req0_state_q;
      wire [0:1]                  derat_req0_ttype_d;
      wire [0:1]                  derat_req0_ttype_q;
      wire [0:`PID_WIDTH-1]        derat_req0_pid_d;
      wire [0:`PID_WIDTH-1]        derat_req0_pid_q;
      wire [0:`LPID_WIDTH-1]       derat_req0_lpid_d;
      wire [0:`LPID_WIDTH-1]       derat_req0_lpid_q;
      wire [0:1]                  derat_req0_dup_d;
      wire [0:1]                  derat_req0_dup_q;
      wire [0:`ITAG_SIZE_ENC-1]    derat_req0_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]    derat_req0_itag_q;
      wire [0:`EMQ_ENTRIES-1]      derat_req0_emq_d;
      wire [0:`EMQ_ENTRIES-1]      derat_req0_emq_q;
      wire                        derat_req0_nonspec_d;
      wire                        derat_req0_nonspec_q;
      wire                        derat_req1_valid_d;
      wire                        derat_req1_valid_q;
      wire [0:`THDID_WIDTH-1]      derat_req1_thdid_d;
      wire [0:`THDID_WIDTH-1]      derat_req1_thdid_q;
      wire [0:`EPN_WIDTH-1]    derat_req1_epn_d;
      wire [0:`EPN_WIDTH-1]    derat_req1_epn_q;
      wire [0:`REQ_STATE_WIDTH-1]      derat_req1_state_d;
      wire [0:`REQ_STATE_WIDTH-1]      derat_req1_state_q;
      wire [0:1]                  derat_req1_ttype_d;
      wire [0:1]                  derat_req1_ttype_q;
      wire [0:`PID_WIDTH-1]        derat_req1_pid_d;
      wire [0:`PID_WIDTH-1]        derat_req1_pid_q;
      wire [0:`LPID_WIDTH-1]       derat_req1_lpid_d;
      wire [0:`LPID_WIDTH-1]       derat_req1_lpid_q;
      wire [0:1]                  derat_req1_dup_d;
      wire [0:1]                  derat_req1_dup_q;
      wire [0:`ITAG_SIZE_ENC-1]    derat_req1_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]    derat_req1_itag_q;
      wire [0:`EMQ_ENTRIES-1]      derat_req1_emq_d;
      wire [0:`EMQ_ENTRIES-1]      derat_req1_emq_q;
      wire                        derat_req1_nonspec_d;
      wire                        derat_req1_nonspec_q;
      wire                        derat_req2_valid_d;
      wire                        derat_req2_valid_q;
      wire [0:`THDID_WIDTH-1]      derat_req2_thdid_d;
      wire [0:`THDID_WIDTH-1]      derat_req2_thdid_q;
      wire [0:`EPN_WIDTH-1]    derat_req2_epn_d;
      wire [0:`EPN_WIDTH-1]    derat_req2_epn_q;
      wire [0:`REQ_STATE_WIDTH-1]      derat_req2_state_d;
      wire [0:`REQ_STATE_WIDTH-1]      derat_req2_state_q;
      wire [0:1]                  derat_req2_ttype_d;
      wire [0:1]                  derat_req2_ttype_q;
      wire [0:`PID_WIDTH-1]        derat_req2_pid_d;
      wire [0:`PID_WIDTH-1]        derat_req2_pid_q;
      wire [0:`LPID_WIDTH-1]       derat_req2_lpid_d;
      wire [0:`LPID_WIDTH-1]       derat_req2_lpid_q;
      wire [0:1]                  derat_req2_dup_d;
      wire [0:1]                  derat_req2_dup_q;
      wire [0:`ITAG_SIZE_ENC-1]    derat_req2_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]    derat_req2_itag_q;
      wire [0:`EMQ_ENTRIES-1]      derat_req2_emq_d;
      wire [0:`EMQ_ENTRIES-1]      derat_req2_emq_q;
      wire                        derat_req2_nonspec_d;
      wire                        derat_req2_nonspec_q;
      wire                        derat_req3_valid_d;
      wire                        derat_req3_valid_q;
      wire [0:`THDID_WIDTH-1]      derat_req3_thdid_d;
      wire [0:`THDID_WIDTH-1]      derat_req3_thdid_q;
      wire [0:`EPN_WIDTH-1]    derat_req3_epn_d;
      wire [0:`EPN_WIDTH-1]    derat_req3_epn_q;
      wire [0:`REQ_STATE_WIDTH-1]      derat_req3_state_d;
      wire [0:`REQ_STATE_WIDTH-1]      derat_req3_state_q;
      wire [0:1]                  derat_req3_ttype_d;
      wire [0:1]                  derat_req3_ttype_q;
      wire [0:`PID_WIDTH-1]        derat_req3_pid_d;
      wire [0:`PID_WIDTH-1]        derat_req3_pid_q;
      wire [0:`LPID_WIDTH-1]       derat_req3_lpid_d;
      wire [0:`LPID_WIDTH-1]       derat_req3_lpid_q;
      wire [0:1]                  derat_req3_dup_d;
      wire [0:1]                  derat_req3_dup_q;
      wire [0:`ITAG_SIZE_ENC-1]    derat_req3_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]    derat_req3_itag_q;
      wire [0:`EMQ_ENTRIES-1]      derat_req3_emq_d;
      wire [0:`EMQ_ENTRIES-1]      derat_req3_emq_q;
      wire                        derat_req3_nonspec_d;
      wire                        derat_req3_nonspec_q;
      wire                        derat_ex4_valid_d;
      wire                        derat_ex4_valid_q;
      wire [0:`THDID_WIDTH-1]      derat_ex4_thdid_d;
      wire [0:`THDID_WIDTH-1]      derat_ex4_thdid_q;
      wire [0:`EPN_WIDTH-1]    derat_ex4_epn_d;
      wire [0:`EPN_WIDTH-1]    derat_ex4_epn_q;
      wire [0:`REQ_STATE_WIDTH-1]      derat_ex4_state_d;
      wire [0:`REQ_STATE_WIDTH-1]      derat_ex4_state_q;
      wire [0:1]                  derat_ex4_ttype_d;
      wire [0:1]                  derat_ex4_ttype_q;
      wire [0:`PID_WIDTH-1]        derat_ex4_pid_d;
      wire [0:`PID_WIDTH-1]        derat_ex4_pid_q;
      wire [0:`LPID_WIDTH-1]       derat_ex4_lpid_d;
      wire [0:`LPID_WIDTH-1]       derat_ex4_lpid_q;
      wire [0:`ITAG_SIZE_ENC-1]    derat_ex4_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]    derat_ex4_itag_q;
      wire [0:`EMQ_ENTRIES-1]      derat_ex4_emq_d;
      wire [0:`EMQ_ENTRIES-1]      derat_ex4_emq_q;
      wire                        derat_ex4_nonspec_d;
      wire                        derat_ex4_nonspec_q;
      wire                        derat_ex5_valid_d;
      wire                        derat_ex5_valid_q;
      wire [0:`THDID_WIDTH-1]      derat_ex5_thdid_d;
      wire [0:`THDID_WIDTH-1]      derat_ex5_thdid_q;
      wire [0:`EPN_WIDTH-1]    derat_ex5_epn_d;
      wire [0:`EPN_WIDTH-1]    derat_ex5_epn_q;
      wire [0:`REQ_STATE_WIDTH-1]      derat_ex5_state_d;
      wire [0:`REQ_STATE_WIDTH-1]      derat_ex5_state_q;
      wire [0:1]                  derat_ex5_ttype_d;
      wire [0:1]                  derat_ex5_ttype_q;
      wire [0:`PID_WIDTH-1]        derat_ex5_pid_d;
      wire [0:`PID_WIDTH-1]        derat_ex5_pid_q;
      wire [0:`LPID_WIDTH-1]       derat_ex5_lpid_d;
      wire [0:`LPID_WIDTH-1]       derat_ex5_lpid_q;
      wire [0:`ITAG_SIZE_ENC-1]    derat_ex5_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]    derat_ex5_itag_q;
      wire [0:`EMQ_ENTRIES-1]      derat_ex5_emq_d;
      wire [0:`EMQ_ENTRIES-1]      derat_ex5_emq_q;
      wire                        derat_ex5_nonspec_d;
      wire                        derat_ex5_nonspec_q;
      wire                        derat_ex6_valid_d;
      wire                        derat_ex6_valid_q;
      wire [0:`THDID_WIDTH-1]      derat_ex6_thdid_d;
      wire [0:`THDID_WIDTH-1]      derat_ex6_thdid_q;
      wire [0:`EPN_WIDTH-1]    derat_ex6_epn_d;
      wire [0:`EPN_WIDTH-1]    derat_ex6_epn_q;
      wire [0:`REQ_STATE_WIDTH-1]      derat_ex6_state_d;
      wire [0:`REQ_STATE_WIDTH-1]      derat_ex6_state_q;
      wire [0:1]                  derat_ex6_ttype_d;
      wire [0:1]                  derat_ex6_ttype_q;
      wire [0:`PID_WIDTH-1]        derat_ex6_pid_d;
      wire [0:`PID_WIDTH-1]        derat_ex6_pid_q;
      wire [0:`LPID_WIDTH-1]       derat_ex6_lpid_d;
      wire [0:`LPID_WIDTH-1]       derat_ex6_lpid_q;
      wire [0:`ITAG_SIZE_ENC-1]    derat_ex6_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]    derat_ex6_itag_q;
      wire [0:`EMQ_ENTRIES-1]      derat_ex6_emq_d;
      wire [0:`EMQ_ENTRIES-1]      derat_ex6_emq_q;
      wire                        derat_ex6_nonspec_d;
      wire                        derat_ex6_nonspec_q;
      wire [0:1]                  derat_inptr_d;
      wire [0:1]                  derat_inptr_q;
      wire [0:1]                  derat_outptr_d;
      wire [0:1]                  derat_outptr_q;
      wire                        tlb_seq_derat_req_d;
      wire                        tlb_seq_derat_req_q;
      wire [0:31]                 spare_q;
      // logic signals
      wire [0:`PID_WIDTH-1]        ierat_req_pid_mux;
      wire [0:`THDID_WIDTH-1]      tlb_req_quiesce_b;

      (* analysis_not_referenced="true" *)
      wire [0:16]                 unused_dc;

      // Pervasive
      wire                        pc_sg_1;
      wire                        pc_sg_0;
      wire                        pc_func_sl_thold_1;
      wire                        pc_func_sl_thold_0;
      wire                        pc_func_sl_thold_0_b;
      wire                        pc_func_slp_sl_thold_1;
      wire                        pc_func_slp_sl_thold_0;
      wire                        pc_func_slp_sl_thold_0_b;
      wire                        pc_func_sl_force;
      wire                        pc_func_slp_sl_force;
      wire [0:scan_right]         siv;
      wire [0:scan_right]         sov;

      //!! Bugspray Include: mmq_tlb_req;
      //---------------------------------------------------------------------
      // Logic
      //---------------------------------------------------------------------
      //---------------------------------------------------------------------
      // Common stuff for erat-only and tlb
      //---------------------------------------------------------------------

      // not quiesced
      assign tlb_req_quiesce_b[0:`THDID_WIDTH - 1] = ({`THDID_WIDTH{ierat_req0_valid_q}} & ierat_req0_thdid_q[0:`THDID_WIDTH - 1]) |
                                                       ({`THDID_WIDTH{ierat_req1_valid_q}} & ierat_req1_thdid_q[0:`THDID_WIDTH - 1]) |
                                                       ({`THDID_WIDTH{ierat_req2_valid_q}} & ierat_req2_thdid_q[0:`THDID_WIDTH - 1]) |
                                                       ({`THDID_WIDTH{ierat_req3_valid_q}} & ierat_req3_thdid_q[0:`THDID_WIDTH - 1]) |
                                                       ({`THDID_WIDTH{derat_req0_valid_q}} & derat_req0_thdid_q[0:`THDID_WIDTH - 1]) |
                                                       ({`THDID_WIDTH{derat_req1_valid_q}} & derat_req1_thdid_q[0:`THDID_WIDTH - 1]) |
                                                       ({`THDID_WIDTH{derat_req2_valid_q}} & derat_req2_thdid_q[0:`THDID_WIDTH - 1]) |
                                                       ({`THDID_WIDTH{derat_req3_valid_q}} & derat_req3_thdid_q[0:`THDID_WIDTH - 1]) |
                                                       ({`THDID_WIDTH{derat_ex4_valid_q}} & derat_ex4_thdid_q[0:`THDID_WIDTH - 1]) |
                                                       ({`THDID_WIDTH{derat_ex5_valid_q}} & derat_ex5_thdid_q[0:`THDID_WIDTH - 1]) |
                                                       ({`THDID_WIDTH{derat_ex6_valid_q}} & derat_ex6_thdid_q[0:`THDID_WIDTH - 1]) |
                                                       ({`THDID_WIDTH{ierat_iu3_valid_q}} & ierat_iu3_thdid_q[0:`THDID_WIDTH - 1]) |
                                                       ({`THDID_WIDTH{ierat_iu4_valid_q}} & ierat_iu4_thdid_q[0:`THDID_WIDTH - 1]) |
                                                       ({`THDID_WIDTH{ierat_iu5_valid_q}} & ierat_iu5_thdid_q[0:`THDID_WIDTH - 1]);

      assign tlb_req_quiesce = (~tlb_req_quiesce_b);
      assign xu_mm_ierat_flush_d = xu_mm_ierat_flush;
      assign xu_mm_ierat_miss_d = xu_mm_ierat_miss;
      // iu pipe for non-speculative ierat flush processing
      assign ierat_iu3_flush_d = iu_mm_ierat_flush;
      assign ierat_iu3_valid_d = iu_mm_ierat_req;
      assign ierat_iu4_valid_d = ((ierat_iu3_valid_q == 1'b1 & |(ierat_iu3_thdid_q & (~(ierat_iu3_flush_q)) & (~(xu_mm_ierat_flush_q))) == 1'b1)) ? 1'b1 :
                                 1'b0;
      assign ierat_iu5_valid_d = ((ierat_iu4_valid_q == 1'b1 & |(ierat_iu4_thdid_q & (~(ierat_iu3_flush_q)) & (~(xu_mm_ierat_flush_q))) == 1'b1)) ? 1'b1 :
                                 1'b0;
      assign ierat_iu3_thdid_d = iu_mm_ierat_thdid;
      assign ierat_iu3_state_d = iu_mm_ierat_state;
      assign ierat_iu3_pid_d = iu_mm_ierat_tid;

      generate
         if (`RS_DATA_WIDTH == 64)
         begin : gen64_iu3_epn
            assign ierat_iu3_epn_d = iu_mm_ierat_epn;
         end
      endgenerate
      generate
         if (`RS_DATA_WIDTH < 64)
         begin : gen32_iu3_epn
            assign ierat_iu3_epn_d = {1'b0, iu_mm_ierat_epn[64 - `RS_DATA_WIDTH:51]};
         end
      endgenerate
      assign ierat_iu4_thdid_d = ierat_iu3_thdid_q;
      assign ierat_iu4_epn_d = ierat_iu3_epn_q;
      assign ierat_iu4_state_d = ierat_iu3_state_q;
      assign ierat_iu4_pid_d = ierat_iu3_pid_q;
      assign ierat_iu5_thdid_d = ierat_iu4_thdid_q;
      assign ierat_iu5_epn_d = ierat_iu4_epn_q;
      assign ierat_iu5_state_d = ierat_iu4_state_q;
      assign ierat_iu5_pid_d = ierat_iu4_pid_q;
      assign ierat_iu3_nonspec_d = iu_mm_ierat_req_nonspec;
      assign ierat_iu4_nonspec_d = ierat_iu3_nonspec_q;
      assign ierat_iu5_nonspec_d = ierat_iu4_nonspec_q;

      // ierat request queue logic pointers
      assign ierat_inptr_d = (ierat_inptr_q == 2'b00 & ierat_req1_valid_q == 1'b0 & ierat_iu5_valid_q == 1'b1) ? 2'b01 :
                             (ierat_inptr_q == 2'b00 & ierat_req2_valid_q == 1'b0 & ierat_iu5_valid_q == 1'b1) ? 2'b10 :
                             (ierat_inptr_q == 2'b00 & ierat_req3_valid_q == 1'b0 & ierat_iu5_valid_q == 1'b1) ? 2'b11 :
                             (ierat_inptr_q == 2'b01 & ierat_req2_valid_q == 1'b0 & ierat_iu5_valid_q == 1'b1) ? 2'b10 :
                             (ierat_inptr_q == 2'b01 & ierat_req3_valid_q == 1'b0 & ierat_iu5_valid_q == 1'b1) ? 2'b11 :
                             (ierat_inptr_q == 2'b01 & ierat_req0_valid_q == 1'b0 & ierat_iu5_valid_q == 1'b1) ? 2'b00 :
                             (ierat_inptr_q == 2'b10 & ierat_req3_valid_q == 1'b0 & ierat_iu5_valid_q == 1'b1) ? 2'b11 :
                             (ierat_inptr_q == 2'b10 & ierat_req0_valid_q == 1'b0 & ierat_iu5_valid_q == 1'b1) ? 2'b00 :
                             (ierat_inptr_q == 2'b10 & ierat_req1_valid_q == 1'b0 & ierat_iu5_valid_q == 1'b1) ? 2'b01 :
                             (ierat_inptr_q == 2'b11 & ierat_req0_valid_q == 1'b0 & ierat_iu5_valid_q == 1'b1) ? 2'b00 :
                             (ierat_inptr_q == 2'b11 & ierat_req1_valid_q == 1'b0 & ierat_iu5_valid_q == 1'b1) ? 2'b01 :
                             (ierat_inptr_q == 2'b11 & ierat_req2_valid_q == 1'b0 & ierat_iu5_valid_q == 1'b1) ? 2'b10 :
                             (ierat_req_taken == 1'b1) ? ierat_outptr_q :
                             ierat_inptr_q;

      assign ierat_outptr_d = (ierat_outptr_q == 2'b00 & ierat_req0_valid_q == 1'b1 & ierat_req_taken == 1'b1) ? 2'b01 :
                              (ierat_outptr_q == 2'b01 & ierat_req1_valid_q == 1'b1 & ierat_req_taken == 1'b1) ? 2'b10 :
                              (ierat_outptr_q == 2'b10 & ierat_req2_valid_q == 1'b1 & ierat_req_taken == 1'b1) ? 2'b11 :
                              (ierat_outptr_q == 2'b11 & ierat_req3_valid_q == 1'b1 & ierat_req_taken == 1'b1) ? 2'b00 :
                              (ierat_outptr_q == 2'b00 & ierat_req0_valid_q == 1'b0 & ierat_req1_valid_q == 1'b1) ? 2'b01 :
                              (ierat_outptr_q == 2'b00 & ierat_req0_valid_q == 1'b0 & ierat_req1_valid_q == 1'b0 & ierat_req2_valid_q == 1'b1) ? 2'b10 :
                              (ierat_outptr_q == 2'b00 & ierat_req0_valid_q == 1'b0 & ierat_req1_valid_q == 1'b0 & ierat_req2_valid_q == 1'b0 & ierat_req3_valid_q == 1'b1) ? 2'b11 :
                              (ierat_outptr_q == 2'b01 & ierat_req1_valid_q == 1'b0 & ierat_req2_valid_q == 1'b1) ? 2'b10 :
                              (ierat_outptr_q == 2'b01 & ierat_req1_valid_q == 1'b0 & ierat_req2_valid_q == 1'b0 & ierat_req3_valid_q == 1'b1) ? 2'b11 :
                              (ierat_outptr_q == 2'b01 & ierat_req1_valid_q == 1'b0 & ierat_req2_valid_q == 1'b0 & ierat_req3_valid_q == 1'b0 & ierat_req0_valid_q == 1'b1) ? 2'b00 :
                              (ierat_outptr_q == 2'b10 & ierat_req2_valid_q == 1'b0 & ierat_req3_valid_q == 1'b1) ? 2'b11 :
                              (ierat_outptr_q == 2'b10 & ierat_req2_valid_q == 1'b0 & ierat_req3_valid_q == 1'b0 & ierat_req0_valid_q == 1'b1) ? 2'b00 :
                              (ierat_outptr_q == 2'b10 & ierat_req2_valid_q == 1'b0 & ierat_req3_valid_q == 1'b0 & ierat_req0_valid_q == 1'b0 & ierat_req1_valid_q == 1'b1) ? 2'b01 :
                              (ierat_outptr_q == 2'b11 & ierat_req3_valid_q == 1'b0 & ierat_req0_valid_q == 1'b1) ? 2'b00 :
                              (ierat_outptr_q == 2'b11 & ierat_req3_valid_q == 1'b0 & ierat_req0_valid_q == 1'b0 & ierat_req1_valid_q == 1'b1) ? 2'b01 :
                              (ierat_outptr_q == 2'b11 & ierat_req3_valid_q == 1'b0 & ierat_req0_valid_q == 1'b0 & ierat_req1_valid_q == 1'b0 & ierat_req2_valid_q == 1'b1) ? 2'b10 :
                              ierat_outptr_q;

      assign tlb_seq_ierat_req_d = (((ierat_outptr_q == 2'b00 & ierat_req0_valid_q == 1'b1 & |(ierat_req0_thdid_q & (~(xu_mm_ierat_flush_q))) == 1'b1) | (ierat_outptr_q == 2'b01 & ierat_req1_valid_q == 1'b1 & |(ierat_req1_thdid_q & (~(xu_mm_ierat_flush_q))) == 1'b1) | (ierat_outptr_q == 2'b10 & ierat_req2_valid_q == 1'b1 & |(ierat_req2_thdid_q & (~(xu_mm_ierat_flush_q))) == 1'b1) | (ierat_outptr_q == 2'b11 & ierat_req3_valid_q == 1'b1 & |(ierat_req3_thdid_q & (~(xu_mm_ierat_flush_q))) == 1'b1))) ? 1'b1 :
                                   1'b0;
      assign tlb_seq_ierat_req = tlb_seq_ierat_req_q;
      // i-erat queue valid bit is ierat_req<t>_valid_q
      //  tlb_cmp_ierat_dup_val  bits 0:3 are req<t>_tag5_match, 4 is tag5 hit_reload, 5 is stretched hit_reload, 6 is ierat iu5 stage dup
      assign ierat_req0_valid_d = ((ierat_iu5_valid_q == 1'b1 & |(ierat_iu5_thdid_q & (~(ierat_iu3_flush_q)) & (~(xu_mm_ierat_flush_q))) == 1'b1 & ierat_req0_valid_q == 1'b0 & ierat_inptr_q == 2'b00)) ? 1'b1 :
                                  ((ierat_req_taken == 1'b1 & ierat_req0_valid_q == 1'b1 & ierat_outptr_q == 2'b00)) ? 1'b0 :
                                  ((tlb_cmp_ierat_dup_val[0] == 1'b1 & tlb_cmp_ierat_dup_val[4] == 1'b1)) ? 1'b0 :
                                  ierat_req0_valid_q;
      assign ierat_req0_nonspec_d = ((ierat_iu5_valid_q == 1'b1 & |(ierat_iu5_thdid_q & (~(ierat_iu3_flush_q)) & (~(xu_mm_ierat_flush_q))) == 1'b1 & ierat_req0_valid_q == 1'b0 & ierat_inptr_q == 2'b00)) ? ierat_iu5_nonspec_q :
                                    ((ierat_req_taken == 1'b1 & ierat_req0_valid_q == 1'b1 & ierat_outptr_q == 2'b00)) ? 1'b0 :
                                    ((tlb_cmp_ierat_dup_val[0] == 1'b1 & tlb_cmp_ierat_dup_val[4] == 1'b1)) ? 1'b0 :
                                    ierat_req0_nonspec_q;
      assign ierat_req0_thdid_d[0:3] = ((ierat_iu5_valid_q == 1'b1 & ierat_req0_valid_q == 1'b0 & ierat_inptr_q == 2'b00)) ? ierat_iu5_thdid_q :
                                       ierat_req0_thdid_q[0:3];
      assign ierat_req0_epn_d = ((ierat_iu5_valid_q == 1'b1 & ierat_req0_valid_q == 1'b0 & ierat_inptr_q == 2'b00)) ? ierat_iu5_epn_q :
                                ierat_req0_epn_q;
      assign ierat_req0_state_d = ((ierat_iu5_valid_q == 1'b1 & ierat_req0_valid_q == 1'b0 & ierat_inptr_q == 2'b00)) ? ierat_iu5_state_q :
                                  ierat_req0_state_q;
      assign ierat_req0_pid_d = ((ierat_iu5_valid_q == 1'b1 & ierat_req0_valid_q == 1'b0 & ierat_inptr_q == 2'b00)) ? ierat_iu5_pid_q :
                                ierat_req0_pid_q;
      assign ierat_req0_dup_d[0] = 1'b0;
      assign ierat_req0_dup_d[1] = ((ierat_req_taken == 1'b1 & ierat_req0_valid_q == 1'b1 & ierat_outptr_q == 2'b00)) ? 1'b0 :
                                   ((ierat_iu5_valid_q == 1'b1 & ierat_req0_valid_q == 1'b0 & ierat_inptr_q == 2'b00)) ? tlb_cmp_ierat_dup_val[6] :
                                   ((ierat_req0_valid_q == 1'b1 & ierat_req0_dup_q[1] == 1'b0 & tlb_cmp_ierat_dup_val[4] == 1'b0 & tlb_cmp_ierat_dup_val[5] == 1'b1)) ? tlb_cmp_ierat_dup_val[0] :
                                   ierat_req0_dup_q[1];
      assign ierat_req1_valid_d = ((ierat_iu5_valid_q == 1'b1 & |(ierat_iu5_thdid_q & (~(ierat_iu3_flush_q)) & (~(xu_mm_ierat_flush_q))) == 1'b1 & ierat_req1_valid_q == 1'b0 & ierat_inptr_q == 2'b01)) ? 1'b1 :
                                  ((ierat_req_taken == 1'b1 & ierat_req1_valid_q == 1'b1 & ierat_outptr_q == 2'b01)) ? 1'b0 :
                                  ((tlb_cmp_ierat_dup_val[1] == 1'b1 & tlb_cmp_ierat_dup_val[4] == 1'b1)) ? 1'b0 :
                                  ierat_req1_valid_q;
      assign ierat_req1_nonspec_d = ((ierat_iu5_valid_q == 1'b1 & |(ierat_iu5_thdid_q & (~(ierat_iu3_flush_q)) & (~(xu_mm_ierat_flush_q))) == 1'b1 & ierat_req1_valid_q == 1'b0 & ierat_inptr_q == 2'b01)) ? ierat_iu5_nonspec_q :
                                    ((ierat_req_taken == 1'b1 & ierat_req1_valid_q == 1'b1 & ierat_outptr_q == 2'b01)) ? 1'b0 :
                                    ((tlb_cmp_ierat_dup_val[1] == 1'b1 & tlb_cmp_ierat_dup_val[4] == 1'b1)) ? 1'b0 :
                                    ierat_req1_nonspec_q;
      assign ierat_req1_thdid_d[0:3] = ((ierat_iu5_valid_q == 1'b1 & ierat_req1_valid_q == 1'b0 & ierat_inptr_q == 2'b01)) ? ierat_iu5_thdid_q :
                                       ierat_req1_thdid_q[0:3];
      assign ierat_req1_epn_d = ((ierat_iu5_valid_q == 1'b1 & ierat_req1_valid_q == 1'b0 & ierat_inptr_q == 2'b01)) ? ierat_iu5_epn_q :
                                ierat_req1_epn_q;
      assign ierat_req1_state_d = ((ierat_iu5_valid_q == 1'b1 & ierat_req1_valid_q == 1'b0 & ierat_inptr_q == 2'b01)) ? ierat_iu5_state_q :
                                  ierat_req1_state_q;
      assign ierat_req1_pid_d = ((ierat_iu5_valid_q == 1'b1 & ierat_req1_valid_q == 1'b0 & ierat_inptr_q == 2'b01)) ? ierat_iu5_pid_q :
                                ierat_req1_pid_q;
      assign ierat_req1_dup_d[0] = 1'b0;
      assign ierat_req1_dup_d[1] = ((ierat_req_taken == 1'b1 & ierat_req1_valid_q == 1'b1 & ierat_outptr_q == 2'b01)) ? 1'b0 :
                                   ((ierat_iu5_valid_q == 1'b1 & ierat_req1_valid_q == 1'b0 & ierat_inptr_q == 2'b01)) ? tlb_cmp_ierat_dup_val[6] :
                                   ((ierat_req1_valid_q == 1'b1 & ierat_req1_dup_q[1] == 1'b0 & tlb_cmp_ierat_dup_val[4] == 1'b0 & tlb_cmp_ierat_dup_val[5] == 1'b1)) ? tlb_cmp_ierat_dup_val[1] :
                                   ierat_req1_dup_q[1];
      assign ierat_req2_valid_d = ((ierat_iu5_valid_q == 1'b1 & |(ierat_iu5_thdid_q & (~(ierat_iu3_flush_q)) & (~(xu_mm_ierat_flush_q))) == 1'b1 & ierat_req2_valid_q == 1'b0 & ierat_inptr_q == 2'b10)) ? 1'b1 :
                                  ((ierat_req_taken == 1'b1 & ierat_req2_valid_q == 1'b1 & ierat_outptr_q == 2'b10)) ? 1'b0 :
                                  ((tlb_cmp_ierat_dup_val[2] == 1'b1 & tlb_cmp_ierat_dup_val[4] == 1'b1)) ? 1'b0 :
                                  ierat_req2_valid_q;
      assign ierat_req2_nonspec_d = ((ierat_iu5_valid_q == 1'b1 & |(ierat_iu5_thdid_q & (~(ierat_iu3_flush_q)) & (~(xu_mm_ierat_flush_q))) == 1'b1 & ierat_req2_valid_q == 1'b0 & ierat_inptr_q == 2'b10)) ? ierat_iu5_nonspec_q :
                                    ((ierat_req_taken == 1'b1 & ierat_req2_valid_q == 1'b1 & ierat_outptr_q == 2'b10)) ? 1'b0 :
                                    ((tlb_cmp_ierat_dup_val[2] == 1'b1 & tlb_cmp_ierat_dup_val[4] == 1'b1)) ? 1'b0 :
                                    ierat_req2_nonspec_q;
      assign ierat_req2_thdid_d[0:3] = ((ierat_iu5_valid_q == 1'b1 & ierat_req2_valid_q == 1'b0 & ierat_inptr_q == 2'b10)) ? ierat_iu5_thdid_q :
                                       ierat_req2_thdid_q[0:3];
      assign ierat_req2_epn_d = ((ierat_iu5_valid_q == 1'b1 & ierat_req2_valid_q == 1'b0 & ierat_inptr_q == 2'b10)) ? ierat_iu5_epn_q :
                                ierat_req2_epn_q;
      assign ierat_req2_state_d = ((ierat_iu5_valid_q == 1'b1 & ierat_req2_valid_q == 1'b0 & ierat_inptr_q == 2'b10)) ? ierat_iu5_state_q :
                                  ierat_req2_state_q;
      assign ierat_req2_pid_d = ((ierat_iu5_valid_q == 1'b1 & ierat_req2_valid_q == 1'b0 & ierat_inptr_q == 2'b10)) ? ierat_iu5_pid_q :
                                ierat_req2_pid_q;
      assign ierat_req2_dup_d[0] = 1'b0;
      assign ierat_req2_dup_d[1] = ((ierat_req_taken == 1'b1 & ierat_req2_valid_q == 1'b1 & ierat_outptr_q == 2'b10)) ? 1'b0 :
                                   ((ierat_iu5_valid_q == 1'b1 & ierat_req2_valid_q == 1'b0 & ierat_inptr_q == 2'b10)) ? tlb_cmp_ierat_dup_val[6] :
                                   ((ierat_req2_valid_q == 1'b1 & ierat_req2_dup_q[1] == 1'b0 & tlb_cmp_ierat_dup_val[4] == 1'b0 & tlb_cmp_ierat_dup_val[5] == 1'b1)) ? tlb_cmp_ierat_dup_val[2] :
                                   ierat_req2_dup_q[1];
      assign ierat_req3_valid_d = ((ierat_iu5_valid_q == 1'b1 & |(ierat_iu5_thdid_q & (~(ierat_iu3_flush_q)) & (~(xu_mm_ierat_flush_q))) == 1'b1 & ierat_req3_valid_q == 1'b0 & ierat_inptr_q == 2'b11)) ? 1'b1 :
                                  ((ierat_req_taken == 1'b1 & ierat_req3_valid_q == 1'b1 & ierat_outptr_q == 2'b11)) ? 1'b0 :
                                  ((tlb_cmp_ierat_dup_val[3] == 1'b1 & tlb_cmp_ierat_dup_val[4] == 1'b1)) ? 1'b0 :
                                  ierat_req3_valid_q;
      assign ierat_req3_nonspec_d = ((ierat_iu5_valid_q == 1'b1 & |(ierat_iu5_thdid_q & (~(ierat_iu3_flush_q)) & (~(xu_mm_ierat_flush_q))) == 1'b1 & ierat_req3_valid_q == 1'b0 & ierat_inptr_q == 2'b11)) ? ierat_iu5_nonspec_q :
                                    ((ierat_req_taken == 1'b1 & ierat_req3_valid_q == 1'b1 & ierat_outptr_q == 2'b11)) ? 1'b0 :
                                    ((tlb_cmp_ierat_dup_val[3] == 1'b1 & tlb_cmp_ierat_dup_val[4] == 1'b1)) ? 1'b0 :
                                    ierat_req3_nonspec_q;
      assign ierat_req3_thdid_d[0:3] = ((ierat_iu5_valid_q == 1'b1 & ierat_req3_valid_q == 1'b0 & ierat_inptr_q == 2'b11)) ? ierat_iu5_thdid_q :
                                       ierat_req3_thdid_q[0:3];
      assign ierat_req3_epn_d = ((ierat_iu5_valid_q == 1'b1 & ierat_req3_valid_q == 1'b0 & ierat_inptr_q == 2'b11)) ? ierat_iu5_epn_q :
                                ierat_req3_epn_q;
      assign ierat_req3_state_d = ((ierat_iu5_valid_q == 1'b1 & ierat_req3_valid_q == 1'b0 & ierat_inptr_q == 2'b11)) ? ierat_iu5_state_q :
                                  ierat_req3_state_q;
      assign ierat_req3_pid_d = ((ierat_iu5_valid_q == 1'b1 & ierat_req3_valid_q == 1'b0 & ierat_inptr_q == 2'b11)) ? ierat_iu5_pid_q :
                                ierat_req3_pid_q;
      assign ierat_req3_dup_d[0] = 1'b0;
      assign ierat_req3_dup_d[1] = ((ierat_req_taken == 1'b1 & ierat_req3_valid_q == 1'b1 & ierat_outptr_q == 2'b11)) ? 1'b0 :
                                   ((ierat_iu5_valid_q == 1'b1 & ierat_req3_valid_q == 1'b0 & ierat_inptr_q == 2'b11)) ? tlb_cmp_ierat_dup_val[6] :
                                   ((ierat_req3_valid_q == 1'b1 & ierat_req3_dup_q[1] == 1'b0 & tlb_cmp_ierat_dup_val[4] == 1'b0 & tlb_cmp_ierat_dup_val[5] == 1'b1)) ? tlb_cmp_ierat_dup_val[3] :
                                   ierat_req3_dup_q[1];
`ifdef MM_THREADS2
      assign ierat_req_pid_mux = (pid0 & {`PID_WIDTH{iu_mm_ierat_thdid[0]}}) | (pid1 & {`PID_WIDTH{iu_mm_ierat_thdid[1]}});
`else
      assign ierat_req_pid_mux = (pid0 & {`PID_WIDTH{iu_mm_ierat_thdid[0]}});
`endif
      // xu pipe for non-speculative derat flush processing
      assign derat_ex4_valid_d = xu_mm_derat_req;
      assign derat_ex5_valid_d = derat_ex4_valid_q;
      assign derat_ex6_valid_d = derat_ex5_valid_q;

      generate
         if (`RS_DATA_WIDTH == 64)
         begin : gen64_ex4_epn
            assign derat_ex4_epn_d = xu_mm_derat_epn;
         end
      endgenerate

      generate
         if (`RS_DATA_WIDTH < 64)
         begin : gen32_ex4_epn
            assign derat_ex4_epn_d = {1'b0, xu_mm_derat_epn[64 - `RS_DATA_WIDTH:51]};
         end
      endgenerate

      assign derat_ex4_thdid_d = xu_mm_derat_thdid;
      assign derat_ex4_state_d = xu_mm_derat_state;
      assign derat_ex4_ttype_d = xu_mm_derat_ttype;
      assign derat_ex4_pid_d = xu_mm_derat_tid;
      assign derat_ex4_lpid_d = xu_mm_derat_lpid;
      assign derat_ex4_itag_d = lq_mm_derat_req_itag;
      assign derat_ex4_emq_d = lq_mm_derat_req_emq;
      assign derat_ex4_nonspec_d = lq_mm_derat_req_nonspec;
      assign derat_ex5_thdid_d = derat_ex4_thdid_q;
      assign derat_ex5_epn_d = derat_ex4_epn_q;
      assign derat_ex5_state_d = derat_ex4_state_q;
      assign derat_ex5_ttype_d = derat_ex4_ttype_q;
      assign derat_ex5_pid_d = derat_ex4_pid_q;
      assign derat_ex5_itag_d = derat_ex4_itag_q;
      assign derat_ex5_emq_d = derat_ex4_emq_q;
      assign derat_ex5_nonspec_d = derat_ex4_nonspec_q;
      assign derat_ex6_thdid_d = derat_ex5_thdid_q;
      assign derat_ex6_epn_d = derat_ex5_epn_q;
      assign derat_ex6_state_d = derat_ex5_state_q;
      assign derat_ex6_ttype_d = derat_ex5_ttype_q;
      assign derat_ex6_pid_d = derat_ex5_pid_q;
      assign derat_ex6_itag_d = derat_ex5_itag_q;
      assign derat_ex6_emq_d = derat_ex5_emq_q;
      assign derat_ex6_nonspec_d = derat_ex5_nonspec_q;
      // use derat lpid for external pid ops
      assign derat_ex5_lpid_d = (derat_ex4_valid_q == 1'b1 & derat_ex4_ttype_q[0] == 1'b1) ? derat_ex4_lpid_q :
                                lpidr;
      assign derat_ex6_lpid_d = (derat_ex5_valid_q == 1'b1 & derat_ex5_ttype_q[0] == 1'b1) ? derat_ex5_lpid_q :
                                lpidr;

      // derat request queue logic pointers
      assign derat_inptr_d = (derat_inptr_q == 2'b00 & derat_req1_valid_q == 1'b0 & derat_ex6_valid_q == 1'b1) ? 2'b01 :
                             (derat_inptr_q == 2'b00 & derat_req2_valid_q == 1'b0 & derat_ex6_valid_q == 1'b1) ? 2'b10 :
                             (derat_inptr_q == 2'b00 & derat_req3_valid_q == 1'b0 & derat_ex6_valid_q == 1'b1) ? 2'b11 :
                             (derat_inptr_q == 2'b01 & derat_req2_valid_q == 1'b0 & derat_ex6_valid_q == 1'b1) ? 2'b10 :
                             (derat_inptr_q == 2'b01 & derat_req3_valid_q == 1'b0 & derat_ex6_valid_q == 1'b1) ? 2'b11 :
                             (derat_inptr_q == 2'b01 & derat_req0_valid_q == 1'b0 & derat_ex6_valid_q == 1'b1) ? 2'b00 :
                             (derat_inptr_q == 2'b10 & derat_req3_valid_q == 1'b0 & derat_ex6_valid_q == 1'b1) ? 2'b11 :
                             (derat_inptr_q == 2'b10 & derat_req0_valid_q == 1'b0 & derat_ex6_valid_q == 1'b1) ? 2'b00 :
                             (derat_inptr_q == 2'b10 & derat_req1_valid_q == 1'b0 & derat_ex6_valid_q == 1'b1) ? 2'b01 :
                             (derat_inptr_q == 2'b11 & derat_req0_valid_q == 1'b0 & derat_ex6_valid_q == 1'b1) ? 2'b00 :
                             (derat_inptr_q == 2'b11 & derat_req1_valid_q == 1'b0 & derat_ex6_valid_q == 1'b1) ? 2'b01 :
                             (derat_inptr_q == 2'b11 & derat_req2_valid_q == 1'b0 & derat_ex6_valid_q == 1'b1) ? 2'b10 :
                             (derat_req_taken == 1'b1) ? derat_outptr_q :
                             derat_inptr_q;

      assign derat_outptr_d = (derat_outptr_q == 2'b00 & derat_req0_valid_q == 1'b1 & derat_req_taken == 1'b1) ? 2'b01 :
                              (derat_outptr_q == 2'b01 & derat_req1_valid_q == 1'b1 & derat_req_taken == 1'b1) ? 2'b10 :
                              (derat_outptr_q == 2'b10 & derat_req2_valid_q == 1'b1 & derat_req_taken == 1'b1) ? 2'b11 :
                              (derat_outptr_q == 2'b11 & derat_req3_valid_q == 1'b1 & derat_req_taken == 1'b1) ? 2'b00 :
                              (derat_outptr_q == 2'b00 & derat_req0_valid_q == 1'b0 & derat_req1_valid_q == 1'b1) ? 2'b01 :
                              (derat_outptr_q == 2'b00 & derat_req0_valid_q == 1'b0 & derat_req1_valid_q == 1'b0 & derat_req2_valid_q == 1'b1) ? 2'b10 :
                              (derat_outptr_q == 2'b00 & derat_req0_valid_q == 1'b0 & derat_req1_valid_q == 1'b0 & derat_req2_valid_q == 1'b0 & derat_req3_valid_q == 1'b1) ? 2'b11 :
                              (derat_outptr_q == 2'b01 & derat_req1_valid_q == 1'b0 & derat_req2_valid_q == 1'b1) ? 2'b10 :
                              (derat_outptr_q == 2'b01 & derat_req1_valid_q == 1'b0 & derat_req2_valid_q == 1'b0 & derat_req3_valid_q == 1'b1) ? 2'b11 :
                              (derat_outptr_q == 2'b01 & derat_req1_valid_q == 1'b0 & derat_req2_valid_q == 1'b0 & derat_req3_valid_q == 1'b0 & derat_req0_valid_q == 1'b1) ? 2'b00 :
                              (derat_outptr_q == 2'b10 & derat_req2_valid_q == 1'b0 & derat_req3_valid_q == 1'b1) ? 2'b11 :
                              (derat_outptr_q == 2'b10 & derat_req2_valid_q == 1'b0 & derat_req3_valid_q == 1'b0 & derat_req0_valid_q == 1'b1) ? 2'b00 :
                              (derat_outptr_q == 2'b10 & derat_req2_valid_q == 1'b0 & derat_req3_valid_q == 1'b0 & derat_req0_valid_q == 1'b0 & derat_req1_valid_q == 1'b1) ? 2'b01 :
                              (derat_outptr_q == 2'b11 & derat_req3_valid_q == 1'b0 & derat_req0_valid_q == 1'b1) ? 2'b00 :
                              (derat_outptr_q == 2'b11 & derat_req3_valid_q == 1'b0 & derat_req0_valid_q == 1'b0 & derat_req1_valid_q == 1'b1) ? 2'b01 :
                              (derat_outptr_q == 2'b11 & derat_req3_valid_q == 1'b0 & derat_req0_valid_q == 1'b0 & derat_req1_valid_q == 1'b0 & derat_req2_valid_q == 1'b1) ? 2'b10 :
                              derat_outptr_q;

      assign tlb_seq_derat_req_d = (((derat_outptr_q == 2'b00 & derat_req0_valid_q == 1'b1) | (derat_outptr_q == 2'b01 & derat_req1_valid_q == 1'b1) | (derat_outptr_q == 2'b10 & derat_req2_valid_q == 1'b1) | (derat_outptr_q == 2'b11 & derat_req3_valid_q == 1'b1))) ? 1'b1 :
                                   1'b0;
      assign tlb_seq_derat_req = tlb_seq_derat_req_q;
      // d-erat queue valid bit is derat_req<t>_valid_q
      //  tlb_cmp_derat_dup_val  : in std_ulogic_vector(0 to 6); -- bit 4 hit/miss pulse, 5 is stretched hit/miss, 6 is ex6 dup
      assign derat_req0_valid_d = ((derat_ex6_valid_q == 1'b1 & derat_req0_valid_q == 1'b0 & derat_inptr_q == 2'b00)) ? 1'b1 :
                                  ((derat_req_taken == 1'b1 & derat_req0_valid_q == 1'b1 & derat_outptr_q == 2'b00)) ? 1'b0 :
                                  ((tlb_cmp_derat_dup_val[0] == 1'b1 & tlb_cmp_derat_dup_val[4] == 1'b1)) ? 1'b0 :
                                  derat_req0_valid_q;
      assign derat_req0_thdid_d[0:3] = ((derat_ex6_valid_q == 1'b1 & derat_req0_valid_q == 1'b0 & derat_inptr_q == 2'b00)) ? derat_ex6_thdid_q :
                                       derat_req0_thdid_q[0:3];
      assign derat_req0_epn_d = ((derat_ex6_valid_q == 1'b1 & derat_req0_valid_q == 1'b0 & derat_inptr_q == 2'b00)) ? derat_ex6_epn_q :
                                derat_req0_epn_q;
      assign derat_req0_state_d = ((derat_ex6_valid_q == 1'b1 & derat_req0_valid_q == 1'b0 & derat_inptr_q == 2'b00)) ? derat_ex6_state_q :
                                  derat_req0_state_q;
      assign derat_req0_ttype_d = ((derat_ex6_valid_q == 1'b1 & derat_req0_valid_q == 1'b0 & derat_inptr_q == 2'b00)) ? derat_ex6_ttype_q :
                                  derat_req0_ttype_q;
      assign derat_req0_pid_d = ((derat_ex6_valid_q == 1'b1 & derat_req0_valid_q == 1'b0 & derat_inptr_q == 2'b00)) ? derat_ex6_pid_q :
                                derat_req0_pid_q;
      assign derat_req0_lpid_d = ((derat_ex6_valid_q == 1'b1 & derat_req0_valid_q == 1'b0 & derat_inptr_q == 2'b00)) ? derat_ex6_lpid_q :
                                 derat_req0_lpid_q;
      assign derat_req0_dup_d[0] = 1'b0;
      assign derat_req0_dup_d[1] = ((derat_req_taken == 1'b1 & derat_req0_valid_q == 1'b1 & derat_outptr_q == 2'b00)) ? 1'b0 :
                                   ((derat_ex6_valid_q == 1'b1 & derat_req0_valid_q == 1'b0 & derat_inptr_q == 2'b00)) ? tlb_cmp_derat_dup_val[6] :
                                   ((derat_req0_valid_q == 1'b1 & derat_req0_dup_q[1] == 1'b0 & tlb_cmp_derat_dup_val[4] == 1'b0 & tlb_cmp_derat_dup_val[5] == 1'b1)) ? tlb_cmp_derat_dup_val[0] :
                                   derat_req0_dup_q[1];
      assign derat_req0_itag_d = ((derat_ex6_valid_q == 1'b1 & derat_req0_valid_q == 1'b0 & derat_inptr_q == 2'b00)) ? derat_ex6_itag_q :
                                 derat_req0_itag_q;
      assign derat_req0_emq_d = ((derat_ex6_valid_q == 1'b1 & derat_req0_valid_q == 1'b0 & derat_inptr_q == 2'b00)) ? derat_ex6_emq_q :
                                derat_req0_emq_q;
      assign derat_req0_nonspec_d = ((derat_ex6_valid_q == 1'b1 & derat_req0_valid_q == 1'b0 & derat_inptr_q == 2'b00)) ? derat_ex6_nonspec_q :
                                    ((derat_req_taken == 1'b1 & derat_req0_valid_q == 1'b1 & derat_outptr_q == 2'b00)) ? 1'b0 :
                                    ((tlb_cmp_derat_dup_val[0] == 1'b1 & tlb_cmp_derat_dup_val[4] == 1'b1)) ? 1'b0 :
                                    derat_req0_nonspec_q;
      assign derat_req1_valid_d = ((derat_ex6_valid_q == 1'b1 & derat_req1_valid_q == 1'b0 & derat_inptr_q == 2'b01)) ? 1'b1 :
                                  ((derat_req_taken == 1'b1 & derat_req1_valid_q == 1'b1 & derat_outptr_q == 2'b01)) ? 1'b0 :
                                  ((tlb_cmp_derat_dup_val[1] == 1'b1 & tlb_cmp_derat_dup_val[4] == 1'b1)) ? 1'b0 :
                                  derat_req1_valid_q;
      assign derat_req1_thdid_d[0:3] = ((derat_ex6_valid_q == 1'b1 & derat_req1_valid_q == 1'b0 & derat_inptr_q == 2'b01)) ? derat_ex6_thdid_q :
                                       derat_req1_thdid_q[0:3];
      assign derat_req1_epn_d = ((derat_ex6_valid_q == 1'b1 & derat_req1_valid_q == 1'b0 & derat_inptr_q == 2'b01)) ? derat_ex6_epn_q :
                                derat_req1_epn_q;
      assign derat_req1_state_d = ((derat_ex6_valid_q == 1'b1 & derat_req1_valid_q == 1'b0 & derat_inptr_q == 2'b01)) ? derat_ex6_state_q :
                                  derat_req1_state_q;
      assign derat_req1_ttype_d = ((derat_ex6_valid_q == 1'b1 & derat_req1_valid_q == 1'b0 & derat_inptr_q == 2'b01)) ? derat_ex6_ttype_q :
                                  derat_req1_ttype_q;
      assign derat_req1_pid_d = ((derat_ex6_valid_q == 1'b1 & derat_req1_valid_q == 1'b0 & derat_inptr_q == 2'b01)) ? derat_ex6_pid_q :
                                derat_req1_pid_q;
      assign derat_req1_lpid_d = ((derat_ex6_valid_q == 1'b1 & derat_req1_valid_q == 1'b0 & derat_inptr_q == 2'b01)) ? derat_ex6_lpid_q :
                                 derat_req1_lpid_q;
      assign derat_req1_dup_d[0] = 1'b0;
      assign derat_req1_dup_d[1] = ((derat_req_taken == 1'b1 & derat_req1_valid_q == 1'b1 & derat_outptr_q == 2'b01)) ? 1'b0 :
                                   ((derat_ex6_valid_q == 1'b1 & derat_req1_valid_q == 1'b0 & derat_inptr_q == 2'b01)) ? tlb_cmp_derat_dup_val[6] :
                                   ((derat_req1_valid_q == 1'b1 & derat_req1_dup_q[1] == 1'b0 & tlb_cmp_derat_dup_val[4] == 1'b0 & tlb_cmp_derat_dup_val[5] == 1'b1)) ? tlb_cmp_derat_dup_val[1] :
                                   derat_req1_dup_q[1];
      assign derat_req1_itag_d = ((derat_ex6_valid_q == 1'b1 & derat_req1_valid_q == 1'b0 & derat_inptr_q == 2'b01)) ? derat_ex6_itag_q :
                                 derat_req1_itag_q;
      assign derat_req1_emq_d = ((derat_ex6_valid_q == 1'b1 & derat_req1_valid_q == 1'b0 & derat_inptr_q == 2'b01)) ? derat_ex6_emq_q :
                                derat_req1_emq_q;
      assign derat_req1_nonspec_d = ((derat_ex6_valid_q == 1'b1 & derat_req1_valid_q == 1'b0 & derat_inptr_q == 2'b01)) ? derat_ex6_nonspec_q :
                                    ((derat_req_taken == 1'b1 & derat_req1_valid_q == 1'b1 & derat_outptr_q == 2'b01)) ? 1'b0 :
                                    ((tlb_cmp_derat_dup_val[1] == 1'b1 & tlb_cmp_derat_dup_val[4] == 1'b1)) ? 1'b0 :
                                    derat_req1_nonspec_q;
      assign derat_req2_valid_d = ((derat_ex6_valid_q == 1'b1 & derat_req2_valid_q == 1'b0 & derat_inptr_q == 2'b10)) ? 1'b1 :
                                  ((derat_req_taken == 1'b1 & derat_req2_valid_q == 1'b1 & derat_outptr_q == 2'b10)) ? 1'b0 :
                                  ((tlb_cmp_derat_dup_val[2] == 1'b1 & tlb_cmp_derat_dup_val[4] == 1'b1)) ? 1'b0 :
                                  derat_req2_valid_q;
      assign derat_req2_thdid_d[0:3] = ((derat_ex6_valid_q == 1'b1 & derat_req2_valid_q == 1'b0 & derat_inptr_q == 2'b10)) ? derat_ex6_thdid_q :
                                       derat_req2_thdid_q[0:3];
      assign derat_req2_epn_d = ((derat_ex6_valid_q == 1'b1 & derat_req2_valid_q == 1'b0 & derat_inptr_q == 2'b10)) ? derat_ex6_epn_q :
                                derat_req2_epn_q;
      assign derat_req2_state_d = ((derat_ex6_valid_q == 1'b1 & derat_req2_valid_q == 1'b0 & derat_inptr_q == 2'b10)) ? derat_ex6_state_q :
                                  derat_req2_state_q;
      assign derat_req2_ttype_d = ((derat_ex6_valid_q == 1'b1 & derat_req2_valid_q == 1'b0 & derat_inptr_q == 2'b10)) ? derat_ex6_ttype_q :
                                  derat_req2_ttype_q;
      assign derat_req2_pid_d = ((derat_ex6_valid_q == 1'b1 & derat_req2_valid_q == 1'b0 & derat_inptr_q == 2'b10)) ? derat_ex6_pid_q :
                                derat_req2_pid_q;
      assign derat_req2_lpid_d = ((derat_ex6_valid_q == 1'b1 & derat_req2_valid_q == 1'b0 & derat_inptr_q == 2'b10)) ? derat_ex6_lpid_q :
                                 derat_req2_lpid_q;
      assign derat_req2_dup_d[0] = 1'b0;
      assign derat_req2_dup_d[1] = ((derat_req_taken == 1'b1 & derat_req2_valid_q == 1'b1 & derat_outptr_q == 2'b10)) ? 1'b0 :
                                   ((derat_ex6_valid_q == 1'b1 & derat_req2_valid_q == 1'b0 & derat_inptr_q == 2'b10)) ? tlb_cmp_derat_dup_val[6] :
                                   ((derat_req2_valid_q == 1'b1 & derat_req2_dup_q[1] == 1'b0 & tlb_cmp_derat_dup_val[4] == 1'b0 & tlb_cmp_derat_dup_val[5] == 1'b1)) ? tlb_cmp_derat_dup_val[2] :
                                   derat_req2_dup_q[1];
      assign derat_req2_itag_d = ((derat_ex6_valid_q == 1'b1 & derat_req2_valid_q == 1'b0 & derat_inptr_q == 2'b10)) ? derat_ex6_itag_q :
                                 derat_req2_itag_q;
      assign derat_req2_emq_d = ((derat_ex6_valid_q == 1'b1 & derat_req2_valid_q == 1'b0 & derat_inptr_q == 2'b10)) ? derat_ex6_emq_q :
                                derat_req2_emq_q;
      assign derat_req2_nonspec_d = ((derat_ex6_valid_q == 1'b1 & derat_req2_valid_q == 1'b0 & derat_inptr_q == 2'b10)) ? derat_ex6_nonspec_q :
                                    ((derat_req_taken == 1'b1 & derat_req2_valid_q == 1'b1 & derat_outptr_q == 2'b10)) ? 1'b0 :
                                    ((tlb_cmp_derat_dup_val[2] == 1'b1 & tlb_cmp_derat_dup_val[4] == 1'b1)) ? 1'b0 :
                                    derat_req2_nonspec_q;
      assign derat_req3_valid_d = ((derat_ex6_valid_q == 1'b1 & derat_req3_valid_q == 1'b0 & derat_inptr_q == 2'b11)) ? 1'b1 :
                                  ((derat_req_taken == 1'b1 & derat_req3_valid_q == 1'b1 & derat_outptr_q == 2'b11)) ? 1'b0 :
                                  ((tlb_cmp_derat_dup_val[3] == 1'b1 & tlb_cmp_derat_dup_val[4] == 1'b1)) ? 1'b0 :
                                  derat_req3_valid_q;
      assign derat_req3_thdid_d[0:3] = ((derat_ex6_valid_q == 1'b1 & derat_req3_valid_q == 1'b0 & derat_inptr_q == 2'b11)) ? derat_ex6_thdid_q :
                                       derat_req3_thdid_q[0:3];
      assign derat_req3_epn_d = ((derat_ex6_valid_q == 1'b1 & derat_req3_valid_q == 1'b0 & derat_inptr_q == 2'b11)) ? derat_ex6_epn_q :
                                derat_req3_epn_q;
      assign derat_req3_state_d = ((derat_ex6_valid_q == 1'b1 & derat_req3_valid_q == 1'b0 & derat_inptr_q == 2'b11)) ? derat_ex6_state_q :
                                  derat_req3_state_q;
      assign derat_req3_ttype_d = ((derat_ex6_valid_q == 1'b1 & derat_req3_valid_q == 1'b0 & derat_inptr_q == 2'b11)) ? derat_ex6_ttype_q :
                                  derat_req3_ttype_q;
      assign derat_req3_pid_d = ((derat_ex6_valid_q == 1'b1 & derat_req3_valid_q == 1'b0 & derat_inptr_q == 2'b11)) ? derat_ex6_pid_q :
                                derat_req3_pid_q;
      assign derat_req3_lpid_d = ((derat_ex6_valid_q == 1'b1 & derat_req3_valid_q == 1'b0 & derat_inptr_q == 2'b11)) ? derat_ex6_lpid_q :
                                 derat_req3_lpid_q;
      assign derat_req3_dup_d[0] = 1'b0;
      assign derat_req3_dup_d[1] = ((derat_req_taken == 1'b1 & derat_req3_valid_q == 1'b1 & derat_outptr_q == 2'b11)) ? 1'b0 :
                                   ((derat_ex6_valid_q == 1'b1 & derat_req3_valid_q == 1'b0 & derat_inptr_q == 2'b11)) ? tlb_cmp_derat_dup_val[6] :
                                   ((derat_req3_valid_q == 1'b1 & derat_req3_dup_q[1] == 1'b0 & tlb_cmp_derat_dup_val[4] == 1'b0 & tlb_cmp_derat_dup_val[5] == 1'b1)) ? tlb_cmp_derat_dup_val[3] :
                                   derat_req3_dup_q[1];
      assign derat_req3_itag_d = ((derat_ex6_valid_q == 1'b1 & derat_req3_valid_q == 1'b0 & derat_inptr_q == 2'b11)) ? derat_ex6_itag_q :
                                 derat_req3_itag_q;
      assign derat_req3_emq_d = ((derat_ex6_valid_q == 1'b1 & derat_req3_valid_q == 1'b0 & derat_inptr_q == 2'b11)) ? derat_ex6_emq_q :
                                derat_req3_emq_q;
      assign derat_req3_nonspec_d = ((derat_ex6_valid_q == 1'b1 & derat_req3_valid_q == 1'b0 & derat_inptr_q == 2'b11)) ? derat_ex6_nonspec_q :
                                    ((derat_req_taken == 1'b1 & derat_req3_valid_q == 1'b1 & derat_outptr_q == 2'b11)) ? 1'b0 :
                                    ((tlb_cmp_derat_dup_val[3] == 1'b1 & tlb_cmp_derat_dup_val[4] == 1'b1)) ? 1'b0 :
                                    derat_req3_nonspec_q;
      //---------------------------------------------------------------------
      // output assignments
      //---------------------------------------------------------------------
      assign ierat_req_epn = ((ierat_outptr_q == 2'b01)) ? ierat_req1_epn_q :
                             ((ierat_outptr_q == 2'b10)) ? ierat_req2_epn_q :
                             ((ierat_outptr_q == 2'b11)) ? ierat_req3_epn_q :
                             ierat_req0_epn_q;
      assign ierat_req_pid = ((ierat_outptr_q == 2'b01)) ? ierat_req1_pid_q :
                             ((ierat_outptr_q == 2'b10)) ? ierat_req2_pid_q :
                             ((ierat_outptr_q == 2'b11)) ? ierat_req3_pid_q :
                             ierat_req0_pid_q;
      assign ierat_req_state = ((ierat_outptr_q == 2'b01)) ? ierat_req1_state_q :
                               ((ierat_outptr_q == 2'b10)) ? ierat_req2_state_q :
                               ((ierat_outptr_q == 2'b11)) ? ierat_req3_state_q :
                               ierat_req0_state_q;
      assign ierat_req_thdid = ((ierat_outptr_q == 2'b01)) ? ierat_req1_thdid_q[0:`THDID_WIDTH - 1] :
                               ((ierat_outptr_q == 2'b10)) ? ierat_req2_thdid_q[0:`THDID_WIDTH - 1] :
                               ((ierat_outptr_q == 2'b11)) ? ierat_req3_thdid_q[0:`THDID_WIDTH - 1] :
                               ierat_req0_thdid_q[0:`THDID_WIDTH - 1];
      assign ierat_req_dup = ((ierat_outptr_q == 2'b01)) ? ierat_req1_dup_q[0:1] :
                             ((ierat_outptr_q == 2'b10)) ? ierat_req2_dup_q[0:1] :
                             ((ierat_outptr_q == 2'b11)) ? ierat_req3_dup_q[0:1] :
                             ierat_req0_dup_q[0:1];
      assign ierat_req_nonspec = ((ierat_outptr_q == 2'b01)) ? ierat_req1_nonspec_q :
                                 ((ierat_outptr_q == 2'b10)) ? ierat_req2_nonspec_q :
                                 ((ierat_outptr_q == 2'b11)) ? ierat_req3_nonspec_q :
                                 ierat_req0_nonspec_q;
      assign derat_req_epn = ((derat_outptr_q == 2'b01)) ? derat_req1_epn_q :
                             ((derat_outptr_q == 2'b10)) ? derat_req2_epn_q :
                             ((derat_outptr_q == 2'b11)) ? derat_req3_epn_q :
                             derat_req0_epn_q;
      assign derat_req_pid = ((derat_outptr_q == 2'b01)) ? derat_req1_pid_q :
                             ((derat_outptr_q == 2'b10)) ? derat_req2_pid_q :
                             ((derat_outptr_q == 2'b11)) ? derat_req3_pid_q :
                             derat_req0_pid_q;
      assign derat_req_lpid = ((derat_outptr_q == 2'b01)) ? derat_req1_lpid_q :
                              ((derat_outptr_q == 2'b10)) ? derat_req2_lpid_q :
                              ((derat_outptr_q == 2'b11)) ? derat_req3_lpid_q :
                              derat_req0_lpid_q;
      assign derat_req_state = ((derat_outptr_q == 2'b01)) ? derat_req1_state_q :
                               ((derat_outptr_q == 2'b10)) ? derat_req2_state_q :
                               ((derat_outptr_q == 2'b11)) ? derat_req3_state_q :
                               derat_req0_state_q;
      assign derat_req_ttype = ((derat_outptr_q == 2'b01)) ? derat_req1_ttype_q :
                               ((derat_outptr_q == 2'b10)) ? derat_req2_ttype_q :
                               ((derat_outptr_q == 2'b11)) ? derat_req3_ttype_q :
                               derat_req0_ttype_q;
      assign derat_req_thdid = ((derat_outptr_q == 2'b01)) ? derat_req1_thdid_q[0:`THDID_WIDTH - 1] :
                               ((derat_outptr_q == 2'b10)) ? derat_req2_thdid_q[0:`THDID_WIDTH - 1] :
                               ((derat_outptr_q == 2'b11)) ? derat_req3_thdid_q[0:`THDID_WIDTH - 1] :
                               derat_req0_thdid_q[0:`THDID_WIDTH - 1];
      assign derat_req_dup = ((derat_outptr_q == 2'b01)) ? derat_req1_dup_q[0:1] :
                             ((derat_outptr_q == 2'b10)) ? derat_req2_dup_q[0:1] :
                             ((derat_outptr_q == 2'b11)) ? derat_req3_dup_q[0:1] :
                             derat_req0_dup_q[0:1];
      assign derat_req_itag = ((derat_outptr_q == 2'b01)) ? derat_req1_itag_q :
                              ((derat_outptr_q == 2'b10)) ? derat_req2_itag_q :
                              ((derat_outptr_q == 2'b11)) ? derat_req3_itag_q :
                              derat_req0_itag_q;
      assign derat_req_emq = ((derat_outptr_q == 2'b01)) ? derat_req1_emq_q :
                             ((derat_outptr_q == 2'b10)) ? derat_req2_emq_q :
                             ((derat_outptr_q == 2'b11)) ? derat_req3_emq_q :
                             derat_req0_emq_q;
      assign derat_req_nonspec = ((derat_outptr_q == 2'b01)) ? derat_req1_nonspec_q :
                                 ((derat_outptr_q == 2'b10)) ? derat_req2_nonspec_q :
                                 ((derat_outptr_q == 2'b11)) ? derat_req3_nonspec_q :
                                 derat_req0_nonspec_q;
      assign ierat_req0_pid = ierat_req0_pid_q;
      assign ierat_req0_gs = ierat_req0_state_q[1];
      assign ierat_req0_as = ierat_req0_state_q[2];
      assign ierat_req0_epn = ierat_req0_epn_q;
      assign ierat_req0_thdid = ierat_req0_thdid_q;
      assign ierat_req0_valid = ierat_req0_valid_q;
      assign ierat_req0_nonspec = ierat_req0_nonspec_q;
      assign ierat_req1_pid = ierat_req1_pid_q;
      assign ierat_req1_gs = ierat_req1_state_q[1];
      assign ierat_req1_as = ierat_req1_state_q[2];
      assign ierat_req1_epn = ierat_req1_epn_q;
      assign ierat_req1_thdid = ierat_req1_thdid_q;
      assign ierat_req1_valid = ierat_req1_valid_q;
      assign ierat_req1_nonspec = ierat_req1_nonspec_q;
      assign ierat_req2_pid = ierat_req2_pid_q;
      assign ierat_req2_gs = ierat_req2_state_q[1];
      assign ierat_req2_as = ierat_req2_state_q[2];
      assign ierat_req2_epn = ierat_req2_epn_q;
      assign ierat_req2_thdid = ierat_req2_thdid_q;
      assign ierat_req2_valid = ierat_req2_valid_q;
      assign ierat_req2_nonspec = ierat_req2_nonspec_q;
      assign ierat_req3_pid = ierat_req3_pid_q;
      assign ierat_req3_gs = ierat_req3_state_q[1];
      assign ierat_req3_as = ierat_req3_state_q[2];
      assign ierat_req3_epn = ierat_req3_epn_q;
      assign ierat_req3_thdid = ierat_req3_thdid_q;
      assign ierat_req3_valid = ierat_req3_valid_q;
      assign ierat_req3_nonspec = ierat_req3_nonspec_q;
      assign ierat_iu4_pid = ierat_iu4_pid_q;
      assign ierat_iu4_gs = ierat_iu4_state_q[1];
      assign ierat_iu4_as = ierat_iu4_state_q[2];
      assign ierat_iu4_epn = ierat_iu4_epn_q;
      assign ierat_iu4_thdid = ierat_iu4_thdid_q;
      assign ierat_iu4_valid = ierat_iu4_valid_q;
      assign derat_req0_lpid = derat_req0_lpid_q;
      assign derat_req0_pid = derat_req0_pid_q;
      assign derat_req0_gs = derat_req0_state_q[1];
      assign derat_req0_as = derat_req0_state_q[2];
      assign derat_req0_epn = derat_req0_epn_q;
      assign derat_req0_thdid = derat_req0_thdid_q;
      assign derat_req0_emq = derat_req0_emq_q;
      assign derat_req0_valid = derat_req0_valid_q;
      assign derat_req0_nonspec = derat_req0_nonspec_q;
      assign derat_req1_lpid = derat_req1_lpid_q;
      assign derat_req1_pid = derat_req1_pid_q;
      assign derat_req1_gs = derat_req1_state_q[1];
      assign derat_req1_as = derat_req1_state_q[2];
      assign derat_req1_epn = derat_req1_epn_q;
      assign derat_req1_thdid = derat_req1_thdid_q;
      assign derat_req1_emq = derat_req1_emq_q;
      assign derat_req1_valid = derat_req1_valid_q;
      assign derat_req1_nonspec = derat_req1_nonspec_q;
      assign derat_req2_lpid = derat_req2_lpid_q;
      assign derat_req2_pid = derat_req2_pid_q;
      assign derat_req2_gs = derat_req2_state_q[1];
      assign derat_req2_as = derat_req2_state_q[2];
      assign derat_req2_epn = derat_req2_epn_q;
      assign derat_req2_thdid = derat_req2_thdid_q;
      assign derat_req2_emq = derat_req2_emq_q;
      assign derat_req2_valid = derat_req2_valid_q;
      assign derat_req2_nonspec = derat_req2_nonspec_q;
      assign derat_req3_lpid = derat_req3_lpid_q;
      assign derat_req3_pid = derat_req3_pid_q;
      assign derat_req3_gs = derat_req3_state_q[1];
      assign derat_req3_as = derat_req3_state_q[2];
      assign derat_req3_epn = derat_req3_epn_q;
      assign derat_req3_thdid = derat_req3_thdid_q;
      assign derat_req3_emq = derat_req3_emq_q;
      assign derat_req3_valid = derat_req3_valid_q;
      assign derat_req3_nonspec = derat_req3_nonspec_q;
      assign derat_ex5_lpid = derat_ex5_lpid_q;
      assign derat_ex5_pid = derat_ex5_pid_q;
      assign derat_ex5_gs = derat_ex5_state_q[1];
      assign derat_ex5_as = derat_ex5_state_q[2];
      assign derat_ex5_epn = derat_ex5_epn_q;
      assign derat_ex5_thdid = derat_ex5_thdid_q;
      assign derat_ex5_valid = derat_ex5_valid_q;
      assign tlb_req_dbg_ierat_iu5_valid_q = ierat_iu5_valid_q;
      assign tlb_req_dbg_ierat_iu5_thdid[0] = ierat_iu5_thdid_q[2] | ierat_iu5_thdid_q[3];
      assign tlb_req_dbg_ierat_iu5_thdid[1] = ierat_iu5_thdid_q[1] | ierat_iu5_thdid_q[3];
      assign tlb_req_dbg_ierat_iu5_state_q = ierat_iu5_state_q;
      assign tlb_req_dbg_ierat_inptr_q = ierat_inptr_q;
      assign tlb_req_dbg_ierat_outptr_q = ierat_outptr_q;
      assign tlb_req_dbg_ierat_req_valid_q = {ierat_req0_valid_q, ierat_req1_valid_q, ierat_req2_valid_q, ierat_req3_valid_q};
      assign tlb_req_dbg_ierat_req_nonspec_q = {ierat_req0_nonspec_q, ierat_req1_nonspec_q, ierat_req2_nonspec_q, ierat_req3_nonspec_q};
      assign tlb_req_dbg_ierat_req_thdid[0] = ierat_req0_thdid_q[2] | ierat_req0_thdid_q[3];
      assign tlb_req_dbg_ierat_req_thdid[1] = ierat_req0_thdid_q[1] | ierat_req0_thdid_q[3];
      assign tlb_req_dbg_ierat_req_thdid[2] = ierat_req1_thdid_q[2] | ierat_req1_thdid_q[3];
      assign tlb_req_dbg_ierat_req_thdid[3] = ierat_req1_thdid_q[1] | ierat_req1_thdid_q[3];
      assign tlb_req_dbg_ierat_req_thdid[4] = ierat_req2_thdid_q[2] | ierat_req2_thdid_q[3];
      assign tlb_req_dbg_ierat_req_thdid[5] = ierat_req2_thdid_q[1] | ierat_req2_thdid_q[3];
      assign tlb_req_dbg_ierat_req_thdid[6] = ierat_req3_thdid_q[2] | ierat_req3_thdid_q[3];
      assign tlb_req_dbg_ierat_req_thdid[7] = ierat_req3_thdid_q[1] | ierat_req3_thdid_q[3];
      assign tlb_req_dbg_ierat_req_dup_q = {ierat_req0_dup_q[1], ierat_req1_dup_q[1], ierat_req2_dup_q[1], ierat_req3_dup_q[1]};
      assign tlb_req_dbg_derat_ex6_valid_q = derat_ex6_valid_q;
      assign tlb_req_dbg_derat_ex6_thdid[0] = derat_ex6_thdid_q[2] | derat_ex6_thdid_q[3];
      assign tlb_req_dbg_derat_ex6_thdid[1] = derat_ex6_thdid_q[1] | derat_ex6_thdid_q[3];
      assign tlb_req_dbg_derat_ex6_state_q = derat_ex6_state_q;
      assign tlb_req_dbg_derat_inptr_q = derat_inptr_q;
      assign tlb_req_dbg_derat_outptr_q = derat_outptr_q;
      assign tlb_req_dbg_derat_req_valid_q = {derat_req0_valid_q, derat_req1_valid_q, derat_req2_valid_q, derat_req3_valid_q};
      assign tlb_req_dbg_derat_req_thdid[0] = derat_req0_thdid_q[2] | derat_req0_thdid_q[3];
      assign tlb_req_dbg_derat_req_thdid[1] = derat_req0_thdid_q[1] | derat_req0_thdid_q[3];
      assign tlb_req_dbg_derat_req_thdid[2] = derat_req1_thdid_q[2] | derat_req1_thdid_q[3];
      assign tlb_req_dbg_derat_req_thdid[3] = derat_req1_thdid_q[1] | derat_req1_thdid_q[3];
      assign tlb_req_dbg_derat_req_thdid[4] = derat_req2_thdid_q[2] | derat_req2_thdid_q[3];
      assign tlb_req_dbg_derat_req_thdid[5] = derat_req2_thdid_q[1] | derat_req2_thdid_q[3];
      assign tlb_req_dbg_derat_req_thdid[6] = derat_req3_thdid_q[2] | derat_req3_thdid_q[3];
      assign tlb_req_dbg_derat_req_thdid[7] = derat_req3_thdid_q[1] | derat_req3_thdid_q[3];
      assign tlb_req_dbg_derat_req_ttype_q[0:1] = derat_req0_ttype_q[0:1];
      assign tlb_req_dbg_derat_req_ttype_q[2:3] = derat_req1_ttype_q[0:1];
      assign tlb_req_dbg_derat_req_ttype_q[4:5] = derat_req2_ttype_q[0:1];
      assign tlb_req_dbg_derat_req_ttype_q[6:7] = derat_req3_ttype_q[0:1];
      assign tlb_req_dbg_derat_req_dup_q = {derat_req0_dup_q[1], derat_req1_dup_q[1], derat_req2_dup_q[1], derat_req3_dup_q[1]};
      // unused spare signal assignments
      assign unused_dc[0] = |(lcb_delay_lclkr_dc[1:4]);
      assign unused_dc[1] = |(lcb_mpw1_dc_b[1:4]);
      assign unused_dc[2] = pc_func_sl_force;
      assign unused_dc[3] = pc_func_sl_thold_0_b;
      assign unused_dc[4] = tc_scan_dis_dc_b;
      assign unused_dc[5] = tc_scan_diag_dc;
      assign unused_dc[6] = tc_lbist_en_dc;
      assign unused_dc[7] = |(ierat_req_pid_mux);
      assign unused_dc[8] = 1'b0;
      assign unused_dc[9] = 1'b0;
      assign unused_dc[10] = tlb_seq_ierat_done;
      assign unused_dc[11] = tlb_seq_derat_done;
      assign unused_dc[12] = mmucr2_act_override;
      assign unused_dc[13] = |(xu_mm_ierat_miss_q);
      assign unused_dc[14] = |(xu_ex3_flush);
      assign unused_dc[15] = |(xu_mm_ex4_flush);
      assign unused_dc[16] = |(xu_mm_ex5_flush);

      //---------------------------------------------------------------------
      // Latches
      //---------------------------------------------------------------------
      // ierat miss request latches

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_req0_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req0_valid_offset]),
         .scout(sov[ierat_req0_valid_offset]),
         .din(ierat_req0_valid_d),
         .dout(ierat_req0_valid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_req0_nonspec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req0_nonspec_offset]),
         .scout(sov[ierat_req0_nonspec_offset]),
         .din(ierat_req0_nonspec_d),
         .dout(ierat_req0_nonspec_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req0_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req0_thdid_offset:ierat_req0_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov[ierat_req0_thdid_offset:ierat_req0_thdid_offset + `THDID_WIDTH - 1]),
         .din(ierat_req0_thdid_d[0:`THDID_WIDTH - 1]),
         .dout(ierat_req0_thdid_q[0:`THDID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req0_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req0_epn_offset:ierat_req0_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[ierat_req0_epn_offset:ierat_req0_epn_offset + `EPN_WIDTH - 1]),
         .din(ierat_req0_epn_d[0:`EPN_WIDTH - 1]),
         .dout(ierat_req0_epn_q[0:`EPN_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`REQ_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req0_state_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req0_state_offset:ierat_req0_state_offset + `REQ_STATE_WIDTH - 1]),
         .scout(sov[ierat_req0_state_offset:ierat_req0_state_offset + `REQ_STATE_WIDTH - 1]),
         .din(ierat_req0_state_d[0:`REQ_STATE_WIDTH - 1]),
         .dout(ierat_req0_state_q[0:`REQ_STATE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req0_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req0_pid_offset:ierat_req0_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[ierat_req0_pid_offset:ierat_req0_pid_offset + `PID_WIDTH - 1]),
         .din(ierat_req0_pid_d[0:`PID_WIDTH - 1]),
         .dout(ierat_req0_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ierat_req0_dup_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req0_dup_offset:ierat_req0_dup_offset + 2 - 1]),
         .scout(sov[ierat_req0_dup_offset:ierat_req0_dup_offset + 2 - 1]),
         .din(ierat_req0_dup_d),
         .dout(ierat_req0_dup_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_req1_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req1_valid_offset]),
         .scout(sov[ierat_req1_valid_offset]),
         .din(ierat_req1_valid_d),
         .dout(ierat_req1_valid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_req1_nonspec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req1_nonspec_offset]),
         .scout(sov[ierat_req1_nonspec_offset]),
         .din(ierat_req1_nonspec_d),
         .dout(ierat_req1_nonspec_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req1_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req1_thdid_offset:ierat_req1_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov[ierat_req1_thdid_offset:ierat_req1_thdid_offset + `THDID_WIDTH - 1]),
         .din(ierat_req1_thdid_d[0:`THDID_WIDTH - 1]),
         .dout(ierat_req1_thdid_q[0:`THDID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req1_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req1_epn_offset:ierat_req1_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[ierat_req1_epn_offset:ierat_req1_epn_offset + `EPN_WIDTH - 1]),
         .din(ierat_req1_epn_d[0:`EPN_WIDTH - 1]),
         .dout(ierat_req1_epn_q[0:`EPN_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`REQ_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req1_state_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req1_state_offset:ierat_req1_state_offset + `REQ_STATE_WIDTH - 1]),
         .scout(sov[ierat_req1_state_offset:ierat_req1_state_offset + `REQ_STATE_WIDTH - 1]),
         .din(ierat_req1_state_d[0:`REQ_STATE_WIDTH - 1]),
         .dout(ierat_req1_state_q[0:`REQ_STATE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req1_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req1_pid_offset:ierat_req1_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[ierat_req1_pid_offset:ierat_req1_pid_offset + `PID_WIDTH - 1]),
         .din(ierat_req1_pid_d[0:`PID_WIDTH - 1]),
         .dout(ierat_req1_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ierat_req1_dup_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req1_dup_offset:ierat_req1_dup_offset + 2 - 1]),
         .scout(sov[ierat_req1_dup_offset:ierat_req1_dup_offset + 2 - 1]),
         .din(ierat_req1_dup_d),
         .dout(ierat_req1_dup_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_req2_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req2_valid_offset]),
         .scout(sov[ierat_req2_valid_offset]),
         .din(ierat_req2_valid_d),
         .dout(ierat_req2_valid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_req2_nonspec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req2_nonspec_offset]),
         .scout(sov[ierat_req2_nonspec_offset]),
         .din(ierat_req2_nonspec_d),
         .dout(ierat_req2_nonspec_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req2_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req2_thdid_offset:ierat_req2_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov[ierat_req2_thdid_offset:ierat_req2_thdid_offset + `THDID_WIDTH - 1]),
         .din(ierat_req2_thdid_d[0:`THDID_WIDTH - 1]),
         .dout(ierat_req2_thdid_q[0:`THDID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req2_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req2_epn_offset:ierat_req2_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[ierat_req2_epn_offset:ierat_req2_epn_offset + `EPN_WIDTH - 1]),
         .din(ierat_req2_epn_d[0:`EPN_WIDTH - 1]),
         .dout(ierat_req2_epn_q[0:`EPN_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`REQ_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req2_state_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req2_state_offset:ierat_req2_state_offset + `REQ_STATE_WIDTH - 1]),
         .scout(sov[ierat_req2_state_offset:ierat_req2_state_offset + `REQ_STATE_WIDTH - 1]),
         .din(ierat_req2_state_d[0:`REQ_STATE_WIDTH - 1]),
         .dout(ierat_req2_state_q[0:`REQ_STATE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req2_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req2_pid_offset:ierat_req2_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[ierat_req2_pid_offset:ierat_req2_pid_offset + `PID_WIDTH - 1]),
         .din(ierat_req2_pid_d[0:`PID_WIDTH - 1]),
         .dout(ierat_req2_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ierat_req2_dup_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req2_dup_offset:ierat_req2_dup_offset + 2 - 1]),
         .scout(sov[ierat_req2_dup_offset:ierat_req2_dup_offset + 2 - 1]),
         .din(ierat_req2_dup_d),
         .dout(ierat_req2_dup_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_req3_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req3_valid_offset]),
         .scout(sov[ierat_req3_valid_offset]),
         .din(ierat_req3_valid_d),
         .dout(ierat_req3_valid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_req3_nonspec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req3_nonspec_offset]),
         .scout(sov[ierat_req3_nonspec_offset]),
         .din(ierat_req3_nonspec_d),
         .dout(ierat_req3_nonspec_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req3_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req3_thdid_offset:ierat_req3_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov[ierat_req3_thdid_offset:ierat_req3_thdid_offset + `THDID_WIDTH - 1]),
         .din(ierat_req3_thdid_d[0:`THDID_WIDTH - 1]),
         .dout(ierat_req3_thdid_q[0:`THDID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req3_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req3_epn_offset:ierat_req3_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[ierat_req3_epn_offset:ierat_req3_epn_offset + `EPN_WIDTH - 1]),
         .din(ierat_req3_epn_d[0:`EPN_WIDTH - 1]),
         .dout(ierat_req3_epn_q[0:`EPN_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`REQ_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req3_state_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req3_state_offset:ierat_req3_state_offset + `REQ_STATE_WIDTH - 1]),
         .scout(sov[ierat_req3_state_offset:ierat_req3_state_offset + `REQ_STATE_WIDTH - 1]),
         .din(ierat_req3_state_d[0:`REQ_STATE_WIDTH - 1]),
         .dout(ierat_req3_state_q[0:`REQ_STATE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_req3_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req3_pid_offset:ierat_req3_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[ierat_req3_pid_offset:ierat_req3_pid_offset + `PID_WIDTH - 1]),
         .din(ierat_req3_pid_d[0:`PID_WIDTH - 1]),
         .dout(ierat_req3_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ierat_req3_dup_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_req3_dup_offset:ierat_req3_dup_offset + 2 - 1]),
         .scout(sov[ierat_req3_dup_offset:ierat_req3_dup_offset + 2 - 1]),
         .din(ierat_req3_dup_d),
         .dout(ierat_req3_dup_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ierat_inptr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_inptr_offset:ierat_inptr_offset + 2 - 1]),
         .scout(sov[ierat_inptr_offset:ierat_inptr_offset + 2 - 1]),
         .din(ierat_inptr_d),
         .dout(ierat_inptr_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ierat_outptr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_outptr_offset:ierat_outptr_offset + 2 - 1]),
         .scout(sov[ierat_outptr_offset:ierat_outptr_offset + 2 - 1]),
         .din(ierat_outptr_d),
         .dout(ierat_outptr_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_iu3_flush_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu3_flush_offset:ierat_iu3_flush_offset + `THDID_WIDTH - 1]),
         .scout(sov[ierat_iu3_flush_offset:ierat_iu3_flush_offset + `THDID_WIDTH - 1]),
         .din(ierat_iu3_flush_d),
         .dout(ierat_iu3_flush_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_seq_ierat_req_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_seq_ierat_req_offset]),
         .scout(sov[tlb_seq_ierat_req_offset]),
         .din(tlb_seq_ierat_req_d),
         .dout(tlb_seq_ierat_req_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) xu_mm_ierat_flush_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[xu_mm_ierat_flush_offset:xu_mm_ierat_flush_offset + `THDID_WIDTH - 1]),
         .scout(sov[xu_mm_ierat_flush_offset:xu_mm_ierat_flush_offset + `THDID_WIDTH - 1]),
         .din(xu_mm_ierat_flush_d),
         .dout(xu_mm_ierat_flush_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) xu_mm_ierat_miss_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[xu_mm_ierat_miss_offset:xu_mm_ierat_miss_offset + `THDID_WIDTH - 1]),
         .scout(sov[xu_mm_ierat_miss_offset:xu_mm_ierat_miss_offset + `THDID_WIDTH - 1]),
         .din(xu_mm_ierat_miss_d),
         .dout(xu_mm_ierat_miss_q)
      );
      // ierat miss request latches

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_iu3_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu3_valid_offset]),
         .scout(sov[ierat_iu3_valid_offset]),
         .din(ierat_iu3_valid_d),
         .dout(ierat_iu3_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_iu3_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu3_thdid_offset:ierat_iu3_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov[ierat_iu3_thdid_offset:ierat_iu3_thdid_offset + `THDID_WIDTH - 1]),
         .din(ierat_iu3_thdid_d[0:`THDID_WIDTH - 1]),
         .dout(ierat_iu3_thdid_q[0:`THDID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_iu3_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu3_epn_offset:ierat_iu3_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[ierat_iu3_epn_offset:ierat_iu3_epn_offset + `EPN_WIDTH - 1]),
         .din(ierat_iu3_epn_d[0:`EPN_WIDTH - 1]),
         .dout(ierat_iu3_epn_q[0:`EPN_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`REQ_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_iu3_state_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu3_state_offset:ierat_iu3_state_offset + `REQ_STATE_WIDTH - 1]),
         .scout(sov[ierat_iu3_state_offset:ierat_iu3_state_offset + `REQ_STATE_WIDTH - 1]),
         .din(ierat_iu3_state_d[0:`REQ_STATE_WIDTH - 1]),
         .dout(ierat_iu3_state_q[0:`REQ_STATE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_iu3_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu3_pid_offset:ierat_iu3_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[ierat_iu3_pid_offset:ierat_iu3_pid_offset + `PID_WIDTH - 1]),
         .din(ierat_iu3_pid_d[0:`PID_WIDTH - 1]),
         .dout(ierat_iu3_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_iu3_nonspec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu3_nonspec_offset]),
         .scout(sov[ierat_iu3_nonspec_offset]),
         .din(ierat_iu3_nonspec_d),
         .dout(ierat_iu3_nonspec_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_iu4_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu4_valid_offset]),
         .scout(sov[ierat_iu4_valid_offset]),
         .din(ierat_iu4_valid_d),
         .dout(ierat_iu4_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_iu4_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu4_thdid_offset:ierat_iu4_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov[ierat_iu4_thdid_offset:ierat_iu4_thdid_offset + `THDID_WIDTH - 1]),
         .din(ierat_iu4_thdid_d[0:`THDID_WIDTH - 1]),
         .dout(ierat_iu4_thdid_q[0:`THDID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_iu4_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu4_epn_offset:ierat_iu4_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[ierat_iu4_epn_offset:ierat_iu4_epn_offset + `EPN_WIDTH - 1]),
         .din(ierat_iu4_epn_d[0:`EPN_WIDTH - 1]),
         .dout(ierat_iu4_epn_q[0:`EPN_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`REQ_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_iu4_state_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu4_state_offset:ierat_iu4_state_offset + `REQ_STATE_WIDTH - 1]),
         .scout(sov[ierat_iu4_state_offset:ierat_iu4_state_offset + `REQ_STATE_WIDTH - 1]),
         .din(ierat_iu4_state_d[0:`REQ_STATE_WIDTH - 1]),
         .dout(ierat_iu4_state_q[0:`REQ_STATE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_iu4_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu4_pid_offset:ierat_iu4_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[ierat_iu4_pid_offset:ierat_iu4_pid_offset + `PID_WIDTH - 1]),
         .din(ierat_iu4_pid_d[0:`PID_WIDTH - 1]),
         .dout(ierat_iu4_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_iu4_nonspec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu4_nonspec_offset]),
         .scout(sov[ierat_iu4_nonspec_offset]),
         .din(ierat_iu4_nonspec_d),
         .dout(ierat_iu4_nonspec_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_iu5_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu5_valid_offset]),
         .scout(sov[ierat_iu5_valid_offset]),
         .din(ierat_iu5_valid_d),
         .dout(ierat_iu5_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_iu5_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu5_thdid_offset:ierat_iu5_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov[ierat_iu5_thdid_offset:ierat_iu5_thdid_offset + `THDID_WIDTH - 1]),
         .din(ierat_iu5_thdid_d[0:`THDID_WIDTH - 1]),
         .dout(ierat_iu5_thdid_q[0:`THDID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_iu5_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu5_epn_offset:ierat_iu5_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[ierat_iu5_epn_offset:ierat_iu5_epn_offset + `EPN_WIDTH - 1]),
         .din(ierat_iu5_epn_d[0:`EPN_WIDTH - 1]),
         .dout(ierat_iu5_epn_q[0:`EPN_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`REQ_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_iu5_state_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu5_state_offset:ierat_iu5_state_offset + `REQ_STATE_WIDTH - 1]),
         .scout(sov[ierat_iu5_state_offset:ierat_iu5_state_offset + `REQ_STATE_WIDTH - 1]),
         .din(ierat_iu5_state_d[0:`REQ_STATE_WIDTH - 1]),
         .dout(ierat_iu5_state_q[0:`REQ_STATE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ierat_iu5_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu5_pid_offset:ierat_iu5_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[ierat_iu5_pid_offset:ierat_iu5_pid_offset + `PID_WIDTH - 1]),
         .din(ierat_iu5_pid_d[0:`PID_WIDTH - 1]),
         .dout(ierat_iu5_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_iu5_nonspec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ierat_iu5_nonspec_offset]),
         .scout(sov[ierat_iu5_nonspec_offset]),
         .din(ierat_iu5_nonspec_d),
         .dout(ierat_iu5_nonspec_q)
      );
      // derat miss request latches

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_req0_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req0_valid_offset]),
         .scout(sov[derat_req0_valid_offset]),
         .din(derat_req0_valid_d),
         .dout(derat_req0_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req0_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req0_thdid_offset:derat_req0_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov[derat_req0_thdid_offset:derat_req0_thdid_offset + `THDID_WIDTH - 1]),
         .din(derat_req0_thdid_d[0:`THDID_WIDTH - 1]),
         .dout(derat_req0_thdid_q[0:`THDID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req0_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req0_epn_offset:derat_req0_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[derat_req0_epn_offset:derat_req0_epn_offset + `EPN_WIDTH - 1]),
         .din(derat_req0_epn_d[0:`EPN_WIDTH - 1]),
         .dout(derat_req0_epn_q[0:`EPN_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`REQ_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req0_state_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req0_state_offset:derat_req0_state_offset + `REQ_STATE_WIDTH - 1]),
         .scout(sov[derat_req0_state_offset:derat_req0_state_offset + `REQ_STATE_WIDTH - 1]),
         .din(derat_req0_state_d[0:`REQ_STATE_WIDTH - 1]),
         .dout(derat_req0_state_q[0:`REQ_STATE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) derat_req0_ttype_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req0_ttype_offset:derat_req0_ttype_offset + 2 - 1]),
         .scout(sov[derat_req0_ttype_offset:derat_req0_ttype_offset + 2 - 1]),
         .din(derat_req0_ttype_d),
         .dout(derat_req0_ttype_q)
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req0_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req0_pid_offset:derat_req0_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[derat_req0_pid_offset:derat_req0_pid_offset + `PID_WIDTH - 1]),
         .din(derat_req0_pid_d[0:`PID_WIDTH - 1]),
         .dout(derat_req0_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req0_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req0_lpid_offset:derat_req0_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[derat_req0_lpid_offset:derat_req0_lpid_offset + `LPID_WIDTH - 1]),
         .din(derat_req0_lpid_d[0:`LPID_WIDTH - 1]),
         .dout(derat_req0_lpid_q[0:`LPID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) derat_req0_dup_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req0_dup_offset:derat_req0_dup_offset + 2 - 1]),
         .scout(sov[derat_req0_dup_offset:derat_req0_dup_offset + 2 - 1]),
         .din(derat_req0_dup_d),
         .dout(derat_req0_dup_q)
      );

      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) derat_req0_itag_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req0_itag_offset:derat_req0_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[derat_req0_itag_offset:derat_req0_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(derat_req0_itag_d),
         .dout(derat_req0_itag_q)
      );

      tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) derat_req0_emq_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req0_emq_offset:derat_req0_emq_offset + `EMQ_ENTRIES - 1]),
         .scout(sov[derat_req0_emq_offset:derat_req0_emq_offset + `EMQ_ENTRIES - 1]),
         .din(derat_req0_emq_d),
         .dout(derat_req0_emq_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_req0_nonspec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req0_nonspec_offset]),
         .scout(sov[derat_req0_nonspec_offset]),
         .din(derat_req0_nonspec_d),
         .dout(derat_req0_nonspec_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_req1_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req1_valid_offset]),
         .scout(sov[derat_req1_valid_offset]),
         .din(derat_req1_valid_d),
         .dout(derat_req1_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req1_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req1_thdid_offset:derat_req1_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov[derat_req1_thdid_offset:derat_req1_thdid_offset + `THDID_WIDTH - 1]),
         .din(derat_req1_thdid_d[0:`THDID_WIDTH - 1]),
         .dout(derat_req1_thdid_q[0:`THDID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req1_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req1_epn_offset:derat_req1_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[derat_req1_epn_offset:derat_req1_epn_offset + `EPN_WIDTH - 1]),
         .din(derat_req1_epn_d[0:`EPN_WIDTH - 1]),
         .dout(derat_req1_epn_q[0:`EPN_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`REQ_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req1_state_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req1_state_offset:derat_req1_state_offset + `REQ_STATE_WIDTH - 1]),
         .scout(sov[derat_req1_state_offset:derat_req1_state_offset + `REQ_STATE_WIDTH - 1]),
         .din(derat_req1_state_d[0:`REQ_STATE_WIDTH - 1]),
         .dout(derat_req1_state_q[0:`REQ_STATE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) derat_req1_ttype_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req1_ttype_offset:derat_req1_ttype_offset + 2 - 1]),
         .scout(sov[derat_req1_ttype_offset:derat_req1_ttype_offset + 2 - 1]),
         .din(derat_req1_ttype_d),
         .dout(derat_req1_ttype_q)
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req1_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req1_pid_offset:derat_req1_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[derat_req1_pid_offset:derat_req1_pid_offset + `PID_WIDTH - 1]),
         .din(derat_req1_pid_d[0:`PID_WIDTH - 1]),
         .dout(derat_req1_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req1_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req1_lpid_offset:derat_req1_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[derat_req1_lpid_offset:derat_req1_lpid_offset + `LPID_WIDTH - 1]),
         .din(derat_req1_lpid_d[0:`LPID_WIDTH - 1]),
         .dout(derat_req1_lpid_q[0:`LPID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) derat_req1_dup_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req1_dup_offset:derat_req1_dup_offset + 2 - 1]),
         .scout(sov[derat_req1_dup_offset:derat_req1_dup_offset + 2 - 1]),
         .din(derat_req1_dup_d),
         .dout(derat_req1_dup_q)
      );

      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) derat_req1_itag_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req1_itag_offset:derat_req1_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[derat_req1_itag_offset:derat_req1_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(derat_req1_itag_d),
         .dout(derat_req1_itag_q)
      );

      tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) derat_req1_emq_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req1_emq_offset:derat_req1_emq_offset + `EMQ_ENTRIES - 1]),
         .scout(sov[derat_req1_emq_offset:derat_req1_emq_offset + `EMQ_ENTRIES - 1]),
         .din(derat_req1_emq_d),
         .dout(derat_req1_emq_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_req1_nonspec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req1_nonspec_offset]),
         .scout(sov[derat_req1_nonspec_offset]),
         .din(derat_req1_nonspec_d),
         .dout(derat_req1_nonspec_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_req2_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req2_valid_offset]),
         .scout(sov[derat_req2_valid_offset]),
         .din(derat_req2_valid_d),
         .dout(derat_req2_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req2_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req2_thdid_offset:derat_req2_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov[derat_req2_thdid_offset:derat_req2_thdid_offset + `THDID_WIDTH - 1]),
         .din(derat_req2_thdid_d[0:`THDID_WIDTH - 1]),
         .dout(derat_req2_thdid_q[0:`THDID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req2_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req2_epn_offset:derat_req2_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[derat_req2_epn_offset:derat_req2_epn_offset + `EPN_WIDTH - 1]),
         .din(derat_req2_epn_d[0:`EPN_WIDTH - 1]),
         .dout(derat_req2_epn_q[0:`EPN_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`REQ_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req2_state_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req2_state_offset:derat_req2_state_offset + `REQ_STATE_WIDTH - 1]),
         .scout(sov[derat_req2_state_offset:derat_req2_state_offset + `REQ_STATE_WIDTH - 1]),
         .din(derat_req2_state_d[0:`REQ_STATE_WIDTH - 1]),
         .dout(derat_req2_state_q[0:`REQ_STATE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) derat_req2_ttype_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req2_ttype_offset:derat_req2_ttype_offset + 2 - 1]),
         .scout(sov[derat_req2_ttype_offset:derat_req2_ttype_offset + 2 - 1]),
         .din(derat_req2_ttype_d),
         .dout(derat_req2_ttype_q)
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req2_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req2_pid_offset:derat_req2_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[derat_req2_pid_offset:derat_req2_pid_offset + `PID_WIDTH - 1]),
         .din(derat_req2_pid_d[0:`PID_WIDTH - 1]),
         .dout(derat_req2_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req2_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req2_lpid_offset:derat_req2_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[derat_req2_lpid_offset:derat_req2_lpid_offset + `LPID_WIDTH - 1]),
         .din(derat_req2_lpid_d[0:`LPID_WIDTH - 1]),
         .dout(derat_req2_lpid_q[0:`LPID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) derat_req2_dup_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req2_dup_offset:derat_req2_dup_offset + 2 - 1]),
         .scout(sov[derat_req2_dup_offset:derat_req2_dup_offset + 2 - 1]),
         .din(derat_req2_dup_d),
         .dout(derat_req2_dup_q)
      );

      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) derat_req2_itag_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req2_itag_offset:derat_req2_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[derat_req2_itag_offset:derat_req2_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(derat_req2_itag_d),
         .dout(derat_req2_itag_q)
      );

      tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) derat_req2_emq_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req2_emq_offset:derat_req2_emq_offset + `EMQ_ENTRIES - 1]),
         .scout(sov[derat_req2_emq_offset:derat_req2_emq_offset + `EMQ_ENTRIES - 1]),
         .din(derat_req2_emq_d),
         .dout(derat_req2_emq_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_req2_nonspec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req2_nonspec_offset]),
         .scout(sov[derat_req2_nonspec_offset]),
         .din(derat_req2_nonspec_d),
         .dout(derat_req2_nonspec_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_req3_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req3_valid_offset]),
         .scout(sov[derat_req3_valid_offset]),
         .din(derat_req3_valid_d),
         .dout(derat_req3_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req3_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req3_thdid_offset:derat_req3_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov[derat_req3_thdid_offset:derat_req3_thdid_offset + `THDID_WIDTH - 1]),
         .din(derat_req3_thdid_d[0:`THDID_WIDTH - 1]),
         .dout(derat_req3_thdid_q[0:`THDID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req3_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req3_epn_offset:derat_req3_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[derat_req3_epn_offset:derat_req3_epn_offset + `EPN_WIDTH - 1]),
         .din(derat_req3_epn_d[0:`EPN_WIDTH - 1]),
         .dout(derat_req3_epn_q[0:`EPN_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`REQ_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req3_state_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req3_state_offset:derat_req3_state_offset + `REQ_STATE_WIDTH - 1]),
         .scout(sov[derat_req3_state_offset:derat_req3_state_offset + `REQ_STATE_WIDTH - 1]),
         .din(derat_req3_state_d[0:`REQ_STATE_WIDTH - 1]),
         .dout(derat_req3_state_q[0:`REQ_STATE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) derat_req3_ttype_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req3_ttype_offset:derat_req3_ttype_offset + 2 - 1]),
         .scout(sov[derat_req3_ttype_offset:derat_req3_ttype_offset + 2 - 1]),
         .din(derat_req3_ttype_d),
         .dout(derat_req3_ttype_q)
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req3_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req3_pid_offset:derat_req3_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[derat_req3_pid_offset:derat_req3_pid_offset + `PID_WIDTH - 1]),
         .din(derat_req3_pid_d[0:`PID_WIDTH - 1]),
         .dout(derat_req3_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_req3_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req3_lpid_offset:derat_req3_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[derat_req3_lpid_offset:derat_req3_lpid_offset + `LPID_WIDTH - 1]),
         .din(derat_req3_lpid_d[0:`LPID_WIDTH - 1]),
         .dout(derat_req3_lpid_q[0:`LPID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) derat_req3_dup_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req3_dup_offset:derat_req3_dup_offset + 2 - 1]),
         .scout(sov[derat_req3_dup_offset:derat_req3_dup_offset + 2 - 1]),
         .din(derat_req3_dup_d),
         .dout(derat_req3_dup_q)
      );

      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) derat_req3_itag_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req3_itag_offset:derat_req3_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[derat_req3_itag_offset:derat_req3_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(derat_req3_itag_d),
         .dout(derat_req3_itag_q)
      );

      tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) derat_req3_emq_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req3_emq_offset:derat_req3_emq_offset + `EMQ_ENTRIES - 1]),
         .scout(sov[derat_req3_emq_offset:derat_req3_emq_offset + `EMQ_ENTRIES - 1]),
         .din(derat_req3_emq_d),
         .dout(derat_req3_emq_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_req3_nonspec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_req3_nonspec_offset]),
         .scout(sov[derat_req3_nonspec_offset]),
         .din(derat_req3_nonspec_d),
         .dout(derat_req3_nonspec_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) derat_inptr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_inptr_offset:derat_inptr_offset + 2 - 1]),
         .scout(sov[derat_inptr_offset:derat_inptr_offset + 2 - 1]),
         .din(derat_inptr_d),
         .dout(derat_inptr_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) derat_outptr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_outptr_offset:derat_outptr_offset + 2 - 1]),
         .scout(sov[derat_outptr_offset:derat_outptr_offset + 2 - 1]),
         .din(derat_outptr_d),
         .dout(derat_outptr_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_seq_derat_req_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_seq_derat_req_offset]),
         .scout(sov[tlb_seq_derat_req_offset]),
         .din(tlb_seq_derat_req_d),
         .dout(tlb_seq_derat_req_q)
      );
      // derat miss request latches

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_ex4_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex4_valid_offset]),
         .scout(sov[derat_ex4_valid_offset]),
         .din(derat_ex4_valid_d),
         .dout(derat_ex4_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex4_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex4_thdid_offset:derat_ex4_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov[derat_ex4_thdid_offset:derat_ex4_thdid_offset + `THDID_WIDTH - 1]),
         .din(derat_ex4_thdid_d[0:`THDID_WIDTH - 1]),
         .dout(derat_ex4_thdid_q[0:`THDID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex4_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex4_epn_offset:derat_ex4_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[derat_ex4_epn_offset:derat_ex4_epn_offset + `EPN_WIDTH - 1]),
         .din(derat_ex4_epn_d[0:`EPN_WIDTH - 1]),
         .dout(derat_ex4_epn_q[0:`EPN_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`REQ_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex4_state_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex4_state_offset:derat_ex4_state_offset + `REQ_STATE_WIDTH - 1]),
         .scout(sov[derat_ex4_state_offset:derat_ex4_state_offset + `REQ_STATE_WIDTH - 1]),
         .din(derat_ex4_state_d[0:`REQ_STATE_WIDTH - 1]),
         .dout(derat_ex4_state_q[0:`REQ_STATE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) derat_ex4_ttype_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex4_ttype_offset:derat_ex4_ttype_offset + 2 - 1]),
         .scout(sov[derat_ex4_ttype_offset:derat_ex4_ttype_offset + 2 - 1]),
         .din(derat_ex4_ttype_d),
         .dout(derat_ex4_ttype_q)
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex4_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex4_pid_offset:derat_ex4_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[derat_ex4_pid_offset:derat_ex4_pid_offset + `PID_WIDTH - 1]),
         .din(derat_ex4_pid_d[0:`PID_WIDTH - 1]),
         .dout(derat_ex4_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex4_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex4_lpid_offset:derat_ex4_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[derat_ex4_lpid_offset:derat_ex4_lpid_offset + `LPID_WIDTH - 1]),
         .din(derat_ex4_lpid_d[0:`LPID_WIDTH - 1]),
         .dout(derat_ex4_lpid_q[0:`LPID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) derat_ex4_itag_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex4_itag_offset:derat_ex4_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[derat_ex4_itag_offset:derat_ex4_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(derat_ex4_itag_d),
         .dout(derat_ex4_itag_q)
      );

      tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) derat_ex4_emq_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex4_emq_offset:derat_ex4_emq_offset + `EMQ_ENTRIES - 1]),
         .scout(sov[derat_ex4_emq_offset:derat_ex4_emq_offset + `EMQ_ENTRIES - 1]),
         .din(derat_ex4_emq_d),
         .dout(derat_ex4_emq_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_ex4_nonspec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex4_nonspec_offset]),
         .scout(sov[derat_ex4_nonspec_offset]),
         .din(derat_ex4_nonspec_d),
         .dout(derat_ex4_nonspec_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_ex5_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex5_valid_offset]),
         .scout(sov[derat_ex5_valid_offset]),
         .din(derat_ex5_valid_d),
         .dout(derat_ex5_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex5_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex5_thdid_offset:derat_ex5_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov[derat_ex5_thdid_offset:derat_ex5_thdid_offset + `THDID_WIDTH - 1]),
         .din(derat_ex5_thdid_d[0:`THDID_WIDTH - 1]),
         .dout(derat_ex5_thdid_q[0:`THDID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex5_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex5_epn_offset:derat_ex5_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[derat_ex5_epn_offset:derat_ex5_epn_offset + `EPN_WIDTH - 1]),
         .din(derat_ex5_epn_d[0:`EPN_WIDTH - 1]),
         .dout(derat_ex5_epn_q[0:`EPN_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`REQ_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex5_state_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex5_state_offset:derat_ex5_state_offset + `REQ_STATE_WIDTH - 1]),
         .scout(sov[derat_ex5_state_offset:derat_ex5_state_offset + `REQ_STATE_WIDTH - 1]),
         .din(derat_ex5_state_d[0:`REQ_STATE_WIDTH - 1]),
         .dout(derat_ex5_state_q[0:`REQ_STATE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) derat_ex5_ttype_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex5_ttype_offset:derat_ex5_ttype_offset + 2 - 1]),
         .scout(sov[derat_ex5_ttype_offset:derat_ex5_ttype_offset + 2 - 1]),
         .din(derat_ex5_ttype_d),
         .dout(derat_ex5_ttype_q)
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex5_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex5_pid_offset:derat_ex5_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[derat_ex5_pid_offset:derat_ex5_pid_offset + `PID_WIDTH - 1]),
         .din(derat_ex5_pid_d[0:`PID_WIDTH - 1]),
         .dout(derat_ex5_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex5_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex5_lpid_offset:derat_ex5_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[derat_ex5_lpid_offset:derat_ex5_lpid_offset + `LPID_WIDTH - 1]),
         .din(derat_ex5_lpid_d[0:`LPID_WIDTH - 1]),
         .dout(derat_ex5_lpid_q[0:`LPID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) derat_ex5_itag_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex5_itag_offset:derat_ex5_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[derat_ex5_itag_offset:derat_ex5_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(derat_ex5_itag_d),
         .dout(derat_ex5_itag_q)
      );

      tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) derat_ex5_emq_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex5_emq_offset:derat_ex5_emq_offset + `EMQ_ENTRIES - 1]),
         .scout(sov[derat_ex5_emq_offset:derat_ex5_emq_offset + `EMQ_ENTRIES - 1]),
         .din(derat_ex5_emq_d),
         .dout(derat_ex5_emq_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_ex5_nonspec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex5_nonspec_offset]),
         .scout(sov[derat_ex5_nonspec_offset]),
         .din(derat_ex5_nonspec_d),
         .dout(derat_ex5_nonspec_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_ex6_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex6_valid_offset]),
         .scout(sov[derat_ex6_valid_offset]),
         .din(derat_ex6_valid_d),
         .dout(derat_ex6_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex6_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex6_thdid_offset:derat_ex6_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov[derat_ex6_thdid_offset:derat_ex6_thdid_offset + `THDID_WIDTH - 1]),
         .din(derat_ex6_thdid_d[0:`THDID_WIDTH - 1]),
         .dout(derat_ex6_thdid_q[0:`THDID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex6_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex6_epn_offset:derat_ex6_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[derat_ex6_epn_offset:derat_ex6_epn_offset + `EPN_WIDTH - 1]),
         .din(derat_ex6_epn_d[0:`EPN_WIDTH - 1]),
         .dout(derat_ex6_epn_q[0:`EPN_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`REQ_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex6_state_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex6_state_offset:derat_ex6_state_offset + `REQ_STATE_WIDTH - 1]),
         .scout(sov[derat_ex6_state_offset:derat_ex6_state_offset + `REQ_STATE_WIDTH - 1]),
         .din(derat_ex6_state_d[0:`REQ_STATE_WIDTH - 1]),
         .dout(derat_ex6_state_q[0:`REQ_STATE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) derat_ex6_ttype_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex6_ttype_offset:derat_ex6_ttype_offset + 2 - 1]),
         .scout(sov[derat_ex6_ttype_offset:derat_ex6_ttype_offset + 2 - 1]),
         .din(derat_ex6_ttype_d),
         .dout(derat_ex6_ttype_q)
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex6_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex6_pid_offset:derat_ex6_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[derat_ex6_pid_offset:derat_ex6_pid_offset + `PID_WIDTH - 1]),
         .din(derat_ex6_pid_d[0:`PID_WIDTH - 1]),
         .dout(derat_ex6_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) derat_ex6_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex6_lpid_offset:derat_ex6_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[derat_ex6_lpid_offset:derat_ex6_lpid_offset + `LPID_WIDTH - 1]),
         .din(derat_ex6_lpid_d[0:`LPID_WIDTH - 1]),
         .dout(derat_ex6_lpid_q[0:`LPID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) derat_ex6_itag_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex6_itag_offset:derat_ex6_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[derat_ex6_itag_offset:derat_ex6_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(derat_ex6_itag_d),
         .dout(derat_ex6_itag_q)
      );

      tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) derat_ex6_emq_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex6_emq_offset:derat_ex6_emq_offset + `EMQ_ENTRIES - 1]),
         .scout(sov[derat_ex6_emq_offset:derat_ex6_emq_offset + `EMQ_ENTRIES - 1]),
         .din(derat_ex6_emq_d),
         .dout(derat_ex6_emq_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_ex6_nonspec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[derat_ex6_nonspec_offset]),
         .scout(sov[derat_ex6_nonspec_offset]),
         .din(derat_ex6_nonspec_d),
         .dout(derat_ex6_nonspec_q)
      );

      tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) spare_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(xu_mm_ccr2_notlb_b),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[spare_offset:spare_offset + 32 - 1]),
         .scout(sov[spare_offset:spare_offset + 32 - 1]),
         .din(spare_q),
         .dout(spare_q)
      );

      //------------------------------------------------
      // thold/sg latches
      //------------------------------------------------

      tri_plat #(.WIDTH(3)) perv_2to1_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ccflush_dc),
         .din( {pc_func_sl_thold_2, pc_func_slp_sl_thold_2, pc_sg_2} ),
         .q( {pc_func_sl_thold_1, pc_func_slp_sl_thold_1, pc_sg_1} )
      );

      tri_plat #(.WIDTH(3)) perv_1to0_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ccflush_dc),
         .din( {pc_func_sl_thold_1, pc_func_slp_sl_thold_1, pc_sg_1} ),
         .q( {pc_func_sl_thold_0, pc_func_slp_sl_thold_0, pc_sg_0} )
      );

      tri_lcbor perv_lcbor_func_sl(
         .clkoff_b(lcb_clkoff_dc_b),
         .thold(pc_func_sl_thold_0),
         .sg(pc_sg_0),
         .act_dis(lcb_act_dis_dc),
         .force_t(pc_func_sl_force),
         .thold_b(pc_func_sl_thold_0_b)
      );

      tri_lcbor perv_lcbor_func_slp_sl(
         .clkoff_b(lcb_clkoff_dc_b),
         .thold(pc_func_slp_sl_thold_0),
         .sg(pc_sg_0),
         .act_dis(lcb_act_dis_dc),
         .force_t(pc_func_slp_sl_force),
         .thold_b(pc_func_slp_sl_thold_0_b)
      );

      //---------------------------------------------------------------------
      // Scan
      //---------------------------------------------------------------------
      assign siv[0:scan_right] = {sov[1:scan_right], ac_func_scan_in};
      assign ac_func_scan_out = sov[0];

endmodule
