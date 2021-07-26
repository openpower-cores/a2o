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

//----------------------------------------------------------------------------------------------------
// Title:   rv_station.vhdl
// Desc:       Parameterizable reservation station
//-----------------------------------------------------------------------------------------------------
module rv_station(


		  cp_flush,
		  cp_next_itag,
		  rv0_instr_i0_vld,
		  rv0_instr_i0_rte,
		  rv0_instr_i1_vld,
		  rv0_instr_i1_rte,
		  rv0_instr_i0_dat,
		  rv0_instr_i0_dat_ex0,
		  rv0_instr_i0_itag,
		  rv0_instr_i0_ord,
		  rv0_instr_i0_cord,
		  rv0_instr_i0_spec,
		  rv0_instr_i0_s1_v,
		  rv0_instr_i0_s1_dep_hit,
		  rv0_instr_i0_s1_itag,
		  rv0_instr_i0_s2_v,
		  rv0_instr_i0_s2_dep_hit,
		  rv0_instr_i0_s2_itag,
		  rv0_instr_i0_s3_v,
		  rv0_instr_i0_s3_dep_hit,
		  rv0_instr_i0_s3_itag,
		  rv0_instr_i0_is_brick,
		  rv0_instr_i0_brick,
		  rv0_instr_i0_ilat,
		  rv0_instr_i1_dat,
		  rv0_instr_i1_dat_ex0,
		  rv0_instr_i1_itag,
		  rv0_instr_i1_ord,
		  rv0_instr_i1_cord,
		  rv0_instr_i1_spec,
		  rv0_instr_i1_s1_v,
		  rv0_instr_i1_s1_dep_hit,
		  rv0_instr_i1_s1_itag,
		  rv0_instr_i1_s2_v,
		  rv0_instr_i1_s2_dep_hit,
		  rv0_instr_i1_s2_itag,
		  rv0_instr_i1_s3_v,
		  rv0_instr_i1_s3_dep_hit,
		  rv0_instr_i1_s3_itag,
		  rv0_instr_i1_is_brick,
		  rv0_instr_i1_brick,
		  rv0_instr_i1_ilat,

		  fx0_rv_itag_vld,
 		  fx0_rv_itag,
		  fx1_rv_itag_vld,
   		  fx1_rv_itag,
		  axu0_rv_itag_vld,
	          axu0_rv_itag,
 		  axu1_rv_itag_vld,
 		  axu1_rv_itag,
		  lq_rv_itag0_vld,
  		  lq_rv_itag0,
   		  lq_rv_itag1_vld,
  		  lq_rv_itag1,
 		  lq_rv_itag2_vld,
		  lq_rv_itag2,

 		  fx0_rv_itag_abort,
  		  fx1_rv_itag_abort,
  		  axu0_rv_itag_abort,
  		  axu1_rv_itag_abort,
 		  lq_rv_itag0_abort,
   		  lq_rv_itag1_abort,

		  lq_rv_itag1_restart,
		  lq_rv_itag1_hold,
		  lq_rv_itag1_cord,
		  lq_rv_itag1_rst_vld,
		  lq_rv_itag1_rst,
		  lq_rv_clr_hold,

		  xx_rv_ex2_s1_abort,
		  xx_rv_ex2_s2_abort,
		  xx_rv_ex2_s3_abort,

		  q_hold_all,
		  q_ord_complete,
		  q_ord_tid,
		  rv1_other_ilat0_vld,
		  rv1_other_ilat0_itag,
		  rv1_other_ilat0_vld_out,
		  rv1_other_ilat0_itag_out,
		  rv1_instr_vld,
		  rv1_instr_dat,
		  rv1_instr_spec,
		  rv1_instr_ord,
		  rv1_instr_is_brick,
		  rv1_instr_itag,
		  rv1_instr_ilat,
		  rv1_instr_ilat0_vld,
		  rv1_instr_ilat1_vld,
		  rv1_instr_s1_itag,
		  rv1_instr_s2_itag,
		  rv1_instr_s3_itag,
		  ex0_instr_dat,
		  ex1_credit_free,
		  rvs_empty,
		  rvs_perf_bus,
		  rvs_dbg_bus,
		  vdd,
		  gnd,
		  nclk,
		  sg_1,
		  func_sl_thold_1,
		  ccflush_dc,
		  act_dis,
		  clkoff_b,
		  d_mode,
		  delay_lclkr,
		  mpw1_b,
		  mpw2_b,
		  scan_in,
		  scan_out
		  );
