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
`define            MMQ_INVAL_TTYPE_WIDTH   6
`define            MMQ_INVAL_STATE_WIDTH   2
`define            INV_SEQ_WIDTH           6
`define            BUS_SNOOP_SEQ_WIDTH     2



module mmq_inval(

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
   
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                          ac_func_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                         ac_func_scan_out,
   
   input                          pc_sg_2,
   input                          pc_func_sl_thold_2,
   input                          pc_func_slp_sl_thold_2,
   input                          pc_func_slp_nsl_thold_2,
   input                          pc_fce_2,
   input                          mmucr2_act_override,
   input                          xu_mm_ccr2_notlb,
   output [1:12]                  xu_mm_ccr2_notlb_b,
   
   output                         mm_iu_ierat_snoop_coming,
   output                         mm_iu_ierat_snoop_val,
   output [0:25]                  mm_iu_ierat_snoop_attr,
   output [52-`EPN_WIDTH:51]       mm_iu_ierat_snoop_vpn,
   input                          iu_mm_ierat_snoop_ack,
   
   output                         mm_xu_derat_snoop_coming,
   output                         mm_xu_derat_snoop_val,
   output [0:25]                  mm_xu_derat_snoop_attr,
   output [52-`EPN_WIDTH:51]       mm_xu_derat_snoop_vpn,
   input                          xu_mm_derat_snoop_ack,
   output                         tlb_snoop_coming,
   output                         tlb_snoop_val,
   output [0:34]                  tlb_snoop_attr,
   output [52-`EPN_WIDTH:51]       tlb_snoop_vpn,
   input                          tlb_snoop_ack,
   input                          an_ac_back_inv,
   input                          an_ac_back_inv_target,
   input                          an_ac_back_inv_local,
   input                          an_ac_back_inv_lbit,
   input                          an_ac_back_inv_gs,
   input                          an_ac_back_inv_ind,
   input [64-`REAL_ADDR_WIDTH:63]  an_ac_back_inv_addr,
   input [0:`LPID_WIDTH-1]         an_ac_back_inv_lpar_id,
   input                          ac_an_power_managed,
   output                         ac_an_back_inv_reject,

   input [0:`LPID_WIDTH-1]         lpidr,
   input                          mas5_0_sgs,
   input [0:7]                    mas5_0_slpid,
   input [0:13]                   mas6_0_spid,
   input [0:3]                    mas6_0_isize,
   input                          mas6_0_sind,
   input                          mas6_0_sas,
   input [2:19]                   mmucr0_0,
`ifdef MM_THREADS2
   input                          mas5_1_sgs,
   input [0:7]                    mas5_1_slpid,
   input [0:13]                   mas6_1_spid,
   input [0:3]                    mas6_1_isize,
   input                          mas6_1_sind,
   input                          mas6_1_sas,
   input [2:19]                   mmucr0_1,
`endif
   input [12:19]                  mmucr1,
   input [0:1]                    mmucr1_csinv,
   input                          mmucsr0_tlb0fi,
   output                         mmq_inval_tlb0fi_done,
   
   input [0:`MM_THREADS-1]        xu_mm_rf1_val,
   input                          xu_mm_rf1_is_tlbivax,
   input                          xu_mm_rf1_is_tlbilx,
   input                          xu_mm_rf1_is_erativax,
   input                          xu_mm_rf1_is_eratilx,
   input [0:`RS_IS_WIDTH-1]        xu_mm_ex1_rs_is,
   input                          xu_mm_ex1_is_isync,
   input                          xu_mm_ex1_is_csync,
   input [64-`RS_DATA_WIDTH:63]   xu_mm_ex2_eff_addr,
   input [0:`T_WIDTH-1]           xu_mm_rf1_t,
   input [0:`ITAG_SIZE_ENC-1]     xu_mm_rf1_itag,
   input [0:`MM_THREADS-1]        xu_mm_msr_gs,
   input [0:`MM_THREADS-1]        xu_mm_msr_pr,
   input [0:`MM_THREADS-1]        xu_mm_spr_epcr_dgtmi,
   output [0:`MM_THREADS-1]        xu_mm_epcr_dgtmi,
   input [0:`MM_THREADS-1]        xu_rf1_flush,
   input [0:`MM_THREADS-1]        xu_ex1_flush,
   input [0:`MM_THREADS-1]        xu_ex2_flush,
   input [0:`MM_THREADS-1]        xu_ex3_flush,
   input [0:`MM_THREADS-1]        xu_ex4_flush,
   input [0:`MM_THREADS-1]        xu_ex5_flush,
   input                          xu_mm_lmq_stq_empty,
   input                          iu_mm_lmq_empty,
   input [0:`MM_THREADS-1]        tlb_ctl_barrier_done,
   input [0:`MM_THREADS-1]        tlb_ctl_ex2_flush_req,
   input [0:`MM_THREADS-1]        tlb_ctl_ex2_illeg_instr,
   input [0:`MM_THREADS-1]        tlb_ctl_ex6_illeg_instr,
   input [0:`ITAG_SIZE_ENC-1]     tlb_ctl_ex2_itag,
   input [0:2]                    tlb_ctl_ord_type,
   input [0:`ITAG_SIZE_ENC-1]     tlb_tag4_itag,
   input [0:`MM_THREADS-1]        tlb_tag5_except,
   input [0:`MM_THREADS-1]        tlb_ctl_quiesce,
   input [0:`MM_THREADS-1]        tlb_req_quiesce,
   output [0:`MM_THREADS-1]        mm_xu_quiesce,
   output [0:`MM_THREADS-1]        mm_pc_tlb_req_quiesce,   
   output [0:`MM_THREADS-1]        mm_pc_tlb_ctl_quiesce,   
   output [0:`MM_THREADS-1]        mm_pc_htw_quiesce,       
   output [0:`MM_THREADS-1]        mm_pc_inval_quiesce,     
   
   output [0:`MM_THREADS-1]        mm_xu_ex3_flush_req,
   output [0:`MM_THREADS-1]        mm_xu_illeg_instr,
   output [0:`MM_THREADS-1]        mm_xu_local_snoop_reject,
   
   input [0:`MM_THREADS-1]         iu_mm_hold_ack,
   output [0:`MM_THREADS-1]        mm_iu_hold_req,
   output [0:`MM_THREADS-1]        mm_iu_hold_done,
   output [0:`MM_THREADS-1]        mm_iu_flush_req,
   input [0:`MM_THREADS-1]         iu_mm_bus_snoop_hold_ack,
   output [0:`MM_THREADS-1]        mm_iu_bus_snoop_hold_req,
   output [0:`MM_THREADS-1]        mm_iu_bus_snoop_hold_done,
   output [0:`MM_THREADS-1]        mm_iu_tlbi_complete,
   
   output [0:`MM_THREADS-1]        mm_xu_ord_n_flush_req,
   output [0:`MM_THREADS-1]        mm_xu_ord_np1_flush_req,
   output [0:`MM_THREADS-1]        mm_xu_ord_read_done,
   output [0:`MM_THREADS-1]        mm_xu_ord_write_done,
   output [0:`ITAG_SIZE_ENC-1]     mm_xu_itag,
   output                         mm_xu_ord_n_flush_req_ored,
   output                         mm_xu_ord_np1_flush_req_ored,
   output                         mm_xu_ord_read_done_ored,
   output                         mm_xu_ord_write_done_ored,
   output                         mm_xu_illeg_instr_ored,
   output                         mm_pc_local_snoop_reject_ored,
   
   output                         inval_perf_tlbilx,
   output                         inval_perf_tlbivax,
   output                         inval_perf_tlbivax_snoop,
   output                         inval_perf_tlb_flush,
   
   input                          htw_lsu_req_valid,
   input [0:`MM_THREADS-1]        htw_lsu_thdid,
   input [0:1]                    htw_lsu_ttype,
   input [0:4]                    htw_lsu_wimge,
   input [0:3]                    htw_lsu_u,
   input [64-`REAL_ADDR_WIDTH:63]  htw_lsu_addr,
   output                         htw_lsu_req_taken,
   input [0:`MM_THREADS-1]        htw_quiesce,
   input                          tlbwe_back_inv_valid,
   input [0:`MM_THREADS-1]        tlbwe_back_inv_thdid,
   input [52-`EPN_WIDTH:51]        tlbwe_back_inv_addr,
   input [0:34]                   tlbwe_back_inv_attr,
   input                          tlb_tag5_write,
   output                         tlbwe_back_inv_pending,
   
   output [0:`MM_THREADS-1]                   mm_xu_lsu_req,
   output [0:1]                   mm_xu_lsu_ttype,
   output [0:4]                   mm_xu_lsu_wimge,
   output [0:3]                   mm_xu_lsu_u,
   output [64-`REAL_ADDR_WIDTH:63] mm_xu_lsu_addr,
   output [0:7]                   mm_xu_lsu_lpid,
   output                         mm_xu_lsu_gs,
   output                         mm_xu_lsu_ind,
   output                         mm_xu_lsu_lbit,
   input                          xu_mm_lsu_token,
   
   output [0:4]                   inval_dbg_seq_q,
   output                         inval_dbg_seq_idle,
   output                         inval_dbg_seq_snoop_inprogress,
   output                         inval_dbg_seq_snoop_done,
   output                         inval_dbg_seq_local_done,
   output                         inval_dbg_seq_tlb0fi_done,
   output                         inval_dbg_seq_tlbwe_snoop_done,
   output                         inval_dbg_ex6_valid,
   output [0:1]                   inval_dbg_ex6_thdid,   
   output [0:2]                   inval_dbg_ex6_ttype,   
   output                         inval_dbg_snoop_forme,
   output                         inval_dbg_snoop_local_reject,
   output [2:8]                   inval_dbg_an_ac_back_inv_q,
   output [0:7]                   inval_dbg_an_ac_back_inv_lpar_id_q,
   output [22:63]                 inval_dbg_an_ac_back_inv_addr_q,
   output [0:2]                   inval_dbg_snoop_valid_q,
   output [0:2]                   inval_dbg_snoop_ack_q,
   output [0:34]                  inval_dbg_snoop_attr_q,
   output [18:19]                 inval_dbg_snoop_attr_tlb_spec_q,
   output [17:51]                 inval_dbg_snoop_vpn_q,
   output [0:1]                   inval_dbg_lsu_tokens_q

);


      parameter                      MMQ_INVAL_CSWITCH_0TO3 = 0;

      parameter                      MMU_Mode_Value = 1'b0;
      parameter                      ERAT_Mode_Value = 1'b1;
      parameter [0:1]                TlbSel_Tlb = 2'b00;
      parameter [0:1]                TlbSel_IErat = 2'b10;
      parameter [0:1]                TlbSel_DErat = 2'b11;
      parameter [0:3]                TLB_PgSize_1GB = 4'b1010;
      parameter [0:3]                TLB_PgSize_16MB = 4'b0111;
      parameter [0:3]                TLB_PgSize_1MB = 4'b0101;
      parameter [0:3]                TLB_PgSize_64KB = 4'b0011;
      parameter [0:3]                TLB_PgSize_4KB = 4'b0001;
      parameter [0:3]                TLB_PgSize_256MB = 4'b1001;
      parameter [0:5]                InvSeq_Idle = 6'b000000;
      parameter [0:5]                InvSeq_Stg1 = 6'b000001;
      parameter [0:5]                InvSeq_Stg2 = 6'b000011;
      parameter [0:5]                InvSeq_Stg3 = 6'b000010;
      parameter [0:5]                InvSeq_Stg4 = 6'b000110;
      parameter [0:5]                InvSeq_Stg5 = 6'b000100;
      parameter [0:5]                InvSeq_Stg6 = 6'b000101;
      parameter [0:5]                InvSeq_Stg7 = 6'b000111;
      parameter [0:5]                InvSeq_Stg8 = 6'b001000;
      parameter [0:5]                InvSeq_Stg9 = 6'b001001;
      parameter [0:5]                InvSeq_Stg10 = 6'b001011;
      parameter [0:5]                InvSeq_Stg11 = 6'b001010;
      parameter [0:5]                InvSeq_Stg12 = 6'b001110;
      parameter [0:5]                InvSeq_Stg13 = 6'b001100;
      parameter [0:5]                InvSeq_Stg14 = 6'b001101;
      parameter [0:5]                InvSeq_Stg15 = 6'b001111;
      parameter [0:5]                InvSeq_Stg16 = 6'b010000;
      parameter [0:5]                InvSeq_Stg17 = 6'b010001;
      parameter [0:5]                InvSeq_Stg18 = 6'b010011;
      parameter [0:5]                InvSeq_Stg19 = 6'b010010;
      parameter [0:5]                InvSeq_Stg20 = 6'b010110;
      parameter [0:5]                InvSeq_Stg21 = 6'b010100;
      parameter [0:5]                InvSeq_Stg22 = 6'b010101;
      parameter [0:5]                InvSeq_Stg23 = 6'b010111;
      parameter [0:5]                InvSeq_Stg24 = 6'b011000;
      parameter [0:5]                InvSeq_Stg25 = 6'b011001;
      parameter [0:5]                InvSeq_Stg26 = 6'b011011;
      parameter [0:5]                InvSeq_Stg27 = 6'b011010;
      parameter [0:5]                InvSeq_Stg28 = 6'b011110;
      parameter [0:5]                InvSeq_Stg29 = 6'b011100;
      parameter [0:5]                InvSeq_Stg30 = 6'b011101;
      parameter [0:5]                InvSeq_Stg31 = 6'b011111;
      parameter [0:5]                InvSeq_Stg32 = 6'b100000;
      parameter [0:1]                SnoopSeq_Idle = 2'b00;
      parameter [0:1]                SnoopSeq_Stg1 = 2'b01;
      parameter [0:1]                SnoopSeq_Stg2 = 2'b10;
      parameter [0:1]                SnoopSeq_Stg3 = 2'b11;

      parameter                      pos_ictid = 12;
      parameter                      pos_ittid = 13;
      parameter                      pos_dctid = 14;
      parameter                      pos_dttid = 15;
      parameter                      pos_tlbi_msb = 18;
      parameter                      pos_tlbi_rej = 19;
      parameter                      ex1_valid_offset = 0;
      parameter                      ex1_ttype_offset = ex1_valid_offset + `MM_THREADS;
      parameter                      ex1_state_offset = ex1_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH - 2;
      parameter                      ex1_t_offset = ex1_state_offset + `MMQ_INVAL_STATE_WIDTH;
      parameter                      ex2_valid_offset = ex1_t_offset + `T_WIDTH;
      parameter                      ex2_ttype_offset = ex2_valid_offset + `MM_THREADS;
      parameter                      ex2_rs_is_offset = ex2_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH;
      parameter                      ex2_state_offset = ex2_rs_is_offset + `RS_IS_WIDTH;
      parameter                      ex2_t_offset = ex2_state_offset + `MMQ_INVAL_STATE_WIDTH;
      parameter                      ex3_valid_offset = ex2_t_offset + `T_WIDTH;
      parameter                      ex3_ttype_offset = ex3_valid_offset + `MM_THREADS;
      parameter                      ex3_rs_is_offset = ex3_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH;
      parameter                      ex3_state_offset = ex3_rs_is_offset + `RS_IS_WIDTH;
      parameter                      ex3_t_offset = ex3_state_offset + `MMQ_INVAL_STATE_WIDTH;
      parameter                      ex3_flush_req_offset = ex3_t_offset + `T_WIDTH;
      parameter                      ex3_ea_offset = ex3_flush_req_offset + `MM_THREADS;
      parameter                      ex4_valid_offset = ex3_ea_offset + `EPN_WIDTH + 12;
      parameter                      ex4_ttype_offset = ex4_valid_offset + `MM_THREADS;
      parameter                      ex4_rs_is_offset = ex4_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH;
      parameter                      ex4_state_offset = ex4_rs_is_offset + `RS_IS_WIDTH;
      parameter                      ex4_t_offset = ex4_state_offset + `MMQ_INVAL_STATE_WIDTH;
      parameter                      ex5_valid_offset = ex4_t_offset + `T_WIDTH;
      parameter                      ex5_ttype_offset = ex5_valid_offset + `MM_THREADS;
      parameter                      ex5_rs_is_offset = ex5_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH;
      parameter                      ex5_state_offset = ex5_rs_is_offset + `RS_IS_WIDTH;
      parameter                      ex5_t_offset = ex5_state_offset + `MMQ_INVAL_STATE_WIDTH;
      parameter                      ex6_valid_offset = ex5_t_offset + `T_WIDTH;
      parameter                      ex6_ttype_offset = ex6_valid_offset + `MM_THREADS;
      parameter                      ex6_isel_offset = ex6_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH;
      parameter                      ex6_size_offset = ex6_isel_offset + 3;
      parameter                      ex6_gs_offset = ex6_size_offset + 4;
      parameter                      ex6_ts_offset = ex6_gs_offset + 1;
      parameter                      ex6_ind_offset = ex6_ts_offset + 1;
      parameter                      ex6_pid_offset = ex6_ind_offset + 1;
      parameter                      ex6_lpid_offset = ex6_pid_offset + `PID_WIDTH;
      parameter                      ex1_itag_offset = ex6_lpid_offset + `LPID_WIDTH;
      parameter                      ex2_itag_offset = ex1_itag_offset + `ITAG_SIZE_ENC;
      parameter                      ex3_itag_offset = ex2_itag_offset + `ITAG_SIZE_ENC;
      parameter                      ex4_itag_offset = ex3_itag_offset + `ITAG_SIZE_ENC;
      parameter                      ex5_itag_offset = ex4_itag_offset + `ITAG_SIZE_ENC;
      parameter                      ex6_itag_offset = ex5_itag_offset + `ITAG_SIZE_ENC;
      parameter                      mm_xu_itag_offset = ex6_itag_offset + `ITAG_SIZE_ENC;
      parameter                      ord_read_done_offset = mm_xu_itag_offset + `ITAG_SIZE_ENC;
      parameter                      ord_write_done_offset = ord_read_done_offset + `MM_THREADS;
      parameter                      ord_np1_flush_offset = ord_write_done_offset + `MM_THREADS;
      parameter                      inv_seq_offset = ord_np1_flush_offset + `MM_THREADS;
      parameter                      hold_req_offset = inv_seq_offset + `INV_SEQ_WIDTH;
      parameter                      hold_ack_offset = hold_req_offset + `MM_THREADS;
      parameter                      hold_done_offset = hold_ack_offset + `MM_THREADS;
      parameter                      local_barrier_offset = hold_done_offset + `MM_THREADS;
      parameter                      global_barrier_offset = local_barrier_offset + `MM_THREADS;
      parameter                      ex3_illeg_instr_offset = global_barrier_offset + `MM_THREADS;
      parameter                      ex4_illeg_instr_offset = ex3_illeg_instr_offset + `MM_THREADS;
      parameter                      ex5_illeg_instr_offset = ex4_illeg_instr_offset + `MM_THREADS;
      parameter                      ex6_illeg_instr_offset = ex5_illeg_instr_offset + `MM_THREADS;
      parameter                      ex7_illeg_instr_offset = ex6_illeg_instr_offset + `MM_THREADS;
      parameter                      ex3_ivax_lpid_reject_offset = ex7_illeg_instr_offset + `MM_THREADS;
      parameter                      ex4_ivax_lpid_reject_offset = ex3_ivax_lpid_reject_offset + `MM_THREADS;
      parameter                      bus_snoop_seq_offset = ex4_ivax_lpid_reject_offset + `MM_THREADS;
      parameter                      bus_snoop_hold_req_offset = bus_snoop_seq_offset + `BUS_SNOOP_SEQ_WIDTH;
      parameter                      bus_snoop_hold_ack_offset = bus_snoop_hold_req_offset + `MM_THREADS;
      parameter                      bus_snoop_hold_done_offset = bus_snoop_hold_ack_offset + `MM_THREADS;
      parameter                      tlbi_complete_offset = bus_snoop_hold_done_offset + `MM_THREADS;
      parameter                      iu_flush_req_offset = tlbi_complete_offset + `MM_THREADS;
      parameter                      local_snoop_reject_offset = iu_flush_req_offset + `MM_THREADS;
      parameter                      snoop_valid_offset = local_snoop_reject_offset + `MM_THREADS;
      parameter                      snoop_attr_offset = snoop_valid_offset + 3;
      parameter                      snoop_vpn_offset = snoop_attr_offset + 35;
      parameter                      snoop_attr_clone_offset = snoop_vpn_offset + `EPN_WIDTH;
      parameter                      snoop_attr_tlb_spec_offset = snoop_attr_clone_offset + 26;
      parameter                      snoop_vpn_clone_offset = snoop_attr_tlb_spec_offset + 2;
      parameter                      snoop_ack_offset = snoop_vpn_clone_offset + `EPN_WIDTH;
      parameter                      snoop_coming_offset = snoop_ack_offset + 3;
      parameter                      mm_xu_quiesce_offset = snoop_coming_offset + 5;
      parameter                      mm_pc_quiesce_offset = mm_xu_quiesce_offset + `MM_THREADS;
      parameter                      inv_seq_inprogress_offset = mm_pc_quiesce_offset + 4*`MM_THREADS;
      parameter                      xu_mm_ccr2_notlb_offset = inv_seq_inprogress_offset + 6;
      parameter                      spare_offset = xu_mm_ccr2_notlb_offset + 13;
      parameter                      an_ac_back_inv_offset = spare_offset + 16;
      parameter                      an_ac_back_inv_addr_offset = an_ac_back_inv_offset + 9;
      parameter                      an_ac_back_inv_lpar_id_offset = an_ac_back_inv_addr_offset + `REAL_ADDR_WIDTH;
      parameter                      lsu_tokens_offset = an_ac_back_inv_lpar_id_offset + `LPID_WIDTH;
      parameter                      lsu_req_offset = lsu_tokens_offset + 2;
      parameter                      lsu_ttype_offset = lsu_req_offset + `MM_THREADS;
      parameter                      lsu_ubits_offset = lsu_ttype_offset + 2;
      parameter                      lsu_wimge_offset = lsu_ubits_offset + 4;
      parameter                      lsu_addr_offset = lsu_wimge_offset + 5;
      parameter                      lsu_lpid_offset = lsu_addr_offset + `REAL_ADDR_WIDTH;
      parameter                      lsu_ind_offset = lsu_lpid_offset + `LPID_WIDTH;
      parameter                      lsu_gs_offset = lsu_ind_offset + 1;
      parameter                      lsu_lbit_offset = lsu_gs_offset + 1;
      parameter                      power_managed_offset = lsu_lbit_offset + 1;
      parameter                      cswitch_offset = power_managed_offset + 4;
      parameter                      tlbwe_back_inv_offset = cswitch_offset + 4;
      parameter                      tlbwe_back_inv_addr_offset = tlbwe_back_inv_offset + `MM_THREADS + 2;
      parameter                      tlbwe_back_inv_attr_offset = tlbwe_back_inv_addr_offset + `EPN_WIDTH;
      parameter                      scan_right = tlbwe_back_inv_attr_offset + 35 - 1;
      
`ifdef MM_THREADS2
      parameter                      BUGSP_MM_THREADS = 2;
