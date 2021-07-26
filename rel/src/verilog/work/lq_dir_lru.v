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
//  Description:  XU LSU L1 Data Directory LRU Register Array
//
//*****************************************************************************

`include "tri_a2o.vh"


module lq_dir_lru(
   dcc_dir_ex2_stg_act,
   dcc_dir_ex3_stg_act,
   dcc_dir_ex4_stg_act,
   dcc_dir_ex5_stg_act,
   dcc_dir_stq1_stg_act,
   dcc_dir_stq2_stg_act,
   dcc_dir_stq3_stg_act,
   lsq_ctl_stq1_val,
   lsq_ctl_stq2_blk_req,
   lsq_ctl_stq1_ci,
   lsq_ctl_stq1_addr,
   lsq_ctl_rel1_clr_val,
   lsq_ctl_rel1_set_val,
   lsq_ctl_rel1_data_val,
   lsq_ctl_rel2_blk_req,
   lsq_ctl_rel1_lock_set,
   lsq_ctl_rel1_classid,
   lsq_ctl_rel1_tag,
   lsq_ctl_rel3_clr_relq,
   stq1_lru_upd,
   stq3_way_hit_a,
   stq3_way_hit_b,
   stq3_way_hit_c,
   stq3_way_hit_d,
   stq3_way_hit_e,
   stq3_way_hit_f,
   stq3_way_hit_g,
   stq3_way_hit_h,
   stq3_hit,
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
   ex2_eff_addr,
   dcc_dir_ex3_cache_acc,
   dcc_dir_ex3_lru_upd,
   derat_dir_ex4_wimge_i,
   ex4_way_hit_a,
   ex4_way_hit_b,
   ex4_way_hit_c,
   ex4_way_hit_d,
   ex4_way_hit_e,
   ex4_way_hit_f,
   ex4_way_hit_g,
   ex4_way_hit_h,
   ex4_hit,
   dcc_dir_spr_xucr2_rmt,
   spr_xucr0_dcdis,
   xu_lq_spr_xucr0_wlk,
   spr_xucr0_cls,
   fgen_ex3_stg_flush,
   fgen_ex4_stg_flush,
   fgen_ex5_stg_flush,
   rel_way_wen_a,
   rel_way_wen_b,
   rel_way_wen_c,
   rel_way_wen_d,
   rel_way_wen_e,
   rel_way_wen_f,
   rel_way_wen_g,
   rel_way_wen_h,
   rel_way_upd_a,
   rel_way_upd_b,
   rel_way_upd_c,
   rel_way_upd_d,
   rel_way_upd_e,
   rel_way_upd_f,
   rel_way_upd_g,
   rel_way_upd_h,
   rel_way_clr_a,
   rel_way_clr_b,
   rel_way_clr_c,
   rel_way_clr_d,
   rel_way_clr_e,
   rel_way_clr_f,
   rel_way_clr_g,
   rel_way_clr_h,
   rel3_dir_wr_val,
   rel3_dir_wr_addr,
   dir_dcc_rel3_dcarr_upd,
   stq4_dcarr_way_en,
   dir_dcc_ex5_dir_lru,
   lq_xu_spr_xucr0_clo,
   vdd,
   gnd,
   nclk,
   sg_0,
   func_sl_thold_0_b,
   func_sl_force,
   func_nsl_thold_0_b,
   func_nsl_force,
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
//parameter                         LMQ_ENTRIES = 8;		// Number of Loadmiss Queue Entries
//parameter                         DC_SIZE = 15;		  // 14 => 16K L1D$, 15 => 32K L1D$
//parameter                         CL_SIZE = 6;		  // 6 => 64B CLINE, 7 => 128B CLINE

// ACT's
input                               dcc_dir_ex2_stg_act;
input                               dcc_dir_ex3_stg_act;
input                               dcc_dir_ex4_stg_act;
input                               dcc_dir_ex5_stg_act;
input                               dcc_dir_stq1_stg_act;
input                               dcc_dir_stq2_stg_act;
input                               dcc_dir_stq3_stg_act;

// Inputs
//Reload path
input                               lsq_ctl_stq1_val;		      // Recirculation Operation is Valid
input                               lsq_ctl_stq2_blk_req;		// Block Store due to RV issue
input                               lsq_ctl_stq1_ci;		      // Recirculation is Cache-Inhibited
input [64-(`DC_SIZE-3):63-`CL_SIZE] lsq_ctl_stq1_addr;		   // Reload Congruence Class
input                               lsq_ctl_rel1_clr_val;		// Reload data is valid for 1st beat
input                               lsq_ctl_rel1_set_val;		// Reload data is valid for last beat
input                               lsq_ctl_rel1_data_val;		// Reload data is valid for middle beats
input                               lsq_ctl_rel2_blk_req;		// Block Reload due to RV issue or Back-Invalidate
input                               lsq_ctl_rel1_lock_set;		// Reload For a DCBTLS/DCBTSTLS
input [0:1]                         lsq_ctl_rel1_classid;		// Way locking ClassID
input [0:3]                         lsq_ctl_rel1_tag;		      // Reload Tag
input                               lsq_ctl_rel3_clr_relq;		// Reload Complete due to an ECC error
input                               stq1_lru_upd;		         // Cache Access does not update the LRU (i.e. dcbt, dcbtst, dcbf, etc)

// stq3 Recirculation Pipe Command Inputs
input                               stq3_way_hit_a;		      // Way A Hit
input                               stq3_way_hit_b;		      // Way B Hit
input                               stq3_way_hit_c;		      // Way C Hit
input                               stq3_way_hit_d;		      // Way D Hit
input                               stq3_way_hit_e;		      // Way E Hit
input                               stq3_way_hit_f;		      // Way F Hit
input                               stq3_way_hit_g;		      // Way G Hit
input                               stq3_way_hit_h;		      // Way H Hit
input                               stq3_hit;		            // Recirculation Pipe operation hit in L1 D$

// Way Valids for Replacement Algorithm
input                               rel_way_val_a;		         // Way A Valid for Replacement algorithm
input                               rel_way_val_b;		         // Way B Valid for Replacement algorithm
input                               rel_way_val_c;		         // Way C Valid for Replacement algorithm
input                               rel_way_val_d;		         // Way D Valid for Replacement algorithm
input                               rel_way_val_e;		         // Way E Valid for Replacement algorithm
input                               rel_way_val_f;		         // Way F Valid for Replacement algorithm
input                               rel_way_val_g;		         // Way G Valid for Replacement algorithm
input                               rel_way_val_h;		         // Way H Valid for Replacement algorithm

// Congruence Class Line Lock
input                               rel_way_lock_a;		      // Way A Locked Line for Replacement algorithm
input                               rel_way_lock_b;		      // Way B Locked Line for Replacement algorithm
input                               rel_way_lock_c;		      // Way C Locked Line for Replacement algorithm
input                               rel_way_lock_d;		      // Way D Locked Line for Replacement algorithm
input                               rel_way_lock_e;		      // Way E Locked Line for Replacement algorithm
input                               rel_way_lock_f;		      // Way F Locked Line for Replacement algorithm
input                               rel_way_lock_g;		      // Way G Locked Line for Replacement algorithm
input                               rel_way_lock_h;		      // Way H Locked Line for Replacement algorithm

//Execution path
input [64-(`DC_SIZE-3):63-`CL_SIZE] ex2_eff_addr;
input                               dcc_dir_ex3_cache_acc;		// Cache Access is Valid
input                               dcc_dir_ex3_lru_upd;		   // Cache Access does not update the LRU (i.e. dcbt and dcbtst)
input                               derat_dir_ex4_wimge_i;		// Cache-Inhibited Request

// Way Hit for Execution Pipe
input                               ex4_way_hit_a;		         // ex3 Way A hit
input                               ex4_way_hit_b;		         // ex3 Way B hit
input                               ex4_way_hit_c;		         // ex3 Way C hit
input                               ex4_way_hit_d;		         // ex3 Way D hit
input                               ex4_way_hit_e;		         // ex3 Way E hit
input                               ex4_way_hit_f;		         // ex3 Way F hit
input                               ex4_way_hit_g;		         // ex3 Way G hit
input                               ex4_way_hit_h;		         // ex3 Way H hit
input                               ex4_hit;		               // ex4 hit

// SPR's
input [0:31]                        dcc_dir_spr_xucr2_rmt;		// XUCR2 RMT bits
input                               spr_xucr0_dcdis;		      // Data Cache Disable
input                               xu_lq_spr_xucr0_wlk;		   // XUCR0 Way locking enabled
input                               spr_xucr0_cls;		         // 128Byte Cacheline Mode

// Flush Signals
input                               fgen_ex3_stg_flush;		   // ex3 Flush Stage
input                               fgen_ex4_stg_flush;		   // ex4 Flush Stage
input                               fgen_ex5_stg_flush;		   // ex5 Flush Stage

// Outputs
// Way Data Cache Write Enables on a Reload
output                              rel_way_wen_a;		         // Reload Way A Write Enable
output                              rel_way_wen_b;		         // Reload Way B Write Enable
output                              rel_way_wen_c;		         // Reload Way C Write Enable
output                              rel_way_wen_d;		         // Reload Way D Write Enable
output                              rel_way_wen_e;		         // Reload Way E Write Enable
output                              rel_way_wen_f;		         // Reload Way F Write Enable
output                              rel_way_wen_g;		         // Reload Way G Write Enable
output                              rel_way_wen_h;		         // Reload Way H Write Enable

// Way Directory Write Enables on a Reload
output                              rel_way_upd_a;		         // Reload Way A Write Enable
output                              rel_way_upd_b;		         // Reload Way B Write Enable
output                              rel_way_upd_c;		         // Reload Way C Write Enable
output                              rel_way_upd_d;		         // Reload Way D Write Enable
output                              rel_way_upd_e;		         // Reload Way E Write Enable
output                              rel_way_upd_f;		         // Reload Way F Write Enable
output                              rel_way_upd_g;		         // Reload Way G Write Enable
output                              rel_way_upd_h;		         // Reload Way H Write Enable

// Way Invalidate on a Reload
output                              rel_way_clr_a;		         // Reload Way A Write Enable
output                              rel_way_clr_b;		         // Reload Way B Write Enable
output                              rel_way_clr_c;		         // Reload Way C Write Enable
output                              rel_way_clr_d;		         // Reload Way D Write Enable
output                              rel_way_clr_e;		         // Reload Way E Write Enable
output                              rel_way_clr_f;		         // Reload Way F Write Enable
output                              rel_way_clr_g;		         // Reload Way G Write Enable
output                              rel_way_clr_h;		         // Reload Way H Write Enable
output                              rel3_dir_wr_val;             // Reload Directory Write Stage is valid
output [64-(`DC_SIZE-3):63-`CL_SIZE] rel3_dir_wr_addr;           // Reload Directory Write Address
output                              dir_dcc_rel3_dcarr_upd;		 // Reload Data Array Update Valid

// Way Write Enable on a Reload for Data
output [0:7]                        stq4_dcarr_way_en;		         // Reload upper Address

// Directory LRU in EX5
output [0:6]                        dir_dcc_ex5_dir_lru;

// SPR Status
output                              lq_xu_spr_xucr0_clo;		   // Cache Lock instruction caused an overlock

//pervasive


inout                               vdd;


inout                               gnd;

(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

input [0:`NCLK_WIDTH-1]             nclk;
input                               sg_0;
input                               func_sl_thold_0_b;
input                               func_sl_force;
input                               func_nsl_thold_0_b;
input                               func_nsl_force;
input                               d_mode_dc;
input                               delay_lclkr_dc;
input                               mpw1_dc_b;
input                               mpw2_dc_b;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input                               scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output                              scan_out;

