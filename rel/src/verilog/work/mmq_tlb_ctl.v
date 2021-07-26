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
//* TITLE: Memory Management Unit TLB Central Control Logic
//* NAME: mmq_tlb_ctl.v
//*********************************************************************


`timescale 1 ns / 1 ns

`include "tri_a2o.vh"
`include "mmu_a2o.vh"
`define CTL_TTYPE_WIDTH  5
`define CTL_STATE_WIDTH  4

module mmq_tlb_ctl(
   inout                          vdd,
   inout                          gnd,
   (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]        nclk,

   input                          tc_ccflush_dc,
   input                          tc_scan_dis_dc_b,
   input                          tc_scan_diag_dc,
   input                          tc_lbist_en_dc,
   input                          lcb_d_mode_dc,
   input                          lcb_clkoff_dc_b,
   input                          lcb_act_dis_dc,
   input [0:4]                    lcb_mpw1_dc_b,
   input                          lcb_mpw2_dc_b,
   input [0:4]                    lcb_delay_lclkr_dc,

   input                          pc_sg_2,
   input                          pc_func_sl_thold_2,
   input                          pc_func_slp_sl_thold_2,
   input                          pc_func_slp_nsl_thold_2,
   input                          pc_fce_2,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                          ac_func_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                         ac_func_scan_out,

   input [0:`MM_THREADS-1]        xu_mm_rf1_val,
   input                          xu_mm_rf1_is_tlbre,
   input                          xu_mm_rf1_is_tlbwe,
   input                          xu_mm_rf1_is_tlbsx,
   input                          xu_mm_rf1_is_tlbsxr,
   input                          xu_mm_rf1_is_tlbsrx,
   input [64-`RS_DATA_WIDTH:51]   xu_mm_ex2_epn,
   input [0:`ITAG_SIZE_ENC-1]     xu_mm_rf1_itag,
   input [0:`MM_THREADS-1]        xu_mm_msr_gs,
   input [0:`MM_THREADS-1]        xu_mm_msr_pr,
   input [0:`MM_THREADS-1]        xu_mm_msr_is,
   input [0:`MM_THREADS-1]        xu_mm_msr_ds,
   input [0:`MM_THREADS-1]        xu_mm_msr_cm,
   input                          xu_mm_ccr2_notlb_b,
   input [0:`MM_THREADS-1]        xu_mm_epcr_dgtmi,
   input                          xu_mm_xucr4_mmu_mchk,
   output                         xu_mm_xucr4_mmu_mchk_q,

   input [0:`MM_THREADS-1]        xu_rf1_flush,
   input [0:`MM_THREADS-1]        xu_ex1_flush,
   input [0:`MM_THREADS-1]        xu_ex2_flush,
   input [0:`MM_THREADS-1]        xu_ex3_flush,
   input [0:`MM_THREADS-1]        xu_ex4_flush,
   input [0:`MM_THREADS-1]        xu_ex5_flush,

   output [0:`MM_THREADS-1]       tlb_ctl_ex3_valid,
   output [0:`CTL_TTYPE_WIDTH-1]  tlb_ctl_ex3_ttype,
   output                         tlb_ctl_ex3_hv_state,
   output [0:`MM_THREADS-1]       tlb_ctl_tag2_flush,
   output [0:`MM_THREADS-1]       tlb_ctl_tag3_flush,
   output [0:`MM_THREADS-1]       tlb_ctl_tag4_flush,

   input [0:`MM_THREADS-1]        mm_xu_eratmiss_done,
   input [0:`MM_THREADS-1]        mm_xu_tlb_miss,
   input [0:`MM_THREADS-1]        mm_xu_tlb_inelig,
   output [0:`MM_THREADS-1]       tlb_resv_match_vec,
   output [0:`MM_THREADS-1]       tlb_ctl_barrier_done,
   output [0:`MM_THREADS-1]       tlb_ctl_ex2_flush_req,

   output [0:`ITAG_SIZE_ENC-1]    tlb_ctl_ex2_itag,
   output [0:2]                   tlb_ctl_ord_type,

   output [0:`MM_THREADS-1]       tlb_ctl_quiesce,
   output [0:`MM_THREADS-1]       tlb_ctl_ex2_illeg_instr,
   output [0:`MM_THREADS-1]       tlb_ctl_ex6_illeg_instr,
   output [0:1]                   ex6_illeg_instr,        // constant width, bad tlbre/we op indication to tlb_cmp

   input                          tlbwe_back_inv_pending,
   input                          mmucr1_tlbi_msb,
   input                          mmucr1_tlbwe_binv,
   input [0:`MMUCR2_WIDTH-1]      mmucr2,
   input [64-`MMUCR3_WIDTH:63]    mmucr3_0,
   input [0:`PID_WIDTH-1]         pid0,
