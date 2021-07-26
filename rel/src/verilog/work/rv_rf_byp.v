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

//  Description:  A2O Bypass Control
//
//*****************************************************************************

module rv_rf_byp(

`include "tri_a2o.vh"

   //-------------------------------------------------------------------
   // Completion flush
   //-------------------------------------------------------------------
   input [0:`THREADS-1]                            cp_flush,

   //-------------------------------------------------------------------
   // Interface with RV
   //-------------------------------------------------------------------
   input [0:`THREADS-1] 			   rv_byp_fx0_vld,		// FX0 Ports
   input [0:`ITAG_SIZE_ENC-1] 			   rv_byp_fx0_itag,
   input [0:3] 					   rv_byp_fx0_ilat,
   input 					   rv_byp_fx0_ord,
   input 					   rv_byp_fx0_t1_v,
   input [0:2] 					   rv_byp_fx0_t1_t,
   input 					   rv_byp_fx0_t2_v,
   input [0:2] 					   rv_byp_fx0_t2_t,
   input 					   rv_byp_fx0_t3_v,
   input [0:2] 					   rv_byp_fx0_t3_t,
   input [0:2] 					   rv_byp_fx0_s1_t,
   input [0:2] 					   rv_byp_fx0_s2_t,
   input [0:2] 					   rv_byp_fx0_s3_t,
   input                                           rv_byp_fx0_ex0_is_brick,

   input [0:`THREADS-1] 			   rv_byp_fx0_ilat0_vld,
   input [0:`THREADS-1] 			   rv_byp_fx0_ilat1_vld,

   input [0:`THREADS-1] 			   rv_byp_lq_vld,		// LQ Ports
   input 					   rv_byp_lq_t1_v,
   input 					   rv_byp_lq_t3_v,
   input [0:2] 					   rv_byp_lq_t3_t,
   input [0:2] 					   rv_byp_lq_s1_t,
   input [0:2] 					   rv_byp_lq_s2_t,
   input [0:`ITAG_SIZE_ENC-1] 			   rv_byp_lq_ex0_s1_itag,
   input [0:`ITAG_SIZE_ENC-1] 			   rv_byp_lq_ex0_s2_itag,
   input [0:`THREADS-1] 			   rv_byp_fx1_vld,		// FX1 Ports
   input [0:`ITAG_SIZE_ENC-1] 			   rv_byp_fx1_itag,
   (* analysis_not_referenced="<0>true" *)
   input [0:3] 					   rv_byp_fx1_ilat,
   input 					   rv_byp_fx1_t1_v,
   input 					   rv_byp_fx1_t2_v,
   input 					   rv_byp_fx1_t3_v,
   input [0:2] 					   rv_byp_fx1_s1_t,
   input [0:2] 					   rv_byp_fx1_s2_t,
   input [0:2] 					   rv_byp_fx1_s3_t,
   input 					   rv_byp_fx1_ex0_isStore,
   input [0:`THREADS-1] 			   rv_byp_fx1_ilat0_vld,
   input [0:`THREADS-1] 			   rv_byp_fx1_ilat1_vld,

   //-------------------------------------------------------------------
   // Interface with FXU0
   //-------------------------------------------------------------------
   output [1:11] 	    rv_fx0_ex0_s1_fx0_sel,
   output [1:11] 	    rv_fx0_ex0_s2_fx0_sel,
   output [1:11] 	    rv_fx0_ex0_s3_fx0_sel,
   output [4:8]             rv_fx0_ex0_s1_lq_sel,
   output [4:8]             rv_fx0_ex0_s2_lq_sel,
   output [4:8]             rv_fx0_ex0_s3_lq_sel,
   output [1:6] 	    rv_fx0_ex0_s1_fx1_sel,
   output [1:6] 	    rv_fx0_ex0_s2_fx1_sel,
   output [1:6] 	    rv_fx0_ex0_s3_fx1_sel,

   //-------------------------------------------------------------------
   // Interface with LQ
   //-------------------------------------------------------------------
   output [2:12] 	    rv_lq_ex0_s1_fx0_sel,
   output [2:12] 	    rv_lq_ex0_s2_fx0_sel,
   output [4:8]             rv_lq_ex0_s1_lq_sel,
   output [4:8]             rv_lq_ex0_s2_lq_sel,
   output [2:7] 	    rv_lq_ex0_s1_fx1_sel,
   output [2:7] 	    rv_lq_ex0_s2_fx1_sel,

   //-------------------------------------------------------------------
   // Interface with FXU1
   //-------------------------------------------------------------------
   output [1:11] 	    rv_fx1_ex0_s1_fx0_sel,
   output [1:11] 	    rv_fx1_ex0_s2_fx0_sel,
   output [1:11] 	    rv_fx1_ex0_s3_fx0_sel,
   output [4:8]             rv_fx1_ex0_s1_lq_sel,
   output [4:8]             rv_fx1_ex0_s2_lq_sel,
   output [4:8]             rv_fx1_ex0_s3_lq_sel,
   output [1:6] 	    rv_fx1_ex0_s1_fx1_sel,
   output [1:6] 	    rv_fx1_ex0_s2_fx1_sel,
   output [1:6] 	    rv_fx1_ex0_s3_fx1_sel,

   output [2:3]             rv_fx0_ex0_s1_rel_sel,
   output [2:3]             rv_fx0_ex0_s2_rel_sel,
   output [2:3]             rv_fx0_ex0_s3_rel_sel,
   output [2:3]             rv_lq_ex0_s1_rel_sel,
   output [2:3]             rv_lq_ex0_s2_rel_sel,
   output [2:3]             rv_fx1_ex0_s1_rel_sel,
   output [2:3]             rv_fx1_ex0_s2_rel_sel,
   output [2:3]             rv_fx1_ex0_s3_rel_sel,

   //-------------------------------------------------------------------
   // FX0 RV Release / Spec Flush
   //-------------------------------------------------------------------
   output [0:`THREADS-1] 			    fx0_rv_itag_vld,
   output  		                 	    fx0_rv_itag_abort,
   output [0:`ITAG_SIZE_ENC-1] 			    fx0_rv_itag,
   output [0:`THREADS-1] 			    fx0_release_ord_hold,

   output [0:`THREADS-1] 			    fx0_rv_ext_itag_vld,
   output  		                 	    fx0_rv_ext_itag_abort,
   output [0:`ITAG_SIZE_ENC-1] 			    fx0_rv_ext_itag,

   input 					    fx0_rv_ord_complete,
   input [0:`THREADS-1] 			    fx0_rv_ord_tid,
   input [0:`ITAG_SIZE_ENC-1] 			    fx0_rv_ord_itag,

   input [0:`ITAG_SIZE_ENC-1] 			    rv_fx0_s1_itag,
   input [0:`ITAG_SIZE_ENC-1] 			    rv_fx0_s2_itag,
   input [0:`ITAG_SIZE_ENC-1] 			    rv_fx0_s3_itag,

   input                                            fx0_rv_ex2_s1_abort,
   input                                            fx0_rv_ex2_s2_abort,
   input                                            fx0_rv_ex2_s3_abort,

   //-------------------------------------------------------------------
   // FX1 RV Release / Spec Flush
   //-------------------------------------------------------------------
   output [0:`THREADS-1] 			    fx1_rv_itag_vld,
   output  		                 	    fx1_rv_itag_abort,
   output [0:`ITAG_SIZE_ENC-1] 			    fx1_rv_itag,

   output [0:`THREADS-1] 			    fx1_rv_ext_itag_vld,
   output  		                 	    fx1_rv_ext_itag_abort,
   output [0:`ITAG_SIZE_ENC-1] 			    fx1_rv_ext_itag,


   input [0:`ITAG_SIZE_ENC-1] 			    rv_fx1_s1_itag,
   input [0:`ITAG_SIZE_ENC-1] 			    rv_fx1_s2_itag,
   input [0:`ITAG_SIZE_ENC-1] 			    rv_fx1_s3_itag,

   input                                            fx1_rv_ex2_s1_abort,
   input                                            fx1_rv_ex2_s2_abort,
   input                                            fx1_rv_ex2_s3_abort,

   //-------------------------------------------------------------------
   // LQ Release and Restart
   //-------------------------------------------------------------------
   input [0:`ITAG_SIZE_ENC-1] 			    rv_byp_lq_itag,

   input [0:`THREADS-1] 			    lq_rv_itag2_vld,
   input [0:`ITAG_SIZE_ENC-1] 			    lq_rv_itag2,

   //-------------------------------------------------------------------
   // Clocks & Power
   //-------------------------------------------------------------------
   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) // nclk
   input [0:`NCLK_WIDTH-1] 			    nclk,
   inout 					    vdd,
   inout 					    gnd,

   //-------------------------------------------------------------------
   // Pervasive
   //-------------------------------------------------------------------
   input 					    func_sl_thold_1,
   input 					    sg_1,
   input 					    clkoff_b,
   input 					    act_dis,
   input 					    ccflush_dc,
   input 					    delay_lclkr,
   input 					    mpw1_b,
   input 					    mpw2_b,
   input 					    scan_in,

   output 					    scan_out
		 );



   //------------------------------------------------------------------------------------------------------------
   // Pervasive
   //------------------------------------------------------------------------------------------------------------
   parameter                                      tiup = 1'b1;
   parameter                                      tidn = 1'b0;

   parameter                                      elmnt_width = 3 + `THREADS;		// Valid (1) + max_pool_enc (6) + Type (3) = 10, or max_pool_enc + 4


   //-------------------------------------------------------------------
   // Signals
   //-------------------------------------------------------------------
   wire 					    d_mode;
   wire [0:2] 					    rv_byp_fx1_t2_t;
   wire [0:2] 					    rv_byp_fx1_t3_t;

   wire [1:11]      fx0_ex0_s1_fx0_sel;
   wire [1:11]      fx0_ex0_s2_fx0_sel;
   wire [1:11]      fx0_ex0_s3_fx0_sel;
   wire [1:11]	    fxu0_s1_fxu0_itag_match;
   wire [1:11]	    fxu0_s2_fxu0_itag_match;
   wire [1:11] 	    fxu0_s3_fxu0_itag_match;
   wire [1:6] 	    fx0_ex0_s1_fx1_sel;
   wire [1:6] 	    fx0_ex0_s2_fx1_sel;
   wire [1:6] 	    fx0_ex0_s3_fx1_sel;
   wire [1:6] 	    fxu0_s1_fxu1_itag_match;
   wire [1:6] 	    fxu0_s2_fxu1_itag_match;
   wire [1:6] 	    fxu0_s3_fxu1_itag_match;
   wire [4:8] 	    fxu0_s1_lq_itag_match;
   wire [4:8] 	    fxu0_s2_lq_itag_match;
   wire [4:8] 	    fxu0_s3_lq_itag_match;
   wire [1:11] 	    fxu0_s1_fxu0_t1_match;
   wire [1:11] 	    fxu0_s1_fxu0_t2_match;
   wire [1:11] 	    fxu0_s1_fxu0_t3_match;
   wire [1:11] 	    fxu0_s2_fxu0_t1_match;
   wire [1:11] 	    fxu0_s2_fxu0_t2_match;
   wire [1:11] 	    fxu0_s2_fxu0_t3_match;
   wire [1:11] 	    fxu0_s3_fxu0_t1_match;
   wire [1:11] 	    fxu0_s3_fxu0_t2_match;
   wire [1:11] 	    fxu0_s3_fxu0_t3_match;
   wire [4:8] 	    fxu0_s1_lq_t1_match;
   wire [4:8] 	    fxu0_s1_lq_t2_match;
   wire [4:8] 	    fxu0_s1_lq_t3_match;
   wire [4:8] 	    fxu0_s2_lq_t1_match;
   wire [4:8] 	    fxu0_s2_lq_t2_match;
   wire [4:8] 	    fxu0_s2_lq_t3_match;
   wire [4:8] 	    fxu0_s3_lq_t1_match;
   wire [4:8] 	    fxu0_s3_lq_t2_match;
   wire [4:8] 	    fxu0_s3_lq_t3_match;
   wire [1:6] 	    fxu0_s1_fxu1_t1_match;
   wire [1:6] 	    fxu0_s1_fxu1_t2_match;
   wire [1:6] 	    fxu0_s1_fxu1_t3_match;
   wire [1:6] 	    fxu0_s2_fxu1_t1_match;
   wire [1:6] 	    fxu0_s2_fxu1_t2_match;
   wire [1:6] 	    fxu0_s2_fxu1_t3_match;
   wire [1:6] 	    fxu0_s3_fxu1_t1_match;
   wire [1:6] 	    fxu0_s3_fxu1_t2_match;
   wire [1:6] 	    fxu0_s3_fxu1_t3_match;

   wire [2:12] 	    lq_ex0_s1_fx0_sel;
   wire [2:12] 	    lq_ex0_s2_fx0_sel;
   wire [2:12]	    lq_s1_fxu0_itag_match;
   wire [2:12] 	    lq_s2_fxu0_itag_match;
   wire [2:7] 	    lq_s1_fxu1_itag_match;
   wire [2:7] 	    lq_s2_fxu1_itag_match;
   wire [4:8] 	    lq_s1_lq_itag_match;
   wire [4:8] 	    lq_s2_lq_itag_match;
   wire [2:12] 	    lq_s1_fxu0_t1_match;
   wire [2:12] 	    lq_s1_fxu0_t2_match;
   wire [2:12] 	    lq_s1_fxu0_t3_match;
   wire [2:12] 	    lq_s2_fxu0_t1_match;
   wire [2:12] 	    lq_s2_fxu0_t2_match;
   wire [2:12] 	    lq_s2_fxu0_t3_match;
   wire [4:8] 	    lq_s1_lq_t1_match;
   wire [4:8] 	    lq_s1_lq_t2_match;
   wire [4:8] 	    lq_s1_lq_t3_match;
   wire [4:8] 	    lq_s2_lq_t1_match;
   wire [4:8] 	    lq_s2_lq_t2_match;
   wire [4:8] 	    lq_s2_lq_t3_match;
   wire [2:7] 	    lq_ex0_s1_fx1_sel;
   wire [2:7] 	    lq_ex0_s2_fx1_sel;
   wire [2:7] 	    lq_s1_fxu1_t1_match;
   wire [2:7] 	    lq_s1_fxu1_t2_match;
   wire [2:7] 	    lq_s1_fxu1_t3_match;
   wire [2:7] 	    lq_s2_fxu1_t1_match;
   wire [2:7] 	    lq_s2_fxu1_t2_match;
   wire [2:7] 	    lq_s2_fxu1_t3_match;
   wire [1:11]      fx1_ex0_s1_fx0_sel;
   wire [1:11]      fx1_ex0_s2_fx0_sel;
   wire [1:11]      fx1_ex0_s3_fx0_sel;
   wire [1:11] 	    fxu1_s1_fxu0_itag_match;
   wire [1:11] 	    fxu1_s2_fxu0_itag_match;
   wire [1:11] 	    fxu1_s3_fxu0_itag_match;
   wire [1:6] 	    fx1_ex0_s1_fx1_sel;
   wire [1:6] 	    fx1_ex0_s2_fx1_sel;
   wire [1:6] 	    fx1_ex0_s3_fx1_sel;
   wire [1:6] 	    fxu1_s1_fxu1_itag_match;
   wire [1:6] 	    fxu1_s2_fxu1_itag_match;
   wire [1:6] 	    fxu1_s3_fxu1_itag_match;
   wire [4:8] 	    fxu1_s1_lq_itag_match;
   wire [4:8] 	    fxu1_s2_lq_itag_match;
   wire [4:8] 	    fxu1_s3_lq_itag_match;
   wire [1:11] 	    fxu1_s1_fxu0_t1_match;
   wire [1:11] 	    fxu1_s1_fxu0_t2_match;
   wire [1:11] 	    fxu1_s1_fxu0_t3_match;
   wire [1:11] 	    fxu1_s2_fxu0_t1_match;
   wire [1:11] 	    fxu1_s2_fxu0_t2_match;
   wire [1:11] 	    fxu1_s2_fxu0_t3_match;
   wire [1:11] 	    fxu1_s3_fxu0_t1_match;
   wire [1:11] 	    fxu1_s3_fxu0_t2_match;
   wire [1:11] 	    fxu1_s3_fxu0_t3_match;
   wire [4:8]     fxu1_s1_lq_t1_match;
   wire [4:8]     fxu1_s1_lq_t2_match;
   wire [4:8]     fxu1_s1_lq_t3_match;
   wire [4:8]     fxu1_s2_lq_t1_match;
   wire [4:8]     fxu1_s2_lq_t2_match;
   wire [4:8]     fxu1_s2_lq_t3_match;
   wire [4:8]     fxu1_s3_lq_t1_match;
   wire [4:8]     fxu1_s3_lq_t2_match;
   wire [4:8]     fxu1_s3_lq_t3_match;
   wire [1:6] 	    fxu1_s1_fxu1_t1_match;
   wire [1:6] 	    fxu1_s1_fxu1_t2_match;
   wire [1:6] 	    fxu1_s1_fxu1_t3_match;
   wire [1:6] 	    fxu1_s2_fxu1_t1_match;
   wire [1:6] 	    fxu1_s2_fxu1_t2_match;
   wire [1:6] 	    fxu1_s2_fxu1_t3_match;
   wire [1:6] 	    fxu1_s3_fxu1_t1_match;
   wire [1:6] 	    fxu1_s3_fxu1_t2_match;
   wire [1:6] 	    fxu1_s3_fxu1_t3_match;

   wire [2:3]     fxu0_s1_rel_itag_match;
   wire [2:3]     fxu0_s2_rel_itag_match;
   wire [2:3]     fxu0_s3_rel_itag_match;
   wire [2:3]     fxu0_s1_rel_match;
   wire [2:3]     fxu0_s2_rel_match;
   wire [2:3]     fxu0_s3_rel_match;
   wire [2:3]     fxu1_s1_rel_itag_match;
   wire [2:3]     fxu1_s2_rel_itag_match;
   wire [2:3]     fxu1_s3_rel_itag_match;
   wire [2:3]     fxu1_s1_rel_match;
   wire [2:3]     fxu1_s2_rel_match;
   wire [2:3]     fxu1_s3_rel_match;
   wire [2:3]     lq_s1_rel_itag_match;
   wire [2:3]     lq_s2_rel_itag_match;
   wire [2:3]     lq_s1_rel_match;
   wire [2:3]     lq_s2_rel_match;

   wire 					    fx0_rv1_ilat_match;
   wire 					    fx0_ex0_fast_match;
   wire 					    fx0_ex0_ilat_match;
   wire 					    fx0_ex1_ilat_match;
   wire 					    fx0_ex2_ilat_match;
   wire 					    fx0_ex3_ilat_match;
   wire 					    fx0_ex4_ilat_match;

   wire [0:9] 					    fx0_ex0_sched_rel;
   wire [0:9] 					    fx0_ex0_sched_rel_pri;
   wire 					    fx0_rv1_ilat0;
   wire 					    fx0_sched_rel_rv;
   wire 					    fx0_sched_rel_rv_ilat0;
   wire 					    fx0_sched_rel_ex0_fast;
   wire 					    fx0_ex0_stq_pipe_val;
   wire 					    fx0_insert_ord;

   wire 					    fx0_ex2_abort;
   wire 					    fx0_rel_itag_abort_d;
   wire 					    fx0_rel_itag_abort_q;
   wire 					    fx0_ext_rel_itag_abort_d;
   wire 					    fx0_ext_rel_itag_abort_q;
   wire 					    fx0_rv_itag_abort_int;
   wire [3:4] 					    fx0_abort_d;
   wire [3:4] 					    fx0_abort_q;

   wire 					    fx1_ex2_abort;
   wire 					    fx1_rel_itag_abort_d;
   wire 					    fx1_rel_itag_abort_q;
   wire 					    fx1_ext_rel_itag_abort_d;
   wire 					    fx1_ext_rel_itag_abort_q;
   wire 					    fx1_rv_itag_abort_int;
   wire [3:4] 					    fx1_abort_d;
   wire [3:4] 					    fx1_abort_q;


   wire 					    fx1_rv1_ilat_match;
   wire 					    fx1_ex0_fast_match;
   wire 					    fx1_ex0_ilat_match;
   wire 					    fx1_ex1_ilat_match;
   wire 					    fx1_ex2_ilat_match;
   wire 					    fx1_ex3_ilat_match;

   wire [0:4] 					    fx1_ex0_sched_rel;
   wire [0:4] 					    fx1_ex0_sched_rel_pri;
   wire 					    fx1_rv1_ilat0;
   wire 					    fx1_sched_rel_rv;
   wire 					    fx1_sched_rel_rv_ilat0;
   wire 					    fx1_sched_rel_ex0_fast;
   wire 					    fx1_ex0_stq_pipe_val;

   wire [0:`ITAG_SIZE_ENC-1] 			    fx0_ex0_s1_itag_q;
   wire [0:`ITAG_SIZE_ENC-1] 			    fx0_ex0_s2_itag_q;
   wire [0:`ITAG_SIZE_ENC-1] 			    fx0_ex0_s3_itag_q;


   wire [0:`ITAG_SIZE_ENC-1] 			    fx1_ex0_s1_itag_q;
   wire [0:`ITAG_SIZE_ENC-1] 			    fx1_ex0_s2_itag_q;
   wire [0:`ITAG_SIZE_ENC-1] 			    fx1_ex0_s3_itag_q;

   //-------------------------------------------------------------------
   // Latches
   //-------------------------------------------------------------------\
   //FX0
   wire [0:12] 					    fx0_act;

   wire [0:`THREADS-1] 				    fx0_vld_d[0:11];
   wire [0:`THREADS-1] 				    fx0_vld_q[0:11];
   wire [0:`ITAG_SIZE_ENC-1] 			    fx0_itag_d[0:12];
   wire [0:`ITAG_SIZE_ENC-1] 			    fx0_itag_q[0:12];
   wire [0:`THREADS-1] 				    fx1_vld_d[0:6];
   wire [0:`THREADS-1] 				    fx1_vld_q[0:6];
   wire [0:`ITAG_SIZE_ENC-1] 			    fx1_itag_d[0:7];
   wire [0:`ITAG_SIZE_ENC-1] 			    fx1_itag_q[0:7];

   wire [0:3] 					    fx0_ex0_ilat_d;
   wire [0:3] 					    fx0_ex1_ilat_d;
   wire [0:3] 					    fx0_ex2_ilat_d;
   wire [0:3] 					    fx0_ex3_ilat_d;
   wire [0:3] 					    fx0_ex4_ilat_d;
   wire [0:3] 					    fx0_ex5_ilat_d;
   wire [0:3] 					    fx0_ex6_ilat_d;
   wire [0:3] 					    fx0_ex7_ilat_d;
   wire [0:3] 					    fx0_ex8_ilat_d;
   wire [0:3] 					    fx0_ex0_ilat_q;
   wire [0:3] 					    fx0_ex1_ilat_q;
   wire [0:3] 					    fx0_ex2_ilat_q;
   wire [0:3] 					    fx0_ex3_ilat_q;
   wire [0:3] 					    fx0_ex4_ilat_q;
   wire [0:3] 					    fx0_ex5_ilat_q;
   wire [0:3] 					    fx0_ex6_ilat_q;
   wire [0:3] 					    fx0_ex7_ilat_q;
   wire [0:3] 					    fx0_ex8_ilat_q;

   wire [1:7] 					    fx0_is_brick_d;
   wire [1:7] 					    fx0_is_brick_q;

   wire                                             fx0_ex5_mult_recirc;
   wire                                             fx0_ex6_mult_recirc;
   wire                                             fx0_ex7_mult_recirc;
   wire                                             fx0_mult_recirc;
   wire                                             fx0_ex5_recircd_d;
   wire                                             fx0_ex5_recircd_q;
   wire                                             fx0_ex6_recircd_d;
   wire                                             fx0_ex6_recircd_q;
   wire                                             fx0_ex7_recircd_d;
   wire                                             fx0_ex7_recircd_q;

   wire [0:`THREADS-1] 				    fx0_rel_itag_vld_d;
   wire [0:`THREADS-1] 				    fx0_rel_itag_vld_q;
   wire [0:`ITAG_SIZE_ENC-1] 			    fx0_rel_itag_d;
   wire [0:`ITAG_SIZE_ENC-1] 			    fx0_rel_itag_q;

   wire [0:`THREADS-1] 				    fx0_ext_rel_itag_vld_d;
   wire [0:`THREADS-1] 				    fx0_ext_rel_itag_vld_q;
   wire [0:`ITAG_SIZE_ENC-1] 			    fx0_ext_rel_itag_d;
   wire [0:`ITAG_SIZE_ENC-1] 			    fx0_ext_rel_itag_q;
   wire 					    fx0_ext_itag0_sel_d;
   wire 					    fx0_ext_itag0_sel_q;
   wire 					    fx0_ext_ilat_gt_1_need_rel;
   wire [0:`THREADS-1] 				    fx0_rv_itag_vld_int;
   wire [0:`ITAG_SIZE_ENC-1] 			    fx0_rv_itag_int;

   wire [0:4] 					    fx0_need_rel_d;
   wire [0:4] 					    fx0_need_rel_q;

   wire [0:`THREADS-1] 				    fx0_ex3_ord_rel_d;
   wire [0:`THREADS-1] 				    fx0_ex4_ord_rel_d;
   wire [0:`THREADS-1] 				    fx0_ex5_ord_rel_d;
   wire [0:`THREADS-1] 				    fx0_ex6_ord_rel_d;
   wire [0:`THREADS-1] 				    fx0_ex7_ord_rel_d;
   wire [0:`THREADS-1] 				    fx0_ex8_ord_rel_d;
   wire [0:`THREADS-1] 				    fx0_ex3_ord_rel_q;
   wire [0:`THREADS-1] 				    fx0_ex4_ord_rel_q;
   wire [0:`THREADS-1] 				    fx0_ex5_ord_rel_q;
   wire [0:`THREADS-1] 				    fx0_ex6_ord_rel_q;
   wire [0:`THREADS-1] 				    fx0_ex7_ord_rel_q;
   wire [0:`THREADS-1] 				    fx0_ex8_ord_rel_q;
   wire [0:`THREADS-1] 				    fx0_release_ord_hold_d;
   wire [0:`THREADS-1] 				    fx0_release_ord_hold_q;

   wire [0:`THREADS-1] 				    ex3_ord_flush;

   wire 					    fx0_ex0_ord_d;
   wire 					    fx0_ex1_ord_d;
   wire 					    fx0_ex2_ord_d;
   wire 					    fx0_ex3_ord_flush_d;
   wire 					    fx0_ex0_ord_q;
   wire 					    fx0_ex1_ord_q;
   wire 					    fx0_ex2_ord_q;
   wire 					    fx0_ex3_ord_flush_q;

   wire 					    fx0_sched_rel_pri_or_d;
   wire 					    fx0_sched_rel_pri_or_q;

   //FX1
   wire [0:7] 					    fx1_act;

   wire [0:2] 					    fx1_ex0_ilat_d;
   wire [0:2] 					    fx1_ex1_ilat_d;
   wire [0:2] 					    fx1_ex2_ilat_d;
   wire [0:2] 					    fx1_ex3_ilat_d;
   wire [0:2] 					    fx1_ex4_ilat_d;
   wire [0:2] 					    fx1_ex5_ilat_d;
   wire [0:2] 					    fx1_ex6_ilat_d;
   wire [0:2] 					    fx1_ex0_ilat_q;
   wire [0:2] 					    fx1_ex1_ilat_q;
   wire [0:2] 					    fx1_ex2_ilat_q;
   wire [0:2] 					    fx1_ex3_ilat_q;
   wire [0:2] 					    fx1_ex4_ilat_q;
   wire [0:2] 					    fx1_ex5_ilat_q;
   wire [0:2] 					    fx1_ex6_ilat_q;

   wire [0:`THREADS-1] 				    fx1_rel_itag_vld_d;
   wire [0:`THREADS-1] 				    fx1_rel_itag_vld_q;
   wire [0:`ITAG_SIZE_ENC-1] 			    fx1_rel_itag_d;
   wire [0:`ITAG_SIZE_ENC-1] 			    fx1_rel_itag_q;
   wire [0:`THREADS-1] 				    fx1_ext_rel_itag_vld_d;
   wire [0:`THREADS-1] 				    fx1_ext_rel_itag_vld_q;
   wire [0:`ITAG_SIZE_ENC-1] 			    fx1_ext_rel_itag_d;
   wire [0:`ITAG_SIZE_ENC-1] 			    fx1_ext_rel_itag_q;
   wire 					    fx1_ext_itag0_sel_d;
   wire 					    fx1_ext_itag0_sel_q;
   wire 					    fx1_ext_ilat_gt_1_need_rel;
   wire [0:`THREADS-1] 				    fx1_rv_itag_vld_int;
   wire [0:`ITAG_SIZE_ENC-1] 			    fx1_rv_itag_int;

   wire 					    fx1_ex0_need_rel_d;
   wire 					    fx1_ex1_need_rel_d;
   wire 					    fx1_ex2_need_rel_d;
   wire 					    fx1_ex3_need_rel_d;

   wire 					    fx1_ex0_need_rel_q;
   wire 					    fx1_ex1_need_rel_q;
   wire 					    fx1_ex2_need_rel_q;
   wire 					    fx1_ex3_need_rel_q;

   wire 					    fx1_ex1_stq_pipe_d;
   wire 					    fx1_ex2_stq_pipe_d;
   wire 					    fx1_ex1_stq_pipe_q;
   wire 					    fx1_ex2_stq_pipe_q;

   wire 					    fx1_sched_rel_pri_or_d;
   wire 					    fx1_sched_rel_pri_or_q;


   wire [0:elmnt_width-1] 			    fxu0_t1_d[0:12];		// FXU0 Targets
   wire [0:elmnt_width-1] 			    fxu0_t2_d[0:12];
   wire [0:elmnt_width-1] 			    fxu0_t3_d[0:12];
   wire [0:elmnt_width-1] 			    fxu0_s1_d;		// FXU0 Sources
   wire [0:elmnt_width-1] 			    fxu0_s2_d;
   wire [0:elmnt_width-1] 			    fxu0_s3_d;
   wire [0:elmnt_width-1] 			    fxu0_t1_q[0:12];		// FXU0 Targets
   wire [0:elmnt_width-1] 			    fxu0_t2_q[0:12];
   wire [0:elmnt_width-1] 			    fxu0_t3_q[0:12];
   wire [0:elmnt_width-1] 			    fxu0_s1_q;		// FXU0 Sources
   wire [0:elmnt_width-1] 			    fxu0_s2_q;
   wire [0:elmnt_width-1] 			    fxu0_s3_q;
   wire [0:elmnt_width-1] 			    lq_t1_d[0:8];		// LQ Targets
   wire [0:elmnt_width-1] 			    lq_t3_d[0:8];
   wire [0:elmnt_width-1] 			    lq_s1_d;		// Lq Sources
   wire [0:elmnt_width-1] 			    lq_s2_d;
   wire [0:elmnt_width-1] 			    lq_t1_q[0:8];		// LQ Targets
   wire [0:elmnt_width-1] 			    lq_t3_q[0:8];
   wire [0:elmnt_width-1] 			    lq_s1_q;		// Lq Sources
   wire [0:elmnt_width-1] 			    lq_s2_q;
   wire [0:elmnt_width-1] 			    fxu1_t1_d[0:7];		// FXU1 Targets
   wire [0:elmnt_width-1] 			    fxu1_t2_d[0:7];
   wire [0:elmnt_width-1] 			    fxu1_t3_d[0:7];
   wire [0:elmnt_width-1] 			    fxu1_s1_d;		// FXU1 Sources
   wire [0:elmnt_width-1] 			    fxu1_s2_d;
   wire [0:elmnt_width-1] 			    fxu1_s3_d;
   wire [0:elmnt_width-1] 			    fxu1_t1_q[0:7];		// FXU1 Targets
   wire [0:elmnt_width-1] 			    fxu1_t2_q[0:7];
   wire [0:elmnt_width-1] 			    fxu1_t3_q[0:7];
   wire [0:elmnt_width-1] 			    fxu1_s1_q;		// FXU1 Sources
   wire [0:elmnt_width-1] 			    fxu1_s2_q;
   wire [0:elmnt_width-1] 			    fxu1_s3_q;


   wire [0:`THREADS-1] 				    rel_vld_d[0:3];
   wire [0:`THREADS-1] 				    rel_vld_q[0:3];
   wire [0:`ITAG_SIZE_ENC-1] 			    rel_itag_d[0:3];
   wire [0:`ITAG_SIZE_ENC-1] 			    rel_itag_q[0:3];

   wire [0:`THREADS-1] 				    cp_flush_q;


   wire [0:8] 					    lq_act;
   wire [0:`THREADS-1] 				    lq_vld_d[0:7];
   wire [0:`THREADS-1] 				    lq_vld_q[0:7];
   wire [0:`ITAG_SIZE_ENC-1] 			    lq_itag_d[0:8];
   wire [0:`ITAG_SIZE_ENC-1] 			    lq_itag_q[0:8];

   wire fx0_byp_rdy_nxt_0;
   wire [0:`THREADS-1] fx0_byp_rdy_nxt[0:11];
   wire fx1_byp_rdy_nxt_0;
   wire [0:`THREADS-1] fx1_byp_rdy_nxt[0:6];

   //-------------------------------------------------------------------
   // Scanchain
   //-------------------------------------------------------------------
   parameter                                      fxu0_t1_offset = 0;
   parameter                                      fxu0_t2_offset = fxu0_t1_offset + elmnt_width * (13);
   parameter                                      fxu0_t3_offset = fxu0_t2_offset + elmnt_width * (13);
   parameter                                      fxu0_s1_offset = fxu0_t3_offset + elmnt_width * (13);
   parameter                                      fxu0_s2_offset = fxu0_s1_offset + elmnt_width;
   parameter                                      fxu0_s3_offset = fxu0_s2_offset + elmnt_width;
   parameter                                      lq_t1_offset = fxu0_s3_offset + elmnt_width;
   parameter                                      lq_t3_offset = lq_t1_offset + elmnt_width * (9);
   parameter                                      lq_s1_offset = lq_t3_offset + elmnt_width * (9);
   parameter                                      lq_s2_offset = lq_s1_offset + elmnt_width;
   parameter                                      fxu1_t1_offset = lq_s2_offset + elmnt_width;
   parameter                                      fxu1_t2_offset = fxu1_t1_offset + elmnt_width * (8);
   parameter                                      fxu1_t3_offset = fxu1_t2_offset + elmnt_width * (8);
   parameter                                      fxu1_s1_offset = fxu1_t3_offset + elmnt_width * (8);
   parameter                                      fxu1_s2_offset = fxu1_s1_offset + elmnt_width;
   parameter                                      fxu1_s3_offset = fxu1_s2_offset + elmnt_width;

   parameter                                      rel_vld_offset = fxu1_s3_offset + elmnt_width;
   parameter                                      rel_itag_offset = rel_vld_offset + `THREADS * (4);
   parameter                                      cp_flush_offset = rel_itag_offset + `ITAG_SIZE_ENC * (4);

   //fx0 release
   parameter                                      fx0_is_brick_offset = cp_flush_offset + `THREADS;
   parameter                                      fx0_vld_offset = fx0_is_brick_offset+7;

   parameter                                      fx0_itag_offset = fx0_vld_offset + `THREADS * (12);

   parameter                                      fx0_ex0_ilat_offset = fx0_itag_offset + `ITAG_SIZE_ENC * (13);
   parameter                                      fx0_ex1_ilat_offset = fx0_ex0_ilat_offset + 4;
   parameter                                      fx0_ex2_ilat_offset = fx0_ex1_ilat_offset + 4;
   parameter                                      fx0_ex3_ilat_offset = fx0_ex2_ilat_offset + 4;
   parameter                                      fx0_ex4_ilat_offset = fx0_ex3_ilat_offset + 4;
   parameter                                      fx0_ex5_ilat_offset = fx0_ex4_ilat_offset + 4;
   parameter                                      fx0_ex6_ilat_offset = fx0_ex5_ilat_offset + 4;
   parameter                                      fx0_ex7_ilat_offset = fx0_ex6_ilat_offset + 4;
   parameter                                      fx0_ex8_ilat_offset = fx0_ex7_ilat_offset + 4;

   parameter                                      fx0_rel_itag_vld_offset = fx0_ex8_ilat_offset + 4;
   parameter                                      fx0_rel_itag_offset = fx0_rel_itag_vld_offset + `THREADS;
   parameter                                      fx0_ext_rel_itag_vld_offset = fx0_rel_itag_offset + `ITAG_SIZE_ENC;
   parameter                                      fx0_ext_rel_itag_offset = fx0_ext_rel_itag_vld_offset + `THREADS;
   parameter                                      fx0_ext_itag0_sel_offset = fx0_ext_rel_itag_offset + `ITAG_SIZE_ENC;

   parameter                                      fx0_need_rel_offset = fx0_ext_itag0_sel_offset + 1;

   parameter                                      fx0_ex3_ord_rel_offset = fx0_need_rel_offset + 5;
   parameter                                      fx0_ex4_ord_rel_offset = fx0_ex3_ord_rel_offset + `THREADS;
   parameter                                      fx0_ex5_ord_rel_offset = fx0_ex4_ord_rel_offset + `THREADS;
   parameter                                      fx0_ex6_ord_rel_offset = fx0_ex5_ord_rel_offset + `THREADS;
   parameter                                      fx0_ex7_ord_rel_offset = fx0_ex6_ord_rel_offset + `THREADS;
   parameter                                      fx0_ex8_ord_rel_offset = fx0_ex7_ord_rel_offset + `THREADS;
   parameter                                      fx0_release_ord_hold_offset = fx0_ex8_ord_rel_offset + `THREADS;

   parameter                                      fx0_ex0_ord_offset = fx0_release_ord_hold_offset + `THREADS;
   parameter                                      fx0_ex1_ord_offset = fx0_ex0_ord_offset + 1;
   parameter                                      fx0_ex2_ord_offset = fx0_ex1_ord_offset + 1;
   parameter                                      fx0_ex3_ord_flush_offset = fx0_ex2_ord_offset + 1;
   parameter                                      fx0_sched_rel_pri_or_offset = fx0_ex3_ord_flush_offset + 1;

   parameter 					  fx0_rel_itag_abort_offset = fx0_sched_rel_pri_or_offset + 1;
   parameter 					  fx0_ext_rel_itag_abort_offset = fx0_rel_itag_abort_offset + 1;
   parameter                                      fx0_ex5_recircd_offset = fx0_ext_rel_itag_abort_offset + 1;
   parameter                                      fx0_ex6_recircd_offset = fx0_ex5_recircd_offset + 1;
   parameter                                      fx0_ex7_recircd_offset = fx0_ex6_recircd_offset + 1;
   parameter        				  fx0_abort_offset = fx0_ex7_recircd_offset + 1;

   //fx1 release
   parameter                                      fx1_vld_offset = fx0_abort_offset + 2;//3:4

   parameter                                      fx1_itag_offset = fx1_vld_offset + `THREADS * (7);

   parameter                                      fx1_ex0_ilat_offset = fx1_itag_offset + `ITAG_SIZE_ENC * (8);
   parameter                                      fx1_ex1_ilat_offset = fx1_ex0_ilat_offset + 3;
   parameter                                      fx1_ex2_ilat_offset = fx1_ex1_ilat_offset + 3;
   parameter                                      fx1_ex3_ilat_offset = fx1_ex2_ilat_offset + 3;
   parameter                                      fx1_ex4_ilat_offset = fx1_ex3_ilat_offset + 3;
   parameter                                      fx1_ex5_ilat_offset = fx1_ex4_ilat_offset + 3;
   parameter                                      fx1_ex6_ilat_offset = fx1_ex5_ilat_offset + 3;

   parameter                                      fx1_rel_itag_vld_offset = fx1_ex6_ilat_offset + 3;
   parameter                                      fx1_rel_itag_offset = fx1_rel_itag_vld_offset + `THREADS;
   parameter                                      fx1_ext_rel_itag_vld_offset = fx1_rel_itag_offset + `ITAG_SIZE_ENC;
   parameter                                      fx1_ext_rel_itag_offset = fx1_ext_rel_itag_vld_offset + `THREADS;
   parameter                                      fx1_ext_itag0_sel_offset = fx1_ext_rel_itag_offset + `ITAG_SIZE_ENC;

   parameter                                      fx1_ex0_need_rel_offset = fx1_ext_itag0_sel_offset + 1;
   parameter                                      fx1_ex1_need_rel_offset = fx1_ex0_need_rel_offset + 1;
   parameter                                      fx1_ex2_need_rel_offset = fx1_ex1_need_rel_offset + 1;
   parameter                                      fx1_ex3_need_rel_offset = fx1_ex2_need_rel_offset + 1;

   parameter                                      fx1_ex1_stq_pipe_offset = fx1_ex3_need_rel_offset + 1;
   parameter                                      fx1_ex2_stq_pipe_offset = fx1_ex1_stq_pipe_offset + 1;

   parameter                                      fx1_sched_rel_pri_or_offset  = fx1_ex2_stq_pipe_offset + 1;

   parameter 					  fx1_rel_itag_abort_offset = fx1_sched_rel_pri_or_offset + 1;
   parameter 					  fx1_ext_rel_itag_abort_offset = fx1_rel_itag_abort_offset + 1;
   parameter        				  fx1_abort_offset = fx1_ext_rel_itag_abort_offset + 1;

   parameter                                      fx0_ex0_s1_itag_offset = fx1_abort_offset + 2;//3:4
   parameter                                      fx0_ex0_s2_itag_offset = fx0_ex0_s1_itag_offset + `ITAG_SIZE_ENC;
   parameter                                      fx0_ex0_s3_itag_offset = fx0_ex0_s2_itag_offset + `ITAG_SIZE_ENC;

   //fx1 spec flush
   parameter                                      fx1_ex0_s1_itag_offset = fx0_ex0_s3_itag_offset + `ITAG_SIZE_ENC;
   parameter                                      fx1_ex0_s2_itag_offset = fx1_ex0_s1_itag_offset + `ITAG_SIZE_ENC;
   parameter                                      fx1_ex0_s3_itag_offset = fx1_ex0_s2_itag_offset + `ITAG_SIZE_ENC;

   parameter                                      lq_vld_offset = fx1_ex0_s3_itag_offset + `ITAG_SIZE_ENC;
   parameter                                      lq_itag_offset = lq_vld_offset + `THREADS * (8);
   parameter                                      scan_right = lq_itag_offset + `ITAG_SIZE_ENC * (9);

   wire [0:scan_right-1] 			      siv;
   wire [0:scan_right-1] 			      sov;

   wire 					      func_sl_thold_0;
   wire 					      func_sl_thold_0_b;
   wire 					      sg_0;
   wire 					      force_t;

   //!! Bugspray Include: rv_rf_byp;

   assign d_mode = 1'b0;

   assign rv_byp_fx1_t2_t = `xer_t;
   assign rv_byp_fx1_t3_t = `cr_t;

   //----------------------------------------------------------------------------------------------------------------------------------------
   // Concatenate Relevant signals
   //----------------------------------------------------------------------------------------------------------------------------------------

   //Determine if we have a muliplier recirculation
   assign fx0_ex5_mult_recirc = (fx0_ex5_ilat_q == 4'b0101) & fx0_is_brick_q[5] & |(fxu0_t1_q[5][0:`THREADS-1]) & ~fx0_ex5_recircd_q;
   assign fx0_ex6_mult_recirc = (fx0_ex6_ilat_q == 4'b0110) & fx0_is_brick_q[6] & |(fxu0_t1_q[6][0:`THREADS-1]) & ~fx0_ex6_recircd_q;
   assign fx0_ex7_mult_recirc = (fx0_ex7_ilat_q == 4'b0111) & fx0_is_brick_q[7] & |(fxu0_t1_q[7][0:`THREADS-1]) & ~fx0_ex7_recircd_q;
   assign fx0_mult_recirc =  fx0_ex5_mult_recirc | fx0_ex6_mult_recirc | fx0_ex7_mult_recirc ;

   assign fx0_ex5_recircd_d = fx0_mult_recirc;
   assign fx0_ex6_recircd_d = fx0_ex5_recircd_q;
   assign fx0_ex7_recircd_d = fx0_ex6_recircd_q;


   // Valid, not flushed                     & Target/Source    & Type (T1/S1 always GPR)
   assign fxu0_t1_d[0] = {(rv_byp_fx0_vld & (~(cp_flush_q)) & {`THREADS{rv_byp_fx0_t1_v & fx0_byp_rdy_nxt_0}}), rv_byp_fx0_t1_t};
   assign fxu0_t2_d[0] = {(rv_byp_fx0_vld & (~(cp_flush_q)) & {`THREADS{rv_byp_fx0_t2_v & fx0_byp_rdy_nxt_0}}), rv_byp_fx0_t2_t};
   assign fxu0_t3_d[0] = {(rv_byp_fx0_vld & (~(cp_flush_q)) & {`THREADS{rv_byp_fx0_t3_v & fx0_byp_rdy_nxt_0}}), rv_byp_fx0_t3_t};
   assign fxu0_s1_d = {(rv_byp_fx0_vld & (~(cp_flush_q))), rv_byp_fx0_s1_t};
   assign fxu0_s2_d = {(rv_byp_fx0_vld & (~(cp_flush_q))), rv_byp_fx0_s2_t};
   assign fxu0_s3_d = {(rv_byp_fx0_vld & (~(cp_flush_q))), rv_byp_fx0_s3_t};
   assign lq_t1_d[0] = {(rv_byp_lq_vld & (~(cp_flush_q)) & {`THREADS{rv_byp_lq_t1_v}}), `gpr_t};
   assign lq_t3_d[0] = {(rv_byp_lq_vld & (~(cp_flush_q)) & {`THREADS{rv_byp_lq_t3_v}}), rv_byp_lq_t3_t};
   assign lq_s1_d = {(rv_byp_lq_vld & (~(cp_flush_q))), rv_byp_lq_s1_t};
   assign lq_s2_d = {(rv_byp_lq_vld & (~(cp_flush_q))), rv_byp_lq_s2_t};
   assign fxu1_t1_d[0] = {(rv_byp_fx1_vld & (~(cp_flush_q)) & {`THREADS{rv_byp_fx1_t1_v & fx1_byp_rdy_nxt_0}}), `gpr_t};
   assign fxu1_t2_d[0] = {(rv_byp_fx1_vld & (~(cp_flush_q)) & {`THREADS{rv_byp_fx1_t2_v & fx1_byp_rdy_nxt_0}}), rv_byp_fx1_t2_t};
   assign fxu1_t3_d[0] = {(rv_byp_fx1_vld & (~(cp_flush_q)) & {`THREADS{rv_byp_fx1_t3_v & fx1_byp_rdy_nxt_0}}), rv_byp_fx1_t3_t};
   assign fxu1_s1_d = {(rv_byp_fx1_vld & (~(cp_flush_q))), rv_byp_fx1_s1_t};
   assign fxu1_s2_d = {(rv_byp_fx1_vld & (~(cp_flush_q))), rv_byp_fx1_s2_t};
   assign fxu1_s3_d = {(rv_byp_fx1_vld & (~(cp_flush_q))), rv_byp_fx1_s3_t};

   generate
      begin : xhdl1
         genvar                                         i;
         for (i = 1; i <= 4; i = i + 1)
           begin : fxu0_pipe_t_gen
              assign fxu0_t1_d[i] = {((fxu0_t1_q[i - 1][0:`THREADS - 1] | fx0_byp_rdy_nxt[i-1]) & (~(cp_flush_q))), fxu0_t1_q[i - 1][`THREADS:elmnt_width - 1]};
              assign fxu0_t2_d[i] = {((fxu0_t2_q[i - 1][0:`THREADS - 1] | fx0_byp_rdy_nxt[i-1]) & (~(cp_flush_q))), fxu0_t2_q[i - 1][`THREADS:elmnt_width - 1]};
              assign fxu0_t3_d[i] = {((fxu0_t3_q[i - 1][0:`THREADS - 1] | fx0_byp_rdy_nxt[i-1]) & (~(cp_flush_q))), fxu0_t3_q[i - 1][`THREADS:elmnt_width - 1]};
           end
      end
   endgenerate
   // Multiplier Recirc
              assign fxu0_t1_d[5] = (({((fxu0_t1_q[4][0:`THREADS - 1] | fx0_byp_rdy_nxt[4]) & (~(cp_flush_q))), fxu0_t1_q[4][`THREADS:elmnt_width - 1]}) & ({elmnt_width{~fx0_mult_recirc}})) |
				    (({((fxu0_t1_q[5][0:`THREADS - 1] | fx0_byp_rdy_nxt[5]) & (~(cp_flush_q))), fxu0_t1_q[5][`THREADS:elmnt_width - 1]}) & ({elmnt_width{fx0_ex5_mult_recirc}})) |
				    (({((fxu0_t1_q[6][0:`THREADS - 1] | fx0_byp_rdy_nxt[6]) & (~(cp_flush_q))), fxu0_t1_q[6][`THREADS:elmnt_width - 1]}) & ({elmnt_width{fx0_ex6_mult_recirc}})) |
				    (({((fxu0_t1_q[7][0:`THREADS - 1] | fx0_byp_rdy_nxt[7]) & (~(cp_flush_q))), fxu0_t1_q[7][`THREADS:elmnt_width - 1]}) & ({elmnt_width{fx0_ex7_mult_recirc}})) ;
              assign fxu0_t2_d[5] = (({((fxu0_t2_q[4][0:`THREADS - 1] | fx0_byp_rdy_nxt[4]) & (~(cp_flush_q))), fxu0_t2_q[4][`THREADS:elmnt_width - 1]}) & ({elmnt_width{~fx0_mult_recirc}})) |
				    (({((fxu0_t2_q[5][0:`THREADS - 1] | fx0_byp_rdy_nxt[5]) & (~(cp_flush_q))), fxu0_t2_q[5][`THREADS:elmnt_width - 1]}) & ({elmnt_width{fx0_ex5_mult_recirc}})) |
				    (({((fxu0_t2_q[6][0:`THREADS - 1] | fx0_byp_rdy_nxt[6]) & (~(cp_flush_q))), fxu0_t2_q[6][`THREADS:elmnt_width - 1]}) & ({elmnt_width{fx0_ex6_mult_recirc}})) |
				    (({((fxu0_t2_q[7][0:`THREADS - 1] | fx0_byp_rdy_nxt[7]) & (~(cp_flush_q))), fxu0_t2_q[7][`THREADS:elmnt_width - 1]}) & ({elmnt_width{fx0_ex7_mult_recirc}})) ;
              assign fxu0_t3_d[5] = (({((fxu0_t3_q[4][0:`THREADS - 1] | fx0_byp_rdy_nxt[4]) & (~(cp_flush_q))), fxu0_t3_q[4][`THREADS:elmnt_width - 1]}) & ({elmnt_width{~fx0_mult_recirc}})) |
				    (({((fxu0_t3_q[5][0:`THREADS - 1] | fx0_byp_rdy_nxt[5]) & (~(cp_flush_q))), fxu0_t3_q[5][`THREADS:elmnt_width - 1]}) & ({elmnt_width{fx0_ex5_mult_recirc}})) |
				    (({((fxu0_t3_q[6][0:`THREADS - 1] | fx0_byp_rdy_nxt[6]) & (~(cp_flush_q))), fxu0_t3_q[6][`THREADS:elmnt_width - 1]}) & ({elmnt_width{fx0_ex6_mult_recirc}})) |
				    (({((fxu0_t3_q[7][0:`THREADS - 1] | fx0_byp_rdy_nxt[7]) & (~(cp_flush_q))), fxu0_t3_q[7][`THREADS:elmnt_width - 1]}) & ({elmnt_width{fx0_ex7_mult_recirc}})) ;


   generate
      begin : xhdla
         genvar                                         i;
         for (i = 6; i <= 12; i = i + 1)
           begin : fxu0_pipe_t_gen
              assign fxu0_t1_d[i] = {((fxu0_t1_q[i - 1][0:`THREADS - 1] | fx0_byp_rdy_nxt[i-1]) & (~(cp_flush_q))), fxu0_t1_q[i - 1][`THREADS:elmnt_width - 1]};
              assign fxu0_t2_d[i] = {((fxu0_t2_q[i - 1][0:`THREADS - 1] | fx0_byp_rdy_nxt[i-1]) & (~(cp_flush_q))), fxu0_t2_q[i - 1][`THREADS:elmnt_width - 1]};
              assign fxu0_t3_d[i] = {((fxu0_t3_q[i - 1][0:`THREADS - 1] | fx0_byp_rdy_nxt[i-1]) & (~(cp_flush_q))), fxu0_t3_q[i - 1][`THREADS:elmnt_width - 1]};
           end
      end
   endgenerate

   generate
      begin : xhdl3
         genvar                                         i;
         for (i = 1; i <= 8; i = i + 1)
           begin : lq_pipe_t_gen
              assign lq_t1_d[i] = {(lq_t1_q[i - 1][0:`THREADS - 1] & (~(cp_flush_q))), lq_t1_q[i - 1][`THREADS:elmnt_width - 1]};
              assign lq_t3_d[i] = {(lq_t3_q[i - 1][0:`THREADS - 1] & (~(cp_flush_q))), lq_t3_q[i - 1][`THREADS:elmnt_width - 1]};
           end
      end
   endgenerate

   generate
      begin : xhdl4
         genvar                                         i;
         for (i = 1; i <= 7; i = i + 1)
           begin : fxu1_pipe_t_gen
              assign fxu1_t1_d[i] = {((fxu1_t1_q[i - 1][0:`THREADS - 1] | fx1_byp_rdy_nxt[i-1]) & (~(cp_flush_q))), fxu1_t1_q[i - 1][`THREADS:elmnt_width - 1]};
              assign fxu1_t2_d[i] = {((fxu1_t2_q[i - 1][0:`THREADS - 1] | fx1_byp_rdy_nxt[i-1]) & (~(cp_flush_q))), fxu1_t2_q[i - 1][`THREADS:elmnt_width - 1]};
              assign fxu1_t3_d[i] = {((fxu1_t3_q[i - 1][0:`THREADS - 1] | fx1_byp_rdy_nxt[i-1]) & (~(cp_flush_q))), fxu1_t3_q[i - 1][`THREADS:elmnt_width - 1]};
           end
      end
   endgenerate

   assign rel_vld_d[0] = (lq_rv_itag2_vld & (~(cp_flush_q)));
   assign rel_itag_d[0] = lq_rv_itag2;
   generate
      begin : xhdl5
         genvar                                         i;
         for (i = 1; i <= 3; i = i + 1)
           begin : rel_pipe_t_gen
              assign rel_vld_d[i] = (rel_vld_q[i - 1] & (~(cp_flush_q)));
              assign rel_itag_d[i] = rel_itag_q[i - 1];
           end
      end
   endgenerate

   //----------------------------------------------------------------------------------------------------------------------------------------
   // FXU0 Compares
   //----------------------------------------------------------------------------------------------------------------------------------------
   generate
      begin : xhdl6
         genvar                                         i;
         for (i = 1; i <= 11; i = i + 1)
           begin : comp_fxu0_fxu0
              assign fxu0_s1_fxu0_itag_match[i] = fx0_ex0_s1_itag_q == fx0_itag_q[i];
              assign fxu0_s2_fxu0_itag_match[i] = fx0_ex0_s2_itag_q == fx0_itag_q[i];
              assign fxu0_s3_fxu0_itag_match[i] = fx0_ex0_s3_itag_q == fx0_itag_q[i];
              assign fxu0_s1_fxu0_t1_match[i] = (fxu0_s1_q == fxu0_t1_q[i]) & fxu0_s1_fxu0_itag_match[i];		// Source 1 w/ FXU0 T1 Pipe
              assign fxu0_s1_fxu0_t2_match[i] = (fxu0_s1_q == fxu0_t2_q[i]) & fxu0_s1_fxu0_itag_match[i];		// Source 1 w/ FXU0 T2 Pipe
              assign fxu0_s1_fxu0_t3_match[i] = (fxu0_s1_q == fxu0_t3_q[i]) & fxu0_s1_fxu0_itag_match[i];		// Source 1 w/ FXU0 T3 Pipe
              assign fxu0_s2_fxu0_t1_match[i] = (fxu0_s2_q == fxu0_t1_q[i]) & fxu0_s2_fxu0_itag_match[i];		// Source 2 w/ FXU0 T1 Pipe
              assign fxu0_s2_fxu0_t2_match[i] = (fxu0_s2_q == fxu0_t2_q[i]) & fxu0_s2_fxu0_itag_match[i];		// Source 2 w/ FXU0 T2 Pipe
              assign fxu0_s2_fxu0_t3_match[i] = (fxu0_s2_q == fxu0_t3_q[i]) & fxu0_s2_fxu0_itag_match[i];		// Source 2 w/ FXU0 T3 Pipe
              assign fxu0_s3_fxu0_t1_match[i] = (fxu0_s3_q == fxu0_t1_q[i]) & fxu0_s3_fxu0_itag_match[i];		// Source 3 w/ FXU0 T1 Pipe
              assign fxu0_s3_fxu0_t2_match[i] = (fxu0_s3_q == fxu0_t2_q[i]) & fxu0_s3_fxu0_itag_match[i];		// Source 3 w/ FXU0 T2 Pipe
              assign fxu0_s3_fxu0_t3_match[i] = (fxu0_s3_q == fxu0_t3_q[i]) & fxu0_s3_fxu0_itag_match[i];		// Source 3 w/ FXU0 T3 Pipe
           end
      end
   endgenerate

   generate
      begin : xhd7
         genvar                                         i;
         for (i = 4; i <= 8; i = i + 1)
           begin : comp_fxu0_lq
              assign fxu0_s1_lq_itag_match[i] = fx0_ex0_s1_itag_q == lq_itag_q[i];
              assign fxu0_s2_lq_itag_match[i] = fx0_ex0_s2_itag_q == lq_itag_q[i];
              assign fxu0_s3_lq_itag_match[i] = fx0_ex0_s3_itag_q == lq_itag_q[i];
              assign fxu0_s1_lq_t1_match[i] = (fxu0_s1_q == lq_t1_q[i]) & fxu0_s1_lq_itag_match[i];		// Source 1 w/ LQ T1 Pipe
              assign fxu0_s1_lq_t2_match[i] = 1'b0;		// Source 1 w/ LQ T2 Pipe
              assign fxu0_s1_lq_t3_match[i] = (fxu0_s1_q == lq_t3_q[i]) & fxu0_s1_lq_itag_match[i];		// Source 1 w/ LQ T3 Pipe
              assign fxu0_s2_lq_t1_match[i] = (fxu0_s2_q == lq_t1_q[i]) & fxu0_s2_lq_itag_match[i];		// Source 2 w/ LQ T1 Pipe
              assign fxu0_s2_lq_t2_match[i] = 1'b0;		// Source 2 w/ LQ T2 Pipe
              assign fxu0_s2_lq_t3_match[i] = (fxu0_s2_q == lq_t3_q[i]) & fxu0_s2_lq_itag_match[i];		// Source 2 w/ LQ T3 Pipe
              assign fxu0_s3_lq_t1_match[i] = (fxu0_s3_q == lq_t1_q[i]) & fxu0_s3_lq_itag_match[i];		// Source 3 w/ LQ T1 Pipe
              assign fxu0_s3_lq_t2_match[i] = 1'b0;		// Source 3 w/ LQ T2 Pipe
              assign fxu0_s3_lq_t3_match[i] = (fxu0_s3_q == lq_t3_q[i]) & fxu0_s3_lq_itag_match[i];		// Source 3 w/ LQ T3 Pipe
           end
      end
   endgenerate

   generate
      begin : xhdl8
         genvar                                         i;
         for (i = 1; i <= 6 ; i = i + 1)
           begin : comp_fxu0_fxu1
              assign fxu0_s1_fxu1_itag_match[i] = fx0_ex0_s1_itag_q == fx1_itag_q[i];
              assign fxu0_s2_fxu1_itag_match[i] = fx0_ex0_s2_itag_q == fx1_itag_q[i];
              assign fxu0_s3_fxu1_itag_match[i] = fx0_ex0_s3_itag_q == fx1_itag_q[i];
              assign fxu0_s1_fxu1_t1_match[i] = (fxu0_s1_q == fxu1_t1_q[i]) & fxu0_s1_fxu1_itag_match[i];		// Source 1 w/ FXU1 T1 Pipe
              assign fxu0_s1_fxu1_t2_match[i] = (fxu0_s1_q == fxu1_t2_q[i]) & fxu0_s1_fxu1_itag_match[i];		// Source 1 w/ FXU1 T2 Pipe
              assign fxu0_s1_fxu1_t3_match[i] = (fxu0_s1_q == fxu1_t3_q[i]) & fxu0_s1_fxu1_itag_match[i];		// Source 1 w/ FXU1 T3 Pipe
              assign fxu0_s2_fxu1_t1_match[i] = (fxu0_s2_q == fxu1_t1_q[i]) & fxu0_s2_fxu1_itag_match[i];		// Source 2 w/ FXU1 T1 Pipe
              assign fxu0_s2_fxu1_t2_match[i] = (fxu0_s2_q == fxu1_t2_q[i]) & fxu0_s2_fxu1_itag_match[i];		// Source 2 w/ FXU1 T2 Pipe
              assign fxu0_s2_fxu1_t3_match[i] = (fxu0_s2_q == fxu1_t3_q[i]) & fxu0_s2_fxu1_itag_match[i];		// Source 2 w/ FXU1 T3 Pipe
              assign fxu0_s3_fxu1_t1_match[i] = (fxu0_s3_q == fxu1_t1_q[i]) & fxu0_s3_fxu1_itag_match[i];		// Source 3 w/ FXU1 T1 Pipe
              assign fxu0_s3_fxu1_t2_match[i] = (fxu0_s3_q == fxu1_t2_q[i]) & fxu0_s3_fxu1_itag_match[i];		// Source 3 w/ FXU1 T2 Pipe
              assign fxu0_s3_fxu1_t3_match[i] = (fxu0_s3_q == fxu1_t3_q[i]) & fxu0_s3_fxu1_itag_match[i];		// Source 3 w/ FXU1 T3 Pipe
           end
      end
   endgenerate

   generate
      begin : xhdl9
         genvar                                         i;
         for (i = 2; i <= 3; i = i + 1)
           begin : comp_fxu0_rel
              assign fxu0_s1_rel_itag_match[i] = fx0_ex0_s1_itag_q == rel_itag_q[i];
              assign fxu0_s2_rel_itag_match[i] = fx0_ex0_s2_itag_q == rel_itag_q[i];
              assign fxu0_s3_rel_itag_match[i] = fx0_ex0_s3_itag_q == rel_itag_q[i];
              assign fxu0_s1_rel_match[i] = (fxu0_s1_q == ({rel_vld_q[i], `gpr_t})) & fxu0_s1_rel_itag_match[i];		// Source 1 w/ rel T1 Pipe
              assign fxu0_s2_rel_match[i] = (fxu0_s2_q == ({rel_vld_q[i], `gpr_t})) & fxu0_s2_rel_itag_match[i];		// Source 1 w/ rel T1 Pipe
              assign fxu0_s3_rel_match[i] = (fxu0_s3_q == ({rel_vld_q[i], `gpr_t})) & fxu0_s3_rel_itag_match[i];		// Source 1 w/ rel T1 Pipe
           end
      end
   endgenerate

   //----------------------------------------------------------------------------------------------------------------------------------------
   // Assign Outputs to FXU0   -  Fastest back2back is 1->6 (4 bubbles)
   //----------------------------------------------------------------------------------------------------------------------------------------.
   assign fx0_ex0_s1_fx0_sel[1:11] = fxu0_s1_fxu0_t1_match | fxu0_s1_fxu0_t2_match | fxu0_s1_fxu0_t3_match;
   assign fx0_ex0_s2_fx0_sel[1:11] = fxu0_s2_fxu0_t1_match | fxu0_s2_fxu0_t2_match | fxu0_s2_fxu0_t3_match;
   assign fx0_ex0_s3_fx0_sel[1:11] = fxu0_s3_fxu0_t1_match | fxu0_s3_fxu0_t2_match | fxu0_s3_fxu0_t3_match;
   rv_pri #(.size(11)) fx0_s1_fx0 (.cond(fx0_ex0_s1_fx0_sel), .pri(rv_fx0_ex0_s1_fx0_sel));
   rv_pri #(.size(11)) fx0_s2_fx0 (.cond(fx0_ex0_s2_fx0_sel), .pri(rv_fx0_ex0_s2_fx0_sel));
   rv_pri #(.size(11)) fx0_s3_fx0 (.cond(fx0_ex0_s3_fx0_sel), .pri(rv_fx0_ex0_s3_fx0_sel));

   // No pri necessary for 4:8
   assign rv_fx0_ex0_s1_lq_sel[4:8] = fxu0_s1_lq_t1_match | fxu0_s1_lq_t2_match | fxu0_s1_lq_t3_match;
   assign rv_fx0_ex0_s2_lq_sel[4:8] = fxu0_s2_lq_t1_match | fxu0_s2_lq_t2_match | fxu0_s2_lq_t3_match;
   assign rv_fx0_ex0_s3_lq_sel[4:8] = fxu0_s3_lq_t1_match | fxu0_s3_lq_t2_match | fxu0_s3_lq_t3_match;

   assign fx0_ex0_s1_fx1_sel[1:6] = fxu0_s1_fxu1_t1_match | fxu0_s1_fxu1_t2_match | fxu0_s1_fxu1_t3_match;
   assign fx0_ex0_s2_fx1_sel[1:6] = fxu0_s2_fxu1_t1_match | fxu0_s2_fxu1_t2_match | fxu0_s2_fxu1_t3_match;
   assign fx0_ex0_s3_fx1_sel[1:6] = fxu0_s3_fxu1_t1_match | fxu0_s3_fxu1_t2_match | fxu0_s3_fxu1_t3_match;
   assign rv_fx0_ex0_s1_fx1_sel[1:5] = fx0_ex0_s1_fx1_sel[1:5];
   assign rv_fx0_ex0_s2_fx1_sel[1:5] = fx0_ex0_s2_fx1_sel[1:5];
   assign rv_fx0_ex0_s3_fx1_sel[1:5] = fx0_ex0_s3_fx1_sel[1:5];
   assign rv_fx0_ex0_s1_fx1_sel[6]   = fx0_ex0_s1_fx1_sel[6] & ~fx0_ex0_s1_fx1_sel[1];
   assign rv_fx0_ex0_s2_fx1_sel[6]   = fx0_ex0_s2_fx1_sel[6] & ~fx0_ex0_s2_fx1_sel[1];
   assign rv_fx0_ex0_s3_fx1_sel[6]   = fx0_ex0_s3_fx1_sel[6] & ~fx0_ex0_s3_fx1_sel[1];

   assign rv_fx0_ex0_s1_rel_sel[2:3] = fxu0_s1_rel_match;
   assign rv_fx0_ex0_s2_rel_sel[2:3] = fxu0_s2_rel_match;
   assign rv_fx0_ex0_s3_rel_sel[2:3] = fxu0_s3_rel_match;

   //----------------------------------------------------------------------------------------------------------------------------------------
   // LQ Compares
   //----------------------------------------------------------------------------------------------------------------------------------------
   generate
      begin : xhdl10
         genvar                                         i;
         for (i = 2; i <= 12; i = i + 1)
           begin : comp_lq_fxu0
              assign lq_s1_fxu0_itag_match[i] = rv_byp_lq_ex0_s1_itag == fx0_itag_q[i];
              assign lq_s2_fxu0_itag_match[i] = rv_byp_lq_ex0_s2_itag == fx0_itag_q[i];
              assign lq_s1_fxu0_t1_match[i] = (lq_s1_q == fxu0_t1_q[i]) & lq_s1_fxu0_itag_match[i];		// Source 1 w/ FXU0 T1 Pipe
              assign lq_s1_fxu0_t2_match[i] = (lq_s1_q == fxu0_t2_q[i]) & lq_s1_fxu0_itag_match[i];		// Source 1 w/ FXU0 T2 Pipe
              assign lq_s1_fxu0_t3_match[i] = (lq_s1_q == fxu0_t3_q[i]) & lq_s1_fxu0_itag_match[i];		// Source 1 w/ FXU0 T3 Pipe
              assign lq_s2_fxu0_t1_match[i] = (lq_s2_q == fxu0_t1_q[i]) & lq_s2_fxu0_itag_match[i];		// Source 2 w/ FXU0 T1 Pipe
              assign lq_s2_fxu0_t2_match[i] = (lq_s2_q == fxu0_t2_q[i]) & lq_s2_fxu0_itag_match[i];		// Source 2 w/ FXU0 T2 Pipe
              assign lq_s2_fxu0_t3_match[i] = (lq_s2_q == fxu0_t3_q[i]) & lq_s2_fxu0_itag_match[i];		// Source 2 w/ FXU0 T3 Pipe
           end
      end
   endgenerate

   generate
      begin : xhdl11
         genvar                                         i;
         for (i = 4; i <= 8; i = i + 1)
           begin : comp_lq_lq
              assign lq_s1_lq_itag_match[i] = rv_byp_lq_ex0_s1_itag == lq_itag_q[i];
              assign lq_s2_lq_itag_match[i] = rv_byp_lq_ex0_s2_itag == lq_itag_q[i];
              assign lq_s1_lq_t1_match[i] = (lq_s1_q == lq_t1_q[i]) & lq_s1_lq_itag_match[i];		// Source 1 w/ LQ T1 Pipe
              assign lq_s1_lq_t2_match[i] = 1'b0;		// Source 1 w/ LQ T2 Pipe
              assign lq_s1_lq_t3_match[i] = (lq_s1_q == lq_t3_q[i]) & lq_s1_lq_itag_match[i];		// Source 1 w/ LQ T3 Pipe
              assign lq_s2_lq_t1_match[i] = (lq_s2_q == lq_t1_q[i]) & lq_s2_lq_itag_match[i];		// Source 2 w/ LQ T1 Pipe
              assign lq_s2_lq_t2_match[i] = 1'b0;		// Source 2 w/ LQ T2 Pipe
              assign lq_s2_lq_t3_match[i] = (lq_s2_q == lq_t3_q[i]) & lq_s2_lq_itag_match[i];		// Source 2 w/ LQ T3 Pipe
           end
      end
   endgenerate

   generate
      begin : xhdl12
         genvar                                         i;
         for (i = 2; i <= 7; i = i + 1)
           begin : comp_lq_fxu1
              assign lq_s1_fxu1_itag_match[i] = rv_byp_lq_ex0_s1_itag == fx1_itag_q[i];
              assign lq_s2_fxu1_itag_match[i] = rv_byp_lq_ex0_s2_itag == fx1_itag_q[i];
              assign lq_s1_fxu1_t1_match[i] = (lq_s1_q == fxu1_t1_q[i]) & lq_s1_fxu1_itag_match[i];		// Source 1 w/ FXU1 T1 Pipe
              assign lq_s1_fxu1_t2_match[i] = (lq_s1_q == fxu1_t2_q[i]) & lq_s1_fxu1_itag_match[i];		// Source 1 w/ FXU1 T2 Pipe
              assign lq_s1_fxu1_t3_match[i] = (lq_s1_q == fxu1_t3_q[i]) & lq_s1_fxu1_itag_match[i];		// Source 1 w/ FXU1 T3 Pipe
              assign lq_s2_fxu1_t1_match[i] = (lq_s2_q == fxu1_t1_q[i]) & lq_s2_fxu1_itag_match[i];		// Source 2 w/ FXU1 T1 Pipe
              assign lq_s2_fxu1_t2_match[i] = (lq_s2_q == fxu1_t2_q[i]) & lq_s2_fxu1_itag_match[i];		// Source 2 w/ FXU1 T2 Pipe
              assign lq_s2_fxu1_t3_match[i] = (lq_s2_q == fxu1_t3_q[i]) & lq_s2_fxu1_itag_match[i];		// Source 2 w/ FXU1 T3 Pipe
           end
      end
   endgenerate

   generate
      begin : xhdl13
         genvar                                         i;
         for (i = 2; i <= 3 ; i = i + 1)
           begin : comp_lq_rel
              assign lq_s1_rel_itag_match[i] = rv_byp_lq_ex0_s1_itag == rel_itag_q[i];
              assign lq_s2_rel_itag_match[i] = rv_byp_lq_ex0_s2_itag == rel_itag_q[i];
              assign lq_s1_rel_match[i] = (lq_s1_q == ({rel_vld_q[i], `gpr_t})) & lq_s1_rel_itag_match[i];		// Source 1 w/ rel T1 Pipe
              assign lq_s2_rel_match[i] = (lq_s2_q == ({rel_vld_q[i], `gpr_t})) & lq_s2_rel_itag_match[i];		// Source 1 w/ rel T1 Pipe
           end
      end
   endgenerate

   //----------------------------------------------------------------------------------------------------------------------------------------
   // Assign Outputs to LQ   -- Remove last bit, that is for write-back case
   //----------------------------------------------------------------------------------------------------------------------------------------.
   assign lq_ex0_s1_fx0_sel[2:12] = lq_s1_fxu0_t1_match | lq_s1_fxu0_t2_match | lq_s1_fxu0_t3_match;
   assign lq_ex0_s2_fx0_sel[2:12] = lq_s2_fxu0_t1_match | lq_s2_fxu0_t2_match | lq_s2_fxu0_t3_match;
   rv_pri #(.size(11)) lq_s1_fx0 (.cond(lq_ex0_s1_fx0_sel), .pri(rv_lq_ex0_s1_fx0_sel));
   rv_pri #(.size(11)) lq_s2_fx0 (.cond(lq_ex0_s2_fx0_sel), .pri(rv_lq_ex0_s2_fx0_sel));

   assign rv_lq_ex0_s1_lq_sel[4:8] = lq_s1_lq_t1_match | lq_s1_lq_t2_match | lq_s1_lq_t3_match;
   assign rv_lq_ex0_s2_lq_sel[4:8] = lq_s2_lq_t1_match | lq_s2_lq_t2_match | lq_s2_lq_t3_match;

   assign lq_ex0_s1_fx1_sel[2:7] = lq_s1_fxu1_t1_match | lq_s1_fxu1_t2_match | lq_s1_fxu1_t3_match;
   assign lq_ex0_s2_fx1_sel[2:7] = lq_s2_fxu1_t1_match | lq_s2_fxu1_t2_match | lq_s2_fxu1_t3_match;
   assign rv_lq_ex0_s1_fx1_sel[2:6] = lq_ex0_s1_fx1_sel[2:6];
   assign rv_lq_ex0_s2_fx1_sel[2:6] = lq_ex0_s2_fx1_sel[2:6];
   assign rv_lq_ex0_s1_fx1_sel[7]   = lq_ex0_s1_fx1_sel[7] & ~lq_ex0_s1_fx1_sel[2];
   assign rv_lq_ex0_s2_fx1_sel[7]   = lq_ex0_s2_fx1_sel[7] & ~lq_ex0_s2_fx1_sel[2];

   assign rv_lq_ex0_s1_rel_sel[2:3] = lq_s1_rel_match;
   assign rv_lq_ex0_s2_rel_sel[2:3] = lq_s2_rel_match;

   //----------------------------------------------------------------------------------------------------------------------------------------
   // BR Compares
   //----------------------------------------------------------------------------------------------------------------------------------------
   //----------------------------------------------------------------------------------------------------------------------------------------
   // Assign Outputs to BR   -- Remove last bit, that is for write-back case
   //----------------------------------------------------------------------------------------------------------------------------------------.

   //----------------------------------------------------------------------------------------------------------------------------------------
   // FXU1 Compares
   //----------------------------------------------------------------------------------------------------------------------------------------
   generate
      begin : xhdl14
         genvar                                         i;
         for (i = 1; i <= 11; i = i + 1)
           begin : comp_fxu1_fxu0
              assign fxu1_s1_fxu0_itag_match[i] = fx1_ex0_s1_itag_q == fx0_itag_q[i];
              assign fxu1_s2_fxu0_itag_match[i] = fx1_ex0_s2_itag_q == fx0_itag_q[i];
              assign fxu1_s3_fxu0_itag_match[i] = fx1_ex0_s3_itag_q == fx0_itag_q[i];
              assign fxu1_s1_fxu0_t1_match[i] = (fxu1_s1_q == fxu0_t1_q[i]) & fxu1_s1_fxu0_itag_match[i];		// Source 1 w/ FXU0 T1 Pipe
              assign fxu1_s1_fxu0_t2_match[i] = (fxu1_s1_q == fxu0_t2_q[i]) & fxu1_s1_fxu0_itag_match[i];		// Source 1 w/ FXU0 T2 Pipe
              assign fxu1_s1_fxu0_t3_match[i] = (fxu1_s1_q == fxu0_t3_q[i]) & fxu1_s1_fxu0_itag_match[i];		// Source 1 w/ FXU0 T3 Pipe
              assign fxu1_s2_fxu0_t1_match[i] = (fxu1_s2_q == fxu0_t1_q[i]) & fxu1_s2_fxu0_itag_match[i];		// Source 2 w/ FXU0 T1 Pipe
              assign fxu1_s2_fxu0_t2_match[i] = (fxu1_s2_q == fxu0_t2_q[i]) & fxu1_s2_fxu0_itag_match[i];		// Source 2 w/ FXU0 T2 Pipe
              assign fxu1_s2_fxu0_t3_match[i] = (fxu1_s2_q == fxu0_t3_q[i]) & fxu1_s2_fxu0_itag_match[i];		// Source 2 w/ FXU0 T3 Pipe
              assign fxu1_s3_fxu0_t1_match[i] = (fxu1_s3_q == fxu0_t1_q[i]) & fxu1_s3_fxu0_itag_match[i];		// Source 3 w/ FXU0 T1 Pipe
              assign fxu1_s3_fxu0_t2_match[i] = (fxu1_s3_q == fxu0_t2_q[i]) & fxu1_s3_fxu0_itag_match[i];		// Source 3 w/ FXU0 T2 Pipe
              assign fxu1_s3_fxu0_t3_match[i] = (fxu1_s3_q == fxu0_t3_q[i]) & fxu1_s3_fxu0_itag_match[i];		// Source 3 w/ FXU0 T3 Pipe
           end
      end
   endgenerate

   generate
      begin : xhdl15
         genvar                                         i;
         for (i = 4; i <= 8; i = i + 1)
           begin : comp_fxu1_lq
              assign fxu1_s1_lq_itag_match[i] = fx1_ex0_s1_itag_q == lq_itag_q[i];
              assign fxu1_s2_lq_itag_match[i] = fx1_ex0_s2_itag_q == lq_itag_q[i];
              assign fxu1_s3_lq_itag_match[i] = fx1_ex0_s3_itag_q == lq_itag_q[i];
              assign fxu1_s1_lq_t1_match[i] = (fxu1_s1_q == lq_t1_q[i]) & fxu1_s1_lq_itag_match[i];		// Source 1 w/ LQ T1 Pipe
              assign fxu1_s1_lq_t2_match[i] = 1'b0;		// Source 1 w/ LQ T2 Pipe
              assign fxu1_s1_lq_t3_match[i] = (fxu1_s1_q == lq_t3_q[i]) & fxu1_s1_lq_itag_match[i];		// Source 1 w/ LQ T3 Pipe
              assign fxu1_s2_lq_t1_match[i] = (fxu1_s2_q == lq_t1_q[i]) & fxu1_s2_lq_itag_match[i];		// Source 2 w/ LQ T1 Pipe
              assign fxu1_s2_lq_t2_match[i] = 1'b0;		// Source 2 w/ LQ T2 pipe
              assign fxu1_s2_lq_t3_match[i] = (fxu1_s2_q == lq_t3_q[i]) & fxu1_s2_lq_itag_match[i];		// Source 2 w/ LQ T3 Pipe
              assign fxu1_s3_lq_t1_match[i] = (fxu1_s3_q == lq_t1_q[i]) & fxu1_s3_lq_itag_match[i];		// Source 3 w/ LQ T1 Pipe
              assign fxu1_s3_lq_t2_match[i] = 1'b0;		// Source 3 w/ LQ T2 Pipe
              assign fxu1_s3_lq_t3_match[i] = (fxu1_s3_q == lq_t3_q[i]) & fxu1_s3_lq_itag_match[i];		// Source 3 w/ LQ T3 Pipe
           end
      end
   endgenerate

   generate
      begin : xhdl16
         genvar                                         i;
         for (i = 1; i <= 6; i = i + 1)
           begin : comp_fxu1_fxu1
              assign fxu1_s1_fxu1_itag_match[i] = fx1_ex0_s1_itag_q == fx1_itag_q[i];
              assign fxu1_s2_fxu1_itag_match[i] = fx1_ex0_s2_itag_q == fx1_itag_q[i];
              assign fxu1_s3_fxu1_itag_match[i] = fx1_ex0_s3_itag_q == fx1_itag_q[i];
              assign fxu1_s1_fxu1_t1_match[i] = (fxu1_s1_q == fxu1_t1_q[i]) & fxu1_s1_fxu1_itag_match[i];		// Source 1 w/ FXU1 T1 Pipe
              assign fxu1_s1_fxu1_t2_match[i] = (fxu1_s1_q == fxu1_t2_q[i]) & fxu1_s1_fxu1_itag_match[i];		// Source 1 w/ FXU1 T2 Pipe
              assign fxu1_s1_fxu1_t3_match[i] = (fxu1_s1_q == fxu1_t3_q[i]) & fxu1_s1_fxu1_itag_match[i];		// Source 1 w/ FXU1 T3 Pipe
              assign fxu1_s2_fxu1_t1_match[i] = (fxu1_s2_q == fxu1_t1_q[i]) & fxu1_s2_fxu1_itag_match[i];		// Source 2 w/ FXU1 T1 Pipe
              assign fxu1_s2_fxu1_t2_match[i] = (fxu1_s2_q == fxu1_t2_q[i]) & fxu1_s2_fxu1_itag_match[i];		// Source 2 w/ FXU1 T2 Pipe
              assign fxu1_s2_fxu1_t3_match[i] = (fxu1_s2_q == fxu1_t3_q[i]) & fxu1_s2_fxu1_itag_match[i];		// Source 2 w/ FXU1 T3 Pipe
              assign fxu1_s3_fxu1_t1_match[i] = (fxu1_s3_q == fxu1_t1_q[i]) & fxu1_s3_fxu1_itag_match[i];		// Source 3 w/ FXU1 T1 Pipe
              assign fxu1_s3_fxu1_t2_match[i] = (fxu1_s3_q == fxu1_t2_q[i]) & fxu1_s3_fxu1_itag_match[i];		// Source 3 w/ FXU1 T2 Pipe
              assign fxu1_s3_fxu1_t3_match[i] = (fxu1_s3_q == fxu1_t3_q[i]) & fxu1_s3_fxu1_itag_match[i];		// Source 3 w/ FXU1 T3 Pipe
           end
      end
   endgenerate

   generate
      begin : xhdl17
         genvar                                         i;
         for (i = 2; i <= 3 ; i = i + 1)
           begin : comp_fxu1_rel
              assign fxu1_s1_rel_itag_match[i] = fx1_ex0_s1_itag_q == rel_itag_q[i];
              assign fxu1_s2_rel_itag_match[i] = fx1_ex0_s2_itag_q == rel_itag_q[i];
              assign fxu1_s3_rel_itag_match[i] = fx1_ex0_s3_itag_q == rel_itag_q[i];
              assign fxu1_s1_rel_match[i] = (fxu1_s1_q == ({rel_vld_q[i], `gpr_t})) & fxu1_s1_rel_itag_match[i];		// Source 1 w/ rel T1 Pipe
              assign fxu1_s2_rel_match[i] = (fxu1_s2_q == ({rel_vld_q[i], `gpr_t})) & fxu1_s2_rel_itag_match[i];		// Source 1 w/ rel T1 Pipe
              assign fxu1_s3_rel_match[i] = (fxu1_s3_q == ({rel_vld_q[i], `gpr_t})) & fxu1_s3_rel_itag_match[i];		// Source 1 w/ rel T1 Pipe
           end
      end
   endgenerate

   //----------------------------------------------------------------------------------------------------------------------------------------
   // Assign Outputs to FXU1   -- Remove last bit, that is for write-back case
   //----------------------------------------------------------------------------------------------------------------------------------------.
   assign fx1_ex0_s1_fx0_sel[1:11] = fxu1_s1_fxu0_t1_match | fxu1_s1_fxu0_t2_match | fxu1_s1_fxu0_t3_match;
   assign fx1_ex0_s2_fx0_sel[1:11] = fxu1_s2_fxu0_t1_match | fxu1_s2_fxu0_t2_match | fxu1_s2_fxu0_t3_match;
   assign fx1_ex0_s3_fx0_sel[1:11] = fxu1_s3_fxu0_t1_match | fxu1_s3_fxu0_t2_match | fxu1_s3_fxu0_t3_match;
   rv_pri #(.size(11)) fx1_s1_fx0 (.cond(fx1_ex0_s1_fx0_sel), .pri(rv_fx1_ex0_s1_fx0_sel));
   rv_pri #(.size(11)) fx1_s2_fx0 (.cond(fx1_ex0_s2_fx0_sel), .pri(rv_fx1_ex0_s2_fx0_sel));
   rv_pri #(.size(11)) fx1_s3_fx0 (.cond(fx1_ex0_s3_fx0_sel), .pri(rv_fx1_ex0_s3_fx0_sel));

   assign rv_fx1_ex0_s1_lq_sel[4:8] = fxu1_s1_lq_t1_match | fxu1_s1_lq_t2_match | fxu1_s1_lq_t3_match;
   assign rv_fx1_ex0_s2_lq_sel[4:8] = fxu1_s2_lq_t1_match | fxu1_s2_lq_t2_match | fxu1_s2_lq_t3_match;
   assign rv_fx1_ex0_s3_lq_sel[4:8] = fxu1_s3_lq_t1_match | fxu1_s3_lq_t2_match | fxu1_s3_lq_t3_match;

   assign fx1_ex0_s1_fx1_sel[1:6] = fxu1_s1_fxu1_t1_match | fxu1_s1_fxu1_t2_match | fxu1_s1_fxu1_t3_match;
   assign fx1_ex0_s2_fx1_sel[1:6] = fxu1_s2_fxu1_t1_match | fxu1_s2_fxu1_t2_match | fxu1_s2_fxu1_t3_match;
   assign fx1_ex0_s3_fx1_sel[1:6] = fxu1_s3_fxu1_t1_match | fxu1_s3_fxu1_t2_match | fxu1_s3_fxu1_t3_match;
   assign rv_fx1_ex0_s1_fx1_sel[1:5] = fx1_ex0_s1_fx1_sel[1:5];
   assign rv_fx1_ex0_s2_fx1_sel[1:5] = fx1_ex0_s2_fx1_sel[1:5];
   assign rv_fx1_ex0_s3_fx1_sel[1:5] = fx1_ex0_s3_fx1_sel[1:5];
   assign rv_fx1_ex0_s1_fx1_sel[6]   = fx1_ex0_s1_fx1_sel[6] & ~fx1_ex0_s1_fx1_sel[1];
   assign rv_fx1_ex0_s2_fx1_sel[6]   = fx1_ex0_s2_fx1_sel[6] & ~fx1_ex0_s2_fx1_sel[1];
   assign rv_fx1_ex0_s3_fx1_sel[6]   = fx1_ex0_s3_fx1_sel[6] & ~fx1_ex0_s3_fx1_sel[1];

   assign rv_fx1_ex0_s1_rel_sel = fxu1_s1_rel_match;
   assign rv_fx1_ex0_s2_rel_sel = fxu1_s2_rel_match;
   assign rv_fx1_ex0_s3_rel_sel = fxu1_s3_rel_match;

   //----------------------------------------------------------------------------------------------------------------------------------------
   // FX0 RV Release, based on ilat
   //----------------------------------------------------------------------------------------------------------------------------------------
   assign fx0_ex2_abort = (fx0_rv_ex2_s1_abort | fx0_rv_ex2_s2_abort | fx0_rv_ex2_s3_abort) & |(fx0_vld_q[2]) ;

   assign fx0_act[0] = |(rv_byp_fx0_vld);
   assign fx0_act[1] = |(fx0_vld_q[0]);
   assign fx0_act[2] = |(fx0_vld_q[1]);
   assign fx0_act[3] = |(fx0_vld_q[2]) | fx0_insert_ord;
   assign fx0_act[4] = |(fx0_vld_q[3]);
   assign fx0_act[5] = |(fx0_vld_q[4]) | fx0_mult_recirc;
   assign fx0_act[6] = |(fx0_vld_q[5]);
   assign fx0_act[7] = |(fx0_vld_q[6]);
   assign fx0_act[8] = |(fx0_vld_q[7]);
   assign fx0_act[9] = |(fx0_vld_q[8]);
   assign fx0_act[10] = |(fx0_vld_q[9]);
   assign fx0_act[11] = |(fx0_vld_q[10]);
   assign fx0_act[12] = |(fx0_vld_q[11]);

   assign fx0_vld_d[0] = rv_byp_fx0_vld & (~(cp_flush_q));
   assign fx0_vld_d[1] = fx0_vld_q[0] & (~cp_flush_q);
   assign fx0_vld_d[2] = fx0_vld_q[1] & (~cp_flush_q);
   assign fx0_vld_d[3] = (fx0_vld_q[2] | ({`THREADS{fx0_insert_ord}} & fx0_rv_ord_tid)) & (~cp_flush_q);
   assign fx0_vld_d[4] = fx0_vld_q[3] & (~cp_flush_q);
   assign fx0_vld_d[5] = ((fx0_vld_q[4] & {`THREADS{~fx0_mult_recirc}}) |
                          (fx0_vld_q[5] & {`THREADS{fx0_ex5_mult_recirc}}) |
                          (fx0_vld_q[6] & {`THREADS{fx0_ex6_mult_recirc}}) |
                          (fx0_vld_q[7] & {`THREADS{fx0_ex7_mult_recirc}}) ) & (~cp_flush_q);
   assign fx0_vld_d[6] = fx0_vld_q[5] & (~cp_flush_q);
   assign fx0_vld_d[7] = fx0_vld_q[6] & (~cp_flush_q);
   assign fx0_vld_d[8] = fx0_vld_q[7] & (~cp_flush_q);
   assign fx0_vld_d[9] = fx0_vld_q[8] & (~cp_flush_q);
   assign fx0_vld_d[10] = fx0_vld_q[9] & (~cp_flush_q);
   assign fx0_vld_d[11] = fx0_vld_q[10] & (~cp_flush_q);

   assign fx0_is_brick_d[1] = rv_byp_fx0_ex0_is_brick;
   assign fx0_is_brick_d[2] = fx0_is_brick_q[1];
   assign fx0_is_brick_d[3] = fx0_is_brick_q[2];
   assign fx0_is_brick_d[4] = fx0_is_brick_q[3];
   assign fx0_is_brick_d[5] = fx0_is_brick_q[4];
   assign fx0_is_brick_d[6] = fx0_is_brick_q[5];
   assign fx0_is_brick_d[7] = fx0_is_brick_q[6];


   assign fx0_abort_d[3] = fx0_ex2_abort;
   assign fx0_abort_d[4] = fx0_abort_q[3];

   // Itag Pipe
   assign fx0_itag_d[0] = rv_byp_fx0_itag;
   assign fx0_itag_d[1] = fx0_itag_q[0];
   assign fx0_itag_d[2] = fx0_itag_q[1];
   assign fx0_itag_d[3] = (fx0_itag_q[2] & {`ITAG_SIZE_ENC{(~fx0_insert_ord)}}) | (fx0_rv_ord_itag & {`ITAG_SIZE_ENC{fx0_insert_ord}});
   assign fx0_itag_d[4] = fx0_itag_q[3];
   assign fx0_itag_d[5] = (fx0_itag_q[4] & {`ITAG_SIZE_ENC{(~fx0_mult_recirc)}}) |
			  (fx0_itag_q[5] & {`ITAG_SIZE_ENC{( fx0_ex5_mult_recirc)}}) |
			  (fx0_itag_q[6] & {`ITAG_SIZE_ENC{( fx0_ex6_mult_recirc)}}) |
			  (fx0_itag_q[7] & {`ITAG_SIZE_ENC{( fx0_ex7_mult_recirc)}}) ;

   generate
      begin : xhdl18i
         genvar                                         i;
         for (i = 6; i <= 12; i = i + 1)
           begin : fxu0_itag_d_gen
              assign fx0_itag_d[i]  = fx0_itag_q[i-1];
           end
      end
   endgenerate

   // Ilat Pipe
   assign fx0_ex0_ilat_d = rv_byp_fx0_ilat;
   assign fx0_ex1_ilat_d = fx0_ex0_ilat_q;
   assign fx0_ex2_ilat_d = fx0_ex1_ilat_q ;
   assign fx0_ex3_ilat_d = fx0_ex2_ilat_q & {4{(~fx0_insert_ord)}};
   assign fx0_ex4_ilat_d = fx0_ex3_ilat_q & ~{4{fx0_ex3_ord_flush_q & (fx0_ex3_ilat_q != 4'b1111)}};  //If ordered was aborted, release asap (unless it is ilat F)
   assign fx0_ex5_ilat_d = fx0_ex4_ilat_q;
   assign fx0_ex6_ilat_d = fx0_ex5_ilat_q;
   assign fx0_ex7_ilat_d = fx0_ex6_ilat_q;
   assign fx0_ex8_ilat_d = fx0_ex7_ilat_q;

   // Match instruction latency with their location in the pipeline
   assign fx0_rv1_ilat_match = |(rv_byp_fx0_ilat0_vld | rv_byp_fx0_ilat1_vld);		//ilat 0 or 1

   assign fx0_ex0_fast_match = ((fx0_ex0_ilat_q <= 4'b0010));
   assign fx0_ex0_ilat_match = ((fx0_ex0_ilat_q <= 4'b0011));
   assign fx0_ex1_ilat_match = ((fx0_ex1_ilat_q <= 4'b0100));
   assign fx0_ex2_ilat_match = (fx0_ex2_ilat_q <= 4'b0101);
   assign fx0_ex3_ilat_match = (fx0_ex3_ilat_q <= 4'b0110) | (fx0_ex3_ord_flush_q & (fx0_ex3_ilat_q != 4'b1111));

   assign fx0_ex4_ilat_match = (fx0_ex4_ilat_q <= 4'b0111);

   //Store data can't be bypassed (updates)
   assign fx0_ex0_stq_pipe_val = 1'b0;

   // Intructions are in correct pipeline stage to allow dependent op release, and they have not been released yet
   assign fx0_ex0_sched_rel[9] = (fx0_ex0_ilat_match & fx0_need_rel_q[0] & (~(fx0_sched_rel_ex0_fast | fx0_ex0_stq_pipe_val)) & (~|(fx0_vld_q[0] & cp_flush_q)));
   assign fx0_ex0_sched_rel[8] = fx0_ex1_ilat_match & fx0_need_rel_q[1] & ~|(fx0_vld_q[1] & cp_flush_q);
   assign fx0_ex0_sched_rel[7] = fx0_ex2_ilat_match & fx0_need_rel_q[2] & ~|(fx0_vld_q[2] & cp_flush_q);
   assign fx0_ex0_sched_rel[6] = fx0_ex3_ilat_match & fx0_need_rel_q[3] & ~|(fx0_vld_q[3] & cp_flush_q);
   assign fx0_ex0_sched_rel[5] = fx0_ex4_ilat_match & fx0_need_rel_q[4] & ~|(fx0_vld_q[4] & cp_flush_q);        //need this case to kill ord rel when cmplt same cycle as flush
   assign fx0_ex0_sched_rel[4] = 1'b0;
   assign fx0_ex0_sched_rel[3] = 1'b0;
   assign fx0_ex0_sched_rel[2] = 1'b0;
   assign fx0_ex0_sched_rel[1] = 1'b0;
   assign fx0_ex0_sched_rel[0] = 1'b0;


   assign fx0_byp_rdy_nxt_0 = |rv_byp_fx0_ilat0_vld  ;
   assign fx0_byp_rdy_nxt[0] = {`THREADS{ (fx0_ex0_ilat_q == 4'b0001) }} & fx0_vld_q[0];
   assign fx0_byp_rdy_nxt[1] = {`THREADS{ (fx0_ex1_ilat_q == 4'b0010) }} & fx0_vld_q[1];
   assign fx0_byp_rdy_nxt[2] = {`THREADS{ (fx0_ex2_ilat_q == 4'b0011) }} & fx0_vld_q[2];
   assign fx0_byp_rdy_nxt[3] = {`THREADS{ (fx0_ex3_ilat_q == 4'b0100) }} & fx0_vld_q[3];
   assign fx0_byp_rdy_nxt[4] = {`THREADS{ (fx0_ex4_ilat_q == 4'b0101) }} & fx0_vld_q[4];
   assign fx0_byp_rdy_nxt[5] = {`THREADS{ (fx0_ex5_ilat_q == 4'b0110) }} & fx0_vld_q[5];
   assign fx0_byp_rdy_nxt[6] = {`THREADS{ (fx0_ex6_ilat_q == 4'b0111) }} & fx0_vld_q[6];
   assign fx0_byp_rdy_nxt[7] = {`THREADS{ (fx0_ex7_ilat_q == 4'b1000) }} & fx0_vld_q[7];
   assign fx0_byp_rdy_nxt[8] = {`THREADS{ (fx0_ex8_ilat_q == 4'b1001) }} & fx0_vld_q[8];
   assign fx0_byp_rdy_nxt[9] = {`THREADS{ 1'b0}};
   assign fx0_byp_rdy_nxt[10] = {`THREADS{1'b0}};
   assign fx0_byp_rdy_nxt[11] = {`THREADS{1'b0}};


   // Prioritize.  EX6 gets highest priority (Will be latched)

   rv_pri #(.size(10)) fx0_release_pri(
                                       .cond(fx0_ex0_sched_rel),
                                       .pri(fx0_ex0_sched_rel_pri)
                                       );

   // Use prioritized schedule to determine which stage to release itag/vld out of (Will be latched)
   assign fx0_rel_itag_d =
			   (fx0_itag_q[4] & {`ITAG_SIZE_ENC{fx0_ex0_sched_rel_pri[5]}}) |
			   (fx0_itag_q[3] & {`ITAG_SIZE_ENC{fx0_ex0_sched_rel_pri[6]}}) |
			   (fx0_itag_q[2] & {`ITAG_SIZE_ENC{fx0_ex0_sched_rel_pri[7]}}) |
			   (fx0_itag_q[1] & {`ITAG_SIZE_ENC{fx0_ex0_sched_rel_pri[8]}}) |
			   (fx0_itag_q[0] & {`ITAG_SIZE_ENC{fx0_ex0_sched_rel_pri[9]}});


   assign fx0_rel_itag_vld_d = (
				(fx0_vld_q[4] & {`THREADS{fx0_ex0_sched_rel_pri[5]}}) |
				(fx0_vld_q[3] & {`THREADS{fx0_ex0_sched_rel_pri[6]}}) |
				(fx0_vld_q[2] & {`THREADS{fx0_ex0_sched_rel_pri[7]}}) |
				(fx0_vld_q[1] & {`THREADS{fx0_ex0_sched_rel_pri[8]}}) |
				(fx0_vld_q[0] & {`THREADS{fx0_ex0_sched_rel_pri[9]}}) ) & ~cp_flush_q;

   assign fx0_rel_itag_abort_d =
				 (fx0_abort_q[4] & fx0_ex0_sched_rel_pri[5]) |
				 (fx0_abort_q[3] & fx0_ex0_sched_rel_pri[6]) ;

   // | and invert in this cycle so select for outbound mux is fast
   assign fx0_sched_rel_pri_or_d = (~|(fx0_ex0_sched_rel_pri));

   // Check fast releases released?
   assign fx0_sched_rel_rv = fx0_rv1_ilat_match & fx0_sched_rel_pri_or_q & (~fx0_sched_rel_ex0_fast);
   assign fx0_rv1_ilat0 = |(rv_byp_fx0_ilat0_vld);
   assign fx0_sched_rel_rv_ilat0 = fx0_rv1_ilat0 & fx0_sched_rel_pri_or_q & (~fx0_sched_rel_ex0_fast);

   assign fx0_sched_rel_ex0_fast = fx0_ex0_fast_match & |(fx0_vld_q[0] ) & fx0_sched_rel_pri_or_q & fx0_need_rel_q[0];

   // Pipeline to keep track of instructions that have not been released yet
   assign fx0_need_rel_d[0] = |(rv_byp_fx0_vld & (~cp_flush_q)) & (~fx0_sched_rel_rv) & (~rv_byp_fx0_ord);
   assign fx0_need_rel_d[1] = (fx0_need_rel_q[0] & (~(fx0_ex0_sched_rel_pri[9] | fx0_sched_rel_ex0_fast | fx0_ex0_stq_pipe_val)) & (~|(fx0_vld_q[0] & cp_flush_q))) ;
   assign fx0_need_rel_d[2] = fx0_need_rel_q[1] & (~fx0_ex0_sched_rel_pri[8]) & (~|(cp_flush_q & fx0_vld_q[1]));
   assign fx0_need_rel_d[3] = ((fx0_need_rel_q[2] & (~fx0_ex0_sched_rel_pri[7])) | (fx0_insert_ord | fx0_ex2_abort)) & (~|(cp_flush_q & fx0_vld_q[2]));
   assign fx0_need_rel_d[4] = fx0_need_rel_q[3] & (~fx0_ex0_sched_rel_pri[6]) & (~|(cp_flush_q & fx0_vld_q[3]));

   // 0 bubble case (need to do it last to handle quick dependency turnaround, after the latch for timing)
   // Send itag off priority queue to release dependent ops
   assign fx0_rv_itag_int = ({fx0_sched_rel_rv, fx0_sched_rel_ex0_fast} == 2'b10) ? rv_byp_fx0_itag : 		// 1 bubble case
                            ({fx0_sched_rel_rv, fx0_sched_rel_ex0_fast} == 2'b01) ? fx0_itag_q[0] :
                                                                         fx0_rel_itag_q;

   assign fx0_rv_itag_vld_int = ({fx0_sched_rel_rv, fx0_sched_rel_ex0_fast} == 2'b10) ? rv_byp_fx0_vld :
                                ({fx0_sched_rel_rv, fx0_sched_rel_ex0_fast} == 2'b01) ? fx0_vld_q[0] :
                                fx0_rel_itag_vld_q;

   assign fx0_rv_itag_abort_int = fx0_rel_itag_abort_q & ~(fx0_sched_rel_rv | fx0_sched_rel_ex0_fast);

   assign fx0_rv_itag = fx0_rv_itag_int;
   assign fx0_rv_itag_vld = fx0_rv_itag_vld_int;
   assign fx0_rv_itag_abort = fx0_rv_itag_abort_int;

   assign fx0_ext_rel_itag_d = fx0_rv_itag_int;
   assign fx0_ext_rel_itag_vld_d = fx0_rv_itag_vld_int & {`THREADS{~(fx0_ext_itag0_sel_d)}} & ~cp_flush_q;
   assign fx0_ext_rel_itag_abort_d = fx0_rv_itag_abort_int;

   // ilat0 can go only if theres a slot
   assign fx0_ext_itag0_sel_d = fx0_sched_rel_rv_ilat0 & (~fx0_ext_ilat_gt_1_need_rel);
   assign fx0_ext_ilat_gt_1_need_rel = |(fx0_ext_rel_itag_vld_q) & (~(fx0_ext_itag0_sel_q));

   assign fx0_rv_ext_itag = ((fx0_sched_rel_rv_ilat0 & (~fx0_ext_ilat_gt_1_need_rel)) == 1'b1) ? rv_byp_fx0_itag :
                            fx0_ext_rel_itag_q;

   assign fx0_rv_ext_itag_vld = ((fx0_sched_rel_rv_ilat0 & (~fx0_ext_ilat_gt_1_need_rel)) == 1'b1) ? rv_byp_fx0_vld : 		//ex2
                                fx0_ext_rel_itag_vld_q;

   assign fx0_rv_ext_itag_abort = fx0_ext_rel_itag_abort_q & ~(fx0_sched_rel_rv_ilat0 & (~fx0_ext_ilat_gt_1_need_rel));

   assign fx0_insert_ord = fx0_rv_ord_complete & (~|(fx0_rv_ord_tid & cp_flush_q));


   //Ordered release goes with the dep release
   assign fx0_ex3_ord_rel_d = {`THREADS{fx0_rv_ord_complete}} & fx0_rv_ord_tid & (~cp_flush_q);
   assign fx0_ex4_ord_rel_d = fx0_ex3_ord_rel_q & (~cp_flush_q) & {`THREADS{(~fx0_ex0_sched_rel_pri[6])}};
   assign fx0_ex5_ord_rel_d = fx0_ex4_ord_rel_q & (~cp_flush_q) & {`THREADS{(~fx0_ex0_sched_rel_pri[5])}};
   assign fx0_ex6_ord_rel_d = fx0_ex5_ord_rel_q & (~cp_flush_q) & {`THREADS{(~fx0_ex0_sched_rel_pri[4])}};
   assign fx0_ex7_ord_rel_d = fx0_ex6_ord_rel_q & (~cp_flush_q) & {`THREADS{(~fx0_ex0_sched_rel_pri[3])}};
   assign fx0_ex8_ord_rel_d = fx0_ex7_ord_rel_q & (~cp_flush_q) & {`THREADS{(~fx0_ex0_sched_rel_pri[2])}};

   assign fx0_release_ord_hold_d = (
				    (fx0_vld_q[8] & fx0_ex8_ord_rel_q & {`THREADS{fx0_ex0_sched_rel_pri[1]}}) |
				    (fx0_vld_q[7] & fx0_ex7_ord_rel_q & {`THREADS{fx0_ex0_sched_rel_pri[2]}}) |
				    (fx0_vld_q[6] & fx0_ex6_ord_rel_q & {`THREADS{fx0_ex0_sched_rel_pri[3]}}) |
				    (fx0_vld_q[5] & fx0_ex5_ord_rel_q & {`THREADS{fx0_ex0_sched_rel_pri[4]}}) |
				    (fx0_vld_q[4] & fx0_ex4_ord_rel_q & {`THREADS{fx0_ex0_sched_rel_pri[5]}}) |
				    (fx0_vld_q[3] & fx0_ex3_ord_rel_q & {`THREADS{fx0_ex0_sched_rel_pri[6]}}) | ex3_ord_flush) & (~cp_flush_q);

   assign fx0_release_ord_hold = fx0_release_ord_hold_q;

   // If an ordered op gets a spec_flush, release the ord_hold (but not the dependency release bus)
   assign ex3_ord_flush = ({`THREADS{fx0_ex3_ord_flush_q}} & fx0_vld_q[3]);

   assign fx0_ex0_ord_d = rv_byp_fx0_ord;
   assign fx0_ex1_ord_d = fx0_ex0_ord_q;
   assign fx0_ex2_ord_d = fx0_ex1_ord_q;
   assign fx0_ex3_ord_flush_d = fx0_ex2_ord_q & fx0_ex2_abort ;

   //----------------------------------------------------------------------------------------------------------------------------------------
   // FX1 RV Release, based on ilat
   //----------------------------------------------------------------------------------------------------------------------------------------
   assign fx1_ex2_abort = (fx1_rv_ex2_s1_abort | fx1_rv_ex2_s2_abort | fx1_rv_ex2_s3_abort) & ~fx1_ex2_stq_pipe_q & |(fx1_vld_q[2]);

   assign fx1_act[0] = |(rv_byp_fx1_vld);
   assign fx1_act[1] = |(fx1_vld_q[0]);
   assign fx1_act[2] = |(fx1_vld_q[1]);
   assign fx1_act[3] = |(fx1_vld_q[2]);
   assign fx1_act[4] = |(fx1_vld_q[3]);
   assign fx1_act[5] = |(fx1_vld_q[4]);
   assign fx1_act[6] = |(fx1_vld_q[5]);
   assign fx1_act[7] = |(fx1_vld_q[6]);

   assign fx1_itag_d[0] = rv_byp_fx1_itag;
   assign fx1_vld_d[0] = rv_byp_fx1_vld & (~cp_flush_q);
   generate
      begin : xhdl19v
         genvar                                         i;
         for (i = 1; i <= 6; i = i + 1)
           begin : fxu1_vld_d_gen
              assign fx1_vld_d[i] = fx1_vld_q[i - 1] & (~cp_flush_q);
           end
      end
   endgenerate
   generate
      begin : xhdl19
         genvar                                         i;
         for (i = 1; i <= 7; i = i + 1)
           begin : fxu1_itag_d_gen
              assign fx1_itag_d[i] = fx1_itag_q[i - 1];
           end
      end
   endgenerate

   assign fx1_abort_d[3] = fx1_ex2_abort;
   assign fx1_abort_d[4] = fx1_abort_q[3];

   // Ilat Pipe
   assign fx1_ex0_ilat_d = rv_byp_fx1_ilat[1:3];
   assign fx1_ex1_ilat_d = fx1_ex0_ilat_q;
   assign fx1_ex2_ilat_d = fx1_ex1_ilat_q;
   assign fx1_ex3_ilat_d = fx1_ex2_ilat_q;
   assign fx1_ex4_ilat_d = fx1_ex3_ilat_q;
   assign fx1_ex5_ilat_d = fx1_ex4_ilat_q;
   assign fx1_ex6_ilat_d = fx1_ex5_ilat_q;

   // Match instruction latency with their location in the pipeline
   assign fx1_rv1_ilat_match = |(rv_byp_fx1_ilat0_vld | rv_byp_fx1_ilat1_vld);		//ilat 0 or 1
   assign fx1_ex0_fast_match = (fx1_ex0_ilat_q <= 3'b010);
   assign fx1_ex0_ilat_match = (fx1_ex0_ilat_q <= 3'b011);
   assign fx1_ex1_ilat_match = (fx1_ex1_ilat_q <= 3'b100);
   assign fx1_ex2_ilat_match = (fx1_ex2_ilat_q <= 3'b101);
   assign fx1_ex3_ilat_match = (fx1_ex3_ilat_q <= 3'b110);

   //Store Data.  Don't release, or abort on the release bus
   assign fx1_ex0_stq_pipe_val = rv_byp_fx1_ex0_isStore;
   assign fx1_ex1_stq_pipe_d = fx1_ex0_stq_pipe_val;
   assign fx1_ex2_stq_pipe_d = fx1_ex1_stq_pipe_q;

   // Intructions are in correct pipeline stage to allow dependent op release, and they have not been released yet
   assign fx1_ex0_sched_rel[4] = (fx1_ex0_ilat_match & fx1_ex0_need_rel_q & (~(fx1_sched_rel_ex0_fast | fx1_ex0_stq_pipe_val)) & (~|(fx1_vld_q[0] & cp_flush_q )));
   assign fx1_ex0_sched_rel[3] = fx1_ex1_ilat_match & fx1_ex1_need_rel_q & (~|(fx1_vld_q[1] & cp_flush_q ));
   assign fx1_ex0_sched_rel[2] = fx1_ex2_ilat_match & fx1_ex2_need_rel_q & (~|(fx1_vld_q[2] & cp_flush_q ));
   assign fx1_ex0_sched_rel[1] = fx1_ex3_ilat_match & fx1_ex3_need_rel_q & (~|(fx1_vld_q[3] & cp_flush_q ));
   assign fx1_ex0_sched_rel[0] = 1'b0;

   assign fx1_byp_rdy_nxt_0 =  |rv_byp_fx1_ilat0_vld ;
   assign fx1_byp_rdy_nxt[0] = {`THREADS{ (fx1_ex0_ilat_q == 3'b001) }} & fx1_vld_q[0];
   assign fx1_byp_rdy_nxt[1] = {`THREADS{ (fx1_ex1_ilat_q == 3'b010) }} & fx1_vld_q[1];
   assign fx1_byp_rdy_nxt[2] = {`THREADS{ (fx1_ex2_ilat_q == 3'b011) & ~fx1_ex2_stq_pipe_q }} & fx1_vld_q[2];
   assign fx1_byp_rdy_nxt[3] = {`THREADS{ (fx1_ex3_ilat_q == 3'b100) }} & fx1_vld_q[3];
   assign fx1_byp_rdy_nxt[4] = {`THREADS{ (fx1_ex4_ilat_q == 3'b101) }} & fx1_vld_q[4];
   assign fx1_byp_rdy_nxt[5] = {`THREADS{ (fx1_ex5_ilat_q == 3'b110) }} & fx1_vld_q[5];
   assign fx1_byp_rdy_nxt[6] = {`THREADS{ (fx1_ex6_ilat_q == 3'b111) }} & fx1_vld_q[6];

   // Prioritize.  EX6 gets highest priority (Will be latched)

   rv_pri #(.size(5)) fx1_release_pri(
                                      .cond(fx1_ex0_sched_rel),
                                      .pri(fx1_ex0_sched_rel_pri)
                                      );

   // Use prioritized schedule to determine which stage to release itag/vld out of (Will be latched)
   assign fx1_rel_itag_d = (fx1_itag_q[4] & {`ITAG_SIZE_ENC{fx1_ex0_sched_rel_pri[0]}}) |
			   (fx1_itag_q[3] & {`ITAG_SIZE_ENC{fx1_ex0_sched_rel_pri[1]}}) |
			   (fx1_itag_q[2] & {`ITAG_SIZE_ENC{fx1_ex0_sched_rel_pri[2]}}) |
			   (fx1_itag_q[1] & {`ITAG_SIZE_ENC{fx1_ex0_sched_rel_pri[3]}}) |
			   (fx1_itag_q[0] & {`ITAG_SIZE_ENC{fx1_ex0_sched_rel_pri[4]}});		//       when "10000",

   assign fx1_rel_itag_vld_d = ((fx1_vld_q[4] & {`THREADS{fx1_ex0_sched_rel_pri[0]}}) |
				(fx1_vld_q[3] & {`THREADS{fx1_ex0_sched_rel_pri[1]}}) |
				(fx1_vld_q[2] & {`THREADS{fx1_ex0_sched_rel_pri[2]}}) |
				(fx1_vld_q[1] & {`THREADS{fx1_ex0_sched_rel_pri[3]}}) |
				(fx1_vld_q[0] & {`THREADS{fx1_ex0_sched_rel_pri[4]}}) ) & ~cp_flush_q;		//       when "10000",

   assign fx1_rel_itag_abort_d = (fx1_abort_q[4] & fx1_ex0_sched_rel_pri[0]) |
				 (fx1_abort_q[3] & fx1_ex0_sched_rel_pri[1]) ;

   // | and invert in this cycle so select for outbound mux is fast
   assign fx1_sched_rel_pri_or_d = (~|(fx1_ex0_sched_rel_pri));

   // Check fast releases released?
   assign fx1_sched_rel_rv = fx1_rv1_ilat_match & fx1_sched_rel_pri_or_q & (~fx1_sched_rel_ex0_fast);
   assign fx1_rv1_ilat0 = |(rv_byp_fx1_ilat0_vld);
   assign fx1_sched_rel_rv_ilat0 = fx1_rv1_ilat0 & fx1_sched_rel_pri_or_q & (~fx1_sched_rel_ex0_fast);

   assign fx1_sched_rel_ex0_fast = fx1_ex0_fast_match & |(fx1_vld_q[0]) & fx1_sched_rel_pri_or_q & fx1_ex0_need_rel_q;

   // Pipeline to keep track of instructions that have not been released yet
   assign fx1_ex0_need_rel_d = |(rv_byp_fx1_vld & (~cp_flush_q)) & (~fx1_sched_rel_rv);
   assign fx1_ex1_need_rel_d = (fx1_ex0_need_rel_q & (~(fx1_ex0_sched_rel_pri[4] | fx1_sched_rel_ex0_fast | fx1_ex0_stq_pipe_val)) & (~|(fx1_vld_q[0] & cp_flush_q ))) ;

   assign fx1_ex2_need_rel_d = fx1_ex1_need_rel_q & (~fx1_ex0_sched_rel_pri[3]) & (~|(fx1_vld_q[1] & cp_flush_q));
   assign fx1_ex3_need_rel_d = ((fx1_ex2_need_rel_q & (~fx1_ex0_sched_rel_pri[2])) | fx1_ex2_abort) & (~|(fx1_vld_q[2] & cp_flush_q));

   // 0 bubble case (need to do it last to handle quick dependency turnaround, after the latch for timing)
   // Send itag off priority queue to release dependent ops
   assign fx1_rv_itag_int = ({fx1_sched_rel_rv, fx1_sched_rel_ex0_fast} == 2'b10) ? rv_byp_fx1_itag : 		// 1 bubble case
                            ({fx1_sched_rel_rv, fx1_sched_rel_ex0_fast} == 2'b01) ? fx1_itag_q[0] :
                                                                         fx1_rel_itag_q;
   assign fx1_rv_itag_vld_int = ({fx1_sched_rel_rv, fx1_sched_rel_ex0_fast} == 2'b10) ? rv_byp_fx1_vld :
                                ({fx1_sched_rel_rv, fx1_sched_rel_ex0_fast} == 2'b01) ? fx1_vld_q[0] :
                                fx1_rel_itag_vld_q;
   assign fx1_rv_itag_abort_int = fx1_rel_itag_abort_q & ~(fx1_sched_rel_rv | fx1_sched_rel_ex0_fast);

   assign fx1_rv_itag = fx1_rv_itag_int;
   assign fx1_rv_itag_vld = fx1_rv_itag_vld_int;
   assign fx1_rv_itag_abort = fx1_rv_itag_abort_int;

   assign fx1_ext_rel_itag_d = fx1_rv_itag_int;
   assign fx1_ext_rel_itag_vld_d = fx1_rv_itag_vld_int & {`THREADS{~( fx1_ext_itag0_sel_d)}} & ~cp_flush_q;
   assign fx1_ext_rel_itag_abort_d = fx1_rv_itag_abort_int;

   // ilat0 can go only if theres a slot
   assign fx1_ext_itag0_sel_d = fx1_sched_rel_rv_ilat0 & (~fx1_ext_ilat_gt_1_need_rel);
   assign fx1_ext_ilat_gt_1_need_rel = |(fx1_ext_rel_itag_vld_q) & (~(fx1_ext_itag0_sel_q));

   assign fx1_rv_ext_itag_vld = ((fx1_sched_rel_rv_ilat0 & (~fx1_ext_ilat_gt_1_need_rel)) == 1'b1) ? rv_byp_fx1_vld : 		//ex2
                                fx1_ext_rel_itag_vld_q;

   assign fx1_rv_ext_itag = ((fx1_sched_rel_rv_ilat0 & (~fx1_ext_ilat_gt_1_need_rel)) == 1'b1) ? rv_byp_fx1_itag :
                            fx1_ext_rel_itag_q;
   assign fx1_rv_ext_itag_abort = fx1_ext_rel_itag_abort_q & ~(fx1_sched_rel_rv_ilat0 & (~fx1_ext_ilat_gt_1_need_rel));


   assign lq_itag_d[0] = rv_byp_lq_itag;
   generate
      begin : xhdl20
         genvar                                         i;
         for (i = 1; i <= 8; i = i + 1)
           begin : lq_itag_d_gen
              assign lq_itag_d[i] = lq_itag_q[i - 1];
           end
      end
   endgenerate

   assign lq_act[0] = |(rv_byp_lq_vld);
   assign lq_act[1] = |(lq_vld_q[0]);
   assign lq_act[2] = |(lq_vld_q[1]);
   assign lq_act[3] = |(lq_vld_q[2]);
   assign lq_act[4] = |(lq_vld_q[3]);
   assign lq_act[5] = |(lq_vld_q[4]);
   assign lq_act[6] = |(lq_vld_q[5]);
   assign lq_act[7] = |(lq_vld_q[6]);
   assign lq_act[8] = |(lq_vld_q[7]);

   assign lq_vld_d[0] = rv_byp_lq_vld;
   assign lq_vld_d[1] = lq_vld_q[0];
   assign lq_vld_d[2] = lq_vld_q[1];
   assign lq_vld_d[3] = lq_vld_q[2];
   assign lq_vld_d[4] = lq_vld_q[3];
   assign lq_vld_d[5] = lq_vld_q[4];
   assign lq_vld_d[6] = lq_vld_q[5];
   assign lq_vld_d[7] = lq_vld_q[6];




   //-------------------------------------------------------------------
   // Latches
   //-------------------------------------------------------------------
   generate
      begin : xhdl21
         genvar                                         i;
         for (i = 0; i <= 12; i = i + 1)
           begin : fxu0_t1_gen

              tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
	      fxu0_t1_latch(
			    .nclk(nclk),
			    .vd(vdd),
			    .gd(gnd),
			    .act(tiup),
			    .force_t(force_t),
			    .d_mode(d_mode),
			    .delay_lclkr(delay_lclkr),
			    .mpw1_b(mpw1_b),
			    .mpw2_b(mpw2_b),
			    .thold_b(func_sl_thold_0_b),
			    .sg(sg_0),
			    .scin(siv[(fxu0_t1_offset + (elmnt_width * i)):(fxu0_t1_offset + (elmnt_width * i) + (elmnt_width - 1))]),
			    .scout(sov[(fxu0_t1_offset + (elmnt_width * i)):(fxu0_t1_offset + (elmnt_width * i) + (elmnt_width - 1))]),
			    .din(fxu0_t1_d[i]),
			    .dout(fxu0_t1_q[i])
			    );
           end
      end
   endgenerate

   generate
      begin : xhdl22
         genvar                                         i;
         for (i = 0; i <= 12; i = i + 1)
           begin : fxu0_t2_gen

              tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
	      fxu0_t2_latch(
			    .nclk(nclk),
			    .vd(vdd),
			    .gd(gnd),
			    .act(tiup),
			    .force_t(force_t),
			    .d_mode(d_mode),
			    .delay_lclkr(delay_lclkr),
			    .mpw1_b(mpw1_b),
			    .mpw2_b(mpw2_b),
			    .thold_b(func_sl_thold_0_b),
			    .sg(sg_0),
			    .scin(siv[(fxu0_t2_offset + (elmnt_width * i)):(fxu0_t2_offset + (elmnt_width * i) + (elmnt_width - 1))]),
			    .scout(sov[(fxu0_t2_offset + (elmnt_width * i)):(fxu0_t2_offset + (elmnt_width * i) + (elmnt_width - 1))]),
			    .din(fxu0_t2_d[i]),
			    .dout(fxu0_t2_q[i])
			    );
           end
      end
   endgenerate

   generate
      begin
         genvar                                         i;
         for (i = 0; i <= 12; i = i + 1)
           begin : fxu0_t3_gen

              tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
	      fxu0_t3_latch(
			    .nclk(nclk),
			    .vd(vdd),
			    .gd(gnd),
			    .act(tiup),
			    .force_t(force_t),
			    .d_mode(d_mode),
			    .delay_lclkr(delay_lclkr),
			    .mpw1_b(mpw1_b),
			    .mpw2_b(mpw2_b),
			    .thold_b(func_sl_thold_0_b),
			    .sg(sg_0),
			    .scin(siv[(fxu0_t3_offset + (elmnt_width * i)):(fxu0_t3_offset + (elmnt_width * i) + (elmnt_width - 1))]),
			    .scout(sov[(fxu0_t3_offset + (elmnt_width * i)):(fxu0_t3_offset + (elmnt_width * i) + (elmnt_width - 1))]),
			    .din(fxu0_t3_d[i]),
			    .dout(fxu0_t3_q[i])
			    );
           end
      end
   endgenerate

   tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
   fxu0_s1_latch(
		 .nclk(nclk),
		 .vd(vdd),
		 .gd(gnd),
		 .act(fx0_act[0]),
		 .force_t(force_t),
		 .d_mode(d_mode),
		 .delay_lclkr(delay_lclkr),
		 .mpw1_b(mpw1_b),
		 .mpw2_b(mpw2_b),
		 .thold_b(func_sl_thold_0_b),
		 .sg(sg_0),
		 .scin(siv[fxu0_s1_offset:fxu0_s1_offset + elmnt_width - 1]),
		 .scout(sov[fxu0_s1_offset:fxu0_s1_offset + elmnt_width - 1]),
		 .din(fxu0_s1_d),
		 .dout(fxu0_s1_q)
		 );

   tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
   fxu0_s2_latch(
		 .nclk(nclk),
		 .vd(vdd),
		 .gd(gnd),
		 .act(fx0_act[0]),
		 .force_t(force_t),
		 .d_mode(d_mode),
		 .delay_lclkr(delay_lclkr),
		 .mpw1_b(mpw1_b),
		 .mpw2_b(mpw2_b),
		 .thold_b(func_sl_thold_0_b),
		 .sg(sg_0),
		 .scin(siv[fxu0_s2_offset:fxu0_s2_offset + elmnt_width - 1]),
		 .scout(sov[fxu0_s2_offset:fxu0_s2_offset + elmnt_width - 1]),
		 .din(fxu0_s2_d),
		 .dout(fxu0_s2_q)
		 );

   tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
   fxu0_s3_latch(
		 .nclk(nclk),
		 .vd(vdd),
		 .gd(gnd),
		 .act(fx0_act[0]),
		 .force_t(force_t),
		 .d_mode(d_mode),
		 .delay_lclkr(delay_lclkr),
		 .mpw1_b(mpw1_b),
		 .mpw2_b(mpw2_b),
		 .thold_b(func_sl_thold_0_b),
		 .sg(sg_0),
		 .scin(siv[fxu0_s3_offset:fxu0_s3_offset + elmnt_width - 1]),
		 .scout(sov[fxu0_s3_offset:fxu0_s3_offset + elmnt_width - 1]),
		 .din(fxu0_s3_d),
		 .dout(fxu0_s3_q)
		 );

   generate
      begin : xhdl24
         genvar                                         i;
         for (i = 0; i <= 8; i = i + 1)
           begin : lq_t1_gen

              tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
	      lq_t1_latch(
			  .nclk(nclk),
			  .vd(vdd),
			  .gd(gnd),
			  .act(tiup),
			  .force_t(force_t),
			  .d_mode(d_mode),
			  .delay_lclkr(delay_lclkr),
			  .mpw1_b(mpw1_b),
			  .mpw2_b(mpw2_b),
			  .thold_b(func_sl_thold_0_b),
			  .sg(sg_0),
			  .scin(siv[(lq_t1_offset + (elmnt_width * i)):(lq_t1_offset + (elmnt_width * i) + (elmnt_width - 1))]),
			  .scout(sov[(lq_t1_offset + (elmnt_width * i)):(lq_t1_offset + (elmnt_width * i) + (elmnt_width - 1))]),
			  .din(lq_t1_d[i]),
			  .dout(lq_t1_q[i])
			  );
           end
      end
   endgenerate


   generate
      begin : xhdl26
         genvar                                         i;
         for (i = 0; i <= 8; i = i + 1)
           begin : lq_t3_gen

              tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
	      lq_t3_latch(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(tiup),
                          .force_t(force_t),
                          .d_mode(d_mode),
                          .delay_lclkr(delay_lclkr),
                          .mpw1_b(mpw1_b),
                          .mpw2_b(mpw2_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[(lq_t3_offset + (elmnt_width * i)):(lq_t3_offset + (elmnt_width * i) + (elmnt_width - 1))]),
                          .scout(sov[(lq_t3_offset + (elmnt_width * i)):(lq_t3_offset + (elmnt_width * i) + (elmnt_width - 1))]),
                          .din(lq_t3_d[i]),
                          .dout(lq_t3_q[i])
                          );
           end
      end
   endgenerate

   tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
   lq_s1_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(tiup),
               .force_t(force_t),
               .d_mode(d_mode),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .scin(siv[lq_s1_offset:lq_s1_offset + elmnt_width - 1]),
               .scout(sov[lq_s1_offset:lq_s1_offset + elmnt_width - 1]),
               .din(lq_s1_d),
               .dout(lq_s1_q)
               );

   tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
   lq_s2_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(tiup),
               .force_t(force_t),
               .d_mode(d_mode),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .scin(siv[lq_s2_offset:lq_s2_offset + elmnt_width - 1]),
               .scout(sov[lq_s2_offset:lq_s2_offset + elmnt_width - 1]),
               .din(lq_s2_d),
               .dout(lq_s2_q)
               );

   generate
      begin : xhdl27
         genvar                                         i;
         for (i = 0; i <= 7; i = i + 1)
           begin : fxu1_t1_gen

              tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
	      fxu1_t1_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[(fxu1_t1_offset + (elmnt_width * i)):(fxu1_t1_offset + (elmnt_width * i) + (elmnt_width - 1))]),
                            .scout(sov[(fxu1_t1_offset + (elmnt_width * i)):(fxu1_t1_offset + (elmnt_width * i) + (elmnt_width - 1))]),
                            .din(fxu1_t1_d[i]),
                            .dout(fxu1_t1_q[i])
                            );
           end
      end
   endgenerate

   generate
      begin : xhdl28
         genvar                                         i;
         for (i = 0; i <= 7; i = i + 1)
           begin : fxu1_t2_gen

              tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
	      fxu1_t2_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[(fxu1_t2_offset + (elmnt_width * i)):(fxu1_t2_offset + (elmnt_width * i) + (elmnt_width - 1))]),
                            .scout(sov[(fxu1_t2_offset + (elmnt_width * i)):(fxu1_t2_offset + (elmnt_width * i) + (elmnt_width - 1))]),
                            .din(fxu1_t2_d[i]),
                            .dout(fxu1_t2_q[i])
                            );
           end
      end
   endgenerate

   generate
      begin : xhdl29
         genvar                                         i;
         for (i = 0; i <= 7; i = i + 1)
           begin : fxu1_t3_gen

              tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
	      fxu1_t3_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[(fxu1_t3_offset + (elmnt_width * i)):(fxu1_t3_offset + (elmnt_width * i) + (elmnt_width - 1))]),
                            .scout(sov[(fxu1_t3_offset + (elmnt_width * i)):(fxu1_t3_offset + (elmnt_width * i) + (elmnt_width - 1))]),
                            .din(fxu1_t3_d[i]),
                            .dout(fxu1_t3_q[i])
                            );
           end
      end
   endgenerate

   tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
   fxu1_s1_latch(
                 .nclk(nclk),
                 .vd(vdd),
                 .gd(gnd),
                 .act(fx1_act[0]),
                 .force_t(force_t),
                 .d_mode(d_mode),
                 .delay_lclkr(delay_lclkr),
                 .mpw1_b(mpw1_b),
                 .mpw2_b(mpw2_b),
                 .thold_b(func_sl_thold_0_b),
                 .sg(sg_0),
                 .scin(siv[fxu1_s1_offset:fxu1_s1_offset + elmnt_width - 1]),
                 .scout(sov[fxu1_s1_offset:fxu1_s1_offset + elmnt_width - 1]),
                 .din(fxu1_s1_d),
                 .dout(fxu1_s1_q)
                 );

   tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
   fxu1_s2_latch(
                 .nclk(nclk),
                 .vd(vdd),
                 .gd(gnd),
                 .act(fx1_act[0]),
                 .force_t(force_t),
                 .d_mode(d_mode),
                 .delay_lclkr(delay_lclkr),
                 .mpw1_b(mpw1_b),
                 .mpw2_b(mpw2_b),
                 .thold_b(func_sl_thold_0_b),
                 .sg(sg_0),
                 .scin(siv[fxu1_s2_offset:fxu1_s2_offset + elmnt_width - 1]),
                 .scout(sov[fxu1_s2_offset:fxu1_s2_offset + elmnt_width - 1]),
                 .din(fxu1_s2_d),
                 .dout(fxu1_s2_q)
                 );

   tri_rlmreg_p #(.WIDTH(elmnt_width), .INIT(0), .NEEDS_SRESET(1))
   fxu1_s3_latch(
                 .nclk(nclk),
                 .vd(vdd),
                 .gd(gnd),
                 .act(fx1_act[0]),
                 .force_t(force_t),
                 .d_mode(d_mode),
                 .delay_lclkr(delay_lclkr),
                 .mpw1_b(mpw1_b),
                 .mpw2_b(mpw2_b),
                 .thold_b(func_sl_thold_0_b),
                 .sg(sg_0),
                 .scin(siv[fxu1_s3_offset:fxu1_s3_offset + elmnt_width - 1]),
                 .scout(sov[fxu1_s3_offset:fxu1_s3_offset + elmnt_width - 1]),
                 .din(fxu1_s3_d),
                 .dout(fxu1_s3_q)
                 );

   generate
      begin : xhdl77
         genvar                                         i;
         for (i = 0; i <= 3 ; i = i + 1)
           begin : rel_gen

              tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))
	      rel_vld_latch(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[rel_vld_offset + (`THREADS * i):(rel_vld_offset + (`THREADS * i) + (`THREADS - 1))]),
                            .scout(sov[rel_vld_offset + (`THREADS * i):(rel_vld_offset + (`THREADS * i) + (`THREADS - 1))]),
                            .din(rel_vld_d[i]),
                            .dout(rel_vld_q[i])
                            );


              tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1))
	      rel_itag_latch(
                             .nclk(nclk),
                             .vd(vdd),
                             .gd(gnd),
                             .act(tiup),
                             .force_t(force_t),
                             .d_mode(d_mode),
                             .delay_lclkr(delay_lclkr),
                             .mpw1_b(mpw1_b),
                             .mpw2_b(mpw2_b),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .scin(siv[rel_itag_offset + (`ITAG_SIZE_ENC * i):(rel_itag_offset + (`ITAG_SIZE_ENC * i) + (`ITAG_SIZE_ENC - 1))]),
                             .scout(sov[rel_itag_offset + (`ITAG_SIZE_ENC * i):(rel_itag_offset + (`ITAG_SIZE_ENC * i) + (`ITAG_SIZE_ENC - 1))]),
                             .din(rel_itag_d[i]),
                             .dout(rel_itag_q[i])
                             );
           end
      end
   endgenerate


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   cp_flush_reg(
                .nclk(nclk),
                .vd(vdd),
                .gd(gnd),
                .act(tiup),
                .force_t(force_t),
                .d_mode(d_mode),
                .delay_lclkr(delay_lclkr),
                .mpw1_b(mpw1_b),
                .mpw2_b(mpw2_b),
                .thold_b(func_sl_thold_0_b),
                .sg(sg_0),
                .scin(siv[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
                .scout(sov[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
                .din(cp_flush),
                .dout(cp_flush_q)
                );

   generate
      begin : xhdl78b
         genvar                                         i;
         for (i = 1; i <= 7; i = i + 1)
           begin : fxu0_itagv_gen

              tri_rlmlatch_p #(.INIT(0))
	      fx0_is_brick_reg(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(fx0_act[i]),
                          .force_t(force_t),
                          .d_mode(d_mode),
                          .delay_lclkr(delay_lclkr),
                          .mpw1_b(mpw1_b),
                          .mpw2_b(mpw2_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[fx0_is_brick_offset +i-1 ]),
                          .scout(sov[fx0_is_brick_offset +i-1 ]),
                          .din(fx0_is_brick_d[i]),
                          .dout(fx0_is_brick_q[i])
                          );

           end
      end
   endgenerate
   generate
      begin : xhdl78v
         genvar                                         i;
         for (i = 0; i <= 11; i = i + 1)
           begin : fxu0_itagv_gen

              tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))
	      fx0_vld_reg(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(tiup),
                          .force_t(force_t),
                          .d_mode(d_mode),
                          .delay_lclkr(delay_lclkr),
                          .mpw1_b(mpw1_b),
                          .mpw2_b(mpw2_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[fx0_vld_offset + (`THREADS * i):(fx0_vld_offset + (`THREADS * i) + `THREADS - 1)]),
                          .scout(sov[fx0_vld_offset + (`THREADS * i):(fx0_vld_offset + (`THREADS * i) + `THREADS - 1)]),
                          .din(fx0_vld_d[i]),
                          .dout(fx0_vld_q[i])
                          );

           end
      end
   endgenerate
   generate
      begin : xhdl78i
         genvar                                         i;
         for (i = 0; i <= 12; i = i + 1)
           begin : fxu0_itag_gen


              tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
	      fx0_itag_reg(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(fx0_act[i]),
                           .force_t(force_t),
                           .d_mode(d_mode),
                           .delay_lclkr(delay_lclkr),
                           .mpw1_b(mpw1_b),
                           .mpw2_b(mpw2_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[(fx0_itag_offset + (`ITAG_SIZE_ENC * i)):(fx0_itag_offset + (`ITAG_SIZE_ENC * i) + (`ITAG_SIZE_ENC - 1))]),
                           .scout(sov[(fx0_itag_offset + (`ITAG_SIZE_ENC * i)):(fx0_itag_offset + (`ITAG_SIZE_ENC * i) + (`ITAG_SIZE_ENC - 1))]),
                           .din(fx0_itag_d[i]),
                           .dout(fx0_itag_q[i])
                           );
           end
      end
   endgenerate


   tri_rlmreg_p #(.WIDTH(4), .INIT(0))
   fx0_ex0_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx0_act[0]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx0_ex0_ilat_offset:fx0_ex0_ilat_offset + 4 - 1]),
                    .scout(sov[fx0_ex0_ilat_offset:fx0_ex0_ilat_offset + 4 - 1]),
                    .din(fx0_ex0_ilat_d),
                    .dout(fx0_ex0_ilat_q)
                    );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0))
   fx0_ex1_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx0_act[1]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx0_ex1_ilat_offset:fx0_ex1_ilat_offset + 4 - 1]),
                    .scout(sov[fx0_ex1_ilat_offset:fx0_ex1_ilat_offset + 4 - 1]),
                    .din(fx0_ex1_ilat_d),
                    .dout(fx0_ex1_ilat_q)
                    );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0))
   fx0_ex2_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx0_act[2]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx0_ex2_ilat_offset:fx0_ex2_ilat_offset + 4 - 1]),
                    .scout(sov[fx0_ex2_ilat_offset:fx0_ex2_ilat_offset + 4 - 1]),
                    .din(fx0_ex2_ilat_d),
                    .dout(fx0_ex2_ilat_q)
                    );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0))
   fx0_ex3_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx0_act[3]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx0_ex3_ilat_offset:fx0_ex3_ilat_offset + 4 - 1]),
                    .scout(sov[fx0_ex3_ilat_offset:fx0_ex3_ilat_offset + 4 - 1]),
                    .din(fx0_ex3_ilat_d),
                    .dout(fx0_ex3_ilat_q)
                    );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0))
   fx0_ex4_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx0_act[4]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx0_ex4_ilat_offset:fx0_ex4_ilat_offset + 4 - 1]),
                    .scout(sov[fx0_ex4_ilat_offset:fx0_ex4_ilat_offset + 4 - 1]),
                    .din(fx0_ex4_ilat_d),
                    .dout(fx0_ex4_ilat_q)
                    );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0))
   fx0_ex5_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx0_act[5]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx0_ex5_ilat_offset:fx0_ex5_ilat_offset + 4 - 1]),
                    .scout(sov[fx0_ex5_ilat_offset:fx0_ex5_ilat_offset + 4 - 1]),
                    .din(fx0_ex5_ilat_d),
                    .dout(fx0_ex5_ilat_q)
                    );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0))
   fx0_ex6_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx0_act[6]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx0_ex6_ilat_offset:fx0_ex6_ilat_offset + 4 - 1]),
                    .scout(sov[fx0_ex6_ilat_offset:fx0_ex6_ilat_offset + 4 - 1]),
                    .din(fx0_ex6_ilat_d),
                    .dout(fx0_ex6_ilat_q)
                    );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0))
   fx0_ex7_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx0_act[7]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx0_ex7_ilat_offset:fx0_ex7_ilat_offset + 4 - 1]),
                    .scout(sov[fx0_ex7_ilat_offset:fx0_ex7_ilat_offset + 4 - 1]),
                    .din(fx0_ex7_ilat_d),
                    .dout(fx0_ex7_ilat_q)
                    );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0))
   fx0_ex8_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx0_act[8]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx0_ex8_ilat_offset:fx0_ex8_ilat_offset + 4 - 1]),
                    .scout(sov[fx0_ex8_ilat_offset:fx0_ex8_ilat_offset + 4 - 1]),
                    .din(fx0_ex8_ilat_d),
                    .dout(fx0_ex8_ilat_q)
                    );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   fx0_rel_itag_vld_reg(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(tiup),
                        .force_t(force_t),
                        .d_mode(d_mode),
                        .delay_lclkr(delay_lclkr),
                        .mpw1_b(mpw1_b),
                        .mpw2_b(mpw2_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[fx0_rel_itag_vld_offset:fx0_rel_itag_vld_offset + `THREADS - 1]),
                        .scout(sov[fx0_rel_itag_vld_offset:fx0_rel_itag_vld_offset + `THREADS - 1]),
                        .din(fx0_rel_itag_vld_d),
                        .dout(fx0_rel_itag_vld_q)
                        );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
   fx0_rel_itag_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(tiup),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx0_rel_itag_offset:fx0_rel_itag_offset + `ITAG_SIZE_ENC - 1]),
                    .scout(sov[fx0_rel_itag_offset:fx0_rel_itag_offset + `ITAG_SIZE_ENC - 1]),
                    .din(fx0_rel_itag_d),
                    .dout(fx0_rel_itag_q)
                    );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   fx0_ext_rel_itag_vld_reg(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[fx0_ext_rel_itag_vld_offset:fx0_ext_rel_itag_vld_offset + `THREADS - 1]),
                            .scout(sov[fx0_ext_rel_itag_vld_offset:fx0_ext_rel_itag_vld_offset + `THREADS - 1]),
                            .din(fx0_ext_rel_itag_vld_d),
                            .dout(fx0_ext_rel_itag_vld_q)
                            );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
   fx0_ext_rel_itag_reg(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(tiup),
                        .force_t(force_t),
                        .d_mode(d_mode),
                        .delay_lclkr(delay_lclkr),
                        .mpw1_b(mpw1_b),
                        .mpw2_b(mpw2_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[fx0_ext_rel_itag_offset:fx0_ext_rel_itag_offset + `ITAG_SIZE_ENC - 1]),
                        .scout(sov[fx0_ext_rel_itag_offset:fx0_ext_rel_itag_offset + `ITAG_SIZE_ENC - 1]),
                        .din(fx0_ext_rel_itag_d),
                        .dout(fx0_ext_rel_itag_q)
                        );


   tri_rlmlatch_p #(.INIT(0))
   fx0_ext_itag0_sel_reg(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(tiup),
                         .force_t(force_t),
                         .d_mode(d_mode),
                         .delay_lclkr(delay_lclkr),
                         .mpw1_b(mpw1_b),
                         .mpw2_b(mpw2_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[fx0_ext_itag0_sel_offset]),
                         .scout(sov[fx0_ext_itag0_sel_offset]),
                         .din(fx0_ext_itag0_sel_d),
                         .dout(fx0_ext_itag0_sel_q)
                         );


   tri_rlmreg_p #(.WIDTH(5), .INIT(0))
   fx0_need_rel_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(tiup),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx0_need_rel_offset:fx0_need_rel_offset + 5 - 1]),
                    .scout(sov[fx0_need_rel_offset:fx0_need_rel_offset + 5 - 1]),
                    .din(fx0_need_rel_d),
                    .dout(fx0_need_rel_q)
                    );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   fx0_ex3_ord_rel_reg(
                       .nclk(nclk),
                       .vd(vdd),
                       .gd(gnd),
                       .act(tiup),
                       .force_t(force_t),
                       .d_mode(d_mode),
                       .delay_lclkr(delay_lclkr),
                       .mpw1_b(mpw1_b),
                       .mpw2_b(mpw2_b),
                       .thold_b(func_sl_thold_0_b),
                       .sg(sg_0),
                       .scin(siv[fx0_ex3_ord_rel_offset:fx0_ex3_ord_rel_offset + `THREADS - 1]),
                       .scout(sov[fx0_ex3_ord_rel_offset:fx0_ex3_ord_rel_offset + `THREADS - 1]),
                       .din(fx0_ex3_ord_rel_d),
                       .dout(fx0_ex3_ord_rel_q)
                       );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   fx0_ex4_ord_rel_reg(
                       .nclk(nclk),
                       .vd(vdd),
                       .gd(gnd),
                       .act(tiup),
                       .force_t(force_t),
                       .d_mode(d_mode),
                       .delay_lclkr(delay_lclkr),
                       .mpw1_b(mpw1_b),
                       .mpw2_b(mpw2_b),
                       .thold_b(func_sl_thold_0_b),
                       .sg(sg_0),
                       .scin(siv[fx0_ex4_ord_rel_offset:fx0_ex4_ord_rel_offset + `THREADS - 1]),
                       .scout(sov[fx0_ex4_ord_rel_offset:fx0_ex4_ord_rel_offset + `THREADS - 1]),
                       .din(fx0_ex4_ord_rel_d),
                       .dout(fx0_ex4_ord_rel_q)
                       );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   fx0_ex5_ord_rel_reg(
                       .nclk(nclk),
                       .vd(vdd),
                       .gd(gnd),
                       .act(tiup),
                       .force_t(force_t),
                       .d_mode(d_mode),
                       .delay_lclkr(delay_lclkr),
                       .mpw1_b(mpw1_b),
                       .mpw2_b(mpw2_b),
                       .thold_b(func_sl_thold_0_b),
                       .sg(sg_0),
                       .scin(siv[fx0_ex5_ord_rel_offset:fx0_ex5_ord_rel_offset + `THREADS - 1]),
                       .scout(sov[fx0_ex5_ord_rel_offset:fx0_ex5_ord_rel_offset + `THREADS - 1]),
                       .din(fx0_ex5_ord_rel_d),
                       .dout(fx0_ex5_ord_rel_q)
                       );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   fx0_ex6_ord_rel_reg(
                       .nclk(nclk),
                       .vd(vdd),
                       .gd(gnd),
                       .act(tiup),
                       .force_t(force_t),
                       .d_mode(d_mode),
                       .delay_lclkr(delay_lclkr),
                       .mpw1_b(mpw1_b),
                       .mpw2_b(mpw2_b),
                       .thold_b(func_sl_thold_0_b),
                       .sg(sg_0),
                       .scin(siv[fx0_ex6_ord_rel_offset:fx0_ex6_ord_rel_offset + `THREADS - 1]),
                       .scout(sov[fx0_ex6_ord_rel_offset:fx0_ex6_ord_rel_offset + `THREADS - 1]),
                       .din(fx0_ex6_ord_rel_d),
                       .dout(fx0_ex6_ord_rel_q)
                       );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   fx0_ex7_ord_rel_reg(
                       .nclk(nclk),
                       .vd(vdd),
                       .gd(gnd),
                       .act(tiup),
                       .force_t(force_t),
                       .d_mode(d_mode),
                       .delay_lclkr(delay_lclkr),
                       .mpw1_b(mpw1_b),
                       .mpw2_b(mpw2_b),
                       .thold_b(func_sl_thold_0_b),
                       .sg(sg_0),
                       .scin(siv[fx0_ex7_ord_rel_offset:fx0_ex7_ord_rel_offset + `THREADS - 1]),
                       .scout(sov[fx0_ex7_ord_rel_offset:fx0_ex7_ord_rel_offset + `THREADS - 1]),
                       .din(fx0_ex7_ord_rel_d),
                       .dout(fx0_ex7_ord_rel_q)
                       );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   fx0_ex8_ord_rel_reg(
                       .nclk(nclk),
                       .vd(vdd),
                       .gd(gnd),
                       .act(tiup),
                       .force_t(force_t),
                       .d_mode(d_mode),
                       .delay_lclkr(delay_lclkr),
                       .mpw1_b(mpw1_b),
                       .mpw2_b(mpw2_b),
                       .thold_b(func_sl_thold_0_b),
                       .sg(sg_0),
                       .scin(siv[fx0_ex8_ord_rel_offset:fx0_ex8_ord_rel_offset + `THREADS - 1]),
                       .scout(sov[fx0_ex8_ord_rel_offset:fx0_ex8_ord_rel_offset + `THREADS - 1]),
                       .din(fx0_ex8_ord_rel_d),
                       .dout(fx0_ex8_ord_rel_q)
                       );



   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   fx0_release_ord_hold_reg(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[fx0_release_ord_hold_offset:fx0_release_ord_hold_offset + `THREADS - 1]),
                            .scout(sov[fx0_release_ord_hold_offset:fx0_release_ord_hold_offset + `THREADS - 1]),
                            .din(fx0_release_ord_hold_d),
                            .dout(fx0_release_ord_hold_q)
                            );


   tri_rlmlatch_p #(.INIT(0))
   fx0_ex0_ord_reg(
                   .nclk(nclk),
                   .vd(vdd),
                   .gd(gnd),
                   .act(fx0_act[0]),
                   .force_t(force_t),
                   .d_mode(d_mode),
                   .delay_lclkr(delay_lclkr),
                   .mpw1_b(mpw1_b),
                   .mpw2_b(mpw2_b),
                   .thold_b(func_sl_thold_0_b),
                   .sg(sg_0),
                   .scin(siv[fx0_ex0_ord_offset]),
                   .scout(sov[fx0_ex0_ord_offset]),
                   .din(fx0_ex0_ord_d),
                   .dout(fx0_ex0_ord_q)
                   );


   tri_rlmlatch_p #(.INIT(0))
   fx0_ex1_ord_reg(
                   .nclk(nclk),
                   .vd(vdd),
                   .gd(gnd),
                   .act(fx0_act[1]),
                   .force_t(force_t),
                   .d_mode(d_mode),
                   .delay_lclkr(delay_lclkr),
                   .mpw1_b(mpw1_b),
                   .mpw2_b(mpw2_b),
                   .thold_b(func_sl_thold_0_b),
                   .sg(sg_0),
                   .scin(siv[fx0_ex1_ord_offset]),
                   .scout(sov[fx0_ex1_ord_offset]),
                   .din(fx0_ex1_ord_d),
                   .dout(fx0_ex1_ord_q)
                   );

   tri_rlmlatch_p #(.INIT(0))
   fx0_ex2_ord_reg(
                   .nclk(nclk),
                   .vd(vdd),
                   .gd(gnd),
                   .act(fx0_act[2]),
                   .force_t(force_t),
                   .d_mode(d_mode),
                   .delay_lclkr(delay_lclkr),
                   .mpw1_b(mpw1_b),
                   .mpw2_b(mpw2_b),
                   .thold_b(func_sl_thold_0_b),
                   .sg(sg_0),
                   .scin(siv[fx0_ex2_ord_offset]),
                   .scout(sov[fx0_ex2_ord_offset]),
                   .din(fx0_ex2_ord_d),
                   .dout(fx0_ex2_ord_q)
                   );
   tri_rlmlatch_p #(.INIT(0))
   fx0_ex3_ord_flush_reg(
                   .nclk(nclk),
                   .vd(vdd),
                   .gd(gnd),
                   .act(fx0_act[3]),
                   .force_t(force_t),
                   .d_mode(d_mode),
                   .delay_lclkr(delay_lclkr),
                   .mpw1_b(mpw1_b),
                   .mpw2_b(mpw2_b),
                   .thold_b(func_sl_thold_0_b),
                   .sg(sg_0),
                   .scin(siv[fx0_ex3_ord_flush_offset]),
                   .scout(sov[fx0_ex3_ord_flush_offset]),
                   .din(fx0_ex3_ord_flush_d),
                   .dout(fx0_ex3_ord_flush_q)
                   );

   tri_rlmlatch_p #(.INIT(0))
   fx0_sched_rel_pri_or_reg(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[fx0_sched_rel_pri_or_offset]),
                            .scout(sov[fx0_sched_rel_pri_or_offset]),
                            .din(fx0_sched_rel_pri_or_d),
                            .dout(fx0_sched_rel_pri_or_q)
                            );
   tri_rlmlatch_p #(.INIT(0))
   fx0_rel_itag_abort_reg(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[fx0_rel_itag_abort_offset]),
                            .scout(sov[fx0_rel_itag_abort_offset]),
                            .din(fx0_rel_itag_abort_d),
                            .dout(fx0_rel_itag_abort_q)
                            );

   tri_rlmlatch_p #(.INIT(0))
   fx0_ext_rel_itag_abort_reg(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[fx0_ext_rel_itag_abort_offset]),
                            .scout(sov[fx0_ext_rel_itag_abort_offset]),
                            .din(fx0_ext_rel_itag_abort_d),
                            .dout(fx0_ext_rel_itag_abort_q)
                            );
   tri_rlmlatch_p #(.INIT(0))
   fx0_ex5_recircd_reg(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[fx0_ex5_recircd_offset]),
                            .scout(sov[fx0_ex5_recircd_offset]),
                            .din(fx0_ex5_recircd_d),
                            .dout(fx0_ex5_recircd_q)
                            );
   tri_rlmlatch_p #(.INIT(0))
   fx0_ex6_recircd_reg(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[fx0_ex6_recircd_offset]),
                            .scout(sov[fx0_ex6_recircd_offset]),
                            .din(fx0_ex6_recircd_d),
                            .dout(fx0_ex6_recircd_q)
                            );
   tri_rlmlatch_p #(.INIT(0))
   fx0_ex7_recircd_reg(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[fx0_ex7_recircd_offset]),
                            .scout(sov[fx0_ex7_recircd_offset]),
                            .din(fx0_ex7_recircd_d),
                            .dout(fx0_ex7_recircd_q)
                            );

   generate
      begin : xab0
         genvar                                         i;
         for (i = 3; i <= 4; i = i + 1)
           begin : fx0xab

	      tri_rlmlatch_p #(.INIT(0))
	      fx0_abort_reg(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(fx0_act[i]),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[fx0_abort_offset+i-3]),
                            .scout(sov[fx0_abort_offset+i-3]),
                            .din(fx0_abort_d[i]),
                            .dout(fx0_abort_q[i])
                            );

	   end // block: fx0xab
      end // block: xab0
      endgenerate


   generate
      begin : xhdl70v
         genvar                                         i;
         for (i = 0; i <= 6; i = i + 1)
           begin : fxu1_vld_gen

              tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1))
	      fx1_vld_reg(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(tiup),
                          .force_t(force_t),
                          .d_mode(d_mode),
                          .delay_lclkr(delay_lclkr),
                          .mpw1_b(mpw1_b),
                          .mpw2_b(mpw2_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[fx1_vld_offset + (`THREADS * i):(fx1_vld_offset + (`THREADS * i) + `THREADS - 1)]),
                          .scout(sov[fx1_vld_offset + (`THREADS * i):(fx1_vld_offset + (`THREADS * i) + `THREADS - 1)]),
                          .din(fx1_vld_d[i]),
                          .dout(fx1_vld_q[i])
                          );

           end
      end
   endgenerate

   generate
      begin : xhdl70
         genvar                                         i;
         for (i = 0; i <= 7; i = i + 1)

           begin : fxu1_itag_gen
              tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
	      fx1_itag_reg(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(fx1_act[i]),
                           .force_t(force_t),
                           .d_mode(d_mode),
                           .delay_lclkr(delay_lclkr),
                           .mpw1_b(mpw1_b),
                           .mpw2_b(mpw2_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[(fx1_itag_offset + (`ITAG_SIZE_ENC * i)):(fx1_itag_offset + (`ITAG_SIZE_ENC * i) + (`ITAG_SIZE_ENC - 1))]),
                           .scout(sov[(fx1_itag_offset + (`ITAG_SIZE_ENC * i)):(fx1_itag_offset + (`ITAG_SIZE_ENC * i) + (`ITAG_SIZE_ENC - 1))]),
                           .din(fx1_itag_d[i]),
                           .dout(fx1_itag_q[i])
                           );
           end
      end
   endgenerate


   tri_rlmreg_p #(.WIDTH(3), .INIT(0))
   fx1_ex0_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx1_act[0]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx1_ex0_ilat_offset:fx1_ex0_ilat_offset + 3 - 1]),
                    .scout(sov[fx1_ex0_ilat_offset:fx1_ex0_ilat_offset + 3 - 1]),
                    .din(fx1_ex0_ilat_d),
                    .dout(fx1_ex0_ilat_q)
                    );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0))
   fx1_ex1_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx1_act[1]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx1_ex1_ilat_offset:fx1_ex1_ilat_offset + 3 - 1]),
                    .scout(sov[fx1_ex1_ilat_offset:fx1_ex1_ilat_offset + 3 - 1]),
                    .din(fx1_ex1_ilat_d),
                    .dout(fx1_ex1_ilat_q)
                    );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0))
   fx1_ex2_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx1_act[2]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx1_ex2_ilat_offset:fx1_ex2_ilat_offset + 3 - 1]),
                    .scout(sov[fx1_ex2_ilat_offset:fx1_ex2_ilat_offset + 3 - 1]),
                    .din(fx1_ex2_ilat_d),
                    .dout(fx1_ex2_ilat_q)
                    );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0))
   fx1_ex3_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx1_act[3]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx1_ex3_ilat_offset:fx1_ex3_ilat_offset + 3 - 1]),
                    .scout(sov[fx1_ex3_ilat_offset:fx1_ex3_ilat_offset + 3 - 1]),
                    .din(fx1_ex3_ilat_d),
                    .dout(fx1_ex3_ilat_q)
                    );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0))
   fx1_ex4_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx1_act[4]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx1_ex4_ilat_offset:fx1_ex4_ilat_offset + 3 - 1]),
                    .scout(sov[fx1_ex4_ilat_offset:fx1_ex4_ilat_offset + 3 - 1]),
                    .din(fx1_ex4_ilat_d),
                    .dout(fx1_ex4_ilat_q)
                    );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0))
   fx1_ex5_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx1_act[5]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx1_ex5_ilat_offset:fx1_ex5_ilat_offset + 3 - 1]),
                    .scout(sov[fx1_ex5_ilat_offset:fx1_ex5_ilat_offset + 3 - 1]),
                    .din(fx1_ex5_ilat_d),
                    .dout(fx1_ex5_ilat_q)
                    );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0))
   fx1_ex6_ilat_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(fx1_act[6]),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx1_ex6_ilat_offset:fx1_ex6_ilat_offset + 3 - 1]),
                    .scout(sov[fx1_ex6_ilat_offset:fx1_ex6_ilat_offset + 3 - 1]),
                    .din(fx1_ex6_ilat_d),
                    .dout(fx1_ex6_ilat_q)
                    );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   fx1_rel_itag_vld_reg(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(tiup),
                        .force_t(force_t),
                        .d_mode(d_mode),
                        .delay_lclkr(delay_lclkr),
                        .mpw1_b(mpw1_b),
                        .mpw2_b(mpw2_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[fx1_rel_itag_vld_offset:fx1_rel_itag_vld_offset + `THREADS - 1]),
                        .scout(sov[fx1_rel_itag_vld_offset:fx1_rel_itag_vld_offset + `THREADS - 1]),
                        .din(fx1_rel_itag_vld_d),
                        .dout(fx1_rel_itag_vld_q)
                        );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
   fx1_rel_itag_reg(
                    .nclk(nclk),
                    .vd(vdd),
                    .gd(gnd),
                    .act(tiup),
                    .force_t(force_t),
                    .d_mode(d_mode),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .scin(siv[fx1_rel_itag_offset:fx1_rel_itag_offset + `ITAG_SIZE_ENC - 1]),
                    .scout(sov[fx1_rel_itag_offset:fx1_rel_itag_offset + `ITAG_SIZE_ENC - 1]),
                    .din(fx1_rel_itag_d),
                    .dout(fx1_rel_itag_q)
                    );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   fx1_ext_rel_itag_vld_reg(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[fx1_ext_rel_itag_vld_offset:fx1_ext_rel_itag_vld_offset + `THREADS - 1]),
                            .scout(sov[fx1_ext_rel_itag_vld_offset:fx1_ext_rel_itag_vld_offset + `THREADS - 1]),
                            .din(fx1_ext_rel_itag_vld_d),
                            .dout(fx1_ext_rel_itag_vld_q)
                            );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
   fx1_ext_rel_itag_reg(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(tiup),
                        .force_t(force_t),
                        .d_mode(d_mode),
                        .delay_lclkr(delay_lclkr),
                        .mpw1_b(mpw1_b),
                        .mpw2_b(mpw2_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[fx1_ext_rel_itag_offset:fx1_ext_rel_itag_offset + `ITAG_SIZE_ENC - 1]),
                        .scout(sov[fx1_ext_rel_itag_offset:fx1_ext_rel_itag_offset + `ITAG_SIZE_ENC - 1]),
                        .din(fx1_ext_rel_itag_d),
                        .dout(fx1_ext_rel_itag_q)
                        );


   tri_rlmlatch_p #(.INIT(0))
   fx1_ext_itag0_sel_reg(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(tiup),
                         .force_t(force_t),
                         .d_mode(d_mode),
                         .delay_lclkr(delay_lclkr),
                         .mpw1_b(mpw1_b),
                         .mpw2_b(mpw2_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[fx1_ext_itag0_sel_offset]),
                         .scout(sov[fx1_ext_itag0_sel_offset]),
                         .din(fx1_ext_itag0_sel_d),
                         .dout(fx1_ext_itag0_sel_q)
                         );


   tri_rlmlatch_p #(.INIT(0))
   fx1_ex0_need_rel_reg(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(tiup),
                        .force_t(force_t),
                        .d_mode(d_mode),
                        .delay_lclkr(delay_lclkr),
                        .mpw1_b(mpw1_b),
                        .mpw2_b(mpw2_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[fx1_ex0_need_rel_offset]),
                        .scout(sov[fx1_ex0_need_rel_offset]),
                        .din(fx1_ex0_need_rel_d),
                        .dout(fx1_ex0_need_rel_q)
                        );


   tri_rlmlatch_p #(.INIT(0))
   fx1_ex1_need_rel_reg(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(tiup),
                        .force_t(force_t),
                        .d_mode(d_mode),
                        .delay_lclkr(delay_lclkr),
                        .mpw1_b(mpw1_b),
                        .mpw2_b(mpw2_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[fx1_ex1_need_rel_offset]),
                        .scout(sov[fx1_ex1_need_rel_offset]),
                        .din(fx1_ex1_need_rel_d),
                        .dout(fx1_ex1_need_rel_q)
                        );


   tri_rlmlatch_p #(.INIT(0))
   fx1_ex2_need_rel_reg(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(tiup),
                        .force_t(force_t),
                        .d_mode(d_mode),
                        .delay_lclkr(delay_lclkr),
                        .mpw1_b(mpw1_b),
                        .mpw2_b(mpw2_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[fx1_ex2_need_rel_offset]),
                        .scout(sov[fx1_ex2_need_rel_offset]),
                        .din(fx1_ex2_need_rel_d),
                        .dout(fx1_ex2_need_rel_q)
                        );


   tri_rlmlatch_p #(.INIT(0))
   fx1_ex3_need_rel_reg(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(tiup),
                        .force_t(force_t),
                        .d_mode(d_mode),
                        .delay_lclkr(delay_lclkr),
                        .mpw1_b(mpw1_b),
                        .mpw2_b(mpw2_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[fx1_ex3_need_rel_offset]),
                        .scout(sov[fx1_ex3_need_rel_offset]),
                        .din(fx1_ex3_need_rel_d),
                        .dout(fx1_ex3_need_rel_q)
                        );

   tri_rlmlatch_p #(.INIT(0))
   fx1_ex1_stq_pipe_reg(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(tiup),
                        .force_t(force_t),
                        .d_mode(d_mode),
                        .delay_lclkr(delay_lclkr),
                        .mpw1_b(mpw1_b),
                        .mpw2_b(mpw2_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[fx1_ex1_stq_pipe_offset]),
                        .scout(sov[fx1_ex1_stq_pipe_offset]),
                        .din(fx1_ex1_stq_pipe_d),
                        .dout(fx1_ex1_stq_pipe_q)
                        );
   tri_rlmlatch_p #(.INIT(0))
   fx1_ex2_stq_pipe_reg(
                        .nclk(nclk),
                        .vd(vdd),
                        .gd(gnd),
                        .act(tiup),
                        .force_t(force_t),
                        .d_mode(d_mode),
                        .delay_lclkr(delay_lclkr),
                        .mpw1_b(mpw1_b),
                        .mpw2_b(mpw2_b),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .scin(siv[fx1_ex2_stq_pipe_offset]),
                        .scout(sov[fx1_ex2_stq_pipe_offset]),
                        .din(fx1_ex2_stq_pipe_d),
                        .dout(fx1_ex2_stq_pipe_q)
                        );

   tri_rlmlatch_p #(.INIT(0))
   fx1_sched_rel_pri_or_reg(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[fx1_sched_rel_pri_or_offset]),
                            .scout(sov[fx1_sched_rel_pri_or_offset]),
                            .din(fx1_sched_rel_pri_or_d),
                            .dout(fx1_sched_rel_pri_or_q)
                            );

   tri_rlmlatch_p #(.INIT(0))
   fx1_rel_itag_abort_reg(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[fx1_rel_itag_abort_offset]),
                            .scout(sov[fx1_rel_itag_abort_offset]),
                            .din(fx1_rel_itag_abort_d),
                            .dout(fx1_rel_itag_abort_q)
                            );

   tri_rlmlatch_p #(.INIT(0))
   fx1_ext_rel_itag_abort_reg(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(tiup),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[fx1_ext_rel_itag_abort_offset]),
                            .scout(sov[fx1_ext_rel_itag_abort_offset]),
                            .din(fx1_ext_rel_itag_abort_d),
                            .dout(fx1_ext_rel_itag_abort_q)
                            );

   generate
      begin : xab1
         genvar                                         i;
         for (i = 3; i <= 4; i = i + 1)
           begin : fx1xab

	      tri_rlmlatch_p #(.INIT(0))
	      fx0_abort_reg(
                            .nclk(nclk),
                            .vd(vdd),
                            .gd(gnd),
                            .act(fx1_act[i]),
                            .force_t(force_t),
                            .d_mode(d_mode),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .scin(siv[fx1_abort_offset+i-3]),
                            .scout(sov[fx1_abort_offset+i-3]),
                            .din(fx1_abort_d[i]),
                            .dout(fx1_abort_q[i])
                            );

	   end // block: fx0xab
      end // block: xab0
      endgenerate

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
   fx0_ex0_s1_itag_latch(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(fx0_act[0]),
                         .force_t(force_t),
                         .d_mode(d_mode),
                         .delay_lclkr(delay_lclkr),
                         .mpw1_b(mpw1_b),
                         .mpw2_b(mpw2_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[fx0_ex0_s1_itag_offset:fx0_ex0_s1_itag_offset + `ITAG_SIZE_ENC - 1]),
                         .scout(sov[fx0_ex0_s1_itag_offset:fx0_ex0_s1_itag_offset + `ITAG_SIZE_ENC - 1]),
                         .din(rv_fx0_s1_itag),
                         .dout(fx0_ex0_s1_itag_q)
                         );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
   fx0_ex0_s2_itag_latch(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(fx0_act[0]),
                         .force_t(force_t),
                         .d_mode(d_mode),
                         .delay_lclkr(delay_lclkr),
                         .mpw1_b(mpw1_b),
                         .mpw2_b(mpw2_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[fx0_ex0_s2_itag_offset:fx0_ex0_s2_itag_offset + `ITAG_SIZE_ENC - 1]),
                         .scout(sov[fx0_ex0_s2_itag_offset:fx0_ex0_s2_itag_offset + `ITAG_SIZE_ENC - 1]),
                         .din(rv_fx0_s2_itag),
                         .dout(fx0_ex0_s2_itag_q)
                         );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
   fx0_ex0_s3_itag_latch(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(fx0_act[0]),
                         .force_t(force_t),
                         .d_mode(d_mode),
                         .delay_lclkr(delay_lclkr),
                         .mpw1_b(mpw1_b),
                         .mpw2_b(mpw2_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[fx0_ex0_s3_itag_offset:fx0_ex0_s3_itag_offset + `ITAG_SIZE_ENC - 1]),
                         .scout(sov[fx0_ex0_s3_itag_offset:fx0_ex0_s3_itag_offset + `ITAG_SIZE_ENC - 1]),
                         .din(rv_fx0_s3_itag),
                         .dout(fx0_ex0_s3_itag_q)
                         );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
   fx1_ex0_s1_itag_latch(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(fx1_act[0]),
                         .force_t(force_t),
                         .d_mode(d_mode),
                         .delay_lclkr(delay_lclkr),
                         .mpw1_b(mpw1_b),
                         .mpw2_b(mpw2_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[fx1_ex0_s1_itag_offset:fx1_ex0_s1_itag_offset + `ITAG_SIZE_ENC - 1]),
                         .scout(sov[fx1_ex0_s1_itag_offset:fx1_ex0_s1_itag_offset + `ITAG_SIZE_ENC - 1]),
                         .din(rv_fx1_s1_itag),
                         .dout(fx1_ex0_s1_itag_q)
                         );



   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
   fx1_ex0_s2_itag_latch(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(fx1_act[0]),
                         .force_t(force_t),
                         .d_mode(d_mode),
                         .delay_lclkr(delay_lclkr),
                         .mpw1_b(mpw1_b),
                         .mpw2_b(mpw2_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[fx1_ex0_s2_itag_offset:fx1_ex0_s2_itag_offset + `ITAG_SIZE_ENC - 1]),
                         .scout(sov[fx1_ex0_s2_itag_offset:fx1_ex0_s2_itag_offset + `ITAG_SIZE_ENC - 1]),
                         .din(rv_fx1_s2_itag),
                         .dout(fx1_ex0_s2_itag_q)
                         );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
   fx1_ex0_s3_itag_latch(
                         .nclk(nclk),
                         .vd(vdd),
                         .gd(gnd),
                         .act(fx1_act[0]),
                         .force_t(force_t),
                         .d_mode(d_mode),
                         .delay_lclkr(delay_lclkr),
                         .mpw1_b(mpw1_b),
                         .mpw2_b(mpw2_b),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .scin(siv[fx1_ex0_s3_itag_offset:fx1_ex0_s3_itag_offset + `ITAG_SIZE_ENC - 1]),
                         .scout(sov[fx1_ex0_s3_itag_offset:fx1_ex0_s3_itag_offset + `ITAG_SIZE_ENC - 1]),
                         .din(rv_fx1_s3_itag),
                         .dout(fx1_ex0_s3_itag_q)
                         );

   generate
      begin : xhdl80
         genvar                                         i;
         for (i = 0; i <= 7; i = i + 1)
           begin : lq_vld_gen

              tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
	      lq_vld_latch(
                           .nclk(nclk),
                           .vd(vdd),
                           .gd(gnd),
                           .act(tiup),
                           .force_t(force_t),
                           .d_mode(d_mode),
                           .delay_lclkr(delay_lclkr),
                           .mpw1_b(mpw1_b),
                           .mpw2_b(mpw2_b),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .scin(siv[(lq_vld_offset + (`THREADS * i)):(lq_vld_offset + (`THREADS * i) + (`THREADS - 1))]),
                           .scout(sov[(lq_vld_offset + (`THREADS * i)):(lq_vld_offset + (`THREADS * i) + (`THREADS - 1))]),
                           .din(lq_vld_d[i]),
                           .dout(lq_vld_q[i])
                           );
           end
      end
   endgenerate

   generate
      begin : xhdl81
         genvar                                         i;
         for (i = 0; i <= `LQ_LOAD_PIPE_END; i = i + 1)
           begin : lq_itag_gen

              tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
	      lq_itag_reg(
                          .nclk(nclk),
                          .vd(vdd),
                          .gd(gnd),
                          .act(lq_act[i]),
                          .force_t(force_t),
                          .d_mode(d_mode),
                          .delay_lclkr(delay_lclkr),
                          .mpw1_b(mpw1_b),
                          .mpw2_b(mpw2_b),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .scin(siv[(lq_itag_offset + (`ITAG_SIZE_ENC * i)):(lq_itag_offset + (`ITAG_SIZE_ENC * i) + (`ITAG_SIZE_ENC - 1))]),
                          .scout(sov[(lq_itag_offset + (`ITAG_SIZE_ENC * i)):(lq_itag_offset + (`ITAG_SIZE_ENC * i) + (`ITAG_SIZE_ENC - 1))]),
                          .din(lq_itag_d[i]),
                          .dout(lq_itag_q[i])
                          );
           end
      end
   endgenerate



   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];

   //-----------------------------------------------
   // pervasive
   //-----------------------------------------------


   tri_plat #(.WIDTH(2)) perv_1to0_reg(
                                       .vd(vdd),
                                       .gd(gnd),
                                       .nclk(nclk),
                                       .flush(ccflush_dc),
                                       .din({func_sl_thold_1, sg_1}),
                                       .q({func_sl_thold_0, sg_0})
                                       );


   tri_lcbor
     perv_lcbor(
                .clkoff_b(clkoff_b),
                .thold(func_sl_thold_0),
                .sg(sg_0),
                .act_dis(act_dis),
                .force_t(force_t),
                .thold_b(func_sl_thold_0_b)
                );

endmodule // rv_rf_byp