//--------------------------
// components
//--------------------------

//--------------------------
// signals
//--------------------------
parameter                           uprCClassBit = 64 - (`DC_SIZE - 3);
parameter                           lwrCClassBit = 63 - `CL_SIZE;
parameter                           numCClass = ((2 ** `DC_SIZE)/(2 ** `CL_SIZE))/8;
parameter                           numCClassWidth = lwrCClassBit-uprCClassBit+1;
parameter                           numWays = 8;
parameter                           lruState = numWays - 1;

wire [0:lruState-1]                 congr_cl_lru_d[0:numCClass-1];
wire [0:lruState-1]                 congr_cl_lru_q[0:numCClass-1];
wire [0:numCClass-1]                congr_cl_lru_wen;
wire [0:numCClass-1]                lq_op_cl_lru_wen;
wire [0:numCClass-1]                rel_cl_lru_wen;
wire [0:lruState-1]                 rel_ldst_cl_lru[0:numCClass-1];
wire [uprCClassBit:lwrCClassBit]    ex2_congr_cl;
wire [uprCClassBit:lwrCClassBit]    ex3_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]    ex3_congr_cl_q;
wire [uprCClassBit:lwrCClassBit]    ex4_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]    ex4_congr_cl_q;
wire [0:numCClass-1]                ex4_congr_cl_1hot;
wire [uprCClassBit:lwrCClassBit]    ex5_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]    ex5_congr_cl_q;
wire [uprCClassBit:lwrCClassBit]    ex6_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]    ex6_congr_cl_q;
wire [uprCClassBit:lwrCClassBit]    stq1_congr_cl;
wire [uprCClassBit:lwrCClassBit]    stq2_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]    stq2_congr_cl_q;
wire [0:numCClass-1]                stq2_congr_cl_1hot;
wire [uprCClassBit:lwrCClassBit]    stq3_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]    stq3_congr_cl_q;
wire [uprCClassBit:lwrCClassBit]    stq4_congr_cl_d;
wire [uprCClassBit:lwrCClassBit]    stq4_congr_cl_q;
wire                                rel2_clr_stg_val_d;
wire                                rel2_clr_stg_val_q;
wire                                rel3_clr_stg_val_d;
wire                                rel3_clr_stg_val_q;
wire                                rel2_data_stg_val_d;
wire                                rel2_data_stg_val_q;
wire                                rel3_data_stg_val_d;
wire                                rel3_data_stg_val_q;
wire                                stq3_val_wen;
wire                                stq4_val_wen_d;
wire                                stq4_val_wen_q;
wire [0:lruState-1]                 lq_congr_cl_lru_d;
wire [0:lruState-1]                 lq_congr_cl_lru_q;
wire                                rel_wayA_clr;
wire                                rel_wayB_clr;
wire                                rel_wayC_clr;
wire                                rel_wayD_clr;
wire                                rel_wayE_clr;
wire                                rel_wayF_clr;
wire                                rel_wayG_clr;
wire                                rel_wayH_clr;
wire                                stq_wayA_hit;
wire                                stq_wayB_hit;
wire                                stq_wayC_hit;
wire                                stq_wayD_hit;
wire                                stq_wayE_hit;
wire                                stq_wayF_hit;
wire                                stq_wayG_hit;
wire                                stq_wayH_hit;
wire [0:numWays-1]                  rel_clr_vec;
wire [0:numWays-1]                  rel_hit_vec;
wire [0:lruState-1]                 hit_wayA_upd;
wire [0:lruState-1]                 hit_wayB_upd;
wire [0:lruState-1]                 hit_wayC_upd;
wire [0:lruState-1]                 hit_wayD_upd;
wire [0:lruState-1]                 hit_wayE_upd;
wire [0:lruState-1]                 hit_wayF_upd;
wire [0:lruState-1]                 hit_wayG_upd;
wire [0:lruState-1]                 hit_wayh_upd;
wire [0:lruState-1]                 rel_hit_wayA_upd;
wire [0:lruState-1]                 rel_hit_wayB_upd;
wire [0:lruState-1]                 rel_hit_wayC_upd;
wire [0:lruState-1]                 rel_hit_wayD_upd;
wire [0:lruState-1]                 rel_hit_wayE_upd;
wire [0:lruState-1]                 rel_hit_wayF_upd;
wire [0:lruState-1]                 rel_hit_wayG_upd;
wire [0:lruState-1]                 rel_hit_wayh_upd;
wire [0:lruState-1]                 ex5_lru_upd;
wire [0:lruState-1]                 stq3_lru_upd;
wire [0:lruState-1]                 stq4_lru_upd_d;
wire [0:lruState-1]                 stq4_lru_upd_q;
wire [0:lruState-1]                 ex6_lru_upd_d;
wire [0:lruState-1]                 ex6_lru_upd_q;
wire                                ex4_c_acc_d;
wire                                ex4_c_acc_q;
wire                                ex5_c_acc_d;
wire                                ex5_c_acc_q;
wire                                ex6_c_acc_d;
wire                                ex6_c_acc_q;
wire [0:lruState-1]                 lq_op_lru;
wire [0:lruState-1]                 rel_op_lru;
wire [0:numWays-1]                  ldst_hit_vector_d;
wire [0:numWays-1]                  ldst_hit_vector_q;
reg [0:lruState-1]                  p0_arr_lru_rd;
reg [0:lruState-1]                  p1_arr_lru_rd;
wire [0:lruState-1]                 rel_congr_cl_lru_d;
wire [0:lruState-1]                 rel_congr_cl_lru_q;
wire                                ex4_lru_upd_d;
wire                                ex4_lru_upd_q;
wire                                congr_cl_full;
wire [0:numWays-1]                  empty_way;
wire [0:numWays-1]                  full_way;
wire [0:numWays-1]                  rel_hit;
wire [0:3]                          congr_cl_ex4_byp;
wire [0:3]                          congr_cl_ex4_sel;
wire                                ex4_lru_arr_sel;
wire                                congr_cl_ex4_ex5_cmp_d;
wire                                congr_cl_ex4_ex5_cmp_q;
wire                                congr_cl_ex4_ex6_cmp_d;
wire                                congr_cl_ex4_ex6_cmp_q;
wire                                congr_cl_ex4_stq3_cmp_d;
wire                                congr_cl_ex4_stq3_cmp_q;
wire                                congr_cl_ex4_stq4_cmp_d;
wire                                congr_cl_ex4_stq4_cmp_q;
wire                                congr_cl_ex4_ex5_m;
wire                                congr_cl_ex4_stq3_m;
wire                                congr_cl_ex4_ex6_m;
wire                                congr_cl_ex4_stq4_m;
wire                                congr_cl_stq2_ex5_cmp_d;
wire                                congr_cl_stq2_ex5_cmp_q;
wire                                congr_cl_stq2_ex6_cmp_d;
wire                                congr_cl_stq2_ex6_cmp_q;
wire                                congr_cl_stq2_stq3_cmp_d;
wire                                congr_cl_stq2_stq3_cmp_q;
wire                                congr_cl_stq2_stq4_cmp_d;
wire                                congr_cl_stq2_stq4_cmp_q;
wire                                congr_cl_stq2_ex5_m;
wire                                congr_cl_stq2_ex6_m;
wire                                congr_cl_stq2_stq3_m;
wire                                congr_cl_stq2_stq4_m;
wire [0:3]                          congr_cl_stq2_byp;
wire [0:3]                          congr_cl_stq2_sel;
wire                                stq2_lru_arr_sel;
reg [0:numWays-1]                   rel_way_qsel_d;
wire [0:numWays-1]                  rel_way_qsel_q;
reg [0:numWays-1]                   rel_way_mid_qsel;
wire                                rel_val_mid_qsel;
wire [0:3]                          rel2_rel_tag_d;
wire [0:3]                          rel2_rel_tag_q;
wire [0:3]                          rel3_rel_tag_d;
wire [0:3]                          rel3_rel_tag_q;
wire                                rel2_set_stg_val_d;
wire                                rel2_set_stg_val_q;
wire                                rel3_set_stg_val_d;
wire                                rel3_set_stg_val_q;
wire                                rel_wayA_mid;
wire                                rel_wayB_mid;
wire                                rel_wayC_mid;
wire                                rel_wayD_mid;
wire                                rel_wayE_mid;
wire                                rel_wayF_mid;
wire                                rel_wayG_mid;
wire                                rel_wayH_mid;
wire                                rel_wayA_set;
wire                                rel_wayB_set;
wire                                rel_wayC_set;
wire                                rel_wayD_set;
wire                                rel_wayE_set;
wire                                rel_wayF_set;
wire                                rel_wayG_set;
wire                                rel_wayH_set;
wire [0:numWays-1]                  rel4_dir_way_upd_d;
wire [0:numWays-1]                  rel4_dir_way_upd_q;
wire [0:numWays-1]                  rel3_wlock_d;
wire [0:numWays-1]                  rel3_wlock_q;
wire [0:numWays-1]                  rel_lock_line;
wire [0:lruState-1]                 stq3_op_lru;
wire [0:lruState-1]                 rel_ovrd_lru;
wire [0:1]                          rel_ovrd_wayAB;
wire [0:1]                          rel_ovrd_wayCD;
wire [0:1]                          rel_ovrd_wayEF;
wire [0:1]                          rel_ovrd_wayGH;
wire [0:1]                          rel_ovrd_wayABCD;
wire [0:1]                          rel_ovrd_wayEFGH;
wire [0:1]                          rel_ovrd_wayABCDEFGH;
wire                                ovr_lock_det;
wire                                ovr_lock_det_wlkon;
wire                                ovr_lock_det_wlkoff;
wire                                wayA_not_empty;
wire                                wayB_not_empty;
wire                                wayC_not_empty;
wire                                wayD_not_empty;
wire                                wayE_not_empty;
wire                                wayF_not_empty;
wire                                wayG_not_empty;
wire                                wayH_not_empty;
wire [0:`LMQ_ENTRIES-1]             reld_q_chk_val;
wire [0:numWays-1]                  reld_q_chk_way[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]             reld_q_way_m;
wire [0:`LMQ_ENTRIES-1]             reld_q_set;
wire [0:`LMQ_ENTRIES-1]             reld_q_inval;
wire [0:1]                          reld_q_val_sel[0:`LMQ_ENTRIES-1];
wire [uprCClassBit:lwrCClassBit]    reld_q_congr_cl_d[0:`LMQ_ENTRIES-1];
wire [uprCClassBit:lwrCClassBit]    reld_q_congr_cl_q[0:`LMQ_ENTRIES-1];
wire [0:numWays-1]                  reld_q_way_d[0:`LMQ_ENTRIES-1];
wire [0:numWays-1]                  reld_q_way_q[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]             reld_q_val_d;
wire [0:`LMQ_ENTRIES-1]             reld_q_val_q;
wire [0:`LMQ_ENTRIES-1]             reld_q_lock_d;
wire [0:`LMQ_ENTRIES-1]             reld_q_lock_q;
wire [0:numWays-1]                  reld_q_way_lock[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]             rel_m_q;
wire [0:`LMQ_ENTRIES-1]             reld_match;
wire [0:`LMQ_ENTRIES-1]             reld_q_sel_d;
wire [0:`LMQ_ENTRIES-1]             reld_q_sel_q;
wire [0:`LMQ_ENTRIES-1]             reld_q_set_val;
wire [0:`LMQ_ENTRIES-1]             reld_q_mid_val;
wire                                rel_val_qsel_d;
wire                                rel_val_qsel_q;
wire [0:numWays-1]                  rel2_wlock_rmt;
wire [0:31]                         rel2_xucr2_rmt_d;
wire [0:31]                         rel2_xucr2_rmt_q;
wire                                spr_xucr0_wlk_d;
wire                                spr_xucr0_wlk_q;
wire [0:1]                          stq2_class_id_d;
wire [0:1]                          stq2_class_id_q;
wire                                rel_m_q_upd;
wire [0:numWays-1]                  rel_m_q_upd_way;
wire [0:numWays-1]                  rel_m_q_upd_lock_way;
reg [0:numWays-1]                   rel_m_q_way_val;
reg [0:numWays-1]                   rel_m_q_lock_way;
wire [0:numWays-1]                  rel3_m_q_way_d;
wire [0:numWays-1]                  rel3_m_q_way_q;
wire                                rel2_lock_en_d;
wire                                rel2_lock_en_q;
wire                                rel3_lock_en_d;
wire                                rel3_lock_en_q;
wire                                xucr0_clo_d;
wire                                xucr0_clo_q;
wire [0:numWays-1]                  rel_way_dwen;
wire [0:numWays-1]                  stq4_dcarr_way_en_d;
wire [0:numWays-1]                  stq4_dcarr_way_en_q;
wire                                stq3_new_lru_sel;
wire [0:lruState-1]                 rel_hit_lru_upd;
wire [0:lruState-1]                 ldst_hit_lru_upd;
wire                                stq2_val_d;
wire                                stq2_val_q;
wire                                stq3_val_d;
wire                                stq3_val_q;
wire                                congr_cl_act_d;
wire                                congr_cl_act_q;

//--------------------------
// constants
//--------------------------
parameter                           congr_cl_lru_offset = 0;
parameter                           rel2_xucr2_rmt_offset = congr_cl_lru_offset + numCClass*lruState;
parameter                           spr_xucr0_wlk_offset = rel2_xucr2_rmt_offset + 32;
parameter                           lq_congr_cl_lru_offset = spr_xucr0_wlk_offset + 1;
parameter                           ldst_hit_vector_offset = lq_congr_cl_lru_offset + lruState;
parameter                           rel_congr_cl_lru_offset = ldst_hit_vector_offset + numWays;
parameter                           ex3_congr_cl_offset = rel_congr_cl_lru_offset + lruState;
parameter                           ex4_congr_cl_offset = ex3_congr_cl_offset + numCClassWidth;
parameter                           ex5_congr_cl_offset = ex4_congr_cl_offset + numCClassWidth;
parameter                           ex6_congr_cl_offset = ex5_congr_cl_offset + numCClassWidth;
parameter                           stq2_congr_cl_offset = ex6_congr_cl_offset + numCClassWidth;
parameter                           stq3_congr_cl_offset = stq2_congr_cl_offset + numCClassWidth;
parameter                           stq4_congr_cl_offset = stq3_congr_cl_offset + numCClassWidth;
parameter                           congr_cl_stq2_ex5_cmp_offset = stq4_congr_cl_offset + numCClassWidth;
parameter                           congr_cl_stq2_ex6_cmp_offset = congr_cl_stq2_ex5_cmp_offset + 1;
parameter                           congr_cl_stq2_stq3_cmp_offset = congr_cl_stq2_ex6_cmp_offset + 1;
parameter                           congr_cl_stq2_stq4_cmp_offset = congr_cl_stq2_stq3_cmp_offset + 1;
parameter                           congr_cl_ex4_ex5_cmp_offset = congr_cl_stq2_stq4_cmp_offset + 1;
parameter                           congr_cl_ex4_ex6_cmp_offset = congr_cl_ex4_ex5_cmp_offset + 1;
parameter                           congr_cl_ex4_stq3_cmp_offset = congr_cl_ex4_ex6_cmp_offset + 1;
parameter                           congr_cl_ex4_stq4_cmp_offset = congr_cl_ex4_stq3_cmp_offset + 1;
parameter                           ex6_lru_upd_offset = congr_cl_ex4_stq4_cmp_offset + 1;
parameter                           rel2_clr_stg_val_offset = ex6_lru_upd_offset + lruState;
parameter                           rel3_clr_stg_val_offset = rel2_clr_stg_val_offset + 1;
parameter                           rel2_data_stg_val_offset = rel3_clr_stg_val_offset + 1;
parameter                           rel3_data_stg_val_offset = rel2_data_stg_val_offset + 1;
parameter                           ex4_c_acc_offset = rel3_data_stg_val_offset + 1;
parameter                           ex5_c_acc_offset = ex4_c_acc_offset + 1;
parameter                           ex6_c_acc_offset = ex5_c_acc_offset + 1;
parameter                           stq4_val_wen_offset = ex6_c_acc_offset + 1;
parameter                           stq4_lru_upd_offset = stq4_val_wen_offset + 1;
parameter                           rel2_rel_tag_offset = stq4_lru_upd_offset + lruState;
parameter                           rel3_rel_tag_offset = rel2_rel_tag_offset + 4;
parameter                           rel2_set_stg_val_offset = rel3_rel_tag_offset + 4;
parameter                           rel3_set_stg_val_offset = rel2_set_stg_val_offset + 1;
parameter                           rel3_wlock_offset = rel3_set_stg_val_offset + 1;
parameter                           reld_q_sel_offset = rel3_wlock_offset + numWays;
parameter                           rel_way_qsel_offset = reld_q_sel_offset + `LMQ_ENTRIES;
parameter                           rel_val_qsel_offset = rel_way_qsel_offset + numWays;
parameter                           rel4_dir_way_upd_offset = rel_val_qsel_offset + 1;
parameter                           reld_q_congr_cl_offset = rel4_dir_way_upd_offset + numWays;
parameter                           reld_q_way_offset = reld_q_congr_cl_offset + `LMQ_ENTRIES*numCClassWidth;
parameter                           reld_q_val_offset = reld_q_way_offset + `LMQ_ENTRIES *numWays;
parameter                           reld_q_lock_offset = reld_q_val_offset + `LMQ_ENTRIES;
parameter                           rel3_m_q_way_offset = reld_q_lock_offset + `LMQ_ENTRIES;
parameter                           ex4_lru_upd_offset = rel3_m_q_way_offset + numWays;
parameter                           rel2_lock_en_offset = ex4_lru_upd_offset + 1;
parameter                           rel3_lock_en_offset = rel2_lock_en_offset + 1;
parameter                           xucr0_clo_offset = rel3_lock_en_offset + 1;
parameter                           stq4_dcarr_way_en_offset = xucr0_clo_offset + 1;
parameter                           stq2_class_id_offset = stq4_dcarr_way_en_offset + numWays;
parameter                           stq2_val_offset = stq2_class_id_offset + 2;
parameter                           stq3_val_offset = stq2_val_offset + 1;
parameter                           congr_cl_act_offset = stq3_val_offset + 1;
parameter                           scan_right = congr_cl_act_offset + 1 - 1;

wire                                tiup;
wire [0:scan_right]                 siv;
wire [0:scan_right]                 sov;


(* analysis_not_referenced="true" *)

wire                                unused;

// ####################################################
// Inputs
// ####################################################

assign rel2_xucr2_rmt_d = dcc_dir_spr_xucr2_rmt;
assign spr_xucr0_wlk_d  = xu_lq_spr_xucr0_wlk;
assign tiup = 1'b1;
assign unused = stq3_op_lru[0];

// ####################################################
// Reload Pipe Control
// Port1 => Reload or Recirculation
// ####################################################

// Reload/Recirc Pipe Staging
assign stq2_val_d          = lsq_ctl_stq1_val & stq1_lru_upd & (~(spr_xucr0_dcdis | lsq_ctl_stq1_ci));
assign stq3_val_d          = stq2_val_q & (~lsq_ctl_stq2_blk_req);
assign rel2_clr_stg_val_d  = lsq_ctl_rel1_clr_val & (~spr_xucr0_dcdis);
assign rel3_clr_stg_val_d  = rel2_clr_stg_val_q & (~lsq_ctl_rel2_blk_req);
assign rel2_data_stg_val_d = lsq_ctl_rel1_data_val & (~spr_xucr0_dcdis);
assign rel3_data_stg_val_d = rel2_data_stg_val_q;
assign rel2_set_stg_val_d  = lsq_ctl_rel1_set_val & (~spr_xucr0_dcdis);
assign rel3_set_stg_val_d  = rel2_set_stg_val_q & (~lsq_ctl_rel2_blk_req);
assign rel2_rel_tag_d      = lsq_ctl_rel1_tag;
assign rel3_rel_tag_d      = rel2_rel_tag_q;
assign stq2_class_id_d     = lsq_ctl_rel1_classid;
assign rel2_lock_en_d      = lsq_ctl_rel1_lock_set & lsq_ctl_rel1_clr_val;
assign rel3_lock_en_d      = rel2_lock_en_q & (~lsq_ctl_rel2_blk_req);
assign stq3_val_wen        = (rel3_clr_stg_val_q & (~ovr_lock_det)) | (stq3_val_q & stq3_hit);
assign stq4_val_wen_d      = stq3_val_wen;

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

// ####################################################
// Reload Pipe Directory Read
// ####################################################
// 1-hot Congruence Class Select
generate begin : stpCClass
      genvar                            cclass;
      for (cclass=0; cclass<numCClass; cclass=cclass+1) begin : stpCClass
         wire [uprCClassBit:lwrCClassBit]       cclassDummy=cclass;
         assign stq2_congr_cl_1hot[cclass] = (cclassDummy == stq2_congr_cl_q);
      end
   end
endgenerate

// Reload Path LRU Muxing

always @(*) begin: p1LruRd
   reg [0:lruState-1]                lruSel;

   (* analysis_not_referenced="true" *)

   integer                           cclass;
   lruSel = {lruState{1'b0}};
   for (cclass=0; cclass<numCClass; cclass=cclass+1)
      lruSel = (congr_cl_lru_q[cclass] & {lruState{stq2_congr_cl_1hot[cclass]}}) | lruSel;
   p1_arr_lru_rd <= lruSel;
end

// ####################################################
// Reload Queue Bypass Network
// ####################################################
// STQ2 Stage --> Bypass out of reload Queue
// Need to merge outstanding reloads to same congruence class

// Select which RMT table to use
assign rel2_wlock_rmt = (stq2_class_id_q == 2'b11) ? (~rel2_xucr2_rmt_q[0:7]) :
                        (stq2_class_id_q == 2'b10) ? (~rel2_xucr2_rmt_q[8:15]) :
                        (stq2_class_id_q == 2'b01) ? (~rel2_xucr2_rmt_q[16:23]) :
                        (~rel2_xucr2_rmt_q[24:31]);

// Reload updating a way
assign rel_m_q_upd          = (stq2_congr_cl_q == stq3_congr_cl_q) & rel3_clr_stg_val_q;
assign rel_m_q_upd_way      = rel_clr_vec & {numWays{rel_m_q_upd}};
assign rel_m_q_upd_lock_way = rel_clr_vec & {numWays{(rel_m_q_upd & rel3_lock_en_q)}};

// Reload Matching Reload Queue Entry
generate begin : relqByp
      genvar                            lmq;
      for (lmq=0; lmq<`LMQ_ENTRIES; lmq=lmq+1) begin : relqByp
         assign rel_m_q[lmq]         = (stq2_congr_cl_q == reld_q_congr_cl_q[lmq]) & reld_q_val_q[lmq];
         assign reld_q_way_lock[lmq] = reld_q_way_q[lmq] & {numWays{reld_q_lock_q[lmq]}};
      end
   end
endgenerate

// Reload Matching Reload Queue State Muxing

always @(*) begin: relqBypState
   reg [0:numWays-1]                 qVal;
   reg [0:numWays-1]                 qLock;

   (* analysis_not_referenced="true" *)

   integer                           lmq;
   qVal  = {numWays{1'b0}};
   qLock = {numWays{1'b0}};
   for (lmq=0; lmq<`LMQ_ENTRIES; lmq=lmq+1) begin
      qVal  = (reld_q_way_q[lmq]    & {numWays{rel_m_q[lmq]}}) | qVal;
      qLock = (reld_q_way_lock[lmq] & {numWays{rel_m_q[lmq]}}) | qLock;
   end
   rel_m_q_way_val  <= qVal;
   rel_m_q_lock_way <= qLock;
end

// Reload Queue Ways in Use for congruence class
assign rel3_m_q_way_d = rel_m_q_way_val | rel_m_q_upd_way;

// Reload Queue Locked Ways
assign rel3_wlock_d = rel_m_q_lock_way | rel_m_q_upd_lock_way | rel2_wlock_rmt;

// ####################################################
// Reload/Recirc Pipe Bypass
// ####################################################
// STQ2 Stage --> Bypass Logic
assign congr_cl_stq2_stq3_cmp_d = (stq1_congr_cl == stq2_congr_cl_q);
assign congr_cl_stq2_stq4_cmp_d = (stq1_congr_cl == stq3_congr_cl_q);
assign congr_cl_stq2_ex5_cmp_d  = (stq1_congr_cl == ex4_congr_cl_q);
assign congr_cl_stq2_ex6_cmp_d  = (stq1_congr_cl == ex5_congr_cl_q);

assign congr_cl_stq2_stq3_m = congr_cl_stq2_stq3_cmp_q & stq3_val_wen;
assign congr_cl_stq2_stq4_m = congr_cl_stq2_stq4_cmp_q & stq4_val_wen_q;
assign congr_cl_stq2_ex5_m  = congr_cl_stq2_ex5_cmp_q & ex5_c_acc_q;
assign congr_cl_stq2_ex6_m  = congr_cl_stq2_ex6_cmp_q & ex6_c_acc_q;

// Bypass STQ2 select
assign congr_cl_stq2_byp[0] = congr_cl_stq2_ex5_m;		    // 1st priority
assign congr_cl_stq2_byp[1] = congr_cl_stq2_stq3_m;		    // 2nd priority         <-- slowest of all of them
assign congr_cl_stq2_byp[2] = congr_cl_stq2_ex6_m;		    // 3rd priority
assign congr_cl_stq2_byp[3] = congr_cl_stq2_stq4_m;		    // 4th priority

assign congr_cl_stq2_sel[0] = congr_cl_stq2_byp[0];
assign congr_cl_stq2_sel[1] = congr_cl_stq2_byp[1] &  (~congr_cl_stq2_byp[0]);
assign congr_cl_stq2_sel[2] = congr_cl_stq2_byp[2] & ~(|congr_cl_stq2_byp[0:1]);
assign congr_cl_stq2_sel[3] = congr_cl_stq2_byp[3] & ~(|congr_cl_stq2_byp[0:2]);

assign stq2_lru_arr_sel = ~(|congr_cl_stq2_byp);

assign rel_congr_cl_lru_d = (ex5_lru_upd    & {lruState{congr_cl_stq2_sel[0]}}) |
                            (stq3_lru_upd   & {lruState{congr_cl_stq2_sel[1]}}) |
                            (ex6_lru_upd_q  & {lruState{congr_cl_stq2_sel[2]}}) |
                            (stq4_lru_upd_q & {lruState{congr_cl_stq2_sel[3]}}) |
                            (p1_arr_lru_rd  & {lruState{stq2_lru_arr_sel}});

// Bypassed LRU for Reloads
assign rel_op_lru = rel_congr_cl_lru_q;

// ####################################################
// Reload Path
// ####################################################

// Determine which way is locked
assign rel_lock_line[0] = rel_way_lock_a | rel3_wlock_q[0];
assign rel_lock_line[1] = rel_way_lock_b | rel3_wlock_q[1];
assign rel_lock_line[2] = rel_way_lock_c | rel3_wlock_q[2];
assign rel_lock_line[3] = rel_way_lock_d | rel3_wlock_q[3];
assign rel_lock_line[4] = rel_way_lock_e | rel3_wlock_q[4];
assign rel_lock_line[5] = rel_way_lock_f | rel3_wlock_q[5];
assign rel_lock_line[6] = rel_way_lock_g | rel3_wlock_q[6];
assign rel_lock_line[7] = rel_way_lock_h | rel3_wlock_q[7];

// Override LRU, removing locked ways from replacement
// Overlocking Detected, do not update Cache
assign ovr_lock_det = rel_lock_line[0] & rel_lock_line[1] & rel_lock_line[2] & rel_lock_line[3] &
                      rel_lock_line[4] & rel_lock_line[5] & rel_lock_line[6] & rel_lock_line[7];

assign ovr_lock_det_wlkon  = ovr_lock_det & rel3_clr_stg_val_q;
assign ovr_lock_det_wlkoff = ovr_lock_det & rel3_lock_en_q & rel3_clr_stg_val_q;

assign xucr0_clo_d = spr_xucr0_wlk_q ? ovr_lock_det_wlkon : ovr_lock_det_wlkoff;

// LRU(0)
assign rel_ovrd_wayABCDEFGH = {(rel_lock_line[0] & rel_lock_line[1] & rel_lock_line[2] & rel_lock_line[3]),
                               (rel_lock_line[4] & rel_lock_line[5] & rel_lock_line[6] & rel_lock_line[7])};
assign rel_ovrd_lru[0] = (rel_op_lru[0] & (~rel_ovrd_wayABCDEFGH[1])) | rel_ovrd_wayABCDEFGH[0];

// LRU(1)
assign rel_ovrd_wayABCD = {(rel_lock_line[0] & rel_lock_line[1]), (rel_lock_line[2] & rel_lock_line[3])};
assign rel_ovrd_lru[1] = (rel_op_lru[1] & (~rel_ovrd_wayABCD[1])) | rel_ovrd_wayABCD[0];

// LRU(2)
assign rel_ovrd_wayEFGH = {(rel_lock_line[4] & rel_lock_line[5]), (rel_lock_line[6] & rel_lock_line[7])};
assign rel_ovrd_lru[2] = (rel_op_lru[2] & (~rel_ovrd_wayEFGH[1])) | rel_ovrd_wayEFGH[0];

// LRU(3)
assign rel_ovrd_wayAB = rel_lock_line[0:1];
assign rel_ovrd_lru[3] = (rel_op_lru[3] & (~rel_ovrd_wayAB[1])) | rel_ovrd_wayAB[0];

// LRU(4)
assign rel_ovrd_wayCD = rel_lock_line[2:3];
assign rel_ovrd_lru[4] = (rel_op_lru[4] & (~rel_ovrd_wayCD[1])) | rel_ovrd_wayCD[0];

// LRU(5)
assign rel_ovrd_wayEF = rel_lock_line[4:5];
assign rel_ovrd_lru[5] = (rel_op_lru[5] & (~rel_ovrd_wayEF[1])) | rel_ovrd_wayEF[0];

// LRU(6)
assign rel_ovrd_wayGH = rel_lock_line[6:7];
assign rel_ovrd_lru[6] = (rel_op_lru[6] & (~rel_ovrd_wayGH[1])) | rel_ovrd_wayGH[0];

// Locking Enabled
// Not Empty way is a valid Way or locked way or reload way in queue
assign wayA_not_empty = rel_way_val_a | rel3_wlock_q[0] | rel3_m_q_way_q[0];
assign wayB_not_empty = rel_way_val_b | rel3_wlock_q[1] | rel3_m_q_way_q[1];
assign wayC_not_empty = rel_way_val_c | rel3_wlock_q[2] | rel3_m_q_way_q[2];
assign wayD_not_empty = rel_way_val_d | rel3_wlock_q[3] | rel3_m_q_way_q[3];
assign wayE_not_empty = rel_way_val_e | rel3_wlock_q[4] | rel3_m_q_way_q[4];
assign wayF_not_empty = rel_way_val_f | rel3_wlock_q[5] | rel3_m_q_way_q[5];
assign wayG_not_empty = rel_way_val_g | rel3_wlock_q[6] | rel3_m_q_way_q[6];
assign wayH_not_empty = rel_way_val_h | rel3_wlock_q[7] | rel3_m_q_way_q[7];

// Pseudo LRU needs to be used if all ways contain valid data on a reload or its a recirculation
assign congr_cl_full = (wayA_not_empty & wayB_not_empty & wayC_not_empty & wayD_not_empty &
                        wayE_not_empty & wayF_not_empty & wayG_not_empty & wayH_not_empty) | stq3_val_q;

// Need to select which non-valid way needs updating, Using leftmost empty Way
assign empty_way[0] = ~wayA_not_empty;
assign empty_way[1] = (wayA_not_empty & ~wayB_not_empty);
assign empty_way[2] = (wayA_not_empty &  wayB_not_empty & ~wayC_not_empty);
assign empty_way[3] = (wayA_not_empty &  wayB_not_empty &  wayC_not_empty & ~wayD_not_empty);
assign empty_way[4] = (wayA_not_empty &  wayB_not_empty &  wayC_not_empty &  wayD_not_empty & ~wayE_not_empty);
assign empty_way[5] = (wayA_not_empty &  wayB_not_empty &  wayC_not_empty &  wayD_not_empty &  wayE_not_empty & ~wayF_not_empty);
assign empty_way[6] = (wayA_not_empty &  wayB_not_empty &  wayC_not_empty &  wayD_not_empty &  wayE_not_empty &  wayF_not_empty & ~wayG_not_empty);
assign empty_way[7] = (wayA_not_empty &  wayB_not_empty &  wayC_not_empty &  wayD_not_empty &  wayE_not_empty &  wayF_not_empty &  wayG_not_empty);

// Locking Enabled
// Using LRU to determine which way will be updated
assign full_way[0] = ~rel_ovrd_lru[0] & ~rel_ovrd_lru[1] & ~rel_ovrd_lru[3];
assign full_way[1] = ~rel_ovrd_lru[0] & ~rel_ovrd_lru[1] &  rel_ovrd_lru[3];
assign full_way[2] = ~rel_ovrd_lru[0] &  rel_ovrd_lru[1] & ~rel_ovrd_lru[4];
assign full_way[3] = ~rel_ovrd_lru[0] &  rel_ovrd_lru[1] &  rel_ovrd_lru[4];
assign full_way[4] =  rel_ovrd_lru[0] & ~rel_ovrd_lru[2] & ~rel_ovrd_lru[5];
assign full_way[5] =  rel_ovrd_lru[0] & ~rel_ovrd_lru[2] &  rel_ovrd_lru[5];
assign full_way[6] =  rel_ovrd_lru[0] &  rel_ovrd_lru[2] & ~rel_ovrd_lru[6];
assign full_way[7] =  rel_ovrd_lru[0] &  rel_ovrd_lru[2] &  rel_ovrd_lru[6];

// Selecting between using LRU or Fill in the Empty Ways
assign rel_hit = (empty_way & {numWays{~congr_cl_full}}) | (full_way & {numWays{congr_cl_full}});

// Way that will be updating is determined by the current LRU
// Dont want to update the directory or the D$ if we have all ways locked in the same congruence class
assign rel_wayA_clr = rel_hit[0] & rel3_clr_stg_val_q & ~ovr_lock_det;
assign rel_wayB_clr = rel_hit[1] & rel3_clr_stg_val_q & ~ovr_lock_det;
assign rel_wayC_clr = rel_hit[2] & rel3_clr_stg_val_q & ~ovr_lock_det;
assign rel_wayD_clr = rel_hit[3] & rel3_clr_stg_val_q & ~ovr_lock_det;
assign rel_wayE_clr = rel_hit[4] & rel3_clr_stg_val_q & ~ovr_lock_det;
assign rel_wayF_clr = rel_hit[5] & rel3_clr_stg_val_q & ~ovr_lock_det;
assign rel_wayG_clr = rel_hit[6] & rel3_clr_stg_val_q & ~ovr_lock_det;
assign rel_wayH_clr = rel_hit[7] & rel3_clr_stg_val_q & ~ovr_lock_det;

assign rel_clr_vec = {rel_wayA_clr, rel_wayB_clr, rel_wayC_clr, rel_wayD_clr,
                      rel_wayE_clr, rel_wayF_clr, rel_wayG_clr, rel_wayH_clr};

assign stq_wayA_hit = stq3_way_hit_a & stq3_val_q;
assign stq_wayB_hit = stq3_way_hit_b & stq3_val_q;
assign stq_wayC_hit = stq3_way_hit_c & stq3_val_q;
assign stq_wayD_hit = stq3_way_hit_d & stq3_val_q;
assign stq_wayE_hit = stq3_way_hit_e & stq3_val_q;
assign stq_wayF_hit = stq3_way_hit_f & stq3_val_q;
assign stq_wayG_hit = stq3_way_hit_g & stq3_val_q;
assign stq_wayH_hit = stq3_way_hit_h & stq3_val_q;

assign rel_hit_vec = {(rel_wayA_clr | stq_wayA_hit), (rel_wayB_clr | stq_wayB_hit),
                      (rel_wayC_clr | stq_wayC_hit), (rel_wayD_clr | stq_wayD_hit),
                      (rel_wayE_clr | stq_wayE_hit), (rel_wayF_clr | stq_wayF_hit),
                      (rel_wayG_clr | stq_wayG_hit), (rel_wayH_clr | stq_wayH_hit)};

// ####################################################
// LRU update calculation due to a Reload/Recirculation
// ####################################################
// Select between Reload or Recirculation Operation
assign stq3_op_lru = ~rel3_clr_stg_val_q ? rel_op_lru : rel_ovrd_lru;

// Updating the LRU using the Way that is being reloaded or the Way hit
assign rel_hit_wayA_upd = {2'b11, stq3_op_lru[2],   1'b1, stq3_op_lru[4:6]};
assign rel_hit_wayB_upd = {2'b11, stq3_op_lru[2],   1'b0, stq3_op_lru[4:6]};
assign rel_hit_wayC_upd = {2'b10, stq3_op_lru[2:3], 1'b1, stq3_op_lru[5:6]};
assign rel_hit_wayD_upd = {2'b10, stq3_op_lru[2:3], 1'b0, stq3_op_lru[5:6]};
assign rel_hit_wayE_upd = {1'b0,  stq3_op_lru[1],   1'b1, stq3_op_lru[3:4], 1'b1, stq3_op_lru[6]};
assign rel_hit_wayF_upd = {1'b0,  stq3_op_lru[1],   1'b1, stq3_op_lru[3:4], 1'b0, stq3_op_lru[6]};
assign rel_hit_wayG_upd = {1'b0,  stq3_op_lru[1],   1'b0, stq3_op_lru[3:5], 1'b1};
assign rel_hit_wayh_upd = {1'b0,  stq3_op_lru[1],   1'b0, stq3_op_lru[3:5], 1'b0};

// ####################################################
// Selecting which calculated LRU to update with
// ####################################################
// Selecting Way Hit Updated LRU
assign rel_hit_lru_upd = (rel_hit_wayA_upd & {lruState{rel_hit_vec[0]}}) | (rel_hit_wayB_upd & {lruState{rel_hit_vec[1]}}) |
                         (rel_hit_wayC_upd & {lruState{rel_hit_vec[2]}}) | (rel_hit_wayD_upd & {lruState{rel_hit_vec[3]}}) |
                         (rel_hit_wayE_upd & {lruState{rel_hit_vec[4]}}) | (rel_hit_wayF_upd & {lruState{rel_hit_vec[5]}}) |
                         (rel_hit_wayG_upd & {lruState{rel_hit_vec[6]}}) | (rel_hit_wayh_upd & {lruState{rel_hit_vec[7]}});

// LRU update is valid
assign stq3_new_lru_sel = |(rel_clr_vec) | stq3_hit;
assign stq3_lru_upd     = ~stq3_new_lru_sel ? rel_op_lru : rel_hit_lru_upd;
assign stq4_lru_upd_d   = stq3_lru_upd;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Small Reload Way Enable Queue to Handle Beats with Gaps
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
generate begin : reldQ
      genvar                            lmq;
      for (lmq=0; lmq<`LMQ_ENTRIES; lmq=lmq+1) begin : reldQ
         wire [0:3]           lmqDummy = lmq;

         // Write Enable Logic for Reload Queue
         assign reld_q_chk_val[lmq] = (reld_q_congr_cl_q[lmq] == stq3_congr_cl_q) & reld_q_val_q[lmq] & rel3_clr_stg_val_q & (~ovr_lock_det);
         assign reld_q_chk_way[lmq] = reld_q_way_q[lmq] & {numWays{reld_q_chk_val[lmq]}};
         assign reld_q_way_m[lmq]   = |(reld_q_chk_way[lmq] & rel_hit);
         assign reld_match[lmq]     = reld_q_way_m[lmq];
         assign reld_q_set[lmq]     = rel3_clr_stg_val_q & (rel3_rel_tag_q == lmqDummy);
         assign reld_q_inval[lmq]   = ((rel3_set_stg_val_q | lsq_ctl_rel3_clr_relq) & reld_q_sel_q[lmq]) | reld_match[lmq];
         assign reld_q_val_sel[lmq] = {reld_q_set[lmq], reld_q_inval[lmq]};

         // Congruence Class
         assign reld_q_congr_cl_d[lmq] = reld_q_set[lmq] ? stq3_congr_cl_q : reld_q_congr_cl_q[lmq];

         // Reload Way
         assign reld_q_way_d[lmq] = reld_q_set[lmq] ? rel_hit_vec : reld_q_way_q[lmq];

         // Valid
         assign reld_q_val_d[lmq] = (reld_q_val_sel[lmq] == 2'b10) ? 1'b1 :
                                    (reld_q_val_sel[lmq] == 2'b00) ? reld_q_val_q[lmq] :
                                    1'b0;

         // Lock Bit
         assign reld_q_lock_d[lmq] = (reld_q_val_sel[lmq] == 2'b10) ? rel3_lock_en_q :
                                     (reld_q_val_sel[lmq] == 2'b00) ? reld_q_lock_q[lmq] :
                                     1'b0;

         // Reload Queue Select
         assign reld_q_sel_d[lmq] = (rel2_rel_tag_q == lmqDummy);

         // Reload Queue Set Stage Valid
         assign reld_q_set_val[lmq] = reld_q_val_q[lmq] & reld_q_sel_d[lmq] & ~reld_match[lmq];

         // Reload Queue Mid Stage Valid
         assign reld_q_mid_val[lmq] = reld_q_val_q[lmq] & reld_q_sel_q[lmq];
      end
   end
endgenerate

// Reload Queue Way Muxing
always @(*) begin: reldQSel
   reg [0:numWays-1]                 qWay;
   reg [0:numWays-1]                 qWayM;

   (* analysis_not_referenced="true" *)

   integer                           lmq;
   qWay  = {numWays{1'b0}};
   qWayM = {numWays{1'b0}};
   for (lmq=0; lmq<`LMQ_ENTRIES; lmq=lmq+1) begin
      qWay  = (reld_q_way_q[lmq] & {numWays{reld_q_sel_d[lmq]}}) | qWay;
      qWayM = (reld_q_way_q[lmq] & {numWays{reld_q_sel_q[lmq]}}) | qWayM;
   end
   // Select Way for Set Data Beat
   rel_way_qsel_d <= qWay;

   // Select Way for Middle Data Beats
   rel_way_mid_qsel <= qWayM;
end

// Select Valid for Set Data Beat
assign rel_val_qsel_d = |(reld_q_set_val);

// Select Valid for Middle Data Beats
assign rel_val_mid_qsel = |(reld_q_mid_val);

// Reload Way Middle Data Beats
assign rel_wayA_mid = rel_way_mid_qsel[0] & rel3_data_stg_val_q & rel_val_mid_qsel;
assign rel_wayB_mid = rel_way_mid_qsel[1] & rel3_data_stg_val_q & rel_val_mid_qsel;
assign rel_wayC_mid = rel_way_mid_qsel[2] & rel3_data_stg_val_q & rel_val_mid_qsel;
assign rel_wayD_mid = rel_way_mid_qsel[3] & rel3_data_stg_val_q & rel_val_mid_qsel;
assign rel_wayE_mid = rel_way_mid_qsel[4] & rel3_data_stg_val_q & rel_val_mid_qsel;
assign rel_wayF_mid = rel_way_mid_qsel[5] & rel3_data_stg_val_q & rel_val_mid_qsel;
assign rel_wayG_mid = rel_way_mid_qsel[6] & rel3_data_stg_val_q & rel_val_mid_qsel;
assign rel_wayH_mid = rel_way_mid_qsel[7] & rel3_data_stg_val_q & rel_val_mid_qsel;

// Reload Way Set
assign rel_wayA_set = rel_way_qsel_q[0] & rel3_set_stg_val_q & rel_val_qsel_q;
assign rel_wayB_set = rel_way_qsel_q[1] & rel3_set_stg_val_q & rel_val_qsel_q;
assign rel_wayC_set = rel_way_qsel_q[2] & rel3_set_stg_val_q & rel_val_qsel_q;
assign rel_wayD_set = rel_way_qsel_q[3] & rel3_set_stg_val_q & rel_val_qsel_q;
assign rel_wayE_set = rel_way_qsel_q[4] & rel3_set_stg_val_q & rel_val_qsel_q;
assign rel_wayF_set = rel_way_qsel_q[5] & rel3_set_stg_val_q & rel_val_qsel_q;
assign rel_wayG_set = rel_way_qsel_q[6] & rel3_set_stg_val_q & rel_val_qsel_q;
assign rel_wayH_set = rel_way_qsel_q[7] & rel3_set_stg_val_q & rel_val_qsel_q;

assign rel4_dir_way_upd_d = {rel_wayA_set, rel_wayB_set, rel_wayC_set, rel_wayD_set,
                             rel_wayE_set, rel_wayF_set, rel_wayG_set, rel_wayH_set};

// ####################################################
// Execution Pipe Control
// Port0 => Execution Pipe
// ####################################################

// access is valid if its a cache_enabled op and not flushed or not a dcbt/dcbf type instruction
assign ex4_c_acc_d    = dcc_dir_ex3_cache_acc & (~(fgen_ex3_stg_flush | spr_xucr0_dcdis));
assign ex5_c_acc_d    = ex4_c_acc_q & (~derat_dir_ex4_wimge_i) & ex4_hit & ex4_lru_upd_q & (~fgen_ex4_stg_flush);
assign ex6_c_acc_d    = ex5_c_acc_q & (~fgen_ex5_stg_flush);
assign ex2_congr_cl   = ex2_eff_addr;
assign ex3_congr_cl_d = ex2_congr_cl;
assign ex4_congr_cl_d = ex3_congr_cl_q;
assign ex5_congr_cl_d = ex4_congr_cl_q;
assign ex6_congr_cl_d = ex5_congr_cl_q;
assign ex4_lru_upd_d  = dcc_dir_ex3_lru_upd;

// ####################################################
// Execution Pipe Directory Read
// ####################################################
// 1-hot Congruence Class Select
generate begin : ldpCClass
      genvar                            cclass;
      for (cclass=0; cclass<numCClass; cclass=cclass+1) begin : ldpCClass
         wire [uprCClassBit:lwrCClassBit]       cclassDummy=cclass;
         assign ex4_congr_cl_1hot[cclass] = (cclassDummy == ex4_congr_cl_q);
      end
   end
endgenerate

// Execution Path LRU Muxing

always @(*) begin: p0LruRd
   reg [0:lruState-1]                lruSel;

   (* analysis_not_referenced="true" *)

   integer                           cclass;
   lruSel = {lruState{1'b0}};
   for (cclass=0; cclass<numCClass; cclass=cclass+1)
      lruSel = (congr_cl_lru_q[cclass] & {lruState{ex4_congr_cl_1hot[cclass]}}) | lruSel;
   p0_arr_lru_rd <= lruSel;
end

// ####################################################
// Execution Pipe Bypass
// ####################################################
// ex4 Stage --> Bypass Logic
// ex4 congruence class matches valid ex5,ex6 or reload congruence class

assign congr_cl_ex4_ex5_cmp_d  = (ex3_congr_cl_q == ex4_congr_cl_q);
assign congr_cl_ex4_ex6_cmp_d  = (ex3_congr_cl_q == ex5_congr_cl_q);
assign congr_cl_ex4_stq3_cmp_d = (ex3_congr_cl_q == stq2_congr_cl_q);
assign congr_cl_ex4_stq4_cmp_d = (ex3_congr_cl_q == stq3_congr_cl_q);

assign congr_cl_ex4_ex5_m  = congr_cl_ex4_ex5_cmp_q & ex5_c_acc_q;
assign congr_cl_ex4_ex6_m  = congr_cl_ex4_ex6_cmp_q & ex6_c_acc_q;
assign congr_cl_ex4_stq3_m = congr_cl_ex4_stq3_cmp_q & stq3_val_wen;
assign congr_cl_ex4_stq4_m = congr_cl_ex4_stq4_cmp_q & stq4_val_wen_q;

// Bypass ex3 select
assign congr_cl_ex4_byp[0] = congr_cl_ex4_ex5_m;		// 1st priority
assign congr_cl_ex4_byp[1] = congr_cl_ex4_stq3_m;		// 2nd priority           <-- slowest of all of them
assign congr_cl_ex4_byp[2] = congr_cl_ex4_ex6_m;		// 3rd priority
assign congr_cl_ex4_byp[3] = congr_cl_ex4_stq4_m;		// 4th priority

assign congr_cl_ex4_sel[0] = congr_cl_ex4_byp[0];
assign congr_cl_ex4_sel[1] = congr_cl_ex4_byp[1] &  (~congr_cl_ex4_byp[0]);
assign congr_cl_ex4_sel[2] = congr_cl_ex4_byp[2] & ~(|congr_cl_ex4_byp[0:1]);
assign congr_cl_ex4_sel[3] = congr_cl_ex4_byp[3] & ~(|congr_cl_ex4_byp[0:2]);

assign ex4_lru_arr_sel = ~(|congr_cl_ex4_byp);

assign lq_congr_cl_lru_d = (ex5_lru_upd    & {lruState{congr_cl_ex4_sel[0]}}) |
                           (stq3_lru_upd   & {lruState{congr_cl_ex4_sel[1]}}) |
                           (ex6_lru_upd_q  & {lruState{congr_cl_ex4_sel[2]}}) |
                           (stq4_lru_upd_q & {lruState{congr_cl_ex4_sel[3]}}) |
                           (p0_arr_lru_rd  & {lruState{ex4_lru_arr_sel}});

// Bypassed LRU for Execution Pipe
assign lq_op_lru = lq_congr_cl_lru_q;

// ####################################################
// LRU update calculation due to an XU op
// ####################################################
// Updating the LRU using the Way that is being reloaded as the Way hit
assign hit_wayA_upd = {2'b11, lq_op_lru[2],   1'b1, lq_op_lru[4:6]};
assign hit_wayB_upd = {2'b11, lq_op_lru[2],   1'b0, lq_op_lru[4:6]};
assign hit_wayC_upd = {2'b10, lq_op_lru[2:3], 1'b1, lq_op_lru[5:6]};
assign hit_wayD_upd = {2'b10, lq_op_lru[2:3], 1'b0, lq_op_lru[5:6]};
assign hit_wayE_upd = {1'b0,  lq_op_lru[1],   1'b1, lq_op_lru[3:4], 1'b1, lq_op_lru[6]};
assign hit_wayF_upd = {1'b0,  lq_op_lru[1],   1'b1, lq_op_lru[3:4], 1'b0, lq_op_lru[6]};
assign hit_wayG_upd = {1'b0,  lq_op_lru[1],   1'b0, lq_op_lru[3:5], 1'b1};
assign hit_wayh_upd = {1'b0,  lq_op_lru[1],   1'b0, lq_op_lru[3:5], 1'b0};

// ####################################################
// Selecting between Execution Pipe
// ####################################################
// Selecting Way Hit Updated LRU
assign ldst_hit_vector_d = {ex4_way_hit_a, ex4_way_hit_b, ex4_way_hit_c, ex4_way_hit_d,
                            ex4_way_hit_e, ex4_way_hit_f, ex4_way_hit_g, ex4_way_hit_h};
assign ldst_hit_lru_upd = (hit_wayA_upd & {lruState{ldst_hit_vector_q[0]}}) | (hit_wayB_upd & {lruState{ldst_hit_vector_q[1]}}) |
                          (hit_wayC_upd & {lruState{ldst_hit_vector_q[2]}}) | (hit_wayD_upd & {lruState{ldst_hit_vector_q[3]}}) |
                          (hit_wayE_upd & {lruState{ldst_hit_vector_q[4]}}) | (hit_wayF_upd & {lruState{ldst_hit_vector_q[5]}}) |
                          (hit_wayG_upd & {lruState{ldst_hit_vector_q[6]}}) | (hit_wayh_upd & {lruState{ldst_hit_vector_q[7]}});

assign ex5_lru_upd   = ex5_c_acc_q ? ldst_hit_lru_upd : lq_op_lru;
assign ex6_lru_upd_d = ex5_lru_upd;

// ####################################################
// Upper Address Caculation
// ####################################################
// Reload Address Calculation
assign rel_way_dwen = {(rel_wayA_clr | rel_wayA_mid | stq_wayA_hit), (rel_wayB_clr | rel_wayB_mid | stq_wayB_hit),
                       (rel_wayC_clr | rel_wayC_mid | stq_wayC_hit), (rel_wayD_clr | rel_wayD_mid | stq_wayD_hit),
                       (rel_wayE_clr | rel_wayE_mid | stq_wayE_hit), (rel_wayF_clr | rel_wayF_mid | stq_wayF_hit),
                       (rel_wayG_clr | rel_wayG_mid | stq_wayG_hit), (rel_wayH_clr | rel_wayH_mid | stq_wayH_hit)};

assign dir_dcc_rel3_dcarr_upd = rel3_clr_stg_val_q | rel3_data_stg_val_q;
assign stq4_dcarr_way_en_d    = rel_way_dwen;
// ####################################################
// Directory LRU write enable generations
// ####################################################

// Congruence Class Update Act
assign congr_cl_act_d = ex5_c_acc_q | stq3_val_wen;

// Update LRU due to a Reload or an EX6 Execution operation
generate begin : lruUpd
      genvar                            cclass;
      for (cclass=0; cclass<numCClass; cclass=cclass+1) begin : lruUpd
         wire [uprCClassBit:lwrCClassBit]       cclassDummy=cclass;

         // LRU Update Control
         assign lq_op_cl_lru_wen[cclass] = (ex6_congr_cl_q  == cclassDummy) & ex6_c_acc_q;
         assign rel_cl_lru_wen[cclass]   = (stq4_congr_cl_q == cclassDummy) & stq4_val_wen_q;
         assign congr_cl_lru_wen[cclass] = lq_op_cl_lru_wen[cclass] | rel_cl_lru_wen[cclass];

         // Selecting LRU update
         assign rel_ldst_cl_lru[cclass] = ~lq_op_cl_lru_wen[cclass] ? stq4_lru_upd_q : ex6_lru_upd_q;

         // LRU update data
         assign congr_cl_lru_d[cclass] = congr_cl_lru_wen[cclass] ? rel_ldst_cl_lru[cclass] : congr_cl_lru_q[cclass];
      end
   end
endgenerate

// ####################################################
// Outputs
// ####################################################
assign rel_way_clr_a = rel_wayA_clr;
assign rel_way_clr_b = rel_wayB_clr;
assign rel_way_clr_c = rel_wayC_clr;
assign rel_way_clr_d = rel_wayD_clr;
assign rel_way_clr_e = rel_wayE_clr;
assign rel_way_clr_f = rel_wayF_clr;
assign rel_way_clr_g = rel_wayG_clr;
assign rel_way_clr_h = rel_wayH_clr;

assign rel_way_upd_a = rel4_dir_way_upd_q[0];
assign rel_way_upd_b = rel4_dir_way_upd_q[1];
assign rel_way_upd_c = rel4_dir_way_upd_q[2];
assign rel_way_upd_d = rel4_dir_way_upd_q[3];
assign rel_way_upd_e = rel4_dir_way_upd_q[4];
assign rel_way_upd_f = rel4_dir_way_upd_q[5];
assign rel_way_upd_g = rel4_dir_way_upd_q[6];
assign rel_way_upd_h = rel4_dir_way_upd_q[7];

assign rel_way_wen_a = rel_wayA_set;
assign rel_way_wen_b = rel_wayB_set;
assign rel_way_wen_c = rel_wayC_set;
assign rel_way_wen_d = rel_wayD_set;
assign rel_way_wen_e = rel_wayE_set;
assign rel_way_wen_f = rel_wayF_set;
assign rel_way_wen_g = rel_wayG_set;
assign rel_way_wen_h = rel_wayH_set;

assign dir_dcc_ex5_dir_lru = lq_op_lru;
assign stq4_dcarr_way_en   = stq4_dcarr_way_en_q;
assign lq_xu_spr_xucr0_clo = xucr0_clo_q;

assign rel3_dir_wr_val  = rel3_set_stg_val_q;
assign rel3_dir_wr_addr = stq3_congr_cl_q;

// ####################################################
// Directory LRU Registers
// ####################################################

// Congruence Class LRU
generate begin : congr_cl_lru
      genvar                            cclass;
      for (cclass=0; cclass<numCClass; cclass=cclass+1) begin : congr_cl_lru
         tri_rlmreg_p #(.WIDTH(lruState), .INIT(0), .NEEDS_SRESET(1)) congr_cl_lru_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(congr_cl_act_q),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[congr_cl_lru_offset + lruState*cclass:congr_cl_lru_offset + lruState*(cclass+1) - 1]),
            .scout(sov[congr_cl_lru_offset + lruState*cclass:congr_cl_lru_offset + lruState*(cclass+1) - 1]),
            .din(congr_cl_lru_d[cclass]),
            .dout(congr_cl_lru_q[cclass])
         );
      end
   end
endgenerate


tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) rel2_xucr2_rmt_reg(
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
   .scin(siv[rel2_xucr2_rmt_offset:rel2_xucr2_rmt_offset + 32 - 1]),
   .scout(sov[rel2_xucr2_rmt_offset:rel2_xucr2_rmt_offset + 32 - 1]),
   .din(rel2_xucr2_rmt_d),
   .dout(rel2_xucr2_rmt_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_wlk_reg(
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
   .scin(siv[spr_xucr0_wlk_offset]),
   .scout(sov[spr_xucr0_wlk_offset]),
   .din(spr_xucr0_wlk_d),
   .dout(spr_xucr0_wlk_q)
);


tri_rlmreg_p #(.WIDTH(lruState), .INIT(0), .NEEDS_SRESET(1)) lq_congr_cl_lru_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_ex4_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq_congr_cl_lru_offset:lq_congr_cl_lru_offset + lruState - 1]),
   .scout(sov[lq_congr_cl_lru_offset:lq_congr_cl_lru_offset + lruState - 1]),
   .din(lq_congr_cl_lru_d),
   .dout(lq_congr_cl_lru_q)
);


tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) ldst_hit_vector_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_ex4_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldst_hit_vector_offset:ldst_hit_vector_offset + numWays - 1]),
   .scout(sov[ldst_hit_vector_offset:ldst_hit_vector_offset + numWays - 1]),
   .din(ldst_hit_vector_d),
   .dout(ldst_hit_vector_q)
);


tri_rlmreg_p #(.WIDTH(lruState), .INIT(0), .NEEDS_SRESET(1)) rel_congr_cl_lru_reg(
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
   .scin(siv[rel_congr_cl_lru_offset:rel_congr_cl_lru_offset + lruState - 1]),
   .scout(sov[rel_congr_cl_lru_offset:rel_congr_cl_lru_offset + lruState - 1]),
   .din(rel_congr_cl_lru_d),
   .dout(rel_congr_cl_lru_q)
);


tri_rlmreg_p #(.WIDTH(numCClassWidth), .INIT(0), .NEEDS_SRESET(1)) ex3_congr_cl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_ex2_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_congr_cl_offset:ex3_congr_cl_offset + numCClassWidth - 1]),
   .scout(sov[ex3_congr_cl_offset:ex3_congr_cl_offset + numCClassWidth - 1]),
   .din(ex3_congr_cl_d),
   .dout(ex3_congr_cl_q)
);


tri_rlmreg_p #(.WIDTH(numCClassWidth), .INIT(0), .NEEDS_SRESET(1)) ex4_congr_cl_reg(
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
   .scin(siv[ex4_congr_cl_offset:ex4_congr_cl_offset + numCClassWidth - 1]),
   .scout(sov[ex4_congr_cl_offset:ex4_congr_cl_offset + numCClassWidth - 1]),
   .din(ex4_congr_cl_d),
   .dout(ex4_congr_cl_q)
);


tri_rlmreg_p #(.WIDTH(numCClassWidth), .INIT(0), .NEEDS_SRESET(1)) ex5_congr_cl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_ex4_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_congr_cl_offset:ex5_congr_cl_offset + numCClassWidth - 1]),
   .scout(sov[ex5_congr_cl_offset:ex5_congr_cl_offset + numCClassWidth - 1]),
   .din(ex5_congr_cl_d),
   .dout(ex5_congr_cl_q)
);


tri_rlmreg_p #(.WIDTH(numCClassWidth), .INIT(0), .NEEDS_SRESET(1)) ex6_congr_cl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_ex5_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_congr_cl_offset:ex6_congr_cl_offset + numCClassWidth - 1]),
   .scout(sov[ex6_congr_cl_offset:ex6_congr_cl_offset + numCClassWidth - 1]),
   .din(ex6_congr_cl_d),
   .dout(ex6_congr_cl_q)
);


tri_rlmreg_p #(.WIDTH(numCClassWidth), .INIT(0), .NEEDS_SRESET(1)) stq2_congr_cl_reg(
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
   .scin(siv[stq2_congr_cl_offset:stq2_congr_cl_offset + numCClassWidth - 1]),
   .scout(sov[stq2_congr_cl_offset:stq2_congr_cl_offset + numCClassWidth - 1]),
   .din(stq2_congr_cl_d),
   .dout(stq2_congr_cl_q)
);


tri_rlmreg_p #(.WIDTH(numCClassWidth), .INIT(0), .NEEDS_SRESET(1)) stq3_congr_cl_reg(
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
   .scin(siv[stq3_congr_cl_offset:stq3_congr_cl_offset + numCClassWidth - 1]),
   .scout(sov[stq3_congr_cl_offset:stq3_congr_cl_offset + numCClassWidth - 1]),
   .din(stq3_congr_cl_d),
   .dout(stq3_congr_cl_q)
);


tri_rlmreg_p #(.WIDTH(numCClassWidth), .INIT(0), .NEEDS_SRESET(1)) stq4_congr_cl_reg(
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
   .scin(siv[stq4_congr_cl_offset:stq4_congr_cl_offset + numCClassWidth - 1]),
   .scout(sov[stq4_congr_cl_offset:stq4_congr_cl_offset + numCClassWidth - 1]),
   .din(stq4_congr_cl_d),
   .dout(stq4_congr_cl_q)
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


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex4_ex5_cmp_reg(
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
   .scin(siv[congr_cl_ex4_ex5_cmp_offset]),
   .scout(sov[congr_cl_ex4_ex5_cmp_offset]),
   .din(congr_cl_ex4_ex5_cmp_d),
   .dout(congr_cl_ex4_ex5_cmp_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex4_ex6_cmp_reg(
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
   .scin(siv[congr_cl_ex4_ex6_cmp_offset]),
   .scout(sov[congr_cl_ex4_ex6_cmp_offset]),
   .din(congr_cl_ex4_ex6_cmp_d),
   .dout(congr_cl_ex4_ex6_cmp_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex4_stq3_cmp_reg(
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
   .scin(siv[congr_cl_ex4_stq3_cmp_offset]),
   .scout(sov[congr_cl_ex4_stq3_cmp_offset]),
   .din(congr_cl_ex4_stq3_cmp_d),
   .dout(congr_cl_ex4_stq3_cmp_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_ex4_stq4_cmp_reg(
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
   .scin(siv[congr_cl_ex4_stq4_cmp_offset]),
   .scout(sov[congr_cl_ex4_stq4_cmp_offset]),
   .din(congr_cl_ex4_stq4_cmp_d),
   .dout(congr_cl_ex4_stq4_cmp_q)
);


tri_rlmreg_p #(.WIDTH(lruState), .INIT(0), .NEEDS_SRESET(1)) ex6_lru_upd_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(dcc_dir_ex5_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_lru_upd_offset:ex6_lru_upd_offset + lruState - 1]),
   .scout(sov[ex6_lru_upd_offset:ex6_lru_upd_offset + lruState - 1]),
   .din(ex6_lru_upd_d),
   .dout(ex6_lru_upd_q)
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


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel2_data_stg_val_reg(
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
   .scin(siv[rel2_data_stg_val_offset]),
   .scout(sov[rel2_data_stg_val_offset]),
   .din(rel2_data_stg_val_d),
   .dout(rel2_data_stg_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel3_data_stg_val_reg(
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
   .scin(siv[rel3_data_stg_val_offset]),
   .scout(sov[rel3_data_stg_val_offset]),
   .din(rel3_data_stg_val_d),
   .dout(rel3_data_stg_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_c_acc_reg(
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
   .scin(siv[ex4_c_acc_offset]),
   .scout(sov[ex4_c_acc_offset]),
   .din(ex4_c_acc_d),
   .dout(ex4_c_acc_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_c_acc_reg(
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
   .scin(siv[ex5_c_acc_offset]),
   .scout(sov[ex5_c_acc_offset]),
   .din(ex5_c_acc_d),
   .dout(ex5_c_acc_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_c_acc_reg(
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
   .scin(siv[ex6_c_acc_offset]),
   .scout(sov[ex6_c_acc_offset]),
   .din(ex6_c_acc_d),
   .dout(ex6_c_acc_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_val_wen_reg(
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
   .scin(siv[stq4_val_wen_offset]),
   .scout(sov[stq4_val_wen_offset]),
   .din(stq4_val_wen_d),
   .dout(stq4_val_wen_q)
);


tri_rlmreg_p #(.WIDTH(lruState), .INIT(0), .NEEDS_SRESET(1)) stq4_lru_upd_reg(
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
   .scin(siv[stq4_lru_upd_offset:stq4_lru_upd_offset + lruState - 1]),
   .scout(sov[stq4_lru_upd_offset:stq4_lru_upd_offset + lruState - 1]),
   .din(stq4_lru_upd_d),
   .dout(stq4_lru_upd_q)
);


tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) rel2_rel_tag_reg(
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
   .scin(siv[rel2_rel_tag_offset:rel2_rel_tag_offset + 4 - 1]),
   .scout(sov[rel2_rel_tag_offset:rel2_rel_tag_offset + 4 - 1]),
   .din(rel2_rel_tag_d),
   .dout(rel2_rel_tag_q)
);


tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) rel3_rel_tag_reg(
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
   .scin(siv[rel3_rel_tag_offset:rel3_rel_tag_offset + 4 - 1]),
   .scout(sov[rel3_rel_tag_offset:rel3_rel_tag_offset + 4 - 1]),
   .din(rel3_rel_tag_d),
   .dout(rel3_rel_tag_q)
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


tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) rel3_wlock_reg(
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
   .scin(siv[rel3_wlock_offset:rel3_wlock_offset + numWays - 1]),
   .scout(sov[rel3_wlock_offset:rel3_wlock_offset + numWays - 1]),
   .din(rel3_wlock_d),
   .dout(rel3_wlock_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) reld_q_sel_reg(
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
   .scin(siv[reld_q_sel_offset:reld_q_sel_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[reld_q_sel_offset:reld_q_sel_offset + `LMQ_ENTRIES - 1]),
   .din(reld_q_sel_d),
   .dout(reld_q_sel_q)
);


tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) rel_way_qsel_reg(
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
   .scin(siv[rel_way_qsel_offset:rel_way_qsel_offset + numWays - 1]),
   .scout(sov[rel_way_qsel_offset:rel_way_qsel_offset + numWays - 1]),
   .din(rel_way_qsel_d),
   .dout(rel_way_qsel_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel_val_qsel_reg(
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
   .scin(siv[rel_val_qsel_offset]),
   .scout(sov[rel_val_qsel_offset]),
   .din(rel_val_qsel_d),
   .dout(rel_val_qsel_q)
);


tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) rel4_dir_way_upd_reg(
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
   .scin(siv[rel4_dir_way_upd_offset:rel4_dir_way_upd_offset + numWays - 1]),
   .scout(sov[rel4_dir_way_upd_offset:rel4_dir_way_upd_offset + numWays - 1]),
   .din(rel4_dir_way_upd_d),
   .dout(rel4_dir_way_upd_q)
);

generate begin : reld_q_congr_cl
      genvar                            lmq0;
      for (lmq0=0; lmq0<`LMQ_ENTRIES; lmq0=lmq0+1) begin : reld_q_congr_cl
         tri_rlmreg_p #(.WIDTH(numCClassWidth), .INIT(0), .NEEDS_SRESET(1)) reld_q_congr_cl_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(reld_q_set[lmq0]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[reld_q_congr_cl_offset + numCClassWidth*lmq0:reld_q_congr_cl_offset + numCClassWidth*(lmq0+1) - 1]),
            .scout(sov[reld_q_congr_cl_offset + numCClassWidth*lmq0:reld_q_congr_cl_offset + numCClassWidth*(lmq0+1) - 1]),
            .din(reld_q_congr_cl_d[lmq0]),
            .dout(reld_q_congr_cl_q[lmq0])
         );
      end
   end
endgenerate

generate begin : reld_q_way
      genvar                            lmq1;
      for (lmq1=0; lmq1<`LMQ_ENTRIES; lmq1=lmq1+1) begin : reld_q_way
         tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) reld_q_way_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(reld_q_set[lmq1]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[reld_q_way_offset + (numWays * lmq1):reld_q_way_offset + (numWays * (lmq1 + 1)) - 1]),
            .scout(sov[reld_q_way_offset + (numWays * lmq1):reld_q_way_offset + (numWays * (lmq1 + 1)) - 1]),
            .din(reld_q_way_d[lmq1]),
            .dout(reld_q_way_q[lmq1])
         );
      end
   end
endgenerate


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) reld_q_val_reg(
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
   .scin(siv[reld_q_val_offset:reld_q_val_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[reld_q_val_offset:reld_q_val_offset + `LMQ_ENTRIES - 1]),
   .din(reld_q_val_d),
   .dout(reld_q_val_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) reld_q_lock_reg(
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
   .scin(siv[reld_q_lock_offset:reld_q_lock_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[reld_q_lock_offset:reld_q_lock_offset + `LMQ_ENTRIES - 1]),
   .din(reld_q_lock_d),
   .dout(reld_q_lock_q)
);


tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) rel3_m_q_way_reg(
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
   .scin(siv[rel3_m_q_way_offset:rel3_m_q_way_offset + numWays - 1]),
   .scout(sov[rel3_m_q_way_offset:rel3_m_q_way_offset + numWays - 1]),
   .din(rel3_m_q_way_d),
   .dout(rel3_m_q_way_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_lru_upd_reg(
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
   .scin(siv[ex4_lru_upd_offset]),
   .scout(sov[ex4_lru_upd_offset]),
   .din(ex4_lru_upd_d),
   .dout(ex4_lru_upd_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel2_lock_en_reg(
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
   .scin(siv[rel2_lock_en_offset]),
   .scout(sov[rel2_lock_en_offset]),
   .din(rel2_lock_en_d),
   .dout(rel2_lock_en_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel3_lock_en_reg(
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
   .scin(siv[rel3_lock_en_offset]),
   .scout(sov[rel3_lock_en_offset]),
   .din(rel3_lock_en_d),
   .dout(rel3_lock_en_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xucr0_clo_reg(
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
   .scin(siv[xucr0_clo_offset]),
   .scout(sov[xucr0_clo_offset]),
   .din(xucr0_clo_d),
   .dout(xucr0_clo_q)
);


tri_rlmreg_p #(.WIDTH(numWays), .INIT(0), .NEEDS_SRESET(1)) stq4_dcarr_way_en_reg(
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
   .scin(siv[stq4_dcarr_way_en_offset:stq4_dcarr_way_en_offset + numWays - 1]),
   .scout(sov[stq4_dcarr_way_en_offset:stq4_dcarr_way_en_offset + numWays - 1]),
   .din(stq4_dcarr_way_en_d),
   .dout(stq4_dcarr_way_en_q)
);


tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) stq2_class_id_reg(
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
   .scin(siv[stq2_class_id_offset:stq2_class_id_offset + 2 - 1]),
   .scout(sov[stq2_class_id_offset:stq2_class_id_offset + 2 - 1]),
   .din(stq2_class_id_d),
   .dout(stq2_class_id_q)
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


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) congr_cl_act_reg(
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
   .scin(siv[congr_cl_act_offset]),
   .scout(sov[congr_cl_act_offset]),
   .din(congr_cl_act_d),
   .dout(congr_cl_act_q)
);

assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
assign scan_out = sov[0];

endmodule
