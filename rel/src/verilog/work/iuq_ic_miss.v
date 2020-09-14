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




module iuq_ic_miss(
   vdd,
   gnd,
   nclk,
   pc_iu_func_sl_thold_0_b,
   pc_iu_sg_0,
   force_t,
   d_mode,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   scan_in,
   scan_out,
   iu_flush,
   br_iu_redirect,
   bp_ic_iu4_redirect,
   ic_bp_iu3_ecc_err,
   ics_icm_iu0_t0_ifar,
 `ifndef THREADS1
   ics_icm_iu0_t1_ifar,
 `endif
   ics_icm_iu0_inval,
   ics_icm_iu0_inval_addr,
   ics_icm_iu2_flush,
   icm_ics_hold_thread,
   icm_ics_hold_iu0,
   icm_ics_iu3_miss_match,
   icm_ics_iu3_ecc_fp_cancel,
   icm_ics_iu0_preload_val,
   icm_ics_iu0_preload_ifar,
   icm_ics_prefetch_req,
   icm_ics_prefetch_sm_idle,
   icm_icd_lru_addr,
   icm_icd_dir_inval,
   icm_icd_dir_val,
   icm_icd_data_write,
   icm_icd_reload_addr,
   icm_icd_reload_data,
   icm_icd_reload_way,
   icm_icd_load,
   icm_icd_load_addr,
   icm_icd_load_2ucode,
   icm_icd_load_2ucode_type,
   icm_icd_dir_write,
   icm_icd_dir_write_addr,
   icm_icd_dir_write_endian,
   icm_icd_dir_write_way,
   icm_icd_lru_write,
   icm_icd_lru_write_addr,
   icm_icd_lru_write_way,
   icm_icd_ecc_inval,
   icm_icd_ecc_addr,
   icm_icd_ecc_way,
   icm_icd_iu3_ecc_fp_cancel,
   icm_icd_any_reld_r2,
   icd_icm_miss,
   icd_icm_prefetch,
   icd_icm_tid,
   icd_icm_addr_real,
   icd_icm_addr_eff,
   icd_icm_wimge,
   icd_icm_userdef,
   icd_icm_2ucode,
   icd_icm_2ucode_type,
   icd_icm_iu2_inval,
   icd_icm_any_iu2_valid,
   icd_icm_row_lru,
   icd_icm_row_val,
   ic_perf_t0_event,
 `ifndef THREADS1
   ic_perf_t1_event,
 `endif
   cp_async_block,
   iu_mm_lmq_empty,
   iu_xu_icache_quiesce,
   iu_pc_icache_quiesce,
   an_ac_reld_data_vld,
   an_ac_reld_core_tag,
   an_ac_reld_qw,
   an_ac_reld_data,
   an_ac_reld_ecc_err,
   an_ac_reld_ecc_err_ue,
   spr_ic_cls,
   spr_ic_bp_config,
   iu_lq_request,
   iu_lq_ctag,
   iu_lq_ra,
   iu_lq_wimge,
   iu_lq_userdef,
   event_bus_enable
);

    
   inout                           vdd;
    
   inout                           gnd;
    
    (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]         nclk;
   input                           pc_iu_func_sl_thold_0_b;
   input                           pc_iu_sg_0;
   input                           force_t;
   input                           d_mode;
   input                           delay_lclkr;
   input                           mpw1_b;
   input                           mpw2_b;
   input                           scan_in;
   output                          scan_out;

   input [0:`THREADS-1]            iu_flush;
   input [0:`THREADS-1]            br_iu_redirect;
   input [0:`THREADS-1]            bp_ic_iu4_redirect;

   output                          ic_bp_iu3_ecc_err;

   input [46:52]                   ics_icm_iu0_t0_ifar;
 `ifndef THREADS1
   input [46:52]                   ics_icm_iu0_t1_ifar;
 `endif

   input                           ics_icm_iu0_inval;
   input [51:57]                   ics_icm_iu0_inval_addr;

   input [0:`THREADS-1]            ics_icm_iu2_flush;
   output [0:`THREADS-1]           icm_ics_hold_thread;
   output                          icm_ics_hold_iu0;
   output                          icm_ics_iu3_miss_match;
   output [0:`THREADS-1]           icm_ics_iu3_ecc_fp_cancel;

   output [0:`THREADS-1]           icm_ics_iu0_preload_val;
   output [50:59]                  icm_ics_iu0_preload_ifar;
   output [0:`THREADS-1]           icm_ics_prefetch_req;
   output [0:`THREADS-1]           icm_ics_prefetch_sm_idle;

   output [51:57]                  icm_icd_lru_addr;
   output                          icm_icd_dir_inval;
   output                          icm_icd_dir_val;
   output                          icm_icd_data_write;
   output [51:59]                  icm_icd_reload_addr;
   output [0:143]                  icm_icd_reload_data;
   output [0:3]                    icm_icd_reload_way;
   output [0:`THREADS-1]           icm_icd_load;
   output [62-`EFF_IFAR_WIDTH:61]  icm_icd_load_addr;
   output                          icm_icd_load_2ucode;
   output                          icm_icd_load_2ucode_type;
   output                          icm_icd_dir_write;
   output [64-`REAL_IFAR_WIDTH:57] icm_icd_dir_write_addr;
   output                          icm_icd_dir_write_endian;
   output [0:3]                    icm_icd_dir_write_way;
   output                          icm_icd_lru_write;
   output [51:57]                  icm_icd_lru_write_addr;
   output [0:3]                    icm_icd_lru_write_way;
   output                          icm_icd_ecc_inval;
   output [51:57]                  icm_icd_ecc_addr;
   output [0:3]                    icm_icd_ecc_way;
   output                          icm_icd_iu3_ecc_fp_cancel;
   output                          icm_icd_any_reld_r2;

   input                           icd_icm_miss;        
   input                           icd_icm_prefetch;
   input [0:`THREADS-1]            icd_icm_tid;
   input [64-`REAL_IFAR_WIDTH:61]  icd_icm_addr_real;
   input [62-`EFF_IFAR_WIDTH:51]   icd_icm_addr_eff;    
   input [0:4]                     icd_icm_wimge;       
   input [0:3]                     icd_icm_userdef;
   input                           icd_icm_2ucode;
   input                           icd_icm_2ucode_type;
   input                           icd_icm_iu2_inval;
   input                           icd_icm_any_iu2_valid;

   input [0:2]                     icd_icm_row_lru;     
   input [0:3]                     icd_icm_row_val;     

   output [0:2]                    ic_perf_t0_event;
 `ifndef THREADS1
   output [0:2]                    ic_perf_t1_event;
 `endif

   input [0:`THREADS-1]            cp_async_block;
   output                          iu_mm_lmq_empty;
   output [0:`THREADS-1]           iu_xu_icache_quiesce;
   output [0:`THREADS-1]           iu_pc_icache_quiesce;

   input                           an_ac_reld_data_vld;         
   input [0:4]                     an_ac_reld_core_tag;         
   input [58:59]                   an_ac_reld_qw;               
   input [0:127]                   an_ac_reld_data;             
   input                           an_ac_reld_ecc_err;          
   input                           an_ac_reld_ecc_err_ue;       

   input                           spr_ic_cls;                  
   input [0:3]                     spr_ic_bp_config;            

   output [0:`THREADS-1]           iu_lq_request;
   output [0:1]                    iu_lq_ctag;                  
   output [64-`REAL_IFAR_WIDTH:59] iu_lq_ra;
   output [0:4]                    iu_lq_wimge;
   output [0:3]                    iu_lq_userdef;

   input                           event_bus_enable;


   localparam [0:31]              value_1 = 32'h00000001;							 
   localparam [0:31]              value_2 = 32'h00000002;							 

   parameter                      SM_MAX = 4;   
   parameter                      TAGS_USED = `THREADS * 2;

   parameter                      spr_ic_cls_offset = 0;
   parameter                      bp_config_offset = spr_ic_cls_offset + 1;
   parameter                      an_ac_reld_data_vld_offset = bp_config_offset + 4;
   parameter                      an_ac_reld_core_tag_offset = an_ac_reld_data_vld_offset + 1;
   parameter                      an_ac_reld_qw_offset = an_ac_reld_core_tag_offset + 5;
   parameter                      reld_data_offset = an_ac_reld_qw_offset + 2;
   parameter                      an_ac_reld_ecc_err_offset = reld_data_offset + 128;
   parameter                      an_ac_reld_ecc_err_ue_offset = an_ac_reld_ecc_err_offset + 1;
   parameter                      reld_r1_val_offset = an_ac_reld_ecc_err_ue_offset + 1;
   parameter                      reld_r1_qw_offset = reld_r1_val_offset + TAGS_USED;
   parameter                      reld_r2_val_offset = reld_r1_qw_offset + 2;
   parameter                      reld_r2_qw_offset = reld_r2_val_offset + TAGS_USED;
   parameter                      r2_crit_qw_offset = reld_r2_qw_offset + 2;
   parameter                      reld_r3_val_offset = r2_crit_qw_offset + 1;
   parameter                      r3_loaded_offset = reld_r3_val_offset + TAGS_USED;
   parameter                      request_offset = r3_loaded_offset + 1;
   parameter                      req_ctag_offset = request_offset + `THREADS;
   parameter                      req_ra_offset = req_ctag_offset + 2;
   parameter                      req_wimge_offset = req_ra_offset + `REAL_IFAR_WIDTH - 4;
   parameter                      req_userdef_offset = req_wimge_offset + 5;
   parameter                      iu3_miss_match_offset = req_userdef_offset + 4;

   parameter                      miss_tid_sm_offset = iu3_miss_match_offset + 1;
   parameter                      miss_count_offset = miss_tid_sm_offset + TAGS_USED * 6;
   parameter                      miss_flush_occurred_offset = miss_count_offset + TAGS_USED * 3;
   parameter                      miss_flushed_offset = miss_flush_occurred_offset + TAGS_USED;
   parameter                      miss_inval_offset = miss_flushed_offset + TAGS_USED;
   parameter                      miss_block_fp_offset = miss_inval_offset + TAGS_USED;
   parameter                      miss_ecc_err_offset = miss_block_fp_offset + TAGS_USED;
   parameter                      miss_ecc_err_ue_offset = miss_ecc_err_offset + TAGS_USED;
   parameter                      miss_wrote_dir_offset = miss_ecc_err_ue_offset + TAGS_USED;
   parameter                      miss_need_hold_offset = miss_wrote_dir_offset + TAGS_USED;
   parameter                      miss_addr_real_offset = miss_need_hold_offset + TAGS_USED;
   parameter                      miss_addr_eff_offset = miss_addr_real_offset + TAGS_USED * (`REAL_IFAR_WIDTH - 2);
   parameter                      miss_ci_offset = miss_addr_eff_offset + TAGS_USED * (`EFF_IFAR_WIDTH - 10);
   parameter                      miss_endian_offset = miss_ci_offset + TAGS_USED;
   parameter                      miss_2ucode_offset = miss_endian_offset + TAGS_USED;
   parameter                      miss_2ucode_type_offset = miss_2ucode_offset + TAGS_USED;
   parameter                      miss_way_offset = miss_2ucode_type_offset + TAGS_USED;
   parameter                      lru_write_next_cycle_offset = miss_way_offset + 4 * TAGS_USED;
   parameter                      lru_write_offset = lru_write_next_cycle_offset + TAGS_USED;
   parameter                      miss_prefetch_perf_offset = lru_write_offset + TAGS_USED;
   parameter                      perf_event_offset = miss_prefetch_perf_offset + `THREADS;
   parameter                      scan_right = perf_event_offset + `THREADS * 3 - 1;

   parameter                      IDLE = 0;
   parameter                      WAITMISS = 1;
   parameter                      WAITSTATE = 2;
   parameter                      DATA = 3;
   parameter                      CI = 4;
   parameter                      CHECK_ECC = 5;

   wire [1:24]                    select_lru_way_pt;

   wire [0:TAGS_USED-1]           reld_r1_val_d;
   wire                           spr_ic_cls_d;
   wire [0:3]                     bp_config_d;
   wire                           an_ac_reld_data_vld_d;
   wire [0:4]                     an_ac_reld_core_tag_d;
   wire [58:59]                   an_ac_reld_qw_d;
   wire [0:127]                   reld_data_d;
   wire                           an_ac_reld_ecc_err_d;
   wire                           an_ac_reld_ecc_err_ue_d;
   wire [0:1]                     reld_r1_qw_d;
   wire [0:TAGS_USED-1]           reld_r2_val_d;
   wire [0:1]                     reld_r2_qw_d;
   wire                           r2_crit_qw_d;
   wire [0:TAGS_USED-1]           reld_r3_val_d;
   wire                           r3_loaded_d;
   wire [0:`THREADS-1]            request_d;
   wire [0:1]                     req_ctag_d;
   wire [64-`REAL_IFAR_WIDTH:59]  req_ra_d;
   wire [0:4]                     req_wimge_d;
   wire [0:3]                     req_userdef_d;
   wire                           iu3_miss_match_d;
   wire [0:5]                     miss_tid_sm_d[0:SM_MAX-1];
   wire [0:2]                     miss_count_d[0:TAGS_USED-1];
   wire [64-`REAL_IFAR_WIDTH:61]  miss_addr_real_d[0:TAGS_USED-1];
   wire [62-`EFF_IFAR_WIDTH:51]   miss_addr_eff_d[0:TAGS_USED-1];
   wire [0:3]                     miss_way_d[0:TAGS_USED-1];
   wire [0:TAGS_USED-1]           miss_flush_occurred_d;
   wire [0:SM_MAX-1]              miss_flushed_d;
   wire [0:SM_MAX-1]              miss_inval_d;
   wire [0:TAGS_USED-1]           miss_block_fp_d;
   wire [0:TAGS_USED-1]           miss_ecc_err_d;
   wire [0:TAGS_USED-1]           miss_ecc_err_ue_d;
   wire [0:TAGS_USED-1]           miss_wrote_dir_d;
   wire [0:TAGS_USED-1]           miss_need_hold_d;
   wire [0:SM_MAX-1]              miss_ci_d;
   wire [0:TAGS_USED-1]           miss_endian_d;
   wire [0:TAGS_USED-1]           miss_2ucode_d;
   wire [0:TAGS_USED-1]           miss_2ucode_type_d;
   wire [0:TAGS_USED-1]           lru_write_next_cycle_d;
   wire [0:TAGS_USED-1]           lru_write_d;
   wire [0:`THREADS-1]            miss_prefetch_perf_d;
   wire [0:2]                     perf_event_d[0:`THREADS-1];

   wire [0:SM_MAX-1]              reld_r1_val_l2;
   wire                           spr_ic_cls_l2;
   wire [0:3]                     bp_config_l2;
   wire                           an_ac_reld_data_vld_l2;
   wire [0:4]                     an_ac_reld_core_tag_l2;
   wire [58:59]                   an_ac_reld_qw_l2;
   wire [0:127]                   reld_data_l2;
   wire                           an_ac_reld_ecc_err_l2;
   wire                           an_ac_reld_ecc_err_ue_l2;
   wire [0:1]                     reld_r1_qw_l2;
   wire [0:TAGS_USED-1]           reld_r2_val_l2;
   wire [0:1]                     reld_r2_qw_l2;
   wire                           r2_crit_qw_l2;
   wire [0:TAGS_USED-1]           reld_r3_val_l2;
   wire                           r3_loaded_l2;
   wire [0:`THREADS-1]            request_l2;
   wire [0:1]                     req_ctag_l2;
   wire [64-`REAL_IFAR_WIDTH:59]  req_ra_l2;
   wire [0:4]                     req_wimge_l2;
   wire [0:3]                     req_userdef_l2;
   wire                           iu3_miss_match_l2;
   wire [0:5]                     miss_tid_sm_l2[0:SM_MAX-1];       
   wire [0:2]                     miss_count_l2[0:TAGS_USED-1];
   wire [64-`REAL_IFAR_WIDTH:61]  miss_addr_real_l2[0:TAGS_USED-1];
   wire [62-`EFF_IFAR_WIDTH:51]   miss_addr_eff_l2[0:TAGS_USED-1];
   wire [0:3]                     miss_way_l2[0:TAGS_USED-1];
   wire [0:TAGS_USED-1]           miss_flush_occurred_l2;
   wire [0:SM_MAX-1]              miss_flushed_l2;
   wire [0:SM_MAX-1]              miss_inval_l2;
   wire [0:TAGS_USED-1]           miss_block_fp_l2;     
   wire [0:TAGS_USED-1]           miss_ecc_err_l2;
   wire [0:TAGS_USED-1]           miss_ecc_err_ue_l2;
   wire [0:TAGS_USED-1]           miss_wrote_dir_l2;
   wire [0:TAGS_USED-1]           miss_need_hold_l2;
   wire [0:SM_MAX-1]              miss_ci_l2;
   wire [0:TAGS_USED-1]           miss_endian_l2;
   wire [0:TAGS_USED-1]           miss_2ucode_l2;
   wire [0:TAGS_USED-1]           miss_2ucode_type_l2;
   wire [0:TAGS_USED-1]           lru_write_next_cycle_l2;
   wire [0:TAGS_USED-1]           lru_write_l2;
   wire [0:`THREADS-1]            miss_prefetch_perf_l2;
   wire [0:2]                     perf_event_l2[0:`THREADS-1];

   wire [46:52]                   iu0_ifar[0:TAGS_USED-1];

   wire [0:TAGS_USED-1]           default_reld_act_v;
   wire                           default_reld_act;
   wire                           miss_or_default_act;
   wire                           reld_r2_act;
   wire [0:TAGS_USED-1]           miss_act;

   wire                           reld_r0_vld;
   wire [0:TAGS_USED-1]           reld_r0_tag;
   wire [0:`THREADS-1]            reld_r3_tid;

   wire [0:`THREADS-1]            iu_xu_icache_quiesce_int;

   wire [0:SM_MAX-1]              iu2_flush;
   wire [0:SM_MAX-1]              new_miss;
   wire [0:SM_MAX-1]              last_data;
   wire [0:TAGS_USED-1]           no_data;
   wire [0:TAGS_USED-1]           set_flush_occurred;
   wire [0:TAGS_USED-1]           flush_addr_outside_range;

   wire [0:TAGS_USED-1]           set_flushed;
   wire [0:TAGS_USED-1]           inval_equal;
   wire [0:TAGS_USED-1]           set_invalidated;
   wire [0:SM_MAX-1]              reset_state;
   wire [0:TAGS_USED-1]           sent_fp;
   wire [0:TAGS_USED-1]           set_block_fp;

   wire [0:TAGS_USED-1]           addr_equal;
   wire [0:TAGS_USED-1]           addr_match_tag;
   wire                           addr_match;
   wire                           miss_thread_has_idle;

   wire                           release_sm;
   wire [0:SM_MAX-1]              release_sm_hold;

   wire [0:TAGS_USED-1]           iu0_inval_match;

   wire [0:SM_MAX-1]              request_tag;

   wire [0:TAGS_USED-1]           preload_r0_tag;
   wire [0:`THREADS-1]            preload_r0_tid;
   wire [0:`THREADS-1]            preload_hold_iu0;
   reg [50:59]                    r0_addr;
   wire [0:SM_MAX-1]              load_tag;
   reg [62-`EFF_IFAR_WIDTH:61]    load_addr;
   wire                           load_2ucode;
   wire                           load_2ucode_type;
   wire [0:TAGS_USED-1]           load_tag_no_block;
   wire [0:`THREADS-1]            load_tid_no_block;

   wire [0:TAGS_USED-1]           r0_crit_qw;
   wire [0:TAGS_USED-1]           r1_crit_qw;

   wire                           lru_write_hit;
   wire [0:2]                     hit_lru;
   wire [0:2]                     row_lru;
   wire [0:TAGS_USED-1]           select_lru;
   reg [51:57]                    lru_addr;
   wire [0:TAGS_USED-1]           lru_valid;
   wire [0:TAGS_USED-1]           row_match;
   reg [0:3]                      row_match_way;
   wire [0:3]                     val_or_match;
   wire [0:3]                     next_lru_way;
   wire [0:3]                     next_way;

   wire [0:SM_MAX-1]              hold_tid;
   wire                           hold_iu0;

   wire [0:SM_MAX-1]              write_dir_inval;
   wire [0:SM_MAX-1]              write_dir_val;
   wire [0:SM_MAX-1]              data_write;
   wire [0:SM_MAX-1]              dir_write;
   wire [0:TAGS_USED-1]           dir_write_no_block;

   reg [64-`REAL_IFAR_WIDTH:57]   reload_addr;
   reg [0:3]                      reload_way;
   wire                           reload_endian;
   wire                           reld_r1_endian;
   wire [0:127]                   swap_endian_data;

   wire [0:3]                     branch_decode0;
   wire [0:3]                     branch_decode1;
   wire [0:3]                     branch_decode2;
   wire [0:3]                     branch_decode3;

   wire [0:143]                   instr_data;

   wire [0:TAGS_USED-1]           lru_write;
   reg [51:57]                    lru_write_addr;
   reg [0:3]                      lru_write_way;

   wire [0:TAGS_USED-1]           new_ecc_err;
   wire [0:TAGS_USED-1]           new_ecc_err_ue;
   wire [0:SM_MAX-1]              ecc_err;
   wire [0:SM_MAX-1]              ecc_err_ue;
   wire [0:TAGS_USED-1]           ecc_inval;
   wire [0:TAGS_USED-1]           ecc_block_iu0;
   wire                           ecc_fp;
   reg [51:57]                    r3_addr;
   reg [0:3]                      r3_way;

   wire [0:SM_MAX-1]              active_l1_miss;
   wire [0:scan_right]            siv;
   wire [0:scan_right]            sov;

   wire [0:31]                    tidn32;

    
    (* analysis_not_referenced="true" *)
    
   wire                           miss_unused;



   assign tidn32 = 32'b0;

   generate
   begin : xhdl1
     if (TAGS_USED < SM_MAX)
     begin : gen_unused_t1
	   assign miss_unused = | {load_tag[TAGS_USED:SM_MAX - 1], reset_state[TAGS_USED:SM_MAX - 1], request_tag[TAGS_USED:SM_MAX - 1], write_dir_val[TAGS_USED:SM_MAX - 1], hold_tid[TAGS_USED:SM_MAX - 1], dir_write[TAGS_USED:SM_MAX - 1], miss_ci_d[TAGS_USED:SM_MAX - 1], miss_flushed_d[TAGS_USED:SM_MAX - 1], miss_inval_d[TAGS_USED:SM_MAX - 1], active_l1_miss[TAGS_USED:SM_MAX-1], miss_tid_sm_d[TAGS_USED], miss_tid_sm_d[SM_MAX - 1]};    

       assign iu2_flush[TAGS_USED:SM_MAX - 1]       = {SM_MAX-TAGS_USED{1'b0}};
       assign new_miss[TAGS_USED:SM_MAX - 1]        = {SM_MAX-TAGS_USED{1'b0}};
       assign last_data[TAGS_USED:SM_MAX - 1]       = {SM_MAX-TAGS_USED{1'b0}};
       assign ecc_err[TAGS_USED:SM_MAX - 1]         = {SM_MAX-TAGS_USED{1'b0}};
       assign ecc_err_ue[TAGS_USED:SM_MAX - 1]      = {SM_MAX-TAGS_USED{1'b0}};

       assign reld_r1_val_l2[TAGS_USED:SM_MAX - 1]  = {SM_MAX-TAGS_USED{1'b0}};

       assign miss_flushed_d[TAGS_USED:SM_MAX - 1]  = {SM_MAX-TAGS_USED{1'b0}};
       assign miss_inval_d[TAGS_USED:SM_MAX - 1]    = {SM_MAX-TAGS_USED{1'b0}};
       assign miss_ci_d[TAGS_USED:SM_MAX - 1]       = {SM_MAX-TAGS_USED{1'b0}};

       assign miss_flushed_l2[TAGS_USED:SM_MAX - 1] = {SM_MAX-TAGS_USED{1'b0}};
       assign miss_inval_l2[TAGS_USED:SM_MAX - 1]   = {SM_MAX-TAGS_USED{1'b0}};
       assign miss_ci_l2[TAGS_USED:SM_MAX - 1]      = {SM_MAX-TAGS_USED{1'b0}};

       genvar  i;
       for (i = TAGS_USED; i < SM_MAX; i = i + 1)
       begin : gen_sm_t1
         assign miss_tid_sm_l2[i][0] = 1'b1;
         assign miss_tid_sm_l2[i][1:CHECK_ECC] = {CHECK_ECC{1'b0}};
       end
     end

     if (TAGS_USED >= SM_MAX)
     begin : gen_unused_t2
       assign miss_unused = 1'b0;
     end

   end
   endgenerate

   assign iu0_ifar[0] = ics_icm_iu0_t0_ifar;
   assign iu0_ifar[1] = ics_icm_iu0_t0_ifar;

  `ifndef THREADS1
     assign iu0_ifar[2] = ics_icm_iu0_t1_ifar;
     assign iu0_ifar[3] = ics_icm_iu0_t1_ifar;
  `endif

   generate
   begin : xhdl2
     genvar  i;
     for (i = 0; i < TAGS_USED; i = i + 1)
     begin : gen_default_reld_act
       assign default_reld_act_v[i] = (~miss_tid_sm_l2[i][IDLE]);
     end
   end
   endgenerate

   assign default_reld_act = |(default_reld_act_v);
   assign miss_or_default_act = default_reld_act | (|(miss_act));
   assign reld_r2_act = |(reld_r1_val_l2);

   assign bp_config_d = spr_ic_bp_config;        
   assign spr_ic_cls_d = spr_ic_cls;

   assign an_ac_reld_data_vld_d = an_ac_reld_data_vld;
   assign an_ac_reld_core_tag_d = an_ac_reld_core_tag;
   assign an_ac_reld_qw_d = an_ac_reld_qw;

   assign reld_r0_vld = an_ac_reld_data_vld_l2 & (an_ac_reld_core_tag_l2[0:2] == 3'b010);


   generate
   begin : xhdl3
     genvar  i;
     for (i = 0; i < TAGS_USED; i = i + 1)
     begin : gen_reld_tag
       wire [0:1]  index = i;
       assign reld_r0_tag[i] = (an_ac_reld_core_tag_l2[3:4] == index);
     end
   end
   endgenerate

   assign reld_r1_val_d = {TAGS_USED{reld_r0_vld}} & reld_r0_tag;
   assign reld_r1_qw_d = an_ac_reld_qw_l2;

   assign reld_r2_val_d = reld_r1_val_l2[0:TAGS_USED - 1];
   assign reld_r2_qw_d = reld_r1_qw_l2;

   assign reld_r3_val_d = reld_r2_val_l2;
   assign an_ac_reld_ecc_err_d = an_ac_reld_ecc_err;
   assign an_ac_reld_ecc_err_ue_d = an_ac_reld_ecc_err_ue;

   generate
   begin : xhdl4
     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : gen_reld_r3_tid
       assign reld_r3_tid[i] = reld_r3_val_l2[2 * i] | reld_r3_val_l2[2 * i + 1];
       assign iu2_flush[2 * i] = ics_icm_iu2_flush[i];
       assign iu2_flush[2 * i + 1] = ics_icm_iu2_flush[i];
     end
   end
   endgenerate

   generate
   begin
     genvar  i;
     for (i = 0; i < SM_MAX; i = i + 1)
     begin : miss_sm_loop
       iuq_ic_miss_table  miss_sm(
          .new_miss(new_miss[i]),
          .miss_ci_l2(miss_ci_l2[i]),
          .reld_r1_val_l2(reld_r1_val_l2[i]),
          .r2_crit_qw_l2(r2_crit_qw_l2),
          .ecc_err(ecc_err[i]),
          .ecc_err_ue(ecc_err_ue[i]),
          .addr_match(addr_match),
          .iu2_flush(iu2_flush[i]),
          .release_sm(release_sm),
          .miss_flushed_l2(miss_flushed_l2[i]),
          .miss_inval_l2(miss_inval_l2[i]),
          .miss_tid_sm_l2(miss_tid_sm_l2[i]),
          .last_data(last_data[i]),
          .miss_tid_sm_d(miss_tid_sm_d[i]),
          .reset_state(reset_state[i]),
          .request_tag(request_tag[i]),
          .write_dir_inval(write_dir_inval[i]),
          .write_dir_val(write_dir_val[i]),
          .hold_tid(hold_tid[i]),
          .data_write(data_write[i]),
          .dir_write(dir_write[i]),
          .load_tag(load_tag[i]),
          .release_sm_hold(release_sm_hold[i])
       );
     end
   end
   endgenerate


   assign iu_mm_lmq_empty = &(iu_xu_icache_quiesce_int) & (~(|(cp_async_block)));
   assign iu_xu_icache_quiesce = iu_xu_icache_quiesce_int;
   assign iu_pc_icache_quiesce = iu_xu_icache_quiesce_int;

   generate
   begin : xhdl5
     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : gen_new_miss
       assign new_miss[2*i]     = icd_icm_miss & icd_icm_tid[i] & (~icd_icm_prefetch);
       assign new_miss[2*i+1] = icd_icm_miss & icd_icm_tid[i] & ((icd_icm_prefetch & (~icd_icm_wimge[1]) & (~icd_icm_wimge[3])) | (~miss_tid_sm_l2[2*i][IDLE]));

       assign miss_prefetch_perf_d[i] = (icd_icm_miss & icd_icm_tid[i] & miss_tid_sm_l2[2*i+1][IDLE]) ?
	 (icd_icm_prefetch & (~icd_icm_wimge[1]) & (~icd_icm_wimge[3])) :
	  miss_prefetch_perf_l2[i];

       assign iu_xu_icache_quiesce_int[i] = miss_tid_sm_l2[2*i][IDLE] & miss_tid_sm_l2[2*i+1][IDLE];
       assign icm_ics_prefetch_req[i] = icd_icm_miss & icd_icm_tid[i] & (~icd_icm_prefetch) & (~icd_icm_wimge[1]) & (~icd_icm_wimge[3]) & (~addr_match) & (miss_tid_sm_l2[2*i][IDLE] | miss_tid_sm_l2[2*i+1][IDLE]) & (~ics_icm_iu2_flush[i]);
       assign icm_ics_prefetch_sm_idle[i] = miss_tid_sm_l2[2*i+1][IDLE];
     end

     for (i = 0; i < TAGS_USED; i = i + 1)
     begin : gen_miss
       assign miss_count_d[i] = ((request_tag[i] | (miss_tid_sm_l2[i][CHECK_ECC] & ecc_err[i])) == 1'b1) ? {spr_ic_cls_l2, 2'b11} :
                                (miss_tid_sm_l2[i][DATA] == 1'b1) ? miss_count_l2[i] - 3'b001 :
                                 miss_count_l2[i];

       assign last_data[i] = miss_count_l2[i] == 3'b000;
       assign no_data[i] = miss_count_l2[i] == {spr_ic_cls_l2, 2'b11};

       assign miss_act[i] = miss_tid_sm_l2[i][IDLE] & icd_icm_any_iu2_valid & icd_icm_tid[i/2];         
       assign miss_addr_real_d[i] = icd_icm_addr_real;          
       assign miss_addr_eff_d[i] = icd_icm_addr_eff;            
       assign miss_ci_d[i] = icd_icm_wimge[1];                  
       assign miss_endian_d[i] = icd_icm_wimge[4];              
       assign miss_2ucode_d[i] = icd_icm_2ucode;                
       assign miss_2ucode_type_d[i] = icd_icm_2ucode_type;      

       assign set_flush_occurred[i] = (iu_flush[i/2] | br_iu_redirect[i/2] | bp_ic_iu4_redirect[i/2]) & (~miss_tid_sm_l2[i][IDLE]) & (~miss_tid_sm_l2[i][WAITMISS]);
       assign miss_flush_occurred_d[i] = (reset_state[i] == 1'b1) ?        1'b0 :  
                                         (set_flush_occurred[i] == 1'b1) ? 1'b1 :  
                                         miss_flush_occurred_l2[i];

       assign flush_addr_outside_range[i] = iu0_ifar[i] != {miss_addr_eff_l2[i][46:51], miss_addr_real_l2[i][52]};    

       assign set_flushed[i] = miss_flush_occurred_l2[i] & flush_addr_outside_range[i] & reld_r1_val_l2[i] &
           ((miss_tid_sm_l2[i][WAITSTATE] & no_data[i]) | miss_tid_sm_l2[i][CHECK_ECC]);

       assign miss_flushed_d[i] = (reset_state[i] == 1'b1) ? 1'b0 :  
                                  (set_flushed[i] == 1'b1) ? 1'b1 :  
                                  miss_flushed_l2[i];
     end

     assign inval_equal = {TAGS_USED{icd_icm_iu2_inval}} & addr_equal;

     for (i = 0; i < TAGS_USED; i = i + 1)
     begin : gen_miss_inval
       assign set_invalidated[i] = inval_equal[i] & (~miss_tid_sm_l2[i][IDLE]) & (~miss_tid_sm_l2[i][WAITMISS]) & (~miss_ci_l2[i]);
       assign miss_inval_d[i] = (reset_state[i] == 1'b1)     ? 1'b0 :  
                                (set_invalidated[i] == 1'b1) ? 1'b1 :  
                                miss_inval_l2[i];
     end

     for (i = 0; i < TAGS_USED; i = i + 1)
     begin : gen_miss_block_fp
       assign sent_fp[i] = (r3_loaded_l2 & (~(an_ac_reld_ecc_err_l2))) & reld_r3_val_l2[i];   
       assign set_block_fp[i] = sent_fp[i] |    
           (iu2_flush[i] & (~(miss_tid_sm_l2[i][IDLE] | miss_tid_sm_l2[i][WAITMISS]))) |
           (icd_icm_prefetch & new_miss[i] & miss_tid_sm_l2[i][IDLE] & miss_tid_sm_d[i][WAITSTATE]);
       assign miss_block_fp_d[i] = (reset_state[i] == 1'b1)  ? 1'b0 :  
                                   (set_block_fp[i] == 1'b1) ? 1'b1 :  
                                   miss_block_fp_l2[i];
     end

     for (i = 0; i < TAGS_USED; i = i + 1)
     begin : gen_miss_ecc_err
       assign miss_ecc_err_d[i] = ((miss_tid_sm_l2[i][WAITSTATE] & no_data[i]) == 1'b1) ? 1'b0 :  
                                  (new_ecc_err[i] == 1'b1) ? 1'b1 :
                                  miss_ecc_err_l2[i];

       assign miss_ecc_err_ue_d[i] = ((miss_tid_sm_l2[i][WAITSTATE] & no_data[i]) == 1'b1) ? 1'b0 :  
                                     (new_ecc_err_ue[i] == 1'b1) ? an_ac_reld_ecc_err_ue_l2 :
                                     miss_ecc_err_ue_l2[i];

       assign addr_equal[i] = (icd_icm_addr_real[64 - `REAL_IFAR_WIDTH:56] == miss_addr_real_l2[i][64 - `REAL_IFAR_WIDTH:56]) &
                              (spr_ic_cls_l2 | (icd_icm_addr_real[57] == miss_addr_real_l2[i][57]));

       assign addr_match_tag[i] = (addr_equal[i] & (~miss_tid_sm_l2[i][IDLE]));
     end

     assign addr_match = |(addr_match_tag);

     if (`THREADS == 1)
     begin : gen_is_idle_t1
       assign miss_thread_has_idle = miss_tid_sm_l2[0][IDLE] | miss_tid_sm_l2[1][IDLE];
     end
     if (`THREADS == 2)
     begin : gen_is_idle_t2
       assign miss_thread_has_idle = ((miss_tid_sm_l2[0][IDLE] | miss_tid_sm_l2[1][IDLE]) & icd_icm_tid[0]) |
                                     ((miss_tid_sm_l2[2][IDLE] | miss_tid_sm_l2[3][IDLE]) & icd_icm_tid[1]);
     end

     assign iu3_miss_match_d = (miss_thread_has_idle == 1'b1) ? addr_match :    
                                                                1'b1;  
     assign icm_ics_iu3_miss_match = iu3_miss_match_l2;

     assign release_sm = |(release_sm_hold);

     for (i = 0; i < TAGS_USED; i = i + 1)
     begin : gen_miss_wrote
       assign iu0_inval_match[i] = ics_icm_iu0_inval & (ics_icm_iu0_inval_addr[51:56] == miss_addr_real_l2[i][51:56]) &
                                      (spr_ic_cls_l2 | (ics_icm_iu0_inval_addr[57] == miss_addr_real_l2[i][57]));

       assign miss_wrote_dir_d[i] = (reset_state[i] == 1'b1) ? 1'b0 :  
                                    (dir_write_no_block[i] | miss_wrote_dir_l2[i]);
     end

     for (i = 0; i < `THREADS; i = i + 1)
     begin : gen_need_hold
       assign miss_need_hold_d[2*i] = (iu2_flush[2*i] == 1'b1) ? 1'b0 :
                ((new_miss[2*i] &
                  (miss_tid_sm_l2[2*i][IDLE] | ((~miss_tid_sm_l2[2*i][IDLE]) & (~miss_tid_sm_l2[2*i+1][IDLE])))) == 1'b1) ? 1'b1 :
                miss_need_hold_l2[2*i];

       assign miss_need_hold_d[2*i+1] = ((iu2_flush[2*i+1] | reset_state[2*i+1]) == 1'b1) ? 1'b0 :
                                        ((new_miss[2*i] &     
                                          miss_tid_sm_l2[2*i+1][IDLE] & (~miss_tid_sm_l2[2*i][IDLE])) == 1'b1) ? 1'b1 :
                                        miss_need_hold_l2[2 * i + 1];
     end
   end
   endgenerate

   generate
   begin : xhdl12
     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : gen_request
       assign request_d[i] = request_tag[2*i] | request_tag[2*i+1];
     end

     if (`THREADS == 1)
     begin : gen_ctag_t1
       assign req_ctag_d[0] = 1'b0;
     end
     if (`THREADS == 2)
     begin : gen_ctag_t2
       assign req_ctag_d[0] = icd_icm_tid[1];
     end
   end
   endgenerate

   assign req_ctag_d[1] = new_miss[1] | new_miss[TAGS_USED - 1];        

   assign req_ra_d = icd_icm_addr_real[64 - `REAL_IFAR_WIDTH:59];
   assign req_wimge_d = icd_icm_wimge;
   assign req_userdef_d = icd_icm_userdef;

   assign iu_lq_request = request_l2;
   assign iu_lq_ctag = req_ctag_l2;
   assign iu_lq_ra = req_ra_l2;
   assign iu_lq_wimge = req_wimge_l2;
   assign iu_lq_userdef = req_userdef_l2;


   always @(*)
   begin: addr_mux_proc
     reg [50:59]                    r0_addr_calc;
     reg [51:57]                    lru_addr_calc;
     reg [62-`EFF_IFAR_WIDTH:61]    load_addr_calc;
     reg [64-`REAL_IFAR_WIDTH:57]   reload_addr_calc;
     reg [0:3]                      reload_way_calc;
     reg [51:57]                    lru_write_addr_calc;
     reg [0:3]                      lru_write_way_calc;
     reg [51:57]                    r3_addr_calc;
     reg [0:3]                      r3_way_calc;
     reg [0:3]                      row_match_way_calc;
     (* analysis_not_referenced="true" *)
     integer                        i;
     r0_addr_calc = 10'b0;
     lru_addr_calc = 7'b0;
     load_addr_calc = {`EFF_IFAR_WIDTH{1'b0}};
     reload_addr_calc = {`REAL_IFAR_WIDTH-6{1'b0}};
     reload_way_calc = 4'b0;
     lru_write_addr_calc = 7'b0;
     lru_write_way_calc = 4'b0;
     r3_addr_calc = 7'b0;
     r3_way_calc = 4'b0;
     row_match_way_calc = 4'b0;

     for (i = 0; i < TAGS_USED; i = i + 1)
     begin
       r0_addr_calc = r0_addr_calc |
           {10{reld_r0_tag[i]}} & {miss_addr_eff_l2[i][50:51], miss_addr_real_l2[i][52:59]};
       lru_addr_calc = lru_addr_calc |
           {7{reld_r1_val_l2[i]}} & miss_addr_real_l2[i][51:57];
       load_addr_calc = load_addr_calc |
           {`EFF_IFAR_WIDTH{reld_r2_val_l2[i]}} & {miss_addr_eff_l2[i], miss_addr_real_l2[i][52:61]};
       reload_addr_calc = reload_addr_calc |
           {`REAL_IFAR_WIDTH-6{reld_r2_val_l2[i]}} & miss_addr_real_l2[i][64 - `REAL_IFAR_WIDTH:57];
       reload_way_calc = reload_way_calc |
           {4{reld_r2_val_l2[i]}} & miss_way_l2[i];
       lru_write_addr_calc = lru_write_addr_calc |
           {7{lru_write_l2[i]}} & miss_addr_real_l2[i][51:57];
       lru_write_way_calc = lru_write_way_calc |
           {4{lru_write_l2[i]}} & miss_way_l2[i];
       r3_addr_calc = r3_addr_calc |
           {7{reld_r3_val_l2[i]}} & miss_addr_real_l2[i][51:57];
       r3_way_calc = r3_way_calc |
           {4{reld_r3_val_l2[i]}} & miss_way_l2[i];
       row_match_way_calc = row_match_way_calc |
           {4{row_match[i]}} & miss_way_l2[i];
     end
     r0_addr <= r0_addr_calc;
     lru_addr <= lru_addr_calc;
     load_addr <= load_addr_calc;
     reload_addr <= reload_addr_calc;
     reload_way <= reload_way_calc;
     lru_write_addr <= lru_write_addr_calc;
     lru_write_way <= lru_write_way_calc;
     r3_addr <= r3_addr_calc;
     r3_way <= r3_way_calc;
     row_match_way <= row_match_way_calc;
   end

   assign preload_r0_tag = r0_crit_qw & reld_r0_tag & (~miss_block_fp_l2) & (~miss_flushed_l2[0:TAGS_USED - 1]);

   generate
   begin : xhdl13
     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : gen_preload_r0_tid
       assign preload_r0_tid[i] = preload_r0_tag[2*i] | preload_r0_tag[2*i+1];
     end
   end
   endgenerate

   assign preload_hold_iu0 = {`THREADS{reld_r0_vld}} & preload_r0_tid;

   assign icm_ics_iu0_preload_val = preload_hold_iu0;
   assign icm_ics_iu0_preload_ifar = r0_addr;

   assign load_2ucode = |(reld_r2_val_l2 & miss_2ucode_l2);
   assign load_2ucode_type = |(reld_r2_val_l2 & miss_2ucode_type_l2);
   assign load_tag_no_block = load_tag[0:TAGS_USED - 1] & (~miss_block_fp_l2[0:TAGS_USED - 1]);

   generate
   begin : xhdl14
     genvar  i;
     for (i = 0; i < `THREADS; i = i + 1)
     begin : gen_load_tid
       assign load_tid_no_block[i] = load_tag_no_block[2*i] | load_tag_no_block[2*i+1];
     end
   end
   endgenerate

   assign icm_icd_load = load_tid_no_block;
   assign icm_icd_load_addr = load_addr;
   assign icm_icd_load_2ucode = load_2ucode;
   assign icm_icd_load_2ucode_type = load_2ucode_type;

   assign r3_loaded_d = |(load_tid_no_block);

   generate
   begin : xhdl15
     genvar  i;
     for (i = 0; i < TAGS_USED; i = i + 1)
     begin : gen_crit_qw
       assign r0_crit_qw[i] = an_ac_reld_qw_l2[58:59] == miss_addr_real_l2[i][58:59];
       assign r1_crit_qw[i] = reld_r1_qw_l2 == miss_addr_real_l2[i][58:59];
     end
   end
   endgenerate

   assign r2_crit_qw_d = |(r1_crit_qw & reld_r1_val_l2[0:TAGS_USED - 1]);


   assign lru_write_hit = |(lru_write) & (lru_addr[51:56] == lru_write_addr[51:56]) &
                         (spr_ic_cls_l2 | (lru_addr[57] == lru_write_addr[57]));

   assign hit_lru = ({3{lru_write_way[0]}} & {2'b11, icd_icm_row_lru[2]}) |
                    ({3{lru_write_way[1]}} & {2'b10, icd_icm_row_lru[2]}) |
                    ({3{lru_write_way[2]}} & {1'b0, icd_icm_row_lru[1], 1'b1}) |
                    ({3{lru_write_way[3]}} & {1'b0, icd_icm_row_lru[1], 1'b0});

   assign row_lru = (lru_write_hit == 1'b0) ? icd_icm_row_lru :
                    hit_lru;

   generate
   begin : xhdl16
     genvar  i;
     for (i = 0; i < TAGS_USED; i = i + 1)
     begin : gen_lru
       assign select_lru[i] = (~miss_ci_l2[i]) & reld_r1_val_l2[i] & (miss_tid_sm_l2[i][WAITSTATE] & no_data[i]) & (~miss_flushed_l2[i]) & (~miss_inval_l2[i]);

       assign lru_valid[i] = (~(miss_tid_sm_l2[i][IDLE] | miss_tid_sm_l2[i][WAITMISS] | (miss_tid_sm_l2[i][WAITSTATE] & no_data[i]) | miss_flushed_l2[i] | miss_inval_l2[i] | miss_ci_l2[i]));

       assign row_match[i] = lru_valid[i] & (lru_addr[51:56] == miss_addr_real_l2[i][51:56]) & (spr_ic_cls_l2 | (lru_addr[57] == miss_addr_real_l2[i][57]));
     end
   end
   endgenerate


   assign val_or_match = icd_icm_row_val | row_match_way;


/*
?TABLE select_lru_way LISTING(final) OPTIMIZE PARMS(ON-SET, OFF-SET);
*INPUTS*=================*OUTPUTS*======*
|                        |              |
| row_lru                |              |
| |    row_match_way     |              |
| |    |                 | next_lru_way |
| |    |                 | |            |
| |    |                 | |            |
| 012  0123              | 0123         |
*TYPE*===================+==============+
| PPP  PPPP              | PPPP         |
*TERMS*==================+==============+
| 00-  0---              | 1000         |
| 000  1-0-              | 0010         |
| 000  101-              | 0100         |
| 000  111-              | 0001         |
| 001  1--0              | 0001         |
| 001  10-1              | 0100         |
| 001  11-1              | 0010         |
|                        |              |
| 01-  -0--              | 0100         |
| 010  -10-              | 0010         |
| 010  011-              | 1000         |
| 010  111-              | 0001         |
| 011  -1-0              | 0001         |
| 011  01-1              | 1000         |
| 011  11-1              | 0010         |
|                        |              |
| 1-0  --0-              | 0010         |
| 100  0-1-              | 1000         |
| 100  1-10              | 0001         |
| 100  1-11              | 0100         |
| 110  -01-              | 0100         |
| 110  -110              | 0001         |
| 110  -111              | 1000         |
|                        |              |
| 1-1  ---0              | 0001         |
| 101  0--1              | 1000         |
| 101  1-01              | 0010         |
| 101  1-11              | 0100         |
| 111  -0-1              | 0100         |
| 111  -101              | 0010         |
| 111  -111              | 1000         |
*END*====================+==============+
?TABLE END select_lru_way;
*/


assign select_lru_way_pt[1] =
    (({ row_lru[0] , row_lru[2] , 
    row_match_way[0] , row_match_way[1] , 
    row_match_way[3] }) === 5'b01011);
assign select_lru_way_pt[2] =
    (({ row_lru[0] , row_lru[2] , 
    row_match_way[0] , row_match_way[1] , 
    row_match_way[2] }) === 5'b00011);
assign select_lru_way_pt[3] =
    (({ row_lru[0] , row_lru[2] , 
    row_match_way[0] , row_match_way[1] , 
    row_match_way[3] }) === 5'b01101);
assign select_lru_way_pt[4] =
    (({ row_lru[0] , row_lru[2] , 
    row_match_way[0] , row_match_way[1] , 
    row_match_way[2] }) === 5'b00101);
assign select_lru_way_pt[5] =
    (({ row_lru[0] , row_lru[1] , 
    row_match_way[1] , row_match_way[2] , 
    row_match_way[3] }) === 5'b11101);
assign select_lru_way_pt[6] =
    (({ row_lru[0] , row_lru[1] , 
    row_match_way[0] , row_match_way[2] , 
    row_match_way[3] }) === 5'b10101);
assign select_lru_way_pt[7] =
    (({ row_lru[0] , row_lru[1] , 
    row_match_way[1] , row_match_way[2] , 
    row_match_way[3] }) === 5'b11110);
assign select_lru_way_pt[8] =
    (({ row_lru[0] , row_lru[1] , 
    row_match_way[0] , row_match_way[2] , 
    row_match_way[3] }) === 5'b10110);
assign select_lru_way_pt[9] =
    (({ row_lru[0] , row_lru[1] , 
    row_match_way[1] , row_match_way[2] , 
    row_match_way[3] }) === 5'b11111);
assign select_lru_way_pt[10] =
    (({ row_lru[0] , row_lru[1] , 
    row_match_way[0] , row_match_way[2] , 
    row_match_way[3] }) === 5'b10111);
assign select_lru_way_pt[11] =
    (({ row_lru[0] , row_lru[2] , 
    row_match_way[0] , row_match_way[1] , 
    row_match_way[3] }) === 5'b01111);
assign select_lru_way_pt[12] =
    (({ row_lru[0] , row_lru[2] , 
    row_match_way[0] , row_match_way[1] , 
    row_match_way[2] }) === 5'b00111);
assign select_lru_way_pt[13] =
    (({ row_lru[1] , row_lru[2] , 
    row_match_way[0] , row_match_way[3]
     }) === 4'b0101);
assign select_lru_way_pt[14] =
    (({ row_lru[1] , row_lru[2] , 
    row_match_way[0] , row_match_way[2]
     }) === 4'b0001);
assign select_lru_way_pt[15] =
    (({ row_lru[1] , row_lru[2] , 
    row_match_way[1] , row_match_way[3]
     }) === 4'b1101);
assign select_lru_way_pt[16] =
    (({ row_lru[1] , row_lru[2] , 
    row_match_way[1] , row_match_way[2]
     }) === 4'b1001);
assign select_lru_way_pt[17] =
    (({ row_lru[1] , row_lru[2] , 
    row_match_way[1] , row_match_way[2]
     }) === 4'b1010);
assign select_lru_way_pt[18] =
    (({ row_lru[1] , row_lru[2] , 
    row_match_way[0] , row_match_way[2]
     }) === 4'b0010);
assign select_lru_way_pt[19] =
    (({ row_lru[1] , row_lru[2] , 
    row_match_way[1] , row_match_way[3]
     }) === 4'b1110);
assign select_lru_way_pt[20] =
    (({ row_lru[1] , row_lru[2] , 
    row_match_way[0] , row_match_way[3]
     }) === 4'b0110);
assign select_lru_way_pt[21] =
    (({ row_lru[0] , row_lru[1] , 
    row_match_way[0] }) === 3'b000);
assign select_lru_way_pt[22] =
    (({ row_lru[0] , row_lru[1] , 
    row_match_way[1] }) === 3'b010);
assign select_lru_way_pt[23] =
    (({ row_lru[0] , row_lru[2] , 
    row_match_way[2] }) === 3'b100);
assign select_lru_way_pt[24] =
    (({ row_lru[0] , row_lru[2] , 
    row_match_way[3] }) === 3'b110);
assign next_lru_way[0] = 
    (select_lru_way_pt[1] | select_lru_way_pt[2]
     | select_lru_way_pt[9] | select_lru_way_pt[13]
     | select_lru_way_pt[14] | select_lru_way_pt[21]
    );
assign next_lru_way[1] = 
    (select_lru_way_pt[3] | select_lru_way_pt[4]
     | select_lru_way_pt[10] | select_lru_way_pt[15]
     | select_lru_way_pt[16] | select_lru_way_pt[22]
    );
assign next_lru_way[2] = 
    (select_lru_way_pt[5] | select_lru_way_pt[6]
     | select_lru_way_pt[11] | select_lru_way_pt[17]
     | select_lru_way_pt[18] | select_lru_way_pt[23]
    );
assign next_lru_way[3] = 
    (select_lru_way_pt[7] | select_lru_way_pt[8]
     | select_lru_way_pt[12] | select_lru_way_pt[19]
     | select_lru_way_pt[20] | select_lru_way_pt[24]
    );


   assign next_way = (val_or_match[0] == 1'b0) ? 4'b1000 :
                     (val_or_match[1] == 1'b0) ? 4'b0100 :
                     (val_or_match[2] == 1'b0) ? 4'b0010 :
                     (val_or_match[3] == 1'b0) ? 4'b0001 :
                     next_lru_way;

   generate
   begin : xhdl17
     genvar  i;
     for (i = 0; i < TAGS_USED; i = i + 1)
     begin : gen_miss_way
       assign miss_way_d[i] = (select_lru[i] == 1'b1) ? next_way :
                                                        miss_way_l2[i];
     end
   end
   endgenerate

   generate
   begin : xhdl18
     genvar  i;
     for (i = 0; i < `THREADS ; i = i + 1)
     begin : gen_hold_thread
       assign icm_ics_hold_thread[i] = ((hold_tid[2*i] | ecc_block_iu0[2*i]) & miss_need_hold_l2[2*i]) | ((hold_tid[2*i+1] | ecc_block_iu0[2*i+1]) & miss_need_hold_l2[2*i+1]);
     end
   end
   endgenerate



   assign hold_iu0 = |(data_write) | (|(preload_hold_iu0));

   assign icm_ics_hold_iu0 = hold_iu0;
   assign icm_icd_lru_addr = lru_addr;
   assign icm_icd_data_write = |(data_write);
   assign icm_icd_dir_inval = |(write_dir_inval);

   assign icm_icd_dir_val = | (write_dir_val[0:TAGS_USED - 1] & miss_wrote_dir_l2 & (~inval_equal));


   assign icm_icd_reload_addr = {reload_addr[51:57], reld_r2_qw_l2};
   assign icm_icd_reload_way = reload_way;

   assign reload_endian = | (reld_r2_val_l2 & miss_endian_l2);
   assign reld_r1_endian = | (reld_r1_val_l2[0:TAGS_USED - 1] & miss_endian_l2);

   assign swap_endian_data =
       {an_ac_reld_data[24:31],   an_ac_reld_data[16:23],   an_ac_reld_data[8:15],    an_ac_reld_data[0:7],
        an_ac_reld_data[56:63],   an_ac_reld_data[48:55],   an_ac_reld_data[40:47],   an_ac_reld_data[32:39],
        an_ac_reld_data[88:95],   an_ac_reld_data[80:87],   an_ac_reld_data[72:79],   an_ac_reld_data[64:71],
        an_ac_reld_data[120:127], an_ac_reld_data[112:119], an_ac_reld_data[104:111], an_ac_reld_data[96:103]};

   assign reld_data_d = (reld_r1_endian == 1'b0) ? an_ac_reld_data :
                        swap_endian_data;

   iuq_bd br_decode0(
      .instruction(reld_data_l2[0:31]),
      .instruction_next(reld_data_l2[32:63]),
      .branch_decode(branch_decode0[0:3]),
      .bp_bc_en(bp_config_l2[0]),
      .bp_bclr_en(bp_config_l2[1]),
      .bp_bcctr_en(bp_config_l2[2]),
      .bp_sw_en(bp_config_l2[3])
   );

   iuq_bd br_decode1(
      .instruction(reld_data_l2[32:63]),
      .instruction_next(reld_data_l2[64:95]),
      .branch_decode(branch_decode1[0:3]),
      .bp_bc_en(bp_config_l2[0]),
      .bp_bclr_en(bp_config_l2[1]),
      .bp_bcctr_en(bp_config_l2[2]),
      .bp_sw_en(bp_config_l2[3])
   );

   iuq_bd br_decode2(
      .instruction(reld_data_l2[64:95]),
      .instruction_next(reld_data_l2[96:127]),
      .branch_decode(branch_decode2[0:3]),
      .bp_bc_en(bp_config_l2[0]),
      .bp_bclr_en(bp_config_l2[1]),
      .bp_bcctr_en(bp_config_l2[2]),
      .bp_sw_en(bp_config_l2[3])
   );

   iuq_bd br_decode3(
      .instruction(reld_data_l2[96:127]),
      .instruction_next(tidn32[0:31]),
      .branch_decode(branch_decode3[0:3]),
      .bp_bc_en(bp_config_l2[0]),
      .bp_bclr_en(bp_config_l2[1]),
      .bp_bcctr_en(bp_config_l2[2]),
      .bp_sw_en(bp_config_l2[3])
   );

   assign instr_data = {reld_data_l2[0:31],   branch_decode0[0:3],
                        reld_data_l2[32:63],  branch_decode1[0:3],
                        reld_data_l2[64:95],  branch_decode2[0:3],
                        reld_data_l2[96:127], branch_decode3[0:3]};

   assign icm_icd_reload_data = instr_data;

   assign dir_write_no_block = dir_write[0:TAGS_USED - 1] & (~iu0_inval_match);
   assign icm_icd_dir_write = |(dir_write_no_block);
   assign icm_icd_dir_write_addr = reload_addr;
   assign icm_icd_dir_write_endian = reload_endian;
   assign icm_icd_dir_write_way = reload_way;

   generate
   begin : xhdl19
     genvar  i;
     for (i = 0; i < TAGS_USED; i = i + 1)
     begin : gen_lru_write
       assign lru_write_next_cycle_d[i] = data_write[i] & (miss_tid_sm_l2[i][DATA] & (miss_count_l2[i] == 3'b001));
       assign lru_write[i] = lru_write_l2[i] & (~miss_inval_l2[i]);
     end
   end
   endgenerate

   assign lru_write_d = lru_write_next_cycle_l2;


   assign icm_icd_lru_write = |(lru_write);
   assign icm_icd_lru_write_addr = lru_write_addr;
   assign icm_icd_lru_write_way = lru_write_way;

   assign icm_icd_any_reld_r2 = |(reld_r2_val_l2);

   assign new_ecc_err = {TAGS_USED{an_ac_reld_ecc_err_l2}} & reld_r3_val_l2;
   assign new_ecc_err_ue = {TAGS_USED{an_ac_reld_ecc_err_ue_l2}} & reld_r3_val_l2;
   assign ecc_err[0:TAGS_USED - 1] = new_ecc_err | miss_ecc_err_l2;
   assign ecc_err_ue[0:TAGS_USED - 1] = new_ecc_err_ue | miss_ecc_err_ue_l2;

   generate
   begin : xhdl20
     genvar  i;
     for (i = 0; i < TAGS_USED; i = i + 1)
     begin : gen_ecc_inval
       assign ecc_inval[i] = (an_ac_reld_ecc_err_l2 | an_ac_reld_ecc_err_ue_l2 | inval_equal[i]) &	
            miss_tid_sm_l2[i][CHECK_ECC] & (~miss_ci_l2[i]) & (~miss_flushed_l2[i]) & (~miss_inval_l2[i]);
       assign ecc_block_iu0[i] = ecc_err[i] & (miss_tid_sm_l2[i][CHECK_ECC] | (miss_tid_sm_l2[i][DATA] & last_data[i]));  
     end
   end
   endgenerate


   assign icm_icd_ecc_inval = |(ecc_inval);    


   assign icm_icd_ecc_addr = r3_addr[51:57];
   assign icm_icd_ecc_way  = r3_way;


   assign ecc_fp = r3_loaded_l2 & an_ac_reld_ecc_err_l2;
   assign icm_icd_iu3_ecc_fp_cancel = ecc_fp;
   assign icm_ics_iu3_ecc_fp_cancel = {`THREADS{ecc_fp}} & reld_r3_tid;
   assign ic_bp_iu3_ecc_err = r3_loaded_l2 & an_ac_reld_ecc_err_ue_l2;

   generate
   begin : xhdl11
     genvar  i;
     for (i = 0; i < SM_MAX; i = i + 1)
     begin : g11
       assign active_l1_miss[i] = ~miss_ci_l2[i] & ~miss_tid_sm_l2[i][IDLE] & ~miss_tid_sm_l2[i][WAITMISS] & ~(miss_tid_sm_l2[i][CHECK_ECC] & ~ecc_err[i]);
     end

     genvar  t;
     for (t = 0; t < `THREADS; t = t + 1)
     begin : gen_perf
       assign perf_event_d[t][0] = active_l1_miss[2*t] | (active_l1_miss[2*t+1] & ~miss_prefetch_perf_l2[t]);

       assign perf_event_d[t][1] =
	 (~miss_ci_l2[2*t]   & miss_flushed_l2[2*t]   & (miss_tid_sm_l2[2*t][CHECK_ECC]   & ~ecc_err[2*t])) |
	 (~miss_ci_l2[2*t+1] & miss_flushed_l2[2*t+1] & (miss_tid_sm_l2[2*t+1][CHECK_ECC] & ~ecc_err[2*t+1]));

       assign perf_event_d[t][2] = active_l1_miss[2*t+1] & miss_prefetch_perf_l2[t];
     end
   end
   endgenerate

   assign ic_perf_t0_event = perf_event_l2[0];
 `ifndef THREADS1
     assign ic_perf_t1_event = perf_event_l2[1];
 `endif


   tri_rlmlatch_p #(.INIT(0)) spr_ic_cls_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[spr_ic_cls_offset]),
      .scout(sov[spr_ic_cls_offset]),
      .din(spr_ic_cls_d),
      .dout(spr_ic_cls_l2)
      );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) bp_config_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[bp_config_offset:bp_config_offset + 4 - 1]),
      .scout(sov[bp_config_offset:bp_config_offset + 4 - 1]),
      .din(bp_config_d),
      .dout(bp_config_l2)
      );

   tri_rlmlatch_p #(.INIT(0)) an_ac_reld_data_vld_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[an_ac_reld_data_vld_offset]),
      .scout(sov[an_ac_reld_data_vld_offset]),
      .din(an_ac_reld_data_vld_d),
      .dout(an_ac_reld_data_vld_l2)
      );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0)) an_ac_reld_core_tag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[an_ac_reld_core_tag_offset:an_ac_reld_core_tag_offset + 5 - 1]),
      .scout(sov[an_ac_reld_core_tag_offset:an_ac_reld_core_tag_offset + 5 - 1]),
      .din(an_ac_reld_core_tag_d),
      .dout(an_ac_reld_core_tag_l2)
      );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) an_ac_reld_qw_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[an_ac_reld_qw_offset:an_ac_reld_qw_offset + 2 - 1]),
      .scout(sov[an_ac_reld_qw_offset:an_ac_reld_qw_offset + 2 - 1]),
      .din(an_ac_reld_qw_d),
      .dout(an_ac_reld_qw_l2)
      );

   tri_rlmreg_p #(.WIDTH(TAGS_USED), .INIT(0)) reld_r1_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[reld_r1_val_offset:reld_r1_val_offset + TAGS_USED - 1]),
      .scout(sov[reld_r1_val_offset:reld_r1_val_offset + TAGS_USED - 1]),
      .din(reld_r1_val_d),
      .dout(reld_r1_val_l2[0:TAGS_USED - 1])
      );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) reld_r1_qw_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[reld_r1_qw_offset:reld_r1_qw_offset + 2 - 1]),
      .scout(sov[reld_r1_qw_offset:reld_r1_qw_offset + 2 - 1]),
      .din(reld_r1_qw_d),
      .dout(reld_r1_qw_l2)
      );

   tri_rlmreg_p #(.WIDTH(128), .INIT(0)) reld_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(reld_r2_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[reld_data_offset:reld_data_offset + 128 - 1]),
      .scout(sov[reld_data_offset:reld_data_offset + 128 - 1]),
      .din(reld_data_d),
      .dout(reld_data_l2)
      );

   tri_rlmreg_p #(.WIDTH(TAGS_USED), .INIT(0)) reld_r2_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[reld_r2_val_offset:reld_r2_val_offset + TAGS_USED - 1]),
      .scout(sov[reld_r2_val_offset:reld_r2_val_offset + TAGS_USED - 1]),
      .din(reld_r2_val_d),
      .dout(reld_r2_val_l2)
      );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) reld_r2_qw_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(reld_r2_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[reld_r2_qw_offset:reld_r2_qw_offset + 2 - 1]),
      .scout(sov[reld_r2_qw_offset:reld_r2_qw_offset + 2 - 1]),
      .din(reld_r2_qw_d),
      .dout(reld_r2_qw_l2)
      );

   tri_rlmlatch_p #(.INIT(0)) r2_crit_qw_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[r2_crit_qw_offset]),
      .scout(sov[r2_crit_qw_offset]),
      .din(r2_crit_qw_d),
      .dout(r2_crit_qw_l2)
      );

   tri_rlmreg_p #(.WIDTH(TAGS_USED), .INIT(0)) reld_r3_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[reld_r3_val_offset:reld_r3_val_offset + TAGS_USED - 1]),
      .scout(sov[reld_r3_val_offset:reld_r3_val_offset + TAGS_USED - 1]),
      .din(reld_r3_val_d),
      .dout(reld_r3_val_l2)
      );

   tri_rlmlatch_p #(.INIT(0)) r3_loaded_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[r3_loaded_offset]),
      .scout(sov[r3_loaded_offset]),
      .din(r3_loaded_d),
      .dout(r3_loaded_l2)
      );

   tri_rlmlatch_p #(.INIT(0)) an_ac_reld_ecc_err_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[an_ac_reld_ecc_err_offset]),
      .scout(sov[an_ac_reld_ecc_err_offset]),
      .din(an_ac_reld_ecc_err_d),
      .dout(an_ac_reld_ecc_err_l2)
      );

   tri_rlmlatch_p #(.INIT(0)) an_ac_reld_ecc_err_ue_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[an_ac_reld_ecc_err_ue_offset]),
      .scout(sov[an_ac_reld_ecc_err_ue_offset]),
      .din(an_ac_reld_ecc_err_ue_d),
      .dout(an_ac_reld_ecc_err_ue_l2)
      );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) request_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(miss_or_default_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[request_offset:request_offset + `THREADS - 1]),
      .scout(sov[request_offset:request_offset + `THREADS - 1]),
      .din(request_d),
      .dout(request_l2)
      );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) req_ctag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(icd_icm_any_iu2_valid),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[req_ctag_offset:req_ctag_offset + 2 - 1]),
      .scout(sov[req_ctag_offset:req_ctag_offset + 2 - 1]),
      .din(req_ctag_d),
      .dout(req_ctag_l2)
      );

   tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH-4), .INIT(0)) req_ra_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(icd_icm_any_iu2_valid),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[req_ra_offset:req_ra_offset + (`REAL_IFAR_WIDTH-4) - 1]),
      .scout(sov[req_ra_offset:req_ra_offset + (`REAL_IFAR_WIDTH-4) - 1]),
      .din(req_ra_d),
      .dout(req_ra_l2)
      );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0)) req_wimge_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(icd_icm_any_iu2_valid),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[req_wimge_offset:req_wimge_offset + 5 - 1]),
      .scout(sov[req_wimge_offset:req_wimge_offset + 5 - 1]),
      .din(req_wimge_d),
      .dout(req_wimge_l2)
      );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) req_userdef_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(icd_icm_any_iu2_valid),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[req_userdef_offset:req_userdef_offset + 4 - 1]),
      .scout(sov[req_userdef_offset:req_userdef_offset + 4 - 1]),
      .din(req_userdef_d),
      .dout(req_userdef_l2)
      );

   tri_rlmlatch_p #(.INIT(0)) iu3_miss_match_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(icd_icm_any_iu2_valid),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[iu3_miss_match_offset]),
      .scout(sov[iu3_miss_match_offset]),
      .din(iu3_miss_match_d),
      .dout(iu3_miss_match_l2)
      );

   generate
   begin : xhdl21
     genvar  i;
     for (i = 0; i < TAGS_USED; i = i + 1)
     begin : gen_sm

       tri_rlmreg_p #(.WIDTH(CHECK_ECC+1), .INIT({1'b1, {CHECK_ECC{1'b0}} })) miss_tid_sm_latch(
          .vd(vdd),
          .gd(gnd),
          .nclk(nclk),
          .act(miss_or_default_act),
          .thold_b(pc_iu_func_sl_thold_0_b),
          .sg(pc_iu_sg_0),
          .force_t(force_t),
          .delay_lclkr(delay_lclkr),
          .mpw1_b(mpw1_b),
          .mpw2_b(mpw2_b),
          .d_mode(d_mode),
          .scin(siv[miss_tid_sm_offset + i * (CHECK_ECC+1):miss_tid_sm_offset + (i + 1) * (CHECK_ECC+1) - 1]),
          .scout(sov[miss_tid_sm_offset + i * (CHECK_ECC+1):miss_tid_sm_offset + (i + 1) * (CHECK_ECC+1) - 1]),
          .din(miss_tid_sm_d[i]),
          .dout(miss_tid_sm_l2[i])
          );

       tri_rlmreg_p #(.WIDTH(3), .INIT(0)) miss_count_latch(
          .vd(vdd),
          .gd(gnd),
          .nclk(nclk),
          .act(miss_or_default_act),
          .thold_b(pc_iu_func_sl_thold_0_b),
          .sg(pc_iu_sg_0),
          .force_t(force_t),
          .delay_lclkr(delay_lclkr),
          .mpw1_b(mpw1_b),
          .mpw2_b(mpw2_b),
          .d_mode(d_mode),
          .scin(siv[miss_count_offset + i * 3:miss_count_offset + (i + 1) * 3 - 1]),
          .scout(sov[miss_count_offset + i * 3:miss_count_offset + (i + 1) * 3 - 1]),
          .din(miss_count_d[i]),
          .dout(miss_count_l2[i])
          );
     end
   end
   endgenerate

   tri_rlmreg_p #(.WIDTH(TAGS_USED), .INIT(0)) miss_flush_occurred_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[miss_flush_occurred_offset:miss_flush_occurred_offset + TAGS_USED - 1]),
      .scout(sov[miss_flush_occurred_offset:miss_flush_occurred_offset + TAGS_USED - 1]),
      .din(miss_flush_occurred_d),
      .dout(miss_flush_occurred_l2)
      );

   tri_rlmreg_p #(.WIDTH(TAGS_USED), .INIT(0)) miss_flushed_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[miss_flushed_offset:miss_flushed_offset + TAGS_USED - 1]),
      .scout(sov[miss_flushed_offset:miss_flushed_offset + TAGS_USED - 1]),
      .din(miss_flushed_d[0:TAGS_USED - 1]),
      .dout(miss_flushed_l2[0:TAGS_USED - 1])
      );

   tri_rlmreg_p #(.WIDTH(TAGS_USED), .INIT(0)) miss_inval_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[miss_inval_offset:miss_inval_offset + TAGS_USED - 1]),
      .scout(sov[miss_inval_offset:miss_inval_offset + TAGS_USED - 1]),
      .din(miss_inval_d[0:TAGS_USED - 1]),
      .dout(miss_inval_l2[0:TAGS_USED - 1])
      );

   tri_rlmreg_p #(.WIDTH(TAGS_USED), .INIT(0)) miss_block_fp_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(miss_or_default_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[miss_block_fp_offset:miss_block_fp_offset + TAGS_USED - 1]),
      .scout(sov[miss_block_fp_offset:miss_block_fp_offset + TAGS_USED - 1]),
      .din(miss_block_fp_d),
      .dout(miss_block_fp_l2)
      );

   tri_rlmreg_p #(.WIDTH(TAGS_USED), .INIT(0)) miss_ecc_err_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[miss_ecc_err_offset:miss_ecc_err_offset + TAGS_USED - 1]),
      .scout(sov[miss_ecc_err_offset:miss_ecc_err_offset + TAGS_USED - 1]),
      .din(miss_ecc_err_d),
      .dout(miss_ecc_err_l2)
      );

   tri_rlmreg_p #(.WIDTH(TAGS_USED), .INIT(0)) miss_ecc_err_ue_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[miss_ecc_err_ue_offset:miss_ecc_err_ue_offset + TAGS_USED - 1]),
      .scout(sov[miss_ecc_err_ue_offset:miss_ecc_err_ue_offset + TAGS_USED - 1]),
      .din(miss_ecc_err_ue_d),
      .dout(miss_ecc_err_ue_l2)
      );

   tri_rlmreg_p #(.WIDTH(TAGS_USED), .INIT(0), .NEEDS_SRESET(1)) miss_wrote_dir_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[miss_wrote_dir_offset:miss_wrote_dir_offset + TAGS_USED - 1]),
      .scout(sov[miss_wrote_dir_offset:miss_wrote_dir_offset + TAGS_USED - 1]),
      .din(miss_wrote_dir_d),
      .dout(miss_wrote_dir_l2)
      );

   tri_rlmreg_p #(.WIDTH(TAGS_USED), .INIT(0), .NEEDS_SRESET(1)) miss_need_hold_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(miss_or_default_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[miss_need_hold_offset:miss_need_hold_offset + TAGS_USED - 1]),
      .scout(sov[miss_need_hold_offset:miss_need_hold_offset + TAGS_USED - 1]),
      .din(miss_need_hold_d),
      .dout(miss_need_hold_l2)
      );

   generate
   begin : xhdl22
     genvar  i;
     for (i = 0; i < TAGS_USED; i = i + 1)
     begin : gen
       tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH - 2), .INIT(0)) miss_addr_real_latch(
          .vd(vdd),
          .gd(gnd),
          .nclk(nclk),
          .act(miss_act[i]),
          .thold_b(pc_iu_func_sl_thold_0_b),
          .sg(pc_iu_sg_0),
          .force_t(force_t),
          .delay_lclkr(delay_lclkr),
          .mpw1_b(mpw1_b),
          .mpw2_b(mpw2_b),
          .d_mode(d_mode),
          .scin(siv[miss_addr_real_offset + i * (`REAL_IFAR_WIDTH - 2):miss_addr_real_offset + (i + 1) * (`REAL_IFAR_WIDTH - 2) - 1]),
          .scout(sov[miss_addr_real_offset + i * (`REAL_IFAR_WIDTH - 2):miss_addr_real_offset + (i + 1) * (`REAL_IFAR_WIDTH - 2) - 1]),
          .din(miss_addr_real_d[i]),
          .dout(miss_addr_real_l2[i])
          );

       tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH - 10), .INIT(0)) miss_addr_eff_latch(
          .vd(vdd),
          .gd(gnd),
          .nclk(nclk),
          .act(miss_act[i]),
          .thold_b(pc_iu_func_sl_thold_0_b),
          .sg(pc_iu_sg_0),
          .force_t(force_t),
          .delay_lclkr(delay_lclkr),
          .mpw1_b(mpw1_b),
          .mpw2_b(mpw2_b),
          .d_mode(d_mode),
          .scin(siv[miss_addr_eff_offset + i * (`EFF_IFAR_WIDTH - 10):miss_addr_eff_offset + (i + 1) * (`EFF_IFAR_WIDTH - 10) - 1]),
          .scout(sov[miss_addr_eff_offset + i * (`EFF_IFAR_WIDTH - 10):miss_addr_eff_offset + (i + 1) * (`EFF_IFAR_WIDTH - 10) - 1]),
          .din(miss_addr_eff_d[i]),
          .dout(miss_addr_eff_l2[i])
          );

      tri_rlmlatch_p #(.INIT(0)) miss_ci_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(miss_act[i]),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[miss_ci_offset + i]),
         .scout(sov[miss_ci_offset + i]),
         .din(miss_ci_d[i]),
         .dout(miss_ci_l2[i])
         );

      tri_rlmlatch_p #(.INIT(0)) miss_endian_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(miss_act[i]),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[miss_endian_offset + i]),
         .scout(sov[miss_endian_offset + i]),
         .din(miss_endian_d[i]),
         .dout(miss_endian_l2[i])
         );

      tri_rlmlatch_p #(.INIT(0)) miss_2ucode_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(miss_act[i]),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[miss_2ucode_offset + i]),
         .scout(sov[miss_2ucode_offset + i]),
         .din(miss_2ucode_d[i]),
         .dout(miss_2ucode_l2[i])
         );

      tri_rlmlatch_p #(.INIT(0)) miss_2ucode_type_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(miss_act[i]),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[miss_2ucode_type_offset + i]),
         .scout(sov[miss_2ucode_type_offset + i]),
         .din(miss_2ucode_type_d[i]),
         .dout(miss_2ucode_type_l2[i])
         );

      tri_rlmreg_p #(.WIDTH(4), .INIT(0)) miss_way_latch(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(reld_r2_act),
         .thold_b(pc_iu_func_sl_thold_0_b),
         .sg(pc_iu_sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[miss_way_offset + i * 4:miss_way_offset + (i + 1) * 4 - 1]),
         .scout(sov[miss_way_offset + i * 4:miss_way_offset + (i + 1) * 4 - 1]),
         .din(miss_way_d[i]),
         .dout(miss_way_l2[i])
         );
     end
   end
   endgenerate

   tri_rlmreg_p #(.WIDTH(TAGS_USED), .INIT(0)) lru_write_next_cycle_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[lru_write_next_cycle_offset:lru_write_next_cycle_offset + TAGS_USED - 1]),
      .scout(sov[lru_write_next_cycle_offset:lru_write_next_cycle_offset + TAGS_USED - 1]),
      .din(lru_write_next_cycle_d),
      .dout(lru_write_next_cycle_l2)
     );

   tri_rlmreg_p #(.WIDTH(TAGS_USED), .INIT(0)) lru_write_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(default_reld_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[lru_write_offset:lru_write_offset + TAGS_USED - 1]),
      .scout(sov[lru_write_offset:lru_write_offset + TAGS_USED - 1]),
      .din(lru_write_d),
      .dout(lru_write_l2)
     );

   generate
   begin : xhdl23
      genvar  i;
      for (i = 0; i < `THREADS; i = i + 1)
      begin : t
        tri_rlmreg_p #(.WIDTH(3), .INIT(0)) perf_event_latch(
           .vd(vdd),
           .gd(gnd),
           .nclk(nclk),
           .act(event_bus_enable),
           .thold_b(pc_iu_func_sl_thold_0_b),
           .sg(pc_iu_sg_0),
           .force_t(force_t),
           .delay_lclkr(delay_lclkr),
           .mpw1_b(mpw1_b),
           .mpw2_b(mpw2_b),
           .d_mode(d_mode),
           .scin(siv[perf_event_offset + i * 3:perf_event_offset + (i+1) * 3 - 1]),
           .scout(sov[perf_event_offset + i * 3:perf_event_offset + (i+1) * 3 - 1]),
           .din(perf_event_d[i]),
           .dout(perf_event_l2[i])
          );
      end
   end
   endgenerate

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) miss_prefetch_perf_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(event_bus_enable),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[miss_prefetch_perf_offset:miss_prefetch_perf_offset + `THREADS - 1]),
      .scout(sov[miss_prefetch_perf_offset:miss_prefetch_perf_offset + `THREADS - 1]),
      .din(miss_prefetch_perf_d),
      .dout(miss_prefetch_perf_l2)
     );

   assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
   assign scan_out = sov[0];

endmodule

