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
//* TITLE: Memory Management Unit Hardware Table Walker Logic
//*********************************************************************

`timescale 1 ns / 1 ns

`include "tri_a2o.vh"
`include "mmu_a2o.vh"
`define        HTW_SEQ_WIDTH   2
`define        PTE_SEQ_WIDTH   3


module mmq_htw(
   inout                                  vdd,
   inout                                  gnd,
   (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]                nclk,

   input                                  tc_ccflush_dc,
   input                                  tc_scan_dis_dc_b,
   input                                  tc_scan_diag_dc,
   input                                  tc_lbist_en_dc,
   input                                  lcb_d_mode_dc,
   input                                  lcb_clkoff_dc_b,
   input                                  lcb_act_dis_dc,
   input [0:4]                            lcb_mpw1_dc_b,
   input                                  lcb_mpw2_dc_b,
   input [0:4]                            lcb_delay_lclkr_dc,
   input                                  pc_sg_2,
   input                                  pc_func_sl_thold_2,
   input                                  pc_func_slp_sl_thold_2,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:1]                            ac_func_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:1]                           ac_func_scan_out,

   input                                  xu_mm_ccr2_notlb_b,
   input                                  mmucr2_act_override,
   input [24:28]                          tlb_delayed_act,
   input [0:`MM_THREADS-1]                tlb_ctl_tag2_flush,
   input [0:`MM_THREADS-1]                tlb_ctl_tag3_flush,
   input [0:`MM_THREADS-1]                tlb_ctl_tag4_flush,
   input [0:`TLB_TAG_WIDTH-1]             tlb_tag2,
   input [0:`MM_THREADS-1]                tlb_tag5_except,
   input                                  tlb_htw_req_valid,
   input [0:`TLB_TAG_WIDTH-1]              tlb_htw_req_tag,
   input [`TLB_WORD_WIDTH:`TLB_WAY_WIDTH-1] tlb_htw_req_way,
   output reg                             htw_lsu_req_valid,
   output [0:`THDID_WIDTH-1]               htw_lsu_thdid,
   output [0:1]                           htw_dbg_lsu_thdid,
   output [0:1]                           htw_lsu_ttype,
   output [0:4]                           htw_lsu_wimge,
   output [0:3]                           htw_lsu_u,
   output [64-`REAL_ADDR_WIDTH:63]         htw_lsu_addr,
   input                                  htw_lsu_req_taken,
   output [0:`THDID_WIDTH-1]               htw_quiesce,
   output                                 htw_req0_valid,
   output [0:`THDID_WIDTH-1]               htw_req0_thdid,
   output [0:1]                           htw_req0_type,
   output                                 htw_req1_valid,
   output [0:`THDID_WIDTH-1]               htw_req1_thdid,
   output [0:1]                           htw_req1_type,
   output                                 htw_req2_valid,
   output [0:`THDID_WIDTH-1]               htw_req2_thdid,
   output [0:1]                           htw_req2_type,
   output                                 htw_req3_valid,
   output [0:`THDID_WIDTH-1]               htw_req3_thdid,
   output [0:1]                           htw_req3_type,
   output                                 ptereload_req_valid,
   output [0:`TLB_TAG_WIDTH-1]             ptereload_req_tag,
   output [0:`PTE_WIDTH-1]                 ptereload_req_pte,
   input                                  ptereload_req_taken,
   input [0:4]                            an_ac_reld_core_tag,
   input [0:127]                          an_ac_reld_data,
   input                                  an_ac_reld_data_vld,
   input                                  an_ac_reld_ecc_err,
   input                                  an_ac_reld_ecc_err_ue,
   input [58:59]                          an_ac_reld_qw,
   input                                  an_ac_reld_ditc,
   input                                  an_ac_reld_crit_qw,
   output                                 htw_dbg_seq_idle,
   output                                 htw_dbg_pte0_seq_idle,
   output                                 htw_dbg_pte1_seq_idle,
   output [0:1]                           htw_dbg_seq_q,
   output [0:1]                           htw_dbg_inptr_q,
   output [0:2]                           htw_dbg_pte0_seq_q,
   output [0:2]                           htw_dbg_pte1_seq_q,
   output                                 htw_dbg_ptereload_ptr_q,
   output [0:1]                           htw_dbg_lsuptr_q,
   output [0:3]                           htw_dbg_req_valid_q,
   output [0:3]                           htw_dbg_resv_valid_vec,
   output [0:3]                           htw_dbg_tag4_clr_resv_q,
   output [0:3]                           htw_dbg_tag4_clr_resv_terms,
   output [0:1]                           htw_dbg_pte0_score_ptr_q,
   output [58:60]                         htw_dbg_pte0_score_cl_offset_q,
   output [0:2]                           htw_dbg_pte0_score_error_q,
   output [0:3]                           htw_dbg_pte0_score_qwbeat_q,
   output                                 htw_dbg_pte0_score_pending_q,
   output                                 htw_dbg_pte0_score_ibit_q,
   output                                 htw_dbg_pte0_score_dataval_q,
   output                                 htw_dbg_pte0_reld_for_me_tm1,
   output [0:1]                           htw_dbg_pte1_score_ptr_q,
   output [58:60]                         htw_dbg_pte1_score_cl_offset_q,
   output [0:2]                           htw_dbg_pte1_score_error_q,
   output [0:3]                           htw_dbg_pte1_score_qwbeat_q,
   output                                 htw_dbg_pte1_score_pending_q,
   output                                 htw_dbg_pte1_score_ibit_q,
   output                                 htw_dbg_pte1_score_dataval_q,

   output                                 htw_dbg_pte1_reld_for_me_tm1

);



      parameter                              MMU_Mode_Value = 1'b0;
      parameter [0:1]                        TlbSel_Tlb = 2'b00;
      parameter [0:1]                        TlbSel_IErat = 2'b10;
      parameter [0:1]                        TlbSel_DErat = 2'b11;
      parameter [0:4]                        Core_Tag0_Value = 5'b01100;
      parameter [0:4]                        Core_Tag1_Value = 5'b01101;
      parameter [0:2]                        ERAT_PgSize_1GB = 3'b110;
      parameter [0:2]                        ERAT_PgSize_16MB = 3'b111;
      parameter [0:2]                        ERAT_PgSize_1MB = 3'b101;
      parameter [0:2]                        ERAT_PgSize_64KB = 3'b011;
      parameter [0:2]                        ERAT_PgSize_4KB = 3'b001;
      parameter [0:3]                        TLB_PgSize_1GB = 4'b1010;
      parameter [0:3]                        TLB_PgSize_16MB = 4'b0111;
      parameter [0:3]                        TLB_PgSize_1MB = 4'b0101;
      parameter [0:3]                        TLB_PgSize_64KB = 4'b0011;
      parameter [0:3]                        TLB_PgSize_4KB = 4'b0001;
      // reserved for indirect entries
      parameter [0:2]                        ERAT_PgSize_256MB = 3'b100;
      parameter [0:3]                        TLB_PgSize_256MB = 4'b1001;
      parameter [0:1]                        HtwSeq_Idle = 2'b00;
      parameter [0:1]                        HtwSeq_Stg1 = 2'b01;
      parameter [0:1]                        HtwSeq_Stg2 = 2'b11;
      parameter [0:1]                        HtwSeq_Stg3 = 2'b10;
      parameter [0:2]                        PteSeq_Idle = 3'b000;
      parameter [0:2]                        PteSeq_Stg1 = 3'b001;
      parameter [0:2]                        PteSeq_Stg2 = 3'b011;
      parameter [0:2]                        PteSeq_Stg3 = 3'b010;
      parameter [0:2]                        PteSeq_Stg4 = 3'b110;
      parameter [0:2]                        PteSeq_Stg5 = 3'b111;
      parameter [0:2]                        PteSeq_Stg6 = 3'b101;
      parameter [0:2]                        PteSeq_Stg7 = 3'b100;
      //constant command_width          : integer := (EFF_IFAR'length+ibuff_data_width);

      parameter                              tlb_htw_req0_valid_offset = 0;
      parameter                              tlb_htw_req0_pending_offset = tlb_htw_req0_valid_offset + 1;
      parameter                              tlb_htw_req0_tag_offset = tlb_htw_req0_pending_offset + 1;
      parameter                              tlb_htw_req0_way_offset = tlb_htw_req0_tag_offset + `TLB_TAG_WIDTH;
      parameter                              tlb_htw_req1_valid_offset = tlb_htw_req0_way_offset + `TLB_WORD_WIDTH;
      parameter                              tlb_htw_req1_pending_offset = tlb_htw_req1_valid_offset + 1;
      parameter                              tlb_htw_req1_tag_offset = tlb_htw_req1_pending_offset + 1;
      parameter                              tlb_htw_req1_way_offset = tlb_htw_req1_tag_offset + `TLB_TAG_WIDTH;
      parameter                              tlb_htw_req2_valid_offset = tlb_htw_req1_way_offset + `TLB_WORD_WIDTH;
      parameter                              tlb_htw_req2_pending_offset = tlb_htw_req2_valid_offset + 1;
      parameter                              tlb_htw_req2_tag_offset = tlb_htw_req2_pending_offset + 1;
      parameter                              tlb_htw_req2_way_offset = tlb_htw_req2_tag_offset + `TLB_TAG_WIDTH;
      parameter                              tlb_htw_req3_valid_offset = tlb_htw_req2_way_offset + `TLB_WORD_WIDTH;
      parameter                              tlb_htw_req3_pending_offset = tlb_htw_req3_valid_offset + 1;
      parameter                              tlb_htw_req3_tag_offset = tlb_htw_req3_pending_offset + 1;
      parameter                              tlb_htw_req3_way_offset = tlb_htw_req3_tag_offset + `TLB_TAG_WIDTH;
      parameter                              spare_a_offset = tlb_htw_req3_way_offset + `TLB_WORD_WIDTH;
      parameter                              scan_right_0 = spare_a_offset + 16 - 1;
      parameter                              htw_seq_offset = 0;
      parameter                              htw_inptr_offset = htw_seq_offset + `HTW_SEQ_WIDTH;
      parameter                              htw_lsuptr_offset = htw_inptr_offset + 2;
      parameter                              htw_lsu_ttype_offset = htw_lsuptr_offset + 2;
      parameter                              htw_lsu_thdid_offset = htw_lsu_ttype_offset + 2;
      parameter                              htw_lsu_wimge_offset = htw_lsu_thdid_offset + `THDID_WIDTH;
      parameter                              htw_lsu_u_offset = htw_lsu_wimge_offset + 5;
      parameter                              htw_lsu_addr_offset = htw_lsu_u_offset + 4;
      parameter                              pte0_seq_offset = htw_lsu_addr_offset + `REAL_ADDR_WIDTH;
      parameter                              pte0_score_ptr_offset = pte0_seq_offset + `PTE_SEQ_WIDTH;
      parameter                              pte0_score_cl_offset_offset = pte0_score_ptr_offset + 2;
      parameter                              pte0_score_error_offset = pte0_score_cl_offset_offset + 3;
      parameter                              pte0_score_qwbeat_offset = pte0_score_error_offset + 3;
      parameter                              pte0_score_ibit_offset = pte0_score_qwbeat_offset + 4;
      parameter                              pte0_score_pending_offset = pte0_score_ibit_offset + 1;
      parameter                              pte0_score_dataval_offset = pte0_score_pending_offset + 1;
      parameter                              pte1_seq_offset = pte0_score_dataval_offset + 1;
      parameter                              pte1_score_ptr_offset = pte1_seq_offset + `PTE_SEQ_WIDTH;
      parameter                              pte1_score_cl_offset_offset = pte1_score_ptr_offset + 2;
      parameter                              pte1_score_error_offset = pte1_score_cl_offset_offset + 3;
      parameter                              pte1_score_qwbeat_offset = pte1_score_error_offset + 3;
      parameter                              pte1_score_ibit_offset = pte1_score_qwbeat_offset + 4;
      parameter                              pte1_score_pending_offset = pte1_score_ibit_offset + 1;
      parameter                              pte1_score_dataval_offset = pte1_score_pending_offset + 1;
      parameter                              pte_load_ptr_offset = pte1_score_dataval_offset + 1;
      parameter                              ptereload_ptr_offset = pte_load_ptr_offset + 1;
      //  ptereload_ptr_offset + 1 phase
      parameter                              reld_core_tag_tm1_offset = ptereload_ptr_offset + 1;
      parameter                              reld_qw_tm1_offset = reld_core_tag_tm1_offset + 5;
      parameter                              reld_crit_qw_tm1_offset = reld_qw_tm1_offset + 2;
      parameter                              reld_ditc_tm1_offset = reld_crit_qw_tm1_offset + 1;
      parameter                              reld_data_vld_tm1_offset = reld_ditc_tm1_offset + 1;
      //  reld_data_vld_tm1_offset + 1 phase
      parameter                              reld_core_tag_t_offset = reld_data_vld_tm1_offset + 1;
      parameter                              reld_qw_t_offset = reld_core_tag_t_offset + 5;
      parameter                              reld_crit_qw_t_offset = reld_qw_t_offset + 2;
      parameter                              reld_ditc_t_offset = reld_crit_qw_t_offset + 1;
      parameter                              reld_data_vld_t_offset = reld_ditc_t_offset + 1;
      //  reld_data_vld_t_offset + 1 phase
      parameter                              reld_core_tag_tp1_offset = reld_data_vld_t_offset + 1;
      parameter                              reld_qw_tp1_offset = reld_core_tag_tp1_offset + 5;
      parameter                              reld_crit_qw_tp1_offset = reld_qw_tp1_offset + 2;
      parameter                              reld_ditc_tp1_offset = reld_crit_qw_tp1_offset + 1;
      parameter                              reld_data_vld_tp1_offset = reld_ditc_tp1_offset + 1;
      //  reld_data_vld_tp1_offset + 1 phase
      parameter                              reld_core_tag_tp2_offset = reld_data_vld_tp1_offset + 1;
      parameter                              reld_qw_tp2_offset = reld_core_tag_tp2_offset + 5;
      parameter                              reld_crit_qw_tp2_offset = reld_qw_tp2_offset + 2;
      parameter                              reld_ditc_tp2_offset = reld_crit_qw_tp2_offset + 1;
      parameter                              reld_data_vld_tp2_offset = reld_ditc_tp2_offset + 1;
      parameter                              reld_ecc_err_tp2_offset = reld_data_vld_tp2_offset + 1;
      parameter                              reld_ecc_err_ue_tp2_offset = reld_ecc_err_tp2_offset + 1;
      parameter                              reld_data_tp1_offset = reld_ecc_err_ue_tp2_offset + 1;
      parameter                              reld_data_tp2_offset = reld_data_tp1_offset + 128;
      parameter                              pte0_reld_data_tp3_offset = reld_data_tp2_offset + 128;
      parameter                              pte1_reld_data_tp3_offset = pte0_reld_data_tp3_offset + 64;
      parameter                              htw_tag3_offset = pte1_reld_data_tp3_offset + 64;
      parameter                              htw_tag4_clr_resv_offset = htw_tag3_offset + `TLB_TAG_WIDTH;
      parameter                              htw_tag5_clr_resv_offset = htw_tag4_clr_resv_offset + `THDID_WIDTH;
      parameter                              spare_b_offset = htw_tag5_clr_resv_offset + `THDID_WIDTH;
      parameter                              scan_right_1 = spare_b_offset + 16 - 1;

`ifdef MM_THREADS2
      parameter                      BUGSP_MM_THREADS = 2;
`else
      parameter                      BUGSP_MM_THREADS = 1;
