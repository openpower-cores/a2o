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

// *********************************************************************
//
// This is the ENTITY for rv_deps
//
// *********************************************************************

module rv_deps(

`include "tri_a2o.vh"

   //------------------------------------------------------------------------------------------------------------
   // Instructions from IU
   //------------------------------------------------------------------------------------------------------------
   input                              iu_rv_iu6_t0_i0_vld,
   input 			      iu_rv_iu6_t0_i0_rte_lq,
   input 			      iu_rv_iu6_t0_i0_rte_sq,
   input 			      iu_rv_iu6_t0_i0_rte_fx0,
   input 			      iu_rv_iu6_t0_i0_rte_fx1,
   input 			      iu_rv_iu6_t0_i0_rte_axu0,
   input 			      iu_rv_iu6_t0_i0_rte_axu1,
   input 			      iu_rv_iu6_t0_i0_act     ,
   input [0:31] 		      iu_rv_iu6_t0_i0_instr,
   input [0:`EFF_IFAR_WIDTH-1] 	      iu_rv_iu6_t0_i0_ifar,
   input [0:2] 			      iu_rv_iu6_t0_i0_ucode,
   input 			      iu_rv_iu6_t0_i0_2ucode,
   input [0:`UCODE_ENTRIES_ENC-1]      iu_rv_iu6_t0_i0_ucode_cnt,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t0_i0_itag,
   input 			      iu_rv_iu6_t0_i0_ord,
   input 			      iu_rv_iu6_t0_i0_cord,
   input 			      iu_rv_iu6_t0_i0_spec,
   input 			      iu_rv_iu6_t0_i0_t1_v,
   input [0:2] 			      iu_rv_iu6_t0_i0_t1_t,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t0_i0_t1_p,
   input 			      iu_rv_iu6_t0_i0_t2_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t0_i0_t2_p,
   input [0:2] 			      iu_rv_iu6_t0_i0_t2_t,
   input 			      iu_rv_iu6_t0_i0_t3_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t0_i0_t3_p,
   input [0:2] 			      iu_rv_iu6_t0_i0_t3_t,
   input 			      iu_rv_iu6_t0_i0_s1_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t0_i0_s1_p,
   input [0:2] 			      iu_rv_iu6_t0_i0_s1_t,
   input 			      iu_rv_iu6_t0_i0_s2_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t0_i0_s2_p,
   input [0:2] 			      iu_rv_iu6_t0_i0_s2_t,
   input 			      iu_rv_iu6_t0_i0_s3_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t0_i0_s3_p,
   input [0:2] 			      iu_rv_iu6_t0_i0_s3_t,
   input [0:3] 			      iu_rv_iu6_t0_i0_ilat,
   input [0:`G_BRANCH_LEN-1] 	      iu_rv_iu6_t0_i0_branch,
   input 			      iu_rv_iu6_t0_i0_isLoad,
   input 			      iu_rv_iu6_t0_i0_isStore,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t0_i0_s1_itag,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t0_i0_s2_itag,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t0_i0_s3_itag,

   input                              iu_rv_iu6_t0_i1_vld,
   input 			      iu_rv_iu6_t0_i1_rte_lq,
   input 			      iu_rv_iu6_t0_i1_rte_sq,
   input 			      iu_rv_iu6_t0_i1_rte_fx0,
   input 			      iu_rv_iu6_t0_i1_rte_fx1,
   input 			      iu_rv_iu6_t0_i1_rte_axu0,
   input 			      iu_rv_iu6_t0_i1_rte_axu1,
   input 			      iu_rv_iu6_t0_i1_act     ,
   input [0:31] 		      iu_rv_iu6_t0_i1_instr,
   input [0:`EFF_IFAR_WIDTH-1] 	      iu_rv_iu6_t0_i1_ifar,
   input [0:2] 			      iu_rv_iu6_t0_i1_ucode,
   input [0:`UCODE_ENTRIES_ENC-1]      iu_rv_iu6_t0_i1_ucode_cnt,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t0_i1_itag,
   input 			      iu_rv_iu6_t0_i1_ord,
   input 			      iu_rv_iu6_t0_i1_cord,
   input 			      iu_rv_iu6_t0_i1_spec,
   input 			      iu_rv_iu6_t0_i1_t1_v,
   input [0:2] 			      iu_rv_iu6_t0_i1_t1_t,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t0_i1_t1_p,
   input 			      iu_rv_iu6_t0_i1_t2_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t0_i1_t2_p,
   input [0:2] 			      iu_rv_iu6_t0_i1_t2_t,
   input 			      iu_rv_iu6_t0_i1_t3_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t0_i1_t3_p,
   input [0:2] 			      iu_rv_iu6_t0_i1_t3_t,
   input 			      iu_rv_iu6_t0_i1_s1_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t0_i1_s1_p,
   input [0:2] 			      iu_rv_iu6_t0_i1_s1_t,
   input 			      iu_rv_iu6_t0_i1_s2_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t0_i1_s2_p,
   input [0:2] 			      iu_rv_iu6_t0_i1_s2_t,
   input 			      iu_rv_iu6_t0_i1_s3_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t0_i1_s3_p,
   input [0:2] 			      iu_rv_iu6_t0_i1_s3_t,
   input [0:3] 			      iu_rv_iu6_t0_i1_ilat,
   input [0:`G_BRANCH_LEN-1] 	      iu_rv_iu6_t0_i1_branch,
   input 			      iu_rv_iu6_t0_i1_isLoad,
   input 			      iu_rv_iu6_t0_i1_isStore,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t0_i1_s1_itag,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t0_i1_s2_itag,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t0_i1_s3_itag,
   input                              iu_rv_iu6_t0_i1_s1_dep_hit,
   input                              iu_rv_iu6_t0_i1_s2_dep_hit,
   input                              iu_rv_iu6_t0_i1_s3_dep_hit,

`ifndef THREADS1

   input                              iu_rv_iu6_t1_i0_vld,
   input 			      iu_rv_iu6_t1_i0_rte_lq,
   input 			      iu_rv_iu6_t1_i0_rte_sq,
   input 			      iu_rv_iu6_t1_i0_rte_fx0,
   input 			      iu_rv_iu6_t1_i0_rte_fx1,
   input 			      iu_rv_iu6_t1_i0_rte_axu0,
   input 			      iu_rv_iu6_t1_i0_rte_axu1,
   input 			      iu_rv_iu6_t1_i0_act     ,
   input [0:31] 		      iu_rv_iu6_t1_i0_instr,
   input [0:`EFF_IFAR_WIDTH-1] 	      iu_rv_iu6_t1_i0_ifar,
   input [0:2] 			      iu_rv_iu6_t1_i0_ucode,
   input 			      iu_rv_iu6_t1_i0_2ucode,
   input [0:`UCODE_ENTRIES_ENC-1]      iu_rv_iu6_t1_i0_ucode_cnt,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t1_i0_itag,
   input 			      iu_rv_iu6_t1_i0_ord,
   input 			      iu_rv_iu6_t1_i0_cord,
   input 			      iu_rv_iu6_t1_i0_spec,
   input 			      iu_rv_iu6_t1_i0_t1_v,
   input [0:2] 			      iu_rv_iu6_t1_i0_t1_t,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t1_i0_t1_p,
   input 			      iu_rv_iu6_t1_i0_t2_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t1_i0_t2_p,
   input [0:2] 			      iu_rv_iu6_t1_i0_t2_t,
   input 			      iu_rv_iu6_t1_i0_t3_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t1_i0_t3_p,
   input [0:2] 			      iu_rv_iu6_t1_i0_t3_t,
   input 			      iu_rv_iu6_t1_i0_s1_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t1_i0_s1_p,
   input [0:2] 			      iu_rv_iu6_t1_i0_s1_t,
   input 			      iu_rv_iu6_t1_i0_s2_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t1_i0_s2_p,
   input [0:2] 			      iu_rv_iu6_t1_i0_s2_t,
   input 			      iu_rv_iu6_t1_i0_s3_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t1_i0_s3_p,
   input [0:2] 			      iu_rv_iu6_t1_i0_s3_t,
   input [0:3] 			      iu_rv_iu6_t1_i0_ilat,
   input [0:`G_BRANCH_LEN-1] 	      iu_rv_iu6_t1_i0_branch,
   input 			      iu_rv_iu6_t1_i0_isLoad,
   input 			      iu_rv_iu6_t1_i0_isStore,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t1_i0_s1_itag,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t1_i0_s2_itag,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t1_i0_s3_itag,

   input                              iu_rv_iu6_t1_i1_vld,
   input 			      iu_rv_iu6_t1_i1_rte_lq,
   input 			      iu_rv_iu6_t1_i1_rte_sq,
   input 			      iu_rv_iu6_t1_i1_rte_fx0,
   input 			      iu_rv_iu6_t1_i1_rte_fx1,
   input 			      iu_rv_iu6_t1_i1_rte_axu0,
   input 			      iu_rv_iu6_t1_i1_rte_axu1,
   input 			      iu_rv_iu6_t1_i1_act     ,
   input [0:31] 		      iu_rv_iu6_t1_i1_instr,
   input [0:`EFF_IFAR_WIDTH-1] 	      iu_rv_iu6_t1_i1_ifar,
   input [0:2] 			      iu_rv_iu6_t1_i1_ucode,
   input [0:`UCODE_ENTRIES_ENC-1]      iu_rv_iu6_t1_i1_ucode_cnt,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t1_i1_itag,
   input 			      iu_rv_iu6_t1_i1_ord,
   input 			      iu_rv_iu6_t1_i1_cord,
   input 			      iu_rv_iu6_t1_i1_spec,
   input 			      iu_rv_iu6_t1_i1_t1_v,
   input [0:2] 			      iu_rv_iu6_t1_i1_t1_t,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t1_i1_t1_p,
   input 			      iu_rv_iu6_t1_i1_t2_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t1_i1_t2_p,
   input [0:2] 			      iu_rv_iu6_t1_i1_t2_t,
   input 			      iu_rv_iu6_t1_i1_t3_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t1_i1_t3_p,
   input [0:2] 			      iu_rv_iu6_t1_i1_t3_t,
   input 			      iu_rv_iu6_t1_i1_s1_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t1_i1_s1_p,
   input [0:2] 			      iu_rv_iu6_t1_i1_s1_t,
   input 			      iu_rv_iu6_t1_i1_s2_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t1_i1_s2_p,
   input [0:2] 			      iu_rv_iu6_t1_i1_s2_t,
   input 			      iu_rv_iu6_t1_i1_s3_v,
   input [0:`GPR_POOL_ENC-1] 	      iu_rv_iu6_t1_i1_s3_p,
   input [0:2] 			      iu_rv_iu6_t1_i1_s3_t,
   input [0:3] 			      iu_rv_iu6_t1_i1_ilat,
   input [0:`G_BRANCH_LEN-1] 	      iu_rv_iu6_t1_i1_branch,
   input 			      iu_rv_iu6_t1_i1_isLoad,
   input 			      iu_rv_iu6_t1_i1_isStore,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t1_i1_s1_itag,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t1_i1_s2_itag,
   input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t1_i1_s3_itag,
   input                              iu_rv_iu6_t1_i1_s1_dep_hit,
   input                              iu_rv_iu6_t1_i1_s2_dep_hit,
   input                              iu_rv_iu6_t1_i1_s3_dep_hit,

`endif

   //------------------------------------------------------------------------------------------------------------
   // Machine zap interface
   //------------------------------------------------------------------------------------------------------------
   input [0:`THREADS-1] 		      cp_flush,

   //------------------------------------------------------------------------------------------------------------
   // ITAG Busses
   //------------------------------------------------------------------------------------------------------------
   input [0:`THREADS-1]		      fx0_rv_itag_vld,
   input [0:`ITAG_SIZE_ENC-1]           fx0_rv_itag,
   input [0:`THREADS-1]	            fx1_rv_itag_vld,
   input [0:`ITAG_SIZE_ENC-1]           fx1_rv_itag,
   input [0:`THREADS-1]		    lq_rv_itag0_vld,
   input [0:`ITAG_SIZE_ENC-1]           lq_rv_itag0,
   input [0:`THREADS-1]		    lq_rv_itag1_vld,
   input [0:`ITAG_SIZE_ENC-1]           lq_rv_itag1,
   input [0:`THREADS-1]		    lq_rv_itag2_vld,
   input [0:`ITAG_SIZE_ENC-1]           lq_rv_itag2,
   input [0:`THREADS-1]		    axu0_rv_itag_vld,
   input [0:`ITAG_SIZE_ENC-1]           axu0_rv_itag,
   input [0:`THREADS-1]		    axu1_rv_itag_vld,
   input [0:`ITAG_SIZE_ENC-1]           axu1_rv_itag,

   input 			   fx0_rv_itag_abort,
   input 			   fx1_rv_itag_abort,
   input 			   lq_rv_itag0_abort,
   input 			   lq_rv_itag1_abort,
   input 			   axu0_rv_itag_abort,
   input 			   axu1_rv_itag_abort,


   //------------------------------------------------------------------------------------------------------------
   // fx0 Outputs
   //------------------------------------------------------------------------------------------------------------
   output [0:`THREADS-1] 	      rv0_fx0_instr_i0_vld,
   output                             rv0_fx0_instr_i0_rte_fx0,

   output [0:31] 		      rv0_fx0_instr_i0_instr,
   output [62-`EFF_IFAR_WIDTH:61]      rv0_fx0_instr_i0_ifar,
   output [0:2] 		      rv0_fx0_instr_i0_ucode,
   output [0:`UCODE_ENTRIES_ENC-1]     rv0_fx0_instr_i0_ucode_cnt,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx0_instr_i0_itag,
   output                             rv0_fx0_instr_i0_ord,
   output                             rv0_fx0_instr_i0_cord,
   output                             rv0_fx0_instr_i0_t1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx0_instr_i0_t1_p,
   output [0:2] 		      rv0_fx0_instr_i0_t1_t,
   output                             rv0_fx0_instr_i0_t2_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx0_instr_i0_t2_p,
   output [0:2] 		      rv0_fx0_instr_i0_t2_t,
   output                             rv0_fx0_instr_i0_t3_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx0_instr_i0_t3_p,
   output [0:2] 		      rv0_fx0_instr_i0_t3_t,
   output                             rv0_fx0_instr_i0_s1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx0_instr_i0_s1_p,
   output [0:2] 		      rv0_fx0_instr_i0_s1_t,
   output                             rv0_fx0_instr_i0_s2_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx0_instr_i0_s2_p,
   output [0:2] 		      rv0_fx0_instr_i0_s2_t,
   output                             rv0_fx0_instr_i0_s3_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx0_instr_i0_s3_p,
   output [0:2] 		      rv0_fx0_instr_i0_s3_t,
   output [0:3] 		      rv0_fx0_instr_i0_ilat,
   output [0:`G_BRANCH_LEN-1] 	      rv0_fx0_instr_i0_branch,
   output [0:3] 		      rv0_fx0_instr_i0_spare,
   output                             rv0_fx0_instr_i0_is_brick,
   output [0:2] 		      rv0_fx0_instr_i0_brick,

   output [0:`THREADS-1] 	      rv0_fx0_instr_i1_vld,
   output                             rv0_fx0_instr_i1_rte_fx0,
   output [0:31] 		      rv0_fx0_instr_i1_instr,
   output [62-`EFF_IFAR_WIDTH:61]      rv0_fx0_instr_i1_ifar,
   output [0:2] 		      rv0_fx0_instr_i1_ucode,
   output [0:`UCODE_ENTRIES_ENC-1]     rv0_fx0_instr_i1_ucode_cnt,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx0_instr_i1_itag,
   output                             rv0_fx0_instr_i1_ord,
   output                             rv0_fx0_instr_i1_cord,
   output                             rv0_fx0_instr_i1_t1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx0_instr_i1_t1_p,
   output [0:2] 		      rv0_fx0_instr_i1_t1_t,
   output                             rv0_fx0_instr_i1_t2_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx0_instr_i1_t2_p,
   output [0:2] 		      rv0_fx0_instr_i1_t2_t,
   output                             rv0_fx0_instr_i1_t3_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx0_instr_i1_t3_p,
   output [0:2] 		      rv0_fx0_instr_i1_t3_t,
   output                             rv0_fx0_instr_i1_s1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx0_instr_i1_s1_p,
   output [0:2] 		      rv0_fx0_instr_i1_s1_t,
   output                             rv0_fx0_instr_i1_s2_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx0_instr_i1_s2_p,
   output [0:2] 		      rv0_fx0_instr_i1_s2_t,
   output                             rv0_fx0_instr_i1_s3_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx0_instr_i1_s3_p,
   output [0:2] 		      rv0_fx0_instr_i1_s3_t,
   output [0:3] 		      rv0_fx0_instr_i1_ilat,
   output [0:`G_BRANCH_LEN-1] 	      rv0_fx0_instr_i1_branch,
   output [0:3] 		      rv0_fx0_instr_i1_spare,
   output                             rv0_fx0_instr_i1_is_brick,
   output [0:2] 		      rv0_fx0_instr_i1_brick,

   output                             rv0_fx0_instr_i0_s1_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx0_instr_i0_s1_itag,
   output                             rv0_fx0_instr_i0_s2_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx0_instr_i0_s2_itag,
   output                             rv0_fx0_instr_i0_s3_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx0_instr_i0_s3_itag,

   output                             rv0_fx0_instr_i1_s1_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx0_instr_i1_s1_itag,
   output                             rv0_fx0_instr_i1_s2_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx0_instr_i1_s2_itag,
   output                             rv0_fx0_instr_i1_s3_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx0_instr_i1_s3_itag,

   //------------------------------------------------------------------------------------------------------------
   // fx1 Outputs
   //------------------------------------------------------------------------------------------------------------
   output [0:`THREADS-1] 	      rv0_fx1_instr_i0_vld,
   output                             rv0_fx1_instr_i0_rte_fx1,

   output [0:31] 		      rv0_fx1_instr_i0_instr,
   output [0:2] 		      rv0_fx1_instr_i0_ucode,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx1_instr_i0_itag,
   output                             rv0_fx1_instr_i0_t1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx1_instr_i0_t1_p,
   output                             rv0_fx1_instr_i0_t2_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx1_instr_i0_t2_p,
   output                             rv0_fx1_instr_i0_t3_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx1_instr_i0_t3_p,
   output                             rv0_fx1_instr_i0_s1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx1_instr_i0_s1_p,
   output [0:2] 		      rv0_fx1_instr_i0_s1_t,
   output                             rv0_fx1_instr_i0_s2_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx1_instr_i0_s2_p,
   output [0:2] 		      rv0_fx1_instr_i0_s2_t,
   output                             rv0_fx1_instr_i0_s3_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx1_instr_i0_s3_p,
   output [0:2] 		      rv0_fx1_instr_i0_s3_t,
   output [0:3] 		      rv0_fx1_instr_i0_ilat,
   output                             rv0_fx1_instr_i0_isStore,
   output [0:3] 		      rv0_fx1_instr_i0_spare,
   output                             rv0_fx1_instr_i0_is_brick,
   output [0:2] 		      rv0_fx1_instr_i0_brick,

   output [0:`THREADS-1] 	      rv0_fx1_instr_i1_vld,
   output                             rv0_fx1_instr_i1_rte_fx1,
   output [0:31] 		      rv0_fx1_instr_i1_instr,
   output [0:2] 		      rv0_fx1_instr_i1_ucode,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx1_instr_i1_itag,
   output                             rv0_fx1_instr_i1_t1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx1_instr_i1_t1_p,
   output                             rv0_fx1_instr_i1_t2_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx1_instr_i1_t2_p,
   output                             rv0_fx1_instr_i1_t3_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx1_instr_i1_t3_p,
   output                             rv0_fx1_instr_i1_s1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx1_instr_i1_s1_p,
   output [0:2] 		      rv0_fx1_instr_i1_s1_t,
   output                             rv0_fx1_instr_i1_s2_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx1_instr_i1_s2_p,
   output [0:2] 		      rv0_fx1_instr_i1_s2_t,
   output                             rv0_fx1_instr_i1_s3_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_fx1_instr_i1_s3_p,
   output [0:2] 		      rv0_fx1_instr_i1_s3_t,
   output [0:3] 		      rv0_fx1_instr_i1_ilat,
   output                             rv0_fx1_instr_i1_isStore,
   output [0:3] 		      rv0_fx1_instr_i1_spare,
   output                             rv0_fx1_instr_i1_is_brick,
   output [0:2] 		      rv0_fx1_instr_i1_brick,

   output                             rv0_fx1_instr_i0_s1_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx1_instr_i0_s1_itag,
   output                             rv0_fx1_instr_i0_s2_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx1_instr_i0_s2_itag,
   output                             rv0_fx1_instr_i0_s3_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx1_instr_i0_s3_itag,

   output                             rv0_fx1_instr_i1_s1_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx1_instr_i1_s1_itag,
   output                             rv0_fx1_instr_i1_s2_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx1_instr_i1_s2_itag,
   output                             rv0_fx1_instr_i1_s3_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_fx1_instr_i1_s3_itag,

   //------------------------------------------------------------------------------------------------------------
   // lq Outputs
   //------------------------------------------------------------------------------------------------------------
   output [0:`THREADS-1] 	      rv0_lq_instr_i0_vld,
   output                             rv0_lq_instr_i0_rte_lq,

   output [0:31] 		      rv0_lq_instr_i0_instr,
   output [0:2] 		      rv0_lq_instr_i0_ucode,
   output [0:`UCODE_ENTRIES_ENC-1]     rv0_lq_instr_i0_ucode_cnt,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_lq_instr_i0_itag,
   output                             rv0_lq_instr_i0_ord,
   output                             rv0_lq_instr_i0_cord,
   output                             rv0_lq_instr_i0_spec,
   output                             rv0_lq_instr_i0_t1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_lq_instr_i0_t1_p,
   output                             rv0_lq_instr_i0_t2_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_lq_instr_i0_t2_p,
   output [0:2] 		      rv0_lq_instr_i0_t2_t,
   output                             rv0_lq_instr_i0_t3_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_lq_instr_i0_t3_p,
   output [0:2] 		      rv0_lq_instr_i0_t3_t,
   output                             rv0_lq_instr_i0_s1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_lq_instr_i0_s1_p,
   output [0:2] 		      rv0_lq_instr_i0_s1_t,
   output                             rv0_lq_instr_i0_s2_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_lq_instr_i0_s2_p,
   output [0:2] 		      rv0_lq_instr_i0_s2_t,
   output                             rv0_lq_instr_i0_isLoad,
   output [0:3] 		      rv0_lq_instr_i0_spare,
   output                             rv0_lq_instr_i0_is_brick,
   output [0:2] 		      rv0_lq_instr_i0_brick,

   output [0:`THREADS-1] 	      rv0_lq_instr_i1_vld,
   output                             rv0_lq_instr_i1_rte_lq,
   output [0:31] 		      rv0_lq_instr_i1_instr,
   output [0:2] 		      rv0_lq_instr_i1_ucode,
   output [0:`UCODE_ENTRIES_ENC-1]     rv0_lq_instr_i1_ucode_cnt,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_lq_instr_i1_itag,
   output                             rv0_lq_instr_i1_ord,
   output                             rv0_lq_instr_i1_cord,
   output                             rv0_lq_instr_i1_spec,
   output                             rv0_lq_instr_i1_t1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_lq_instr_i1_t1_p,
   output                             rv0_lq_instr_i1_t2_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_lq_instr_i1_t2_p,
   output [0:2] 		      rv0_lq_instr_i1_t2_t,
   output                             rv0_lq_instr_i1_t3_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_lq_instr_i1_t3_p,
   output [0:2] 		      rv0_lq_instr_i1_t3_t,
   output                             rv0_lq_instr_i1_s1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_lq_instr_i1_s1_p,
   output [0:2] 		      rv0_lq_instr_i1_s1_t,
   output                             rv0_lq_instr_i1_s2_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_lq_instr_i1_s2_p,
   output [0:2] 		      rv0_lq_instr_i1_s2_t,
   output                             rv0_lq_instr_i1_isLoad,
   output [0:3] 		      rv0_lq_instr_i1_spare,
   output                             rv0_lq_instr_i1_is_brick,
   output [0:2] 		      rv0_lq_instr_i1_brick,

   output [0:`THREADS-1]                          rv_lq_rv1_i0_vld,
   output                                         rv_lq_rv1_i0_ucode_preissue,
   output                                         rv_lq_rv1_i0_2ucode,
   output [0:`UCODE_ENTRIES_ENC-1]                rv_lq_rv1_i0_ucode_cnt,
   output [0:2]                                   rv_lq_rv1_i0_s3_t,
   output                                         rv_lq_rv1_i0_isLoad,
   output                                         rv_lq_rv1_i0_isStore,
   output [0:`ITAG_SIZE_ENC-1]                    rv_lq_rv1_i0_itag,
   output                                         rv_lq_rv1_i0_rte_lq,
   output                                         rv_lq_rv1_i0_rte_sq,
   output [61-`PF_IAR_BITS+1:61]                  rv_lq_rv1_i0_ifar,

   output [0:`THREADS-1]                          rv_lq_rv1_i1_vld,
   output                                         rv_lq_rv1_i1_ucode_preissue,
   output                                         rv_lq_rv1_i1_2ucode,
   output [0:`UCODE_ENTRIES_ENC-1]                rv_lq_rv1_i1_ucode_cnt,
   output [0:2]                                   rv_lq_rv1_i1_s3_t,
   output                                         rv_lq_rv1_i1_isLoad,
   output                                         rv_lq_rv1_i1_isStore,
   output [0:`ITAG_SIZE_ENC-1]                    rv_lq_rv1_i1_itag,
   output                                         rv_lq_rv1_i1_rte_lq,
   output                                         rv_lq_rv1_i1_rte_sq,
   output [61-`PF_IAR_BITS+1:61]                  rv_lq_rv1_i1_ifar,

   output                             rv0_lq_instr_i0_s1_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_lq_instr_i0_s1_itag,
   output                             rv0_lq_instr_i0_s2_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_lq_instr_i0_s2_itag,

   output                             rv0_lq_instr_i1_s1_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_lq_instr_i1_s1_itag,
   output                             rv0_lq_instr_i1_s2_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_lq_instr_i1_s2_itag,

   //------------------------------------------------------------------------------------------------------------
   // axu0 Outputs
   //------------------------------------------------------------------------------------------------------------
   output [0:`THREADS-1] 	      rv0_axu0_instr_i0_vld,
   output                             rv0_axu0_instr_i0_rte_axu0,

   output [0:31] 		      rv0_axu0_instr_i0_instr,
   output [0:2] 		      rv0_axu0_instr_i0_ucode,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_axu0_instr_i0_itag,
   output                             rv0_axu0_instr_i0_ord,
   output                             rv0_axu0_instr_i0_cord,
   output                             rv0_axu0_instr_i0_t1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_axu0_instr_i0_t1_p,
   output [0:`GPR_POOL_ENC-1] 	      rv0_axu0_instr_i0_t2_p,
   output [0:`GPR_POOL_ENC-1] 	      rv0_axu0_instr_i0_t3_p,
   output                             rv0_axu0_instr_i0_s1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_axu0_instr_i0_s1_p,
   output                             rv0_axu0_instr_i0_s2_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_axu0_instr_i0_s2_p,
   output                             rv0_axu0_instr_i0_s3_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_axu0_instr_i0_s3_p,
   output                             rv0_axu0_instr_i0_isStore,
   output [0:3] 		      rv0_axu0_instr_i0_spare,

   output [0:`THREADS-1] 	      rv0_axu0_instr_i1_vld,
   output                             rv0_axu0_instr_i1_rte_axu0,
   output [0:31] 		      rv0_axu0_instr_i1_instr,
   output [0:2] 		      rv0_axu0_instr_i1_ucode,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_axu0_instr_i1_itag,
   output                             rv0_axu0_instr_i1_ord,
   output                             rv0_axu0_instr_i1_cord,
   output                             rv0_axu0_instr_i1_t1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_axu0_instr_i1_t1_p,
   output [0:`GPR_POOL_ENC-1] 	      rv0_axu0_instr_i1_t2_p,
   output [0:`GPR_POOL_ENC-1] 	      rv0_axu0_instr_i1_t3_p,
   output                             rv0_axu0_instr_i1_s1_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_axu0_instr_i1_s1_p,
   output                             rv0_axu0_instr_i1_s2_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_axu0_instr_i1_s2_p,
   output                             rv0_axu0_instr_i1_s3_v,
   output [0:`GPR_POOL_ENC-1] 	      rv0_axu0_instr_i1_s3_p,
   output                             rv0_axu0_instr_i1_isStore,
   output [0:3] 		      rv0_axu0_instr_i1_spare,

   output                             rv0_axu0_instr_i0_s1_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_axu0_instr_i0_s1_itag,
   output                             rv0_axu0_instr_i0_s2_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_axu0_instr_i0_s2_itag,
   output                             rv0_axu0_instr_i0_s3_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_axu0_instr_i0_s3_itag,

   output                             rv0_axu0_instr_i1_s1_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_axu0_instr_i1_s1_itag,
   output                             rv0_axu0_instr_i1_s2_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_axu0_instr_i1_s2_itag,
   output                             rv0_axu0_instr_i1_s3_dep_hit,
   output [0:`ITAG_SIZE_ENC-1] 	      rv0_axu0_instr_i1_s3_itag,

   //------------------------------------------------------------------------------------------------------------
   // Pervasive
   //------------------------------------------------------------------------------------------------------------
   inout                              vdd,
   inout                              gnd,
   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) // nclk
   input [0:`NCLK_WIDTH-1] 	      nclk,

   input                              func_sl_thold_1,
   input                              sg_1,
   input                              clkoff_b,
   input                              act_dis,
   input                              ccflush_dc,

   input                              d_mode,
   input                              delay_lclkr,
   input                              mpw1_b,
   input                              mpw2_b,
   input                              scan_in,

   output                             scan_out

 );

   //!! Bugspray Include: rv_deps ;


   wire 			      tiup;
   wire [0:`THREADS-1] 		      iu_xx_zap;


   wire                               iu6_t0_i0_act;
   wire                               iu6_t0_i1_act;
   wire                               rv0_t0_i0_act;
   wire                               rv0_t0_i1_act;


   wire 			      rv0_t0_i0_vld_d;
   wire 			      rv0_t0_i0_rte_lq_d;
   wire 			      rv0_t0_i0_rte_sq_d;
   wire 			      rv0_t0_i0_rte_fx0_d;
   wire 			      rv0_t0_i0_rte_fx1_d;
   wire 			      rv0_t0_i0_rte_axu0_d;
   wire 			      rv0_t0_i0_rte_axu1_d;
   wire [0:31] 			      rv0_t0_i0_instr_d;
   wire [62-`EFF_IFAR_WIDTH:61] 	      rv0_t0_i0_ifar_d;
   wire [0:2] 			      rv0_t0_i0_ucode_d;
   wire 			      rv0_t0_i0_2ucode_d;
   wire [0:`UCODE_ENTRIES_ENC-1]       rv0_t0_i0_ucode_cnt_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i0_itag_d;
   wire 			      rv0_t0_i0_ord_d;
   wire 			      rv0_t0_i0_cord_d;
   wire 			      rv0_t0_i0_spec_d;
   wire 			      rv0_t0_i0_t1_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i0_t1_p_d;
   wire [0:2] 			      rv0_t0_i0_t1_t_d;
   wire 			      rv0_t0_i0_t2_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i0_t2_p_d;
   wire [0:2] 			      rv0_t0_i0_t2_t_d;
   wire 			      rv0_t0_i0_t3_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i0_t3_p_d;
   wire [0:2] 			      rv0_t0_i0_t3_t_d;
   wire 			      rv0_t0_i0_s1_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i0_s1_p_d;
   wire [0:2] 			      rv0_t0_i0_s1_t_d;
   wire 			      rv0_t0_i0_s2_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i0_s2_p_d;
   wire [0:2] 			      rv0_t0_i0_s2_t_d;
   wire 			      rv0_t0_i0_s3_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i0_s3_p_d;
   wire [0:2] 			      rv0_t0_i0_s3_t_d;
   wire [0:3] 			      rv0_t0_i0_ilat_d;
   wire [0:`G_BRANCH_LEN-1] 	      rv0_t0_i0_branch_d;
   wire 			      rv0_t0_i0_isLoad_d;
   wire 			      rv0_t0_i0_isStore_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i0_s1_itag_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i0_s2_itag_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i0_s3_itag_d;
   wire [0:3] 			      rv0_t0_i0_spare_d;

   wire 			      rv0_t0_i1_vld_d;
   wire 			      rv0_t0_i1_rte_lq_d;
   wire 			      rv0_t0_i1_rte_sq_d;
   wire 			      rv0_t0_i1_rte_fx0_d;
   wire 			      rv0_t0_i1_rte_fx1_d;
   wire 			      rv0_t0_i1_rte_axu0_d;
   wire 			      rv0_t0_i1_rte_axu1_d;
   wire [0:31] 			      rv0_t0_i1_instr_d;
   wire [62-`EFF_IFAR_WIDTH:61] 	      rv0_t0_i1_ifar_d;
   wire [0:2] 			      rv0_t0_i1_ucode_d;
   wire [0:`UCODE_ENTRIES_ENC-1]       rv0_t0_i1_ucode_cnt_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i1_itag_d;
   wire 			      rv0_t0_i1_ord_d;
   wire 			      rv0_t0_i1_cord_d;
   wire 			      rv0_t0_i1_spec_d;
   wire 			      rv0_t0_i1_t1_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i1_t1_p_d;
   wire [0:2] 			      rv0_t0_i1_t1_t_d;
   wire 			      rv0_t0_i1_t2_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i1_t2_p_d;
   wire [0:2] 			      rv0_t0_i1_t2_t_d;
   wire 			      rv0_t0_i1_t3_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i1_t3_p_d;
   wire [0:2] 			      rv0_t0_i1_t3_t_d;
   wire 			      rv0_t0_i1_s1_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i1_s1_p_d;
   wire [0:2] 			      rv0_t0_i1_s1_t_d;
   wire 			      rv0_t0_i1_s2_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i1_s2_p_d;
   wire [0:2] 			      rv0_t0_i1_s2_t_d;
   wire 			      rv0_t0_i1_s3_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i1_s3_p_d;
   wire [0:2] 			      rv0_t0_i1_s3_t_d;
   wire [0:3] 			      rv0_t0_i1_ilat_d;
   wire [0:`G_BRANCH_LEN-1] 	      rv0_t0_i1_branch_d;
   wire 			      rv0_t0_i1_isLoad_d;
   wire 			      rv0_t0_i1_isStore_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i1_s1_itag_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i1_s2_itag_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i1_s3_itag_d;
   wire 			      rv0_t0_i1_s1_dep_hit_d;
   wire 			      rv0_t0_i1_s2_dep_hit_d;
   wire 			      rv0_t0_i1_s3_dep_hit_d;

   wire [0:3] 			      rv0_t0_i1_spare_d;

   wire 			      rv0_t0_i0_vld_q;
   wire 			      rv0_t0_i0_rte_lq_q;
   wire 			      rv0_t0_i0_rte_sq_q;
   wire 			      rv0_t0_i0_rte_fx0_q;
   wire 			      rv0_t0_i0_rte_fx1_q;
   wire 			      rv0_t0_i0_rte_axu0_q;
   (* analysis_not_referenced="true" *)
   wire 			      rv0_t0_i0_rte_axu1_q;
   wire [0:31] 			      rv0_t0_i0_instr_q;
   wire [62-`EFF_IFAR_WIDTH:61] 	      rv0_t0_i0_ifar_q;
   wire [0:2] 			      rv0_t0_i0_ucode_q;
   wire 			      rv0_t0_i0_2ucode_q;
   wire [0:`UCODE_ENTRIES_ENC-1]       rv0_t0_i0_ucode_cnt_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i0_itag_q;
   wire 			      rv0_t0_i0_ord_q;
   wire 			      rv0_t0_i0_cord_q;
   wire 			      rv0_t0_i0_spec_q;
   wire 			      rv0_t0_i0_t1_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i0_t1_p_q;
   wire [0:2] 			      rv0_t0_i0_t1_t_q;
   wire 			      rv0_t0_i0_t2_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i0_t2_p_q;
   wire [0:2] 			      rv0_t0_i0_t2_t_q;
   wire 			      rv0_t0_i0_t3_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i0_t3_p_q;
   wire [0:2] 			      rv0_t0_i0_t3_t_q;
   wire 			      rv0_t0_i0_s1_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i0_s1_p_q;
   wire [0:2] 			      rv0_t0_i0_s1_t_q;
   wire 			      rv0_t0_i0_s2_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i0_s2_p_q;
   wire [0:2] 			      rv0_t0_i0_s2_t_q;
   wire 			      rv0_t0_i0_s3_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i0_s3_p_q;
   wire [0:2] 			      rv0_t0_i0_s3_t_q;
   wire [0:3] 			      rv0_t0_i0_ilat_q;
   wire [0:`G_BRANCH_LEN-1] 	      rv0_t0_i0_branch_q;
   wire 			      rv0_t0_i0_isLoad_q;
   wire 			      rv0_t0_i0_isStore_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i0_s1_itag_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i0_s2_itag_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i0_s3_itag_q;
   wire [0:3] 			      rv0_t0_i0_spare_q;

   wire 			      rv0_t0_i1_vld_q;
   wire 			      rv0_t0_i1_rte_lq_q;
   wire 			      rv0_t0_i1_rte_sq_q;
   wire 			      rv0_t0_i1_rte_fx0_q;
   wire 			      rv0_t0_i1_rte_fx1_q;
   wire 			      rv0_t0_i1_rte_axu0_q;
   (* analysis_not_referenced="true" *)
   wire 			      rv0_t0_i1_rte_axu1_q;
   wire [0:31] 			      rv0_t0_i1_instr_q;
   wire [62-`EFF_IFAR_WIDTH:61] 	      rv0_t0_i1_ifar_q;
   wire [0:2] 			      rv0_t0_i1_ucode_q;
   wire [0:`UCODE_ENTRIES_ENC-1]       rv0_t0_i1_ucode_cnt_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i1_itag_q;
   wire 			      rv0_t0_i1_ord_q;
   wire 			      rv0_t0_i1_cord_q;
   wire 			      rv0_t0_i1_spec_q;
   wire 			      rv0_t0_i1_t1_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i1_t1_p_q;
   wire [0:2] 			      rv0_t0_i1_t1_t_q;
   wire 			      rv0_t0_i1_t2_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i1_t2_p_q;
   wire [0:2] 			      rv0_t0_i1_t2_t_q;
   wire 			      rv0_t0_i1_t3_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i1_t3_p_q;
   wire [0:2] 			      rv0_t0_i1_t3_t_q;
   wire 			      rv0_t0_i1_s1_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i1_s1_p_q;
   wire [0:2] 			      rv0_t0_i1_s1_t_q;
   wire 			      rv0_t0_i1_s2_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i1_s2_p_q;
   wire [0:2] 			      rv0_t0_i1_s2_t_q;
   wire 			      rv0_t0_i1_s3_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t0_i1_s3_p_q;
   wire [0:2] 			      rv0_t0_i1_s3_t_q;
   wire [0:3] 			      rv0_t0_i1_ilat_q;
   wire [0:`G_BRANCH_LEN-1] 	      rv0_t0_i1_branch_q;
   wire 			      rv0_t0_i1_isLoad_q;
   wire 			      rv0_t0_i1_isStore_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i1_s1_itag_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i1_s2_itag_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t0_i1_s3_itag_q;
   wire 			      rv0_t0_i1_s1_dep_hit_q;
   wire 			      rv0_t0_i1_s2_dep_hit_q;
   wire 			      rv0_t0_i1_s3_dep_hit_q;
   wire [0:3] 			      rv0_t0_i1_spare_q;



   wire 			      rv0_t0_i0_is_brick;
   wire [0:2] 			      rv0_t0_i0_brick;
   wire 			      rv0_t0_i1_is_brick;
   wire [0:2] 			      rv0_t0_i1_brick;

   wire [0:3] 			      rv0_t0_i0_ilat;
   wire [0:3] 			      rv0_t0_i1_ilat;

`ifndef THREADS1
   wire                               iu6_t1_i0_act;
   wire                               iu6_t1_i1_act;
   wire                               rv0_t1_i0_act;
   wire                               rv0_t1_i1_act;


   wire 			      rv0_t1_i0_vld_d;
   wire 			      rv0_t1_i0_rte_lq_d;
   wire 			      rv0_t1_i0_rte_sq_d;
   wire 			      rv0_t1_i0_rte_fx0_d;
   wire 			      rv0_t1_i0_rte_fx1_d;
   wire 			      rv0_t1_i0_rte_axu0_d;
   wire 			      rv0_t1_i0_rte_axu1_d;
   wire [0:31] 			      rv0_t1_i0_instr_d;
   wire [62-`EFF_IFAR_WIDTH:61] 	      rv0_t1_i0_ifar_d;
   wire [0:2] 			      rv0_t1_i0_ucode_d;
   wire 			      rv0_t1_i0_2ucode_d;
   wire [0:`UCODE_ENTRIES_ENC-1]       rv0_t1_i0_ucode_cnt_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i0_itag_d;
   wire 			      rv0_t1_i0_ord_d;
   wire 			      rv0_t1_i0_cord_d;
   wire 			      rv0_t1_i0_spec_d;
   wire 			      rv0_t1_i0_t1_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i0_t1_p_d;
   wire [0:2] 			      rv0_t1_i0_t1_t_d;
   wire 			      rv0_t1_i0_t2_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i0_t2_p_d;
   wire [0:2] 			      rv0_t1_i0_t2_t_d;
   wire 			      rv0_t1_i0_t3_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i0_t3_p_d;
   wire [0:2] 			      rv0_t1_i0_t3_t_d;
   wire 			      rv0_t1_i0_s1_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i0_s1_p_d;
   wire [0:2] 			      rv0_t1_i0_s1_t_d;
   wire 			      rv0_t1_i0_s2_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i0_s2_p_d;
   wire [0:2] 			      rv0_t1_i0_s2_t_d;
   wire 			      rv0_t1_i0_s3_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i0_s3_p_d;
   wire [0:2] 			      rv0_t1_i0_s3_t_d;
   wire [0:3] 			      rv0_t1_i0_ilat_d;
   wire [0:`G_BRANCH_LEN-1] 	      rv0_t1_i0_branch_d;
   wire 			      rv0_t1_i0_isLoad_d;
   wire 			      rv0_t1_i0_isStore_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i0_s1_itag_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i0_s2_itag_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i0_s3_itag_d;
   wire [0:3] 			      rv0_t1_i0_spare_d;

   wire 			      rv0_t1_i1_vld_d;
   wire 			      rv0_t1_i1_rte_lq_d;
   wire 			      rv0_t1_i1_rte_sq_d;
   wire 			      rv0_t1_i1_rte_fx0_d;
   wire 			      rv0_t1_i1_rte_fx1_d;
   wire 			      rv0_t1_i1_rte_axu0_d;
   wire 			      rv0_t1_i1_rte_axu1_d;
   wire [0:31] 			      rv0_t1_i1_instr_d;
   wire [62-`EFF_IFAR_WIDTH:61] 	      rv0_t1_i1_ifar_d;
   wire [0:2] 			      rv0_t1_i1_ucode_d;
   wire [0:`UCODE_ENTRIES_ENC-1]       rv0_t1_i1_ucode_cnt_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i1_itag_d;
   wire 			      rv0_t1_i1_ord_d;
   wire 			      rv0_t1_i1_cord_d;
   wire 			      rv0_t1_i1_spec_d;
   wire 			      rv0_t1_i1_t1_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i1_t1_p_d;
   wire [0:2] 			      rv0_t1_i1_t1_t_d;
   wire 			      rv0_t1_i1_t2_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i1_t2_p_d;
   wire [0:2] 			      rv0_t1_i1_t2_t_d;
   wire 			      rv0_t1_i1_t3_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i1_t3_p_d;
   wire [0:2] 			      rv0_t1_i1_t3_t_d;
   wire 			      rv0_t1_i1_s1_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i1_s1_p_d;
   wire [0:2] 			      rv0_t1_i1_s1_t_d;
   wire 			      rv0_t1_i1_s2_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i1_s2_p_d;
   wire [0:2] 			      rv0_t1_i1_s2_t_d;
   wire 			      rv0_t1_i1_s3_v_d;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i1_s3_p_d;
   wire [0:2] 			      rv0_t1_i1_s3_t_d;
   wire [0:3] 			      rv0_t1_i1_ilat_d;
   wire [0:`G_BRANCH_LEN-1] 	      rv0_t1_i1_branch_d;
   wire 			      rv0_t1_i1_isLoad_d;
   wire 			      rv0_t1_i1_isStore_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i1_s1_itag_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i1_s2_itag_d;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i1_s3_itag_d;
   wire 			      rv0_t1_i1_s1_dep_hit_d;
   wire 			      rv0_t1_i1_s2_dep_hit_d;
   wire 			      rv0_t1_i1_s3_dep_hit_d;
   wire [0:3] 			      rv0_t1_i1_spare_d;

   wire 			      rv0_t1_i0_vld_q;
   wire 			      rv0_t1_i0_rte_lq_q;
   wire 			      rv0_t1_i0_rte_sq_q;
   wire 			      rv0_t1_i0_rte_fx0_q;
   wire 			      rv0_t1_i0_rte_fx1_q;
   wire 			      rv0_t1_i0_rte_axu0_q;
   (* analysis_not_referenced="true" *)
   wire 			      rv0_t1_i0_rte_axu1_q;
   wire [0:31] 			      rv0_t1_i0_instr_q;
   wire [62-`EFF_IFAR_WIDTH:61] 	      rv0_t1_i0_ifar_q;
   wire [0:2] 			      rv0_t1_i0_ucode_q;
   wire 			      rv0_t1_i0_2ucode_q;
   wire [0:`UCODE_ENTRIES_ENC-1]       rv0_t1_i0_ucode_cnt_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i0_itag_q;
   wire 			      rv0_t1_i0_ord_q;
   wire 			      rv0_t1_i0_cord_q;
   wire 			      rv0_t1_i0_spec_q;
   wire 			      rv0_t1_i0_t1_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i0_t1_p_q;
   wire [0:2] 			      rv0_t1_i0_t1_t_q;
   wire 			      rv0_t1_i0_t2_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i0_t2_p_q;
   wire [0:2] 			      rv0_t1_i0_t2_t_q;
   wire 			      rv0_t1_i0_t3_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i0_t3_p_q;
   wire [0:2] 			      rv0_t1_i0_t3_t_q;
   wire 			      rv0_t1_i0_s1_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i0_s1_p_q;
   wire [0:2] 			      rv0_t1_i0_s1_t_q;
   wire 			      rv0_t1_i0_s2_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i0_s2_p_q;
   wire [0:2] 			      rv0_t1_i0_s2_t_q;
   wire 			      rv0_t1_i0_s3_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i0_s3_p_q;
   wire [0:2] 			      rv0_t1_i0_s3_t_q;
   wire [0:3] 			      rv0_t1_i0_ilat_q;
   wire [0:`G_BRANCH_LEN-1] 	      rv0_t1_i0_branch_q;
   wire 			      rv0_t1_i0_isLoad_q;
   wire 			      rv0_t1_i0_isStore_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i0_s1_itag_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i0_s2_itag_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i0_s3_itag_q;
   wire [0:3] 			      rv0_t1_i0_spare_q;

   wire 			      rv0_t1_i1_vld_q;
   wire 			      rv0_t1_i1_rte_lq_q;
   wire 			      rv0_t1_i1_rte_sq_q;
   wire 			      rv0_t1_i1_rte_fx0_q;
   wire 			      rv0_t1_i1_rte_fx1_q;
   wire 			      rv0_t1_i1_rte_axu0_q;
   (* analysis_not_referenced="true" *)
   wire 			      rv0_t1_i1_rte_axu1_q;
   wire [0:31] 			      rv0_t1_i1_instr_q;
   wire [62-`EFF_IFAR_WIDTH:61] 	      rv0_t1_i1_ifar_q;
   wire [0:2] 			      rv0_t1_i1_ucode_q;
   wire [0:`UCODE_ENTRIES_ENC-1]       rv0_t1_i1_ucode_cnt_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i1_itag_q;
   wire 			      rv0_t1_i1_ord_q;
   wire 			      rv0_t1_i1_cord_q;
   wire 			      rv0_t1_i1_spec_q;
   wire 			      rv0_t1_i1_t1_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i1_t1_p_q;
   wire [0:2] 			      rv0_t1_i1_t1_t_q;
   wire 			      rv0_t1_i1_t2_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i1_t2_p_q;
   wire [0:2] 			      rv0_t1_i1_t2_t_q;
   wire 			      rv0_t1_i1_t3_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i1_t3_p_q;
   wire [0:2] 			      rv0_t1_i1_t3_t_q;
   wire 			      rv0_t1_i1_s1_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i1_s1_p_q;
   wire [0:2] 			      rv0_t1_i1_s1_t_q;
   wire 			      rv0_t1_i1_s2_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i1_s2_p_q;
   wire [0:2] 			      rv0_t1_i1_s2_t_q;
   wire 			      rv0_t1_i1_s3_v_q;
   wire [0:`GPR_POOL_ENC-1] 	      rv0_t1_i1_s3_p_q;
   wire [0:2] 			      rv0_t1_i1_s3_t_q;
   wire [0:3] 			      rv0_t1_i1_ilat_q;
   wire [0:`G_BRANCH_LEN-1] 	      rv0_t1_i1_branch_q;
   wire 			      rv0_t1_i1_isLoad_q;
   wire 			      rv0_t1_i1_isStore_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i1_s1_itag_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i1_s2_itag_q;
   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_t1_i1_s3_itag_q;
   wire 			      rv0_t1_i1_s1_dep_hit_q;
   wire 			      rv0_t1_i1_s2_dep_hit_q;
   wire 			      rv0_t1_i1_s3_dep_hit_q;
   wire [0:3] 			      rv0_t1_i1_spare_q;


   wire 			      rv0_t1_i0_is_brick;
   wire [0:2] 			      rv0_t1_i0_brick;
   wire 			      rv0_t1_i1_is_brick;
   wire [0:2] 			      rv0_t1_i1_brick;

   wire [0:3] 			      rv0_t1_i0_ilat;
   wire [0:3] 			      rv0_t1_i1_ilat;

`endif


   wire [0:`THREADS-1] 		      rv0_instr_i0_flushed_d;
   wire [0:`THREADS-1] 		      rv0_instr_i1_flushed_d;
   wire [0:`THREADS-1] 		      rv0_instr_i0_flushed_q;
   wire [0:`THREADS-1] 		      rv0_instr_i1_flushed_q;


   wire [0:`THREADS-1] 		      rv0_instr_i0_dep_val;
   wire [0:`THREADS-1] 		      rv0_instr_i1_dep_val;

   wire [0:`THREADS-1] 		      rv0_instr_i0_s1_dep_hit;
   wire [0:`THREADS-1] 		      rv0_instr_i0_s2_dep_hit;
   wire [0:`THREADS-1] 		      rv0_instr_i0_s3_dep_hit;
   wire [0:`THREADS-1] 		      rv0_instr_i1_s1_dep_hit;
   wire [0:`THREADS-1] 		      rv0_instr_i1_s2_dep_hit;
   wire [0:`THREADS-1] 		      rv0_instr_i1_s3_dep_hit;

   wire [0:`THREADS-1] 		      rv0_instr_i1_local_s1_dep_hit;
   wire [0:`THREADS-1] 		      rv0_instr_i1_local_s2_dep_hit;
   wire [0:`THREADS-1] 		      rv0_instr_i1_local_s3_dep_hit;
   wire [0:`THREADS-1] 		      rv0_instr_i1_s1_dep_hit_loc;
   wire [0:`THREADS-1] 		      rv0_instr_i1_s2_dep_hit_loc;
   wire [0:`THREADS-1] 		      rv0_instr_i1_s3_dep_hit_loc;

   wire [0:`ITAG_SIZE_ENC-1] 	      rv0_instr_i1_s1_itag_loc[0:`THREADS-1];
   wire [0:`ITAG_SIZE_ENC-1]	      rv0_instr_i1_s2_itag_loc[0:`THREADS-1];
   wire [0:`ITAG_SIZE_ENC-1]	      rv0_instr_i1_s3_itag_loc[0:`THREADS-1];


   wire [0:`THREADS-1] 		      rv1_lq_instr_i0_vld_d;
   wire [0:`THREADS-1] 		      rv1_lq_instr_i1_vld_d;
   wire [0:`THREADS-1] 		      rv1_lq_instr_i0_vld_q;
   wire [0:`THREADS-1] 		      rv1_lq_instr_i1_vld_q;

   wire                               rv1_lq_instr_i0_rte_lq_d;
   wire                               rv1_lq_instr_i0_rte_sq_d;
   wire                               rv1_lq_instr_i0_rte_lq_q;
   wire                               rv1_lq_instr_i0_rte_sq_q;
   wire                               rv1_lq_instr_i1_rte_lq_d;
   wire                               rv1_lq_instr_i1_rte_sq_d;
   wire                               rv1_lq_instr_i1_rte_lq_q;
   wire                               rv1_lq_instr_i1_rte_sq_q;

   wire [61-`PF_IAR_BITS+1:61] 	      rv0_lq_instr_i0_ifar;
   wire [61-`PF_IAR_BITS+1:61] 	      rv0_lq_instr_i1_ifar;
   wire [61-`PF_IAR_BITS+1:61] 	      rv1_lq_instr_i0_ifar_d;
   wire [61-`PF_IAR_BITS+1:61] 	      rv1_lq_instr_i1_ifar_d;
   wire [61-`PF_IAR_BITS+1:61] 	      rv1_lq_instr_i0_ifar_q;
   wire [61-`PF_IAR_BITS+1:61] 	      rv1_lq_instr_i1_ifar_q;

   wire [0: `ITAG_SIZE_ENC-1]         rv1_lq_instr_i0_itag_d;
   wire [0:2]                         rv1_lq_instr_i0_ucode_d;
   wire                               rv1_lq_instr_i0_ucode_preissue_d;
   wire [0:`UCODE_ENTRIES_ENC-1]      rv1_lq_instr_i0_ucode_cnt_d;
   wire                               rv1_lq_instr_i0_2ucode_d;
   wire [0:2]                         rv1_lq_instr_i0_s3_t_d;
   wire                               rv1_lq_instr_i0_isLoad_d;
   wire                               rv1_lq_instr_i0_isStore_d;
   wire [0: `ITAG_SIZE_ENC-1]         rv1_lq_instr_i1_itag_d;
   wire [0:2]                         rv1_lq_instr_i1_ucode_d;
   wire                               rv1_lq_instr_i1_ucode_preissue_d;
   wire [0:`UCODE_ENTRIES_ENC-1]      rv1_lq_instr_i1_ucode_cnt_d;
   wire                               rv1_lq_instr_i1_2ucode_d;
   wire [0:2]                         rv1_lq_instr_i1_s3_t_d;
   wire                               rv1_lq_instr_i1_isLoad_d;
   wire                               rv1_lq_instr_i1_isStore_d;
   wire [0: `ITAG_SIZE_ENC-1]         rv1_lq_instr_i0_itag_q;
   wire                               rv1_lq_instr_i0_ucode_preissue_q;
   wire [0:`UCODE_ENTRIES_ENC-1]      rv1_lq_instr_i0_ucode_cnt_q;
   wire                               rv1_lq_instr_i0_2ucode_q;
   wire [0:2]                         rv1_lq_instr_i0_s3_t_q;
   wire                               rv1_lq_instr_i0_isLoad_q;
   wire                               rv1_lq_instr_i0_isStore_q;
   wire [0: `ITAG_SIZE_ENC-1]         rv1_lq_instr_i1_itag_q;
   wire                               rv1_lq_instr_i1_ucode_preissue_q;
   wire [0:`UCODE_ENTRIES_ENC-1]      rv1_lq_instr_i1_ucode_cnt_q;
   wire                               rv1_lq_instr_i1_2ucode_q;
   wire [0:2]                         rv1_lq_instr_i1_s3_t_q;
   wire                               rv1_lq_instr_i1_isLoad_q;
   wire                               rv1_lq_instr_i1_isStore_q;


   wire                               func_sl_thold_0;
   wire                               func_sl_thold_0_b;
   wire                               sg_0;

`ifndef THREADS1
   wire [0:2] 			      rv0_fx0_i0_sel;
   wire [0:2] 			      rv0_fx0_i1_sel;
   wire [0:2] 			      rv0_fx1_i0_sel;
   wire [0:2] 			      rv0_fx1_i1_sel;
   wire [0:2] 			      rv0_lq_i0_sel;
   wire [0:2] 			      rv0_lq_i1_sel;
   wire [0:2] 			      rv0_axu0_i0_sel;
   wire [0:2] 			      rv0_axu0_i1_sel;
`endif


   parameter                          cp_flush_offset = 0 + 0;

   parameter                          dep0_offset = cp_flush_offset + `THREADS;
   parameter                          rv0_t0_i0_vld_offset = dep0_offset + 1;
   parameter                          rv0_t0_i0_rte_lq_offset = rv0_t0_i0_vld_offset + 1;
   parameter                          rv0_t0_i0_rte_sq_offset = rv0_t0_i0_rte_lq_offset + 1;
   parameter                          rv0_t0_i0_rte_fx0_offset = rv0_t0_i0_rte_sq_offset + 1;
   parameter                          rv0_t0_i0_rte_fx1_offset = rv0_t0_i0_rte_fx0_offset + 1;
   parameter                          rv0_t0_i0_rte_axu0_offset = rv0_t0_i0_rte_fx1_offset + 1;
   parameter                          rv0_t0_i0_rte_axu1_offset = rv0_t0_i0_rte_axu0_offset + 1;
   parameter                          rv0_t0_i0_instr_offset = rv0_t0_i0_rte_axu1_offset + 1;
   parameter                          rv0_t0_i0_ifar_offset = rv0_t0_i0_instr_offset + 32;
   parameter                          rv0_t0_i0_ucode_offset = rv0_t0_i0_ifar_offset + `EFF_IFAR_WIDTH;
   parameter                          rv0_t0_i0_2ucode_offset = rv0_t0_i0_ucode_offset + 3;
   parameter                          rv0_t0_i0_ucode_cnt_offset = rv0_t0_i0_2ucode_offset + 1;
   parameter                          rv0_t0_i0_itag_offset = rv0_t0_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
   parameter                          rv0_t0_i0_ord_offset = rv0_t0_i0_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t0_i0_cord_offset = rv0_t0_i0_ord_offset + 1;
   parameter                          rv0_t0_i0_spec_offset = rv0_t0_i0_cord_offset + 1;
   parameter                          rv0_t0_i0_t1_v_offset = rv0_t0_i0_spec_offset + 1;
   parameter                          rv0_t0_i0_t1_p_offset = rv0_t0_i0_t1_v_offset + 1;
   parameter                          rv0_t0_i0_t1_t_offset = rv0_t0_i0_t1_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t0_i0_t2_v_offset = rv0_t0_i0_t1_t_offset + 3;
   parameter                          rv0_t0_i0_t2_p_offset = rv0_t0_i0_t2_v_offset + 1;
   parameter                          rv0_t0_i0_t2_t_offset = rv0_t0_i0_t2_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t0_i0_t3_v_offset = rv0_t0_i0_t2_t_offset + 3;
   parameter                          rv0_t0_i0_t3_p_offset = rv0_t0_i0_t3_v_offset + 1;
   parameter                          rv0_t0_i0_t3_t_offset = rv0_t0_i0_t3_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t0_i0_s1_v_offset = rv0_t0_i0_t3_t_offset + 3;
   parameter                          rv0_t0_i0_s1_p_offset = rv0_t0_i0_s1_v_offset + 1;
   parameter                          rv0_t0_i0_s1_t_offset = rv0_t0_i0_s1_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t0_i0_s2_v_offset = rv0_t0_i0_s1_t_offset + 3;
   parameter                          rv0_t0_i0_s2_p_offset = rv0_t0_i0_s2_v_offset + 1;
   parameter                          rv0_t0_i0_s2_t_offset = rv0_t0_i0_s2_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t0_i0_s3_v_offset = rv0_t0_i0_s2_t_offset + 3;
   parameter                          rv0_t0_i0_s3_p_offset = rv0_t0_i0_s3_v_offset + 1;
   parameter                          rv0_t0_i0_s3_t_offset = rv0_t0_i0_s3_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t0_i0_s1_itag_offset = rv0_t0_i0_s3_t_offset + 3;
   parameter                          rv0_t0_i0_s2_itag_offset = rv0_t0_i0_s1_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t0_i0_s3_itag_offset = rv0_t0_i0_s2_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t0_i0_ilat_offset = rv0_t0_i0_s3_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t0_i0_branch_offset = rv0_t0_i0_ilat_offset + 4;
   parameter                          rv0_t0_i0_isLoad_offset = rv0_t0_i0_branch_offset + `G_BRANCH_LEN;
   parameter                          rv0_t0_i0_isStore_offset = rv0_t0_i0_isLoad_offset + 1;
   parameter                          rv0_t0_i0_spare_offset = rv0_t0_i0_isStore_offset + 1;

   parameter                          rv0_t0_i1_vld_offset = rv0_t0_i0_spare_offset + 4;
   parameter                          rv0_t0_i1_rte_lq_offset = rv0_t0_i1_vld_offset + 1;
   parameter                          rv0_t0_i1_rte_sq_offset = rv0_t0_i1_rte_lq_offset + 1;
   parameter                          rv0_t0_i1_rte_fx0_offset = rv0_t0_i1_rte_sq_offset + 1;
   parameter                          rv0_t0_i1_rte_fx1_offset = rv0_t0_i1_rte_fx0_offset + 1;
   parameter                          rv0_t0_i1_rte_axu0_offset = rv0_t0_i1_rte_fx1_offset + 1;
   parameter                          rv0_t0_i1_rte_axu1_offset = rv0_t0_i1_rte_axu0_offset + 1;
   parameter                          rv0_t0_i1_instr_offset = rv0_t0_i1_rte_axu1_offset + 1;
   parameter                          rv0_t0_i1_ifar_offset = rv0_t0_i1_instr_offset + 32;
   parameter                          rv0_t0_i1_ucode_offset = rv0_t0_i1_ifar_offset + `EFF_IFAR_WIDTH;
   parameter                          rv0_t0_i1_ucode_cnt_offset = rv0_t0_i1_ucode_offset + 3;
   parameter                          rv0_t0_i1_itag_offset = rv0_t0_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
   parameter                          rv0_t0_i1_ord_offset = rv0_t0_i1_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t0_i1_cord_offset = rv0_t0_i1_ord_offset + 1;
   parameter                          rv0_t0_i1_spec_offset = rv0_t0_i1_cord_offset + 1;
   parameter                          rv0_t0_i1_t1_v_offset = rv0_t0_i1_spec_offset + 1;
   parameter                          rv0_t0_i1_t1_p_offset = rv0_t0_i1_t1_v_offset + 1;
   parameter                          rv0_t0_i1_t1_t_offset = rv0_t0_i1_t1_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t0_i1_t2_v_offset = rv0_t0_i1_t1_t_offset + 3;
   parameter                          rv0_t0_i1_t2_p_offset = rv0_t0_i1_t2_v_offset + 1;
   parameter                          rv0_t0_i1_t2_t_offset = rv0_t0_i1_t2_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t0_i1_t3_v_offset = rv0_t0_i1_t2_t_offset + 3;
   parameter                          rv0_t0_i1_t3_p_offset = rv0_t0_i1_t3_v_offset + 1;
   parameter                          rv0_t0_i1_t3_t_offset = rv0_t0_i1_t3_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t0_i1_s1_v_offset = rv0_t0_i1_t3_t_offset + 3;
   parameter                          rv0_t0_i1_s1_p_offset = rv0_t0_i1_s1_v_offset + 1;
   parameter                          rv0_t0_i1_s1_t_offset = rv0_t0_i1_s1_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t0_i1_s2_v_offset = rv0_t0_i1_s1_t_offset + 3;
   parameter                          rv0_t0_i1_s2_p_offset = rv0_t0_i1_s2_v_offset + 1;
   parameter                          rv0_t0_i1_s2_t_offset = rv0_t0_i1_s2_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t0_i1_s3_v_offset = rv0_t0_i1_s2_t_offset + 3;
   parameter                          rv0_t0_i1_s3_p_offset = rv0_t0_i1_s3_v_offset + 1;
   parameter                          rv0_t0_i1_s3_t_offset = rv0_t0_i1_s3_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t0_i1_s1_itag_offset = rv0_t0_i1_s3_t_offset + 3;
   parameter                          rv0_t0_i1_s2_itag_offset = rv0_t0_i1_s1_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t0_i1_s3_itag_offset = rv0_t0_i1_s2_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t0_i1_s1_dep_hit_offset = rv0_t0_i1_s3_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t0_i1_s2_dep_hit_offset = rv0_t0_i1_s1_dep_hit_offset + 1;
   parameter                          rv0_t0_i1_s3_dep_hit_offset = rv0_t0_i1_s2_dep_hit_offset + 1;
   parameter                          rv0_t0_i1_ilat_offset = rv0_t0_i1_s3_dep_hit_offset + 1;
   parameter                          rv0_t0_i1_branch_offset = rv0_t0_i1_ilat_offset + 4;
   parameter                          rv0_t0_i1_isLoad_offset = rv0_t0_i1_branch_offset + `G_BRANCH_LEN;
   parameter                          rv0_t0_i1_isStore_offset = rv0_t0_i1_isLoad_offset + 1;
   parameter                          rv0_t0_i1_spare_offset = rv0_t0_i1_isStore_offset + 1;

`ifndef THREADS1
   parameter                          dep1_offset = rv0_t0_i1_spare_offset + 4;
   parameter                          rv0_t1_i0_vld_offset = dep1_offset + 1;
   parameter                          rv0_t1_i0_rte_lq_offset = rv0_t1_i0_vld_offset + 1;
   parameter                          rv0_t1_i0_rte_sq_offset = rv0_t1_i0_rte_lq_offset + 1;
   parameter                          rv0_t1_i0_rte_fx0_offset = rv0_t1_i0_rte_sq_offset + 1;
   parameter                          rv0_t1_i0_rte_fx1_offset = rv0_t1_i0_rte_fx0_offset + 1;
   parameter                          rv0_t1_i0_rte_axu0_offset = rv0_t1_i0_rte_fx1_offset + 1;
   parameter                          rv0_t1_i0_rte_axu1_offset = rv0_t1_i0_rte_axu0_offset + 1;
   parameter                          rv0_t1_i0_instr_offset = rv0_t1_i0_rte_axu1_offset + 1;
   parameter                          rv0_t1_i0_ifar_offset = rv0_t1_i0_instr_offset + 32;
   parameter                          rv0_t1_i0_ucode_offset = rv0_t1_i0_ifar_offset + `EFF_IFAR_WIDTH;
   parameter                          rv0_t1_i0_2ucode_offset = rv0_t1_i0_ucode_offset + 3;
   parameter                          rv0_t1_i0_ucode_cnt_offset = rv0_t1_i0_2ucode_offset + 1;
   parameter                          rv0_t1_i0_itag_offset = rv0_t1_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
   parameter                          rv0_t1_i0_ord_offset = rv0_t1_i0_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t1_i0_cord_offset = rv0_t1_i0_ord_offset + 1;
   parameter                          rv0_t1_i0_spec_offset = rv0_t1_i0_cord_offset + 1;
   parameter                          rv0_t1_i0_t1_v_offset = rv0_t1_i0_spec_offset + 1;
   parameter                          rv0_t1_i0_t1_p_offset = rv0_t1_i0_t1_v_offset + 1;
   parameter                          rv0_t1_i0_t1_t_offset = rv0_t1_i0_t1_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t1_i0_t2_v_offset = rv0_t1_i0_t1_t_offset + 3;
   parameter                          rv0_t1_i0_t2_p_offset = rv0_t1_i0_t2_v_offset + 1;
   parameter                          rv0_t1_i0_t2_t_offset = rv0_t1_i0_t2_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t1_i0_t3_v_offset = rv0_t1_i0_t2_t_offset + 3;
   parameter                          rv0_t1_i0_t3_p_offset = rv0_t1_i0_t3_v_offset + 1;
   parameter                          rv0_t1_i0_t3_t_offset = rv0_t1_i0_t3_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t1_i0_s1_v_offset = rv0_t1_i0_t3_t_offset + 3;
   parameter                          rv0_t1_i0_s1_p_offset = rv0_t1_i0_s1_v_offset + 1;
   parameter                          rv0_t1_i0_s1_t_offset = rv0_t1_i0_s1_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t1_i0_s2_v_offset = rv0_t1_i0_s1_t_offset + 3;
   parameter                          rv0_t1_i0_s2_p_offset = rv0_t1_i0_s2_v_offset + 1;
   parameter                          rv0_t1_i0_s2_t_offset = rv0_t1_i0_s2_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t1_i0_s3_v_offset = rv0_t1_i0_s2_t_offset + 3;
   parameter                          rv0_t1_i0_s3_p_offset = rv0_t1_i0_s3_v_offset + 1;
   parameter                          rv0_t1_i0_s3_t_offset = rv0_t1_i0_s3_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t1_i0_s1_itag_offset = rv0_t1_i0_s3_t_offset + 3;
   parameter                          rv0_t1_i0_s2_itag_offset = rv0_t1_i0_s1_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t1_i0_s3_itag_offset = rv0_t1_i0_s2_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t1_i0_ilat_offset = rv0_t1_i0_s3_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t1_i0_branch_offset = rv0_t1_i0_ilat_offset + 4;
   parameter                          rv0_t1_i0_isLoad_offset = rv0_t1_i0_branch_offset + `G_BRANCH_LEN;
   parameter                          rv0_t1_i0_isStore_offset = rv0_t1_i0_isLoad_offset + 1;
   parameter                          rv0_t1_i0_spare_offset = rv0_t1_i0_isStore_offset + 1;

   parameter                          rv0_t1_i1_vld_offset = rv0_t1_i0_spare_offset + 4;
   parameter                          rv0_t1_i1_rte_lq_offset = rv0_t1_i1_vld_offset + 1;
   parameter                          rv0_t1_i1_rte_sq_offset = rv0_t1_i1_rte_lq_offset + 1;
   parameter                          rv0_t1_i1_rte_fx0_offset = rv0_t1_i1_rte_sq_offset + 1;
   parameter                          rv0_t1_i1_rte_fx1_offset = rv0_t1_i1_rte_fx0_offset + 1;
   parameter                          rv0_t1_i1_rte_axu0_offset = rv0_t1_i1_rte_fx1_offset + 1;
   parameter                          rv0_t1_i1_rte_axu1_offset = rv0_t1_i1_rte_axu0_offset + 1;
   parameter                          rv0_t1_i1_instr_offset = rv0_t1_i1_rte_axu1_offset + 1;
   parameter                          rv0_t1_i1_ifar_offset = rv0_t1_i1_instr_offset + 32;
   parameter                          rv0_t1_i1_ucode_offset = rv0_t1_i1_ifar_offset + `EFF_IFAR_WIDTH;
   parameter                          rv0_t1_i1_ucode_cnt_offset = rv0_t1_i1_ucode_offset + 3;
   parameter                          rv0_t1_i1_itag_offset = rv0_t1_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
   parameter                          rv0_t1_i1_ord_offset = rv0_t1_i1_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t1_i1_cord_offset = rv0_t1_i1_ord_offset + 1;
   parameter                          rv0_t1_i1_spec_offset = rv0_t1_i1_cord_offset + 1;
   parameter                          rv0_t1_i1_t1_v_offset = rv0_t1_i1_spec_offset + 1;
   parameter                          rv0_t1_i1_t1_p_offset = rv0_t1_i1_t1_v_offset + 1;
   parameter                          rv0_t1_i1_t1_t_offset = rv0_t1_i1_t1_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t1_i1_t2_v_offset = rv0_t1_i1_t1_t_offset + 3;
   parameter                          rv0_t1_i1_t2_p_offset = rv0_t1_i1_t2_v_offset + 1;
   parameter                          rv0_t1_i1_t2_t_offset = rv0_t1_i1_t2_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t1_i1_t3_v_offset = rv0_t1_i1_t2_t_offset + 3;
   parameter                          rv0_t1_i1_t3_p_offset = rv0_t1_i1_t3_v_offset + 1;
   parameter                          rv0_t1_i1_t3_t_offset = rv0_t1_i1_t3_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t1_i1_s1_v_offset = rv0_t1_i1_t3_t_offset + 3;
   parameter                          rv0_t1_i1_s1_p_offset = rv0_t1_i1_s1_v_offset + 1;
   parameter                          rv0_t1_i1_s1_t_offset = rv0_t1_i1_s1_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t1_i1_s2_v_offset = rv0_t1_i1_s1_t_offset + 3;
   parameter                          rv0_t1_i1_s2_p_offset = rv0_t1_i1_s2_v_offset + 1;
   parameter                          rv0_t1_i1_s2_t_offset = rv0_t1_i1_s2_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t1_i1_s3_v_offset = rv0_t1_i1_s2_t_offset + 3;
   parameter                          rv0_t1_i1_s3_p_offset = rv0_t1_i1_s3_v_offset + 1;
   parameter                          rv0_t1_i1_s3_t_offset = rv0_t1_i1_s3_p_offset + `GPR_POOL_ENC;
   parameter                          rv0_t1_i1_s1_itag_offset = rv0_t1_i1_s3_t_offset + 3;
   parameter                          rv0_t1_i1_s2_itag_offset = rv0_t1_i1_s1_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t1_i1_s3_itag_offset = rv0_t1_i1_s2_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t1_i1_s1_dep_hit_offset = rv0_t1_i1_s3_itag_offset + `ITAG_SIZE_ENC;
   parameter                          rv0_t1_i1_s2_dep_hit_offset = rv0_t1_i1_s1_dep_hit_offset + 1;
   parameter                          rv0_t1_i1_s3_dep_hit_offset = rv0_t1_i1_s2_dep_hit_offset + 1;
   parameter                          rv0_t1_i1_ilat_offset = rv0_t1_i1_s3_dep_hit_offset + 1;
   parameter                          rv0_t1_i1_branch_offset = rv0_t1_i1_ilat_offset + 4;
   parameter                          rv0_t1_i1_isLoad_offset = rv0_t1_i1_branch_offset + `G_BRANCH_LEN;
   parameter                          rv0_t1_i1_isStore_offset = rv0_t1_i1_isLoad_offset + 1;
   parameter                          rv0_t1_i1_spare_offset = rv0_t1_i1_isStore_offset + 1;


   parameter                          rv0_instr_i0_flushed_offset = rv0_t1_i1_spare_offset + 4;
`else

   parameter                          rv0_instr_i0_flushed_offset = rv0_t0_i1_spare_offset + 4;
`endif

   parameter                          rv0_instr_i1_flushed_offset = rv0_instr_i0_flushed_offset + `THREADS;
   parameter                          rv1_lq_instr_i0_vld_offset =  rv0_instr_i1_flushed_offset + `THREADS;
   parameter                          rv1_lq_instr_i0_rte_lq_offset = rv1_lq_instr_i0_vld_offset + `THREADS;
   parameter                          rv1_lq_instr_i0_rte_sq_offset = rv1_lq_instr_i0_rte_lq_offset + 1;
   parameter                          rv1_lq_instr_i0_ucode_preissue_offset = rv1_lq_instr_i0_rte_sq_offset + 1;
   parameter                          rv1_lq_instr_i0_2ucode_offset = rv1_lq_instr_i0_ucode_preissue_offset + 1;
   parameter                          rv1_lq_instr_i0_ucode_cnt_offset = rv1_lq_instr_i0_2ucode_offset + 1;
   parameter                          rv1_lq_instr_i0_s3_t_offset = rv1_lq_instr_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
   parameter                          rv1_lq_instr_i0_isLoad_offset = rv1_lq_instr_i0_s3_t_offset + 3;
   parameter                          rv1_lq_instr_i0_isStore_offset = rv1_lq_instr_i0_isLoad_offset + 1;
   parameter                          rv1_lq_instr_i0_itag_offset = rv1_lq_instr_i0_isStore_offset + 1;
   parameter                          rv1_lq_instr_i0_ifar_offset = rv1_lq_instr_i0_itag_offset+ `ITAG_SIZE_ENC;

   parameter                          rv1_lq_instr_i1_vld_offset = rv1_lq_instr_i0_ifar_offset + `PF_IAR_BITS;
   parameter                          rv1_lq_instr_i1_rte_lq_offset = rv1_lq_instr_i1_vld_offset + `THREADS;
   parameter                          rv1_lq_instr_i1_rte_sq_offset = rv1_lq_instr_i1_rte_lq_offset + 1;
   parameter                          rv1_lq_instr_i1_ucode_preissue_offset = rv1_lq_instr_i1_rte_sq_offset + 1;
   parameter                          rv1_lq_instr_i1_2ucode_offset = rv1_lq_instr_i1_ucode_preissue_offset + 1;
   parameter                          rv1_lq_instr_i1_ucode_cnt_offset = rv1_lq_instr_i1_2ucode_offset + 1;
   parameter                          rv1_lq_instr_i1_s3_t_offset = rv1_lq_instr_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
   parameter                          rv1_lq_instr_i1_isLoad_offset = rv1_lq_instr_i1_s3_t_offset + 3;
   parameter                          rv1_lq_instr_i1_isStore_offset = rv1_lq_instr_i1_isLoad_offset + 1;
   parameter                          rv1_lq_instr_i1_itag_offset = rv1_lq_instr_i1_isStore_offset + 1;
   parameter                          rv1_lq_instr_i1_ifar_offset = rv1_lq_instr_i1_itag_offset+ `ITAG_SIZE_ENC;

   parameter                          scan_right =  rv1_lq_instr_i1_ifar_offset + `PF_IAR_BITS;
   wire [0:scan_right-1] 	      siv;
   wire [0:scan_right-1] 	      sov;

   //------------------------------------------------------------------------------------------------------------
   // Misc
   //------------------------------------------------------------------------------------------------------------
   assign tiup = 1'b1;

   //------------------------------------------------------------------------------------------------------------
   // Inputs Thread 0
   //------------------------------------------------------------------------------------------------------------

   assign iu6_t0_i0_act = iu_rv_iu6_t0_i0_act;
   assign iu6_t0_i1_act = iu_rv_iu6_t0_i1_act;

   assign rv0_t0_i0_act = rv0_t0_i0_vld_q;
   assign rv0_t0_i1_act = rv0_t0_i1_vld_q;

   assign rv0_t0_i0_vld_d = iu_rv_iu6_t0_i0_vld;
   assign rv0_instr_i0_flushed_d[0] = iu_rv_iu6_t0_i0_vld & iu_xx_zap[0];
   assign rv0_t0_i0_rte_lq_d = iu_rv_iu6_t0_i0_rte_lq & iu_rv_iu6_t0_i0_vld;
   assign rv0_t0_i0_rte_sq_d = iu_rv_iu6_t0_i0_rte_sq & iu_rv_iu6_t0_i0_vld;
   assign rv0_t0_i0_rte_fx0_d = iu_rv_iu6_t0_i0_rte_fx0 & iu_rv_iu6_t0_i0_vld;
   assign rv0_t0_i0_rte_fx1_d = iu_rv_iu6_t0_i0_rte_fx1 & iu_rv_iu6_t0_i0_vld;
   assign rv0_t0_i0_rte_axu0_d = iu_rv_iu6_t0_i0_rte_axu0 & iu_rv_iu6_t0_i0_vld;
   assign rv0_t0_i0_rte_axu1_d = iu_rv_iu6_t0_i0_rte_axu1 & iu_rv_iu6_t0_i0_vld;
   assign rv0_t0_i0_instr_d = iu_rv_iu6_t0_i0_instr;
   assign rv0_t0_i0_ifar_d = iu_rv_iu6_t0_i0_ifar;
   assign rv0_t0_i0_ucode_d = iu_rv_iu6_t0_i0_ucode;
   assign rv0_t0_i0_2ucode_d = iu_rv_iu6_t0_i0_2ucode;
   assign rv0_t0_i0_ucode_cnt_d = iu_rv_iu6_t0_i0_ucode_cnt;
   assign rv0_t0_i0_itag_d = iu_rv_iu6_t0_i0_itag;
   assign rv0_t0_i0_ord_d = iu_rv_iu6_t0_i0_ord;
   assign rv0_t0_i0_cord_d = iu_rv_iu6_t0_i0_cord;
   assign rv0_t0_i0_spec_d = iu_rv_iu6_t0_i0_spec;
   assign rv0_t0_i0_t1_v_d = iu_rv_iu6_t0_i0_t1_v;
   assign rv0_t0_i0_t1_p_d = iu_rv_iu6_t0_i0_t1_p;
   assign rv0_t0_i0_t1_t_d = iu_rv_iu6_t0_i0_t1_t;
   assign rv0_t0_i0_t2_v_d = iu_rv_iu6_t0_i0_t2_v;
   assign rv0_t0_i0_t2_p_d = iu_rv_iu6_t0_i0_t2_p;
   assign rv0_t0_i0_t2_t_d = iu_rv_iu6_t0_i0_t2_t;
   assign rv0_t0_i0_t3_v_d = iu_rv_iu6_t0_i0_t3_v;
   assign rv0_t0_i0_t3_p_d = iu_rv_iu6_t0_i0_t3_p;
   assign rv0_t0_i0_t3_t_d = iu_rv_iu6_t0_i0_t3_t;
   assign rv0_t0_i0_s1_v_d = iu_rv_iu6_t0_i0_s1_v;
   assign rv0_t0_i0_s1_p_d = iu_rv_iu6_t0_i0_s1_p;
   assign rv0_t0_i0_s1_t_d = iu_rv_iu6_t0_i0_s1_t;
   assign rv0_t0_i0_s2_v_d = iu_rv_iu6_t0_i0_s2_v;
   assign rv0_t0_i0_s2_p_d = iu_rv_iu6_t0_i0_s2_p;
   assign rv0_t0_i0_s2_t_d = iu_rv_iu6_t0_i0_s2_t;
   assign rv0_t0_i0_s3_v_d = iu_rv_iu6_t0_i0_s3_v;
   assign rv0_t0_i0_s3_p_d = iu_rv_iu6_t0_i0_s3_p;
   assign rv0_t0_i0_s3_t_d = iu_rv_iu6_t0_i0_s3_t;
   assign rv0_t0_i0_ilat_d = iu_rv_iu6_t0_i0_ilat;
   assign rv0_t0_i0_branch_d = iu_rv_iu6_t0_i0_branch;
   assign rv0_t0_i0_isLoad_d = iu_rv_iu6_t0_i0_isLoad;
   assign rv0_t0_i0_isStore_d = iu_rv_iu6_t0_i0_isStore;
   assign rv0_t0_i0_s1_itag_d = iu_rv_iu6_t0_i0_s1_itag;
   assign rv0_t0_i0_s2_itag_d = iu_rv_iu6_t0_i0_s2_itag;
   assign rv0_t0_i0_s3_itag_d = iu_rv_iu6_t0_i0_s3_itag;

   assign rv0_t0_i1_vld_d = iu_rv_iu6_t0_i1_vld;
   assign rv0_instr_i1_flushed_d[0] = iu_rv_iu6_t0_i1_vld & iu_xx_zap[0];
   assign rv0_t0_i1_rte_lq_d = iu_rv_iu6_t0_i1_rte_lq & iu_rv_iu6_t0_i1_vld;
   assign rv0_t0_i1_rte_sq_d = iu_rv_iu6_t0_i1_rte_sq & iu_rv_iu6_t0_i1_vld;
   assign rv0_t0_i1_rte_fx0_d = iu_rv_iu6_t0_i1_rte_fx0 & iu_rv_iu6_t0_i1_vld;
   assign rv0_t0_i1_rte_fx1_d = iu_rv_iu6_t0_i1_rte_fx1 & iu_rv_iu6_t0_i1_vld;
   assign rv0_t0_i1_rte_axu0_d = iu_rv_iu6_t0_i1_rte_axu0 & iu_rv_iu6_t0_i1_vld;
   assign rv0_t0_i1_rte_axu1_d = iu_rv_iu6_t0_i1_rte_axu1 & iu_rv_iu6_t0_i1_vld;
   assign rv0_t0_i1_instr_d = iu_rv_iu6_t0_i1_instr;
   assign rv0_t0_i1_ifar_d = iu_rv_iu6_t0_i1_ifar;
   assign rv0_t0_i1_ucode_d = iu_rv_iu6_t0_i1_ucode;
   assign rv0_t0_i1_ucode_cnt_d = iu_rv_iu6_t0_i1_ucode_cnt;
   assign rv0_t0_i1_itag_d = iu_rv_iu6_t0_i1_itag;
   assign rv0_t0_i1_ord_d = iu_rv_iu6_t0_i1_ord;
   assign rv0_t0_i1_cord_d = iu_rv_iu6_t0_i1_cord;
   assign rv0_t0_i1_spec_d = iu_rv_iu6_t0_i1_spec;
   assign rv0_t0_i1_t1_v_d = iu_rv_iu6_t0_i1_t1_v;
   assign rv0_t0_i1_t1_p_d = iu_rv_iu6_t0_i1_t1_p;
   assign rv0_t0_i1_t1_t_d = iu_rv_iu6_t0_i1_t1_t;
   assign rv0_t0_i1_t2_v_d = iu_rv_iu6_t0_i1_t2_v;
   assign rv0_t0_i1_t2_p_d = iu_rv_iu6_t0_i1_t2_p;
   assign rv0_t0_i1_t2_t_d = iu_rv_iu6_t0_i1_t2_t;
   assign rv0_t0_i1_t3_v_d = iu_rv_iu6_t0_i1_t3_v;
   assign rv0_t0_i1_t3_p_d = iu_rv_iu6_t0_i1_t3_p;
   assign rv0_t0_i1_t3_t_d = iu_rv_iu6_t0_i1_t3_t;
   assign rv0_t0_i1_s1_v_d = iu_rv_iu6_t0_i1_s1_v;
   assign rv0_t0_i1_s1_p_d = iu_rv_iu6_t0_i1_s1_p;
   assign rv0_t0_i1_s1_t_d = iu_rv_iu6_t0_i1_s1_t;
   assign rv0_t0_i1_s2_v_d = iu_rv_iu6_t0_i1_s2_v;
   assign rv0_t0_i1_s2_p_d = iu_rv_iu6_t0_i1_s2_p;
   assign rv0_t0_i1_s2_t_d = iu_rv_iu6_t0_i1_s2_t;
   assign rv0_t0_i1_s3_v_d = iu_rv_iu6_t0_i1_s3_v;
   assign rv0_t0_i1_s3_p_d = iu_rv_iu6_t0_i1_s3_p;
   assign rv0_t0_i1_s3_t_d = iu_rv_iu6_t0_i1_s3_t;
   assign rv0_t0_i1_ilat_d = iu_rv_iu6_t0_i1_ilat;
   assign rv0_t0_i1_branch_d = iu_rv_iu6_t0_i1_branch;
   assign rv0_t0_i1_isLoad_d = iu_rv_iu6_t0_i1_isLoad;
   assign rv0_t0_i1_isStore_d = iu_rv_iu6_t0_i1_isStore;
   assign rv0_t0_i1_s1_itag_d = iu_rv_iu6_t0_i1_s1_itag;
   assign rv0_t0_i1_s2_itag_d = iu_rv_iu6_t0_i1_s2_itag;
   assign rv0_t0_i1_s3_itag_d = iu_rv_iu6_t0_i1_s3_itag;
   assign rv0_t0_i1_s1_dep_hit_d = iu_rv_iu6_t0_i1_s1_dep_hit;
   assign rv0_t0_i1_s2_dep_hit_d = iu_rv_iu6_t0_i1_s2_dep_hit;
   assign rv0_t0_i1_s3_dep_hit_d = iu_rv_iu6_t0_i1_s3_dep_hit;

`ifndef THREADS1
   //------------------------------------------------------------------------------------------------------------
   // Inputs Thread 0
   //------------------------------------------------------------------------------------------------------------

   assign iu6_t1_i0_act = iu_rv_iu6_t1_i0_act;
   assign iu6_t1_i1_act = iu_rv_iu6_t1_i1_act;

   assign rv0_t1_i0_act = rv0_t1_i0_vld_q;
   assign rv0_t1_i1_act = rv0_t1_i1_vld_q;

   assign rv0_t1_i0_vld_d = iu_rv_iu6_t1_i0_vld;
   assign rv0_instr_i0_flushed_d[1] = iu_rv_iu6_t1_i0_vld & iu_xx_zap[1];
   assign rv0_t1_i0_rte_lq_d = iu_rv_iu6_t1_i0_rte_lq & iu_rv_iu6_t1_i0_vld;
   assign rv0_t1_i0_rte_sq_d = iu_rv_iu6_t1_i0_rte_sq & iu_rv_iu6_t1_i0_vld;
   assign rv0_t1_i0_rte_fx0_d = iu_rv_iu6_t1_i0_rte_fx0 & iu_rv_iu6_t1_i0_vld;
   assign rv0_t1_i0_rte_fx1_d = iu_rv_iu6_t1_i0_rte_fx1 & iu_rv_iu6_t1_i0_vld;
   assign rv0_t1_i0_rte_axu0_d = iu_rv_iu6_t1_i0_rte_axu0 & iu_rv_iu6_t1_i0_vld;
   assign rv0_t1_i0_rte_axu1_d = iu_rv_iu6_t1_i0_rte_axu1 & iu_rv_iu6_t1_i0_vld;
   assign rv0_t1_i0_instr_d = iu_rv_iu6_t1_i0_instr;
   assign rv0_t1_i0_ifar_d = iu_rv_iu6_t1_i0_ifar;
   assign rv0_t1_i0_ucode_d = iu_rv_iu6_t1_i0_ucode;
   assign rv0_t1_i0_2ucode_d = iu_rv_iu6_t1_i0_2ucode;
   assign rv0_t1_i0_ucode_cnt_d = iu_rv_iu6_t1_i0_ucode_cnt;
   assign rv0_t1_i0_itag_d = iu_rv_iu6_t1_i0_itag;
   assign rv0_t1_i0_ord_d = iu_rv_iu6_t1_i0_ord;
   assign rv0_t1_i0_cord_d = iu_rv_iu6_t1_i0_cord;
   assign rv0_t1_i0_spec_d = iu_rv_iu6_t1_i0_spec;
   assign rv0_t1_i0_t1_v_d = iu_rv_iu6_t1_i0_t1_v;
   assign rv0_t1_i0_t1_p_d = iu_rv_iu6_t1_i0_t1_p;
   assign rv0_t1_i0_t1_t_d = iu_rv_iu6_t1_i0_t1_t;
   assign rv0_t1_i0_t2_v_d = iu_rv_iu6_t1_i0_t2_v;
   assign rv0_t1_i0_t2_p_d = iu_rv_iu6_t1_i0_t2_p;
   assign rv0_t1_i0_t2_t_d = iu_rv_iu6_t1_i0_t2_t;
   assign rv0_t1_i0_t3_v_d = iu_rv_iu6_t1_i0_t3_v;
   assign rv0_t1_i0_t3_p_d = iu_rv_iu6_t1_i0_t3_p;
   assign rv0_t1_i0_t3_t_d = iu_rv_iu6_t1_i0_t3_t;
   assign rv0_t1_i0_s1_v_d = iu_rv_iu6_t1_i0_s1_v;
   assign rv0_t1_i0_s1_p_d = iu_rv_iu6_t1_i0_s1_p;
   assign rv0_t1_i0_s1_t_d = iu_rv_iu6_t1_i0_s1_t;
   assign rv0_t1_i0_s2_v_d = iu_rv_iu6_t1_i0_s2_v;
   assign rv0_t1_i0_s2_p_d = iu_rv_iu6_t1_i0_s2_p;
   assign rv0_t1_i0_s2_t_d = iu_rv_iu6_t1_i0_s2_t;
   assign rv0_t1_i0_s3_v_d = iu_rv_iu6_t1_i0_s3_v;
   assign rv0_t1_i0_s3_p_d = iu_rv_iu6_t1_i0_s3_p;
   assign rv0_t1_i0_s3_t_d = iu_rv_iu6_t1_i0_s3_t;
   assign rv0_t1_i0_ilat_d = iu_rv_iu6_t1_i0_ilat;
   assign rv0_t1_i0_branch_d = iu_rv_iu6_t1_i0_branch;
   assign rv0_t1_i0_isLoad_d = iu_rv_iu6_t1_i0_isLoad;
   assign rv0_t1_i0_isStore_d = iu_rv_iu6_t1_i0_isStore;
   assign rv0_t1_i0_s1_itag_d = iu_rv_iu6_t1_i0_s1_itag;
   assign rv0_t1_i0_s2_itag_d = iu_rv_iu6_t1_i0_s2_itag;
   assign rv0_t1_i0_s3_itag_d = iu_rv_iu6_t1_i0_s3_itag;

   assign rv0_t1_i1_vld_d = iu_rv_iu6_t1_i1_vld;
   assign rv0_instr_i1_flushed_d[1] = iu_rv_iu6_t1_i1_vld & iu_xx_zap[1];
   assign rv0_t1_i1_rte_lq_d = iu_rv_iu6_t1_i1_rte_lq & iu_rv_iu6_t1_i1_vld;
   assign rv0_t1_i1_rte_sq_d = iu_rv_iu6_t1_i1_rte_sq & iu_rv_iu6_t1_i1_vld;
   assign rv0_t1_i1_rte_fx0_d = iu_rv_iu6_t1_i1_rte_fx0 & iu_rv_iu6_t1_i1_vld;
   assign rv0_t1_i1_rte_fx1_d = iu_rv_iu6_t1_i1_rte_fx1 & iu_rv_iu6_t1_i1_vld;
   assign rv0_t1_i1_rte_axu0_d = iu_rv_iu6_t1_i1_rte_axu0 & iu_rv_iu6_t1_i1_vld;
   assign rv0_t1_i1_rte_axu1_d = iu_rv_iu6_t1_i1_rte_axu1 & iu_rv_iu6_t1_i1_vld;
   assign rv0_t1_i1_instr_d = iu_rv_iu6_t1_i1_instr;
   assign rv0_t1_i1_ifar_d = iu_rv_iu6_t1_i1_ifar;
   assign rv0_t1_i1_ucode_d = iu_rv_iu6_t1_i1_ucode;
   assign rv0_t1_i1_ucode_cnt_d = iu_rv_iu6_t1_i1_ucode_cnt;
   assign rv0_t1_i1_itag_d = iu_rv_iu6_t1_i1_itag;
   assign rv0_t1_i1_ord_d = iu_rv_iu6_t1_i1_ord;
   assign rv0_t1_i1_cord_d = iu_rv_iu6_t1_i1_cord;
   assign rv0_t1_i1_spec_d = iu_rv_iu6_t1_i1_spec;
   assign rv0_t1_i1_t1_v_d = iu_rv_iu6_t1_i1_t1_v;
   assign rv0_t1_i1_t1_p_d = iu_rv_iu6_t1_i1_t1_p;
   assign rv0_t1_i1_t1_t_d = iu_rv_iu6_t1_i1_t1_t;
   assign rv0_t1_i1_t2_v_d = iu_rv_iu6_t1_i1_t2_v;
   assign rv0_t1_i1_t2_p_d = iu_rv_iu6_t1_i1_t2_p;
   assign rv0_t1_i1_t2_t_d = iu_rv_iu6_t1_i1_t2_t;
   assign rv0_t1_i1_t3_v_d = iu_rv_iu6_t1_i1_t3_v;
   assign rv0_t1_i1_t3_p_d = iu_rv_iu6_t1_i1_t3_p;
   assign rv0_t1_i1_t3_t_d = iu_rv_iu6_t1_i1_t3_t;
   assign rv0_t1_i1_s1_v_d = iu_rv_iu6_t1_i1_s1_v;
   assign rv0_t1_i1_s1_p_d = iu_rv_iu6_t1_i1_s1_p;
   assign rv0_t1_i1_s1_t_d = iu_rv_iu6_t1_i1_s1_t;
   assign rv0_t1_i1_s2_v_d = iu_rv_iu6_t1_i1_s2_v;
   assign rv0_t1_i1_s2_p_d = iu_rv_iu6_t1_i1_s2_p;
   assign rv0_t1_i1_s2_t_d = iu_rv_iu6_t1_i1_s2_t;
   assign rv0_t1_i1_s3_v_d = iu_rv_iu6_t1_i1_s3_v;
   assign rv0_t1_i1_s3_p_d = iu_rv_iu6_t1_i1_s3_p;
   assign rv0_t1_i1_s3_t_d = iu_rv_iu6_t1_i1_s3_t;
   assign rv0_t1_i1_ilat_d = iu_rv_iu6_t1_i1_ilat;
   assign rv0_t1_i1_branch_d = iu_rv_iu6_t1_i1_branch;
   assign rv0_t1_i1_isLoad_d = iu_rv_iu6_t1_i1_isLoad;
   assign rv0_t1_i1_isStore_d = iu_rv_iu6_t1_i1_isStore;
   assign rv0_t1_i1_s1_itag_d = iu_rv_iu6_t1_i1_s1_itag;
   assign rv0_t1_i1_s2_itag_d = iu_rv_iu6_t1_i1_s2_itag;
   assign rv0_t1_i1_s3_itag_d = iu_rv_iu6_t1_i1_s3_itag;
   assign rv0_t1_i1_s1_dep_hit_d = iu_rv_iu6_t1_i1_s1_dep_hit;
   assign rv0_t1_i1_s2_dep_hit_d = iu_rv_iu6_t1_i1_s2_dep_hit;
   assign rv0_t1_i1_s3_dep_hit_d = iu_rv_iu6_t1_i1_s3_dep_hit;
`endif //  `ifndef THREADS1


   //------------------------------------------------------------------------------------------------------------
   // RV0
   //------------------------------------------------------------------------------------------------------------

   assign rv0_instr_i0_dep_val[0] = rv0_t0_i0_vld_q & (~rv0_instr_i0_flushed_q[0]);
   assign rv0_instr_i1_dep_val[0] = rv0_t0_i1_vld_q & (~rv0_instr_i1_flushed_q[0]);


   rv_dep
     rv_dep0(
	     .iu_xx_zap(iu_xx_zap[0]),
	     .rv0_i0_act(rv0_t0_i0_act),
	     .rv0_i1_act(rv0_t0_i1_act),

	     .rv0_instr_i0_vld(rv0_instr_i0_dep_val[0]),
	     .rv0_instr_i0_t1_v(rv0_t0_i0_t1_v_q),
	     .rv0_instr_i0_t2_v(rv0_t0_i0_t2_v_q),
	     .rv0_instr_i0_t3_v(rv0_t0_i0_t3_v_q),
	     .rv0_instr_i0_itag(rv0_t0_i0_itag_q),

	     .rv0_instr_i0_s1_v   (rv0_t0_i0_s1_v_q),
	     .rv0_instr_i0_s1_itag(rv0_t0_i0_s1_itag_q),
	     .rv0_instr_i0_s2_v   (rv0_t0_i0_s2_v_q),
	     .rv0_instr_i0_s2_itag(rv0_t0_i0_s2_itag_q),
	     .rv0_instr_i0_s3_v   (rv0_t0_i0_s3_v_q),
	     .rv0_instr_i0_s3_itag(rv0_t0_i0_s3_itag_q),

	     .rv0_instr_i1_vld(rv0_instr_i1_dep_val[0]),
	     .rv0_instr_i1_t1_v(rv0_t0_i1_t1_v_q),
	     .rv0_instr_i1_t2_v(rv0_t0_i1_t2_v_q),
	     .rv0_instr_i1_t3_v(rv0_t0_i1_t3_v_q),
	     .rv0_instr_i1_itag(rv0_t0_i1_itag_q),

	     .rv0_instr_i1_s1_v   (rv0_t0_i1_s1_v_q),
	     .rv0_instr_i1_s1_itag(rv0_t0_i1_s1_itag_q),
	     .rv0_instr_i1_s2_v   (rv0_t0_i1_s2_v_q),
	     .rv0_instr_i1_s2_itag(rv0_t0_i1_s2_itag_q),
	     .rv0_instr_i1_s3_v   (rv0_t0_i1_s3_v_q),
	     .rv0_instr_i1_s3_itag(rv0_t0_i1_s3_itag_q),

	     .fx0_rv_itag_vld(fx0_rv_itag_vld[0]),
	     .fx0_rv_itag(fx0_rv_itag),
	     .fx1_rv_itag_vld(fx1_rv_itag_vld[0]),
	     .fx1_rv_itag(fx1_rv_itag),
	     .lq_rv_itag0_vld(lq_rv_itag0_vld[0]),
	     .lq_rv_itag0(lq_rv_itag0),
	     .lq_rv_itag1_vld(lq_rv_itag1_vld[0]),
	     .lq_rv_itag1(lq_rv_itag1),
	     .lq_rv_itag2_vld(lq_rv_itag2_vld[0]),
	     .lq_rv_itag2(lq_rv_itag2),
	     .axu0_rv_itag_vld(axu0_rv_itag_vld[0]),
	     .axu0_rv_itag(axu0_rv_itag),
	     .axu1_rv_itag_vld(axu1_rv_itag_vld[0]),
	     .axu1_rv_itag(axu1_rv_itag),

	     .fx0_rv_itag_abort  (fx0_rv_itag_abort),
	     .fx1_rv_itag_abort  (fx1_rv_itag_abort),
	     .lq_rv_itag0_abort  (lq_rv_itag0_abort),
	     .lq_rv_itag1_abort  (lq_rv_itag1_abort),
	     .axu0_rv_itag_abort (axu0_rv_itag_abort),
	     .axu1_rv_itag_abort (axu1_rv_itag_abort),

	     .rv0_instr_i0_s1_dep_hit(rv0_instr_i0_s1_dep_hit[0]),
	     .rv0_instr_i0_s2_dep_hit(rv0_instr_i0_s2_dep_hit[0]),
	     .rv0_instr_i0_s3_dep_hit(rv0_instr_i0_s3_dep_hit[0]),

	     .rv0_instr_i1_s1_dep_hit(rv0_instr_i1_s1_dep_hit[0]),
	     .rv0_instr_i1_s2_dep_hit(rv0_instr_i1_s2_dep_hit[0]),
	     .rv0_instr_i1_s3_dep_hit(rv0_instr_i1_s3_dep_hit[0]),

	     .vdd(vdd),
	     .gnd(gnd),
	     .nclk(nclk),
	     .sg_1(sg_1),
	     .func_sl_thold_1(func_sl_thold_1),
	     .clkoff_b(clkoff_b),
	     .act_dis(act_dis),
	     .ccflush_dc(ccflush_dc),
	     .d_mode(d_mode),
	     .delay_lclkr(delay_lclkr),
	     .mpw1_b(mpw1_b),
	     .mpw2_b(mpw2_b),
	     .scan_in(siv[dep0_offset]),
	     .scan_out(sov[dep0_offset])
	     );


   rv_decode
     dec_t0i0(
              .instr(rv0_t0_i0_instr_q),

              .is_brick(rv0_t0_i0_is_brick),
              .brick_cycles(rv0_t0_i0_brick)
	      );


   rv_decode
     dec_t0i1(
              .instr(rv0_t0_i1_instr_q),

              .is_brick(rv0_t0_i1_is_brick),
              .brick_cycles(rv0_t0_i1_brick)
	      );

   // side checking of instruction b sources against instruction a targets
   assign rv0_instr_i1_local_s1_dep_hit[0] = rv0_t0_i1_s1_v_q & rv0_t0_i1_s1_dep_hit_q ;
   assign rv0_instr_i1_local_s2_dep_hit[0] = rv0_t0_i1_s2_v_q & rv0_t0_i1_s2_dep_hit_q ;
   assign rv0_instr_i1_local_s3_dep_hit[0] = rv0_t0_i1_s3_v_q & rv0_t0_i1_s3_dep_hit_q ;

   assign rv0_t0_i0_ilat = rv0_t0_i0_ilat_q | {4{(~(rv0_t0_i0_t1_v_q | rv0_t0_i0_t2_v_q | rv0_t0_i0_t3_v_q))}};
   assign rv0_t0_i1_ilat = rv0_t0_i1_ilat_q | {4{(~(rv0_t0_i1_t1_v_q | rv0_t0_i1_t2_v_q | rv0_t0_i1_t3_v_q))}};

   assign rv0_instr_i1_s1_itag_loc[0] = rv0_t0_i1_s1_itag_q;
   assign rv0_instr_i1_s2_itag_loc[0] = rv0_t0_i1_s2_itag_q;
   assign rv0_instr_i1_s3_itag_loc[0] = rv0_t0_i1_s3_itag_q;

`ifndef THREADS1

   assign rv0_instr_i0_dep_val[1] = rv0_t1_i0_vld_q & (~rv0_instr_i0_flushed_q[1]);
   assign rv0_instr_i1_dep_val[1] = rv0_t1_i1_vld_q & (~rv0_instr_i1_flushed_q[1]);

   rv_dep
     rv_dep1(
	     .iu_xx_zap(iu_xx_zap[1]),
	     .rv0_i0_act(rv0_t1_i0_act),
	     .rv0_i1_act(rv0_t1_i1_act),

	     .rv0_instr_i0_vld(rv0_instr_i0_dep_val[1]),
	     .rv0_instr_i0_t1_v(rv0_t1_i0_t1_v_q),
	     .rv0_instr_i0_t2_v(rv0_t1_i0_t2_v_q),
	     .rv0_instr_i0_t3_v(rv0_t1_i0_t3_v_q),
	     .rv0_instr_i0_itag(rv0_t1_i0_itag_q),

	     .rv0_instr_i0_s1_v   (rv0_t1_i0_s1_v_q),
	     .rv0_instr_i0_s1_itag(rv0_t1_i0_s1_itag_q),
	     .rv0_instr_i0_s2_v   (rv0_t1_i0_s2_v_q),
	     .rv0_instr_i0_s2_itag(rv0_t1_i0_s2_itag_q),
	     .rv0_instr_i0_s3_v   (rv0_t1_i0_s3_v_q),
	     .rv0_instr_i0_s3_itag(rv0_t1_i0_s3_itag_q),

	     .rv0_instr_i1_vld(rv0_instr_i1_dep_val[1]),
	     .rv0_instr_i1_t1_v(rv0_t1_i1_t1_v_q),
	     .rv0_instr_i1_t2_v(rv0_t1_i1_t2_v_q),
	     .rv0_instr_i1_t3_v(rv0_t1_i1_t3_v_q),
	     .rv0_instr_i1_itag(rv0_t1_i1_itag_q),

	     .rv0_instr_i1_s1_v   (rv0_t1_i1_s1_v_q),
	     .rv0_instr_i1_s1_itag(rv0_t1_i1_s1_itag_q),
	     .rv0_instr_i1_s2_v   (rv0_t1_i1_s2_v_q),
	     .rv0_instr_i1_s2_itag(rv0_t1_i1_s2_itag_q),
	     .rv0_instr_i1_s3_v   (rv0_t1_i1_s3_v_q),
	     .rv0_instr_i1_s3_itag(rv0_t1_i1_s3_itag_q),

	     .fx0_rv_itag_vld(fx0_rv_itag_vld[1]),
	     .fx0_rv_itag(fx0_rv_itag),
	     .fx1_rv_itag_vld(fx1_rv_itag_vld[1]),
	     .fx1_rv_itag(fx1_rv_itag),
	     .lq_rv_itag0_vld(lq_rv_itag0_vld[1]),
	     .lq_rv_itag0(lq_rv_itag0),
	     .lq_rv_itag1_vld(lq_rv_itag1_vld[1]),
	     .lq_rv_itag1(lq_rv_itag1),
	     .lq_rv_itag2_vld(lq_rv_itag2_vld[1]),
	     .lq_rv_itag2(lq_rv_itag2),
	     .axu0_rv_itag_vld(axu0_rv_itag_vld[1]),
	     .axu0_rv_itag(axu0_rv_itag),
	     .axu1_rv_itag_vld(axu1_rv_itag_vld[1]),
	     .axu1_rv_itag(axu1_rv_itag),

	     .fx0_rv_itag_abort  (fx0_rv_itag_abort),
	     .fx1_rv_itag_abort  (fx1_rv_itag_abort),
	     .lq_rv_itag0_abort  (lq_rv_itag0_abort),
	     .lq_rv_itag1_abort  (lq_rv_itag1_abort),
	     .axu0_rv_itag_abort (axu0_rv_itag_abort),
	     .axu1_rv_itag_abort (axu1_rv_itag_abort),

	     .rv0_instr_i0_s1_dep_hit(rv0_instr_i0_s1_dep_hit[1]),
	     .rv0_instr_i0_s2_dep_hit(rv0_instr_i0_s2_dep_hit[1]),
	     .rv0_instr_i0_s3_dep_hit(rv0_instr_i0_s3_dep_hit[1]),

	     .rv0_instr_i1_s1_dep_hit(rv0_instr_i1_s1_dep_hit[1]),
	     .rv0_instr_i1_s2_dep_hit(rv0_instr_i1_s2_dep_hit[1]),
	     .rv0_instr_i1_s3_dep_hit(rv0_instr_i1_s3_dep_hit[1]),

	     .vdd(vdd),
	     .gnd(gnd),
	     .nclk(nclk),
	     .sg_1(sg_1),
	     .func_sl_thold_1(func_sl_thold_1),
	     .clkoff_b(clkoff_b),
	     .act_dis(act_dis),
	     .ccflush_dc(ccflush_dc),
	     .d_mode(d_mode),
	     .delay_lclkr(delay_lclkr),
	     .mpw1_b(mpw1_b),
	     .mpw2_b(mpw2_b),
	     .scan_in(siv[dep1_offset]),
	     .scan_out(sov[dep1_offset])
	     );


   rv_decode
     dec_t1i0(
              .instr(rv0_t1_i0_instr_q),

              .is_brick(rv0_t1_i0_is_brick),
              .brick_cycles(rv0_t1_i0_brick)
	      );


   rv_decode
     dec_t1i1(
              .instr(rv0_t1_i1_instr_q),

              .is_brick(rv0_t1_i1_is_brick),
              .brick_cycles(rv0_t1_i1_brick)
	      );

   // side checking of instruction b sources against instruction a targets
   assign rv0_instr_i1_local_s1_dep_hit[1] = rv0_t1_i1_s1_v_q & rv0_t1_i1_s1_dep_hit_q ;
   assign rv0_instr_i1_local_s2_dep_hit[1] = rv0_t1_i1_s2_v_q & rv0_t1_i1_s2_dep_hit_q ;
   assign rv0_instr_i1_local_s3_dep_hit[1] = rv0_t1_i1_s3_v_q & rv0_t1_i1_s3_dep_hit_q ;

   assign rv0_t1_i0_ilat = rv0_t1_i0_ilat_q | {4{(~(rv0_t1_i0_t1_v_q | rv0_t1_i0_t2_v_q | rv0_t1_i0_t3_v_q))}};
   assign rv0_t1_i1_ilat = rv0_t1_i1_ilat_q | {4{(~(rv0_t1_i1_t1_v_q | rv0_t1_i1_t2_v_q | rv0_t1_i1_t3_v_q))}};

   assign rv0_instr_i1_s1_itag_loc[1] = rv0_t1_i1_s1_itag_q; //todo remove
   assign rv0_instr_i1_s2_itag_loc[1] = rv0_t1_i1_s2_itag_q;
   assign rv0_instr_i1_s3_itag_loc[1] = rv0_t1_i1_s3_itag_q;

`endif //  `ifndef THREADS1


   assign rv0_instr_i1_s1_dep_hit_loc = rv0_instr_i1_s1_dep_hit | rv0_instr_i1_local_s1_dep_hit;
   assign rv0_instr_i1_s2_dep_hit_loc = rv0_instr_i1_s2_dep_hit | rv0_instr_i1_local_s2_dep_hit;
   assign rv0_instr_i1_s3_dep_hit_loc = rv0_instr_i1_s3_dep_hit | rv0_instr_i1_local_s3_dep_hit;



   //------------------------------------------------------------------------------------------------------------
   // FX0 RV0
   //------------------------------------------------------------------------------------------------------------
   generate
      if (`THREADS == 1)
        begin : t1
           assign rv0_fx0_instr_i0_vld     = rv0_t0_i0_vld_q;
           assign rv0_fx0_instr_i0_rte_fx0 = rv0_t0_i0_rte_fx0_q;
           assign rv0_fx0_instr_i1_vld     = rv0_t0_i1_vld_q;
           assign rv0_fx0_instr_i1_rte_fx0 = rv0_t0_i1_rte_fx0_q;

           assign rv0_fx0_instr_i0_s1_dep_hit = rv0_instr_i0_s1_dep_hit[0];
           assign rv0_fx0_instr_i0_s2_dep_hit = rv0_instr_i0_s2_dep_hit[0];
           assign rv0_fx0_instr_i0_s3_dep_hit = rv0_instr_i0_s3_dep_hit[0];
           assign rv0_fx0_instr_i0_s1_itag = rv0_t0_i0_s1_itag_q;
           assign rv0_fx0_instr_i0_s2_itag = rv0_t0_i0_s2_itag_q;
           assign rv0_fx0_instr_i0_s3_itag = rv0_t0_i0_s3_itag_q;
           assign rv0_fx0_instr_i1_s1_dep_hit = rv0_instr_i1_s1_dep_hit_loc[0];
           assign rv0_fx0_instr_i1_s2_dep_hit = rv0_instr_i1_s2_dep_hit_loc[0];
           assign rv0_fx0_instr_i1_s3_dep_hit = rv0_instr_i1_s3_dep_hit_loc[0];
           assign rv0_fx0_instr_i1_s1_itag = rv0_instr_i1_s1_itag_loc[0];
           assign rv0_fx0_instr_i1_s2_itag = rv0_instr_i1_s2_itag_loc[0];
           assign rv0_fx0_instr_i1_s3_itag = rv0_instr_i1_s3_itag_loc[0];
           //------------------------------------------------------------------------------------------------------------
           // FX0 RV1
           //------------------------------------------------------------------------------------------------------------
           assign rv0_fx0_instr_i0_instr = rv0_t0_i0_instr_q;
           assign rv0_fx0_instr_i0_ifar = rv0_t0_i0_ifar_q;
           assign rv0_fx0_instr_i0_ucode = rv0_t0_i0_ucode_q;
           assign rv0_fx0_instr_i0_ucode_cnt = rv0_t0_i0_ucode_cnt_q;
           assign rv0_fx0_instr_i0_itag = rv0_t0_i0_itag_q;
           assign rv0_fx0_instr_i0_ord = rv0_t0_i0_ord_q;
           assign rv0_fx0_instr_i0_cord = rv0_t0_i0_cord_q;

           assign rv0_fx0_instr_i0_t1_v = rv0_t0_i0_t1_v_q;
           assign rv0_fx0_instr_i0_t1_p = rv0_t0_i0_t1_p_q;
           assign rv0_fx0_instr_i0_t1_t = rv0_t0_i0_t1_t_q;
           assign rv0_fx0_instr_i0_t2_v = rv0_t0_i0_t2_v_q;
           assign rv0_fx0_instr_i0_t2_p = rv0_t0_i0_t2_p_q;
           assign rv0_fx0_instr_i0_t2_t = rv0_t0_i0_t2_t_q;
           assign rv0_fx0_instr_i0_t3_v = rv0_t0_i0_t3_v_q;
           assign rv0_fx0_instr_i0_t3_p = rv0_t0_i0_t3_p_q;
           assign rv0_fx0_instr_i0_t3_t = rv0_t0_i0_t3_t_q;

           assign rv0_fx0_instr_i0_s1_v = rv0_t0_i0_s1_v_q;
           assign rv0_fx0_instr_i0_s1_p = rv0_t0_i0_s1_p_q;
           assign rv0_fx0_instr_i0_s1_t = rv0_t0_i0_s1_t_q;
           assign rv0_fx0_instr_i0_s2_v = rv0_t0_i0_s2_v_q;
           assign rv0_fx0_instr_i0_s2_p = rv0_t0_i0_s2_p_q;
           assign rv0_fx0_instr_i0_s2_t = rv0_t0_i0_s2_t_q;
           assign rv0_fx0_instr_i0_s3_v = rv0_t0_i0_s3_v_q;
           assign rv0_fx0_instr_i0_s3_p = rv0_t0_i0_s3_p_q;
           assign rv0_fx0_instr_i0_s3_t = rv0_t0_i0_s3_t_q;

           assign rv0_fx0_instr_i0_ilat = rv0_t0_i0_ilat;
           assign rv0_fx0_instr_i0_branch = rv0_t0_i0_branch_q;
           assign rv0_fx0_instr_i0_spare = rv0_t0_i0_spare_q;
           assign rv0_fx0_instr_i0_is_brick = rv0_t0_i0_is_brick;
           assign rv0_fx0_instr_i0_brick = rv0_t0_i0_brick;

           assign rv0_fx0_instr_i1_instr = rv0_t0_i1_instr_q;
           assign rv0_fx0_instr_i1_ifar = rv0_t0_i1_ifar_q;
           assign rv0_fx0_instr_i1_ucode = rv0_t0_i1_ucode_q;
           assign rv0_fx0_instr_i1_ucode_cnt = rv0_t0_i1_ucode_cnt_q;
           assign rv0_fx0_instr_i1_itag = rv0_t0_i1_itag_q;
           assign rv0_fx0_instr_i1_ord = rv0_t0_i1_ord_q;
           assign rv0_fx0_instr_i1_cord = rv0_t0_i1_cord_q;

           assign rv0_fx0_instr_i1_t1_v = rv0_t0_i1_t1_v_q;
           assign rv0_fx0_instr_i1_t1_p = rv0_t0_i1_t1_p_q;
           assign rv0_fx0_instr_i1_t1_t = rv0_t0_i1_t1_t_q;
           assign rv0_fx0_instr_i1_t2_v = rv0_t0_i1_t2_v_q;
           assign rv0_fx0_instr_i1_t2_p = rv0_t0_i1_t2_p_q;
           assign rv0_fx0_instr_i1_t2_t = rv0_t0_i1_t2_t_q;
           assign rv0_fx0_instr_i1_t3_v = rv0_t0_i1_t3_v_q;
           assign rv0_fx0_instr_i1_t3_p = rv0_t0_i1_t3_p_q;
           assign rv0_fx0_instr_i1_t3_t = rv0_t0_i1_t3_t_q;

           assign rv0_fx0_instr_i1_s1_v = rv0_t0_i1_s1_v_q;
           assign rv0_fx0_instr_i1_s1_p = rv0_t0_i1_s1_p_q;
           assign rv0_fx0_instr_i1_s1_t = rv0_t0_i1_s1_t_q;
           assign rv0_fx0_instr_i1_s2_v = rv0_t0_i1_s2_v_q;
           assign rv0_fx0_instr_i1_s2_p = rv0_t0_i1_s2_p_q;
           assign rv0_fx0_instr_i1_s2_t = rv0_t0_i1_s2_t_q;
           assign rv0_fx0_instr_i1_s3_v = rv0_t0_i1_s3_v_q;
           assign rv0_fx0_instr_i1_s3_p = rv0_t0_i1_s3_p_q;
           assign rv0_fx0_instr_i1_s3_t = rv0_t0_i1_s3_t_q;

           assign rv0_fx0_instr_i1_ilat = rv0_t0_i1_ilat;
           assign rv0_fx0_instr_i1_branch = rv0_t0_i1_branch_q;
           assign rv0_fx0_instr_i1_spare = rv0_t0_i1_spare_q;
           assign rv0_fx0_instr_i1_is_brick = rv0_t0_i1_is_brick;
           assign rv0_fx0_instr_i1_brick = rv0_t0_i1_brick;

           //------------------------------------------------------------------------------------------------------------
           // fx1 RV0
           //------------------------------------------------------------------------------------------------------------
           assign rv0_fx1_instr_i0_vld = rv0_t0_i0_vld_q;
           assign rv0_fx1_instr_i0_rte_fx1 = rv0_t0_i0_rte_fx1_q;
           assign rv0_fx1_instr_i1_vld = rv0_t0_i1_vld_q;
           assign rv0_fx1_instr_i1_rte_fx1 = rv0_t0_i1_rte_fx1_q;

           assign rv0_fx1_instr_i0_s1_dep_hit = rv0_instr_i0_s1_dep_hit[0];
           assign rv0_fx1_instr_i0_s2_dep_hit = rv0_instr_i0_s2_dep_hit[0];
           assign rv0_fx1_instr_i0_s3_dep_hit = rv0_instr_i0_s3_dep_hit[0];
           assign rv0_fx1_instr_i0_s1_itag = rv0_t0_i0_s1_itag_q;
           assign rv0_fx1_instr_i0_s2_itag = rv0_t0_i0_s2_itag_q;
           assign rv0_fx1_instr_i0_s3_itag = rv0_t0_i0_s3_itag_q;
           assign rv0_fx1_instr_i1_s1_dep_hit = rv0_instr_i1_s1_dep_hit_loc[0];
           assign rv0_fx1_instr_i1_s2_dep_hit = rv0_instr_i1_s2_dep_hit_loc[0];
           assign rv0_fx1_instr_i1_s3_dep_hit = rv0_instr_i1_s3_dep_hit_loc[0];
           assign rv0_fx1_instr_i1_s1_itag = rv0_instr_i1_s1_itag_loc[0];
           assign rv0_fx1_instr_i1_s2_itag = rv0_instr_i1_s2_itag_loc[0];
           assign rv0_fx1_instr_i1_s3_itag = rv0_instr_i1_s3_itag_loc[0];
           //------------------------------------------------------------------------------------------------------------
           // fx1 RV1
           //------------------------------------------------------------------------------------------------------------
           assign rv0_fx1_instr_i0_instr = rv0_t0_i0_instr_q;
           assign rv0_fx1_instr_i0_ucode = rv0_t0_i0_ucode_q;
           assign rv0_fx1_instr_i0_itag = rv0_t0_i0_itag_q;

           assign rv0_fx1_instr_i0_t1_v = rv0_t0_i0_t1_v_q;
           assign rv0_fx1_instr_i0_t1_p = rv0_t0_i0_t1_p_q;
           assign rv0_fx1_instr_i0_t2_v = rv0_t0_i0_t2_v_q;
           assign rv0_fx1_instr_i0_t2_p = rv0_t0_i0_t2_p_q;
           assign rv0_fx1_instr_i0_t3_v = rv0_t0_i0_t3_v_q;
           assign rv0_fx1_instr_i0_t3_p = rv0_t0_i0_t3_p_q;

           assign rv0_fx1_instr_i0_s1_v = rv0_t0_i0_s1_v_q;
           assign rv0_fx1_instr_i0_s1_p = rv0_t0_i0_s1_p_q;
           assign rv0_fx1_instr_i0_s1_t = rv0_t0_i0_s1_t_q;
           assign rv0_fx1_instr_i0_s2_v = rv0_t0_i0_s2_v_q;
           assign rv0_fx1_instr_i0_s2_p = rv0_t0_i0_s2_p_q;
           assign rv0_fx1_instr_i0_s2_t = rv0_t0_i0_s2_t_q;
           assign rv0_fx1_instr_i0_s3_v = rv0_t0_i0_s3_v_q;
           assign rv0_fx1_instr_i0_s3_p = rv0_t0_i0_s3_p_q;
           assign rv0_fx1_instr_i0_s3_t = rv0_t0_i0_s3_t_q;

           assign rv0_fx1_instr_i0_ilat = rv0_t0_i0_ilat;
           assign rv0_fx1_instr_i0_isStore = rv0_t0_i0_isStore_q;
           assign rv0_fx1_instr_i0_spare = rv0_t0_i0_spare_q;
           assign rv0_fx1_instr_i0_is_brick = rv0_t0_i0_is_brick;
           assign rv0_fx1_instr_i0_brick = rv0_t0_i0_brick;

           assign rv0_fx1_instr_i1_instr = rv0_t0_i1_instr_q;
           assign rv0_fx1_instr_i1_ucode = rv0_t0_i1_ucode_q;
           assign rv0_fx1_instr_i1_itag = rv0_t0_i1_itag_q;

           assign rv0_fx1_instr_i1_t1_v = rv0_t0_i1_t1_v_q;
           assign rv0_fx1_instr_i1_t1_p = rv0_t0_i1_t1_p_q;
           assign rv0_fx1_instr_i1_t2_v = rv0_t0_i1_t2_v_q;
           assign rv0_fx1_instr_i1_t2_p = rv0_t0_i1_t2_p_q;
           assign rv0_fx1_instr_i1_t3_v = rv0_t0_i1_t3_v_q;
           assign rv0_fx1_instr_i1_t3_p = rv0_t0_i1_t3_p_q;

           assign rv0_fx1_instr_i1_s1_v = rv0_t0_i1_s1_v_q;
           assign rv0_fx1_instr_i1_s1_p = rv0_t0_i1_s1_p_q;
           assign rv0_fx1_instr_i1_s1_t = rv0_t0_i1_s1_t_q;
           assign rv0_fx1_instr_i1_s2_v = rv0_t0_i1_s2_v_q;
           assign rv0_fx1_instr_i1_s2_p = rv0_t0_i1_s2_p_q;
           assign rv0_fx1_instr_i1_s2_t = rv0_t0_i1_s2_t_q;
           assign rv0_fx1_instr_i1_s3_v = rv0_t0_i1_s3_v_q;
           assign rv0_fx1_instr_i1_s3_p = rv0_t0_i1_s3_p_q;
           assign rv0_fx1_instr_i1_s3_t = rv0_t0_i1_s3_t_q;

           assign rv0_fx1_instr_i1_ilat = rv0_t0_i1_ilat;
           assign rv0_fx1_instr_i1_isStore = rv0_t0_i1_isStore_q;
           assign rv0_fx1_instr_i1_spare = rv0_t0_i1_spare_q;
           assign rv0_fx1_instr_i1_is_brick = rv0_t0_i1_is_brick;
           assign rv0_fx1_instr_i1_brick = rv0_t0_i1_brick;

           //------------------------------------------------------------------------------------------------------------
           // lq RV0
           //------------------------------------------------------------------------------------------------------------
           assign rv0_lq_instr_i0_vld = rv0_t0_i0_vld_q;
           assign rv0_lq_instr_i0_rte_lq = rv0_t0_i0_rte_lq_q;
           assign rv0_lq_instr_i1_vld = rv0_t0_i1_vld_q;
           assign rv0_lq_instr_i1_rte_lq = rv0_t0_i1_rte_lq_q;

           assign rv0_lq_instr_i0_s1_dep_hit = rv0_instr_i0_s1_dep_hit[0];
           assign rv0_lq_instr_i0_s2_dep_hit = rv0_instr_i0_s2_dep_hit[0];
           assign rv0_lq_instr_i0_s1_itag = rv0_t0_i0_s1_itag_q;
           assign rv0_lq_instr_i0_s2_itag = rv0_t0_i0_s2_itag_q;
           assign rv0_lq_instr_i1_s1_dep_hit = rv0_instr_i1_s1_dep_hit_loc[0];
           assign rv0_lq_instr_i1_s2_dep_hit = rv0_instr_i1_s2_dep_hit_loc[0];
           assign rv0_lq_instr_i1_s1_itag = rv0_instr_i1_s1_itag_loc[0];
           assign rv0_lq_instr_i1_s2_itag = rv0_instr_i1_s2_itag_loc[0];
           //------------------------------------------------------------------------------------------------------------
           // lq RV1
           //------------------------------------------------------------------------------------------------------------

           assign rv1_lq_instr_i0_vld_d = rv0_t0_i0_vld_q;
           assign rv1_lq_instr_i1_vld_d = rv0_t0_i1_vld_q;

           assign rv1_lq_instr_i0_rte_lq_d = rv0_t0_i0_rte_lq_q;
           assign rv1_lq_instr_i1_rte_lq_d = rv0_t0_i1_rte_lq_q;

           assign rv1_lq_instr_i0_rte_sq_d = rv0_t0_i0_rte_sq_q;
           assign rv1_lq_instr_i1_rte_sq_d = rv0_t0_i1_rte_sq_q;

           assign rv0_lq_instr_i0_instr = rv0_t0_i0_instr_q;
           assign rv0_lq_instr_i0_ifar = rv0_t0_i0_ifar_q[61 - `PF_IAR_BITS + 1:61];
           assign rv1_lq_instr_i0_ucode_d = rv0_t0_i0_ucode_q;
           assign rv1_lq_instr_i0_2ucode_d = rv0_t0_i0_2ucode_q;
           assign rv1_lq_instr_i0_ucode_cnt_d = rv0_t0_i0_ucode_cnt_q;
           assign rv1_lq_instr_i0_itag_d = rv0_t0_i0_itag_q;
           assign rv0_lq_instr_i0_ord = rv0_t0_i0_ord_q;
           assign rv0_lq_instr_i0_cord = rv0_t0_i0_cord_q;
           assign rv0_lq_instr_i0_spec = rv0_t0_i0_spec_q;

           assign rv0_lq_instr_i0_t1_v = rv0_t0_i0_t1_v_q;
           assign rv0_lq_instr_i0_t1_p = rv0_t0_i0_t1_p_q;
           assign rv0_lq_instr_i0_t2_v = rv0_t0_i0_t2_v_q;
           assign rv0_lq_instr_i0_t2_p = rv0_t0_i0_t2_p_q;
           assign rv0_lq_instr_i0_t2_t = rv0_t0_i0_t2_t_q;
           assign rv0_lq_instr_i0_t3_v = rv0_t0_i0_t3_v_q;
           assign rv0_lq_instr_i0_t3_p = rv0_t0_i0_t3_p_q;
           assign rv0_lq_instr_i0_t3_t = rv0_t0_i0_t3_t_q;

           assign rv0_lq_instr_i0_s1_v = rv0_t0_i0_s1_v_q;
           assign rv0_lq_instr_i0_s1_p = rv0_t0_i0_s1_p_q;
           assign rv0_lq_instr_i0_s1_t = rv0_t0_i0_s1_t_q;
           assign rv0_lq_instr_i0_s2_v = rv0_t0_i0_s2_v_q;
           assign rv0_lq_instr_i0_s2_p = rv0_t0_i0_s2_p_q;
           assign rv0_lq_instr_i0_s2_t = rv0_t0_i0_s2_t_q;
           assign rv0_lq_instr_i0_s3_v = rv0_t0_i0_s3_v_q;
           assign rv0_lq_instr_i0_s3_p = rv0_t0_i0_s3_p_q;
           assign rv1_lq_instr_i0_s3_t_d = rv0_t0_i0_s3_t_q;

           assign rv1_lq_instr_i0_isLoad_d = rv0_t0_i0_isLoad_q;
           assign rv1_lq_instr_i0_isStore_d = rv0_t0_i0_isStore_q;
           assign rv0_lq_instr_i0_spare = rv0_t0_i0_spare_q;
           assign rv0_lq_instr_i0_is_brick = rv0_t0_i0_is_brick;
           assign rv0_lq_instr_i0_brick = rv0_t0_i0_brick;

           assign rv0_lq_instr_i1_instr = rv0_t0_i1_instr_q;
           assign rv0_lq_instr_i1_ifar = rv0_t0_i1_ifar_q[61 - `PF_IAR_BITS + 1:61];
           assign rv1_lq_instr_i1_ucode_d = rv0_t0_i1_ucode_q;
           assign rv1_lq_instr_i1_2ucode_d = 1'b0;
           assign rv1_lq_instr_i1_ucode_cnt_d = rv0_t0_i1_ucode_cnt_q;
           assign rv1_lq_instr_i1_itag_d = rv0_t0_i1_itag_q;
           assign rv0_lq_instr_i1_ord = rv0_t0_i1_ord_q;
           assign rv0_lq_instr_i1_cord = rv0_t0_i1_cord_q;
           assign rv0_lq_instr_i1_spec = rv0_t0_i1_spec_q;

           assign rv0_lq_instr_i1_t1_v = rv0_t0_i1_t1_v_q;
           assign rv0_lq_instr_i1_t1_p = rv0_t0_i1_t1_p_q;
           assign rv0_lq_instr_i1_t2_v = rv0_t0_i1_t2_v_q;
           assign rv0_lq_instr_i1_t2_p = rv0_t0_i1_t2_p_q;
           assign rv0_lq_instr_i1_t2_t = rv0_t0_i1_t2_t_q;
           assign rv0_lq_instr_i1_t3_v = rv0_t0_i1_t3_v_q;
           assign rv0_lq_instr_i1_t3_p = rv0_t0_i1_t3_p_q;
           assign rv0_lq_instr_i1_t3_t = rv0_t0_i1_t3_t_q;

           assign rv0_lq_instr_i1_s1_v = rv0_t0_i1_s1_v_q;
           assign rv0_lq_instr_i1_s1_p = rv0_t0_i1_s1_p_q;
           assign rv0_lq_instr_i1_s1_t = rv0_t0_i1_s1_t_q;
           assign rv0_lq_instr_i1_s2_v = rv0_t0_i1_s2_v_q;
           assign rv0_lq_instr_i1_s2_p = rv0_t0_i1_s2_p_q;
           assign rv0_lq_instr_i1_s2_t = rv0_t0_i1_s2_t_q;
           assign rv1_lq_instr_i1_s3_t_d = rv0_t0_i1_s3_t_q;

           assign rv1_lq_instr_i1_isLoad_d = rv0_t0_i1_isLoad_q;
           assign rv1_lq_instr_i1_isStore_d = rv0_t0_i1_isStore_q;
           assign rv0_lq_instr_i1_spare = rv0_t0_i1_spare_q;
           assign rv0_lq_instr_i1_is_brick = rv0_t0_i1_is_brick;
           assign rv0_lq_instr_i1_brick = rv0_t0_i1_brick;

           //------------------------------------------------------------------------------------------------------------
           // axu0 RV0
           //------------------------------------------------------------------------------------------------------------
           assign rv0_axu0_instr_i0_vld = rv0_t0_i0_vld_q;
           assign rv0_axu0_instr_i0_rte_axu0 = rv0_t0_i0_rte_axu0_q;
           assign rv0_axu0_instr_i1_vld = rv0_t0_i1_vld_q;
           assign rv0_axu0_instr_i1_rte_axu0 = rv0_t0_i1_rte_axu0_q;

           assign rv0_axu0_instr_i0_s1_dep_hit = rv0_instr_i0_s1_dep_hit[0];
           assign rv0_axu0_instr_i0_s2_dep_hit = rv0_instr_i0_s2_dep_hit[0];
           assign rv0_axu0_instr_i0_s3_dep_hit = rv0_instr_i0_s3_dep_hit[0];
           assign rv0_axu0_instr_i0_s1_itag = rv0_t0_i0_s1_itag_q;
           assign rv0_axu0_instr_i0_s2_itag = rv0_t0_i0_s2_itag_q;
           assign rv0_axu0_instr_i0_s3_itag = rv0_t0_i0_s3_itag_q;
           assign rv0_axu0_instr_i1_s1_dep_hit = rv0_instr_i1_s1_dep_hit_loc[0];
           assign rv0_axu0_instr_i1_s2_dep_hit = rv0_instr_i1_s2_dep_hit_loc[0];
           assign rv0_axu0_instr_i1_s3_dep_hit = rv0_instr_i1_s3_dep_hit_loc[0];
           assign rv0_axu0_instr_i1_s1_itag = rv0_instr_i1_s1_itag_loc[0];
           assign rv0_axu0_instr_i1_s2_itag = rv0_instr_i1_s2_itag_loc[0];
           assign rv0_axu0_instr_i1_s3_itag = rv0_instr_i1_s3_itag_loc[0];
           //------------------------------------------------------------------------------------------------------------
           // axu0 RV1
           //------------------------------------------------------------------------------------------------------------
           assign rv0_axu0_instr_i0_instr = rv0_t0_i0_instr_q;
           assign rv0_axu0_instr_i0_ucode = rv0_t0_i0_ucode_q;
           assign rv0_axu0_instr_i0_itag = rv0_t0_i0_itag_q;
           assign rv0_axu0_instr_i0_ord = rv0_t0_i0_ord_q;
           assign rv0_axu0_instr_i0_cord = rv0_t0_i0_cord_q;

           assign rv0_axu0_instr_i0_t1_v = rv0_t0_i0_t1_v_q;
           assign rv0_axu0_instr_i0_t1_p = rv0_t0_i0_t1_p_q;
           assign rv0_axu0_instr_i0_t2_p = rv0_t0_i0_t2_p_q;
           assign rv0_axu0_instr_i0_t3_p = rv0_t0_i0_t3_p_q;

           assign rv0_axu0_instr_i0_s1_v = rv0_t0_i0_s1_v_q;
           assign rv0_axu0_instr_i0_s1_p = rv0_t0_i0_s1_p_q;
           assign rv0_axu0_instr_i0_s2_v = rv0_t0_i0_s2_v_q;
           assign rv0_axu0_instr_i0_s2_p = rv0_t0_i0_s2_p_q;
           assign rv0_axu0_instr_i0_s3_v = rv0_t0_i0_s3_v_q;
           assign rv0_axu0_instr_i0_s3_p = rv0_t0_i0_s3_p_q;

           assign rv0_axu0_instr_i0_isStore = rv0_t0_i0_isStore_q;
           assign rv0_axu0_instr_i0_spare = rv0_t0_i0_spare_q;

           assign rv0_axu0_instr_i1_instr = rv0_t0_i1_instr_q;
           assign rv0_axu0_instr_i1_ucode = rv0_t0_i1_ucode_q;
           assign rv0_axu0_instr_i1_itag = rv0_t0_i1_itag_q;
           assign rv0_axu0_instr_i1_ord = rv0_t0_i1_ord_q;
           assign rv0_axu0_instr_i1_cord = rv0_t0_i1_cord_q;

           assign rv0_axu0_instr_i1_t1_v = rv0_t0_i1_t1_v_q;
           assign rv0_axu0_instr_i1_t1_p = rv0_t0_i1_t1_p_q;
           assign rv0_axu0_instr_i1_t2_p = rv0_t0_i1_t2_p_q;
           assign rv0_axu0_instr_i1_t3_p = rv0_t0_i1_t3_p_q;

           assign rv0_axu0_instr_i1_s1_v = rv0_t0_i1_s1_v_q;
           assign rv0_axu0_instr_i1_s1_p = rv0_t0_i1_s1_p_q;
           assign rv0_axu0_instr_i1_s2_v = rv0_t0_i1_s2_v_q;
           assign rv0_axu0_instr_i1_s2_p = rv0_t0_i1_s2_p_q;
           assign rv0_axu0_instr_i1_s3_v = rv0_t0_i1_s3_v_q;
           assign rv0_axu0_instr_i1_s3_p = rv0_t0_i1_s3_p_q;

           assign rv0_axu0_instr_i1_isStore = rv0_t0_i1_isStore_q;
           assign rv0_axu0_instr_i1_spare = rv0_t0_i1_spare_q;
        end
   endgenerate

   // t1 :

   //------------------------------------------------------------------------------------------------------------
   //  FX0 RVS       --    Thread0        Thread1     --
   //------------------------------------------------------------------------------------------------------------
   //   I0      I1      I0(0)  I1(0)  I0(1)  I1(1)  ---
   // (-----, -----) <= (  0,     0,     0,     0)
   // (-----, I1(1)) <= (  0,     0,     0,     1)
   // (I0(1), -----) <= (  0,     0,     1,     0)
   // (I0(1), I1(1)) <= (  0,     0,     1,     1)
   // (-----, I1(0)) <= (  0,     1,     0,     0)
   // (I1(0), I1(1)) <= (  0,     1,     0,     1)
   // (I1(0), I0(1)) <= (  0,     1,     1,     0)
   // (I0(0), -----) <= (  1,     0,     0,     0)
   // (I0(0), I1(1)) <= (  1,     0,     0,     1)
   // (I0(0), I0(1)) <= (  1,     0,     1,     0)
   // (I0(0), I1(0)) <= (  1,     1,     0,     0)

   //------------------------------------------------------------------------------------------------------------
   //                --    Thread0        Thread1     --
   //------------------------------------------------------------------------------------------------------------
   //                -- I0(0)  I1(0)   I0(1)  I1(1)  ---
   // fx0_i0:              x      x       x
   // fx0_i1                      x       x      x

   //------------------------------------------------------------------------------------------------------------
   // FX0 RV0
   //------------------------------------------------------------------------------------------------------------
`ifndef THREADS1

   assign rv0_fx0_i0_sel[0] = rv0_t0_i0_rte_fx0_q;
   assign rv0_fx0_i0_sel[1] = rv0_t0_i1_rte_fx0_q & (rv0_t1_i0_rte_fx0_q | rv0_t1_i1_rte_fx0_q);
   assign rv0_fx0_i0_sel[2] = rv0_t1_i0_rte_fx0_q & (~rv0_t0_i0_rte_fx0_q) & (~rv0_t0_i1_rte_fx0_q);
   assign rv0_fx0_i1_sel[0] = rv0_t0_i1_rte_fx0_q & (~rv0_t1_i0_rte_fx0_q) & (~rv0_t1_i1_rte_fx0_q);
   assign rv0_fx0_i1_sel[1] = rv0_t1_i0_rte_fx0_q & (rv0_t0_i0_rte_fx0_q | rv0_t0_i1_rte_fx0_q);
   assign rv0_fx0_i1_sel[2] = rv0_t1_i1_rte_fx0_q;

   assign rv0_fx0_instr_i0_vld = {((rv0_fx0_i0_sel[0] & rv0_t0_i0_vld_q) | (rv0_fx0_i0_sel[1] & rv0_t0_i1_vld_q)), (rv0_fx0_i0_sel[2] & rv0_t1_i0_vld_q)};
   assign rv0_fx0_instr_i1_vld = {(rv0_fx0_i1_sel[0] & rv0_t0_i1_vld_q), ((rv0_fx0_i1_sel[1] & rv0_t1_i0_vld_q) | (rv0_fx0_i1_sel[2] & rv0_t1_i1_vld_q))};

   assign rv0_fx0_instr_i0_rte_fx0 = |(rv0_fx0_i0_sel);

   assign rv0_fx0_instr_i1_rte_fx0 = |(rv0_fx0_i1_sel);

   assign rv0_fx0_instr_i0_s1_dep_hit = (rv0_instr_i0_s1_dep_hit[0] & rv0_fx0_i0_sel[0]) | (rv0_instr_i1_s1_dep_hit_loc[0] & rv0_fx0_i0_sel[1]) | (rv0_instr_i0_s1_dep_hit[1] & rv0_fx0_i0_sel[2]);
   assign rv0_fx0_instr_i0_s2_dep_hit = (rv0_instr_i0_s2_dep_hit[0] & rv0_fx0_i0_sel[0]) | (rv0_instr_i1_s2_dep_hit_loc[0] & rv0_fx0_i0_sel[1]) | (rv0_instr_i0_s2_dep_hit[1] & rv0_fx0_i0_sel[2]);
   assign rv0_fx0_instr_i0_s3_dep_hit = (rv0_instr_i0_s3_dep_hit[0] & rv0_fx0_i0_sel[0]) | (rv0_instr_i1_s3_dep_hit_loc[0] & rv0_fx0_i0_sel[1]) | (rv0_instr_i0_s3_dep_hit[1] & rv0_fx0_i0_sel[2]);

   assign rv0_fx0_instr_i0_s1_itag = (rv0_t0_i0_s1_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i0_sel[0]}}) | (rv0_instr_i1_s1_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_s1_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_s2_itag = (rv0_t0_i0_s2_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i0_sel[0]}}) | (rv0_instr_i1_s2_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_s2_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_s3_itag = (rv0_t0_i0_s3_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i0_sel[0]}}) | (rv0_instr_i1_s3_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_s3_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i0_sel[2]}});

   assign rv0_fx0_instr_i1_s1_dep_hit = (rv0_instr_i1_s1_dep_hit_loc[0] & rv0_fx0_i1_sel[0]) | (rv0_instr_i0_s1_dep_hit[1] & rv0_fx0_i1_sel[1]) | (rv0_instr_i1_s1_dep_hit_loc[1] & rv0_fx0_i1_sel[2]);
   assign rv0_fx0_instr_i1_s2_dep_hit = (rv0_instr_i1_s2_dep_hit_loc[0] & rv0_fx0_i1_sel[0]) | (rv0_instr_i0_s2_dep_hit[1] & rv0_fx0_i1_sel[1]) | (rv0_instr_i1_s2_dep_hit_loc[1] & rv0_fx0_i1_sel[2]);
   assign rv0_fx0_instr_i1_s3_dep_hit = (rv0_instr_i1_s3_dep_hit_loc[0] & rv0_fx0_i1_sel[0]) | (rv0_instr_i0_s3_dep_hit[1] & rv0_fx0_i1_sel[1]) | (rv0_instr_i1_s3_dep_hit_loc[1] & rv0_fx0_i1_sel[2]);
   assign rv0_fx0_instr_i1_s1_itag = (rv0_instr_i1_s1_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_s1_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i1_sel[1]}}) | (rv0_instr_i1_s1_itag_loc[1] & {`ITAG_SIZE_ENC{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_s2_itag = (rv0_instr_i1_s2_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_s2_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i1_sel[1]}}) | (rv0_instr_i1_s2_itag_loc[1] & {`ITAG_SIZE_ENC{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_s3_itag = (rv0_instr_i1_s3_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_s3_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i1_sel[1]}}) | (rv0_instr_i1_s3_itag_loc[1] & {`ITAG_SIZE_ENC{rv0_fx0_i1_sel[2]}});

   //------------------------------------------------------------------------------------------------------------
   // FX0 RV1
   //------------------------------------------------------------------------------------------------------------

   assign rv0_fx0_instr_i0_instr = (rv0_t0_i0_instr_q & {32{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_instr_q & {32{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_instr_q & {32{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_ifar =  (rv0_t0_i0_ifar_q & {`EFF_IFAR_WIDTH{rv0_fx0_i0_sel[0]}})  | (rv0_t0_i1_ifar_q  & {`EFF_IFAR_WIDTH{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_ifar_q  & {`EFF_IFAR_WIDTH{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_ucode = (rv0_t0_i0_ucode_q & {3{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_ucode_q & {3{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_ucode_q & {3{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_ucode_cnt = (rv0_t0_i0_ucode_cnt_q & {`UCODE_ENTRIES_ENC{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_ucode_cnt_q & {`UCODE_ENTRIES_ENC{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_ucode_cnt_q & {`UCODE_ENTRIES_ENC{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_itag = (rv0_t0_i0_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_ord  = (rv0_t0_i0_ord_q  & rv0_fx0_i0_sel[0]) | ( rv0_t0_i1_ord_q & rv0_fx0_i0_sel[1]) | (rv0_t1_i0_ord_q  & rv0_fx0_i0_sel[2]);
   assign rv0_fx0_instr_i0_cord = (rv0_t0_i0_cord_q & rv0_fx0_i0_sel[0]) | (rv0_t0_i1_cord_q & rv0_fx0_i0_sel[1]) | (rv0_t1_i0_cord_q & rv0_fx0_i0_sel[2]);

   assign rv0_fx0_instr_i0_t1_v = (rv0_t0_i0_t1_v_q & rv0_fx0_i0_sel[0]) | (rv0_t0_i1_t1_v_q & rv0_fx0_i0_sel[1]) | (rv0_t1_i0_t1_v_q & rv0_fx0_i0_sel[2]);
   assign rv0_fx0_instr_i0_t1_p = (rv0_t0_i0_t1_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_t1_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_t1_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_t1_t = (rv0_t0_i0_t1_t_q & {3{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_t1_t_q & {3{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_t1_t_q & {3{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_t2_v = (rv0_t0_i0_t2_v_q & rv0_fx0_i0_sel[0]) | (rv0_t0_i1_t2_v_q & rv0_fx0_i0_sel[1]) | (rv0_t1_i0_t2_v_q & rv0_fx0_i0_sel[2]);
   assign rv0_fx0_instr_i0_t2_p = (rv0_t0_i0_t2_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_t2_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_t2_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_t2_t = (rv0_t0_i0_t2_t_q & {3{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_t2_t_q & {3{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_t2_t_q & {3{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_t3_v = (rv0_t0_i0_t3_v_q & rv0_fx0_i0_sel[0]) | (rv0_t0_i1_t3_v_q & rv0_fx0_i0_sel[1]) | (rv0_t1_i0_t3_v_q & rv0_fx0_i0_sel[2]);
   assign rv0_fx0_instr_i0_t3_p = (rv0_t0_i0_t3_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_t3_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_t3_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_t3_t = (rv0_t0_i0_t3_t_q & {3{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_t3_t_q & {3{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_t3_t_q & {3{rv0_fx0_i0_sel[2]}});

   assign rv0_fx0_instr_i0_s1_v = (rv0_t0_i0_s1_v_q & rv0_fx0_i0_sel[0]) | (rv0_t0_i1_s1_v_q & rv0_fx0_i0_sel[1]) | (rv0_t1_i0_s1_v_q & rv0_fx0_i0_sel[2]);
   assign rv0_fx0_instr_i0_s1_p = (rv0_t0_i0_s1_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_s1_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_s1_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_s1_t = (rv0_t0_i0_s1_t_q & {3{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_s1_t_q & {3{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_s1_t_q & {3{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_s2_v = (rv0_t0_i0_s2_v_q & rv0_fx0_i0_sel[0]) | (rv0_t0_i1_s2_v_q & rv0_fx0_i0_sel[1]) | (rv0_t1_i0_s2_v_q & rv0_fx0_i0_sel[2]);
   assign rv0_fx0_instr_i0_s2_p = (rv0_t0_i0_s2_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_s2_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_s2_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_s2_t = (rv0_t0_i0_s2_t_q & {3{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_s2_t_q & {3{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_s2_t_q & {3{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_s3_v = (rv0_t0_i0_s3_v_q & rv0_fx0_i0_sel[0]) | (rv0_t0_i1_s3_v_q & rv0_fx0_i0_sel[1]) | (rv0_t1_i0_s3_v_q & rv0_fx0_i0_sel[2]);
   assign rv0_fx0_instr_i0_s3_p = (rv0_t0_i0_s3_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_s3_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_s3_p_q & {`GPR_POOL_ENC{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_s3_t = (rv0_t0_i0_s3_t_q & {3{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_s3_t_q & {3{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_s3_t_q & {3{rv0_fx0_i0_sel[2]}});

   assign rv0_fx0_instr_i0_ilat    = (rv0_t0_i0_ilat    & {4{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_ilat    & {4{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_ilat    & {4{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_branch  = (rv0_t0_i0_branch_q  & {`G_BRANCH_LEN{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_branch_q  & {`G_BRANCH_LEN{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_branch_q  & {`G_BRANCH_LEN{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_spare   = (rv0_t0_i0_spare_q   & {4{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_spare_q   & {4{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_spare_q   & {4{rv0_fx0_i0_sel[2]}});
   assign rv0_fx0_instr_i0_is_brick = (rv0_t0_i0_is_brick & rv0_fx0_i0_sel[0]) | (rv0_t0_i1_is_brick & rv0_fx0_i0_sel[1]) | (rv0_t1_i0_is_brick & rv0_fx0_i0_sel[2]);
   assign rv0_fx0_instr_i0_brick    = (rv0_t0_i0_brick    & {3{rv0_fx0_i0_sel[0]}}) | (rv0_t0_i1_brick    & {3{rv0_fx0_i0_sel[1]}}) | (rv0_t1_i0_brick    & {3{rv0_fx0_i0_sel[2]}});


   assign rv0_fx0_instr_i1_instr = (rv0_t0_i1_instr_q & {32{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_instr_q & {32{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_instr_q & {32{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_ifar =  (rv0_t0_i1_ifar_q & {`EFF_IFAR_WIDTH{rv0_fx0_i1_sel[0]}})  | (rv0_t1_i0_ifar_q  & {`EFF_IFAR_WIDTH{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_ifar_q  & {`EFF_IFAR_WIDTH{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_ucode = (rv0_t0_i1_ucode_q & {3{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_ucode_q & {3{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_ucode_q & {3{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_ucode_cnt = (rv0_t0_i1_ucode_cnt_q & {`UCODE_ENTRIES_ENC{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_ucode_cnt_q & {`UCODE_ENTRIES_ENC{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_ucode_cnt_q & {`UCODE_ENTRIES_ENC{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_itag = (rv0_t0_i1_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_itag_q & {`ITAG_SIZE_ENC{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_ord  = (rv0_t0_i1_ord_q  & rv0_fx0_i1_sel[0]) | ( rv0_t1_i0_ord_q & rv0_fx0_i1_sel[1]) | (rv0_t1_i1_ord_q  & rv0_fx0_i1_sel[2]);
   assign rv0_fx0_instr_i1_cord = (rv0_t0_i1_cord_q & rv0_fx0_i1_sel[0]) | (rv0_t1_i0_cord_q & rv0_fx0_i1_sel[1]) | (rv0_t1_i1_cord_q & rv0_fx0_i1_sel[2]);

   assign rv0_fx0_instr_i1_t1_v = (rv0_t0_i1_t1_v_q & rv0_fx0_i1_sel[0]) | (rv0_t1_i0_t1_v_q & rv0_fx0_i1_sel[1]) | (rv0_t1_i1_t1_v_q & rv0_fx0_i1_sel[2]);
   assign rv0_fx0_instr_i1_t1_p = (rv0_t0_i1_t1_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_t1_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_t1_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_t1_t = (rv0_t0_i1_t1_t_q & {3{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_t1_t_q & {3{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_t1_t_q & {3{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_t2_v = (rv0_t0_i1_t2_v_q & rv0_fx0_i1_sel[0]) | (rv0_t1_i0_t2_v_q & rv0_fx0_i1_sel[1]) | (rv0_t1_i1_t2_v_q & rv0_fx0_i1_sel[2]);
   assign rv0_fx0_instr_i1_t2_p = (rv0_t0_i1_t2_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_t2_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_t2_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_t2_t = (rv0_t0_i1_t2_t_q & {3{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_t2_t_q & {3{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_t2_t_q & {3{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_t3_v = (rv0_t0_i1_t3_v_q & rv0_fx0_i1_sel[0]) | (rv0_t1_i0_t3_v_q & rv0_fx0_i1_sel[1]) | (rv0_t1_i1_t3_v_q & rv0_fx0_i1_sel[2]);
   assign rv0_fx0_instr_i1_t3_p = (rv0_t0_i1_t3_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_t3_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_t3_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_t3_t = (rv0_t0_i1_t3_t_q & {3{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_t3_t_q & {3{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_t3_t_q & {3{rv0_fx0_i1_sel[2]}});

   assign rv0_fx0_instr_i1_s1_v = (rv0_t0_i1_s1_v_q & rv0_fx0_i1_sel[0]) | (rv0_t1_i0_s1_v_q & rv0_fx0_i1_sel[1]) | (rv0_t1_i1_s1_v_q & rv0_fx0_i1_sel[2]);
   assign rv0_fx0_instr_i1_s1_p = (rv0_t0_i1_s1_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_s1_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_s1_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_s1_t = (rv0_t0_i1_s1_t_q & {3{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_s1_t_q & {3{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_s1_t_q & {3{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_s2_v = (rv0_t0_i1_s2_v_q & rv0_fx0_i1_sel[0]) | (rv0_t1_i0_s2_v_q & rv0_fx0_i1_sel[1]) | (rv0_t1_i1_s2_v_q & rv0_fx0_i1_sel[2]);
   assign rv0_fx0_instr_i1_s2_p = (rv0_t0_i1_s2_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_s2_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_s2_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_s2_t = (rv0_t0_i1_s2_t_q & {3{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_s2_t_q & {3{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_s2_t_q & {3{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_s3_v = (rv0_t0_i1_s3_v_q & rv0_fx0_i1_sel[0]) | (rv0_t1_i0_s3_v_q & rv0_fx0_i1_sel[1]) | (rv0_t1_i1_s3_v_q & rv0_fx0_i1_sel[2]);
   assign rv0_fx0_instr_i1_s3_p = (rv0_t0_i1_s3_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_s3_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_s3_p_q & {`GPR_POOL_ENC{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_s3_t = (rv0_t0_i1_s3_t_q & {3{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_s3_t_q & {3{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_s3_t_q & {3{rv0_fx0_i1_sel[2]}});

   assign rv0_fx0_instr_i1_ilat    = (rv0_t0_i1_ilat    & {4{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_ilat    & {4{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_ilat    & {4{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_branch  = (rv0_t0_i1_branch_q  & {`G_BRANCH_LEN{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_branch_q  & {`G_BRANCH_LEN{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_branch_q  & {`G_BRANCH_LEN{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_spare   = (rv0_t0_i1_spare_q   & {4{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_spare_q   & {4{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_spare_q   & {4{rv0_fx0_i1_sel[2]}});
   assign rv0_fx0_instr_i1_is_brick = (rv0_t0_i1_is_brick & rv0_fx0_i1_sel[0]) | (rv0_t1_i0_is_brick & rv0_fx0_i1_sel[1]) | (rv0_t1_i1_is_brick & rv0_fx0_i1_sel[2]);
   assign rv0_fx0_instr_i1_brick    = (rv0_t0_i1_brick    & {3{rv0_fx0_i1_sel[0]}}) | (rv0_t1_i0_brick    & {3{rv0_fx0_i1_sel[1]}}) | (rv0_t1_i1_brick    & {3{rv0_fx0_i1_sel[2]}});



   //------------------------------------------------------------------------------------------------------------
   // fx1 RV0
   //------------------------------------------------------------------------------------------------------------
   //------------------------------------------------------------------------------------------------------------
   //  FX0 RVS       --    Thread0        Thread1     --
   //------------------------------------------------------------------------------------------------------------
   //   I0      I1      I0(0)  I1(0)  I0(1)  I1(1)  ---
   // (-----, -----) <= (  0,     0,     0,     0)
   // (-----, I1(1)) <= (  0,     0,     0,     1)
   // (I0(1), -----) <= (  0,     0,     1,     0)
   // (I0(1), I1(1)) <= (  0,     0,     1,     1)
   // (-----, I1(0)) <= (  0,     1,     0,     0)
   // (I1(0), I1(1)) <= (  0,     1,     0,     1)
   // (I1(0), I0(1)) <= (  0,     1,     1,     0)
   // (I0(0), -----) <= (  1,     0,     0,     0)
   // (I0(0), I1(1)) <= (  1,     0,     0,     1)
   // (I0(0), I0(1)) <= (  1,     0,     1,     0)
   // (I0(0), I1(0)) <= (  1,     1,     0,     0)

   //------------------------------------------------------------------------------------------------------------
   //                --    Thread0        Thread1     --
   //------------------------------------------------------------------------------------------------------------
   //                -- I0(0)  I1(0)   I0(1)  I1(1)  ---
   // fx0_i0:              x      x       x
   // fx0_i1                      x       x      x

   assign rv0_fx1_i0_sel[0] = rv0_t0_i0_rte_fx1_q;
   assign rv0_fx1_i0_sel[1] = rv0_t0_i1_rte_fx1_q & (rv0_t1_i0_rte_fx1_q | rv0_t1_i1_rte_fx1_q);
   assign rv0_fx1_i0_sel[2] = rv0_t1_i0_rte_fx1_q & (~rv0_t0_i0_rte_fx1_q) & (~rv0_t0_i1_rte_fx1_q);
   assign rv0_fx1_i1_sel[0] = rv0_t0_i1_rte_fx1_q & (~rv0_t1_i0_rte_fx1_q) & (~rv0_t1_i1_rte_fx1_q);
   assign rv0_fx1_i1_sel[1] = rv0_t1_i0_rte_fx1_q & (rv0_t0_i0_rte_fx1_q | rv0_t0_i1_rte_fx1_q);
   assign rv0_fx1_i1_sel[2] = rv0_t1_i1_rte_fx1_q;

   assign rv0_fx1_instr_i0_vld = {((rv0_fx1_i0_sel[0] & rv0_t0_i0_vld_q) | (rv0_fx1_i0_sel[1] & rv0_t0_i1_vld_q)), (rv0_fx1_i0_sel[2] & rv0_t1_i0_vld_q)};
   assign rv0_fx1_instr_i1_vld = {(rv0_fx1_i1_sel[0] & rv0_t0_i1_vld_q), ((rv0_fx1_i1_sel[1] & rv0_t1_i0_vld_q) | (rv0_fx1_i1_sel[2] & rv0_t1_i1_vld_q))};

   assign rv0_fx1_instr_i0_rte_fx1 = |(rv0_fx1_i0_sel);

   assign rv0_fx1_instr_i1_rte_fx1 = |(rv0_fx1_i1_sel);

   assign rv0_fx1_instr_i0_s1_dep_hit = (rv0_instr_i0_s1_dep_hit[0] & rv0_fx1_i0_sel[0]) | (rv0_instr_i1_s1_dep_hit_loc[0] & rv0_fx1_i0_sel[1]) | (rv0_instr_i0_s1_dep_hit[1] & rv0_fx1_i0_sel[2]);
   assign rv0_fx1_instr_i0_s2_dep_hit = (rv0_instr_i0_s2_dep_hit[0] & rv0_fx1_i0_sel[0]) | (rv0_instr_i1_s2_dep_hit_loc[0] & rv0_fx1_i0_sel[1]) | (rv0_instr_i0_s2_dep_hit[1] & rv0_fx1_i0_sel[2]);
   assign rv0_fx1_instr_i0_s3_dep_hit = (rv0_instr_i0_s3_dep_hit[0] & rv0_fx1_i0_sel[0]) | (rv0_instr_i1_s3_dep_hit_loc[0] & rv0_fx1_i0_sel[1]) | (rv0_instr_i0_s3_dep_hit[1] & rv0_fx1_i0_sel[2]);

   assign rv0_fx1_instr_i0_s1_itag = (rv0_t0_i0_s1_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i0_sel[0]}}) | (rv0_instr_i1_s1_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_s1_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i0_sel[2]}});
   assign rv0_fx1_instr_i0_s2_itag = (rv0_t0_i0_s2_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i0_sel[0]}}) | (rv0_instr_i1_s2_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_s2_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i0_sel[2]}});
   assign rv0_fx1_instr_i0_s3_itag = (rv0_t0_i0_s3_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i0_sel[0]}}) | (rv0_instr_i1_s3_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_s3_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i0_sel[2]}});

   assign rv0_fx1_instr_i1_s1_dep_hit = (rv0_instr_i1_s1_dep_hit_loc[0] & rv0_fx1_i1_sel[0]) | (rv0_instr_i0_s1_dep_hit[1] & rv0_fx1_i1_sel[1]) | (rv0_instr_i1_s1_dep_hit_loc[1] & rv0_fx1_i1_sel[2]);
   assign rv0_fx1_instr_i1_s2_dep_hit = (rv0_instr_i1_s2_dep_hit_loc[0] & rv0_fx1_i1_sel[0]) | (rv0_instr_i0_s2_dep_hit[1] & rv0_fx1_i1_sel[1]) | (rv0_instr_i1_s2_dep_hit_loc[1] & rv0_fx1_i1_sel[2]);
   assign rv0_fx1_instr_i1_s3_dep_hit = (rv0_instr_i1_s3_dep_hit_loc[0] & rv0_fx1_i1_sel[0]) | (rv0_instr_i0_s3_dep_hit[1] & rv0_fx1_i1_sel[1]) | (rv0_instr_i1_s3_dep_hit_loc[1] & rv0_fx1_i1_sel[2]);
   assign rv0_fx1_instr_i1_s1_itag = (rv0_instr_i1_s1_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_s1_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i1_sel[1]}}) | (rv0_instr_i1_s1_itag_loc[1] & {`ITAG_SIZE_ENC{rv0_fx1_i1_sel[2]}});
   assign rv0_fx1_instr_i1_s2_itag = (rv0_instr_i1_s2_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_s2_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i1_sel[1]}}) | (rv0_instr_i1_s2_itag_loc[1] & {`ITAG_SIZE_ENC{rv0_fx1_i1_sel[2]}});
   assign rv0_fx1_instr_i1_s3_itag = (rv0_instr_i1_s3_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_s3_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i1_sel[1]}}) | (rv0_instr_i1_s3_itag_loc[1] & {`ITAG_SIZE_ENC{rv0_fx1_i1_sel[2]}});

   //------------------------------------------------------------------------------------------------------------
   // FX1 RV1
   //------------------------------------------------------------------------------------------------------------

   assign rv0_fx1_instr_i0_instr = (rv0_t0_i0_instr_q & {32{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_instr_q & {32{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_instr_q & {32{rv0_fx1_i0_sel[2]}});
   assign rv0_fx1_instr_i0_ucode = (rv0_t0_i0_ucode_q & {3{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_ucode_q & {3{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_ucode_q & {3{rv0_fx1_i0_sel[2]}});
   assign rv0_fx1_instr_i0_itag = (rv0_t0_i0_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i0_sel[2]}});

   assign rv0_fx1_instr_i0_t1_v = (rv0_t0_i0_t1_v_q & rv0_fx1_i0_sel[0]) | (rv0_t0_i1_t1_v_q & rv0_fx1_i0_sel[1]) | (rv0_t1_i0_t1_v_q & rv0_fx1_i0_sel[2]);
   assign rv0_fx1_instr_i0_t1_p = (rv0_t0_i0_t1_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_t1_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_t1_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[2]}});
   assign rv0_fx1_instr_i0_t2_v = (rv0_t0_i0_t2_v_q & rv0_fx1_i0_sel[0]) | (rv0_t0_i1_t2_v_q & rv0_fx1_i0_sel[1]) | (rv0_t1_i0_t2_v_q & rv0_fx1_i0_sel[2]);
   assign rv0_fx1_instr_i0_t2_p = (rv0_t0_i0_t2_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_t2_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_t2_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[2]}});
   assign rv0_fx1_instr_i0_t3_v = (rv0_t0_i0_t3_v_q & rv0_fx1_i0_sel[0]) | (rv0_t0_i1_t3_v_q & rv0_fx1_i0_sel[1]) | (rv0_t1_i0_t3_v_q & rv0_fx1_i0_sel[2]);
   assign rv0_fx1_instr_i0_t3_p = (rv0_t0_i0_t3_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_t3_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_t3_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[2]}});

   assign rv0_fx1_instr_i0_s1_v = (rv0_t0_i0_s1_v_q & rv0_fx1_i0_sel[0]) | (rv0_t0_i1_s1_v_q & rv0_fx1_i0_sel[1]) | (rv0_t1_i0_s1_v_q & rv0_fx1_i0_sel[2]);
   assign rv0_fx1_instr_i0_s1_p = (rv0_t0_i0_s1_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_s1_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_s1_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[2]}});
   assign rv0_fx1_instr_i0_s1_t = (rv0_t0_i0_s1_t_q & {3{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_s1_t_q & {3{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_s1_t_q & {3{rv0_fx1_i0_sel[2]}});
   assign rv0_fx1_instr_i0_s2_v = (rv0_t0_i0_s2_v_q & rv0_fx1_i0_sel[0]) | (rv0_t0_i1_s2_v_q & rv0_fx1_i0_sel[1]) | (rv0_t1_i0_s2_v_q & rv0_fx1_i0_sel[2]);
   assign rv0_fx1_instr_i0_s2_p = (rv0_t0_i0_s2_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_s2_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_s2_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[2]}});
   assign rv0_fx1_instr_i0_s2_t = (rv0_t0_i0_s2_t_q & {3{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_s2_t_q & {3{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_s2_t_q & {3{rv0_fx1_i0_sel[2]}});
   assign rv0_fx1_instr_i0_s3_v = (rv0_t0_i0_s3_v_q & rv0_fx1_i0_sel[0]) | (rv0_t0_i1_s3_v_q & rv0_fx1_i0_sel[1]) | (rv0_t1_i0_s3_v_q & rv0_fx1_i0_sel[2]);
   assign rv0_fx1_instr_i0_s3_p = (rv0_t0_i0_s3_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_s3_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_s3_p_q & {`GPR_POOL_ENC{rv0_fx1_i0_sel[2]}});
   assign rv0_fx1_instr_i0_s3_t = (rv0_t0_i0_s3_t_q & {3{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_s3_t_q & {3{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_s3_t_q & {3{rv0_fx1_i0_sel[2]}});

   assign rv0_fx1_instr_i0_ilat    = (rv0_t0_i0_ilat    & {4{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_ilat    & {4{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_ilat    & {4{rv0_fx1_i0_sel[2]}});
   assign rv0_fx1_instr_i0_isStore = (rv0_t0_i0_isStore_q & rv0_fx1_i0_sel[0]) | (rv0_t0_i1_isStore_q & rv0_fx1_i0_sel[1]) | (rv0_t1_i0_isStore_q & rv0_fx1_i0_sel[2]);
   assign rv0_fx1_instr_i0_spare   = (rv0_t0_i0_spare_q   & {4{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_spare_q   & {4{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_spare_q   & {4{rv0_fx1_i0_sel[2]}});
   assign rv0_fx1_instr_i0_is_brick = (rv0_t0_i0_is_brick & rv0_fx1_i0_sel[0]) | (rv0_t0_i1_is_brick & rv0_fx1_i0_sel[1]) | (rv0_t1_i0_is_brick & rv0_fx1_i0_sel[2]);
   assign rv0_fx1_instr_i0_brick    = (rv0_t0_i0_brick    & {3{rv0_fx1_i0_sel[0]}}) | (rv0_t0_i1_brick    & {3{rv0_fx1_i0_sel[1]}}) | (rv0_t1_i0_brick    & {3{rv0_fx1_i0_sel[2]}});


   assign rv0_fx1_instr_i1_instr = (rv0_t0_i1_instr_q & {32{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_instr_q & {32{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_instr_q & {32{rv0_fx1_i1_sel[2]}});
   assign rv0_fx1_instr_i1_ucode = (rv0_t0_i1_ucode_q & {3{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_ucode_q & {3{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_ucode_q & {3{rv0_fx1_i1_sel[2]}});
   assign rv0_fx1_instr_i1_itag = (rv0_t0_i1_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_itag_q & {`ITAG_SIZE_ENC{rv0_fx1_i1_sel[2]}});

   assign rv0_fx1_instr_i1_t1_v = (rv0_t0_i1_t1_v_q & rv0_fx1_i1_sel[0]) | (rv0_t1_i0_t1_v_q & rv0_fx1_i1_sel[1]) | (rv0_t1_i1_t1_v_q & rv0_fx1_i1_sel[2]);
   assign rv0_fx1_instr_i1_t1_p = (rv0_t0_i1_t1_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_t1_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_t1_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[2]}});
   assign rv0_fx1_instr_i1_t2_v = (rv0_t0_i1_t2_v_q & rv0_fx1_i1_sel[0]) | (rv0_t1_i0_t2_v_q & rv0_fx1_i1_sel[1]) | (rv0_t1_i1_t2_v_q & rv0_fx1_i1_sel[2]);
   assign rv0_fx1_instr_i1_t2_p = (rv0_t0_i1_t2_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_t2_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_t2_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[2]}});
   assign rv0_fx1_instr_i1_t3_v = (rv0_t0_i1_t3_v_q & rv0_fx1_i1_sel[0]) | (rv0_t1_i0_t3_v_q & rv0_fx1_i1_sel[1]) | (rv0_t1_i1_t3_v_q & rv0_fx1_i1_sel[2]);
   assign rv0_fx1_instr_i1_t3_p = (rv0_t0_i1_t3_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_t3_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_t3_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[2]}});

   assign rv0_fx1_instr_i1_s1_v = (rv0_t0_i1_s1_v_q & rv0_fx1_i1_sel[0]) | (rv0_t1_i0_s1_v_q & rv0_fx1_i1_sel[1]) | (rv0_t1_i1_s1_v_q & rv0_fx1_i1_sel[2]);
   assign rv0_fx1_instr_i1_s1_p = (rv0_t0_i1_s1_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_s1_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_s1_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[2]}});
   assign rv0_fx1_instr_i1_s1_t = (rv0_t0_i1_s1_t_q & {3{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_s1_t_q & {3{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_s1_t_q & {3{rv0_fx1_i1_sel[2]}});
   assign rv0_fx1_instr_i1_s2_v = (rv0_t0_i1_s2_v_q & rv0_fx1_i1_sel[0]) | (rv0_t1_i0_s2_v_q & rv0_fx1_i1_sel[1]) | (rv0_t1_i1_s2_v_q & rv0_fx1_i1_sel[2]);
   assign rv0_fx1_instr_i1_s2_p = (rv0_t0_i1_s2_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_s2_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_s2_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[2]}});
   assign rv0_fx1_instr_i1_s2_t = (rv0_t0_i1_s2_t_q & {3{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_s2_t_q & {3{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_s2_t_q & {3{rv0_fx1_i1_sel[2]}});
   assign rv0_fx1_instr_i1_s3_v = (rv0_t0_i1_s3_v_q & rv0_fx1_i1_sel[0]) | (rv0_t1_i0_s3_v_q & rv0_fx1_i1_sel[1]) | (rv0_t1_i1_s3_v_q & rv0_fx1_i1_sel[2]);
   assign rv0_fx1_instr_i1_s3_p = (rv0_t0_i1_s3_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_s3_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_s3_p_q & {`GPR_POOL_ENC{rv0_fx1_i1_sel[2]}});
   assign rv0_fx1_instr_i1_s3_t = (rv0_t0_i1_s3_t_q & {3{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_s3_t_q & {3{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_s3_t_q & {3{rv0_fx1_i1_sel[2]}});

   assign rv0_fx1_instr_i1_ilat    = (rv0_t0_i1_ilat    & {4{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_ilat    & {4{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_ilat    & {4{rv0_fx1_i1_sel[2]}});
   assign rv0_fx1_instr_i1_isStore = (rv0_t0_i1_isStore_q & rv0_fx1_i1_sel[0]) | (rv0_t1_i0_isStore_q & rv0_fx1_i1_sel[1]) | (rv0_t1_i1_isStore_q & rv0_fx1_i1_sel[2]);
   assign rv0_fx1_instr_i1_spare   = (rv0_t0_i1_spare_q   & {4{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_spare_q   & {4{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_spare_q   & {4{rv0_fx1_i1_sel[2]}});
   assign rv0_fx1_instr_i1_is_brick = (rv0_t0_i1_is_brick & rv0_fx1_i1_sel[0]) | (rv0_t1_i0_is_brick & rv0_fx1_i1_sel[1]) | (rv0_t1_i1_is_brick & rv0_fx1_i1_sel[2]);
   assign rv0_fx1_instr_i1_brick    = (rv0_t0_i1_brick    & {3{rv0_fx1_i1_sel[0]}}) | (rv0_t1_i0_brick    & {3{rv0_fx1_i1_sel[1]}}) | (rv0_t1_i1_brick    & {3{rv0_fx1_i1_sel[2]}});





   //------------------------------------------------------------------------------------------------------------
   // lq RV0
   //------------------------------------------------------------------------------------------------------------


   assign rv0_lq_i0_sel[0] = rv0_t0_i0_rte_lq_q;
   assign rv0_lq_i0_sel[1] = rv0_t0_i1_rte_lq_q & (rv0_t1_i0_rte_lq_q | rv0_t1_i1_rte_lq_q);
   assign rv0_lq_i0_sel[2] = rv0_t1_i0_rte_lq_q & (~rv0_t0_i0_rte_lq_q) & (~rv0_t0_i1_rte_lq_q);
   assign rv0_lq_i1_sel[0] = rv0_t0_i1_rte_lq_q & (~rv0_t1_i0_rte_lq_q) & (~rv0_t1_i1_rte_lq_q);
   assign rv0_lq_i1_sel[1] = rv0_t1_i0_rte_lq_q & (rv0_t0_i0_rte_lq_q | rv0_t0_i1_rte_lq_q);
   assign rv0_lq_i1_sel[2] = rv0_t1_i1_rte_lq_q;

   assign rv1_lq_instr_i0_vld_d = {((rv0_lq_i0_sel[0] & rv0_t0_i0_vld_q) | (rv0_lq_i0_sel[1] & rv0_t0_i1_vld_q)), (rv0_lq_i0_sel[2] & rv0_t1_i0_vld_q)};
   assign rv1_lq_instr_i1_vld_d = {(rv0_lq_i1_sel[0] & rv0_t0_i1_vld_q), ((rv0_lq_i1_sel[1] & rv0_t1_i0_vld_q) | (rv0_lq_i1_sel[2] & rv0_t1_i1_vld_q))};

   assign rv0_lq_instr_i0_vld = rv1_lq_instr_i0_vld_d;
   assign rv0_lq_instr_i1_vld = rv1_lq_instr_i1_vld_d;

   assign rv1_lq_instr_i0_rte_lq_d = |(rv0_lq_i0_sel);
   assign rv1_lq_instr_i1_rte_lq_d = |(rv0_lq_i1_sel);

   assign rv0_lq_instr_i0_rte_lq = rv1_lq_instr_i0_rte_lq_d;
   assign rv0_lq_instr_i1_rte_lq = rv1_lq_instr_i1_rte_lq_d;

   assign rv1_lq_instr_i0_rte_sq_d = (rv0_t0_i0_rte_sq_q & rv0_lq_i0_sel[0]) | (rv0_t0_i1_rte_sq_q & rv0_lq_i0_sel[1]) | (rv0_t1_i0_rte_sq_q & rv0_lq_i0_sel[2]);
   assign rv1_lq_instr_i1_rte_sq_d = (rv0_t0_i1_rte_sq_q & rv0_lq_i1_sel[0]) | (rv0_t1_i0_rte_sq_q & rv0_lq_i1_sel[1]) | (rv0_t1_i1_rte_sq_q & rv0_lq_i1_sel[2]);

   assign rv0_lq_instr_i0_s1_dep_hit = (rv0_instr_i0_s1_dep_hit[0] & rv0_lq_i0_sel[0]) | (rv0_instr_i1_s1_dep_hit_loc[0] & rv0_lq_i0_sel[1]) | (rv0_instr_i0_s1_dep_hit[1] & rv0_lq_i0_sel[2]);
   assign rv0_lq_instr_i0_s2_dep_hit = (rv0_instr_i0_s2_dep_hit[0] & rv0_lq_i0_sel[0]) | (rv0_instr_i1_s2_dep_hit_loc[0] & rv0_lq_i0_sel[1]) | (rv0_instr_i0_s2_dep_hit[1] & rv0_lq_i0_sel[2]);

   assign rv0_lq_instr_i0_s1_itag = (rv0_t0_i0_s1_itag_q & {`ITAG_SIZE_ENC{rv0_lq_i0_sel[0]}}) | (rv0_instr_i1_s1_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_s1_itag_q & {`ITAG_SIZE_ENC{rv0_lq_i0_sel[2]}});
   assign rv0_lq_instr_i0_s2_itag = (rv0_t0_i0_s2_itag_q & {`ITAG_SIZE_ENC{rv0_lq_i0_sel[0]}}) | (rv0_instr_i1_s2_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_s2_itag_q & {`ITAG_SIZE_ENC{rv0_lq_i0_sel[2]}});

   assign rv0_lq_instr_i1_s1_dep_hit = (rv0_instr_i1_s1_dep_hit_loc[0] & rv0_lq_i1_sel[0]) | (rv0_instr_i0_s1_dep_hit[1] & rv0_lq_i1_sel[1]) | (rv0_instr_i1_s1_dep_hit_loc[1] & rv0_lq_i1_sel[2]);
   assign rv0_lq_instr_i1_s2_dep_hit = (rv0_instr_i1_s2_dep_hit_loc[0] & rv0_lq_i1_sel[0]) | (rv0_instr_i0_s2_dep_hit[1] & rv0_lq_i1_sel[1]) | (rv0_instr_i1_s2_dep_hit_loc[1] & rv0_lq_i1_sel[2]);
   assign rv0_lq_instr_i1_s1_itag = (rv0_instr_i1_s1_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_s1_itag_q & {`ITAG_SIZE_ENC{rv0_lq_i1_sel[1]}}) | (rv0_instr_i1_s1_itag_loc[1] & {`ITAG_SIZE_ENC{rv0_lq_i1_sel[2]}});
   assign rv0_lq_instr_i1_s2_itag = (rv0_instr_i1_s2_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_s2_itag_q & {`ITAG_SIZE_ENC{rv0_lq_i1_sel[1]}}) | (rv0_instr_i1_s2_itag_loc[1] & {`ITAG_SIZE_ENC{rv0_lq_i1_sel[2]}});

   //------------------------------------------------------------------------------------------------------------
   // lq RV1
   //------------------------------------------------------------------------------------------------------------


   assign rv0_lq_instr_i0_instr = (rv0_t0_i0_instr_q & {32{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_instr_q & {32{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_instr_q & {32{rv0_lq_i0_sel[2]}});
   assign rv0_lq_instr_i0_ifar =  (rv0_t0_i0_ifar_q[61 - `PF_IAR_BITS + 1:61] & {`PF_IAR_BITS{rv0_lq_i0_sel[0]}})  | (rv0_t0_i1_ifar_q[61 - `PF_IAR_BITS + 1:61]  & {`PF_IAR_BITS{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_ifar_q[61 - `PF_IAR_BITS + 1:61]  & {`PF_IAR_BITS{rv0_lq_i0_sel[2]}});
   assign rv1_lq_instr_i0_ucode_d = (rv0_t0_i0_ucode_q & {3{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_ucode_q & {3{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_ucode_q & {3{rv0_lq_i0_sel[2]}});
   assign rv1_lq_instr_i0_2ucode_d = (rv0_t0_i0_2ucode_q & rv0_lq_i0_sel[0]) |  (rv0_t1_i0_2ucode_q & rv0_lq_i0_sel[2]); // No i1_2ucode
   assign rv1_lq_instr_i0_ucode_cnt_d = (rv0_t0_i0_ucode_cnt_q & {`UCODE_ENTRIES_ENC{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_ucode_cnt_q & {`UCODE_ENTRIES_ENC{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_ucode_cnt_q & {`UCODE_ENTRIES_ENC{rv0_lq_i0_sel[2]}});
   assign rv1_lq_instr_i0_itag_d = (rv0_t0_i0_itag_q & {`ITAG_SIZE_ENC{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_itag_q & {`ITAG_SIZE_ENC{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_itag_q & {`ITAG_SIZE_ENC{rv0_lq_i0_sel[2]}});
   assign rv0_lq_instr_i0_ord  = (rv0_t0_i0_ord_q  & rv0_lq_i0_sel[0]) | ( rv0_t0_i1_ord_q & rv0_lq_i0_sel[1]) | (rv0_t1_i0_ord_q  & rv0_lq_i0_sel[2]);
   assign rv0_lq_instr_i0_cord = (rv0_t0_i0_cord_q & rv0_lq_i0_sel[0]) | (rv0_t0_i1_cord_q & rv0_lq_i0_sel[1]) | (rv0_t1_i0_cord_q & rv0_lq_i0_sel[2]);
   assign rv0_lq_instr_i0_spec = (rv0_t0_i0_spec_q & rv0_lq_i0_sel[0]) | (rv0_t0_i1_spec_q & rv0_lq_i0_sel[1]) | (rv0_t1_i0_spec_q & rv0_lq_i0_sel[2]);

   assign rv0_lq_instr_i0_t1_v = (rv0_t0_i0_t1_v_q & rv0_lq_i0_sel[0]) | (rv0_t0_i1_t1_v_q & rv0_lq_i0_sel[1]) | (rv0_t1_i0_t1_v_q & rv0_lq_i0_sel[2]);
   assign rv0_lq_instr_i0_t1_p = (rv0_t0_i0_t1_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_t1_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_t1_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[2]}});
   assign rv0_lq_instr_i0_t2_v = (rv0_t0_i0_t2_v_q & rv0_lq_i0_sel[0]) | (rv0_t0_i1_t2_v_q & rv0_lq_i0_sel[1]) | (rv0_t1_i0_t2_v_q & rv0_lq_i0_sel[2]);
   assign rv0_lq_instr_i0_t2_p = (rv0_t0_i0_t2_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_t2_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_t2_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[2]}});
   assign rv0_lq_instr_i0_t2_t = (rv0_t0_i0_t2_t_q & {3{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_t2_t_q & {3{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_t2_t_q & {3{rv0_lq_i0_sel[2]}});
   assign rv0_lq_instr_i0_t3_v = (rv0_t0_i0_t3_v_q & rv0_lq_i0_sel[0]) | (rv0_t0_i1_t3_v_q & rv0_lq_i0_sel[1]) | (rv0_t1_i0_t3_v_q & rv0_lq_i0_sel[2]);
   assign rv0_lq_instr_i0_t3_p = (rv0_t0_i0_t3_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_t3_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_t3_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[2]}});
   assign rv0_lq_instr_i0_t3_t = (rv0_t0_i0_t3_t_q & {3{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_t3_t_q & {3{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_t3_t_q & {3{rv0_lq_i0_sel[2]}});

   assign rv0_lq_instr_i0_s1_v = (rv0_t0_i0_s1_v_q & rv0_lq_i0_sel[0]) | (rv0_t0_i1_s1_v_q & rv0_lq_i0_sel[1]) | (rv0_t1_i0_s1_v_q & rv0_lq_i0_sel[2]);
   assign rv0_lq_instr_i0_s1_p = (rv0_t0_i0_s1_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_s1_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_s1_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[2]}});
   assign rv0_lq_instr_i0_s1_t = (rv0_t0_i0_s1_t_q & {3{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_s1_t_q & {3{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_s1_t_q & {3{rv0_lq_i0_sel[2]}});
   assign rv0_lq_instr_i0_s2_v = (rv0_t0_i0_s2_v_q & rv0_lq_i0_sel[0]) | (rv0_t0_i1_s2_v_q & rv0_lq_i0_sel[1]) | (rv0_t1_i0_s2_v_q & rv0_lq_i0_sel[2]);
   assign rv0_lq_instr_i0_s2_p = (rv0_t0_i0_s2_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_s2_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_s2_p_q & {`GPR_POOL_ENC{rv0_lq_i0_sel[2]}});
   assign rv0_lq_instr_i0_s2_t = (rv0_t0_i0_s2_t_q & {3{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_s2_t_q & {3{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_s2_t_q & {3{rv0_lq_i0_sel[2]}});
   assign rv1_lq_instr_i0_s3_t_d = (rv0_t0_i0_s3_t_q & {3{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_s3_t_q & {3{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_s3_t_q & {3{rv0_lq_i0_sel[2]}});

   assign rv1_lq_instr_i0_isLoad_d  = (rv0_t0_i0_isLoad_q  & rv0_lq_i0_sel[0]) | (rv0_t0_i1_isLoad_q  & rv0_lq_i0_sel[1]) | (rv0_t1_i0_isLoad_q  & rv0_lq_i0_sel[2]);
   assign rv1_lq_instr_i0_isStore_d = (rv0_t0_i0_isStore_q & rv0_lq_i0_sel[0]) | (rv0_t0_i1_isStore_q & rv0_lq_i0_sel[1]) | (rv0_t1_i0_isStore_q & rv0_lq_i0_sel[2]);
   assign rv0_lq_instr_i0_spare   = (rv0_t0_i0_spare_q   & {4{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_spare_q   & {4{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_spare_q   & {4{rv0_lq_i0_sel[2]}});
   assign rv0_lq_instr_i0_is_brick = (rv0_t0_i0_is_brick & rv0_lq_i0_sel[0]) | (rv0_t0_i1_is_brick & rv0_lq_i0_sel[1]) | (rv0_t1_i0_is_brick & rv0_lq_i0_sel[2]);
   assign rv0_lq_instr_i0_brick    = (rv0_t0_i0_brick    & {3{rv0_lq_i0_sel[0]}}) | (rv0_t0_i1_brick    & {3{rv0_lq_i0_sel[1]}}) | (rv0_t1_i0_brick    & {3{rv0_lq_i0_sel[2]}});


   assign rv0_lq_instr_i1_instr = (rv0_t0_i1_instr_q & {32{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_instr_q & {32{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_instr_q & {32{rv0_lq_i1_sel[2]}});
   assign rv0_lq_instr_i1_ifar =  (rv0_t0_i1_ifar_q[61 - `PF_IAR_BITS + 1:61] & {`PF_IAR_BITS{rv0_lq_i1_sel[0]}})  | (rv0_t1_i0_ifar_q[61 - `PF_IAR_BITS + 1:61]  & {`PF_IAR_BITS{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_ifar_q[61 - `PF_IAR_BITS + 1:61]  & {`PF_IAR_BITS{rv0_lq_i1_sel[2]}});
   assign rv1_lq_instr_i1_ucode_d = (rv0_t0_i1_ucode_q & {3{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_ucode_q & {3{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_ucode_q & {3{rv0_lq_i1_sel[2]}});
   assign rv1_lq_instr_i1_2ucode_d =  (rv0_t1_i0_2ucode_q & rv0_lq_i1_sel[1]) ;
   assign rv1_lq_instr_i1_ucode_cnt_d = (rv0_t0_i1_ucode_cnt_q & {`UCODE_ENTRIES_ENC{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_ucode_cnt_q & {`UCODE_ENTRIES_ENC{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_ucode_cnt_q & {`UCODE_ENTRIES_ENC{rv0_lq_i1_sel[2]}});
   assign rv1_lq_instr_i1_itag_d = (rv0_t0_i1_itag_q & {`ITAG_SIZE_ENC{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_itag_q & {`ITAG_SIZE_ENC{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_itag_q & {`ITAG_SIZE_ENC{rv0_lq_i1_sel[2]}});
   assign rv0_lq_instr_i1_ord  = (rv0_t0_i1_ord_q  & rv0_lq_i1_sel[0]) | ( rv0_t1_i0_ord_q & rv0_lq_i1_sel[1]) | (rv0_t1_i1_ord_q  & rv0_lq_i1_sel[2]);
   assign rv0_lq_instr_i1_cord = (rv0_t0_i1_cord_q & rv0_lq_i1_sel[0]) | (rv0_t1_i0_cord_q & rv0_lq_i1_sel[1]) | (rv0_t1_i1_cord_q & rv0_lq_i1_sel[2]);
   assign rv0_lq_instr_i1_spec = (rv0_t0_i1_spec_q & rv0_lq_i1_sel[0]) | (rv0_t1_i0_spec_q & rv0_lq_i1_sel[1]) | (rv0_t1_i1_spec_q & rv0_lq_i1_sel[2]);

   assign rv0_lq_instr_i1_t1_v = (rv0_t0_i1_t1_v_q & rv0_lq_i1_sel[0]) | (rv0_t1_i0_t1_v_q & rv0_lq_i1_sel[1]) | (rv0_t1_i1_t1_v_q & rv0_lq_i1_sel[2]);
   assign rv0_lq_instr_i1_t1_p = (rv0_t0_i1_t1_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_t1_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_t1_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[2]}});
   assign rv0_lq_instr_i1_t2_v = (rv0_t0_i1_t2_v_q & rv0_lq_i1_sel[0]) | (rv0_t1_i0_t2_v_q & rv0_lq_i1_sel[1]) | (rv0_t1_i1_t2_v_q & rv0_lq_i1_sel[2]);
   assign rv0_lq_instr_i1_t2_p = (rv0_t0_i1_t2_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_t2_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_t2_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[2]}});
   assign rv0_lq_instr_i1_t2_t = (rv0_t0_i1_t2_t_q & {3{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_t2_t_q & {3{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_t2_t_q & {3{rv0_lq_i1_sel[2]}});
   assign rv0_lq_instr_i1_t3_v = (rv0_t0_i1_t3_v_q & rv0_lq_i1_sel[0]) | (rv0_t1_i0_t3_v_q & rv0_lq_i1_sel[1]) | (rv0_t1_i1_t3_v_q & rv0_lq_i1_sel[2]);
   assign rv0_lq_instr_i1_t3_p = (rv0_t0_i1_t3_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_t3_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_t3_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[2]}});
   assign rv0_lq_instr_i1_t3_t = (rv0_t0_i1_t3_t_q & {3{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_t3_t_q & {3{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_t3_t_q & {3{rv0_lq_i1_sel[2]}});

   assign rv0_lq_instr_i1_s1_v = (rv0_t0_i1_s1_v_q & rv0_lq_i1_sel[0]) | (rv0_t1_i0_s1_v_q & rv0_lq_i1_sel[1]) | (rv0_t1_i1_s1_v_q & rv0_lq_i1_sel[2]);
   assign rv0_lq_instr_i1_s1_p = (rv0_t0_i1_s1_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_s1_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_s1_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[2]}});
   assign rv0_lq_instr_i1_s1_t = (rv0_t0_i1_s1_t_q & {3{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_s1_t_q & {3{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_s1_t_q & {3{rv0_lq_i1_sel[2]}});
   assign rv0_lq_instr_i1_s2_v = (rv0_t0_i1_s2_v_q & rv0_lq_i1_sel[0]) | (rv0_t1_i0_s2_v_q & rv0_lq_i1_sel[1]) | (rv0_t1_i1_s2_v_q & rv0_lq_i1_sel[2]);
   assign rv0_lq_instr_i1_s2_p = (rv0_t0_i1_s2_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_s2_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_s2_p_q & {`GPR_POOL_ENC{rv0_lq_i1_sel[2]}});
   assign rv0_lq_instr_i1_s2_t = (rv0_t0_i1_s2_t_q & {3{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_s2_t_q & {3{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_s2_t_q & {3{rv0_lq_i1_sel[2]}});
   assign rv1_lq_instr_i1_s3_t_d = (rv0_t0_i1_s3_t_q & {3{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_s3_t_q & {3{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_s3_t_q & {3{rv0_lq_i1_sel[2]}});

   assign rv1_lq_instr_i1_isLoad_d  = (rv0_t0_i1_isLoad_q  & rv0_lq_i1_sel[0]) | (rv0_t1_i0_isLoad_q  & rv0_lq_i1_sel[1]) | (rv0_t1_i1_isLoad_q  & rv0_lq_i1_sel[2]);
   assign rv1_lq_instr_i1_isStore_d = (rv0_t0_i1_isStore_q & rv0_lq_i1_sel[0]) | (rv0_t1_i0_isStore_q & rv0_lq_i1_sel[1]) | (rv0_t1_i1_isStore_q & rv0_lq_i1_sel[2]);
   assign rv0_lq_instr_i1_spare   = (rv0_t0_i1_spare_q   & {4{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_spare_q   & {4{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_spare_q   & {4{rv0_lq_i1_sel[2]}});
   assign rv0_lq_instr_i1_is_brick = (rv0_t0_i1_is_brick & rv0_lq_i1_sel[0]) | (rv0_t1_i0_is_brick & rv0_lq_i1_sel[1]) | (rv0_t1_i1_is_brick & rv0_lq_i1_sel[2]);
   assign rv0_lq_instr_i1_brick    = (rv0_t0_i1_brick    & {3{rv0_lq_i1_sel[0]}}) | (rv0_t1_i0_brick    & {3{rv0_lq_i1_sel[1]}}) | (rv0_t1_i1_brick    & {3{rv0_lq_i1_sel[2]}});



    //------------------------------------------------------------------------------------------------------------
    // axu0 RV0
    //------------------------------------------------------------------------------------------------------------
   assign rv0_axu0_i0_sel[0] = rv0_t0_i0_rte_axu0_q;
   assign rv0_axu0_i0_sel[1] = rv0_t0_i1_rte_axu0_q & (rv0_t1_i0_rte_axu0_q | rv0_t1_i1_rte_axu0_q);
   assign rv0_axu0_i0_sel[2] = rv0_t1_i0_rte_axu0_q & (~rv0_t0_i0_rte_axu0_q) & (~rv0_t0_i1_rte_axu0_q);
   assign rv0_axu0_i1_sel[0] = rv0_t0_i1_rte_axu0_q & (~rv0_t1_i0_rte_axu0_q) & (~rv0_t1_i1_rte_axu0_q);
   assign rv0_axu0_i1_sel[1] = rv0_t1_i0_rte_axu0_q & (rv0_t0_i0_rte_axu0_q | rv0_t0_i1_rte_axu0_q);
   assign rv0_axu0_i1_sel[2] = rv0_t1_i1_rte_axu0_q;

   assign rv0_axu0_instr_i0_vld = {((rv0_axu0_i0_sel[0] & rv0_t0_i0_vld_q) | (rv0_axu0_i0_sel[1] & rv0_t0_i1_vld_q)), (rv0_axu0_i0_sel[2] & rv0_t1_i0_vld_q)};
   assign rv0_axu0_instr_i1_vld = {(rv0_axu0_i1_sel[0] & rv0_t0_i1_vld_q), ((rv0_axu0_i1_sel[1] & rv0_t1_i0_vld_q) | (rv0_axu0_i1_sel[2] & rv0_t1_i1_vld_q))};

   assign rv0_axu0_instr_i0_rte_axu0 = |(rv0_axu0_i0_sel);

   assign rv0_axu0_instr_i1_rte_axu0 = |(rv0_axu0_i1_sel);

   assign rv0_axu0_instr_i0_s1_dep_hit = (rv0_instr_i0_s1_dep_hit[0] & rv0_axu0_i0_sel[0]) | (rv0_instr_i1_s1_dep_hit_loc[0] & rv0_axu0_i0_sel[1]) | (rv0_instr_i0_s1_dep_hit[1] & rv0_axu0_i0_sel[2]);
   assign rv0_axu0_instr_i0_s2_dep_hit = (rv0_instr_i0_s2_dep_hit[0] & rv0_axu0_i0_sel[0]) | (rv0_instr_i1_s2_dep_hit_loc[0] & rv0_axu0_i0_sel[1]) | (rv0_instr_i0_s2_dep_hit[1] & rv0_axu0_i0_sel[2]);
   assign rv0_axu0_instr_i0_s3_dep_hit = (rv0_instr_i0_s3_dep_hit[0] & rv0_axu0_i0_sel[0]) | (rv0_instr_i1_s3_dep_hit_loc[0] & rv0_axu0_i0_sel[1]) | (rv0_instr_i0_s3_dep_hit[1] & rv0_axu0_i0_sel[2]);

   assign rv0_axu0_instr_i0_s1_itag = (rv0_t0_i0_s1_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i0_sel[0]}}) | (rv0_instr_i1_s1_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_axu0_i0_sel[1]}}) | (rv0_t1_i0_s1_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i0_sel[2]}});
   assign rv0_axu0_instr_i0_s2_itag = (rv0_t0_i0_s2_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i0_sel[0]}}) | (rv0_instr_i1_s2_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_axu0_i0_sel[1]}}) | (rv0_t1_i0_s2_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i0_sel[2]}});
   assign rv0_axu0_instr_i0_s3_itag = (rv0_t0_i0_s3_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i0_sel[0]}}) | (rv0_instr_i1_s3_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_axu0_i0_sel[1]}}) | (rv0_t1_i0_s3_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i0_sel[2]}});

   assign rv0_axu0_instr_i1_s1_dep_hit = (rv0_instr_i1_s1_dep_hit_loc[0] & rv0_axu0_i1_sel[0]) | (rv0_instr_i0_s1_dep_hit[1] & rv0_axu0_i1_sel[1]) | (rv0_instr_i1_s1_dep_hit_loc[1] & rv0_axu0_i1_sel[2]);
   assign rv0_axu0_instr_i1_s2_dep_hit = (rv0_instr_i1_s2_dep_hit_loc[0] & rv0_axu0_i1_sel[0]) | (rv0_instr_i0_s2_dep_hit[1] & rv0_axu0_i1_sel[1]) | (rv0_instr_i1_s2_dep_hit_loc[1] & rv0_axu0_i1_sel[2]);
   assign rv0_axu0_instr_i1_s3_dep_hit = (rv0_instr_i1_s3_dep_hit_loc[0] & rv0_axu0_i1_sel[0]) | (rv0_instr_i0_s3_dep_hit[1] & rv0_axu0_i1_sel[1]) | (rv0_instr_i1_s3_dep_hit_loc[1] & rv0_axu0_i1_sel[2]);
   assign rv0_axu0_instr_i1_s1_itag = (rv0_instr_i1_s1_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_axu0_i1_sel[0]}}) | (rv0_t1_i0_s1_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i1_sel[1]}}) | (rv0_instr_i1_s1_itag_loc[1] & {`ITAG_SIZE_ENC{rv0_axu0_i1_sel[2]}});
   assign rv0_axu0_instr_i1_s2_itag = (rv0_instr_i1_s2_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_axu0_i1_sel[0]}}) | (rv0_t1_i0_s2_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i1_sel[1]}}) | (rv0_instr_i1_s2_itag_loc[1] & {`ITAG_SIZE_ENC{rv0_axu0_i1_sel[2]}});
   assign rv0_axu0_instr_i1_s3_itag = (rv0_instr_i1_s3_itag_loc[0] & {`ITAG_SIZE_ENC{rv0_axu0_i1_sel[0]}}) | (rv0_t1_i0_s3_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i1_sel[1]}}) | (rv0_instr_i1_s3_itag_loc[1] & {`ITAG_SIZE_ENC{rv0_axu0_i1_sel[2]}});

   //------------------------------------------------------------------------------------------------------------
   // AXU0 RV1
   //------------------------------------------------------------------------------------------------------------

   assign rv0_axu0_instr_i0_instr = (rv0_t0_i0_instr_q & {32{rv0_axu0_i0_sel[0]}}) | (rv0_t0_i1_instr_q & {32{rv0_axu0_i0_sel[1]}}) | (rv0_t1_i0_instr_q & {32{rv0_axu0_i0_sel[2]}});
   assign rv0_axu0_instr_i0_ucode = (rv0_t0_i0_ucode_q & {3{rv0_axu0_i0_sel[0]}}) | (rv0_t0_i1_ucode_q & {3{rv0_axu0_i0_sel[1]}}) | (rv0_t1_i0_ucode_q & {3{rv0_axu0_i0_sel[2]}});
   assign rv0_axu0_instr_i0_itag = (rv0_t0_i0_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i0_sel[0]}}) | (rv0_t0_i1_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i0_sel[1]}}) | (rv0_t1_i0_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i0_sel[2]}});
   assign rv0_axu0_instr_i0_ord  = (rv0_t0_i0_ord_q  & rv0_axu0_i0_sel[0]) | ( rv0_t0_i1_ord_q & rv0_axu0_i0_sel[1]) | (rv0_t1_i0_ord_q  & rv0_axu0_i0_sel[2]);
   assign rv0_axu0_instr_i0_cord = (rv0_t0_i0_cord_q & rv0_axu0_i0_sel[0]) | (rv0_t0_i1_cord_q & rv0_axu0_i0_sel[1]) | (rv0_t1_i0_cord_q & rv0_axu0_i0_sel[2]);
   assign rv0_axu0_instr_i0_isStore = (rv0_t0_i0_isStore_q & rv0_axu0_i0_sel[0]) | (rv0_t0_i1_isStore_q & rv0_axu0_i0_sel[1]) | (rv0_t1_i0_isStore_q & rv0_axu0_i0_sel[2]);

   assign rv0_axu0_instr_i0_t1_v = (rv0_t0_i0_t1_v_q & rv0_axu0_i0_sel[0]) | (rv0_t0_i1_t1_v_q & rv0_axu0_i0_sel[1]) | (rv0_t1_i0_t1_v_q & rv0_axu0_i0_sel[2]);
   assign rv0_axu0_instr_i0_t1_p = (rv0_t0_i0_t1_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[0]}}) | (rv0_t0_i1_t1_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[1]}}) | (rv0_t1_i0_t1_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[2]}});
   assign rv0_axu0_instr_i0_t2_p = (rv0_t0_i0_t2_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[0]}}) | (rv0_t0_i1_t2_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[1]}}) | (rv0_t1_i0_t2_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[2]}});
   assign rv0_axu0_instr_i0_t3_p = (rv0_t0_i0_t3_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[0]}}) | (rv0_t0_i1_t3_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[1]}}) | (rv0_t1_i0_t3_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[2]}});

   assign rv0_axu0_instr_i0_s1_v = (rv0_t0_i0_s1_v_q & rv0_axu0_i0_sel[0]) | (rv0_t0_i1_s1_v_q & rv0_axu0_i0_sel[1]) | (rv0_t1_i0_s1_v_q & rv0_axu0_i0_sel[2]);
   assign rv0_axu0_instr_i0_s1_p = (rv0_t0_i0_s1_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[0]}}) | (rv0_t0_i1_s1_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[1]}}) | (rv0_t1_i0_s1_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[2]}});
   assign rv0_axu0_instr_i0_s2_v = (rv0_t0_i0_s2_v_q & rv0_axu0_i0_sel[0]) | (rv0_t0_i1_s2_v_q & rv0_axu0_i0_sel[1]) | (rv0_t1_i0_s2_v_q & rv0_axu0_i0_sel[2]);
   assign rv0_axu0_instr_i0_s2_p = (rv0_t0_i0_s2_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[0]}}) | (rv0_t0_i1_s2_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[1]}}) | (rv0_t1_i0_s2_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[2]}});
   assign rv0_axu0_instr_i0_s3_v = (rv0_t0_i0_s3_v_q & rv0_axu0_i0_sel[0]) | (rv0_t0_i1_s3_v_q & rv0_axu0_i0_sel[1]) | (rv0_t1_i0_s3_v_q & rv0_axu0_i0_sel[2]);
   assign rv0_axu0_instr_i0_s3_p = (rv0_t0_i0_s3_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[0]}}) | (rv0_t0_i1_s3_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[1]}}) | (rv0_t1_i0_s3_p_q & {`GPR_POOL_ENC{rv0_axu0_i0_sel[2]}});

   assign rv0_axu0_instr_i0_spare   = (rv0_t0_i0_spare_q   & {4{rv0_axu0_i0_sel[0]}}) | (rv0_t0_i1_spare_q   & {4{rv0_axu0_i0_sel[1]}}) | (rv0_t1_i0_spare_q   & {4{rv0_axu0_i0_sel[2]}});


   assign rv0_axu0_instr_i1_instr = (rv0_t0_i1_instr_q & {32{rv0_axu0_i1_sel[0]}}) | (rv0_t1_i0_instr_q & {32{rv0_axu0_i1_sel[1]}}) | (rv0_t1_i1_instr_q & {32{rv0_axu0_i1_sel[2]}});
   assign rv0_axu0_instr_i1_ucode = (rv0_t0_i1_ucode_q & {3{rv0_axu0_i1_sel[0]}}) | (rv0_t1_i0_ucode_q & {3{rv0_axu0_i1_sel[1]}}) | (rv0_t1_i1_ucode_q & {3{rv0_axu0_i1_sel[2]}});
   assign rv0_axu0_instr_i1_itag = (rv0_t0_i1_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i1_sel[0]}}) | (rv0_t1_i0_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i1_sel[1]}}) | (rv0_t1_i1_itag_q & {`ITAG_SIZE_ENC{rv0_axu0_i1_sel[2]}});
   assign rv0_axu0_instr_i1_ord  = (rv0_t0_i1_ord_q  & rv0_axu0_i1_sel[0]) | ( rv0_t1_i0_ord_q & rv0_axu0_i1_sel[1]) | (rv0_t1_i1_ord_q  & rv0_axu0_i1_sel[2]);
   assign rv0_axu0_instr_i1_cord = (rv0_t0_i1_cord_q & rv0_axu0_i1_sel[0]) | (rv0_t1_i0_cord_q & rv0_axu0_i1_sel[1]) | (rv0_t1_i1_cord_q & rv0_axu0_i1_sel[2]);
   assign rv0_axu0_instr_i1_isStore = (rv0_t0_i1_isStore_q & rv0_axu0_i1_sel[0]) | (rv0_t1_i0_isStore_q & rv0_axu0_i1_sel[1]) | (rv0_t1_i1_isStore_q & rv0_axu0_i1_sel[2]);

   assign rv0_axu0_instr_i1_t1_v = (rv0_t0_i1_t1_v_q & rv0_axu0_i1_sel[0]) | (rv0_t1_i0_t1_v_q & rv0_axu0_i1_sel[1]) | (rv0_t1_i1_t1_v_q & rv0_axu0_i1_sel[2]);
   assign rv0_axu0_instr_i1_t1_p = (rv0_t0_i1_t1_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[0]}}) | (rv0_t1_i0_t1_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[1]}}) | (rv0_t1_i1_t1_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[2]}});
   assign rv0_axu0_instr_i1_t2_p = (rv0_t0_i1_t2_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[0]}}) | (rv0_t1_i0_t2_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[1]}}) | (rv0_t1_i1_t2_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[2]}});
   assign rv0_axu0_instr_i1_t3_p = (rv0_t0_i1_t3_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[0]}}) | (rv0_t1_i0_t3_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[1]}}) | (rv0_t1_i1_t3_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[2]}});

   assign rv0_axu0_instr_i1_s1_v = (rv0_t0_i1_s1_v_q & rv0_axu0_i1_sel[0]) | (rv0_t1_i0_s1_v_q & rv0_axu0_i1_sel[1]) | (rv0_t1_i1_s1_v_q & rv0_axu0_i1_sel[2]);
   assign rv0_axu0_instr_i1_s1_p = (rv0_t0_i1_s1_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[0]}}) | (rv0_t1_i0_s1_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[1]}}) | (rv0_t1_i1_s1_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[2]}});
   assign rv0_axu0_instr_i1_s2_v = (rv0_t0_i1_s2_v_q & rv0_axu0_i1_sel[0]) | (rv0_t1_i0_s2_v_q & rv0_axu0_i1_sel[1]) | (rv0_t1_i1_s2_v_q & rv0_axu0_i1_sel[2]);
   assign rv0_axu0_instr_i1_s2_p = (rv0_t0_i1_s2_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[0]}}) | (rv0_t1_i0_s2_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[1]}}) | (rv0_t1_i1_s2_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[2]}});
   assign rv0_axu0_instr_i1_s3_v = (rv0_t0_i1_s3_v_q & rv0_axu0_i1_sel[0]) | (rv0_t1_i0_s3_v_q & rv0_axu0_i1_sel[1]) | (rv0_t1_i1_s3_v_q & rv0_axu0_i1_sel[2]);
   assign rv0_axu0_instr_i1_s3_p = (rv0_t0_i1_s3_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[0]}}) | (rv0_t1_i0_s3_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[1]}}) | (rv0_t1_i1_s3_p_q & {`GPR_POOL_ENC{rv0_axu0_i1_sel[2]}});

   assign rv0_axu0_instr_i1_spare   = (rv0_t0_i1_spare_q   & {4{rv0_axu0_i1_sel[0]}}) | (rv0_t1_i0_spare_q   & {4{rv0_axu0_i1_sel[1]}}) | (rv0_t1_i1_spare_q   & {4{rv0_axu0_i1_sel[2]}});


`endif //  `ifndef THREADS1



   //------------------------------------------------------------------------------------------------------------
   // Dep Hit Outputs
   //------------------------------------------------------------------------------------------------------------


   //------------------------------------------------------------------------------------------------------------
   // LQ RV1 outputs for sq
   //------------------------------------------------------------------------------------------------------------

   assign rv0_lq_instr_i0_ucode = rv1_lq_instr_i0_ucode_d;
   assign rv0_lq_instr_i0_ucode_cnt = rv1_lq_instr_i0_ucode_cnt_d;
   assign rv0_lq_instr_i0_itag = rv1_lq_instr_i0_itag_d;
   assign rv0_lq_instr_i0_isLoad = rv1_lq_instr_i0_isLoad_d;

   assign rv0_lq_instr_i1_ucode = rv1_lq_instr_i1_ucode_d;
   assign rv0_lq_instr_i1_ucode_cnt = rv1_lq_instr_i1_ucode_cnt_d;
   assign rv0_lq_instr_i1_itag = rv1_lq_instr_i1_itag_d;
   assign rv0_lq_instr_i1_isLoad = rv1_lq_instr_i1_isLoad_d;

   assign rv1_lq_instr_i0_ucode_preissue_d = rv1_lq_instr_i0_ucode_d[1];
   assign rv1_lq_instr_i0_ifar_d           = rv0_lq_instr_i0_ifar;

   assign rv_lq_rv1_i0_vld                 = rv1_lq_instr_i0_vld_q;
   assign rv_lq_rv1_i0_rte_lq              = rv1_lq_instr_i0_rte_lq_q;
   assign rv_lq_rv1_i0_rte_sq              = rv1_lq_instr_i0_rte_sq_q;
   assign rv_lq_rv1_i0_ucode_preissue      = rv1_lq_instr_i0_ucode_preissue_q;
   assign rv_lq_rv1_i0_2ucode              = rv1_lq_instr_i0_2ucode_q;
   assign rv_lq_rv1_i0_ucode_cnt           = rv1_lq_instr_i0_ucode_cnt_q;
   assign rv_lq_rv1_i0_s3_t                = rv1_lq_instr_i0_s3_t_q;
   assign rv_lq_rv1_i0_isLoad              = rv1_lq_instr_i0_isLoad_q;
   assign rv_lq_rv1_i0_isStore             = rv1_lq_instr_i0_isStore_q;
   assign rv_lq_rv1_i0_itag                = rv1_lq_instr_i0_itag_q;
   assign rv_lq_rv1_i0_ifar                = rv1_lq_instr_i0_ifar_q;

   assign rv1_lq_instr_i1_ucode_preissue_d = rv1_lq_instr_i1_ucode_d[1];
   assign rv1_lq_instr_i1_ifar_d           = rv0_lq_instr_i1_ifar;

   assign rv_lq_rv1_i1_vld                 = rv1_lq_instr_i1_vld_q;
   assign rv_lq_rv1_i1_rte_lq              = rv1_lq_instr_i1_rte_lq_q;
   assign rv_lq_rv1_i1_rte_sq              = rv1_lq_instr_i1_rte_sq_q;
   assign rv_lq_rv1_i1_ucode_preissue      = rv1_lq_instr_i1_ucode_preissue_q;
   assign rv_lq_rv1_i1_2ucode              = rv1_lq_instr_i1_2ucode_q;
   assign rv_lq_rv1_i1_ucode_cnt           = rv1_lq_instr_i1_ucode_cnt_q;
   assign rv_lq_rv1_i1_s3_t                = rv1_lq_instr_i1_s3_t_q;
   assign rv_lq_rv1_i1_isLoad              = rv1_lq_instr_i1_isLoad_q;
   assign rv_lq_rv1_i1_isStore             = rv1_lq_instr_i1_isStore_q;
   assign rv_lq_rv1_i1_itag                = rv1_lq_instr_i1_itag_q;
   assign rv_lq_rv1_i1_ifar                = rv1_lq_instr_i1_ifar_q;







   //------------------------------------------------------------------------------------------------------------
   // Storage Elements RV0
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
							  .scin(siv[cp_flush_offset:cp_flush_offset + `THREADS-1]),
							  .scout(sov[cp_flush_offset:cp_flush_offset + `THREADS-1]),
							  .din(cp_flush),
							  .dout(iu_xx_zap)
							  );

   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_vld_reg(
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
							       .scin(siv[rv0_t0_i0_vld_offset]),
							       .scout(sov[rv0_t0_i0_vld_offset]),
							       .din(rv0_t0_i0_vld_d),
							       .dout(rv0_t0_i0_vld_q)
							       );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_rte_lq_q_reg(
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
						     .scin(siv[rv0_t0_i0_rte_lq_offset ]),
						     .scout(sov[rv0_t0_i0_rte_lq_offset ]),
						     .din(rv0_t0_i0_rte_lq_d),
						     .dout(rv0_t0_i0_rte_lq_q)
						     );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_rte_sq_q_reg(
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
						     .scin(siv[rv0_t0_i0_rte_sq_offset ]),
						     .scout(sov[rv0_t0_i0_rte_sq_offset ]),
						     .din(rv0_t0_i0_rte_sq_d),
						     .dout(rv0_t0_i0_rte_sq_q)
						     );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_rte_fx0_q_reg(
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
						      .scin(siv[rv0_t0_i0_rte_fx0_offset ]),
						      .scout(sov[rv0_t0_i0_rte_fx0_offset ]),
						      .din(rv0_t0_i0_rte_fx0_d),
						      .dout(rv0_t0_i0_rte_fx0_q)
						      );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_rte_fx1_q_reg(
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
						      .scin(siv[rv0_t0_i0_rte_fx1_offset ]),
						      .scout(sov[rv0_t0_i0_rte_fx1_offset ]),
						      .din(rv0_t0_i0_rte_fx1_d),
						      .dout(rv0_t0_i0_rte_fx1_q)
						      );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_rte_axu0_q_reg(
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
						       .scin(siv[rv0_t0_i0_rte_axu0_offset ]),
						       .scout(sov[rv0_t0_i0_rte_axu0_offset ]),
						       .din(rv0_t0_i0_rte_axu0_d),
						       .dout(rv0_t0_i0_rte_axu0_q)
						       );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_rte_axu1_q_reg(
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
						       .scin(siv[rv0_t0_i0_rte_axu1_offset ]),
						       .scout(sov[rv0_t0_i0_rte_axu1_offset ]),
						       .din(rv0_t0_i0_rte_axu1_d),
						       .dout(rv0_t0_i0_rte_axu1_q)
						       );


   tri_rlmreg_p #(.WIDTH(32), .INIT(0)) rv0_t0_i0_instr_q_reg(
							      .vd(vdd),
							      .gd(gnd),
							      .nclk(nclk),
							      .act(iu6_t0_i0_act),
							      .thold_b(func_sl_thold_0_b),
							      .sg(sg_0),
							      .force_t(force_t),
							      .delay_lclkr(delay_lclkr),
							      .mpw1_b(mpw1_b),
							      .mpw2_b(mpw2_b),
							      .d_mode(d_mode),
							      .scin(siv[rv0_t0_i0_instr_offset :rv0_t0_i0_instr_offset + 31 ]),
							      .scout(sov[rv0_t0_i0_instr_offset :rv0_t0_i0_instr_offset + 31 ]),
							      .din(rv0_t0_i0_instr_d),
							      .dout(rv0_t0_i0_instr_q)
							      );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) rv0_t0_i0_ifar_q_reg(
									 .vd(vdd),
									 .gd(gnd),
									 .nclk(nclk),
									 .act(iu6_t0_i0_act),
									 .thold_b(func_sl_thold_0_b),
									 .sg(sg_0),
									 .force_t(force_t),
									 .delay_lclkr(delay_lclkr),
									 .mpw1_b(mpw1_b),
									 .mpw2_b(mpw2_b),
									 .d_mode(d_mode),
									 .scin(siv[rv0_t0_i0_ifar_offset :rv0_t0_i0_ifar_offset + `EFF_IFAR_WIDTH - 1 ]),
									 .scout(sov[rv0_t0_i0_ifar_offset :rv0_t0_i0_ifar_offset + `EFF_IFAR_WIDTH - 1 ]),
									 .din(rv0_t0_i0_ifar_d),
									 .dout(rv0_t0_i0_ifar_q)
									 );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t0_i0_ucode_q_reg(
							     .vd(vdd),
							     .gd(gnd),
							     .nclk(nclk),
							     .act(iu6_t0_i0_act),
							     .thold_b(func_sl_thold_0_b),
							     .sg(sg_0),
							     .force_t(force_t),
							     .delay_lclkr(delay_lclkr),
							     .mpw1_b(mpw1_b),
							     .mpw2_b(mpw2_b),
							     .d_mode(d_mode),
							     .scin(siv[rv0_t0_i0_ucode_offset :rv0_t0_i0_ucode_offset + 3 - 1 ]),
							     .scout(sov[rv0_t0_i0_ucode_offset :rv0_t0_i0_ucode_offset + 3 - 1 ]),
							     .din(rv0_t0_i0_ucode_d),
							     .dout(rv0_t0_i0_ucode_q)
							     );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_2ucode_q_reg(
						     .vd(vdd),
						     .gd(gnd),
						     .nclk(nclk),
						     .act(iu6_t0_i0_act),
						     .thold_b(func_sl_thold_0_b),
						     .sg(sg_0),
						     .force_t(force_t),
						     .delay_lclkr(delay_lclkr),
						     .mpw1_b(mpw1_b),
						     .mpw2_b(mpw2_b),
						     .d_mode(d_mode),
						     .scin(siv[rv0_t0_i0_2ucode_offset ]),
						     .scout(sov[rv0_t0_i0_2ucode_offset ]),
						     .din(rv0_t0_i0_2ucode_d),
						     .dout(rv0_t0_i0_2ucode_q)
						     );


   tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0)) rv0_t0_i0_ucode_cnt_q_reg(
										 .vd(vdd),
										 .gd(gnd),
										 .nclk(nclk),
										 .act(iu6_t0_i0_act),
										 .thold_b(func_sl_thold_0_b),
										 .sg(sg_0),
										 .force_t(force_t),
										 .delay_lclkr(delay_lclkr),
										 .mpw1_b(mpw1_b),
										 .mpw2_b(mpw2_b),
										 .d_mode(d_mode),
										 .scin(siv[rv0_t0_i0_ucode_cnt_offset :rv0_t0_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1 ]),
										 .scout(sov[rv0_t0_i0_ucode_cnt_offset :rv0_t0_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1 ]),
										 .din(rv0_t0_i0_ucode_cnt_d),
										 .dout(rv0_t0_i0_ucode_cnt_q)
										 );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) rv0_t0_i0_itag_q_reg(
									.vd(vdd),
									.gd(gnd),
									.nclk(nclk),
									.act(iu6_t0_i0_act),
									.thold_b(func_sl_thold_0_b),
									.sg(sg_0),
									.force_t(force_t),
									.delay_lclkr(delay_lclkr),
									.mpw1_b(mpw1_b),
									.mpw2_b(mpw2_b),
									.d_mode(d_mode),
									.scin(siv[rv0_t0_i0_itag_offset :rv0_t0_i0_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									.scout(sov[rv0_t0_i0_itag_offset :rv0_t0_i0_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									.din(rv0_t0_i0_itag_d),
									.dout(rv0_t0_i0_itag_q)
									);


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_ord_q_reg(
						  .vd(vdd),
						  .gd(gnd),
						  .nclk(nclk),
						  .act(iu6_t0_i0_act),
						  .thold_b(func_sl_thold_0_b),
						  .sg(sg_0),
						  .force_t(force_t),
						  .delay_lclkr(delay_lclkr),
						  .mpw1_b(mpw1_b),
						  .mpw2_b(mpw2_b),
						  .d_mode(d_mode),
						  .scin(siv[rv0_t0_i0_ord_offset ]),
						  .scout(sov[rv0_t0_i0_ord_offset ]),
						  .din(rv0_t0_i0_ord_d),
						  .dout(rv0_t0_i0_ord_q)
						  );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_cord_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i0_cord_offset ]),
						   .scout(sov[rv0_t0_i0_cord_offset ]),
						   .din(rv0_t0_i0_cord_d),
						   .dout(rv0_t0_i0_cord_q)
						   );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_spec_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i0_spec_offset ]),
						   .scout(sov[rv0_t0_i0_spec_offset ]),
						   .din(rv0_t0_i0_spec_d),
						   .dout(rv0_t0_i0_spec_q)
						   );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_t1_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i0_t1_v_offset ]),
						   .scout(sov[rv0_t0_i0_t1_v_offset ]),
						   .din(rv0_t0_i0_t1_v_d),
						   .dout(rv0_t0_i0_t1_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t0_i0_t1_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t0_i0_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t0_i0_t1_p_offset :rv0_t0_i0_t1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t0_i0_t1_p_offset :rv0_t0_i0_t1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t0_i0_t1_p_d),
								       .dout(rv0_t0_i0_t1_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t0_i0_t1_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t0_i0_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t0_i0_t1_t_offset :rv0_t0_i0_t1_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t0_i0_t1_t_offset :rv0_t0_i0_t1_t_offset + 3 - 1 ]),
							    .din(rv0_t0_i0_t1_t_d),
							    .dout(rv0_t0_i0_t1_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_t2_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i0_t2_v_offset ]),
						   .scout(sov[rv0_t0_i0_t2_v_offset ]),
						   .din(rv0_t0_i0_t2_v_d),
						   .dout(rv0_t0_i0_t2_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t0_i0_t2_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t0_i0_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t0_i0_t2_p_offset :rv0_t0_i0_t2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t0_i0_t2_p_offset :rv0_t0_i0_t2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t0_i0_t2_p_d),
								       .dout(rv0_t0_i0_t2_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t0_i0_t2_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t0_i0_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t0_i0_t2_t_offset :rv0_t0_i0_t2_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t0_i0_t2_t_offset :rv0_t0_i0_t2_t_offset + 3 - 1 ]),
							    .din(rv0_t0_i0_t2_t_d),
							    .dout(rv0_t0_i0_t2_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_t3_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i0_t3_v_offset ]),
						   .scout(sov[rv0_t0_i0_t3_v_offset ]),
						   .din(rv0_t0_i0_t3_v_d),
						   .dout(rv0_t0_i0_t3_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t0_i0_t3_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t0_i0_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t0_i0_t3_p_offset :rv0_t0_i0_t3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t0_i0_t3_p_offset :rv0_t0_i0_t3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t0_i0_t3_p_d),
								       .dout(rv0_t0_i0_t3_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t0_i0_t3_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t0_i0_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t0_i0_t3_t_offset :rv0_t0_i0_t3_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t0_i0_t3_t_offset :rv0_t0_i0_t3_t_offset + 3 - 1 ]),
							    .din(rv0_t0_i0_t3_t_d),
							    .dout(rv0_t0_i0_t3_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_s1_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i0_s1_v_offset ]),
						   .scout(sov[rv0_t0_i0_s1_v_offset ]),
						   .din(rv0_t0_i0_s1_v_d),
						   .dout(rv0_t0_i0_s1_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t0_i0_s1_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t0_i0_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t0_i0_s1_p_offset :rv0_t0_i0_s1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t0_i0_s1_p_offset :rv0_t0_i0_s1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t0_i0_s1_p_d),
								       .dout(rv0_t0_i0_s1_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t0_i0_s1_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t0_i0_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t0_i0_s1_t_offset :rv0_t0_i0_s1_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t0_i0_s1_t_offset :rv0_t0_i0_s1_t_offset + 3 - 1 ]),
							    .din(rv0_t0_i0_s1_t_d),
							    .dout(rv0_t0_i0_s1_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_s2_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i0_s2_v_offset ]),
						   .scout(sov[rv0_t0_i0_s2_v_offset ]),
						   .din(rv0_t0_i0_s2_v_d),
						   .dout(rv0_t0_i0_s2_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t0_i0_s2_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t0_i0_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t0_i0_s2_p_offset :rv0_t0_i0_s2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t0_i0_s2_p_offset :rv0_t0_i0_s2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t0_i0_s2_p_d),
								       .dout(rv0_t0_i0_s2_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t0_i0_s2_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t0_i0_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t0_i0_s2_t_offset :rv0_t0_i0_s2_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t0_i0_s2_t_offset :rv0_t0_i0_s2_t_offset + 3 - 1 ]),
							    .din(rv0_t0_i0_s2_t_d),
							    .dout(rv0_t0_i0_s2_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_s3_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i0_s3_v_offset ]),
						   .scout(sov[rv0_t0_i0_s3_v_offset ]),
						   .din(rv0_t0_i0_s3_v_d),
						   .dout(rv0_t0_i0_s3_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t0_i0_s3_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t0_i0_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t0_i0_s3_p_offset :rv0_t0_i0_s3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t0_i0_s3_p_offset :rv0_t0_i0_s3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t0_i0_s3_p_d),
								       .dout(rv0_t0_i0_s3_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t0_i0_s3_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t0_i0_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t0_i0_s3_t_offset :rv0_t0_i0_s3_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t0_i0_s3_t_offset :rv0_t0_i0_s3_t_offset + 3 - 1 ]),
							    .din(rv0_t0_i0_s3_t_d),
							    .dout(rv0_t0_i0_s3_t_q)
							    );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) rv0_t0_i0_s1_itag_q_reg(
									   .vd(vdd),
									   .gd(gnd),
									   .nclk(nclk),
									   .act(iu6_t0_i0_act),
									   .thold_b(func_sl_thold_0_b),
									   .sg(sg_0),
									   .force_t(force_t),
									   .delay_lclkr(delay_lclkr),
									   .mpw1_b(mpw1_b),
									   .mpw2_b(mpw2_b),
									   .d_mode(d_mode),
									   .scin(siv[rv0_t0_i0_s1_itag_offset :rv0_t0_i0_s1_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .scout(sov[rv0_t0_i0_s1_itag_offset :rv0_t0_i0_s1_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .din(rv0_t0_i0_s1_itag_d),
									   .dout(rv0_t0_i0_s1_itag_q)
									   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) rv0_t0_i0_s2_itag_q_reg(
									   .vd(vdd),
									   .gd(gnd),
									   .nclk(nclk),
									   .act(iu6_t0_i0_act),
									   .thold_b(func_sl_thold_0_b),
									   .sg(sg_0),
									   .force_t(force_t),
									   .delay_lclkr(delay_lclkr),
									   .mpw1_b(mpw1_b),
									   .mpw2_b(mpw2_b),
									   .d_mode(d_mode),
									   .scin(siv[rv0_t0_i0_s2_itag_offset :rv0_t0_i0_s2_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .scout(sov[rv0_t0_i0_s2_itag_offset :rv0_t0_i0_s2_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .din(rv0_t0_i0_s2_itag_d),
									   .dout(rv0_t0_i0_s2_itag_q)
									   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) rv0_t0_i0_s3_itag_q_reg(
									   .vd(vdd),
									   .gd(gnd),
									   .nclk(nclk),
									   .act(iu6_t0_i0_act),
									   .thold_b(func_sl_thold_0_b),
									   .sg(sg_0),
									   .force_t(force_t),
									   .delay_lclkr(delay_lclkr),
									   .mpw1_b(mpw1_b),
									   .mpw2_b(mpw2_b),
									   .d_mode(d_mode),
									   .scin(siv[rv0_t0_i0_s3_itag_offset :rv0_t0_i0_s3_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .scout(sov[rv0_t0_i0_s3_itag_offset :rv0_t0_i0_s3_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .din(rv0_t0_i0_s3_itag_d),
									   .dout(rv0_t0_i0_s3_itag_q)
									   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) rv0_t0_i0_ilat_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t0_i0_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t0_i0_ilat_offset :rv0_t0_i0_ilat_offset + 4 - 1 ]),
							    .scout(sov[rv0_t0_i0_ilat_offset :rv0_t0_i0_ilat_offset + 4 - 1 ]),
							    .din(rv0_t0_i0_ilat_d),
							    .dout(rv0_t0_i0_ilat_q)
							    );


   tri_rlmreg_p #(.WIDTH(`G_BRANCH_LEN), .INIT(0)) rv0_t0_i0_branch_q_reg(
									 .vd(vdd),
									 .gd(gnd),
									 .nclk(nclk),
									 .act(iu6_t0_i0_act),
									 .thold_b(func_sl_thold_0_b),
									 .sg(sg_0),
									 .force_t(force_t),
									 .delay_lclkr(delay_lclkr),
									 .mpw1_b(mpw1_b),
									 .mpw2_b(mpw2_b),
									 .d_mode(d_mode),
									 .scin(siv[rv0_t0_i0_branch_offset :rv0_t0_i0_branch_offset + `G_BRANCH_LEN - 1 ]),
									 .scout(sov[rv0_t0_i0_branch_offset :rv0_t0_i0_branch_offset + `G_BRANCH_LEN - 1 ]),
									 .din(rv0_t0_i0_branch_d),
									 .dout(rv0_t0_i0_branch_q)
									 );

   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_isLoad_q_reg(
						     .vd(vdd),
						     .gd(gnd),
						     .nclk(nclk),
						     .act(iu6_t0_i0_act),
						     .thold_b(func_sl_thold_0_b),
						     .sg(sg_0),
						     .force_t(force_t),
						     .delay_lclkr(delay_lclkr),
						     .mpw1_b(mpw1_b),
						     .mpw2_b(mpw2_b),
						     .d_mode(d_mode),
						     .scin(siv[rv0_t0_i0_isLoad_offset ]),
						     .scout(sov[rv0_t0_i0_isLoad_offset ]),
						     .din(rv0_t0_i0_isLoad_d),
						     .dout(rv0_t0_i0_isLoad_q)
						     );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i0_isStore_q_reg(
						      .vd(vdd),
						      .gd(gnd),
						      .nclk(nclk),
						      .act(iu6_t0_i0_act),
						      .thold_b(func_sl_thold_0_b),
						      .sg(sg_0),
						      .force_t(force_t),
						      .delay_lclkr(delay_lclkr),
						      .mpw1_b(mpw1_b),
						      .mpw2_b(mpw2_b),
						      .d_mode(d_mode),
						      .scin(siv[rv0_t0_i0_isStore_offset ]),
						      .scout(sov[rv0_t0_i0_isStore_offset ]),
						      .din(rv0_t0_i0_isStore_d),
						      .dout(rv0_t0_i0_isStore_q)
						      );

   assign rv0_t0_i0_spare_d = 4'b0000;


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) rv0_t0_i0_spare_q_reg(
							     .vd(vdd),
							     .gd(gnd),
							     .nclk(nclk),
							     .act(iu6_t0_i0_act),
							     .thold_b(func_sl_thold_0_b),
							     .sg(sg_0),
							     .force_t(force_t),
							     .delay_lclkr(delay_lclkr),
							     .mpw1_b(mpw1_b),
							     .mpw2_b(mpw2_b),
							     .d_mode(d_mode),
							     .scin(siv[rv0_t0_i0_spare_offset :rv0_t0_i0_spare_offset + 4 - 1 ]),
							     .scout(sov[rv0_t0_i0_spare_offset :rv0_t0_i0_spare_offset + 4 - 1 ]),
							     .din(rv0_t0_i0_spare_d),
							     .dout(rv0_t0_i0_spare_q)
							     );

   //t0_i1
   tri_rlmlatch_p #( .INIT(0)) rv0_t0_i1_vld_reg(
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
							       .scin(siv[rv0_t0_i1_vld_offset]),
							       .scout(sov[rv0_t0_i1_vld_offset]),
							       .din(rv0_t0_i1_vld_d),
							       .dout(rv0_t0_i1_vld_q)
							       );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_rte_lq_q_reg(
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
						     .scin(siv[rv0_t0_i1_rte_lq_offset ]),
						     .scout(sov[rv0_t0_i1_rte_lq_offset ]),
						     .din(rv0_t0_i1_rte_lq_d),
						     .dout(rv0_t0_i1_rte_lq_q)
						     );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_rte_sq_q_reg(
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
						     .scin(siv[rv0_t0_i1_rte_sq_offset ]),
						     .scout(sov[rv0_t0_i1_rte_sq_offset ]),
						     .din(rv0_t0_i1_rte_sq_d),
						     .dout(rv0_t0_i1_rte_sq_q)
						     );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_rte_fx0_q_reg(
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
						      .scin(siv[rv0_t0_i1_rte_fx0_offset ]),
						      .scout(sov[rv0_t0_i1_rte_fx0_offset ]),
						      .din(rv0_t0_i1_rte_fx0_d),
						      .dout(rv0_t0_i1_rte_fx0_q)
						      );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_rte_fx1_q_reg(
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
						      .scin(siv[rv0_t0_i1_rte_fx1_offset ]),
						      .scout(sov[rv0_t0_i1_rte_fx1_offset ]),
						      .din(rv0_t0_i1_rte_fx1_d),
						      .dout(rv0_t0_i1_rte_fx1_q)
						      );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_rte_axu0_q_reg(
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
						       .scin(siv[rv0_t0_i1_rte_axu0_offset ]),
						       .scout(sov[rv0_t0_i1_rte_axu0_offset ]),
						       .din(rv0_t0_i1_rte_axu0_d),
						       .dout(rv0_t0_i1_rte_axu0_q)
						       );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_rte_axu1_q_reg(
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
						       .scin(siv[rv0_t0_i1_rte_axu1_offset ]),
						       .scout(sov[rv0_t0_i1_rte_axu1_offset ]),
						       .din(rv0_t0_i1_rte_axu1_d),
						       .dout(rv0_t0_i1_rte_axu1_q)
						       );


   tri_rlmreg_p #(.WIDTH(32), .INIT(0)) rv0_t0_i1_instr_q_reg(
							      .vd(vdd),
							      .gd(gnd),
							      .nclk(nclk),
							      .act(iu6_t0_i1_act),
							      .thold_b(func_sl_thold_0_b),
							      .sg(sg_0),
							      .force_t(force_t),
							      .delay_lclkr(delay_lclkr),
							      .mpw1_b(mpw1_b),
							      .mpw2_b(mpw2_b),
							      .d_mode(d_mode),
							      .scin(siv[rv0_t0_i1_instr_offset :rv0_t0_i1_instr_offset + 31 ]),
							      .scout(sov[rv0_t0_i1_instr_offset :rv0_t0_i1_instr_offset + 31 ]),
							      .din(rv0_t0_i1_instr_d),
							      .dout(rv0_t0_i1_instr_q)
							      );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) rv0_t0_i1_ifar_q_reg(
									 .vd(vdd),
									 .gd(gnd),
									 .nclk(nclk),
									 .act(iu6_t0_i1_act),
									 .thold_b(func_sl_thold_0_b),
									 .sg(sg_0),
									 .force_t(force_t),
									 .delay_lclkr(delay_lclkr),
									 .mpw1_b(mpw1_b),
									 .mpw2_b(mpw2_b),
									 .d_mode(d_mode),
									 .scin(siv[rv0_t0_i1_ifar_offset :rv0_t0_i1_ifar_offset + `EFF_IFAR_WIDTH - 1 ]),
									 .scout(sov[rv0_t0_i1_ifar_offset :rv0_t0_i1_ifar_offset + `EFF_IFAR_WIDTH - 1 ]),
									 .din(rv0_t0_i1_ifar_d),
									 .dout(rv0_t0_i1_ifar_q)
									 );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t0_i1_ucode_q_reg(
							     .vd(vdd),
							     .gd(gnd),
							     .nclk(nclk),
							     .act(iu6_t0_i1_act),
							     .thold_b(func_sl_thold_0_b),
							     .sg(sg_0),
							     .force_t(force_t),
							     .delay_lclkr(delay_lclkr),
							     .mpw1_b(mpw1_b),
							     .mpw2_b(mpw2_b),
							     .d_mode(d_mode),
							     .scin(siv[rv0_t0_i1_ucode_offset :rv0_t0_i1_ucode_offset + 3 - 1 ]),
							     .scout(sov[rv0_t0_i1_ucode_offset :rv0_t0_i1_ucode_offset + 3 - 1 ]),
							     .din(rv0_t0_i1_ucode_d),
							     .dout(rv0_t0_i1_ucode_q)
							     );




   tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0)) rv0_t0_i1_ucode_cnt_q_reg(
										 .vd(vdd),
										 .gd(gnd),
										 .nclk(nclk),
										 .act(iu6_t0_i1_act),
										 .thold_b(func_sl_thold_0_b),
										 .sg(sg_0),
										 .force_t(force_t),
										 .delay_lclkr(delay_lclkr),
										 .mpw1_b(mpw1_b),
										 .mpw2_b(mpw2_b),
										 .d_mode(d_mode),
										 .scin(siv[rv0_t0_i1_ucode_cnt_offset :rv0_t0_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1 ]),
										 .scout(sov[rv0_t0_i1_ucode_cnt_offset :rv0_t0_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1 ]),
										 .din(rv0_t0_i1_ucode_cnt_d),
										 .dout(rv0_t0_i1_ucode_cnt_q)
										 );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) rv0_t0_i1_itag_q_reg(
									.vd(vdd),
									.gd(gnd),
									.nclk(nclk),
									.act(iu6_t0_i1_act),
									.thold_b(func_sl_thold_0_b),
									.sg(sg_0),
									.force_t(force_t),
									.delay_lclkr(delay_lclkr),
									.mpw1_b(mpw1_b),
									.mpw2_b(mpw2_b),
									.d_mode(d_mode),
									.scin(siv[rv0_t0_i1_itag_offset :rv0_t0_i1_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									.scout(sov[rv0_t0_i1_itag_offset :rv0_t0_i1_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									.din(rv0_t0_i1_itag_d),
									.dout(rv0_t0_i1_itag_q)
									);


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_ord_q_reg(
						  .vd(vdd),
						  .gd(gnd),
						  .nclk(nclk),
						  .act(iu6_t0_i1_act),
						  .thold_b(func_sl_thold_0_b),
						  .sg(sg_0),
						  .force_t(force_t),
						  .delay_lclkr(delay_lclkr),
						  .mpw1_b(mpw1_b),
						  .mpw2_b(mpw2_b),
						  .d_mode(d_mode),
						  .scin(siv[rv0_t0_i1_ord_offset ]),
						  .scout(sov[rv0_t0_i1_ord_offset ]),
						  .din(rv0_t0_i1_ord_d),
						  .dout(rv0_t0_i1_ord_q)
						  );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_cord_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i1_cord_offset ]),
						   .scout(sov[rv0_t0_i1_cord_offset ]),
						   .din(rv0_t0_i1_cord_d),
						   .dout(rv0_t0_i1_cord_q)
						   );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_spec_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i1_spec_offset ]),
						   .scout(sov[rv0_t0_i1_spec_offset ]),
						   .din(rv0_t0_i1_spec_d),
						   .dout(rv0_t0_i1_spec_q)
						   );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_t1_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i1_t1_v_offset ]),
						   .scout(sov[rv0_t0_i1_t1_v_offset ]),
						   .din(rv0_t0_i1_t1_v_d),
						   .dout(rv0_t0_i1_t1_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t0_i1_t1_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t0_i1_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t0_i1_t1_p_offset :rv0_t0_i1_t1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t0_i1_t1_p_offset :rv0_t0_i1_t1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t0_i1_t1_p_d),
								       .dout(rv0_t0_i1_t1_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t0_i1_t1_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t0_i1_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t0_i1_t1_t_offset :rv0_t0_i1_t1_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t0_i1_t1_t_offset :rv0_t0_i1_t1_t_offset + 3 - 1 ]),
							    .din(rv0_t0_i1_t1_t_d),
							    .dout(rv0_t0_i1_t1_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_t2_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i1_t2_v_offset ]),
						   .scout(sov[rv0_t0_i1_t2_v_offset ]),
						   .din(rv0_t0_i1_t2_v_d),
						   .dout(rv0_t0_i1_t2_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t0_i1_t2_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t0_i1_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t0_i1_t2_p_offset :rv0_t0_i1_t2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t0_i1_t2_p_offset :rv0_t0_i1_t2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t0_i1_t2_p_d),
								       .dout(rv0_t0_i1_t2_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t0_i1_t2_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t0_i1_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t0_i1_t2_t_offset :rv0_t0_i1_t2_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t0_i1_t2_t_offset :rv0_t0_i1_t2_t_offset + 3 - 1 ]),
							    .din(rv0_t0_i1_t2_t_d),
							    .dout(rv0_t0_i1_t2_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_t3_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i1_t3_v_offset ]),
						   .scout(sov[rv0_t0_i1_t3_v_offset ]),
						   .din(rv0_t0_i1_t3_v_d),
						   .dout(rv0_t0_i1_t3_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t0_i1_t3_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t0_i1_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t0_i1_t3_p_offset :rv0_t0_i1_t3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t0_i1_t3_p_offset :rv0_t0_i1_t3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t0_i1_t3_p_d),
								       .dout(rv0_t0_i1_t3_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t0_i1_t3_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t0_i1_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t0_i1_t3_t_offset :rv0_t0_i1_t3_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t0_i1_t3_t_offset :rv0_t0_i1_t3_t_offset + 3 - 1 ]),
							    .din(rv0_t0_i1_t3_t_d),
							    .dout(rv0_t0_i1_t3_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_s1_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i1_s1_v_offset ]),
						   .scout(sov[rv0_t0_i1_s1_v_offset ]),
						   .din(rv0_t0_i1_s1_v_d),
						   .dout(rv0_t0_i1_s1_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t0_i1_s1_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t0_i1_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t0_i1_s1_p_offset :rv0_t0_i1_s1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t0_i1_s1_p_offset :rv0_t0_i1_s1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t0_i1_s1_p_d),
								       .dout(rv0_t0_i1_s1_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t0_i1_s1_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t0_i1_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t0_i1_s1_t_offset :rv0_t0_i1_s1_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t0_i1_s1_t_offset :rv0_t0_i1_s1_t_offset + 3 - 1 ]),
							    .din(rv0_t0_i1_s1_t_d),
							    .dout(rv0_t0_i1_s1_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_s2_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i1_s2_v_offset ]),
						   .scout(sov[rv0_t0_i1_s2_v_offset ]),
						   .din(rv0_t0_i1_s2_v_d),
						   .dout(rv0_t0_i1_s2_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t0_i1_s2_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t0_i1_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t0_i1_s2_p_offset :rv0_t0_i1_s2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t0_i1_s2_p_offset :rv0_t0_i1_s2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t0_i1_s2_p_d),
								       .dout(rv0_t0_i1_s2_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t0_i1_s2_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t0_i1_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t0_i1_s2_t_offset :rv0_t0_i1_s2_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t0_i1_s2_t_offset :rv0_t0_i1_s2_t_offset + 3 - 1 ]),
							    .din(rv0_t0_i1_s2_t_d),
							    .dout(rv0_t0_i1_s2_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_s3_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t0_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t0_i1_s3_v_offset ]),
						   .scout(sov[rv0_t0_i1_s3_v_offset ]),
						   .din(rv0_t0_i1_s3_v_d),
						   .dout(rv0_t0_i1_s3_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t0_i1_s3_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t0_i1_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t0_i1_s3_p_offset :rv0_t0_i1_s3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t0_i1_s3_p_offset :rv0_t0_i1_s3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t0_i1_s3_p_d),
								       .dout(rv0_t0_i1_s3_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t0_i1_s3_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t0_i1_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t0_i1_s3_t_offset :rv0_t0_i1_s3_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t0_i1_s3_t_offset :rv0_t0_i1_s3_t_offset + 3 - 1 ]),
							    .din(rv0_t0_i1_s3_t_d),
							    .dout(rv0_t0_i1_s3_t_q)
							    );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
   rv0_t0_i1_s1_itag_q_reg(
			   .vd(vdd),
			   .gd(gnd),
			   .nclk(nclk),
			   .act(iu6_t0_i1_act),
			   .thold_b(func_sl_thold_0_b),
			   .sg(sg_0),
			   .force_t(force_t),
			   .delay_lclkr(delay_lclkr),
			   .mpw1_b(mpw1_b),
			   .mpw2_b(mpw2_b),
			   .d_mode(d_mode),
			   .scin(siv[rv0_t0_i1_s1_itag_offset :rv0_t0_i1_s1_itag_offset + `ITAG_SIZE_ENC - 1 ]),
			   .scout(sov[rv0_t0_i1_s1_itag_offset :rv0_t0_i1_s1_itag_offset + `ITAG_SIZE_ENC - 1 ]),
			   .din(rv0_t0_i1_s1_itag_d),
			   .dout(rv0_t0_i1_s1_itag_q)
			   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
   rv0_t0_i1_s2_itag_q_reg(
			   .vd(vdd),
			   .gd(gnd),
			   .nclk(nclk),
			   .act(iu6_t0_i1_act),
			   .thold_b(func_sl_thold_0_b),
			   .sg(sg_0),
			   .force_t(force_t),
			   .delay_lclkr(delay_lclkr),
			   .mpw1_b(mpw1_b),
			   .mpw2_b(mpw2_b),
			   .d_mode(d_mode),
			   .scin(siv[rv0_t0_i1_s2_itag_offset :rv0_t0_i1_s2_itag_offset + `ITAG_SIZE_ENC - 1 ]),
			   .scout(sov[rv0_t0_i1_s2_itag_offset :rv0_t0_i1_s2_itag_offset + `ITAG_SIZE_ENC - 1 ]),
			   .din(rv0_t0_i1_s2_itag_d),
			   .dout(rv0_t0_i1_s2_itag_q)
			   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0))
   rv0_t0_i1_s3_itag_q_reg(
			   .vd(vdd),
			   .gd(gnd),
			   .nclk(nclk),
			   .act(iu6_t0_i1_act),
			   .thold_b(func_sl_thold_0_b),
			   .sg(sg_0),
			   .force_t(force_t),
			   .delay_lclkr(delay_lclkr),
			   .mpw1_b(mpw1_b),
			   .mpw2_b(mpw2_b),
			   .d_mode(d_mode),
			   .scin(siv[rv0_t0_i1_s3_itag_offset :rv0_t0_i1_s3_itag_offset + `ITAG_SIZE_ENC - 1 ]),
			   .scout(sov[rv0_t0_i1_s3_itag_offset :rv0_t0_i1_s3_itag_offset + `ITAG_SIZE_ENC - 1 ]),
			   .din(rv0_t0_i1_s3_itag_d),
			   .dout(rv0_t0_i1_s3_itag_q)
			   );
   tri_rlmlatch_p #(.INIT(0))
   rv0_t0_i1_s1_dep_hit_q_reg(
			      .vd(vdd),
			      .gd(gnd),
			      .nclk(nclk),
			      .act(iu6_t0_i1_act),
			      .thold_b(func_sl_thold_0_b),
			      .sg(sg_0),
			      .force_t(force_t),
			      .delay_lclkr(delay_lclkr),
			      .mpw1_b(mpw1_b),
			      .mpw2_b(mpw2_b),
			      .d_mode(d_mode),
			      .scin(siv[rv0_t0_i1_s1_dep_hit_offset ]),
			      .scout(sov[rv0_t0_i1_s1_dep_hit_offset ]),
			      .din(rv0_t0_i1_s1_dep_hit_d),
			      .dout(rv0_t0_i1_s1_dep_hit_q)
			      );

   tri_rlmlatch_p #(.INIT(0))
   rv0_t0_i1_s2_dep_hit_q_reg(
			      .vd(vdd),
			      .gd(gnd),
			      .nclk(nclk),
			      .act(iu6_t0_i1_act),
			      .thold_b(func_sl_thold_0_b),
			      .sg(sg_0),
			      .force_t(force_t),
			      .delay_lclkr(delay_lclkr),
			      .mpw1_b(mpw1_b),
			      .mpw2_b(mpw2_b),
			      .d_mode(d_mode),
			      .scin(siv[rv0_t0_i1_s2_dep_hit_offset ]),
			      .scout(sov[rv0_t0_i1_s2_dep_hit_offset ]),
			      .din(rv0_t0_i1_s2_dep_hit_d),
			      .dout(rv0_t0_i1_s2_dep_hit_q)
			      );

   tri_rlmlatch_p #(.INIT(0))
   rv0_t0_i1_s3_dep_hit_q_reg(
			      .vd(vdd),
			      .gd(gnd),
			      .nclk(nclk),
			      .act(iu6_t0_i1_act),
			      .thold_b(func_sl_thold_0_b),
			      .sg(sg_0),
			      .force_t(force_t),
			      .delay_lclkr(delay_lclkr),
			      .mpw1_b(mpw1_b),
			      .mpw2_b(mpw2_b),
			      .d_mode(d_mode),
			      .scin(siv[rv0_t0_i1_s3_dep_hit_offset ]),
			      .scout(sov[rv0_t0_i1_s3_dep_hit_offset ]),
			      .din(rv0_t0_i1_s3_dep_hit_d),
			      .dout(rv0_t0_i1_s3_dep_hit_q)
			      );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0))
   rv0_t0_i1_ilat_q_reg(
			.vd(vdd),
			.gd(gnd),
			.nclk(nclk),
			.act(iu6_t0_i1_act),
			.thold_b(func_sl_thold_0_b),
			.sg(sg_0),
			.force_t(force_t),
			.delay_lclkr(delay_lclkr),
			.mpw1_b(mpw1_b),
			.mpw2_b(mpw2_b),
			.d_mode(d_mode),
			.scin(siv[rv0_t0_i1_ilat_offset :rv0_t0_i1_ilat_offset + 4 - 1 ]),
			.scout(sov[rv0_t0_i1_ilat_offset :rv0_t0_i1_ilat_offset + 4 - 1 ]),
			.din(rv0_t0_i1_ilat_d),
			.dout(rv0_t0_i1_ilat_q)
			);


   tri_rlmreg_p #(.WIDTH(`G_BRANCH_LEN), .INIT(0))
   rv0_t0_i1_branch_q_reg(
			  .vd(vdd),
			  .gd(gnd),
			  .nclk(nclk),
			  .act(iu6_t0_i1_act),
			  .thold_b(func_sl_thold_0_b),
			  .sg(sg_0),
			  .force_t(force_t),
			  .delay_lclkr(delay_lclkr),
			  .mpw1_b(mpw1_b),
			  .mpw2_b(mpw2_b),
			  .d_mode(d_mode),
			  .scin(siv[rv0_t0_i1_branch_offset :rv0_t0_i1_branch_offset + `G_BRANCH_LEN - 1 ]),
			  .scout(sov[rv0_t0_i1_branch_offset :rv0_t0_i1_branch_offset + `G_BRANCH_LEN - 1 ]),
			  .din(rv0_t0_i1_branch_d),
			  .dout(rv0_t0_i1_branch_q)
			  );

   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_isLoad_q_reg(
						     .vd(vdd),
						     .gd(gnd),
						     .nclk(nclk),
						     .act(iu6_t0_i1_act),
						     .thold_b(func_sl_thold_0_b),
						     .sg(sg_0),
						     .force_t(force_t),
						     .delay_lclkr(delay_lclkr),
						     .mpw1_b(mpw1_b),
						     .mpw2_b(mpw2_b),
						     .d_mode(d_mode),
						     .scin(siv[rv0_t0_i1_isLoad_offset ]),
						     .scout(sov[rv0_t0_i1_isLoad_offset ]),
						     .din(rv0_t0_i1_isLoad_d),
						     .dout(rv0_t0_i1_isLoad_q)
						     );


   tri_rlmlatch_p #(.INIT(0)) rv0_t0_i1_isStore_q_reg(
						      .vd(vdd),
						      .gd(gnd),
						      .nclk(nclk),
						      .act(iu6_t0_i1_act),
						      .thold_b(func_sl_thold_0_b),
						      .sg(sg_0),
						      .force_t(force_t),
						      .delay_lclkr(delay_lclkr),
						      .mpw1_b(mpw1_b),
						      .mpw2_b(mpw2_b),
						      .d_mode(d_mode),
						      .scin(siv[rv0_t0_i1_isStore_offset ]),
						      .scout(sov[rv0_t0_i1_isStore_offset ]),
						      .din(rv0_t0_i1_isStore_d),
						      .dout(rv0_t0_i1_isStore_q)
						      );

   assign rv0_t0_i1_spare_d = 4'b0000;


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) rv0_t0_i1_spare_q_reg(
							     .vd(vdd),
							     .gd(gnd),
							     .nclk(nclk),
							     .act(iu6_t0_i1_act),
							     .thold_b(func_sl_thold_0_b),
							     .sg(sg_0),
							     .force_t(force_t),
							     .delay_lclkr(delay_lclkr),
							     .mpw1_b(mpw1_b),
							     .mpw2_b(mpw2_b),
							     .d_mode(d_mode),
							     .scin(siv[rv0_t0_i1_spare_offset :rv0_t0_i1_spare_offset + 4 - 1 ]),
							     .scout(sov[rv0_t0_i1_spare_offset :rv0_t0_i1_spare_offset + 4 - 1 ]),
							     .din(rv0_t0_i1_spare_d),
							     .dout(rv0_t0_i1_spare_q)
							     );


   //------------------------------------------------------------------------------------------------------------
   // // Storage Elements RV1
   //------------------------------------------------------------------------------------------------------------



   //t0_i1
`ifndef THREADS1
   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_vld_reg(
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
							       .scin(siv[rv0_t1_i0_vld_offset]),
							       .scout(sov[rv0_t1_i0_vld_offset]),
							       .din(rv0_t1_i0_vld_d),
							       .dout(rv0_t1_i0_vld_q)
							       );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_rte_lq_q_reg(
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
						     .scin(siv[rv0_t1_i0_rte_lq_offset ]),
						     .scout(sov[rv0_t1_i0_rte_lq_offset ]),
						     .din(rv0_t1_i0_rte_lq_d),
						     .dout(rv0_t1_i0_rte_lq_q)
						     );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_rte_sq_q_reg(
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
						     .scin(siv[rv0_t1_i0_rte_sq_offset ]),
						     .scout(sov[rv0_t1_i0_rte_sq_offset ]),
						     .din(rv0_t1_i0_rte_sq_d),
						     .dout(rv0_t1_i0_rte_sq_q)
						     );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_rte_fx0_q_reg(
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
						      .scin(siv[rv0_t1_i0_rte_fx0_offset ]),
						      .scout(sov[rv0_t1_i0_rte_fx0_offset ]),
						      .din(rv0_t1_i0_rte_fx0_d),
						      .dout(rv0_t1_i0_rte_fx0_q)
						      );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_rte_fx1_q_reg(
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
						      .scin(siv[rv0_t1_i0_rte_fx1_offset ]),
						      .scout(sov[rv0_t1_i0_rte_fx1_offset ]),
						      .din(rv0_t1_i0_rte_fx1_d),
						      .dout(rv0_t1_i0_rte_fx1_q)
						      );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_rte_axu0_q_reg(
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
						       .scin(siv[rv0_t1_i0_rte_axu0_offset ]),
						       .scout(sov[rv0_t1_i0_rte_axu0_offset ]),
						       .din(rv0_t1_i0_rte_axu0_d),
						       .dout(rv0_t1_i0_rte_axu0_q)
						       );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_rte_axu1_q_reg(
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
						       .scin(siv[rv0_t1_i0_rte_axu1_offset ]),
						       .scout(sov[rv0_t1_i0_rte_axu1_offset ]),
						       .din(rv0_t1_i0_rte_axu1_d),
						       .dout(rv0_t1_i0_rte_axu1_q)
						       );


   tri_rlmreg_p #(.WIDTH(32), .INIT(0)) rv0_t1_i0_instr_q_reg(
							      .vd(vdd),
							      .gd(gnd),
							      .nclk(nclk),
							      .act(iu6_t1_i0_act),
							      .thold_b(func_sl_thold_0_b),
							      .sg(sg_0),
							      .force_t(force_t),
							      .delay_lclkr(delay_lclkr),
							      .mpw1_b(mpw1_b),
							      .mpw2_b(mpw2_b),
							      .d_mode(d_mode),
							      .scin(siv[rv0_t1_i0_instr_offset :rv0_t1_i0_instr_offset + 31 ]),
							      .scout(sov[rv0_t1_i0_instr_offset :rv0_t1_i0_instr_offset + 31 ]),
							      .din(rv0_t1_i0_instr_d),
							      .dout(rv0_t1_i0_instr_q)
							      );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) rv0_t1_i0_ifar_q_reg(
									 .vd(vdd),
									 .gd(gnd),
									 .nclk(nclk),
									 .act(iu6_t1_i0_act),
									 .thold_b(func_sl_thold_0_b),
									 .sg(sg_0),
									 .force_t(force_t),
									 .delay_lclkr(delay_lclkr),
									 .mpw1_b(mpw1_b),
									 .mpw2_b(mpw2_b),
									 .d_mode(d_mode),
									 .scin(siv[rv0_t1_i0_ifar_offset :rv0_t1_i0_ifar_offset + `EFF_IFAR_WIDTH - 1 ]),
									 .scout(sov[rv0_t1_i0_ifar_offset :rv0_t1_i0_ifar_offset + `EFF_IFAR_WIDTH - 1 ]),
									 .din(rv0_t1_i0_ifar_d),
									 .dout(rv0_t1_i0_ifar_q)
									 );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t1_i0_ucode_q_reg(
							     .vd(vdd),
							     .gd(gnd),
							     .nclk(nclk),
							     .act(iu6_t1_i0_act),
							     .thold_b(func_sl_thold_0_b),
							     .sg(sg_0),
							     .force_t(force_t),
							     .delay_lclkr(delay_lclkr),
							     .mpw1_b(mpw1_b),
							     .mpw2_b(mpw2_b),
							     .d_mode(d_mode),
							     .scin(siv[rv0_t1_i0_ucode_offset :rv0_t1_i0_ucode_offset + 3 - 1 ]),
							     .scout(sov[rv0_t1_i0_ucode_offset :rv0_t1_i0_ucode_offset + 3 - 1 ]),
							     .din(rv0_t1_i0_ucode_d),
							     .dout(rv0_t1_i0_ucode_q)
							     );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_2ucode_q_reg(
						     .vd(vdd),
						     .gd(gnd),
						     .nclk(nclk),
						     .act(iu6_t1_i0_act),
						     .thold_b(func_sl_thold_0_b),
						     .sg(sg_0),
						     .force_t(force_t),
						     .delay_lclkr(delay_lclkr),
						     .mpw1_b(mpw1_b),
						     .mpw2_b(mpw2_b),
						     .d_mode(d_mode),
						     .scin(siv[rv0_t1_i0_2ucode_offset ]),
						     .scout(sov[rv0_t1_i0_2ucode_offset ]),
						     .din(rv0_t1_i0_2ucode_d),
						     .dout(rv0_t1_i0_2ucode_q)
						     );


   tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0)) rv0_t1_i0_ucode_cnt_q_reg(
										 .vd(vdd),
										 .gd(gnd),
										 .nclk(nclk),
										 .act(iu6_t1_i0_act),
										 .thold_b(func_sl_thold_0_b),
										 .sg(sg_0),
										 .force_t(force_t),
										 .delay_lclkr(delay_lclkr),
										 .mpw1_b(mpw1_b),
										 .mpw2_b(mpw2_b),
										 .d_mode(d_mode),
										 .scin(siv[rv0_t1_i0_ucode_cnt_offset :rv0_t1_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1 ]),
										 .scout(sov[rv0_t1_i0_ucode_cnt_offset :rv0_t1_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1 ]),
										 .din(rv0_t1_i0_ucode_cnt_d),
										 .dout(rv0_t1_i0_ucode_cnt_q)
										 );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) rv0_t1_i0_itag_q_reg(
									.vd(vdd),
									.gd(gnd),
									.nclk(nclk),
									.act(iu6_t1_i0_act),
									.thold_b(func_sl_thold_0_b),
									.sg(sg_0),
									.force_t(force_t),
									.delay_lclkr(delay_lclkr),
									.mpw1_b(mpw1_b),
									.mpw2_b(mpw2_b),
									.d_mode(d_mode),
									.scin(siv[rv0_t1_i0_itag_offset :rv0_t1_i0_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									.scout(sov[rv0_t1_i0_itag_offset :rv0_t1_i0_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									.din(rv0_t1_i0_itag_d),
									.dout(rv0_t1_i0_itag_q)
									);


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_ord_q_reg(
						  .vd(vdd),
						  .gd(gnd),
						  .nclk(nclk),
						  .act(iu6_t1_i0_act),
						  .thold_b(func_sl_thold_0_b),
						  .sg(sg_0),
						  .force_t(force_t),
						  .delay_lclkr(delay_lclkr),
						  .mpw1_b(mpw1_b),
						  .mpw2_b(mpw2_b),
						  .d_mode(d_mode),
						  .scin(siv[rv0_t1_i0_ord_offset ]),
						  .scout(sov[rv0_t1_i0_ord_offset ]),
						  .din(rv0_t1_i0_ord_d),
						  .dout(rv0_t1_i0_ord_q)
						  );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_cord_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i0_cord_offset ]),
						   .scout(sov[rv0_t1_i0_cord_offset ]),
						   .din(rv0_t1_i0_cord_d),
						   .dout(rv0_t1_i0_cord_q)
						   );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_spec_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i0_spec_offset ]),
						   .scout(sov[rv0_t1_i0_spec_offset ]),
						   .din(rv0_t1_i0_spec_d),
						   .dout(rv0_t1_i0_spec_q)
						   );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_t1_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i0_t1_v_offset ]),
						   .scout(sov[rv0_t1_i0_t1_v_offset ]),
						   .din(rv0_t1_i0_t1_v_d),
						   .dout(rv0_t1_i0_t1_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t1_i0_t1_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t1_i0_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t1_i0_t1_p_offset :rv0_t1_i0_t1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t1_i0_t1_p_offset :rv0_t1_i0_t1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t1_i0_t1_p_d),
								       .dout(rv0_t1_i0_t1_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t1_i0_t1_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t1_i0_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t1_i0_t1_t_offset :rv0_t1_i0_t1_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t1_i0_t1_t_offset :rv0_t1_i0_t1_t_offset + 3 - 1 ]),
							    .din(rv0_t1_i0_t1_t_d),
							    .dout(rv0_t1_i0_t1_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_t2_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i0_t2_v_offset ]),
						   .scout(sov[rv0_t1_i0_t2_v_offset ]),
						   .din(rv0_t1_i0_t2_v_d),
						   .dout(rv0_t1_i0_t2_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t1_i0_t2_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t1_i0_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t1_i0_t2_p_offset :rv0_t1_i0_t2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t1_i0_t2_p_offset :rv0_t1_i0_t2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t1_i0_t2_p_d),
								       .dout(rv0_t1_i0_t2_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t1_i0_t2_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t1_i0_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t1_i0_t2_t_offset :rv0_t1_i0_t2_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t1_i0_t2_t_offset :rv0_t1_i0_t2_t_offset + 3 - 1 ]),
							    .din(rv0_t1_i0_t2_t_d),
							    .dout(rv0_t1_i0_t2_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_t3_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i0_t3_v_offset ]),
						   .scout(sov[rv0_t1_i0_t3_v_offset ]),
						   .din(rv0_t1_i0_t3_v_d),
						   .dout(rv0_t1_i0_t3_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t1_i0_t3_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t1_i0_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t1_i0_t3_p_offset :rv0_t1_i0_t3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t1_i0_t3_p_offset :rv0_t1_i0_t3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t1_i0_t3_p_d),
								       .dout(rv0_t1_i0_t3_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t1_i0_t3_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t1_i0_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t1_i0_t3_t_offset :rv0_t1_i0_t3_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t1_i0_t3_t_offset :rv0_t1_i0_t3_t_offset + 3 - 1 ]),
							    .din(rv0_t1_i0_t3_t_d),
							    .dout(rv0_t1_i0_t3_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_s1_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i0_s1_v_offset ]),
						   .scout(sov[rv0_t1_i0_s1_v_offset ]),
						   .din(rv0_t1_i0_s1_v_d),
						   .dout(rv0_t1_i0_s1_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t1_i0_s1_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t1_i0_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t1_i0_s1_p_offset :rv0_t1_i0_s1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t1_i0_s1_p_offset :rv0_t1_i0_s1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t1_i0_s1_p_d),
								       .dout(rv0_t1_i0_s1_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t1_i0_s1_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t1_i0_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t1_i0_s1_t_offset :rv0_t1_i0_s1_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t1_i0_s1_t_offset :rv0_t1_i0_s1_t_offset + 3 - 1 ]),
							    .din(rv0_t1_i0_s1_t_d),
							    .dout(rv0_t1_i0_s1_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_s2_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i0_s2_v_offset ]),
						   .scout(sov[rv0_t1_i0_s2_v_offset ]),
						   .din(rv0_t1_i0_s2_v_d),
						   .dout(rv0_t1_i0_s2_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t1_i0_s2_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t1_i0_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t1_i0_s2_p_offset :rv0_t1_i0_s2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t1_i0_s2_p_offset :rv0_t1_i0_s2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t1_i0_s2_p_d),
								       .dout(rv0_t1_i0_s2_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t1_i0_s2_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t1_i0_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t1_i0_s2_t_offset :rv0_t1_i0_s2_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t1_i0_s2_t_offset :rv0_t1_i0_s2_t_offset + 3 - 1 ]),
							    .din(rv0_t1_i0_s2_t_d),
							    .dout(rv0_t1_i0_s2_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_s3_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i0_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i0_s3_v_offset ]),
						   .scout(sov[rv0_t1_i0_s3_v_offset ]),
						   .din(rv0_t1_i0_s3_v_d),
						   .dout(rv0_t1_i0_s3_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t1_i0_s3_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t1_i0_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t1_i0_s3_p_offset :rv0_t1_i0_s3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t1_i0_s3_p_offset :rv0_t1_i0_s3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t1_i0_s3_p_d),
								       .dout(rv0_t1_i0_s3_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t1_i0_s3_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t1_i0_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t1_i0_s3_t_offset :rv0_t1_i0_s3_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t1_i0_s3_t_offset :rv0_t1_i0_s3_t_offset + 3 - 1 ]),
							    .din(rv0_t1_i0_s3_t_d),
							    .dout(rv0_t1_i0_s3_t_q)
							    );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) rv0_t1_i0_s1_itag_q_reg(
									   .vd(vdd),
									   .gd(gnd),
									   .nclk(nclk),
									   .act(iu6_t1_i0_act),
									   .thold_b(func_sl_thold_0_b),
									   .sg(sg_0),
									   .force_t(force_t),
									   .delay_lclkr(delay_lclkr),
									   .mpw1_b(mpw1_b),
									   .mpw2_b(mpw2_b),
									   .d_mode(d_mode),
									   .scin(siv[rv0_t1_i0_s1_itag_offset :rv0_t1_i0_s1_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .scout(sov[rv0_t1_i0_s1_itag_offset :rv0_t1_i0_s1_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .din(rv0_t1_i0_s1_itag_d),
									   .dout(rv0_t1_i0_s1_itag_q)
									   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) rv0_t1_i0_s2_itag_q_reg(
									   .vd(vdd),
									   .gd(gnd),
									   .nclk(nclk),
									   .act(iu6_t1_i0_act),
									   .thold_b(func_sl_thold_0_b),
									   .sg(sg_0),
									   .force_t(force_t),
									   .delay_lclkr(delay_lclkr),
									   .mpw1_b(mpw1_b),
									   .mpw2_b(mpw2_b),
									   .d_mode(d_mode),
									   .scin(siv[rv0_t1_i0_s2_itag_offset :rv0_t1_i0_s2_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .scout(sov[rv0_t1_i0_s2_itag_offset :rv0_t1_i0_s2_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .din(rv0_t1_i0_s2_itag_d),
									   .dout(rv0_t1_i0_s2_itag_q)
									   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) rv0_t1_i0_s3_itag_q_reg(
									   .vd(vdd),
									   .gd(gnd),
									   .nclk(nclk),
									   .act(iu6_t1_i0_act),
									   .thold_b(func_sl_thold_0_b),
									   .sg(sg_0),
									   .force_t(force_t),
									   .delay_lclkr(delay_lclkr),
									   .mpw1_b(mpw1_b),
									   .mpw2_b(mpw2_b),
									   .d_mode(d_mode),
									   .scin(siv[rv0_t1_i0_s3_itag_offset :rv0_t1_i0_s3_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .scout(sov[rv0_t1_i0_s3_itag_offset :rv0_t1_i0_s3_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .din(rv0_t1_i0_s3_itag_d),
									   .dout(rv0_t1_i0_s3_itag_q)
									   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) rv0_t1_i0_ilat_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t1_i0_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t1_i0_ilat_offset :rv0_t1_i0_ilat_offset + 4 - 1 ]),
							    .scout(sov[rv0_t1_i0_ilat_offset :rv0_t1_i0_ilat_offset + 4 - 1 ]),
							    .din(rv0_t1_i0_ilat_d),
							    .dout(rv0_t1_i0_ilat_q)
							    );


   tri_rlmreg_p #(.WIDTH(`G_BRANCH_LEN), .INIT(0)) rv0_t1_i0_branch_q_reg(
									 .vd(vdd),
									 .gd(gnd),
									 .nclk(nclk),
									 .act(iu6_t1_i0_act),
									 .thold_b(func_sl_thold_0_b),
									 .sg(sg_0),
									 .force_t(force_t),
									 .delay_lclkr(delay_lclkr),
									 .mpw1_b(mpw1_b),
									 .mpw2_b(mpw2_b),
									 .d_mode(d_mode),
									 .scin(siv[rv0_t1_i0_branch_offset :rv0_t1_i0_branch_offset + `G_BRANCH_LEN - 1 ]),
									 .scout(sov[rv0_t1_i0_branch_offset :rv0_t1_i0_branch_offset + `G_BRANCH_LEN - 1 ]),
									 .din(rv0_t1_i0_branch_d),
									 .dout(rv0_t1_i0_branch_q)
									 );

   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_isLoad_q_reg(
						     .vd(vdd),
						     .gd(gnd),
						     .nclk(nclk),
						     .act(iu6_t1_i0_act),
						     .thold_b(func_sl_thold_0_b),
						     .sg(sg_0),
						     .force_t(force_t),
						     .delay_lclkr(delay_lclkr),
						     .mpw1_b(mpw1_b),
						     .mpw2_b(mpw2_b),
						     .d_mode(d_mode),
						     .scin(siv[rv0_t1_i0_isLoad_offset ]),
						     .scout(sov[rv0_t1_i0_isLoad_offset ]),
						     .din(rv0_t1_i0_isLoad_d),
						     .dout(rv0_t1_i0_isLoad_q)
						     );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i0_isStore_q_reg(
						      .vd(vdd),
						      .gd(gnd),
						      .nclk(nclk),
						      .act(iu6_t1_i0_act),
						      .thold_b(func_sl_thold_0_b),
						      .sg(sg_0),
						      .force_t(force_t),
						      .delay_lclkr(delay_lclkr),
						      .mpw1_b(mpw1_b),
						      .mpw2_b(mpw2_b),
						      .d_mode(d_mode),
						      .scin(siv[rv0_t1_i0_isStore_offset ]),
						      .scout(sov[rv0_t1_i0_isStore_offset ]),
						      .din(rv0_t1_i0_isStore_d),
						      .dout(rv0_t1_i0_isStore_q)
						      );

   assign rv0_t1_i0_spare_d = 4'b0000;


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) rv0_t1_i0_spare_q_reg(
							     .vd(vdd),
							     .gd(gnd),
							     .nclk(nclk),
							     .act(iu6_t1_i0_act),
							     .thold_b(func_sl_thold_0_b),
							     .sg(sg_0),
							     .force_t(force_t),
							     .delay_lclkr(delay_lclkr),
							     .mpw1_b(mpw1_b),
							     .mpw2_b(mpw2_b),
							     .d_mode(d_mode),
							     .scin(siv[rv0_t1_i0_spare_offset :rv0_t1_i0_spare_offset + 4 - 1 ]),
							     .scout(sov[rv0_t1_i0_spare_offset :rv0_t1_i0_spare_offset + 4 - 1 ]),
							     .din(rv0_t1_i0_spare_d),
							     .dout(rv0_t1_i0_spare_q)
							     );

   //t1_i1
   tri_rlmlatch_p #( .INIT(0)) rv0_t1_i1_vld_reg(
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
							       .scin(siv[rv0_t1_i1_vld_offset]),
							       .scout(sov[rv0_t1_i1_vld_offset]),
							       .din(rv0_t1_i1_vld_d),
							       .dout(rv0_t1_i1_vld_q)
							       );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_rte_lq_q_reg(
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
						     .scin(siv[rv0_t1_i1_rte_lq_offset ]),
						     .scout(sov[rv0_t1_i1_rte_lq_offset ]),
						     .din(rv0_t1_i1_rte_lq_d),
						     .dout(rv0_t1_i1_rte_lq_q)
						     );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_rte_sq_q_reg(
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
						     .scin(siv[rv0_t1_i1_rte_sq_offset ]),
						     .scout(sov[rv0_t1_i1_rte_sq_offset ]),
						     .din(rv0_t1_i1_rte_sq_d),
						     .dout(rv0_t1_i1_rte_sq_q)
						     );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_rte_fx0_q_reg(
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
						      .scin(siv[rv0_t1_i1_rte_fx0_offset ]),
						      .scout(sov[rv0_t1_i1_rte_fx0_offset ]),
						      .din(rv0_t1_i1_rte_fx0_d),
						      .dout(rv0_t1_i1_rte_fx0_q)
						      );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_rte_fx1_q_reg(
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
						      .scin(siv[rv0_t1_i1_rte_fx1_offset ]),
						      .scout(sov[rv0_t1_i1_rte_fx1_offset ]),
						      .din(rv0_t1_i1_rte_fx1_d),
						      .dout(rv0_t1_i1_rte_fx1_q)
						      );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_rte_axu0_q_reg(
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
						       .scin(siv[rv0_t1_i1_rte_axu0_offset ]),
						       .scout(sov[rv0_t1_i1_rte_axu0_offset ]),
						       .din(rv0_t1_i1_rte_axu0_d),
						       .dout(rv0_t1_i1_rte_axu0_q)
						       );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_rte_axu1_q_reg(
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
						       .scin(siv[rv0_t1_i1_rte_axu1_offset ]),
						       .scout(sov[rv0_t1_i1_rte_axu1_offset ]),
						       .din(rv0_t1_i1_rte_axu1_d),
						       .dout(rv0_t1_i1_rte_axu1_q)
						       );


   tri_rlmreg_p #(.WIDTH(32), .INIT(0)) rv0_t1_i1_instr_q_reg(
							      .vd(vdd),
							      .gd(gnd),
							      .nclk(nclk),
							      .act(iu6_t1_i1_act),
							      .thold_b(func_sl_thold_0_b),
							      .sg(sg_0),
							      .force_t(force_t),
							      .delay_lclkr(delay_lclkr),
							      .mpw1_b(mpw1_b),
							      .mpw2_b(mpw2_b),
							      .d_mode(d_mode),
							      .scin(siv[rv0_t1_i1_instr_offset :rv0_t1_i1_instr_offset + 31 ]),
							      .scout(sov[rv0_t1_i1_instr_offset :rv0_t1_i1_instr_offset + 31 ]),
							      .din(rv0_t1_i1_instr_d),
							      .dout(rv0_t1_i1_instr_q)
							      );


   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0)) rv0_t1_i1_ifar_q_reg(
									 .vd(vdd),
									 .gd(gnd),
									 .nclk(nclk),
									 .act(iu6_t1_i1_act),
									 .thold_b(func_sl_thold_0_b),
									 .sg(sg_0),
									 .force_t(force_t),
									 .delay_lclkr(delay_lclkr),
									 .mpw1_b(mpw1_b),
									 .mpw2_b(mpw2_b),
									 .d_mode(d_mode),
									 .scin(siv[rv0_t1_i1_ifar_offset :rv0_t1_i1_ifar_offset + `EFF_IFAR_WIDTH - 1 ]),
									 .scout(sov[rv0_t1_i1_ifar_offset :rv0_t1_i1_ifar_offset + `EFF_IFAR_WIDTH - 1 ]),
									 .din(rv0_t1_i1_ifar_d),
									 .dout(rv0_t1_i1_ifar_q)
									 );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t1_i1_ucode_q_reg(
							     .vd(vdd),
							     .gd(gnd),
							     .nclk(nclk),
							     .act(iu6_t1_i1_act),
							     .thold_b(func_sl_thold_0_b),
							     .sg(sg_0),
							     .force_t(force_t),
							     .delay_lclkr(delay_lclkr),
							     .mpw1_b(mpw1_b),
							     .mpw2_b(mpw2_b),
							     .d_mode(d_mode),
							     .scin(siv[rv0_t1_i1_ucode_offset :rv0_t1_i1_ucode_offset + 3 - 1 ]),
							     .scout(sov[rv0_t1_i1_ucode_offset :rv0_t1_i1_ucode_offset + 3 - 1 ]),
							     .din(rv0_t1_i1_ucode_d),
							     .dout(rv0_t1_i1_ucode_q)
							     );




   tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0)) rv0_t1_i1_ucode_cnt_q_reg(
										 .vd(vdd),
										 .gd(gnd),
										 .nclk(nclk),
										 .act(iu6_t1_i1_act),
										 .thold_b(func_sl_thold_0_b),
										 .sg(sg_0),
										 .force_t(force_t),
										 .delay_lclkr(delay_lclkr),
										 .mpw1_b(mpw1_b),
										 .mpw2_b(mpw2_b),
										 .d_mode(d_mode),
										 .scin(siv[rv0_t1_i1_ucode_cnt_offset :rv0_t1_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1 ]),
										 .scout(sov[rv0_t1_i1_ucode_cnt_offset :rv0_t1_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1 ]),
										 .din(rv0_t1_i1_ucode_cnt_d),
										 .dout(rv0_t1_i1_ucode_cnt_q)
										 );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) rv0_t1_i1_itag_q_reg(
									.vd(vdd),
									.gd(gnd),
									.nclk(nclk),
									.act(iu6_t1_i1_act),
									.thold_b(func_sl_thold_0_b),
									.sg(sg_0),
									.force_t(force_t),
									.delay_lclkr(delay_lclkr),
									.mpw1_b(mpw1_b),
									.mpw2_b(mpw2_b),
									.d_mode(d_mode),
									.scin(siv[rv0_t1_i1_itag_offset :rv0_t1_i1_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									.scout(sov[rv0_t1_i1_itag_offset :rv0_t1_i1_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									.din(rv0_t1_i1_itag_d),
									.dout(rv0_t1_i1_itag_q)
									);


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_ord_q_reg(
						  .vd(vdd),
						  .gd(gnd),
						  .nclk(nclk),
						  .act(iu6_t1_i1_act),
						  .thold_b(func_sl_thold_0_b),
						  .sg(sg_0),
						  .force_t(force_t),
						  .delay_lclkr(delay_lclkr),
						  .mpw1_b(mpw1_b),
						  .mpw2_b(mpw2_b),
						  .d_mode(d_mode),
						  .scin(siv[rv0_t1_i1_ord_offset ]),
						  .scout(sov[rv0_t1_i1_ord_offset ]),
						  .din(rv0_t1_i1_ord_d),
						  .dout(rv0_t1_i1_ord_q)
						  );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_cord_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i1_cord_offset ]),
						   .scout(sov[rv0_t1_i1_cord_offset ]),
						   .din(rv0_t1_i1_cord_d),
						   .dout(rv0_t1_i1_cord_q)
						   );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_spec_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i1_spec_offset ]),
						   .scout(sov[rv0_t1_i1_spec_offset ]),
						   .din(rv0_t1_i1_spec_d),
						   .dout(rv0_t1_i1_spec_q)
						   );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_t1_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i1_t1_v_offset ]),
						   .scout(sov[rv0_t1_i1_t1_v_offset ]),
						   .din(rv0_t1_i1_t1_v_d),
						   .dout(rv0_t1_i1_t1_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t1_i1_t1_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t1_i1_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t1_i1_t1_p_offset :rv0_t1_i1_t1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t1_i1_t1_p_offset :rv0_t1_i1_t1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t1_i1_t1_p_d),
								       .dout(rv0_t1_i1_t1_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t1_i1_t1_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t1_i1_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t1_i1_t1_t_offset :rv0_t1_i1_t1_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t1_i1_t1_t_offset :rv0_t1_i1_t1_t_offset + 3 - 1 ]),
							    .din(rv0_t1_i1_t1_t_d),
							    .dout(rv0_t1_i1_t1_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_t2_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i1_t2_v_offset ]),
						   .scout(sov[rv0_t1_i1_t2_v_offset ]),
						   .din(rv0_t1_i1_t2_v_d),
						   .dout(rv0_t1_i1_t2_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t1_i1_t2_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t1_i1_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t1_i1_t2_p_offset :rv0_t1_i1_t2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t1_i1_t2_p_offset :rv0_t1_i1_t2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t1_i1_t2_p_d),
								       .dout(rv0_t1_i1_t2_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t1_i1_t2_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t1_i1_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t1_i1_t2_t_offset :rv0_t1_i1_t2_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t1_i1_t2_t_offset :rv0_t1_i1_t2_t_offset + 3 - 1 ]),
							    .din(rv0_t1_i1_t2_t_d),
							    .dout(rv0_t1_i1_t2_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_t3_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i1_t3_v_offset ]),
						   .scout(sov[rv0_t1_i1_t3_v_offset ]),
						   .din(rv0_t1_i1_t3_v_d),
						   .dout(rv0_t1_i1_t3_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t1_i1_t3_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t1_i1_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t1_i1_t3_p_offset :rv0_t1_i1_t3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t1_i1_t3_p_offset :rv0_t1_i1_t3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t1_i1_t3_p_d),
								       .dout(rv0_t1_i1_t3_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t1_i1_t3_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t1_i1_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t1_i1_t3_t_offset :rv0_t1_i1_t3_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t1_i1_t3_t_offset :rv0_t1_i1_t3_t_offset + 3 - 1 ]),
							    .din(rv0_t1_i1_t3_t_d),
							    .dout(rv0_t1_i1_t3_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_s1_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i1_s1_v_offset ]),
						   .scout(sov[rv0_t1_i1_s1_v_offset ]),
						   .din(rv0_t1_i1_s1_v_d),
						   .dout(rv0_t1_i1_s1_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t1_i1_s1_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t1_i1_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t1_i1_s1_p_offset :rv0_t1_i1_s1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t1_i1_s1_p_offset :rv0_t1_i1_s1_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t1_i1_s1_p_d),
								       .dout(rv0_t1_i1_s1_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t1_i1_s1_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t1_i1_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t1_i1_s1_t_offset :rv0_t1_i1_s1_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t1_i1_s1_t_offset :rv0_t1_i1_s1_t_offset + 3 - 1 ]),
							    .din(rv0_t1_i1_s1_t_d),
							    .dout(rv0_t1_i1_s1_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_s2_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i1_s2_v_offset ]),
						   .scout(sov[rv0_t1_i1_s2_v_offset ]),
						   .din(rv0_t1_i1_s2_v_d),
						   .dout(rv0_t1_i1_s2_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t1_i1_s2_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t1_i1_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t1_i1_s2_p_offset :rv0_t1_i1_s2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t1_i1_s2_p_offset :rv0_t1_i1_s2_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t1_i1_s2_p_d),
								       .dout(rv0_t1_i1_s2_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t1_i1_s2_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t1_i1_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t1_i1_s2_t_offset :rv0_t1_i1_s2_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t1_i1_s2_t_offset :rv0_t1_i1_s2_t_offset + 3 - 1 ]),
							    .din(rv0_t1_i1_s2_t_d),
							    .dout(rv0_t1_i1_s2_t_q)
							    );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_s3_v_q_reg(
						   .vd(vdd),
						   .gd(gnd),
						   .nclk(nclk),
						   .act(iu6_t1_i1_act),
						   .thold_b(func_sl_thold_0_b),
						   .sg(sg_0),
						   .force_t(force_t),
						   .delay_lclkr(delay_lclkr),
						   .mpw1_b(mpw1_b),
						   .mpw2_b(mpw2_b),
						   .d_mode(d_mode),
						   .scin(siv[rv0_t1_i1_s3_v_offset ]),
						   .scout(sov[rv0_t1_i1_s3_v_offset ]),
						   .din(rv0_t1_i1_s3_v_d),
						   .dout(rv0_t1_i1_s3_v_q)
						   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) rv0_t1_i1_s3_p_q_reg(
								       .vd(vdd),
								       .gd(gnd),
								       .nclk(nclk),
								       .act(iu6_t1_i1_act),
								       .thold_b(func_sl_thold_0_b),
								       .sg(sg_0),
								       .force_t(force_t),
								       .delay_lclkr(delay_lclkr),
								       .mpw1_b(mpw1_b),
								       .mpw2_b(mpw2_b),
								       .d_mode(d_mode),
								       .scin(siv[rv0_t1_i1_s3_p_offset :rv0_t1_i1_s3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .scout(sov[rv0_t1_i1_s3_p_offset :rv0_t1_i1_s3_p_offset + `GPR_POOL_ENC - 1 ]),
								       .din(rv0_t1_i1_s3_p_d),
								       .dout(rv0_t1_i1_s3_p_q)
								       );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) rv0_t1_i1_s3_t_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t1_i1_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t1_i1_s3_t_offset :rv0_t1_i1_s3_t_offset + 3 - 1 ]),
							    .scout(sov[rv0_t1_i1_s3_t_offset :rv0_t1_i1_s3_t_offset + 3 - 1 ]),
							    .din(rv0_t1_i1_s3_t_d),
							    .dout(rv0_t1_i1_s3_t_q)
							    );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) rv0_t1_i1_s1_itag_q_reg(
									   .vd(vdd),
									   .gd(gnd),
									   .nclk(nclk),
									   .act(iu6_t1_i1_act),
									   .thold_b(func_sl_thold_0_b),
									   .sg(sg_0),
									   .force_t(force_t),
									   .delay_lclkr(delay_lclkr),
									   .mpw1_b(mpw1_b),
									   .mpw2_b(mpw2_b),
									   .d_mode(d_mode),
									   .scin(siv[rv0_t1_i1_s1_itag_offset :rv0_t1_i1_s1_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .scout(sov[rv0_t1_i1_s1_itag_offset :rv0_t1_i1_s1_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .din(rv0_t1_i1_s1_itag_d),
									   .dout(rv0_t1_i1_s1_itag_q)
									   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) rv0_t1_i1_s2_itag_q_reg(
									   .vd(vdd),
									   .gd(gnd),
									   .nclk(nclk),
									   .act(iu6_t1_i1_act),
									   .thold_b(func_sl_thold_0_b),
									   .sg(sg_0),
									   .force_t(force_t),
									   .delay_lclkr(delay_lclkr),
									   .mpw1_b(mpw1_b),
									   .mpw2_b(mpw2_b),
									   .d_mode(d_mode),
									   .scin(siv[rv0_t1_i1_s2_itag_offset :rv0_t1_i1_s2_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .scout(sov[rv0_t1_i1_s2_itag_offset :rv0_t1_i1_s2_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .din(rv0_t1_i1_s2_itag_d),
									   .dout(rv0_t1_i1_s2_itag_q)
									   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) rv0_t1_i1_s3_itag_q_reg(
									   .vd(vdd),
									   .gd(gnd),
									   .nclk(nclk),
									   .act(iu6_t1_i1_act),
									   .thold_b(func_sl_thold_0_b),
									   .sg(sg_0),
									   .force_t(force_t),
									   .delay_lclkr(delay_lclkr),
									   .mpw1_b(mpw1_b),
									   .mpw2_b(mpw2_b),
									   .d_mode(d_mode),
									   .scin(siv[rv0_t1_i1_s3_itag_offset :rv0_t1_i1_s3_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .scout(sov[rv0_t1_i1_s3_itag_offset :rv0_t1_i1_s3_itag_offset + `ITAG_SIZE_ENC - 1 ]),
									   .din(rv0_t1_i1_s3_itag_d),
									   .dout(rv0_t1_i1_s3_itag_q)
									   );

      tri_rlmlatch_p #(.INIT(0))
   rv0_t1_i1_s1_dep_hit_q_reg(
			      .vd(vdd),
			      .gd(gnd),
			      .nclk(nclk),
			      .act(iu6_t1_i1_act),
			      .thold_b(func_sl_thold_0_b),
			      .sg(sg_0),
			      .force_t(force_t),
			      .delay_lclkr(delay_lclkr),
			      .mpw1_b(mpw1_b),
			      .mpw2_b(mpw2_b),
			      .d_mode(d_mode),
			      .scin(siv[rv0_t1_i1_s1_dep_hit_offset ]),
			      .scout(sov[rv0_t1_i1_s1_dep_hit_offset ]),
			      .din(rv0_t1_i1_s1_dep_hit_d),
			      .dout(rv0_t1_i1_s1_dep_hit_q)
			      );

   tri_rlmlatch_p #(.INIT(0))
   rv0_t1_i1_s2_dep_hit_q_reg(
			      .vd(vdd),
			      .gd(gnd),
			      .nclk(nclk),
			      .act(iu6_t1_i1_act),
			      .thold_b(func_sl_thold_0_b),
			      .sg(sg_0),
			      .force_t(force_t),
			      .delay_lclkr(delay_lclkr),
			      .mpw1_b(mpw1_b),
			      .mpw2_b(mpw2_b),
			      .d_mode(d_mode),
			      .scin(siv[rv0_t1_i1_s2_dep_hit_offset ]),
			      .scout(sov[rv0_t1_i1_s2_dep_hit_offset ]),
			      .din(rv0_t1_i1_s2_dep_hit_d),
			      .dout(rv0_t1_i1_s2_dep_hit_q)
			      );

   tri_rlmlatch_p #(.INIT(0))
   rv0_t1_i1_s3_dep_hit_q_reg(
			      .vd(vdd),
			      .gd(gnd),
			      .nclk(nclk),
			      .act(iu6_t1_i1_act),
			      .thold_b(func_sl_thold_0_b),
			      .sg(sg_0),
			      .force_t(force_t),
			      .delay_lclkr(delay_lclkr),
			      .mpw1_b(mpw1_b),
			      .mpw2_b(mpw2_b),
			      .d_mode(d_mode),
			      .scin(siv[rv0_t1_i1_s3_dep_hit_offset ]),
			      .scout(sov[rv0_t1_i1_s3_dep_hit_offset ]),
			      .din(rv0_t1_i1_s3_dep_hit_d),
			      .dout(rv0_t1_i1_s3_dep_hit_q)
			      );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) rv0_t1_i1_ilat_q_reg(
							    .vd(vdd),
							    .gd(gnd),
							    .nclk(nclk),
							    .act(iu6_t1_i1_act),
							    .thold_b(func_sl_thold_0_b),
							    .sg(sg_0),
							    .force_t(force_t),
							    .delay_lclkr(delay_lclkr),
							    .mpw1_b(mpw1_b),
							    .mpw2_b(mpw2_b),
							    .d_mode(d_mode),
							    .scin(siv[rv0_t1_i1_ilat_offset :rv0_t1_i1_ilat_offset + 4 - 1 ]),
							    .scout(sov[rv0_t1_i1_ilat_offset :rv0_t1_i1_ilat_offset + 4 - 1 ]),
							    .din(rv0_t1_i1_ilat_d),
							    .dout(rv0_t1_i1_ilat_q)
							    );


   tri_rlmreg_p #(.WIDTH(`G_BRANCH_LEN), .INIT(0)) rv0_t1_i1_branch_q_reg(
									 .vd(vdd),
									 .gd(gnd),
									 .nclk(nclk),
									 .act(iu6_t1_i1_act),
									 .thold_b(func_sl_thold_0_b),
									 .sg(sg_0),
									 .force_t(force_t),
									 .delay_lclkr(delay_lclkr),
									 .mpw1_b(mpw1_b),
									 .mpw2_b(mpw2_b),
									 .d_mode(d_mode),
									 .scin(siv[rv0_t1_i1_branch_offset :rv0_t1_i1_branch_offset + `G_BRANCH_LEN - 1 ]),
									 .scout(sov[rv0_t1_i1_branch_offset :rv0_t1_i1_branch_offset + `G_BRANCH_LEN - 1 ]),
									 .din(rv0_t1_i1_branch_d),
									 .dout(rv0_t1_i1_branch_q)
									 );

   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_isLoad_q_reg(
						     .vd(vdd),
						     .gd(gnd),
						     .nclk(nclk),
						     .act(iu6_t1_i1_act),
						     .thold_b(func_sl_thold_0_b),
						     .sg(sg_0),
						     .force_t(force_t),
						     .delay_lclkr(delay_lclkr),
						     .mpw1_b(mpw1_b),
						     .mpw2_b(mpw2_b),
						     .d_mode(d_mode),
						     .scin(siv[rv0_t1_i1_isLoad_offset ]),
						     .scout(sov[rv0_t1_i1_isLoad_offset ]),
						     .din(rv0_t1_i1_isLoad_d),
						     .dout(rv0_t1_i1_isLoad_q)
						     );


   tri_rlmlatch_p #(.INIT(0)) rv0_t1_i1_isStore_q_reg(
						      .vd(vdd),
						      .gd(gnd),
						      .nclk(nclk),
						      .act(iu6_t1_i1_act),
						      .thold_b(func_sl_thold_0_b),
						      .sg(sg_0),
						      .force_t(force_t),
						      .delay_lclkr(delay_lclkr),
						      .mpw1_b(mpw1_b),
						      .mpw2_b(mpw2_b),
						      .d_mode(d_mode),
						      .scin(siv[rv0_t1_i1_isStore_offset ]),
						      .scout(sov[rv0_t1_i1_isStore_offset ]),
						      .din(rv0_t1_i1_isStore_d),
						      .dout(rv0_t1_i1_isStore_q)
						      );

   assign rv0_t1_i1_spare_d = 4'b0000;


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) rv0_t1_i1_spare_q_reg(
							     .vd(vdd),
							     .gd(gnd),
							     .nclk(nclk),
							     .act(iu6_t1_i1_act),
							     .thold_b(func_sl_thold_0_b),
							     .sg(sg_0),
							     .force_t(force_t),
							     .delay_lclkr(delay_lclkr),
							     .mpw1_b(mpw1_b),
							     .mpw2_b(mpw2_b),
							     .d_mode(d_mode),
							     .scin(siv[rv0_t1_i1_spare_offset :rv0_t1_i1_spare_offset + 4 - 1 ]),
							     .scout(sov[rv0_t1_i1_spare_offset :rv0_t1_i1_spare_offset + 4 - 1 ]),
							     .din(rv0_t1_i1_spare_d),
							     .dout(rv0_t1_i1_spare_q)
							     );





