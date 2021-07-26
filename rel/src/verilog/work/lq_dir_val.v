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

//
//  Description:  XU LSU L1 Data Directory Valid Register Array
//
//*****************************************************************************

// ##########################################################################################
// Directory Valids Component
// 1) Contains an Array of Valids
// 2) Updates Valid bits on Reloads
// 3) Invalidates Valid bits for Flush type commands and Back Invalidates
// 4) Outputs Valids for Congruence Class
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Flush Way Generation
// Want to flush a Way on the following conditions
// 1) Invalidate Type Instruction (dcbf,dcbi,dcbz,lwarx,stwcx)
// 2) L2 Back Invalidate
// 3) L2 Reload and overwritting a Valid Way
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// ##########################################################################################

`include "tri_a2o.vh"

module lq_dir_val(
   dcc_dir_ex2_stg_act,
   dcc_dir_ex3_stg_act,
   dcc_dir_ex4_stg_act,
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
   lsq_ctl_stq1_val,
   lsq_ctl_stq2_blk_req,
   lsq_ctl_stq1_thrd_id,
   lsq_ctl_rel1_thrd_id,
   lsq_ctl_stq1_ci,
   lsq_ctl_stq1_lock_clr,
   lsq_ctl_stq1_watch_clr,
   lsq_ctl_stq1_store_val,
   lsq_ctl_stq1_inval,
   lsq_ctl_stq1_dci_val,
   lsq_ctl_stq1_l_fld,
   lsq_ctl_stq1_addr,
   lsq_ctl_rel1_clr_val,
   lsq_ctl_rel1_set_val,
   lsq_ctl_rel1_back_inv,
   lsq_ctl_rel2_blk_req,
   lsq_ctl_rel1_lock_set,
   lsq_ctl_rel1_watch_set,
   lsq_ctl_rel2_upd_val,
   lsq_ctl_rel3_l1dump_val,
   dcc_dir_stq6_store_val,
   rel_way_clr_a,
   rel_way_clr_b,
   rel_way_clr_c,
   rel_way_clr_d,
   rel_way_clr_e,
   rel_way_clr_f,
   rel_way_clr_g,
   rel_way_clr_h,
   rel_way_wen_a,
   rel_way_wen_b,
   rel_way_wen_c,
   rel_way_wen_d,
   rel_way_wen_e,
   rel_way_wen_f,
   rel_way_wen_g,
   rel_way_wen_h,
   xu_lq_spr_xucr0_clfc,
   spr_xucr0_dcdis,
   spr_xucr0_cls,
   dcc_dir_ex2_binv_val,
   dcc_dir_ex2_thrd_id,
   ex2_eff_addr,
   dcc_dir_ex3_cache_acc,
   dcc_dir_ex3_pfetch_val,
   dcc_dir_ex3_lock_set,
   dcc_dir_ex3_th_c,
   dcc_dir_ex3_watch_set,
   dcc_dir_ex3_larx_val,
   dcc_dir_ex3_watch_chk,
   dcc_dir_ex4_load_val,
   derat_dir_ex4_wimge_i,
   fgen_ex3_stg_flush,
   fgen_ex4_cp_flush,
   fgen_ex4_stg_flush,
   fgen_ex5_stg_flush,
   ex4_tag_perr_way,
   dat_ctl_dcarr_perr_way,
   ex4_way_cmp_a,
   ex4_way_cmp_b,
   ex4_way_cmp_c,
   ex4_way_cmp_d,
   ex4_way_cmp_e,
   ex4_way_cmp_f,
   ex4_way_cmp_g,
   ex4_way_cmp_h,
   stq3_way_cmp_a,
   stq3_way_cmp_b,
   stq3_way_cmp_c,
   stq3_way_cmp_d,
   stq3_way_cmp_e,
   stq3_way_cmp_f,
   stq3_way_cmp_g,
   stq3_way_cmp_h,
   stq3_tag_way_perr,
   pc_lq_inj_dcachedir_ldp_multihit,
   pc_lq_inj_dcachedir_stp_multihit,
   dir_dcc_ex5_way_a_dir,
   dir_dcc_ex5_way_b_dir,
   dir_dcc_ex5_way_c_dir,
   dir_dcc_ex5_way_d_dir,
   dir_dcc_ex5_way_e_dir,
   dir_dcc_ex5_way_f_dir,
   dir_dcc_ex5_way_g_dir,
   dir_dcc_ex5_way_h_dir,
   ex4_way_hit_a,
   ex4_way_hit_b,
   ex4_way_hit_c,
   ex4_way_hit_d,
   ex4_way_hit_e,
   ex4_way_hit_f,
   ex4_way_hit_g,
   ex4_way_hit_h,
   ex4_miss,
   ex4_hit,
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
   ctl_perv_dir_perf_events,
   lq_xu_spr_xucr0_cslc_xuop,
   lq_xu_spr_xucr0_cslc_binv,
   dir_dcc_ex5_cr_rslt,
   stq2_ddir_acc,
   stq3_way_hit_a,
   stq3_way_hit_b,
   stq3_way_hit_c,
   stq3_way_hit_d,
   stq3_way_hit_e,
   stq3_way_hit_f,
   stq3_way_hit_g,
   stq3_way_hit_h,
   stq3_miss,
   stq3_hit,
   ctl_lsq_stq4_perr_reject,
   ctl_dat_stq5_way_perr_inval,
   rel_way_val_a,
   rel_way_val_b,
   rel_way_val_c,
   rel_way_val_d,
   rel_way_val_e,
   rel_way_val_f,
   rel_way_val_g,
   rel_way_val_h,
   rel_way_lock_a,
   rel_way_lock_b,
   rel_way_lock_c,
   rel_way_lock_d,
   rel_way_lock_e,
   rel_way_lock_f,
   rel_way_lock_g,
   rel_way_lock_h,
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
//parameter                         EXPAND_TYPE = 2;		// 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
//parameter                         THREADS = 2;
//parameter                         DC_SIZE = 15;		// 14 => 16K L1D$, 15 => 32K L1D$
//parameter                         CL_SIZE = 6;		// 6 => 64B CLINE, 7 => 128B CLINE

// ACT's
input                               dcc_dir_ex2_stg_act;
input                               dcc_dir_ex3_stg_act;
input                               dcc_dir_ex4_stg_act;
input                               dcc_dir_stq1_stg_act;
input                               dcc_dir_stq2_stg_act;
input                               dcc_dir_stq3_stg_act;
input                               dcc_dir_stq4_stg_act;
input                               dcc_dir_stq5_stg_act;
input                               dcc_dir_binv2_ex2_stg_act;
input                               dcc_dir_binv3_ex3_stg_act;
input                               dcc_dir_binv4_ex4_stg_act;
input                               dcc_dir_binv5_ex5_stg_act;
input                               dcc_dir_binv6_ex6_stg_act;

// Reload and Store Commit Pipe
input                               lsq_ctl_stq1_val;		                // Commit Operation is Valid
input                               lsq_ctl_stq2_blk_req;	                // Block Store due to RV issue
input [0:`THREADS-1]                lsq_ctl_stq1_thrd_id;
input [0:`THREADS-1]                lsq_ctl_rel1_thrd_id;
input                               lsq_ctl_stq1_ci;		                // Reload/Commit is Cache-Inhibited
input                               lsq_ctl_stq1_lock_clr;
input                               lsq_ctl_stq1_watch_clr;
input                               lsq_ctl_stq1_store_val;
input                               lsq_ctl_stq1_inval;
input                               lsq_ctl_stq1_dci_val;
input [0:1]                         lsq_ctl_stq1_l_fld;
input [64-(`DC_SIZE-3):63-`CL_SIZE] lsq_ctl_stq1_addr;
input                               lsq_ctl_rel1_clr_val;	                // Reload data is valid for 1st beat
input                               lsq_ctl_rel1_set_val;	                // Reload data is valid for last beat
input                               lsq_ctl_rel1_back_inv;	                // Reload was Back-Invalidated
input                               lsq_ctl_rel2_blk_req;	                // Block Reload due to RV issue or Back-Invalidate
input                               lsq_ctl_rel1_lock_set;
input                               lsq_ctl_rel1_watch_set;
input                               lsq_ctl_rel2_upd_val;	                // all 8 data beats have transferred without error, set valid in dir
input                               lsq_ctl_rel3_l1dump_val;		        // Reload Complete for an L1_DUMP reload
input                               dcc_dir_stq6_store_val;

input                               rel_way_clr_a;		                    // Reload Stage2 Way A clear existing Valid
input                               rel_way_clr_b;		                    // Reload Stage2 Way B clear existing Valid
input                               rel_way_clr_c;		                    // Reload Stage2 Way C clear existing Valid
input                               rel_way_clr_d;		                    // Reload Stage2 Way D clear existing Valid
input                               rel_way_clr_e;		                    // Reload Stage2 Way E clear existing Valid
input                               rel_way_clr_f;		                    // Reload Stage2 Way F clear existing Valid
input                               rel_way_clr_g;		                    // Reload Stage2 Way G clear existing Valid
input                               rel_way_clr_h;		                    // Reload Stage2 Way H clear existing Valid

input                               rel_way_wen_a;		                    // Reload Stage4 Way A Write Enable
input                               rel_way_wen_b;		                    // Reload Stage4 Way B Write Enable
input                               rel_way_wen_c;		                    // Reload Stage4 Way C Write Enable
input                               rel_way_wen_d;		                    // Reload Stage4 Way D Write Enable
input                               rel_way_wen_e;		                    // Reload Stage4 Way E Write Enable
input                               rel_way_wen_f;		                    // Reload Stage4 Way F Write Enable
input                               rel_way_wen_g;		                    // Reload Stage4 Way G Write Enable
input                               rel_way_wen_h;		                    // Reload Stage4 Way H Write Enable

input                               xu_lq_spr_xucr0_clfc;		            // Cache Lock Bits Flash Clear
input                               spr_xucr0_dcdis;		                // Data Cache Disable
input                               spr_xucr0_cls;		                    // 128Byte Cacheline Mode

// Execution Pipe
input                               dcc_dir_ex2_binv_val;		            // Back-Invalidate is Valid
input [0:`THREADS-1]                dcc_dir_ex2_thrd_id;		            // Thread ID
input [64-(`DC_SIZE-3):63-`CL_SIZE] ex2_eff_addr;
input                               dcc_dir_ex3_cache_acc;		            // Cache Access is Valid
input                               dcc_dir_ex3_pfetch_val;                 // Prefetch is Valid
input                               dcc_dir_ex3_lock_set;		            // DCBT[ST]LS Operation is valid
input                               dcc_dir_ex3_th_c;		                // DCBT[ST]LS Operation is targeting the L1 Data Cache
input                               dcc_dir_ex3_watch_set;		            // LDAWX Operation is valid
input                               dcc_dir_ex3_larx_val;		            // LARX Operation is valid, the directory should be invalidated if hit
input                               dcc_dir_ex3_watch_chk;		            // WCHK Operation is valid
input                               dcc_dir_ex4_load_val;
input                               derat_dir_ex4_wimge_i;		            // Cache-Inhibited Request

// Execution Pipe Flush
input                               fgen_ex3_stg_flush;		                // ex3 Stage Flush
input                               fgen_ex4_cp_flush;                      // ex4 CP Flush
input                               fgen_ex4_stg_flush;		                // ex4 Stage Flush
input                               fgen_ex5_stg_flush;		                // ex5 Stage Flush

// Directory Parity Error for Execution Pipe
input [0:7]                         ex4_tag_perr_way;		                // Directory Way with Parity Error
input [0:7]                         dat_ctl_dcarr_perr_way;		            // Data Cache Parity on a Way

// Tag Compares
input                               ex4_way_cmp_a;		                    // Way A Compared
input                               ex4_way_cmp_b;		                    // Way B Compared
input                               ex4_way_cmp_c;		                    // Way C Compared
input                               ex4_way_cmp_d;		                    // Way D Compared
input                               ex4_way_cmp_e;		                    // Way E Compared
input                               ex4_way_cmp_f;		                    // Way F Compared
input                               ex4_way_cmp_g;		                    // Way G Compared
input                               ex4_way_cmp_h;		                    // Way H Compared

// Commit Pipe
input                               stq3_way_cmp_a;		                    // Way A Compared
input                               stq3_way_cmp_b;		                    // Way B Compared
input                               stq3_way_cmp_c;		                    // Way C Compared
input                               stq3_way_cmp_d;		                    // Way D Compared
input                               stq3_way_cmp_e;		                    // Way E Compared
input                               stq3_way_cmp_f;		                    // Way F Compared
input                               stq3_way_cmp_g;		                    // Way G Compared
input                               stq3_way_cmp_h;		                    // Way H Compared

// Directory Parity Error for Store Commit Pipe
input [0:7]                         stq3_tag_way_perr;

// Multihit Error Inject
input                               pc_lq_inj_dcachedir_ldp_multihit;       // Load Pipe Multihit Error Inject from PC
input                               pc_lq_inj_dcachedir_stp_multihit;		// Store Pipe Multihit Error Inject from PC

// L1 Directory Contents
output [0:1+`THREADS]               dir_dcc_ex5_way_a_dir;
output [0:1+`THREADS]               dir_dcc_ex5_way_b_dir;
output [0:1+`THREADS]               dir_dcc_ex5_way_c_dir;
output [0:1+`THREADS]               dir_dcc_ex5_way_d_dir;
output [0:1+`THREADS]               dir_dcc_ex5_way_e_dir;
output [0:1+`THREADS]               dir_dcc_ex5_way_f_dir;
output [0:1+`THREADS]               dir_dcc_ex5_way_g_dir;
output [0:1+`THREADS]               dir_dcc_ex5_way_h_dir;

// L1 Directory Hits
output                              ex4_way_hit_a;		                    // Way A Hit
output                              ex4_way_hit_b;		                    // Way B Hit
output                              ex4_way_hit_c;		                    // Way C Hit
output                              ex4_way_hit_d;		                    // Way D Hit
output                              ex4_way_hit_e;		                    // Way E Hit
output                              ex4_way_hit_f;		                    // Way F Hit
output                              ex4_way_hit_g;		                    // Way G Hit
output                              ex4_way_hit_h;		                    // Way H Hit

// ex4 Execution Pipe Command Outputs
output                              ex4_miss;		                        // Execution Pipe operation missed in D$
output                              ex4_hit;		                        // Execution Pipe operation hit in D$
output                              dir_dcc_ex4_set_rel_coll;		        // Resource Conflict, should cause a reject
output                              dir_dcc_ex4_byp_restart;		        // Directory Bypassed stage that was restarted
output                              dir_dcc_ex5_dir_perr_det;		        // Data Directory Parity Error Detected on the LDQ Pipeline
output                              dir_dcc_ex5_dc_perr_det;		        // Data Cache Parity Error Detected on the LDQ Pipeline
output                              dir_dcc_ex5_dir_perr_flush;	      	    // Data Directory Parity Error Flush on the LDQ Pipeline
output                              dir_dcc_ex5_dc_perr_flush;	      	    // Data Cache Parity Error Flush on the LDQ Pipeline
output                              dir_dcc_ex5_multihit_det;		        // Directory Multihit Detected on the LDQ Pipeline
output                              dir_dcc_ex5_multihit_flush;	      	    // Directory Multihit Flush on the LDQ Pipeline
output                              dir_dcc_stq4_dir_perr_det;	      	    // Data Cache Parity Error Detected on the STQ Commit Pipeline
output                              dir_dcc_stq4_multihit_det;	      	    // Directory Multihit Detected on the STQ Commit Pipeline
output                              dir_dcc_ex5_stp_flush;                  // Directory Error detected on the STQ Commit Pipeline with EX5 LDP valid

// Performance Events
output [0:(`THREADS*3)+1]           ctl_perv_dir_perf_events;		        // Performance Events

// SPR status
output                              lq_xu_spr_xucr0_cslc_xuop;		        // Invalidate type instruction invalidated lock
output                              lq_xu_spr_xucr0_cslc_binv;		        // Back-Invalidate invalidated lock

// ex5 Execution Pipe Command Outputs
output                              dir_dcc_ex5_cr_rslt;		            // Condition Register Results from Watch instructions

// stq4 Recirculation Pipe Command Outputs
output                              stq2_ddir_acc;                          // Directory Array Access is valid
output                              stq3_way_hit_a;		                    // Way A Hit
output                              stq3_way_hit_b;		                    // Way B Hit
output                              stq3_way_hit_c;		                    // Way C Hit
output                              stq3_way_hit_d;		                    // Way D Hit
output                              stq3_way_hit_e;		                    // Way E Hit
output                              stq3_way_hit_f;		                    // Way F Hit
output                              stq3_way_hit_g;		                    // Way G Hit
output                              stq3_way_hit_h;		                    // Way H Hit
output                              stq3_miss;		                        // Recirculation Pipe operation missed in L1 D$
output                              stq3_hit;		                        // Recirculation Pipe operation hit in L1 D$
output                              ctl_lsq_stq4_perr_reject;               // STQ4 detected a parity error, need to reject STQ2 Commit
output [0:7]                        ctl_dat_stq5_way_perr_inval;            // STQ5 Gate Data Cache Write due to Directory Error

// Way Valids for Replacement Algorithm
output                              rel_way_val_a;		                    // Way A Valid for Replacement algorithm
output                              rel_way_val_b;		                    // Way B Valid for Replacement algorithm
output                              rel_way_val_c;		                    // Way C Valid for Replacement algorithm
output                              rel_way_val_d;		                    // Way D Valid for Replacement algorithm
output                              rel_way_val_e;		                    // Way E Valid for Replacement algorithm
output                              rel_way_val_f;		                    // Way F Valid for Replacement algorithm
output                              rel_way_val_g;		                    // Way G Valid for Replacement algorithm
output                              rel_way_val_h;		                    // Way H Valid for Replacement algorithm

// Congruence Class Line Lock
output                              rel_way_lock_a;		                    // Way A Locked Line for Replacement algorithm
output                              rel_way_lock_b;		                    // Way B Locked Line for Replacement algorithm
output                              rel_way_lock_c;		                    // Way C Locked Line for Replacement algorithm
output                              rel_way_lock_d;		                    // Way D Locked Line for Replacement algorithm
output                              rel_way_lock_e;		                    // Way E Locked Line for Replacement algorithm
output                              rel_way_lock_f;		                    // Way F Locked Line for Replacement algorithm
output                              rel_way_lock_g;		                    // Way G Locked Line for Replacement algorithm
output                              rel_way_lock_h;		                    // Way H Locked Line for Replacement algorithm

//pervasive


inout                               vdd;


inout                               gnd;

(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

input [0:`NCLK_WIDTH-1]             nclk;
input                               sg_0;
input                               func_sl_thold_0_b;
input                               func_sl_force;
input                               func_slp_sl_thold_0_b;
input                               func_slp_sl_force;
input                               func_nsl_thold_0_b;
input                               func_nsl_force;
input                               func_slp_nsl_thold_0_b;
input                               func_slp_nsl_force;
input                               d_mode_dc;
input                               delay_lclkr_dc;
input                               mpw1_dc_b;
input                               mpw2_dc_b;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input [0:2]                         scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output [0:2]                        scan_out;

//--------------------------
// components
//--------------------------

//--------------------------
// signals
//--------------------------
parameter                         uprCClassBit = 64 - (`DC_SIZE - 3);
parameter                         lwrCClassBit = 63 - `CL_SIZE;
parameter                         numCClass = ((2 ** `DC_SIZE)/(2 ** `CL_SIZE))/8;
parameter                         dirState = 2 + `THREADS;
parameter                         numWays = 8;


wire [0:dirState-1]               congr_cl_wA_d[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wA_q[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wB_d[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wB_q[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wC_d[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wC_q[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wD_d[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wD_q[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wE_d[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wE_q[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wF_d[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wF_q[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wG_d[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wG_q[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wH_d[0:numCClass-1];
wire [0:dirState-1]               congr_cl_wH_q[0:numCClass-1];
wire [0:1]                        rel_bixu_wayA_upd[0:numCClass-1];
wire [0:1]                        rel_bixu_wayB_upd[0:numCClass-1];
wire [0:1]                        rel_bixu_wayC_upd[0:numCClass-1];
wire [0:1]                        rel_bixu_wayD_upd[0:numCClass-1];
wire [0:1]                        rel_bixu_wayE_upd[0:numCClass-1];
wire [0:1]                        rel_bixu_wayF_upd[0:numCClass-1];
wire [0:1]                        rel_bixu_wayG_upd[0:numCClass-1];
wire [0:1]                        rel_bixu_wayH_upd[0:numCClass-1];
wire [0:numWays-1]                p0_way_data_upd_way[0:numCClass-1];
wire [0:numWays-1]                p1_way_data_upd_way[0:numCClass-1];
wire [0:numCClass-1]              p0_congr_cl_m;
wire [0:numCClass-1]              p1_congr_cl_m;
wire [0:numCClass-1]              p0_congr_cl_act_d;
wire [0:numCClass-1]              p0_congr_cl_act_q;
wire [0:numCClass-1]              p1_congr_cl_act_d;
wire [0:numCClass-1]              p1_congr_cl_act_q;
wire [0:numCClass-1]              congr_cl_act;
wire [0:numWays-1]                rel_way_clr;
wire [0:numWays-1]                rel_way_set;
reg  [0:dirState-1]               p0_arr_way_rd[0:numWays-1];
reg  [0:dirState-1]               p1_arr_way_rd[0:numWays-1];
wire [0:numWays-1]                ex4_way_hit;
wire [0:numWays-1]                ex4_way_cmp;
wire [0:4]                        congr_cl_ex3_way_byp[0:numWays-1];
wire [1:4]                        congr_cl_ex3_way_sel[0:numWays-1];
wire [0:numWays-1]                ex3_way_arr_sel;
wire [0:dirState-1]               ex3_way_stg_pri[0:numWays-1];
wire [0:dirState-1]               ex4_way_val_d[0:numWays-1];
wire [0:dirState-1]               ex4_way_val_q[0:numWays-1];
wire [0:dirState-1]               ex5_way_val_d[0:numWays-1];
wire [0:dirState-1]               ex5_way_val_q[0:numWays-1];
wire [0:numWays-1]                ex5_clr_lck_way_d;
wire [0:numWays-1]                ex5_clr_lck_way_q;
wire [0:`THREADS-1]               ex5_lost_way[0:numWays-1];
wire [0:numWays-1]                ex5_way_upd;
wire [0:numWays-1]                ex5_way_upd_d;
wire [0:numWays-1]                ex5_way_upd_q;
wire [0:numWays-1]                ex6_way_upd_d;
wire [0:numWays-1]                ex6_way_upd_q;
wire [0:numWays-1]                ex7_way_upd_d;
wire [0:numWays-1]                ex7_way_upd_q;
wire [0:dirState-1]               ex4_dir_way[0:numWays-1];
wire [0:dirState-1]               ex5_dir_way_err[0:numWays-1];
wire [0:dirState-1]               ex5_dir_way_d[0:numWays-1];
wire [0:dirState-1]               ex5_dir_way_q[0:numWays-1];
wire [0:dirState-1]               ex6_dir_way_d[0:numWays-1];
wire [0:dirState-1]               ex6_dir_way_q[0:numWays-1];
wire [2:dirState-1]               ex7_dir_way_d[0:numWays-1];
wire [2:dirState-1]               ex7_dir_way_q[0:numWays-1];
wire [0:numWays-1]                ex4_way_watch;
wire [0:numWays-1]                ex4_way_lock;
wire [0:`THREADS-1]               ex4_err_way_watchlost[0:numWays-1];
wire [0:4]                        congr_cl_stq2_way_byp[0:numWays-1];
wire [1:4]                        congr_cl_stq2_way_sel[0:numWays-1];
wire [0:numWays-1]                stq2_way_arr_sel;
wire [0:dirState-1]               stq2_way_stg_pri[0:numWays-1];
wire [0:dirState-1]               stq3_way_val_d[0:numWays-1];
wire [0:dirState-1]               stq3_way_val_q[0:numWays-1];
wire [2:dirState-1]               stq4_way_val_d[0:numWays-1];
wire [2:dirState-1]               stq4_way_val_q[0:numWays-1];
wire [0:numWays-1]                stq3_way_hit;
wire [0:numWays-1]                stq3_way_cmp;
wire [0:dirState-1]               stq3_dir_way[0:numWays-1];
wire [0:dirState-1]               stq4_dir_way_d[0:numWays-1];
wire [0:dirState-1]               stq4_dir_way_q[0:numWays-1];
wire [0:dirState-1]               stq4_dir_way_err[0:numWays-1];
wire [0:dirState-1]               stq5_dir_way_d[0:numWays-1];
wire [0:dirState-1]               stq5_dir_way_q[0:numWays-1];
wire [0:numWays-1]                stq2_ex5_ldp_err;
wire [0:numWays-1]                stq3_ex6_ldp_err_d;
wire [0:numWays-1]                stq3_ex6_ldp_err_q;
wire [0:numWays-1]                stq4_ex7_ldp_err_d;
wire [0:numWays-1]                stq4_ex7_ldp_err_q;
wire [0:numWays-1]                stq3_ex5_ldp_err;
wire [0:numWays-1]                stq4_ex6_ldp_err_d;
wire [0:numWays-1]                stq4_ex6_ldp_err_q;
wire [0:numWays-1]                stq4_ex5_ldp_err;
wire [0:numWays-1]                stq4_ex_ldp_err_det;


wire [0:numWays-1]                stq2_stq4_stp_err;
wire [0:numWays-1]                stq3_stq5_stp_err_d;
wire [0:numWays-1]                stq3_stq5_stp_err_q;
wire [0:numWays-1]                stq4_stq6_stp_err_d;
wire [0:numWays-1]                stq4_stq6_stp_err_q;
wire [0:numWays-1]                stq3_stq4_stp_err;
wire [0:numWays-1]                stq4_stq5_stp_err_d;
wire [0:numWays-1]                stq4_stq5_stp_err_q;
wire [0:numWays-1]                stq4_stq_stp_err_det;


wire [0:numWays-1]                stq3_way_lock;
wire [0:numWays-1]                stq4_clr_lck_way_d;
wire [0:numWays-1]                stq4_clr_lck_way_q;
wire [0:numWays-1]                stq4_lose_watch_way;
wire [0:`THREADS-1]               stq4_lost_way[0:numWays-1];
wire [0:`THREADS-1]               rel_lost_watch_way_evict[0:numWays-1];
wire [0:`THREADS-1]               ex7_lost_watch_way_evict[0:numWays-1];
wire [0:numWays-1]                stq3_way_upd;
wire [0:numWays-1]                stq4_way_upd;
wire [0:numWays-1]                stq4_way_upd_d;
wire [0:numWays-1]                stq4_way_upd_q;
wire [0:numWays-1]                stq5_way_upd_d;
wire [0:numWays-1]                stq5_way_upd_q;
wire [0:numWays-1]                stq6_way_upd_d;
wire [0:numWays-1]                stq6_way_upd_q;
wire [0:numWays-1]                stq7_way_upd_d;
wire [0:numWays-1]                stq7_way_upd_q;
wire [0:numWays-1]                stq4_rel_way_clr_d;
wire [0:numWays-1]                stq4_rel_way_clr_q;
wire [0:dirState-1]               stq4_dir_way_rel[0:numWays-1];
wire [0:`THREADS-1]               stq3_err_way_watchlost[0:numWays-1];
wire                              ex4_cache_acc_d;
wire                              ex4_cache_acc_q;
wire                              ex5_cache_acc_d;
wire                              ex5_cache_acc_q;
wire                              ex5_mhit_cacc_d;
wire                              ex5_mhit_cacc_q;
wire                              ex4_pfetch_val_d;
wire                              ex4_pfetch_val_q;
wire                              ex4_cache_en_val;
wire                              ex3_binv_val_d;
wire                              ex3_binv_val_q;
wire                              ex4_binv_val_d;
wire                              ex4_binv_val_q;
wire                              ex5_binv_val_d;
wire                              ex5_binv_val_q;
wire [0:`THREADS-1]               ex2_thrd_id;
wire [0:`THREADS-1]               ex3_thrd_id_d;
wire [0:`THREADS-1]               ex3_thrd_id_q;
wire [0:`THREADS-1]               ex4_thrd_id_d;
wire [0:`THREADS-1]               ex4_thrd_id_q;
wire [0:`THREADS-1]               ex5_thrd_id_d;
wire [0:`THREADS-1]               ex5_thrd_id_q;
wire                              ex3_lock_set;
wire                              ex4_lock_set_d;
wire                              ex4_lock_set_q;
wire                              ex5_lock_set_d;
wire                              ex5_lock_set_q;
wire                              ex4_watch_set_d;
wire                              ex4_watch_set_q;
wire                              ex5_watch_set_d;
wire                              ex5_watch_set_q;
wire                              ex6_watch_set_d;
wire                              ex6_watch_set_q;
wire                              ex4_larx_val_d;
wire                              ex4_larx_val_q;
wire                              ex7_watch_set_inval_d;
wire                              ex7_watch_set_inval_q;
wire                              ex4_clr_watch;
wire [0:`THREADS-1]               ex4_set_watch;
wire                              ex5_lose_watch_d;
wire                              ex5_lose_watch_q;
wire                              ex4_clr_val_way;
wire                              ex4_xuop_upd_val;
wire                              ex4_xuop_upd_val_d;
wire                              ex4_xuop_upd_val_q;
wire                              ex5_xuop_upd_val;
wire                              ex5_xuop_upd_val_d;
wire                              ex5_xuop_upd_val_q;
wire                              binv4_ex4_xuop_upd;
wire                              binv4_ex4_dir_val;
wire                              binv5_ex5_dir_val_d;
wire                              binv5_ex5_dir_val_q;
wire [0:numWays-1]                ex5_way_hit_d;
wire [0:numWays-1]                ex5_way_hit_q;
wire [uprCClassBit:lwrCClassBit]  ex2_congr_cl;
wire [uprCClassBit:lwrCClassBit]  ex3_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]  ex3_congr_cl_q;
wire [0:numCClass-1]              ex3_congr_cl_1hot;
wire [uprCClassBit:lwrCClassBit]  ex4_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]  ex4_congr_cl_q;
wire [uprCClassBit:lwrCClassBit]  ex5_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]  ex5_congr_cl_q;
wire [0:numWays-1]                ex4_dcarr_perr_way;
wire [0:numWays-1]                stq6_dcarr_perr_way;
wire [0:numWays-1]                ex4_perr_way;
wire                              ex5_cr_watch_d;
wire                              ex5_cr_watch_q;
wire                              congr_cl_ex3_ex4_cmp_d;
wire                              congr_cl_ex3_ex4_cmp_q;
wire                              congr_cl_ex3_ex5_cmp_d;
wire                              congr_cl_ex3_ex5_cmp_q;
wire                              congr_cl_ex3_ex6_cmp_d;
wire                              congr_cl_ex3_ex6_cmp_q;
wire                              congr_cl_ex3_stq4_cmp_d;
wire                              congr_cl_ex3_stq4_cmp_q;
wire                              congr_cl_ex3_stq5_cmp_d;
wire                              congr_cl_ex3_stq5_cmp_q;
wire                              congr_cl_ex4_ex5_cmp_d;
wire                              congr_cl_ex4_ex5_cmp_q;
wire                              congr_cl_ex4_ex6_cmp_d;
wire                              congr_cl_ex4_ex6_cmp_q;
wire                              congr_cl_ex5_ex6_cmp_d;
wire                              congr_cl_ex5_ex6_cmp_q;
wire                              congr_cl_ex5_ex7_cmp_d;
wire                              congr_cl_ex5_ex7_cmp_q;
wire                              congr_cl_ex5_stq5_cmp_d;
wire                              congr_cl_ex5_stq5_cmp_q;
wire                              congr_cl_ex5_stq6_cmp_d;
wire                              congr_cl_ex5_stq6_cmp_q;
wire                              congr_cl_ex5_stq7_cmp_d;
wire                              congr_cl_ex5_stq7_cmp_q;
wire                              congr_cl_ex4_ex6_rest_d;
wire                              congr_cl_ex4_ex6_rest_q;
wire                              congr_cl_ex4_byp_restart;
wire                              congr_cl_ex3_ex4_m;
wire                              congr_cl_ex3_ex5_m;
wire                              congr_cl_ex3_ex6_m;
wire                              congr_cl_ex3_stq4_m;
wire                              congr_cl_ex3_stq5_m;
wire                              ex5_inval_clr_lock;
wire                              ex5_cClass_lock_set_d;
wire                              ex5_cClass_lock_set_q;
wire [0:`THREADS-1]               stq4_dci_watch_lost;
reg  [0:`THREADS-1]               ex5_lost_watch;
wire [0:`THREADS-1]               ex5_watchlost_binv;
reg  [0:`THREADS-1]               ex5_cClass_thrd_watch_d;
wire [0:`THREADS-1]               ex5_cClass_thrd_watch_q;
wire [0:`THREADS-1]               ex5_watchlost_upd;
wire [0:`THREADS-1]               ex5_watchlost_set;
wire                              ex4_curr_watch;
wire                              ex4_stm_watchlost_sel;
wire                              ex4_hit_and_01_b;
wire                              ex4_hit_and_23_b;
wire                              ex4_hit_and_45_b;
wire                              ex4_hit_and_67_b;
wire                              ex4_hit_or_01_b;
wire                              ex4_hit_or_23_b;
wire                              ex4_hit_or_45_b;
wire                              ex4_hit_or_67_b;
wire                              ex4_hit_or_0123;
wire                              ex4_hit_or_4567;
wire                              ex4_hit_and_0123;
wire                              ex4_hit_and_4567;
wire                              ex4_multi_hit_err2_0;
wire                              ex4_multi_hit_err2_1;
wire                              ex4_hit_or_01234567_b;
wire [0:2]                        ex4_multi_hit_err3_b;
wire                              ex4_dir_multihit_val_0;
wire                              ex4_dir_multihit_val_1;
wire                              ex4_dir_multihit_val_b;
wire                              ex5_dir_multihit_val_b_d;
wire                              ex5_dir_multihit_val_b_q;
wire                              ex5_dir_multihit_val;
wire                              ex5_dir_multihit_det;
wire                              ex5_dir_multihit_flush;
wire                              ex5_multihit_lock_lost;
wire [0:`THREADS-1]               ex5_multihit_watch_lost;
wire [0:7]                        ex4_dir_perr_det;
wire [0:7]                        ex4_dc_perr_det;
wire [0:7]                        ex4_err_det_way;
wire [0:7]                        ex5_err_det_way_d;
wire [0:7]                        ex5_err_det_way_q;
wire [0:7]                        ex4_err_lock_lost;
wire                              ex5_perr_lock_lost_d;
wire                              ex5_perr_lock_lost_q;
reg  [0:`THREADS-1]               ex5_perr_watchlost_d;
wire [0:`THREADS-1]               ex5_perr_watchlost_q;
wire                              ex5_dir_perr_det_d;
wire                              ex5_dir_perr_det_q;
wire                              ex5_dc_perr_det_d;
wire                              ex5_dc_perr_det_q;
wire                              ex5_dir_perr_flush_d;
wire                              ex5_dir_perr_flush_q;
wire                              ex5_dc_perr_flush_d;
wire                              ex5_dc_perr_flush_q;
wire                              ex5_way_perr_det_d;
wire                              ex5_way_perr_det_q;
wire [0:numWays-1]                ex5_way_perr_inval;
wire                              ex5_xuop_perr_det;
wire                              ex5_way_err_val;
wire                              ex4_stq2_congr_cl_m_d;
wire                              ex4_stq2_congr_cl_m_q;
wire                              ex4_stq2_set_rel_coll;
wire                              ex4_stq3_set_rel_coll_d;
wire                              ex4_stq3_set_rel_coll_q;
wire                              ex4_stq4_set_rel_coll_d;
wire                              ex4_stq4_set_rel_coll_q;
wire                              ex4_lockwatchSet_rel_coll;
wire [0:numWays-1]                binv5_ex5_way_upd;
wire [0:numWays-1]                binv6_ex6_way_upd;
wire [0:numWays-1]                binv7_ex7_way_upd;
wire [0:numWays-1]                stq5_way_upd;
wire [0:numWays-1]                stq6_way_upd;
wire [0:numWays-1]                stq7_way_upd;
reg  [1:dirState-1]               binv5_ex5_dir_data;
wire [1:dirState-1]               binv6_ex6_dir_data_d;
wire [1:dirState-1]               binv6_ex6_dir_data_q;
wire [1:dirState-1]               binv7_ex7_dir_data_d;
wire [1:dirState-1]               binv7_ex7_dir_data_q;
reg  [1:dirState-1]               stq5_dir_data;
wire [1:dirState-1]               stq6_dir_data_d;
wire [1:dirState-1]               stq6_dir_data_q;
wire [1:dirState-1]               stq7_dir_data_d;
wire [1:dirState-1]               stq7_dir_data_q;
wire                              binv5_inval_lck;
wire                              binv5_inval_lock_val;
wire [0:`THREADS-1]               binv5_inval_watch;
wire [0:`THREADS-1]               binv5_inval_watch_val;
wire                              binv5_ex6_coll;
wire                              binv5_ex7_coll;
wire                              binv5_stq5_coll;
wire                              binv5_stq6_coll;
wire                              binv5_stq7_coll;
wire                              binv5_coll_val;
wire [0:4]                        binv5_pri_byp_sel;
wire [1:dirState-1]               binv5_byp_dir_data;
wire                              stq2_ci_d;
wire                              stq2_ci_q;
wire                              stq2_cen_acc;
wire                              stq2_cen_acc_d;
wire                              stq2_cen_acc_q;
wire                              stq2_dci_val_d;
wire                              stq2_dci_val_q;
wire                              stq3_dci_val_d;
wire                              stq3_dci_val_q;
wire                              stq4_dci_val_d;
wire                              stq4_dci_val_q;
wire                              stq2_val;
wire                              stq2_val_d;
wire                              stq2_val_q;
wire                              stq3_val_d;
wire                              stq3_val_q;
wire                              stq4_val_d;
wire                              stq4_val_q;
wire [0:`THREADS-1]               stq2_thrd_id_d;
wire [0:`THREADS-1]               stq2_thrd_id_q;
wire [0:`THREADS-1]               stq3_thrd_id_d;
wire [0:`THREADS-1]               stq3_thrd_id_q;
wire [0:`THREADS-1]               stq4_thrd_id_d;
wire [0:`THREADS-1]               stq4_thrd_id_q;
wire [0:`THREADS-1]               rel2_thrd_id_d;
wire [0:`THREADS-1]               rel2_thrd_id_q;
wire [0:`THREADS-1]               rel3_thrd_id_d;
wire [0:`THREADS-1]               rel3_thrd_id_q;
wire                              stq2_lock_clr_d;
wire                              stq2_lock_clr_q;
wire                              stq3_lock_clr_d;
wire                              stq3_lock_clr_q;
wire                              stq2_watch_clr_d;
wire                              stq2_watch_clr_q;
wire                              stq3_watch_clr_d;
wire                              stq3_watch_clr_q;
wire                              stq2_store_val_d;
wire                              stq2_store_val_q;
wire                              stq3_store_val_d;
wire                              stq3_store_val_q;
wire                              stq2_l_fld_b1_d;
wire                              stq2_l_fld_b1_q;
wire                              stq3_l_fld_b1_d;
wire                              stq3_l_fld_b1_q;
wire                              stq4_l_fld_b1_d;
wire                              stq4_l_fld_b1_q;
wire                              stq2_inval_op_d;
wire                              stq2_inval_op_q;
wire                              stq3_inval_op_d;
wire                              stq3_inval_op_q;
wire                              stq1_watch_clr_all;
wire                              stq2_watch_clr_all_d;
wire                              stq2_watch_clr_all_q;
wire                              stq3_watch_clr_all_d;
wire                              stq3_watch_clr_all_q;
wire                              stq4_watch_clr_all_d;
wire                              stq4_watch_clr_all_q;
wire [uprCClassBit:lwrCClassBit]  stq1_congr_cl;
wire [uprCClassBit:lwrCClassBit]  stq2_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]  stq2_congr_cl_q;
wire [0:numCClass-1]              stq2_congr_cl_1hot;
wire [uprCClassBit:lwrCClassBit]  stq3_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]  stq3_congr_cl_q;
wire [uprCClassBit:lwrCClassBit]  stq4_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]  stq4_congr_cl_q;
wire [uprCClassBit:lwrCClassBit]  stq5_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]  stq5_congr_cl_q;
wire [uprCClassBit:lwrCClassBit]  stq6_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]  stq6_congr_cl_q;
wire                              rel2_clr_stg_val;
wire                              rel2_clr_stg_val_d;
wire                              rel2_clr_stg_val_q;
wire                              rel3_clr_stg_val_d;
wire                              rel3_clr_stg_val_q;
wire                              rel4_clr_stg_val_d;
wire                              rel4_clr_stg_val_q;
wire                              rel5_clr_stg_val_d;
wire                              rel5_clr_stg_val_q;
wire                              rel2_set_dir_val;
wire                              rel3_set_dir_val_d;
wire                              rel3_set_dir_val_q;
wire                              rel4_set_dir_val_d;
wire                              rel4_set_dir_val_q;
wire                              rel2_set_stg_val_d;
wire                              rel2_set_stg_val_q;
wire                              rel3_set_stg_val_d;
wire                              rel3_set_stg_val_q;
wire                              rel2_back_inv_d;
wire                              rel2_back_inv_q;
wire                              rel3_back_inv_d;
wire                              rel3_back_inv_q;
wire                              rel3_upd_val_d;
wire                              rel3_upd_val_q;
wire                              rel2_lock_set_d;
wire                              rel2_lock_set_q;
wire                              rel3_lock_set_d;
wire                              rel3_lock_set_q;
wire                              rel3_lock_pipe_d;
wire                              rel3_lock_pipe_q;
wire                              rel2_watch_set_d;
wire                              rel2_watch_set_q;
wire                              rel3_watch_set_d;
wire                              rel3_watch_set_q;
wire                              rel3_watch_pipe_d;
wire                              rel3_watch_pipe_q;
wire                              stq2_dir_upd_val;
wire                              stq3_dir_upd_val_d;
wire                              stq3_dir_upd_val_q;
wire                              stq4_dir_upd_val_d;
wire                              stq4_dir_upd_val_q;
wire                              stq3_rel3_val_d;
wire                              stq3_rel3_val_q;
wire                              stq4_rel4_val_d;
wire                              stq4_rel4_val_q;
wire                              stq3_clr_lock;
wire [0:`THREADS-1]               rel3_set_watch;
wire                              stq4_lose_watch_d;
wire                              stq4_lose_watch_q;
wire [0:`THREADS-1]               stq3_store_clr_watch;
wire [0:`THREADS-1]               stq3_wclr_clr_watch;
wire [0:`THREADS-1]               stq3_inval_clr_watch;
wire [0:`THREADS-1]               stq3_clr_watch;
wire [0:numWays-1]                stq4_way_hit_d;
wire [0:numWays-1]                stq4_way_hit_q;
wire                              congr_cl_stq2_stq3_cmp_d;
wire                              congr_cl_stq2_stq3_cmp_q;
wire                              congr_cl_stq2_stq4_cmp_d;
wire                              congr_cl_stq2_stq4_cmp_q;
wire                              congr_cl_stq2_stq5_cmp_d;
wire                              congr_cl_stq2_stq5_cmp_q;
wire                              congr_cl_stq3_stq4_cmp_d;
wire                              congr_cl_stq3_stq4_cmp_q;
wire                              congr_cl_stq2_ex5_cmp_d;
wire                              congr_cl_stq2_ex5_cmp_q;
wire                              congr_cl_stq2_ex6_cmp_d;
wire                              congr_cl_stq2_ex6_cmp_q;
wire                              congr_cl_stq3_ex6_cmp_d;
wire                              congr_cl_stq3_ex6_cmp_q;
wire                              congr_cl_stq3_ex5_cmp_d;
wire                              congr_cl_stq3_ex5_cmp_q;
wire                              congr_cl_stq4_ex5_cmp_d;
wire                              congr_cl_stq4_ex5_cmp_q;
wire                              congr_cl_stq2_stq3_m;
wire                              congr_cl_stq2_stq4_m;
wire                              congr_cl_stq2_stq5_m;
wire                              congr_cl_stq2_ex5_m;
wire                              congr_cl_stq2_ex6_m;
wire                              stq4_inval_clr_lock;
wire                              stq4_cClass_lock_set_d;
wire                              stq4_cClass_lock_set_q;
wire                              rel3_way_set;
wire                              rel3_binv_lock_lost;
wire                              rel3_l1dump_lock_lost;
wire                              binv_rel_lock_lost;
wire                              rel3_binv_watch_lost;
wire                              rel3_l1dump_watch_lost;
wire                              rel3_ovl_watch_lost;
wire [0:`THREADS-1]               rel3_all_watch_lost;
wire [0:`THREADS-1]               rel4_all_watch_lost_d;
wire [0:`THREADS-1]               rel4_all_watch_lost_q;
wire [0:`THREADS-1]               stq4_lost_watch;
reg  [0:`THREADS-1]               stq4_cClass_thrd_watch_d;
wire [0:`THREADS-1]               stq4_cClass_thrd_watch_q;
wire [0:`THREADS-1]               stq4_watchlost_value;
wire [0:`THREADS-1]               stq4_watch_clr_all;
wire [0:`THREADS-1]               stq4_watchlost_upd;
wire [0:`THREADS-1]               stq4_watchlost_set;
wire [0:`THREADS-1]               lost_watch_evict_ovl_d;
wire [0:`THREADS-1]               lost_watch_evict_ovl_q;
reg  [0:`THREADS-1]               stq4_instr_watch_lost;
reg  [0:`THREADS-1]               rel_lost_watch_evict;
reg  [0:`THREADS-1]               ex7_lost_watch_evict;
wire                              stq3_hit_and_01_b;
wire                              stq3_hit_and_23_b;
wire                              stq3_hit_and_45_b;
wire                              stq3_hit_and_67_b;
wire                              stq3_hit_or_01_b;
wire                              stq3_hit_or_23_b;
wire                              stq3_hit_or_45_b;
wire                              stq3_hit_or_67_b;
wire                              stq3_hit_or_0123;
wire                              stq3_hit_or_4567;
wire                              stq3_hit_and_0123;
wire                              stq3_hit_and_4567;
wire                              stq3_multi_hit_err2_0;
wire                              stq3_multi_hit_err2_1;
wire                              stq3_hit_or_01234567_b;
wire [0:2]                        stq3_multi_hit_err3_b;
wire                              stq3_dir_multihit_val_0;
wire                              stq3_dir_multihit_val_1;
wire                              stq3_dir_multihit_val_b;
wire                              stq4_dir_multihit_val_b_d;
wire                              stq4_dir_multihit_val_b_q;
wire                              stq4_dir_multihit_det;
wire                              stq4_multihit_lock_lost;
wire [0:`THREADS-1]               stq4_multihit_watch_lost;
wire [0:numWays-1]                stq3_err_det_way;
wire [0:numWays-1]                stq4_err_det_way_d;
wire [0:numWays-1]                stq4_err_det_way_q;
wire [0:numWays-1]                stq3_err_lock_lost;
wire                              stq4_perr_lock_lost_d;
wire                              stq4_perr_lock_lost_q;
reg  [0:`THREADS-1]               stq4_perr_watchlost_d;
wire [0:`THREADS-1]               stq4_perr_watchlost_q;
wire                              stq4_dir_perr_det_d;
wire                              stq4_dir_perr_det_q;
wire [0:numWays-1]                stq4_way_perr_inval;
wire [0:numWays-1]                stq5_way_perr_inval_d;
wire [0:numWays-1]                stq5_way_perr_inval_q;
wire                              stq4_dir_err_val;
wire                              stq5_dir_err_val_d;
wire                              stq5_dir_err_val_q;
wire                              ex5_stp_perr_flush_d;
wire                              ex5_stp_perr_flush_q;
wire                              ex5_stp_multihit_flush;
wire [0:1]                        stm_upd_watchlost_tid[0:`THREADS-1];
wire [0:`THREADS-1]               stm_watchlost;
wire [0:`THREADS-1]               stm_watchlost_state_d;
wire [0:`THREADS-1]               stm_watchlost_state_q;
wire                              p0_wren_d;
wire                              p0_wren_q;
wire                              p0_wren_cpy_d;
wire                              p0_wren_cpy_q;
wire                              p0_wren_stg_d;
wire                              p0_wren_stg_q;
wire                              p1_wren_d;
wire                              p1_wren_q;
wire                              p1_wren_cpy_d;
wire                              p1_wren_cpy_q;
wire                              stq6_wren_d;
wire                              stq6_wren_q;
wire                              stq7_wren_d;
wire                              stq7_wren_q;
wire                              congr_cl_all_act_d;
wire                              congr_cl_all_act_q;
wire                              lock_finval_d;
wire                              lock_finval_q;
wire                              val_finval_d;
wire                              val_finval_q;
wire [0:`THREADS-1]               watch_finval_d;
wire [0:`THREADS-1]               watch_finval_q;
wire                              spr_xucr0_clfc_d;
wire                              spr_xucr0_clfc_q;
wire                              inj_dirmultihit_ldp_b;
wire                              inj_dirmultihit_ldp_d;
wire                              inj_dirmultihit_ldp_q;
wire                              inj_dirmultihit_stp_b;
wire                              inj_dirmultihit_stp_d;
wire                              inj_dirmultihit_stp_q;
wire                              xucr0_cslc_xuop_d;
wire                              xucr0_cslc_xuop_q;
wire                              xucr0_cslc_binv_d;
wire                              xucr0_cslc_binv_q;
wire                              perf_dir_binv_val;
wire                              perf_dir_binv_hit;
wire [0:`THREADS-1]               perf_dir_interTid_watchlost;
wire [0:`THREADS-1]               perf_dir_evict_watchlost;
wire [0:`THREADS-1]               perf_dir_binv_watchlost;
wire [0:`THREADS-1]               lost_watch_inter_thrd_d;
wire [0:`THREADS-1]               lost_watch_inter_thrd_q;
wire [0:`THREADS-1]               lost_watch_evict_val_d;
wire [0:`THREADS-1]               lost_watch_evict_val_q;
wire [0:`THREADS-1]               lost_watch_binv_d;
wire [0:`THREADS-1]               lost_watch_binv_q;

//--------------------------
// constants
//--------------------------
parameter                         congr_cl_wA_offset = 0;
parameter                         congr_cl_wB_offset = congr_cl_wA_offset + numCClass*dirState;
parameter                         congr_cl_wC_offset = congr_cl_wB_offset + numCClass*dirState;
parameter                         congr_cl_wD_offset = congr_cl_wC_offset + numCClass*dirState;
parameter                         congr_cl_wE_offset = congr_cl_wD_offset + numCClass*dirState;
parameter                         congr_cl_wF_offset = congr_cl_wE_offset + numCClass*dirState;
parameter                         congr_cl_wG_offset = congr_cl_wF_offset + numCClass*dirState;
parameter                         congr_cl_wH_offset = congr_cl_wG_offset + numCClass*dirState;
parameter                         p0_congr_cl_act_offset = congr_cl_wH_offset + numCClass*dirState;
parameter                         p1_congr_cl_act_offset = p0_congr_cl_act_offset + numCClass;
parameter                         ex4_way_val_offset = p1_congr_cl_act_offset + numCClass;
parameter                         ex5_way_val_offset = ex4_way_val_offset + numWays*dirState;
parameter                         ex5_clr_lck_way_offset = ex5_way_val_offset + numWays*dirState;
parameter                         ex5_way_upd_offset = ex5_clr_lck_way_offset + numWays;
parameter                         ex6_way_upd_offset = ex5_way_upd_offset + numWays;
parameter                         ex7_way_upd_offset = ex6_way_upd_offset + numWays;
parameter                         ex5_dir_way_offset = ex7_way_upd_offset + numWays;
parameter                         ex6_dir_way_offset = ex5_dir_way_offset + numWays*dirState;
parameter                         ex7_dir_way_offset = ex6_dir_way_offset + numWays*dirState;
parameter                         stq3_way_val_offset = ex7_dir_way_offset + numWays*(dirState-2);
parameter                         stq4_way_val_offset = stq3_way_val_offset + numWays*dirState;
parameter                         stq4_dir_way_offset = stq4_way_val_offset + numWays*(dirState-2);
parameter                         stq5_dir_way_offset = stq4_dir_way_offset + numWays*dirState;
parameter                         stq3_ex6_ldp_err_offset = stq5_dir_way_offset + numWays*dirState;
parameter                         stq4_ex7_ldp_err_offset = stq3_ex6_ldp_err_offset + numWays;
parameter                         stq4_ex6_ldp_err_offset = stq4_ex7_ldp_err_offset + numWays;
parameter                         stq3_stq5_stp_err_offset = stq4_ex6_ldp_err_offset + numWays;
parameter                         stq4_stq6_stp_err_offset = stq3_stq5_stp_err_offset + numWays;
parameter                         stq4_stq5_stp_err_offset = stq4_stq6_stp_err_offset + numWays;
parameter                         stq4_clr_lck_way_offset = stq4_stq5_stp_err_offset + numWays;
parameter                         stq4_way_upd_offset = stq4_clr_lck_way_offset + numWays;
parameter                         stq5_way_upd_offset = stq4_way_upd_offset + numWays;
parameter                         stq6_way_upd_offset = stq5_way_upd_offset + numWays;
parameter                         stq7_way_upd_offset = stq6_way_upd_offset + numWays;
parameter                         stq4_rel_way_clr_offset = stq7_way_upd_offset + numWays;
parameter                         ex4_cache_acc_offset = stq4_rel_way_clr_offset + numWays;
parameter                         ex5_cache_acc_offset = ex4_cache_acc_offset + 1;
parameter                         ex5_mhit_cacc_offset = ex5_cache_acc_offset + 1;
parameter                         ex4_pfetch_val_offset = ex5_mhit_cacc_offset + 1;
parameter                         ex3_binv_val_offset = ex4_pfetch_val_offset + 1;
parameter                         ex4_binv_val_offset = ex3_binv_val_offset + 1;
parameter                         ex5_binv_val_offset = ex4_binv_val_offset + 1;
parameter                         ex3_thrd_id_offset = ex5_binv_val_offset + 1;
parameter                         ex4_thrd_id_offset = ex3_thrd_id_offset + `THREADS;
parameter                         ex5_thrd_id_offset = ex4_thrd_id_offset + `THREADS;
parameter                         ex4_lock_set_offset = ex5_thrd_id_offset + `THREADS;
parameter                         ex5_lock_set_offset = ex4_lock_set_offset + 1;
parameter                         ex4_watch_set_offset = ex5_lock_set_offset + 1;
parameter                         ex5_watch_set_offset = ex4_watch_set_offset + 1;
parameter                         ex6_watch_set_offset = ex5_watch_set_offset + 1;
parameter                         ex4_larx_val_offset = ex6_watch_set_offset + 1;
parameter                         ex7_watch_set_inval_offset = ex4_larx_val_offset + 1;
parameter                         ex5_lose_watch_offset = ex7_watch_set_inval_offset + 1;
parameter                         ex4_xuop_upd_val_offset = ex5_lose_watch_offset+ 1;
parameter                         ex5_xuop_upd_val_offset = ex4_xuop_upd_val_offset + 1;
parameter                         binv5_ex5_dir_val_offset = ex5_xuop_upd_val_offset + 1;
parameter                         ex5_way_hit_offset = binv5_ex5_dir_val_offset + 1;
parameter                         ex3_congr_cl_offset = ex5_way_hit_offset + numWays;
parameter                         ex4_congr_cl_offset = ex3_congr_cl_offset + (lwrCClassBit-uprCClassBit+1);
parameter                         ex5_congr_cl_offset = ex4_congr_cl_offset + (lwrCClassBit-uprCClassBit+1);
parameter                         ex5_cr_watch_offset = ex5_congr_cl_offset + (lwrCClassBit-uprCClassBit+1);
parameter                         congr_cl_ex3_ex4_cmp_offset = ex5_cr_watch_offset + 1;
parameter                         congr_cl_ex3_ex5_cmp_offset = congr_cl_ex3_ex4_cmp_offset + 1;
parameter                         congr_cl_ex3_ex6_cmp_offset = congr_cl_ex3_ex5_cmp_offset + 1;
parameter                         congr_cl_ex3_stq4_cmp_offset = congr_cl_ex3_ex6_cmp_offset + 1;
parameter                         congr_cl_ex3_stq5_cmp_offset = congr_cl_ex3_stq4_cmp_offset + 1;
parameter                         congr_cl_ex4_ex5_cmp_offset = congr_cl_ex3_stq5_cmp_offset + 1;
parameter                         congr_cl_ex4_ex6_cmp_offset = congr_cl_ex4_ex5_cmp_offset + 1;
parameter                         congr_cl_ex5_ex6_cmp_offset = congr_cl_ex4_ex6_cmp_offset + 1;
parameter                         congr_cl_ex5_ex7_cmp_offset = congr_cl_ex5_ex6_cmp_offset + 1;
parameter                         congr_cl_ex5_stq5_cmp_offset = congr_cl_ex5_ex7_cmp_offset + 1;
parameter                         congr_cl_ex5_stq6_cmp_offset = congr_cl_ex5_stq5_cmp_offset + 1;
parameter                         congr_cl_ex5_stq7_cmp_offset = congr_cl_ex5_stq6_cmp_offset + 1;
parameter                         congr_cl_ex4_ex6_rest_offset = congr_cl_ex5_stq7_cmp_offset + 1;
parameter                         ex5_cClass_lock_set_offset = congr_cl_ex4_ex6_rest_offset + 1;
parameter                         ex5_cClass_thrd_watch_offset = ex5_cClass_lock_set_offset + 1;
parameter                         ex5_dir_multihit_val_b_offset = ex5_cClass_thrd_watch_offset + `THREADS;
parameter                         ex5_err_det_way_offset = ex5_dir_multihit_val_b_offset + 1;
parameter                         ex5_perr_lock_lost_offset = ex5_err_det_way_offset + 8;
parameter                         ex5_perr_watchlost_offset = ex5_perr_lock_lost_offset + 1;
parameter                         ex5_dir_perr_det_offset = ex5_perr_watchlost_offset + `THREADS;
parameter                         ex5_dc_perr_det_offset = ex5_dir_perr_det_offset + 1;
parameter                         ex5_dir_perr_flush_offset = ex5_dc_perr_det_offset + 1;
parameter                         ex5_dc_perr_flush_offset = ex5_dir_perr_flush_offset + 1;
parameter                         ex5_way_perr_det_offset = ex5_dc_perr_flush_offset + 1;
parameter                         ex4_stq2_congr_cl_m_offset = ex5_way_perr_det_offset + 1;
parameter                         ex4_stq3_set_rel_coll_offset = ex4_stq2_congr_cl_m_offset + 1;
parameter                         ex4_stq4_set_rel_coll_offset = ex4_stq3_set_rel_coll_offset + 1;
parameter                         binv6_ex6_dir_data_offset = ex4_stq4_set_rel_coll_offset + 1;
parameter                         binv7_ex7_dir_data_offset = binv6_ex6_dir_data_offset + (dirState-1);
parameter                         stq6_dir_data_offset = binv7_ex7_dir_data_offset + (dirState-1);
parameter                         stq7_dir_data_offset = stq6_dir_data_offset + (dirState-1);
parameter                         stq2_ci_offset = stq7_dir_data_offset + (dirState-1);
parameter                         stq2_cen_acc_offset = stq2_ci_offset + 1;
parameter                         stq2_val_offset = stq2_cen_acc_offset + 1;
parameter                         stq3_val_offset = stq2_val_offset + 1;
parameter                         stq4_val_offset = stq3_val_offset + 1;
parameter                         stq2_dci_val_offset = stq4_val_offset + 1;
parameter                         stq3_dci_val_offset = stq2_dci_val_offset + 1;
parameter                         stq4_dci_val_offset = stq3_dci_val_offset + 1;
parameter                         stq2_thrd_id_offset = stq4_dci_val_offset + 1;
parameter                         stq3_thrd_id_offset = stq2_thrd_id_offset + `THREADS;
parameter                         stq4_thrd_id_offset = stq3_thrd_id_offset + `THREADS;
parameter                         rel2_thrd_id_offset = stq4_thrd_id_offset + `THREADS;
parameter                         rel3_thrd_id_offset = rel2_thrd_id_offset + `THREADS;
parameter                         stq2_lock_clr_offset = rel3_thrd_id_offset + `THREADS;
parameter                         stq3_lock_clr_offset = stq2_lock_clr_offset + 1;
parameter                         stq2_watch_clr_offset = stq3_lock_clr_offset + 1;
parameter                         stq3_watch_clr_offset = stq2_watch_clr_offset + 1;
parameter                         stq2_store_val_offset = stq3_watch_clr_offset + 1;
parameter                         stq3_store_val_offset = stq2_store_val_offset + 1;
parameter                         stq2_l_fld_b1_offset = stq3_store_val_offset + 1;
parameter                         stq3_l_fld_b1_offset = stq2_l_fld_b1_offset + 1;
parameter                         stq4_l_fld_b1_offset = stq3_l_fld_b1_offset + 1;
parameter                         stq2_inval_op_offset = stq4_l_fld_b1_offset + 1;
parameter                         stq3_inval_op_offset = stq2_inval_op_offset + 1;
parameter                         stq2_watch_clr_all_offset = stq3_inval_op_offset + 1;
parameter                         stq3_watch_clr_all_offset = stq2_watch_clr_all_offset + 1;
parameter                         stq4_watch_clr_all_offset = stq3_watch_clr_all_offset + 1;
parameter                         stq2_congr_cl_offset = stq4_watch_clr_all_offset + 1;
parameter                         stq3_congr_cl_offset = stq2_congr_cl_offset + (lwrCClassBit-uprCClassBit+1);
parameter                         stq4_congr_cl_offset = stq3_congr_cl_offset + (lwrCClassBit-uprCClassBit+1);
parameter                         stq5_congr_cl_offset = stq4_congr_cl_offset + (lwrCClassBit-uprCClassBit+1);
parameter                         stq6_congr_cl_offset = stq5_congr_cl_offset + (lwrCClassBit-uprCClassBit+1);
parameter                         rel2_clr_stg_val_offset = stq6_congr_cl_offset + (lwrCClassBit-uprCClassBit+1);
parameter                         rel3_clr_stg_val_offset = rel2_clr_stg_val_offset + 1;
parameter                         rel4_clr_stg_val_offset = rel3_clr_stg_val_offset + 1;
parameter                         rel5_clr_stg_val_offset = rel4_clr_stg_val_offset + 1;
parameter                         rel3_set_dir_val_offset = rel5_clr_stg_val_offset + 1;
parameter                         rel4_set_dir_val_offset = rel3_set_dir_val_offset + 1;
parameter                         rel2_set_stg_val_offset = rel4_set_dir_val_offset + 1;
parameter                         rel3_set_stg_val_offset = rel2_set_stg_val_offset + 1;
parameter                         rel2_back_inv_offset = rel3_set_stg_val_offset + 1;
parameter                         rel3_back_inv_offset = rel2_back_inv_offset + 1;
parameter                         rel3_upd_val_offset = rel3_back_inv_offset + 1;
parameter                         rel2_lock_set_offset = rel3_upd_val_offset + 1;
parameter                         rel3_lock_set_offset = rel2_lock_set_offset + 1;
parameter                         rel3_lock_pipe_offset = rel3_lock_set_offset + 1;
parameter                         rel2_watch_set_offset = rel3_lock_pipe_offset + 1;
parameter                         rel3_watch_set_offset = rel2_watch_set_offset + 1;
parameter                         rel3_watch_pipe_offset = rel3_watch_set_offset + 1;
parameter                         stq3_dir_upd_val_offset = rel3_watch_pipe_offset + 1;
parameter                         stq4_dir_upd_val_offset = stq3_dir_upd_val_offset + 1;
parameter                         stq3_rel3_val_offset = stq4_dir_upd_val_offset + 1;
parameter                         stq4_rel4_val_offset = stq3_rel3_val_offset + 1;
parameter                         stq4_lose_watch_offset = stq4_rel4_val_offset + 1;
parameter                         stq4_way_hit_offset = stq4_lose_watch_offset + 1;
parameter                         congr_cl_stq2_stq3_cmp_offset = stq4_way_hit_offset + numWays;
parameter                         congr_cl_stq2_stq4_cmp_offset = congr_cl_stq2_stq3_cmp_offset + 1;
parameter                         congr_cl_stq2_stq5_cmp_offset = congr_cl_stq2_stq4_cmp_offset + 1;
parameter                         congr_cl_stq3_stq4_cmp_offset = congr_cl_stq2_stq5_cmp_offset + 1;
parameter                         congr_cl_stq2_ex5_cmp_offset = congr_cl_stq3_stq4_cmp_offset + 1;
parameter                         congr_cl_stq2_ex6_cmp_offset = congr_cl_stq2_ex5_cmp_offset + 1;
parameter                         congr_cl_stq3_ex6_cmp_offset = congr_cl_stq2_ex6_cmp_offset + 1;
parameter                         congr_cl_stq3_ex5_cmp_offset = congr_cl_stq3_ex6_cmp_offset + 1;
parameter                         congr_cl_stq4_ex5_cmp_offset = congr_cl_stq3_ex5_cmp_offset + 1;
parameter                         stq4_cClass_lock_set_offset = congr_cl_stq4_ex5_cmp_offset + 1;
parameter                         stq4_cClass_thrd_watch_offset = stq4_cClass_lock_set_offset + 1;
parameter                         rel4_all_watch_lost_offset = stq4_cClass_thrd_watch_offset + `THREADS;
parameter                         lost_watch_evict_ovl_offset = rel4_all_watch_lost_offset + `THREADS;
parameter                         stq4_dir_multihit_val_b_offset = lost_watch_evict_ovl_offset + `THREADS;
parameter                         stq4_err_det_way_offset = stq4_dir_multihit_val_b_offset + 1;
parameter                         stq4_perr_lock_lost_offset = stq4_err_det_way_offset + numWays;
parameter                         stq4_perr_watchlost_offset = stq4_perr_lock_lost_offset + 1;
parameter                         stq4_dir_perr_det_offset = stq4_perr_watchlost_offset + `THREADS;
parameter                         stq5_way_perr_inval_offset = stq4_dir_perr_det_offset + 1;
parameter                         stq5_dir_err_val_offset = stq5_way_perr_inval_offset + numWays;
parameter                         ex5_stp_perr_flush_offset = stq5_dir_err_val_offset + 1;
parameter                         stm_watchlost_state_offset = ex5_stp_perr_flush_offset + 1;
parameter                         p0_wren_offset = stm_watchlost_state_offset + `THREADS;
parameter                         p0_wren_cpy_offset = p0_wren_offset + 1;
parameter                         p0_wren_stg_offset = p0_wren_cpy_offset + 1;
parameter                         p1_wren_offset = p0_wren_stg_offset + 1;
parameter                         p1_wren_cpy_offset = p1_wren_offset + 1;
parameter                         stq6_wren_offset = p1_wren_cpy_offset + 1;
parameter                         stq7_wren_offset = stq6_wren_offset + 1;
parameter                         congr_cl_all_act_offset = stq7_wren_offset + 1;
parameter                         spr_xucr0_clfc_offset = congr_cl_all_act_offset + 1;
parameter                         lock_finval_offset = spr_xucr0_clfc_offset + 1;
parameter                         val_finval_offset = lock_finval_offset + 1;
parameter                         watch_finval_offset = val_finval_offset + 1;
parameter                         inj_dirmultihit_ldp_offset = watch_finval_offset + `THREADS;
parameter                         inj_dirmultihit_stp_offset = inj_dirmultihit_ldp_offset + 1;
parameter                         xucr0_cslc_xuop_offset = inj_dirmultihit_stp_offset + 1;
parameter                         xucr0_cslc_binv_offset = xucr0_cslc_xuop_offset + 1;
parameter                         lost_watch_inter_thrd_offset = xucr0_cslc_binv_offset + 1;
parameter                         lost_watch_evict_val_offset = lost_watch_inter_thrd_offset + `THREADS;
parameter                         lost_watch_binv_offset = lost_watch_evict_val_offset + `THREADS;
parameter                         scan_right = lost_watch_binv_offset + `THREADS - 1;
parameter                         numScanChains = scan_right/1248;

wire                              tiup;
wire [0:scan_right]               siv;
wire [0:scan_right]               sov;
(* analysis_not_referenced="true" *)
wire                              unused;

//!! Bugspray Include: lq_dir_val
assign tiup = 1'b1;
assign unused = dcc_dir_ex3_watch_chk;

// ####################################################
// Inputs
// ####################################################
assign spr_xucr0_clfc_d      = xu_lq_spr_xucr0_clfc;
assign val_finval_d          = stq4_dci_val_q;
assign lock_finval_d         = stq4_dci_val_q | spr_xucr0_clfc_q;
assign watch_finval_d        = stq4_dci_watch_lost | (stq4_watch_clr_all & {`THREADS{stq4_val_q}});
assign inj_dirmultihit_ldp_d = pc_lq_inj_dcachedir_ldp_multihit;
assign inj_dirmultihit_stp_d = pc_lq_inj_dcachedir_stp_multihit;

assign rel_way_clr  = {rel_way_clr_a, rel_way_clr_b, rel_way_clr_c, rel_way_clr_d, rel_way_clr_e, rel_way_clr_f, rel_way_clr_g, rel_way_clr_h};
assign rel_way_set  = {rel_way_wen_a, rel_way_wen_b, rel_way_wen_c, rel_way_wen_d, rel_way_wen_e, rel_way_wen_f, rel_way_wen_g, rel_way_wen_h};
assign ex4_way_cmp  = {ex4_way_cmp_a, ex4_way_cmp_b, ex4_way_cmp_c, ex4_way_cmp_d, ex4_way_cmp_e, ex4_way_cmp_f, ex4_way_cmp_g, ex4_way_cmp_h};
assign stq3_way_cmp = {stq3_way_cmp_a, stq3_way_cmp_b, stq3_way_cmp_c, stq3_way_cmp_d, stq3_way_cmp_e, stq3_way_cmp_f, stq3_way_cmp_g, stq3_way_cmp_h};

// ####################################################
// Execution Pipe Control
// Port0 => Execution Pipe or Back-Invalidate
// ####################################################

// Execution and Back-Invalidate Pipeline Staging
assign ex4_cache_acc_d  = dcc_dir_ex3_cache_acc & ~fgen_ex3_stg_flush;
assign ex5_cache_acc_d  = ex4_cache_acc_q       & ~fgen_ex4_stg_flush;
assign ex5_mhit_cacc_d  = ex4_cache_acc_q       & ~fgen_ex4_cp_flush;
assign ex4_pfetch_val_d = dcc_dir_ex3_pfetch_val;
assign ex4_cache_en_val = (ex4_cache_acc_q | ex4_pfetch_val_q) & ~derat_dir_ex4_wimge_i;
assign ex3_binv_val_d   = dcc_dir_ex2_binv_val  & ~spr_xucr0_dcdis;
assign ex4_binv_val_d   = ex3_binv_val_q;
assign ex5_binv_val_d   = ex4_binv_val_q;
assign ex2_thrd_id      = dcc_dir_ex2_thrd_id;
assign ex3_thrd_id_d    = ex2_thrd_id;
assign ex4_thrd_id_d    = ex3_thrd_id_q;
assign ex5_thrd_id_d    = ex4_thrd_id_q;
assign ex2_congr_cl     = ex2_eff_addr;
assign ex3_congr_cl_d   = ex2_congr_cl;
assign ex4_congr_cl_d   = ex3_congr_cl_q;
assign ex5_congr_cl_d   = ex4_congr_cl_q;
assign ex4_dcarr_perr_way  = dat_ctl_dcarr_perr_way & {numWays{dcc_dir_ex4_load_val}};
assign stq6_dcarr_perr_way = dat_ctl_dcarr_perr_way & {numWays{dcc_dir_stq6_store_val}};
assign ex4_perr_way        = ex4_tag_perr_way | ex4_dcarr_perr_way;

assign ex3_lock_set    = dcc_dir_ex3_lock_set  & dcc_dir_ex3_th_c;
assign ex4_lock_set_d  = ex3_lock_set          & ~fgen_ex3_stg_flush;
assign ex5_lock_set_d  = ex4_lock_set_q        & ~fgen_ex4_stg_flush;
assign ex4_watch_set_d = dcc_dir_ex3_watch_set & ~fgen_ex3_stg_flush;
assign ex5_watch_set_d = ex4_watch_set_q       & ~fgen_ex4_stg_flush;
assign ex6_watch_set_d = ex5_watch_set_q       & ~fgen_ex5_stg_flush;
assign ex4_larx_val_d  = dcc_dir_ex3_larx_val  & ~fgen_ex3_stg_flush;
assign ex7_watch_set_inval_d = ex6_watch_set_q & congr_cl_stq3_ex6_cmp_q;

// Clear Watch Bit on an invalidate type op or WCLR
assign ex4_clr_watch    = ex4_clr_val_way;
assign ex4_set_watch    = ex4_thrd_id_q & {`THREADS{ex4_watch_set_q}};
assign ex5_lose_watch_d = ex4_clr_watch;

assign ex4_clr_val_way    = ex4_larx_val_q | ex4_binv_val_q;
assign ex4_xuop_upd_val_d = (ex3_lock_set | dcc_dir_ex3_watch_set | dcc_dir_ex3_larx_val) & ~fgen_ex3_stg_flush;
assign ex4_xuop_upd_val   = ex4_xuop_upd_val_q & ex4_cache_en_val & ~spr_xucr0_dcdis;
assign ex5_xuop_upd_val_d = ex4_xuop_upd_val   & ~fgen_ex4_stg_flush;
assign ex5_xuop_upd_val   = ex5_xuop_upd_val_q & ~fgen_ex5_stg_flush;

assign binv4_ex4_xuop_upd    = ex4_binv_val_q | ex4_xuop_upd_val;
assign binv4_ex4_dir_val     = ex4_binv_val_q | ex4_cache_acc_q | ex4_pfetch_val_q;
assign binv5_ex5_dir_val_d   = ex4_binv_val_q | (ex4_cache_acc_q & ~fgen_ex4_cp_flush) | ex4_pfetch_val_q;
assign inj_dirmultihit_ldp_b = ~(inj_dirmultihit_ldp_q & binv4_ex4_dir_val);

assign ex5_way_hit_d = ex4_way_hit;

// ####################################################
// Execution Pipe Directory Read
// ####################################################
// 1-hot Congruence Class Select
generate begin : ldpCClass
      genvar                            cclass;
      for (cclass=0; cclass<numCClass; cclass=cclass+1) begin : ldpCClass
         wire [uprCClassBit:lwrCClassBit]       cclassDummy = cclass;
         assign ex3_congr_cl_1hot[cclass] = (cclassDummy == ex3_congr_cl_q);
      end
   end
endgenerate

// Execution Path Directory Valid Muxing
always @(*) begin: p0WayRd
   reg  [0:dirState-1]               wAState;
   reg  [0:dirState-1]               wBState;
   reg  [0:dirState-1]               wCState;
   reg  [0:dirState-1]               wDState;
   reg  [0:dirState-1]               wEState;
   reg  [0:dirState-1]               wFState;
   reg  [0:dirState-1]               wGState;
   reg  [0:dirState-1]               wHState;

   (* analysis_not_referenced="true" *)

   integer                           cclass;
   wAState = {dirState{1'b0}};
   wBState = {dirState{1'b0}};
   wCState = {dirState{1'b0}};
   wDState = {dirState{1'b0}};
   wEState = {dirState{1'b0}};
   wFState = {dirState{1'b0}};
   wGState = {dirState{1'b0}};
   wHState = {dirState{1'b0}};
   for (cclass=0; cclass<numCClass; cclass=cclass+1) begin
      wAState = (congr_cl_wA_q[cclass] & {dirState{ex3_congr_cl_1hot[cclass]}}) | wAState;
      wBState = (congr_cl_wB_q[cclass] & {dirState{ex3_congr_cl_1hot[cclass]}}) | wBState;
      wCState = (congr_cl_wC_q[cclass] & {dirState{ex3_congr_cl_1hot[cclass]}}) | wCState;
      wDState = (congr_cl_wD_q[cclass] & {dirState{ex3_congr_cl_1hot[cclass]}}) | wDState;
      wEState = (congr_cl_wE_q[cclass] & {dirState{ex3_congr_cl_1hot[cclass]}}) | wEState;
      wFState = (congr_cl_wF_q[cclass] & {dirState{ex3_congr_cl_1hot[cclass]}}) | wFState;
      wGState = (congr_cl_wG_q[cclass] & {dirState{ex3_congr_cl_1hot[cclass]}}) | wGState;
      wHState = (congr_cl_wH_q[cclass] & {dirState{ex3_congr_cl_1hot[cclass]}}) | wHState;
   end
   p0_arr_way_rd[0] <= wAState;
   p0_arr_way_rd[1] <= wBState;
   p0_arr_way_rd[2] <= wCState;
   p0_arr_way_rd[3] <= wDState;
   p0_arr_way_rd[4] <= wEState;
   p0_arr_way_rd[5] <= wFState;
   p0_arr_way_rd[6] <= wGState;
   p0_arr_way_rd[7] <= wHState;
end

// ####################################################
// Execution Pipe Bypass
// ####################################################

// Determine if there is any updates in later stages to the same congruence class
assign congr_cl_ex3_ex4_cmp_d  = (ex2_congr_cl == ex3_congr_cl_q);
assign congr_cl_ex3_ex5_cmp_d  = (ex2_congr_cl == ex4_congr_cl_q);
assign congr_cl_ex3_ex6_cmp_d  = (ex2_congr_cl == ex5_congr_cl_q);
assign congr_cl_ex3_stq4_cmp_d = (ex2_congr_cl == stq3_congr_cl_q);
assign congr_cl_ex3_stq5_cmp_d = (ex2_congr_cl == stq4_congr_cl_q);

// Check that bypassed results were restarted, want to restart instruction in LQ EX4 pipeline
assign congr_cl_ex4_ex6_rest_d = (congr_cl_ex3_way_sel[0][3] | congr_cl_ex3_way_sel[1][3] | congr_cl_ex3_way_sel[2][3] | congr_cl_ex3_way_sel[3][3] |
                                  congr_cl_ex3_way_sel[4][3] | congr_cl_ex3_way_sel[5][3] | congr_cl_ex3_way_sel[6][3] | congr_cl_ex3_way_sel[7][3]) & fgen_ex5_stg_flush;
assign congr_cl_ex4_byp_restart = congr_cl_ex4_ex6_rest_q & ex4_cache_en_val;

// Want to only bypass from EX pipeline if operation ahead of me is
// 1) larx,ldawx, or dcbt[st]ls, ignoring thread, not needed since these requests are
//    guaranteed to complete, will restart EX3 instruction if op cant complete
// 2) back-invalidate
// Dont want to bypass from EX pipeline if my operation is a back-invalidate
// Want to only bypass from REL pipeline if its a cacheline invalidate due to capacity miss
// Dont want to bypass from STQ pipeline
assign congr_cl_ex3_ex4_m  = congr_cl_ex3_ex4_cmp_q  & (ex4_xuop_upd_val   | ex4_binv_val_q) & ~ex3_binv_val_q;
assign congr_cl_ex3_ex5_m  = congr_cl_ex3_ex5_cmp_q  & (ex5_xuop_upd_val_q | ex5_binv_val_q) & ~ex3_binv_val_q;
assign congr_cl_ex3_ex6_m  = congr_cl_ex3_ex6_cmp_q  & p0_wren_cpy_q;
assign congr_cl_ex3_stq4_m = congr_cl_ex3_stq4_cmp_q & rel4_clr_stg_val_q;
assign congr_cl_ex3_stq5_m = congr_cl_ex3_stq5_cmp_q & rel5_clr_stg_val_q;

generate begin : ldpByp
      genvar                            ways;
      for (ways=0; ways<numWays; ways=ways+1) begin : ldpByp
         // Way Bypass Calculation                                                               Should have the following priority
         assign congr_cl_ex3_way_byp[ways][0] = congr_cl_ex3_stq4_m & stq4_way_upd_q[ways];	        // 0
         assign congr_cl_ex3_way_byp[ways][1] = congr_cl_ex3_stq5_m & stq5_way_upd_q[ways];		    // 1
         assign congr_cl_ex3_way_byp[ways][2] = congr_cl_ex3_ex4_m & ex4_way_hit[ways];		        // 2    <-- slowest of all of them
         assign congr_cl_ex3_way_byp[ways][3] = congr_cl_ex3_ex5_m & ex5_way_upd_q[ways];		    // 3
         assign congr_cl_ex3_way_byp[ways][4] = congr_cl_ex3_ex6_m & ex6_way_upd_q[ways];		    // 4

         // Late Stages Priority Selection
         assign congr_cl_ex3_way_sel[ways][1] = congr_cl_ex3_way_byp[ways][0];
         assign congr_cl_ex3_way_sel[ways][2] = congr_cl_ex3_way_byp[ways][1] &    ~congr_cl_ex3_way_byp[ways][0];
         assign congr_cl_ex3_way_sel[ways][3] = congr_cl_ex3_way_byp[ways][3] & ~(|(congr_cl_ex3_way_byp[ways][0:1]));
         assign congr_cl_ex3_way_sel[ways][4] = congr_cl_ex3_way_byp[ways][4] & ~(|(congr_cl_ex3_way_byp[ways][0:1]) | congr_cl_ex3_way_byp[ways][3]);

         assign ex3_way_arr_sel[ways] = |(congr_cl_ex3_way_byp[ways]);
         assign ex3_way_stg_pri[ways] = (stq4_dir_way_q[ways] & {dirState{congr_cl_ex3_way_sel[ways][1]}}) |
                                        (stq5_dir_way_q[ways] & {dirState{congr_cl_ex3_way_sel[ways][2]}}) |
                                        (ex5_dir_way_q[ways]  & {dirState{congr_cl_ex3_way_sel[ways][3]}}) |
                                        (ex6_dir_way_q[ways]  & {dirState{congr_cl_ex3_way_sel[ways][4]}}) |
                                        (p0_arr_way_rd[ways]  & {dirState{~ex3_way_arr_sel[ways]}});

         assign ex4_way_val_d[ways] = (ex4_dir_way[ways]     & {dirState{ congr_cl_ex3_way_byp[ways][2]}}) |
                                      (ex3_way_stg_pri[ways] & {dirState{~congr_cl_ex3_way_byp[ways][2]}});
         assign ex5_way_val_d[ways] = ex4_way_val_q[ways];
      end
   end
endgenerate

// ####################################################
// Execution Pipe Update Directory Logic
// ####################################################
generate begin : ldpCtrl
      genvar                            ways;
      for (ways=0; ways<numWays; ways=ways+1) begin : ldpCtrl
         // Hit Detect
         assign ex4_way_hit[ways] = ex4_way_val_q[ways][0] & ex4_way_cmp[ways];

         // Cacheline Valid Bit
         //                                   CLEAR VALID
         assign ex4_dir_way[ways][0] = ~ex4_clr_val_way & ex4_way_val_q[ways][0];

         // Cacheline Lock Bit
         //                                  CLEAR LOCK               SET LOCK
         assign ex4_dir_way[ways][1] = (ex4_way_val_q[ways][1] & ~ex4_clr_val_way) | (ex4_way_val_q[ways][0] & ex4_lock_set_q);

         // Determine Lock Bit Set Per Way
         assign ex4_way_lock[ways] = ex4_way_val_q[ways][1];

         // Need to detect if Back-Invalidate or invalidate type instruction invalidated the lock bit
         assign ex5_clr_lck_way_d[ways] = ex4_clr_val_way & ex4_way_val_q[ways][1];

         // Set/Clr Watch Bit for Thread on Port0
         // Cacheline Watch Bits
         begin : P0Watch
            genvar                            tid;
            for (tid=0; tid<`THREADS; tid=tid+1) begin : P0Watch
               assign ex4_dir_way[ways][2 + tid] = (ex4_way_val_q[ways][2 + tid] & ~ex4_clr_watch) | (ex4_way_val_q[ways][0] & ex4_set_watch[tid]);
            end
         end

         // Determine if a Watch Bit was lost
         assign ex5_lost_way[ways] = ex5_way_val_q[ways][2:dirState - 1] & {dirState-2{(ex5_lose_watch_q & ex5_way_hit_q[ways])}};

         // Determine if Updating Directory
         assign ex5_way_upd_d[ways]   = (ex4_way_hit[ways] & binv4_ex4_xuop_upd);
         // Need to gate with ex5_xuop_perr_det so the instruction currently in ex2 doesnt bypass my instruction that will cause a flush
         assign ex5_way_upd[ways]     = (ex5_way_upd_q[ways] & ~ex5_xuop_perr_det) | ex5_way_perr_inval[ways];
         assign ex6_way_upd_d[ways]   = ex5_way_upd[ways];
         assign ex7_way_upd_d[ways]   = ex6_way_upd_q[ways];
         assign ex5_dir_way_d[ways]   = ex4_dir_way[ways];
         assign ex5_dir_way_err[ways] = ex5_dir_way_q[ways] & {dirState{~ex5_way_perr_inval[ways]}};
         assign ex6_dir_way_d[ways]   = ex5_dir_way_err[ways];
         assign ex7_dir_way_d[ways]   = ex6_dir_way_q[ways][2:dirState-1];

         // Determine `THREADS Watch Bits Per Way
         assign ex4_way_watch[ways] = |(ex4_thrd_id_q & ex4_way_val_q[ways][2:dirState - 1]);
      end
   end
endgenerate

// Execution Pipe Hit/Miss
assign ex4_miss =  ex4_hit_or_01234567_b;
assign ex4_hit  = ~ex4_hit_or_01234567_b;

// Invalidate Lock Bit Detect
assign ex5_inval_clr_lock = |(ex5_clr_lck_way_q & ex5_way_upd_q);

// One of the Ways has a Lock Bit set
assign ex5_cClass_lock_set_d = |(ex4_way_lock);

// Lock bit invalidated due to LARX instruction
assign xucr0_cslc_xuop_d = ex5_inval_clr_lock & ex5_xuop_upd_val;

// Lock bit invalidated due to Back-Invlaidate
assign xucr0_cslc_binv_d = (binv5_inval_lock_val & ex5_binv_val_q) |
                           ex5_perr_lock_lost_q |
                           ex5_multihit_lock_lost |
                           binv_rel_lock_lost |
                           stq4_inval_clr_lock |
                           stq4_perr_lock_lost_q |
                           stq4_multihit_lock_lost;

// Watch Lost due to DCI
assign stq4_dci_watch_lost = {`THREADS{stq4_dci_val_q}};

// Watch Lost due to Back-Invalidate only
assign ex5_watchlost_binv = binv5_inval_watch_val;

// Way Watch Bits OR Reduced

always @(*) begin: ldpThrdWatch
   reg  [0:`THREADS-1]               tidW;
   reg  [0:`THREADS-1]               tidWLp;
   reg  [0:`THREADS-1]               tidWLe;

   (* analysis_not_referenced="true" *)

   integer                           ways;
   tidW   = {`THREADS{1'b0}};
   tidWLp = {`THREADS{1'b0}};
   tidWLe = {`THREADS{1'b0}};
   for (ways=0; ways<numWays; ways=ways+1) begin
      tidW   = ex4_way_val_q[ways][2:dirState - 1] | tidW;
      tidWLp = ex5_lost_way[ways]                  | tidWLp;
      tidWLe = ex4_err_way_watchlost[ways]         | tidWLe;
   end
   // `THREADS Watching one of the ways in EX4/BINV4
   ex5_cClass_thrd_watch_d <= tidW;

   // Watch Lost due to Back-Invalidate or LARX
   ex5_lost_watch <= tidWLp;

   // Watch Lost due to Parity Error
   ex5_perr_watchlost_d <= tidWLe;
end

// Update STM_WACHTLOST valid
assign ex5_watchlost_upd = (ex5_lost_watch & {`THREADS{ex5_xuop_upd_val}}) | ex5_watchlost_binv | ex5_multihit_watch_lost | ex5_perr_watchlost_q;

// Update STM_WATCHLOST contents
assign ex5_watchlost_set = (ex5_lost_watch & {`THREADS{ex5_xuop_upd_val}}) | ex5_watchlost_binv | ex5_multihit_watch_lost | ex5_perr_watchlost_q;

// Watch Bit for LDAWX CR update
assign ex4_curr_watch = |(ex4_way_hit & ex4_way_watch);

// Current WatchLost State for WCHKALL CR update
assign ex4_stm_watchlost_sel = |(ex4_thrd_id_q & stm_watchlost);

// CR update for LDAWX and WCHKALL
assign ex5_cr_watch_d = ~ex4_watch_set_q ? ex4_stm_watchlost_sel : ex4_curr_watch;

// ####################################################
// Back-Invalidated Watched/Locked Line detection,
// I need to do it late since instructions ahead of a
// back-invalidate could have set the watch/lost bit
// Back-Invalidate does not look at instructions ahead of pipe,
// since they might get flushed and will get bad results
// Also includes Multihit Error Detect case
// ####################################################

// Staging out congruence class compares
assign congr_cl_ex4_ex5_cmp_d  = congr_cl_ex3_ex4_cmp_q;
assign congr_cl_ex4_ex6_cmp_d  = congr_cl_ex3_ex5_cmp_q;
assign congr_cl_ex5_ex6_cmp_d  = congr_cl_ex4_ex5_cmp_q;
assign congr_cl_ex5_ex7_cmp_d  = congr_cl_ex4_ex6_cmp_q;
assign congr_cl_ex5_stq5_cmp_d = (ex4_congr_cl_q == stq4_congr_cl_q);
assign congr_cl_ex5_stq6_cmp_d = (ex4_congr_cl_q == stq5_congr_cl_q);
assign congr_cl_ex5_stq7_cmp_d = (ex4_congr_cl_q == stq6_congr_cl_q);

// Ways updated in other stages
assign binv5_ex5_way_upd = ex5_way_upd;
assign binv6_ex6_way_upd = ex6_way_upd_q;
assign binv7_ex7_way_upd = ex7_way_upd_q;
assign stq5_way_upd      = stq5_way_upd_q;
assign stq6_way_upd      = stq6_way_upd_q;
assign stq7_way_upd      = stq7_way_upd_q;

// Data of ways updated in other stages
always @(*) begin: binvData
   reg  [1:dirState-1]               binvD;
   reg  [1:dirState-1]               stqD;

   (* analysis_not_referenced="true" *)

   integer                           ways;
   binvD = {dirState-1{1'b0}};
   stqD  = {dirState-1{1'b0}};
   for (ways=0; ways<numWays; ways=ways+1) begin
      binvD = (ex5_dir_way_err[ways][1:dirState - 1] & {dirState-1{binv5_ex5_way_upd[ways]}}) | binvD;
      stqD  = ( stq5_dir_way_q[ways][1:dirState - 1] & {dirState-1{     stq5_way_upd[ways]}}) | stqD;
   end
   binv5_ex5_dir_data <= binvD;
   stq5_dir_data <= stqD;
end

assign binv6_ex6_dir_data_d = binv5_ex5_dir_data;
assign binv7_ex7_dir_data_d = binv6_ex6_dir_data_q;
assign stq6_dir_data_d      = stq5_dir_data;
assign stq7_dir_data_d      = stq6_dir_data_q;

// None Bypass Locked Line lost indicator
assign binv5_inval_lck = ex5_inval_clr_lock & ex5_binv_val_q & (~binv5_coll_val);

// None Bypass Watch Lost indicator
assign binv5_inval_watch = (ex5_lost_watch & {`THREADS{(ex5_binv_val_q & (~binv5_coll_val))}});

// Stage Bypass Select
assign binv5_ex6_coll  = (ex5_binv_val_q | ex5_dir_multihit_det) & congr_cl_ex5_ex6_cmp_q  & |(ex5_way_hit_q & binv6_ex6_way_upd) & p0_wren_q;
assign binv5_ex7_coll  = (ex5_binv_val_q | ex5_dir_multihit_det) & congr_cl_ex5_ex7_cmp_q  & |(ex5_way_hit_q & binv7_ex7_way_upd) & p0_wren_stg_q;
assign binv5_stq5_coll = (ex5_binv_val_q | ex5_dir_multihit_det) & congr_cl_ex5_stq5_cmp_q & |(ex5_way_hit_q & stq5_way_upd) & p1_wren_q & rel5_clr_stg_val_q;
assign binv5_stq6_coll = (ex5_binv_val_q | ex5_dir_multihit_det) & congr_cl_ex5_stq6_cmp_q & |(ex5_way_hit_q & stq6_way_upd) & stq6_wren_q;
assign binv5_stq7_coll = (ex5_binv_val_q | ex5_dir_multihit_det) & congr_cl_ex5_stq7_cmp_q & |(ex5_way_hit_q & stq7_way_upd) & stq7_wren_q;
assign binv5_coll_val  = binv5_ex6_coll | binv5_ex7_coll | binv5_stq5_coll | binv5_stq6_coll | binv5_stq7_coll;

// Priority Calculation
assign binv5_pri_byp_sel[0] = binv5_stq5_coll;
assign binv5_pri_byp_sel[1] = binv5_ex6_coll  & (~binv5_stq5_coll);
assign binv5_pri_byp_sel[2] = binv5_stq6_coll & (~(binv5_stq5_coll | binv5_ex6_coll));
assign binv5_pri_byp_sel[3] = binv5_ex7_coll  & (~(binv5_stq5_coll | binv5_ex6_coll | binv5_stq6_coll));
assign binv5_pri_byp_sel[4] = binv5_stq7_coll & (~(binv5_stq5_coll | binv5_ex6_coll | binv5_stq6_coll | binv5_ex7_coll));

// Data Bypass
assign binv5_byp_dir_data = (stq5_dir_data        & {dirState-1{binv5_pri_byp_sel[0]}}) |
                            (binv6_ex6_dir_data_q & {dirState-1{binv5_pri_byp_sel[1]}}) |
                            (stq6_dir_data_q      & {dirState-1{binv5_pri_byp_sel[2]}}) |
                            (binv7_ex7_dir_data_q & {dirState-1{binv5_pri_byp_sel[3]}}) |
                            (stq7_dir_data_q      & {dirState-1{binv5_pri_byp_sel[4]}});

// Back-Invalidate invalidated a watched line
assign binv5_inval_watch_val = (binv5_byp_dir_data[2:dirState - 1] & (~binv5_ex5_dir_data[2:dirState - 1])) | binv5_inval_watch;

// Back-Invalidate invalidated a locked line
assign binv5_inval_lock_val = (binv5_byp_dir_data[1] & (~binv5_ex5_dir_data[1])) | binv5_inval_lck;

// Multihit Error Detected
// ####################################################
// Level 1
assign ex4_hit_and_01_b = ~(ex4_way_hit[0] & ex4_way_hit[1]);
assign ex4_hit_and_23_b = ~(ex4_way_hit[2] & ex4_way_hit[3]);
assign ex4_hit_and_45_b = ~(ex4_way_hit[4] & ex4_way_hit[5]);
assign ex4_hit_and_67_b = ~(ex4_way_hit[6] & ex4_way_hit[7]);
assign ex4_hit_or_01_b  = ~(ex4_way_hit[0] | ex4_way_hit[1]);
assign ex4_hit_or_23_b  = ~(ex4_way_hit[2] | ex4_way_hit[3]);
assign ex4_hit_or_45_b  = ~(ex4_way_hit[4] | ex4_way_hit[5]);
assign ex4_hit_or_67_b  = ~(ex4_way_hit[6] | ex4_way_hit[7]);

// Level 2
assign ex4_hit_or_0123      = ~(ex4_hit_or_01_b & ex4_hit_or_23_b);
assign ex4_hit_or_4567      = ~(ex4_hit_or_45_b & ex4_hit_or_67_b);
assign ex4_hit_and_0123     = ~(ex4_hit_or_01_b | ex4_hit_or_23_b);
assign ex4_hit_and_4567     = ~(ex4_hit_or_45_b | ex4_hit_or_67_b);
assign ex4_multi_hit_err2_0 = ~(ex4_hit_and_01_b & ex4_hit_and_23_b);
assign ex4_multi_hit_err2_1 = ~(ex4_hit_and_45_b & ex4_hit_and_67_b);

// Level 3
assign ex4_hit_or_01234567_b   = ~(ex4_hit_or_0123 | ex4_hit_or_4567);
assign ex4_multi_hit_err3_b[0] = ~(ex4_hit_or_0123 & ex4_hit_or_4567);
assign ex4_multi_hit_err3_b[1] = ~(ex4_hit_and_0123 | ex4_hit_and_4567);
assign ex4_multi_hit_err3_b[2] = ~(ex4_multi_hit_err2_0 | ex4_multi_hit_err2_1);

// Level 4
// Multihit Error Detected
assign ex4_dir_multihit_val_0 = ~(ex4_multi_hit_err3_b[0] & ex4_multi_hit_err3_b[1]);
assign ex4_dir_multihit_val_1 = ~(ex4_multi_hit_err3_b[2] & inj_dirmultihit_ldp_b);

// Level 5
assign ex4_dir_multihit_val_b = ~(ex4_dir_multihit_val_0 | ex4_dir_multihit_val_1);

assign ex5_dir_multihit_val_b_d =  ex4_dir_multihit_val_b;
assign ex5_dir_multihit_val     = ~ex5_dir_multihit_val_b_q;
assign ex5_dir_multihit_det     = binv5_ex5_dir_val_q & ex5_dir_multihit_val;
assign ex5_dir_multihit_flush   = ex5_mhit_cacc_q & ex5_dir_multihit_val;

// Lock Bit Lost due to Multihit Error
assign ex5_multihit_lock_lost = ex5_dir_multihit_det & ex5_cClass_lock_set_q;

// Watch Lost due to Multihit Error
assign ex5_multihit_watch_lost = ex5_cClass_thrd_watch_q & {`THREADS{(ex5_dir_multihit_det)}};

// Parity Error Detect
// ####################################################
generate begin : ldpErrGen
      genvar                            ways;
      for (ways=0; ways<numWays; ways=ways+1) begin : ldpErrGen
         assign ex4_dir_perr_det[ways]      = ex4_way_val_q[ways][0] & ex4_tag_perr_way[ways];
         assign ex4_dc_perr_det[ways]       = ex4_way_val_q[ways][0] & ex4_dcarr_perr_way[ways];
         assign ex4_err_det_way[ways]       = ex4_way_val_q[ways][0] & ex4_perr_way[ways];
         assign ex5_err_det_way_d[ways]     = ex4_err_det_way[ways];
         assign ex4_err_lock_lost[ways]     = ex4_way_val_q[ways][1] & ex4_perr_way[ways];
         assign ex4_err_way_watchlost[ways] = ex4_way_val_q[ways][2:dirState - 1] & {dirState-2{ex4_perr_way[ways]}};
      end
   end
endgenerate

// Lock Bit Lost due to Parity Error
assign ex5_perr_lock_lost_d = |(ex4_err_lock_lost);

// Parity Error Detected
assign ex5_dir_perr_det_d   = |(ex4_dir_perr_det);
assign ex5_dc_perr_det_d    = |(ex4_dc_perr_det);
assign ex5_dir_perr_flush_d = |(ex4_dir_perr_det) & ex4_cache_acc_q & ~fgen_ex4_cp_flush;
assign ex5_dc_perr_flush_d  = |(ex4_dc_perr_det)  & ex4_cache_acc_q & ~fgen_ex4_cp_flush;
assign ex5_way_perr_det_d   = |(ex4_err_det_way);
assign ex5_way_perr_inval   = ex5_err_det_way_q | {numWays{ex5_dir_multihit_det}};
assign ex5_xuop_perr_det    = ex5_way_perr_det_q & ~ex5_binv_val_q; // dont want to use ex5_xuop_val in case it was valid

// Staging out Directory Error
assign ex5_way_err_val = ex5_way_perr_det_q | ex5_dir_multihit_det;

// ####################################################
// Resource Conflict Flushes
// ####################################################

// DCTB[ST]LS/LDAWX instruction colliding with reload clear to same congruence class
// DCTB[ST]LS/LDAWX will get restarted
assign ex4_stq2_congr_cl_m_d     = ex3_congr_cl_q == stq1_congr_cl;
assign ex4_stq2_set_rel_coll     = (ex4_lock_set_q | ex4_watch_set_q) & rel2_clr_stg_val & ex4_stq2_congr_cl_m_q;
assign ex4_stq3_set_rel_coll_d   = rel2_clr_stg_val & (dcc_dir_ex3_lock_set | dcc_dir_ex3_watch_set) & (stq2_congr_cl_q == ex3_congr_cl_q);
assign ex4_stq4_set_rel_coll_d   = rel3_clr_stg_val_q & (dcc_dir_ex3_lock_set | dcc_dir_ex3_watch_set) & (stq3_congr_cl_q == ex3_congr_cl_q);
assign ex4_lockwatchSet_rel_coll = ex4_stq2_set_rel_coll | ex4_stq3_set_rel_coll_q | ex4_stq4_set_rel_coll_q;

// ####################################################
// Reload Pipe Control
// Port1 => Reload or Commit
// ####################################################

// Store Commit Pipeline Staging
assign stq2_ci_d        = lsq_ctl_stq1_ci;
assign stq2_cen_acc_d   = lsq_ctl_stq1_lock_clr | (lsq_ctl_stq1_watch_clr & lsq_ctl_stq1_l_fld[0]) | lsq_ctl_stq1_store_val;
assign stq2_cen_acc     = stq2_cen_acc_q & ~stq2_ci_q;
assign stq2_dci_val_d   = lsq_ctl_stq1_dci_val;
assign stq3_dci_val_d   = stq2_val_q & stq2_dci_val_q & ~lsq_ctl_stq2_blk_req;
assign stq4_dci_val_d   = stq3_dci_val_q;
assign stq2_val_d       = lsq_ctl_stq1_val;
assign stq2_val         = stq2_val_q & (stq2_cen_acc | stq2_inval_op_q | stq2_watch_clr_all_q | stq2_dci_val_q) & ~(lsq_ctl_stq2_blk_req | spr_xucr0_dcdis);
assign stq3_val_d       = stq2_val;
assign stq4_val_d       = stq3_val_q;
assign stq2_thrd_id_d   = lsq_ctl_stq1_thrd_id;
assign stq3_thrd_id_d   = stq2_thrd_id_q;
assign stq4_thrd_id_d   = stq3_thrd_id_q;
assign rel2_thrd_id_d   = lsq_ctl_rel1_thrd_id;
assign rel3_thrd_id_d   = rel2_thrd_id_q;
assign stq2_lock_clr_d  = lsq_ctl_stq1_lock_clr;
assign stq3_lock_clr_d  = stq2_lock_clr_q & stq2_val;
assign stq2_watch_clr_d = lsq_ctl_stq1_watch_clr & lsq_ctl_stq1_l_fld[0];
assign stq3_watch_clr_d = stq2_watch_clr_q & stq2_val;
assign stq2_store_val_d = lsq_ctl_stq1_store_val;
assign stq3_store_val_d = stq2_store_val_q & stq2_val;

// Cacheline Invalidate type instructions, still invalidate if I=1
assign stq2_inval_op_d = lsq_ctl_stq1_inval;
assign stq3_inval_op_d = stq2_inval_op_q & stq2_val;

// Watch Clear All updates STM_WATCHLOST indicator if DCDIS,
// but does not update the watch bits in the directory
assign stq1_watch_clr_all    = lsq_ctl_stq1_watch_clr & (~lsq_ctl_stq1_l_fld[0]);
assign stq2_watch_clr_all_d  = stq1_watch_clr_all;
assign stq3_watch_clr_all_d  = stq2_watch_clr_all_q & stq2_val_q & ~lsq_ctl_stq2_blk_req;
assign stq4_watch_clr_all_d  = stq3_watch_clr_all_q;
assign stq2_l_fld_b1_d       = lsq_ctl_stq1_l_fld[1];
assign stq3_l_fld_b1_d       = stq2_l_fld_b1_q;
assign stq4_l_fld_b1_d       = stq3_l_fld_b1_q;
assign inj_dirmultihit_stp_b = ~(inj_dirmultihit_stp_q & stq3_dir_upd_val_q);

generate
   if (`CL_SIZE == 6) begin : cl64size
      assign stq1_congr_cl[uprCClassBit:lwrCClassBit - 1] = lsq_ctl_stq1_addr[uprCClassBit:lwrCClassBit - 1];
      assign stq1_congr_cl[lwrCClassBit]                  = lsq_ctl_stq1_addr[lwrCClassBit] | spr_xucr0_cls;
   end
endgenerate

generate
   if (`CL_SIZE == 7) begin : cl128size
      assign stq1_congr_cl = lsq_ctl_stq1_addr;
   end
endgenerate

assign stq2_congr_cl_d = stq1_congr_cl;
assign stq3_congr_cl_d = stq2_congr_cl_q;
assign stq4_congr_cl_d = stq3_congr_cl_q;
assign stq5_congr_cl_d = stq4_congr_cl_q;
assign stq6_congr_cl_d = stq5_congr_cl_q;

// Reload Pipeline Staging
assign rel2_clr_stg_val_d = lsq_ctl_rel1_clr_val & ~spr_xucr0_dcdis;
assign rel2_clr_stg_val   = rel2_clr_stg_val_q & ~lsq_ctl_rel2_blk_req;
assign rel3_clr_stg_val_d = rel2_clr_stg_val;
assign rel4_clr_stg_val_d = rel3_clr_stg_val_q;
assign rel5_clr_stg_val_d = rel4_clr_stg_val_q;
assign rel2_set_stg_val_d = lsq_ctl_rel1_set_val & ~spr_xucr0_dcdis;
assign rel2_set_dir_val   = rel2_set_stg_val_q & lsq_ctl_rel2_upd_val & ~(lsq_ctl_rel2_blk_req | rel2_back_inv_q);
assign rel3_set_dir_val_d = rel2_set_dir_val;
assign rel4_set_dir_val_d = rel3_set_dir_val_q;
assign rel3_set_stg_val_d = rel2_set_stg_val_q & ~lsq_ctl_rel2_blk_req;
assign rel2_back_inv_d    = lsq_ctl_rel1_back_inv;
assign rel3_back_inv_d    = rel2_back_inv_q;
assign rel3_upd_val_d     = lsq_ctl_rel2_upd_val;
assign rel2_lock_set_d    = lsq_ctl_rel1_lock_set;
assign rel3_lock_set_d    = rel2_lock_set_q & rel2_set_stg_val_q & ~lsq_ctl_rel2_blk_req;
assign rel3_lock_pipe_d   = rel2_lock_set_q;
assign rel2_watch_set_d   = lsq_ctl_rel1_watch_set;
assign rel3_watch_set_d   = rel2_watch_set_q & rel2_set_stg_val_q & ~lsq_ctl_rel2_blk_req;
assign rel3_watch_pipe_d  = rel2_watch_set_q;

// COMMIT/Reload Pipe Update Valid
assign stq2_dir_upd_val   = stq2_val_q & (stq2_cen_acc | stq2_inval_op_q) & ~(lsq_ctl_stq2_blk_req | spr_xucr0_dcdis);
assign stq3_dir_upd_val_d = stq2_dir_upd_val;
assign stq4_dir_upd_val_d = stq3_dir_upd_val_q;
// removed rel2_set_dir_val, moved dir tag update to the set stage, was getting stale
// tag hits when bypassing rel_set_dir stages to stq2 commit stage before the directory
// was updated
assign stq3_rel3_val_d    = stq2_dir_upd_val | rel2_clr_stg_val;
assign stq4_rel4_val_d    = stq3_rel3_val_q;

assign stq3_clr_lock        = stq3_inval_op_q | stq3_lock_clr_q;
assign rel3_set_watch       = rel3_thrd_id_q & {`THREADS{rel3_watch_set_q}};
assign stq4_lose_watch_d    = stq3_inval_op_q & stq3_dir_upd_val_q;
assign stq3_store_clr_watch = ~stq3_thrd_id_q & {`THREADS{stq3_store_val_q}};
assign stq3_wclr_clr_watch  = stq3_thrd_id_q  & {`THREADS{stq3_watch_clr_q}};
assign stq3_inval_clr_watch = {`THREADS{stq3_inval_op_q}};
assign stq3_clr_watch       = stq3_store_clr_watch | stq3_wclr_clr_watch | stq3_inval_clr_watch;
assign stq4_way_hit_d       = stq3_way_hit;

// ####################################################
// Reload Pipe Directory Read
// ####################################################
// 1-hot Congruence Class Select
generate begin : stpCClass
      genvar                            cclass;
      for (cclass=0; cclass<numCClass; cclass=cclass+1) begin : stpCClass
         wire [uprCClassBit:lwrCClassBit]       cclassDummy = cclass;
         assign stq2_congr_cl_1hot[cclass] = (cclassDummy == stq2_congr_cl_q);
      end
   end
endgenerate

// Reload Path Directory Valid Bits Muxing

always @(*) begin: p1WayRd
   reg  [0:dirState-1]               wAState;
   reg  [0:dirState-1]               wBState;
   reg  [0:dirState-1]               wCState;
   reg  [0:dirState-1]               wDState;
   reg  [0:dirState-1]               wEState;
   reg  [0:dirState-1]               wFState;
   reg  [0:dirState-1]               wGState;
   reg  [0:dirState-1]               wHState;

   (* analysis_not_referenced="true" *)

   integer                           cclass;
   wAState = {dirState{1'b0}};
   wBState = {dirState{1'b0}};
   wCState = {dirState{1'b0}};
   wDState = {dirState{1'b0}};
   wEState = {dirState{1'b0}};
   wFState = {dirState{1'b0}};
   wGState = {dirState{1'b0}};
   wHState = {dirState{1'b0}};
   for (cclass=0; cclass<numCClass; cclass=cclass+1)
   begin
      wAState = (congr_cl_wA_q[cclass] & {dirState{stq2_congr_cl_1hot[cclass]}}) | wAState;
      wBState = (congr_cl_wB_q[cclass] & {dirState{stq2_congr_cl_1hot[cclass]}}) | wBState;
      wCState = (congr_cl_wC_q[cclass] & {dirState{stq2_congr_cl_1hot[cclass]}}) | wCState;
      wDState = (congr_cl_wD_q[cclass] & {dirState{stq2_congr_cl_1hot[cclass]}}) | wDState;
      wEState = (congr_cl_wE_q[cclass] & {dirState{stq2_congr_cl_1hot[cclass]}}) | wEState;
      wFState = (congr_cl_wF_q[cclass] & {dirState{stq2_congr_cl_1hot[cclass]}}) | wFState;
      wGState = (congr_cl_wG_q[cclass] & {dirState{stq2_congr_cl_1hot[cclass]}}) | wGState;
      wHState = (congr_cl_wH_q[cclass] & {dirState{stq2_congr_cl_1hot[cclass]}}) | wHState;
   end
   p1_arr_way_rd[0] <= wAState;
   p1_arr_way_rd[1] <= wBState;
   p1_arr_way_rd[2] <= wCState;
   p1_arr_way_rd[3] <= wDState;
   p1_arr_way_rd[4] <= wEState;
   p1_arr_way_rd[5] <= wFState;
   p1_arr_way_rd[6] <= wGState;
   p1_arr_way_rd[7] <= wHState;
end

// ####################################################
// Reload/Commit Pipe Bypass
// ####################################################
// Determine if there is any updates in later stages to the same congruence class
// There is no Thread Check for bypass here since everything is guaranteed to commit
assign congr_cl_stq2_stq3_cmp_d = (stq1_congr_cl == stq2_congr_cl_q);
assign congr_cl_stq2_stq4_cmp_d = (stq1_congr_cl == stq3_congr_cl_q);
assign congr_cl_stq2_stq5_cmp_d = (stq1_congr_cl == stq4_congr_cl_q);
assign congr_cl_stq3_stq4_cmp_d = congr_cl_stq2_stq3_cmp_q;
assign congr_cl_stq2_ex5_cmp_d  = (stq1_congr_cl == ex4_congr_cl_q);
assign congr_cl_stq2_ex6_cmp_d  = (stq1_congr_cl == ex5_congr_cl_q);
assign congr_cl_stq3_ex5_cmp_d  = (stq2_congr_cl_q == ex4_congr_cl_q);
assign congr_cl_stq4_ex5_cmp_d  = (stq3_congr_cl_q == ex4_congr_cl_q);
assign congr_cl_stq3_ex6_cmp_d  = congr_cl_stq2_ex5_cmp_q;

// Dont want to bypass rel_set_dir_val to a store commit instruction when the cclass matches
// The rel_set_dir_val has not updated the directory TAG and the bypass would cause a false hit
// The store commit could hit against a TAG that was invalid and the reload is overwritting it
// Reloads should bypass the rel_set_dir_val results since its used as part of the LRU calculation
assign congr_cl_stq2_stq3_m = congr_cl_stq2_stq3_cmp_q & (stq3_rel3_val_q | (rel3_set_dir_val_q & (rel2_set_stg_val_q | rel2_clr_stg_val_q)));
assign congr_cl_stq2_stq4_m = congr_cl_stq2_stq4_cmp_q & (stq4_rel4_val_q | (rel4_set_dir_val_q & (rel2_set_stg_val_q | rel2_clr_stg_val_q)));
assign congr_cl_stq2_stq5_m = congr_cl_stq2_stq5_cmp_q & p1_wren_cpy_q;     // Dont need rel5_set_dir_val check here since ldq_stq_stq4_dir_upd wont allow it
assign congr_cl_stq2_ex5_m  = congr_cl_stq2_ex5_cmp_q & (ex5_binv_val_q | (ex5_lock_set_q & rel2_clr_stg_val_q));
assign congr_cl_stq2_ex6_m  = congr_cl_stq2_ex6_cmp_q & p0_wren_q;

generate begin : stpByp
      genvar                            ways;
      for (ways=0; ways<numWays; ways=ways+1) begin : stpByp

         // Way Bypass Calculation                                                             Should have the following priority
         assign congr_cl_stq2_way_byp[ways][0] = congr_cl_stq2_ex5_m  & ex5_way_upd_q[ways];	    // 1
         assign congr_cl_stq2_way_byp[ways][1] = congr_cl_stq2_ex6_m  & ex6_way_upd_q[ways];		// 2
         assign congr_cl_stq2_way_byp[ways][2] = congr_cl_stq2_stq3_m & stq3_way_upd[ways];		    // 3    <-- slowest of all of them
         assign congr_cl_stq2_way_byp[ways][3] = congr_cl_stq2_stq4_m & stq4_way_upd_q[ways];		// 4
         assign congr_cl_stq2_way_byp[ways][4] = congr_cl_stq2_stq5_m & stq5_way_upd_q[ways];		// 5

         // Late Stages Priority Selection
         assign congr_cl_stq2_way_sel[ways][1] = congr_cl_stq2_way_byp[ways][0];
         assign congr_cl_stq2_way_sel[ways][2] = congr_cl_stq2_way_byp[ways][1] &    ~congr_cl_stq2_way_byp[ways][0];
         assign congr_cl_stq2_way_sel[ways][3] = congr_cl_stq2_way_byp[ways][3] & ~(|(congr_cl_stq2_way_byp[ways][0:1]));
         assign congr_cl_stq2_way_sel[ways][4] = congr_cl_stq2_way_byp[ways][4] & ~(|(congr_cl_stq2_way_byp[ways][0:1]) | congr_cl_stq2_way_byp[ways][3]);

         assign stq2_way_arr_sel[ways] = |(congr_cl_stq2_way_byp[ways]);
         assign stq2_way_stg_pri[ways] = (ex5_dir_way_q[ways]    & {dirState{congr_cl_stq2_way_sel[ways][1]}}) |
                                         (ex6_dir_way_q[ways]    & {dirState{congr_cl_stq2_way_sel[ways][2]}}) |
                                         (stq4_dir_way_rel[ways] & {dirState{congr_cl_stq2_way_sel[ways][3]}}) |
                                         (stq5_dir_way_q[ways]   & {dirState{congr_cl_stq2_way_sel[ways][4]}}) |
                                         (p1_arr_way_rd[ways]    & {dirState{    ~stq2_way_arr_sel[ways]}});

         assign stq3_way_val_d[ways] = (stq3_dir_way[ways]     & {dirState{ congr_cl_stq2_way_byp[ways][2]}}) |
                                       (stq2_way_stg_pri[ways] & {dirState{~congr_cl_stq2_way_byp[ways][2]}});
         assign stq4_way_val_d[ways] = stq3_way_val_q[ways][2:dirState-1];
      end
   end
endgenerate

// ####################################################
// Reload/Commit Directory Update
// ####################################################
generate begin : stpCtrl
      genvar                            ways;
      for (ways=0; ways<numWays; ways=ways+1) begin : stpCtrl
         // Hit Detect
         assign stq3_way_hit[ways] = stq3_way_val_q[ways][0] & stq3_dir_upd_val_q & stq3_way_cmp[ways];

         // Invalidate/Reload Logic on Port1
         //                                               CLEAR VALID                                             SET VALID
         assign stq3_dir_way[ways][0] = ((~(rel_way_clr[ways] | stq3_inval_op_q)) & stq3_way_val_q[ways][0]) | rel_way_set[ways];

         // Lock Clear/Set Logic on Port1
         //                                               CLEAR LOCK                                              SET LOCK
         assign stq3_dir_way[ways][1] = ((~(rel_way_clr[ways] | stq3_clr_lock)) & stq3_way_val_q[ways][1]) | (rel3_lock_set_q & rel_way_set[ways]);

         // Determine Lock Bit Set Per Way
         assign stq3_way_lock[ways] = stq3_way_val_q[ways][1];

         // Need to detect if Back-Invalidate or invalidate type instruction invalidated the lock bit
         assign stq4_clr_lck_way_d[ways] = (rel_way_clr[ways] | stq3_inval_op_q) & stq3_way_val_q[ways][1];

         // Set/Clr Watch Bit for Thread on Port1
         // Cacheline Watch Bits
         begin : P1Watch
            genvar                            tid;
            for (tid=0; tid<`THREADS; tid=tid+1) begin : P1Watch
               assign stq3_dir_way[ways][2 + tid] = (stq3_way_val_q[ways][2 + tid] & (~(stq3_clr_watch[tid] | rel_way_clr[ways]))) | (rel3_set_watch[tid] & rel_way_set[ways]);
            end
         end

         // Determine if a Watch Bit was lost
         assign stq4_lose_watch_way[ways] = (stq4_lose_watch_q & stq4_way_hit_q[ways]) | stq4_rel_way_clr_q[ways];
         assign stq4_lost_way[ways]       = stq4_way_val_q[ways][2:dirState-1] & {dirState-2{stq4_lose_watch_way[ways]}};

         // Lost Watch due to Reload Eviction
         assign rel_lost_watch_way_evict[ways] = stq4_way_val_q[ways][2:dirState-1] & {dirState-2{stq4_rel_way_clr_q[ways]}};

         // Lost EX5 Watch due to a Reload Eviction
         assign ex7_lost_watch_way_evict[ways] = ex7_dir_way_q[ways][2:dirState - 1] & {dirState-2{(ex7_watch_set_inval_q & ex7_way_upd_q[ways] & stq4_rel_way_clr_q[ways])}};

         // Updating due to Reload or Store Commit Instruction
         assign stq3_way_upd[ways]     = rel_way_clr[ways] | rel_way_set[ways] | (stq3_way_hit[ways] & stq3_dir_upd_val_q);
         assign stq4_way_upd_d[ways]   = stq3_way_upd[ways];
         assign stq4_way_upd[ways]     = stq4_way_upd_q[ways] | stq4_way_perr_inval[ways];
         assign stq5_way_upd_d[ways]   = stq4_way_upd[ways];
         assign stq6_way_upd_d[ways]   = stq5_way_upd_q[ways];
         assign stq7_way_upd_d[ways]   = stq6_way_upd_q[ways];
         assign stq4_dir_way_d[ways]   = stq3_dir_way[ways];
         assign stq4_dir_way_err[ways] = stq4_dir_way_q[ways] & {dirState{~(stq4_way_perr_inval[ways] | stq4_stq_stp_err_det[ways] | stq4_ex_ldp_err_det[ways])}};
         assign stq5_dir_way_d[ways]   = stq4_dir_way_err[ways];

         // Error Detected in EX5 Load Pipe to same congruence class as store commit in STQ2 or STQ3 or STQ4
         assign stq2_ex5_ldp_err[ways]    = congr_cl_stq2_ex5_cmp_q & ex5_way_perr_inval[ways];
         assign stq3_ex6_ldp_err_d[ways]  = stq2_ex5_ldp_err[ways];
         assign stq4_ex7_ldp_err_d[ways]  = stq3_ex6_ldp_err_q[ways];
         assign stq3_ex5_ldp_err[ways]    = congr_cl_stq3_ex5_cmp_q & ex5_way_perr_inval[ways];
         assign stq4_ex6_ldp_err_d[ways]  = stq3_ex5_ldp_err[ways];
         assign stq4_ex5_ldp_err[ways]    = congr_cl_stq4_ex5_cmp_q & ex5_way_perr_inval[ways];
         assign stq4_ex_ldp_err_det[ways] = stq4_ex5_ldp_err[ways] | stq4_ex6_ldp_err_q[ways] | stq4_ex7_ldp_err_q[ways];

         // Error Detected in STQ4 Commit Pipe to same congruence class as store commit in STQ2 or STQ3
         assign stq2_stq4_stp_err[ways]    = congr_cl_stq2_stq4_cmp_q & stq4_way_perr_inval[ways];
         assign stq3_stq5_stp_err_d[ways]  = stq2_stq4_stp_err[ways];
         assign stq4_stq6_stp_err_d[ways]  = stq3_stq5_stp_err_q[ways];
         assign stq3_stq4_stp_err[ways]    = congr_cl_stq3_stq4_cmp_q & stq4_way_perr_inval[ways];
         assign stq4_stq5_stp_err_d[ways]  = stq3_stq4_stp_err[ways];
         assign stq4_stq_stp_err_det[ways] = stq4_stq5_stp_err_q[ways] | stq4_stq6_stp_err_q[ways];

         // Reload Clearing Way
         assign stq4_rel_way_clr_d[ways] = rel_way_clr[ways];

         // Need to set reload way valid bit when clearing the valid bit of older load
         // in case second reload of interleaved reloads to same congruence class
         // Dont want second reload to overwrite first reload that cleared the valid bit
         // Second reload will choose the same way if not set by first
         assign stq4_dir_way_rel[ways][0]              = (rel2_clr_stg_val_q & stq4_rel_way_clr_q[ways]) | (stq4_dir_way_q[ways][0] & (~stq4_rel_way_clr_q[ways]));
         assign stq4_dir_way_rel[ways][1:dirState - 1] = stq4_dir_way_q[ways][1:dirState - 1];
      end
   end
endgenerate

// Recirculation Pipe Hit/Miss
assign stq3_miss =  stq3_hit_or_01234567_b;
assign stq3_hit  = ~stq3_hit_or_01234567_b;

// Invalidate Lock Bit Detected
assign stq4_inval_clr_lock = |(stq4_clr_lck_way_q & stq4_way_upd_q);

// One of the Ways has a Lock Bit set
assign stq4_cClass_lock_set_d = |(stq3_way_lock);

// Reload Lost Lock due to Back-Invalidate of loadmissQ entry
// rel3_upd_val indicatest that the reload completed without an ecc error
assign rel3_way_set           = |(rel_way_set);
assign rel3_binv_lock_lost    = rel3_lock_set_q & rel3_set_stg_val_q & rel3_way_set & rel3_back_inv_q & rel3_upd_val_q;
assign rel3_l1dump_lock_lost  = lsq_ctl_rel3_l1dump_val & rel3_lock_pipe_q & ~spr_xucr0_dcdis;
assign binv_rel_lock_lost     = rel3_binv_lock_lost | rel3_l1dump_lock_lost;

// Determine if Watch was lost due to a reload or due to a Back-Invalidate of loadmissQ entry
// rel3_upd_val indicatest that the reload completed without an ecc error
assign rel3_binv_watch_lost   = rel3_watch_set_q & rel3_set_stg_val_q & rel3_back_inv_q & rel3_upd_val_q;
assign rel3_l1dump_watch_lost = lsq_ctl_rel3_l1dump_val & rel3_watch_pipe_q & ~spr_xucr0_dcdis;
assign rel3_ovl_watch_lost    = rel3_watch_set_q & rel3_set_stg_val_q & ~rel3_way_set & rel3_upd_val_q;
assign rel3_all_watch_lost    = rel3_thrd_id_q & {`THREADS{(rel3_binv_watch_lost | rel3_l1dump_watch_lost | rel3_ovl_watch_lost)}};
assign rel4_all_watch_lost_d  = rel3_all_watch_lost;

// Watch Lost due to Invalidating Type Instruction, Reload Clear, Back-Invalidate of a Reload, or Directory Parity Error
assign stq4_lost_watch = stq4_instr_watch_lost | rel4_all_watch_lost_q | stq4_perr_watchlost_q;

// Way Watch Bits OR Reduced

always @(*) begin: stpThrdWatch
   reg  [0:`THREADS-1]               tidW;
   reg  [0:`THREADS-1]               tidWLs;
   reg  [0:`THREADS-1]               tidWLr;
   reg  [0:`THREADS-1]               tidWLl;
   reg  [0:`THREADS-1]               tidWLp;

   (* analysis_not_referenced="true" *)

   integer                           ways;
   tidW   = {`THREADS{1'b0}};
   tidWLs = {`THREADS{1'b0}};
   tidWLr = {`THREADS{1'b0}};
   tidWLl = {`THREADS{1'b0}};
   tidWLp = {`THREADS{1'b0}};
   for (ways=0; ways<numWays; ways=ways+1)
   begin
      tidW   = stq3_way_val_q[ways][2:dirState - 1] | tidW;
      tidWLs = stq4_lost_way[ways]                  | tidWLs;
      tidWLr = rel_lost_watch_way_evict[ways]       | tidWLr;
      tidWLl = ex7_lost_watch_way_evict[ways]       | tidWLl;
      tidWLp = stq3_err_way_watchlost[ways]         | tidWLp;
   end
   // `THREADS Watching one of the ways in STQ3
   stq4_cClass_thrd_watch_d <= tidW;

   // Watch Lost due to Instruction
   stq4_instr_watch_lost <= tidWLs;

   // Watch Lost due to Eviction
   rel_lost_watch_evict <= tidWLr;

   // EX5 Watch Lost due to Eviction
   ex7_lost_watch_evict <= tidWLl;

   // Watch Lost due to Parity Error
   stq4_perr_watchlost_d <= tidWLp;
end

// Want to still update the STM_WATCHLOST indicator if the DCDIS=1
generate begin : wLVal
      genvar                            tid;
      for (tid = 0; tid <= `THREADS - 1; tid = tid + 1) begin : wLVal
         assign stq4_watchlost_value[tid] = ~stq4_watch_clr_all[tid] ? stq4_lost_watch[tid] : stq4_l_fld_b1_q;
      end
   end
endgenerate

// Update STM_WACHTLOST valid
assign stq4_watch_clr_all = stq4_thrd_id_q & {`THREADS{stq4_watch_clr_all_q}};
assign stq4_watchlost_upd = stq4_lost_watch | stq4_watch_clr_all | stq4_multihit_watch_lost | ex7_lost_watch_evict | stq4_dci_watch_lost;

// Update STM_WATCHLOST contents
assign stq4_watchlost_set = stq4_watchlost_value | stq4_multihit_watch_lost | ex7_lost_watch_evict | stq4_dci_watch_lost;

// Watch Lost due to Overlock
assign lost_watch_evict_ovl_d = rel3_thrd_id_q & {`THREADS{(rel3_l1dump_watch_lost | rel3_ovl_watch_lost)}};

// Multihit Error Detected
// ####################################################
// Level 1
assign stq3_hit_and_01_b = ~(stq3_way_hit[0] & stq3_way_hit[1]);
assign stq3_hit_and_23_b = ~(stq3_way_hit[2] & stq3_way_hit[3]);
assign stq3_hit_and_45_b = ~(stq3_way_hit[4] & stq3_way_hit[5]);
assign stq3_hit_and_67_b = ~(stq3_way_hit[6] & stq3_way_hit[7]);
assign stq3_hit_or_01_b  = ~(stq3_way_hit[0] | stq3_way_hit[1]);
assign stq3_hit_or_23_b  = ~(stq3_way_hit[2] | stq3_way_hit[3]);
assign stq3_hit_or_45_b  = ~(stq3_way_hit[4] | stq3_way_hit[5]);
assign stq3_hit_or_67_b  = ~(stq3_way_hit[6] | stq3_way_hit[7]);

// Level 2
assign stq3_hit_or_0123      = ~(stq3_hit_or_01_b & stq3_hit_or_23_b);
assign stq3_hit_or_4567      = ~(stq3_hit_or_45_b & stq3_hit_or_67_b);
assign stq3_hit_and_0123     = ~(stq3_hit_or_01_b | stq3_hit_or_23_b);
assign stq3_hit_and_4567     = ~(stq3_hit_or_45_b | stq3_hit_or_67_b);
assign stq3_multi_hit_err2_0 = ~(stq3_hit_and_01_b & stq3_hit_and_23_b);
assign stq3_multi_hit_err2_1 = ~(stq3_hit_and_45_b & stq3_hit_and_67_b);

// Level 3
assign stq3_hit_or_01234567_b   = ~(stq3_hit_or_0123 | stq3_hit_or_4567);
assign stq3_multi_hit_err3_b[0] = ~(stq3_hit_or_0123 & stq3_hit_or_4567);
assign stq3_multi_hit_err3_b[1] = ~(stq3_hit_and_0123 | stq3_hit_and_4567);
assign stq3_multi_hit_err3_b[2] = ~(stq3_multi_hit_err2_0 | stq3_multi_hit_err2_1);

// Level 4
// Multihit Error Detected
assign stq3_dir_multihit_val_0 = ~(stq3_multi_hit_err3_b[0] & stq3_multi_hit_err3_b[1]);
assign stq3_dir_multihit_val_1 = ~(stq3_multi_hit_err3_b[2] & inj_dirmultihit_stp_b);

// Level 5
assign stq3_dir_multihit_val_b = ~(stq3_dir_multihit_val_0 | stq3_dir_multihit_val_1);

assign stq4_dir_multihit_val_b_d = stq3_dir_multihit_val_b;
assign stq4_dir_multihit_det     = stq4_dir_upd_val_q & ~stq4_dir_multihit_val_b_q;

// Lock Bit Lost due to Multihit Error
assign stq4_multihit_lock_lost = stq4_dir_multihit_det & stq4_cClass_lock_set_q;

// Watch Lost due to Multihit Error
assign stq4_multihit_watch_lost = stq4_cClass_thrd_watch_q & {`THREADS{stq4_dir_multihit_det}};

// Parity Error Detect
// ####################################################
generate begin : stpErrGen
      genvar                            ways;
      for (ways=0; ways<numWays; ways=ways+1) begin : stpErrGen
         assign stq3_err_det_way[ways]       = stq3_way_val_q[ways][0] & stq3_tag_way_perr[ways];
         assign stq4_err_det_way_d[ways]     = stq3_err_det_way[ways];
         assign stq3_err_lock_lost[ways]     = stq3_way_val_q[ways][1] & stq3_tag_way_perr[ways];
         assign stq3_err_way_watchlost[ways] = stq3_way_val_q[ways][2:dirState - 1] & {dirState-2{stq3_tag_way_perr[ways]}};
      end
   end
endgenerate

// Lock Bit Lost due to Parity Error
assign stq4_perr_lock_lost_d = |(stq3_err_lock_lost);

// Parity Error Detected
assign stq4_dir_perr_det_d    = |(stq3_err_det_way);
assign stq4_way_perr_inval    = stq4_err_det_way_q | {numWays{stq4_dir_multihit_det}};
assign stq5_way_perr_inval_d  = stq4_way_perr_inval;
assign ex5_stp_perr_flush_d   = |(stq3_err_det_way)  & ex4_cache_acc_q & ~fgen_ex4_cp_flush;
assign ex5_stp_multihit_flush = ex5_mhit_cacc_q & stq4_dir_multihit_det;

// Staging out Directory Error
assign stq4_dir_err_val   = stq4_dir_perr_det_q | stq4_dir_multihit_det;
assign stq5_dir_err_val_d = stq4_dir_err_val;

// ####################################################
// Update Watch Lost State Bits per thread
// ####################################################

generate begin : wLost
      genvar                            tid;
      for (tid=0; tid<`THREADS; tid=tid+1) begin : wLost
         assign stm_upd_watchlost_tid[tid] = {stq4_watchlost_upd[tid], ex5_watchlost_upd[tid]};
         assign stm_watchlost[tid] = (stm_upd_watchlost_tid[tid] == 2'b00) ? stm_watchlost_state_q[tid] :
                                     (stm_upd_watchlost_tid[tid] == 2'b01) ? ex5_watchlost_set[tid] :
                                     stq4_watchlost_set[tid];
      end
   end
endgenerate

// Watch Lost Bits
assign stm_watchlost_state_d = stm_watchlost;

// ####################################################
// Performance Events
// ####################################################
// Performance Event, Back-Invalidate Hit
assign perf_dir_binv_val = ex5_binv_val_q;
assign perf_dir_binv_hit = ex5_binv_val_q & |(ex5_way_hit_q);

// Performance Event, Watches lost due to other thread
assign lost_watch_inter_thrd_d     = ((ex5_watchlost_set  & ~ex5_thrd_id_q)                         & {`THREADS{ex5_xuop_upd_val}}) |
                                     ((stq4_watchlost_set & ~(stq4_thrd_id_q | stq4_watch_clr_all)) & {`THREADS{stq4_val_q}});
assign perf_dir_interTid_watchlost = lost_watch_inter_thrd_q;

// Performance Event, Watches lost due to Eviction or Overlock
assign lost_watch_evict_val_d   = lost_watch_evict_ovl_q | rel_lost_watch_evict | ex7_lost_watch_evict;
assign perf_dir_evict_watchlost = lost_watch_evict_val_q;

// Performance Event, Watch Lost due to back-invalidate
assign lost_watch_binv_d       = ex5_watchlost_binv | rel3_all_watch_lost;
assign perf_dir_binv_watchlost = lost_watch_binv_q;

// ####################################################
// Directory Valid Bits Write Enable Generation
// ####################################################
// Valids are updated for the following operations
// 1) Reload -> updated the following cycle of the first beat,
//              need to invalidate the way that will be overwritten
// 2) Reload -> updated on the last data beat when no ECC error was detected,
//              the Way will be validated that was replaced
// 3) Back-Invalidate -> updated the following cycle
// 4) DCBF -> Updated in ex5
// 5) DCBI -> Updated in ex5
// 6) DCBZ -> Updated in ex5
// 7) LWARX Hit Invalidate -> Updated in ex5
// 8) STWCX Hit Invalidate -> Updated in ex5
//
// Lock Bits are updated for the following operations
// 1) Reload -> updated the following cycle of the first beat,
//              need to clear the lock bit for the way that will be overwritten
// 2) Reload -> updated on the last data beat when no ECC error was detected,
//              the Lock bit will be set that was replaced if originally a lock type op
// 3) Back-Invalidate -> will clear lock bit the following cycle
// 4) DCBF -> will clear lock bit in ex5
// 5) DCBI -> will clear lock bit in ex5
// 6) DCBZ -> will clear lock bit in ex5
// 7) LWARX Hit Invalidate -> will clear lock bit in ex5
// 8) STWCX Hit Invalidate -> will clear lock bit in ex5
// 9) DCBLC -> will clear lock bit in ex5
//10) DCBTLS/DCBTSTLS -> will set lock bit in ex5 if hit

// Port0 Updates
// 1) XU Invalidate Op
// 2) BACK-INV Update
// 3) XU clear Lock Op
// 4) XU set Lock Op
assign p0_wren_d     = ex5_xuop_upd_val | ex5_binv_val_q | ex5_way_err_val;
assign p0_wren_cpy_d = ex5_xuop_upd_val | ex5_binv_val_q | ex5_way_err_val;
assign p0_wren_stg_d = p0_wren_q;

// Port1 Updates
// 1) RELOAD_CLR
// 2) RELOAD_SET
// 3) DC Array Parity Error with Loadhit followed by storehit update - need to invalidate storehit cline
assign p1_wren_d     = stq4_rel4_val_q | rel4_set_dir_val_q;
assign p1_wren_cpy_d = stq4_rel4_val_q | rel4_set_dir_val_q;
assign stq6_wren_d   = p1_wren_q;
assign stq7_wren_d   = stq6_wren_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Table for selecting Ports data for
// updating to the same way and
// same congruence class
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// P0           P1      |       PortSel
//------------------------------------------
// binv2        relclr  |       P1
// binv2        relset  |       P1
// binv2        binv2   |       P1      <- Impossible
// flush        relclr  |       P1
// flush        relset  |       P1
// flush        binv2   |       P1      <- FlushOp is flushed
// lckset       relclr  |       P1
// lckset       relset  |       P1
// lckset       binv2   |       P1      <- LockSetOp is flushed
// lckclr       relclr  |       P1
// lckclr       relset  |       P1
// lckclr       binv2   |       P1      <- LockClrOp is flushed

// Act Pin to all Directory Latches
assign congr_cl_all_act_d = (stq4_watch_clr_all_q & stq4_val_q) | stq4_dci_val_q | spr_xucr0_clfc_q;

generate begin : dirUpdCtrl
      genvar                            cclass;
      for (cclass=0; cclass<numCClass; cclass=cclass+1) begin : dirUpdCtrl
         wire [uprCClassBit:lwrCClassBit]       cclassDummy = cclass;

         // Congruence Class Match
         assign p0_congr_cl_m[cclass] = (ex5_congr_cl_q  == cclassDummy);
         assign p1_congr_cl_m[cclass] = (stq4_congr_cl_q == cclassDummy);

         // Act Pin to Directory Latches for specific congruence class
         assign p0_congr_cl_act_d[cclass] = p0_congr_cl_m[cclass] & (ex5_binv_val_q | ex5_xuop_upd_val_q | ex5_way_err_val);
         assign p1_congr_cl_act_d[cclass] = p1_congr_cl_m[cclass] & (stq4_rel4_val_q | rel4_set_dir_val_q | stq4_dir_err_val);
         assign congr_cl_act[cclass]      = p0_congr_cl_act_q[cclass] | p1_congr_cl_act_q[cclass] | congr_cl_all_act_q;

         begin : wayCtrl
            genvar                            ways;
            for (ways=0; ways<numWays; ways=ways+1) begin : wayCtrl
               assign p0_way_data_upd_way[cclass][ways] = p0_congr_cl_act_q[cclass] & ex6_way_upd_q[ways]  & p0_wren_q;
               assign p1_way_data_upd_way[cclass][ways] = p1_congr_cl_act_q[cclass] & stq5_way_upd_q[ways] & p1_wren_q;
            end
         end

         // ####################################################
         // Write Select for WayA
         // Mux Selects for Input to Latches
         assign rel_bixu_wayA_upd[cclass] = {p0_way_data_upd_way[cclass][0], p1_way_data_upd_way[cclass][0]};

         // WayA Valid Bit Update
         assign congr_cl_wA_d[cclass][0] = (rel_bixu_wayA_upd[cclass] == 2'b00) ? (congr_cl_wA_q[cclass][0] & (~val_finval_q)) :
                                           (rel_bixu_wayA_upd[cclass] == 2'b10) ? (ex6_dir_way_q[0][0] & (~val_finval_q)) :
                                           (stq5_dir_way_q[0][0] & (~val_finval_q));

         // WayA Lock Bit Update
         assign congr_cl_wA_d[cclass][1] = (rel_bixu_wayA_upd[cclass] == 2'b00) ? (congr_cl_wA_q[cclass][1] & (~lock_finval_q)) :
                                           (rel_bixu_wayA_upd[cclass] == 2'b10) ? (ex6_dir_way_q[0][1] & (~lock_finval_q)) :
                                           (stq5_dir_way_q[0][1] & (~lock_finval_q));

         // WayA Thread Watch Bit Update
         assign congr_cl_wA_d[cclass][2:dirState - 1] = (rel_bixu_wayA_upd[cclass] == 2'b00) ? (congr_cl_wA_q[cclass][2:dirState - 1] & (~watch_finval_q)) :
                                                        (rel_bixu_wayA_upd[cclass] == 2'b10) ? (ex6_dir_way_q[0][2:dirState - 1] & (~watch_finval_q)) :
                                                        (stq5_dir_way_q[0][2:dirState - 1] & (~watch_finval_q));

         // ####################################################
         // Write Select for WayB
         // Mux Selects for Input to Latches
         assign rel_bixu_wayB_upd[cclass] = {p0_way_data_upd_way[cclass][1], p1_way_data_upd_way[cclass][1]};

         // WayB Valid Bit Update
         assign congr_cl_wB_d[cclass][0] = (rel_bixu_wayB_upd[cclass] == 2'b00) ? (congr_cl_wB_q[cclass][0] & (~val_finval_q)) :
                                           (rel_bixu_wayB_upd[cclass] == 2'b10) ? (ex6_dir_way_q[1][0] & (~val_finval_q)) :
                                           (stq5_dir_way_q[1][0] & (~val_finval_q));

         // WayB Lock Bit Update
         assign congr_cl_wB_d[cclass][1] = (rel_bixu_wayB_upd[cclass] == 2'b00) ? (congr_cl_wB_q[cclass][1] & (~lock_finval_q)) :
                                           (rel_bixu_wayB_upd[cclass] == 2'b10) ? (ex6_dir_way_q[1][1] & (~lock_finval_q)) :
                                           (stq5_dir_way_q[1][1] & (~lock_finval_q));

         // WayB Thread Watch Bit Update
         assign congr_cl_wB_d[cclass][2:dirState - 1] = (rel_bixu_wayB_upd[cclass] == 2'b00) ? (congr_cl_wB_q[cclass][2:dirState - 1] & (~watch_finval_q)) :
                                                        (rel_bixu_wayB_upd[cclass] == 2'b10) ? (ex6_dir_way_q[1][2:dirState - 1] & (~watch_finval_q)) :
                                                        (stq5_dir_way_q[1][2:dirState - 1] & (~watch_finval_q));

         // ####################################################
         // Write Select for WayC
         // Mux Selects for Input to Latches
         assign rel_bixu_wayC_upd[cclass] = {p0_way_data_upd_way[cclass][2], p1_way_data_upd_way[cclass][2]};

         // WayC Valid Bit Update
         assign congr_cl_wC_d[cclass][0] = (rel_bixu_wayC_upd[cclass] == 2'b00) ? (congr_cl_wC_q[cclass][0] & (~val_finval_q)) :
                                           (rel_bixu_wayC_upd[cclass] == 2'b10) ? (ex6_dir_way_q[2][0] & (~val_finval_q)) :
                                           (stq5_dir_way_q[2][0] & (~val_finval_q));

         // WayC Lock Bit Update
         assign congr_cl_wC_d[cclass][1] = (rel_bixu_wayC_upd[cclass] == 2'b00) ? (congr_cl_wC_q[cclass][1] & (~lock_finval_q)) :
                                           (rel_bixu_wayC_upd[cclass] == 2'b10) ? (ex6_dir_way_q[2][1] & (~lock_finval_q)) :
                                           (stq5_dir_way_q[2][1] & (~lock_finval_q));

         // WayC Thread Watch Bit Update
         assign congr_cl_wC_d[cclass][2:dirState - 1] = (rel_bixu_wayC_upd[cclass] == 2'b00) ? (congr_cl_wC_q[cclass][2:dirState - 1] & (~watch_finval_q)) :
                                                        (rel_bixu_wayC_upd[cclass] == 2'b10) ? (ex6_dir_way_q[2][2:dirState - 1] & (~watch_finval_q)) :
                                                        (stq5_dir_way_q[2][2:dirState - 1] & (~watch_finval_q));

         // ####################################################
         // Write Select for WayD
         // Mux Selects for Input to Latches
         assign rel_bixu_wayD_upd[cclass] = {p0_way_data_upd_way[cclass][3], p1_way_data_upd_way[cclass][3]};

         // WayD Valid Bit Update
         assign congr_cl_wD_d[cclass][0] = (rel_bixu_wayD_upd[cclass] == 2'b00) ? (congr_cl_wD_q[cclass][0] & (~val_finval_q)) :
                                           (rel_bixu_wayD_upd[cclass] == 2'b10) ? (ex6_dir_way_q[3][0] & (~val_finval_q)) :
                                           (stq5_dir_way_q[3][0] & (~val_finval_q));

         // WayD Lock Bit Update
         assign congr_cl_wD_d[cclass][1] = (rel_bixu_wayD_upd[cclass] == 2'b00) ? (congr_cl_wD_q[cclass][1] & (~lock_finval_q)) :
                                           (rel_bixu_wayD_upd[cclass] == 2'b10) ? (ex6_dir_way_q[3][1] & (~lock_finval_q)) :
                                           (stq5_dir_way_q[3][1] & (~lock_finval_q));

         // WayD Thread Watch Bit Update
         assign congr_cl_wD_d[cclass][2:dirState - 1] = (rel_bixu_wayD_upd[cclass] == 2'b00) ? (congr_cl_wD_q[cclass][2:dirState - 1] & (~watch_finval_q)) :
                                                        (rel_bixu_wayD_upd[cclass] == 2'b10) ? (ex6_dir_way_q[3][2:dirState - 1] & (~watch_finval_q)) :
                                                        (stq5_dir_way_q[3][2:dirState - 1] & (~watch_finval_q));

         // ####################################################
         // Write Select for WayE
         // Mux Selects for Input to Latches
         assign rel_bixu_wayE_upd[cclass] = {p0_way_data_upd_way[cclass][4], p1_way_data_upd_way[cclass][4]};

         // WayE Valid Bit Update
         assign congr_cl_wE_d[cclass][0] = (rel_bixu_wayE_upd[cclass] == 2'b00) ? (congr_cl_wE_q[cclass][0] & (~val_finval_q)) :
                                           (rel_bixu_wayE_upd[cclass] == 2'b10) ? (ex6_dir_way_q[4][0] & (~val_finval_q)) :
                                           (stq5_dir_way_q[4][0] & (~val_finval_q));

         // WayE Lock Bit Update
         assign congr_cl_wE_d[cclass][1] = (rel_bixu_wayE_upd[cclass] == 2'b00) ? (congr_cl_wE_q[cclass][1] & (~lock_finval_q)) :
                                           (rel_bixu_wayE_upd[cclass] == 2'b10) ? (ex6_dir_way_q[4][1] & (~lock_finval_q)) :
                                           (stq5_dir_way_q[4][1] & (~lock_finval_q));

         // WayE Thread Watch Bit Update
         assign congr_cl_wE_d[cclass][2:dirState - 1] = (rel_bixu_wayE_upd[cclass] == 2'b00) ? (congr_cl_wE_q[cclass][2:dirState - 1] & (~watch_finval_q)) :
                                                        (rel_bixu_wayE_upd[cclass] == 2'b10) ? (ex6_dir_way_q[4][2:dirState - 1] & (~watch_finval_q)) :
                                                        (stq5_dir_way_q[4][2:dirState - 1] & (~watch_finval_q));

         // ####################################################
         // Write Select for WayF
         // Mux Selects for Input to Latches
         assign rel_bixu_wayF_upd[cclass] = {p0_way_data_upd_way[cclass][5], p1_way_data_upd_way[cclass][5]};

         // WayF Valid Bit Update
         assign congr_cl_wF_d[cclass][0] = (rel_bixu_wayF_upd[cclass] == 2'b00) ? (congr_cl_wF_q[cclass][0] & (~val_finval_q)) :
                                           (rel_bixu_wayF_upd[cclass] == 2'b10) ? (ex6_dir_way_q[5][0] & (~val_finval_q)) :
                                           (stq5_dir_way_q[5][0] & (~val_finval_q));

         // WayF Lock Bit Update
         assign congr_cl_wF_d[cclass][1] = (rel_bixu_wayF_upd[cclass] == 2'b00) ? (congr_cl_wF_q[cclass][1] & (~lock_finval_q)) :
                                           (rel_bixu_wayF_upd[cclass] == 2'b10) ? (ex6_dir_way_q[5][1] & (~lock_finval_q)) :
                                           (stq5_dir_way_q[5][1] & (~lock_finval_q));

         // WayF Thread Watch Bit Update
         assign congr_cl_wF_d[cclass][2:dirState - 1] = (rel_bixu_wayF_upd[cclass] == 2'b00) ? (congr_cl_wF_q[cclass][2:dirState - 1] & (~watch_finval_q)) :
                                                        (rel_bixu_wayF_upd[cclass] == 2'b10) ? (ex6_dir_way_q[5][2:dirState - 1] & (~watch_finval_q)) :
                                                        (stq5_dir_way_q[5][2:dirState - 1] & (~watch_finval_q));

         // ####################################################
         // Write Select for WayG
         // Mux Selects for Input to Latches
         assign rel_bixu_wayG_upd[cclass] = {p0_way_data_upd_way[cclass][6], p1_way_data_upd_way[cclass][6]};

         // WayG Valid Bit Update
         assign congr_cl_wG_d[cclass][0] = (rel_bixu_wayG_upd[cclass] == 2'b00) ? (congr_cl_wG_q[cclass][0] & (~val_finval_q)) :
                                           (rel_bixu_wayG_upd[cclass] == 2'b10) ? (ex6_dir_way_q[6][0] & (~val_finval_q)) :
                                           (stq5_dir_way_q[6][0] & (~val_finval_q));

         // WayG Lock Bit Update
         assign congr_cl_wG_d[cclass][1] = (rel_bixu_wayG_upd[cclass] == 2'b00) ? (congr_cl_wG_q[cclass][1] & (~lock_finval_q)) :
                                           (rel_bixu_wayG_upd[cclass] == 2'b10) ? (ex6_dir_way_q[6][1] & (~lock_finval_q)) :
                                           (stq5_dir_way_q[6][1] & (~lock_finval_q));

         // WayG Thread Watch Bit Update
         assign congr_cl_wG_d[cclass][2:dirState - 1] = (rel_bixu_wayG_upd[cclass] == 2'b00) ? (congr_cl_wG_q[cclass][2:dirState - 1] & (~watch_finval_q)) :
                                                        (rel_bixu_wayG_upd[cclass] == 2'b10) ? (ex6_dir_way_q[6][2:dirState - 1] & (~watch_finval_q)) :
                                                        (stq5_dir_way_q[6][2:dirState - 1] & (~watch_finval_q));

         // ####################################################
         // Write Select for WayH
         // Mux Selects for Input to Latches
         assign rel_bixu_wayH_upd[cclass] = {p0_way_data_upd_way[cclass][7], p1_way_data_upd_way[cclass][7]};

         // WayH Valid Bit Update
         assign congr_cl_wH_d[cclass][0] = (rel_bixu_wayH_upd[cclass] == 2'b00) ? (congr_cl_wH_q[cclass][0] & (~val_finval_q)) :
                                           (rel_bixu_wayH_upd[cclass] == 2'b10) ? (ex6_dir_way_q[7][0] & (~val_finval_q)) :
                                           (stq5_dir_way_q[7][0] & (~val_finval_q));

         // WayH Lock Bit Update
         assign congr_cl_wH_d[cclass][1] = (rel_bixu_wayH_upd[cclass] == 2'b00) ? (congr_cl_wH_q[cclass][1] & (~lock_finval_q)) :
                                           (rel_bixu_wayH_upd[cclass] == 2'b10) ? (ex6_dir_way_q[7][1] & (~lock_finval_q)) :
                                           (stq5_dir_way_q[7][1] & (~lock_finval_q));

         // WayH Thread Watch Bit Update
         assign congr_cl_wH_d[cclass][2:dirState - 1] = (rel_bixu_wayH_upd[cclass] == 2'b00) ? (congr_cl_wH_q[cclass][2:dirState - 1] & (~watch_finval_q)) :
                                                        (rel_bixu_wayH_upd[cclass] == 2'b10) ? (ex6_dir_way_q[7][2:dirState - 1] & (~watch_finval_q)) :
                                                        (stq5_dir_way_q[7][2:dirState - 1] & (~watch_finval_q));
      end
   end
endgenerate

// ####################################################
// Outputs
// ####################################################
assign ex4_way_hit_a = ex4_way_hit[0];
assign ex4_way_hit_b = ex4_way_hit[1];
assign ex4_way_hit_c = ex4_way_hit[2];
assign ex4_way_hit_d = ex4_way_hit[3];
assign ex4_way_hit_e = ex4_way_hit[4];
assign ex4_way_hit_f = ex4_way_hit[5];
assign ex4_way_hit_g = ex4_way_hit[6];
assign ex4_way_hit_h = ex4_way_hit[7];

assign dir_dcc_ex5_way_a_dir = ex5_way_val_q[0];
assign dir_dcc_ex5_way_b_dir = ex5_way_val_q[1];
assign dir_dcc_ex5_way_c_dir = ex5_way_val_q[2];
assign dir_dcc_ex5_way_d_dir = ex5_way_val_q[3];
assign dir_dcc_ex5_way_e_dir = ex5_way_val_q[4];
assign dir_dcc_ex5_way_f_dir = ex5_way_val_q[5];
assign dir_dcc_ex5_way_g_dir = ex5_way_val_q[6];
assign dir_dcc_ex5_way_h_dir = ex5_way_val_q[7];

assign stq2_ddir_acc  = stq2_dir_upd_val;
assign stq3_way_hit_a = stq3_way_hit[0];
assign stq3_way_hit_b = stq3_way_hit[1];
assign stq3_way_hit_c = stq3_way_hit[2];
assign stq3_way_hit_d = stq3_way_hit[3];
assign stq3_way_hit_e = stq3_way_hit[4];
assign stq3_way_hit_f = stq3_way_hit[5];
assign stq3_way_hit_g = stq3_way_hit[6];
assign stq3_way_hit_h = stq3_way_hit[7];

assign dir_dcc_ex5_cr_rslt = ex5_cr_watch_q;

assign rel_way_val_a = stq3_way_val_q[0][0];
assign rel_way_val_b = stq3_way_val_q[1][0];
assign rel_way_val_c = stq3_way_val_q[2][0];
assign rel_way_val_d = stq3_way_val_q[3][0];
assign rel_way_val_e = stq3_way_val_q[4][0];
assign rel_way_val_f = stq3_way_val_q[5][0];
assign rel_way_val_g = stq3_way_val_q[6][0];
assign rel_way_val_h = stq3_way_val_q[7][0];

assign rel_way_lock_a = stq3_way_val_q[0][1];
assign rel_way_lock_b = stq3_way_val_q[1][1];
assign rel_way_lock_c = stq3_way_val_q[2][1];
assign rel_way_lock_d = stq3_way_val_q[3][1];
assign rel_way_lock_e = stq3_way_val_q[4][1];
assign rel_way_lock_f = stq3_way_val_q[5][1];
assign rel_way_lock_g = stq3_way_val_q[6][1];
assign rel_way_lock_h = stq3_way_val_q[7][1];

// Performance Events
assign ctl_perv_dir_perf_events = {perf_dir_binv_val,        perf_dir_binv_hit,         perf_dir_binv_watchlost,
                                   perf_dir_evict_watchlost, perf_dir_interTid_watchlost};

// Parity Error Detected
assign dir_dcc_ex5_dir_perr_det   = ex5_dir_perr_det_q;
assign dir_dcc_ex5_dc_perr_det    = ex5_dc_perr_det_q;
assign dir_dcc_ex5_dir_perr_flush = ex5_dir_perr_flush_q;
assign dir_dcc_ex5_dc_perr_flush  = ex5_dc_perr_flush_q;
assign dir_dcc_stq4_dir_perr_det  = stq4_dir_perr_det_q;

// Directory MultiHit Detected
assign dir_dcc_ex5_multihit_det   = ex5_dir_multihit_det;
assign dir_dcc_ex5_multihit_flush = ex5_dir_multihit_flush;
assign dir_dcc_stq4_multihit_det  = stq4_dir_multihit_det;
assign dir_dcc_ex5_stp_flush      = ex5_stp_perr_flush_q | ex5_stp_multihit_flush;

// Resource Conflict between Reload and dcbt[st]ls/ldawx
assign dir_dcc_ex4_set_rel_coll = ex4_lockwatchSet_rel_coll;
assign dir_dcc_ex4_byp_restart  = congr_cl_ex4_byp_restart;

// Store Commit Restart
assign ctl_lsq_stq4_perr_reject = stq4_dir_err_val | stq5_dir_err_val_q;

// Store Commit Gate Write due to Directory Errors
assign ctl_dat_stq5_way_perr_inval = stq5_way_perr_inval_q;

// SPR Status
assign lq_xu_spr_xucr0_cslc_xuop = xucr0_cslc_xuop_q;
assign lq_xu_spr_xucr0_cslc_binv = xucr0_cslc_binv_q;

// ####################################################
// Directory Valid Bit Registers
// ####################################################

// Directory State for Way A
generate begin : congr_cl_wA
      genvar                            cclassA;
      for (cclassA=0; cclassA<numCClass; cclassA=cclassA+1) begin : congr_cl_wA
         tri_rlmreg_p #(.WIDTH(dirState), .INIT(0), .NEEDS_SRESET(1)) congr_cl_wA_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(congr_cl_act[cclassA]),
            .force_t(func_slp_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_slp_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[congr_cl_wA_offset + (dirState * cclassA):congr_cl_wA_offset + (dirState * (cclassA + 1)) - 1]),
            .scout(sov[congr_cl_wA_offset + (dirState * cclassA):congr_cl_wA_offset + (dirState * (cclassA + 1)) - 1]),
            .din(congr_cl_wA_d[cclassA]),
            .dout(congr_cl_wA_q[cclassA])
         );
      end
   end
endgenerate

// Directory State for Way B
generate begin : congr_cl_wB
      genvar                            cclassB;
      for (cclassB=0; cclassB<numCClass; cclassB=cclassB+1) begin : congr_cl_wB
         tri_rlmreg_p #(.WIDTH(dirState), .INIT(0), .NEEDS_SRESET(1)) congr_cl_wB_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(congr_cl_act[cclassB]),
            .force_t(func_slp_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_slp_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[congr_cl_wB_offset + (dirState * cclassB):congr_cl_wB_offset + (dirState * (cclassB + 1)) - 1]),
            .scout(sov[congr_cl_wB_offset + (dirState * cclassB):congr_cl_wB_offset + (dirState * (cclassB + 1)) - 1]),
            .din(congr_cl_wB_d[cclassB]),
            .dout(congr_cl_wB_q[cclassB])
         );
      end
   end
endgenerate

// Directory State for Way C
generate begin : congr_cl_wC
      genvar                            cclassC;
      for (cclassC=0; cclassC<numCClass; cclassC=cclassC+1) begin : congr_cl_wC
         tri_rlmreg_p #(.WIDTH(dirState), .INIT(0), .NEEDS_SRESET(1)) congr_cl_wC_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(congr_cl_act[cclassC]),
            .force_t(func_slp_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_slp_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[congr_cl_wC_offset + (dirState * cclassC):congr_cl_wC_offset + (dirState * (cclassC + 1)) - 1]),
            .scout(sov[congr_cl_wC_offset + (dirState * cclassC):congr_cl_wC_offset + (dirState * (cclassC + 1)) - 1]),
            .din(congr_cl_wC_d[cclassC]),
            .dout(congr_cl_wC_q[cclassC])
         );
      end
   end
endgenerate

// Directory State for Way D
generate begin : congr_cl_wD
      genvar                            cclassD;
      for (cclassD=0; cclassD<numCClass; cclassD=cclassD+1) begin : congr_cl_wD
         tri_rlmreg_p #(.WIDTH(dirState), .INIT(0), .NEEDS_SRESET(1)) congr_cl_wD_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(congr_cl_act[cclassD]),
            .force_t(func_slp_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_slp_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[congr_cl_wD_offset + (dirState * cclassD):congr_cl_wD_offset + (dirState * (cclassD + 1)) - 1]),
            .scout(sov[congr_cl_wD_offset + (dirState * cclassD):congr_cl_wD_offset + (dirState * (cclassD + 1)) - 1]),
            .din(congr_cl_wD_d[cclassD]),
            .dout(congr_cl_wD_q[cclassD])
         );
      end
   end
endgenerate

// Directory State for Way E
generate begin : congr_cl_wE
      genvar                            cclassE;
      for (cclassE=0; cclassE<numCClass; cclassE=cclassE+1) begin : congr_cl_wE
         tri_rlmreg_p #(.WIDTH(dirState), .INIT(0), .NEEDS_SRESET(1)) congr_cl_wE_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(congr_cl_act[cclassE]),
            .force_t(func_slp_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_slp_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[congr_cl_wE_offset + (dirState * cclassE):congr_cl_wE_offset + (dirState * (cclassE + 1)) - 1]),
            .scout(sov[congr_cl_wE_offset + (dirState * cclassE):congr_cl_wE_offset + (dirState * (cclassE + 1)) - 1]),
            .din(congr_cl_wE_d[cclassE]),
            .dout(congr_cl_wE_q[cclassE])
         );
      end
   end
endgenerate

// Directory State for Way F
generate begin : congr_cl_wF
      genvar                            cclassF;
      for (cclassF=0; cclassF<numCClass; cclassF=cclassF+1) begin : congr_cl_wF
         tri_rlmreg_p #(.WIDTH(dirState), .INIT(0), .NEEDS_SRESET(1)) congr_cl_wF_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(congr_cl_act[cclassF]),
            .force_t(func_slp_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_slp_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[congr_cl_wF_offset + (dirState * cclassF):congr_cl_wF_offset + (dirState * (cclassF + 1)) - 1]),
            .scout(sov[congr_cl_wF_offset + (dirState * cclassF):congr_cl_wF_offset + (dirState * (cclassF + 1)) - 1]),
            .din(congr_cl_wF_d[cclassF]),
            .dout(congr_cl_wF_q[cclassF])
         );
      end
   end
endgenerate

// Directory State for Way G
generate begin : congr_cl_wG
      genvar                            cclassG;
      for (cclassG=0; cclassG<numCClass; cclassG=cclassG+1) begin : congr_cl_wG
         tri_rlmreg_p #(.WIDTH(dirState), .INIT(0), .NEEDS_SRESET(1)) congr_cl_wG_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(congr_cl_act[cclassG]),
            .force_t(func_slp_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_slp_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[congr_cl_wG_offset + (dirState * cclassG):congr_cl_wG_offset + (dirState * (cclassG + 1)) - 1]),
            .scout(sov[congr_cl_wG_offset + (dirState * cclassG):congr_cl_wG_offset + (dirState * (cclassG + 1)) - 1]),
            .din(congr_cl_wG_d[cclassG]),
            .dout(congr_cl_wG_q[cclassG])
         );
      end
   end
endgenerate

// Directory State for Way H
generate begin : congr_cl_wH
      genvar                            cclassH;
      for (cclassH=0; cclassH<numCClass; cclassH=cclassH+1) begin : congr_cl_wH
         tri_rlmreg_p #(.WIDTH(dirState), .INIT(0), .NEEDS_SRESET(1)) congr_cl_wH_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(congr_cl_act[cclassH]),
            .force_t(func_slp_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_slp_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[congr_cl_wH_offset + (dirState * cclassH):congr_cl_wH_offset + (dirState * (cclassH + 1)) - 1]),
            .scout(sov[congr_cl_wH_offset + (dirState * cclassH):congr_cl_wH_offset + (dirState * (cclassH + 1)) - 1]),
            .din(congr_cl_wH_d[cclassH]),
            .dout(congr_cl_wH_q[cclassH])
         );
      end
   end
endgenerate

tri_rlmreg_p #(.WIDTH(numCClass), .INIT(0), .NEEDS_SRESET(1)) p0_congr_cl_act_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv5_ex5_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[p0_congr_cl_act_offset:p0_congr_cl_act_offset + numCClass - 1]),
   .scout(sov[p0_congr_cl_act_offset:p0_congr_cl_act_offset + numCClass - 1]),
   .din(p0_congr_cl_act_d),
   .dout(p0_congr_cl_act_q)
);

tri_rlmreg_p #(.WIDTH(numCClass), .INIT(0), .NEEDS_SRESET(1)) p1_congr_cl_act_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq4_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[p1_congr_cl_act_offset:p1_congr_cl_act_offset + numCClass - 1]),
   .scout(sov[p1_congr_cl_act_offset:p1_congr_cl_act_offset + numCClass - 1]),
   .din(p1_congr_cl_act_d),
   .dout(p1_congr_cl_act_q)
);

generate begin : ex4_way_val
      genvar                            ways0;
      for (ways0=0; ways0<numWays; ways0=ways0+1) begin : ex4_way_val
         tri_rlmreg_p #(.WIDTH(dirState), .INIT(0), .NEEDS_SRESET(1)) ex4_way_val_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(dcc_dir_binv3_ex3_stg_act),
            .force_t(func_slp_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_slp_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ex4_way_val_offset + (dirState * ways0):ex4_way_val_offset + (dirState * (ways0 + 1)) - 1]),
            .scout(sov[ex4_way_val_offset + (dirState * ways0):ex4_way_val_offset + (dirState * (ways0 + 1)) - 1]),
            .din(ex4_way_val_d[ways0]),
            .dout(ex4_way_val_q[ways0])
         );
      end
   end
endgenerate

generate begin : ex5_way_val
      genvar                            ways1;
      for (ways1=0; ways1<numWays; ways1=ways1+1) begin : ex5_way_val
         tri_regk #(.WIDTH(dirState), .INIT(0), .NEEDS_SRESET(1)) ex5_way_val_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(dcc_dir_binv4_ex4_stg_act),
            .force_t(func_slp_nsl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_slp_nsl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ex5_way_val_offset + (dirState * ways1):ex5_way_val_offset + (dirState * (ways1 + 1)) - 1]),
            .scout(sov[ex5_way_val_offset + (dirState * ways1):ex5_way_val_offset + (dirState * (ways1 + 1)) - 1]),
            .din(ex5_way_val_d[ways1]),
            .dout(ex5_way_val_q[ways1])
         );
      end
   end
endgenerate

tri_regk #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) ex5_clr_lck_way_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv4_ex4_stg_act),
   .force_t(func_slp_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_clr_lck_way_offset:ex5_clr_lck_way_offset + numWays - 1]),
   .scout(sov[ex5_clr_lck_way_offset:ex5_clr_lck_way_offset + numWays - 1]),
   .din(ex5_clr_lck_way_d),
   .dout(ex5_clr_lck_way_q)
);

tri_regk #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) ex5_way_upd_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_way_upd_offset:ex5_way_upd_offset + numWays - 1]),
   .scout(sov[ex5_way_upd_offset:ex5_way_upd_offset + numWays - 1]),
   .din(ex5_way_upd_d),
   .dout(ex5_way_upd_q)
);

tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) ex6_way_upd_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_way_upd_offset:ex6_way_upd_offset + numWays - 1]),
   .scout(sov[ex6_way_upd_offset:ex6_way_upd_offset + numWays - 1]),
   .din(ex6_way_upd_d),
   .dout(ex6_way_upd_q)
);

tri_regk #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) ex7_way_upd_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex7_way_upd_offset:ex7_way_upd_offset + numWays - 1]),
   .scout(sov[ex7_way_upd_offset:ex7_way_upd_offset + numWays - 1]),
   .din(ex7_way_upd_d),
   .dout(ex7_way_upd_q)
);

generate begin : ex5_dir_way
      genvar                            ways2;
      for (ways2=0; ways2<numWays; ways2=ways2+1) begin : ex5_dir_way
         tri_regk #(.WIDTH(dirState), .INIT(0), .NEEDS_SRESET(1)) ex5_dir_way_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(dcc_dir_binv4_ex4_stg_act),
            .force_t(func_slp_nsl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_slp_nsl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ex5_dir_way_offset + (dirState * ways2):ex5_dir_way_offset + (dirState * (ways2 + 1)) - 1]),
            .scout(sov[ex5_dir_way_offset + (dirState * ways2):ex5_dir_way_offset + (dirState * (ways2 + 1)) - 1]),
            .din(ex5_dir_way_d[ways2]),
            .dout(ex5_dir_way_q[ways2])
         );
      end
   end
endgenerate

generate begin : ex6_dir_way
      genvar                            ways3;
      for (ways3=0; ways3<numWays; ways3=ways3+1) begin : ex6_dir_way
         tri_rlmreg_p #(.WIDTH(2 + `THREADS), .INIT(0), .NEEDS_SRESET(1)) ex6_dir_way_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(dcc_dir_binv5_ex5_stg_act),
            .force_t(func_slp_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_slp_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ex6_dir_way_offset + (dirState * ways3):ex6_dir_way_offset + (dirState * (ways3 + 1)) - 1]),
            .scout(sov[ex6_dir_way_offset + (dirState * ways3):ex6_dir_way_offset + (dirState * (ways3 + 1)) - 1]),
            .din(ex6_dir_way_d[ways3]),
            .dout(ex6_dir_way_q[ways3])
         );
      end
   end
endgenerate

generate begin : ex7_dir_way
      genvar                            ways4;
      for (ways4=0; ways4<numWays; ways4=ways4+1) begin : ex7_dir_way
         tri_regk #(.WIDTH(dirState-2), .INIT(0), .NEEDS_SRESET(1)) ex7_dir_way_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(dcc_dir_binv6_ex6_stg_act),
            .force_t(func_slp_nsl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_slp_nsl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ex7_dir_way_offset + ((dirState-2) * ways4):ex7_dir_way_offset + ((dirState-2) * (ways4 + 1)) - 1]),
            .scout(sov[ex7_dir_way_offset + ((dirState-2) * ways4):ex7_dir_way_offset + ((dirState-2) * (ways4 + 1)) - 1]),
            .din(ex7_dir_way_d[ways4]),
            .dout(ex7_dir_way_q[ways4])
         );
      end
   end
endgenerate

generate begin : stq3_way_val
      genvar                            ways5;
      for (ways5=0; ways5<numWays; ways5=ways5+1) begin : stq3_way_val
         tri_regk #(.WIDTH(dirState), .INIT(0), .NEEDS_SRESET(1)) stq3_way_val_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(dcc_dir_stq2_stg_act),
            .force_t(func_nsl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_nsl_thold_0_b),
            .sg(sg_0),
            .scin(siv[stq3_way_val_offset + (dirState * ways5):stq3_way_val_offset + (dirState * (ways5 + 1)) - 1]),
            .scout(sov[stq3_way_val_offset + (dirState * ways5):stq3_way_val_offset + (dirState * (ways5 + 1)) - 1]),
            .din(stq3_way_val_d[ways5]),
            .dout(stq3_way_val_q[ways5])
         );
      end
   end
endgenerate

generate begin : stq4_way_val
      genvar                            ways6;
      for (ways6=0; ways6<numWays; ways6=ways6+1) begin : stq4_way_val
         tri_rlmreg_p #(.WIDTH(dirState-2), .INIT(0), .NEEDS_SRESET(1)) stq4_way_val_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(dcc_dir_stq3_stg_act),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[stq4_way_val_offset + ((dirState-2) * ways6):stq4_way_val_offset + ((dirState-2) * (ways6 + 1)) - 1]),
            .scout(sov[stq4_way_val_offset + ((dirState-2) * ways6):stq4_way_val_offset + ((dirState-2) * (ways6 + 1)) - 1]),
            .din(stq4_way_val_d[ways6]),
            .dout(stq4_way_val_q[ways6])
         );
      end
   end
endgenerate

generate begin : stq4_dir_way
      genvar                            ways7;
      for (ways7=0; ways7<numWays; ways7=ways7+1) begin : stq4_dir_way
         tri_rlmreg_p #(.WIDTH(dirState), .INIT(0), .NEEDS_SRESET(1)) stq4_dir_way_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(dcc_dir_stq3_stg_act),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[stq4_dir_way_offset + (dirState * ways7):stq4_dir_way_offset + (dirState * (ways7 + 1)) - 1]),
            .scout(sov[stq4_dir_way_offset + (dirState * ways7):stq4_dir_way_offset + (dirState * (ways7 + 1)) - 1]),
            .din(stq4_dir_way_d[ways7]),
            .dout(stq4_dir_way_q[ways7])
         );
      end
   end
endgenerate

generate begin : stq5_dir_way
      genvar                            ways8;
      for (ways8=0; ways8<numWays; ways8=ways8+1) begin : stq5_dir_way
         tri_regk #(.WIDTH(dirState), .INIT(0), .NEEDS_SRESET(1)) stq5_dir_way_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(dcc_dir_stq4_stg_act),
            .force_t(func_nsl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_nsl_thold_0_b),
            .sg(sg_0),
            .scin(siv[stq5_dir_way_offset + (dirState * ways8):stq5_dir_way_offset + (dirState * (ways8 + 1)) - 1]),
            .scout(sov[stq5_dir_way_offset + (dirState * ways8):stq5_dir_way_offset + (dirState * (ways8 + 1)) - 1]),
            .din(stq5_dir_way_d[ways8]),
            .dout(stq5_dir_way_q[ways8])
         );
      end
   end
endgenerate

tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq3_ex6_ldp_err_reg(
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
   .scin(siv[stq3_ex6_ldp_err_offset:stq3_ex6_ldp_err_offset + numWays - 1]),
   .scout(sov[stq3_ex6_ldp_err_offset:stq3_ex6_ldp_err_offset + numWays - 1]),
   .din(stq3_ex6_ldp_err_d),
   .dout(stq3_ex6_ldp_err_q)
);

tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq4_ex7_ldp_err_reg(
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
   .scin(siv[stq4_ex7_ldp_err_offset:stq4_ex7_ldp_err_offset + numWays - 1]),
   .scout(sov[stq4_ex7_ldp_err_offset:stq4_ex7_ldp_err_offset + numWays - 1]),
   .din(stq4_ex7_ldp_err_d),
   .dout(stq4_ex7_ldp_err_q)
);

tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq4_ex6_ldp_err_reg(
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
   .scin(siv[stq4_ex6_ldp_err_offset:stq4_ex6_ldp_err_offset + numWays - 1]),
   .scout(sov[stq4_ex6_ldp_err_offset:stq4_ex6_ldp_err_offset + numWays - 1]),
   .din(stq4_ex6_ldp_err_d),
   .dout(stq4_ex6_ldp_err_q)
);

tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq3_stq5_stp_err_reg(
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
   .scin(siv[stq3_stq5_stp_err_offset:stq3_stq5_stp_err_offset + numWays - 1]),
   .scout(sov[stq3_stq5_stp_err_offset:stq3_stq5_stp_err_offset + numWays - 1]),
   .din(stq3_stq5_stp_err_d),
   .dout(stq3_stq5_stp_err_q)
);

tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq4_stq6_stp_err_reg(
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
   .scin(siv[stq4_stq6_stp_err_offset:stq4_stq6_stp_err_offset + numWays - 1]),
   .scout(sov[stq4_stq6_stp_err_offset:stq4_stq6_stp_err_offset + numWays - 1]),
   .din(stq4_stq6_stp_err_d),
   .dout(stq4_stq6_stp_err_q)
);

tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq4_stq5_stp_err_reg(
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
   .scin(siv[stq4_stq5_stp_err_offset:stq4_stq5_stp_err_offset + numWays - 1]),
   .scout(sov[stq4_stq5_stp_err_offset:stq4_stq5_stp_err_offset + numWays - 1]),
   .din(stq4_stq5_stp_err_d),
   .dout(stq4_stq5_stp_err_q)
);

tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq4_clr_lck_way_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq3_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_clr_lck_way_offset:stq4_clr_lck_way_offset + numWays - 1]),
   .scout(sov[stq4_clr_lck_way_offset:stq4_clr_lck_way_offset + numWays - 1]),
   .din(stq4_clr_lck_way_d),
   .dout(stq4_clr_lck_way_q)
);


tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq4_way_upd_reg(
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
   .scin(siv[stq4_way_upd_offset:stq4_way_upd_offset + numWays - 1]),
   .scout(sov[stq4_way_upd_offset:stq4_way_upd_offset + numWays - 1]),
   .din(stq4_way_upd_d),
   .dout(stq4_way_upd_q)
);


tri_regk #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq5_way_upd_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq5_way_upd_offset:stq5_way_upd_offset + numWays - 1]),
   .scout(sov[stq5_way_upd_offset:stq5_way_upd_offset + numWays - 1]),
   .din(stq5_way_upd_d),
   .dout(stq5_way_upd_q)
);


tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq6_way_upd_reg(
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
   .scin(siv[stq6_way_upd_offset:stq6_way_upd_offset + numWays - 1]),
   .scout(sov[stq6_way_upd_offset:stq6_way_upd_offset + numWays - 1]),
   .din(stq6_way_upd_d),
   .dout(stq6_way_upd_q)
);


tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq7_way_upd_reg(
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
   .scin(siv[stq7_way_upd_offset:stq7_way_upd_offset + numWays - 1]),
   .scout(sov[stq7_way_upd_offset:stq7_way_upd_offset + numWays - 1]),
   .din(stq7_way_upd_d),
   .dout(stq7_way_upd_q)
);


tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq4_rel_way_clr_reg(
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
   .scin(siv[stq4_rel_way_clr_offset:stq4_rel_way_clr_offset + numWays - 1]),
   .scout(sov[stq4_rel_way_clr_offset:stq4_rel_way_clr_offset + numWays - 1]),
   .din(stq4_rel_way_clr_d),
   .dout(stq4_rel_way_clr_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_cache_acc_reg(
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
   .scin(siv[ex4_cache_acc_offset]),
   .scout(sov[ex4_cache_acc_offset]),
   .din(ex4_cache_acc_d),
   .dout(ex4_cache_acc_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_cache_acc_reg(
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
   .scin(siv[ex5_cache_acc_offset]),
   .scout(sov[ex5_cache_acc_offset]),
   .din(ex5_cache_acc_d),
   .dout(ex5_cache_acc_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_mhit_cacc_reg(
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
   .scin(siv[ex5_mhit_cacc_offset]),
   .scout(sov[ex5_mhit_cacc_offset]),
   .din(ex5_mhit_cacc_d),
   .dout(ex5_mhit_cacc_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_pfetch_val_reg(
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
   .scin(siv[ex4_pfetch_val_offset]),
   .scout(sov[ex4_pfetch_val_offset]),
   .din(ex4_pfetch_val_d),
   .dout(ex4_pfetch_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_binv_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_binv_val_offset]),
   .scout(sov[ex3_binv_val_offset]),
   .din(ex3_binv_val_d),
   .dout(ex3_binv_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_binv_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_binv_val_offset]),
   .scout(sov[ex4_binv_val_offset]),
   .din(ex4_binv_val_d),
   .dout(ex4_binv_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_binv_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_binv_val_offset]),
   .scout(sov[ex5_binv_val_offset]),
   .din(ex5_binv_val_d),
   .dout(ex5_binv_val_q)
);

tri_regk #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_ex2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_thrd_id_offset:ex3_thrd_id_offset + `THREADS - 1]),
   .scout(sov[ex3_thrd_id_offset:ex3_thrd_id_offset + `THREADS - 1]),
   .din(ex3_thrd_id_d),
   .dout(ex3_thrd_id_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_ex3_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_thrd_id_offset:ex4_thrd_id_offset + `THREADS - 1]),
   .scout(sov[ex4_thrd_id_offset:ex4_thrd_id_offset + `THREADS - 1]),
   .din(ex4_thrd_id_d),
   .dout(ex4_thrd_id_q)
);

tri_regk #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_ex4_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_thrd_id_offset:ex5_thrd_id_offset + `THREADS - 1]),
   .scout(sov[ex5_thrd_id_offset:ex5_thrd_id_offset + `THREADS - 1]),
   .din(ex5_thrd_id_d),
   .dout(ex5_thrd_id_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_lock_set_reg(
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
   .scin(siv[ex4_lock_set_offset]),
   .scout(sov[ex4_lock_set_offset]),
   .din(ex4_lock_set_d),
   .dout(ex4_lock_set_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_lock_set_reg(
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
   .scin(siv[ex5_lock_set_offset]),
   .scout(sov[ex5_lock_set_offset]),
   .din(ex5_lock_set_d),
   .dout(ex5_lock_set_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_watch_set_reg(
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
   .scin(siv[ex4_watch_set_offset]),
   .scout(sov[ex4_watch_set_offset]),
   .din(ex4_watch_set_d),
   .dout(ex4_watch_set_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_watch_set_reg(
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
   .scin(siv[ex5_watch_set_offset]),
   .scout(sov[ex5_watch_set_offset]),
   .din(ex5_watch_set_d),
   .dout(ex5_watch_set_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_watch_set_reg(
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
   .scin(siv[ex6_watch_set_offset]),
   .scout(sov[ex6_watch_set_offset]),
   .din(ex6_watch_set_d),
   .dout(ex6_watch_set_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_larx_val_reg(
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
   .scin(siv[ex4_larx_val_offset]),
   .scout(sov[ex4_larx_val_offset]),
   .din(ex4_larx_val_d),
   .dout(ex4_larx_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex7_watch_set_inval_reg(
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
   .scin(siv[ex7_watch_set_inval_offset]),
   .scout(sov[ex7_watch_set_inval_offset]),
   .din(ex7_watch_set_inval_d),
   .dout(ex7_watch_set_inval_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_lose_watch_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv4_ex4_stg_act),
   .force_t(func_slp_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_lose_watch_offset]),
   .scout(sov[ex5_lose_watch_offset]),
   .din(ex5_lose_watch_d),
   .dout(ex5_lose_watch_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_xuop_upd_val_reg(
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
   .scin(siv[ex4_xuop_upd_val_offset]),
   .scout(sov[ex4_xuop_upd_val_offset]),
   .din(ex4_xuop_upd_val_d),
   .dout(ex4_xuop_upd_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_xuop_upd_val_reg(
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
   .scin(siv[ex5_xuop_upd_val_offset]),
   .scout(sov[ex5_xuop_upd_val_offset]),
   .din(ex5_xuop_upd_val_d),
   .dout(ex5_xuop_upd_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) binv5_ex5_dir_val_reg(
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
   .scin(siv[binv5_ex5_dir_val_offset]),
   .scout(sov[binv5_ex5_dir_val_offset]),
   .din(binv5_ex5_dir_val_d),
   .dout(binv5_ex5_dir_val_q)
);

tri_regk #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) ex5_way_hit_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv4_ex4_stg_act),
   .force_t(func_slp_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_way_hit_offset:ex5_way_hit_offset + numWays - 1]),
   .scout(sov[ex5_way_hit_offset:ex5_way_hit_offset + numWays - 1]),
   .din(ex5_way_hit_d),
   .dout(ex5_way_hit_q)
);

tri_regk #(.WIDTH((lwrCClassBit-uprCClassBit+1)), .INIT(0), .NEEDS_SRESET(1)) ex3_congr_cl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv2_ex2_stg_act),
   .force_t(func_slp_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_congr_cl_offset:ex3_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .scout(sov[ex3_congr_cl_offset:ex3_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .din(ex3_congr_cl_d),
   .dout(ex3_congr_cl_q)
);

tri_rlmreg_p #(.WIDTH((lwrCClassBit-uprCClassBit+1)), .INIT(0), .NEEDS_SRESET(1)) ex4_congr_cl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv3_ex3_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_congr_cl_offset:ex4_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .scout(sov[ex4_congr_cl_offset:ex4_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .din(ex4_congr_cl_d),
   .dout(ex4_congr_cl_q)
);

tri_regk #(.WIDTH((lwrCClassBit-uprCClassBit+1)), .INIT(0), .NEEDS_SRESET(1)) ex5_congr_cl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv4_ex4_stg_act),
   .force_t(func_slp_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_congr_cl_offset:ex5_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .scout(sov[ex5_congr_cl_offset:ex5_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .din(ex5_congr_cl_d),
   .dout(ex5_congr_cl_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_cr_watch_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv4_ex4_stg_act),
   .force_t(func_slp_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_cr_watch_offset]),
   .scout(sov[ex5_cr_watch_offset]),
   .din(ex5_cr_watch_d),
   .dout(ex5_cr_watch_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex3_ex4_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv2_ex2_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_ex3_ex4_cmp_offset]),
   .scout(sov[congr_cl_ex3_ex4_cmp_offset]),
   .din(congr_cl_ex3_ex4_cmp_d),
   .dout(congr_cl_ex3_ex4_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex3_ex5_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv2_ex2_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_ex3_ex5_cmp_offset]),
   .scout(sov[congr_cl_ex3_ex5_cmp_offset]),
   .din(congr_cl_ex3_ex5_cmp_d),
   .dout(congr_cl_ex3_ex5_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex3_ex6_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv2_ex2_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_ex3_ex6_cmp_offset]),
   .scout(sov[congr_cl_ex3_ex6_cmp_offset]),
   .din(congr_cl_ex3_ex6_cmp_d),
   .dout(congr_cl_ex3_ex6_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex3_stq4_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv2_ex2_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_ex3_stq4_cmp_offset]),
   .scout(sov[congr_cl_ex3_stq4_cmp_offset]),
   .din(congr_cl_ex3_stq4_cmp_d),
   .dout(congr_cl_ex3_stq4_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex3_stq5_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv2_ex2_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_ex3_stq5_cmp_offset]),
   .scout(sov[congr_cl_ex3_stq5_cmp_offset]),
   .din(congr_cl_ex3_stq5_cmp_d),
   .dout(congr_cl_ex3_stq5_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex4_ex5_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv3_ex3_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_ex4_ex5_cmp_offset]),
   .scout(sov[congr_cl_ex4_ex5_cmp_offset]),
   .din(congr_cl_ex4_ex5_cmp_d),
   .dout(congr_cl_ex4_ex5_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex4_ex6_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv3_ex3_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_ex4_ex6_cmp_offset]),
   .scout(sov[congr_cl_ex4_ex6_cmp_offset]),
   .din(congr_cl_ex4_ex6_cmp_d),
   .dout(congr_cl_ex4_ex6_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex5_ex6_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv4_ex4_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_ex5_ex6_cmp_offset]),
   .scout(sov[congr_cl_ex5_ex6_cmp_offset]),
   .din(congr_cl_ex5_ex6_cmp_d),
   .dout(congr_cl_ex5_ex6_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex5_ex7_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv4_ex4_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_ex5_ex7_cmp_offset]),
   .scout(sov[congr_cl_ex5_ex7_cmp_offset]),
   .din(congr_cl_ex5_ex7_cmp_d),
   .dout(congr_cl_ex5_ex7_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex5_stq5_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv4_ex4_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_ex5_stq5_cmp_offset]),
   .scout(sov[congr_cl_ex5_stq5_cmp_offset]),
   .din(congr_cl_ex5_stq5_cmp_d),
   .dout(congr_cl_ex5_stq5_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex5_stq6_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv4_ex4_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_ex5_stq6_cmp_offset]),
   .scout(sov[congr_cl_ex5_stq6_cmp_offset]),
   .din(congr_cl_ex5_stq6_cmp_d),
   .dout(congr_cl_ex5_stq6_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex5_stq7_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv4_ex4_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_ex5_stq7_cmp_offset]),
   .scout(sov[congr_cl_ex5_stq7_cmp_offset]),
   .din(congr_cl_ex5_stq7_cmp_d),
   .dout(congr_cl_ex5_stq7_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex4_ex6_rest_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv3_ex3_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_ex4_ex6_rest_offset]),
   .scout(sov[congr_cl_ex4_ex6_rest_offset]),
   .din(congr_cl_ex4_ex6_rest_d),
   .dout(congr_cl_ex4_ex6_rest_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_cClass_lock_set_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv4_ex4_stg_act),
   .force_t(func_slp_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_cClass_lock_set_offset]),
   .scout(sov[ex5_cClass_lock_set_offset]),
   .din(ex5_cClass_lock_set_d),
   .dout(ex5_cClass_lock_set_q)
);

tri_regk #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_cClass_thrd_watch_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv4_ex4_stg_act),
   .force_t(func_slp_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_cClass_thrd_watch_offset:ex5_cClass_thrd_watch_offset + `THREADS - 1]),
   .scout(sov[ex5_cClass_thrd_watch_offset:ex5_cClass_thrd_watch_offset + `THREADS - 1]),
   .din(ex5_cClass_thrd_watch_d),
   .dout(ex5_cClass_thrd_watch_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_dir_multihit_val_b_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_dir_multihit_val_b_offset]),
   .scout(sov[ex5_dir_multihit_val_b_offset]),
   .din(ex5_dir_multihit_val_b_d),
   .dout(ex5_dir_multihit_val_b_q)
);

tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex5_err_det_way_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_err_det_way_offset:ex5_err_det_way_offset + 8 - 1]),
   .scout(sov[ex5_err_det_way_offset:ex5_err_det_way_offset + 8 - 1]),
   .din(ex5_err_det_way_d),
   .dout(ex5_err_det_way_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_perr_lock_lost_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_perr_lock_lost_offset]),
   .scout(sov[ex5_perr_lock_lost_offset]),
   .din(ex5_perr_lock_lost_d),
   .dout(ex5_perr_lock_lost_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_perr_watchlost_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_perr_watchlost_offset:ex5_perr_watchlost_offset + `THREADS - 1]),
   .scout(sov[ex5_perr_watchlost_offset:ex5_perr_watchlost_offset + `THREADS - 1]),
   .din(ex5_perr_watchlost_d),
   .dout(ex5_perr_watchlost_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_dir_perr_det_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_dir_perr_det_offset]),
   .scout(sov[ex5_dir_perr_det_offset]),
   .din(ex5_dir_perr_det_d),
   .dout(ex5_dir_perr_det_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_dc_perr_det_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_dc_perr_det_offset]),
   .scout(sov[ex5_dc_perr_det_offset]),
   .din(ex5_dc_perr_det_d),
   .dout(ex5_dc_perr_det_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_dir_perr_flush_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_dir_perr_flush_offset]),
   .scout(sov[ex5_dir_perr_flush_offset]),
   .din(ex5_dir_perr_flush_d),
   .dout(ex5_dir_perr_flush_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_dc_perr_flush_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_dc_perr_flush_offset]),
   .scout(sov[ex5_dc_perr_flush_offset]),
   .din(ex5_dc_perr_flush_d),
   .dout(ex5_dc_perr_flush_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_way_perr_det_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_way_perr_det_offset]),
   .scout(sov[ex5_way_perr_det_offset]),
   .din(ex5_way_perr_det_d),
   .dout(ex5_way_perr_det_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_stq2_congr_cl_m_reg(
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
   .scin(siv[ex4_stq2_congr_cl_m_offset]),
   .scout(sov[ex4_stq2_congr_cl_m_offset]),
   .din(ex4_stq2_congr_cl_m_d),
   .dout(ex4_stq2_congr_cl_m_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_stq3_set_rel_coll_reg(
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
   .scin(siv[ex4_stq3_set_rel_coll_offset]),
   .scout(sov[ex4_stq3_set_rel_coll_offset]),
   .din(ex4_stq3_set_rel_coll_d),
   .dout(ex4_stq3_set_rel_coll_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_stq4_set_rel_coll_reg(
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
   .scin(siv[ex4_stq4_set_rel_coll_offset]),
   .scout(sov[ex4_stq4_set_rel_coll_offset]),
   .din(ex4_stq4_set_rel_coll_d),
   .dout(ex4_stq4_set_rel_coll_q)
);


tri_rlmreg_p #(.WIDTH((dirState-1)), .INIT(0), .NEEDS_SRESET(1)) binv6_ex6_dir_data_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv5_ex5_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[binv6_ex6_dir_data_offset:binv6_ex6_dir_data_offset + (dirState-1) - 1]),
   .scout(sov[binv6_ex6_dir_data_offset:binv6_ex6_dir_data_offset + (dirState-1) - 1]),
   .din(binv6_ex6_dir_data_d),
   .dout(binv6_ex6_dir_data_q)
);


tri_rlmreg_p #(.WIDTH((dirState-1)), .INIT(0), .NEEDS_SRESET(1)) binv7_ex7_dir_data_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_binv6_ex6_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[binv7_ex7_dir_data_offset:binv7_ex7_dir_data_offset + (dirState-1) - 1]),
   .scout(sov[binv7_ex7_dir_data_offset:binv7_ex7_dir_data_offset + (dirState-1) - 1]),
   .din(binv7_ex7_dir_data_d),
   .dout(binv7_ex7_dir_data_q)
);


tri_rlmreg_p #(.WIDTH((dirState-1)), .INIT(0), .NEEDS_SRESET(1)) stq6_dir_data_reg(
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
   .scin(siv[stq6_dir_data_offset:stq6_dir_data_offset + (dirState-1) - 1]),
   .scout(sov[stq6_dir_data_offset:stq6_dir_data_offset + (dirState-1) - 1]),
   .din(stq6_dir_data_d),
   .dout(stq6_dir_data_q)
);


tri_rlmreg_p #(.WIDTH((dirState-1)), .INIT(0), .NEEDS_SRESET(1)) stq7_dir_data_reg(
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
   .scin(siv[stq7_dir_data_offset:stq7_dir_data_offset + (dirState-1) - 1]),
   .scout(sov[stq7_dir_data_offset:stq7_dir_data_offset + (dirState-1) - 1]),
   .din(stq7_dir_data_d),
   .dout(stq7_dir_data_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_ci_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_ci_offset]),
   .scout(sov[stq2_ci_offset]),
   .din(stq2_ci_d),
   .dout(stq2_ci_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_cen_acc_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_cen_acc_offset]),
   .scout(sov[stq2_cen_acc_offset]),
   .din(stq2_cen_acc_d),
   .dout(stq2_cen_acc_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_val_reg(
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
   .scin(siv[stq2_val_offset]),
   .scout(sov[stq2_val_offset]),
   .din(stq2_val_d),
   .dout(stq2_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq3_val_reg(
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
   .scin(siv[stq3_val_offset]),
   .scout(sov[stq3_val_offset]),
   .din(stq3_val_d),
   .dout(stq3_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_val_reg(
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
   .scin(siv[stq4_val_offset]),
   .scout(sov[stq4_val_offset]),
   .din(stq4_val_d),
   .dout(stq4_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_dci_val_reg(
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
   .scin(siv[stq2_dci_val_offset]),
   .scout(sov[stq2_dci_val_offset]),
   .din(stq2_dci_val_d),
   .dout(stq2_dci_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq3_dci_val_reg(
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
   .scin(siv[stq3_dci_val_offset]),
   .scout(sov[stq3_dci_val_offset]),
   .din(stq3_dci_val_d),
   .dout(stq3_dci_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_dci_val_reg(
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
   .scin(siv[stq4_dci_val_offset]),
   .scout(sov[stq4_dci_val_offset]),
   .din(stq4_dci_val_d),
   .dout(stq4_dci_val_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stq2_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_thrd_id_offset:stq2_thrd_id_offset + `THREADS - 1]),
   .scout(sov[stq2_thrd_id_offset:stq2_thrd_id_offset + `THREADS - 1]),
   .din(stq2_thrd_id_d),
   .dout(stq2_thrd_id_q)
);


tri_regk #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stq3_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_thrd_id_offset:stq3_thrd_id_offset + `THREADS - 1]),
   .scout(sov[stq3_thrd_id_offset:stq3_thrd_id_offset + `THREADS - 1]),
   .din(stq3_thrd_id_d),
   .dout(stq3_thrd_id_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stq4_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq3_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_thrd_id_offset:stq4_thrd_id_offset + `THREADS - 1]),
   .scout(sov[stq4_thrd_id_offset:stq4_thrd_id_offset + `THREADS - 1]),
   .din(stq4_thrd_id_d),
   .dout(stq4_thrd_id_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) rel2_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel2_thrd_id_offset:rel2_thrd_id_offset + `THREADS - 1]),
   .scout(sov[rel2_thrd_id_offset:rel2_thrd_id_offset + `THREADS - 1]),
   .din(rel2_thrd_id_d),
   .dout(rel2_thrd_id_q)
);


tri_regk #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) rel3_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel3_thrd_id_offset:rel3_thrd_id_offset + `THREADS - 1]),
   .scout(sov[rel3_thrd_id_offset:rel3_thrd_id_offset + `THREADS - 1]),
   .din(rel3_thrd_id_d),
   .dout(rel3_thrd_id_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_lock_clr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_lock_clr_offset]),
   .scout(sov[stq2_lock_clr_offset]),
   .din(stq2_lock_clr_d),
   .dout(stq2_lock_clr_q)
);


tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq3_lock_clr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_lock_clr_offset]),
   .scout(sov[stq3_lock_clr_offset]),
   .din(stq3_lock_clr_d),
   .dout(stq3_lock_clr_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_watch_clr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_watch_clr_offset]),
   .scout(sov[stq2_watch_clr_offset]),
   .din(stq2_watch_clr_d),
   .dout(stq2_watch_clr_q)
);


tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq3_watch_clr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_watch_clr_offset]),
   .scout(sov[stq3_watch_clr_offset]),
   .din(stq3_watch_clr_d),
   .dout(stq3_watch_clr_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_store_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_store_val_offset]),
   .scout(sov[stq2_store_val_offset]),
   .din(stq2_store_val_d),
   .dout(stq2_store_val_q)
);


tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq3_store_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_store_val_offset]),
   .scout(sov[stq3_store_val_offset]),
   .din(stq3_store_val_d),
   .dout(stq3_store_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_l_fld_b1_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_l_fld_b1_offset]),
   .scout(sov[stq2_l_fld_b1_offset]),
   .din(stq2_l_fld_b1_d),
   .dout(stq2_l_fld_b1_q)
);


tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq3_l_fld_b1_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_l_fld_b1_offset]),
   .scout(sov[stq3_l_fld_b1_offset]),
   .din(stq3_l_fld_b1_d),
   .dout(stq3_l_fld_b1_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_l_fld_b1_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq3_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_l_fld_b1_offset]),
   .scout(sov[stq4_l_fld_b1_offset]),
   .din(stq4_l_fld_b1_d),
   .dout(stq4_l_fld_b1_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_inval_op_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_inval_op_offset]),
   .scout(sov[stq2_inval_op_offset]),
   .din(stq2_inval_op_d),
   .dout(stq2_inval_op_q)
);


tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq3_inval_op_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_inval_op_offset]),
   .scout(sov[stq3_inval_op_offset]),
   .din(stq3_inval_op_d),
   .dout(stq3_inval_op_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_watch_clr_all_reg(
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
   .scin(siv[stq2_watch_clr_all_offset]),
   .scout(sov[stq2_watch_clr_all_offset]),
   .din(stq2_watch_clr_all_d),
   .dout(stq2_watch_clr_all_q)
);


tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq3_watch_clr_all_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_watch_clr_all_offset]),
   .scout(sov[stq3_watch_clr_all_offset]),
   .din(stq3_watch_clr_all_d),
   .dout(stq3_watch_clr_all_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_watch_clr_all_reg(
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
   .scin(siv[stq4_watch_clr_all_offset]),
   .scout(sov[stq4_watch_clr_all_offset]),
   .din(stq4_watch_clr_all_d),
   .dout(stq4_watch_clr_all_q)
);


tri_rlmreg_p #(.WIDTH((lwrCClassBit-uprCClassBit+1)), .INIT(0), .NEEDS_SRESET(1)) stq2_congr_cl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_congr_cl_offset:stq2_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .scout(sov[stq2_congr_cl_offset:stq2_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .din(stq2_congr_cl_d),
   .dout(stq2_congr_cl_q)
);


tri_regk #(.WIDTH((lwrCClassBit-uprCClassBit+1)), .INIT(0), .NEEDS_SRESET(1)) stq3_congr_cl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_congr_cl_offset:stq3_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .scout(sov[stq3_congr_cl_offset:stq3_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .din(stq3_congr_cl_d),
   .dout(stq3_congr_cl_q)
);


tri_rlmreg_p #(.WIDTH((lwrCClassBit-uprCClassBit+1)), .INIT(0), .NEEDS_SRESET(1)) stq4_congr_cl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq3_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_congr_cl_offset:stq4_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .scout(sov[stq4_congr_cl_offset:stq4_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .din(stq4_congr_cl_d),
   .dout(stq4_congr_cl_q)
);


tri_regk #(.WIDTH((lwrCClassBit-uprCClassBit+1)), .INIT(0), .NEEDS_SRESET(1)) stq5_congr_cl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq4_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq5_congr_cl_offset:stq5_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .scout(sov[stq5_congr_cl_offset:stq5_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .din(stq5_congr_cl_d),
   .dout(stq5_congr_cl_q)
);


tri_rlmreg_p #(.WIDTH((lwrCClassBit-uprCClassBit+1)), .INIT(0), .NEEDS_SRESET(1)) stq6_congr_cl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq5_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_congr_cl_offset:stq6_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .scout(sov[stq6_congr_cl_offset:stq6_congr_cl_offset + (lwrCClassBit-uprCClassBit+1) - 1]),
   .din(stq6_congr_cl_d),
   .dout(stq6_congr_cl_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel2_clr_stg_val_reg(
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
   .scin(siv[rel2_clr_stg_val_offset]),
   .scout(sov[rel2_clr_stg_val_offset]),
   .din(rel2_clr_stg_val_d),
   .dout(rel2_clr_stg_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel3_clr_stg_val_reg(
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
   .scin(siv[rel3_clr_stg_val_offset]),
   .scout(sov[rel3_clr_stg_val_offset]),
   .din(rel3_clr_stg_val_d),
   .dout(rel3_clr_stg_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel4_clr_stg_val_reg(
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
   .scin(siv[rel4_clr_stg_val_offset]),
   .scout(sov[rel4_clr_stg_val_offset]),
   .din(rel4_clr_stg_val_d),
   .dout(rel4_clr_stg_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel5_clr_stg_val_reg(
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
   .scin(siv[rel5_clr_stg_val_offset]),
   .scout(sov[rel5_clr_stg_val_offset]),
   .din(rel5_clr_stg_val_d),
   .dout(rel5_clr_stg_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel3_set_dir_val_reg(
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
   .scin(siv[rel3_set_dir_val_offset]),
   .scout(sov[rel3_set_dir_val_offset]),
   .din(rel3_set_dir_val_d),
   .dout(rel3_set_dir_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel4_set_dir_val_reg(
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
   .scin(siv[rel4_set_dir_val_offset]),
   .scout(sov[rel4_set_dir_val_offset]),
   .din(rel4_set_dir_val_d),
   .dout(rel4_set_dir_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel2_set_stg_val_reg(
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
   .scin(siv[rel2_set_stg_val_offset]),
   .scout(sov[rel2_set_stg_val_offset]),
   .din(rel2_set_stg_val_d),
   .dout(rel2_set_stg_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel3_set_stg_val_reg(
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
   .scin(siv[rel3_set_stg_val_offset]),
   .scout(sov[rel3_set_stg_val_offset]),
   .din(rel3_set_stg_val_d),
   .dout(rel3_set_stg_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel2_back_inv_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel2_back_inv_offset]),
   .scout(sov[rel2_back_inv_offset]),
   .din(rel2_back_inv_d),
   .dout(rel2_back_inv_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) rel3_back_inv_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel3_back_inv_offset]),
   .scout(sov[rel3_back_inv_offset]),
   .din(rel3_back_inv_d),
   .dout(rel3_back_inv_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) rel3_upd_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel3_upd_val_offset]),
   .scout(sov[rel3_upd_val_offset]),
   .din(rel3_upd_val_d),
   .dout(rel3_upd_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel2_lock_set_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel2_lock_set_offset]),
   .scout(sov[rel2_lock_set_offset]),
   .din(rel2_lock_set_d),
   .dout(rel2_lock_set_q)
);


tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) rel3_lock_set_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel3_lock_set_offset]),
   .scout(sov[rel3_lock_set_offset]),
   .din(rel3_lock_set_d),
   .dout(rel3_lock_set_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) rel3_lock_pipe_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel3_lock_pipe_offset]),
   .scout(sov[rel3_lock_pipe_offset]),
   .din(rel3_lock_pipe_d),
   .dout(rel3_lock_pipe_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel2_watch_set_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel2_watch_set_offset]),
   .scout(sov[rel2_watch_set_offset]),
   .din(rel2_watch_set_d),
   .dout(rel2_watch_set_q)
);


tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) rel3_watch_set_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel3_watch_set_offset]),
   .scout(sov[rel3_watch_set_offset]),
   .din(rel3_watch_set_d),
   .dout(rel3_watch_set_q)
);


tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) rel3_watch_pipe_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel3_watch_pipe_offset]),
   .scout(sov[rel3_watch_pipe_offset]),
   .din(rel3_watch_pipe_d),
   .dout(rel3_watch_pipe_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq3_dir_upd_val_reg(
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
   .scin(siv[stq3_dir_upd_val_offset]),
   .scout(sov[stq3_dir_upd_val_offset]),
   .din(stq3_dir_upd_val_d),
   .dout(stq3_dir_upd_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_dir_upd_val_reg(
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
   .scin(siv[stq4_dir_upd_val_offset]),
   .scout(sov[stq4_dir_upd_val_offset]),
   .din(stq4_dir_upd_val_d),
   .dout(stq4_dir_upd_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq3_rel3_val_reg(
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
   .scin(siv[stq3_rel3_val_offset]),
   .scout(sov[stq3_rel3_val_offset]),
   .din(stq3_rel3_val_d),
   .dout(stq3_rel3_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_rel4_val_reg(
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
   .scin(siv[stq4_rel4_val_offset]),
   .scout(sov[stq4_rel4_val_offset]),
   .din(stq4_rel4_val_d),
   .dout(stq4_rel4_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_lose_watch_reg(
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
   .scin(siv[stq4_lose_watch_offset]),
   .scout(sov[stq4_lose_watch_offset]),
   .din(stq4_lose_watch_d),
   .dout(stq4_lose_watch_q)
);

tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq4_way_hit_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq3_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_way_hit_offset:stq4_way_hit_offset + numWays - 1]),
   .scout(sov[stq4_way_hit_offset:stq4_way_hit_offset + numWays - 1]),
   .din(stq4_way_hit_d),
   .dout(stq4_way_hit_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_stq2_stq3_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_stq2_stq3_cmp_offset]),
   .scout(sov[congr_cl_stq2_stq3_cmp_offset]),
   .din(congr_cl_stq2_stq3_cmp_d),
   .dout(congr_cl_stq2_stq3_cmp_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_stq2_stq4_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_stq2_stq4_cmp_offset]),
   .scout(sov[congr_cl_stq2_stq4_cmp_offset]),
   .din(congr_cl_stq2_stq4_cmp_d),
   .dout(congr_cl_stq2_stq4_cmp_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_stq2_stq5_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_stq2_stq5_cmp_offset]),
   .scout(sov[congr_cl_stq2_stq5_cmp_offset]),
   .din(congr_cl_stq2_stq5_cmp_d),
   .dout(congr_cl_stq2_stq5_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_stq3_stq4_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_stq3_stq4_cmp_offset]),
   .scout(sov[congr_cl_stq3_stq4_cmp_offset]),
   .din(congr_cl_stq3_stq4_cmp_d),
   .dout(congr_cl_stq3_stq4_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_stq2_ex5_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_stq2_ex5_cmp_offset]),
   .scout(sov[congr_cl_stq2_ex5_cmp_offset]),
   .din(congr_cl_stq2_ex5_cmp_d),
   .dout(congr_cl_stq2_ex5_cmp_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_stq2_ex6_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_stq2_ex6_cmp_offset]),
   .scout(sov[congr_cl_stq2_ex6_cmp_offset]),
   .din(congr_cl_stq2_ex6_cmp_d),
   .dout(congr_cl_stq2_ex6_cmp_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_stq3_ex6_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_stq3_ex6_cmp_offset]),
   .scout(sov[congr_cl_stq3_ex6_cmp_offset]),
   .din(congr_cl_stq3_ex6_cmp_d),
   .dout(congr_cl_stq3_ex6_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_stq3_ex5_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq2_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_stq3_ex5_cmp_offset]),
   .scout(sov[congr_cl_stq3_ex5_cmp_offset]),
   .din(congr_cl_stq3_ex5_cmp_d),
   .dout(congr_cl_stq3_ex5_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_stq4_ex5_cmp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq3_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[congr_cl_stq4_ex5_cmp_offset]),
   .scout(sov[congr_cl_stq4_ex5_cmp_offset]),
   .din(congr_cl_stq4_ex5_cmp_d),
   .dout(congr_cl_stq4_ex5_cmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_cClass_lock_set_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq3_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_cClass_lock_set_offset]),
   .scout(sov[stq4_cClass_lock_set_offset]),
   .din(stq4_cClass_lock_set_d),
   .dout(stq4_cClass_lock_set_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stq4_cClass_thrd_watch_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_stq3_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_cClass_thrd_watch_offset:stq4_cClass_thrd_watch_offset + `THREADS - 1]),
   .scout(sov[stq4_cClass_thrd_watch_offset:stq4_cClass_thrd_watch_offset + `THREADS - 1]),
   .din(stq4_cClass_thrd_watch_d),
   .dout(stq4_cClass_thrd_watch_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) rel4_all_watch_lost_reg(
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
   .scin(siv[rel4_all_watch_lost_offset:rel4_all_watch_lost_offset + `THREADS - 1]),
   .scout(sov[rel4_all_watch_lost_offset:rel4_all_watch_lost_offset + `THREADS - 1]),
   .din(rel4_all_watch_lost_d),
   .dout(rel4_all_watch_lost_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) lost_watch_evict_ovl_reg(
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
   .scin(siv[lost_watch_evict_ovl_offset:lost_watch_evict_ovl_offset + `THREADS - 1]),
   .scout(sov[lost_watch_evict_ovl_offset:lost_watch_evict_ovl_offset + `THREADS - 1]),
   .din(lost_watch_evict_ovl_d),
   .dout(lost_watch_evict_ovl_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_dir_multihit_val_b_reg(
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
   .scin(siv[stq4_dir_multihit_val_b_offset]),
   .scout(sov[stq4_dir_multihit_val_b_offset]),
   .din(stq4_dir_multihit_val_b_d),
   .dout(stq4_dir_multihit_val_b_q)
);


tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq4_err_det_way_reg(
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
   .scin(siv[stq4_err_det_way_offset:stq4_err_det_way_offset + numWays - 1]),
   .scout(sov[stq4_err_det_way_offset:stq4_err_det_way_offset + numWays - 1]),
   .din(stq4_err_det_way_d),
   .dout(stq4_err_det_way_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_perr_lock_lost_reg(
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
   .scin(siv[stq4_perr_lock_lost_offset]),
   .scout(sov[stq4_perr_lock_lost_offset]),
   .din(stq4_perr_lock_lost_d),
   .dout(stq4_perr_lock_lost_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stq4_perr_watchlost_reg(
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
   .scin(siv[stq4_perr_watchlost_offset:stq4_perr_watchlost_offset + `THREADS - 1]),
   .scout(sov[stq4_perr_watchlost_offset:stq4_perr_watchlost_offset + `THREADS - 1]),
   .din(stq4_perr_watchlost_d),
   .dout(stq4_perr_watchlost_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_dir_perr_det_reg(
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
   .scin(siv[stq4_dir_perr_det_offset]),
   .scout(sov[stq4_dir_perr_det_offset]),
   .din(stq4_dir_perr_det_d),
   .dout(stq4_dir_perr_det_q)
);

tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq5_way_perr_inval_reg(
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
   .scin(siv[stq5_way_perr_inval_offset:stq5_way_perr_inval_offset + numWays - 1]),
   .scout(sov[stq5_way_perr_inval_offset:stq5_way_perr_inval_offset + numWays - 1]),
   .din(stq5_way_perr_inval_d),
   .dout(stq5_way_perr_inval_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq5_dir_err_val_reg(
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
   .scin(siv[stq5_dir_err_val_offset]),
   .scout(sov[stq5_dir_err_val_offset]),
   .din(stq5_dir_err_val_d),
   .dout(stq5_dir_err_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_stp_perr_flush_reg(
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
   .scin(siv[ex5_stp_perr_flush_offset]),
   .scout(sov[ex5_stp_perr_flush_offset]),
   .din(ex5_stp_perr_flush_d),
   .dout(ex5_stp_perr_flush_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stm_watchlost_state_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stm_watchlost_state_offset:stm_watchlost_state_offset + `THREADS - 1]),
   .scout(sov[stm_watchlost_state_offset:stm_watchlost_state_offset + `THREADS - 1]),
   .din(stm_watchlost_state_d),
   .dout(stm_watchlost_state_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) p0_wren_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[p0_wren_offset]),
   .scout(sov[p0_wren_offset]),
   .din(p0_wren_d),
   .dout(p0_wren_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) p0_wren_cpy_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[p0_wren_cpy_offset]),
   .scout(sov[p0_wren_cpy_offset]),
   .din(p0_wren_cpy_d),
   .dout(p0_wren_cpy_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) p0_wren_stg_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[p0_wren_stg_offset]),
   .scout(sov[p0_wren_stg_offset]),
   .din(p0_wren_stg_d),
   .dout(p0_wren_stg_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) p1_wren_reg(
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
   .scin(siv[p1_wren_offset]),
   .scout(sov[p1_wren_offset]),
   .din(p1_wren_d),
   .dout(p1_wren_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) p1_wren_cpy_reg(
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
   .scin(siv[p1_wren_cpy_offset]),
   .scout(sov[p1_wren_cpy_offset]),
   .din(p1_wren_cpy_d),
   .dout(p1_wren_cpy_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq6_wren_reg(
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
   .scin(siv[stq6_wren_offset]),
   .scout(sov[stq6_wren_offset]),
   .din(stq6_wren_d),
   .dout(stq6_wren_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq7_wren_reg(
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
   .scin(siv[stq7_wren_offset]),
   .scout(sov[stq7_wren_offset]),
   .din(stq7_wren_d),
   .dout(stq7_wren_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_all_act_reg(
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
   .scin(siv[congr_cl_all_act_offset]),
   .scout(sov[congr_cl_all_act_offset]),
   .din(congr_cl_all_act_d),
   .dout(congr_cl_all_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_clfc_reg(
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
   .scin(siv[spr_xucr0_clfc_offset]),
   .scout(sov[spr_xucr0_clfc_offset]),
   .din(spr_xucr0_clfc_d),
   .dout(spr_xucr0_clfc_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lock_finval_reg(
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
   .scin(siv[lock_finval_offset]),
   .scout(sov[lock_finval_offset]),
   .din(lock_finval_d),
   .dout(lock_finval_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) val_finval_reg(
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
   .scin(siv[val_finval_offset]),
   .scout(sov[val_finval_offset]),
   .din(val_finval_d),
   .dout(val_finval_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) watch_finval_reg(
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
   .scin(siv[watch_finval_offset:watch_finval_offset + `THREADS - 1]),
   .scout(sov[watch_finval_offset:watch_finval_offset + `THREADS - 1]),
   .din(watch_finval_d),
   .dout(watch_finval_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) inj_dirmultihit_ldp_reg(
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
   .scin(siv[inj_dirmultihit_ldp_offset]),
   .scout(sov[inj_dirmultihit_ldp_offset]),
   .din(inj_dirmultihit_ldp_d),
   .dout(inj_dirmultihit_ldp_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) inj_dirmultihit_stp_reg(
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
   .scin(siv[inj_dirmultihit_stp_offset]),
   .scout(sov[inj_dirmultihit_stp_offset]),
   .din(inj_dirmultihit_stp_d),
   .dout(inj_dirmultihit_stp_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xucr0_cslc_xuop_reg(
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
   .scin(siv[xucr0_cslc_xuop_offset]),
   .scout(sov[xucr0_cslc_xuop_offset]),
   .din(xucr0_cslc_xuop_d),
   .dout(xucr0_cslc_xuop_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xucr0_cslc_binv_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[xucr0_cslc_binv_offset]),
   .scout(sov[xucr0_cslc_binv_offset]),
   .din(xucr0_cslc_binv_d),
   .dout(xucr0_cslc_binv_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) lost_watch_inter_thrd_reg(
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
   .scin(siv[lost_watch_inter_thrd_offset:lost_watch_inter_thrd_offset + `THREADS - 1]),
   .scout(sov[lost_watch_inter_thrd_offset:lost_watch_inter_thrd_offset + `THREADS - 1]),
   .din(lost_watch_inter_thrd_d),
   .dout(lost_watch_inter_thrd_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) lost_watch_evict_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lost_watch_evict_val_offset:lost_watch_evict_val_offset + `THREADS - 1]),
   .scout(sov[lost_watch_evict_val_offset:lost_watch_evict_val_offset + `THREADS - 1]),
   .din(lost_watch_evict_val_d),
   .dout(lost_watch_evict_val_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) lost_watch_binv_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lost_watch_binv_offset:lost_watch_binv_offset + `THREADS - 1]),
   .scout(sov[lost_watch_binv_offset:lost_watch_binv_offset + `THREADS - 1]),
   .din(lost_watch_binv_d),
   .dout(lost_watch_binv_q)
);

generate
   if (numScanChains == 0) begin : ring0
      assign siv[0:(scan_right % 1248)] = {sov[1:(scan_right % 1248)], scan_in[0]};
      assign scan_out[0] = sov[0];
      assign scan_out[1] = scan_in[1];
      assign scan_out[2] = scan_in[2];
   end
endgenerate
generate
   if (numScanChains == 1) begin : ring1
      assign siv[0:1247] = {sov[1:1247], scan_in[0]};
      assign scan_out[0] = sov[0];
      assign siv[1248:1248 + (scan_right % 1248)] = {sov[1248 + 1:1248 + (scan_right % 1248)], scan_in[1]};
      assign scan_out[1] = sov[1248];
      assign scan_out[2] = scan_in[2];
   end
endgenerate
generate
   if (numScanChains == 2) begin : ring2
      assign siv[0:1247] = {sov[1:1247], scan_in[0]};
      assign scan_out[0] = sov[0];
      assign siv[1248:2495] = {sov[1249:2495], scan_in[1]};
      assign scan_out[1] = sov[1248];
      assign siv[2496:2496 + (scan_right % 1248)] = {sov[2496 + 1:2496 + (scan_right % 1248)], scan_in[2]};
      assign scan_out[2] = sov[2496];
   end
endgenerate

endmodule