`endif

      //tlb_tag0_d <= ( 0:51   epn &
      //                52:65  pid &
      //                66:67  IS, or derat_ttype &
      //                68:69  Class &
      //                70:73  state (pr,gs,as,cm) &
      //                74:77  thdid &
      //                78:81  size &
      //                82:83  derat_miss/ierat_miss &
      //                84:85  tlbsx/tlbsrx &
      //                86:87  inval_snoop/tlbre &
      //                88:89  tlbwe/ptereload &
      //                90:97  lpid &
      //                98  indirect
      //                99  atsel &
      //                100:102  esel, or ptereload errors &
      //                103:105  hes/wq(0:1) &
      //                106:107  ltwe/lpte &
      //                108  recform, or ptrpn for ptereloads
      //                109  endflag

      // ttype: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload

      // state: 0:pr 1:gs 2:as 3:cm

      // Latch signals
      reg [0:1]                              htw_seq_d;
      wire [0:1]                             htw_seq_q;
      wire [0:1]                             htw_inptr_d;
      wire [0:1]                             htw_inptr_q;
      wire [0:1]                             htw_lsuptr_d;
      wire [0:1]                             htw_lsuptr_q;
      wire [0:1]                             htw_lsu_ttype_d;
      wire [0:1]                             htw_lsu_ttype_q;
      wire [0:`THDID_WIDTH-1]                 htw_lsu_thdid_d;
      wire [0:`THDID_WIDTH-1]                 htw_lsu_thdid_q;
      wire [0:4]                             htw_lsu_wimge_d;
      wire [0:4]                             htw_lsu_wimge_q;
      wire [0:3]                             htw_lsu_u_d;
      wire [0:3]                             htw_lsu_u_q;
      wire [64-`REAL_ADDR_WIDTH:63]           htw_lsu_addr_d;
      wire [64-`REAL_ADDR_WIDTH:63]           htw_lsu_addr_q;
      reg [0:2]                              pte0_seq_d;
      wire [0:2]                             pte0_seq_q;
      wire [0:1]                             pte0_score_ptr_d;
      wire [0:1]                             pte0_score_ptr_q;
      wire [58:60]                           pte0_score_cl_offset_d;
      wire [58:60]                           pte0_score_cl_offset_q;
      wire [0:2]                             pte0_score_error_d;
      wire [0:2]                             pte0_score_error_q;
      wire [0:3]                             pte0_score_qwbeat_d;
      wire [0:3]                             pte0_score_qwbeat_q;
      wire                                   pte0_score_pending_d;
      wire                                   pte0_score_pending_q;
      wire                                   pte0_score_ibit_d;
      wire                                   pte0_score_ibit_q;
      wire                                   pte0_score_dataval_d;
      wire                                   pte0_score_dataval_q;
      reg [0:2]                              pte1_seq_d;
      wire [0:2]                             pte1_seq_q;
      wire [0:1]                             pte1_score_ptr_d;
      wire [0:1]                             pte1_score_ptr_q;
      wire [58:60]                           pte1_score_cl_offset_d;
      wire [58:60]                           pte1_score_cl_offset_q;
      wire [0:2]                             pte1_score_error_d;
      wire [0:2]                             pte1_score_error_q;
      wire [0:3]                             pte1_score_qwbeat_d;
      wire [0:3]                             pte1_score_qwbeat_q;
      wire                                   pte1_score_pending_d;
      wire                                   pte1_score_pending_q;
      wire                                   pte1_score_ibit_d;
      wire                                   pte1_score_ibit_q;
      wire                                   pte1_score_dataval_d;
      wire                                   pte1_score_dataval_q;
      wire                                   ptereload_ptr_d;
      wire                                   ptereload_ptr_q;
      wire                                   pte_load_ptr_d;
      wire                                   pte_load_ptr_q;
      wire                                   tlb_htw_req0_valid_d;
      wire                                   tlb_htw_req0_valid_q;
      wire                                   tlb_htw_req0_pending_d;
      wire                                   tlb_htw_req0_pending_q;
      wire [0:`TLB_TAG_WIDTH-1]               tlb_htw_req0_tag_d;
      wire [0:`TLB_TAG_WIDTH-1]               tlb_htw_req0_tag_q;
      wire [`TLB_WORD_WIDTH:`TLB_WAY_WIDTH-1]  tlb_htw_req0_way_d;
      wire [`TLB_WORD_WIDTH:`TLB_WAY_WIDTH-1]  tlb_htw_req0_way_q;
      wire                                   tlb_htw_req0_tag_act;
      wire                                   tlb_htw_req1_valid_d;
      wire                                   tlb_htw_req1_valid_q;
      wire                                   tlb_htw_req1_pending_d;
      wire                                   tlb_htw_req1_pending_q;
      wire [0:`TLB_TAG_WIDTH-1]               tlb_htw_req1_tag_d;
      wire [0:`TLB_TAG_WIDTH-1]               tlb_htw_req1_tag_q;
      wire [`TLB_WORD_WIDTH:`TLB_WAY_WIDTH-1]  tlb_htw_req1_way_d;
      wire [`TLB_WORD_WIDTH:`TLB_WAY_WIDTH-1]  tlb_htw_req1_way_q;
      wire                                   tlb_htw_req1_tag_act;
      wire                                   tlb_htw_req2_valid_d;
      wire                                   tlb_htw_req2_valid_q;
      wire                                   tlb_htw_req2_pending_d;
      wire                                   tlb_htw_req2_pending_q;
      wire [0:`TLB_TAG_WIDTH-1]               tlb_htw_req2_tag_d;
      wire [0:`TLB_TAG_WIDTH-1]               tlb_htw_req2_tag_q;
      wire [`TLB_WORD_WIDTH:`TLB_WAY_WIDTH-1]  tlb_htw_req2_way_d;
      wire [`TLB_WORD_WIDTH:`TLB_WAY_WIDTH-1]  tlb_htw_req2_way_q;
      wire                                   tlb_htw_req2_tag_act;
      wire                                   tlb_htw_req3_valid_d;
      wire                                   tlb_htw_req3_valid_q;
      wire                                   tlb_htw_req3_pending_d;
      wire                                   tlb_htw_req3_pending_q;
      wire [0:`TLB_TAG_WIDTH-1]               tlb_htw_req3_tag_d;
      wire [0:`TLB_TAG_WIDTH-1]               tlb_htw_req3_tag_q;
      wire [`TLB_WORD_WIDTH:`TLB_WAY_WIDTH-1]  tlb_htw_req3_way_d;
      wire [`TLB_WORD_WIDTH:`TLB_WAY_WIDTH-1]  tlb_htw_req3_way_q;
      wire                                   tlb_htw_req3_tag_act;
      //  t minus 1 phase
      wire [0:4]                             reld_core_tag_tm1_d;
      wire [0:4]                             reld_core_tag_tm1_q;
      wire [0:1]                             reld_qw_tm1_d;
      wire [0:1]                             reld_qw_tm1_q;
      wire                                   reld_crit_qw_tm1_d;
      wire                                   reld_crit_qw_tm1_q;
      wire                                   reld_ditc_tm1_d;
      wire                                   reld_ditc_tm1_q;
      wire                                   reld_data_vld_tm1_d;
      wire                                   reld_data_vld_tm1_q;
      //  t   phase
      wire [0:4]                             reld_core_tag_t_d;
      wire [0:4]                             reld_core_tag_t_q;
      wire [0:1]                             reld_qw_t_d;
      wire [0:1]                             reld_qw_t_q;
      wire                                   reld_crit_qw_t_d;
      wire                                   reld_crit_qw_t_q;
      wire                                   reld_ditc_t_d;
      wire                                   reld_ditc_t_q;
      wire                                   reld_data_vld_t_d;
      wire                                   reld_data_vld_t_q;
      //  t plus 1 phase
      wire [0:4]                             reld_core_tag_tp1_d;
      wire [0:4]                             reld_core_tag_tp1_q;
      wire [0:1]                             reld_qw_tp1_d;
      wire [0:1]                             reld_qw_tp1_q;
      wire                                   reld_crit_qw_tp1_d;
      wire                                   reld_crit_qw_tp1_q;
      wire                                   reld_ditc_tp1_d;
      wire                                   reld_ditc_tp1_q;
      wire                                   reld_data_vld_tp1_d;
      wire                                   reld_data_vld_tp1_q;
      wire [0:127]                           reld_data_tp1_d;
      wire [0:127]                           reld_data_tp1_q;
      //  t plus 2 phase
      wire [0:4]                             reld_core_tag_tp2_d;
      wire [0:4]                             reld_core_tag_tp2_q;
      wire [0:1]                             reld_qw_tp2_d;
      wire [0:1]                             reld_qw_tp2_q;
      wire                                   reld_crit_qw_tp2_d;
      wire                                   reld_crit_qw_tp2_q;
      wire                                   reld_ditc_tp2_d;
      wire                                   reld_ditc_tp2_q;
      wire                                   reld_data_vld_tp2_d;
      wire                                   reld_data_vld_tp2_q;
      wire [0:127]                           reld_data_tp2_d;
      wire [0:127]                           reld_data_tp2_q;
      wire                                   reld_ecc_err_tp2_d;
      wire                                   reld_ecc_err_tp2_q;
      wire                                   reld_ecc_err_ue_tp2_d;
      wire                                   reld_ecc_err_ue_tp2_q;
      //  t plus 3 phase
      wire [0:63]                            pte0_reld_data_tp3_d;
      wire [0:63]                            pte0_reld_data_tp3_q;
      wire [0:63]                            pte1_reld_data_tp3_d;
      wire [0:63]                            pte1_reld_data_tp3_q;
      wire [0:`TLB_TAG_WIDTH-1]               htw_tag3_d;
      wire [0:`TLB_TAG_WIDTH-1]               htw_tag3_q;
      wire [0:`THDID_WIDTH-1]                 htw_tag3_clr_resv_term2;
      wire [0:`THDID_WIDTH-1]                 htw_tag3_clr_resv_term4;
      wire [0:`THDID_WIDTH-1]                 htw_tag3_clr_resv_term5;
      wire [0:`THDID_WIDTH-1]                 htw_tag3_clr_resv_term6;
      wire [0:`THDID_WIDTH-1]                 htw_tag3_clr_resv_term7;
      wire [0:`THDID_WIDTH-1]                 htw_tag3_clr_resv_term8;
      wire [0:`THDID_WIDTH-1]                 htw_tag3_clr_resv_term9;
      wire [0:`THDID_WIDTH-1]                 htw_tag3_clr_resv_term11;
      wire [0:`THDID_WIDTH-1]                 htw_tag4_clr_resv_d;
      wire [0:`THDID_WIDTH-1]                 htw_tag4_clr_resv_q;
      wire [0:`THDID_WIDTH-1]                 htw_tag5_clr_resv_d;
      wire [0:`THDID_WIDTH-1]                 htw_tag5_clr_resv_q;
      wire [0:15]                            spare_a_q;
      wire [0:15]                            spare_b_q;
      // logic signals
      wire                                   htw_seq_idle;
      reg                                    htw_seq_load_pteaddr;
      wire [0:`THDID_WIDTH-1]                 htw_quiesce_b;
      wire [0:`THDID_WIDTH-1]                 tlb_htw_req_valid_vec;
      wire [0:`THDID_WIDTH-1]                 tlb_htw_req_valid_notpend_vec;
      wire                                   tlb_htw_pte_machines_full;
      wire [0:1]                             htw_lsuptr_alt_d;
      wire                                   pte0_seq_idle;
      reg                                    pte0_reload_req_valid;
      reg                                    pte0_reload_req_taken;
      wire                                   pte0_reld_for_me_tm1;
      wire                                   pte0_reld_for_me_tp2;
      reg                                    pte0_reld_enable_lo_tp2;
      reg                                    pte0_reld_enable_hi_tp2;
      reg                                    pte0_seq_score_load;
      reg                                    pte0_seq_score_done;
      reg                                    pte0_seq_data_retry;
      reg                                    pte0_seq_clr_resv_ue;
      wire                                   pte1_seq_idle;
      reg                                    pte1_reload_req_valid;
      reg                                    pte1_reload_req_taken;
      wire                                   pte1_reld_for_me_tm1;
      wire                                   pte1_reld_for_me_tp2;
      reg                                    pte1_reld_enable_lo_tp2;
      reg                                    pte1_reld_enable_hi_tp2;
      reg                                    pte1_seq_score_load;
      reg                                    pte1_seq_score_done;
      reg                                    pte1_seq_data_retry;
      reg                                    pte1_seq_clr_resv_ue;
      wire [64-`REAL_ADDR_WIDTH:63]           pte_ra_0;
      wire [64-`REAL_ADDR_WIDTH:63]           pte_ra_0_spsize4K;
      wire [64-`REAL_ADDR_WIDTH:63]           pte_ra_0_spsize64K;
      wire [64-`REAL_ADDR_WIDTH:63]           pte_ra_1;
      wire [64-`REAL_ADDR_WIDTH:63]           pte_ra_1_spsize4K;
      wire [64-`REAL_ADDR_WIDTH:63]           pte_ra_1_spsize64K;
      wire [64-`REAL_ADDR_WIDTH:63]           pte_ra_2;
      wire [64-`REAL_ADDR_WIDTH:63]           pte_ra_2_spsize4K;
      wire [64-`REAL_ADDR_WIDTH:63]           pte_ra_2_spsize64K;
      wire [64-`REAL_ADDR_WIDTH:63]           pte_ra_3;
      wire [64-`REAL_ADDR_WIDTH:63]           pte_ra_3_spsize4K;
      wire [64-`REAL_ADDR_WIDTH:63]           pte_ra_3_spsize64K;
      wire                                   htw_resv0_tag3_lpid_match;
      wire                                   htw_resv0_tag3_pid_match;
      wire                                   htw_resv0_tag3_as_match;
      wire                                   htw_resv0_tag3_gs_match;
      wire                                   htw_resv0_tag3_epn_loc_match;
      wire                                   htw_resv0_tag3_epn_glob_match;
      wire                                   tlb_htw_req0_clr_resv_ue;
      wire                                   htw_resv1_tag3_lpid_match;
      wire                                   htw_resv1_tag3_pid_match;
      wire                                   htw_resv1_tag3_as_match;
      wire                                   htw_resv1_tag3_gs_match;
      wire                                   htw_resv1_tag3_epn_loc_match;
      wire                                   htw_resv1_tag3_epn_glob_match;
      wire                                   tlb_htw_req1_clr_resv_ue;
      wire                                   htw_resv2_tag3_lpid_match;
      wire                                   htw_resv2_tag3_pid_match;
      wire                                   htw_resv2_tag3_as_match;
      wire                                   htw_resv2_tag3_gs_match;
      wire                                   htw_resv2_tag3_epn_loc_match;
      wire                                   htw_resv2_tag3_epn_glob_match;
      wire                                   tlb_htw_req2_clr_resv_ue;
      wire                                   htw_resv3_tag3_lpid_match;
      wire                                   htw_resv3_tag3_pid_match;
      wire                                   htw_resv3_tag3_as_match;
      wire                                   htw_resv3_tag3_gs_match;
      wire                                   htw_resv3_tag3_epn_loc_match;
      wire                                   htw_resv3_tag3_epn_glob_match;
      wire                                   tlb_htw_req3_clr_resv_ue;
      wire [0:`THDID_WIDTH-1]                 htw_resv_valid_vec;
      wire [0:3]                             htw_tag4_clr_resv_terms;
      wire                                   htw_lsu_act;
      wire                                   pte0_score_act;
      wire                                   pte1_score_act;
      wire                                   reld_act;
      wire                                   pte0_reld_act;
      wire                                   pte1_reld_act;
      (* analysis_not_referenced="true" *)
      wire [0:21]                            unused_dc;

      // Pervasive
      wire                                   pc_sg_1;
      wire                                   pc_sg_0;
      wire                                   pc_func_sl_thold_1;
      wire                                   pc_func_sl_thold_0;
      wire                                   pc_func_sl_thold_0_b;
      wire                                   pc_func_slp_sl_thold_1;
      wire                                   pc_func_slp_sl_thold_0;
      wire                                   pc_func_slp_sl_thold_0_b;
      wire                                   pc_func_sl_force;
      wire                                   pc_func_slp_sl_force;
      wire [0:scan_right_0]                  siv_0;
      wire [0:scan_right_0]                  sov_0;
      wire [0:scan_right_1]                  siv_1;
      wire [0:scan_right_1]                  sov_1;
      //@@ START OF EXECUTABLE CODE FOR MMQ_HTW

      //begin
      //!! Bugspray Include: mmq_htw;

      //---------------------------------------------------------------------
      // Logic
      //---------------------------------------------------------------------

      // not quiesced
      assign htw_quiesce_b[0:`THDID_WIDTH - 1] = ({`THDID_WIDTH{tlb_htw_req0_valid_q}} & tlb_htw_req0_tag_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) |
                                                   ({`THDID_WIDTH{tlb_htw_req1_valid_q}} & tlb_htw_req1_tag_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) |
                                                   ({`THDID_WIDTH{tlb_htw_req2_valid_q}} & tlb_htw_req2_tag_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) |
                                                   ({`THDID_WIDTH{tlb_htw_req3_valid_q}} & tlb_htw_req3_tag_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]);
      assign htw_quiesce = (~htw_quiesce_b);

      assign tlb_htw_pte_machines_full = ((pte0_score_pending_q == 1'b1 & pte1_score_pending_q == 1'b1)) ? 1'b1 :
                                         1'b0;

      assign tlb_htw_req_valid_vec = { (tlb_htw_req0_valid_q & (pte0_score_pending_q == 1'b0 | pte0_score_ptr_q != 2'b00) & (pte1_score_pending_q == 1'b0 | pte1_score_ptr_q != 2'b00)),
                                          (tlb_htw_req1_valid_q & (pte0_score_pending_q == 1'b0 | pte0_score_ptr_q != 2'b01) & (pte1_score_pending_q == 1'b0 | pte1_score_ptr_q != 2'b01)),
                                          (tlb_htw_req2_valid_q & (pte0_score_pending_q == 1'b0 | pte0_score_ptr_q != 2'b10) & (pte1_score_pending_q == 1'b0 | pte1_score_ptr_q != 2'b10)),
                                          (tlb_htw_req3_valid_q & (pte0_score_pending_q == 1'b0 | pte0_score_ptr_q != 2'b11) & (pte1_score_pending_q == 1'b0 | pte1_score_ptr_q != 2'b11)) };


      // HTW sequencer for servicing indirect tlb entry hits
      always @(htw_seq_q or tlb_htw_req_valid_vec or tlb_htw_pte_machines_full or htw_lsu_req_taken)
      begin: Htw_Sequencer
         htw_seq_load_pteaddr <= 1'b0;
         htw_lsu_req_valid <= 1'b0;
         case (htw_seq_q)
            HtwSeq_Idle :
               if (tlb_htw_req_valid_vec != 4'b0000 & tlb_htw_pte_machines_full == 1'b0)
                  htw_seq_d <= HtwSeq_Stg1;
               else
                  htw_seq_d <= HtwSeq_Idle;
            HtwSeq_Stg1 :
               begin
                  htw_seq_load_pteaddr <= 1'b1;
                  htw_seq_d <= HtwSeq_Stg2;
               end

            HtwSeq_Stg2 :
               begin
                  htw_lsu_req_valid <= 1'b1;
                  if (htw_lsu_req_taken == 1'b1)
                     htw_seq_d <= HtwSeq_Idle;
                  else
                     htw_seq_d <= HtwSeq_Stg2;
               end

            default :
               htw_seq_d <= HtwSeq_Idle;

         endcase
      end
      assign htw_seq_idle = (htw_seq_q == HtwSeq_Idle) ? 1'b1 :
                            1'b0;

      // PTE sequencer for servicing pte data reloads

      always @(pte0_seq_q or pte_load_ptr_q or ptereload_ptr_q or htw_lsu_req_taken or ptereload_req_taken or pte0_score_pending_q or pte0_score_dataval_q or pte0_score_error_q or pte0_score_qwbeat_q or pte0_score_ibit_q)
      begin: Pte0_Sequencer
         pte0_reload_req_valid <= 1'b0;
         pte0_reload_req_taken <= 1'b0;
         pte0_seq_score_load <= 1'b0;
         pte0_seq_score_done <= 1'b0;
         pte0_seq_data_retry <= 1'b0;
         pte0_reld_enable_lo_tp2 <= 1'b0;
         pte0_reld_enable_hi_tp2 <= 1'b0;
         pte0_seq_clr_resv_ue <= 1'b0;
         case (pte0_seq_q)
            PteSeq_Idle :
               if (pte_load_ptr_q == 1'b0 & htw_lsu_req_taken == 1'b1)
               begin
                  pte0_seq_score_load <= 1'b1;
                  pte0_seq_d <= PteSeq_Stg1;
               end
               else
                  pte0_seq_d <= PteSeq_Idle;
            PteSeq_Stg1 :
               if (pte0_score_pending_q == 1'b1 & pte0_score_dataval_q == 1'b1)
                  pte0_seq_d <= PteSeq_Stg2;
               else
                  pte0_seq_d <= PteSeq_Stg1;

            PteSeq_Stg2 :
               if (pte0_score_error_q[1] == 1'b1 & (pte0_score_qwbeat_q == 4'b1111 | pte0_score_ibit_q == 1'b1))
                  pte0_seq_d <= PteSeq_Stg4;
               else if (pte0_score_error_q == 3'b100 & (pte0_score_qwbeat_q == 4'b1111 | pte0_score_ibit_q == 1'b1))
               begin
                  pte0_seq_data_retry <= 1'b1;
                  pte0_seq_d <= PteSeq_Stg1;
               end
               else if (pte0_score_error_q[1] == 1'b0 & (pte0_score_qwbeat_q == 4'b1111 | pte0_score_ibit_q == 1'b1))
                  pte0_seq_d <= PteSeq_Stg3;
               else
                  pte0_seq_d <= PteSeq_Stg2;

            PteSeq_Stg3 :
               begin
                  pte0_reload_req_valid <= 1'b1;
                  if (ptereload_ptr_q == 1'b0 & ptereload_req_taken == 1'b1)
                  begin
                     pte0_seq_score_done <= 1'b1;
                     pte0_reload_req_taken <= 1'b1;
                     pte0_seq_d <= PteSeq_Idle;
                  end
                  else
                     pte0_seq_d <= PteSeq_Stg3;
               end

            PteSeq_Stg4 :
               begin
                  pte0_seq_clr_resv_ue <= 1'b1;
                  pte0_seq_d <= PteSeq_Stg5;
               end

            PteSeq_Stg5 :
               begin
                  pte0_reload_req_valid <= 1'b1;
                  if (ptereload_ptr_q == 1'b0 & ptereload_req_taken == 1'b1)
                  begin
                     pte0_seq_score_done <= 1'b1;
                     pte0_reload_req_taken <= 1'b1;
                     pte0_seq_d <= PteSeq_Idle;
                  end
                  else
                     pte0_seq_d <= PteSeq_Stg5;
               end

            default :
               pte0_seq_d <= PteSeq_Idle;

         endcase
      end
      assign pte0_seq_idle = (pte0_seq_q == PteSeq_Idle) ? 1'b1 :
                             1'b0;
      // PTE sequencer for servicing pte data reloads

      always @(pte1_seq_q or pte_load_ptr_q or ptereload_ptr_q or htw_lsu_req_taken or ptereload_req_taken or pte1_score_pending_q or pte1_score_dataval_q or pte1_score_error_q or pte1_score_qwbeat_q or pte1_score_ibit_q)
      begin: Pte1_Sequencer
         pte1_reload_req_valid <= 1'b0;
         pte1_reload_req_taken <= 1'b0;
         pte1_seq_score_load <= 1'b0;
         pte1_seq_score_done <= 1'b0;
         pte1_seq_data_retry <= 1'b0;
         pte1_reld_enable_lo_tp2 <= 1'b0;
         pte1_reld_enable_hi_tp2 <= 1'b0;
         pte1_seq_clr_resv_ue <= 1'b0;
         case (pte1_seq_q)
            PteSeq_Idle :
               if (pte_load_ptr_q == 1'b1 & htw_lsu_req_taken == 1'b1)
               begin
                  pte1_seq_score_load <= 1'b1;
                  pte1_seq_d <= PteSeq_Stg1;
               end
               else
                  pte1_seq_d <= PteSeq_Idle;
            PteSeq_Stg1 :
               if (pte1_score_pending_q == 1'b1 & pte1_score_dataval_q == 1'b1)
                  pte1_seq_d <= PteSeq_Stg2;
               else
                  pte1_seq_d <= PteSeq_Stg1;

            PteSeq_Stg2 :
               if (pte1_score_error_q[1] == 1'b1 & (pte1_score_qwbeat_q == 4'b1111 | pte1_score_ibit_q == 1'b1))
                  pte1_seq_d <= PteSeq_Stg4;
               else if (pte1_score_error_q == 3'b100 & (pte1_score_qwbeat_q == 4'b1111 | pte1_score_ibit_q == 1'b1))
               begin
                  pte1_seq_data_retry <= 1'b1;
                  pte1_seq_d <= PteSeq_Stg1;
               end
               else if (pte1_score_error_q[1] == 1'b0 & (pte1_score_qwbeat_q == 4'b1111 | pte1_score_ibit_q == 1'b1))
                  pte1_seq_d <= PteSeq_Stg3;
               else
                  pte1_seq_d <= PteSeq_Stg2;

            PteSeq_Stg3 :
               begin
                  pte1_reload_req_valid <= 1'b1;
                  if (ptereload_ptr_q == 1'b1 & ptereload_req_taken == 1'b1)
                  begin
                     pte1_seq_score_done <= 1'b1;
                     pte1_reload_req_taken <= 1'b1;
                     pte1_seq_d <= PteSeq_Idle;
                  end
                  else
                     pte1_seq_d <= PteSeq_Stg3;
               end

            PteSeq_Stg4 :
               begin
                  pte1_seq_clr_resv_ue <= 1'b1;
                  pte1_seq_d <= PteSeq_Stg5;
               end

            PteSeq_Stg5 :
               begin
                  pte1_reload_req_valid <= 1'b1;
                  if (ptereload_ptr_q == 1'b1 & ptereload_req_taken == 1'b1)
                  begin
                     pte1_seq_score_done <= 1'b1;
                     pte1_reload_req_taken <= 1'b1;
                     pte1_seq_d <= PteSeq_Idle;
                  end
                  else
                     pte1_seq_d <= PteSeq_Stg5;
               end

            default :
               pte1_seq_d <= PteSeq_Idle;

         endcase
      end
      assign pte1_seq_idle = (pte1_seq_q == PteSeq_Idle) ? 1'b1 :
                             1'b0;
      //  tlb_way  IND=0    IND=1
      //   134      UX     SPSIZE0
      //   135      SX     SPSIZE1
      //   136      UW     SPSIZE2
      //   137      SW     SPSIZE3
      //   138      UR     PTRPN
      //   139      SR     PA52
      assign tlb_htw_req0_valid_d = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req0_valid_q == 1'b0 & htw_inptr_q == 2'b00)) ? 1'b1 :
                                    ((pte0_reload_req_taken == 1'b1 & tlb_htw_req0_valid_q == 1'b1 & pte0_score_ptr_q == 2'b00)) ? 1'b0 :
                                    ((pte1_reload_req_taken == 1'b1 & tlb_htw_req0_valid_q == 1'b1 & pte1_score_ptr_q == 2'b00)) ? 1'b0 :
                                    tlb_htw_req0_valid_q;
      assign tlb_htw_req0_pending_d = ((htw_lsu_req_taken == 1'b1 & tlb_htw_req0_pending_q == 1'b0 & htw_lsuptr_q == 2'b00)) ? 1'b1 :
                                      ((pte0_reload_req_taken == 1'b1 & tlb_htw_req0_pending_q == 1'b1 & pte0_score_ptr_q == 2'b00)) ? 1'b0 :
                                      ((pte1_reload_req_taken == 1'b1 & tlb_htw_req0_pending_q == 1'b1 & pte1_score_ptr_q == 2'b00)) ? 1'b0 :
                                      tlb_htw_req0_pending_q;
      // the  rpn  part of the tlb way
      assign tlb_htw_req0_way_d = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req0_valid_q == 1'b0 & htw_inptr_q == 2'b00)) ? tlb_htw_req_way :
                                  tlb_htw_req0_way_q;
      assign tlb_htw_req0_tag_d[0:`tagpos_wq - 1] = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req0_valid_q == 1'b0 & htw_inptr_q == 2'b00)) ? tlb_htw_req_tag[0:`tagpos_wq - 1] :
                                                   tlb_htw_req0_tag_q[0:`tagpos_wq - 1];
      assign tlb_htw_req0_tag_d[`tagpos_wq + 2:`TLB_TAG_WIDTH - 1] = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req0_valid_q == 1'b0 & htw_inptr_q == 2'b00)) ? tlb_htw_req_tag[`tagpos_wq + 2:`TLB_TAG_WIDTH - 1] :
                                                                   tlb_htw_req0_tag_q[`tagpos_wq + 2:`TLB_TAG_WIDTH - 1];
      // the WQ bits of the tag are re-purposed as reservation valid and duplicate bits
      //  set reservation valid at tlb handoff, clear when ptereload taken..
      //  or, clear reservation if tlbwe,ptereload,tlbi from another thread to avoid duplicates
      //  or, clear reservation when L2 UE for this reload
      assign tlb_htw_req0_tag_d[`tagpos_wq] = (((htw_tag5_clr_resv_q[0] == 1'b1 & |(tlb_tag5_except) == 1'b0) | tlb_htw_req0_clr_resv_ue == 1'b1)) ? 1'b0 :
                                             ((tlb_htw_req_valid == 1'b1 & tlb_htw_req0_valid_q == 1'b0 & htw_inptr_q == 2'b00)) ? 1'b1 :
                                             ((pte0_reload_req_taken == 1'b1 & tlb_htw_req0_valid_q == 1'b1 & pte0_score_ptr_q == 2'b00)) ? 1'b0 :
                                             ((pte1_reload_req_taken == 1'b1 & tlb_htw_req0_valid_q == 1'b1 & pte1_score_ptr_q == 2'b00)) ? 1'b0 :
                                             tlb_htw_req0_tag_q[`tagpos_wq];
      //  spare, wq+1 is duplicate indicator in tlb_cmp, but would not make it to tlb handoff
      assign tlb_htw_req0_tag_d[`tagpos_wq + 1] = tlb_htw_req0_tag_q[`tagpos_wq + 1];
      assign tlb_htw_req0_tag_act = tlb_delayed_act[24 + 0] | tlb_htw_req0_valid_q;

      assign tlb_htw_req0_clr_resv_ue = {(pte0_seq_clr_resv_ue & (pte0_score_ptr_q == 2'b00)) | (pte1_seq_clr_resv_ue & (pte1_score_ptr_q == 2'b00))};

      assign htw_req0_valid = tlb_htw_req0_valid_q;
      assign htw_req0_thdid = tlb_htw_req0_tag_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1];
      assign htw_req0_type = tlb_htw_req0_tag_q[`tagpos_type_derat:`tagpos_type_ierat];
      // FIX THESE!!!!!!  for 32bit generates into smaller RA's
      assign pte_ra_0_spsize4K = {tlb_htw_req0_way_q[`waypos_rpn:`waypos_rpn + `RPN_WIDTH - 1], tlb_htw_req0_way_q[`waypos_usxwr + 5], tlb_htw_req0_tag_q[`tagpos_epn + `EPN_WIDTH - 8:`tagpos_epn + `EPN_WIDTH - 1], 3'b000};
      assign pte_ra_0_spsize64K = {tlb_htw_req0_way_q[`waypos_rpn:`waypos_rpn + `RPN_WIDTH - 4], tlb_htw_req0_tag_q[`tagpos_epn + `EPN_WIDTH - 16:`tagpos_epn + `EPN_WIDTH - 5], 3'b000};
      // select based on SPSIZE
      assign pte_ra_0 = (tlb_htw_req0_way_q[`waypos_usxwr:`waypos_usxwr + 3] == TLB_PgSize_64KB) ? pte_ra_0_spsize64K :
                        pte_ra_0_spsize4K;
      assign tlb_htw_req1_valid_d = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req1_valid_q == 1'b0 & htw_inptr_q == 2'b01)) ? 1'b1 :
                                    ((pte0_reload_req_taken == 1'b1 & tlb_htw_req1_valid_q == 1'b1 & pte0_score_ptr_q == 2'b01)) ? 1'b0 :
                                    ((pte1_reload_req_taken == 1'b1 & tlb_htw_req1_valid_q == 1'b1 & pte1_score_ptr_q == 2'b01)) ? 1'b0 :
                                    tlb_htw_req1_valid_q;
      assign tlb_htw_req1_pending_d = ((htw_lsu_req_taken == 1'b1 & tlb_htw_req1_pending_q == 1'b0 & htw_lsuptr_q == 2'b01)) ? 1'b1 :
                                      ((pte0_reload_req_taken == 1'b1 & tlb_htw_req1_pending_q == 1'b1 & pte0_score_ptr_q == 2'b01)) ? 1'b0 :
                                      ((pte1_reload_req_taken == 1'b1 & tlb_htw_req1_pending_q == 1'b1 & pte1_score_ptr_q == 2'b01)) ? 1'b0 :
                                      tlb_htw_req1_pending_q;
      // the  rpn  part of the tlb way
      assign tlb_htw_req1_way_d = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req1_valid_q == 1'b0 & htw_inptr_q == 2'b01)) ? tlb_htw_req_way :
                                  tlb_htw_req1_way_q;
      assign tlb_htw_req1_tag_d[0:`tagpos_wq - 1] = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req1_valid_q == 1'b0 & htw_inptr_q == 2'b01)) ? tlb_htw_req_tag[0:`tagpos_wq - 1] :
                                                   tlb_htw_req1_tag_q[0:`tagpos_wq - 1];
      assign tlb_htw_req1_tag_d[`tagpos_wq + 2:`TLB_TAG_WIDTH - 1] = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req1_valid_q == 1'b0 & htw_inptr_q == 2'b01)) ? tlb_htw_req_tag[`tagpos_wq + 2:`TLB_TAG_WIDTH - 1] :
                                                                   tlb_htw_req1_tag_q[`tagpos_wq + 2:`TLB_TAG_WIDTH - 1];
      // the WQ bits of the tag are re-purposed as reservation valid and duplicate bits
      //  set reservation valid at tlb handoff, clear when ptereload taken..
      //  or, clear reservation if tlbwe,ptereload,tlbi from another thread to avoid duplicates
      //  or, clear reservation when L2 UE for this reload
      assign tlb_htw_req1_tag_d[`tagpos_wq] = (((htw_tag5_clr_resv_q[1] == 1'b1 & |(tlb_tag5_except) == 1'b0) | tlb_htw_req1_clr_resv_ue == 1'b1)) ? 1'b0 :
                                             ((tlb_htw_req_valid == 1'b1 & tlb_htw_req1_valid_q == 1'b0 & htw_inptr_q == 2'b01)) ? 1'b1 :
                                             ((pte0_reload_req_taken == 1'b1 & tlb_htw_req1_valid_q == 1'b1 & pte0_score_ptr_q == 2'b01)) ? 1'b0 :
                                             ((pte1_reload_req_taken == 1'b1 & tlb_htw_req1_valid_q == 1'b1 & pte1_score_ptr_q == 2'b01)) ? 1'b0 :
                                             tlb_htw_req1_tag_q[`tagpos_wq];
      //  spare, wq+1 is duplicate indicator in tlb_cmp, but would not make it to tlb handoff
      assign tlb_htw_req1_tag_d[`tagpos_wq + 1] = tlb_htw_req1_tag_q[`tagpos_wq + 1];
      assign tlb_htw_req1_tag_act = tlb_delayed_act[24 + 1] | tlb_htw_req1_valid_q;
      assign tlb_htw_req1_clr_resv_ue = {(pte0_seq_clr_resv_ue & (pte0_score_ptr_q == 2'b01)) | (pte1_seq_clr_resv_ue & (pte1_score_ptr_q == 2'b01))};
      assign htw_req1_valid = tlb_htw_req1_valid_q;
      assign htw_req1_thdid = tlb_htw_req1_tag_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1];
      assign htw_req1_type = tlb_htw_req1_tag_q[`tagpos_type_derat:`tagpos_type_ierat];
      // FIX THESE!!!!!!  for 32bit generates into smaller RA's
      assign pte_ra_1_spsize4K = {tlb_htw_req1_way_q[`waypos_rpn:`waypos_rpn + `RPN_WIDTH - 1], tlb_htw_req1_way_q[`waypos_usxwr + 5], tlb_htw_req1_tag_q[`tagpos_epn + `EPN_WIDTH - 8:`tagpos_epn + `EPN_WIDTH - 1], 3'b000};
      assign pte_ra_1_spsize64K = {tlb_htw_req1_way_q[`waypos_rpn:`waypos_rpn + `RPN_WIDTH - 4], tlb_htw_req1_tag_q[`tagpos_epn + `EPN_WIDTH - 16:`tagpos_epn + `EPN_WIDTH - 5], 3'b000};
      // select based on SPSIZE
      assign pte_ra_1 = (tlb_htw_req1_way_q[`waypos_usxwr:`waypos_usxwr + 3] == TLB_PgSize_64KB) ? pte_ra_1_spsize64K :
                        pte_ra_1_spsize4K;
      assign tlb_htw_req2_valid_d = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req2_valid_q == 1'b0 & htw_inptr_q == 2'b10)) ? 1'b1 :
                                    ((pte0_reload_req_taken == 1'b1 & tlb_htw_req2_valid_q == 1'b1 & pte0_score_ptr_q == 2'b10)) ? 1'b0 :
                                    ((pte1_reload_req_taken == 1'b1 & tlb_htw_req2_valid_q == 1'b1 & pte1_score_ptr_q == 2'b10)) ? 1'b0 :
                                    tlb_htw_req2_valid_q;
      assign tlb_htw_req2_pending_d = ((htw_lsu_req_taken == 1'b1 & tlb_htw_req2_pending_q == 1'b0 & htw_lsuptr_q == 2'b10)) ? 1'b1 :
                                      ((pte0_reload_req_taken == 1'b1 & tlb_htw_req2_pending_q == 1'b1 & pte0_score_ptr_q == 2'b10)) ? 1'b0 :
                                      ((pte1_reload_req_taken == 1'b1 & tlb_htw_req2_pending_q == 1'b1 & pte1_score_ptr_q == 2'b10)) ? 1'b0 :
                                      tlb_htw_req2_pending_q;
      // the  rpn  part of the tlb way
      assign tlb_htw_req2_way_d = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req2_valid_q == 1'b0 & htw_inptr_q == 2'b10)) ? tlb_htw_req_way :
                                  tlb_htw_req2_way_q;
      assign tlb_htw_req2_tag_d[0:`tagpos_wq - 1] = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req2_valid_q == 1'b0 & htw_inptr_q == 2'b10)) ? tlb_htw_req_tag[0:`tagpos_wq - 1] :
                                                   tlb_htw_req2_tag_q[0:`tagpos_wq - 1];
      assign tlb_htw_req2_tag_d[`tagpos_wq + 2:`TLB_TAG_WIDTH - 1] = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req2_valid_q == 1'b0 & htw_inptr_q == 2'b10)) ? tlb_htw_req_tag[`tagpos_wq + 2:`TLB_TAG_WIDTH - 1] :
                                                                   tlb_htw_req2_tag_q[`tagpos_wq + 2:`TLB_TAG_WIDTH - 1];
      // the WQ bits of the tag are re-purposed as reservation valid and duplicate bits
      //  set reservation valid at tlb handoff, clear when ptereload taken..
      //  or, clear reservation if tlbwe,ptereload,tlbi from another thread to avoid duplicates
      //  or, clear reservation when L2 UE for this reload
      assign tlb_htw_req2_tag_d[`tagpos_wq] = (((htw_tag5_clr_resv_q[2] == 1'b1 & |(tlb_tag5_except) == 1'b0) | tlb_htw_req2_clr_resv_ue == 1'b1)) ? 1'b0 :
                                             ((tlb_htw_req_valid == 1'b1 & tlb_htw_req2_valid_q == 1'b0 & htw_inptr_q == 2'b10)) ? 1'b1 :
                                             ((pte0_reload_req_taken == 1'b1 & tlb_htw_req2_valid_q == 1'b1 & pte0_score_ptr_q == 2'b10)) ? 1'b0 :
                                             ((pte1_reload_req_taken == 1'b1 & tlb_htw_req2_valid_q == 1'b1 & pte1_score_ptr_q == 2'b10)) ? 1'b0 :
                                             tlb_htw_req2_tag_q[`tagpos_wq];
      //  spare, wq+1 is duplicate indicator in tlb_cmp, but would not make it to tlb handoff
      assign tlb_htw_req2_tag_d[`tagpos_wq + 1] = tlb_htw_req2_tag_q[`tagpos_wq + 1];
      assign tlb_htw_req2_tag_act = tlb_delayed_act[24 + 2] | tlb_htw_req2_valid_q;
      assign tlb_htw_req2_clr_resv_ue = {(pte0_seq_clr_resv_ue & (pte0_score_ptr_q == 2'b10)) | (pte1_seq_clr_resv_ue & (pte1_score_ptr_q == 2'b10))};
      assign htw_req2_valid = tlb_htw_req2_valid_q;
      assign htw_req2_thdid = tlb_htw_req2_tag_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1];
      assign htw_req2_type = tlb_htw_req2_tag_q[`tagpos_type_derat:`tagpos_type_ierat];
      // FIX THESE!!!!!!  for 32bit generates into smaller RA's
      assign pte_ra_2_spsize4K = {tlb_htw_req2_way_q[`waypos_rpn:`waypos_rpn + `RPN_WIDTH - 1], tlb_htw_req2_way_q[`waypos_usxwr + 5], tlb_htw_req2_tag_q[`tagpos_epn + `EPN_WIDTH - 8:`tagpos_epn + `EPN_WIDTH - 1], 3'b000};
      assign pte_ra_2_spsize64K = {tlb_htw_req2_way_q[`waypos_rpn:`waypos_rpn + `RPN_WIDTH - 4], tlb_htw_req2_tag_q[`tagpos_epn + `EPN_WIDTH - 16:`tagpos_epn + `EPN_WIDTH - 5], 3'b000};
      // select based on SPSIZE
      assign pte_ra_2 = (tlb_htw_req2_way_q[`waypos_usxwr:`waypos_usxwr + 3] == TLB_PgSize_64KB) ? pte_ra_2_spsize64K :
                        pte_ra_2_spsize4K;
      assign tlb_htw_req3_valid_d = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req3_valid_q == 1'b0 & htw_inptr_q == 2'b11)) ? 1'b1 :
                                    ((pte0_reload_req_taken == 1'b1 & tlb_htw_req3_valid_q == 1'b1 & pte0_score_ptr_q == 2'b11)) ? 1'b0 :
                                    ((pte1_reload_req_taken == 1'b1 & tlb_htw_req3_valid_q == 1'b1 & pte1_score_ptr_q == 2'b11)) ? 1'b0 :
                                    tlb_htw_req3_valid_q;
      assign tlb_htw_req3_pending_d = ((htw_lsu_req_taken == 1'b1 & tlb_htw_req3_pending_q == 1'b0 & htw_lsuptr_q == 2'b11)) ? 1'b1 :
                                      ((pte0_reload_req_taken == 1'b1 & tlb_htw_req3_pending_q == 1'b1 & pte0_score_ptr_q == 2'b11)) ? 1'b0 :
                                      ((pte1_reload_req_taken == 1'b1 & tlb_htw_req3_pending_q == 1'b1 & pte1_score_ptr_q == 2'b11)) ? 1'b0 :
                                      tlb_htw_req3_pending_q;
      // the  rpn  part of the tlb way
      assign tlb_htw_req3_way_d = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req3_valid_q == 1'b0 & htw_inptr_q == 2'b11)) ? tlb_htw_req_way :
                                  tlb_htw_req3_way_q;
      assign tlb_htw_req3_tag_d[0:`tagpos_wq - 1] = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req3_valid_q == 1'b0 & htw_inptr_q == 2'b11)) ? tlb_htw_req_tag[0:`tagpos_wq - 1] :
                                                   tlb_htw_req3_tag_q[0:`tagpos_wq - 1];
      assign tlb_htw_req3_tag_d[`tagpos_wq + 2:`TLB_TAG_WIDTH - 1] = ((tlb_htw_req_valid == 1'b1 & tlb_htw_req3_valid_q == 1'b0 & htw_inptr_q == 2'b11)) ? tlb_htw_req_tag[`tagpos_wq + 2:`TLB_TAG_WIDTH - 1] :
                                                                   tlb_htw_req3_tag_q[`tagpos_wq + 2:`TLB_TAG_WIDTH - 1];
      // the WQ bits of the tag are re-purposed as reservation valid and duplicate bits
      //  set reservation valid at tlb handoff, clear when ptereload taken..
      //  or, clear reservation if tlbwe,ptereload,tlbi from another thread to avoid duplicates
      //  or, clear reservation when L2 UE for this reload
      assign tlb_htw_req3_tag_d[`tagpos_wq] = (((htw_tag5_clr_resv_q[3] == 1'b1 & |(tlb_tag5_except) == 1'b0) | tlb_htw_req3_clr_resv_ue == 1'b1)) ? 1'b0 :
                                             ((tlb_htw_req_valid == 1'b1 & tlb_htw_req3_valid_q == 1'b0 & htw_inptr_q == 2'b11)) ? 1'b1 :
                                             ((pte0_reload_req_taken == 1'b1 & tlb_htw_req3_valid_q == 1'b1 & pte0_score_ptr_q == 2'b11)) ? 1'b0 :
                                             ((pte1_reload_req_taken == 1'b1 & tlb_htw_req3_valid_q == 1'b1 & pte1_score_ptr_q == 2'b11)) ? 1'b0 :
                                             tlb_htw_req3_tag_q[`tagpos_wq];
      //  spare, wq+1 is duplicate indicator in tlb_cmp, but would not make it to tlb handoff
      assign tlb_htw_req3_tag_d[`tagpos_wq + 1] = tlb_htw_req3_tag_q[`tagpos_wq + 1];
      assign tlb_htw_req3_tag_act = tlb_delayed_act[24 + 3] | tlb_htw_req3_valid_q;
      assign tlb_htw_req3_clr_resv_ue = {(pte0_seq_clr_resv_ue & (pte0_score_ptr_q == 2'b11)) | (pte1_seq_clr_resv_ue & (pte1_score_ptr_q == 2'b11))};
      assign htw_req3_valid = tlb_htw_req3_valid_q;
      assign htw_req3_thdid = tlb_htw_req3_tag_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1];
      assign htw_req3_type = tlb_htw_req3_tag_q[`tagpos_type_derat:`tagpos_type_ierat];

      // FIX THESE!!!!!!  for 32bit generates into smaller RA's
      assign pte_ra_3_spsize4K = {tlb_htw_req3_way_q[`waypos_rpn:`waypos_rpn + `RPN_WIDTH - 1], tlb_htw_req3_way_q[`waypos_usxwr + 5], tlb_htw_req3_tag_q[`tagpos_epn + `EPN_WIDTH - 8:`tagpos_epn + `EPN_WIDTH - 1], 3'b000};
      assign pte_ra_3_spsize64K = {tlb_htw_req3_way_q[`waypos_rpn:`waypos_rpn + `RPN_WIDTH - 4], tlb_htw_req3_tag_q[`tagpos_epn + `EPN_WIDTH - 16:`tagpos_epn + `EPN_WIDTH - 5], 3'b000};
      // select based on SPSIZE
      assign pte_ra_3 = (tlb_htw_req3_way_q[`waypos_usxwr:`waypos_usxwr + 3] == TLB_PgSize_64KB) ? pte_ra_3_spsize64K :
                        pte_ra_3_spsize4K;
      // tag forwarding from tlb_ctl, for reservation clear compares
      assign htw_tag3_d[0:`tagpos_thdid - 1] = tlb_tag2[0:`tagpos_thdid - 1];
      assign htw_tag3_d[`tagpos_thdid + `THDID_WIDTH:`TLB_TAG_WIDTH - 1] = tlb_tag2[`tagpos_thdid + `THDID_WIDTH:`TLB_TAG_WIDTH - 1];
      assign htw_tag3_d[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] = tlb_tag2[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag2_flush));

      generate
         if (`THDID_WIDTH > `MM_THREADS)
         begin : htwtag3NExist
            assign htw_tag3_d[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1] = tlb_tag2[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1];
         end
      endgenerate

      //  reservation clear:
      //        (1) proc holding resv executes another tlbsrx. overwriting the old resv
      //        (2) any tlbivax snoop with gs,as,lpid,pid,sizemasked(epn,mas6.isize) matching resv.gs,as,lpid,pid,sizemasked(epn,mas6.isize)
      //             (note ind bit is not part of tlbivax criteria!!)
      //        (3) any proc sets mmucsr0.TLB0_FI=1 with lpidr matching resv.lpid
      //        (4) any proc executes tlbilx T=0 (all) with mas5.slpid matching resv.lpid
      //        (5) any proc executes tlbilx T=1 (pid) with mas5.slpid and mas6.spid matching resv.lpid,pid
      //        (6) any proc executes tlbilx T=3 (vpn) with mas gs,as,slpid,spid,sizemasked(epn,mas6.isize) matching
      //              resv.gs,as,lpid,pid,sizemasked(epn,mas6.isize)
      //              (note ind bit is not part of tlbilx criteria!!)
      //        (7) any proc executes tlbwe not causing exception and with (wq=00 always, or wq=01 and proc holds resv)
      //              and mas regs ind,tgs,ts,tlpid,tid,sizemasked(epn,mas1.tsize) match resv.ind,gs,as,lpid,pid,sizemasked(epn,mas1.tsize)
      //        (8) any page table reload not causing an exception (due to pt fault, tlb inelig, or lrat miss)
      //              and PTE's tag ind=0,tgs,ts,tlpid,tid,sizemasked(epn,pte.size) match resv.ind=0,gs,as,lpid,pid,sizemasked(epn.pte.size)
      //       A2-specific non-architected clear states
      //        (9) any proc executes tlbwe not causing exception and with (wq=10 clear, or wq=11 always (same as 00))
      //              and mas regs ind,tgs,ts,tlpid,tid,sizemasked(epn,mas1.tsize) match resv.ind,gs,as,lpid,pid,sizemasked(epn,mas1.tsize)
      //               (basically same as 7,
      //        (10) any proc executes tlbilx T=2 (gs) with mas5.sgs matching resv.gs
      //        (11) any proc executes tlbilx T=4 to 7 (class) with T(1:2) matching resv.class
      //  ttype <= tlbre & tlbwe & tlbsx & tlbsxr & tlbsrx;
      //  IS0: Local bit
      //  IS1/Class: 0=all, 1=tid, 2=gs, 3=vpn, 4=class0, 5=class1, 6=class2, 7=class3
      //  mas0.wq: 00=ignore reserv write always, 01=write if reserved, 10=clear reserv, 11=same as 00
      assign htw_tag3_clr_resv_term2[0] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b0011 &
                                              htw_resv0_tag3_lpid_match == 1'b1 & htw_resv0_tag3_pid_match == 1'b1 & htw_resv0_tag3_gs_match == 1'b1 &
                                              htw_resv0_tag3_as_match == 1'b1 & htw_resv0_tag3_epn_glob_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term4[0] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b1000 &
                                              htw_resv0_tag3_lpid_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term5[0] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b1001 &
                                              htw_resv0_tag3_lpid_match == 1'b1 & htw_resv0_tag3_pid_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term6[0] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b1011 &
                                              htw_resv0_tag3_lpid_match == 1'b1 & htw_resv0_tag3_pid_match == 1'b1 & htw_resv0_tag3_gs_match == 1'b1 &
                                              htw_resv0_tag3_as_match == 1'b1 & htw_resv0_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term7[0] = ((((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b01) |
                                               (|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b00)) &
                                                         htw_tag3_q[`tagpos_type_tlbwe] == 1'b1 & htw_resv0_tag3_gs_match == 1'b1 & htw_resv0_tag3_as_match == 1'b1 &
                                                         htw_resv0_tag3_lpid_match == 1'b1 & htw_resv0_tag3_pid_match == 1'b1 & htw_resv0_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term8[0] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_ptereload] == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b10 &
                                              htw_resv0_tag3_gs_match == 1'b1 & htw_resv0_tag3_as_match == 1'b1 & htw_resv0_tag3_lpid_match == 1'b1 &
                                              htw_resv0_tag3_pid_match == 1'b1 & htw_resv0_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term9[0] = ((((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS -1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b10) |
                                               (|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b11)) &
                                                          htw_tag3_q[`tagpos_type_tlbwe] == 1'b1 & htw_resv0_tag3_gs_match == 1'b1 & htw_resv0_tag3_as_match == 1'b1 &
                                                          htw_resv0_tag3_lpid_match == 1'b1 & htw_resv0_tag3_pid_match == 1'b1 & htw_resv0_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term11[0] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 1] == 2'b11)) ? 1'b1 :
                                           1'b0;
      assign htw_tag4_clr_resv_d[0] = htw_tag3_clr_resv_term2[0] | htw_tag3_clr_resv_term4[0] | htw_tag3_clr_resv_term5[0] | htw_tag3_clr_resv_term6[0] |
                                        htw_tag3_clr_resv_term7[0] | htw_tag3_clr_resv_term8[0] | htw_tag3_clr_resv_term9[0] | htw_tag3_clr_resv_term11[0];


      assign htw_tag3_clr_resv_term2[1] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b0011 &
                                              htw_resv1_tag3_lpid_match == 1'b1 & htw_resv1_tag3_pid_match == 1'b1 & htw_resv1_tag3_gs_match == 1'b1 &
                                              htw_resv1_tag3_as_match == 1'b1 & htw_resv1_tag3_epn_glob_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term4[1] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b1000 &
                                              htw_resv1_tag3_lpid_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term5[1] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b1001 &
                                              htw_resv1_tag3_lpid_match == 1'b1 & htw_resv1_tag3_pid_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term6[1] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b1011 &
                                              htw_resv1_tag3_lpid_match == 1'b1 & htw_resv1_tag3_pid_match == 1'b1 & htw_resv1_tag3_gs_match == 1'b1 &
                                              htw_resv1_tag3_as_match == 1'b1 & htw_resv1_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term7[1] = ((((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b01) |
                                               (|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b00)) &
                                                          htw_tag3_q[`tagpos_type_tlbwe] == 1'b1 & htw_resv1_tag3_gs_match == 1'b1 & htw_resv1_tag3_as_match == 1'b1 &
                                                          htw_resv1_tag3_lpid_match == 1'b1 & htw_resv1_tag3_pid_match == 1'b1 & htw_resv1_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term8[1] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_ptereload] == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b10 &
                                              htw_resv1_tag3_gs_match == 1'b1 & htw_resv1_tag3_as_match == 1'b1 & htw_resv1_tag3_lpid_match == 1'b1 &
                                              htw_resv1_tag3_pid_match == 1'b1 & htw_resv1_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term9[1] = ((((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b10) |
                                               (|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b11)) &
                                                           htw_tag3_q[`tagpos_type_tlbwe] == 1'b1 & htw_resv1_tag3_gs_match == 1'b1 & htw_resv1_tag3_as_match == 1'b1 &
                                                           htw_resv1_tag3_lpid_match == 1'b1 & htw_resv1_tag3_pid_match == 1'b1 & htw_resv1_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term11[1] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 1] == 2'b11)) ? 1'b1 :
                                           1'b0;
      assign htw_tag4_clr_resv_d[1] = htw_tag3_clr_resv_term2[1] | htw_tag3_clr_resv_term4[1] | htw_tag3_clr_resv_term5[1] | htw_tag3_clr_resv_term6[1] |
                                        htw_tag3_clr_resv_term7[1] | htw_tag3_clr_resv_term8[1] | htw_tag3_clr_resv_term9[1] | htw_tag3_clr_resv_term11[1];


      assign htw_tag3_clr_resv_term2[2] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b0011 &
                                                htw_resv2_tag3_lpid_match == 1'b1 & htw_resv2_tag3_pid_match == 1'b1 & htw_resv2_tag3_gs_match == 1'b1 &
                                                htw_resv2_tag3_as_match == 1'b1 & htw_resv2_tag3_epn_glob_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term4[2] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b1000 &
                                                htw_resv2_tag3_lpid_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term5[2] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b1001 &
                                                htw_resv2_tag3_lpid_match == 1'b1 & htw_resv2_tag3_pid_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term6[2] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b1011 &
                                                htw_resv2_tag3_lpid_match == 1'b1 & htw_resv2_tag3_pid_match == 1'b1 & htw_resv2_tag3_gs_match == 1'b1 &
                                                htw_resv2_tag3_as_match == 1'b1 & htw_resv2_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term7[2] = ((((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b01) |
                                               (|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b00)) &
                                                          htw_tag3_q[`tagpos_type_tlbwe] == 1'b1 & htw_resv2_tag3_gs_match == 1'b1 & htw_resv2_tag3_as_match == 1'b1 &
                                                          htw_resv2_tag3_lpid_match == 1'b1 & htw_resv2_tag3_pid_match == 1'b1 & htw_resv2_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term8[2] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_ptereload] == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b10 &
                                                htw_resv2_tag3_gs_match == 1'b1 & htw_resv2_tag3_as_match == 1'b1 & htw_resv2_tag3_lpid_match == 1'b1 &
                                                htw_resv2_tag3_pid_match == 1'b1 & htw_resv2_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term9[2] = ((((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b10) |
                                               (|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b11)) &
                                                          htw_tag3_q[`tagpos_type_tlbwe] == 1'b1 & htw_resv2_tag3_gs_match == 1'b1 & htw_resv2_tag3_as_match == 1'b1 &
                                                          htw_resv2_tag3_lpid_match == 1'b1 & htw_resv2_tag3_pid_match == 1'b1 & htw_resv2_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term11[2] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 1] == 2'b11)) ? 1'b1 :
                                           1'b0;
      assign htw_tag4_clr_resv_d[2] = htw_tag3_clr_resv_term2[2] | htw_tag3_clr_resv_term4[2] | htw_tag3_clr_resv_term5[2] | htw_tag3_clr_resv_term6[2] |
                                        htw_tag3_clr_resv_term7[2] | htw_tag3_clr_resv_term8[2] | htw_tag3_clr_resv_term9[2] | htw_tag3_clr_resv_term11[2];


      assign htw_tag3_clr_resv_term2[3] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b0011 &
                                                htw_resv3_tag3_lpid_match == 1'b1 & htw_resv3_tag3_pid_match == 1'b1 & htw_resv3_tag3_gs_match == 1'b1 &
                                                htw_resv3_tag3_as_match == 1'b1 & htw_resv3_tag3_epn_glob_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term4[3] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b1000 &
                                                htw_resv3_tag3_lpid_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term5[3] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b1001 &
                                                htw_resv3_tag3_lpid_match == 1'b1 & htw_resv3_tag3_pid_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term6[3] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 3] == 4'b1011 &
                                                 htw_resv3_tag3_lpid_match == 1'b1 & htw_resv3_tag3_pid_match == 1'b1 & htw_resv3_tag3_gs_match == 1'b1 &
                                                 htw_resv3_tag3_as_match == 1'b1 & htw_resv3_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term7[3] = ((((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b01) |
                                               (|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b00)) &
                                                          htw_tag3_q[`tagpos_type_tlbwe] == 1'b1 & htw_resv3_tag3_gs_match == 1'b1 & htw_resv3_tag3_as_match == 1'b1 &
                                                          htw_resv3_tag3_lpid_match == 1'b1 & htw_resv3_tag3_pid_match == 1'b1 & htw_resv3_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term8[3] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_ptereload] == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b10 &
                                                htw_resv3_tag3_gs_match == 1'b1 & htw_resv3_tag3_as_match == 1'b1 & htw_resv3_tag3_lpid_match == 1'b1 &
                                                htw_resv3_tag3_pid_match == 1'b1 & htw_resv3_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term9[3] = ((((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b10) |
                                               (|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush))) == 1'b1 & htw_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b11)) &
                                                          htw_tag3_q[`tagpos_type_tlbwe] == 1'b1 & htw_resv3_tag3_gs_match == 1'b1 & htw_resv3_tag3_as_match == 1'b1 &
                                                          htw_resv3_tag3_lpid_match == 1'b1 & htw_resv3_tag3_pid_match == 1'b1 & htw_resv3_tag3_epn_loc_match == 1'b1)) ? 1'b1 :
                                          1'b0;
      assign htw_tag3_clr_resv_term11[3] = ((|(htw_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & htw_tag3_q[`tagpos_type_snoop] == 1'b1 & htw_tag3_q[`tagpos_is:`tagpos_is + 1] == 2'b11)) ? 1'b1 :
                                           1'b0;

      assign htw_tag4_clr_resv_d[3] = htw_tag3_clr_resv_term2[3] | htw_tag3_clr_resv_term4[3] | htw_tag3_clr_resv_term5[3] | htw_tag3_clr_resv_term6[3] | htw_tag3_clr_resv_term7[3] | htw_tag3_clr_resv_term8[3] | htw_tag3_clr_resv_term9[3] | htw_tag3_clr_resv_term11[3];


      assign htw_tag5_clr_resv_d = (|(tlb_htw_req_tag[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag4_flush))) == 1'b1) ? htw_tag4_clr_resv_q :
                                   4'b0000;

      assign htw_resv_valid_vec = {tlb_htw_req0_tag_q[`tagpos_wq], tlb_htw_req1_tag_q[`tagpos_wq], tlb_htw_req2_tag_q[`tagpos_wq], tlb_htw_req3_tag_q[`tagpos_wq]};

      assign htw_resv0_tag3_lpid_match = ((htw_tag3_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] == tlb_htw_req0_tag_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1])) ? 1'b1 :
                                         1'b0;
      assign htw_resv0_tag3_pid_match = ((htw_tag3_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1] == tlb_htw_req0_tag_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1])) ? 1'b1 :
                                        1'b0;
      assign htw_resv0_tag3_as_match = ((htw_tag3_q[`tagpos_as] == tlb_htw_req0_tag_q[`tagpos_as])) ? 1'b1 :
                                       1'b0;
      assign htw_resv0_tag3_gs_match = ((htw_tag3_q[`tagpos_gs] == tlb_htw_req0_tag_q[`tagpos_gs])) ? 1'b1 :
                                       1'b0;

      // local match includes upper epn bits
      assign htw_resv0_tag3_epn_loc_match = ((htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] == tlb_htw_req0_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 5] == tlb_htw_req0_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 5] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 9] == tlb_htw_req0_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 9] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 13] == tlb_htw_req0_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 13] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 19] == tlb_htw_req0_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 19] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 :
                                            1'b0;
      // global match ignores certain upper epn bits that are not tranferred over bus
      // fix me!!  use various upper nibbles dependent on pgsize and mmucr1.tlbi_msb
      assign htw_resv0_tag3_epn_glob_match = ((htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 1] == tlb_htw_req0_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 1] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 5] == tlb_htw_req0_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 5] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 9] == tlb_htw_req0_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 9] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 13] == tlb_htw_req0_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 13] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 19] == tlb_htw_req0_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 19] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 :
                                             1'b0;
      assign htw_resv1_tag3_lpid_match = ((htw_tag3_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] == tlb_htw_req1_tag_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1])) ? 1'b1 :
                                         1'b0;
      assign htw_resv1_tag3_pid_match = ((htw_tag3_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1] == tlb_htw_req1_tag_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1])) ? 1'b1 :
                                        1'b0;
      assign htw_resv1_tag3_as_match = ((htw_tag3_q[`tagpos_as] == tlb_htw_req1_tag_q[`tagpos_as])) ? 1'b1 :
                                       1'b0;
      assign htw_resv1_tag3_gs_match = ((htw_tag3_q[`tagpos_gs] == tlb_htw_req1_tag_q[`tagpos_gs])) ? 1'b1 :
                                       1'b0;

      // local match includes upper epn bits
      assign htw_resv1_tag3_epn_loc_match = ((htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] == tlb_htw_req1_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 5] == tlb_htw_req1_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 5] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 9] == tlb_htw_req1_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 9] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 13] == tlb_htw_req1_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 13] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 19] == tlb_htw_req1_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 19] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 :
                                            1'b0;
      // global match ignores certain upper epn bits that are not tranferred over bus
      // fix me!!  use various upper nibbles dependent on pgsize and mmucr1.tlbi_msb
      assign htw_resv1_tag3_epn_glob_match = ((htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 1] == tlb_htw_req1_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 1] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 5] == tlb_htw_req1_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 5] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 9] == tlb_htw_req1_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 9] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 13] == tlb_htw_req1_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 13] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 19] == tlb_htw_req1_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 19] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 :
                                             1'b0;
      assign htw_resv2_tag3_lpid_match = ((htw_tag3_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] == tlb_htw_req2_tag_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1])) ? 1'b1 :
                                         1'b0;
      assign htw_resv2_tag3_pid_match = ((htw_tag3_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1] == tlb_htw_req2_tag_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1])) ? 1'b1 :
                                        1'b0;
      assign htw_resv2_tag3_as_match = ((htw_tag3_q[`tagpos_as] == tlb_htw_req2_tag_q[`tagpos_as])) ? 1'b1 :
                                       1'b0;
      assign htw_resv2_tag3_gs_match = ((htw_tag3_q[`tagpos_gs] == tlb_htw_req2_tag_q[`tagpos_gs])) ? 1'b1 :
                                       1'b0;

      // local match includes upper epn bits
      assign htw_resv2_tag3_epn_loc_match = ((htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] == tlb_htw_req2_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 5] == tlb_htw_req2_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 5] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 9] == tlb_htw_req2_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 9] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 13] == tlb_htw_req2_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 13] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 19] == tlb_htw_req2_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 19] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 :
                                            1'b0;
      // global match ignores certain upper epn bits that are not tranferred over bus
      // fix me!!  use various upper nibbles dependent on pgsize and mmucr1.tlbi_msb
      assign htw_resv2_tag3_epn_glob_match = ((htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 1] == tlb_htw_req2_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 1] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 5] == tlb_htw_req2_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 5] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 9] == tlb_htw_req2_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 9] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 13] == tlb_htw_req2_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 13] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 19] == tlb_htw_req2_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 19] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 :
                                             1'b0;
      assign htw_resv3_tag3_lpid_match = ((htw_tag3_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] == tlb_htw_req3_tag_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1])) ? 1'b1 :
                                         1'b0;
      assign htw_resv3_tag3_pid_match = ((htw_tag3_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1] == tlb_htw_req3_tag_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1])) ? 1'b1 :
                                        1'b0;
      assign htw_resv3_tag3_as_match = ((htw_tag3_q[`tagpos_as] == tlb_htw_req3_tag_q[`tagpos_as])) ? 1'b1 :
                                       1'b0;
      assign htw_resv3_tag3_gs_match = ((htw_tag3_q[`tagpos_gs] == tlb_htw_req3_tag_q[`tagpos_gs])) ? 1'b1 :
                                       1'b0;

      // local match includes upper epn bits
      assign htw_resv3_tag3_epn_loc_match = ((htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] == tlb_htw_req3_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 5] == tlb_htw_req3_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 5] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 9] == tlb_htw_req3_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 9] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 13] == tlb_htw_req3_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 13] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (htw_tag3_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 19] == tlb_htw_req3_tag_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 19] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 :
                                            1'b0;
      // global match ignores certain upper epn bits that are not tranferred over bus
      // fix me!!  use various upper nibbles dependent on pgsize and mmucr1.tlbi_msb
      assign htw_resv3_tag3_epn_glob_match = ((htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 1] == tlb_htw_req3_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 1] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 5] == tlb_htw_req3_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 5] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 9] == tlb_htw_req3_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 9] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 13] == tlb_htw_req3_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 13] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (htw_tag3_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 19] == tlb_htw_req3_tag_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 19] & htw_tag3_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 :
                                             1'b0;
      assign pte0_score_act = (|(pte0_seq_q) | |(htw_seq_q) | mmucr2_act_override) & xu_mm_ccr2_notlb_b;
      assign pte0_score_ptr_d = (pte0_seq_score_load == 1'b1) ? htw_lsuptr_q :
                                pte0_score_ptr_q;
      assign pte0_score_cl_offset_d = (pte0_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b00) ? pte_ra_0[58:60] :
                                      (pte0_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b01) ? pte_ra_1[58:60] :
                                      (pte0_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b10) ? pte_ra_2[58:60] :
                                      (pte0_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b11) ? pte_ra_3[58:60] :
                                      pte0_score_cl_offset_q;
      assign pte0_score_ibit_d = (pte0_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b00) ? tlb_htw_req0_way_q[`waypos_wimge + 1] :
                                 (pte0_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b01) ? tlb_htw_req1_way_q[`waypos_wimge + 1] :
                                 (pte0_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b10) ? tlb_htw_req2_way_q[`waypos_wimge + 1] :
                                 (pte0_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b11) ? tlb_htw_req3_way_q[`waypos_wimge + 1] :
                                 pte0_score_ibit_q;
      assign pte0_score_pending_d = (pte0_seq_score_load == 1'b1) ? 1'b1 :
                                    (pte0_seq_score_done == 1'b1) ? 1'b0 :
                                    pte0_score_pending_q;

      // 4 quadword data beats being returned; entire CL repeated if any beat has ecc error
      //   beats need to be set regardless of ecc present..ecc and any qw happen simultaneously
      assign pte0_score_qwbeat_d[0] = (pte0_seq_score_load == 1'b1 | pte0_seq_data_retry == 1'b1) ? 1'b0 :
                                      ((pte0_score_pending_q == 1'b1 & reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_core_tag_tp2_q == Core_Tag0_Value & reld_qw_tp2_q == 2'b00)) ? 1'b1 :
                                      pte0_score_qwbeat_q[0];
      assign pte0_score_qwbeat_d[1] = (pte0_seq_score_load == 1'b1 | pte0_seq_data_retry == 1'b1) ? 1'b0 :
                                      ((pte0_score_pending_q == 1'b1 & reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_core_tag_tp2_q == Core_Tag0_Value & reld_qw_tp2_q == 2'b01)) ? 1'b1 :
                                      pte0_score_qwbeat_q[1];
      assign pte0_score_qwbeat_d[2] = (pte0_seq_score_load == 1'b1 | pte0_seq_data_retry == 1'b1) ? 1'b0 :
                                      ((pte0_score_pending_q == 1'b1 & reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_core_tag_tp2_q == Core_Tag0_Value & reld_qw_tp2_q == 2'b10)) ? 1'b1 :
                                      pte0_score_qwbeat_q[2];
      assign pte0_score_qwbeat_d[3] = (pte0_seq_score_load == 1'b1 | pte0_seq_data_retry == 1'b1) ? 1'b0 :
                                      ((pte0_score_pending_q == 1'b1 & reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_core_tag_tp2_q == Core_Tag0_Value & reld_qw_tp2_q == 2'b11)) ? 1'b1 :
                                      pte0_score_qwbeat_q[3];
      // ecc error detection: bit0=ECC, bit1=UE, bit2=retry
      assign pte0_score_error_d[0] = (pte0_seq_score_load == 1'b1) ? 1'b0 :
                                     ((pte0_score_pending_q == 1'b1 & reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_core_tag_tp2_q == Core_Tag0_Value & reld_ecc_err_tp2_q == 1'b1)) ? 1'b1 :
                                     pte0_score_error_q[0];
      assign pte0_score_error_d[1] = (pte0_seq_score_load == 1'b1) ? 1'b0 :
                                     ((pte0_score_pending_q == 1'b1 & reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_core_tag_tp2_q == Core_Tag0_Value & reld_ecc_err_ue_tp2_q == 1'b1)) ? 1'b1 :
                                     pte0_score_error_q[1];
      assign pte0_score_error_d[2] = (pte0_seq_score_load == 1'b1) ? 1'b0 :
                                     (pte0_seq_data_retry == 1'b1) ? 1'b1 :
                                     pte0_score_error_q[2];
      assign pte0_score_dataval_d = (pte0_seq_score_load == 1'b1 | pte0_seq_data_retry == 1'b1) ? 1'b0 :
                                    ((pte0_score_pending_q == 1'b1 & reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_crit_qw_tp2_q == 1'b1 & reld_qw_tp2_q == pte0_score_cl_offset_q[58:59] & reld_core_tag_tp2_q == Core_Tag0_Value)) ? 1'b1 :
                                    pte0_score_dataval_q;


      assign pte1_score_act = (|(pte1_seq_q) | |(htw_seq_q) | mmucr2_act_override) & xu_mm_ccr2_notlb_b;
      assign pte1_score_ptr_d = (pte1_seq_score_load == 1'b1) ? htw_lsuptr_q :
                                pte1_score_ptr_q;
      assign pte1_score_cl_offset_d = (pte1_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b00) ? pte_ra_0[58:60] :
                                      (pte1_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b01) ? pte_ra_1[58:60] :
                                      (pte1_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b10) ? pte_ra_2[58:60] :
                                      (pte1_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b11) ? pte_ra_3[58:60] :
                                      pte1_score_cl_offset_q;
      assign pte1_score_ibit_d = (pte1_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b00) ? tlb_htw_req0_way_q[`waypos_wimge + 1] :
                                 (pte1_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b01) ? tlb_htw_req1_way_q[`waypos_wimge + 1] :
                                 (pte1_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b10) ? tlb_htw_req2_way_q[`waypos_wimge + 1] :
                                 (pte1_seq_score_load == 1'b1 & htw_lsuptr_q == 2'b11) ? tlb_htw_req3_way_q[`waypos_wimge + 1] :
                                 pte1_score_ibit_q;
      assign pte1_score_pending_d = (pte1_seq_score_load == 1'b1) ? 1'b1 :
                                    (pte1_seq_score_done == 1'b1) ? 1'b0 :
                                    pte1_score_pending_q;

      // 4 quadword data beats being returned; entire CL repeated if any beat has ecc error
      //   beats need to be set regardless of ecc present..ecc and any qw happen simultaneously
      assign pte1_score_qwbeat_d[0] = (pte1_seq_score_load == 1'b1 | pte1_seq_data_retry == 1'b1) ? 1'b0 :
                                      ((pte1_score_pending_q == 1'b1 & reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_core_tag_tp2_q == Core_Tag1_Value & reld_qw_tp2_q == 2'b00)) ? 1'b1 :
                                      pte1_score_qwbeat_q[0];
      assign pte1_score_qwbeat_d[1] = (pte1_seq_score_load == 1'b1 | pte1_seq_data_retry == 1'b1) ? 1'b0 :
                                      ((pte1_score_pending_q == 1'b1 & reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_core_tag_tp2_q == Core_Tag1_Value & reld_qw_tp2_q == 2'b01)) ? 1'b1 :
                                      pte1_score_qwbeat_q[1];
      assign pte1_score_qwbeat_d[2] = (pte1_seq_score_load == 1'b1 | pte1_seq_data_retry == 1'b1) ? 1'b0 :
                                      ((pte1_score_pending_q == 1'b1 & reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_core_tag_tp2_q == Core_Tag1_Value & reld_qw_tp2_q == 2'b10)) ? 1'b1 :
                                      pte1_score_qwbeat_q[2];
      assign pte1_score_qwbeat_d[3] = (pte1_seq_score_load == 1'b1 | pte1_seq_data_retry == 1'b1) ? 1'b0 :
                                      ((pte1_score_pending_q == 1'b1 & reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_core_tag_tp2_q == Core_Tag1_Value & reld_qw_tp2_q == 2'b11)) ? 1'b1 :
                                      pte1_score_qwbeat_q[3];
      // ecc error detection: bit0=ECC, bit1=UE, bit2=retry
      assign pte1_score_error_d[0] = (pte1_seq_score_load == 1'b1) ? 1'b0 :
                                     ((pte1_score_pending_q == 1'b1 & reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_core_tag_tp2_q == Core_Tag1_Value & reld_ecc_err_tp2_q == 1'b1)) ? 1'b1 :
                                     pte1_score_error_q[0];
      assign pte1_score_error_d[1] = (pte1_seq_score_load == 1'b1) ? 1'b0 :
                                     ((pte1_score_pending_q == 1'b1 & reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_core_tag_tp2_q == Core_Tag1_Value & reld_ecc_err_ue_tp2_q == 1'b1)) ? 1'b1 :
                                     pte1_score_error_q[1];
      assign pte1_score_error_d[2] = (pte1_seq_score_load == 1'b1) ? 1'b0 :
                                     (pte1_seq_data_retry == 1'b1) ? 1'b1 :
                                     pte1_score_error_q[2];
      assign pte1_score_dataval_d = (pte1_seq_score_load == 1'b1 | pte1_seq_data_retry == 1'b1) ? 1'b0 :
                                    ((pte1_score_pending_q == 1'b1 & reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_crit_qw_tp2_q == 1'b1 & reld_qw_tp2_q == pte1_score_cl_offset_q[58:59] & reld_core_tag_tp2_q == Core_Tag1_Value)) ? 1'b1 :
                                    pte1_score_dataval_q;


      // pointers:
      //  htw_inptr:      tlb to htw incoming request queue pointer, 4 total
      //  htw_lsuptr:     htw to lru outgoing request queue pointer, 4 total
      //  pte_load_ptr:   pte machine pointer next to load, 2 total
      //  ptereload_ptr:  pte to tlb data reload select, 2 total
      assign htw_inptr_d = (htw_inptr_q == 2'b00 & tlb_htw_req0_valid_q == 1'b0 & tlb_htw_req1_valid_q == 1'b0 & tlb_htw_req_valid == 1'b1) ? 2'b01 :
                           (htw_inptr_q == 2'b00 & tlb_htw_req0_valid_q == 1'b0 & tlb_htw_req1_valid_q == 1'b1 & tlb_htw_req2_valid_q == 1'b0 & tlb_htw_req_valid == 1'b1) ? 2'b10 :
                           (htw_inptr_q == 2'b00 & tlb_htw_req0_valid_q == 1'b0 & tlb_htw_req1_valid_q == 1'b1 & tlb_htw_req2_valid_q == 1'b1 & tlb_htw_req3_valid_q == 1'b0 & tlb_htw_req_valid == 1'b1) ? 2'b11 :
                           (htw_inptr_q == 2'b01 & tlb_htw_req1_valid_q == 1'b0 & tlb_htw_req2_valid_q == 1'b0 & tlb_htw_req_valid == 1'b1) ? 2'b10 :
                           (htw_inptr_q == 2'b01 & tlb_htw_req1_valid_q == 1'b0 & tlb_htw_req2_valid_q == 1'b1 & tlb_htw_req3_valid_q == 1'b0 & tlb_htw_req_valid == 1'b1) ? 2'b11 :
                           (htw_inptr_q == 2'b01 & tlb_htw_req1_valid_q == 1'b0 & tlb_htw_req2_valid_q == 1'b1 & tlb_htw_req3_valid_q == 1'b1 & tlb_htw_req0_valid_q == 1'b0 & tlb_htw_req_valid == 1'b1) ? 2'b00 :
                           (htw_inptr_q == 2'b10 & tlb_htw_req2_valid_q == 1'b0 & tlb_htw_req3_valid_q == 1'b0 & tlb_htw_req_valid == 1'b1) ? 2'b11 :
                           (htw_inptr_q == 2'b10 & tlb_htw_req2_valid_q == 1'b0 & tlb_htw_req3_valid_q == 1'b1 & tlb_htw_req0_valid_q == 1'b0 & tlb_htw_req_valid == 1'b1) ? 2'b00 :
                           (htw_inptr_q == 2'b10 & tlb_htw_req2_valid_q == 1'b0 & tlb_htw_req3_valid_q == 1'b1 & tlb_htw_req0_valid_q == 1'b1 & tlb_htw_req1_valid_q == 1'b0 & tlb_htw_req_valid == 1'b1) ? 2'b01 :
                           (htw_inptr_q == 2'b11 & tlb_htw_req3_valid_q == 1'b0 & tlb_htw_req0_valid_q == 1'b0 & tlb_htw_req_valid == 1'b1) ? 2'b00 :
                           (htw_inptr_q == 2'b11 & tlb_htw_req3_valid_q == 1'b0 & tlb_htw_req0_valid_q == 1'b1 & tlb_htw_req1_valid_q == 1'b0 & tlb_htw_req_valid == 1'b1) ? 2'b01 :
                           (htw_inptr_q == 2'b11 & tlb_htw_req3_valid_q == 1'b0 & tlb_htw_req0_valid_q == 1'b1 & tlb_htw_req1_valid_q == 1'b1 & tlb_htw_req2_valid_q == 1'b0 & tlb_htw_req_valid == 1'b1) ? 2'b10 :
                           (ptereload_ptr_q == 1'b0 & ptereload_req_taken == 1'b1) ? pte0_score_ptr_q :
                           (ptereload_ptr_q == 1'b1 & ptereload_req_taken == 1'b1) ? pte1_score_ptr_q :
                           htw_inptr_q;

      assign htw_lsuptr_d = (htw_lsuptr_q == 2'b00 & tlb_htw_req_valid_vec[0] == 1'b0 & tlb_htw_req_valid_vec[1] == 1'b1) ? 2'b01 :
                            (htw_lsuptr_q == 2'b00 & tlb_htw_req_valid_vec[0] == 1'b0 & tlb_htw_req_valid_vec[1] == 1'b0 & tlb_htw_req_valid_vec[2] == 1'b1) ? 2'b10 :
                            (htw_lsuptr_q == 2'b00 & tlb_htw_req_valid_vec[0] == 1'b0 & tlb_htw_req_valid_vec[1] == 1'b0 & tlb_htw_req_valid_vec[2] == 1'b0 & tlb_htw_req_valid_vec[3] == 1'b1) ? 2'b11 :
                            (htw_lsuptr_q == 2'b01 & tlb_htw_req_valid_vec[1] == 1'b0 & tlb_htw_req_valid_vec[2] == 1'b1) ? 2'b10 :
                            (htw_lsuptr_q == 2'b01 & tlb_htw_req_valid_vec[1] == 1'b0 & tlb_htw_req_valid_vec[2] == 1'b0 & tlb_htw_req_valid_vec[3] == 1'b1) ? 2'b11 :
                            (htw_lsuptr_q == 2'b01 & tlb_htw_req_valid_vec[1] == 1'b0 & tlb_htw_req_valid_vec[2] == 1'b0 & tlb_htw_req_valid_vec[3] == 1'b0 & tlb_htw_req_valid_vec[0] == 1'b1) ? 2'b00 :
                            (htw_lsuptr_q == 2'b10 & tlb_htw_req_valid_vec[2] == 1'b0 & tlb_htw_req_valid_vec[3] == 1'b1) ? 2'b11 :
                            (htw_lsuptr_q == 2'b10 & tlb_htw_req_valid_vec[2] == 1'b0 & tlb_htw_req_valid_vec[3] == 1'b0 & tlb_htw_req_valid_vec[0] == 1'b1) ? 2'b00 :
                            (htw_lsuptr_q == 2'b10 & tlb_htw_req_valid_vec[2] == 1'b0 & tlb_htw_req_valid_vec[3] == 1'b0 & tlb_htw_req_valid_vec[0] == 1'b0 & tlb_htw_req_valid_vec[1] == 1'b1) ? 2'b01 :
                            (htw_lsuptr_q == 2'b11 & tlb_htw_req_valid_vec[3] == 1'b0 & tlb_htw_req_valid_vec[0] == 1'b1) ? 2'b00 :
                            (htw_lsuptr_q == 2'b11 & tlb_htw_req_valid_vec[3] == 1'b0 & tlb_htw_req_valid_vec[0] == 1'b0 & tlb_htw_req_valid_vec[1] == 1'b1) ? 2'b01 :
                            (htw_lsuptr_q == 2'b11 & tlb_htw_req_valid_vec[3] == 1'b0 & tlb_htw_req_valid_vec[0] == 1'b0 & tlb_htw_req_valid_vec[1] == 1'b0 & tlb_htw_req_valid_vec[2] == 1'b1) ? 2'b10 :
                            htw_lsuptr_q;

      assign tlb_htw_req_valid_notpend_vec = {(tlb_htw_req0_valid_q & (~tlb_htw_req0_pending_q)), (tlb_htw_req1_valid_q & (~tlb_htw_req1_pending_q)), (tlb_htw_req2_valid_q & (~tlb_htw_req2_pending_q)), (tlb_htw_req3_valid_q & (~tlb_htw_req3_pending_q))};

      assign htw_lsuptr_alt_d = (htw_lsuptr_q == 2'b00 & tlb_htw_req_valid_notpend_vec[0] == 1'b1 & htw_lsu_req_taken == 1'b1) ? 2'b01 :
                                (htw_lsuptr_q == 2'b01 & tlb_htw_req_valid_notpend_vec[1] == 1'b1 & htw_lsu_req_taken == 1'b1) ? 2'b10 :
                                (htw_lsuptr_q == 2'b10 & tlb_htw_req_valid_notpend_vec[2] == 1'b1 & htw_lsu_req_taken == 1'b1) ? 2'b11 :
                                (htw_lsuptr_q == 2'b11 & tlb_htw_req_valid_notpend_vec[3] == 1'b1 & htw_lsu_req_taken == 1'b1) ? 2'b00 :
                                (htw_lsuptr_q == 2'b00 & tlb_htw_req_valid_notpend_vec[0] == 1'b0 & tlb_htw_req_valid_notpend_vec[1] == 1'b1) ? 2'b01 :
                                (htw_lsuptr_q == 2'b00 & tlb_htw_req_valid_notpend_vec[0] == 1'b0 & tlb_htw_req_valid_notpend_vec[1] == 1'b0 & tlb_htw_req_valid_notpend_vec[2] == 1'b1) ? 2'b10 :
                                (htw_lsuptr_q == 2'b00 & tlb_htw_req_valid_notpend_vec[0] == 1'b0 & tlb_htw_req_valid_notpend_vec[1] == 1'b0 & tlb_htw_req_valid_notpend_vec[2] == 1'b0 & tlb_htw_req_valid_notpend_vec[3] == 1'b1) ? 2'b11 :
                                (htw_lsuptr_q == 2'b01 & tlb_htw_req_valid_notpend_vec[1] == 1'b0 & tlb_htw_req_valid_notpend_vec[2] == 1'b1) ? 2'b10 :
                                (htw_lsuptr_q == 2'b01 & tlb_htw_req_valid_notpend_vec[1] == 1'b0 & tlb_htw_req_valid_notpend_vec[2] == 1'b0 & tlb_htw_req_valid_notpend_vec[3] == 1'b1) ? 2'b11 :
                                (htw_lsuptr_q == 2'b01 & tlb_htw_req_valid_notpend_vec[1] == 1'b0 & tlb_htw_req_valid_notpend_vec[2] == 1'b0 & tlb_htw_req_valid_notpend_vec[3] == 1'b0 & tlb_htw_req_valid_notpend_vec[0] == 1'b1) ? 2'b00 :
                                (htw_lsuptr_q == 2'b10 & tlb_htw_req_valid_notpend_vec[2] == 1'b0 & tlb_htw_req_valid_notpend_vec[3] == 1'b1) ? 2'b11 :
                                (htw_lsuptr_q == 2'b10 & tlb_htw_req_valid_notpend_vec[2] == 1'b0 & tlb_htw_req_valid_notpend_vec[3] == 1'b0 & tlb_htw_req_valid_notpend_vec[0] == 1'b1) ? 2'b00 :
                                (htw_lsuptr_q == 2'b10 & tlb_htw_req_valid_notpend_vec[2] == 1'b0 & tlb_htw_req_valid_notpend_vec[3] == 1'b0 & tlb_htw_req_valid_notpend_vec[0] == 1'b0 & tlb_htw_req_valid_notpend_vec[1] == 1'b1) ? 2'b01 :
                                (htw_lsuptr_q == 2'b11 & tlb_htw_req_valid_notpend_vec[3] == 1'b0 & tlb_htw_req_valid_notpend_vec[0] == 1'b1) ? 2'b00 :
                                (htw_lsuptr_q == 2'b11 & tlb_htw_req_valid_notpend_vec[3] == 1'b0 & tlb_htw_req_valid_notpend_vec[0] == 1'b0 & tlb_htw_req_valid_notpend_vec[1] == 1'b1) ? 2'b01 :
                                (htw_lsuptr_q == 2'b11 & tlb_htw_req_valid_notpend_vec[3] == 1'b0 & tlb_htw_req_valid_notpend_vec[0] == 1'b0 & tlb_htw_req_valid_notpend_vec[1] == 1'b0 & tlb_htw_req_valid_notpend_vec[2] == 1'b1) ? 2'b10 :
                                htw_lsuptr_q;

      assign pte_load_ptr_d = (ptereload_ptr_q == 1'b1 & pte1_score_pending_q == 1'b1 & pte0_score_pending_d == 1'b1 & ptereload_req_taken == 1'b1) ? 1'b1 :
                              (ptereload_ptr_q == 1'b0 & pte0_score_pending_q == 1'b1 & pte1_score_pending_d == 1'b1 & ptereload_req_taken == 1'b1) ? 1'b0 :
                              (pte_load_ptr_q == 1'b0 & pte0_seq_score_load == 1'b1 & pte1_score_pending_q == 1'b0) ? 1'b1 :
                              (pte_load_ptr_q == 1'b1 & pte1_seq_score_load == 1'b1 & pte0_score_pending_q == 1'b0) ? 1'b0 :
                              pte_load_ptr_q;

      assign ptereload_ptr_d = (ptereload_ptr_q == 1'b0 & ptereload_req_taken == 1'b1) ? 1'b1 :
                               (ptereload_ptr_q == 1'b0 & pte0_reload_req_valid == 1'b0 & pte1_reload_req_valid == 1'b1) ? 1'b1 :
                               (ptereload_ptr_q == 1'b1 & ptereload_req_taken == 1'b1) ? 1'b0 :
                               (ptereload_ptr_q == 1'b1 & pte0_reload_req_valid == 1'b1 & pte1_reload_req_valid == 1'b0) ? 1'b0 :
                               ptereload_ptr_q;

      // 0=tlbivax_op, 1=tlbi_complete, 2=mmu read with core_tag=01100, 3=mmu read with core_tag=01101
      assign htw_lsu_ttype_d = ((pte_load_ptr_q == 1'b1 & htw_seq_load_pteaddr == 1'b1)) ? 2'b11 :
                               (htw_seq_load_pteaddr == 1'b1) ? 2'b10 :
                               htw_lsu_ttype_q;
      assign htw_lsu_thdid_d = (htw_lsuptr_q == 2'b00 & tlb_htw_req0_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? tlb_htw_req0_tag_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1] :
                               (htw_lsuptr_q == 2'b01 & tlb_htw_req1_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? tlb_htw_req1_tag_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1] :
                               (htw_lsuptr_q == 2'b10 & tlb_htw_req2_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? tlb_htw_req2_tag_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1] :
                               (htw_lsuptr_q == 2'b11 & tlb_htw_req3_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? tlb_htw_req3_tag_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1] :
                               htw_lsu_thdid_q;
      assign htw_lsu_wimge_d = (htw_lsuptr_q == 2'b00 & tlb_htw_req0_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? tlb_htw_req0_way_q[`waypos_wimge:`waypos_wimge + 4] :
                               (htw_lsuptr_q == 2'b01 & tlb_htw_req1_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? tlb_htw_req1_way_q[`waypos_wimge:`waypos_wimge + 4] :
                               (htw_lsuptr_q == 2'b10 & tlb_htw_req2_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? tlb_htw_req2_way_q[`waypos_wimge:`waypos_wimge + 4] :
                               (htw_lsuptr_q == 2'b11 & tlb_htw_req3_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? tlb_htw_req3_way_q[`waypos_wimge:`waypos_wimge + 4] :
                               htw_lsu_wimge_q;
      assign htw_lsu_u_d = (htw_lsuptr_q == 2'b00 & tlb_htw_req0_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? tlb_htw_req0_way_q[`waypos_ubits:`waypos_ubits + 3] :
                           (htw_lsuptr_q == 2'b01 & tlb_htw_req1_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? tlb_htw_req1_way_q[`waypos_ubits:`waypos_ubits + 3] :
                           (htw_lsuptr_q == 2'b10 & tlb_htw_req2_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? tlb_htw_req2_way_q[`waypos_ubits:`waypos_ubits + 3] :
                           (htw_lsuptr_q == 2'b11 & tlb_htw_req3_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? tlb_htw_req3_way_q[`waypos_ubits:`waypos_ubits + 3] :
                           htw_lsu_u_q;
      assign htw_lsu_addr_d = (htw_lsuptr_q == 2'b00 & tlb_htw_req0_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? pte_ra_0 :
                              (htw_lsuptr_q == 2'b01 & tlb_htw_req1_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? pte_ra_1 :
                              (htw_lsuptr_q == 2'b10 & tlb_htw_req2_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? pte_ra_2 :
                              (htw_lsuptr_q == 2'b11 & tlb_htw_req3_valid_q == 1'b1 & htw_seq_load_pteaddr == 1'b1) ? pte_ra_3 :
                              htw_lsu_addr_q;
      assign htw_lsu_act = (|(htw_seq_q) | mmucr2_act_override) & xu_mm_ccr2_notlb_b;
      assign htw_lsu_thdid = htw_lsu_thdid_q;
      assign htw_dbg_lsu_thdid[0] = htw_lsu_thdid_q[2] | htw_lsu_thdid_q[3];
      assign htw_dbg_lsu_thdid[1] = htw_lsu_thdid_q[1] | htw_lsu_thdid_q[3];
      assign htw_lsu_ttype = htw_lsu_ttype_q;
      assign htw_lsu_wimge = htw_lsu_wimge_q;
      assign htw_lsu_u = htw_lsu_u_q;
      assign htw_lsu_addr = htw_lsu_addr_q;
      // L2 data reload stages
      //  t minus 2 phase
      assign reld_core_tag_tm1_d = an_ac_reld_core_tag;
      assign reld_qw_tm1_d = an_ac_reld_qw;
      assign reld_crit_qw_tm1_d = an_ac_reld_crit_qw;
      assign reld_ditc_tm1_d = an_ac_reld_ditc;
      assign reld_data_vld_tm1_d = an_ac_reld_data_vld;
      //  t minus 1 phase
      assign reld_core_tag_t_d = reld_core_tag_tm1_q;
      assign reld_qw_t_d = reld_qw_tm1_q;
      assign reld_crit_qw_t_d = reld_crit_qw_tm1_q;
      assign reld_ditc_t_d = reld_ditc_tm1_q;
      assign reld_data_vld_t_d = reld_data_vld_tm1_q;
      assign pte0_reld_for_me_tm1 = ((reld_data_vld_tm1_q == 1'b1 & reld_ditc_tm1_q == 1'b0 & reld_crit_qw_tm1_q == 1'b1 & reld_qw_tm1_q == pte0_score_cl_offset_q[58:59] & reld_core_tag_tm1_q == Core_Tag0_Value)) ? 1'b1 :
                                    1'b0;
      assign pte1_reld_for_me_tm1 = ((reld_data_vld_tm1_q == 1'b1 & reld_ditc_tm1_q == 1'b0 & reld_crit_qw_tm1_q == 1'b1 & reld_qw_tm1_q == pte1_score_cl_offset_q[58:59] & reld_core_tag_tm1_q == Core_Tag1_Value)) ? 1'b1 :
                                    1'b0;
      //  t phase
      assign reld_core_tag_tp1_d = reld_core_tag_t_q;
      assign reld_qw_tp1_d = reld_qw_t_q;
      assign reld_crit_qw_tp1_d = reld_crit_qw_t_q;
      assign reld_ditc_tp1_d = reld_ditc_t_q;
      assign reld_data_vld_tp1_d = reld_data_vld_t_q;
      assign reld_data_tp1_d = an_ac_reld_data;
      //  t plus 1 phase
      assign reld_core_tag_tp2_d = reld_core_tag_tp1_q;
      assign reld_qw_tp2_d = reld_qw_tp1_q;
      assign reld_crit_qw_tp2_d = reld_crit_qw_tp1_q;
      assign reld_ditc_tp2_d = reld_ditc_tp1_q;
      assign reld_data_vld_tp2_d = reld_data_vld_tp1_q;
      assign reld_data_tp2_d = reld_data_tp1_q;
      assign reld_ecc_err_tp2_d = an_ac_reld_ecc_err;
      assign reld_ecc_err_ue_tp2_d = an_ac_reld_ecc_err_ue;
      //  t plus 2 phase
      assign pte0_reld_for_me_tp2 = ((reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_crit_qw_tp2_q == 1'b1 & reld_qw_tp2_q == pte0_score_cl_offset_q[58:59] & reld_core_tag_tp2_q == Core_Tag0_Value)) ? 1'b1 :
                                    1'b0;
      assign pte0_reld_data_tp3_d = ((pte0_reld_for_me_tp2 == 1'b1 & pte0_score_cl_offset_q[60] == 1'b0)) ? reld_data_tp2_q[0:63] :
                                    ((pte0_reld_for_me_tp2 == 1'b1 & pte0_score_cl_offset_q[60] == 1'b1)) ? reld_data_tp2_q[64:127] :
                                    pte0_reld_data_tp3_q;
      assign pte1_reld_for_me_tp2 = ((reld_data_vld_tp2_q == 1'b1 & reld_ditc_tp2_q == 1'b0 & reld_crit_qw_tp2_q == 1'b1 & reld_qw_tp2_q == pte1_score_cl_offset_q[58:59] & reld_core_tag_tp2_q == Core_Tag1_Value)) ? 1'b1 :
                                    1'b0;
      assign pte1_reld_data_tp3_d = ((pte1_reld_for_me_tp2 == 1'b1 & pte1_score_cl_offset_q[60] == 1'b0)) ? reld_data_tp2_q[0:63] :
                                    ((pte1_reld_for_me_tp2 == 1'b1 & pte1_score_cl_offset_q[60] == 1'b1)) ? reld_data_tp2_q[64:127] :
                                    pte1_reld_data_tp3_q;
      assign reld_act = (|(pte0_seq_q) | |(pte1_seq_q) | mmucr2_act_override) & xu_mm_ccr2_notlb_b;
      assign pte0_reld_act = (|(pte0_seq_q) | mmucr2_act_override) & xu_mm_ccr2_notlb_b;
      assign pte1_reld_act = (|(pte1_seq_q) | mmucr2_act_override) & xu_mm_ccr2_notlb_b;
      // ptereload requests to tlb_ctl
      assign ptereload_req_valid = ((htw_tag4_clr_resv_q != 4'b0000 | htw_tag5_clr_resv_q != 4'b0000)) ? 1'b0 :
                                   (ptereload_ptr_q == 1'b1) ? pte1_reload_req_valid :
                                   pte0_reload_req_valid;
      assign ptereload_req_tag = (((ptereload_ptr_q == 1'b0 & pte0_score_ptr_q == 2'b01) | (ptereload_ptr_q == 1'b1 & pte1_score_ptr_q == 2'b01))) ? tlb_htw_req1_tag_q :
                                 (((ptereload_ptr_q == 1'b0 & pte0_score_ptr_q == 2'b10) | (ptereload_ptr_q == 1'b1 & pte1_score_ptr_q == 2'b10))) ? tlb_htw_req2_tag_q :
                                 (((ptereload_ptr_q == 1'b0 & pte0_score_ptr_q == 2'b11) | (ptereload_ptr_q == 1'b1 & pte1_score_ptr_q == 2'b11))) ? tlb_htw_req3_tag_q :
                                 tlb_htw_req0_tag_q;
      assign ptereload_req_pte = (ptereload_ptr_q == 1'b1) ? pte1_reld_data_tp3_q :
                                 pte0_reld_data_tp3_q;

      assign htw_tag4_clr_resv_terms = {4{1'b0}};
      assign htw_dbg_seq_idle = htw_seq_idle;
      assign htw_dbg_pte0_seq_idle = pte0_seq_idle;
      assign htw_dbg_pte1_seq_idle = pte1_seq_idle;
      assign htw_dbg_seq_q = htw_seq_q;
      assign htw_dbg_inptr_q = htw_inptr_q;
      assign htw_dbg_pte0_seq_q = pte0_seq_q;
      assign htw_dbg_pte1_seq_q = pte1_seq_q;
      assign htw_dbg_ptereload_ptr_q = ptereload_ptr_q;
      assign htw_dbg_lsuptr_q = htw_lsuptr_q;
      assign htw_dbg_req_valid_q = {tlb_htw_req0_valid_q, tlb_htw_req1_valid_q, tlb_htw_req2_valid_q, tlb_htw_req3_valid_q};
      assign htw_dbg_resv_valid_vec = htw_resv_valid_vec;
      assign htw_dbg_tag4_clr_resv_q = htw_tag4_clr_resv_q;
      assign htw_dbg_tag4_clr_resv_terms = htw_tag4_clr_resv_terms;
      assign htw_dbg_pte0_score_ptr_q = pte0_score_ptr_q;
      assign htw_dbg_pte0_score_cl_offset_q = pte0_score_cl_offset_q;
      assign htw_dbg_pte0_score_error_q = pte0_score_error_q;
      assign htw_dbg_pte0_score_qwbeat_q = pte0_score_qwbeat_q;
      assign htw_dbg_pte0_score_pending_q = pte0_score_pending_q;
      assign htw_dbg_pte0_score_ibit_q = pte0_score_ibit_q;
      assign htw_dbg_pte0_score_dataval_q = pte0_score_dataval_q;
      assign htw_dbg_pte0_reld_for_me_tm1 = pte0_reld_for_me_tm1;
      assign htw_dbg_pte1_score_ptr_q = pte1_score_ptr_q;
      assign htw_dbg_pte1_score_cl_offset_q = pte1_score_cl_offset_q;
      assign htw_dbg_pte1_score_error_q = pte1_score_error_q;
      assign htw_dbg_pte1_score_qwbeat_q = pte1_score_qwbeat_q;
      assign htw_dbg_pte1_score_pending_q = pte1_score_pending_q;
      assign htw_dbg_pte1_score_ibit_q = pte1_score_ibit_q;
      assign htw_dbg_pte1_score_dataval_q = pte1_score_dataval_q;
      assign htw_dbg_pte1_reld_for_me_tm1 = pte1_reld_for_me_tm1;

      // unused spare signal assignments
      assign unused_dc[0] = |(lcb_delay_lclkr_dc[1:4]);
      assign unused_dc[1] = |(lcb_mpw1_dc_b[1:4]);
      assign unused_dc[2] = pc_func_sl_force;
      assign unused_dc[3] = pc_func_sl_thold_0_b;
      assign unused_dc[4] = tc_scan_dis_dc_b;
      assign unused_dc[5] = tc_scan_diag_dc;
      assign unused_dc[6] = tc_lbist_en_dc;
      assign unused_dc[7] = |(tlb_htw_req_tag[104:105]);
      assign unused_dc[8] = htw_tag3_q[70];
      assign unused_dc[9] = htw_tag3_q[73];
      assign unused_dc[10] = |(htw_tag3_q[82:85]);
      assign unused_dc[11] = htw_tag3_q[87];
      assign unused_dc[12] = |(htw_tag3_q[98:103]);
      assign unused_dc[13] = |(htw_tag3_q[106:`TLB_TAG_WIDTH - 1]);
      assign unused_dc[14] = pte0_reld_enable_lo_tp2 | pte0_reld_enable_hi_tp2;
      assign unused_dc[15] = pte1_reld_enable_lo_tp2 | pte1_reld_enable_hi_tp2;
      assign unused_dc[16:19] = {tlb_htw_req0_pending_q, tlb_htw_req1_pending_q, tlb_htw_req2_pending_q, tlb_htw_req3_pending_q};
      assign unused_dc[20:21] = htw_lsuptr_alt_d;
      //---------------------------------------------------------------------
      // Latches
      //---------------------------------------------------------------------
      // tlb request valid latches

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_htw_req0_valid_latch(
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
         .scin(siv_0[tlb_htw_req0_valid_offset]),
         .scout(sov_0[tlb_htw_req0_valid_offset]),
         .din(tlb_htw_req0_valid_d),
         .dout(tlb_htw_req0_valid_q)
      );
      // tlb request pending latches.. this req is loaded into a pte machine

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_htw_req0_pending_latch(
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
         .scin(siv_0[tlb_htw_req0_pending_offset]),
         .scout(sov_0[tlb_htw_req0_pending_offset]),
         .din(tlb_htw_req0_pending_d),
         .dout(tlb_htw_req0_pending_q)
      );
      // tlb request tag latches

      tri_rlmreg_p #(.WIDTH(`TLB_TAG_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_htw_req0_tag_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_htw_req0_tag_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_htw_req0_tag_offset:tlb_htw_req0_tag_offset + `TLB_TAG_WIDTH - 1]),
         .scout(sov_0[tlb_htw_req0_tag_offset:tlb_htw_req0_tag_offset + `TLB_TAG_WIDTH - 1]),
         .din(tlb_htw_req0_tag_d),
         .dout(tlb_htw_req0_tag_q)
      );
      // tlb request tag latches

      tri_rlmreg_p #(.WIDTH((`TLB_WAY_WIDTH-1-`TLB_WORD_WIDTH+1)), .INIT(0), .NEEDS_SRESET(1)) tlb_htw_req0_way_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[24 + 0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_htw_req0_way_offset:tlb_htw_req0_way_offset + (`TLB_WAY_WIDTH-1-`TLB_WORD_WIDTH+1) - 1]),
         .scout(sov_0[tlb_htw_req0_way_offset:tlb_htw_req0_way_offset + (`TLB_WAY_WIDTH-1-`TLB_WORD_WIDTH+1) - 1]),
         .din(tlb_htw_req0_way_d),
         .dout(tlb_htw_req0_way_q)
      );
      // tlb request valid latches

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_htw_req1_valid_latch(
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
         .scin(siv_0[tlb_htw_req1_valid_offset]),
         .scout(sov_0[tlb_htw_req1_valid_offset]),
         .din(tlb_htw_req1_valid_d),
         .dout(tlb_htw_req1_valid_q)
      );
      // tlb request pending latches.. this req is loaded into a pte machine

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_htw_req1_pending_latch(
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
         .scin(siv_0[tlb_htw_req1_pending_offset]),
         .scout(sov_0[tlb_htw_req1_pending_offset]),
         .din(tlb_htw_req1_pending_d),
         .dout(tlb_htw_req1_pending_q)
      );
      // tlb request tag latches

      tri_rlmreg_p #(.WIDTH(`TLB_TAG_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_htw_req1_tag_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_htw_req1_tag_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_htw_req1_tag_offset:tlb_htw_req1_tag_offset + `TLB_TAG_WIDTH - 1]),
         .scout(sov_0[tlb_htw_req1_tag_offset:tlb_htw_req1_tag_offset + `TLB_TAG_WIDTH - 1]),
         .din(tlb_htw_req1_tag_d),
         .dout(tlb_htw_req1_tag_q)
      );
      // tlb request tag latches

      tri_rlmreg_p #(.WIDTH((`TLB_WAY_WIDTH-1-`TLB_WORD_WIDTH+1)), .INIT(0), .NEEDS_SRESET(1)) tlb_htw_req1_way_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[24 + 1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_htw_req1_way_offset:tlb_htw_req1_way_offset + (`TLB_WAY_WIDTH-1-`TLB_WORD_WIDTH+1) - 1]),
         .scout(sov_0[tlb_htw_req1_way_offset:tlb_htw_req1_way_offset + (`TLB_WAY_WIDTH-1-`TLB_WORD_WIDTH+1) - 1]),
         .din(tlb_htw_req1_way_d),
         .dout(tlb_htw_req1_way_q)
      );
      // tlb request valid latches

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_htw_req2_valid_latch(
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
         .scin(siv_0[tlb_htw_req2_valid_offset]),
         .scout(sov_0[tlb_htw_req2_valid_offset]),
         .din(tlb_htw_req2_valid_d),
         .dout(tlb_htw_req2_valid_q)
      );
      // tlb request pending latches.. this req is loaded into a pte machine

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_htw_req2_pending_latch(
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
         .scin(siv_0[tlb_htw_req2_pending_offset]),
         .scout(sov_0[tlb_htw_req2_pending_offset]),
         .din(tlb_htw_req2_pending_d),
         .dout(tlb_htw_req2_pending_q)
      );
      // tlb request tag latches

      tri_rlmreg_p #(.WIDTH(`TLB_TAG_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_htw_req2_tag_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_htw_req2_tag_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_htw_req2_tag_offset:tlb_htw_req2_tag_offset + `TLB_TAG_WIDTH - 1]),
         .scout(sov_0[tlb_htw_req2_tag_offset:tlb_htw_req2_tag_offset + `TLB_TAG_WIDTH - 1]),
         .din(tlb_htw_req2_tag_d),
         .dout(tlb_htw_req2_tag_q)
      );
      // tlb request tag latches

      tri_rlmreg_p #(.WIDTH((`TLB_WAY_WIDTH-1-`TLB_WORD_WIDTH+1)), .INIT(0), .NEEDS_SRESET(1)) tlb_htw_req2_way_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[24 + 2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_htw_req2_way_offset:tlb_htw_req2_way_offset + (`TLB_WAY_WIDTH-1-`TLB_WORD_WIDTH+1) - 1]),
         .scout(sov_0[tlb_htw_req2_way_offset:tlb_htw_req2_way_offset + (`TLB_WAY_WIDTH-1-`TLB_WORD_WIDTH+1) - 1]),
         .din(tlb_htw_req2_way_d),
         .dout(tlb_htw_req2_way_q)
      );
      // tlb request valid latches

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_htw_req3_valid_latch(
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
         .scin(siv_0[tlb_htw_req3_valid_offset]),
         .scout(sov_0[tlb_htw_req3_valid_offset]),
         .din(tlb_htw_req3_valid_d),
         .dout(tlb_htw_req3_valid_q)
      );
      // tlb request pending latches.. this req is loaded into a pte machine

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_htw_req3_pending_latch(
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
         .scin(siv_0[tlb_htw_req3_pending_offset]),
         .scout(sov_0[tlb_htw_req3_pending_offset]),
         .din(tlb_htw_req3_pending_d),
         .dout(tlb_htw_req3_pending_q)
      );
      // tlb request tag latches

      tri_rlmreg_p #(.WIDTH(`TLB_TAG_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_htw_req3_tag_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_htw_req3_tag_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_htw_req3_tag_offset:tlb_htw_req3_tag_offset + `TLB_TAG_WIDTH - 1]),
         .scout(sov_0[tlb_htw_req3_tag_offset:tlb_htw_req3_tag_offset + `TLB_TAG_WIDTH - 1]),
         .din(tlb_htw_req3_tag_d),
         .dout(tlb_htw_req3_tag_q)
      );
      // tlb request tag latches

      tri_rlmreg_p #(.WIDTH((`TLB_WAY_WIDTH-1-`TLB_WORD_WIDTH+1)), .INIT(0), .NEEDS_SRESET(1)) tlb_htw_req3_way_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[24 + 3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_htw_req3_way_offset:tlb_htw_req3_way_offset + (`TLB_WAY_WIDTH-1-`TLB_WORD_WIDTH+1) - 1]),
         .scout(sov_0[tlb_htw_req3_way_offset:tlb_htw_req3_way_offset + (`TLB_WAY_WIDTH-1-`TLB_WORD_WIDTH+1) - 1]),
         .din(tlb_htw_req3_way_d),
         .dout(tlb_htw_req3_way_q)
      );

      tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) spare_a_latch(
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
         .scin(siv_0[spare_a_offset:spare_a_offset + 16 - 1]),
         .scout(sov_0[spare_a_offset:spare_a_offset + 16 - 1]),
         .din(spare_a_q),
         .dout(spare_a_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) htw_seq_latch(
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
         .scin(siv_1[htw_seq_offset:htw_seq_offset + 2 - 1]),
         .scout(sov_1[htw_seq_offset:htw_seq_offset + 2 - 1]),
         .din(htw_seq_d[0:`HTW_SEQ_WIDTH - 1]),
         .dout(htw_seq_q[0:`HTW_SEQ_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) htw_inptr_latch(
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
         .scin(siv_1[htw_inptr_offset:htw_inptr_offset + 2 - 1]),
         .scout(sov_1[htw_inptr_offset:htw_inptr_offset + 2 - 1]),
         .din(htw_inptr_d),
         .dout(htw_inptr_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) htw_lsuptr_latch(
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
         .scin(siv_1[htw_lsuptr_offset:htw_lsuptr_offset + 2 - 1]),
         .scout(sov_1[htw_lsuptr_offset:htw_lsuptr_offset + 2 - 1]),
         .din(htw_lsuptr_d),
         .dout(htw_lsuptr_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) htw_lsu_ttype_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(htw_lsu_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[htw_lsu_ttype_offset:htw_lsu_ttype_offset + 2 - 1]),
         .scout(sov_1[htw_lsu_ttype_offset:htw_lsu_ttype_offset + 2 - 1]),
         .din(htw_lsu_ttype_d),
         .dout(htw_lsu_ttype_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) htw_lsu_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(htw_lsu_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[htw_lsu_thdid_offset:htw_lsu_thdid_offset + `THDID_WIDTH - 1]),
         .scout(sov_1[htw_lsu_thdid_offset:htw_lsu_thdid_offset + `THDID_WIDTH - 1]),
         .din(htw_lsu_thdid_d),
         .dout(htw_lsu_thdid_q)
      );

      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) htw_lsu_wimge_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(htw_lsu_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[htw_lsu_wimge_offset:htw_lsu_wimge_offset + 5 - 1]),
         .scout(sov_1[htw_lsu_wimge_offset:htw_lsu_wimge_offset + 5 - 1]),
         .din(htw_lsu_wimge_d),
         .dout(htw_lsu_wimge_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) htw_lsu_u_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(htw_lsu_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[htw_lsu_u_offset:htw_lsu_u_offset + 4 - 1]),
         .scout(sov_1[htw_lsu_u_offset:htw_lsu_u_offset + 4 - 1]),
         .din(htw_lsu_u_d),
         .dout(htw_lsu_u_q)
      );

      tri_rlmreg_p #(.WIDTH(`REAL_ADDR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) htw_lsu_addr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(htw_lsu_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[htw_lsu_addr_offset:htw_lsu_addr_offset + `REAL_ADDR_WIDTH - 1]),
         .scout(sov_1[htw_lsu_addr_offset:htw_lsu_addr_offset + `REAL_ADDR_WIDTH - 1]),
         .din(htw_lsu_addr_d),
         .dout(htw_lsu_addr_q)
      );

      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) pte0_seq_latch(
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
         .scin(siv_1[pte0_seq_offset:pte0_seq_offset + 3 - 1]),
         .scout(sov_1[pte0_seq_offset:pte0_seq_offset + 3 - 1]),
         .din(pte0_seq_d),
         .dout(pte0_seq_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) pte0_score_ptr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte0_score_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte0_score_ptr_offset:pte0_score_ptr_offset + 2 - 1]),
         .scout(sov_1[pte0_score_ptr_offset:pte0_score_ptr_offset + 2 - 1]),
         .din(pte0_score_ptr_d),
         .dout(pte0_score_ptr_q)
      );

      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) pte0_score_cl_offset_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte0_score_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte0_score_cl_offset_offset:pte0_score_cl_offset_offset + 3 - 1]),
         .scout(sov_1[pte0_score_cl_offset_offset:pte0_score_cl_offset_offset + 3 - 1]),
         .din(pte0_score_cl_offset_d),
         .dout(pte0_score_cl_offset_q)
      );

      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) pte0_score_error_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte0_score_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte0_score_error_offset:pte0_score_error_offset + 3 - 1]),
         .scout(sov_1[pte0_score_error_offset:pte0_score_error_offset + 3 - 1]),
         .din(pte0_score_error_d),
         .dout(pte0_score_error_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) pte0_score_qwbeat_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte0_score_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte0_score_qwbeat_offset:pte0_score_qwbeat_offset + 4 - 1]),
         .scout(sov_1[pte0_score_qwbeat_offset:pte0_score_qwbeat_offset + 4 - 1]),
         .din(pte0_score_qwbeat_d),
         .dout(pte0_score_qwbeat_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pte0_score_ibit_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte0_score_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte0_score_ibit_offset]),
         .scout(sov_1[pte0_score_ibit_offset]),
         .din(pte0_score_ibit_d),
         .dout(pte0_score_ibit_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pte0_score_pending_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte0_score_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte0_score_pending_offset]),
         .scout(sov_1[pte0_score_pending_offset]),
         .din(pte0_score_pending_d),
         .dout(pte0_score_pending_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pte0_score_dataval_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte0_score_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte0_score_dataval_offset]),
         .scout(sov_1[pte0_score_dataval_offset]),
         .din(pte0_score_dataval_d),
         .dout(pte0_score_dataval_q)
      );

      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) pte1_seq_latch(
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
         .scin(siv_1[pte1_seq_offset:pte1_seq_offset + 3 - 1]),
         .scout(sov_1[pte1_seq_offset:pte1_seq_offset + 3 - 1]),
         .din(pte1_seq_d),
         .dout(pte1_seq_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) pte1_score_ptr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte1_score_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte1_score_ptr_offset:pte1_score_ptr_offset + 2 - 1]),
         .scout(sov_1[pte1_score_ptr_offset:pte1_score_ptr_offset + 2 - 1]),
         .din(pte1_score_ptr_d),
         .dout(pte1_score_ptr_q)
      );

      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) pte1_score_cl_offset_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte1_score_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte1_score_cl_offset_offset:pte1_score_cl_offset_offset + 3 - 1]),
         .scout(sov_1[pte1_score_cl_offset_offset:pte1_score_cl_offset_offset + 3 - 1]),
         .din(pte1_score_cl_offset_d),
         .dout(pte1_score_cl_offset_q)
      );

      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) pte1_score_error_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte1_score_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte1_score_error_offset:pte1_score_error_offset + 3 - 1]),
         .scout(sov_1[pte1_score_error_offset:pte1_score_error_offset + 3 - 1]),
         .din(pte1_score_error_d),
         .dout(pte1_score_error_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) pte1_score_qwbeat_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte1_score_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte1_score_qwbeat_offset:pte1_score_qwbeat_offset + 4 - 1]),
         .scout(sov_1[pte1_score_qwbeat_offset:pte1_score_qwbeat_offset + 4 - 1]),
         .din(pte1_score_qwbeat_d),
         .dout(pte1_score_qwbeat_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pte1_score_ibit_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte1_score_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte1_score_ibit_offset]),
         .scout(sov_1[pte1_score_ibit_offset]),
         .din(pte1_score_ibit_d),
         .dout(pte1_score_ibit_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pte1_score_pending_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte1_score_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte1_score_pending_offset]),
         .scout(sov_1[pte1_score_pending_offset]),
         .din(pte1_score_pending_d),
         .dout(pte1_score_pending_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pte1_score_dataval_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte1_score_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte1_score_dataval_offset]),
         .scout(sov_1[pte1_score_dataval_offset]),
         .din(pte1_score_dataval_d),
         .dout(pte1_score_dataval_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pte_load_ptr_latch(
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
         .scin(siv_1[pte_load_ptr_offset]),
         .scout(sov_1[pte_load_ptr_offset]),
         .din(pte_load_ptr_d),
         .dout(pte_load_ptr_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ptereload_ptr_latch(
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
         .scin(siv_1[ptereload_ptr_offset]),
         .scout(sov_1[ptereload_ptr_offset]),
         .din(ptereload_ptr_d),
         .dout(ptereload_ptr_q)
      );
      //  t minus 1 phase latches

      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) reld_core_tag_tm1_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_core_tag_tm1_offset:reld_core_tag_tm1_offset + 5 - 1]),
         .scout(sov_1[reld_core_tag_tm1_offset:reld_core_tag_tm1_offset + 5 - 1]),
         .din(reld_core_tag_tm1_d),
         .dout(reld_core_tag_tm1_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) reld_qw_tm1_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_qw_tm1_offset:reld_qw_tm1_offset + 2 - 1]),
         .scout(sov_1[reld_qw_tm1_offset:reld_qw_tm1_offset + 2 - 1]),
         .din(reld_qw_tm1_d),
         .dout(reld_qw_tm1_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reld_crit_qw_tm1_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_crit_qw_tm1_offset]),
         .scout(sov_1[reld_crit_qw_tm1_offset]),
         .din(reld_crit_qw_tm1_d),
         .dout(reld_crit_qw_tm1_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reld_ditc_tm1_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_ditc_tm1_offset]),
         .scout(sov_1[reld_ditc_tm1_offset]),
         .din(reld_ditc_tm1_d),
         .dout(reld_ditc_tm1_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reld_data_vld_tm1_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_data_vld_tm1_offset]),
         .scout(sov_1[reld_data_vld_tm1_offset]),
         .din(reld_data_vld_tm1_d),
         .dout(reld_data_vld_tm1_q)
      );
      //  t   phase latches

      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) reld_core_tag_t_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_core_tag_t_offset:reld_core_tag_t_offset + 5 - 1]),
         .scout(sov_1[reld_core_tag_t_offset:reld_core_tag_t_offset + 5 - 1]),
         .din(reld_core_tag_t_d),
         .dout(reld_core_tag_t_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) reld_qw_t_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_qw_t_offset:reld_qw_t_offset + 2 - 1]),
         .scout(sov_1[reld_qw_t_offset:reld_qw_t_offset + 2 - 1]),
         .din(reld_qw_t_d),
         .dout(reld_qw_t_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reld_crit_qw_t_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_crit_qw_t_offset]),
         .scout(sov_1[reld_crit_qw_t_offset]),
         .din(reld_crit_qw_t_d),
         .dout(reld_crit_qw_t_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reld_ditc_t_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_ditc_t_offset]),
         .scout(sov_1[reld_ditc_t_offset]),
         .din(reld_ditc_t_d),
         .dout(reld_ditc_t_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reld_data_vld_t_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_data_vld_t_offset]),
         .scout(sov_1[reld_data_vld_t_offset]),
         .din(reld_data_vld_t_d),
         .dout(reld_data_vld_t_q)
      );
      //  t plus 1 phase latches

      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) reld_core_tag_tp1_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_core_tag_tp1_offset:reld_core_tag_tp1_offset + 5 - 1]),
         .scout(sov_1[reld_core_tag_tp1_offset:reld_core_tag_tp1_offset + 5 - 1]),
         .din(reld_core_tag_tp1_d),
         .dout(reld_core_tag_tp1_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) reld_qw_tp1_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_qw_tp1_offset:reld_qw_tp1_offset + 2 - 1]),
         .scout(sov_1[reld_qw_tp1_offset:reld_qw_tp1_offset + 2 - 1]),
         .din(reld_qw_tp1_d),
         .dout(reld_qw_tp1_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reld_crit_qw_tp1_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_crit_qw_tp1_offset]),
         .scout(sov_1[reld_crit_qw_tp1_offset]),
         .din(reld_crit_qw_tp1_d),
         .dout(reld_crit_qw_tp1_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reld_ditc_tp1_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_ditc_tp1_offset]),
         .scout(sov_1[reld_ditc_tp1_offset]),
         .din(reld_ditc_tp1_d),
         .dout(reld_ditc_tp1_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reld_data_vld_tp1_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_data_vld_tp1_offset]),
         .scout(sov_1[reld_data_vld_tp1_offset]),
         .din(reld_data_vld_tp1_d),
         .dout(reld_data_vld_tp1_q)
      );

      tri_rlmreg_p #(.WIDTH(128), .INIT(0), .NEEDS_SRESET(1)) reld_data_tp1_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_data_tp1_offset:reld_data_tp1_offset + 128 - 1]),
         .scout(sov_1[reld_data_tp1_offset:reld_data_tp1_offset + 128 - 1]),
         .din(reld_data_tp1_d),
         .dout(reld_data_tp1_q)
      );
      //  t plus 2 phase latches

      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) reld_core_tag_tp2_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_core_tag_tp2_offset:reld_core_tag_tp2_offset + 5 - 1]),
         .scout(sov_1[reld_core_tag_tp2_offset:reld_core_tag_tp2_offset + 5 - 1]),
         .din(reld_core_tag_tp2_d),
         .dout(reld_core_tag_tp2_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) reld_qw_tp2_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_qw_tp2_offset:reld_qw_tp2_offset + 2 - 1]),
         .scout(sov_1[reld_qw_tp2_offset:reld_qw_tp2_offset + 2 - 1]),
         .din(reld_qw_tp2_d),
         .dout(reld_qw_tp2_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reld_crit_qw_tp2_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_crit_qw_tp2_offset]),
         .scout(sov_1[reld_crit_qw_tp2_offset]),
         .din(reld_crit_qw_tp2_d),
         .dout(reld_crit_qw_tp2_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reld_ditc_tp2_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_ditc_tp2_offset]),
         .scout(sov_1[reld_ditc_tp2_offset]),
         .din(reld_ditc_tp2_d),
         .dout(reld_ditc_tp2_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reld_data_vld_tp2_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_data_vld_tp2_offset]),
         .scout(sov_1[reld_data_vld_tp2_offset]),
         .din(reld_data_vld_tp2_d),
         .dout(reld_data_vld_tp2_q)
      );

      tri_rlmreg_p #(.WIDTH(128), .INIT(0), .NEEDS_SRESET(1)) reld_data_tp2_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_data_tp2_offset:reld_data_tp2_offset + 128 - 1]),
         .scout(sov_1[reld_data_tp2_offset:reld_data_tp2_offset + 128 - 1]),
         .din(reld_data_tp2_d),
         .dout(reld_data_tp2_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reld_ecc_err_tp2_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_ecc_err_tp2_offset]),
         .scout(sov_1[reld_ecc_err_tp2_offset]),
         .din(reld_ecc_err_tp2_d),
         .dout(reld_ecc_err_tp2_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reld_ecc_err_ue_tp2_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[reld_ecc_err_ue_tp2_offset]),
         .scout(sov_1[reld_ecc_err_ue_tp2_offset]),
         .din(reld_ecc_err_ue_tp2_d),
         .dout(reld_ecc_err_ue_tp2_q)
      );
      //  t plus 3 phase

      tri_rlmreg_p #(.WIDTH(64), .INIT(0), .NEEDS_SRESET(1)) pte0_reld_data_tp3_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte0_reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte0_reld_data_tp3_offset:pte0_reld_data_tp3_offset + 64 - 1]),
         .scout(sov_1[pte0_reld_data_tp3_offset:pte0_reld_data_tp3_offset + 64 - 1]),
         .din(pte0_reld_data_tp3_d),
         .dout(pte0_reld_data_tp3_q)
      );

      tri_rlmreg_p #(.WIDTH(64), .INIT(0), .NEEDS_SRESET(1)) pte1_reld_data_tp3_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(pte1_reld_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[pte1_reld_data_tp3_offset:pte1_reld_data_tp3_offset + 64 - 1]),
         .scout(sov_1[pte1_reld_data_tp3_offset:pte1_reld_data_tp3_offset + 64 - 1]),
         .din(pte1_reld_data_tp3_d),
         .dout(pte1_reld_data_tp3_q)
      );

      tri_rlmreg_p #(.WIDTH(`TLB_TAG_WIDTH), .INIT(0), .NEEDS_SRESET(1)) htw_tag3_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[28]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[htw_tag3_offset:htw_tag3_offset + `TLB_TAG_WIDTH - 1]),
         .scout(sov_1[htw_tag3_offset:htw_tag3_offset + `TLB_TAG_WIDTH - 1]),
         .din(htw_tag3_d),
         .dout(htw_tag3_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) htw_tag4_clr_resv_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[28]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[htw_tag4_clr_resv_offset:htw_tag4_clr_resv_offset + `THDID_WIDTH - 1]),
         .scout(sov_1[htw_tag4_clr_resv_offset:htw_tag4_clr_resv_offset + `THDID_WIDTH - 1]),
         .din(htw_tag4_clr_resv_d),
         .dout(htw_tag4_clr_resv_q)
      );

      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) htw_tag5_clr_resv_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[28]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[htw_tag5_clr_resv_offset:htw_tag5_clr_resv_offset + `THDID_WIDTH - 1]),
         .scout(sov_1[htw_tag5_clr_resv_offset:htw_tag5_clr_resv_offset + `THDID_WIDTH - 1]),
         .din(htw_tag5_clr_resv_d),
         .dout(htw_tag5_clr_resv_q)
      );

      tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) spare_b_latch(
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
         .scin(siv_1[spare_b_offset:spare_b_offset + 16 - 1]),
         .scout(sov_1[spare_b_offset:spare_b_offset + 16 - 1]),
         .din(spare_b_q),
         .dout(spare_b_q)
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


      //---------------------------------------------------------------------
      // Scan
      //---------------------------------------------------------------------
      assign siv_0[0:scan_right_0] = {sov_0[1:scan_right_0], ac_func_scan_in[0]};
      assign ac_func_scan_out[0] = sov_0[0];
      assign siv_1[0:scan_right_1] = {sov_1[1:scan_right_1], ac_func_scan_in[1]};
      assign ac_func_scan_out[1] = sov_1[0];

      function Eq;
        input  a, b;
        reg  result;
          begin
            if (a == b)
            begin
              result = 1'b1;
            end
            else
            begin
               result = 1'b0;
            end
            Eq = result;
          end
       endfunction

endmodule
