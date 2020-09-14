// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.



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
   
   input [0:`THDID_WIDTH-1] lq_mm_perf_dtlb,		
   input [0:`THDID_WIDTH-1] iu_mm_perf_itlb,		
   input                    lq_mm_derat_req_nonspec,
   input                    iu_mm_ierat_req_nonspec,
   
   input [0:9]             tlb_cmp_perf_event_t0,
   input [0:9]             tlb_cmp_perf_event_t1,
   input [0:1]             tlb_cmp_perf_state,		
   
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
   input [0:1]              tlb_tag0_type,		
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
`endif

   input [0:`MESR1_WIDTH*`THREADS-1]    mmq_spr_event_mux_ctrls,
   input [0:2]                pc_mm_event_count_mode,		
   input                      rp_mm_event_bus_enable_q,		
   
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
      wire [0:2]                          pc_mm_event_count_mode_q;		
      
      wire [0:23]             mm_perf_event_t0_d, mm_perf_event_t0_q;                   
      wire [0:23]             mm_perf_event_t1_d, mm_perf_event_t1_q;                   
      wire [0:31]             mm_perf_event_core_level_d, mm_perf_event_core_level_q;   
      
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
      
      
      assign tidn = 1'b0;
      assign tiup = 1'b1;
      
      assign event_en[0:3] = (xu_mm_msr_pr_q[0:3] & {4{pc_mm_event_count_mode_q[0]}}) | 
                               ((~xu_mm_msr_pr_q[0:3]) & xu_mm_msr_gs_q[0:3] & {4{pc_mm_event_count_mode_q[1]}}) | 
                               ((~xu_mm_msr_pr_q[0:3]) & (~xu_mm_msr_gs_q[0:3]) & {4{pc_mm_event_count_mode_q[2]}}); 
      
      assign event_en[4] = (tlb_cmp_perf_state[1] & pc_mm_event_count_mode_q[0]) | 
                             (tlb_cmp_perf_state[0] & (~tlb_cmp_perf_state[1]) & pc_mm_event_count_mode_q[1]) | 
                             ((~tlb_cmp_perf_state[0]) & (~tlb_cmp_perf_state[1]) & pc_mm_event_count_mode_q[2]);
      

      
      
      
      
      assign mm_perf_event_t0_d[0:9] = tlb_cmp_perf_event_t0[0:9] & {10{event_en[0]}};
      
      assign mm_perf_event_t0_d[10] = (((ierat_req0_valid & ierat_req0_thdid[0]) | 
                                          (ierat_req1_valid & ierat_req1_thdid[0]) | 
                                          (ierat_req2_valid & ierat_req2_thdid[0]) | 
                                          (ierat_req3_valid & ierat_req3_thdid[0]) | 
                                          ((~tlb_seq_idle) & tlb_tag0_type[1] & tlb_tag0_thdid[0]) | 
                                          (htw_req0_valid & htw_req0_type[1] & htw_req0_thdid[0]) | 
                                          (htw_req1_valid & htw_req1_type[1] & htw_req1_thdid[0]) | 
                                          (htw_req2_valid & htw_req2_type[1] & htw_req2_thdid[0]) | 
                                          (htw_req3_valid & htw_req3_type[1] & htw_req3_thdid[0])) & xu_mm_ccr2_notlb_b) | 
                                          (iu_mm_perf_itlb[0] & (~xu_mm_ccr2_notlb_b));
      
      assign mm_perf_event_t0_d[11] = (((derat_req0_valid & derat_req0_thdid[0]) | 
                                          (derat_req1_valid & derat_req1_thdid[0]) | 
                                          (derat_req2_valid & derat_req2_thdid[0]) | 
                                          (derat_req3_valid & derat_req3_thdid[0]) | 
                                          ((~tlb_seq_idle) & tlb_tag0_type[0] & tlb_tag0_thdid[0]) | 
                                          (htw_req0_valid & htw_req0_type[0] & htw_req0_thdid[0]) | 
                                          (htw_req1_valid & htw_req1_type[0] & htw_req1_thdid[0]) | 
                                          (htw_req2_valid & htw_req2_type[0] & htw_req2_thdid[0]) | 
                                          (htw_req3_valid & htw_req3_type[0] & htw_req3_thdid[0])) & xu_mm_ccr2_notlb_b) | 
                                          (lq_mm_perf_dtlb[0] & (~xu_mm_ccr2_notlb_b));
      
      assign mm_perf_event_t0_d[12] = tlb_cmp_perf_event_t0[0] & event_en[0] & tlb_tag4_nonspec;
      
      assign mm_perf_event_t0_d[13] = tlb_cmp_perf_event_t0[1] & event_en[0] & tlb_tag4_nonspec;
      
      assign mm_perf_event_t0_d[14] = tlb_cmp_perf_event_t0[5] & event_en[0] & tlb_tag4_nonspec;
      
      assign mm_perf_event_t0_d[15] = tlb_cmp_perf_event_t0[6] & event_en[0] & tlb_tag4_nonspec;
      
      assign mm_perf_event_t0_d[16] = (((ierat_req0_valid & ierat_req0_nonspec & ierat_req0_thdid[0]) | 
                                          (ierat_req1_valid & ierat_req1_nonspec & ierat_req1_thdid[0]) | 
                                          (ierat_req2_valid & ierat_req2_nonspec & ierat_req2_thdid[0]) | 
                                          (ierat_req3_valid & ierat_req3_nonspec & ierat_req3_thdid[0]) | 
                                          ((~tlb_seq_idle) & tlb_tag0_type[1] & tlb_tag0_thdid[0] & tlb_tag0_nonspec) | 
                                          (htw_req0_valid & htw_req0_type[1] & htw_req0_thdid[0]) | 
                                          (htw_req1_valid & htw_req1_type[1] & htw_req1_thdid[0]) | 
                                          (htw_req2_valid & htw_req2_type[1] & htw_req2_thdid[0]) | 
                                          (htw_req3_valid & htw_req3_type[1] & htw_req3_thdid[0])) & xu_mm_ccr2_notlb_b) | 
                                          (iu_mm_perf_itlb[0] & iu_mm_ierat_req_nonspec & (~xu_mm_ccr2_notlb_b));
      
      assign mm_perf_event_t0_d[17] = (((derat_req0_valid & derat_req0_nonspec & derat_req0_thdid[0]) | 
                                          (derat_req1_valid & derat_req1_nonspec & derat_req1_thdid[0]) | 
                                          (derat_req2_valid & derat_req2_nonspec & derat_req2_thdid[0]) | 
                                          (derat_req3_valid & derat_req3_nonspec & derat_req3_thdid[0]) | 
                                          ((~tlb_seq_idle) & tlb_tag0_type[0] & tlb_tag0_thdid[0] & tlb_tag0_nonspec) | 
                                          (htw_req0_valid & htw_req0_type[0] & htw_req0_thdid[0]) | 
                                          (htw_req1_valid & htw_req1_type[0] & htw_req1_thdid[0]) | 
                                          (htw_req2_valid & htw_req2_type[0] & htw_req2_thdid[0]) | 
                                          (htw_req3_valid & htw_req3_type[0] & htw_req3_thdid[0])) & xu_mm_ccr2_notlb_b) | 
                                          (lq_mm_perf_dtlb[0] & lq_mm_derat_req_nonspec & (~xu_mm_ccr2_notlb_b));
      
      
      assign mm_perf_event_t0_d[18] = tlb_cmp_perf_event_t0[0] & event_en[0] & ~tlb_tag4_nonspec;
      
      assign mm_perf_event_t0_d[19] = tlb_cmp_perf_event_t0[1] & event_en[0] & ~tlb_tag4_nonspec;
      
      assign mm_perf_event_t0_d[20] = tlb_cmp_perf_event_t0[5] & event_en[0] & ~tlb_tag4_nonspec;
      
      assign mm_perf_event_t0_d[21] = tlb_cmp_perf_event_t0[6] & event_en[0] & ~tlb_tag4_nonspec;
      
      assign mm_perf_event_t0_d[22] = (((ierat_req0_valid & ~ierat_req0_nonspec & ierat_req0_thdid[0]) | 
                                          (ierat_req1_valid & ~ierat_req1_nonspec & ierat_req1_thdid[0]) | 
                                          (ierat_req2_valid & ~ierat_req2_nonspec & ierat_req2_thdid[0]) | 
                                          (ierat_req3_valid & ~ierat_req3_nonspec & ierat_req3_thdid[0]) | 
                                          ((~tlb_seq_idle) & tlb_tag0_type[1] & tlb_tag0_thdid[0] & ~tlb_tag0_nonspec)) & xu_mm_ccr2_notlb_b) | 
                                          (iu_mm_perf_itlb[0] & (~iu_mm_ierat_req_nonspec) & (~xu_mm_ccr2_notlb_b));
      
      assign mm_perf_event_t0_d[23] = (((derat_req0_valid & ~derat_req0_nonspec & derat_req0_thdid[0]) | 
                                          (derat_req1_valid & ~derat_req1_nonspec & derat_req1_thdid[0]) | 
                                          (derat_req2_valid & ~derat_req2_nonspec & derat_req2_thdid[0]) | 
                                          (derat_req3_valid & ~derat_req3_nonspec & derat_req3_thdid[0]) | 
                                          ((~tlb_seq_idle) & tlb_tag0_type[0] & tlb_tag0_thdid[0] & ~tlb_tag0_nonspec)) & xu_mm_ccr2_notlb_b) | 
                                          (lq_mm_perf_dtlb[0] & (~lq_mm_derat_req_nonspec) & (~xu_mm_ccr2_notlb_b));
      

      assign mm_perf_event_t1_d[0:9] = tlb_cmp_perf_event_t1[0:9] & {10{event_en[1]}};
      
      assign mm_perf_event_t1_d[10] = (((ierat_req0_valid & ierat_req0_thdid[1]) | 
                                          (ierat_req1_valid & ierat_req1_thdid[1]) | 
                                          (ierat_req2_valid & ierat_req2_thdid[1]) | 
                                          (ierat_req3_valid & ierat_req3_thdid[1]) | 
                                          ((~tlb_seq_idle) & tlb_tag0_type[1] & tlb_tag0_thdid[1]) | 
                                          (htw_req0_valid & htw_req0_type[1] & htw_req0_thdid[1]) | 
                                          (htw_req1_valid & htw_req1_type[1] & htw_req1_thdid[1]) | 
                                          (htw_req2_valid & htw_req2_type[1] & htw_req2_thdid[1]) | 
                                          (htw_req3_valid & htw_req3_type[1] & htw_req3_thdid[1])) & xu_mm_ccr2_notlb_b) | 
                                          (iu_mm_perf_itlb[1] & (~xu_mm_ccr2_notlb_b));
      
      assign mm_perf_event_t1_d[11] = (((derat_req0_valid & derat_req0_thdid[1]) | 
                                          (derat_req1_valid & derat_req1_thdid[1]) | 
                                          (derat_req2_valid & derat_req2_thdid[1]) | 
                                          (derat_req3_valid & derat_req3_thdid[1]) | 
                                          ((~tlb_seq_idle) & tlb_tag0_type[0] & tlb_tag0_thdid[1]) | 
                                          (htw_req0_valid & htw_req0_type[0] & htw_req0_thdid[1]) | 
                                          (htw_req1_valid & htw_req1_type[0] & htw_req1_thdid[1]) | 
                                          (htw_req2_valid & htw_req2_type[0] & htw_req2_thdid[1]) | 
                                          (htw_req3_valid & htw_req3_type[0] & htw_req3_thdid[1])) & xu_mm_ccr2_notlb_b) | 
                                          (lq_mm_perf_dtlb[1] & (~xu_mm_ccr2_notlb_b));
      

      assign mm_perf_event_t1_d[12] = tlb_cmp_perf_event_t1[0] & event_en[1] & tlb_tag4_nonspec;
      
      assign mm_perf_event_t1_d[13] = tlb_cmp_perf_event_t1[1] & event_en[1] & tlb_tag4_nonspec;
      
      assign mm_perf_event_t1_d[14] = tlb_cmp_perf_event_t1[5] & event_en[1] & tlb_tag4_nonspec;
      
      assign mm_perf_event_t1_d[15] = tlb_cmp_perf_event_t1[6] & event_en[1] & tlb_tag4_nonspec;
      
      assign mm_perf_event_t1_d[16] = (((ierat_req0_valid & ierat_req0_nonspec & ierat_req0_thdid[1]) | 
                                          (ierat_req1_valid & ierat_req1_nonspec & ierat_req1_thdid[1]) | 
                                          (ierat_req2_valid & ierat_req2_nonspec & ierat_req2_thdid[1]) | 
                                          (ierat_req3_valid & ierat_req3_nonspec & ierat_req3_thdid[1]) | 
                                          ((~tlb_seq_idle) & tlb_tag0_type[1] & tlb_tag0_thdid[1] & tlb_tag0_nonspec) | 
                                          (htw_req0_valid & htw_req0_type[1] & htw_req0_thdid[1]) | 
                                          (htw_req1_valid & htw_req1_type[1] & htw_req1_thdid[1]) | 
                                          (htw_req2_valid & htw_req2_type[1] & htw_req2_thdid[1]) | 
                                          (htw_req3_valid & htw_req3_type[1] & htw_req3_thdid[1])) & xu_mm_ccr2_notlb_b) | 
                                          (iu_mm_perf_itlb[1] & iu_mm_ierat_req_nonspec & (~xu_mm_ccr2_notlb_b));
      
      assign mm_perf_event_t1_d[17] = (((derat_req0_valid & derat_req0_nonspec & derat_req0_thdid[1]) | 
                                          (derat_req1_valid & derat_req1_nonspec & derat_req1_thdid[1]) | 
                                          (derat_req2_valid & derat_req2_nonspec & derat_req2_thdid[1]) | 
                                          (derat_req3_valid & derat_req3_nonspec & derat_req3_thdid[1]) | 
                                          ((~tlb_seq_idle) & tlb_tag0_type[0] & tlb_tag0_thdid[1] & tlb_tag0_nonspec) | 
                                          (htw_req0_valid & htw_req0_type[0] & htw_req0_thdid[1]) | 
                                          (htw_req1_valid & htw_req1_type[0] & htw_req1_thdid[1]) | 
                                          (htw_req2_valid & htw_req2_type[0] & htw_req2_thdid[1]) | 
                                          (htw_req3_valid & htw_req3_type[0] & htw_req3_thdid[1])) & xu_mm_ccr2_notlb_b) | 
                                          (lq_mm_perf_dtlb[1] & lq_mm_derat_req_nonspec & (~xu_mm_ccr2_notlb_b));
      
      
      assign mm_perf_event_t1_d[18] = tlb_cmp_perf_event_t1[0] & event_en[1] & ~tlb_tag4_nonspec;
      
      assign mm_perf_event_t1_d[19] = tlb_cmp_perf_event_t1[1] & event_en[1] & ~tlb_tag4_nonspec;
      
      assign mm_perf_event_t1_d[20] = tlb_cmp_perf_event_t1[5] & event_en[1] & ~tlb_tag4_nonspec;
      
      assign mm_perf_event_t1_d[21] = tlb_cmp_perf_event_t1[6] & event_en[1] & ~tlb_tag4_nonspec;
      
      assign mm_perf_event_t1_d[22] = (((ierat_req0_valid & ~ierat_req0_nonspec & ierat_req0_thdid[1]) | 
                                          (ierat_req1_valid & ~ierat_req1_nonspec & ierat_req1_thdid[1]) | 
                                          (ierat_req2_valid & ~ierat_req2_nonspec & ierat_req2_thdid[1]) | 
                                          (ierat_req3_valid & ~ierat_req3_nonspec & ierat_req3_thdid[1]) | 
                                          ((~tlb_seq_idle) & tlb_tag0_type[1] & tlb_tag0_thdid[1] & ~tlb_tag0_nonspec)) & xu_mm_ccr2_notlb_b) | 
                                          (iu_mm_perf_itlb[1] & (~iu_mm_ierat_req_nonspec) & (~xu_mm_ccr2_notlb_b));
      
      assign mm_perf_event_t1_d[23] = (((derat_req0_valid & ~derat_req0_nonspec & derat_req0_thdid[1]) | 
                                          (derat_req1_valid & ~derat_req1_nonspec & derat_req1_thdid[1]) | 
                                          (derat_req2_valid & ~derat_req2_nonspec & derat_req2_thdid[1]) | 
                                          (derat_req3_valid & ~derat_req3_nonspec & derat_req3_thdid[1]) | 
                                          ((~tlb_seq_idle) & tlb_tag0_type[0] & tlb_tag0_thdid[1] & ~tlb_tag0_nonspec)) & xu_mm_ccr2_notlb_b) | 
                                          (lq_mm_perf_dtlb[1] & (~lq_mm_derat_req_nonspec) & (~xu_mm_ccr2_notlb_b));
      


      
      assign mm_perf_event_core_level_d[0] = (ierat_req_taken & xu_mm_ccr2_notlb_b) |
                                               ( |(iu_mm_perf_itlb) & (~xu_mm_ccr2_notlb_b) );
      
      assign mm_perf_event_core_level_d[1] = (derat_req_taken & xu_mm_ccr2_notlb_b) |
                                               ( |(lq_mm_perf_dtlb) & (~xu_mm_ccr2_notlb_b) );
      
      assign mm_perf_event_core_level_d[2] = tlb_cmp_perf_miss_direct & event_en[4];
      
      assign mm_perf_event_core_level_d[3] = tlb_cmp_perf_hit_first_page & event_en[4];
      
      assign mm_perf_event_core_level_d[4] = tlb_cmp_perf_hit_indirect & event_en[4];
      
      assign mm_perf_event_core_level_d[5] = tlb_cmp_perf_ptereload_noexcep & event_en[4];
      
      assign mm_perf_event_core_level_d[6] = tlb_cmp_perf_lrat_request & event_en[4];
      
      assign mm_perf_event_core_level_d[7] = tlb_cmp_perf_lrat_miss & event_en[4];
      
      assign mm_perf_event_core_level_d[8] = tlb_cmp_perf_pt_fault & event_en[4];
      
      assign mm_perf_event_core_level_d[9] = tlb_cmp_perf_pt_inelig & event_en[4];
      
      assign mm_perf_event_core_level_d[10] = tlb_ctl_perf_tlbwec_noresv & event_en[4];
      
      assign mm_perf_event_core_level_d[11] = tlb_ctl_perf_tlbwec_resv & event_en[4];
      
      assign mm_perf_event_core_level_d[12] = inval_perf_tlbilx;
      
      assign mm_perf_event_core_level_d[13] = inval_perf_tlbivax;
      
      assign mm_perf_event_core_level_d[14] = inval_perf_tlbivax_snoop;
      
      assign mm_perf_event_core_level_d[15] = inval_perf_tlb_flush;
      
      assign mm_perf_event_core_level_d[16] = (mm_perf_event_core_level_q[0] & tlb_tag0_nonspec & xu_mm_ccr2_notlb_b) |   
                                                ( |(iu_mm_perf_itlb) & iu_mm_ierat_req_nonspec & (~xu_mm_ccr2_notlb_b) );
      
      assign mm_perf_event_core_level_d[17] = (mm_perf_event_core_level_q[1] & tlb_tag0_nonspec & xu_mm_ccr2_notlb_b) |    
                                                ( |(lq_mm_perf_dtlb) & lq_mm_derat_req_nonspec & (~xu_mm_ccr2_notlb_b) );
      
      assign mm_perf_event_core_level_d[18] = tlb_cmp_perf_miss_direct & event_en[4] & tlb_tag4_nonspec; 
      
      assign mm_perf_event_core_level_d[19] = tlb_cmp_perf_hit_first_page & event_en[4] & tlb_tag4_nonspec;
      
      assign mm_perf_event_core_level_d[20] = (mm_perf_event_core_level_q[0] & ~tlb_tag0_nonspec & xu_mm_ccr2_notlb_b) |    
                                                ( |(iu_mm_perf_itlb) & (~iu_mm_ierat_req_nonspec) & (~xu_mm_ccr2_notlb_b) );
      
      assign mm_perf_event_core_level_d[21] = (mm_perf_event_core_level_q[1] & ~tlb_tag0_nonspec & xu_mm_ccr2_notlb_b) |    
                                                ( |(lq_mm_perf_dtlb) & (~lq_mm_derat_req_nonspec) & (~xu_mm_ccr2_notlb_b) );
      
      assign mm_perf_event_core_level_d[22] = tlb_cmp_perf_miss_direct & event_en[4] & ~tlb_tag4_nonspec; 
      
      assign mm_perf_event_core_level_d[23] = tlb_cmp_perf_hit_first_page & event_en[4] & ~tlb_tag4_nonspec;
      
      assign mm_perf_event_core_level_d[24] = (mm_perf_event_core_level_q[0] | mm_perf_event_core_level_q[1]);  

      assign mm_perf_event_core_level_d[25] = ( (mm_perf_event_core_level_q[0] | mm_perf_event_core_level_q[1]) & tlb_tag0_nonspec & xu_mm_ccr2_notlb_b ) |   
                                                ( (mm_perf_event_core_level_q[16] | mm_perf_event_core_level_q[17]) & (~xu_mm_ccr2_notlb_b) );  

      assign mm_perf_event_core_level_d[26] = ( (mm_perf_event_core_level_q[0] | mm_perf_event_core_level_q[1]) & ~tlb_tag0_nonspec & xu_mm_ccr2_notlb_b ) |  
                                                ( (mm_perf_event_core_level_q[20] | mm_perf_event_core_level_q[21]) & (~xu_mm_ccr2_notlb_b) );  

      assign mm_perf_event_core_level_d[27] = tlb_cmp_perf_hit_direct & event_en[4];
      
      assign mm_perf_event_core_level_d[28] = tlb_cmp_perf_hit_direct & event_en[4] & tlb_tag4_nonspec;
      
      assign mm_perf_event_core_level_d[29] = tlb_cmp_perf_hit_direct & event_en[4] & ~tlb_tag4_nonspec;

      assign mm_perf_event_core_level_d[30] = tlb_cmp_perf_ptereload & event_en[4];
      
      assign mm_perf_event_core_level_d[31] = ( |(iu_mm_perf_itlb) | |(lq_mm_perf_dtlb) );
      
      
      
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
         .din(rp_mm_event_bus_enable_q),		
         .dout(rp_mm_event_bus_enable_int_q)		
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
      
      assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
      assign scan_out = sov[0];
      

endmodule

