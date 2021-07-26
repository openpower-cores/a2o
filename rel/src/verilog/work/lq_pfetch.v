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

`timescale 1 ns / 1 ns

//
//  Description:  XU LSU Data Prefetcher
//
//*****************************************************************************

`include "tri_a2o.vh"

//   parameter                                 EXPAND_TYPE = 2;
//   parameter                                 GPR_WIDTH_ENC = 6;		// 5 = 32bit mode, 6 = 64bit mode
//   parameter                                 CL_SIZE = 6;		// 6 => 64B CLINE, 7 => 128B CLINE
//   parameter                                 THREADS = 2;		// Number of Threads in the system
//   parameter                                 REAL_IFAR_WIDTH = 42;		// width of the read address
//   parameter                                 ITAG_SIZE_ENC = 7;
//   parameter                                 LDSTQ_ENTRIES = 16;		// Order Queue Size
//   `define                                 PF_IFAR_WIDTH  12 		// number of IAR bits used by prefetch
//   `define                                 PFETCH_INITIAL_DEPTH  0		// the initial value for the SPR that determines how many lines to prefetch
//   `define                                 PFETCH_Q_SIZE_ENC  3		// number of bits to address queue size (3 => 8 entries, 4 => 16 entries)
//   `define                                 PFETCH_Q_SIZE  8		// number of entries in prefetch queue

