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
//* TITLE: Performance event mux
//*
//* NAME: mmq_perf.v
//*
//*********************************************************************

`timescale 1 ns / 1 ns

`include "tri_a2o.vh"
`include "mmu_a2o.vh"


module mmq_perf(

   inout                                   vdd,
   inout                                   gnd,
    (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]                 nclk,


   input                   pc_func_sl_thold_2,
   input                   pc_func_slp_nsl_thold_2,
   input                   pc_sg_2,
   input                   pc_fce_2,
   input                   tc_ac_ccflush_dc,

   input                   lcb_clkoff_dc_b,
   input                   lcb_act_dis_dc,
   input                   lcb_d_mode_dc,
   input                   lcb_delay_lclkr_dc,
   input                   lcb_mpw1_dc_b,
   input                   lcb_mpw2_dc_b,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                   scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                  scan_out,

   input [0:`MM_THREADS-1]  cp_flush_p1,

   input [0:`THDID_WIDTH-1] xu_mm_msr_gs,
   input [0:`THDID_WIDTH-1] xu_mm_msr_pr,
   input                    xu_mm_ccr2_notlb_b,

   // count event inputs
   input [0:`THDID_WIDTH-1] lq_mm_perf_dtlb,
   input [0:`THDID_WIDTH-1] iu_mm_perf_itlb,
   input                    lq_mm_derat_req_nonspec,
   input                    iu_mm_ierat_req_nonspec,

   input [0:9]             tlb_cmp_perf_event_t0,
   input [0:9]             tlb_cmp_perf_event_t1,
   input [0:1]             tlb_cmp_perf_state,		// gs & pr

   input                   tlb_cmp_perf_miss_direct,
   input                   tlb_cmp_perf_hit_direct,
   input                   tlb_cmp_perf_hit_indirect,
   input                   tlb_cmp_perf_hit_first_page,
   input                   tlb_cmp_perf_ptereload,
   input                   tlb_cmp_perf_ptereload_noexcep,
   input                   tlb_cmp_perf_lrat_request,
   input                   tlb_cmp_perf_lrat_miss,
   input                   tlb_cmp_perf_pt_fault,
   input                   tlb_cmp_perf_pt_inelig,
   input                   tlb_ctl_perf_tlbwec_resv,
   input                   tlb_ctl_perf_tlbwec_noresv,

   input [0:`THDID_WIDTH-1] derat_req0_thdid,
   input                   derat_req0_valid,
   input                   derat_req0_nonspec,
   input [0:`THDID_WIDTH-1] derat_req1_thdid,
   input                   derat_req1_valid,
   input                   derat_req1_nonspec,
   input [0:`THDID_WIDTH-1] derat_req2_thdid,
   input                   derat_req2_valid,
   input                   derat_req2_nonspec,
   input [0:`THDID_WIDTH-1] derat_req3_thdid,
   input                   derat_req3_valid,
   input                   derat_req3_nonspec,

   input [0:`THDID_WIDTH-1] ierat_req0_thdid,
   input                   ierat_req0_valid,
   input                   ierat_req0_nonspec,
   input [0:`THDID_WIDTH-1] ierat_req1_thdid,
   input                   ierat_req1_valid,
   input                   ierat_req1_nonspec,
   input [0:`THDID_WIDTH-1] ierat_req2_thdid,
   input                   ierat_req2_valid,
   input                   ierat_req2_nonspec,
   input [0:`THDID_WIDTH-1] ierat_req3_thdid,
   input                   ierat_req3_valid,
   input                   ierat_req3_nonspec,

   input                   ierat_req_taken,
   input                   derat_req_taken,

   input [0:`THDID_WIDTH-1] tlb_tag0_thdid,
   input [0:1]              tlb_tag0_type,		// derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
   input                    tlb_tag0_nonspec,
   input                    tlb_tag4_nonspec,
   input                    tlb_seq_idle,

   input                   inval_perf_tlbilx,
   input                   inval_perf_tlbivax,
   input                   inval_perf_tlbivax_snoop,
   input                   inval_perf_tlb_flush,

   input                   htw_req0_valid,
   input [0:`THDID_WIDTH-1] htw_req0_thdid,
   input [0:1]             htw_req0_type,
   input                   htw_req1_valid,
   input [0:`THDID_WIDTH-1] htw_req1_thdid,
   input [0:1]             htw_req1_type,
   input                   htw_req2_valid,
   input [0:`THDID_WIDTH-1] htw_req2_thdid,
   input [0:1]             htw_req2_type,
   input                   htw_req3_valid,
   input [0:`THDID_WIDTH-1] htw_req3_thdid,
   input [0:1]             htw_req3_type,

`ifdef WAIT_UPDATES
   input [0:`MM_THREADS+5-1]           cp_mm_perf_except_taken_q,
   // 0:1 - thdid/val
   // 2   - I=0/D=1
   // 3   - TLB miss
   // 4   - Storage int (TLBI/PTfault)
   // 5   - LRAT miss
   // 6   - Mcheck
`endif

   // control inputs
   input [0:`MESR1_WIDTH*`THREADS-1]    mmq_spr_event_mux_ctrls,
   input [0:2]                pc_mm_event_count_mode,		// 0=count events in problem state,1=sup,2=hypv
   input                      rp_mm_event_bus_enable_q,		// act for perf related latches from repower

   input  [0:`PERF_EVENT_WIDTH*`THREADS-1]       mm_event_bus_in,
   output [0:`PERF_EVENT_WIDTH*`THREADS-1]       mm_event_bus_out

);


      parameter               rp_mm_event_bus_enable_offset = 0;
      parameter               mmq_spr_event_mux_ctrls_offset = rp_mm_event_bus_enable_offset + 1;
      parameter               pc_mm_event_count_mode_offset = mmq_spr_event_mux_ctrls_offset + `MESR1_WIDTH*`THREADS;
      parameter               xu_mm_msr_gs_offset = pc_mm_event_count_mode_offset + 3;
      parameter               xu_mm_msr_pr_offset = xu_mm_msr_gs_offset + `THDID_WIDTH;
      parameter               event_bus_out_offset = xu_mm_msr_pr_offset + `THDID_WIDTH;
      parameter               scan_right = event_bus_out_offset + `PERF_EVENT_WIDTH*`THREADS - 1;

      wire [0:`PERF_EVENT_WIDTH*`THREADS-1]     event_bus_out_d, event_bus_out_q;

      wire                                rp_mm_event_bus_enable_int_q;
      wire [0:`MESR1_WIDTH*`THREADS-1]    mmq_spr_event_mux_ctrls_q;
      wire [0:2]                          pc_mm_event_count_mode_q;		// 0=count events in problem state,1=sup,2=hypv

      wire [0:23]             mm_perf_event_t0_d, mm_perf_event_t0_q;                   // t0 threadwise events
      wire [0:23]             mm_perf_event_t1_d, mm_perf_event_t1_q;                   // t1 threadwise events
      wire [0:31]             mm_perf_event_core_level_d, mm_perf_event_core_level_q;   // thread independent events

      wire [0:`THDID_WIDTH-1]  xu_mm_msr_gs_q;
      wire [0:`THDID_WIDTH-1]  xu_mm_msr_pr_q;
      wire [0:`THDID_WIDTH]    event_en;

      wire [0:`PERF_MUX_WIDTH-1]                     unit_t0_events_in;
`ifndef THREADS1
      wire [0:`PERF_MUX_WIDTH-1]                     unit_t1_events_in;