`include "tri_a2o.vh"

   parameter                   q_dat_width_g = 80;
   parameter                   q_dat_ex0_width_g = 60;
   parameter                   q_num_entries_g = 12;
   parameter                   q_barf_enc_g = 4;
   parameter                   q_itag_busses_g = 7;		// 2 fx, 3 lq, 2 axu
   parameter                   q_ord_g = 1;		// ordered Logic
   parameter                   q_cord_g = 1;		// Completion Ordered ordered Logic
   parameter                   q_brick_g = 1'b1;		// Brick Logic
   parameter                   q_lq_g=0;
   parameter                   q_noilat0_g=0;


   input [0:`THREADS-1]         cp_flush;
   input [0:(`THREADS*`ITAG_SIZE_ENC)-1] 	cp_next_itag;

   input [0:`THREADS-1] 	rv0_instr_i0_vld;
   input 			rv0_instr_i0_rte;
   input [0:`THREADS-1] 	rv0_instr_i1_vld;
   input 			rv0_instr_i1_rte;

   input [0:q_dat_width_g-1] 	rv0_instr_i0_dat;
   input [0:q_dat_ex0_width_g-1] 	rv0_instr_i0_dat_ex0;
   input [0:`ITAG_SIZE_ENC-1] 	rv0_instr_i0_itag;
   input 			rv0_instr_i0_ord;
   input 			rv0_instr_i0_cord;
   input 			rv0_instr_i0_spec;
   input 			rv0_instr_i0_s1_v;
   input 			rv0_instr_i0_s1_dep_hit;
   input [0:`ITAG_SIZE_ENC-1] 	rv0_instr_i0_s1_itag;
   input 			rv0_instr_i0_s2_v;
   input 			rv0_instr_i0_s2_dep_hit;
   input [0:`ITAG_SIZE_ENC-1] 	rv0_instr_i0_s2_itag;
   input 			rv0_instr_i0_s3_v;
   input 			rv0_instr_i0_s3_dep_hit;
   input [0:`ITAG_SIZE_ENC-1] 	rv0_instr_i0_s3_itag;
   input 			rv0_instr_i0_is_brick;
   input [0:2] 			rv0_instr_i0_brick;
   input [0:3] 			rv0_instr_i0_ilat;

   input [0:q_dat_width_g-1] 	rv0_instr_i1_dat;
   input [0:q_dat_ex0_width_g-1] 	rv0_instr_i1_dat_ex0;
   input [0:`ITAG_SIZE_ENC-1] 	rv0_instr_i1_itag;
   input 			rv0_instr_i1_ord;
   input 			rv0_instr_i1_cord;
   input 			rv0_instr_i1_spec;
   input 			rv0_instr_i1_s1_v;
   input 			rv0_instr_i1_s1_dep_hit;
   input [0:`ITAG_SIZE_ENC-1] 	rv0_instr_i1_s1_itag;
   input 			rv0_instr_i1_s2_v;
   input 			rv0_instr_i1_s2_dep_hit;
   input [0:`ITAG_SIZE_ENC-1] 	rv0_instr_i1_s2_itag;
   input 			rv0_instr_i1_s3_v;
   input 			rv0_instr_i1_s3_dep_hit;
   input [0:`ITAG_SIZE_ENC-1] 	rv0_instr_i1_s3_itag;
   input 			rv0_instr_i1_is_brick;
   input [0:2] 			rv0_instr_i1_brick;
   input [0:3] 			rv0_instr_i1_ilat;

   input [0:`THREADS-1] 	fx0_rv_itag_vld;
   input [0:`ITAG_SIZE_ENC-1] 	fx0_rv_itag;
   input [0:`THREADS-1] 	fx1_rv_itag_vld;
   input [0:`ITAG_SIZE_ENC-1] 	fx1_rv_itag;
   input [0:`THREADS-1] 	axu0_rv_itag_vld;
   input [0:`ITAG_SIZE_ENC-1] 	axu0_rv_itag;
   input [0:`THREADS-1] 	axu1_rv_itag_vld;
   input [0:`ITAG_SIZE_ENC-1] 	axu1_rv_itag;
   input [0:`THREADS-1] 	lq_rv_itag0_vld;
   input [0:`ITAG_SIZE_ENC-1] 	lq_rv_itag0;
   input [0:`THREADS-1] 	lq_rv_itag1_vld;
   input [0:`ITAG_SIZE_ENC-1] 	lq_rv_itag1;
   input [0:`THREADS-1] 	lq_rv_itag2_vld;
   input [0:`ITAG_SIZE_ENC-1] 	lq_rv_itag2;

   input 			fx0_rv_itag_abort;
   input 			fx1_rv_itag_abort;
   input 			axu0_rv_itag_abort;
   input 			axu1_rv_itag_abort;
   input 			lq_rv_itag0_abort;
   input 			lq_rv_itag1_abort;


   input 			lq_rv_itag1_restart;
   input 			lq_rv_itag1_hold;
   input 			lq_rv_itag1_cord;
   input [0:`THREADS-1] 	lq_rv_itag1_rst_vld;
   input [0:`ITAG_SIZE_ENC-1] 	lq_rv_itag1_rst;
   input [0:`THREADS-1] 	lq_rv_clr_hold;

   input                        xx_rv_ex2_s1_abort;
   input                        xx_rv_ex2_s2_abort;
   input                        xx_rv_ex2_s3_abort;

   input 			q_hold_all;
   input [0:`THREADS-1] 	q_ord_complete;
   output [0:`THREADS-1] 	q_ord_tid;

   input [0:`THREADS-1] 	rv1_other_ilat0_vld;
   input [0:`ITAG_SIZE_ENC-1] 	rv1_other_ilat0_itag;
   output [0:`THREADS-1] 	rv1_other_ilat0_vld_out;
   output [0:`ITAG_SIZE_ENC-1] 	rv1_other_ilat0_itag_out;

   output [0:`THREADS-1] 	rv1_instr_vld;
   output [0:q_dat_width_g-1] 	rv1_instr_dat;
   output 			rv1_instr_spec;
   output 			rv1_instr_ord;
   output [0:`ITAG_SIZE_ENC-1] 	rv1_instr_itag;
   output [0:3] 		rv1_instr_ilat;
   output [0:`THREADS-1] 	rv1_instr_ilat0_vld;
   output [0:`THREADS-1] 	rv1_instr_ilat1_vld;
   output [0:`ITAG_SIZE_ENC-1] 	rv1_instr_s1_itag;
   output [0:`ITAG_SIZE_ENC-1] 	rv1_instr_s2_itag;
   output [0:`ITAG_SIZE_ENC-1] 	rv1_instr_s3_itag;
   output                       rv1_instr_is_brick;
   output [0:q_dat_ex0_width_g-1] ex0_instr_dat;
   output [0:`THREADS-1] 	ex1_credit_free;
   output [0:`THREADS-1] 	rvs_empty;
   output [0:8*`THREADS-1] 	rvs_perf_bus;
   output [0:31] 		rvs_dbg_bus;


   // pervasive
   inout 			vdd;
   inout 			gnd;
   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) // nclk
   input [0:`NCLK_WIDTH-1] 	nclk;
   input 			sg_1;
   input 			func_sl_thold_1;
   input 			ccflush_dc;
   input 			act_dis;
   input 			clkoff_b;
   input 			d_mode;
   input 			delay_lclkr;
   input 			mpw1_b;
   input 			mpw2_b;
   input 			scan_in;

   output 			scan_out;



   //-------------------------------------------------------------------------------------------------------
   // Type definitions
   //-------------------------------------------------------------------------------------------------------
   parameter                   q_ilat_width_g = 4;




   wire [0:`THREADS-1]          flush;
   wire [0:`THREADS-1] 		flush2;

   wire 			sg_0;
   wire 			func_sl_thold_0;
   wire 			func_sl_thold_0_b;
   wire 			force_t;

   wire 				       rv0_load1;
   wire 				       rv0_load2;
   wire 				       rv0_load1_instr_select;
   wire 				       rv0_instr_i0_flushed;
   wire 				       rv0_instr_i1_flushed;

   wire 				       rv0_instr_i0_s1_rdy;
   wire 				       rv0_instr_i0_s2_rdy;
   wire 				       rv0_instr_i0_s3_rdy;
   wire 				       rv0_instr_i1_s1_rdy;
   wire 				       rv0_instr_i1_s2_rdy;
   wire 				       rv0_instr_i1_s3_rdy;

   wire 				       rv0_i0_s1_itag_clear;
   wire 				       rv0_i0_s2_itag_clear;
   wire 				       rv0_i0_s3_itag_clear;
   wire 				       rv0_i1_s1_itag_clear;
   wire 				       rv0_i1_s2_itag_clear;
   wire 				       rv0_i1_s3_itag_clear;

   wire 				       rv0_i0_s1_itag_abort;
   wire 				       rv0_i0_s2_itag_abort;
   wire 				       rv0_i0_s3_itag_abort;
   wire 				       rv0_i1_s1_itag_abort;
   wire 				       rv0_i1_s2_itag_abort;
   wire 				       rv0_i1_s3_itag_abort;

   wire [0:`THREADS-1] 			       rv0_instr_i0_tid;
   wire [0:`THREADS-1] 			       rv0_instr_i1_tid;

   wire 				       lq_rv_itag1_restart_q;
   wire 				       lq_rv_itag1_hold_q;
   wire 				       lq_rv_itag1_cord_q;
   wire [0:`THREADS-1] 			       lq_rv_clr_hold_q;
   wire [0:`THREADS-1] 			       lq_rv_itag1_rst_vld_q;
   wire [0:`ITAG_SIZE_ENC-1] 		       lq_rv_itag1_rst_q;


   // reservation station entry elements
   wire [0:q_num_entries_g-1] 		       q_ev_b;
   wire [0:q_num_entries_g-1] 		       q_ev_d;
   wire [0:q_num_entries_g-1] 		       q_ev_q;
   wire [0:q_num_entries_g-1] 		       q_ord_d;
   wire [0:q_num_entries_g-1] 		       q_ord_q;
   wire [0:q_num_entries_g-1] 		       q_cord_d;
   wire [0:q_num_entries_g-1] 		       q_cord_q;
   wire [0:`ITAG_SIZE_ENC-1] 		       q_itag_d[0:q_num_entries_g-1];
   wire [0:`ITAG_SIZE_ENC-1] 		       q_itag_q[0:q_num_entries_g-1];
   wire [0:q_num_entries_g-1] 		       q_is_brick_d;
   wire [0:q_num_entries_g-1] 		       q_is_brick_q;
   wire [0:`THREADS-1] 			       q_tid_d[0:q_num_entries_g-1];
   wire [0:`THREADS-1] 			       q_tid_q[0:q_num_entries_g-1];
   wire [0:2] 				       q_brick_d[0:q_num_entries_g-1];
   wire [0:2] 				       q_brick_q[0:q_num_entries_g-1];
   wire [0:3] 				       q_ilat_d[0:q_num_entries_g-1];
   wire [0:3] 				       q_ilat_q[0:q_num_entries_g-1];
   wire [0:q_num_entries_g-1] 		       q_spec_d;
   wire [0:q_num_entries_g-1] 		       q_spec_q;
   wire [0:q_num_entries_g-1] 		       q_s1_v_d;
   wire [0:q_num_entries_g-1] 		       q_s1_v_q;
   wire [0:`ITAG_SIZE_ENC-1] 		       q_s1_itag_d[0:q_num_entries_g-1];
   wire [0:`ITAG_SIZE_ENC-1] 		       q_s1_itag_q[0:q_num_entries_g-1];
   wire [0:q_num_entries_g-1] 		       q_s2_v_d;
   wire [0:q_num_entries_g-1] 		       q_s2_v_q;
   wire [0:`ITAG_SIZE_ENC-1] 		       q_s2_itag_d[0:q_num_entries_g-1];
   wire [0:`ITAG_SIZE_ENC-1] 		       q_s2_itag_q[0:q_num_entries_g-1];
   wire [0:q_num_entries_g-1] 		       q_s3_v_d;
   wire [0:q_num_entries_g-1] 		       q_s3_v_q;
   wire [0:`ITAG_SIZE_ENC-1] 		       q_s3_itag_d[0:q_num_entries_g-1];
   wire [0:`ITAG_SIZE_ENC-1] 		       q_s3_itag_q[0:q_num_entries_g-1];
   wire [0:q_num_entries_g-1] 		       q_s1_rdy_d;
   wire [0:q_num_entries_g-1] 		       q_s1_rdy_q;
   wire [0:q_num_entries_g-1] 		       q_s2_rdy_d;
   wire [0:q_num_entries_g-1] 		       q_s2_rdy_q;
   wire [0:q_num_entries_g-1] 		       q_s3_rdy_d;
   wire [0:q_num_entries_g-1] 		       q_s3_rdy_q;
   wire [0:q_num_entries_g-1] 		       q_rdy_d;
   wire [0:q_num_entries_g-1] 		       q_rdy_q;
   wire [0:q_num_entries_g-1] 		       q_rdy_qb;
   wire [0:q_num_entries_g-1] 		       q_issued_d;
   wire [0:q_num_entries_g-1] 		       q_issued_q;
   wire [0:q_num_entries_g-1] 		       q_e_miss_d;
   wire [0:q_num_entries_g-1] 		       q_e_miss_q;
   wire [0:q_dat_width_g-1] 		       q_dat_d[0:q_num_entries_g-1];
   wire [0:q_dat_width_g-1] 		       q_dat_q[0:q_num_entries_g-1];
   wire [0:q_num_entries_g-1] 		       q_flushed_d;
   wire [0:q_num_entries_g-1] 		       q_flushed_q;
   wire [0:q_num_entries_g-1] 		       q_flushed_nxt;

   // reservation station set/clr/nxt signals
   wire [0:q_num_entries_g-1] 		       q_ev_clr;
   wire [0:q_num_entries_g-1] 		       q_ev_nxt;
   wire [0:q_num_entries_g-1] 		       q_ord_nxt;
   wire [0:q_num_entries_g-1] 		       q_cord_set;
   wire [0:q_num_entries_g-1] 		       q_cord_nxt;
   wire [0:q_num_entries_g-1] 		       q_spec_clr;
   wire [0:q_num_entries_g-1] 		       q_spec_nxt;
   wire [0:q_num_entries_g-1] 		       q_sx_rdy_nxt;
   wire [0:q_num_entries_g-1] 		       q_s1_rdy_sets;
   wire [0:q_num_entries_g-1] 		       q_s2_rdy_sets;
   wire [0:q_num_entries_g-1] 		       q_s3_rdy_sets;
   wire [0:q_num_entries_g-1] 		       q_s1_rdy_setf;
   wire [0:q_num_entries_g-1] 		       q_s2_rdy_setf;
   wire [0:q_num_entries_g-1] 		       q_s3_rdy_setf;
   wire [0:q_num_entries_g-1] 		       q_s1_rdy_clr;
   wire [0:q_num_entries_g-1] 		       q_s1_rdy_nxt;
   wire [0:q_num_entries_g-1] 		       q_s2_rdy_clr;
   wire [0:q_num_entries_g-1] 		       q_s2_rdy_nxt;
   wire [0:q_num_entries_g-1] 		       q_s3_rdy_clr;
   wire [0:q_num_entries_g-1] 		       q_s3_rdy_nxt;
   wire 				       q_i0_s_rdy;
   wire 				       q_i1_s_rdy;
   wire [0:q_num_entries_g-1] 		       q_rdy_set;
   wire [0:q_num_entries_g-1] 		       q_rdy_nxt;
   wire [4:q_num_entries_g-1] 		       q_issued_set;
   wire [4:q_num_entries_g-1] 		       q_issued_clr;
   wire [0:q_num_entries_g-1] 		       q_issued_nxt;
   wire [0:q_num_entries_g-1] 		       q_e_miss_set;
   wire [0:q_num_entries_g-1] 		       q_e_miss_clr;
   wire [0:q_num_entries_g-1] 		       q_e_miss_nxt;

   // itag match signals
   wire [0:q_num_entries_g-1] 		       q_lq_itag_match;
   wire [0:q_num_entries_g-1] 		       q_ilat0_match_s1;
   wire [0:q_num_entries_g-1] 		       q_ilat0_match_s2;
   wire [0:q_num_entries_g-1] 		       q_ilat0_match_s3;
   wire [0:q_num_entries_g-1] 		       q_other_ilat0_match_s1;
   wire [0:q_num_entries_g-1] 		       q_other_ilat0_match_s2;
   wire [0:q_num_entries_g-1] 		       q_other_ilat0_match_s3;
   wire [0:q_num_entries_g-1] 		       q_xx_itag_clear_s1;
   wire [0:q_num_entries_g-1] 		       q_xx_itag_clear_s2;
   wire [0:q_num_entries_g-1] 		       q_xx_itag_clear_s3;
   wire [0:q_num_entries_g-1] 		       q_xx_itag_abort_s1;
   wire [0:q_num_entries_g-1] 		       q_xx_itag_abort_s2;
   wire [0:q_num_entries_g-1] 		       q_xx_itag_abort_s3;

   // entry rdy/select/etc signals
   wire [4:q_num_entries_g-1] 		       q_entry_rdy;
   wire [4:q_num_entries_g-1] 		       q_entry_rdy_l1_b;
   wire [4:q_num_entries_g-1] 		       q_entry_rdy_l2a;
   wire [4:q_num_entries_g-1] 		       q_entry_rdy_l2b;
   wire [4:q_num_entries_g-1] 		       q_entry_rdy_l2c;

   wire [4:q_num_entries_g-1] 		       q_entry_rdy_pri;
   wire [4:q_num_entries_g-1] 		       q_entry_select;
   wire [0:q_num_entries_g-1] 		       q_entry_or_tree;
   wire [0:q_num_entries_g-1] 		       q_entry_and_tree;

   wire [0:`THREADS-1] 			       q_entry_ilat0[4:q_num_entries_g-1];
   wire [0:`THREADS-1] 			       q_entry_ilat1[4:q_num_entries_g-1];
   wire [0:q_dat_width_g-1] 		       q_instr_dat;
   wire [0:`THREADS-1] 			       q_instr_vld;
   wire [0:`THREADS-1] 			       q_instr_ilat0_vld;
   wire [0:`THREADS-1] 			       q_instr_ilat0_vld_l1a_b;
   wire [0:`THREADS-1] 			       q_instr_ilat0_vld_l1b_b;
   wire [0:`THREADS-1] 			       q_instr_ilat0_vld_rp;
   wire [0:`THREADS-1] 			       q_instr_ilat1_vld;
   wire 				       q_instr_is_brick;
   wire [0:2] 				       q_instr_brick;
   wire [0:`ITAG_SIZE_ENC-1] 		       q_instr_itag;
   wire [0:`ITAG_SIZE_ENC-1] 		       q_instr_itag_rp;
   wire [0:`ITAG_SIZE_ENC-1] 		       q_instr_itag_l1a_b;
   wire [0:`ITAG_SIZE_ENC-1] 		       q_instr_itag_l1b_b;
   wire [0:`ITAG_SIZE_ENC-1] 		       q_instr_s1_itag;
   wire [0:`ITAG_SIZE_ENC-1] 		       q_instr_s2_itag;
   wire [0:`ITAG_SIZE_ENC-1] 		       q_instr_s3_itag;
   wire [0:`THREADS-1] 			       q_instr_ilat0;
   wire [0:`THREADS-1] 			       q_instr_ilat1;
   wire [0:`THREADS-1] 			       q_tid_vld;
   // hold signals
   wire 				       q_hold_all_d;
   wire 				       q_hold_all_q;
   wire [0:`THREADS-1] 			       q_ord_completed;
   wire [0:`THREADS-1] 			       q_hold_ord_d;
   wire [0:`THREADS-1] 			       q_hold_ord_q;
   wire 				       q_hold_brick_d;
   wire 				       q_hold_brick_q;
   wire 				       q_hold_brick;
   wire [0:2] 				       q_hold_brick_cnt_d;
   wire [0:2] 				       q_hold_brick_cnt_q;
   wire [0:`THREADS-1] 			       q_hold_ord_set;
   wire 				       q_cord_match;
   wire [0:`ITAG_SIZE_ENC-1] 		       q_cp_next_itag;

   //credit release
   wire [0:q_num_entries_g-1] 		       q_credit_d;
   wire [0:q_num_entries_g-1] 		       q_credit_q;
   wire [0:q_num_entries_g-1] 		       q_credit_nxt;
   wire [0:q_num_entries_g-1] 		       q_credit_rdy;
   wire [0:q_num_entries_g-1] 		       q_credit_set;
   wire [0:q_num_entries_g-1] 		       q_credit_clr;
   wire [0:q_num_entries_g-1] 		       q_credit_take;
   wire [0:q_num_entries_g-1] 		       q_credit_ex3;
   wire [0:q_num_entries_g-1] 		       q_credit_ex6;
   wire [0:q_num_entries_g-1] 		       q_credit_flush;

   wire [0:`THREADS-1] 			       ex1_credit_free_d;
   wire [0:`THREADS-1] 			       ex1_credit_free_q;

   wire [0:`THREADS-1] 			       q_entry_tvld[0:q_num_entries_g-1];
   wire [0:q_num_entries_g-1] 		       q_entry_tvld_rev[0:`THREADS-1];
   wire [0:`THREADS-1] 			       rvs_empty_d;
   wire [0:`THREADS-1] 			       rvs_empty_q;

   //load/shift signals
   wire [0:q_num_entries_g-1] 		       q_entry_load;
   wire [0:q_num_entries_g-1] 		       q_entry_load2;
   wire [0:q_num_entries_g-1] 		       q_entry_load_i0;
   wire [0:q_num_entries_g-1] 		       q_entry_load_i1;
   wire [0:q_num_entries_g-1] 		       q_entry_shift;
   wire [0:q_num_entries_g-1] 		       q_entry_hold;
   wire [0:q_num_entries_g-1] 		       q_cord_act;
   wire [0:q_num_entries_g-1] 		       q_dat_act;
   wire [0:q_num_entries_g-1] 		       q_e_miss_act;

   wire [0:3] 		       issued_addr;
   wire [0:q_num_entries_g-1]  issued_shift[0:3];
   wire [0:3] 		       issued_addr_d[0:4];
   wire [0:3] 		       issued_addr_q[0:4];
   wire [0:`THREADS-1] 	       issued_vld_d[0:4];
   wire [0:`THREADS-1] 	       issued_vld_q[0:4];
   wire 		       xx_rv_ex2_abort;
   wire 		       xx_rv_ex3_abort;
   wire 		       xx_rv_ex4_abort;


   wire [0:q_num_entries_g-1]  ex3_instr_issued;
   wire [0:q_num_entries_g-1]  ex4_instr_issued;
   (* analysis_not_referenced="<0:3>true" *)
   wire [0:q_num_entries_g-1]  ex4_instr_aborted;

   wire 				       w0_en;
   wire 				       w1_en;
   wire [0:q_num_entries_g] 		       w_act;

   wire [0:`THREADS-1] 			       rv0_w0_en;
   wire [0:`THREADS-1] 			       rv0_w1_en;
   wire [0:`THREADS-1] 			       barf_ev_d[0:q_num_entries_g];
   wire [0:`THREADS-1] 			       barf_ev_q[0:q_num_entries_g];
   wire [0:q_num_entries_g] 		       barf_w0_ev_b;
   wire [0:q_num_entries_g] 		       barf_w1_ev_b;
   wire [0:q_num_entries_g] 		       barf_w0_or_tree;
   wire [0:q_num_entries_g] 		       barf_w1_or_tree;
   wire [0:q_num_entries_g] 		       rv0_w0_addr;
   wire [0:q_num_entries_g] 		       rv0_w1_addr;
   wire [0:q_barf_enc_g-1] 		       rv0_w0_addr_enc;
   wire [0:q_barf_enc_g-1] 		       rv0_w1_addr_enc;
   wire [0:q_barf_enc_g-1] 		       ex0_barf_addr_d;
   wire [0:q_barf_enc_g-1] 		       ex0_barf_addr_q;
   wire [0:q_barf_enc_g-1] 		       barf_clr_addr;
   wire [0:q_num_entries_g] 		       q_barf_clr;
   wire [0:q_barf_enc_g-1] 		       q_barf_addr_d[0:q_num_entries_g-1];
   wire [0:q_barf_enc_g-1] 		       q_barf_addr_q[0:q_num_entries_g-1];

   wire [0:`THREADS-1] xx_rv_rel_vld_d[0:q_itag_busses_g-1];
   wire [0:`THREADS-1] xx_rv_rel_vld_q[0:q_itag_busses_g-1];
   wire [0:q_itag_busses_g-1] xx_rv_abort_d;
   wire [0:q_itag_busses_g-1] xx_rv_abort_q;
   wire [0:`ITAG_SIZE_ENC-1]  xx_rv_rel_itag_d[0:q_itag_busses_g-1];
   wire [0:`ITAG_SIZE_ENC-1]  xx_rv_rel_itag_q[0:q_itag_busses_g-1];

   wire [4*q_dat_width_g:q_dat_width_g*q_num_entries_g-1] q_dat_ary;
   wire [4*`THREADS:`THREADS*q_num_entries_g-1] q_tid_ary;
   wire [4*3:3*q_num_entries_g-1] q_brick_ary;
   wire [4*`THREADS:`THREADS*q_num_entries_g-1] q_ilat0_ary;
   wire [4*`THREADS:`THREADS*q_num_entries_g-1] q_ilat1_ary;
   wire [4*`ITAG_SIZE_ENC:`ITAG_SIZE_ENC*q_num_entries_g-1] q_itag_ary;
   wire [4*`ITAG_SIZE_ENC:`ITAG_SIZE_ENC*q_num_entries_g-1] q_s1_itag_ary;
   wire [4*`ITAG_SIZE_ENC:`ITAG_SIZE_ENC*q_num_entries_g-1] q_s2_itag_ary;
   wire [4*`ITAG_SIZE_ENC:`ITAG_SIZE_ENC*q_num_entries_g-1] q_s3_itag_ary;
   wire [4*q_ilat_width_g:q_ilat_width_g*q_num_entries_g-1] q_ilat_ary;
   wire [4*q_barf_enc_g:q_barf_enc_g*q_num_entries_g-1] q_barf_addr_ary;
   wire [0             :q_barf_enc_g*q_num_entries_g-1] q_barf_clr_addr_ary;
   wire [0:`THREADS*q_num_entries_g-1] q_tid_full_ary;

   wire [0:q_itag_busses_g*`THREADS-1] xx_rv_itag_vld_ary;
   wire [0:q_itag_busses_g*(`ITAG_SIZE_ENC)-1] xx_rv_itag_ary;

   wire [0:8*`THREADS-1] 		       perf_bus_d;
   wire [0:8*`THREADS-1]		       perf_bus_q;

   wire [0:31] 		       dbg_bus_d;
   wire [0:31]		       dbg_bus_q;

   (* analysis_not_referenced="true" *)
   wire 		       no_lq_unused;
   (* analysis_not_referenced="true" *)
   wire 		       brick_unused;
   (* analysis_not_referenced="true" *)
   wire [0:q_num_entries_g-1]  brickn_unused;

   wire 				       tiup;

   //-------------------------------------------------------------------
   // Scanchain
   //-------------------------------------------------------------------
   parameter                   barf_offset = 0;
   parameter                   barf_ev_offset = barf_offset + 1;
   parameter                   ex0_barf_addr_offset = barf_ev_offset + (q_num_entries_g+1)* `THREADS;
   parameter                   issued_vld_offset =ex0_barf_addr_offset + q_barf_enc_g;
   parameter                   issued_addr_offset =issued_vld_offset + 5*`THREADS;
   parameter                   xx_rv_ex3_abort_offset = issued_addr_offset + 5*4;
   parameter                   xx_rv_ex4_abort_offset = xx_rv_ex3_abort_offset + 1;
   parameter                   flush_reg_offset = xx_rv_ex4_abort_offset + 1;
   parameter                   flush2_reg_offset = flush_reg_offset + `THREADS;
   parameter                   q_dat_offset = flush2_reg_offset + `THREADS;
   parameter                   q_itag_offset = q_dat_offset + q_num_entries_g * q_dat_width_g;
   parameter                   q_brick_offset = q_itag_offset + q_num_entries_g * `ITAG_SIZE_ENC;
   parameter                   q_ilat_offset = q_brick_offset + q_num_entries_g * 3;
   parameter                   q_barf_addr_offset = q_ilat_offset + q_num_entries_g * 4;
   parameter                   q_tid_offset = q_barf_addr_offset + q_num_entries_g * q_barf_enc_g;
   parameter                   q_s1_itag_offset = q_tid_offset + q_num_entries_g * `THREADS;
   parameter                   q_s2_itag_offset = q_s1_itag_offset + q_num_entries_g * `ITAG_SIZE_ENC;
   parameter                   q_s3_itag_offset = q_s2_itag_offset + q_num_entries_g * `ITAG_SIZE_ENC;
   parameter                   lq_rv_itag1_restart_offset = q_s3_itag_offset + q_num_entries_g * `ITAG_SIZE_ENC;
   parameter                   lq_rv_itag1_hold_offset = lq_rv_itag1_restart_offset + 1;
   parameter                   lq_rv_itag1_cord_offset = lq_rv_itag1_hold_offset + 1;
   parameter                   lq_rv_clr_hold_offset = lq_rv_itag1_cord_offset + 1;
   parameter                   lq_rv_itag1_rst_vld_offset = lq_rv_clr_hold_offset + `THREADS;
   parameter                   lq_rv_itag1_rst_offset = lq_rv_itag1_rst_vld_offset + `THREADS;
   parameter                   xx_rv_rel_vld_offset = lq_rv_itag1_rst_offset + `ITAG_SIZE_ENC;
   parameter                   xx_rv_rel_itag_offset = xx_rv_rel_vld_offset + q_itag_busses_g * `THREADS;
   parameter                   xx_rv_abort_offset = xx_rv_rel_itag_offset + q_itag_busses_g * `ITAG_SIZE_ENC;
   parameter                   q_ev_offset =  xx_rv_abort_offset + q_itag_busses_g;
   parameter                   q_flushed_offset = q_ev_offset + q_num_entries_g;
   parameter                   q_credit_offset = q_flushed_offset + q_num_entries_g;
   parameter                   ex1_credit_free_offset = q_credit_offset + q_num_entries_g;
   parameter                   rvs_empty_offset = ex1_credit_free_offset + `THREADS;
   parameter                   q_ord_offset = rvs_empty_offset + `THREADS;
   parameter                   q_cord_offset = q_ord_offset + q_num_entries_g;
   parameter                   q_is_brick_offset = q_cord_offset + q_num_entries_g;
   parameter                   q_spec_offset = q_is_brick_offset + q_num_entries_g;
   parameter                   q_s1_v_offset = q_spec_offset + q_num_entries_g;
   parameter                   q_s2_v_offset = q_s1_v_offset + q_num_entries_g;
   parameter                   q_s3_v_offset = q_s2_v_offset + q_num_entries_g;
   parameter                   q_s1_rdy_offset = q_s3_v_offset + q_num_entries_g;
   parameter                   q_s2_rdy_offset = q_s1_rdy_offset + q_num_entries_g;
   parameter                   q_s3_rdy_offset = q_s2_rdy_offset + q_num_entries_g;
   parameter                   q_rdy_offset = q_s3_rdy_offset + q_num_entries_g;
   parameter                   q_issued_offset = q_rdy_offset + q_num_entries_g;
   parameter                   q_e_miss_offset = q_issued_offset + q_num_entries_g;
   parameter                   q_hold_all_offset = q_e_miss_offset + q_num_entries_g;
   parameter                   q_hold_ord_offset = q_hold_all_offset + 1;
   parameter                   q_hold_brick_offset = q_hold_ord_offset + `THREADS;
   parameter                   q_hold_brick_cnt_offset = q_hold_brick_offset + 1;
   parameter                   perf_bus_offset = q_hold_brick_cnt_offset + 3;
   parameter                   dbg_bus_offset = perf_bus_offset + 8*`THREADS;

   parameter                   scan_right = dbg_bus_offset + 32;

   wire [0:scan_right-1] 		       siv;
   wire [0:scan_right-1] 		       sov;

   genvar                      n;
   genvar                      t;
   genvar                      i;



   //-------------------------------------------------------------------------------------------------------
   // Bugspray
   //-------------------------------------------------------------------------------------------------------
   //!! Bugspray Include: rv_station;

   //-------------------------------------------------------------------------------------------------------
   // misc
   //-------------------------------------------------------------------------------------------------------
   assign tiup = 1'b1;

   //-------------------------------------------------------------------------------------------------------
   // Barf array.  Data not needed until EX0
   //-------------------------------------------------------------------------------------------------------


   rv_barf #(.q_dat_width_g(q_dat_ex0_width_g), .q_num_entries_g(q_num_entries_g+1), .q_barf_enc_g(q_barf_enc_g) )
   barf(
	.w0_dat(rv0_instr_i0_dat_ex0),
	.w0_addr(rv0_w0_addr_enc),
	.w0_en(w0_en),
	.w1_dat(rv0_instr_i1_dat_ex0),
	.w1_addr(rv0_w1_addr_enc),
	.w1_en(w1_en),
	.w_act(w_act),
	.r0_addr(ex0_barf_addr_q),
	.r0_dat(ex0_instr_dat),
	.nclk(nclk),
	.vdd(vdd),
	.gnd(gnd),
	.sg_1(sg_1),
	.func_sl_thold_1(func_sl_thold_1),
	.ccflush_dc(ccflush_dc),
	.act_dis(act_dis),
	.clkoff_b(clkoff_b),
	.d_mode(d_mode),
	.delay_lclkr(delay_lclkr),
	.mpw1_b(mpw1_b),
	.mpw2_b(mpw2_b),
	.scan_in(siv[barf_offset]),
	.scan_out(sov[barf_offset])
	);

   assign rv0_w0_en = {`THREADS{rv0_instr_i0_rte}} & rv0_instr_i0_vld & ~({`THREADS{&flush2}}) ;
   assign rv0_w1_en = {`THREADS{rv0_instr_i1_rte}} & rv0_instr_i1_vld & ~({`THREADS{&flush2}}) ;

   assign w0_en = |rv0_w0_en;
   assign w1_en = |rv0_w1_en;
   assign w_act = (rv0_w0_addr | rv0_w1_addr) & {q_num_entries_g+1{(rv0_instr_i0_rte | rv0_instr_i1_rte)}};


   generate
      begin : xhdlbbar
         for (n = 0; n <= (q_num_entries_g ); n = n + 1)
           begin : genaddr
	      wire [0:q_barf_enc_g-1] id=n;

	      assign barf_w0_ev_b[n]    = ~(|(barf_ev_q[n]));
	      assign barf_w1_ev_b[n]    = ~(|(barf_ev_q[n]));

	      assign barf_w0_or_tree[n] = |(barf_w0_ev_b[n:q_num_entries_g]);
	      assign barf_w1_or_tree[n] = |(barf_w1_ev_b[0:n]);

	      //Mark the entry valid if it was written
	      assign barf_ev_d[n] = ((rv0_w0_en & {`THREADS{rv0_w0_addr[n]}}) |
				     (rv0_w1_en & {`THREADS{rv0_w1_addr[n]}}) |
				     (barf_ev_q[n]  & ~{`THREADS{q_barf_clr[n]}}) ) & ~({`THREADS{&flush}}) ;

	      //Clear logic
	      assign q_barf_clr[n] = |q_credit_rdy & (barf_clr_addr==id);


           end // block: genaddr
	 if(q_num_entries_g==12)
	   begin : baenc12
	      assign rv0_w0_addr_enc[0]= rv0_w0_addr[ 8]|rv0_w0_addr[ 9]|rv0_w0_addr[10]|rv0_w0_addr[11]|rv0_w0_addr[12];
	      assign rv0_w0_addr_enc[1]= rv0_w0_addr[ 4]|rv0_w0_addr[ 5]|rv0_w0_addr[ 6]|rv0_w0_addr[ 7]|rv0_w0_addr[12];
	      assign rv0_w0_addr_enc[2]= rv0_w0_addr[ 2]|rv0_w0_addr[ 3]|rv0_w0_addr[ 6]|rv0_w0_addr[ 7]|
					 rv0_w0_addr[10]|rv0_w0_addr[11];
	      assign rv0_w0_addr_enc[3]= rv0_w0_addr[ 1]|rv0_w0_addr[ 3]|rv0_w0_addr[ 5]|rv0_w0_addr[ 7]|
					 rv0_w0_addr[ 9]|rv0_w0_addr[11];
	      assign rv0_w1_addr_enc[0]= rv0_w1_addr[ 8]|rv0_w1_addr[ 9]|rv0_w1_addr[10]|rv0_w1_addr[11]|rv0_w1_addr[12];
	      assign rv0_w1_addr_enc[1]= rv0_w1_addr[ 4]|rv0_w1_addr[ 5]|rv0_w1_addr[ 6]|rv0_w1_addr[ 7]|rv0_w1_addr[12];
	      assign rv0_w1_addr_enc[2]= rv0_w1_addr[ 2]|rv0_w1_addr[ 3]|rv0_w1_addr[ 6]|rv0_w1_addr[ 7]|
					 rv0_w1_addr[10]|rv0_w1_addr[11];
	      assign rv0_w1_addr_enc[3]= rv0_w1_addr[ 1]|rv0_w1_addr[ 3]|rv0_w1_addr[ 5]|rv0_w1_addr[ 7]|
					 rv0_w1_addr[ 9]|rv0_w1_addr[11];
	   end
	 else
	   begin : baenc16
	      assign rv0_w0_addr_enc[0]= rv0_w0_addr[16];
	      assign rv0_w0_addr_enc[1]= rv0_w0_addr[ 8]|rv0_w0_addr[ 9]|rv0_w0_addr[10]|rv0_w0_addr[11]|
					 rv0_w0_addr[12]|rv0_w0_addr[13]|rv0_w0_addr[14]|rv0_w0_addr[15];
	      assign rv0_w0_addr_enc[2]= rv0_w0_addr[ 4]|rv0_w0_addr[ 5]|rv0_w0_addr[ 6]|rv0_w0_addr[ 7]|
					 rv0_w0_addr[12]|rv0_w0_addr[13]|rv0_w0_addr[14]|rv0_w0_addr[15];
	      assign rv0_w0_addr_enc[3]= rv0_w0_addr[ 2]|rv0_w0_addr[ 3]|rv0_w0_addr[ 6]|rv0_w0_addr[ 7]|
					 rv0_w0_addr[10]|rv0_w0_addr[11]|rv0_w0_addr[14]|rv0_w0_addr[15];
	      assign rv0_w0_addr_enc[4]= rv0_w0_addr[ 1]|rv0_w0_addr[ 3]|rv0_w0_addr[ 5]|rv0_w0_addr[ 7]|
					 rv0_w0_addr[ 9]|rv0_w0_addr[11]|rv0_w0_addr[13]|rv0_w0_addr[15];
	      assign rv0_w1_addr_enc[0]= rv0_w1_addr[16];
	      assign rv0_w1_addr_enc[1]= rv0_w1_addr[ 8]|rv0_w1_addr[ 9]|rv0_w1_addr[10]|rv0_w1_addr[11]|
					 rv0_w1_addr[12]|rv0_w1_addr[13]|rv0_w1_addr[14]|rv0_w1_addr[15];
	      assign rv0_w1_addr_enc[2]= rv0_w1_addr[ 4]|rv0_w1_addr[ 5]|rv0_w1_addr[ 6]|rv0_w1_addr[ 7]|
					 rv0_w1_addr[12]|rv0_w1_addr[13]|rv0_w1_addr[14]|rv0_w1_addr[15];
	      assign rv0_w1_addr_enc[3]= rv0_w1_addr[ 2]|rv0_w1_addr[ 3]|rv0_w1_addr[ 6]|rv0_w1_addr[ 7]|
					 rv0_w1_addr[10]|rv0_w1_addr[11]|rv0_w1_addr[14]|rv0_w1_addr[15];
	      assign rv0_w1_addr_enc[4]= rv0_w1_addr[ 1]|rv0_w1_addr[ 3]|rv0_w1_addr[ 5]|rv0_w1_addr[ 7]|
					 rv0_w1_addr[ 9]|rv0_w1_addr[11]|rv0_w1_addr[13]|rv0_w1_addr[15];
	   end

      end
   endgenerate
   assign rv0_w0_addr[0] = barf_w0_or_tree[0] & ~barf_w0_or_tree[1];
   assign rv0_w1_addr[0] = barf_w1_or_tree[0];
   generate
      begin : xhdlbbar2
         for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
           begin : genaddr2

	      assign rv0_w0_addr[n] = barf_w0_or_tree[n] & ~barf_w0_or_tree[n+1];
	      assign rv0_w1_addr[n] = barf_w1_or_tree[n] & ~barf_w1_or_tree[n-1];

           end
      end
   endgenerate
   assign rv0_w0_addr[q_num_entries_g] = barf_w0_or_tree[q_num_entries_g];
   assign rv0_w1_addr[q_num_entries_g] = barf_w1_or_tree[q_num_entries_g] & ~barf_w1_or_tree[q_num_entries_g-1];

   //-------------------------------------------------------------------------------------------------------
   // Compute instruction bus controls in RV0
   //-------------------------------------------------------------------------------------------------------
   assign rv0_load1 = (rv0_instr_i0_rte  | rv0_instr_i1_rte ) & (~(&(flush)) & ~(&(flush2)));
   assign rv0_load2 = (rv0_instr_i0_rte  & rv0_instr_i1_rte ) & (~(&(flush)) & ~(&(flush2)));
   assign rv0_load1_instr_select = (rv0_instr_i1_rte ) & (~rv0_load2);


   assign rv0_instr_i0_tid = rv0_instr_i0_vld;
   assign rv0_instr_i1_tid = rv0_instr_i1_vld;

   assign rv0_instr_i0_flushed = |(rv0_instr_i0_vld & (flush | flush2));
   assign rv0_instr_i1_flushed = |(rv0_instr_i1_vld & (flush | flush2));


   //-------------------------------------------------------------------------------------------------------
   // generation of logic to manage the q ev (entry valid) bits.
   //-------------------------------------------------------------------------------------------------------
   assign q_ev_d[0] = (q_entry_load_i1[0]) | (q_entry_load_i0[0]) | (1'b0 & q_entry_shift[0]) | (q_ev_nxt[0] & q_entry_hold[0]);

   generate
      begin : xhdl1
         for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_ev_gen
              assign q_ev_d[n] = (q_entry_load_i1[n]) | (q_entry_load_i0[n]) | (q_ev_nxt[n - 1] & q_entry_shift[n]) | (q_ev_nxt[n] & q_entry_hold[n]);
           end
      end
   endgenerate

   generate
      begin : xhdl2
         for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_ev_nxt_gen
              assign q_ev_clr[n] =  q_credit_take[n] | &(flush);

              assign q_ev_nxt[n] = q_ev_q[n] & (~q_ev_clr[n]);
           end
      end
   endgenerate


   //-------------------------------------------------------------------------------------------------------
   // generation of the itag for this entry's cmd
   //-------------------------------------------------------------------------------------------------------
   assign q_itag_d[0] = (rv0_instr_i1_itag & {`ITAG_SIZE_ENC{q_entry_load_i1[0]}}) |
			(rv0_instr_i0_itag & {`ITAG_SIZE_ENC{q_entry_load_i0[0]}}) |
			(q_itag_q[0] & {`ITAG_SIZE_ENC{q_entry_hold[0]}});

   generate
      begin : xhdl7
         for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_itag_gen
              assign q_itag_d[n] = (rv0_instr_i1_itag & {`ITAG_SIZE_ENC{q_entry_load_i1[n]}}) |
				   (rv0_instr_i0_itag & {`ITAG_SIZE_ENC{q_entry_load_i0[n]}}) |
				   (q_itag_q[n - 1] & {`ITAG_SIZE_ENC{q_entry_shift[n]}}) |
				   (q_itag_q[n] & {`ITAG_SIZE_ENC{q_entry_hold[n]}});
           end
      end
   endgenerate


   //-------------------------------------------------------------------------------------------------------
   // generation of the tid for this entry's cmd
   //-------------------------------------------------------------------------------------------------------

   assign q_tid_d[0] = ({`THREADS{q_entry_load_i1[0]}} & rv0_instr_i1_tid ) |
                       ({`THREADS{q_entry_load_i0[0]}} & rv0_instr_i0_tid ) |
                       ({`THREADS{q_entry_hold[0]}} & q_tid_q[0]);
   generate
      begin : xhdl10
         for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_tid_gen
              assign q_tid_d[n] = ({`THREADS{q_entry_load_i1[n]}} & rv0_instr_i1_tid ) |
                                  ({`THREADS{q_entry_load_i0[n]}} & rv0_instr_i0_tid ) |
                                  ({`THREADS{q_entry_shift[n]}} & q_tid_q[n - 1] ) |
                                  ({`THREADS{q_entry_hold[n]}} & q_tid_q[n]);
           end
      end
   endgenerate

   //-------------------------------------------------------------------------------------------------------
   // generation of the flush for this entry's cmd
   //-------------------------------------------------------------------------------------------------------
   assign q_flushed_d[0] = (rv0_instr_i1_flushed & q_entry_load_i1[0]) | (rv0_instr_i0_flushed & q_entry_load_i0[0]) | (q_flushed_nxt[0] & q_entry_hold[0]);

   generate
      begin : xhdl11
         for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_flushed_gen
              assign q_flushed_d[n] = (rv0_instr_i1_flushed & q_entry_load_i1[n]) |
				      (rv0_instr_i0_flushed & q_entry_load_i0[n]) |
				      (q_flushed_nxt[n - 1] & q_entry_shift[n]) |
				      (q_flushed_nxt[n] & q_entry_hold[n]);
           end
      end
   endgenerate

   generate
      begin : xhdl12
         for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_flushed_nxt_gen
              assign q_flushed_nxt[n] = q_ev_q[n] & |(q_tid_q[n] & ({`THREADS{q_flushed_q[n]}} | flush));
           end
      end
   endgenerate


   //-------------------------------------------------------------------------------------------------------
   // Save the ex0 indirect address
   //-------------------------------------------------------------------------------------------------------
   assign q_barf_addr_d[0] = (rv0_w0_addr_enc & {q_barf_enc_g{q_entry_load_i0[0]}}) |
			     (rv0_w1_addr_enc & {q_barf_enc_g{q_entry_load_i1[0]}}) |
			     (q_barf_addr_q[0] & {q_barf_enc_g{q_entry_hold[0]}});

   generate
      begin : xhdl11b
         for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_barf_addr_gen
              assign q_barf_addr_d[n] = (rv0_w0_addr_enc & {q_barf_enc_g{q_entry_load_i0[n]}}) |
					(rv0_w1_addr_enc & {q_barf_enc_g{q_entry_load_i1[n]}}) |
					(q_barf_addr_q[n - 1] & {q_barf_enc_g{q_entry_shift[n]}}) |
					(q_barf_addr_q[n]     & {q_barf_enc_g{q_entry_hold[n]}});
           end
      end
   endgenerate

   //-------------------------------------------------------------------------------------------------------
   // ILAT
   //-------------------------------------------------------------------------------------------------------

   assign q_ilat_d[0] = ({q_ilat_width_g{q_entry_load_i1[0]}} & rv0_instr_i1_ilat ) |
                        ({q_ilat_width_g{q_entry_load_i0[0]}} & rv0_instr_i0_ilat ) |
                        ({q_ilat_width_g{q_entry_hold[0]}} & q_ilat_q[0]);
   generate
      begin : xhdl13
         for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_ilat_gen
              assign q_ilat_d[n] = ({q_ilat_width_g{q_entry_load_i1[n]}} & rv0_instr_i1_ilat ) |
                                   ({q_ilat_width_g{q_entry_load_i0[n]}} & rv0_instr_i0_ilat ) |
                                   ({q_ilat_width_g{q_entry_shift[n]}} & q_ilat_q[n - 1] ) |
                                   ({q_ilat_width_g{q_entry_hold[n]}} & q_ilat_q[n]);
           end
      end
   endgenerate


   //-------------------------------------------------------------------------------------------------------
   // generation of logic for the source valid fields that are present in each reservation station entry
   //-------------------------------------------------------------------------------------------------------
   assign q_s1_v_d[0] = (rv0_instr_i1_s1_v & q_entry_load_i1[0]) |
			(rv0_instr_i0_s1_v & q_entry_load_i0[0]) |
			(q_s1_v_q[0] & q_entry_hold[0]);

   assign q_s2_v_d[0] = (rv0_instr_i1_s2_v & q_entry_load_i1[0]) |
			(rv0_instr_i0_s2_v & q_entry_load_i0[0]) |
			(q_s2_v_q[0] & q_entry_hold[0]);

   assign q_s3_v_d[0] = (rv0_instr_i1_s3_v & q_entry_load_i1[0]) |
			(rv0_instr_i0_s3_v & q_entry_load_i0[0]) |
			(q_s3_v_q[0] & q_entry_hold[0]);

   generate
      begin : xhdl16
         for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_sv_gen
              assign q_s1_v_d[n] = (rv0_instr_i1_s1_v & q_entry_load_i1[n]) |
				   (rv0_instr_i0_s1_v & q_entry_load_i0[n]) |
				   (q_s1_v_q[n - 1]   & q_entry_shift[n]) |
				   (q_s1_v_q[n]       & q_entry_hold[n]);

              assign q_s2_v_d[n] = (rv0_instr_i1_s2_v & q_entry_load_i1[n]) |
				   (rv0_instr_i0_s2_v & q_entry_load_i0[n]) |
				   (q_s2_v_q[n - 1]   & q_entry_shift[n]) |
				   (q_s2_v_q[n]       & q_entry_hold[n]);

              assign q_s3_v_d[n] = (rv0_instr_i1_s3_v & q_entry_load_i1[n]) |
				   (rv0_instr_i0_s3_v & q_entry_load_i0[n]) |
				   (q_s3_v_q[n - 1]   & q_entry_shift[n]) |
				   (q_s3_v_q[n]       & q_entry_hold[n]);
           end
      end
   endgenerate

   //-------------------------------------------------------------------------------------------------------
   // generation of logic for the dependent itags
   //-------------------------------------------------------------------------------------------------------

   assign q_s1_itag_d[0] = (rv0_instr_i1_s1_itag & {`ITAG_SIZE_ENC{q_entry_load_i1[0]}}) |
                           (rv0_instr_i0_s1_itag & {`ITAG_SIZE_ENC{q_entry_load_i0[0]}}) |
                           (q_s1_itag_q[0] & {`ITAG_SIZE_ENC{q_entry_hold[0]}});

   assign q_s2_itag_d[0] = (rv0_instr_i1_s2_itag & {`ITAG_SIZE_ENC{q_entry_load_i1[0]}}) |
                           (rv0_instr_i0_s2_itag & {`ITAG_SIZE_ENC{q_entry_load_i0[0]}}) |
                           (q_s2_itag_q[0] & {`ITAG_SIZE_ENC{q_entry_hold[0]}});

   assign q_s3_itag_d[0] = (rv0_instr_i1_s3_itag & {`ITAG_SIZE_ENC{q_entry_load_i1[0]}}) |
                           (rv0_instr_i0_s3_itag & {`ITAG_SIZE_ENC{q_entry_load_i0[0]}}) |
                           (q_s3_itag_q[0] & {`ITAG_SIZE_ENC{q_entry_hold[0]}});

   generate
      begin : xhdl17
         for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_sitag_gen

              assign q_s1_itag_d[n] = (rv0_instr_i1_s1_itag & {`ITAG_SIZE_ENC{q_entry_load_i1[n]}}) |
				      (rv0_instr_i0_s1_itag & {`ITAG_SIZE_ENC{q_entry_load_i0[n]}}) |
				      (q_s1_itag_q[n-1]     & {`ITAG_SIZE_ENC{q_entry_shift[n]}}) |
				      (q_s1_itag_q[n]       & {`ITAG_SIZE_ENC{q_entry_hold[n]}});

              assign q_s2_itag_d[n] = (rv0_instr_i1_s2_itag & {`ITAG_SIZE_ENC{q_entry_load_i1[n]}}) |
				      (rv0_instr_i0_s2_itag & {`ITAG_SIZE_ENC{q_entry_load_i0[n]}}) |
				      (q_s2_itag_q[n-1]     & {`ITAG_SIZE_ENC{q_entry_shift[n]}}) |
				      (q_s2_itag_q[n]       & {`ITAG_SIZE_ENC{q_entry_hold[n]}});

              assign q_s3_itag_d[n] = (rv0_instr_i1_s3_itag & {`ITAG_SIZE_ENC{q_entry_load_i1[n]}}) |
				      (rv0_instr_i0_s3_itag & {`ITAG_SIZE_ENC{q_entry_load_i0[n]}}) |
				      (q_s3_itag_q[n-1]     & {`ITAG_SIZE_ENC{q_entry_shift[n]}}) |
				      (q_s3_itag_q[n]       & {`ITAG_SIZE_ENC{q_entry_hold[n]}});

           end
      end
   endgenerate

   //-------------------------------------------------------------------------------------------------------
   // generation of source rdy logic
   //-------------------------------------------------------------------------------------------------------lol

   assign q_s1_rdy_d[0] = (rv0_instr_i1_s1_rdy & q_entry_load_i1[0]) |
			  (rv0_instr_i0_s1_rdy & q_entry_load_i0[0]) |
			  (q_s1_rdy_nxt[0]     & q_entry_hold[0] );
   assign q_s2_rdy_d[0] = (rv0_instr_i1_s2_rdy & q_entry_load_i1[0]) |
			  (rv0_instr_i0_s2_rdy & q_entry_load_i0[0]) |
			  (q_s2_rdy_nxt[0]     & q_entry_hold[0] );
   assign q_s3_rdy_d[0] = (rv0_instr_i1_s3_rdy & q_entry_load_i1[0]) |
			  (rv0_instr_i0_s3_rdy & q_entry_load_i0[0]) |
			  (q_s3_rdy_nxt[0]     & q_entry_hold[0] );


   generate
      begin : xhdl20
         for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_srdy_gen
              assign q_s1_rdy_d[n] = (rv0_instr_i1_s1_rdy & q_entry_load_i1[n]) |
				     (rv0_instr_i0_s1_rdy & q_entry_load_i0[n]) |
				     (q_s1_rdy_nxt[n - 1] & q_entry_shift[n]) |
				     (q_s1_rdy_nxt[n] & q_entry_hold[n]);
              assign q_s2_rdy_d[n] = (rv0_instr_i1_s2_rdy & q_entry_load_i1[n]) |
				     (rv0_instr_i0_s2_rdy & q_entry_load_i0[n]) |
				     (q_s2_rdy_nxt[n - 1] & q_entry_shift[n]) |
				     (q_s2_rdy_nxt[n] & q_entry_hold[n]);
              assign q_s3_rdy_d[n] = (rv0_instr_i1_s3_rdy & q_entry_load_i1[n]) |
				     (rv0_instr_i0_s3_rdy & q_entry_load_i0[n]) |
				     (q_s3_rdy_nxt[n - 1] & q_entry_shift[n]) |
				     (q_s3_rdy_nxt[n] & q_entry_hold[n]);
           end
      end
   endgenerate

   generate
      begin : xhdl21
         for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_srdy_nxt_gen
              assign q_s1_rdy_setf[n] = (q_other_ilat0_match_s1[n] | q_ilat0_match_s1[n]);
              assign q_s2_rdy_setf[n] = (q_other_ilat0_match_s2[n] | q_ilat0_match_s2[n]);
              assign q_s3_rdy_setf[n] = (q_other_ilat0_match_s3[n] | q_ilat0_match_s3[n]);
              assign q_s1_rdy_sets[n] = q_xx_itag_clear_s1[n] | q_s1_rdy_q[n] | ~q_s1_v_q[n];
              assign q_s2_rdy_sets[n] = q_xx_itag_clear_s2[n] | q_s2_rdy_q[n] | ~q_s2_v_q[n];
              assign q_s3_rdy_sets[n] = q_xx_itag_clear_s3[n] | q_s3_rdy_q[n] | ~q_s3_v_q[n];

              assign q_s1_rdy_clr[n] = q_xx_itag_abort_s1[n] & q_s1_v_q[n];
              assign q_s2_rdy_clr[n] = q_xx_itag_abort_s2[n] & q_s2_v_q[n] ;
              assign q_s3_rdy_clr[n] = q_xx_itag_abort_s3[n] & q_s3_v_q[n];

              assign q_s1_rdy_nxt[n] = ((q_s1_rdy_setf[n] | q_s1_rdy_sets[n]) & (~q_s1_rdy_clr[n]) ) ;
              assign q_s2_rdy_nxt[n] = ((q_s2_rdy_setf[n] | q_s2_rdy_sets[n]) & (~q_s2_rdy_clr[n]) ) ;
              assign q_s3_rdy_nxt[n] = ((q_s3_rdy_setf[n] | q_s3_rdy_sets[n]) & (~q_s3_rdy_clr[n]) ) ;

	      assign q_sx_rdy_nxt[n] = q_s1_rdy_nxt[n] & q_s2_rdy_nxt[n] & q_s3_rdy_nxt[n] ;

           end
      end
   endgenerate

   //-------------------------------------------------------------------------------------------------------
   // generation of rdy logic
   //-------------------------------------------------------------------------------------------------------

   assign q_i0_s_rdy = (rv0_instr_i0_s1_rdy) & (rv0_instr_i0_s2_rdy) & (rv0_instr_i0_s3_rdy) & ~(rv0_instr_i0_ord | rv0_instr_i0_cord | rv0_instr_i0_flushed);
   assign q_i1_s_rdy = (rv0_instr_i1_s1_rdy) & (rv0_instr_i1_s2_rdy) & (rv0_instr_i1_s3_rdy) & ~(rv0_instr_i1_ord | rv0_instr_i1_cord | rv0_instr_i1_flushed);

   assign q_rdy_d[0] = (q_i1_s_rdy & q_entry_load_i1[0]) |
		       (q_i0_s_rdy & q_entry_load_i0[0]) |
		       (q_entry_hold[0] & q_rdy_nxt[0]);

   generate
      begin : xhdl22
         for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_rdy_gen
              assign q_rdy_d[n] = (q_i1_s_rdy & q_entry_load_i1[n]) |
				  (q_i0_s_rdy & q_entry_load_i0[n]) |
				  (q_rdy_nxt[n - 1] & q_entry_shift[n]) |
				  (q_rdy_nxt[n] & q_entry_hold[n]);
           end
      end
   endgenerate

   generate
      begin : xhdl23
         for (n = 0; n <= (q_num_entries_g - 2); n = n + 1)
           begin : q_rdy_nxt_gen
              assign q_rdy_set[n] = ( (~q_e_miss_nxt[n])) &
				    ((~q_ord_q[n])) & ((~(q_cord_q[n] | q_cord_nxt[n]))) &
				    (~q_issued_nxt[n]) & (~q_flushed_nxt[n]) & q_ev_nxt[n];

              assign q_rdy_nxt[n] =  q_rdy_set[n] & q_sx_rdy_nxt[n];

           end
      end
   endgenerate

   //Last Entry
   assign q_rdy_set[q_num_entries_g - 1] = (~q_e_miss_nxt[q_num_entries_g - 1]) &
					   ((~q_ord_q[q_num_entries_g - 1]) | (q_ord_q[q_num_entries_g - 1] & ~(|(q_hold_ord_q)))) &
					   ((~q_cord_nxt[q_num_entries_g - 1]) | (q_cord_q[q_num_entries_g - 1] & q_cord_match)) &
                                            (~q_issued_nxt[q_num_entries_g - 1]) & (~q_flushed_nxt[q_num_entries_g - 1]) & q_ev_nxt[q_num_entries_g - 1];


   assign q_rdy_nxt[q_num_entries_g - 1] =  q_rdy_set[q_num_entries_g - 1] & q_sx_rdy_nxt[q_num_entries_g - 1];


   //-------------------------------------------------------------------------------------------------------
   // generation of issued logic
   //-------------------------------------------------------------------------------------------------------
   assign q_issued_nxt[0:3] = 4'b0;
   assign q_issued_d[0:3] = 4'b0;

   assign q_issued_d[4] =   q_issued_nxt[4] & q_entry_hold[4];

   generate
      begin : xhdl24
         for (n = 5; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_issued_gen

              assign q_issued_d[n] = (q_issued_nxt[n - 1] & q_entry_shift[n]) |
                                     (q_issued_nxt[n]     & q_entry_hold[n]);
           end
      end
   endgenerate

   // If its not ready, its not issued nxt
   generate
      begin : xhdl25
         for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_issued_nxt_gen
              assign q_issued_set[n] = q_entry_select[n];

              assign q_issued_clr[n] = (q_lq_itag_match[n] & q_spec_q[n] & lq_rv_itag1_restart_q) |
				       ((q_e_miss_q[n] | q_e_miss_nxt[n]) & q_spec_q[n]) |
				       (ex4_instr_aborted[n] );

              assign q_issued_nxt[n] = (q_issued_q[n] | q_issued_set[n]) & (~q_issued_clr[n]);
           end
      end
   endgenerate


   //-------------------------------------------------------------------------------------------------------
   // generation of the data field that is present in each reservation station entry
   //-------------------------------------------------------------------------------------------------------
   assign q_dat_d[0] = (rv0_instr_i1_dat & {q_dat_width_g{q_entry_load_i1[0]}}) |
		       (rv0_instr_i0_dat & {q_dat_width_g{q_entry_load_i0[0]}}) |
		       ({q_dat_width_g{1'b0}} & {q_dat_width_g{q_entry_shift[0]}}) |
                       (q_dat_q[0] & {q_dat_width_g{q_entry_hold[0]}});		//feedback

   generate
      begin : xhdl28
         for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_dat_gen
              assign q_dat_d[n] = (rv0_instr_i1_dat & {q_dat_width_g{q_entry_load_i1[n]}}) |
				  (rv0_instr_i0_dat & {q_dat_width_g{q_entry_load_i0[n]}}) |
				  (q_dat_q[n - 1] & {q_dat_width_g{q_entry_shift[n]}}) |
				  (q_dat_q[n] & {q_dat_width_g{q_entry_hold[n]}});		//feedback
           end
      end
   endgenerate

   //-------------------------------------------------------------------------------------------------------
   // generation of q_entry_rdy logic.  These are used after prioritization as mux selects to remove entries
   //-------------------------------------------------------------------------------------------------------
   generate
      begin : xhdl29
         for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_entry_rdy_gen
              assign q_entry_rdy[n] =   q_rdy_q[n] ;

           end
      end
   endgenerate

   // q_entry_rdy Fanout Tree
   assign q_entry_rdy_l1_b = (~q_entry_rdy);
   assign q_entry_rdy_l2a = (~q_entry_rdy_l1_b);
   assign q_entry_rdy_l2b = (~q_entry_rdy_l1_b);
   assign q_entry_rdy_l2c = (~q_entry_rdy_l1_b);

   //-------------------------------------------------------------------------------------------------------
   // generation of ilat0 compare for zero bypass cases.  Do it early for timing
   //-------------------------------------------------------------------------------------------------------
   generate
      begin : xhdl30
         for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_entry_ilat0_gen
              assign q_entry_ilat0[n] = q_tid_q[n] & {`THREADS{(q_ilat_q[n] == 4'b0000) }};
           end
      end
   endgenerate

   generate
      begin : xhdl31
         for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_entry_ilat1_gen
              assign q_entry_ilat1[n] = q_tid_q[n] & {`THREADS{(q_ilat_q[n] == 4'b0001) }};
           end
      end
   endgenerate

   //-------------------------------------------------------------------------------------------------------
   // generation of q_entry_rdy_pri logic. These are the gates that represent the prioritization
   //   The prioritized result is gated with hold in order to be able to prevent an instruction
   //   from being selected
   //-------------------------------------------------------------------------------------------------------

   rv_rpri #(.size(q_num_entries_g-4))
   q_rdy_pri(
             .cond(q_entry_rdy),
             .pri(q_entry_rdy_pri)
             );

   assign q_entry_select = ~(q_hold_all_q | q_hold_brick) ? q_entry_rdy_pri : {q_num_entries_g-4{1'b0}};

   generate
        begin : dat_extnd
	   for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
             begin : dat_extnda
		assign q_dat_ary[n*q_dat_width_g:(n+1)*q_dat_width_g-1] = q_dat_q[n];

             end
	end
   endgenerate

   rv_primux #(.q_dat_width_g(q_dat_width_g),  .q_num_entries_g(q_num_entries_g-4))
   q_dat_mux(
             .cond(q_entry_rdy_l2c),
             .din(q_dat_ary),
             .dout(q_instr_dat)
             );
   assign rv1_instr_dat = q_instr_dat;


   generate
        begin : tid_extnd
	   for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
             begin : tid_extnda
		assign q_tid_ary[n*`THREADS:(n+1)*`THREADS-1] = q_tid_q[n];

             end
	end
   endgenerate
   rv_prisel #(.q_dat_width_g(`THREADS),  .q_num_entries_g(q_num_entries_g-4))
   q_vld_mux(
             .cond(q_entry_rdy_l2b),
             .din(q_tid_ary),
             .dout(q_tid_vld)
             );
   assign q_instr_vld = q_tid_vld & {`THREADS{(~(q_hold_all_q | q_hold_brick))}};
   assign rv1_instr_vld = q_instr_vld;

   assign q_instr_is_brick = |(q_entry_select & q_is_brick_q[4:q_num_entries_g-1]);
   assign rv1_instr_is_brick = |(q_entry_rdy_pri & q_is_brick_q[4:q_num_entries_g-1]);

   generate
        begin : brick_extnd
	   for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
             begin : brick_extnda
		assign q_brick_ary[n*3:(n+1)*3-1] = q_brick_q[n];

             end
	end
   endgenerate
   rv_primux #(.q_dat_width_g(3),  .q_num_entries_g(q_num_entries_g-4))
   q_brick_mux(
             .cond(q_entry_rdy_pri),
             .din(q_brick_ary),
             .dout(q_instr_brick)
             );

   assign rv1_instr_ord = |(q_entry_rdy_pri &  q_ord_q[4:q_num_entries_g-1]);

   assign rv1_other_ilat0_vld_out =  ~q_instr_ilat0_vld_l1a_b;
   assign rv1_other_ilat0_itag_out = ~q_instr_itag_l1a_b;

   //-------------------------------------------------------------------------------------------------------
   generate
        begin : ilat0_extnd
	   for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
             begin : ilat0_extnda
		assign q_ilat0_ary[n*`THREADS:(n+1)*`THREADS-1] = q_entry_ilat0[n];

             end
	end
   endgenerate
   rv_prisel #(.q_dat_width_g(`THREADS),  .q_num_entries_g(q_num_entries_g-4))
   q_ilat0_vld_mux(
             .cond(q_entry_rdy_l2b),
             .din(q_ilat0_ary),
             .dout(q_instr_ilat0)
             );

   assign q_instr_ilat0_vld_rp = q_instr_ilat0 & q_instr_vld;
   tri_inv #(.WIDTH(`THREADS)) q_itagvrp_l1a  (q_instr_ilat0_vld_l1a_b, q_instr_ilat0_vld_rp); //ilat0_out
   tri_inv #(.WIDTH(`THREADS)) q_itagvrp_l1b  (q_instr_ilat0_vld_l1b_b, q_instr_ilat0_vld_rp); //everything else

   assign q_instr_ilat0_vld = ~q_instr_ilat0_vld_l1b_b;

   assign rv1_instr_ilat0_vld = q_instr_ilat0_vld;

   //-------------------------------------------------------------------------------------------------------
   generate
        begin : ilat1_extnd
	   for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
             begin : ilat1_extnda
		assign q_ilat1_ary[n*`THREADS:(n+1)*`THREADS-1] = q_entry_ilat1[n];

             end
	end
   endgenerate
   rv_prisel #(.q_dat_width_g(`THREADS),  .q_num_entries_g(q_num_entries_g-4))
   q_ilat1_vld_mux(
             .cond(q_entry_rdy_l2b),
             .din(q_ilat1_ary),
             .dout(q_instr_ilat1)
             );

   assign q_instr_ilat1_vld = q_instr_ilat1 & q_instr_vld;
   assign rv1_instr_ilat1_vld = q_instr_ilat1_vld;

   //-------------------------------------------------------------------------------------------------------
   generate
        begin : itag_extnd
	   for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
             begin : itag_extnda
		assign q_itag_ary[n*`ITAG_SIZE_ENC:(n+1)*`ITAG_SIZE_ENC-1] = q_itag_q[n];

             end
	end
   endgenerate
   rv_primux #(.q_dat_width_g(`ITAG_SIZE_ENC),  .q_num_entries_g(q_num_entries_g-4))
   q_itag_mux(
             .cond(q_entry_rdy_l2b),
             .din(q_itag_ary),
             .dout(q_instr_itag_rp)
             );

   tri_inv #(.WIDTH(`ITAG_SIZE_ENC)) q_itagrp_l1a  (q_instr_itag_l1a_b, q_instr_itag_rp); //ilat0_out
   tri_inv #(.WIDTH(`ITAG_SIZE_ENC)) q_itagrp_l1b  (q_instr_itag_l1b_b, q_instr_itag_rp); //everything else

   assign q_instr_itag = ~q_instr_itag_l1b_b;

   assign rv1_instr_itag = q_instr_itag;


   //-------------------------------------------------------------------------------------------------------
   generate
        begin : s1_itag_extnd
	   for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
             begin : s1_itag_extnda
		assign q_s1_itag_ary[n*`ITAG_SIZE_ENC:(n+1)*`ITAG_SIZE_ENC-1] = q_s1_itag_q[n];

             end
	end
   endgenerate
   rv_primux #(.q_dat_width_g(`ITAG_SIZE_ENC),  .q_num_entries_g(q_num_entries_g-4))
   q_s1_itag_mux(
             .cond(q_entry_rdy_l2a),
             .din(q_s1_itag_ary),
             .dout(q_instr_s1_itag)
             );
   assign rv1_instr_s1_itag = q_instr_s1_itag;

   //-------------------------------------------------------------------------------------------------------
   generate
        begin : s2_itag_extnd
	   for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
             begin : s2_itag_extnda
		assign q_s2_itag_ary[n*`ITAG_SIZE_ENC:(n+1)*`ITAG_SIZE_ENC-1] = q_s2_itag_q[n];

             end
	end
   endgenerate

   rv_primux #(.q_dat_width_g(`ITAG_SIZE_ENC),  .q_num_entries_g(q_num_entries_g-4))
   q_s2_itag_mux(
             .cond(q_entry_rdy_l2a),
             .din(q_s2_itag_ary),
             .dout(q_instr_s2_itag)
             );
   assign rv1_instr_s2_itag = q_instr_s2_itag;

   //-------------------------------------------------------------------------------------------------------
   generate
        begin : s3_itag_extnd
	   for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
             begin : s3_itag_extnda
		assign q_s3_itag_ary[n*`ITAG_SIZE_ENC:(n+1)*`ITAG_SIZE_ENC-1] = q_s3_itag_q[n];

             end
	end
   endgenerate

   rv_primux #(.q_dat_width_g(`ITAG_SIZE_ENC),  .q_num_entries_g(q_num_entries_g-4))
   q_s3_itag_mux(
             .cond(q_entry_rdy_l2a),
             .din(q_s3_itag_ary),
             .dout(q_instr_s3_itag)
             );
   assign rv1_instr_s3_itag = q_instr_s3_itag;

   //-------------------------------------------------------------------------------------------------------
   generate
        begin : ilat_extnd
	   for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
             begin : ilat_extnda
		assign q_ilat_ary[n*q_ilat_width_g:(n+1)*q_ilat_width_g-1] = q_ilat_q[n];

             end
	end
   endgenerate

   rv_primux #(.q_dat_width_g(q_ilat_width_g),  .q_num_entries_g(q_num_entries_g-4))
   q_ilat_mux(
             .cond(q_entry_rdy_l2c),
             .din(q_ilat_ary),
             .dout(rv1_instr_ilat)
             );

   //-------------------------------------------------------------------------------------------------------
   generate
        begin : ba_extnd
	   for (n = 4; n <= (q_num_entries_g - 1); n = n + 1)
             begin : ba_extnda
		assign q_barf_addr_ary[n*q_barf_enc_g:(n+1)*q_barf_enc_g-1] = q_barf_addr_q[n];

             end
	end
   endgenerate
   generate
        begin : ba_extndc
	   for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
             begin : ba_extndac
		assign q_barf_clr_addr_ary[n*q_barf_enc_g:(n+1)*q_barf_enc_g-1] = q_barf_addr_q[n];

             end
	end
   endgenerate

   rv_primux #(.q_dat_width_g(q_barf_enc_g),  .q_num_entries_g(q_num_entries_g-4))
   q_barf_addr_mux(
             .cond(q_entry_rdy_l2c),
             .din(q_barf_addr_ary),
             .dout(ex0_barf_addr_d)
             );

   rv_primux #(.q_dat_width_g(q_barf_enc_g), .q_num_entries_g(q_num_entries_g))
   barf_clr_addr_mux(
                .cond(q_credit_rdy),
		.din(q_barf_clr_addr_ary),
                .dout(barf_clr_addr)
                );


   //-------------------------------------------------------------------------------------------------------
   // Hold Logic  (ordered / cordered)
   //-------------------------------------------------------------------------------------------------------

   assign q_hold_all_d = q_hold_all;
   assign q_ord_completed = q_ord_complete | (flush & q_hold_ord_q);
   assign q_hold_ord_set = q_tid_q[q_num_entries_g - 1] & {`THREADS{q_ord_q[q_num_entries_g - 1] & q_entry_select[q_num_entries_g - 1]}};		//and not q_cord_q(q_num_entries_g-1); --cord

   assign q_hold_ord_d = (q_hold_ord_set | (q_hold_ord_q & (~q_hold_ord_set))) & (~q_ord_completed) & (~flush);

   // The ordered TID, needed for itag release
   assign q_ord_tid = q_hold_ord_q;


   generate
      if (`THREADS == 1)
        begin : q_cp_next_gen1
           assign q_cp_next_itag = cp_next_itag;
        end
   endgenerate
   generate
      if (`THREADS == 2)
        begin : q_cp_next_gen2
           assign q_cp_next_itag = ({`ITAG_SIZE_ENC{q_tid_q[q_num_entries_g - 1][0]}} & cp_next_itag[0:`ITAG_SIZE_ENC-1]) |
				   ({`ITAG_SIZE_ENC{q_tid_q[q_num_entries_g - 1][1]}} & cp_next_itag[`ITAG_SIZE_ENC:`THREADS*`ITAG_SIZE_ENC-1]);
        end
   endgenerate

   // Completion Ordered logic, optimize out if not used == todo MAKE THREADED
   generate
      if (q_cord_g == 1)
        begin : q_cord1_g_gen
           assign q_cord_match = (q_cp_next_itag == q_itag_q[q_num_entries_g - 1]) & q_ev_q[q_num_entries_g - 1];

	   assign q_cord_d[0] = (q_entry_load_i1[0] & rv0_instr_i1_cord ) |
				(q_entry_load_i0[0] & rv0_instr_i0_cord ) |
				(q_entry_hold[0] & q_cord_nxt[0]);
	   begin : xhdl5
              for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
		begin : q_cord_gen
		   assign q_cord_d[n] = (q_entry_load_i1[n] & rv0_instr_i1_cord ) |
					(q_entry_load_i0[n] & rv0_instr_i0_cord ) |
					(q_entry_shift[n] & q_cord_nxt[n - 1] ) |
					(q_entry_hold[n] &  q_cord_nxt[n]) ;

		end
	   end
	   begin : xhdl6
              for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
		begin : q_cord_nxt_gen
		   assign q_cord_set[n] = q_lq_itag_match[n] & lq_rv_itag1_cord_q;
		   assign q_cord_nxt[n] = q_cord_q[n] | q_cord_set[n];

		   tri_rlmlatch_p #(.INIT(0))
		   q_cord_q_reg(
				.vd(vdd),
				.gd(gnd),
				.nclk(nclk),
				.act(q_cord_act[n]),
				.thold_b(func_sl_thold_0_b),
				.sg(sg_0),
				.force_t(force_t),
				.delay_lclkr(delay_lclkr),
				.mpw1_b(mpw1_b),
				.mpw2_b(mpw2_b),
				.d_mode(d_mode),
				.scin(siv[q_cord_offset + n]),
				.scout(sov[q_cord_offset + n]),
				.din(q_cord_d[n]),
				.dout(q_cord_q[n])
                           );

		end
	   end

        end
   endgenerate
   generate
      if (q_cord_g == 0)
        begin : q_cord0_g_gen
           assign q_cord_match = 1'b0;
	   begin : xhdl6b
              for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
		begin : q_cord0_nxt_gen
		   assign q_cord_d[n]=1'b0;
		   assign q_cord_q[n]=1'b0;
		   assign q_cord_nxt[n]=1'b0;
		   assign sov[q_cord_offset + n] = siv[q_cord_offset + n];
		end
	   end

        end
   endgenerate

   //-------------------------------------------------------------------------------------------------------
   // generation of the ordered bit that is present in each reservation station entry
   //-------------------------------------------------------------------------------------------------------
   generate
      if (q_ord_g == 1)
        begin : q_ord1_g_gen

	   assign q_ord_d[0] = (q_entry_load_i1[0] & rv0_instr_i1_ord ) |
            		       (q_entry_load_i0[0] & rv0_instr_i0_ord ) |
              		       (q_entry_hold[0] & q_ord_nxt[0]);
      	   begin : xhdl3
              for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
              	begin : q_ord_gen
              	   assign q_ord_d[n] = (q_entry_load_i1[n] & rv0_instr_i1_ord ) |
              			       (q_entry_load_i0[n] & rv0_instr_i0_ord ) |
              			       (q_entry_shift[n] & q_ord_nxt[n - 1] ) |
              			       (q_entry_hold[n] &  q_ord_nxt[n]) ;

              	end
           end

           begin : xhdl4
              for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
		begin : q_ord_nxt_gen
		   assign q_ord_nxt[n] = q_ord_q[n];

		   tri_rlmlatch_p #(.INIT(0))
              	   q_ord_q_reg(
                               .vd(vdd),
                               .gd(gnd),
                               .nclk(nclk),
                               .act(q_dat_act[n]),
                               .thold_b(func_sl_thold_0_b),
                               .sg(sg_0),
                               .force_t(force_t),
                               .delay_lclkr(delay_lclkr),
                               .mpw1_b(mpw1_b),
                               .mpw2_b(mpw2_b),
                               .d_mode(d_mode),
                               .scin(siv[q_ord_offset + n]),
                               .scout(sov[q_ord_offset + n]),
                               .din(q_ord_d[n]),
              		       .dout(q_ord_q[n])
                               );

		end
	   end
        end
   endgenerate
   generate
      if (q_ord_g == 0)
        begin : q_ord0_g_gen
	   //generate
	   begin : xhdl3b
	      for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
		begin : q_ord0_gen

		   assign q_ord_d[n]=1'b0;
		   assign q_ord_q[n]=1'b0;
		   assign q_ord_nxt[n]=1'b0;

		   assign sov[q_ord_offset + n] = siv[q_ord_offset + n];

		end
	   end
	   //endgenerate

        end
   endgenerate

   //-------------------------------------------------------------------------------------------------------
   // LQ Only. This logic is only needed in the LQ RVS
   //-------------------------------------------------------------------------------------------------------
   generate
      if (q_lq_g)
        begin : q_lq1_g_gen

	   assign no_lq_unused = 1'b0;

	   //-------------------------------------------------------------------------------------------------------
	   // generation of the speculative bit for this entry's cmd
	   //-------------------------------------------------------------------------------------------------------

	   assign q_spec_d[0] = (q_entry_load_i1[0] & rv0_instr_i1_spec ) |
				(q_entry_load_i0[0] & rv0_instr_i0_spec ) |
				(q_entry_hold[0] & q_spec_nxt[0]);
	   begin : xhdl14
              for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
		begin : q_spec_gen
		   assign q_spec_d[n] = (q_entry_load_i1[n] & rv0_instr_i1_spec ) |
					(q_entry_load_i0[n] & rv0_instr_i0_spec ) |
					(q_entry_shift[n]  & q_spec_nxt[n - 1] ) |
					(q_entry_hold[n] & q_spec_nxt[n] );
		end
	   end
	   begin : xhdl15
              for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
		begin : q_spec_nxt_gen
		   assign q_spec_clr[n] = q_lq_itag_match[n] & (~q_e_miss_nxt[n]) & (~lq_rv_itag1_restart_q);
		   assign q_spec_nxt[n] = q_spec_q[n] & (~q_spec_clr[n]);

		   tri_rlmlatch_p #(.INIT(0))
		   q_spec_q_reg(
				.vd(vdd),
				.gd(gnd),
				.nclk(nclk),
				.act(tiup),
				.thold_b(func_sl_thold_0_b),
				.sg(sg_0),
				.force_t(force_t),
				.delay_lclkr(delay_lclkr),
				.mpw1_b(mpw1_b),
				.mpw2_b(mpw2_b),
				.d_mode(d_mode),
				.scin(siv[q_spec_offset + n]),
				.scout(sov[q_spec_offset + n]),
				.din(q_spec_d[n]),
				.dout(q_spec_q[n])
				);
		end
	   end

	   assign rv1_instr_spec = |(q_entry_rdy_pri & q_spec_q[4:q_num_entries_g-1]);

	   //-------------------------------------------------------------------------------------------------------
	   // generation of erat miss logic
	   //-------------------------------------------------------------------------------------------------------

	   assign q_e_miss_d[0] =   q_e_miss_nxt[0] & q_entry_hold[0];
	   begin : xhdl26
              for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
		begin : q_e_miss_gen

		   assign q_e_miss_d[n] = (q_e_miss_nxt[n - 1] & q_entry_shift[n]) |
					  (q_e_miss_nxt[n]     & q_entry_hold[n]);
		end
	   end
	   begin : xhdl27
              for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
		begin : q_e_miss_nxt_gen
		   assign q_e_miss_set[n] = q_lq_itag_match[n] & lq_rv_itag1_hold_q;
		   assign q_e_miss_clr[n] = |(lq_rv_clr_hold_q & q_tid_q[n]);
		   assign q_e_miss_nxt[n] = (q_e_miss_q[n] | q_e_miss_set[n]) & (~q_e_miss_clr[n]);

		   tri_rlmlatch_p #(.INIT(0)) q_e_miss_q_reg(
                                                             .vd(vdd),
                                                             .gd(gnd),
                                                             .nclk(nclk),
                                                             .act(q_e_miss_act[n]),
                                                             .thold_b(func_sl_thold_0_b),
                                                             .sg(sg_0),
                                                             .force_t(force_t),
                                                             .delay_lclkr(delay_lclkr),
                                                             .mpw1_b(mpw1_b),
                                                             .mpw2_b(mpw2_b),
                                                             .d_mode(d_mode),
                                                             .scin(siv[q_e_miss_offset + n]),
                                                             .scout(sov[q_e_miss_offset + n]),
                                                             .din(q_e_miss_d[n]),
                                                             .dout(q_e_miss_q[n])
                                                             );

		end
	   end

	   tri_rlmlatch_p #(.INIT(0))
	   lq_rv_itag1_restart_reg(
				   .vd(vdd),
				   .gd(gnd),
				   .nclk(nclk),
				   .act(tiup),
				   .thold_b(func_sl_thold_0_b),
				   .sg(sg_0),
				   .force_t(force_t),
				   .delay_lclkr(delay_lclkr),
				   .mpw1_b(mpw1_b),
				   .mpw2_b(mpw2_b),
				   .d_mode(d_mode),
				   .scin(siv[lq_rv_itag1_restart_offset]),
				   .scout(sov[lq_rv_itag1_restart_offset]),
				   .din(lq_rv_itag1_restart),
				   .dout(lq_rv_itag1_restart_q)
                           );


                 tri_rlmlatch_p #(.INIT(0))
                 lq_rv_itag1_hold_reg(
                        .vd(vdd),
                        .gd(gnd),
                        .nclk(nclk),
                        .act(tiup),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .force_t(force_t),
                        .delay_lclkr(delay_lclkr),
                        .mpw1_b(mpw1_b),
                        .mpw2_b(mpw2_b),
                        .d_mode(d_mode),
                        .scin(siv[lq_rv_itag1_hold_offset]),
                        .scout(sov[lq_rv_itag1_hold_offset]),
                        .din(lq_rv_itag1_hold),
                        .dout(lq_rv_itag1_hold_q)
                        );


                 tri_rlmlatch_p #(.INIT(0))
                 lq_rv_itag1_cord_reg(
                        .vd(vdd),
                        .gd(gnd),
                        .nclk(nclk),
                        .act(tiup),
                        .thold_b(func_sl_thold_0_b),
                        .sg(sg_0),
                        .force_t(force_t),
                        .delay_lclkr(delay_lclkr),
                        .mpw1_b(mpw1_b),
                        .mpw2_b(mpw2_b),
                        .d_mode(d_mode),
                        .scin(siv[lq_rv_itag1_cord_offset]),
                        .scout(sov[lq_rv_itag1_cord_offset]),
                        .din(lq_rv_itag1_cord),
                        .dout(lq_rv_itag1_cord_q)
                        );


                 tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
                 lq_rv_clr_hold_reg(
                      .vd(vdd),
                      .gd(gnd),
                      .nclk(nclk),
                      .act(tiup),
                      .thold_b(func_sl_thold_0_b),
                      .sg(sg_0),
                      .force_t(force_t),
                      .delay_lclkr(delay_lclkr),
                      .mpw1_b(mpw1_b),
                      .mpw2_b(mpw2_b),
                      .d_mode(d_mode),
                      .scin(siv[lq_rv_clr_hold_offset:lq_rv_clr_hold_offset + `THREADS - 1]),
                      .scout(sov[lq_rv_clr_hold_offset:lq_rv_clr_hold_offset + `THREADS - 1]),
                      .din(lq_rv_clr_hold),
                      .dout(lq_rv_clr_hold_q)
                      );


	end
   endgenerate
   generate
      if (!(q_lq_g))
        begin : q_lq0_g_gen

	   assign rv1_instr_spec = 1'b0;
	   assign q_spec_clr = {q_num_entries_g{1'b0}};
	   assign q_spec_nxt = {q_num_entries_g{1'b0}};
	   assign q_spec_d = {q_num_entries_g{1'b0}};
	   assign q_spec_q = {q_num_entries_g{1'b0}};
	   assign sov[q_spec_offset:q_spec_offset+q_num_entries_g-1] = siv[q_spec_offset:q_spec_offset+q_num_entries_g-1];

	   assign q_e_miss_set = {q_num_entries_g{1'b0}};
	   assign q_e_miss_clr = {q_num_entries_g{1'b0}};
	   assign q_e_miss_nxt = {q_num_entries_g{1'b0}};
	   assign q_e_miss_d = {q_num_entries_g{1'b0}};
	   assign q_e_miss_q = {q_num_entries_g{1'b0}};
	   assign sov[q_e_miss_offset:q_e_miss_offset+q_num_entries_g-1] = siv[q_e_miss_offset:q_e_miss_offset+q_num_entries_g-1];

	   assign no_lq_unused = |q_spec_clr | |q_spec_nxt | |q_spec_d | |q_spec_q |
				 |q_e_miss_d | |q_e_miss_q[0:3] | |q_e_miss_set | |q_e_miss_clr | lq_rv_itag1_hold_q | |q_e_miss_act |
				 rv0_instr_i0_spec | rv0_instr_i1_spec | lq_rv_itag1_restart | lq_rv_itag1_hold | lq_rv_itag1_cord | |lq_rv_clr_hold;


	   assign lq_rv_itag1_restart_q = 1'b0;
	   assign lq_rv_itag1_hold_q = 1'b0;
	   assign lq_rv_itag1_cord_q = 1'b0;
	   assign lq_rv_clr_hold_q = {`THREADS{1'b0}};

	   assign sov[lq_rv_itag1_restart_offset]= siv[lq_rv_itag1_restart_offset];
	   assign sov[lq_rv_itag1_hold_offset] = siv[lq_rv_itag1_hold_offset];
	   assign sov[lq_rv_itag1_cord_offset] = siv[lq_rv_itag1_cord_offset];
     	   assign sov[lq_rv_clr_hold_offset:lq_rv_clr_hold_offset + `THREADS - 1] = siv[lq_rv_clr_hold_offset:lq_rv_clr_hold_offset + `THREADS - 1];


	end
   endgenerate


   //-------------------------------------------------------------------------------------------------------
   // Brick.  Kills all valids, late gate - optimize out if not used
   //-------------------------------------------------------------------------------------------------------
   generate
      if (q_brick_g == 1'b1)
        begin : q_brick1_g_gen


	   assign q_hold_brick_cnt_d = ((q_instr_is_brick == 1'b1)) ? q_instr_brick :
				       ((q_hold_brick_q == 1'b0)) ? q_hold_brick_cnt_q :
				       q_hold_brick_cnt_q - 3'b001;
	   assign q_hold_brick_d = ((q_instr_is_brick == 1'b1)) ? 1'b1 :
				   ((q_hold_brick_cnt_q == 3'b000)) ? 1'b0 :
				   q_hold_brick_q;

           assign q_hold_brick = q_hold_brick_q;
	   assign brick_unused = 1'b0;
	   assign brickn_unused = {q_num_entries_g{1'b0}};


	   //-------------------------------------------------------------------------------------------------------
	   // generation of the brick info for this entry's cmd
	   //-------------------------------------------------------------------------------------------------------

	   assign q_is_brick_d[0] = (q_entry_load_i1[0] & rv0_instr_i1_is_brick ) |
				    (q_entry_load_i0[0] & rv0_instr_i0_is_brick ) |
				    (q_entry_hold[0] & q_is_brick_q[0]);
	   begin : xhdl8
              for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
		begin : q_is_brick_gen
		   assign q_is_brick_d[n] = (q_entry_load_i1[n] & rv0_instr_i1_is_brick ) |
					    (q_entry_load_i0[n] & rv0_instr_i0_is_brick ) |
					    (q_entry_shift[n] & q_is_brick_q[n - 1] ) |
					    (q_entry_hold[n] & q_is_brick_q[n]);

		end
	   end
	   assign q_brick_d[0] = ({3{q_entry_load_i1[0]}} & rv0_instr_i1_brick ) |
				 ({3{q_entry_load_i0[0]}} & rv0_instr_i0_brick ) |
				 ({3{q_entry_hold[0]}} & q_brick_q[0]);
	   begin : xhdl9
              for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
		begin : q_brick_gen
		   assign q_brick_d[n] = ({3{q_entry_load_i1[n]}} & rv0_instr_i1_brick ) |
					 ({3{q_entry_load_i0[n]}} & rv0_instr_i0_brick ) |
					 ({3{q_entry_shift[n]}} & q_brick_q[n - 1] ) |
					 ({3{q_entry_hold[n]}} & q_brick_q[n]);
		end
	   end

              	      tri_rlmlatch_p #(.INIT(0))
                 q_hold_brick_q_reg(
                      .vd(vdd),
                      .gd(gnd),
                      .nclk(nclk),
                      .act(tiup),
                      .thold_b(func_sl_thold_0_b),
                      .sg(sg_0),
                      .force_t(force_t),
                      .delay_lclkr(delay_lclkr),
                      .mpw1_b(mpw1_b),
                      .mpw2_b(mpw2_b),
                      .d_mode(d_mode),
                      .scin(siv[q_hold_brick_offset]),
                      .scout(sov[q_hold_brick_offset]),
                      .din(q_hold_brick_d),
                      .dout(q_hold_brick_q)
                      );


                 tri_rlmreg_p #(.WIDTH(3), .INIT(0))
                 q_hold_brick_cnt_q_reg(
                          .vd(vdd),
                          .gd(gnd),
                          .nclk(nclk),
                          .act(tiup),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .force_t(force_t),
                          .delay_lclkr(delay_lclkr),
                          .mpw1_b(mpw1_b),
                          .mpw2_b(mpw2_b),
                          .d_mode(d_mode),
                          .scin(siv[q_hold_brick_cnt_offset:q_hold_brick_cnt_offset + 3 - 1]),
                          .scout(sov[q_hold_brick_cnt_offset:q_hold_brick_cnt_offset + 3 - 1]),
                          .din(q_hold_brick_cnt_d),
                          .dout(q_hold_brick_cnt_q)
                          );

	   begin : xhdl9b
              for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
		begin : q_bricklat_gen
              		   tri_rlmlatch_p #(.INIT(0))
              	   q_is_brick_q_reg(
                            .vd(vdd),
                            .gd(gnd),
                            .nclk(nclk),
                            .act(q_dat_act[n]),
                            .thold_b(func_sl_thold_0_b),
                            .sg(sg_0),
                            .force_t(force_t),
                            .delay_lclkr(delay_lclkr),
                            .mpw1_b(mpw1_b),
                            .mpw2_b(mpw2_b),
                            .d_mode(d_mode),
                            .scin(siv[q_is_brick_offset + n]),
                            .scout(sov[q_is_brick_offset + n]),
                            .din(q_is_brick_d[n]),
                            .dout(q_is_brick_q[n])
                            );

                         tri_rlmreg_p #(.WIDTH(3), .INIT(0))
              	   q_brick_q_reg(
                         .vd(vdd),
                         .gd(gnd),
                         .nclk(nclk),
                         .act(tiup),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .force_t(force_t),
                         .delay_lclkr(delay_lclkr),
                         .mpw1_b(mpw1_b),
                         .mpw2_b(mpw2_b),
                         .d_mode(d_mode),
                         .scin(siv[q_brick_offset + 3 * n:q_brick_offset + 3 * (n + 1) - 1]),
                         .scout(sov[q_brick_offset + 3 * n:q_brick_offset + 3 * (n + 1) - 1]),
                         .din(q_brick_d[n]),
                         .dout(q_brick_q[n])
                         );
		end // block: q_bricklat_gen
	   end // block: xhdl9b
	end // block: q_brick1_g_gen
   endgenerate

   generate
      if (q_brick_g == 1'b0)
        begin : q_brick0_g_gen
           assign q_hold_brick = 1'b0;
	   assign sov[q_hold_brick_offset] = siv[q_hold_brick_offset];
	   assign sov[q_hold_brick_cnt_offset:q_hold_brick_cnt_offset + 3 - 1] = siv[q_hold_brick_cnt_offset:q_hold_brick_cnt_offset + 3 - 1];

	   assign q_hold_brick_cnt_d = 3'b0;
	   assign q_hold_brick_cnt_q = 3'b0;
	   assign q_hold_brick_d = 1'b0;
	   assign q_hold_brick_q = 1'b0;

	   assign brick_unused = q_hold_brick | |q_hold_brick_cnt_d | |q_hold_brick_cnt_q | q_hold_brick_d | q_hold_brick_q | q_instr_is_brick |
				 rv0_instr_i0_is_brick | |rv0_instr_i0_brick | rv0_instr_i1_is_brick | |rv0_instr_i1_brick | |q_instr_brick;

	   begin : xhdl9b
              for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
		begin : q_brick_gen0

		   assign q_brick_d[n] = 3'b0;
		   assign q_brick_q[n] = 3'b0;
		   assign q_is_brick_d[n] = 1'b0;
		   assign q_is_brick_q[n] = 1'b0;
		   assign sov[q_is_brick_offset + n] = siv[q_is_brick_offset + n];
		   assign sov[q_brick_offset + 3 * n:q_brick_offset + 3 * (n + 1) - 1]=siv[q_brick_offset + 3 * n:q_brick_offset + 3 * (n + 1) - 1];
		   assign brickn_unused[n] = |q_brick_d[n] | |q_brick_q[n] | q_is_brick_d[n] | q_is_brick_q[n] ;


		end
	   end

        end
   endgenerate

   //-------------------------------------------------------------------------------------------------------
   // Generate Q load and shift signals.
   //   q_entry_shift is gated when either q_entry_load or q_entry_load2 is active to create one hot
   //   mux controls.  q_entry_or_tree is simply an or tree starting at the first ready entry from
   //   the bottom of the q.
   //-------------------------------------------------------------------------------------------------------
   assign q_ev_b = (~q_ev_q);

   generate
      begin : xhdl32
         for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_or_gen
              assign q_entry_or_tree[n] = |(q_ev_b[n:q_num_entries_g - 1]);
           end
      end
   endgenerate

   generate
      begin : xhdl33
         for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_and_gen
              assign q_entry_and_tree[n] = &(q_ev_b[0:n]);
           end
      end
   endgenerate

   generate
      begin : xhdl34
         for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_entry_shift_gen
              assign q_entry_shift[n] = q_entry_or_tree[n] & (~(q_entry_load[n] | q_entry_load2[n]));
           end
      end
   endgenerate

   assign q_entry_load[0] = (rv0_load1 & (~q_entry_or_tree[0]) & q_entry_and_tree[0] & (~q_entry_and_tree[1])) |
			    (rv0_load1 & q_entry_or_tree[0] & (~q_entry_and_tree[0]) & 1'b1) |
			    (rv0_load1 & q_entry_or_tree[0] & q_entry_and_tree[0] & (~q_entry_or_tree[1]));


   generate
      begin : xhdl35
         for (n = 1; n <= (q_num_entries_g - 2); n = n + 1)
           begin : q_load_gen
              //  special case
              assign q_entry_load[n] = (rv0_load1 & (~q_entry_or_tree[n]) & q_entry_and_tree[n] & (~q_entry_and_tree[n + 1])) |
				       (rv0_load1 & q_entry_or_tree[n] & (~q_entry_and_tree[n]) & q_entry_and_tree[n - 1]) |
				       (rv0_load1 & q_entry_or_tree[n] & q_entry_and_tree[n] & (~q_entry_or_tree[n + 1]));
           end
      end
   endgenerate


   assign q_entry_load[q_num_entries_g - 1] = (rv0_load1 & (~q_entry_or_tree[q_num_entries_g - 1]) & q_entry_and_tree[q_num_entries_g - 1] & (~1'b0)) |
					      (rv0_load1 & q_entry_or_tree[q_num_entries_g - 1] & (~1'b0) & q_entry_and_tree[q_num_entries_g - 2]);

   generate
      begin : xhdl36
         for (n = 0; n <= (q_num_entries_g - 2); n = n + 1)
           begin : q_entry_load2_gen
              assign q_entry_load2[n] = rv0_load2 & q_entry_load[n + 1];
           end
      end
   endgenerate
   assign q_entry_load2[q_num_entries_g - 1] = 1'b0;

   generate
      begin : xhdl37
         for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_hold_gen
              assign q_entry_hold[n] = (~(q_entry_load[n] | q_entry_load2[n] | q_entry_shift[n]));

              assign q_entry_load_i0[n] = (q_entry_load[n] & (~rv0_load1_instr_select));
              assign q_entry_load_i1[n] = q_entry_load2[n] | (q_entry_load[n] & rv0_load1_instr_select);
           end
      end
   endgenerate

   //-------------------------------------------------------------------------------------------------------
   // generation of Clock gating
   //-------------------------------------------------------------------------------------------------------

   assign q_dat_act[0] = (rv0_instr_i0_rte | rv0_instr_i1_rte);

   assign q_e_miss_act[0] = (rv0_instr_i0_rte | rv0_instr_i1_rte) |
			    |(lq_rv_itag1_rst_vld_q | lq_rv_clr_hold_q);		//itag1 clrhold
   assign q_cord_act[0] = (rv0_instr_i0_rte | rv0_instr_i1_rte) | |(lq_rv_itag1_rst_vld_q);

   generate
      begin : xhdl38
         for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_act_gen
              assign q_dat_act[n] = ((rv0_instr_i0_rte | rv0_instr_i1_rte) | q_ev_q[n - 1]);

              assign q_e_miss_act[n] = ((rv0_instr_i0_rte | rv0_instr_i1_rte) | q_ev_q[n - 1]) |
				       |(lq_rv_itag1_rst_vld_q |
					 lq_rv_clr_hold_q);		//itag1 clrhold
              assign q_cord_act[n] = ((rv0_instr_i0_rte | rv0_instr_i1_rte) | q_ev_q[n - 1]) | |(lq_rv_itag1_rst_vld_q);
           end
      end
   endgenerate

   //-------------------------------------------------------------------------------------------------------
   // generation of Credit Logic, with spec trickle
   //-------------------------------------------------------------------------------------------------------

   assign q_credit_d[0] = (q_credit_nxt[0] & q_entry_hold[0]) & ~(&(flush));

   generate
      begin : xhdl39
         for (n = 1; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_credit_gen
              assign q_credit_d[n] =
				     ((q_credit_nxt[n - 1] & q_entry_shift[n]) |
				      (q_credit_nxt[n] & q_entry_hold[n])) & ~(&(flush));
           end
      end
   endgenerate

   generate
      begin : xhdl40
         for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_credit_nxt_gen


	      assign q_credit_ex3[n] = (ex3_instr_issued[n] & ~xx_rv_ex3_abort & ~q_spec_q[n]) ;
	      assign q_credit_ex6[n] = (q_lq_itag_match[n] & q_spec_q[n] & ~lq_rv_itag1_restart_q) ;
	      assign q_credit_flush[n] = q_flushed_q[n];

	      assign q_credit_set[n] = q_ev_q[n] & (q_credit_ex3[n] | q_credit_ex6[n] | q_credit_flush[n]);
	      assign q_credit_clr[n] = q_credit_take[n] | (&(flush));

              assign q_credit_rdy[n] = ( q_credit_q[n] | q_credit_set[n]) ;

	      assign q_credit_nxt[n] = ( q_credit_q[n] | q_credit_set[n]) & ~q_credit_clr[n];


           end
      end
   endgenerate



   rv_rpri #(.size(q_num_entries_g))
   q_credit_pri(
                .cond(q_credit_rdy),
                .pri(q_credit_take)
                );

   generate
        begin : tid_extndf
	   for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
             begin : tid_extndaf
		assign q_tid_full_ary[n*`THREADS:(n+1)*`THREADS-1] = q_tid_q[n];

             end
	end
   endgenerate

   rv_prisel #(.q_dat_width_g(`THREADS), .q_num_entries_g(q_num_entries_g))
   q_credit_mux(
                .cond(q_credit_rdy),
		.din(q_tid_full_ary),
                .dout(ex1_credit_free_d)
                );

   generate
      begin : xhdl41
         for (t = 0; t <= (`THREADS - 1); t = t + 1)
           begin : ex1_credit_gen
              assign ex1_credit_free[t] = ex1_credit_free_q[t] & ~(&(flush2));
           end
      end
   endgenerate

   //-------------------------------------------------------------------------------------------------------
   // RVS Empty
   //-------------------------------------------------------------------------------------------------------

   generate
      begin : xhdl43
         for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_entry_tvld_gen
              assign q_entry_tvld[n] = {`THREADS{q_ev_q[n]}} & q_tid_q[n];

              begin : xhdl42
                 for (t = 0; t <= (`THREADS - 1); t = t + 1)
                   begin : q_tvld_rev_gen
                      assign q_entry_tvld_rev[t][n] = q_entry_tvld[n][t];
                   end
              end
           end
      end
   endgenerate

   generate
      begin : xhdl44
         for (t = 0; t <= (`THREADS - 1); t = t + 1)
           begin : rvs_empty_gen
              assign rvs_empty_d[t] = (~(|(q_entry_tvld_rev[t]) |
					 rv0_instr_i0_vld[t] | rv0_instr_i0_vld[t] ));
           end
      end
   endgenerate

   assign rvs_empty = rvs_empty_q;

   //-------------------------------------------------------------------------------------------------------
   // Abort
   //-------------------------------------------------------------------------------------------------------

   assign xx_rv_ex2_abort = xx_rv_ex2_s1_abort | xx_rv_ex2_s2_abort | xx_rv_ex2_s3_abort ;

   assign issued_vld_d[0] = q_instr_vld & ~flush;
   assign issued_vld_d[1] = issued_vld_q[0] & ~flush;
   assign issued_vld_d[2] = issued_vld_q[1] & ~flush;
   assign issued_vld_d[3] = issued_vld_q[2] & ~flush;
   assign issued_vld_d[4] = issued_vld_q[3] & ~flush;

   // Is the entry being shifted?  We only shift down, ignore last shift

   generate
      begin : xiaenc
	 // Encode the issued entry address to save latches
   	 if(q_num_entries_g==12)
	   begin : ia12
	      assign issued_addr[0]= q_entry_select[ 8]|q_entry_select[ 9]|q_entry_select[10]|q_entry_select[11];
	      assign issued_addr[1]= q_entry_select[ 4]|q_entry_select[ 5]|q_entry_select[ 6]|q_entry_select[ 7];
	      assign issued_addr[2]=                                       q_entry_select[ 6]|q_entry_select[ 7]|
				     q_entry_select[10]|q_entry_select[11];
	      assign issued_addr[3]=                                       q_entry_select[ 5]|q_entry_select[ 7]|
				     q_entry_select[ 9]|q_entry_select[11];
	   end
	 else
	   begin : ia16
	      assign issued_addr[0]= q_entry_select[ 8]|q_entry_select[ 9]|q_entry_select[10]|q_entry_select[11]|
				     q_entry_select[12]|q_entry_select[13]|q_entry_select[14]|q_entry_select[15];
	      assign issued_addr[1]= q_entry_select[ 4]|q_entry_select[ 5]|q_entry_select[ 6]|q_entry_select[ 7]|
				     q_entry_select[12]|q_entry_select[13]|q_entry_select[14]|q_entry_select[15];
	      assign issued_addr[2]=                                       q_entry_select[ 6]|q_entry_select[ 7]|
				     q_entry_select[10]|q_entry_select[11]|q_entry_select[14]|q_entry_select[15];
	      assign issued_addr[3]=                                       q_entry_select[ 5]|q_entry_select[ 7]|
				     q_entry_select[ 9]|q_entry_select[11]|q_entry_select[13]|q_entry_select[15];
	   end

	 // Is the entry being shifted?  We only shift down, ignore last shift
	 assign issued_addr_d[0] = (|(q_entry_select[4:q_num_entries_g-2] & q_entry_shift[5:q_num_entries_g-1])) ? (issued_addr + 4'b0001) : issued_addr;

	 for (i = 0; i <= q_num_entries_g-2; i = i + 1)
	   begin : ias
	      wire [0:3] idi = i;
	      assign issued_shift[0][i] = (issued_addr_q[0] == idi) & q_entry_shift[i+1];
	      assign issued_shift[1][i] = (issued_addr_q[1] == idi) & q_entry_shift[i+1];
	      assign issued_shift[2][i] = (issued_addr_q[2] == idi) & q_entry_shift[i+1];
	      assign issued_shift[3][i] = (issued_addr_q[3] == idi) & q_entry_shift[i+1];

	   end
	 //last entry never shifted
	 assign issued_shift[0][q_num_entries_g-1] = 1'b0;
	 assign issued_shift[1][q_num_entries_g-1] = 1'b0;
	 assign issued_shift[2][q_num_entries_g-1] = 1'b0;
	 assign issued_shift[3][q_num_entries_g-1] = 1'b0;

	 assign issued_addr_d[1] = (|issued_shift[0]) ? (issued_addr_q[0] + 4'b0001) : issued_addr_q[0];
	 assign issued_addr_d[2] = (|issued_shift[1]) ? (issued_addr_q[1] + 4'b0001) : issued_addr_q[1];
	 assign issued_addr_d[3] = (|issued_shift[2]) ? (issued_addr_q[2] + 4'b0001) : issued_addr_q[2];
	 assign issued_addr_d[4] = (|issued_shift[3]) ? (issued_addr_q[3] + 4'b0001) : issued_addr_q[3];


	 for (n = 0; n <= q_num_entries_g-1; n = n + 1)
	   begin : iasa
	      wire [0:3] ent = n;

	      assign ex3_instr_issued[n] = (issued_addr_q[3] == ent) & |issued_vld_q[3];
	      assign ex4_instr_issued[n] = (issued_addr_q[4] == ent) & |issued_vld_q[4];

	   end // block: iasa

      end
   endgenerate

   //Delay clear for a cycle to line up better with abort reset for perf
   assign ex4_instr_aborted = {q_num_entries_g{( xx_rv_ex4_abort) }} & ex4_instr_issued;




   //-------------------------------------------------------------------------------------------------------
   // generation of itag match logic
   //-------------------------------------------------------------------------------------------------------

   assign xx_rv_rel_vld_d[0] = fx0_rv_itag_vld;
   assign xx_rv_rel_vld_d[1] = fx1_rv_itag_vld;
   assign xx_rv_rel_vld_d[2] = lq_rv_itag0_vld;
   assign xx_rv_rel_vld_d[3] = lq_rv_itag1_vld;
   assign xx_rv_rel_vld_d[4] = lq_rv_itag2_vld;
   assign xx_rv_rel_vld_d[5] = axu0_rv_itag_vld;
   assign xx_rv_rel_vld_d[6] = axu1_rv_itag_vld;

   assign xx_rv_abort_d[0] = fx0_rv_itag_abort;
   assign xx_rv_abort_d[1] = fx1_rv_itag_abort;
   assign xx_rv_abort_d[2] = lq_rv_itag0_abort;
   assign xx_rv_abort_d[3] = lq_rv_itag1_abort;
   assign xx_rv_abort_d[4] = 1'b0;
   assign xx_rv_abort_d[5] = axu0_rv_itag_abort;
   assign xx_rv_abort_d[6] = axu1_rv_itag_abort;

   assign xx_rv_rel_itag_d[0] = {fx0_rv_itag[0:`ITAG_SIZE_ENC-1]};
   assign xx_rv_rel_itag_d[1] = {fx1_rv_itag[0:`ITAG_SIZE_ENC-1]};
   assign xx_rv_rel_itag_d[2] = {lq_rv_itag0[0:`ITAG_SIZE_ENC-1]};
   assign xx_rv_rel_itag_d[3] = {lq_rv_itag1[0:`ITAG_SIZE_ENC-1]};
   assign xx_rv_rel_itag_d[4] = {lq_rv_itag2[0:`ITAG_SIZE_ENC-1]};
   assign xx_rv_rel_itag_d[5] = {axu0_rv_itag[0:`ITAG_SIZE_ENC-1]};
   assign xx_rv_rel_itag_d[6] = {axu1_rv_itag[0:`ITAG_SIZE_ENC-1]};


   //Vectorize to pass to cmpitag
   assign xx_rv_itag_vld_ary[0*`THREADS:0*`THREADS+`THREADS-1] = xx_rv_rel_vld_q[0] ;
   assign xx_rv_itag_vld_ary[1*`THREADS:1*`THREADS+`THREADS-1] = xx_rv_rel_vld_q[1] ;
   assign xx_rv_itag_vld_ary[2*`THREADS:2*`THREADS+`THREADS-1] = xx_rv_rel_vld_q[2] ;
   assign xx_rv_itag_vld_ary[3*`THREADS:3*`THREADS+`THREADS-1] = xx_rv_rel_vld_q[3];
   assign xx_rv_itag_vld_ary[4*`THREADS:4*`THREADS+`THREADS-1] = xx_rv_rel_vld_q[4];
   assign xx_rv_itag_vld_ary[5*`THREADS:5*`THREADS+`THREADS-1] = xx_rv_rel_vld_q[5];
   assign xx_rv_itag_vld_ary[6*`THREADS:6*`THREADS+`THREADS-1] = xx_rv_rel_vld_q[6];

   assign xx_rv_itag_ary[0*(`ITAG_SIZE_ENC):0*(`ITAG_SIZE_ENC)+(`ITAG_SIZE_ENC)-1] = xx_rv_rel_itag_q[0] ;
   assign xx_rv_itag_ary[1*(`ITAG_SIZE_ENC):1*(`ITAG_SIZE_ENC)+(`ITAG_SIZE_ENC)-1] = xx_rv_rel_itag_q[1] ;
   assign xx_rv_itag_ary[2*(`ITAG_SIZE_ENC):2*(`ITAG_SIZE_ENC)+(`ITAG_SIZE_ENC)-1] = xx_rv_rel_itag_q[2] ;
   assign xx_rv_itag_ary[3*(`ITAG_SIZE_ENC):3*(`ITAG_SIZE_ENC)+(`ITAG_SIZE_ENC)-1] = xx_rv_rel_itag_q[3] ;
   assign xx_rv_itag_ary[4*(`ITAG_SIZE_ENC):4*(`ITAG_SIZE_ENC)+(`ITAG_SIZE_ENC)-1] = xx_rv_rel_itag_q[4] ;
   assign xx_rv_itag_ary[5*(`ITAG_SIZE_ENC):5*(`ITAG_SIZE_ENC)+(`ITAG_SIZE_ENC)-1] = xx_rv_rel_itag_q[5] ;
   assign xx_rv_itag_ary[6*(`ITAG_SIZE_ENC):6*(`ITAG_SIZE_ENC)+(`ITAG_SIZE_ENC)-1] = xx_rv_rel_itag_q[6] ;

   generate
      begin : xhdl45
         for (n = 0; n <= (q_num_entries_g - 1); n = n + 1)
           begin : q_itag_match_gen
              // Zero Bubble from my FX release
              assign q_ilat0_match_s1[n] = (q_instr_ilat0_vld == q_tid_q[n]) & (q_s1_itag_q[n] == q_instr_itag);
              assign q_ilat0_match_s2[n] = (q_instr_ilat0_vld == q_tid_q[n]) & (q_s2_itag_q[n] == q_instr_itag);
              assign q_ilat0_match_s3[n] = (q_instr_ilat0_vld == q_tid_q[n]) & (q_s3_itag_q[n] == q_instr_itag);

              // Zero Bubble from other FX release
              assign q_other_ilat0_match_s1[n] = (rv1_other_ilat0_vld == q_tid_q[n]) & (q_s1_itag_q[n] == rv1_other_ilat0_itag);
              assign q_other_ilat0_match_s2[n] = (rv1_other_ilat0_vld == q_tid_q[n]) & (q_s2_itag_q[n] == rv1_other_ilat0_itag);
              assign q_other_ilat0_match_s3[n] = (rv1_other_ilat0_vld == q_tid_q[n]) & (q_s3_itag_q[n] == rv1_other_ilat0_itag);

              // All itag matches except other ilat0

              assign q_lq_itag_match[n] = |(lq_rv_itag1_rst_vld_q & q_tid_q[n]) & (q_itag_q[n] == lq_rv_itag1_rst_q);

              rv_cmpitag #(.q_itag_busses_g(q_itag_busses_g))
	      q_s1_itag_cmp(
                            .vld(q_tid_q[n]),
                            .itag(q_s1_itag_q[n]),
                            .vld_ary(xx_rv_itag_vld_ary),
                            .itag_ary(xx_rv_itag_ary),
			    .abort(xx_rv_abort_q),
                            .hit_clear(q_xx_itag_clear_s1[n]),
                            .hit_abort(q_xx_itag_abort_s1[n])
                            );

              rv_cmpitag #( .q_itag_busses_g(q_itag_busses_g))
	      q_s2_itag_cmp(
                            .vld(q_tid_q[n]),
                            .itag(q_s2_itag_q[n]),
                            .vld_ary(xx_rv_itag_vld_ary),
                            .itag_ary(xx_rv_itag_ary),
			    .abort(xx_rv_abort_q),
                            .hit_clear(q_xx_itag_clear_s2[n]),
                            .hit_abort(q_xx_itag_abort_s2[n])
                            );

              rv_cmpitag #( .q_itag_busses_g(q_itag_busses_g))
	      q_s3_itag_cmp(
                            .vld(q_tid_q[n]),
                            .itag(q_s3_itag_q[n]),
                            .vld_ary(xx_rv_itag_vld_ary),
                            .itag_ary(xx_rv_itag_ary),
			    .abort(xx_rv_abort_q),
                            .hit_clear(q_xx_itag_clear_s3[n]),
                            .hit_abort(q_xx_itag_abort_s3[n])
                            );

           end
      end
   endgenerate

   rv_cmpitag #( .q_itag_busses_g(q_itag_busses_g))
   i0_s1_itag_cmp(
                  .vld(rv0_instr_i0_tid),
                  .itag(rv0_instr_i0_s1_itag),
                  .vld_ary(xx_rv_itag_vld_ary),
                  .itag_ary(xx_rv_itag_ary),
		  .abort(xx_rv_abort_q),
                  .hit_clear(rv0_i0_s1_itag_clear),
		  .hit_abort(rv0_i0_s1_itag_abort) //unused
                  );

   rv_cmpitag #( .q_itag_busses_g(q_itag_busses_g))
   i0_s2_itag_cmp(
                  .vld(rv0_instr_i0_tid),
                  .itag(rv0_instr_i0_s2_itag),
                  .vld_ary(xx_rv_itag_vld_ary),
                  .itag_ary(xx_rv_itag_ary),
		  .abort(xx_rv_abort_q),
                  .hit_clear(rv0_i0_s2_itag_clear),
		  .hit_abort(rv0_i0_s2_itag_abort) //unused
                  );

   rv_cmpitag #( .q_itag_busses_g(q_itag_busses_g))
   i0_s3_itag_cmp(
                  .vld(rv0_instr_i0_tid),
                  .itag(rv0_instr_i0_s3_itag),
                  .vld_ary(xx_rv_itag_vld_ary),
                  .itag_ary(xx_rv_itag_ary),
		  .abort(xx_rv_abort_q),
                  .hit_clear(rv0_i0_s3_itag_clear),
		  .hit_abort(rv0_i0_s3_itag_abort) //unused
                  );


   // rv0_*_s?_dep_hit will only be on for a souce valid, so don't need to gate that here (except for the abort, which is faster)
   assign rv0_instr_i0_s1_rdy = ~((rv0_instr_i0_s1_dep_hit & ~(rv0_i0_s1_itag_clear )) | (rv0_i0_s1_itag_abort & rv0_instr_i0_s1_v));
   assign rv0_instr_i0_s2_rdy = ~((rv0_instr_i0_s2_dep_hit & ~(rv0_i0_s2_itag_clear )) | (rv0_i0_s2_itag_abort & rv0_instr_i0_s2_v));
   assign rv0_instr_i0_s3_rdy = ~((rv0_instr_i0_s3_dep_hit & ~(rv0_i0_s3_itag_clear )) | (rv0_i0_s3_itag_abort & rv0_instr_i0_s3_v));


   rv_cmpitag #( .q_itag_busses_g(q_itag_busses_g))
   i1_s1_itag_cmp(
                  .vld(rv0_instr_i1_tid),
                  .itag(rv0_instr_i1_s1_itag),
                  .vld_ary(xx_rv_itag_vld_ary),
                  .itag_ary(xx_rv_itag_ary),
		  .abort(xx_rv_abort_q),
                  .hit_clear(rv0_i1_s1_itag_clear),
		  .hit_abort(rv0_i1_s1_itag_abort)
                  );

   rv_cmpitag #( .q_itag_busses_g(q_itag_busses_g))
   i1_s2_itag_cmp(
                  .vld(rv0_instr_i1_tid),
                  .itag(rv0_instr_i1_s2_itag),
                  .vld_ary(xx_rv_itag_vld_ary),
                  .itag_ary(xx_rv_itag_ary),
		  .abort(xx_rv_abort_q),
                  .hit_clear(rv0_i1_s2_itag_clear),
		  .hit_abort(rv0_i1_s2_itag_abort)
                  );

   rv_cmpitag #( .q_itag_busses_g(q_itag_busses_g))
   i1_s3_itag_cmp(
                  .vld(rv0_instr_i1_tid),
                  .itag(rv0_instr_i1_s3_itag),
                  .vld_ary(xx_rv_itag_vld_ary),
                  .itag_ary(xx_rv_itag_ary),
		  .abort(xx_rv_abort_q),
                  .hit_clear(rv0_i1_s3_itag_clear),
		  .hit_abort(rv0_i1_s3_itag_abort)
                  );

   assign rv0_instr_i1_s1_rdy = ~((rv0_instr_i1_s1_dep_hit & ~(rv0_i1_s1_itag_clear )) | (rv0_i1_s1_itag_abort & rv0_instr_i1_s1_v));
   assign rv0_instr_i1_s2_rdy = ~((rv0_instr_i1_s2_dep_hit & ~(rv0_i1_s2_itag_clear )) | (rv0_i1_s2_itag_abort & rv0_instr_i1_s2_v));
   assign rv0_instr_i1_s3_rdy = ~((rv0_instr_i1_s3_dep_hit & ~(rv0_i1_s3_itag_clear )) | (rv0_i1_s3_itag_abort & rv0_instr_i1_s3_v));

   //-------------------------------------------------------------------------------------------------------
   // Perf Counters
   //-------------------------------------------------------------------------------------------------------
   // 0 RV Empty
   // 1 RV Issued OoO
   // 2 RV Above watermark
   // 3 RV Instr Issued
   // 4 Ordered Hold
   // 5 Cord Hold
   // 6 Dep Hold
   // 7 Instr Aborted

   assign perf_bus_d[0] = &(rvs_empty_q);
   assign perf_bus_d[1] = issued_vld_q[0][0]; //todo, not right
   assign perf_bus_d[2] = |(q_ev_q[0:4]);
   assign perf_bus_d[3] = issued_vld_q[0][0];
   assign perf_bus_d[4] = q_entry_tvld_rev[0][q_num_entries_g-1] & ~q_issued_q[q_num_entries_g-1] & q_ord_q[q_num_entries_g-1] & |q_hold_ord_q;
   assign perf_bus_d[5] = q_entry_tvld_rev[0][q_num_entries_g-1] & ~q_issued_q[q_num_entries_g-1] & q_cord_q[q_num_entries_g-1] & ~q_cord_match;
   assign perf_bus_d[6] = |(q_entry_tvld_rev[0] & ~q_issued_q & ~q_rdy_q);
   assign perf_bus_d[7] = xx_rv_ex3_abort & issued_vld_q[3][0];

`ifndef THREADS1

   assign perf_bus_d[8]  = &(rvs_empty_q);
   assign perf_bus_d[9]  = issued_vld_q[0][1]; //todo, not right
   assign perf_bus_d[10] = |(q_ev_q[0:4]);
   assign perf_bus_d[11] = issued_vld_q[0][1];
   assign perf_bus_d[12] = q_entry_tvld_rev[1][q_num_entries_g-1] & ~q_issued_q[q_num_entries_g-1] & q_ord_q[q_num_entries_g-1] & |q_hold_ord_q;
   assign perf_bus_d[13] = q_entry_tvld_rev[1][q_num_entries_g-1] & ~q_issued_q[q_num_entries_g-1] & q_cord_q[q_num_entries_g-1] & ~q_cord_match;
   assign perf_bus_d[14] = |(q_entry_tvld_rev[1] & ~q_issued_q & ~q_rdy_q);
   assign perf_bus_d[15] = xx_rv_ex3_abort & issued_vld_q[3][1];

`endif

   assign rvs_perf_bus = perf_bus_q;

   assign dbg_bus_d = 32'b0;
   assign rvs_dbg_bus = dbg_bus_q;


   //-------------------------------------------------------------------------------------------------------
   // storage elements
   //-------------------------------------------------------------------------------------------------------


   tri_rlmreg_p #(.WIDTH(q_barf_enc_g), .INIT(0))
   ex0_barf_addr_reg(
              .vd(vdd),
              .gd(gnd),
              .nclk(nclk),
              .act(tiup),
              .thold_b(func_sl_thold_0_b),
              .sg(sg_0),
              .force_t(force_t),
              .delay_lclkr(delay_lclkr),
              .mpw1_b(mpw1_b),
              .mpw2_b(mpw2_b),
              .d_mode(d_mode),
              .scin(siv[ex0_barf_addr_offset:ex0_barf_addr_offset + q_barf_enc_g - 1]),
              .scout(sov[ex0_barf_addr_offset:ex0_barf_addr_offset + q_barf_enc_g - 1]),
              .din(ex0_barf_addr_d),
              .dout(ex0_barf_addr_q)
              );

   generate
      begin : x5ia4
         for (n = 0; n <= 4 ; n = n + 1)
           begin : isa_gen

	      tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
	      issued_vld_reg(
			  .vd(vdd),
			  .gd(gnd),
			  .nclk(nclk),
			  .act(tiup),
			  .thold_b(func_sl_thold_0_b),
			  .sg(sg_0),
			  .force_t(force_t),
			  .delay_lclkr(delay_lclkr),
			  .mpw1_b(mpw1_b),
			  .mpw2_b(mpw2_b),
			  .d_mode(d_mode),
			  .scin(siv[issued_vld_offset + `THREADS*n:issued_vld_offset + `THREADS*(n+1) - 1]),
			  .scout(sov[issued_vld_offset + `THREADS*n:issued_vld_offset + `THREADS*(n+1) - 1]),
			  .din(issued_vld_d[n]),
			  .dout(issued_vld_q[n])
              );
	      tri_rlmreg_p #(.WIDTH(4), .INIT(0))
	      issued_addr_reg(
			  .vd(vdd),
			  .gd(gnd),
			  .nclk(nclk),
			  .act(tiup),
			  .thold_b(func_sl_thold_0_b),
			  .sg(sg_0),
			  .force_t(force_t),
			  .delay_lclkr(delay_lclkr),
			  .mpw1_b(mpw1_b),
			  .mpw2_b(mpw2_b),
			  .d_mode(d_mode),
			  .scin(siv[issued_addr_offset + 4*n:issued_addr_offset + 4*(n+1) - 1]),
			  .scout(sov[issued_addr_offset + 4*n:issued_addr_offset + 4*(n+1) - 1]),
			  .din(issued_addr_d[n]),
			  .dout(issued_addr_q[n])
              );
	   end // block: q_bev_gen
      end // block: xhdl555
   endgenerate

  tri_rlmlatch_p #( .INIT(0))
   xx_rv_ex3_abort_reg(
             .vd(vdd),
             .gd(gnd),
             .nclk(nclk),
             .act(tiup),
             .thold_b(func_sl_thold_0_b),
             .sg(sg_0),
             .force_t(force_t),
             .delay_lclkr(delay_lclkr),
             .mpw1_b(mpw1_b),
             .mpw2_b(mpw2_b),
             .d_mode(d_mode),
             .scin(siv[xx_rv_ex3_abort_offset]),
             .scout(sov[xx_rv_ex3_abort_offset]),
             .din(xx_rv_ex2_abort),
             .dout(xx_rv_ex3_abort)
             );
  tri_rlmlatch_p #( .INIT(0))
   xx_rv_ex4_abort_reg(
             .vd(vdd),
             .gd(gnd),
             .nclk(nclk),
             .act(tiup),
             .thold_b(func_sl_thold_0_b),
             .sg(sg_0),
             .force_t(force_t),
             .delay_lclkr(delay_lclkr),
             .mpw1_b(mpw1_b),
             .mpw2_b(mpw2_b),
             .d_mode(d_mode),
             .scin(siv[xx_rv_ex4_abort_offset]),
             .scout(sov[xx_rv_ex4_abort_offset]),
             .din(xx_rv_ex3_abort),
             .dout(xx_rv_ex4_abort)
             );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   flush_reg(
             .vd(vdd),
             .gd(gnd),
             .nclk(nclk),
             .act(tiup),
             .thold_b(func_sl_thold_0_b),
             .sg(sg_0),
             .force_t(force_t),
             .delay_lclkr(delay_lclkr),
             .mpw1_b(mpw1_b),
             .mpw2_b(mpw2_b),
             .d_mode(d_mode),
             .scin(siv[flush_reg_offset:flush_reg_offset + `THREADS - 1]),
             .scout(sov[flush_reg_offset:flush_reg_offset + `THREADS - 1]),
             .din(cp_flush),
             .dout(flush)
             );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   flush2_reg(
              .vd(vdd),
              .gd(gnd),
              .nclk(nclk),
              .act(tiup),
              .thold_b(func_sl_thold_0_b),
              .sg(sg_0),
              .force_t(force_t),
              .delay_lclkr(delay_lclkr),
              .mpw1_b(mpw1_b),
              .mpw2_b(mpw2_b),
              .d_mode(d_mode),
              .scin(siv[flush2_reg_offset:flush2_reg_offset + `THREADS - 1]),
              .scout(sov[flush2_reg_offset:flush2_reg_offset + `THREADS - 1]),
              .din(flush),
              .dout(flush2)
              );



   generate
      begin : xhdl555
         for (n = 0; n <= q_num_entries_g ; n = n + 1)
           begin : q_bev_gen

	      tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
	      barf_ev_reg(
			  .vd(vdd),
			  .gd(gnd),
			  .nclk(nclk),
			  .act(tiup),
			  .thold_b(func_sl_thold_0_b),
			  .sg(sg_0),
			  .force_t(force_t),
			  .delay_lclkr(delay_lclkr),
			  .mpw1_b(mpw1_b),
			  .mpw2_b(mpw2_b),
			  .d_mode(d_mode),
			  .scin(siv[barf_ev_offset + `THREADS*n:barf_ev_offset + `THREADS*(n+1) - 1]),
			  .scout(sov[barf_ev_offset + `THREADS*n:barf_ev_offset + `THREADS*(n+1) - 1]),
			  .din(barf_ev_d[n]),
			  .dout(barf_ev_q[n])
              );
	   end // block: q_bev_gen
      end // block: xhdl555
   endgenerate

   generate
      begin : xhdl5xx
         for (n = 0; n < q_itag_busses_g ; n = n + 1)
           begin : xx_gen

	      tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
	      xx_rv_rel_vld_reg(
			  .vd(vdd),
			  .gd(gnd),
			  .nclk(nclk),
			  .act(tiup),
			  .thold_b(func_sl_thold_0_b),
			  .sg(sg_0),
			  .force_t(force_t),
			  .delay_lclkr(delay_lclkr),
			  .mpw1_b(mpw1_b),
			  .mpw2_b(mpw2_b),
			  .d_mode(d_mode),
			  .scin(siv[xx_rv_rel_vld_offset + `THREADS*n:xx_rv_rel_vld_offset + `THREADS*(n+1) - 1]),
			  .scout(sov[xx_rv_rel_vld_offset + `THREADS*n:xx_rv_rel_vld_offset + `THREADS*(n+1) - 1]),
			  .din(xx_rv_rel_vld_d[n]),
			  .dout(xx_rv_rel_vld_q[n])
              );
	      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
	      xx_rv_rel_itag_reg(
			  .vd(vdd),
			  .gd(gnd),
			  .nclk(nclk),
			  .act(tiup),
			  .thold_b(func_sl_thold_0_b),
			  .sg(sg_0),
			  .force_t(force_t),
			  .delay_lclkr(delay_lclkr),
			  .mpw1_b(mpw1_b),
			  .mpw2_b(mpw2_b),
			  .d_mode(d_mode),
			  .scin(siv[xx_rv_rel_itag_offset + (`ITAG_SIZE_ENC)*n:xx_rv_rel_itag_offset + (`ITAG_SIZE_ENC)*(n+1) - 1]),
			  .scout(sov[xx_rv_rel_itag_offset + (`ITAG_SIZE_ENC)*n:xx_rv_rel_itag_offset + (`ITAG_SIZE_ENC)*(n+1) - 1]),
			  .din(xx_rv_rel_itag_d[n]),
			  .dout(xx_rv_rel_itag_q[n])
              );
	   end // block: q_bev_gen
      end // block: xhdl555
   endgenerate

	      tri_rlmreg_p #(.WIDTH(q_itag_busses_g), .INIT(0))
	      xx_rv_abort_reg(
			  .vd(vdd),
			  .gd(gnd),
			  .nclk(nclk),
			  .act(tiup),
			  .thold_b(func_sl_thold_0_b),
			  .sg(sg_0),
			  .force_t(force_t),
			  .delay_lclkr(delay_lclkr),
			  .mpw1_b(mpw1_b),
			  .mpw2_b(mpw2_b),
			  .d_mode(d_mode),
			  .scin(siv[xx_rv_abort_offset:xx_rv_abort_offset + q_itag_busses_g - 1]),
			  .scout(sov[xx_rv_abort_offset:xx_rv_abort_offset + q_itag_busses_g - 1]),
			  .din(xx_rv_abort_d),
			  .dout(xx_rv_abort_q)
              );

   generate
      begin : xhdl999
         for (n = 0; n <= q_num_entries_g - 1; n = n + 1)
           begin : q_x_q_gen

              tri_rlmreg_p #(.WIDTH(q_dat_width_g), .INIT(0))
	      q_dat_q_reg(
                          .vd(vdd),
                          .gd(gnd),
                          .nclk(nclk),
                          .act(q_dat_act[n]),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .force_t(force_t),
                          .delay_lclkr(delay_lclkr),
                          .mpw1_b(mpw1_b),
                          .mpw2_b(mpw2_b),
                          .d_mode(d_mode),
                          .scin(siv[q_dat_offset + q_dat_width_g * n:q_dat_offset + q_dat_width_g * (n + 1) - 1]),
                          .scout(sov[q_dat_offset + q_dat_width_g * n:q_dat_offset + q_dat_width_g * (n + 1) - 1]),
                          .din(q_dat_d[n]),
                          .dout(q_dat_q[n])
                          );


              tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
	      q_itag_q_reg(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(q_dat_act[n]),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .force_t(force_t),
                           .delay_lclkr(delay_lclkr),
                           .mpw1_b(mpw1_b),
                           .mpw2_b(mpw2_b),
                           .d_mode(d_mode),
                           .scin(siv[q_itag_offset + `ITAG_SIZE_ENC * n:q_itag_offset + `ITAG_SIZE_ENC * (n + 1) - 1]),
                           .scout(sov[q_itag_offset + `ITAG_SIZE_ENC * n:q_itag_offset + `ITAG_SIZE_ENC * (n + 1) - 1]),
                           .din(q_itag_d[n]),
                           .dout(q_itag_q[n])
                           );




              tri_rlmreg_p #(.WIDTH(4), .INIT(0))
	      q_ilat_q_reg(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(q_dat_act[n]),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .force_t(force_t),
                           .delay_lclkr(delay_lclkr),
                           .mpw1_b(mpw1_b),
                           .mpw2_b(mpw2_b),
                           .d_mode(d_mode),
                           .scin(siv[q_ilat_offset + 4 * n:q_ilat_offset + 4 * (n + 1) - 1]),
                           .scout(sov[q_ilat_offset + 4 * n:q_ilat_offset + 4 * (n + 1) - 1]),
                           .din(q_ilat_d[n]),
                           .dout(q_ilat_q[n])
                           );


              tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
	      q_tid_q_reg(
                          .vd(vdd),
                          .gd(gnd),
                          .nclk(nclk),
                          .act(q_dat_act[n]),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .force_t(force_t),
                          .delay_lclkr(delay_lclkr),
                          .mpw1_b(mpw1_b),
                          .mpw2_b(mpw2_b),
                          .d_mode(d_mode),
                          .scin(siv[q_tid_offset + `THREADS * n:q_tid_offset + `THREADS * (n + 1) - 1]),
                          .scout(sov[q_tid_offset + `THREADS * n:q_tid_offset + `THREADS * (n + 1) - 1]),
                          .din(q_tid_d[n]),
                          .dout(q_tid_q[n])
                          );
              tri_rlmreg_p #(.WIDTH(q_barf_enc_g), .INIT(0))
	      q_bard_addr_q_reg(
                          .vd(vdd),
                          .gd(gnd),
                          .nclk(nclk),
                          .act(q_dat_act[n]),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .force_t(force_t),
                          .delay_lclkr(delay_lclkr),
                          .mpw1_b(mpw1_b),
                          .mpw2_b(mpw2_b),
                          .d_mode(d_mode),
                          .scin(siv[q_barf_addr_offset + q_barf_enc_g* n:q_barf_addr_offset + q_barf_enc_g* (n + 1) - 1]),
                          .scout(sov[q_barf_addr_offset + q_barf_enc_g* n:q_barf_addr_offset + q_barf_enc_g* (n + 1) - 1]),
                          .din(q_barf_addr_d[n]),
                          .dout(q_barf_addr_q[n])
                          );


              tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
	      q_s1_itag_q_reg(
                              .vd(vdd),
                              .gd(gnd),
                              .nclk(nclk),
                              .act(q_dat_act[n]),
                              .thold_b(func_sl_thold_0_b),
                              .sg(sg_0),
                              .force_t(force_t),
                              .delay_lclkr(delay_lclkr),
                              .mpw1_b(mpw1_b),
                              .mpw2_b(mpw2_b),
                              .d_mode(d_mode),
                              .scin(siv[q_s1_itag_offset + `ITAG_SIZE_ENC * n:q_s1_itag_offset + `ITAG_SIZE_ENC * (n + 1) - 1]),
                              .scout(sov[q_s1_itag_offset + `ITAG_SIZE_ENC * n:q_s1_itag_offset + `ITAG_SIZE_ENC * (n + 1) - 1]),
                              .din(q_s1_itag_d[n]),
                              .dout(q_s1_itag_q[n])
                              );


              tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
	      q_s2_itag_q_reg(
                              .vd(vdd),
                              .gd(gnd),
                              .nclk(nclk),
                              .act(q_dat_act[n]),
                              .thold_b(func_sl_thold_0_b),
                              .sg(sg_0),
                              .force_t(force_t),
                              .delay_lclkr(delay_lclkr),
                              .mpw1_b(mpw1_b),
                              .mpw2_b(mpw2_b),
                              .d_mode(d_mode),
                              .scin(siv[q_s2_itag_offset + `ITAG_SIZE_ENC * n:q_s2_itag_offset + `ITAG_SIZE_ENC * (n + 1) - 1]),
                              .scout(sov[q_s2_itag_offset + `ITAG_SIZE_ENC * n:q_s2_itag_offset + `ITAG_SIZE_ENC * (n + 1) - 1]),
                              .din(q_s2_itag_d[n]),
                              .dout(q_s2_itag_q[n])
                              );


              tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
	      q_s3_itag_q_reg(
                              .vd(vdd),
                              .gd(gnd),
                              .nclk(nclk),
                              .act(q_dat_act[n]),
                              .thold_b(func_sl_thold_0_b),
                              .sg(sg_0),
                              .force_t(force_t),
                              .delay_lclkr(delay_lclkr),
                              .mpw1_b(mpw1_b),
                              .mpw2_b(mpw2_b),
                              .d_mode(d_mode),
                              .scin(siv[q_s3_itag_offset + `ITAG_SIZE_ENC * n:q_s3_itag_offset + `ITAG_SIZE_ENC * (n + 1) - 1]),
                              .scout(sov[q_s3_itag_offset + `ITAG_SIZE_ENC * n:q_s3_itag_offset + `ITAG_SIZE_ENC * (n + 1) - 1]),
                              .din(q_s3_itag_d[n]),
                              .dout(q_s3_itag_q[n])
                              );


              tri_rlmlatch_p #(.INIT(0))
	      q_s1_v_q_reg(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(q_dat_act[n]),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .force_t(force_t),
                           .delay_lclkr(delay_lclkr),
                           .mpw1_b(mpw1_b),
                           .mpw2_b(mpw2_b),
                           .d_mode(d_mode),
                           .scin(siv[q_s1_v_offset + n]),
                           .scout(sov[q_s1_v_offset + n]),
                           .din(q_s1_v_d[n]),
                           .dout(q_s1_v_q[n])
                           );


              tri_rlmlatch_p #(.INIT(0))
	      q_s2_v_q_reg(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(q_dat_act[n]),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .force_t(force_t),
                           .delay_lclkr(delay_lclkr),
                           .mpw1_b(mpw1_b),
                           .mpw2_b(mpw2_b),
                           .d_mode(d_mode),
                           .scin(siv[q_s2_v_offset + n]),
                           .scout(sov[q_s2_v_offset + n]),
                           .din(q_s2_v_d[n]),
                           .dout(q_s2_v_q[n])
                           );


              tri_rlmlatch_p #(.INIT(0))
	      q_s3_v_q_reg(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(q_dat_act[n]),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .force_t(force_t),
                           .delay_lclkr(delay_lclkr),
                           .mpw1_b(mpw1_b),
                           .mpw2_b(mpw2_b),
                           .d_mode(d_mode),
                           .scin(siv[q_s3_v_offset + n]),
                           .scout(sov[q_s3_v_offset + n]),
                           .din(q_s3_v_d[n]),
                           .dout(q_s3_v_q[n])
                           );


              tri_rlmlatch_p #(.INIT(0))
	      q_issued_q_reg(
                             .vd(vdd),
                             .gd(gnd),
                             .nclk(nclk),
                             .act(tiup),
                             .thold_b(func_sl_thold_0_b),
                             .sg(sg_0),
                             .force_t(force_t),
                             .delay_lclkr(delay_lclkr),
                             .mpw1_b(mpw1_b),
                             .mpw2_b(mpw2_b),
                             .d_mode(d_mode),
                             .scin(siv[q_issued_offset + n]),
                             .scout(sov[q_issued_offset + n]),
                             .din(q_issued_d[n]),
                             .dout(q_issued_q[n])
                             );

              tri_rlmlatch_p #(.INIT(0))
	      q_s1_rdy_reg(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(tiup),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .force_t(force_t),
                           .delay_lclkr(delay_lclkr),
                           .mpw1_b(mpw1_b),
                           .mpw2_b(mpw2_b),
                           .d_mode(d_mode),
                           .scin(siv[q_s1_rdy_offset + n]),
                           .scout(sov[q_s1_rdy_offset + n]),
                           .din(q_s1_rdy_d[n]),
                           .dout(q_s1_rdy_q[n])
                           );


              tri_rlmlatch_p #(.INIT(0))
	      q_s2_rdy_reg(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(tiup),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .force_t(force_t),
                           .delay_lclkr(delay_lclkr),
                           .mpw1_b(mpw1_b),
                           .mpw2_b(mpw2_b),
                           .d_mode(d_mode),
                           .scin(siv[q_s2_rdy_offset + n]),
                           .scout(sov[q_s2_rdy_offset + n]),
                           .din(q_s2_rdy_d[n]),
                           .dout(q_s2_rdy_q[n])
                           );


              tri_rlmlatch_p #(.INIT(0))
	      q_s3_rdy_reg(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(tiup),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .force_t(force_t),
                           .delay_lclkr(delay_lclkr),
                           .mpw1_b(mpw1_b),
                           .mpw2_b(mpw2_b),
                           .d_mode(d_mode),
                           .scin(siv[q_s3_rdy_offset + n]),
                           .scout(sov[q_s3_rdy_offset + n]),
                           .din(q_s3_rdy_d[n]),
                           .dout(q_s3_rdy_q[n])
                           );

           end
      end
   endgenerate


   // Issueable
   generate
      begin : xhdl999i
         for (n = 0; n <= q_num_entries_g - 1; n = n + 1)
           begin : q_x_q_gen


              tri_rlmlatch_p #(.INIT(0))
	      q_rdy_q_reg(
                          .vd(vdd),
                          .gd(gnd),
                          .nclk(nclk),
                          .act(tiup),
                          .thold_b(func_sl_thold_0_b),
                          .sg(sg_0),
                          .force_t(force_t),
                          .delay_lclkr(delay_lclkr),
                          .mpw1_b(mpw1_b),
                          .mpw2_b(mpw2_b),
                          .d_mode(d_mode),
                          .scin(siv[q_rdy_offset + n]),
                          .scout(sov[q_rdy_offset + n]),
                          .din(q_rdy_d[n]),
                          .dout(q_rdy_q[n])
                          );
              assign q_rdy_qb[n] = ~q_rdy_q[n];

            end
      end
   endgenerate


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   lq_rv_itag1_rst_vld_reg(
                           .vd(vdd),
                           .gd(gnd),
                           .nclk(nclk),
                           .act(tiup),
                           .thold_b(func_sl_thold_0_b),
                           .sg(sg_0),
                           .force_t(force_t),
                           .delay_lclkr(delay_lclkr),
                           .mpw1_b(mpw1_b),
                           .mpw2_b(mpw2_b),
                           .d_mode(d_mode),
                           .scin(siv[lq_rv_itag1_rst_vld_offset:lq_rv_itag1_rst_vld_offset + `THREADS - 1]),
                           .scout(sov[lq_rv_itag1_rst_vld_offset:lq_rv_itag1_rst_vld_offset + `THREADS - 1]),
                           .din(lq_rv_itag1_rst_vld),
                           .dout(lq_rv_itag1_rst_vld_q)
                           );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
   lq_rv_itag1_rst_reg(
                       .vd(vdd),
                       .gd(gnd),
                       .nclk(nclk),
                       .act(tiup),
                       .thold_b(func_sl_thold_0_b),
                       .sg(sg_0),
                       .force_t(force_t),
                       .delay_lclkr(delay_lclkr),
                       .mpw1_b(mpw1_b),
                       .mpw2_b(mpw2_b),
                       .d_mode(d_mode),
                       .scin(siv[lq_rv_itag1_rst_offset:lq_rv_itag1_rst_offset + `ITAG_SIZE_ENC - 1]),
                       .scout(sov[lq_rv_itag1_rst_offset:lq_rv_itag1_rst_offset + `ITAG_SIZE_ENC - 1]),
                       .din(lq_rv_itag1_rst),
                       .dout(lq_rv_itag1_rst_q)
                       );



   tri_rlmreg_p #(.WIDTH(q_num_entries_g), .INIT(0))
   q_ev_q_reg(
              .vd(vdd),
              .gd(gnd),
              .nclk(nclk),
              .act(tiup),
              .thold_b(func_sl_thold_0_b),
              .sg(sg_0),
              .force_t(force_t),
              .delay_lclkr(delay_lclkr),
              .mpw1_b(mpw1_b),
              .mpw2_b(mpw2_b),
              .d_mode(d_mode),
              .scin(siv[q_ev_offset:q_ev_offset + q_num_entries_g - 1]),
              .scout(sov[q_ev_offset:q_ev_offset + q_num_entries_g - 1]),
              .din(q_ev_d),
              .dout(q_ev_q)
              );


   tri_rlmreg_p #(.WIDTH(q_num_entries_g), .INIT(0))
   q_flushed_q_reg(
                   .vd(vdd),
                   .gd(gnd),
                   .nclk(nclk),
                   .act(tiup),
                   .thold_b(func_sl_thold_0_b),
                   .sg(sg_0),
                   .force_t(force_t),
                   .delay_lclkr(delay_lclkr),
                   .mpw1_b(mpw1_b),
                   .mpw2_b(mpw2_b),
                   .d_mode(d_mode),
                   .scin(siv[q_flushed_offset:q_flushed_offset + q_num_entries_g - 1]),
                   .scout(sov[q_flushed_offset:q_flushed_offset + q_num_entries_g - 1]),
                   .din(q_flushed_d),
                   .dout(q_flushed_q)
                   );


   tri_rlmreg_p #(.WIDTH(q_num_entries_g), .INIT(0))
   q_credit_q_reg(
                  .vd(vdd),
                  .gd(gnd),
                  .nclk(nclk),
                  .act(tiup),
                  .thold_b(func_sl_thold_0_b),
                  .sg(sg_0),
                  .force_t(force_t),
                  .delay_lclkr(delay_lclkr),
                  .mpw1_b(mpw1_b),
                  .mpw2_b(mpw2_b),
                  .d_mode(d_mode),
                  .scin(siv[q_credit_offset:q_credit_offset + q_num_entries_g - 1]),
                  .scout(sov[q_credit_offset:q_credit_offset + q_num_entries_g - 1]),
                  .din(q_credit_d),
                  .dout(q_credit_q)
                  );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   ex1_credit_free_q_reg(
                         .vd(vdd),
                         .gd(gnd),
                         .nclk(nclk),
                         .act(tiup),
                         .thold_b(func_sl_thold_0_b),
                         .sg(sg_0),
                         .force_t(force_t),
                         .delay_lclkr(delay_lclkr),
                         .mpw1_b(mpw1_b),
                         .mpw2_b(mpw2_b),
                         .d_mode(d_mode),
                         .scin(siv[ex1_credit_free_offset:ex1_credit_free_offset + `THREADS - 1]),
                         .scout(sov[ex1_credit_free_offset:ex1_credit_free_offset + `THREADS - 1]),
                         .din(ex1_credit_free_d),
                         .dout(ex1_credit_free_q)
                         );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   rvs_empty_q_reg(
                   .vd(vdd),
                   .gd(gnd),
                   .nclk(nclk),
                   .act(tiup),
                   .thold_b(func_sl_thold_0_b),
                   .sg(sg_0),
                   .force_t(force_t),
                   .delay_lclkr(delay_lclkr),
                   .mpw1_b(mpw1_b),
                   .mpw2_b(mpw2_b),
                   .d_mode(d_mode),
                   .scin(siv[rvs_empty_offset:rvs_empty_offset + `THREADS - 1]),
                   .scout(sov[rvs_empty_offset:rvs_empty_offset + `THREADS - 1]),
                   .din(rvs_empty_d),
                   .dout(rvs_empty_q)
                   );


   tri_rlmlatch_p #(.INIT(0))
   q_hold_all_q_reg(
                    .vd(vdd),
                    .gd(gnd),
                    .nclk(nclk),
                    .act(tiup),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .force_t(force_t),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .d_mode(d_mode),
                    .scin(siv[q_hold_all_offset]),
                    .scout(sov[q_hold_all_offset]),
                    .din(q_hold_all_d),
                    .dout(q_hold_all_q)
                    );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
   q_hold_ord_q_reg(
                    .vd(vdd),
                    .gd(gnd),
                    .nclk(nclk),
                    .act(tiup),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .force_t(force_t),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .d_mode(d_mode),
                    .scin(siv[q_hold_ord_offset:q_hold_ord_offset + `THREADS - 1]),
                    .scout(sov[q_hold_ord_offset:q_hold_ord_offset + `THREADS - 1]),
                    .din(q_hold_ord_d),
                    .dout(q_hold_ord_q)
                    );

   tri_rlmreg_p #(.WIDTH(8*`THREADS), .INIT(0))
   perf_bus_reg(
                    .vd(vdd),
                    .gd(gnd),
                    .nclk(nclk),
                    .act(tiup),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .force_t(force_t),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .d_mode(d_mode),
                    .scin(siv[perf_bus_offset:perf_bus_offset + 8*`THREADS - 1]),
                    .scout(sov[perf_bus_offset:perf_bus_offset + 8*`THREADS - 1]),
                    .din(perf_bus_d),
                    .dout(perf_bus_q)
                    );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0))
   dbg_bus_reg(
                    .vd(vdd),
                    .gd(gnd),
                    .nclk(nclk),
                    .act(tiup),
                    .thold_b(func_sl_thold_0_b),
                    .sg(sg_0),
                    .force_t(force_t),
                    .delay_lclkr(delay_lclkr),
                    .mpw1_b(mpw1_b),
                    .mpw2_b(mpw2_b),
                    .d_mode(d_mode),
                    .scin(siv[dbg_bus_offset:dbg_bus_offset + 32 - 1]),
                    .scout(sov[dbg_bus_offset:dbg_bus_offset + 32 - 1]),
                    .din(dbg_bus_d),
                    .dout(dbg_bus_q)
                    );



   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];

   //-----------------------------------------------
   // pervasive
   //-----------------------------------------------


   tri_plat #(.WIDTH(2))
   perv_1to0_reg(
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


endmodule
