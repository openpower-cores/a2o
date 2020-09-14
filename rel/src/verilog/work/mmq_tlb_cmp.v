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


module mmq_tlb_cmp(
   inout                                   vdd,
   inout                                   gnd,
    (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]                 nclk,
   
   input                                   tc_ccflush_dc,
   input                                   tc_scan_dis_dc_b,
   input                                   tc_scan_diag_dc,
   input                                   tc_lbist_en_dc,
   input                                   lcb_d_mode_dc,
   input                                   lcb_clkoff_dc_b,
   input                                   lcb_act_dis_dc,
   input [0:4]                             lcb_mpw1_dc_b,
   input                                   lcb_mpw2_dc_b,
   input [0:4]                             lcb_delay_lclkr_dc,
   input                                   pc_sg_2,
   input                                   pc_func_sl_thold_2,
   input                                   pc_func_slp_sl_thold_2,
   input                                   pc_func_slp_nsl_thold_2,
   input                                   pc_fce_2,
   
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:2]                             ac_func_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:2]                            ac_func_scan_out,
   
   input                                   xu_mm_ccr2_notlb_b,
   input [0:`MM_THREADS-1]                 xu_mm_spr_epcr_dmiuh,
   input [0:`MM_THREADS-1]                 xu_mm_epcr_dgtmi,
   input [0:`MM_THREADS-1]                 xu_mm_msr_gs,
   input [0:`MM_THREADS-1]                 xu_mm_msr_pr,
   input                                   xu_mm_xucr4_mmu_mchk_q,
   
   input [0:`LPID_WIDTH-1]                  lpidr,
   input [10:18]                            mmucr1,
   input [64-`MMUCR3_WIDTH:63]              mmucr3_0,
   input [1:3]                              tstmode4k_0,
`ifdef MM_THREADS2   
   input [64-`MMUCR3_WIDTH:63]              mmucr3_1,
   input [1:3]                              tstmode4k_1,
`endif   
   output [0:4]                            mm_iu_ierat_rel_val,
   output [0:`ERAT_REL_DATA_WIDTH-1]       mm_iu_ierat_rel_data,
   output [0:4]                            mm_xu_derat_rel_val,
   output [0:`ERAT_REL_DATA_WIDTH-1]       mm_xu_derat_rel_data,
   output [0:6]                            tlb_cmp_ierat_dup_val,
   output [0:6]                            tlb_cmp_derat_dup_val,
   output [0:1]                            tlb_cmp_erat_dup_wait,
   input [0:`PID_WIDTH-1]                  ierat_req0_pid,
   input                                   ierat_req0_as,
   input                                   ierat_req0_gs,
   input [0:`EPN_WIDTH-1]                  ierat_req0_epn,
   input [0:`THDID_WIDTH-1]                ierat_req0_thdid,
   input                                   ierat_req0_valid,
   input                                   ierat_req0_nonspec,
   input [0:`PID_WIDTH-1]                  ierat_req1_pid,
   input                                   ierat_req1_as,
   input                                   ierat_req1_gs,
   input [0:`EPN_WIDTH-1]                  ierat_req1_epn,
   input [0:`THDID_WIDTH-1]                ierat_req1_thdid,
   input                                   ierat_req1_valid,
   input                                   ierat_req1_nonspec,
   input [0:`PID_WIDTH-1]                  ierat_req2_pid,
   input                                   ierat_req2_as,
   input                                   ierat_req2_gs,
   input [0:`EPN_WIDTH-1]                  ierat_req2_epn,
   input [0:`THDID_WIDTH-1]                ierat_req2_thdid,
   input                                   ierat_req2_valid,
   input                                   ierat_req2_nonspec,
   input [0:`PID_WIDTH-1]                  ierat_req3_pid,
   input                                   ierat_req3_as,
   input                                   ierat_req3_gs,
   input [0:`EPN_WIDTH-1]                  ierat_req3_epn,
   input [0:`THDID_WIDTH-1]                ierat_req3_thdid,
   input                                   ierat_req3_valid,
   input                                   ierat_req3_nonspec,
   input [0:`PID_WIDTH-1]                  ierat_iu4_pid,
   input                                   ierat_iu4_gs,
   input                                   ierat_iu4_as,
   input [0:`EPN_WIDTH-1]                  ierat_iu4_epn,
   input [0:`THDID_WIDTH-1]                ierat_iu4_thdid,
   input                                   ierat_iu4_valid,
   input [0:`LPID_WIDTH-1]                 derat_req0_lpid,
   input [0:`PID_WIDTH-1]                  derat_req0_pid,
   input                                   derat_req0_as,
   input                                   derat_req0_gs,
   input [0:`EPN_WIDTH-1]                  derat_req0_epn,
   input [0:`THDID_WIDTH-1]                derat_req0_thdid,
   input [0:`EMQ_ENTRIES-1]                derat_req0_emq,
   input                                   derat_req0_valid,
   input [0:`LPID_WIDTH-1]                 derat_req1_lpid,
   input [0:`PID_WIDTH-1]                  derat_req1_pid,
   input                                   derat_req1_as,
   input                                   derat_req1_gs,
   input [0:`EPN_WIDTH-1]                  derat_req1_epn,
   input [0:`THDID_WIDTH-1]                derat_req1_thdid,
   input [0:`EMQ_ENTRIES-1]                derat_req1_emq,
   input                                   derat_req1_valid,
   input [0:`LPID_WIDTH-1]                 derat_req2_lpid,
   input [0:`PID_WIDTH-1]                  derat_req2_pid,
   input                                   derat_req2_as,
   input                                   derat_req2_gs,
   input [0:`EPN_WIDTH-1]                  derat_req2_epn,
   input [0:`THDID_WIDTH-1]                derat_req2_thdid,
   input [0:`EMQ_ENTRIES-1]                derat_req2_emq,
   input                                   derat_req2_valid,
   input [0:`LPID_WIDTH-1]                 derat_req3_lpid,
   input [0:`PID_WIDTH-1]                  derat_req3_pid,
   input                                   derat_req3_as,
   input                                   derat_req3_gs,
   input [0:`EPN_WIDTH-1]                  derat_req3_epn,
   input [0:`THDID_WIDTH-1]                derat_req3_thdid,
   input [0:`EMQ_ENTRIES-1]                derat_req3_emq,
   input                                   derat_req3_valid,
   input [0:`LPID_WIDTH-1]                 derat_ex5_lpid,
   input [0:`PID_WIDTH-1]                  derat_ex5_pid,
   input                                   derat_ex5_gs,
   input                                   derat_ex5_as,
   input [0:`EPN_WIDTH-1]                  derat_ex5_epn,
   input [0:`THDID_WIDTH-1]                derat_ex5_thdid,
   input                                   derat_ex5_valid,
   input [0:`TLB_TAG_WIDTH-1]              tlb_tag2,
   input [0:`TLB_ADDR_WIDTH-1]             tlb_addr2,
   input [0:1]                             ex6_illeg_instr,
   input                                   ierat_req_taken,
   input                                   derat_req_taken,
   input                                   ptereload_req_taken,
   input [0:1]                             tlb_tag0_type,
   input [64-`REAL_ADDR_WIDTH:51]          lrat_tag3_lpn,
   input [64-`REAL_ADDR_WIDTH:51]          lrat_tag3_rpn,
   input [0:3]                             lrat_tag3_hit_status,
   input [0:2]                             lrat_tag3_hit_entry,
   input [64-`REAL_ADDR_WIDTH:51]          lrat_tag4_lpn,
   input [64-`REAL_ADDR_WIDTH:51]          lrat_tag4_rpn,
   input [0:3]                             lrat_tag4_hit_status,
   input [0:2]                             lrat_tag4_hit_entry,
   input [0:15]                            lru_dataout,
   input [0:`TLB_WAY_WIDTH*`TLB_WAYS-1]    tlb_dataout,
   output [0:`TLB_WAY_WIDTH-1]             tlb_dataina,
   output [0:`TLB_WAY_WIDTH-1]             tlb_datainb,
   output [0:`TLB_ADDR_WIDTH-1]            lru_wr_addr,
   output [0:15]                           lru_write,
   output [0:15]                           lru_datain,
   output [0:15]                           lru_tag4_dataout,
   output [0:2]                            tlb_tag4_esel,
   output [0:1]                            tlb_tag4_wq,
   output [0:1]                            tlb_tag4_is,
   output                                  tlb_tag4_gs,
   output                                  tlb_tag4_pr,
   output                                  tlb_tag4_hes,
   output                                  tlb_tag4_atsel,
   output                                  tlb_tag4_pt,
   output                                  tlb_tag4_cmp_hit,
   output                                  tlb_tag4_way_ind,
   output                                  tlb_tag4_ptereload,
   output                                  tlb_tag4_endflag,
   output                                  tlb_tag4_parerr,
   output                                  tlb_tag4_nonspec,
   output [0:`TLB_ADDR_WIDTH-1]            tlb_addr4,  
   output [0:`TLB_WAYS-1]                  tlb_tag4_parerr_write,   
   output                                  tlb_tag5_parerr_zeroize, 
   output [0:`MM_THREADS-1]                tlb_tag5_except,
   output [0:`ITAG_SIZE_ENC-1]             tlb_tag4_itag,
   output [0:`ITAG_SIZE_ENC-1]             tlb_tag5_itag,
   output [0:`EMQ_ENTRIES-1]               tlb_tag5_emq,
   input                                   mmucfg_twc,
   input                                   mmucfg_lrat,
   input                                   tlb0cfg_pt,
   input                                   tlb0cfg_gtwe,
   input                                   tlb0cfg_ind,
   input [0:4]                             mas2_0_wimge,
   input [32:52]                           mas3_0_rpnl,
   input [0:3]                             mas3_0_ubits,
   input [0:5]                             mas3_0_usxwr,
   input [22:31]                           mas7_0_rpnu,
   input                                   mas8_0_vf,
`ifdef MM_THREADS2   
   input [0:4]                             mas2_1_wimge,
   input [32:52]                           mas3_1_rpnl,
   input [0:3]                             mas3_1_ubits,
   input [0:5]                             mas3_1_usxwr,
   input [22:31]                           mas7_1_rpnu,
   input                                   mas8_1_vf,
`endif   
   output [0:2]                            tlb_mas0_esel,
   output                                  tlb_mas1_v,
   output                                  tlb_mas1_iprot,
   output [0:`PID_WIDTH-1]                 tlb_mas1_tid,
   output [0:`PID_WIDTH-1]                 tlb_mas1_tid_error,
   output                                  tlb_mas1_ind,
   output                                  tlb_mas1_ts,
   output                                  tlb_mas1_ts_error,
   output [0:3]                            tlb_mas1_tsize,
   output [0:`EPN_WIDTH-1]                 tlb_mas2_epn,
   output [0:`EPN_WIDTH-1]                 tlb_mas2_epn_error,
   output [0:4]                            tlb_mas2_wimge,
   output [32:51]                          tlb_mas3_rpnl,
   output [0:3]                            tlb_mas3_ubits,
   output [0:5]                            tlb_mas3_usxwr,
   output [22:31]                          tlb_mas7_rpnu,
   output                                  tlb_mas8_tgs,
   output                                  tlb_mas8_vf,
   output [0:7]                            tlb_mas8_tlpid,
   output [0:8]                            tlb_mmucr1_een,
   output                                  tlb_mmucr1_we,
   output [0:`THDID_WIDTH-1]               tlb_mmucr3_thdid,
   output                                  tlb_mmucr3_resvattr,
   output [0:1]                            tlb_mmucr3_wlc,
   output [0:`CLASS_WIDTH-1]               tlb_mmucr3_class,
   output [0:`EXTCLASS_WIDTH-1]            tlb_mmucr3_extclass,
   output [0:1]                            tlb_mmucr3_rc,
   output                                  tlb_mmucr3_x,
   output                                  tlb_mas_tlbre,
   output                                  tlb_mas_tlbsx_hit,
   output                                  tlb_mas_tlbsx_miss,
   output                                  tlb_mas_dtlb_error,
   output                                  tlb_mas_itlb_error,
   output [0:`MM_THREADS-1]                tlb_mas_thdid,
   output                                  tlb_htw_req_valid,
   output [0:`TLB_TAG_WIDTH-1]             tlb_htw_req_tag,
   output [`TLB_WORD_WIDTH:`TLB_WAY_WIDTH-1] tlb_htw_req_way,
   output                                  tlbwe_back_inv_valid,
   output [0:`MM_THREADS-1]                tlbwe_back_inv_thdid,
   output [52-`EPN_WIDTH:51]               tlbwe_back_inv_addr,
   output [0:34]                           tlbwe_back_inv_attr,
   
   input [0:`PTE_WIDTH-1]                  ptereload_req_pte_lat,
   input [0:`MM_THREADS-1]                 tlb_ctl_tag2_flush,
   input [0:`MM_THREADS-1]                 tlb_ctl_tag3_flush,
   input [0:`MM_THREADS-1]                 tlb_ctl_tag4_flush,
   input [0:`MM_THREADS-1]                 tlb_resv_match_vec,
   
   output [0:`MM_THREADS-1]                mm_xu_eratmiss_done,
   output [0:`MM_THREADS-1]                mm_xu_tlb_miss,
   output [0:`MM_THREADS-1]                mm_xu_tlb_inelig,
   output [0:`MM_THREADS-1]                mm_xu_lrat_miss,
   output [0:`MM_THREADS-1]                mm_xu_pt_fault,
   output [0:`MM_THREADS-1]                mm_xu_hv_priv,
   output [0:`MM_THREADS-1]                mm_xu_esr_pt,
   output [0:`MM_THREADS-1]                mm_xu_esr_data,
   output [0:`MM_THREADS-1]                mm_xu_esr_epid,
   output [0:`MM_THREADS-1]                mm_xu_esr_st,
   output [0:`MM_THREADS-1]                mm_xu_cr0_eq,
   output [0:`MM_THREADS-1]                mm_xu_cr0_eq_valid,
   output [0:`MM_THREADS-1]                mm_xu_tlb_multihit_err,
   output [0:`MM_THREADS-1]                mm_xu_tlb_par_err,
   output [0:`MM_THREADS-1]                mm_xu_lru_par_err,
   
   output                                  mm_xu_ord_tlb_multihit,
   output                                  mm_xu_ord_tlb_par_err,
   output                                  mm_xu_ord_lru_par_err,
   
   output                                  mm_xu_tlb_miss_ored,
   output                                  mm_xu_lrat_miss_ored,
   output                                  mm_xu_tlb_inelig_ored,
   output                                  mm_xu_pt_fault_ored,
   output                                  mm_xu_hv_priv_ored,
   output                                  mm_xu_cr0_eq_ored,
   output                                  mm_xu_cr0_eq_valid_ored,
   output                                  mm_pc_tlb_multihit_err_ored,
   output                                  mm_pc_tlb_par_err_ored,
   output                                  mm_pc_lru_par_err_ored,
   input [9:16]                            tlb_delayed_act,
   output [0:9]                            tlb_cmp_perf_event_t0,
   output [0:9]                            tlb_cmp_perf_event_t1,
   output [0:1]                            tlb_cmp_perf_state,
   output                                  tlb_cmp_perf_miss_direct,
   output                                  tlb_cmp_perf_hit_direct,
   output                                  tlb_cmp_perf_hit_indirect,
   output                                  tlb_cmp_perf_hit_first_page,
   output                                  tlb_cmp_perf_ptereload,
   output                                  tlb_cmp_perf_ptereload_noexcep,
   output                                  tlb_cmp_perf_lrat_request,
   output                                  tlb_cmp_perf_lrat_miss,
   output                                  tlb_cmp_perf_pt_fault,
   output                                  tlb_cmp_perf_pt_inelig,
   output [0:`TLB_TAG_WIDTH-1]              tlb_cmp_dbg_tag4,
   output [0:`TLB_WAYS]                     tlb_cmp_dbg_tag4_wayhit,
   output [0:`TLB_ADDR_WIDTH-1]             tlb_cmp_dbg_addr4,
   output [0:`TLB_WAY_WIDTH-1]              tlb_cmp_dbg_tag4_way,
   output [0:4]                            tlb_cmp_dbg_tag4_parerr,
   output [0:11]                           tlb_cmp_dbg_tag4_lru_dataout_q,
   output [0:`TLB_WAY_WIDTH-1]              tlb_cmp_dbg_tag5_tlb_datain_q,
   output [0:11]                           tlb_cmp_dbg_tag5_lru_datain_q,
   output                                  tlb_cmp_dbg_tag5_lru_write,
   output                                  tlb_cmp_dbg_tag5_any_exception,
   output [0:3]                            tlb_cmp_dbg_tag5_except_type_q,
   output [0:1]                            tlb_cmp_dbg_tag5_except_thdid_q,
   output [0:9]                            tlb_cmp_dbg_tag5_erat_rel_val,
   output [0:131]                          tlb_cmp_dbg_tag5_erat_rel_data,
   output [0:19]                           tlb_cmp_dbg_erat_dup_q,
   output [0:8]                            tlb_cmp_dbg_addr_enable,
   output                                  tlb_cmp_dbg_pgsize_enable,
   output                                  tlb_cmp_dbg_class_enable,
   output [0:1]                            tlb_cmp_dbg_extclass_enable,
   output [0:1]                            tlb_cmp_dbg_state_enable,
   output                                  tlb_cmp_dbg_thdid_enable,
   output                                  tlb_cmp_dbg_pid_enable,
   output                                  tlb_cmp_dbg_lpid_enable,
   output                                  tlb_cmp_dbg_ind_enable,
   output                                  tlb_cmp_dbg_iprot_enable,
   output                                  tlb_cmp_dbg_way0_entry_v,
   output                                  tlb_cmp_dbg_way0_addr_match,
   output                                  tlb_cmp_dbg_way0_pgsize_match,
   output                                  tlb_cmp_dbg_way0_class_match,
   output                                  tlb_cmp_dbg_way0_extclass_match,
   output                                  tlb_cmp_dbg_way0_state_match,
   output                                  tlb_cmp_dbg_way0_thdid_match,
   output                                  tlb_cmp_dbg_way0_pid_match,
   output                                  tlb_cmp_dbg_way0_lpid_match,
   output                                  tlb_cmp_dbg_way0_ind_match,
   output                                  tlb_cmp_dbg_way0_iprot_match,
   output                                  tlb_cmp_dbg_way1_entry_v,
   output                                  tlb_cmp_dbg_way1_addr_match,
   output                                  tlb_cmp_dbg_way1_pgsize_match,
   output                                  tlb_cmp_dbg_way1_class_match,
   output                                  tlb_cmp_dbg_way1_extclass_match,
   output                                  tlb_cmp_dbg_way1_state_match,
   output                                  tlb_cmp_dbg_way1_thdid_match,
   output                                  tlb_cmp_dbg_way1_pid_match,
   output                                  tlb_cmp_dbg_way1_lpid_match,
   output                                  tlb_cmp_dbg_way1_ind_match,
   output                                  tlb_cmp_dbg_way1_iprot_match,
   output                                  tlb_cmp_dbg_way2_entry_v,
   output                                  tlb_cmp_dbg_way2_addr_match,
   output                                  tlb_cmp_dbg_way2_pgsize_match,
   output                                  tlb_cmp_dbg_way2_class_match,
   output                                  tlb_cmp_dbg_way2_extclass_match,
   output                                  tlb_cmp_dbg_way2_state_match,
   output                                  tlb_cmp_dbg_way2_thdid_match,
   output                                  tlb_cmp_dbg_way2_pid_match,
   output                                  tlb_cmp_dbg_way2_lpid_match,
   output                                  tlb_cmp_dbg_way2_ind_match,
   output                                  tlb_cmp_dbg_way2_iprot_match,
   output                                  tlb_cmp_dbg_way3_entry_v,
   output                                  tlb_cmp_dbg_way3_addr_match,
   output                                  tlb_cmp_dbg_way3_pgsize_match,
   output                                  tlb_cmp_dbg_way3_class_match,
   output                                  tlb_cmp_dbg_way3_extclass_match,
   output                                  tlb_cmp_dbg_way3_state_match,
   output                                  tlb_cmp_dbg_way3_thdid_match,
   output                                  tlb_cmp_dbg_way3_pid_match,
   output                                  tlb_cmp_dbg_way3_lpid_match,
   output                                  tlb_cmp_dbg_way3_ind_match,
   output                                  tlb_cmp_dbg_way3_iprot_match

);

      parameter  MMQ_TLB_CMP_CSWITCH_0TO7  = 0;

      parameter                               MMU_Mode_Value = 1'b0;
      parameter [0:1]                         TlbSel_Tlb = 2'b00;
      parameter [0:1]                         TlbSel_IErat = 2'b10;
      parameter [0:1]                         TlbSel_DErat = 2'b11;
      parameter [0:2]                         ERAT_PgSize_1GB = 3'b110;
      parameter [0:2]                         ERAT_PgSize_16MB = 3'b111;
      parameter [0:2]                         ERAT_PgSize_1MB = 3'b101;
      parameter [0:2]                         ERAT_PgSize_64KB = 3'b011;
      parameter [0:2]                         ERAT_PgSize_4KB = 3'b001;
      parameter [0:3]                         TLB_PgSize_1GB = 4'b1010;
      parameter [0:3]                         TLB_PgSize_16MB = 4'b0111;
      parameter [0:3]                         TLB_PgSize_1MB = 4'b0101;
      parameter [0:3]                         TLB_PgSize_64KB = 4'b0011;
      parameter [0:3]                         TLB_PgSize_4KB = 4'b0001;
      parameter [0:2]                         ERAT_PgSize_256MB = 3'b100;
      parameter [0:3]                         TLB_PgSize_256MB = 4'b1001;
      
      parameter                               pos_tlb_pei = 10;
      parameter                               pos_lru_pei = 11;
      parameter                               pos_ictid = 12;
      parameter                               pos_ittid = 13;
      parameter                               pos_dctid = 14;
      parameter                               pos_dttid = 15;
      parameter                               pos_dccd = 16;
      parameter                               pos_tlbwe_binv = 17;
      parameter                               pos_tlbi_msb = 18;
      parameter                               pos_tlbi_rej = 19;


      parameter                               tlb_way0_offset = 0;
      parameter                               tlb_way1_offset = tlb_way0_offset + `TLB_WAY_WIDTH;
      parameter                               tlb_way0_cmpmask_offset = tlb_way1_offset + `TLB_WAY_WIDTH;
      parameter                               tlb_way1_cmpmask_offset = tlb_way0_cmpmask_offset + 5;
      parameter                               tlb_way0_xbitmask_offset = tlb_way1_cmpmask_offset + 5;
      parameter                               tlb_way1_xbitmask_offset = tlb_way0_xbitmask_offset + 5;
      parameter                               tlb_tag3_cmpmask_offset = tlb_way1_xbitmask_offset + 5;
      parameter                               tlb_tag3_clone1_offset = tlb_tag3_cmpmask_offset + 5;
      parameter                               tlb_tag4_way_offset = tlb_tag3_clone1_offset + `TLB_TAG_WIDTH;
      parameter                               tlb_tag4_way_rw_offset = tlb_tag4_way_offset + `TLB_WAY_WIDTH;
      parameter                               tlb_dataina_offset = tlb_tag4_way_rw_offset + `TLB_WAY_WIDTH;
      parameter                               tlb_erat_rel_offset = tlb_dataina_offset + `TLB_WAY_WIDTH;
      parameter                               mmucr1_offset = tlb_erat_rel_offset + 132;
      parameter                               spare_a_offset = mmucr1_offset + 9;
      parameter                               scan_right_0 = spare_a_offset + 16 - 1;
      parameter                               tlb_way2_offset = 0;
      parameter                               tlb_way3_offset = tlb_way2_offset + `TLB_WAY_WIDTH;
      parameter                               tlb_way2_cmpmask_offset = tlb_way3_offset + `TLB_WAY_WIDTH;
      parameter                               tlb_way3_cmpmask_offset = tlb_way2_cmpmask_offset + 5;
      parameter                               tlb_way2_xbitmask_offset = tlb_way3_cmpmask_offset + 5;
      parameter                               tlb_way3_xbitmask_offset = tlb_way2_xbitmask_offset + 5;
      parameter                               tlb_tag3_clone2_offset = tlb_way3_xbitmask_offset + 5;
      parameter                               tlb_tag3_cmpmask_clone_offset = tlb_tag3_clone2_offset + `TLB_TAG_WIDTH;
      parameter                               tlb_erat_rel_clone_offset = tlb_tag3_cmpmask_clone_offset + 5;
      parameter                               tlb_tag4_way_clone_offset = tlb_erat_rel_clone_offset + 132;
      parameter                               tlb_tag4_way_rw_clone_offset = tlb_tag4_way_clone_offset + `TLB_WAY_WIDTH;
      parameter                               tlb_datainb_offset = tlb_tag4_way_rw_clone_offset + `TLB_WAY_WIDTH;
      parameter                               mmucr1_clone_offset = tlb_datainb_offset + `TLB_WAY_WIDTH;
      parameter                               spare_b_offset = mmucr1_clone_offset + 9;
      parameter                               scan_right_1 = spare_b_offset + 16 - 1;
      parameter                               tlb_tag3_offset = 0;
      parameter                               tlb_addr3_offset = tlb_tag3_offset + `TLB_TAG_WIDTH;
      parameter                               lru_tag3_dataout_offset = tlb_addr3_offset + `TLB_ADDR_WIDTH;
      parameter                               tlb_tag4_offset = lru_tag3_dataout_offset + 16;
      parameter                               tlb_tag4_wayhit_offset = tlb_tag4_offset + `TLB_TAG_WIDTH;
      parameter                               tlb_addr4_offset = tlb_tag4_wayhit_offset + `TLB_WAYS + 1;
      parameter                               lru_tag4_dataout_offset = tlb_addr4_offset + `TLB_ADDR_WIDTH;
      parameter                               tlbwe_tag4_back_inv_offset = lru_tag4_dataout_offset + 16;
      parameter                               tlbwe_tag4_back_inv_attr_offset = tlbwe_tag4_back_inv_offset + 2 + 1;
      parameter                               tlb_erat_val_offset = tlbwe_tag4_back_inv_attr_offset + 2;
      parameter                               tlb_erat_dup_offset = tlb_erat_val_offset + 2 * `THDID_WIDTH + 2;
      parameter                               lru_write_offset = tlb_erat_dup_offset + 2 * `THDID_WIDTH + 14;
      parameter                               lru_wr_addr_offset = lru_write_offset + `LRU_WIDTH;
      parameter                               lru_datain_offset = lru_wr_addr_offset + `TLB_ADDR_WIDTH;
      parameter                               eratmiss_done_offset = lru_datain_offset + `LRU_WIDTH;
      parameter                               tlb_miss_offset = eratmiss_done_offset + 2;
      parameter                               tlb_inelig_offset = tlb_miss_offset + 2;
      parameter                               lrat_miss_offset = tlb_inelig_offset + 2;
      parameter                               pt_fault_offset = lrat_miss_offset + 2;
      parameter                               hv_priv_offset = pt_fault_offset + 2;
      parameter                               tlb_tag5_except_offset = hv_priv_offset + 2;
      parameter                               lru_update_clear_enab_offset = tlb_tag5_except_offset + 2;
      parameter                               tlb_tag5_parerr_zeroize_offset = lru_update_clear_enab_offset + 1;
      parameter                               mm_xu_ord_par_mhit_err_offset = tlb_tag5_parerr_zeroize_offset + 1;
      parameter                               tlb_dsi_offset = mm_xu_ord_par_mhit_err_offset + 3;
      parameter                               tlb_isi_offset = tlb_dsi_offset + 2;
      parameter                               esr_pt_offset = tlb_isi_offset + 2;
      parameter                               esr_data_offset = esr_pt_offset + 2;
      parameter                               esr_epid_offset = esr_data_offset + 2;
      parameter                               esr_st_offset = esr_epid_offset + 2;
      parameter                               cr0_eq_offset = esr_st_offset + 2;
      parameter                               cr0_eq_valid_offset = cr0_eq_offset + 2;
      parameter                               tlb_multihit_err_offset = cr0_eq_valid_offset + 2;
      parameter                               tag4_parerr_offset = tlb_multihit_err_offset + 2;
      parameter                               tlb_par_err_offset = tag4_parerr_offset + `TLB_WAYS + 1;
      parameter                               lru_par_err_offset = tlb_par_err_offset + 2;
      parameter                               tlb_tag5_itag_offset = lru_par_err_offset + 2;
      parameter                               tlb_tag5_emq_offset = tlb_tag5_itag_offset + `ITAG_SIZE_ENC;
      parameter                               tlb_tag5_perf_offset = tlb_tag5_emq_offset + `EMQ_ENTRIES;
      parameter                               cswitch_offset = tlb_tag5_perf_offset + 8;
      parameter                               spare_c_offset = cswitch_offset + 8;
      parameter                               scan_right_2 = spare_c_offset + 16 - 1;

`ifdef MM_THREADS2
      parameter                      BUGSP_MM_THREADS = 2;
`else
      parameter                      BUGSP_MM_THREADS = 1;
`endif      



      
    (* NO_MODIFICATION="TRUE" *)
      wire [1:170]                            LRU_UPDATE_DATA_PT;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:2]                              lru_update_data;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    lru_update_data_enab;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    lru_update_clear_enab;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_tag4_parerr_zeroize;
      wire                                    tlb_tag5_parerr_zeroize_q;

    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_way0_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_way0_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_way1_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_way1_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_way2_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_way2_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_way3_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_way3_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_TAG_WIDTH-1]                tlb_tag3_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_TAG_WIDTH-1]                tlb_tag3_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_TAG_WIDTH-1]                tlb_tag3_clone1_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_TAG_WIDTH-1]                tlb_tag3_clone1_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_TAG_WIDTH-1]                tlb_tag3_clone2_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_TAG_WIDTH-1]                tlb_tag3_clone2_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_ADDR_WIDTH-1]               tlb_addr3_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_ADDR_WIDTH-1]               tlb_addr3_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:15]                             lru_tag3_dataout_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:15]                             lru_tag3_dataout_q;
      
      wire [0:4]                              tlb_tag3_cmpmask_d;
      wire [0:4]                              tlb_tag3_cmpmask_q;
      wire [0:4]                              tlb_tag3_cmpmask_clone_d;
      wire [0:4]                              tlb_tag3_cmpmask_clone_q;
      wire [0:4]                              tlb_way0_cmpmask_d;
      wire [0:4]                              tlb_way0_cmpmask_q;
      wire [0:4]                              tlb_way1_cmpmask_d;
      wire [0:4]                              tlb_way1_cmpmask_q;
      wire [0:4]                              tlb_way2_cmpmask_d;
      wire [0:4]                              tlb_way2_cmpmask_q;
      wire [0:4]                              tlb_way3_cmpmask_d;
      wire [0:4]                              tlb_way3_cmpmask_q;
      wire [0:4]                              tlb_way0_xbitmask_d;
      wire [0:4]                              tlb_way0_xbitmask_q;
      wire [0:4]                              tlb_way1_xbitmask_d;
      wire [0:4]                              tlb_way1_xbitmask_q;
      wire [0:4]                              tlb_way2_xbitmask_d;
      wire [0:4]                              tlb_way2_xbitmask_q;
      wire [0:4]                              tlb_way3_xbitmask_d;
      wire [0:4]                              tlb_way3_xbitmask_q;
      
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_TAG_WIDTH-1]                tlb_tag4_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_TAG_WIDTH-1]                tlb_tag4_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAYS]                       tlb_tag4_wayhit_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAYS]                       tlb_tag4_wayhit_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_ADDR_WIDTH-1]               tlb_addr4_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_ADDR_WIDTH-1]               tlb_addr4_q;
      
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_dataina_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_dataina_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_datainb_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_datainb_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`LRU_WIDTH-1]                    lru_tag4_dataout_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`LRU_WIDTH-1]                    lru_tag4_dataout_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_tag4_way_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_tag4_way_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_tag4_way_clone_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_tag4_way_clone_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_tag4_way_rw_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_tag4_way_rw_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_tag4_way_rw_clone_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_tag4_way_rw_clone_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAY_WIDTH-1]                tlb_tag4_way_rw_or;
      
      wire [0:`MM_THREADS]                    tlbwe_tag4_back_inv_d;
      wire [0:`MM_THREADS]                    tlbwe_tag4_back_inv_q;
      wire [18:19]                            tlbwe_tag4_back_inv_attr_d;
      wire [18:19]                            tlbwe_tag4_back_inv_attr_q;
      wire [0:2*`THDID_WIDTH+1]                tlb_erat_val_d;
      wire [0:2*`THDID_WIDTH+1]                tlb_erat_val_q;
      wire [0:`ERAT_REL_DATA_WIDTH-1]          tlb_erat_rel_d;
      wire [0:`ERAT_REL_DATA_WIDTH-1]          tlb_erat_rel_q;
      wire [0:`ERAT_REL_DATA_WIDTH-1]          tlb_erat_rel_clone_d;
      wire [0:`ERAT_REL_DATA_WIDTH-1]          tlb_erat_rel_clone_q;
      wire [0:2*`THDID_WIDTH+13]               tlb_erat_dup_d;
      wire [0:2*`THDID_WIDTH+13]               tlb_erat_dup_q;
      
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`LRU_WIDTH-1]                    lru_write_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`LRU_WIDTH-1]                    lru_write_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_ADDR_WIDTH-1]               lru_wr_addr_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_ADDR_WIDTH-1]               lru_wr_addr_q;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`LRU_WIDTH-1]                    lru_datain_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`LRU_WIDTH-1]                    lru_datain_q;
      
      wire [0:`MM_THREADS-1]                              eratmiss_done_d;
      wire [0:`MM_THREADS-1]                              eratmiss_done_q;
      wire [0:`MM_THREADS-1]                              tlb_miss_d;
      wire [0:`MM_THREADS-1]                              tlb_miss_q;
      wire [0:`MM_THREADS-1]                              tlb_inelig_d;
      wire [0:`MM_THREADS-1]                              tlb_inelig_q;
      wire [0:`MM_THREADS-1]                              lrat_miss_d;
      wire [0:`MM_THREADS-1]                              lrat_miss_q;
      wire [0:`MM_THREADS-1]                              pt_fault_d;
      wire [0:`MM_THREADS-1]                              pt_fault_q;
      wire [0:`MM_THREADS-1]                              hv_priv_d;
      wire [0:`MM_THREADS-1]                              hv_priv_q;
      wire [0:`MM_THREADS-1]                              tlb_tag5_except_d;
      wire [0:`MM_THREADS-1]                              tlb_tag5_except_q;
      wire [0:`MM_THREADS-1]                              tlb_dsi_d;
      wire [0:`MM_THREADS-1]                              tlb_dsi_q;
      wire [0:`MM_THREADS-1]                              tlb_isi_d;
      wire [0:`MM_THREADS-1]                              tlb_isi_q;
      
      wire [0:`TLB_WAYS]                      tag4_parerr_d, tag4_parerr_q;
      wire [0:`ITAG_SIZE_ENC-1]                tlb_tag5_itag_d, tlb_tag5_itag_q;
      wire [0:`EMQ_ENTRIES-1]                  tlb_tag5_emq_d, tlb_tag5_emq_q;
      wire [0:1]                               tlb_tag5_perf_d, tlb_tag5_perf_q;
      wire [10:18]                            mmucr1_q;
      wire [10:18]                            mmucr1_clone_q;
      
      wire [0:`MM_THREADS-1]                              esr_pt_d;
      wire [0:`MM_THREADS-1]                              esr_pt_q;
      wire [0:`MM_THREADS-1]                              esr_data_d;
      wire [0:`MM_THREADS-1]                              esr_data_q;
      wire [0:`MM_THREADS-1]                              esr_epid_d;
      wire [0:`MM_THREADS-1]                              esr_epid_q;
      wire [0:`MM_THREADS-1]                              esr_st_d;
      wire [0:`MM_THREADS-1]                              esr_st_q;
      wire [0:`MM_THREADS-1]                              tlb_multihit_err_d;
      wire [0:`MM_THREADS-1]                              tlb_multihit_err_q;
      wire [0:`MM_THREADS-1]                              tlb_par_err_d;
      wire [0:`MM_THREADS-1]                              tlb_par_err_q;
      wire [0:`MM_THREADS-1]                              lru_par_err_d;
      wire [0:`MM_THREADS-1]                              lru_par_err_q;
      wire [0:`MM_THREADS-1]                              cr0_eq_d;
      wire [0:`MM_THREADS-1]                              cr0_eq_q;
      wire [0:`MM_THREADS-1]                              cr0_eq_valid_d;
      wire [0:`MM_THREADS-1]                              cr0_eq_valid_q;
      wire [0:`MM_THREADS-1]                              epcr_dmiuh_q;
      wire [0:`MM_THREADS-1]                              msr_gs_q;
      wire [0:`MM_THREADS-1]                              msr_pr_q;
      
      wire                                    tlb_multihit_err_ored;
      wire                                    tlb_par_err_ored;
      wire                                    lru_par_err_ored;
      wire                                    lru_update_clear_enab_q;
      wire [0:2]                              mm_xu_ord_par_mhit_err_d, mm_xu_ord_par_mhit_err_q;
      
      wire [0:15]                             spare_a_q;
      wire [0:15]                             spare_b_q;
      wire [0:15]                             spare_c_q;
      wire [0:7]                              spare_nsl_q;
      wire [0:7]                              spare_nsl_clone_q;
      wire [0:7]                              cswitch_q;
      
      
    (* NO_MODIFICATION="TRUE" *)
      wire                                    pgsize_enable;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    class_enable;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    thdid_enable;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    pid_enable;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    lpid_enable;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    ind_enable;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    iprot_enable;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:1]                              state_enable;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:1]                              extclass_enable;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:8]                              addr_enable;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    comp_iprot;
      wire [0:1]                              comp_extclass;
      wire                                    comp_ind;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    pgsize_enable_clone;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    class_enable_clone;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    thdid_enable_clone;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    pid_enable_clone;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    lpid_enable_clone;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    ind_enable_clone;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    iprot_enable_clone;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:1]                              state_enable_clone;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:1]                              extclass_enable_clone;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:8]                              addr_enable_clone;
      wire                                    comp_iprot_clone;
      wire [0:1]                              comp_extclass_clone;
      wire                                    comp_ind_clone;

      wire                                    tlbwe_tag3_back_inv_enab;
      wire [0:`TLB_WAY_WIDTH-1]               tlb_tag4_way_or;
      wire                                    tlb_tag4_way_act;
      wire                                    tlb_tag4_way_clone_act;
      wire                                    tlb_tag4_way_rw_act;
      wire                                    tlb_tag4_way_rw_clone_act;
      wire [0:7]                              tlb_tag4_type_sig;
      wire [0:2]                              tlb_tag4_esel_sig;
      wire                                    tlb_tag4_hes_sig;
      wire [0:1]                              tlb_tag4_wq_sig;
      wire [0:3]                              tlb_tag4_is_sig;
      wire [0:`THDID_WIDTH-1]                 tlb_tag4_hes1_mas1_v;
      wire [0:`THDID_WIDTH-1]                 tlb_tag4_hes0_mas1_v;
      wire [0:`THDID_WIDTH-1]                 tlb_tag4_hes1_mas1_iprot;
      wire [0:`THDID_WIDTH-1]                 tlb_tag4_hes0_mas1_iprot;
      wire [0:`THDID_WIDTH-1]                 tlb_tag4_ptereload_v;
      wire [0:`THDID_WIDTH-1]                 tlb_tag4_ptereload_iprot;
      wire                                    tlb_tag4_ptereload_sig;
      wire                                    tlb_tag4_erat_data_cap;
      
    (* NO_MODIFICATION="TRUE" *)
      wire [0:`TLB_WAYS-1]                     tlb_wayhit;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    multihit;
      wire [0:2]                              erat_pgsize;
      wire                                    tlb_tag4_size_not_supp;
      wire                                    tlb_tag4_hv_op;
      wire                                    tlb_tag4_epcr_dgtmi;
      
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way0_addr_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way0_pgsize_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way0_class_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way0_extclass_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way0_state_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way0_thdid_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way0_pid_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way0_lpid_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way0_ind_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way0_iprot_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way1_addr_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way1_pgsize_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way1_class_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way1_extclass_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way1_state_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way1_thdid_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way1_pid_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way1_lpid_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way1_ind_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way1_iprot_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way2_addr_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way2_pgsize_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way2_class_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way2_extclass_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way2_state_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way2_thdid_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way2_pid_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way2_lpid_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way2_ind_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way2_iprot_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way3_addr_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way3_pgsize_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way3_class_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way3_extclass_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way3_state_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way3_thdid_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way3_pid_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way3_lpid_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way3_ind_match;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_way3_iprot_match;

      wire                                    ierat_req0_tag4_pid_match;
      wire                                    ierat_req0_tag4_as_match;
      wire                                    ierat_req0_tag4_gs_match;
      wire                                    ierat_req0_tag4_epn_match;
      wire                                    ierat_req0_tag4_thdid_match;
      wire                                    ierat_req1_tag4_pid_match;
      wire                                    ierat_req1_tag4_as_match;
      wire                                    ierat_req1_tag4_gs_match;
      wire                                    ierat_req1_tag4_epn_match;
      wire                                    ierat_req1_tag4_thdid_match;
      wire                                    ierat_req2_tag4_pid_match;
      wire                                    ierat_req2_tag4_as_match;
      wire                                    ierat_req2_tag4_gs_match;
      wire                                    ierat_req2_tag4_epn_match;
      wire                                    ierat_req2_tag4_thdid_match;
      wire                                    ierat_req3_tag4_pid_match;
      wire                                    ierat_req3_tag4_as_match;
      wire                                    ierat_req3_tag4_gs_match;
      wire                                    ierat_req3_tag4_epn_match;
      wire                                    ierat_req3_tag4_thdid_match;
      wire                                    ierat_iu4_tag4_lpid_match;
      wire                                    ierat_iu4_tag4_pid_match;
      wire                                    ierat_iu4_tag4_as_match;
      wire                                    ierat_iu4_tag4_gs_match;
      wire                                    ierat_iu4_tag4_epn_match;
      wire                                    ierat_iu4_tag4_thdid_match;
      wire                                    derat_req0_tag4_lpid_match;
      wire                                    derat_req0_tag4_pid_match;
      wire                                    derat_req0_tag4_as_match;
      wire                                    derat_req0_tag4_gs_match;
      wire                                    derat_req0_tag4_epn_match;
      wire                                    derat_req0_tag4_thdid_match;
      wire                                    derat_req1_tag4_lpid_match;
      wire                                    derat_req1_tag4_pid_match;
      wire                                    derat_req1_tag4_as_match;
      wire                                    derat_req1_tag4_gs_match;
      wire                                    derat_req1_tag4_epn_match;
      wire                                    derat_req1_tag4_thdid_match;
      wire                                    derat_req2_tag4_lpid_match;
      wire                                    derat_req2_tag4_pid_match;
      wire                                    derat_req2_tag4_as_match;
      wire                                    derat_req2_tag4_gs_match;
      wire                                    derat_req2_tag4_epn_match;
      wire                                    derat_req2_tag4_thdid_match;
      wire                                    derat_req3_tag4_lpid_match;
      wire                                    derat_req3_tag4_pid_match;
      wire                                    derat_req3_tag4_as_match;
      wire                                    derat_req3_tag4_gs_match;
      wire                                    derat_req3_tag4_epn_match;
      wire                                    derat_req3_tag4_thdid_match;
      wire                                    derat_ex5_tag4_lpid_match;
      wire                                    derat_ex5_tag4_pid_match;
      wire                                    derat_ex5_tag4_as_match;
      wire                                    derat_ex5_tag4_gs_match;
      wire                                    derat_ex5_tag4_epn_match;
      wire                                    derat_ex5_tag4_thdid_match;
      wire [0:`THDID_WIDTH-1]                 ierat_tag4_dup_thdid;
      wire [0:`THDID_WIDTH-1]                 derat_tag4_dup_thdid;
      wire [0:`EMQ_ENTRIES-1]                 derat_tag4_dup_emq;
      
      wire [0:9]                              tlb_way0_lo_calc_par;
      wire [0:9]                              tlb_way0_hi_calc_par;
      wire                                    tlb_way0_parerr;
      wire [0:9]                              tlb_way1_lo_calc_par;
      wire [0:9]                              tlb_way1_hi_calc_par;
      wire                                    tlb_way1_parerr;
      wire [0:9]                              tlb_way2_lo_calc_par;
      wire [0:9]                              tlb_way2_hi_calc_par;
      wire                                    tlb_way2_parerr;
      wire [0:9]                              tlb_way3_lo_calc_par;
      wire [0:9]                              tlb_way3_hi_calc_par;
      wire                                    tlb_way3_parerr;
      wire [0:1]                              lru_calc_par;
      
      wire [0:`TLB_WORD_WIDTH-10-1]           tlb_datain_lo_tlbwe_0_nopar;
      wire [0:9]                              tlb_datain_lo_tlbwe_0_par;
      wire [0:`TLB_WORD_WIDTH-10-1]           tlb_datain_hi_hv_tlbwe_0_nopar;
      wire [0:`TLB_WORD_WIDTH-10-1]           tlb_datain_hi_gs_tlbwe_0_nopar;
      wire [0:9]                              tlb_datain_hi_hv_tlbwe_0_par;
      wire [0:9]                              tlb_datain_hi_gs_tlbwe_0_par;
`ifdef MM_THREADS2      
      wire [0:`TLB_WORD_WIDTH-10-1]           tlb_datain_lo_tlbwe_1_nopar;
      wire [0:9]                              tlb_datain_lo_tlbwe_1_par;
      wire [0:`TLB_WORD_WIDTH-10-1]           tlb_datain_hi_hv_tlbwe_1_nopar;
      wire [0:`TLB_WORD_WIDTH-10-1]           tlb_datain_hi_gs_tlbwe_1_nopar;
      wire [0:9]                              tlb_datain_hi_hv_tlbwe_1_par;
      wire [0:9]                              tlb_datain_hi_gs_tlbwe_1_par;
`endif      
      wire [0:`TLB_WORD_WIDTH-10-1]           tlb_datain_lo_ptereload_nopar;
      wire [0:9]                              tlb_datain_lo_ptereload_par;
      wire [0:`TLB_WORD_WIDTH-10-1]           tlb_datain_hi_hv_ptereload_nopar;
      wire [0:`TLB_WORD_WIDTH-10-1]           tlb_datain_hi_gs_ptereload_nopar;
      wire [0:9]                              tlb_datain_hi_hv_ptereload_par;
      wire [0:9]                              tlb_datain_hi_gs_ptereload_par;
      wire [0:5]                              ptereload_req_derived_usxwr;
      wire [22:51]                            lrat_tag3_lpn_sig;
      wire [22:51]                            lrat_tag3_rpn_sig;
      wire [22:51]                            lrat_tag4_lpn_sig;
      wire [22:51]                            lrat_tag4_rpn_sig;

    (* NO_MODIFICATION="TRUE" *)
      wire [4:9]                              lru_datain_alt_d;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:2]                              lru_update_data_alt;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_tag4_parerr_enab;
    (* NO_MODIFICATION="TRUE" *)
      wire                                    tlb_tag4_tlbre_parerr;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:2]                              lru_update_data_snoophit_eco;
    (* NO_MODIFICATION="TRUE" *)
      wire [0:2]                              lru_update_data_erathit_eco;

      (* analysis_not_referenced="true" *)  
      wire [0:41]                             unused_dc;

      wire [0:15]            tri_regk_unused_scan;   

      wire [0:`MM_THREADS-1] tri_regk_unused_scan_epcr_dmiuh; 
      wire [0:`MM_THREADS-1] tri_regk_unused_scan_msr_gs; 
      wire [0:`MM_THREADS-1] tri_regk_unused_scan_msr_pr; 
      
      
      wire                                    ECO107332_orred_tag4_thdid_flushed;
      wire [0:`MM_THREADS-1]                  ECO107332_tlb_par_err_d;
      wire [0:`MM_THREADS-1]                  ECO107332_lru_par_err_d;
      
      wire                                    pc_sg_1;
      wire                                    pc_sg_0;
      wire                                    pc_fce_1;
      wire                                    pc_fce_0;
      wire                                    pc_func_sl_thold_1;
      wire                                    pc_func_sl_thold_0;
      wire                                    pc_func_sl_thold_0_b;
      wire                                    pc_func_slp_sl_thold_1;
      wire                                    pc_func_slp_sl_thold_0;
      wire                                    pc_func_slp_sl_thold_0_b;
      wire                                    pc_func_sl_force;
      wire                                    pc_func_slp_sl_force;
      wire                                    pc_func_slp_nsl_thold_1;
      wire                                    pc_func_slp_nsl_thold_0;
      wire [0:1]                              pc_func_slp_nsl_thold_0_b;
      wire [0:1]                              pc_func_slp_nsl_force;
      
      wire [0:scan_right_0]                   siv_0;
      wire [0:scan_right_0]                   sov_0;
      wire [0:scan_right_1]                   siv_1;
      wire [0:scan_right_1]                   sov_1;
      wire [0:scan_right_2]                   siv_2;
      wire [0:scan_right_2]                   sov_2;
      
      wire                                    tidn;
      wire                                    tiup;
      
      
      
      assign tidn = 1'b0;
      assign tiup = 1'b1;
      
      assign tlb_addr3_d = tlb_addr2;

      assign tlb_way0_d = tlb_dataout[0:`TLB_WAY_WIDTH - 1];
      assign tlb_way1_d = tlb_dataout[`TLB_WAY_WIDTH:2 * `TLB_WAY_WIDTH - 1];
      assign tlb_way2_d = tlb_dataout[2 * `TLB_WAY_WIDTH:3 * `TLB_WAY_WIDTH - 1];
      assign tlb_way3_d = tlb_dataout[3 * `TLB_WAY_WIDTH:4 * `TLB_WAY_WIDTH - 1];

      assign tlb_tag3_d[0:`tagpos_thdid - 1] = tlb_tag2[0:`tagpos_thdid - 1];

      assign tlb_tag3_d[`tagpos_thdid:`tagpos_thdid +  `MM_THREADS - 1] = 
                                                         (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & (tlb_tag4_q[`tagpos_type_ierat] == 1'b1 | tlb_tag4_q[`tagpos_type_derat] == 1'b1))) ? {`MM_THREADS{1'b0}} : 
                                                         (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & (tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbsrx] == 1'b1))) ? {`MM_THREADS{1'b0}} : 
                                                         ((tlb_tag4_q[`tagpos_endflag] == 1'b1 & tlb_tag4_q[`tagpos_type_snoop] == 1'b1)) ? {`MM_THREADS{1'b0}} : 
                                                         (((tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 | tlb_tag4_q[`tagpos_type_ptereload] == 1'b1) & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1)) ? {`MM_THREADS{1'b0}} : 
                                                      tlb_tag2[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag2_flush));
      generate
         if (`THDID_WIDTH > `MM_THREADS)
         begin : tlbtag3NExist
            assign tlb_tag3_d[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1] = 
                                                         (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & (tlb_tag4_q[`tagpos_type_ierat] == 1'b1 | tlb_tag4_q[`tagpos_type_derat] == 1'b1))) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                                         (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & (tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbsrx] == 1'b1))) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                                         ((tlb_tag4_q[`tagpos_endflag] == 1'b1 & tlb_tag4_q[`tagpos_type_snoop] == 1'b1)) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                                         (((tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 | tlb_tag4_q[`tagpos_type_ptereload] == 1'b1) & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1)) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                                      tlb_tag2[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1];
         end
      endgenerate

      assign tlb_tag3_d[`tagpos_thdid + `THDID_WIDTH:`TLB_TAG_WIDTH - 1] = tlb_tag2[`tagpos_thdid + `THDID_WIDTH:`TLB_TAG_WIDTH - 1];

      assign tlb_tag3_clone1_d[0:`tagpos_thdid - 1] = tlb_tag2[0:`tagpos_thdid - 1];
      assign tlb_tag3_clone1_d[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] =
                                                         (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & (tlb_tag4_q[`tagpos_type_ierat] == 1'b1 | tlb_tag4_q[`tagpos_type_derat] == 1'b1))) ? {`MM_THREADS{1'b0}} : 
                                                         (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & (tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbsrx] == 1'b1))) ? {`MM_THREADS{1'b0}} : 
                                                         ((tlb_tag4_q[`tagpos_endflag] == 1'b1 & tlb_tag4_q[`tagpos_type_snoop] == 1'b1)) ? {`MM_THREADS{1'b0}} : 
                                                         (((tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 | tlb_tag4_q[`tagpos_type_ptereload] == 1'b1) & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1)) ? {`MM_THREADS{1'b0}} : 
                                                       tlb_tag2[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag2_flush));
      generate
         if (`THDID_WIDTH > `MM_THREADS)
         begin : tlbtag3c1NExist
            assign tlb_tag3_clone1_d[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1] = 
                                                         (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & (tlb_tag4_q[`tagpos_type_ierat] == 1'b1 | tlb_tag4_q[`tagpos_type_derat] == 1'b1))) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                                         (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & (tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbsrx] == 1'b1))) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                                         ((tlb_tag4_q[`tagpos_endflag] == 1'b1 & tlb_tag4_q[`tagpos_type_snoop] == 1'b1)) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                                         (((tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 | tlb_tag4_q[`tagpos_type_ptereload] == 1'b1) & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1)) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                                        tlb_tag2[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1];
         end
      endgenerate

      assign tlb_tag3_clone1_d[`tagpos_thdid + `THDID_WIDTH:`TLB_TAG_WIDTH - 1] = tlb_tag2[`tagpos_thdid + `THDID_WIDTH:`TLB_TAG_WIDTH - 1];

      assign tlb_tag3_clone2_d[0:`tagpos_thdid - 1] = tlb_tag2[0:`tagpos_thdid - 1];
      assign tlb_tag3_clone2_d[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] = 
                                                                (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & (tlb_tag4_q[`tagpos_type_ierat] == 1'b1 | tlb_tag4_q[`tagpos_type_derat] == 1'b1))) ? {`MM_THREADS{1'b0}} : 
                                                                (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & (tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbsrx] == 1'b1))) ? {`MM_THREADS{1'b0}} : 
                                                                ((tlb_tag4_q[`tagpos_endflag] == 1'b1 & tlb_tag4_q[`tagpos_type_snoop] == 1'b1)) ? {`MM_THREADS{1'b0}} : 
                                                                (((tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 | tlb_tag4_q[`tagpos_type_ptereload] == 1'b1) & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1)) ? {`MM_THREADS{1'b0}} : 
                                                              tlb_tag2[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag2_flush));
      generate
         if (`THDID_WIDTH > `MM_THREADS)
         begin : tlbtag3c2NExist
            assign tlb_tag3_clone2_d[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1] = 
                                                                (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & (tlb_tag4_q[`tagpos_type_ierat] == 1'b1 | tlb_tag4_q[`tagpos_type_derat] == 1'b1))) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                                                (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & (tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbsrx] == 1'b1))) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                                                ((tlb_tag4_q[`tagpos_endflag] == 1'b1 & tlb_tag4_q[`tagpos_type_snoop] == 1'b1)) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                                                (((tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 | tlb_tag4_q[`tagpos_type_ptereload] == 1'b1) & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1)) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                                              tlb_tag2[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1];
         end
      endgenerate

      assign tlb_tag3_clone2_d[`tagpos_thdid + `THDID_WIDTH:`TLB_TAG_WIDTH - 1] = tlb_tag2[`tagpos_thdid + `THDID_WIDTH:`TLB_TAG_WIDTH - 1];


      assign tlb_tag3_cmpmask_d[0] = (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB);
      assign tlb_tag3_cmpmask_d[1] = (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB);
      assign tlb_tag3_cmpmask_d[2] = (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB);
      assign tlb_tag3_cmpmask_d[3] = (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB);
      assign tlb_tag3_cmpmask_d[4] = (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB);

      assign tlb_tag3_cmpmask_clone_d[0] = (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB);
      assign tlb_tag3_cmpmask_clone_d[1] = (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB);
      assign tlb_tag3_cmpmask_clone_d[2] = (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB);
      assign tlb_tag3_cmpmask_clone_d[3] = (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB);
      assign tlb_tag3_cmpmask_clone_d[4] = (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (tlb_tag2[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB);

      assign tlb_way0_cmpmask_d[0] = (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB);
      assign tlb_way0_cmpmask_d[1] = (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB);
      assign tlb_way0_cmpmask_d[2] = (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB) | (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB);
      assign tlb_way0_cmpmask_d[3] = (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB) | (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB) | (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1MB);
      assign tlb_way0_cmpmask_d[4] = (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB) | (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB) | (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1MB) | (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_64KB);
      assign tlb_way0_xbitmask_d[0] = (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB);
      assign tlb_way0_xbitmask_d[1] = (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB);
      assign tlb_way0_xbitmask_d[2] = (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB);
      assign tlb_way0_xbitmask_d[3] = (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1MB);
      assign tlb_way0_xbitmask_d[4] = (tlb_dataout[0 * `TLB_WAY_WIDTH + `waypos_size:0 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_64KB);
      assign tlb_way1_cmpmask_d[0] = (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB);
      assign tlb_way1_cmpmask_d[1] = (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB);
      assign tlb_way1_cmpmask_d[2] = (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB) | (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB);
      assign tlb_way1_cmpmask_d[3] = (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB) | (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB) | (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1MB);
      assign tlb_way1_cmpmask_d[4] = (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB) | (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB) | (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1MB) | (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_64KB);
      assign tlb_way1_xbitmask_d[0] = (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB);
      assign tlb_way1_xbitmask_d[1] = (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB);
      assign tlb_way1_xbitmask_d[2] = (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB);
      assign tlb_way1_xbitmask_d[3] = (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1MB);
      assign tlb_way1_xbitmask_d[4] = (tlb_dataout[1 * `TLB_WAY_WIDTH + `waypos_size:1 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_64KB);
      assign tlb_way2_cmpmask_d[0] = (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB);
      assign tlb_way2_cmpmask_d[1] = (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB);
      assign tlb_way2_cmpmask_d[2] = (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB) | (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB);
      assign tlb_way2_cmpmask_d[3] = (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB) | (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB) | (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1MB);
      assign tlb_way2_cmpmask_d[4] = (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB) | (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB) | (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1MB) | (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_64KB);
      assign tlb_way2_xbitmask_d[0] = (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB);
      assign tlb_way2_xbitmask_d[1] = (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB);
      assign tlb_way2_xbitmask_d[2] = (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB);
      assign tlb_way2_xbitmask_d[3] = (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1MB);
      assign tlb_way2_xbitmask_d[4] = (tlb_dataout[2 * `TLB_WAY_WIDTH + `waypos_size:2 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_64KB);
      assign tlb_way3_cmpmask_d[0] = (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB);
      assign tlb_way3_cmpmask_d[1] = (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB);
      assign tlb_way3_cmpmask_d[2] = (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB) | (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB);
      assign tlb_way3_cmpmask_d[3] = (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB) | (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB) | (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1MB);
      assign tlb_way3_cmpmask_d[4] = (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB) | (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB) | (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB) | (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1MB) | (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_64KB);
      assign tlb_way3_xbitmask_d[0] = (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1GB);
      assign tlb_way3_xbitmask_d[1] = (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_256MB);
      assign tlb_way3_xbitmask_d[2] = (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_16MB);
      assign tlb_way3_xbitmask_d[3] = (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_1MB);
      assign tlb_way3_xbitmask_d[4] = (tlb_dataout[3 * `TLB_WAY_WIDTH + `waypos_size:3 * `TLB_WAY_WIDTH + `waypos_size + 3] == TLB_PgSize_64KB);
      assign tlb_way0_lo_calc_par[0] = ^(tlb_way0_q[0:7]);
      assign tlb_way0_lo_calc_par[1] = ^(tlb_way0_q[8:15]);
      assign tlb_way0_lo_calc_par[2] = ^(tlb_way0_q[16:23]);
      assign tlb_way0_lo_calc_par[3] = ^(tlb_way0_q[24:31]);
      assign tlb_way0_lo_calc_par[4] = ^(tlb_way0_q[32:39]);
      assign tlb_way0_lo_calc_par[5] = ^(tlb_way0_q[40:47]);
      assign tlb_way0_lo_calc_par[6] = ^(tlb_way0_q[48:51]);
      assign tlb_way0_lo_calc_par[7] = ^(tlb_way0_q[52:59]);
      assign tlb_way0_lo_calc_par[8] = ^(tlb_way0_q[60:65]);
      assign tlb_way0_lo_calc_par[9] = ^(tlb_way0_q[66:73]);
      assign tlb_way1_lo_calc_par[0] = ^(tlb_way1_q[0:7]);
      assign tlb_way1_lo_calc_par[1] = ^(tlb_way1_q[8:15]);
      assign tlb_way1_lo_calc_par[2] = ^(tlb_way1_q[16:23]);
      assign tlb_way1_lo_calc_par[3] = ^(tlb_way1_q[24:31]);
      assign tlb_way1_lo_calc_par[4] = ^(tlb_way1_q[32:39]);
      assign tlb_way1_lo_calc_par[5] = ^(tlb_way1_q[40:47]);
      assign tlb_way1_lo_calc_par[6] = ^(tlb_way1_q[48:51]);
      assign tlb_way1_lo_calc_par[7] = ^(tlb_way1_q[52:59]);
      assign tlb_way1_lo_calc_par[8] = ^(tlb_way1_q[60:65]);
      assign tlb_way1_lo_calc_par[9] = ^(tlb_way1_q[66:73]);
      assign tlb_way2_lo_calc_par[0] = ^(tlb_way2_q[0:7]);
      assign tlb_way2_lo_calc_par[1] = ^(tlb_way2_q[8:15]);
      assign tlb_way2_lo_calc_par[2] = ^(tlb_way2_q[16:23]);
      assign tlb_way2_lo_calc_par[3] = ^(tlb_way2_q[24:31]);
      assign tlb_way2_lo_calc_par[4] = ^(tlb_way2_q[32:39]);
      assign tlb_way2_lo_calc_par[5] = ^(tlb_way2_q[40:47]);
      assign tlb_way2_lo_calc_par[6] = ^(tlb_way2_q[48:51]);
      assign tlb_way2_lo_calc_par[7] = ^(tlb_way2_q[52:59]);
      assign tlb_way2_lo_calc_par[8] = ^(tlb_way2_q[60:65]);
      assign tlb_way2_lo_calc_par[9] = ^(tlb_way2_q[66:73]);
      assign tlb_way3_lo_calc_par[0] = ^(tlb_way3_q[0:7]);
      assign tlb_way3_lo_calc_par[1] = ^(tlb_way3_q[8:15]);
      assign tlb_way3_lo_calc_par[2] = ^(tlb_way3_q[16:23]);
      assign tlb_way3_lo_calc_par[3] = ^(tlb_way3_q[24:31]);
      assign tlb_way3_lo_calc_par[4] = ^(tlb_way3_q[32:39]);
      assign tlb_way3_lo_calc_par[5] = ^(tlb_way3_q[40:47]);
      assign tlb_way3_lo_calc_par[6] = ^(tlb_way3_q[48:51]);
      assign tlb_way3_lo_calc_par[7] = ^(tlb_way3_q[52:59]);
      assign tlb_way3_lo_calc_par[8] = ^(tlb_way3_q[60:65]);
      assign tlb_way3_lo_calc_par[9] = ^(tlb_way3_q[66:73]);
      assign tlb_way0_hi_calc_par[0] = ^(tlb_way0_q[`TLB_WORD_WIDTH + 0:`TLB_WORD_WIDTH + 7]);
      assign tlb_way0_hi_calc_par[1] = ^(tlb_way0_q[`TLB_WORD_WIDTH + 8:`TLB_WORD_WIDTH + 15]);
      assign tlb_way0_hi_calc_par[2] = ^(tlb_way0_q[`TLB_WORD_WIDTH + 16:`TLB_WORD_WIDTH + 23]);
      assign tlb_way0_hi_calc_par[3] = ^(tlb_way0_q[`TLB_WORD_WIDTH + 24:`TLB_WORD_WIDTH + 31]);
      assign tlb_way0_hi_calc_par[4] = ^(tlb_way0_q[`TLB_WORD_WIDTH + 32:`TLB_WORD_WIDTH + 39]);
      assign tlb_way0_hi_calc_par[5] = ^(tlb_way0_q[`TLB_WORD_WIDTH + 40:`TLB_WORD_WIDTH + 44]);
      assign tlb_way0_hi_calc_par[6] = ^(tlb_way0_q[`TLB_WORD_WIDTH + 45:`TLB_WORD_WIDTH + 49]);
      assign tlb_way0_hi_calc_par[7] = ^(tlb_way0_q[`TLB_WORD_WIDTH + 50:`TLB_WORD_WIDTH + 57]);
      assign tlb_way0_hi_calc_par[8] = ^(tlb_way0_q[`TLB_WORD_WIDTH + 58:`TLB_WORD_WIDTH + 65]);
      assign tlb_way0_hi_calc_par[9] = ^(tlb_way0_q[`TLB_WORD_WIDTH + 66:`TLB_WORD_WIDTH + 73]);
      assign tlb_way1_hi_calc_par[0] = ^(tlb_way1_q[`TLB_WORD_WIDTH + 0:`TLB_WORD_WIDTH + 7]);
      assign tlb_way1_hi_calc_par[1] = ^(tlb_way1_q[`TLB_WORD_WIDTH + 8:`TLB_WORD_WIDTH + 15]);
      assign tlb_way1_hi_calc_par[2] = ^(tlb_way1_q[`TLB_WORD_WIDTH + 16:`TLB_WORD_WIDTH + 23]);
      assign tlb_way1_hi_calc_par[3] = ^(tlb_way1_q[`TLB_WORD_WIDTH + 24:`TLB_WORD_WIDTH + 31]);
      assign tlb_way1_hi_calc_par[4] = ^(tlb_way1_q[`TLB_WORD_WIDTH + 32:`TLB_WORD_WIDTH + 39]);
      assign tlb_way1_hi_calc_par[5] = ^(tlb_way1_q[`TLB_WORD_WIDTH + 40:`TLB_WORD_WIDTH + 44]);
      assign tlb_way1_hi_calc_par[6] = ^(tlb_way1_q[`TLB_WORD_WIDTH + 45:`TLB_WORD_WIDTH + 49]);
      assign tlb_way1_hi_calc_par[7] = ^(tlb_way1_q[`TLB_WORD_WIDTH + 50:`TLB_WORD_WIDTH + 57]);
      assign tlb_way1_hi_calc_par[8] = ^(tlb_way1_q[`TLB_WORD_WIDTH + 58:`TLB_WORD_WIDTH + 65]);
      assign tlb_way1_hi_calc_par[9] = ^(tlb_way1_q[`TLB_WORD_WIDTH + 66:`TLB_WORD_WIDTH + 73]);
      assign tlb_way2_hi_calc_par[0] = ^(tlb_way2_q[`TLB_WORD_WIDTH + 0:`TLB_WORD_WIDTH + 7]);
      assign tlb_way2_hi_calc_par[1] = ^(tlb_way2_q[`TLB_WORD_WIDTH + 8:`TLB_WORD_WIDTH + 15]);
      assign tlb_way2_hi_calc_par[2] = ^(tlb_way2_q[`TLB_WORD_WIDTH + 16:`TLB_WORD_WIDTH + 23]);
      assign tlb_way2_hi_calc_par[3] = ^(tlb_way2_q[`TLB_WORD_WIDTH + 24:`TLB_WORD_WIDTH + 31]);
      assign tlb_way2_hi_calc_par[4] = ^(tlb_way2_q[`TLB_WORD_WIDTH + 32:`TLB_WORD_WIDTH + 39]);
      assign tlb_way2_hi_calc_par[5] = ^(tlb_way2_q[`TLB_WORD_WIDTH + 40:`TLB_WORD_WIDTH + 44]);
      assign tlb_way2_hi_calc_par[6] = ^(tlb_way2_q[`TLB_WORD_WIDTH + 45:`TLB_WORD_WIDTH + 49]);
      assign tlb_way2_hi_calc_par[7] = ^(tlb_way2_q[`TLB_WORD_WIDTH + 50:`TLB_WORD_WIDTH + 57]);
      assign tlb_way2_hi_calc_par[8] = ^(tlb_way2_q[`TLB_WORD_WIDTH + 58:`TLB_WORD_WIDTH + 65]);
      assign tlb_way2_hi_calc_par[9] = ^(tlb_way2_q[`TLB_WORD_WIDTH + 66:`TLB_WORD_WIDTH + 73]);
      assign tlb_way3_hi_calc_par[0] = ^(tlb_way3_q[`TLB_WORD_WIDTH + 0:`TLB_WORD_WIDTH + 7]);
      assign tlb_way3_hi_calc_par[1] = ^(tlb_way3_q[`TLB_WORD_WIDTH + 8:`TLB_WORD_WIDTH + 15]);
      assign tlb_way3_hi_calc_par[2] = ^(tlb_way3_q[`TLB_WORD_WIDTH + 16:`TLB_WORD_WIDTH + 23]);
      assign tlb_way3_hi_calc_par[3] = ^(tlb_way3_q[`TLB_WORD_WIDTH + 24:`TLB_WORD_WIDTH + 31]);
      assign tlb_way3_hi_calc_par[4] = ^(tlb_way3_q[`TLB_WORD_WIDTH + 32:`TLB_WORD_WIDTH + 39]);
      assign tlb_way3_hi_calc_par[5] = ^(tlb_way3_q[`TLB_WORD_WIDTH + 40:`TLB_WORD_WIDTH + 44]);
      assign tlb_way3_hi_calc_par[6] = ^(tlb_way3_q[`TLB_WORD_WIDTH + 45:`TLB_WORD_WIDTH + 49]);
      assign tlb_way3_hi_calc_par[7] = ^(tlb_way3_q[`TLB_WORD_WIDTH + 50:`TLB_WORD_WIDTH + 57]);
      assign tlb_way3_hi_calc_par[8] = ^(tlb_way3_q[`TLB_WORD_WIDTH + 58:`TLB_WORD_WIDTH + 65]);
      assign tlb_way3_hi_calc_par[9] = ^(tlb_way3_q[`TLB_WORD_WIDTH + 66:`TLB_WORD_WIDTH + 73]);
      assign tlb_way0_parerr = |(tlb_way0_lo_calc_par[0:9] ^ tlb_way0_q[74:83]) | |(tlb_way0_hi_calc_par[0:9] ^ tlb_way0_q[`TLB_WORD_WIDTH + 74:`TLB_WORD_WIDTH + 83]);
      assign tag4_parerr_d[0] = tlb_way0_parerr;
      assign tlb_way1_parerr = |(tlb_way1_lo_calc_par[0:9] ^ tlb_way1_q[74:83]) | |(tlb_way1_hi_calc_par[0:9] ^ tlb_way1_q[`TLB_WORD_WIDTH + 74:`TLB_WORD_WIDTH + 83]);
      assign tag4_parerr_d[1] = tlb_way1_parerr;
      assign tlb_way2_parerr = |(tlb_way2_lo_calc_par[0:9] ^ tlb_way2_q[74:83]) | |(tlb_way2_hi_calc_par[0:9] ^ tlb_way2_q[`TLB_WORD_WIDTH + 74:`TLB_WORD_WIDTH + 83]);
      assign tag4_parerr_d[2] = tlb_way2_parerr;
      assign tlb_way3_parerr = |(tlb_way3_lo_calc_par[0:9] ^ tlb_way3_q[74:83]) | |(tlb_way3_hi_calc_par[0:9] ^ tlb_way3_q[`TLB_WORD_WIDTH + 74:`TLB_WORD_WIDTH + 83]);
      assign tag4_parerr_d[3] = tlb_way3_parerr;

      assign tlb_tag4_parerr_write = ((xu_mm_xucr4_mmu_mchk_q == 1'b0 & xu_mm_ccr2_notlb_b == 1'b1 & 
                                          ((tlb_tag4_q[`tagpos_type_derat] == 1'b1 | tlb_tag4_q[`tagpos_type_ierat] == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0) & 
                                              |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & tlb_tag4_q[`tagpos_nonspec] == 1'b1 )) ? tag4_parerr_q[0:`TLB_WAYS-1] : 
                                     `TLB_WAYS'b0;
                                     
      assign tlb_tag4_parerr_zeroize = ((xu_mm_xucr4_mmu_mchk_q == 1'b0 & xu_mm_ccr2_notlb_b == 1'b1 & 
                                          ((tlb_tag4_q[`tagpos_type_derat] == 1'b1 | tlb_tag4_q[`tagpos_type_ierat] == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0) & 
                                              |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & tlb_tag4_q[`tagpos_nonspec] == 1'b1 )) ? |(tag4_parerr_q[0:`TLB_WAYS-1]) : 
                                     1'b0;
                                     
      assign tlb_tag5_parerr_zeroize = tlb_tag5_parerr_zeroize_q;
                                     

      assign lru_tag3_dataout_d = lru_dataout;

      assign tlb_tag4_d[0:`tagpos_thdid - 1] = tlb_tag3_q[0:`tagpos_thdid - 1];
      assign tlb_tag4_d[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] = 
                                     (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & (tlb_tag4_q[`tagpos_type_ierat] == 1'b1 | tlb_tag4_q[`tagpos_type_derat] == 1'b1))) ? {`MM_THREADS{1'b0}} : 
                                     (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & (tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbsrx] == 1'b1))) ? {`MM_THREADS{1'b0}} : 
                                     ((tlb_tag4_q[`tagpos_endflag] == 1'b1 & tlb_tag4_q[`tagpos_type_snoop] == 1'b1)) ? {`MM_THREADS{1'b0}} : 
                                     (((tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 | tlb_tag4_q[`tagpos_type_ptereload] == 1'b1) & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1)) ? {`MM_THREADS{1'b0}} : 
                                 tlb_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush));
      generate
         if (`THDID_WIDTH > `MM_THREADS)
         begin : tlbtag4NExist
            assign tlb_tag4_d[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1] = 
                                      (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & (tlb_tag4_q[`tagpos_type_ierat] == 1'b1 | tlb_tag4_q[`tagpos_type_derat] == 1'b1))) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                      (((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | tlb_tag4_q[`tagpos_endflag] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & (tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbsrx] == 1'b1))) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                      ((tlb_tag4_q[`tagpos_endflag] == 1'b1 & tlb_tag4_q[`tagpos_type_snoop] == 1'b1)) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                      (((tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 | tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 | tlb_tag4_q[`tagpos_type_ptereload] == 1'b1) & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1)) ? {`THDID_WIDTH-`MM_THREADS{1'b0}} : 
                                  tlb_tag3_q[`tagpos_thdid + `MM_THREADS:`tagpos_thdid + `THDID_WIDTH - 1];
         end
      endgenerate

      assign tlb_tag4_d[`tagpos_thdid + `THDID_WIDTH:`TLB_TAG_WIDTH - 1] = tlb_tag3_q[`tagpos_thdid + `THDID_WIDTH:`TLB_TAG_WIDTH - 1];
      assign tlb_addr4_d = tlb_addr3_q;


      assign tlb_tag4_way_d       = (tlb_way0_q & {`TLB_WAY_WIDTH{tlb_wayhit[0]}}) | (tlb_way1_q & {`TLB_WAY_WIDTH{tlb_wayhit[1]}});
      
      assign tlb_tag4_way_clone_d = (tlb_way2_q & {`TLB_WAY_WIDTH{tlb_wayhit[2]}}) | (tlb_way3_q & {`TLB_WAY_WIDTH{tlb_wayhit[3]}});
      
      assign tlb_tag4_way_or = tlb_tag4_way_q | tlb_tag4_way_clone_q;

      assign tlb_tag4_way_rw_d = ( tlb_way0_q & ( {`TLB_WAY_WIDTH{(~tlb_tag3_clone1_q[`tagpos_esel + 1]) & (~tlb_tag3_clone1_q[`tagpos_esel + 2]) & |(tlb_tag3_clone1_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) & 
                                                                      (tlb_tag3_clone1_q[`tagpos_type_tlbre] | (tlb_tag3_clone1_q[`tagpos_type_tlbwe] & (~tlb_tag3_clone1_q[`tagpos_hes])))}} ) ) | 
                                                                      
                                   ( tlb_way1_q & ( {`TLB_WAY_WIDTH{(~tlb_tag3_clone1_q[`tagpos_esel + 1]) & tlb_tag3_clone1_q[`tagpos_esel + 2] & |(tlb_tag3_clone1_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) & 
                                                                      (tlb_tag3_clone1_q[`tagpos_type_tlbre] | (tlb_tag3_clone1_q[`tagpos_type_tlbwe] & (~tlb_tag3_clone1_q[`tagpos_hes])))}} ) ) | 
                                                                      
                                   ( tlb_way0_q & ( {`TLB_WAY_WIDTH{(~lru_tag3_dataout_q[4]) & (~lru_tag3_dataout_q[5]) & |(tlb_tag3_clone1_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) & 
                                                                      (tlb_tag3_clone1_q[`tagpos_type_ptereload] | (tlb_tag3_clone1_q[`tagpos_type_tlbwe] & tlb_tag3_clone1_q[`tagpos_hes]))}} ) ) | 
                                                                      
                                   ( tlb_way1_q & ( {`TLB_WAY_WIDTH{(~lru_tag3_dataout_q[4]) & lru_tag3_dataout_q[5] & |(tlb_tag3_clone1_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) & 
                                                                      (tlb_tag3_clone1_q[`tagpos_type_ptereload] | (tlb_tag3_clone1_q[`tagpos_type_tlbwe] & tlb_tag3_clone1_q[`tagpos_hes]))}} ) );
      
      assign tlb_tag4_way_rw_clone_d = ( tlb_way2_q & ( {`TLB_WAY_WIDTH{tlb_tag3_clone2_q[`tagpos_esel + 1] & (~tlb_tag3_clone2_q[`tagpos_esel + 2]) & |(tlb_tag3_clone2_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) & 
                                                                          (tlb_tag3_clone2_q[`tagpos_type_tlbre] | (tlb_tag3_clone2_q[`tagpos_type_tlbwe] & (~tlb_tag3_clone2_q[`tagpos_hes])))}} ) ) | 
                                                                          
                                         ( tlb_way3_q & ( {`TLB_WAY_WIDTH{tlb_tag3_clone2_q[`tagpos_esel + 1] & tlb_tag3_clone2_q[`tagpos_esel + 2] & |(tlb_tag3_clone2_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) & 
                                                                          (tlb_tag3_clone2_q[`tagpos_type_tlbre] | (tlb_tag3_clone2_q[`tagpos_type_tlbwe] & (~tlb_tag3_clone2_q[`tagpos_hes])))}} ) ) | 
                                                                          
                                         ( tlb_way2_q & ( {`TLB_WAY_WIDTH{lru_tag3_dataout_q[4] & (~lru_tag3_dataout_q[6]) & |(tlb_tag3_clone2_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) & 
                                                                          (tlb_tag3_clone2_q[`tagpos_type_ptereload] | (tlb_tag3_clone2_q[`tagpos_type_tlbwe] & tlb_tag3_clone2_q[`tagpos_hes]))}} ) ) | 
                                                                          
                                         ( tlb_way3_q & ( {`TLB_WAY_WIDTH{lru_tag3_dataout_q[4] & lru_tag3_dataout_q[6] & |(tlb_tag3_clone2_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) & 
                                                                          (tlb_tag3_clone2_q[`tagpos_type_ptereload] | (tlb_tag3_clone2_q[`tagpos_type_tlbwe] & tlb_tag3_clone2_q[`tagpos_hes]))}} ) );

      assign tlb_tag4_way_rw_or = tlb_tag4_way_rw_q | tlb_tag4_way_rw_clone_q;

      assign tlb_tag4_wayhit_d[0:`TLB_WAYS - 1] = tlb_wayhit[0:`TLB_WAYS - 1];

      assign tlb_tag4_wayhit_d[`TLB_WAYS] = ((tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b0 & |(tlb_wayhit[0:`TLB_WAYS - 1]) == 1'b1 & |(tlb_tag3_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1)) ? 1'b1 : 
                                           1'b0;

      assign tlb_tag4_way_act = (|(tlb_tag3_clone1_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1])) & (~(tlb_tag4_wayhit_q[`TLB_WAYS])) & (~tlb_tag3_clone1_q[`tagpos_type_ptereload]) & 
                                     (tlb_tag3_clone1_q[`tagpos_type_derat] | tlb_tag3_clone1_q[`tagpos_type_ierat] | tlb_tag3_clone1_q[`tagpos_type_tlbsx] | tlb_tag3_clone1_q[`tagpos_type_tlbsrx]);

      assign tlb_tag4_way_clone_act = (|(tlb_tag3_clone2_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1])) & (~(tlb_tag4_wayhit_q[`TLB_WAYS])) & (~tlb_tag3_clone2_q[`tagpos_type_ptereload]) & 
                                           (tlb_tag3_clone2_q[`tagpos_type_derat] | tlb_tag3_clone2_q[`tagpos_type_ierat] | tlb_tag3_clone2_q[`tagpos_type_tlbsx] | tlb_tag3_clone2_q[`tagpos_type_tlbsrx]);

      assign tlb_tag4_way_rw_act = (|(tlb_tag3_clone1_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1])) & 
                                         (tlb_tag3_clone1_q[`tagpos_type_tlbre] | tlb_tag3_clone1_q[`tagpos_type_tlbwe] | tlb_tag3_clone1_q[`tagpos_type_ptereload]);

      assign tlb_tag4_way_rw_clone_act = (|(tlb_tag3_clone2_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1])) & 
                                              (tlb_tag3_clone2_q[`tagpos_type_tlbre] | tlb_tag3_clone2_q[`tagpos_type_tlbwe] | tlb_tag3_clone2_q[`tagpos_type_ptereload]);

      assign lru_tag4_dataout_d = lru_tag3_dataout_q;
      
      




      assign addr_enable[0] = (|(tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone1_q[`tagpos_type_ptereload])) | 
                                  (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b1011));

      assign addr_enable[1] = (|(tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone1_q[`tagpos_type_ptereload])) | 
                                   (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b1011)) | 
                                   (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & mmucr1_q[pos_tlbi_msb] & tlb_tag3_cmpmask_q[0]);

      assign addr_enable[2] = (|(tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone1_q[`tagpos_type_ptereload])) | 
                                   (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b1011)) | 
                                   (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & mmucr1_q[pos_tlbi_msb] & tlb_tag3_cmpmask_q[1]);

      assign addr_enable[3] = (|(tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone1_q[`tagpos_type_ptereload])) | 
                                  (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b1011)) | 
                                  (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & mmucr1_q[pos_tlbi_msb] & tlb_tag3_cmpmask_q[1]) | 
                                  (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & (~mmucr1_q[pos_tlbi_msb]) & tlb_tag3_cmpmask_q[0]);

      assign addr_enable[4] = (|(tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone1_q[`tagpos_type_ptereload])) | 
                                   (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b1011)) | 
                                   (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & mmucr1_q[pos_tlbi_msb] & tlb_tag3_cmpmask_q[2]) | 
                                   (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & (~mmucr1_q[pos_tlbi_msb]) & tlb_tag3_cmpmask_q[1]);

      assign addr_enable[5] = (|(tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone1_q[`tagpos_type_ptereload])) | 
                                   (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b1011)) | 
                                   (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & mmucr1_q[pos_tlbi_msb] & tlb_tag3_cmpmask_q[3]) | 
                                   (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & (~mmucr1_q[pos_tlbi_msb]) & tlb_tag3_cmpmask_q[2]);

      assign addr_enable[6] = (|(tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone1_q[`tagpos_type_ptereload])) | 
                                   (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b1011)) | 
                                   (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & mmucr1_q[pos_tlbi_msb]) | 
                                   (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & (~mmucr1_q[pos_tlbi_msb]) & tlb_tag3_cmpmask_q[3]);

      assign addr_enable[7] = (|(tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone1_q[`tagpos_type_ptereload])) | 
                                   (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011));
                                   
      assign addr_enable[8] = (|(tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone1_q[`tagpos_type_ptereload])) | 
                                  (tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011));

      assign class_enable = ((tlb_tag3_clone1_q[`tagpos_type_snoop] == 1'b1 & tlb_tag3_clone1_q[`tagpos_is + 1] == 1'b1)) ? 1'b1 : 
                            1'b0;
                            
      assign pgsize_enable = tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011);

      assign extclass_enable = 2'b00;


      assign thdid_enable = (|(tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx])) & (~tlb_tag3_clone1_q[`tagpos_type_ptereload]);

      assign pid_enable = ((tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx] != 4'b0000 & tlb_tag3_clone1_q[`tagpos_type_ptereload] == 1'b0)) ? 1'b1 : 
                          ((tlb_tag3_clone1_q[`tagpos_type_snoop] == 1'b1 & tlb_tag3_clone1_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b001)) ? 1'b1 : 
                          ((tlb_tag3_clone1_q[`tagpos_type_snoop] == 1'b1 & tlb_tag3_clone1_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011)) ? 1'b1 : 
                          1'b0;
      assign state_enable[0] = ((tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx] != 4'b0000 & tlb_tag3_clone1_q[`tagpos_type_ptereload] == 1'b0)) ? 1'b1 : 
                               ((tlb_tag3_clone1_q[`tagpos_type_snoop] == 1'b1 & tlb_tag3_clone1_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b010)) ? 1'b1 : 
                               ((tlb_tag3_clone1_q[`tagpos_type_snoop] == 1'b1 & tlb_tag3_clone1_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011)) ? 1'b1 : 
                               1'b0;
      assign state_enable[1] = ((tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx] != 4'b0000 & tlb_tag3_clone1_q[`tagpos_type_ptereload] == 1'b0)) ? 1'b1 : 
                               ((tlb_tag3_clone1_q[`tagpos_type_snoop] == 1'b1 & tlb_tag3_clone1_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011)) ? 1'b1 : 
                               1'b0;
      assign lpid_enable = ((tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx] != 4'b0000 & tlb_tag3_clone1_q[`tagpos_type_ptereload] == 1'b0)) ? 1'b1 : 
                           ((tlb_tag3_clone1_q[`tagpos_type_snoop] == 1'b1)) ? (~(tlb_tag3_clone1_q[`tagpos_hes])) : 
                           1'b0;
      assign ind_enable = ( |(tlb_tag3_clone1_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone1_q[`tagpos_type_ptereload]) ) | 
                               ( tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011) ) | 
                                ( tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b001) & tlb_tag3_clone1_q[`tagpos_ind] );

      assign iprot_enable = tlb_tag3_clone1_q[`tagpos_type_snoop];

      assign comp_extclass = 2'b00;

      assign comp_iprot = 1'b0;

      assign comp_ind = tlb_tag3_clone1_q[`tagpos_ind] & (~(tlb_tag3_clone1_q[`tagpos_type_snoop] & (tlb_tag3_clone1_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b001)));

      assign addr_enable_clone[0] = (|(tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone2_q[`tagpos_type_ptereload])) | 
                                        (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b1011));
      
      assign addr_enable_clone[1] = (|(tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone2_q[`tagpos_type_ptereload])) | 
                                        (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b1011)) | 
                                        (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & mmucr1_clone_q[pos_tlbi_msb] & tlb_tag3_cmpmask_clone_q[0]);
      
      assign addr_enable_clone[2] = (|(tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone2_q[`tagpos_type_ptereload])) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b1011)) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & mmucr1_clone_q[pos_tlbi_msb] & tlb_tag3_cmpmask_clone_q[1]);
      
      assign addr_enable_clone[3] = (|(tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone2_q[`tagpos_type_ptereload])) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b1011)) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & mmucr1_clone_q[pos_tlbi_msb] & tlb_tag3_cmpmask_clone_q[1]) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & (~mmucr1_clone_q[pos_tlbi_msb]) & tlb_tag3_cmpmask_clone_q[0]);
      
      assign addr_enable_clone[4] = (|(tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone2_q[`tagpos_type_ptereload])) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b1011)) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & mmucr1_clone_q[pos_tlbi_msb] & tlb_tag3_cmpmask_clone_q[2]) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & (~mmucr1_clone_q[pos_tlbi_msb]) & tlb_tag3_cmpmask_clone_q[1]);
      
      assign addr_enable_clone[5] = (|(tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone2_q[`tagpos_type_ptereload])) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b1011)) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & mmucr1_clone_q[pos_tlbi_msb] & tlb_tag3_cmpmask_clone_q[3]) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & (~mmucr1_clone_q[pos_tlbi_msb]) & tlb_tag3_cmpmask_clone_q[2]);
      
      assign addr_enable_clone[6] = (|(tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone2_q[`tagpos_type_ptereload])) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b1011)) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & mmucr1_clone_q[pos_tlbi_msb]) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & (~mmucr1_clone_q[pos_tlbi_msb]) & tlb_tag3_cmpmask_clone_q[3]);
      
      assign addr_enable_clone[7] = (|(tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone2_q[`tagpos_type_ptereload])) | 
                                         (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011));
      
      assign addr_enable_clone[8] = (|(tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone2_q[`tagpos_type_ptereload])) | 
                                        (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011));
    
      assign class_enable_clone = ((tlb_tag3_clone2_q[`tagpos_type_snoop] == 1'b1 & tlb_tag3_clone2_q[`tagpos_is + 1] == 1'b1)) ? 1'b1 : 
                                  1'b0;
    
      assign pgsize_enable_clone = tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011);
    
      assign extclass_enable_clone = 2'b00;
    
      assign thdid_enable_clone = (|(tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx])) & (~tlb_tag3_clone2_q[`tagpos_type_ptereload]);
   
      assign pid_enable_clone = ((tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx] != 4'b0000 & tlb_tag3_clone2_q[`tagpos_type_ptereload] == 1'b0)) ? 1'b1 : 
                                ((tlb_tag3_clone2_q[`tagpos_type_snoop] == 1'b1 & tlb_tag3_clone2_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b001)) ? 1'b1 : 
                                ((tlb_tag3_clone2_q[`tagpos_type_snoop] == 1'b1 & tlb_tag3_clone2_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011)) ? 1'b1 : 
                                1'b0;
      assign state_enable_clone[0] = ((tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx] != 4'b0000 & tlb_tag3_clone2_q[`tagpos_type_ptereload] == 1'b0)) ? 1'b1 : 
                                     ((tlb_tag3_clone2_q[`tagpos_type_snoop] == 1'b1 & tlb_tag3_clone2_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b010)) ? 1'b1 : 
                                     ((tlb_tag3_clone2_q[`tagpos_type_snoop] == 1'b1 & tlb_tag3_clone2_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011)) ? 1'b1 : 
                                     1'b0;
      assign state_enable_clone[1] = ((tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx] != 4'b0000 & tlb_tag3_clone2_q[`tagpos_type_ptereload] == 1'b0)) ? 1'b1 : 
                                     ((tlb_tag3_clone2_q[`tagpos_type_snoop] == 1'b1 & tlb_tag3_clone2_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011)) ? 1'b1 : 
                                     1'b0;
      assign lpid_enable_clone = ((tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx] != 4'b0000 & tlb_tag3_clone2_q[`tagpos_type_ptereload] == 1'b0)) ? 1'b1 : 
                                 ((tlb_tag3_clone2_q[`tagpos_type_snoop] == 1'b1)) ? (~(tlb_tag3_clone2_q[`tagpos_hes])) : 
                                 1'b0;
   
      assign ind_enable_clone = (|(tlb_tag3_clone2_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag3_clone2_q[`tagpos_type_ptereload])) | 
                                   (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011)) | 
                                   (tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b001) & tlb_tag3_clone2_q[`tagpos_ind]);
  
      assign iprot_enable_clone = tlb_tag3_clone2_q[`tagpos_type_snoop];

      assign comp_extclass_clone = 2'b00;

      assign comp_iprot_clone = 1'b0;

      assign comp_ind_clone = tlb_tag3_clone2_q[`tagpos_ind] & (~(tlb_tag3_clone2_q[`tagpos_type_snoop] & (tlb_tag3_clone2_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b001)));



      assign tlb_tag4_type_sig[0:7] = tlb_tag4_q[`tagpos_type:`tagpos_type + 7];
      assign tlb_tag4_esel_sig[0:2] = tlb_tag4_q[`tagpos_esel:`tagpos_esel + 2];
      assign tlb_tag4_hes_sig = tlb_tag4_q[`tagpos_hes];
      assign tlb_tag4_wq_sig[0:1] = tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1];
      assign tlb_tag4_is_sig[0:3] = tlb_tag4_q[`tagpos_is:`tagpos_is + 3];
      assign tlb_tag4_hv_op = |((~msr_gs_q) & (~msr_pr_q) & tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1]);
      
      assign multihit = (~((tlb_tag4_wayhit_q[0:3] == 4'b0000) | (tlb_tag4_wayhit_q[0:3] == 4'b1000) | 
                             (tlb_tag4_wayhit_q[0:3] == 4'b0100) | (tlb_tag4_wayhit_q[0:3] == 4'b0010) | 
                             (tlb_tag4_wayhit_q[0:3] == 4'b0001))) & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]);

      
      assign tlb_tag4_hes1_mas1_v[0:`THDID_WIDTH - 1] = ( ({tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[1:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & (~lru_tag4_dataout_q[5]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[2:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & lru_tag4_dataout_q[5])}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:1], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & (~lru_tag4_dataout_q[6]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:2], tlb_tag4_q[`tagpos_is]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & lru_tag4_dataout_q[6])}} ) | 
                                                          
                                                          ( ({tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[1:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & (~lru_tag4_dataout_q[5]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[2:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & lru_tag4_dataout_q[5])}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:1], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & (~lru_tag4_dataout_q[6]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:2], tlb_tag4_q[`tagpos_is]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & lru_tag4_dataout_q[6])}} ) | 
                                                          
                                                          ( ({tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[1:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & (~lru_tag4_dataout_q[5]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[2:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & lru_tag4_dataout_q[5])}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:1], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & (~lru_tag4_dataout_q[6]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:2], tlb_tag4_q[`tagpos_is]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & lru_tag4_dataout_q[6])}} ) | 
                                                          
                                                          ( ({tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[1:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & (~lru_tag4_dataout_q[5]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[2:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & lru_tag4_dataout_q[5])}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:1], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & (~lru_tag4_dataout_q[6]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:2], tlb_tag4_q[`tagpos_is]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & lru_tag4_dataout_q[6])}} );
      assign tlb_tag4_hes0_mas1_v[0:`THDID_WIDTH - 1] = ( ({tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[1:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[2:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & tlb_tag4_q[`tagpos_esel + 2])}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:1], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:2], tlb_tag4_q[`tagpos_is]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & tlb_tag4_q[`tagpos_esel + 2])}} ) | 
                                                          
                                                          ( ({tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[1:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[2:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & tlb_tag4_q[`tagpos_esel + 2])}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:1], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:2], tlb_tag4_q[`tagpos_is]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & tlb_tag4_q[`tagpos_esel + 2])}} ) | 
                                                          
                                                          ( ({tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[1:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[2:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & tlb_tag4_q[`tagpos_esel + 2])}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:1], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:2], tlb_tag4_q[`tagpos_is]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & tlb_tag4_q[`tagpos_esel + 2])}} ) |
                                                           
                                                          ( ({tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[1:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[2:3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & tlb_tag4_q[`tagpos_esel + 2])}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:1], tlb_tag4_q[`tagpos_is], lru_tag4_dataout_q[3]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                          ( ({lru_tag4_dataout_q[0:2], tlb_tag4_q[`tagpos_is]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & tlb_tag4_q[`tagpos_esel + 2])}} );

      
      assign tlb_tag4_hes1_mas1_iprot[0:`THDID_WIDTH - 1] = ( ({tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[9:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & (~lru_tag4_dataout_q[5]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[10:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & lru_tag4_dataout_q[5])}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:9], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & (~lru_tag4_dataout_q[6]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:10], tlb_tag4_q[`tagpos_is + 1]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & lru_tag4_dataout_q[6])}} ) | 
                                                              
                                                              ( ({tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[9:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & (~lru_tag4_dataout_q[5]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[10:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & lru_tag4_dataout_q[5])}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:9], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & (~lru_tag4_dataout_q[6]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:10], tlb_tag4_q[`tagpos_is + 1]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & lru_tag4_dataout_q[6])}} ) | 
                                                              
                                                              ( ({tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[9:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & (~lru_tag4_dataout_q[5]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[10:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & lru_tag4_dataout_q[5])}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:9], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & (~lru_tag4_dataout_q[6]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:10], tlb_tag4_q[`tagpos_is + 1]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & lru_tag4_dataout_q[6])}} ) | 
                                                              
                                                              ( ({tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[9:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & (~lru_tag4_dataout_q[5]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[10:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & tlb_tag4_q[`tagpos_hes] & (~lru_tag4_dataout_q[4]) & lru_tag4_dataout_q[5])}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:9], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & (~lru_tag4_dataout_q[6]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:10], tlb_tag4_q[`tagpos_is + 1]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & tlb_tag4_q[`tagpos_hes] & lru_tag4_dataout_q[4] & lru_tag4_dataout_q[6])}} );
                                                              
      assign tlb_tag4_hes0_mas1_iprot[0:`THDID_WIDTH - 1] = ( ({tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[9:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[10:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & tlb_tag4_q[`tagpos_esel + 2])}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:9], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:10], tlb_tag4_q[`tagpos_is + 1]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 0] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & tlb_tag4_q[`tagpos_esel + 2])}} ) | 
                                                              
                                                              ( ({tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[9:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[10:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & tlb_tag4_q[`tagpos_esel + 2])}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:9], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:10], tlb_tag4_q[`tagpos_is + 1]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 1] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & tlb_tag4_q[`tagpos_esel + 2])}} ) | 

                                                              ( ({tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[9:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[10:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & tlb_tag4_q[`tagpos_esel + 2])}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:9], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:10], tlb_tag4_q[`tagpos_is + 1]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 2] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & tlb_tag4_q[`tagpos_esel + 2])}} ) | 

                                                              ( ({tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[9:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[10:11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & (~tlb_tag4_q[`tagpos_hes]) & (~tlb_tag4_q[`tagpos_esel + 1]) & tlb_tag4_q[`tagpos_esel + 2])}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:9], tlb_tag4_q[`tagpos_is + 1], lru_tag4_dataout_q[11]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & (~tlb_tag4_q[`tagpos_esel + 2]))}} ) | 
                                                              ( ({lru_tag4_dataout_q[8:10], tlb_tag4_q[`tagpos_is + 1]}) & {`THDID_WIDTH{(tlb_tag4_q[`tagpos_thdid + 3] & (~tlb_tag4_q[`tagpos_hes]) & tlb_tag4_q[`tagpos_esel + 1] & tlb_tag4_q[`tagpos_esel + 2])}} );

      assign tlb_tag4_ptereload_v[0:`THDID_WIDTH - 1] = ((lru_tag4_dataout_q[4:5] == 2'b00)) ? ({ptereload_req_pte_lat[`ptepos_valid], lru_tag4_dataout_q[1:3]}) : 
                                                       ((lru_tag4_dataout_q[4:5] == 2'b01)) ? ({lru_tag4_dataout_q[0], ptereload_req_pte_lat[`ptepos_valid], lru_tag4_dataout_q[2:3]}) : 
                                                       ((lru_tag4_dataout_q[4] == 1'b1 & lru_tag4_dataout_q[6] == 1'b0)) ? ({lru_tag4_dataout_q[0:1], ptereload_req_pte_lat[`ptepos_valid], lru_tag4_dataout_q[3]}) : 
                                                       ((lru_tag4_dataout_q[4] == 1'b1 & lru_tag4_dataout_q[6] == 1'b1)) ? ({lru_tag4_dataout_q[0:2], ptereload_req_pte_lat[`ptepos_valid]}) : 
                                                       lru_tag4_dataout_q[0:3];
      assign tlb_tag4_ptereload_iprot[0:`THDID_WIDTH - 1] = ((lru_tag4_dataout_q[4:5] == 2'b00)) ? ({1'b0, lru_tag4_dataout_q[9:11]}) : 
                                                           ((lru_tag4_dataout_q[4:5] == 2'b01)) ? ({lru_tag4_dataout_q[8], 1'b0, lru_tag4_dataout_q[10:11]}) : 
                                                           ((lru_tag4_dataout_q[4] == 1'b1 & lru_tag4_dataout_q[6] == 1'b0)) ? ({lru_tag4_dataout_q[8:9], 1'b0, lru_tag4_dataout_q[11]}) : 
                                                           ((lru_tag4_dataout_q[4] == 1'b1 & lru_tag4_dataout_q[6] == 1'b1)) ? ({lru_tag4_dataout_q[8:10], 1'b0}) : 
                                                           lru_tag4_dataout_q[8:11];
                                                           
      assign lru_write_d = (  (tlb_tag4_q[`tagpos_type_derat] == 1'b1 | tlb_tag4_q[`tagpos_type_ierat] == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & 
                                 |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & 
                                  ((|(tlb_tag4_wayhit_q[0:`TLB_WAYS - 1]) == 1'b1 & multihit == 1'b0 & |(tag4_parerr_q[0:4]) == 1'b0) | 
                                      (xu_mm_xucr4_mmu_mchk_q == 1'b0 & xu_mm_ccr2_notlb_b == 1'b1 & tlb_tag4_q[`tagpos_nonspec] == 1'b1 & 
                                        (multihit == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1)))  ) ? {`LRU_WIDTH{1'b1}} : 
                              ( tlb_tag4_q[`tagpos_type_snoop] == 1'b1 & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & 
                                (|(tlb_tag4_wayhit_q[0:`TLB_WAYS - 1]) == 1'b1 | tlb_tag4_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b000) ) ? {`LRU_WIDTH{1'b1}} : 
                              ( tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_pr] == 1'b0 & ex6_illeg_instr[1] == 1'b0 & 
                                |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~tlb_ctl_tag4_flush)) == 1'b1 & 
                                 ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & tlb_resv_match_vec) == 1'b1 & 
                                       tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b01 & mmucfg_twc == 1'b1) | tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b00 | 
                                       tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b11) & ((tlb_tag4_q[`tagpos_gs] == 1'b0 & tlb_tag4_q[`tagpos_atsel] == 1'b0) | 
                                       (tlb_tag4_q[`tagpos_gs] == 1'b1 & tlb_tag4_q[`tagpos_hes] == 1'b1 & tlb_tag4_q[`tagpos_is + 1] == 1'b0 & tlb0cfg_gtwe == 1'b1 & 
                                        tlb_tag4_epcr_dgtmi == 1'b0 & lrat_tag4_hit_status == 4'b1100 & 
                                        (((lru_tag4_dataout_q[0] == 1'b0 | lru_tag4_dataout_q[8] == 1'b0) & lru_tag4_dataout_q[4:5] == 2'b00) | 
                                         ((lru_tag4_dataout_q[1] == 1'b0 | lru_tag4_dataout_q[9] == 1'b0) & lru_tag4_dataout_q[4:5] == 2'b01) | 
                                         ((lru_tag4_dataout_q[2] == 1'b0 | lru_tag4_dataout_q[10] == 1'b0) & lru_tag4_dataout_q[4] == 1'b1 & lru_tag4_dataout_q[6] == 1'b0) | 
                                         ((lru_tag4_dataout_q[3] == 1'b0 | lru_tag4_dataout_q[11] == 1'b0) & lru_tag4_dataout_q[4] == 1'b1 & lru_tag4_dataout_q[6] == 1'b1)))) ) ? {`LRU_WIDTH{1'b1}} : 
                              ( tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & (|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1) & 
                                 (tlb_tag4_q[`tagpos_gs] == 1'b0 | (tlb_tag4_q[`tagpos_gs] == 1'b1 & lrat_tag4_hit_status == 4'b1100)) & 
                                 (tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b10) & (tlb_tag4_q[`tagpos_pt] == 1'b1) & 
                                 (((lru_tag4_dataout_q[0] == 1'b0 | lru_tag4_dataout_q[8] == 1'b0) & lru_tag4_dataout_q[4:5] == 2'b00) | 
                                 ((lru_tag4_dataout_q[1] == 1'b0 | lru_tag4_dataout_q[9] == 1'b0) & lru_tag4_dataout_q[4:5] == 2'b01) | 
                                 ((lru_tag4_dataout_q[2] == 1'b0 | lru_tag4_dataout_q[10] == 1'b0) & lru_tag4_dataout_q[4] == 1'b1 & lru_tag4_dataout_q[6] == 1'b0) | 
                                 ((lru_tag4_dataout_q[3] == 1'b0 | lru_tag4_dataout_q[11] == 1'b0) & lru_tag4_dataout_q[4] == 1'b1 & lru_tag4_dataout_q[6] == 1'b1)) ) ? {`LRU_WIDTH{ptereload_req_pte_lat[`ptepos_valid]}} : 
                              {`LRU_WIDTH{1'b0}};
                              
      assign lru_wr_addr_d = tlb_addr4_q;
   

      assign lru_update_clear_enab = ((xu_mm_xucr4_mmu_mchk_q == 1'b0 & xu_mm_ccr2_notlb_b == 1'b1 & 
                                          ((tlb_tag4_q[`tagpos_type_derat] == 1'b1 | tlb_tag4_q[`tagpos_type_ierat] == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0) & 
                                             tlb_tag4_q[`tagpos_nonspec] == 1'b1 & (multihit == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1))) ? 1'b1 : 
                                     1'b0;
                                     
      assign lru_update_data_enab = ( ((tlb_tag4_q[`tagpos_type_derat] == 1'b1 | tlb_tag4_q[`tagpos_type_ierat] == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & 
                                           multihit == 1'b0 & |(tag4_parerr_q[0:4]) == 1'b0) | 
                                            (tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & (tlb_tag4_q[`tagpos_atsel] == 1'b0 | tlb_tag4_q[`tagpos_gs] == 1'b1)) | 
                                              (tlb_tag4_q[`tagpos_type_ptereload] == 1'b1) | (tlb_tag4_q[`tagpos_type_snoop] == 1'b1) ) ? 1'b1 : 
                                    1'b0;
      assign lru_datain_d[0:3] = (lru_update_clear_enab == 1'b1) ? {4{1'b0}} : 
                                 (tlb_tag4_q[`tagpos_type_snoop] == 1'b1) ? (lru_tag4_dataout_q[0:3] & (lru_tag4_dataout_q[8:11] | (~(tlb_tag4_wayhit_q[0:3])))) : 
                                 (tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_hes] == 1'b1) ? tlb_tag4_hes1_mas1_v[0:`THDID_WIDTH - 1] : 
                                 (tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_hes] == 1'b0) ? tlb_tag4_hes0_mas1_v[0:`THDID_WIDTH - 1] : 
                                 (tlb_tag4_q[`tagpos_type_ptereload] == 1'b1) ? tlb_tag4_ptereload_v[0:`THDID_WIDTH - 1] : 
                                 lru_tag4_dataout_q[0:3];
      assign lru_datain_d[4:6] = (lru_update_clear_enab == 1'b1) ? {3{1'b0}} : 
                                 (lru_update_data_enab == 1'b1) ? lru_update_data : 
                                 lru_tag4_dataout_q[4:6];

      assign lru_datain_alt_d[4:6] = (((tlb_tag4_q[`tagpos_type_derat] == 1'b1 | tlb_tag4_q[`tagpos_type_ierat] == 1'b1 | tlb_tag4_q[`tagpos_type_snoop] == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0)) ? lru_update_data_alt : 
                                     ((tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & (tlb_tag4_q[`tagpos_atsel] == 1'b0 | tlb_tag4_q[`tagpos_gs] == 1'b1))) ? lru_update_data : 
                                     ((tlb_tag4_q[`tagpos_type_ptereload] == 1'b1)) ? lru_update_data : 
                                     lru_tag4_dataout_q[4:6];

      assign lru_update_data_alt = ( lru_tag4_dataout_q[4:6] & {3{(~tlb_tag4_wayhit_q[4])}} ) | 
                                     ( lru_update_data_snoophit_eco & {3{(tlb_tag4_wayhit_q[4] & tlb_tag4_q[`tagpos_type_snoop])}} ) | 
                                     ( lru_update_data_erathit_eco & {3{(tlb_tag4_wayhit_q[4] & (~tlb_tag4_q[`tagpos_type_ptereload]) & (tlb_tag4_q[`tagpos_type_derat] | tlb_tag4_q[`tagpos_type_ierat]))}} );

      assign lru_datain_alt_d[7] = ^({lru_datain_d[0:3], lru_datain_alt_d[4:6]});

      assign lru_update_data_snoophit_eco[0:2] = ((tlb_tag4_wayhit_q[0] & (~lru_tag4_dataout_q[6]) & (~lru_tag4_dataout_q[8])) == 1'b1) ? 3'b000 : 
                                                 ((tlb_tag4_wayhit_q[0] & lru_tag4_dataout_q[6] & (~lru_tag4_dataout_q[8])) == 1'b1) ? 3'b001 : 
                                                 ((tlb_tag4_wayhit_q[1] & (~lru_tag4_dataout_q[6]) & (~lru_tag4_dataout_q[9])) == 1'b1) ? 3'b010 : 
                                                 ((tlb_tag4_wayhit_q[1] & lru_tag4_dataout_q[6] & (~lru_tag4_dataout_q[9])) == 1'b1) ? 3'b011 : 
                                                 ((tlb_tag4_wayhit_q[2] & (~lru_tag4_dataout_q[5]) & (~lru_tag4_dataout_q[10])) == 1'b1) ? 3'b100 : 
                                                 ((tlb_tag4_wayhit_q[2] & lru_tag4_dataout_q[5] & (~lru_tag4_dataout_q[10])) == 1'b1) ? 3'b110 : 
                                                 ((tlb_tag4_wayhit_q[3] & (~lru_tag4_dataout_q[5]) & (~lru_tag4_dataout_q[11])) == 1'b1) ? 3'b101 : 
                                                 ((tlb_tag4_wayhit_q[3] & lru_tag4_dataout_q[5] & (~lru_tag4_dataout_q[11])) == 1'b1) ? 3'b111 : 
                                                 lru_tag4_dataout_q[4:6];

      assign lru_datain_alt_d[8] = ^({lru_datain_d[0:3], lru_update_data_snoophit_eco[0:2]});

      assign lru_update_data_erathit_eco[0:2] = ((tlb_tag4_wayhit_q[0] & (~lru_tag4_dataout_q[9])) == 1'b1) ? {2'b01, lru_tag4_dataout_q[6]} : 
                                                ((tlb_tag4_wayhit_q[0] & (~lru_tag4_dataout_q[10])) == 1'b1) ? {1'b1, lru_tag4_dataout_q[5], 1'b0} : 
                                                ((tlb_tag4_wayhit_q[0] & (~lru_tag4_dataout_q[11])) == 1'b1) ? {1'b1, lru_tag4_dataout_q[5], 1'b1} : 
                                                ((tlb_tag4_wayhit_q[1] & (~lru_tag4_dataout_q[10])) == 1'b1) ? {1'b1, lru_tag4_dataout_q[5], 1'b0} : 
                                                ((tlb_tag4_wayhit_q[1] & (~lru_tag4_dataout_q[11])) == 1'b1) ? {1'b1, lru_tag4_dataout_q[5], 1'b1} : 
                                                ((tlb_tag4_wayhit_q[1] & (~lru_tag4_dataout_q[8])) == 1'b1) ? {2'b00, lru_tag4_dataout_q[6]} : 
                                                ((tlb_tag4_wayhit_q[2] & (~lru_tag4_dataout_q[11])) == 1'b1) ? {1'b1, lru_tag4_dataout_q[5], 1'b1} : 
                                                ((tlb_tag4_wayhit_q[2] & (~lru_tag4_dataout_q[8])) == 1'b1) ? {2'b00, lru_tag4_dataout_q[6]} : 
                                                ((tlb_tag4_wayhit_q[2] & (~lru_tag4_dataout_q[9])) == 1'b1) ? {2'b01, lru_tag4_dataout_q[6]} : 
                                                ((tlb_tag4_wayhit_q[3] & (~lru_tag4_dataout_q[8])) == 1'b1) ? {2'b00, lru_tag4_dataout_q[6]} : 
                                                ((tlb_tag4_wayhit_q[3] & (~lru_tag4_dataout_q[9])) == 1'b1) ? {2'b01, lru_tag4_dataout_q[6]} : 
                                                ((tlb_tag4_wayhit_q[3] & (~lru_tag4_dataout_q[10])) == 1'b1) ? {1'b1, lru_tag4_dataout_q[5], 1'b0} : 
                                                lru_tag4_dataout_q[4:6];
                                                
      assign lru_datain_alt_d[9] = ^({lru_datain_d[0:3], lru_update_data_erathit_eco[0:2]});

      assign lru_datain_d[8:11] = (lru_update_clear_enab == 1'b1) ? {4{1'b0}} : 
                                  (tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_hes] == 1'b1) ? tlb_tag4_hes1_mas1_iprot[0:`THDID_WIDTH - 1] : 
                                  (tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_hes] == 1'b0) ? tlb_tag4_hes0_mas1_iprot[0:`THDID_WIDTH - 1] : 
                                  (tlb_tag4_q[`tagpos_type_ptereload] == 1'b1) ? tlb_tag4_ptereload_iprot[0:`THDID_WIDTH - 1] : 
                                  lru_tag4_dataout_q[8:11];

      assign lru_datain_d[12:14] = {3{1'b0}};

      assign lru_datain_d[7] = ^(lru_datain_d[0:6]);
      assign lru_datain_d[15] = ^({lru_datain_d[8:14], (mmucr1_q[pos_lru_pei] & tlb_tag4_q[`tagpos_type_tlbwe])});  

      assign lru_calc_par[0] = ^(lru_tag3_dataout_q[0:6]);
      assign lru_calc_par[1] = ^(lru_tag3_dataout_q[8:14]);
      
      assign tag4_parerr_d[`TLB_WAYS] = |( lru_calc_par[0:1] ^ {lru_tag3_dataout_q[7], lru_tag3_dataout_q[15]} );

      assign tlb_tag4_parerr_enab = |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) & |(tlb_tag4_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) | tlb_tag4_q[`tagpos_type_tlbre];

      
      
      
/*
?TABLE lru_update_data LISTING(final) OPTIMIZE PARMS(ON-SET, OFF-SET);
*INPUTS*============================================*OUTPUTS*=============*
|                                                   |                     |
| tlb_tag4_type_sig                                 |  lru_update_data    |
| |        tlb_tag4_hes_sig                         |  |                  |
| |        | tlb_tag4_esel_sig                      |  |                  |
| |        | |   tlb_tag4_wq_sig                    |  |                  |
| |        | |   |  tlb_tag4_is_sig                 |  |                  |
| |        | |   |  |    tlb_tag4_wayhit_q          |  |                  |
| |        | |   |  |    |    lru_tag4_dataout_q    |  |                  |
| |        | |   |  |    |    |                     |  |                  |
| |        | |   |  |    |    |                     |  |                  |
| |        | |   |  |    |    |         111111      |  |                  |
| 01234567 | 012 01 0123 0123 0123456789012345      |  012                |
*TYPE*==============================================+=====================+
| PPPPPPPP P PPP PP PPPP PPPP PPPPPPPPPPPPPPPP      |  PPP                |
*OPTIMIZE*----------------------------------------->|  AAA                |
*TERMS*=============================================+=====================+
| 10000000 - --- -- ---- ---- 0-----0---------      |  000                | derat nonvalid ways
| 10000000 - --- -- ---- ---- 0-----1---------      |  001                |
| 10000000 - --- -- ---- ---- 10----0---------      |  010                | 
| 10000000 - --- -- ---- ---- 10----1---------      |  011                | 
| 10000000 - --- -- ---- ---- 110--0----------      |  100                | 
| 10000000 - --- -- ---- ---- 110--1----------      |  110                | 
| 10000000 - --- -- ---- ---- 1110-0----------      |  101                | 
| 10000000 - --- -- ---- ---- 1110-1----------      |  111                | 
| 10000000 - --- -- ---- 0000 1111000---------      |  000                | derat cc full, no hit, no lru change
| 10000000 - --- -- ---- 0000 1111001---------      |  001                | 
| 10000000 - --- -- ---- 0000 1111010---------      |  010                | 
| 10000000 - --- -- ---- 0000 1111011---------      |  011                |  
| 10000000 - --- -- ---- 0000 1111100---------      |  100                |  
| 10000000 - --- -- ---- 0000 1111101---------      |  101                |  
| 10000000 - --- -- ---- 0000 1111110---------      |  110                |  
| 10000000 - --- -- ---- 0000 1111111---------      |  111                |  
| 10000000 - --- -- ---- 1000 1111--0-0000----      |  110                | derat cc full, hit way0 (multihits don't write lru)
| 10000000 - --- -- ---- 1000 1111--0-0001----      |  110                | 
| 10000000 - --- -- ---- 1000 1111--0-0010----      |  111                | 
| 10000000 - --- -- ---- 1000 1111--0-0011----      |  010                | 
| 10000000 - --- -- ---- 1000 1111--0-0100----      |  100                | 
| 10000000 - --- -- ---- 1000 1111--0-0101----      |  100                | 
| 10000000 - --- -- ---- 1000 1111--0-0110----      |  101                | 
| 10000000 - --- -- ---- 1000 1111--0-0111----      |  000                | 
| 10000000 - --- -- ---- 1000 1111--0-1000----      |  110                |
| 10000000 - --- -- ---- 1000 1111--0-1001----      |  110                | 
| 10000000 - --- -- ---- 1000 1111--0-1010----      |  111                | 
| 10000000 - --- -- ---- 1000 1111--0-1011----      |  010                | 
| 10000000 - --- -- ---- 1000 1111--0-1100----      |  110                | 
| 10000000 - --- -- ---- 1000 1111--0-1101----      |  110                | 
| 10000000 - --- -- ---- 1000 1111--0-1110----      |  111                | 
| 10000000 - --- -- ---- 1000 1111--0-1111----      |  110                |
| 10000000 - --- -- ---- 1000 1111--1-0000----      |  111                |
| 10000000 - --- -- ---- 1000 1111--1-0001----      |  110                | 
| 10000000 - --- -- ---- 1000 1111--1-0010----      |  111                | 
| 10000000 - --- -- ---- 1000 1111--1-0011----      |  011                | 
| 10000000 - --- -- ---- 1000 1111--1-0100----      |  101                | 
| 10000000 - --- -- ---- 1000 1111--1-0101----      |  100                | 
| 10000000 - --- -- ---- 1000 1111--1-0110----      |  101                | 
| 10000000 - --- -- ---- 1000 1111--1-0111----      |  001                | 
| 10000000 - --- -- ---- 1000 1111--1-1000----      |  111                |
| 10000000 - --- -- ---- 1000 1111--1-1001----      |  110                | 
| 10000000 - --- -- ---- 1000 1111--1-1010----      |  111                | 
| 10000000 - --- -- ---- 1000 1111--1-1011----      |  011                | 
| 10000000 - --- -- ---- 1000 1111--1-1100----      |  111                | 
| 10000000 - --- -- ---- 1000 1111--1-1101----      |  110                | 
| 10000000 - --- -- ---- 1000 1111--1-1110----      |  111                | 
| 10000000 - --- -- ---- 1000 1111--1-1111----      |  111                | 
| 10000000 - --- -- ---- 0100 1111--0-0000----      |  100                | derat cc full, hit way1
| 10000000 - --- -- ---- 0100 1111--0-0001----      |  100                | 
| 10000000 - --- -- ---- 0100 1111--0-0010----      |  101                | 
| 10000000 - --- -- ---- 0100 1111--0-0011----      |  000                | 
| 10000000 - --- -- ---- 0100 1111--0-0100----      |  100                | 
| 10000000 - --- -- ---- 0100 1111--0-0101----      |  100                | 
| 10000000 - --- -- ---- 0100 1111--0-0110----      |  101                | 
| 10000000 - --- -- ---- 0100 1111--0-0111----      |  000                | 
| 10000000 - --- -- ---- 0100 1111--0-1000----      |  110                |
| 10000000 - --- -- ---- 0100 1111--0-1001----      |  110                | 
| 10000000 - --- -- ---- 0100 1111--0-1010----      |  111                | 
| 10000000 - --- -- ---- 0100 1111--0-1011----      |  010                |
| 10000000 - --- -- ---- 0100 1111--0-1100----      |  100                | 
| 10000000 - --- -- ---- 0100 1111--0-1101----      |  100                | 
| 10000000 - --- -- ---- 0100 1111--0-1110----      |  101                | 
| 10000000 - --- -- ---- 0100 1111--0-1111----      |  100                |
| 10000000 - --- -- ---- 0100 1111--1-0000----      |  101                |
| 10000000 - --- -- ---- 0100 1111--1-0001----      |  100                | 
| 10000000 - --- -- ---- 0100 1111--1-0010----      |  101                | 
| 10000000 - --- -- ---- 0100 1111--1-0011----      |  001                | 
| 10000000 - --- -- ---- 0100 1111--1-0100----      |  101                | 
| 10000000 - --- -- ---- 0100 1111--1-0101----      |  100                | 
| 10000000 - --- -- ---- 0100 1111--1-0110----      |  101                | 
| 10000000 - --- -- ---- 0100 1111--1-0111----      |  001                | 
| 10000000 - --- -- ---- 0100 1111--1-1000----      |  111                |
| 10000000 - --- -- ---- 0100 1111--1-1001----      |  110                | 
| 10000000 - --- -- ---- 0100 1111--1-1010----      |  111                | 
| 10000000 - --- -- ---- 0100 1111--1-1011----      |  011                | 
| 10000000 - --- -- ---- 0100 1111--1-1100----      |  101                | 
| 10000000 - --- -- ---- 0100 1111--1-1101----      |  100                | 
| 10000000 - --- -- ---- 0100 1111--1-1110----      |  101                | 
| 10000000 - --- -- ---- 0100 1111--1-1111----      |  101                | 
| 10000000 - --- -- ---- 0010 1111-0--0000----      |  001                | derat cc full, hit way2
| 10000000 - --- -- ---- 0010 1111-0--0001----      |  000                | 
| 10000000 - --- -- ---- 0010 1111-0--0010----      |  001                | 
| 10000000 - --- -- ---- 0010 1111-0--0011----      |  001                | 
| 10000000 - --- -- ---- 0010 1111-0--0100----      |  001                | 
| 10000000 - --- -- ---- 0010 1111-0--0101----      |  000                | 
| 10000000 - --- -- ---- 0010 1111-0--0110----      |  001                | 
| 10000000 - --- -- ---- 0010 1111-0--0111----      |  001                | 
| 10000000 - --- -- ---- 0010 1111-0--1000----      |  011                |
| 10000000 - --- -- ---- 0010 1111-0--1001----      |  010                | 
| 10000000 - --- -- ---- 0010 1111-0--1010----      |  011                | 
| 10000000 - --- -- ---- 0010 1111-0--1011----      |  011                | 
| 10000000 - --- -- ---- 0010 1111-0--1100----      |  101                | 
| 10000000 - --- -- ---- 0010 1111-0--1101----      |  100                | 
| 10000000 - --- -- ---- 0010 1111-0--1110----      |  101                | 
| 10000000 - --- -- ---- 0010 1111-0--1111----      |  001                |
| 10000000 - --- -- ---- 0010 1111-1--0000----      |  011                |
| 10000000 - --- -- ---- 0010 1111-1--0001----      |  010                | 
| 10000000 - --- -- ---- 0010 1111-1--0010----      |  011                | 
| 10000000 - --- -- ---- 0010 1111-1--0011----      |  011                | 
| 10000000 - --- -- ---- 0010 1111-1--0100----      |  001                | 
| 10000000 - --- -- ---- 0010 1111-1--0101----      |  000                | 
| 10000000 - --- -- ---- 0010 1111-1--0110----      |  001                | 
| 10000000 - --- -- ---- 0010 1111-1--0111----      |  001                | 
| 10000000 - --- -- ---- 0010 1111-1--1000----      |  011                |
| 10000000 - --- -- ---- 0010 1111-1--1001----      |  010                | 
| 10000000 - --- -- ---- 0010 1111-1--1010----      |  011                | 
| 10000000 - --- -- ---- 0010 1111-1--1011----      |  011                | 
| 10000000 - --- -- ---- 0010 1111-1--1100----      |  111                | 
| 10000000 - --- -- ---- 0010 1111-1--1101----      |  110                | 
| 10000000 - --- -- ---- 0010 1111-1--1110----      |  111                | 
| 10000000 - --- -- ---- 0010 1111-1--1111----      |  011                | 
| 10000000 - --- -- ---- 0001 1111-0--0000----      |  000                | derat cc full, hit way3
| 10000000 - --- -- ---- 0001 1111-0--0001----      |  000                | 
| 10000000 - --- -- ---- 0001 1111-0--0010----      |  001                | 
| 10000000 - --- -- ---- 0001 1111-0--0011----      |  000                | 
| 10000000 - --- -- ---- 0001 1111-0--0100----      |  000                | 
| 10000000 - --- -- ---- 0001 1111-0--0101----      |  000                | 
| 10000000 - --- -- ---- 0001 1111-0--0110----      |  001                | 
| 10000000 - --- -- ---- 0001 1111-0--0111----      |  000                | 
| 10000000 - --- -- ---- 0001 1111-0--1000----      |  010                |
| 10000000 - --- -- ---- 0001 1111-0--1001----      |  010                | 
| 10000000 - --- -- ---- 0001 1111-0--1010----      |  011                | 
| 10000000 - --- -- ---- 0001 1111-0--1011----      |  010                | 
| 10000000 - --- -- ---- 0001 1111-0--1100----      |  100                | 
| 10000000 - --- -- ---- 0001 1111-0--1101----      |  100                | 
| 10000000 - --- -- ---- 0001 1111-0--1110----      |  101                | 
| 10000000 - --- -- ---- 0001 1111-0--1111----      |  000                |
| 10000000 - --- -- ---- 0001 1111-1--0000----      |  010                |
| 10000000 - --- -- ---- 0001 1111-1--0001----      |  010                | 
| 10000000 - --- -- ---- 0001 1111-1--0010----      |  011                | 
| 10000000 - --- -- ---- 0001 1111-1--0011----      |  010                | 
| 10000000 - --- -- ---- 0001 1111-1--0100----      |  000                | 
| 10000000 - --- -- ---- 0001 1111-1--0101----      |  000                | 
| 10000000 - --- -- ---- 0001 1111-1--0110----      |  001                | 
| 10000000 - --- -- ---- 0001 1111-1--0111----      |  000                | 
| 10000000 - --- -- ---- 0001 1111-1--1000----      |  010                |
| 10000000 - --- -- ---- 0001 1111-1--1001----      |  010                | 
| 10000000 - --- -- ---- 0001 1111-1--1010----      |  011                | 
| 10000000 - --- -- ---- 0001 1111-1--1011----      |  010                | 
| 10000000 - --- -- ---- 0001 1111-1--1100----      |  110                | 
| 10000000 - --- -- ---- 0001 1111-1--1101----      |  110                | 
| 10000000 - --- -- ---- 0001 1111-1--1110----      |  111                | 
| 10000000 - --- -- ---- 0001 1111-1--1111----      |  010                | 
| 01000000 - --- -- ---- ---- 0-----0---------      |  000                | ierat nonvalid ways
| 01000000 - --- -- ---- ---- 0-----1---------      |  001                |
| 01000000 - --- -- ---- ---- 10----0---------      |  010                | 
| 01000000 - --- -- ---- ---- 10----1---------      |  011                | 
| 01000000 - --- -- ---- ---- 110--0----------      |  100                | 
| 01000000 - --- -- ---- ---- 110--1----------      |  110                | 
| 01000000 - --- -- ---- ---- 1110-0----------      |  101                | 
| 01000000 - --- -- ---- ---- 1110-1----------      |  111                | 
| 01000000 - --- -- ---- 0000 1111000---------      |  000                | ierat cc full, no hit, no lru change
| 01000000 - --- -- ---- 0000 1111001---------      |  001                |  
| 01000000 - --- -- ---- 0000 1111010---------      |  010                |  
| 01000000 - --- -- ---- 0000 1111011---------      |  011                |  
| 01000000 - --- -- ---- 0000 1111100---------      |  100                |  
| 01000000 - --- -- ---- 0000 1111101---------      |  101                |  
| 01000000 - --- -- ---- 0000 1111110---------      |  110                |  
| 01000000 - --- -- ---- 0000 1111111---------      |  111                |  
| 01000000 - --- -- ---- 1000 1111--0-0000----      |  110                | ierat cc full, hit way0 (multihits don't write lru)
| 01000000 - --- -- ---- 1000 1111--0-0001----      |  110                | 
| 01000000 - --- -- ---- 1000 1111--0-0010----      |  111                | 
| 01000000 - --- -- ---- 1000 1111--0-0011----      |  010                | 
| 01000000 - --- -- ---- 1000 1111--0-0100----      |  100                | 
| 01000000 - --- -- ---- 1000 1111--0-0101----      |  100                | 
| 01000000 - --- -- ---- 1000 1111--0-0110----      |  101                | 
| 01000000 - --- -- ---- 1000 1111--0-0111----      |  000                | 
| 01000000 - --- -- ---- 1000 1111--0-1000----      |  110                |
| 01000000 - --- -- ---- 1000 1111--0-1001----      |  110                | 
| 01000000 - --- -- ---- 1000 1111--0-1010----      |  111                | 
| 01000000 - --- -- ---- 1000 1111--0-1011----      |  010                | 
| 01000000 - --- -- ---- 1000 1111--0-1100----      |  110                | 
| 01000000 - --- -- ---- 1000 1111--0-1101----      |  110                | 
| 01000000 - --- -- ---- 1000 1111--0-1110----      |  111                | 
| 01000000 - --- -- ---- 1000 1111--0-1111----      |  110                |
| 01000000 - --- -- ---- 1000 1111--1-0000----      |  111                |
| 01000000 - --- -- ---- 1000 1111--1-0001----      |  110                | 
| 01000000 - --- -- ---- 1000 1111--1-0010----      |  111                | 
| 01000000 - --- -- ---- 1000 1111--1-0011----      |  011                | 
| 01000000 - --- -- ---- 1000 1111--1-0100----      |  101                | 
| 01000000 - --- -- ---- 1000 1111--1-0101----      |  100                | 
| 01000000 - --- -- ---- 1000 1111--1-0110----      |  101                | 
| 01000000 - --- -- ---- 1000 1111--1-0111----      |  001                | 
| 01000000 - --- -- ---- 1000 1111--1-1000----      |  111                |
| 01000000 - --- -- ---- 1000 1111--1-1001----      |  110                | 
| 01000000 - --- -- ---- 1000 1111--1-1010----      |  111                | 
| 01000000 - --- -- ---- 1000 1111--1-1011----      |  011                | 
| 01000000 - --- -- ---- 1000 1111--1-1100----      |  111                | 
| 01000000 - --- -- ---- 1000 1111--1-1101----      |  110                | 
| 01000000 - --- -- ---- 1000 1111--1-1110----      |  111                | 
| 01000000 - --- -- ---- 1000 1111--1-1111----      |  111                | 
| 01000000 - --- -- ---- 0100 1111--0-0000----      |  100                | ierat cc full, hit way1
| 01000000 - --- -- ---- 0100 1111--0-0001----      |  100                | 
| 01000000 - --- -- ---- 0100 1111--0-0010----      |  101                | 
| 01000000 - --- -- ---- 0100 1111--0-0011----      |  000                | 
| 01000000 - --- -- ---- 0100 1111--0-0100----      |  100                | 
| 01000000 - --- -- ---- 0100 1111--0-0101----      |  100                | 
| 01000000 - --- -- ---- 0100 1111--0-0110----      |  101                | 
| 01000000 - --- -- ---- 0100 1111--0-0111----      |  000                | 
| 01000000 - --- -- ---- 0100 1111--0-1000----      |  110                |
| 01000000 - --- -- ---- 0100 1111--0-1001----      |  110                | 
| 01000000 - --- -- ---- 0100 1111--0-1010----      |  111                | 
| 01000000 - --- -- ---- 0100 1111--0-1011----      |  010                |
| 01000000 - --- -- ---- 0100 1111--0-1100----      |  100                | 
| 01000000 - --- -- ---- 0100 1111--0-1101----      |  100                | 
| 01000000 - --- -- ---- 0100 1111--0-1110----      |  101                | 
| 01000000 - --- -- ---- 0100 1111--0-1111----      |  100                |
| 01000000 - --- -- ---- 0100 1111--1-0000----      |  101                |
| 01000000 - --- -- ---- 0100 1111--1-0001----      |  100                | 
| 01000000 - --- -- ---- 0100 1111--1-0010----      |  101                | 
| 01000000 - --- -- ---- 0100 1111--1-0011----      |  001                | 
| 01000000 - --- -- ---- 0100 1111--1-0100----      |  101                | 
| 01000000 - --- -- ---- 0100 1111--1-0101----      |  100                | 
| 01000000 - --- -- ---- 0100 1111--1-0110----      |  101                | 
| 01000000 - --- -- ---- 0100 1111--1-0111----      |  001                | 
| 01000000 - --- -- ---- 0100 1111--1-1000----      |  111                |
| 01000000 - --- -- ---- 0100 1111--1-1001----      |  110                | 
| 01000000 - --- -- ---- 0100 1111--1-1010----      |  111                | 
| 01000000 - --- -- ---- 0100 1111--1-1011----      |  011                | 
| 01000000 - --- -- ---- 0100 1111--1-1100----      |  101                | 
| 01000000 - --- -- ---- 0100 1111--1-1101----      |  100                | 
| 01000000 - --- -- ---- 0100 1111--1-1110----      |  101                | 
| 01000000 - --- -- ---- 0100 1111--1-1111----      |  101                | 
| 01000000 - --- -- ---- 0010 1111-0--0000----      |  001                | ierat cc full, hit way2
| 01000000 - --- -- ---- 0010 1111-0--0001----      |  000                | 
| 01000000 - --- -- ---- 0010 1111-0--0010----      |  001                | 
| 01000000 - --- -- ---- 0010 1111-0--0011----      |  001                | 
| 01000000 - --- -- ---- 0010 1111-0--0100----      |  001                | 
| 01000000 - --- -- ---- 0010 1111-0--0101----      |  000                | 
| 01000000 - --- -- ---- 0010 1111-0--0110----      |  001                | 
| 01000000 - --- -- ---- 0010 1111-0--0111----      |  001                | 
| 01000000 - --- -- ---- 0010 1111-0--1000----      |  011                |
| 01000000 - --- -- ---- 0010 1111-0--1001----      |  010                | 
| 01000000 - --- -- ---- 0010 1111-0--1010----      |  011                | 
| 01000000 - --- -- ---- 0010 1111-0--1011----      |  011                | 
| 01000000 - --- -- ---- 0010 1111-0--1100----      |  101                | 
| 01000000 - --- -- ---- 0010 1111-0--1101----      |  100                | 
| 01000000 - --- -- ---- 0010 1111-0--1110----      |  101                | 
| 01000000 - --- -- ---- 0010 1111-0--1111----      |  001                |
| 01000000 - --- -- ---- 0010 1111-1--0000----      |  011                |
| 01000000 - --- -- ---- 0010 1111-1--0001----      |  010                | 
| 01000000 - --- -- ---- 0010 1111-1--0010----      |  011                | 
| 01000000 - --- -- ---- 0010 1111-1--0011----      |  011                | 
| 01000000 - --- -- ---- 0010 1111-1--0100----      |  001                | 
| 01000000 - --- -- ---- 0010 1111-1--0101----      |  000                | 
| 01000000 - --- -- ---- 0010 1111-1--0110----      |  001                | 
| 01000000 - --- -- ---- 0010 1111-1--0111----      |  001                | 
| 01000000 - --- -- ---- 0010 1111-1--1000----      |  011                |
| 01000000 - --- -- ---- 0010 1111-1--1001----      |  010                | 
| 01000000 - --- -- ---- 0010 1111-1--1010----      |  011                | 
| 01000000 - --- -- ---- 0010 1111-1--1011----      |  011                | 
| 01000000 - --- -- ---- 0010 1111-1--1100----      |  111                | 
| 01000000 - --- -- ---- 0010 1111-1--1101----      |  110                | 
| 01000000 - --- -- ---- 0010 1111-1--1110----      |  111                | 
| 01000000 - --- -- ---- 0010 1111-1--1111----      |  011                | 
| 01000000 - --- -- ---- 0001 1111-0--0000----      |  000                | ierat cc full, hit way3
| 01000000 - --- -- ---- 0001 1111-0--0001----      |  000                | 
| 01000000 - --- -- ---- 0001 1111-0--0010----      |  001                | 
| 01000000 - --- -- ---- 0001 1111-0--0011----      |  000                | 
| 01000000 - --- -- ---- 0001 1111-0--0100----      |  000                | 
| 01000000 - --- -- ---- 0001 1111-0--0101----      |  000                | 
| 01000000 - --- -- ---- 0001 1111-0--0110----      |  001                | 
| 01000000 - --- -- ---- 0001 1111-0--0111----      |  000                | 
| 01000000 - --- -- ---- 0001 1111-0--1000----      |  010                |
| 01000000 - --- -- ---- 0001 1111-0--1001----      |  010                | 
| 01000000 - --- -- ---- 0001 1111-0--1010----      |  011                | 
| 01000000 - --- -- ---- 0001 1111-0--1011----      |  010                | 
| 01000000 - --- -- ---- 0001 1111-0--1100----      |  100                | 
| 01000000 - --- -- ---- 0001 1111-0--1101----      |  100                | 
| 01000000 - --- -- ---- 0001 1111-0--1110----      |  101                | 
| 01000000 - --- -- ---- 0001 1111-0--1111----      |  000                |
| 01000000 - --- -- ---- 0001 1111-1--0000----      |  010                |
| 01000000 - --- -- ---- 0001 1111-1--0001----      |  010                | 
| 01000000 - --- -- ---- 0001 1111-1--0010----      |  011                | 
| 01000000 - --- -- ---- 0001 1111-1--0011----      |  010                | 
| 01000000 - --- -- ---- 0001 1111-1--0100----      |  000                | 
| 01000000 - --- -- ---- 0001 1111-1--0101----      |  000                | 
| 01000000 - --- -- ---- 0001 1111-1--0110----      |  001                | 
| 01000000 - --- -- ---- 0001 1111-1--0111----      |  000                | 
| 01000000 - --- -- ---- 0001 1111-1--1000----      |  010                |
| 01000000 - --- -- ---- 0001 1111-1--1001----      |  010                | 
| 01000000 - --- -- ---- 0001 1111-1--1010----      |  011                | 
| 01000000 - --- -- ---- 0001 1111-1--1011----      |  010                | 
| 01000000 - --- -- ---- 0001 1111-1--1100----      |  110                | 
| 01000000 - --- -- ---- 0001 1111-1--1101----      |  110                | 
| 01000000 - --- -- ---- 0001 1111-1--1110----      |  111                | 
| 01000000 - --- -- ---- 0001 1111-1--1111----      |  010                | 
| 00001000 - --- -- ---- 0000 ----000---------      |  000                | snoop no hit, no lru change
| 00001000 - --- -- ---- 0000 ----001---------      |  001                | 
| 00001000 - --- -- ---- 0000 ----010---------      |  010                | 
| 00001000 - --- -- ---- 0000 ----011---------      |  011                | 
| 00001000 - --- -- ---- 0000 ----100---------      |  100                | 
| 00001000 - --- -- ---- 0000 ----101---------      |  101                | 
| 00001000 - --- -- ---- 0000 ----110---------      |  110                | 
| 00001000 - --- -- ---- 0000 ----111---------      |  111                | 
| 00001000 - --- -- ---- 1--- 0-----0---------      |  000                | snoop hit with existing nonvalid ways
| 00001000 - --- -- ---- 1--- 0-----1---------      |  001                | 
| 00001000 - --- -- ---- 1--- 10----0-0-------      |  000                | 
| 00001000 - --- -- ---- 1--- 10----1-0-------      |  001                | 
| 00001000 - --- -- ---- 1--- 10----0-1-------      |  010                | 
| 00001000 - --- -- ---- 1--- 10----1-1-------      |  011                | 
| 00001000 - --- -- ---- 1--- 110---0-0-------      |  000                | 
| 00001000 - --- -- ---- 1--- 110---1-0-------      |  001                | 
| 00001000 - --- -- ---- 1--- 110--0--1-------      |  100                | 
| 00001000 - --- -- ---- 1--- 110--1--1-------      |  110                | 
| 00001000 - --- -- ---- 1--- 1110--0-0-------      |  000                | 
| 00001000 - --- -- ---- 1--- 1110--1-0-------      |  001                | 
| 00001000 - --- -- ---- 1--- 1110-0--1-------      |  101                | 
| 00001000 - --- -- ---- 1--- 1110-1--1-------      |  111                | 
| 00001000 - --- -- ---- 01-- 0-----0---------      |  000                | 
| 00001000 - --- -- ---- 01-- 0-----1---------      |  001                | 
| 00001000 - --- -- ---- 01-- 10----0---------      |  010                | 
| 00001000 - --- -- ---- 01-- 10----1---------      |  011                | 
| 00001000 - --- -- ---- 01-- 110---0--0------      |  010                | 
| 00001000 - --- -- ---- 01-- 110---1--0------      |  011                | 
| 00001000 - --- -- ---- 01-- 110--0---1------      |  100                | 
| 00001000 - --- -- ---- 01-- 110--1---1------      |  110                | 
| 00001000 - --- -- ---- 01-- 1110--0--0------      |  010                | 
| 00001000 - --- -- ---- 01-- 1110--1--0------      |  011                | 
| 00001000 - --- -- ---- 01-- 1110-0---1------      |  101                | 
| 00001000 - --- -- ---- 01-- 1110-1---1------      |  111                | 
| 00001000 - --- -- ---- 001- 0-----0---------      |  000                | 
| 00001000 - --- -- ---- 001- 0-----1---------      |  001                | 
| 00001000 - --- -- ---- 001- 10----0---------      |  010                | 
| 00001000 - --- -- ---- 001- 10----1---------      |  011                | 
| 00001000 - --- -- ---- 001- 110--0----------      |  100                | 
| 00001000 - --- -- ---- 001- 110--1----------      |  110                | 
| 00001000 - --- -- ---- 001- 1110-0----0-----      |  100                | 
| 00001000 - --- -- ---- 001- 1110-1----0-----      |  110                | 
| 00001000 - --- -- ---- 001- 1110-0----1-----      |  101                | 
| 00001000 - --- -- ---- 001- 1110-1----1-----      |  111                | 
| 00001000 - --- -- ---- 0001 0-----0---------      |  000                | 
| 00001000 - --- -- ---- 0001 0-----1---------      |  001                | 
| 00001000 - --- -- ---- 0001 10----0---------      |  010                | 
| 00001000 - --- -- ---- 0001 10----1---------      |  011                | 
| 00001000 - --- -- ---- 0001 110--0----------      |  100                | 
| 00001000 - --- -- ---- 0001 110--1----------      |  110                | 
| 00001000 - --- -- ---- 0001 1110-0----------      |  101                | 
| 00001000 - --- -- ---- 0001 1110-1----------      |  111                | 
| 00001000 - --- -- ---- 1--- 1111--0-0-------      |  000                | snoop hit way0, all valid, hit is iprot=0
| 00001000 - --- -- ---- 1--- 1111--1-0-------      |  001                | 
| 00001000 - --- -- ---- 11-- 1111--0-10------      |  010                | 
| 00001000 - --- -- ---- 11-- 1111--1-10------      |  011                | 
| 00001000 - --- -- ---- 1-1- 1111-0--110-----      |  100                | 
| 00001000 - --- -- ---- 1-1- 1111-1--110-----      |  110                | 
| 00001000 - --- -- ---- 1--1 1111-0--1110----      |  101                | 
| 00001000 - --- -- ---- 1--1 1111-1--1110----      |  111                | 
| 00001000 - --- -- ---- 01-- 1111--0--0------      |  010                | snoop hit way1, all valid, hit is iprot=0
| 00001000 - --- -- ---- 01-- 1111--1--0------      |  011                | 
| 00001000 - --- -- ---- 011- 1111-0---10-----      |  100                | 
| 00001000 - --- -- ---- 011- 1111-1---10-----      |  110                | 
| 00001000 - --- -- ---- 01-1 1111-0---110----      |  101                | 
| 00001000 - --- -- ---- 01-1 1111-1---110----      |  111                | 
| 00001000 - --- -- ---- 001- 1111-0----0-----      |  100                | snoop hit way2, all valid, hit is iprot=0
| 00001000 - --- -- ---- 001- 1111-1----0-----      |  110                | 
| 00001000 - --- -- ---- 0011 1111-0----10----      |  101                | 
| 00001000 - --- -- ---- 0011 1111-1----10----      |  111                | 
| 00001000 - --- -- ---- 0001 1111-0-----0----      |  101                | snoop hit way3, all valid, hit is iprot=0 
| 00001000 - --- -- ---- 0001 1111-1-----0----      |  111                | 
| 00001000 - --- -- ---- 1000 1111000-1-------      |  000                | snoop hit way0, all valid, hit is iprot=1, no change
| 00001000 - --- -- ---- 1000 1111001-1-------      |  001                | 
| 00001000 - --- -- ---- 1000 1111010-1-------      |  010                | 
| 00001000 - --- -- ---- 1000 1111011-1-------      |  011                | 
| 00001000 - --- -- ---- 1000 1111100-1-------      |  100                | 
| 00001000 - --- -- ---- 1000 1111101-1-------      |  101                | 
| 00001000 - --- -- ---- 1000 1111110-1-------      |  110                | 
| 00001000 - --- -- ---- 1000 1111111-1-------      |  111                | 
| 00001000 - --- -- ---- 0100 1111000--1------      |  000                | snoop hit way1, all valid, hit is iprot=1, no change
| 00001000 - --- -- ---- 0100 1111001--1------      |  001                | 
| 00001000 - --- -- ---- 0100 1111010--1------      |  010                | 
| 00001000 - --- -- ---- 0100 1111011--1------      |  011                | 
| 00001000 - --- -- ---- 0100 1111100--1------      |  100                | 
| 00001000 - --- -- ---- 0100 1111101--1------      |  101                | 
| 00001000 - --- -- ---- 0100 1111110--1------      |  110                | 
| 00001000 - --- -- ---- 0100 1111111--1------      |  111                | 
| 00001000 - --- -- ---- 0010 1111000---1-----      |  000                | snoop hit way2, all valid, hit is iprot=1, no change
| 00001000 - --- -- ---- 0010 1111001---1-----      |  001                | 
| 00001000 - --- -- ---- 0010 1111010---1-----      |  010                | 
| 00001000 - --- -- ---- 0010 1111011---1-----      |  011                | 
| 00001000 - --- -- ---- 0010 1111100---1-----      |  100                | 
| 00001000 - --- -- ---- 0010 1111101---1-----      |  101                | 
| 00001000 - --- -- ---- 0010 1111110---1-----      |  110                | 
| 00001000 - --- -- ---- 0010 1111111---1-----      |  111                | 
| 00001000 - --- -- ---- 0001 1111000----1----      |  000                | snoop hit way3, all valid, hit is iprot=1, no change
| 00001000 - --- -- ---- 0001 1111001----1----      |  001                | 
| 00001000 - --- -- ---- 0001 1111010----1----      |  010                | 
| 00001000 - --- -- ---- 0001 1111011----1----      |  011                | 
| 00001000 - --- -- ---- 0001 1111100----1----      |  100                | 
| 00001000 - --- -- ---- 0001 1111101----1----      |  101                | 
| 00001000 - --- -- ---- 0001 1111110----1----      |  110                | 
| 00001000 - --- -- ---- 0001 1111111----1----      |  111                | 
| 00001000 - --- -- ---- 1100 1111000-11------      |  000                | snoop multihit, all valid, all hits are iprot=1, no change
| 00001000 - --- -- ---- 1100 1111001-11------      |  001                | 
| 00001000 - --- -- ---- 1100 1111010-11------      |  010                | 
| 00001000 - --- -- ---- 1100 1111011-11------      |  011                | 
| 00001000 - --- -- ---- 1100 1111100-11------      |  100                | 
| 00001000 - --- -- ---- 1100 1111101-11------      |  101                | 
| 00001000 - --- -- ---- 1100 1111110-11------      |  110                | 
| 00001000 - --- -- ---- 1100 1111111-11------      |  111                | 
| 00001000 - --- -- ---- 1010 1111000-1-1-----      |  000                | snoop multihit, all valid, all hits are iprot=1, no change
| 00001000 - --- -- ---- 1010 1111001-1-1-----      |  001                | 
| 00001000 - --- -- ---- 1010 1111010-1-1-----      |  010                | 
| 00001000 - --- -- ---- 1010 1111011-1-1-----      |  011                | 
| 00001000 - --- -- ---- 1010 1111100-1-1-----      |  100                | 
| 00001000 - --- -- ---- 1010 1111101-1-1-----      |  101                | 
| 00001000 - --- -- ---- 1010 1111110-1-1-----      |  110                | 
| 00001000 - --- -- ---- 1010 1111111-1-1-----      |  111                | 
| 00001000 - --- -- ---- 1110 1111000-111-----      |  000                | snoop multihit, all valid, all hits are iprot=1, no change
| 00001000 - --- -- ---- 1110 1111001-111-----      |  001                | 
| 00001000 - --- -- ---- 1110 1111010-111-----      |  010                | 
| 00001000 - --- -- ---- 1110 1111011-111-----      |  011                | 
| 00001000 - --- -- ---- 1110 1111100-111-----      |  100                | 
| 00001000 - --- -- ---- 1110 1111101-111-----      |  101                | 
| 00001000 - --- -- ---- 1110 1111110-111-----      |  110                | 
| 00001000 - --- -- ---- 1110 1111111-111-----      |  111                | 
| 00001000 - --- -- ---- 1001 1111000-1--1----      |  000                | snoop multihit, all valid, all hits are iprot=1, no change
| 00001000 - --- -- ---- 1001 1111001-1--1----      |  001                | 
| 00001000 - --- -- ---- 1001 1111010-1--1----      |  010                | 
| 00001000 - --- -- ---- 1001 1111011-1--1----      |  011                | 
| 00001000 - --- -- ---- 1001 1111100-1--1----      |  100                | 
| 00001000 - --- -- ---- 1001 1111101-1--1----      |  101                | 
| 00001000 - --- -- ---- 1001 1111110-1--1----      |  110                | 
| 00001000 - --- -- ---- 1001 1111111-1--1----      |  111                | 
| 00001000 - --- -- ---- 1101 1111000-11-1----      |  000                | snoop multihit, all valid, all hits are iprot=1, no change
| 00001000 - --- -- ---- 1101 1111001-11-1----      |  001                | 
| 00001000 - --- -- ---- 1101 1111010-11-1----      |  010                | 
| 00001000 - --- -- ---- 1101 1111011-11-1----      |  011                | 
| 00001000 - --- -- ---- 1101 1111100-11-1----      |  100                | 
| 00001000 - --- -- ---- 1101 1111101-11-1----      |  101                | 
| 00001000 - --- -- ---- 1101 1111110-11-1----      |  110                | 
| 00001000 - --- -- ---- 1101 1111111-11-1----      |  111                | 
| 00001000 - --- -- ---- 1110 1111000-111-----      |  000                | snoop multihit, all valid, all hits are iprot=1, no change
| 00001000 - --- -- ---- 1110 1111001-111-----      |  001                | 
| 00001000 - --- -- ---- 1110 1111010-111-----      |  010                | 
| 00001000 - --- -- ---- 1110 1111011-111-----      |  011                | 
| 00001000 - --- -- ---- 1110 1111100-111-----      |  100                | 
| 00001000 - --- -- ---- 1110 1111101-111-----      |  101                | 
| 00001000 - --- -- ---- 1110 1111110-111-----      |  110                | 
| 00001000 - --- -- ---- 1110 1111111-111-----      |  111                | 
| 00001000 - --- -- ---- 1111 1111000-1111----      |  000                | snoop multihit, all valid, all hits are iprot=1, no change
| 00001000 - --- -- ---- 1111 1111001-1111----      |  001                | 
| 00001000 - --- -- ---- 1111 1111010-1111----      |  010                | 
| 00001000 - --- -- ---- 1111 1111011-1111----      |  011                | 
| 00001000 - --- -- ---- 1111 1111100-1111----      |  100                | 
| 00001000 - --- -- ---- 1111 1111101-1111----      |  101                | 
| 00001000 - --- -- ---- 1111 1111110-1111----      |  110                | 
| 00001000 - --- -- ---- 1111 1111111-1111----      |  111                | 
| 00001000 - --- -- ---- 0110 1111000--11-----      |  000                | snoop multihit, all valid, all hits are iprot=1, no change
| 00001000 - --- -- ---- 0110 1111001--11-----      |  001                | 
| 00001000 - --- -- ---- 0110 1111010--11-----      |  010                | 
| 00001000 - --- -- ---- 0110 1111011--11-----      |  011                | 
| 00001000 - --- -- ---- 0110 1111100--11-----      |  100                | 
| 00001000 - --- -- ---- 0110 1111101--11-----      |  101                | 
| 00001000 - --- -- ---- 0110 1111110--11-----      |  110                | 
| 00001000 - --- -- ---- 0110 1111111--11-----      |  111                | 
| 00001000 - --- -- ---- 0101 1111000--1-1----      |  000                | snoop multihit, all valid, all hits are iprot=1, no change
| 00001000 - --- -- ---- 0101 1111001--1-1----      |  001                | 
| 00001000 - --- -- ---- 0101 1111010--1-1----      |  010                | 
| 00001000 - --- -- ---- 0101 1111011--1-1----      |  011                | 
| 00001000 - --- -- ---- 0101 1111100--1-1----      |  100                | 
| 00001000 - --- -- ---- 0101 1111101--1-1----      |  101                | 
| 00001000 - --- -- ---- 0101 1111110--1-1----      |  110                | 
| 00001000 - --- -- ---- 0101 1111111--1-1----      |  111                | 
| 00001000 - --- -- ---- 0111 1111000--111----      |  000                | snoop multihit, all valid, all hits are iprot=1, no change
| 00001000 - --- -- ---- 0111 1111001--111----      |  001                | 
| 00001000 - --- -- ---- 0111 1111010--111----      |  010                | 
| 00001000 - --- -- ---- 0111 1111011--111----      |  011                | 
| 00001000 - --- -- ---- 0111 1111100--111----      |  100                | 
| 00001000 - --- -- ---- 0111 1111101--111----      |  101                | 
| 00001000 - --- -- ---- 0111 1111110--111----      |  110                | 
| 00001000 - --- -- ---- 0111 1111111--111----      |  111                | 
| 00001000 - --- -- ---- 0011 1111000---11----      |  000                | snoop multihit, all valid, all hits are iprot=1, no change
| 00001000 - --- -- ---- 0011 1111001---11----      |  001                | 
| 00001000 - --- -- ---- 0011 1111010---11----      |  010                | 
| 00001000 - --- -- ---- 0011 1111011---11----      |  011                | 
| 00001000 - --- -- ---- 0011 1111100---11----      |  100                | 
| 00001000 - --- -- ---- 0011 1111101---11----      |  101                | 
| 00001000 - --- -- ---- 0011 1111110---11----      |  110                | 
| 00001000 - --- -- ---- 0011 1111111---11----      |  111                | 
| 00000010 0 -0- -- 0--- ---- 0-----0---------      |  000                | HW078192: tlbwe v=0 and hes=0, unused tagpos_is def is mas1_v, mas1_iprot for tlbwe
| 00000010 0 -0- -- 0--- ---- 0-----1---------      |  001                | 
| 00000010 0 -10 -- 0--- ---- 0---------------      |  000                | 
| 00000010 0 -11 -- 0--- ---- 0-0-------------      |  000                | 
| 00000010 0 -11 -- 0--- ---- 0-1-------------      |  001                | 
| 00000010 0 -00 -- 0--- ---- 1-----0---------      |  000                | 
| 00000010 0 -00 -- 0--- ---- 1-----1---------      |  001                | 
| 00000010 0 -01 -- 0--- ---- 1-----0---------      |  010                | 
| 00000010 0 -01 -- 0--- ---- 1-----1---------      |  011                | 
| 00000010 0 -10 -- 0--- ---- 10--------------      |  010                | 
| 00000010 0 -11 -- 0--- ---- 100-------------      |  010                | 
| 00000010 0 -11 -- 0--- ---- 101-------------      |  011                | 
| 00000010 0 -1- -- 0--- ---- 110--0----------      |  100                | 
| 00000010 0 -1- -- 0--- ---- 110--1----------      |  110                | 
| 00000010 0 -10 -- 0--- ---- 111--0----------      |  100                | 
| 00000010 0 -10 -- 0--- ---- 111--1----------      |  110                | 
| 00000010 0 -11 -- 0--- ---- 111--0----------      |  101                | 
| 00000010 0 -11 -- 0--- ---- 111--1----------      |  111                |
| 00000010 1 --- -- 0--- ---- 0---0-0---------      |  000                | HW078192: tlbwe v=0 and hes=1, unused tagpos_is def is mas1_v, mas1_iprot for tlbwe
| 00000010 1 --- -- 0--- ---- 0---0-1---------      |  001                | 
| 00000010 1 --- -- 0--- ---- 0---1-0---------      |  000                | 
| 00000010 1 --- -- 0--- ---- 0-0-1-1---------      |  000                | 
| 00000010 1 --- -- 0--- ---- 0-1-1-1---------      |  001                | 
| 00000010 1 --- -- 0--- ---- 1---000---------      |  000                | 
| 00000010 1 --- -- 0--- ---- 1---001---------      |  001                | 
| 00000010 1 --- -- 0--- ---- 1---010---------      |  010                | 
| 00000010 1 --- -- 0--- ---- 1---011---------      |  011                | 
| 00000010 1 --- -- 0--- ---- 10--1-0---------      |  010                | 
| 00000010 1 --- -- 0--- ---- 100-1-1---------      |  010                | 
| 00000010 1 --- -- 0--- ---- 101-1-1---------      |  011                | 
| 00000010 1 --- -- 0--- ---- 110-10----------      |  100                | 
| 00000010 1 --- -- 0--- ---- 110-11----------      |  110                | 
| 00000010 1 --- -- 0--- ---- 111-100---------      |  100                | 
| 00000010 1 --- -- 0--- ---- 111-110---------      |  110                | 
| 00000010 1 --- -- 0--- ---- 111-101---------      |  101                | 
| 00000010 1 --- -- 0--- ---- 111-111---------      |  111                |
| 00000010 0 -01 -- 1--- ---- 0-----0---------      |  000                | tlbwe v=1, hes=0, esel/=open way, unused tagpos_is def is mas1_v, mas1_iprot for tlbwe
| 00000010 0 -01 -- 1--- ---- 0-----1---------      |  001                | 
| 00000010 0 -10 -- 10-- ---- 0----------0----      |  001                | 
| 00000010 0 -10 -- 10-- ---- 0----------1----      |  000                | 
| 00000010 0 -10 -- 11-- ---- 0---------------      |  001                | 
| 00000010 0 -11 -- 10-- ---- 0---------0-----      |  000                |
| 00000010 0 -11 -- 10-- ---- 0---------1-----      |  001                | 
| 00000010 0 -11 -- 11-- ---- 0---------------      |  000                | 
| 00000010 0 -00 -- 1--- ---- 10----0---------      |  010                | 
| 00000010 0 -00 -- 1--- ---- 10----1---------      |  011                | 
| 00000010 0 -10 -- 10-- ---- 10---------0----      |  011                | 
| 00000010 0 -10 -- 10-- ---- 10---------1----      |  010                | 
| 00000010 0 -10 -- 11-- ---- 10--------------      |  011                | 
| 00000010 0 -11 -- 10-- ---- 10--------0-----      |  010                | 
| 00000010 0 -11 -- 10-- ---- 10--------1-----      |  011                | 
| 00000010 0 -11 -- 11-- ---- 10--------------      |  010                | 
| 00000010 0 -00 -- 10-- ---- 110------0------      |  110                | 
| 00000010 0 -00 -- 10-- ---- 110------1------      |  100                | 
| 00000010 0 -00 -- 11-- ---- 110-------------      |  110                | 
| 00000010 0 -01 -- 10-- ---- 110-----0-------      |  100                | 
| 00000010 0 -01 -- 10-- ---- 110-----1-------      |  110                | 
| 00000010 0 -01 -- 11-- ---- 110-------------      |  100                | 
| 00000010 0 -11 -- 1--- ---- 110--0----------      |  100                | 
| 00000010 0 -11 -- 1--- ---- 110--1----------      |  110                | 
| 00000010 0 -00 -- 10-- ---- 1110-----0------      |  111                | 
| 00000010 0 -00 -- 10-- ---- 1110-----1------      |  101                | 
| 00000010 0 -00 -- 11-- ---- 1110------------      |  111                | 
| 00000010 0 -01 -- 10-- ---- 1110----0-------      |  101                | 
| 00000010 0 -01 -- 10-- ---- 1110----1-------      |  111                | 
| 00000010 0 -01 -- 11-- ---- 1110------------      |  101                | 
| 00000010 0 -10 -- 1--- ---- 1110-0----------      |  101                | 
| 00000010 0 -10 -- 1--- ---- 1110-1----------      |  111                |
| 00000010 0 -00 -- 1--- ---- 00----0---------      |  010                | tlbwe v=1, hes=0, esel=0=first open way, multiple open ways
| 00000010 0 -00 -- 1--- ---- 00----1---------      |  011                | 
| 00000010 0 -00 -- 1--- ---- 010------0------      |  110                | 
| 00000010 0 -00 -- 10-- ---- 010------1------      |  100                | 
| 00000010 0 -00 -- 11-- ---- 010------1------      |  110                | 
| 00000010 0 -00 -- 1--- ---- 0110-----0------      |  111                | 
| 00000010 0 -00 -- 10-- ---- 0110-----1------      |  101                | 
| 00000010 0 -00 -- 11-- ---- 0110-----1------      |  111                | 
| 00000010 0 -01 -- 1--- ---- 100-----0-------      |  100                | tlbwe v=1, hes=0, esel=1=first open way, multiple open ways
| 00000010 0 -01 -- 10-- ---- 100-----1-------      |  110                |
| 00000010 0 -01 -- 11-- ---- 100-----1-------      |  100                |
| 00000010 0 -01 -- 1--- ---- 1010----0-------      |  101                | 
| 00000010 0 -01 -- 10-- ---- 1010----1-------      |  111                | 
| 00000010 0 -01 -- 11-- ---- 1010----1-------      |  101                | 
| 00000010 0 -10 -- 1--- ---- 1100-0----------      |  101                | tlbwe v=1, hes=0, esel=2=first open way, multiple open ways
| 00000010 0 -10 -- 1--- ---- 1100-1----------      |  111                | 
| 00000010 0 -00 -- 1--- ---- 0111--0--00-----      |  110                | tlbwe v=1, hes=0, esel=0=open way, 1 open way
| 00000010 0 -00 -- 1--- ---- 0111--0--010----      |  111                | 
| 00000010 0 -00 -- 1--- ---- 0111--1--0-0----      |  111                | 
| 00000010 0 -00 -- 1--- ---- 0111--1--001----      |  110                | 
| 00000010 0 -00 -- 10-- ---- 0111--0--10-----      |  100                | 
| 00000010 0 -00 -- 10-- ---- 0111--0--110----      |  101                | 
| 00000010 0 -00 -- 10-- ---- 0111--1--1-0----      |  101                | 
| 00000010 0 -00 -- 10-- ---- 0111--1--101----      |  100                | 
| 00000010 0 -00 -- 11-- ---- 0111--0--10-----      |  110                | 
| 00000010 0 -00 -- 11-- ---- 0111--0--110----      |  111                | 
| 00000010 0 -00 -- 11-- ---- 0111--1--1-0----      |  111                | 
| 00000010 0 -00 -- 11-- ---- 0111--1--101----      |  110                | 
| 00000010 0 -00 -- 1--- ---- 0111--0--011----      |  010                | 
| 00000010 0 -00 -- 1--- ---- 0111--1--011----      |  011                |
| 00000010 0 -00 -- 10-- ---- 0111--0--111----      |  000                | 
| 00000010 0 -00 -- 10-- ---- 0111--1--111----      |  001                |
| 00000010 0 -00 -- 11-- ---- 0111--0--111----      |  110                | 
| 00000010 0 -00 -- 11-- ---- 0111--1--111----      |  111                |
| 00000010 0 -01 -- 1--- ---- 1011--0-0-0-----      |  100                | tlbwe v=1, hes=0, esel=1=open way, 1 open way 
| 00000010 0 -01 -- 1--- ---- 1011--0-0-10----      |  101                | 
| 00000010 0 -01 -- 1--- ---- 1011--1-0--0----      |  101                | 
| 00000010 0 -01 -- 1--- ---- 1011--1-0-01----      |  100                | 
| 00000010 0 -01 -- 10-- ---- 1011--0-1-0-----      |  110                | 
| 00000010 0 -01 -- 10-- ---- 1011--0-1-10----      |  111                | 
| 00000010 0 -01 -- 10-- ---- 1011--1-1--0----      |  111                | 
| 00000010 0 -01 -- 10-- ---- 1011--1-1-01----      |  110                | 
| 00000010 0 -01 -- 11-- ---- 1011--0-1-0-----      |  100                | 
| 00000010 0 -01 -- 11-- ---- 1011--0-1-10----      |  101                | 
| 00000010 0 -01 -- 11-- ---- 1011--1-1--0----      |  101                | 
| 00000010 0 -01 -- 11-- ---- 1011--1-1-01----      |  100                | 
| 00000010 0 -01 -- 1--- ---- 1011--0-0-11----      |  000                | 
| 00000010 0 -01 -- 1--- ---- 1011--1-0-11----      |  001                | 
| 00000010 0 -01 -- 10-- ---- 1011--0-1-11----      |  010                | 
| 00000010 0 -01 -- 10-- ---- 1011--1-1-11----      |  011                |
| 00000010 0 -01 -- 11-- ---- 1011--0-1-11----      |  100                | 
| 00000010 0 -01 -- 11-- ---- 1011--1-1-11----      |  101                |
| 00000010 0 -10 -- 1--- ---- 1101-0--0--0----      |  001                | tlbwe v=1, hes=0, esel=2=open way, 1 open way 
| 00000010 0 -10 -- 1--- ---- 1101-0--10-0----      |  011                | 
| 00000010 0 -10 -- 1--- ---- 1101-1---0-0----      |  011                | 
| 00000010 0 -10 -- 1--- ---- 1101-1--01-0----      |  001                |
| 00000010 0 -10 -- 10-- ---- 1101-0--0--1----      |  000                | 
| 00000010 0 -10 -- 10-- ---- 1101-0--10-1----      |  010                | 
| 00000010 0 -10 -- 10-- ---- 1101-1---0-1----      |  010                | 
| 00000010 0 -10 -- 10-- ---- 1101-1--01-1----      |  000                |
| 00000010 0 -10 -- 11-- ---- 1101-0--0--1----      |  001                | 
| 00000010 0 -10 -- 11-- ---- 1101-0--10-1----      |  011                | 
| 00000010 0 -10 -- 11-- ---- 1101-1---0-1----      |  011                | 
| 00000010 0 -10 -- 11-- ---- 1101-1--01-1----      |  001                |
| 00000010 0 -10 -- 1--- ---- 1101-0--11-0----      |  101                | 
| 00000010 0 -10 -- 1--- ---- 1101-1--11-0----      |  111                | 
| 00000010 0 -10 -- 10-- ---- 1101-0--11-1----      |  100                | 
| 00000010 0 -10 -- 10-- ---- 1101-1--11-1----      |  110                |
| 00000010 0 -10 -- 11-- ---- 1101-0--11-1----      |  001                | 
| 00000010 0 -10 -- 11-- ---- 1101-1--11-1----      |  011                |
| 00000010 0 -11 -- 1--- ---- 1110-0--0-0-----      |  000                | tlbwe v=1, hes=0, esel=3=open way, 1 open way
| 00000010 0 -11 -- 1--- ---- 1110-0--100-----      |  010                | 
| 00000010 0 -11 -- 1--- ---- 1110-1---00-----      |  010                | 
| 00000010 0 -11 -- 1--- ---- 1110-1--010-----      |  000                | 
| 00000010 0 -11 -- 10-- ---- 1110-0--0-1-----      |  001                |
| 00000010 0 -11 -- 10-- ---- 1110-0--101-----      |  011                | 
| 00000010 0 -11 -- 10-- ---- 1110-1---01-----      |  011                | 
| 00000010 0 -11 -- 10-- ---- 1110-1--011-----      |  001                | 
| 00000010 0 -11 -- 11-- ---- 1110-0--0-1-----      |  000                |
| 00000010 0 -11 -- 11-- ---- 1110-0--101-----      |  010                | 
| 00000010 0 -11 -- 11-- ---- 1110-1---01-----      |  010                | 
| 00000010 0 -11 -- 11-- ---- 1110-1--011-----      |  000                | 
| 00000010 0 -11 -- 1--- ---- 1110-0--110-----      |  100                | 
| 00000010 0 -11 -- 1--- ---- 1110-1--110-----      |  110                | 
| 00000010 0 -11 -- 10-- ---- 1110-0--111-----      |  101                | 
| 00000010 0 -11 -- 10-- ---- 1110-1--111-----      |  111                |
| 00000010 0 -11 -- 11-- ---- 1110-0--111-----      |  000                | 
| 00000010 0 -11 -- 11-- ---- 1110-1--111-----      |  010                |
| 00000010 0 -00 -- 1--- ---- 1111--0--00-----      |  110                | tlbwe v=1, hes=0, esel=0, full ways
| 00000010 0 -00 -- 1--- ---- 1111--0--010----      |  111                | 
| 00000010 0 -00 -- 1--- ---- 1111--1--0-0----      |  111                | 
| 00000010 0 -00 -- 1--- ---- 1111--1--001----      |  110                | 
| 00000010 0 -00 -- 10-- ---- 1111--0--10-----      |  100                | 
| 00000010 0 -00 -- 10-- ---- 1111--0--110----      |  101                | 
| 00000010 0 -00 -- 10-- ---- 1111--1--1-0----      |  101                | 
| 00000010 0 -00 -- 10-- ---- 1111--1--101----      |  100                | 
| 00000010 0 -00 -- 11-- ---- 1111--0--10-----      |  110                | 
| 00000010 0 -00 -- 11-- ---- 1111--0--110----      |  111                | 
| 00000010 0 -00 -- 11-- ---- 1111--1--1-0----      |  111                | 
| 00000010 0 -00 -- 11-- ---- 1111--1--101----      |  110                | 
| 00000010 0 -00 -- 1--- ---- 1111--0--011----      |  010                |
| 00000010 0 -00 -- 1--- ---- 1111--1--011----      |  011                |
| 00000010 0 -00 -- 10-- ---- 1111--0--111----      |  000                | 
| 00000010 0 -00 -- 10-- ---- 1111--1--111----      |  001                |
| 00000010 0 -00 -- 11-- ---- 1111--0--111----      |  110                | 
| 00000010 0 -00 -- 11-- ---- 1111--1--111----      |  111                |
| 00000010 0 -01 -- 1--- ---- 1111--0-0-0-----      |  100                | tlbwe v=1, hes=0, esel=1, full ways
| 00000010 0 -01 -- 1--- ---- 1111--0-0-10----      |  101                | 
| 00000010 0 -01 -- 1--- ---- 1111--1-0--0----      |  101                | 
| 00000010 0 -01 -- 1--- ---- 1111--1-0-01----      |  100                |
| 00000010 0 -01 -- 10-- ---- 1111--0-1-0-----      |  110                |
| 00000010 0 -01 -- 10-- ---- 1111--0-1-10----      |  111                | 
| 00000010 0 -01 -- 10-- ---- 1111--1-1--0----      |  111                | 
| 00000010 0 -01 -- 10-- ---- 1111--1-1-01----      |  110                |
| 00000010 0 -01 -- 11-- ---- 1111--0-1-0-----      |  100                |
| 00000010 0 -01 -- 11-- ---- 1111--0-1-10----      |  101                | 
| 00000010 0 -01 -- 11-- ---- 1111--1-1--0----      |  101                | 
| 00000010 0 -01 -- 11-- ---- 1111--1-1-01----      |  100                |
| 00000010 0 -01 -- 1--- ---- 1111--0-0-11----      |  000                | 
| 00000010 0 -01 -- 1--- ---- 1111--1-0-11----      |  001                | 
| 00000010 0 -01 -- 10-- ---- 1111--0-1-11----      |  010                | 
| 00000010 0 -01 -- 10-- ---- 1111--1-1-11----      |  011                |
| 00000010 0 -01 -- 11-- ---- 1111--0-1-11----      |  100                | 
| 00000010 0 -01 -- 11-- ---- 1111--1-1-11----      |  101                |
| 00000010 0 -10 -- 1--- ---- 1111-0--0--0----      |  001                | tlbwe v=1, hes=0, esel=2, full ways
| 00000010 0 -10 -- 1--- ---- 1111-0--10-0----      |  011                | 
| 00000010 0 -10 -- 1--- ---- 1111-1---0-0----      |  011                | 
| 00000010 0 -10 -- 1--- ---- 1111-1--01-0----      |  001                |
| 00000010 0 -10 -- 10-- ---- 1111-0--0--1----      |  000                |
| 00000010 0 -10 -- 10-- ---- 1111-0--10-1----      |  010                | 
| 00000010 0 -10 -- 10-- ---- 1111-1---0-1----      |  010                | 
| 00000010 0 -10 -- 10-- ---- 1111-1--01-1----      |  000                |
| 00000010 0 -10 -- 11-- ---- 1111-0--0--1----      |  001                |
| 00000010 0 -10 -- 11-- ---- 1111-0--10-1----      |  011                | 
| 00000010 0 -10 -- 11-- ---- 1111-1---0-1----      |  011                | 
| 00000010 0 -10 -- 11-- ---- 1111-1--01-1----      |  001                |
| 00000010 0 -10 -- 1--- ---- 1111-0--11-0----      |  101                | 
| 00000010 0 -10 -- 1--- ---- 1111-1--11-0----      |  111                | 
| 00000010 0 -10 -- 10-- ---- 1111-0--11-1----      |  100                | 
| 00000010 0 -10 -- 10-- ---- 1111-1--11-1----      |  110                |
| 00000010 0 -10 -- 11-- ---- 1111-0--11-1----      |  001                | 
| 00000010 0 -10 -- 11-- ---- 1111-1--11-1----      |  011                |
| 00000010 0 -11 -- 1--- ---- 1111-0--0-0-----      |  000                | tlbwe v=1, hes=0, esel=3, full ways
| 00000010 0 -11 -- 1--- ---- 1111-0--100-----      |  010                | 
| 00000010 0 -11 -- 1--- ---- 1111-1---00-----      |  010                | 
| 00000010 0 -11 -- 1--- ---- 1111-1--010-----      |  000                |
| 00000010 0 -11 -- 10-- ---- 1111-0--0-1-----      |  001                |
| 00000010 0 -11 -- 10-- ---- 1111-0--101-----      |  011                | 
| 00000010 0 -11 -- 10-- ---- 1111-1---01-----      |  011                | 
| 00000010 0 -11 -- 10-- ---- 1111-1--011-----      |  001                |
| 00000010 0 -11 -- 11-- ---- 1111-0--0-1-----      |  000                |
| 00000010 0 -11 -- 11-- ---- 1111-0--101-----      |  010                | 
| 00000010 0 -11 -- 11-- ---- 1111-1---01-----      |  010                | 
| 00000010 0 -11 -- 11-- ---- 1111-1--011-----      |  000                |
| 00000010 0 -11 -- 1--- ---- 1111-0--110-----      |  100                | 
| 00000010 0 -11 -- 1--- ---- 1111-1--110-----      |  110                | 
| 00000010 0 -11 -- 10-- ---- 1111-0--111-----      |  101                | 
| 00000010 0 -11 -- 10-- ---- 1111-1--111-----      |  111                |
| 00000010 0 -11 -- 11-- ---- 1111-0--111-----      |  000                | 
| 00000010 0 -11 -- 11-- ---- 1111-1--111-----      |  010                |
| 00000010 1 --- -- 1--- ---- 0---010---------      |  000                | tlbwe v=1, hes=1, lru/=first open way, unused tagpos_is def is mas1_v, mas1_iprot for tlbwe
| 00000010 1 --- -- 1--- ---- 0---011---------      |  001                | 
| 00000010 1 --- -- 10-- ---- 0---1-0----0----      |  001                | 
| 00000010 1 --- -- 10-- ---- 0---1-0----1----      |  000                | 
| 00000010 1 --- -- 11-- ---- 0---1-0---------      |  001                | 
| 00000010 1 --- -- 10-- ---- 0---1-1---0-----      |  000                |
| 00000010 1 --- -- 10-- ---- 0---1-1---1-----      |  001                | 
| 00000010 1 --- -- 11-- ---- 0---1-1---------      |  000                | 
| 00000010 1 --- -- 1--- ---- 10--000---------      |  010                | 
| 00000010 1 --- -- 1--- ---- 10--001---------      |  011                | 
| 00000010 1 --- -- 10-- ---- 10--1-0----0----      |  011                | 
| 00000010 1 --- -- 10-- ---- 10--1-0----1----      |  010                | 
| 00000010 1 --- -- 11-- ---- 10--1-0---------      |  011                | 
| 00000010 1 --- -- 10-- ---- 10--1-1---0-----      |  010                |  
| 00000010 1 --- -- 10-- ---- 10--1-1---1-----      |  011                |  
| 00000010 1 --- -- 11-- ---- 10--1-1---------      |  010                | 
| 00000010 1 --- -- 10-- ---- 110-00---0------      |  110                | 
| 00000010 1 --- -- 10-- ---- 110-00---1------      |  100                | 
| 00000010 1 --- -- 11-- ---- 110-00----------      |  110                | 
| 00000010 1 --- -- 10-- ---- 110-01--0-------      |  100                | 
| 00000010 1 --- -- 10-- ---- 110-01--1-------      |  110                | 
| 00000010 1 --- -- 11-- ---- 110-01----------      |  100                | 
| 00000010 1 --- -- 1--- ---- 110-101---------      |  100                | 
| 00000010 1 --- -- 1--- ---- 110-111---------      |  110                | 
| 00000010 1 --- -- 10-- ---- 111000---0------      |  111                | 
| 00000010 1 --- -- 10-- ---- 111000---1------      |  101                | 
| 00000010 1 --- -- 11-- ---- 111000----------      |  111                | 
| 00000010 1 --- -- 10-- ---- 111001--0-------      |  101                | 
| 00000010 1 --- -- 10-- ---- 111001--1-------      |  111                | 
| 00000010 1 --- -- 11-- ---- 111001----------      |  101                | 
| 00000010 1 --- -- 1--- ---- 1110100---------      |  101                | 
| 00000010 1 --- -- 1--- ---- 1110110---------      |  111                |
| 00000010 1 --- -- 1--- ---- 00--000---------      |  010                | tlbwe v=1, hes=1, lsu=0=first open way, multiple open ways
| 00000010 1 --- -- 1--- ---- 00--001---------      |  011                | 
| 00000010 1 --- -- 1--- ---- 010-00---0------      |  110                | 
| 00000010 1 --- -- 10-- ---- 010-00---1------      |  100                | 
| 00000010 1 --- -- 11-- ---- 010-00---1------      |  110                | 
| 00000010 1 --- -- 1--- ---- 011000---0------      |  111                | 
| 00000010 1 --- -- 10-- ---- 011000---1------      |  101                | 
| 00000010 1 --- -- 11-- ---- 011000---1------      |  111                | 
| 00000010 1 --- -- 1--- ---- 100-01--0-------      |  100                | tlbwe v=1, hes=1, lsu=1=first open way, multiple open ways
| 00000010 1 --- -- 10-- ---- 100-01--1-------      |  110                |
| 00000010 1 --- -- 11-- ---- 100-01--1-------      |  100                |
| 00000010 1 --- -- 1--- ---- 101001--0-------      |  101                | 
| 00000010 1 --- -- 10-- ---- 101001--1-------      |  111                | 
| 00000010 1 --- -- 11-- ---- 101001--1-------      |  101                | 
| 00000010 1 --- -- 1--- ---- 1100100---------      |  101                | tlbwe v=1, hes=1, lru=2=first open way, multiple open ways
| 00000010 1 --- -- 1--- ---- 1100110---------      |  111                | 
| 00000010 1 --- -- 1--- ---- 0111000--00-----      |  110                | tlbwe v=1, hes=1, lru=0=open way, 1 open way
| 00000010 1 --- -- 1--- ---- 0111000--010----      |  111                | 
| 00000010 1 --- -- 1--- ---- 0111001--0-0----      |  111                | 
| 00000010 1 --- -- 1--- ---- 0111001--001----      |  110                | 
| 00000010 1 --- -- 10-- ---- 0111000--10-----      |  100                | 
| 00000010 1 --- -- 10-- ---- 0111000--110----      |  101                | 
| 00000010 1 --- -- 10-- ---- 0111001--1-0----      |  101                | 
| 00000010 1 --- -- 10-- ---- 0111001--101----      |  100                | 
| 00000010 1 --- -- 11-- ---- 0111000--10-----      |  110                | 
| 00000010 1 --- -- 11-- ---- 0111000--110----      |  111                | 
| 00000010 1 --- -- 11-- ---- 0111001--1-0----      |  111                | 
| 00000010 1 --- -- 11-- ---- 0111001--101----      |  110                | 
| 00000010 1 --- -- 1--- ---- 0111000--011----      |  010                | 
| 00000010 1 --- -- 1--- ---- 0111001--011----      |  011                |
| 00000010 1 --- -- 10-- ---- 0111000--111----      |  000                | 
| 00000010 1 --- -- 10-- ---- 0111001--111----      |  001                |
| 00000010 1 --- -- 11-- ---- 0111000--111----      |  110                | 
| 00000010 1 --- -- 11-- ---- 0111001--111----      |  111                |
| 00000010 1 --- -- 1--- ---- 1011010-0-0-----      |  100                | tlbwe v=1, hes=1, lru=1=open way, 1 open way 
| 00000010 1 --- -- 1--- ---- 1011010-0-10----      |  101                | 
| 00000010 1 --- -- 1--- ---- 1011011-0--0----      |  101                | 
| 00000010 1 --- -- 1--- ---- 1011011-0-01----      |  100                | 
| 00000010 1 --- -- 10-- ---- 1011010-1-0-----      |  110                | 
| 00000010 1 --- -- 10-- ---- 1011010-1-10----      |  111                | 
| 00000010 1 --- -- 10-- ---- 1011011-1--0----      |  111                | 
| 00000010 1 --- -- 10-- ---- 1011011-1-01----      |  110                | 
| 00000010 1 --- -- 11-- ---- 1011010-1-0-----      |  100                | 
| 00000010 1 --- -- 11-- ---- 1011010-1-10----      |  101                | 
| 00000010 1 --- -- 11-- ---- 1011011-1--0----      |  101                | 
| 00000010 1 --- -- 11-- ---- 1011011-1-01----      |  100                | 
| 00000010 1 --- -- 1--- ---- 1011010-0-11----      |  000                | 
| 00000010 1 --- -- 1--- ---- 1011011-0-11----      |  001                | 
| 00000010 1 --- -- 10-- ---- 1011010-1-11----      |  010                | 
| 00000010 1 --- -- 10-- ---- 1011011-1-11----      |  011                |
| 00000010 1 --- -- 11-- ---- 1011010-1-11----      |  100                | 
| 00000010 1 --- -- 11-- ---- 1011011-1-11----      |  101                |
| 00000010 1 --- -- 1--- ---- 1101100-0--0----      |  001                | tlbwe v=1, hes=1, lru=2=open way, 1 open way 
| 00000010 1 --- -- 1--- ---- 1101100-10-0----      |  011                | 
| 00000010 1 --- -- 1--- ---- 1101110--0-0----      |  011                | 
| 00000010 1 --- -- 1--- ---- 1101110-01-0----      |  001                |
| 00000010 1 --- -- 10-- ---- 1101100-0--1----      |  000                | 
| 00000010 1 --- -- 10-- ---- 1101100-10-1----      |  010                | 
| 00000010 1 --- -- 10-- ---- 1101110--0-1----      |  010                | 
| 00000010 1 --- -- 10-- ---- 1101110-01-1----      |  000                |
| 00000010 1 --- -- 11-- ---- 1101100-0--1----      |  001                | 
| 00000010 1 --- -- 11-- ---- 1101100-10-1----      |  011                | 
| 00000010 1 --- -- 11-- ---- 1101110--0-1----      |  011                | 
| 00000010 1 --- -- 11-- ---- 1101110-01-1----      |  001                |
| 00000010 1 --- -- 1--- ---- 1101100-11-0----      |  101                | 
| 00000010 1 --- -- 1--- ---- 1101110-11-0----      |  111                | 
| 00000010 1 --- -- 10-- ---- 1101100-11-1----      |  100                | 
| 00000010 1 --- -- 10-- ---- 1101110-11-1----      |  110                |
| 00000010 1 --- -- 11-- ---- 1101100-11-1----      |  001                | 
| 00000010 1 --- -- 11-- ---- 1101110-11-1----      |  011                |
| 00000010 1 --- -- 1--- ---- 1110101-0-0-----      |  000                | tlbwe v=1, hes=1, lru=3=open way, 1 open way
| 00000010 1 --- -- 1--- ---- 1110101-100-----      |  010                | 
| 00000010 1 --- -- 1--- ---- 1110111--00-----      |  010                | 
| 00000010 1 --- -- 1--- ---- 1110111-010-----      |  000                | 
| 00000010 1 --- -- 10-- ---- 1110101-0-1-----      |  001                |
| 00000010 1 --- -- 10-- ---- 1110101-101-----      |  011                | 
| 00000010 1 --- -- 10-- ---- 1110111--01-----      |  011                | 
| 00000010 1 --- -- 10-- ---- 1110111-011-----      |  001                | 
| 00000010 1 --- -- 11-- ---- 1110101-0-1-----      |  000                |
| 00000010 1 --- -- 11-- ---- 1110101-101-----      |  010                | 
| 00000010 1 --- -- 11-- ---- 1110111--01-----      |  010                | 
| 00000010 1 --- -- 11-- ---- 1110111-011-----      |  000                | 
| 00000010 1 --- -- 1--- ---- 1110101-110-----      |  100                | 
| 00000010 1 --- -- 1--- ---- 1110111-110-----      |  110                | 
| 00000010 1 --- -- 10-- ---- 1110101-111-----      |  101                | 
| 00000010 1 --- -- 10-- ---- 1110111-111-----      |  111                |
| 00000010 1 --- -- 11-- ---- 1110101-111-----      |  000                | 
| 00000010 1 --- -- 11-- ---- 1110111-111-----      |  010                |
| 00000010 1 --- -- 1--- ---- 1111000--00-----      |  110                | tlbwe v=1, hes=1, lru=0, full ways
| 00000010 1 --- -- 1--- ---- 1111000--010----      |  111                | 
| 00000010 1 --- -- 1--- ---- 1111001--0-0----      |  111                | 
| 00000010 1 --- -- 1--- ---- 1111001--001----      |  110                | 
| 00000010 1 --- -- 10-- ---- 1111000--10-----      |  100                | 
| 00000010 1 --- -- 10-- ---- 1111000--110----      |  101                | 
| 00000010 1 --- -- 10-- ---- 1111001--1-0----      |  101                | 
| 00000010 1 --- -- 10-- ---- 1111001--101----      |  100                | 
| 00000010 1 --- -- 11-- ---- 1111000--10-----      |  110                | 
| 00000010 1 --- -- 11-- ---- 1111000--110----      |  111                | 
| 00000010 1 --- -- 11-- ---- 1111001--1-0----      |  111                | 
| 00000010 1 --- -- 11-- ---- 1111001--101----      |  110                | 
| 00000010 1 --- -- 1--- ---- 1111000--011----      |  010                |
| 00000010 1 --- -- 1--- ---- 1111001--011----      |  011                |
| 00000010 1 --- -- 10-- ---- 1111000--111----      |  000                | 
| 00000010 1 --- -- 10-- ---- 1111001--111----      |  001                |
| 00000010 1 --- -- 11-- ---- 1111000--111----      |  110                | 
| 00000010 1 --- -- 11-- ---- 1111001--111----      |  111                |
| 00000010 1 --- -- 1--- ---- 1111010-0-0-----      |  100                | tlbwe v=1, hes=1, lru=1, full ways
| 00000010 1 --- -- 1--- ---- 1111010-0-10----      |  101                | 
| 00000010 1 --- -- 1--- ---- 1111011-0--0----      |  101                | 
| 00000010 1 --- -- 1--- ---- 1111011-0-01----      |  100                |
| 00000010 1 --- -- 10-- ---- 1111010-1-0-----      |  110                |
| 00000010 1 --- -- 10-- ---- 1111010-1-10----      |  111                | 
| 00000010 1 --- -- 10-- ---- 1111011-1--0----      |  111                | 
| 00000010 1 --- -- 10-- ---- 1111011-1-01----      |  110                |
| 00000010 1 --- -- 11-- ---- 1111010-1-0-----      |  100                |
| 00000010 1 --- -- 11-- ---- 1111010-1-10----      |  101                | 
| 00000010 1 --- -- 11-- ---- 1111011-1--0----      |  101                | 
| 00000010 1 --- -- 11-- ---- 1111011-1-01----      |  100                |
| 00000010 1 --- -- 1--- ---- 1111010-0-11----      |  000                | 
| 00000010 1 --- -- 1--- ---- 1111011-0-11----      |  001                | 
| 00000010 1 --- -- 10-- ---- 1111010-1-11----      |  010                | 
| 00000010 1 --- -- 10-- ---- 1111011-1-11----      |  011                |
| 00000010 1 --- -- 11-- ---- 1111010-1-11----      |  100                | 
| 00000010 1 --- -- 11-- ---- 1111011-1-11----      |  101                |
| 00000010 1 --- -- 1--- ---- 1111100-0--0----      |  001                | tlbwe v=1, hes=1, lru=2, full ways
| 00000010 1 --- -- 1--- ---- 1111100-10-0----      |  011                | 
| 00000010 1 --- -- 1--- ---- 1111110--0-0----      |  011                | 
| 00000010 1 --- -- 1--- ---- 1111110-01-0----      |  001                |
| 00000010 1 --- -- 10-- ---- 1111100-0--1----      |  000                |
| 00000010 1 --- -- 10-- ---- 1111100-10-1----      |  010                | 
| 00000010 1 --- -- 10-- ---- 1111110--0-1----      |  010                | 
| 00000010 1 --- -- 10-- ---- 1111110-01-1----      |  000                |
| 00000010 1 --- -- 11-- ---- 1111100-0--1----      |  001                |
| 00000010 1 --- -- 11-- ---- 1111100-10-1----      |  011                | 
| 00000010 1 --- -- 11-- ---- 1111110--0-1----      |  011                | 
| 00000010 1 --- -- 11-- ---- 1111110-01-1----      |  001                |
| 00000010 1 --- -- 1--- ---- 1111100-11-0----      |  101                | 
| 00000010 1 --- -- 1--- ---- 1111110-11-0----      |  111                | 
| 00000010 1 --- -- 10-- ---- 1111100-11-1----      |  100                | 
| 00000010 1 --- -- 10-- ---- 1111110-11-1----      |  110                |
| 00000010 1 --- -- 11-- ---- 1111100-11-1----      |  001                | 
| 00000010 1 --- -- 11-- ---- 1111110-11-1----      |  011                |
| 00000010 1 --- -- 1--- ---- 1111101-0-0-----      |  000                | tlbwe v=1, hes=1, lru=3, full ways
| 00000010 1 --- -- 1--- ---- 1111101-100-----      |  010                | 
| 00000010 1 --- -- 1--- ---- 1111111--00-----      |  010                | 
| 00000010 1 --- -- 1--- ---- 1111111-010-----      |  000                |
| 00000010 1 --- -- 10-- ---- 1111101-0-1-----      |  001                |
| 00000010 1 --- -- 10-- ---- 1111101-101-----      |  011                | 
| 00000010 1 --- -- 10-- ---- 1111111--01-----      |  011                | 
| 00000010 1 --- -- 10-- ---- 1111111-011-----      |  001                |
| 00000010 1 --- -- 11-- ---- 1111101-0-1-----      |  000                |
| 00000010 1 --- -- 11-- ---- 1111101-101-----      |  010                | 
| 00000010 1 --- -- 11-- ---- 1111111--01-----      |  010                | 
| 00000010 1 --- -- 11-- ---- 1111111-011-----      |  000                |
| 00000010 1 --- -- 1--- ---- 1111101-110-----      |  100                | 
| 00000010 1 --- -- 1--- ---- 1111111-110-----      |  110                | 
| 00000010 1 --- -- 10-- ---- 1111101-111-----      |  101                | 
| 00000010 1 --- -- 10-- ---- 1111111-111-----      |  111                |
| 00000010 1 --- -- 11-- ---- 1111101-111-----      |  000                | 
| 00000010 1 --- -- 11-- ---- 1111111-111-----      |  010                |
| --000001 - --- -- 0--- ---- ----000---------      |  000                | ptereload v=0, no change (pt_fault)
| --000001 - --- -- 0--- ---- ----001---------      |  001                |
| --000001 - --- -- 0--- ---- ----010---------      |  010                |
| --000001 - --- -- 0--- ---- ----011---------      |  011                |
| --000001 - --- -- 0--- ---- ----100---------      |  100                |
| --000001 - --- -- 0--- ---- ----101---------      |  101                |
| --000001 - --- -- 0--- ---- ----110---------      |  110                |
| --000001 - --- -- 0--- ---- ----111---------      |  111                |
| --000001 - --- -- 1--- ---- 0---010---------      |  000                | ptereload v=1, hes=1 and iprot=0 assumed, lru/=first open way
| --000001 - --- -- 1--- ---- 0---011---------      |  001                | 
| --000001 - --- -- 1--- ---- 0---1-0----0----      |  001                | 
| --000001 - --- -- 1--- ---- 0---1-0----1----      |  000                | 
| --000001 - --- -- 1--- ---- 0---1-1---0-----      |  000                |
| --000001 - --- -- 1--- ---- 0---1-1---1-----      |  001                | 
| --000001 - --- -- 1--- ---- 10--000---------      |  010                | 
| --000001 - --- -- 1--- ---- 10--001---------      |  011                | 
| --000001 - --- -- 1--- ---- 10--1-0----0----      |  011                | 
| --000001 - --- -- 1--- ---- 10--1-0----1----      |  010                | 
| --000001 - --- -- 1--- ---- 10--1-1---0-----      |  010                |  
| --000001 - --- -- 1--- ---- 10--1-1---1-----      |  011                |  
| --000001 - --- -- 1--- ---- 110-00---0------      |  110                | 
| --000001 - --- -- 1--- ---- 110-00---1------      |  100                | 
| --000001 - --- -- 1--- ---- 110-01--0-------      |  100                | 
| --000001 - --- -- 1--- ---- 110-01--1-------      |  110                | 
| --000001 - --- -- 1--- ---- 110-101---------      |  100                | 
| --000001 - --- -- 1--- ---- 110-111---------      |  110                | 
| --000001 - --- -- 1--- ---- 111000---0------      |  111                | 
| --000001 - --- -- 1--- ---- 111000---1------      |  101                | 
| --000001 - --- -- 1--- ---- 111001--0-------      |  101                | 
| --000001 - --- -- 1--- ---- 111001--1-------      |  111                | 
| --000001 - --- -- 1--- ---- 1110100---------      |  101                | 
| --000001 - --- -- 1--- ---- 1110110---------      |  111                |
| --000001 - --- -- 1--- ---- 00--000---------      |  010                | ptereload v=1, hes=1 and iprot=0 assumed, lsu=0=first open way, multiple open ways
| --000001 - --- -- 1--- ---- 00--001---------      |  011                | 
| --000001 - --- -- 1--- ---- 010-00---0------      |  110                | 
| --000001 - --- -- 1--- ---- 010-00---1------      |  100                | 
| --000001 - --- -- 1--- ---- 011000---0------      |  111                | 
| --000001 - --- -- 1--- ---- 011000---1------      |  101                | 
| --000001 - --- -- 1--- ---- 100-01--0-------      |  100                | ptereload v=1, hes=1 and iprot=0 assumed, lsu=1=first open way, multiple open ways
| --000001 - --- -- 1--- ---- 100-01--1-------      |  110                |
| --000001 - --- -- 1--- ---- 101001--0-------      |  101                | 
| --000001 - --- -- 1--- ---- 101001--1-------      |  111                | 
| --000001 - --- -- 1--- ---- 1100100---------      |  101                | ptereload v=1, hes=1 and iprot=0 assumed, lru=2=first open way, multiple open ways
| --000001 - --- -- 1--- ---- 1100110---------      |  111                | 
| --000001 - --- -- 1--- ---- 0111000--00-----      |  110                | ptereload v=1, hes=1 and iprot=0 assumed, lru=0=open way, 1 open way
| --000001 - --- -- 1--- ---- 0111000--010----      |  111                | 
| --000001 - --- -- 1--- ---- 0111001--0-0----      |  111                | 
| --000001 - --- -- 1--- ---- 0111001--001----      |  110                | 
| --000001 - --- -- 1--- ---- 0111000--10-----      |  100                | 
| --000001 - --- -- 1--- ---- 0111000--110----      |  101                | 
| --000001 - --- -- 1--- ---- 0111001--1-0----      |  101                | 
| --000001 - --- -- 1--- ---- 0111001--101----      |  100                | 
| --000001 - --- -- 1--- ---- 0111000--011----      |  010                | 
| --000001 - --- -- 1--- ---- 0111001--011----      |  011                |
| --000001 - --- -- 1--- ---- 0111000--111----      |  000                | 
| --000001 - --- -- 1--- ---- 0111001--111----      |  001                |
| --000001 - --- -- 1--- ---- 1011010-0-0-----      |  100                | ptereload v=1, hes=1 and iprot=0 assumed, lru=1=open way, 1 open way 
| --000001 - --- -- 1--- ---- 1011010-0-10----      |  101                | 
| --000001 - --- -- 1--- ---- 1011011-0--0----      |  101                | 
| --000001 - --- -- 1--- ---- 1011011-0-01----      |  100                | 
| --000001 - --- -- 1--- ---- 1011010-1-0-----      |  110                | 
| --000001 - --- -- 1--- ---- 1011010-1-10----      |  111                | 
| --000001 - --- -- 1--- ---- 1011011-1--0----      |  111                | 
| --000001 - --- -- 1--- ---- 1011011-1-01----      |  110                | 
| --000001 - --- -- 1--- ---- 1011010-0-11----      |  000                | 
| --000001 - --- -- 1--- ---- 1011011-0-11----      |  001                | 
| --000001 - --- -- 1--- ---- 1011010-1-11----      |  010                | 
| --000001 - --- -- 1--- ---- 1011011-1-11----      |  011                |
| --000001 - --- -- 1--- ---- 1101100-0--0----      |  001                | ptereload v=1, hes=1 and iprot=0 assumed, lru=2=open way, 1 open way 
| --000001 - --- -- 1--- ---- 1101100-10-0----      |  011                | 
| --000001 - --- -- 1--- ---- 1101110--0-0----      |  011                | 
| --000001 - --- -- 1--- ---- 1101110-01-0----      |  001                |
| --000001 - --- -- 1--- ---- 1101100-0--1----      |  000                | 
| --000001 - --- -- 1--- ---- 1101100-10-1----      |  010                | 
| --000001 - --- -- 1--- ---- 1101110--0-1----      |  010                | 
| --000001 - --- -- 1--- ---- 1101110-01-1----      |  000                |
| --000001 - --- -- 1--- ---- 1101100-11-0----      |  101                | 
| --000001 - --- -- 1--- ---- 1101110-11-0----      |  111                | 
| --000001 - --- -- 1--- ---- 1101100-11-1----      |  100                | 
| --000001 - --- -- 1--- ---- 1101110-11-1----      |  110                |
| --000001 - --- -- 1--- ---- 1110101-0-0-----      |  000                | ptereload v=1, hes=1 and iprot=0 assumed, lru=3=open way, 1 open way
| --000001 - --- -- 1--- ---- 1110101-100-----      |  010                | 
| --000001 - --- -- 1--- ---- 1110111--00-----      |  010                | 
| --000001 - --- -- 1--- ---- 1110111-010-----      |  000                | 
| --000001 - --- -- 1--- ---- 1110101-0-1-----      |  001                |
| --000001 - --- -- 1--- ---- 1110101-101-----      |  011                | 
| --000001 - --- -- 1--- ---- 1110111--01-----      |  011                | 
| --000001 - --- -- 1--- ---- 1110111-011-----      |  001                | 
| --000001 - --- -- 1--- ---- 1110101-110-----      |  100                | 
| --000001 - --- -- 1--- ---- 1110111-110-----      |  110                | 
| --000001 - --- -- 1--- ---- 1110101-111-----      |  101                | 
| --000001 - --- -- 1--- ---- 1110111-111-----      |  111                |
| --000001 - --- -- 1--- ---- 1111000-000-----      |  110                | ptereload v=1, hes=1 and iprot=0 assumed, lru=0, full ways
| --000001 - --- -- 1--- ---- 1111000-0010----      |  111                | 
| --000001 - --- -- 1--- ---- 1111001-00-0----      |  111                | 
| --000001 - --- -- 1--- ---- 1111001-0001----      |  110                | 
| --000001 - --- -- 1--- ---- 1111000-010-----      |  100                | 
| --000001 - --- -- 1--- ---- 1111000-0110----      |  101                | 
| --000001 - --- -- 1--- ---- 1111001-01-0----      |  101                | 
| --000001 - --- -- 1--- ---- 1111001-0101----      |  100                | 
| --000001 - --- -- 1--- ---- 1111000-0011----      |  010                |
| --000001 - --- -- 1--- ---- 1111001-0011----      |  011                |
| --000001 - --- -- 1--- ---- 1111000-0111----      |  000                | 
| --000001 - --- -- 1--- ---- 1111001-0111----      |  001                |
| --000001 - --- -- 1--- ---- 1111010-000-----      |  100                | ptereload v=1, hes=1 and iprot=0 assumed, lru=1, full ways
| --000001 - --- -- 1--- ---- 1111010-0010----      |  101                | 
| --000001 - --- -- 1--- ---- 1111011-00-0----      |  101                | 
| --000001 - --- -- 1--- ---- 1111011-0001----      |  100                |
| --000001 - --- -- 1--- ---- 1111010-100-----      |  110                |
| --000001 - --- -- 1--- ---- 1111010-1010----      |  111                | 
| --000001 - --- -- 1--- ---- 1111011-10-0----      |  111                | 
| --000001 - --- -- 1--- ---- 1111011-1001----      |  110                |
| --000001 - --- -- 1--- ---- 1111010-0011----      |  000                | 
| --000001 - --- -- 1--- ---- 1111011-0011----      |  001                | 
| --000001 - --- -- 1--- ---- 1111010-1011----      |  010                | 
| --000001 - --- -- 1--- ---- 1111011-1011----      |  011                |
| --000001 - --- -- 1--- ---- 1111100-0-00----      |  001                | ptereload v=1, hes=1 and iprot=0 assumed, lru=2, full ways
| --000001 - --- -- 1--- ---- 1111100-1000----      |  011                | 
| --000001 - --- -- 1--- ---- 1111110--000----      |  011                | 
| --000001 - --- -- 1--- ---- 1111110-0100----      |  001                |
| --000001 - --- -- 1--- ---- 1111100-0-01----      |  000                |
| --000001 - --- -- 1--- ---- 1111100-1001----      |  010                | 
| --000001 - --- -- 1--- ---- 1111110--001----      |  010                | 
| --000001 - --- -- 1--- ---- 1111110-0101----      |  000                |
| --000001 - --- -- 1--- ---- 1111100-1100----      |  101                | 
| --000001 - --- -- 1--- ---- 1111110-1100----      |  111                | 
| --000001 - --- -- 1--- ---- 1111100-1101----      |  100                | 
| --000001 - --- -- 1--- ---- 1111110-1101----      |  110                |
| --000001 - --- -- 1--- ---- 1111101-0-00----      |  000                | ptereload v=1, hes=1 and iprot=0 assumed, lru=3, full ways
| --000001 - --- -- 1--- ---- 1111101-1000----      |  010                | 
| --000001 - --- -- 1--- ---- 1111111--000----      |  010                | 
| --000001 - --- -- 1--- ---- 1111111-0100----      |  000                |
| --000001 - --- -- 1--- ---- 1111101-0-10----      |  001                |
| --000001 - --- -- 1--- ---- 1111101-1010----      |  011                | 
| --000001 - --- -- 1--- ---- 1111111--010----      |  011                | 
| --000001 - --- -- 1--- ---- 1111111-0110----      |  001                |
| --000001 - --- -- 1--- ---- 1111101-1100----      |  100                | 
| --000001 - --- -- 1--- ---- 1111111-1100----      |  110                | 
| --000001 - --- -- 1--- ---- 1111101-1110----      |  101                | 
| --000001 - --- -- 1--- ---- 1111111-1110----      |  111                |
| --000001 - --- -- 1--- ---- 1111000-1111----      |  000                | ptereload v=1, cc full, all protected, no change
| --000001 - --- -- 1--- ---- 1111001-1111----      |  001                |
| --000001 - --- -- 1--- ---- 1111010-1111----      |  010                |
| --000001 - --- -- 1--- ---- 1111011-1111----      |  011                |
| --000001 - --- -- 1--- ---- 1111100-1111----      |  100                |
| --000001 - --- -- 1--- ---- 1111101-1111----      |  101                |
| --000001 - --- -- 1--- ---- 1111110-1111----      |  110                |
| --000001 - --- -- 1--- ---- 1111111-1111----      |  111                |
*END*===============================================+=====================+
?TABLE END lru_update_data;  
*/
      

      assign LRU_UPDATE_DATA_PT[1] = (({tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9], lru_tag4_dataout_q[10], lru_tag4_dataout_q[11]}) === 10'b0011111110);
      assign LRU_UPDATE_DATA_PT[2] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[9], lru_tag4_dataout_q[10], lru_tag4_dataout_q[11]}) === 9'b101111110);
      assign LRU_UPDATE_DATA_PT[3] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[10], lru_tag4_dataout_q[11]}) === 9'b111110010);
      assign LRU_UPDATE_DATA_PT[4] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[10], lru_tag4_dataout_q[11]}) === 8'b11110010);
      assign LRU_UPDATE_DATA_PT[5] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[10], lru_tag4_dataout_q[11]}) === 9'b111110110);
      assign LRU_UPDATE_DATA_PT[6] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[10], lru_tag4_dataout_q[11]}) === 8'b11110110);
      assign LRU_UPDATE_DATA_PT[7] = (({tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[10], lru_tag4_dataout_q[11]}) === 10'b0000111110);
      assign LRU_UPDATE_DATA_PT[8] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[10], lru_tag4_dataout_q[11]}) === 9'b000111110);
      assign LRU_UPDATE_DATA_PT[9] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[10], lru_tag4_dataout_q[11]}) === 9'b000111110);
      assign LRU_UPDATE_DATA_PT[10] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[10], lru_tag4_dataout_q[11]}) === 9'b100011110);
      assign LRU_UPDATE_DATA_PT[11] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[10], lru_tag4_dataout_q[11]}) === 9'b100111110);
      assign LRU_UPDATE_DATA_PT[12] = (({tlb_tag4_hes_sig, lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9], lru_tag4_dataout_q[11]}) === 8'b11110110);
      assign LRU_UPDATE_DATA_PT[13] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9], lru_tag4_dataout_q[11]}) === 9'b000111110);
      assign LRU_UPDATE_DATA_PT[14] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9], lru_tag4_dataout_q[11]}) === 9'b101011110);
      assign LRU_UPDATE_DATA_PT[15] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6], lru_tag4_dataout_q[11]}) === 6'b111100);
      assign LRU_UPDATE_DATA_PT[16] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6], lru_tag4_dataout_q[11]}) === 5'b11100);
      assign LRU_UPDATE_DATA_PT[17] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, lru_tag4_dataout_q[2], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6], lru_tag4_dataout_q[11]}) === 6'b111010);
      assign LRU_UPDATE_DATA_PT[18] = (({tlb_tag4_type_sig[7], lru_tag4_dataout_q[2], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6], lru_tag4_dataout_q[11]}) === 5'b11010);
      assign LRU_UPDATE_DATA_PT[19] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[2], lru_tag4_dataout_q[6], lru_tag4_dataout_q[11]}) === 7'b0000110);
      assign LRU_UPDATE_DATA_PT[20] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[6], lru_tag4_dataout_q[11]}) === 6'b100110);
      assign LRU_UPDATE_DATA_PT[21] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], tlb_tag4_wayhit_q[2], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[11]}) === 9'b100011110);
      assign LRU_UPDATE_DATA_PT[22] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[11]}) === 8'b00011110);
      assign LRU_UPDATE_DATA_PT[23] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[11]}) === 7'b1001110);
      assign LRU_UPDATE_DATA_PT[24] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[11]}) === 6'b101010);
      assign LRU_UPDATE_DATA_PT[25] = (({tlb_tag4_hes_sig, lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9], lru_tag4_dataout_q[10]}) === 8'b11111110);
      assign LRU_UPDATE_DATA_PT[26] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9], lru_tag4_dataout_q[10]}) === 9'b000111110);
      assign LRU_UPDATE_DATA_PT[27] = (({tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9], lru_tag4_dataout_q[10]}) === 8'b00111110);
      assign LRU_UPDATE_DATA_PT[28] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9], lru_tag4_dataout_q[10]}) === 9'b101111110);
      assign LRU_UPDATE_DATA_PT[29] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[9], lru_tag4_dataout_q[10]}) === 7'b1011110);
      assign LRU_UPDATE_DATA_PT[30] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[10]}) === 7'b1111000);
      assign LRU_UPDATE_DATA_PT[31] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[10]}) === 6'b111000);
      assign LRU_UPDATE_DATA_PT[32] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[10]}) === 7'b1111010);
      assign LRU_UPDATE_DATA_PT[33] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[10]}) === 6'b111010);
      assign LRU_UPDATE_DATA_PT[34] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], tlb_tag4_wayhit_q[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[10]}) === 7'b1001110);
      assign LRU_UPDATE_DATA_PT[35] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[10]}) === 7'b0001110);
      assign LRU_UPDATE_DATA_PT[36] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[10]}) === 7'b0001110);
      assign LRU_UPDATE_DATA_PT[37] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[10]}) === 7'b1000110);
      assign LRU_UPDATE_DATA_PT[38] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[10]}) === 7'b1001110);
      assign LRU_UPDATE_DATA_PT[39] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, lru_tag4_dataout_q[2], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6], lru_tag4_dataout_q[10]}) === 6'b111011);
      assign LRU_UPDATE_DATA_PT[40] = (({tlb_tag4_type_sig[7], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6], lru_tag4_dataout_q[10]}) === 6'b110111);
      assign LRU_UPDATE_DATA_PT[41] = (({tlb_tag4_hes_sig, tlb_tag4_is_sig[0], tlb_tag4_is_sig[1], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6], lru_tag4_dataout_q[10]}) === 7'b1100111);
      assign LRU_UPDATE_DATA_PT[42] = (({tlb_tag4_hes_sig, tlb_tag4_is_sig[0], tlb_tag4_is_sig[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6], lru_tag4_dataout_q[10]}) === 7'b1100111);
      assign LRU_UPDATE_DATA_PT[43] = (({tlb_tag4_type_sig[6], lru_tag4_dataout_q[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6], lru_tag4_dataout_q[10]}) === 5'b00111);
      assign LRU_UPDATE_DATA_PT[44] = (({tlb_tag4_type_sig[6], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[2], lru_tag4_dataout_q[6], lru_tag4_dataout_q[10]}) === 5'b00111);
      assign LRU_UPDATE_DATA_PT[45] = (({tlb_tag4_type_sig[6], tlb_tag4_wayhit_q[2], lru_tag4_dataout_q[2], lru_tag4_dataout_q[6], lru_tag4_dataout_q[10]}) === 5'b01111);
      assign LRU_UPDATE_DATA_PT[46] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[6], lru_tag4_dataout_q[10]}) === 6'b110111);
      assign LRU_UPDATE_DATA_PT[47] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[6], lru_tag4_dataout_q[10]}) === 6'b100111);
      assign LRU_UPDATE_DATA_PT[48] = (({tlb_tag4_type_sig[7], lru_tag4_dataout_q[2], lru_tag4_dataout_q[6], lru_tag4_dataout_q[10]}) === 4'b1111);
      assign LRU_UPDATE_DATA_PT[49] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], tlb_tag4_wayhit_q[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3], lru_tag4_dataout_q[10]}) === 9'b100111101);
      assign LRU_UPDATE_DATA_PT[50] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[10]}) === 8'b00011111);
      assign LRU_UPDATE_DATA_PT[51] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[10]}) === 7'b1011011);
      assign LRU_UPDATE_DATA_PT[52] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], tlb_tag4_is_sig[1], lru_tag4_dataout_q[1], lru_tag4_dataout_q[10]}) === 8'b10111001);
      assign LRU_UPDATE_DATA_PT[53] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], tlb_tag4_is_sig[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[10]}) === 8'b10111001);
      assign LRU_UPDATE_DATA_PT[54] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[3], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 9'b111111010);
      assign LRU_UPDATE_DATA_PT[55] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[3], lru_tag4_dataout_q[6], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 7'b1111010);
      assign LRU_UPDATE_DATA_PT[56] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 9'b111111110);
      assign LRU_UPDATE_DATA_PT[57] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[6], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 7'b1111110);
      assign LRU_UPDATE_DATA_PT[58] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 9'b000111110);
      assign LRU_UPDATE_DATA_PT[59] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 9'b000111110);
      assign LRU_UPDATE_DATA_PT[60] = (({tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 8'b00111110);
      assign LRU_UPDATE_DATA_PT[61] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[3], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 8'b10011110);
      assign LRU_UPDATE_DATA_PT[62] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 9'b101111110);
      assign LRU_UPDATE_DATA_PT[63] = (({tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[6], lru_tag4_dataout_q[9]}) === 7'b0011110);
      assign LRU_UPDATE_DATA_PT[64] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[6], lru_tag4_dataout_q[9]}) === 5'b10110);
      assign LRU_UPDATE_DATA_PT[65] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[9]}) === 6'b111000);
      assign LRU_UPDATE_DATA_PT[66] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[9]}) === 5'b11000);
      assign LRU_UPDATE_DATA_PT[67] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, lru_tag4_dataout_q[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[9]}) === 6'b111110);
      assign LRU_UPDATE_DATA_PT[68] = (({tlb_tag4_type_sig[7], lru_tag4_dataout_q[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[9]}) === 5'b11110);
      assign LRU_UPDATE_DATA_PT[69] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[5], lru_tag4_dataout_q[9]}) === 7'b0000110);
      assign LRU_UPDATE_DATA_PT[70] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[5], lru_tag4_dataout_q[9]}) === 6'b101110);
      assign LRU_UPDATE_DATA_PT[71] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3], lru_tag4_dataout_q[9]}) === 8'b00011110);
      assign LRU_UPDATE_DATA_PT[72] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[9]}) === 5'b10110);
      assign LRU_UPDATE_DATA_PT[73] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[9]}) === 6'b100010);
      assign LRU_UPDATE_DATA_PT[74] = (({tlb_tag4_type_sig[6], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 7'b0111111);
      assign LRU_UPDATE_DATA_PT[75] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 8'b11011111);
      assign LRU_UPDATE_DATA_PT[76] = (({tlb_tag4_type_sig[7], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 6'b111111);
      assign LRU_UPDATE_DATA_PT[77] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 10'b0001111111);
      assign LRU_UPDATE_DATA_PT[78] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 8'b00011111);
      assign LRU_UPDATE_DATA_PT[79] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_is_sig[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[8], lru_tag4_dataout_q[9]}) === 8'b10101111);
      assign LRU_UPDATE_DATA_PT[80] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], tlb_tag4_is_sig[1], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[9]}) === 8'b11111001);
      assign LRU_UPDATE_DATA_PT[81] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[9]}) === 6'b101111);
      assign LRU_UPDATE_DATA_PT[82] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3], lru_tag4_dataout_q[9]}) === 8'b10111101);
      assign LRU_UPDATE_DATA_PT[83] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[9]}) === 7'b1011101);
      assign LRU_UPDATE_DATA_PT[84] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], tlb_tag4_is_sig[1], lru_tag4_dataout_q[1], lru_tag4_dataout_q[9]}) === 8'b10001111);
      assign LRU_UPDATE_DATA_PT[85] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], lru_tag4_dataout_q[6], lru_tag4_dataout_q[8]}) === 4'b1110);
      assign LRU_UPDATE_DATA_PT[86] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], tlb_tag4_is_sig[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[8]}) === 8'b11111011);
      assign LRU_UPDATE_DATA_PT[87] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, lru_tag4_dataout_q[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[8]}) === 6'b111111);
      assign LRU_UPDATE_DATA_PT[88] = (({tlb_tag4_type_sig[6], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[5], lru_tag4_dataout_q[8]}) === 5'b00111);
      assign LRU_UPDATE_DATA_PT[89] = (({tlb_tag4_type_sig[6], tlb_tag4_wayhit_q[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[5], lru_tag4_dataout_q[8]}) === 5'b01111);
      assign LRU_UPDATE_DATA_PT[90] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[5], lru_tag4_dataout_q[8]}) === 6'b110111);
      assign LRU_UPDATE_DATA_PT[91] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[5], lru_tag4_dataout_q[8]}) === 6'b101111);
      assign LRU_UPDATE_DATA_PT[92] = (({tlb_tag4_type_sig[7], lru_tag4_dataout_q[0], lru_tag4_dataout_q[5], lru_tag4_dataout_q[8]}) === 4'b1111);
      assign LRU_UPDATE_DATA_PT[93] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[8]}) === 6'b101111);
      assign LRU_UPDATE_DATA_PT[94] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3], lru_tag4_dataout_q[8]}) === 7'b1111101);
      assign LRU_UPDATE_DATA_PT[95] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[8]}) === 6'b111101);
      assign LRU_UPDATE_DATA_PT[96] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[8]}) === 5'b11101);
      assign LRU_UPDATE_DATA_PT[97] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[8]}) === 7'b1001011);
      assign LRU_UPDATE_DATA_PT[98] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], tlb_tag4_is_sig[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[8]}) === 8'b10011111);
      assign LRU_UPDATE_DATA_PT[99] = (({tlb_tag4_type_sig[4], tlb_tag4_hes_sig, lru_tag4_dataout_q[0], lru_tag4_dataout_q[3], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[6]}) === 7'b0110110);
      assign LRU_UPDATE_DATA_PT[100] = (({tlb_tag4_type_sig[7], lru_tag4_dataout_q[0], lru_tag4_dataout_q[3], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[6]}) === 6'b110110);
      assign LRU_UPDATE_DATA_PT[101] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[3], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6]}) === 8'b11111010);
      assign LRU_UPDATE_DATA_PT[102] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[3], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6]}) === 7'b1111010);
      assign LRU_UPDATE_DATA_PT[103] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], tlb_tag4_is_sig[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6]}) === 6'b111110);
      assign LRU_UPDATE_DATA_PT[104] = (({tlb_tag4_hes_sig, lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[6]}) === 5'b10001);
      assign LRU_UPDATE_DATA_PT[105] = (({tlb_tag4_type_sig[7], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[6]}) === 5'b10001);
      assign LRU_UPDATE_DATA_PT[106] = (({tlb_tag4_hes_sig, lru_tag4_dataout_q[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[6]}) === 5'b10011);
      assign LRU_UPDATE_DATA_PT[107] = (({tlb_tag4_type_sig[6], lru_tag4_dataout_q[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[6]}) === 5'b00011);
      assign LRU_UPDATE_DATA_PT[108] = (({tlb_tag4_type_sig[4], tlb_tag4_hes_sig, lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[6]}) === 7'b0110111);
      assign LRU_UPDATE_DATA_PT[109] = (({tlb_tag4_type_sig[7], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5], lru_tag4_dataout_q[6]}) === 6'b110111);
      assign LRU_UPDATE_DATA_PT[110] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[4], lru_tag4_dataout_q[6]}) === 5'b11001);
      assign LRU_UPDATE_DATA_PT[111] = (({tlb_tag4_type_sig[4], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[6]}) === 7'b0111101);
      assign LRU_UPDATE_DATA_PT[112] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[6]}) === 6'b111101);
      assign LRU_UPDATE_DATA_PT[113] = (({tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], tlb_tag4_wayhit_q[2], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[2], lru_tag4_dataout_q[6]}) === 8'b00000011);
      assign LRU_UPDATE_DATA_PT[114] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[2], lru_tag4_dataout_q[2], lru_tag4_dataout_q[6]}) === 4'b1011);
      assign LRU_UPDATE_DATA_PT[115] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[6]}) === 5'b11011);
      assign LRU_UPDATE_DATA_PT[116] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], lru_tag4_dataout_q[1], lru_tag4_dataout_q[6]}) === 6'b100001);
      assign LRU_UPDATE_DATA_PT[117] = (({tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], lru_tag4_dataout_q[1], lru_tag4_dataout_q[6]}) === 4'b0001);
      assign LRU_UPDATE_DATA_PT[118] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[6]}) === 6'b100101);
      assign LRU_UPDATE_DATA_PT[119] = (({tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], lru_tag4_dataout_q[0], lru_tag4_dataout_q[6]}) === 4'b0001);
      assign LRU_UPDATE_DATA_PT[120] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], tlb_tag4_wayhit_q[2], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[6]}) === 6'b100001);
      assign LRU_UPDATE_DATA_PT[121] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_is_sig[0], lru_tag4_dataout_q[6]}) === 5'b10001);
      assign LRU_UPDATE_DATA_PT[122] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[6]}) === 3'b101);
      assign LRU_UPDATE_DATA_PT[123] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5]}) === 8'b11111000);
      assign LRU_UPDATE_DATA_PT[124] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5]}) === 7'b1111000);
      assign LRU_UPDATE_DATA_PT[125] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5]}) === 7'b1111000);
      assign LRU_UPDATE_DATA_PT[126] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5]}) === 6'b111000);
      assign LRU_UPDATE_DATA_PT[127] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5]}) === 6'b111000);
      assign LRU_UPDATE_DATA_PT[128] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5]}) === 5'b11000);
      assign LRU_UPDATE_DATA_PT[129] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5]}) === 8'b11111001);
      assign LRU_UPDATE_DATA_PT[130] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5]}) === 7'b1111001);
      assign LRU_UPDATE_DATA_PT[131] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5]}) === 7'b1111001);
      assign LRU_UPDATE_DATA_PT[132] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[4], lru_tag4_dataout_q[5]}) === 6'b111001);
      assign LRU_UPDATE_DATA_PT[133] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[3], lru_tag4_dataout_q[5]}) === 7'b1010101);
      assign LRU_UPDATE_DATA_PT[134] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], lru_tag4_dataout_q[0], lru_tag4_dataout_q[3], lru_tag4_dataout_q[5]}) === 6'b000101);
      assign LRU_UPDATE_DATA_PT[135] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[5]}) === 7'b1011101);
      assign LRU_UPDATE_DATA_PT[136] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[5]}) === 6'b000101);
      assign LRU_UPDATE_DATA_PT[137] = (({tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], tlb_tag4_wayhit_q[2], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[0], lru_tag4_dataout_q[5]}) === 8'b00000011);
      assign LRU_UPDATE_DATA_PT[138] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[5]}) === 4'b1011);
      assign LRU_UPDATE_DATA_PT[139] = (({tlb_tag4_type_sig[6], tlb_tag4_esel_sig[1], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[5]}) === 5'b11011);
      assign LRU_UPDATE_DATA_PT[140] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[5]}) === 5'b11011);
      assign LRU_UPDATE_DATA_PT[141] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], tlb_tag4_wayhit_q[2], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[5]}) === 6'b100001);
      assign LRU_UPDATE_DATA_PT[142] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[5]}) === 3'b101);
      assign LRU_UPDATE_DATA_PT[143] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4]}) === 5'b11101);
      assign LRU_UPDATE_DATA_PT[144] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4]}) === 5'b11101);
      assign LRU_UPDATE_DATA_PT[145] = (({tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], tlb_tag4_wayhit_q[2], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4]}) === 9'b000000111);
      assign LRU_UPDATE_DATA_PT[146] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4]}) === 6'b100111);
      assign LRU_UPDATE_DATA_PT[147] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[4]}) === 6'b110111);
      assign LRU_UPDATE_DATA_PT[148] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], tlb_tag4_wayhit_q[2], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[4]}) === 6'b100001);
      assign LRU_UPDATE_DATA_PT[149] = (({tlb_tag4_type_sig[7], tlb_tag4_is_sig[0], lru_tag4_dataout_q[4]}) === 3'b101);
      assign LRU_UPDATE_DATA_PT[150] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], tlb_tag4_wayhit_q[2], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3]}) === 9'b100011110);
      assign LRU_UPDATE_DATA_PT[151] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3]}) === 7'b0001110);
      assign LRU_UPDATE_DATA_PT[152] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3]}) === 8'b10001110);
      assign LRU_UPDATE_DATA_PT[153] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2], lru_tag4_dataout_q[3]}) === 8'b10011110);
      assign LRU_UPDATE_DATA_PT[154] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[3]}) === 8'b10101110);
      assign LRU_UPDATE_DATA_PT[155] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2]}) === 7'b1001110);
      assign LRU_UPDATE_DATA_PT[156] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], tlb_tag4_wayhit_q[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2]}) === 7'b1001110);
      assign LRU_UPDATE_DATA_PT[157] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2]}) === 7'b1011110);
      assign LRU_UPDATE_DATA_PT[158] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2]}) === 6'b000110);
      assign LRU_UPDATE_DATA_PT[159] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[1], lru_tag4_dataout_q[2]}) === 7'b1000110);
      assign LRU_UPDATE_DATA_PT[160] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[2]}) === 7'b1001110);
      assign LRU_UPDATE_DATA_PT[161] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[2]}) === 6'b101101);
      assign LRU_UPDATE_DATA_PT[162] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[3], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1]}) === 5'b10110);
      assign LRU_UPDATE_DATA_PT[163] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[2], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1]}) === 5'b10110);
      assign LRU_UPDATE_DATA_PT[164] = (({tlb_tag4_type_sig[4], tlb_tag4_wayhit_q[0], tlb_tag4_wayhit_q[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1]}) === 5'b10110);
      assign LRU_UPDATE_DATA_PT[165] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1]}) === 5'b10110);
      assign LRU_UPDATE_DATA_PT[166] = (({tlb_tag4_type_sig[4], tlb_tag4_type_sig[6], tlb_tag4_type_sig[7], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1]}) === 5'b00010);
      assign LRU_UPDATE_DATA_PT[167] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[1]}) === 6'b100010);
      assign LRU_UPDATE_DATA_PT[168] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0], lru_tag4_dataout_q[1]}) === 6'b101011);
      assign LRU_UPDATE_DATA_PT[169] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], lru_tag4_dataout_q[0]}) === 6'b100101);
      assign LRU_UPDATE_DATA_PT[170] = (({tlb_tag4_type_sig[6], tlb_tag4_hes_sig, tlb_tag4_esel_sig[1], tlb_tag4_esel_sig[2], tlb_tag4_is_sig[0], tlb_tag4_is_sig[1]}) === 6'b101011);
      
      assign lru_update_data[0] = (LRU_UPDATE_DATA_PT[1] | LRU_UPDATE_DATA_PT[2] | 
                                     LRU_UPDATE_DATA_PT[3] | LRU_UPDATE_DATA_PT[4] | 
                                     LRU_UPDATE_DATA_PT[5] | LRU_UPDATE_DATA_PT[6] | 
                                     LRU_UPDATE_DATA_PT[8] | LRU_UPDATE_DATA_PT[9] | 
                                     LRU_UPDATE_DATA_PT[10] | LRU_UPDATE_DATA_PT[11] | 
                                     LRU_UPDATE_DATA_PT[12] | LRU_UPDATE_DATA_PT[13] | 
                                     LRU_UPDATE_DATA_PT[14] | LRU_UPDATE_DATA_PT[23] | 
                                     LRU_UPDATE_DATA_PT[25] | LRU_UPDATE_DATA_PT[26] | 
                                     LRU_UPDATE_DATA_PT[27] | LRU_UPDATE_DATA_PT[28] | 
                                     LRU_UPDATE_DATA_PT[29] | LRU_UPDATE_DATA_PT[30] | 
                                     LRU_UPDATE_DATA_PT[31] | LRU_UPDATE_DATA_PT[32] | 
                                     LRU_UPDATE_DATA_PT[33] | LRU_UPDATE_DATA_PT[34] | 
                                     LRU_UPDATE_DATA_PT[35] | LRU_UPDATE_DATA_PT[36] | 
                                     LRU_UPDATE_DATA_PT[37] | LRU_UPDATE_DATA_PT[38] | 
                                     LRU_UPDATE_DATA_PT[49] | LRU_UPDATE_DATA_PT[74] | 
                                     LRU_UPDATE_DATA_PT[75] | LRU_UPDATE_DATA_PT[76] | 
                                     LRU_UPDATE_DATA_PT[77] | LRU_UPDATE_DATA_PT[78] | 
                                     LRU_UPDATE_DATA_PT[79] | LRU_UPDATE_DATA_PT[80] | 
                                     LRU_UPDATE_DATA_PT[81] | LRU_UPDATE_DATA_PT[82] | 
                                     LRU_UPDATE_DATA_PT[83] | LRU_UPDATE_DATA_PT[84] | 
                                     LRU_UPDATE_DATA_PT[86] | LRU_UPDATE_DATA_PT[93] | 
                                     LRU_UPDATE_DATA_PT[94] | LRU_UPDATE_DATA_PT[95] | 
                                     LRU_UPDATE_DATA_PT[98] | LRU_UPDATE_DATA_PT[101] | 
                                     LRU_UPDATE_DATA_PT[102] | LRU_UPDATE_DATA_PT[111] | 
                                     LRU_UPDATE_DATA_PT[112] | LRU_UPDATE_DATA_PT[123] | 
                                     LRU_UPDATE_DATA_PT[124] | LRU_UPDATE_DATA_PT[125] | 
                                     LRU_UPDATE_DATA_PT[126] | LRU_UPDATE_DATA_PT[129] | 
                                     LRU_UPDATE_DATA_PT[130] | LRU_UPDATE_DATA_PT[131] | 
                                     LRU_UPDATE_DATA_PT[132] | LRU_UPDATE_DATA_PT[145] | 
                                     LRU_UPDATE_DATA_PT[146] | LRU_UPDATE_DATA_PT[147] | 
                                     LRU_UPDATE_DATA_PT[148] | LRU_UPDATE_DATA_PT[149] | 
                                     LRU_UPDATE_DATA_PT[150] | LRU_UPDATE_DATA_PT[151] | 
                                     LRU_UPDATE_DATA_PT[152] | LRU_UPDATE_DATA_PT[153] | 
                                     LRU_UPDATE_DATA_PT[154] | LRU_UPDATE_DATA_PT[155] | 
                                     LRU_UPDATE_DATA_PT[156] | LRU_UPDATE_DATA_PT[157] | 
                                     LRU_UPDATE_DATA_PT[158] | LRU_UPDATE_DATA_PT[159] | 
                                     LRU_UPDATE_DATA_PT[160] | LRU_UPDATE_DATA_PT[168]);

      assign lru_update_data[1] = (LRU_UPDATE_DATA_PT[54] | LRU_UPDATE_DATA_PT[55] | 
                                     LRU_UPDATE_DATA_PT[56] | LRU_UPDATE_DATA_PT[57] | 
                                     LRU_UPDATE_DATA_PT[58] | LRU_UPDATE_DATA_PT[59] | 
                                     LRU_UPDATE_DATA_PT[60] | LRU_UPDATE_DATA_PT[61] | 
                                     LRU_UPDATE_DATA_PT[62] | LRU_UPDATE_DATA_PT[65] | 
                                     LRU_UPDATE_DATA_PT[66] | LRU_UPDATE_DATA_PT[67] | 
                                     LRU_UPDATE_DATA_PT[68] | LRU_UPDATE_DATA_PT[69] | 
                                     LRU_UPDATE_DATA_PT[70] | LRU_UPDATE_DATA_PT[71] | 
                                     LRU_UPDATE_DATA_PT[72] | LRU_UPDATE_DATA_PT[73] | 
                                     LRU_UPDATE_DATA_PT[77] | LRU_UPDATE_DATA_PT[80] | 
                                     LRU_UPDATE_DATA_PT[84] | LRU_UPDATE_DATA_PT[87] | 
                                     LRU_UPDATE_DATA_PT[88] | LRU_UPDATE_DATA_PT[89] | 
                                     LRU_UPDATE_DATA_PT[90] | LRU_UPDATE_DATA_PT[91] | 
                                     LRU_UPDATE_DATA_PT[92] | LRU_UPDATE_DATA_PT[96] | 
                                     LRU_UPDATE_DATA_PT[97] | LRU_UPDATE_DATA_PT[99] | 
                                     LRU_UPDATE_DATA_PT[100] | LRU_UPDATE_DATA_PT[108] | 
                                     LRU_UPDATE_DATA_PT[109] | LRU_UPDATE_DATA_PT[127] | 
                                     LRU_UPDATE_DATA_PT[128] | LRU_UPDATE_DATA_PT[133] | 
                                     LRU_UPDATE_DATA_PT[134] | LRU_UPDATE_DATA_PT[135] | 
                                     LRU_UPDATE_DATA_PT[136] | LRU_UPDATE_DATA_PT[137] | 
                                     LRU_UPDATE_DATA_PT[138] | LRU_UPDATE_DATA_PT[139] | 
                                     LRU_UPDATE_DATA_PT[140] | LRU_UPDATE_DATA_PT[141] | 
                                     LRU_UPDATE_DATA_PT[142] | LRU_UPDATE_DATA_PT[143] | 
                                     LRU_UPDATE_DATA_PT[144] | LRU_UPDATE_DATA_PT[162] | 
                                     LRU_UPDATE_DATA_PT[163] | LRU_UPDATE_DATA_PT[164] | 
                                     LRU_UPDATE_DATA_PT[165] | LRU_UPDATE_DATA_PT[166] | 
                                     LRU_UPDATE_DATA_PT[167] | LRU_UPDATE_DATA_PT[169]);

      assign lru_update_data[2] = (LRU_UPDATE_DATA_PT[1] | LRU_UPDATE_DATA_PT[2] | 
                                     LRU_UPDATE_DATA_PT[3] | LRU_UPDATE_DATA_PT[4] | 
                                     LRU_UPDATE_DATA_PT[5] | LRU_UPDATE_DATA_PT[6] | 
                                     LRU_UPDATE_DATA_PT[7] | LRU_UPDATE_DATA_PT[8] | 
                                     LRU_UPDATE_DATA_PT[9] | LRU_UPDATE_DATA_PT[10] | 
                                     LRU_UPDATE_DATA_PT[11] | LRU_UPDATE_DATA_PT[15] | 
                                     LRU_UPDATE_DATA_PT[16] | LRU_UPDATE_DATA_PT[17] | 
                                     LRU_UPDATE_DATA_PT[18] | LRU_UPDATE_DATA_PT[19] | 
                                     LRU_UPDATE_DATA_PT[20] | LRU_UPDATE_DATA_PT[21] | 
                                     LRU_UPDATE_DATA_PT[22] | LRU_UPDATE_DATA_PT[24] | 
                                     LRU_UPDATE_DATA_PT[39] | LRU_UPDATE_DATA_PT[40] | 
                                     LRU_UPDATE_DATA_PT[41] | LRU_UPDATE_DATA_PT[42] | 
                                     LRU_UPDATE_DATA_PT[43] | LRU_UPDATE_DATA_PT[44] | 
                                     LRU_UPDATE_DATA_PT[45] | LRU_UPDATE_DATA_PT[46] | 
                                     LRU_UPDATE_DATA_PT[47] | LRU_UPDATE_DATA_PT[48] | 
                                     LRU_UPDATE_DATA_PT[49] | LRU_UPDATE_DATA_PT[50] | 
                                     LRU_UPDATE_DATA_PT[51] | LRU_UPDATE_DATA_PT[52] | 
                                     LRU_UPDATE_DATA_PT[53] | LRU_UPDATE_DATA_PT[63] | 
                                     LRU_UPDATE_DATA_PT[64] | LRU_UPDATE_DATA_PT[82] | 
                                     LRU_UPDATE_DATA_PT[85] | LRU_UPDATE_DATA_PT[94] | 
                                     LRU_UPDATE_DATA_PT[101] | LRU_UPDATE_DATA_PT[102] | 
                                     LRU_UPDATE_DATA_PT[103] | LRU_UPDATE_DATA_PT[104] | 
                                     LRU_UPDATE_DATA_PT[105] | LRU_UPDATE_DATA_PT[106] | 
                                     LRU_UPDATE_DATA_PT[107] | LRU_UPDATE_DATA_PT[110] | 
                                     LRU_UPDATE_DATA_PT[113] | LRU_UPDATE_DATA_PT[114] | 
                                     LRU_UPDATE_DATA_PT[115] | LRU_UPDATE_DATA_PT[116] | 
                                     LRU_UPDATE_DATA_PT[117] | LRU_UPDATE_DATA_PT[118] | 
                                     LRU_UPDATE_DATA_PT[119] | LRU_UPDATE_DATA_PT[120] | 
                                     LRU_UPDATE_DATA_PT[121] | LRU_UPDATE_DATA_PT[122] | 
                                     LRU_UPDATE_DATA_PT[123] | LRU_UPDATE_DATA_PT[124] | 
                                     LRU_UPDATE_DATA_PT[129] | LRU_UPDATE_DATA_PT[130] | 
                                     LRU_UPDATE_DATA_PT[150] | LRU_UPDATE_DATA_PT[151] | 
                                     LRU_UPDATE_DATA_PT[152] | LRU_UPDATE_DATA_PT[153] | 
                                     LRU_UPDATE_DATA_PT[154] | LRU_UPDATE_DATA_PT[161] | 
                                     LRU_UPDATE_DATA_PT[170]);


      

      generate
         if (`RS_DATA_WIDTH == 64)
         begin : gen64_tlb_datain
            assign tlb_datain_lo_tlbwe_0_nopar[0:`TLB_WORD_WIDTH - 10 - 1] = 
               { (tlb_tag4_q[`tagpos_epn:`tagpos_epn + 31] & {32{tlb_tag4_q[`tagpos_cm]}}), tlb_tag4_q[`tagpos_epn + 32:`tagpos_epn + `EPN_WIDTH - 1], tlb_tag4_q[`tagpos_size:`tagpos_size + 3], mmucr3_0[60:63], 
                  mmucr3_0[54:55], (mmucr3_0[52] & tlb_tag4_q[`tagpos_is + 1]), |(tlb_tag4_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]), 
                  2'b00, tlb_tag4_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] };

`ifdef MM_THREADS2      
            assign tlb_datain_lo_tlbwe_1_nopar[0:`TLB_WORD_WIDTH - 10 - 1] = 
               { (tlb_tag4_q[`tagpos_epn:`tagpos_epn + 31] & {32{tlb_tag4_q[`tagpos_cm]}}), tlb_tag4_q[`tagpos_epn + 32:`tagpos_epn + `EPN_WIDTH - 1], tlb_tag4_q[`tagpos_size:`tagpos_size + 3], mmucr3_1[60:63], 
                  mmucr3_1[54:55], (mmucr3_1[52] & tlb_tag4_q[`tagpos_is + 1]), |(tlb_tag4_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]), 
                  2'b00, tlb_tag4_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] };
`endif
            assign tlb_datain_lo_ptereload_nopar[0:`TLB_WORD_WIDTH - 10 - 1] = {tlb_tag4_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1], 1'b0, ptereload_req_pte_lat[`ptepos_size:`ptepos_size + 2], tlb_tag4_q[`tagpos_atsel], tlb_tag4_q[`tagpos_esel:`tagpos_esel + 2], tlb_tag4_q[`tagpos_class], (tlb_tag4_q[`tagpos_class] & tlb_tag4_q[`tagpos_class + 1]), 1'b0, |(tlb_tag4_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]), 2'b00, tlb_tag4_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1]};

            assign tlb_dataina_d[0:`TLB_WORD_WIDTH - 1] = (tlb_tag4_q[`tagpos_thdid + 0] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1) ? {tlb_datain_lo_tlbwe_0_nopar, tlb_datain_lo_tlbwe_0_par} : 
`ifdef MM_THREADS2      
                                                         (tlb_tag4_q[`tagpos_thdid + 1] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1) ? {tlb_datain_lo_tlbwe_1_nopar, tlb_datain_lo_tlbwe_1_par} : 
`endif
                                                         (tlb_tag4_ptereload_sig == 1'b1) ? {tlb_datain_lo_ptereload_nopar, tlb_datain_lo_ptereload_par} : 
                                                         (tlb_tag4_parerr_zeroize == 1'b1) ? {`TLB_WORD_WIDTH{1'b0}} :   
                                                         tlb_dataina_q[0:`TLB_WORD_WIDTH - 1];
                                                         
            assign tlb_datainb_d[0:`TLB_WORD_WIDTH - 1] = (tlb_tag4_q[`tagpos_thdid + 0] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1) ? {tlb_datain_lo_tlbwe_0_nopar, tlb_datain_lo_tlbwe_0_par} : 
`ifdef MM_THREADS2      
                                                         (tlb_tag4_q[`tagpos_thdid + 1] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1) ? {tlb_datain_lo_tlbwe_1_nopar, tlb_datain_lo_tlbwe_1_par} : 
`endif
                                                         (tlb_tag4_ptereload_sig == 1'b1) ? {tlb_datain_lo_ptereload_nopar, tlb_datain_lo_ptereload_par} : 
                                                         (tlb_tag4_parerr_zeroize == 1'b1) ? {`TLB_WORD_WIDTH{1'b0}} :   
                                                         tlb_datainb_q[0:`TLB_WORD_WIDTH - 1];
         end
      endgenerate

      generate
         if (`RS_DATA_WIDTH == 32)
         begin : gen32_tlb_datain
            assign tlb_datain_lo_tlbwe_0_nopar[0:`TLB_WORD_WIDTH - 10 - 1] = 
                { {32{1'b0}}, tlb_tag4_q[`tagpos_epn + 32:`tagpos_epn + `EPN_WIDTH - 1], tlb_tag4_q[`tagpos_size:`tagpos_size + 3], mmucr3_0[60:63], 
                   mmucr3_0[54:55], (mmucr3_0[52] & tlb_tag4_q[`tagpos_is + 1]), |(tlb_tag4_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]), 
                   2'b00, tlb_tag4_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] };

`ifdef MM_THREADS2      
            assign tlb_datain_lo_tlbwe_1_nopar[0:`TLB_WORD_WIDTH - 10 - 1] = 
                { {32{1'b0}}, tlb_tag4_q[`tagpos_epn + 32:`tagpos_epn + `EPN_WIDTH - 1], tlb_tag4_q[`tagpos_size:`tagpos_size + 3], mmucr3_1[60:63], 
                   mmucr3_1[54:55], (mmucr3_1[52] & tlb_tag4_q[`tagpos_is + 1]), |(tlb_tag4_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]), 
                   2'b00, tlb_tag4_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] };
`endif

            assign tlb_datain_lo_ptereload_nopar[0:`TLB_WORD_WIDTH - 10 - 1] = {1'b0, tlb_tag4_q[`tagpos_epn + 32:`tagpos_epn + `EPN_WIDTH + 32 - 1], 1'b0, ptereload_req_pte_lat[`ptepos_size:`ptepos_size + 2], 4'b1111, tlb_tag4_q[`tagpos_class:`tagpos_class + 1], 1'b0, |(tlb_tag4_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]), 2'b00, tlb_tag4_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1]};

            assign tlb_dataina_d[0:`TLB_WORD_WIDTH - 1] = (tlb_tag4_q[`tagpos_thdid + 0] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1) ? {tlb_datain_lo_tlbwe_0_nopar, tlb_datain_lo_tlbwe_0_par} : 
`ifdef MM_THREADS2      
                                                         (tlb_tag4_q[`tagpos_thdid + 1] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1) ? {tlb_datain_lo_tlbwe_1_nopar, tlb_datain_lo_tlbwe_1_par} : 
`endif
                                                         (tlb_tag4_ptereload_sig == 1'b1) ? {tlb_datain_lo_ptereload_nopar, tlb_datain_lo_ptereload_par} : 
                                                         (tlb_tag4_parerr_zeroize == 1'b1) ? {`TLB_WORD_WIDTH{1'b0}} :   
                                                         tlb_dataina_q[0:`TLB_WORD_WIDTH - 1];
                                                         
            assign tlb_datainb_d[0:`TLB_WORD_WIDTH - 1] = (tlb_tag4_q[`tagpos_thdid + 0] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1) ? {tlb_datain_lo_tlbwe_0_nopar, tlb_datain_lo_tlbwe_0_par} : 
`ifdef MM_THREADS2      
                                                         (tlb_tag4_q[`tagpos_thdid + 1] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1) ? {tlb_datain_lo_tlbwe_1_nopar, tlb_datain_lo_tlbwe_1_par} : 
`endif
                                                         (tlb_tag4_ptereload_sig == 1'b1) ? {tlb_datain_lo_ptereload_nopar, tlb_datain_lo_ptereload_par} : 
                                                         (tlb_tag4_parerr_zeroize == 1'b1) ? {`TLB_WORD_WIDTH{1'b0}} :   
                                                         tlb_datainb_q[0:`TLB_WORD_WIDTH - 1];
         end
      endgenerate

      assign ptereload_req_derived_usxwr[0] = ptereload_req_pte_lat[`ptepos_usxwr + 0] & ptereload_req_pte_lat[`ptepos_r];
      assign ptereload_req_derived_usxwr[1] = ptereload_req_pte_lat[`ptepos_usxwr + 1] & ptereload_req_pte_lat[`ptepos_r];
      assign ptereload_req_derived_usxwr[2] = ptereload_req_pte_lat[`ptepos_usxwr + 2] & ptereload_req_pte_lat[`ptepos_r] & ptereload_req_pte_lat[`ptepos_c];
      assign ptereload_req_derived_usxwr[3] = ptereload_req_pte_lat[`ptepos_usxwr + 3] & ptereload_req_pte_lat[`ptepos_r] & ptereload_req_pte_lat[`ptepos_c];
      assign ptereload_req_derived_usxwr[4] = ptereload_req_pte_lat[`ptepos_usxwr + 4] & ptereload_req_pte_lat[`ptepos_r];
      assign ptereload_req_derived_usxwr[5] = ptereload_req_pte_lat[`ptepos_usxwr + 5] & ptereload_req_pte_lat[`ptepos_r];
      
      generate
         if (`REAL_ADDR_WIDTH < 42)
         begin : gen32_lrat_tag3_lpn
            assign lrat_tag3_lpn_sig[22:63 - `REAL_ADDR_WIDTH] = {2{1'b0}};
            assign lrat_tag3_lpn_sig[64 - `REAL_ADDR_WIDTH:51] = lrat_tag3_lpn[64 - `REAL_ADDR_WIDTH:51];
         end
      endgenerate
      
      generate
         if (`REAL_ADDR_WIDTH > 41)
         begin : gen64_lrat_tag3_lpn
            assign lrat_tag3_lpn_sig[64 - `REAL_ADDR_WIDTH:51] = lrat_tag3_lpn[64 - `REAL_ADDR_WIDTH:51];
         end
      endgenerate
      
      generate
         if (`REAL_ADDR_WIDTH < 42)
         begin : gen32_lrat_tag3_rpn
            assign lrat_tag3_rpn_sig[22:63 - `REAL_ADDR_WIDTH] = {2{1'b0}};
            assign lrat_tag3_rpn_sig[64 - `REAL_ADDR_WIDTH:51] = lrat_tag3_rpn[64 - `REAL_ADDR_WIDTH:51];
         end
      endgenerate
      
      generate
         if (`REAL_ADDR_WIDTH > 41)
         begin : gen64_lrat_tag3_rpn
            assign lrat_tag3_rpn_sig[64 - `REAL_ADDR_WIDTH:51] = lrat_tag3_rpn[64 - `REAL_ADDR_WIDTH:51];
         end
      endgenerate
      
      generate
         if (`REAL_ADDR_WIDTH < 42)
         begin : gen32_lrat_tag4_lpn
            assign lrat_tag4_lpn_sig[22:63 - `REAL_ADDR_WIDTH] = {2{1'b0}};
            assign lrat_tag4_lpn_sig[64 - `REAL_ADDR_WIDTH:51] = lrat_tag4_lpn[64 - `REAL_ADDR_WIDTH:51];
         end
      endgenerate
      
      generate
         if (`REAL_ADDR_WIDTH > 41)
         begin : gen64_lrat_tag4_lpn
            assign lrat_tag4_lpn_sig[64 - `REAL_ADDR_WIDTH:51] = lrat_tag4_lpn[64 - `REAL_ADDR_WIDTH:51];
         end
      endgenerate
      
      generate
         if (`REAL_ADDR_WIDTH < 42)
         begin : gen32_lrat_tag4_rpn
            assign lrat_tag4_rpn_sig[22:63 - `REAL_ADDR_WIDTH] = {2{1'b0}};
            assign lrat_tag4_rpn_sig[64 - `REAL_ADDR_WIDTH:51] = lrat_tag4_rpn[64 - `REAL_ADDR_WIDTH:51];
         end
      endgenerate
      
      generate
         if (`REAL_ADDR_WIDTH > 41)
         begin : gen64_lrat_tag4_rpn
            assign lrat_tag4_rpn_sig[64 - `REAL_ADDR_WIDTH:51] = lrat_tag4_rpn[64 - `REAL_ADDR_WIDTH:51];
         end
      endgenerate
      
      assign tlb_datain_hi_hv_tlbwe_0_nopar = 
                                                {mmucr3_0[49], (tstmode4k_0 & {3{~tlb_tag4_q[`tagpos_ind]}}), mas7_0_rpnu, mas3_0_rpnl[32:51], mmucr3_0[50:51], 
                                                 mmucr3_0[56:58], mas8_0_vf, (tlb_tag4_q[`tagpos_ind] & tlb0cfg_ind), mas3_0_ubits, mas2_0_wimge, 
                                                 mas3_0_usxwr[0:3], 
                                                  (mas3_0_usxwr[4] & ((~tlb_tag4_q[`tagpos_ind]) | (~tlb0cfg_ind))), 
                                                 ((mas3_0_usxwr[5] & ((~tlb_tag4_q[`tagpos_ind]) | (~tlb0cfg_ind))) | (mas3_0_rpnl[52] & tlb_tag4_q[`tagpos_ind] & tlb0cfg_ind)), 
                                                 tlb_tag4_q[`tagpos_pt], tlb_tag4_q[`tagpos_recform], 2'b00, tlb_tag4_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]};
                                                 
      assign tlb_datain_hi_gs_tlbwe_0_nopar = 
                                                {mmucr3_0[49], (tstmode4k_0 & {3{~tlb_tag4_q[`tagpos_ind]}}), lrat_tag4_rpn_sig[22:51], mmucr3_0[50:51], 
                                                 mmucr3_0[56:58], mas8_0_vf, (tlb_tag4_q[`tagpos_ind] & tlb0cfg_ind), mas3_0_ubits, mas2_0_wimge, 
                                                 mas3_0_usxwr[0:3], 
                                                 (mas3_0_usxwr[4] & ((~tlb_tag4_q[`tagpos_ind]) | (~tlb0cfg_ind))), 
                                                 ((mas3_0_usxwr[5] & ((~tlb_tag4_q[`tagpos_ind]) | (~tlb0cfg_ind))) | (mas3_0_rpnl[52] & tlb_tag4_q[`tagpos_ind] & tlb0cfg_ind)), 
                                                 tlb_tag4_q[`tagpos_pt], tlb_tag4_q[`tagpos_recform], 2'b00, tlb_tag4_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]};
`ifdef MM_THREADS2
      assign tlb_datain_hi_hv_tlbwe_1_nopar = 
                                                {mmucr3_1[49], (tstmode4k_1 & {3{~tlb_tag4_q[`tagpos_ind]}}), mas7_1_rpnu, mas3_1_rpnl[32:51], mmucr3_1[50:51], 
                                                 mmucr3_1[56:58], mas8_1_vf, (tlb_tag4_q[`tagpos_ind] & tlb0cfg_ind), mas3_1_ubits, mas2_1_wimge, 
                                                 mas3_1_usxwr[0:3], 
                                                 (mas3_1_usxwr[4] & ((~tlb_tag4_q[`tagpos_ind]) | (~tlb0cfg_ind))), 
                                                 ((mas3_1_usxwr[5] & ((~tlb_tag4_q[`tagpos_ind]) | (~tlb0cfg_ind))) | (mas3_1_rpnl[52] & tlb_tag4_q[`tagpos_ind] & tlb0cfg_ind)), 
                                                 tlb_tag4_q[`tagpos_pt], tlb_tag4_q[`tagpos_recform], 2'b00, tlb_tag4_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]};

      assign tlb_datain_hi_gs_tlbwe_1_nopar = 
                                                {mmucr3_1[49], (tstmode4k_1 & {3{~tlb_tag4_q[`tagpos_ind]}}), lrat_tag4_rpn_sig[22:51], mmucr3_1[50:51], 
                                                mmucr3_1[56:58], mas8_1_vf, (tlb_tag4_q[`tagpos_ind] & tlb0cfg_ind), mas3_1_ubits, mas2_1_wimge, 
                                                mas3_1_usxwr[0:3], 
                                                (mas3_1_usxwr[4] & ((~tlb_tag4_q[`tagpos_ind]) | (~tlb0cfg_ind))), 
                                                ((mas3_1_usxwr[5] & ((~tlb_tag4_q[`tagpos_ind]) | (~tlb0cfg_ind))) | (mas3_1_rpnl[52] & tlb_tag4_q[`tagpos_ind] & tlb0cfg_ind)), 
                                                tlb_tag4_q[`tagpos_pt], tlb_tag4_q[`tagpos_recform], 2'b00, tlb_tag4_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]};
`endif

      assign tlb_datain_hi_hv_ptereload_nopar = {1'b0, 3'b000, ptereload_req_pte_lat[`ptepos_rpn + 10:`ptepos_rpn + 39], ptereload_req_pte_lat[`ptepos_r], ptereload_req_pte_lat[`ptepos_c], 2'b00, 1'b0, 1'b0, 1'b0, ptereload_req_pte_lat[`ptepos_ubits:`ptepos_ubits + 3], ptereload_req_pte_lat[`ptepos_wimge:`ptepos_wimge + 4], ptereload_req_derived_usxwr[0:5], tlb_tag4_q[`tagpos_gs], tlb_tag4_q[`tagpos_as], 2'b00, tlb_tag4_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]};
      assign tlb_datain_hi_gs_ptereload_nopar = {1'b0, 3'b000, lrat_tag4_rpn_sig[22:51], ptereload_req_pte_lat[`ptepos_r], ptereload_req_pte_lat[`ptepos_c], 2'b00, 1'b0, 1'b0, 1'b0, ptereload_req_pte_lat[`ptepos_ubits:`ptepos_ubits + 3], ptereload_req_pte_lat[`ptepos_wimge:`ptepos_wimge + 4], ptereload_req_derived_usxwr[0:5], tlb_tag4_q[`tagpos_gs], tlb_tag4_q[`tagpos_as], 2'b00, tlb_tag4_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]};
      assign tlb_dataina_d[`TLB_WORD_WIDTH:2 * `TLB_WORD_WIDTH - 1] = (tlb_tag4_q[`tagpos_thdid + 0] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & (tlb_tag4_q[`tagpos_gs] == 1'b0 | tlb_tag4_q[`tagpos_is] == 1'b0)) ? {tlb_datain_hi_hv_tlbwe_0_nopar, tlb_datain_hi_hv_tlbwe_0_par} : 
                                                                    (tlb_tag4_q[`tagpos_thdid + 0] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1 & tlb_tag4_q[`tagpos_is] == 1'b1) ? {tlb_datain_hi_gs_tlbwe_0_nopar, tlb_datain_hi_gs_tlbwe_0_par} : 
`ifdef MM_THREADS2                                                                    
                                                                    (tlb_tag4_q[`tagpos_thdid + 1] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & (tlb_tag4_q[`tagpos_gs] == 1'b0 | tlb_tag4_q[`tagpos_is] == 1'b0)) ? {tlb_datain_hi_hv_tlbwe_1_nopar, tlb_datain_hi_hv_tlbwe_1_par} : 
                                                                    (tlb_tag4_q[`tagpos_thdid + 1] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1 & tlb_tag4_q[`tagpos_is] == 1'b1) ? {tlb_datain_hi_gs_tlbwe_1_nopar, tlb_datain_hi_gs_tlbwe_1_par} : 
`endif
                                                                    (tlb_tag4_ptereload_sig == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b0) ? {tlb_datain_hi_hv_ptereload_nopar, tlb_datain_hi_hv_ptereload_par} : 
                                                                    (tlb_tag4_ptereload_sig == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1) ? {tlb_datain_hi_gs_ptereload_nopar, tlb_datain_hi_gs_ptereload_par} : 
                                                                    (tlb_tag4_parerr_zeroize == 1'b1) ? {`TLB_WORD_WIDTH{1'b0}} :   
                                                                    tlb_dataina_q[`TLB_WORD_WIDTH:2 * `TLB_WORD_WIDTH - 1];
                                                                    
      assign tlb_datainb_d[`TLB_WORD_WIDTH:2 * `TLB_WORD_WIDTH - 1] = (tlb_tag4_q[`tagpos_thdid + 0] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & (tlb_tag4_q[`tagpos_gs] == 1'b0 | tlb_tag4_q[`tagpos_is] == 1'b0)) ? {tlb_datain_hi_hv_tlbwe_0_nopar, tlb_datain_hi_hv_tlbwe_0_par} : 
                                                                    (tlb_tag4_q[`tagpos_thdid + 0] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1 & tlb_tag4_q[`tagpos_is] == 1'b1) ? {tlb_datain_hi_gs_tlbwe_0_nopar, tlb_datain_hi_gs_tlbwe_0_par} :
`ifdef MM_THREADS2                                                                     
                                                                    (tlb_tag4_q[`tagpos_thdid + 1] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & (tlb_tag4_q[`tagpos_gs] == 1'b0 | tlb_tag4_q[`tagpos_is] == 1'b0)) ? {tlb_datain_hi_hv_tlbwe_1_nopar, tlb_datain_hi_hv_tlbwe_1_par} : 
                                                                    (tlb_tag4_q[`tagpos_thdid + 1] == 1'b1 & tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1 & tlb_tag4_q[`tagpos_is] == 1'b1) ? {tlb_datain_hi_gs_tlbwe_1_nopar, tlb_datain_hi_gs_tlbwe_1_par} : 
`endif                                                                    
                                                                    (tlb_tag4_ptereload_sig == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b0) ? {tlb_datain_hi_hv_ptereload_nopar, tlb_datain_hi_hv_ptereload_par} : 
                                                                    (tlb_tag4_ptereload_sig == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1) ? {tlb_datain_hi_gs_ptereload_nopar, tlb_datain_hi_gs_ptereload_par} : 
                                                                    (tlb_tag4_parerr_zeroize == 1'b1) ? {`TLB_WORD_WIDTH{1'b0}} :   
                                                                    tlb_datainb_q[`TLB_WORD_WIDTH:2 * `TLB_WORD_WIDTH - 1];
      assign tlb_datain_lo_tlbwe_0_par[0] = ^(tlb_datain_lo_tlbwe_0_nopar[0:7]);
      assign tlb_datain_lo_tlbwe_0_par[1] = ^(tlb_datain_lo_tlbwe_0_nopar[8:15]);
      assign tlb_datain_lo_tlbwe_0_par[2] = ^(tlb_datain_lo_tlbwe_0_nopar[16:23]);
      assign tlb_datain_lo_tlbwe_0_par[3] = ^(tlb_datain_lo_tlbwe_0_nopar[24:31]);
      assign tlb_datain_lo_tlbwe_0_par[4] = ^(tlb_datain_lo_tlbwe_0_nopar[32:39]);
      assign tlb_datain_lo_tlbwe_0_par[5] = ^(tlb_datain_lo_tlbwe_0_nopar[40:47]);
      assign tlb_datain_lo_tlbwe_0_par[6] = ^({tlb_datain_lo_tlbwe_0_nopar[48:51], mmucr1_q[pos_tlb_pei]});
      assign tlb_datain_lo_tlbwe_0_par[7] = ^(tlb_datain_lo_tlbwe_0_nopar[52:59]);
      assign tlb_datain_lo_tlbwe_0_par[8] = ^(tlb_datain_lo_tlbwe_0_nopar[60:65]);
      assign tlb_datain_lo_tlbwe_0_par[9] = ^(tlb_datain_lo_tlbwe_0_nopar[66:73]);
`ifdef MM_THREADS2      
      assign tlb_datain_lo_tlbwe_1_par[0] = ^(tlb_datain_lo_tlbwe_1_nopar[0:7]);
      assign tlb_datain_lo_tlbwe_1_par[1] = ^(tlb_datain_lo_tlbwe_1_nopar[8:15]);
      assign tlb_datain_lo_tlbwe_1_par[2] = ^(tlb_datain_lo_tlbwe_1_nopar[16:23]);
      assign tlb_datain_lo_tlbwe_1_par[3] = ^(tlb_datain_lo_tlbwe_1_nopar[24:31]);
      assign tlb_datain_lo_tlbwe_1_par[4] = ^(tlb_datain_lo_tlbwe_1_nopar[32:39]);
      assign tlb_datain_lo_tlbwe_1_par[5] = ^(tlb_datain_lo_tlbwe_1_nopar[40:47]);
      assign tlb_datain_lo_tlbwe_1_par[6] = ^({tlb_datain_lo_tlbwe_1_nopar[48:51], mmucr1_q[pos_tlb_pei]});
      assign tlb_datain_lo_tlbwe_1_par[7] = ^(tlb_datain_lo_tlbwe_1_nopar[52:59]);
      assign tlb_datain_lo_tlbwe_1_par[8] = ^(tlb_datain_lo_tlbwe_1_nopar[60:65]);
      assign tlb_datain_lo_tlbwe_1_par[9] = ^(tlb_datain_lo_tlbwe_1_nopar[66:73]);
`endif
      assign tlb_datain_lo_ptereload_par[0] = ^(tlb_datain_lo_ptereload_nopar[0:7]);
      assign tlb_datain_lo_ptereload_par[1] = ^(tlb_datain_lo_ptereload_nopar[8:15]);
      assign tlb_datain_lo_ptereload_par[2] = ^(tlb_datain_lo_ptereload_nopar[16:23]);
      assign tlb_datain_lo_ptereload_par[3] = ^(tlb_datain_lo_ptereload_nopar[24:31]);
      assign tlb_datain_lo_ptereload_par[4] = ^(tlb_datain_lo_ptereload_nopar[32:39]);
      assign tlb_datain_lo_ptereload_par[5] = ^(tlb_datain_lo_ptereload_nopar[40:47]);
      assign tlb_datain_lo_ptereload_par[6] = ^(tlb_datain_lo_ptereload_nopar[48:51]);
      assign tlb_datain_lo_ptereload_par[7] = ^(tlb_datain_lo_ptereload_nopar[52:59]);
      assign tlb_datain_lo_ptereload_par[8] = ^(tlb_datain_lo_ptereload_nopar[60:65]);
      assign tlb_datain_lo_ptereload_par[9] = ^(tlb_datain_lo_ptereload_nopar[66:73]);
      assign tlb_datain_hi_hv_tlbwe_0_par[0] = ^(tlb_datain_hi_hv_tlbwe_0_nopar[0:7]);
      assign tlb_datain_hi_hv_tlbwe_0_par[1] = ^(tlb_datain_hi_hv_tlbwe_0_nopar[8:15]);
      assign tlb_datain_hi_hv_tlbwe_0_par[2] = ^(tlb_datain_hi_hv_tlbwe_0_nopar[16:23]);
      assign tlb_datain_hi_hv_tlbwe_0_par[3] = ^(tlb_datain_hi_hv_tlbwe_0_nopar[24:31]);
      assign tlb_datain_hi_hv_tlbwe_0_par[4] = ^(tlb_datain_hi_hv_tlbwe_0_nopar[32:39]);
      assign tlb_datain_hi_hv_tlbwe_0_par[5] = ^(tlb_datain_hi_hv_tlbwe_0_nopar[40:44]);
      assign tlb_datain_hi_hv_tlbwe_0_par[6] = ^(tlb_datain_hi_hv_tlbwe_0_nopar[45:49]);
      assign tlb_datain_hi_hv_tlbwe_0_par[7] = ^(tlb_datain_hi_hv_tlbwe_0_nopar[50:57]);
      assign tlb_datain_hi_hv_tlbwe_0_par[8] = ^(tlb_datain_hi_hv_tlbwe_0_nopar[58:65]);
      assign tlb_datain_hi_hv_tlbwe_0_par[9] = ^(tlb_datain_hi_hv_tlbwe_0_nopar[66:73]);
`ifdef MM_THREADS2       
      assign tlb_datain_hi_hv_tlbwe_1_par[0] = ^(tlb_datain_hi_hv_tlbwe_1_nopar[0:7]);
      assign tlb_datain_hi_hv_tlbwe_1_par[1] = ^(tlb_datain_hi_hv_tlbwe_1_nopar[8:15]);
      assign tlb_datain_hi_hv_tlbwe_1_par[2] = ^(tlb_datain_hi_hv_tlbwe_1_nopar[16:23]);
      assign tlb_datain_hi_hv_tlbwe_1_par[3] = ^(tlb_datain_hi_hv_tlbwe_1_nopar[24:31]);
      assign tlb_datain_hi_hv_tlbwe_1_par[4] = ^(tlb_datain_hi_hv_tlbwe_1_nopar[32:39]);
      assign tlb_datain_hi_hv_tlbwe_1_par[5] = ^(tlb_datain_hi_hv_tlbwe_1_nopar[40:44]);
      assign tlb_datain_hi_hv_tlbwe_1_par[6] = ^(tlb_datain_hi_hv_tlbwe_1_nopar[45:49]);
      assign tlb_datain_hi_hv_tlbwe_1_par[7] = ^(tlb_datain_hi_hv_tlbwe_1_nopar[50:57]);
      assign tlb_datain_hi_hv_tlbwe_1_par[8] = ^(tlb_datain_hi_hv_tlbwe_1_nopar[58:65]);
      assign tlb_datain_hi_hv_tlbwe_1_par[9] = ^(tlb_datain_hi_hv_tlbwe_1_nopar[66:73]);
`endif      
      assign tlb_datain_hi_gs_tlbwe_0_par[0] = ^(tlb_datain_hi_gs_tlbwe_0_nopar[0:7]);
      assign tlb_datain_hi_gs_tlbwe_0_par[1] = ^(tlb_datain_hi_gs_tlbwe_0_nopar[8:15]);
      assign tlb_datain_hi_gs_tlbwe_0_par[2] = ^(tlb_datain_hi_gs_tlbwe_0_nopar[16:23]);
      assign tlb_datain_hi_gs_tlbwe_0_par[3] = ^(tlb_datain_hi_gs_tlbwe_0_nopar[24:31]);
      assign tlb_datain_hi_gs_tlbwe_0_par[4] = ^(tlb_datain_hi_gs_tlbwe_0_nopar[32:39]);
      assign tlb_datain_hi_gs_tlbwe_0_par[5] = ^(tlb_datain_hi_gs_tlbwe_0_nopar[40:44]);
      assign tlb_datain_hi_gs_tlbwe_0_par[6] = ^(tlb_datain_hi_gs_tlbwe_0_nopar[45:49]);
      assign tlb_datain_hi_gs_tlbwe_0_par[7] = ^(tlb_datain_hi_gs_tlbwe_0_nopar[50:57]);
      assign tlb_datain_hi_gs_tlbwe_0_par[8] = ^(tlb_datain_hi_gs_tlbwe_0_nopar[58:65]);
      assign tlb_datain_hi_gs_tlbwe_0_par[9] = ^(tlb_datain_hi_gs_tlbwe_0_nopar[66:73]);
`ifdef MM_THREADS2      
      assign tlb_datain_hi_gs_tlbwe_1_par[0] = ^(tlb_datain_hi_gs_tlbwe_1_nopar[0:7]);
      assign tlb_datain_hi_gs_tlbwe_1_par[1] = ^(tlb_datain_hi_gs_tlbwe_1_nopar[8:15]);
      assign tlb_datain_hi_gs_tlbwe_1_par[2] = ^(tlb_datain_hi_gs_tlbwe_1_nopar[16:23]);
      assign tlb_datain_hi_gs_tlbwe_1_par[3] = ^(tlb_datain_hi_gs_tlbwe_1_nopar[24:31]);
      assign tlb_datain_hi_gs_tlbwe_1_par[4] = ^(tlb_datain_hi_gs_tlbwe_1_nopar[32:39]);
      assign tlb_datain_hi_gs_tlbwe_1_par[5] = ^(tlb_datain_hi_gs_tlbwe_1_nopar[40:44]);
      assign tlb_datain_hi_gs_tlbwe_1_par[6] = ^(tlb_datain_hi_gs_tlbwe_1_nopar[45:49]);
      assign tlb_datain_hi_gs_tlbwe_1_par[7] = ^(tlb_datain_hi_gs_tlbwe_1_nopar[50:57]);
      assign tlb_datain_hi_gs_tlbwe_1_par[8] = ^(tlb_datain_hi_gs_tlbwe_1_nopar[58:65]);
      assign tlb_datain_hi_gs_tlbwe_1_par[9] = ^(tlb_datain_hi_gs_tlbwe_1_nopar[66:73]);
`endif      
      assign tlb_datain_hi_hv_ptereload_par[0] = ^(tlb_datain_hi_hv_ptereload_nopar[0:7]);
      assign tlb_datain_hi_hv_ptereload_par[1] = ^(tlb_datain_hi_hv_ptereload_nopar[8:15]);
      assign tlb_datain_hi_hv_ptereload_par[2] = ^(tlb_datain_hi_hv_ptereload_nopar[16:23]);
      assign tlb_datain_hi_hv_ptereload_par[3] = ^(tlb_datain_hi_hv_ptereload_nopar[24:31]);
      assign tlb_datain_hi_hv_ptereload_par[4] = ^(tlb_datain_hi_hv_ptereload_nopar[32:39]);
      assign tlb_datain_hi_hv_ptereload_par[5] = ^(tlb_datain_hi_hv_ptereload_nopar[40:44]);
      assign tlb_datain_hi_hv_ptereload_par[6] = ^(tlb_datain_hi_hv_ptereload_nopar[45:49]);
      assign tlb_datain_hi_hv_ptereload_par[7] = ^(tlb_datain_hi_hv_ptereload_nopar[50:57]);
      assign tlb_datain_hi_hv_ptereload_par[8] = ^(tlb_datain_hi_hv_ptereload_nopar[58:65]);
      assign tlb_datain_hi_hv_ptereload_par[9] = ^(tlb_datain_hi_hv_ptereload_nopar[66:73]);
      assign tlb_datain_hi_gs_ptereload_par[0] = ^(tlb_datain_hi_gs_ptereload_nopar[0:7]);
      assign tlb_datain_hi_gs_ptereload_par[1] = ^(tlb_datain_hi_gs_ptereload_nopar[8:15]);
      assign tlb_datain_hi_gs_ptereload_par[2] = ^(tlb_datain_hi_gs_ptereload_nopar[16:23]);
      assign tlb_datain_hi_gs_ptereload_par[3] = ^(tlb_datain_hi_gs_ptereload_nopar[24:31]);
      assign tlb_datain_hi_gs_ptereload_par[4] = ^(tlb_datain_hi_gs_ptereload_nopar[32:39]);
      assign tlb_datain_hi_gs_ptereload_par[5] = ^(tlb_datain_hi_gs_ptereload_nopar[40:44]);
      assign tlb_datain_hi_gs_ptereload_par[6] = ^(tlb_datain_hi_gs_ptereload_nopar[45:49]);
      assign tlb_datain_hi_gs_ptereload_par[7] = ^(tlb_datain_hi_gs_ptereload_nopar[50:57]);
      assign tlb_datain_hi_gs_ptereload_par[8] = ^(tlb_datain_hi_gs_ptereload_nopar[58:65]);
      assign tlb_datain_hi_gs_ptereload_par[9] = ^(tlb_datain_hi_gs_ptereload_nopar[66:73]);
      assign tlb_dataina = tlb_dataina_q;
      assign tlb_datainb = tlb_datainb_q;
      assign tlb_cmp_dbg_tag5_tlb_datain_q = tlb_dataina_q;
      
      
      assign tlb_erat_rel_d[`eratpos_epn:`EPN_WIDTH - 1] = (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b100) ?  tlb_tag4_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] : 
                                                             (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b101) ? {tlb_tag4_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 5], 4'b0000} : 
                                                             (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b110) ? {tlb_tag4_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 9], 8'b00000000} : 
                                                             (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b111) ? {tlb_tag4_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 13], 12'b000000000000} : 
                                                             (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1] : 
                                                               tlb_erat_rel_q[`eratpos_epn:`EPN_WIDTH - 1];
                                                              
      assign tlb_erat_rel_d[`eratpos_size:`eratpos_size + 2] = (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b100) ? ERAT_PgSize_4KB : 
                                                                 (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b101) ? ERAT_PgSize_64KB : 
                                                                 (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b110) ? ERAT_PgSize_1MB : 
                                                                 (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b111) ? ERAT_PgSize_16MB : 
                                                                 (tlb_tag4_erat_data_cap == 1'b1) ? erat_pgsize[0:2] : 
                                                                  tlb_erat_rel_q[`eratpos_size:`eratpos_size + 2];

      assign tlb_erat_rel_d[`eratpos_x] = (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k] == 1'b1) ? 1'b0 : 
                                            (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_xbit] : 
                                             tlb_erat_rel_q[`eratpos_x];
      assign tlb_erat_rel_d[`eratpos_v] = (tlb_tag4_erat_data_cap == 1'b1) ? 1'b1 : 
                                         tlb_erat_rel_q[`eratpos_v];
                                         

      assign tlb_erat_rel_clone_d[`eratpos_epn:`EPN_WIDTH - 1] = (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b100) ?  tlb_tag4_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] : 
                                                                   (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b101) ? {tlb_tag4_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 5], 4'b0000} : 
                                                                   (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b110) ? {tlb_tag4_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 9], 8'b00000000} : 
                                                                   (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b111) ? {tlb_tag4_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 13], 12'b000000000000} : 
                                                                   (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1] : 
                                                                     tlb_erat_rel_clone_q[`eratpos_epn:`EPN_WIDTH - 1];
                                                                     
      assign tlb_erat_rel_clone_d[`eratpos_size:`eratpos_size + 2] = (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b100) ? ERAT_PgSize_4KB : 
                                                                       (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b101) ? ERAT_PgSize_64KB : 
                                                                       (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b110) ? ERAT_PgSize_1MB : 
                                                                       (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k:`waypos_tstmode4k+2] == 3'b111) ? ERAT_PgSize_16MB : 
                                                                       (tlb_tag4_erat_data_cap == 1'b1) ? erat_pgsize[0:2] : 
                                                                         tlb_erat_rel_clone_q[`eratpos_size:`eratpos_size + 2];
                                                                   
      assign tlb_erat_rel_clone_d[`eratpos_x] = (tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_way_or[`waypos_tstmode4k] == 1'b1) ? 1'b0 : 
                                                   (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_xbit] : 
                                                   tlb_erat_rel_clone_q[`eratpos_x];
      assign tlb_erat_rel_clone_d[`eratpos_v] = (tlb_tag4_erat_data_cap == 1'b1) ? 1'b1 : 
                                               tlb_erat_rel_clone_q[`eratpos_v];
                                               
      assign tlb_erat_rel_d[`eratpos_thdid:`eratpos_thdid + `THDID_WIDTH - 1] = (((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_q[pos_ittid] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0) | (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_q[pos_dttid] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? tlb_tag4_way_or[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1] : 
                                                                             (((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_q[pos_ittid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0) | (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_q[pos_dttid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? tlb_tag4_way_or[`waypos_tid + 2:`waypos_tid + 5] : 
                                                                             (((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_q[pos_ittid] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0) | (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_q[pos_dttid] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? ({tlb_tag4_q[`tagpos_atsel], tlb_tag4_q[`tagpos_esel:`tagpos_esel + 2]}) : 
                                                                             (((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_q[pos_ittid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0) | (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_q[pos_dttid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? tlb_tag4_q[`tagpos_pid + 2:`tagpos_pid + 5] : 
                                                                             tlb_erat_rel_q[`eratpos_thdid:`eratpos_thdid + `THDID_WIDTH - 1];
      assign tlb_erat_rel_clone_d[`eratpos_thdid:`eratpos_thdid + `THDID_WIDTH - 1] = (((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_clone_q[pos_ittid] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0) | (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_clone_q[pos_dttid] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? tlb_tag4_way_or[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1] : 
                                                                                   (((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_clone_q[pos_ittid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0) | (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_clone_q[pos_dttid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? tlb_tag4_way_or[`waypos_tid + 2:`waypos_tid + 5] : 
                                                                                   (((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_clone_q[pos_ittid] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0) | (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_clone_q[pos_dttid] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? ({tlb_tag4_q[`tagpos_atsel], tlb_tag4_q[`tagpos_esel:`tagpos_esel + 2]}) : 
                                                                                   (((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_clone_q[pos_ittid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0) | (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_clone_q[pos_dttid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? tlb_tag4_q[`tagpos_pid + 2:`tagpos_pid + 5] : 
                                                                                   tlb_erat_rel_clone_q[`eratpos_thdid:`eratpos_thdid + `THDID_WIDTH - 1];
      assign tlb_erat_rel_d[`eratpos_class:`eratpos_class + `CLASS_WIDTH - 1] = (tlb_tag4_erat_data_cap == 1'b1 & ((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_q[pos_ictid] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0) | 
                                                                                     (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_q[pos_dctid] == 1'b0 & mmucr1_q[pos_dccd] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? tlb_tag4_way_or[`waypos_class:`waypos_class + `CLASS_WIDTH - 1] : 
                                                                             (tlb_tag4_erat_data_cap == 1'b1 & ((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_q[pos_ictid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0) | 
                                                                              (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_q[pos_dctid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? tlb_tag4_way_or[`waypos_tid + 0:`waypos_tid + 1] : 
                                                                             ((tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_q[pos_dctid] == 1'b0 & mmucr1_q[pos_dccd] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0)) ? ({tlb_tag4_q[`tagpos_class], ((tlb_tag4_q[`tagpos_class] & tlb_tag4_q[`tagpos_class + 1]) | ((~(tlb_tag4_q[`tagpos_class])) & tlb_tag4_way_or[`waypos_class + 1]))}) : 
                                                                             (tlb_tag4_erat_data_cap == 1'b1 & ((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_q[pos_ictid] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0) | 
                                                                              (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_q[pos_dctid] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? ({tlb_tag4_q[`tagpos_class], (tlb_tag4_q[`tagpos_class] & tlb_tag4_q[`tagpos_class + 1])}) : 
                                                                             (tlb_tag4_erat_data_cap == 1'b1 & ((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_q[pos_ictid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0) | 
                                                                              (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_q[pos_dctid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? tlb_tag4_q[`tagpos_pid + 0:`tagpos_pid + 1] : 
                                                                             tlb_erat_rel_q[`eratpos_class:`eratpos_class + `CLASS_WIDTH - 1];
      assign tlb_erat_rel_clone_d[`eratpos_class:`eratpos_class + `CLASS_WIDTH - 1] = (tlb_tag4_erat_data_cap == 1'b1 & ((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_clone_q[pos_ictid] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0) | (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_clone_q[pos_dctid] == 1'b0 & mmucr1_clone_q[pos_dccd] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? tlb_tag4_way_or[`waypos_class:`waypos_class + `CLASS_WIDTH - 1] : 
                                                                                   (tlb_tag4_erat_data_cap == 1'b1 & ((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_clone_q[pos_ictid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0) | (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_clone_q[pos_dctid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? tlb_tag4_way_or[`waypos_tid + 0:`waypos_tid + 1] : 
                                                                                   ((tlb_tag4_erat_data_cap == 1'b1 & tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & mmucr1_clone_q[pos_dctid] == 1'b0 & mmucr1_clone_q[pos_dccd] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0)) ? ({tlb_tag4_q[`tagpos_class], ((tlb_tag4_q[`tagpos_class] & tlb_tag4_q[`tagpos_class + 1]) | ((~(tlb_tag4_q[`tagpos_class])) & tlb_tag4_way_or[`waypos_class + 1]))}) : 
                                                                                   (tlb_tag4_erat_data_cap == 1'b1 & ((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_clone_q[pos_ictid] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0) | (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_clone_q[pos_dctid] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? ({tlb_tag4_q[`tagpos_class], (tlb_tag4_q[`tagpos_class] & tlb_tag4_q[`tagpos_class + 1])}) : 
                                                                                   (tlb_tag4_erat_data_cap == 1'b1 & ((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_clone_q[pos_ictid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0) | (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & mmucr1_clone_q[pos_dctid] == 1'b1 & tlb_tag4_q[`tagpos_ind] == 1'b0))) ? tlb_tag4_q[`tagpos_pid + 0:`tagpos_pid + 1] : 
                                                                                   tlb_erat_rel_clone_q[`eratpos_class:`eratpos_class + `CLASS_WIDTH - 1];
      assign tlb_erat_rel_d[`eratpos_extclass:`eratpos_extclass + 1] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_extclass:`waypos_extclass + 1] : 
                                                                     tlb_erat_rel_q[`eratpos_extclass:`eratpos_extclass + 1];
      assign tlb_erat_rel_d[`eratpos_wren] = ((tlb_tag4_erat_data_cap == 1'b1 & (tlb_tag4_q[`tagpos_type_ierat] == 1'b1 | tlb_tag4_q[`tagpos_type_derat] == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & 
                                                  tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 & tlb_tag4_q[`tagpos_wq + 1] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0 & 
                                                   multihit == 1'b0 & |(tag4_parerr_q[0:4]) == 1'b0)) ? 1'b1 : 
                                            (tlb_tag4_erat_data_cap == 1'b1) ? 1'b0 : 
                                            tlb_erat_rel_q[`eratpos_wren];
      assign tlb_erat_rel_d[`eratpos_rpnrsvd:`eratpos_rpnrsvd + 3] = {4{1'b0}};
      assign tlb_erat_rel_d[`eratpos_rpn:`eratpos_rpn + `RPN_WIDTH - 1] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_rpn:`waypos_rpn + `RPN_WIDTH - 1] : 
                                                                       tlb_erat_rel_q[`eratpos_rpn:`eratpos_rpn + `RPN_WIDTH - 1];
      assign tlb_erat_rel_d[`eratpos_r:`eratpos_c] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_rc:`waypos_rc + 1] : 
                                                   tlb_erat_rel_q[`eratpos_r:`eratpos_c];
      assign tlb_erat_rel_d[`eratpos_relsoon] = ierat_req_taken | ptereload_req_taken | tlb_tag0_type[1];
      assign tlb_erat_rel_d[`eratpos_wlc:`eratpos_wlc + 1] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_wlc:`waypos_wlc + 1] : 
                                                           tlb_erat_rel_q[`eratpos_wlc:`eratpos_wlc + 1];
      assign tlb_erat_rel_d[`eratpos_resvattr] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_resvattr] : 
                                                tlb_erat_rel_q[`eratpos_resvattr];
      assign tlb_erat_rel_d[`eratpos_vf] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_vf] : 
                                          tlb_erat_rel_q[`eratpos_vf];
      assign tlb_erat_rel_d[`eratpos_ubits:`eratpos_ubits + 3] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_ubits:`waypos_ubits + 3] : 
                                                               tlb_erat_rel_q[`eratpos_ubits:`eratpos_ubits + 3];
      assign tlb_erat_rel_d[`eratpos_wimge:`eratpos_wimge + 4] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_wimge:`waypos_wimge + 4] : 
                                                               tlb_erat_rel_q[`eratpos_wimge:`eratpos_wimge + 4];
      assign tlb_erat_rel_d[`eratpos_usxwr:`eratpos_usxwr + 5] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_usxwr:`waypos_usxwr + 5] : 
                                                               tlb_erat_rel_q[`eratpos_usxwr:`eratpos_usxwr + 5];
      assign tlb_erat_rel_d[`eratpos_gs] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_gs] : 
                                          tlb_erat_rel_q[`eratpos_gs];
      assign tlb_erat_rel_d[`eratpos_ts] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_ts] : 
                                          tlb_erat_rel_q[`eratpos_ts];
      assign tlb_erat_rel_d[`eratpos_tid:`eratpos_tid + `PID_WIDTH_ERAT - 1] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_tid + 6:`waypos_tid + 14 - 1] : 
                                                                            tlb_erat_rel_q[`eratpos_tid:`eratpos_tid + `PID_WIDTH_ERAT - 1];
      assign tlb_erat_rel_clone_d[`eratpos_extclass:`eratpos_extclass + 1] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_extclass:`waypos_extclass + 1] : 
                                                                           tlb_erat_rel_clone_q[`eratpos_extclass:`eratpos_extclass + 1];
      assign tlb_erat_rel_clone_d[`eratpos_wren] = ((tlb_tag4_erat_data_cap == 1'b1 & (tlb_tag4_q[`tagpos_type_ierat] == 1'b1 | tlb_tag4_q[`tagpos_type_derat] == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 & tlb_tag4_q[`tagpos_wq + 1] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0 & multihit == 1'b0)) ? 1'b1 : 
                                                  (tlb_tag4_erat_data_cap == 1'b1) ? 1'b0 : 
                                                  tlb_erat_rel_clone_q[`eratpos_wren];
      assign tlb_erat_rel_clone_d[`eratpos_rpnrsvd:`eratpos_rpnrsvd + 3] = {4{1'b0}};
      assign tlb_erat_rel_clone_d[`eratpos_rpn:`eratpos_rpn + `RPN_WIDTH - 1] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_rpn:`waypos_rpn + `RPN_WIDTH - 1] : 
                                                                             tlb_erat_rel_clone_q[`eratpos_rpn:`eratpos_rpn + `RPN_WIDTH - 1];
      assign tlb_erat_rel_clone_d[`eratpos_r:`eratpos_c] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_rc:`waypos_rc + 1] : 
                                                         tlb_erat_rel_clone_q[`eratpos_r:`eratpos_c];
      assign tlb_erat_rel_clone_d[`eratpos_relsoon] = derat_req_taken | ptereload_req_taken | tlb_tag0_type[0];
      assign tlb_erat_rel_clone_d[`eratpos_wlc:`eratpos_wlc + 1] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_wlc:`waypos_wlc + 1] : 
                                                                 tlb_erat_rel_clone_q[`eratpos_wlc:`eratpos_wlc + 1];
      assign tlb_erat_rel_clone_d[`eratpos_resvattr] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_resvattr] : 
                                                      tlb_erat_rel_clone_q[`eratpos_resvattr];
      assign tlb_erat_rel_clone_d[`eratpos_vf] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_vf] : 
                                                tlb_erat_rel_clone_q[`eratpos_vf];
      assign tlb_erat_rel_clone_d[`eratpos_ubits:`eratpos_ubits + 3] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_ubits:`waypos_ubits + 3] : 
                                                                     tlb_erat_rel_clone_q[`eratpos_ubits:`eratpos_ubits + 3];
      assign tlb_erat_rel_clone_d[`eratpos_wimge:`eratpos_wimge + 4] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_wimge:`waypos_wimge + 4] : 
                                                                     tlb_erat_rel_clone_q[`eratpos_wimge:`eratpos_wimge + 4];
      assign tlb_erat_rel_clone_d[`eratpos_usxwr:`eratpos_usxwr + 5] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_usxwr:`waypos_usxwr + 5] : 
                                                                     tlb_erat_rel_clone_q[`eratpos_usxwr:`eratpos_usxwr + 5];
      assign tlb_erat_rel_clone_d[`eratpos_gs] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_gs] : 
                                                tlb_erat_rel_clone_q[`eratpos_gs];
      assign tlb_erat_rel_clone_d[`eratpos_ts] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_ts] : 
                                                tlb_erat_rel_clone_q[`eratpos_ts];
      assign tlb_erat_rel_clone_d[`eratpos_tid:`eratpos_tid + `PID_WIDTH_ERAT - 1] = (tlb_tag4_erat_data_cap == 1'b1) ? tlb_tag4_way_or[`waypos_tid + 6:`waypos_tid + 14 - 1] : 
                                                                                  tlb_erat_rel_clone_q[`eratpos_tid:`eratpos_tid + `PID_WIDTH_ERAT - 1];
      assign tlb_tag4_erat_data_cap = (((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 | tlb_tag4_q[`tagpos_type_derat] == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0 & 
                                          (tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 | |(tag4_parerr_q[0:4]) == 1'b1) & |((tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS-1] & (~tlb_ctl_tag4_flush))) == 1'b1)) ? 1'b1 : 
                                      (((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 | tlb_tag4_q[`tagpos_type_derat] == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & 
                                            tlb_tag4_q[`tagpos_ind] == 1'b0 & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1)) ? 1'b1 : 
                                      1'b0;
      assign erat_pgsize[0:2] = (tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1GB) ? ERAT_PgSize_1GB : 
                                (tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_16MB) ? ERAT_PgSize_16MB : 
                                (tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1MB) ? ERAT_PgSize_1MB : 
                                (tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_64KB) ? ERAT_PgSize_64KB : 
                                ERAT_PgSize_4KB;
      assign tlb_erat_val_d[0:3] = ((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0 & tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 & |(tag4_parerr_q[0:4]) == 1'b0 & multihit == 1'b0 & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS-1] & (~tlb_ctl_tag4_flush)) == 1'b1)) ? (tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1] | ierat_tag4_dup_thdid[0:`THDID_WIDTH - 1]) : 
                                   ((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & ((tlb_tag4_q[`tagpos_endflag] == 1'b1 & tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b0) | |(tag4_parerr_q[0:4]) == 1'b1 | multihit == 1'b1) & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS-1] & (~tlb_ctl_tag4_flush)) == 1'b1)) ? tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1] : 
                                   ((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1)) ? tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1] : 
                                   {4{1'b0}};
      assign tlb_erat_val_d[4] = ((tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0 & tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 & multihit == 1'b0 & |(tag4_parerr_q[0:4]) == 1'b0 & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS-1] & (~tlb_ctl_tag4_flush)) == 1'b1)) ? tlb_tag4_q[`tagpos_type_ierat] : 
                                 ((tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1)) ? tlb_tag4_q[`tagpos_type_ierat] : 
                                 1'b0;
      assign tlb_erat_val_d[5:8] = ((tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0 & tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 & |(tag4_parerr_q[0:4]) == 1'b0 & multihit == 1'b0 & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS-1] & (~tlb_ctl_tag4_flush)) == 1'b1)) ? (tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1] | derat_tag4_dup_thdid[0:`THDID_WIDTH - 1]) : 
                                   ((tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & ((tlb_tag4_q[`tagpos_endflag] == 1'b1 & tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b0) | |(tag4_parerr_q[0:4]) == 1'b1 | multihit == 1'b1) & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS-1] & (~tlb_ctl_tag4_flush)) == 1'b1)) ? tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1] : 
                                   ((tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1)) ? tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1] : 
                                   {4{1'b0}};
      assign tlb_erat_val_d[9] = ((tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0 & tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 & multihit == 1'b0 & |(tag4_parerr_q[0:4]) == 1'b0 & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS-1] & (~tlb_ctl_tag4_flush)) == 1'b1)) ? tlb_tag4_q[`tagpos_type_derat] : 
                                 ((tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1)) ? tlb_tag4_q[`tagpos_type_derat] : 
                                 1'b0;
      assign ierat_req0_tag4_thdid_match = (|(tlb_tag4_way_or[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1] & ierat_req0_thdid) == 1'b1) ? 1'b1 : 
                                           1'b0;
      assign ierat_req0_tag4_pid_match = ((tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1] == ierat_req0_pid | |(tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                         1'b0;
      assign ierat_req0_tag4_as_match = ((tlb_tag4_way_or[`waypos_ts] == ierat_req0_as)) ? 1'b1 : 
                                        1'b0;
      assign ierat_req0_tag4_gs_match = ((tlb_tag4_way_or[`waypos_gs] == ierat_req0_gs)) ? 1'b1 : 
                                        1'b0;
      assign ierat_req0_tag4_epn_match = ((tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1] == ierat_req0_epn[52 - `EPN_WIDTH:51] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_4KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 5] == ierat_req0_epn[52 - `EPN_WIDTH:47] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_64KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 9] == ierat_req0_epn[52 - `EPN_WIDTH:43] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 13] == ierat_req0_epn[52 - `EPN_WIDTH:39] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_16MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 19] == ierat_req0_epn[52 - `EPN_WIDTH:33] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 : 
                                         1'b0;
      assign tlb_erat_dup_d[0] = ((ierat_req0_tag4_pid_match == 1'b1 & ierat_req0_tag4_as_match == 1'b1 & ierat_req0_tag4_gs_match == 1'b1 & ierat_req0_tag4_epn_match == 1'b1 & ierat_req0_tag4_thdid_match == 1'b1 & ierat_req0_valid == 1'b1 & (tlb_erat_dup_d[4] == 1'b0 & tlb_erat_dup_d[5] == 1'b1))) ? 1'b1 : 
                                 1'b0;
      assign ierat_req1_tag4_thdid_match = (|(tlb_tag4_way_or[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1] & ierat_req1_thdid) == 1'b1) ? 1'b1 : 
                                           1'b0;
      assign ierat_req1_tag4_pid_match = ((tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1] == ierat_req1_pid | |(tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                         1'b0;
      assign ierat_req1_tag4_as_match = ((tlb_tag4_way_or[`waypos_ts] == ierat_req1_as)) ? 1'b1 : 
                                        1'b0;
      assign ierat_req1_tag4_gs_match = ((tlb_tag4_way_or[`waypos_gs] == ierat_req1_gs)) ? 1'b1 : 
                                        1'b0;
      assign ierat_req1_tag4_epn_match = ((tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1] == ierat_req1_epn[52 - `EPN_WIDTH:51] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_4KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 5] == ierat_req1_epn[52 - `EPN_WIDTH:47] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_64KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 9] == ierat_req1_epn[52 - `EPN_WIDTH:43] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 13] == ierat_req1_epn[52 - `EPN_WIDTH:39] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_16MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 19] == ierat_req1_epn[52 - `EPN_WIDTH:33] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 : 
                                         1'b0;
      assign tlb_erat_dup_d[1] = ((ierat_req1_tag4_pid_match == 1'b1 & ierat_req1_tag4_as_match == 1'b1 & ierat_req1_tag4_gs_match == 1'b1 & ierat_req1_tag4_epn_match == 1'b1 & ierat_req1_tag4_thdid_match == 1'b1 & ierat_req1_valid == 1'b1 & (tlb_erat_dup_d[4] == 1'b0 & tlb_erat_dup_d[5] == 1'b1))) ? 1'b1 : 
                                 1'b0;
      assign ierat_req2_tag4_thdid_match = (|(tlb_tag4_way_or[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1] & ierat_req2_thdid) == 1'b1) ? 1'b1 : 
                                           1'b0;
      assign ierat_req2_tag4_pid_match = ((tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1] == ierat_req2_pid | |(tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                         1'b0;
      assign ierat_req2_tag4_as_match = ((tlb_tag4_way_or[`waypos_ts] == ierat_req2_as)) ? 1'b1 : 
                                        1'b0;
      assign ierat_req2_tag4_gs_match = ((tlb_tag4_way_or[`waypos_gs] == ierat_req2_gs)) ? 1'b1 : 
                                        1'b0;
      assign ierat_req2_tag4_epn_match = ((tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1] == ierat_req2_epn[52 - `EPN_WIDTH:51] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_4KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 5] == ierat_req2_epn[52 - `EPN_WIDTH:47] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_64KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 9] == ierat_req2_epn[52 - `EPN_WIDTH:43] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 13] == ierat_req2_epn[52 - `EPN_WIDTH:39] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_16MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 19] == ierat_req2_epn[52 - `EPN_WIDTH:33] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 : 
                                         1'b0;
      assign tlb_erat_dup_d[2] = ((ierat_req2_tag4_pid_match == 1'b1 & ierat_req2_tag4_as_match == 1'b1 & ierat_req2_tag4_gs_match == 1'b1 & ierat_req2_tag4_epn_match == 1'b1 & ierat_req2_tag4_thdid_match == 1'b1 & ierat_req2_valid == 1'b1 & (tlb_erat_dup_d[4] == 1'b0 & tlb_erat_dup_d[5] == 1'b1))) ? 1'b1 : 
                                 1'b0;
      assign ierat_req3_tag4_thdid_match = (|(tlb_tag4_way_or[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1] & ierat_req3_thdid) == 1'b1) ? 1'b1 : 
                                           1'b0;
      assign ierat_req3_tag4_pid_match = ((tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1] == ierat_req3_pid | |(tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                         1'b0;
      assign ierat_req3_tag4_as_match = ((tlb_tag4_way_or[`waypos_ts] == ierat_req3_as)) ? 1'b1 : 
                                        1'b0;
      assign ierat_req3_tag4_gs_match = ((tlb_tag4_way_or[`waypos_gs] == ierat_req3_gs)) ? 1'b1 : 
                                        1'b0;
      assign ierat_req3_tag4_epn_match = ((tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1] == ierat_req3_epn[52 - `EPN_WIDTH:51] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_4KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 5] == ierat_req3_epn[52 - `EPN_WIDTH:47] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_64KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 9] == ierat_req3_epn[52 - `EPN_WIDTH:43] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 13] == ierat_req3_epn[52 - `EPN_WIDTH:39] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_16MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 19] == ierat_req3_epn[52 - `EPN_WIDTH:33] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 : 
                                         1'b0;
      assign tlb_erat_dup_d[3] = ((ierat_req3_tag4_pid_match == 1'b1 & ierat_req3_tag4_as_match == 1'b1 & ierat_req3_tag4_gs_match == 1'b1 & ierat_req3_tag4_epn_match == 1'b1 & ierat_req3_tag4_thdid_match == 1'b1 & ierat_req3_valid == 1'b1 & (tlb_erat_dup_d[4] == 1'b0 & tlb_erat_dup_d[5] == 1'b1))) ? 1'b1 : 
                                 1'b0;
      assign ierat_iu4_tag4_thdid_match = (|(tlb_tag4_way_or[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1] & ierat_iu4_thdid) == 1'b1) ? 1'b1 : 
                                          1'b0;
      assign ierat_iu4_tag4_lpid_match = ((tlb_tag4_way_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1] == lpidr | |(tlb_tag4_way_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                         1'b0;
      assign ierat_iu4_tag4_pid_match = ((tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1] == ierat_iu4_pid | |(tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                        1'b0;
      assign ierat_iu4_tag4_as_match = ((tlb_tag4_way_or[`waypos_ts] == ierat_iu4_as)) ? 1'b1 : 
                                       1'b0;
      assign ierat_iu4_tag4_gs_match = ((tlb_tag4_way_or[`waypos_gs] == ierat_iu4_gs)) ? 1'b1 : 
                                       1'b0;
      assign ierat_iu4_tag4_epn_match = ((tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1] == ierat_iu4_epn[52 - `EPN_WIDTH:51] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_4KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 5] == ierat_iu4_epn[52 - `EPN_WIDTH:47] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_64KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 9] == ierat_iu4_epn[52 - `EPN_WIDTH:43] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 13] == ierat_iu4_epn[52 - `EPN_WIDTH:39] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_16MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 19] == ierat_iu4_epn[52 - `EPN_WIDTH:33] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 : 
                                        1'b0;
      assign derat_req0_tag4_thdid_match = (|(tlb_tag4_way_or[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1] & derat_req0_thdid) == 1'b1) ? 1'b1 : 
                                           1'b0;
      assign derat_req0_tag4_lpid_match = ((tlb_tag4_way_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1] == derat_req0_lpid | |(tlb_tag4_way_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                          1'b0;
      assign derat_req0_tag4_pid_match = ((tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1] == derat_req0_pid | |(tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                         1'b0;
      assign derat_req0_tag4_as_match = ((tlb_tag4_way_or[`waypos_ts] == derat_req0_as)) ? 1'b1 : 
                                        1'b0;
      assign derat_req0_tag4_gs_match = ((tlb_tag4_way_or[`waypos_gs] == derat_req0_gs)) ? 1'b1 : 
                                        1'b0;
      assign derat_req0_tag4_epn_match = ((tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1] == derat_req0_epn[52 - `EPN_WIDTH:51] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_4KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 5] == derat_req0_epn[52 - `EPN_WIDTH:47] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_64KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 9] == derat_req0_epn[52 - `EPN_WIDTH:43] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 13] == derat_req0_epn[52 - `EPN_WIDTH:39] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_16MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 19] == derat_req0_epn[52 - `EPN_WIDTH:33] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 : 
                                         1'b0;
      assign tlb_erat_dup_d[10] = ((derat_req0_tag4_lpid_match == 1'b1 & derat_req0_tag4_pid_match == 1'b1 & derat_req0_tag4_as_match == 1'b1 & derat_req0_tag4_gs_match == 1'b1 & derat_req0_tag4_epn_match == 1'b1 & derat_req0_tag4_thdid_match == 1'b1 & derat_req0_valid == 1'b1)) ? 1'b1 : 
                                  1'b0;
      assign derat_req1_tag4_thdid_match = (|(tlb_tag4_way_or[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1] & derat_req1_thdid) == 1'b1) ? 1'b1 : 
                                           1'b0;
      assign derat_req1_tag4_lpid_match = ((tlb_tag4_way_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1] == derat_req1_lpid | |(tlb_tag4_way_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                          1'b0;
      assign derat_req1_tag4_pid_match = ((tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1] == derat_req1_pid | |(tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                         1'b0;
      assign derat_req1_tag4_as_match = ((tlb_tag4_way_or[`waypos_ts] == derat_req1_as)) ? 1'b1 : 
                                        1'b0;
      assign derat_req1_tag4_gs_match = ((tlb_tag4_way_or[`waypos_gs] == derat_req1_gs)) ? 1'b1 : 
                                        1'b0;
      assign derat_req1_tag4_epn_match = ((tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1] == derat_req1_epn[52 - `EPN_WIDTH:51] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_4KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 5] == derat_req1_epn[52 - `EPN_WIDTH:47] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_64KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 9] == derat_req1_epn[52 - `EPN_WIDTH:43] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 13] == derat_req1_epn[52 - `EPN_WIDTH:39] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_16MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 19] == derat_req1_epn[52 - `EPN_WIDTH:33] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 : 
                                         1'b0;
      assign tlb_erat_dup_d[11] = ((derat_req1_tag4_lpid_match == 1'b1 & derat_req1_tag4_pid_match == 1'b1 & derat_req1_tag4_as_match == 1'b1 & derat_req1_tag4_gs_match == 1'b1 & derat_req1_tag4_epn_match == 1'b1 & derat_req1_tag4_thdid_match == 1'b1 & derat_req1_valid == 1'b1)) ? 1'b1 : 
                                  1'b0;
      assign derat_req2_tag4_thdid_match = (|(tlb_tag4_way_or[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1] & derat_req2_thdid) == 1'b1) ? 1'b1 : 
                                           1'b0;
      assign derat_req2_tag4_lpid_match = ((tlb_tag4_way_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1] == derat_req2_lpid | |(tlb_tag4_way_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                          1'b0;
      assign derat_req2_tag4_pid_match = ((tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1] == derat_req2_pid | |(tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                         1'b0;
      assign derat_req2_tag4_as_match = ((tlb_tag4_way_or[`waypos_ts] == derat_req2_as)) ? 1'b1 : 
                                        1'b0;
      assign derat_req2_tag4_gs_match = ((tlb_tag4_way_or[`waypos_gs] == derat_req2_gs)) ? 1'b1 : 
                                        1'b0;
      assign derat_req2_tag4_epn_match = ((tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1] == derat_req2_epn[52 - `EPN_WIDTH:51] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_4KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 5] == derat_req2_epn[52 - `EPN_WIDTH:47] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_64KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 9] == derat_req2_epn[52 - `EPN_WIDTH:43] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 13] == derat_req2_epn[52 - `EPN_WIDTH:39] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_16MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 19] == derat_req2_epn[52 - `EPN_WIDTH:33] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 : 
                                         1'b0;
      assign tlb_erat_dup_d[12] = ((derat_req2_tag4_lpid_match == 1'b1 & derat_req2_tag4_pid_match == 1'b1 & derat_req2_tag4_as_match == 1'b1 & derat_req2_tag4_gs_match == 1'b1 & derat_req2_tag4_epn_match == 1'b1 & derat_req2_tag4_thdid_match == 1'b1 & derat_req2_valid == 1'b1)) ? 1'b1 : 
                                  1'b0;
      assign derat_req3_tag4_thdid_match = (|(tlb_tag4_way_or[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1] & derat_req3_thdid) == 1'b1) ? 1'b1 : 
                                           1'b0;
      assign derat_req3_tag4_lpid_match = ((tlb_tag4_way_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1] == derat_req3_lpid | |(tlb_tag4_way_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                          1'b0;
      assign derat_req3_tag4_pid_match = ((tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1] == derat_req3_pid | |(tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                         1'b0;
      assign derat_req3_tag4_as_match = ((tlb_tag4_way_or[`waypos_ts] == derat_req3_as)) ? 1'b1 : 
                                        1'b0;
      assign derat_req3_tag4_gs_match = ((tlb_tag4_way_or[`waypos_gs] == derat_req3_gs)) ? 1'b1 : 
                                        1'b0;
      assign derat_req3_tag4_epn_match = ((tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1] == derat_req3_epn[52 - `EPN_WIDTH:51] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_4KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 5] == derat_req3_epn[52 - `EPN_WIDTH:47] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_64KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 9] == derat_req3_epn[52 - `EPN_WIDTH:43] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 13] == derat_req3_epn[52 - `EPN_WIDTH:39] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_16MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 19] == derat_req3_epn[52 - `EPN_WIDTH:33] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 : 
                                         1'b0;
      assign tlb_erat_dup_d[13] = ((derat_req3_tag4_lpid_match == 1'b1 & derat_req3_tag4_pid_match == 1'b1 & derat_req3_tag4_as_match == 1'b1 & derat_req3_tag4_gs_match == 1'b1 & derat_req3_tag4_epn_match == 1'b1 & derat_req3_tag4_thdid_match == 1'b1 & derat_req3_valid == 1'b1)) ? 1'b1 : 
                                  1'b0;
      assign derat_ex5_tag4_thdid_match = (|(tlb_tag4_way_or[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1] & derat_ex5_thdid) == 1'b1) ? 1'b1 : 
                                          1'b0;
      assign derat_ex5_tag4_lpid_match = ((tlb_tag4_way_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1] == derat_ex5_lpid | |(tlb_tag4_way_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                         1'b0;
      assign derat_ex5_tag4_pid_match = ((tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1] == derat_ex5_pid | |(tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1]) == 1'b0)) ? 1'b1 : 
                                        1'b0;
      assign derat_ex5_tag4_as_match = ((tlb_tag4_way_or[`waypos_ts] == derat_ex5_as)) ? 1'b1 : 
                                       1'b0;
      assign derat_ex5_tag4_gs_match = ((tlb_tag4_way_or[`waypos_gs] == derat_ex5_gs)) ? 1'b1 : 
                                       1'b0;
      assign derat_ex5_tag4_epn_match = ((tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1] == derat_ex5_epn[52 - `EPN_WIDTH:51] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_4KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 5] == derat_ex5_epn[52 - `EPN_WIDTH:47] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_64KB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 9] == derat_ex5_epn[52 - `EPN_WIDTH:43] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 13] == derat_ex5_epn[52 - `EPN_WIDTH:39] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_16MB) | (tlb_tag4_way_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 19] == derat_ex5_epn[52 - `EPN_WIDTH:33] & tlb_tag4_way_or[`waypos_size:`waypos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 : 
                                        1'b0;
      assign tlb_erat_dup_d[4] = ((tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & tlb_tag4_way_or[`waypos_ind] == 1'b0 & tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 & multihit == 1'b0 & tlb_tag4_q[`tagpos_wq + 1] == 1'b0 & |(tag4_parerr_q[0:4]) == 1'b0)) ? tlb_tag4_q[`tagpos_type_ierat] : 
                                 1'b0;
      assign tlb_erat_dup_d[5] = ((tlb_erat_dup_d[4] == 1'b1 | tlb_erat_dup_q[4] == 1'b1)) ? 1'b1 : 
                                 ((tlb_erat_dup_q[20] == 1'b1 | tlb_erat_dup_q[7:9] != 3'b000)) ? 1'b1 : 
                                 1'b0;
      assign tlb_erat_dup_d[6] = ((ierat_iu4_tag4_lpid_match == 1'b1 & ierat_iu4_tag4_pid_match == 1'b1 & ierat_iu4_tag4_as_match == 1'b1 & ierat_iu4_tag4_gs_match == 1'b1 & ierat_iu4_tag4_epn_match == 1'b1 & ierat_iu4_tag4_thdid_match == 1'b1 & ierat_iu4_valid == 1'b1 & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1)) ? tlb_tag4_q[`tagpos_type_ierat] : 
                                 1'b0;
      assign tlb_erat_dup_d[7:9] = ((((tlb_erat_dup_q[4] == 1'b1 & tlb_erat_dup_q[20] == 1'b0) | tlb_erat_dup_q[20] == 1'b1) & tlb_erat_dup_q[7:9] == 3'b000)) ? 3'b001 : 
                                   (tlb_erat_dup_q[7:9] == 3'b001) ? 3'b010 : 
                                   (tlb_erat_dup_q[7:9] == 3'b010) ? 3'b011 : 
                                   (tlb_erat_dup_q[7:9] == 3'b011) ? 3'b100 : 
                                   (tlb_erat_dup_q[7:9] == 3'b100) ? 3'b101 : 
                                   (tlb_erat_dup_q[7:9] == 3'b101) ? 3'b110 : 
                                   (tlb_erat_dup_q[7:9] == 3'b110) ? 3'b111 : 
                                   (tlb_erat_dup_q[7:9] == 3'b111) ? 3'b000 : 
                                   tlb_erat_dup_q[7:9];
      assign tlb_erat_dup_d[20] = ((tlb_erat_dup_q[20] == 1'b0 & tlb_erat_dup_q[7:9] == 3'b111)) ? 1'b1 : 
                                  ((tlb_erat_dup_q[20] == 1'b1 & tlb_erat_dup_q[7:9] == 3'b111)) ? 1'b0 : 
                                  tlb_erat_dup_q[20];
      assign tlb_erat_dup_d[14] = ((tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & tlb_tag4_way_or[`waypos_ind] == 1'b0 & tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 & multihit == 1'b0 & tlb_tag4_q[`tagpos_wq + 1] == 1'b0 & |(tag4_parerr_q[0:4]) == 1'b0)) ? tlb_tag4_q[`tagpos_type_derat] : 
                                  1'b0;
      assign tlb_erat_dup_d[15] = ((tlb_erat_dup_d[14] == 1'b1 | tlb_erat_dup_q[14] == 1'b1)) ? 1'b1 : 
                                  ((tlb_erat_dup_q[21] == 1'b1 | tlb_erat_dup_q[17:19] != 3'b000)) ? 1'b1 : 
                                  1'b0;
      assign tlb_erat_dup_d[16] = ((derat_ex5_tag4_lpid_match == 1'b1 & derat_ex5_tag4_pid_match == 1'b1 & derat_ex5_tag4_as_match == 1'b1 & derat_ex5_tag4_gs_match == 1'b1 & derat_ex5_tag4_epn_match == 1'b1 & derat_ex5_tag4_thdid_match == 1'b1 & derat_ex5_valid == 1'b1 & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1)) ? tlb_tag4_q[`tagpos_type_derat] : 
                                  1'b0;
      assign tlb_erat_dup_d[17:19] = ((((tlb_erat_dup_q[14] == 1'b1 & tlb_erat_dup_q[21] == 1'b0) | tlb_erat_dup_q[21] == 1'b1) & tlb_erat_dup_q[17:19] == 3'b000)) ? 3'b001 : 
                                     (tlb_erat_dup_q[17:19] == 3'b001) ? 3'b010 : 
                                     (tlb_erat_dup_q[17:19] == 3'b010) ? 3'b011 : 
                                     (tlb_erat_dup_q[17:19] == 3'b011) ? 3'b100 : 
                                     (tlb_erat_dup_q[17:19] == 3'b100) ? 3'b101 : 
                                     (tlb_erat_dup_q[17:19] == 3'b101) ? 3'b110 : 
                                     (tlb_erat_dup_q[17:19] == 3'b110) ? 3'b111 : 
                                     (tlb_erat_dup_q[17:19] == 3'b111) ? 3'b000 : 
                                     tlb_erat_dup_q[17:19];
      assign tlb_erat_dup_d[21] = ((tlb_erat_dup_q[21] == 1'b0 & tlb_erat_dup_q[17:19] == 3'b111)) ? 1'b1 : 
                                  ((tlb_erat_dup_q[21] == 1'b1 & tlb_erat_dup_q[17:19] == 3'b111)) ? 1'b0 : 
                                  tlb_erat_dup_q[21];
      assign ierat_tag4_dup_thdid = ( {`THDID_WIDTH{tlb_erat_dup_d[0]}} & ierat_req0_thdid[0:`THDID_WIDTH - 1] & {`THDID_WIDTH{(~tlb_tag4_q[`tagpos_wq + 1])}} ) | 
                                      ( {`THDID_WIDTH{tlb_erat_dup_d[1]}} & ierat_req1_thdid[0:`THDID_WIDTH - 1] & {`THDID_WIDTH{(~tlb_tag4_q[`tagpos_wq + 1])}} ) | 
                                      ( {`THDID_WIDTH{tlb_erat_dup_d[2]}} & ierat_req2_thdid[0:`THDID_WIDTH - 1] & {`THDID_WIDTH{(~tlb_tag4_q[`tagpos_wq + 1])}} ) | 
                                      ( {`THDID_WIDTH{tlb_erat_dup_d[3]}} & ierat_req3_thdid[0:`THDID_WIDTH - 1] & {`THDID_WIDTH{(~tlb_tag4_q[`tagpos_wq + 1])}} );

      assign derat_tag4_dup_thdid = ( {`THDID_WIDTH{tlb_erat_dup_d[10]}} & derat_req0_thdid[0:`THDID_WIDTH - 1] & {`THDID_WIDTH{(~tlb_tag4_q[`tagpos_wq + 1])}} ) | 
                                      ( {`THDID_WIDTH{tlb_erat_dup_d[11]}} & derat_req1_thdid[0:`THDID_WIDTH - 1] & {`THDID_WIDTH{(~tlb_tag4_q[`tagpos_wq + 1])}} ) | 
                                      ( {`THDID_WIDTH{tlb_erat_dup_d[12]}} & derat_req2_thdid[0:`THDID_WIDTH - 1] & {`THDID_WIDTH{(~tlb_tag4_q[`tagpos_wq + 1])}} ) | 
                                      ( {`THDID_WIDTH{tlb_erat_dup_d[13]}} & derat_req3_thdid[0:`THDID_WIDTH - 1] & {`THDID_WIDTH{(~tlb_tag4_q[`tagpos_wq + 1])}} );

      assign derat_tag4_dup_emq = ( {`THDID_WIDTH{tlb_erat_dup_d[10]}} & derat_req0_emq[0:`THDID_WIDTH - 1] & {`THDID_WIDTH{(~tlb_tag4_q[`tagpos_wq + 1])}} ) | 
                                    ( {`THDID_WIDTH{tlb_erat_dup_d[11]}} & derat_req1_emq[0:`THDID_WIDTH - 1] & {`THDID_WIDTH{(~tlb_tag4_q[`tagpos_wq + 1])}} ) | 
                                    ( {`THDID_WIDTH{tlb_erat_dup_d[12]}} & derat_req2_emq[0:`THDID_WIDTH - 1] & {`THDID_WIDTH{(~tlb_tag4_q[`tagpos_wq + 1])}} ) | 
                                    ( {`THDID_WIDTH{tlb_erat_dup_d[13]}} & derat_req3_emq[0:`THDID_WIDTH - 1] & {`THDID_WIDTH{(~tlb_tag4_q[`tagpos_wq + 1])}} );

      assign tlb_tag4_epcr_dgtmi = |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS-1] & xu_mm_epcr_dgtmi);

      assign tlb_tag4_size_not_supp = ( tlb_tag4_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB | tlb_tag4_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB | 
                                          tlb_tag4_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB | tlb_tag4_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB | 
                                          tlb_tag4_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB | 
                                         (tlb_tag4_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB & tlb_tag4_q[`tagpos_ind] == 1'b1) ) ? 1'b0 : 
                                      1'b1;
                                      
      assign eratmiss_done_d = tlb_erat_val_q[0:`MM_THREADS-1] | tlb_erat_val_q[5:5 + `MM_THREADS-1];
      
      
      assign tlb_miss_d = ( ((tlb_tag4_q[`tagpos_type_ierat] == 1'b1 | tlb_tag4_q[`tagpos_type_derat] == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & tlb_tag4_q[`tagpos_endflag] == 1'b1 & 
                                 |(tlb_tag4_wayhit_q[0:`TLB_WAYS - 1]) == 1'b0 & tlb_tag4_q[`tagpos_nonspec] == 1'b1 & |(tag4_parerr_q[0:4]) == 1'b0) ) ? tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] : 
                          {`MM_THREADS{1'b0}};
                          
                          
      assign tlb_inelig_d = ((tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & tlb_tag4_q[`tagpos_is] == 1'b1 & lru_tag4_dataout_q[0:3] == 4'b1111 & lru_tag4_dataout_q[8:11] == 4'b1111) | 
                               (tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & tlb_tag4_q[`tagpos_is] == 1'b1 & tlb_tag4_size_not_supp == 1'b1) | 
                               (tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & tlb_tag4_q[`tagpos_is] == 1'b1 & tlb_tag4_q[`tagpos_pt] == 1'b0)) ? tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] : 
                            {`MM_THREADS{1'b0}};
                            
      assign lrat_miss_d = ((((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & tlb_resv_match_vec) == 1'b1 & tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b01 & mmucfg_twc == 1'b1) | tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b00 | tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b11) & 
                                   tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1 & tlb_tag4_q[`tagpos_pr] == 1'b0 & tlb_tag4_epcr_dgtmi == 1'b0 & 
                                     mmucfg_lrat == 1'b1 & tlb_tag4_q[`tagpos_is] == 1'b1 & lrat_tag4_hit_status[0:3] != 4'b1100)) ? (tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS-1] & (~(tlb_ctl_tag4_flush))) : 
                           ((tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1 & mmucfg_lrat == 1'b1 & tlb_tag4_q[`tagpos_is] == 1'b1 & 
                                 lrat_tag4_hit_status[0:3] != 4'b1100 & tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b10 & tlb_tag4_q[`tagpos_pt] == 1'b1)) ? tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS-1] : 
                           {`MM_THREADS{1'b0}};
                           
      assign pt_fault_d = ((tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & tlb_tag4_q[`tagpos_is] == 1'b0 & 
                              tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b10 & tlb_tag4_q[`tagpos_pt] == 1'b1)) ? tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] : 
                          {`MM_THREADS{1'b0}};
                          
      
      assign hv_priv_d = ( (tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1 & tlb_tag4_q[`tagpos_pr] == 1'b0 & tlb0cfg_gtwe == 1'b0) | 
                             (tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1 & tlb_tag4_q[`tagpos_pr] == 1'b0 & mmucfg_lrat == 1'b0) | 
                            
                            ( tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1 & tlb_tag4_q[`tagpos_pr] == 1'b0 & tlb_tag4_q[`tagpos_hes] == 1'b1 & 
                             (tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b00 | tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b11 | 
                               (tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b01 & (|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid +  `MM_THREADS - 1] & tlb_resv_match_vec) == 1'b1))) & 
                               ((lru_tag4_dataout_q[0] == 1'b1 & lru_tag4_dataout_q[4:5] == 2'b00 & lru_tag4_dataout_q[8] == 1'b1) | 
                               (lru_tag4_dataout_q[1] == 1'b1 & lru_tag4_dataout_q[4:5] == 2'b01 & lru_tag4_dataout_q[9] == 1'b1) | 
                               (lru_tag4_dataout_q[2] == 1'b1 & lru_tag4_dataout_q[4] == 1'b1 & lru_tag4_dataout_q[6] == 1'b0 & lru_tag4_dataout_q[10] == 1'b1) | 
                               (lru_tag4_dataout_q[3] == 1'b1 & lru_tag4_dataout_q[4] == 1'b1 & lru_tag4_dataout_q[6] == 1'b1 & lru_tag4_dataout_q[11] == 1'b1)) ) | 
                               
                            ( tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1 & tlb_tag4_q[`tagpos_pr] == 1'b0 & tlb_tag4_q[`tagpos_hes] == 1'b1 & 
                               (tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b00 | tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b11 | 
                                 (tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b01 & (|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid +  `MM_THREADS - 1] & tlb_resv_match_vec) == 1'b1))) & 
                                 tlb_tag4_q[`tagpos_is + 1] == 1'b1 ) | 
                                 
                            (tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1 & tlb_tag4_q[`tagpos_pr] == 1'b0 & 
                              tlb_tag4_q[`tagpos_hes] == 1'b0 & tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] != 2'b10) ) ? (tlb_tag4_q[`tagpos_thdid:`tagpos_thdid +  `MM_THREADS - 1] & (~(tlb_ctl_tag4_flush))) : 
                         {`MM_THREADS{1'b0}};
                         

      assign esr_pt_d = (pt_fault_d | lrat_miss_d) & {`MM_THREADS{tlb_tag4_q[`tagpos_type_ptereload]}};
      assign esr_data_d = (tlb_miss_d | pt_fault_d | tlb_inelig_d | lrat_miss_d) & {`MM_THREADS{tlb_tag4_q[`tagpos_type_derat]}};
      assign esr_st_d = (tlb_miss_d | pt_fault_d | tlb_inelig_d | lrat_miss_d) & {`MM_THREADS{tlb_tag4_q[`tagpos_type_derat]}} & {`MM_THREADS{tlb_tag4_q[`tagpos_class + 1]}};
      assign esr_epid_d = (tlb_miss_d | pt_fault_d | tlb_inelig_d | lrat_miss_d) & {`MM_THREADS{tlb_tag4_q[`tagpos_type_derat]}} & {`MM_THREADS{tlb_tag4_q[`tagpos_class]}};

      assign cr0_eq_d = ( ((tlb_tag4_q[`tagpos_type_tlbsrx] == 1'b1 | (tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1 & tlb_tag4_q[`tagpos_recform] == 1'b1)) & tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 & 
                                multihit == 1'b0 & |(tag4_parerr_q[0:`TLB_WAYS]) == 1'b0) ) ? tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] : 
                        {`MM_THREADS{1'b0}};
                        
      assign cr0_eq_valid_d = (((tlb_tag4_q[`tagpos_type_tlbsrx] == 1'b1 | (tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1 & tlb_tag4_q[`tagpos_recform] == 1'b1)) & 
                                   (tlb_tag4_q[`tagpos_endflag] == 1'b1 | (tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 & multihit == 1'b0)) & 
                                      |(tag4_parerr_q[0:`TLB_WAYS]) == 1'b0)) ? tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] : 
                              {`MM_THREADS{1'b0}};
                              
      assign tlb_multihit_err_d = ((((tlb_tag4_q[`tagpos_type_derat:`tagpos_type_ierat] != 2'b00 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & tlb_tag4_q[`tagpos_nonspec] == 1'b1) | 
                                       (tlb_tag4_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx] != 2'b00)) & multihit == 1'b1 & 
                                        (tlb_tag4_q[`tagpos_endflag] == 1'b1 | tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1))) ? tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] : 
                                  {`MM_THREADS{1'b0}};
                                  
      assign mm_xu_ord_par_mhit_err_d[0] = |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1]) & (tlb_tag4_q[`tagpos_endflag] | tlb_tag4_wayhit_q[`TLB_WAYS]) & 
                                                 |(tlb_tag4_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) & multihit;
                                  
      generate
         if (`CHECK_PARITY == 0)
         begin : parerr_gen0
            assign tlb_par_err_d = tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & {`MM_THREADS{tag4_parerr_q[0] & (~(tag4_parerr_q[0])) & |(tlb_tag4_q[`tagpos_type_derat:`tagpos_type_tlbre])}};
            assign lru_par_err_d = tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & {`MM_THREADS{tag4_parerr_q[2] & (~(tag4_parerr_q[2])) & |(tlb_tag4_q[`tagpos_type_derat:`tagpos_type_tlbre])}};
            assign tlb_tag4_tlbre_parerr = 1'b0;
            assign ECO107332_tlb_par_err_d = tlb_par_err_d;
            assign ECO107332_lru_par_err_d = lru_par_err_d;
            assign mm_xu_ord_par_mhit_err_d[1] = 1'b0;
            assign mm_xu_ord_par_mhit_err_d[2] = 1'b0;
         end
      endgenerate


      generate
         if (`CHECK_PARITY == 1)
         begin : parerr_gen1
            assign tlb_par_err_d = tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & 
                         {`MM_THREADS{ (|(tag4_parerr_q[0:`TLB_WAYS - 1]) & tlb_tag4_q[`tagpos_nonspec] & |(tlb_tag4_q[`tagpos_type_derat:`tagpos_type_tlbsrx])) | 
                                        (tag4_parerr_q[0] & tlb_tag4_q[`tagpos_type_tlbre] & (~tlb_tag4_q[`tagpos_esel + 1]) & (~tlb_tag4_q[`tagpos_esel + 2])) | 
                                        (tag4_parerr_q[1] & tlb_tag4_q[`tagpos_type_tlbre] & (~tlb_tag4_q[`tagpos_esel + 1]) & tlb_tag4_q[`tagpos_esel + 2]) | 
                                        (tag4_parerr_q[2] & tlb_tag4_q[`tagpos_type_tlbre] & tlb_tag4_q[`tagpos_esel + 1] & (~tlb_tag4_q[`tagpos_esel + 2])) | 
                                        (tag4_parerr_q[3] & tlb_tag4_q[`tagpos_type_tlbre] & tlb_tag4_q[`tagpos_esel + 1] & tlb_tag4_q[`tagpos_esel + 2]) }};
                                        
            assign lru_par_err_d = tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & 
                                       {`MM_THREADS{ tag4_parerr_q[4] & tlb_tag4_q[`tagpos_nonspec] & (|(tlb_tag4_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) | tlb_tag4_q[`tagpos_type_tlbre]) }};
                                       
            assign ECO107332_tlb_par_err_d = tlb_par_err_d & (~(tlb_ctl_tag4_flush));
            assign ECO107332_lru_par_err_d = lru_par_err_d & (~(tlb_ctl_tag4_flush));
            
            assign tlb_tag4_tlbre_parerr = (tag4_parerr_q[0] & tlb_tag4_q[`tagpos_type_tlbre] & (~tlb_tag4_q[`tagpos_esel + 1]) & (~tlb_tag4_q[`tagpos_esel + 2])) | 
                                             (tag4_parerr_q[1] & tlb_tag4_q[`tagpos_type_tlbre] & (~tlb_tag4_q[`tagpos_esel + 1]) & tlb_tag4_q[`tagpos_esel + 2]) | 
                                             (tag4_parerr_q[2] & tlb_tag4_q[`tagpos_type_tlbre] & tlb_tag4_q[`tagpos_esel + 1] & (~tlb_tag4_q[`tagpos_esel + 2])) | 
                                             (tag4_parerr_q[3] & tlb_tag4_q[`tagpos_type_tlbre] & tlb_tag4_q[`tagpos_esel + 1] & tlb_tag4_q[`tagpos_esel + 2]) | 
                                             (tag4_parerr_q[4] & tlb_tag4_q[`tagpos_type_tlbre]);
                                             
            assign mm_xu_ord_par_mhit_err_d[1] = |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1]) & 
                                    ( (|(tag4_parerr_q[0:`TLB_WAYS - 1]) & |(tlb_tag4_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx])) | 
                                        (tag4_parerr_q[0] & tlb_tag4_q[`tagpos_type_tlbre] & (~tlb_tag4_q[`tagpos_esel + 1]) & (~tlb_tag4_q[`tagpos_esel + 2])) | 
                                        (tag4_parerr_q[1] & tlb_tag4_q[`tagpos_type_tlbre] & (~tlb_tag4_q[`tagpos_esel + 1]) & tlb_tag4_q[`tagpos_esel + 2]) | 
                                        (tag4_parerr_q[2] & tlb_tag4_q[`tagpos_type_tlbre] & tlb_tag4_q[`tagpos_esel + 1] & (~tlb_tag4_q[`tagpos_esel + 2])) | 
                                        (tag4_parerr_q[3] & tlb_tag4_q[`tagpos_type_tlbre] & tlb_tag4_q[`tagpos_esel + 1] & tlb_tag4_q[`tagpos_esel + 2]) );
                                        
            assign mm_xu_ord_par_mhit_err_d[2] = |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1]) & ( tag4_parerr_q[4] & 
                                         (|(tlb_tag4_q[`tagpos_type_tlbsx:`tagpos_type_tlbsrx]) | tlb_tag4_q[`tagpos_type_tlbre]) );
                                       
         end
      endgenerate
      
      assign  mm_xu_ord_tlb_multihit = mm_xu_ord_par_mhit_err_q[0];
      assign  mm_xu_ord_tlb_par_err = mm_xu_ord_par_mhit_err_q[1];
      assign  mm_xu_ord_lru_par_err = mm_xu_ord_par_mhit_err_q[2];

      assign tlb_tag5_except_d = (hv_priv_d | lrat_miss_d | tlb_inelig_d | pt_fault_d | tlb_multihit_err_d | tlb_par_err_d | lru_par_err_d);
      assign tlb_tag5_itag_d = tlb_tag4_q[`tagpos_itag:`tagpos_itag + `ITAG_SIZE_ENC - 1];

      assign tlb_tag5_emq_d = ( tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b0 & 
                                    tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 & |(tag4_parerr_q[0:`TLB_WAYS]) == 1'b0 & multihit == 1'b0 & 
                                      |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~tlb_ctl_tag4_flush)) == 1'b1 ) ? (tlb_tag4_q[`tagpos_emq:`tagpos_emq + `EMQ_ENTRIES - 1] | derat_tag4_dup_emq) : 
                                ( tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & ((tlb_tag4_q[`tagpos_endflag] == 1'b1 & 
                                    tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b0) | |(tag4_parerr_q[0:4]) == 1'b1 | multihit == 1'b1) & 
                                      |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid +  `MM_THREADS - 1] & (~tlb_ctl_tag4_flush)) == 1'b1 ) ? tlb_tag4_q[`tagpos_emq:`tagpos_emq + `EMQ_ENTRIES - 1] : 
                                 ( tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 ) ? tlb_tag4_q[`tagpos_emq:`tagpos_emq + `EMQ_ENTRIES - 1] : 
                              {`EMQ_ENTRIES{1'b0}};

      assign tlb_isi_d = ( tlb_tag4_q[`tagpos_type_ierat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & tlb_tag4_q[`tagpos_nonspec] == 1'b1 & 
                             (|(tlb_tag4_wayhit_q[0:`TLB_WAYS - 1])) == 1'b0 & tlb_tag4_q[`tagpos_endflag] == 1'b1 ) ? tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] : 
                         {`MM_THREADS{1'b0}};
      assign tlb_dsi_d = ( (tlb_tag4_q[`tagpos_type_derat] == 1'b1 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & tlb_tag4_q[`tagpos_nonspec] == 1'b1 & 
                              (|(tlb_tag4_wayhit_q[0:`TLB_WAYS - 1])) == 1'b0 & tlb_tag4_q[`tagpos_endflag] == 1'b1)) ? tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] : 
                         {`MM_THREADS{1'b0}};
                         
                         
      
      mmq_tlb_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1)) matchline_comb0(
         .vdd(vdd),
         .gnd(gnd),
         .addr_in(tlb_tag3_clone1_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1]),
         .addr_enable(addr_enable),
         .comp_pgsize(tlb_tag3_clone1_q[`tagpos_size:`tagpos_size + 3]),
         .pgsize_enable(pgsize_enable),
         .entry_size(tlb_way0_q[`waypos_size:`waypos_size + 3]),
         .entry_cmpmask(tlb_way0_cmpmask_q),
         .entry_xbit(tlb_way0_q[`waypos_xbit]),
         .entry_xbitmask(tlb_way0_xbitmask_q),
         .entry_epn(tlb_way0_q[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1]),
         .comp_class(tlb_tag3_clone1_q[`tagpos_class:`tagpos_class + 1]),
         .entry_class(tlb_way0_q[`waypos_class:`waypos_class + 1]),
         .class_enable(class_enable),
         .comp_extclass(comp_extclass),
         .entry_extclass(tlb_way0_q[`waypos_extclass:`waypos_extclass + 1]),
         .extclass_enable(extclass_enable),
         .comp_state(tlb_tag3_clone1_q[`tagpos_state + 1:`tagpos_state + 2]),
         .entry_gs(tlb_way0_q[`waypos_gs]),
         .entry_ts(tlb_way0_q[`waypos_ts]),
         .state_enable(state_enable),
         .entry_thdid(tlb_way0_q[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1]),
         .comp_thdid(tlb_tag3_clone1_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]),
         .thdid_enable(thdid_enable),
         .entry_pid(tlb_way0_q[`waypos_tid:`waypos_tid + `PID_WIDTH - 1]),
         .comp_pid(tlb_tag3_clone1_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]),
         .pid_enable(pid_enable),
         .entry_lpid(tlb_way0_q[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1]),
         .comp_lpid(tlb_tag3_clone1_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1]),
         .lpid_enable(lpid_enable),
         .entry_ind(tlb_way0_q[`waypos_ind]),
         .comp_ind(comp_ind),
         .ind_enable(ind_enable),
         .entry_iprot(lru_tag3_dataout_q[8]),
         .comp_iprot(comp_iprot),
         .iprot_enable(iprot_enable),
         .entry_v(lru_tag3_dataout_q[0]),
         .comp_invalidate(tlb_tag3_clone1_q[`tagpos_type_snoop]),
         
         .match(tlb_wayhit[0]),
         .dbg_addr_match(tlb_way0_addr_match),
         .dbg_pgsize_match(tlb_way0_pgsize_match),
         .dbg_class_match(tlb_way0_class_match),
         .dbg_extclass_match(tlb_way0_extclass_match),
         .dbg_state_match(tlb_way0_state_match),
         .dbg_thdid_match(tlb_way0_thdid_match),
         .dbg_pid_match(tlb_way0_pid_match),
         .dbg_lpid_match(tlb_way0_lpid_match),
         .dbg_ind_match(tlb_way0_ind_match),
         .dbg_iprot_match(tlb_way0_iprot_match)
      );
      
      mmq_tlb_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1)) matchline_comb1(
         .vdd(vdd),
         .gnd(gnd),
         .addr_in(tlb_tag3_clone1_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1]),
         .addr_enable(addr_enable),
         .comp_pgsize(tlb_tag3_clone1_q[`tagpos_size:`tagpos_size + 3]),
         .pgsize_enable(pgsize_enable),
         .entry_size(tlb_way1_q[`waypos_size:`waypos_size + 3]),
         .entry_cmpmask(tlb_way1_cmpmask_q),
         .entry_xbit(tlb_way1_q[`waypos_xbit]),
         .entry_xbitmask(tlb_way1_xbitmask_q),
         .entry_epn(tlb_way1_q[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1]),
         .comp_class(tlb_tag3_clone1_q[`tagpos_class:`tagpos_class + 1]),
         .entry_class(tlb_way1_q[`waypos_class:`waypos_class + 1]),
         .class_enable(class_enable),
         .comp_extclass(comp_extclass),
         .entry_extclass(tlb_way1_q[`waypos_extclass:`waypos_extclass + 1]),
         .extclass_enable(extclass_enable),
         .comp_state(tlb_tag3_clone1_q[`tagpos_state + 1:`tagpos_state + 2]),
         .entry_gs(tlb_way1_q[`waypos_gs]),
         .entry_ts(tlb_way1_q[`waypos_ts]),
         .state_enable(state_enable),
         .entry_thdid(tlb_way1_q[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1]),
         .comp_thdid(tlb_tag3_clone1_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]),
         .thdid_enable(thdid_enable),
         .entry_pid(tlb_way1_q[`waypos_tid:`waypos_tid + `PID_WIDTH - 1]),
         .comp_pid(tlb_tag3_clone1_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]),
         .pid_enable(pid_enable),
         .entry_lpid(tlb_way1_q[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1]),
         .comp_lpid(tlb_tag3_clone1_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1]),
         .lpid_enable(lpid_enable),
         .entry_ind(tlb_way1_q[`waypos_ind]),
         .comp_ind(comp_ind),
         .ind_enable(ind_enable),
         .entry_iprot(lru_tag3_dataout_q[9]),
         .comp_iprot(comp_iprot),
         .iprot_enable(iprot_enable),
         .entry_v(lru_tag3_dataout_q[1]),
         .comp_invalidate(tlb_tag3_clone1_q[`tagpos_type_snoop]),
         
         .match(tlb_wayhit[1]),
         .dbg_addr_match(tlb_way1_addr_match),
         .dbg_pgsize_match(tlb_way1_pgsize_match),
         .dbg_class_match(tlb_way1_class_match),
         .dbg_extclass_match(tlb_way1_extclass_match),
         .dbg_state_match(tlb_way1_state_match),
         .dbg_thdid_match(tlb_way1_thdid_match),
         .dbg_pid_match(tlb_way1_pid_match),
         .dbg_lpid_match(tlb_way1_lpid_match),
         .dbg_ind_match(tlb_way1_ind_match),
         .dbg_iprot_match(tlb_way1_iprot_match)
      );
      
      mmq_tlb_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1)) matchline_comb2(
         .vdd(vdd),
         .gnd(gnd),
         .addr_in(tlb_tag3_clone2_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1]),
         .addr_enable(addr_enable_clone),
         .comp_pgsize(tlb_tag3_clone2_q[`tagpos_size:`tagpos_size + 3]),
         .pgsize_enable(pgsize_enable_clone),
         .entry_size(tlb_way2_q[`waypos_size:`waypos_size + 3]),
         .entry_cmpmask(tlb_way2_cmpmask_q),
         .entry_xbit(tlb_way2_q[`waypos_xbit]),
         .entry_xbitmask(tlb_way2_xbitmask_q),
         .entry_epn(tlb_way2_q[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1]),
         .comp_class(tlb_tag3_clone2_q[`tagpos_class:`tagpos_class + 1]),
         .entry_class(tlb_way2_q[`waypos_class:`waypos_class + 1]),
         .class_enable(class_enable_clone),
         .comp_extclass(comp_extclass_clone),
         .entry_extclass(tlb_way2_q[`waypos_extclass:`waypos_extclass + 1]),
         .extclass_enable(extclass_enable_clone),
         .comp_state(tlb_tag3_clone2_q[`tagpos_state + 1:`tagpos_state + 2]),
         .entry_gs(tlb_way2_q[`waypos_gs]),
         .entry_ts(tlb_way2_q[`waypos_ts]),
         .state_enable(state_enable_clone),
         .entry_thdid(tlb_way2_q[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1]),
         .comp_thdid(tlb_tag3_clone2_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]),
         .thdid_enable(thdid_enable_clone),
         .entry_pid(tlb_way2_q[`waypos_tid:`waypos_tid + `PID_WIDTH - 1]),
         .comp_pid(tlb_tag3_clone2_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]),
         .pid_enable(pid_enable_clone),
         .entry_lpid(tlb_way2_q[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1]),
         .comp_lpid(tlb_tag3_clone2_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1]),
         .lpid_enable(lpid_enable_clone),
         .entry_ind(tlb_way2_q[`waypos_ind]),
         .comp_ind(comp_ind_clone),
         .ind_enable(ind_enable_clone),
         .entry_iprot(lru_tag3_dataout_q[10]),
         .comp_iprot(comp_iprot_clone),
         .iprot_enable(iprot_enable_clone),
         .entry_v(lru_tag3_dataout_q[2]),
         .comp_invalidate(tlb_tag3_clone2_q[`tagpos_type_snoop]),
         
         .match(tlb_wayhit[2]),
         
         .dbg_addr_match(tlb_way2_addr_match),
         .dbg_pgsize_match(tlb_way2_pgsize_match),
         .dbg_class_match(tlb_way2_class_match),
         .dbg_extclass_match(tlb_way2_extclass_match),
         .dbg_state_match(tlb_way2_state_match),
         .dbg_thdid_match(tlb_way2_thdid_match),
         .dbg_pid_match(tlb_way2_pid_match),
         .dbg_lpid_match(tlb_way2_lpid_match),
         .dbg_ind_match(tlb_way2_ind_match),
         .dbg_iprot_match(tlb_way2_iprot_match)
      );
      
      mmq_tlb_matchline #(.HAVE_XBIT(1), .NUM_PGSIZES(5), .HAVE_CMPMASK(1)) matchline_comb3(
         .vdd(vdd),
         .gnd(gnd),
         .addr_in(tlb_tag3_clone2_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1]),
         .addr_enable(addr_enable_clone),
         .comp_pgsize(tlb_tag3_clone2_q[`tagpos_size:`tagpos_size + 3]),
         .pgsize_enable(pgsize_enable_clone),
         .entry_size(tlb_way3_q[`waypos_size:`waypos_size + 3]),
         .entry_cmpmask(tlb_way3_cmpmask_q),
         .entry_xbit(tlb_way3_q[`waypos_xbit]),
         .entry_xbitmask(tlb_way3_xbitmask_q),
         .entry_epn(tlb_way3_q[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1]),
         .comp_class(tlb_tag3_clone2_q[`tagpos_class:`tagpos_class + 1]),
         .entry_class(tlb_way3_q[`waypos_class:`waypos_class + 1]),
         .class_enable(class_enable_clone),
         .comp_extclass(comp_extclass_clone),
         .entry_extclass(tlb_way3_q[`waypos_extclass:`waypos_extclass + 1]),
         .extclass_enable(extclass_enable_clone),
         .comp_state(tlb_tag3_clone2_q[`tagpos_state + 1:`tagpos_state + 2]),
         .entry_gs(tlb_way3_q[`waypos_gs]),
         .entry_ts(tlb_way3_q[`waypos_ts]),
         .state_enable(state_enable_clone),
         .entry_thdid(tlb_way3_q[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1]),
         .comp_thdid(tlb_tag3_clone2_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]),
         .thdid_enable(thdid_enable_clone),
         .entry_pid(tlb_way3_q[`waypos_tid:`waypos_tid + `PID_WIDTH - 1]),
         .comp_pid(tlb_tag3_clone2_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]),
         .pid_enable(pid_enable_clone),
         .entry_lpid(tlb_way3_q[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1]),
         .comp_lpid(tlb_tag3_clone2_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1]),
         .lpid_enable(lpid_enable_clone),
         .entry_ind(tlb_way3_q[`waypos_ind]),
         .comp_ind(comp_ind_clone),
         .ind_enable(ind_enable_clone),
         .entry_iprot(lru_tag3_dataout_q[11]),
         .comp_iprot(comp_iprot_clone),
         .iprot_enable(iprot_enable_clone),
         .entry_v(lru_tag3_dataout_q[3]),
         .comp_invalidate(tlb_tag3_clone2_q[`tagpos_type_snoop]),
         
         .match(tlb_wayhit[3]),
         
         .dbg_addr_match(tlb_way3_addr_match),
         .dbg_pgsize_match(tlb_way3_pgsize_match),
         .dbg_class_match(tlb_way3_class_match),
         .dbg_extclass_match(tlb_way3_extclass_match),
         .dbg_state_match(tlb_way3_state_match),
         .dbg_thdid_match(tlb_way3_thdid_match),
         .dbg_pid_match(tlb_way3_pid_match),
         .dbg_lpid_match(tlb_way3_lpid_match),
         .dbg_ind_match(tlb_way3_ind_match),
         .dbg_iprot_match(tlb_way3_iprot_match)
      );
      
      
      assign tlb_cmp_ierat_dup_val[0:6] = tlb_erat_dup_q[0:6];
      assign tlb_cmp_derat_dup_val[0:6] = tlb_erat_dup_q[10:16];
      assign tlb_cmp_erat_dup_wait = {tlb_erat_dup_q[5], tlb_erat_dup_q[15]};
      assign mm_iu_ierat_rel_val = tlb_erat_val_q[0:4];
      assign mm_iu_ierat_rel_data = tlb_erat_rel_q;
      assign mm_xu_derat_rel_val = tlb_erat_val_q[5:9];
      assign mm_xu_derat_rel_data = tlb_erat_rel_clone_q;
      assign mm_xu_eratmiss_done = eratmiss_done_q;
      assign mm_xu_tlb_miss = tlb_miss_q;
      assign mm_xu_tlb_inelig = tlb_inelig_q;
      assign mm_xu_lrat_miss = lrat_miss_q;
      assign mm_xu_pt_fault = pt_fault_q;
      assign mm_xu_hv_priv = hv_priv_q;
      assign mm_xu_esr_pt = esr_pt_q;
      assign mm_xu_esr_data = esr_data_q;
      assign mm_xu_esr_epid = esr_epid_q;
      assign mm_xu_esr_st = esr_st_q;
      assign mm_xu_cr0_eq = cr0_eq_q;
      assign mm_xu_cr0_eq_valid = cr0_eq_valid_q;
      assign mm_xu_tlb_multihit_err = tlb_multihit_err_q;
      assign mm_xu_tlb_par_err = tlb_par_err_q;
      assign mm_xu_lru_par_err = lru_par_err_q;
      assign mm_xu_tlb_miss_ored = |(tlb_miss_q);
      assign mm_xu_lrat_miss_ored = |(lrat_miss_q);
      assign mm_xu_tlb_inelig_ored = |(tlb_inelig_q);
      assign mm_xu_pt_fault_ored = |(pt_fault_q);
      assign mm_xu_hv_priv_ored = |(hv_priv_q);
      assign mm_xu_cr0_eq_ored = |(cr0_eq_q);
      assign mm_xu_cr0_eq_valid_ored = |(cr0_eq_valid_q);
      assign tlb_multihit_err_ored = |(tlb_multihit_err_q);
      assign tlb_par_err_ored = |(tlb_par_err_q);
      assign lru_par_err_ored = |(lru_par_err_q);
      assign tlb_addr4 = tlb_addr4_q;
      assign tlb_tag5_except = tlb_tag5_except_q;
      assign tlb_tag4_itag = tlb_tag4_q[`tagpos_itag:`tagpos_itag + `ITAG_SIZE_ENC - 1];
      assign tlb_tag5_itag = tlb_tag5_itag_q;
      assign tlb_tag5_emq = tlb_tag5_emq_q;
      assign tlb_tag4_esel = tlb_tag4_q[`tagpos_esel:`tagpos_esel + 2];
      assign tlb_tag4_wq = tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1];
      assign tlb_tag4_is = tlb_tag4_q[`tagpos_is:`tagpos_is + 1];
      assign tlb_tag4_hes = tlb_tag4_q[`tagpos_hes];
      assign tlb_tag4_gs = tlb_tag4_q[`tagpos_gs];
      assign tlb_tag4_pr = tlb_tag4_q[`tagpos_pr];
      assign tlb_tag4_atsel = tlb_tag4_q[`tagpos_atsel];
      assign tlb_tag4_pt = tlb_tag4_q[`tagpos_pt];
      assign tlb_tag4_endflag = tlb_tag4_q[`tagpos_endflag] & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]);
      assign tlb_tag4_nonspec = tlb_tag4_q[`tagpos_nonspec];
      assign lru_tag4_dataout = lru_tag4_dataout_q[0:15];
      assign tlb_tag4_cmp_hit = tlb_tag4_wayhit_q[`TLB_WAYS];
      assign tlb_tag4_way_ind = tlb_tag4_way_or[`waypos_ind];
      assign tlb_tag4_ptereload_sig = tlb_tag4_q[`tagpos_type_ptereload] & |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]);
      assign tlb_tag4_ptereload = tlb_tag4_ptereload_sig;
      assign tlb_tag4_parerr = |(tag4_parerr_q[0:4]) & tlb_tag4_parerr_enab;
      assign tlb_mas0_esel[0] = 1'b0;
      assign tlb_mas0_esel[1:2] = (tlb_tag4_wayhit_q[0:`TLB_WAYS] == 5'b01001) ? 2'b01 : 
                                  (tlb_tag4_wayhit_q[0:`TLB_WAYS] == 5'b00101) ? 2'b10 : 
                                  (tlb_tag4_wayhit_q[0:`TLB_WAYS] == 5'b00011) ? 2'b11 : 
                                  2'b00;
      assign tlb_mas1_v = ((tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 & tlb_tag4_q[`tagpos_esel + 1:`tagpos_esel + 2] == 2'b00)) ? lru_tag4_dataout_q[0] : 
                          ((tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 & tlb_tag4_q[`tagpos_esel + 1:`tagpos_esel + 2] == 2'b01)) ? lru_tag4_dataout_q[1] : 
                          ((tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 & tlb_tag4_q[`tagpos_esel + 1:`tagpos_esel + 2] == 2'b10)) ? lru_tag4_dataout_q[2] : 
                          ((tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 & tlb_tag4_q[`tagpos_esel + 1:`tagpos_esel + 2] == 2'b11)) ? lru_tag4_dataout_q[3] : 
                          (tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1) ? tlb_tag4_wayhit_q[`TLB_WAYS] : 
                          1'b0;
      assign tlb_mas1_iprot = ((tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1 & tlb_tag4_wayhit_q[0:`TLB_WAYS] == 5'b10001) | (tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 & tlb_tag4_q[`tagpos_esel + 1:`tagpos_esel + 2] == 2'b00)) ? lru_tag4_dataout_q[8] : 
                              ((tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1 & tlb_tag4_wayhit_q[0:`TLB_WAYS] == 5'b01001) | (tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 & tlb_tag4_q[`tagpos_esel + 1:`tagpos_esel + 2] == 2'b01)) ? lru_tag4_dataout_q[9] : 
                              ((tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1 & tlb_tag4_wayhit_q[0:`TLB_WAYS] == 5'b00101) | (tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 & tlb_tag4_q[`tagpos_esel + 1:`tagpos_esel + 2] == 2'b10)) ? lru_tag4_dataout_q[10] : 
                              ((tlb_tag4_q[`tagpos_type_tlbsx] == 1'b1 & tlb_tag4_wayhit_q[0:`TLB_WAYS] == 5'b00011) | (tlb_tag4_q[`tagpos_type_tlbre] == 1'b1 & tlb_tag4_q[`tagpos_esel + 1:`tagpos_esel + 2] == 2'b11)) ? lru_tag4_dataout_q[11] : 
                              1'b0;


      assign tlb_mas1_tid = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1] : 
                            tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1];
                            
      assign tlb_mas1_tid_error = tlb_tag4_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1];
      
      assign tlb_mas1_ind = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_ind] : 
                            tlb_tag4_way_or[`waypos_ind];
                            
      assign tlb_mas1_ts = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_ts] : 
                           tlb_tag4_way_or[`waypos_ts];
                           
      assign tlb_mas1_ts_error = tlb_tag4_q[`tagpos_state + 2];
      
      assign tlb_mas1_tsize = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_size:`waypos_size + 3] : 
                              tlb_tag4_way_or[`waypos_size:`waypos_size + 3];


      assign tlb_mas2_epn[0:31] = ( |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & 
                                        (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1 ) ? (tlb_tag4_way_rw_or[`waypos_epn:`waypos_epn + 31] & {32{tlb_tag4_q[`tagpos_cm]}}) : 
                                  tlb_tag4_way_or[`waypos_epn:`waypos_epn + 31];
                                  
      assign tlb_mas2_epn[32:`EPN_WIDTH - 1] = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_epn + 32:`waypos_epn + `EPN_WIDTH - 1] : 
                                              tlb_tag4_way_or[`waypos_epn + 32:`waypos_epn + `EPN_WIDTH - 1];
                                              
      assign tlb_mas2_epn_error = tlb_tag4_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1];
      
      assign tlb_mas2_wimge = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_wimge:`waypos_wimge + 4] : 
                              tlb_tag4_way_or[`waypos_wimge:`waypos_wimge + 4];


      assign tlb_mas3_rpnl = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_rpn + 10:`waypos_rpn + `RPN_WIDTH - 1] : 
                             tlb_tag4_way_or[`waypos_rpn + 10:`waypos_rpn + `RPN_WIDTH - 1];
                             
      assign tlb_mas3_ubits = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_ubits:`waypos_ubits + 3] : 
                              tlb_tag4_way_or[`waypos_ubits:`waypos_ubits + 3];
                              
      assign tlb_mas3_usxwr = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_usxwr:`waypos_usxwr + 5] : 
                              tlb_tag4_way_or[`waypos_usxwr:`waypos_usxwr + 5];
                              
      
      assign tlb_mas7_rpnu = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_rpn:`waypos_rpn + 9] : 
                             tlb_tag4_way_or[`waypos_rpn:`waypos_rpn + 9];

      assign tlb_mas8_tgs = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_gs] : 
                            tlb_tag4_way_or[`waypos_gs];
      assign tlb_mas8_vf = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_vf] : 
                           tlb_tag4_way_or[`waypos_vf];
      assign tlb_mas8_tlpid = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1] : 
                              tlb_tag4_way_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1];

      assign tlb_mmucr3_thdid = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1] : 
                                tlb_tag4_way_or[`waypos_thdid:`waypos_thdid + `THDID_WIDTH - 1];
      assign tlb_mmucr3_resvattr = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_resvattr] : 
                                   tlb_tag4_way_or[`waypos_resvattr];
      assign tlb_mmucr3_wlc = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_wlc:`waypos_wlc + 1] : 
                              tlb_tag4_way_or[`waypos_wlc:`waypos_wlc + 1];
      assign tlb_mmucr3_class = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_class:`waypos_class + 1] : 
                                tlb_tag4_way_or[`waypos_class:`waypos_class + 1];
      assign tlb_mmucr3_extclass = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_extclass:`waypos_extclass + 1] : 
                                   tlb_tag4_way_or[`waypos_extclass:`waypos_extclass + 1];
      assign tlb_mmucr3_rc = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_rc:`waypos_rc + 1] : 
                             tlb_tag4_way_or[`waypos_rc:`waypos_rc + 1];
      assign tlb_mmucr3_x = ((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1)) ? tlb_tag4_way_rw_or[`waypos_xbit] : 
                            tlb_tag4_way_or[`waypos_xbit];
                            
      assign tlb_mmucr1_een = {tlb_addr4_q, (tag4_parerr_q[2] | tag4_parerr_q[3]), (tag4_parerr_q[1] | tag4_parerr_q[3])};
      
      assign tlb_mmucr1_we = ( ( (|(tag4_parerr_q[0:`TLB_WAYS]) & |(tlb_tag4_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag4_q[`tagpos_type_ptereload])) | tlb_tag4_tlbre_parerr ) | 
                                 ( multihit & tlb_tag4_wayhit_q[`TLB_WAYS] & |(tlb_tag4_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag4_q[`tagpos_type_ptereload]) ) )  
                                & tlb_tag4_q[`tagpos_nonspec] & ECO107332_orred_tag4_thdid_flushed & xu_mm_xucr4_mmu_mchk_q & xu_mm_ccr2_notlb_b;
                               
      assign ECO107332_orred_tag4_thdid_flushed = |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid +  `MM_THREADS - 1] & (~(tlb_ctl_tag4_flush)));

      assign tlb_mas_dtlb_error = tlb_tag4_q[`tagpos_type_derat] & tlb_tag4_q[`tagpos_endflag] & (~tlb_tag4_wayhit_q[`TLB_WAYS]) & tlb_tag4_q[`tagpos_nonspec] & 
                                     ( (~(|(tag4_parerr_q[0:4]))) | cswitch_q[6] ) & |( (msr_gs_q | msr_pr_q | (~epcr_dmiuh_q)) & tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] );
                                     
      assign tlb_mas_itlb_error = tlb_tag4_q[`tagpos_type_ierat] & tlb_tag4_q[`tagpos_endflag] & (~tlb_tag4_wayhit_q[`TLB_WAYS]) & tlb_tag4_q[`tagpos_nonspec] & 
                                     ( (~(|(tag4_parerr_q[0:4]))) | cswitch_q[6] ) & |( (msr_gs_q | msr_pr_q | (~epcr_dmiuh_q)) & tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] );

      assign tlb_mas_tlbsx_hit = tlb_tag4_q[`tagpos_type_tlbsx] & tlb_tag4_wayhit_q[`TLB_WAYS] & (~multihit) & tlb_tag4_hv_op & 
                                     ( (~(|(tag4_parerr_q[0:4]))) | cswitch_q[5] );

      assign tlb_mas_tlbsx_miss = tlb_tag4_q[`tagpos_type_tlbsx] & tlb_tag4_q[`tagpos_endflag] & (~tlb_tag4_wayhit_q[`TLB_WAYS]) & tlb_tag4_hv_op & 
                                     ( (~(|(tag4_parerr_q[0:4]))) | cswitch_q[6] );

      assign tlb_mas_tlbre = tlb_tag4_q[`tagpos_type_tlbre] & (~tlb_tag4_q[`tagpos_atsel]) & tlb_tag4_hv_op & (~ex6_illeg_instr[0]) & 
                                     ( (~(tlb_tag4_tlbre_parerr)) | cswitch_q[7] );

      assign tlb_mas_thdid = tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag4_flush));

      assign tlbwe_tag3_back_inv_enab = (lru_tag3_dataout_q[0] & (lru_tag3_dataout_q[8] | (~cswitch_q[0])) & ((~(tlb_tag3_q[`tagpos_is])) | 
                                            (~(cswitch_q[3]))) & (~tlb_tag3_q[`tagpos_hes]) & (~tlb_tag3_q[`tagpos_esel + 1]) & (~tlb_tag3_q[`tagpos_esel + 2])) | 
                                          (lru_tag3_dataout_q[1] & (lru_tag3_dataout_q[9] | (~cswitch_q[0])) & ((~(tlb_tag3_q[`tagpos_is])) | 
                                            (~(cswitch_q[3]))) & (~tlb_tag3_q[`tagpos_hes]) & (~tlb_tag3_q[`tagpos_esel + 1]) & tlb_tag3_q[`tagpos_esel + 2]) | 
                                          (lru_tag3_dataout_q[2] & (lru_tag3_dataout_q[10] | (~cswitch_q[0])) & ((~(tlb_tag3_q[`tagpos_is])) | 
                                             (~(cswitch_q[3]))) & (~tlb_tag3_q[`tagpos_hes]) & tlb_tag3_q[`tagpos_esel + 1] & (~tlb_tag3_q[`tagpos_esel + 2])) | 
                                          (lru_tag3_dataout_q[3] & (lru_tag3_dataout_q[11] | (~cswitch_q[0])) & ((~(tlb_tag3_q[`tagpos_is])) | 
                                             (~(cswitch_q[3]))) & (~tlb_tag3_q[`tagpos_hes]) & tlb_tag3_q[`tagpos_esel + 1] & tlb_tag3_q[`tagpos_esel + 2]) | 
                                          (lru_tag3_dataout_q[0] & (lru_tag3_dataout_q[8] | (~cswitch_q[0])) & ((~(tlb_tag3_q[`tagpos_is])) | 
                                             (~(cswitch_q[3]))) & tlb_tag3_q[`tagpos_hes] & cswitch_q[1] & (~lru_tag3_dataout_q[4]) & (~lru_tag3_dataout_q[5])) | 
                                          (lru_tag3_dataout_q[1] & (lru_tag3_dataout_q[9] | (~cswitch_q[0])) & ((~(tlb_tag3_q[`tagpos_is])) | 
                                             (~(cswitch_q[3]))) & tlb_tag3_q[`tagpos_hes] & cswitch_q[1] & (~lru_tag3_dataout_q[4]) & lru_tag3_dataout_q[5]) | 
                                          (lru_tag3_dataout_q[2] & (lru_tag3_dataout_q[10] | (~cswitch_q[0])) & ((~(tlb_tag3_q[`tagpos_is])) | 
                                             (~(cswitch_q[3]))) & tlb_tag3_q[`tagpos_hes] & cswitch_q[1] & lru_tag3_dataout_q[4] & (~lru_tag3_dataout_q[6])) | 
                                          (lru_tag3_dataout_q[3] & (lru_tag3_dataout_q[11] | (~cswitch_q[0])) & ((~(tlb_tag3_q[`tagpos_is])) | 
                                             (~(cswitch_q[3]))) & tlb_tag3_q[`tagpos_hes] & cswitch_q[1] & lru_tag3_dataout_q[4] & lru_tag3_dataout_q[6]);

      assign tlbwe_tag4_back_inv_d[0:`MM_THREADS - 1] = tlb_tag3_q[`tagpos_thdid:`tagpos_thdid +  `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush));
      assign tlbwe_tag4_back_inv_d[`MM_THREADS] = ( tlbwe_tag3_back_inv_enab & tlb_tag3_q[`tagpos_type_tlbwe] & (~((tlb_tag3_q[`tagpos_wq:`tagpos_wq + 1] == 2'b10))) & mmucr1_q[pos_tlbwe_binv] & 
                                                    ( ((~(tlb_tag3_q[`tagpos_gs])) & (~(tlb_tag3_q[`tagpos_atsel]))) | (tlb_tag3_q[`tagpos_gs] & tlb_tag3_q[`tagpos_hes] & lrat_tag3_hit_status[1] & (~lrat_tag3_hit_status[2])) ) & 
                                                     |( tlb_tag3_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & (~(tlb_ctl_tag3_flush)) ) );

      assign tlbwe_tag4_back_inv_attr_d[18] = ( lru_tag3_dataout_q[0] & (lru_tag3_dataout_q[8]  | (~cswitch_q[2])) & (~tlb_tag3_q[`tagpos_hes]) & (~tlb_tag3_q[`tagpos_esel + 1]) & (~tlb_tag3_q[`tagpos_esel + 2]) ) | 
                                                ( lru_tag3_dataout_q[1] & (lru_tag3_dataout_q[9]  | (~cswitch_q[2])) & (~tlb_tag3_q[`tagpos_hes]) & (~tlb_tag3_q[`tagpos_esel + 1]) & tlb_tag3_q[`tagpos_esel + 2] ) | 
                                                ( lru_tag3_dataout_q[2] & (lru_tag3_dataout_q[10] | (~cswitch_q[2])) & (~tlb_tag3_q[`tagpos_hes]) & tlb_tag3_q[`tagpos_esel + 1] & (~tlb_tag3_q[`tagpos_esel + 2]) ) | 
                                                ( lru_tag3_dataout_q[3] & (lru_tag3_dataout_q[11] | (~cswitch_q[2])) & (~tlb_tag3_q[`tagpos_hes]) & tlb_tag3_q[`tagpos_esel + 1] & tlb_tag3_q[`tagpos_esel + 2] ) | 
                                                ( lru_tag3_dataout_q[0] & (lru_tag3_dataout_q[8]  | (~cswitch_q[2])) & tlb_tag3_q[`tagpos_hes] & (~lru_tag3_dataout_q[4]) & (~lru_tag3_dataout_q[5]) ) | 
                                                ( lru_tag3_dataout_q[1] & (lru_tag3_dataout_q[9]  | (~cswitch_q[2])) & tlb_tag3_q[`tagpos_hes] & (~lru_tag3_dataout_q[4]) & lru_tag3_dataout_q[5] ) | 
                                                ( lru_tag3_dataout_q[2] & (lru_tag3_dataout_q[10] | (~cswitch_q[2])) & tlb_tag3_q[`tagpos_hes] & lru_tag3_dataout_q[4] & (~lru_tag3_dataout_q[6]) ) | 
                                                ( lru_tag3_dataout_q[3] & (lru_tag3_dataout_q[11] | (~cswitch_q[2])) & tlb_tag3_q[`tagpos_hes] & lru_tag3_dataout_q[4] & lru_tag3_dataout_q[6] );
                                                
      assign tlbwe_tag4_back_inv_attr_d[19] = 1'b0;

      assign tlbwe_back_inv_valid = tlbwe_tag4_back_inv_q[`MM_THREADS] & ((~(tlb_tag4_way_rw_or[`waypos_ind])) | cswitch_q[4]);  
      
      assign tlbwe_back_inv_thdid = tlbwe_tag4_back_inv_q[0:`MM_THREADS - 1];
      
      assign tlbwe_back_inv_addr = tlb_tag4_way_rw_or[`waypos_epn:`waypos_epn + `EPN_WIDTH - 1];
      
      assign tlbwe_back_inv_attr = { 1'b1, 3'b011, 
                                        tlb_tag4_way_rw_or[`waypos_gs], tlb_tag4_way_rw_or[`waypos_ts], 
                                        tlb_tag4_way_rw_or[`waypos_tid + 6:`waypos_tid + `PID_WIDTH -1], 
                                        tlb_tag4_way_rw_or[`waypos_size:`waypos_size + 3], 
                                        tlbwe_tag4_back_inv_attr_q[18:19], 
                                        tlb_tag4_way_rw_or[`waypos_tid:`waypos_tid + 5], 
                                        tlb_tag4_way_rw_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1], 
                                        tlb_tag4_way_rw_or[`waypos_ind] };      

      assign lru_write = lru_write_q & {`LRU_WIDTH{lru_update_clear_enab_q | (~|(tlb_tag5_except_q))}};
      
      assign lru_wr_addr = lru_wr_addr_q;
      assign lru_datain = lru_datain_q;
      
      assign tlb_htw_req_valid = ( tlb_tag4_q[`tagpos_type_derat:`tagpos_type_ierat] != 2'b00 & tlb_tag4_q[`tagpos_type_ptereload] == 1'b0 & tlb_tag4_q[`tagpos_ind] == 1'b1 & 
                                     tlb_tag4_q[`tagpos_nonspec] == 1'b1 & tlb_tag4_wayhit_q[`TLB_WAYS] == 1'b1 & multihit == 1'b0 ) ? 1'b1 : 
                                 1'b0;

      assign tlb_htw_req_way = tlb_tag4_way_or[`TLB_WORD_WIDTH:`TLB_WAY_WIDTH - 1];
      
      assign tlb_htw_req_tag[0:`EPN_WIDTH - 1] = tlb_tag4_q[0:`EPN_WIDTH - 1];
      assign tlb_htw_req_tag[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1] = tlb_tag4_way_or[`waypos_tid:`waypos_tid + `PID_WIDTH - 1];
      assign tlb_htw_req_tag[`tagpos_is:`tagpos_class + 1] = tlb_tag4_q[`tagpos_is:`tagpos_class + 1];
      assign tlb_htw_req_tag[`tagpos_pr] = tlb_tag4_q[`tagpos_pr];
      assign tlb_htw_req_tag[`tagpos_gs] = tlb_tag4_way_or[`waypos_gs];
      assign tlb_htw_req_tag[`tagpos_as] = tlb_tag4_way_or[`waypos_ts];
      assign tlb_htw_req_tag[`tagpos_cm] = tlb_tag4_q[`tagpos_cm];
      assign tlb_htw_req_tag[`tagpos_thdid:`tagpos_lpid - 1] = tlb_tag4_q[`tagpos_thdid:`tagpos_lpid - 1];
      assign tlb_htw_req_tag[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] = tlb_tag4_way_or[`waypos_lpid:`waypos_lpid + `LPID_WIDTH - 1];
      assign tlb_htw_req_tag[`tagpos_ind] = tlb_tag4_q[`tagpos_ind];
      assign tlb_htw_req_tag[`tagpos_atsel] = tlb_tag4_way_or[`waypos_thdid];
      assign tlb_htw_req_tag[`tagpos_esel:`tagpos_esel + 2] = tlb_tag4_way_or[`waypos_thdid + 1:`waypos_thdid + 3];
      assign tlb_htw_req_tag[`tagpos_hes:`TLB_TAG_WIDTH - 1] = tlb_tag4_q[`tagpos_hes:`TLB_TAG_WIDTH - 1];
      
      assign tlb_cmp_perf_event_t0[0] = tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_type_ierat] & (~tlb_tag4_q[`tagpos_type_ptereload]) & (~tlb_tag4_q[`tagpos_ind]) & tlb_tag4_wayhit_q[`TLB_WAYS] & (~multihit);
      assign tlb_cmp_perf_event_t0[1] = tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_type_ierat] & (~tlb_tag4_q[`tagpos_type_ptereload]) & (~tlb_tag4_q[`tagpos_ind]) & (~tlb_tag4_wayhit_q[`TLB_WAYS]) & (tlb_tag3_q[`tagpos_ind] | tlb_tag4_q[`tagpos_endflag]);
      assign tlb_cmp_perf_event_t0[2] = tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_type_ierat] & (~tlb_tag4_q[`tagpos_type_ptereload]) & tlb_tag4_q[`tagpos_ind] & (~tlb_tag4_wayhit_q[`TLB_WAYS]) & tlb_tag4_q[`tagpos_endflag];
      assign tlb_cmp_perf_event_t0[3] = tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_type_ierat] & tlb_tag4_q[`tagpos_type_ptereload] & tlb_tag4_q[`tagpos_is];
      assign tlb_cmp_perf_event_t0[4] = tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_type_ierat] & tlb_tag4_q[`tagpos_type_ptereload] & (~tlb_tag4_q[`tagpos_is]);
      assign tlb_cmp_perf_event_t0[5] = tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_type_derat] & (~tlb_tag4_q[`tagpos_type_ptereload]) & (~tlb_tag4_q[`tagpos_ind]) & tlb_tag4_wayhit_q[`TLB_WAYS] & (~multihit);
      assign tlb_cmp_perf_event_t0[6] = tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_type_derat] & (~tlb_tag4_q[`tagpos_type_ptereload]) & (~tlb_tag4_q[`tagpos_ind]) & (~tlb_tag4_wayhit_q[`TLB_WAYS]) & (tlb_tag3_q[`tagpos_ind] | tlb_tag4_q[`tagpos_endflag]);
      assign tlb_cmp_perf_event_t0[7] = tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_type_derat] & (~tlb_tag4_q[`tagpos_type_ptereload]) & tlb_tag4_q[`tagpos_ind] & (~tlb_tag4_wayhit_q[`TLB_WAYS]) & tlb_tag4_q[`tagpos_endflag];
      assign tlb_cmp_perf_event_t0[8] = tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_type_derat] & tlb_tag4_q[`tagpos_type_ptereload] & tlb_tag4_q[`tagpos_is];
      assign tlb_cmp_perf_event_t0[9] = tlb_tag4_q[`tagpos_thdid + 0] & tlb_tag4_q[`tagpos_type_derat] & tlb_tag4_q[`tagpos_type_ptereload] & (~tlb_tag4_q[`tagpos_is]);
      assign tlb_cmp_perf_event_t1[0] = tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_type_ierat] & (~tlb_tag4_q[`tagpos_type_ptereload]) & (~tlb_tag4_q[`tagpos_ind]) & tlb_tag4_wayhit_q[`TLB_WAYS] & (~multihit);
      assign tlb_cmp_perf_event_t1[1] = tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_type_ierat] & (~tlb_tag4_q[`tagpos_type_ptereload]) & (~tlb_tag4_q[`tagpos_ind]) & (~tlb_tag4_wayhit_q[`TLB_WAYS]) & (tlb_tag3_q[`tagpos_ind] | tlb_tag4_q[`tagpos_endflag]);
      assign tlb_cmp_perf_event_t1[2] = tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_type_ierat] & (~tlb_tag4_q[`tagpos_type_ptereload]) & tlb_tag4_q[`tagpos_ind] & (~tlb_tag4_wayhit_q[`TLB_WAYS]) & tlb_tag4_q[`tagpos_endflag];
      assign tlb_cmp_perf_event_t1[3] = tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_type_ierat] & tlb_tag4_q[`tagpos_type_ptereload] & tlb_tag4_q[`tagpos_is];
      assign tlb_cmp_perf_event_t1[4] = tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_type_ierat] & tlb_tag4_q[`tagpos_type_ptereload] & (~tlb_tag4_q[`tagpos_is]);
      assign tlb_cmp_perf_event_t1[5] = tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_type_derat] & (~tlb_tag4_q[`tagpos_type_ptereload]) & (~tlb_tag4_q[`tagpos_ind]) & tlb_tag4_wayhit_q[`TLB_WAYS] & (~multihit);
      assign tlb_cmp_perf_event_t1[6] = tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_type_derat] & (~tlb_tag4_q[`tagpos_type_ptereload]) & (~tlb_tag4_q[`tagpos_ind]) & (~tlb_tag4_wayhit_q[`TLB_WAYS]) & (tlb_tag3_q[`tagpos_ind] | tlb_tag4_q[`tagpos_endflag]);
      assign tlb_cmp_perf_event_t1[7] = tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_type_derat] & (~tlb_tag4_q[`tagpos_type_ptereload]) & tlb_tag4_q[`tagpos_ind] & (~tlb_tag4_wayhit_q[`TLB_WAYS]) & tlb_tag4_q[`tagpos_endflag];
      assign tlb_cmp_perf_event_t1[8] = tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_type_derat] & tlb_tag4_q[`tagpos_type_ptereload] & tlb_tag4_q[`tagpos_is];
      assign tlb_cmp_perf_event_t1[9] = tlb_tag4_q[`tagpos_thdid + 1] & tlb_tag4_q[`tagpos_type_derat] & tlb_tag4_q[`tagpos_type_ptereload] & (~tlb_tag4_q[`tagpos_is]);
      assign tlb_cmp_perf_state = {tlb_tag4_q[`tagpos_gs], tlb_tag4_q[`tagpos_pr]};
      
      
      
      assign tlb_cmp_perf_miss_direct = |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) & |(tlb_tag4_q[`tagpos_type_derat:`tagpos_type_ierat]) & 
                                            (~tlb_tag4_q[`tagpos_type_ptereload]) & (~tlb_tag4_q[`tagpos_ind]) & (~tlb_tag4_wayhit_q[`TLB_WAYS]) & 
                                             (tlb_tag3_q[`tagpos_ind] | tlb_tag4_q[`tagpos_endflag]);   
                                            
      assign tlb_cmp_perf_hit_direct = |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) & |(tlb_tag4_q[`tagpos_type_derat:`tagpos_type_ierat]) & 
                                              (~tlb_tag4_q[`tagpos_type_ptereload]) & (~tlb_tag4_q[`tagpos_ind]) & tlb_tag4_wayhit_q[`TLB_WAYS] & (~multihit); 

      assign tlb_cmp_perf_hit_indirect = |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) & |(tlb_tag4_q[`tagpos_type_derat:`tagpos_type_ierat]) & 
                                             (~tlb_tag4_q[`tagpos_type_ptereload]) & tlb_tag4_q[`tagpos_ind] & tlb_tag4_wayhit_q[`TLB_WAYS] & (~multihit);  
                                             
      assign tlb_cmp_perf_hit_first_page = |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) & |(tlb_tag4_q[`tagpos_type_derat:`tagpos_type_ierat]) & 
                                              (~tlb_tag4_q[`tagpos_type_ptereload]) & (~tlb_tag4_q[`tagpos_ind]) & tlb_tag4_wayhit_q[`TLB_WAYS] & (~multihit) & 
                                                 (tlb_tag4_q[`tagpos_esel:`tagpos_esel + 2] == 3'b001);   
                                                 
      assign tlb_tag5_perf_d[0] = ( (|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1) & tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 &  
                                       (tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b10) & (tlb_tag4_q[`tagpos_pt] == 1'b1) ) ? {1'b1} : 
                              {1'b0};
      
      assign tlb_tag5_perf_d[1] = ((((|(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS - 1] & tlb_resv_match_vec) == 1'b1 & tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b01 & mmucfg_twc == 1'b1) | 
                                            tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b00 | tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b11) & 
                                   tlb_tag4_q[`tagpos_type_tlbwe] == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1 & tlb_tag4_q[`tagpos_pr] == 1'b0 & tlb_tag4_epcr_dgtmi == 1'b0 & 
                                     mmucfg_lrat == 1'b1 & tlb_tag4_q[`tagpos_is] == 1'b1)) ? |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS-1] & (~(tlb_ctl_tag4_flush))) : 
                           ((tlb_tag4_q[`tagpos_type_ptereload] == 1'b1 & tlb_tag4_q[`tagpos_gs] == 1'b1 & mmucfg_lrat == 1'b1 & tlb_tag4_q[`tagpos_is] == 1'b1 & 
                                 tlb_tag4_q[`tagpos_wq:`tagpos_wq + 1] == 2'b10 & tlb_tag4_q[`tagpos_pt] == 1'b1)) ? |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS-1]) : 
                           {1'b0};
                           
      
      assign tlb_cmp_perf_ptereload = tlb_tag5_perf_q[0];  
      assign tlb_cmp_perf_ptereload_noexcep = tlb_tag5_perf_q[0] & (~(|(tlb_tag5_except_q)));  
      assign tlb_cmp_perf_lrat_request = tlb_tag5_perf_q[1];       
      assign tlb_cmp_perf_lrat_miss = |(lrat_miss_q);  
      assign tlb_cmp_perf_pt_fault = |(pt_fault_q);    
      assign tlb_cmp_perf_pt_inelig = |(tlb_inelig_q); 
      

      assign tlb_cmp_dbg_tag4 = tlb_tag4_q;
      assign tlb_cmp_dbg_tag4_wayhit = tlb_tag4_wayhit_q;
      assign tlb_cmp_dbg_addr4 = tlb_addr4_q;
      assign tlb_cmp_dbg_tag4_way = ( |(tlb_tag4_q[`tagpos_thdid:`tagpos_thdid + `THDID_WIDTH - 1]) == 1'b1 & 
                                         (tlb_tag4_q[`tagpos_type_tlbre] | tlb_tag4_q[`tagpos_type_tlbwe] | tlb_tag4_q[`tagpos_type_ptereload]) == 1'b1 ) ? tlb_tag4_way_rw_or : 
                                    tlb_tag4_way_or;
                                    
      assign tlb_cmp_dbg_tag4_parerr = tag4_parerr_q;
      assign tlb_cmp_dbg_tag4_lru_dataout_q = lru_tag4_dataout_q[0:`LRU_WIDTH - 5];
      assign tlb_cmp_dbg_tag5_lru_datain_q = lru_datain_q[0:`LRU_WIDTH - 5];
      assign tlb_cmp_dbg_tag5_lru_write = lru_write_q[0];
      assign tlb_cmp_dbg_tag5_any_exception = |(tlb_miss_q) | |(hv_priv_q) | |(lrat_miss_q) | |(pt_fault_q) | |(tlb_inelig_q);
      assign tlb_cmp_dbg_tag5_except_type_q = { |(hv_priv_q), |(lrat_miss_q), |(pt_fault_q), |(tlb_inelig_q) };
`ifdef MM_THREADS2      
      assign tlb_cmp_dbg_tag5_except_thdid_q[0] = 1'b0;
      assign tlb_cmp_dbg_tag5_except_thdid_q[1] = hv_priv_q[1] | lrat_miss_q[1] | pt_fault_q[1] | tlb_inelig_q[1] | tlb_miss_q[1];
`else
      assign tlb_cmp_dbg_tag5_except_thdid_q[0] = 1'b0;
      assign tlb_cmp_dbg_tag5_except_thdid_q[1] = 1'b0;
`endif      
      assign tlb_cmp_dbg_tag5_erat_rel_val = tlb_erat_val_q;
      assign tlb_cmp_dbg_tag5_erat_rel_data = tlb_erat_rel_q;
      assign tlb_cmp_dbg_erat_dup_q = tlb_erat_dup_q[0:19];
      assign tlb_cmp_dbg_addr_enable = addr_enable;
      assign tlb_cmp_dbg_pgsize_enable = pgsize_enable;
      assign tlb_cmp_dbg_class_enable = class_enable;
      assign tlb_cmp_dbg_extclass_enable = extclass_enable;
      assign tlb_cmp_dbg_state_enable = state_enable;
      assign tlb_cmp_dbg_thdid_enable = thdid_enable;
      assign tlb_cmp_dbg_pid_enable = pid_enable;
      assign tlb_cmp_dbg_lpid_enable = lpid_enable;
      assign tlb_cmp_dbg_ind_enable = ind_enable;
      assign tlb_cmp_dbg_iprot_enable = iprot_enable;
      assign tlb_cmp_dbg_way0_entry_v = lru_tag3_dataout_q[0];
      assign tlb_cmp_dbg_way0_addr_match = tlb_way0_addr_match;
      assign tlb_cmp_dbg_way0_pgsize_match = tlb_way0_pgsize_match;
      assign tlb_cmp_dbg_way0_class_match = tlb_way0_class_match;
      assign tlb_cmp_dbg_way0_extclass_match = tlb_way0_extclass_match;
      assign tlb_cmp_dbg_way0_state_match = tlb_way0_state_match;
      assign tlb_cmp_dbg_way0_thdid_match = tlb_way0_thdid_match;
      assign tlb_cmp_dbg_way0_pid_match = tlb_way0_pid_match;
      assign tlb_cmp_dbg_way0_lpid_match = tlb_way0_lpid_match;
      assign tlb_cmp_dbg_way0_ind_match = tlb_way0_ind_match;
      assign tlb_cmp_dbg_way0_iprot_match = tlb_way0_iprot_match;
      assign tlb_cmp_dbg_way1_entry_v = lru_tag3_dataout_q[1];
      assign tlb_cmp_dbg_way1_addr_match = tlb_way1_addr_match;
      assign tlb_cmp_dbg_way1_pgsize_match = tlb_way1_pgsize_match;
      assign tlb_cmp_dbg_way1_class_match = tlb_way1_class_match;
      assign tlb_cmp_dbg_way1_extclass_match = tlb_way1_extclass_match;
      assign tlb_cmp_dbg_way1_state_match = tlb_way1_state_match;
      assign tlb_cmp_dbg_way1_thdid_match = tlb_way1_thdid_match;
      assign tlb_cmp_dbg_way1_pid_match = tlb_way1_pid_match;
      assign tlb_cmp_dbg_way1_lpid_match = tlb_way1_lpid_match;
      assign tlb_cmp_dbg_way1_ind_match = tlb_way1_ind_match;
      assign tlb_cmp_dbg_way1_iprot_match = tlb_way1_iprot_match;
      assign tlb_cmp_dbg_way2_entry_v = lru_tag3_dataout_q[2];
      assign tlb_cmp_dbg_way2_addr_match = tlb_way2_addr_match;
      assign tlb_cmp_dbg_way2_pgsize_match = tlb_way2_pgsize_match;
      assign tlb_cmp_dbg_way2_class_match = tlb_way2_class_match;
      assign tlb_cmp_dbg_way2_extclass_match = tlb_way2_extclass_match;
      assign tlb_cmp_dbg_way2_state_match = tlb_way2_state_match;
      assign tlb_cmp_dbg_way2_thdid_match = tlb_way2_thdid_match;
      assign tlb_cmp_dbg_way2_pid_match = tlb_way2_pid_match;
      assign tlb_cmp_dbg_way2_lpid_match = tlb_way2_lpid_match;
      assign tlb_cmp_dbg_way2_ind_match = tlb_way2_ind_match;
      assign tlb_cmp_dbg_way2_iprot_match = tlb_way2_iprot_match;
      assign tlb_cmp_dbg_way3_entry_v = lru_tag3_dataout_q[3];
      assign tlb_cmp_dbg_way3_addr_match = tlb_way3_addr_match;
      assign tlb_cmp_dbg_way3_pgsize_match = tlb_way3_pgsize_match;
      assign tlb_cmp_dbg_way3_class_match = tlb_way3_class_match;
      assign tlb_cmp_dbg_way3_extclass_match = tlb_way3_extclass_match;
      assign tlb_cmp_dbg_way3_state_match = tlb_way3_state_match;
      assign tlb_cmp_dbg_way3_thdid_match = tlb_way3_thdid_match;
      assign tlb_cmp_dbg_way3_pid_match = tlb_way3_pid_match;
      assign tlb_cmp_dbg_way3_lpid_match = tlb_way3_lpid_match;
      assign tlb_cmp_dbg_way3_ind_match = tlb_way3_ind_match;
      assign tlb_cmp_dbg_way3_iprot_match = tlb_way3_iprot_match;
      
      tri_direct_err_rpt #(.WIDTH(3)) tlb_direct_err_rpt(
         .vd(vdd),
         .gd(gnd),
         .err_in( {tlb_multihit_err_ored, tlb_par_err_ored, lru_par_err_ored} ),
         .err_out( {mm_pc_tlb_multihit_err_ored, mm_pc_tlb_par_err_ored, mm_pc_lru_par_err_ored} )
      );
      
      assign unused_dc[0] = |(lcb_delay_lclkr_dc[1:4]);
      assign unused_dc[1] = |(lcb_mpw1_dc_b[1:4]);
      assign unused_dc[2] = pc_func_sl_force;
      assign unused_dc[3] = pc_func_sl_thold_0_b;
      assign unused_dc[4] = tc_scan_dis_dc_b;
      assign unused_dc[5] = tc_scan_diag_dc;
      assign unused_dc[6] = tc_lbist_en_dc;
      assign unused_dc[7] = tlb_tag3_clone1_q[70];
      assign unused_dc[8] = tlb_tag3_clone1_q[73];
      assign unused_dc[9] = |(tlb_tag3_clone1_q[99:100]);
      assign unused_dc[10] = |(tlb_tag3_clone1_q[104:109]);
      assign unused_dc[11] = tlb_tag3_clone2_q[70];
      assign unused_dc[12] = tlb_tag3_clone2_q[73];
      assign unused_dc[13] = |(tlb_tag3_clone2_q[99:100]);
      assign unused_dc[14] = |(tlb_tag3_clone2_q[104:109]);
      assign unused_dc[15] = 1'b0;
      assign unused_dc[16] = tlb_tag3_cmpmask_q[4];
      assign unused_dc[17] = tlb_tag3_cmpmask_clone_q[4];
      assign unused_dc[18] = |({mmucr1_clone_q[11], mmucr1_clone_q[17]});
      assign unused_dc[19] = |({tlb_tag4_type_sig[0:3], tlb_tag4_type_sig[5]});
      assign unused_dc[20] = tlb_tag4_esel_sig[0];
      assign unused_dc[21] = |(tlb_tag4_wq_sig);
      assign unused_dc[22] = |(tlb_tag4_is_sig[2:3]);
      assign unused_dc[23] = |(ptereload_req_pte_lat[0:9]);
      assign unused_dc[24] = |({ptereload_req_pte_lat[50], ptereload_req_pte_lat[55], ptereload_req_pte_lat[62]});
`ifdef MM_THREADS2      
      assign unused_dc[25] = |({mmucr3_0[53], mmucr3_0[59]}) | |({mmucr3_1[53], mmucr3_1[59]});
`else
      assign unused_dc[25] = |({mmucr3_0[53], mmucr3_0[59]});
`endif      
      assign unused_dc[26] = mmucr1_clone_q[pos_tlb_pei];
      assign unused_dc[27] = 1'b0;
      assign unused_dc[28] = |(lru_datain_alt_d[4:9]);
      assign unused_dc[29] = tlb0cfg_pt;
      assign unused_dc[30] = |(tlb_dsi_q);
      assign unused_dc[31] = |(tlb_isi_q);
      assign unused_dc[32] = |(lrat_tag3_lpn_sig);
      assign unused_dc[33] = |(lrat_tag3_rpn_sig);
      assign unused_dc[34] = |(lrat_tag4_lpn_sig);
      assign unused_dc[35] = lrat_tag3_hit_status[0];
      assign unused_dc[36] = lrat_tag3_hit_status[3];
      assign unused_dc[37] = |(lrat_tag3_hit_entry);
      assign unused_dc[38] = |(lrat_tag4_hit_entry);
      assign unused_dc[39] = |(tlb_tag3_clone1_q[`tagpos_itag:`tagpos_emq + `EMQ_ENTRIES - 1]);
      assign unused_dc[40] = |(tlb_tag3_clone2_q[`tagpos_itag:`tagpos_emq + `EMQ_ENTRIES - 1]);
      assign unused_dc[41] = ierat_req0_nonspec | ierat_req1_nonspec | ierat_req2_nonspec | ierat_req3_nonspec;
      
      tri_rlmreg_p #(.WIDTH(`TLB_WAY_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_way0_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[12]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_way0_offset:tlb_way0_offset + `TLB_WAY_WIDTH - 1]),
         .scout(sov_0[tlb_way0_offset:tlb_way0_offset + `TLB_WAY_WIDTH - 1]),
         .din(tlb_way0_d[0:`TLB_WAY_WIDTH - 1]),
         .dout(tlb_way0_q[0:`TLB_WAY_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_WAY_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_way1_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[12]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_way1_offset:tlb_way1_offset + `TLB_WAY_WIDTH - 1]),
         .scout(sov_0[tlb_way1_offset:tlb_way1_offset + `TLB_WAY_WIDTH - 1]),
         .din(tlb_way1_d[0:`TLB_WAY_WIDTH - 1]),
         .dout(tlb_way1_q[0:`TLB_WAY_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_WAY_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_way2_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[13]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[tlb_way2_offset:tlb_way2_offset + `TLB_WAY_WIDTH - 1]),
         .scout(sov_1[tlb_way2_offset:tlb_way2_offset + `TLB_WAY_WIDTH - 1]),
         .din(tlb_way2_d[0:`TLB_WAY_WIDTH - 1]),
         .dout(tlb_way2_q[0:`TLB_WAY_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_WAY_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_way3_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[13]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[tlb_way3_offset:tlb_way3_offset + `TLB_WAY_WIDTH - 1]),
         .scout(sov_1[tlb_way3_offset:tlb_way3_offset + `TLB_WAY_WIDTH - 1]),
         .din(tlb_way3_d[0:`TLB_WAY_WIDTH - 1]),
         .dout(tlb_way3_q[0:`TLB_WAY_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_TAG_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_tag3_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[9]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_tag3_offset:tlb_tag3_offset + `TLB_TAG_WIDTH - 1]),
         .scout(sov_2[tlb_tag3_offset:tlb_tag3_offset + `TLB_TAG_WIDTH - 1]),
         .din(tlb_tag3_d[0:`TLB_TAG_WIDTH - 1]),
         .dout(tlb_tag3_q[0:`TLB_TAG_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_TAG_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_tag3_clone1_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[12]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_tag3_clone1_offset:tlb_tag3_clone1_offset + `TLB_TAG_WIDTH - 1]),
         .scout(sov_0[tlb_tag3_clone1_offset:tlb_tag3_clone1_offset + `TLB_TAG_WIDTH - 1]),
         .din(tlb_tag3_clone1_d[0:`TLB_TAG_WIDTH - 1]),
         .dout(tlb_tag3_clone1_q[0:`TLB_TAG_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_TAG_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_tag3_clone2_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[13]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[tlb_tag3_clone2_offset:tlb_tag3_clone2_offset + `TLB_TAG_WIDTH - 1]),
         .scout(sov_1[tlb_tag3_clone2_offset:tlb_tag3_clone2_offset + `TLB_TAG_WIDTH - 1]),
         .din(tlb_tag3_clone2_d[0:`TLB_TAG_WIDTH - 1]),
         .dout(tlb_tag3_clone2_q[0:`TLB_TAG_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_ADDR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_addr3_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[9]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_addr3_offset:tlb_addr3_offset + `TLB_ADDR_WIDTH - 1]),
         .scout(sov_2[tlb_addr3_offset:tlb_addr3_offset + `TLB_ADDR_WIDTH - 1]),
         .din(tlb_addr3_d[0:`TLB_ADDR_WIDTH - 1]),
         .dout(tlb_addr3_q[0:`TLB_ADDR_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) lru_tag3_dataout_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[9]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[lru_tag3_dataout_offset:lru_tag3_dataout_offset + 16 - 1]),
         .scout(sov_2[lru_tag3_dataout_offset:lru_tag3_dataout_offset + 16 - 1]),
         .din(lru_tag3_dataout_d[0:15]),
         .dout(lru_tag3_dataout_q[0:15])
      );
      
      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) tlb_tag3_cmpmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[12]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_tag3_cmpmask_offset:tlb_tag3_cmpmask_offset + 5 - 1]),
         .scout(sov_0[tlb_tag3_cmpmask_offset:tlb_tag3_cmpmask_offset + 5 - 1]),
         .din(tlb_tag3_cmpmask_d),
         .dout(tlb_tag3_cmpmask_q)
      );
      
      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) tlb_tag3_cmpmask_clone_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[13]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[tlb_tag3_cmpmask_clone_offset:tlb_tag3_cmpmask_clone_offset + 5 - 1]),
         .scout(sov_1[tlb_tag3_cmpmask_clone_offset:tlb_tag3_cmpmask_clone_offset + 5 - 1]),
         .din(tlb_tag3_cmpmask_clone_d),
         .dout(tlb_tag3_cmpmask_clone_q)
      );
      
      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) tlb_way0_cmpmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[12]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_way0_cmpmask_offset:tlb_way0_cmpmask_offset + 5 - 1]),
         .scout(sov_0[tlb_way0_cmpmask_offset:tlb_way0_cmpmask_offset + 5 - 1]),
         .din(tlb_way0_cmpmask_d),
         .dout(tlb_way0_cmpmask_q)
      );
      
      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) tlb_way1_cmpmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[12]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_way1_cmpmask_offset:tlb_way1_cmpmask_offset + 5 - 1]),
         .scout(sov_0[tlb_way1_cmpmask_offset:tlb_way1_cmpmask_offset + 5 - 1]),
         .din(tlb_way1_cmpmask_d),
         .dout(tlb_way1_cmpmask_q)
      );
      
      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) tlb_way2_cmpmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[13]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[tlb_way2_cmpmask_offset:tlb_way2_cmpmask_offset + 5 - 1]),
         .scout(sov_1[tlb_way2_cmpmask_offset:tlb_way2_cmpmask_offset + 5 - 1]),
         .din(tlb_way2_cmpmask_d),
         .dout(tlb_way2_cmpmask_q)
      );
      
      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) tlb_way3_cmpmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[13]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[tlb_way3_cmpmask_offset:tlb_way3_cmpmask_offset + 5 - 1]),
         .scout(sov_1[tlb_way3_cmpmask_offset:tlb_way3_cmpmask_offset + 5 - 1]),
         .din(tlb_way3_cmpmask_d),
         .dout(tlb_way3_cmpmask_q)
      );
      
      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) tlb_way0_xbitmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[12]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_way0_xbitmask_offset:tlb_way0_xbitmask_offset + 5 - 1]),
         .scout(sov_0[tlb_way0_xbitmask_offset:tlb_way0_xbitmask_offset + 5 - 1]),
         .din(tlb_way0_xbitmask_d),
         .dout(tlb_way0_xbitmask_q)
      );
      
      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) tlb_way1_xbitmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[12]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_way1_xbitmask_offset:tlb_way1_xbitmask_offset + 5 - 1]),
         .scout(sov_0[tlb_way1_xbitmask_offset:tlb_way1_xbitmask_offset + 5 - 1]),
         .din(tlb_way1_xbitmask_d),
         .dout(tlb_way1_xbitmask_q)
      );
      
      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) tlb_way2_xbitmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[13]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[tlb_way2_xbitmask_offset:tlb_way2_xbitmask_offset + 5 - 1]),
         .scout(sov_1[tlb_way2_xbitmask_offset:tlb_way2_xbitmask_offset + 5 - 1]),
         .din(tlb_way2_xbitmask_d),
         .dout(tlb_way2_xbitmask_q)
      );
      
      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) tlb_way3_xbitmask_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[13]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[tlb_way3_xbitmask_offset:tlb_way3_xbitmask_offset + 5 - 1]),
         .scout(sov_1[tlb_way3_xbitmask_offset:tlb_way3_xbitmask_offset + 5 - 1]),
         .din(tlb_way3_xbitmask_d),
         .dout(tlb_way3_xbitmask_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_TAG_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_tag4_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[10]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_tag4_offset:tlb_tag4_offset + `TLB_TAG_WIDTH - 1]),
         .scout(sov_2[tlb_tag4_offset:tlb_tag4_offset + `TLB_TAG_WIDTH - 1]),
         .din(tlb_tag4_d[0:`TLB_TAG_WIDTH - 1]),
         .dout(tlb_tag4_q[0:`TLB_TAG_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH((`TLB_WAYS+1)), .INIT(0), .NEEDS_SRESET(1)) tlb_tag4_wayhit_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[10]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_tag4_wayhit_offset:tlb_tag4_wayhit_offset + (`TLB_WAYS+1) - 1]),
         .scout(sov_2[tlb_tag4_wayhit_offset:tlb_tag4_wayhit_offset + (`TLB_WAYS+1) - 1]),
         .din(tlb_tag4_wayhit_d[0:`TLB_WAYS]),
         .dout(tlb_tag4_wayhit_q[0:`TLB_WAYS])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_ADDR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_addr4_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[10]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_addr4_offset:tlb_addr4_offset + `TLB_ADDR_WIDTH - 1]),
         .scout(sov_2[tlb_addr4_offset:tlb_addr4_offset + `TLB_ADDR_WIDTH - 1]),
         .din(tlb_addr4_d[0:`TLB_ADDR_WIDTH - 1]),
         .dout(tlb_addr4_q[0:`TLB_ADDR_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_WAY_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_dataina_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[14]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_dataina_offset:tlb_dataina_offset + `TLB_WAY_WIDTH - 1]),
         .scout(sov_0[tlb_dataina_offset:tlb_dataina_offset + `TLB_WAY_WIDTH - 1]),
         .din(tlb_dataina_d[0:`TLB_WAY_WIDTH - 1]),
         .dout(tlb_dataina_q[0:`TLB_WAY_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_WAY_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_datainb_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[15]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[tlb_datainb_offset:tlb_datainb_offset + `TLB_WAY_WIDTH - 1]),
         .scout(sov_1[tlb_datainb_offset:tlb_datainb_offset + `TLB_WAY_WIDTH - 1]),
         .din(tlb_datainb_d[0:`TLB_WAY_WIDTH - 1]),
         .dout(tlb_datainb_q[0:`TLB_WAY_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`LRU_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lru_tag4_dataout_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[10]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[lru_tag4_dataout_offset:lru_tag4_dataout_offset + `LRU_WIDTH - 1]),
         .scout(sov_2[lru_tag4_dataout_offset:lru_tag4_dataout_offset + `LRU_WIDTH - 1]),
         .din(lru_tag4_dataout_d[0:15]),
         .dout(lru_tag4_dataout_q[0:15])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_WAY_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_tag4_way_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_tag4_way_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_tag4_way_offset:tlb_tag4_way_offset + `TLB_WAY_WIDTH - 1]),
         .scout(sov_0[tlb_tag4_way_offset:tlb_tag4_way_offset + `TLB_WAY_WIDTH - 1]),
         .din(tlb_tag4_way_d[0:`TLB_WAY_WIDTH - 1]),
         .dout(tlb_tag4_way_q[0:`TLB_WAY_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_WAY_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_tag4_way_clone_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_tag4_way_clone_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[tlb_tag4_way_clone_offset:tlb_tag4_way_clone_offset + `TLB_WAY_WIDTH - 1]),
         .scout(sov_1[tlb_tag4_way_clone_offset:tlb_tag4_way_clone_offset + `TLB_WAY_WIDTH - 1]),
         .din(tlb_tag4_way_clone_d[0:`TLB_WAY_WIDTH - 1]),
         .dout(tlb_tag4_way_clone_q[0:`TLB_WAY_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_WAY_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_tag4_way_rw_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_tag4_way_rw_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_tag4_way_rw_offset:tlb_tag4_way_rw_offset + `TLB_WAY_WIDTH - 1]),
         .scout(sov_0[tlb_tag4_way_rw_offset:tlb_tag4_way_rw_offset + `TLB_WAY_WIDTH - 1]),
         .din(tlb_tag4_way_rw_d[0:`TLB_WAY_WIDTH - 1]),
         .dout(tlb_tag4_way_rw_q[0:`TLB_WAY_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_WAY_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_tag4_way_rw_clone_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_tag4_way_rw_clone_act),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[tlb_tag4_way_rw_clone_offset:tlb_tag4_way_rw_clone_offset + `TLB_WAY_WIDTH - 1]),
         .scout(sov_1[tlb_tag4_way_rw_clone_offset:tlb_tag4_way_rw_clone_offset + `TLB_WAY_WIDTH - 1]),
         .din(tlb_tag4_way_rw_clone_d[0:`TLB_WAY_WIDTH - 1]),
         .dout(tlb_tag4_way_rw_clone_q[0:`TLB_WAY_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS+1), .INIT(0), .NEEDS_SRESET(1)) tlbwe_tag4_back_inv_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[10]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlbwe_tag4_back_inv_offset:tlbwe_tag4_back_inv_offset + `MM_THREADS]),
         .scout(sov_2[tlbwe_tag4_back_inv_offset:tlbwe_tag4_back_inv_offset + `MM_THREADS]),
         .din(tlbwe_tag4_back_inv_d),
         .dout(tlbwe_tag4_back_inv_q)
      );
      
      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) tlbwe_tag4_back_inv_attr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[10]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlbwe_tag4_back_inv_attr_offset:tlbwe_tag4_back_inv_attr_offset + 2 - 1]),
         .scout(sov_2[tlbwe_tag4_back_inv_attr_offset:tlbwe_tag4_back_inv_attr_offset + 2 - 1]),
         .din(tlbwe_tag4_back_inv_attr_d),
         .dout(tlbwe_tag4_back_inv_attr_q)
      );
      
      tri_rlmreg_p #(.WIDTH((2*`THDID_WIDTH+1+1)), .INIT(0), .NEEDS_SRESET(1)) tlb_erat_val_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[14]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_erat_val_offset:tlb_erat_val_offset + (2*`THDID_WIDTH+1+1) - 1]),
         .scout(sov_2[tlb_erat_val_offset:tlb_erat_val_offset + (2*`THDID_WIDTH+1+1) - 1]),
         .din(tlb_erat_val_d[0:2 * `THDID_WIDTH + 1]),
         .dout(tlb_erat_val_q[0:2 * `THDID_WIDTH + 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`ERAT_REL_DATA_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_erat_rel_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[14]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_0[tlb_erat_rel_offset:tlb_erat_rel_offset + `ERAT_REL_DATA_WIDTH - 1]),
         .scout(sov_0[tlb_erat_rel_offset:tlb_erat_rel_offset + `ERAT_REL_DATA_WIDTH - 1]),
         .din(tlb_erat_rel_d[0:`ERAT_REL_DATA_WIDTH - 1]),
         .dout(tlb_erat_rel_q[0:`ERAT_REL_DATA_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`ERAT_REL_DATA_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlb_erat_rel_clone_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[15]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_1[tlb_erat_rel_clone_offset:tlb_erat_rel_clone_offset + `ERAT_REL_DATA_WIDTH - 1]),
         .scout(sov_1[tlb_erat_rel_clone_offset:tlb_erat_rel_clone_offset + `ERAT_REL_DATA_WIDTH - 1]),
         .din(tlb_erat_rel_clone_d[0:`ERAT_REL_DATA_WIDTH - 1]),
         .dout(tlb_erat_rel_clone_q[0:`ERAT_REL_DATA_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH((2*`THDID_WIDTH+13+1)), .INIT(0), .NEEDS_SRESET(1)) tlb_erat_dup_latch(
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
         .scin(siv_2[tlb_erat_dup_offset:tlb_erat_dup_offset + (2*`THDID_WIDTH+13+1) - 1]),
         .scout(sov_2[tlb_erat_dup_offset:tlb_erat_dup_offset + (2*`THDID_WIDTH+13+1) - 1]),
         .din(tlb_erat_dup_d),
         .dout(tlb_erat_dup_q)
      );
      
      tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) lru_write_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[11]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[lru_write_offset:lru_write_offset + 16 - 1]),
         .scout(sov_2[lru_write_offset:lru_write_offset + 16 - 1]),
         .din(lru_write_d[0:15]),
         .dout(lru_write_q[0:15])
      );
      
      tri_rlmreg_p #(.WIDTH(`TLB_ADDR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lru_wr_addr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[11]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[lru_wr_addr_offset:lru_wr_addr_offset + `TLB_ADDR_WIDTH - 1]),
         .scout(sov_2[lru_wr_addr_offset:lru_wr_addr_offset + `TLB_ADDR_WIDTH - 1]),
         .din(lru_wr_addr_d[0:`TLB_ADDR_WIDTH - 1]),
         .dout(lru_wr_addr_q[0:`TLB_ADDR_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) lru_datain_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[11]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[lru_datain_offset:lru_datain_offset + 16 - 1]),
         .scout(sov_2[lru_datain_offset:lru_datain_offset + 16 - 1]),
         .din(lru_datain_d[0:15]),
         .dout(lru_datain_q[0:15])
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) eratmiss_done_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[eratmiss_done_offset:eratmiss_done_offset + `MM_THREADS - 1]),
         .scout(sov_2[eratmiss_done_offset:eratmiss_done_offset + `MM_THREADS - 1]),
         .din(eratmiss_done_d),
         .dout(eratmiss_done_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_miss_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_miss_offset:tlb_miss_offset + `MM_THREADS - 1]),
         .scout(sov_2[tlb_miss_offset:tlb_miss_offset + `MM_THREADS - 1]),
         .din(tlb_miss_d),
         .dout(tlb_miss_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_inelig_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_inelig_offset:tlb_inelig_offset + `MM_THREADS - 1]),
         .scout(sov_2[tlb_inelig_offset:tlb_inelig_offset + `MM_THREADS - 1]),
         .din(tlb_inelig_d),
         .dout(tlb_inelig_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) lrat_miss_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[lrat_miss_offset:lrat_miss_offset + `MM_THREADS - 1]),
         .scout(sov_2[lrat_miss_offset:lrat_miss_offset + `MM_THREADS - 1]),
         .din(lrat_miss_d),
         .dout(lrat_miss_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) pt_fault_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[pt_fault_offset:pt_fault_offset + `MM_THREADS - 1]),
         .scout(sov_2[pt_fault_offset:pt_fault_offset + `MM_THREADS - 1]),
         .din(pt_fault_d),
         .dout(pt_fault_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) hv_priv_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[hv_priv_offset:hv_priv_offset + `MM_THREADS - 1]),
         .scout(sov_2[hv_priv_offset:hv_priv_offset + `MM_THREADS - 1]),
         .din(hv_priv_d),
         .dout(hv_priv_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_tag5_except_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[11]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_tag5_except_offset:tlb_tag5_except_offset + `MM_THREADS - 1]),
         .scout(sov_2[tlb_tag5_except_offset:tlb_tag5_except_offset + `MM_THREADS - 1]),
         .din(tlb_tag5_except_d),
         .dout(tlb_tag5_except_q)
      );
      
      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) mm_xu_ord_par_mhit_err_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[11]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[mm_xu_ord_par_mhit_err_offset:mm_xu_ord_par_mhit_err_offset + 3 - 1]),
         .scout(sov_2[mm_xu_ord_par_mhit_err_offset:mm_xu_ord_par_mhit_err_offset + 3 - 1]),
         .din(mm_xu_ord_par_mhit_err_d),
         .dout(mm_xu_ord_par_mhit_err_q)
      );
      
      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lru_update_clear_enab_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[11]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[lru_update_clear_enab_offset]),
         .scout(sov_2[lru_update_clear_enab_offset]),
         .din(lru_update_clear_enab),
         .dout(lru_update_clear_enab_q)
      );
      
      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_tag5_parerr_zeroize_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[11]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_tag5_parerr_zeroize_offset]),
         .scout(sov_2[tlb_tag5_parerr_zeroize_offset]),
         .din(tlb_tag4_parerr_zeroize),
         .dout(tlb_tag5_parerr_zeroize_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) tlb_tag5_itag_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[11]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_tag5_itag_offset:tlb_tag5_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov_2[tlb_tag5_itag_offset:tlb_tag5_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(tlb_tag5_itag_d),
         .dout(tlb_tag5_itag_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`EMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) tlb_tag5_emq_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[11]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_tag5_emq_offset:tlb_tag5_emq_offset + `EMQ_ENTRIES - 1]),
         .scout(sov_2[tlb_tag5_emq_offset:tlb_tag5_emq_offset + `EMQ_ENTRIES - 1]),
         .din(tlb_tag5_emq_d),
         .dout(tlb_tag5_emq_q)
      );
      
      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) tlb_tag5_perf_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[11]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_tag5_perf_offset:tlb_tag5_perf_offset + 2 - 1]),
         .scout(sov_2[tlb_tag5_perf_offset:tlb_tag5_perf_offset + 2 - 1]),
         .din(tlb_tag5_perf_d),
         .dout(tlb_tag5_perf_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_dsi_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_dsi_offset:tlb_dsi_offset + `MM_THREADS - 1]),
         .scout(sov_2[tlb_dsi_offset:tlb_dsi_offset + `MM_THREADS - 1]),
         .din(tlb_dsi_d),
         .dout(tlb_dsi_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_isi_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_isi_offset:tlb_isi_offset + `MM_THREADS - 1]),
         .scout(sov_2[tlb_isi_offset:tlb_isi_offset + `MM_THREADS - 1]),
         .din(tlb_isi_d),
         .dout(tlb_isi_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) esr_pt_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[esr_pt_offset:esr_pt_offset + `MM_THREADS - 1]),
         .scout(sov_2[esr_pt_offset:esr_pt_offset + `MM_THREADS - 1]),
         .din(esr_pt_d),
         .dout(esr_pt_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) esr_data_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[esr_data_offset:esr_data_offset + `MM_THREADS - 1]),
         .scout(sov_2[esr_data_offset:esr_data_offset + `MM_THREADS - 1]),
         .din(esr_data_d),
         .dout(esr_data_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) esr_st_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[esr_st_offset:esr_st_offset + `MM_THREADS - 1]),
         .scout(sov_2[esr_st_offset:esr_st_offset + `MM_THREADS - 1]),
         .din(esr_st_d),
         .dout(esr_st_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) esr_epid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[esr_epid_offset:esr_epid_offset + `MM_THREADS - 1]),
         .scout(sov_2[esr_epid_offset:esr_epid_offset + `MM_THREADS - 1]),
         .din(esr_epid_d),
         .dout(esr_epid_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) cr0_eq_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[cr0_eq_offset:cr0_eq_offset + `MM_THREADS - 1]),
         .scout(sov_2[cr0_eq_offset:cr0_eq_offset + `MM_THREADS - 1]),
         .din(cr0_eq_d),
         .dout(cr0_eq_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) cr0_eq_valid_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[cr0_eq_valid_offset:cr0_eq_valid_offset + `MM_THREADS - 1]),
         .scout(sov_2[cr0_eq_valid_offset:cr0_eq_valid_offset + `MM_THREADS - 1]),
         .din(cr0_eq_valid_d),
         .dout(cr0_eq_valid_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_multihit_err_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_multihit_err_offset:tlb_multihit_err_offset + `MM_THREADS - 1]),
         .scout(sov_2[tlb_multihit_err_offset:tlb_multihit_err_offset + `MM_THREADS - 1]),
         .din(tlb_multihit_err_d),
         .dout(tlb_multihit_err_q)
      );
      
      tri_rlmreg_p #(.WIDTH((`TLB_WAYS+1)), .INIT(0), .NEEDS_SRESET(1)) tag4_parerr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[10]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tag4_parerr_offset:tag4_parerr_offset + (`TLB_WAYS+1) - 1]),
         .scout(sov_2[tag4_parerr_offset:tag4_parerr_offset + (`TLB_WAYS+1) - 1]),
         .din(tag4_parerr_d),
         .dout(tag4_parerr_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) tlb_par_err_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[tlb_par_err_offset:tlb_par_err_offset + `MM_THREADS - 1]),
         .scout(sov_2[tlb_par_err_offset:tlb_par_err_offset + `MM_THREADS - 1]),
         .din(ECO107332_tlb_par_err_d),
         .dout(tlb_par_err_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) lru_par_err_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[lru_par_err_offset:lru_par_err_offset + `MM_THREADS - 1]),
         .scout(sov_2[lru_par_err_offset:lru_par_err_offset + `MM_THREADS - 1]),
         .din(ECO107332_lru_par_err_d),
         .dout(lru_par_err_q)
      );
      
      tri_rlmreg_p #(.WIDTH(9), .INIT(0), .NEEDS_SRESET(1)) mmucr1_latch(
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
         .scin(siv_0[mmucr1_offset:mmucr1_offset + 9 - 1]),
         .scout(sov_0[mmucr1_offset:mmucr1_offset + 9 - 1]),
         .din(mmucr1),
         .dout(mmucr1_q)
      );
      
      tri_rlmreg_p #(.WIDTH(9), .INIT(0), .NEEDS_SRESET(1)) mmucr1_clone_latch(
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
         .scin(siv_1[mmucr1_clone_offset:mmucr1_clone_offset + 9 - 1]),
         .scout(sov_1[mmucr1_clone_offset:mmucr1_clone_offset + 9 - 1]),
         .din(mmucr1),
         .dout(mmucr1_clone_q)
      );
      
      tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) spare_a_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[14]),
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
      
      tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) spare_b_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[15]),
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
      
      tri_rlmreg_p #(.WIDTH(8), .INIT(MMQ_TLB_CMP_CSWITCH_0TO7), .NEEDS_SRESET(1)) cswitch_latch(
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
         .scin(siv_2[cswitch_offset:cswitch_offset + 8 - 1]),
         .scout(sov_2[cswitch_offset:cswitch_offset + 8 - 1]),
         .din(cswitch_q),
         .dout(cswitch_q)
      );
      
      tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) spare_c_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(tlb_delayed_act[16]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv_2[spare_c_offset:spare_c_offset + 16 - 1]),
         .scout(sov_2[spare_c_offset:spare_c_offset + 16 - 1]),
         .din(spare_c_q),
         .dout(spare_c_q)
      );
      
      
      tri_regk #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(0)) spare_nsl_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(xu_mm_ccr2_notlb_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_nsl_force[0]),
         .d_mode(lcb_d_mode_dc),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .thold_b(pc_func_slp_nsl_thold_0_b[0]),
         .scin(tri_regk_unused_scan[0:7]),
         .scout(tri_regk_unused_scan[0:7]),
         .din(spare_nsl_q),
         .dout(spare_nsl_q)
      );
      
      tri_regk #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(0)) spare_nsl_clone_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(xu_mm_ccr2_notlb_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_nsl_force[1]),
         .d_mode(lcb_d_mode_dc),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .thold_b(pc_func_slp_nsl_thold_0_b[1]),
         .scin(tri_regk_unused_scan[8:15]),
         .scout(tri_regk_unused_scan[8:15]),
         .din(spare_nsl_clone_q),
         .dout(spare_nsl_clone_q)
      );
      
      tri_regk #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(0)) epcr_dmiuh_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(xu_mm_ccr2_notlb_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_nsl_force[0]),
         .d_mode(lcb_d_mode_dc),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .thold_b(pc_func_slp_nsl_thold_0_b[0]),
         .scin(tri_regk_unused_scan_epcr_dmiuh),
         .scout(tri_regk_unused_scan_epcr_dmiuh),
         .din(xu_mm_spr_epcr_dmiuh),
         .dout(epcr_dmiuh_q)
      );
      
      tri_regk #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(0)) msr_gs_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(xu_mm_ccr2_notlb_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_nsl_force[0]),
         .d_mode(lcb_d_mode_dc),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .thold_b(pc_func_slp_nsl_thold_0_b[0]),
         .scin(tri_regk_unused_scan_msr_gs),
         .scout(tri_regk_unused_scan_msr_gs),
         .din(xu_mm_msr_gs),
         .dout(msr_gs_q)
      );

      tri_regk #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(0)) msr_pr_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(xu_mm_ccr2_notlb_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_nsl_force[0]),
         .d_mode(lcb_d_mode_dc),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .thold_b(pc_func_slp_nsl_thold_0_b[0]),
         .scin(tri_regk_unused_scan_msr_pr),
         .scout(tri_regk_unused_scan_msr_pr),
         .din(xu_mm_msr_pr),
         .dout(msr_pr_q)
      );
     
      
      
      
      tri_plat #(.WIDTH(5)) perv_2to1_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ccflush_dc),
         .din( {pc_func_sl_thold_2, pc_func_slp_sl_thold_2, pc_func_slp_nsl_thold_2, pc_sg_2, pc_fce_2} ),
         .q(    {pc_func_sl_thold_1, pc_func_slp_sl_thold_1, pc_func_slp_nsl_thold_1, pc_sg_1, pc_fce_1} )
      );
      
      tri_plat #(.WIDTH(5)) perv_1to0_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .flush(tc_ccflush_dc),
         .din( {pc_func_sl_thold_1, pc_func_slp_sl_thold_1, pc_func_slp_nsl_thold_1, pc_sg_1, pc_fce_1} ),
         .q(    {pc_func_sl_thold_0, pc_func_slp_sl_thold_0, pc_func_slp_nsl_thold_0, pc_sg_0, pc_fce_0} )
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
         .force_t(pc_func_slp_nsl_force[0]),
         .thold_b(pc_func_slp_nsl_thold_0_b[0])
      );
      
      tri_lcbor  perv_nsl_lcbor_clone(
         .clkoff_b(lcb_clkoff_dc_b),
         .thold(pc_func_slp_nsl_thold_0),
         .sg(pc_fce_0),
         .act_dis(tidn),
         .force_t(pc_func_slp_nsl_force[1]),
         .thold_b(pc_func_slp_nsl_thold_0_b[1])
      );
      
      
      assign siv_0[0:scan_right_0] = {sov_0[1:scan_right_0], ac_func_scan_in[0]};
      assign ac_func_scan_out[0] = sov_0[0];
      assign siv_1[0:scan_right_1] = {sov_1[1:scan_right_1], ac_func_scan_in[1]};
      assign ac_func_scan_out[1] = sov_1[0];
      assign siv_2[0:scan_right_2] = {sov_2[1:scan_right_2], ac_func_scan_in[2]};
      assign ac_func_scan_out[2] = sov_2[0];
      
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
