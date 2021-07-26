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
//* TITLE: MMU Logical to Real Translate Logic
//* NAME: mmq_tlb_lrat.vhdl
//*********************************************************************

`timescale 1 ns / 1 ns

`include "tri_a2o.vh"
`include "mmu_a2o.vh"
`define            LRAT_TTYPE_WIDTH        5
`define            LRAT_NUM_ENTRY          8
`define            LRAT_NUM_ENTRY_LOG2     3
`define            LRAT_MAXSIZE_LOG2       40
`define            LRAT_MINSIZE_LOG2       20


module mmq_tlb_lrat(

   inout                                            vdd,
   inout                                            gnd,
   (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]                          nclk,

   input                                            tc_ccflush_dc,
   input                                            tc_scan_dis_dc_b,
   input                                            tc_scan_diag_dc,
   input                                            tc_lbist_en_dc,
   input                                            lcb_d_mode_dc,
   input                                            lcb_clkoff_dc_b,
   input                                            lcb_act_dis_dc,
   input [0:4]                                      lcb_mpw1_dc_b,
   input                                            lcb_mpw2_dc_b,
   input [0:4]                                      lcb_delay_lclkr_dc,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                                            ac_func_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                                           ac_func_scan_out,

   input                                            pc_sg_2,
   input                                            pc_func_sl_thold_2,
   input                                            pc_func_slp_sl_thold_2,

   input                                            xu_mm_ccr2_notlb_b,
   input [20:23]                                    tlb_delayed_act,
   input                                            mmucr2_act_override,
   input [0:`MM_THREADS-1]                          tlb_ctl_ex3_valid,
   input [0:`LRAT_TTYPE_WIDTH-1]                    tlb_ctl_ex3_ttype,
   input                                            tlb_ctl_ex3_hv_state,
   input [0:`MM_THREADS-1]                          xu_ex3_flush,
   input [0:`MM_THREADS-1]                          xu_ex4_flush,
   input [0:`MM_THREADS-1]                          xu_ex5_flush,
   input [64-`REAL_ADDR_WIDTH:51]                   tlb_tag0_epn,
   input [0:`THDID_WIDTH-1]                         tlb_tag0_thdid,
   input [0:7]                                      tlb_tag0_type,
   input [0:`LPID_WIDTH-1]                          tlb_tag0_lpid,
   input [0:3]                                      tlb_tag0_size,
   input                                            tlb_tag0_atsel,
   input                                            tlb_tag0_addr_cap,
   input [0:1]                                      ex6_illeg_instr,   // bad tlbre|tlbwe indication from tlb_ctl
   input [64-`REAL_ADDR_WIDTH:51]                   pte_tag0_lpn,
   input [0:`LPID_WIDTH-1]                          pte_tag0_lpid,
   input                                            mas0_0_atsel,
   input [0:`LRAT_NUM_ENTRY_LOG2-1]                 mas0_0_esel,
   input                                            mas0_0_hes,
   input [0:1]                                      mas0_0_wq,
   input                                            mas1_0_v,
   input [0:3]                                      mas1_0_tsize,
   input [64-`REAL_ADDR_WIDTH:51]                   mas2_0_epn,
   input [22:31]                                    mas7_0_rpnu,
   input [32:51]                                    mas3_0_rpnl,
   input [0:`LPID_WIDTH-1]                          mas8_0_tlpid,
   input                                            mmucr3_0_x,
`ifdef MM_THREADS2
   input                                            mas0_1_atsel,
   input [0:`LRAT_NUM_ENTRY_LOG2-1]                 mas0_1_esel,
   input                                            mas0_1_hes,
   input [0:1]                                      mas0_1_wq,
   input                                            mas1_1_v,
   input [0:3]                                      mas1_1_tsize,
   input [64-`REAL_ADDR_WIDTH:51]                   mas2_1_epn,
   input [22:31]                                    mas7_1_rpnu,
   input [32:51]                                    mas3_1_rpnl,
   input [0:`LPID_WIDTH-1]                          mas8_1_tlpid,
   input                                            mmucr3_1_x,
`endif

   output                                           lrat_mmucr3_x,
   output [0:2]                                     lrat_mas0_esel,
   output                                           lrat_mas1_v,
   output [0:3]                                     lrat_mas1_tsize,
   output [0:51]                                    lrat_mas2_epn,
   output [32:51]                                   lrat_mas3_rpnl,
   output [22:31]                                   lrat_mas7_rpnu,
   output [0:`LPID_WIDTH-1]                         lrat_mas8_tlpid,
   output                                           lrat_mas_tlbre,
   output                                           lrat_mas_tlbsx_hit,
   output                                           lrat_mas_tlbsx_miss,
   output [0:`MM_THREADS-1]                         lrat_mas_thdid,
   output [64-`REAL_ADDR_WIDTH:51]                  lrat_tag3_lpn,
   output [64-`REAL_ADDR_WIDTH:51]                  lrat_tag3_rpn,
   output [0:3]                                     lrat_tag3_hit_status,
   output [0:`LRAT_NUM_ENTRY_LOG2-1]                lrat_tag3_hit_entry,
   output [64-`REAL_ADDR_WIDTH:51]                  lrat_tag4_lpn,
   output [64-`REAL_ADDR_WIDTH:51]                  lrat_tag4_rpn,
   output [0:3]                                     lrat_tag4_hit_status,
   output [0:`LRAT_NUM_ENTRY_LOG2-1]                lrat_tag4_hit_entry,

   output                                           lrat_dbg_tag1_addr_enable,
   output [0:7]                                     lrat_dbg_tag2_matchline_q,
   output                                           lrat_dbg_entry0_addr_match,
   output                                           lrat_dbg_entry0_lpid_match,
   output                                           lrat_dbg_entry0_entry_v,
   output                                           lrat_dbg_entry0_entry_x,
   output [0:3]                                     lrat_dbg_entry0_size,
   output                                           lrat_dbg_entry1_addr_match,
   output                                           lrat_dbg_entry1_lpid_match,
   output                                           lrat_dbg_entry1_entry_v,
   output                                           lrat_dbg_entry1_entry_x,
   output [0:3]                                     lrat_dbg_entry1_size,
   output                                           lrat_dbg_entry2_addr_match,
   output                                           lrat_dbg_entry2_lpid_match,
   output                                           lrat_dbg_entry2_entry_v,
   output                                           lrat_dbg_entry2_entry_x,
   output [0:3]                                     lrat_dbg_entry2_size,
   output                                           lrat_dbg_entry3_addr_match,
   output                                           lrat_dbg_entry3_lpid_match,
   output                                           lrat_dbg_entry3_entry_v,
   output                                           lrat_dbg_entry3_entry_x,
   output [0:3]                                     lrat_dbg_entry3_size,
   output                                           lrat_dbg_entry4_addr_match,
   output                                           lrat_dbg_entry4_lpid_match,
   output                                           lrat_dbg_entry4_entry_v,
   output                                           lrat_dbg_entry4_entry_x,
   output [0:3]                                     lrat_dbg_entry4_size,
   output                                           lrat_dbg_entry5_addr_match,
   output                                           lrat_dbg_entry5_lpid_match,
   output                                           lrat_dbg_entry5_entry_v,
   output                                           lrat_dbg_entry5_entry_x,
   output [0:3]                                     lrat_dbg_entry5_size,
   output                                           lrat_dbg_entry6_addr_match,
   output                                           lrat_dbg_entry6_lpid_match,
   output                                           lrat_dbg_entry6_entry_v,
   output                                           lrat_dbg_entry6_entry_x,
   output [0:3]                                     lrat_dbg_entry6_size,
   output                                           lrat_dbg_entry7_addr_match,
   output                                           lrat_dbg_entry7_lpid_match,
   output                                           lrat_dbg_entry7_entry_v,
   output                                           lrat_dbg_entry7_entry_x,
   output [0:3]                                     lrat_dbg_entry7_size

);

      parameter                                        MMU_Mode_Value = 1'b0;
      parameter [0:3]                                  TLB_PgSize_1GB = 4'b1010;
      parameter [0:3]                                  TLB_PgSize_256MB = 4'b1001;
      parameter [0:3]                                  TLB_PgSize_16MB = 4'b0111;
      parameter [0:3]                                  TLB_PgSize_1MB = 4'b0101;
      parameter [0:3]                                  TLB_PgSize_64KB = 4'b0011;
      parameter [0:3]                                  TLB_PgSize_4KB = 4'b0001;
      parameter [0:3]                                  LRAT_PgSize_1TB = 4'b1111;
      parameter [0:3]                                  LRAT_PgSize_256GB = 4'b1110;
      parameter [0:3]                                  LRAT_PgSize_16GB = 4'b1100;
      parameter [0:3]                                  LRAT_PgSize_4GB = 4'b1011;
      parameter [0:3]                                  LRAT_PgSize_1GB = 4'b1010;
      parameter [0:3]                                  LRAT_PgSize_256MB = 4'b1001;
      parameter [0:3]                                  LRAT_PgSize_16MB = 4'b0111;
      parameter [0:3]                                  LRAT_PgSize_1MB = 4'b0101;
      parameter                                        LRAT_PgSize_1TB_log2 = 40;
      parameter                                        LRAT_PgSize_256GB_log2 = 38;
      parameter                                        LRAT_PgSize_16GB_log2 = 34;
      parameter                                        LRAT_PgSize_4GB_log2 = 32;
      parameter                                        LRAT_PgSize_1GB_log2 = 30;
      parameter                                        LRAT_PgSize_256MB_log2 = 28;
      parameter                                        LRAT_PgSize_16MB_log2 = 24;
      parameter                                        LRAT_PgSize_1MB_log2 = 20;
      // derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      parameter                                        lrat_tagpos_type = 0;
      parameter                                        lrat_tagpos_type_derat     = lrat_tagpos_type;
      parameter                                        lrat_tagpos_type_ierat     = lrat_tagpos_type + 1;
      parameter                                        lrat_tagpos_type_tlbsx     = lrat_tagpos_type + 2;
      parameter                                        lrat_tagpos_type_tlbsrx    = lrat_tagpos_type + 3;
      parameter                                        lrat_tagpos_type_snoop     = lrat_tagpos_type + 4;
      parameter                                        lrat_tagpos_type_tlbre     = lrat_tagpos_type + 5;
      parameter                                        lrat_tagpos_type_tlbwe     = lrat_tagpos_type + 6;
      parameter                                        lrat_tagpos_type_ptereload = lrat_tagpos_type + 7;

      // scan path constants
      parameter                                        ex4_valid_offset = 0;
      parameter                                        ex4_ttype_offset = ex4_valid_offset + `MM_THREADS;
      parameter                                        ex4_hv_state_offset = ex4_ttype_offset + `LRAT_TTYPE_WIDTH;
      parameter                                        ex5_valid_offset = ex4_hv_state_offset + 1;
      parameter                                        ex5_ttype_offset = ex5_valid_offset + `MM_THREADS;
      parameter                                        ex5_esel_offset = ex5_ttype_offset + `LRAT_TTYPE_WIDTH;
      parameter                                        ex5_atsel_offset = ex5_esel_offset + 3;
      parameter                                        ex5_wq_offset = ex5_atsel_offset + 1;
      parameter                                        ex5_hes_offset = ex5_wq_offset + 2;
      parameter                                        ex5_hv_state_offset = ex5_hes_offset + 1;
      parameter                                        ex6_valid_offset = ex5_hv_state_offset + 1;
      parameter                                        ex6_ttype_offset = ex6_valid_offset + `MM_THREADS;
      parameter                                        ex6_esel_offset = ex6_ttype_offset + `LRAT_TTYPE_WIDTH;
      parameter                                        ex6_atsel_offset = ex6_esel_offset + 3;
      parameter                                        ex6_wq_offset = ex6_atsel_offset + 1;
      parameter                                        ex6_hes_offset = ex6_wq_offset + 2;
      parameter                                        ex6_hv_state_offset = ex6_hes_offset + 1;
      parameter                                        lrat_tag1_lpn_offset = ex6_hv_state_offset + 1;
      parameter                                        lrat_tag2_lpn_offset = lrat_tag1_lpn_offset + `RPN_WIDTH;
      parameter                                        lrat_tag3_lpn_offset = lrat_tag2_lpn_offset + `RPN_WIDTH;
      parameter                                        lrat_tag3_rpn_offset = lrat_tag3_lpn_offset + `RPN_WIDTH;
      parameter                                        lrat_tag4_lpn_offset = lrat_tag3_rpn_offset + `RPN_WIDTH;
      parameter                                        lrat_tag4_rpn_offset = lrat_tag4_lpn_offset + `RPN_WIDTH;
      parameter                                        lrat_tag1_lpid_offset = lrat_tag4_rpn_offset + `RPN_WIDTH;
      parameter                                        lrat_tag1_size_offset = lrat_tag1_lpid_offset + `LPID_WIDTH;
      parameter                                        lrat_tag2_size_offset = lrat_tag1_size_offset + 4;
      parameter                                        lrat_tag2_entry_size_offset = lrat_tag2_size_offset + 4;
      parameter                                        lrat_tag2_matchline_offset = lrat_tag2_entry_size_offset + 4;
      parameter                                        lrat_tag3_hit_status_offset = lrat_tag2_matchline_offset + `LRAT_NUM_ENTRY;
      parameter                                        lrat_tag3_hit_entry_offset = lrat_tag3_hit_status_offset + 4;
      parameter                                        lrat_tag4_hit_status_offset = lrat_tag3_hit_entry_offset + `LRAT_NUM_ENTRY_LOG2;
      parameter                                        lrat_tag4_hit_entry_offset = lrat_tag4_hit_status_offset + 4;
      parameter                                        tlb_addr_cap_offset = lrat_tag4_hit_entry_offset + `LRAT_NUM_ENTRY_LOG2;
      parameter                                        lrat_entry0_lpn_offset = tlb_addr_cap_offset + 2;
      parameter                                        lrat_entry0_rpn_offset = lrat_entry0_lpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry0_lpid_offset = lrat_entry0_rpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry0_size_offset = lrat_entry0_lpid_offset + `LPID_WIDTH;
      parameter                                        lrat_entry0_cmpmask_offset = lrat_entry0_size_offset + 4;
      parameter                                        lrat_entry0_xbitmask_offset = lrat_entry0_cmpmask_offset + 7;
      parameter                                        lrat_entry0_xbit_offset = lrat_entry0_xbitmask_offset + 7;
      parameter                                        lrat_entry0_valid_offset = lrat_entry0_xbit_offset + 1;
      parameter                                        lrat_entry1_lpn_offset = lrat_entry0_valid_offset + 1;
      parameter                                        lrat_entry1_rpn_offset = lrat_entry1_lpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry1_lpid_offset = lrat_entry1_rpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry1_size_offset = lrat_entry1_lpid_offset + `LPID_WIDTH;
      parameter                                        lrat_entry1_cmpmask_offset = lrat_entry1_size_offset + 4;
      parameter                                        lrat_entry1_xbitmask_offset = lrat_entry1_cmpmask_offset + 7;
      parameter                                        lrat_entry1_xbit_offset = lrat_entry1_xbitmask_offset + 7;
      parameter                                        lrat_entry1_valid_offset = lrat_entry1_xbit_offset + 1;
      parameter                                        lrat_entry2_lpn_offset = lrat_entry1_valid_offset + 1;
      parameter                                        lrat_entry2_rpn_offset = lrat_entry2_lpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry2_lpid_offset = lrat_entry2_rpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry2_size_offset = lrat_entry2_lpid_offset + `LPID_WIDTH;
      parameter                                        lrat_entry2_cmpmask_offset = lrat_entry2_size_offset + 4;
      parameter                                        lrat_entry2_xbitmask_offset = lrat_entry2_cmpmask_offset + 7;
      parameter                                        lrat_entry2_xbit_offset = lrat_entry2_xbitmask_offset + 7;
      parameter                                        lrat_entry2_valid_offset = lrat_entry2_xbit_offset + 1;
      parameter                                        lrat_entry3_lpn_offset = lrat_entry2_valid_offset + 1;
      parameter                                        lrat_entry3_rpn_offset = lrat_entry3_lpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry3_lpid_offset = lrat_entry3_rpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry3_size_offset = lrat_entry3_lpid_offset + `LPID_WIDTH;
      parameter                                        lrat_entry3_cmpmask_offset = lrat_entry3_size_offset + 4;
      parameter                                        lrat_entry3_xbitmask_offset = lrat_entry3_cmpmask_offset + 7;
      parameter                                        lrat_entry3_xbit_offset = lrat_entry3_xbitmask_offset + 7;
      parameter                                        lrat_entry3_valid_offset = lrat_entry3_xbit_offset + 1;
      parameter                                        lrat_entry4_lpn_offset = lrat_entry3_valid_offset + 1;
      parameter                                        lrat_entry4_rpn_offset = lrat_entry4_lpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry4_lpid_offset = lrat_entry4_rpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry4_size_offset = lrat_entry4_lpid_offset + `LPID_WIDTH;
      parameter                                        lrat_entry4_cmpmask_offset = lrat_entry4_size_offset + 4;
      parameter                                        lrat_entry4_xbitmask_offset = lrat_entry4_cmpmask_offset + 7;
      parameter                                        lrat_entry4_xbit_offset = lrat_entry4_xbitmask_offset + 7;
      parameter                                        lrat_entry4_valid_offset = lrat_entry4_xbit_offset + 1;
      parameter                                        lrat_entry5_lpn_offset = lrat_entry4_valid_offset + 1;
      parameter                                        lrat_entry5_rpn_offset = lrat_entry5_lpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry5_lpid_offset = lrat_entry5_rpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry5_size_offset = lrat_entry5_lpid_offset + `LPID_WIDTH;
      parameter                                        lrat_entry5_cmpmask_offset = lrat_entry5_size_offset + 4;
      parameter                                        lrat_entry5_xbitmask_offset = lrat_entry5_cmpmask_offset + 7;
      parameter                                        lrat_entry5_xbit_offset = lrat_entry5_xbitmask_offset + 7;
      parameter                                        lrat_entry5_valid_offset = lrat_entry5_xbit_offset + 1;
      parameter                                        lrat_entry6_lpn_offset = lrat_entry5_valid_offset + 1;
      parameter                                        lrat_entry6_rpn_offset = lrat_entry6_lpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry6_lpid_offset = lrat_entry6_rpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry6_size_offset = lrat_entry6_lpid_offset + `LPID_WIDTH;
      parameter                                        lrat_entry6_cmpmask_offset = lrat_entry6_size_offset + 4;
      parameter                                        lrat_entry6_xbitmask_offset = lrat_entry6_cmpmask_offset + 7;
      parameter                                        lrat_entry6_xbit_offset = lrat_entry6_xbitmask_offset + 7;
      parameter                                        lrat_entry6_valid_offset = lrat_entry6_xbit_offset + 1;
      parameter                                        lrat_entry7_lpn_offset = lrat_entry6_valid_offset + 1;
      parameter                                        lrat_entry7_rpn_offset = lrat_entry7_lpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry7_lpid_offset = lrat_entry7_rpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_entry7_size_offset = lrat_entry7_lpid_offset + `LPID_WIDTH;
      parameter                                        lrat_entry7_cmpmask_offset = lrat_entry7_size_offset + 4;
      parameter                                        lrat_entry7_xbitmask_offset = lrat_entry7_cmpmask_offset + 7;
      parameter                                        lrat_entry7_xbit_offset = lrat_entry7_xbitmask_offset + 7;
      parameter                                        lrat_entry7_valid_offset = lrat_entry7_xbit_offset + 1;
      parameter                                        lrat_datain_lpn_offset = lrat_entry7_valid_offset + 1;
      parameter                                        lrat_datain_rpn_offset = lrat_datain_lpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_datain_lpid_offset = lrat_datain_rpn_offset + `REAL_ADDR_WIDTH - `LRAT_MINSIZE_LOG2;
      parameter                                        lrat_datain_size_offset = lrat_datain_lpid_offset + `LPID_WIDTH;
      parameter                                        lrat_datain_xbit_offset = lrat_datain_size_offset + 4;
      parameter                                        lrat_datain_valid_offset = lrat_datain_xbit_offset + 1;
      parameter                                        lrat_mas1_v_offset = lrat_datain_valid_offset + 1;
      parameter                                        lrat_mas1_tsize_offset = lrat_mas1_v_offset + 1;
      parameter                                        lrat_mas2_epn_offset = lrat_mas1_tsize_offset + 4;
      parameter                                        lrat_mas3_rpnl_offset = lrat_mas2_epn_offset + `RPN_WIDTH;
      parameter                                        lrat_mas7_rpnu_offset = lrat_mas3_rpnl_offset + 20;
      parameter                                        lrat_mas8_tlpid_offset = lrat_mas7_rpnu_offset + 10;
      parameter                                        lrat_mas_tlbre_offset = lrat_mas8_tlpid_offset + `LPID_WIDTH;
      parameter                                        lrat_mas_tlbsx_hit_offset = lrat_mas_tlbre_offset + 1;
      parameter                                        lrat_mas_tlbsx_miss_offset = lrat_mas_tlbsx_hit_offset + 1;
      parameter                                        lrat_mas_thdid_offset = lrat_mas_tlbsx_miss_offset + 1;
      parameter                                        lrat_mmucr3_x_offset = lrat_mas_thdid_offset + `MM_THREADS;
      parameter                                        lrat_entry_act_offset = lrat_mmucr3_x_offset + 1;
      parameter                                        lrat_mas_act_offset = lrat_entry_act_offset + 8;
      parameter                                        lrat_datain_act_offset = lrat_mas_act_offset + 3;
      parameter                                        spare_offset = lrat_datain_act_offset + 2;
      parameter                                        scan_right = spare_offset + 64 - 1;

      parameter                                        const_lrat_maxsize_log2 = `REAL_ADDR_WIDTH - 2;

`ifdef MM_THREADS2
      parameter                      BUGSP_MM_THREADS = 2;
`else
      parameter                      BUGSP_MM_THREADS = 1;
`endif

      // Latch signals
      wire [0:`MM_THREADS-1]                           ex4_valid_d;
      wire [0:`MM_THREADS-1]                           ex4_valid_q;
      wire [0:`LRAT_TTYPE_WIDTH-1]                     ex4_ttype_d;
      wire [0:`LRAT_TTYPE_WIDTH-1]                     ex4_ttype_q;
      wire                                             ex4_hv_state_d;
      wire                                             ex4_hv_state_q;
      wire [0:`MM_THREADS-1]                           ex5_valid_d;
      wire [0:`MM_THREADS-1]                           ex5_valid_q;
      wire [0:`LRAT_TTYPE_WIDTH-1]                     ex5_ttype_d;
      wire [0:`LRAT_TTYPE_WIDTH-1]                     ex5_ttype_q;
      wire [0:`LRAT_NUM_ENTRY_LOG2-1]                  ex5_esel_d;
      wire [0:`LRAT_NUM_ENTRY_LOG2-1]                  ex5_esel_q;
      wire                                             ex5_atsel_d;
      wire                                             ex5_atsel_q;
      wire                                             ex5_hes_d;
      wire                                             ex5_hes_q;
      wire [0:1]                                       ex5_wq_d;
      wire [0:1]                                       ex5_wq_q;
      wire                                             ex5_hv_state_d;
      wire                                             ex5_hv_state_q;
      wire [0:`MM_THREADS-1]                           ex6_valid_d;
      wire [0:`MM_THREADS-1]                           ex6_valid_q;
      wire [0:`LRAT_TTYPE_WIDTH-1]                     ex6_ttype_d;
      wire [0:`LRAT_TTYPE_WIDTH-1]                     ex6_ttype_q;
      wire [0:`LRAT_NUM_ENTRY_LOG2-1]                  ex6_esel_d;
      wire [0:`LRAT_NUM_ENTRY_LOG2-1]                  ex6_esel_q;
      wire                                             ex6_atsel_d;
      wire                                             ex6_atsel_q;
      wire                                             ex6_hes_d;
      wire                                             ex6_hes_q;
      wire [0:1]                                       ex6_wq_d;
      wire [0:1]                                       ex6_wq_q;
      wire                                             ex6_hv_state_d;
      wire                                             ex6_hv_state_q;
      wire [64-`REAL_ADDR_WIDTH:51]                     lrat_tag1_lpn_d;
      wire [64-`REAL_ADDR_WIDTH:51]                     lrat_tag1_lpn_q;
      wire [64-`REAL_ADDR_WIDTH:51]                     lrat_tag2_lpn_d;
      wire [64-`REAL_ADDR_WIDTH:51]                     lrat_tag2_lpn_q;
      wire [64-`REAL_ADDR_WIDTH:51]                     lrat_tag3_lpn_d;
      wire [64-`REAL_ADDR_WIDTH:51]                     lrat_tag3_lpn_q;
      wire [64-`REAL_ADDR_WIDTH:51]                     lrat_tag3_rpn_d;
      wire [64-`REAL_ADDR_WIDTH:51]                     lrat_tag3_rpn_q;
      wire [64-`REAL_ADDR_WIDTH:51]                     lrat_tag4_lpn_d;
      wire [64-`REAL_ADDR_WIDTH:51]                     lrat_tag4_lpn_q;
      wire [64-`REAL_ADDR_WIDTH:51]                     lrat_tag4_rpn_d;
      wire [64-`REAL_ADDR_WIDTH:51]                     lrat_tag4_rpn_q;
      wire [0:`LPID_WIDTH-1]                            lrat_tag1_lpid_d;
      wire [0:`LPID_WIDTH-1]                            lrat_tag1_lpid_q;
      wire [0:`LRAT_NUM_ENTRY-1]                        lrat_tag2_matchline_d;
      wire [0:`LRAT_NUM_ENTRY-1]                        lrat_tag2_matchline_q;
      wire [0:3]                                       lrat_tag1_size_d;
      wire [0:3]                                       lrat_tag1_size_q;
      wire [0:3]                                       lrat_tag2_size_d;
      wire [0:3]                                       lrat_tag2_size_q;
      wire [0:3]                                       lrat_tag2_entry_size_d;
      wire [0:3]                                       lrat_tag2_entry_size_q;
      wire [0:3]                                       lrat_tag3_hit_status_d;
      wire [0:3]                                       lrat_tag3_hit_status_q;
      wire [0:`LRAT_NUM_ENTRY_LOG2-1]                   lrat_tag3_hit_entry_d;
      wire [0:`LRAT_NUM_ENTRY_LOG2-1]                   lrat_tag3_hit_entry_q;
      wire [0:3]                                       lrat_tag4_hit_status_d;
      wire [0:3]                                       lrat_tag4_hit_status_q;
      wire [0:`LRAT_NUM_ENTRY_LOG2-1]                   lrat_tag4_hit_entry_d;
      wire [0:`LRAT_NUM_ENTRY_LOG2-1]                   lrat_tag4_hit_entry_q;
      wire [1:2]                                       tlb_addr_cap_d;
      wire [1:2]                                       tlb_addr_cap_q;
      wire                                             lrat_entry0_wren;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry0_lpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry0_lpn_q;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry0_rpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry0_rpn_q;
      wire [0:`LPID_WIDTH-1]                            lrat_entry0_lpid_d;
      wire [0:`LPID_WIDTH-1]                            lrat_entry0_lpid_q;
      wire [0:3]                                       lrat_entry0_size_d;
      wire [0:3]                                       lrat_entry0_size_q;
      wire [0:6]                                       lrat_entry0_cmpmask_d;
      wire [0:6]                                       lrat_entry0_cmpmask_q;
      wire [0:6]                                       lrat_entry0_xbitmask_d;
      wire [0:6]                                       lrat_entry0_xbitmask_q;
      wire                                             lrat_entry0_xbit_d;
      wire                                             lrat_entry0_xbit_q;
      wire                                             lrat_entry0_valid_d;
      wire                                             lrat_entry0_valid_q;
      wire                                             lrat_entry1_wren;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry1_lpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry1_lpn_q;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry1_rpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry1_rpn_q;
      wire [0:`LPID_WIDTH-1]                            lrat_entry1_lpid_d;
      wire [0:`LPID_WIDTH-1]                            lrat_entry1_lpid_q;
      wire [0:3]                                       lrat_entry1_size_d;
      wire [0:3]                                       lrat_entry1_size_q;
      wire [0:6]                                       lrat_entry1_cmpmask_d;
      wire [0:6]                                       lrat_entry1_cmpmask_q;
      wire [0:6]                                       lrat_entry1_xbitmask_d;
      wire [0:6]                                       lrat_entry1_xbitmask_q;
      wire                                             lrat_entry1_xbit_d;
      wire                                             lrat_entry1_xbit_q;
      wire                                             lrat_entry1_valid_d;
      wire                                             lrat_entry1_valid_q;
      wire                                             lrat_entry2_wren;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry2_lpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry2_lpn_q;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry2_rpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry2_rpn_q;
      wire [0:`LPID_WIDTH-1]                            lrat_entry2_lpid_d;
      wire [0:`LPID_WIDTH-1]                            lrat_entry2_lpid_q;
      wire [0:3]                                       lrat_entry2_size_d;
      wire [0:3]                                       lrat_entry2_size_q;
      wire [0:6]                                       lrat_entry2_cmpmask_d;
      wire [0:6]                                       lrat_entry2_cmpmask_q;
      wire [0:6]                                       lrat_entry2_xbitmask_d;
      wire [0:6]                                       lrat_entry2_xbitmask_q;
      wire                                             lrat_entry2_xbit_d;
      wire                                             lrat_entry2_xbit_q;
      wire                                             lrat_entry2_valid_d;
      wire                                             lrat_entry2_valid_q;
      wire                                             lrat_entry3_wren;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry3_lpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry3_lpn_q;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry3_rpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry3_rpn_q;
      wire [0:`LPID_WIDTH-1]                            lrat_entry3_lpid_d;
      wire [0:`LPID_WIDTH-1]                            lrat_entry3_lpid_q;
      wire [0:3]                                       lrat_entry3_size_d;
      wire [0:3]                                       lrat_entry3_size_q;
      wire [0:6]                                       lrat_entry3_cmpmask_d;
      wire [0:6]                                       lrat_entry3_cmpmask_q;
      wire [0:6]                                       lrat_entry3_xbitmask_d;
      wire [0:6]                                       lrat_entry3_xbitmask_q;
      wire                                             lrat_entry3_xbit_d;
      wire                                             lrat_entry3_xbit_q;
      wire                                             lrat_entry3_valid_d;
      wire                                             lrat_entry3_valid_q;
      wire                                             lrat_entry4_wren;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry4_lpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry4_lpn_q;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry4_rpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry4_rpn_q;
      wire [0:`LPID_WIDTH-1]                            lrat_entry4_lpid_d;
      wire [0:`LPID_WIDTH-1]                            lrat_entry4_lpid_q;
      wire [0:3]                                       lrat_entry4_size_d;
      wire [0:3]                                       lrat_entry4_size_q;
      wire [0:6]                                       lrat_entry4_cmpmask_d;
      wire [0:6]                                       lrat_entry4_cmpmask_q;
      wire [0:6]                                       lrat_entry4_xbitmask_d;
      wire [0:6]                                       lrat_entry4_xbitmask_q;
      wire                                             lrat_entry4_xbit_d;
      wire                                             lrat_entry4_xbit_q;
      wire                                             lrat_entry4_valid_d;
      wire                                             lrat_entry4_valid_q;
      wire                                             lrat_entry5_wren;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry5_lpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry5_lpn_q;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry5_rpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry5_rpn_q;
      wire [0:`LPID_WIDTH-1]                            lrat_entry5_lpid_d;
      wire [0:`LPID_WIDTH-1]                            lrat_entry5_lpid_q;
      wire [0:3]                                       lrat_entry5_size_d;
      wire [0:3]                                       lrat_entry5_size_q;
      wire [0:6]                                       lrat_entry5_cmpmask_d;
      wire [0:6]                                       lrat_entry5_cmpmask_q;
      wire [0:6]                                       lrat_entry5_xbitmask_d;
      wire [0:6]                                       lrat_entry5_xbitmask_q;
      wire                                             lrat_entry5_xbit_d;
      wire                                             lrat_entry5_xbit_q;
      wire                                             lrat_entry5_valid_d;
      wire                                             lrat_entry5_valid_q;
      wire                                             lrat_entry6_wren;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry6_lpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry6_lpn_q;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry6_rpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry6_rpn_q;
      wire [0:`LPID_WIDTH-1]                            lrat_entry6_lpid_d;
      wire [0:`LPID_WIDTH-1]                            lrat_entry6_lpid_q;
      wire [0:3]                                       lrat_entry6_size_d;
      wire [0:3]                                       lrat_entry6_size_q;
      wire [0:6]                                       lrat_entry6_cmpmask_d;
      wire [0:6]                                       lrat_entry6_cmpmask_q;
      wire [0:6]                                       lrat_entry6_xbitmask_d;
      wire [0:6]                                       lrat_entry6_xbitmask_q;
      wire                                             lrat_entry6_xbit_d;
      wire                                             lrat_entry6_xbit_q;
      wire                                             lrat_entry6_valid_d;
      wire                                             lrat_entry6_valid_q;
      wire                                             lrat_entry7_wren;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry7_lpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry7_lpn_q;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry7_rpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_entry7_rpn_q;
      wire [0:`LPID_WIDTH-1]                            lrat_entry7_lpid_d;
      wire [0:`LPID_WIDTH-1]                            lrat_entry7_lpid_q;
      wire [0:3]                                       lrat_entry7_size_d;
      wire [0:3]                                       lrat_entry7_size_q;
      wire [0:6]                                       lrat_entry7_cmpmask_d;
      wire [0:6]                                       lrat_entry7_cmpmask_q;
      wire [0:6]                                       lrat_entry7_xbitmask_d;
      wire [0:6]                                       lrat_entry7_xbitmask_q;
      wire                                             lrat_entry7_xbit_d;
      wire                                             lrat_entry7_xbit_q;
      wire                                             lrat_entry7_valid_d;
      wire                                             lrat_entry7_valid_q;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_datain_lpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_datain_lpn_q;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_datain_rpn_d;
      wire [64-`REAL_ADDR_WIDTH:64-`LRAT_MINSIZE_LOG2-1] lrat_datain_rpn_q;
      wire [0:`LPID_WIDTH-1]                            lrat_datain_lpid_d;
      wire [0:`LPID_WIDTH-1]                            lrat_datain_lpid_q;
      wire [0:3]                                       lrat_datain_size_d;
      wire [0:3]                                       lrat_datain_size_q;
      wire                                             lrat_datain_xbit_d;
      wire                                             lrat_datain_xbit_q;
      wire                                             lrat_datain_valid_d;
      wire                                             lrat_datain_valid_q;
      wire                                             lrat_mas1_v_d;
      wire                                             lrat_mas1_v_q;
      wire [0:3]                                       lrat_mas1_tsize_d;
      wire [0:3]                                       lrat_mas1_tsize_q;
      wire [64-`REAL_ADDR_WIDTH:51]                     lrat_mas2_epn_d;
      wire [64-`REAL_ADDR_WIDTH:51]                     lrat_mas2_epn_q;
      wire [32:51]                                     lrat_mas3_rpnl_d;
      wire [32:51]                                     lrat_mas3_rpnl_q;
      wire [22:31]                                     lrat_mas7_rpnu_d;
      wire [22:31]                                     lrat_mas7_rpnu_q;
      wire [0:`LPID_WIDTH-1]                            lrat_mas8_tlpid_d;
      wire [0:`LPID_WIDTH-1]                            lrat_mas8_tlpid_q;
      wire                                             lrat_mas_tlbre_d;
      wire                                             lrat_mas_tlbre_q;
      wire                                             lrat_mas_tlbsx_hit_d;
      wire                                             lrat_mas_tlbsx_hit_q;
      wire                                             lrat_mas_tlbsx_miss_d;
      wire                                             lrat_mas_tlbsx_miss_q;
      wire [0:`MM_THREADS-1]                           lrat_mas_thdid_d;
      wire [0:`MM_THREADS-1]                           lrat_mas_thdid_q;
      wire                                             lrat_mmucr3_x_d;
      wire                                             lrat_mmucr3_x_q;
      wire [0:7]                                       lrat_entry_act_d;
      wire [0:7]                                       lrat_entry_act_q;
      wire [0:2]                                       lrat_mas_act_d;
      wire [0:2]                                       lrat_mas_act_q;
      wire [0:1]                                       lrat_datain_act_d;
      wire [0:1]                                       lrat_datain_act_q;
      wire [0:63]                                      spare_q;
      // Logic signals
      wire                                             multihit;
      wire                                             addr_enable;
      wire                                             lpid_enable;
      wire                                             lrat_supp_pgsize;
      wire                                             lrat_tag2_size_gt_entry_size;
      wire [0:`LRAT_NUM_ENTRY-1]                        lrat_tag1_matchline;
      wire                                             lrat_entry0_addr_match;
      wire                                             lrat_entry0_lpid_match;
      wire                                             lrat_entry1_addr_match;
      wire                                             lrat_entry1_lpid_match;
      wire                                             lrat_entry2_addr_match;
      wire                                             lrat_entry2_lpid_match;
      wire                                             lrat_entry3_addr_match;
      wire                                             lrat_entry3_lpid_match;
      wire                                             lrat_entry4_addr_match;
      wire                                             lrat_entry4_lpid_match;
      wire                                             lrat_entry5_addr_match;
      wire                                             lrat_entry5_lpid_match;
      wire                                             lrat_entry6_addr_match;
      wire                                             lrat_entry6_lpid_match;
      wire                                             lrat_entry7_addr_match;
      wire                                             lrat_entry7_lpid_match;

      wire                                             lrat_datain_size_gte_1TB;
      wire                                             lrat_datain_size_gte_256GB;
      wire                                             lrat_datain_size_gte_16GB;
      wire                                             lrat_datain_size_gte_4GB;
      wire                                             lrat_datain_size_gte_1GB;
      wire                                             lrat_datain_size_gte_256MB;
      wire                                             lrat_datain_size_gte_16MB;

      (* analysis_not_referenced="true" *)
      wire [0:13]                                      unused_dc;
      (* analysis_not_referenced="true" *)
      wire [`MM_THREADS:3]                             unused_dc_threads;


      // Pervasive
      wire                                             pc_sg_1;
      wire                                             pc_sg_0;
      wire                                             pc_func_sl_thold_1;
      wire                                             pc_func_sl_thold_0;
      wire                                             pc_func_sl_thold_0_b;
      wire                                             pc_func_slp_sl_thold_1;
      wire                                             pc_func_slp_sl_thold_0;
      wire                                             pc_func_slp_sl_thold_0_b;
      wire                                             pc_func_sl_force;
      wire                                             pc_func_slp_sl_force;
      wire [0:scan_right]                              siv;
      wire [0:scan_right]                              sov;

      wire                                             tiup;

      //@@ START OF EXECUTABLE CODE FOR MMQ_TLB_LRAT
      //begin
      //!! Bugspray Include: mmq_tlb_lrat;

      //---------------------------------------------------------------------
      // Logic
      //---------------------------------------------------------------------
      assign tiup = 1'b1;

      // tag0 phase signals, tlbwe/re ex2, tlbsx/srx ex3
      assign tlb_addr_cap_d[1] = tlb_tag0_addr_cap & ((tlb_tag0_type[lrat_tagpos_type_tlbsx] & tlb_tag0_atsel) | tlb_tag0_type[lrat_tagpos_type_ptereload] | tlb_tag0_type[lrat_tagpos_type_tlbwe]);
      assign lrat_tag1_size_d = (tlb_tag0_addr_cap == 1'b1) ? tlb_tag0_size :
                                lrat_tag1_size_q;
      generate
         if (`REAL_ADDR_WIDTH < 33)
         begin : gen32_lrat_tag1_lpn
            assign lrat_tag1_lpn_d = ((tlb_tag0_addr_cap == 1'b1 & tlb_tag0_type[lrat_tagpos_type_tlbsx] == 1'b1)) ? tlb_tag0_epn[64 - `REAL_ADDR_WIDTH:51] :
                                     ((tlb_tag0_addr_cap == 1'b1 & tlb_tag0_type[lrat_tagpos_type_ptereload] == 1'b1)) ? pte_tag0_lpn[64 - `REAL_ADDR_WIDTH:51] :
                                     ((tlb_tag0_addr_cap == 1'b1 & tlb_tag0_thdid[0] == 1'b1 & tlb_tag0_type[lrat_tagpos_type_tlbwe] == 1'b1)) ? mas3_0_rpnl :
`ifdef MM_THREADS2
                                     ((tlb_tag0_addr_cap == 1'b1 & tlb_tag0_thdid[1] == 1'b1 & tlb_tag0_type[lrat_tagpos_type_tlbwe] == 1'b1)) ? mas3_1_rpnl :
`endif
                                     lrat_tag1_lpn_q;
         end
      endgenerate
      generate
         if (`REAL_ADDR_WIDTH > 32)
         begin : gen64_lrat_tag1_lpn
            assign lrat_tag1_lpn_d = ((tlb_tag0_addr_cap == 1'b1 & tlb_tag0_type[lrat_tagpos_type_tlbsx] == 1'b1)) ? tlb_tag0_epn[64 - `REAL_ADDR_WIDTH:51] :
                                     ((tlb_tag0_addr_cap == 1'b1 & tlb_tag0_type[lrat_tagpos_type_ptereload] == 1'b1)) ? pte_tag0_lpn[64 - `REAL_ADDR_WIDTH:51] :
                                     ((tlb_tag0_addr_cap == 1'b1 & tlb_tag0_thdid[0] == 1'b1 & tlb_tag0_type[lrat_tagpos_type_tlbwe] == 1'b1)) ? {mas7_0_rpnu[64 - `REAL_ADDR_WIDTH:31], mas3_0_rpnl} :
`ifdef MM_THREADS2
                                     ((tlb_tag0_addr_cap == 1'b1 & tlb_tag0_thdid[1] == 1'b1 & tlb_tag0_type[lrat_tagpos_type_tlbwe] == 1'b1)) ? {mas7_1_rpnu[64 - `REAL_ADDR_WIDTH:31], mas3_1_rpnl} :
`endif
                                     lrat_tag1_lpn_q;
         end
      endgenerate
      assign lrat_tag1_lpid_d = ((tlb_tag0_addr_cap == 1'b1 & tlb_tag0_type[lrat_tagpos_type_tlbsx] == 1'b1)) ? tlb_tag0_lpid :
                                ((tlb_tag0_addr_cap == 1'b1 & tlb_tag0_type[lrat_tagpos_type_ptereload] == 1'b1)) ? pte_tag0_lpid :
                                ((tlb_tag0_addr_cap == 1'b1 & tlb_tag0_thdid[0] == 1'b1 & tlb_tag0_type[lrat_tagpos_type_tlbwe] == 1'b1)) ? mas8_0_tlpid :
`ifdef MM_THREADS2
                                ((tlb_tag0_addr_cap == 1'b1 & tlb_tag0_thdid[1] == 1'b1 & tlb_tag0_type[lrat_tagpos_type_tlbwe] == 1'b1)) ? mas8_1_tlpid :
`endif
                                lrat_tag1_lpid_q;
      // tag1 phase signals, tlbwe/re ex3, tlbsx/srx ex4
      assign ex4_valid_d = tlb_ctl_ex3_valid & (~(xu_ex3_flush));
      assign ex4_ttype_d = tlb_ctl_ex3_ttype;
      assign ex4_hv_state_d = tlb_ctl_ex3_hv_state;
      assign addr_enable = tlb_addr_cap_q[1];
      assign lpid_enable = tlb_addr_cap_q[1];
      assign tlb_addr_cap_d[2] = tlb_addr_cap_q[1];
      assign lrat_tag2_lpn_d = lrat_tag1_lpn_q;
      assign lrat_tag2_matchline_d = lrat_tag1_matchline;
      assign lrat_tag2_size_d = lrat_tag1_size_q;
      assign lrat_tag2_entry_size_d = (lrat_entry0_size_q & {4{lrat_tag1_matchline[0]}}) |
                                        (lrat_entry1_size_q & {4{lrat_tag1_matchline[1]}}) |
                                        (lrat_entry2_size_q & {4{lrat_tag1_matchline[2]}}) |
                                        (lrat_entry3_size_q & {4{lrat_tag1_matchline[3]}}) |
                                        (lrat_entry4_size_q & {4{lrat_tag1_matchline[4]}}) |
                                        (lrat_entry5_size_q & {4{lrat_tag1_matchline[5]}}) |
                                        (lrat_entry6_size_q & {4{lrat_tag1_matchline[6]}}) |
                                        (lrat_entry7_size_q & {4{lrat_tag1_matchline[7]}});
      // tag2 phase signals, tlbwe/re ex4, tlbsx/srx ex5
      assign ex5_valid_d = ex4_valid_q & (~(xu_ex4_flush));
      assign ex5_ttype_d = ex4_ttype_q;
`ifdef MM_THREADS2
      assign ex5_esel_d = (mas0_0_esel & {`LRAT_NUM_ENTRY_LOG2{ex4_valid_q[0]}}) | (mas0_1_esel & {`LRAT_NUM_ENTRY_LOG2{ex4_valid_q[1]}});
      assign ex5_atsel_d = (mas0_0_atsel & ex4_valid_q[0]) | (mas0_1_atsel & ex4_valid_q[1]);
      assign ex5_hes_d = (mas0_0_hes & ex4_valid_q[0]) | (mas0_1_hes & ex4_valid_q[1]);
      assign ex5_wq_d = (mas0_0_wq & {2{ex4_valid_q[0]}}) | (mas0_1_wq & {2{ex4_valid_q[1]}});
`else
      assign ex5_esel_d = (mas0_0_esel & {`LRAT_NUM_ENTRY_LOG2{ex4_valid_q[0]}});
      assign ex5_atsel_d = (mas0_0_atsel & ex4_valid_q[0]);
      assign ex5_hes_d = (mas0_0_hes & ex4_valid_q[0]);
      assign ex5_wq_d = (mas0_0_wq & {2{ex4_valid_q[0]}});
`endif
      assign ex5_hv_state_d = ex4_hv_state_q;
      assign lrat_tag3_lpn_d = lrat_tag2_lpn_q;
      // hit_status: val,hit,multihit,inval_pgsize
      assign lrat_tag3_hit_status_d[0] = tlb_addr_cap_q[2];
      assign lrat_tag3_hit_status_d[1] = tlb_addr_cap_q[2] & |(lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1]);
      assign lrat_tag3_hit_status_d[2] = tlb_addr_cap_q[2] & multihit;
      assign lrat_tag3_hit_status_d[3] = tlb_addr_cap_q[2] & ((~(lrat_supp_pgsize)) | lrat_tag2_size_gt_entry_size);
      assign multihit = ((lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b00000000 | lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b10000000 | lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b01000000 | lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b00100000 | lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b00010000 | lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b00001000 | lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b00000100 | lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b00000010 | lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b00000001)) ? 1'b0 :
                        1'b1;
      assign lrat_tag3_hit_entry_d = (lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b01000000) ? 3'b001 :
                                     (lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b00100000) ? 3'b010 :
                                     (lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b00010000) ? 3'b011 :
                                     (lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b00001000) ? 3'b100 :
                                     (lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b00000100) ? 3'b101 :
                                     (lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b00000010) ? 3'b110 :
                                     (lrat_tag2_matchline_q[0:`LRAT_NUM_ENTRY - 1] == 8'b00000001) ? 3'b111 :
                                     3'b000;
      //     constant TLB_PgSize_1GB   : std_ulogic_vector(0 to 3) :=  1010 ;
      //     constant TLB_PgSize_256MB : std_ulogic_vector(0 to 3) :=  1001 ;
      //     constant TLB_PgSize_16MB  : std_ulogic_vector(0 to 3) :=  0111 ;
      //     constant TLB_PgSize_1MB   : std_ulogic_vector(0 to 3) :=  0101 ;
      //     constant TLB_PgSize_64KB  : std_ulogic_vector(0 to 3) :=  0011 ;
      //     constant TLB_PgSize_4KB   : std_ulogic_vector(0 to 3) :=  0001 ;
      // ISA 2.06 pgsize match criteria for tlbwe:
      //   MAS1.IND=0 and MAS1.TSIZE </= LRAT_entry.LSIZE, or
      //   MAS1.IND=1 and (3 + (MAS1.TSIZE - MAS3.SPSIZE)) </= (10 + LRAT_entry.LSIZE)
      //    the second term above can never happen for A2, 3+9-3 or 3+5-1 is never > 10+5
      //      ..in other words, the biggest page table for A2 is 256M/64K=4K entries x 8 bytes = 32K,
      //      .. 32K is always less than the minimum supported LRAT size of 1MB.
      // pgsize match criteria for ptereload:
      //   PTE.PS </= LRAT_entry.LSIZE
      assign lrat_tag2_size_gt_entry_size = ((lrat_tag2_size_q == TLB_PgSize_16MB) & (lrat_tag2_entry_size_q == LRAT_PgSize_1MB))  |
                                              ((lrat_tag2_size_q == TLB_PgSize_1GB)  & (lrat_tag2_entry_size_q == LRAT_PgSize_1MB))  |
                                              ((lrat_tag2_size_q == TLB_PgSize_1GB)  & (lrat_tag2_entry_size_q == LRAT_PgSize_16MB)) |
                                              ((lrat_tag2_size_q == TLB_PgSize_1GB)  & (lrat_tag2_entry_size_q == LRAT_PgSize_256MB));
      assign lrat_supp_pgsize = ((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB | lrat_tag2_entry_size_q == LRAT_PgSize_256GB | lrat_tag2_entry_size_q == LRAT_PgSize_1TB)) ? 1'b1 :
                                1'b0;
      //constant LRAT_PgSize_1TB_log2   : integer := 40;
      //constant LRAT_PgSize_256GB_log2 : integer := 38;
      //constant LRAT_PgSize_16GB_log2  : integer := 34;
      //constant LRAT_PgSize_4GB_log2   : integer := 32;
      //constant LRAT_PgSize_1GB_log2   : integer := 30;
      //constant LRAT_PgSize_256MB_log2 : integer := 28;
      //constant LRAT_PgSize_16MB_log2  : integer := 24;
      //constant LRAT_PgSize_1MB_log2   : integer := 20;
      // offset forwarding muxes based on page size
      // rpn(44:51)
      assign lrat_tag3_rpn_d[64 - LRAT_PgSize_1MB_log2:51] = lrat_tag2_lpn_q[64 - LRAT_PgSize_1MB_log2:51];
      // rpn(40:43)
      assign lrat_tag3_rpn_d[64 - LRAT_PgSize_16MB_log2:64 - LRAT_PgSize_1MB_log2 - 1] = ((lrat_tag2_entry_size_q == LRAT_PgSize_1MB & lrat_tag2_matchline_q[0] == 1'b1)) ? lrat_entry0_rpn_q[64 - LRAT_PgSize_16MB_log2:64 - LRAT_PgSize_1MB_log2 - 1] :
                                                                                         ((lrat_tag2_entry_size_q == LRAT_PgSize_1MB & lrat_tag2_matchline_q[1] == 1'b1)) ? lrat_entry1_rpn_q[64 - LRAT_PgSize_16MB_log2:64 - LRAT_PgSize_1MB_log2 - 1] :
                                                                                         ((lrat_tag2_entry_size_q == LRAT_PgSize_1MB & lrat_tag2_matchline_q[2] == 1'b1)) ? lrat_entry2_rpn_q[64 - LRAT_PgSize_16MB_log2:64 - LRAT_PgSize_1MB_log2 - 1] :
                                                                                         ((lrat_tag2_entry_size_q == LRAT_PgSize_1MB & lrat_tag2_matchline_q[3] == 1'b1)) ? lrat_entry3_rpn_q[64 - LRAT_PgSize_16MB_log2:64 - LRAT_PgSize_1MB_log2 - 1] :
                                                                                         ((lrat_tag2_entry_size_q == LRAT_PgSize_1MB & lrat_tag2_matchline_q[4] == 1'b1)) ? lrat_entry4_rpn_q[64 - LRAT_PgSize_16MB_log2:64 - LRAT_PgSize_1MB_log2 - 1] :
                                                                                         ((lrat_tag2_entry_size_q == LRAT_PgSize_1MB & lrat_tag2_matchline_q[5] == 1'b1)) ? lrat_entry5_rpn_q[64 - LRAT_PgSize_16MB_log2:64 - LRAT_PgSize_1MB_log2 - 1] :
                                                                                         ((lrat_tag2_entry_size_q == LRAT_PgSize_1MB & lrat_tag2_matchline_q[6] == 1'b1)) ? lrat_entry6_rpn_q[64 - LRAT_PgSize_16MB_log2:64 - LRAT_PgSize_1MB_log2 - 1] :
                                                                                         ((lrat_tag2_entry_size_q == LRAT_PgSize_1MB & lrat_tag2_matchline_q[7] == 1'b1)) ? lrat_entry7_rpn_q[64 - LRAT_PgSize_16MB_log2:64 - LRAT_PgSize_1MB_log2 - 1] :
                                                                                         lrat_tag2_lpn_q[64 - LRAT_PgSize_16MB_log2:64 - LRAT_PgSize_1MB_log2 - 1];
      // rpn(36:39)
      assign lrat_tag3_rpn_d[64 - LRAT_PgSize_256MB_log2:64 - LRAT_PgSize_16MB_log2 - 1] = (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB) & lrat_tag2_matchline_q[0] == 1'b1)) ? lrat_entry0_rpn_q[64 - LRAT_PgSize_256MB_log2:64 - LRAT_PgSize_16MB_log2 - 1] :
                                                                                           (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB) & lrat_tag2_matchline_q[1] == 1'b1)) ? lrat_entry1_rpn_q[64 - LRAT_PgSize_256MB_log2:64 - LRAT_PgSize_16MB_log2 - 1] :
                                                                                           (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB) & lrat_tag2_matchline_q[2] == 1'b1)) ? lrat_entry2_rpn_q[64 - LRAT_PgSize_256MB_log2:64 - LRAT_PgSize_16MB_log2 - 1] :
                                                                                           (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB) & lrat_tag2_matchline_q[3] == 1'b1)) ? lrat_entry3_rpn_q[64 - LRAT_PgSize_256MB_log2:64 - LRAT_PgSize_16MB_log2 - 1] :
                                                                                           (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB) & lrat_tag2_matchline_q[4] == 1'b1)) ? lrat_entry4_rpn_q[64 - LRAT_PgSize_256MB_log2:64 - LRAT_PgSize_16MB_log2 - 1] :
                                                                                           (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB) & lrat_tag2_matchline_q[5] == 1'b1)) ? lrat_entry5_rpn_q[64 - LRAT_PgSize_256MB_log2:64 - LRAT_PgSize_16MB_log2 - 1] :
                                                                                           (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB) & lrat_tag2_matchline_q[6] == 1'b1)) ? lrat_entry6_rpn_q[64 - LRAT_PgSize_256MB_log2:64 - LRAT_PgSize_16MB_log2 - 1] :
                                                                                           (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB) & lrat_tag2_matchline_q[7] == 1'b1)) ? lrat_entry7_rpn_q[64 - LRAT_PgSize_256MB_log2:64 - LRAT_PgSize_16MB_log2 - 1] :
                                                                                           lrat_tag2_lpn_q[64 - LRAT_PgSize_256MB_log2:64 - LRAT_PgSize_16MB_log2 - 1];
      // rpn(34:35)
      assign lrat_tag3_rpn_d[64 - LRAT_PgSize_1GB_log2:64 - LRAT_PgSize_256MB_log2 - 1] = (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB) & lrat_tag2_matchline_q[0] == 1'b1)) ? lrat_entry0_rpn_q[64 - LRAT_PgSize_1GB_log2:64 - LRAT_PgSize_256MB_log2 - 1] :
                                                                                          (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB) & lrat_tag2_matchline_q[1] == 1'b1)) ? lrat_entry1_rpn_q[64 - LRAT_PgSize_1GB_log2:64 - LRAT_PgSize_256MB_log2 - 1] :
                                                                                          (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB) & lrat_tag2_matchline_q[2] == 1'b1)) ? lrat_entry2_rpn_q[64 - LRAT_PgSize_1GB_log2:64 - LRAT_PgSize_256MB_log2 - 1] :
                                                                                          (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB) & lrat_tag2_matchline_q[3] == 1'b1)) ? lrat_entry3_rpn_q[64 - LRAT_PgSize_1GB_log2:64 - LRAT_PgSize_256MB_log2 - 1] :
                                                                                          (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB) & lrat_tag2_matchline_q[4] == 1'b1)) ? lrat_entry4_rpn_q[64 - LRAT_PgSize_1GB_log2:64 - LRAT_PgSize_256MB_log2 - 1] :
                                                                                          (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB) & lrat_tag2_matchline_q[5] == 1'b1)) ? lrat_entry5_rpn_q[64 - LRAT_PgSize_1GB_log2:64 - LRAT_PgSize_256MB_log2 - 1] :
                                                                                          (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB) & lrat_tag2_matchline_q[6] == 1'b1)) ? lrat_entry6_rpn_q[64 - LRAT_PgSize_1GB_log2:64 - LRAT_PgSize_256MB_log2 - 1] :
                                                                                          (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB) & lrat_tag2_matchline_q[7] == 1'b1)) ? lrat_entry7_rpn_q[64 - LRAT_PgSize_1GB_log2:64 - LRAT_PgSize_256MB_log2 - 1] :
                                                                                          lrat_tag2_lpn_q[64 - LRAT_PgSize_1GB_log2:64 - LRAT_PgSize_256MB_log2 - 1];
      // rpn(32:33)
      assign lrat_tag3_rpn_d[64 - LRAT_PgSize_4GB_log2:64 - LRAT_PgSize_1GB_log2 - 1] = (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB) & lrat_tag2_matchline_q[0] == 1'b1)) ? lrat_entry0_rpn_q[64 - LRAT_PgSize_4GB_log2:64 - LRAT_PgSize_1GB_log2 - 1] :
                                                                                        (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB) & lrat_tag2_matchline_q[1] == 1'b1)) ? lrat_entry1_rpn_q[64 - LRAT_PgSize_4GB_log2:64 - LRAT_PgSize_1GB_log2 - 1] :
                                                                                        (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB) & lrat_tag2_matchline_q[2] == 1'b1)) ? lrat_entry2_rpn_q[64 - LRAT_PgSize_4GB_log2:64 - LRAT_PgSize_1GB_log2 - 1] :
                                                                                        (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB) & lrat_tag2_matchline_q[3] == 1'b1)) ? lrat_entry3_rpn_q[64 - LRAT_PgSize_4GB_log2:64 - LRAT_PgSize_1GB_log2 - 1] :
                                                                                        (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB) & lrat_tag2_matchline_q[4] == 1'b1)) ? lrat_entry4_rpn_q[64 - LRAT_PgSize_4GB_log2:64 - LRAT_PgSize_1GB_log2 - 1] :
                                                                                        (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB) & lrat_tag2_matchline_q[5] == 1'b1)) ? lrat_entry5_rpn_q[64 - LRAT_PgSize_4GB_log2:64 - LRAT_PgSize_1GB_log2 - 1] :
                                                                                        (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB) & lrat_tag2_matchline_q[6] == 1'b1)) ? lrat_entry6_rpn_q[64 - LRAT_PgSize_4GB_log2:64 - LRAT_PgSize_1GB_log2 - 1] :
                                                                                        (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB) & lrat_tag2_matchline_q[7] == 1'b1)) ? lrat_entry7_rpn_q[64 - LRAT_PgSize_4GB_log2:64 - LRAT_PgSize_1GB_log2 - 1] :
                                                                                        lrat_tag2_lpn_q[64 - LRAT_PgSize_4GB_log2:64 - LRAT_PgSize_1GB_log2 - 1];
      // rpn(30:31)
      generate
         if (`REAL_ADDR_WIDTH > 33)
         begin : gen64_lrat_tag3_rpn_34
            assign lrat_tag3_rpn_d[64 - LRAT_PgSize_16GB_log2:64 - LRAT_PgSize_4GB_log2 - 1] = (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB) & lrat_tag2_matchline_q[0] == 1'b1)) ? lrat_entry0_rpn_q[64 - LRAT_PgSize_16GB_log2:64 - LRAT_PgSize_4GB_log2 - 1] :
                                                                                               (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB) & lrat_tag2_matchline_q[1] == 1'b1)) ? lrat_entry1_rpn_q[64 - LRAT_PgSize_16GB_log2:64 - LRAT_PgSize_4GB_log2 - 1] :
                                                                                               (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB) & lrat_tag2_matchline_q[2] == 1'b1)) ? lrat_entry2_rpn_q[64 - LRAT_PgSize_16GB_log2:64 - LRAT_PgSize_4GB_log2 - 1] :
                                                                                               (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB) & lrat_tag2_matchline_q[3] == 1'b1)) ? lrat_entry3_rpn_q[64 - LRAT_PgSize_16GB_log2:64 - LRAT_PgSize_4GB_log2 - 1] :
                                                                                               (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB) & lrat_tag2_matchline_q[4] == 1'b1)) ? lrat_entry4_rpn_q[64 - LRAT_PgSize_16GB_log2:64 - LRAT_PgSize_4GB_log2 - 1] :
                                                                                               (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB) & lrat_tag2_matchline_q[5] == 1'b1)) ? lrat_entry5_rpn_q[64 - LRAT_PgSize_16GB_log2:64 - LRAT_PgSize_4GB_log2 - 1] :
                                                                                               (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB) & lrat_tag2_matchline_q[6] == 1'b1)) ? lrat_entry6_rpn_q[64 - LRAT_PgSize_16GB_log2:64 - LRAT_PgSize_4GB_log2 - 1] :
                                                                                               (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB) & lrat_tag2_matchline_q[7] == 1'b1)) ? lrat_entry7_rpn_q[64 - LRAT_PgSize_16GB_log2:64 - LRAT_PgSize_4GB_log2 - 1] :
                                                                                               lrat_tag2_lpn_q[64 - LRAT_PgSize_16GB_log2:64 - LRAT_PgSize_4GB_log2 - 1];
         end
      endgenerate
      // rpn(26:29)
      generate
         if (`REAL_ADDR_WIDTH > 37)
         begin : gen64_lrat_tag3_rpn_38
            assign lrat_tag3_rpn_d[64 - LRAT_PgSize_256GB_log2:64 - LRAT_PgSize_16GB_log2 - 1] = (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB) & lrat_tag2_matchline_q[0] == 1'b1)) ? lrat_entry0_rpn_q[64 - LRAT_PgSize_256GB_log2:64 - LRAT_PgSize_16GB_log2 - 1] :
                                                                                                 (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB) & lrat_tag2_matchline_q[1] == 1'b1)) ? lrat_entry1_rpn_q[64 - LRAT_PgSize_256GB_log2:64 - LRAT_PgSize_16GB_log2 - 1] :
                                                                                                 (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB) & lrat_tag2_matchline_q[2] == 1'b1)) ? lrat_entry2_rpn_q[64 - LRAT_PgSize_256GB_log2:64 - LRAT_PgSize_16GB_log2 - 1] :
                                                                                                 (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB) & lrat_tag2_matchline_q[3] == 1'b1)) ? lrat_entry3_rpn_q[64 - LRAT_PgSize_256GB_log2:64 - LRAT_PgSize_16GB_log2 - 1] :
                                                                                                 (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB) & lrat_tag2_matchline_q[4] == 1'b1)) ? lrat_entry4_rpn_q[64 - LRAT_PgSize_256GB_log2:64 - LRAT_PgSize_16GB_log2 - 1] :
                                                                                                 (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB) & lrat_tag2_matchline_q[5] == 1'b1)) ? lrat_entry5_rpn_q[64 - LRAT_PgSize_256GB_log2:64 - LRAT_PgSize_16GB_log2 - 1] :
                                                                                                 (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB) & lrat_tag2_matchline_q[6] == 1'b1)) ? lrat_entry6_rpn_q[64 - LRAT_PgSize_256GB_log2:64 - LRAT_PgSize_16GB_log2 - 1] :
                                                                                                 (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB) & lrat_tag2_matchline_q[7] == 1'b1)) ? lrat_entry7_rpn_q[64 - LRAT_PgSize_256GB_log2:64 - LRAT_PgSize_16GB_log2 - 1] :
                                                                                                 lrat_tag2_lpn_q[64 - LRAT_PgSize_256GB_log2:64 - LRAT_PgSize_16GB_log2 - 1];
         end
      endgenerate
      // rpn(24:25)
      generate
         if (`REAL_ADDR_WIDTH > 39)
         begin : gen64_lrat_tag3_rpn_40
            assign lrat_tag3_rpn_d[64 - LRAT_PgSize_1TB_log2:64 - LRAT_PgSize_256GB_log2 - 1] = (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB | lrat_tag2_entry_size_q == LRAT_PgSize_256GB) & lrat_tag2_matchline_q[0] == 1'b1)) ? lrat_entry0_rpn_q[64 - LRAT_PgSize_1TB_log2:64 - LRAT_PgSize_256GB_log2 - 1] :
                                                                                                (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB | lrat_tag2_entry_size_q == LRAT_PgSize_256GB) & lrat_tag2_matchline_q[1] == 1'b1)) ? lrat_entry1_rpn_q[64 - LRAT_PgSize_1TB_log2:64 - LRAT_PgSize_256GB_log2 - 1] :
                                                                                                (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB | lrat_tag2_entry_size_q == LRAT_PgSize_256GB) & lrat_tag2_matchline_q[2] == 1'b1)) ? lrat_entry2_rpn_q[64 - LRAT_PgSize_1TB_log2:64 - LRAT_PgSize_256GB_log2 - 1] :
                                                                                                (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB | lrat_tag2_entry_size_q == LRAT_PgSize_256GB) & lrat_tag2_matchline_q[3] == 1'b1)) ? lrat_entry3_rpn_q[64 - LRAT_PgSize_1TB_log2:64 - LRAT_PgSize_256GB_log2 - 1] :
                                                                                                (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB | lrat_tag2_entry_size_q == LRAT_PgSize_256GB) & lrat_tag2_matchline_q[4] == 1'b1)) ? lrat_entry4_rpn_q[64 - LRAT_PgSize_1TB_log2:64 - LRAT_PgSize_256GB_log2 - 1] :
                                                                                                (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB | lrat_tag2_entry_size_q == LRAT_PgSize_256GB) & lrat_tag2_matchline_q[5] == 1'b1)) ? lrat_entry5_rpn_q[64 - LRAT_PgSize_1TB_log2:64 - LRAT_PgSize_256GB_log2 - 1] :
                                                                                                (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB | lrat_tag2_entry_size_q == LRAT_PgSize_256GB) & lrat_tag2_matchline_q[6] == 1'b1)) ? lrat_entry6_rpn_q[64 - LRAT_PgSize_1TB_log2:64 - LRAT_PgSize_256GB_log2 - 1] :
                                                                                                (((lrat_tag2_entry_size_q == LRAT_PgSize_1MB | lrat_tag2_entry_size_q == LRAT_PgSize_16MB | lrat_tag2_entry_size_q == LRAT_PgSize_256MB | lrat_tag2_entry_size_q == LRAT_PgSize_1GB | lrat_tag2_entry_size_q == LRAT_PgSize_4GB | lrat_tag2_entry_size_q == LRAT_PgSize_16GB | lrat_tag2_entry_size_q == LRAT_PgSize_256GB) & lrat_tag2_matchline_q[7] == 1'b1)) ? lrat_entry7_rpn_q[64 - LRAT_PgSize_1TB_log2:64 - LRAT_PgSize_256GB_log2 - 1] :
                                                                                                lrat_tag2_lpn_q[64 - LRAT_PgSize_1TB_log2:64 - LRAT_PgSize_256GB_log2 - 1];
         end
      endgenerate
      // rpn(22:23)
      generate
         if (`REAL_ADDR_WIDTH > 41)
         begin : gen64_lrat_tag3_rpn_42
            assign lrat_tag3_rpn_d[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MAXSIZE_LOG2 - 1] = (lrat_tag2_matchline_q[0] == 1'b1) ? lrat_entry0_rpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MAXSIZE_LOG2 - 1] :
                                                                                      (lrat_tag2_matchline_q[1] == 1'b1) ? lrat_entry1_rpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MAXSIZE_LOG2 - 1] :
                                                                                      (lrat_tag2_matchline_q[2] == 1'b1) ? lrat_entry2_rpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MAXSIZE_LOG2 - 1] :
                                                                                      (lrat_tag2_matchline_q[3] == 1'b1) ? lrat_entry3_rpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MAXSIZE_LOG2 - 1] :
                                                                                      (lrat_tag2_matchline_q[4] == 1'b1) ? lrat_entry4_rpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MAXSIZE_LOG2 - 1] :
                                                                                      (lrat_tag2_matchline_q[5] == 1'b1) ? lrat_entry5_rpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MAXSIZE_LOG2 - 1] :
                                                                                      (lrat_tag2_matchline_q[6] == 1'b1) ? lrat_entry6_rpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MAXSIZE_LOG2 - 1] :
                                                                                      (lrat_tag2_matchline_q[7] == 1'b1) ? lrat_entry7_rpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MAXSIZE_LOG2 - 1] :
                                                                                      lrat_tag2_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MAXSIZE_LOG2 - 1];
         end
      endgenerate
      //constant LRAT_PgSize_1TB_log2   : integer := 40;
      //constant LRAT_PgSize_256GB_log2 : integer := 38;
      //constant LRAT_PgSize_16GB_log2  : integer := 34;
      //constant LRAT_PgSize_4GB_log2   : integer := 32;
      //constant LRAT_PgSize_1GB_log2   : integer := 30;
      //constant LRAT_PgSize_256MB_log2 : integer := 28;
      //constant LRAT_PgSize_16MB_log2  : integer := 24;
      //constant LRAT_PgSize_1MB_log2   : integer := 20;
      // tag3 phase signals, tlbwe/re ex4, tlbsx/srx ex5
      assign ex6_valid_d = ex5_valid_q & (~(xu_ex5_flush));
      assign ex6_ttype_d = ex5_ttype_q;
      assign ex6_esel_d = ex5_esel_q;
      assign ex6_atsel_d = ex5_atsel_q;
      assign ex6_hes_d = ex5_hes_q;
      assign ex6_wq_d = ex5_wq_q;
      assign ex6_hv_state_d = ex5_hv_state_q;
      assign lrat_tag4_lpn_d = lrat_tag3_lpn_q;
      assign lrat_tag4_rpn_d = lrat_tag3_rpn_q;
      assign lrat_tag4_hit_status_d = lrat_tag3_hit_status_q;
      assign lrat_tag4_hit_entry_d = lrat_tag3_hit_entry_q;
`ifdef MM_THREADS2
      assign lrat_datain_lpn_d = ((ex5_valid_q[0] == 1'b1)) ? mas2_0_epn[64 - `REAL_ADDR_WIDTH:63 - `LRAT_MINSIZE_LOG2] :
                                 ((ex5_valid_q[1] == 1'b1)) ? mas2_1_epn[64 - `REAL_ADDR_WIDTH:63 - `LRAT_MINSIZE_LOG2] :
                                 lrat_datain_lpn_q;
`else
      assign lrat_datain_lpn_d = ((ex5_valid_q[0] == 1'b1)) ? mas2_0_epn[64 - `REAL_ADDR_WIDTH:63 - `LRAT_MINSIZE_LOG2] :
                                 lrat_datain_lpn_q;
`endif

      generate
         if (`REAL_ADDR_WIDTH > 32)
         begin : gen64_lrat_datain_rpn
`ifdef MM_THREADS2
            assign lrat_datain_rpn_d[64 - `REAL_ADDR_WIDTH:31] = ((ex5_valid_q[0] == 1'b1)) ? mas7_0_rpnu[64 - `REAL_ADDR_WIDTH:31] :
                                                                   ((ex5_valid_q[1] == 1'b1)) ? mas7_1_rpnu[64 - `REAL_ADDR_WIDTH:31] :
                                                                lrat_datain_rpn_q[64 - `REAL_ADDR_WIDTH:31];
`else
            assign lrat_datain_rpn_d[64 - `REAL_ADDR_WIDTH:31] = ((ex5_valid_q[0] == 1'b1)) ? mas7_0_rpnu[64 - `REAL_ADDR_WIDTH:31] :
                                                                lrat_datain_rpn_q[64 - `REAL_ADDR_WIDTH:31];
`endif
         end
      endgenerate

`ifdef MM_THREADS2
      assign lrat_datain_rpn_d[32:63 - `LRAT_MINSIZE_LOG2] = ((ex5_valid_q[0] == 1'b1)) ? mas3_0_rpnl[32:63 - `LRAT_MINSIZE_LOG2] :
                                                            ((ex5_valid_q[1] == 1'b1)) ? mas3_1_rpnl[32:63 - `LRAT_MINSIZE_LOG2] :
                                                            lrat_datain_rpn_q[32:63 - `LRAT_MINSIZE_LOG2];
      assign lrat_datain_lpid_d = ((ex5_valid_q[0] == 1'b1)) ? mas8_0_tlpid :
                                  ((ex5_valid_q[1] == 1'b1)) ? mas8_1_tlpid :
                                  lrat_datain_lpid_q;
      assign lrat_datain_size_d = ((ex5_valid_q[0] == 1'b1)) ? mas1_0_tsize :
                                  ((ex5_valid_q[1] == 1'b1)) ? mas1_1_tsize :
                                  lrat_datain_size_q;
      assign lrat_datain_valid_d = ((ex5_valid_q[0] == 1'b1)) ? mas1_0_v :
                                   ((ex5_valid_q[1] == 1'b1)) ? mas1_1_v :
                                   lrat_datain_valid_q;
      assign lrat_datain_xbit_d = ((ex5_valid_q[0] == 1'b1)) ? mmucr3_0_x :
                                  ((ex5_valid_q[1] == 1'b1)) ? mmucr3_1_x :
                                  lrat_datain_xbit_q;
`else
      assign lrat_datain_rpn_d[32:63 - `LRAT_MINSIZE_LOG2] = ((ex5_valid_q[0] == 1'b1)) ? mas3_0_rpnl[32:63 - `LRAT_MINSIZE_LOG2] :
                                                            lrat_datain_rpn_q[32:63 - `LRAT_MINSIZE_LOG2];
      assign lrat_datain_lpid_d = ((ex5_valid_q[0] == 1'b1)) ? mas8_0_tlpid :
                                  lrat_datain_lpid_q;
      assign lrat_datain_size_d = ((ex5_valid_q[0] == 1'b1)) ? mas1_0_tsize :
                                  lrat_datain_size_q;
      assign lrat_datain_valid_d = ((ex5_valid_q[0] == 1'b1)) ? mas1_0_v :
                                   lrat_datain_valid_q;
      assign lrat_datain_xbit_d = ((ex5_valid_q[0] == 1'b1)) ? mmucr3_0_x :
                                  lrat_datain_xbit_q;
`endif
      assign lrat_mmucr3_x_d = ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b000)) ? lrat_entry0_xbit_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b001)) ? lrat_entry1_xbit_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b010)) ? lrat_entry2_xbit_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b011)) ? lrat_entry3_xbit_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b100)) ? lrat_entry4_xbit_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b101)) ? lrat_entry5_xbit_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b110)) ? lrat_entry6_xbit_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b111)) ? lrat_entry7_xbit_q :
                                 lrat_mmucr3_x_q;
      assign lrat_mas1_v_d = ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b000)) ? lrat_entry0_valid_q :
                             ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b001)) ? lrat_entry1_valid_q :
                             ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b010)) ? lrat_entry2_valid_q :
                             ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b011)) ? lrat_entry3_valid_q :
                             ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b100)) ? lrat_entry4_valid_q :
                             ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b101)) ? lrat_entry5_valid_q :
                             ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b110)) ? lrat_entry6_valid_q :
                             ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b111)) ? lrat_entry7_valid_q :
                             lrat_mas1_v_q;
      assign lrat_mas1_tsize_d = ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b000)) ? lrat_entry0_size_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b001)) ? lrat_entry1_size_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b010)) ? lrat_entry2_size_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b011)) ? lrat_entry3_size_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b100)) ? lrat_entry4_size_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b101)) ? lrat_entry5_size_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b110)) ? lrat_entry6_size_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b111)) ? lrat_entry7_size_q :
                                 lrat_mas1_tsize_q;
      assign lrat_mas2_epn_d[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1] = ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b000)) ? lrat_entry0_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                                                ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b001)) ? lrat_entry1_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                                                ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b010)) ? lrat_entry2_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                                                ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b011)) ? lrat_entry3_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                                                ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b100)) ? lrat_entry4_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                                                ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b101)) ? lrat_entry5_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                                                ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b110)) ? lrat_entry6_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                                                ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b111)) ? lrat_entry7_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                                                lrat_mas2_epn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1];
      assign lrat_mas2_epn_d[64 - `LRAT_MINSIZE_LOG2:51] = ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b000)) ? {8{1'b0}} :
                                                          ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b001)) ? {8{1'b0}} :
                                                          ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b010)) ? {8{1'b0}} :
                                                          ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b011)) ? {8{1'b0}} :
                                                          ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b100)) ? {8{1'b0}} :
                                                          ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b101)) ? {8{1'b0}} :
                                                          ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b110)) ? {8{1'b0}} :
                                                          ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b111)) ? {8{1'b0}} :
                                                          lrat_mas2_epn_q[64 - `LRAT_MINSIZE_LOG2:51];
      assign lrat_mas3_rpnl_d[32:64 - `LRAT_MINSIZE_LOG2 - 1] = ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b000)) ? lrat_entry0_rpn_q[32:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                               ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b001)) ? lrat_entry1_rpn_q[32:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                               ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b010)) ? lrat_entry2_rpn_q[32:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                               ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b011)) ? lrat_entry3_rpn_q[32:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                               ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b100)) ? lrat_entry4_rpn_q[32:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                               ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b101)) ? lrat_entry5_rpn_q[32:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                               ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b110)) ? lrat_entry6_rpn_q[32:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                               ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b111)) ? lrat_entry7_rpn_q[32:64 - `LRAT_MINSIZE_LOG2 - 1] :
                                                               lrat_mas3_rpnl_q[32:64 - `LRAT_MINSIZE_LOG2 - 1];
      assign lrat_mas3_rpnl_d[64 - `LRAT_MINSIZE_LOG2:51] = ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b000)) ? {8{1'b0}} :
                                                           ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b001)) ? {8{1'b0}} :
                                                           ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b010)) ? {8{1'b0}} :
                                                           ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b011)) ? {8{1'b0}} :
                                                           ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b100)) ? {8{1'b0}} :
                                                           ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b101)) ? {8{1'b0}} :
                                                           ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b110)) ? {8{1'b0}} :
                                                           ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b111)) ? {8{1'b0}} :
                                                           lrat_mas3_rpnl_q[64 - `LRAT_MINSIZE_LOG2:51];
      assign lrat_mas7_rpnu_d[64 - `REAL_ADDR_WIDTH:31] = ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b000)) ? lrat_entry0_rpn_q[64 - `REAL_ADDR_WIDTH:31] :
                                                         ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b001)) ? lrat_entry1_rpn_q[64 - `REAL_ADDR_WIDTH:31] :
                                                         ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b010)) ? lrat_entry2_rpn_q[64 - `REAL_ADDR_WIDTH:31] :
                                                         ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b011)) ? lrat_entry3_rpn_q[64 - `REAL_ADDR_WIDTH:31] :
                                                         ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b100)) ? lrat_entry4_rpn_q[64 - `REAL_ADDR_WIDTH:31] :
                                                         ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b101)) ? lrat_entry5_rpn_q[64 - `REAL_ADDR_WIDTH:31] :
                                                         ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b110)) ? lrat_entry6_rpn_q[64 - `REAL_ADDR_WIDTH:31] :
                                                         ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b111)) ? lrat_entry7_rpn_q[64 - `REAL_ADDR_WIDTH:31] :
                                                         lrat_mas7_rpnu_q[64 - `REAL_ADDR_WIDTH:31];
      assign lrat_mas8_tlpid_d = ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b000)) ? lrat_entry0_lpid_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b001)) ? lrat_entry1_lpid_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b010)) ? lrat_entry2_lpid_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b011)) ? lrat_entry3_lpid_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b100)) ? lrat_entry4_lpid_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b101)) ? lrat_entry5_lpid_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b110)) ? lrat_entry6_lpid_q :
                                 ((|(ex5_valid_q) == 1'b1 & ex5_esel_q == 3'b111)) ? lrat_entry7_lpid_q :
                                 lrat_mas8_tlpid_q;
      // ttype -> tlbre,tlbwe,tlbsx,tlbsxr,tlbsrx
      assign lrat_mas_tlbre_d = ((|(ex5_valid_q & (~(xu_ex5_flush))) == 1'b1 & ex5_ttype_q[0] == 1'b1 & ex5_atsel_q == 1'b1 & ex5_hv_state_q == 1'b1)) ? 1'b1 :
                                1'b0;
      assign lrat_mas_tlbsx_hit_d = ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[2:4] != 3'b000 & ex6_ttype_q[0] == 1'b1 & ex6_atsel_q == 1'b1 & ex6_hv_state_q == 1'b1 & lrat_tag3_hit_status_q[1] == 1'b1)) ? 1'b1 :
                                    1'b0;
      assign lrat_mas_tlbsx_miss_d = ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[2:4] != 3'b000 & ex6_ttype_q[0] == 1'b1 & ex6_atsel_q == 1'b1 & ex6_hv_state_q == 1'b1 & lrat_tag3_hit_status_q[1] == 1'b0)) ? 1'b1 :
                                     1'b0;
      assign lrat_mas_thdid_d[0:`MM_THREADS-1] = (ex5_valid_q & {`MM_THREADS{ex5_ttype_q[0]}}) |
                                                   (ex6_valid_q & {`MM_THREADS{|(ex6_ttype_q[2:4])}});
      // power clock gating
      assign lrat_mas_act_d[0] = ((|(ex4_valid_q) & |(ex4_ttype_q)) | mmucr2_act_override) & xu_mm_ccr2_notlb_b;
      assign lrat_mas_act_d[1] = ((|(ex4_valid_q) & |(ex4_ttype_q)) | mmucr2_act_override) & xu_mm_ccr2_notlb_b;
      assign lrat_mas_act_d[2] = (((|(ex4_valid_q) & |(ex4_ttype_q)) | mmucr2_act_override) & xu_mm_ccr2_notlb_b) |
                                   (((|(ex5_valid_q) & |(ex5_ttype_q)) | mmucr2_act_override) & xu_mm_ccr2_notlb_b) |
                                   (((|(ex6_valid_q) & |(ex6_ttype_q)) | mmucr2_act_override) & xu_mm_ccr2_notlb_b);
      assign lrat_datain_act_d[0] = ((|(ex4_valid_q) & |(ex4_ttype_q)) | mmucr2_act_override) & xu_mm_ccr2_notlb_b;
      assign lrat_datain_act_d[1] = ((|(ex4_valid_q) & |(ex4_ttype_q)) | mmucr2_act_override) & xu_mm_ccr2_notlb_b;
      // tag4 phase signals, tlbwe/re ex6
      assign lrat_entry0_wren = ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_hv_state_q == 1'b1 & ex6_atsel_q == 1'b1 & ex6_hes_q == 1'b0 & (ex6_wq_q == 2'b00 | ex6_wq_q == 2'b11) & ex6_esel_q == 3'b000 & ex6_illeg_instr[1] == 1'b0)) ? 1'b1 :
                                1'b0;
      assign lrat_entry0_lpn_d = ((lrat_entry0_wren == 1'b1)) ? lrat_datain_lpn_q :
                                 lrat_entry0_lpn_q;
      assign lrat_entry0_rpn_d = ((lrat_entry0_wren == 1'b1)) ? lrat_datain_rpn_q :
                                 lrat_entry0_rpn_q;
      assign lrat_entry0_lpid_d = ((lrat_entry0_wren == 1'b1)) ? lrat_datain_lpid_q :
                                  lrat_entry0_lpid_q;
      assign lrat_entry0_size_d = ((lrat_entry0_wren == 1'b1)) ? lrat_datain_size_q :
                                  lrat_entry0_size_q;
      assign lrat_entry0_xbit_d = ((lrat_entry0_wren == 1'b1)) ? lrat_datain_xbit_q :
                                  lrat_entry0_xbit_q;
      assign lrat_entry0_valid_d = ((lrat_entry0_wren == 1'b1)) ? lrat_datain_valid_q :
                                   lrat_entry0_valid_q;

      assign lrat_datain_size_gte_1TB = (lrat_datain_size_q == LRAT_PgSize_1TB) ? 1'b1 :
                                        1'b0;
      assign lrat_datain_size_gte_256GB = ((lrat_datain_size_q == LRAT_PgSize_1TB) |
                                             (lrat_datain_size_q == LRAT_PgSize_256GB)) ? 1'b1 :
                                        1'b0;
      assign lrat_datain_size_gte_16GB =  ((lrat_datain_size_q == LRAT_PgSize_1TB) |
                                             (lrat_datain_size_q == LRAT_PgSize_256GB) |
                                             (lrat_datain_size_q == LRAT_PgSize_16GB)) ? 1'b1 :
                                        1'b0;
      assign lrat_datain_size_gte_4GB =  ((lrat_datain_size_q == LRAT_PgSize_1TB) |
                                            (lrat_datain_size_q == LRAT_PgSize_256GB) |
                                            (lrat_datain_size_q == LRAT_PgSize_16GB) |
                                            (lrat_datain_size_q == LRAT_PgSize_4GB)) ? 1'b1 :
                                        1'b0;
      assign lrat_datain_size_gte_1GB =  ((lrat_datain_size_q == LRAT_PgSize_1TB) |
                                            (lrat_datain_size_q == LRAT_PgSize_256GB) |
                                            (lrat_datain_size_q == LRAT_PgSize_16GB) |
                                            (lrat_datain_size_q == LRAT_PgSize_4GB) |
                                            (lrat_datain_size_q == LRAT_PgSize_1GB)) ? 1'b1 :
                                        1'b0;
      assign lrat_datain_size_gte_256MB = ((lrat_datain_size_q == LRAT_PgSize_1TB) |
                                            (lrat_datain_size_q == LRAT_PgSize_256GB) |
                                            (lrat_datain_size_q == LRAT_PgSize_16GB) |
                                            (lrat_datain_size_q == LRAT_PgSize_4GB) |
                                            (lrat_datain_size_q == LRAT_PgSize_1GB) |
                                            (lrat_datain_size_q == LRAT_PgSize_256MB)) ? 1'b1 :
                                        1'b0;
      assign lrat_datain_size_gte_16MB =  ((lrat_datain_size_q == LRAT_PgSize_1TB) |
                                            (lrat_datain_size_q == LRAT_PgSize_256GB) |
                                            (lrat_datain_size_q == LRAT_PgSize_16GB) |
                                            (lrat_datain_size_q == LRAT_PgSize_4GB) |
                                            (lrat_datain_size_q == LRAT_PgSize_1GB) |
                                            (lrat_datain_size_q == LRAT_PgSize_256MB) |
                                            (lrat_datain_size_q == LRAT_PgSize_16MB)) ? 1'b1 :
                                        1'b0;

      //  size           entry_cmpmask: 0123456
      //    1TB                         1111111
      //  256GB                         0111111
      //   16GB                         0011111
      //    4GB                         0001111
      //    1GB                         0000111
      //  256MB                         0000011
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry0_cmpmask_d[0] = ((lrat_entry0_wren == 1'b1)) ? (lrat_datain_size_gte_1TB) :
                                        lrat_entry0_cmpmask_q[0];
      assign lrat_entry0_cmpmask_d[1] = ((lrat_entry0_wren == 1'b1)) ? (lrat_datain_size_gte_256GB) :
                                        lrat_entry0_cmpmask_q[1];
      assign lrat_entry0_cmpmask_d[2] = ((lrat_entry0_wren == 1'b1)) ? (lrat_datain_size_gte_16GB) :
                                        lrat_entry0_cmpmask_q[2];
      assign lrat_entry0_cmpmask_d[3] = ((lrat_entry0_wren == 1'b1)) ? (lrat_datain_size_gte_4GB) :
                                        lrat_entry0_cmpmask_q[3];
      assign lrat_entry0_cmpmask_d[4] = ((lrat_entry0_wren == 1'b1)) ? (lrat_datain_size_gte_1GB) :
                                        lrat_entry0_cmpmask_q[4];
      assign lrat_entry0_cmpmask_d[5] = ((lrat_entry0_wren == 1'b1)) ? (lrat_datain_size_gte_256MB) :
                                        lrat_entry0_cmpmask_q[5];
      assign lrat_entry0_cmpmask_d[6] = ((lrat_entry0_wren == 1'b1)) ? (lrat_datain_size_gte_16MB) :
                                        lrat_entry0_cmpmask_q[6];
      //  size          entry_xbitmask: 0123456
      //    1TB                         1000000
      //  256GB                         0100000
      //   16GB                         0010000
      //    4GB                         0001000
      //    1GB                         0000100
      //  256MB                         0000010
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry0_xbitmask_d[0] = ((lrat_entry0_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1TB) :
                                         lrat_entry0_xbitmask_q[0];
      assign lrat_entry0_xbitmask_d[1] = ((lrat_entry0_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256GB) :
                                         lrat_entry0_xbitmask_q[1];
      assign lrat_entry0_xbitmask_d[2] = ((lrat_entry0_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16GB) :
                                         lrat_entry0_xbitmask_q[2];
      assign lrat_entry0_xbitmask_d[3] = ((lrat_entry0_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_4GB) :
                                         lrat_entry0_xbitmask_q[3];
      assign lrat_entry0_xbitmask_d[4] = ((lrat_entry0_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1GB) :
                                         lrat_entry0_xbitmask_q[4];
      assign lrat_entry0_xbitmask_d[5] = ((lrat_entry0_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256MB) :
                                         lrat_entry0_xbitmask_q[5];
      assign lrat_entry0_xbitmask_d[6] = ((lrat_entry0_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16MB) :
                                         lrat_entry0_xbitmask_q[6];
      assign lrat_entry1_wren = ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_hv_state_q == 1'b1 & ex6_atsel_q == 1'b1 & ex6_hes_q == 1'b0 & (ex6_wq_q == 2'b00 | ex6_wq_q == 2'b11) & ex6_esel_q == 3'b001 & ex6_illeg_instr[1] == 1'b0)) ? 1'b1 :
                                1'b0;
      assign lrat_entry1_lpn_d = ((lrat_entry1_wren == 1'b1)) ? lrat_datain_lpn_q :
                                 lrat_entry1_lpn_q;
      assign lrat_entry1_rpn_d = ((lrat_entry1_wren == 1'b1)) ? lrat_datain_rpn_q :
                                 lrat_entry1_rpn_q;
      assign lrat_entry1_lpid_d = ((lrat_entry1_wren == 1'b1)) ? lrat_datain_lpid_q :
                                  lrat_entry1_lpid_q;
      assign lrat_entry1_size_d = ((lrat_entry1_wren == 1'b1)) ? lrat_datain_size_q :
                                  lrat_entry1_size_q;
      assign lrat_entry1_xbit_d = ((lrat_entry1_wren == 1'b1)) ? lrat_datain_xbit_q :
                                  lrat_entry1_xbit_q;
      assign lrat_entry1_valid_d = ((lrat_entry1_wren == 1'b1)) ? lrat_datain_valid_q :
                                   lrat_entry1_valid_q;
      //  size           entry_cmpmask: 0123456
      //    1TB                         1111111
      //  256GB                         0111111
      //   16GB                         0011111
      //    4GB                         0001111
      //    1GB                         0000111
      //  256MB                         0000011
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry1_cmpmask_d[0] = ((lrat_entry1_wren == 1'b1)) ? (lrat_datain_size_gte_1TB) :
                                        lrat_entry1_cmpmask_q[0];
      assign lrat_entry1_cmpmask_d[1] = ((lrat_entry1_wren == 1'b1)) ? (lrat_datain_size_gte_256GB) :
                                        lrat_entry1_cmpmask_q[1];
      assign lrat_entry1_cmpmask_d[2] = ((lrat_entry1_wren == 1'b1)) ? (lrat_datain_size_gte_16GB) :
                                        lrat_entry1_cmpmask_q[2];
      assign lrat_entry1_cmpmask_d[3] = ((lrat_entry1_wren == 1'b1)) ? (lrat_datain_size_gte_4GB) :
                                        lrat_entry1_cmpmask_q[3];
      assign lrat_entry1_cmpmask_d[4] = ((lrat_entry1_wren == 1'b1)) ? (lrat_datain_size_gte_1GB) :
                                        lrat_entry1_cmpmask_q[4];
      assign lrat_entry1_cmpmask_d[5] = ((lrat_entry1_wren == 1'b1)) ? (lrat_datain_size_gte_256MB) :
                                        lrat_entry1_cmpmask_q[5];
      assign lrat_entry1_cmpmask_d[6] = ((lrat_entry1_wren == 1'b1)) ? (lrat_datain_size_gte_16MB) :
                                        lrat_entry1_cmpmask_q[6];
      //  size          entry_xbitmask: 0123456
      //    1TB                         1000000
      //  256GB                         0100000
      //   16GB                         0010000
      //    4GB                         0001000
      //    1GB                         0000100
      //  256MB                         0000010
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry1_xbitmask_d[0] = ((lrat_entry1_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1TB) :
                                         lrat_entry1_xbitmask_q[0];
      assign lrat_entry1_xbitmask_d[1] = ((lrat_entry1_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256GB) :
                                         lrat_entry1_xbitmask_q[1];
      assign lrat_entry1_xbitmask_d[2] = ((lrat_entry1_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16GB) :
                                         lrat_entry1_xbitmask_q[2];
      assign lrat_entry1_xbitmask_d[3] = ((lrat_entry1_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_4GB) :
                                         lrat_entry1_xbitmask_q[3];
      assign lrat_entry1_xbitmask_d[4] = ((lrat_entry1_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1GB) :
                                         lrat_entry1_xbitmask_q[4];
      assign lrat_entry1_xbitmask_d[5] = ((lrat_entry1_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256MB) :
                                         lrat_entry1_xbitmask_q[5];
      assign lrat_entry1_xbitmask_d[6] = ((lrat_entry1_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16MB) :
                                         lrat_entry1_xbitmask_q[6];
      assign lrat_entry2_wren = ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_hv_state_q == 1'b1 & ex6_atsel_q == 1'b1 & ex6_hes_q == 1'b0 & (ex6_wq_q == 2'b00 | ex6_wq_q == 2'b11) & ex6_esel_q == 3'b010 & ex6_illeg_instr[1] == 1'b0)) ? 1'b1 :
                                1'b0;
      assign lrat_entry2_lpn_d = ((lrat_entry2_wren == 1'b1)) ? lrat_datain_lpn_q :
                                 lrat_entry2_lpn_q;
      assign lrat_entry2_rpn_d = ((lrat_entry2_wren == 1'b1)) ? lrat_datain_rpn_q :
                                 lrat_entry2_rpn_q;
      assign lrat_entry2_lpid_d = ((lrat_entry2_wren == 1'b1)) ? lrat_datain_lpid_q :
                                  lrat_entry2_lpid_q;
      assign lrat_entry2_size_d = ((lrat_entry2_wren == 1'b1)) ? lrat_datain_size_q :
                                  lrat_entry2_size_q;
      assign lrat_entry2_xbit_d = ((lrat_entry2_wren == 1'b1)) ? lrat_datain_xbit_q :
                                  lrat_entry2_xbit_q;
      assign lrat_entry2_valid_d = ((lrat_entry2_wren == 1'b1)) ? lrat_datain_valid_q :
                                   lrat_entry2_valid_q;
      //  size           entry_cmpmask: 0123456
      //    1TB                         1111111
      //  256GB                         0111111
      //   16GB                         0011111
      //    4GB                         0001111
      //    1GB                         0000111
      //  256MB                         0000011
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry2_cmpmask_d[0] = ((lrat_entry2_wren == 1'b1)) ? (lrat_datain_size_gte_1TB) :
                                        lrat_entry2_cmpmask_q[0];
      assign lrat_entry2_cmpmask_d[1] = ((lrat_entry2_wren == 1'b1)) ? (lrat_datain_size_gte_256GB) :
                                        lrat_entry2_cmpmask_q[1];
      assign lrat_entry2_cmpmask_d[2] = ((lrat_entry2_wren == 1'b1)) ? (lrat_datain_size_gte_16GB) :
                                        lrat_entry2_cmpmask_q[2];
      assign lrat_entry2_cmpmask_d[3] = ((lrat_entry2_wren == 1'b1)) ? (lrat_datain_size_gte_4GB) :
                                        lrat_entry2_cmpmask_q[3];
      assign lrat_entry2_cmpmask_d[4] = ((lrat_entry2_wren == 1'b1)) ? (lrat_datain_size_gte_1GB) :
                                        lrat_entry2_cmpmask_q[4];
      assign lrat_entry2_cmpmask_d[5] = ((lrat_entry2_wren == 1'b1)) ? (lrat_datain_size_gte_256MB) :
                                        lrat_entry2_cmpmask_q[5];
      assign lrat_entry2_cmpmask_d[6] = ((lrat_entry2_wren == 1'b1)) ? (lrat_datain_size_gte_16MB) :
                                        lrat_entry2_cmpmask_q[6];
      //  size          entry_xbitmask: 0123456
      //    1TB                         1000000
      //  256GB                         0100000
      //   16GB                         0010000
      //    4GB                         0001000
      //    1GB                         0000100
      //  256MB                         0000010
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry2_xbitmask_d[0] = ((lrat_entry2_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1TB) :
                                         lrat_entry2_xbitmask_q[0];
      assign lrat_entry2_xbitmask_d[1] = ((lrat_entry2_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256GB) :
                                         lrat_entry2_xbitmask_q[1];
      assign lrat_entry2_xbitmask_d[2] = ((lrat_entry2_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16GB) :
                                         lrat_entry2_xbitmask_q[2];
      assign lrat_entry2_xbitmask_d[3] = ((lrat_entry2_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_4GB) :
                                         lrat_entry2_xbitmask_q[3];
      assign lrat_entry2_xbitmask_d[4] = ((lrat_entry2_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1GB) :
                                         lrat_entry2_xbitmask_q[4];
      assign lrat_entry2_xbitmask_d[5] = ((lrat_entry2_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256MB) :
                                         lrat_entry2_xbitmask_q[5];
      assign lrat_entry2_xbitmask_d[6] = ((lrat_entry2_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16MB) :
                                         lrat_entry2_xbitmask_q[6];
      assign lrat_entry3_wren = ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_hv_state_q == 1'b1 & ex6_atsel_q == 1'b1 & ex6_hes_q == 1'b0 & (ex6_wq_q == 2'b00 | ex6_wq_q == 2'b11) & ex6_esel_q == 3'b011 & ex6_illeg_instr[1] == 1'b0)) ? 1'b1 :
                                1'b0;
      assign lrat_entry3_lpn_d = ((lrat_entry3_wren == 1'b1)) ? lrat_datain_lpn_q :
                                 lrat_entry3_lpn_q;
      assign lrat_entry3_rpn_d = ((lrat_entry3_wren == 1'b1)) ? lrat_datain_rpn_q :
                                 lrat_entry3_rpn_q;
      assign lrat_entry3_lpid_d = ((lrat_entry3_wren == 1'b1)) ? lrat_datain_lpid_q :
                                  lrat_entry3_lpid_q;
      assign lrat_entry3_size_d = ((lrat_entry3_wren == 1'b1)) ? lrat_datain_size_q :
                                  lrat_entry3_size_q;
      assign lrat_entry3_xbit_d = ((lrat_entry3_wren == 1'b1)) ? lrat_datain_xbit_q :
                                  lrat_entry3_xbit_q;
      assign lrat_entry3_valid_d = ((lrat_entry3_wren == 1'b1)) ? lrat_datain_valid_q :
                                   lrat_entry3_valid_q;
      //  size           entry_cmpmask: 0123456
      //    1TB                         1111111
      //  256GB                         0111111
      //   16GB                         0011111
      //    4GB                         0001111
      //    1GB                         0000111
      //  256MB                         0000011
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry3_cmpmask_d[0] = ((lrat_entry3_wren == 1'b1)) ? (lrat_datain_size_gte_1TB) :
                                        lrat_entry3_cmpmask_q[0];
      assign lrat_entry3_cmpmask_d[1] = ((lrat_entry3_wren == 1'b1)) ? (lrat_datain_size_gte_256GB) :
                                        lrat_entry3_cmpmask_q[1];
      assign lrat_entry3_cmpmask_d[2] = ((lrat_entry3_wren == 1'b1)) ? (lrat_datain_size_gte_16GB) :
                                        lrat_entry3_cmpmask_q[2];
      assign lrat_entry3_cmpmask_d[3] = ((lrat_entry3_wren == 1'b1)) ? (lrat_datain_size_gte_4GB) :
                                        lrat_entry3_cmpmask_q[3];
      assign lrat_entry3_cmpmask_d[4] = ((lrat_entry3_wren == 1'b1)) ? (lrat_datain_size_gte_1GB) :
                                        lrat_entry3_cmpmask_q[4];
      assign lrat_entry3_cmpmask_d[5] = ((lrat_entry3_wren == 1'b1)) ? (lrat_datain_size_gte_256MB) :
                                        lrat_entry3_cmpmask_q[5];
      assign lrat_entry3_cmpmask_d[6] = ((lrat_entry3_wren == 1'b1)) ? (lrat_datain_size_gte_16MB) :
                                        lrat_entry3_cmpmask_q[6];
      //  size          entry_xbitmask: 0123456
      //    1TB                         1000000
      //  256GB                         0100000
      //   16GB                         0010000
      //    4GB                         0001000
      //    1GB                         0000100
      //  256MB                         0000010
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry3_xbitmask_d[0] = ((lrat_entry3_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1TB) :
                                         lrat_entry3_xbitmask_q[0];
      assign lrat_entry3_xbitmask_d[1] = ((lrat_entry3_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256GB) :
                                         lrat_entry3_xbitmask_q[1];
      assign lrat_entry3_xbitmask_d[2] = ((lrat_entry3_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16GB) :
                                         lrat_entry3_xbitmask_q[2];
      assign lrat_entry3_xbitmask_d[3] = ((lrat_entry3_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_4GB) :
                                         lrat_entry3_xbitmask_q[3];
      assign lrat_entry3_xbitmask_d[4] = ((lrat_entry3_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1GB) :
                                         lrat_entry3_xbitmask_q[4];
      assign lrat_entry3_xbitmask_d[5] = ((lrat_entry3_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256MB) :
                                         lrat_entry3_xbitmask_q[5];
      assign lrat_entry3_xbitmask_d[6] = ((lrat_entry3_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16MB) :
                                         lrat_entry3_xbitmask_q[6];
      assign lrat_entry4_wren = ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_hv_state_q == 1'b1 & ex6_atsel_q == 1'b1 & ex6_hes_q == 1'b0 & (ex6_wq_q == 2'b00 | ex6_wq_q == 2'b11) & ex6_esel_q == 3'b100 & ex6_illeg_instr[1] == 1'b0)) ? 1'b1 :
                                1'b0;
      assign lrat_entry4_lpn_d = ((lrat_entry4_wren == 1'b1)) ? lrat_datain_lpn_q :
                                 lrat_entry4_lpn_q;
      assign lrat_entry4_rpn_d = ((lrat_entry4_wren == 1'b1)) ? lrat_datain_rpn_q :
                                 lrat_entry4_rpn_q;
      assign lrat_entry4_lpid_d = ((lrat_entry4_wren == 1'b1)) ? lrat_datain_lpid_q :
                                  lrat_entry4_lpid_q;
      assign lrat_entry4_size_d = ((lrat_entry4_wren == 1'b1)) ? lrat_datain_size_q :
                                  lrat_entry4_size_q;
      assign lrat_entry4_xbit_d = ((lrat_entry4_wren == 1'b1)) ? lrat_datain_xbit_q :
                                  lrat_entry4_xbit_q;
      assign lrat_entry4_valid_d = ((lrat_entry4_wren == 1'b1)) ? lrat_datain_valid_q :
                                   lrat_entry4_valid_q;
      //  size           entry_cmpmask: 0123456
      //    1TB                         1111111
      //  256GB                         0111111
      //   16GB                         0011111
      //    4GB                         0001111
      //    1GB                         0000111
      //  256MB                         0000011
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry4_cmpmask_d[0] = ((lrat_entry4_wren == 1'b1)) ? (lrat_datain_size_gte_1TB) :
                                        lrat_entry4_cmpmask_q[0];
      assign lrat_entry4_cmpmask_d[1] = ((lrat_entry4_wren == 1'b1)) ? (lrat_datain_size_gte_256GB) :
                                        lrat_entry4_cmpmask_q[1];
      assign lrat_entry4_cmpmask_d[2] = ((lrat_entry4_wren == 1'b1)) ? (lrat_datain_size_gte_16GB) :
                                        lrat_entry4_cmpmask_q[2];
      assign lrat_entry4_cmpmask_d[3] = ((lrat_entry4_wren == 1'b1)) ? (lrat_datain_size_gte_4GB) :
                                        lrat_entry4_cmpmask_q[3];
      assign lrat_entry4_cmpmask_d[4] = ((lrat_entry4_wren == 1'b1)) ? (lrat_datain_size_gte_1GB) :
                                        lrat_entry4_cmpmask_q[4];
      assign lrat_entry4_cmpmask_d[5] = ((lrat_entry4_wren == 1'b1)) ? (lrat_datain_size_gte_256MB) :
                                        lrat_entry4_cmpmask_q[5];
      assign lrat_entry4_cmpmask_d[6] = ((lrat_entry4_wren == 1'b1)) ? (lrat_datain_size_gte_16MB) :
                                        lrat_entry4_cmpmask_q[6];
      //  size          entry_xbitmask: 0123456
      //    1TB                         1000000
      //  256GB                         0100000
      //   16GB                         0010000
      //    4GB                         0001000
      //    1GB                         0000100
      //  256MB                         0000010
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry4_xbitmask_d[0] = ((lrat_entry4_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1TB) :
                                         lrat_entry4_xbitmask_q[0];
      assign lrat_entry4_xbitmask_d[1] = ((lrat_entry4_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256GB) :
                                         lrat_entry4_xbitmask_q[1];
      assign lrat_entry4_xbitmask_d[2] = ((lrat_entry4_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16GB) :
                                         lrat_entry4_xbitmask_q[2];
      assign lrat_entry4_xbitmask_d[3] = ((lrat_entry4_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_4GB) :
                                         lrat_entry4_xbitmask_q[3];
      assign lrat_entry4_xbitmask_d[4] = ((lrat_entry4_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1GB) :
                                         lrat_entry4_xbitmask_q[4];
      assign lrat_entry4_xbitmask_d[5] = ((lrat_entry4_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256MB) :
                                         lrat_entry4_xbitmask_q[5];
      assign lrat_entry4_xbitmask_d[6] = ((lrat_entry4_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16MB) :
                                         lrat_entry4_xbitmask_q[6];
      assign lrat_entry5_wren = ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_hv_state_q == 1'b1 & ex6_atsel_q == 1'b1 & ex6_hes_q == 1'b0 & (ex6_wq_q == 2'b00 | ex6_wq_q == 2'b11) & ex6_esel_q == 3'b101 & ex6_illeg_instr[1] == 1'b0)) ? 1'b1 :
                                1'b0;
      assign lrat_entry5_lpn_d = ((lrat_entry5_wren == 1'b1)) ? lrat_datain_lpn_q :
                                 lrat_entry5_lpn_q;
      assign lrat_entry5_rpn_d = ((lrat_entry5_wren == 1'b1)) ? lrat_datain_rpn_q :
                                 lrat_entry5_rpn_q;
      assign lrat_entry5_lpid_d = ((lrat_entry5_wren == 1'b1)) ? lrat_datain_lpid_q :
                                  lrat_entry5_lpid_q;
      assign lrat_entry5_size_d = ((lrat_entry5_wren == 1'b1)) ? lrat_datain_size_q :
                                  lrat_entry5_size_q;
      assign lrat_entry5_xbit_d = ((lrat_entry5_wren == 1'b1)) ? lrat_datain_xbit_q :
                                  lrat_entry5_xbit_q;
      assign lrat_entry5_valid_d = ((lrat_entry5_wren == 1'b1)) ? lrat_datain_valid_q :
                                   lrat_entry5_valid_q;
      //  size           entry_cmpmask: 0123456
      //    1TB                         1111111
      //  256GB                         0111111
      //   16GB                         0011111
      //    4GB                         0001111
      //    1GB                         0000111
      //  256MB                         0000011
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry5_cmpmask_d[0] = ((lrat_entry5_wren == 1'b1)) ? (lrat_datain_size_gte_1TB) :
                                        lrat_entry5_cmpmask_q[0];
      assign lrat_entry5_cmpmask_d[1] = ((lrat_entry5_wren == 1'b1)) ? (lrat_datain_size_gte_256GB) :
                                        lrat_entry5_cmpmask_q[1];
      assign lrat_entry5_cmpmask_d[2] = ((lrat_entry5_wren == 1'b1)) ? (lrat_datain_size_gte_16GB) :
                                        lrat_entry5_cmpmask_q[2];
      assign lrat_entry5_cmpmask_d[3] = ((lrat_entry5_wren == 1'b1)) ? (lrat_datain_size_gte_4GB) :
                                        lrat_entry5_cmpmask_q[3];
      assign lrat_entry5_cmpmask_d[4] = ((lrat_entry5_wren == 1'b1)) ? (lrat_datain_size_gte_1GB) :
                                        lrat_entry5_cmpmask_q[4];
      assign lrat_entry5_cmpmask_d[5] = ((lrat_entry5_wren == 1'b1)) ? (lrat_datain_size_gte_256MB) :
                                        lrat_entry5_cmpmask_q[5];
      assign lrat_entry5_cmpmask_d[6] = ((lrat_entry5_wren == 1'b1)) ? (lrat_datain_size_gte_16MB) :
                                        lrat_entry5_cmpmask_q[6];
      //  size          entry_xbitmask: 0123456
      //    1TB                         1000000
      //  256GB                         0100000
      //   16GB                         0010000
      //    4GB                         0001000
      //    1GB                         0000100
      //  256MB                         0000010
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry5_xbitmask_d[0] = ((lrat_entry5_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1TB) :
                                         lrat_entry5_xbitmask_q[0];
      assign lrat_entry5_xbitmask_d[1] = ((lrat_entry5_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256GB) :
                                         lrat_entry5_xbitmask_q[1];
      assign lrat_entry5_xbitmask_d[2] = ((lrat_entry5_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16GB) :
                                         lrat_entry5_xbitmask_q[2];
      assign lrat_entry5_xbitmask_d[3] = ((lrat_entry5_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_4GB) :
                                         lrat_entry5_xbitmask_q[3];
      assign lrat_entry5_xbitmask_d[4] = ((lrat_entry5_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1GB) :
                                         lrat_entry5_xbitmask_q[4];
      assign lrat_entry5_xbitmask_d[5] = ((lrat_entry5_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256MB) :
                                         lrat_entry5_xbitmask_q[5];
      assign lrat_entry5_xbitmask_d[6] = ((lrat_entry5_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16MB) :
                                         lrat_entry5_xbitmask_q[6];
      assign lrat_entry6_wren = ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_hv_state_q == 1'b1 & ex6_atsel_q == 1'b1 & ex6_hes_q == 1'b0 & (ex6_wq_q == 2'b00 | ex6_wq_q == 2'b11) & ex6_esel_q == 3'b110 & ex6_illeg_instr[1] == 1'b0)) ? 1'b1 :
                                1'b0;
      assign lrat_entry6_lpn_d = ((lrat_entry6_wren == 1'b1)) ? lrat_datain_lpn_q :
                                 lrat_entry6_lpn_q;
      assign lrat_entry6_rpn_d = ((lrat_entry6_wren == 1'b1)) ? lrat_datain_rpn_q :
                                 lrat_entry6_rpn_q;
      assign lrat_entry6_lpid_d = ((lrat_entry6_wren == 1'b1)) ? lrat_datain_lpid_q :
                                  lrat_entry6_lpid_q;
      assign lrat_entry6_size_d = ((lrat_entry6_wren == 1'b1)) ? lrat_datain_size_q :
                                  lrat_entry6_size_q;
      assign lrat_entry6_xbit_d = ((lrat_entry6_wren == 1'b1)) ? lrat_datain_xbit_q :
                                  lrat_entry6_xbit_q;
      assign lrat_entry6_valid_d = ((lrat_entry6_wren == 1'b1)) ? lrat_datain_valid_q :
                                   lrat_entry6_valid_q;
      //  size           entry_cmpmask: 0123456
      //    1TB                         1111111
      //  256GB                         0111111
      //   16GB                         0011111
      //    4GB                         0001111
      //    1GB                         0000111
      //  256MB                         0000011
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry6_cmpmask_d[0] = ((lrat_entry6_wren == 1'b1)) ? (lrat_datain_size_gte_1TB) :
                                        lrat_entry6_cmpmask_q[0];
      assign lrat_entry6_cmpmask_d[1] = ((lrat_entry6_wren == 1'b1)) ? (lrat_datain_size_gte_256GB) :
                                        lrat_entry6_cmpmask_q[1];
      assign lrat_entry6_cmpmask_d[2] = ((lrat_entry6_wren == 1'b1)) ? (lrat_datain_size_gte_16GB) :
                                        lrat_entry6_cmpmask_q[2];
      assign lrat_entry6_cmpmask_d[3] = ((lrat_entry6_wren == 1'b1)) ? (lrat_datain_size_gte_4GB) :
                                        lrat_entry6_cmpmask_q[3];
      assign lrat_entry6_cmpmask_d[4] = ((lrat_entry6_wren == 1'b1)) ? (lrat_datain_size_gte_1GB) :
                                        lrat_entry6_cmpmask_q[4];
      assign lrat_entry6_cmpmask_d[5] = ((lrat_entry6_wren == 1'b1)) ? (lrat_datain_size_gte_256MB) :
                                        lrat_entry6_cmpmask_q[5];
      assign lrat_entry6_cmpmask_d[6] = ((lrat_entry6_wren == 1'b1)) ? (lrat_datain_size_gte_16MB) :
                                        lrat_entry6_cmpmask_q[6];
      //  size          entry_xbitmask: 0123456
      //    1TB                         1000000
      //  256GB                         0100000
      //   16GB                         0010000
      //    4GB                         0001000
      //    1GB                         0000100
      //  256MB                         0000010
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry6_xbitmask_d[0] = ((lrat_entry6_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1TB) :
                                         lrat_entry6_xbitmask_q[0];
      assign lrat_entry6_xbitmask_d[1] = ((lrat_entry6_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256GB) :
                                         lrat_entry6_xbitmask_q[1];
      assign lrat_entry6_xbitmask_d[2] = ((lrat_entry6_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16GB) :
                                         lrat_entry6_xbitmask_q[2];
      assign lrat_entry6_xbitmask_d[3] = ((lrat_entry6_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_4GB) :
                                         lrat_entry6_xbitmask_q[3];
      assign lrat_entry6_xbitmask_d[4] = ((lrat_entry6_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1GB) :
                                         lrat_entry6_xbitmask_q[4];
      assign lrat_entry6_xbitmask_d[5] = ((lrat_entry6_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256MB) :
                                         lrat_entry6_xbitmask_q[5];
      assign lrat_entry6_xbitmask_d[6] = ((lrat_entry6_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16MB) :
                                         lrat_entry6_xbitmask_q[6];
      assign lrat_entry7_wren = ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_hv_state_q == 1'b1 & ex6_atsel_q == 1'b1 & ex6_hes_q == 1'b0 & (ex6_wq_q == 2'b00 | ex6_wq_q == 2'b11) & ex6_esel_q == 3'b111 & ex6_illeg_instr[1] == 1'b0)) ? 1'b1 :
                                1'b0;
      assign lrat_entry7_lpn_d = ((lrat_entry7_wren == 1'b1)) ? lrat_datain_lpn_q :
                                 lrat_entry7_lpn_q;
      assign lrat_entry7_rpn_d = ((lrat_entry7_wren == 1'b1)) ? lrat_datain_rpn_q :
                                 lrat_entry7_rpn_q;
      assign lrat_entry7_lpid_d = ((lrat_entry7_wren == 1'b1)) ? lrat_datain_lpid_q :
                                  lrat_entry7_lpid_q;
      assign lrat_entry7_size_d = ((lrat_entry7_wren == 1'b1)) ? lrat_datain_size_q :
                                  lrat_entry7_size_q;
      assign lrat_entry7_xbit_d = ((lrat_entry7_wren == 1'b1)) ? lrat_datain_xbit_q :
                                  lrat_entry7_xbit_q;
      assign lrat_entry7_valid_d = ((lrat_entry7_wren == 1'b1)) ? lrat_datain_valid_q :
                                   lrat_entry7_valid_q;
      //  size           entry_cmpmask: 0123456
      //    1TB                         1111111
      //  256GB                         0111111
      //   16GB                         0011111
      //    4GB                         0001111
      //    1GB                         0000111
      //  256MB                         0000011
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry7_cmpmask_d[0] = ((lrat_entry7_wren == 1'b1)) ? (lrat_datain_size_gte_1TB) :
                                        lrat_entry7_cmpmask_q[0];
      assign lrat_entry7_cmpmask_d[1] = ((lrat_entry7_wren == 1'b1)) ? (lrat_datain_size_gte_256GB) :
                                        lrat_entry7_cmpmask_q[1];
      assign lrat_entry7_cmpmask_d[2] = ((lrat_entry7_wren == 1'b1)) ? (lrat_datain_size_gte_16GB) :
                                        lrat_entry7_cmpmask_q[2];
      assign lrat_entry7_cmpmask_d[3] = ((lrat_entry7_wren == 1'b1)) ? (lrat_datain_size_gte_4GB) :
                                        lrat_entry7_cmpmask_q[3];
      assign lrat_entry7_cmpmask_d[4] = ((lrat_entry7_wren == 1'b1)) ? (lrat_datain_size_gte_1GB) :
                                        lrat_entry7_cmpmask_q[4];
      assign lrat_entry7_cmpmask_d[5] = ((lrat_entry7_wren == 1'b1)) ? (lrat_datain_size_gte_256MB) :
                                        lrat_entry7_cmpmask_q[5];
      assign lrat_entry7_cmpmask_d[6] = ((lrat_entry7_wren == 1'b1)) ? (lrat_datain_size_gte_16MB) :
                                        lrat_entry7_cmpmask_q[6];
      //  size          entry_xbitmask: 0123456
      //    1TB                         1000000
      //  256GB                         0100000
      //   16GB                         0010000
      //    4GB                         0001000
      //    1GB                         0000100
      //  256MB                         0000010
      //   16MB                         0000001
      //    1MB                         0000000
      assign lrat_entry7_xbitmask_d[0] = ((lrat_entry7_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1TB) :
                                         lrat_entry7_xbitmask_q[0];
      assign lrat_entry7_xbitmask_d[1] = ((lrat_entry7_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256GB) :
                                         lrat_entry7_xbitmask_q[1];
      assign lrat_entry7_xbitmask_d[2] = ((lrat_entry7_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16GB) :
                                         lrat_entry7_xbitmask_q[2];
      assign lrat_entry7_xbitmask_d[3] = ((lrat_entry7_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_4GB) :
                                         lrat_entry7_xbitmask_q[3];
      assign lrat_entry7_xbitmask_d[4] = ((lrat_entry7_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_1GB) :
                                         lrat_entry7_xbitmask_q[4];
      assign lrat_entry7_xbitmask_d[5] = ((lrat_entry7_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_256MB) :
                                         lrat_entry7_xbitmask_q[5];
      assign lrat_entry7_xbitmask_d[6] = ((lrat_entry7_wren == 1'b1)) ? (lrat_datain_size_q == LRAT_PgSize_16MB) :
                                         lrat_entry7_xbitmask_q[6];
      // power clock gating for entries
      assign lrat_entry_act_d[0:7] = {8{((|(ex5_valid_q) & ex5_atsel_q) | mmucr2_act_override) & xu_mm_ccr2_notlb_b}};
      // these are tag1 phase matchline components

      mmq_tlb_lrat_matchline #(.HAVE_XBIT(1),
                               .NUM_PGSIZES(8),
                               .HAVE_CMPMASK(1))
         matchline_comb0(
         .vdd(vdd),
         .gnd(gnd),
         .addr_in(lrat_tag1_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .addr_enable(addr_enable),
         .entry_size(lrat_entry0_size_q[0:3]),
         .entry_cmpmask(lrat_entry0_cmpmask_q[0:6]),
         .entry_xbit(lrat_entry0_xbit_q),
         .entry_xbitmask(lrat_entry0_xbitmask_q[0:6]),
         .entry_lpn(lrat_entry0_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .entry_lpid(lrat_entry0_lpid_q[0:`LPID_WIDTH - 1]),
         .comp_lpid(lrat_tag1_lpid_q[0:`LPID_WIDTH - 1]),
         .lpid_enable(lpid_enable),
         .entry_v(lrat_entry0_valid_q),

         .match(lrat_tag1_matchline[0]),

         .dbg_addr_match(lrat_entry0_addr_match),

         .dbg_lpid_match(lrat_entry0_lpid_match)
      );

      mmq_tlb_lrat_matchline #(.HAVE_XBIT(1),
                               .NUM_PGSIZES(8),
                               .HAVE_CMPMASK(1))
         matchline_comb1(
         .vdd(vdd),
         .gnd(gnd),
         .addr_in(lrat_tag1_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .addr_enable(addr_enable),
         .entry_size(lrat_entry1_size_q[0:3]),
         .entry_cmpmask(lrat_entry1_cmpmask_q[0:6]),
         .entry_xbit(lrat_entry1_xbit_q),
         .entry_xbitmask(lrat_entry1_xbitmask_q[0:6]),
         .entry_lpn(lrat_entry1_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .entry_lpid(lrat_entry1_lpid_q[0:`LPID_WIDTH - 1]),
         .comp_lpid(lrat_tag1_lpid_q[0:`LPID_WIDTH - 1]),
         .lpid_enable(lpid_enable),
         .entry_v(lrat_entry1_valid_q),

         .match(lrat_tag1_matchline[1]),

         .dbg_addr_match(lrat_entry1_addr_match),

         .dbg_lpid_match(lrat_entry1_lpid_match)
      );

      mmq_tlb_lrat_matchline #(.HAVE_XBIT(1),
                               .NUM_PGSIZES(8),
                               .HAVE_CMPMASK(1))
         matchline_comb2(
         .vdd(vdd),
         .gnd(gnd),
         .addr_in(lrat_tag1_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .addr_enable(addr_enable),
         .entry_size(lrat_entry2_size_q[0:3]),
         .entry_cmpmask(lrat_entry2_cmpmask_q[0:6]),
         .entry_xbit(lrat_entry2_xbit_q),
         .entry_xbitmask(lrat_entry2_xbitmask_q[0:6]),
         .entry_lpn(lrat_entry2_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .entry_lpid(lrat_entry2_lpid_q[0:`LPID_WIDTH - 1]),
         .comp_lpid(lrat_tag1_lpid_q[0:`LPID_WIDTH - 1]),
         .lpid_enable(lpid_enable),
         .entry_v(lrat_entry2_valid_q),

         .match(lrat_tag1_matchline[2]),

         .dbg_addr_match(lrat_entry2_addr_match),

         .dbg_lpid_match(lrat_entry2_lpid_match)
      );

      mmq_tlb_lrat_matchline #(.HAVE_XBIT(1),
                               .NUM_PGSIZES(8),
                               .HAVE_CMPMASK(1))
         matchline_comb3(
         .vdd(vdd),
         .gnd(gnd),
         .addr_in(lrat_tag1_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .addr_enable(addr_enable),
         .entry_size(lrat_entry3_size_q[0:3]),
         .entry_cmpmask(lrat_entry3_cmpmask_q[0:6]),
         .entry_xbit(lrat_entry3_xbit_q),
         .entry_xbitmask(lrat_entry3_xbitmask_q[0:6]),
         .entry_lpn(lrat_entry3_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .entry_lpid(lrat_entry3_lpid_q[0:`LPID_WIDTH - 1]),
         .comp_lpid(lrat_tag1_lpid_q[0:`LPID_WIDTH - 1]),
         .lpid_enable(lpid_enable),
         .entry_v(lrat_entry3_valid_q),

         .match(lrat_tag1_matchline[3]),

         .dbg_addr_match(lrat_entry3_addr_match),

         .dbg_lpid_match(lrat_entry3_lpid_match)
      );

      mmq_tlb_lrat_matchline #(.HAVE_XBIT(1),
                               .NUM_PGSIZES(8),
                               .HAVE_CMPMASK(1))
         matchline_comb4(
         .vdd(vdd),
         .gnd(gnd),
         .addr_in(lrat_tag1_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .addr_enable(addr_enable),
         .entry_size(lrat_entry4_size_q[0:3]),
         .entry_cmpmask(lrat_entry4_cmpmask_q[0:6]),
         .entry_xbit(lrat_entry4_xbit_q),
         .entry_xbitmask(lrat_entry4_xbitmask_q[0:6]),
         .entry_lpn(lrat_entry4_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .entry_lpid(lrat_entry4_lpid_q[0:`LPID_WIDTH - 1]),
         .comp_lpid(lrat_tag1_lpid_q[0:`LPID_WIDTH - 1]),
         .lpid_enable(lpid_enable),
         .entry_v(lrat_entry4_valid_q),

         .match(lrat_tag1_matchline[4]),

         .dbg_addr_match(lrat_entry4_addr_match),

         .dbg_lpid_match(lrat_entry4_lpid_match)
      );

      mmq_tlb_lrat_matchline #(.HAVE_XBIT(1),
                               .NUM_PGSIZES(8),
                               .HAVE_CMPMASK(1))
         matchline_comb5(
         .vdd(vdd),
         .gnd(gnd),
         .addr_in(lrat_tag1_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .addr_enable(addr_enable),
         .entry_size(lrat_entry5_size_q[0:3]),
         .entry_cmpmask(lrat_entry5_cmpmask_q[0:6]),
         .entry_xbit(lrat_entry5_xbit_q),
         .entry_xbitmask(lrat_entry5_xbitmask_q[0:6]),
         .entry_lpn(lrat_entry5_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .entry_lpid(lrat_entry5_lpid_q[0:`LPID_WIDTH - 1]),
         .comp_lpid(lrat_tag1_lpid_q[0:`LPID_WIDTH - 1]),
         .lpid_enable(lpid_enable),
         .entry_v(lrat_entry5_valid_q),

         .match(lrat_tag1_matchline[5]),

         .dbg_addr_match(lrat_entry5_addr_match),

         .dbg_lpid_match(lrat_entry5_lpid_match)
      );

      mmq_tlb_lrat_matchline #(.HAVE_XBIT(1),
                               .NUM_PGSIZES(8),
                               .HAVE_CMPMASK(1))
         matchline_comb6(
         .vdd(vdd),
         .gnd(gnd),
         .addr_in(lrat_tag1_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .addr_enable(addr_enable),
         .entry_size(lrat_entry6_size_q[0:3]),
         .entry_cmpmask(lrat_entry6_cmpmask_q[0:6]),
         .entry_xbit(lrat_entry6_xbit_q),
         .entry_xbitmask(lrat_entry6_xbitmask_q[0:6]),
         .entry_lpn(lrat_entry6_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .entry_lpid(lrat_entry6_lpid_q[0:`LPID_WIDTH - 1]),
         .comp_lpid(lrat_tag1_lpid_q[0:`LPID_WIDTH - 1]),
         .lpid_enable(lpid_enable),
         .entry_v(lrat_entry6_valid_q),

         .match(lrat_tag1_matchline[6]),

         .dbg_addr_match(lrat_entry6_addr_match),

         .dbg_lpid_match(lrat_entry6_lpid_match)
      );

      mmq_tlb_lrat_matchline #(.HAVE_XBIT(1),
                               .NUM_PGSIZES(8),
                               .HAVE_CMPMASK(1))
         matchline_comb7(
         .vdd(vdd),
         .gnd(gnd),
         .addr_in(lrat_tag1_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .addr_enable(addr_enable),
         .entry_size(lrat_entry7_size_q[0:3]),
         .entry_cmpmask(lrat_entry7_cmpmask_q[0:6]),
         .entry_xbit(lrat_entry7_xbit_q),
         .entry_xbitmask(lrat_entry7_xbitmask_q[0:6]),
         .entry_lpn(lrat_entry7_lpn_q[64 - `REAL_ADDR_WIDTH:64 - `LRAT_MINSIZE_LOG2 - 1]),
         .entry_lpid(lrat_entry7_lpid_q[0:`LPID_WIDTH - 1]),
         .comp_lpid(lrat_tag1_lpid_q[0:`LPID_WIDTH - 1]),
         .lpid_enable(lpid_enable),
         .entry_v(lrat_entry7_valid_q),

         .match(lrat_tag1_matchline[7]),

         .dbg_addr_match(lrat_entry7_addr_match),

         .dbg_lpid_match(lrat_entry7_lpid_match)
      );

      //---------------------------------------------------------------------
      // output assignments
      //---------------------------------------------------------------------
      assign lrat_tag3_lpn = lrat_tag3_lpn_q[64 - `REAL_ADDR_WIDTH:51];
      assign lrat_tag3_rpn = lrat_tag3_rpn_q[64 - `REAL_ADDR_WIDTH:51];
      assign lrat_tag3_hit_status = lrat_tag3_hit_status_q;
      assign lrat_tag3_hit_entry = lrat_tag3_hit_entry_q;
      assign lrat_tag4_lpn = lrat_tag4_lpn_q[64 - `REAL_ADDR_WIDTH:51];
      assign lrat_tag4_rpn = lrat_tag4_rpn_q[64 - `REAL_ADDR_WIDTH:51];
      assign lrat_tag4_hit_status = lrat_tag4_hit_status_q;
      assign lrat_tag4_hit_entry = lrat_tag4_hit_entry_q;
      assign lrat_mas0_esel = lrat_tag4_hit_entry_q;
      assign lrat_mas1_v = lrat_mas1_v_q;
      assign lrat_mas1_tsize = lrat_mas1_tsize_q;
      generate
         if (`REAL_ADDR_WIDTH > 32)
         begin : gen64_lrat_mas2_epn
            assign lrat_mas2_epn[0:63 - `REAL_ADDR_WIDTH] = {22{1'b0}};
            assign lrat_mas2_epn[64 - `REAL_ADDR_WIDTH:31] = lrat_mas2_epn_q[64 - `REAL_ADDR_WIDTH:31];
            assign lrat_mas2_epn[32:51] = lrat_mas2_epn_q[32:51];
         end
      endgenerate
      generate
         if (`REAL_ADDR_WIDTH < 33)
         begin : gen32_lrat_mas2_epn
            assign lrat_mas2_epn[0:63 - `REAL_ADDR_WIDTH] = {22{1'b0}};
            assign lrat_mas2_epn[64 - `REAL_ADDR_WIDTH:51] = lrat_mas2_epn_q[64 - `REAL_ADDR_WIDTH:51];
         end
      endgenerate
      assign lrat_mas3_rpnl = lrat_mas3_rpnl_q;
      assign lrat_mas7_rpnu = lrat_mas7_rpnu_q;
      assign lrat_mas8_tlpid = lrat_mas8_tlpid_q;
      assign lrat_mas_tlbre = lrat_mas_tlbre_q;
      assign lrat_mas_tlbsx_hit = lrat_mas_tlbsx_hit_q;
      assign lrat_mas_tlbsx_miss = lrat_mas_tlbsx_miss_q;
      assign lrat_mas_thdid = lrat_mas_thdid_q;
      assign lrat_mmucr3_x = lrat_mmucr3_x_q;
      assign lrat_dbg_tag1_addr_enable = addr_enable;
      assign lrat_dbg_tag2_matchline_q = lrat_tag2_matchline_q;
      assign lrat_dbg_entry0_addr_match = lrat_entry0_addr_match;
      assign lrat_dbg_entry0_lpid_match = lrat_entry0_lpid_match;
      assign lrat_dbg_entry0_entry_v = lrat_entry0_valid_q;
      assign lrat_dbg_entry0_entry_x = lrat_entry0_xbit_q;
      assign lrat_dbg_entry0_size = lrat_entry0_size_q;
      assign lrat_dbg_entry1_addr_match = lrat_entry1_addr_match;
      assign lrat_dbg_entry1_lpid_match = lrat_entry1_lpid_match;
      assign lrat_dbg_entry1_entry_v = lrat_entry1_valid_q;
      assign lrat_dbg_entry1_entry_x = lrat_entry1_xbit_q;
      assign lrat_dbg_entry1_size = lrat_entry1_size_q;
      assign lrat_dbg_entry2_addr_match = lrat_entry2_addr_match;
      assign lrat_dbg_entry2_lpid_match = lrat_entry2_lpid_match;
      assign lrat_dbg_entry2_entry_v = lrat_entry2_valid_q;
      assign lrat_dbg_entry2_entry_x = lrat_entry2_xbit_q;
      assign lrat_dbg_entry2_size = lrat_entry2_size_q;
      assign lrat_dbg_entry3_addr_match = lrat_entry3_addr_match;
      assign lrat_dbg_entry3_lpid_match = lrat_entry3_lpid_match;
      assign lrat_dbg_entry3_entry_v = lrat_entry3_valid_q;
      assign lrat_dbg_entry3_entry_x = lrat_entry3_xbit_q;
      assign lrat_dbg_entry3_size = lrat_entry3_size_q;
      assign lrat_dbg_entry4_addr_match = lrat_entry4_addr_match;
      assign lrat_dbg_entry4_lpid_match = lrat_entry4_lpid_match;
      assign lrat_dbg_entry4_entry_v = lrat_entry4_valid_q;
      assign lrat_dbg_entry4_entry_x = lrat_entry4_xbit_q;
      assign lrat_dbg_entry4_size = lrat_entry4_size_q;
      assign lrat_dbg_entry5_addr_match = lrat_entry5_addr_match;
      assign lrat_dbg_entry5_lpid_match = lrat_entry5_lpid_match;
      assign lrat_dbg_entry5_entry_v = lrat_entry5_valid_q;
      assign lrat_dbg_entry5_entry_x = lrat_entry5_xbit_q;
      assign lrat_dbg_entry5_size = lrat_entry5_size_q;
      assign lrat_dbg_entry6_addr_match = lrat_entry6_addr_match;
      assign lrat_dbg_entry6_lpid_match = lrat_entry6_lpid_match;
      assign lrat_dbg_entry6_entry_v = lrat_entry6_valid_q;
      assign lrat_dbg_entry6_entry_x = lrat_entry6_xbit_q;
      assign lrat_dbg_entry6_size = lrat_entry6_size_q;
      assign lrat_dbg_entry7_addr_match = lrat_entry7_addr_match;
      assign lrat_dbg_entry7_lpid_match = lrat_entry7_lpid_match;
      assign lrat_dbg_entry7_entry_v = lrat_entry7_valid_q;
      assign lrat_dbg_entry7_entry_x = lrat_entry7_xbit_q;
      assign lrat_dbg_entry7_size = lrat_entry7_size_q;
      // unused spare signal assignments
      assign unused_dc[0] = |(lcb_delay_lclkr_dc[1:4]);
      assign unused_dc[1] = |(lcb_mpw1_dc_b[1:4]);
      assign unused_dc[2] = pc_func_sl_force;
      assign unused_dc[3] = pc_func_sl_thold_0_b;
      assign unused_dc[4] = tc_scan_dis_dc_b;
      assign unused_dc[5] = tc_scan_diag_dc;
      assign unused_dc[6] = tc_lbist_en_dc;
      assign unused_dc[7] = |({tlb_tag0_type[0:1], tlb_tag0_type[3:5]});
      assign unused_dc[8] = ex6_ttype_q[0];
`ifdef MM_THREADS2
      assign unused_dc[9] = |(mas2_0_epn[44:45]) | |(mas2_1_epn[44:45]);
      assign unused_dc[10] = |(mas2_0_epn[46:47]) | |(mas2_1_epn[46:47]);
      assign unused_dc[11] = |(mas2_0_epn[48:49]) | |(mas2_1_epn[48:49]);
      assign unused_dc[12] = |(mas2_0_epn[50:51]) | |(mas2_1_epn[50:51]);
`else
      assign unused_dc[9] = |(mas2_0_epn[44:45]);
      assign unused_dc[10] = |(mas2_0_epn[46:47]);
      assign unused_dc[11] = |(mas2_0_epn[48:49]);
      assign unused_dc[12] = |(mas2_0_epn[50:51]);
`endif
      assign unused_dc[13] = ex6_illeg_instr[0];

      generate
         begin : xhdl0
            genvar   tid;
            for (tid = 0; tid <= `THDID_WIDTH - 1; tid = tid + 1)
            begin : lratunused
               if (tid >= `MM_THREADS)
               begin : lrattidNExist
                  assign unused_dc_threads[tid] = tlb_tag0_thdid[tid];
               end
         end
      end
      endgenerate

      //---------------------------------------------------------------------
      // Latches
      //---------------------------------------------------------------------
      // ex4   phase:  valid latches

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_valid_latch(
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
         .scin(siv[ex4_valid_offset:ex4_valid_offset + `MM_THREADS - 1]),
         .scout(sov[ex4_valid_offset:ex4_valid_offset + `MM_THREADS - 1]),
         .din(ex4_valid_d),
         .dout(ex4_valid_q)
      );
      // ex4   phase:  ttype latches

      tri_rlmreg_p #(.WIDTH(`LRAT_TTYPE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex4_ttype_latch(
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
         .scin(siv[ex4_ttype_offset:ex4_ttype_offset + `LRAT_TTYPE_WIDTH - 1]),
         .scout(sov[ex4_ttype_offset:ex4_ttype_offset + `LRAT_TTYPE_WIDTH - 1]),
         .din(ex4_ttype_d),
         .dout(ex4_ttype_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_hv_state_latch(
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
         .scin(siv[ex4_hv_state_offset]),
         .scout(sov[ex4_hv_state_offset]),
         .din(ex4_hv_state_d),
         .dout(ex4_hv_state_q)
      );
      // ex5   phase:  valid latches

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_valid_latch(
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
         .scin(siv[ex5_valid_offset:ex5_valid_offset + `MM_THREADS - 1]),
         .scout(sov[ex5_valid_offset:ex5_valid_offset + `MM_THREADS - 1]),
         .din(ex5_valid_d),
         .dout(ex5_valid_q)
      );
      // ex5   phase:  ttype latches

      tri_rlmreg_p #(.WIDTH(`LRAT_TTYPE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex5_ttype_latch(
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
         .scin(siv[ex5_ttype_offset:ex5_ttype_offset + `LRAT_TTYPE_WIDTH - 1]),
         .scout(sov[ex5_ttype_offset:ex5_ttype_offset + `LRAT_TTYPE_WIDTH - 1]),
         .din(ex5_ttype_d),
         .dout(ex5_ttype_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_hv_state_latch(
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
         .scin(siv[ex5_hv_state_offset]),
         .scout(sov[ex5_hv_state_offset]),
         .din(ex5_hv_state_d),
         .dout(ex5_hv_state_q)
      );
      // ex6   phase:  valid latches

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex6_valid_latch(
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
         .scin(siv[ex6_valid_offset:ex6_valid_offset + `MM_THREADS - 1]),
         .scout(sov[ex6_valid_offset:ex6_valid_offset + `MM_THREADS - 1]),
         .din(ex6_valid_d),
         .dout(ex6_valid_q)
      );
      // ex6   phase:  ttype latches

      tri_rlmreg_p #(.WIDTH(`LRAT_TTYPE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex6_ttype_latch(
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
         .scin(siv[ex6_ttype_offset:ex6_ttype_offset + `LRAT_TTYPE_WIDTH - 1]),
         .scout(sov[ex6_ttype_offset:ex6_ttype_offset + `LRAT_TTYPE_WIDTH - 1]),
         .din(ex6_ttype_d),
         .dout(ex6_ttype_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_hv_state_latch(
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
         .scin(siv[ex6_hv_state_offset]),
         .scout(sov[ex6_hv_state_offset]),
         .din(ex6_hv_state_d),
         .dout(ex6_hv_state_q)
      );
      // ex5   phase:  esel latches

      tri_rlmreg_p #(.WIDTH(`LRAT_NUM_ENTRY_LOG2), .INIT(0), .NEEDS_SRESET(1)) ex5_esel_latch(
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
         .scin(siv[ex5_esel_offset:ex5_esel_offset + `LRAT_NUM_ENTRY_LOG2 - 1]),
         .scout(sov[ex5_esel_offset:ex5_esel_offset + `LRAT_NUM_ENTRY_LOG2 - 1]),
         .din(ex5_esel_d),
         .dout(ex5_esel_q)
      );
      // ex5   phase:  atsel latches

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_atsel_latch(
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
         .scin(siv[ex5_atsel_offset]),
         .scout(sov[ex5_atsel_offset]),
         .din(ex5_atsel_d),
         .dout(ex5_atsel_q)
      );
      // ex5   phase:  hes latches

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_hes_latch(
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
         .scin(siv[ex5_hes_offset]),
         .scout(sov[ex5_hes_offset]),
         .din(ex5_hes_d),
         .dout(ex5_hes_q)
      );
      // ex5   phase:  wq latches

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex5_wq_latch(
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
         .scin(siv[ex5_wq_offset:ex5_wq_offset + 2 - 1]),
         .scout(sov[ex5_wq_offset:ex5_wq_offset + 2 - 1]),
         .din(ex5_wq_d),
         .dout(ex5_wq_q)
      );
      // ex6   phase:  esel latches

      tri_rlmreg_p #(.WIDTH(`LRAT_NUM_ENTRY_LOG2), .INIT(0), .NEEDS_SRESET(1)) ex6_esel_latch(
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
         .scin(siv[ex6_esel_offset:ex6_esel_offset + `LRAT_NUM_ENTRY_LOG2 - 1]),
         .scout(sov[ex6_esel_offset:ex6_esel_offset + `LRAT_NUM_ENTRY_LOG2 - 1]),
         .din(ex6_esel_d),
         .dout(ex6_esel_q)
      );
      // ex6   phase:  atsel latches

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_atsel_latch(
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
         .scin(siv[ex6_atsel_offset]),
         .scout(sov[ex6_atsel_offset]),
         .din(ex6_atsel_d),
         .dout(ex6_atsel_q)
      );
      // ex6   phase:  hes latches

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_hes_latch(
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
         .scin(siv[ex6_hes_offset]),
         .scout(sov[ex6_hes_offset]),
         .din(ex6_hes_d),
         .dout(ex6_hes_q)
      );
      // ex6   phase:  wq latches

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex6_wq_latch(
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
         .scin(siv[ex6_wq_offset:ex6_wq_offset + 2 - 1]),
         .scout(sov[ex6_wq_offset:ex6_wq_offset + 2 - 1]),
         .din(ex6_wq_d),
         .dout(ex6_wq_q)
      );
      // tag1   phase:  logical page number latches

      tri_rlmreg_p #(.WIDTH(`RPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_tag1_lpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[20 + 0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag1_lpn_offset:lrat_tag1_lpn_offset + `RPN_WIDTH - 1]),
         .scout(sov[lrat_tag1_lpn_offset:lrat_tag1_lpn_offset + `RPN_WIDTH - 1]),
         .din(lrat_tag1_lpn_d[64 - `REAL_ADDR_WIDTH:51]),
         .dout(lrat_tag1_lpn_q[64 - `REAL_ADDR_WIDTH:51])
      );
      // tag2   phase:  logical page number latches

      tri_rlmreg_p #(.WIDTH(`RPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_tag2_lpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[20 + 1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag2_lpn_offset:lrat_tag2_lpn_offset + `RPN_WIDTH - 1]),
         .scout(sov[lrat_tag2_lpn_offset:lrat_tag2_lpn_offset + `RPN_WIDTH - 1]),
         .din(lrat_tag2_lpn_d[64 - `REAL_ADDR_WIDTH:51]),
         .dout(lrat_tag2_lpn_q[64 - `REAL_ADDR_WIDTH:51])
      );
      // tag3   phase:  logical page number latches

      tri_rlmreg_p #(.WIDTH(`RPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_tag3_lpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[20 + 2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag3_lpn_offset:lrat_tag3_lpn_offset + `RPN_WIDTH - 1]),
         .scout(sov[lrat_tag3_lpn_offset:lrat_tag3_lpn_offset + `RPN_WIDTH - 1]),
         .din(lrat_tag3_lpn_d[64 - `REAL_ADDR_WIDTH:51]),
         .dout(lrat_tag3_lpn_q[64 - `REAL_ADDR_WIDTH:51])
      );
      // tag4   phase:  logical page number latches

      tri_rlmreg_p #(.WIDTH(`RPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_tag4_lpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[20 + 3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag4_lpn_offset:lrat_tag4_lpn_offset + `RPN_WIDTH - 1]),
         .scout(sov[lrat_tag4_lpn_offset:lrat_tag4_lpn_offset + `RPN_WIDTH - 1]),
         .din(lrat_tag4_lpn_d[64 - `REAL_ADDR_WIDTH:51]),
         .dout(lrat_tag4_lpn_q[64 - `REAL_ADDR_WIDTH:51])
      );
      // tag3   phase:  real page number latches

      tri_rlmreg_p #(.WIDTH(`RPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_tag3_rpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[20 + 2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag3_rpn_offset:lrat_tag3_rpn_offset + `RPN_WIDTH - 1]),
         .scout(sov[lrat_tag3_rpn_offset:lrat_tag3_rpn_offset + `RPN_WIDTH - 1]),
         .din(lrat_tag3_rpn_d[64 - `REAL_ADDR_WIDTH:51]),
         .dout(lrat_tag3_rpn_q[64 - `REAL_ADDR_WIDTH:51])
      );
      // tag4   phase:  real page number latches

      tri_rlmreg_p #(.WIDTH(`RPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_tag4_rpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[20 + 3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag4_rpn_offset:lrat_tag4_rpn_offset + `RPN_WIDTH - 1]),
         .scout(sov[lrat_tag4_rpn_offset:lrat_tag4_rpn_offset + `RPN_WIDTH - 1]),
         .din(lrat_tag4_rpn_d[64 - `REAL_ADDR_WIDTH:51]),
         .dout(lrat_tag4_rpn_q[64 - `REAL_ADDR_WIDTH:51])
      );
      // tag3   phase:  hit status latches

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_tag3_hit_status_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[20 + 2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag3_hit_status_offset:lrat_tag3_hit_status_offset + 4 - 1]),
         .scout(sov[lrat_tag3_hit_status_offset:lrat_tag3_hit_status_offset + 4 - 1]),
         .din(lrat_tag3_hit_status_d),
         .dout(lrat_tag3_hit_status_q)
      );
      // tag3   phase:  hit entry latches

      tri_rlmreg_p #(.WIDTH(`LRAT_NUM_ENTRY_LOG2), .INIT(0), .NEEDS_SRESET(1)) lrat_tag3_hit_entry_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[20 + 2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag3_hit_entry_offset:lrat_tag3_hit_entry_offset + `LRAT_NUM_ENTRY_LOG2 - 1]),
         .scout(sov[lrat_tag3_hit_entry_offset:lrat_tag3_hit_entry_offset + `LRAT_NUM_ENTRY_LOG2 - 1]),
         .din(lrat_tag3_hit_entry_d),
         .dout(lrat_tag3_hit_entry_q)
      );
      // tag4   phase:  hit status latches

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_tag4_hit_status_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[20 + 3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag4_hit_status_offset:lrat_tag4_hit_status_offset + 4 - 1]),
         .scout(sov[lrat_tag4_hit_status_offset:lrat_tag4_hit_status_offset + 4 - 1]),
         .din(lrat_tag4_hit_status_d),
         .dout(lrat_tag4_hit_status_q)
      );
      // tag4   phase:  hit entry latches

      tri_rlmreg_p #(.WIDTH(`LRAT_NUM_ENTRY_LOG2), .INIT(0), .NEEDS_SRESET(1)) lrat_tag4_hit_entry_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[20 + 3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag4_hit_entry_offset:lrat_tag4_hit_entry_offset + `LRAT_NUM_ENTRY_LOG2 - 1]),
         .scout(sov[lrat_tag4_hit_entry_offset:lrat_tag4_hit_entry_offset + `LRAT_NUM_ENTRY_LOG2 - 1]),
         .din(lrat_tag4_hit_entry_d),
         .dout(lrat_tag4_hit_entry_q)
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_tag1_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[20]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag1_lpid_offset:lrat_tag1_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[lrat_tag1_lpid_offset:lrat_tag1_lpid_offset + `LPID_WIDTH - 1]),
         .din(lrat_tag1_lpid_d),
         .dout(lrat_tag1_lpid_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_tag1_size_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[20]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag1_size_offset:lrat_tag1_size_offset + 4 - 1]),
         .scout(sov[lrat_tag1_size_offset:lrat_tag1_size_offset + 4 - 1]),
         .din(lrat_tag1_size_d),
         .dout(lrat_tag1_size_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_tag2_size_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[21]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag2_size_offset:lrat_tag2_size_offset + 4 - 1]),
         .scout(sov[lrat_tag2_size_offset:lrat_tag2_size_offset + 4 - 1]),
         .din(lrat_tag2_size_d),
         .dout(lrat_tag2_size_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_tag2_entry_size_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[21]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag2_entry_size_offset:lrat_tag2_entry_size_offset + 4 - 1]),
         .scout(sov[lrat_tag2_entry_size_offset:lrat_tag2_entry_size_offset + 4 - 1]),
         .din(lrat_tag2_entry_size_d),
         .dout(lrat_tag2_entry_size_q)
      );

      tri_rlmreg_p #(.WIDTH(`LRAT_NUM_ENTRY), .INIT(0), .NEEDS_SRESET(1)) lrat_tag2_matchline_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[21]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_tag2_matchline_offset:lrat_tag2_matchline_offset + `LRAT_NUM_ENTRY - 1]),
         .scout(sov[lrat_tag2_matchline_offset:lrat_tag2_matchline_offset + `LRAT_NUM_ENTRY - 1]),
         .din(lrat_tag2_matchline_d),
         .dout(lrat_tag2_matchline_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) tlb_addr_cap_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[20]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_addr_cap_offset:tlb_addr_cap_offset + 2 - 1]),
         .scout(sov[tlb_addr_cap_offset:tlb_addr_cap_offset + 2 - 1]),
         .din(tlb_addr_cap_d),
         .dout(tlb_addr_cap_q)
      );

      tri_rlmreg_p #(.WIDTH(64), .INIT(0), .NEEDS_SRESET(1)) spare_latch(
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
         .scin(siv[spare_offset:spare_offset + 64 - 1]),
         .scout(sov[spare_offset:spare_offset + 64 - 1]),
         .din(spare_q),
         .dout(spare_q)
      );

      tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) lrat_entry_act_latch(
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
         .scin(siv[lrat_entry_act_offset:lrat_entry_act_offset + 8 - 1]),
         .scout(sov[lrat_entry_act_offset:lrat_entry_act_offset + 8 - 1]),
         .din(lrat_entry_act_d),
         .dout(lrat_entry_act_q)
      );

      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) lrat_mas_act_latch(
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
         .scin(siv[lrat_mas_act_offset:lrat_mas_act_offset + 3 - 1]),
         .scout(sov[lrat_mas_act_offset:lrat_mas_act_offset + 3 - 1]),
         .din(lrat_mas_act_d),
         .dout(lrat_mas_act_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) lrat_datain_act_latch(
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
         .scin(siv[lrat_datain_act_offset:lrat_datain_act_offset + 2 - 1]),
         .scout(sov[lrat_datain_act_offset:lrat_datain_act_offset + 2 - 1]),
         .din(lrat_datain_act_d),
         .dout(lrat_datain_act_q)
      );
      // LRAT entry latches

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry0_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry0_valid_offset]),
         .scout(sov[lrat_entry0_valid_offset]),
         .din(lrat_entry0_valid_d),
         .dout(lrat_entry0_valid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry0_xbit_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry0_xbit_offset]),
         .scout(sov[lrat_entry0_xbit_offset]),
         .din(lrat_entry0_xbit_d),
         .dout(lrat_entry0_xbit_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry0_lpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry0_lpn_offset:lrat_entry0_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry0_lpn_offset:lrat_entry0_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry0_lpn_d),
         .dout(lrat_entry0_lpn_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry0_rpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry0_rpn_offset:lrat_entry0_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry0_rpn_offset:lrat_entry0_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry0_rpn_d),
         .dout(lrat_entry0_rpn_q)
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_entry0_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry0_lpid_offset:lrat_entry0_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[lrat_entry0_lpid_offset:lrat_entry0_lpid_offset + `LPID_WIDTH - 1]),
         .din(lrat_entry0_lpid_d),
         .dout(lrat_entry0_lpid_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_entry0_size_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry0_size_offset:lrat_entry0_size_offset + 4 - 1]),
         .scout(sov[lrat_entry0_size_offset:lrat_entry0_size_offset + 4 - 1]),
         .din(lrat_entry0_size_d),
         .dout(lrat_entry0_size_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry0_cmpmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry0_cmpmask_offset:lrat_entry0_cmpmask_offset + 7 - 1]),
         .scout(sov[lrat_entry0_cmpmask_offset:lrat_entry0_cmpmask_offset + 7 - 1]),
         .din(lrat_entry0_cmpmask_d),
         .dout(lrat_entry0_cmpmask_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry0_xbitmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry0_xbitmask_offset:lrat_entry0_xbitmask_offset + 7 - 1]),
         .scout(sov[lrat_entry0_xbitmask_offset:lrat_entry0_xbitmask_offset + 7 - 1]),
         .din(lrat_entry0_xbitmask_d),
         .dout(lrat_entry0_xbitmask_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry1_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry1_valid_offset]),
         .scout(sov[lrat_entry1_valid_offset]),
         .din(lrat_entry1_valid_d),
         .dout(lrat_entry1_valid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry1_xbit_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry1_xbit_offset]),
         .scout(sov[lrat_entry1_xbit_offset]),
         .din(lrat_entry1_xbit_d),
         .dout(lrat_entry1_xbit_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry1_lpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry1_lpn_offset:lrat_entry1_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry1_lpn_offset:lrat_entry1_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry1_lpn_d),
         .dout(lrat_entry1_lpn_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry1_rpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry1_rpn_offset:lrat_entry1_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry1_rpn_offset:lrat_entry1_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry1_rpn_d),
         .dout(lrat_entry1_rpn_q)
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_entry1_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry1_lpid_offset:lrat_entry1_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[lrat_entry1_lpid_offset:lrat_entry1_lpid_offset + `LPID_WIDTH - 1]),
         .din(lrat_entry1_lpid_d),
         .dout(lrat_entry1_lpid_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_entry1_size_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry1_size_offset:lrat_entry1_size_offset + 4 - 1]),
         .scout(sov[lrat_entry1_size_offset:lrat_entry1_size_offset + 4 - 1]),
         .din(lrat_entry1_size_d),
         .dout(lrat_entry1_size_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry1_cmpmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry1_cmpmask_offset:lrat_entry1_cmpmask_offset + 7 - 1]),
         .scout(sov[lrat_entry1_cmpmask_offset:lrat_entry1_cmpmask_offset + 7 - 1]),
         .din(lrat_entry1_cmpmask_d),
         .dout(lrat_entry1_cmpmask_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry1_xbitmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry1_xbitmask_offset:lrat_entry1_xbitmask_offset + 7 - 1]),
         .scout(sov[lrat_entry1_xbitmask_offset:lrat_entry1_xbitmask_offset + 7 - 1]),
         .din(lrat_entry1_xbitmask_d),
         .dout(lrat_entry1_xbitmask_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry2_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry2_valid_offset]),
         .scout(sov[lrat_entry2_valid_offset]),
         .din(lrat_entry2_valid_d),
         .dout(lrat_entry2_valid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry2_xbit_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry2_xbit_offset]),
         .scout(sov[lrat_entry2_xbit_offset]),
         .din(lrat_entry2_xbit_d),
         .dout(lrat_entry2_xbit_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry2_lpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry2_lpn_offset:lrat_entry2_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry2_lpn_offset:lrat_entry2_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry2_lpn_d),
         .dout(lrat_entry2_lpn_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry2_rpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry2_rpn_offset:lrat_entry2_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry2_rpn_offset:lrat_entry2_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry2_rpn_d),
         .dout(lrat_entry2_rpn_q)
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_entry2_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry2_lpid_offset:lrat_entry2_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[lrat_entry2_lpid_offset:lrat_entry2_lpid_offset + `LPID_WIDTH - 1]),
         .din(lrat_entry2_lpid_d),
         .dout(lrat_entry2_lpid_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_entry2_size_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry2_size_offset:lrat_entry2_size_offset + 4 - 1]),
         .scout(sov[lrat_entry2_size_offset:lrat_entry2_size_offset + 4 - 1]),
         .din(lrat_entry2_size_d),
         .dout(lrat_entry2_size_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry2_cmpmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry2_cmpmask_offset:lrat_entry2_cmpmask_offset + 7 - 1]),
         .scout(sov[lrat_entry2_cmpmask_offset:lrat_entry2_cmpmask_offset + 7 - 1]),
         .din(lrat_entry2_cmpmask_d),
         .dout(lrat_entry2_cmpmask_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry2_xbitmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry2_xbitmask_offset:lrat_entry2_xbitmask_offset + 7 - 1]),
         .scout(sov[lrat_entry2_xbitmask_offset:lrat_entry2_xbitmask_offset + 7 - 1]),
         .din(lrat_entry2_xbitmask_d),
         .dout(lrat_entry2_xbitmask_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry3_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry3_valid_offset]),
         .scout(sov[lrat_entry3_valid_offset]),
         .din(lrat_entry3_valid_d),
         .dout(lrat_entry3_valid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry3_xbit_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry3_xbit_offset]),
         .scout(sov[lrat_entry3_xbit_offset]),
         .din(lrat_entry3_xbit_d),
         .dout(lrat_entry3_xbit_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry3_lpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry3_lpn_offset:lrat_entry3_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry3_lpn_offset:lrat_entry3_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry3_lpn_d),
         .dout(lrat_entry3_lpn_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry3_rpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry3_rpn_offset:lrat_entry3_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry3_rpn_offset:lrat_entry3_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry3_rpn_d),
         .dout(lrat_entry3_rpn_q)
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_entry3_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry3_lpid_offset:lrat_entry3_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[lrat_entry3_lpid_offset:lrat_entry3_lpid_offset + `LPID_WIDTH - 1]),
         .din(lrat_entry3_lpid_d),
         .dout(lrat_entry3_lpid_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_entry3_size_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry3_size_offset:lrat_entry3_size_offset + 4 - 1]),
         .scout(sov[lrat_entry3_size_offset:lrat_entry3_size_offset + 4 - 1]),
         .din(lrat_entry3_size_d),
         .dout(lrat_entry3_size_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry3_cmpmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry3_cmpmask_offset:lrat_entry3_cmpmask_offset + 7 - 1]),
         .scout(sov[lrat_entry3_cmpmask_offset:lrat_entry3_cmpmask_offset + 7 - 1]),
         .din(lrat_entry3_cmpmask_d),
         .dout(lrat_entry3_cmpmask_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry3_xbitmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry3_xbitmask_offset:lrat_entry3_xbitmask_offset + 7 - 1]),
         .scout(sov[lrat_entry3_xbitmask_offset:lrat_entry3_xbitmask_offset + 7 - 1]),
         .din(lrat_entry3_xbitmask_d),
         .dout(lrat_entry3_xbitmask_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry4_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry4_valid_offset]),
         .scout(sov[lrat_entry4_valid_offset]),
         .din(lrat_entry4_valid_d),
         .dout(lrat_entry4_valid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry4_xbit_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry4_xbit_offset]),
         .scout(sov[lrat_entry4_xbit_offset]),
         .din(lrat_entry4_xbit_d),
         .dout(lrat_entry4_xbit_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry4_lpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry4_lpn_offset:lrat_entry4_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry4_lpn_offset:lrat_entry4_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry4_lpn_d),
         .dout(lrat_entry4_lpn_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry4_rpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry4_rpn_offset:lrat_entry4_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry4_rpn_offset:lrat_entry4_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry4_rpn_d),
         .dout(lrat_entry4_rpn_q)
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_entry4_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry4_lpid_offset:lrat_entry4_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[lrat_entry4_lpid_offset:lrat_entry4_lpid_offset + `LPID_WIDTH - 1]),
         .din(lrat_entry4_lpid_d),
         .dout(lrat_entry4_lpid_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_entry4_size_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry4_size_offset:lrat_entry4_size_offset + 4 - 1]),
         .scout(sov[lrat_entry4_size_offset:lrat_entry4_size_offset + 4 - 1]),
         .din(lrat_entry4_size_d),
         .dout(lrat_entry4_size_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry4_cmpmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry4_cmpmask_offset:lrat_entry4_cmpmask_offset + 7 - 1]),
         .scout(sov[lrat_entry4_cmpmask_offset:lrat_entry4_cmpmask_offset + 7 - 1]),
         .din(lrat_entry4_cmpmask_d),
         .dout(lrat_entry4_cmpmask_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry4_xbitmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry4_xbitmask_offset:lrat_entry4_xbitmask_offset + 7 - 1]),
         .scout(sov[lrat_entry4_xbitmask_offset:lrat_entry4_xbitmask_offset + 7 - 1]),
         .din(lrat_entry4_xbitmask_d),
         .dout(lrat_entry4_xbitmask_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry5_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[5]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry5_valid_offset]),
         .scout(sov[lrat_entry5_valid_offset]),
         .din(lrat_entry5_valid_d),
         .dout(lrat_entry5_valid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry5_xbit_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[5]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry5_xbit_offset]),
         .scout(sov[lrat_entry5_xbit_offset]),
         .din(lrat_entry5_xbit_d),
         .dout(lrat_entry5_xbit_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry5_lpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[5]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry5_lpn_offset:lrat_entry5_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry5_lpn_offset:lrat_entry5_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry5_lpn_d),
         .dout(lrat_entry5_lpn_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry5_rpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[5]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry5_rpn_offset:lrat_entry5_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry5_rpn_offset:lrat_entry5_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry5_rpn_d),
         .dout(lrat_entry5_rpn_q)
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_entry5_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[5]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry5_lpid_offset:lrat_entry5_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[lrat_entry5_lpid_offset:lrat_entry5_lpid_offset + `LPID_WIDTH - 1]),
         .din(lrat_entry5_lpid_d),
         .dout(lrat_entry5_lpid_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_entry5_size_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[5]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry5_size_offset:lrat_entry5_size_offset + 4 - 1]),
         .scout(sov[lrat_entry5_size_offset:lrat_entry5_size_offset + 4 - 1]),
         .din(lrat_entry5_size_d),
         .dout(lrat_entry5_size_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry5_cmpmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[5]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry5_cmpmask_offset:lrat_entry5_cmpmask_offset + 7 - 1]),
         .scout(sov[lrat_entry5_cmpmask_offset:lrat_entry5_cmpmask_offset + 7 - 1]),
         .din(lrat_entry5_cmpmask_d),
         .dout(lrat_entry5_cmpmask_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry5_xbitmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[5]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry5_xbitmask_offset:lrat_entry5_xbitmask_offset + 7 - 1]),
         .scout(sov[lrat_entry5_xbitmask_offset:lrat_entry5_xbitmask_offset + 7 - 1]),
         .din(lrat_entry5_xbitmask_d),
         .dout(lrat_entry5_xbitmask_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry6_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[6]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry6_valid_offset]),
         .scout(sov[lrat_entry6_valid_offset]),
         .din(lrat_entry6_valid_d),
         .dout(lrat_entry6_valid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry6_xbit_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[6]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry6_xbit_offset]),
         .scout(sov[lrat_entry6_xbit_offset]),
         .din(lrat_entry6_xbit_d),
         .dout(lrat_entry6_xbit_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry6_lpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[6]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry6_lpn_offset:lrat_entry6_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry6_lpn_offset:lrat_entry6_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry6_lpn_d),
         .dout(lrat_entry6_lpn_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry6_rpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[6]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry6_rpn_offset:lrat_entry6_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry6_rpn_offset:lrat_entry6_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry6_rpn_d),
         .dout(lrat_entry6_rpn_q)
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_entry6_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[6]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry6_lpid_offset:lrat_entry6_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[lrat_entry6_lpid_offset:lrat_entry6_lpid_offset + `LPID_WIDTH - 1]),
         .din(lrat_entry6_lpid_d),
         .dout(lrat_entry6_lpid_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_entry6_size_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[6]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry6_size_offset:lrat_entry6_size_offset + 4 - 1]),
         .scout(sov[lrat_entry6_size_offset:lrat_entry6_size_offset + 4 - 1]),
         .din(lrat_entry6_size_d),
         .dout(lrat_entry6_size_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry6_cmpmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[6]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry6_cmpmask_offset:lrat_entry6_cmpmask_offset + 7 - 1]),
         .scout(sov[lrat_entry6_cmpmask_offset:lrat_entry6_cmpmask_offset + 7 - 1]),
         .din(lrat_entry6_cmpmask_d),
         .dout(lrat_entry6_cmpmask_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry6_xbitmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[6]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry6_xbitmask_offset:lrat_entry6_xbitmask_offset + 7 - 1]),
         .scout(sov[lrat_entry6_xbitmask_offset:lrat_entry6_xbitmask_offset + 7 - 1]),
         .din(lrat_entry6_xbitmask_d),
         .dout(lrat_entry6_xbitmask_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry7_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[7]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry7_valid_offset]),
         .scout(sov[lrat_entry7_valid_offset]),
         .din(lrat_entry7_valid_d),
         .dout(lrat_entry7_valid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_entry7_xbit_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[7]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry7_xbit_offset]),
         .scout(sov[lrat_entry7_xbit_offset]),
         .din(lrat_entry7_xbit_d),
         .dout(lrat_entry7_xbit_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry7_lpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[7]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry7_lpn_offset:lrat_entry7_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry7_lpn_offset:lrat_entry7_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry7_lpn_d),
         .dout(lrat_entry7_lpn_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_entry7_rpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[7]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry7_rpn_offset:lrat_entry7_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_entry7_rpn_offset:lrat_entry7_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_entry7_rpn_d),
         .dout(lrat_entry7_rpn_q)
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_entry7_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[7]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry7_lpid_offset:lrat_entry7_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[lrat_entry7_lpid_offset:lrat_entry7_lpid_offset + `LPID_WIDTH - 1]),
         .din(lrat_entry7_lpid_d),
         .dout(lrat_entry7_lpid_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_entry7_size_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[7]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry7_size_offset:lrat_entry7_size_offset + 4 - 1]),
         .scout(sov[lrat_entry7_size_offset:lrat_entry7_size_offset + 4 - 1]),
         .din(lrat_entry7_size_d),
         .dout(lrat_entry7_size_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry7_cmpmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[7]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry7_cmpmask_offset:lrat_entry7_cmpmask_offset + 7 - 1]),
         .scout(sov[lrat_entry7_cmpmask_offset:lrat_entry7_cmpmask_offset + 7 - 1]),
         .din(lrat_entry7_cmpmask_d),
         .dout(lrat_entry7_cmpmask_q)
      );

      tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lrat_entry7_xbitmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_entry_act_q[7]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_entry7_xbitmask_offset:lrat_entry7_xbitmask_offset + 7 - 1]),
         .scout(sov[lrat_entry7_xbitmask_offset:lrat_entry7_xbitmask_offset + 7 - 1]),
         .din(lrat_entry7_xbitmask_d),
         .dout(lrat_entry7_xbitmask_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_datain_lpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_datain_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_datain_lpn_offset:lrat_datain_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_datain_lpn_offset:lrat_datain_lpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_datain_lpn_d),
         .dout(lrat_datain_lpn_q)
      );

      tri_rlmreg_p #(.WIDTH((64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) lrat_datain_rpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_datain_act_q[1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_datain_rpn_offset:lrat_datain_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .scout(sov[lrat_datain_rpn_offset:lrat_datain_rpn_offset + (64-`LRAT_MINSIZE_LOG2-1-(64-`REAL_ADDR_WIDTH)+1) - 1]),
         .din(lrat_datain_rpn_d),
         .dout(lrat_datain_rpn_q)
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_datain_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_datain_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_datain_lpid_offset:lrat_datain_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[lrat_datain_lpid_offset:lrat_datain_lpid_offset + `LPID_WIDTH - 1]),
         .din(lrat_datain_lpid_d),
         .dout(lrat_datain_lpid_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_datain_size_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_datain_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_datain_size_offset:lrat_datain_size_offset + 4 - 1]),
         .scout(sov[lrat_datain_size_offset:lrat_datain_size_offset + 4 - 1]),
         .din(lrat_datain_size_d),
         .dout(lrat_datain_size_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_datain_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_datain_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_datain_valid_offset]),
         .scout(sov[lrat_datain_valid_offset]),
         .din(lrat_datain_valid_d),
         .dout(lrat_datain_valid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_datain_xbit_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_datain_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_datain_xbit_offset]),
         .scout(sov[lrat_datain_xbit_offset]),
         .din(lrat_datain_xbit_d),
         .dout(lrat_datain_xbit_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_mas1_v_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_mas_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_mas1_v_offset]),
         .scout(sov[lrat_mas1_v_offset]),
         .din(lrat_mas1_v_d),
         .dout(lrat_mas1_v_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_mmucr3_x_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_mas_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_mmucr3_x_offset]),
         .scout(sov[lrat_mmucr3_x_offset]),
         .din(lrat_mmucr3_x_d),
         .dout(lrat_mmucr3_x_q)
      );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lrat_mas1_tsize_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_mas_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_mas1_tsize_offset:lrat_mas1_tsize_offset + 4 - 1]),
         .scout(sov[lrat_mas1_tsize_offset:lrat_mas1_tsize_offset + 4 - 1]),
         .din(lrat_mas1_tsize_d),
         .dout(lrat_mas1_tsize_q)
      );

      tri_rlmreg_p #(.WIDTH(`RPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_mas2_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_mas_act_q[0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_mas2_epn_offset:lrat_mas2_epn_offset + `RPN_WIDTH - 1]),
         .scout(sov[lrat_mas2_epn_offset:lrat_mas2_epn_offset + `RPN_WIDTH - 1]),
         .din(lrat_mas2_epn_d),
         .dout(lrat_mas2_epn_q)
      );

      tri_rlmreg_p #(.WIDTH(20), .INIT(0), .NEEDS_SRESET(1)) lrat_mas3_rpnl_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_mas_act_q[1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_mas3_rpnl_offset:lrat_mas3_rpnl_offset + 20 - 1]),
         .scout(sov[lrat_mas3_rpnl_offset:lrat_mas3_rpnl_offset + 20 - 1]),
         .din(lrat_mas3_rpnl_d),
         .dout(lrat_mas3_rpnl_q)
      );

      tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) lrat_mas7_rpnu_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_mas_act_q[1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_mas7_rpnu_offset:lrat_mas7_rpnu_offset + 10 - 1]),
         .scout(sov[lrat_mas7_rpnu_offset:lrat_mas7_rpnu_offset + 10 - 1]),
         .din(lrat_mas7_rpnu_d),
         .dout(lrat_mas7_rpnu_q)
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lrat_mas8_tlpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_mas_act_q[1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_mas8_tlpid_offset:lrat_mas8_tlpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[lrat_mas8_tlpid_offset:lrat_mas8_tlpid_offset + `LPID_WIDTH - 1]),
         .din(lrat_mas8_tlpid_d),
         .dout(lrat_mas8_tlpid_q)
      );

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) lrat_mas_thdid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_mas_act_q[2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_mas_thdid_offset:lrat_mas_thdid_offset + `MM_THREADS - 1]),
         .scout(sov[lrat_mas_thdid_offset:lrat_mas_thdid_offset + `MM_THREADS - 1]),
         .din(lrat_mas_thdid_d),
         .dout(lrat_mas_thdid_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_mas_tlbre_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_mas_act_q[2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_mas_tlbre_offset]),
         .scout(sov[lrat_mas_tlbre_offset]),
         .din(lrat_mas_tlbre_d),
         .dout(lrat_mas_tlbre_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_mas_tlbsx_hit_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_mas_act_q[2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_mas_tlbsx_hit_offset]),
         .scout(sov[lrat_mas_tlbsx_hit_offset]),
         .din(lrat_mas_tlbsx_hit_d),
         .dout(lrat_mas_tlbsx_hit_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lrat_mas_tlbsx_miss_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(lrat_mas_act_q[2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[lrat_mas_tlbsx_miss_offset]),
         .scout(sov[lrat_mas_tlbsx_miss_offset]),
         .din(lrat_mas_tlbsx_miss_d),
         .dout(lrat_mas_tlbsx_miss_q)
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