`endif



   //------------------------------------------------------------------------------------------------------------
   // // Misc
   //------------------------------------------------------------------------------------------------------------


   //------------------------------------------------------------------------------------------------------------
   // Dep Hit latches (replicated per unit)
   //------------------------------------------------------------------------------------------------------------


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
 rv0_instr_i0_flushed_reg(
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
								      .scin(siv[rv0_instr_i0_flushed_offset:rv0_instr_i0_flushed_offset + `THREADS - 1]),
								      .scout(sov[rv0_instr_i0_flushed_offset:rv0_instr_i0_flushed_offset + `THREADS - 1]),
								      .din(rv0_instr_i0_flushed_d),
								      .dout(rv0_instr_i0_flushed_q)
								      );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
 rv0_instr_i1_flushed_reg(
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
								      .scin(siv[rv0_instr_i1_flushed_offset:rv0_instr_i1_flushed_offset + `THREADS - 1]),
								      .scout(sov[rv0_instr_i1_flushed_offset:rv0_instr_i1_flushed_offset + `THREADS - 1]),
								      .din(rv0_instr_i1_flushed_d),
								      .dout(rv0_instr_i1_flushed_q)
								      );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
 rv1_lq_instr_i0_vld_reg(
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
								     .scin(siv[rv1_lq_instr_i0_vld_offset:rv1_lq_instr_i0_vld_offset + `THREADS - 1]),
								     .scout(sov[rv1_lq_instr_i0_vld_offset:rv1_lq_instr_i0_vld_offset + `THREADS - 1]),
								     .din(rv1_lq_instr_i0_vld_d),
								     .dout(rv1_lq_instr_i0_vld_q)
								     );



   tri_rlmlatch_p #(.INIT(0))
rv1_lq_instr_i0_rte_lq_reg(
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
							 .scin(siv[rv1_lq_instr_i0_rte_lq_offset]),
							 .scout(sov[rv1_lq_instr_i0_rte_lq_offset]),
							 .din(rv1_lq_instr_i0_rte_lq_d),
							 .dout(rv1_lq_instr_i0_rte_lq_q)
							 );


   tri_rlmlatch_p #(.INIT(0))
rv1_lq_instr_i0_rte_sq_reg(
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
							 .scin(siv[rv1_lq_instr_i0_rte_sq_offset]),
							 .scout(sov[rv1_lq_instr_i0_rte_sq_offset]),
							 .din(rv1_lq_instr_i0_rte_sq_d),
							 .dout(rv1_lq_instr_i0_rte_sq_q)
							 );

   tri_rlmlatch_p #(.INIT(0))
   rv1_lq_instr_i0_ucode_preissue_reg(
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
							 .scin(siv[rv1_lq_instr_i0_ucode_preissue_offset]),
							 .scout(sov[rv1_lq_instr_i0_ucode_preissue_offset]),
							 .din(rv1_lq_instr_i0_ucode_preissue_d),
							 .dout(rv1_lq_instr_i0_ucode_preissue_q)
							 );
   tri_rlmlatch_p #(.INIT(0))
   rv1_lq_instr_i0_2ucode_reg(
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
							 .scin(siv[rv1_lq_instr_i0_2ucode_offset]),
							 .scout(sov[rv1_lq_instr_i0_2ucode_offset]),
							 .din(rv1_lq_instr_i0_2ucode_d),
							 .dout(rv1_lq_instr_i0_2ucode_q)
							 );

   tri_rlmreg_p #(.INIT(0), .WIDTH(`UCODE_ENTRIES_ENC))
   rv1_lq_instr_i0_ucode_cnt_reg(
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
							 .scin(siv[rv1_lq_instr_i0_ucode_cnt_offset:rv1_lq_instr_i0_ucode_cnt_offset+`UCODE_ENTRIES_ENC-1]),
							 .scout(sov[rv1_lq_instr_i0_ucode_cnt_offset:rv1_lq_instr_i0_ucode_cnt_offset+`UCODE_ENTRIES_ENC-1]),
							 .din(rv1_lq_instr_i0_ucode_cnt_d),
							 .dout(rv1_lq_instr_i0_ucode_cnt_q)
							 );

      tri_rlmreg_p #(.INIT(0), .WIDTH(3))
   rv1_lq_instr_i0_s3_t_reg(
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
							 .scin(siv[rv1_lq_instr_i0_s3_t_offset:rv1_lq_instr_i0_s3_t_offset+3-1]),
							 .scout(sov[rv1_lq_instr_i0_s3_t_offset:rv1_lq_instr_i0_s3_t_offset+3-1]),
							 .din(rv1_lq_instr_i0_s3_t_d),
							 .dout(rv1_lq_instr_i0_s3_t_q)
							 );

   tri_rlmlatch_p #(.INIT(0))
   rv1_lq_instr_i0_isLoad_reg(
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
							 .scin(siv[rv1_lq_instr_i0_isLoad_offset]),
							 .scout(sov[rv1_lq_instr_i0_isLoad_offset]),
							 .din(rv1_lq_instr_i0_isLoad_d),
							 .dout(rv1_lq_instr_i0_isLoad_q)
							 );
   tri_rlmlatch_p #(.INIT(0))
   rv1_lq_instr_i0_isStore_reg(
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
							 .scin(siv[rv1_lq_instr_i0_isStore_offset]),
							 .scout(sov[rv1_lq_instr_i0_isStore_offset]),
							 .din(rv1_lq_instr_i0_isStore_d),
							 .dout(rv1_lq_instr_i0_isStore_q)
							 );

      tri_rlmreg_p #(.INIT(0), .WIDTH(`ITAG_SIZE_ENC))
   rv1_lq_instr_i0_itag_reg(
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
							 .scin(siv[rv1_lq_instr_i0_itag_offset:rv1_lq_instr_i0_itag_offset+`ITAG_SIZE_ENC-1]),
							 .scout(sov[rv1_lq_instr_i0_itag_offset:rv1_lq_instr_i0_itag_offset+`ITAG_SIZE_ENC-1]),
							 .din(rv1_lq_instr_i0_itag_d),
							 .dout(rv1_lq_instr_i0_itag_q)
							 );

      tri_rlmreg_p #(.INIT(0), .WIDTH(`PF_IAR_BITS))
   rv1_lq_instr_i0_ifar_reg(
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
							 .scin(siv[rv1_lq_instr_i0_ifar_offset:rv1_lq_instr_i0_ifar_offset+`PF_IAR_BITS-1]),
							 .scout(sov[rv1_lq_instr_i0_ifar_offset:rv1_lq_instr_i0_ifar_offset+`PF_IAR_BITS-1]),
							 .din(rv1_lq_instr_i0_ifar_d),
							 .dout(rv1_lq_instr_i0_ifar_q)
							 );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0))
