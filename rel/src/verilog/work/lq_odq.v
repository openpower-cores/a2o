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



module lq_odq(		
   rv_lq_rv1_i0_vld,
   rv_lq_rv1_i0_ucode_preissue,
   rv_lq_rv1_i0_s3_t,
   rv_lq_rv1_i0_rte_lq,
   rv_lq_rv1_i0_rte_sq,
   rv_lq_rv1_i0_isLoad,
   rv_lq_rv1_i0_isStore,
   rv_lq_rv1_i0_itag,
   rv_lq_rv1_i1_vld,
   rv_lq_rv1_i1_ucode_preissue,
   rv_lq_rv1_i1_s3_t,
   rv_lq_rv1_i1_rte_lq,
   rv_lq_rv1_i1_rte_sq,
   rv_lq_rv1_i1_isLoad,
   rv_lq_rv1_i1_isStore,
   rv_lq_rv1_i1_itag,
   ldq_odq_vld,
   ldq_odq_tid,
   ldq_odq_wimge_i,
   ldq_odq_inv,
   ldq_odq_hit,
   ldq_odq_fwd,
   ldq_odq_addr,
   ldq_odq_bytemask,
   ldq_odq_itag,
   ldq_odq_cline_chk,
   ldq_odq_ex6_pEvents,
   ctl_lsq_ex6_ldh_dacrw,
   ldq_odq_upd_val,
   ldq_odq_upd_itag,
   ldq_odq_upd_nFlush,
   ldq_odq_upd_np1Flush,
   ldq_odq_upd_tid,
   ldq_odq_upd_dacrw,
   ldq_odq_upd_eccue,
   ldq_odq_upd_pEvents,
   ldq_odq_pfetch_vld,
   odq_ldq_resolved,
   odq_ldq_report_needed,
   odq_ldq_report_itag,
   odq_ldq_n_flush,
   odq_ldq_np1_flush,
   odq_ldq_report_tid,
   odq_ldq_report_dacrw,
   odq_ldq_report_eccue,
   odq_ldq_report_pEvents,
   odq_stq_resolved,
   odq_stq_stTag,
   odq_ldq_oldest_ld_tid,
   odq_ldq_oldest_ld_itag,
   odq_ldq_ex7_pfetch_blk,
   lsq_ctl_oldest_tid,
   lsq_ctl_oldest_itag,
   ctl_lsq_ex2_thrd_id,
   ctl_lsq_ex2_itag,
   stq_odq_i0_stTag,
   stq_odq_i1_stTag,
   stq_odq_stq4_stTag_inval,
   stq_odq_stq4_stTag,
   odq_stq_ex2_nxt_oldest_val,
   odq_stq_ex2_nxt_oldest_stTag,
   odq_stq_ex2_nxt_youngest_val,
   odq_stq_ex2_nxt_youngest_stTag,
   iu_lq_cp_next_itag,
   iu_lq_i0_completed,
   iu_lq_i0_completed_itag,
   iu_lq_i1_completed,
   iu_lq_i1_completed_itag,
   l2_back_inv_val,
   l2_back_inv_addr,
   iu_lq_cp_flush,
   lq_iu_credit_free,
   xu_lq_spr_xucr0_cls,
   lsq_perv_odq_events,
   vdd,
   gnd,
   nclk,
   sg_0,
   func_sl_thold_0_b,
   func_sl_force,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   scan_in,
   scan_out
);

   parameter DACR_WIDTH = 4;

   
   input [0:`THREADS-1]              rv_lq_rv1_i0_vld;
   input                             rv_lq_rv1_i0_ucode_preissue;
   input [0:2]                       rv_lq_rv1_i0_s3_t;
   input                             rv_lq_rv1_i0_rte_lq;
   input                             rv_lq_rv1_i0_rte_sq;
   input                             rv_lq_rv1_i0_isLoad;
   input                             rv_lq_rv1_i0_isStore;
   input [0:`ITAG_SIZE_ENC-1] 	     rv_lq_rv1_i0_itag;
   
   input [0:`THREADS-1]              rv_lq_rv1_i1_vld;
   input                             rv_lq_rv1_i1_ucode_preissue;
   input [0:2]                       rv_lq_rv1_i1_s3_t;
   input                             rv_lq_rv1_i1_rte_lq;
   input                             rv_lq_rv1_i1_rte_sq;
   input                             rv_lq_rv1_i1_isLoad;
   input                             rv_lq_rv1_i1_isStore;
   input [0:`ITAG_SIZE_ENC-1] 	     rv_lq_rv1_i1_itag;
   
   input                             ldq_odq_vld;
   input [0:`THREADS-1]              ldq_odq_tid;
   input                             ldq_odq_wimge_i;
   input                             ldq_odq_inv;
   input                             ldq_odq_hit;
   input                             ldq_odq_fwd;
   input [64-`REAL_IFAR_WIDTH:59]    ldq_odq_addr;
   input [0:15]                      ldq_odq_bytemask;
   input [0:`ITAG_SIZE_ENC-1]        ldq_odq_itag;
   input                             ldq_odq_cline_chk;
   input [0:3]                       ldq_odq_ex6_pEvents;

   input [0:DACR_WIDTH-1]            ctl_lsq_ex6_ldh_dacrw;
   
   input                             ldq_odq_upd_val;
   input [0:`ITAG_SIZE_ENC-1]        ldq_odq_upd_itag;
   input                             ldq_odq_upd_nFlush;
   input                             ldq_odq_upd_np1Flush;
   input [0:`THREADS-1]              ldq_odq_upd_tid;
   input [0:DACR_WIDTH-1]            ldq_odq_upd_dacrw;
   input                             ldq_odq_upd_eccue;
   input [0:3]                       ldq_odq_upd_pEvents;
   input                             ldq_odq_pfetch_vld;

   output                            odq_ldq_resolved;
   output                            odq_ldq_report_needed;
   output [0:`ITAG_SIZE_ENC-1]       odq_ldq_report_itag;
   output                            odq_ldq_n_flush;
   output                            odq_ldq_np1_flush;
   output [0:`THREADS-1]             odq_ldq_report_tid;
   output [0:DACR_WIDTH-1]           odq_ldq_report_dacrw;
   output                            odq_ldq_report_eccue;
   output [0:3]                      odq_ldq_report_pEvents;
   output                            odq_stq_resolved;
   output [0:`STQ_ENTRIES-1]         odq_stq_stTag;
   
   output [0:`THREADS-1]             odq_ldq_oldest_ld_tid;
   output [0:`ITAG_SIZE_ENC-1]       odq_ldq_oldest_ld_itag;
   output                            odq_ldq_ex7_pfetch_blk;

   output [0:`THREADS-1]             lsq_ctl_oldest_tid;
   output [0:`ITAG_SIZE_ENC-1]       lsq_ctl_oldest_itag;
   
   input [0:`THREADS-1]              ctl_lsq_ex2_thrd_id;
   input [0:`ITAG_SIZE_ENC-1]        ctl_lsq_ex2_itag;
   
   input [0:`STQ_ENTRIES_ENC-1]      stq_odq_i0_stTag;
   input [0:`STQ_ENTRIES_ENC-1]      stq_odq_i1_stTag;
   
   input                             stq_odq_stq4_stTag_inval;
   input [0:`STQ_ENTRIES_ENC-1]      stq_odq_stq4_stTag;
   
   output                            odq_stq_ex2_nxt_oldest_val;
   output [0:`STQ_ENTRIES-1]         odq_stq_ex2_nxt_oldest_stTag;
   
   output                            odq_stq_ex2_nxt_youngest_val;
   output [0:`STQ_ENTRIES-1]         odq_stq_ex2_nxt_youngest_stTag;
   
   input [0:(`THREADS * `ITAG_SIZE_ENC)-1]  iu_lq_cp_next_itag;
   
   input [0:`THREADS-1]                     iu_lq_i0_completed;
   input [0:(`THREADS * `ITAG_SIZE_ENC)-1]  iu_lq_i0_completed_itag;
   input [0:`THREADS-1]                     iu_lq_i1_completed;
   input [0:(`THREADS * `ITAG_SIZE_ENC)-1]  iu_lq_i1_completed_itag;
   
   input                             l2_back_inv_val;
   input [67-`DC_SIZE:63-`CL_SIZE]   l2_back_inv_addr;
   
   input [0:`THREADS-1]              iu_lq_cp_flush;
   
   output [0:`THREADS-1]             lq_iu_credit_free;
   
   input                             xu_lq_spr_xucr0_cls;

   output [0:4+`THREADS-1]           lsq_perv_odq_events;
   
   
   
   
   inout                             vdd;
   
   
   inout                             gnd;
   
   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)
   
   input [0:`NCLK_WIDTH-1]           nclk;
   input                             sg_0;
   input                             func_sl_thold_0_b;
   input                             func_sl_force;
   input                             d_mode_dc;
   input                             delay_lclkr_dc;
   input                             mpw1_dc_b;
   input                             mpw2_dc_b;
   
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   
   input                             scan_in;
   
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   
   output                            scan_out;

   wire [0:`LDSTQ_ENTRIES-1] 	     remove_entry_base;
   wire [0:`LDSTQ_ENTRIES-1] 	     compress_vector;
   wire                              compress_val;
   wire [0:`LDSTQ_ENTRIES_ENC-1]     compress_entry;
   wire [0:`LDSTQ_ENTRIES-1] 	     remove_entry_vec;
   reg  [0:`LDSTQ_ENTRIES_ENC-1]     remove_entry;
   reg  [0:`THREADS-1]               remove_tid;
   
   wire [67-`DC_SIZE:63-`CL_SIZE]    oldest_entry_p0_cclass;
   wire [67-`DC_SIZE:63-`CL_SIZE]    oldest_entry_p1_cclass;
   wire                              oldest_entry_p0_m_rv0;
   wire                              oldest_entry_p1_m_rv0;
   wire                              oldest_entry_p1_m_rv1;
   wire                              oldest_entry_p1_m_ex0;
   wire                              oldest_entry_p1_m_ex1;
   wire                              oldest_entry_p1_m_ex2;
   wire                              oldest_entry_p1_m_ex3;
   wire                              oldest_entry_p1_m_ex4;
   wire                              oldest_entry_p1_m_ex5;
   wire                              entry_rv1_blk_d;
   wire                              entry_rv1_blk_q;
   wire                              entry_ex0_blk_d;
   wire                              entry_ex0_blk_q;
   wire                              entry_ex1_blk_d;
   wire                              entry_ex1_blk_q;
   wire                              entry_ex2_blk_d;
   wire                              entry_ex2_blk_q;
   wire                              entry_ex3_blk_d;
   wire                              entry_ex3_blk_q;
   wire                              entry_ex4_blk_d;
   wire                              entry_ex4_blk_q;
   wire                              entry_ex5_blk_d;
   wire                              entry_ex5_blk_q;
   wire                              entry_ex6_blk_d;
   wire                              entry_ex6_blk_q;
   wire                              oldest_entry_blk;
   
   reg                               orderq_entry_inuse_d[0:`LDSTQ_ENTRIES-1];      
   wire                              orderq_entry_inuse_q[0:`LDSTQ_ENTRIES-1];
   reg  [0:`THREADS-1] 	             orderq_entry_tid_d[0:`LDSTQ_ENTRIES-1];        
   wire [0:`THREADS-1]               orderq_entry_tid_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_val_d[0:`LDSTQ_ENTRIES-1];        
   wire                              orderq_entry_val_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_ld_d[0:`LDSTQ_ENTRIES-1];         
   wire                              orderq_entry_ld_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_efs_d[0:`LDSTQ_ENTRIES-1];        
   wire                              orderq_entry_efs_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_i_d[0:`LDSTQ_ENTRIES-1];          
   wire                              orderq_entry_i_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_hit_d[0:`LDSTQ_ENTRIES-1];        
   wire                              orderq_entry_hit_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_fwd_d[0:`LDSTQ_ENTRIES-1];        
   wire                              orderq_entry_fwd_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_cls_op_d[0:`LDSTQ_ENTRIES-1];     
   wire                              orderq_entry_cls_op_q[0:`LDSTQ_ENTRIES-1];
   reg  [0:DACR_WIDTH-1]             orderq_entry_dacrw_d[0:`LDSTQ_ENTRIES-1];      
   wire [0:DACR_WIDTH-1]             orderq_entry_dacrw_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_eccue_d[0:`LDSTQ_ENTRIES-1];      
   wire                              orderq_entry_eccue_q[0:`LDSTQ_ENTRIES-1];
   reg  [0:3]                        orderq_entry_pEvents_d[0:`LDSTQ_ENTRIES-1];    
   wire [0:3]                        orderq_entry_pEvents_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_pre_d[0:`LDSTQ_ENTRIES-1];        
   wire                              orderq_entry_pre_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_instq_d[0:`LDSTQ_ENTRIES-1];      
   wire                              orderq_entry_instq_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_flushed_d[0:`LDSTQ_ENTRIES-1];    
   wire                              orderq_entry_flushed_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_myflush_d[0:`LDSTQ_ENTRIES-1];    
   wire                              orderq_entry_myflush_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_ld_chk_d[0:`LDSTQ_ENTRIES-1];     
   wire                              orderq_entry_ld_chk_q[0:`LDSTQ_ENTRIES-1];
   reg  [0:`STQ_ENTRIES_ENC-1] 	     orderq_entry_stTag_d[0:`LDSTQ_ENTRIES-1];      
   wire [0:`STQ_ENTRIES_ENC-1] 	     orderq_entry_stTag_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_cmmt_d[0:`LDSTQ_ENTRIES-1];       
   wire                              orderq_entry_cmmt_q[0:`LDSTQ_ENTRIES-1];
   
   reg                               orderq_entry_bi_flag_d[0:`LDSTQ_ENTRIES-1];    
   wire                              orderq_entry_bi_flag_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_bi_flush_d[0:`LDSTQ_ENTRIES-1];   
   wire                              orderq_entry_bi_flush_q[0:`LDSTQ_ENTRIES-1];
   
   reg                               orderq_entry_val2_d[0:`LDSTQ_ENTRIES-1];       
   wire                              orderq_entry_val2_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_n_flush_d[0:`LDSTQ_ENTRIES-1];    
   wire                              orderq_entry_n_flush_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_np1_flush_d[0:`LDSTQ_ENTRIES-1];  
   wire                              orderq_entry_np1_flush_q[0:`LDSTQ_ENTRIES-1];
   reg                               orderq_entry_update_pulse_d[0:`LDSTQ_ENTRIES-1];
   wire                              orderq_entry_update_pulse_q[0:`LDSTQ_ENTRIES-1];
   
   reg  [0:`ITAG_SIZE_ENC-1] 	     orderq_entry_itag_d[0:`LDSTQ_ENTRIES-1];       
   wire [0:`ITAG_SIZE_ENC-1] 	     orderq_entry_itag_q[0:`LDSTQ_ENTRIES-1];
   
   reg                               addrq_entry_inuse_d[0:`LDSTQ_ENTRIES-1];       
   wire                              addrq_entry_inuse_q[0:`LDSTQ_ENTRIES-1];
   reg                               addrq_entry_val_d[0:`LDSTQ_ENTRIES-1];         
   wire                              addrq_entry_val_q[0:`LDSTQ_ENTRIES-1];
   reg  [0:`THREADS-1]               addrq_entry_tid_d[0:`LDSTQ_ENTRIES-1];         
   wire [0:`THREADS-1]               addrq_entry_tid_q[0:`LDSTQ_ENTRIES-1];
   reg  [0:`ITAG_SIZE_ENC-1] 	     addrq_entry_itag_d[0:`LDSTQ_ENTRIES-1];        
   wire [0:`ITAG_SIZE_ENC-1] 	     addrq_entry_itag_q[0:`LDSTQ_ENTRIES-1];
   reg  [64-`REAL_IFAR_WIDTH:59]     addrq_entry_address_d[0:`LDSTQ_ENTRIES-1];     
   wire [64-`REAL_IFAR_WIDTH:59]     addrq_entry_address_q[0:`LDSTQ_ENTRIES-1];
   reg  [0:15]                       addrq_entry_bytemask_d[0:`LDSTQ_ENTRIES-1];    
   wire [0:15]                       addrq_entry_bytemask_q[0:`LDSTQ_ENTRIES-1];
   
   wire                              compress_val_d;
   wire                              compress_val_q;


   wire [0:`THREADS-1]               ex0_i0_vld_q;
   wire                              ex0_i0_rte_lq_q;
   wire                              ex0_i0_rte_sq_q;
   wire                              ex0_i0_ucode_preissue_q;
   wire [0:2]                        ex0_i0_s3_t_q;
   wire                              ex0_i0_isLoad_q;
   wire                              ex0_i0_isStore_q;
   wire [0:`ITAG_SIZE_ENC-1]         ex0_i0_itag_q;

   wire [0:`THREADS-1]               ex1_i0_vld_d;
   wire [0:`THREADS-1]               ex1_i0_vld_q;
   wire                              ex1_i0_pre_d;
   wire                              ex1_i0_pre_q;
   wire                              ex1_i0_isLoad_d;
   wire                              ex1_i0_isLoad_q;
   wire [0:`ITAG_SIZE_ENC-1] 	     ex1_i0_itag_d;
   wire [0:`ITAG_SIZE_ENC-1] 	     ex1_i0_itag_q;
   
   wire [0:`THREADS-1]               ex0_i1_vld_q;
   wire                              ex0_i1_rte_lq_q;
   wire                              ex0_i1_rte_sq_q;
   wire                              ex0_i1_ucode_preissue_q;
   wire [0:2]                        ex0_i1_s3_t_q;
   wire                              ex0_i1_isLoad_q;
   wire                              ex0_i1_isStore_q;
   wire [0:`ITAG_SIZE_ENC-1]         ex0_i1_itag_q;

   wire [0:`THREADS-1]               ex1_i1_vld_d;
   wire [0:`THREADS-1]               ex1_i1_vld_q;
   wire                              ex1_i1_pre_d;
   wire                              ex1_i1_pre_q;
   wire                              ex1_i1_isLoad_d;
   wire                              ex1_i1_isLoad_q;
   wire [0:`ITAG_SIZE_ENC-1]         ex1_i1_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]         ex1_i1_itag_q;


   wire [0:`LDSTQ_ENTRIES]           next_fill_ptr_d;
   wire [0:`LDSTQ_ENTRIES]           next_fill_ptr_q;
   
   wire [0:`LDSTQ_ENTRIES_ENC-1]     flushed_credit_count_d[0:`THREADS-1];
   wire [0:`LDSTQ_ENTRIES_ENC-1]     flushed_credit_count_q[0:`THREADS-1];
   
   wire [0:`THREADS-1]               cp_flush_d;
   wire [0:`THREADS-1]               cp_flush_q;
   wire [0:`THREADS-1]               cp_flush2_d;
   wire [0:`THREADS-1]               cp_flush2_q;
   wire [0:`THREADS-1]               cp_flush3_d;
   wire [0:`THREADS-1] 	             cp_flush3_q;
   wire [0:`THREADS-1] 	             cp_flush4_d;
   wire [0:`THREADS-1] 	             cp_flush4_q;
   wire [0:`THREADS-1] 	             cp_flush5_d;
   wire [0:`THREADS-1] 	             cp_flush5_q;
   
   wire                              xu_lq_spr_xucr0_cls_q;
   wire [0:`THREADS-1]               lq_iu_credit_free_d;
   wire [0:`THREADS-1]               lq_iu_credit_free_q;
   
   wire                              ldq_odq_vld_q;
   wire [0:`THREADS-1] 	             ldq_odq_tid_q;
   wire                              ldq_odq_inv_q;
   wire                              ldq_odq_wimge_i_q;
   wire                              ldq_odq_hit_q;
   wire                              ldq_odq_fwd_q;
   wire [0:`ITAG_SIZE_ENC-1] 	     ldq_odq_itag_q;
   wire                              ldq_odq_cline_chk_q;
   wire [0:`ITAG_SIZE_ENC-1] 	     iu_lq_cp_next_itag_q[0:`THREADS-1];
   wire [0:`THREADS-1]               cp_i0_completed_q;
   wire [0:`ITAG_SIZE_ENC-1] 	     cp_i0_completed_itag_q[0:`THREADS-1];
   wire [0:`THREADS-1]               cp_i1_completed_q;
   wire [0:`ITAG_SIZE_ENC-1] 	     cp_i1_completed_itag_q[0:`THREADS-1];
   
   reg                               orderq_entry_inuse_next[0:`LDSTQ_ENTRIES];     
   reg [0:`THREADS-1]                orderq_entry_tid_next[0:`LDSTQ_ENTRIES];       
   reg                               orderq_entry_val_next[0:`LDSTQ_ENTRIES];       
   reg                               orderq_entry_ld_next[0:`LDSTQ_ENTRIES];        
   reg                               orderq_entry_efs_next[0:`LDSTQ_ENTRIES];       
   reg                               orderq_entry_i_next[0:`LDSTQ_ENTRIES];         
   reg                               orderq_entry_hit_next[0:`LDSTQ_ENTRIES];       
   reg                               orderq_entry_fwd_next[0:`LDSTQ_ENTRIES];       
   reg                               orderq_entry_cls_op_next[0:`LDSTQ_ENTRIES];    
   reg  [0:DACR_WIDTH-1] 	         orderq_entry_dacrw_next[0:`LDSTQ_ENTRIES];     
   reg                               orderq_entry_eccue_next[0:`LDSTQ_ENTRIES];     
   reg  [0:3] 	                     orderq_entry_pEvents_next[0:`LDSTQ_ENTRIES];   
   reg                               orderq_entry_pre_next[0:`LDSTQ_ENTRIES];		
   reg                               orderq_entry_instq_next[0:`LDSTQ_ENTRIES];		
   reg                               orderq_entry_flushed_next[0:`LDSTQ_ENTRIES];	
   reg                               orderq_entry_myflush_next[0:`LDSTQ_ENTRIES];	
   reg                               orderq_entry_ld_chk_next[0:`LDSTQ_ENTRIES];	
   reg  [0:`STQ_ENTRIES_ENC-1] 	     orderq_entry_stTag_next[0:`LDSTQ_ENTRIES];		
   reg                               orderq_entry_cmmt_next[0:`LDSTQ_ENTRIES];		
   reg                               orderq_entry_bi_flag_next[0:`LDSTQ_ENTRIES];	
   reg                               orderq_entry_bi_flush_next[0:`LDSTQ_ENTRIES];	
   reg                               orderq_entry_val2_next[0:`LDSTQ_ENTRIES];		
   reg                               orderq_entry_n_flush_next[0:`LDSTQ_ENTRIES];	
   reg                               orderq_entry_np1_flush_next[0:`LDSTQ_ENTRIES];	
   reg                               orderq_entry_update_pulse_next[0:`LDSTQ_ENTRIES];	
   reg  [0:`ITAG_SIZE_ENC-1] 	     orderq_entry_itag_next[0:`LDSTQ_ENTRIES];		
   wire [0:`STQ_ENTRIES-1]           orderq_entry_stTag_1hot[0:`LDSTQ_ENTRIES-1];   
   wire                              orderq_entry_instq_inval[0:`LDSTQ_ENTRIES-1];	
   reg  [0:`ITAG_SIZE_ENC-1]         oderq_entry_i0_comp_itag[0:`LDSTQ_ENTRIES-1];  
   reg  [0:`ITAG_SIZE_ENC-1] 	     oderq_entry_i1_comp_itag[0:`LDSTQ_ENTRIES-1];  
   wire                              orderq_entry_i0_cmmt[0:`LDSTQ_ENTRIES-1];		
   wire                              orderq_entry_i1_cmmt[0:`LDSTQ_ENTRIES-1];      
   wire                              orderq_entry_cmmt[0:`LDSTQ_ENTRIES-1];	        
   
   reg                               addrq_entry_inuse_next[0:`LDSTQ_ENTRIES];		
   reg                               addrq_entry_val_next[0:`LDSTQ_ENTRIES];		
   reg  [0:`THREADS-1]               addrq_entry_tid_next[0:`LDSTQ_ENTRIES];		
   reg  [0:`ITAG_SIZE_ENC-1] 	     addrq_entry_itag_next[0:`LDSTQ_ENTRIES];		
   reg  [64-`REAL_IFAR_WIDTH:59]     addrq_entry_address_next[0:`LDSTQ_ENTRIES];	
   reg  [0:15]                       addrq_entry_bytemask_next[0:`LDSTQ_ENTRIES];	
   
   wire [0:`LDSTQ_ENTRIES-1] 	     collision_vector_pre;
   wire [0:`LDSTQ_ENTRIES-1] 	     collision_vector;
   wire [0:`LDSTQ_ENTRIES-1] 	     collision_vector_d;
   wire [0:`LDSTQ_ENTRIES-1] 	     collision_vector_q;

   reg  [0:`LDSTQ_ENTRIES-1] 	     flush_vector_pre;
   wire [0:`LDSTQ_ENTRIES-1] 	     flush_vector;

   wire [0:`LDSTQ_ENTRIES-1] 	     collision_vector_new;
   
   wire [0:`LDSTQ_ENTRIES-1] 	     ci_flush_detected;
   wire [0:`LDSTQ_ENTRIES-1] 	     forw_flush_detected;
   wire [0:`LDSTQ_ENTRIES-1] 	     store_flush_detected;
   wire [0:`LDSTQ_ENTRIES-1] 	     set_flush_condition;
   
   wire [0:2]                        next_fill_sel;
   
   wire                              instr0_vld;
   wire                              instr1_vld;
   
   wire [0:`LDSTQ_ENTRIES-1] 	     next_instr0_ptr;
   wire [0:`LDSTQ_ENTRIES-1] 	     next_instr1_ptr;
   wire [0:`LDSTQ_ENTRIES-1] 	     write_instr0;
   wire [0:`LDSTQ_ENTRIES-1] 	     write_instr1;
   wire [0:`LDSTQ_ENTRIES-1] 	     update_vld;
   wire [0:`LDSTQ_ENTRIES-1] 	     update2_vld;
   wire [0:`LDSTQ_ENTRIES-1] 	     cp_flush_entry;
   
   wire [0:`LDSTQ_ENTRIES-1] 	     update_addrq_vld;
   
   reg  [0:`LDSTQ_ENTRIES-1] 	     store_collisions_ahead;
   reg  [0:`LDSTQ_ENTRIES-1] 	     load_collisions_ahead;
   reg  [0:`LDSTQ_ENTRIES-1] 	     forw_collisions_ahead;
   
   wire [0:`LDSTQ_ENTRIES-1] 	     queue_entry_is_store;
   wire [0:`LDSTQ_ENTRIES-1] 	     queue_entry_is_load;
   wire [0:`LDSTQ_ENTRIES-1] 	     oo_collision_detected;
   reg  [0:`LDSTQ_ENTRIES-1] 	     collision_check_mask;
   
   wire [0:`LDSTQ_ENTRIES-1] 	     sent_early_flush;
   
   wire [0:`THREADS-1]               inc0_flush_count;
   wire [0:`THREADS-1]               inc1_flush_count;
   wire [0:2]                        flushed_credit_sel[0:`THREADS-1];
   wire [0:`THREADS-1]               flush_credit_avail;
   wire [0:`THREADS-1]               flush_credit_free;
   wire [0:`THREADS-1]               flush_credit_token;
   
   wire                              compressed_store_collision;
   wire [0:`LDSTQ_ENTRIES-1] 	     temp_collision_flush;
     
   wire                              cl64;
   
   reg  [0:`THREADS-1]               oldest_unrsv_ld_tid;
   reg  [0:`ITAG_SIZE_ENC-1] 	     oldest_unrsv_ld_itag;
   wire [0:`LDSTQ_ENTRIES-1] 	     unresolved_load;
   
   wire                              cacheline_size_check[0:`LDSTQ_ENTRIES-1];
         
   wire [0:`ITAG_SIZE_ENC-1] 	     oldest_rem_itag;
   wire                              oldest_rem_n_flush_value;
   wire                              oldest_rem_np1_flush_value;
   wire                              oldest_rem_report_needed;
   
   wire                              oldest_rem_hit;
   wire                              oldest_rem_is_nonflush_ld;
   wire                              oldest_rem_instq;
   wire [0:`STQ_ENTRIES-1]           oldest_rem_stTag;
   wire [0:DACR_WIDTH-1]             oldest_rem_dacrw;
   wire                              oldest_rem_eccue;
   wire [0:3]                        oldest_rem_pEvents;
   wire [0:`THREADS-1]               oldest_rem_tid;
   
   wire [0:`LDSTQ_ENTRIES-1] 	     binv_flush_detected;
   
   wire                              rv1_binv_val_d;
   wire                              rv1_binv_val_q;
   wire                              ex0_binv_val_d;
   wire                              ex0_binv_val_q;
   wire                              ex1_binv_val_d;
   wire                              ex1_binv_val_q;
   wire                              ex2_binv_val_d;
   wire                              ex2_binv_val_q;
   wire                              ex3_binv_val_d;
   wire                              ex3_binv_val_q;
   wire                              ex4_binv_val_d;
   wire                              ex4_binv_val_q;
   wire                              ex5_binv_val_d;
   wire                              ex5_binv_val_q;

   wire [67-`DC_SIZE:63-`CL_SIZE]    rv1_binv_addr_d;
   wire [67-`DC_SIZE:63-`CL_SIZE]    rv1_binv_addr_q;
   wire [67-`DC_SIZE:63-`CL_SIZE]    ex0_binv_addr_d;
   wire [67-`DC_SIZE:63-`CL_SIZE]    ex0_binv_addr_q;
   wire [67-`DC_SIZE:63-`CL_SIZE]    ex1_binv_addr_d;
   wire [67-`DC_SIZE:63-`CL_SIZE]    ex1_binv_addr_q;
   wire [67-`DC_SIZE:63-`CL_SIZE]    ex2_binv_addr_d;
   wire [67-`DC_SIZE:63-`CL_SIZE]    ex2_binv_addr_q;
   wire [67-`DC_SIZE:63-`CL_SIZE]    ex3_binv_addr_d;
   wire [67-`DC_SIZE:63-`CL_SIZE]    ex3_binv_addr_q;
   wire [67-`DC_SIZE:63-`CL_SIZE]    ex4_binv_addr_d;
   wire [67-`DC_SIZE:63-`CL_SIZE]    ex4_binv_addr_q;
   wire [67-`DC_SIZE:63-`CL_SIZE]    ex5_binv_addr_d;
   wire [67-`DC_SIZE:63-`CL_SIZE]    ex5_binv_addr_q;

   wire [0:`LDSTQ_ENTRIES-1] 	     ex2_age_upper_ptr;
   wire [0:`LDSTQ_ENTRIES-1] 	     ex2_age_entry_younger;
   wire [0:`LDSTQ_ENTRIES-1] 	     ex2_age_entry_older;
   wire [0:`LDSTQ_ENTRIES-1] 	     ex2_age_younger_ptr;
   wire [0:`LDSTQ_ENTRIES-1] 	     ex2_age_older_ptr;
   wire [0:`LDSTQ_ENTRIES-1] 	     ex2_age_younger_st;
   wire [0:`LDSTQ_ENTRIES-1] 	     ex2_age_older_st;
   wire [0:`LDSTQ_ENTRIES-1] 	     ex2_nxt_youngest_ptr;
   wire [0:`LDSTQ_ENTRIES-1] 	     ex2_nxt_oldest_ptr;
   reg  [0:`STQ_ENTRIES-1]           ex2_nxt_youngest_stTag;
   reg  [0:`STQ_ENTRIES-1]           ex2_nxt_oldest_stTag;

   wire                              ex0_i0_src_xer;
   wire                              ex0_i1_src_xer;
   wire                              ex1_i0_instq_d;
   wire                              ex1_i0_instq_q;
   wire                              ex1_i1_instq_d;
   wire                              ex1_i1_instq_q;

   wire                              ldq_odq_pfetch_vld_ex6_d;
   wire                              ldq_odq_pfetch_vld_ex6_q;
   wire                              odq_ldq_ex7_pfetch_blk_d;
   wire                              odq_ldq_ex7_pfetch_blk_q;



   wire [0:`ITAG_SIZE_ENC-1]         iu_lq_cp_next_itag_int[0:`THREADS-1];
   wire [0:`ITAG_SIZE_ENC-1]         iu_lq_i0_completed_itag_int[0:`THREADS-1];
   wire [0:`ITAG_SIZE_ENC-1]         iu_lq_i1_completed_itag_int[0:`THREADS-1];
     
   parameter                         orderq_entry_inuse_offset          = 0;
   parameter                         orderq_entry_tid_offset            = orderq_entry_inuse_offset          + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_val_offset            = orderq_entry_tid_offset            + (`LDSTQ_ENTRIES * `THREADS);
   parameter                         orderq_entry_ld_offset             = orderq_entry_val_offset            + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_i_offset              = orderq_entry_ld_offset             + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_hit_offset            = orderq_entry_i_offset              + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_fwd_offset            = orderq_entry_hit_offset            + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_cls_op_offset         = orderq_entry_fwd_offset            + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_dacrw_offset          = orderq_entry_cls_op_offset         + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_eccue_offset          = orderq_entry_dacrw_offset          + (`LDSTQ_ENTRIES * DACR_WIDTH);
   parameter                         orderq_entry_pEvents_offset        = orderq_entry_eccue_offset          + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_pre_offset            = orderq_entry_pEvents_offset        + (`LDSTQ_ENTRIES * 4);
   parameter                         orderq_entry_instq_offset          = orderq_entry_pre_offset            + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_flushed_offset        = orderq_entry_instq_offset          + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_myflush_offset        = orderq_entry_flushed_offset        + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_itag_offset           = orderq_entry_myflush_offset        + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_ld_chk_offset         = orderq_entry_itag_offset           + (`LDSTQ_ENTRIES * `ITAG_SIZE_ENC);
   parameter                         orderq_entry_stTag_offset          = orderq_entry_ld_chk_offset         + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_cmmt_offset           = orderq_entry_stTag_offset          + (`LDSTQ_ENTRIES * `STQ_ENTRIES_ENC);
   parameter                         orderq_entry_bi_flag_offset        = orderq_entry_cmmt_offset           + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_bi_flush_offset       = orderq_entry_bi_flag_offset        + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_val2_offset           = orderq_entry_bi_flush_offset       + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_n_flush_offset        = orderq_entry_val2_offset           + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_np1_flush_offset      = orderq_entry_n_flush_offset        + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_update_pulse_offset   = orderq_entry_np1_flush_offset      + `LDSTQ_ENTRIES;
   parameter                         orderq_entry_efs_offset            = orderq_entry_update_pulse_offset   + `LDSTQ_ENTRIES;
   parameter                         addrq_entry_inuse_offset           = orderq_entry_efs_offset            + `LDSTQ_ENTRIES;
   parameter                         addrq_entry_val_offset             = addrq_entry_inuse_offset           + `LDSTQ_ENTRIES;
   parameter                         addrq_entry_tid_offset             = addrq_entry_val_offset             + `LDSTQ_ENTRIES;
   parameter                         addrq_entry_itag_offset            = addrq_entry_tid_offset             + (`LDSTQ_ENTRIES * `THREADS);
   parameter                         addrq_entry_address_offset         = addrq_entry_itag_offset            + (`LDSTQ_ENTRIES * `ITAG_SIZE_ENC);
   parameter                         addrq_entry_bytemask_offset        = addrq_entry_address_offset         + (`LDSTQ_ENTRIES * (`REAL_IFAR_WIDTH - 4));
   parameter                         ex0_i0_vld_offset                  = addrq_entry_bytemask_offset        + `LDSTQ_ENTRIES * 16;
   parameter                         ex0_i0_rte_lq_offset               = ex0_i0_vld_offset                  + `THREADS;
   parameter                         ex0_i0_rte_sq_offset               = ex0_i0_rte_lq_offset               + 1;
   parameter                         ex0_i0_isLoad_offset               = ex0_i0_rte_sq_offset               + 1;
   parameter                         ex0_i0_ucode_preissue_offset       = ex0_i0_isLoad_offset               + 1;
   parameter                         ex0_i0_s3_t_offset                 = ex0_i0_ucode_preissue_offset       + 1;
   parameter                         ex0_i0_isStore_offset              = ex0_i0_s3_t_offset                 + 3;
   parameter                         ex0_i0_itag_offset                 = ex0_i0_isStore_offset              + 1;
   parameter                         ex1_i0_vld_offset                  = ex0_i0_itag_offset                 + `ITAG_SIZE_ENC;
   parameter                         ex1_i0_isLoad_offset               = ex1_i0_vld_offset                  + `THREADS;
   parameter                         ex1_i0_pre_offset                  = ex1_i0_isLoad_offset               + 1;
   parameter                         ex1_i0_instq_offset                = ex1_i0_pre_offset                  + 1;
   parameter                         ex1_i0_itag_offset                 = ex1_i0_instq_offset                + 1;
   parameter                         ex0_i1_vld_offset                  = ex1_i0_itag_offset                 + `ITAG_SIZE_ENC;
   parameter                         ex0_i1_rte_lq_offset               = ex0_i1_vld_offset                  + `THREADS;
   parameter                         ex0_i1_rte_sq_offset               = ex0_i1_rte_lq_offset               + 1;
   parameter                         ex0_i1_isLoad_offset               = ex0_i1_rte_sq_offset               + 1;
   parameter                         ex0_i1_ucode_preissue_offset       = ex0_i1_isLoad_offset               + 1;
   parameter                         ex0_i1_s3_t_offset                 = ex0_i1_ucode_preissue_offset       + 1;
   parameter                         ex0_i1_isStore_offset              = ex0_i1_s3_t_offset                 + 3;
   parameter                         ex0_i1_itag_offset                 = ex0_i1_isStore_offset              + 1;
   parameter                         ex1_i1_vld_offset                  = ex0_i1_itag_offset                 + `ITAG_SIZE_ENC;
   parameter                         ex1_i1_isLoad_offset               = ex1_i1_vld_offset                  + `THREADS;
   parameter                         ex1_i1_pre_offset                  = ex1_i1_isLoad_offset               + 1;
   parameter                         ex1_i1_instq_offset                = ex1_i1_pre_offset                  + 1;
   parameter                         ex1_i1_itag_offset                 = ex1_i1_instq_offset                + 1;
   parameter                         ldq_odq_vld_offset                 = ex1_i1_itag_offset                 + `ITAG_SIZE_ENC;
   parameter                         ldq_odq_tid_offset                 = ldq_odq_vld_offset                 + 1;
   parameter                         ldq_odq_inv_offset                 = ldq_odq_tid_offset                 + `THREADS;
   parameter                         ldq_odq_wimge_i_offset             = ldq_odq_inv_offset                 + 1;
   parameter                         ldq_odq_hit_offset                 = ldq_odq_wimge_i_offset             + 1;
   parameter                         ldq_odq_fwd_offset                 = ldq_odq_hit_offset                 + 1;
   parameter                         ldq_odq_itag_offset                = ldq_odq_fwd_offset                 + 1;
   parameter                         iu_lq_cp_next_itag_offset          = ldq_odq_itag_offset                + `ITAG_SIZE_ENC;
   parameter                         cp_i0_completed_offset             = iu_lq_cp_next_itag_offset          + (`ITAG_SIZE_ENC * `THREADS);
   parameter                         cp_i0_completed_itag_offset        = cp_i0_completed_offset             + `THREADS;
   parameter                         cp_i1_completed_offset             = cp_i0_completed_itag_offset        + (`THREADS * `ITAG_SIZE_ENC);
   parameter                         cp_i1_completed_itag_offset        = cp_i1_completed_offset             + `THREADS;
   parameter                         ldq_odq_cline_chk_offset           = cp_i1_completed_itag_offset        + (`THREADS * `ITAG_SIZE_ENC);
   parameter                         next_fill_ptr_offset               = ldq_odq_cline_chk_offset           + 1;
   parameter                         collision_vector_offset            = next_fill_ptr_offset               + (`LDSTQ_ENTRIES + 1);
   parameter                         flushed_credit_count_offset        = collision_vector_offset            + `LDSTQ_ENTRIES;
   parameter                         cp_flush_offset                    = flushed_credit_count_offset        + (`LDSTQ_ENTRIES_ENC * `THREADS);
   parameter                         cp_flush2_offset                   = cp_flush_offset                    + `THREADS;
   parameter                         cp_flush3_offset                   = cp_flush2_offset                   + `THREADS;
   parameter                         cp_flush4_offset                   = cp_flush3_offset                   + `THREADS;
   parameter                         cp_flush5_offset                   = cp_flush4_offset                   + `THREADS;
   parameter                         xu_lq_spr_xucr0_cls_offset         = cp_flush5_offset                   + `THREADS;
   parameter                         lq_iu_credit_free_offset           = xu_lq_spr_xucr0_cls_offset         + 1;
   parameter                         compress_val_offset                = lq_iu_credit_free_offset           + `THREADS;
   parameter                         rv1_binv_val_offset                = compress_val_offset                + 1;
   parameter                         ex0_binv_val_offset                = rv1_binv_val_offset                + 1;
   parameter                         ex1_binv_val_offset                = ex0_binv_val_offset                + 1;
   parameter                         ex2_binv_val_offset                = ex1_binv_val_offset                + 1;
   parameter                         ex3_binv_val_offset                = ex2_binv_val_offset                + 1;
   parameter                         ex4_binv_val_offset                = ex3_binv_val_offset                + 1;
   parameter                         ex5_binv_val_offset                = ex4_binv_val_offset                + 1;
   parameter                         rv1_binv_addr_offset               = ex5_binv_val_offset                + 1;
   parameter                         ex0_binv_addr_offset               = rv1_binv_addr_offset               + (`DC_SIZE - `CL_SIZE - 3);
   parameter                         ex1_binv_addr_offset               = ex0_binv_addr_offset               + (`DC_SIZE - `CL_SIZE - 3);
   parameter                         ex2_binv_addr_offset               = ex1_binv_addr_offset               + (`DC_SIZE - `CL_SIZE - 3);
   parameter                         ex3_binv_addr_offset               = ex2_binv_addr_offset               + (`DC_SIZE - `CL_SIZE - 3);
   parameter                         ex4_binv_addr_offset               = ex3_binv_addr_offset               + (`DC_SIZE - `CL_SIZE - 3);
   parameter                         ex5_binv_addr_offset               = ex4_binv_addr_offset               + (`DC_SIZE - `CL_SIZE - 3);
   parameter                         entry_rv1_blk_offset               = ex5_binv_addr_offset               + (`DC_SIZE - `CL_SIZE - 3);
   parameter                         entry_ex0_blk_offset               = entry_rv1_blk_offset               + 1;
   parameter                         entry_ex1_blk_offset               = entry_ex0_blk_offset               + 1;
   parameter                         entry_ex2_blk_offset               = entry_ex1_blk_offset               + 1;
   parameter                         entry_ex3_blk_offset               = entry_ex2_blk_offset               + 1;
   parameter                         entry_ex4_blk_offset               = entry_ex3_blk_offset               + 1;
   parameter                         entry_ex5_blk_offset               = entry_ex4_blk_offset               + 1;
   parameter                         entry_ex6_blk_offset               = entry_ex5_blk_offset               + 1;
   parameter                         ldq_odq_pfetch_vld_ex6_offset      = entry_ex6_blk_offset               + 1;
   parameter                         odq_ldq_ex7_pfetch_blk_offset      = ldq_odq_pfetch_vld_ex6_offset      + 1;
   parameter                         scan_right                         = odq_ldq_ex7_pfetch_blk_offset      + 1 - 1;
   
   wire                              tiup;
   wire                              tidn;
   wire [0:scan_right]               siv;
   wire [0:scan_right]               sov;


   assign tiup = 1'b1;
   assign tidn = 1'b0;

   generate
      begin : ports
         genvar tid;
         for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
           begin : convert
             assign iu_lq_cp_next_itag_int[tid]      = iu_lq_cp_next_itag[`ITAG_SIZE_ENC*tid:(`ITAG_SIZE_ENC*(tid+1))-1];
             assign iu_lq_i0_completed_itag_int[tid] = iu_lq_i0_completed_itag[`ITAG_SIZE_ENC*tid:(`ITAG_SIZE_ENC*(tid+1))-1];
             assign iu_lq_i1_completed_itag_int[tid] = iu_lq_i1_completed_itag[`ITAG_SIZE_ENC*tid:(`ITAG_SIZE_ENC*(tid+1))-1];
           end
      end
   endgenerate

      
   assign compressed_store_collision = 1'b0;
   assign lsq_perv_odq_events = {4+`THREADS{1'b0}};
   
   
   assign rv1_binv_val_d = l2_back_inv_val;
   assign ex0_binv_val_d = rv1_binv_val_q;
   assign ex1_binv_val_d = ex0_binv_val_q;
   assign ex2_binv_val_d = ex1_binv_val_q;
   assign ex3_binv_val_d = ex2_binv_val_q;
   assign ex4_binv_val_d = ex3_binv_val_q;
   assign ex5_binv_val_d = ex4_binv_val_q;
         
   assign rv1_binv_addr_d = l2_back_inv_addr;
   assign ex0_binv_addr_d = rv1_binv_addr_q;
   assign ex1_binv_addr_d = ex0_binv_addr_q;
   assign ex2_binv_addr_d = ex1_binv_addr_q;
   assign ex3_binv_addr_d = ex2_binv_addr_q;
   assign ex4_binv_addr_d = ex3_binv_addr_q;
   assign ex5_binv_addr_d = ex4_binv_addr_q;
   
         
   assign cp_flush_d  = iu_lq_cp_flush;
   assign cp_flush2_d = cp_flush_q;
   assign cp_flush3_d = cp_flush2_q;
   assign cp_flush4_d = cp_flush3_q;
   assign cp_flush5_d = cp_flush4_q;
   
   assign ex0_i0_src_xer  = (ex0_i0_s3_t_q == 3'b100);
   assign ex1_i0_vld_d    = (ex0_i0_vld_q & {`THREADS{ex0_i0_rte_lq_q}});
   assign ex1_i0_pre_d    = ex0_i0_ucode_preissue_q | ((~ex0_i0_isLoad_q) & (~ex0_i0_isStore_q));
   assign ex1_i0_isLoad_d = ex0_i0_isLoad_q;
   assign ex1_i0_itag_d   = ex0_i0_itag_q;
   assign ex1_i0_instq_d  = ex0_i0_rte_sq_q & ((ex0_i0_ucode_preissue_q & ex0_i0_src_xer) | ((~ex0_i0_ucode_preissue_q)));
   
   assign ex0_i1_src_xer  = (ex0_i1_s3_t_q == 3'b100);
   assign ex1_i1_vld_d    = (ex0_i1_vld_q & {`THREADS{ex0_i1_rte_lq_q}});
   assign ex1_i1_pre_d    = ex0_i1_ucode_preissue_q | ((~ex0_i1_isLoad_q) & (~ex0_i1_isStore_q));
   assign ex1_i1_isLoad_d = ex0_i1_isLoad_q;
   assign ex1_i1_itag_d   = ex0_i1_itag_q;
   assign ex1_i1_instq_d  = ex0_i1_rte_sq_q & ((ex0_i1_ucode_preissue_q & ex0_i1_src_xer) | ((~ex0_i1_ucode_preissue_q)));
   
   assign instr0_vld = |(ex1_i0_vld_q & (~(cp_flush_q | cp_flush2_q | cp_flush3_q | cp_flush4_q | cp_flush5_q)));
   assign instr1_vld = |(ex1_i1_vld_q & (~(cp_flush_q | cp_flush2_q | cp_flush3_q | cp_flush4_q | cp_flush5_q)));

         
   generate
      begin : fcf
         genvar tid;
         for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
           begin : flushCredFree
              assign inc0_flush_count[tid] = ex1_i0_vld_q[tid] & (cp_flush_q[tid] | cp_flush2_q[tid] | cp_flush3_q[tid] | cp_flush4_q[tid] | cp_flush5_q[tid]);
              assign inc1_flush_count[tid] = ex1_i1_vld_q[tid] & (cp_flush_q[tid] | cp_flush2_q[tid] | cp_flush3_q[tid] | cp_flush4_q[tid] | cp_flush5_q[tid]);
              
              assign flushed_credit_sel[tid] = {inc0_flush_count[tid], inc1_flush_count[tid], flush_credit_free[tid]};
              assign flushed_credit_count_d[tid] = (flushed_credit_sel[tid] == 3'b110) ? flushed_credit_count_q[tid] + 4'd2 : 
                                                   (flushed_credit_sel[tid] == 3'b100) ? flushed_credit_count_q[tid] + 4'd1 : 
                                                   (flushed_credit_sel[tid] == 3'b010) ? flushed_credit_count_q[tid] + 4'd1 : 
                                                   (flushed_credit_sel[tid] == 3'b111) ? flushed_credit_count_q[tid] + 4'd1 : 
                                                   (flushed_credit_sel[tid] == 3'b001) ? flushed_credit_count_q[tid] - 4'd1 : 
                                                   flushed_credit_count_q[tid];
              assign flush_credit_avail[tid] = |(flushed_credit_count_q[tid]);
              assign flush_credit_free[tid] = ((~compress_val)) & flush_credit_avail[tid] & flush_credit_token[tid];
           end
      end
   endgenerate
            
   generate
      if (`THREADS == 1)
        begin : t1
           assign flush_credit_token[0] = (flushed_credit_count_q[0] != 4'b0000);
        end
   endgenerate
   generate
      if (`THREADS == 2)
        begin : t2
           assign flush_credit_token[0] = (flushed_credit_count_q[0] != 4'b0000);
           assign flush_credit_token[1] = (flushed_credit_count_q[1] != 4'b0000) & (~flush_credit_token[0]);
        end
   endgenerate
   
   
   
   
   
   assign next_fill_sel = {compress_val, instr0_vld, instr1_vld};
   
   assign next_fill_ptr_d = ((next_fill_sel) == 3'b010) ? ({1'b0, next_fill_ptr_q[0:`LDSTQ_ENTRIES - 1]}) : 		
                            ((next_fill_sel) == 3'b001) ? ({1'b0, next_fill_ptr_q[0:`LDSTQ_ENTRIES - 1]}) : 
                            ((next_fill_sel) == 3'b011) ? ({2'b00, next_fill_ptr_q[0:`LDSTQ_ENTRIES - 2]}) : 
                            ((next_fill_sel) == 3'b100) ? ({next_fill_ptr_q[1:`LDSTQ_ENTRIES], 1'b0}) : 
                            ((next_fill_sel) == 3'b111) ? ({1'b0, next_fill_ptr_q[0:`LDSTQ_ENTRIES - 1]}) : 
                            next_fill_ptr_q;
   assign next_instr0_ptr = next_fill_ptr_q[0:`LDSTQ_ENTRIES - 1];
   
   assign next_instr1_ptr = ((instr0_vld == 1'b1)) ? ({1'b0, next_fill_ptr_q[0:`LDSTQ_ENTRIES - 2]}) : 
                            next_fill_ptr_q[0:`LDSTQ_ENTRIES - 1];
            
    
   always @(*)
   begin : def
      orderq_entry_inuse_next[`LDSTQ_ENTRIES]        <= tidn;
      orderq_entry_tid_next[`LDSTQ_ENTRIES]          <= {`THREADS{tidn}};
      orderq_entry_val_next[`LDSTQ_ENTRIES]          <= tidn;
      orderq_entry_ld_next[`LDSTQ_ENTRIES]           <= tidn;
      orderq_entry_efs_next[`LDSTQ_ENTRIES]          <= tidn;
      orderq_entry_i_next[`LDSTQ_ENTRIES]            <= tidn;
      orderq_entry_hit_next[`LDSTQ_ENTRIES]          <= tidn;
      orderq_entry_fwd_next[`LDSTQ_ENTRIES]          <= tidn;
      orderq_entry_cls_op_next[`LDSTQ_ENTRIES]       <= tidn;
      orderq_entry_dacrw_next[`LDSTQ_ENTRIES]        <= {DACR_WIDTH{tidn}};
      orderq_entry_eccue_next[`LDSTQ_ENTRIES]        <= tidn;
      orderq_entry_pEvents_next[`LDSTQ_ENTRIES]      <= {4{tidn}};
      orderq_entry_pre_next[`LDSTQ_ENTRIES]          <= tidn;
      orderq_entry_instq_next[`LDSTQ_ENTRIES]        <= tidn;
      orderq_entry_flushed_next[`LDSTQ_ENTRIES]      <= tidn;
      orderq_entry_myflush_next[`LDSTQ_ENTRIES]      <= tidn;
      orderq_entry_ld_chk_next[`LDSTQ_ENTRIES]       <= tidn;
      orderq_entry_stTag_next[`LDSTQ_ENTRIES]        <= {`STQ_ENTRIES_ENC{tidn}};
      orderq_entry_cmmt_next[`LDSTQ_ENTRIES]         <= tidn;
      orderq_entry_bi_flag_next[`LDSTQ_ENTRIES]      <= tidn;
      orderq_entry_bi_flush_next[`LDSTQ_ENTRIES]     <= tidn;
      orderq_entry_val2_next[`LDSTQ_ENTRIES]         <= tidn;
      orderq_entry_n_flush_next[`LDSTQ_ENTRIES]      <= tidn;
      orderq_entry_np1_flush_next[`LDSTQ_ENTRIES]    <= tidn;
      orderq_entry_update_pulse_next[`LDSTQ_ENTRIES] <= tidn;
      orderq_entry_itag_next[`LDSTQ_ENTRIES]         <= {`ITAG_SIZE_ENC{tidn}};
   end


   
  
   generate
      begin : gen_a
         genvar                            entry;
         for (entry = 0; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
           begin : gen_a
              
              assign write_instr0[entry] = (next_instr0_ptr[entry] & instr0_vld);
              assign write_instr1[entry] = (next_instr1_ptr[entry] & instr1_vld);
              assign update_vld[entry] = ldq_odq_vld_q & |(ldq_odq_tid_q & orderq_entry_tid_q[entry]) & orderq_entry_inuse_q[entry] & ((~orderq_entry_val_q[entry])) & (orderq_entry_itag_q[entry] == ldq_odq_itag_q) & ((~orderq_entry_flushed_q[entry]));
              
              assign update2_vld[entry] = ldq_odq_upd_val & |(ldq_odq_upd_tid & orderq_entry_tid_q[entry]) & orderq_entry_inuse_q[entry] & ((~orderq_entry_val2_q[entry])) & (orderq_entry_itag_q[entry] == ldq_odq_upd_itag);
              
              assign cp_flush_entry[entry] = |(cp_flush_q & orderq_entry_tid_q[entry]);
              
              assign temp_collision_flush[entry] = 1'b0;		
              
              assign orderq_entry_instq_inval[entry] = orderq_entry_inuse_q[entry] & stq_odq_stq4_stTag_inval & (orderq_entry_stTag_q[entry] == stq_odq_stq4_stTag);
              
              
             always @(*)
                 begin: complete_itag_p
                   reg [0:`ITAG_SIZE_ENC-1]       i0_itag;
                   reg [0:`ITAG_SIZE_ENC-1] 	  i1_itag;
                   integer                        tid;
                   i0_itag = {`ITAG_SIZE_ENC{1'b0}};
                   i1_itag = {`ITAG_SIZE_ENC{1'b0}};
                   for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
                     begin
                        i0_itag = (cp_i0_completed_itag_q[tid] & {`ITAG_SIZE_ENC{orderq_entry_tid_q[entry][tid]}}) | i0_itag;
                        i1_itag = (cp_i1_completed_itag_q[tid] & {`ITAG_SIZE_ENC{orderq_entry_tid_q[entry][tid]}}) | i1_itag;
                     end
                   oderq_entry_i0_comp_itag[entry] <= i0_itag;
                   oderq_entry_i1_comp_itag[entry] <= i1_itag;
                end
              
              assign orderq_entry_i0_cmmt[entry] = |(cp_i0_completed_q & orderq_entry_tid_q[entry]) & (oderq_entry_i0_comp_itag[entry] == orderq_entry_itag_q[entry]);
              assign orderq_entry_i1_cmmt[entry] = |(cp_i1_completed_q & orderq_entry_tid_q[entry]) & (oderq_entry_i1_comp_itag[entry] == orderq_entry_itag_q[entry]);
              assign orderq_entry_cmmt[entry] = orderq_entry_inuse_q[entry] & (orderq_entry_i0_cmmt[entry] | orderq_entry_i1_cmmt[entry]);
              
              always @(*)
                begin: entry_update
                   
                   orderq_entry_inuse_next[entry]        <= orderq_entry_inuse_q[entry];
                   orderq_entry_tid_next[entry]          <= orderq_entry_tid_q[entry];
                   orderq_entry_val_next[entry]          <= orderq_entry_val_q[entry];
                   orderq_entry_ld_next[entry]           <= orderq_entry_ld_q[entry];
                   orderq_entry_efs_next[entry]          <= (sent_early_flush[entry] | orderq_entry_efs_q[entry]);
                   orderq_entry_i_next[entry]            <= orderq_entry_i_q[entry];
                   orderq_entry_hit_next[entry]          <= orderq_entry_hit_q[entry];
                   orderq_entry_fwd_next[entry]          <= orderq_entry_fwd_q[entry];
                   orderq_entry_cls_op_next[entry]       <= orderq_entry_cls_op_q[entry];
                   orderq_entry_dacrw_next[entry]        <= orderq_entry_dacrw_q[entry];
                   orderq_entry_eccue_next[entry]        <= orderq_entry_eccue_q[entry];
                   orderq_entry_pEvents_next[entry]      <= orderq_entry_pEvents_q[entry];
                   orderq_entry_pre_next[entry]          <= orderq_entry_pre_q[entry];
                   orderq_entry_instq_next[entry]        <= orderq_entry_instq_q[entry];
                   orderq_entry_flushed_next[entry]      <= orderq_entry_flushed_q[entry];
                   orderq_entry_myflush_next[entry]      <= orderq_entry_myflush_q[entry];
                   orderq_entry_ld_chk_next[entry]       <= ((set_flush_condition[entry] & (~ldq_odq_pfetch_vld_ex6_q)) | orderq_entry_ld_chk_q[entry]);
                   orderq_entry_stTag_next[entry]        <= orderq_entry_stTag_q[entry];
                   orderq_entry_cmmt_next[entry]         <= orderq_entry_cmmt_q[entry];
                   orderq_entry_bi_flag_next[entry]      <= orderq_entry_bi_flag_q[entry];
                   orderq_entry_bi_flush_next[entry]     <= orderq_entry_bi_flush_q[entry];
                   orderq_entry_val2_next[entry]         <= orderq_entry_val2_q[entry];
                   orderq_entry_n_flush_next[entry]      <= orderq_entry_n_flush_q[entry];
                   orderq_entry_np1_flush_next[entry]    <= orderq_entry_np1_flush_q[entry];
                   orderq_entry_update_pulse_next[entry] <= 1'b0;
                   orderq_entry_itag_next[entry]         <= orderq_entry_itag_q[entry];
                   
                   if (cp_flush_entry[entry] == 1'b1 & flush_vector[entry] == 1'b1 & orderq_entry_cmmt_q[entry] == 1'b0)                    
                     orderq_entry_flushed_next[entry] <= orderq_entry_inuse_q[entry];
                   else if (write_instr0[entry] == 1'b1 | write_instr1[entry] == 1'b1)
                     orderq_entry_flushed_next[entry] <= 1'b0;
                   
                   if (temp_collision_flush[entry] == 1'b1)
                     orderq_entry_myflush_next[entry] <= 1'b1;
                   else if (write_instr0[entry] == 1'b1 | write_instr1[entry] == 1'b1)
                     orderq_entry_myflush_next[entry] <= 1'b0;
                   
                   if (write_instr0[entry] == 1'b1)
                     begin
                        orderq_entry_inuse_next[entry]  <= 1'b1;
                        orderq_entry_tid_next[entry]    <= ex1_i0_vld_q;
                        orderq_entry_val_next[entry]    <= 1'b0;
                        orderq_entry_ld_next[entry]     <= ex1_i0_isLoad_q;
                        orderq_entry_pre_next[entry]    <= ex1_i0_pre_q;
                        orderq_entry_ld_chk_next[entry] <= 1'b0;
                        orderq_entry_stTag_next[entry]  <= stq_odq_i0_stTag;
                        orderq_entry_itag_next[entry]   <= ex1_i0_itag_q;
                     end
                   
                   if (write_instr0[entry] == 1'b1)
                     orderq_entry_instq_next[entry] <= ex1_i0_instq_q;
                   else if (orderq_entry_instq_inval[entry] == 1'b1)
                     orderq_entry_instq_next[entry] <= 1'b0;
                   
                   if (write_instr1[entry] == 1'b1)
                     begin
                        orderq_entry_inuse_next[entry]  <= 1'b1;
                        orderq_entry_tid_next[entry]    <= ex1_i1_vld_q;
                        orderq_entry_val_next[entry]    <= 1'b0;
                        orderq_entry_ld_next[entry]     <= ex1_i1_isLoad_q;
                       orderq_entry_pre_next[entry]     <= ex1_i1_pre_q;
                        orderq_entry_ld_chk_next[entry] <= 1'b0;
                        orderq_entry_stTag_next[entry]  <= stq_odq_i1_stTag;
                        orderq_entry_itag_next[entry]   <= ex1_i1_itag_q;
                     end
                   
                   if (write_instr1[entry] == 1'b1)
                     orderq_entry_instq_next[entry] <= ex1_i1_instq_q;
                   else if (orderq_entry_instq_inval[entry] == 1'b1)
                     orderq_entry_instq_next[entry] <= 1'b0;
                   
                   if (update_vld[entry] == 1'b1)
                     begin
                        orderq_entry_val_next[entry]    <= 1'b1;
                        orderq_entry_update_pulse_next[entry] <= 1'b1;
                        orderq_entry_i_next[entry]      <= ldq_odq_wimge_i_q;
                        orderq_entry_hit_next[entry]    <= ldq_odq_hit_q;
                        orderq_entry_fwd_next[entry]    <= ldq_odq_fwd_q;
                        orderq_entry_cls_op_next[entry] <= ldq_odq_cline_chk_q;
                         
                        if (binv_flush_detected[entry] == 1'b1)
                          orderq_entry_bi_flush_next[entry] <= 1'b1;
                     end
                   
                   if (update_vld[entry] == 1'b1) begin
                     orderq_entry_dacrw_next[entry]   <= ctl_lsq_ex6_ldh_dacrw;
                     orderq_entry_pEvents_next[entry] <= ldq_odq_ex6_pEvents;
                     orderq_entry_eccue_next[entry]   <= 1'b0;
                   end
                   
                   if (update2_vld[entry] == 1'b1) begin
                     orderq_entry_dacrw_next[entry]   <= ldq_odq_upd_dacrw | orderq_entry_dacrw_q[entry];
                     orderq_entry_pEvents_next[entry] <= ldq_odq_upd_pEvents | orderq_entry_pEvents_q[entry];
                     orderq_entry_eccue_next[entry]   <= ldq_odq_upd_eccue | orderq_entry_eccue_q[entry];
                   end
                   
                   if (ldq_odq_inv_q == 1'b1 & collision_vector_new[entry] == 1'b1 & orderq_entry_val_q[entry] == 1'b1 & orderq_entry_ld_q[entry] == 1'b1)
                     orderq_entry_bi_flag_next[entry] <= 1'b1;
                   
                   if ((binv_flush_detected[entry] == 1'b1) | (update2_vld[entry] == 1'b1 & ldq_odq_upd_nFlush == 1'b1))
                     orderq_entry_n_flush_next[entry] <= 1'b1;
                   
                   if ((update2_vld[entry] == 1'b1 & ldq_odq_upd_np1Flush == 1'b1))
                     orderq_entry_np1_flush_next[entry] <= 1'b1;
                   
                   if (update2_vld[entry] == 1'b1)
                     orderq_entry_val2_next[entry] <= 1'b1;
                   
                   if (orderq_entry_cmmt[entry] == 1'b1)
                     orderq_entry_cmmt_next[entry] <= 1'b1;
                   else if (write_instr0[entry] == 1'b1 | write_instr1[entry] == 1'b1)
                     orderq_entry_cmmt_next[entry] <= 1'b0;
                   
                   
                end
              
           end
      end
   endgenerate
   
   
   generate
      begin : ady
         genvar entry;
         for (entry = 0; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
           begin : ageDetectYoung
              assign ex2_age_upper_ptr[entry] = |(ctl_lsq_ex2_thrd_id & orderq_entry_tid_q[entry]) & (ctl_lsq_ex2_itag == orderq_entry_itag_q[entry]);
              
              assign ex2_age_entry_younger[entry] = |(ex2_age_younger_ptr[0:entry]);
              
              assign ex2_age_entry_older[entry] = |(ex2_age_older_ptr[entry:`LDSTQ_ENTRIES - 1]);
              
              assign ex2_age_younger_st[entry] = ex2_age_entry_younger[entry] & orderq_entry_inuse_q[entry] & orderq_entry_instq_q[entry] & (~orderq_entry_flushed_q[entry]);
              
              assign ex2_age_older_st[entry] = ex2_age_entry_older[entry] & orderq_entry_inuse_q[entry] & orderq_entry_instq_q[entry] & (~orderq_entry_flushed_q[entry]);
              
              if (entry == 0)
                begin : priYoungEntry0
                   assign ex2_nxt_youngest_ptr[entry] = ex2_age_younger_st[entry];
                end
              
              if (entry > 0)
                begin : priYoungerEntry
                   assign ex2_nxt_youngest_ptr[entry] = (~(|(ex2_age_younger_st[0:entry - 1]))) & ex2_age_younger_st[entry];
                end
              
              genvar bit;
              for (bit = 0; bit <= `STQ_ENTRIES - 1; bit = bit + 1)
                begin : stTag1Hot
                   wire [0:`STQ_ENTRIES_ENC-1] bitVect = bit;
                   assign orderq_entry_stTag_1hot[entry][bit] = (bitVect == orderq_entry_stTag_q[entry]);
                end
           end
      end
   endgenerate
         
   generate
      begin : ado
         genvar entry;
         for (entry = 0; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
           begin : ageDetectOld
              if (entry == `LDSTQ_ENTRIES - 1)
                begin : priOldEntryLast
                   assign ex2_nxt_oldest_ptr[entry] = ex2_age_older_st[entry];
                end
              
              if (entry < `LDSTQ_ENTRIES - 1)
		        begin : priOldEntry
                   assign ex2_nxt_oldest_ptr[entry] = (~(|(ex2_age_older_st[entry + 1:`LDSTQ_ENTRIES - 1]))) & ex2_age_older_st[entry];
		        end
           end
      end
   endgenerate
      
   assign ex2_age_younger_ptr = {1'b0, ex2_age_upper_ptr[0:`LDSTQ_ENTRIES - 2]};
   
   assign ex2_age_older_ptr = {ex2_age_upper_ptr[1:`LDSTQ_ENTRIES - 1], 1'b0};
   
   
   always @(*)
     begin: ageMux
        reg [0:`STQ_ENTRIES-1] yStTag;
        reg [0:`STQ_ENTRIES-1] oStTag;
        integer entry;
        yStTag = {`STQ_ENTRIES{1'b0}};
        oStTag = {`STQ_ENTRIES{1'b0}};
        for (entry = 0; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
          begin
             yStTag = (orderq_entry_stTag_1hot[entry] & {`STQ_ENTRIES{ex2_nxt_youngest_ptr[entry]}}) | yStTag;
             oStTag = (orderq_entry_stTag_1hot[entry] & {`STQ_ENTRIES{ex2_nxt_oldest_ptr[entry]}}) | oStTag;
          end
        ex2_nxt_youngest_stTag <= yStTag;
        ex2_nxt_oldest_stTag   <= oStTag;
     end
   
   assign odq_stq_ex2_nxt_oldest_val     = |(ex2_nxt_oldest_ptr);
   assign odq_stq_ex2_nxt_oldest_stTag   = ex2_nxt_oldest_stTag;
   assign odq_stq_ex2_nxt_youngest_val   = |(ex2_nxt_youngest_ptr);
   assign odq_stq_ex2_nxt_youngest_stTag = ex2_nxt_youngest_stTag;
   
   
   generate
      begin : flush_a
         genvar entry;
         for (entry = 0; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
           begin : flush_a
              assign store_flush_detected[entry] = store_collisions_ahead[entry] & orderq_entry_val_q[entry] & orderq_entry_ld_q[entry];
              assign binv_flush_detected[entry]  = load_collisions_ahead[entry] & orderq_entry_bi_flag_q[entry] & orderq_entry_ld_q[entry];
              assign ci_flush_detected[entry]    = load_collisions_ahead[entry] & orderq_entry_val_q[entry] & orderq_entry_ld_q[entry] & orderq_entry_i_q[entry];
              assign forw_flush_detected[entry]  = forw_collisions_ahead[entry] & orderq_entry_val_q[entry] & orderq_entry_ld_q[entry] & (~orderq_entry_hit_q[entry]);
              assign set_flush_condition[entry]  = store_flush_detected[entry] | forw_flush_detected[entry] | ci_flush_detected[entry];
           end
      end
   endgenerate
   
   
   
   
  always @(*)
     begin: cmp
        integer i;
        
        for (i = 0; i <= `LDSTQ_ENTRIES - 1; i = i + 1)
           
          flush_vector_pre[i] <= orderq_entry_inuse_q[i];
        
     end
   
   assign compress_val   = |(remove_entry_vec);
   assign compress_entry = remove_entry;
   
   assign lq_iu_credit_free_d = (remove_tid & {`THREADS{compress_val}}) | flush_credit_free;
   assign lq_iu_credit_free   = lq_iu_credit_free_q;
      
   generate
      begin : compVect
         genvar entry;
         for (entry = 0; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
           begin : compVect
              if (entry == 0)
                begin : en0
                   assign remove_entry_base[entry] = remove_entry_vec[entry];
                   assign compress_vector[entry]   = remove_entry_base[entry];
                end
              if (entry > 0)
                begin : en
                   assign remove_entry_base[entry] = remove_entry_vec[entry] & (~(|(remove_entry_vec[0:entry - 1])));
                   assign compress_vector[entry]   = |(remove_entry_base[0:entry]);
                end
           end
      end
   endgenerate
   
   assign flush_vector = flush_vector_pre;
      
   generate
      begin : cmp_loop
         genvar entry;
         for (entry = 0; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
           begin : cmp_loop
              
              
              
              always @(*)
                begin: cmp
                     
                   orderq_entry_inuse_d[entry]        <= orderq_entry_inuse_next[entry];
                   orderq_entry_tid_d[entry]          <= orderq_entry_tid_next[entry];
                   orderq_entry_val_d[entry]          <= orderq_entry_val_next[entry];
                   orderq_entry_ld_d[entry]           <= orderq_entry_ld_next[entry];
                   orderq_entry_efs_d[entry]          <= orderq_entry_efs_next[entry];
                   orderq_entry_i_d[entry]            <= orderq_entry_i_next[entry];
                   orderq_entry_hit_d[entry]          <= orderq_entry_hit_next[entry];
                   orderq_entry_fwd_d[entry]          <= orderq_entry_fwd_next[entry];
                   orderq_entry_cls_op_d[entry]       <= orderq_entry_cls_op_next[entry];
                   orderq_entry_dacrw_d[entry]        <= orderq_entry_dacrw_next[entry];
                   orderq_entry_eccue_d[entry]        <= orderq_entry_eccue_next[entry];
                   orderq_entry_pEvents_d[entry]      <= orderq_entry_pEvents_next[entry];
                   orderq_entry_pre_d[entry]          <= orderq_entry_pre_next[entry];
                   orderq_entry_instq_d[entry]        <= orderq_entry_instq_next[entry];
                   orderq_entry_flushed_d[entry]      <= orderq_entry_flushed_next[entry];
                   orderq_entry_myflush_d[entry]      <= orderq_entry_myflush_next[entry];
                   orderq_entry_ld_chk_d[entry]       <= orderq_entry_ld_chk_next[entry];
                   orderq_entry_stTag_d[entry]        <= orderq_entry_stTag_next[entry];
                   orderq_entry_cmmt_d[entry]         <= orderq_entry_cmmt_next[entry];
                   orderq_entry_bi_flag_d[entry]      <= orderq_entry_bi_flag_next[entry];
                   orderq_entry_bi_flush_d[entry]     <= orderq_entry_bi_flush_next[entry];
                   orderq_entry_val2_d[entry]         <= orderq_entry_val2_next[entry];
                   orderq_entry_n_flush_d[entry]      <= orderq_entry_n_flush_next[entry];
                   orderq_entry_np1_flush_d[entry]    <= orderq_entry_np1_flush_next[entry];
                   orderq_entry_update_pulse_d[entry] <= orderq_entry_update_pulse_next[entry];
                   orderq_entry_itag_d[entry]         <= orderq_entry_itag_next[entry];
                   
                   if (compress_vector[entry] == 1'b1 & compress_val == 1'b1)
                     begin
                        orderq_entry_inuse_d[entry]        <= orderq_entry_inuse_next[entry + 1];
                        orderq_entry_tid_d[entry]          <= orderq_entry_tid_next[entry + 1];
                        orderq_entry_val_d[entry]          <= orderq_entry_val_next[entry + 1];
                        orderq_entry_ld_d[entry]           <= orderq_entry_ld_next[entry + 1];
                        orderq_entry_efs_d[entry]          <= orderq_entry_efs_next[entry + 1];
                        orderq_entry_i_d[entry]            <= orderq_entry_i_next[entry + 1];
                        orderq_entry_hit_d[entry]          <= orderq_entry_hit_next[entry + 1];
                        orderq_entry_fwd_d[entry]          <= orderq_entry_fwd_next[entry + 1];
                        orderq_entry_cls_op_d[entry]       <= orderq_entry_cls_op_next[entry + 1];
                        orderq_entry_dacrw_d[entry]        <= orderq_entry_dacrw_next[entry + 1];
                        orderq_entry_eccue_d[entry]        <= orderq_entry_eccue_next[entry + 1];
                        orderq_entry_pEvents_d[entry]      <= orderq_entry_pEvents_next[entry + 1];
                        orderq_entry_pre_d[entry]          <= orderq_entry_pre_next[entry + 1];
                        orderq_entry_instq_d[entry]        <= orderq_entry_instq_next[entry + 1];
                        orderq_entry_flushed_d[entry]      <= orderq_entry_flushed_next[entry + 1];
                        orderq_entry_myflush_d[entry]      <= orderq_entry_myflush_next[entry + 1];
                        orderq_entry_ld_chk_d[entry]       <= orderq_entry_ld_chk_next[entry + 1];
                        orderq_entry_stTag_d[entry]        <= orderq_entry_stTag_next[entry + 1];
                        orderq_entry_cmmt_d[entry]         <= orderq_entry_cmmt_next[entry + 1];
                        orderq_entry_bi_flag_d[entry]      <= orderq_entry_bi_flag_next[entry + 1];
                        orderq_entry_bi_flush_d[entry]     <= orderq_entry_bi_flush_next[entry + 1];
                        orderq_entry_val2_d[entry]         <= orderq_entry_val2_next[entry + 1];
                        orderq_entry_n_flush_d[entry]      <= orderq_entry_n_flush_next[entry + 1];
                        orderq_entry_np1_flush_d[entry]    <= orderq_entry_np1_flush_next[entry + 1];
                        orderq_entry_update_pulse_d[entry] <= orderq_entry_update_pulse_next[entry + 1];
                        orderq_entry_itag_d[entry]         <= orderq_entry_itag_next[entry + 1];
                     end
                end
           end
      end
   endgenerate
   
      
   
   
   assign compress_val_d = compress_val;
   
            
   assign collision_vector_new = (compress_val_q == 1'b0) ? collision_vector_q : 
                                 {collision_vector_q[1:`LDSTQ_ENTRIES - 1], 1'b0};
   generate
      begin : gen_ops
         genvar entry;
         for (entry = 0; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
           begin : gen_ops
              assign queue_entry_is_store[entry] = ((orderq_entry_ld_q[entry] == 1'b0) & orderq_entry_pre_q[entry] == 1'b0);
              assign queue_entry_is_load[entry]  = (orderq_entry_ld_q[entry] == 1'b1);
           end
      end
   endgenerate
   
   generate
      begin : col_det_g
         genvar entry;
         for (entry = 0; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
           begin : col_det_g
              assign oo_collision_detected[entry] = collision_vector_new[entry] & collision_check_mask[entry];
           end
      end
   endgenerate
 
   always @(*)
     begin : def2
        collision_check_mask[0]   <= tidn;
        store_collisions_ahead[0] <= tidn;
        load_collisions_ahead[0]  <= tidn;
        forw_collisions_ahead[0]  <= tidn;
      end
  
   generate
      begin : col_det_f
         genvar entry;
         for (entry = 1; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
           begin : col_det_f
              
              always @(*)
                begin: col_chk
                   collision_check_mask[entry]   <= ((|(update_vld[0:entry - 1])) | ldq_odq_pfetch_vld_ex6_q);
                   store_collisions_ahead[entry] <= oo_collision_detected[entry] & |(update_vld[0:entry - 1] & queue_entry_is_store[0:entry - 1]);
                   load_collisions_ahead[entry]  <= oo_collision_detected[entry] & |(update_vld[0:entry - 1] & queue_entry_is_load[0:entry - 1]);
                   forw_collisions_ahead[entry]  <= oo_collision_detected[entry] & ldq_odq_vld_q & ldq_odq_fwd_q;
                end
           end
      end
   endgenerate


   assign ldq_odq_pfetch_vld_ex6_d = ldq_odq_pfetch_vld;

   assign odq_ldq_ex7_pfetch_blk_d = ((|(set_flush_condition[0:`LDSTQ_ENTRIES-1])) & ldq_odq_pfetch_vld_ex6_q);
   assign odq_ldq_ex7_pfetch_blk = odq_ldq_ex7_pfetch_blk_q;

      
   assign sent_early_flush = {`LDSTQ_ENTRIES{1'b0}};
   
   
   
   
   
   
   
   always @(*)
     begin : def3
       addrq_entry_inuse_next[`LDSTQ_ENTRIES]    <= tidn;
       addrq_entry_val_next[`LDSTQ_ENTRIES]      <= tidn;
       addrq_entry_tid_next[`LDSTQ_ENTRIES]      <= {`THREADS{tidn}};
       addrq_entry_itag_next[`LDSTQ_ENTRIES]     <= {`ITAG_SIZE_ENC{tidn}};
       addrq_entry_address_next[`LDSTQ_ENTRIES]  <= {`REAL_IFAR_WIDTH-4{tidn}};
       addrq_entry_bytemask_next[`LDSTQ_ENTRIES] <= {16{tidn}}; 
   end
    
   generate
      begin : gen_b
         genvar entry;
         for (entry = 0; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
           begin : gen_b
              
              assign update_addrq_vld[entry] = ldq_odq_vld & |(ldq_odq_tid & addrq_entry_tid_q[entry]) & addrq_entry_inuse_q[entry] & (~addrq_entry_val_q[entry]) & (addrq_entry_itag_q[entry] == ldq_odq_itag) & (~orderq_entry_flushed_q[entry]);
                                  
              always @(*)
                begin: entry_update
                   
                   addrq_entry_inuse_next[entry]    <= addrq_entry_inuse_q[entry];
                   addrq_entry_val_next[entry]      <= addrq_entry_val_q[entry];
                   addrq_entry_tid_next[entry]      <= addrq_entry_tid_q[entry];
                   addrq_entry_itag_next[entry]     <= addrq_entry_itag_q[entry];
                   addrq_entry_address_next[entry]  <= addrq_entry_address_q[entry];
                   addrq_entry_bytemask_next[entry] <= addrq_entry_bytemask_q[entry];
                   
                   if (write_instr0[entry] == 1'b1)
                     begin
                        addrq_entry_inuse_next[entry] <= 1'b1;
                        addrq_entry_val_next[entry]   <= 1'b0;
                        addrq_entry_tid_next[entry]   <= ex1_i0_vld_q;
                        addrq_entry_itag_next[entry]  <= ex1_i0_itag_q;
                     end
                   
                   if (write_instr1[entry] == 1'b1)
                     begin
                        addrq_entry_inuse_next[entry] <= 1'b1;
                        addrq_entry_val_next[entry]   <= 1'b0;
                        addrq_entry_tid_next[entry]   <= ex1_i1_vld_q;
                        addrq_entry_itag_next[entry]  <= ex1_i1_itag_q;
                     end
                   
                   if (update_addrq_vld[entry] == 1'b1)
                     begin
                        addrq_entry_val_next[entry]      <= 1'b1;
                        addrq_entry_address_next[entry]  <= ldq_odq_addr;
                        addrq_entry_bytemask_next[entry] <= ldq_odq_bytemask;
                     end
                   
                   
                   
                end
           end
      end
   endgenerate
   
   generate
      begin : cmp2_loop
         genvar  entry;
         for (entry = 0; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
           begin : cmp2_loop
              
              
              
              always @(*)
                begin: cmp
                   
                   addrq_entry_inuse_d[entry]    <= addrq_entry_inuse_next[entry];
                   addrq_entry_val_d[entry]      <= addrq_entry_val_next[entry];
                   addrq_entry_tid_d[entry]      <= addrq_entry_tid_next[entry];
                   addrq_entry_itag_d[entry]     <= addrq_entry_itag_next[entry];
                   addrq_entry_address_d[entry]  <= addrq_entry_address_next[entry];
                   addrq_entry_bytemask_d[entry] <= addrq_entry_bytemask_next[entry];
                   
                   if (compress_vector[entry] == 1'b1 & compress_val == 1'b1)
                     begin
                        addrq_entry_inuse_d[entry]    <= addrq_entry_inuse_next[entry + 1];
                        addrq_entry_val_d[entry]      <= addrq_entry_val_next[entry + 1];
                        addrq_entry_tid_d[entry]      <= addrq_entry_tid_next[entry + 1];
                        addrq_entry_itag_d[entry]     <= addrq_entry_itag_next[entry + 1];
                        addrq_entry_address_d[entry]  <= addrq_entry_address_next[entry + 1];
                        addrq_entry_bytemask_d[entry] <= addrq_entry_bytemask_next[entry + 1];		
                     end
                   
                end
              
              
              assign cacheline_size_check[entry] = orderq_entry_cls_op_q[entry] | ldq_odq_cline_chk;
              
              assign collision_vector_pre[entry] = ((addrq_entry_val_q[entry] == 1'b1) & 
                                                    ((addrq_entry_address_q[entry][64 - `REAL_IFAR_WIDTH:57] == ldq_odq_addr[64 - `REAL_IFAR_WIDTH:57]) & 
                                                    ((cl64 == 1'b0 & cacheline_size_check[entry] == 1'b1) | ((cl64 == 1'b1 | cacheline_size_check[entry] == 1'b0) & (addrq_entry_address_q[entry][58] == ldq_odq_addr[58]))) & 
                                                    ((cacheline_size_check[entry] == 1'b1) | ((cacheline_size_check[entry] == 1'b0) & (addrq_entry_address_q[entry][59] == ldq_odq_addr[59]))) & 
                                                    ((cacheline_size_check[entry] == 1'b1) | ((cacheline_size_check[entry] == 1'b0) & |(addrq_entry_bytemask_q[entry] & ldq_odq_bytemask)))));
              
              assign collision_vector[entry] = (collision_vector_pre[entry] & ((~orderq_entry_pre_q[entry])));
           end
      end
   endgenerate
                           
   assign collision_vector_d = collision_vector;
   
   assign cl64 = xu_lq_spr_xucr0_cls_q;
   
   
   
   
   
   
   
   assign odq_ldq_resolved       = remove_entry_vec[0] & oldest_rem_is_nonflush_ld;
   assign odq_ldq_report_itag    = oldest_rem_itag;
   assign odq_ldq_n_flush        = oldest_rem_n_flush_value;
   assign odq_ldq_np1_flush      = oldest_rem_np1_flush_value;
   assign odq_ldq_report_needed  = oldest_rem_report_needed | oldest_rem_hit;
   assign odq_ldq_report_dacrw   = oldest_rem_dacrw;
   assign odq_ldq_report_eccue   = oldest_rem_eccue;
   assign odq_ldq_report_tid     = oldest_rem_tid;
   assign odq_ldq_report_pEvents = oldest_rem_pEvents;
   assign odq_stq_resolved       = remove_entry_vec[0] & oldest_rem_instq;
   assign odq_stq_stTag          = oldest_rem_stTag;
   
   
   generate
      begin : urld_gen
         genvar entry;
         for (entry = 0; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
           begin : urld_gen
              assign unresolved_load[entry] = orderq_entry_inuse_q[entry] & ((~orderq_entry_val_q[entry])) & orderq_entry_ld_q[entry];
           end
      end
   endgenerate
   
   
   always @(*)
     begin: old_itag
        integer                           i;
        oldest_unrsv_ld_tid  <= {`THREADS{1'b0}};
        oldest_unrsv_ld_itag <= {`ITAG_SIZE_ENC{1'b0}};
        for (i = `LDSTQ_ENTRIES - 1; i >= 0; i = i - 1)
          if (unresolved_load[i] == 1'b1)
            begin
               oldest_unrsv_ld_tid  <= orderq_entry_tid_q[i];
               oldest_unrsv_ld_itag <= orderq_entry_itag_q[i];
            end
     end
   
   assign odq_ldq_oldest_ld_tid  = oldest_unrsv_ld_tid;
   assign odq_ldq_oldest_ld_itag = oldest_unrsv_ld_itag;
   
   
   assign oldest_entry_p0_cclass = {addrq_entry_address_q[0][64 - (`DC_SIZE - 3):56], (addrq_entry_address_q[0][57] | xu_lq_spr_xucr0_cls_q)};
   assign oldest_entry_p1_cclass = {addrq_entry_address_q[1][64 - (`DC_SIZE - 3):56], (addrq_entry_address_q[1][57] | xu_lq_spr_xucr0_cls_q)};
   assign oldest_entry_p0_m_rv0 = orderq_entry_inuse_q[0] & orderq_entry_val_q[0] & orderq_entry_ld_q[0] & l2_back_inv_val & (l2_back_inv_addr == oldest_entry_p0_cclass);
   assign oldest_entry_p1_m_rv0 = orderq_entry_inuse_q[1] & orderq_entry_val_q[1] & orderq_entry_ld_q[1] & l2_back_inv_val & (l2_back_inv_addr == oldest_entry_p1_cclass);
   assign oldest_entry_p1_m_rv1 = orderq_entry_inuse_q[1] & orderq_entry_val_q[1] & orderq_entry_ld_q[1] & rv1_binv_val_q & (rv1_binv_addr_q == oldest_entry_p1_cclass);
   assign oldest_entry_p1_m_ex0 = orderq_entry_inuse_q[1] & orderq_entry_val_q[1] & orderq_entry_ld_q[1] & ex0_binv_val_q & (ex0_binv_addr_q == oldest_entry_p1_cclass);
   assign oldest_entry_p1_m_ex1 = orderq_entry_inuse_q[1] & orderq_entry_val_q[1] & orderq_entry_ld_q[1] & ex1_binv_val_q & (ex1_binv_addr_q == oldest_entry_p1_cclass);
   assign oldest_entry_p1_m_ex2 = orderq_entry_inuse_q[1] & orderq_entry_val_q[1] & orderq_entry_ld_q[1] & ex2_binv_val_q & (ex2_binv_addr_q == oldest_entry_p1_cclass);
   assign oldest_entry_p1_m_ex3 = orderq_entry_inuse_q[1] & orderq_entry_val_q[1] & orderq_entry_ld_q[1] & ex3_binv_val_q & (ex3_binv_addr_q == oldest_entry_p1_cclass);
   assign oldest_entry_p1_m_ex4 = orderq_entry_inuse_q[1] & orderq_entry_val_q[1] & orderq_entry_ld_q[1] & ex4_binv_val_q & (ex4_binv_addr_q == oldest_entry_p1_cclass);
   assign oldest_entry_p1_m_ex5 = orderq_entry_inuse_q[1] & orderq_entry_val_q[1] & orderq_entry_ld_q[1] & ex5_binv_val_q & (ex5_binv_addr_q == oldest_entry_p1_cclass);
   assign entry_rv1_blk_d = oldest_entry_p0_m_rv0 | oldest_entry_p1_m_rv0;
   assign entry_ex0_blk_d = entry_rv1_blk_q | oldest_entry_p1_m_rv1;
   assign entry_ex1_blk_d = entry_ex0_blk_q | oldest_entry_p1_m_ex0;
   assign entry_ex2_blk_d = entry_ex1_blk_q | oldest_entry_p1_m_ex1;
   assign entry_ex3_blk_d = entry_ex2_blk_q | oldest_entry_p1_m_ex2;
   assign entry_ex4_blk_d = entry_ex3_blk_q | oldest_entry_p1_m_ex3;
   assign entry_ex5_blk_d = entry_ex4_blk_q | oldest_entry_p1_m_ex4;
   assign entry_ex6_blk_d = entry_ex5_blk_q | oldest_entry_p1_m_ex5;
   assign oldest_entry_blk = (orderq_entry_ld_q[0] & l2_back_inv_val) | entry_rv1_blk_q | entry_ex0_blk_q | entry_ex1_blk_q | entry_ex2_blk_q | entry_ex3_blk_q | entry_ex4_blk_q | entry_ex5_blk_q | entry_ex6_blk_q;
   
   assign remove_entry_vec[0] = orderq_entry_inuse_q[0] & ((orderq_entry_val_q[0] & (~oldest_entry_blk)) | orderq_entry_flushed_q[0]);
   
   generate
      begin : rld_gen
         genvar entry;
         for (entry = 1; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
           begin : rld_gen
              assign remove_entry_vec[entry] = (orderq_entry_inuse_q[entry] & orderq_entry_flushed_q[entry] & ((~ldq_odq_vld)));
           end
      end
   endgenerate
   
   
   always @(*)
     begin: rm_entry
        integer i;
        remove_entry <= {`LDSTQ_ENTRIES_ENC{1'b0}};
        remove_tid   <= {`THREADS{1'b0}};
        for (i = `LDSTQ_ENTRIES - 1; i >= 0; i = i - 1)
          if (remove_entry_vec[i] == 1'b1)
            begin
               remove_entry <= i;
               remove_tid   <= orderq_entry_tid_q[i];
            end
     end
   
    
   assign oldest_rem_itag            = orderq_entry_itag_q[0];
   assign oldest_rem_n_flush_value   = (orderq_entry_ld_chk_q[0] | orderq_entry_myflush_q[0] | orderq_entry_efs_q[0] | orderq_entry_bi_flush_q[0] | orderq_entry_n_flush_q[0]);
   assign oldest_rem_np1_flush_value = orderq_entry_np1_flush_q[0];
   assign oldest_rem_report_needed   = orderq_entry_val2_q[0];
   assign oldest_rem_hit             = orderq_entry_hit_q[0];
   assign oldest_rem_is_nonflush_ld  = (orderq_entry_ld_q[0] & ((~orderq_entry_flushed_q[0])));
   assign oldest_rem_dacrw           = orderq_entry_dacrw_q[0];
   assign oldest_rem_eccue           = orderq_entry_eccue_q[0];
   assign oldest_rem_pEvents         = orderq_entry_pEvents_q[0];
   assign oldest_rem_tid             = orderq_entry_tid_q[0];
   assign oldest_rem_instq           = orderq_entry_instq_q[0] & (~orderq_entry_flushed_q[0]);
   
   generate
      genvar bit;
      for (bit = 0; bit <= `STQ_ENTRIES - 1; bit = bit + 1)
        begin : stTag1Hot
           wire [0:`STQ_ENTRIES_ENC-1] bitVect = bit;
           assign oldest_rem_stTag[bit] = (bitVect == orderq_entry_stTag_q[0]);
        end
   endgenerate
   
   assign lsq_ctl_oldest_tid  = orderq_entry_tid_q[0];
   assign lsq_ctl_oldest_itag = orderq_entry_itag_q[0];
   
                                 
   generate
      genvar 			       entry;
      for (entry = 0; entry <= `LDSTQ_ENTRIES - 1; entry = entry + 1)
        begin : oqe
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_inuse_reg
		   (
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
		    .scin(siv[orderq_entry_inuse_offset + entry]),
		    .scout(sov[orderq_entry_inuse_offset + entry]),
		    .din(orderq_entry_inuse_d[entry]),
		    .dout(orderq_entry_inuse_q[entry])
		    );
           
           
           tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) orderq_entry_tid_reg
	     (
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
	      .scin(siv[orderq_entry_tid_offset + (`THREADS * entry):orderq_entry_tid_offset + (`THREADS * (entry + 1)) - 1]),
	      .scout(sov[orderq_entry_tid_offset + (`THREADS * entry):orderq_entry_tid_offset + (`THREADS * (entry + 1)) - 1]),
	      .din(orderq_entry_tid_d[entry]),
	      .dout(orderq_entry_tid_q[entry])
	      );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_val_reg
	     (
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
	      .scin(siv[orderq_entry_val_offset + entry]),
	      .scout(sov[orderq_entry_val_offset + entry]),
	      .din(orderq_entry_val_d[entry]),
	      .dout(orderq_entry_val_q[entry])
	      );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_ld_reg
	     (
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
	      .scin(siv[orderq_entry_ld_offset + entry]),
	      .scout(sov[orderq_entry_ld_offset + entry]),
	      .din(orderq_entry_ld_d[entry]),
	      .dout(orderq_entry_ld_q[entry])
	      );
              
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_i_reg
	     (
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
              .scin(siv[orderq_entry_i_offset + entry]),
              .scout(sov[orderq_entry_i_offset + entry]),
              .din(orderq_entry_i_d[entry]),
              .dout(orderq_entry_i_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_hit_reg
	     (
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
              .scin(siv[orderq_entry_hit_offset + entry]),
              .scout(sov[orderq_entry_hit_offset + entry]),
              .din(orderq_entry_hit_d[entry]),
              .dout(orderq_entry_hit_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_fwd_reg
	     (
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
              .scin(siv[orderq_entry_fwd_offset + entry]),
              .scout(sov[orderq_entry_fwd_offset + entry]),
              .din(orderq_entry_fwd_d[entry]),
              .dout(orderq_entry_fwd_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_cls_op_reg
	     (
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
              .scin(siv[orderq_entry_cls_op_offset + entry]),
              .scout(sov[orderq_entry_cls_op_offset + entry]),
              .din(orderq_entry_cls_op_d[entry]),
              .dout(orderq_entry_cls_op_q[entry])
              );
           
           
           tri_rlmreg_p #(.WIDTH(DACR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) orderq_entry_dacrw_reg
	     (
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
              .scin(siv[orderq_entry_dacrw_offset + (DACR_WIDTH * entry):orderq_entry_dacrw_offset + (DACR_WIDTH * (entry + 1)) - 1]),
              .scout(sov[orderq_entry_dacrw_offset + (DACR_WIDTH  * entry):orderq_entry_dacrw_offset + (DACR_WIDTH * (entry + 1)) - 1]),
              .din(orderq_entry_dacrw_d[entry]),
              .dout(orderq_entry_dacrw_q[entry])
              );
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_eccue_reg
	     (
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
              .scin(siv[orderq_entry_eccue_offset + entry]),
              .scout(sov[orderq_entry_eccue_offset + entry]),
              .din(orderq_entry_eccue_d[entry]),
              .dout(orderq_entry_eccue_q[entry])
              );
           
           tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) orderq_entry_pEvents_reg
	     (
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
              .scin(siv[orderq_entry_pEvents_offset + (4 * entry):orderq_entry_pEvents_offset + (4 * (entry + 1)) - 1]),
              .scout(sov[orderq_entry_pEvents_offset + (4  * entry):orderq_entry_pEvents_offset + (4 * (entry + 1)) - 1]),
              .din(orderq_entry_pEvents_d[entry]),
              .dout(orderq_entry_pEvents_q[entry])
              );          
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_pre_reg
	     (
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
              .scin(siv[orderq_entry_pre_offset + entry]),
              .scout(sov[orderq_entry_pre_offset + entry]),
              .din(orderq_entry_pre_d[entry]),
              .dout(orderq_entry_pre_q[entry])
              );
              
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_instq_reg
	     (
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
              .scin(siv[orderq_entry_instq_offset + entry]),
              .scout(sov[orderq_entry_instq_offset + entry]),
              .din(orderq_entry_instq_d[entry]),
              .dout(orderq_entry_instq_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_flushed_reg
	     (
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
              .scin(siv[orderq_entry_flushed_offset + entry]),
              .scout(sov[orderq_entry_flushed_offset + entry]),
              .din(orderq_entry_flushed_d[entry]),
              .dout(orderq_entry_flushed_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_myflush_reg
	     (
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
              .scin(siv[orderq_entry_myflush_offset + entry]),
              .scout(sov[orderq_entry_myflush_offset + entry]),
              .din(orderq_entry_myflush_d[entry]),
              .dout(orderq_entry_myflush_q[entry])
              );
           
           
           tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) orderq_entry_itag_reg
	     (
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
              .scin(siv[orderq_entry_itag_offset + (`ITAG_SIZE_ENC * entry):orderq_entry_itag_offset + (`ITAG_SIZE_ENC * (entry + 1)) - 1]),
              .scout(sov[orderq_entry_itag_offset + (`ITAG_SIZE_ENC * entry):orderq_entry_itag_offset + (`ITAG_SIZE_ENC * (entry + 1)) - 1]),
              .din(orderq_entry_itag_d[entry]),
              .dout(orderq_entry_itag_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_ld_chk_reg
	     (
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
              .scin(siv[orderq_entry_ld_chk_offset + entry]),
              .scout(sov[orderq_entry_ld_chk_offset + entry]),
              .din(orderq_entry_ld_chk_d[entry]),
              .dout(orderq_entry_ld_chk_q[entry])
              );
           
           
           tri_rlmreg_p #(.WIDTH(`STQ_ENTRIES_ENC), .INIT(0), .NEEDS_SRESET(1)) orderq_entry_stTag_reg
	     (
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
              .scin(siv[orderq_entry_stTag_offset + (`STQ_ENTRIES_ENC * entry):orderq_entry_stTag_offset + (`STQ_ENTRIES_ENC * (entry + 1)) - 1]),
              .scout(sov[orderq_entry_stTag_offset + (`STQ_ENTRIES_ENC * entry):orderq_entry_stTag_offset + (`STQ_ENTRIES_ENC * (entry + 1)) - 1]),
              .din(orderq_entry_stTag_d[entry]),
              .dout(orderq_entry_stTag_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_cmmt_reg
	     (
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
              .scin(siv[orderq_entry_cmmt_offset + entry]),
              .scout(sov[orderq_entry_cmmt_offset + entry]),
              .din(orderq_entry_cmmt_d[entry]),
              .dout(orderq_entry_cmmt_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_bi_flag_reg
	     (
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
              .scin(siv[orderq_entry_bi_flag_offset + entry]),
              .scout(sov[orderq_entry_bi_flag_offset + entry]),
              .din(orderq_entry_bi_flag_d[entry]),
              .dout(orderq_entry_bi_flag_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_bi_flush_reg
	     (
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
              .scin(siv[orderq_entry_bi_flush_offset + entry]),
              .scout(sov[orderq_entry_bi_flush_offset + entry]),
              .din(orderq_entry_bi_flush_d[entry]),
              .dout(orderq_entry_bi_flush_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_val2_reg
	     (
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
              .scin(siv[orderq_entry_val2_offset + entry]),
              .scout(sov[orderq_entry_val2_offset + entry]),
              .din(orderq_entry_val2_d[entry]),
              .dout(orderq_entry_val2_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_n_flush_reg
	     (
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
              .scin(siv[orderq_entry_n_flush_offset + entry]),
              .scout(sov[orderq_entry_n_flush_offset + entry]),
              .din(orderq_entry_n_flush_d[entry]),
              .dout(orderq_entry_n_flush_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_np1_flush_reg
	     (
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
              .scin(siv[orderq_entry_np1_flush_offset + entry]),
              .scout(sov[orderq_entry_np1_flush_offset + entry]),
              .din(orderq_entry_np1_flush_d[entry]),
              .dout(orderq_entry_np1_flush_q[entry])
              );
              
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_update_pulse_reg
	     (
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
              .scin(siv[orderq_entry_update_pulse_offset + entry]),
              .scout(sov[orderq_entry_update_pulse_offset + entry]),
              .din(orderq_entry_update_pulse_d[entry]),
              .dout(orderq_entry_update_pulse_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) orderq_entry_efs_reg
	     (
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
              .scin(siv[orderq_entry_efs_offset + entry]),
              .scout(sov[orderq_entry_efs_offset + entry]),
              .din(orderq_entry_efs_d[entry]),
              .dout(orderq_entry_efs_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) addrq_entry_inuse_reg
	     (
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
              .scin(siv[addrq_entry_inuse_offset + entry]),
              .scout(sov[addrq_entry_inuse_offset + entry]),
              .din(addrq_entry_inuse_d[entry]),
              .dout(addrq_entry_inuse_q[entry])
              );
           
           
           tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) addrq_entry_val_reg
	     (
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
              .scin(siv[addrq_entry_val_offset + entry]),
              .scout(sov[addrq_entry_val_offset + entry]),
              .din(addrq_entry_val_d[entry]),
              .dout(addrq_entry_val_q[entry])
              );
           
           
           tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) addrq_entry_tid_reg
	     (
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
              .scin(siv[addrq_entry_tid_offset + (`THREADS * entry):addrq_entry_tid_offset + (`THREADS * (entry + 1)) - 1]),
              .scout(sov[addrq_entry_tid_offset + (`THREADS * entry):addrq_entry_tid_offset + (`THREADS * (entry + 1)) - 1]),
              .din(addrq_entry_tid_d[entry]),
              .dout(addrq_entry_tid_q[entry])
              );
           
           
           tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) addrq_entry_itag_reg
	     (
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
              .scin(siv[addrq_entry_itag_offset + (`ITAG_SIZE_ENC * entry):addrq_entry_itag_offset + (`ITAG_SIZE_ENC * (entry + 1)) - 1]),
              .scout(sov[addrq_entry_itag_offset + (`ITAG_SIZE_ENC * entry):addrq_entry_itag_offset + (`ITAG_SIZE_ENC * (entry + 1)) - 1]),
              .din(addrq_entry_itag_d[entry]),
              .dout(addrq_entry_itag_q[entry])
              );
           
           
           tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH-4), .INIT(0), .NEEDS_SRESET(1)) addrq_entry_address_reg
	     (
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
              .scin(siv[addrq_entry_address_offset + ((`REAL_IFAR_WIDTH-4) * entry):addrq_entry_address_offset + ((`REAL_IFAR_WIDTH-4) * (entry + 1)) - 1]),
              .scout(sov[addrq_entry_address_offset + ((`REAL_IFAR_WIDTH-4) * entry):addrq_entry_address_offset + ((`REAL_IFAR_WIDTH-4) * (entry + 1)) - 1]),
              .din(addrq_entry_address_d[entry]),
              .dout(addrq_entry_address_q[entry])
              );
           
           
           tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) addrq_entry_bytemask_reg
	     (
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
              .scin(siv[addrq_entry_bytemask_offset + (16 * entry):addrq_entry_bytemask_offset + (16 * (entry + 1)) - 1]),
              .scout(sov[addrq_entry_bytemask_offset + (16 * entry):addrq_entry_bytemask_offset + (16 * (entry + 1)) - 1]),
              .din(addrq_entry_bytemask_d[entry]),
              .dout(addrq_entry_bytemask_q[entry])
              );
        end
   endgenerate
   

   
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex0_i0_vld_reg
     (
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
      .scin(siv[ex0_i0_vld_offset:ex0_i0_vld_offset + `THREADS - 1]),
      .scout(sov[ex0_i0_vld_offset:ex0_i0_vld_offset + `THREADS - 1]),
      .din(rv_lq_rv1_i0_vld),
      .dout(ex0_i0_vld_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i0_rte_lq_reg
     (
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
      .scin(siv[ex0_i0_rte_lq_offset]),
      .scout(sov[ex0_i0_rte_lq_offset]),
      .din(rv_lq_rv1_i0_rte_lq),
      .dout(ex0_i0_rte_lq_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i0_rte_sq_reg
     (
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
      .scin(siv[ex0_i0_rte_sq_offset]),
      .scout(sov[ex0_i0_rte_sq_offset]),
      .din(rv_lq_rv1_i0_rte_sq),
      .dout(ex0_i0_rte_sq_q)
      );
   
                                    
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i0_isLoad_reg
     (
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
      .scin(siv[ex0_i0_isLoad_offset]),
      .scout(sov[ex0_i0_isLoad_offset]),
      .din(rv_lq_rv1_i0_isLoad),
      .dout(ex0_i0_isLoad_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i0_ucode_preissue_reg
     (
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
      .scin(siv[ex0_i0_ucode_preissue_offset]),
      .scout(sov[ex0_i0_ucode_preissue_offset]),
      .din(rv_lq_rv1_i0_ucode_preissue),
      .dout(ex0_i0_ucode_preissue_q)
      );
                                    
                                    
   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex0_i0_s3_t_reg
     (
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
      .scin(siv[ex0_i0_s3_t_offset:ex0_i0_s3_t_offset + 3 - 1]),
      .scout(sov[ex0_i0_s3_t_offset:ex0_i0_s3_t_offset + 3 - 1]),
      .din(rv_lq_rv1_i0_s3_t),
      .dout(ex0_i0_s3_t_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i0_isStore_reg
     (
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
      .scin(siv[ex0_i0_isStore_offset]),
      .scout(sov[ex0_i0_isStore_offset]),
      .din(rv_lq_rv1_i0_isStore),
      .dout(ex0_i0_isStore_q)
      );
   
   
   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex0_i0_itag_reg
     (
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
      .scin(siv[ex0_i0_itag_offset:ex0_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[ex0_i0_itag_offset:ex0_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(rv_lq_rv1_i0_itag),
      .dout(ex0_i0_itag_q)
      );
   
   
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex1_i0_vld_reg
     (
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
      .scin(siv[ex1_i0_vld_offset:ex1_i0_vld_offset + `THREADS - 1]),
      .scout(sov[ex1_i0_vld_offset:ex1_i0_vld_offset + `THREADS - 1]),
      .din(ex1_i0_vld_d),
      .dout(ex1_i0_vld_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_i0_isLoad_reg
     (
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
      .scin(siv[ex1_i0_isLoad_offset]),
      .scout(sov[ex1_i0_isLoad_offset]),
      .din(ex1_i0_isLoad_d),
      .dout(ex1_i0_isLoad_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_i0_pre_reg
     (
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
      .scin(siv[ex1_i0_pre_offset]),
      .scout(sov[ex1_i0_pre_offset]),
      .din(ex1_i0_pre_d),
      .dout(ex1_i0_pre_q)
      );
                                    
                                    
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_i0_instq_reg
     (
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
      .scin(siv[ex1_i0_instq_offset]),
      .scout(sov[ex1_i0_instq_offset]),
      .din(ex1_i0_instq_d),
      .dout(ex1_i0_instq_q)
      );
   
   
   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex1_i0_itag_reg
     (
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
      .scin(siv[ex1_i0_itag_offset:ex1_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[ex1_i0_itag_offset:ex1_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ex1_i0_itag_d),
      .dout(ex1_i0_itag_q)
      );
                                    
   
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex0_i1_vld_reg
     (
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
      .scin(siv[ex0_i1_vld_offset:ex0_i1_vld_offset + `THREADS - 1]),
      .scout(sov[ex0_i1_vld_offset:ex0_i1_vld_offset + `THREADS - 1]),
      .din(rv_lq_rv1_i1_vld),
      .dout(ex0_i1_vld_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i1_rte_lq_reg
     (
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
      .scin(siv[ex0_i1_rte_lq_offset]),
      .scout(sov[ex0_i1_rte_lq_offset]),
      .din(rv_lq_rv1_i1_rte_lq),
      .dout(ex0_i1_rte_lq_q)
      );
                                    
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i1_rte_sq_reg
     (
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
      .scin(siv[ex0_i1_rte_sq_offset]),
      .scout(sov[ex0_i1_rte_sq_offset]),
      .din(rv_lq_rv1_i1_rte_sq),
      .dout(ex0_i1_rte_sq_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i1_isLoad_reg
     (
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
      .scin(siv[ex0_i1_isLoad_offset]),
      .scout(sov[ex0_i1_isLoad_offset]),
      .din(rv_lq_rv1_i1_isLoad),
      .dout(ex0_i1_isLoad_q)
      );
                                    
                                    
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i1_ucode_preissue_reg
     (
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
      .scin(siv[ex0_i1_ucode_preissue_offset]),
      .scout(sov[ex0_i1_ucode_preissue_offset]),
      .din(rv_lq_rv1_i1_ucode_preissue),
      .dout(ex0_i1_ucode_preissue_q)
      );
   
   
   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex0_i1_s3_t_reg
     (
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
      .scin(siv[ex0_i1_s3_t_offset:ex0_i1_s3_t_offset + 3 - 1]),
      .scout(sov[ex0_i1_s3_t_offset:ex0_i1_s3_t_offset + 3 - 1]),
      .din(rv_lq_rv1_i1_s3_t),
      .dout(ex0_i1_s3_t_q)
      );
   
                                    
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i1_isStore_reg
     (
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
      .scin(siv[ex0_i1_isStore_offset]),
      .scout(sov[ex0_i1_isStore_offset]),
      .din(rv_lq_rv1_i1_isStore),
      .dout(ex0_i1_isStore_q)
      );
   
   
   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex0_i1_itag_reg
     (
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
      .scin(siv[ex0_i1_itag_offset:ex0_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[ex0_i1_itag_offset:ex0_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(rv_lq_rv1_i1_itag),
      .dout(ex0_i1_itag_q)
      );
                                    
                                    
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex1_i1_vld_reg
     (
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
      .scin(siv[ex1_i1_vld_offset:ex1_i1_vld_offset + `THREADS - 1]),
      .scout(sov[ex1_i1_vld_offset:ex1_i1_vld_offset + `THREADS - 1]),
      .din(ex1_i1_vld_d),
      .dout(ex1_i1_vld_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_i1_isLoad_reg
     (
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
      .scin(siv[ex1_i1_isLoad_offset]),
      .scout(sov[ex1_i1_isLoad_offset]),
      .din(ex1_i1_isLoad_d),
      .dout(ex1_i1_isLoad_q)
      );
                                    
                                    
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_i1_pre_reg
     (
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
      .scin(siv[ex1_i1_pre_offset]),
      .scout(sov[ex1_i1_pre_offset]),
      .din(ex1_i1_pre_d),
      .dout(ex1_i1_pre_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_i1_instq_reg
     (
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
      .scin(siv[ex1_i1_instq_offset]),
      .scout(sov[ex1_i1_instq_offset]),
      .din(ex1_i1_instq_d),
      .dout(ex1_i1_instq_q)
      );
                                    
      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex1_i1_itag_reg
     (
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
      .scin(siv[ex1_i1_itag_offset:ex1_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[ex1_i1_itag_offset:ex1_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ex1_i1_itag_d),
      .dout(ex1_i1_itag_q)
      );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_odq_vld_reg
     (
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
      .scin(siv[ldq_odq_vld_offset]),
      .scout(sov[ldq_odq_vld_offset]),
      .din(ldq_odq_vld),
      .dout(ldq_odq_vld_q)
      );
                                    
                                    
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ldq_odq_tid_reg
     (
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
      .scin(siv[ldq_odq_tid_offset:ldq_odq_tid_offset + `THREADS - 1]),
      .scout(sov[ldq_odq_tid_offset:ldq_odq_tid_offset + `THREADS - 1]),
      .din(ldq_odq_tid),
      .dout(ldq_odq_tid_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_odq_inv_reg
     (
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
      .scin(siv[ldq_odq_inv_offset]),
      .scout(sov[ldq_odq_inv_offset]),
      .din(ldq_odq_inv),
      .dout(ldq_odq_inv_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_odq_wimge_i_reg
     (
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
      .scin(siv[ldq_odq_wimge_i_offset]),
      .scout(sov[ldq_odq_wimge_i_offset]),
      .din(ldq_odq_wimge_i),
      .dout(ldq_odq_wimge_i_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_odq_hit_reg
     (
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
      .scin(siv[ldq_odq_hit_offset]),
      .scout(sov[ldq_odq_hit_offset]),
      .din(ldq_odq_hit),
      .dout(ldq_odq_hit_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_odq_fwd_reg
     (
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
      .scin(siv[ldq_odq_fwd_offset]),
      .scout(sov[ldq_odq_fwd_offset]),
      .din(ldq_odq_fwd),
      .dout(ldq_odq_fwd_q)
      );
   
   
   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ldq_odq_itag_reg
     (
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
      .scin(siv[ldq_odq_itag_offset:ldq_odq_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[ldq_odq_itag_offset:ldq_odq_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ldq_odq_itag),
      .dout(ldq_odq_itag_q)
      );
   
   generate
      genvar  tid;
      for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
        begin : iu_lq_cp_next_itag_tid
           
           tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) iu_lq_cp_next_itag_reg
		 (
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
		  .scin(siv[iu_lq_cp_next_itag_offset + (`ITAG_SIZE_ENC * tid):iu_lq_cp_next_itag_offset + (`ITAG_SIZE_ENC * (tid + 1)) - 1]),
		  .scout(sov[iu_lq_cp_next_itag_offset + (`ITAG_SIZE_ENC * tid):iu_lq_cp_next_itag_offset + (`ITAG_SIZE_ENC * (tid + 1)) - 1]),
		  .din(iu_lq_cp_next_itag_int[tid]),
		  .dout(iu_lq_cp_next_itag_q[tid])
		  );

        end 

      for (tid = 0; tid <= `THREADS-1; tid = tid + 1)
        begin : cp_i0_completed_itag_latch_gen
	   
           tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) cp_i0_completed_itag_latch
		 (
                  .nclk(nclk),
                  .vd(vdd),
                  .gd(gnd),
                  .act(iu_lq_i0_completed[tid]),
                  .force_t(func_sl_force),
                  .d_mode(d_mode_dc),
                  .delay_lclkr(delay_lclkr_dc),
                  .mpw1_b(mpw1_dc_b),
                  .mpw2_b(mpw2_dc_b),
                  .thold_b(func_sl_thold_0_b),
                  .sg(sg_0),
                  .scin(siv[cp_i0_completed_itag_offset + (`ITAG_SIZE_ENC * tid):cp_i0_completed_itag_offset + (`ITAG_SIZE_ENC * (tid + 1)) - 1]),
                  .scout(sov[cp_i0_completed_itag_offset + (`ITAG_SIZE_ENC * tid):cp_i0_completed_itag_offset + (`ITAG_SIZE_ENC * (tid + 1)) - 1]),
                  .din(iu_lq_i0_completed_itag_int[tid]),
                  .dout(cp_i0_completed_itag_q[tid])
                  );
        end

      for (tid = 0; tid <= `THREADS-1; tid = tid + 1)
        begin : cp_i1_completed_itag_latch_gen

           tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) cp_i1_completed_itag_latch
		 (
                  .nclk(nclk),
                  .vd(vdd),
                  .gd(gnd),
                  .act(iu_lq_i1_completed[tid]),
                  .force_t(func_sl_force),
                  .d_mode(d_mode_dc),
                  .delay_lclkr(delay_lclkr_dc),
                  .mpw1_b(mpw1_dc_b),
                  .mpw2_b(mpw2_dc_b),
                  .thold_b(func_sl_thold_0_b),
                  .sg(sg_0),
                  .scin(siv[cp_i1_completed_itag_offset + (`ITAG_SIZE_ENC * tid):cp_i1_completed_itag_offset + (`ITAG_SIZE_ENC * (tid + 1)) - 1]),
                  .scout(sov[cp_i1_completed_itag_offset + (`ITAG_SIZE_ENC * tid):cp_i1_completed_itag_offset + (`ITAG_SIZE_ENC * (tid + 1)) - 1]),
                  .din(iu_lq_i1_completed_itag_int[tid]),
                  .dout(cp_i1_completed_itag_q[tid])
                  );
        end
      
      for (tid = 0; tid <= `THREADS - 1; tid = tid + 1)
        begin : flushed_credit_count

           tri_rlmreg_p #(.WIDTH(`LDSTQ_ENTRIES_ENC), .INIT(0), .NEEDS_SRESET(1)) flushed_credit_count_reg
		 (
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
                  .scin(siv[flushed_credit_count_offset + (`LDSTQ_ENTRIES_ENC * tid):flushed_credit_count_offset + (`LDSTQ_ENTRIES_ENC * (tid + 1)) - 1]),
                  .scout(sov[flushed_credit_count_offset + (`LDSTQ_ENTRIES_ENC * tid):flushed_credit_count_offset + (`LDSTQ_ENTRIES_ENC * (tid + 1)) - 1]),
                  .din(flushed_credit_count_d[tid]),
                  .dout(flushed_credit_count_q[tid])
                  );


        end
   endgenerate
   
   
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_i0_completed_latch
     (
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[cp_i0_completed_offset:cp_i0_completed_offset + `THREADS - 1]),
      .scout(sov[cp_i0_completed_offset:cp_i0_completed_offset + `THREADS - 1]),
      .din(iu_lq_i0_completed),
      .dout(cp_i0_completed_q)
      );
    
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_i1_completed_latch
     (
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[cp_i1_completed_offset:cp_i1_completed_offset + `THREADS - 1]),
      .scout(sov[cp_i1_completed_offset:cp_i1_completed_offset + `THREADS - 1]),
      .din(iu_lq_i1_completed),
      .dout(cp_i1_completed_q)
      );
                                   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_odq_cline_chk_reg
     (
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
      .scin(siv[ldq_odq_cline_chk_offset]),
      .scout(sov[ldq_odq_cline_chk_offset]),
      .din(ldq_odq_cline_chk),
      .dout(ldq_odq_cline_chk_q)
      );
   
   
   tri_rlmreg_p #(.WIDTH(`LDSTQ_ENTRIES + 1), .INIT((2 ** `LDSTQ_ENTRIES)), .NEEDS_SRESET(1)) next_fill_ptr_reg
     (
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
      .scin(siv[next_fill_ptr_offset:next_fill_ptr_offset + (`LDSTQ_ENTRIES+1) - 1]),
      .scout(sov[next_fill_ptr_offset:next_fill_ptr_offset + (`LDSTQ_ENTRIES+1) - 1]),
      .din(next_fill_ptr_d),
      .dout(next_fill_ptr_q)
      );
   
                                             
   tri_rlmreg_p #(.WIDTH(`LDSTQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) collision_vector_reg
     (
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
      .scin(siv[collision_vector_offset:collision_vector_offset + `LDSTQ_ENTRIES - 1]),
      .scout(sov[collision_vector_offset:collision_vector_offset + `LDSTQ_ENTRIES - 1]),
      .din(collision_vector_d),
      .dout(collision_vector_q)
      );
                                           
                                                
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush_reg
     (
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
      .din(cp_flush_d),
      .dout(cp_flush_q)
      );
   
   
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush2_reg
     (
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
      .din(cp_flush2_d),
      .dout(cp_flush2_q)
      );
                                                
   
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush3_reg
     (
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
      .din(cp_flush3_d),
      .dout(cp_flush3_q)
      );
   
   
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush4_reg
     (
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
      .din(cp_flush4_d),
      .dout(cp_flush4_q)
      );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) cp_flush5_reg
     (
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
      .scin(siv[cp_flush5_offset:cp_flush5_offset + `THREADS - 1]),
      .scout(sov[cp_flush5_offset:cp_flush5_offset + `THREADS - 1]),
      .din(cp_flush5_d),
      .dout(cp_flush5_q)
      );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_lq_spr_xucr0_cls_reg
     (
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
      .scin(siv[xu_lq_spr_xucr0_cls_offset]),
      .scout(sov[xu_lq_spr_xucr0_cls_offset]),
      .din(xu_lq_spr_xucr0_cls),
      .dout(xu_lq_spr_xucr0_cls_q)
      );
   
   
   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) lq_iu_credit_free_reg
     (
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
      .scin(siv[lq_iu_credit_free_offset:lq_iu_credit_free_offset + `THREADS - 1]),
      .scout(sov[lq_iu_credit_free_offset:lq_iu_credit_free_offset + `THREADS - 1]),
      .din(lq_iu_credit_free_d),
      .dout(lq_iu_credit_free_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) compress_val_reg
     (
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
      .scin(siv[compress_val_offset]),
      .scout(sov[compress_val_offset]),
      .din(compress_val_d),
      .dout(compress_val_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rv1_binv_val_reg
     (
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
      .scin(siv[rv1_binv_val_offset]),
      .scout(sov[rv1_binv_val_offset]),
      .din(rv1_binv_val_d),
      .dout(rv1_binv_val_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_binv_val_reg
     (
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
      .scin(siv[ex0_binv_val_offset]),
      .scout(sov[ex0_binv_val_offset]),
      .din(ex0_binv_val_d),
      .dout(ex0_binv_val_q)
      );
                                                
                                                
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_binv_val_reg
     (
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
      .scin(siv[ex1_binv_val_offset]),
      .scout(sov[ex1_binv_val_offset]),
      .din(ex1_binv_val_d),
      .dout(ex1_binv_val_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_binv_val_reg
     (
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
      .scin(siv[ex2_binv_val_offset]),
      .scout(sov[ex2_binv_val_offset]),
      .din(ex2_binv_val_d),
      .dout(ex2_binv_val_q)
      );
                                                
                                                
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_binv_val_reg
     (
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
      .scin(siv[ex3_binv_val_offset]),
      .scout(sov[ex3_binv_val_offset]),
      .din(ex3_binv_val_d),
      .dout(ex3_binv_val_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_binv_val_reg
     (
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
      .scin(siv[ex4_binv_val_offset]),
      .scout(sov[ex4_binv_val_offset]),
      .din(ex4_binv_val_d),
      .dout(ex4_binv_val_q)
      );
                                                
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_binv_val_reg
     (
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
      .scin(siv[ex5_binv_val_offset]),
      .scout(sov[ex5_binv_val_offset]),
      .din(ex5_binv_val_d),
      .dout(ex5_binv_val_q)
      );
   
   
   tri_rlmreg_p #(.WIDTH((`DC_SIZE-`CL_SIZE-3)), .INIT(0), .NEEDS_SRESET(1)) rv1_binv_addr_reg
     (
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
      .scin(siv[rv1_binv_addr_offset:rv1_binv_addr_offset + (`DC_SIZE-`CL_SIZE-3) - 1]),
      .scout(sov[rv1_binv_addr_offset:rv1_binv_addr_offset + (`DC_SIZE-`CL_SIZE-3) - 1]),
      .din(rv1_binv_addr_d),
      .dout(rv1_binv_addr_q)
      );
                                                
   
   tri_rlmreg_p #(.WIDTH((`DC_SIZE-`CL_SIZE-3)), .INIT(0), .NEEDS_SRESET(1)) ex0_binv_addr_reg
     (
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
      .scin(siv[ex0_binv_addr_offset:ex0_binv_addr_offset + (`DC_SIZE-`CL_SIZE-3) - 1]),
      .scout(sov[ex0_binv_addr_offset:ex0_binv_addr_offset + (`DC_SIZE-`CL_SIZE-3) - 1]),
      .din(ex0_binv_addr_d),
      .dout(ex0_binv_addr_q)
      );
   
   
   tri_rlmreg_p #(.WIDTH((`DC_SIZE-`CL_SIZE-3)), .INIT(0), .NEEDS_SRESET(1)) ex1_binv_addr_reg
     (
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
      .scin(siv[ex1_binv_addr_offset:ex1_binv_addr_offset + (`DC_SIZE-`CL_SIZE-3) - 1]),
      .scout(sov[ex1_binv_addr_offset:ex1_binv_addr_offset + (`DC_SIZE-`CL_SIZE-3) - 1]),
      .din(ex1_binv_addr_d),
      .dout(ex1_binv_addr_q)
      );
                                                
   
   tri_rlmreg_p #(.WIDTH((`DC_SIZE-`CL_SIZE-3)), .INIT(0), .NEEDS_SRESET(1)) ex2_binv_addr_reg
     (
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
      .scin(siv[ex2_binv_addr_offset:ex2_binv_addr_offset + (`DC_SIZE-`CL_SIZE-3) - 1]),
      .scout(sov[ex2_binv_addr_offset:ex2_binv_addr_offset + (`DC_SIZE-`CL_SIZE-3) - 1]),
      .din(ex2_binv_addr_d),
      .dout(ex2_binv_addr_q)
      );
   
   
   tri_rlmreg_p #(.WIDTH((`DC_SIZE-`CL_SIZE-3)), .INIT(0), .NEEDS_SRESET(1)) ex3_binv_addr_reg
     (
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
      .scin(siv[ex3_binv_addr_offset:ex3_binv_addr_offset + (`DC_SIZE-`CL_SIZE-3) - 1]),
      .scout(sov[ex3_binv_addr_offset:ex3_binv_addr_offset + (`DC_SIZE-`CL_SIZE-3) - 1]),
      .din(ex3_binv_addr_d),
      .dout(ex3_binv_addr_q)
      );
                                                
   
   tri_rlmreg_p #(.WIDTH((`DC_SIZE-`CL_SIZE-3)), .INIT(0), .NEEDS_SRESET(1)) ex4_binv_addr_reg
     (
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
      .scin(siv[ex4_binv_addr_offset:ex4_binv_addr_offset + (`DC_SIZE-`CL_SIZE-3) - 1]),
      .scout(sov[ex4_binv_addr_offset:ex4_binv_addr_offset + (`DC_SIZE-`CL_SIZE-3) - 1]),
      .din(ex4_binv_addr_d),
      .dout(ex4_binv_addr_q)
      );
   
   
   tri_rlmreg_p #(.WIDTH((`DC_SIZE-`CL_SIZE-3)), .INIT(0), .NEEDS_SRESET(1)) ex5_binv_addr_reg
     (
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
      .scin(siv[ex5_binv_addr_offset:ex5_binv_addr_offset + (`DC_SIZE-`CL_SIZE-3) - 1]),
      .scout(sov[ex5_binv_addr_offset:ex5_binv_addr_offset + (`DC_SIZE-`CL_SIZE-3) - 1]),
      .din(ex5_binv_addr_d),
      .dout(ex5_binv_addr_q)
      );
                                                
                                                
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) entry_rv1_blk_reg
     (
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
      .scin(siv[entry_rv1_blk_offset]),
      .scout(sov[entry_rv1_blk_offset]),
      .din(entry_rv1_blk_d),
      .dout(entry_rv1_blk_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) entry_ex0_blk_reg
     (
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
      .scin(siv[entry_ex0_blk_offset]),
      .scout(sov[entry_ex0_blk_offset]),
      .din(entry_ex0_blk_d),
      .dout(entry_ex0_blk_q)
      );
                                                
                                                
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) entry_ex1_blk_reg
     (
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
      .scin(siv[entry_ex1_blk_offset]),
      .scout(sov[entry_ex1_blk_offset]),
      .din(entry_ex1_blk_d),
      .dout(entry_ex1_blk_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) entry_ex2_blk_reg
     (
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
      .scin(siv[entry_ex2_blk_offset]),
      .scout(sov[entry_ex2_blk_offset]),
      .din(entry_ex2_blk_d),
      .dout(entry_ex2_blk_q)
      );
                                                
                                                
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) entry_ex3_blk_reg
     (
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
      .scin(siv[entry_ex3_blk_offset]),
      .scout(sov[entry_ex3_blk_offset]),
      .din(entry_ex3_blk_d),
      .dout(entry_ex3_blk_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) entry_ex4_blk_reg
     (
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
      .scin(siv[entry_ex4_blk_offset]),
      .scout(sov[entry_ex4_blk_offset]),
      .din(entry_ex4_blk_d),
      .dout(entry_ex4_blk_q)
      );
                                                
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) entry_ex5_blk_reg
     (
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
      .scin(siv[entry_ex5_blk_offset]),
      .scout(sov[entry_ex5_blk_offset]),
      .din(entry_ex5_blk_d),
      .dout(entry_ex5_blk_q)
      );
   
   
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) entry_ex6_blk_reg
     (
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
      .scin(siv[entry_ex6_blk_offset]),
      .scout(sov[entry_ex6_blk_offset]),
      .din(entry_ex6_blk_d),
      .dout(entry_ex6_blk_q)
      );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_odq_pfetch_vld_ex6_reg
     (
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
      .scin(siv[ldq_odq_pfetch_vld_ex6_offset]),
      .scout(sov[ldq_odq_pfetch_vld_ex6_offset]),
      .din(ldq_odq_pfetch_vld_ex6_d),
      .dout(ldq_odq_pfetch_vld_ex6_q)
      );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) odq_ldq_ex7_pfetch_blk_reg
     (
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
      .scin(siv[odq_ldq_ex7_pfetch_blk_offset]),
      .scout(sov[odq_ldq_ex7_pfetch_blk_offset]),
      .din(odq_ldq_ex7_pfetch_blk_d),
      .dout(odq_ldq_ex7_pfetch_blk_q)
      );


   assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
   assign scan_out = sov[0];
   
endmodule