module lq_pfetch(
   rv_lq_rv1_i0_vld,
   rv_lq_rv1_i0_rte_lq,
   rv_lq_rv1_i0_isLoad,
   rv_lq_rv1_i0_ifar,
   rv_lq_rv1_i0_itag,
   rv_lq_rv1_i1_vld,
   rv_lq_rv1_i1_rte_lq,
   rv_lq_rv1_i1_isLoad,
   rv_lq_rv1_i1_ifar,
   rv_lq_rv1_i1_itag,
   iu_lq_cp_flush,
   ctl_pf_clear_queue,
   odq_pf_report_tid,
   odq_pf_report_itag,
   odq_pf_resolved,
   dcc_pf_ex5_eff_addr,
   dcc_pf_ex5_req_val_4pf,
   dcc_pf_ex5_act,
   dcc_pf_ex5_loadmiss,
   dcc_pf_ex5_thrd_id,
   dcc_pf_ex5_itag,
   spr_pf_spr_dscr_lsd,
   spr_pf_spr_dscr_snse,
   spr_pf_spr_dscr_sse,
   spr_pf_spr_dscr_dpfd,
   spr_pf_spr_pesr,
   pf_dec_req_addr,
   pf_dec_req_thrd,
   pf_dec_req_val,
   dec_pf_ack,
   pf_empty,
   pc_lq_inj_prefetcher_parity,
   lq_pc_err_prefetcher_parity,
   vdd,
   gnd,
   vcs,
   nclk,
   sg_0,
   func_sl_thold_0_b,
   func_sl_force,
   d_mode_dc,
   delay_lclkr_dc,
   clkoff_dc_b,
   mpw1_dc_b,
   mpw2_dc_b,
   scan_in,
   scan_out,
   abst_sl_thold_0,
   ary_nsl_thold_0,
   time_sl_thold_0,
   repr_sl_thold_0,
   g8t_clkoff_dc_b,
   pc_lq_ccflush_dc,
   an_ac_scan_dis_dc_b,
   an_ac_scan_diag_dc,
   g8t_d_mode_dc,
   g8t_mpw1_dc_b,
   g8t_mpw2_dc_b,
   g8t_delay_lclkr_dc,
   pc_xu_abist_g8t_wenb_q,
   pc_xu_abist_g8t1p_renb_0_q,
   pc_xu_abist_di_0_q,
   pc_xu_abist_g8t_bw_1_q,
   pc_xu_abist_g8t_bw_0_q,
   pc_xu_abist_waddr_0_q,
   pc_xu_abist_raddr_0_q,
   an_ac_lbist_ary_wrt_thru_dc,
   pc_xu_abist_ena_dc,
   pc_xu_abist_wl64_comp_ena_q,
   pc_xu_abist_raw_dc_b,
   pc_xu_abist_g8t_dcomp_q,
   abst_scan_in,
   time_scan_in,
   repr_scan_in,
   abst_scan_out,
   time_scan_out,
   repr_scan_out,
   bolt_sl_thold_0,
   pc_bo_enable_2,
   pc_xu_bo_reset,
   pc_xu_bo_unload,
   pc_xu_bo_repair,
   pc_xu_bo_shdata,
   pc_xu_bo_select,
   xu_pc_bo_fail,
   xu_pc_bo_diagout
);

   // iar and itag of the load instruction from dispatch
   input [0:`THREADS-1]                      rv_lq_rv1_i0_vld;
   input                                     rv_lq_rv1_i0_rte_lq;
   input                                     rv_lq_rv1_i0_isLoad;
   input [61-`PF_IFAR_WIDTH+1:61]            rv_lq_rv1_i0_ifar;
   input [0:`ITAG_SIZE_ENC-1]                rv_lq_rv1_i0_itag;
   input [0:`THREADS-1]                      rv_lq_rv1_i1_vld;
   input                                     rv_lq_rv1_i1_rte_lq;
   input                                     rv_lq_rv1_i1_isLoad;
   input [61-`PF_IFAR_WIDTH+1:61]            rv_lq_rv1_i1_ifar;
   input [0:`ITAG_SIZE_ENC-1]                rv_lq_rv1_i1_itag;

   // flush interface
   input [0:`THREADS-1]                      iu_lq_cp_flush;

   input                                     ctl_pf_clear_queue;

   // release itag to pfetch
   input [0:`THREADS-1]                      odq_pf_report_tid;
   input [0:`ITAG_SIZE_ENC-1]                odq_pf_report_itag;
   input                                     odq_pf_resolved;

   // EA of load miss that is valid for pre-fetching
   input [64-(2**`GPR_WIDTH_ENC):59]         dcc_pf_ex5_eff_addr;
   input                                     dcc_pf_ex5_req_val_4pf;
   input                                     dcc_pf_ex5_act;
   input                                     dcc_pf_ex5_loadmiss;
   input [0:`THREADS-1]                      dcc_pf_ex5_thrd_id;
   input [0:`ITAG_SIZE_ENC-1]                dcc_pf_ex5_itag;

   input [0:`THREADS-1]                      spr_pf_spr_dscr_lsd;
   input [0:`THREADS-1]                      spr_pf_spr_dscr_snse;
   input [0:`THREADS-1]                      spr_pf_spr_dscr_sse;
   input [0:3*`THREADS-1]                    spr_pf_spr_dscr_dpfd;
   input [0:31]                              spr_pf_spr_pesr;

   // EA of prefetch request
   output [64-(2**`GPR_WIDTH_ENC):63-`CL_SIZE] pf_dec_req_addr;
   output [0:`THREADS-1]                     pf_dec_req_thrd;
   output                                    pf_dec_req_val;
   input                                     dec_pf_ack;

   output [0:`THREADS-1]                     pf_empty;

   // parity error signals
   input                                     pc_lq_inj_prefetcher_parity;
   output                                    lq_pc_err_prefetcher_parity;

   // Pervasive


   inout                                     vcs;


   inout                                     vdd;


   inout                                     gnd;

   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

   input [0:`NCLK_WIDTH-1]                   nclk;
   input                                     sg_0;
   input                                     func_sl_thold_0_b;
   input                                     func_sl_force;
   input                                     d_mode_dc;
   input                                     delay_lclkr_dc;
   input                                     clkoff_dc_b;
   input                                     mpw1_dc_b;
   input                                     mpw2_dc_b;

   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

   input                                     scan_in;

   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

   output                                    scan_out;

   // array pervasive
   input                                     abst_sl_thold_0;
   input                                     ary_nsl_thold_0;
   input                                     time_sl_thold_0;
   input                                     repr_sl_thold_0;
   input                                     g8t_clkoff_dc_b;
   input                                     pc_lq_ccflush_dc;
   input                                     an_ac_scan_dis_dc_b;
   input                                     an_ac_scan_diag_dc;
   input                                     g8t_d_mode_dc;
   input [0:4]                               g8t_mpw1_dc_b;
   input                                     g8t_mpw2_dc_b;
   input [0:4]                               g8t_delay_lclkr_dc;
   // ABIST
   input                                     pc_xu_abist_g8t_wenb_q;
   input                                     pc_xu_abist_g8t1p_renb_0_q;
   input [0:3]                               pc_xu_abist_di_0_q;
   input                                     pc_xu_abist_g8t_bw_1_q;
   input                                     pc_xu_abist_g8t_bw_0_q;
   input [0:4]                               pc_xu_abist_waddr_0_q;
   input [0:4]                               pc_xu_abist_raddr_0_q;
   input                                     an_ac_lbist_ary_wrt_thru_dc;
   input                                     pc_xu_abist_ena_dc;
   input                                     pc_xu_abist_wl64_comp_ena_q;
   input                                     pc_xu_abist_raw_dc_b;
   input [0:3]                               pc_xu_abist_g8t_dcomp_q;
   // Scan

   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

   input [0:1]                               abst_scan_in;

   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

   input                                     time_scan_in;

   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

   input                                     repr_scan_in;

   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

   output [0:1]                              abst_scan_out;

   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

   output                                    time_scan_out;

   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

   output                                    repr_scan_out;
   // BOLT-ON
   input                                     bolt_sl_thold_0;
   input                                     pc_bo_enable_2;		// general bolt-on enable
   input                                     pc_xu_bo_reset;		// reset
   input                                     pc_xu_bo_unload;		// unload sticky bits
   input                                     pc_xu_bo_repair;		// execute sticky bit decode
   input                                     pc_xu_bo_shdata;		// shift data for timing write and diag loop
   input [0:1]                               pc_xu_bo_select;		// select for mask and hier writes
   output [0:1]                              xu_pc_bo_fail;		   // fail/no-fix reg

   output [0:1]                              xu_pc_bo_diagout;

   //--------------------------
   // signals
   //--------------------------
   wire [0:`THREADS-1]                       pfetch_dis_thrd;
   reg                                       pf1_disable;
   reg                                       ex6_pf_disable;

   wire [58:63] 			                     pf_dscr_reg[0:`THREADS-1];
   reg [58:63] 				                  pf1_dscr;
   wire [0:`THREADS-1] 			               rv_i0_vld_d;
   wire [0:`THREADS-1] 			               rv_i0_vld_q;
   wire                                      rv_i0_rte_lq_q;
   wire                                      rv_i0_isLoad_q;
   wire [61-`PF_IFAR_WIDTH+1:61] 	         rv_i0_ifar_q;
   wire [0:`ITAG_SIZE_ENC-1] 		            rv_i0_itag_q;
   wire [0:`THREADS-1] 			               rv_i1_vld_d;
   wire [0:`THREADS-1] 			               rv_i1_vld_q;
   wire                                      rv_i1_rte_lq_q;
   wire                                      rv_i1_isLoad_q;
   wire [61-`PF_IFAR_WIDTH+1:61] 	         rv_i1_ifar_q;
   wire [0:`ITAG_SIZE_ENC-1] 		            rv_i1_itag_q;
   wire [0:`THREADS-1] 			               cp_flush_q;
   wire [0:`THREADS-1] 			               cp_flush2_q;
   wire [0:`THREADS-1] 			               cp_flush3_q;
   wire [0:`THREADS-1] 			               cp_flush4_q;

   wire                                      new_itag_i0_val;
   wire                                      new_itag_i1_val;
   wire [0:`LDSTQ_ENTRIES-1] 		            pf_iar_i0_wen;
   wire [0:`LDSTQ_ENTRIES-1] 		            pf_iar_val_for_i1;
   wire [0:`LDSTQ_ENTRIES-1] 		            pf_iar_i1_wen;
   wire [61-`PF_IFAR_WIDTH+1:61] 	         pf_iar_tbl_d[0:`LDSTQ_ENTRIES-1];
   wire [61-`PF_IFAR_WIDTH+1:61] 	         pf_iar_tbl_q[0:`LDSTQ_ENTRIES-1];
   wire [0:`ITAG_SIZE_ENC-1] 		            pf_itag_tbl_d[0:`LDSTQ_ENTRIES-1];
   wire [0:`ITAG_SIZE_ENC-1] 		            pf_itag_tbl_q[0:`LDSTQ_ENTRIES-1];
   wire [0:`THREADS-1] 			               pf_tid_tbl_d[0:`LDSTQ_ENTRIES-1];
   wire [0:`THREADS-1] 			               pf_tid_tbl_q[0:`LDSTQ_ENTRIES-1];
   wire [0:`LDSTQ_ENTRIES-1] 		            pf_iar_tbl_val_d;
   wire [0:`LDSTQ_ENTRIES-1] 		            pf_iar_tbl_val_q;
   wire [0:`LDSTQ_ENTRIES-1] 		            ex5_itag_match;
   reg [61-`PF_IFAR_WIDTH+1:61] 		         ex5_iar;
   wire [61-`PF_IFAR_WIDTH+1:61] 	         ex6_iar_q;
   wire [61-`PF_IFAR_WIDTH+1:61] 	         ex7_iar_q;
   wire [61-`PF_IFAR_WIDTH+1:61] 	         ex8_iar_q;
   wire [0:`LDSTQ_ENTRIES-1] 		            pf_iar_tbl_reset;
   wire                                      odq_resolved_q;
   wire [0:`ITAG_SIZE_ENC-1] 		            odq_report_itag_q;
   wire [0:`THREADS-1] 			               odq_report_tid_q;

   wire [0:21] 				                  pfq_stride_d[0:`PFETCH_Q_SIZE-1];
   wire [0:21] 				                  pfq_stride_q[0:`PFETCH_Q_SIZE-1];
   wire [64-(2**`GPR_WIDTH_ENC):59] 	      pfq_data_ea_d[0:`PFETCH_Q_SIZE-1];
   wire [64-(2**`GPR_WIDTH_ENC):59] 	      pfq_data_ea_q[0:`PFETCH_Q_SIZE-1];
   wire [0:`PFETCH_Q_SIZE-1] 		            pfq_dup_flag_d;
   wire [0:`PFETCH_Q_SIZE-1] 		            pfq_dup_flag_q;
   wire [0:`THREADS-1] 			               pfq_thrd_d[0:`PFETCH_Q_SIZE-1];
   wire [0:`THREADS-1] 			               pfq_thrd_q[0:`PFETCH_Q_SIZE-1];
   wire [61:63] 			                     pfq_dscr_d[0:`PFETCH_Q_SIZE-1];
   wire [61:63] 			                     pfq_dscr_q[0:`PFETCH_Q_SIZE-1];
   wire [0:`PFETCH_Q_SIZE-1] 		            pfq_wen;
   wire [0:`PFETCH_Q_SIZE_ENC-1] 	         pfq_wrt_ptr_plus1;
   wire [0:`PFETCH_Q_SIZE_ENC-1] 	         pfq_wrt_ptr_d;
   wire [0:`PFETCH_Q_SIZE_ENC-1] 	         pfq_wrt_ptr_q;
   wire [0:`PFETCH_Q_SIZE_ENC-1] 	         pfq_rd_ptr_d;
   wire [0:`PFETCH_Q_SIZE_ENC-1] 	         pfq_rd_ptr_q;
   wire                                      pfq_full_d;
   wire                                      pfq_full_q;
   wire                                      pfq_wrt_val;
   reg [0:21] 				     pf3_stride_d;
   wire [0:21] 				     pf3_stride_q;
   reg [64-(2**`GPR_WIDTH_ENC):59] 	     pfq_rd_data_ea;
   reg                                       pfq_rd_dup_flag;
   reg [0:`THREADS-1] 			     pfq_rd_thrd;
   reg [0:`THREADS-1] 			     pfq_thrd_v;
   reg [61:63] 				     pfq_rd_dscr;
   wire                                      pf_rd_val;
   wire                                      pf_idle;
   wire                                      pf_gen;
   wire                                      pf_send;
   wire                                      pf_next;
   wire                                      pf_done;
   reg                                       pf_nxt_idle;
   reg                                       pf_nxt_gen;
   reg                                       pf_nxt_send;
   reg                                       pf_nxt_next;
   reg                                       pf_nxt_done;
   wire [0:4] 				                     pf_nxt_state;
   wire [0:4] 				                     pf_state_q;
   wire [0:2] 				                     pf_count_d;
   wire [0:2] 				                     pf_count_q;
   wire [0:21] 				                  pf1_new_stride_d;
   wire [0:21] 				                  pf1_new_stride_q;
   wire [0:21] 				                  pf1_rpt_stride_q;
   wire                                      stride_match;
   wire                                      generate_pfetch;
   wire [0:2] 				                     nxt_state_cntrl;
   wire [0:1] 				                     burst_cnt_inc;
   wire [0:21] 				                  pf2_next_stride_d;
   wire [0:21] 				                  pf2_stride_q;
   wire [61-`PF_IFAR_WIDTH+1:61] 	         pf1_iar_d;
   wire [61-`PF_IFAR_WIDTH+1:61] 	         pf1_iar_q;
   wire [61-`PF_IFAR_WIDTH+1:61] 	         pf2_iar_q;
   wire [64-(2**`GPR_WIDTH_ENC):59] 	      pf1_data_ea_d;
   wire [64-(2**`GPR_WIDTH_ENC):59] 	      pf1_data_ea_q;
   wire [64-(2**`GPR_WIDTH_ENC):59] 	      pf1_new_data_ea;
   wire [64-(2**`GPR_WIDTH_ENC):59] 	      pf2_data_ea_d;
   wire [64-(2**`GPR_WIDTH_ENC):59] 	      pf2_data_ea_q;
   wire [0:1] 				                     pf1_pf_state_d;
   wire [0:1] 				                     pf1_pf_state_q;
   wire [0:1] 				                     pf2_next_state_d;
   wire [0:1] 				                     pf1_update_state;
   wire [0:1] 				                     pf2_pf_state_q;
   wire [0:1] 				                     pf1_burst_cnt_d;
   wire [0:1] 				                     pf1_burst_cnt_q;
   wire [0:1] 				                     pf2_burst_cnt_d;
   wire [0:1] 				                     pf2_burst_cnt_q;
   wire                                      pf1_dup_flag_d;
   wire                                      pf1_dup_flag_q;
   wire [0:2] 				                     ex8_pf_hits_d;
   wire [0:2] 				                     ex8_pf_hits_q;
   wire [0:1] 				                     ex8_rpt_pe_d;
   wire [0:1] 				                     ex8_rpt_pe_q;
   wire [38:59] 			                     ex8_last_dat_addr_q;
   wire [0:21] 				                  ex8_stride_q;
   wire [0:1] 				                     ex8_pf_state_q;
   wire [0:1] 				                     ex8_burst_cnt_q;
   wire                                      ex8_dup_flag_q;
   wire [0:2] 				                     pf1_hits_d;
   wire [0:2] 				                     pf1_hits_q;
   wire [0:1] 				                     pf1_rpt_pe_q;
   wire [0:2] 				                     pf2_hits_q;
   wire [0:1] 				                     pf2_rpt_pe_q;
   wire [0:`THREADS-1] 			               pf1_thrd_d;
   wire [0:`THREADS-1] 			               pf1_thrd_q;
   wire [0:`THREADS-1] 			               pf2_thrd_q;
   wire [0:`THREADS-1] 			               pf3_thrd_d;
   wire [0:`THREADS-1] 			               pf3_thrd_q;
   wire                                      pf2_gen_pfetch_q;
   wire                                      pf2_valid;
   reg                                       old_rpt_lru;
   wire                                      new_rpt_lru;
   wire [0:31] 				                  rpt_lru_d;
   wire [0:31] 				                  rpt_lru_q;

   wire [0:1] 				                     rpt_wen;
   wire [0:1] 				                     rpt_rd_act;
   wire [0:1] 				                     rpt_byp_val;
   wire [0:4] 				                     rpt_wrt_addr;
   wire [0:69] 				                  rpt_data_in;
   wire [0:4] 				                     rpt_rd_addr;
   wire [0:139] 			                     rpt_data_out;
   wire [0:69] 				                  rpt_byp_dat_d;
   wire [0:69] 				                  rpt_byp_dat_q;
   wire [0:69] 				                  rpt_byp_dat1_d;
   wire [0:69] 				                  rpt_byp_dat1_q;
   wire [0:1] 				                     byp_rpt_ary_d;
   wire [0:1] 				                     byp_rpt_ary_q;
   wire [0:1] 				                     byp1_rpt_ary_d;
   wire [0:1] 				                     byp1_rpt_ary_q;
   wire [0:69] 				                  ex7_rpt_entry0;
   wire [0:69] 				                  ex7_rpt_entry1;
   wire                                      entry0_hit;
   wire                                      entry1_hit;
   wire [0:56] 				                  ex7_rpt_entry_mux;
   wire [0:56] 				                  new_rpt_entry;
   wire [0:21] 				                  new_stride_prelim;
   wire                                      same_cline;
   wire                                      pf1_stride_too_small_q;
   wire                                      pf1_same_cline_q;
   wire                                      stride_too_small;
   wire                                      stride_lessthan_cline_pos;
   wire                                      stride_lessthan_cline_neg;

   wire [0:`THREADS-1] 			               ex6_thrd_q;
   wire [0:`THREADS-1] 			               ex7_thrd_q;
   wire [0:`THREADS-1] 			               ex8_thrd_q;
   wire [64-(2**`GPR_WIDTH_ENC):59] 	      ex6_eff_addr_q;
   wire [64-(2**`GPR_WIDTH_ENC):59] 	      ex7_eff_addr_q;
   wire [64-(2**`GPR_WIDTH_ENC):59] 	      ex8_eff_addr_q;
   wire                                      ex6_req_val_4pf_q;
   wire                                      ex7_req_val_4pf_d;
   wire                                      ex7_req_val_4pf_q;
   wire                                      ex8_req_val_4pf_q;
   wire                                      pf1_req_val_4pf_q;
   wire                                      pf2_req_val_4pf_d;
   wire                                      pf2_req_val_4pf_q;
   wire                                      ex5_valid_loadmiss;
   wire                                      ex6_loadmiss_q;
   wire                                      ex7_loadmiss_q;
   wire                                      pf3_req_val_d;
   wire                                      pf3_req_val_q;
   wire [64-(2**`GPR_WIDTH_ENC):59] 	      pf3_req_addr_d;
   wire [64-(2**`GPR_WIDTH_ENC):59] 	      pf3_req_addr_q;
   wire                                      block_dup_pfetch;
   wire                                      inj_pfetch_parity_q;
   wire                                      ex7_rpt_entry0_pe;
   wire                                      ex7_rpt_entry1_pe;
   wire                                      ex8_pfetch_pe_d;
   wire                                      ex8_pfetch_pe_q;
   wire [57+`THREADS:64+`THREADS] 	         ex7_rpt_entry0_par;
   wire [57+`THREADS:64+`THREADS] 	         ex7_rpt_entry1_par;
   wire [0:`LDSTQ_ENTRIES-1] 		            pf_itag_tbl_act;
   wire                                      ex6_pf_act;
   wire                                      ex7_pf_act;
   wire                                      ex8_pf_act;
   wire                                      pf1_act;
   wire                                      pf2_act;
   wire                                      pf3_act;
   wire                                      byp_act;
   wire                                      rpt_func_scan_in;
   wire                                      rpt_func_scan_out;

   //--------------------------
   // constants
   //--------------------------

   parameter                                 rv_i0_vld_offset = 0;

   parameter                                 rv_i0_isLoad_offset = rv_i0_vld_offset + `THREADS;
   parameter                                 rv_i0_rte_lq_offset = rv_i0_isLoad_offset + 1;
   parameter                                 rv_i0_ifar_offset = rv_i0_rte_lq_offset + 1;
   parameter                                 rv_i0_itag_offset = rv_i0_ifar_offset + `PF_IFAR_WIDTH;
   parameter                                 rv_i1_vld_offset = rv_i0_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 rv_i1_isLoad_offset = rv_i1_vld_offset + `THREADS;
   parameter                                 rv_i1_rte_lq_offset = rv_i1_isLoad_offset + 1;
   parameter                                 rv_i1_ifar_offset = rv_i1_rte_lq_offset + 1;
   parameter                                 rv_i1_itag_offset = rv_i1_ifar_offset + `PF_IFAR_WIDTH;
   parameter                                 cp_flush_offset = rv_i1_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 cp_flush2_offset = cp_flush_offset + `THREADS;
   parameter                                 cp_flush3_offset = cp_flush2_offset + `THREADS;
   parameter                                 cp_flush4_offset = cp_flush3_offset + `THREADS;
   parameter                                 inj_pfetch_parity_offset = cp_flush4_offset + `THREADS;
   parameter                                 odq_resolved_offset = inj_pfetch_parity_offset + 1;
   parameter                                 odq_report_itag_offset = odq_resolved_offset + 1;
   parameter                                 odq_report_tid_offset = odq_report_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 pf_iar_tbl_offset = odq_report_tid_offset + `THREADS;
   parameter                                 pf_itag_tbl_offset = pf_iar_tbl_offset + `PF_IFAR_WIDTH * `LDSTQ_ENTRIES;
   parameter                                 pf_tid_tbl_offset = pf_itag_tbl_offset + `ITAG_SIZE_ENC * `LDSTQ_ENTRIES;
   parameter                                 pf_iar_tbl_val_offset = pf_tid_tbl_offset + `THREADS * `LDSTQ_ENTRIES;
   parameter                                 ex6_iar_offset = pf_iar_tbl_val_offset + `LDSTQ_ENTRIES;
   parameter                                 ex7_iar_offset = ex6_iar_offset + `PF_IFAR_WIDTH;
   parameter                                 ex8_iar_offset = ex7_iar_offset + `PF_IFAR_WIDTH;
   parameter                                 ex6_thrd_offset = ex8_iar_offset + `PF_IFAR_WIDTH;
   parameter                                 ex7_thrd_offset = ex6_thrd_offset + `THREADS;
   parameter                                 ex8_thrd_offset = ex7_thrd_offset + `THREADS;
   parameter                                 ex6_eff_addr_offset = ex8_thrd_offset + `THREADS;
   parameter                                 ex7_eff_addr_offset = ex6_eff_addr_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1);
   parameter                                 ex8_eff_addr_offset = ex7_eff_addr_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1);
   parameter                                 ex6_req_val_4pf_offset = ex8_eff_addr_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1);
   parameter                                 ex7_req_val_4pf_offset = ex6_req_val_4pf_offset + 1;
   parameter                                 ex8_req_val_4pf_offset = ex7_req_val_4pf_offset + 1;
   parameter                                 pf1_req_val_4pf_offset = ex8_req_val_4pf_offset + 1;
   parameter                                 pf2_req_val_4pf_offset = pf1_req_val_4pf_offset + 1;
   parameter                                 ex6_loadmiss_offset = pf2_req_val_4pf_offset + 1;
   parameter                                 ex7_loadmiss_offset = ex6_loadmiss_offset + 1;
   parameter                                 byp_rpt_ary_offset = ex7_loadmiss_offset + 1;
   parameter                                 byp1_rpt_ary_offset = byp_rpt_ary_offset + 2;
   parameter                                 rpt_byp_dat_offset = byp1_rpt_ary_offset + 2;
   parameter                                 rpt_byp_dat1_offset = rpt_byp_dat_offset + 70;
   parameter                                 ex8_last_dat_addr_offset = rpt_byp_dat1_offset + 70;
   parameter                                 ex8_stride_offset = ex8_last_dat_addr_offset + 22;
   parameter                                 ex8_pf_state_offset = ex8_stride_offset + 22;
   parameter                                 ex8_burst_cnt_offset = ex8_pf_state_offset + 2;
   parameter                                 ex8_dup_flag_offset = ex8_burst_cnt_offset + 2;
   parameter                                 ex8_pf_hits_offset = ex8_dup_flag_offset + 1;
   parameter                                 ex8_rpt_pe_offset = ex8_pf_hits_offset + 3;
   parameter                                 ex8_pfetch_pe_offset = ex8_rpt_pe_offset + 2;
   parameter                                 pfq_stride_offset = ex8_pfetch_pe_offset + 1;
   parameter                                 pfq_data_ea_offset = pfq_stride_offset + 22 * `PFETCH_Q_SIZE;
   parameter                                 pfq_thrd_offset = pfq_data_ea_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) * `PFETCH_Q_SIZE;
   parameter                                 pfq_dscr_offset = pfq_thrd_offset + `THREADS * `PFETCH_Q_SIZE;
   parameter                                 pfq_dup_flag_offset = pfq_dscr_offset + 3 * `PFETCH_Q_SIZE;
   parameter                                 pfq_full_offset = pfq_dup_flag_offset + `PFETCH_Q_SIZE;
   parameter                                 pfq_wrt_ptr_offset = pfq_full_offset + 1;
   parameter                                 pf_state_offset = pfq_wrt_ptr_offset + `PFETCH_Q_SIZE_ENC;
   parameter                                 pf_count_offset = pf_state_offset + 5;
   parameter                                 pf1_new_stride_offset = pf_count_offset + 3;
   parameter                                 pf1_rpt_stride_offset = pf1_new_stride_offset + 22;
   parameter                                 pf1_data_ea_offset = pf1_rpt_stride_offset + 22;
   parameter                                 pf1_iar_offset = pf1_data_ea_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1);
   parameter                                 pf1_pf_state_offset = pf1_iar_offset + `PF_IFAR_WIDTH;
   parameter                                 pf1_burst_cnt_offset = pf1_pf_state_offset + 2;
   parameter                                 pf1_dup_flag_offset = pf1_burst_cnt_offset + 2;
   parameter                                 pf1_hits_offset = pf1_dup_flag_offset + 1;
   parameter                                 pf1_rpt_pe_offset = pf1_hits_offset + 3;
   parameter                                 pf1_thrd_offset = pf1_rpt_pe_offset + 2;
   parameter                                 pf1_same_cline_offset = pf1_thrd_offset + `THREADS;
   parameter                                 pf1_stride_too_small_offset = pf1_same_cline_offset + 1;
   parameter                                 pf2_gen_pfetch_offset = pf1_stride_too_small_offset + 1;
   parameter                                 pf2_rpt_stride_offset = pf2_gen_pfetch_offset + 1;
   parameter                                 pf2_data_ea_offset = pf2_rpt_stride_offset + 22;
   parameter                                 pf2_iar_offset = pf2_data_ea_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1);
   parameter                                 pf2_pf_state_offset = pf2_iar_offset + `PF_IFAR_WIDTH;
   parameter                                 pf2_burst_cnt_offset = pf2_pf_state_offset + 2;
   parameter                                 pf2_hits_offset = pf2_burst_cnt_offset + 2;
   parameter                                 pf2_rpt_pe_offset = pf2_hits_offset + 3;
   parameter                                 pf2_thrd_offset = pf2_rpt_pe_offset + 2;
   parameter                                 rpt_lru_offset = pf2_thrd_offset + `THREADS;
   parameter                                 pfq_rd_ptr_offset = rpt_lru_offset + 32;
   parameter                                 pf3_stride_offset = pfq_rd_ptr_offset + `PFETCH_Q_SIZE_ENC;
   parameter                                 pf3_req_addr_offset = pf3_stride_offset + 22;
   parameter                                 pf3_req_val_offset = pf3_req_addr_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1);
   parameter                                 pf3_thrd_offset = pf3_req_val_offset + 1;

   parameter                                 scan_right = pf3_thrd_offset + `THREADS - 1;

   wire                                      tiup;
   wire                                      tidn;
   wire [0:scan_right] 			     siv;
   wire [0:scan_right] 			     sov;
   wire [0:31]                       value1;
   wire [0:31]                       value2;

   //!! Bugspray Include: lq_pfetch

   assign tiup = 1'b1;
   assign tidn = 1'b0;
   assign value1 = 32'h00000001;
   assign value2 = 32'h00000002;

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // SPR for prefetch depth
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   generate
      begin : xhdl0
         genvar                                    tid;
         for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
           begin : sprThrd
              assign pf_dscr_reg[tid] = {spr_pf_spr_dscr_lsd[tid], spr_pf_spr_dscr_snse[tid], spr_pf_spr_dscr_sse[tid],
                                         spr_pf_spr_dscr_dpfd[tid * 3:(tid * 3) + 2]};
              assign pfetch_dis_thrd[tid] = pf_dscr_reg[tid][58] | (pf_dscr_reg[tid][61:62] == 2'b00);
           end
      end
   endgenerate


   always @(*)
     begin: tid_pd_dis_p
        reg                                       pf_dis;
        reg                                       ex6_dis;
        reg [58:63] 				  pf_dscr;
        integer                                   tid;

        ex6_dis = 1'b0;
        pf_dis = 1'b0;
        pf_dscr = {6{1'b0}};
        for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
          begin
             ex6_dis = (pfetch_dis_thrd[tid] & ex6_thrd_q[tid]) | ex6_dis;
             pf_dis  = (pfetch_dis_thrd[tid] & pf1_thrd_q[tid]) | pf_dis;
             pf_dscr = (pf_dscr_reg[tid] & {6{pf1_thrd_q[tid]}}) | pf_dscr;
          end
        ex6_pf_disable <= ex6_dis;
        pf1_disable <= pf_dis;
        pf1_dscr <= pf_dscr;
     end

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // latch iu signals before using
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   assign rv_i0_vld_d = rv_lq_rv1_i0_vld;
   assign rv_i1_vld_d = rv_lq_rv1_i1_vld;


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) rv_i0_vld_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[rv_i0_vld_offset:rv_i0_vld_offset + `THREADS - 1]),
      .scout(sov[rv_i0_vld_offset:rv_i0_vld_offset + `THREADS - 1]),
      .din(rv_i0_vld_d),
      .dout(rv_i0_vld_q)
   );


   tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) rv_i0_isLoad_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[rv_i0_isLoad_offset:rv_i0_isLoad_offset]),
      .scout(sov[rv_i0_isLoad_offset:rv_i0_isLoad_offset]),
      .din(rv_lq_rv1_i0_isLoad),
      .dout(rv_i0_isLoad_q)
   );


   tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) rv_i0_rte_lq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[rv_i0_rte_lq_offset:rv_i0_rte_lq_offset]),
      .scout(sov[rv_i0_rte_lq_offset:rv_i0_rte_lq_offset]),
      .din(rv_lq_rv1_i0_rte_lq),
      .dout(rv_i0_rte_lq_q)
   );


   tri_rlmreg_p #(.WIDTH(`PF_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) rv_i0_ifar_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[rv_i0_ifar_offset:rv_i0_ifar_offset + `PF_IFAR_WIDTH - 1]),
      .scout(sov[rv_i0_ifar_offset:rv_i0_ifar_offset + `PF_IFAR_WIDTH - 1]),
      .din(rv_lq_rv1_i0_ifar),
      .dout(rv_i0_ifar_q)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) rv_i0_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[rv_i0_itag_offset:rv_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[rv_i0_itag_offset:rv_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(rv_lq_rv1_i0_itag),
      .dout(rv_i0_itag_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) rv_i1_vld_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[rv_i1_vld_offset:rv_i1_vld_offset + `THREADS - 1]),
      .scout(sov[rv_i1_vld_offset:rv_i1_vld_offset + `THREADS - 1]),
      .din(rv_i1_vld_d),
      .dout(rv_i1_vld_q)
   );


   tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) rv_i1_isLoad_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[rv_i1_isLoad_offset:rv_i1_isLoad_offset]),
      .scout(sov[rv_i1_isLoad_offset:rv_i1_isLoad_offset]),
      .din(rv_lq_rv1_i1_isLoad),
      .dout(rv_i1_isLoad_q)
   );


   tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) rv_i1_rte_lq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[rv_i1_rte_lq_offset:rv_i1_rte_lq_offset]),
      .scout(sov[rv_i1_rte_lq_offset:rv_i1_rte_lq_offset]),
      .din(rv_lq_rv1_i1_rte_lq),
      .dout(rv_i1_rte_lq_q)
   );


   tri_rlmreg_p #(.WIDTH(`PF_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) rv_i1_ifar_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[rv_i1_ifar_offset:rv_i1_ifar_offset + `PF_IFAR_WIDTH - 1]),
      .scout(sov[rv_i1_ifar_offset:rv_i1_ifar_offset + `PF_IFAR_WIDTH - 1]),
      .din(rv_lq_rv1_i1_ifar),
      .dout(rv_i1_ifar_q)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) rv_i1_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[rv_i1_itag_offset:rv_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[rv_i1_itag_offset:rv_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(rv_lq_rv1_i1_itag),
      .dout(rv_i1_itag_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
      .scout(sov[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
      .din(iu_lq_cp_flush),
      .dout(cp_flush_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush2_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[cp_flush2_offset:cp_flush2_offset + `THREADS - 1]),
      .scout(sov[cp_flush2_offset:cp_flush2_offset + `THREADS - 1]),
      .din(cp_flush_q),
      .dout(cp_flush2_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush3_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[cp_flush3_offset:cp_flush3_offset + `THREADS - 1]),
      .scout(sov[cp_flush3_offset:cp_flush3_offset + `THREADS - 1]),
      .din(cp_flush2_q),
      .dout(cp_flush3_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush4_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[cp_flush4_offset:cp_flush4_offset + `THREADS - 1]),
      .scout(sov[cp_flush4_offset:cp_flush4_offset + `THREADS - 1]),
      .din(cp_flush3_q),
      .dout(cp_flush4_q)
   );


   tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) inj_pfetch_parity_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[inj_pfetch_parity_offset:inj_pfetch_parity_offset]),
      .scout(sov[inj_pfetch_parity_offset:inj_pfetch_parity_offset]),
      .din(pc_lq_inj_prefetcher_parity),
      .dout(inj_pfetch_parity_q)
   );

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // Save iar and itag from dispatch
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   assign new_itag_i0_val = |(rv_i0_vld_q & (~(cp_flush_q | cp_flush2_q | cp_flush3_q | cp_flush4_q))) & rv_i0_rte_lq_q & rv_i0_isLoad_q;
   assign new_itag_i1_val = |(rv_i1_vld_q & (~(cp_flush_q | cp_flush2_q | cp_flush3_q | cp_flush4_q))) & rv_i1_rte_lq_q & rv_i1_isLoad_q;

   assign pf_iar_i0_wen[0] = new_itag_i0_val & (pf_iar_tbl_val_q[0] == 1'b0);
   assign pf_iar_i0_wen[1] = new_itag_i0_val & (pf_iar_tbl_val_q[0:1] == 2'b10);

   generate
      begin : xhdl1
         genvar                                    i;
         for (i = 2; i <= `LDSTQ_ENTRIES - 1; i = i + 1)
           begin : pf_iar_i0_wen_gen
              assign pf_iar_i0_wen[i] = new_itag_i0_val & &(pf_iar_tbl_val_q[0:i - 1]) & (pf_iar_tbl_val_q[i] == 1'b0);
           end
      end
   endgenerate

   assign pf_iar_val_for_i1 = pf_iar_tbl_val_q | pf_iar_i0_wen;

   assign pf_iar_i1_wen[0] = new_itag_i1_val & (pf_iar_val_for_i1[0] == 1'b0);
   assign pf_iar_i1_wen[1] = new_itag_i1_val & (pf_iar_val_for_i1[0:1] == 2'b10);

   generate
      begin : xhdl2
         genvar                                    i;
         for (i = 2; i <= `LDSTQ_ENTRIES - 1; i = i + 1)
           begin : pf_iar_i1_wen_gen
              assign pf_iar_i1_wen[i] = new_itag_i1_val & &(pf_iar_val_for_i1[0:i - 1]) & (pf_iar_val_for_i1[i] == 1'b0);
           end
      end
   endgenerate

   // latch itag report from odq


   tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) odq_resolved_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[odq_resolved_offset:odq_resolved_offset]),
      .scout(sov[odq_resolved_offset:odq_resolved_offset]),
      .din(odq_pf_resolved),
      .dout(odq_resolved_q)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) odq_report_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[odq_report_itag_offset:odq_report_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[odq_report_itag_offset:odq_report_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(odq_pf_report_itag),
      .dout(odq_report_itag_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) odq_report_tid_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[odq_report_tid_offset:odq_report_tid_offset + `THREADS - 1]),
      .scout(sov[odq_report_tid_offset:odq_report_tid_offset + `THREADS - 1]),
      .din(odq_pf_report_tid),
      .dout(odq_report_tid_q)
   );

   generate
      begin : xhdl3
         genvar                                    i;
         for (i = 0; i <= `LDSTQ_ENTRIES - 1; i = i + 1)
           begin : done_itag_match_gen
              assign pf_iar_tbl_reset[i] = (odq_report_itag_q == pf_itag_tbl_q[i]) &
                                           |(odq_report_tid_q & pf_tid_tbl_q[i]) &
                                           odq_resolved_q & pf_iar_tbl_val_q[i];
           end
      end
   endgenerate

   generate
      begin : xhdl4
         genvar                                    i;
         for (i = 0; i <= `LDSTQ_ENTRIES - 1; i = i + 1)
           begin : pf_iar_table

              assign pf_itag_tbl_act[i] = pf_iar_i0_wen[i] | pf_iar_i1_wen[i] | pf_iar_tbl_reset[i] | |(cp_flush_q);

              assign pf_iar_tbl_d[i] = (pf_iar_i0_wen[i] == 1'b1) ? rv_i0_ifar_q :
                                       (pf_iar_i1_wen[i] == 1'b1) ? rv_i1_ifar_q :
                                                                    pf_iar_tbl_q[i];
              assign pf_itag_tbl_d[i] = (pf_iar_i0_wen[i] == 1'b1) ? rv_i0_itag_q :
                                        (pf_iar_i1_wen[i] == 1'b1) ? rv_i1_itag_q :
                                                                     pf_itag_tbl_q[i];
              assign pf_tid_tbl_d[i] = (pf_iar_i0_wen[i] == 1'b1) ? rv_i0_vld_q :
                                       (pf_iar_i1_wen[i] == 1'b1) ? rv_i1_vld_q :
                                                                    pf_tid_tbl_q[i];

              assign pf_iar_tbl_val_d[i] = pf_iar_i0_wen[i] | pf_iar_i1_wen[i] |
                                          (pf_iar_tbl_val_q[i] & (~(|(pf_tid_tbl_q[i] & cp_flush_q) | pf_iar_tbl_reset[i])));


              tri_rlmreg_p #(.WIDTH(`PF_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) pf_iar_tbl_latch(
                 .vd(vdd),
                 .gd(gnd),
                 .nclk(nclk),
                 .act(pf_itag_tbl_act[i]),
                 .force_t(func_sl_force),
                 .d_mode(d_mode_dc),
                 .delay_lclkr(delay_lclkr_dc),
                 .mpw1_b(mpw1_dc_b),
                 .mpw2_b(mpw2_dc_b),
                 .thold_b(func_sl_thold_0_b),
                 .sg(sg_0),
                 .scin(siv[pf_iar_tbl_offset + `PF_IFAR_WIDTH * i:pf_iar_tbl_offset + `PF_IFAR_WIDTH * (i + 1) - 1]),
                 .scout(sov[pf_iar_tbl_offset + `PF_IFAR_WIDTH * i:pf_iar_tbl_offset + `PF_IFAR_WIDTH * (i + 1) - 1]),
                 .din(pf_iar_tbl_d[i]),
                 .dout(pf_iar_tbl_q[i])
              );


              tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) pf_itag_tbl_latch(
                 .vd(vdd),
                 .gd(gnd),
                 .nclk(nclk),
                 .act(pf_itag_tbl_act[i]),
                 .force_t(func_sl_force),
                 .d_mode(d_mode_dc),
                 .delay_lclkr(delay_lclkr_dc),
                 .mpw1_b(mpw1_dc_b),
                 .mpw2_b(mpw2_dc_b),
                 .thold_b(func_sl_thold_0_b),
                 .sg(sg_0),
                 .scin(siv[pf_itag_tbl_offset + `ITAG_SIZE_ENC * i:pf_itag_tbl_offset + `ITAG_SIZE_ENC * (i + 1) - 1]),
                 .scout(sov[pf_itag_tbl_offset + `ITAG_SIZE_ENC * i:pf_itag_tbl_offset + `ITAG_SIZE_ENC * (i + 1) - 1]),
                 .din(pf_itag_tbl_d[i]),
                 .dout(pf_itag_tbl_q[i])
              );


              tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) pf_tid_tbl_latch(
                 .vd(vdd),
                 .gd(gnd),
                 .nclk(nclk),
                 .act(pf_itag_tbl_act[i]),
                 .force_t(func_sl_force),
                 .d_mode(d_mode_dc),
                 .delay_lclkr(delay_lclkr_dc),
                 .mpw1_b(mpw1_dc_b),
                 .mpw2_b(mpw2_dc_b),
                 .thold_b(func_sl_thold_0_b),
                 .sg(sg_0),
                 .scin(siv[pf_tid_tbl_offset + `THREADS * i:pf_tid_tbl_offset + `THREADS * (i + 1) - 1]),
                 .scout(sov[pf_tid_tbl_offset + `THREADS * i:pf_tid_tbl_offset + `THREADS * (i + 1) - 1]),
                 .din(pf_tid_tbl_d[i]),
                 .dout(pf_tid_tbl_q[i])
              );
         end
      end
   endgenerate


    tri_rlmreg_p #(.WIDTH(`LDSTQ_ENTRIES), .INIT(0)) latch_pf_iar_tbl_val(
       .nclk(nclk),
       .act(tiup),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .vd(vdd),
       .gd(gnd),
       .scin(siv[pf_iar_tbl_val_offset:pf_iar_tbl_val_offset + `LDSTQ_ENTRIES - 1]),
       .scout(sov[pf_iar_tbl_val_offset:pf_iar_tbl_val_offset + `LDSTQ_ENTRIES - 1]),
       .din(pf_iar_tbl_val_d),
       .dout(pf_iar_tbl_val_q)
    );

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // lookup iar from itag-iar table
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   generate
      begin : xhdl5
         genvar                                    i;
         for (i = 0; i <= `LDSTQ_ENTRIES - 1; i = i + 1)
           begin : new_itag_match_gen
              assign ex5_itag_match[i] = (dcc_pf_ex5_itag == pf_itag_tbl_q[i]) &
                                         |(dcc_pf_ex5_thrd_id & pf_tid_tbl_q[i]) &
                                         pf_iar_tbl_val_q[i];
           end
      end
   endgenerate

   always @(*)
     begin: ex5_iar_proc
        reg [61-`PF_IFAR_WIDTH+1:61]               iar;
        integer                                   i;
        iar = {61-(61-`PF_IFAR_WIDTH+1)+1{1'b0}};
        for (i = 0; i <= `LDSTQ_ENTRIES - 1; i = i + 1)
          iar = ({`PF_IFAR_WIDTH{ex5_itag_match[i]}} & pf_iar_tbl_q[i]) | iar;

       ex5_iar <= iar;
     end

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // stage out signals to ex7
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   assign ex6_pf_act = dcc_pf_ex5_act | ex6_req_val_4pf_q;
   assign ex7_pf_act = (ex6_req_val_4pf_q & (~ex6_pf_disable)) | ex7_req_val_4pf_q;
   assign ex8_pf_act = ex7_req_val_4pf_q | ex8_req_val_4pf_q;
   assign pf1_act = ex8_req_val_4pf_q | pf1_req_val_4pf_q;
   assign pf2_act = pf1_req_val_4pf_q | pf2_req_val_4pf_q;


    tri_rlmreg_p #(.WIDTH(`PF_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex6_iar_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex6_pf_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ex6_iar_offset:ex6_iar_offset + `PF_IFAR_WIDTH - 1]),
       .scout(sov[ex6_iar_offset:ex6_iar_offset + `PF_IFAR_WIDTH - 1]),
       .din(ex5_iar),
       .dout(ex6_iar_q)
    );


    tri_rlmreg_p #(.WIDTH(`PF_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex7_iar_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex7_pf_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ex7_iar_offset:ex7_iar_offset + `PF_IFAR_WIDTH - 1]),
       .scout(sov[ex7_iar_offset:ex7_iar_offset + `PF_IFAR_WIDTH - 1]),
       .din(ex6_iar_q),
       .dout(ex7_iar_q)
    );


    tri_rlmreg_p #(.WIDTH(`PF_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex8_iar_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex8_pf_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ex8_iar_offset:ex8_iar_offset + `PF_IFAR_WIDTH - 1]),
       .scout(sov[ex8_iar_offset:ex8_iar_offset + `PF_IFAR_WIDTH - 1]),
       .din(ex7_iar_q),
       .dout(ex8_iar_q)
    );


    tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex6_thrd_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex6_pf_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ex6_thrd_offset:ex6_thrd_offset + `THREADS - 1]),
       .scout(sov[ex6_thrd_offset:ex6_thrd_offset + `THREADS - 1]),
       .din(dcc_pf_ex5_thrd_id),
       .dout(ex6_thrd_q)
    );


    tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex7_thrd_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex7_pf_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ex7_thrd_offset:ex7_thrd_offset + `THREADS - 1]),
       .scout(sov[ex7_thrd_offset:ex7_thrd_offset + `THREADS - 1]),
       .din(ex6_thrd_q),
       .dout(ex7_thrd_q)
    );


    tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex8_thrd_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex8_pf_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ex8_thrd_offset:ex8_thrd_offset + `THREADS - 1]),
       .scout(sov[ex8_thrd_offset:ex8_thrd_offset + `THREADS - 1]),
       .din(ex7_thrd_q),
       .dout(ex8_thrd_q)
    );


    tri_rlmreg_p #(.WIDTH((59-(64-(2**`GPR_WIDTH_ENC))+1)), .INIT(0), .NEEDS_SRESET(1)) ex6_eff_addr_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex6_pf_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ex6_eff_addr_offset:ex6_eff_addr_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
       .scout(sov[ex6_eff_addr_offset:ex6_eff_addr_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
       .din(dcc_pf_ex5_eff_addr),
       .dout(ex6_eff_addr_q)
    );


    tri_rlmreg_p #(.WIDTH((59-(64-(2**`GPR_WIDTH_ENC))+1)), .INIT(0), .NEEDS_SRESET(1)) ex7_eff_addr_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex7_pf_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ex7_eff_addr_offset:ex7_eff_addr_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
       .scout(sov[ex7_eff_addr_offset:ex7_eff_addr_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
       .din(ex6_eff_addr_q),
       .dout(ex7_eff_addr_q)
    );


    tri_rlmreg_p #(.WIDTH((59-(64-(2**`GPR_WIDTH_ENC))+1)), .INIT(0), .NEEDS_SRESET(1)) ex8_eff_addr_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex8_pf_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ex8_eff_addr_offset:ex8_eff_addr_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
       .scout(sov[ex8_eff_addr_offset:ex8_eff_addr_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
       .din(ex7_eff_addr_q),
       .dout(ex8_eff_addr_q)
    );


    tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex6_req_val_4pf_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex6_pf_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ex6_req_val_4pf_offset:ex6_req_val_4pf_offset]),
       .scout(sov[ex6_req_val_4pf_offset:ex6_req_val_4pf_offset]),
       .din(dcc_pf_ex5_req_val_4pf),
       .dout(ex6_req_val_4pf_q)
    );

    assign ex7_req_val_4pf_d = ex6_req_val_4pf_q & (~ex6_pf_disable);


    tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex7_req_val_4pf_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex7_pf_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ex7_req_val_4pf_offset:ex7_req_val_4pf_offset]),
       .scout(sov[ex7_req_val_4pf_offset:ex7_req_val_4pf_offset]),
       .din(ex7_req_val_4pf_d),
       .dout(ex7_req_val_4pf_q)
    );


    tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex8_req_val_4pf_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex8_pf_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ex8_req_val_4pf_offset:ex8_req_val_4pf_offset]),
       .scout(sov[ex8_req_val_4pf_offset:ex8_req_val_4pf_offset]),
       .din(ex7_req_val_4pf_q),
       .dout(ex8_req_val_4pf_q)
    );


    tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) pf1_req_val_4pf_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(pf1_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[pf1_req_val_4pf_offset:pf1_req_val_4pf_offset]),
       .scout(sov[pf1_req_val_4pf_offset:pf1_req_val_4pf_offset]),
       .din(ex8_req_val_4pf_q),
       .dout(pf1_req_val_4pf_q)
    );

    assign pf2_req_val_4pf_d = pf1_req_val_4pf_q & (~pf1_stride_too_small_q);


    tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) pf2_req_val_4pf_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(pf2_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[pf2_req_val_4pf_offset:pf2_req_val_4pf_offset]),
       .scout(sov[pf2_req_val_4pf_offset:pf2_req_val_4pf_offset]),
       .din(pf2_req_val_4pf_d),
       .dout(pf2_req_val_4pf_q)
    );

    assign ex5_valid_loadmiss = dcc_pf_ex5_loadmiss & dcc_pf_ex5_req_val_4pf;


    tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex6_loadmiss_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex6_pf_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ex6_loadmiss_offset:ex6_loadmiss_offset]),
       .scout(sov[ex6_loadmiss_offset:ex6_loadmiss_offset]),
       .din(ex5_valid_loadmiss),
       .dout(ex6_loadmiss_q)
    );


    tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex7_loadmiss_latch(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex7_pf_act),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ex7_loadmiss_offset:ex7_loadmiss_offset]),
       .scout(sov[ex7_loadmiss_offset:ex7_loadmiss_offset]),
       .din(ex6_loadmiss_q),
       .dout(ex7_loadmiss_q)
    );

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // lookup entry in RPT (Reference Predictor Table)
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   assign rpt_rd_addr = ex5_iar[57:61];

    tri_32x70_2w_1r1w  rpt(
       // POWER PINS
       .gnd(gnd),
       .vdd(vdd),
       .vcs(vcs),
       // CLOCK and CLOCKCONTROL ports
       .nclk(nclk),
       .rd_act(rpt_rd_act[0:1]),
       .wr_act(rpt_wen[0:1]),
       .sg_0(sg_0),
       .abst_sl_thold_0(abst_sl_thold_0),
       .ary_nsl_thold_0(ary_nsl_thold_0),
       .time_sl_thold_0(time_sl_thold_0),
       .repr_sl_thold_0(repr_sl_thold_0),
       .func_sl_force(func_sl_force),
       .func_sl_thold_0_b(func_sl_thold_0_b),
       .g8t_clkoff_dc_b(g8t_clkoff_dc_b),
       .ccflush_dc(pc_lq_ccflush_dc),
       .scan_dis_dc_b(an_ac_scan_dis_dc_b),
       .scan_diag_dc(an_ac_scan_diag_dc),
       .g8t_d_mode_dc(g8t_d_mode_dc),
       .g8t_mpw1_dc_b(g8t_mpw1_dc_b[0:4]),
       .g8t_mpw2_dc_b(g8t_mpw2_dc_b),
       .g8t_delay_lclkr_dc(g8t_delay_lclkr_dc[0:4]),
       .d_mode_dc(d_mode_dc),
       .mpw1_dc_b(mpw1_dc_b),
       .mpw2_dc_b(mpw2_dc_b),
       .delay_lclkr_dc(delay_lclkr_dc),
       // ABIST
       .wr_abst_act(pc_xu_abist_g8t_wenb_q),
       .rd0_abst_act(pc_xu_abist_g8t1p_renb_0_q),
       .abist_di(pc_xu_abist_di_0_q[0:3]),
       .abist_bw_odd(pc_xu_abist_g8t_bw_1_q),
       .abist_bw_even(pc_xu_abist_g8t_bw_0_q),
       .abist_wr_adr(pc_xu_abist_waddr_0_q[0:4]),
       .abist_rd0_adr(pc_xu_abist_raddr_0_q[0:4]),
       .tc_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
       .abist_ena_1(pc_xu_abist_ena_dc),
       .abist_g8t_rd0_comp_ena(pc_xu_abist_wl64_comp_ena_q),
       .abist_raw_dc_b(pc_xu_abist_raw_dc_b),
       .obs0_abist_cmp(pc_xu_abist_g8t_dcomp_q[0:3]),
       // Scan
       .abst_scan_in(abst_scan_in[0:1]),
       .time_scan_in(time_scan_in),
       .repr_scan_in(repr_scan_in),
       .func_scan_in(rpt_func_scan_in),
       .abst_scan_out(abst_scan_out[0:1]),
       .time_scan_out(time_scan_out),
       .repr_scan_out(repr_scan_out),
       .func_scan_out(rpt_func_scan_out),
       // BOLT-ON
       .lcb_bolt_sl_thold_0(bolt_sl_thold_0),
       .pc_bo_enable_2(pc_bo_enable_2),		// general bolt-on enable
       .pc_bo_reset(pc_xu_bo_reset),		// reset
       .pc_bo_unload(pc_xu_bo_unload),		// unload sticky bits
       .pc_bo_repair(pc_xu_bo_repair),		// execute sticky bit decode
       .pc_bo_shdata(pc_xu_bo_shdata),		// shift data for timing write and diag loop
       .pc_bo_select(pc_xu_bo_select[0:1]),		// select for mask and hier writes
       .bo_pc_failout(xu_pc_bo_fail[0:1]),		// fail/no-fix reg
       .bo_pc_diagloop(xu_pc_bo_diagout[0:1]),
       .tri_lcb_mpw1_dc_b(mpw1_dc_b),
       .tri_lcb_mpw2_dc_b(mpw2_dc_b),
       .tri_lcb_delay_lclkr_dc(delay_lclkr_dc),
       .tri_lcb_clkoff_dc_b(clkoff_dc_b),
       .tri_lcb_act_dis_dc(tidn),
       // Write Ports
       .wr_way(rpt_wen[0:1]),
       .wr_addr(rpt_wrt_addr[0:4]),
       .data_in(rpt_data_in[0:69]),
       // Read Ports
       .rd_addr(rpt_rd_addr[0:4]),
       .data_out(rpt_data_out[0:139])
    );

    // bypass around array when wrt addr equals read addr (and turn off rd act)

   assign rpt_byp_val[0] = (rpt_rd_addr == rpt_wrt_addr) & rpt_wen[0];
   assign rpt_byp_val[1] = (rpt_rd_addr == rpt_wrt_addr) & rpt_wen[1];

   assign rpt_rd_act[0] = dcc_pf_ex5_act & ~rpt_byp_val[0] & ~(&(pfetch_dis_thrd));
   assign rpt_rd_act[1] = dcc_pf_ex5_act & ~rpt_byp_val[1] & ~(&(pfetch_dis_thrd));

   assign byp_act = rpt_wen[0] | rpt_wen[1];
   assign byp1_act = |(byp_rpt_ary_q);

   assign byp_rpt_ary_d = (~rpt_rd_act);
   assign byp1_rpt_ary_d = byp_rpt_ary_q;

   assign rpt_byp_dat_d = rpt_data_in[0:69];
   assign rpt_byp_dat1_d = rpt_byp_dat_q[0:69];

   assign ex7_rpt_entry0 = (byp1_rpt_ary_q[0] == 1'b1) ? rpt_byp_dat1_q[0:69] :
                                                          rpt_data_out[0:69];

   assign ex7_rpt_entry1 = (byp1_rpt_ary_q[1] == 1'b1) ? rpt_byp_dat1_q[0:69] :
                                                          rpt_data_out[70:139];

   assign ex7_rpt_entry0_par[57 + `THREADS] = ^(ex7_rpt_entry0[0:7]);
   assign ex7_rpt_entry0_par[58 + `THREADS] = ^(ex7_rpt_entry0[8:15]);
   assign ex7_rpt_entry0_par[59 + `THREADS] = ^(ex7_rpt_entry0[16:23]);
   assign ex7_rpt_entry0_par[60 + `THREADS] = ^(ex7_rpt_entry0[24:31]);
   assign ex7_rpt_entry0_par[61 + `THREADS] = ^(ex7_rpt_entry0[32:39]);
   assign ex7_rpt_entry0_par[62 + `THREADS] = ^(ex7_rpt_entry0[40:47]);
   assign ex7_rpt_entry0_par[63 + `THREADS] = ^(ex7_rpt_entry0[48:55]);
   assign ex7_rpt_entry0_par[64 + `THREADS] = ^(ex7_rpt_entry0[56:57 + `THREADS - 1]);

   assign ex7_rpt_entry1_par[57 + `THREADS] = ^(ex7_rpt_entry1[0:7]);
   assign ex7_rpt_entry1_par[58 + `THREADS] = ^(ex7_rpt_entry1[8:15]);
   assign ex7_rpt_entry1_par[59 + `THREADS] = ^(ex7_rpt_entry1[16:23]);
   assign ex7_rpt_entry1_par[60 + `THREADS] = ^(ex7_rpt_entry1[24:31]);
   assign ex7_rpt_entry1_par[61 + `THREADS] = ^(ex7_rpt_entry1[32:39]);
   assign ex7_rpt_entry1_par[62 + `THREADS] = ^(ex7_rpt_entry1[40:47]);
   assign ex7_rpt_entry1_par[63 + `THREADS] = ^(ex7_rpt_entry1[48:55]);
   assign ex7_rpt_entry1_par[64 + `THREADS] = ^(ex7_rpt_entry1[56:57 + `THREADS - 1]);


   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) byp_rpt_ary_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[byp_rpt_ary_offset:byp_rpt_ary_offset + 2 - 1]),
      .scout(sov[byp_rpt_ary_offset:byp_rpt_ary_offset + 2 - 1]),
      .din(byp_rpt_ary_d),
      .dout(byp_rpt_ary_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) byp1_rpt_ary_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[byp1_rpt_ary_offset:byp1_rpt_ary_offset + 2 - 1]),
      .scout(sov[byp1_rpt_ary_offset:byp1_rpt_ary_offset + 2 - 1]),
      .din(byp1_rpt_ary_d),
      .dout(byp1_rpt_ary_q)
   );


   tri_rlmreg_p #(.WIDTH(70), .INIT(0), .NEEDS_SRESET(1)) rpt_byp_dat_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(byp_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[rpt_byp_dat_offset:rpt_byp_dat_offset + 70 - 1]),
      .scout(sov[rpt_byp_dat_offset:rpt_byp_dat_offset + 70 - 1]),
      .din(rpt_byp_dat_d),
      .dout(rpt_byp_dat_q)
   );

   tri_rlmreg_p #(.WIDTH(70), .INIT(0), .NEEDS_SRESET(1)) rpt_byp_dat1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(byp1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[rpt_byp_dat1_offset:rpt_byp_dat1_offset + 70 - 1]),
      .scout(sov[rpt_byp_dat1_offset:rpt_byp_dat1_offset + 70 - 1]),
      .din(rpt_byp_dat1_d),
      .dout(rpt_byp_dat1_q)
   );



   assign ex7_rpt_entry0_pe = |(ex7_rpt_entry0_par ^ ex7_rpt_entry0[57 + `THREADS:57 + `THREADS + 7]);
   assign ex7_rpt_entry1_pe = |(ex7_rpt_entry1_par ^ ex7_rpt_entry1[57 + `THREADS:57 + `THREADS + 7]);

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // Check entry hit/miss and create new entry
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   assign entry0_hit = ex7_rpt_entry0[0] & ex7_req_val_4pf_q & (~ex7_rpt_entry0_pe) &
                      (ex7_iar_q[50:56] == ex7_rpt_entry0[45:51]) &
                      (ex7_thrd_q == ex7_rpt_entry0[57:57 + `THREADS - 1]);

   assign entry1_hit = ex7_rpt_entry1[0] & ex7_req_val_4pf_q & (~ex7_rpt_entry1_pe) &
                       (ex7_iar_q[50:56] == ex7_rpt_entry1[45:51]) &
                       (ex7_thrd_q == ex7_rpt_entry1[57:57 + `THREADS - 1]);

   assign new_rpt_entry[0] = 1'b1;		                    // valid bit
   assign new_rpt_entry[1:22] = ex7_eff_addr_q[38:59];	  // last data address
   assign new_rpt_entry[23:44] = {22{1'b0}};	              // stride
   assign new_rpt_entry[45:51] = ex7_iar_q[50:56];		     // iar tag
   assign new_rpt_entry[52:53] = 2'b01;		              // prefetch state
   assign new_rpt_entry[54:55] = 2'b00;		              // burst counter
   assign new_rpt_entry[56] = 1'b0;		                    // duplicate flag

   assign ex7_rpt_entry_mux = (entry0_hit == 1'b1) ? ex7_rpt_entry0[0:56] :
                              (entry1_hit == 1'b1) ? ex7_rpt_entry1[0:56] :
                                                     new_rpt_entry;

   assign ex8_pf_hits_d = {entry0_hit, entry1_hit, ex7_loadmiss_q};

   assign ex8_rpt_pe_d = {ex7_rpt_entry0_pe, ex7_rpt_entry1_pe};

   assign ex8_pfetch_pe_d = ex7_req_val_4pf_q & (ex7_rpt_entry0_pe | ex7_rpt_entry1_pe);


   tri_rlmreg_p #(.WIDTH(22), .INIT(0), .NEEDS_SRESET(1)) ex8_last_dat_addr_latch(
													     .vd(vdd),
                  .gd(gnd),
                  .nclk(nclk),
                  .act(ex8_pf_act),
                  .force_t(func_sl_force),
                  .d_mode(d_mode_dc),
                  .delay_lclkr(delay_lclkr_dc),
                  .mpw1_b(mpw1_dc_b),
                  .mpw2_b(mpw2_dc_b),
                  .thold_b(func_sl_thold_0_b),
                  .sg(sg_0),
                  .scin(siv[ex8_last_dat_addr_offset:ex8_last_dat_addr_offset + 22 - 1]),
                  .scout(sov[ex8_last_dat_addr_offset:ex8_last_dat_addr_offset + 22 - 1]),
                  .din(ex7_rpt_entry_mux[1:22]),
                  .dout(ex8_last_dat_addr_q)
                   );


   tri_rlmreg_p #(.WIDTH(22), .INIT(0), .NEEDS_SRESET(1)) ex8_stride_latch(
                     .vd(vdd),
                     .gd(gnd),
                     .nclk(nclk),
                     .act(ex8_pf_act),
                     .force_t(func_sl_force),
                     .d_mode(d_mode_dc),
                     .delay_lclkr(delay_lclkr_dc),
                     .mpw1_b(mpw1_dc_b),
                     .mpw2_b(mpw2_dc_b),
                     .thold_b(func_sl_thold_0_b),
                     .sg(sg_0),
                     .scin(siv[ex8_stride_offset:ex8_stride_offset + 22 - 1]),
                     .scout(sov[ex8_stride_offset:ex8_stride_offset + 22 - 1]),
                     .din(ex7_rpt_entry_mux[23:44]),
                     .dout(ex8_stride_q)
                  );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex8_pf_state_latch(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(ex8_pf_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[ex8_pf_state_offset:ex8_pf_state_offset + 2 - 1]),
                           .scout(sov[ex8_pf_state_offset:ex8_pf_state_offset + 2 - 1]),
                           .din(ex7_rpt_entry_mux[52:53]),
                           .dout(ex8_pf_state_q)
                        );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex8_burst_cnt_latch(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(ex8_pf_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[ex8_burst_cnt_offset:ex8_burst_cnt_offset + 2 - 1]),
                           .scout(sov[ex8_burst_cnt_offset:ex8_burst_cnt_offset + 2 - 1]),
                           .din(ex7_rpt_entry_mux[54:55]),
                           .dout(ex8_burst_cnt_q)
                        );


   tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex8_dup_flag_latch(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(ex8_pf_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[ex8_dup_flag_offset:ex8_dup_flag_offset]),
                           .scout(sov[ex8_dup_flag_offset:ex8_dup_flag_offset]),
                           .din(ex7_rpt_entry_mux[56]),
                           .dout(ex8_dup_flag_q)
                        );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex8_pf_hits_latch(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(ex8_pf_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[ex8_pf_hits_offset:ex8_pf_hits_offset + 3 - 1]),
                           .scout(sov[ex8_pf_hits_offset:ex8_pf_hits_offset + 3 - 1]),
                           .din(ex8_pf_hits_d),
                           .dout(ex8_pf_hits_q)
                        );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex8_rpt_pe_latch(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(ex8_pf_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[ex8_rpt_pe_offset:ex8_rpt_pe_offset + 2 - 1]),
                           .scout(sov[ex8_rpt_pe_offset:ex8_rpt_pe_offset + 2 - 1]),
                           .din(ex8_rpt_pe_d),
                           .dout(ex8_rpt_pe_q)
                        );

   tri_rlmreg_p #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex8_pfetch_pe_latch(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(ex8_pf_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[ex8_pfetch_pe_offset:ex8_pfetch_pe_offset]),
                           .scout(sov[ex8_pfetch_pe_offset:ex8_pfetch_pe_offset]),
                           .din(ex8_pfetch_pe_d),
                           .dout(ex8_pfetch_pe_q)
                        );


   tri_direct_err_rpt #(.WIDTH(1)) pfetch_err_rpt(
                           .vd(vdd),
                           .gd(gnd),
                           .err_in(ex8_pfetch_pe_q),
                           .err_out(lq_pc_err_prefetcher_parity)
                        );

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // Compute new Stride
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   assign new_stride_prelim = ex8_eff_addr_q[38:59] - ex8_last_dat_addr_q[38:59];		// Data EA - last address

   assign same_cline = ex8_eff_addr_q[38:57] == ex8_last_dat_addr_q[38:57];

   // transaction dropped if stride is not at least half a cache line (stride of 0, 1 or -1)
   assign stride_too_small = ((new_stride_prelim == {20'h00000, 2'b00}) |       // 0
                              (new_stride_prelim == {20'h00000, 2'b01}) |       // +1 (+16 bytes)
                              (new_stride_prelim == {20'hFFFFF, 2'b11})) &      // -1 (-16 bytes)
                              (ex8_pf_hits_q[0] | ex8_pf_hits_q[1]);		        // hit on either entry 0 or 1

   //if stride is less than a cache line, round up

   assign stride_lessthan_cline_pos = (new_stride_prelim == {20'h00000, 2'b10}) |        // +2  (+32 bytes)
                                      (new_stride_prelim == {20'h00000, 2'b11});	        // +3  (+48 bytes)


   assign stride_lessthan_cline_neg = (new_stride_prelim == {20'hFFFFF, 2'b10}) |       // -2  (-32 bytes)
                                      (new_stride_prelim == {20'hFFFFF, 2'b01});        // -3  (-48 bytes)

   assign pf1_new_stride_d = (stride_lessthan_cline_pos == 1'b1) ? {20'h00001, 2'b00} :
                             (stride_lessthan_cline_neg == 1'b1) ? {20'hFFFFF, 2'b00} :
                                                                    new_stride_prelim;

   assign pf1_iar_d = ex8_iar_q;
   assign pf1_data_ea_d = ex8_eff_addr_q;
   assign pf1_pf_state_d = ex8_pf_state_q;
   assign pf1_burst_cnt_d = ex8_burst_cnt_q;
   assign pf1_dup_flag_d = ex8_dup_flag_q;
   assign pf1_hits_d = ex8_pf_hits_q;
   assign pf1_thrd_d = ex8_thrd_q;


   tri_rlmreg_p #(.WIDTH(22), .INIT(0)) latch_pf1_new_stride(
                           .nclk(nclk),
                           .act(pf1_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf1_new_stride_offset:pf1_new_stride_offset + 22 - 1]),
                           .scout(sov[pf1_new_stride_offset:pf1_new_stride_offset + 22 - 1]),
                           .din(pf1_new_stride_d),
                           .dout(pf1_new_stride_q)
                        );


   tri_rlmreg_p #(.WIDTH(22), .INIT(0)) latch_pf1_rpt_stride(
                           .nclk(nclk),
                           .act(pf1_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf1_rpt_stride_offset:pf1_rpt_stride_offset + 22 - 1]),
                           .scout(sov[pf1_rpt_stride_offset:pf1_rpt_stride_offset + 22 - 1]),
                           .din(ex8_stride_q),
                           .dout(pf1_rpt_stride_q)
                        );


   tri_rlmreg_p #(.WIDTH((59-(64-(2**`GPR_WIDTH_ENC))+1)), .INIT(0)) latch_pf1_data_ea(
                           .nclk(nclk),
                           .act(pf1_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf1_data_ea_offset:pf1_data_ea_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
                           .scout(sov[pf1_data_ea_offset:pf1_data_ea_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
                           .din(pf1_data_ea_d),
                           .dout(pf1_data_ea_q)
                        );


   tri_rlmreg_p #(.WIDTH(`PF_IFAR_WIDTH), .INIT(0)) latch_pf1_iar(
                           .nclk(nclk),
                           .act(pf1_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf1_iar_offset:pf1_iar_offset + `PF_IFAR_WIDTH - 1]),
                           .scout(sov[pf1_iar_offset:pf1_iar_offset + `PF_IFAR_WIDTH - 1]),
                           .din(pf1_iar_d),
                           .dout(pf1_iar_q)
                        );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) latch_pf1_pf_state(
                           .nclk(nclk),
                           .act(pf1_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf1_pf_state_offset:pf1_pf_state_offset + 2 - 1]),
                           .scout(sov[pf1_pf_state_offset:pf1_pf_state_offset + 2 - 1]),
                           .din(pf1_pf_state_d),
                           .dout(pf1_pf_state_q)
                        );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) latch_pf1_burst_cnt(
                           .nclk(nclk),
                           .act(pf1_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf1_burst_cnt_offset:pf1_burst_cnt_offset + 2 - 1]),
                           .scout(sov[pf1_burst_cnt_offset:pf1_burst_cnt_offset + 2 - 1]),
                           .din(pf1_burst_cnt_d),
                           .dout(pf1_burst_cnt_q)
                        );


   tri_rlmreg_p #(.WIDTH(1), .INIT(0)) latch_pf1_dup_flag(
                           .nclk(nclk),
                           .act(pf1_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf1_dup_flag_offset:pf1_dup_flag_offset]),
                           .scout(sov[pf1_dup_flag_offset:pf1_dup_flag_offset]),
                           .din(pf1_dup_flag_d),
                           .dout(pf1_dup_flag_q)
                        );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) latch_pf1_hits(
                           .nclk(nclk),
                           .act(pf1_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf1_hits_offset:pf1_hits_offset + 3 - 1]),
                           .scout(sov[pf1_hits_offset:pf1_hits_offset + 3 - 1]),
                           .din(pf1_hits_d),
                           .dout(pf1_hits_q)
                        );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) pf1_rpt_pe_latch(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(pf1_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[pf1_rpt_pe_offset:pf1_rpt_pe_offset + 2 - 1]),
                           .scout(sov[pf1_rpt_pe_offset:pf1_rpt_pe_offset + 2 - 1]),
                           .din(ex8_rpt_pe_q),
                           .dout(pf1_rpt_pe_q)
                        );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) latch_pf1_thrd(
										       .nclk(nclk),
                           .act(pf1_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf1_thrd_offset:pf1_thrd_offset + `THREADS - 1]),
                           .scout(sov[pf1_thrd_offset:pf1_thrd_offset + `THREADS - 1]),
                           .din(pf1_thrd_d),
                           .dout(pf1_thrd_q)
                        );


   tri_rlmreg_p #(.WIDTH(1), .INIT(0)) latch_pf1_same_cline(
                           .nclk(nclk),
                           .act(pf1_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf1_same_cline_offset:pf1_same_cline_offset]),
                           .scout(sov[pf1_same_cline_offset:pf1_same_cline_offset]),
                           .din(same_cline),
                           .dout(pf1_same_cline_q)
                        );


   tri_rlmreg_p #(.WIDTH(1), .INIT(0)) latch_pf1_stride_too_small(
                           .nclk(nclk),
                           .act(pf1_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf1_stride_too_small_offset:pf1_stride_too_small_offset]),
                           .scout(sov[pf1_stride_too_small_offset:pf1_stride_too_small_offset]),
                           .din(stride_too_small),
                           .dout(pf1_stride_too_small_q)
                        );

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // Stride Compare
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   assign stride_match = pf1_new_stride_q == pf1_rpt_stride_q;



   assign generate_pfetch = (~(pf1_pf_state_q == 2'b11)) &                                           // state 0, 1, or 2
                            (stride_match | (pf1_burst_cnt_q == 2'b11 & pf1_pf_state_q == 2'b00)) &  // stride correct or burst count is 3
                            (~(pf1_hits_q[0:1] == 2'b00)) &                                          // not for a new RPT entry
                            (~pf1_stride_too_small_q);

   assign nxt_state_cntrl = {stride_match, pf1_pf_state_q};

   assign pf1_update_state = ((nxt_state_cntrl) == 3'b100) ? 2'b00 : 		// state is 01 for new entry
                             ((nxt_state_cntrl) == 3'b101) ? 2'b00 :
                             ((nxt_state_cntrl) == 3'b110) ? 2'b00 :
                             ((nxt_state_cntrl) == 3'b111) ? 2'b10 :
                             ((nxt_state_cntrl) == 3'b000) ? 2'b01 :
                             ((nxt_state_cntrl) == 3'b001) ? 2'b10 :
                             ((nxt_state_cntrl) == 3'b010) ? 2'b11 :
                                                             2'b11;

   assign pf2_next_state_d = (pf1_hits_q[0:1] == 2'b00) ? 2'b01 :
                                                          pf1_update_state;

   assign pf2_next_stride_d = (((~stride_match) & (~(pf1_pf_state_q == 2'b00))) == 1'b1) ? pf1_new_stride_q :
                                                                                           pf1_rpt_stride_q;

   assign burst_cnt_inc = (pf1_burst_cnt_q == 2'b00) ? 2'b01 :
                          (pf1_burst_cnt_q == 2'b01) ? 2'b10 :
                                                       2'b11;

   assign pf2_burst_cnt_d = ((pf1_pf_state_q == 2'b01 & stride_match) == 1'b1)    ? burst_cnt_inc :
                            ((pf1_pf_state_q == 2'b01 & (~stride_match)) == 1'b1) ? 2'b00 :
                                                                                    pf1_burst_cnt_q;

   assign pf2_data_ea_d = pf1_data_ea_q;


   tri_rlmreg_p #(.WIDTH(1), .INIT(0)) latch_pf2_gen_pfetch(
										       .nclk(nclk),
                           .act(pf2_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf2_gen_pfetch_offset:pf2_gen_pfetch_offset]),
                           .scout(sov[pf2_gen_pfetch_offset:pf2_gen_pfetch_offset]),
                           .din(generate_pfetch),
                           .dout(pf2_gen_pfetch_q)
                        );


   tri_rlmreg_p #(.WIDTH(22), .INIT(0)) latch_pf2_rpt_stride(
                           .nclk(nclk),
                           .act(pf2_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf2_rpt_stride_offset:pf2_rpt_stride_offset + 22 - 1]),
                           .scout(sov[pf2_rpt_stride_offset:pf2_rpt_stride_offset + 22 - 1]),
                           .din(pf2_next_stride_d),
                           .dout(pf2_stride_q)
                        );


   tri_rlmreg_p #(.WIDTH((59-(64-(2**`GPR_WIDTH_ENC))+1)), .INIT(0)) latch_pf2_data_ea(
                           .nclk(nclk),
                           .act(pf2_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf2_data_ea_offset:pf2_data_ea_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
                           .scout(sov[pf2_data_ea_offset:pf2_data_ea_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
                           .din(pf2_data_ea_d),
                           .dout(pf2_data_ea_q)
                        );


   tri_rlmreg_p #(.WIDTH(`PF_IFAR_WIDTH), .INIT(0)) latch_pf2_iar(
                           .nclk(nclk),
                           .act(pf2_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf2_iar_offset:pf2_iar_offset + `PF_IFAR_WIDTH - 1]),
                           .scout(sov[pf2_iar_offset:pf2_iar_offset + `PF_IFAR_WIDTH - 1]),
                           .din(pf1_iar_q),
                           .dout(pf2_iar_q)
                        );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) latch_pf2_pf_state(
                           .nclk(nclk),
                           .act(pf2_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf2_pf_state_offset:pf2_pf_state_offset + 2 - 1]),
                           .scout(sov[pf2_pf_state_offset:pf2_pf_state_offset + 2 - 1]),
                           .din(pf2_next_state_d),
                           .dout(pf2_pf_state_q)
                        );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) latch_pf2_burst_cnt(
                           .nclk(nclk),
                           .act(pf2_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf2_burst_cnt_offset:pf2_burst_cnt_offset + 2 - 1]),
                           .scout(sov[pf2_burst_cnt_offset:pf2_burst_cnt_offset + 2 - 1]),
                           .din(pf2_burst_cnt_d),
                           .dout(pf2_burst_cnt_q)
                        );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) latch_pf2_hits(
										 .nclk(nclk),
                           .act(pf2_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf2_hits_offset:pf2_hits_offset + 3 - 1]),
                           .scout(sov[pf2_hits_offset:pf2_hits_offset + 3 - 1]),
                           .din(pf1_hits_q),
                           .dout(pf2_hits_q)
                        );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) pf2_rpt_pe_latch(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(pf2_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[pf2_rpt_pe_offset:pf2_rpt_pe_offset + 2 - 1]),
                           .scout(sov[pf2_rpt_pe_offset:pf2_rpt_pe_offset + 2 - 1]),
                           .din(pf1_rpt_pe_q),
                           .dout(pf2_rpt_pe_q)
                        );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) latch_pf2_thrd(
                           .nclk(nclk),
                           .act(pf2_act),
                           .force_t(func_sl_force),
                           .d_mode(d_mode_dc),
                           .delay_lclkr(delay_lclkr_dc),
                           .mpw1_b(mpw1_dc_b),
                           .mpw2_b(mpw2_dc_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .vd(vdd),
                           .gd(gnd),
                           .scin(siv[pf2_thrd_offset:pf2_thrd_offset + `THREADS - 1]),
                           .scout(sov[pf2_thrd_offset:pf2_thrd_offset + `THREADS - 1]),
                           .din(pf1_thrd_q),
                           .dout(pf2_thrd_q)
                        );

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // RPT update
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   assign pf2_valid = pf2_req_val_4pf_q;

   assign rpt_data_in[0] = ~|(pf2_rpt_pe_q);		// valid bit
   assign rpt_data_in[1:22] = pf2_data_ea_q[38:59];		// last data address
   assign rpt_data_in[23:44] = pf2_stride_q;		// stride
   assign rpt_data_in[45:51] = pf2_iar_q[50:56];		// iar tag
   assign rpt_data_in[52:53] = pf2_pf_state_q;		// prefetch state
   assign rpt_data_in[54:55] = pf2_burst_cnt_q;		// burst counter
   assign rpt_data_in[56] = pf2_gen_pfetch_q;		// duplicate flag
   assign rpt_data_in[57:57 + `THREADS - 1] = pf2_thrd_q;		// thread id

   assign rpt_data_in[57 + `THREADS] = ^({rpt_data_in[0:7], inj_pfetch_parity_q});
   assign rpt_data_in[58 + `THREADS] = ^(rpt_data_in[8:15]);
   assign rpt_data_in[59 + `THREADS] = ^(rpt_data_in[16:23]);
   assign rpt_data_in[60 + `THREADS] = ^(rpt_data_in[24:31]);
   assign rpt_data_in[61 + `THREADS] = ^(rpt_data_in[32:39]);
   assign rpt_data_in[62 + `THREADS] = ^(rpt_data_in[40:47]);
   assign rpt_data_in[63 + `THREADS] = ^(rpt_data_in[48:55]);
   assign rpt_data_in[64 + `THREADS] = ^(rpt_data_in[56:57 + `THREADS - 1]);

   assign rpt_data_in[65 + `THREADS:69] = 0;		// unused

   assign rpt_wrt_addr = pf2_iar_q[57:61];


   always @(*)
     begin: old_lru_proc
        reg                                       lru;

        (* analysis_not_referenced="true" *)

        integer                                i;
        lru = 1'b0;
        for (i = 0; i <= 31; i = i + 1)
          lru = (rpt_lru_q[i] & (pf2_iar_q[57:61] == i[4:0])) | lru;

        old_rpt_lru <= lru;
     end

   assign new_rpt_lru = (pf2_hits_q[0:1] == 2'b01) ? 1'b0 :
                        (pf2_hits_q[0:1] == 2'b10) ? 1'b1 :
                                                     (~old_rpt_lru);

   generate
      begin : xhdl6
         genvar                                    i;
         for (i = 0; i <= 31; i = i + 1)
           begin : rpt_lru_gen
              wire [0:4]        iDummy=i;
              assign rpt_lru_d[i] = ((pf2_iar_q[57:61] == iDummy)) ? new_rpt_lru :
                                                                     rpt_lru_q[i];
           end
      end
   endgenerate

   assign rpt_wen[0:1] = |(pf2_rpt_pe_q)                        ? pf2_rpt_pe_q :
                         ((pf2_valid & (~new_rpt_lru)) == 1'b1) ? 2'b01 :
                         ((pf2_valid & new_rpt_lru) == 1'b1)    ? 2'b10 :
                                                                  2'b00;


   tri_rlmreg_p #(.WIDTH(32), .INIT(0)) latch_rpt_lru(
                              .nclk(nclk),
                              .act(pf2_valid),
                              .force_t(func_sl_force),
                              .d_mode(d_mode_dc),
                              .delay_lclkr(delay_lclkr_dc),
                              .mpw1_b(mpw1_dc_b),
                              .mpw2_b(mpw2_dc_b),
                              .thold_b(func_sl_thold_0_b),
                              .sg(sg_0),
                              .vd(vdd),
                              .gd(gnd),
                              .scin(siv[rpt_lru_offset:rpt_lru_offset + 32 - 1]),
                              .scout(sov[rpt_lru_offset:rpt_lru_offset + 32 - 1]),
                              .din(rpt_lru_d),
                              .dout(rpt_lru_q)
                           );

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // Create new prefetches based current load request and store into queue
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   // latch new EA, stride, and dup flag in to prefetch queue

   assign pfq_wrt_ptr_plus1 = pfq_wrt_ptr_q + value1[32-`PFETCH_Q_SIZE_ENC:31];

   assign pfq_full_d = (((pfq_wrt_ptr_plus1 == pfq_rd_ptr_q) & pfq_wrt_val) | (pfq_full_q & (~(pfq_wrt_ptr_plus1 == pfq_rd_ptr_q)))) &
                       ~ctl_pf_clear_queue;

   assign pfq_wrt_val = (generate_pfetch & (~(pf1_dup_flag_q & pf1_same_cline_q))) & (~pfq_full_q) & (~pf1_disable);

   assign pfq_wrt_ptr_d = (ctl_pf_clear_queue == 1'b1) ? {`PFETCH_Q_SIZE_ENC{1'b0}} :
                          (pfq_wrt_val == 1'b1)        ? pfq_wrt_ptr_plus1 :
                                                         pfq_wrt_ptr_q;

   assign pf1_new_data_ea = pf1_data_ea_q + ({ {59-21-1-(64-(2**`GPR_WIDTH_ENC))+1{pf1_rpt_stride_q[0]}}, pf1_rpt_stride_q });

   generate
      begin : xhdl7
         genvar                                    i;
         for (i = 0; i <= `PFETCH_Q_SIZE - 1; i = i + 1)
           begin : pfq_gen
              wire [0:`PFETCH_Q_SIZE_ENC-1]         iDummy=i;
              assign pfq_wen[i] = pfq_wrt_val & (pfq_wrt_ptr_q == iDummy);

              assign pfq_stride_d[i] = (pfq_wen[i] == 1'b1) ? pf1_rpt_stride_q :
                                                              pfq_stride_q[i];

              assign pfq_data_ea_d[i] = (pfq_wen[i] == 1'b1) ? pf1_new_data_ea :
                                                               pfq_data_ea_q[i];

              assign pfq_dup_flag_d[i] = (pfq_wen[i] == 1'b1) ? pf1_dup_flag_q :
                                                                pfq_dup_flag_q[i];

              assign pfq_thrd_d[i] = (ctl_pf_clear_queue == 1'b1)         ? {`THREADS{1'b0}}:
                                     (pfq_wen[i] == 1'b1)                 ? pf1_thrd_q :
              	                     (pf_done & (pfq_rd_ptr_q == iDummy)) ? {`THREADS{1'b0}}:
                                                                             pfq_thrd_q[i];

              assign pfq_dscr_d[i] = (pfq_wen[i] == 1'b1) ? pf1_dscr[61:63] :
                                                            pfq_dscr_q[i];


              tri_rlmreg_p #(.WIDTH(22), .INIT(0), .NEEDS_SRESET(1)) pfq_stride_latch(
                                       .vd(vdd),
                                       .gd(gnd),
                                       .nclk(nclk),
                                       .act(pf2_act),
                                       .force_t(func_sl_force),
                                       .d_mode(d_mode_dc),
                                       .delay_lclkr(delay_lclkr_dc),
                                       .mpw1_b(mpw1_dc_b),
                                       .mpw2_b(mpw2_dc_b),
                                       .thold_b(func_sl_thold_0_b),
                                       .sg(sg_0),
                                       .scin(siv[pfq_stride_offset + 22 * i:pfq_stride_offset + 22 * (i + 1) - 1]),
                                       .scout(sov[pfq_stride_offset + 22 * i:pfq_stride_offset + 22 * (i + 1) - 1]),
                                       .din(pfq_stride_d[i]),
                                       .dout(pfq_stride_q[i])
                                    );


              tri_rlmreg_p #(.WIDTH((59-(64-(2**`GPR_WIDTH_ENC))+1)), .INIT(0), .NEEDS_SRESET(1)) pfq_data_ea_latch(
                                       .vd(vdd),
                                       .gd(gnd),
                                       .nclk(nclk),
                                       .act(pf2_act),
                                       .force_t(func_sl_force),
                                       .d_mode(d_mode_dc),
                                       .delay_lclkr(delay_lclkr_dc),
                                       .mpw1_b(mpw1_dc_b),
                                       .mpw2_b(mpw2_dc_b),
                                       .thold_b(func_sl_thold_0_b),
                                       .sg(sg_0),
                                       .scin(siv[pfq_data_ea_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) * i:pfq_data_ea_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) * (i + 1) - 1]),
                                       .scout(sov[pfq_data_ea_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) * i:pfq_data_ea_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) * (i + 1) - 1]),
                                       .din(pfq_data_ea_d[i]),
                                       .dout(pfq_data_ea_q[i])
                                    );


              tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) pfq_thrd_latch(
                                       .vd(vdd),
                                       .gd(gnd),
                                       .nclk(nclk),
                                       .act(tiup),
                                       .force_t(func_sl_force),
                                       .d_mode(d_mode_dc),
                                       .delay_lclkr(delay_lclkr_dc),
                                       .mpw1_b(mpw1_dc_b),
                                       .mpw2_b(mpw2_dc_b),
                                       .thold_b(func_sl_thold_0_b),
                                       .sg(sg_0),
                                       .scin(siv[pfq_thrd_offset + `THREADS * i:pfq_thrd_offset + `THREADS * (i + 1) - 1]),
                                       .scout(sov[pfq_thrd_offset + `THREADS * i:pfq_thrd_offset + `THREADS * (i + 1) - 1]),
				       .din(pfq_thrd_d[i]),
				       .dout(pfq_thrd_q[i])
				);


              tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) pfq_dscr_latch(
				.vd(vdd),
				.gd(gnd),
				.nclk(nclk),
				.act(pf2_act),
				.force_t(func_sl_force),
				.d_mode(d_mode_dc),
				.delay_lclkr(delay_lclkr_dc),
				.mpw1_b(mpw1_dc_b),
				.mpw2_b(mpw2_dc_b),
				.thold_b(func_sl_thold_0_b),
				.sg(sg_0),
				.scin(siv[pfq_dscr_offset + 3 * i:pfq_dscr_offset + 3 * (i + 1) - 1]),
				.scout(sov[pfq_dscr_offset + 3 * i:pfq_dscr_offset + 3 * (i + 1) - 1]),
				.din(pfq_dscr_d[i]),
				.dout(pfq_dscr_q[i])
				 );
           end
      end
   endgenerate


   tri_rlmreg_p #(.WIDTH(`PFETCH_Q_SIZE), .INIT(1)) latch_pfq_dup_flag(
                                 .nclk(nclk),
                                 .act(pf2_act),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .scin(siv[pfq_dup_flag_offset:pfq_dup_flag_offset + `PFETCH_Q_SIZE - 1]),
                                 .scout(sov[pfq_dup_flag_offset:pfq_dup_flag_offset + `PFETCH_Q_SIZE - 1]),
                                 .din(pfq_dup_flag_d),
                                 .dout(pfq_dup_flag_q)
                              );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pfq_full_latch(
											  .vd(vdd),
                                 .gd(gnd),
                                 .nclk(nclk),
                                 .act(tiup),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[pfq_full_offset]),
                                 .scout(sov[pfq_full_offset]),
                                 .din(pfq_full_d),
                                 .dout(pfq_full_q)
														     );


   tri_rlmreg_p #(.WIDTH(`PFETCH_Q_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) pfq_wrt_ptr_latch(
                                 .vd(vdd),
                                 .gd(gnd),
                                 .nclk(nclk),
                                 .act(tiup),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[pfq_wrt_ptr_offset:pfq_wrt_ptr_offset + `PFETCH_Q_SIZE_ENC - 1]),
                                 .scout(sov[pfq_wrt_ptr_offset:pfq_wrt_ptr_offset + `PFETCH_Q_SIZE_ENC - 1]),
                                 .din(pfq_wrt_ptr_d),
                                 .dout(pfq_wrt_ptr_q)
																		 );

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // State Machine to read the prefetch queue
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   assign pf_rd_val = ((~(pfq_wrt_ptr_q == pfq_rd_ptr_q)) | pfq_full_q) & (~ctl_pf_clear_queue);

   assign pf_empty = ~(pfq_thrd_v) &
                     ~({`THREADS{ex6_req_val_4pf_q}} & ex6_thrd_q) &
                     ~({`THREADS{ex7_req_val_4pf_q}} & ex7_thrd_q) &
                     ~({`THREADS{ex8_req_val_4pf_q}} & ex8_thrd_q) &
                     ~({`THREADS{pf1_req_val_4pf_q}} & pf1_thrd_q) &
                     ~({`THREADS{pf2_req_val_4pf_q}} & pf2_thrd_q);

   assign pf_idle = pf_state_q[4];
   assign pf_gen = pf_state_q[0];
   assign pf_send = pf_state_q[1];
   assign pf_next = pf_state_q[2];
   assign pf_done = pf_state_q[3];


   always @(*)
     begin: pf_state_mach

        pf_nxt_idle <= 1'b0;
        pf_nxt_gen <= 1'b0;
        pf_nxt_send <= 1'b0;
        pf_nxt_next <= 1'b0;
        pf_nxt_done <= 1'b0;

        if (pf_idle == 1'b1)
          begin
             if (pf_rd_val == 1'b1)
               pf_nxt_gen <= 1'b1;
             else
               pf_nxt_idle <= 1'b1;
          end

        if (pf_gen == 1'b1)
          begin
             if (block_dup_pfetch == 1'b0)
               pf_nxt_send <= 1'b1;
             else
               pf_nxt_next <= 1'b1;
          end

        if (pf_send == 1'b1)
          begin
             if (dec_pf_ack == 1'b1)
	             pf_nxt_next <= 1'b1;
             else
	             pf_nxt_send <= 1'b1;
          end

        if (pf_next == 1'b1)
          begin
             if (pf_count_q == 3'b000)
	             pf_nxt_done <= 1'b1;
             else if (block_dup_pfetch == 1'b0)
	             pf_nxt_send <= 1'b1;
             else
	             pf_nxt_next <= 1'b1;
          end

        if (pf_done == 1'b1)
          pf_nxt_idle <= 1'b1;

     end

   assign pf_nxt_state[4] = pf_nxt_idle | ctl_pf_clear_queue;
   assign pf_nxt_state[0] = pf_nxt_gen & (~ctl_pf_clear_queue);
   assign pf_nxt_state[1] = pf_nxt_send & (~ctl_pf_clear_queue);
   assign pf_nxt_state[2] = pf_nxt_next & (~ctl_pf_clear_queue);
   assign pf_nxt_state[3] = pf_nxt_done & (~ctl_pf_clear_queue);


   tri_rlmreg_p #(.WIDTH(5), .INIT(1)) latch_pf_state(
      .nclk(nclk),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(siv[pf_state_offset:pf_state_offset + 5 - 1]),
      .scout(sov[pf_state_offset:pf_state_offset + 5 - 1]),
      .din(pf_nxt_state),
      .dout(pf_state_q)
   );

   // count the number of prefetches to issue
   assign pf_count_d = (pf_gen == 1'b1)  ? pfq_rd_dscr[61:63] - value2[29:31] :
                       (pf_next == 1'b1) ? pf_count_q - value1[29:31] :
                                           pf_count_q;


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) latch_pf_count(
                                 .nclk(nclk),
                                 .act(tiup),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .scin(siv[pf_count_offset:pf_count_offset + 3 - 1]),
                                 .scout(sov[pf_count_offset:pf_count_offset + 3 - 1]),
                                 .din(pf_count_d),
                                 .dout(pf_count_q)
										 );

   // increment read pointer when prefetches for that entry are done
   assign pfq_rd_ptr_d = (ctl_pf_clear_queue == 1'b1) ? {`PFETCH_Q_SIZE_ENC{1'b0}} :
                         (pf_done == 1'b1)            ? pfq_rd_ptr_q + value1[32-`PFETCH_Q_SIZE_ENC:31] :
                                                        pfq_rd_ptr_q;


   tri_rlmreg_p #(.WIDTH(`PFETCH_Q_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) pfq_rd_ptr_latch(
														     .vd(vdd),
                                 .gd(gnd),
                                 .nclk(nclk),
                                 .act(tiup),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[pfq_rd_ptr_offset:pfq_rd_ptr_offset + `PFETCH_Q_SIZE_ENC - 1]),
                                 .scout(sov[pfq_rd_ptr_offset:pfq_rd_ptr_offset + `PFETCH_Q_SIZE_ENC - 1]),
                                 .din(pfq_rd_ptr_d),
                                 .dout(pfq_rd_ptr_q)
														     );

   // mux next address from prefetch queue

   always @(*)
     begin: pfq_rd_data_proc
        reg [0:21]                                rd_stride;
        reg [64-(2**`GPR_WIDTH_ENC):59] 		  rd_data_ea;
        reg                                       rd_dup_flag;
        reg [0:`THREADS-1] 			  rd_thrd;
        reg [61:63] 				  rd_dscr;
        reg [0:`THREADS-1]                        thrd_v;
        reg [0:31]                                i;
        rd_stride = {22{1'b0}};
        rd_data_ea = {59-(64-(2**`GPR_WIDTH_ENC))+1{1'b0}};
        rd_dup_flag = 1'b0;
        rd_thrd = {`THREADS{1'b0}};
        rd_dscr = {3{1'b0}};
        thrd_v = {`THREADS{1'b0}};
        for (i = 0; i <= `PFETCH_Q_SIZE - 1; i = i + 1)
          begin
             rd_stride =   (                           {22{(pfq_rd_ptr_q == i[32-`PFETCH_Q_SIZE_ENC:31])}} & pfq_stride_q[i])   | rd_stride;
             rd_data_ea =  ({59-(64-(2**`GPR_WIDTH_ENC))+1{(pfq_rd_ptr_q == i[32-`PFETCH_Q_SIZE_ENC:31])}} & pfq_data_ea_q[i])  | rd_data_ea;
             rd_dup_flag = (                               (pfq_rd_ptr_q == i[32-`PFETCH_Q_SIZE_ENC:31])   & pfq_dup_flag_q[i]) | rd_dup_flag;
             rd_thrd =     (                     {`THREADS{(pfq_rd_ptr_q == i[32-`PFETCH_Q_SIZE_ENC:31])}} & pfq_thrd_q[i])     | rd_thrd;
             rd_dscr =     (                             {3{pfq_rd_ptr_q == i[32-`PFETCH_Q_SIZE_ENC:31]}}  & pfq_dscr_q[i])     | rd_dscr;
             thrd_v =      pfq_thrd_q[i] | thrd_v;
          end
        pf3_stride_d <= rd_stride;
        pfq_rd_data_ea <= rd_data_ea;
        pfq_rd_dup_flag <= rd_dup_flag;
        pfq_rd_thrd <= rd_thrd;
        pfq_rd_dscr <= rd_dscr;
        pfq_thrd_v <= thrd_v;
     end

   assign pf3_act = (~pf_idle);


   tri_rlmreg_p #(.WIDTH(22), .INIT(0), .NEEDS_SRESET(1)) pf3_stride_latch(
                                 .vd(vdd),
                                 .gd(gnd),
                                 .nclk(nclk),
                                 .act(pf3_act),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .scin(siv[pf3_stride_offset:pf3_stride_offset + 22 - 1]),
                                 .scout(sov[pf3_stride_offset:pf3_stride_offset + 22 - 1]),
                                 .din(pf3_stride_d),
                                 .dout(pf3_stride_q)
												      );

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // Prefetch Generation
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   assign block_dup_pfetch = (pfq_rd_dup_flag & (~(pf_count_d == 3'b000)));		// after 1st set of N prefetches, only prefetch the last of N

   assign pf3_req_val_d = ((pf_gen | (pf_next & (~(pf_count_q == 3'b000)))) == 1'b1) ? pf_rd_val & (~block_dup_pfetch) :
                          ((pf_send & (~dec_pf_ack)) == 1'b1)                        ? pf3_req_val_q & (~ctl_pf_clear_queue) :
                                                                                       1'b0;

   assign pf3_thrd_d = (pf_gen == 1'b1) ? pfq_rd_thrd :
                                          pf3_thrd_q;

   assign pf3_req_addr_d = (pf_gen == 1'b1)  ? pfq_rd_data_ea :
                           (pf_next == 1'b1) ? pf3_req_addr_q + ({ {59-21-1-(64-(2**`GPR_WIDTH_ENC))+1{pf3_stride_q[0]}}, pf3_stride_q }) :
                                               pf3_req_addr_q;


   tri_rlmreg_p #(.WIDTH((59-(64-(2**`GPR_WIDTH_ENC))+1)), .INIT(0)) latch_pf3_req_addr(
                                 .nclk(nclk),
                                 .act(pf3_act),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .scin(siv[pf3_req_addr_offset:pf3_req_addr_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
                                 .scout(sov[pf3_req_addr_offset:pf3_req_addr_offset + (59-(64-(2**`GPR_WIDTH_ENC))+1) - 1]),
                                 .din(pf3_req_addr_d),
                                 .dout(pf3_req_addr_q)
														);

   assign pf_dec_req_addr = pf3_req_addr_q[64 - (2 ** `GPR_WIDTH_ENC):63 - `CL_SIZE];


   tri_rlmreg_p #(.WIDTH(1), .INIT(0)) latch_pf3_req_val(
                                 .nclk(nclk),
                                 .act(pf3_act),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .scin(siv[pf3_req_val_offset:pf3_req_val_offset]),
                                 .scout(sov[pf3_req_val_offset:pf3_req_val_offset]),
                                 .din(pf3_req_val_d),
                                 .dout(pf3_req_val_q)
										    );

   assign pf_dec_req_val = pf3_req_val_q & (~ctl_pf_clear_queue);


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) latch_pf3_thrd(
                                 .nclk(nclk),
                                 .act(pf3_act),
                                 .force_t(func_sl_force),
                                 .d_mode(d_mode_dc),
                                 .delay_lclkr(delay_lclkr_dc),
                                 .mpw1_b(mpw1_dc_b),
                                 .mpw2_b(mpw2_dc_b),
                                 .thold_b(func_sl_thold_0_b),
                                 .sg(sg_0),
                                 .vd(vdd),
                                 .gd(gnd),
                                 .scin(siv[pf3_thrd_offset:pf3_thrd_offset + `THREADS - 1]),
                                 .scout(sov[pf3_thrd_offset:pf3_thrd_offset + `THREADS - 1]),
                                 .din(pf3_thrd_d),
                                 .dout(pf3_thrd_q)
										       );

   assign pf_dec_req_thrd = pf3_thrd_q;

   assign rpt_func_scan_in = scan_in;
   assign siv[0:scan_right] = {sov[1:scan_right], rpt_func_scan_out};
   assign scan_out = sov[0];

endmodule
