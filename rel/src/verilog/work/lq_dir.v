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

//  Description:  XU LSU L1 Data Directory Wrapper
//*****************************************************************************

// ##########################################################################################
// VHDL Contents
// 1) L1 D$ Directory Array
// 2) Valid Register Array
// 3) LRU Register Array
// 4) Data Cache Control
// 5) Flush Generation
// 6) 8 way tag compare
// 7) Parity Check
// 8) Reload Update
// ##########################################################################################

`include "tri_a2o.vh"



module lq_dir(
   dcc_dir_ex2_stg_act,
   dcc_dir_ex3_stg_act,
   dcc_dir_ex4_stg_act,
   dcc_dir_ex5_stg_act,
   dcc_dir_stq1_stg_act,
   dcc_dir_stq2_stg_act,
   dcc_dir_stq3_stg_act,
   dcc_dir_stq4_stg_act,
   dcc_dir_stq5_stg_act,
   dcc_dir_binv2_ex2_stg_act,
   dcc_dir_binv3_ex3_stg_act,
   dcc_dir_binv4_ex4_stg_act,
   dcc_dir_binv5_ex5_stg_act,
   dcc_dir_binv6_ex6_stg_act,
   byp_dir_ex2_rs1,
   byp_dir_ex2_rs2,
   dcc_dir_ex2_64bit_agen,
   pc_lq_inj_dcachedir_ldp_parity,
   pc_lq_inj_dcachedir_ldp_multihit,
   pc_lq_inj_dcachedir_stp_parity,
   pc_lq_inj_dcachedir_stp_multihit,
   dcc_dir_ex2_binv_val,
   dcc_dir_ex2_thrd_id,
   dcc_dir_ex3_cache_acc,
   dcc_dir_ex3_pfetch_val,
   dcc_dir_ex3_lru_upd,
   dcc_dir_ex3_lock_set,
   dcc_dir_ex3_th_c,
   dcc_dir_ex3_watch_set,
   dcc_dir_ex3_larx_val,
   dcc_dir_ex3_watch_chk,
   dcc_dir_ex3_ddir_acc,
   dcc_dir_ex4_load_val,
   dcc_dir_ex4_p_addr,
   derat_dir_ex4_wimge_i,
   dcc_dir_stq6_store_val,
   dat_ctl_dcarr_perr_way,
   xu_lq_spr_xucr0_wlk,
   xu_lq_spr_xucr0_dcdis,
   xu_lq_spr_xucr0_clfc,
   xu_lq_spr_xucr0_cls,
   dcc_dir_spr_xucr2_rmt,
   dcc_dir_ex2_frc_align16,
   dcc_dir_ex2_frc_align8,
   dcc_dir_ex2_frc_align4,
   dcc_dir_ex2_frc_align2,
   lsq_ctl_stq1_val,
   lsq_ctl_stq2_blk_req,
   lsq_ctl_stq1_thrd_id,
   lsq_ctl_rel1_thrd_id,
   lsq_ctl_stq1_store_val,
   lsq_ctl_stq1_ci,
   lsq_ctl_stq1_lock_clr,
   lsq_ctl_stq1_watch_clr,
   lsq_ctl_stq1_l_fld,
   lsq_ctl_stq1_inval,
   lsq_ctl_stq1_dci_val,
   lsq_ctl_stq1_addr,
   lsq_ctl_rel1_clr_val,
   lsq_ctl_rel1_set_val,
   lsq_ctl_rel1_data_val,
   lsq_ctl_rel1_back_inv,
   lsq_ctl_rel2_blk_req,
   lsq_ctl_rel1_tag,
   lsq_ctl_rel1_classid,
   lsq_ctl_rel1_lock_set,
   lsq_ctl_rel1_watch_set,
   lsq_ctl_rel2_upd_val,
   lsq_ctl_rel3_l1dump_val,
   lsq_ctl_rel3_clr_relq,
   ctl_lsq_stq4_perr_reject,
   ctl_dat_stq5_way_perr_inval,
   fgen_ex3_stg_flush,
   fgen_ex4_cp_flush,
   fgen_ex4_stg_flush,
   fgen_ex5_stg_flush,
   dir_arr_rd_addr0_01,
   dir_arr_rd_addr0_23,
   dir_arr_rd_addr0_45,
   dir_arr_rd_addr0_67,
   dir_arr_rd_data0,
   dir_arr_rd_data1,
   dir_arr_wr_enable,
   dir_arr_wr_way,
   dir_arr_wr_addr,
   dir_arr_wr_data,
   dir_dcc_ex2_eff_addr,
   dir_derat_ex2_eff_addr,
   dir_dcc_ex4_hit,
   dir_dcc_ex4_miss,
   ctl_dat_ex4_way_hit,
   dir_dcc_stq3_hit,
   dir_dcc_ex5_cr_rslt,
   ctl_perv_dir_perf_events,
   dir_dcc_rel3_dcarr_upd,
   dir_dec_rel3_dir_wr_val,
   dir_dec_rel3_dir_wr_addr,
   stq4_dcarr_way_en,
   lq_xu_spr_xucr0_cslc_xuop,
   lq_xu_spr_xucr0_cslc_binv,
   lq_xu_spr_xucr0_clo,
   dir_dcc_ex4_way_tag_a,
   dir_dcc_ex4_way_tag_b,
   dir_dcc_ex4_way_tag_c,
   dir_dcc_ex4_way_tag_d,
   dir_dcc_ex4_way_tag_e,
   dir_dcc_ex4_way_tag_f,
   dir_dcc_ex4_way_tag_g,
   dir_dcc_ex4_way_tag_h,
   dir_dcc_ex4_way_par_a,
   dir_dcc_ex4_way_par_b,
   dir_dcc_ex4_way_par_c,
   dir_dcc_ex4_way_par_d,
   dir_dcc_ex4_way_par_e,
   dir_dcc_ex4_way_par_f,
   dir_dcc_ex4_way_par_g,
   dir_dcc_ex4_way_par_h,
   dir_dcc_ex5_way_a_dir,
   dir_dcc_ex5_way_b_dir,
   dir_dcc_ex5_way_c_dir,
   dir_dcc_ex5_way_d_dir,
   dir_dcc_ex5_way_e_dir,
   dir_dcc_ex5_way_f_dir,
   dir_dcc_ex5_way_g_dir,
   dir_dcc_ex5_way_h_dir,
   dir_dcc_ex5_dir_lru,
   dir_dcc_ex4_set_rel_coll,
   dir_dcc_ex4_byp_restart,
   dir_dcc_ex5_dir_perr_det,
   dir_dcc_ex5_dc_perr_det,
   dir_dcc_ex5_dir_perr_flush,
   dir_dcc_ex5_dc_perr_flush,
   dir_dcc_ex5_multihit_det,
   dir_dcc_ex5_multihit_flush,
   dir_dcc_stq4_dir_perr_det,
   dir_dcc_stq4_multihit_det,
   dir_dcc_ex5_stp_flush,
   vdd,
   gnd,
   nclk,
   sg_0,
   func_sl_thold_0_b,
   func_sl_force,
   func_slp_sl_thold_0_b,
   func_slp_sl_force,
   func_nsl_thold_0_b,
   func_nsl_force,
   func_slp_nsl_thold_0_b,
   func_slp_nsl_force,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   scan_in,
   scan_out
);

//-------------------------------------------------------------------
// Generics
//-------------------------------------------------------------------
//parameter                                                    EXPAND_TYPE = 2;
//parameter                                                    THREADS = 2;
//parameter                                                    ITAG_SIZE_ENC = 7;
//parameter                                                    DC_SIZE = 15;		// 14 => 16K L1D$, 15 => 32K L1D$
//parameter                                                    CL_SIZE = 6;		// 6 => 64B CLINE, 7 => 128B CLINE
//parameter                                                    LMQ_ENTRIES = 8;
//parameter                                                    CR_POOL_ENC = 5;
//parameter                                                    UCODE_ENTRIES_ENC = 3;
//parameter                                                    REAL_IFAR_WIDTH = 42;
//parameter                                                    `GPR_WIDTH_ENC = 6;
parameter                                                    WAYDATASIZE = 34;		// TagSize + Parity Bits
parameter                                                    PARBITS = 4;