`ifdef MM_THREADS2
   input [0:`PID_WIDTH-1]         pid1,
   input [64-`MMUCR3_WIDTH:63]    mmucr3_1,
`endif
   input [0:`LPID_WIDTH-1]        lpidr,
   input                          mmucfg_lrat,
   input                          mmucfg_twc,
   input                          tlb0cfg_pt,
   input                          tlb0cfg_ind,
   input                          tlb0cfg_gtwe,
   input                          mmucsr0_tlb0fi,
   input                          mas0_0_atsel,
   input [0:2]                    mas0_0_esel,
   input                          mas0_0_hes,
   input [0:1]                    mas0_0_wq,
   input                          mas1_0_v,
   input                          mas1_0_iprot,
   input [0:13]                   mas1_0_tid,
   input                          mas1_0_ind,
   input                          mas1_0_ts,
   input [0:3]                    mas1_0_tsize,
   input [0:51]                   mas2_0_epn,
   input [0:4]                    mas2_0_wimge,
   input [0:3]                    mas3_0_usxwr,
   input                          mas5_0_sgs,
   input [0:7]                    mas5_0_slpid,
   input [0:13]                   mas6_0_spid,
   input                          mas6_0_sind,
   input                          mas6_0_sas,
   input                          mas8_0_tgs,
   input [0:7]                    mas8_0_tlpid,
`ifdef MM_THREADS2
   input                          mas0_1_atsel,
   input [0:2]                    mas0_1_esel,
   input                          mas0_1_hes,
   input [0:1]                    mas0_1_wq,
   input                          mas1_1_v,
   input                          mas1_1_iprot,
   input [0:13]                   mas1_1_tid,
   input                          mas1_1_ind,
   input                          mas1_1_ts,
   input [0:3]                    mas1_1_tsize,
   input [0:51]                   mas2_1_epn,
   input [0:4]                    mas2_1_wimge,
   input [0:3]                    mas3_1_usxwr,
   input                          mas5_1_sgs,
   input [0:7]                    mas5_1_slpid,
   input [0:13]                   mas6_1_spid,
   input                          mas6_1_sind,
   input                          mas6_1_sas,
   input                          mas8_1_tgs,
   input [0:7]                    mas8_1_tlpid,
`endif
   input                          tlb_seq_ierat_req,
   input                          tlb_seq_derat_req,
   output                         tlb_seq_ierat_done,
   output                         tlb_seq_derat_done,
   output                         tlb_seq_idle,
   output                         ierat_req_taken,
   output                         derat_req_taken,
   input [0:`EPN_WIDTH-1]         ierat_req_epn,
   input [0:`PID_WIDTH-1]         ierat_req_pid,
   input [0:`CTL_STATE_WIDTH-1]   ierat_req_state,
   input [0:`THDID_WIDTH-1]       ierat_req_thdid,
   input [0:1]                    ierat_req_dup,
   input                          ierat_req_nonspec,
   input [0:`EPN_WIDTH-1]         derat_req_epn,
   input [0:`PID_WIDTH-1]         derat_req_pid,
   input [0:`LPID_WIDTH-1]        derat_req_lpid,
   input [0:`CTL_STATE_WIDTH-1]   derat_req_state,
   input [0:1]                    derat_req_ttype,
   input [0:`THDID_WIDTH-1]       derat_req_thdid,
   input [0:1]                    derat_req_dup,
   input [0:`ITAG_SIZE_ENC-1]     derat_req_itag,
   input [0:`EMQ_ENTRIES-1]       derat_req_emq,
   input                          derat_req_nonspec,
   input                          ptereload_req_valid,
   input [0:`TLB_TAG_WIDTH-1]     ptereload_req_tag,
   input [0:`PTE_WIDTH-1]         ptereload_req_pte,
   output                         ptereload_req_taken,
   input                          tlb_snoop_coming,
   input                          tlb_snoop_val,
   input [0:34]                   tlb_snoop_attr,
   input [52-`EPN_WIDTH:51]       tlb_snoop_vpn,
   output                         tlb_snoop_ack,
   output [0:`TLB_ADDR_WIDTH-1]   lru_rd_addr,
   input [0:15]                   lru_tag4_dataout,
   input [0:`TLB_ADDR_WIDTH-1]    tlb_addr4,
   input [0:2]                    tlb_tag4_esel,
   input [0:1]                    tlb_tag4_wq,
   input [0:1]                    tlb_tag4_is,
   input                          tlb_tag4_gs,
   input                          tlb_tag4_pr,
   input                          tlb_tag4_hes,
   input                          tlb_tag4_atsel,
   input                          tlb_tag4_pt,
   input                          tlb_tag4_cmp_hit,
   input                          tlb_tag4_way_ind,
   input                          tlb_tag4_ptereload,
   input                          tlb_tag4_endflag,
   input                          tlb_tag4_parerr,
   input [0:`TLB_WAYS-1]          tlb_tag4_parerr_write,
   input                          tlb_tag5_parerr_zeroize,
   input [0:`MM_THREADS-1]        tlb_tag5_except,
   input [0:1]                    tlb_cmp_erat_dup_wait,
   output [52-`EPN_WIDTH:51]      tlb_tag0_epn,
   output [0:`THDID_WIDTH-1]      tlb_tag0_thdid,
   output [0:7]                   tlb_tag0_type,
   output [0:`LPID_WIDTH-1]       tlb_tag0_lpid,
   output                         tlb_tag0_atsel,
   output [0:3]                   tlb_tag0_size,
   output                         tlb_tag0_addr_cap,
   output                         tlb_tag0_nonspec,
   output [0:`TLB_TAG_WIDTH-1]    tlb_tag2,
   output [0:`TLB_ADDR_WIDTH-1]   tlb_addr2,
   output                         tlb_ctl_perf_tlbwec_resv,
   output                         tlb_ctl_perf_tlbwec_noresv,
   input [0:3]                    lrat_tag4_hit_status,

   output [64-`REAL_ADDR_WIDTH:51] tlb_lper_lpn,
   output [60:63]                  tlb_lper_lps,
   output [0:`MM_THREADS-1]        tlb_lper_we,
   output [0:`PTE_WIDTH-1]         ptereload_req_pte_lat,
   output [64-`REAL_ADDR_WIDTH:51] pte_tag0_lpn,
   output [0:`LPID_WIDTH-1]        pte_tag0_lpid,
   output [0:`TLB_WAYS-1]          tlb_write,
   output [0:`TLB_ADDR_WIDTH-1]    tlb_addr,
   output                          tlb_tag5_write,
   output [9:33]                   tlb_delayed_act,

   output [0:5]                   tlb_ctl_dbg_seq_q,
   output                         tlb_ctl_dbg_seq_idle,
   output                         tlb_ctl_dbg_seq_any_done_sig,
   output                         tlb_ctl_dbg_seq_abort,
   output                         tlb_ctl_dbg_any_tlb_req_sig,
   output                         tlb_ctl_dbg_any_req_taken_sig,
   output [0:3]                   tlb_ctl_dbg_tag5_tlb_write_q,
   output                         tlb_ctl_dbg_tag0_valid,
   output [0:1]                   tlb_ctl_dbg_tag0_thdid,    // encoded
   output [0:2]                   tlb_ctl_dbg_tag0_type,     // encoded
   output [0:1]                   tlb_ctl_dbg_tag0_wq,
   output                         tlb_ctl_dbg_tag0_gs,
   output                         tlb_ctl_dbg_tag0_pr,
   output                         tlb_ctl_dbg_tag0_atsel,
   output [0:3]                   tlb_ctl_dbg_resv_valid,
   output [0:3]                   tlb_ctl_dbg_set_resv,
   output [0:3]                   tlb_ctl_dbg_resv_match_vec_q,
   output                         tlb_ctl_dbg_any_tag_flush_sig,
   output                         tlb_ctl_dbg_resv0_tag0_lpid_match,
   output                         tlb_ctl_dbg_resv0_tag0_pid_match,
   output                         tlb_ctl_dbg_resv0_tag0_as_snoop_match,
   output                         tlb_ctl_dbg_resv0_tag0_gs_snoop_match,
   output                         tlb_ctl_dbg_resv0_tag0_as_tlbwe_match,
   output                         tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match,
   output                         tlb_ctl_dbg_resv0_tag0_ind_match,
   output                         tlb_ctl_dbg_resv0_tag0_epn_loc_match,
   output                         tlb_ctl_dbg_resv0_tag0_epn_glob_match,
   output                         tlb_ctl_dbg_resv0_tag0_class_match,
   output                         tlb_ctl_dbg_resv1_tag0_lpid_match,
   output                         tlb_ctl_dbg_resv1_tag0_pid_match,
   output                         tlb_ctl_dbg_resv1_tag0_as_snoop_match,
   output                         tlb_ctl_dbg_resv1_tag0_gs_snoop_match,
   output                         tlb_ctl_dbg_resv1_tag0_as_tlbwe_match,
   output                         tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match,
   output                         tlb_ctl_dbg_resv1_tag0_ind_match,
   output                         tlb_ctl_dbg_resv1_tag0_epn_loc_match,
   output                         tlb_ctl_dbg_resv1_tag0_epn_glob_match,
   output                         tlb_ctl_dbg_resv1_tag0_class_match,
   output                         tlb_ctl_dbg_resv2_tag0_lpid_match,
   output                         tlb_ctl_dbg_resv2_tag0_pid_match,
   output                         tlb_ctl_dbg_resv2_tag0_as_snoop_match,
   output                         tlb_ctl_dbg_resv2_tag0_gs_snoop_match,
   output                         tlb_ctl_dbg_resv2_tag0_as_tlbwe_match,
   output                         tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match,
   output                         tlb_ctl_dbg_resv2_tag0_ind_match,
   output                         tlb_ctl_dbg_resv2_tag0_epn_loc_match,
   output                         tlb_ctl_dbg_resv2_tag0_epn_glob_match,
   output                         tlb_ctl_dbg_resv2_tag0_class_match,
   output                         tlb_ctl_dbg_resv3_tag0_lpid_match,
   output                         tlb_ctl_dbg_resv3_tag0_pid_match,
   output                         tlb_ctl_dbg_resv3_tag0_as_snoop_match,
   output                         tlb_ctl_dbg_resv3_tag0_gs_snoop_match,
   output                         tlb_ctl_dbg_resv3_tag0_as_tlbwe_match,
   output                         tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match,
   output                         tlb_ctl_dbg_resv3_tag0_ind_match,
   output                         tlb_ctl_dbg_resv3_tag0_epn_loc_match,
   output                         tlb_ctl_dbg_resv3_tag0_epn_glob_match,
   output                         tlb_ctl_dbg_resv3_tag0_class_match,
   output [0:3]                   tlb_ctl_dbg_clr_resv_q,
   output [0:3]                   tlb_ctl_dbg_clr_resv_terms

);


      parameter                      MMU_Mode_Value = 1'b0;
      parameter [0:1]                TlbSel_Tlb = 2'b00;
      parameter [0:1]                TlbSel_IErat = 2'b10;
      parameter [0:1]                TlbSel_DErat = 2'b11;
      parameter [0:2]                ERAT_PgSize_1GB = 3'b110;
      parameter [0:2]                ERAT_PgSize_16MB = 3'b111;
      parameter [0:2]                ERAT_PgSize_1MB = 3'b101;
      parameter [0:2]                ERAT_PgSize_64KB = 3'b011;
      parameter [0:2]                ERAT_PgSize_4KB = 3'b001;
      parameter [0:3]                TLB_PgSize_1GB = 4'b1010;
      parameter [0:3]                TLB_PgSize_16MB = 4'b0111;
      parameter [0:3]                TLB_PgSize_1MB = 4'b0101;
      parameter [0:3]                TLB_PgSize_64KB = 4'b0011;
      parameter [0:3]                TLB_PgSize_4KB = 4'b0001;
      // reserved for indirect entries
      parameter [0:2]                ERAT_PgSize_256MB = 3'b100;
      parameter [0:3]                TLB_PgSize_256MB = 4'b1001;
      // LRAT page sizes
      parameter [0:3]                LRAT_PgSize_1TB = 4'b1111;
      parameter [0:3]                LRAT_PgSize_256GB = 4'b1110;
      parameter [0:3]                LRAT_PgSize_16GB = 4'b1100;
      parameter [0:3]                LRAT_PgSize_4GB = 4'b1011;
      parameter [0:3]                LRAT_PgSize_1GB = 4'b1010;
      parameter [0:3]                LRAT_PgSize_256MB = 4'b1001;
      parameter [0:3]                LRAT_PgSize_16MB = 4'b0111;
      parameter [0:3]                LRAT_PgSize_1MB = 4'b0101;
      parameter [0:5]                TlbSeq_Idle = 6'b000000;
      parameter [0:5]                TlbSeq_Stg1 = 6'b000001;
      parameter [0:5]                TlbSeq_Stg2 = 6'b000011;
      parameter [0:5]                TlbSeq_Stg3 = 6'b000010;
      parameter [0:5]                TlbSeq_Stg4 = 6'b000110;
      parameter [0:5]                TlbSeq_Stg5 = 6'b000100;
      parameter [0:5]                TlbSeq_Stg6 = 6'b000101;
      parameter [0:5]                TlbSeq_Stg7 = 6'b000111;
      parameter [0:5]                TlbSeq_Stg8 = 6'b001000;
      parameter [0:5]                TlbSeq_Stg9 = 6'b001001;
      parameter [0:5]                TlbSeq_Stg10 = 6'b001011;
      parameter [0:5]                TlbSeq_Stg11 = 6'b001010;
      parameter [0:5]                TlbSeq_Stg12 = 6'b001110;
      parameter [0:5]                TlbSeq_Stg13 = 6'b001100;
      parameter [0:5]                TlbSeq_Stg14 = 6'b001101;
      parameter [0:5]                TlbSeq_Stg15 = 6'b001111;
      parameter [0:5]                TlbSeq_Stg16 = 6'b010000;
      parameter [0:5]                TlbSeq_Stg17 = 6'b010001;
      parameter [0:5]                TlbSeq_Stg18 = 6'b010011;
      parameter [0:5]                TlbSeq_Stg19 = 6'b010010;
      parameter [0:5]                TlbSeq_Stg20 = 6'b010110;
      parameter [0:5]                TlbSeq_Stg21 = 6'b010100;
      parameter [0:5]                TlbSeq_Stg22 = 6'b010101;
      parameter [0:5]                TlbSeq_Stg23 = 6'b010111;
      parameter [0:5]                TlbSeq_Stg24 = 6'b011000;
      parameter [0:5]                TlbSeq_Stg25 = 6'b011001;
      parameter [0:5]                TlbSeq_Stg26 = 6'b011011;
      parameter [0:5]                TlbSeq_Stg27 = 6'b011010;
      parameter [0:5]                TlbSeq_Stg28 = 6'b011110;
      parameter [0:5]                TlbSeq_Stg29 = 6'b011100;
      parameter [0:5]                TlbSeq_Stg30 = 6'b011101;
      parameter [0:5]                TlbSeq_Stg31 = 6'b011111;
      parameter [0:5]                TlbSeq_Stg32 = 6'b100000;


      parameter                      xu_ex1_flush_offset = 0;
      parameter                      ex1_valid_offset = xu_ex1_flush_offset + `MM_THREADS;
      parameter                      ex1_ttype_offset = ex1_valid_offset + `MM_THREADS;
      parameter                      ex1_state_offset = ex1_ttype_offset + `CTL_TTYPE_WIDTH;
      parameter                      ex1_itag_offset = ex1_state_offset + `CTL_STATE_WIDTH + 1;
      parameter                      ex1_pid_offset = ex1_itag_offset + `ITAG_SIZE_ENC;
      parameter                      ex2_valid_offset = ex1_pid_offset + `PID_WIDTH;
      parameter                      ex2_flush_offset = ex2_valid_offset + `MM_THREADS;
      parameter                      ex2_flush_req_offset = ex2_flush_offset + `MM_THREADS;
      parameter                      ex2_ttype_offset = ex2_flush_req_offset + `MM_THREADS;
      parameter                      ex2_state_offset = ex2_ttype_offset + `CTL_TTYPE_WIDTH;
      parameter                      ex2_itag_offset = ex2_state_offset + `CTL_STATE_WIDTH + 1;
      parameter                      ex2_pid_offset = ex2_itag_offset + `ITAG_SIZE_ENC;
      parameter                      ex3_valid_offset = ex2_pid_offset + `PID_WIDTH;
      parameter                      ex3_flush_offset = ex3_valid_offset + `MM_THREADS;
      parameter                      ex3_ttype_offset = ex3_flush_offset + `MM_THREADS;
      parameter                      ex3_state_offset = ex3_ttype_offset + `CTL_TTYPE_WIDTH;
      parameter                      ex3_pid_offset = ex3_state_offset + `CTL_STATE_WIDTH + 1;
      parameter                      ex4_valid_offset = ex3_pid_offset + `PID_WIDTH;
      parameter                      ex4_flush_offset = ex4_valid_offset + `MM_THREADS;
      parameter                      ex4_ttype_offset = ex4_flush_offset + `MM_THREADS;
      parameter                      ex4_state_offset = ex4_ttype_offset + `CTL_TTYPE_WIDTH;
      parameter                      ex4_pid_offset = ex4_state_offset + `CTL_STATE_WIDTH + 1;
      parameter                      ex5_valid_offset = ex4_pid_offset + `PID_WIDTH;
      parameter                      ex5_flush_offset = ex5_valid_offset + `MM_THREADS;
      parameter                      ex5_ttype_offset = ex5_flush_offset + `MM_THREADS;
      parameter                      ex5_state_offset = ex5_ttype_offset + `CTL_TTYPE_WIDTH;
      parameter                      ex5_pid_offset = ex5_state_offset + `CTL_STATE_WIDTH + 1;
      parameter                      ex6_valid_offset = ex5_pid_offset + `PID_WIDTH;
      parameter                      ex6_flush_offset = ex6_valid_offset + `MM_THREADS;
      parameter                      ex6_ttype_offset = ex6_flush_offset + `MM_THREADS;
      parameter                      ex6_state_offset = ex6_ttype_offset + `CTL_TTYPE_WIDTH;
      parameter                      ex6_pid_offset = ex6_state_offset + `CTL_STATE_WIDTH + 1;
      parameter                      tlb_addr_offset = ex6_pid_offset + `PID_WIDTH;
      parameter                      tlb_addr2_offset = tlb_addr_offset + `TLB_ADDR_WIDTH;
      parameter                      tlb_write_offset = tlb_addr2_offset + `TLB_ADDR_WIDTH;
      parameter                      tlb_tag0_offset = tlb_write_offset + `TLB_WAYS;
      parameter                      tlb_tag1_offset = tlb_tag0_offset + `TLB_TAG_WIDTH;
      parameter                      tlb_tag2_offset = tlb_tag1_offset + `TLB_TAG_WIDTH;
      parameter                      tlb_seq_offset = tlb_tag2_offset + `TLB_TAG_WIDTH;
      parameter                      derat_taken_offset = tlb_seq_offset + `TLB_SEQ_WIDTH;
      parameter                      xucr4_mmu_mchk_offset = derat_taken_offset + 1;
      parameter                      ex6_illeg_instr_offset = xucr4_mmu_mchk_offset + 1;

      parameter                      snoop_val_offset = ex6_illeg_instr_offset + 2;  // this is constant for tlbre/we illegal
      parameter                      snoop_attr_offset = snoop_val_offset + 2;
      parameter                      snoop_vpn_offset = snoop_attr_offset + 35;
      parameter                      tlb_clr_resv_offset = snoop_vpn_offset + `EPN_WIDTH;
      parameter                      tlb_resv_match_vec_offset = tlb_clr_resv_offset + `MM_THREADS;
      parameter                      tlb_resv0_valid_offset = tlb_resv_match_vec_offset + `MM_THREADS;
      parameter                      tlb_resv0_epn_offset = tlb_resv0_valid_offset + 1;
      parameter                      tlb_resv0_pid_offset = tlb_resv0_epn_offset + `EPN_WIDTH;
      parameter                      tlb_resv0_lpid_offset = tlb_resv0_pid_offset + `PID_WIDTH;
      parameter                      tlb_resv0_as_offset = tlb_resv0_lpid_offset + `LPID_WIDTH;
      parameter                      tlb_resv0_gs_offset = tlb_resv0_as_offset + 1;
      parameter                      tlb_resv0_ind_offset = tlb_resv0_gs_offset + 1;
      parameter                      tlb_resv0_class_offset = tlb_resv0_ind_offset + 1;
`ifdef MM_THREADS2
      parameter                      tlb_resv1_valid_offset = tlb_resv0_class_offset + `CLASS_WIDTH;
      parameter                      tlb_resv1_epn_offset = tlb_resv1_valid_offset + 1;
      parameter                      tlb_resv1_pid_offset = tlb_resv1_epn_offset + `EPN_WIDTH;
      parameter                      tlb_resv1_lpid_offset = tlb_resv1_pid_offset + `PID_WIDTH;
      parameter                      tlb_resv1_as_offset = tlb_resv1_lpid_offset + `LPID_WIDTH;
      parameter                      tlb_resv1_gs_offset = tlb_resv1_as_offset + 1;
      parameter                      tlb_resv1_ind_offset = tlb_resv1_gs_offset + 1;
      parameter                      tlb_resv1_class_offset = tlb_resv1_ind_offset + 1;
      parameter                      ptereload_req_pte_offset = tlb_resv1_class_offset + `CLASS_WIDTH;
`else
      parameter                      ptereload_req_pte_offset = tlb_resv0_class_offset + `CLASS_WIDTH;
`endif
      parameter                      tlb_delayed_act_offset = ptereload_req_pte_offset + `PTE_WIDTH;
      parameter                      tlb_ctl_spare_offset = tlb_delayed_act_offset + 34;
      parameter                      scan_right = tlb_ctl_spare_offset + 32 - 1;

`ifdef MM_THREADS2
      parameter                      BUGSP_MM_THREADS = 2;
`else
      parameter                      BUGSP_MM_THREADS = 1;
`endif

      // Latch signals
      wire [0:`MM_THREADS-1]          xu_ex1_flush_d;
      wire [0:`MM_THREADS-1]          xu_ex1_flush_q;
      wire [0:`MM_THREADS-1]          ex1_valid_d;
      wire [0:`MM_THREADS-1]          ex1_valid_q;
      wire [0:`CTL_TTYPE_WIDTH-1]     ex1_ttype_d, ex1_ttype_q;
      wire [0:`CTL_STATE_WIDTH]       ex1_state_d;
      wire [0:`CTL_STATE_WIDTH]       ex1_state_q;
      wire [0:`PID_WIDTH-1]           ex1_pid_d;
      wire [0:`PID_WIDTH-1]           ex1_pid_q;
      wire [0:`MM_THREADS-1]          ex2_valid_d;
      wire [0:`MM_THREADS-1]          ex2_valid_q;
      wire [0:`MM_THREADS-1]          ex2_flush_d;
      wire [0:`MM_THREADS-1]          ex2_flush_q;
      wire [0:`MM_THREADS-1]          ex2_flush_req_d;
      wire [0:`MM_THREADS-1]          ex2_flush_req_q;
      wire [0:`CTL_TTYPE_WIDTH-1]     ex2_ttype_d;
      wire [0:`CTL_TTYPE_WIDTH-1]     ex2_ttype_q;
      wire [0:`CTL_STATE_WIDTH]       ex2_state_d;
      wire [0:`CTL_STATE_WIDTH]       ex2_state_q;
      wire [0:`PID_WIDTH-1]           ex2_pid_d;
      wire [0:`PID_WIDTH-1]           ex2_pid_q;
      wire [0:`ITAG_SIZE_ENC-1]       ex1_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]       ex1_itag_q;
      wire [0:`ITAG_SIZE_ENC-1]       ex2_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]       ex2_itag_q;
      wire [0:`MM_THREADS-1]                     ex3_valid_d;
      wire [0:`MM_THREADS-1]                     ex3_valid_q;
      wire [0:`MM_THREADS-1]                     ex3_flush_d;
      wire [0:`MM_THREADS-1]                     ex3_flush_q;
      wire [0:`CTL_TTYPE_WIDTH-1]         ex3_ttype_d;
      wire [0:`CTL_TTYPE_WIDTH-1]         ex3_ttype_q;
      wire [0:`CTL_STATE_WIDTH]           ex3_state_d;
      wire [0:`CTL_STATE_WIDTH]           ex3_state_q;
      wire [0:`PID_WIDTH-1]           ex3_pid_d;
      wire [0:`PID_WIDTH-1]           ex3_pid_q;
      wire [0:`MM_THREADS-1]                     ex4_valid_d;
      wire [0:`MM_THREADS-1]                     ex4_valid_q;
      wire [0:`MM_THREADS-1]                     ex4_flush_d;
      wire [0:`MM_THREADS-1]                     ex4_flush_q;
      wire [0:`CTL_TTYPE_WIDTH-1]         ex4_ttype_d;
      wire [0:`CTL_TTYPE_WIDTH-1]         ex4_ttype_q;
      wire [0:`CTL_STATE_WIDTH]           ex4_state_d;
      wire [0:`CTL_STATE_WIDTH]           ex4_state_q;
      wire [0:`PID_WIDTH-1]           ex4_pid_d;
      wire [0:`PID_WIDTH-1]           ex4_pid_q;
      wire [0:`MM_THREADS-1]                     ex5_valid_d;
      wire [0:`MM_THREADS-1]                     ex5_valid_q;
      wire [0:`MM_THREADS-1]                     ex5_flush_d;
      wire [0:`MM_THREADS-1]                     ex5_flush_q;
      wire [0:`CTL_TTYPE_WIDTH-1]         ex5_ttype_d;
      wire [0:`CTL_TTYPE_WIDTH-1]         ex5_ttype_q;
      wire [0:`CTL_STATE_WIDTH]           ex5_state_d;
      wire [0:`CTL_STATE_WIDTH]           ex5_state_q;
      wire [0:`PID_WIDTH-1]           ex5_pid_d;
      wire [0:`PID_WIDTH-1]           ex5_pid_q;
      wire [0:`MM_THREADS-1]                     ex6_valid_d;
      wire [0:`MM_THREADS-1]                     ex6_valid_q;
      wire [0:`MM_THREADS-1]                     ex6_flush_d;
      wire [0:`MM_THREADS-1]                     ex6_flush_q;
      wire [0:`CTL_TTYPE_WIDTH-1]         ex6_ttype_d;
      wire [0:`CTL_TTYPE_WIDTH-1]         ex6_ttype_q;
      wire [0:`CTL_STATE_WIDTH]           ex6_state_d;
      wire [0:`CTL_STATE_WIDTH]           ex6_state_q;
      wire [0:`PID_WIDTH-1]           ex6_pid_d;
      wire [0:`PID_WIDTH-1]           ex6_pid_q;
      wire [0:`TLB_TAG_WIDTH-1]       tlb_tag0_d;
      wire [0:`TLB_TAG_WIDTH-1]       tlb_tag0_q;
      wire [0:`TLB_TAG_WIDTH-1]       tlb_tag1_d;
      wire [0:`TLB_TAG_WIDTH-1]       tlb_tag1_q;
      wire [0:`TLB_TAG_WIDTH-1]       tlb_tag2_d;
      wire [0:`TLB_TAG_WIDTH-1]       tlb_tag2_q;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_addr_d;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_addr_q;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_addr2_d;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_addr2_q;
      wire [0:`TLB_WAYS-1]            tlb_write_d;
      wire [0:`TLB_WAYS-1]            tlb_write_q;
      wire [0:5]                     tlb_seq_d;
      wire [0:5]                     tlb_seq_q;
      wire                           derat_taken_d;
      wire                           derat_taken_q;
      wire [0:1]                     ex6_illeg_instr_d;
      wire [0:1]                     ex6_illeg_instr_q;
      wire [0:1]                     snoop_val_d;
      wire [0:1]                     snoop_val_q;
      wire [0:34]                    snoop_attr_d;
      wire [0:34]                    snoop_attr_q;
      wire [52-`EPN_WIDTH:51]         snoop_vpn_d;
      wire [52-`EPN_WIDTH:51]         snoop_vpn_q;
      wire                           tlb_resv0_valid_d;
      wire                           tlb_resv0_valid_q;
      wire [52-`EPN_WIDTH:51]        tlb_resv0_epn_d;
      wire [52-`EPN_WIDTH:51]        tlb_resv0_epn_q;
      wire [0:`PID_WIDTH-1]          tlb_resv0_pid_d;
      wire [0:`PID_WIDTH-1]          tlb_resv0_pid_q;
      wire [0:`LPID_WIDTH-1]         tlb_resv0_lpid_d;
      wire [0:`LPID_WIDTH-1]         tlb_resv0_lpid_q;
      wire                           tlb_resv0_as_d;
      wire                           tlb_resv0_as_q;
      wire                           tlb_resv0_gs_d;
      wire                           tlb_resv0_gs_q;
      wire                           tlb_resv0_ind_d;
      wire                           tlb_resv0_ind_q;
      wire [0:`CLASS_WIDTH-1]        tlb_resv0_class_d;
      wire [0:`CLASS_WIDTH-1]        tlb_resv0_class_q;
`ifdef MM_THREADS2
      wire                           tlb_resv1_valid_d;
      wire                           tlb_resv1_valid_q;
      wire [52-`EPN_WIDTH:51]        tlb_resv1_epn_d;
      wire [52-`EPN_WIDTH:51]        tlb_resv1_epn_q;
      wire [0:`PID_WIDTH-1]          tlb_resv1_pid_d;
      wire [0:`PID_WIDTH-1]          tlb_resv1_pid_q;
      wire [0:`LPID_WIDTH-1]         tlb_resv1_lpid_d;
      wire [0:`LPID_WIDTH-1]         tlb_resv1_lpid_q;
      wire                           tlb_resv1_as_d;
      wire                           tlb_resv1_as_q;
      wire                           tlb_resv1_gs_d;
      wire                           tlb_resv1_gs_q;
      wire                           tlb_resv1_ind_d;
      wire                           tlb_resv1_ind_q;
      wire [0:`CLASS_WIDTH-1]        tlb_resv1_class_d;
      wire [0:`CLASS_WIDTH-1]        tlb_resv1_class_q;
`endif
      wire [0:`PTE_WIDTH-1]          ptereload_req_pte_d;
      wire [0:`PTE_WIDTH-1]          ptereload_req_pte_q;
      wire [0:`MM_THREADS-1]         tlb_clr_resv_d;
      wire [0:`MM_THREADS-1]         tlb_clr_resv_q;
      wire [0:`MM_THREADS-1]         tlb_resv_match_vec_d;
      wire [0:`MM_THREADS-1]         tlb_resv_match_vec_q;
      wire [0:33]                    tlb_delayed_act_d;
      wire [0:33]                    tlb_delayed_act_q;
      wire [0:31]                    tlb_ctl_spare_q;

      // logic signals
      reg [0:5]                      tlb_seq_next;
      wire                           tlb_resv0_tag0_lpid_match;
      wire                           tlb_resv0_tag0_pid_match;
      wire                           tlb_resv0_tag0_as_snoop_match;
      wire                           tlb_resv0_tag0_gs_snoop_match;
      wire                           tlb_resv0_tag0_as_tlbwe_match;
      wire                           tlb_resv0_tag0_gs_tlbwe_match;
      wire                           tlb_resv0_tag0_ind_match;
      wire                           tlb_resv0_tag0_epn_loc_match;
      wire                           tlb_resv0_tag0_epn_glob_match;
      wire                           tlb_resv0_tag0_class_match;
      wire                           tlb_resv0_tag1_lpid_match;
      wire                           tlb_resv0_tag1_pid_match;
      wire                           tlb_resv0_tag1_as_snoop_match;
      wire                           tlb_resv0_tag1_gs_snoop_match;
      wire                           tlb_resv0_tag1_as_tlbwe_match;
      wire                           tlb_resv0_tag1_gs_tlbwe_match;
      wire                           tlb_resv0_tag1_ind_match;
      wire                           tlb_resv0_tag1_epn_loc_match;
      wire                           tlb_resv0_tag1_epn_glob_match;
      wire                           tlb_resv0_tag1_class_match;
`ifdef MM_THREADS2
      wire                           tlb_resv1_tag0_lpid_match;
      wire                           tlb_resv1_tag0_pid_match;
      wire                           tlb_resv1_tag0_as_snoop_match;
      wire                           tlb_resv1_tag0_gs_snoop_match;
      wire                           tlb_resv1_tag0_as_tlbwe_match;
      wire                           tlb_resv1_tag0_gs_tlbwe_match;
      wire                           tlb_resv1_tag0_ind_match;
      wire                           tlb_resv1_tag0_epn_loc_match;
      wire                           tlb_resv1_tag0_epn_glob_match;
      wire                           tlb_resv1_tag0_class_match;
      wire                           tlb_resv1_tag1_lpid_match;
      wire                           tlb_resv1_tag1_pid_match;
      wire                           tlb_resv1_tag1_as_snoop_match;
      wire                           tlb_resv1_tag1_gs_snoop_match;
      wire                           tlb_resv1_tag1_as_tlbwe_match;
      wire                           tlb_resv1_tag1_gs_tlbwe_match;
      wire                           tlb_resv1_tag1_ind_match;
      wire                           tlb_resv1_tag1_epn_loc_match;
      wire                           tlb_resv1_tag1_epn_glob_match;
      wire                           tlb_resv1_tag1_class_match;
`endif
      wire [0:`MM_THREADS-1]         tlb_resv_valid_vec;

      reg                            tlb_seq_set_resv;
      reg                            tlb_seq_snoop_resv;
      reg                            tlb_seq_snoop_inprogress;
      wire [0:`MM_THREADS-1]         tlb_seq_snoop_resv_q;
      reg                            tlb_seq_lru_rd_act;
      reg                            tlb_seq_lru_wr_act;

      wire [0:`TLB_ADDR_WIDTH-1]      tlb_hashed_addr1;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_hashed_addr2;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_hashed_addr3;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_hashed_addr4;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_hashed_addr5;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_hashed_tid0_addr1;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_hashed_tid0_addr2;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_hashed_tid0_addr3;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_hashed_tid0_addr4;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_hashed_tid0_addr5;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_tag0_hashed_addr;
      wire [0:`TLB_ADDR_WIDTH-1]      tlb_tag0_hashed_tid0_addr;
      wire                           tlb_tag0_tid_notzero;
      wire [0:`TLB_ADDR_WIDTH-1]      size_4K_hashed_addr;
      wire [0:`TLB_ADDR_WIDTH-1]      size_64K_hashed_addr;
      wire [0:`TLB_ADDR_WIDTH-1]      size_1M_hashed_addr;
      wire [0:`TLB_ADDR_WIDTH-1]      size_16M_hashed_addr;
      wire [0:`TLB_ADDR_WIDTH-1]      size_1G_hashed_addr;
      wire [0:`TLB_ADDR_WIDTH-1]      size_4K_hashed_tid0_addr;
      wire [0:`TLB_ADDR_WIDTH-1]      size_64K_hashed_tid0_addr;
      wire [0:`TLB_ADDR_WIDTH-1]      size_1M_hashed_tid0_addr;
      wire [0:`TLB_ADDR_WIDTH-1]      size_16M_hashed_tid0_addr;
      wire [0:`TLB_ADDR_WIDTH-1]      size_1G_hashed_tid0_addr;
      // reserved for HTW
      wire [0:`TLB_ADDR_WIDTH-1]      size_256M_hashed_addr;
      wire [0:`TLB_ADDR_WIDTH-1]      size_256M_hashed_tid0_addr;

      reg [0:3]                      tlb_seq_pgsize;
      reg [0:`TLB_ADDR_WIDTH-1]      tlb_seq_addr;
      reg [0:2]                      tlb_seq_esel;
      reg [0:1]                      tlb_seq_is;
      wire [0:`TLB_ADDR_WIDTH-1]     tlb_addr_p1;
      wire                           tlb_addr_maxcntm1;
      reg                            tlb_seq_addr_incr;
      reg                            tlb_seq_addr_clr;
      reg                            tlb_seq_tag0_addr_cap;
      reg                            tlb_seq_addr_update;
      reg                            tlb_seq_lrat_enable;
      wire                           tlb_seq_idle_sig;
      reg                            tlb_seq_ind;
      reg                            tlb_seq_ierat_done_sig;
      reg                            tlb_seq_derat_done_sig;
      reg                            tlb_seq_snoop_done_sig;
      reg                            tlb_seq_search_done_sig;
      reg                            tlb_seq_searchresv_done_sig;
      reg                            tlb_seq_read_done_sig;
      reg                            tlb_seq_write_done_sig;
      reg                            tlb_seq_ptereload_done_sig;
      wire                           tlb_seq_any_done_sig;
      reg                            tlb_seq_endflag;

      wire                           tlb_search_req;
      wire                           tlb_searchresv_req;
      wire                           tlb_read_req;
      wire                           tlb_write_req;

      (* NO_MODIFICATION="true" *)
      wire                           tlb_set_resv0;
`ifdef MM_THREADS2
      (* NO_MODIFICATION="true" *)
      wire                           tlb_set_resv1;
`endif
      wire                           any_tlb_req_sig;
      wire                           any_req_taken_sig;
      reg                            ierat_req_taken_sig;
      reg                            derat_req_taken_sig;
      reg                            snoop_req_taken_sig;
      reg                            search_req_taken_sig;
      reg                            searchresv_req_taken_sig;
      reg                            read_req_taken_sig;
      reg                            write_req_taken_sig;
      reg                            ptereload_req_taken_sig;
      wire                           ex3_valid_32b;
      wire                           ex1_mas0_atsel;
      wire [0:2]                     ex1_mas0_esel;
      wire                           ex1_mas0_hes;
      wire [0:1]                     ex1_mas0_wq;
      wire                           ex1_mas1_v;
      wire                           ex1_mas1_iprot;
      wire                           ex1_mas1_ind;
      wire [0:`PID_WIDTH-1]          ex1_mas1_tid;
      wire                           ex1_mas1_ts;
      wire [0:3]                     ex1_mas1_tsize;
      wire [52-`EPN_WIDTH:51]        ex1_mas2_epn;
      wire                           ex1_mas8_tgs;
      wire [0:`LPID_WIDTH-1]         ex1_mas8_tlpid;

      wire [0:`CLASS_WIDTH-1]        ex1_mmucr3_class;
      wire                           ex2_mas0_atsel;
      wire [0:2]                     ex2_mas0_esel;
      wire                           ex2_mas0_hes;
      wire [0:1]                     ex2_mas0_wq;
      wire                           ex2_mas1_ind;
      wire [0:`PID_WIDTH-1]          ex2_mas1_tid;
      wire [0:`LPID_WIDTH-1]         ex2_mas5_slpid;
      wire [0:`CTL_STATE_WIDTH-1]    ex2_mas5_1_state;
      wire [0:`CTL_STATE_WIDTH-1]    ex2_mas5_6_state;
      wire                           ex2_mas6_sind;
      wire [0:`PID_WIDTH-1]          ex2_mas6_spid;
      wire                           ex2_hv_state;
      wire                           ex6_hv_state;
      wire                           ex6_priv_state;
      wire                           ex6_dgtmi_state;

      wire [0:`MM_THREADS-1]         tlb_ctl_tag1_flush_sig;
      wire [0:`MM_THREADS-1]         tlb_ctl_tag2_flush_sig;
      wire [0:`MM_THREADS-1]         tlb_ctl_tag3_flush_sig;
      wire [0:`MM_THREADS-1]         tlb_ctl_tag4_flush_sig;
      wire                           tlb_ctl_any_tag_flush_sig;
      wire                           tlb_seq_abort;
      wire                           tlb_tag4_hit_or_parerr;
      wire [0:`MM_THREADS-1]         tlb_ctl_quiesce_b;
      wire [0:`MM_THREADS-1]         ex2_flush_req_local;
      wire                           tlbwe_back_inv_holdoff;
      wire                           pgsize1_valid;
      wire                           pgsize2_valid;
      wire                           pgsize3_valid;
      wire                           pgsize4_valid;
      wire                           pgsize5_valid;
      wire                           pgsize1_tid0_valid;
      wire                           pgsize2_tid0_valid;
      wire                           pgsize3_tid0_valid;
      wire                           pgsize4_tid0_valid;
      wire                           pgsize5_tid0_valid;
      wire [0:2]                     pgsize_qty;
      wire [0:2]                     pgsize_tid0_qty;
      wire                           tlb_tag1_pgsize_eq_16mb;
      wire                           tlb_tag1_pgsize_gte_1mb;
      wire                           tlb_tag1_pgsize_gte_64kb;
      // mas settings errors
      wire [0:`MM_THREADS-1]                     mas1_tsize_direct;
      wire [0:`MM_THREADS-1]                     mas1_tsize_indirect;
      wire [0:`MM_THREADS-1]                     mas1_tsize_lrat;
      wire [0:`MM_THREADS-1]                     mas3_spsize_indirect;
      wire [0:`MM_THREADS-1]                     ex2_tlbre_mas1_tsize_not_supp;
      wire [0:`MM_THREADS-1]                     ex5_tlbre_mas1_tsize_not_supp;
      wire [0:`MM_THREADS-1]                     ex5_tlbwe_mas1_tsize_not_supp;
      wire [0:`MM_THREADS-1]                     ex6_tlbwe_mas1_tsize_not_supp;
      wire [0:`MM_THREADS-1]                     ex5_tlbwe_mas0_lrat_bad_selects;
      wire [0:`MM_THREADS-1]                     ex6_tlbwe_mas0_lrat_bad_selects;
      wire [0:`MM_THREADS-1]                     ex5_tlbwe_mas2_ind_bad_wimge;
      wire [0:`MM_THREADS-1]                     ex6_tlbwe_mas2_ind_bad_wimge;
      wire [0:`MM_THREADS-1]                     ex5_tlbwe_mas3_ind_bad_spsize;
      wire [0:`MM_THREADS-1]                     ex6_tlbwe_mas3_ind_bad_spsize;
      // power clock gating signals
      wire                           tlb_early_act;
      wire                           tlb_tag0_act;
      wire                           tlb_snoop_act;

      (* analysis_not_referenced="true" *)
      wire [0:36]                    unused_dc;
      (* analysis_not_referenced="true" *)
      wire [`MM_THREADS:`THDID_WIDTH-1]         unused_dc_thdid;

      wire [0:(`MM_THREADS*11)-1]     tri_regk_unused_scan;


      // Pervasive
      wire                           pc_sg_1;
      wire                           pc_sg_0;
      wire                           pc_fce_1;
      wire                           pc_fce_0;
      wire                           pc_func_sl_thold_1;
      wire                           pc_func_sl_thold_0;
      wire                           pc_func_sl_thold_0_b;
      wire                           pc_func_slp_sl_thold_1;
      wire                           pc_func_slp_sl_thold_0;
      wire                           pc_func_slp_sl_thold_0_b;
      wire                           pc_func_sl_force;
      wire                           pc_func_slp_sl_force;
      wire                           pc_func_slp_nsl_thold_1;
      wire                           pc_func_slp_nsl_thold_0;
      wire                           pc_func_slp_nsl_thold_0_b;
      wire                           pc_func_slp_nsl_force;

      wire [0:scan_right]            siv;
      wire [0:scan_right]            sov;

      wire                           tidn;
      wire                           tiup;


      //begin
      //!! Bugspray Include: mmq_tlb_ctl;
      //---------------------------------------------------------------------
      // Logic
      //---------------------------------------------------------------------
      //---------------------------------------------------------------------
      // Common stuff for erat-only and tlb
      //---------------------------------------------------------------------
      assign tidn = 1'b0;
      assign tiup = 1'b1;

      // snoop from bus being serviced
      // not quiesced
      assign tlb_ctl_quiesce_b[0:`MM_THREADS-1] = ( {`MM_THREADS{(~(tlb_seq_idle_sig) & ~(tlb_seq_snoop_inprogress))}} & tlb_tag0_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS -1] );
      assign tlb_ctl_quiesce = (~tlb_ctl_quiesce_b);

      assign xu_ex1_flush_d = xu_rf1_flush;
      assign ex1_valid_d = xu_mm_rf1_val & (~(xu_rf1_flush));
      assign ex1_ttype_d = {xu_mm_rf1_is_tlbre, xu_mm_rf1_is_tlbwe, xu_mm_rf1_is_tlbsx, xu_mm_rf1_is_tlbsxr, xu_mm_rf1_is_tlbsrx};
      assign ex1_state_d[0] = |(xu_mm_msr_pr & xu_mm_rf1_val);
      assign ex1_state_d[1] = |(xu_mm_msr_gs & xu_mm_rf1_val);
      assign ex1_state_d[2] = |(xu_mm_msr_ds & xu_mm_rf1_val);
      assign ex1_state_d[3] = |(xu_mm_msr_cm & xu_mm_rf1_val);
      assign ex1_state_d[4] = |(xu_mm_msr_is & xu_mm_rf1_val);
      assign ex1_itag_d = xu_mm_rf1_itag;
`ifdef MM_THREADS2
      assign ex1_pid_d = (pid0 & {`PID_WIDTH{xu_mm_rf1_val[0]}}) | (pid1 & {`PID_WIDTH{xu_mm_rf1_val[1]}});
      assign ex1_mas0_atsel = (mas0_0_atsel & ex1_valid_q[0]) | (mas0_1_atsel & ex1_valid_q[1]);
      assign ex1_mas0_esel = (mas0_0_esel & {3{ex1_valid_q[0]}}) | (mas0_1_esel & {3{ex1_valid_q[1]}});
      assign ex1_mas0_hes = (mas0_0_hes & ex1_valid_q[0]) | (mas0_1_hes & ex1_valid_q[1]);
      assign ex1_mas0_wq = (mas0_0_wq & {2{ex1_valid_q[0]}}) | (mas0_1_wq & {2{ex1_valid_q[1]}} );
      assign ex1_mas1_tid = (mas1_0_tid & {`PID_WIDTH{ex1_valid_q[0]}}) | (mas1_1_tid & {`PID_WIDTH{ex1_valid_q[1]}});
      assign ex1_mas1_ts = (mas1_0_ts & ex1_valid_q[0]) | (mas1_1_ts & ex1_valid_q[1]);
      assign ex1_mas1_tsize = (mas1_0_tsize & {4{ex1_valid_q[0]}}) | (mas1_1_tsize & {4{ex1_valid_q[1]}});
      assign ex1_mas1_ind = (mas1_0_ind & ex1_valid_q[0]) | (mas1_1_ind & ex1_valid_q[1]);
      assign ex1_mas1_v = (mas1_0_v & ex1_valid_q[0]) | (mas1_1_v & ex1_valid_q[1]);
      assign ex1_mas1_iprot = (mas1_0_iprot & ex1_valid_q[0]) | (mas1_1_iprot & ex1_valid_q[1]);
      assign ex1_mas2_epn = (mas2_0_epn[52 - `EPN_WIDTH:51] & {`EPN_WIDTH{ex1_valid_q[0]}}) | (mas2_1_epn[52 - `EPN_WIDTH:51] & {`EPN_WIDTH{ex1_valid_q[1]}});
      assign ex1_mas8_tgs = (mas8_0_tgs & ex1_valid_q[0]) | (mas8_1_tgs & ex1_valid_q[1]);
      assign ex1_mas8_tlpid = (mas8_0_tlpid & {`LPID_WIDTH{ex1_valid_q[0]}}) | (mas8_1_tlpid & {`LPID_WIDTH{ex1_valid_q[1]}});

      assign ex1_mmucr3_class = (mmucr3_0[54:55] & {`CLASS_WIDTH{ex1_valid_q[0]}}) | (mmucr3_1[54:55] & {`CLASS_WIDTH{ex1_valid_q[1]}});
      assign ex2_mas0_atsel = (mas0_0_atsel & ex2_valid_q[0]) | (mas0_1_atsel & ex2_valid_q[1]);
      assign ex2_mas0_esel = (mas0_0_esel & {3{ex2_valid_q[0]}}) | (mas0_1_esel & {3{ex2_valid_q[1]}});
      assign ex2_mas0_hes = (mas0_0_hes & ex2_valid_q[0]) | (mas0_1_hes & ex2_valid_q[1]);
      assign ex2_mas0_wq = (mas0_0_wq & {2{ex2_valid_q[0]}}) | (mas0_1_wq & {2{ex2_valid_q[1]}});
      assign ex2_mas1_ind = (mas1_0_ind & ex2_valid_q[0]) | (mas1_1_ind & ex2_valid_q[1]);
      assign ex2_mas1_tid = (mas1_0_tid & {`PID_WIDTH{ex2_valid_q[0]}}) | (mas1_1_tid & {`PID_WIDTH{ex2_valid_q[1]}});

      // state: 0:pr 1:gs 2:as 3:cm
      assign ex2_mas5_1_state = ( {ex2_state_q[0], mas5_0_sgs, mas1_0_ts, ex2_state_q[3]} & {`CTL_STATE_WIDTH{ex2_valid_q[0]}} ) |
                                  ( {ex2_state_q[0], mas5_1_sgs, mas1_1_ts, ex2_state_q[3]} & {`CTL_STATE_WIDTH{ex2_valid_q[1]}} );

      assign ex2_mas5_6_state = ( {ex2_state_q[0], mas5_0_sgs, mas6_0_sas, ex2_state_q[3]} & {`CTL_STATE_WIDTH{ex2_valid_q[0]}} ) |
                                  ( {ex2_state_q[0], mas5_1_sgs, mas6_1_sas, ex2_state_q[3]} & {`CTL_STATE_WIDTH{ex2_valid_q[1]}} );

      assign ex2_mas5_slpid = (mas5_0_slpid & {`LPID_WIDTH{ex2_valid_q[0]}}) | (mas5_1_slpid & {`LPID_WIDTH{ex2_valid_q[1]}});

      assign ex2_mas6_spid = (mas6_0_spid & {`PID_WIDTH{ex2_valid_q[0]}}) | (mas6_1_spid & {`PID_WIDTH{ex2_valid_q[1]}});

      assign ex2_mas6_sind = (mas6_0_sind & ex2_valid_q[0]) | (mas6_1_sind & ex2_valid_q[1]);
`else
      assign ex1_pid_d = (pid0 & {`PID_WIDTH{xu_mm_rf1_val[0]}});
      assign ex1_mas0_atsel = (mas0_0_atsel & ex1_valid_q[0]);
      assign ex1_mas0_esel = (mas0_0_esel & {3{ex1_valid_q[0]}});
      assign ex1_mas0_hes = (mas0_0_hes & ex1_valid_q[0]);
      assign ex1_mas0_wq = (mas0_0_wq & {2{ex1_valid_q[0]}});
      assign ex1_mas1_tid = (mas1_0_tid & {`PID_WIDTH{ex1_valid_q[0]}});
      assign ex1_mas1_ts = (mas1_0_ts & ex1_valid_q[0]);
      assign ex1_mas1_tsize = (mas1_0_tsize & {4{ex1_valid_q[0]}});
      assign ex1_mas1_ind = (mas1_0_ind & ex1_valid_q[0]);
      assign ex1_mas1_v = (mas1_0_v & ex1_valid_q[0]);
      assign ex1_mas1_iprot = (mas1_0_iprot & ex1_valid_q[0]);
      assign ex1_mas2_epn = (mas2_0_epn[52 - `EPN_WIDTH:51] & {`EPN_WIDTH{ex1_valid_q[0]}});
      assign ex1_mas8_tgs = (mas8_0_tgs & ex1_valid_q[0]);
      assign ex1_mas8_tlpid = (mas8_0_tlpid & {`LPID_WIDTH{ex1_valid_q[0]}});

      assign ex1_mmucr3_class = (mmucr3_0[54:55] & {`CLASS_WIDTH{ex1_valid_q[0]}});
      assign ex2_mas0_atsel = (mas0_0_atsel & ex2_valid_q[0]);
      assign ex2_mas0_esel = (mas0_0_esel & {3{ex2_valid_q[0]}});
      assign ex2_mas0_hes = (mas0_0_hes & ex2_valid_q[0]);
      assign ex2_mas0_wq = (mas0_0_wq & {2{ex2_valid_q[0]}});
      assign ex2_mas1_ind = (mas1_0_ind & ex2_valid_q[0]);
      assign ex2_mas1_tid = (mas1_0_tid & {`PID_WIDTH{ex2_valid_q[0]}});

      // state: 0:pr 1:gs 2:as 3:cm
      assign ex2_mas5_1_state = ( {ex2_state_q[0], mas5_0_sgs, mas1_0_ts, ex2_state_q[3]} & {`CTL_STATE_WIDTH{ex2_valid_q[0]}} );

      assign ex2_mas5_6_state = ( {ex2_state_q[0], mas5_0_sgs, mas6_0_sas, ex2_state_q[3]} & {`CTL_STATE_WIDTH{ex2_valid_q[0]}} );

      assign ex2_mas5_slpid = (mas5_0_slpid & {`LPID_WIDTH{ex2_valid_q[0]}});

      assign ex2_mas6_spid = (mas6_0_spid & {`PID_WIDTH{ex2_valid_q[0]}});

      assign ex2_mas6_sind = (mas6_0_sind & ex2_valid_q[0]);
`endif

      assign ex2_itag_d = ex1_itag_q;
      assign ex2_valid_d = ex1_valid_q & (~(xu_ex1_flush));
      assign ex2_flush_d = (|(ex1_ttype_q) == 1'b1) ? (ex1_valid_q & xu_ex1_flush) :
                           {`MM_THREADS{1'b0}};
      assign ex2_flush_req_d = ((ex1_ttype_q[0:1] != 2'b00 & read_req_taken_sig == 1'b0 & write_req_taken_sig == 1'b0)) ? (ex1_valid_q & (~(xu_ex1_flush))) :
                               {`MM_THREADS{1'b0}};
      assign ex2_ttype_d = ex1_ttype_q;
      assign ex2_state_d = ex1_state_q;
      assign ex2_pid_d = ex1_pid_q;
      assign ex2_flush_req_local = ( (ex2_ttype_q[2:4] != 3'b000) & (search_req_taken_sig == 1'b0) & (searchresv_req_taken_sig == 1'b0) ) ? ex2_valid_q :
                                   {`MM_THREADS{1'b0}};

      // state: 0:pr 1:gs 2:as 3:cm
      assign ex2_hv_state = (~ex2_state_q[0]) & (~ex2_state_q[1]);
      assign ex6_hv_state = (~ex6_state_q[0]) & (~ex6_state_q[1]);
      assign ex6_priv_state = (~ex6_state_q[0]);
      assign ex6_dgtmi_state = |(ex6_valid_q & xu_mm_epcr_dgtmi);
      assign ex3_valid_d = ex2_valid_q & (~(xu_ex2_flush)) & (~(ex2_flush_req_q)) & (~(ex2_flush_req_local));
      assign ex3_flush_d = (|(ex2_ttype_q) == 1'b1) ? ((ex2_valid_q & xu_ex2_flush) | ex2_flush_q | ex2_flush_req_q | ex2_flush_req_local) :
                           {`MM_THREADS{1'b0}};
      assign ex3_ttype_d = ex2_ttype_q;
      assign ex3_state_d = ex2_state_q;
      assign ex3_pid_d = ex2_pid_q;
      assign tlb_ctl_ex3_valid = ex3_valid_q;
      assign tlb_ctl_ex3_ttype = ex3_ttype_q;
      // state: 0:pr 1:gs 2:as 3:cm
      assign tlb_ctl_ex3_hv_state = (~ex3_state_q[0]) & (~ex3_state_q[1]);

      assign ex4_valid_d = ex3_valid_q & (~(xu_ex3_flush));
      assign ex4_flush_d = (|(ex3_ttype_q) == 1'b1) ? ((ex3_valid_q & xu_ex3_flush) | ex3_flush_q) :
                           {`MM_THREADS{1'b0}};
      assign ex4_ttype_d = ex3_ttype_q;
      // state: 0:pr 1:gs 2:as 3:cm
      assign ex4_state_d = ex3_state_q;
      assign ex4_pid_d = ex3_pid_q;

      assign ex5_valid_d = ex4_valid_q & (~(xu_ex4_flush));
      assign ex5_flush_d = (|(ex4_ttype_q) == 1'b1) ? ((ex4_valid_q & xu_ex4_flush) | ex4_flush_q) :
                           {`MM_THREADS{1'b0}};
      assign ex5_ttype_d = ex4_ttype_q;
      assign ex5_state_d = ex4_state_q;
      assign ex5_pid_d = ex4_pid_q;

      // ex6 phase are holding latches for non-flushed tlbre,we,sx until tlb_seq is done
      assign ex6_valid_d = ((tlb_seq_read_done_sig == 1'b1 | tlb_seq_write_done_sig == 1'b1 | tlb_seq_search_done_sig == 1'b1 | tlb_seq_searchresv_done_sig == 1'b1)) ? {`MM_THREADS{1'b0}} :
                           ((|(ex6_valid_q) == 1'b0 & |(ex5_ttype_q) == 1'b1)) ? (ex5_valid_q & (~(xu_ex5_flush))) :
                           ex6_valid_q;
      assign ex6_flush_d = (|(ex5_ttype_q) == 1'b1) ? ((ex5_valid_q & xu_ex5_flush) | ex5_flush_q) :
                           {`MM_THREADS{1'b0}};
      assign ex6_ttype_d = (|(ex6_valid_q) == 1'b0) ? ex5_ttype_q :
                           ex6_ttype_q;
      assign ex6_state_d = (|(ex6_valid_q) == 1'b0) ? ex5_state_q :
                           ex6_state_q;
      assign ex6_pid_d = (|(ex6_valid_q) == 1'b0) ? ex5_pid_q :
                         ex6_pid_q;
      assign tlb_ctl_barrier_done = ((tlb_seq_read_done_sig == 1'b1 | tlb_seq_write_done_sig == 1'b1 | tlb_seq_search_done_sig == 1'b1 | tlb_seq_searchresv_done_sig == 1'b1)) ? ex6_valid_q :
                                    {`MM_THREADS{1'b0}};
      assign tlb_ctl_ord_type = {ex6_ttype_q[0:1], |(ex6_ttype_q[2:4])};
      // TLB Reservations
      // ttype <= tlbre & tlbwe & tlbsx & tlbsxr & tlbsrx;
      // mas0.wq: 00=ignore reserv, 01=write if reserved, 10=clear reserv, 11=not used
      //  reservation set:
      //        (1) proc completion of tlbsrx. when no reservation exists
      //        (2) proc holding resv executes another tlbsrx. thus establishing new resv
      assign tlb_set_resv0 = ((ex6_valid_q[0] == 1'b1 & ex6_ttype_q[4] == 1'b1 & tlb_seq_set_resv == 1'b1)) ? 1'b1 :
                             1'b0;
`ifdef MM_THREADS2
      assign tlb_set_resv1 = ((ex6_valid_q[1] == 1'b1 & ex6_ttype_q[4] == 1'b1 & tlb_seq_set_resv == 1'b1)) ? 1'b1 :
                             1'b0;
`endif

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
      //        (7a) any proc executes tlbwe not causing exception and with (wq=00 always, or wq=01 and proc holds resv)
      //              and mas regs ind,tgs,ts,tlpid,tid,sizemasked(epn,mas1.tsize) match resv.ind,gs,as,lpid,pid,sizemasked(epn,mas1.tsize)
      //        (7b) this proc executes tlbwe not causing exception and with (wq=10 clear my resv regardless of va)
      //        (8) any page table reload not causing an exception (due to pt fault, tlb inelig, or lrat miss)
      //              and PTE's tag ind=0,tgs,ts,tlpid,tid,sizemasked(epn,pte.size) match resv.ind=0,gs,as,lpid,pid,sizemasked(epn.pte.size)
      //       A2-specific non-architected clear states
      //        (9) any proc executes tlbwe not causing exception and with (wq=10 clear, or wq=11 always (same as 00))
      //              and mas regs ind,tgs,ts,tlpid,tid,sizemasked(epn,mas1.tsize) match resv.ind,gs,as,lpid,pid,sizemasked(epn,mas1.tsize)
      //               (basically same as 7)
      //        (10) any proc executes tlbilx T=2 (gs) with mas5.sgs matching resv.gs
      //        (11) any proc executes tlbilx T=4 to 7 (class) with T(1:2) matching resv.class
      //  ttype <= tlbre & tlbwe & tlbsx & tlbsxr & tlbsrx;
      //  IS0: Local bit
      //  IS1/Class: 0=all, 1=tid, 2=gs, 3=vpn, 4=class0, 5=class1, 6=class2, 7=class3
      //  mas0.wq: 00=ignore reserv write always, 01=write if reserved, 10=clear reserv, 11=same as 00
      assign tlb_clr_resv_d[0] =
                                 // term 1, overwriting reservation, part of set_resv terms
                                 // term 2, tlbivax VA match, snoop same as term 6 tlbilx T=3 (by vpn in lpid)
                                    ( tlb_seq_snoop_resv_q[0] & (tlb_tag1_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & tlb_resv0_tag1_lpid_match &
                                      tlb_resv0_tag1_pid_match & tlb_resv0_tag1_gs_snoop_match & tlb_resv0_tag1_as_snoop_match & tlb_resv0_tag1_epn_glob_match ) |
                                 // term 3, mmucsr0.TLB0_FI=1, snoop same as term 4 tlbilx T=0 (all in lpid)
                                 // term 4, tlbilx T=0 (all in lpid)
                                    ( tlb_seq_snoop_resv_q[0] & (tlb_tag1_q[`tagpos_is:`tagpos_is + 3] == 4'b1000) & tlb_resv0_tag1_lpid_match ) |
                                 // term 5, tlbilx T=1 (by pid in lpid)
                                    ( tlb_seq_snoop_resv_q[0] & (tlb_tag1_q[`tagpos_is:`tagpos_is + 3] == 4'b1001) & tlb_resv0_tag1_lpid_match & tlb_resv0_tag1_pid_match ) |
                                 // term 6, tlbilx T=3 (by vpn)
                                    ( tlb_seq_snoop_resv_q[0] & (tlb_tag1_q[`tagpos_is:`tagpos_is + 3] == 4'b1011) & tlb_resv0_tag1_lpid_match &
                                      tlb_resv0_tag1_pid_match & tlb_resv0_tag1_gs_snoop_match & tlb_resv0_tag1_as_snoop_match & tlb_resv0_tag1_epn_loc_match ) |
                                 // term 7a, tlbwe wq=00 always, or wq=01 and proc holds resv
                                    ( ((|(ex6_valid_q & tlb_resv_valid_vec) & (tlb_tag4_wq == 2'b01)) | (|(ex6_valid_q) & (tlb_tag4_wq == 2'b00))) &
                                           ex6_ttype_q[1] & tlb_resv0_tag1_gs_tlbwe_match & tlb_resv0_tag1_as_tlbwe_match & tlb_resv0_tag1_lpid_match & tlb_resv0_tag1_pid_match &
                                           tlb_resv0_tag1_epn_loc_match & tlb_resv0_tag1_ind_match ) |
                                 // term 7b, tlbwe wq=10 unconditionally clear my resv (regardless of va)
                                    ( ex6_valid_q[0] & ex6_ttype_q[1] & (tlb_tag4_wq == 2'b10) ) |
                                 // term 8, ptereload (matching resv.vpn)
                                    ( tlb_tag4_ptereload & tlb_resv0_tag1_gs_snoop_match & tlb_resv0_tag1_as_snoop_match & tlb_resv0_tag1_lpid_match & tlb_resv0_tag1_pid_match & tlb_resv0_tag1_epn_loc_match & tlb_resv0_tag1_ind_match ) |
                                 // A2-specific non-architected clear states
                                 // term 9, tlbwe wq=10 clear from anybody, or wq=11 from anybody always (same as 00)
                                    ( ((|(ex6_valid_q) & (tlb_tag4_wq == 2'b10)) | (|(ex6_valid_q) & (tlb_tag4_wq == 2'b11))) &
                                           ex6_ttype_q[1] & tlb_resv0_tag1_gs_tlbwe_match & tlb_resv0_tag1_as_tlbwe_match & tlb_resv0_tag1_lpid_match & tlb_resv0_tag1_pid_match & tlb_resv0_tag1_epn_loc_match & tlb_resv0_tag1_ind_match ) |
                                 // term 10, tlbilx T=2 (gs=1)
                                 //  or (tlb_seq_snoop_resv_q(<t>) and Eq(tlb_tag1_q(tagpos_is to tagpos_is+3),"1010") and
                                 //                tlb_resv<t>_tag1_gs_snoop_match)
                                 // term 11, tlbilx T=4 (by class)
                                    ( tlb_seq_snoop_resv_q[0] & (tlb_tag1_q[`tagpos_is:`tagpos_is + 1] == 2'b11) & tlb_resv0_tag1_class_match );

`ifdef MM_THREADS2
      assign tlb_clr_resv_d[1] = ( tlb_seq_snoop_resv_q[1] & (tlb_tag1_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & tlb_resv1_tag1_lpid_match & tlb_resv1_tag1_pid_match &
                                      tlb_resv1_tag1_gs_snoop_match & tlb_resv1_tag1_as_snoop_match & tlb_resv1_tag1_epn_glob_match ) |
                                   ( tlb_seq_snoop_resv_q[1] & (tlb_tag1_q[`tagpos_is:`tagpos_is + 3] == 4'b1000) & tlb_resv1_tag1_lpid_match ) |
                                   ( tlb_seq_snoop_resv_q[1] & (tlb_tag1_q[`tagpos_is:`tagpos_is + 3] == 4'b1001) & tlb_resv1_tag1_lpid_match & tlb_resv1_tag1_pid_match ) |
                                   ( tlb_seq_snoop_resv_q[1] & (tlb_tag1_q[`tagpos_is:`tagpos_is + 3] == 4'b1011) & tlb_resv1_tag1_lpid_match & tlb_resv1_tag1_pid_match & tlb_resv1_tag1_gs_snoop_match & tlb_resv1_tag1_as_snoop_match & tlb_resv1_tag1_epn_loc_match ) |
                                   ( ((|(ex6_valid_q & tlb_resv_valid_vec) & (tlb_tag4_wq == 2'b01)) | (|(ex6_valid_q) & (tlb_tag4_wq == 2'b00))) & ex6_ttype_q[1] &
                                         tlb_resv1_tag1_gs_tlbwe_match & tlb_resv1_tag1_as_tlbwe_match & tlb_resv1_tag1_lpid_match & tlb_resv1_tag1_pid_match & tlb_resv1_tag1_epn_loc_match & tlb_resv1_tag1_ind_match ) |
                                   ( ex6_valid_q[1] & ex6_ttype_q[1] & (tlb_tag4_wq == 2'b10) ) |
                                   ( tlb_tag4_ptereload & tlb_resv1_tag1_gs_snoop_match & tlb_resv1_tag1_as_snoop_match & tlb_resv1_tag1_lpid_match & tlb_resv1_tag1_pid_match & tlb_resv1_tag1_epn_loc_match & tlb_resv1_tag1_ind_match ) |
                                   ( ((|(ex6_valid_q) & (tlb_tag4_wq == 2'b10)) | (|(ex6_valid_q) & (tlb_tag4_wq == 2'b11))) & ex6_ttype_q[1] &
                                         tlb_resv1_tag1_gs_tlbwe_match & tlb_resv1_tag1_as_tlbwe_match & tlb_resv1_tag1_lpid_match & tlb_resv1_tag1_pid_match & tlb_resv1_tag1_epn_loc_match & tlb_resv1_tag1_ind_match ) |
                                   ( tlb_seq_snoop_resv_q[1] & (tlb_tag1_q[`tagpos_is:`tagpos_is + 1] == 2'b11) & tlb_resv1_tag1_class_match );

      assign tlb_resv_valid_vec = {tlb_resv0_valid_q, tlb_resv1_valid_q};
`else
      assign tlb_resv_valid_vec = {tlb_resv0_valid_q};
`endif
      assign tlb_resv_match_vec = tlb_resv_match_vec_q;
      assign tlb_resv0_valid_d = (tlb_clr_resv_q[0] == 1'b1 & tlb_tag5_except[0] == 1'b0) ? 1'b0 :
                                 (tlb_set_resv0 == 1'b1) ? ex6_valid_q[0] :
                                 tlb_resv0_valid_q;
      assign tlb_resv0_epn_d = ((tlb_set_resv0 == 1'b1)) ? tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] :
                               tlb_resv0_epn_q;
      assign tlb_resv0_pid_d = ((tlb_set_resv0 == 1'b1)) ? mas1_0_tid :
                               tlb_resv0_pid_q;
      assign tlb_resv0_lpid_d = ((tlb_set_resv0 == 1'b1)) ? mas5_0_slpid :
                                tlb_resv0_lpid_q;
      assign tlb_resv0_as_d = ((tlb_set_resv0 == 1'b1)) ? mas1_0_ts :
                              tlb_resv0_as_q;
      assign tlb_resv0_gs_d = ((tlb_set_resv0 == 1'b1)) ? mas5_0_sgs :
                              tlb_resv0_gs_q;
      assign tlb_resv0_ind_d = ((tlb_set_resv0 == 1'b1)) ? mas1_0_ind :
                               tlb_resv0_ind_q;
      assign tlb_resv0_class_d = ((tlb_set_resv0 == 1'b1)) ? mmucr3_0[54:55] :
                                 tlb_resv0_class_q;
      // uniquify snoop/tlbwe as/gs match sigs because `tagpos_as/gs are msr state for tlbwe, not mas values
      assign tlb_resv0_tag0_lpid_match = ((tlb_tag0_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] == tlb_resv0_lpid_q)) ? 1'b1 :
                                         1'b0;
      assign tlb_resv0_tag0_pid_match = ((tlb_tag0_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1] == tlb_resv0_pid_q)) ? 1'b1 :
                                        1'b0;
      assign tlb_resv0_tag0_gs_snoop_match = ((tlb_tag0_q[`tagpos_gs] == tlb_resv0_gs_q)) ? 1'b1 :
                                             1'b0;
      assign tlb_resv0_tag0_as_snoop_match = ((tlb_tag0_q[`tagpos_as] == tlb_resv0_as_q)) ? 1'b1 :
                                             1'b0;
      //  unused `tagpos_pt, `tagpos_recform def are mas8_tgs, mas1_ts for tlbwe
      assign tlb_resv0_tag0_gs_tlbwe_match = ((tlb_tag0_q[`tagpos_pt] == tlb_resv0_gs_q)) ? 1'b1 :
                                             1'b0;
      assign tlb_resv0_tag0_as_tlbwe_match = ((tlb_tag0_q[`tagpos_recform] == tlb_resv0_as_q)) ? 1'b1 :
                                             1'b0;
      assign tlb_resv0_tag0_ind_match = ((tlb_tag0_q[`tagpos_ind] == tlb_resv0_ind_q)) ? 1'b1 :
                                        1'b0;
      assign tlb_resv0_tag0_class_match = ((tlb_tag0_q[`tagpos_class:`tagpos_class + 1] == tlb_resv0_class_q)) ? 1'b1 :
                                          1'b0;
      // local match includes upper epn bits
      assign tlb_resv0_tag0_epn_loc_match = ((tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] == tlb_resv0_epn_q[52 - `EPN_WIDTH:51] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 5] == tlb_resv0_epn_q[52 - `EPN_WIDTH:47] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 9] == tlb_resv0_epn_q[52 - `EPN_WIDTH:43] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 13] == tlb_resv0_epn_q[52 - `EPN_WIDTH:39] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 17] == tlb_resv0_epn_q[52 - `EPN_WIDTH:35] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 19] == tlb_resv0_epn_q[52 - `EPN_WIDTH:33] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 :
                                            1'b0;
      // global match ignores certain upper epn bits that are not tranferred over bus
      // fix me!!  use various upper nibbles dependent on pgsize and mmucr1.tlbi_msb
      assign tlb_resv0_tag0_epn_glob_match = ((tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 1] == tlb_resv0_epn_q[52 - `EPN_WIDTH + 31:51] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 5] == tlb_resv0_epn_q[52 - `EPN_WIDTH + 31:47] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 9] == tlb_resv0_epn_q[52 - `EPN_WIDTH + 31:43] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 13] == tlb_resv0_epn_q[52 - `EPN_WIDTH + 31:39] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 17] == tlb_resv0_epn_q[52 - `EPN_WIDTH + 31:35] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 19] == tlb_resv0_epn_q[52 - `EPN_WIDTH + 31:33] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 :
                                             1'b0;
      // NOTE: ind is part of reservation tlbwe/ptereload match criteria, but not invalidate criteria
      assign tlb_resv_match_vec_d[0] = (tlb_resv0_valid_q & tlb_tag0_q[`tagpos_type_snoop] == 1'b1 & tlb_resv0_tag0_epn_loc_match & tlb_resv0_tag0_lpid_match & tlb_resv0_tag0_pid_match & tlb_resv0_tag0_as_snoop_match & tlb_resv0_tag0_gs_snoop_match) | (tlb_resv0_valid_q & tlb_tag0_q[`tagpos_type_tlbwe] == 1'b1 & tlb_resv0_tag0_epn_loc_match & tlb_resv0_tag0_lpid_match & tlb_resv0_tag0_pid_match & tlb_resv0_tag0_as_tlbwe_match & tlb_resv0_tag0_gs_tlbwe_match & tlb_resv0_tag0_ind_match) | (tlb_resv0_valid_q & tlb_tag0_q[`tagpos_type_ptereload] == 1'b1 & tlb_resv0_tag0_epn_loc_match & tlb_resv0_tag0_lpid_match & tlb_resv0_tag0_pid_match & tlb_resv0_tag0_as_snoop_match & tlb_resv0_tag0_gs_snoop_match & tlb_resv0_tag0_ind_match);

`ifdef MM_THREADS2
      assign tlb_resv1_valid_d = (tlb_clr_resv_q[1] == 1'b1 & tlb_tag5_except[1] == 1'b0) ? 1'b0 :
                                 (tlb_set_resv1 == 1'b1) ? ex6_valid_q[1] :
                                 tlb_resv1_valid_q;
      assign tlb_resv1_epn_d = ((tlb_set_resv1 == 1'b1)) ? tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] :
                               tlb_resv1_epn_q;
      assign tlb_resv1_pid_d = ((tlb_set_resv1 == 1'b1)) ? mas1_1_tid :
                               tlb_resv1_pid_q;
      assign tlb_resv1_lpid_d = ((tlb_set_resv1 == 1'b1)) ? mas5_1_slpid :
                                tlb_resv1_lpid_q;
      assign tlb_resv1_as_d = ((tlb_set_resv1 == 1'b1)) ? mas1_1_ts :
                              tlb_resv1_as_q;
      assign tlb_resv1_gs_d = ((tlb_set_resv1 == 1'b1)) ? mas5_1_sgs :
                              tlb_resv1_gs_q;
      assign tlb_resv1_ind_d = ((tlb_set_resv1 == 1'b1)) ? mas1_1_ind :
                               tlb_resv1_ind_q;
      assign tlb_resv1_class_d = ((tlb_set_resv1 == 1'b1)) ? mmucr3_1[54:55] :
                                 tlb_resv1_class_q;
      // uniquify snoop/tlbwe as/gs match sigs because `tagpos_as/gs are msr state for tlbwe, not mas values
      assign tlb_resv1_tag0_lpid_match = ((tlb_tag0_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] == tlb_resv1_lpid_q)) ? 1'b1 :
                                         1'b0;
      assign tlb_resv1_tag0_pid_match = ((tlb_tag0_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1] == tlb_resv1_pid_q)) ? 1'b1 :
                                        1'b0;
      assign tlb_resv1_tag0_gs_snoop_match = ((tlb_tag0_q[`tagpos_gs] == tlb_resv1_gs_q)) ? 1'b1 :
                                             1'b0;
      assign tlb_resv1_tag0_as_snoop_match = ((tlb_tag0_q[`tagpos_as] == tlb_resv1_as_q)) ? 1'b1 :
                                             1'b0;
      assign tlb_resv1_tag0_gs_tlbwe_match = ((tlb_tag0_q[`tagpos_pt] == tlb_resv1_gs_q)) ? 1'b1 :
                                             1'b0;
      assign tlb_resv1_tag0_as_tlbwe_match = ((tlb_tag0_q[`tagpos_recform] == tlb_resv1_as_q)) ? 1'b1 :
                                             1'b0;
      assign tlb_resv1_tag0_ind_match = ((tlb_tag0_q[`tagpos_ind] == tlb_resv1_ind_q)) ? 1'b1 :
                                        1'b0;
      assign tlb_resv1_tag0_class_match = ((tlb_tag0_q[`tagpos_class:`tagpos_class + 1] == tlb_resv1_class_q)) ? 1'b1 :
                                          1'b0;
      // local match includes upper epn bits
      assign tlb_resv1_tag0_epn_loc_match = ((tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] == tlb_resv1_epn_q[52 - `EPN_WIDTH:51] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 5] == tlb_resv1_epn_q[52 - `EPN_WIDTH:47] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 9] == tlb_resv1_epn_q[52 - `EPN_WIDTH:43] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 13] == tlb_resv1_epn_q[52 - `EPN_WIDTH:39] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 17] == tlb_resv1_epn_q[52 - `EPN_WIDTH:35] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 19] == tlb_resv1_epn_q[52 - `EPN_WIDTH:33] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 :
                                            1'b0;
      // global match ignores certain upper epn bits that are not tranferred over bus
      // fix me!!  use various upper nibbles dependent on pgsize and mmucr1.tlbi_msb
      assign tlb_resv1_tag0_epn_glob_match = ((tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 1] == tlb_resv1_epn_q[52 - `EPN_WIDTH + 31:51] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 5] == tlb_resv1_epn_q[52 - `EPN_WIDTH + 31:47] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 9] == tlb_resv1_epn_q[52 - `EPN_WIDTH + 31:43] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 13] == tlb_resv1_epn_q[52 - `EPN_WIDTH + 31:39] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 17] == tlb_resv1_epn_q[52 - `EPN_WIDTH + 31:35] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 19] == tlb_resv1_epn_q[52 - `EPN_WIDTH + 31:33] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 :
                                             1'b0;
      // NOTE: ind is part of reservation tlbwe/ptereload match criteria, but not invalidate criteria
      assign tlb_resv_match_vec_d[1] = (tlb_resv1_valid_q & tlb_tag0_q[`tagpos_type_snoop] == 1'b1 & tlb_resv1_tag0_epn_loc_match & tlb_resv1_tag0_lpid_match & tlb_resv1_tag0_pid_match & tlb_resv1_tag0_as_snoop_match & tlb_resv1_tag0_gs_snoop_match) | (tlb_resv1_valid_q & tlb_tag0_q[`tagpos_type_tlbwe] == 1'b1 & tlb_resv1_tag0_epn_loc_match & tlb_resv1_tag0_lpid_match & tlb_resv1_tag0_pid_match & tlb_resv1_tag0_as_tlbwe_match & tlb_resv1_tag0_gs_tlbwe_match & tlb_resv1_tag0_ind_match) | (tlb_resv1_valid_q & tlb_tag0_q[`tagpos_type_ptereload] == 1'b1 & tlb_resv1_tag0_epn_loc_match & tlb_resv1_tag0_lpid_match & tlb_resv1_tag0_pid_match & tlb_resv1_tag0_as_snoop_match & tlb_resv1_tag0_gs_snoop_match & tlb_resv1_tag0_ind_match);
`endif

      //  TLB Address Hash xor terms per size
      //   4K        64K       1M     16M   256M    1G
      //-----------------------------------------------
      // 6 51 44 37  47    37  43 36  39     35     33
      // 5 50 43 36  46    36  42 35  38     34     32
      // 4 49 42 35  45    35  41 34  37     33     31
      // 3 48 41 34  44    34  40 33  36 32  32     30
      // 2 47 40 33  43 40 33  39 32  35 31  31     29
      // 1 46 39 32  42 39 32  38 31  34 30  30 28  28
      // 0 45 38 31  41 38 31  37 30  33 29  29 27  27
      // pid(9:15) <- tlb_tag0_q(53:59)
      generate
         if (`TLB_ADDR_WIDTH == 7)
         begin : tlbaddrwidth7_gen
            assign size_1G_hashed_addr[6] = tlb_tag0_q[33] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 1];
            assign size_1G_hashed_addr[5] = tlb_tag0_q[32] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 2];
            assign size_1G_hashed_addr[4] = tlb_tag0_q[31] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 3];
            assign size_1G_hashed_addr[3] = tlb_tag0_q[30] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 4];
            assign size_1G_hashed_addr[2] = tlb_tag0_q[29] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 5];
            assign size_1G_hashed_addr[1] = tlb_tag0_q[28] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 6];
            assign size_1G_hashed_addr[0] = tlb_tag0_q[27] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 7];
            assign size_1G_hashed_tid0_addr[6] = tlb_tag0_q[33];
            assign size_1G_hashed_tid0_addr[5] = tlb_tag0_q[32];
            assign size_1G_hashed_tid0_addr[4] = tlb_tag0_q[31];
            assign size_1G_hashed_tid0_addr[3] = tlb_tag0_q[30];
            assign size_1G_hashed_tid0_addr[2] = tlb_tag0_q[29];
            assign size_1G_hashed_tid0_addr[1] = tlb_tag0_q[28];
            assign size_1G_hashed_tid0_addr[0] = tlb_tag0_q[27];
            assign size_256M_hashed_addr[6] = tlb_tag0_q[35] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 1];
            assign size_256M_hashed_addr[5] = tlb_tag0_q[34] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 2];
            assign size_256M_hashed_addr[4] = tlb_tag0_q[33] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 3];
            assign size_256M_hashed_addr[3] = tlb_tag0_q[32] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 4];
            assign size_256M_hashed_addr[2] = tlb_tag0_q[31] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 5];
            assign size_256M_hashed_addr[1] = tlb_tag0_q[30] ^ tlb_tag0_q[28] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 6];
            assign size_256M_hashed_addr[0] = tlb_tag0_q[29] ^ tlb_tag0_q[27] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 7];
            assign size_256M_hashed_tid0_addr[6] = tlb_tag0_q[35];
            assign size_256M_hashed_tid0_addr[5] = tlb_tag0_q[34];
            assign size_256M_hashed_tid0_addr[4] = tlb_tag0_q[33];
            assign size_256M_hashed_tid0_addr[3] = tlb_tag0_q[32];
            assign size_256M_hashed_tid0_addr[2] = tlb_tag0_q[31];
            assign size_256M_hashed_tid0_addr[1] = tlb_tag0_q[30] ^ tlb_tag0_q[28];
            assign size_256M_hashed_tid0_addr[0] = tlb_tag0_q[29] ^ tlb_tag0_q[27];
            assign size_16M_hashed_addr[6] = tlb_tag0_q[39] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 1];
            assign size_16M_hashed_addr[5] = tlb_tag0_q[38] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 2];
            assign size_16M_hashed_addr[4] = tlb_tag0_q[37] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 3];
            assign size_16M_hashed_addr[3] = tlb_tag0_q[36] ^ tlb_tag0_q[32] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 4];
            assign size_16M_hashed_addr[2] = tlb_tag0_q[35] ^ tlb_tag0_q[31] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 5];
            assign size_16M_hashed_addr[1] = tlb_tag0_q[34] ^ tlb_tag0_q[30] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 6];
            assign size_16M_hashed_addr[0] = tlb_tag0_q[33] ^ tlb_tag0_q[29] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 7];
            assign size_16M_hashed_tid0_addr[6] = tlb_tag0_q[39];
            assign size_16M_hashed_tid0_addr[5] = tlb_tag0_q[38];
            assign size_16M_hashed_tid0_addr[4] = tlb_tag0_q[37];
            assign size_16M_hashed_tid0_addr[3] = tlb_tag0_q[36] ^ tlb_tag0_q[32];
            assign size_16M_hashed_tid0_addr[2] = tlb_tag0_q[35] ^ tlb_tag0_q[31];
            assign size_16M_hashed_tid0_addr[1] = tlb_tag0_q[34] ^ tlb_tag0_q[30];
            assign size_16M_hashed_tid0_addr[0] = tlb_tag0_q[33] ^ tlb_tag0_q[29];
            assign size_1M_hashed_addr[6] = tlb_tag0_q[43] ^ tlb_tag0_q[36] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 1];
            assign size_1M_hashed_addr[5] = tlb_tag0_q[42] ^ tlb_tag0_q[35] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 2];
            assign size_1M_hashed_addr[4] = tlb_tag0_q[41] ^ tlb_tag0_q[34] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 3];
            assign size_1M_hashed_addr[3] = tlb_tag0_q[40] ^ tlb_tag0_q[33] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 4];
            assign size_1M_hashed_addr[2] = tlb_tag0_q[39] ^ tlb_tag0_q[32] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 5];
            assign size_1M_hashed_addr[1] = tlb_tag0_q[38] ^ tlb_tag0_q[31] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 6];
            assign size_1M_hashed_addr[0] = tlb_tag0_q[37] ^ tlb_tag0_q[30] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 7];
            assign size_1M_hashed_tid0_addr[6] = tlb_tag0_q[43] ^ tlb_tag0_q[36];
            assign size_1M_hashed_tid0_addr[5] = tlb_tag0_q[42] ^ tlb_tag0_q[35];
            assign size_1M_hashed_tid0_addr[4] = tlb_tag0_q[41] ^ tlb_tag0_q[34];
            assign size_1M_hashed_tid0_addr[3] = tlb_tag0_q[40] ^ tlb_tag0_q[33];
            assign size_1M_hashed_tid0_addr[2] = tlb_tag0_q[39] ^ tlb_tag0_q[32];
            assign size_1M_hashed_tid0_addr[1] = tlb_tag0_q[38] ^ tlb_tag0_q[31];
            assign size_1M_hashed_tid0_addr[0] = tlb_tag0_q[37] ^ tlb_tag0_q[30];
            assign size_64K_hashed_addr[6] = tlb_tag0_q[47] ^ tlb_tag0_q[37] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 1];
            assign size_64K_hashed_addr[5] = tlb_tag0_q[46] ^ tlb_tag0_q[36] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 2];
            assign size_64K_hashed_addr[4] = tlb_tag0_q[45] ^ tlb_tag0_q[35] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 3];
            assign size_64K_hashed_addr[3] = tlb_tag0_q[44] ^ tlb_tag0_q[34] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 4];
            assign size_64K_hashed_addr[2] = tlb_tag0_q[43] ^ tlb_tag0_q[40] ^ tlb_tag0_q[33] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 5];
            assign size_64K_hashed_addr[1] = tlb_tag0_q[42] ^ tlb_tag0_q[39] ^ tlb_tag0_q[32] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 6];
            assign size_64K_hashed_addr[0] = tlb_tag0_q[41] ^ tlb_tag0_q[38] ^ tlb_tag0_q[31] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 7];
            assign size_64K_hashed_tid0_addr[6] = tlb_tag0_q[47] ^ tlb_tag0_q[37];
            assign size_64K_hashed_tid0_addr[5] = tlb_tag0_q[46] ^ tlb_tag0_q[36];
            assign size_64K_hashed_tid0_addr[4] = tlb_tag0_q[45] ^ tlb_tag0_q[35];
            assign size_64K_hashed_tid0_addr[3] = tlb_tag0_q[44] ^ tlb_tag0_q[34];
            assign size_64K_hashed_tid0_addr[2] = tlb_tag0_q[43] ^ tlb_tag0_q[40] ^ tlb_tag0_q[33];
            assign size_64K_hashed_tid0_addr[1] = tlb_tag0_q[42] ^ tlb_tag0_q[39] ^ tlb_tag0_q[32];
            assign size_64K_hashed_tid0_addr[0] = tlb_tag0_q[41] ^ tlb_tag0_q[38] ^ tlb_tag0_q[31];
            assign size_4K_hashed_addr[6] = tlb_tag0_q[51] ^ tlb_tag0_q[44] ^ tlb_tag0_q[37] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 1];
            assign size_4K_hashed_addr[5] = tlb_tag0_q[50] ^ tlb_tag0_q[43] ^ tlb_tag0_q[36] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 2];
            assign size_4K_hashed_addr[4] = tlb_tag0_q[49] ^ tlb_tag0_q[42] ^ tlb_tag0_q[35] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 3];
            assign size_4K_hashed_addr[3] = tlb_tag0_q[48] ^ tlb_tag0_q[41] ^ tlb_tag0_q[34] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 4];
            assign size_4K_hashed_addr[2] = tlb_tag0_q[47] ^ tlb_tag0_q[40] ^ tlb_tag0_q[33] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 5];
            assign size_4K_hashed_addr[1] = tlb_tag0_q[46] ^ tlb_tag0_q[39] ^ tlb_tag0_q[32] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 6];
            assign size_4K_hashed_addr[0] = tlb_tag0_q[45] ^ tlb_tag0_q[38] ^ tlb_tag0_q[31] ^ tlb_tag0_q[`tagpos_pid + `PID_WIDTH - 7];
            assign size_4K_hashed_tid0_addr[6] = tlb_tag0_q[51] ^ tlb_tag0_q[44] ^ tlb_tag0_q[37];
            assign size_4K_hashed_tid0_addr[5] = tlb_tag0_q[50] ^ tlb_tag0_q[43] ^ tlb_tag0_q[36];
            assign size_4K_hashed_tid0_addr[4] = tlb_tag0_q[49] ^ tlb_tag0_q[42] ^ tlb_tag0_q[35];
            assign size_4K_hashed_tid0_addr[3] = tlb_tag0_q[48] ^ tlb_tag0_q[41] ^ tlb_tag0_q[34];
            assign size_4K_hashed_tid0_addr[2] = tlb_tag0_q[47] ^ tlb_tag0_q[40] ^ tlb_tag0_q[33];
            assign size_4K_hashed_tid0_addr[1] = tlb_tag0_q[46] ^ tlb_tag0_q[39] ^ tlb_tag0_q[32];
            assign size_4K_hashed_tid0_addr[0] = tlb_tag0_q[45] ^ tlb_tag0_q[38] ^ tlb_tag0_q[31];
         end
      endgenerate
      //constant TLB_PgSize_1GB   :=  1010 ;
      //constant TLB_PgSize_256MB :=  1001 ;
      //constant TLB_PgSize_16MB  :=  0111 ;
      //constant TLB_PgSize_1MB   :=  0101 ;
      //constant TLB_PgSize_64KB  :=  0011 ;
      //constant TLB_PgSize_4KB   :=  0001 ;
      assign tlb_tag0_tid_notzero = |(tlb_tag0_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]);
      // these are used for direct and indirect page sizes
      assign tlb_tag0_hashed_addr = (tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB) ? size_1G_hashed_addr :
                                    (tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) ? size_256M_hashed_addr :
                                    (tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) ? size_16M_hashed_addr :
                                    (tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) ? size_1M_hashed_addr :
                                    (tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) ? size_64K_hashed_addr :
                                    size_4K_hashed_addr;
      assign tlb_tag0_hashed_tid0_addr = (tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB) ? size_1G_hashed_tid0_addr :
                                         (tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) ? size_256M_hashed_tid0_addr :
                                         (tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) ? size_16M_hashed_tid0_addr :
                                         (tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) ? size_1M_hashed_tid0_addr :
                                         (tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) ? size_64K_hashed_tid0_addr :
                                         size_4K_hashed_tid0_addr;
      // these are used for direct page sizes only
      assign tlb_hashed_addr1 = (mmucr2[28:31] == TLB_PgSize_1GB) ? size_1G_hashed_addr :
                                (mmucr2[28:31] == TLB_PgSize_16MB) ? size_16M_hashed_addr :
                                (mmucr2[28:31] == TLB_PgSize_1MB) ? size_1M_hashed_addr :
                                (mmucr2[28:31] == TLB_PgSize_64KB) ? size_64K_hashed_addr :
                                size_4K_hashed_addr;
      assign tlb_hashed_tid0_addr1 = (mmucr2[28:31] == TLB_PgSize_1GB) ? size_1G_hashed_tid0_addr :
                                     (mmucr2[28:31] == TLB_PgSize_16MB) ? size_16M_hashed_tid0_addr :
                                     (mmucr2[28:31] == TLB_PgSize_1MB) ? size_1M_hashed_tid0_addr :
                                     (mmucr2[28:31] == TLB_PgSize_64KB) ? size_64K_hashed_tid0_addr :
                                     size_4K_hashed_tid0_addr;
      assign tlb_hashed_addr2 = (mmucr2[24:27] == TLB_PgSize_1GB) ? size_1G_hashed_addr :
                                (mmucr2[24:27] == TLB_PgSize_16MB) ? size_16M_hashed_addr :
                                (mmucr2[24:27] == TLB_PgSize_1MB) ? size_1M_hashed_addr :
                                (mmucr2[24:27] == TLB_PgSize_64KB) ? size_64K_hashed_addr :
                                size_4K_hashed_addr;
      assign tlb_hashed_tid0_addr2 = (mmucr2[24:27] == TLB_PgSize_1GB) ? size_1G_hashed_tid0_addr :
                                     (mmucr2[24:27] == TLB_PgSize_16MB) ? size_16M_hashed_tid0_addr :
                                     (mmucr2[24:27] == TLB_PgSize_1MB) ? size_1M_hashed_tid0_addr :
                                     (mmucr2[24:27] == TLB_PgSize_64KB) ? size_64K_hashed_tid0_addr :
                                     size_4K_hashed_tid0_addr;
      assign tlb_hashed_addr3 = (mmucr2[20:23] == TLB_PgSize_1GB) ? size_1G_hashed_addr :
                                (mmucr2[20:23] == TLB_PgSize_16MB) ? size_16M_hashed_addr :
                                (mmucr2[20:23] == TLB_PgSize_1MB) ? size_1M_hashed_addr :
                                (mmucr2[20:23] == TLB_PgSize_64KB) ? size_64K_hashed_addr :
                                size_4K_hashed_addr;
      assign tlb_hashed_tid0_addr3 = (mmucr2[20:23] == TLB_PgSize_1GB) ? size_1G_hashed_tid0_addr :
                                     (mmucr2[20:23] == TLB_PgSize_16MB) ? size_16M_hashed_tid0_addr :
                                     (mmucr2[20:23] == TLB_PgSize_1MB) ? size_1M_hashed_tid0_addr :
                                     (mmucr2[20:23] == TLB_PgSize_64KB) ? size_64K_hashed_tid0_addr :
                                     size_4K_hashed_tid0_addr;
      assign tlb_hashed_addr4 = (mmucr2[16:19] == TLB_PgSize_1GB) ? size_1G_hashed_addr :
                                (mmucr2[16:19] == TLB_PgSize_16MB) ? size_16M_hashed_addr :
                                (mmucr2[16:19] == TLB_PgSize_1MB) ? size_1M_hashed_addr :
                                (mmucr2[16:19] == TLB_PgSize_64KB) ? size_64K_hashed_addr :
                                size_4K_hashed_addr;
      assign tlb_hashed_tid0_addr4 = (mmucr2[16:19] == TLB_PgSize_1GB) ? size_1G_hashed_tid0_addr :
                                     (mmucr2[16:19] == TLB_PgSize_16MB) ? size_16M_hashed_tid0_addr :
                                     (mmucr2[16:19] == TLB_PgSize_1MB) ? size_1M_hashed_tid0_addr :
                                     (mmucr2[16:19] == TLB_PgSize_64KB) ? size_64K_hashed_tid0_addr :
                                     size_4K_hashed_tid0_addr;
      assign tlb_hashed_addr5 = (mmucr2[12:15] == TLB_PgSize_1GB) ? size_1G_hashed_addr :
                                (mmucr2[12:15] == TLB_PgSize_16MB) ? size_16M_hashed_addr :
                                (mmucr2[12:15] == TLB_PgSize_1MB) ? size_1M_hashed_addr :
                                (mmucr2[12:15] == TLB_PgSize_64KB) ? size_64K_hashed_addr :
                                size_4K_hashed_addr;
      assign tlb_hashed_tid0_addr5 = (mmucr2[12:15] == TLB_PgSize_1GB) ? size_1G_hashed_tid0_addr :
                                     (mmucr2[12:15] == TLB_PgSize_16MB) ? size_16M_hashed_tid0_addr :
                                     (mmucr2[12:15] == TLB_PgSize_1MB) ? size_1M_hashed_tid0_addr :
                                     (mmucr2[12:15] == TLB_PgSize_64KB) ? size_64K_hashed_tid0_addr :
                                     size_4K_hashed_tid0_addr;
      assign pgsize1_valid = |(mmucr2[28:31]);
      assign pgsize2_valid = |(mmucr2[24:27]);
      assign pgsize3_valid = |(mmucr2[20:23]);
      assign pgsize4_valid = |(mmucr2[16:19]);
      assign pgsize5_valid = |(mmucr2[12:15]);
      assign pgsize1_tid0_valid = |(mmucr2[28:31]);
      assign pgsize2_tid0_valid = |(mmucr2[24:27]);
      assign pgsize3_tid0_valid = |(mmucr2[20:23]);
      assign pgsize4_tid0_valid = |(mmucr2[16:19]);
      assign pgsize5_tid0_valid = |(mmucr2[12:15]);
      assign pgsize_qty = ((pgsize5_valid == 1'b1 & pgsize4_valid == 1'b1 & pgsize3_valid == 1'b1 & pgsize2_valid == 1'b1 & pgsize1_valid == 1'b1)) ? 3'b101 :
                          ((pgsize4_valid == 1'b1 & pgsize3_valid == 1'b1 & pgsize2_valid == 1'b1 & pgsize1_valid == 1'b1)) ? 3'b100 :
                          ((pgsize3_valid == 1'b1 & pgsize2_valid == 1'b1 & pgsize1_valid == 1'b1)) ? 3'b011 :
                          ((pgsize2_valid == 1'b1 & pgsize1_valid == 1'b1)) ? 3'b010 :
                          ((pgsize1_valid == 1'b1)) ? 3'b001 :
                          3'b000;
      assign pgsize_tid0_qty = ((pgsize5_tid0_valid == 1'b1 & pgsize4_tid0_valid == 1'b1 & pgsize3_tid0_valid == 1'b1 & pgsize2_tid0_valid == 1'b1 & pgsize1_tid0_valid == 1'b1)) ? 3'b101 :
                               ((pgsize4_tid0_valid == 1'b1 & pgsize3_tid0_valid == 1'b1 & pgsize2_tid0_valid == 1'b1 & pgsize1_tid0_valid == 1'b1)) ? 3'b100 :
                               ((pgsize3_tid0_valid == 1'b1 & pgsize2_tid0_valid == 1'b1 & pgsize1_tid0_valid == 1'b1)) ? 3'b011 :
                               ((pgsize2_tid0_valid == 1'b1 & pgsize1_tid0_valid == 1'b1)) ? 3'b010 :
                               ((pgsize1_tid0_valid == 1'b1)) ? 3'b001 :
                               3'b000;
      assign derat_taken_d = (derat_req_taken_sig == 1'b1) ? 1'b1 :
                             (ierat_req_taken_sig == 1'b1) ? 1'b0 :
                             derat_taken_q;
      // ttype: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      assign tlb_read_req = ((|(ex1_valid_q) == 1'b1 & ex1_ttype_q[0] == 1'b1)) ? 1'b1 :
                            1'b0;
      assign tlb_write_req = ((|(ex1_valid_q) == 1'b1 & ex1_ttype_q[1] == 1'b1)) ? 1'b1 :
                             1'b0;
      assign tlb_search_req = ((|(ex2_valid_q) == 1'b1 & ex2_ttype_q[2:3] != 2'b00)) ? 1'b1 :
                              1'b0;
      assign tlb_searchresv_req = ((|(ex2_valid_q) == 1'b1 & ex2_ttype_q[4] == 1'b1)) ? 1'b1 :
                                  1'b0;
      assign tlb_seq_idle_sig = (tlb_seq_q == TlbSeq_Idle) ? 1'b1 :
                                1'b0;
      assign tlbwe_back_inv_holdoff = tlbwe_back_inv_pending & mmucr1_tlbwe_binv;
      assign tlb_seq_any_done_sig = tlb_seq_ierat_done_sig | tlb_seq_derat_done_sig | tlb_seq_snoop_done_sig | tlb_seq_search_done_sig | tlb_seq_searchresv_done_sig | tlb_seq_read_done_sig | tlb_seq_write_done_sig | tlb_seq_ptereload_done_sig;
      assign any_tlb_req_sig = snoop_val_q[0] | ptereload_req_valid | tlb_seq_ierat_req | tlb_seq_derat_req | tlb_search_req | tlb_searchresv_req | tlb_write_req | tlb_read_req;
      assign any_req_taken_sig = ierat_req_taken_sig | derat_req_taken_sig | snoop_req_taken_sig | search_req_taken_sig | searchresv_req_taken_sig | read_req_taken_sig | write_req_taken_sig | ptereload_req_taken_sig;
      assign tlb_tag4_hit_or_parerr = tlb_tag4_cmp_hit | tlb_tag4_parerr;

      // abort control sequencer back to state_idle
      //   tlbsx, tlbsrx, tlbre, tlbwe are flushable ops, so short-cycle sequencer
      assign tlb_seq_abort = |( tlb_tag0_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS -1] & (tlb_ctl_tag1_flush_sig | tlb_ctl_tag2_flush_sig | tlb_ctl_tag3_flush_sig | tlb_ctl_tag4_flush_sig) );

      assign tlb_seq_d = tlb_seq_next & {`TLB_SEQ_WIDTH{(~(tlb_seq_abort))}};


      // TLB access sequencer for multiple page size compares for reloads
      always @(tlb_seq_q or tlb_tag0_q[`tagpos_is + 1:`tagpos_is + 3] or tlb_tag0_q[`tagpos_size:`tagpos_size + 3] or
            tlb_tag0_q[`tagpos_type:`tagpos_type + 7] or tlb_tag0_q[`tagpos_type:`tagpos_type + 7] or tlb_tag1_q[`tagpos_endflag] or
            tlb_tag0_tid_notzero or tlb_tag0_q[`tagpos_nonspec] or tlb_tag4_hit_or_parerr or tlb_tag4_way_ind or tlb_addr_maxcntm1 or
            tlb_cmp_erat_dup_wait or tlb_seq_ierat_req or tlb_seq_derat_req or tlb_search_req or tlb_searchresv_req or snoop_val_q[0] or
            tlb_read_req or tlb_write_req or ptereload_req_valid or mmucr2[12:31] or derat_taken_q or
            tlb_hashed_addr1 or tlb_hashed_addr2 or tlb_hashed_addr3 or tlb_hashed_addr4 or tlb_hashed_addr5 or
            tlb_hashed_tid0_addr1 or tlb_hashed_tid0_addr2 or tlb_hashed_tid0_addr3 or tlb_hashed_tid0_addr4 or tlb_hashed_tid0_addr5 or
            pgsize2_valid or pgsize3_valid or pgsize4_valid or pgsize5_valid or
            pgsize2_tid0_valid or pgsize3_tid0_valid or pgsize4_tid0_valid or pgsize5_tid0_valid or
            size_1M_hashed_addr or size_1M_hashed_tid0_addr or size_256M_hashed_addr or size_256M_hashed_tid0_addr or
            tlb_tag0_hashed_addr or tlb_tag0_hashed_tid0_addr or tlb0cfg_ind or tlbwe_back_inv_holdoff)
      begin: Tlb_Sequencer
         tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
         tlb_seq_pgsize <= mmucr2[28:31];
         tlb_seq_ind <= 1'b0;
         tlb_seq_esel <= 3'b000;
         tlb_seq_is <= 2'b00;
         tlb_seq_tag0_addr_cap <= 1'b0;
         tlb_seq_addr_update <= 1'b0;
         tlb_seq_addr_clr <= 1'b0;
         tlb_seq_addr_incr <= 1'b0;
         tlb_seq_lrat_enable <= 1'b0;
         tlb_seq_endflag <= 1'b0;
         tlb_seq_ierat_done_sig <= 1'b0;
         tlb_seq_derat_done_sig <= 1'b0;
         tlb_seq_snoop_done_sig <= 1'b0;
         tlb_seq_search_done_sig <= 1'b0;
         tlb_seq_searchresv_done_sig <= 1'b0;
         tlb_seq_read_done_sig <= 1'b0;
         tlb_seq_write_done_sig <= 1'b0;
         tlb_seq_ptereload_done_sig <= 1'b0;
         tlb_seq_lru_rd_act <= 1'b0;
         tlb_seq_lru_wr_act <= 1'b0;
         ierat_req_taken_sig <= 1'b0;
         derat_req_taken_sig <= 1'b0;
         search_req_taken_sig <= 1'b0;
         searchresv_req_taken_sig <= 1'b0;
         snoop_req_taken_sig <= 1'b0;
         read_req_taken_sig <= 1'b0;
         write_req_taken_sig <= 1'b0;
         ptereload_req_taken_sig <= 1'b0;
         tlb_seq_set_resv <= 1'b0;
         tlb_seq_snoop_resv <= 1'b0;
         tlb_seq_snoop_inprogress <= 1'b0;

         case (tlb_seq_q)
         // wait for snoop, ptereload, erat miss, search, write, or read to service
            TlbSeq_Idle :
               if (snoop_val_q[0] == 1'b1)
               // service invalidate snoop
               begin
                  tlb_seq_next <= TlbSeq_Stg24;
                  snoop_req_taken_sig <= 1'b1;
                  tlb_seq_snoop_inprogress <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else if (ptereload_req_valid == 1'b1)
               // service pte reload
               begin
                  tlb_seq_next <= TlbSeq_Stg19;
                  ptereload_req_taken_sig <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else if (tlb_seq_ierat_req == 1'b1 & tlb_cmp_erat_dup_wait[0] == 1'b0 & tlb_cmp_erat_dup_wait[1] == 1'b0 & (derat_taken_q == 1'b1 | tlb_seq_derat_req == 1'b0))
               // service ierat miss
               begin
                  tlb_seq_next <= TlbSeq_Stg1;
                  ierat_req_taken_sig <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else if (tlb_seq_derat_req == 1'b1 & tlb_cmp_erat_dup_wait[0] == 1'b0 & tlb_cmp_erat_dup_wait[1] == 1'b0)
               begin
               // service derat miss
                  tlb_seq_next <= TlbSeq_Stg1;
                  derat_req_taken_sig <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else if (tlb_search_req == 1'b1)
               // service search
               begin
                  tlb_seq_next <= TlbSeq_Stg1;
                  search_req_taken_sig <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else if (tlb_searchresv_req == 1'b1)
               // service search and reserve
               begin
                  tlb_seq_next <= TlbSeq_Stg1;
                  searchresv_req_taken_sig <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else if (tlb_write_req == 1'b1 & tlbwe_back_inv_holdoff == 1'b0)
               // service write
               begin
                  tlb_seq_next <= TlbSeq_Stg19;
                  write_req_taken_sig <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else if (tlb_read_req == 1'b1)
               // service read
               begin
                  tlb_seq_next <= TlbSeq_Stg19;
                  read_req_taken_sig <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else
                  tlb_seq_next <= TlbSeq_Idle;

            TlbSeq_Stg1 :
            // tag0 phase, erat miss, or ex3 phase tlbsx/tlbsrx
               begin
                  tlb_seq_tag0_addr_cap <= 1'b1;
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_addr1;  // hash for tid=pid page size 1
                  tlb_seq_pgsize <= mmucr2[28:31];
                  tlb_seq_is <= 2'b00;      // ind=0, tid/=0 pages
                  tlb_seq_esel <= 3'b001;   // page 1
                  tlb_seq_lru_rd_act <= 1'b1;
                  if (pgsize2_valid == 1'b1)
                     tlb_seq_next <= TlbSeq_Stg2;
                  else
                     tlb_seq_next <= TlbSeq_Stg6;
               end

            TlbSeq_Stg2 :
            // tag1 phase, ex4 phase
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_addr2;  // hash for tid=pid page size 2
                  tlb_seq_pgsize <= mmucr2[24:27];
                  tlb_seq_is <= 2'b00;      // ind=0, tid/=0 pages
                  tlb_seq_esel <= 3'b010;   // page 2
                  tlb_seq_lru_rd_act <= 1'b1;
                  if (pgsize3_valid == 1'b1)
                     tlb_seq_next <= TlbSeq_Stg3;
                  else
                     tlb_seq_next <= TlbSeq_Stg6;
               end

            TlbSeq_Stg3 :
            // tag2 phase, ex5 phase
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_addr3;  // hash for tid=pid page size 3
                  tlb_seq_pgsize <= mmucr2[20:23];
                  tlb_seq_is <= 2'b00;      // ind=0, tid/=0 pages
                  tlb_seq_esel <= 3'b011;   // page 3
                  tlb_seq_lru_rd_act <= 1'b1;
                  if (pgsize4_valid == 1'b1)
                     tlb_seq_next <= TlbSeq_Stg4;
                  else
                     tlb_seq_next <= TlbSeq_Stg6;
               end

            TlbSeq_Stg4 :
            // tag3 phase, ex6 phase
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_addr4;  // hash for tid=pid page size 4
                  tlb_seq_pgsize <= mmucr2[16:19];
                  tlb_seq_is <= 2'b00;      // ind=0, tid/=0 pages
                  tlb_seq_esel <= 3'b100;   // page 4
                  tlb_seq_lru_rd_act <= 1'b1;
                  if (pgsize5_valid == 1'b1)
                     tlb_seq_next <= TlbSeq_Stg5;
                  else
                     tlb_seq_next <= TlbSeq_Stg6;
               end

            TlbSeq_Stg5 :
            // tag4 phase, ex7 phase
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_addr5;  // hash for tid=pid page size 5
                  tlb_seq_pgsize <= mmucr2[12:15];
                  tlb_seq_is <= 2'b00;      // ind=0, tid/=0 pages
                  tlb_seq_esel <= 3'b101;   // page 5
                  if (tlb_tag4_hit_or_parerr == 1'b1 & |(tlb_tag0_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg30;
                     tlb_seq_lru_rd_act <= 1'b0;
                    end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b0)
                    begin
                     tlb_seq_next <= TlbSeq_Stg31;
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else
                    begin
                     tlb_seq_next <= TlbSeq_Stg6;
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
               end

            TlbSeq_Stg6 :
            // start checking ind=0, tid=0 page possibilites
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_tid0_addr1;  // hash for tid=0 page size 1
                  tlb_seq_pgsize <= mmucr2[28:31];
                  tlb_seq_is <= 2'b01;      // ind=0, tid=0 pages
                  tlb_seq_esel <= 3'b001;   // page 1
                  if (tlb_tag4_hit_or_parerr == 1'b1 & |(tlb_tag0_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) == 1'b1)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg30;
                     tlb_seq_lru_rd_act <= 1'b0;
                    end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b0)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg31;
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else if (pgsize2_tid0_valid == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg7;  // check next page hash
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else if (tlb0cfg_ind == 1'b1 & tlb_tag0_q[`tagpos_nonspec] == 1'b1)  // this is a non-speculative erat miss
                    begin
                     tlb_seq_next <= TlbSeq_Stg11;  // check indirect entries
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else
                  begin
                     tlb_seq_endflag <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg15;  // start of wait states
                     tlb_seq_lru_rd_act <= 1'b1;
                  end
               end

            TlbSeq_Stg7 :
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_tid0_addr2;  // hash for tid=0 page size 2
                  tlb_seq_pgsize <= mmucr2[24:27];
                  tlb_seq_is <= 2'b01;      // ind=0, tid=0 pages
                  tlb_seq_esel <= 3'b010;   // page 2
                  if (tlb_tag4_hit_or_parerr == 1'b1 & |(tlb_tag0_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) == 1'b1)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg30;
                     tlb_seq_lru_rd_act <= 1'b0;
                    end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b0)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg31;
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else if (pgsize3_tid0_valid == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg8;  // check next page hash
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else if (tlb0cfg_ind == 1'b1 & tlb_tag0_q[`tagpos_nonspec] == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg11;  // check indirect entries
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else
                  begin
                     tlb_seq_endflag <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg15;  // start of wait states
                     tlb_seq_lru_rd_act <= 1'b1;
                  end
               end

            TlbSeq_Stg8 :
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_tid0_addr3;  // hash for tid=0 page size 3
                  tlb_seq_pgsize <= mmucr2[20:23];
                  tlb_seq_is <= 2'b01;      // ind=0, tid=0 pages
                  tlb_seq_esel <= 3'b011;   // page 3
                  if (tlb_tag4_hit_or_parerr == 1'b1 & |(tlb_tag0_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) == 1'b1)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg30;
                     tlb_seq_lru_rd_act <= 1'b0;
                    end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b0)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg31;
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else if (pgsize4_tid0_valid == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg9;  // check next page hash
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else if (tlb0cfg_ind == 1'b1 & tlb_tag0_q[`tagpos_nonspec] == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg11;  // check indirect entries
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else
                  begin
                     tlb_seq_endflag <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg15;  // start of wait states
                     tlb_seq_lru_rd_act <= 1'b1;
                  end
               end

            TlbSeq_Stg9 :
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_tid0_addr4;  // hash for tid=0 page size 4
                  tlb_seq_pgsize <= mmucr2[16:19];
                  tlb_seq_is <= 2'b01;      // ind=0, tid=0 pages
                  tlb_seq_esel <= 3'b100;   // page 4
                  if (tlb_tag4_hit_or_parerr == 1'b1 & |(tlb_tag0_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) == 1'b1)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg30;
                     tlb_seq_lru_rd_act <= 1'b0;
                    end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b0)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg31;
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else if (pgsize5_tid0_valid == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg10;  // check next page hash
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else if (tlb0cfg_ind == 1'b1 & tlb_tag0_q[`tagpos_nonspec] == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg11;  // check indirect entries
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else
                   begin
                     tlb_seq_endflag <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg15;  // start of wait states
                     tlb_seq_lru_rd_act <= 1'b1;
                   end
               end

            TlbSeq_Stg10 :
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_tid0_addr5;  // hash for tid=0 page size 5
                  tlb_seq_pgsize <= mmucr2[12:15];
                  tlb_seq_is <= 2'b01;      // ind=0, tid=0 pages
                  tlb_seq_esel <= 3'b101;   // page 5
                  if (tlb_tag4_hit_or_parerr == 1'b1 & |(tlb_tag0_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) == 1'b1)
                   begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg30;
                     tlb_seq_lru_rd_act <= 1'b0;
                   end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b0)
                   begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg31;
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                   end
                  else if (tlb0cfg_ind == 1'b1 & tlb_tag0_q[`tagpos_nonspec] == 1'b1)
                   begin
                     tlb_seq_next <= TlbSeq_Stg11;  // go check for indirect entries
                     tlb_seq_lru_rd_act <= 1'b1;
                   end
                  else
                   begin
                     tlb_seq_endflag <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg15;  // start of wait states
                     tlb_seq_lru_rd_act <= 1'b1;
                   end
               end

            TlbSeq_Stg11 :
            // indirect entry size 1MB, 4K sub-pages, tid/=0
               begin
                  tlb_seq_ind <= 1'b1;
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= size_1M_hashed_addr;
                  tlb_seq_pgsize <= TLB_PgSize_1MB;
                  tlb_seq_is <= 2'b10;      // ind=1, tid/=0 pages
                  tlb_seq_esel <= 3'b001;   // page 1
                  if (tlb_tag4_hit_or_parerr == 1'b1 & |(tlb_tag0_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) == 1'b1)
                   begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg30;
                     tlb_seq_lru_rd_act <= 1'b0;
                   end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b0)
                   begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg31;
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                   end
                  else
                   begin
                     tlb_seq_next <= TlbSeq_Stg12;  // next ind=1 page size
                     tlb_seq_lru_rd_act <= 1'b1;
                   end
               end

            TlbSeq_Stg12 :
            // indirect entry size 256MB, 64K sub-pages, tid/=0
               begin
                  tlb_seq_ind <= 1'b1;
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= size_256M_hashed_addr;
                  tlb_seq_pgsize <= TLB_PgSize_256MB;
                  tlb_seq_is <= 2'b10;      // ind=1, tid/=0 pages
                  tlb_seq_esel <= 3'b010;   // page 2
                  if (tlb_tag4_hit_or_parerr == 1'b1 & |(tlb_tag0_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) == 1'b1)
                   begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg30;
                     tlb_seq_lru_rd_act <= 1'b0;
                   end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b0)
                   begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg31;
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                   end
                  else
                   begin
                     tlb_seq_next <= TlbSeq_Stg13;  // go check for ind=1, tid=0 pages
                     tlb_seq_lru_rd_act <= 1'b1;
                   end
               end

            TlbSeq_Stg13 :
            // indirect entry size 1MB, 4K sub-pages, tid=0
               begin
                  tlb_seq_ind <= 1'b1;
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= size_1M_hashed_tid0_addr;
                  tlb_seq_pgsize <= TLB_PgSize_1MB;
                  tlb_seq_is <= 2'b11;      // ind=1, tid=0 pages
                  tlb_seq_esel <= 3'b001;   // page 1
                  if (tlb_tag4_hit_or_parerr == 1'b1 & |(tlb_tag0_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) == 1'b1)
                   begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg30;
                     tlb_seq_lru_rd_act <= 1'b0;
                   end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b0)
                   begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg31;
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                   end
                  else
                   begin
                     tlb_seq_next <= TlbSeq_Stg14;  // next page size
                     tlb_seq_lru_rd_act <= 1'b1;
                   end
               end

            TlbSeq_Stg14 :
            // indirect entry size 256MB, 64K sub-pages, tid=0
               begin
                  tlb_seq_ind <= 1'b1;
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= size_256M_hashed_tid0_addr;
                  tlb_seq_pgsize <= TLB_PgSize_256MB;
                  tlb_seq_is <= 2'b11;      // ind=1, tid=0 pages
                  tlb_seq_esel <= 3'b010;   // page 2
                  if (tlb_tag4_hit_or_parerr == 1'b1 & |(tlb_tag0_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) == 1'b1)
                   begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg30;
                     tlb_seq_lru_rd_act <= 1'b0;
                   end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b0)
                   begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg31;
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                   end
                  else
                   begin
                     tlb_seq_endflag <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg15;
                     tlb_seq_lru_rd_act <= 1'b1;
                   end
               end

            TlbSeq_Stg15 :
            // wait_state_tag1 ..wait for results..
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  if (tlb_tag4_hit_or_parerr == 1'b1 & |(tlb_tag0_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) == 1'b1)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg30;
                     tlb_seq_lru_rd_act <= 1'b0;
                    end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b0)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg31;
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b1 & |(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_ierat]) == 1'b1 & tlb_tag0_q[`tagpos_type_ptereload] == 1'b0)
                    begin
                     // results for previous indirect page size
                     tlb_seq_next <= TlbSeq_Stg29;  // handoff to table walker, or tlb_inelig if pt=0
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else
                    begin
                     tlb_seq_next <= TlbSeq_Stg16;  // next wait state
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
               end

            TlbSeq_Stg16 :
            // wait_state_tag2 ..wait for results..
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  if (tlb_tag4_hit_or_parerr == 1'b1 & |(tlb_tag0_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) == 1'b1)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg30;
                     tlb_seq_lru_rd_act <= 1'b0;
                    end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b0)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg31;
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b1)
                    begin
                     // results for previous indirect page size
                     tlb_seq_next <= TlbSeq_Stg29;  // handoff to table walker, or tlb_inelig if pt=0
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else
                    begin
                     tlb_seq_next <= TlbSeq_Stg17;  // next wait state
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
               end

            TlbSeq_Stg17 :
            // wait_state_tag3 ..wait for results..
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  if (tlb_tag4_hit_or_parerr == 1'b1 & |(tlb_tag0_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) == 1'b1)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg30;
                     tlb_seq_lru_rd_act <= 1'b0;
                    end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b0)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg31;
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b1)
                    begin
                     // results for previous indirect page size
                     tlb_seq_next <= TlbSeq_Stg29;  // handoff to table walker, or tlb_inelig if pt=0
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else
                    begin
                     tlb_seq_next <= TlbSeq_Stg18;  // next wait state
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
               end

            TlbSeq_Stg18 :
            // wait_state_tag4 ..wait for results..
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  if (tlb_tag4_hit_or_parerr == 1'b1 & |(tlb_tag0_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) == 1'b1)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg30;
                     tlb_seq_lru_rd_act <= 1'b0;
                    end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b0)
                    begin
                     // results for previous direct page size
                     tlb_seq_next <= TlbSeq_Stg31;
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b1)
                    begin
                     // results for previous indirect page size
                     tlb_seq_next <= TlbSeq_Stg29;  // handoff to table walker, or tlb_inelig if pt=0
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else
                    begin
                     tlb_seq_next <= TlbSeq_Stg30;  // tlb miss
                     tlb_seq_lru_rd_act <= 1'b0;
                    end
               end

            TlbSeq_Stg19 :
            // tag0 (ex2) tlbre,tlbwe (flushable), or ptereload (not flushable)
               begin
                  tlb_seq_pgsize <= tlb_tag0_q[`tagpos_size:`tagpos_size + 3];
                  tlb_seq_tag0_addr_cap <= 1'b1;
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
                  if (tlb_tag0_tid_notzero == 1'b1)
                     tlb_seq_addr <= tlb_tag0_hashed_addr;
                  else
                     tlb_seq_addr <= tlb_tag0_hashed_tid0_addr;
                  tlb_seq_next <= TlbSeq_Stg20;
               end

            TlbSeq_Stg20 :
            // tag1 (ex3) tlbre,tlbwe, or ptereload
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_lru_rd_act <= 1'b1;
                  tlb_seq_next <= TlbSeq_Stg21;
               end

            TlbSeq_Stg21 :
            // tag2 (ex4) tlbre,tlbwe, or ptereload
               begin
                  tlb_seq_lrat_enable <= tlb_tag0_q[`tagpos_type_tlbwe] | tlb_tag0_q[`tagpos_type_ptereload];
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_lru_rd_act <= 1'b1;
                  tlb_seq_next <= TlbSeq_Stg22;
               end

            TlbSeq_Stg22 :
            // tag3 (ex5) tlbre,tlbwe, or ptereload
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_lru_rd_act <= 1'b1;
                  tlb_seq_next <= TlbSeq_Stg23;
               end

            TlbSeq_Stg23 :
            // tag4 (ex6) tlbre,tlbwe, or ptereload
            // tag type bits --> derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_read_done_sig <= tlb_tag0_q[`tagpos_type_tlbre];
                  tlb_seq_write_done_sig <= tlb_tag0_q[`tagpos_type_tlbwe];
                  tlb_seq_ptereload_done_sig <= tlb_tag0_q[`tagpos_type_ptereload];
                  if (tlb_tag0_q[`tagpos_type_tlbre] == 1'b1)
                    begin
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b0;
                     tlb_seq_next <= TlbSeq_Idle;  // done with read or write
                    end
                  else
                    begin
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg31; // tlbwe, or ptereload to erat thread stall clear
                    end
               end

            TlbSeq_Stg24 :
            // invalidate snoop start,  snoop_wait_state_tag0
               begin
                  tlb_seq_snoop_inprogress <= 1'b1;
                  tlb_seq_pgsize <= tlb_tag0_q[`tagpos_size:`tagpos_size + 3];
                  tlb_seq_tag0_addr_cap <= 1'b1;
                  tlb_seq_snoop_resv <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
                  tlb_seq_lru_wr_act <= 1'b0;
                  // IS1/Class: 0=all, 1=tid, 2=gs, 3=vpn, 4=class0, 5=class1, 6=class2, 7=class3
                  if (tlb_tag0_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011)
                  // inval by vpn, local or global
                   begin
                     tlb_seq_addr_update <= 1'b1;
                     tlb_seq_addr_clr <= 1'b0;
                     tlb_seq_endflag <= 1'b1;   // endflag now, no loop
                   end
                  else
                   begin
                     tlb_seq_addr_update <= 1'b0;
                     tlb_seq_addr_clr <= 1'b1;  // clear tlb_addr for loop scenarios
                     tlb_seq_endflag <= 1'b0;   // endflag later for loop scenarios
                   end
                  if (tlb_tag0_tid_notzero == 1'b1)
                     tlb_seq_addr <= tlb_tag0_hashed_addr;
                  else
                     tlb_seq_addr <= tlb_tag0_hashed_tid0_addr;
                  tlb_seq_next <= TlbSeq_Stg25;
               end

            TlbSeq_Stg25 :
            // snoop_wait_state_tag1 ..wait for results..
            //  IS1/Class: 0=all, 1=tid, 2=gs, 3=vpn, 4=class0, 5=class1, 6=class2, 7=class3
               begin
                  tlb_seq_snoop_inprogress <= 1'b1;
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  if (tlb_tag0_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011)
                  // inval by vpn, local or global
                   begin
                     tlb_seq_addr_incr <= 1'b0;
                     tlb_seq_endflag <= 1'b0;
                   end
                  else
                   begin
                     tlb_seq_addr_incr <= 1'b1;  // increment tlb_addr for loop scenarios
                     tlb_seq_endflag <= tlb_addr_maxcntm1;
                   end
                  if (tlb_tag0_q[`tagpos_is + 1:`tagpos_is + 3] != 3'b011 & tlb_tag1_q[`tagpos_endflag] == 1'b0)
                   begin
                     tlb_seq_lru_rd_act <= 1'b1;
                     tlb_seq_lru_wr_act <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg25;  // loop until tag1 endflag
                   end
                  else if (tlb_tag0_q[`tagpos_is + 1:`tagpos_is + 3] != 3'b011 & tlb_tag1_q[`tagpos_endflag] == 1'b1)
                   begin
                     tlb_seq_lru_rd_act <= 1'b1;  // allows lru rd_addr to update to x00
                     tlb_seq_lru_wr_act <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg26;  // loop complete
                   end
                  else
                   begin
                     tlb_seq_lru_rd_act <= 1'b1;
                     tlb_seq_lru_wr_act <= 1'b0;
                     tlb_seq_next <= TlbSeq_Stg26;  // by vpn
                   end
               end

            TlbSeq_Stg26 :
            // snoop_wait_state_tag2 ..wait for results..
               begin
                  tlb_seq_snoop_inprogress <= 1'b1;
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_lru_rd_act <= 1'b0;
                  tlb_seq_lru_wr_act <= 1'b1;
                  tlb_seq_next <= TlbSeq_Stg27;
               end

            TlbSeq_Stg27 :
            // snoop_wait_state_tag3 ..wait for results..
               begin
                  tlb_seq_snoop_inprogress <= 1'b1;
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_lru_rd_act <= 1'b0;
                  tlb_seq_lru_wr_act <= 1'b1;
                  tlb_seq_next <= TlbSeq_Stg28;
               end

            TlbSeq_Stg28 :
            // snoop_wait_state_tag4 ..wait for results..
               begin
                  tlb_seq_snoop_inprogress <= 1'b1;
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_lru_rd_act <= 1'b0;
                  tlb_seq_lru_wr_act <= 1'b1;
                  tlb_seq_next <= TlbSeq_Stg31;  // invalidate snoop goto complete
               end

            TlbSeq_Stg29 :
            // ind=1 hit jumps here
            //  tag5, handoff to hw table walker and reservations updated
               begin
                  tlb_seq_derat_done_sig <= tlb_tag0_q[`tagpos_type_derat] & (~tlb_tag0_q[`tagpos_type_ptereload]);
                  tlb_seq_ierat_done_sig <= tlb_tag0_q[`tagpos_type_ierat] & (~tlb_tag0_q[`tagpos_type_ptereload]);
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_lru_wr_act <= 1'b1;
                  tlb_seq_next <= TlbSeq_Idle;   // go idle
               end

            TlbSeq_Stg30 :
            // tlb miss, or search hit/miss,  jumps here..
            //  wait for possible exceptions to be asserted
            //  tag type bits --> derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_derat_done_sig <= tlb_tag0_q[`tagpos_type_derat] & (~tlb_tag0_q[`tagpos_type_ptereload]);
                  tlb_seq_ierat_done_sig <= tlb_tag0_q[`tagpos_type_ierat] & (~tlb_tag0_q[`tagpos_type_ptereload]);
                  tlb_seq_search_done_sig <= tlb_tag0_q[`tagpos_type_tlbsx];
                  tlb_seq_searchresv_done_sig <= tlb_tag0_q[`tagpos_type_tlbsrx];
                  tlb_seq_snoop_done_sig <= tlb_tag0_q[`tagpos_type_snoop];
                  tlb_seq_snoop_inprogress <= tlb_tag0_q[`tagpos_type_snoop];
                  tlb_seq_set_resv <= tlb_tag0_q[`tagpos_type_tlbsrx];
                  tlb_seq_lru_rd_act <= 1'b0;
                  tlb_seq_lru_wr_act <= 1'b0;

                  tlb_seq_next <= TlbSeq_Idle;
               end

            TlbSeq_Stg31 :
            // direct entry hits, tlbwe, ptereloads, and snoops jump here..
            //  tag5,  lru update, erat reloads, and/or ptereload write into tlb
            //  tag type bits --> derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_derat_done_sig <= tlb_tag0_q[`tagpos_type_derat] & (~tlb_tag0_q[`tagpos_type_ptereload]);
                  tlb_seq_ierat_done_sig <= tlb_tag0_q[`tagpos_type_ierat] & (~tlb_tag0_q[`tagpos_type_ptereload]);
                  tlb_seq_search_done_sig <= tlb_tag0_q[`tagpos_type_tlbsx];
                  tlb_seq_searchresv_done_sig <= tlb_tag0_q[`tagpos_type_tlbsrx];
                  tlb_seq_snoop_done_sig <= tlb_tag0_q[`tagpos_type_snoop];
                  tlb_seq_snoop_inprogress <= tlb_tag0_q[`tagpos_type_snoop];
                  tlb_seq_set_resv <= tlb_tag0_q[`tagpos_type_tlbsrx];
                  tlb_seq_lru_rd_act <= 1'b0;
                  tlb_seq_lru_wr_act <= 1'b1;

                  if (tlb_tag0_q[`tagpos_type_ierat] == 1'b1 | tlb_tag0_q[`tagpos_type_derat] == 1'b1 | tlb_tag0_q[`tagpos_type_ptereload] == 1'b1)
                     tlb_seq_next <= TlbSeq_Stg32;
                  else
                     tlb_seq_next <= TlbSeq_Idle;
               end

            TlbSeq_Stg32 :
            // end of ptereload
            //  tag6, wait for erat duplicates to be cleared in tlb_req, and reservations updated
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_next <= TlbSeq_Idle;
                  tlb_seq_lru_rd_act <= 1'b0;
                  tlb_seq_lru_wr_act <= 1'b0;
               end

            default :
               tlb_seq_next <= TlbSeq_Idle;

         endcase
      end

      assign ierat_req_taken = ierat_req_taken_sig;
      assign derat_req_taken = derat_req_taken_sig;
      assign tlb_seq_ierat_done = tlb_seq_ierat_done_sig;
      assign tlb_seq_derat_done = tlb_seq_derat_done_sig;
      assign ptereload_req_taken = ptereload_req_taken_sig;
      assign tlb_seq_idle = tlb_seq_idle_sig;
      // snoop_val: 0 -> valid, 1 -> ack
      assign snoop_val_d[0] = (snoop_val_q[0] == 1'b0) ? tlb_snoop_val :
                              (snoop_req_taken_sig == 1'b1) ? 1'b0 :
                              snoop_val_q[0];
      assign snoop_val_d[1] = tlb_seq_snoop_done_sig;
      assign tlb_snoop_ack = snoop_val_q[1];
      // snoop_attr:
      //          0 -> Local
      //        1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=epn, 4=class0, 5=class1, 6=class2, 7=class3
      //        4:5 -> GS/TS
      //       6:13 -> TID(6:13)
      //      14:17 -> Size
      //      18    -> reserved for tlb, extclass_enable(0) for erats
      //      19    -> mmucsr0.tlb0fi for tlb, or TID_NZ for erats
      //      20:25 -> TID(0:5)
      //      26:33 -> LPID
      //      34    -> IND
      assign snoop_attr_d = (snoop_val_q[0] == 1'b0) ? tlb_snoop_attr :
                            snoop_attr_q;
      assign snoop_vpn_d[52 - `EPN_WIDTH:51] = (snoop_val_q[0] == 1'b0) ? tlb_snoop_vpn :
                                              snoop_vpn_q[52 - `EPN_WIDTH:51];
      assign ptereload_req_pte_d = (ptereload_req_taken_sig == 1'b1) ? ptereload_req_pte :
                                   ptereload_req_pte_q;
      assign ptereload_req_pte_lat = ptereload_req_pte_q;
      //tlb_tag0_d <= ( 0:51   epn &
      //                52:65  pid &
      //                66:67  IS &
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
      //                100:102  esel &
      //                103:105  hes/wq(0:1) &
      //                106:107  lrat/pt &
      //                108  record form
      //                109  endflag
      //  `tagpos_epn      : natural  := 0;
      //  `tagpos_pid      : natural  := 52; -- 14 bits
      //  `tagpos_is       : natural  := 66;
      //  `tagpos_class    : natural  := 68;
      //  `tagpos_state    : natural  := 70; -- state: 0:pr 1:gs 2:as 3:cm
      //  `tagpos_thdid    : natural  := 74;
      //  `tagpos_size     : natural  := 78;
      //  `tagpos_type    : natural  := 82; -- derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      //  `tagpos_lpid     : natural  := 90;
      //  `tagpos_ind      : natural  := 98;
      //  `tagpos_atsel    : natural  := 99;
      //  `tagpos_esel     : natural  := 100;
      //  `tagpos_hes      : natural  := 103;
      //  `tagpos_wq       : natural  := 104;
      //  `tagpos_lrat     : natural  := 106;
      //  `tagpos_pt       : natural  := 107;
      //  `tagpos_recform  : natural  := 108;
      //  `tagpos_endflag  : natural  := 109;
      // snoop_attr:
      //          0 -> Local
      //        1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=epn, 4=class0, 5=class1, 6=class2, 7=class3
      //        4:5 -> GS/TS
      //       6:13 -> TID(6:13)
      //      14:17 -> Size
      //      18    -> reserved for tlb, extclass_enable(0) for erats
      //      19    -> mmucsr0.tlb0fi for tlb, or TID_NZ for erats
      //      20:25 -> TID(0:5)
      //      26:33 -> LPID
      //      34    -> IND
      // TAG PHASE (q)  DESCRPTION                      OPERATION / EXn
      // -1    prehash arb                tlbwe ex1  tlbre ex1  tlbsx ex2   tlbsrx ex2
      //  0    hash calc                  tlbwe ex2  tlbre ex2  tlbsx ex3   tlbsrx ex3
      //  1    tlb/lru cc addr            tlbwe ex3  tlbre ex3  tlbsx ex4   tlbsrx ex4
      //  2    tlb/lru data out           tlbwe ex4  tlbre ex4  tlbsx ex5   tlbsrx ex5
      //  3    comp & select              tlbwe ex5  tlbre ex5  tlbsx ex6   tlbsrx ex6
      //  4    tlb/lru/mas update         tlbwe ex6  tlbre ex6  tlbsx ex7   tlbsrx ex7
      //  5    erat reload
      assign tlb_ctl_tag1_flush_sig = ((tlb_tag0_q[`tagpos_type_tlbre] == 1'b1 | tlb_tag0_q[`tagpos_type_tlbwe] == 1'b1)) ? ex3_flush_q :
                                      ((tlb_tag0_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag0_q[`tagpos_type_tlbsrx] == 1'b1)) ? ex4_flush_q :
                                      {`MM_THREADS{1'b0}};
      assign tlb_ctl_tag2_flush_sig = ((tlb_tag0_q[`tagpos_type_tlbre] == 1'b1 | tlb_tag0_q[`tagpos_type_tlbwe] == 1'b1)) ? ex4_flush_q :
                                      ((tlb_tag0_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag0_q[`tagpos_type_tlbsrx] == 1'b1)) ? ex5_flush_q :
                                      {`MM_THREADS{1'b0}};
      assign tlb_ctl_tag3_flush_sig = ((tlb_tag0_q[`tagpos_type_tlbre] == 1'b1 | tlb_tag0_q[`tagpos_type_tlbwe] == 1'b1)) ? ex5_flush_q :
                                      ((tlb_tag0_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag0_q[`tagpos_type_tlbsrx] == 1'b1)) ? ex6_flush_q :
                                      {`MM_THREADS{1'b0}};
      assign tlb_ctl_tag4_flush_sig = ((tlb_tag0_q[`tagpos_type_tlbre] == 1'b1 | tlb_tag0_q[`tagpos_type_tlbwe] == 1'b1)) ? ex6_flush_q :
                                      {`MM_THREADS{1'b0}};
      assign tlb_ctl_any_tag_flush_sig = |(tlb_ctl_tag1_flush_sig | tlb_ctl_tag2_flush_sig | tlb_ctl_tag3_flush_sig | tlb_ctl_tag4_flush_sig);
      assign tlb_ctl_tag2_flush = tlb_ctl_tag2_flush_sig | tlb_ctl_tag3_flush_sig | tlb_ctl_tag4_flush_sig;
      assign tlb_ctl_tag3_flush = tlb_ctl_tag3_flush_sig | tlb_ctl_tag4_flush_sig;
      assign tlb_ctl_tag4_flush = tlb_ctl_tag4_flush_sig;

      //                        0     1     2     3      4     5     6     7
      //     tag type bits --> derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      //  tag -1 phase, tlbwe/re ex1, tlbsx/srx ex2
      //tlb_tag0_d(`tagpos_type to `tagpos_type+7) <=
      //         ptereload_req_tag(`tagpos_type to `tagpos_type+1) &  000001  when ptereload_req_taken_sig='1'
      //         else  00000010  when write_req_taken_sig='1'
      //         else  00000100  when read_req_taken_sig='1'
      //         else  00001000  when snoop_req_taken_sig='1'
      //         else  00010000  when searchresv_req_taken_sig='1'
      //         else  00100000  when search_req_taken_sig='1'
      //         else  01000000  when ierat_req_taken_sig='1'
      //         else  10000000  when derat_req_taken_sig='1'
      //         else  00000000  when (tlb_seq_ierat_done_sig='1' or tlb_seq_derat_done_sig='1' or
      //                                  tlb_seq_snoop_done_sig='1' or tlb_seq_search_done_sig='1' or
      //                                   tlb_seq_searchresv_done_sig ='1' or tlb_seq_read_done_sig ='1' or
      //                                    tlb_seq_write_done_sig ='1' or tlb_seq_ptereload_done_sig ='1' or tlb_seq_abort='1')
      //         else tlb_tag0_q(`tagpos_type to `tagpos_type+7);
      assign tlb_tag0_d[`tagpos_type_derat] = (derat_req_taken_sig) |
                                                (ptereload_req_tag[`tagpos_type_derat] & ptereload_req_taken_sig) |
                                                (tlb_tag0_q[`tagpos_type_derat] & (~tlb_seq_any_done_sig) & (~tlb_seq_abort));

      assign tlb_tag0_d[`tagpos_type_ierat] = (ierat_req_taken_sig) |
                                                (ptereload_req_tag[`tagpos_type_ierat] & ptereload_req_taken_sig) |
                                                (tlb_tag0_q[`tagpos_type_ierat] & (~tlb_seq_any_done_sig) & (~tlb_seq_abort));

      assign tlb_tag0_d[`tagpos_type_tlbsx] = (search_req_taken_sig) |
                                                (tlb_tag0_q[`tagpos_type_tlbsx] & (~tlb_seq_any_done_sig) & (~tlb_seq_abort));

      assign tlb_tag0_d[`tagpos_type_tlbsrx] = (searchresv_req_taken_sig) |
                                                 (tlb_tag0_q[`tagpos_type_tlbsrx] & (~tlb_seq_any_done_sig) & (~tlb_seq_abort));

      assign tlb_tag0_d[`tagpos_type_snoop] = (snoop_req_taken_sig) |
                                                (tlb_tag0_q[`tagpos_type_snoop] & (~tlb_seq_any_done_sig) & (~tlb_seq_abort));

      assign tlb_tag0_d[`tagpos_type_tlbre] = (read_req_taken_sig) |
                                                (tlb_tag0_q[`tagpos_type_tlbre] & (~tlb_seq_any_done_sig) & (~tlb_seq_abort));

      assign tlb_tag0_d[`tagpos_type_tlbwe] = (write_req_taken_sig) |
                                                (tlb_tag0_q[`tagpos_type_tlbwe] & (~tlb_seq_any_done_sig) & (~tlb_seq_abort));

      assign tlb_tag0_d[`tagpos_type_ptereload] = (ptereload_req_taken_sig) |
                                                     (tlb_tag0_q[`tagpos_type_ptereload] & (~tlb_seq_any_done_sig) & (~tlb_seq_abort));

      // state: 0:pr 1:gs 2:as 3:cm
      //tlb_tag0_d(`tagpos_epn to `tagpos_epn+`EPN_WIDTH-1) <=
      //         ptereload_req_tag(`tagpos_epn to `tagpos_epn+`EPN_WIDTH-1) when ptereload_req_taken_sig='1'
      //         else ex1_mas2_epn   when write_req_taken_sig='1'
      //         else ex1_mas2_epn   when read_req_taken_sig='1'
      //         else snoop_vpn_q    when snoop_req_taken_sig='1'
      // IFDEF(CAT_EMF)
      //         else xu_mm_ex2_epn   when searchresv_req_taken_sig='1'
      //         else xu_mm_ex2_epn   when search_req_taken_sig='1'
      // ELSE
      //         else xu_mm_ex1_rb   when searchresv_req_taken_sig='1'
      //         else xu_mm_ex1_rb   when search_req_taken_sig='1'
      // ENDIF
      //         else ierat_req_epn  when ierat_req_taken_sig='1'
      //         else derat_req_epn  when derat_req_taken_sig='1'
      //         else tlb_tag0_q(`tagpos_epn to `tagpos_epn+`EPN_WIDTH-1);

      generate
         if (`RS_DATA_WIDTH == 64)
         begin : gen64_tag_epn
            assign tlb_tag0_d[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] =
                        ( ptereload_req_tag[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] & {`EPN_WIDTH{ptereload_req_taken_sig}} ) |
                        ( ({(ex1_mas2_epn[0:31] & {32{ex1_state_q[3]}}), ex1_mas2_epn[32:`EPN_WIDTH - 1]}) & {`EPN_WIDTH{write_req_taken_sig}} ) |
                        ( ({(ex1_mas2_epn[0:31] & {32{ex1_state_q[3]}}), ex1_mas2_epn[32:`EPN_WIDTH - 1]}) & {`EPN_WIDTH{read_req_taken_sig}} ) |
                        ( snoop_vpn_q & {`EPN_WIDTH{snoop_req_taken_sig}} ) |
                        ( xu_mm_ex2_epn & {`EPN_WIDTH{searchresv_req_taken_sig}} ) |
                        ( xu_mm_ex2_epn & {`EPN_WIDTH{search_req_taken_sig}} ) |
                        ( ierat_req_epn & {`EPN_WIDTH{ierat_req_taken_sig}} ) |
                        ( derat_req_epn & {`EPN_WIDTH{derat_req_taken_sig}} ) |
                        ( tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] & {`EPN_WIDTH{(~any_req_taken_sig)}} );
         end
      endgenerate

      //tlb_tag0_d(`tagpos_epn to `tagpos_epn+`EPN_WIDTH-1) <=
      //         ptereload_req_tag(`tagpos_epn to `tagpos_epn+`EPN_WIDTH-1) when ptereload_req_taken_sig='1'
      //         else ex1_mas2_epn(52-`EPN_WIDTH to 51)   when write_req_taken_sig='1'
      //         else ex1_mas2_epn(52-`EPN_WIDTH to 51)   when read_req_taken_sig='1'
      //         else snoop_vpn_q(52-`EPN_WIDTH to 51)    when snoop_req_taken_sig='1'
      // IFDEF(CAT_EMF)
      //         else xu_mm_ex2_epn(52-`EPN_WIDTH to 51)   when searchresv_req_taken_sig='1'
      //         else xu_mm_ex2_epn(52-`EPN_WIDTH to 51)   when search_req_taken_sig='1'
      // ELSE
      //         else xu_mm_ex1_rb(52-`EPN_WIDTH to 51)   when searchresv_req_taken_sig='1'
      //         else xu_mm_ex1_rb(52-`EPN_WIDTH to 51)   when search_req_taken_sig='1'
      // ENDIF
      //         else ierat_req_epn(52-`EPN_WIDTH to 51)  when ierat_req_taken_sig='1'
      //         else derat_req_epn(52-`EPN_WIDTH to 51)  when derat_req_taken_sig='1'
      //         else tlb_tag0_q(`tagpos_epn to `tagpos_epn+`EPN_WIDTH-1);
      generate
         if (`RS_DATA_WIDTH == 32)
         begin : gen32_tag_epn
            assign tlb_tag0_d[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] =
                        ( ptereload_req_tag[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] & {`EPN_WIDTH{ptereload_req_taken_sig}} ) |
                        ( ex1_mas2_epn[52 - `EPN_WIDTH:51] & {`EPN_WIDTH{write_req_taken_sig}} ) |
                        ( ex1_mas2_epn[52 - `EPN_WIDTH:51] & {`EPN_WIDTH{read_req_taken_sig}} ) |
                        ( snoop_vpn_q[52 - `EPN_WIDTH:51] & {`EPN_WIDTH{snoop_req_taken_sig}} ) |
                        ( xu_mm_ex2_epn[52 - `EPN_WIDTH:51] & {`EPN_WIDTH{searchresv_req_taken_sig}} ) |
                        ( xu_mm_ex2_epn[52 - `EPN_WIDTH:51] & {`EPN_WIDTH{search_req_taken_sig}} ) |
                        ( ierat_req_epn[52 - `EPN_WIDTH:51] & {`EPN_WIDTH{ierat_req_taken_sig}} ) |
                        ( derat_req_epn[52 - `EPN_WIDTH:51] & {`EPN_WIDTH{derat_req_taken_sig}} ) |
                        ( tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] & {`EPN_WIDTH{(~any_req_taken_sig)}} );
         end
      endgenerate

      // snoop_attr:
      //          0 -> Local
      //        1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=epn, 4=class0, 5=class1, 6=class2, 7=class3
      //        4:5 -> GS/TS
      //       6:13 -> TID(6:13)
      //      14:17 -> Size
      //      18    -> reserved for tlb, extclass_enable(0) for erats
      //      19    -> mmucsr0.tlb0fi for tlb, or TID_NZ for erats
      //      20:25 -> TID(0:5)
      //      26:33 -> LPID
      //      34    -> IND
      //tlb_tag0_d(`tagpos_pid to `tagpos_pid+`PID_WIDTH-1) <=
      //         ptereload_req_tag(`tagpos_pid to `tagpos_pid+`PID_WIDTH-1) when ptereload_req_taken_sig='1'
      //         else ex1_mas1_tid   when write_req_taken_sig='1'
      //         else ex1_mas1_tid   when read_req_taken_sig='1'
      //         else snoop_attr_q(20 to 25) & snoop_attr_q(6 to 13) when snoop_req_taken_sig='1'
      //         else ex2_mas1_tid         when searchresv_req_taken_sig='1'
      //         else ex2_mas6_spid         when search_req_taken_sig='1'
      //         else ierat_req_pid          when ierat_req_taken_sig='1'
      //         else derat_req_pid          when derat_req_taken_sig='1'
      //         else tlb_tag0_q(`tagpos_pid to `tagpos_pid+`PID_WIDTH-1);
      assign tlb_tag0_d[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1] =
                  ( ptereload_req_tag[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1] & {`PID_WIDTH{ptereload_req_taken_sig}} ) |
                  ( ex1_mas1_tid & {`PID_WIDTH{write_req_taken_sig}} ) |
                  ( ex1_mas1_tid & {`PID_WIDTH{read_req_taken_sig}} ) |
                  ( {snoop_attr_q[20:25], snoop_attr_q[6:13]} & {`PID_WIDTH{snoop_req_taken_sig}} ) |
                  ( ex2_mas1_tid & {`PID_WIDTH{searchresv_req_taken_sig}} ) |
                  ( ex2_mas6_spid & {`PID_WIDTH{search_req_taken_sig}} ) |
                  ( ierat_req_pid & {`PID_WIDTH{ierat_req_taken_sig}} ) |
                  ( derat_req_pid & {`PID_WIDTH{derat_req_taken_sig}} ) |
                  ( tlb_tag0_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1] & {`PID_WIDTH{(~any_req_taken_sig)}} );

      // snoop_attr: 0 -> Local
      // snoop_attr: 1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=vpn, 4=class0, 5=class1, 6=class2, 7=class3
      //  unused `tagpos_is def is mas1_v, mas1_iprot for tlbwe, and is (pte.valid & 0) for ptereloads
      //tlb_tag0_d(`tagpos_is to `tagpos_is+1) <=
      //         ptereload_req_pte(`ptepos_valid) & ptereload_req_tag(`tagpos_is+1) when ptereload_req_taken_sig='1'
      //         else ex1_mas1_v & ex1_mas1_iprot  when write_req_taken_sig='1' -- re-purpose `tagpos_is as tlbwe 0=valid,1=iprot
      //         else  00    when read_req_taken_sig='1'
      //         else snoop_attr_q(0 to 1) when snoop_req_taken_sig='1'   -- local | is(0)
      //         else  00  when searchresv_req_taken_sig='1'
      //         else  00  when search_req_taken_sig='1'
      //         else  00  when ierat_req_taken_sig='1'
      //         else  00  when derat_req_taken_sig='1'
      //         else tlb_tag0_q(`tagpos_is to `tagpos_is+1);
      assign tlb_tag0_d[`tagpos_is:`tagpos_is + 1] =
                   ( ({ptereload_req_pte[`ptepos_valid], ptereload_req_tag[`tagpos_is + 1]}) & {2{ptereload_req_taken_sig}} ) |
                   ( ({ex1_mas1_v, ex1_mas1_iprot}) & {2{write_req_taken_sig}} ) |
                   ( snoop_attr_q[0:1] & {2{snoop_req_taken_sig}} ) |
                   ( tlb_tag0_q[`tagpos_is:`tagpos_is + 1] & {2{(~any_req_taken_sig)}} );

      //tlb_tag0_d(`tagpos_class to `tagpos_class+1) <=
      //         ptereload_req_tag(`tagpos_class to `tagpos_class+1) when ptereload_req_taken_sig='1'
      //         else ex1_mmucr3_class   when write_req_taken_sig='1'
      //         else  00    when read_req_taken_sig='1'
      //         else  snoop_attr_q(2 to 3) when snoop_req_taken_sig='1'   -- is(1:2)
      //         else  00  when searchresv_req_taken_sig='1'
      //         else  00  when search_req_taken_sig='1'
      //         else  00  when ierat_req_taken_sig='1'
      //         else derat_req_ttype when derat_req_taken_sig='1'  -- re-purpose class as derat ttype, 0=load,1=store,2=epid load,3=epid store
      //         else tlb_tag0_q(`tagpos_class to `tagpos_class+1);
      assign tlb_tag0_d[`tagpos_class:`tagpos_class + `CLASS_WIDTH - 1] =
                  ( ptereload_req_tag[`tagpos_class:`tagpos_class + `CLASS_WIDTH - 1] & {`CLASS_WIDTH{ptereload_req_taken_sig}} ) |
                  ( ex1_mmucr3_class & {`CLASS_WIDTH{write_req_taken_sig}} ) |
                  ( snoop_attr_q[2:3] & {`CLASS_WIDTH{snoop_req_taken_sig}} ) |
                  ( derat_req_ttype & {`CLASS_WIDTH{derat_req_taken_sig}} ) |
                  ( tlb_tag0_q[`tagpos_class:`tagpos_class + 1] & {`CLASS_WIDTH{(~any_req_taken_sig)}} );

      // state: 0:pr 1:gs 2:as 3:cm
      //tlb_tag0_d(`tagpos_state to `tagpos_state+`CTL_STATE_WIDTH-1) <=
      //         ptereload_req_tag(`tagpos_state to `tagpos_state+`CTL_STATE_WIDTH-1) when ptereload_req_taken_sig='1'
      //         else ex1_state_q   when write_req_taken_sig='1'  -- this has to be machine state passed to cmp exceptions, etc.
      //         else ex1_state_q   when read_req_taken_sig='1'
      //         else ('0' & snoop_attr_q(4 to 5) & '0') when snoop_req_taken_sig='1'
      //         -- NOTE: may change ex2_mas5_1_state to ex2_mas8_1_state depending on architecture change
      //         else ex2_mas5_1_state when searchresv_req_taken_sig='1'   -- mas5.sgs, mas1.ts
      //         else ex2_mas5_6_state when search_req_taken_sig='1'       -- mas5.sgs, mas6.sas
      //         else ierat_req_state when ierat_req_taken_sig='1'
      //         else derat_req_state when derat_req_taken_sig='1'
      assign tlb_tag0_d[`tagpos_state:`tagpos_state + `CTL_STATE_WIDTH - 1] =
                   ( ptereload_req_tag[`tagpos_state:`tagpos_state + `CTL_STATE_WIDTH - 1] & {`CTL_STATE_WIDTH{ptereload_req_taken_sig}} ) |
                   ( ex1_state_q[0:`CTL_STATE_WIDTH - 1] & {`CTL_STATE_WIDTH{write_req_taken_sig}} ) |
                   ( ex1_state_q[0:`CTL_STATE_WIDTH - 1] & {`CTL_STATE_WIDTH{read_req_taken_sig}} ) |
                   ( {1'b0, snoop_attr_q[4:5], 1'b0} & {`CTL_STATE_WIDTH{snoop_req_taken_sig}} ) |
                   ( ex2_mas5_1_state & {`CTL_STATE_WIDTH{searchresv_req_taken_sig}} ) |
                   ( ex2_mas5_6_state & {`CTL_STATE_WIDTH{search_req_taken_sig}} ) |
                   ( ierat_req_state & {`CTL_STATE_WIDTH{ierat_req_taken_sig}} ) |
                   ( derat_req_state & {`CTL_STATE_WIDTH{derat_req_taken_sig}} ) |
                   ( tlb_tag0_q[`tagpos_state:`tagpos_state + `CTL_STATE_WIDTH - 1] & {`CTL_STATE_WIDTH{(~any_req_taken_sig)}} );

      //tlb_tag0_d(`tagpos_thdid to `tagpos_thdid+`THDID_WIDTH-1) <=
      //         ptereload_req_tag(`tagpos_thdid to `tagpos_thdid+`THDID_WIDTH-1) when ptereload_req_taken_sig='1'
      //         else ex1_valid_q   when write_req_taken_sig='1'
      //         else ex1_valid_q   when read_req_taken_sig='1'
      //         else  1111           when snoop_req_taken_sig='1'
      //         else ex2_valid_q     when searchresv_req_taken_sig='1'
      //         else ex2_valid_q     when search_req_taken_sig='1'
      //         else ierat_req_thdid when ierat_req_taken_sig='1'
      //         else derat_req_thdid when derat_req_taken_sig='1'
      //         else (others => '0') when (tlb_seq_ierat_done_sig='1' or tlb_seq_derat_done_sig='1' or
      //                                          tlb_seq_snoop_done_sig='1' or tlb_seq_search_done_sig='1' or
      //                                           tlb_seq_searchresv_done_sig ='1' or tlb_seq_read_done_sig ='1' or
      //                                            tlb_seq_write_done_sig ='1' or tlb_seq_ptereload_done_sig ='1' or tlb_seq_abort='1')
      //
      //         else tlb_tag0_q(`tagpos_thdid to `tagpos_thdid+`THDID_WIDTH-1) and not(tlb_ctl_tag1_flush_sig) and
      //                            not(tlb_ctl_tag2_flush_sig) and not(tlb_ctl_tag3_flush_sig) and not(tlb_ctl_tag4_flush_sig);
      assign tlb_tag0_d[`tagpos_thdid : `tagpos_thdid + `MM_THREADS -1] =
                   ( ptereload_req_tag[`tagpos_thdid:`tagpos_thdid + `MM_THREADS -1] & {`MM_THREADS{ptereload_req_taken_sig}} ) |
                   ( ex1_valid_q & {`MM_THREADS{write_req_taken_sig}} ) |
                   ( ex1_valid_q & {`MM_THREADS{read_req_taken_sig}} ) |
                   ( {`MM_THREADS{snoop_req_taken_sig}} ) |
                   ( ex2_valid_q & {`MM_THREADS{searchresv_req_taken_sig}} ) |
                   ( ex2_valid_q & {`MM_THREADS{search_req_taken_sig}} ) |
                   ( ierat_req_thdid[0:`MM_THREADS-1] & {`MM_THREADS{ierat_req_taken_sig}} ) |
                   ( derat_req_thdid[0:`MM_THREADS-1] & {`MM_THREADS{derat_req_taken_sig}} ) |
                   ( tlb_tag0_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS-1] & (~(tlb_ctl_tag1_flush_sig)) & (~(tlb_ctl_tag2_flush_sig)) & (~(tlb_ctl_tag3_flush_sig)) & (~(tlb_ctl_tag4_flush_sig)) &
                     {`MM_THREADS{((~tlb_seq_any_done_sig) & (~any_req_taken_sig) & (~tlb_seq_abort))}} );

      generate
         if (`THDID_WIDTH > `MM_THREADS)
         begin : tlbtag0NExist
            assign tlb_tag0_d[`tagpos_thdid + `MM_THREADS : `tagpos_thdid + `THDID_WIDTH - 1] =
                        ( ptereload_req_tag[`tagpos_thdid + `MM_THREADS : `tagpos_thdid + `THDID_WIDTH - 1] & {`THDID_WIDTH - `MM_THREADS{ptereload_req_taken_sig}} ) |
                        ( {`THDID_WIDTH - `MM_THREADS{snoop_req_taken_sig}} ) |
                        ( ierat_req_thdid[`MM_THREADS:`THDID_WIDTH - 1] & {`THDID_WIDTH - `MM_THREADS{ierat_req_taken_sig}} ) |
                        ( derat_req_thdid[`MM_THREADS:`THDID_WIDTH - 1] & {`THDID_WIDTH - `MM_THREADS{derat_req_taken_sig}} ) |
                        ( tlb_tag0_q[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1] & {`THDID_WIDTH - `MM_THREADS{((~tlb_seq_any_done_sig) & (~any_req_taken_sig) & (~tlb_seq_abort))}} );
         end
      endgenerate

      //tlb_tag0_d(`tagpos_size to `tagpos_size+3) <=
      //         --ptereload_req_tag(`tagpos_size to `tagpos_size+2) when ptereload_req_taken_sig='1'
      //         '0' & ptereload_req_pte(`ptepos_size to `ptepos_size+2) when ptereload_req_taken_sig='1'  -- 0 | pte.size(0:2)
      //         else ex1_mas1_tsize   when write_req_taken_sig='1'
      //         else ex1_mas1_tsize   when read_req_taken_sig='1'
      //         else snoop_attr_q(14 to 17)  when snoop_req_taken_sig='1'
      //         else mmucr2(28 to 31) when searchresv_req_taken_sig='1'
      //         else mmucr2(28 to 31) when search_req_taken_sig='1'
      //         else mmucr2(28 to 31) when ierat_req_taken_sig='1'
      //         else mmucr2(28 to 31) when derat_req_taken_sig='1'
      //         else tlb_tag0_q(`tagpos_size to `tagpos_size+3);
      assign tlb_tag0_d[`tagpos_size:`tagpos_size + 3] =
                   ( ({1'b0, ptereload_req_pte[`ptepos_size:`ptepos_size + 2]}) & {4{ptereload_req_taken_sig}} ) |
                   ( ex1_mas1_tsize & {4{write_req_taken_sig}} ) |
                   ( ex1_mas1_tsize & {4{read_req_taken_sig}} ) |
                   ( snoop_attr_q[14:17] & {4{snoop_req_taken_sig}} ) |
                   ( mmucr2[28:31] & {4{searchresv_req_taken_sig}} ) |
                   ( mmucr2[28:31] & {4{search_req_taken_sig}} ) |
                   ( mmucr2[28:31] & {4{ierat_req_taken_sig}} ) |
                   ( mmucr2[28:31] & {4{derat_req_taken_sig}} ) |
                   ( tlb_tag0_q[`tagpos_size:`tagpos_size + 3] & {4{(~any_req_taken_sig)}} );

      //tlb_tag0_d(`tagpos_lpid to `tagpos_lpid+`LPID_WIDTH-1) <=
      //         ptereload_req_tag(`tagpos_lpid to `tagpos_lpid+`LPID_WIDTH-1) when ptereload_req_taken_sig='1'
      //         else ex1_mas8_tlpid  when write_req_taken_sig='1'
      //         else ex1_mas8_tlpid  when read_req_taken_sig='1'
      //         else snoop_attr_q(26 to 33) when snoop_req_taken_sig='1'
      //         -- NOTE: may change ex2_mas5_slpid to ex2_mas8_tlpid depending on architecture change
      //         else ex2_mas5_slpid         when searchresv_req_taken_sig='1'
      //         else ex2_mas5_slpid         when search_req_taken_sig='1'
      //         else lpidr                   when ierat_req_taken_sig='1'
      //         else derat_req_lpid          when derat_req_taken_sig='1'
      //         else tlb_tag0_q(`tagpos_lpid to `tagpos_lpid+`LPID_WIDTH-1);
      assign tlb_tag0_d[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] =
                  ( ptereload_req_tag[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] & {`LPID_WIDTH{ptereload_req_taken_sig}} ) |
                  ( ex1_mas8_tlpid & {`LPID_WIDTH{write_req_taken_sig}} ) |
                  ( ex1_mas8_tlpid & {`LPID_WIDTH{read_req_taken_sig}} ) |
                  ( snoop_attr_q[26:33] & {`LPID_WIDTH{snoop_req_taken_sig}} ) |
                  ( ex2_mas5_slpid & {`LPID_WIDTH{searchresv_req_taken_sig}} ) |
                  ( ex2_mas5_slpid & {`LPID_WIDTH{search_req_taken_sig}} ) |
                  ( lpidr & {`LPID_WIDTH{ierat_req_taken_sig}} ) |
                  ( derat_req_lpid & {`LPID_WIDTH{derat_req_taken_sig}} ) |
                  ( tlb_tag0_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] & {`LPID_WIDTH{(~any_req_taken_sig)}} );

      //tlb_tag0_d(`tagpos_ind) <=
      //         '0' when ptereload_req_taken_sig='1'  -- prevents htw re-request, ptereload is always ind=0 entry
      //         --ptereload_req_tag(`tagpos_ind) when ptereload_req_taken_sig='1'
      //         else ex1_mas1_ind  when write_req_taken_sig='1'
      //         else ex1_mas1_ind  when read_req_taken_sig='1'
      //         else snoop_attr_q(34) when snoop_req_taken_sig='1'
      //         else ex2_mas1_ind   when searchresv_req_taken_sig='1'
      //         else ex2_mas6_sind   when search_req_taken_sig='1'
      //         else '0'             when ierat_req_taken_sig='1'
      //         else '0'             when derat_req_taken_sig='1'
      //         else tlb_tag0_q(`tagpos_ind);
      assign tlb_tag0_d[`tagpos_ind] =
                  ( ex1_mas1_ind & write_req_taken_sig ) |
                  ( ex1_mas1_ind & read_req_taken_sig ) |
                  ( snoop_attr_q[34] & snoop_req_taken_sig ) |
                  ( ex2_mas1_ind & searchresv_req_taken_sig ) |
                  ( ex2_mas6_sind & search_req_taken_sig ) |
                  ( tlb_tag0_q[`tagpos_ind] & (~any_req_taken_sig) );

      //tlb_tag0_d(`tagpos_atsel) <=
      //         ptereload_req_tag(`tagpos_atsel) when ptereload_req_taken_sig='1'
      //         else ex1_mas0_atsel  when write_req_taken_sig='1'
      //         else ex1_mas0_atsel  when read_req_taken_sig='1'
      //         else '0'  when snoop_req_taken_sig='1'
      //         else ex2_mas0_atsel  when searchresv_req_taken_sig='1'
      //         else ex2_mas0_atsel  when search_req_taken_sig='1'
      //         else '0'  when ierat_req_taken_sig='1'
      //         else '0'  when derat_req_taken_sig='1'
      //         else tlb_tag0_q(`tagpos_atsel);
      assign tlb_tag0_d[`tagpos_atsel] =
              ( ptereload_req_tag[`tagpos_atsel] & ptereload_req_taken_sig ) |
              ( ex1_mas0_atsel & write_req_taken_sig ) |
              ( ex1_mas0_atsel & read_req_taken_sig ) |
              ( ex2_mas0_atsel & searchresv_req_taken_sig ) |
              ( ex2_mas0_atsel & search_req_taken_sig ) |
              ( tlb_tag0_q[`tagpos_atsel] & (~any_req_taken_sig) );

      //tlb_tag0_d(`tagpos_esel to `tagpos_esel+2) <=
      //         ptereload_req_tag(`tagpos_esel to `tagpos_esel+2) when ptereload_req_taken_sig='1'
      //         else ex1_mas0_esel   when write_req_taken_sig='1'
      //         else ex1_mas0_esel   when read_req_taken_sig='1'
      //         else  000   when snoop_req_taken_sig='1'
      //         else ex2_mas0_esel when searchresv_req_taken_sig='1'
      //         else ex2_mas0_esel when search_req_taken_sig='1'
      //         else  000  when ierat_req_taken_sig='1'
      //         else  000  when derat_req_taken_sig='1'
      //         else tlb_tag0_q(`tagpos_esel to `tagpos_esel+2);
      assign tlb_tag0_d[`tagpos_esel:`tagpos_esel + 2] =
                  ( ptereload_req_tag[`tagpos_esel:`tagpos_esel + 2] & {3{ptereload_req_taken_sig}} ) |
                  ( ex1_mas0_esel & {3{write_req_taken_sig}} ) |
                  ( ex1_mas0_esel & {3{read_req_taken_sig}} ) |
                  ( ex2_mas0_esel & {3{searchresv_req_taken_sig}} ) |
                  ( ex2_mas0_esel & {3{search_req_taken_sig}} ) |
                  ( tlb_tag0_q[`tagpos_esel:`tagpos_esel + 2] & {3{(~any_req_taken_sig)}} );

      //tlb_tag0_d(`tagpos_hes) <=
      //         ptereload_req_tag(`tagpos_hes) when ptereload_req_taken_sig='1'
      //         else ex1_mas0_hes  when write_req_taken_sig='1'
      //         else ex1_mas0_hes  when read_req_taken_sig='1'
      //         else snoop_attr_q(19) when snoop_req_taken_sig='1'  -- hes = mmucsr0.tlb0fi invalidate all bit for snoops
      //         else ex2_mas0_hes  when searchresv_req_taken_sig='1'
      //         else ex2_mas0_hes  when search_req_taken_sig='1'
      //         else '1'  when ierat_req_taken_sig='1'
      //         else '1'  when derat_req_taken_sig='1'
      //         else tlb_tag0_q(`tagpos_hes);
      assign tlb_tag0_d[`tagpos_hes] =
                  ( ptereload_req_tag[`tagpos_hes] & ptereload_req_taken_sig ) |
                  ( ex1_mas0_hes & write_req_taken_sig ) |
                  ( ex1_mas0_hes & read_req_taken_sig ) |
                  ( snoop_attr_q[19] & snoop_req_taken_sig ) |
                  ( ex2_mas0_hes & searchresv_req_taken_sig ) |
                  ( ex2_mas0_hes & search_req_taken_sig ) |
                  ( ierat_req_taken_sig) | (derat_req_taken_sig ) |
                  ( tlb_tag0_q[`tagpos_hes] & (~any_req_taken_sig) );

      //tlb_tag0_d(`tagpos_wq to `tagpos_wq+1) <=
      //         -- unused WQ for ptereloads come back as htw reserv write enab & dup bits set in htw
      //         ptereload_req_tag(`tagpos_wq to `tagpos_wq+1) when ptereload_req_taken_sig='1'
      //         else ex1_mas0_wq   when write_req_taken_sig='1'
      //         else ex1_mas0_wq   when read_req_taken_sig='1'
      //         else  00   when snoop_req_taken_sig='1'
      //         else ex2_mas0_wq when searchresv_req_taken_sig='1'
      //         else ex2_mas0_wq when search_req_taken_sig='1'
      //         else ierat_req_dup when ierat_req_taken_sig='1'  -- unused WQ is re-purposed as htw reservation write enab or dup bits
      //         else derat_req_dup when derat_req_taken_sig='1'  -- unused WQ is re-purposed as htw reservation write enab or dup bits
      //         else tlb_tag0_q(`tagpos_wq to `tagpos_wq+1);
      assign tlb_tag0_d[`tagpos_wq:`tagpos_wq + 1] =
                  ( ptereload_req_tag[`tagpos_wq:`tagpos_wq + 1] & {2{ptereload_req_taken_sig}} ) |
                  ( ex1_mas0_wq & {2{write_req_taken_sig}} ) |
                  ( ex1_mas0_wq & {2{read_req_taken_sig}} ) |
                  ( ex2_mas0_wq & {2{searchresv_req_taken_sig}} ) |
                  ( ex2_mas0_wq & {2{search_req_taken_sig}} ) |
                  ( ierat_req_dup & {2{ierat_req_taken_sig}} ) |
                  ( derat_req_dup & {2{derat_req_taken_sig}} ) |
                  ( tlb_tag0_q[`tagpos_wq:`tagpos_wq + 1] & {2{(~any_req_taken_sig)}} );

      //tlb_tag0_d(`tagpos_lrat) <=
      //         ptereload_req_tag(`tagpos_lrat) when ptereload_req_taken_sig='1'
      //         else ex1_mmucfg_lrat  when write_req_taken_sig='1'
      //         else ex1_mmucfg_lrat  when read_req_taken_sig='1'
      //         else '0'  when snoop_req_taken_sig='1'
      //         else ex2_mmucfg_lrat  when searchresv_req_taken_sig='1'
      //         else ex2_mmucfg_lrat  when search_req_taken_sig='1'
      //         else mmucfg_lrat  when ierat_req_taken_sig='1'
      //         else mmucfg_lrat  when derat_req_taken_sig='1'
      //         else tlb_tag0_q(`tagpos_lrat);
      assign tlb_tag0_d[`tagpos_lrat] =
                  ( ptereload_req_tag[`tagpos_lrat] & ptereload_req_taken_sig ) |
                  ( mmucfg_lrat & write_req_taken_sig ) |
                  ( mmucfg_lrat & read_req_taken_sig ) |
                  ( mmucfg_lrat & searchresv_req_taken_sig ) |
                  ( mmucfg_lrat & search_req_taken_sig ) |
                  ( mmucfg_lrat & ierat_req_taken_sig ) |
                  ( mmucfg_lrat & derat_req_taken_sig ) |
                  ( tlb_tag0_q[`tagpos_lrat] & (~any_req_taken_sig) );

      //  unused `tagpos_pt def is mas8_tgs for tlbwe
      assign tlb_tag0_d[`tagpos_pt] =
                  ( ptereload_req_tag[`tagpos_pt] & ptereload_req_taken_sig ) |
                  ( ex1_mas8_tgs & write_req_taken_sig ) |
                  ( tlb0cfg_pt & read_req_taken_sig ) |
                  ( tlb0cfg_pt & searchresv_req_taken_sig ) |
                  ( tlb0cfg_pt & search_req_taken_sig ) |
                  ( tlb0cfg_pt & ierat_req_taken_sig ) |
                  ( tlb0cfg_pt & derat_req_taken_sig ) |
                  ( tlb_tag0_q[`tagpos_pt] & (~any_req_taken_sig ) );

      //  unused `tagpos_recform def is mas1_ts for tlbwe
      assign tlb_tag0_d[`tagpos_recform] =
                  ( ex1_mas1_ts & write_req_taken_sig ) |
                  ( searchresv_req_taken_sig ) |
                  ( ex2_ttype_q[3] & search_req_taken_sig ) |
                  ( tlb_tag0_q[`tagpos_recform] & (~any_req_taken_sig) );

      assign tlb_tag0_d[`tagpos_endflag] = 1'b0;

      assign tlb_tag0_d[`tagpos_itag:`tagpos_itag + `ITAG_SIZE_ENC - 1] =
                  ( ptereload_req_tag[`tagpos_itag:`tagpos_itag + `ITAG_SIZE_ENC - 1] & {`ITAG_SIZE_ENC{ptereload_req_taken_sig}} ) |
                  ( ex1_itag_q & {`ITAG_SIZE_ENC{write_req_taken_sig}} ) |
                  ( ex1_itag_q & {`ITAG_SIZE_ENC{read_req_taken_sig}} ) |
                  ( ex2_itag_q & {`ITAG_SIZE_ENC{searchresv_req_taken_sig}} ) |
                  ( ex2_itag_q & {`ITAG_SIZE_ENC{search_req_taken_sig}} ) |
                  ( derat_req_itag & {`ITAG_SIZE_ENC{derat_req_taken_sig}} ) |
                  ( tlb_tag0_q[`tagpos_itag:`tagpos_itag + `ITAG_SIZE_ENC - 1] & {`ITAG_SIZE_ENC{(~any_req_taken_sig)}} );

      assign tlb_tag0_d[`tagpos_emq:`tagpos_emq + `EMQ_ENTRIES - 1] =
                  ( ptereload_req_tag[`tagpos_emq:`tagpos_emq + `EMQ_ENTRIES - 1] & {`EMQ_ENTRIES{ptereload_req_taken_sig}} ) |
                  ( derat_req_emq & {`EMQ_ENTRIES{derat_req_taken_sig}} ) |
                  (tlb_tag0_q[`tagpos_emq:`tagpos_emq + `EMQ_ENTRIES - 1] & {`EMQ_ENTRIES{(~any_req_taken_sig)}} );

      assign tlb_tag0_d[`tagpos_nonspec] =
                  ( ptereload_req_tag[`tagpos_nonspec] & ptereload_req_taken_sig ) |
                  ( write_req_taken_sig ) |
                  ( read_req_taken_sig ) |
                  ( searchresv_req_taken_sig ) |
                  ( search_req_taken_sig ) |
                  ( ierat_req_nonspec & ierat_req_taken_sig ) |
                  ( derat_req_nonspec & derat_req_taken_sig ) |
                  ( tlb_tag0_q[`tagpos_nonspec] & (~any_req_taken_sig) );

      //  `tagpos_epn      : natural  := 0;
      //  `tagpos_pid      : natural  := 52; -- 14 bits
      //  `tagpos_is       : natural  := 66;
      //  `tagpos_class    : natural  := 68;
      //  `tagpos_state    : natural  := 70; -- state: 0:pr 1:gs 2:as 3:cm
      //  `tagpos_thdid    : natural  := 74;
      //  `tagpos_size     : natural  := 78;
      //  `tagpos_type    : natural  := 82; -- derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      //  `tagpos_lpid     : natural  := 90;
      //  `tagpos_ind      : natural  := 98;
      //  `tagpos_atsel    : natural  := 99;
      //  `tagpos_esel     : natural  := 100;
      //  `tagpos_hes      : natural  := 103;
      //  `tagpos_wq       : natural  := 104;
      //  `tagpos_lrat     : natural  := 106;
      //  `tagpos_pt       : natural  := 107;
      //  `tagpos_recform  : natural  := 108;
      //  `tagpos_endflag  : natural  := 109;
      //ac/q7/vhdl/a2_simwrap_32.vhdl:  constant `REAL_ADDR_WIDTH     : integer := 32;
      //ac/q7/vhdl/a2_simwrap.vhdl:     constant `REAL_ADDR_WIDTH     : integer := 42;
      //ac/q7/vhdl/a2_simwrap_32.vhdl:  constant `EPN_WIDTH           : integer := 20;
      //ac/q7/vhdl/a2_simwrap.vhdl:     constant `EPN_WIDTH           : integer := 52;
      // tag0 phase, tlbwe/re ex2, tlbsx/srx ex3

      assign tlb_tag0_epn[52 - `EPN_WIDTH:51] = tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1];

      assign tlb_tag0_thdid = tlb_tag0_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1];

      assign tlb_tag0_type = tlb_tag0_q[`tagpos_type:`tagpos_type + 7];

      assign tlb_tag0_lpid = tlb_tag0_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1];

      assign tlb_tag0_atsel = tlb_tag0_q[`tagpos_atsel];

      assign tlb_tag0_size = tlb_tag0_q[`tagpos_size:`tagpos_size + 3];

      assign tlb_tag0_addr_cap = tlb_seq_tag0_addr_cap;

      assign tlb_tag0_nonspec = tlb_tag0_q[`tagpos_nonspec];

      assign tlb_tag1_d[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] = tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1];

      assign tlb_tag1_d[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1] = tlb_tag0_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1];

      // maybe needed for timing here and for ptereload_req_pte(`ptepos_size) stuff
      //  unused `tagpos_is def is (pte.valid & 0) for ptereloads
      //tlb_tag1_d(`tagpos_is to `tagpos_is+1) <= ptereload_req_pte_q(`ptepos_valid) & tlb_tag0_q(`tagpos_is+1)
      //                                            when (tlb_seq_tag0_addr_cap='1' and tlb_tag0_q(`tagpos_type_ptereload)='1')
      //                                     else tlb_tag0_q(`tagpos_is to `tagpos_is+1);
      // tlb_tag1_d(`tagpos_is to `tagpos_is+1) <= tlb_tag0_q(`tagpos_is to `tagpos_is+1);
      // unused isel for derat,ierat,tlbsx,tlbsrx becomes page size attempted number msb (9 thru 13, or 17 thru 21)
      assign tlb_tag1_d[`tagpos_is:`tagpos_is + 1] =
              ( {2{|(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_tlbsrx])}} & {2{(~tlb_tag0_q[`tagpos_type_ptereload])}} & tlb_seq_is) |
              ( {2{|(tlb_tag0_q[`tagpos_type_snoop:`tagpos_type_ptereload])}} & tlb_tag0_q[`tagpos_is:`tagpos_is + 1] );

      assign tlb_tag1_d[`tagpos_class:`tagpos_class + `CLASS_WIDTH - 1] = tlb_tag0_q[`tagpos_class:`tagpos_class + `CLASS_WIDTH - 1];

      assign tlb_tag1_d[`tagpos_state:`tagpos_state + `CTL_STATE_WIDTH - 1] = tlb_tag0_q[`tagpos_state:`tagpos_state + `CTL_STATE_WIDTH - 1];

      assign tlb_tag1_d[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] =
                   ( ((tlb_tag4_hit_or_parerr == 1'b1 | tlb_tag4_endflag == 1'b1) & tlb_tag0_q[`tagpos_type_ptereload] == 1'b0 &
                      (tlb_tag0_q[`tagpos_type_ierat] == 1'b1 | tlb_tag0_q[`tagpos_type_derat] == 1'b1 | tlb_tag0_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag0_q[`tagpos_type_tlbsrx] == 1'b1)) |
                      (tlb_tag4_endflag == 1'b1 & tlb_tag0_q[`tagpos_type_snoop] == 1'b1) |
                       tlb_seq_any_done_sig == 1'b1 | tlb_seq_abort == 1'b1 ) ? {`MM_THREADS{1'b0}} :
                   {tlb_tag0_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag1_flush_sig)) & (~(tlb_ctl_tag2_flush_sig)) & (~(tlb_ctl_tag3_flush_sig)) & (~(tlb_ctl_tag4_flush_sig))};
      generate
         if (`THDID_WIDTH > `MM_THREADS)
         begin : tlbtag1NExist
            assign tlb_tag1_d[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1] =
                         ( ((tlb_tag4_hit_or_parerr == 1'b1 | tlb_tag4_endflag == 1'b1) & tlb_tag0_q[`tagpos_type_ptereload] == 1'b0 &
                            (tlb_tag0_q[`tagpos_type_ierat] == 1'b1 | tlb_tag0_q[`tagpos_type_derat] == 1'b1 | tlb_tag0_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag0_q[`tagpos_type_tlbsrx] == 1'b1)) |
                            (tlb_tag4_endflag == 1'b1 & tlb_tag0_q[`tagpos_type_snoop] == 1'b1) |
                             tlb_seq_any_done_sig == 1'b1 | tlb_seq_abort == 1'b1) ? {`THDID_WIDTH - `MM_THREADS{1'b0}} :
                    {tlb_tag0_q[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1]};
         end
      endgenerate

      //tlb_tag1_d(`tagpos_ind) <= '1' when tlb_seq_ind='1' else tlb_tag0_q(`tagpos_ind);
      //tlb_tag1_d(`tagpos_esel to `tagpos_esel+2) <= tlb_tag0_q(`tagpos_esel to `tagpos_esel+2);
      assign tlb_tag1_d[`tagpos_ind] = ( |(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_ierat]) & tlb_seq_ind ) |
                                         ( (~|(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_ierat])) & tlb_tag0_q[`tagpos_ind] );

      // unused esel for derat,ierat,tlbsx,tlbsrx becomes page size attempted number (1 thru 5)
      assign tlb_tag1_d[`tagpos_esel:`tagpos_esel + 2] = ( {3{|(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag0_q[`tagpos_type_ptereload])}} & tlb_seq_esel ) |
                                                           ( {3{tlb_tag0_q[`tagpos_type_ptereload] | (~|(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_tlbsrx]))}} & tlb_tag0_q[`tagpos_esel:`tagpos_esel + 2]);

      assign tlb_tag1_d[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] = tlb_tag0_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1];

      assign tlb_tag1_d[`tagpos_atsel] = tlb_tag0_q[`tagpos_atsel];

      assign tlb_tag1_d[`tagpos_hes] = tlb_tag0_q[`tagpos_hes];

      assign tlb_tag1_d[`tagpos_wq:`tagpos_wq + 1] = tlb_tag0_q[`tagpos_wq:`tagpos_wq + 1];

      assign tlb_tag1_d[`tagpos_lrat] = tlb_tag0_q[`tagpos_lrat];

      assign tlb_tag1_d[`tagpos_pt] = tlb_tag0_q[`tagpos_pt];

      assign tlb_tag1_d[`tagpos_recform] = tlb_tag0_q[`tagpos_recform];

      //       pgsize bits
      assign tlb_tag1_d[`tagpos_size:`tagpos_size + 3] =
                  ( {4{|(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag0_q[`tagpos_type_ptereload])}} & tlb_seq_pgsize ) |
                  ( {4{tlb_tag0_q[`tagpos_type_ptereload] | (~|(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_tlbsrx]))}} & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] );

      //       tag type bits: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      assign tlb_tag1_d[`tagpos_type:`tagpos_type + 7] =
                  ( (tlb_seq_ierat_done_sig == 1'b1 | tlb_seq_derat_done_sig == 1'b1 | tlb_seq_snoop_done_sig == 1'b1 |
                     tlb_seq_search_done_sig == 1'b1 | tlb_seq_searchresv_done_sig == 1'b1 | tlb_seq_read_done_sig == 1'b1 | tlb_seq_write_done_sig == 1'b1 |
                     tlb_seq_ptereload_done_sig == 1'b1 | tlb_seq_abort == 1'b1) ) ? 8'b00000000 :
                 tlb_tag0_q[`tagpos_type:`tagpos_type + 7];

      //       endflag
      assign tlb_tag1_d[`tagpos_endflag] = tlb_seq_endflag;

      assign tlb_addr_d = (|(tlb_tag4_parerr_write) == 1'b1) ? tlb_addr4 :
                          (tlb_seq_addr_clr == 1'b1) ? {`TLB_ADDR_WIDTH{1'b0}} :
                          (tlb_seq_addr_incr == 1'b1) ? tlb_addr_p1 :
                          (tlb_seq_addr_update == 1'b1) ? tlb_seq_addr :
                          tlb_addr_q;

      assign tlb_addr_p1 = (tlb_addr_q == 7'b1111111) ? 7'b0000000 :
                               tlb_addr_q + 7'b0000001;

      assign tlb_addr_maxcntm1 = (tlb_addr_q == 7'b1111110) ? 1'b1 :
                                 1'b0;

      // tag1 phase, tlbwe/re ex3, tlbsx/srx ex4
      //tlb_tag2_d   <= tlb_tag1_q;
      //tlb_tag2_d(`tagpos_epn to `tagpos_epn+`EPN_WIDTH-1) <= tlb_tag1_q(`tagpos_epn to `tagpos_epn+`EPN_WIDTH-1);
      assign tlb_tag1_pgsize_eq_16mb = (tlb_tag1_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB);
      assign tlb_tag1_pgsize_gte_1mb = (tlb_tag1_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (tlb_tag1_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB);
      assign tlb_tag1_pgsize_gte_64kb =  (tlb_tag1_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (tlb_tag1_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (tlb_tag1_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB);
      assign tlb_tag1_d[`tagpos_itag:`tagpos_itag + `ITAG_SIZE_ENC - 1] = tlb_tag0_q[`tagpos_itag:`tagpos_itag + `ITAG_SIZE_ENC - 1];
      assign tlb_tag1_d[`tagpos_emq:`tagpos_emq + `EMQ_ENTRIES - 1] = tlb_tag0_q[`tagpos_emq:`tagpos_emq + `EMQ_ENTRIES - 1];
      assign tlb_tag1_d[`tagpos_nonspec] = tlb_tag0_q[`tagpos_nonspec];

      assign tlb_tag2_d[`tagpos_epn:`tagpos_epn + 39] = tlb_tag1_q[`tagpos_epn:`tagpos_epn + 39];
      assign tlb_tag2_d[`tagpos_epn + 40:`tagpos_epn + 43] = tlb_tag1_q[`tagpos_epn + 40:`tagpos_epn + 43] & {4{((~tlb_tag1_pgsize_eq_16mb) | (~tlb_tag1_q[`tagpos_type_ptereload]))}};
      assign tlb_tag2_d[`tagpos_epn + 44:`tagpos_epn + 47] = tlb_tag1_q[`tagpos_epn + 44:`tagpos_epn + 47] & {4{((~tlb_tag1_pgsize_gte_1mb) | (~tlb_tag1_q[`tagpos_type_ptereload]))}};
      assign tlb_tag2_d[`tagpos_epn + 48:`tagpos_epn + 51] = tlb_tag1_q[`tagpos_epn + 48:`tagpos_epn + 51] & {4{((~tlb_tag1_pgsize_gte_64kb) | (~tlb_tag1_q[`tagpos_type_ptereload]))}};

      assign tlb_tag2_d[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1] = tlb_tag1_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1];
      assign tlb_tag2_d[`tagpos_is:`tagpos_is + 1] = tlb_tag1_q[`tagpos_is:`tagpos_is + 1];
      assign tlb_tag2_d[`tagpos_class:`tagpos_class + 1] = tlb_tag1_q[`tagpos_class:`tagpos_class + 1];
      assign tlb_tag2_d[`tagpos_state:`tagpos_state + `CTL_STATE_WIDTH - 1] = tlb_tag1_q[`tagpos_state:`tagpos_state + `CTL_STATE_WIDTH - 1];

      assign tlb_tag2_d[`tagpos_thdid:`tagpos_thdid + `MM_THREADS -1] = (((tlb_tag4_hit_or_parerr == 1'b1 | tlb_tag4_endflag == 1'b1) & tlb_tag1_q[`tagpos_type_ptereload] == 1'b0 &
                                                               (tlb_tag1_q[`tagpos_type_ierat] == 1'b1 | tlb_tag1_q[`tagpos_type_derat] == 1'b1 |
                                                                tlb_tag1_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag1_q[`tagpos_type_tlbsrx] == 1'b1)) |
                                                                (tlb_tag4_endflag == 1'b1 & tlb_tag1_q[`tagpos_type_snoop] == 1'b1) |
                                                                  tlb_seq_any_done_sig == 1'b1 | tlb_seq_abort == 1'b1) ? {`MM_THREADS{1'b0}} :
                                                         tlb_tag1_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag2_flush_sig)) & (~(tlb_ctl_tag3_flush_sig)) & (~(tlb_ctl_tag4_flush_sig));
      generate
         if (`THDID_WIDTH > `MM_THREADS)
         begin : tlbtag2NExist
            assign tlb_tag2_d[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1] = (((tlb_tag4_hit_or_parerr == 1'b1 | tlb_tag4_endflag == 1'b1) & tlb_tag1_q[`tagpos_type_ptereload] == 1'b0 &
                                                                  (tlb_tag1_q[`tagpos_type_ierat] == 1'b1 | tlb_tag1_q[`tagpos_type_derat] == 1'b1 |
                                                                   tlb_tag1_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag1_q[`tagpos_type_tlbsrx] == 1'b1)) |
                                                                   (tlb_tag4_endflag == 1'b1 & tlb_tag1_q[`tagpos_type_snoop] == 1'b1) |
                                                                    tlb_seq_any_done_sig == 1'b1 | tlb_seq_abort == 1'b1) ? {`THDID_WIDTH - `MM_THREADS{1'b0}} :
                                                                                 tlb_tag1_q[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1];
         end
      endgenerate

      assign tlb_tag2_d[`tagpos_size:`tagpos_size + 3] = tlb_tag1_q[`tagpos_size:`tagpos_size + 3];
      assign tlb_tag2_d[`tagpos_type:`tagpos_type + 7] = ((tlb_seq_ierat_done_sig == 1'b1 | tlb_seq_derat_done_sig == 1'b1 | tlb_seq_snoop_done_sig == 1'b1 | tlb_seq_search_done_sig == 1'b1 | tlb_seq_searchresv_done_sig == 1'b1 | tlb_seq_read_done_sig == 1'b1 | tlb_seq_write_done_sig == 1'b1 | tlb_seq_ptereload_done_sig == 1'b1 | tlb_seq_abort == 1'b1)) ? 8'b00000000 :
                                                       tlb_tag1_q[`tagpos_type:`tagpos_type + 7];
      assign tlb_tag2_d[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] = tlb_tag1_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1];
      assign tlb_tag2_d[`tagpos_ind] = tlb_tag1_q[`tagpos_ind];
      assign tlb_tag2_d[`tagpos_atsel] = tlb_tag1_q[`tagpos_atsel];
      assign tlb_tag2_d[`tagpos_esel:`tagpos_esel + 2] = tlb_tag1_q[`tagpos_esel:`tagpos_esel + 2];
      assign tlb_tag2_d[`tagpos_hes] = tlb_tag1_q[`tagpos_hes];
      assign tlb_tag2_d[`tagpos_wq:`tagpos_wq + 1] = tlb_tag1_q[`tagpos_wq:`tagpos_wq + 1];
      assign tlb_tag2_d[`tagpos_lrat] = tlb_tag1_q[`tagpos_lrat];
      assign tlb_tag2_d[`tagpos_pt] = tlb_tag1_q[`tagpos_pt];
      assign tlb_tag2_d[`tagpos_recform] = tlb_tag1_q[`tagpos_recform];
      assign tlb_tag2_d[`tagpos_endflag] = tlb_tag1_q[`tagpos_endflag];
      assign tlb_tag2_d[`tagpos_itag:`tagpos_itag + `ITAG_SIZE_ENC - 1] = tlb_tag1_q[`tagpos_itag:`tagpos_itag + `ITAG_SIZE_ENC - 1];
      assign tlb_tag2_d[`tagpos_emq:`tagpos_emq + `EMQ_ENTRIES - 1] = tlb_tag1_q[`tagpos_emq:`tagpos_emq + `EMQ_ENTRIES - 1];
      assign tlb_tag2_d[`tagpos_nonspec] = tlb_tag1_q[`tagpos_nonspec];
      assign lru_rd_addr = tlb_addr_q;
      assign tlb_addr = tlb_addr_q;
      assign tlb_addr2_d = tlb_addr_q;
      // tag2 phase, tlbwe/re ex4, tlbsx/srx ex5
      assign tlb_tag2 = tlb_tag2_q;
      assign tlb_addr2 = tlb_addr2_q;
      // tag4, tlbwe/re ex6

      assign tlb_write_d[0] = ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_state_q[0] == 1'b0 & ex6_illeg_instr_q[1] == 1'b0 & ((ex6_state_q[1] == 1'b0 & tlb_tag4_atsel == 1'b0) | (ex6_state_q[1] == 1'b1 & lrat_tag4_hit_status[0:3] == 4'b1100 & (lru_tag4_dataout[0] == 1'b0 | lru_tag4_dataout[8] == 1'b0)  & tlb_tag4_is[1] == 1'b0 & tlb0cfg_gtwe == 1'b1 & ex6_dgtmi_state == 1'b0)) & ((|(ex6_valid_q & tlb_resv_match_vec_q) == 1'b1 & tlb_tag4_wq == 2'b01 & mmucfg_twc == 1'b1) | tlb_tag4_wq == 2'b00 | tlb_tag4_wq == 2'b11) & tlb_tag4_hes == 1'b1 & lru_tag4_dataout[4] == 1'b0 & lru_tag4_dataout[5] == 1'b0)) ? 1'b1 :
                                ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_state_q[0] == 1'b0 & ex6_illeg_instr_q[1] == 1'b0 & ex6_state_q[1] == 1'b0 & tlb_tag4_atsel == 1'b0 & ((|(ex6_valid_q & tlb_resv_match_vec_q) == 1'b1 & tlb_tag4_wq == 2'b01 & mmucfg_twc == 1'b1) | tlb_tag4_wq == 2'b00 | tlb_tag4_wq == 2'b11) & tlb_tag4_hes == 1'b0 & tlb_tag4_esel[1:2] == 2'b00)) ? 1'b1 :
                                ((tlb_tag4_ptereload == 1'b1 & (tlb_tag4_gs == 1'b0 | (tlb_tag4_gs == 1'b1 & lrat_tag4_hit_status[0:3] == 4'b1100)) & lru_tag4_dataout[4] == 1'b0 & lru_tag4_dataout[5] == 1'b0 & (lru_tag4_dataout[0] == 1'b0 | lru_tag4_dataout[8] == 1'b0)  & tlb_tag4_wq == 2'b10 & tlb_tag4_is[0] == 1'b1 & tlb_tag4_pt == 1'b1)) ? 1'b1 :
                                tlb_tag4_parerr_write[0];

      assign tlb_write_d[1] = ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_state_q[0] == 1'b0 & ex6_illeg_instr_q[1] == 1'b0 & ((ex6_state_q[1] == 1'b0 & tlb_tag4_atsel == 1'b0) | (ex6_state_q[1] == 1'b1 & lrat_tag4_hit_status[0:3] == 4'b1100 & (lru_tag4_dataout[1] == 1'b0 | lru_tag4_dataout[9] == 1'b0)  & tlb_tag4_is[1] == 1'b0 & tlb0cfg_gtwe == 1'b1 & ex6_dgtmi_state == 1'b0)) & ((|(ex6_valid_q & tlb_resv_match_vec_q) == 1'b1 & tlb_tag4_wq == 2'b01 & mmucfg_twc == 1'b1) | tlb_tag4_wq == 2'b00 | tlb_tag4_wq == 2'b11) & tlb_tag4_hes == 1'b1 & lru_tag4_dataout[4] == 1'b0 & lru_tag4_dataout[5] == 1'b1)) ? 1'b1 :
                                ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_state_q[0] == 1'b0 & ex6_illeg_instr_q[1] == 1'b0 & ex6_state_q[1] == 1'b0 & tlb_tag4_atsel == 1'b0 & ((|(ex6_valid_q & tlb_resv_match_vec_q) == 1'b1 & tlb_tag4_wq == 2'b01 & mmucfg_twc == 1'b1) | tlb_tag4_wq == 2'b00 | tlb_tag4_wq == 2'b11) & tlb_tag4_hes == 1'b0 & tlb_tag4_esel[1:2] == 2'b01)) ? 1'b1 :
                                ((tlb_tag4_ptereload == 1'b1 & (tlb_tag4_gs == 1'b0 | (tlb_tag4_gs == 1'b1 & lrat_tag4_hit_status[0:3] == 4'b1100)) & lru_tag4_dataout[4:5] == 2'b01 & (lru_tag4_dataout[1] == 1'b0 | lru_tag4_dataout[9] == 1'b0) & tlb_tag4_wq == 2'b10 & tlb_tag4_is[0] == 1'b1 & tlb_tag4_pt == 1'b1)) ? 1'b1 :
                                tlb_tag4_parerr_write[1];

      assign tlb_write_d[2] = ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_state_q[0] == 1'b0 & ex6_illeg_instr_q[1] == 1'b0 & ((ex6_state_q[1] == 1'b0 & tlb_tag4_atsel == 1'b0) | (ex6_state_q[1] == 1'b1 & lrat_tag4_hit_status[0:3] == 4'b1100 & (lru_tag4_dataout[2] == 1'b0 | lru_tag4_dataout[10] == 1'b0) & tlb_tag4_is[1] == 1'b0 & tlb0cfg_gtwe == 1'b1 & ex6_dgtmi_state == 1'b0)) & ((|(ex6_valid_q & tlb_resv_match_vec_q) == 1'b1 & tlb_tag4_wq == 2'b01 & mmucfg_twc == 1'b1) | tlb_tag4_wq == 2'b00 | tlb_tag4_wq == 2'b11) & tlb_tag4_hes == 1'b1 & lru_tag4_dataout[4] == 1'b1 & lru_tag4_dataout[6] == 1'b0)) ? 1'b1 :
                                ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_state_q[0] == 1'b0 & ex6_illeg_instr_q[1] == 1'b0 & ex6_state_q[1] == 1'b0 & tlb_tag4_atsel == 1'b0 & ((|(ex6_valid_q & tlb_resv_match_vec_q) == 1'b1 & tlb_tag4_wq == 2'b01 & mmucfg_twc == 1'b1) | tlb_tag4_wq == 2'b00 | tlb_tag4_wq == 2'b11) & tlb_tag4_hes == 1'b0 & tlb_tag4_esel[1:2] == 2'b10)) ? 1'b1 :
                                ((tlb_tag4_ptereload == 1'b1 & (tlb_tag4_gs == 1'b0 | (tlb_tag4_gs == 1'b1 & lrat_tag4_hit_status[0:3] == 4'b1100)) & lru_tag4_dataout[4] == 1'b1 & lru_tag4_dataout[6] == 1'b0 & (lru_tag4_dataout[2] == 1'b0 | lru_tag4_dataout[10] == 1'b0) & tlb_tag4_wq == 2'b10 & tlb_tag4_is[0] == 1'b1 & tlb_tag4_pt == 1'b1)) ? 1'b1 :
                                tlb_tag4_parerr_write[2];

      assign tlb_write_d[3] = ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_state_q[0] == 1'b0 & ex6_illeg_instr_q[1] == 1'b0 & ((ex6_state_q[1] == 1'b0 & tlb_tag4_atsel == 1'b0) | (ex6_state_q[1] == 1'b1 & lrat_tag4_hit_status[0:3] == 4'b1100 & (lru_tag4_dataout[3] == 1'b0 | lru_tag4_dataout[11] == 1'b0) & tlb_tag4_is[1] == 1'b0 & tlb0cfg_gtwe == 1'b1 & ex6_dgtmi_state == 1'b0)) & ((|(ex6_valid_q & tlb_resv_match_vec_q) == 1'b1 & tlb_tag4_wq == 2'b01 & mmucfg_twc == 1'b1) | tlb_tag4_wq == 2'b00 | tlb_tag4_wq == 2'b11) & tlb_tag4_hes == 1'b1 & lru_tag4_dataout[4] == 1'b1 & lru_tag4_dataout[6] == 1'b1)) ? 1'b1 :
                                ((|(ex6_valid_q) == 1'b1 & ex6_ttype_q[1] == 1'b1 & ex6_state_q[0] == 1'b0 & ex6_illeg_instr_q[1] == 1'b0 & ex6_state_q[1] == 1'b0 & tlb_tag4_atsel == 1'b0 & ((|(ex6_valid_q & tlb_resv_match_vec_q) == 1'b1 & tlb_tag4_wq == 2'b01 & mmucfg_twc == 1'b1) | tlb_tag4_wq == 2'b00 | tlb_tag4_wq == 2'b11) & tlb_tag4_hes == 1'b0 & tlb_tag4_esel[1:2] == 2'b11)) ? 1'b1 :
                                ((tlb_tag4_ptereload == 1'b1 & (tlb_tag4_gs == 1'b0 | (tlb_tag4_gs == 1'b1 & lrat_tag4_hit_status[0:3] == 4'b1100)) & lru_tag4_dataout[4] == 1'b1 & lru_tag4_dataout[6] == 1'b1 & (lru_tag4_dataout[3] == 1'b0 | lru_tag4_dataout[11] == 1'b0) & tlb_tag4_wq == 2'b10 & tlb_tag4_is[0] == 1'b1 & tlb_tag4_pt == 1'b1)) ? 1'b1 :
                                tlb_tag4_parerr_write[3];


      // tag5 (ex7) phase signals
      // tlb_write        <= tlb_write_q; -- tag5, or ex7
      assign tlb_write = tlb_write_q & {`TLB_WAYS{tlb_tag5_parerr_zeroize | (~|(tlb_tag5_except))}};

      assign tlb_tag5_write = |(tlb_write_q) & (~|(tlb_tag5_except));

      //--------- this is what the erat expects on reload bus
      //  0:51  - EPN
      //  52  - X
      //  53:55  - SIZE
      //  56  - V
      //  57:60  - ThdID
      //  61:62  - Class
      //  63  - ExtClass
      //  64  - TID_NZ
      //  65  - reserved
      //  0:33 66:99 - RPN
      //  34:35 100:101 - R,C
      //  36:40 102:106 - ResvAttr
      //  41:44 107:110 - U0-U3
      //  45:49 111:115 - WIMGE
      //  50:52 116:118 - UX,UW,UR
      //  53:55 119:121 - SX,SW,SR
      //  56 122 - HS
      //  57 123 - TS
      //  58:65 124:131 - TID
      //---------
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
      // lru data format
      //   0:3  - valid(0:3)
      //   4:6  - LRU
      //   7  - parity
      //   8:11  - iprot(0:3)
      //   12:14  - reserved
      //   15  - parity
      // wr_ws0_data (LO)
      //  0:51  - EPN
      //  52:53  - Class
      //  54  - V
      //  55  - unused
      //  56  - X
      //  57:59  - SIZE
      //  60:63  - ThdID
      // wr_ws1_data (HI)
      //  0:6  - unused
      //  7:11  - ResvAttr
      //  12:15  - U0-U3
      //  16:17  - R,C
      //  18:51  - RPN
      //  52:56  - WIMGE
      //  57  - unused
      //  58:59  - UX,SX
      //  60:61  - UW,SW
      //  62:63  - UR,SR
      assign ex3_valid_32b = |(ex3_valid_q & (~(xu_mm_msr_cm)));
      assign tlb_ctl_ex2_flush_req = ((ex2_ttype_q[2:4] != 3'b000 & search_req_taken_sig == 1'b0 & searchresv_req_taken_sig == 1'b0)) ? (ex2_valid_q & (~(xu_ex2_flush))) :
                                     ((|(ex2_flush_req_q) == 1'b1)) ? (ex2_valid_q & (~(xu_ex2_flush))) :
                                     {`MM_THREADS{1'b0}};
      assign tlb_ctl_ex2_itag = ex2_itag_q;

      // illegal instruction terms
      //  state: 0:pr 1:gs 2:as 3:cm
      assign mas1_tsize_direct[0] = ((mas1_0_tsize == TLB_PgSize_4KB) |  (mas1_0_tsize == TLB_PgSize_64KB) | (mas1_0_tsize == TLB_PgSize_1MB) |
                                       (mas1_0_tsize == TLB_PgSize_16MB) | (mas1_0_tsize == TLB_PgSize_1GB));

      assign mas1_tsize_indirect[0] = ((mas1_0_tsize == TLB_PgSize_1MB) | (mas1_0_tsize == TLB_PgSize_256MB));

      assign mas1_tsize_lrat[0] = ((mas1_0_tsize == LRAT_PgSize_1MB) | (mas1_0_tsize == LRAT_PgSize_16MB) | (mas1_0_tsize == LRAT_PgSize_256MB) |
                                     (mas1_0_tsize == LRAT_PgSize_1GB) | (mas1_0_tsize == LRAT_PgSize_4GB) | (mas1_0_tsize == LRAT_PgSize_16GB) |
                                     (mas1_0_tsize == LRAT_PgSize_256GB) | (mas1_0_tsize == LRAT_PgSize_1TB));

      //  tlbre illegals only dependent on page size for non-lrat reads; lrat selected by ESEL
      assign ex2_tlbre_mas1_tsize_not_supp[0] = ((mas1_tsize_direct[0] == 1'b0 & (mas1_0_ind == 1'b0 | tlb0cfg_ind == 1'b0) & (mas0_0_atsel == 1'b0 | ex2_state_q[1] == 1'b1)) | (mas1_tsize_indirect[0] == 1'b0 & mas1_0_ind == 1'b1 & tlb0cfg_ind == 1'b1 & (mas0_0_atsel == 1'b0 | ex2_state_q[1] == 1'b1))) ? 1'b1 :
                                                1'b0;

      assign ex5_tlbre_mas1_tsize_not_supp[0] = ((mas1_tsize_direct[0] == 1'b0 & (mas1_0_ind == 1'b0 | tlb0cfg_ind == 1'b0) & (mas0_0_atsel == 1'b0 | ex5_state_q[1] == 1'b1)) | (mas1_tsize_indirect[0] == 1'b0 & mas1_0_ind == 1'b1 & tlb0cfg_ind == 1'b1 & (mas0_0_atsel == 1'b0 | ex5_state_q[1] == 1'b1))) ? 1'b1 :
                                                1'b0;

      //  tlbwe illegals dependent on WQ /= 2, for WQ=2 only trying to kill reservation, not  write TLB , and ISA is being changed per this
      assign ex5_tlbwe_mas1_tsize_not_supp[0] = ((mas1_tsize_direct[0] == 1'b0 & (mas1_0_ind == 1'b0 | tlb0cfg_ind == 1'b0) & mas0_0_wq != 2'b10 & (mas0_0_atsel == 1'b0 | ex5_state_q[1] == 1'b1)) | (mas1_tsize_indirect[0] == 1'b0 & mas1_0_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_0_wq != 2'b10 & (mas0_0_atsel == 1'b0 | ex5_state_q[1] == 1'b1)) | (mas1_tsize_lrat[0] == 1'b0 & mas0_0_atsel == 1'b1 & (mas0_0_wq == 2'b00 | mas0_0_wq == 2'b11) & ex5_state_q[1] == 1'b0)) ? 1'b1 :
                                                1'b0;

      assign ex6_tlbwe_mas1_tsize_not_supp[0] = ((mas1_tsize_direct[0] == 1'b0 & (mas1_0_ind == 1'b0 | tlb0cfg_ind == 1'b0) & mas0_0_wq != 2'b10 & (mas0_0_atsel == 1'b0 | ex6_state_q[1] == 1'b1)) | (mas1_tsize_indirect[0] == 1'b0 & mas1_0_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_0_wq != 2'b10 & (mas0_0_atsel == 1'b0 | ex6_state_q[1] == 1'b1)) | (mas1_tsize_lrat[0] == 1'b0 & mas0_0_atsel == 1'b1 & (mas0_0_wq == 2'b00 | mas0_0_wq == 2'b11) & ex6_state_q[1] == 1'b0)) ? 1'b1 :
                                                1'b0;

      //  state: 0:pr 1:gs 2:as 3:cm
      assign ex5_tlbwe_mas0_lrat_bad_selects[0] = (((mas0_0_hes == 1'b1 | mas0_0_wq == 2'b01 | mas0_0_wq == 2'b10) & mas0_0_atsel == 1'b1 & ex5_state_q[1] == 1'b0)) ? 1'b1 :
                                                  1'b0;
      assign ex6_tlbwe_mas0_lrat_bad_selects[0] = (((mas0_0_hes == 1'b1 | mas0_0_wq == 2'b01 | mas0_0_wq == 2'b10) & mas0_0_atsel == 1'b1 & ex6_state_q[1] == 1'b0)) ? 1'b1 :
                                                  1'b0;
      assign ex5_tlbwe_mas2_ind_bad_wimge[0] = ((mas1_0_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_0_wq != 2'b10 & (mas2_0_wimge[1] == 1'b1 | mas2_0_wimge[2] == 1'b0 | mas2_0_wimge[3] == 1'b1 | mas2_0_wimge[4] == 1'b1) & (mas0_0_atsel == 1'b0 | ex5_state_q[1] == 1'b1))) ? 1'b1 :
                                               1'b0;
      assign ex6_tlbwe_mas2_ind_bad_wimge[0] = ((mas1_0_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_0_wq != 2'b10 & (mas2_0_wimge[1] == 1'b1 | mas2_0_wimge[2] == 1'b0 | mas2_0_wimge[3] == 1'b1 | mas2_0_wimge[4] == 1'b1) & (mas0_0_atsel == 1'b0 | ex6_state_q[1] == 1'b1))) ? 1'b1 :
                                               1'b0;
      // Added for illegal indirect page size and sub-page size combinations
      //     mas3_0_usxwr           : in std_ulogic_vector(0 to 3);
      assign mas3_spsize_indirect[0] = (((mas1_0_tsize == TLB_PgSize_1MB & mas3_0_usxwr[0:3] == TLB_PgSize_4KB) | (mas1_0_tsize == TLB_PgSize_256MB & mas3_0_usxwr[0:3] == TLB_PgSize_64KB))) ? 1'b1 :
                                       1'b0;
      assign ex5_tlbwe_mas3_ind_bad_spsize[0] = ((mas1_0_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_0_wq != 2'b10 & mas3_spsize_indirect[0] == 1'b0 & (mas0_0_atsel == 1'b0 | ex5_state_q[1] == 1'b1))) ? 1'b1 :
                                                1'b0;
      assign ex6_tlbwe_mas3_ind_bad_spsize[0] = ((mas1_0_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_0_wq != 2'b10 & mas3_spsize_indirect[0] == 1'b0 & (mas0_0_atsel == 1'b0 | ex6_state_q[1] == 1'b1))) ? 1'b1 :
                                                1'b0;

`ifdef MM_THREADS2
      assign mas1_tsize_direct[1] = ((mas1_1_tsize == TLB_PgSize_4KB) | (mas1_1_tsize == TLB_PgSize_64KB) | (mas1_1_tsize == TLB_PgSize_1MB) |
                                       (mas1_1_tsize == TLB_PgSize_16MB) | (mas1_1_tsize == TLB_PgSize_1GB));

      assign mas1_tsize_indirect[1] = ((mas1_1_tsize == TLB_PgSize_1MB) | (mas1_1_tsize == TLB_PgSize_256MB));

      assign mas1_tsize_lrat[1] = ((mas1_1_tsize == LRAT_PgSize_1MB) | (mas1_1_tsize == LRAT_PgSize_16MB) | (mas1_1_tsize == LRAT_PgSize_256MB) |
                                     (mas1_1_tsize == LRAT_PgSize_1GB) | (mas1_1_tsize == LRAT_PgSize_4GB) | (mas1_1_tsize == LRAT_PgSize_16GB) |
                                     (mas1_1_tsize == LRAT_PgSize_256GB) | (mas1_1_tsize == LRAT_PgSize_1TB));

      assign ex2_tlbre_mas1_tsize_not_supp[1] = ((mas1_tsize_direct[1] == 1'b0 & (mas1_1_ind == 1'b0 | tlb0cfg_ind == 1'b0) & (mas0_1_atsel == 1'b0 | ex2_state_q[1] == 1'b1)) | (mas1_tsize_indirect[1] == 1'b0 & mas1_1_ind == 1'b1 & tlb0cfg_ind == 1'b1 & (mas0_1_atsel == 1'b0 | ex2_state_q[1] == 1'b1))) ? 1'b1 :
                                                1'b0;

      assign ex5_tlbre_mas1_tsize_not_supp[1] = ((mas1_tsize_direct[1] == 1'b0 & (mas1_1_ind == 1'b0 | tlb0cfg_ind == 1'b0) & (mas0_1_atsel == 1'b0 | ex5_state_q[1] == 1'b1)) | (mas1_tsize_indirect[1] == 1'b0 & mas1_1_ind == 1'b1 & tlb0cfg_ind == 1'b1 & (mas0_1_atsel == 1'b0 | ex5_state_q[1] == 1'b1))) ? 1'b1 :
                                                1'b0;

      assign ex5_tlbwe_mas1_tsize_not_supp[1] = ((mas1_tsize_direct[1] == 1'b0 & (mas1_1_ind == 1'b0 | tlb0cfg_ind == 1'b0) & mas0_1_wq != 2'b10 & (mas0_1_atsel == 1'b0 | ex5_state_q[1] == 1'b1)) | (mas1_tsize_indirect[1] == 1'b0 & mas1_1_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_1_wq != 2'b10 & (mas0_1_atsel == 1'b0 | ex5_state_q[1] == 1'b1)) | (mas1_tsize_lrat[1] == 1'b0 & mas0_1_atsel == 1'b1 & (mas0_1_wq == 2'b00 | mas0_1_wq == 2'b11) & ex5_state_q[1] == 1'b0)) ? 1'b1 :
                                                1'b0;

      assign ex6_tlbwe_mas1_tsize_not_supp[1] = ((mas1_tsize_direct[1] == 1'b0 & (mas1_1_ind == 1'b0 | tlb0cfg_ind == 1'b0) & mas0_1_wq != 2'b10 & (mas0_1_atsel == 1'b0 | ex6_state_q[1] == 1'b1)) | (mas1_tsize_indirect[1] == 1'b0 & mas1_1_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_1_wq != 2'b10 & (mas0_1_atsel == 1'b0 | ex6_state_q[1] == 1'b1)) | (mas1_tsize_lrat[1] == 1'b0 & mas0_1_atsel == 1'b1 & (mas0_1_wq == 2'b00 | mas0_1_wq == 2'b11) & ex6_state_q[1] == 1'b0)) ? 1'b1 :
                                                1'b0;

      //  state: 0:pr 1:gs 2:as 3:cm
      assign ex5_tlbwe_mas0_lrat_bad_selects[1] = (((mas0_1_hes == 1'b1 | mas0_1_wq == 2'b01 | mas0_1_wq == 2'b10) & mas0_1_atsel == 1'b1 & ex5_state_q[1] == 1'b0)) ? 1'b1 :
                                                  1'b0;
      assign ex6_tlbwe_mas0_lrat_bad_selects[1] = (((mas0_1_hes == 1'b1 | mas0_1_wq == 2'b01 | mas0_1_wq == 2'b10) & mas0_1_atsel == 1'b1 & ex6_state_q[1] == 1'b0)) ? 1'b1 :
                                                  1'b0;
      assign ex5_tlbwe_mas2_ind_bad_wimge[1] = ((mas1_1_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_1_wq != 2'b10 & (mas2_1_wimge[1] == 1'b1 | mas2_1_wimge[2] == 1'b0 | mas2_1_wimge[3] == 1'b1 | mas2_1_wimge[4] == 1'b1) & (mas0_1_atsel == 1'b0 | ex5_state_q[1] == 1'b1))) ? 1'b1 :
                                               1'b0;

      assign ex6_tlbwe_mas2_ind_bad_wimge[1] = ((mas1_1_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_1_wq != 2'b10 & (mas2_1_wimge[1] == 1'b1 | mas2_1_wimge[2] == 1'b0 | mas2_1_wimge[3] == 1'b1 | mas2_1_wimge[4] == 1'b1) & (mas0_1_atsel == 1'b0 | ex6_state_q[1] == 1'b1))) ? 1'b1 :
                                               1'b0;

      // Added for illegal indirect page size and sub-page size combinations
      //     mas3_1_usxwr           : in std_ulogic_vector(0 to 3);
      assign mas3_spsize_indirect[1] = (((mas1_1_tsize == TLB_PgSize_1MB & mas3_1_usxwr[0:3] == TLB_PgSize_4KB) | (mas1_1_tsize == TLB_PgSize_256MB & mas3_1_usxwr[0:3] == TLB_PgSize_64KB))) ? 1'b1 :
                                       1'b0;

      assign ex5_tlbwe_mas3_ind_bad_spsize[1] = ((mas1_1_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_1_wq != 2'b10 & mas3_spsize_indirect[1] == 1'b0 & (mas0_1_atsel == 1'b0 | ex5_state_q[1] == 1'b1))) ? 1'b1 :
                                                1'b0;

      assign ex6_tlbwe_mas3_ind_bad_spsize[1] = ((mas1_1_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_1_wq != 2'b10 & mas3_spsize_indirect[1] == 1'b0 & (mas0_1_atsel == 1'b0 | ex6_state_q[1] == 1'b1))) ? 1'b1 :
                                                1'b0;

`endif

      assign tlb_ctl_ex2_illeg_instr = ( ex2_tlbre_mas1_tsize_not_supp & ex2_valid_q & (~(xu_ex2_flush)) & {`MM_THREADS{(ex2_ttype_q[0] & ex2_hv_state & (~ex2_mas0_atsel))}} );

      assign tlb_ctl_ex6_illeg_instr = ( (ex6_tlbwe_mas1_tsize_not_supp | ex6_tlbwe_mas0_lrat_bad_selects | ex6_tlbwe_mas2_ind_bad_wimge | ex6_tlbwe_mas3_ind_bad_spsize) &
                                            ex6_valid_q & {`MM_THREADS{(ex6_ttype_q[1] & (ex6_hv_state | (ex6_priv_state & (~ex6_dgtmi_state))))}} );

      assign ex6_illeg_instr_d[0] = ex5_ttype_q[0] & |(ex5_tlbre_mas1_tsize_not_supp & ex5_valid_q);

      assign ex6_illeg_instr_d[1] = ex5_ttype_q[1] & |( (ex5_tlbwe_mas1_tsize_not_supp | ex5_tlbwe_mas0_lrat_bad_selects |
                                                           ex5_tlbwe_mas2_ind_bad_wimge | ex5_tlbwe_mas3_ind_bad_spsize) & ex5_valid_q );

      assign ex6_illeg_instr = ex6_illeg_instr_q;

      // state: 0:pr 1:gs 2:as 3:cm
      //ex6_hv_state   <= not ex6_state_q(0) and not ex6_state_q(1); -- pr=0, gs=0
      //ex6_priv_state <= not ex6_state_q(0); -- pr=0
      //ex6_dgtmi_state <= |(ex6_valid_q and xu_mm_epcr_dgtmi); -- disable guest tlb mgmt instr's
      //     lru_tag4_dataout   : in std_ulogic_vector(0 to 15);  -- latched lru_dataout
      //     tlb_tag4_esel      : in std_ulogic_vector(0 to 2);
      //     tlb_tag4_wq        : in std_ulogic_vector(0 to 1);
      //     tlb_tag4_gs        : in std_ulogic;
      //     tlb_tag4_hes       : in std_ulogic;
      //     tlb_tag4_atsel     : in std_ulogic;
      //     tlb_tag4_cmp_hit   : in std_ulogic;  -- hit indication
      //     tlb_tag4_way_ind   : in std_ulogic;  -- indirect entry hit indication
      //     tlb_tag4_ptereload : in std_ulogic;  -- ptereload write event
      // Event     |          Exceptions
      //           | PT fault   | TLB Inelig | LRAT miss
      //--------------------------------------------------------
      // tlbwe     |  -         | hv_priv=1  | lrat_miss=1
      //           |            | tlbi=1     | esr_pt=0
      //           |            | esr_pt=0   |
      //--------------------------------------------------------
      // ptereload | DSI        | DSI        | lrat_miss=1
      //  (data)   | pt_fault=1 | tlbi=1     | esr_pt=1
      //           | PT=1       | esr_pt=0 ? | esr_data=1
      //           |            |            | esr_epid=class(0)
      //           |            |            | esr_st=class(1)
      //--------------------------------------------------------
      // ptereload | ISI        | ISI        | lrat_miss=1
      //  (inst)   | pt_fault=1 | tlbi=1     | esr_pt=1
      //           | PT=1       | esr_pt=0 ? | esr_data=0
      //--------------------------------------------------------
      assign tlb_lper_lpn = ptereload_req_pte_q[`ptepos_rpn + 10:`ptepos_rpn + 39];

      assign tlb_lper_lps = ptereload_req_pte_q[`ptepos_size:`ptepos_size + 3];

      // lrat hit_status: 0:val,1:hit,2:multihit,3:inval_pgsize
      //  unused `tagpos_is def is mas1_v, mas1_iprot for tlbwe, and is (pte.valid & 0) for ptereloads
      assign tlb_lper_we = ( (tlb_tag4_ptereload == 1'b1 & tlb_tag4_gs == 1'b1 & mmucfg_lrat == 1'b1 &
                                tlb_tag4_pt == 1'b1 & tlb_tag4_wq == 2'b10 & tlb_tag4_is[0] == 1'b1 &
                                lrat_tag4_hit_status[0:3] != 4'b1100) ) ? tlb_tag0_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS -1] :
                           {`MM_THREADS{1'b0}};

      assign pte_tag0_lpn = ptereload_req_pte_q[`ptepos_rpn + 10:`ptepos_rpn + 39];

      assign pte_tag0_lpid = tlb_tag0_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1];


      // perf count events
      assign tlb_ctl_perf_tlbwec_resv = |(ex6_valid_q & tlb_resv_match_vec_q) & ex6_ttype_q[1] & (tlb_tag4_wq == 2'b01);

      assign tlb_ctl_perf_tlbwec_noresv = |(ex6_valid_q & (~tlb_resv_match_vec_q)) & ex6_ttype_q[1] & (tlb_tag4_wq == 2'b01);

      // power clock gating for latches
      assign tlb_early_act = xu_mm_ccr2_notlb_b & (any_tlb_req_sig | (~(tlb_seq_idle_sig)) | tlb_ctl_any_tag_flush_sig | tlb_seq_abort);

      assign tlb_delayed_act_d[0:1] = (tlb_early_act == 1'b1) ? 2'b11 :
                                      (tlb_delayed_act_q[0:1] == 2'b11) ? 2'b10 :
                                      (tlb_delayed_act_q[0:1] == 2'b10) ? 2'b01 :
                                      2'b00;

      // mmq_tlb_req  => n/a                         => mmucr2(0)
      // mmq_tlb_ctl  => tlb_delayed_act(2 to 8)     => mmucr2(1)
      // mmq_tlb_cmp  => tlb_delayed_act(9 to 16)    => mmucr2(2)
      // tlb0, tlb1   => tlb_delayed_act(17)         => mmucr2(2)
      // tlb2, tlb3   => tlb_delayed_act(18)         => mmucr2(2)
      // lru rd       => tlb_delayed_act(19)         => removed mmucr2(2) override
      // lru wr       => tlb_delayed_act(33)         => removed mmucr2(2) override
      // mmq_tlb_lrat => tlb_delayed_act(20 to 23)   => mmucr2(3)
      // mmq_htw      => tlb_delayed_act(24 to 28)   => mmucr2(4)
      // mmq_spr      => tlb_delayed_act(29 to 32)   => mmucr2(5 to 6)
      // mmq_inval    => n/a                         => mmucr2(7)
      assign tlb_delayed_act_d[2:8]   = {7{tlb_early_act | tlb_delayed_act_q[0] | tlb_delayed_act_q[1] | mmucr2[1]}};
      assign tlb_delayed_act_d[9:16]  = {8{tlb_early_act | tlb_delayed_act_q[0] | tlb_delayed_act_q[1] | mmucr2[2]}};
      assign tlb_delayed_act_d[17:18] = {2{tlb_early_act | tlb_delayed_act_q[0] | tlb_delayed_act_q[1] | mmucr2[2]}};  // tlb array 0/1, 2/3 act's
      assign tlb_delayed_act_d[20:23] = {4{tlb_early_act | tlb_delayed_act_q[0] | tlb_delayed_act_q[1] | mmucr2[3]}};
      assign tlb_delayed_act_d[24:28] = {5{tlb_early_act | tlb_delayed_act_q[0] | tlb_delayed_act_q[1] | mmucr2[4]}};
      assign tlb_delayed_act_d[29:32] = {4{tlb_early_act | tlb_delayed_act_q[0] | tlb_delayed_act_q[1] | mmucr2[6]}};

      assign tlb_delayed_act_d[19] = xu_mm_ccr2_notlb_b & tlb_seq_lru_rd_act; // lru rd_act
      assign tlb_delayed_act_d[33] = xu_mm_ccr2_notlb_b & tlb_seq_lru_wr_act; // lru wr_act

      assign tlb_delayed_act[9:33] = tlb_delayed_act_q[9:33];

      assign tlb_tag0_act = tlb_early_act | mmucr2[1];
      assign tlb_snoop_act = (tlb_snoop_coming | mmucr2[1]) & xu_mm_ccr2_notlb_b;
      assign tlb_ctl_dbg_seq_q = tlb_seq_q;
      assign tlb_ctl_dbg_seq_idle = tlb_seq_idle_sig;
      assign tlb_ctl_dbg_seq_any_done_sig = tlb_seq_any_done_sig;
      assign tlb_ctl_dbg_seq_abort = tlb_seq_abort;
      assign tlb_ctl_dbg_any_tlb_req_sig = any_tlb_req_sig;
      assign tlb_ctl_dbg_any_req_taken_sig = any_req_taken_sig;
      assign tlb_ctl_dbg_tag0_valid = |(tlb_tag0_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]);
      assign tlb_ctl_dbg_tag0_thdid[0] = tlb_tag0_q[`tagpos_thdid + 2] | tlb_tag0_q[`tagpos_thdid + 3];
      assign tlb_ctl_dbg_tag0_thdid[1] = tlb_tag0_q[`tagpos_thdid + 1] | tlb_tag0_q[`tagpos_thdid + 3];
      assign tlb_ctl_dbg_tag0_type[0] = tlb_tag0_q[`tagpos_type + 4] | tlb_tag0_q[`tagpos_type + 5] | tlb_tag0_q[`tagpos_type + 6] | tlb_tag0_q[`tagpos_type + 7];
      assign tlb_ctl_dbg_tag0_type[1] = tlb_tag0_q[`tagpos_type + 2] | tlb_tag0_q[`tagpos_type + 3] | tlb_tag0_q[`tagpos_type + 6] | tlb_tag0_q[`tagpos_type + 7];
      assign tlb_ctl_dbg_tag0_type[2] = tlb_tag0_q[`tagpos_type + 1] | tlb_tag0_q[`tagpos_type + 3] | tlb_tag0_q[`tagpos_type + 5] | tlb_tag0_q[`tagpos_type + 7];
      assign tlb_ctl_dbg_tag0_wq = tlb_tag0_q[`tagpos_wq:`tagpos_wq + 1];
      assign tlb_ctl_dbg_tag0_gs = tlb_tag0_q[`tagpos_gs];
      assign tlb_ctl_dbg_tag0_pr = tlb_tag0_q[`tagpos_pr];
      assign tlb_ctl_dbg_tag0_atsel = tlb_tag0_q[`tagpos_atsel];
      assign tlb_ctl_dbg_tag5_tlb_write_q = tlb_write_q;
      assign tlb_ctl_dbg_any_tag_flush_sig = tlb_ctl_any_tag_flush_sig;
      assign tlb_ctl_dbg_resv0_tag0_lpid_match = tlb_resv0_tag0_lpid_match;
      assign tlb_ctl_dbg_resv0_tag0_pid_match = tlb_resv0_tag0_pid_match;
      assign tlb_ctl_dbg_resv0_tag0_as_snoop_match = tlb_resv0_tag0_as_snoop_match;
      assign tlb_ctl_dbg_resv0_tag0_gs_snoop_match = tlb_resv0_tag0_gs_snoop_match;
      assign tlb_ctl_dbg_resv0_tag0_as_tlbwe_match = tlb_resv0_tag0_as_tlbwe_match;
      assign tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match = tlb_resv0_tag0_gs_tlbwe_match;
      assign tlb_ctl_dbg_resv0_tag0_ind_match = tlb_resv0_tag0_ind_match;
      assign tlb_ctl_dbg_resv0_tag0_epn_loc_match = tlb_resv0_tag0_epn_loc_match;
      assign tlb_ctl_dbg_resv0_tag0_epn_glob_match = tlb_resv0_tag0_epn_glob_match;
      assign tlb_ctl_dbg_resv0_tag0_class_match = tlb_resv0_tag0_class_match;
      assign tlb_ctl_dbg_set_resv[0] = tlb_set_resv0;
      assign tlb_ctl_dbg_clr_resv_q[0] = tlb_clr_resv_q[0];
      assign tlb_ctl_dbg_resv_valid[0] = tlb_resv_valid_vec[0];
      assign tlb_ctl_dbg_resv_match_vec_q[0] = tlb_resv_match_vec_q[0];
`ifdef MM_THREADS2
      assign tlb_ctl_dbg_resv1_tag0_lpid_match = tlb_resv1_tag0_lpid_match;
      assign tlb_ctl_dbg_resv1_tag0_pid_match = tlb_resv1_tag0_pid_match;
      assign tlb_ctl_dbg_resv1_tag0_as_snoop_match = tlb_resv1_tag0_as_snoop_match;
      assign tlb_ctl_dbg_resv1_tag0_gs_snoop_match = tlb_resv1_tag0_gs_snoop_match;
      assign tlb_ctl_dbg_resv1_tag0_as_tlbwe_match = tlb_resv1_tag0_as_tlbwe_match;
      assign tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match = tlb_resv1_tag0_gs_tlbwe_match;
      assign tlb_ctl_dbg_resv1_tag0_ind_match = tlb_resv1_tag0_ind_match;
      assign tlb_ctl_dbg_resv1_tag0_epn_loc_match = tlb_resv1_tag0_epn_loc_match;
      assign tlb_ctl_dbg_resv1_tag0_epn_glob_match = tlb_resv1_tag0_epn_glob_match;
      assign tlb_ctl_dbg_resv1_tag0_class_match = tlb_resv1_tag0_class_match;
      assign tlb_ctl_dbg_set_resv[1] = tlb_set_resv1;
      assign tlb_ctl_dbg_clr_resv_q[1] = tlb_clr_resv_q[1];
      assign tlb_ctl_dbg_resv_valid[1] = tlb_resv_valid_vec[1];
      assign tlb_ctl_dbg_resv_match_vec_q[1] = tlb_resv_match_vec_q[1];
`else
      assign tlb_ctl_dbg_resv1_tag0_lpid_match = 1'b0;
      assign tlb_ctl_dbg_resv1_tag0_pid_match = 1'b0;
      assign tlb_ctl_dbg_resv1_tag0_as_snoop_match = 1'b0;
      assign tlb_ctl_dbg_resv1_tag0_gs_snoop_match = 1'b0;
      assign tlb_ctl_dbg_resv1_tag0_as_tlbwe_match = 1'b0;
      assign tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match = 1'b0;
      assign tlb_ctl_dbg_resv1_tag0_ind_match = 1'b0;
      assign tlb_ctl_dbg_resv1_tag0_epn_loc_match = 1'b0;
      assign tlb_ctl_dbg_resv1_tag0_epn_glob_match = 1'b0;
      assign tlb_ctl_dbg_resv1_tag0_class_match = 1'b0;
      assign tlb_ctl_dbg_set_resv[1] = 1'b0;
      assign tlb_ctl_dbg_clr_resv_q[1] = 1'b0;
      assign tlb_ctl_dbg_resv_valid[1] = 1'b0;
      assign tlb_ctl_dbg_resv_match_vec_q[1] = 1'b0;
`endif
      assign tlb_ctl_dbg_resv2_tag0_lpid_match = 1'b0;
      assign tlb_ctl_dbg_resv2_tag0_pid_match = 1'b0;
      assign tlb_ctl_dbg_resv2_tag0_as_snoop_match = 1'b0;
      assign tlb_ctl_dbg_resv2_tag0_gs_snoop_match = 1'b0;
      assign tlb_ctl_dbg_resv2_tag0_as_tlbwe_match = 1'b0;
      assign tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match = 1'b0;
      assign tlb_ctl_dbg_resv2_tag0_ind_match = 1'b0;
      assign tlb_ctl_dbg_resv2_tag0_epn_loc_match = 1'b0;
      assign tlb_ctl_dbg_resv2_tag0_epn_glob_match = 1'b0;
      assign tlb_ctl_dbg_resv2_tag0_class_match = 1'b0;
      assign tlb_ctl_dbg_set_resv[2] = 1'b0;
      assign tlb_ctl_dbg_clr_resv_q[2] = 1'b0;
      assign tlb_ctl_dbg_resv_valid[2] = 1'b0;
      assign tlb_ctl_dbg_resv_match_vec_q[2] = 1'b0;
      assign tlb_ctl_dbg_resv3_tag0_lpid_match = 1'b0;
      assign tlb_ctl_dbg_resv3_tag0_pid_match = 1'b0;
      assign tlb_ctl_dbg_resv3_tag0_as_snoop_match = 1'b0;
      assign tlb_ctl_dbg_resv3_tag0_gs_snoop_match = 1'b0;
      assign tlb_ctl_dbg_resv3_tag0_as_tlbwe_match = 1'b0;
      assign tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match = 1'b0;
      assign tlb_ctl_dbg_resv3_tag0_ind_match = 1'b0;
      assign tlb_ctl_dbg_resv3_tag0_epn_loc_match = 1'b0;
      assign tlb_ctl_dbg_resv3_tag0_epn_glob_match = 1'b0;
      assign tlb_ctl_dbg_resv3_tag0_class_match = 1'b0;
      assign tlb_ctl_dbg_set_resv[3] = 1'b0;
      assign tlb_ctl_dbg_clr_resv_q[3] = 1'b0;
      assign tlb_ctl_dbg_resv_valid[3] = 1'b0;
      assign tlb_ctl_dbg_resv_match_vec_q[3] = 1'b0;
      assign tlb_ctl_dbg_clr_resv_terms = {4{1'b0}};

      // unused spare signal assignments
      assign unused_dc[0] = |(lcb_delay_lclkr_dc[1:4]);
      assign unused_dc[1] = |(lcb_mpw1_dc_b[1:4]);
      assign unused_dc[2] = pc_func_sl_force;
      assign unused_dc[3] = pc_func_sl_thold_0_b;
      assign unused_dc[4] = tc_scan_dis_dc_b;
      assign unused_dc[5] = tc_scan_diag_dc;
      assign unused_dc[6] = tc_lbist_en_dc;
      assign unused_dc[7] = tlb_tag0_q[109];
`ifdef MM_THREADS2
      assign unused_dc[8] = mmucr3_0[49] | mmucr3_0[56] | mmucr3_1[49] | mmucr3_1[56];
      assign unused_dc[9] = mmucr3_0[50] | mmucr3_0[57] | mmucr3_1[50] | mmucr3_1[57];
      assign unused_dc[10] = mmucr3_0[51] | mmucr3_0[58] | mmucr3_1[51] | mmucr3_1[58];
      assign unused_dc[11] = mmucr3_0[52] | mmucr3_0[59] | mmucr3_1[52] | mmucr3_1[59];
      assign unused_dc[12] = mmucr3_0[53] | mmucr3_0[60] | mmucr3_1[53] | mmucr3_1[60];
      assign unused_dc[13] = mmucr3_0[61] | mmucr3_1[61];
      assign unused_dc[14] = mmucr3_0[62] | mmucr3_1[62];
      assign unused_dc[15] = mmucr3_0[63] | mmucr3_1[63];
`else
      assign unused_dc[8] = mmucr3_0[49] | mmucr3_0[56];
      assign unused_dc[9] = mmucr3_0[50] | mmucr3_0[57];
      assign unused_dc[10] = mmucr3_0[51] | mmucr3_0[58];
      assign unused_dc[11] = mmucr3_0[52] | mmucr3_0[59];
      assign unused_dc[12] = mmucr3_0[53] | mmucr3_0[60];
      assign unused_dc[13] = mmucr3_0[61];
      assign unused_dc[14] = mmucr3_0[62];
      assign unused_dc[15] = mmucr3_0[63];
`endif
      assign unused_dc[16] = |(pgsize_qty);
      assign unused_dc[17] = |(pgsize_tid0_qty);
      assign unused_dc[18] = ptereload_req_tag[66];
      assign unused_dc[19] = |(ptereload_req_tag[78:81]);
      assign unused_dc[20] = |(ptereload_req_tag[84:89]);
      assign unused_dc[21] = ptereload_req_tag[98];
      assign unused_dc[22] = |(ptereload_req_tag[108:109]);
      assign unused_dc[23] = lru_tag4_dataout[7];
      assign unused_dc[24] = |(lru_tag4_dataout[12:15]);
      assign unused_dc[25] = tlb_tag4_esel[0];
      assign unused_dc[26] = ex3_valid_32b;
`ifdef MM_THREADS2
      assign unused_dc[27] = mas2_0_wimge[0] | mas2_1_wimge[0];
`else
      assign unused_dc[27] = mas2_0_wimge[0];
`endif
      assign unused_dc[28] = |(xu_ex1_flush_q);
      assign unused_dc[29] = |(mm_xu_eratmiss_done);
      assign unused_dc[30] = |(mm_xu_tlb_miss);
      assign unused_dc[31] = |(mm_xu_tlb_inelig);
      assign unused_dc[32] = mmucr1_tlbi_msb;
      assign unused_dc[33] = mmucsr0_tlb0fi;
      assign unused_dc[34] = tlb_tag4_pr;
      assign unused_dc[35] = |({mmucr2[0], mmucr2[5], mmucr2[7], mmucr2[8:11]});
      assign unused_dc[36] = tlb_seq_lrat_enable;

      generate
         if (`THDID_WIDTH > `MM_THREADS)
         begin : tlbctlthdNExist
            begin : xhdl0
               genvar                         tid;
               for (tid = `MM_THREADS; tid <= (`THDID_WIDTH - 1); tid = tid + 1)
               begin : tlbctlthdunused
                  assign unused_dc_thdid[tid] = tlb_delayed_act_q[tid + 5];
               end
            end
         end
      endgenerate


      //---------------------------------------------------------------------
      // Latches
      //---------------------------------------------------------------------

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) xu_ex1_flush_latch(
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
         .scin(siv[xu_ex1_flush_offset:xu_ex1_flush_offset + `MM_THREADS - 1]),
         .scout(sov[xu_ex1_flush_offset:xu_ex1_flush_offset + `MM_THREADS - 1]),
         .din(xu_ex1_flush_d),
         .dout(xu_ex1_flush_q)
      );

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex1_valid_latch(
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
         .scin(siv[ex1_valid_offset:ex1_valid_offset + `MM_THREADS - 1]),
         .scout(sov[ex1_valid_offset:ex1_valid_offset + `MM_THREADS - 1]),
         .din(ex1_valid_d),
         .dout(ex1_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`CTL_TTYPE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex1_ttype_latch(
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
         .scin(siv[ex1_ttype_offset:ex1_ttype_offset + `CTL_TTYPE_WIDTH - 1]),
         .scout(sov[ex1_ttype_offset:ex1_ttype_offset + `CTL_TTYPE_WIDTH - 1]),
         .din(ex1_ttype_d[0:`CTL_TTYPE_WIDTH - 1]),
         .dout(ex1_ttype_q[0:`CTL_TTYPE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH((`CTL_STATE_WIDTH+1)), .INIT(0), .NEEDS_SRESET(1)) ex1_state_latch(
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
         .scin(siv[ex1_state_offset:ex1_state_offset + (`CTL_STATE_WIDTH+1) - 1]),
         .scout(sov[ex1_state_offset:ex1_state_offset + (`CTL_STATE_WIDTH+1) - 1]),
         .din(ex1_state_d[0:`CTL_STATE_WIDTH]),
         .dout(ex1_state_q[0:`CTL_STATE_WIDTH])
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex1_pid_latch(
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
         .scin(siv[ex1_pid_offset:ex1_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[ex1_pid_offset:ex1_pid_offset + `PID_WIDTH - 1]),
         .din(ex1_pid_d[0:`PID_WIDTH - 1]),
         .dout(ex1_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex1_itag_latch(
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
         .scin(siv[ex1_itag_offset:ex1_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[ex1_itag_offset:ex1_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(ex1_itag_d),
         .dout(ex1_itag_q)
      );
      //-----------------------------------------------------------------------------

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex2_valid_latch(
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
         .scin(siv[ex2_valid_offset:ex2_valid_offset + `MM_THREADS - 1]),
         .scout(sov[ex2_valid_offset:ex2_valid_offset + `MM_THREADS - 1]),
         .din(ex2_valid_d),
         .dout(ex2_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex2_flush_latch(
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
         .scin(siv[ex2_flush_offset:ex2_flush_offset + `MM_THREADS - 1]),
         .scout(sov[ex2_flush_offset:ex2_flush_offset + `MM_THREADS - 1]),
         .din(ex2_flush_d),
         .dout(ex2_flush_q)
      );

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex2_flush_req_latch(
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
         .scin(siv[ex2_flush_req_offset:ex2_flush_req_offset + `MM_THREADS - 1]),
         .scout(sov[ex2_flush_req_offset:ex2_flush_req_offset + `MM_THREADS - 1]),
         .din(ex2_flush_req_d),
         .dout(ex2_flush_req_q)
      );

      tri_rlmreg_p #(.WIDTH(`CTL_TTYPE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex2_ttype_latch(
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
         .scin(siv[ex2_ttype_offset:ex2_ttype_offset + `CTL_TTYPE_WIDTH - 1]),
         .scout(sov[ex2_ttype_offset:ex2_ttype_offset + `CTL_TTYPE_WIDTH - 1]),
         .din(ex2_ttype_d[0:`CTL_TTYPE_WIDTH - 1]),
         .dout(ex2_ttype_q[0:`CTL_TTYPE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH((`CTL_STATE_WIDTH+1)), .INIT(0), .NEEDS_SRESET(1)) ex2_state_latch(
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
         .scin(siv[ex2_state_offset:ex2_state_offset + (`CTL_STATE_WIDTH+1) - 1]),
         .scout(sov[ex2_state_offset:ex2_state_offset + (`CTL_STATE_WIDTH+1) - 1]),
         .din(ex2_state_d[0:`CTL_STATE_WIDTH]),
         .dout(ex2_state_q[0:`CTL_STATE_WIDTH])
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex2_pid_latch(
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
         .scin(siv[ex2_pid_offset:ex2_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[ex2_pid_offset:ex2_pid_offset + `PID_WIDTH - 1]),
         .din(ex2_pid_d[0:`PID_WIDTH - 1]),
         .dout(ex2_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex2_itag_latch(
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
         .scin(siv[ex2_itag_offset:ex2_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[ex2_itag_offset:ex2_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(ex2_itag_d),
         .dout(ex2_itag_q)
      );
      //-----------------------------------------------------------------------------

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_valid_latch(
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
         .scin(siv[ex3_valid_offset:ex3_valid_offset + `MM_THREADS - 1]),
         .scout(sov[ex3_valid_offset:ex3_valid_offset + `MM_THREADS - 1]),
         .din(ex3_valid_d),
         .dout(ex3_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_flush_latch(
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
         .scin(siv[ex3_flush_offset:ex3_flush_offset + `MM_THREADS - 1]),
         .scout(sov[ex3_flush_offset:ex3_flush_offset + `MM_THREADS - 1]),
         .din(ex3_flush_d),
         .dout(ex3_flush_q)
      );

      tri_rlmreg_p #(.WIDTH(`CTL_TTYPE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex3_ttype_latch(
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
         .scin(siv[ex3_ttype_offset:ex3_ttype_offset + `CTL_TTYPE_WIDTH - 1]),
         .scout(sov[ex3_ttype_offset:ex3_ttype_offset + `CTL_TTYPE_WIDTH - 1]),
         .din(ex3_ttype_d[0:`CTL_TTYPE_WIDTH - 1]),
         .dout(ex3_ttype_q[0:`CTL_TTYPE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH((`CTL_STATE_WIDTH+1)), .INIT(0), .NEEDS_SRESET(1)) ex3_state_latch(
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
         .scin(siv[ex3_state_offset:ex3_state_offset + (`CTL_STATE_WIDTH+1) - 1]),
         .scout(sov[ex3_state_offset:ex3_state_offset + (`CTL_STATE_WIDTH+1) - 1]),
         .din(ex3_state_d[0:`CTL_STATE_WIDTH]),
         .dout(ex3_state_q[0:`CTL_STATE_WIDTH])
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex3_pid_latch(
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
         .scin(siv[ex3_pid_offset:ex3_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[ex3_pid_offset:ex3_pid_offset + `PID_WIDTH - 1]),
         .din(ex3_pid_d[0:`PID_WIDTH - 1]),
         .dout(ex3_pid_q[0:`PID_WIDTH - 1])
      );
      //-----------------------------------------------------------------------------

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

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_flush_latch(
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
         .scin(siv[ex4_flush_offset:ex4_flush_offset + `MM_THREADS - 1]),
         .scout(sov[ex4_flush_offset:ex4_flush_offset + `MM_THREADS - 1]),
         .din(ex4_flush_d),
         .dout(ex4_flush_q)
      );

      tri_rlmreg_p #(.WIDTH(`CTL_TTYPE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex4_ttype_latch(
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
         .scin(siv[ex4_ttype_offset:ex4_ttype_offset + `CTL_TTYPE_WIDTH - 1]),
         .scout(sov[ex4_ttype_offset:ex4_ttype_offset + `CTL_TTYPE_WIDTH - 1]),
         .din(ex4_ttype_d[0:`CTL_TTYPE_WIDTH - 1]),
         .dout(ex4_ttype_q[0:`CTL_TTYPE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH((`CTL_STATE_WIDTH+1)), .INIT(0), .NEEDS_SRESET(1)) ex4_state_latch(
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
         .scin(siv[ex4_state_offset:ex4_state_offset + (`CTL_STATE_WIDTH+1) - 1]),
         .scout(sov[ex4_state_offset:ex4_state_offset + (`CTL_STATE_WIDTH+1) - 1]),
         .din(ex4_state_d[0:`CTL_STATE_WIDTH]),
         .dout(ex4_state_q[0:`CTL_STATE_WIDTH])
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex4_pid_latch(
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
         .scin(siv[ex4_pid_offset:ex4_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[ex4_pid_offset:ex4_pid_offset + `PID_WIDTH - 1]),
         .din(ex4_pid_d[0:`PID_WIDTH - 1]),
         .dout(ex4_pid_q[0:`PID_WIDTH - 1])
      );
      //-----------------------------------------------------------------------------

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

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_flush_latch(
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
         .scin(siv[ex5_flush_offset:ex5_flush_offset + `MM_THREADS - 1]),
         .scout(sov[ex5_flush_offset:ex5_flush_offset + `MM_THREADS - 1]),
         .din(ex5_flush_d),
         .dout(ex5_flush_q)
      );

      tri_rlmreg_p #(.WIDTH(`CTL_TTYPE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex5_ttype_latch(
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
         .scin(siv[ex5_ttype_offset:ex5_ttype_offset + `CTL_TTYPE_WIDTH - 1]),
         .scout(sov[ex5_ttype_offset:ex5_ttype_offset + `CTL_TTYPE_WIDTH - 1]),
         .din(ex5_ttype_d[0:`CTL_TTYPE_WIDTH - 1]),
         .dout(ex5_ttype_q[0:`CTL_TTYPE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH((`CTL_STATE_WIDTH+1)), .INIT(0), .NEEDS_SRESET(1)) ex5_state_latch(
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
         .scin(siv[ex5_state_offset:ex5_state_offset + (`CTL_STATE_WIDTH+1) - 1]),
         .scout(sov[ex5_state_offset:ex5_state_offset + (`CTL_STATE_WIDTH+1) - 1]),
         .din(ex5_state_d[0:`CTL_STATE_WIDTH]),
         .dout(ex5_state_q[0:`CTL_STATE_WIDTH])
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex5_pid_latch(
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
         .scin(siv[ex5_pid_offset:ex5_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[ex5_pid_offset:ex5_pid_offset + `PID_WIDTH - 1]),
         .din(ex5_pid_d[0:`PID_WIDTH - 1]),
         .dout(ex5_pid_q[0:`PID_WIDTH - 1])
      );
      //------------------------------------------------

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

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex6_flush_latch(
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
         .scin(siv[ex6_flush_offset:ex6_flush_offset + `MM_THREADS - 1]),
         .scout(sov[ex6_flush_offset:ex6_flush_offset + `MM_THREADS - 1]),
         .din(ex6_flush_d),
         .dout(ex6_flush_q)
      );

      tri_rlmreg_p #(.WIDTH(`CTL_TTYPE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex6_ttype_latch(
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
         .scin(siv[ex6_ttype_offset:ex6_ttype_offset + `CTL_TTYPE_WIDTH - 1]),
         .scout(sov[ex6_ttype_offset:ex6_ttype_offset + `CTL_TTYPE_WIDTH - 1]),
         .din(ex6_ttype_d[0:`CTL_TTYPE_WIDTH - 1]),
         .dout(ex6_ttype_q[0:`CTL_TTYPE_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH((`CTL_STATE_WIDTH+1)), .INIT(0), .NEEDS_SRESET(1)) ex6_state_latch(
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
         .scin(siv[ex6_state_offset:ex6_state_offset + (`CTL_STATE_WIDTH+1) - 1]),
         .scout(sov[ex6_state_offset:ex6_state_offset + (`CTL_STATE_WIDTH+1) - 1]),
         .din(ex6_state_d[0:`CTL_STATE_WIDTH]),
         .dout(ex6_state_q[0:`CTL_STATE_WIDTH])
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex6_pid_latch(
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
         .scin(siv[ex6_pid_offset:ex6_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[ex6_pid_offset:ex6_pid_offset + `PID_WIDTH - 1]),
         .din(ex6_pid_d[0:`PID_WIDTH - 1]),
         .dout(ex6_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`TLB_TAG_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_tag0_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_tag0_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_tag0_offset:tlb_tag0_offset + `TLB_TAG_WIDTH - 1]),
         .scout(sov[tlb_tag0_offset:tlb_tag0_offset + `TLB_TAG_WIDTH - 1]),
         .din(tlb_tag0_d[0:`TLB_TAG_WIDTH - 1]),
         .dout(tlb_tag0_q[0:`TLB_TAG_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`TLB_TAG_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_tag1_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[2]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_tag1_offset:tlb_tag1_offset + `TLB_TAG_WIDTH - 1]),
         .scout(sov[tlb_tag1_offset:tlb_tag1_offset + `TLB_TAG_WIDTH - 1]),
         .din(tlb_tag1_d[0:`TLB_TAG_WIDTH - 1]),
         .dout(tlb_tag1_q[0:`TLB_TAG_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`TLB_TAG_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_tag2_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_tag2_offset:tlb_tag2_offset + `TLB_TAG_WIDTH - 1]),
         .scout(sov[tlb_tag2_offset:tlb_tag2_offset + `TLB_TAG_WIDTH - 1]),
         .din(tlb_tag2_d[0:`TLB_TAG_WIDTH - 1]),
         .dout(tlb_tag2_q[0:`TLB_TAG_WIDTH - 1])
      );
      // hashed address input to tlb, tag1 phase

      tri_rlmreg_p #(.WIDTH(`TLB_ADDR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_addr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_addr_offset:tlb_addr_offset + `TLB_ADDR_WIDTH - 1]),
         .scout(sov[tlb_addr_offset:tlb_addr_offset + `TLB_ADDR_WIDTH - 1]),
         .din(tlb_addr_d[0:`TLB_ADDR_WIDTH - 1]),
         .dout(tlb_addr_q[0:`TLB_ADDR_WIDTH - 1])
      );
      // hashed address input to tlb, tag2 phase

      tri_rlmreg_p #(.WIDTH(`TLB_ADDR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_addr2_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_addr2_offset:tlb_addr2_offset + `TLB_ADDR_WIDTH - 1]),
         .scout(sov[tlb_addr2_offset:tlb_addr2_offset + `TLB_ADDR_WIDTH - 1]),
         .din(tlb_addr2_d[0:`TLB_ADDR_WIDTH - 1]),
         .dout(tlb_addr2_q[0:`TLB_ADDR_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`TLB_WAYS), .INIT(0), .NEEDS_SRESET(1)) tlb_write_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_write_offset:tlb_write_offset + `TLB_WAYS - 1]),
         .scout(sov[tlb_write_offset:tlb_write_offset + `TLB_WAYS - 1]),
         .din(tlb_write_d[0:`TLB_WAYS - 1]),
         .dout(tlb_write_q[0:`TLB_WAYS - 1])
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex6_illeg_instr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ex6_illeg_instr_offset:ex6_illeg_instr_offset + 2 - 1]),
         .scout(sov[ex6_illeg_instr_offset:ex6_illeg_instr_offset + 2 - 1]),
         .din(ex6_illeg_instr_d),
         .dout(ex6_illeg_instr_q)
      );
      // sequencer latches

      tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) tlb_seq_latch(
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
         .scin(siv[tlb_seq_offset:tlb_seq_offset + 6 - 1]),
         .scout(sov[tlb_seq_offset:tlb_seq_offset + 6 - 1]),
         .din(tlb_seq_d[0:`TLB_SEQ_WIDTH - 1]),
         .dout(tlb_seq_q[0:`TLB_SEQ_WIDTH - 1])
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) derat_taken_latch(
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
         .scin(siv[derat_taken_offset]),
         .scout(sov[derat_taken_offset]),
         .din(derat_taken_d),
         .dout(derat_taken_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xucr4_mmu_mchk_latch(
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
         .scin(siv[xucr4_mmu_mchk_offset]),
         .scout(sov[xucr4_mmu_mchk_offset]),
         .din(xu_mm_xucr4_mmu_mchk),
         .dout(xu_mm_xucr4_mmu_mchk_q)
      );

      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) snoop_val_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_snoop_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[snoop_val_offset:snoop_val_offset + 2 - 1]),
         .scout(sov[snoop_val_offset:snoop_val_offset + 2 - 1]),
         .din(snoop_val_d),
         .dout(snoop_val_q)
      );

      tri_rlmreg_p #(.WIDTH(35), .INIT(0), .NEEDS_SRESET(1)) snoop_attr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_snoop_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[snoop_attr_offset:snoop_attr_offset + 35 - 1]),
         .scout(sov[snoop_attr_offset:snoop_attr_offset + 35 - 1]),
         .din(snoop_attr_d),
         .dout(snoop_attr_q)
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) snoop_vpn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_snoop_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[snoop_vpn_offset:snoop_vpn_offset + `EPN_WIDTH - 1]),
         .scout(sov[snoop_vpn_offset:snoop_vpn_offset + `EPN_WIDTH - 1]),
         .din(snoop_vpn_d),
         .dout(snoop_vpn_q)
      );

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_clr_resv_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_clr_resv_offset:tlb_clr_resv_offset + `MM_THREADS - 1]),
         .scout(sov[tlb_clr_resv_offset:tlb_clr_resv_offset + `MM_THREADS - 1]),
         .din(tlb_clr_resv_d),
         .dout(tlb_clr_resv_q)
      );

      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_resv_match_vec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv_match_vec_offset:tlb_resv_match_vec_offset + `MM_THREADS - 1]),
         .scout(sov[tlb_resv_match_vec_offset:tlb_resv_match_vec_offset + `MM_THREADS - 1]),
         .din(tlb_resv_match_vec_d),
         .dout(tlb_resv_match_vec_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_resv0_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv0_valid_offset]),
         .scout(sov[tlb_resv0_valid_offset]),
         .din(tlb_resv0_valid_d),
         .dout(tlb_resv0_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_resv0_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv0_epn_offset:tlb_resv0_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[tlb_resv0_epn_offset:tlb_resv0_epn_offset + `EPN_WIDTH - 1]),
         .din(tlb_resv0_epn_d),
         .dout(tlb_resv0_epn_q)
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_resv0_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv0_pid_offset:tlb_resv0_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[tlb_resv0_pid_offset:tlb_resv0_pid_offset + `PID_WIDTH - 1]),
         .din(tlb_resv0_pid_d[0:`PID_WIDTH - 1]),
         .dout(tlb_resv0_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_resv0_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv0_lpid_offset:tlb_resv0_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[tlb_resv0_lpid_offset:tlb_resv0_lpid_offset + `LPID_WIDTH - 1]),
         .din(tlb_resv0_lpid_d[0:`LPID_WIDTH - 1]),
         .dout(tlb_resv0_lpid_q[0:`LPID_WIDTH - 1])
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_resv0_as_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv0_as_offset]),
         .scout(sov[tlb_resv0_as_offset]),
         .din(tlb_resv0_as_d),
         .dout(tlb_resv0_as_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_resv0_gs_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv0_gs_offset]),
         .scout(sov[tlb_resv0_gs_offset]),
         .din(tlb_resv0_gs_d),
         .dout(tlb_resv0_gs_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_resv0_ind_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv0_ind_offset]),
         .scout(sov[tlb_resv0_ind_offset]),
         .din(tlb_resv0_ind_d),
         .dout(tlb_resv0_ind_q)
      );

      tri_rlmreg_p #(.WIDTH(`CLASS_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_resv0_class_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 0]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv0_class_offset:tlb_resv0_class_offset + `CLASS_WIDTH - 1]),
         .scout(sov[tlb_resv0_class_offset:tlb_resv0_class_offset + `CLASS_WIDTH - 1]),
         .din(tlb_resv0_class_d[0:`CLASS_WIDTH - 1]),
         .dout(tlb_resv0_class_q[0:`CLASS_WIDTH - 1])
      );

`ifdef MM_THREADS2
      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_resv1_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv1_valid_offset]),
         .scout(sov[tlb_resv1_valid_offset]),
         .din(tlb_resv1_valid_d),
         .dout(tlb_resv1_valid_q)
      );

      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_resv1_epn_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv1_epn_offset:tlb_resv1_epn_offset + `EPN_WIDTH - 1]),
         .scout(sov[tlb_resv1_epn_offset:tlb_resv1_epn_offset + `EPN_WIDTH - 1]),
         .din(tlb_resv1_epn_d),
         .dout(tlb_resv1_epn_q)
      );

      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_resv1_pid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv1_pid_offset:tlb_resv1_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[tlb_resv1_pid_offset:tlb_resv1_pid_offset + `PID_WIDTH - 1]),
         .din(tlb_resv1_pid_d[0:`PID_WIDTH - 1]),
         .dout(tlb_resv1_pid_q[0:`PID_WIDTH - 1])
      );

      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_resv1_lpid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv1_lpid_offset:tlb_resv1_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[tlb_resv1_lpid_offset:tlb_resv1_lpid_offset + `LPID_WIDTH - 1]),
         .din(tlb_resv1_lpid_d[0:`LPID_WIDTH - 1]),
         .dout(tlb_resv1_lpid_q[0:`LPID_WIDTH - 1])
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_resv1_as_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv1_as_offset]),
         .scout(sov[tlb_resv1_as_offset]),
         .din(tlb_resv1_as_d),
         .dout(tlb_resv1_as_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_resv1_gs_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv1_gs_offset]),
         .scout(sov[tlb_resv1_gs_offset]),
         .din(tlb_resv1_gs_d),
         .dout(tlb_resv1_gs_q)
      );

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_resv1_ind_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv1_ind_offset]),
         .scout(sov[tlb_resv1_ind_offset]),
         .din(tlb_resv1_ind_d),
         .dout(tlb_resv1_ind_q)
      );

      tri_rlmreg_p #(.WIDTH(`CLASS_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_resv1_class_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act_q[5 + 1]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[tlb_resv1_class_offset:tlb_resv1_class_offset + `CLASS_WIDTH - 1]),
         .scout(sov[tlb_resv1_class_offset:tlb_resv1_class_offset + `CLASS_WIDTH - 1]),
         .din(tlb_resv1_class_d[0:`CLASS_WIDTH - 1]),
         .dout(tlb_resv1_class_q[0:`CLASS_WIDTH - 1])
      );
`endif

      tri_rlmreg_p #(.WIDTH(`PTE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ptereload_req_pte_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(ptereload_req_valid),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[ptereload_req_pte_offset:ptereload_req_pte_offset + `PTE_WIDTH - 1]),
         .scout(sov[ptereload_req_pte_offset:ptereload_req_pte_offset + `PTE_WIDTH - 1]),
         .din(ptereload_req_pte_d),
         .dout(ptereload_req_pte_q)
      );
      // power clock gating latches

      tri_rlmreg_p #(.WIDTH(34), .INIT(0), .NEEDS_SRESET(1)) tlb_delayed_act_latch(
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
         .scin(siv[tlb_delayed_act_offset:tlb_delayed_act_offset + 34 - 1]),
         .scout(sov[tlb_delayed_act_offset:tlb_delayed_act_offset + 34 - 1]),
         .din(tlb_delayed_act_d),
         .dout(tlb_delayed_act_q)
      );
      // spare latches

      tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) tlb_ctl_spare_latch(
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
         .scin(siv[tlb_ctl_spare_offset:tlb_ctl_spare_offset + 32 - 1]),
         .scout(sov[tlb_ctl_spare_offset:tlb_ctl_spare_offset + 32 - 1]),
         .din(tlb_ctl_spare_q),
         .dout(tlb_ctl_spare_q)
      );

      // non-scannable timing latches
      tri_regk #(.WIDTH(11), .INIT(0), .NEEDS_SRESET(0)) tlb_resv0_tag1_match_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(xu_mm_ccr2_notlb_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_nsl_force),
         .d_mode(lcb_d_mode_dc),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .thold_b(pc_func_slp_nsl_thold_0_b),
         .scin(tri_regk_unused_scan[0:10]),
         .scout(tri_regk_unused_scan[0:10]),
         .din( {tlb_resv0_tag0_lpid_match, tlb_resv0_tag0_pid_match, tlb_resv0_tag0_as_snoop_match, tlb_resv0_tag0_gs_snoop_match,
                  tlb_resv0_tag0_as_tlbwe_match, tlb_resv0_tag0_gs_tlbwe_match, tlb_resv0_tag0_ind_match,
                   tlb_resv0_tag0_epn_loc_match, tlb_resv0_tag0_epn_glob_match,
                     tlb_resv0_tag0_class_match, tlb_seq_snoop_resv} ),
         .dout( {tlb_resv0_tag1_lpid_match, tlb_resv0_tag1_pid_match, tlb_resv0_tag1_as_snoop_match, tlb_resv0_tag1_gs_snoop_match,
                    tlb_resv0_tag1_as_tlbwe_match, tlb_resv0_tag1_gs_tlbwe_match, tlb_resv0_tag1_ind_match,
                     tlb_resv0_tag1_epn_loc_match, tlb_resv0_tag1_epn_glob_match,
                       tlb_resv0_tag1_class_match, tlb_seq_snoop_resv_q[0]} )
      );

`ifdef MM_THREADS2
      tri_regk #(.WIDTH(11), .INIT(0), .NEEDS_SRESET(0)) tlb_resv1_tag1_match_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(xu_mm_ccr2_notlb_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_nsl_force),
         .d_mode(lcb_d_mode_dc),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .thold_b(pc_func_slp_nsl_thold_0_b),
         .scin(tri_regk_unused_scan[11:21]),
         .scout(tri_regk_unused_scan[11:21]),
         .din( {tlb_resv1_tag0_lpid_match, tlb_resv1_tag0_pid_match, tlb_resv1_tag0_as_snoop_match, tlb_resv1_tag0_gs_snoop_match,
                  tlb_resv1_tag0_as_tlbwe_match, tlb_resv1_tag0_gs_tlbwe_match, tlb_resv1_tag0_ind_match,
                   tlb_resv1_tag0_epn_loc_match, tlb_resv1_tag0_epn_glob_match,
                     tlb_resv1_tag0_class_match, tlb_seq_snoop_resv} ),
         .dout( {tlb_resv1_tag1_lpid_match, tlb_resv1_tag1_pid_match, tlb_resv1_tag1_as_snoop_match, tlb_resv1_tag1_gs_snoop_match,
                    tlb_resv1_tag1_as_tlbwe_match, tlb_resv1_tag1_gs_tlbwe_match, tlb_resv1_tag1_ind_match,
                     tlb_resv1_tag1_epn_loc_match, tlb_resv1_tag1_epn_glob_match,
                       tlb_resv1_tag1_class_match, tlb_seq_snoop_resv_q[1]} )
      );
`endif

      //------------------------------------------------
      // thold/sg latches
      //------------------------------------------------

      tri_plat #(.WIDTH(5)) perv_2to1_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ccflush_dc),
         .din( {pc_func_sl_thold_2, pc_func_slp_sl_thold_2, pc_func_slp_nsl_thold_2, pc_sg_2, pc_fce_2} ),
         .q( {pc_func_sl_thold_1, pc_func_slp_sl_thold_1, pc_func_slp_nsl_thold_1, pc_sg_1, pc_fce_1} )
      );

      tri_plat #(.WIDTH(5)) perv_1to0_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ccflush_dc),
         .din( {pc_func_sl_thold_1, pc_func_slp_sl_thold_1, pc_func_slp_nsl_thold_1, pc_sg_1, pc_fce_1} ),
         .q( {pc_func_sl_thold_0, pc_func_slp_sl_thold_0, pc_func_slp_nsl_thold_0, pc_sg_0, pc_fce_0} )
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

      tri_lcbor  perv_nsl_lcbor(
         .clkoff_b(lcb_clkoff_dc_b),
         .thold(pc_func_slp_nsl_thold_0),
         .sg(pc_fce_0),
         .act_dis(tidn),
         .force_t(pc_func_slp_nsl_force),
         .thold_b(pc_func_slp_nsl_thold_0_b)
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