`else
      parameter                      BUGSP_MM_THREADS = 1;
`endif      
      
      wire [0:`MM_THREADS-1]          ex1_valid_d;
      wire [0:`MM_THREADS-1]          ex1_valid_q;
      wire [0:`MMQ_INVAL_TTYPE_WIDTH-3]         ex1_ttype_d;
      wire [0:`MMQ_INVAL_TTYPE_WIDTH-3]         ex1_ttype_q;
      wire [0:`MMQ_INVAL_STATE_WIDTH-1]         ex1_state_d;
      wire [0:`MMQ_INVAL_STATE_WIDTH-1]         ex1_state_q;
      wire [0:`T_WIDTH-1]             ex1_t_d;
      wire [0:`T_WIDTH-1]             ex1_t_q;
      wire [0:`MM_THREADS-1]          ex2_valid_d;
      wire [0:`MM_THREADS-1]          ex2_valid_q;
      wire [0:`MMQ_INVAL_TTYPE_WIDTH-1]         ex2_ttype_d;
      wire [0:`MMQ_INVAL_TTYPE_WIDTH-1]         ex2_ttype_q;
      wire [0:`RS_IS_WIDTH-1]         ex2_rs_is_d;
      wire [0:`RS_IS_WIDTH-1]         ex2_rs_is_q;
      wire [0:`MMQ_INVAL_STATE_WIDTH-1]         ex2_state_d;
      wire [0:`MMQ_INVAL_STATE_WIDTH-1]         ex2_state_q;
      wire [0:`T_WIDTH-1]             ex2_t_d;
      wire [0:`T_WIDTH-1]             ex2_t_q;
      wire [64-`RS_DATA_WIDTH:63]     ex3_ea_d;
      wire [64-`RS_DATA_WIDTH:63]     ex3_ea_q;
      wire [0:`MM_THREADS-1]          ex3_valid_d;
      wire [0:`MM_THREADS-1]          ex3_valid_q;
      wire [0:`MMQ_INVAL_TTYPE_WIDTH-1]         ex3_ttype_d;
      wire [0:`MMQ_INVAL_TTYPE_WIDTH-1]         ex3_ttype_q;
      wire [0:`RS_IS_WIDTH-1]         ex3_rs_is_d;
      wire [0:`RS_IS_WIDTH-1]         ex3_rs_is_q;
      wire [0:`MMQ_INVAL_STATE_WIDTH-1]         ex3_state_d;
      wire [0:`MMQ_INVAL_STATE_WIDTH-1]         ex3_state_q;
      wire [0:`T_WIDTH-1]             ex3_t_d;
      wire [0:`T_WIDTH-1]             ex3_t_q;
      wire [0:`MM_THREADS-1]          ex3_flush_req_d;
      wire [0:`MM_THREADS-1]          ex3_flush_req_q;
      wire [0:`MM_THREADS-1]          ex4_valid_d;
      wire [0:`MM_THREADS-1]          ex4_valid_q;
      wire [0:`MMQ_INVAL_TTYPE_WIDTH-1]         ex4_ttype_d;
      wire [0:`MMQ_INVAL_TTYPE_WIDTH-1]         ex4_ttype_q;
      wire [0:`RS_IS_WIDTH-1]         ex4_rs_is_d;
      wire [0:`RS_IS_WIDTH-1]         ex4_rs_is_q;
      wire [0:`MMQ_INVAL_STATE_WIDTH-1]         ex4_state_d;
      wire [0:`MMQ_INVAL_STATE_WIDTH-1]         ex4_state_q;
      wire [0:`T_WIDTH-1]             ex4_t_d;
      wire [0:`T_WIDTH-1]             ex4_t_q;
      wire [0:`MM_THREADS-1]          ex5_valid_d;
      wire [0:`MM_THREADS-1]          ex5_valid_q;
      wire [0:`MMQ_INVAL_TTYPE_WIDTH-1]         ex5_ttype_d;
      wire [0:`MMQ_INVAL_TTYPE_WIDTH-1]         ex5_ttype_q;
      wire [0:`RS_IS_WIDTH-1]         ex5_rs_is_d;
      wire [0:`RS_IS_WIDTH-1]         ex5_rs_is_q;
      wire [0:`MMQ_INVAL_STATE_WIDTH-1]         ex5_state_d;
      wire [0:`MMQ_INVAL_STATE_WIDTH-1]         ex5_state_q;
      wire [0:`T_WIDTH-1]             ex5_t_d;
      wire [0:`T_WIDTH-1]             ex5_t_q;
      wire [0:`MM_THREADS-1]          ex6_valid_d;
      wire [0:`MM_THREADS-1]          ex6_valid_q;
      wire [0:`MMQ_INVAL_TTYPE_WIDTH-1]         ex6_ttype_d;
      wire [0:`MMQ_INVAL_TTYPE_WIDTH-1]         ex6_ttype_q;
      wire [0:2]                      ex6_isel_d;
      wire [0:2]                      ex6_isel_q;
      wire [0:3]                      ex6_size_d;
      wire [0:3]                      ex6_size_q;
      wire                            ex6_gs_d;
      wire                            ex6_gs_q;
      wire                            ex6_ts_d;
      wire                            ex6_ts_q;
      wire                            ex6_ind_d;
      wire                            ex6_ind_q;
      wire [0:`PID_WIDTH-1]           ex6_pid_d;
      wire [0:`PID_WIDTH-1]           ex6_pid_q;
      wire [0:`LPID_WIDTH-1]          ex6_lpid_d;
      wire [0:`LPID_WIDTH-1]          ex6_lpid_q;
      wire [0:`ITAG_SIZE_ENC-1]       ex1_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]       ex1_itag_q;
      wire [0:`ITAG_SIZE_ENC-1]       ex2_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]       ex2_itag_q;
      wire [0:`ITAG_SIZE_ENC-1]       ex3_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]       ex3_itag_q;
      wire [0:`ITAG_SIZE_ENC-1]       ex4_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]       ex4_itag_q;
      wire [0:`ITAG_SIZE_ENC-1]       ex5_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]       ex5_itag_q;
      wire [0:`ITAG_SIZE_ENC-1]       ex6_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]       ex6_itag_q;
      wire [0:`ITAG_SIZE_ENC-1]       mm_xu_itag_d;
      wire [0:`ITAG_SIZE_ENC-1]       mm_xu_itag_q;
      wire [0:`MM_THREADS-1]          ord_read_done_d;
      wire [0:`MM_THREADS-1]          ord_read_done_q;
      wire [0:`MM_THREADS-1]          ord_write_done_d;
      wire [0:`MM_THREADS-1]          ord_write_done_q;
      wire [0:`MM_THREADS-1]          ord_np1_flush_d;
      wire [0:`MM_THREADS-1]          ord_np1_flush_q;
      reg [0:`INV_SEQ_WIDTH-1]       inv_seq_d;
      wire [0:`INV_SEQ_WIDTH-1]       inv_seq_q;
      wire [0:`MM_THREADS-1]          hold_req_d;
      wire [0:`MM_THREADS-1]          hold_req_q;
      wire [0:`MM_THREADS-1]          hold_ack_d;
      wire [0:`MM_THREADS-1]          hold_ack_q;
      wire [0:`MM_THREADS-1]          hold_done_d;
      wire [0:`MM_THREADS-1]          hold_done_q;
      wire [0:`MM_THREADS-1]          local_barrier_d;
      wire [0:`MM_THREADS-1]          local_barrier_q;
      wire [0:`MM_THREADS-1]          global_barrier_d;
      wire [0:`MM_THREADS-1]          global_barrier_q;
      wire [0:`MM_THREADS-1]          ex3_illeg_instr_d;
      wire [0:`MM_THREADS-1]          ex3_illeg_instr_q;
      wire [0:`MM_THREADS-1]          ex3_ivax_lpid_reject_d, ex3_ivax_lpid_reject_q;
      wire [0:`MM_THREADS-1]          ex4_ivax_lpid_reject_d, ex4_ivax_lpid_reject_q;
      reg  [0:`BUS_SNOOP_SEQ_WIDTH-1]          bus_snoop_seq_d;
      wire [0:`BUS_SNOOP_SEQ_WIDTH-1]          bus_snoop_seq_q;
      wire [0:`MM_THREADS-1]          bus_snoop_hold_req_d;
      wire [0:`MM_THREADS-1]          bus_snoop_hold_req_q;
      wire [0:`MM_THREADS-1]          bus_snoop_hold_ack_d;
      wire [0:`MM_THREADS-1]          bus_snoop_hold_ack_q;
      wire [0:`MM_THREADS-1]          bus_snoop_hold_done_d;
      wire [0:`MM_THREADS-1]          bus_snoop_hold_done_q;
      wire [0:`MM_THREADS-1]          tlbi_complete_d;
      wire [0:`MM_THREADS-1]          tlbi_complete_q;
      wire [0:`MM_THREADS-1]          iu_flush_req_d;
      wire [0:`MM_THREADS-1]          iu_flush_req_q;
      wire [0:`MM_THREADS-1]          ex4_illeg_instr_d;
      wire [0:`MM_THREADS-1]          ex4_illeg_instr_q;
      wire [0:`MM_THREADS-1]          ex5_illeg_instr_d;
      wire [0:`MM_THREADS-1]          ex5_illeg_instr_q;
      wire [0:`MM_THREADS-1]          ex6_illeg_instr_d;
      wire [0:`MM_THREADS-1]          ex6_illeg_instr_q;
      wire [0:`MM_THREADS-1]          ex7_illeg_instr_d;
      wire [0:`MM_THREADS-1]          ex7_illeg_instr_q;
      wire                           local_snoop_reject_ored;
      wire [0:`MM_THREADS-1]          local_snoop_reject_d, local_snoop_reject_q;
      wire [0:5]                     inv_seq_inprogress_d;
      wire [0:5]                     inv_seq_inprogress_q;
      wire [0:2]                     snoop_valid_d;
      wire [0:2]                     snoop_valid_q;
      wire [0:34]                    snoop_attr_d;
      wire [0:34]                    snoop_attr_q;
      wire [52-`EPN_WIDTH:51]         snoop_vpn_d;
      wire [52-`EPN_WIDTH:51]         snoop_vpn_q;
      wire [0:25]                    snoop_attr_clone_d;
      wire [0:25]                    snoop_attr_clone_q;
      wire [18:19]                   snoop_attr_tlb_spec_d;
      wire [18:19]                   snoop_attr_tlb_spec_q;
      wire [52-`EPN_WIDTH:51]         snoop_vpn_clone_d;
      wire [52-`EPN_WIDTH:51]         snoop_vpn_clone_q;
      wire [0:2]                     snoop_ack_d;
      wire [0:2]                     snoop_ack_q;
      wire [0:4]                     snoop_coming_d;
      wire [0:4]                     snoop_coming_q;
      wire [0:8]                     an_ac_back_inv_d;
      wire [0:8]                     an_ac_back_inv_q;
      wire [64-`REAL_ADDR_WIDTH:63]   an_ac_back_inv_addr_d;
      wire [64-`REAL_ADDR_WIDTH:63]   an_ac_back_inv_addr_q;
      wire [0:`LPID_WIDTH-1]          an_ac_back_inv_lpar_id_d;
      wire [0:`LPID_WIDTH-1]          an_ac_back_inv_lpar_id_q;
      wire [0:1]                     lsu_tokens_d;
      wire [0:1]                     lsu_tokens_q;
      wire [0:`MM_THREADS-1]                     lsu_req_d;
      wire [0:`MM_THREADS-1]                     lsu_req_q;
      wire [0:1]                     lsu_ttype_d;
      wire [0:1]                     lsu_ttype_q;
      wire [0:3]                     lsu_ubits_d;
      wire [0:3]                     lsu_ubits_q;
      wire [0:4]                     lsu_wimge_d;
      wire [0:4]                     lsu_wimge_q;
      wire [64-`REAL_ADDR_WIDTH:63]   lsu_addr_d;
      wire [64-`REAL_ADDR_WIDTH:63]   lsu_addr_q;
      wire [0:`LPID_WIDTH-1]          lsu_lpid_d;
      wire [0:`LPID_WIDTH-1]          lsu_lpid_q;
      wire                           lsu_ind_d;
      wire                           lsu_ind_q;
      wire                           lsu_gs_d;
      wire                           lsu_gs_q;
      wire                           lsu_lbit_d;
      wire                           lsu_lbit_q;
      wire [0:12]                    xu_mm_ccr2_notlb_d;
      wire [0:12]                    xu_mm_ccr2_notlb_q;
      wire [0:`MM_THREADS-1]         xu_mm_epcr_dgtmi_q;
      wire [0:`LPID_WIDTH-1]          lpidr_q;
      wire [12:19]                   mmucr1_q;
      wire [0:1]                     mmucr1_csinv_q;
      wire [0:15]                    spare_q;
      wire [0:3]                     power_managed_d;
      wire [0:3]                     power_managed_q;
      wire [0:3]                     cswitch_q;
      wire [0:`MM_THREADS-1]         mm_xu_quiesce_d;
      wire [0:`MM_THREADS-1]         mm_xu_quiesce_q;
      wire [0:`MM_THREADS-1]         inval_quiesce_b;
      wire [0:4*`MM_THREADS-1]       mm_pc_quiesce_d, mm_pc_quiesce_q;   

      reg                            inv_seq_local_done;
      reg                            inv_seq_snoop_done;
      reg [0:`MM_THREADS-1]                      inv_seq_hold_req;
      reg [0:`MM_THREADS-1]                      inv_seq_hold_done;
      reg                            inv_seq_tlbi_load;
      reg                            inv_seq_tlbi_complete;
      reg                            inv_seq_tlb_snoop_val;
      reg                            inv_seq_htw_load;
      reg                            inv_seq_ierat_snoop_val;
      reg                            inv_seq_derat_snoop_val;
      reg                            inv_seq_snoop_inprogress;
      wire [0:1]                     inv_seq_snoop_inprogress_q;
      reg                            inv_seq_local_inprogress;
      reg                            inv_seq_local_barrier_set;
      reg                            inv_seq_global_barrier_set;
      reg                            inv_seq_local_barrier_done;
      reg                            inv_seq_global_barrier_done;
      reg                            inv_seq_idle;
      reg                            bus_snoop_seq_idle;
      reg                            bus_snoop_seq_hold_req;
      reg                            bus_snoop_seq_ready;
      reg                            bus_snoop_seq_done;
      wire                           inval_snoop_forme;
      wire                           inval_snoop_local_reject;
      wire                           ex6_size_large;
      reg                            inv_seq_tlb0fi_inprogress;
      wire [0:1]                    inv_seq_tlb0fi_inprogress_q;
      reg                            inv_seq_tlb0fi_done;
      wire                           ex3_ea_hold;
      reg                            htw_lsu_req_taken_sig;
      reg                            inv_seq_tlbwe_inprogress;
      wire [0:1]                    inv_seq_tlbwe_inprogress_q;
      reg                            inv_seq_tlbwe_snoop_done;
      wire                           tlbwe_back_inv_tid_nz;
      wire [0:`MM_THREADS+1]         tlbwe_back_inv_d;
      wire [0:`MM_THREADS+1]         tlbwe_back_inv_q;
      wire [52-`EPN_WIDTH:51]         tlbwe_back_inv_addr_d;
      wire [52-`EPN_WIDTH:51]         tlbwe_back_inv_addr_q;
      wire [0:34]                    tlbwe_back_inv_attr_d;
      wire [0:34]                    tlbwe_back_inv_attr_q;
      wire                           back_inv_tid_nz;
      wire                           ex6_tid_nz;
      wire                           ex2_rs_pgsize_not_supp;
      wire [0:`MM_THREADS-1]         mas6_isize_not_supp;
      wire [0:`MM_THREADS-1]         mas5_slpid_neq_lpidr;
      wire                           ex2_hv_state;
      wire                           ex2_priv_state;
      wire                           ex2_dgtmi_state;
      wire                           ex5_hv_state;
      wire                           ex5_priv_state;
      wire                           ex5_dgtmi_state;
      (* analysis_not_referenced="true" *)  
      wire [0:16]                    unused_dc;
      
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
      wire                           pc_func_slp_nsl_thold_1;
      wire                           pc_func_slp_nsl_thold_0;
      wire                           pc_func_slp_nsl_thold_0_b;
      wire                           pc_func_sl_force;
      wire                           pc_func_slp_sl_force;
      wire                           pc_func_slp_nsl_force;
      wire [0:scan_right]            siv;
      wire [0:scan_right]            sov;
      wire                           tidn;
      wire                           tiup;


      assign tidn = 1'b0;
      assign tiup = 1'b1;
      
      assign xu_mm_ccr2_notlb_d = {13{xu_mm_ccr2_notlb}};
      
      assign power_managed_d[0] = ac_an_power_managed;
      assign power_managed_d[1] = power_managed_q[1];
      assign power_managed_d[2] = power_managed_q[2];
      assign power_managed_d[3] = power_managed_q[3];
      assign mm_xu_quiesce = mm_xu_quiesce_q;
      assign mm_xu_quiesce_d = tlb_req_quiesce & tlb_ctl_quiesce & htw_quiesce & (~inval_quiesce_b);
      assign inval_quiesce_b = ex6_valid_q | 
                                 ({`MM_THREADS{inv_seq_tlbwe_inprogress}} & tlbwe_back_inv_q[0:`MM_THREADS-1]); 

      assign mm_pc_quiesce_d[0:`MM_THREADS-1]               = tlb_req_quiesce;
      assign mm_pc_quiesce_d[`MM_THREADS:2*`MM_THREADS-1]   = tlb_ctl_quiesce;
      assign mm_pc_quiesce_d[2*`MM_THREADS:3*`MM_THREADS-1] = htw_quiesce;
      assign mm_pc_quiesce_d[3*`MM_THREADS:4*`MM_THREADS-1] = (~inval_quiesce_b);
      assign mm_pc_tlb_req_quiesce = mm_pc_quiesce_q[0:`MM_THREADS-1];
      assign mm_pc_tlb_ctl_quiesce = mm_pc_quiesce_q[`MM_THREADS:2*`MM_THREADS-1];
      assign mm_pc_htw_quiesce = mm_pc_quiesce_q[2*`MM_THREADS:3*`MM_THREADS-1];
      assign mm_pc_inval_quiesce = mm_pc_quiesce_q[3*`MM_THREADS:4*`MM_THREADS-1];

      assign ex1_valid_d = xu_mm_rf1_val & (~(xu_rf1_flush));
      assign ex1_ttype_d[0:`MMQ_INVAL_TTYPE_WIDTH - 3] = {xu_mm_rf1_is_tlbilx, xu_mm_rf1_is_tlbivax, xu_mm_rf1_is_eratilx, xu_mm_rf1_is_erativax};
      assign ex1_state_d[0] = |(xu_mm_msr_gs & xu_mm_rf1_val);
      assign ex1_state_d[1] = |(xu_mm_msr_pr & xu_mm_rf1_val);
      assign ex1_t_d = xu_mm_rf1_t;
      
      assign ex2_valid_d = ex1_valid_q & (~(xu_ex1_flush));
      assign ex2_ttype_d[0:`MMQ_INVAL_TTYPE_WIDTH - 3] = ex1_ttype_q[0:`MMQ_INVAL_TTYPE_WIDTH - 3];
      assign ex2_ttype_d[`MMQ_INVAL_TTYPE_WIDTH - 2:`MMQ_INVAL_TTYPE_WIDTH - 1] = {xu_mm_ex1_is_csync, xu_mm_ex1_is_isync};
      assign ex2_rs_is_d = xu_mm_ex1_rs_is;
      assign ex2_state_d = ex1_state_q;
      assign ex2_t_d = ex1_t_q;
      assign ex3_ea_hold = (|(ex3_valid_q) & |(ex3_ttype_q[0:3])) | (|(ex4_valid_q) & |(ex4_ttype_q[0:3])) | (|(ex5_valid_q) & |(ex5_ttype_q[0:3])) | (|(ex6_valid_q) & |(ex6_ttype_q[0:3]));
      assign ex3_ea_d = (ex3_ea_q & {`RS_DATA_WIDTH{ex3_ea_hold}}) | (xu_mm_ex2_eff_addr & {`RS_DATA_WIDTH{~ex3_ea_hold}});
      assign ex2_hv_state = (~ex2_state_q[0]) & (~ex2_state_q[1]);
      assign ex2_priv_state = (~ex2_state_q[1]);
      assign ex2_dgtmi_state = |(ex2_valid_q & xu_mm_epcr_dgtmi_q);
      
      assign ex3_valid_d = ex2_valid_q & (~(xu_ex2_flush));
      assign ex3_ttype_d[0:`MMQ_INVAL_TTYPE_WIDTH - 3] = ex2_ttype_q[0:`MMQ_INVAL_TTYPE_WIDTH - 3];
      assign ex3_ttype_d[`MMQ_INVAL_TTYPE_WIDTH - 2] = (ex2_ttype_q[`MMQ_INVAL_TTYPE_WIDTH - 2] & (~mmucr1_csinv_q[0]));
      assign ex3_ttype_d[`MMQ_INVAL_TTYPE_WIDTH - 1] = (ex2_ttype_q[`MMQ_INVAL_TTYPE_WIDTH - 1] & (~mmucr1_csinv_q[1]));
      assign ex3_rs_is_d = ex2_rs_is_q;
      assign ex3_state_d = ex2_state_q;
      assign ex3_t_d = ex2_t_q;
      
      assign ex3_flush_req_d = ((ex2_ttype_q[0:3] != 4'b0000 & (inv_seq_idle == 1'b0 | 
                                    (|(ex3_valid_q) == 1'b1 & |(ex3_ttype_q[0:3]) == 1'b1) | 
                                    (|(ex4_valid_q) == 1'b1 & |(ex4_ttype_q[0:3]) == 1'b1) | 
                                    (|(ex5_valid_q) == 1'b1 & |(ex5_ttype_q[0:3]) == 1'b1) | 
                                    (|(ex6_valid_q) == 1'b1 & |(ex6_ttype_q[0:3]) == 1'b1)))) ? (ex2_valid_q & (~(xu_ex2_flush))) : 
                               tlb_ctl_ex2_flush_req;
                               
      assign ex4_valid_d = ex3_valid_q & (~(xu_ex3_flush)) & (~(ex3_flush_req_q)) & (~(ex3_illeg_instr_q)) & (~(ex3_ivax_lpid_reject_q));
      assign ex4_ttype_d = ex3_ttype_q;
      assign ex4_rs_is_d = ex3_rs_is_q;
      assign ex4_state_d = ex3_state_q;
      assign ex4_t_d = ex3_t_q;
      
      assign ex5_valid_d = ex4_valid_q & (~(xu_ex4_flush));
      assign ex5_ttype_d = ex4_ttype_q;
      assign ex5_rs_is_d = ex4_rs_is_q;
      assign ex5_state_d = ex4_state_q;
      assign ex5_t_d = ex4_t_q;
      assign ex5_hv_state = (~ex5_state_q[0]) & (~ex5_state_q[1]);
      assign ex5_priv_state = (~ex5_state_q[1]);
      assign ex5_dgtmi_state = |(ex5_valid_q & xu_mm_epcr_dgtmi_q);
      
      assign ex6_valid_d = (inv_seq_local_done == 1'b1) ? {`MM_THREADS{1'b0}} : 
                           ((|(ex6_valid_q) == 1'b0 & ((ex5_ttype_q[0] == 1'b1 & ex5_priv_state == 1'b1 & ex5_dgtmi_state == 1'b0) | (ex5_ttype_q[0] == 1'b1 & ex5_hv_state == 1'b1 & ex5_dgtmi_state == 1'b1) | (|(ex5_ttype_q[1:3]) == 1'b1 & ex5_hv_state == 1'b1)))) ? (ex5_valid_q & (~(xu_ex5_flush))) : 
                           ex6_valid_q;
      assign ex6_ttype_d = ((|(ex5_valid_q) == 1'b1 & |(ex5_ttype_q[0:3]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? ex5_ttype_q : 
                           ex6_ttype_q;
      assign ex6_isel_d = ((|(ex5_valid_q) == 1'b1 & ex5_ttype_q[3] == 1'b1 & ex5_rs_is_q[1:2] == 2'b10 & |(ex6_valid_q) == 1'b0)) ? {1'b1, ex5_rs_is_q[3:4]} : 
                          ((|(ex5_valid_q) == 1'b1 & ex5_ttype_q[3] == 1'b1 & ex5_rs_is_q[1:2] != 2'b10 & |(ex6_valid_q) == 1'b0)) ? {1'b0, ex5_rs_is_q[1:2]} : 
                          ((|(ex5_valid_q) == 1'b1 & ex5_ttype_q[2] == 1'b1 & |(ex6_valid_q) == 1'b0)) ? ex5_t_q[0:2] : 
                          ((|(ex5_valid_q) == 1'b1 & ex5_ttype_q[1] == 1'b1 & |(ex6_valid_q) == 1'b0)) ? 3'b011 : 
                          ((|(ex5_valid_q) == 1'b1 & ex5_ttype_q[0] == 1'b1 & |(ex6_valid_q) == 1'b0)) ? ex5_t_q[0:2] : 
                          ex6_isel_q;
      assign ex6_size_d = ((|(ex5_valid_q) == 1'b1 & ex5_ttype_q[3] == 1'b1 & |(ex6_valid_q) == 1'b0)) ? ex5_rs_is_q[5:8] : 
                            ((|(ex5_valid_q) == 1'b1 & ex5_ttype_q[2] == 1'b1 & |(ex6_valid_q) == 1'b0)) ? 4'b0000 : 
                            ((ex5_valid_q[0] == 1'b1 & ex5_ttype_q[0:1] != 2'b00 & |(ex6_valid_q) == 1'b0)) ? mas6_0_isize : 
                          `ifdef MM_THREADS2
                            ((ex5_valid_q[1] == 1'b1 & ex5_ttype_q[0:1] != 2'b00 & |(ex6_valid_q) == 1'b0)) ? mas6_1_isize : 
                          `endif
                            ex6_size_q;
      assign ex6_size_large = ((ex6_size_q == TLB_PgSize_64KB | ex6_size_q == TLB_PgSize_1MB | ex6_size_q == TLB_PgSize_16MB | ex6_size_q == TLB_PgSize_256MB | ex6_size_q == TLB_PgSize_1GB)) ? 1'b1 : 
                              1'b0;
      assign ex6_gs_d = ((ex5_valid_q[0] == 1'b1 & |(ex5_ttype_q[2:3]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mmucr0_0[2] : 
                          ((ex5_valid_q[0] == 1'b1 & |(ex5_ttype_q[0:1]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mas5_0_sgs : 
                        `ifdef MM_THREADS2
                          ((ex5_valid_q[1] == 1'b1 & |(ex5_ttype_q[2:3]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mmucr0_1[2] : 
                          ((ex5_valid_q[1] == 1'b1 & |(ex5_ttype_q[0:1]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mas5_1_sgs : 
                        `endif
                          ex6_gs_q;
      assign ex6_ts_d = ((ex5_valid_q[0] == 1'b1 & |(ex5_ttype_q[2:3]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mmucr0_0[3] : 
                          ((ex5_valid_q[0] == 1'b1 & |(ex5_ttype_q[0:1]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mas6_0_sas : 
                        `ifdef MM_THREADS2
                          ((ex5_valid_q[1] == 1'b1 & |(ex5_ttype_q[2:3]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mmucr0_1[3] : 
                          ((ex5_valid_q[1] == 1'b1 & |(ex5_ttype_q[0:1]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mas6_1_sas : 
                        `endif
                          ex6_ts_q;
      assign ex6_ind_d = ((ex5_valid_q[0] == 1'b1 & |(ex5_ttype_q[2:3]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? 1'b0 : 
                           ((ex5_valid_q[0] == 1'b1 & |(ex5_ttype_q[0:1]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mas6_0_sind : 
                        `ifdef MM_THREADS2
                           ((ex5_valid_q[1] == 1'b1 & |(ex5_ttype_q[2:3]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? 1'b0 : 
                           ((ex5_valid_q[1] == 1'b1 & |(ex5_ttype_q[0:1]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mas6_1_sind : 
                        `endif
                           ex6_ind_q;
      assign ex6_pid_d = ((ex5_valid_q[0] == 1'b1 & |(ex5_ttype_q[2:3]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mmucr0_0[6:19] : 
                           ((ex5_valid_q[0] == 1'b1 & |(ex5_ttype_q[0:1]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mas6_0_spid : 
                        `ifdef MM_THREADS2
                           ((ex5_valid_q[1] == 1'b1 & |(ex5_ttype_q[2:3]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mmucr0_1[6:19] : 
                           ((ex5_valid_q[1] == 1'b1 & |(ex5_ttype_q[0:1]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mas6_1_spid : 
                        `endif
                           ex6_pid_q;
      assign ex6_lpid_d = ((|(ex5_valid_q) == 1'b1 & |(ex5_ttype_q[2:3]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? lpidr_q : 
                            ((ex5_valid_q[0] == 1'b1 & |(ex5_ttype_q[0:1]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mas5_0_slpid : 
                        `ifdef MM_THREADS2
                            ((ex5_valid_q[1] == 1'b1 & |(ex5_ttype_q[0:1]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? mas5_1_slpid : 
                        `endif
                            ex6_lpid_q;
                            
      assign ex1_itag_d = xu_mm_rf1_itag;
      assign ex2_itag_d = ex1_itag_q;
      assign ex3_itag_d = ex2_itag_q;
      assign ex4_itag_d = ex3_itag_q;
      assign ex5_itag_d = ex4_itag_q;
      assign ex6_itag_d = ((|(ex5_valid_q) == 1'b1 & |(ex5_ttype_q[0:3]) == 1'b1 & |(ex6_valid_q) == 1'b0)) ? ex5_itag_q : 
                          ex6_itag_q;
      assign local_barrier_d = (inv_seq_local_barrier_done == 1'b1) ? (local_barrier_q & (~(ex6_valid_q))) : 
                               (inv_seq_local_barrier_set == 1'b1) ? (ex6_valid_q | local_barrier_q) : 
                               local_barrier_q;
      assign global_barrier_d = (((inv_seq_global_barrier_done == 1'b1 & an_ac_back_inv_q[7] == 1'b1) | inval_snoop_local_reject == 1'b1)) ? {`MM_THREADS{1'b0}} : 
                                (inv_seq_global_barrier_set == 1'b1) ? (ex6_valid_q | global_barrier_q) : 
                                global_barrier_q;
      assign ord_np1_flush_d = (inv_seq_local_done == 1'b1) ? ex6_valid_q : 
                               {`MM_THREADS{1'b0}};
      assign ord_read_done_d = (inv_seq_local_barrier_done == 1'b1) ? (local_barrier_q & ex6_valid_q) : 
                               ((inv_seq_tlbi_load == 1'b1)) ? ex6_valid_q : 
                               (((tlbwe_back_inv_q[`MM_THREADS] == 1'b1 & inv_seq_tlbwe_snoop_done == 1'b1 & cswitch_q[2] == 1'b0) | 
                                 (tlbwe_back_inv_q[`MM_THREADS] == 1'b1 & tlbwe_back_inv_q[`MM_THREADS+1] == 1'b0 & tlb_tag5_write == 1'b0 & cswitch_q[2] == 1'b0))) ? tlbwe_back_inv_q[0:`MM_THREADS-1] : 
                               ((tlb_ctl_ord_type[1] == 1'b1 & (tlbwe_back_inv_valid == 1'b0 | cswitch_q[2] == 1'b1))) ? tlb_ctl_barrier_done : 
                               {`MM_THREADS{1'b0}};
      assign ord_write_done_d = (((tlb_ctl_ord_type[0] == 1'b1 | tlb_ctl_ord_type[2] == 1'b1) & (tlbwe_back_inv_valid == 1'b0 | cswitch_q[2] == 1'b1))) ? tlb_ctl_barrier_done : 
                                {`MM_THREADS{1'b0}};
      assign tlbi_complete_d = (((inv_seq_global_barrier_done == 1'b1 & an_ac_back_inv_q[7] == 1'b1) | inval_snoop_local_reject == 1'b1)) ? global_barrier_q : 
                                {`MM_THREADS{1'b0}};
      assign ex2_rs_pgsize_not_supp = ((ex2_rs_is_q[5:8] == TLB_PgSize_4KB | ex2_rs_is_q[5:8] == TLB_PgSize_64KB | ex2_rs_is_q[5:8] == TLB_PgSize_1MB | ex2_rs_is_q[5:8] == TLB_PgSize_16MB | ex2_rs_is_q[5:8] == TLB_PgSize_1GB)) ? 1'b0 : 
                                      1'b1;
      assign mas6_isize_not_supp[0] = (((mas6_0_isize == TLB_PgSize_4KB | mas6_0_isize == TLB_PgSize_64KB | mas6_0_isize == TLB_PgSize_1MB | mas6_0_isize == TLB_PgSize_16MB | mas6_0_isize == TLB_PgSize_1GB) & mas6_0_sind == 1'b0) | ((mas6_0_isize == TLB_PgSize_1MB | mas6_0_isize == TLB_PgSize_256MB) & mas6_0_sind == 1'b1)) ? 1'b0 : 
                                      1'b1;
`ifdef MM_THREADS2                                      
      assign mas6_isize_not_supp[1] = (((mas6_1_isize == TLB_PgSize_4KB | mas6_1_isize == TLB_PgSize_64KB | mas6_1_isize == TLB_PgSize_1MB | mas6_1_isize == TLB_PgSize_16MB | mas6_1_isize == TLB_PgSize_1GB) & mas6_1_sind == 1'b0) | ((mas6_1_isize == TLB_PgSize_1MB | mas6_1_isize == TLB_PgSize_256MB) & mas6_1_sind == 1'b1)) ? 1'b0 : 
                                      1'b1;
`endif

      assign mas5_slpid_neq_lpidr[0] = ~(mas5_0_slpid == lpidr_q);
`ifdef MM_THREADS2                                      
      assign mas5_slpid_neq_lpidr[1] = ~(mas5_1_slpid == lpidr_q);
`endif

      assign ex3_illeg_instr_d = ( ex2_valid_q & mas6_isize_not_supp & {`MM_THREADS{ex2_ttype_q[1] & ex2_hv_state}} ) | 
                                   ( ex2_valid_q & mas6_isize_not_supp & ({`MM_THREADS{ex2_ttype_q[0] & (ex2_t_q == 3'b011)}} & {`MM_THREADS{ex2_hv_state | (ex2_priv_state & (~ex2_dgtmi_state))}}) ) | 
                                   ( ex2_valid_q & {`MM_THREADS{ex2_ttype_q[3] & ex2_hv_state & ex2_rs_pgsize_not_supp}} ) | 
                                   ( ex2_valid_q & {`MM_THREADS{ex2_ttype_q[2] & ex2_hv_state & ex2_t_q[0] & mmucr1_q[pos_ictid] & mmucr1_q[pos_dctid]}} ) | 
                                   (tlb_ctl_ex2_illeg_instr);
                                   
      assign ex4_illeg_instr_d = ex3_illeg_instr_q & (~(ex3_flush_req_q));
      assign ex5_illeg_instr_d = ex4_illeg_instr_q;
      assign ex6_illeg_instr_d = ex5_illeg_instr_q;
      assign ex7_illeg_instr_d = ex6_illeg_instr_q | tlb_ctl_ex6_illeg_instr;
      
      assign ex3_ivax_lpid_reject_d = ( ex2_valid_q & mas5_slpid_neq_lpidr & ~mas6_isize_not_supp & {`MM_THREADS{ex2_ttype_q[1] & ex2_hv_state & 
                                              (xu_mm_ccr2_notlb_q[0] == MMU_Mode_Value) & mmucr1_q[pos_tlbi_rej]}} ); 

      assign ex4_ivax_lpid_reject_d = (ex3_ivax_lpid_reject_q & ~ex3_illeg_instr_q & ~ex3_flush_req_q & ~xu_ex3_flush);
                                
      
      always @(inv_seq_q or xu_mm_lmq_stq_empty or iu_mm_lmq_empty or hold_ack_q or lsu_tokens_q or xu_mm_ccr2_notlb_q[0] or snoop_ack_q or ex6_valid_q or ex6_ttype_q[0:3] or ex6_ind_q or ex6_isel_q or bus_snoop_seq_ready or mmucsr0_tlb0fi or tlbwe_back_inv_q[`MM_THREADS+1] or an_ac_back_inv_q[6] or an_ac_back_inv_addr_q[54:55] or htw_lsu_req_valid or lsu_req_q or cswitch_q[0:1] or cswitch_q[3] or power_managed_q[0] or power_managed_q[2] or power_managed_q[3])
      begin: Inv_Sequencer
         inv_seq_idle <= 1'b0;
         inv_seq_snoop_inprogress <= 1'b0;
         inv_seq_local_inprogress <= 1'b0;
         inv_seq_local_barrier_set <= 1'b0;
         inv_seq_global_barrier_set <= 1'b0;
         inv_seq_local_barrier_done <= 1'b0;
         inv_seq_global_barrier_done <= 1'b0;
         inv_seq_snoop_done <= 1'b0;
         inv_seq_local_done <= 1'b0;
         inv_seq_tlbi_load <= 1'b0;
         inv_seq_tlbi_complete <= 1'b0;
         inv_seq_htw_load <= 1'b0;
         htw_lsu_req_taken_sig <= 1'b0;
         inv_seq_hold_req <= {`MM_THREADS{1'b0}};
         inv_seq_hold_done <= {`MM_THREADS{1'b0}};
         inv_seq_tlb_snoop_val <= 1'b0;
         inv_seq_ierat_snoop_val <= 1'b0;
         inv_seq_derat_snoop_val <= 1'b0;
         inv_seq_tlb0fi_inprogress <= 1'b0;
         inv_seq_tlb0fi_done <= 1'b0;
         inv_seq_tlbwe_snoop_done <= 1'b0;
         inv_seq_tlbwe_inprogress <= 1'b0;

         case (inv_seq_q)
         
            InvSeq_Idle :
               begin
                  inv_seq_idle <= 1'b1;
                  if (bus_snoop_seq_ready == 1'b1)
                  begin
                     inv_seq_snoop_inprogress <= 1'b1;
                     inv_seq_hold_req <= {`MM_THREADS{1'b1}};
                     inv_seq_d <= InvSeq_Stg8;
                  end
                  else if (htw_lsu_req_valid == 1'b1)
                     inv_seq_d <= InvSeq_Stg31;
                  else if (|(ex6_valid_q) == 1'b1 & (ex6_ttype_q[1] == 1'b1 | ex6_ttype_q[3] == 1'b1))
                  begin
                     inv_seq_local_inprogress <= 1'b1;
                     inv_seq_global_barrier_set <= 1'b1;
                     inv_seq_d <= InvSeq_Stg1;
                  end
                  else if (|(ex6_valid_q) == 1'b1 & (ex6_ttype_q[0] == 1'b1 | ex6_ttype_q[2] == 1'b1))
                  begin
                     inv_seq_hold_req <= {`MM_THREADS{1'b1}};
                     inv_seq_local_inprogress <= 1'b1;
                     inv_seq_local_barrier_set <= 1'b1;
                     inv_seq_d <= InvSeq_Stg2;
                  end
                  else if (mmucsr0_tlb0fi == 1'b1)
                  begin
                     inv_seq_hold_req <= {`MM_THREADS{1'b1}};
                     inv_seq_tlb0fi_inprogress <= 1'b1;
                     inv_seq_d <= InvSeq_Stg16;
                  end
                  else if (tlbwe_back_inv_q[`MM_THREADS+1] == 1'b1)
                  begin
                     inv_seq_hold_req <= {`MM_THREADS{1'b1}};
                     inv_seq_tlbwe_inprogress <= 1'b1;
                     inv_seq_d <= InvSeq_Stg24;
                  end
                  else
                     inv_seq_d <= InvSeq_Idle;
               end
               
            InvSeq_Stg1 :
               begin
                  inv_seq_local_inprogress <= 1'b1;
                  if (lsu_tokens_q != 2'b00 & (xu_mm_lmq_stq_empty == 1'b1 | cswitch_q[0] == 1'b1))
                  begin
                     inv_seq_tlbi_load <= 1'b1;
                     inv_seq_local_done <= 1'b1;
                     inv_seq_d <= InvSeq_Idle;
                  end
                  else
                     inv_seq_d <= InvSeq_Stg1;
               end
               
            InvSeq_Stg2 :
               begin
                  inv_seq_local_inprogress <= 1'b1;
                  if (&(hold_ack_q | ex6_valid_q) == 1'b1)
                     inv_seq_d <= InvSeq_Stg3;
                  else if (htw_lsu_req_valid == 1'b1)
                     inv_seq_d <= InvSeq_Stg23;
                  else
                     inv_seq_d <= InvSeq_Stg2;
               end
            
            InvSeq_Stg3 :
               begin
                  inv_seq_local_inprogress <= 1'b1;
                  if (iu_mm_lmq_empty == 1'b1 & xu_mm_lmq_stq_empty == 1'b1 & xu_mm_ccr2_notlb_q[0] == MMU_Mode_Value & ex6_ttype_q[0] == 1'b1)
                     inv_seq_d <= InvSeq_Stg4;
                  else if (iu_mm_lmq_empty == 1'b1 & xu_mm_lmq_stq_empty == 1'b1)
                     inv_seq_d <= InvSeq_Stg6;
                  else if (htw_lsu_req_valid == 1'b1)
                     inv_seq_d <= InvSeq_Stg23;
                  else
                     inv_seq_d <= InvSeq_Stg3;
               end
            
            InvSeq_Stg4 :
               begin
                  inv_seq_local_inprogress <= 1'b1;
                  inv_seq_tlb_snoop_val <= 1'b1;
                  inv_seq_d <= InvSeq_Stg5;
               end
            
            InvSeq_Stg5 :
               begin
                  inv_seq_local_inprogress <= 1'b1;
                  if (snoop_ack_q[2] == 1'b1)
                     inv_seq_d <= InvSeq_Stg6;
                  else
                     inv_seq_d <= InvSeq_Stg5;
               end
            
            InvSeq_Stg6 :
               begin
                  inv_seq_local_inprogress <= 1'b1;
                  if ( (~(ex6_ind_q & (ex6_isel_q == 3'b011))) == 1'b1 )
                  begin
                    inv_seq_ierat_snoop_val <= 1'b1;
                    inv_seq_derat_snoop_val <= 1'b1;
                  end
                  inv_seq_d <= InvSeq_Stg7;
               end
            
            InvSeq_Stg7 :
               begin
                  inv_seq_local_inprogress <= 1'b1;
                  if (snoop_ack_q[0:1] == 2'b11 | (ex6_ind_q & (ex6_isel_q == 3'b011)) == 1'b1)
                  begin
                     inv_seq_local_done <= 1'b1;
                     inv_seq_local_barrier_done <= 1'b1;
                     inv_seq_hold_done <= {`MM_THREADS{1'b1}};
                     inv_seq_d <= InvSeq_Idle;
                  end
                  else
                     inv_seq_d <= InvSeq_Stg7;
               end
            
            InvSeq_Stg8 :
               begin
                  inv_seq_snoop_inprogress <= 1'b1;
                  if (htw_lsu_req_valid == 1'b1)
                     inv_seq_d <= InvSeq_Stg28;
                  else
                     inv_seq_d <= InvSeq_Stg9;
               end
            
            InvSeq_Stg9 :
               begin
                  inv_seq_snoop_inprogress <= 1'b1;
                  inv_seq_d <= InvSeq_Stg10;
               end
            
            InvSeq_Stg10 :
               begin
                  inv_seq_snoop_inprogress <= 1'b1;
                  if (power_managed_q[0] == 1'b1 & power_managed_q[3] == 1'b1)
                     inv_seq_d <= InvSeq_Stg14;
                  else if ((iu_mm_lmq_empty == 1'b1 | cswitch_q[3] == 1'b1 | power_managed_q[0] == 1'b1) & (xu_mm_lmq_stq_empty == 1'b1 | cswitch_q[1] == 1'b1 | (power_managed_q[0] == 1'b1 & power_managed_q[2] == 1'b1)) & xu_mm_ccr2_notlb_q[0] == MMU_Mode_Value)
                     inv_seq_d <= InvSeq_Stg11;
                  else if ((iu_mm_lmq_empty == 1'b1 | cswitch_q[3] == 1'b1 | power_managed_q[0] == 1'b1) & 
                             (xu_mm_lmq_stq_empty == 1'b1 | cswitch_q[1] == 1'b1 | (power_managed_q[0] == 1'b1 & power_managed_q[2] == 1'b1)))
                     inv_seq_d <= InvSeq_Stg13;
                  else if (htw_lsu_req_valid == 1'b1)
                     inv_seq_d <= InvSeq_Stg28;
                  else
                     inv_seq_d <= InvSeq_Stg10;
               end
            
            InvSeq_Stg11 :
               begin
                  inv_seq_snoop_inprogress <= 1'b1;
                  inv_seq_tlb_snoop_val <= 1'b1;
                  inv_seq_d <= InvSeq_Stg12;
               end
            
            InvSeq_Stg12 :
               begin
                  inv_seq_snoop_inprogress <= 1'b1;
                  if (snoop_ack_q[2] == 1'b1 | (power_managed_q[0] == 1'b1 & power_managed_q[2] == 1'b1))
                     inv_seq_d <= InvSeq_Stg13;
                  else
                     inv_seq_d <= InvSeq_Stg12;
               end
            
            InvSeq_Stg13 :
               begin
                  inv_seq_snoop_inprogress <= 1'b1;
                  if ( (~(an_ac_back_inv_q[6] & (an_ac_back_inv_addr_q[54:55] == 2'b11))) == 1'b1 )
                  begin
                    inv_seq_ierat_snoop_val <= 1'b1;
                    inv_seq_derat_snoop_val <= 1'b1;
                  end
                  inv_seq_d <= InvSeq_Stg14;
               end
            
            InvSeq_Stg14 :
               begin
                  inv_seq_snoop_inprogress <= 1'b1;
                  if (power_managed_q[0] == 1'b1 & power_managed_q[2] == 1'b1)
                  begin
                     inv_seq_tlbi_complete <= 1'b1;  
                     inv_seq_d <= InvSeq_Stg15;
                  end
                  else if (lsu_tokens_q != 2'b00 & (snoop_ack_q[0:1] == 2'b11 | (an_ac_back_inv_q[6] & (an_ac_back_inv_addr_q[54:55] == 2'b11)) == 1'b1))
                  begin
                     inv_seq_tlbi_complete <= 1'b1;  
                     inv_seq_d <= InvSeq_Stg15;
                  end
                  else
                     inv_seq_d <= InvSeq_Stg14;
               end
            
            InvSeq_Stg15 :
               if ((|(lsu_req_q) == 1'b0 & lsu_tokens_q != 2'b00) | (power_managed_q[0] == 1'b1 & power_managed_q[2] == 1'b1))
               begin
                  inv_seq_snoop_inprogress <= 1'b0;
                  inv_seq_snoop_done <= 1'b1;
                  inv_seq_hold_done <= {`MM_THREADS{1'b1}};
                  inv_seq_global_barrier_done <= 1'b1;
                  inv_seq_d <= InvSeq_Idle;  
               end
               else
               begin
                  inv_seq_snoop_inprogress <= 1'b1;
                  inv_seq_d <= InvSeq_Stg15;
               end
            
            InvSeq_Stg16 :
               begin
                  inv_seq_tlb0fi_inprogress <= 1'b1;
                  if (&(hold_ack_q) == 1'b1)
                     inv_seq_d <= InvSeq_Stg17;
                  else if (htw_lsu_req_valid == 1'b1)
                     inv_seq_d <= InvSeq_Stg22;
                  else
                     inv_seq_d <= InvSeq_Stg16;
               end
            
            InvSeq_Stg17 :
               begin
                  inv_seq_tlb0fi_inprogress <= 1'b1;
                  if (iu_mm_lmq_empty == 1'b1 & xu_mm_lmq_stq_empty == 1'b1 & xu_mm_ccr2_notlb_q[0] == MMU_Mode_Value)
                     inv_seq_d <= InvSeq_Stg18;
                  else if (iu_mm_lmq_empty == 1'b1 & xu_mm_lmq_stq_empty == 1'b1)   
                     inv_seq_d <= InvSeq_Stg20;
                  else if (htw_lsu_req_valid == 1'b1)
                     inv_seq_d <= InvSeq_Stg22;
                  else
                     inv_seq_d <= InvSeq_Stg17;   
               end
            
            InvSeq_Stg18 :
               begin
                  inv_seq_tlb0fi_inprogress <= 1'b1;
                  inv_seq_tlb_snoop_val <= 1'b1;
                  inv_seq_d <= InvSeq_Stg19;
               end
            
            InvSeq_Stg19 :
               begin
                  inv_seq_tlb0fi_inprogress <= 1'b1;
                  if (snoop_ack_q[2] == 1'b1)
                     inv_seq_d <= InvSeq_Stg20;
                  else
                     inv_seq_d <= InvSeq_Stg19;
               end
            
            InvSeq_Stg20 :
               begin
                  inv_seq_tlb0fi_inprogress <= 1'b1;
                  inv_seq_ierat_snoop_val <= 1'b1;
                  inv_seq_derat_snoop_val <= 1'b1;
                  inv_seq_d <= InvSeq_Stg21;
               end
            
            InvSeq_Stg21 :
               if (snoop_ack_q[0:1] == 2'b11)
               begin
                  inv_seq_tlb0fi_inprogress <= 1'b0;
                  inv_seq_tlb0fi_done <= 1'b1;
                  inv_seq_hold_done <= {`MM_THREADS{1'b1}};
                  inv_seq_d <= InvSeq_Idle;  
               end
               else
               begin
                  inv_seq_tlb0fi_inprogress <= 1'b1;
                  inv_seq_d <= InvSeq_Stg21;
               end
               
            InvSeq_Stg22 :
               begin
                  inv_seq_tlb0fi_inprogress <= 1'b1;
                  if (lsu_tokens_q != 2'b00)
                  begin
                     inv_seq_htw_load <= 1'b1;
                     htw_lsu_req_taken_sig <= 1'b1;
                     inv_seq_d <= InvSeq_Stg16;  
                  end
                  else
                     inv_seq_d <= InvSeq_Stg22; 
               end
            
            InvSeq_Stg23 :
               begin
                  inv_seq_local_inprogress <= 1'b1;
                  if (lsu_tokens_q != 2'b00)
                  begin
                     inv_seq_htw_load <= 1'b1;
                     htw_lsu_req_taken_sig <= 1'b1;
                     inv_seq_d <= InvSeq_Stg2;  
                  end
                  else
                     inv_seq_d <= InvSeq_Stg23; 
               end
            
            InvSeq_Stg24 :
               begin
                  inv_seq_tlbwe_inprogress <= 1'b1;
                  if (&(hold_ack_q | tlbwe_back_inv_q[0:`MM_THREADS-1]) == 1'b1)
                     inv_seq_d <= InvSeq_Stg25;
                  else if (htw_lsu_req_valid == 1'b1)
                     inv_seq_d <= InvSeq_Stg29;
                  else
                     inv_seq_d <= InvSeq_Stg24;
               end
            
            InvSeq_Stg25 :
               begin
                  inv_seq_tlbwe_inprogress <= 1'b1;
                  if (iu_mm_lmq_empty == 1'b1 & xu_mm_lmq_stq_empty == 1'b1)
                     inv_seq_d <= InvSeq_Stg26;
                  else if (htw_lsu_req_valid == 1'b1)
                     inv_seq_d <= InvSeq_Stg29;
                  else
                     inv_seq_d <= InvSeq_Stg25; 
               end
            
            InvSeq_Stg26 :
               begin
                  inv_seq_tlbwe_inprogress <= 1'b1;
                  inv_seq_ierat_snoop_val <= 1'b1;
                  inv_seq_derat_snoop_val <= 1'b1;
                  inv_seq_d <= InvSeq_Stg27;
               end
            
            InvSeq_Stg27 :
               if (snoop_ack_q[0:1] == 2'b11)
               begin
                  inv_seq_tlbwe_inprogress <= 1'b0;
                  inv_seq_tlbwe_snoop_done <= 1'b1;
                  inv_seq_hold_done <= {`MM_THREADS{1'b1}};
                  inv_seq_d <= InvSeq_Idle;
               end
               else
               begin
                  inv_seq_tlbwe_inprogress <= 1'b1;
                  inv_seq_d <= InvSeq_Stg27;
               end

            InvSeq_Stg28 :
               begin
                  inv_seq_snoop_inprogress <= 1'b1;
                  if (lsu_tokens_q != 2'b00)  
                  begin
                     inv_seq_htw_load <= 1'b1;
                     htw_lsu_req_taken_sig <= 1'b1;
                     inv_seq_d <= InvSeq_Stg8;  
                  end
                  else
                     inv_seq_d <= InvSeq_Stg28; 
               end
               
            InvSeq_Stg29 :
               begin
                  inv_seq_tlbwe_inprogress <= 1'b1;
                  if (lsu_tokens_q != 2'b00)  
                  begin
                     inv_seq_htw_load <= 1'b1;
                     htw_lsu_req_taken_sig <= 1'b1;
                     inv_seq_d <= InvSeq_Stg24;  
                  end
                  else
                     inv_seq_d <= InvSeq_Stg29; 
               end
            
            InvSeq_Stg31 :
               if (lsu_tokens_q != 2'b00)  
               begin
                  inv_seq_htw_load <= 1'b1;
                  htw_lsu_req_taken_sig <= 1'b1;
                  inv_seq_d <= InvSeq_Idle;
               end
               else
                  inv_seq_d <= InvSeq_Stg31; 
            default :
               inv_seq_d <= InvSeq_Idle;
         endcase
      end
      
      assign hold_req_d = inv_seq_hold_req;
      assign hold_done_d = inv_seq_hold_done;
      assign iu_flush_req_d[0] = ((~(ex6_valid_q[0])) & inv_seq_local_barrier_set) | ((~(tlbwe_back_inv_q[0])) & inv_seq_hold_req[0] & inv_seq_tlbwe_inprogress) | (inv_seq_hold_req[0] & inv_seq_tlb0fi_inprogress);
`ifdef MM_THREADS2
      assign iu_flush_req_d[1] = ((~(ex6_valid_q[1])) & inv_seq_local_barrier_set) | ((~(tlbwe_back_inv_q[1])) & inv_seq_hold_req[1] & inv_seq_tlbwe_inprogress) | (inv_seq_hold_req[1] & inv_seq_tlb0fi_inprogress);
`endif
      assign inv_seq_inprogress_d[0] = inv_seq_snoop_inprogress;
      assign inv_seq_inprogress_d[1] = inv_seq_snoop_inprogress;
      assign inv_seq_inprogress_d[2] = inv_seq_tlb0fi_inprogress;
      assign inv_seq_inprogress_d[3] = inv_seq_tlb0fi_inprogress;
      assign inv_seq_inprogress_d[4] = inv_seq_tlbwe_inprogress;
      assign inv_seq_inprogress_d[5] = inv_seq_tlbwe_inprogress;
      assign inv_seq_snoop_inprogress_q[0] = inv_seq_inprogress_q[0];
      assign inv_seq_snoop_inprogress_q[1] = inv_seq_inprogress_q[1];
      assign inv_seq_tlb0fi_inprogress_q[0] = inv_seq_inprogress_q[2];
      assign inv_seq_tlb0fi_inprogress_q[1] = inv_seq_inprogress_q[3];
      assign inv_seq_tlbwe_inprogress_q[0] = inv_seq_inprogress_q[4];
      assign inv_seq_tlbwe_inprogress_q[1] = inv_seq_inprogress_q[5];
      assign hold_ack_d[0] = ((inv_seq_local_done == 1'b1 | inv_seq_tlb0fi_done == 1'b1 | inv_seq_tlbwe_snoop_done == 1'b1)) ? 1'b0 : 
                             (hold_ack_q[0] == 1'b0) ? iu_mm_hold_ack[0] : 
                             hold_ack_q[0];
`ifdef MM_THREADS2
      assign hold_ack_d[1] = ((inv_seq_local_done == 1'b1 | inv_seq_tlb0fi_done == 1'b1 | inv_seq_tlbwe_snoop_done == 1'b1)) ? 1'b0 : 
                             (hold_ack_q[1] == 1'b0) ? iu_mm_hold_ack[1] : 
                             hold_ack_q[1];
`endif
      
      always @(bus_snoop_seq_q or inval_snoop_forme or bus_snoop_hold_ack_q or inv_seq_snoop_done or power_managed_q)
      begin: Bus_Snoop_Sequencer
         bus_snoop_seq_idle <= 1'b0;
         bus_snoop_seq_hold_req <= 1'b0;
         bus_snoop_seq_ready <= 1'b0;
         bus_snoop_seq_done <= 1'b0;
         case (bus_snoop_seq_q)
            SnoopSeq_Idle :
               if (inval_snoop_forme == 1'b1)
               begin
                  bus_snoop_seq_idle <= 1'b0;
                  bus_snoop_seq_hold_req <= 1'b1;
                  bus_snoop_seq_d <= SnoopSeq_Stg1;
               end
               else
               begin
                  bus_snoop_seq_idle <= 1'b1;
                  bus_snoop_seq_d <= SnoopSeq_Idle;
               end
            SnoopSeq_Stg1 :
               if (&(bus_snoop_hold_ack_q) == 1'b1 | (power_managed_q[0] == 1'b1 & power_managed_q[2] == 1'b1))
                  bus_snoop_seq_d <= SnoopSeq_Stg3;
               else
                  bus_snoop_seq_d <= SnoopSeq_Stg1;
            
            SnoopSeq_Stg3 :
               begin
                  bus_snoop_seq_ready <= 1'b1;
                  if (inv_seq_snoop_done == 1'b1)
                     bus_snoop_seq_d <= SnoopSeq_Stg2;
                  else
                     bus_snoop_seq_d <= SnoopSeq_Stg3;
               end
            
            SnoopSeq_Stg2 :
               begin
                  bus_snoop_seq_done <= 1'b1;
                  bus_snoop_seq_d <= SnoopSeq_Idle;
               end
            
            default :
               bus_snoop_seq_d <= SnoopSeq_Idle;
         endcase
      end
      assign bus_snoop_hold_req_d[0] = bus_snoop_seq_hold_req;
      assign bus_snoop_hold_done_d[0] = bus_snoop_seq_done;
      assign bus_snoop_hold_ack_d[0] = ((inv_seq_snoop_done == 1'b1)) ? 1'b0 : 
                                       (bus_snoop_hold_ack_q[0] == 1'b0) ? iu_mm_bus_snoop_hold_ack[0] : 
                                       bus_snoop_hold_ack_q[0];
`ifdef MM_THREADS2
      assign bus_snoop_hold_req_d[1] = bus_snoop_seq_hold_req;
      assign bus_snoop_hold_done_d[1] = bus_snoop_seq_done;
      assign bus_snoop_hold_ack_d[1] = ((inv_seq_snoop_done == 1'b1)) ? 1'b0 : 
                                       (bus_snoop_hold_ack_q[1] == 1'b0) ? iu_mm_bus_snoop_hold_ack[1] : 
                                       bus_snoop_hold_ack_q[1];
`endif
      assign mm_iu_hold_req = hold_req_q;
      assign mm_iu_hold_done = hold_done_q;
      assign mm_iu_flush_req = iu_flush_req_q;
      assign mm_iu_bus_snoop_hold_req = bus_snoop_hold_req_q;
      assign mm_iu_bus_snoop_hold_done = bus_snoop_hold_done_q;
      assign mm_iu_tlbi_complete = tlbi_complete_q;
      assign mm_xu_illeg_instr = ex7_illeg_instr_q;
      assign mm_xu_illeg_instr_ored = |(ex7_illeg_instr_q);
      assign mm_xu_ex3_flush_req = ex3_flush_req_q;
      assign mm_xu_local_snoop_reject = ex4_ivax_lpid_reject_q;
      assign mmq_inval_tlb0fi_done = inv_seq_tlb0fi_done;
      assign mm_xu_ord_n_flush_req = ex3_flush_req_q;
      assign mm_xu_ord_np1_flush_req = ord_np1_flush_q;
      assign mm_xu_ord_read_done = ord_read_done_q;
      assign mm_xu_ord_write_done = ord_write_done_q;
      assign mm_xu_ord_n_flush_req_ored = |(ex3_flush_req_q);
      assign mm_xu_ord_np1_flush_req_ored = |(ord_np1_flush_q);
      assign mm_xu_ord_read_done_ored = |(ord_read_done_q);
      assign mm_xu_ord_write_done_ored = |(ord_write_done_q);
      assign mm_xu_itag_d = ((|(ex2_ttype_q[0:3]) == 1'b1 & (inv_seq_idle == 1'b0 | (|(ex3_valid_q) == 1'b1 & |(ex3_ttype_q[0:3]) == 1'b1) | (|(ex4_valid_q) == 1'b1 & |(ex4_ttype_q[0:3]) == 1'b1) | (|(ex5_valid_q) == 1'b1 & |(ex5_ttype_q[0:3]) == 1'b1) | (|(ex6_valid_q) == 1'b1 & |(ex6_ttype_q[0:3]) == 1'b1)))) ? ex2_itag_q : 
                            (|(tlb_ctl_ex2_flush_req) == 1'b1) ? tlb_ctl_ex2_itag : 
                            ((tlbwe_back_inv_q[`MM_THREADS] == 1'b1 & cswitch_q[2] == 1'b0)) ? mm_xu_itag_q : 
                            tlb_tag4_itag;
      assign mm_xu_itag = mm_xu_itag_q;
      
      assign inval_snoop_forme = ( an_ac_back_inv_q[2] & an_ac_back_inv_q[3] & (~(power_managed_q[0] & power_managed_q[1])) & (xu_mm_ccr2_notlb_q[0] == MMU_Mode_Value) & ~mmucr1_q[pos_tlbi_rej] ) | 
                                   ( an_ac_back_inv_q[2] & an_ac_back_inv_q[3] & (~(power_managed_q[0] & power_managed_q[1])) & (an_ac_back_inv_lpar_id_q == lpidr_q) );

      assign inval_snoop_local_reject = ( an_ac_back_inv_q[2] & an_ac_back_inv_q[3] & (~(power_managed_q[0] & power_managed_q[1])) & an_ac_back_inv_q[7] & 
                                            (~(an_ac_back_inv_lpar_id_q == lpidr_q)) & ((xu_mm_ccr2_notlb_q[0] == ERAT_Mode_Value) | mmucr1_q[pos_tlbi_rej]) );

      assign local_snoop_reject_d = (global_barrier_q & {`MM_THREADS{inval_snoop_local_reject}}) | 
                                       (ex3_ivax_lpid_reject_q & ~ex3_illeg_instr_q & ~ex3_flush_req_q);

      assign local_snoop_reject_ored = |(local_snoop_reject_q);
      
      
      tri_direct_err_rpt #(.WIDTH(1)) tlb_snoop_reject_err_rpt(
         .vd(vdd),
         .gd(gnd),
         .err_in(local_snoop_reject_ored),
         .err_out(mm_pc_local_snoop_reject_ored)
      );
      
      assign an_ac_back_inv_d[0] = an_ac_back_inv;
      assign an_ac_back_inv_d[1] = an_ac_back_inv_target;
      assign an_ac_back_inv_d[2] = (inval_snoop_forme == 1'b0) ? an_ac_back_inv_q[0] : 
                                   (inv_seq_snoop_done == 1'b1) ? 1'b0 : 
                                   an_ac_back_inv_q[2];
      assign an_ac_back_inv_d[3] = (inval_snoop_forme == 1'b0) ? an_ac_back_inv_q[1] : 
                                   (inv_seq_snoop_done == 1'b1) ? 1'b0 : 
                                   an_ac_back_inv_q[3];
      assign an_ac_back_inv_d[4] = (inval_snoop_forme == 1'b0) ? an_ac_back_inv_lbit : 
                                   an_ac_back_inv_q[4];
      assign an_ac_back_inv_d[5] = (inval_snoop_forme == 1'b0) ? an_ac_back_inv_gs : 
                                   an_ac_back_inv_q[5];
      assign an_ac_back_inv_d[6] = (inval_snoop_forme == 1'b0) ? an_ac_back_inv_ind : 
                                   an_ac_back_inv_q[6];
      assign an_ac_back_inv_d[7] = (inval_snoop_forme == 1'b0) ? an_ac_back_inv_local : 
                                   an_ac_back_inv_q[7];
                                   
      assign an_ac_back_inv_d[8] = ( an_ac_back_inv_q[2] & an_ac_back_inv_q[3] & (~(an_ac_back_inv_lpar_id_q == lpidr_q)) & ((xu_mm_ccr2_notlb_q[0] == ERAT_Mode_Value) | mmucr1_q[pos_tlbi_rej]) ) |
                                     ( an_ac_back_inv_q[2] & an_ac_back_inv_q[3] & power_managed_q[0] & power_managed_q[1] );
                                     
      assign an_ac_back_inv_addr_d = (inval_snoop_forme == 1'b0) ? an_ac_back_inv_addr : 
                                     an_ac_back_inv_addr_q;
      assign an_ac_back_inv_lpar_id_d = (inval_snoop_forme == 1'b0) ? an_ac_back_inv_lpar_id : 
                                        an_ac_back_inv_lpar_id_q;
      assign ac_an_back_inv_reject = an_ac_back_inv_q[8];
      assign tlbwe_back_inv_d[0:`MM_THREADS-1] = (tlbwe_back_inv_q[`MM_THREADS] == 1'b0) ? tlbwe_back_inv_thdid : 
                                     ((tlbwe_back_inv_q[`MM_THREADS] == 1'b1 & tlbwe_back_inv_q[`MM_THREADS+1] == 1'b0 & tlb_tag5_write == 1'b0)) ? {`MM_THREADS{1'b0}} : 
                                     (inv_seq_tlbwe_snoop_done == 1'b1) ? {`MM_THREADS{1'b0}} : 
                                     tlbwe_back_inv_q[0:`MM_THREADS-1];
      assign tlbwe_back_inv_d[`MM_THREADS] = (tlbwe_back_inv_q[`MM_THREADS] == 1'b0) ? tlbwe_back_inv_valid : 
                                               ((tlbwe_back_inv_q[`MM_THREADS] == 1'b1 & tlbwe_back_inv_q[`MM_THREADS+1] == 1'b0 & tlb_tag5_write == 1'b0)) ? 1'b0 : 
                                               (inv_seq_tlbwe_snoop_done == 1'b1) ? 1'b0 : 
                                                tlbwe_back_inv_q[`MM_THREADS];
      assign tlbwe_back_inv_d[`MM_THREADS+1] = (tlbwe_back_inv_q[`MM_THREADS+1] == 1'b0) ? (tlbwe_back_inv_q[`MM_THREADS] & tlb_tag5_write) : 
                                                 (inv_seq_tlbwe_snoop_done == 1'b1) ? 1'b0 : 
                                                 tlbwe_back_inv_q[`MM_THREADS+1];
      assign tlbwe_back_inv_addr_d = (tlbwe_back_inv_q[`MM_THREADS] == 1'b0) ? tlbwe_back_inv_addr : 
                                        tlbwe_back_inv_addr_q;
      assign tlbwe_back_inv_attr_d = (tlbwe_back_inv_q[`MM_THREADS] == 1'b0) ? tlbwe_back_inv_attr : 
                                     tlbwe_back_inv_attr_q;
      assign tlbwe_back_inv_pending = |(tlbwe_back_inv_q[`MM_THREADS:`MM_THREADS+1]);
      assign htw_lsu_req_taken = htw_lsu_req_taken_sig;
      assign lsu_tokens_d = ((xu_mm_lsu_token == 1'b1 & lsu_tokens_q == 2'b00)) ? 2'b01 : 
                            ((xu_mm_lsu_token == 1'b1 & lsu_tokens_q == 2'b01)) ? 2'b10 : 
                            ((xu_mm_lsu_token == 1'b1 & lsu_tokens_q == 2'b10)) ? 2'b11 : 
                            ((|(lsu_req_q) == 1'b1 & lsu_tokens_q == 2'b11)) ? 2'b10 : 
                            ((|(lsu_req_q) == 1'b1 & lsu_tokens_q == 2'b10)) ? 2'b01 : 
                            ((|(lsu_req_q) == 1'b1 & lsu_tokens_q == 2'b01)) ? 2'b00 : 
                            lsu_tokens_q;
      assign lsu_req_d = (lsu_tokens_q == 2'b00) ? {`MM_THREADS{1'b0}} : 
                      `ifdef MM_THREADS2
                         (inv_seq_tlbi_complete == 1'b1) ? {1'b1, {`MM_THREADS-1{1'b0}}} : 
                      `else
                         (inv_seq_tlbi_complete == 1'b1) ? {1'b1} : 
                      `endif
                         (inv_seq_htw_load == 1'b1) ? htw_lsu_thdid : 
                         (inv_seq_tlbi_load == 1'b1) ? ex6_valid_q : 
                         {`MM_THREADS{1'b0}};
      assign lsu_ttype_d = (inv_seq_tlbi_complete == 1'b1) ? 2'b01 : 
                           (inv_seq_htw_load == 1'b1) ? htw_lsu_ttype : 
                           {2'b0};
      assign lsu_wimge_d = (inv_seq_htw_load == 1'b1) ? htw_lsu_wimge : 
                           {5'b0};
      assign lsu_ubits_d = (inv_seq_htw_load == 1'b1) ? htw_lsu_u : 
                           {4'b0};
      assign lsu_addr_d[64 - `REAL_ADDR_WIDTH:64 - `REAL_ADDR_WIDTH + 4] = (inv_seq_htw_load == 1'b1) ? htw_lsu_addr[64 - `REAL_ADDR_WIDTH:64 - `REAL_ADDR_WIDTH + 4] : 
                                                                         (inv_seq_tlbi_load == 1'b1) ? ex6_pid_q[`PID_WIDTH - 13:`PID_WIDTH - 9] : 
                                                                         lsu_addr_q[64 - `REAL_ADDR_WIDTH:64 - `REAL_ADDR_WIDTH + 4];
      assign lsu_addr_d[64 - `REAL_ADDR_WIDTH + 5:33] = (inv_seq_htw_load == 1'b1) ? htw_lsu_addr[64 - `REAL_ADDR_WIDTH + 5:33] : 
                                                       (inv_seq_tlbi_load == 1'b1) ? ex3_ea_q[64 - `REAL_ADDR_WIDTH + 5:33] : 
                                                       lsu_addr_q[64 - `REAL_ADDR_WIDTH + 5:33];
      assign lsu_addr_d[34:35] = (inv_seq_htw_load == 1'b1) ? htw_lsu_addr[34:35] : 
                                 ((inv_seq_tlbi_load == 1'b1 & mmucr1[pos_tlbi_msb] == 1'b1 & ex6_size_q == TLB_PgSize_1GB)) ? ex3_ea_q[13:14] : 
                                 ((inv_seq_tlbi_load == 1'b1 & mmucr1[pos_tlbi_msb] == 1'b0 & ex6_size_q == TLB_PgSize_1GB)) ? ex3_ea_q[17:18] : 
                                 (inv_seq_tlbi_load == 1'b1) ? ex3_ea_q[34:35] : 
                                 lsu_addr_q[34:35];
      assign lsu_addr_d[36:39] = (inv_seq_htw_load == 1'b1) ? htw_lsu_addr[36:39] : 
                                 ((inv_seq_tlbi_load == 1'b1 & mmucr1[pos_tlbi_msb] == 1'b1 & (ex6_size_q == TLB_PgSize_1GB | ex6_size_q == TLB_PgSize_256MB))) ? ex3_ea_q[15:18] : 
                                 ((inv_seq_tlbi_load == 1'b1 & mmucr1[pos_tlbi_msb] == 1'b0 & (ex6_size_q == TLB_PgSize_1GB | ex6_size_q == TLB_PgSize_256MB))) ? ex3_ea_q[19:22] : 
                                 (inv_seq_tlbi_load == 1'b1) ? ex3_ea_q[36:39] : 
                                 lsu_addr_q[36:39];
      assign lsu_addr_d[40:41] = (inv_seq_htw_load == 1'b1) ? htw_lsu_addr[40:41] : 
                                 ((inv_seq_tlbi_load == 1'b1 & mmucr1[pos_tlbi_msb] == 1'b1 & (ex6_size_q == TLB_PgSize_1GB | ex6_size_q == TLB_PgSize_256MB | ex6_size_q == TLB_PgSize_16MB))) ? ex3_ea_q[19:20] : 
                                 ((inv_seq_tlbi_load == 1'b1 & mmucr1[pos_tlbi_msb] == 1'b0 & (ex6_size_q == TLB_PgSize_1GB | ex6_size_q == TLB_PgSize_256MB | ex6_size_q == TLB_PgSize_16MB))) ? ex3_ea_q[23:24] : 
                                 (inv_seq_tlbi_load == 1'b1) ? ex3_ea_q[40:41] : 
                                 lsu_addr_q[40:41];
      assign lsu_addr_d[42:43] = (inv_seq_htw_load == 1'b1) ? htw_lsu_addr[42:43] : 
                                 ((ex6_isel_q[0] == 1'b1 & inv_seq_tlbi_load == 1'b1)) ? ex6_isel_q[1:2] : 
                                 ((ex6_isel_q[0] == 1'b0 & inv_seq_tlbi_load == 1'b1 & mmucr1[pos_tlbi_msb] == 1'b1 & (ex6_size_q == TLB_PgSize_1GB | ex6_size_q == TLB_PgSize_256MB | ex6_size_q == TLB_PgSize_16MB))) ? ex3_ea_q[21:22] : 
                                 ((ex6_isel_q[0] == 1'b0 & inv_seq_tlbi_load == 1'b1 & mmucr1[pos_tlbi_msb] == 1'b0 & (ex6_size_q == TLB_PgSize_1GB | ex6_size_q == TLB_PgSize_256MB | ex6_size_q == TLB_PgSize_16MB))) ? ex3_ea_q[25:26] : 
                                 ((ex6_isel_q[0] == 1'b0 & inv_seq_tlbi_load == 1'b1)) ? ex3_ea_q[42:43] : 
                                 lsu_addr_q[42:43];
      assign lsu_addr_d[44:47] = (inv_seq_htw_load == 1'b1) ? htw_lsu_addr[44:47] : 
                                 ((inv_seq_tlbi_load == 1'b1 & mmucr1[pos_tlbi_msb] == 1'b1 & (ex6_size_q == TLB_PgSize_1GB | ex6_size_q == TLB_PgSize_256MB | ex6_size_q == TLB_PgSize_16MB | ex6_size_q == TLB_PgSize_1MB))) ? ex3_ea_q[23:26] : 
                                 ((inv_seq_tlbi_load == 1'b1 & mmucr1[pos_tlbi_msb] == 1'b0 & (ex6_size_q == TLB_PgSize_1GB | ex6_size_q == TLB_PgSize_256MB | ex6_size_q == TLB_PgSize_16MB | ex6_size_q == TLB_PgSize_1MB))) ? ex3_ea_q[27:30] : 
                                 (inv_seq_tlbi_load == 1'b1) ? ex3_ea_q[44:47] : 
                                 lsu_addr_q[44:47];
      assign lsu_addr_d[48:51] = (inv_seq_htw_load == 1'b1) ? htw_lsu_addr[48:51] : 
                                 (inv_seq_tlbi_load == 1'b1 & ex6_size_large == 1'b1) ? ex6_size_q[0:3] : 
                                 (inv_seq_tlbi_load == 1'b1 & ex6_size_large == 1'b0) ? ex3_ea_q[48:51] : 
                                 lsu_addr_q[48:51];
      assign lsu_addr_d[52] = (inv_seq_htw_load == 1'b1) ? htw_lsu_addr[52] : 
                              (inv_seq_tlbi_load == 1'b1) ? ex6_ts_q : 
                              lsu_addr_q[52];
      assign lsu_addr_d[53] = (inv_seq_htw_load == 1'b1) ? htw_lsu_addr[53] : 
                              (inv_seq_tlbi_load == 1'b1) ? ex6_pid_q[0] : 
                              lsu_addr_q[53];
      assign lsu_addr_d[54:55] = (inv_seq_htw_load == 1'b1) ? htw_lsu_addr[54:55] : 
                                 ((ex6_isel_q[0] == 1'b0 & inv_seq_tlbi_load == 1'b1)) ? ex6_isel_q[1:2] : 
                                 ((ex6_isel_q[0] == 1'b1 & inv_seq_tlbi_load == 1'b1)) ? 2'b10 : 
                                 lsu_addr_q[54:55];
      assign lsu_addr_d[56:63] = (inv_seq_htw_load == 1'b1) ? htw_lsu_addr[56:63] : 
                                 (inv_seq_tlbi_load == 1'b1) ? ex6_pid_q[`PID_WIDTH - 8:`PID_WIDTH - 1] : 
                                 lsu_addr_q[56:63];
      assign lsu_lpid_d = (inv_seq_tlbi_load == 1'b1) ? ex6_lpid_q : 
                          lsu_lpid_q;
      assign lsu_ind_d = (inv_seq_tlbi_load == 1'b1) ? ex6_ind_q : 
                         lsu_ind_q;
      assign lsu_gs_d = (inv_seq_tlbi_load == 1'b1) ? ex6_gs_q : 
                        lsu_gs_q;
      assign lsu_lbit_d = ((inv_seq_tlbi_load == 1'b1 & ex6_size_large == 1'b1)) ? 1'b1 : 
                          ((inv_seq_tlbi_load == 1'b1 & ex6_size_large == 1'b0)) ? 1'b0 : 
                          lsu_lbit_q;
      assign mm_xu_lsu_req = lsu_req_q;
      assign mm_xu_lsu_ttype = lsu_ttype_q;
      assign mm_xu_lsu_wimge = lsu_wimge_q;
      assign mm_xu_lsu_u = lsu_ubits_q;
      assign mm_xu_lsu_addr = lsu_addr_q;
      assign mm_xu_lsu_lpid = lsu_lpid_q;
      assign mm_xu_lsu_ind = lsu_ind_q;
      assign mm_xu_lsu_gs = lsu_gs_q;
      assign mm_xu_lsu_lbit = lsu_lbit_q;
      assign snoop_valid_d[0] = inv_seq_ierat_snoop_val;
      assign snoop_valid_d[1] = inv_seq_derat_snoop_val;
      assign snoop_valid_d[2] = inv_seq_tlb_snoop_val;
      assign snoop_coming_d[0] = inv_seq_tlb0fi_inprogress | inv_seq_tlbwe_inprogress | inv_seq_local_inprogress | inv_seq_snoop_inprogress;
      assign snoop_coming_d[1] = snoop_coming_d[0];
      assign snoop_coming_d[2] = snoop_coming_d[0];
      assign snoop_coming_d[3] = snoop_coming_d[0] | mmucr2_act_override;
      assign snoop_coming_d[4] = snoop_coming_d[0] | mmucr2_act_override;
      generate
         if (`REAL_ADDR_WIDTH > 32)
         begin : gen64_snoop_attr
            assign ex6_tid_nz = |(ex6_pid_q[0:`PID_WIDTH - 1]);
            assign back_inv_tid_nz = |({an_ac_back_inv_addr_q[53], an_ac_back_inv_addr_q[22:26], an_ac_back_inv_addr_q[56:63]});
            assign tlbwe_back_inv_tid_nz = |({tlbwe_back_inv_attr_q[20:25], tlbwe_back_inv_attr_q[6:13]});
            assign snoop_attr_d[0] = (~inv_seq_snoop_inprogress_q[0]);
            assign snoop_attr_d[1:3] = (inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_addr_q[54:55] == 2'b10) ? {1'b1, an_ac_back_inv_addr_q[42:43]} : 
                                       (inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_addr_q[54:55] != 2'b10) ? {1'b0, an_ac_back_inv_addr_q[54:55]} : 
                                       (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? 3'b011 : 
                                       (ex6_isel_q[0:2] & {3{(~inv_seq_tlb0fi_inprogress_q[0])}});
            assign snoop_attr_d[4:13] = (inv_seq_snoop_inprogress_q[0] == 1'b1) ? {an_ac_back_inv_q[5], an_ac_back_inv_addr_q[52], an_ac_back_inv_addr_q[56:63]} : 
                                        (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_attr_q[4:13] : 
                                        {ex6_gs_q, ex6_ts_q, ex6_pid_q[`PID_WIDTH - 8:`PID_WIDTH - 1]};
            assign snoop_attr_d[14:17] = (inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_q[4] == 1'b0) ? 4'b0001 : 
                                         (inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_q[4] == 1'b1) ? an_ac_back_inv_addr_q[48:51] : 
                                         (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_attr_q[14:17] : 
                                         ex6_size_q[0:3];
            assign snoop_attr_d[18] = (~inv_seq_tlbwe_inprogress_q[0]) | (~tlbwe_back_inv_attr_q[18]);
            assign snoop_attr_d[19] = (inv_seq_snoop_inprogress_q[0] == 1'b1) ? back_inv_tid_nz : 
                                      (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_tid_nz : 
                                      ex6_tid_nz;
            assign snoop_attr_tlb_spec_d[18] = 1'b0;
            assign snoop_attr_tlb_spec_d[19] = inv_seq_tlb0fi_inprogress_q[0];
            assign snoop_attr_d[20:25] = (inv_seq_snoop_inprogress_q[0] == 1'b1) ? {an_ac_back_inv_addr_q[53], an_ac_back_inv_addr_q[22:26]} : 
                                         (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_attr_q[20:25] : 
                                         ex6_pid_q[`PID_WIDTH - 14:`PID_WIDTH - 9];
            assign snoop_attr_d[26:33] = (inv_seq_snoop_inprogress_q[0] == 1'b1) ? an_ac_back_inv_lpar_id_q : 
                                         (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_attr_q[26:33] : 
                                         (inv_seq_tlb0fi_inprogress_q[0] == 1'b1) ? lpidr_q : 
                                         ex6_lpid_q;
            assign snoop_attr_d[34] = (inv_seq_snoop_inprogress_q[0] == 1'b1) ? an_ac_back_inv_q[6] : 
                                      (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_attr_q[34] : 
                                      ex6_ind_q;
            assign snoop_attr_clone_d[0] = (~inv_seq_snoop_inprogress_q[1]);
            assign snoop_attr_clone_d[1:3] = (inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_addr_q[54:55] == 2'b10) ? {1'b1, an_ac_back_inv_addr_q[42:43]} : 
                                             (inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_addr_q[54:55] != 2'b10) ? {1'b0, an_ac_back_inv_addr_q[54:55]} : 
                                             (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? 3'b011 : 
                                             (ex6_isel_q[0:2] & {3{(~inv_seq_tlb0fi_inprogress_q[1])}});
            assign snoop_attr_clone_d[4:13] = (inv_seq_snoop_inprogress_q[1] == 1'b1) ? {an_ac_back_inv_q[5], an_ac_back_inv_addr_q[52], an_ac_back_inv_addr_q[56:63]} : 
                                              (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_attr_q[4:13] : 
                                              {ex6_gs_q, ex6_ts_q, ex6_pid_q[`PID_WIDTH - 8:`PID_WIDTH - 1]};
            assign snoop_attr_clone_d[14:17] = (inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_q[4] == 1'b0) ? 4'b0001 : 
                                               (inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_q[4] == 1'b1) ? an_ac_back_inv_addr_q[48:51] : 
                                               (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_attr_q[14:17] : 
                                               ex6_size_q[0:3];
            assign snoop_attr_clone_d[18] = (~inv_seq_tlbwe_inprogress_q[1]) | (~tlbwe_back_inv_attr_q[18]);
            assign snoop_attr_clone_d[19] = (inv_seq_snoop_inprogress_q[1] == 1'b1) ? back_inv_tid_nz : 
                                            (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_tid_nz : 
                                            ex6_tid_nz;
            assign snoop_attr_clone_d[20:25] = (inv_seq_snoop_inprogress_q[1] == 1'b1) ? {an_ac_back_inv_addr_q[53], an_ac_back_inv_addr_q[22:26]} : 
                                               (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_attr_q[20:25] : 
                                               ex6_pid_q[`PID_WIDTH - 14:`PID_WIDTH - 9];
         end
      endgenerate
      generate
         if (`REAL_ADDR_WIDTH < 33)
         begin : gen32_snoop_attr
            assign ex6_tid_nz = |(ex6_pid_q[0:`PID_WIDTH - 1]);
            assign back_inv_tid_nz = |(an_ac_back_inv_addr_q[56:63]);
            assign tlbwe_back_inv_tid_nz = |({tlbwe_back_inv_attr_q[20:25], tlbwe_back_inv_attr_q[6:13]});
            assign snoop_attr_d[0] = (~inv_seq_snoop_inprogress_q[0]);
            assign snoop_attr_d[1:3] = (inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_addr_q[54:55] == 2'b10) ? {1'b1, an_ac_back_inv_addr_q[42:43]} : 
                                       (inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_addr_q[54:55] != 2'b10) ? {1'b0, an_ac_back_inv_addr_q[54:55]} : 
                                       (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? 3'b011 : 
                                       ex6_isel_q[0:2];
            assign snoop_attr_d[4:13] = (inv_seq_snoop_inprogress_q[0] == 1'b1) ? {an_ac_back_inv_q[5], an_ac_back_inv_addr_q[52], an_ac_back_inv_addr_q[56:63]} : 
                                        (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_attr_q[4:13] : 
                                        {ex6_gs_q, ex6_ts_q, ex6_pid_q[`PID_WIDTH - 8:`PID_WIDTH - 1]};
            assign snoop_attr_d[14:17] = (inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_q[4] == 1'b0) ? 4'b0001 : 
                                         (inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_q[4] == 1'b1) ? an_ac_back_inv_addr_q[48:51] : 
                                         (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_attr_q[14:17] : 
                                         ex6_size_q[0:3];
            assign snoop_attr_d[18] = (~inv_seq_tlbwe_inprogress_q[0]) | (~tlbwe_back_inv_attr_q[18]);
            assign snoop_attr_d[19] = (inv_seq_snoop_inprogress_q[0] == 1'b1) ? back_inv_tid_nz : 
                                      (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_tid_nz : 
                                      ex6_tid_nz;
            assign snoop_attr_tlb_spec_d[18] = 1'b0;
            assign snoop_attr_tlb_spec_d[19] = inv_seq_tlb0fi_inprogress_q[0];
            assign snoop_attr_d[20:25] = (inv_seq_snoop_inprogress_q[0] == 1'b1) ? {6{1'b0}} : 
                                         (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_attr_q[20:25] : 
                                         ex6_pid_q[`PID_WIDTH - 14:`PID_WIDTH - 9];
            assign snoop_attr_d[26:33] = (inv_seq_snoop_inprogress_q[0] == 1'b1) ? an_ac_back_inv_lpar_id_q : 
                                         (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_attr_q[26:33] : 
                                         (inv_seq_tlb0fi_inprogress_q[0] == 1'b1) ? lpidr_q : 
                                         ex6_lpid_q;
            assign snoop_attr_d[34] = (inv_seq_snoop_inprogress_q[0] == 1'b1) ? an_ac_back_inv_q[6] : 
                                      (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_attr_q[34] : 
                                      ex6_ind_q;
            assign snoop_attr_clone_d[0] = (~inv_seq_snoop_inprogress_q[1]);
            assign snoop_attr_clone_d[1:3] = (inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_addr_q[54:55] == 2'b10) ? {1'b1, an_ac_back_inv_addr_q[42:43]} : 
                                             (inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_addr_q[54:55] != 2'b10) ? {1'b0, an_ac_back_inv_addr_q[54:55]} : 
                                             (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? 3'b011 : 
                                             ex6_isel_q[0:2];
            assign snoop_attr_clone_d[4:13] = (inv_seq_snoop_inprogress_q[1] == 1'b1) ? {an_ac_back_inv_q[5], an_ac_back_inv_addr_q[52], an_ac_back_inv_addr_q[56:63]} : 
                                              (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_attr_q[4:13] : 
                                              {ex6_gs_q, ex6_ts_q, ex6_pid_q[`PID_WIDTH - 8:`PID_WIDTH - 1]};
            assign snoop_attr_clone_d[14:17] = (inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_q[4] == 1'b0) ? 4'b0001 : 
                                               (inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_q[4] == 1'b1) ? an_ac_back_inv_addr_q[48:51] : 
                                               (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_attr_q[14:17] : 
                                               ex6_size_q[0:3];
            assign snoop_attr_clone_d[18] = (~inv_seq_tlbwe_inprogress_q[1]) | (~tlbwe_back_inv_attr_q[18]);
            assign snoop_attr_clone_d[19] = (inv_seq_snoop_inprogress_q[1] == 1'b1) ? back_inv_tid_nz : 
                                            (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_tid_nz : 
                                            ex6_tid_nz;
            assign snoop_attr_clone_d[20:25] = (inv_seq_snoop_inprogress_q[1] == 1'b1) ? {6{1'b0}} : 
                                               (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_attr_q[20:25] : 
                                               ex6_pid_q[`PID_WIDTH - 14:`PID_WIDTH - 9];
         end
      endgenerate
      generate
         if ((`RS_DATA_WIDTH > `EPN_WIDTH - 1) & (`EPN_WIDTH > `REAL_ADDR_WIDTH))
         begin : gen_rs_gte_epn_snoop_vpn
            assign snoop_vpn_d[52 - `EPN_WIDTH:12] = (inv_seq_snoop_inprogress_q[0] == 1'b1) ? {13{1'b0}} : 
                                                    (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_addr_q[0:12] : 
                                                    ex3_ea_q[52 - `EPN_WIDTH:12];
            assign snoop_vpn_d[13:14] = ((inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b1 & an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB)) ? an_ac_back_inv_addr_q[34:35] : 
                                        (inv_seq_snoop_inprogress_q[0] == 1'b1) ? {2{1'b0}} : 
                                        (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_addr_q[13:14] : 
                                        ex3_ea_q[13:14];
            assign snoop_vpn_d[15:16] = ((inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b1 & (an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_256MB))) ? an_ac_back_inv_addr_q[36:37] : 
                                        (inv_seq_snoop_inprogress_q[0] == 1'b1) ? {2{1'b0}} : 
                                        (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_addr_q[15:16] : 
                                        ex3_ea_q[15:16];
            assign snoop_vpn_d[17:18] = ((inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b1 & (an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_256MB))) ? an_ac_back_inv_addr_q[38:39] : 
                                        ((inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b0 & an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB)) ? an_ac_back_inv_addr_q[34:35] : 
                                        (inv_seq_snoop_inprogress_q[0] == 1'b1) ? {2{1'b0}} : 
                                        (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_addr_q[17:18] : 
                                        ex3_ea_q[17:18];
            assign snoop_vpn_d[19:22] = ((inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b1 & (an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_256MB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_16MB))) ? an_ac_back_inv_addr_q[40:43] : 
                                        ((inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b0 & (an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_256MB))) ? an_ac_back_inv_addr_q[36:39] : 
                                        (inv_seq_snoop_inprogress_q[0] == 1'b1) ? {4{1'b0}} : 
                                        (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_addr_q[19:22] : 
                                        ex3_ea_q[19:22];
            assign snoop_vpn_d[23:26] = ((inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b1 & (an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_256MB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_16MB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1MB))) ? an_ac_back_inv_addr_q[44:47] : 
                                        ((inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b0 & (an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_256MB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_16MB))) ? an_ac_back_inv_addr_q[40:43] : 
                                        (inv_seq_snoop_inprogress_q[0] == 1'b1) ? {4{1'b0}} : 
                                        (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_addr_q[23:26] : 
                                        ex3_ea_q[23:26];
            assign snoop_vpn_d[27:30] = ((inv_seq_snoop_inprogress_q[0] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b0 & (an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_256MB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_16MB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1MB))) ? an_ac_back_inv_addr_q[44:47] : 
                                        (inv_seq_snoop_inprogress_q[0] == 1'b1) ? an_ac_back_inv_addr_q[27:30] : 
                                        (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_addr_q[27:30] : 
                                        ex3_ea_q[27:30];
            assign snoop_vpn_d[31] = (inv_seq_snoop_inprogress_q[0] == 1'b1) ? an_ac_back_inv_addr_q[31] : 
                                     (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_addr_q[31] : 
                                     ex3_ea_q[31];
            assign snoop_vpn_clone_d[52 - `EPN_WIDTH:12] = (inv_seq_snoop_inprogress_q[1] == 1'b1) ? {13{1'b0}} : 
                                                          (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_addr_q[0:12] : 
                                                          ex3_ea_q[52 - `EPN_WIDTH:12];
            assign snoop_vpn_clone_d[13:14] = ((inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b1 & an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB)) ? an_ac_back_inv_addr_q[34:35] : 
                                              (inv_seq_snoop_inprogress_q[1] == 1'b1) ? {2{1'b0}} : 
                                              (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_addr_q[13:14] : 
                                              ex3_ea_q[13:14];
            assign snoop_vpn_clone_d[15:16] = ((inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b1 & (an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_256MB))) ? an_ac_back_inv_addr_q[36:37] : 
                                              (inv_seq_snoop_inprogress_q[1] == 1'b1) ? {2{1'b0}} : 
                                              (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_addr_q[15:16] : 
                                              ex3_ea_q[15:16];
            assign snoop_vpn_clone_d[17:18] = ((inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b1 & (an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_256MB))) ? an_ac_back_inv_addr_q[38:39] : 
                                              ((inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b0 & an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB)) ? an_ac_back_inv_addr_q[34:35] : 
                                              (inv_seq_snoop_inprogress_q[1] == 1'b1) ? {2{1'b0}} : 
                                              (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_addr_q[17:18] : 
                                              ex3_ea_q[17:18];
            assign snoop_vpn_clone_d[19:22] = ((inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b1 & (an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_256MB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_16MB))) ? an_ac_back_inv_addr_q[40:43] : 
                                              ((inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b0 & (an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_256MB))) ? an_ac_back_inv_addr_q[36:39] : 
                                              (inv_seq_snoop_inprogress_q[1] == 1'b1) ? {4{1'b0}} : 
                                              (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_addr_q[19:22] : 
                                              ex3_ea_q[19:22];
            assign snoop_vpn_clone_d[23:26] = ((inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b1 & (an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_256MB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_16MB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1MB))) ? an_ac_back_inv_addr_q[44:47] : 
                                              ((inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b0 & (an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_256MB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_16MB))) ? an_ac_back_inv_addr_q[40:43] : 
                                              (inv_seq_snoop_inprogress_q[1] == 1'b1) ? {4{1'b0}} : 
                                              (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_addr_q[23:26] : 
                                              ex3_ea_q[23:26];
            assign snoop_vpn_clone_d[27:30] = ((inv_seq_snoop_inprogress_q[1] == 1'b1 & an_ac_back_inv_q[4] == 1'b1 & mmucr1_q[pos_tlbi_msb] == 1'b0 & (an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1GB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_256MB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_16MB | an_ac_back_inv_addr_q[48:51] == TLB_PgSize_1MB))) ? an_ac_back_inv_addr_q[44:47] : 
                                              (inv_seq_snoop_inprogress_q[1] == 1'b1) ? an_ac_back_inv_addr_q[27:30] : 
                                              (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_addr_q[27:30] : 
                                              ex3_ea_q[27:30];
            assign snoop_vpn_clone_d[31] = (inv_seq_snoop_inprogress_q[1] == 1'b1) ? an_ac_back_inv_addr_q[31] : 
                                           (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_addr_q[31] : 
                                           ex3_ea_q[31];
         end
      endgenerate
      generate
         if (`RS_DATA_WIDTH > `REAL_ADDR_WIDTH - 1)
         begin : gen_rs_gte_ra_snoop_vpn
            assign snoop_vpn_d[32:51] = (inv_seq_snoop_inprogress_q[0] == 1'b1) ? an_ac_back_inv_addr_q[32:51] : 
                                        (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_addr_q[32:51] : 
                                        ex3_ea_q[32:51];
            assign snoop_vpn_clone_d[32:51] = (inv_seq_snoop_inprogress_q[1] == 1'b1) ? an_ac_back_inv_addr_q[32:51] : 
                                              (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_addr_q[32:51] : 
                                              ex3_ea_q[32:51];
         end
      endgenerate
      generate
         if (`RS_DATA_WIDTH < `REAL_ADDR_WIDTH)
         begin : gen_ra_gt_rs_snoop_vpn
            assign snoop_vpn_d[64 - `REAL_ADDR_WIDTH:51] = (inv_seq_snoop_inprogress_q[0] == 1'b1) ? an_ac_back_inv_addr_q[64 - `REAL_ADDR_WIDTH:51] : 
                                                          (inv_seq_tlbwe_inprogress_q[0] == 1'b1) ? tlbwe_back_inv_addr_q[64 - `REAL_ADDR_WIDTH:51] : 
                                                          {1'b0, ex3_ea_q[64 - `RS_DATA_WIDTH:51]};
            assign snoop_vpn_clone_d[64 - `REAL_ADDR_WIDTH:51] = (inv_seq_snoop_inprogress_q[1] == 1'b1) ? an_ac_back_inv_addr_q[64 - `REAL_ADDR_WIDTH:51] : 
                                                                (inv_seq_tlbwe_inprogress_q[1] == 1'b1) ? tlbwe_back_inv_addr_q[64 - `REAL_ADDR_WIDTH:51] : 
                                                                {1'b0, ex3_ea_q[64 - `RS_DATA_WIDTH:51]};
         end
      endgenerate
      generate
         if ((`EPN_WIDTH > `REAL_ADDR_WIDTH) & (`RS_DATA_WIDTH < `EPN_WIDTH))
         begin : gen_epn_gt_rs_snoop_vpn
            assign snoop_vpn_d[52 - `EPN_WIDTH:63 - `REAL_ADDR_WIDTH] = {22{1'b0}};
            assign snoop_vpn_clone_d[52 - `EPN_WIDTH:63 - `REAL_ADDR_WIDTH] = {22{1'b0}};
         end
      endgenerate
      assign snoop_ack_d[0] = (snoop_ack_q[0] == 1'b0) ? iu_mm_ierat_snoop_ack : 
                              ((inv_seq_snoop_done == 1'b1 | inv_seq_local_done == 1'b1 | inv_seq_tlb0fi_done == 1'b1 | inv_seq_tlbwe_snoop_done == 1'b1)) ? 1'b0 : 
                              snoop_ack_q[0];
      assign snoop_ack_d[1] = (snoop_ack_q[1] == 1'b0) ? xu_mm_derat_snoop_ack : 
                              ((inv_seq_snoop_done == 1'b1 | inv_seq_local_done == 1'b1 | inv_seq_tlb0fi_done == 1'b1 | inv_seq_tlbwe_snoop_done == 1'b1)) ? 1'b0 : 
                              snoop_ack_q[1];
      assign snoop_ack_d[2] = (snoop_ack_q[2] == 1'b0) ? tlb_snoop_ack : 
                              ((inv_seq_snoop_done == 1'b1 | inv_seq_local_done == 1'b1 | inv_seq_tlb0fi_done == 1'b1 | inv_seq_tlbwe_snoop_done == 1'b1)) ? 1'b0 : 
                              snoop_ack_q[2];
      assign mm_iu_ierat_snoop_coming = snoop_coming_q[0];
      assign mm_iu_ierat_snoop_val = snoop_valid_q[0];
      assign mm_iu_ierat_snoop_attr = snoop_attr_q[0:25];
      assign mm_iu_ierat_snoop_vpn = snoop_vpn_q;
      assign mm_xu_derat_snoop_coming = snoop_coming_q[1];
      assign mm_xu_derat_snoop_val = snoop_valid_q[1];
      assign mm_xu_derat_snoop_attr = snoop_attr_clone_q[0:25];
      assign mm_xu_derat_snoop_vpn = snoop_vpn_clone_q;
      assign tlb_snoop_coming = snoop_coming_q[2];
      assign tlb_snoop_val = snoop_valid_q[2];
      assign tlb_snoop_attr[0:17] = snoop_attr_q[0:17];
      assign tlb_snoop_attr[18:19] = snoop_attr_tlb_spec_q[18:19];
      assign tlb_snoop_attr[20:34] = snoop_attr_q[20:34];
      assign tlb_snoop_vpn = snoop_vpn_q;
      assign xu_mm_ccr2_notlb_b = (~xu_mm_ccr2_notlb_q[1:12]);
      assign xu_mm_epcr_dgtmi = xu_mm_epcr_dgtmi_q;
      assign inval_perf_tlbilx = inv_seq_local_done & (~inv_seq_tlbi_load);
      assign inval_perf_tlbivax = inv_seq_local_done & inv_seq_tlbi_load;
      assign inval_perf_tlbivax_snoop = inv_seq_snoop_done;
      assign inval_perf_tlb_flush = |(ex3_flush_req_q);
      assign inval_dbg_seq_q = inv_seq_q[1:5];
      assign inval_dbg_seq_idle = inv_seq_idle;
      assign inval_dbg_seq_snoop_inprogress = inv_seq_snoop_inprogress;
      assign inval_dbg_seq_snoop_done = inv_seq_snoop_done;
      assign inval_dbg_seq_local_done = inv_seq_local_done;
      assign inval_dbg_seq_tlb0fi_done = inv_seq_tlb0fi_done;
      assign inval_dbg_seq_tlbwe_snoop_done = inv_seq_tlbwe_snoop_done;
      assign inval_dbg_ex6_valid = |(ex6_valid_q);
    `ifdef MM_THREADS2
      assign inval_dbg_ex6_thdid[0] = 1'b0;
      assign inval_dbg_ex6_thdid[1] = ex6_valid_q[1];
    `else
      assign inval_dbg_ex6_thdid[0] = 1'b0;
      assign inval_dbg_ex6_thdid[1] = 1'b0;
    `endif
      assign inval_dbg_ex6_ttype[0] = (ex6_ttype_q[4] | ex6_ttype_q[5]);
      assign inval_dbg_ex6_ttype[1] = (ex6_ttype_q[2] | ex6_ttype_q[3]);
      assign inval_dbg_ex6_ttype[2] = (ex6_ttype_q[1] | ex6_ttype_q[3] | ex6_ttype_q[5]);
      assign inval_dbg_snoop_forme = inval_snoop_forme;
      assign inval_dbg_snoop_local_reject = inval_snoop_local_reject | |(ex3_ivax_lpid_reject_q);
      assign inval_dbg_an_ac_back_inv_q = an_ac_back_inv_q[2:8];
      assign inval_dbg_an_ac_back_inv_lpar_id_q = an_ac_back_inv_lpar_id_q;
      assign inval_dbg_an_ac_back_inv_addr_q = an_ac_back_inv_addr_q;
      assign inval_dbg_snoop_valid_q = snoop_valid_q;
      assign inval_dbg_snoop_ack_q = snoop_ack_q;
      assign inval_dbg_snoop_attr_q = snoop_attr_q;
      assign inval_dbg_snoop_attr_tlb_spec_q = snoop_attr_tlb_spec_q;
      assign inval_dbg_snoop_vpn_q = snoop_vpn_q[17:51];
      assign inval_dbg_lsu_tokens_q = lsu_tokens_q;
      assign unused_dc[0] = |(lcb_delay_lclkr_dc[1:4]);
      assign unused_dc[1] = |(lcb_mpw1_dc_b[1:4]);
      assign unused_dc[2] = pc_func_sl_force;
      assign unused_dc[3] = pc_func_sl_thold_0_b;
      assign unused_dc[4] = tc_scan_dis_dc_b;
      assign unused_dc[5] = tc_scan_diag_dc;
      assign unused_dc[6] = tc_lbist_en_dc;
      `ifdef MM_THREADS2 
      assign unused_dc[7] = mmucr0_0[4] | mmucr0_1[4];
      assign unused_dc[8] = mmucr0_0[5] | mmucr0_1[5];
      `else 
      assign unused_dc[7] = mmucr0_0[4];
      assign unused_dc[8] = mmucr0_0[5];
      `endif
      assign unused_dc[9] = |(tlb_tag5_except);
      assign unused_dc[10] = mmucr1_q[13];
      assign unused_dc[11] = |(mmucr1_q[15:17]);
      assign unused_dc[12] = ex5_rs_is_q[0] | bus_snoop_seq_idle;
      
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex1_valid_latch(
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
         .scin(siv[ex1_valid_offset:ex1_valid_offset + `MM_THREADS - 1]),
         .scout(sov[ex1_valid_offset:ex1_valid_offset + `MM_THREADS - 1]),
         .din(ex1_valid_d),
         .dout(ex1_valid_q)
      );
      
      tri_rlmreg_p #(.WIDTH((`MMQ_INVAL_TTYPE_WIDTH-2)), .INIT(0), .NEEDS_SRESET(1)) ex1_ttype_latch(
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
         .scin(siv[ex1_ttype_offset:ex1_ttype_offset + (`MMQ_INVAL_TTYPE_WIDTH-2) - 1]),
         .scout(sov[ex1_ttype_offset:ex1_ttype_offset + (`MMQ_INVAL_TTYPE_WIDTH-2) - 1]),
         .din(ex1_ttype_d),
         .dout(ex1_ttype_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MMQ_INVAL_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex1_state_latch(
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
         .scin(siv[ex1_state_offset:ex1_state_offset + `MMQ_INVAL_STATE_WIDTH - 1]),
         .scout(sov[ex1_state_offset:ex1_state_offset + `MMQ_INVAL_STATE_WIDTH - 1]),
         .din(ex1_state_d[0:`MMQ_INVAL_STATE_WIDTH - 1]),
         .dout(ex1_state_q[0:`MMQ_INVAL_STATE_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`T_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex1_t_latch(
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
         .scin(siv[ex1_t_offset:ex1_t_offset + `T_WIDTH - 1]),
         .scout(sov[ex1_t_offset:ex1_t_offset + `T_WIDTH - 1]),
         .din(ex1_t_d[0:`T_WIDTH - 1]),
         .dout(ex1_t_q[0:`T_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex1_itag_latch(
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
         .scin(siv[ex1_itag_offset:ex1_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[ex1_itag_offset:ex1_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(ex1_itag_d),
         .dout(ex1_itag_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex2_valid_latch(
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
         .scin(siv[ex2_valid_offset:ex2_valid_offset + `MM_THREADS - 1]),
         .scout(sov[ex2_valid_offset:ex2_valid_offset + `MM_THREADS - 1]),
         .din(ex2_valid_d),
         .dout(ex2_valid_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MMQ_INVAL_TTYPE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex2_ttype_latch(
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
         .scin(siv[ex2_ttype_offset:ex2_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH - 1]),
         .scout(sov[ex2_ttype_offset:ex2_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH - 1]),
         .din(ex2_ttype_d[0:`MMQ_INVAL_TTYPE_WIDTH - 1]),
         .dout(ex2_ttype_q[0:`MMQ_INVAL_TTYPE_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`RS_IS_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex2_rs_is_latch(
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
         .scin(siv[ex2_rs_is_offset:ex2_rs_is_offset + `RS_IS_WIDTH - 1]),
         .scout(sov[ex2_rs_is_offset:ex2_rs_is_offset + `RS_IS_WIDTH - 1]),
         .din(ex2_rs_is_d[0:`RS_IS_WIDTH - 1]),
         .dout(ex2_rs_is_q[0:`RS_IS_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`MMQ_INVAL_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex2_state_latch(
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
         .scin(siv[ex2_state_offset:ex2_state_offset + `MMQ_INVAL_STATE_WIDTH - 1]),
         .scout(sov[ex2_state_offset:ex2_state_offset + `MMQ_INVAL_STATE_WIDTH - 1]),
         .din(ex2_state_d[0:`MMQ_INVAL_STATE_WIDTH - 1]),
         .dout(ex2_state_q[0:`MMQ_INVAL_STATE_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`T_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex2_t_latch(
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
         .scin(siv[ex2_t_offset:ex2_t_offset + `T_WIDTH - 1]),
         .scout(sov[ex2_t_offset:ex2_t_offset + `T_WIDTH - 1]),
         .din(ex2_t_d[0:`T_WIDTH - 1]),
         .dout(ex2_t_q[0:`T_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex2_itag_latch(
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
         .scin(siv[ex2_itag_offset:ex2_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[ex2_itag_offset:ex2_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(ex2_itag_d),
         .dout(ex2_itag_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_valid_latch(
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
         .scin(siv[ex3_valid_offset:ex3_valid_offset + `MM_THREADS - 1]),
         .scout(sov[ex3_valid_offset:ex3_valid_offset + `MM_THREADS - 1]),
         .din(ex3_valid_d),
         .dout(ex3_valid_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MMQ_INVAL_TTYPE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex3_ttype_latch(
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
         .scin(siv[ex3_ttype_offset:ex3_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH - 1]),
         .scout(sov[ex3_ttype_offset:ex3_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH - 1]),
         .din(ex3_ttype_d[0:`MMQ_INVAL_TTYPE_WIDTH - 1]),
         .dout(ex3_ttype_q[0:`MMQ_INVAL_TTYPE_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`RS_IS_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex3_rs_is_latch(
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
         .scin(siv[ex3_rs_is_offset:ex3_rs_is_offset + `RS_IS_WIDTH - 1]),
         .scout(sov[ex3_rs_is_offset:ex3_rs_is_offset + `RS_IS_WIDTH - 1]),
         .din(ex3_rs_is_d[0:`RS_IS_WIDTH - 1]),
         .dout(ex3_rs_is_q[0:`RS_IS_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`MMQ_INVAL_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex3_state_latch(
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
         .scin(siv[ex3_state_offset:ex3_state_offset + `MMQ_INVAL_STATE_WIDTH - 1]),
         .scout(sov[ex3_state_offset:ex3_state_offset + `MMQ_INVAL_STATE_WIDTH - 1]),
         .din(ex3_state_d[0:`MMQ_INVAL_STATE_WIDTH - 1]),
         .dout(ex3_state_q[0:`MMQ_INVAL_STATE_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`T_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex3_t_latch(
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
         .scin(siv[ex3_t_offset:ex3_t_offset + `T_WIDTH - 1]),
         .scout(sov[ex3_t_offset:ex3_t_offset + `T_WIDTH - 1]),
         .din(ex3_t_d[0:`T_WIDTH - 1]),
         .dout(ex3_t_q[0:`T_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_flush_req_latch(
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
         .scin(siv[ex3_flush_req_offset:ex3_flush_req_offset + `MM_THREADS - 1]),
         .scout(sov[ex3_flush_req_offset:ex3_flush_req_offset + `MM_THREADS - 1]),
         .din(ex3_flush_req_d),
         .dout(ex3_flush_req_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`RS_DATA_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex3_ea_latch(
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
         .scin(siv[ex3_ea_offset:ex3_ea_offset + `RS_DATA_WIDTH - 1]),
         .scout(sov[ex3_ea_offset:ex3_ea_offset + `RS_DATA_WIDTH - 1]),
         .din(ex3_ea_d[64 - `RS_DATA_WIDTH:63]),
         .dout(ex3_ea_q[64 - `RS_DATA_WIDTH:63])
      );
      
      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex3_itag_latch(
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
         .scin(siv[ex3_itag_offset:ex3_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[ex3_itag_offset:ex3_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(ex3_itag_d),
         .dout(ex3_itag_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_valid_latch(
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
         .scin(siv[ex4_valid_offset:ex4_valid_offset + `MM_THREADS - 1]),
         .scout(sov[ex4_valid_offset:ex4_valid_offset + `MM_THREADS - 1]),
         .din(ex4_valid_d),
         .dout(ex4_valid_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MMQ_INVAL_TTYPE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex4_ttype_latch(
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
         .scin(siv[ex4_ttype_offset:ex4_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH - 1]),
         .scout(sov[ex4_ttype_offset:ex4_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH - 1]),
         .din(ex4_ttype_d[0:`MMQ_INVAL_TTYPE_WIDTH - 1]),
         .dout(ex4_ttype_q[0:`MMQ_INVAL_TTYPE_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`RS_IS_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex4_rs_is_latch(
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
         .scin(siv[ex4_rs_is_offset:ex4_rs_is_offset + `RS_IS_WIDTH - 1]),
         .scout(sov[ex4_rs_is_offset:ex4_rs_is_offset + `RS_IS_WIDTH - 1]),
         .din(ex4_rs_is_d[0:`RS_IS_WIDTH - 1]),
         .dout(ex4_rs_is_q[0:`RS_IS_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`MMQ_INVAL_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex4_state_latch(
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
         .scin(siv[ex4_state_offset:ex4_state_offset + `MMQ_INVAL_STATE_WIDTH - 1]),
         .scout(sov[ex4_state_offset:ex4_state_offset + `MMQ_INVAL_STATE_WIDTH - 1]),
         .din(ex4_state_d[0:`MMQ_INVAL_STATE_WIDTH - 1]),
         .dout(ex4_state_q[0:`MMQ_INVAL_STATE_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`T_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex4_t_latch(
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
         .scin(siv[ex4_t_offset:ex4_t_offset + `T_WIDTH - 1]),
         .scout(sov[ex4_t_offset:ex4_t_offset + `T_WIDTH - 1]),
         .din(ex4_t_d[0:`T_WIDTH - 1]),
         .dout(ex4_t_q[0:`T_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex4_itag_latch(
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
         .scin(siv[ex4_itag_offset:ex4_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[ex4_itag_offset:ex4_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(ex4_itag_d),
         .dout(ex4_itag_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_valid_latch(
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
         .scin(siv[ex5_valid_offset:ex5_valid_offset + `MM_THREADS - 1]),
         .scout(sov[ex5_valid_offset:ex5_valid_offset + `MM_THREADS - 1]),
         .din(ex5_valid_d),
         .dout(ex5_valid_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MMQ_INVAL_TTYPE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex5_ttype_latch(
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
         .scin(siv[ex5_ttype_offset:ex5_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH - 1]),
         .scout(sov[ex5_ttype_offset:ex5_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH - 1]),
         .din(ex5_ttype_d[0:`MMQ_INVAL_TTYPE_WIDTH - 1]),
         .dout(ex5_ttype_q[0:`MMQ_INVAL_TTYPE_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`RS_IS_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex5_rs_is_latch(
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
         .scin(siv[ex5_rs_is_offset:ex5_rs_is_offset + `RS_IS_WIDTH - 1]),
         .scout(sov[ex5_rs_is_offset:ex5_rs_is_offset + `RS_IS_WIDTH - 1]),
         .din(ex5_rs_is_d[0:`RS_IS_WIDTH - 1]),
         .dout(ex5_rs_is_q[0:`RS_IS_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`MMQ_INVAL_STATE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex5_state_latch(
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
         .scin(siv[ex5_state_offset:ex5_state_offset + `MMQ_INVAL_STATE_WIDTH - 1]),
         .scout(sov[ex5_state_offset:ex5_state_offset + `MMQ_INVAL_STATE_WIDTH - 1]),
         .din(ex5_state_d[0:`MMQ_INVAL_STATE_WIDTH - 1]),
         .dout(ex5_state_q[0:`MMQ_INVAL_STATE_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`T_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex5_t_latch(
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
         .scin(siv[ex5_t_offset:ex5_t_offset + `T_WIDTH - 1]),
         .scout(sov[ex5_t_offset:ex5_t_offset + `T_WIDTH - 1]),
         .din(ex5_t_d[0:`T_WIDTH - 1]),
         .dout(ex5_t_q[0:`T_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex5_itag_latch(
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
         .scin(siv[ex5_itag_offset:ex5_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[ex5_itag_offset:ex5_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(ex5_itag_d),
         .dout(ex5_itag_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex6_valid_latch(
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
         .scin(siv[ex6_valid_offset:ex6_valid_offset + `MM_THREADS - 1]),
         .scout(sov[ex6_valid_offset:ex6_valid_offset + `MM_THREADS - 1]),
         .din(ex6_valid_d),
         .dout(ex6_valid_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MMQ_INVAL_TTYPE_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex6_ttype_latch(
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
         .scin(siv[ex6_ttype_offset:ex6_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH - 1]),
         .scout(sov[ex6_ttype_offset:ex6_ttype_offset + `MMQ_INVAL_TTYPE_WIDTH - 1]),
         .din(ex6_ttype_d[0:`MMQ_INVAL_TTYPE_WIDTH - 1]),
         .dout(ex6_ttype_q[0:`MMQ_INVAL_TTYPE_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex6_isel_latch(
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
         .scin(siv[ex6_isel_offset:ex6_isel_offset + 3 - 1]),
         .scout(sov[ex6_isel_offset:ex6_isel_offset + 3 - 1]),
         .din(ex6_isel_d[0:3 - 1]),
         .dout(ex6_isel_q[0:3 - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex6_size_latch(
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
         .scin(siv[ex6_size_offset:ex6_size_offset + 4 - 1]),
         .scout(sov[ex6_size_offset:ex6_size_offset + 4 - 1]),
         .din(ex6_size_d[0:4 - 1]),
         .dout(ex6_size_q[0:4 - 1])
      );
      
      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_gs_latch(
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
         .scin(siv[ex6_gs_offset]),
         .scout(sov[ex6_gs_offset]),
         .din(ex6_gs_d),
         .dout(ex6_gs_q)
      );
      
      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_ts_latch(
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
         .scin(siv[ex6_ts_offset]),
         .scout(sov[ex6_ts_offset]),
         .din(ex6_ts_d),
         .dout(ex6_ts_q)
      );
      
      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_ind_latch(
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
         .scin(siv[ex6_ind_offset]),
         .scout(sov[ex6_ind_offset]),
         .din(ex6_ind_d),
         .dout(ex6_ind_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`PID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex6_pid_latch(
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
         .scin(siv[ex6_pid_offset:ex6_pid_offset + `PID_WIDTH - 1]),
         .scout(sov[ex6_pid_offset:ex6_pid_offset + `PID_WIDTH - 1]),
         .din(ex6_pid_d[0:`PID_WIDTH - 1]),
         .dout(ex6_pid_q[0:`PID_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex6_lpid_latch(
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
         .scin(siv[ex6_lpid_offset:ex6_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[ex6_lpid_offset:ex6_lpid_offset + `LPID_WIDTH - 1]),
         .din(ex6_lpid_d[0:`LPID_WIDTH - 1]),
         .dout(ex6_lpid_q[0:`LPID_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex6_itag_latch(
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
         .scin(siv[ex6_itag_offset:ex6_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[ex6_itag_offset:ex6_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(ex6_itag_d),
         .dout(ex6_itag_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) mm_xu_itag_latch(
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
         .scin(siv[mm_xu_itag_offset:mm_xu_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[mm_xu_itag_offset:mm_xu_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(mm_xu_itag_d),
         .dout(mm_xu_itag_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ord_np1_flush_latch(
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
         .scin(siv[ord_np1_flush_offset:ord_np1_flush_offset + `MM_THREADS - 1]),
         .scout(sov[ord_np1_flush_offset:ord_np1_flush_offset + `MM_THREADS - 1]),
         .din(ord_np1_flush_d),
         .dout(ord_np1_flush_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ord_read_done_latch(
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
         .scin(siv[ord_read_done_offset:ord_read_done_offset + `MM_THREADS - 1]),
         .scout(sov[ord_read_done_offset:ord_read_done_offset + `MM_THREADS - 1]),
         .din(ord_read_done_d),
         .dout(ord_read_done_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ord_write_done_latch(
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
         .scin(siv[ord_write_done_offset:ord_write_done_offset + `MM_THREADS - 1]),
         .scout(sov[ord_write_done_offset:ord_write_done_offset + `MM_THREADS - 1]),
         .din(ord_write_done_d),
         .dout(ord_write_done_q)
      );
      
      tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) inv_seq_latch(
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
         .scin(siv[inv_seq_offset:inv_seq_offset + 6 - 1]),
         .scout(sov[inv_seq_offset:inv_seq_offset + 6 - 1]),
         .din(inv_seq_d[0:`INV_SEQ_WIDTH - 1]),
         .dout(inv_seq_q[0:`INV_SEQ_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) hold_req_latch(
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
         .scin(siv[hold_req_offset:hold_req_offset + `MM_THREADS - 1]),
         .scout(sov[hold_req_offset:hold_req_offset + `MM_THREADS - 1]),
         .din(hold_req_d),
         .dout(hold_req_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) hold_ack_latch(
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
         .scin(siv[hold_ack_offset:hold_ack_offset + `MM_THREADS - 1]),
         .scout(sov[hold_ack_offset:hold_ack_offset + `MM_THREADS - 1]),
         .din(hold_ack_d),
         .dout(hold_ack_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) hold_done_latch(
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
         .scin(siv[hold_done_offset:hold_done_offset + `MM_THREADS - 1]),
         .scout(sov[hold_done_offset:hold_done_offset + `MM_THREADS - 1]),
         .din(hold_done_d),
         .dout(hold_done_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) iu_flush_req_latch(
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
         .scin(siv[iu_flush_req_offset:iu_flush_req_offset + `MM_THREADS - 1]),
         .scout(sov[iu_flush_req_offset:iu_flush_req_offset + `MM_THREADS - 1]),
         .din(iu_flush_req_d),
         .dout(iu_flush_req_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`BUS_SNOOP_SEQ_WIDTH), .INIT(0), .NEEDS_SRESET(1)) bus_snoop_seq_latch(
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
         .scin(siv[bus_snoop_seq_offset:bus_snoop_seq_offset + `BUS_SNOOP_SEQ_WIDTH - 1]),
         .scout(sov[bus_snoop_seq_offset:bus_snoop_seq_offset + `BUS_SNOOP_SEQ_WIDTH - 1]),
         .din(bus_snoop_seq_d),
         .dout(bus_snoop_seq_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) bus_snoop_hold_req_latch(
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
         .scin(siv[bus_snoop_hold_req_offset:bus_snoop_hold_req_offset + `MM_THREADS - 1]),
         .scout(sov[bus_snoop_hold_req_offset:bus_snoop_hold_req_offset + `MM_THREADS - 1]),
         .din(bus_snoop_hold_req_d),
         .dout(bus_snoop_hold_req_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) bus_snoop_hold_ack_latch(
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
         .scin(siv[bus_snoop_hold_ack_offset:bus_snoop_hold_ack_offset + `MM_THREADS - 1]),
         .scout(sov[bus_snoop_hold_ack_offset:bus_snoop_hold_ack_offset + `MM_THREADS - 1]),
         .din(bus_snoop_hold_ack_d),
         .dout(bus_snoop_hold_ack_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) bus_snoop_hold_done_latch(
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
         .scin(siv[bus_snoop_hold_done_offset:bus_snoop_hold_done_offset + `MM_THREADS - 1]),
         .scout(sov[bus_snoop_hold_done_offset:bus_snoop_hold_done_offset + `MM_THREADS - 1]),
         .din(bus_snoop_hold_done_d),
         .dout(bus_snoop_hold_done_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) tlbi_complete_latch(
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
         .scin(siv[tlbi_complete_offset:tlbi_complete_offset + `MM_THREADS - 1]),
         .scout(sov[tlbi_complete_offset:tlbi_complete_offset + `MM_THREADS - 1]),
         .din(tlbi_complete_d),
         .dout(tlbi_complete_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) local_barrier_latch(
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
         .scin(siv[local_barrier_offset:local_barrier_offset + `MM_THREADS - 1]),
         .scout(sov[local_barrier_offset:local_barrier_offset + `MM_THREADS - 1]),
         .din(local_barrier_d),
         .dout(local_barrier_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) global_barrier_latch(
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
         .scin(siv[global_barrier_offset:global_barrier_offset + `MM_THREADS - 1]),
         .scout(sov[global_barrier_offset:global_barrier_offset + `MM_THREADS - 1]),
         .din(global_barrier_d),
         .dout(global_barrier_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_illeg_instr_latch(
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
         .scin(siv[ex3_illeg_instr_offset:ex3_illeg_instr_offset + `MM_THREADS - 1]),
         .scout(sov[ex3_illeg_instr_offset:ex3_illeg_instr_offset + `MM_THREADS - 1]),
         .din(ex3_illeg_instr_d),
         .dout(ex3_illeg_instr_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_illeg_instr_latch(
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
         .scin(siv[ex4_illeg_instr_offset:ex4_illeg_instr_offset + `MM_THREADS - 1]),
         .scout(sov[ex4_illeg_instr_offset:ex4_illeg_instr_offset + `MM_THREADS - 1]),
         .din(ex4_illeg_instr_d),
         .dout(ex4_illeg_instr_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_illeg_instr_latch(
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
         .scin(siv[ex5_illeg_instr_offset:ex5_illeg_instr_offset + `MM_THREADS - 1]),
         .scout(sov[ex5_illeg_instr_offset:ex5_illeg_instr_offset + `MM_THREADS - 1]),
         .din(ex5_illeg_instr_d),
         .dout(ex5_illeg_instr_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex6_illeg_instr_latch(
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
         .scin(siv[ex6_illeg_instr_offset:ex6_illeg_instr_offset + `MM_THREADS - 1]),
         .scout(sov[ex6_illeg_instr_offset:ex6_illeg_instr_offset + `MM_THREADS - 1]),
         .din(ex6_illeg_instr_d),
         .dout(ex6_illeg_instr_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex7_illeg_instr_latch(
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
         .scin(siv[ex7_illeg_instr_offset:ex7_illeg_instr_offset + `MM_THREADS - 1]),
         .scout(sov[ex7_illeg_instr_offset:ex7_illeg_instr_offset + `MM_THREADS - 1]),
         .din(ex7_illeg_instr_d),
         .dout(ex7_illeg_instr_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_ivax_lpid_reject_latch(
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
         .scin(siv[ex3_ivax_lpid_reject_offset:ex3_ivax_lpid_reject_offset + `MM_THREADS - 1]),
         .scout(sov[ex3_ivax_lpid_reject_offset:ex3_ivax_lpid_reject_offset + `MM_THREADS - 1]),
         .din(ex3_ivax_lpid_reject_d),
         .dout(ex3_ivax_lpid_reject_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_ivax_lpid_reject_latch(
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
         .scin(siv[ex4_ivax_lpid_reject_offset:ex4_ivax_lpid_reject_offset + `MM_THREADS - 1]),
         .scout(sov[ex4_ivax_lpid_reject_offset:ex4_ivax_lpid_reject_offset + `MM_THREADS - 1]),
         .din(ex4_ivax_lpid_reject_d),
         .dout(ex4_ivax_lpid_reject_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) local_snoop_reject_latch(
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
         .scin(siv[local_snoop_reject_offset:local_snoop_reject_offset + `MM_THREADS - 1]),
         .scout(sov[local_snoop_reject_offset:local_snoop_reject_offset + `MM_THREADS - 1]),
         .din(local_snoop_reject_d),
         .dout(local_snoop_reject_q)
      );
      
      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) snoop_coming_latch(
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
         .scin(siv[snoop_coming_offset:snoop_coming_offset + 5 - 1]),
         .scout(sov[snoop_coming_offset:snoop_coming_offset + 5 - 1]),
         .din(snoop_coming_d),
         .dout(snoop_coming_q)
      );
      
      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) snoop_valid_latch(
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
         .scin(siv[snoop_valid_offset:snoop_valid_offset + 3 - 1]),
         .scout(sov[snoop_valid_offset:snoop_valid_offset + 3 - 1]),
         .din(snoop_valid_d),
         .dout(snoop_valid_q)
      );
      
      tri_rlmreg_p #(.WIDTH(35), .INIT(0), .NEEDS_SRESET(1)) snoop_attr_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(snoop_coming_q[3]),
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
         .act(snoop_coming_q[3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[snoop_vpn_offset:snoop_vpn_offset + `EPN_WIDTH - 1]),
         .scout(sov[snoop_vpn_offset:snoop_vpn_offset + `EPN_WIDTH - 1]),
         .din(snoop_vpn_d[52 - `EPN_WIDTH:51]),
         .dout(snoop_vpn_q[52 - `EPN_WIDTH:51])
      );
      
      tri_rlmreg_p #(.WIDTH(26), .INIT(0), .NEEDS_SRESET(1)) snoop_attr_clone_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(snoop_coming_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[snoop_attr_clone_offset:snoop_attr_clone_offset + 26 - 1]),
         .scout(sov[snoop_attr_clone_offset:snoop_attr_clone_offset + 26 - 1]),
         .din(snoop_attr_clone_d),
         .dout(snoop_attr_clone_q)
      );
      
      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) snoop_attr_tlb_spec_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(snoop_coming_q[3]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[snoop_attr_tlb_spec_offset:snoop_attr_tlb_spec_offset + 2 - 1]),
         .scout(sov[snoop_attr_tlb_spec_offset:snoop_attr_tlb_spec_offset + 2 - 1]),
         .din(snoop_attr_tlb_spec_d),
         .dout(snoop_attr_tlb_spec_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) snoop_vpn_clone_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(snoop_coming_q[4]),
         .thold_b(pc_func_slp_sl_thold_0_b),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_sl_force),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .d_mode(lcb_d_mode_dc),
         .scin(siv[snoop_vpn_clone_offset:snoop_vpn_clone_offset + `EPN_WIDTH - 1]),
         .scout(sov[snoop_vpn_clone_offset:snoop_vpn_clone_offset + `EPN_WIDTH - 1]),
         .din(snoop_vpn_clone_d[52 - `EPN_WIDTH:51]),
         .dout(snoop_vpn_clone_q[52 - `EPN_WIDTH:51])
      );
      
      tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) snoop_ack_latch(
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
         .scin(siv[snoop_ack_offset:snoop_ack_offset + 3 - 1]),
         .scout(sov[snoop_ack_offset:snoop_ack_offset + 3 - 1]),
         .din(snoop_ack_d),
         .dout(snoop_ack_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) mm_xu_quiesce_latch(
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
         .scin(siv[mm_xu_quiesce_offset:mm_xu_quiesce_offset + `MM_THREADS - 1]),
         .scout(sov[mm_xu_quiesce_offset:mm_xu_quiesce_offset + `MM_THREADS - 1]),
         .din(mm_xu_quiesce_d),
         .dout(mm_xu_quiesce_q)
      );
      
      tri_rlmreg_p #(.WIDTH(4*`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) mm_pc_quiesce_latch(
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
         .scin(siv[mm_pc_quiesce_offset:mm_pc_quiesce_offset + 4*`MM_THREADS - 1]),
         .scout(sov[mm_pc_quiesce_offset:mm_pc_quiesce_offset + 4*`MM_THREADS - 1]),
         .din(mm_pc_quiesce_d),
         .dout(mm_pc_quiesce_q)
      );
      
      
      tri_rlmreg_p #(.WIDTH(9), .INIT(0), .NEEDS_SRESET(1)) an_ac_back_inv_latch(
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
         .scin(siv[an_ac_back_inv_offset:an_ac_back_inv_offset + 9 - 1]),
         .scout(sov[an_ac_back_inv_offset:an_ac_back_inv_offset + 9 - 1]),
         .din(an_ac_back_inv_d),
         .dout(an_ac_back_inv_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`REAL_ADDR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) an_ac_back_inv_addr_latch(
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
         .scin(siv[an_ac_back_inv_addr_offset:an_ac_back_inv_addr_offset + `REAL_ADDR_WIDTH - 1]),
         .scout(sov[an_ac_back_inv_addr_offset:an_ac_back_inv_addr_offset + `REAL_ADDR_WIDTH - 1]),
         .din(an_ac_back_inv_addr_d[64 - `REAL_ADDR_WIDTH:63]),
         .dout(an_ac_back_inv_addr_q[64 - `REAL_ADDR_WIDTH:63])
      );
      
      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) an_ac_back_inv_lpar_id_latch(
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
         .scin(siv[an_ac_back_inv_lpar_id_offset:an_ac_back_inv_lpar_id_offset + `LPID_WIDTH - 1]),
         .scout(sov[an_ac_back_inv_lpar_id_offset:an_ac_back_inv_lpar_id_offset + `LPID_WIDTH - 1]),
         .din(an_ac_back_inv_lpar_id_d[0:`LPID_WIDTH - 1]),
         .dout(an_ac_back_inv_lpar_id_q[0:`LPID_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(2), .INIT(1), .NEEDS_SRESET(1)) lsu_tokens_latch(
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
         .scin(siv[lsu_tokens_offset:lsu_tokens_offset + 2 - 1]),
         .scout(sov[lsu_tokens_offset:lsu_tokens_offset + 2 - 1]),
         .din(lsu_tokens_d[0:1]),
         .dout(lsu_tokens_q[0:1])
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(1)) lsu_req_latch(
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
         .scin(siv[lsu_req_offset:lsu_req_offset + `MM_THREADS - 1]),
         .scout(sov[lsu_req_offset:lsu_req_offset + `MM_THREADS - 1]),
         .din(lsu_req_d),
         .dout(lsu_req_q)
      );
      
      tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) lsu_ttype_latch(
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
         .scin(siv[lsu_ttype_offset:lsu_ttype_offset + 2 - 1]),
         .scout(sov[lsu_ttype_offset:lsu_ttype_offset + 2 - 1]),
         .din(lsu_ttype_d[0:1]),
         .dout(lsu_ttype_q[0:1])
      );
      
      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lsu_ubits_latch(
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
         .scin(siv[lsu_ubits_offset:lsu_ubits_offset + 4 - 1]),
         .scout(sov[lsu_ubits_offset:lsu_ubits_offset + 4 - 1]),
         .din(lsu_ubits_d[0:3]),
         .dout(lsu_ubits_q[0:3])
      );
      
      tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) lsu_wimge_latch(
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
         .scin(siv[lsu_wimge_offset:lsu_wimge_offset + 5 - 1]),
         .scout(sov[lsu_wimge_offset:lsu_wimge_offset + 5 - 1]),
         .din(lsu_wimge_d[0:4]),
         .dout(lsu_wimge_q[0:4])
      );
      
      tri_rlmreg_p #(.WIDTH(`REAL_ADDR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lsu_addr_latch(
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
         .scin(siv[lsu_addr_offset:lsu_addr_offset + `REAL_ADDR_WIDTH - 1]),
         .scout(sov[lsu_addr_offset:lsu_addr_offset + `REAL_ADDR_WIDTH - 1]),
         .din(lsu_addr_d[64 - `REAL_ADDR_WIDTH:63]),
         .dout(lsu_addr_q[64 - `REAL_ADDR_WIDTH:63])
      );
      
      tri_rlmreg_p #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lsu_lpid_latch(
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
         .scin(siv[lsu_lpid_offset:lsu_lpid_offset + `LPID_WIDTH - 1]),
         .scout(sov[lsu_lpid_offset:lsu_lpid_offset + `LPID_WIDTH - 1]),
         .din(lsu_lpid_d[0:`LPID_WIDTH - 1]),
         .dout(lsu_lpid_q[0:`LPID_WIDTH - 1])
      );
      
      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lsu_ind_latch(
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
         .scin(siv[lsu_ind_offset]),
         .scout(sov[lsu_ind_offset]),
         .din(lsu_ind_d),
         .dout(lsu_ind_q)
      );
      
      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lsu_gs_latch(
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
         .scin(siv[lsu_gs_offset]),
         .scout(sov[lsu_gs_offset]),
         .din(lsu_gs_d),
         .dout(lsu_gs_q)
      );
      
      tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lsu_lbit_latch(
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
         .scin(siv[lsu_lbit_offset]),
         .scout(sov[lsu_lbit_offset]),
         .din(lsu_lbit_d),
         .dout(lsu_lbit_q)
      );
      
      tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) power_managed_latch(
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
         .scin(siv[power_managed_offset:power_managed_offset + 4 - 1]),
         .scout(sov[power_managed_offset:power_managed_offset + 4 - 1]),
         .din(power_managed_d),
         .dout(power_managed_q)
      );
      
      tri_rlmreg_p #(.WIDTH(4), .INIT(MMQ_INVAL_CSWITCH_0TO3), .NEEDS_SRESET(1)) cswitch_latch(
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
         .scin(siv[cswitch_offset:cswitch_offset + 4 - 1]),
         .scout(sov[cswitch_offset:cswitch_offset + 4 - 1]),
         .din(cswitch_q),
         .dout(cswitch_q)
      );
      
      tri_rlmreg_p #(.WIDTH(`MM_THREADS+2), .INIT(0), .NEEDS_SRESET(1)) tlbwe_back_inv_latch(
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
         .scin(siv[tlbwe_back_inv_offset:tlbwe_back_inv_offset + `MM_THREADS + 2 - 1]),
         .scout(sov[tlbwe_back_inv_offset:tlbwe_back_inv_offset + `MM_THREADS + 2 - 1]),
         .din(tlbwe_back_inv_d[0:`MM_THREADS+1]),
         .dout(tlbwe_back_inv_q[0:`MM_THREADS+1])
      );
      
      tri_rlmreg_p #(.WIDTH(`EPN_WIDTH), .INIT(0), .NEEDS_SRESET(1)) tlbwe_back_inv_addr_latch(
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
         .scin(siv[tlbwe_back_inv_addr_offset:tlbwe_back_inv_addr_offset + `EPN_WIDTH - 1]),
         .scout(sov[tlbwe_back_inv_addr_offset:tlbwe_back_inv_addr_offset + `EPN_WIDTH - 1]),
         .din(tlbwe_back_inv_addr_d[0:`EPN_WIDTH - 1]),
         .dout(tlbwe_back_inv_addr_q[0:`EPN_WIDTH - 1])
      );
      
      tri_rlmreg_p #(.WIDTH(35), .INIT(0), .NEEDS_SRESET(1)) tlbwe_back_inv_attr_latch(
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
         .scin(siv[tlbwe_back_inv_attr_offset:tlbwe_back_inv_attr_offset + 35 - 1]),
         .scout(sov[tlbwe_back_inv_attr_offset:tlbwe_back_inv_attr_offset + 35 - 1]),
         .din(tlbwe_back_inv_attr_d),
         .dout(tlbwe_back_inv_attr_q)
      );
      
      tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) inv_seq_inprogress_latch(
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
         .scin(siv[inv_seq_inprogress_offset:inv_seq_inprogress_offset + 6 - 1]),
         .scout(sov[inv_seq_inprogress_offset:inv_seq_inprogress_offset + 6 - 1]),
         .din(inv_seq_inprogress_d),
         .dout(inv_seq_inprogress_q)
      );
      
      tri_rlmreg_p #(.WIDTH(13), .INIT(0), .NEEDS_SRESET(1)) xu_mm_ccr2_notlb_latch(
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
         .scin(siv[xu_mm_ccr2_notlb_offset:xu_mm_ccr2_notlb_offset + 13 - 1]),
         .scout(sov[xu_mm_ccr2_notlb_offset:xu_mm_ccr2_notlb_offset + 13 - 1]),
         .din(xu_mm_ccr2_notlb_d),
         .dout(xu_mm_ccr2_notlb_q)
      );
      
      tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) spare_latch(
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
         .scin(siv[spare_offset:spare_offset + 16 - 1]),
         .scout(sov[spare_offset:spare_offset + 16 - 1]),
         .din(spare_q),
         .dout(spare_q)
      );
      
      tri_regk #(.WIDTH(`MM_THREADS), .INIT(0), .NEEDS_SRESET(0)) epcr_dgtmi_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(tiup),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_nsl_force),
         .d_mode(lcb_d_mode_dc),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .thold_b(pc_func_slp_nsl_thold_0_b),
         .scin({`MM_THREADS{tidn}}),
         .din(xu_mm_spr_epcr_dgtmi),
         .dout(xu_mm_epcr_dgtmi_q)
      );
      
      tri_regk #(.WIDTH(`LPID_WIDTH), .INIT(0), .NEEDS_SRESET(0)) lpidr_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(tiup),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_nsl_force),
         .d_mode(lcb_d_mode_dc),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .thold_b(pc_func_slp_nsl_thold_0_b),
         .scin({`LPID_WIDTH{tidn}}),
         .din(lpidr),
         .dout(lpidr_q)
      );
      
      tri_regk #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(0)) mmucr1_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(tiup),
         .sg(pc_sg_0),
         .force_t(pc_func_slp_nsl_force),
         .d_mode(lcb_d_mode_dc),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .thold_b(pc_func_slp_nsl_thold_0_b),
         .scin({8{tidn}}),
         .din(mmucr1),
         .dout(mmucr1_q)
      );
      
      tri_regk #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(0)) mmucr1_csinv_latch(
         .nclk(nclk),
         .vd(vdd),
         .gd(gnd),
         .act(tiup),
         .force_t(pc_func_slp_nsl_force),
         .sg(pc_sg_0),
         .d_mode(lcb_d_mode_dc),
         .delay_lclkr(lcb_delay_lclkr_dc[0]),
         .mpw1_b(lcb_mpw1_dc_b[0]),
         .mpw2_b(lcb_mpw2_dc_b),
         .thold_b(pc_func_slp_nsl_thold_0_b),
         .scin({2{tidn}}),
         .din(mmucr1_csinv),
         .dout(mmucr1_csinv_q)
      );

      
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
      
      tri_lcbor perv_nsl_lcbor(
         .clkoff_b(lcb_clkoff_dc_b),
         .thold(pc_func_slp_nsl_thold_0),
         .sg(pc_fce_0),
         .act_dis(tidn),
         .force_t(pc_func_slp_nsl_force),
         .thold_b(pc_func_slp_nsl_thold_0_b)
      );
      
      assign siv[0:scan_right] = {sov[1:scan_right], ac_func_scan_in};
      assign ac_func_scan_out = sov[0];
      
endmodule