// ACT's
input                                                        dcc_dir_ex2_stg_act;
input                                                        dcc_dir_ex3_stg_act;
input                                                        dcc_dir_ex4_stg_act;
input                                                        dcc_dir_ex5_stg_act;
input                                                        dcc_dir_stq1_stg_act;
input                                                        dcc_dir_stq2_stg_act;
input                                                        dcc_dir_stq3_stg_act;
input                                                        dcc_dir_stq4_stg_act;
input                                                        dcc_dir_stq5_stg_act;
input                                                        dcc_dir_binv2_ex2_stg_act;
input                                                        dcc_dir_binv3_ex3_stg_act;
input                                                        dcc_dir_binv4_ex4_stg_act;
input                                                        dcc_dir_binv5_ex5_stg_act;
input                                                        dcc_dir_binv6_ex6_stg_act;

// AGEN Sources
input [64-(2**`GPR_WIDTH_ENC):63]                            byp_dir_ex2_rs1;
input [64-(2**`GPR_WIDTH_ENC):63]                            byp_dir_ex2_rs2;
input                                                        dcc_dir_ex2_64bit_agen;

// Error Inject
input                                                        pc_lq_inj_dcachedir_ldp_parity;
input                                                        pc_lq_inj_dcachedir_ldp_multihit;
input                                                        pc_lq_inj_dcachedir_stp_parity;
input                                                        pc_lq_inj_dcachedir_stp_multihit;

input                                                        dcc_dir_ex2_binv_val;		// Back-Invalidate is Valid
input [0:`THREADS-1]                                         dcc_dir_ex2_thrd_id;		// Thread ID
input                                                        dcc_dir_ex3_cache_acc;		// Cache Access is Valid
input                                                        dcc_dir_ex3_pfetch_val;
input                                                        dcc_dir_ex3_lru_upd;		// Dont update LRU indicator
input                                                        dcc_dir_ex3_lock_set;		// DCBT[ST]LS Operation is valid
input                                                        dcc_dir_ex3_th_c;		   // DCBT[ST]LS Operation is targeting the L1 Data Cache
input                                                        dcc_dir_ex3_watch_set;		// LDAWX Operation is valid
input                                                        dcc_dir_ex3_larx_val;		// LARX Operation is valid, the directory should be invalidated if hit
input                                                        dcc_dir_ex3_watch_chk;		// WCHK Operation is valid
input                                                        dcc_dir_ex3_ddir_acc;		// Directory Access is valid
input                                                        dcc_dir_ex4_load_val;
input [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                  dcc_dir_ex4_p_addr;
input                                                        derat_dir_ex4_wimge_i;		// Cache-Inhibited Request
input                                                        dcc_dir_stq6_store_val;

input [0:7]                                                  dat_ctl_dcarr_perr_way;		// Data Cache Parity on a Way

input                                                        xu_lq_spr_xucr0_wlk;
input                                                        xu_lq_spr_xucr0_dcdis;
input                                                        xu_lq_spr_xucr0_clfc;
input                                                        xu_lq_spr_xucr0_cls;		// Cacheline Size = 1 => 128Byte size, 0 => 64Byte size
input [0:31]                                                 dcc_dir_spr_xucr2_rmt;
input                                                        dcc_dir_ex2_frc_align16;
input                                                        dcc_dir_ex2_frc_align8;
input                                                        dcc_dir_ex2_frc_align4;
input                                                        dcc_dir_ex2_frc_align2;

// RELOAD/RECIRC Control
input                                                        lsq_ctl_stq1_val;
input                                                        lsq_ctl_stq2_blk_req;		// Block Store due to RV issue
input [0:`THREADS-1]                                         lsq_ctl_stq1_thrd_id;
input [0:`THREADS-1]                                         lsq_ctl_rel1_thrd_id;
input                                                        lsq_ctl_stq1_store_val;	// Recir Store instruction
input                                                        lsq_ctl_stq1_ci;
input                                                        lsq_ctl_stq1_lock_clr;		// Recirc Lock Clear instruction
input                                                        lsq_ctl_stq1_watch_clr;	// Recirc Watch Clear instruction
input [0:1]                                                  lsq_ctl_stq1_l_fld;		   // Recirc Watch Clear L-Field
input                                                        lsq_ctl_stq1_inval;		   // Recirc Invalidate instruction
input                                                        lsq_ctl_stq1_dci_val;		// Recirc DCI instruction
input [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                      lsq_ctl_stq1_addr;
input                                                        lsq_ctl_rel1_clr_val;		// Reload data is valid for 1st beat
input                                                        lsq_ctl_rel1_set_val;		// Reload data is valid for last beat
input                                                        lsq_ctl_rel1_data_val;		// Reload data is valid
input                                                        lsq_ctl_rel1_back_inv;		// Reload was Back-Invalidated
input                                                        lsq_ctl_rel2_blk_req;		// Block Reload due to RV issue or Back-Invalidate
input [0:3]                                                  lsq_ctl_rel1_tag;		   // Reload Tag
input [0:1]                                                  lsq_ctl_rel1_classid;
input                                                        lsq_ctl_rel1_lock_set;		// Reload/Recirc Lock Set instruction
input                                                        lsq_ctl_rel1_watch_set;	// Reload/Recirc Watch Set instruction
input                                                        lsq_ctl_rel2_upd_val;		// No ECC Errors were detected
input                                                        lsq_ctl_rel3_l1dump_val;	// Reload Complete for an L1_DUMP reload
input                                                        lsq_ctl_rel3_clr_relq;		// Reload Complete due to an ECC error
output                                                       ctl_lsq_stq4_perr_reject; // STQ4 parity error detected, reject STQ2 Commit
output [0:7]                                                 ctl_dat_stq5_way_perr_inval;

// Instruction Flush
input                                                        fgen_ex3_stg_flush;
input                                                        fgen_ex4_cp_flush;
input                                                        fgen_ex4_stg_flush;
input                                                        fgen_ex5_stg_flush;

// Directory Read Interface
output [64-(`DC_SIZE-3):63-`CL_SIZE]                         dir_arr_rd_addr0_01;
output [64-(`DC_SIZE-3):63-`CL_SIZE]                         dir_arr_rd_addr0_23;
output [64-(`DC_SIZE-3):63-`CL_SIZE]                         dir_arr_rd_addr0_45;
output [64-(`DC_SIZE-3):63-`CL_SIZE]                         dir_arr_rd_addr0_67;
input [0:(8*WAYDATASIZE)-1]                                  dir_arr_rd_data0;
input [0:(8*WAYDATASIZE)-1]                                  dir_arr_rd_data1;

// Directory Write Interface
output [0:3]                                                 dir_arr_wr_enable;
output [0:7]                                                 dir_arr_wr_way;
output [64-(`DC_SIZE-3):63-`CL_SIZE]                         dir_arr_wr_addr;
output [64-`REAL_IFAR_WIDTH:64-`REAL_IFAR_WIDTH+WAYDATASIZE-1] dir_arr_wr_data;

// LQ Pipe Outputs
output [64-(2**`GPR_WIDTH_ENC):63]                           dir_dcc_ex2_eff_addr;
output [0:51]                                                dir_derat_ex2_eff_addr;
output                                                       dir_dcc_ex4_hit;
output                                                       dir_dcc_ex4_miss;
output [0:7]                                                 ctl_dat_ex4_way_hit;		   // Way Hit

