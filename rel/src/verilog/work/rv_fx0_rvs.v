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
// Title:   rv_fx0_rvs.vhdl
// Desc:    LQ Reservation Station
//
//-----------------------------------------------------------------------------------------------------

module rv_fx0_rvs(
`include "tri_a2o.vh"

   //------------------------------------------------------------------------------------------------------------
   // Instructions from RV_DEP
   //------------------------------------------------------------------------------------------------------------
   input [0:`THREADS-1]            rv0_instr_i0_vld,
   input 			   rv0_instr_i0_rte_fx0,
   input [0:`THREADS-1] 	   rv0_instr_i1_vld,
   input 			   rv0_instr_i1_rte_fx0,

   input [0:31] 		   rv0_instr_i0_instr,
   input [62-`EFF_IFAR_WIDTH:61]   rv0_instr_i0_ifar,
   input [0:2] 			   rv0_instr_i0_ucode,
   input [0:`UCODE_ENTRIES_ENC-1]  rv0_instr_i0_ucode_cnt,
   input [0:`ITAG_SIZE_ENC-1] 	   rv0_instr_i0_itag,
   input 			   rv0_instr_i0_ord,
   input 			   rv0_instr_i0_cord,
   input 			   rv0_instr_i0_t1_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i0_t1_p,
   input [0:2] 			   rv0_instr_i0_t1_t,
   input 			   rv0_instr_i0_t2_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i0_t2_p,
   input [0:2] 			   rv0_instr_i0_t2_t,
   input 			   rv0_instr_i0_t3_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i0_t3_p,
   input [0:2] 			   rv0_instr_i0_t3_t,
   input 			   rv0_instr_i0_s1_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i0_s1_p,
   input [0:2] 			   rv0_instr_i0_s1_t,
   input 			   rv0_instr_i0_s2_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i0_s2_p,
   input [0:2] 			   rv0_instr_i0_s2_t,
   input 			   rv0_instr_i0_s3_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i0_s3_p,
   input [0:2] 			   rv0_instr_i0_s3_t,
   input [0:3] 			   rv0_instr_i0_ilat,
   input [0:3] 			   rv0_instr_i0_spare,
   input 			   rv0_instr_i0_is_brick,
   input [0:2] 			   rv0_instr_i0_brick,
   input [0:`G_BRANCH_LEN-1] 	   rv0_instr_i0_branch,

   input [0:31] 		   rv0_instr_i1_instr,
   input [62-`EFF_IFAR_WIDTH:61]   rv0_instr_i1_ifar,
   input [0:2] 			   rv0_instr_i1_ucode,
   input [0:`UCODE_ENTRIES_ENC-1]  rv0_instr_i1_ucode_cnt,
   input [0:`ITAG_SIZE_ENC-1] 	   rv0_instr_i1_itag,
   input 			   rv0_instr_i1_ord,
   input 			   rv0_instr_i1_cord,
   input 			   rv0_instr_i1_t1_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i1_t1_p,
   input [0:2] 			   rv0_instr_i1_t1_t,
   input 			   rv0_instr_i1_t2_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i1_t2_p,
   input [0:2] 			   rv0_instr_i1_t2_t,
   input 			   rv0_instr_i1_t3_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i1_t3_p,
   input [0:2] 			   rv0_instr_i1_t3_t,
   input 			   rv0_instr_i1_s1_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i1_s1_p,
   input [0:2] 			   rv0_instr_i1_s1_t,
   input 			   rv0_instr_i1_s2_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i1_s2_p,
   input [0:2] 			   rv0_instr_i1_s2_t,
   input 			   rv0_instr_i1_s3_v,
   input [0:`GPR_POOL_ENC-1] 	   rv0_instr_i1_s3_p,
   input [0:2] 			   rv0_instr_i1_s3_t,
   input [0:3] 			   rv0_instr_i1_ilat,
   input [0:3] 			   rv0_instr_i1_spare,
   input 			   rv0_instr_i1_is_brick,
   input [0:2] 			   rv0_instr_i1_brick,
   input [0:`G_BRANCH_LEN-1] 	   rv0_instr_i1_branch,

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
   output [0:`THREADS-1] 	   rv_iu_fx0_credit_free,

   //------------------------------------------------------------------------------------------------------------
   // Machine zap interface
   //------------------------------------------------------------------------------------------------------------
   input [0:`THREADS-1] 	   cp_flush,
   input [0:`THREADS*`ITAG_SIZE_ENC-1] 	   cp_next_itag,

   //------------------------------------------------------------------------------------------------------------
   // Interface to FX0
   //------------------------------------------------------------------------------------------------------------
   output [0:`THREADS-1] 	   rv_byp_fx0_vld,
   output [0:`ITAG_SIZE_ENC-1] 	   rv_byp_fx0_itag,
   output 			   rv_byp_fx0_ord,
   output 			   rv_byp_fx0_t1_v,
   output [0:2] 		   rv_byp_fx0_t1_t,
   output 			   rv_byp_fx0_t2_v,
   output [0:2] 		   rv_byp_fx0_t2_t,
   output 			   rv_byp_fx0_t3_v,
   output [0:2] 		   rv_byp_fx0_t3_t,
   output [0:2] 		   rv_byp_fx0_s1_t,
   output [0:2] 		   rv_byp_fx0_s2_t,
   output [0:2] 		   rv_byp_fx0_s3_t,
   output [0:3] 		   rv_byp_fx0_ilat,

   output [0:`THREADS-1] 	   rv_fx0_vld,
   output 			   rv_fx0_s1_v,
   output [0:`GPR_POOL_ENC-1] 	   rv_fx0_s1_p,
   output 			   rv_fx0_s2_v,
   output [0:`GPR_POOL_ENC-1] 	   rv_fx0_s2_p,
   output 			   rv_fx0_s3_v,
   output [0:`GPR_POOL_ENC-1] 	   rv_fx0_s3_p,

   output [0:`ITAG_SIZE_ENC-1] 	   rv_fx0_ex0_itag,
   output [0:31] 		   rv_fx0_ex0_instr,
   output [62-`EFF_IFAR_WIDTH:61]  rv_fx0_ex0_ifar,
   output [0:2] 		   rv_fx0_ex0_ucode,
   output [0:`UCODE_ENTRIES_ENC-1] rv_fx0_ex0_ucode_cnt,
   output 			   rv_fx0_ex0_ord,
   output 			   rv_fx0_ex0_t1_v,
   output [0:`GPR_POOL_ENC-1] 	   rv_fx0_ex0_t1_p,
   output [0:2] 		   rv_fx0_ex0_t1_t,
   output 			   rv_fx0_ex0_t2_v,
   output [0:`GPR_POOL_ENC-1] 	   rv_fx0_ex0_t2_p,
   output [0:2] 		   rv_fx0_ex0_t2_t,
   output 			   rv_fx0_ex0_t3_v,
   output [0:`GPR_POOL_ENC-1] 	   rv_fx0_ex0_t3_p,
   output [0:2] 		   rv_fx0_ex0_t3_t,
   output 			   rv_fx0_ex0_s1_v,
   output 			   rv_fx0_ex0_s2_v,
   output [0:2] 		   rv_fx0_ex0_s2_t,
   output 			   rv_fx0_ex0_s3_v,
   output [0:2] 		   rv_fx0_ex0_s3_t,
   output [0:`G_BRANCH_LEN-1] 	   rv_fx0_ex0_branch,

   output [0:`ITAG_SIZE_ENC-1] 	   rv_byp_fx0_s1_itag,
   output [0:`ITAG_SIZE_ENC-1] 	   rv_byp_fx0_s2_itag,
   output [0:`ITAG_SIZE_ENC-1] 	   rv_byp_fx0_s3_itag,
   output                          rv_byp_fx0_ex0_is_brick,

   //------------------------------------------------------------------------------------------------------------
   // RV Release bus
   //------------------------------------------------------------------------------------------------------------

   input                           fx0_rv_ex2_s1_abort,
   input                           fx0_rv_ex2_s2_abort,
   input                           fx0_rv_ex2_s3_abort,


   input 			   fx0_rv_itag_abort,
   input 			   fx1_rv_itag_abort,
   input 			   lq_rv_ext_itag0_abort,
   input 			   lq_rv_ext_itag1_abort,
   input 			   axu1_rv_ext_itag_abort,
   input 			   axu0_rv_ext_itag_abort,

   input [0:`THREADS-1] 	   fx0_rv_itag_vld,
   input [0:`ITAG_SIZE_ENC-1] 	   fx0_rv_itag,

   input [0:`THREADS-1] 	   fx1_rv_itag_vld,
   input [0:`ITAG_SIZE_ENC-1] 	   fx1_rv_itag,

   input [0:`THREADS-1] 	   axu0_rv_ext_itag_vld,
   input [0:`ITAG_SIZE_ENC-1] 	   axu0_rv_ext_itag,

   input [0:`THREADS-1] 	   axu1_rv_ext_itag_vld,
   input [0:`ITAG_SIZE_ENC-1] 	   axu1_rv_ext_itag,

   input [0:`THREADS-1] 	   lq_rv_ext_itag0_vld,
   input [0:`ITAG_SIZE_ENC-1] 	   lq_rv_ext_itag0,

   input [0:`THREADS-1] 	   lq_rv_itag1_vld,
   input [0:`ITAG_SIZE_ENC-1] 	   lq_rv_itag1,
   input 			   lq_rv_itag1_restart,
   input 			   lq_rv_itag1_hold,
   input [0:`THREADS-1] 	   lq_rv_ext_itag1_vld,
   input [0:`ITAG_SIZE_ENC-1] 	   lq_rv_ext_itag1,

   input [0:`THREADS-1] 	   lq_rv_ext_itag2_vld,
   input [0:`ITAG_SIZE_ENC-1] 	   lq_rv_ext_itag2,

   input [0:`THREADS-1] 	   lq_rv_clr_hold,

   input [0:`THREADS-1] 	   fx0_rv_ord_complete,
   input 			   fx0_rv_hold_all,
   output [0:`THREADS-1] 	   fx0_rv_ord_tid,

   output [0:`THREADS-1] 	   rv_byp_fx0_ilat0_vld,
   output [0:`THREADS-1] 	   rv_byp_fx0_ilat1_vld,

   input [0:`THREADS-1] 	   rv1_fx1_ilat0_vld,
   input [0:`ITAG_SIZE_ENC-1] 	   rv1_fx1_ilat0_itag,
   output [0:`THREADS-1] 	   rv1_fx0_ilat0_vld,
   output [0:`ITAG_SIZE_ENC-1] 	   rv1_fx0_ilat0_itag,

   //------------------------------------------------------------------------------------------------------------
   // Pervasive
   //------------------------------------------------------------------------------------------------------------
   output [0:8*`THREADS-1]         fx0_rvs_perf_bus,
   output [0:31]                   fx0_rvs_dbg_bus,
   inout 			   vdd,
   inout 			   gnd,
   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) // nclk
   input [0:`NCLK_WIDTH-1] 	   nclk,
   input 			   func_sl_thold_1,
   input 			   sg_1,
   input 			   clkoff_b,
   input 			   act_dis,
   input 			   ccflush_dc,
   input 			   d_mode,
   input 			   delay_lclkr,
   input 			   mpw1_b,
   input 			   mpw2_b,
   input 			   scan_in,

   output 			   scan_out


		  );

   parameter                      num_itag_busses_g = 7;


   //------------------------------------------------------------------------------------------------------------
   // RV FX0 RVS INSTR ISSUE
   //------------------------------------------------------------------------------------------------------------
   parameter              rvfx0_ex0_start = 0;
   parameter              rvfx0_instr_start = rvfx0_ex0_start;
   parameter              rvfx0_instr_stop = (rvfx0_instr_start + (32)) - 1;
   parameter              rvfx0_ifar_start = rvfx0_instr_stop + 1;
   parameter              rvfx0_ifar_stop = (rvfx0_ifar_start + (`EFF_IFAR_WIDTH)) - 1;
   parameter              rvfx0_ucode_start = rvfx0_ifar_stop + 1;
   parameter              rvfx0_ucode_stop = (rvfx0_ucode_start + (3)) - 1;
   parameter              rvfx0_ucode_cnt_start = rvfx0_ucode_stop + 1;
   parameter              rvfx0_ucode_cnt_stop = (rvfx0_ucode_cnt_start + (`UCODE_ENTRIES_ENC)) - 1;
   parameter              rvfx0_t1_p_start = rvfx0_ucode_cnt_stop + 1;
   parameter              rvfx0_t1_p_stop = (rvfx0_t1_p_start + (`GPR_POOL_ENC)) - 1;
   parameter              rvfx0_t2_p_start = rvfx0_t1_p_stop + 1;
   parameter              rvfx0_t2_p_stop = (rvfx0_t2_p_start + (`GPR_POOL_ENC)) - 1;
   parameter              rvfx0_t3_p_start = rvfx0_t2_p_stop + 1;
   parameter              rvfx0_t3_p_stop = (rvfx0_t3_p_start + (`GPR_POOL_ENC)) - 1;
   parameter              rvfx0_branch_start = rvfx0_t3_p_stop + 1;
   parameter              rvfx0_branch_stop = (rvfx0_branch_start + (`G_BRANCH_LEN)) - 1;
   parameter              rvfx0_spare_start = rvfx0_branch_stop + 1;
   parameter              rvfx0_spare_stop = (rvfx0_spare_start + (4)) - 1;

   parameter              rvfx0_ex0_end = rvfx0_spare_stop;

   parameter              rvfx0_ex0_size = rvfx0_ex0_end + 1;


   parameter              rvfx0_start = 0;
   parameter              rvfx0_t1_v_start = rvfx0_start;
   parameter              rvfx0_t1_v_stop = (rvfx0_t1_v_start + (1)) - 1;
   parameter              rvfx0_t1_t_start = rvfx0_t1_v_stop + 1;
   parameter              rvfx0_t1_t_stop = (rvfx0_t1_t_start + (3)) - 1;
   parameter              rvfx0_t2_v_start = rvfx0_t1_t_stop + 1;
   parameter              rvfx0_t2_v_stop = (rvfx0_t2_v_start + (1)) - 1;
   parameter              rvfx0_t2_t_start = rvfx0_t2_v_stop + 1;
   parameter              rvfx0_t2_t_stop = (rvfx0_t2_t_start + (3)) - 1;
   parameter              rvfx0_t3_v_start = rvfx0_t2_t_stop + 1;
   parameter              rvfx0_t3_v_stop = (rvfx0_t3_v_start + (1)) - 1;
   parameter              rvfx0_t3_t_start = rvfx0_t3_v_stop + 1;
   parameter              rvfx0_t3_t_stop = (rvfx0_t3_t_start + (3)) - 1;
   parameter              rvfx0_s1_v_start = rvfx0_t3_t_stop + 1;
   parameter              rvfx0_s1_v_stop = (rvfx0_s1_v_start + (1)) - 1;
   parameter              rvfx0_s1_p_start = rvfx0_s1_v_stop + 1;
   parameter              rvfx0_s1_p_stop = (rvfx0_s1_p_start + (`GPR_POOL_ENC)) - 1;
   parameter              rvfx0_s1_t_start = rvfx0_s1_p_stop + 1;
   parameter              rvfx0_s1_t_stop = (rvfx0_s1_t_start + (3)) - 1;
   parameter              rvfx0_s2_v_start = rvfx0_s1_t_stop + 1;
   parameter              rvfx0_s2_v_stop = (rvfx0_s2_v_start + (1)) - 1;
   parameter              rvfx0_s2_p_start = rvfx0_s2_v_stop + 1;
   parameter              rvfx0_s2_p_stop = (rvfx0_s2_p_start + (`GPR_POOL_ENC)) - 1;
   parameter              rvfx0_s2_t_start = rvfx0_s2_p_stop + 1;
   parameter              rvfx0_s2_t_stop = (rvfx0_s2_t_start + (3)) - 1;
   parameter              rvfx0_s3_v_start = rvfx0_s2_t_stop + 1;
   parameter              rvfx0_s3_v_stop = (rvfx0_s3_v_start + (1)) - 1;
   parameter              rvfx0_s3_p_start = rvfx0_s3_v_stop + 1;
   parameter              rvfx0_s3_p_stop = (rvfx0_s3_p_start + (`GPR_POOL_ENC)) - 1;
   parameter              rvfx0_s3_t_start = rvfx0_s3_p_stop + 1;
   parameter              rvfx0_s3_t_stop = (rvfx0_s3_t_start + (3)) - 1;

   parameter              rvfx0_end = rvfx0_s3_t_stop;

   parameter              rvfx0_size = rvfx0_end + 1;

   //------------------------------------------------------------------------------------------------------------
   // Pervasive
   //------------------------------------------------------------------------------------------------------------


   wire 			   tiup;

   //------------------------------------------------------------------------------------------------------------
   // RV1
   //------------------------------------------------------------------------------------------------------------
   wire [rvfx0_start:rvfx0_end]    rv0_instr_i0_dat;
   wire [rvfx0_start:rvfx0_end]    rv0_instr_i1_dat;
   wire [rvfx0_ex0_start:rvfx0_ex0_end]    rv0_instr_i0_dat_ex0;
   wire [rvfx0_ex0_start:rvfx0_ex0_end]    rv0_instr_i1_dat_ex0;

   wire 			   rv0_instr_i0_spec;
   wire 			   rv0_instr_i1_spec;

   //------------------------------------------------------------------------------------------------------------
   // RV2
   //------------------------------------------------------------------------------------------------------------
   wire [rvfx0_start:rvfx0_end]    rv1_instr_dat;
   wire [0:`THREADS-1] 		   rv1_instr_v;
   wire 			   rv1_instr_ord;
   (* analysis_not_referenced="true" *)
   wire 			   rv1_instr_spec;
   wire [0:`THREADS-1] 		   rv1_instr_ilat0_vld;
   wire [0:`THREADS-1] 		   rv1_instr_ilat1_vld;
   wire [0:3] 			   rv1_instr_ilat;
   wire [0:`ITAG_SIZE_ENC-1] 	   rv1_instr_itag;
   wire [0:`ITAG_SIZE_ENC-1] 	   rv1_instr_s1_itag;
   wire [0:`ITAG_SIZE_ENC-1] 	   rv1_instr_s2_itag;
   wire [0:`ITAG_SIZE_ENC-1] 	   rv1_instr_s3_itag;
   wire                            rv1_instr_is_brick;
   wire [0:`THREADS-1] 		   ex1_credit_free;

   //------------------------------------------------------------------------------------------------------------
   // EX0
   //------------------------------------------------------------------------------------------------------------
   wire 			   rv_ex0_act;

   (* analysis_not_referenced="<140:143>true" *)
   wire [rvfx0_ex0_start:rvfx0_ex0_end]    ex0_instr_dat;

   wire [0:`ITAG_SIZE_ENC-1] 	   ex0_itag_d;
   wire 			   ex0_ord_d;
   wire 			   ex0_is_brick_d;
   wire 			   ex0_t1_v_d;
   wire [0:2] 			   ex0_t1_t_d;
   wire 			   ex0_t2_v_d;
   wire [0:2] 			   ex0_t2_t_d;
   wire 			   ex0_t3_v_d;
   wire [0:2] 			   ex0_t3_t_d;
   wire 			   ex0_s1_v_d;
   wire 			   ex0_s2_v_d;
   wire [0:2] 			   ex0_s2_t_d;
   wire 			   ex0_s3_v_d;
   wire [0:2] 			   ex0_s3_t_d;

   wire [0:`ITAG_SIZE_ENC-1] 	   ex0_itag_q;
   wire 			   ex0_ord_q;
   wire 			   ex0_is_brick_q;
   wire 			   ex0_t1_v_q;
   wire [0:2] 			   ex0_t1_t_q;
   wire 			   ex0_t2_v_q;
   wire [0:2] 			   ex0_t2_t_q;
   wire 			   ex0_t3_v_q;
   wire [0:2] 			   ex0_t3_t_q;
   wire 			   ex0_s1_v_q;
   wire 			   ex0_s2_v_q;
   wire [0:2] 			   ex0_s2_t_q;
   wire 			   ex0_s3_v_q;
   wire [0:2] 			   ex0_s3_t_q;

   //------------------------------------------------------------------------------------------------------------
   // Itag busses and shadow
   //------------------------------------------------------------------------------------------------------------

   wire [0:`THREADS-1] 		   lq_rv_itag1_rst_vld;
   wire [0:`ITAG_SIZE_ENC-1] 	   lq_rv_itag1_rst;

   wire [0:`THREADS*`ITAG_SIZE_ENC-1] 		   cp_next_itag_q;

   (* analysis_not_referenced="true" *)
   wire                            rvs_empty;

   //------------------------------------------------------------------------------------------------------------
   // Scan Chains
   //------------------------------------------------------------------------------------------------------------
   parameter                      rvs_offset = 0 + 0;
   parameter                      ex0_is_brick_offset = rvs_offset + 1;
   parameter                      ex0_itag_offset = ex0_is_brick_offset + 1;
   parameter                      ex0_ord_offset = ex0_itag_offset + `ITAG_SIZE_ENC;
   parameter                      ex0_t1_v_offset = ex0_ord_offset + 1;
   parameter                      ex0_t1_t_offset = ex0_t1_v_offset + 1;
   parameter                      ex0_t2_v_offset = ex0_t1_t_offset + 3;
   parameter                      ex0_t2_t_offset = ex0_t2_v_offset + 1;
   parameter                      ex0_t3_v_offset = ex0_t2_t_offset + 3;
   parameter                      ex0_t3_t_offset = ex0_t3_v_offset + 1;
   parameter                      ex0_s1_v_offset = ex0_t3_t_offset + 3;
   parameter                      ex0_s2_v_offset = ex0_s1_v_offset + 1;
   parameter                      ex0_s2_t_offset = ex0_s2_v_offset + 1;
   parameter                      ex0_s3_v_offset = ex0_s2_t_offset + 3;
   parameter                      ex0_s3_t_offset = ex0_s3_v_offset + 1;

   parameter                      cp_next_itag_offset = ex0_s3_t_offset + 3;

   parameter                      scan_right = cp_next_itag_offset + `THREADS * `ITAG_SIZE_ENC;
   wire [0:scan_right-1] 	   siv;
   wire [0:scan_right-1] 	   sov;

   wire 			   func_sl_thold_0;
   wire 			   func_sl_thold_0_b;
   wire 			   sg_0;
   wire 			   force_t;

   //!! Bugspray Include: rv_fx0_rvs;

   //------------------------------------------------------------------------------------------------------------
   // Pervasive
   //------------------------------------------------------------------------------------------------------------
   assign tiup = 1'b1;



   //------------------------------------------------------------------------------------------------------------
   // RV Entry
   //------------------------------------------------------------------------------------------------------------


   assign rv0_instr_i0_dat = {
			      rv0_instr_i0_t1_v,
			      rv0_instr_i0_t1_t,
			      rv0_instr_i0_t2_v,
			      rv0_instr_i0_t2_t,
			      rv0_instr_i0_t3_v,
			      rv0_instr_i0_t3_t,
			      rv0_instr_i0_s1_v,
			      rv0_instr_i0_s1_p,
			      rv0_instr_i0_s1_t,
			      rv0_instr_i0_s2_v,
			      rv0_instr_i0_s2_p,
			      rv0_instr_i0_s2_t,
			      rv0_instr_i0_s3_v,
			      rv0_instr_i0_s3_p,
			      rv0_instr_i0_s3_t };

   assign rv0_instr_i0_dat_ex0 = {
				  rv0_instr_i0_instr,
				  rv0_instr_i0_ifar,
				  rv0_instr_i0_ucode,
				  rv0_instr_i0_ucode_cnt,
				  rv0_instr_i0_t1_p,
				  rv0_instr_i0_t2_p,
				  rv0_instr_i0_t3_p,
				  rv0_instr_i0_branch,
				  rv0_instr_i0_spare};

   assign rv0_instr_i1_dat = {
			      rv0_instr_i1_t1_v,
			      rv0_instr_i1_t1_t,
			      rv0_instr_i1_t2_v,
			      rv0_instr_i1_t2_t,
			      rv0_instr_i1_t3_v,
			      rv0_instr_i1_t3_t,
			      rv0_instr_i1_s1_v,
			      rv0_instr_i1_s1_p,
			      rv0_instr_i1_s1_t,
			      rv0_instr_i1_s2_v,
			      rv0_instr_i1_s2_p,
			      rv0_instr_i1_s2_t,
			      rv0_instr_i1_s3_v,
			      rv0_instr_i1_s3_p,
			      rv0_instr_i1_s3_t };

   assign rv0_instr_i1_dat_ex0 = {
				  rv0_instr_i1_instr,
				  rv0_instr_i1_ifar,
				  rv0_instr_i1_ucode,
				  rv0_instr_i1_ucode_cnt,
				  rv0_instr_i1_t1_p,
				  rv0_instr_i1_t2_p,
				  rv0_instr_i1_t3_p,
				  rv0_instr_i1_branch,
				  rv0_instr_i1_spare};

   //------------------------------------------------------------------------------------------------------------
   // FX0 Reservation Stations
   //------------------------------------------------------------------------------------------------------------
   assign rv0_instr_i0_spec = 1'b0;
   assign rv0_instr_i1_spec = 1'b0;

   assign lq_rv_itag1_cord = 1'b0;

   rv_station #( .q_dat_width_g(rvfx0_size), .q_dat_ex0_width_g(rvfx0_ex0_size), .q_num_entries_g(`RV_FX0_ENTRIES), .q_itag_busses_g(num_itag_busses_g) )
   rvs(
       .cp_flush(cp_flush),
       .cp_next_itag(cp_next_itag_q),

       .rv0_instr_i0_vld(rv0_instr_i0_vld),
       .rv0_instr_i0_rte(rv0_instr_i0_rte_fx0),
       .rv0_instr_i1_vld(rv0_instr_i1_vld),
       .rv0_instr_i1_rte(rv0_instr_i1_rte_fx0),

       .rv0_instr_i0_dat(rv0_instr_i0_dat),
       .rv0_instr_i0_dat_ex0(rv0_instr_i0_dat_ex0),
       .rv0_instr_i0_itag(rv0_instr_i0_itag),
       .rv0_instr_i0_ord(rv0_instr_i0_ord),
       .rv0_instr_i0_cord(rv0_instr_i0_cord),
       .rv0_instr_i0_spec(rv0_instr_i0_spec),
       .rv0_instr_i0_s1_dep_hit(rv0_instr_i0_s1_dep_hit),		//swap
       .rv0_instr_i0_s1_itag(rv0_instr_i0_s1_itag),		//swap
       .rv0_instr_i0_s2_dep_hit(rv0_instr_i0_s2_dep_hit),
       .rv0_instr_i0_s2_itag(rv0_instr_i0_s2_itag),
       .rv0_instr_i0_s3_dep_hit(rv0_instr_i0_s3_dep_hit),
       .rv0_instr_i0_s3_itag(rv0_instr_i0_s3_itag),
       .rv0_instr_i0_is_brick(rv0_instr_i0_is_brick),
       .rv0_instr_i0_brick(rv0_instr_i0_brick),
       .rv0_instr_i0_ilat(rv0_instr_i0_ilat),
       .rv0_instr_i0_s1_v(rv0_instr_i0_s1_v),		//swap
       .rv0_instr_i0_s2_v(rv0_instr_i0_s2_v),
       .rv0_instr_i0_s3_v(rv0_instr_i0_s3_v),

       .rv0_instr_i1_dat(rv0_instr_i1_dat),
       .rv0_instr_i1_dat_ex0(rv0_instr_i1_dat_ex0),
       .rv0_instr_i1_itag(rv0_instr_i1_itag),
       .rv0_instr_i1_ord(rv0_instr_i1_ord),
       .rv0_instr_i1_cord(rv0_instr_i1_cord),
       .rv0_instr_i1_spec(rv0_instr_i1_spec),
       .rv0_instr_i1_s1_dep_hit(rv0_instr_i1_s1_dep_hit),		//swap
       .rv0_instr_i1_s1_itag(rv0_instr_i1_s1_itag),		//swap
       .rv0_instr_i1_s2_dep_hit(rv0_instr_i1_s2_dep_hit),
       .rv0_instr_i1_s2_itag(rv0_instr_i1_s2_itag),
       .rv0_instr_i1_s3_dep_hit(rv0_instr_i1_s3_dep_hit),
       .rv0_instr_i1_s3_itag(rv0_instr_i1_s3_itag),
       .rv0_instr_i1_is_brick(rv0_instr_i1_is_brick),
       .rv0_instr_i1_brick(rv0_instr_i1_brick),
       .rv0_instr_i1_ilat(rv0_instr_i1_ilat),
       .rv0_instr_i1_s1_v(rv0_instr_i1_s1_v),		//swap
       .rv0_instr_i1_s2_v(rv0_instr_i1_s2_v),
       .rv0_instr_i1_s3_v(rv0_instr_i1_s3_v),

       .rv1_instr_vld(rv1_instr_v),
       .rv1_instr_dat(rv1_instr_dat),
       .rv1_instr_ord(rv1_instr_ord),
       .rv1_instr_spec(rv1_instr_spec),
       .rv1_instr_itag(rv1_instr_itag),
       .rv1_instr_ilat(rv1_instr_ilat),
       .rv1_instr_ilat0_vld(rv1_instr_ilat0_vld),
       .rv1_instr_ilat1_vld(rv1_instr_ilat1_vld),
       .rv1_instr_s1_itag(rv1_instr_s1_itag),
       .rv1_instr_s2_itag(rv1_instr_s2_itag),
       .rv1_instr_s3_itag(rv1_instr_s3_itag),
       .rv1_instr_is_brick(rv1_instr_is_brick),
       .ex0_instr_dat(ex0_instr_dat),
       .ex1_credit_free(ex1_credit_free),

       .rv1_other_ilat0_vld(rv1_fx1_ilat0_vld),
       .rv1_other_ilat0_itag(rv1_fx1_ilat0_itag),
       .rv1_other_ilat0_vld_out(rv1_fx0_ilat0_vld),
       .rv1_other_ilat0_itag_out(rv1_fx0_ilat0_itag),

       .q_hold_all(fx0_rv_hold_all),
       .q_ord_complete(fx0_rv_ord_complete),
       .q_ord_tid(fx0_rv_ord_tid),

       .fx0_rv_itag  (fx0_rv_itag),
       .fx1_rv_itag  (fx1_rv_itag),
       .lq_rv_itag0  (lq_rv_ext_itag0),
       .lq_rv_itag1  (lq_rv_ext_itag1),
       .lq_rv_itag2  (lq_rv_ext_itag2),
       .axu0_rv_itag (axu0_rv_ext_itag),
       .axu1_rv_itag (axu1_rv_ext_itag),
       .fx0_rv_itag_vld  (fx0_rv_itag_vld),
       .fx1_rv_itag_vld  (fx1_rv_itag_vld),
       .lq_rv_itag0_vld  (lq_rv_ext_itag0_vld),
       .lq_rv_itag1_vld  (lq_rv_ext_itag1_vld),
       .lq_rv_itag2_vld  (lq_rv_ext_itag2_vld),
       .axu0_rv_itag_vld (axu0_rv_ext_itag_vld),
       .axu1_rv_itag_vld (axu1_rv_ext_itag_vld),
       .fx0_rv_itag_abort  (fx0_rv_itag_abort),
       .fx1_rv_itag_abort  (fx1_rv_itag_abort),
       .lq_rv_itag0_abort  (lq_rv_ext_itag0_abort),
       .lq_rv_itag1_abort  (lq_rv_ext_itag1_abort),
       .axu0_rv_itag_abort (axu0_rv_ext_itag_abort),
       .axu1_rv_itag_abort (axu1_rv_ext_itag_abort),

       .xx_rv_ex2_s1_abort(fx0_rv_ex2_s1_abort),
       .xx_rv_ex2_s2_abort(fx0_rv_ex2_s2_abort),
       .xx_rv_ex2_s3_abort(fx0_rv_ex2_s3_abort),

       .lq_rv_itag1_restart(lq_rv_itag1_restart),
       .lq_rv_itag1_hold(lq_rv_itag1_hold),
       .lq_rv_itag1_cord(lq_rv_itag1_cord),
       .lq_rv_itag1_rst_vld(lq_rv_itag1_rst_vld),
       .lq_rv_itag1_rst(lq_rv_itag1_rst),
       .lq_rv_clr_hold(lq_rv_clr_hold),

       .rvs_perf_bus(fx0_rvs_perf_bus),
       .rvs_dbg_bus(fx0_rvs_dbg_bus),
       .rvs_empty(rvs_empty),

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

   assign rv_iu_fx0_credit_free = ex1_credit_free;

   assign rv_fx0_vld = rv1_instr_v;
   assign rv_fx0_s1_v = rv1_instr_dat[rvfx0_s1_v_start];
   assign rv_fx0_s1_p = rv1_instr_dat[rvfx0_s1_p_start:rvfx0_s1_p_stop];
   assign rv_fx0_s2_v = rv1_instr_dat[rvfx0_s2_v_start];
   assign rv_fx0_s2_p = rv1_instr_dat[rvfx0_s2_p_start:rvfx0_s2_p_stop];
   assign rv_fx0_s3_v = rv1_instr_dat[rvfx0_s3_v_start];
   assign rv_fx0_s3_p = rv1_instr_dat[rvfx0_s3_p_start:rvfx0_s3_p_stop];

   assign rv_byp_fx0_vld = rv1_instr_v;

   //RV2 Outputs
   assign rv_byp_fx0_ord = rv1_instr_ord;
   assign rv_byp_fx0_itag = rv1_instr_itag;
   assign rv_byp_fx0_ilat = rv1_instr_ilat;
   assign rv_byp_fx0_s1_itag = rv1_instr_s1_itag;
   assign rv_byp_fx0_s2_itag = rv1_instr_s2_itag;
   assign rv_byp_fx0_s3_itag = rv1_instr_s3_itag;

   //RV2 to Bypass
   assign rv_byp_fx0_t1_v = rv1_instr_dat[rvfx0_t1_v_start];
   assign rv_byp_fx0_t1_t = rv1_instr_dat[rvfx0_t1_t_start:rvfx0_t1_t_stop];
   assign rv_byp_fx0_t2_v = rv1_instr_dat[rvfx0_t2_v_start];
   assign rv_byp_fx0_t2_t = rv1_instr_dat[rvfx0_t2_t_start:rvfx0_t2_t_stop];
   assign rv_byp_fx0_t3_v = rv1_instr_dat[rvfx0_t3_v_start];
   assign rv_byp_fx0_t3_t = rv1_instr_dat[rvfx0_t3_t_start:rvfx0_t3_t_stop];
   assign rv_byp_fx0_s1_t = rv1_instr_dat[rvfx0_s1_t_start:rvfx0_s1_t_stop];
   assign rv_byp_fx0_s2_t = rv1_instr_dat[rvfx0_s2_t_start:rvfx0_s2_t_stop];
   assign rv_byp_fx0_s3_t = rv1_instr_dat[rvfx0_s3_t_start:rvfx0_s3_t_stop];
   assign rv_byp_fx0_ilat0_vld = rv1_instr_ilat0_vld;
   assign rv_byp_fx0_ilat1_vld = rv1_instr_ilat1_vld;

   //EX0 Outputs
   assign ex0_ord_d = rv1_instr_ord;
   assign ex0_itag_d = rv1_instr_itag;
   assign ex0_is_brick_d = rv1_instr_is_brick;

   assign ex0_t1_v_d = rv1_instr_dat[rvfx0_t1_v_start];
   assign ex0_t1_t_d = rv1_instr_dat[rvfx0_t1_t_start:rvfx0_t1_t_stop];
   assign ex0_t2_v_d = rv1_instr_dat[rvfx0_t2_v_start];
   assign ex0_t2_t_d = rv1_instr_dat[rvfx0_t2_t_start:rvfx0_t2_t_stop];
   assign ex0_t3_v_d = rv1_instr_dat[rvfx0_t3_v_start];
   assign ex0_t3_t_d = rv1_instr_dat[rvfx0_t3_t_start:rvfx0_t3_t_stop];
   assign ex0_s1_v_d = rv1_instr_dat[rvfx0_s1_v_start];
   assign ex0_s2_v_d = rv1_instr_dat[rvfx0_s2_v_start];
   assign ex0_s2_t_d = rv1_instr_dat[rvfx0_s2_t_start:rvfx0_s2_t_stop];
   assign ex0_s3_v_d = rv1_instr_dat[rvfx0_s3_v_start];
   assign ex0_s3_t_d = rv1_instr_dat[rvfx0_s3_t_start:rvfx0_s3_t_stop];

   assign rv_ex0_act = |(rv1_instr_v);

   assign rv_fx0_ex0_instr = ex0_instr_dat[rvfx0_instr_start:rvfx0_instr_stop];
   assign rv_fx0_ex0_ifar = ex0_instr_dat[rvfx0_ifar_start:rvfx0_ifar_stop];
   assign rv_fx0_ex0_ucode = ex0_instr_dat[rvfx0_ucode_start:rvfx0_ucode_stop];
   assign rv_fx0_ex0_ucode_cnt = ex0_instr_dat[rvfx0_ucode_cnt_start:rvfx0_ucode_cnt_stop];
   assign rv_fx0_ex0_t1_p = ex0_instr_dat[rvfx0_t1_p_start:rvfx0_t1_p_stop];
   assign rv_fx0_ex0_t2_p = ex0_instr_dat[rvfx0_t2_p_start:rvfx0_t2_p_stop];
   assign rv_fx0_ex0_t3_p = ex0_instr_dat[rvfx0_t3_p_start:rvfx0_t3_p_stop];
   assign rv_fx0_ex0_branch = ex0_instr_dat[rvfx0_branch_start:rvfx0_branch_stop];

   assign rv_fx0_ex0_ord = ex0_ord_q;
   assign rv_fx0_ex0_itag = ex0_itag_q;
   assign rv_fx0_ex0_t1_v = ex0_t1_v_q;
   assign rv_fx0_ex0_t1_t = ex0_t1_t_q;
   assign rv_fx0_ex0_t2_v = ex0_t2_v_q;
   assign rv_fx0_ex0_t2_t = ex0_t2_t_q;
   assign rv_fx0_ex0_t3_v = ex0_t3_v_q;
   assign rv_fx0_ex0_t3_t = ex0_t3_t_q;
   assign rv_fx0_ex0_s1_v = ex0_s1_v_q;
   assign rv_fx0_ex0_s2_v = ex0_s2_v_q;
   assign rv_fx0_ex0_s2_t = ex0_s2_t_q;
   assign rv_fx0_ex0_s3_v = ex0_s3_v_q;
   assign rv_fx0_ex0_s3_t = ex0_s3_t_q;
   assign rv_byp_fx0_ex0_is_brick = ex0_is_brick_q;

   //------------------------------------------------------------------------------------------------------------
   // Itag busses
   //------------------------------------------------------------------------------------------------------------


   // Restart Itag and Valid from LQ.  This is separate because it could be early (not latched)
   assign lq_rv_itag1_rst_vld = lq_rv_itag1_vld;
   assign lq_rv_itag1_rst = lq_rv_itag1;

   //------------------------------------------------------------------------------------------------------------
   // Pipeline Latches
   //------------------------------------------------------------------------------------------------------------

   tri_rlmlatch_p #(.INIT(0) )
   ex0_is_brick_reg(
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
		.scin(siv[ex0_is_brick_offset]),
		.scout(sov[ex0_is_brick_offset]),
		.din(ex0_is_brick_d),
		.dout(ex0_is_brick_q)
		);


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0) )
   ex0_itag_reg(
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
		.scin(siv[ex0_itag_offset:ex0_itag_offset + `ITAG_SIZE_ENC - 1]),
		.scout(sov[ex0_itag_offset:ex0_itag_offset + `ITAG_SIZE_ENC - 1]),
		.din(ex0_itag_d),
		.dout(ex0_itag_q)
		);


   tri_rlmlatch_p #(.INIT(0))
   ex0_ord_reg(
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


   tri_rlmlatch_p #(.INIT(0))
   ex0_t1_v_reg(
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
		.scin(siv[ex0_t1_v_offset]),
		.scout(sov[ex0_t1_v_offset]),
		.din(ex0_t1_v_d),
		.dout(ex0_t1_v_q)
		);




   tri_rlmreg_p #(.WIDTH(3), .INIT(0))
   ex0_t1_t_reg(
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
		.scin(siv[ex0_t1_t_offset:ex0_t1_t_offset + 3 - 1]),
		.scout(sov[ex0_t1_t_offset:ex0_t1_t_offset + 3 - 1]),
		.din(ex0_t1_t_d),
		.dout(ex0_t1_t_q)
		);


   tri_rlmlatch_p #(.INIT(0))
   ex0_t2_v_reg(
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
		.scin(siv[ex0_t2_v_offset]),
		.scout(sov[ex0_t2_v_offset]),
		.din(ex0_t2_v_d),
		.dout(ex0_t2_v_q)
		);


   tri_rlmreg_p #(.WIDTH(3), .INIT(0))
   ex0_t2_t_reg(
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
		.scin(siv[ex0_t2_t_offset:ex0_t2_t_offset + 3 - 1]),
		.scout(sov[ex0_t2_t_offset:ex0_t2_t_offset + 3 - 1]),
		.din(ex0_t2_t_d),
		.dout(ex0_t2_t_q)
		);


   tri_rlmlatch_p #(.INIT(0))
   ex0_t3_v_reg(
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
		.scin(siv[ex0_t3_v_offset]),
		.scout(sov[ex0_t3_v_offset]),
		.din(ex0_t3_v_d),
		.dout(ex0_t3_v_q)
		);


   tri_rlmreg_p #(.WIDTH(3), .INIT(0))
   ex0_t3_t_reg(
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
		.scin(siv[ex0_t3_t_offset:ex0_t3_t_offset + 3 - 1]),
		.scout(sov[ex0_t3_t_offset:ex0_t3_t_offset + 3 - 1]),
		.din(ex0_t3_t_d),
		.dout(ex0_t3_t_q)
		);


   tri_rlmlatch_p #(.INIT(0))
   ex0_s1_v_reg(
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
		.scin(siv[ex0_s1_v_offset]),
		.scout(sov[ex0_s1_v_offset]),
		.din(ex0_s1_v_d),
		.dout(ex0_s1_v_q)
		);


   tri_rlmlatch_p #(.INIT(0))
   ex0_s2_v_reg(
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
		.scin(siv[ex0_s2_v_offset]),
		.scout(sov[ex0_s2_v_offset]),
		.din(ex0_s2_v_d),
		.dout(ex0_s2_v_q)
		);


   tri_rlmreg_p #(.WIDTH(3), .INIT(0))
   ex0_s2_t_reg(
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
		.scin(siv[ex0_s2_t_offset:ex0_s2_t_offset + 3 - 1]),
		.scout(sov[ex0_s2_t_offset:ex0_s2_t_offset + 3 - 1]),
		.din(ex0_s2_t_d),
		.dout(ex0_s2_t_q)
		);


   tri_rlmlatch_p #(.INIT(0))
   ex0_s3_v_reg(
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
		.scin(siv[ex0_s3_v_offset]),
		.scout(sov[ex0_s3_v_offset]),
		.din(ex0_s3_v_d),
		.dout(ex0_s3_v_q)
		);


   tri_rlmreg_p #(.WIDTH(3), .INIT(0))
   ex0_s3_t_reg(
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
		.scin(siv[ex0_s3_t_offset:ex0_s3_t_offset + 3 - 1]),
		.scout(sov[ex0_s3_t_offset:ex0_s3_t_offset + 3 - 1]),
		.din(ex0_s3_t_d),
		.dout(ex0_s3_t_q)
		);



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
