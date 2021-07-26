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

//-----------------------------------------------------------------------------------------------------
// Title:   rv_axu0_rvs.vhdl
// Desc:    LQ Reservation Station
//
//-----------------------------------------------------------------------------------------------------

module rv_axu0_rvs(
`include "tri_a2o.vh"

   //------------------------------------------------------------------------------------------------------------
   // Instructions from RV_DEP
   //------------------------------------------------------------------------------------------------------------
   input [0:`THREADS-1]            rv0_instr_i0_vld,
   input 			   rv0_instr_i0_rte_axu0,
   input [0:`THREADS-1] 	   rv0_instr_i1_vld,
   input 			   rv0_instr_i1_rte_axu0,

   input [0:31] 		   rv0_instr_i0_instr,
   input [0:2] 			   rv0_instr_i0_ucode,
   input [0:`ITAG_SIZE_ENC-1] 	   rv0_instr_i0_itag,
   input 			   rv0_instr_i0_ord,
   input 			   rv0_instr_i0_cord,
   input 			   rv0_instr_i0_t1_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i0_t1_p,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i0_t2_p,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i0_t3_p,
   input 			   rv0_instr_i0_s1_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i0_s1_p,
   input 			   rv0_instr_i0_s2_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i0_s2_p,
   input 			   rv0_instr_i0_s3_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i0_s3_p,
   input                           rv0_instr_i0_isStore,
   input [0:3] 			   rv0_instr_i0_spare,

   input [0:31] 		   rv0_instr_i1_instr,
   input [0:2] 			   rv0_instr_i1_ucode,
   input [0:`ITAG_SIZE_ENC-1] 	   rv0_instr_i1_itag,
   input 			   rv0_instr_i1_ord,
   input 			   rv0_instr_i1_cord,
   input 			   rv0_instr_i1_t1_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i1_t1_p,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i1_t2_p,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i1_t3_p,
   input 			   rv0_instr_i1_s1_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i1_s1_p,
   input 			   rv0_instr_i1_s2_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i1_s2_p,
   input 			   rv0_instr_i1_s3_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i1_s3_p,
   input                           rv0_instr_i1_isStore,
   input [0:3] 			   rv0_instr_i1_spare,

   input 			   rv0_instr_i0_s1_dep_hit,
   input [0:`ITAG_SIZE_ENC-1] 	   rv0_instr_i0_s1_itag,
   input 			   rv0_instr_i0_s2_dep_hit,
   input [0:`ITAG_SIZE_ENC-1] 	   rv0_instr_i0_s2_itag,
   input 			   rv0_instr_i0_s3_dep_hit,
   input [0:`ITAG_SIZE_ENC-1] 	   rv0_instr_i0_s3_itag,

   input 			   rv0_instr_i1_s1_dep_hit,
   input [0:`ITAG_SIZE_ENC-1] 	   rv0_instr_i1_s1_itag,
   input 			   rv0_instr_i1_s2_dep_hit,
   input [0:`ITAG_SIZE_ENC-1] 	   rv0_instr_i1_s2_itag,
   input 			   rv0_instr_i1_s3_dep_hit,
   input [0:`ITAG_SIZE_ENC-1] 	   rv0_instr_i1_s3_itag,

   //------------------------------------------------------------------------------------------------------------
   // Credit Interface with IU
   //------------------------------------------------------------------------------------------------------------
   output [0:`THREADS-1] 	   rv_iu_axu0_credit_free,

   //------------------------------------------------------------------------------------------------------------
   // Machine zap interface
   //------------------------------------------------------------------------------------------------------------
   input [0:`THREADS-1] 	   cp_flush,
   input [0:`THREADS*`ITAG_SIZE_ENC-1] cp_next_itag,

   //------------------------------------------------------------------------------------------------------------
   // Interface to axu0
   //------------------------------------------------------------------------------------------------------------
   output [0:`THREADS-1] 	       rv_axu0_vld,
   output 			       rv_axu0_s1_v,
   output [0:`GPR_POOL_ENC-1] 	       rv_axu0_s1_p,
   output 			       rv_axu0_s2_v,
   output [0:`GPR_POOL_ENC-1] 	       rv_axu0_s2_p,
   output 			       rv_axu0_s3_v,
   output [0:`GPR_POOL_ENC-1] 	       rv_axu0_s3_p,

   output [0:`ITAG_SIZE_ENC-1] 	       rv_axu0_ex0_itag,
   output [0:31] 		       rv_axu0_ex0_instr,
   output [0:2] 		       rv_axu0_ex0_ucode,
   output 			       rv_axu0_ex0_t1_v,
   output [0:`GPR_POOL_ENC-1] 	       rv_axu0_ex0_t1_p,
   output [0:`GPR_POOL_ENC-1] 	       rv_axu0_ex0_t2_p,
   output [0:`GPR_POOL_ENC-1] 	       rv_axu0_ex0_t3_p,

   input 			       axu0_rv_ord_complete,
   input                               axu0_rv_hold_all,

   //------------------------------------------------------------------------------------------------------------
   // RV Release bus
   //------------------------------------------------------------------------------------------------------------

   input                           axu0_rv_ex2_s1_abort,
   input                           axu0_rv_ex2_s2_abort,
   input                           axu0_rv_ex2_s3_abort,

   input 			   fx0_rv_ext_itag_abort,
   input 			   fx1_rv_ext_itag_abort,
   input 			   lq_rv_ext_itag0_abort,
   input 			   lq_rv_ext_itag1_abort,
   input 			   axu0_rv_itag_abort,
   input 			   axu1_rv_itag_abort,

   input [0:`THREADS-1] 	       fx0_rv_ext_itag_vld,
   input [0:`ITAG_SIZE_ENC-1] 	       fx0_rv_ext_itag,

   input [0:`THREADS-1] 	       fx1_rv_ext_itag_vld,
   input [0:`ITAG_SIZE_ENC-1] 	       fx1_rv_ext_itag,

   input [0:`THREADS-1] 	       axu0_rv_itag_vld,
   input [0:`ITAG_SIZE_ENC-1] 	       axu0_rv_itag,

   input [0:`THREADS-1] 	       axu1_rv_itag_vld,
   input [0:`ITAG_SIZE_ENC-1] 	       axu1_rv_itag,

   input [0:`THREADS-1] 	       lq_rv_ext_itag0_vld,
   input [0:`ITAG_SIZE_ENC-1] 	       lq_rv_ext_itag0,

   input [0:`THREADS-1] 	       lq_rv_itag1_vld,
   input [0:`ITAG_SIZE_ENC-1] 	       lq_rv_itag1,
   input 			       lq_rv_itag1_restart,
   input 			       lq_rv_itag1_hold,
   input [0:`THREADS-1] 	       lq_rv_ext_itag1_vld,
   input [0:`ITAG_SIZE_ENC-1] 	       lq_rv_ext_itag1,

   input [0:`THREADS-1] 	       lq_rv_ext_itag2_vld,
   input [0:`ITAG_SIZE_ENC-1] 	       lq_rv_ext_itag2,

   input [0:`THREADS-1] 	       lq_rv_clr_hold,

   output [0:`THREADS-1] 	       axu0_rv_ext_itag_vld,
   output    	                       axu0_rv_ext_itag_abort,
   output [0:`ITAG_SIZE_ENC-1] 	       axu0_rv_ext_itag,

   //------------------------------------------------------------------------------------------------------------
   // Pervasive
   //------------------------------------------------------------------------------------------------------------
   output [0:8*`THREADS-1]         axu0_rvs_perf_bus,
   output [0:31]                   axu0_rvs_dbg_bus,

   inout 			       vdd,
   inout 			       gnd,
   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) // nclk
   input [0:`NCLK_WIDTH-1]	       nclk,
   input 			       func_sl_thold_1,
   input 			       sg_1,
   input 			       clkoff_b,
   input 			       act_dis,
   input 			       ccflush_dc,
   input 			       d_mode,
   input 			       delay_lclkr,
   input 			       mpw1_b,
   input 			       mpw2_b,
   input 			       scan_in,

   output 			       scan_out
		   );



   parameter                      num_itag_busses_g = 7;

   //------------------------------------------------------------------------------------------------------------
   // RV AXU0 RVS INSTR ISSUE
   //------------------------------------------------------------------------------------------------------------
   parameter              rvaxu0_ex0_start = 0;

   parameter              rvaxu0_instr_start = rvaxu0_ex0_start;
   parameter              rvaxu0_instr_stop = (rvaxu0_instr_start + (32)) - 1;
   parameter              rvaxu0_ucode_start = rvaxu0_instr_stop + 1;
   parameter              rvaxu0_ucode_stop = (rvaxu0_ucode_start + (3)) - 1;
   parameter              rvaxu0_t1_v_start = rvaxu0_ucode_stop + 1;
   parameter              rvaxu0_t1_v_stop = (rvaxu0_t1_v_start + (1)) - 1;
   parameter              rvaxu0_t1_p_start = rvaxu0_t1_v_stop + 1;
   parameter              rvaxu0_t1_p_stop = (rvaxu0_t1_p_start + (`GPR_POOL_ENC)) - 1;
   parameter              rvaxu0_t2_p_start = rvaxu0_t1_p_stop + 1;
   parameter              rvaxu0_t2_p_stop = (rvaxu0_t2_p_start + (`GPR_POOL_ENC)) - 1;
   parameter              rvaxu0_t3_p_start = rvaxu0_t2_p_stop + 1;
   parameter              rvaxu0_t3_p_stop = (rvaxu0_t3_p_start + (`GPR_POOL_ENC)) - 1;
   parameter              rvaxu0_spare_start = rvaxu0_t3_p_stop + 1;
   parameter              rvaxu0_spare_stop = (rvaxu0_spare_start + (4)) - 1;

   parameter              rvaxu0_ex0_end = rvaxu0_spare_stop;

   parameter              rvaxu0_ex0_size = rvaxu0_ex0_end + 1;

   parameter              rvaxu0_start = 0;
   parameter              rvaxu0_s1_v_start = rvaxu0_start;
   parameter              rvaxu0_s1_v_stop = (rvaxu0_s1_v_start + (1)) - 1;
   parameter              rvaxu0_s1_p_start = rvaxu0_s1_v_stop + 1;
   parameter              rvaxu0_s1_p_stop = (rvaxu0_s1_p_start + (`GPR_POOL_ENC)) - 1;
   parameter              rvaxu0_s2_v_start = rvaxu0_s1_p_stop + 1;
   parameter              rvaxu0_s2_v_stop = (rvaxu0_s2_v_start + (1)) - 1;
   parameter              rvaxu0_s2_p_start = rvaxu0_s2_v_stop + 1;
   parameter              rvaxu0_s2_p_stop = (rvaxu0_s2_p_start + (`GPR_POOL_ENC)) - 1;
   parameter              rvaxu0_s3_v_start =  rvaxu0_s2_p_stop + 1;
   parameter              rvaxu0_s3_v_stop = (rvaxu0_s3_v_start + (1)) - 1;
   parameter              rvaxu0_s3_p_start = rvaxu0_s3_v_stop + 1;
   parameter              rvaxu0_s3_p_stop = (rvaxu0_s3_p_start + (`GPR_POOL_ENC)) - 1;

   parameter              rvaxu0_end = rvaxu0_s3_p_stop;

   parameter              rvaxu0_size = rvaxu0_end + 1;


   //------------------------------------------------------------------------------------------------------------
   // Pervasive
   //------------------------------------------------------------------------------------------------------------

   wire 			       tiup;
   wire [0:`THREADS-1] 		       cp_flush_q;

   //------------------------------------------------------------------------------------------------------------
   // RV0
   //------------------------------------------------------------------------------------------------------------
   wire 			       rv0_instr_i0_rte;
   wire 			       rv0_instr_i1_rte;

   //------------------------------------------------------------------------------------------------------------
   // RV1
   //------------------------------------------------------------------------------------------------------------
   wire [rvaxu0_start:rvaxu0_end]      rv0_instr_i0_dat;
   wire [rvaxu0_start:rvaxu0_end]      rv0_instr_i1_dat;
   wire [rvaxu0_ex0_start:rvaxu0_ex0_end] rv0_instr_i0_dat_ex0;
   wire [rvaxu0_ex0_start:rvaxu0_ex0_end] rv0_instr_i1_dat_ex0;

   wire 			       rv0_instr_i0_spec;
   wire 			       rv0_instr_i1_spec;

   wire 			       rv0_instr_i0_is_brick;
   wire [0:2] 			       rv0_instr_i0_brick;
   wire [0:3] 			       rv0_instr_i0_ilat;
   wire 			       rv0_instr_i1_is_brick;
   wire [0:2] 			       rv0_instr_i1_brick;
   wire [0:3] 			       rv0_instr_i1_ilat;

   wire 			       rv0_i0_s1_v;
   wire 			       rv0_i0_s2_v;
   wire 			       rv0_i1_s1_v;
   wire 			       rv0_i1_s2_v;
   wire 			       rv0_i0_s1_dep_hit;
   wire 			       rv0_i0_s2_dep_hit;
   wire 			       rv0_i1_s1_dep_hit;
   wire 			       rv0_i1_s2_dep_hit;

   //------------------------------------------------------------------------------------------------------------
   // RV2
   //------------------------------------------------------------------------------------------------------------
   wire [0:`THREADS-1] 		       rv1_other_ilat0_vld;
   wire [0:`ITAG_SIZE_ENC-1] 	       rv1_other_ilat0_itag;

   wire [rvaxu0_start:rvaxu0_end]      rv1_instr_dat;
   wire [0:`THREADS-1] 		       rv1_instr_v;
   wire 			       rv1_instr_ord;
   (* analysis_not_referenced="true" *)
   wire 			       rv1_instr_spec;
   wire [0:`ITAG_SIZE_ENC-1] 	       rv1_instr_itag;
   (* analysis_not_referenced="true" *)
   wire [0:`ITAG_SIZE_ENC-1] 	       rv1_instr_s1_itag;
   (* analysis_not_referenced="true" *)
   wire [0:`ITAG_SIZE_ENC-1] 	       rv1_instr_s2_itag;
   (* analysis_not_referenced="true" *)
   wire [0:`ITAG_SIZE_ENC-1] 	       rv1_instr_s3_itag;
   (* analysis_not_referenced="<54:57>true" *)
   wire [rvaxu0_ex0_start:rvaxu0_ex0_end] ex0_instr_dat;
   wire [0:`THREADS-1] 		       ex1_credit_free;

   wire 			       ex0_ord_d;
   wire 			       ex0_ord_q;
   wire [0:`THREADS-1] 		       ex1_ord_vld_d;
   wire [0:`THREADS-1] 		       ex1_ord_vld_q;
   wire [0:`THREADS-1] 		       ex2_ord_vld_d;
   wire [0:`THREADS-1] 		       ex2_ord_vld_q;
   wire [0:`THREADS-1] 		       ex3_ord_flush_d;
   wire [0:`THREADS-1] 		       ex3_ord_flush_q;

   //------------------------------------------------------------------------------------------------------------
   // EX0
   //------------------------------------------------------------------------------------------------------------

   wire 			       rv_ex0_act;

   wire [0:`THREADS-1] 		       ex0_vld_d;
   wire [0:`ITAG_SIZE_ENC-1] 	       ex0_itag_d;

   wire [0:`THREADS-1] 		       ex0_vld_q;
   wire [0:`ITAG_SIZE_ENC-1] 	       ex0_itag_q;

   //------------------------------------------------------------------------------------------------------------
   // Itag busses and shadow
   //------------------------------------------------------------------------------------------------------------

   wire [0:`THREADS-1] 		       lq_rv_itag1_rst_vld;
   wire [0:`ITAG_SIZE_ENC-1] 	       lq_rv_itag1_rst;

   wire [0:`THREADS-1] 		       q_ord_complete;
   wire [0:`THREADS-1] 		       ex3_ord_flush;

   wire 			       lq_rv_itag1_cord;

   wire [0:`THREADS*`ITAG_SIZE_ENC-1] 		       cp_next_itag_q;


   //------------------------------------------------------------------------------------------------------------
   // Scan Chains
   //------------------------------------------------------------------------------------------------------------

   parameter                      rvs_offset = 0 + 0;
   parameter                      cp_flush_offset = rvs_offset + 1;
   parameter                      ex0_ord_offset = cp_flush_offset + `THREADS;
   parameter                      ex1_ord_vld_offset = ex0_ord_offset + 1;
   parameter                      ex2_ord_vld_offset = ex1_ord_vld_offset + `THREADS;
   parameter                      ex3_ord_flush_offset = ex2_ord_vld_offset + `THREADS;
   parameter                      ex0_vld_offset = ex3_ord_flush_offset + `THREADS;
   parameter                      ex0_itag_offset = ex0_vld_offset + `THREADS;
   parameter                      axu0_rv_itag_vld_offset =  ex0_itag_offset + `ITAG_SIZE_ENC;
   parameter                      axu0_rv_itag_abort_offset = axu0_rv_itag_vld_offset + `THREADS;
   parameter                      axu0_rv_itag_offset = axu0_rv_itag_abort_offset + 1;
   parameter                      cp_next_itag_offset = axu0_rv_itag_offset + `ITAG_SIZE_ENC;

   parameter                      scan_right = cp_next_itag_offset + `THREADS * `ITAG_SIZE_ENC;
   wire [0:scan_right-1] 	       siv;
   wire [0:scan_right-1] 	       sov;

   wire 			       func_sl_thold_0;
   wire 			       func_sl_thold_0_b;
   wire 			       sg_0;
   wire 			       force_t;

   //unused
   (* analysis_not_referenced="true" *)
   wire [0:`THREADS-1] 		       q_ord_tid;
   (* analysis_not_referenced="true" *)
   wire [0:`THREADS-1] 		       rv1_other_ilat0_vld_out;
   (* analysis_not_referenced="true" *)
   wire [0:`ITAG_SIZE_ENC-1] 	       rv1_other_ilat0_itag_out;
   (* analysis_not_referenced="true" *)
   wire [0:3] 	       		       rv1_instr_ilat;
   (* analysis_not_referenced="true" *)
   wire [0:`THREADS-1] 		       rv1_instr_ilat0_vld;
   (* analysis_not_referenced="true" *)
   wire [0:`THREADS-1] 		       rv1_instr_ilat1_vld;
   (* analysis_not_referenced="true" *)
   wire                                rvs_empty;
   (* analysis_not_referenced="true" *)
   wire                                rv1_instr_is_brick;


   //------------------------------------------------------------------------------------------------------------
   // Pervasive
   //------------------------------------------------------------------------------------------------------------
   assign tiup = 1'b1;

   //------------------------------------------------------------------------------------------------------------
   // RV Entry
   //------------------------------------------------------------------------------------------------------------

   //Don't hit on cracked store GPR valids
   assign rv0_i0_s1_v       = rv0_instr_i0_s1_v & ~rv0_instr_i0_isStore;
   assign rv0_i0_s2_v       = rv0_instr_i0_s2_v & ~rv0_instr_i0_isStore;
   assign rv0_i0_s1_dep_hit = rv0_instr_i0_s1_dep_hit & ~rv0_instr_i0_isStore;
   assign rv0_i0_s2_dep_hit = rv0_instr_i0_s2_dep_hit & ~rv0_instr_i0_isStore;

   assign rv0_i1_s1_v       = rv0_instr_i1_s1_v & ~rv0_instr_i1_isStore;
   assign rv0_i1_s2_v       = rv0_instr_i1_s2_v & ~rv0_instr_i1_isStore;
   assign rv0_i1_s1_dep_hit = rv0_instr_i1_s1_dep_hit & ~rv0_instr_i1_isStore;
   assign rv0_i1_s2_dep_hit = rv0_instr_i1_s2_dep_hit & ~rv0_instr_i1_isStore;

   assign rv0_instr_i0_dat = {
			      rv0_i0_s1_v,
			      rv0_instr_i0_s1_p,
			      rv0_i0_s2_v,
			      rv0_instr_i0_s2_p,
			      rv0_instr_i0_s3_v,
			      rv0_instr_i0_s3_p};

   assign rv0_instr_i0_dat_ex0 = {rv0_instr_i0_instr,
			      rv0_instr_i0_ucode,
			      rv0_instr_i0_t1_v,
			      rv0_instr_i0_t1_p,
			      rv0_instr_i0_t2_p,
			      rv0_instr_i0_t3_p,
			      rv0_instr_i0_spare};

   assign rv0_instr_i1_dat = {
			      rv0_i1_s1_v,
			      rv0_instr_i1_s1_p,
			      rv0_i1_s2_v,
			      rv0_instr_i1_s2_p,
			      rv0_instr_i1_s3_v,
			      rv0_instr_i1_s3_p};

   assign rv0_instr_i1_dat_ex0 = {rv0_instr_i1_instr,
			      rv0_instr_i1_ucode,
			      rv0_instr_i1_t1_v,
			      rv0_instr_i1_t1_p,
			      rv0_instr_i1_t2_p,
			      rv0_instr_i1_t3_p,
			      rv0_instr_i1_spare};


   //------------------------------------------------------------------------------------------------------------
   // axu0 Reservation Stations
   //------------------------------------------------------------------------------------------------------------
   assign rv0_instr_i0_spec = 1'b0;
   assign rv0_instr_i0_is_brick = 1'b0;
   assign rv0_instr_i0_brick = {3{1'b0}};
   assign rv0_instr_i0_ilat = {4{1'b1}};
   assign rv0_instr_i1_spec = 1'b0;
   assign rv0_instr_i1_is_brick = 1'b0;
   assign rv0_instr_i1_brick = {3{1'b0}};
   assign rv0_instr_i1_ilat = {4{1'b1}};

   assign lq_rv_itag1_cord = 1'b0;

   assign rv1_other_ilat0_vld = {`THREADS{1'b0}};
   assign rv1_other_ilat0_itag = {`ITAG_SIZE_ENC{1'b0}};

   assign q_ord_complete = {`THREADS{axu0_rv_ord_complete}} | ex3_ord_flush;

   assign rv0_instr_i0_rte = rv0_instr_i0_rte_axu0;
   assign rv0_instr_i1_rte = rv0_instr_i1_rte_axu0;


   rv_station #(.q_dat_width_g(rvaxu0_size), .q_dat_ex0_width_g(rvaxu0_ex0_size), .q_num_entries_g(`RV_AXU0_ENTRIES), .q_itag_busses_g(num_itag_busses_g), .q_noilat0_g(1'b1), .q_brick_g(1'b0))
   rvs(
       .cp_flush(cp_flush),
       .cp_next_itag(cp_next_itag_q),

       .rv0_instr_i0_vld(rv0_instr_i0_vld),
       .rv0_instr_i0_rte(rv0_instr_i0_rte),
       .rv0_instr_i1_vld(rv0_instr_i1_vld),
       .rv0_instr_i1_rte(rv0_instr_i1_rte),

       .rv0_instr_i0_dat(rv0_instr_i0_dat),
       .rv0_instr_i0_dat_ex0(rv0_instr_i0_dat_ex0),
       .rv0_instr_i0_itag(rv0_instr_i0_itag),
       .rv0_instr_i0_ord(rv0_instr_i0_ord),
       .rv0_instr_i0_cord(rv0_instr_i0_cord),
       .rv0_instr_i0_spec(rv0_instr_i0_spec),
       .rv0_instr_i0_s1_dep_hit(rv0_i0_s1_dep_hit),
       .rv0_instr_i0_s1_itag(rv0_instr_i0_s1_itag),
       .rv0_instr_i0_s2_dep_hit(rv0_i0_s2_dep_hit),
       .rv0_instr_i0_s2_itag(rv0_instr_i0_s2_itag),
       .rv0_instr_i0_s3_dep_hit(rv0_instr_i0_s3_dep_hit),
       .rv0_instr_i0_s3_itag(rv0_instr_i0_s3_itag),
       .rv0_instr_i0_is_brick(rv0_instr_i0_is_brick),
       .rv0_instr_i0_brick(rv0_instr_i0_brick),
       .rv0_instr_i0_ilat(rv0_instr_i0_ilat),
       .rv0_instr_i0_s1_v(rv0_i0_s1_v),
       .rv0_instr_i0_s2_v(rv0_i0_s2_v),
       .rv0_instr_i0_s3_v(rv0_instr_i0_s3_v),

       .rv0_instr_i1_dat(rv0_instr_i1_dat),
       .rv0_instr_i1_dat_ex0(rv0_instr_i1_dat_ex0),
       .rv0_instr_i1_itag(rv0_instr_i1_itag),
       .rv0_instr_i1_ord(rv0_instr_i1_ord),
       .rv0_instr_i1_cord(rv0_instr_i1_cord),
       .rv0_instr_i1_spec(rv0_instr_i1_spec),
       .rv0_instr_i1_s1_dep_hit(rv0_i1_s1_dep_hit),
       .rv0_instr_i1_s1_itag(rv0_instr_i1_s1_itag),
       .rv0_instr_i1_s2_dep_hit(rv0_i1_s2_dep_hit),
       .rv0_instr_i1_s2_itag(rv0_instr_i1_s2_itag),
       .rv0_instr_i1_s3_dep_hit(rv0_instr_i1_s3_dep_hit),
       .rv0_instr_i1_s3_itag(rv0_instr_i1_s3_itag),
       .rv0_instr_i1_is_brick(rv0_instr_i1_is_brick),
       .rv0_instr_i1_brick(rv0_instr_i1_brick),
       .rv0_instr_i1_ilat(rv0_instr_i1_ilat),
       .rv0_instr_i1_s1_v(rv0_i1_s1_v),
       .rv0_instr_i1_s2_v(rv0_i1_s2_v),
       .rv0_instr_i1_s3_v(rv0_instr_i1_s3_v),

       .rv1_instr_vld(rv1_instr_v),
       .rv1_instr_dat(rv1_instr_dat),
       .rv1_instr_ord(rv1_instr_ord),
       .rv1_instr_spec(rv1_instr_spec),
       .rv1_instr_itag(rv1_instr_itag),
       .rv1_instr_s1_itag(rv1_instr_s1_itag),
       .rv1_instr_s2_itag(rv1_instr_s2_itag),
       .rv1_instr_s3_itag(rv1_instr_s3_itag),
       .rv1_instr_is_brick(rv1_instr_is_brick),
       .ex0_instr_dat(ex0_instr_dat),
       .ex1_credit_free(ex1_credit_free),

       .rv1_other_ilat0_vld(rv1_other_ilat0_vld),
       .rv1_other_ilat0_itag(rv1_other_ilat0_itag),
       .q_ord_tid(q_ord_tid),
       .rv1_other_ilat0_vld_out(rv1_other_ilat0_vld_out),
       .rv1_other_ilat0_itag_out(rv1_other_ilat0_itag_out),
       .rv1_instr_ilat(rv1_instr_ilat),
       .rv1_instr_ilat0_vld(rv1_instr_ilat0_vld),
       .rv1_instr_ilat1_vld(rv1_instr_ilat1_vld),
       .rvs_empty(rvs_empty),
       .rvs_perf_bus(axu0_rvs_perf_bus),
       .rvs_dbg_bus(axu0_rvs_dbg_bus),

       .q_hold_all(axu0_rv_hold_all),
       .q_ord_complete(q_ord_complete),

       .fx0_rv_itag  (fx0_rv_ext_itag),
       .fx1_rv_itag  (fx1_rv_ext_itag),
       .lq_rv_itag0  (lq_rv_ext_itag0),
       .lq_rv_itag1  (lq_rv_ext_itag1),
       .lq_rv_itag2  (lq_rv_ext_itag2),
       .axu0_rv_itag (axu0_rv_itag),
       .axu1_rv_itag (axu1_rv_itag),
       .fx0_rv_itag_vld  (fx0_rv_ext_itag_vld),
       .fx1_rv_itag_vld  (fx1_rv_ext_itag_vld),
       .lq_rv_itag0_vld  (lq_rv_ext_itag0_vld),
       .lq_rv_itag1_vld  (lq_rv_ext_itag1_vld),
       .lq_rv_itag2_vld  (lq_rv_ext_itag2_vld),
       .axu0_rv_itag_vld (axu0_rv_itag_vld),
       .axu1_rv_itag_vld (axu1_rv_itag_vld),
       .fx0_rv_itag_abort  (fx0_rv_ext_itag_abort),
       .fx1_rv_itag_abort  (fx1_rv_ext_itag_abort),
       .lq_rv_itag0_abort  (lq_rv_ext_itag0_abort),
       .lq_rv_itag1_abort  (lq_rv_ext_itag1_abort),
       .axu0_rv_itag_abort (axu0_rv_itag_abort),
       .axu1_rv_itag_abort (axu1_rv_itag_abort),

       .xx_rv_ex2_s1_abort(axu0_rv_ex2_s1_abort),
       .xx_rv_ex2_s2_abort(axu0_rv_ex2_s2_abort),
       .xx_rv_ex2_s3_abort(axu0_rv_ex2_s3_abort),


       .lq_rv_itag1_restart(lq_rv_itag1_restart),
       .lq_rv_itag1_hold(lq_rv_itag1_hold),
       .lq_rv_itag1_cord(lq_rv_itag1_cord),
       .lq_rv_itag1_rst_vld(lq_rv_itag1_rst_vld),
       .lq_rv_itag1_rst(lq_rv_itag1_rst),
       .lq_rv_clr_hold(lq_rv_clr_hold),

       .vdd(vdd),
       .gnd(gnd),
       .nclk(nclk),
       .sg_1(sg_1),
       .func_sl_thold_1(func_sl_thold_1),
       .ccflush_dc(ccflush_dc),
       .act_dis(act_dis),
       .clkoff_b(clkoff_b),
       .d_mode(d_mode),
       .delay_lclkr(delay_lclkr),
       .mpw1_b(mpw1_b),
       .mpw2_b(mpw2_b),
       .scan_in(siv[rvs_offset]),
       .scan_out(sov[rvs_offset])
       );

   assign rv_iu_axu0_credit_free = ex1_credit_free;
   assign rv_axu0_vld = rv1_instr_v;

   assign rv_axu0_s1_v = rv1_instr_dat[rvaxu0_s1_v_start];
   assign rv_axu0_s1_p = rv1_instr_dat[rvaxu0_s1_p_start:rvaxu0_s1_p_stop];
   assign rv_axu0_s2_v = rv1_instr_dat[rvaxu0_s2_v_start];
   assign rv_axu0_s2_p = rv1_instr_dat[rvaxu0_s2_p_start:rvaxu0_s2_p_stop];
   assign rv_axu0_s3_v = rv1_instr_dat[rvaxu0_s3_v_start];
   assign rv_axu0_s3_p = rv1_instr_dat[rvaxu0_s3_p_start:rvaxu0_s3_p_stop];

   assign ex0_vld_d = rv1_instr_v & (~cp_flush_q);
   assign ex0_itag_d = rv1_instr_itag;
   assign rv_axu0_ex0_instr = ex0_instr_dat[rvaxu0_instr_start:rvaxu0_instr_stop];
   assign rv_axu0_ex0_ucode = ex0_instr_dat[rvaxu0_ucode_start:rvaxu0_ucode_stop];
   assign rv_axu0_ex0_t1_v = ex0_instr_dat[rvaxu0_t1_v_start];
   assign rv_axu0_ex0_t1_p = ex0_instr_dat[rvaxu0_t1_p_start:rvaxu0_t1_p_stop];
   assign rv_axu0_ex0_t2_p = ex0_instr_dat[rvaxu0_t2_p_start:rvaxu0_t2_p_stop];
   assign rv_axu0_ex0_t3_p = ex0_instr_dat[rvaxu0_t3_p_start:rvaxu0_t3_p_stop];

   assign rv_ex0_act = |(rv1_instr_v);

   assign rv_axu0_ex0_itag = ex0_itag_q;

   //------------------------------------------------------------------------------------------------------------
   // Itag busses
   //------------------------------------------------------------------------------------------------------------

   // Restart Itag and Valid from LQ.  This is separate because it could be early (not latched)
   assign lq_rv_itag1_rst_vld = lq_rv_itag1_vld;
   assign lq_rv_itag1_rst = lq_rv_itag1;




   assign ex0_ord_d = rv1_instr_ord;
   assign ex1_ord_vld_d   = {`THREADS{ex0_ord_q}} & ex0_vld_q & (~cp_flush_q);
   assign ex2_ord_vld_d   = ex1_ord_vld_q & (~cp_flush_q);
   assign ex3_ord_flush_d = ex2_ord_vld_q & {`THREADS{(axu0_rv_ex2_s1_abort | axu0_rv_ex2_s2_abort | axu0_rv_ex2_s3_abort )}} ;
   assign ex3_ord_flush   = ex3_ord_flush_q & (~cp_flush_q);

   //------------------------------------------------------------------------------------------------------------
   // Pipeline Latches
   //------------------------------------------------------------------------------------------------------------


      tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) cp_flush_reg(
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
         .scin(siv[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
         .scout(sov[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
         .din(cp_flush),
         .dout(cp_flush_q)
      );


      tri_rlmlatch_p #(.INIT(0)) ex0_ord_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(rv_ex0_act),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[ex0_ord_offset]),
         .scout(sov[ex0_ord_offset]),
         .din(ex0_ord_d),
         .dout(ex0_ord_q)
      );


      tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ex1_ord_vld_reg(
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
         .scin(siv[ex1_ord_vld_offset:ex1_ord_vld_offset + `THREADS - 1]),
         .scout(sov[ex1_ord_vld_offset:ex1_ord_vld_offset + `THREADS - 1]),
         .din(ex1_ord_vld_d),
         .dout(ex1_ord_vld_q)
      );


      tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ex2_ord_vld_reg(
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
         .scin(siv[ex2_ord_vld_offset:ex2_ord_vld_offset + `THREADS - 1]),
         .scout(sov[ex2_ord_vld_offset:ex2_ord_vld_offset + `THREADS - 1]),
         .din(ex2_ord_vld_d),
         .dout(ex2_ord_vld_q)
      );


      tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ex3_ord_flush_reg(
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
         .scin(siv[ex3_ord_flush_offset:ex3_ord_flush_offset + `THREADS - 1]),
         .scout(sov[ex3_ord_flush_offset:ex3_ord_flush_offset + `THREADS - 1]),
         .din(ex3_ord_flush_d),
         .dout(ex3_ord_flush_q)
      );




      tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ex0_vld_reg(
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
         .scin(siv[ex0_vld_offset:ex0_vld_offset + `THREADS - 1]),
         .scout(sov[ex0_vld_offset:ex0_vld_offset + `THREADS - 1]),
         .din(ex0_vld_d),
         .dout(ex0_vld_q)
      );


      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) ex0_itag_reg(
         .vd(vdd),
         .gd(gnd),
         .nclk(nclk),
         .act(rv_ex0_act),
         .thold_b(func_sl_thold_0_b),
         .sg(sg_0),
         .force_t(force_t),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .d_mode(d_mode),
         .scin(siv[ex0_itag_offset:ex0_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[ex0_itag_offset:ex0_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(ex0_itag_d),
         .dout(ex0_itag_q)
      );


      tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) axu0_rv_itag_vld_reg(
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
         .scin(siv[axu0_rv_itag_vld_offset:axu0_rv_itag_vld_offset + `THREADS - 1]),
         .scout(sov[axu0_rv_itag_vld_offset:axu0_rv_itag_vld_offset + `THREADS - 1]),
         .din(axu0_rv_itag_vld),
         .dout(axu0_rv_ext_itag_vld)
      );

      tri_rlmlatch_p #( .INIT(0)) axu0_rv_itag_abort_reg(
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
         .scin(siv[axu0_rv_itag_abort_offset]),
         .scout(sov[axu0_rv_itag_abort_offset]),
         .din(axu0_rv_itag_abort),
         .dout(axu0_rv_ext_itag_abort)
      );


      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) axu0_rv_itag_reg(
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
         .scin(siv[axu0_rv_itag_offset:axu0_rv_itag_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[axu0_rv_itag_offset:axu0_rv_itag_offset + `ITAG_SIZE_ENC - 1]),
         .din(axu0_rv_itag),
         .dout(axu0_rv_ext_itag)
      );

/*
      tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) lq_rv_itag0_vld_reg(
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
         .scin(siv[lq_rv_itag0_vld_offset:lq_rv_itag0_vld_offset + `THREADS - 1]),
         .scout(sov[lq_rv_itag0_vld_offset:lq_rv_itag0_vld_offset + `THREADS - 1]),
         .din(lq_rv_itag0_vld_d),
         .dout(lq_rv_itag0_vld_q)
      );


      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) lq_rv_itag0_reg(
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
         .scin(siv[lq_rv_itag0_offset:lq_rv_itag0_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[lq_rv_itag0_offset:lq_rv_itag0_offset + `ITAG_SIZE_ENC - 1]),
         .din(lq_rv_itag0),
         .dout(lq_rv_itag0_q)
      );


      tri_rlmlatch_p #(.INIT(0)) lq_rv_itag0_spec_reg(
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
         .scin(siv[lq_rv_itag0_spec_offset]),
         .scout(sov[lq_rv_itag0_spec_offset]),
         .din(lq_rv_itag0_spec),
         .dout(lq_rv_itag0_spec_q)
      );


      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) lq_rv_itag1_reg(
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
         .scin(siv[lq_rv_itag1_offset:lq_rv_itag1_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[lq_rv_itag1_offset:lq_rv_itag1_offset + `ITAG_SIZE_ENC - 1]),
         .din(lq_rv_itag1),
         .dout(lq_rv_itag1_q)
      );


      tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) lq_rv_itag2_vld_reg(
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
         .scin(siv[lq_rv_itag2_vld_offset:lq_rv_itag2_vld_offset + `THREADS - 1]),
         .scout(sov[lq_rv_itag2_vld_offset:lq_rv_itag2_vld_offset + `THREADS - 1]),
         .din(lq_rv_itag2_vld_d),
         .dout(lq_rv_itag2_vld_q)
      );


      tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) lq_rv_itag2_reg(
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
         .scin(siv[lq_rv_itag2_offset:lq_rv_itag2_offset + `ITAG_SIZE_ENC - 1]),
         .scout(sov[lq_rv_itag2_offset:lq_rv_itag2_offset + `ITAG_SIZE_ENC - 1]),
         .din(lq_rv_itag2),
         .dout(lq_rv_itag2_q)
      );
  */
   tri_rlmreg_p #(.WIDTH(`THREADS*`ITAG_SIZE_ENC), .INIT(0))
   cp_next_itag_reg(
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
		    .scin(siv[cp_next_itag_offset :cp_next_itag_offset + `THREADS*`ITAG_SIZE_ENC-1]),
		    .scout(sov[cp_next_itag_offset:cp_next_itag_offset + `THREADS*`ITAG_SIZE_ENC-1]),
		    .din(cp_next_itag),
		    .dout(cp_next_itag_q)
		    );


   //------------------------------------------------------------------------------------------------------------
   // Scan Connections
   //------------------------------------------------------------------------------------------------------------

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


   tri_lcbor perv_lcbor(
			.clkoff_b(clkoff_b),
			.thold(func_sl_thold_0),
			.sg(sg_0),
			.act_dis(act_dis),
			.force_t(force_t),
			.thold_b(func_sl_thold_0_b)
			);

endmodule // rv_axu0_rvs