// COMMIT Pipe Hit indicator
output                                                       dir_dcc_stq3_hit;

// CR results
output                                                       dir_dcc_ex5_cr_rslt;		   // Condition Register Results from Watch instructions

// Performance Events
output [0:(`THREADS*3)+1]                                    ctl_perv_dir_perf_events;

// Data Array Controls
output                                                       dir_dcc_rel3_dcarr_upd;		// Reload Data Array Update Valid
output                                                       dir_dec_rel3_dir_wr_val;     // Reload Directory Write Stage is valid
output [64-(`DC_SIZE-3):63-`CL_SIZE]                         dir_dec_rel3_dir_wr_addr;    // Reload Directory Write Address
output [0:7]                                                 stq4_dcarr_way_en;

// SPR status
output                                                       lq_xu_spr_xucr0_cslc_xuop;   // Invalidate type instruction invalidated lock
output                                                       lq_xu_spr_xucr0_cslc_binv;   // Back-Invalidate invalidated lock
output                                                       lq_xu_spr_xucr0_clo;		   // Cache Lock instruction caused an overlock

// L1 Directory Contents
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 dir_dcc_ex4_way_tag_a;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 dir_dcc_ex4_way_tag_b;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 dir_dcc_ex4_way_tag_c;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 dir_dcc_ex4_way_tag_d;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 dir_dcc_ex4_way_tag_e;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 dir_dcc_ex4_way_tag_f;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 dir_dcc_ex4_way_tag_g;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                 dir_dcc_ex4_way_tag_h;
output [0:PARBITS-1]                                         dir_dcc_ex4_way_par_a;
output [0:PARBITS-1]                                         dir_dcc_ex4_way_par_b;
output [0:PARBITS-1]                                         dir_dcc_ex4_way_par_c;
output [0:PARBITS-1]                                         dir_dcc_ex4_way_par_d;
output [0:PARBITS-1]                                         dir_dcc_ex4_way_par_e;
output [0:PARBITS-1]                                         dir_dcc_ex4_way_par_f;
output [0:PARBITS-1]                                         dir_dcc_ex4_way_par_g;
output [0:PARBITS-1]                                         dir_dcc_ex4_way_par_h;
output [0:1+`THREADS]                                        dir_dcc_ex5_way_a_dir;
output [0:1+`THREADS]                                        dir_dcc_ex5_way_b_dir;
output [0:1+`THREADS]                                        dir_dcc_ex5_way_c_dir;
output [0:1+`THREADS]                                        dir_dcc_ex5_way_d_dir;
output [0:1+`THREADS]                                        dir_dcc_ex5_way_e_dir;
output [0:1+`THREADS]                                        dir_dcc_ex5_way_f_dir;
output [0:1+`THREADS]                                        dir_dcc_ex5_way_g_dir;
output [0:1+`THREADS]                                        dir_dcc_ex5_way_h_dir;
output [0:6]                                                 dir_dcc_ex5_dir_lru;

// Reject Cases
output                                                       dir_dcc_ex4_set_rel_coll;		// Resource Conflict, should cause a reject
output                                                       dir_dcc_ex4_byp_restart;		// Directory Bypassed stage that was restarted
output                                                       dir_dcc_ex5_dir_perr_det;		// Parity Error Detected
output                                                       dir_dcc_ex5_dc_perr_det;		// Data Cache Parity Error Detected
output                                                       dir_dcc_ex5_dir_perr_flush;	// Data Directory Parity Error Flush
output                                                       dir_dcc_ex5_dc_perr_flush;	// Data Cache Parity Error Flush
output                                                       dir_dcc_ex5_multihit_det;		// Directory Multihit Detected
output                                                       dir_dcc_ex5_multihit_flush;	// Directory Multihit Flush
output                                                       dir_dcc_stq4_dir_perr_det;	// Data Cache Parity Error Detected on the STQ Commit Pipeline
output                                                       dir_dcc_stq4_multihit_det;	// Directory Multihit Detected on the STQ Commit Pipeline
output                                                       dir_dcc_ex5_stp_flush;       // Directory Error detected on the STQ Commit Pipeline with EX5 LDP valid


inout                                                        vdd;


inout                                                        gnd;

(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

input [0:`NCLK_WIDTH-1]                                      nclk;
input                                                        sg_0;
input                                                        func_sl_thold_0_b;
input                                                        func_sl_force;
input                                                        func_slp_sl_thold_0_b;
input                                                        func_slp_sl_force;
input                                                        func_nsl_thold_0_b;
input                                                        func_nsl_force;
input                                                        func_slp_nsl_thold_0_b;
input                                                        func_slp_nsl_force;
input                                                        d_mode_dc;
input                                                        delay_lclkr_dc;
input                                                        mpw1_dc_b;
input                                                        mpw2_dc_b;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input [0:4]                                                  scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output [0:4]                                                 scan_out;

//--------------------------
// components
//--------------------------

