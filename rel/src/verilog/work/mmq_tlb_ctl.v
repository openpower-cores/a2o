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
   output [0:1]                   ex6_illeg_instr,        

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
   output [0:1]                   tlb_ctl_dbg_tag0_thdid,    
   output [0:2]                   tlb_ctl_dbg_tag0_type,     
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
      parameter [0:2]                ERAT_PgSize_256MB = 3'b100;
      parameter [0:3]                TLB_PgSize_256MB = 4'b1001;
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

      parameter                      snoop_val_offset = ex6_illeg_instr_offset + 2;  
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
      wire                           tlb_early_act;
      wire                           tlb_tag0_act;
      wire                           tlb_snoop_act;
      
      (* analysis_not_referenced="true" *)  
      wire [0:36]                    unused_dc;
      (* analysis_not_referenced="true" *)  
      wire [`MM_THREADS:`THDID_WIDTH-1]         unused_dc_thdid;
      
      wire [0:(`MM_THREADS*11)-1]     tri_regk_unused_scan;


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
      

      assign tidn = 1'b0;
      assign tiup = 1'b1;
      
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
      assign tlb_ctl_ex3_hv_state = (~ex3_state_q[0]) & (~ex3_state_q[1]);
      
      assign ex4_valid_d = ex3_valid_q & (~(xu_ex3_flush));
      assign ex4_flush_d = (|(ex3_ttype_q) == 1'b1) ? ((ex3_valid_q & xu_ex3_flush) | ex3_flush_q) : 
                           {`MM_THREADS{1'b0}};
      assign ex4_ttype_d = ex3_ttype_q;
      assign ex4_state_d = ex3_state_q;
      assign ex4_pid_d = ex3_pid_q;
      
      assign ex5_valid_d = ex4_valid_q & (~(xu_ex4_flush));
      assign ex5_flush_d = (|(ex4_ttype_q) == 1'b1) ? ((ex4_valid_q & xu_ex4_flush) | ex4_flush_q) : 
                           {`MM_THREADS{1'b0}};
      assign ex5_ttype_d = ex4_ttype_q;
      assign ex5_state_d = ex4_state_q;
      assign ex5_pid_d = ex4_pid_q;
      
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
      assign tlb_set_resv0 = ((ex6_valid_q[0] == 1'b1 & ex6_ttype_q[4] == 1'b1 & tlb_seq_set_resv == 1'b1)) ? 1'b1 : 
                             1'b0;
`ifdef MM_THREADS2                             
      assign tlb_set_resv1 = ((ex6_valid_q[1] == 1'b1 & ex6_ttype_q[4] == 1'b1 & tlb_seq_set_resv == 1'b1)) ? 1'b1 : 
                             1'b0;
`endif
                             
      assign tlb_clr_resv_d[0] = 
                                    ( tlb_seq_snoop_resv_q[0] & (tlb_tag1_q[`tagpos_is:`tagpos_is + 3] == 4'b0011) & tlb_resv0_tag1_lpid_match & 
                                      tlb_resv0_tag1_pid_match & tlb_resv0_tag1_gs_snoop_match & tlb_resv0_tag1_as_snoop_match & tlb_resv0_tag1_epn_glob_match ) | 
                                    ( tlb_seq_snoop_resv_q[0] & (tlb_tag1_q[`tagpos_is:`tagpos_is + 3] == 4'b1000) & tlb_resv0_tag1_lpid_match ) | 
                                    ( tlb_seq_snoop_resv_q[0] & (tlb_tag1_q[`tagpos_is:`tagpos_is + 3] == 4'b1001) & tlb_resv0_tag1_lpid_match & tlb_resv0_tag1_pid_match ) | 
                                    ( tlb_seq_snoop_resv_q[0] & (tlb_tag1_q[`tagpos_is:`tagpos_is + 3] == 4'b1011) & tlb_resv0_tag1_lpid_match & 
                                      tlb_resv0_tag1_pid_match & tlb_resv0_tag1_gs_snoop_match & tlb_resv0_tag1_as_snoop_match & tlb_resv0_tag1_epn_loc_match ) | 
                                    ( ((|(ex6_valid_q & tlb_resv_valid_vec) & (tlb_tag4_wq == 2'b01)) | (|(ex6_valid_q) & (tlb_tag4_wq == 2'b00))) & 
                                           ex6_ttype_q[1] & tlb_resv0_tag1_gs_tlbwe_match & tlb_resv0_tag1_as_tlbwe_match & tlb_resv0_tag1_lpid_match & tlb_resv0_tag1_pid_match & 
                                           tlb_resv0_tag1_epn_loc_match & tlb_resv0_tag1_ind_match ) | 
                                    ( ex6_valid_q[0] & ex6_ttype_q[1] & (tlb_tag4_wq == 2'b10) ) | 
                                    ( tlb_tag4_ptereload & tlb_resv0_tag1_gs_snoop_match & tlb_resv0_tag1_as_snoop_match & tlb_resv0_tag1_lpid_match & tlb_resv0_tag1_pid_match & tlb_resv0_tag1_epn_loc_match & tlb_resv0_tag1_ind_match ) | 
                                    ( ((|(ex6_valid_q) & (tlb_tag4_wq == 2'b10)) | (|(ex6_valid_q) & (tlb_tag4_wq == 2'b11))) & 
                                           ex6_ttype_q[1] & tlb_resv0_tag1_gs_tlbwe_match & tlb_resv0_tag1_as_tlbwe_match & tlb_resv0_tag1_lpid_match & tlb_resv0_tag1_pid_match & tlb_resv0_tag1_epn_loc_match & tlb_resv0_tag1_ind_match ) | 
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
      assign tlb_resv0_tag0_lpid_match = ((tlb_tag0_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] == tlb_resv0_lpid_q)) ? 1'b1 : 
                                         1'b0;
      assign tlb_resv0_tag0_pid_match = ((tlb_tag0_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1] == tlb_resv0_pid_q)) ? 1'b1 : 
                                        1'b0;
      assign tlb_resv0_tag0_gs_snoop_match = ((tlb_tag0_q[`tagpos_gs] == tlb_resv0_gs_q)) ? 1'b1 : 
                                             1'b0;
      assign tlb_resv0_tag0_as_snoop_match = ((tlb_tag0_q[`tagpos_as] == tlb_resv0_as_q)) ? 1'b1 : 
                                             1'b0;
      assign tlb_resv0_tag0_gs_tlbwe_match = ((tlb_tag0_q[`tagpos_pt] == tlb_resv0_gs_q)) ? 1'b1 : 
                                             1'b0;
      assign tlb_resv0_tag0_as_tlbwe_match = ((tlb_tag0_q[`tagpos_recform] == tlb_resv0_as_q)) ? 1'b1 : 
                                             1'b0;
      assign tlb_resv0_tag0_ind_match = ((tlb_tag0_q[`tagpos_ind] == tlb_resv0_ind_q)) ? 1'b1 : 
                                        1'b0;
      assign tlb_resv0_tag0_class_match = ((tlb_tag0_q[`tagpos_class:`tagpos_class + 1] == tlb_resv0_class_q)) ? 1'b1 : 
                                          1'b0;
      assign tlb_resv0_tag0_epn_loc_match = ((tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] == tlb_resv0_epn_q[52 - `EPN_WIDTH:51] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 5] == tlb_resv0_epn_q[52 - `EPN_WIDTH:47] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 9] == tlb_resv0_epn_q[52 - `EPN_WIDTH:43] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 13] == tlb_resv0_epn_q[52 - `EPN_WIDTH:39] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 17] == tlb_resv0_epn_q[52 - `EPN_WIDTH:35] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 19] == tlb_resv0_epn_q[52 - `EPN_WIDTH:33] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 : 
                                            1'b0;
      assign tlb_resv0_tag0_epn_glob_match = ((tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 1] == tlb_resv0_epn_q[52 - `EPN_WIDTH + 31:51] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 5] == tlb_resv0_epn_q[52 - `EPN_WIDTH + 31:47] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 9] == tlb_resv0_epn_q[52 - `EPN_WIDTH + 31:43] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 13] == tlb_resv0_epn_q[52 - `EPN_WIDTH + 31:39] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 17] == tlb_resv0_epn_q[52 - `EPN_WIDTH + 31:35] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 19] == tlb_resv0_epn_q[52 - `EPN_WIDTH + 31:33] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 : 
                                             1'b0;
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
      assign tlb_resv1_tag0_epn_loc_match = ((tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 1] == tlb_resv1_epn_q[52 - `EPN_WIDTH:51] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 5] == tlb_resv1_epn_q[52 - `EPN_WIDTH:47] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 9] == tlb_resv1_epn_q[52 - `EPN_WIDTH:43] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 13] == tlb_resv1_epn_q[52 - `EPN_WIDTH:39] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 17] == tlb_resv1_epn_q[52 - `EPN_WIDTH:35] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) | (tlb_tag0_q[`tagpos_epn:`tagpos_epn + `EPN_WIDTH - 19] == tlb_resv1_epn_q[52 - `EPN_WIDTH:33] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 : 
                                            1'b0;
      assign tlb_resv1_tag0_epn_glob_match = ((tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 1] == tlb_resv1_epn_q[52 - `EPN_WIDTH + 31:51] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_4KB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 5] == tlb_resv1_epn_q[52 - `EPN_WIDTH + 31:47] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_64KB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 9] == tlb_resv1_epn_q[52 - `EPN_WIDTH + 31:43] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1MB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 13] == tlb_resv1_epn_q[52 - `EPN_WIDTH + 31:39] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_16MB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 17] == tlb_resv1_epn_q[52 - `EPN_WIDTH + 31:35] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_256MB) | (tlb_tag0_q[`tagpos_epn + 31:`tagpos_epn + `EPN_WIDTH - 19] == tlb_resv1_epn_q[52 - `EPN_WIDTH + 31:33] & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] == TLB_PgSize_1GB)) ? 1'b1 : 
                                             1'b0;
      assign tlb_resv_match_vec_d[1] = (tlb_resv1_valid_q & tlb_tag0_q[`tagpos_type_snoop] == 1'b1 & tlb_resv1_tag0_epn_loc_match & tlb_resv1_tag0_lpid_match & tlb_resv1_tag0_pid_match & tlb_resv1_tag0_as_snoop_match & tlb_resv1_tag0_gs_snoop_match) | (tlb_resv1_valid_q & tlb_tag0_q[`tagpos_type_tlbwe] == 1'b1 & tlb_resv1_tag0_epn_loc_match & tlb_resv1_tag0_lpid_match & tlb_resv1_tag0_pid_match & tlb_resv1_tag0_as_tlbwe_match & tlb_resv1_tag0_gs_tlbwe_match & tlb_resv1_tag0_ind_match) | (tlb_resv1_valid_q & tlb_tag0_q[`tagpos_type_ptereload] == 1'b1 & tlb_resv1_tag0_epn_loc_match & tlb_resv1_tag0_lpid_match & tlb_resv1_tag0_pid_match & tlb_resv1_tag0_as_snoop_match & tlb_resv1_tag0_gs_snoop_match & tlb_resv1_tag0_ind_match);