`endif

      wire [0:scan_right]     siv;
      wire [0:scan_right]     sov;

      wire                    tidn;
      wire                    tiup;

      wire                    pc_func_sl_thold_1;
      wire                    pc_func_sl_thold_0;
      wire                    pc_func_sl_thold_0_b;
      wire                    pc_func_slp_nsl_thold_1;
      wire                    pc_func_slp_nsl_thold_0;
      wire                    pc_func_slp_nsl_thold_0_b;
      wire                    pc_func_slp_nsl_force;
      wire                    pc_sg_1;
      wire                    pc_sg_0;
      wire                    pc_fce_1;
      wire                    pc_fce_0;
      wire                    force_t;

      wire [0:79]     tri_regk_unused_scan;

      //---------------------------------------------------------------------
      // Logic
      //---------------------------------------------------------------------

      assign tidn = 1'b0;
      assign tiup = 1'b1;

      assign event_en[0:3] = (xu_mm_msr_pr_q[0:3] & {4{pc_mm_event_count_mode_q[0]}}) |
                               // User problem state
                               ((~xu_mm_msr_pr_q[0:3]) & xu_mm_msr_gs_q[0:3] & {4{pc_mm_event_count_mode_q[1]}}) |
                               // Guest Supervisor
                               ((~xu_mm_msr_pr_q[0:3]) & (~xu_mm_msr_gs_q[0:3]) & {4{pc_mm_event_count_mode_q[2]}});
                               // Hypervisor

      //tlb_cmp_perf_state: 0 =gs, 1=pr
      assign event_en[4] = (tlb_cmp_perf_state[1] & pc_mm_event_count_mode_q[0]) |
                             // User problem state
                             (tlb_cmp_perf_state[0] & (~tlb_cmp_perf_state[1]) & pc_mm_event_count_mode_q[1]) |
                             // Guest Supervisor
                             ((~tlb_cmp_perf_state[0]) & (~tlb_cmp_perf_state[1]) & pc_mm_event_count_mode_q[2]);
                             // Hypervisor

      //--------------------------------------------------
      // t* threadwise event list
      //--------------------------------------------------
      // 0    TLB hit direct entry (instr.)     (ind=0 entry hit for fetch)
      // 1    TLB miss direct entry (instr.)    (ind=0 entry missed for fetch)
      // 2    TLB miss indirect entry (instr.)  (ind=1 entry missed for fetch, results in i-tlb exception)
      // 3    H/W tablewalk hit (instr.)        (ptereload with PTE.V=1 for fetch)
      // 4    H/W tablewalk miss (instr.)       (ptereload with PTE.V=0 for fetch, results in PT fault exception -> isi)
      // 5    TLB hit direct entry (data)       (ind=0 entry hit for load/store/cache op)
      // 6    TLB miss direct entry (data)      (ind=0 entry miss for load/store/cache op)
      // 7    TLB miss indirect entry (data)    (ind=1 entry missed for load/store/cache op, results in d-tlb exception)
      // 8    H/W tablewalk hit (data)          (ptereload with PTE.V=1 for load/store/cache op)
      // 9    H/W tablewalk miss (data)         (ptereload with PTE.V=0 for load/store/cache op, results in PT fault exception -> dsi)
      // 10   IERAT miss (or latency), edge (or level)    (total ierat misses or latency)
      // 11   DERAT miss (or latency), edge (or level)    (total derat misses or latency)

      // 12   TLB hit direct entry (instr.)     (ind=0 entry hit for NONSPECULATIVE fetch)
      // 13   TLB miss direct entry (instr.)    (ind=0 entry missed for NONSPECULATIVE fetch)
      // 14   TLB hit direct entry (data)       (ind=0 entry hit for NONSPECULATIVE load/store/cache op)
      // 15   TLB miss direct entry (data)      (ind=0 entry miss for NONSPECULATIVE load/store/cache op)
      // 16   IERAT miss (or latency), edge (or level)    (total NONSPECULATIVE ierat misses or latency)
      // 17   DERAT miss (or latency), edge (or level)    (total NONSPECULATIVE derat misses or latency)

      // 18   TLB hit direct entry (instr.)     (ind=0 entry hit for SPECULATIVE fetch)
      // 19   TLB miss direct entry (instr.)    (ind=0 entry missed for SPECULATIVE fetch)
      // 20   TLB hit direct entry (data)       (ind=0 entry hit for SPECULATIVE load/store/cache op)
      // 21   TLB miss direct entry (data)      (ind=0 entry miss for SPECULATIVE load/store/cache op)
      // 22   IERAT miss (or latency), edge (or level)    (total SPECULATIVE ierat misses or latency)
      // 23   DERAT miss (or latency), edge (or level)    (total SPECULATIVE derat misses or latency)

      //--------------------------------------------------
      // core single event list
      //--------------------------------------------------
      // 0   IERAT miss total (part of direct entry search total)
      // 1   DERAT miss total (part of direct entry search total)
      // 2   TLB miss direct entry total (total TLB ind=0 misses)
      // 3   TLB hit direct entry first page size
      //--------------------------------------------------
      // 4   TLB indirect entry hits total (=page table searches)
      // 5   H/W tablewalk successful installs total (with no PTfault, TLB ineligible, or LRAT miss)
      // 6   LRAT translation request total (for GS=1 tlbwe and ptereload)
      // 7   LRAT misses total (for GS=1 tlbwe and ptereload)
      //--------------------------------------------------
      // 8   Page table faults total (PTE.V=0 for ptereload, resulting in isi/dsi)
      // 9   TLB ineligible total (all TLB ways are iprot=1 for ptereloads, resulting in isi/dsi)
      // 10  tlbwe conditional failed total (total tlbwe WQ=01 with no reservation match)
      // 11  tlbwe conditional success total (total tlbwe WQ=01 with reservation match)
      //--------------------------------------------------
      // 12  tlbilx local invalidations sourced total (sourced tlbilx on this core total)
      // 13  tlbivax invalidations sourced total (sourced tlbivax on this core total)
      // 14  tlbivax snoops total (total tlbivax snoops received from bus, local bit = don't care)
      // 15  TLB flush requests total (TLB requested flushes due to TLB busy or instruction hazards)
      //--------------------------------------------------
      // 16  IERAT NONSPECULATIVE miss total (part of direct entry search total)
      // 17  DERAT NONSPECULATIVE miss total (part of direct entry search total)
      // 18  TLB NONSPECULATIVE miss direct entry total (total TLB ind=0 misses)
      // 19  TLB NONSPECULATIVE hit direct entry first page size
      //--------------------------------------------------
      // 20  IERAT SPECULATIVE miss total (part of direct entry search total)
      // 21  DERAT SPECULATIVE miss total (part of direct entry search total)
      // 22  TLB SPECULATIVE miss direct entry total (total TLB ind=0 misses)
      // 23  TLB SPECULATIVE hit direct entry first page size
      //--------------------------------------------------
      // 24  ERAT miss total (TLB direct entry search total for both I and D sides)
      // 25  ERAT NONSPECULATIVE miss total (TLB direct entry nonspeculative search total for both I and D sides)
      // 26  ERAT SPECULATIVE miss total (TLB direct entry speculative search total for both I and D sides)
      // 27  TLB hit direct entry total (total TLB ind=0 hits for both I and D sides)
      // 28  TLB NONSPECULATIVE hit direct entry total (total TLB ind=0 nonspeculative hits for both I and D sides)
      // 29  TLB SPECULATIVE hit direct entry total (total TLB ind=0 speculative hits for both I and D sides)
      // 30  PTE reload attempts total (with valid htw-reservation, no duplicate set, and pt=1)
      // 31  Raw Total ERAT misses, either mode


      //--------------------------------------------------
      // t* threadwise event list
      //--------------------------------------------------
      // 0    TLB hit direct entry (instr.)     (ind=0 entry hit for fetch)
      // 1    TLB miss direct entry (instr.)    (ind=0 entry missed for fetch)
      // 2    TLB miss indirect entry (instr.)  (ind=1 entry missed for fetch, results in i-tlb exception)
      // 3    H/W tablewalk hit (instr.)        (ptereload with PTE.V=1 for fetch)
      // 4    H/W tablewalk miss (instr.)       (ptereload with PTE.V=0 for fetch, results in PT fault exception -> isi)
      // 5    TLB hit direct entry (data)       (ind=0 entry hit for load/store/cache op)
      // 6    TLB miss direct entry (data)      (ind=0 entry miss for load/store/cache op)
      // 7    TLB miss indirect entry (data)    (ind=1 entry missed for load/store/cache op, results in d-tlb exception)
      // 8    H/W tablewalk hit (data)          (ptereload with PTE.V=1 for load/store/cache op)
      // 9    H/W tablewalk miss (data)         (ptereload with PTE.V=0 for load/store/cache op, results in PT fault exception -> dsi)
      assign mm_perf_event_t0_d[0:9] = tlb_cmp_perf_event_t0[0:9] & {10{event_en[0]}};

      // 10   IERAT miss (or latency), edge (or level)    (total ierat misses or latency)
      // type: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      assign mm_perf_event_t0_d[10] = (((ierat_req0_valid & ierat_req0_thdid[0]) |
                                          (ierat_req1_valid & ierat_req1_thdid[0]) |
                                          (ierat_req2_valid & ierat_req2_thdid[0]) |
                                          (ierat_req3_valid & ierat_req3_thdid[0]) |
                                     // ierat nonspec miss request
                                          ((~tlb_seq_idle) & tlb_tag0_type[1] & tlb_tag0_thdid[0]) |
                                     // searching tlb for direct entry, or ptereload of instr
                                          (htw_req0_valid & htw_req0_type[1] & htw_req0_thdid[0]) |
                                          (htw_req1_valid & htw_req1_type[1] & htw_req1_thdid[0]) |
                                          (htw_req2_valid & htw_req2_type[1] & htw_req2_thdid[0]) |
                                          (htw_req3_valid & htw_req3_type[1] & htw_req3_thdid[0])) & xu_mm_ccr2_notlb_b) |
                                     // htw servicing miss of instr
                                          (iu_mm_perf_itlb[0] & (~xu_mm_ccr2_notlb_b));

      // 11   DERAT miss (or latency), edge (or level)    (total derat misses or latency)
      // type: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      assign mm_perf_event_t0_d[11] = (((derat_req0_valid & derat_req0_thdid[0]) |
                                          (derat_req1_valid & derat_req1_thdid[0]) |
                                          (derat_req2_valid & derat_req2_thdid[0]) |
                                          (derat_req3_valid & derat_req3_thdid[0]) |
                                     // derat nonspec miss request
                                          ((~tlb_seq_idle) & tlb_tag0_type[0] & tlb_tag0_thdid[0]) |
                                     // searching tlb for direct entry, or ptereload of data
                                          (htw_req0_valid & htw_req0_type[0] & htw_req0_thdid[0]) |
                                          (htw_req1_valid & htw_req1_type[0] & htw_req1_thdid[0]) |
                                          (htw_req2_valid & htw_req2_type[0] & htw_req2_thdid[0]) |
                                          (htw_req3_valid & htw_req3_type[0] & htw_req3_thdid[0])) & xu_mm_ccr2_notlb_b) |
                                     // htw servicing miss of data
                                          (lq_mm_perf_dtlb[0] & (~xu_mm_ccr2_notlb_b));

      // 12   TLB hit direct entry (instr.)     (ind=0 entry hit for NONSPECULATIVE fetch)
      assign mm_perf_event_t0_d[12] = tlb_cmp_perf_event_t0[0] & event_en[0] & tlb_tag4_nonspec;

      // 13   TLB miss direct entry (instr.)    (ind=0 entry missed for NONSPECULATIVE fetch)
      assign mm_perf_event_t0_d[13] = tlb_cmp_perf_event_t0[1] & event_en[0] & tlb_tag4_nonspec;

      // 14   TLB hit direct entry (data)       (ind=0 entry hit for NONSPECULATIVE load/store/cache op)
      assign mm_perf_event_t0_d[14] = tlb_cmp_perf_event_t0[5] & event_en[0] & tlb_tag4_nonspec;

      // 15   TLB miss direct entry (data)      (ind=0 entry miss for NONSPECULATIVE load/store/cache op)
      assign mm_perf_event_t0_d[15] = tlb_cmp_perf_event_t0[6] & event_en[0] & tlb_tag4_nonspec;

      // 16   IERAT miss (or latency), edge (or level)    (total NONSPECULATIVE ierat misses or latency)
      // type: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      assign mm_perf_event_t0_d[16] = (((ierat_req0_valid & ierat_req0_nonspec & ierat_req0_thdid[0]) |
                                          (ierat_req1_valid & ierat_req1_nonspec & ierat_req1_thdid[0]) |
                                          (ierat_req2_valid & ierat_req2_nonspec & ierat_req2_thdid[0]) |
                                          (ierat_req3_valid & ierat_req3_nonspec & ierat_req3_thdid[0]) |
                                     // ierat nonspec miss request
                                          ((~tlb_seq_idle) & tlb_tag0_type[1] & tlb_tag0_thdid[0] & tlb_tag0_nonspec) |
                                     // searching tlb for direct entry, or ptereload of instr
                                          (htw_req0_valid & htw_req0_type[1] & htw_req0_thdid[0]) |
                                          (htw_req1_valid & htw_req1_type[1] & htw_req1_thdid[0]) |
                                          (htw_req2_valid & htw_req2_type[1] & htw_req2_thdid[0]) |
                                          (htw_req3_valid & htw_req3_type[1] & htw_req3_thdid[0])) & xu_mm_ccr2_notlb_b) |
                                     // htw servicing miss of instr
                                          (iu_mm_perf_itlb[0] & iu_mm_ierat_req_nonspec & (~xu_mm_ccr2_notlb_b));

      // 17   DERAT miss (or latency), edge (or level)    (total NONSPECULATIVE derat misses or latency)
      // type: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      assign mm_perf_event_t0_d[17] = (((derat_req0_valid & derat_req0_nonspec & derat_req0_thdid[0]) |
                                          (derat_req1_valid & derat_req1_nonspec & derat_req1_thdid[0]) |
                                          (derat_req2_valid & derat_req2_nonspec & derat_req2_thdid[0]) |
                                          (derat_req3_valid & derat_req3_nonspec & derat_req3_thdid[0]) |
                                     // derat nonspec miss request
                                          ((~tlb_seq_idle) & tlb_tag0_type[0] & tlb_tag0_thdid[0] & tlb_tag0_nonspec) |
                                     // searching tlb for direct entry, or ptereload of data
                                          (htw_req0_valid & htw_req0_type[0] & htw_req0_thdid[0]) |
                                          (htw_req1_valid & htw_req1_type[0] & htw_req1_thdid[0]) |
                                          (htw_req2_valid & htw_req2_type[0] & htw_req2_thdid[0]) |
                                          (htw_req3_valid & htw_req3_type[0] & htw_req3_thdid[0])) & xu_mm_ccr2_notlb_b) |
                                     // htw servicing miss of data
                                          (lq_mm_perf_dtlb[0] & lq_mm_derat_req_nonspec & (~xu_mm_ccr2_notlb_b));


      // 18   TLB hit direct entry (instr.)     (ind=0 entry hit for SPECULATIVE fetch)
      assign mm_perf_event_t0_d[18] = tlb_cmp_perf_event_t0[0] & event_en[0] & ~tlb_tag4_nonspec;

      // 19   TLB miss direct entry (instr.)    (ind=0 entry missed for SPECULATIVE fetch)
      assign mm_perf_event_t0_d[19] = tlb_cmp_perf_event_t0[1] & event_en[0] & ~tlb_tag4_nonspec;

      // 20   TLB hit direct entry (data)       (ind=0 entry hit for SPECULATIVE load/store/cache op)
      assign mm_perf_event_t0_d[20] = tlb_cmp_perf_event_t0[5] & event_en[0] & ~tlb_tag4_nonspec;

      // 21   TLB miss direct entry (data)      (ind=0 entry miss for SPECULATIVE load/store/cache op)
      assign mm_perf_event_t0_d[21] = tlb_cmp_perf_event_t0[6] & event_en[0] & ~tlb_tag4_nonspec;

      // 22   IERAT miss (or latency), edge (or level)    (total SPECULATIVE ierat misses or latency)
      // type: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      // NOTE - speculative requests do not envoke h/w tablewalker actions..
      //        ..tablewalker handles only non-speculative requests
      assign mm_perf_event_t0_d[22] = (((ierat_req0_valid & ~ierat_req0_nonspec & ierat_req0_thdid[0]) |
                                          (ierat_req1_valid & ~ierat_req1_nonspec & ierat_req1_thdid[0]) |
                                          (ierat_req2_valid & ~ierat_req2_nonspec & ierat_req2_thdid[0]) |
                                          (ierat_req3_valid & ~ierat_req3_nonspec & ierat_req3_thdid[0]) |
                                     // ierat nonspec miss request
                                          ((~tlb_seq_idle) & tlb_tag0_type[1] & tlb_tag0_thdid[0] & ~tlb_tag0_nonspec)) & xu_mm_ccr2_notlb_b) |
                                     // searching tlb for direct entry, or ptereload of instr
                                          (iu_mm_perf_itlb[0] & (~iu_mm_ierat_req_nonspec) & (~xu_mm_ccr2_notlb_b));

      // 23   DERAT miss (or latency), edge (or level)    (total SPECULATIVE derat misses or latency)
      // type: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      // NOTE - speculative requests do not envoke h/w tablewalker actions..
      //        ..tablewalker handles only non-speculative requests
      assign mm_perf_event_t0_d[23] = (((derat_req0_valid & ~derat_req0_nonspec & derat_req0_thdid[0]) |
                                          (derat_req1_valid & ~derat_req1_nonspec & derat_req1_thdid[0]) |
                                          (derat_req2_valid & ~derat_req2_nonspec & derat_req2_thdid[0]) |
                                          (derat_req3_valid & ~derat_req3_nonspec & derat_req3_thdid[0]) |
                                     // derat nonspec miss request
                                          ((~tlb_seq_idle) & tlb_tag0_type[0] & tlb_tag0_thdid[0] & ~tlb_tag0_nonspec)) & xu_mm_ccr2_notlb_b) |
                                     // searching tlb for direct entry, or ptereload of data
                                          (lq_mm_perf_dtlb[0] & (~lq_mm_derat_req_nonspec) & (~xu_mm_ccr2_notlb_b));


      //--------------------------------------------------
      // t* threadwise event list
      //--------------------------------------------------
      // 0    TLB hit direct entry (instr.)     (ind=0 entry hit for fetch)
      // 1    TLB miss direct entry (instr.)    (ind=0 entry missed for fetch)
      // 2    TLB miss indirect entry (instr.)  (ind=1 entry missed for fetch, results in i-tlb exception)
      // 3    H/W tablewalk hit (instr.)        (ptereload with PTE.V=1 for fetch)
      // 4    H/W tablewalk miss (instr.)       (ptereload with PTE.V=0 for fetch, results in PT fault exception -> isi)
      // 5    TLB hit direct entry (data)       (ind=0 entry hit for load/store/cache op)
      // 6    TLB miss direct entry (data)      (ind=0 entry miss for load/store/cache op)
      // 7    TLB miss indirect entry (data)    (ind=1 entry missed for load/store/cache op, results in d-tlb exception)
      // 8    H/W tablewalk hit (data)          (ptereload with PTE.V=1 for load/store/cache op)
      // 9    H/W tablewalk miss (data)         (ptereload with PTE.V=0 for load/store/cache op, results in PT fault exception -> dsi)
      assign mm_perf_event_t1_d[0:9] = tlb_cmp_perf_event_t1[0:9] & {10{event_en[1]}};

      // 10   IERAT miss (or latency), edge (or level)    (total ierat misses or latency)
      // type: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      assign mm_perf_event_t1_d[10] = (((ierat_req0_valid & ierat_req0_thdid[1]) |
                                          (ierat_req1_valid & ierat_req1_thdid[1]) |
                                          (ierat_req2_valid & ierat_req2_thdid[1]) |
                                          (ierat_req3_valid & ierat_req3_thdid[1]) |
                                    // ierat nonspec miss request
                                          ((~tlb_seq_idle) & tlb_tag0_type[1] & tlb_tag0_thdid[1]) |
                                    // searching tlb for direct entry, or ptereload of instr
                                          (htw_req0_valid & htw_req0_type[1] & htw_req0_thdid[1]) |
                                          (htw_req1_valid & htw_req1_type[1] & htw_req1_thdid[1]) |
                                          (htw_req2_valid & htw_req2_type[1] & htw_req2_thdid[1]) |
                                          (htw_req3_valid & htw_req3_type[1] & htw_req3_thdid[1])) & xu_mm_ccr2_notlb_b) |
                                    // htw servicing miss of instr
                                          (iu_mm_perf_itlb[1] & (~xu_mm_ccr2_notlb_b));

      // 11   DERAT miss (or latency), edge (or level)    (total derat misses or latency)
      // type: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      assign mm_perf_event_t1_d[11] = (((derat_req0_valid & derat_req0_thdid[1]) |
                                          (derat_req1_valid & derat_req1_thdid[1]) |
                                          (derat_req2_valid & derat_req2_thdid[1]) |
                                          (derat_req3_valid & derat_req3_thdid[1]) |
                                    // derat nonspec miss request
                                          ((~tlb_seq_idle) & tlb_tag0_type[0] & tlb_tag0_thdid[1]) |
                                    // searching tlb for direct entry, or ptereload of data
                                          (htw_req0_valid & htw_req0_type[0] & htw_req0_thdid[1]) |
                                          (htw_req1_valid & htw_req1_type[0] & htw_req1_thdid[1]) |
                                          (htw_req2_valid & htw_req2_type[0] & htw_req2_thdid[1]) |
                                          (htw_req3_valid & htw_req3_type[0] & htw_req3_thdid[1])) & xu_mm_ccr2_notlb_b) |
                                   // htw servicing miss of data
                                          (lq_mm_perf_dtlb[1] & (~xu_mm_ccr2_notlb_b));


      // 12   TLB hit direct entry (instr.)     (ind=0 entry hit for NONSPECULATIVE fetch)
      assign mm_perf_event_t1_d[12] = tlb_cmp_perf_event_t1[0] & event_en[1] & tlb_tag4_nonspec;

      // 13   TLB miss direct entry (instr.)    (ind=0 entry missed for NONSPECULATIVE fetch)
      assign mm_perf_event_t1_d[13] = tlb_cmp_perf_event_t1[1] & event_en[1] & tlb_tag4_nonspec;

      // 14   TLB hit direct entry (data)       (ind=0 entry hit for NONSPECULATIVE load/store/cache op)
      assign mm_perf_event_t1_d[14] = tlb_cmp_perf_event_t1[5] & event_en[1] & tlb_tag4_nonspec;

      // 15   TLB miss direct entry (data)      (ind=0 entry miss for NONSPECULATIVE load/store/cache op)
      assign mm_perf_event_t1_d[15] = tlb_cmp_perf_event_t1[6] & event_en[1] & tlb_tag4_nonspec;

      // 16   IERAT miss (or latency), edge (or level)    (total NONSPECULATIVE ierat misses or latency)
      assign mm_perf_event_t1_d[16] = (((ierat_req0_valid & ierat_req0_nonspec & ierat_req0_thdid[1]) |
                                          (ierat_req1_valid & ierat_req1_nonspec & ierat_req1_thdid[1]) |
                                          (ierat_req2_valid & ierat_req2_nonspec & ierat_req2_thdid[1]) |
                                          (ierat_req3_valid & ierat_req3_nonspec & ierat_req3_thdid[1]) |
                                     // ierat nonspec miss request
                                          ((~tlb_seq_idle) & tlb_tag0_type[1] & tlb_tag0_thdid[1] & tlb_tag0_nonspec) |
                                     // searching tlb for direct entry, or ptereload of instr
                                          (htw_req0_valid & htw_req0_type[1] & htw_req0_thdid[1]) |
                                          (htw_req1_valid & htw_req1_type[1] & htw_req1_thdid[1]) |
                                          (htw_req2_valid & htw_req2_type[1] & htw_req2_thdid[1]) |
                                          (htw_req3_valid & htw_req3_type[1] & htw_req3_thdid[1])) & xu_mm_ccr2_notlb_b) |
                                     // htw servicing miss of instr
                                          (iu_mm_perf_itlb[1] & iu_mm_ierat_req_nonspec & (~xu_mm_ccr2_notlb_b));

      // 17   DERAT miss (or latency), edge (or level)    (total NONSPECULATIVE derat misses or latency)
      assign mm_perf_event_t1_d[17] = (((derat_req0_valid & derat_req0_nonspec & derat_req0_thdid[1]) |
                                          (derat_req1_valid & derat_req1_nonspec & derat_req1_thdid[1]) |
                                          (derat_req2_valid & derat_req2_nonspec & derat_req2_thdid[1]) |
                                          (derat_req3_valid & derat_req3_nonspec & derat_req3_thdid[1]) |
                                     // derat nonspec miss request
                                          ((~tlb_seq_idle) & tlb_tag0_type[0] & tlb_tag0_thdid[1] & tlb_tag0_nonspec) |
                                     // searching tlb for direct entry, or ptereload of data
                                          (htw_req0_valid & htw_req0_type[0] & htw_req0_thdid[1]) |
                                          (htw_req1_valid & htw_req1_type[0] & htw_req1_thdid[1]) |
                                          (htw_req2_valid & htw_req2_type[0] & htw_req2_thdid[1]) |
                                          (htw_req3_valid & htw_req3_type[0] & htw_req3_thdid[1])) & xu_mm_ccr2_notlb_b) |
                                     // htw servicing miss of data
                                          (lq_mm_perf_dtlb[1] & lq_mm_derat_req_nonspec & (~xu_mm_ccr2_notlb_b));


      // 18   TLB hit direct entry (instr.)     (ind=0 entry hit for SPECULATIVE fetch)
      assign mm_perf_event_t1_d[18] = tlb_cmp_perf_event_t1[0] & event_en[1] & ~tlb_tag4_nonspec;

      // 19   TLB miss direct entry (instr.)    (ind=0 entry missed for SPECULATIVE fetch)
      assign mm_perf_event_t1_d[19] = tlb_cmp_perf_event_t1[1] & event_en[1] & ~tlb_tag4_nonspec;

      // 20   TLB hit direct entry (data)       (ind=0 entry hit for SPECULATIVE load/store/cache op)
      assign mm_perf_event_t1_d[20] = tlb_cmp_perf_event_t1[5] & event_en[1] & ~tlb_tag4_nonspec;

      // 21   TLB miss direct entry (data)      (ind=0 entry miss for SPECULATIVE load/store/cache op)
      assign mm_perf_event_t1_d[21] = tlb_cmp_perf_event_t1[6] & event_en[1] & ~tlb_tag4_nonspec;

      // 22   IERAT miss (or latency), edge (or level)    (total SPECULATIVE ierat misses or latency)
      // type: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      // NOTE - speculative requests do not envoke h/w tablewalker actions..
      //        ..tablewalker handles only non-speculative requests
      assign mm_perf_event_t1_d[22] = (((ierat_req0_valid & ~ierat_req0_nonspec & ierat_req0_thdid[1]) |
                                          (ierat_req1_valid & ~ierat_req1_nonspec & ierat_req1_thdid[1]) |
                                          (ierat_req2_valid & ~ierat_req2_nonspec & ierat_req2_thdid[1]) |
                                          (ierat_req3_valid & ~ierat_req3_nonspec & ierat_req3_thdid[1]) |
                                     // ierat nonspec miss request
                                          ((~tlb_seq_idle) & tlb_tag0_type[1] & tlb_tag0_thdid[1] & ~tlb_tag0_nonspec)) & xu_mm_ccr2_notlb_b) |
                                     // searching tlb for direct entry, or ptereload of instr
                                          (iu_mm_perf_itlb[1] & (~iu_mm_ierat_req_nonspec) & (~xu_mm_ccr2_notlb_b));

      // 23   DERAT miss (or latency), edge (or level)    (total SPECULATIVE derat misses or latency)
      // type: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      // NOTE - speculative requests do not envoke h/w tablewalker actions..
      //        ..tablewalker handles only non-speculative requests
      assign mm_perf_event_t1_d[23] = (((derat_req0_valid & ~derat_req0_nonspec & derat_req0_thdid[1]) |
                                          (derat_req1_valid & ~derat_req1_nonspec & derat_req1_thdid[1]) |
                                          (derat_req2_valid & ~derat_req2_nonspec & derat_req2_thdid[1]) |
                                          (derat_req3_valid & ~derat_req3_nonspec & derat_req3_thdid[1]) |
                                     // derat nonspec miss request
                                          ((~tlb_seq_idle) & tlb_tag0_type[0] & tlb_tag0_thdid[1] & ~tlb_tag0_nonspec)) & xu_mm_ccr2_notlb_b) |
                                     // searching tlb for direct entry, or ptereload of data
                                          (lq_mm_perf_dtlb[1] & (~lq_mm_derat_req_nonspec) & (~xu_mm_ccr2_notlb_b));



      //--------------------------------------------------
      // core single event list
      //--------------------------------------------------
      // 0   IERAT miss total (part of direct entry search total)
      // 1   DERAT miss total (part of direct entry search total)
      // 2   TLB miss direct entry total (total TLB ind=0 misses)
      // 3   TLB hit direct entry first page size
      //--------------------------------------------------
      // 4   TLB indirect entry hits total (=page table searches)
      // 5   H/W tablewalk successful installs total (with no PTfault, TLB ineligible, or LRAT miss)
      // 6   LRAT translation request total (for GS=1 tlbwe and ptereload)
      // 7   LRAT misses total (for GS=1 tlbwe and ptereload)
      //--------------------------------------------------
      // 8   Page table faults total (PTE.V=0 for ptereload, resulting in isi/dsi)
      // 9   TLB ineligible total (all TLB ways are iprot=1 for ptereloads, resulting in isi/dsi)
      // 10  tlbwe conditional failed total (total tlbwe WQ=01 with no reservation match)
      // 11  tlbwe conditional success total (total tlbwe WQ=01 with reservation match)
      //--------------------------------------------------
      // 12   tlbilx local invalidations sourced total (sourced tlbilx on this core total)
      // 13   tlbivax invalidations sourced total (sourced tlbivax on this core total)
      // 14   tlbivax snoops total (total tlbivax snoops received from bus, local bit = don't care)
      // 15   TLB flush requests total (TLB requested flushes due to TLB busy or instruction hazards)
      //--------------------------------------------------
      // 16  IERAT NONSPECULATIVE miss total (part of direct entry search total)
      // 17  DERAT NONSPECULATIVE miss total (part of direct entry search total)
      // 18  TLB NONSPECULATIVE miss direct entry total (total TLB ind=0 misses)
      // 19  TLB NONSPECULATIVE hit direct entry first page size
      //--------------------------------------------------
      // 20  IERAT SPECULATIVE miss total (part of direct entry search total)
      // 21  DERAT SPECULATIVE miss total (part of direct entry search total)
      // 22  TLB SPECULATIVE miss direct entry total (total TLB ind=0 misses)
      // 23  TLB SPECULATIVE hit direct entry first page size
      //--------------------------------------------------
      // 24  ERAT miss total (TLB direct entry search total for both I and D sides)
      // 25  ERAT NONSPECULATIVE miss total (TLB direct entry nonspeculative search total for both I and D sides)
      // 26  ERAT SPECULATIVE miss total (TLB direct entry speculative search total for both I and D sides)
      // 27  TLB hit direct entry total (total TLB ind=0 hits for both I and D sides)
      // 28  TLB NONSPECULATIVE hit direct entry total (total TLB ind=0 nonspeculative hits for both I and D sides)
      // 29  TLB SPECULATIVE hit direct entry total (total TLB ind=0 speculative hits for both I and D sides)
      // 30  PTE reload attempts total (with valid htw-reservation, no duplicate set, and pt=1)
      // 31  Raw Total ERAT misses, either mode

      // 0    IERAT miss total (part of direct entry search total)
      assign mm_perf_event_core_level_d[0] = (ierat_req_taken & xu_mm_ccr2_notlb_b) |
                                               ( |(iu_mm_perf_itlb) & (~xu_mm_ccr2_notlb_b) );

      // 1    DERAT miss total (part of direct entry search total)
      assign mm_perf_event_core_level_d[1] = (derat_req_taken & xu_mm_ccr2_notlb_b) |
                                               ( |(lq_mm_perf_dtlb) & (~xu_mm_ccr2_notlb_b) );

      // 2    TLB miss direct entry total (total TLB ind=0 misses)
      assign mm_perf_event_core_level_d[2] = tlb_cmp_perf_miss_direct & event_en[4];

      // 3    TLB hit direct entry first page size
      assign mm_perf_event_core_level_d[3] = tlb_cmp_perf_hit_first_page & event_en[4];

      // 4    TLB indirect entry hits total (=page table searches)
      assign mm_perf_event_core_level_d[4] = tlb_cmp_perf_hit_indirect & event_en[4];

      // 5    H/W tablewalk successful installs total (with no PTfault, TLB ineligible, or LRAT miss)
      assign mm_perf_event_core_level_d[5] = tlb_cmp_perf_ptereload_noexcep & event_en[4];

      // 6    LRAT translation request total (for GS=1 tlbwe and ptereload)
      assign mm_perf_event_core_level_d[6] = tlb_cmp_perf_lrat_request & event_en[4];

      // 7    LRAT misses total (for GS=1 tlbwe and ptereload)
      assign mm_perf_event_core_level_d[7] = tlb_cmp_perf_lrat_miss & event_en[4];

      // 8    Page table faults total (PTE.V=0 for ptereload, resulting in isi/dsi)
      assign mm_perf_event_core_level_d[8] = tlb_cmp_perf_pt_fault & event_en[4];

      // 9    TLB ineligible total (all TLB ways are iprot=1 for ptereloads, resulting in isi/dsi)
      assign mm_perf_event_core_level_d[9] = tlb_cmp_perf_pt_inelig & event_en[4];

      // 10   tlbwe conditional failed total (total tlbwe WQ=01 with no reservation match)
      assign mm_perf_event_core_level_d[10] = tlb_ctl_perf_tlbwec_noresv & event_en[4];

      // 11   tlbwe conditional success total (total tlbwe WQ=01 with reservation match)
      assign mm_perf_event_core_level_d[11] = tlb_ctl_perf_tlbwec_resv & event_en[4];

      // 12   tlbilx local invalidations sourced total (sourced tlbilx on this core total)
      assign mm_perf_event_core_level_d[12] = inval_perf_tlbilx;

      // 13   tlbivax invalidations sourced total (sourced tlbivax on this core total)
      assign mm_perf_event_core_level_d[13] = inval_perf_tlbivax;

      // 14   tlbivax snoops total (total tlbivax snoops received from bus, local bit = don't care)
      assign mm_perf_event_core_level_d[14] = inval_perf_tlbivax_snoop;

      // 15   TLB flush requests total (TLB requested flushes due to TLB busy or instruction hazards)
      assign mm_perf_event_core_level_d[15] = inval_perf_tlb_flush;

      //--------------------------------------------------
      // 16  IERAT NONSPECULATIVE miss total (part of direct entry search total)
      assign mm_perf_event_core_level_d[16] = (mm_perf_event_core_level_q[0] & tlb_tag0_nonspec & xu_mm_ccr2_notlb_b) |   // ierat_req_taken, nonspec
                                                ( |(iu_mm_perf_itlb) & iu_mm_ierat_req_nonspec & (~xu_mm_ccr2_notlb_b) );

      // 17  DERAT NONSPECULATIVE miss total (part of direct entry search total)
      assign mm_perf_event_core_level_d[17] = (mm_perf_event_core_level_q[1] & tlb_tag0_nonspec & xu_mm_ccr2_notlb_b) |    // derat_req_taken, nonspec
                                                ( |(lq_mm_perf_dtlb) & lq_mm_derat_req_nonspec & (~xu_mm_ccr2_notlb_b) );

      // 18  TLB NONSPECULATIVE miss direct entry total (total TLB ind=0 misses)
      assign mm_perf_event_core_level_d[18] = tlb_cmp_perf_miss_direct & event_en[4] & tlb_tag4_nonspec;

      // 19  TLB NONSPECULATIVE hit direct entry first page size
      assign mm_perf_event_core_level_d[19] = tlb_cmp_perf_hit_first_page & event_en[4] & tlb_tag4_nonspec;

      //--------------------------------------------------
      // 20  IERAT SPECULATIVE miss total (part of direct entry search total)
      assign mm_perf_event_core_level_d[20] = (mm_perf_event_core_level_q[0] & ~tlb_tag0_nonspec & xu_mm_ccr2_notlb_b) |    // ierat_req_taken, spec
                                                ( |(iu_mm_perf_itlb) & (~iu_mm_ierat_req_nonspec) & (~xu_mm_ccr2_notlb_b) );

      // 21  DERAT SPECULATIVE miss total (part of direct entry search total)
      assign mm_perf_event_core_level_d[21] = (mm_perf_event_core_level_q[1] & ~tlb_tag0_nonspec & xu_mm_ccr2_notlb_b) |    // derat_req_taken, spec
                                                ( |(lq_mm_perf_dtlb) & (~lq_mm_derat_req_nonspec) & (~xu_mm_ccr2_notlb_b) );

      // 22  TLB SPECULATIVE miss direct entry total (total TLB ind=0 misses)
      assign mm_perf_event_core_level_d[22] = tlb_cmp_perf_miss_direct & event_en[4] & ~tlb_tag4_nonspec;

      // 23  TLB SPECULATIVE hit direct entry first page size
      assign mm_perf_event_core_level_d[23] = tlb_cmp_perf_hit_first_page & event_en[4] & ~tlb_tag4_nonspec;

      //--------------------------------------------------
      // 24  ERAT miss total (TLB direct entry search total for both I and D sides)
      assign mm_perf_event_core_level_d[24] = (mm_perf_event_core_level_q[0] | mm_perf_event_core_level_q[1]);  // i/derat_req_taken (tlb mode),
                                                                                                                  //  or raw i/derat misses (erat-only mode)

      // 25  ERAT NONSPECULATIVE miss total (TLB direct entry nonspeculative search total for both I and D sides)
      assign mm_perf_event_core_level_d[25] = ( (mm_perf_event_core_level_q[0] | mm_perf_event_core_level_q[1]) & tlb_tag0_nonspec & xu_mm_ccr2_notlb_b ) |   // nonspec i/derat_req_taken (tlb mode)
                                                ( (mm_perf_event_core_level_q[16] | mm_perf_event_core_level_q[17]) & (~xu_mm_ccr2_notlb_b) );  // raw nonspec i/derat misses (erat-only mode)

      // 26  ERAT SPECULATIVE miss total (TLB direct entry speculative search total for both I and D sides)
      assign mm_perf_event_core_level_d[26] = ( (mm_perf_event_core_level_q[0] | mm_perf_event_core_level_q[1]) & ~tlb_tag0_nonspec & xu_mm_ccr2_notlb_b ) |  // spec i/derat_req_taken (tlb mode)
                                                ( (mm_perf_event_core_level_q[20] | mm_perf_event_core_level_q[21]) & (~xu_mm_ccr2_notlb_b) );  // raw spec i/derat misses (erat-only mode)

      // 27  TLB hit direct entry total (total TLB ind=0 hits for both I and D sides)
      assign mm_perf_event_core_level_d[27] = tlb_cmp_perf_hit_direct & event_en[4];

      // 28  TLB NONSPECULATIVE hit direct entry total (total TLB ind=0 nonspeculative hits for both I and D sides)
      assign mm_perf_event_core_level_d[28] = tlb_cmp_perf_hit_direct & event_en[4] & tlb_tag4_nonspec;

      // 29  TLB SPECULATIVE hit direct entry total (total TLB ind=0 speculative hits for both I and D sides)
      assign mm_perf_event_core_level_d[29] = tlb_cmp_perf_hit_direct & event_en[4] & ~tlb_tag4_nonspec;

      // 30  PTE reload attempts total (with valid htw-reservation, no duplicate set, and pt=1)
      assign mm_perf_event_core_level_d[30] = tlb_cmp_perf_ptereload & event_en[4];

      // 31  Raw Total ERAT misses, either mode
      assign mm_perf_event_core_level_d[31] = ( |(iu_mm_perf_itlb) | |(lq_mm_perf_dtlb) );

      //--------------------------------------------------
      // end of core single event list
      //--------------------------------------------------

      assign unit_t0_events_in = {1'b0, mm_perf_event_t0_q[0:23],
                                 7'b0,
                                 mm_perf_event_core_level_q[0:31]};

     tri_event_mux1t #(.EVENTS_IN(`PERF_MUX_WIDTH), .EVENTS_OUT(4)) event_mux0(
       .vd(vdd),
       .gd(gnd),
       .select_bits(mmq_spr_event_mux_ctrls_q[0:`MESR1_WIDTH - 1]),
       .unit_events_in(unit_t0_events_in[1:63]),
       .event_bus_in(mm_event_bus_in[0:3]),
       .event_bus_out(event_bus_out_d[0:3])
      );

`ifndef THREADS1
      assign unit_t1_events_in = {1'b0, mm_perf_event_t1_q[0:23],
                                 7'b0,
                                 mm_perf_event_core_level_q[0:31]};


     tri_event_mux1t #(.EVENTS_IN(`PERF_MUX_WIDTH), .EVENTS_OUT(4)) event_mux1(
       .vd(vdd),
       .gd(gnd),
       .select_bits(mmq_spr_event_mux_ctrls_q[`MESR1_WIDTH:`MESR1_WIDTH+`MESR2_WIDTH - 1]),
       .unit_events_in(unit_t1_events_in),
       .event_bus_in(mm_event_bus_in[4:7]),
       .event_bus_out(event_bus_out_d[4:7])
      );
`endif

      assign mm_event_bus_out = event_bus_out_q;


      //---------------------------------------------------------------------
      // Latches
      //---------------------------------------------------------------------

      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rp_mm_event_bus_enable_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tiup),
         .thold_b(pc_func_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(force_t),
         .delay_lclkr(lcb_delay_lclkr_dc),
         .mpw1_b(lcb_mpw1_dc_b),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[rp_mm_event_bus_enable_offset]),
         .scout(sov[rp_mm_event_bus_enable_offset]),
         .din(rp_mm_event_bus_enable_q),		// yes, this in the input name
         .dout(rp_mm_event_bus_enable_int_q)		// this is local internal version
      );


      tri_rlmreg_p #(.WIDTH(`MESR1_WIDTH*`THREADS), .INIT(0)) mmq_spr_event_mux_ctrls_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tiup),
         .thold_b(pc_func_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(force_t),
         .delay_lclkr(lcb_delay_lclkr_dc),
         .mpw1_b(lcb_mpw1_dc_b),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[mmq_spr_event_mux_ctrls_offset:mmq_spr_event_mux_ctrls_offset + `MESR1_WIDTH*`THREADS - 1]),
         .scout(sov[mmq_spr_event_mux_ctrls_offset:mmq_spr_event_mux_ctrls_offset + `MESR1_WIDTH*`THREADS - 1]),
         .din(mmq_spr_event_mux_ctrls),
         .dout(mmq_spr_event_mux_ctrls_q)
      );


      tri_rlmreg_p #(.WIDTH(3), .INIT(0)) pc_mm_event_count_mode_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tiup),
         .thold_b(pc_func_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(force_t),
         .delay_lclkr(lcb_delay_lclkr_dc),
         .mpw1_b(lcb_mpw1_dc_b),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[pc_mm_event_count_mode_offset:pc_mm_event_count_mode_offset + 3 - 1]),
         .scout(sov[pc_mm_event_count_mode_offset:pc_mm_event_count_mode_offset + 3 - 1]),
         .din(pc_mm_event_count_mode),
         .dout(pc_mm_event_count_mode_q)
      );


      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0)) xu_mm_msr_gs_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(rp_mm_event_bus_enable_int_q),
         .thold_b(pc_func_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(force_t),
         .delay_lclkr(lcb_delay_lclkr_dc),
         .mpw1_b(lcb_mpw1_dc_b),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[xu_mm_msr_gs_offset:xu_mm_msr_gs_offset + `THDID_WIDTH - 1]),
         .scout(sov[xu_mm_msr_gs_offset:xu_mm_msr_gs_offset + `THDID_WIDTH - 1]),
         .din(xu_mm_msr_gs),
         .dout(xu_mm_msr_gs_q)
      );


      tri_rlmreg_p #(.WIDTH(`THDID_WIDTH), .INIT(0)) xu_mm_msr_pr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(rp_mm_event_bus_enable_int_q),
         .thold_b(pc_func_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(force_t),
         .delay_lclkr(lcb_delay_lclkr_dc),
         .mpw1_b(lcb_mpw1_dc_b),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[xu_mm_msr_pr_offset:xu_mm_msr_pr_offset + `THDID_WIDTH - 1]),
         .scout(sov[xu_mm_msr_pr_offset:xu_mm_msr_pr_offset + `THDID_WIDTH - 1]),
         .din(xu_mm_msr_pr),
         .dout(xu_mm_msr_pr_q)
      );


      tri_rlmreg_p #(.WIDTH(`PERF_EVENT_WIDTH*`THREADS), .INIT(0)) event_bus_out_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(rp_mm_event_bus_enable_int_q),
         .thold_b(pc_func_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(force_t),
         .delay_lclkr(lcb_delay_lclkr_dc),
         .mpw1_b(lcb_mpw1_dc_b),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[event_bus_out_offset:event_bus_out_offset + `PERF_EVENT_WIDTH*`THREADS - 1]),
         .scout(sov[event_bus_out_offset:event_bus_out_offset + `PERF_EVENT_WIDTH*`THREADS - 1]),
         .din(event_bus_out_d),
         .dout(event_bus_out_q)
      );


      tri_regk #(.WIDTH(24), .INIT(0), .NEEDS_SRESET(0)) mm_perf_event_t0_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(rp_mm_event_bus_enable_int_q),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_nsl_force),
         .d_mode(lcb_d_mode_dc),
         .delay_lclkr(lcb_delay_lclkr_dc),
         .mpw1_b(lcb_mpw1_dc_b),
         .mpw2_b(lcb_mpw2_dc_b),
         .thold_b(pc_func_slp_nsl_thold_0_b),
         .scin(tri_regk_unused_scan[0:23]),
         .scout(tri_regk_unused_scan[0:23]),
         .din(mm_perf_event_t0_d),
         .dout(mm_perf_event_t0_q)
      );


      tri_regk #(.WIDTH(24), .INIT(0), .NEEDS_SRESET(0)) mm_perf_event_t1_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(rp_mm_event_bus_enable_int_q),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_nsl_force),
         .d_mode(lcb_d_mode_dc),
         .delay_lclkr(lcb_delay_lclkr_dc),
         .mpw1_b(lcb_mpw1_dc_b),
         .mpw2_b(lcb_mpw2_dc_b),
         .thold_b(pc_func_slp_nsl_thold_0_b),
         .scin(tri_regk_unused_scan[24:47]),
         .scout(tri_regk_unused_scan[24:47]),
         .din(mm_perf_event_t1_d),
         .dout(mm_perf_event_t1_q)
      );


      tri_regk #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(0)) mm_perf_event_core_level_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(rp_mm_event_bus_enable_int_q),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_nsl_force),
         .d_mode(lcb_d_mode_dc),
         .delay_lclkr(lcb_delay_lclkr_dc),
         .mpw1_b(lcb_mpw1_dc_b),
         .mpw2_b(lcb_mpw2_dc_b),
         .thold_b(pc_func_slp_nsl_thold_0_b),
         .scin(tri_regk_unused_scan[48:79]),
         .scout(tri_regk_unused_scan[48:79]),
         .din(mm_perf_event_core_level_d),
         .dout(mm_perf_event_core_level_q)
      );



      //-----------------------------------------------
      // pervasive
      //-----------------------------------------------


      tri_plat #(.WIDTH(4)) perv_2to1_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ac_ccflush_dc),
         .din( {pc_func_sl_thold_2, pc_func_slp_nsl_thold_2, pc_sg_2, pc_fce_2} ),
         .q( {pc_func_sl_thold_1, pc_func_slp_nsl_thold_1, pc_sg_1, pc_fce_1} )
      );


      tri_plat #(.WIDTH(4)) perv_1to0_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ac_ccflush_dc),
         .din( {pc_func_sl_thold_1, pc_func_slp_nsl_thold_1, pc_sg_1, pc_fce_1} ),
         .q( {pc_func_sl_thold_0, pc_func_slp_nsl_thold_0, pc_sg_0, pc_fce_0} )
      );


      tri_lcbor  perv_lcbor(
         .clkoff_b(lcb_clkoff_dc_b),
         .thold(pc_func_sl_thold_0),
         .sg(pc_sg_0),
         .act_dis(lcb_act_dis_dc),
         .force_t(force_t),
         .thold_b(pc_func_sl_thold_0_b)
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
      assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
      assign scan_out = sov[0];


endmodule