//--------------------------
// signals
//--------------------------
wire [64-(2**`GPR_WIDTH_ENC):63]                             ex2_eff_addr;
wire [60:63]                                                 ex2_lwr_p_addr;
wire                                                         rel4_dir_wr_val_d;
wire                                                         rel4_dir_wr_val_q;
wire                                                         rel_way_val_a;
wire                                                         rel_way_val_b;
wire                                                         rel_way_val_c;
wire                                                         rel_way_val_d;
wire                                                         rel_way_val_e;
wire                                                         rel_way_val_f;
wire                                                         rel_way_val_g;
wire                                                         rel_way_val_h;
wire                                                         rel_way_lock_a;
wire                                                         rel_way_lock_b;
wire                                                         rel_way_lock_c;
wire                                                         rel_way_lock_d;
wire                                                         rel_way_lock_e;
wire                                                         rel_way_lock_f;
wire                                                         rel_way_lock_g;
wire                                                         rel_way_lock_h;
wire                                                         rel_way_clr_a;
wire                                                         rel_way_clr_b;
wire                                                         rel_way_clr_c;
wire                                                         rel_way_clr_d;
wire                                                         rel_way_clr_e;
wire                                                         rel_way_clr_f;
wire                                                         rel_way_clr_g;
wire                                                         rel_way_clr_h;
wire                                                         rel_way_wen_a;
wire                                                         rel_way_wen_b;
wire                                                         rel_way_wen_c;
wire                                                         rel_way_wen_d;
wire                                                         rel_way_wen_e;
wire                                                         rel_way_wen_f;
wire                                                         rel_way_wen_g;
wire                                                         rel_way_wen_h;
wire                                                         rel_way_upd_a;
wire                                                         rel_way_upd_b;
wire                                                         rel_way_upd_c;
wire                                                         rel_way_upd_d;
wire                                                         rel_way_upd_e;
wire                                                         rel_way_upd_f;
wire                                                         rel_way_upd_g;
wire                                                         rel_way_upd_h;
wire                                                         rel3_dir_wr_val;
wire [64-(`DC_SIZE-3):63-`CL_SIZE]                           rel3_dir_wr_addr;
wire                                                         ex4_l1hit;
wire                                                         ex4_l1miss;
wire                                                         ex4_way_cmp_a;
wire                                                         ex4_way_cmp_b;
wire                                                         ex4_way_cmp_c;
wire                                                         ex4_way_cmp_d;
wire                                                         ex4_way_cmp_e;
wire                                                         ex4_way_cmp_f;
wire                                                         ex4_way_cmp_g;
wire                                                         ex4_way_cmp_h;
wire                                                         ex4_way_hit_a;
wire                                                         ex4_way_hit_b;
wire                                                         ex4_way_hit_c;
wire                                                         ex4_way_hit_d;
wire                                                         ex4_way_hit_e;
wire                                                         ex4_way_hit_f;
wire                                                         ex4_way_hit_g;
wire                                                         ex4_way_hit_h;
wire [0:7]                                                   ex4_tag_perr_way;
wire                                                         spr_xucr0_dcdis_d;
wire                                                         spr_xucr0_dcdis_q;
wire                                                         spr_xucr0_cls_b;
wire                                                         spr_xucr0_cls_d;
wire                                                         spr_xucr0_cls_q;
wire                                                         stq3_way_cmp_a;
wire                                                         stq3_way_cmp_b;
wire                                                         stq3_way_cmp_c;
wire                                                         stq3_way_cmp_d;
wire                                                         stq3_way_cmp_e;
wire                                                         stq3_way_cmp_f;
wire                                                         stq3_way_cmp_g;
wire                                                         stq3_way_cmp_h;
wire [0:7]                                                   stq3_tag_way_perr;
wire                                                         stq3_way_hit_a;
wire                                                         stq3_way_hit_b;
wire                                                         stq3_way_hit_c;
wire                                                         stq3_way_hit_d;
wire                                                         stq3_way_hit_e;
wire                                                         stq3_way_hit_f;
wire                                                         stq3_way_hit_g;
wire                                                         stq3_way_hit_h;
wire                                                         stq3_miss;
wire                                                         stq3_hit;
wire                                                         stq1_lru_upd;
wire                                                         stq2_ddir_acc;
wire [0:7]                                                   dir_arr_wr_way_int;
wire [64-(`DC_SIZE-3):63-`CL_SIZE]                           dir_arr_wr_addr_int;
wire                                                         dir_tag_scanout;

//--------------------------
// constants
//--------------------------
parameter                                                    rel4_dir_wr_val_offset = 0;
parameter                                                    spr_xucr0_dcdis_offset = rel4_dir_wr_val_offset + 1;
parameter                                                    spr_xucr0_cls_offset = spr_xucr0_dcdis_offset + 1;
parameter                                                    scan_right = spr_xucr0_cls_offset + 1 - 1;

wire                                                         tiup;
wire [0:scan_right]                                          siv;
wire [0:scan_right]                                          sov;


(* analysis_not_referenced="true" *)

wire                                                         unused;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Inputs
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign tiup = 1'b1;
assign unused = stq3_miss;

// Force Alignment
assign ex2_lwr_p_addr[60] = ex2_eff_addr[60] & (~dcc_dir_ex2_frc_align16);
assign ex2_lwr_p_addr[61] = ex2_eff_addr[61] & (~(dcc_dir_ex2_frc_align16 | dcc_dir_ex2_frc_align8));
assign ex2_lwr_p_addr[62] = ex2_eff_addr[62] & (~(dcc_dir_ex2_frc_align16 | dcc_dir_ex2_frc_align8 | dcc_dir_ex2_frc_align4));
assign ex2_lwr_p_addr[63] = ex2_eff_addr[63] & (~(dcc_dir_ex2_frc_align16 | dcc_dir_ex2_frc_align8 | dcc_dir_ex2_frc_align4 | dcc_dir_ex2_frc_align2));

assign rel4_dir_wr_val_d = rel3_dir_wr_val;
assign stq1_lru_upd      = lsq_ctl_stq1_store_val & (~lsq_ctl_stq1_inval);
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// XU Config Bits
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// XUCR0[DC_DIS] Data Cache Disabled
// 1 => L1 Data Cache Disabled
// 0 => L1 Data Cache Enabled
assign spr_xucr0_dcdis_d = xu_lq_spr_xucr0_dcdis;

// XUCR0[CLS] 128 Byte Cacheline Enabled
// 1 => 128 Byte Cacheline
// 0 => 64 Byte Cacheline
assign spr_xucr0_cls_d = xu_lq_spr_xucr0_cls;
assign spr_xucr0_cls_b = (~spr_xucr0_cls_q);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// AGEN Adder
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

generate
   if (`GPR_WIDTH_ENC == 5) begin : Mode32b
      assign ex2_eff_addr                                       = byp_dir_ex2_rs1 + byp_dir_ex2_rs2;
      assign dir_arr_rd_addr0_01[64-(`DC_SIZE-3):63-`CL_SIZE-1] = ex2_eff_addr[64-(`DC_SIZE-3):63-`CL_SIZE-1];
      assign dir_arr_rd_addr0_01[63-`CL_SIZE]                   = ex2_eff_addr[63-`CL_SIZE] | spr_xucr0_cls_q;
      assign dir_arr_rd_addr0_23[64-(`DC_SIZE-3):63-`CL_SIZE-1] = ex2_eff_addr[64-(`DC_SIZE-3):63-`CL_SIZE-1];
      assign dir_arr_rd_addr0_23[63-`CL_SIZE]                   = ex2_eff_addr[63-`CL_SIZE] | spr_xucr0_cls_q;
      assign dir_arr_rd_addr0_45[64-(`DC_SIZE-3):63-`CL_SIZE-1] = ex2_eff_addr[64-(`DC_SIZE-3):63-`CL_SIZE-1];
      assign dir_arr_rd_addr0_45[63-`CL_SIZE]                   = ex2_eff_addr[63-`CL_SIZE] | spr_xucr0_cls_q;
      assign dir_arr_rd_addr0_67[64-(`DC_SIZE-3):63-`CL_SIZE-1] = ex2_eff_addr[64-(`DC_SIZE-3):63-`CL_SIZE-1];
      assign dir_arr_rd_addr0_67[63-`CL_SIZE]                   = ex2_eff_addr[63-`CL_SIZE] | spr_xucr0_cls_q;
      assign dir_derat_ex2_eff_addr[0:31]                       = {32{1'b0}};
      assign dir_derat_ex2_eff_addr[32:51]                      = ex2_eff_addr[32:51];
      assign dir_arr_wr_enable[0]                               = rel4_dir_wr_val_q & (dir_arr_wr_way_int[0] | dir_arr_wr_way_int[1]);
      assign dir_arr_wr_enable[1]                               = rel4_dir_wr_val_q & (dir_arr_wr_way_int[2] | dir_arr_wr_way_int[3]);
      assign dir_arr_wr_enable[2]                               = rel4_dir_wr_val_q & (dir_arr_wr_way_int[4] | dir_arr_wr_way_int[5]);
      assign dir_arr_wr_enable[3]                               = rel4_dir_wr_val_q & (dir_arr_wr_way_int[6] | dir_arr_wr_way_int[7]);
   end
endgenerate

generate
   if (`GPR_WIDTH_ENC == 6) begin : Mode64b
      lq_agen agen(
         .x(byp_dir_ex2_rs1),
         .y(byp_dir_ex2_rs2),
         .mode64(dcc_dir_ex2_64bit_agen),
         .dir_ig_57_b(spr_xucr0_cls_b),

         .sum_non_erat(ex2_eff_addr),
         .sum(dir_derat_ex2_eff_addr),
         .sum_arr_dir01(dir_arr_rd_addr0_01),
         .sum_arr_dir23(dir_arr_rd_addr0_23),
         .sum_arr_dir45(dir_arr_rd_addr0_45),
         .sum_arr_dir67(dir_arr_rd_addr0_67),

         .way(dir_arr_wr_way_int),
         .rel4_dir_wr_val(rel4_dir_wr_val_q),
         .ary_write_act_01(dir_arr_wr_enable[0]),
         .ary_write_act_23(dir_arr_wr_enable[1]),
         .ary_write_act_45(dir_arr_wr_enable[2]),
         .ary_write_act_67(dir_arr_wr_enable[3])
      );
   end
endgenerate

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Directory Valids Array
// 1) Contains an Array of Valids
// 2) Updates Valid bits on Reloads
// 3) Invalidates Valid bits for Flush type commands and Back Invalidates
// 4) Outputs Valids for Congruence Class
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
lq_dir_val l1dcdv(

   // ACT's
   .dcc_dir_ex2_stg_act(dcc_dir_ex2_stg_act),
   .dcc_dir_ex3_stg_act(dcc_dir_ex3_stg_act),
   .dcc_dir_ex4_stg_act(dcc_dir_ex4_stg_act),
   .dcc_dir_stq1_stg_act(dcc_dir_stq1_stg_act),
   .dcc_dir_stq2_stg_act(dcc_dir_stq2_stg_act),
   .dcc_dir_stq3_stg_act(dcc_dir_stq3_stg_act),
   .dcc_dir_stq4_stg_act(dcc_dir_stq4_stg_act),
   .dcc_dir_stq5_stg_act(dcc_dir_stq5_stg_act),
   .dcc_dir_binv2_ex2_stg_act(dcc_dir_binv2_ex2_stg_act),
   .dcc_dir_binv3_ex3_stg_act(dcc_dir_binv3_ex3_stg_act),
   .dcc_dir_binv4_ex4_stg_act(dcc_dir_binv4_ex4_stg_act),
   .dcc_dir_binv5_ex5_stg_act(dcc_dir_binv5_ex5_stg_act),
   .dcc_dir_binv6_ex6_stg_act(dcc_dir_binv6_ex6_stg_act),

   // Reload and Store Commit Pipe
   .lsq_ctl_stq1_val(lsq_ctl_stq1_val),
   .lsq_ctl_stq2_blk_req(lsq_ctl_stq2_blk_req),
   .lsq_ctl_stq1_thrd_id(lsq_ctl_stq1_thrd_id),
   .lsq_ctl_rel1_thrd_id(lsq_ctl_rel1_thrd_id),
   .lsq_ctl_stq1_ci(lsq_ctl_stq1_ci),
   .lsq_ctl_stq1_lock_clr(lsq_ctl_stq1_lock_clr),
   .lsq_ctl_stq1_watch_clr(lsq_ctl_stq1_watch_clr),
   .lsq_ctl_stq1_store_val(lsq_ctl_stq1_store_val),
   .lsq_ctl_stq1_inval(lsq_ctl_stq1_inval),
   .lsq_ctl_stq1_dci_val(lsq_ctl_stq1_dci_val),
   .lsq_ctl_stq1_l_fld(lsq_ctl_stq1_l_fld),
   .lsq_ctl_stq1_addr(lsq_ctl_stq1_addr[64 - (`DC_SIZE - 3):63 - `CL_SIZE]),
   .lsq_ctl_rel1_clr_val(lsq_ctl_rel1_clr_val),
   .lsq_ctl_rel1_set_val(lsq_ctl_rel1_set_val),
   .lsq_ctl_rel1_back_inv(lsq_ctl_rel1_back_inv),
   .lsq_ctl_rel2_blk_req(lsq_ctl_rel2_blk_req),
   .lsq_ctl_rel2_upd_val(lsq_ctl_rel2_upd_val),
   .lsq_ctl_rel3_l1dump_val(lsq_ctl_rel3_l1dump_val),
   .lsq_ctl_rel1_lock_set(lsq_ctl_rel1_lock_set),
   .lsq_ctl_rel1_watch_set(lsq_ctl_rel1_watch_set),
   .dcc_dir_stq6_store_val(dcc_dir_stq6_store_val),

   .rel_way_clr_a(rel_way_clr_a),
   .rel_way_clr_b(rel_way_clr_b),
   .rel_way_clr_c(rel_way_clr_c),
   .rel_way_clr_d(rel_way_clr_d),
   .rel_way_clr_e(rel_way_clr_e),
   .rel_way_clr_f(rel_way_clr_f),
   .rel_way_clr_g(rel_way_clr_g),
   .rel_way_clr_h(rel_way_clr_h),

   .rel_way_wen_a(rel_way_wen_a),
   .rel_way_wen_b(rel_way_wen_b),
   .rel_way_wen_c(rel_way_wen_c),
   .rel_way_wen_d(rel_way_wen_d),
   .rel_way_wen_e(rel_way_wen_e),
   .rel_way_wen_f(rel_way_wen_f),
   .rel_way_wen_g(rel_way_wen_g),
   .rel_way_wen_h(rel_way_wen_h),

   .xu_lq_spr_xucr0_clfc(xu_lq_spr_xucr0_clfc),
   .spr_xucr0_dcdis(spr_xucr0_dcdis_q),
   .spr_xucr0_cls(spr_xucr0_cls_q),

   // Execution Pipe
   .dcc_dir_ex2_binv_val(dcc_dir_ex2_binv_val),
   .dcc_dir_ex2_thrd_id(dcc_dir_ex2_thrd_id),
   .ex2_eff_addr(ex2_eff_addr[64 - (`DC_SIZE - 3):63 - `CL_SIZE]),
   .dcc_dir_ex3_cache_acc(dcc_dir_ex3_cache_acc),
   .dcc_dir_ex3_pfetch_val(dcc_dir_ex3_pfetch_val),
   .dcc_dir_ex3_lock_set(dcc_dir_ex3_lock_set),
   .dcc_dir_ex3_th_c(dcc_dir_ex3_th_c),
   .dcc_dir_ex3_watch_set(dcc_dir_ex3_watch_set),
   .dcc_dir_ex3_larx_val(dcc_dir_ex3_larx_val),
   .dcc_dir_ex3_watch_chk(dcc_dir_ex3_watch_chk),
   .dcc_dir_ex4_load_val(dcc_dir_ex4_load_val),
   .derat_dir_ex4_wimge_i(derat_dir_ex4_wimge_i),

   // Execution Pipe Flush
   .fgen_ex3_stg_flush(fgen_ex3_stg_flush),
   .fgen_ex4_cp_flush(fgen_ex4_cp_flush),
   .fgen_ex4_stg_flush(fgen_ex4_stg_flush),
   .fgen_ex5_stg_flush(fgen_ex5_stg_flush),

   // Directory Parity Error for Execution Pipe
   .ex4_tag_perr_way(ex4_tag_perr_way),
   .dat_ctl_dcarr_perr_way(dat_ctl_dcarr_perr_way),

   // Tag Compares
   .ex4_way_cmp_a(ex4_way_cmp_a),
   .ex4_way_cmp_b(ex4_way_cmp_b),
   .ex4_way_cmp_c(ex4_way_cmp_c),
   .ex4_way_cmp_d(ex4_way_cmp_d),
   .ex4_way_cmp_e(ex4_way_cmp_e),
   .ex4_way_cmp_f(ex4_way_cmp_f),
   .ex4_way_cmp_g(ex4_way_cmp_g),
   .ex4_way_cmp_h(ex4_way_cmp_h),

   // Commit Pipe
   .stq3_way_cmp_a(stq3_way_cmp_a),
   .stq3_way_cmp_b(stq3_way_cmp_b),
   .stq3_way_cmp_c(stq3_way_cmp_c),
   .stq3_way_cmp_d(stq3_way_cmp_d),
   .stq3_way_cmp_e(stq3_way_cmp_e),
   .stq3_way_cmp_f(stq3_way_cmp_f),
   .stq3_way_cmp_g(stq3_way_cmp_g),
   .stq3_way_cmp_h(stq3_way_cmp_h),

   // Directory Parity Error for Store Commit Pipe
   .stq3_tag_way_perr(stq3_tag_way_perr),

   // Multihit Error Inject
   .pc_lq_inj_dcachedir_ldp_multihit(pc_lq_inj_dcachedir_ldp_multihit),
   .pc_lq_inj_dcachedir_stp_multihit(pc_lq_inj_dcachedir_stp_multihit),

   // L1 Directory Contents
   .dir_dcc_ex5_way_a_dir(dir_dcc_ex5_way_a_dir),
   .dir_dcc_ex5_way_b_dir(dir_dcc_ex5_way_b_dir),
   .dir_dcc_ex5_way_c_dir(dir_dcc_ex5_way_c_dir),
   .dir_dcc_ex5_way_d_dir(dir_dcc_ex5_way_d_dir),
   .dir_dcc_ex5_way_e_dir(dir_dcc_ex5_way_e_dir),
   .dir_dcc_ex5_way_f_dir(dir_dcc_ex5_way_f_dir),
   .dir_dcc_ex5_way_g_dir(dir_dcc_ex5_way_g_dir),
   .dir_dcc_ex5_way_h_dir(dir_dcc_ex5_way_h_dir),

   // L1 Directory Hits
   .ex4_way_hit_a(ex4_way_hit_a),
   .ex4_way_hit_b(ex4_way_hit_b),
   .ex4_way_hit_c(ex4_way_hit_c),
   .ex4_way_hit_d(ex4_way_hit_d),
   .ex4_way_hit_e(ex4_way_hit_e),
   .ex4_way_hit_f(ex4_way_hit_f),
   .ex4_way_hit_g(ex4_way_hit_g),
   .ex4_way_hit_h(ex4_way_hit_h),

   // ex4 Execution Pipe Command Outputs
   .ex4_miss(ex4_l1miss),
   .ex4_hit(ex4_l1hit),
   .dir_dcc_ex4_set_rel_coll(dir_dcc_ex4_set_rel_coll),
   .dir_dcc_ex4_byp_restart(dir_dcc_ex4_byp_restart),
   .dir_dcc_ex5_dir_perr_det(dir_dcc_ex5_dir_perr_det),
   .dir_dcc_ex5_dc_perr_det(dir_dcc_ex5_dc_perr_det),
   .dir_dcc_ex5_dir_perr_flush(dir_dcc_ex5_dir_perr_flush),
   .dir_dcc_ex5_dc_perr_flush(dir_dcc_ex5_dc_perr_flush),
   .dir_dcc_ex5_multihit_det(dir_dcc_ex5_multihit_det),
   .dir_dcc_ex5_multihit_flush(dir_dcc_ex5_multihit_flush),
   .dir_dcc_stq4_dir_perr_det(dir_dcc_stq4_dir_perr_det),
   .dir_dcc_stq4_multihit_det(dir_dcc_stq4_multihit_det),
   .dir_dcc_ex5_stp_flush(dir_dcc_ex5_stp_flush),

   // Performance Events
   .ctl_perv_dir_perf_events(ctl_perv_dir_perf_events),

   // SPR status
   .lq_xu_spr_xucr0_cslc_xuop(lq_xu_spr_xucr0_cslc_xuop),
   .lq_xu_spr_xucr0_cslc_binv(lq_xu_spr_xucr0_cslc_binv),

   // ex5 Execution Pipe Command Outputs
   .dir_dcc_ex5_cr_rslt(dir_dcc_ex5_cr_rslt),

   // stq4 Commit Pipe Command Outputs
   .stq2_ddir_acc(stq2_ddir_acc),
   .stq3_way_hit_a(stq3_way_hit_a),
   .stq3_way_hit_b(stq3_way_hit_b),
   .stq3_way_hit_c(stq3_way_hit_c),
   .stq3_way_hit_d(stq3_way_hit_d),
   .stq3_way_hit_e(stq3_way_hit_e),
   .stq3_way_hit_f(stq3_way_hit_f),
   .stq3_way_hit_g(stq3_way_hit_g),
   .stq3_way_hit_h(stq3_way_hit_h),
   .stq3_miss(stq3_miss),
   .stq3_hit(stq3_hit),
   .ctl_lsq_stq4_perr_reject(ctl_lsq_stq4_perr_reject),
   .ctl_dat_stq5_way_perr_inval(ctl_dat_stq5_way_perr_inval),

   // Way Valids for Replacement Algorithm
   .rel_way_val_a(rel_way_val_a),
   .rel_way_val_b(rel_way_val_b),
   .rel_way_val_c(rel_way_val_c),
   .rel_way_val_d(rel_way_val_d),
   .rel_way_val_e(rel_way_val_e),
   .rel_way_val_f(rel_way_val_f),
   .rel_way_val_g(rel_way_val_g),
   .rel_way_val_h(rel_way_val_h),

   // Congruence Class Line Lock
   .rel_way_lock_a(rel_way_lock_a),
   .rel_way_lock_b(rel_way_lock_b),
   .rel_way_lock_c(rel_way_lock_c),
   .rel_way_lock_d(rel_way_lock_d),
   .rel_way_lock_e(rel_way_lock_e),
   .rel_way_lock_f(rel_way_lock_f),
   .rel_way_lock_g(rel_way_lock_g),
   .rel_way_lock_h(rel_way_lock_h),

   //pervasive
   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .sg_0(sg_0),
   .func_sl_thold_0_b(func_sl_thold_0_b),
   .func_sl_force(func_sl_force),
   .func_slp_sl_thold_0_b(func_slp_sl_thold_0_b),
   .func_slp_sl_force(func_slp_sl_force),
   .func_nsl_thold_0_b(func_nsl_thold_0_b),
   .func_nsl_force(func_nsl_force),
   .func_slp_nsl_thold_0_b(func_slp_nsl_thold_0_b),
   .func_slp_nsl_force(func_slp_nsl_force),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc),
   .mpw1_dc_b(mpw1_dc_b),
   .mpw2_dc_b(mpw2_dc_b),
   .scan_in(scan_in[0:2]),
   .scan_out(scan_out[0:2])
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// LRU Register Array
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
lq_dir_lru l1dcdl(

   // ACT's
   .dcc_dir_ex2_stg_act(dcc_dir_ex2_stg_act),
   .dcc_dir_ex3_stg_act(dcc_dir_ex3_stg_act),
   .dcc_dir_ex4_stg_act(dcc_dir_ex4_stg_act),
   .dcc_dir_ex5_stg_act(dcc_dir_ex5_stg_act),
   .dcc_dir_stq1_stg_act(dcc_dir_stq1_stg_act),
   .dcc_dir_stq2_stg_act(dcc_dir_stq2_stg_act),
   .dcc_dir_stq3_stg_act(dcc_dir_stq3_stg_act),

   // Inputs
   //Reload path
   .lsq_ctl_stq1_val(lsq_ctl_stq1_val),
   .lsq_ctl_stq2_blk_req(lsq_ctl_stq2_blk_req),
   .lsq_ctl_stq1_ci(lsq_ctl_stq1_ci),
   .lsq_ctl_stq1_addr(lsq_ctl_stq1_addr[64 - (`DC_SIZE - 3):63 - `CL_SIZE]),
   .lsq_ctl_rel1_clr_val(lsq_ctl_rel1_clr_val),
   .lsq_ctl_rel1_set_val(lsq_ctl_rel1_set_val),
   .lsq_ctl_rel1_data_val(lsq_ctl_rel1_data_val),
   .lsq_ctl_rel2_blk_req(lsq_ctl_rel2_blk_req),
   .lsq_ctl_rel1_lock_set(lsq_ctl_rel1_lock_set),
   .lsq_ctl_rel1_classid(lsq_ctl_rel1_classid),
   .lsq_ctl_rel1_tag(lsq_ctl_rel1_tag),
   .lsq_ctl_rel3_clr_relq(lsq_ctl_rel3_clr_relq),
   .stq1_lru_upd(stq1_lru_upd),

   // stq3 Commit Pipe Command Inputs
   .stq3_way_hit_a(stq3_way_hit_a),
   .stq3_way_hit_b(stq3_way_hit_b),
   .stq3_way_hit_c(stq3_way_hit_c),
   .stq3_way_hit_d(stq3_way_hit_d),
   .stq3_way_hit_e(stq3_way_hit_e),
   .stq3_way_hit_f(stq3_way_hit_f),
   .stq3_way_hit_g(stq3_way_hit_g),
   .stq3_way_hit_h(stq3_way_hit_h),
   .stq3_hit(stq3_hit),

   // Way Valids for Replacement Algorithm
   .rel_way_val_a(rel_way_val_a),
   .rel_way_val_b(rel_way_val_b),
   .rel_way_val_c(rel_way_val_c),
   .rel_way_val_d(rel_way_val_d),
   .rel_way_val_e(rel_way_val_e),
   .rel_way_val_f(rel_way_val_f),
   .rel_way_val_g(rel_way_val_g),
   .rel_way_val_h(rel_way_val_h),

   // Congruence Class Line Lock
   .rel_way_lock_a(rel_way_lock_a),
   .rel_way_lock_b(rel_way_lock_b),
   .rel_way_lock_c(rel_way_lock_c),
   .rel_way_lock_d(rel_way_lock_d),
   .rel_way_lock_e(rel_way_lock_e),
   .rel_way_lock_f(rel_way_lock_f),
   .rel_way_lock_g(rel_way_lock_g),
   .rel_way_lock_h(rel_way_lock_h),

   //Execution path
   .ex2_eff_addr(ex2_eff_addr[64 - (`DC_SIZE - 3):63 - `CL_SIZE]),
   .dcc_dir_ex3_cache_acc(dcc_dir_ex3_cache_acc),
   .dcc_dir_ex3_lru_upd(dcc_dir_ex3_lru_upd),
   .derat_dir_ex4_wimge_i(derat_dir_ex4_wimge_i),

   // Way Hit for Execution Pipe
   .ex4_way_hit_a(ex4_way_hit_a),
   .ex4_way_hit_b(ex4_way_hit_b),
   .ex4_way_hit_c(ex4_way_hit_c),
   .ex4_way_hit_d(ex4_way_hit_d),
   .ex4_way_hit_e(ex4_way_hit_e),
   .ex4_way_hit_f(ex4_way_hit_f),
   .ex4_way_hit_g(ex4_way_hit_g),
   .ex4_way_hit_h(ex4_way_hit_h),
   .ex4_hit(ex4_l1hit),

   // SPR's
   .dcc_dir_spr_xucr2_rmt(dcc_dir_spr_xucr2_rmt),
   .spr_xucr0_dcdis(spr_xucr0_dcdis_q),
   .xu_lq_spr_xucr0_wlk(xu_lq_spr_xucr0_wlk),
   .spr_xucr0_cls(spr_xucr0_cls_q),

   // Flush Signals
   .fgen_ex3_stg_flush(fgen_ex3_stg_flush),
   .fgen_ex4_stg_flush(fgen_ex4_stg_flush),
   .fgen_ex5_stg_flush(fgen_ex5_stg_flush),

   // Outputs
   // Way Data Cache Write Enables on a Reload
   .rel_way_wen_a(rel_way_wen_a),
   .rel_way_wen_b(rel_way_wen_b),
   .rel_way_wen_c(rel_way_wen_c),
   .rel_way_wen_d(rel_way_wen_d),
   .rel_way_wen_e(rel_way_wen_e),
   .rel_way_wen_f(rel_way_wen_f),
   .rel_way_wen_g(rel_way_wen_g),
   .rel_way_wen_h(rel_way_wen_h),

   // Way Directory Write Enables on a Reload
   .rel_way_upd_a(rel_way_upd_a),
   .rel_way_upd_b(rel_way_upd_b),
   .rel_way_upd_c(rel_way_upd_c),
   .rel_way_upd_d(rel_way_upd_d),
   .rel_way_upd_e(rel_way_upd_e),
   .rel_way_upd_f(rel_way_upd_f),
   .rel_way_upd_g(rel_way_upd_g),
   .rel_way_upd_h(rel_way_upd_h),

   // Way Invalidate on a Reload
   .rel_way_clr_a(rel_way_clr_a),
   .rel_way_clr_b(rel_way_clr_b),
   .rel_way_clr_c(rel_way_clr_c),
   .rel_way_clr_d(rel_way_clr_d),
   .rel_way_clr_e(rel_way_clr_e),
   .rel_way_clr_f(rel_way_clr_f),
   .rel_way_clr_g(rel_way_clr_g),
   .rel_way_clr_h(rel_way_clr_h),
   .rel3_dir_wr_val(rel3_dir_wr_val),
   .rel3_dir_wr_addr(rel3_dir_wr_addr),
   .dir_dcc_rel3_dcarr_upd(dir_dcc_rel3_dcarr_upd),

   // Way Write Enable on a Reload for Data
   .stq4_dcarr_way_en(stq4_dcarr_way_en),

   // Directory LRU in EX5
   .dir_dcc_ex5_dir_lru(dir_dcc_ex5_dir_lru),

   // SPR Status
   .lq_xu_spr_xucr0_clo(lq_xu_spr_xucr0_clo),

   //pervasive
   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .sg_0(sg_0),
   .func_sl_thold_0_b(func_sl_thold_0_b),
   .func_sl_force(func_sl_force),
   .func_nsl_thold_0_b(func_nsl_thold_0_b),
   .func_nsl_force(func_nsl_force),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc),
   .mpw1_dc_b(mpw1_dc_b),
   .mpw2_dc_b(mpw2_dc_b),
   .scan_in(scan_in[3]),
   .scan_out(scan_out[3])
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Directory Tag Array
// 1) Contains an Array of Tags
// 2) Updates Tag on Reload
// 3) Contains Hit Logic
// 4) Outputs Way Hit indicators
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
lq_dir_tag #(.WAYDATASIZE(WAYDATASIZE), .PARBITS(PARBITS)) l1dcdt(

   // Stage ACT Signals
   .dcc_dir_binv3_ex3_stg_act(dcc_dir_binv3_ex3_stg_act),
   .dcc_dir_stq1_stg_act(dcc_dir_stq1_stg_act),
   .dcc_dir_stq2_stg_act(dcc_dir_stq2_stg_act),
   .dcc_dir_stq3_stg_act(dcc_dir_stq3_stg_act),

   // Reload Update Directory
   .rel_way_upd_a(rel_way_upd_a),
   .rel_way_upd_b(rel_way_upd_b),
   .rel_way_upd_c(rel_way_upd_c),
   .rel_way_upd_d(rel_way_upd_d),
   .rel_way_upd_e(rel_way_upd_e),
   .rel_way_upd_f(rel_way_upd_f),
   .rel_way_upd_g(rel_way_upd_g),
   .rel_way_upd_h(rel_way_upd_h),

   // Back-Invalidate
   .dcc_dir_ex2_binv_val(dcc_dir_ex2_binv_val),

   // SPR Bits
   .spr_xucr0_dcdis(spr_xucr0_dcdis_q),

   // LQ Pipe
   .dcc_dir_ex4_p_addr(dcc_dir_ex4_p_addr),
   .dcc_dir_ex3_ddir_acc(dcc_dir_ex3_ddir_acc),

   // Commit Pipe
   .lsq_ctl_stq1_addr(lsq_ctl_stq1_addr),
   .stq2_ddir_acc(stq2_ddir_acc),

   // Error Inject
   .pc_lq_inj_dcachedir_ldp_parity(pc_lq_inj_dcachedir_ldp_parity),
   .pc_lq_inj_dcachedir_stp_parity(pc_lq_inj_dcachedir_stp_parity),

   // L1 Directory Read Interface
   .dir_arr_rd_data0(dir_arr_rd_data0),
   .dir_arr_rd_data1(dir_arr_rd_data1),

   // L1 Directory Write Interface
   .dir_arr_wr_way(dir_arr_wr_way_int),
   .dir_arr_wr_addr(dir_arr_wr_addr_int),
   .dir_arr_wr_data(dir_arr_wr_data),

   // LQ Pipe
   .ex4_way_cmp_a(ex4_way_cmp_a),
   .ex4_way_cmp_b(ex4_way_cmp_b),
   .ex4_way_cmp_c(ex4_way_cmp_c),
   .ex4_way_cmp_d(ex4_way_cmp_d),
   .ex4_way_cmp_e(ex4_way_cmp_e),
   .ex4_way_cmp_f(ex4_way_cmp_f),
   .ex4_way_cmp_g(ex4_way_cmp_g),
   .ex4_way_cmp_h(ex4_way_cmp_h),
   .ex4_tag_perr_way(ex4_tag_perr_way),

   // L1 Directory Contents
   .dir_dcc_ex4_way_tag_a(dir_dcc_ex4_way_tag_a),
   .dir_dcc_ex4_way_tag_b(dir_dcc_ex4_way_tag_b),
   .dir_dcc_ex4_way_tag_c(dir_dcc_ex4_way_tag_c),
   .dir_dcc_ex4_way_tag_d(dir_dcc_ex4_way_tag_d),
   .dir_dcc_ex4_way_tag_e(dir_dcc_ex4_way_tag_e),
   .dir_dcc_ex4_way_tag_f(dir_dcc_ex4_way_tag_f),
   .dir_dcc_ex4_way_tag_g(dir_dcc_ex4_way_tag_g),
   .dir_dcc_ex4_way_tag_h(dir_dcc_ex4_way_tag_h),
   .dir_dcc_ex4_way_par_a(dir_dcc_ex4_way_par_a),
   .dir_dcc_ex4_way_par_b(dir_dcc_ex4_way_par_b),
   .dir_dcc_ex4_way_par_c(dir_dcc_ex4_way_par_c),
   .dir_dcc_ex4_way_par_d(dir_dcc_ex4_way_par_d),
   .dir_dcc_ex4_way_par_e(dir_dcc_ex4_way_par_e),
   .dir_dcc_ex4_way_par_f(dir_dcc_ex4_way_par_f),
   .dir_dcc_ex4_way_par_g(dir_dcc_ex4_way_par_g),
   .dir_dcc_ex4_way_par_h(dir_dcc_ex4_way_par_h),

   // Commit Pipe
   .stq3_way_cmp_a(stq3_way_cmp_a),
   .stq3_way_cmp_b(stq3_way_cmp_b),
   .stq3_way_cmp_c(stq3_way_cmp_c),
   .stq3_way_cmp_d(stq3_way_cmp_d),
   .stq3_way_cmp_e(stq3_way_cmp_e),
   .stq3_way_cmp_f(stq3_way_cmp_f),
   .stq3_way_cmp_g(stq3_way_cmp_g),
   .stq3_way_cmp_h(stq3_way_cmp_h),
   .stq3_tag_way_perr(stq3_tag_way_perr),

   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .sg_0(sg_0),
   .func_sl_thold_0_b(func_sl_thold_0_b),
   .func_sl_force(func_sl_force),
   .func_slp_sl_thold_0_b(func_slp_sl_thold_0_b),
   .func_slp_sl_force(func_slp_sl_force),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc),
   .mpw1_dc_b(mpw1_dc_b),
   .mpw2_dc_b(mpw2_dc_b),
   .scan_in(scan_in[4]),
   .scan_out(dir_tag_scanout)
);
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Outputs
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

assign ctl_dat_ex4_way_hit = {ex4_way_hit_a, ex4_way_hit_b, ex4_way_hit_c, ex4_way_hit_d,
                              ex4_way_hit_e, ex4_way_hit_f, ex4_way_hit_g, ex4_way_hit_h};

assign dir_arr_wr_way  = dir_arr_wr_way_int;
assign dir_arr_wr_addr = dir_arr_wr_addr_int;

assign dir_dcc_ex2_eff_addr = {ex2_eff_addr[(64 - (2 ** `GPR_WIDTH_ENC)):59], ex2_lwr_p_addr};
assign dir_dcc_stq3_hit     = stq3_hit;
assign dir_dcc_ex4_hit      = ex4_l1hit;
assign dir_dcc_ex4_miss     = ex4_l1miss;

assign dir_dec_rel3_dir_wr_val  = rel3_dir_wr_val;
assign dir_dec_rel3_dir_wr_addr = rel3_dir_wr_addr;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Registers
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel4_dir_wr_val_reg(
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
   .scin(siv[rel4_dir_wr_val_offset]),
   .scout(sov[rel4_dir_wr_val_offset]),
   .din(rel4_dir_wr_val_d),
   .dout(rel4_dir_wr_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_dcdis_reg(
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
   .scin(siv[spr_xucr0_dcdis_offset]),
   .scout(sov[spr_xucr0_dcdis_offset]),
   .din(spr_xucr0_dcdis_d),
   .dout(spr_xucr0_dcdis_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_cls_reg(
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
   .scin(siv[spr_xucr0_cls_offset]),
   .scout(sov[spr_xucr0_cls_offset]),
   .din(spr_xucr0_cls_d),
   .dout(spr_xucr0_cls_q)
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign siv[0:scan_right] = {sov[1:scan_right], dir_tag_scanout};
assign scan_out[4] = sov[0];

endmodule