`endif

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
      assign tlb_tag0_tid_notzero = |(tlb_tag0_q[`tagpos_pid:`tagpos_pid + `PID_WIDTH - 1]);
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
      
      assign tlb_seq_abort = |( tlb_tag0_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS -1] & (tlb_ctl_tag1_flush_sig | tlb_ctl_tag2_flush_sig | tlb_ctl_tag3_flush_sig | tlb_ctl_tag4_flush_sig) );
      
      assign tlb_seq_d = tlb_seq_next & {`TLB_SEQ_WIDTH{(~(tlb_seq_abort))}};
      
      
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
            TlbSeq_Idle :
               if (snoop_val_q[0] == 1'b1)
               begin
                  tlb_seq_next <= TlbSeq_Stg24;
                  snoop_req_taken_sig <= 1'b1;
                  tlb_seq_snoop_inprogress <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else if (ptereload_req_valid == 1'b1)
               begin
                  tlb_seq_next <= TlbSeq_Stg19;
                  ptereload_req_taken_sig <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else if (tlb_seq_ierat_req == 1'b1 & tlb_cmp_erat_dup_wait[0] == 1'b0 & tlb_cmp_erat_dup_wait[1] == 1'b0 & (derat_taken_q == 1'b1 | tlb_seq_derat_req == 1'b0))
               begin
                  tlb_seq_next <= TlbSeq_Stg1;
                  ierat_req_taken_sig <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else if (tlb_seq_derat_req == 1'b1 & tlb_cmp_erat_dup_wait[0] == 1'b0 & tlb_cmp_erat_dup_wait[1] == 1'b0)
               begin
                  tlb_seq_next <= TlbSeq_Stg1;
                  derat_req_taken_sig <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else if (tlb_search_req == 1'b1)
               begin
                  tlb_seq_next <= TlbSeq_Stg1;
                  search_req_taken_sig <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else if (tlb_searchresv_req == 1'b1)
               begin
                  tlb_seq_next <= TlbSeq_Stg1;
                  searchresv_req_taken_sig <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else if (tlb_write_req == 1'b1 & tlbwe_back_inv_holdoff == 1'b0)
               begin
                  tlb_seq_next <= TlbSeq_Stg19;
                  write_req_taken_sig <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else if (tlb_read_req == 1'b1)
               begin
                  tlb_seq_next <= TlbSeq_Stg19;
                  read_req_taken_sig <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
               end
               else
                  tlb_seq_next <= TlbSeq_Idle;
                  
            TlbSeq_Stg1 :
               begin
                  tlb_seq_tag0_addr_cap <= 1'b1;
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_addr1;  
                  tlb_seq_pgsize <= mmucr2[28:31];
                  tlb_seq_is <= 2'b00;      
                  tlb_seq_esel <= 3'b001;   
                  tlb_seq_lru_rd_act <= 1'b1;
                  if (pgsize2_valid == 1'b1)
                     tlb_seq_next <= TlbSeq_Stg2;
                  else
                     tlb_seq_next <= TlbSeq_Stg6;
               end
            
            TlbSeq_Stg2 :
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_addr2;  
                  tlb_seq_pgsize <= mmucr2[24:27];
                  tlb_seq_is <= 2'b00;      
                  tlb_seq_esel <= 3'b010;   
                  tlb_seq_lru_rd_act <= 1'b1;
                  if (pgsize3_valid == 1'b1)
                     tlb_seq_next <= TlbSeq_Stg3;
                  else
                     tlb_seq_next <= TlbSeq_Stg6;
               end
            
            TlbSeq_Stg3 :
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_addr3;  
                  tlb_seq_pgsize <= mmucr2[20:23];
                  tlb_seq_is <= 2'b00;      
                  tlb_seq_esel <= 3'b011;   
                  tlb_seq_lru_rd_act <= 1'b1;
                  if (pgsize4_valid == 1'b1)
                     tlb_seq_next <= TlbSeq_Stg4;
                  else
                     tlb_seq_next <= TlbSeq_Stg6;
               end
            
            TlbSeq_Stg4 :
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_addr4;  
                  tlb_seq_pgsize <= mmucr2[16:19];
                  tlb_seq_is <= 2'b00;      
                  tlb_seq_esel <= 3'b100;   
                  tlb_seq_lru_rd_act <= 1'b1;
                  if (pgsize5_valid == 1'b1)
                     tlb_seq_next <= TlbSeq_Stg5;
                  else
                     tlb_seq_next <= TlbSeq_Stg6;
               end
            
            TlbSeq_Stg5 :
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_addr5;  
                  tlb_seq_pgsize <= mmucr2[12:15];
                  tlb_seq_is <= 2'b00;      
                  tlb_seq_esel <= 3'b101;   
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
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_tid0_addr1;  
                  tlb_seq_pgsize <= mmucr2[28:31];
                  tlb_seq_is <= 2'b01;      
                  tlb_seq_esel <= 3'b001;   
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
                  else if (pgsize2_tid0_valid == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg7;  
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else if (tlb0cfg_ind == 1'b1 & tlb_tag0_q[`tagpos_nonspec] == 1'b1)  
                    begin
                     tlb_seq_next <= TlbSeq_Stg11;  
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else
                  begin
                     tlb_seq_endflag <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg15;  
                     tlb_seq_lru_rd_act <= 1'b1;
                  end
               end
            
            TlbSeq_Stg7 :
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_tid0_addr2;  
                  tlb_seq_pgsize <= mmucr2[24:27];
                  tlb_seq_is <= 2'b01;      
                  tlb_seq_esel <= 3'b010;   
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
                  else if (pgsize3_tid0_valid == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg8;  
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else if (tlb0cfg_ind == 1'b1 & tlb_tag0_q[`tagpos_nonspec] == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg11;  
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else
                  begin
                     tlb_seq_endflag <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg15;  
                     tlb_seq_lru_rd_act <= 1'b1;
                  end
               end
            
            TlbSeq_Stg8 :
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_tid0_addr3;  
                  tlb_seq_pgsize <= mmucr2[20:23];
                  tlb_seq_is <= 2'b01;      
                  tlb_seq_esel <= 3'b011;   
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
                  else if (pgsize4_tid0_valid == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg9;  
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else if (tlb0cfg_ind == 1'b1 & tlb_tag0_q[`tagpos_nonspec] == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg11;  
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else
                  begin
                     tlb_seq_endflag <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg15;  
                     tlb_seq_lru_rd_act <= 1'b1;
                  end
               end
            
            TlbSeq_Stg9 :
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_tid0_addr4;  
                  tlb_seq_pgsize <= mmucr2[16:19];
                  tlb_seq_is <= 2'b01;      
                  tlb_seq_esel <= 3'b100;   
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
                  else if (pgsize5_tid0_valid == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg10;  
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else if (tlb0cfg_ind == 1'b1 & tlb_tag0_q[`tagpos_nonspec] == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg11;  
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
                  else
                   begin
                     tlb_seq_endflag <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg15;  
                     tlb_seq_lru_rd_act <= 1'b1;
                   end
               end
            
            TlbSeq_Stg10 :
               begin
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= tlb_hashed_tid0_addr5;  
                  tlb_seq_pgsize <= mmucr2[12:15];
                  tlb_seq_is <= 2'b01;      
                  tlb_seq_esel <= 3'b101;   
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
                  else if (tlb0cfg_ind == 1'b1 & tlb_tag0_q[`tagpos_nonspec] == 1'b1)
                   begin
                     tlb_seq_next <= TlbSeq_Stg11;  
                     tlb_seq_lru_rd_act <= 1'b1;
                   end
                  else
                   begin
                     tlb_seq_endflag <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg15;  
                     tlb_seq_lru_rd_act <= 1'b1;
                   end
               end
            
            TlbSeq_Stg11 :
               begin
                  tlb_seq_ind <= 1'b1;
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= size_1M_hashed_addr;
                  tlb_seq_pgsize <= TLB_PgSize_1MB;
                  tlb_seq_is <= 2'b10;      
                  tlb_seq_esel <= 3'b001;   
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
                     tlb_seq_next <= TlbSeq_Stg12;  
                     tlb_seq_lru_rd_act <= 1'b1;
                   end
               end
            
            TlbSeq_Stg12 :
               begin
                  tlb_seq_ind <= 1'b1;
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= size_256M_hashed_addr;
                  tlb_seq_pgsize <= TLB_PgSize_256MB;
                  tlb_seq_is <= 2'b10;      
                  tlb_seq_esel <= 3'b010;   
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
                     tlb_seq_next <= TlbSeq_Stg13;  
                     tlb_seq_lru_rd_act <= 1'b1;
                   end
               end
            
            TlbSeq_Stg13 :
               begin
                  tlb_seq_ind <= 1'b1;
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= size_1M_hashed_tid0_addr;
                  tlb_seq_pgsize <= TLB_PgSize_1MB;
                  tlb_seq_is <= 2'b11;      
                  tlb_seq_esel <= 3'b001;   
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
                     tlb_seq_next <= TlbSeq_Stg14;  
                     tlb_seq_lru_rd_act <= 1'b1;
                   end
               end
            
            TlbSeq_Stg14 :
               begin
                  tlb_seq_ind <= 1'b1;
                  tlb_seq_addr_update <= 1'b1;
                  tlb_seq_addr <= size_256M_hashed_tid0_addr;
                  tlb_seq_pgsize <= TLB_PgSize_256MB;
                  tlb_seq_is <= 2'b11;      
                  tlb_seq_esel <= 3'b010;   
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
                     tlb_seq_endflag <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg15;
                     tlb_seq_lru_rd_act <= 1'b1;
                   end
               end
            
            TlbSeq_Stg15 :
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
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
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b1 & |(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_ierat]) == 1'b1 & tlb_tag0_q[`tagpos_type_ptereload] == 1'b0)
                    begin
                     tlb_seq_next <= TlbSeq_Stg29;  
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else
                    begin
                     tlb_seq_next <= TlbSeq_Stg16;  
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
               end
            
            TlbSeq_Stg16 :
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
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
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg29;  
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else
                    begin
                     tlb_seq_next <= TlbSeq_Stg17;  
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
               end
            
            TlbSeq_Stg17 :
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
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
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg29;  
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else
                    begin
                     tlb_seq_next <= TlbSeq_Stg18;  
                     tlb_seq_lru_rd_act <= 1'b1;
                    end
               end
            
            TlbSeq_Stg18 :
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
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
                  else if (tlb_tag4_hit_or_parerr == 1'b1 & tlb_tag4_way_ind == 1'b1)
                    begin
                     tlb_seq_next <= TlbSeq_Stg29;  
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                    end
                  else
                    begin
                     tlb_seq_next <= TlbSeq_Stg30;  
                     tlb_seq_lru_rd_act <= 1'b0;
                    end
               end
            
            TlbSeq_Stg19 :
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
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_lru_rd_act <= 1'b1;
                  tlb_seq_next <= TlbSeq_Stg21;
               end
            
            TlbSeq_Stg21 :
               begin
                  tlb_seq_lrat_enable <= tlb_tag0_q[`tagpos_type_tlbwe] | tlb_tag0_q[`tagpos_type_ptereload];
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_lru_rd_act <= 1'b1;
                  tlb_seq_next <= TlbSeq_Stg22;
               end
            
            TlbSeq_Stg22 :
               begin
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_lru_rd_act <= 1'b1;
                  tlb_seq_next <= TlbSeq_Stg23;
               end
            
            TlbSeq_Stg23 :
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
                     tlb_seq_next <= TlbSeq_Idle;  
                    end
                  else
                    begin
                     tlb_seq_lru_rd_act <= 1'b0;
                     tlb_seq_lru_wr_act <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg31; 
                    end
               end
            
            TlbSeq_Stg24 :
               begin
                  tlb_seq_snoop_inprogress <= 1'b1;
                  tlb_seq_pgsize <= tlb_tag0_q[`tagpos_size:`tagpos_size + 3];
                  tlb_seq_tag0_addr_cap <= 1'b1;
                  tlb_seq_snoop_resv <= 1'b1;
                  tlb_seq_lru_rd_act <= 1'b1;
                  tlb_seq_lru_wr_act <= 1'b0;
                  if (tlb_tag0_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011) 
                   begin
                     tlb_seq_addr_update <= 1'b1;
                     tlb_seq_addr_clr <= 1'b0;  
                     tlb_seq_endflag <= 1'b1;   
                   end
                  else
                   begin
                     tlb_seq_addr_update <= 1'b0;
                     tlb_seq_addr_clr <= 1'b1;  
                     tlb_seq_endflag <= 1'b0;   
                   end
                  if (tlb_tag0_tid_notzero == 1'b1)
                     tlb_seq_addr <= tlb_tag0_hashed_addr;
                  else
                     tlb_seq_addr <= tlb_tag0_hashed_tid0_addr;
                  tlb_seq_next <= TlbSeq_Stg25;
               end
            
            TlbSeq_Stg25 :
               begin
                  tlb_seq_snoop_inprogress <= 1'b1;
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  if (tlb_tag0_q[`tagpos_is + 1:`tagpos_is + 3] == 3'b011)
                   begin
                     tlb_seq_addr_incr <= 1'b0;
                     tlb_seq_endflag <= 1'b0;
                   end
                  else
                   begin
                     tlb_seq_addr_incr <= 1'b1;  
                     tlb_seq_endflag <= tlb_addr_maxcntm1;
                   end
                  if (tlb_tag0_q[`tagpos_is + 1:`tagpos_is + 3] != 3'b011 & tlb_tag1_q[`tagpos_endflag] == 1'b0)
                   begin
                     tlb_seq_lru_rd_act <= 1'b1;
                     tlb_seq_lru_wr_act <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg25;  
                   end
                  else if (tlb_tag0_q[`tagpos_is + 1:`tagpos_is + 3] != 3'b011 & tlb_tag1_q[`tagpos_endflag] == 1'b1)
                   begin
                     tlb_seq_lru_rd_act <= 1'b1;  
                     tlb_seq_lru_wr_act <= 1'b1;
                     tlb_seq_next <= TlbSeq_Stg26;  
                   end
                  else
                   begin
                     tlb_seq_lru_rd_act <= 1'b1;
                     tlb_seq_lru_wr_act <= 1'b0;
                     tlb_seq_next <= TlbSeq_Stg26;  
                   end
               end
            
            TlbSeq_Stg26 :
               begin
                  tlb_seq_snoop_inprogress <= 1'b1;
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_lru_rd_act <= 1'b0;
                  tlb_seq_lru_wr_act <= 1'b1;
                  tlb_seq_next <= TlbSeq_Stg27;
               end
            
            TlbSeq_Stg27 :
               begin
                  tlb_seq_snoop_inprogress <= 1'b1;
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_lru_rd_act <= 1'b0;
                  tlb_seq_lru_wr_act <= 1'b1;
                  tlb_seq_next <= TlbSeq_Stg28;
               end
            
            TlbSeq_Stg28 :
               begin
                  tlb_seq_snoop_inprogress <= 1'b1;
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_lru_rd_act <= 1'b0;
                  tlb_seq_lru_wr_act <= 1'b1;
                  tlb_seq_next <= TlbSeq_Stg31;  
               end
               
            TlbSeq_Stg29 :
               begin
                  tlb_seq_derat_done_sig <= tlb_tag0_q[`tagpos_type_derat] & (~tlb_tag0_q[`tagpos_type_ptereload]);
                  tlb_seq_ierat_done_sig <= tlb_tag0_q[`tagpos_type_ierat] & (~tlb_tag0_q[`tagpos_type_ptereload]);
                  tlb_seq_addr <= {`TLB_ADDR_WIDTH{1'b0}};
                  tlb_seq_pgsize <= {4{1'b0}};
                  tlb_seq_lru_wr_act <= 1'b1;
                  tlb_seq_next <= TlbSeq_Idle;   
               end
            
            TlbSeq_Stg30 :
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
      assign snoop_val_d[0] = (snoop_val_q[0] == 1'b0) ? tlb_snoop_val : 
                              (snoop_req_taken_sig == 1'b1) ? 1'b0 : 
                              snoop_val_q[0];
      assign snoop_val_d[1] = tlb_seq_snoop_done_sig;
      assign tlb_snoop_ack = snoop_val_q[1];
      assign snoop_attr_d = (snoop_val_q[0] == 1'b0) ? tlb_snoop_attr : 
                            snoop_attr_q;
      assign snoop_vpn_d[52 - `EPN_WIDTH:51] = (snoop_val_q[0] == 1'b0) ? tlb_snoop_vpn : 
                                              snoop_vpn_q[52 - `EPN_WIDTH:51];
      assign ptereload_req_pte_d = (ptereload_req_taken_sig == 1'b1) ? ptereload_req_pte : 
                                   ptereload_req_pte_q;
      assign ptereload_req_pte_lat = ptereload_req_pte_q;
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

      assign tlb_tag0_d[`tagpos_is:`tagpos_is + 1] = 
                   ( ({ptereload_req_pte[`ptepos_valid], ptereload_req_tag[`tagpos_is + 1]}) & {2{ptereload_req_taken_sig}} ) | 
                   ( ({ex1_mas1_v, ex1_mas1_iprot}) & {2{write_req_taken_sig}} ) | 
                   ( snoop_attr_q[0:1] & {2{snoop_req_taken_sig}} ) | 
                   ( tlb_tag0_q[`tagpos_is:`tagpos_is + 1] & {2{(~any_req_taken_sig)}} );

      assign tlb_tag0_d[`tagpos_class:`tagpos_class + `CLASS_WIDTH - 1] = 
                  ( ptereload_req_tag[`tagpos_class:`tagpos_class + `CLASS_WIDTH - 1] & {`CLASS_WIDTH{ptereload_req_taken_sig}} ) | 
                  ( ex1_mmucr3_class & {`CLASS_WIDTH{write_req_taken_sig}} ) | 
                  ( snoop_attr_q[2:3] & {`CLASS_WIDTH{snoop_req_taken_sig}} ) | 
                  ( derat_req_ttype & {`CLASS_WIDTH{derat_req_taken_sig}} ) | 
                  ( tlb_tag0_q[`tagpos_class:`tagpos_class + 1] & {`CLASS_WIDTH{(~any_req_taken_sig)}} );

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
    
      assign tlb_tag0_d[`tagpos_ind] = 
                  ( ex1_mas1_ind & write_req_taken_sig ) | 
                  ( ex1_mas1_ind & read_req_taken_sig ) | 
                  ( snoop_attr_q[34] & snoop_req_taken_sig ) | 
                  ( ex2_mas1_ind & searchresv_req_taken_sig ) | 
                  ( ex2_mas6_sind & search_req_taken_sig ) | 
                  ( tlb_tag0_q[`tagpos_ind] & (~any_req_taken_sig) );

      assign tlb_tag0_d[`tagpos_atsel] = 
              ( ptereload_req_tag[`tagpos_atsel] & ptereload_req_taken_sig ) | 
              ( ex1_mas0_atsel & write_req_taken_sig ) | 
              ( ex1_mas0_atsel & read_req_taken_sig ) | 
              ( ex2_mas0_atsel & searchresv_req_taken_sig ) | 
              ( ex2_mas0_atsel & search_req_taken_sig ) | 
              ( tlb_tag0_q[`tagpos_atsel] & (~any_req_taken_sig) );

      assign tlb_tag0_d[`tagpos_esel:`tagpos_esel + 2] = 
                  ( ptereload_req_tag[`tagpos_esel:`tagpos_esel + 2] & {3{ptereload_req_taken_sig}} ) | 
                  ( ex1_mas0_esel & {3{write_req_taken_sig}} ) | 
                  ( ex1_mas0_esel & {3{read_req_taken_sig}} ) | 
                  ( ex2_mas0_esel & {3{searchresv_req_taken_sig}} ) | 
                  ( ex2_mas0_esel & {3{search_req_taken_sig}} ) | 
                  ( tlb_tag0_q[`tagpos_esel:`tagpos_esel + 2] & {3{(~any_req_taken_sig)}} );

      assign tlb_tag0_d[`tagpos_hes] = 
                  ( ptereload_req_tag[`tagpos_hes] & ptereload_req_taken_sig ) | 
                  ( ex1_mas0_hes & write_req_taken_sig ) | 
                  ( ex1_mas0_hes & read_req_taken_sig ) | 
                  ( snoop_attr_q[19] & snoop_req_taken_sig ) | 
                  ( ex2_mas0_hes & searchresv_req_taken_sig ) | 
                  ( ex2_mas0_hes & search_req_taken_sig ) | 
                  ( ierat_req_taken_sig) | (derat_req_taken_sig ) | 
                  ( tlb_tag0_q[`tagpos_hes] & (~any_req_taken_sig) );

      assign tlb_tag0_d[`tagpos_wq:`tagpos_wq + 1] = 
                  ( ptereload_req_tag[`tagpos_wq:`tagpos_wq + 1] & {2{ptereload_req_taken_sig}} ) | 
                  ( ex1_mas0_wq & {2{write_req_taken_sig}} ) | 
                  ( ex1_mas0_wq & {2{read_req_taken_sig}} ) | 
                  ( ex2_mas0_wq & {2{searchresv_req_taken_sig}} ) | 
                  ( ex2_mas0_wq & {2{search_req_taken_sig}} ) | 
                  ( ierat_req_dup & {2{ierat_req_taken_sig}} ) | 
                  ( derat_req_dup & {2{derat_req_taken_sig}} ) | 
                  ( tlb_tag0_q[`tagpos_wq:`tagpos_wq + 1] & {2{(~any_req_taken_sig)}} );

      assign tlb_tag0_d[`tagpos_lrat] = 
                  ( ptereload_req_tag[`tagpos_lrat] & ptereload_req_taken_sig ) | 
                  ( mmucfg_lrat & write_req_taken_sig ) | 
                  ( mmucfg_lrat & read_req_taken_sig ) | 
                  ( mmucfg_lrat & searchresv_req_taken_sig ) | 
                  ( mmucfg_lrat & search_req_taken_sig ) | 
                  ( mmucfg_lrat & ierat_req_taken_sig ) | 
                  ( mmucfg_lrat & derat_req_taken_sig ) | 
                  ( tlb_tag0_q[`tagpos_lrat] & (~any_req_taken_sig) );

      assign tlb_tag0_d[`tagpos_pt] = 
                  ( ptereload_req_tag[`tagpos_pt] & ptereload_req_taken_sig ) | 
                  ( ex1_mas8_tgs & write_req_taken_sig ) | 
                  ( tlb0cfg_pt & read_req_taken_sig ) | 
                  ( tlb0cfg_pt & searchresv_req_taken_sig ) | 
                  ( tlb0cfg_pt & search_req_taken_sig ) | 
                  ( tlb0cfg_pt & ierat_req_taken_sig ) | 
                  ( tlb0cfg_pt & derat_req_taken_sig ) | 
                  ( tlb_tag0_q[`tagpos_pt] & (~any_req_taken_sig ) );

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
      
      assign tlb_tag1_d[`tagpos_ind] = ( |(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_ierat]) & tlb_seq_ind ) | 
                                         ( (~|(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_ierat])) & tlb_tag0_q[`tagpos_ind] );

      assign tlb_tag1_d[`tagpos_esel:`tagpos_esel + 2] = ( {3{|(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag0_q[`tagpos_type_ptereload])}} & tlb_seq_esel ) | 
                                                           ( {3{tlb_tag0_q[`tagpos_type_ptereload] | (~|(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_tlbsrx]))}} & tlb_tag0_q[`tagpos_esel:`tagpos_esel + 2]);

      assign tlb_tag1_d[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1] = tlb_tag0_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1];

      assign tlb_tag1_d[`tagpos_atsel] = tlb_tag0_q[`tagpos_atsel];

      assign tlb_tag1_d[`tagpos_hes] = tlb_tag0_q[`tagpos_hes];

      assign tlb_tag1_d[`tagpos_wq:`tagpos_wq + 1] = tlb_tag0_q[`tagpos_wq:`tagpos_wq + 1];

      assign tlb_tag1_d[`tagpos_lrat] = tlb_tag0_q[`tagpos_lrat];

      assign tlb_tag1_d[`tagpos_pt] = tlb_tag0_q[`tagpos_pt];

      assign tlb_tag1_d[`tagpos_recform] = tlb_tag0_q[`tagpos_recform];

      assign tlb_tag1_d[`tagpos_size:`tagpos_size + 3] = 
                  ( {4{|(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_tlbsrx]) & (~tlb_tag0_q[`tagpos_type_ptereload])}} & tlb_seq_pgsize ) | 
                  ( {4{tlb_tag0_q[`tagpos_type_ptereload] | (~|(tlb_tag0_q[`tagpos_type_derat:`tagpos_type_tlbsrx]))}} & tlb_tag0_q[`tagpos_size:`tagpos_size + 3] );

      assign tlb_tag1_d[`tagpos_type:`tagpos_type + 7] = 
                  ( (tlb_seq_ierat_done_sig == 1'b1 | tlb_seq_derat_done_sig == 1'b1 | tlb_seq_snoop_done_sig == 1'b1 | 
                     tlb_seq_search_done_sig == 1'b1 | tlb_seq_searchresv_done_sig == 1'b1 | tlb_seq_read_done_sig == 1'b1 | tlb_seq_write_done_sig == 1'b1 | 
                     tlb_seq_ptereload_done_sig == 1'b1 | tlb_seq_abort == 1'b1) ) ? 8'b00000000 : 
                 tlb_tag0_q[`tagpos_type:`tagpos_type + 7];
                 
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
      assign tlb_tag2 = tlb_tag2_q;
      assign tlb_addr2 = tlb_addr2_q;
                           
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
                           

      assign tlb_write = tlb_write_q & {`TLB_WAYS{tlb_tag5_parerr_zeroize | (~|(tlb_tag5_except))}};
      
      assign tlb_tag5_write = |(tlb_write_q) & (~|(tlb_tag5_except));
      
      assign ex3_valid_32b = |(ex3_valid_q & (~(xu_mm_msr_cm)));
      assign tlb_ctl_ex2_flush_req = ((ex2_ttype_q[2:4] != 3'b000 & search_req_taken_sig == 1'b0 & searchresv_req_taken_sig == 1'b0)) ? (ex2_valid_q & (~(xu_ex2_flush))) : 
                                     ((|(ex2_flush_req_q) == 1'b1)) ? (ex2_valid_q & (~(xu_ex2_flush))) : 
                                     {`MM_THREADS{1'b0}};
      assign tlb_ctl_ex2_itag = ex2_itag_q;
      
      assign mas1_tsize_direct[0] = ((mas1_0_tsize == TLB_PgSize_4KB) |  (mas1_0_tsize == TLB_PgSize_64KB) | (mas1_0_tsize == TLB_PgSize_1MB) | 
                                       (mas1_0_tsize == TLB_PgSize_16MB) | (mas1_0_tsize == TLB_PgSize_1GB));

      assign mas1_tsize_indirect[0] = ((mas1_0_tsize == TLB_PgSize_1MB) | (mas1_0_tsize == TLB_PgSize_256MB));

      assign mas1_tsize_lrat[0] = ((mas1_0_tsize == LRAT_PgSize_1MB) | (mas1_0_tsize == LRAT_PgSize_16MB) | (mas1_0_tsize == LRAT_PgSize_256MB) | 
                                     (mas1_0_tsize == LRAT_PgSize_1GB) | (mas1_0_tsize == LRAT_PgSize_4GB) | (mas1_0_tsize == LRAT_PgSize_16GB) | 
                                     (mas1_0_tsize == LRAT_PgSize_256GB) | (mas1_0_tsize == LRAT_PgSize_1TB));

      assign ex2_tlbre_mas1_tsize_not_supp[0] = ((mas1_tsize_direct[0] == 1'b0 & (mas1_0_ind == 1'b0 | tlb0cfg_ind == 1'b0) & (mas0_0_atsel == 1'b0 | ex2_state_q[1] == 1'b1)) | (mas1_tsize_indirect[0] == 1'b0 & mas1_0_ind == 1'b1 & tlb0cfg_ind == 1'b1 & (mas0_0_atsel == 1'b0 | ex2_state_q[1] == 1'b1))) ? 1'b1 : 
                                                1'b0;
                                                
      assign ex5_tlbre_mas1_tsize_not_supp[0] = ((mas1_tsize_direct[0] == 1'b0 & (mas1_0_ind == 1'b0 | tlb0cfg_ind == 1'b0) & (mas0_0_atsel == 1'b0 | ex5_state_q[1] == 1'b1)) | (mas1_tsize_indirect[0] == 1'b0 & mas1_0_ind == 1'b1 & tlb0cfg_ind == 1'b1 & (mas0_0_atsel == 1'b0 | ex5_state_q[1] == 1'b1))) ? 1'b1 : 
                                                1'b0;
                                                
      assign ex5_tlbwe_mas1_tsize_not_supp[0] = ((mas1_tsize_direct[0] == 1'b0 & (mas1_0_ind == 1'b0 | tlb0cfg_ind == 1'b0) & mas0_0_wq != 2'b10 & (mas0_0_atsel == 1'b0 | ex5_state_q[1] == 1'b1)) | (mas1_tsize_indirect[0] == 1'b0 & mas1_0_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_0_wq != 2'b10 & (mas0_0_atsel == 1'b0 | ex5_state_q[1] == 1'b1)) | (mas1_tsize_lrat[0] == 1'b0 & mas0_0_atsel == 1'b1 & (mas0_0_wq == 2'b00 | mas0_0_wq == 2'b11) & ex5_state_q[1] == 1'b0)) ? 1'b1 : 
                                                1'b0;
                                                
      assign ex6_tlbwe_mas1_tsize_not_supp[0] = ((mas1_tsize_direct[0] == 1'b0 & (mas1_0_ind == 1'b0 | tlb0cfg_ind == 1'b0) & mas0_0_wq != 2'b10 & (mas0_0_atsel == 1'b0 | ex6_state_q[1] == 1'b1)) | (mas1_tsize_indirect[0] == 1'b0 & mas1_0_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_0_wq != 2'b10 & (mas0_0_atsel == 1'b0 | ex6_state_q[1] == 1'b1)) | (mas1_tsize_lrat[0] == 1'b0 & mas0_0_atsel == 1'b1 & (mas0_0_wq == 2'b00 | mas0_0_wq == 2'b11) & ex6_state_q[1] == 1'b0)) ? 1'b1 : 
                                                1'b0;
                                                
      assign ex5_tlbwe_mas0_lrat_bad_selects[0] = (((mas0_0_hes == 1'b1 | mas0_0_wq == 2'b01 | mas0_0_wq == 2'b10) & mas0_0_atsel == 1'b1 & ex5_state_q[1] == 1'b0)) ? 1'b1 : 
                                                  1'b0;
      assign ex6_tlbwe_mas0_lrat_bad_selects[0] = (((mas0_0_hes == 1'b1 | mas0_0_wq == 2'b01 | mas0_0_wq == 2'b10) & mas0_0_atsel == 1'b1 & ex6_state_q[1] == 1'b0)) ? 1'b1 : 
                                                  1'b0;
      assign ex5_tlbwe_mas2_ind_bad_wimge[0] = ((mas1_0_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_0_wq != 2'b10 & (mas2_0_wimge[1] == 1'b1 | mas2_0_wimge[2] == 1'b0 | mas2_0_wimge[3] == 1'b1 | mas2_0_wimge[4] == 1'b1) & (mas0_0_atsel == 1'b0 | ex5_state_q[1] == 1'b1))) ? 1'b1 : 
                                               1'b0;
      assign ex6_tlbwe_mas2_ind_bad_wimge[0] = ((mas1_0_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_0_wq != 2'b10 & (mas2_0_wimge[1] == 1'b1 | mas2_0_wimge[2] == 1'b0 | mas2_0_wimge[3] == 1'b1 | mas2_0_wimge[4] == 1'b1) & (mas0_0_atsel == 1'b0 | ex6_state_q[1] == 1'b1))) ? 1'b1 : 
                                               1'b0;
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
                                                

      assign ex5_tlbwe_mas0_lrat_bad_selects[1] = (((mas0_1_hes == 1'b1 | mas0_1_wq == 2'b01 | mas0_1_wq == 2'b10) & mas0_1_atsel == 1'b1 & ex5_state_q[1] == 1'b0)) ? 1'b1 : 
                                                  1'b0;
      assign ex6_tlbwe_mas0_lrat_bad_selects[1] = (((mas0_1_hes == 1'b1 | mas0_1_wq == 2'b01 | mas0_1_wq == 2'b10) & mas0_1_atsel == 1'b1 & ex6_state_q[1] == 1'b0)) ? 1'b1 : 
                                                  1'b0;
      assign ex5_tlbwe_mas2_ind_bad_wimge[1] = ((mas1_1_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_1_wq != 2'b10 & (mas2_1_wimge[1] == 1'b1 | mas2_1_wimge[2] == 1'b0 | mas2_1_wimge[3] == 1'b1 | mas2_1_wimge[4] == 1'b1) & (mas0_1_atsel == 1'b0 | ex5_state_q[1] == 1'b1))) ? 1'b1 : 
                                               1'b0;
                                               
      assign ex6_tlbwe_mas2_ind_bad_wimge[1] = ((mas1_1_ind == 1'b1 & tlb0cfg_ind == 1'b1 & mas0_1_wq != 2'b10 & (mas2_1_wimge[1] == 1'b1 | mas2_1_wimge[2] == 1'b0 | mas2_1_wimge[3] == 1'b1 | mas2_1_wimge[4] == 1'b1) & (mas0_1_atsel == 1'b0 | ex6_state_q[1] == 1'b1))) ? 1'b1 : 
                                               1'b0;
                                               
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
      
      assign tlb_lper_lpn = ptereload_req_pte_q[`ptepos_rpn + 10:`ptepos_rpn + 39];
      
      assign tlb_lper_lps = ptereload_req_pte_q[`ptepos_size:`ptepos_size + 3];
      
      assign tlb_lper_we = ( (tlb_tag4_ptereload == 1'b1 & tlb_tag4_gs == 1'b1 & mmucfg_lrat == 1'b1 & 
                                tlb_tag4_pt == 1'b1 & tlb_tag4_wq == 2'b10 & tlb_tag4_is[0] == 1'b1 & 
                                lrat_tag4_hit_status[0:3] != 4'b1100) ) ? tlb_tag0_q[`tagpos_thdid:`tagpos_thdid + `MM_THREADS -1] : 
                           {`MM_THREADS{1'b0}};
                           
      assign pte_tag0_lpn = ptereload_req_pte_q[`ptepos_rpn + 10:`ptepos_rpn + 39];
      
      assign pte_tag0_lpid = tlb_tag0_q[`tagpos_lpid:`tagpos_lpid + `LPID_WIDTH - 1];
      
      
      assign tlb_ctl_perf_tlbwec_resv = |(ex6_valid_q & tlb_resv_match_vec_q) & ex6_ttype_q[1] & (tlb_tag4_wq == 2'b01);
      
      assign tlb_ctl_perf_tlbwec_noresv = |(ex6_valid_q & (~tlb_resv_match_vec_q)) & ex6_ttype_q[1] & (tlb_tag4_wq == 2'b01);
      
      assign tlb_early_act = xu_mm_ccr2_notlb_b & (any_tlb_req_sig | (~(tlb_seq_idle_sig)) | tlb_ctl_any_tag_flush_sig | tlb_seq_abort);
      
      assign tlb_delayed_act_d[0:1] = (tlb_early_act == 1'b1) ? 2'b11 : 
                                      (tlb_delayed_act_q[0:1] == 2'b11) ? 2'b10 : 
                                      (tlb_delayed_act_q[0:1] == 2'b10) ? 2'b01 : 
                                      2'b00;
                                      
      assign tlb_delayed_act_d[2:8]   = {7{tlb_early_act | tlb_delayed_act_q[0] | tlb_delayed_act_q[1] | mmucr2[1]}};
      assign tlb_delayed_act_d[9:16]  = {8{tlb_early_act | tlb_delayed_act_q[0] | tlb_delayed_act_q[1] | mmucr2[2]}};
      assign tlb_delayed_act_d[17:18] = {2{tlb_early_act | tlb_delayed_act_q[0] | tlb_delayed_act_q[1] | mmucr2[2]}};  
      assign tlb_delayed_act_d[20:23] = {4{tlb_early_act | tlb_delayed_act_q[0] | tlb_delayed_act_q[1] | mmucr2[3]}};
      assign tlb_delayed_act_d[24:28] = {5{tlb_early_act | tlb_delayed_act_q[0] | tlb_delayed_act_q[1] | mmucr2[4]}};
      assign tlb_delayed_act_d[29:32] = {4{tlb_early_act | tlb_delayed_act_q[0] | tlb_delayed_act_q[1] | mmucr2[6]}};
      
      assign tlb_delayed_act_d[19] = xu_mm_ccr2_notlb_b & tlb_seq_lru_rd_act; 
      assign tlb_delayed_act_d[33] = xu_mm_ccr2_notlb_b & tlb_seq_lru_wr_act; 
      
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