rv1_lq_instr_i1_vld_reg(
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
								     .scin(siv[rv1_lq_instr_i1_vld_offset:rv1_lq_instr_i1_vld_offset + `THREADS - 1]),
								     .scout(sov[rv1_lq_instr_i1_vld_offset:rv1_lq_instr_i1_vld_offset + `THREADS - 1]),
								     .din(rv1_lq_instr_i1_vld_d),
								     .dout(rv1_lq_instr_i1_vld_q)
								     );



   tri_rlmlatch_p #(.INIT(0))
 rv1_lq_instr_i1_rte_lq_reg(
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
							 .scin(siv[rv1_lq_instr_i1_rte_lq_offset]),
							 .scout(sov[rv1_lq_instr_i1_rte_lq_offset]),
							 .din(rv1_lq_instr_i1_rte_lq_d),
							 .dout(rv1_lq_instr_i1_rte_lq_q)
							 );


   tri_rlmlatch_p #(.INIT(0))
rv1_lq_instr_i1_rte_sq_reg(
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
							 .scin(siv[rv1_lq_instr_i1_rte_sq_offset]),
							 .scout(sov[rv1_lq_instr_i1_rte_sq_offset]),
							 .din(rv1_lq_instr_i1_rte_sq_d),
							 .dout(rv1_lq_instr_i1_rte_sq_q)
							 );

   tri_rlmlatch_p #(.INIT(0))
   rv1_lq_instr_i1_ucode_preissue_reg(
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
							 .scin(siv[rv1_lq_instr_i1_ucode_preissue_offset]),
							 .scout(sov[rv1_lq_instr_i1_ucode_preissue_offset]),
							 .din(rv1_lq_instr_i1_ucode_preissue_d),
							 .dout(rv1_lq_instr_i1_ucode_preissue_q)
							 );
   tri_rlmlatch_p #(.INIT(0))
   rv1_lq_instr_i1_2ucode_reg(
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
							 .scin(siv[rv1_lq_instr_i1_2ucode_offset]),
							 .scout(sov[rv1_lq_instr_i1_2ucode_offset]),
							 .din(rv1_lq_instr_i1_2ucode_d),
							 .dout(rv1_lq_instr_i1_2ucode_q)
							 );

   tri_rlmreg_p #(.INIT(0), .WIDTH(`UCODE_ENTRIES_ENC))
   rv1_lq_instr_i1_ucode_cnt_reg(
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
							 .scin(siv[rv1_lq_instr_i1_ucode_cnt_offset:rv1_lq_instr_i1_ucode_cnt_offset+`UCODE_ENTRIES_ENC-1]),
							 .scout(sov[rv1_lq_instr_i1_ucode_cnt_offset:rv1_lq_instr_i1_ucode_cnt_offset+`UCODE_ENTRIES_ENC-1]),
							 .din(rv1_lq_instr_i1_ucode_cnt_d),
							 .dout(rv1_lq_instr_i1_ucode_cnt_q)
							 );

      tri_rlmreg_p #(.INIT(0), .WIDTH(3))
   rv1_lq_instr_i1_s3_t_reg(
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
							 .scin(siv[rv1_lq_instr_i1_s3_t_offset:rv1_lq_instr_i1_s3_t_offset+3-1]),
							 .scout(sov[rv1_lq_instr_i1_s3_t_offset:rv1_lq_instr_i1_s3_t_offset+3-1]),
							 .din(rv1_lq_instr_i1_s3_t_d),
							 .dout(rv1_lq_instr_i1_s3_t_q)
							 );

   tri_rlmlatch_p #(.INIT(0))
   rv1_lq_instr_i1_isLoad_reg(
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
							 .scin(siv[rv1_lq_instr_i1_isLoad_offset]),
							 .scout(sov[rv1_lq_instr_i1_isLoad_offset]),
							 .din(rv1_lq_instr_i1_isLoad_d),
							 .dout(rv1_lq_instr_i1_isLoad_q)
							 );
   tri_rlmlatch_p #(.INIT(0))
   rv1_lq_instr_i1_isStore_reg(
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
							 .scin(siv[rv1_lq_instr_i1_isStore_offset]),
							 .scout(sov[rv1_lq_instr_i1_isStore_offset]),
							 .din(rv1_lq_instr_i1_isStore_d),
							 .dout(rv1_lq_instr_i1_isStore_q)
							 );

      tri_rlmreg_p #(.INIT(0), .WIDTH(`ITAG_SIZE_ENC))
   rv1_lq_instr_i1_itag_reg(
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
							 .scin(siv[rv1_lq_instr_i1_itag_offset:rv1_lq_instr_i1_itag_offset+`ITAG_SIZE_ENC-1]),
							 .scout(sov[rv1_lq_instr_i1_itag_offset:rv1_lq_instr_i1_itag_offset+`ITAG_SIZE_ENC-1]),
							 .din(rv1_lq_instr_i1_itag_d),
							 .dout(rv1_lq_instr_i1_itag_q)
							 );

      tri_rlmreg_p #(.INIT(0), .WIDTH(`PF_IAR_BITS))
   rv1_lq_instr_i1_ifar_reg(
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
							 .scin(siv[rv1_lq_instr_i1_ifar_offset:rv1_lq_instr_i1_ifar_offset+`PF_IAR_BITS-1]),
							 .scout(sov[rv1_lq_instr_i1_ifar_offset:rv1_lq_instr_i1_ifar_offset+`PF_IAR_BITS-1]),
							 .din(rv1_lq_instr_i1_ifar_d),
							 .dout(rv1_lq_instr_i1_ifar_q)
							 );


   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
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
				       .din({func_sl_thold_1,sg_1}),
				       .q({func_sl_thold_0,sg_0})
				       );


   tri_lcbor  perv_lcbor(
			 .clkoff_b(clkoff_b),
			 .thold(func_sl_thold_0),
			 .sg(sg_0),
			 .act_dis(act_dis),
			 .force_t(force_t),
			 .thold_b(func_sl_thold_0_b)
			 );


endmodule
