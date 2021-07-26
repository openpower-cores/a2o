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
// Title:   rv.vhdl
// Desc:       top level of Reservation station heirarchy.
//             contains reservation stations for the three main fixed point functional units
//             as well as the operand available scorecard and associated inline compare logic.
//
// Notes:
//          All indexes are assumed to be physical register indices
//
//          Interface to the fetcher is actual instruction, renamed physical register fields, 20 bits of ifar, and 20 bits of
//             the bta.  Lots of bits.
//
//-----------------------------------------------------------------------------------------------------

(* recursive_synthesis="0" *)

module rv(
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
	  input [0:`EFF_IFAR_WIDTH-1] 	      iu_rv_iu6_t0_i0_bta,
	  input                               iu_rv_iu6_t0_i0_bta_val,
	  input                               iu_rv_iu6_t0_i0_br_pred,
	  input [0:`EFF_IFAR_WIDTH-1]         iu_rv_iu6_t0_i0_fusion,
	  input [0:2]                         iu_rv_iu6_t0_i0_ls_ptr,
	  input [0:17]                         iu_rv_iu6_t0_i0_gshare,
	  input                               iu_rv_iu6_t0_i0_bh_update,
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
	  input [0:`EFF_IFAR_WIDTH-1] 	      iu_rv_iu6_t0_i1_bta,
	  input                               iu_rv_iu6_t0_i1_bta_val,
	  input                               iu_rv_iu6_t0_i1_br_pred,
	  input [0:`EFF_IFAR_WIDTH-1]         iu_rv_iu6_t0_i1_fusion,
	  input [0:2]                         iu_rv_iu6_t0_i1_ls_ptr,
	  input [0:17]                         iu_rv_iu6_t0_i1_gshare,
	  input                               iu_rv_iu6_t0_i1_bh_update,
	  input 			      iu_rv_iu6_t0_i1_isLoad,
	  input 			      iu_rv_iu6_t0_i1_isStore,
	  input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t0_i1_s1_itag,
	  input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t0_i1_s2_itag,
	  input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t0_i1_s3_itag,
	  input                               iu_rv_iu6_t0_i1_s1_dep_hit,
	  input                               iu_rv_iu6_t0_i1_s2_dep_hit,
	  input                               iu_rv_iu6_t0_i1_s3_dep_hit,
	  input [0:`ITAG_SIZE_ENC-1]          cp_t0_next_itag,

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
	  input [0:`EFF_IFAR_WIDTH-1] 	      iu_rv_iu6_t1_i0_bta,
	  input                               iu_rv_iu6_t1_i0_bta_val,
	  input                               iu_rv_iu6_t1_i0_br_pred,
	  input [0:`EFF_IFAR_WIDTH-1]         iu_rv_iu6_t1_i0_fusion,
	  input [0:2]                         iu_rv_iu6_t1_i0_ls_ptr,
	  input [0:17]                         iu_rv_iu6_t1_i0_gshare,
	  input                               iu_rv_iu6_t1_i0_bh_update,
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
	  input [0:`EFF_IFAR_WIDTH-1] 	      iu_rv_iu6_t1_i1_bta,
	  input                               iu_rv_iu6_t1_i1_bta_val,
	  input                               iu_rv_iu6_t1_i1_br_pred,
	  input [0:`EFF_IFAR_WIDTH-1]         iu_rv_iu6_t1_i1_fusion,
	  input [0:2]                         iu_rv_iu6_t1_i1_ls_ptr,
	  input [0:17]                         iu_rv_iu6_t1_i1_gshare,
	  input                               iu_rv_iu6_t1_i1_bh_update,
	  input 			      iu_rv_iu6_t1_i1_isLoad,
	  input 			      iu_rv_iu6_t1_i1_isStore,
	  input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t1_i1_s1_itag,
	  input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t1_i1_s2_itag,
	  input [0:`ITAG_SIZE_ENC-1] 	      iu_rv_iu6_t1_i1_s3_itag,
	  input                               iu_rv_iu6_t1_i1_s1_dep_hit,
	  input                               iu_rv_iu6_t1_i1_s2_dep_hit,
	  input                               iu_rv_iu6_t1_i1_s3_dep_hit,

	  input [0:`ITAG_SIZE_ENC-1]          cp_t1_next_itag,
`endif

	  //------------------------------------------------------------------------------------------------------------
	  // Credit Interface with IU
	  //------------------------------------------------------------------------------------------------------------
	  output [0:`THREADS-1]                           rv_iu_lq_credit_free,
	  output [0:`THREADS-1]                           rv_iu_fx0_credit_free,
	  output [0:`THREADS-1]                           rv_iu_fx1_credit_free,
	  output [0:`THREADS-1]                           rv_iu_axu0_credit_free,
	  output [0:`THREADS-1]                           rv_iu_axu1_credit_free,

	  //------------------------------------------------------------------------------------------------------------
	  // Machine zap interface
	  //------------------------------------------------------------------------------------------------------------
	  input [0:`THREADS-1]                            cp_flush,

	  //------------------------------------------------------------------------------------------------------------
	  // Interface to FX0
	  //------------------------------------------------------------------------------------------------------------
	  output [0:`THREADS-1]                           rv_fx0_vld,
	  output                                         rv_fx0_s1_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_fx0_s1_p,
	  output                                         rv_fx0_s2_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_fx0_s2_p,
	  output                                         rv_fx0_s3_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_fx0_s3_p,

	  output [0:`ITAG_SIZE_ENC-1]                     rv_fx0_ex0_itag,
	  output [0:31]                                  rv_fx0_ex0_instr,
	  output [62-`EFF_IFAR_WIDTH:61]                  rv_fx0_ex0_ifar,
	  output [0:2]                                   rv_fx0_ex0_ucode,
	  output [0:`UCODE_ENTRIES_ENC-1]                 rv_fx0_ex0_ucode_cnt,
	  output                                         rv_fx0_ex0_ord,
	  output                                         rv_fx0_ex0_t1_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_fx0_ex0_t1_p,
	  output [0:2]                                   rv_fx0_ex0_t1_t,
	  output                                         rv_fx0_ex0_t2_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_fx0_ex0_t2_p,
	  output [0:2]                                   rv_fx0_ex0_t2_t,
	  output                                         rv_fx0_ex0_t3_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_fx0_ex0_t3_p,
	  output [0:2]                                   rv_fx0_ex0_t3_t,
	  output                                         rv_fx0_ex0_s1_v,
	  output                                         rv_fx0_ex0_s2_v,
	  output [0:2]                                   rv_fx0_ex0_s2_t,
	  output                                         rv_fx0_ex0_s3_v,
	  output [0:2]                                   rv_fx0_ex0_s3_t,
	  output [0:19]                                  rv_fx0_ex0_fusion,
	  output [62-`EFF_IFAR_WIDTH:61]                  rv_fx0_ex0_pred_bta,
	  output                                         rv_fx0_ex0_bta_val,
	  output                                         rv_fx0_ex0_br_pred,
	  output [0:2]                                   rv_fx0_ex0_ls_ptr,
	  output [0:17]                                   rv_fx0_ex0_gshare,
	  output                                         rv_fx0_ex0_bh_update,

	  input                                          fx0_rv_ord_complete,
	  input [0:`ITAG_SIZE_ENC-1]                      fx0_rv_ord_itag,
	  input                                          fx0_rv_hold_all,

	  //------------------------------------------------------------------------------------------------------------
	  // Interface to FX1
	  //------------------------------------------------------------------------------------------------------------
	  output [0:`THREADS-1]                           rv_fx1_vld,
	  output                                         rv_fx1_s1_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_fx1_s1_p,
	  output                                         rv_fx1_s2_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_fx1_s2_p,
	  output                                         rv_fx1_s3_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_fx1_s3_p,

	  output [0:`ITAG_SIZE_ENC-1]                     rv_fx1_ex0_itag,
	  output [0:31]                                  rv_fx1_ex0_instr,
	  output [0:2]                                   rv_fx1_ex0_ucode,
	  output                                         rv_fx1_ex0_t1_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_fx1_ex0_t1_p,
	  output                                         rv_fx1_ex0_t2_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_fx1_ex0_t2_p,
	  output                                         rv_fx1_ex0_t3_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_fx1_ex0_t3_p,
	  output                                         rv_fx1_ex0_s1_v,
	  output [0:2]                                   rv_fx1_ex0_s3_t,
	  output                                         rv_fx1_ex0_isStore,

	  input                                          fx1_rv_hold_all,

	  //------------------------------------------------------------------------------------------------------------
	  // Interface to LQ
	  //------------------------------------------------------------------------------------------------------------
	  output [0:`THREADS-1]                           rv_lq_vld,
	  output                                         rv_lq_isLoad,

	  output [0:`ITAG_SIZE_ENC-1]                     rv_lq_ex0_itag,
	  output [0:31]                                  rv_lq_ex0_instr,
	  output [0:2]                                   rv_lq_ex0_ucode,
	  output [0:`UCODE_ENTRIES_ENC-1]                 rv_lq_ex0_ucode_cnt,
	  output                                         rv_lq_ex0_spec,
	  output                                         rv_lq_ex0_t1_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_lq_ex0_t1_p,
	  output [0:`GPR_POOL_ENC-1]                      rv_lq_ex0_t3_p,
	  output                                         rv_lq_ex0_s1_v,
	  output                                         rv_lq_ex0_s2_v,
	  output [0:2]                                   rv_lq_ex0_s2_t,

	  input [0:`THREADS-1]                            lq_rv_itag0_vld,
	  input [0:`ITAG_SIZE_ENC-1]                      lq_rv_itag0,
	  input                                          lq_rv_itag0_abort,

	  input [0:`THREADS-1]                            lq_rv_itag1_vld,
	  input [0:`ITAG_SIZE_ENC-1]                      lq_rv_itag1,
	  input                                          lq_rv_itag1_abort,
	  input                                          lq_rv_itag1_restart,
	  input                                          lq_rv_itag1_hold,
	  input                                          lq_rv_itag1_cord,

	  input [0:`THREADS-1]                            lq_rv_itag2_vld,
	  input [0:`ITAG_SIZE_ENC-1]                      lq_rv_itag2,

	  input [0:`THREADS-1]                            lq_rv_clr_hold,

	  input                                          lq_rv_ord_complete,
	  input                                          lq_rv_hold_all,

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

	  output [0:`THREADS-1]                           rv_lq_rvs_empty,

	  //------------------------------------------------------------------------------------------------------------
	  // Interface to AXU0
	  //------------------------------------------------------------------------------------------------------------
	  output [0:`THREADS-1]                           rv_axu0_vld,
	  output                                         rv_axu0_s1_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_axu0_s1_p,
	  output                                         rv_axu0_s2_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_axu0_s2_p,
	  output                                         rv_axu0_s3_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_axu0_s3_p,

	  output [0:`ITAG_SIZE_ENC-1]                     rv_axu0_ex0_itag,
	  output [0:31]                                  rv_axu0_ex0_instr,
	  output [0:2]                                   rv_axu0_ex0_ucode,
	  output                                         rv_axu0_ex0_t1_v,
	  output [0:`GPR_POOL_ENC-1]                      rv_axu0_ex0_t1_p,
	  output [0:`GPR_POOL_ENC-1]                      rv_axu0_ex0_t2_p,
	  output [0:`GPR_POOL_ENC-1]                      rv_axu0_ex0_t3_p,

	  input [0:`THREADS-1]                            axu0_rv_itag_vld,
	  input [0:`ITAG_SIZE_ENC-1]                      axu0_rv_itag,
	  input                                           axu0_rv_itag_abort,

	  input                                          axu0_rv_ord_complete,
	  input                                          axu0_rv_hold_all,

	  //------------------------------------------------------------------------------------------------------------
	  // Interface to AXU1
	  //------------------------------------------------------------------------------------------------------------

	  input [0:`THREADS-1]                            axu1_rv_itag_vld,
	  input [0:`ITAG_SIZE_ENC-1]                      axu1_rv_itag,
	  input                                           axu1_rv_itag_abort,
	  input                                          axu1_rv_hold_all,

	  //------------------------------------------------------------------------------------------------------------
	  // Abort Mechanism
	  //------------------------------------------------------------------------------------------------------------
	  input                                           lq_rv_ex2_s1_abort,
	  input                                           lq_rv_ex2_s2_abort,
	  input                                           fx0_rv_ex2_s1_abort,
	  input                                           fx0_rv_ex2_s2_abort,
	  input                                           fx0_rv_ex2_s3_abort,
	  input                                           fx1_rv_ex2_s1_abort,
	  input                                           fx1_rv_ex2_s2_abort,
	  input                                           fx1_rv_ex2_s3_abort,
	  input                                           axu0_rv_ex2_s1_abort,
	  input                                           axu0_rv_ex2_s2_abort,
	  input                                           axu0_rv_ex2_s3_abort,

	  //------------------------------------------------------------------------------------------------------------
	  // Bypass Control
	  //------------------------------------------------------------------------------------------------------------
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

	  //------------------------------------------------------------------------------------------------------------
	  // LQ Regfile
	  //------------------------------------------------------------------------------------------------------------
	  // Write ports
	  input                                          xu0_gpr_ex6_we,
	  input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]       xu0_gpr_ex6_wa,
	  input [64-`GPR_WIDTH:63+(`GPR_WIDTH/8)]          xu0_gpr_ex6_wd,
	  input                                          xu1_gpr_ex3_we,
	  input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]       xu1_gpr_ex3_wa,
	  input [64-`GPR_WIDTH:63+(`GPR_WIDTH/8)]          xu1_gpr_ex3_wd,

	  input                                          lq_rv_gpr_ex6_we,
	  input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]       lq_rv_gpr_ex6_wa,
	  input [64-`GPR_WIDTH:63+(`GPR_WIDTH/8)]          lq_rv_gpr_ex6_wd,

	  input                                          lq_rv_gpr_rel_we,
	  input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]       lq_rv_gpr_rel_wa,
	  input [64-`GPR_WIDTH:63+(`GPR_WIDTH/8)]          lq_rv_gpr_rel_wd,

	  // Read ports
	  output [64-`GPR_WIDTH:63+(`GPR_WIDTH/8)]         rv_lq_gpr_ex1_r0d,
	  output [64-`GPR_WIDTH:63+(`GPR_WIDTH/8)]         rv_lq_gpr_ex1_r1d,

	  //------------------------------------------------------------------------------------------------------------
	  // Debug and Perf
	  //------------------------------------------------------------------------------------------------------------
	  input                                          pc_rv_trace_bus_enable,
	  input [0:10]  				 pc_rv_debug_mux_ctrls,
	  input                                          pc_rv_event_bus_enable,
	  input [0:2] 				         pc_rv_event_count_mode,
	  input [0:39]                                   pc_rv_event_mux_ctrls,
	  input [0:4*`THREADS-1]                         rv_event_bus_in,
	  output [0:4*`THREADS-1]                        rv_event_bus_out,
	  output [0:31]             	                 debug_bus_out,
	  input  [0:31]             	                 debug_bus_in,
	  input  [0:3]		                         coretrace_ctrls_in,
	  output [0:3]		    	                 coretrace_ctrls_out,
          input [0:`THREADS-1]                           spr_msr_gs,
          input [0:`THREADS-1]                           spr_msr_pr,
	  //------------------------------------------------------------------------------------------------------------
	  // Pervasive
	  //------------------------------------------------------------------------------------------------------------
	  (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) // nclk
	  input[0:`NCLK_WIDTH-1]                         nclk,

	  input                                          rp_rv_ccflush_dc,
	  input                                          rp_rv_func_sl_thold_3,
	  input                                          rp_rv_gptr_sl_thold_3,
	  input                                          rp_rv_sg_3,
	  input                                          rp_rv_fce_3,
	  input                                          an_ac_scan_diag_dc,
	  input                                          an_ac_scan_dis_dc_b,

	  (* pin_data="PIN_FUNCTION=/SCAN_IN/" *) // scan_in
	  input                                          scan_in,
	  (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) // scan_out
	  output                                         scan_out

	  );

   wire [0:`THREADS*`ITAG_SIZE_ENC-1] 			 cp_next_itag;
   wire [0:`G_BRANCH_LEN-1]				 iu_rv_iu6_t0_i0_branch;
   wire [0:`G_BRANCH_LEN-1]				 iu_rv_iu6_t0_i1_branch;
`ifndef THREADS1
   wire [0:`G_BRANCH_LEN-1]				 iu_rv_iu6_t1_i0_branch;
   wire [0:`G_BRANCH_LEN-1]				 iu_rv_iu6_t1_i1_branch;
`endif
   wire [0:`G_BRANCH_LEN-1] 				 rv_fx0_ex0_branch;


   wire [0:`THREADS-1] 					 rv0_fx0_instr_i0_vld;
   wire 						 rv0_fx0_instr_i0_rte_fx0;
   wire [0:31] 						 rv0_fx0_instr_i0_instr;
   wire [62-`EFF_IFAR_WIDTH:61] 			 rv0_fx0_instr_i0_ifar;
   wire [0:2] 						 rv0_fx0_instr_i0_ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] 			 rv0_fx0_instr_i0_ucode_cnt;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx0_instr_i0_itag;
   wire 						 rv0_fx0_instr_i0_ord;
   wire 						 rv0_fx0_instr_i0_cord;
   wire 						 rv0_fx0_instr_i0_t1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx0_instr_i0_t1_p;
   wire [0:2] 						 rv0_fx0_instr_i0_t1_t;
   wire 						 rv0_fx0_instr_i0_t2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx0_instr_i0_t2_p;
   wire [0:2] 						 rv0_fx0_instr_i0_t2_t;
   wire 						 rv0_fx0_instr_i0_t3_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx0_instr_i0_t3_p;
   wire [0:2] 						 rv0_fx0_instr_i0_t3_t;
   wire 						 rv0_fx0_instr_i0_s1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx0_instr_i0_s1_p;
   wire [0:2] 						 rv0_fx0_instr_i0_s1_t;
   wire 						 rv0_fx0_instr_i0_s2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx0_instr_i0_s2_p;
   wire [0:2] 						 rv0_fx0_instr_i0_s2_t;
   wire 						 rv0_fx0_instr_i0_s3_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx0_instr_i0_s3_p;
   wire [0:2] 						 rv0_fx0_instr_i0_s3_t;
   wire [0:3] 						 rv0_fx0_instr_i0_ilat;
   wire [0:`G_BRANCH_LEN-1] 				 rv0_fx0_instr_i0_branch;
   wire [0:3] 						 rv0_fx0_instr_i0_spare;
   wire 						 rv0_fx0_instr_i0_is_brick;
   wire [0:2] 						 rv0_fx0_instr_i0_brick;
   wire [0:`THREADS-1] 					 rv0_fx0_instr_i1_vld;
   wire 						 rv0_fx0_instr_i1_rte_fx0;
   wire [0:31] 						 rv0_fx0_instr_i1_instr;
   wire [62-`EFF_IFAR_WIDTH:61] 			 rv0_fx0_instr_i1_ifar;
   wire [0:2] 						 rv0_fx0_instr_i1_ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] 			 rv0_fx0_instr_i1_ucode_cnt;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx0_instr_i1_itag;
   wire 						 rv0_fx0_instr_i1_ord;
   wire 						 rv0_fx0_instr_i1_cord;
   wire 						 rv0_fx0_instr_i1_t1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx0_instr_i1_t1_p;
   wire [0:2] 						 rv0_fx0_instr_i1_t1_t;
   wire 						 rv0_fx0_instr_i1_t2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx0_instr_i1_t2_p;
   wire [0:2] 						 rv0_fx0_instr_i1_t2_t;
   wire 						 rv0_fx0_instr_i1_t3_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx0_instr_i1_t3_p;
   wire [0:2] 						 rv0_fx0_instr_i1_t3_t;
   wire 						 rv0_fx0_instr_i1_s1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx0_instr_i1_s1_p;
   wire [0:2] 						 rv0_fx0_instr_i1_s1_t;
   wire 						 rv0_fx0_instr_i1_s2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx0_instr_i1_s2_p;
   wire [0:2] 						 rv0_fx0_instr_i1_s2_t;
   wire 						 rv0_fx0_instr_i1_s3_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx0_instr_i1_s3_p;
   wire [0:2] 						 rv0_fx0_instr_i1_s3_t;
   wire [0:3] 						 rv0_fx0_instr_i1_ilat;
   wire [0:`G_BRANCH_LEN-1] 				 rv0_fx0_instr_i1_branch;
   wire [0:3] 						 rv0_fx0_instr_i1_spare;
   wire 						 rv0_fx0_instr_i1_is_brick;
   wire [0:2] 						 rv0_fx0_instr_i1_brick;
   wire 						 rv0_fx0_instr_i0_s1_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx0_instr_i0_s1_itag;
   wire 						 rv0_fx0_instr_i0_s2_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx0_instr_i0_s2_itag;
   wire 						 rv0_fx0_instr_i0_s3_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx0_instr_i0_s3_itag;
   wire 						 rv0_fx0_instr_i1_s1_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx0_instr_i1_s1_itag;
   wire 						 rv0_fx0_instr_i1_s2_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx0_instr_i1_s2_itag;
   wire 						 rv0_fx0_instr_i1_s3_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx0_instr_i1_s3_itag;
   wire [0:`THREADS-1] 					 rv0_fx1_instr_i0_vld;
   wire 						 rv0_fx1_instr_i0_rte_fx1;
   wire [0:31] 						 rv0_fx1_instr_i0_instr;
   wire [0:2] 						 rv0_fx1_instr_i0_ucode;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx1_instr_i0_itag;
   wire 						 rv0_fx1_instr_i0_t1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx1_instr_i0_t1_p;
   wire 						 rv0_fx1_instr_i0_t2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx1_instr_i0_t2_p;
   wire 						 rv0_fx1_instr_i0_t3_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx1_instr_i0_t3_p;
   wire 						 rv0_fx1_instr_i0_s1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx1_instr_i0_s1_p;
   wire [0:2] 						 rv0_fx1_instr_i0_s1_t;
   wire 						 rv0_fx1_instr_i0_s2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx1_instr_i0_s2_p;
   wire [0:2] 						 rv0_fx1_instr_i0_s2_t;
   wire 						 rv0_fx1_instr_i0_s3_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx1_instr_i0_s3_p;
   wire [0:2] 						 rv0_fx1_instr_i0_s3_t;
   wire [0:3] 						 rv0_fx1_instr_i0_ilat;
   wire 						 rv0_fx1_instr_i0_isStore;
   wire [0:3] 						 rv0_fx1_instr_i0_spare;
   wire 						 rv0_fx1_instr_i0_is_brick;
   wire [0:2] 						 rv0_fx1_instr_i0_brick;
   wire [0:`THREADS-1] 					 rv0_fx1_instr_i1_vld;
   wire 						 rv0_fx1_instr_i1_rte_fx1;
   wire [0:31] 						 rv0_fx1_instr_i1_instr;
   wire [0:2] 						 rv0_fx1_instr_i1_ucode;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx1_instr_i1_itag;
   wire 						 rv0_fx1_instr_i1_t1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx1_instr_i1_t1_p;
   wire 						 rv0_fx1_instr_i1_t2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx1_instr_i1_t2_p;
   wire 						 rv0_fx1_instr_i1_t3_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx1_instr_i1_t3_p;
   wire 						 rv0_fx1_instr_i1_s1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx1_instr_i1_s1_p;
   wire [0:2] 						 rv0_fx1_instr_i1_s1_t;
   wire 						 rv0_fx1_instr_i1_s2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx1_instr_i1_s2_p;
   wire [0:2] 						 rv0_fx1_instr_i1_s2_t;
   wire 						 rv0_fx1_instr_i1_s3_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_fx1_instr_i1_s3_p;
   wire [0:2] 						 rv0_fx1_instr_i1_s3_t;
   wire [0:3] 						 rv0_fx1_instr_i1_ilat;
   wire 						 rv0_fx1_instr_i1_isStore;
   wire [0:3] 						 rv0_fx1_instr_i1_spare;
   wire 						 rv0_fx1_instr_i1_is_brick;
   wire [0:2] 						 rv0_fx1_instr_i1_brick;
   wire 						 rv0_fx1_instr_i0_s1_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx1_instr_i0_s1_itag;
   wire 						 rv0_fx1_instr_i0_s2_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx1_instr_i0_s2_itag;
   wire 						 rv0_fx1_instr_i0_s3_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx1_instr_i0_s3_itag;
   wire 						 rv0_fx1_instr_i1_s1_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx1_instr_i1_s1_itag;
   wire 						 rv0_fx1_instr_i1_s2_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx1_instr_i1_s2_itag;
   wire 						 rv0_fx1_instr_i1_s3_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_fx1_instr_i1_s3_itag;
   wire [0:`THREADS-1] 					 rv0_lq_instr_i0_vld;
   wire 						 rv0_lq_instr_i0_rte_lq;
   wire [0:31] 						 rv0_lq_instr_i0_instr;
   wire [0:2] 						 rv0_lq_instr_i0_ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] 			 rv0_lq_instr_i0_ucode_cnt;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_lq_instr_i0_itag;
   wire 						 rv0_lq_instr_i0_ord;
   wire 						 rv0_lq_instr_i0_cord;
   wire 						 rv0_lq_instr_i0_spec;
   wire 						 rv0_lq_instr_i0_t1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_lq_instr_i0_t1_p;
   wire 						 rv0_lq_instr_i0_t2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_lq_instr_i0_t2_p;
   wire [0:2] 						 rv0_lq_instr_i0_t2_t;
   wire 						 rv0_lq_instr_i0_t3_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_lq_instr_i0_t3_p;
   wire [0:2] 						 rv0_lq_instr_i0_t3_t;
   wire 						 rv0_lq_instr_i0_s1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_lq_instr_i0_s1_p;
   wire [0:2] 						 rv0_lq_instr_i0_s1_t;
   wire 						 rv0_lq_instr_i0_s2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_lq_instr_i0_s2_p;
   wire [0:2] 						 rv0_lq_instr_i0_s2_t;
   wire 						 rv0_lq_instr_i0_isLoad;
   wire [0:3] 						 rv0_lq_instr_i0_spare;
   wire 						 rv0_lq_instr_i0_is_brick;
   wire [0:2] 						 rv0_lq_instr_i0_brick;
   wire [0:`THREADS-1] 					 rv0_lq_instr_i1_vld;
   wire 						 rv0_lq_instr_i1_rte_lq;
   wire [0:31] 						 rv0_lq_instr_i1_instr;
   wire [0:2] 						 rv0_lq_instr_i1_ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] 			 rv0_lq_instr_i1_ucode_cnt;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_lq_instr_i1_itag;
   wire 						 rv0_lq_instr_i1_ord;
   wire 						 rv0_lq_instr_i1_cord;
   wire 						 rv0_lq_instr_i1_spec;
   wire 						 rv0_lq_instr_i1_t1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_lq_instr_i1_t1_p;
   wire 						 rv0_lq_instr_i1_t2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_lq_instr_i1_t2_p;
   wire [0:2] 						 rv0_lq_instr_i1_t2_t;
   wire 						 rv0_lq_instr_i1_t3_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_lq_instr_i1_t3_p;
   wire [0:2] 						 rv0_lq_instr_i1_t3_t;
   wire 						 rv0_lq_instr_i1_s1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_lq_instr_i1_s1_p;
   wire [0:2] 						 rv0_lq_instr_i1_s1_t;
   wire 						 rv0_lq_instr_i1_s2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_lq_instr_i1_s2_p;
   wire [0:2] 						 rv0_lq_instr_i1_s2_t;
   wire 						 rv0_lq_instr_i1_isLoad;
   wire [0:3] 						 rv0_lq_instr_i1_spare;
   wire 						 rv0_lq_instr_i1_is_brick;
   wire [0:2] 						 rv0_lq_instr_i1_brick;
   wire 						 rv0_lq_instr_i0_s1_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_lq_instr_i0_s1_itag;
   wire 						 rv0_lq_instr_i0_s2_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_lq_instr_i0_s2_itag;
   wire 						 rv0_lq_instr_i1_s1_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_lq_instr_i1_s1_itag;
   wire 						 rv0_lq_instr_i1_s2_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_lq_instr_i1_s2_itag;
   wire [0:`THREADS-1] 					 rv0_axu0_instr_i0_vld;
   wire 						 rv0_axu0_instr_i0_rte_axu0;
   wire [0:31] 						 rv0_axu0_instr_i0_instr;
   wire [0:2] 						 rv0_axu0_instr_i0_ucode;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_axu0_instr_i0_itag;
   wire 						 rv0_axu0_instr_i0_ord;
   wire 						 rv0_axu0_instr_i0_cord;
   wire 						 rv0_axu0_instr_i0_t1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_axu0_instr_i0_t1_p;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_axu0_instr_i0_t2_p;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_axu0_instr_i0_t3_p;
   wire 						 rv0_axu0_instr_i0_s1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_axu0_instr_i0_s1_p;
   wire 						 rv0_axu0_instr_i0_s2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_axu0_instr_i0_s2_p;
   wire 						 rv0_axu0_instr_i0_s3_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_axu0_instr_i0_s3_p;
   wire 						 rv0_axu0_instr_i0_isStore;
   wire [0:3] 						 rv0_axu0_instr_i0_spare;
   wire [0:`THREADS-1] 					 rv0_axu0_instr_i1_vld;
   wire 						 rv0_axu0_instr_i1_rte_axu0;
   wire [0:31] 						 rv0_axu0_instr_i1_instr;
   wire [0:2] 						 rv0_axu0_instr_i1_ucode;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_axu0_instr_i1_itag;
   wire 						 rv0_axu0_instr_i1_ord;
   wire 						 rv0_axu0_instr_i1_cord;
   wire 						 rv0_axu0_instr_i1_t1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_axu0_instr_i1_t1_p;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_axu0_instr_i1_t2_p;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_axu0_instr_i1_t3_p;
   wire 						 rv0_axu0_instr_i1_s1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_axu0_instr_i1_s1_p;
   wire 						 rv0_axu0_instr_i1_s2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_axu0_instr_i1_s2_p;
   wire 						 rv0_axu0_instr_i1_s3_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv0_axu0_instr_i1_s3_p;
   wire 						 rv0_axu0_instr_i1_isStore;
   wire [0:3] 						 rv0_axu0_instr_i1_spare;
   wire 						 rv0_axu0_instr_i0_s1_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_axu0_instr_i0_s1_itag;
   wire 						 rv0_axu0_instr_i0_s2_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_axu0_instr_i0_s2_itag;
   wire 						 rv0_axu0_instr_i0_s3_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_axu0_instr_i0_s3_itag;
   wire 						 rv0_axu0_instr_i1_s1_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_axu0_instr_i1_s1_itag;
   wire 						 rv0_axu0_instr_i1_s2_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_axu0_instr_i1_s2_itag;
   wire 						 rv0_axu0_instr_i1_s3_dep_hit;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv0_axu0_instr_i1_s3_itag;

   //------------------------------------------------------------------------------------------------------------
   // Itag busses and shadow
   //------------------------------------------------------------------------------------------------------------

   wire [0:`THREADS-1] 					 fx0_rv_itag_vld;
   wire 						 fx0_rv_itag_abort;
   wire [0:`ITAG_SIZE_ENC-1] 				 fx0_rv_itag;
   wire [0:`THREADS-1] 					 fx0_rv_ext_itag_vld;
   wire 						 fx0_rv_ext_itag_abort;
   wire [0:`ITAG_SIZE_ENC-1] 				 fx0_rv_ext_itag;

   wire [0:`THREADS-1] 					 fx1_rv_itag_vld;
   wire 						 fx1_rv_itag_abort;
   wire [0:`ITAG_SIZE_ENC-1] 				 fx1_rv_itag;
   wire [0:`THREADS-1] 					 fx1_rv_ext_itag_vld;
   wire 						 fx1_rv_ext_itag_abort;
   wire [0:`ITAG_SIZE_ENC-1] 				 fx1_rv_ext_itag;

   //------------------------------------------------------------------------------------------------------------
   // Bypass
   //------------------------------------------------------------------------------------------------------------
   wire [0:`THREADS-1] 					 rv_byp_fx0_vld;		// FX0 Ports
   wire [0:`ITAG_SIZE_ENC-1] 				 rv_byp_fx0_itag;
   wire [0:3] 						 rv_byp_fx0_ilat;
   wire 						 rv_byp_fx0_ord;
   wire 						 rv_byp_fx0_t1_v;
   wire [0:2] 						 rv_byp_fx0_t1_t;
   wire 						 rv_byp_fx0_t2_v;
   wire [0:2] 						 rv_byp_fx0_t2_t;
   wire 						 rv_byp_fx0_t3_v;
   wire [0:2] 						 rv_byp_fx0_t3_t;
   wire [0:2] 						 rv_byp_fx0_s1_t;
   wire [0:2] 						 rv_byp_fx0_s2_t;
   wire [0:2] 						 rv_byp_fx0_s3_t;
   wire [0:`THREADS-1] 					 rv_byp_lq_vld;		// LQ Ports
   wire [0:`ITAG_SIZE_ENC-1] 				 rv_byp_lq_itag;		// LQ Ports
   wire [0:`ITAG_SIZE_ENC-1] 				 rv_byp_lq_ex0_s1_itag;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv_byp_lq_ex0_s2_itag;
   wire                                                  rv_byp_fx0_ex0_is_brick;

   wire 						 rv_byp_lq_t1_v;
   wire 						 rv_byp_lq_t3_v;
   wire [0:2] 						 rv_byp_lq_t3_t;
   wire                                                  rv_byp_lq_s1_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv_byp_lq_s1_p;
   wire [0:2] 						 rv_byp_lq_s1_t;
   wire                                                  rv_byp_lq_s2_v;
   wire [0:`GPR_POOL_ENC-1] 				 rv_byp_lq_s2_p;
   wire [0:2] 						 rv_byp_lq_s2_t;
   wire [0:`THREADS-1] 					 rv_byp_fx1_vld;		// FX0 Ports
   wire [0:`ITAG_SIZE_ENC-1] 				 rv_byp_fx1_itag;
   wire [0:3] 						 rv_byp_fx1_ilat;
   wire 						 rv_byp_fx1_t1_v;
   wire 						 rv_byp_fx1_t2_v;
   wire 						 rv_byp_fx1_t3_v;
   wire [0:2] 						 rv_byp_fx1_s1_t;
   wire [0:2] 						 rv_byp_fx1_s2_t;
   wire [0:2] 						 rv_byp_fx1_s3_t;

   wire [0:`ITAG_SIZE_ENC-1] 				 rv_byp_fx0_s1_itag;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv_byp_fx0_s2_itag;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv_byp_fx0_s3_itag;

   wire [0:`ITAG_SIZE_ENC-1] 				 rv_byp_fx1_s1_itag;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv_byp_fx1_s2_itag;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv_byp_fx1_s3_itag;
   wire 						 rv_byp_fx1_ex0_isStore;

   wire [0:`THREADS-1] 					 rv_byp_fx0_ilat0_vld;
   wire [0:`THREADS-1] 					 rv_byp_fx0_ilat1_vld;
   wire [0:`THREADS-1] 					 rv_byp_fx1_ilat0_vld;
   wire [0:`THREADS-1] 					 rv_byp_fx1_ilat1_vld;

   wire [0:`THREADS-1] 					 rv1_fx0_ilat0_vld;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv1_fx0_ilat0_itag;
   wire [0:`THREADS-1] 					 rv1_fx1_ilat0_vld;
   wire [0:`ITAG_SIZE_ENC-1] 				 rv1_fx1_ilat0_itag;

   wire [0:`THREADS-1] 					 fx0_release_ord_hold;
   wire [0:`THREADS-1] 					 fx0_rv_ord_tid;

   wire [0:`THREADS-1] 					 lq_rv_ext_itag0_vld;
   wire 						 lq_rv_ext_itag0_abort;
   wire [0:`ITAG_SIZE_ENC-1] 				 lq_rv_ext_itag0    ;
   wire [0:`THREADS-1] 					 lq_rv_ext_itag1_vld;
   wire 						 lq_rv_ext_itag1_abort;
   wire [0:`ITAG_SIZE_ENC-1] 				 lq_rv_ext_itag1    ;
   wire [0:`THREADS-1] 					 lq_rv_ext_itag2_vld;
   wire [0:`ITAG_SIZE_ENC-1] 				 lq_rv_ext_itag2    ;

   wire [0:`THREADS-1] 					 axu0_rv_ext_itag_vld;
   wire 						 axu0_rv_ext_itag_abort;
   wire [0:`ITAG_SIZE_ENC-1] 				 axu0_rv_ext_itag;
   wire [0:`THREADS-1] 					 axu1_rv_ext_itag_vld;
   wire 						 axu1_rv_ext_itag_abort;
   wire [0:`ITAG_SIZE_ENC-1] 				 axu1_rv_ext_itag;

   wire [64-`GPR_WIDTH:77] 				 w_data_in_1;
   wire [64-`GPR_WIDTH:77] 				 w_data_in_2;
   wire [64-`GPR_WIDTH:77] 				 w_data_in_3;
   wire [64-`GPR_WIDTH:77] 				 w_data_in_4;
   (* analysis_not_referenced="<72:77>true" *)
   wire [64-`GPR_WIDTH:77] 				 r_data_out_1;
   (* analysis_not_referenced="<72:77>true" *)
   wire [64-`GPR_WIDTH:77] 				 r_data_out_2;

   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1] 		 rv_lq_gpr_s1_p;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1] 		 rv_lq_gpr_s2_p;

   wire 						 lqrf_si;
   (* analysis_not_referenced="true" *)
   wire 						 lqrf_so;

   wire [0:8*`THREADS-1] 				 fx0_rvs_perf_bus;
   wire [0:31] 						 fx0_rvs_dbg_bus;
   wire [0:8*`THREADS-1]				 fx1_rvs_perf_bus;
   wire [0:31] 						 fx1_rvs_dbg_bus;
   wire [0:8*`THREADS-1] 				 lq_rvs_perf_bus;
   wire [0:31] 						 lq_rvs_dbg_bus;
   wire [0:8*`THREADS-1]				 axu0_rvs_perf_bus;
   wire [0:31] 						 axu0_rvs_dbg_bus;

   //todo review pervaice sigs.
   wire 						 func_sl_thold_1;
   (* analysis_not_referenced="true" *)
   wire 						 fce_1;
   wire 						 sg_1;
   wire 						 clkoff_dc_b;
   wire 						 act_dis;
   (* analysis_not_referenced="<1:9>true" *)
   wire [0:9] 						 delay_lclkr_dc;
   (* analysis_not_referenced="<1:9>true" *)
   wire [0:9] 						 mpw1_dc_b;
   wire 						 mpw2_dc_b;
   wire 						 gptr_scan_in;
   (* analysis_not_referenced="true" *)
   wire 						 gptr_scan_out;

   wire 						 chip_b_sl_2_thold_0_b;
   wire 						 force_t;
   wire 						 d_mode;
   (* analysis_not_referenced="true" *)
   wire 						 unused;

   // Scan Chain
   parameter                                             rv_deps_offset = 0;
   parameter                                             rv_fx0_rvs_offset = rv_deps_offset +1;
   parameter                                             rv_fx1_rvs_offset = rv_fx0_rvs_offset +1;
   parameter                                             rv_lq_rvs_offset =  rv_fx1_rvs_offset +1;
   parameter                                             rv_axu0_rvs_offset = rv_lq_rvs_offset +1;
   parameter                                             rv_rf_byp_offset =  rv_axu0_rvs_offset +1;
   parameter                                             perv_func_offset =  rv_rf_byp_offset +1;



   parameter                      scan_right = perv_func_offset +1;
   wire [0:scan_right-1] 	   siv;
   wire [0:scan_right-1] 	   sov;

   //!! Bugspray Include: rv;

   wire 			   vdd;
   wire 			   gnd;
   assign vdd = 1'b1;
   assign gnd = 1'b0;

   assign unused = axu1_rv_hold_all;

   //---------------------------------------------------------------------------------------------------------------

   assign chip_b_sl_2_thold_0_b = (~func_sl_thold_1);
   assign force_t = 1'b0;
   assign d_mode = 1'b0;

   assign iu_rv_iu6_t0_i0_branch = {iu_rv_iu6_t0_i0_bta,
	  			    iu_rv_iu6_t0_i0_bta_val,
	  			    iu_rv_iu6_t0_i0_br_pred,
	  			    iu_rv_iu6_t0_i0_fusion,
	  			    iu_rv_iu6_t0_i0_ls_ptr,
	  			    iu_rv_iu6_t0_i0_gshare,
	  			    iu_rv_iu6_t0_i0_bh_update};
   assign iu_rv_iu6_t0_i1_branch = {iu_rv_iu6_t0_i1_bta,
	  			    iu_rv_iu6_t0_i1_bta_val,
	  			    iu_rv_iu6_t0_i1_br_pred,
	  			    iu_rv_iu6_t0_i1_fusion,
	  			    iu_rv_iu6_t0_i1_ls_ptr,
	  			    iu_rv_iu6_t0_i1_gshare,
	  			    iu_rv_iu6_t0_i1_bh_update};
   assign cp_next_itag[0:`ITAG_SIZE_ENC-1] = cp_t0_next_itag;

`ifndef THREADS1
   assign iu_rv_iu6_t1_i0_branch = {iu_rv_iu6_t1_i0_bta,
				    iu_rv_iu6_t1_i0_bta_val,
	  	      		    iu_rv_iu6_t1_i0_br_pred,
	  	  		    iu_rv_iu6_t1_i0_fusion,
	  			    iu_rv_iu6_t1_i0_ls_ptr,
				    iu_rv_iu6_t1_i0_gshare,
	  			    iu_rv_iu6_t1_i0_bh_update};
   assign iu_rv_iu6_t1_i1_branch = {iu_rv_iu6_t1_i1_bta,
	  	   		    iu_rv_iu6_t1_i1_bta_val,
	  	 		    iu_rv_iu6_t1_i1_br_pred,
	  	    		    iu_rv_iu6_t1_i1_fusion,
	  	   		    iu_rv_iu6_t1_i1_ls_ptr,
	  	     		    iu_rv_iu6_t1_i1_gshare,
	  		    	    iu_rv_iu6_t1_i1_bh_update};
   assign cp_next_itag[`ITAG_SIZE_ENC:`THREADS*`ITAG_SIZE_ENC-1] = cp_t1_next_itag;

`endif //  `ifndef THREADS1

   assign rv_fx0_ex0_pred_bta = rv_fx0_ex0_branch[0:`EFF_IFAR_WIDTH - 1];
   assign rv_fx0_ex0_bta_val = rv_fx0_ex0_branch[20];
   assign rv_fx0_ex0_br_pred = rv_fx0_ex0_branch[21];
   assign rv_fx0_ex0_fusion = rv_fx0_ex0_branch[22:22 + `EFF_IFAR_WIDTH - 1];
   assign rv_fx0_ex0_ls_ptr = rv_fx0_ex0_branch[42:44];
   assign rv_fx0_ex0_gshare = rv_fx0_ex0_branch[45:62];
   assign rv_fx0_ex0_bh_update = rv_fx0_ex0_branch[63];

   //------------------------------------------------------------------------------------------------------------
   // Scorecards
   //------------------------------------------------------------------------------------------------------------


   rv_deps
     rv_deps0(
	      .iu_rv_iu6_t0_i0_vld(iu_rv_iu6_t0_i0_vld),
	      .iu_rv_iu6_t0_i0_rte_lq(iu_rv_iu6_t0_i0_rte_lq),
	      .iu_rv_iu6_t0_i0_rte_sq(iu_rv_iu6_t0_i0_rte_sq),
	      .iu_rv_iu6_t0_i0_rte_fx0(iu_rv_iu6_t0_i0_rte_fx0),
	      .iu_rv_iu6_t0_i0_rte_fx1(iu_rv_iu6_t0_i0_rte_fx1),
	      .iu_rv_iu6_t0_i0_rte_axu0(iu_rv_iu6_t0_i0_rte_axu0),
	      .iu_rv_iu6_t0_i0_rte_axu1(iu_rv_iu6_t0_i0_rte_axu1),
	      .iu_rv_iu6_t0_i0_act(iu_rv_iu6_t0_i0_act),
	      .iu_rv_iu6_t0_i0_instr(iu_rv_iu6_t0_i0_instr),
	      .iu_rv_iu6_t0_i0_ifar(iu_rv_iu6_t0_i0_ifar),
	      .iu_rv_iu6_t0_i0_ucode(iu_rv_iu6_t0_i0_ucode),
	      .iu_rv_iu6_t0_i0_2ucode(iu_rv_iu6_t0_i0_2ucode),
	      .iu_rv_iu6_t0_i0_ucode_cnt(iu_rv_iu6_t0_i0_ucode_cnt),
	      .iu_rv_iu6_t0_i0_itag(iu_rv_iu6_t0_i0_itag),
	      .iu_rv_iu6_t0_i0_ord(iu_rv_iu6_t0_i0_ord),
	      .iu_rv_iu6_t0_i0_cord(iu_rv_iu6_t0_i0_cord),
	      .iu_rv_iu6_t0_i0_spec(iu_rv_iu6_t0_i0_spec),
	      .iu_rv_iu6_t0_i0_t1_v(iu_rv_iu6_t0_i0_t1_v),
	      .iu_rv_iu6_t0_i0_t1_p(iu_rv_iu6_t0_i0_t1_p),
	      .iu_rv_iu6_t0_i0_t1_t(iu_rv_iu6_t0_i0_t1_t),
	      .iu_rv_iu6_t0_i0_t2_v(iu_rv_iu6_t0_i0_t2_v),
	      .iu_rv_iu6_t0_i0_t2_p(iu_rv_iu6_t0_i0_t2_p),
	      .iu_rv_iu6_t0_i0_t2_t(iu_rv_iu6_t0_i0_t2_t),
	      .iu_rv_iu6_t0_i0_t3_v(iu_rv_iu6_t0_i0_t3_v),
	      .iu_rv_iu6_t0_i0_t3_p(iu_rv_iu6_t0_i0_t3_p),
	      .iu_rv_iu6_t0_i0_t3_t(iu_rv_iu6_t0_i0_t3_t),
	      .iu_rv_iu6_t0_i0_s1_v(iu_rv_iu6_t0_i0_s1_v),
	      .iu_rv_iu6_t0_i0_s1_p(iu_rv_iu6_t0_i0_s1_p),
	      .iu_rv_iu6_t0_i0_s1_t(iu_rv_iu6_t0_i0_s1_t),
	      .iu_rv_iu6_t0_i0_s2_v(iu_rv_iu6_t0_i0_s2_v),
	      .iu_rv_iu6_t0_i0_s2_p(iu_rv_iu6_t0_i0_s2_p),
	      .iu_rv_iu6_t0_i0_s2_t(iu_rv_iu6_t0_i0_s2_t),
	      .iu_rv_iu6_t0_i0_s3_v(iu_rv_iu6_t0_i0_s3_v),
	      .iu_rv_iu6_t0_i0_s3_p(iu_rv_iu6_t0_i0_s3_p),
	      .iu_rv_iu6_t0_i0_s3_t(iu_rv_iu6_t0_i0_s3_t),
	      .iu_rv_iu6_t0_i0_ilat(iu_rv_iu6_t0_i0_ilat),
	      .iu_rv_iu6_t0_i0_isLoad(iu_rv_iu6_t0_i0_isLoad),
	      .iu_rv_iu6_t0_i0_isStore(iu_rv_iu6_t0_i0_isStore),
	      .iu_rv_iu6_t0_i0_branch(iu_rv_iu6_t0_i0_branch),
	      .iu_rv_iu6_t0_i0_s1_itag(iu_rv_iu6_t0_i0_s1_itag),
	      .iu_rv_iu6_t0_i0_s2_itag(iu_rv_iu6_t0_i0_s2_itag),
	      .iu_rv_iu6_t0_i0_s3_itag(iu_rv_iu6_t0_i0_s3_itag),
	      .iu_rv_iu6_t0_i1_vld(iu_rv_iu6_t0_i1_vld),
	      .iu_rv_iu6_t0_i1_rte_lq(iu_rv_iu6_t0_i1_rte_lq),
	      .iu_rv_iu6_t0_i1_rte_sq(iu_rv_iu6_t0_i1_rte_sq),
	      .iu_rv_iu6_t0_i1_rte_fx0(iu_rv_iu6_t0_i1_rte_fx0),
	      .iu_rv_iu6_t0_i1_rte_fx1(iu_rv_iu6_t0_i1_rte_fx1),
	      .iu_rv_iu6_t0_i1_rte_axu0(iu_rv_iu6_t0_i1_rte_axu0),
	      .iu_rv_iu6_t0_i1_rte_axu1(iu_rv_iu6_t0_i1_rte_axu1),
	      .iu_rv_iu6_t0_i1_act(iu_rv_iu6_t0_i1_act),
	      .iu_rv_iu6_t0_i1_instr(iu_rv_iu6_t0_i1_instr),
	      .iu_rv_iu6_t0_i1_ifar(iu_rv_iu6_t0_i1_ifar),
	      .iu_rv_iu6_t0_i1_ucode(iu_rv_iu6_t0_i1_ucode),
	      .iu_rv_iu6_t0_i1_ucode_cnt(iu_rv_iu6_t0_i1_ucode_cnt),
	      .iu_rv_iu6_t0_i1_itag(iu_rv_iu6_t0_i1_itag),
	      .iu_rv_iu6_t0_i1_ord(iu_rv_iu6_t0_i1_ord),
	      .iu_rv_iu6_t0_i1_cord(iu_rv_iu6_t0_i1_cord),
	      .iu_rv_iu6_t0_i1_spec(iu_rv_iu6_t0_i1_spec),
	      .iu_rv_iu6_t0_i1_t1_v(iu_rv_iu6_t0_i1_t1_v),
	      .iu_rv_iu6_t0_i1_t1_p(iu_rv_iu6_t0_i1_t1_p),
	      .iu_rv_iu6_t0_i1_t1_t(iu_rv_iu6_t0_i1_t1_t),
	      .iu_rv_iu6_t0_i1_t2_v(iu_rv_iu6_t0_i1_t2_v),
	      .iu_rv_iu6_t0_i1_t2_p(iu_rv_iu6_t0_i1_t2_p),
	      .iu_rv_iu6_t0_i1_t2_t(iu_rv_iu6_t0_i1_t2_t),
	      .iu_rv_iu6_t0_i1_t3_v(iu_rv_iu6_t0_i1_t3_v),
	      .iu_rv_iu6_t0_i1_t3_p(iu_rv_iu6_t0_i1_t3_p),
	      .iu_rv_iu6_t0_i1_t3_t(iu_rv_iu6_t0_i1_t3_t),
	      .iu_rv_iu6_t0_i1_s1_v(iu_rv_iu6_t0_i1_s1_v),
	      .iu_rv_iu6_t0_i1_s1_p(iu_rv_iu6_t0_i1_s1_p),
	      .iu_rv_iu6_t0_i1_s1_t(iu_rv_iu6_t0_i1_s1_t),
	      .iu_rv_iu6_t0_i1_s2_v(iu_rv_iu6_t0_i1_s2_v),
	      .iu_rv_iu6_t0_i1_s2_p(iu_rv_iu6_t0_i1_s2_p),
	      .iu_rv_iu6_t0_i1_s2_t(iu_rv_iu6_t0_i1_s2_t),
	      .iu_rv_iu6_t0_i1_s3_v(iu_rv_iu6_t0_i1_s3_v),
	      .iu_rv_iu6_t0_i1_s3_p(iu_rv_iu6_t0_i1_s3_p),
	      .iu_rv_iu6_t0_i1_s3_t(iu_rv_iu6_t0_i1_s3_t),
	      .iu_rv_iu6_t0_i1_ilat(iu_rv_iu6_t0_i1_ilat),
	      .iu_rv_iu6_t0_i1_isLoad(iu_rv_iu6_t0_i1_isLoad),
	      .iu_rv_iu6_t0_i1_isStore(iu_rv_iu6_t0_i1_isStore),
	      .iu_rv_iu6_t0_i1_branch(iu_rv_iu6_t0_i1_branch),
	      .iu_rv_iu6_t0_i1_s1_itag(iu_rv_iu6_t0_i1_s1_itag),
	      .iu_rv_iu6_t0_i1_s2_itag(iu_rv_iu6_t0_i1_s2_itag),
	      .iu_rv_iu6_t0_i1_s3_itag(iu_rv_iu6_t0_i1_s3_itag),
	      .iu_rv_iu6_t0_i1_s1_dep_hit(iu_rv_iu6_t0_i1_s1_dep_hit),
	      .iu_rv_iu6_t0_i1_s2_dep_hit(iu_rv_iu6_t0_i1_s2_dep_hit),
	      .iu_rv_iu6_t0_i1_s3_dep_hit(iu_rv_iu6_t0_i1_s3_dep_hit),
`ifndef THREADS1
	      .iu_rv_iu6_t1_i0_vld(iu_rv_iu6_t1_i0_vld),
	      .iu_rv_iu6_t1_i0_rte_lq(iu_rv_iu6_t1_i0_rte_lq),
	      .iu_rv_iu6_t1_i0_rte_sq(iu_rv_iu6_t1_i0_rte_sq),
	      .iu_rv_iu6_t1_i0_rte_fx0(iu_rv_iu6_t1_i0_rte_fx0),
	      .iu_rv_iu6_t1_i0_rte_fx1(iu_rv_iu6_t1_i0_rte_fx1),
	      .iu_rv_iu6_t1_i0_rte_axu0(iu_rv_iu6_t1_i0_rte_axu0),
	      .iu_rv_iu6_t1_i0_rte_axu1(iu_rv_iu6_t1_i0_rte_axu1),
	      .iu_rv_iu6_t1_i0_act(iu_rv_iu6_t1_i0_act),
	      .iu_rv_iu6_t1_i0_instr(iu_rv_iu6_t1_i0_instr),
	      .iu_rv_iu6_t1_i0_ifar(iu_rv_iu6_t1_i0_ifar),
	      .iu_rv_iu6_t1_i0_ucode(iu_rv_iu6_t1_i0_ucode),
	      .iu_rv_iu6_t1_i0_2ucode(iu_rv_iu6_t1_i0_2ucode),
	      .iu_rv_iu6_t1_i0_ucode_cnt(iu_rv_iu6_t1_i0_ucode_cnt),
	      .iu_rv_iu6_t1_i0_itag(iu_rv_iu6_t1_i0_itag),
	      .iu_rv_iu6_t1_i0_ord(iu_rv_iu6_t1_i0_ord),
	      .iu_rv_iu6_t1_i0_cord(iu_rv_iu6_t1_i0_cord),
	      .iu_rv_iu6_t1_i0_spec(iu_rv_iu6_t1_i0_spec),
	      .iu_rv_iu6_t1_i0_t1_v(iu_rv_iu6_t1_i0_t1_v),
	      .iu_rv_iu6_t1_i0_t1_p(iu_rv_iu6_t1_i0_t1_p),
	      .iu_rv_iu6_t1_i0_t1_t(iu_rv_iu6_t1_i0_t1_t),
	      .iu_rv_iu6_t1_i0_t2_v(iu_rv_iu6_t1_i0_t2_v),
	      .iu_rv_iu6_t1_i0_t2_p(iu_rv_iu6_t1_i0_t2_p),
	      .iu_rv_iu6_t1_i0_t2_t(iu_rv_iu6_t1_i0_t2_t),
	      .iu_rv_iu6_t1_i0_t3_v(iu_rv_iu6_t1_i0_t3_v),
	      .iu_rv_iu6_t1_i0_t3_p(iu_rv_iu6_t1_i0_t3_p),
	      .iu_rv_iu6_t1_i0_t3_t(iu_rv_iu6_t1_i0_t3_t),
	      .iu_rv_iu6_t1_i0_s1_v(iu_rv_iu6_t1_i0_s1_v),
	      .iu_rv_iu6_t1_i0_s1_p(iu_rv_iu6_t1_i0_s1_p),
	      .iu_rv_iu6_t1_i0_s1_t(iu_rv_iu6_t1_i0_s1_t),
	      .iu_rv_iu6_t1_i0_s2_v(iu_rv_iu6_t1_i0_s2_v),
	      .iu_rv_iu6_t1_i0_s2_p(iu_rv_iu6_t1_i0_s2_p),
	      .iu_rv_iu6_t1_i0_s2_t(iu_rv_iu6_t1_i0_s2_t),
	      .iu_rv_iu6_t1_i0_s3_v(iu_rv_iu6_t1_i0_s3_v),
	      .iu_rv_iu6_t1_i0_s3_p(iu_rv_iu6_t1_i0_s3_p),
	      .iu_rv_iu6_t1_i0_s3_t(iu_rv_iu6_t1_i0_s3_t),
	      .iu_rv_iu6_t1_i0_ilat(iu_rv_iu6_t1_i0_ilat),
	      .iu_rv_iu6_t1_i0_isLoad(iu_rv_iu6_t1_i0_isLoad),
	      .iu_rv_iu6_t1_i0_isStore(iu_rv_iu6_t1_i0_isStore),
	      .iu_rv_iu6_t1_i0_branch(iu_rv_iu6_t1_i0_branch),
	      .iu_rv_iu6_t1_i0_s1_itag(iu_rv_iu6_t1_i0_s1_itag),
	      .iu_rv_iu6_t1_i0_s2_itag(iu_rv_iu6_t1_i0_s2_itag),
	      .iu_rv_iu6_t1_i0_s3_itag(iu_rv_iu6_t1_i0_s3_itag),
	      .iu_rv_iu6_t1_i1_vld(iu_rv_iu6_t1_i1_vld),
	      .iu_rv_iu6_t1_i1_rte_lq(iu_rv_iu6_t1_i1_rte_lq),
	      .iu_rv_iu6_t1_i1_rte_sq(iu_rv_iu6_t1_i1_rte_sq),
	      .iu_rv_iu6_t1_i1_rte_fx0(iu_rv_iu6_t1_i1_rte_fx0),
	      .iu_rv_iu6_t1_i1_rte_fx1(iu_rv_iu6_t1_i1_rte_fx1),
	      .iu_rv_iu6_t1_i1_rte_axu0(iu_rv_iu6_t1_i1_rte_axu0),
	      .iu_rv_iu6_t1_i1_rte_axu1(iu_rv_iu6_t1_i1_rte_axu1),
	      .iu_rv_iu6_t1_i1_act(iu_rv_iu6_t1_i1_act),
	      .iu_rv_iu6_t1_i1_instr(iu_rv_iu6_t1_i1_instr),
	      .iu_rv_iu6_t1_i1_ifar(iu_rv_iu6_t1_i1_ifar),
	      .iu_rv_iu6_t1_i1_ucode(iu_rv_iu6_t1_i1_ucode),
	      .iu_rv_iu6_t1_i1_ucode_cnt(iu_rv_iu6_t1_i1_ucode_cnt),
	      .iu_rv_iu6_t1_i1_itag(iu_rv_iu6_t1_i1_itag),
	      .iu_rv_iu6_t1_i1_ord(iu_rv_iu6_t1_i1_ord),
	      .iu_rv_iu6_t1_i1_cord(iu_rv_iu6_t1_i1_cord),
	      .iu_rv_iu6_t1_i1_spec(iu_rv_iu6_t1_i1_spec),
	      .iu_rv_iu6_t1_i1_t1_v(iu_rv_iu6_t1_i1_t1_v),
	      .iu_rv_iu6_t1_i1_t1_p(iu_rv_iu6_t1_i1_t1_p),
	      .iu_rv_iu6_t1_i1_t1_t(iu_rv_iu6_t1_i1_t1_t),
	      .iu_rv_iu6_t1_i1_t2_v(iu_rv_iu6_t1_i1_t2_v),
	      .iu_rv_iu6_t1_i1_t2_p(iu_rv_iu6_t1_i1_t2_p),
	      .iu_rv_iu6_t1_i1_t2_t(iu_rv_iu6_t1_i1_t2_t),
	      .iu_rv_iu6_t1_i1_t3_v(iu_rv_iu6_t1_i1_t3_v),
	      .iu_rv_iu6_t1_i1_t3_p(iu_rv_iu6_t1_i1_t3_p),
	      .iu_rv_iu6_t1_i1_t3_t(iu_rv_iu6_t1_i1_t3_t),
	      .iu_rv_iu6_t1_i1_s1_v(iu_rv_iu6_t1_i1_s1_v),
	      .iu_rv_iu6_t1_i1_s1_p(iu_rv_iu6_t1_i1_s1_p),
	      .iu_rv_iu6_t1_i1_s1_t(iu_rv_iu6_t1_i1_s1_t),
	      .iu_rv_iu6_t1_i1_s2_v(iu_rv_iu6_t1_i1_s2_v),
	      .iu_rv_iu6_t1_i1_s2_p(iu_rv_iu6_t1_i1_s2_p),
	      .iu_rv_iu6_t1_i1_s2_t(iu_rv_iu6_t1_i1_s2_t),
	      .iu_rv_iu6_t1_i1_s3_v(iu_rv_iu6_t1_i1_s3_v),
	      .iu_rv_iu6_t1_i1_s3_p(iu_rv_iu6_t1_i1_s3_p),
	      .iu_rv_iu6_t1_i1_s3_t(iu_rv_iu6_t1_i1_s3_t),
	      .iu_rv_iu6_t1_i1_ilat(iu_rv_iu6_t1_i1_ilat),
	      .iu_rv_iu6_t1_i1_isLoad(iu_rv_iu6_t1_i1_isLoad),
	      .iu_rv_iu6_t1_i1_isStore(iu_rv_iu6_t1_i1_isStore),
	      .iu_rv_iu6_t1_i1_branch(iu_rv_iu6_t1_i1_branch),
	      .iu_rv_iu6_t1_i1_s1_itag(iu_rv_iu6_t1_i1_s1_itag),
	      .iu_rv_iu6_t1_i1_s2_itag(iu_rv_iu6_t1_i1_s2_itag),
	      .iu_rv_iu6_t1_i1_s3_itag(iu_rv_iu6_t1_i1_s3_itag),
	      .iu_rv_iu6_t1_i1_s1_dep_hit(iu_rv_iu6_t1_i1_s1_dep_hit),
	      .iu_rv_iu6_t1_i1_s2_dep_hit(iu_rv_iu6_t1_i1_s2_dep_hit),
	      .iu_rv_iu6_t1_i1_s3_dep_hit(iu_rv_iu6_t1_i1_s3_dep_hit),
`endif
	      .cp_flush(cp_flush),
	      .fx0_rv_itag_vld(fx0_rv_itag_vld),
	      .fx0_rv_itag(fx0_rv_itag),
	      .fx1_rv_itag_vld(fx1_rv_itag_vld),
	      .fx1_rv_itag(fx1_rv_itag),
	      .lq_rv_itag0_vld(lq_rv_itag0_vld),
	      .lq_rv_itag0(lq_rv_itag0),
	      .lq_rv_itag1_vld(lq_rv_itag1_vld),
	      .lq_rv_itag1(lq_rv_itag1),
	      .lq_rv_itag2_vld(lq_rv_itag2_vld),
	      .lq_rv_itag2(lq_rv_itag2),
	      .axu0_rv_itag_vld(axu0_rv_itag_vld),
	      .axu0_rv_itag(axu0_rv_itag),
	      .axu1_rv_itag_vld(axu1_rv_itag_vld),
	      .axu1_rv_itag(axu1_rv_itag),

	      .fx0_rv_itag_abort(fx0_rv_itag_abort),
	      .fx1_rv_itag_abort(fx1_rv_itag_abort),
	      .lq_rv_itag0_abort(lq_rv_itag0_abort),
	      .lq_rv_itag1_abort(lq_rv_itag1_abort),
	      .axu0_rv_itag_abort(axu0_rv_itag_abort),
	      .axu1_rv_itag_abort(axu1_rv_itag_abort),

	      .rv0_fx0_instr_i0_vld(rv0_fx0_instr_i0_vld),
	      .rv0_fx0_instr_i0_rte_fx0(rv0_fx0_instr_i0_rte_fx0),
	      .rv0_fx0_instr_i0_instr(rv0_fx0_instr_i0_instr),
	      .rv0_fx0_instr_i0_ifar(rv0_fx0_instr_i0_ifar),
	      .rv0_fx0_instr_i0_ucode(rv0_fx0_instr_i0_ucode),
	      .rv0_fx0_instr_i0_ucode_cnt(rv0_fx0_instr_i0_ucode_cnt),
	      .rv0_fx0_instr_i0_itag(rv0_fx0_instr_i0_itag),
	      .rv0_fx0_instr_i0_ord(rv0_fx0_instr_i0_ord),
	      .rv0_fx0_instr_i0_cord(rv0_fx0_instr_i0_cord),
	      .rv0_fx0_instr_i0_t1_v(rv0_fx0_instr_i0_t1_v),
	      .rv0_fx0_instr_i0_t1_p(rv0_fx0_instr_i0_t1_p),
	      .rv0_fx0_instr_i0_t1_t(rv0_fx0_instr_i0_t1_t),
	      .rv0_fx0_instr_i0_t2_v(rv0_fx0_instr_i0_t2_v),
	      .rv0_fx0_instr_i0_t2_p(rv0_fx0_instr_i0_t2_p),
	      .rv0_fx0_instr_i0_t2_t(rv0_fx0_instr_i0_t2_t),
	      .rv0_fx0_instr_i0_t3_v(rv0_fx0_instr_i0_t3_v),
	      .rv0_fx0_instr_i0_t3_p(rv0_fx0_instr_i0_t3_p),
	      .rv0_fx0_instr_i0_t3_t(rv0_fx0_instr_i0_t3_t),
	      .rv0_fx0_instr_i0_s1_v(rv0_fx0_instr_i0_s1_v),
	      .rv0_fx0_instr_i0_s1_p(rv0_fx0_instr_i0_s1_p),
	      .rv0_fx0_instr_i0_s1_t(rv0_fx0_instr_i0_s1_t),
	      .rv0_fx0_instr_i0_s2_v(rv0_fx0_instr_i0_s2_v),
	      .rv0_fx0_instr_i0_s2_p(rv0_fx0_instr_i0_s2_p),
	      .rv0_fx0_instr_i0_s2_t(rv0_fx0_instr_i0_s2_t),
	      .rv0_fx0_instr_i0_s3_v(rv0_fx0_instr_i0_s3_v),
	      .rv0_fx0_instr_i0_s3_p(rv0_fx0_instr_i0_s3_p),
	      .rv0_fx0_instr_i0_s3_t(rv0_fx0_instr_i0_s3_t),
	      .rv0_fx0_instr_i0_ilat(rv0_fx0_instr_i0_ilat),
	      .rv0_fx0_instr_i0_branch(rv0_fx0_instr_i0_branch),
	      .rv0_fx0_instr_i0_spare(rv0_fx0_instr_i0_spare),
	      .rv0_fx0_instr_i0_is_brick(rv0_fx0_instr_i0_is_brick),
	      .rv0_fx0_instr_i0_brick(rv0_fx0_instr_i0_brick),
	      .rv0_fx0_instr_i1_vld(rv0_fx0_instr_i1_vld),
	      .rv0_fx0_instr_i1_rte_fx0(rv0_fx0_instr_i1_rte_fx0),
	      .rv0_fx0_instr_i1_instr(rv0_fx0_instr_i1_instr),
	      .rv0_fx0_instr_i1_ifar(rv0_fx0_instr_i1_ifar),
	      .rv0_fx0_instr_i1_ucode(rv0_fx0_instr_i1_ucode),
	      .rv0_fx0_instr_i1_ucode_cnt(rv0_fx0_instr_i1_ucode_cnt),
	      .rv0_fx0_instr_i1_itag(rv0_fx0_instr_i1_itag),
	      .rv0_fx0_instr_i1_ord(rv0_fx0_instr_i1_ord),
	      .rv0_fx0_instr_i1_cord(rv0_fx0_instr_i1_cord),
	      .rv0_fx0_instr_i1_t1_v(rv0_fx0_instr_i1_t1_v),
	      .rv0_fx0_instr_i1_t1_p(rv0_fx0_instr_i1_t1_p),
	      .rv0_fx0_instr_i1_t1_t(rv0_fx0_instr_i1_t1_t),
	      .rv0_fx0_instr_i1_t2_v(rv0_fx0_instr_i1_t2_v),
	      .rv0_fx0_instr_i1_t2_p(rv0_fx0_instr_i1_t2_p),
	      .rv0_fx0_instr_i1_t2_t(rv0_fx0_instr_i1_t2_t),
	      .rv0_fx0_instr_i1_t3_v(rv0_fx0_instr_i1_t3_v),
	      .rv0_fx0_instr_i1_t3_p(rv0_fx0_instr_i1_t3_p),
	      .rv0_fx0_instr_i1_t3_t(rv0_fx0_instr_i1_t3_t),
	      .rv0_fx0_instr_i1_s1_v(rv0_fx0_instr_i1_s1_v),
	      .rv0_fx0_instr_i1_s1_p(rv0_fx0_instr_i1_s1_p),
	      .rv0_fx0_instr_i1_s1_t(rv0_fx0_instr_i1_s1_t),
	      .rv0_fx0_instr_i1_s2_v(rv0_fx0_instr_i1_s2_v),
	      .rv0_fx0_instr_i1_s2_p(rv0_fx0_instr_i1_s2_p),
	      .rv0_fx0_instr_i1_s2_t(rv0_fx0_instr_i1_s2_t),
	      .rv0_fx0_instr_i1_s3_v(rv0_fx0_instr_i1_s3_v),
	      .rv0_fx0_instr_i1_s3_p(rv0_fx0_instr_i1_s3_p),
	      .rv0_fx0_instr_i1_s3_t(rv0_fx0_instr_i1_s3_t),
	      .rv0_fx0_instr_i1_ilat(rv0_fx0_instr_i1_ilat),
	      .rv0_fx0_instr_i1_branch(rv0_fx0_instr_i1_branch),
	      .rv0_fx0_instr_i1_spare(rv0_fx0_instr_i1_spare),
	      .rv0_fx0_instr_i1_is_brick(rv0_fx0_instr_i1_is_brick),
	      .rv0_fx0_instr_i1_brick(rv0_fx0_instr_i1_brick),
	      .rv0_fx0_instr_i0_s1_dep_hit(rv0_fx0_instr_i0_s1_dep_hit),
	      .rv0_fx0_instr_i0_s1_itag(rv0_fx0_instr_i0_s1_itag),
	      .rv0_fx0_instr_i0_s2_dep_hit(rv0_fx0_instr_i0_s2_dep_hit),
	      .rv0_fx0_instr_i0_s2_itag(rv0_fx0_instr_i0_s2_itag),
	      .rv0_fx0_instr_i0_s3_dep_hit(rv0_fx0_instr_i0_s3_dep_hit),
	      .rv0_fx0_instr_i0_s3_itag(rv0_fx0_instr_i0_s3_itag),
	      .rv0_fx0_instr_i1_s1_dep_hit(rv0_fx0_instr_i1_s1_dep_hit),
	      .rv0_fx0_instr_i1_s1_itag(rv0_fx0_instr_i1_s1_itag),
	      .rv0_fx0_instr_i1_s2_dep_hit(rv0_fx0_instr_i1_s2_dep_hit),
	      .rv0_fx0_instr_i1_s2_itag(rv0_fx0_instr_i1_s2_itag),
	      .rv0_fx0_instr_i1_s3_dep_hit(rv0_fx0_instr_i1_s3_dep_hit),
	      .rv0_fx0_instr_i1_s3_itag(rv0_fx0_instr_i1_s3_itag),
	      .rv0_fx1_instr_i0_vld(rv0_fx1_instr_i0_vld),
	      .rv0_fx1_instr_i0_rte_fx1(rv0_fx1_instr_i0_rte_fx1),
	      .rv0_fx1_instr_i0_instr(rv0_fx1_instr_i0_instr),
	      .rv0_fx1_instr_i0_ucode(rv0_fx1_instr_i0_ucode),
	      .rv0_fx1_instr_i0_itag(rv0_fx1_instr_i0_itag),
	      .rv0_fx1_instr_i0_t1_v(rv0_fx1_instr_i0_t1_v),
	      .rv0_fx1_instr_i0_t1_p(rv0_fx1_instr_i0_t1_p),
	      .rv0_fx1_instr_i0_t2_v(rv0_fx1_instr_i0_t2_v),
	      .rv0_fx1_instr_i0_t2_p(rv0_fx1_instr_i0_t2_p),
	      .rv0_fx1_instr_i0_t3_v(rv0_fx1_instr_i0_t3_v),
	      .rv0_fx1_instr_i0_t3_p(rv0_fx1_instr_i0_t3_p),
	      .rv0_fx1_instr_i0_s1_v(rv0_fx1_instr_i0_s1_v),
	      .rv0_fx1_instr_i0_s1_p(rv0_fx1_instr_i0_s1_p),
	      .rv0_fx1_instr_i0_s1_t(rv0_fx1_instr_i0_s1_t),
	      .rv0_fx1_instr_i0_s2_v(rv0_fx1_instr_i0_s2_v),
	      .rv0_fx1_instr_i0_s2_p(rv0_fx1_instr_i0_s2_p),
	      .rv0_fx1_instr_i0_s2_t(rv0_fx1_instr_i0_s2_t),
	      .rv0_fx1_instr_i0_s3_v(rv0_fx1_instr_i0_s3_v),
	      .rv0_fx1_instr_i0_s3_p(rv0_fx1_instr_i0_s3_p),
	      .rv0_fx1_instr_i0_s3_t(rv0_fx1_instr_i0_s3_t),
	      .rv0_fx1_instr_i0_ilat(rv0_fx1_instr_i0_ilat),
	      .rv0_fx1_instr_i0_isStore(rv0_fx1_instr_i0_isStore),
	      .rv0_fx1_instr_i0_spare(rv0_fx1_instr_i0_spare),
	      .rv0_fx1_instr_i0_is_brick(rv0_fx1_instr_i0_is_brick),
	      .rv0_fx1_instr_i0_brick(rv0_fx1_instr_i0_brick),
	      .rv0_fx1_instr_i1_vld(rv0_fx1_instr_i1_vld),
	      .rv0_fx1_instr_i1_rte_fx1(rv0_fx1_instr_i1_rte_fx1),
	      .rv0_fx1_instr_i1_instr(rv0_fx1_instr_i1_instr),
	      .rv0_fx1_instr_i1_ucode(rv0_fx1_instr_i1_ucode),
	      .rv0_fx1_instr_i1_itag(rv0_fx1_instr_i1_itag),
	      .rv0_fx1_instr_i1_t1_v(rv0_fx1_instr_i1_t1_v),
	      .rv0_fx1_instr_i1_t1_p(rv0_fx1_instr_i1_t1_p),
	      .rv0_fx1_instr_i1_t2_v(rv0_fx1_instr_i1_t2_v),
	      .rv0_fx1_instr_i1_t2_p(rv0_fx1_instr_i1_t2_p),
	      .rv0_fx1_instr_i1_t3_v(rv0_fx1_instr_i1_t3_v),
	      .rv0_fx1_instr_i1_t3_p(rv0_fx1_instr_i1_t3_p),
	      .rv0_fx1_instr_i1_s1_v(rv0_fx1_instr_i1_s1_v),
	      .rv0_fx1_instr_i1_s1_p(rv0_fx1_instr_i1_s1_p),
	      .rv0_fx1_instr_i1_s1_t(rv0_fx1_instr_i1_s1_t),
	      .rv0_fx1_instr_i1_s2_v(rv0_fx1_instr_i1_s2_v),
	      .rv0_fx1_instr_i1_s2_p(rv0_fx1_instr_i1_s2_p),
	      .rv0_fx1_instr_i1_s2_t(rv0_fx1_instr_i1_s2_t),
	      .rv0_fx1_instr_i1_s3_v(rv0_fx1_instr_i1_s3_v),
	      .rv0_fx1_instr_i1_s3_p(rv0_fx1_instr_i1_s3_p),
	      .rv0_fx1_instr_i1_s3_t(rv0_fx1_instr_i1_s3_t),
	      .rv0_fx1_instr_i1_ilat(rv0_fx1_instr_i1_ilat),
	      .rv0_fx1_instr_i1_isStore(rv0_fx1_instr_i1_isStore),
	      .rv0_fx1_instr_i1_spare(rv0_fx1_instr_i1_spare),
	      .rv0_fx1_instr_i1_is_brick(rv0_fx1_instr_i1_is_brick),
	      .rv0_fx1_instr_i1_brick(rv0_fx1_instr_i1_brick),
	      .rv0_fx1_instr_i0_s1_dep_hit(rv0_fx1_instr_i0_s1_dep_hit),
	      .rv0_fx1_instr_i0_s1_itag(rv0_fx1_instr_i0_s1_itag),
	      .rv0_fx1_instr_i0_s2_dep_hit(rv0_fx1_instr_i0_s2_dep_hit),
	      .rv0_fx1_instr_i0_s2_itag(rv0_fx1_instr_i0_s2_itag),
	      .rv0_fx1_instr_i0_s3_dep_hit(rv0_fx1_instr_i0_s3_dep_hit),
	      .rv0_fx1_instr_i0_s3_itag(rv0_fx1_instr_i0_s3_itag),
	      .rv0_fx1_instr_i1_s1_dep_hit(rv0_fx1_instr_i1_s1_dep_hit),
	      .rv0_fx1_instr_i1_s1_itag(rv0_fx1_instr_i1_s1_itag),
	      .rv0_fx1_instr_i1_s2_dep_hit(rv0_fx1_instr_i1_s2_dep_hit),
	      .rv0_fx1_instr_i1_s2_itag(rv0_fx1_instr_i1_s2_itag),
	      .rv0_fx1_instr_i1_s3_dep_hit(rv0_fx1_instr_i1_s3_dep_hit),
	      .rv0_fx1_instr_i1_s3_itag(rv0_fx1_instr_i1_s3_itag),
	      .rv0_lq_instr_i0_vld(rv0_lq_instr_i0_vld),
	      .rv0_lq_instr_i0_rte_lq(rv0_lq_instr_i0_rte_lq),
	      .rv0_lq_instr_i0_instr(rv0_lq_instr_i0_instr),
	      .rv0_lq_instr_i0_ucode(rv0_lq_instr_i0_ucode),
	      .rv0_lq_instr_i0_ucode_cnt(rv0_lq_instr_i0_ucode_cnt),
	      .rv0_lq_instr_i0_itag(rv0_lq_instr_i0_itag),
	      .rv0_lq_instr_i0_ord(rv0_lq_instr_i0_ord),
	      .rv0_lq_instr_i0_cord(rv0_lq_instr_i0_cord),
	      .rv0_lq_instr_i0_spec(rv0_lq_instr_i0_spec),
	      .rv0_lq_instr_i0_t1_v(rv0_lq_instr_i0_t1_v),
	      .rv0_lq_instr_i0_t1_p(rv0_lq_instr_i0_t1_p),
	      .rv0_lq_instr_i0_t2_v(rv0_lq_instr_i0_t2_v),
	      .rv0_lq_instr_i0_t2_p(rv0_lq_instr_i0_t2_p),
	      .rv0_lq_instr_i0_t2_t(rv0_lq_instr_i0_t2_t),
	      .rv0_lq_instr_i0_t3_v(rv0_lq_instr_i0_t3_v),
	      .rv0_lq_instr_i0_t3_p(rv0_lq_instr_i0_t3_p),
	      .rv0_lq_instr_i0_t3_t(rv0_lq_instr_i0_t3_t),
	      .rv0_lq_instr_i0_s1_v(rv0_lq_instr_i0_s1_v),
	      .rv0_lq_instr_i0_s1_p(rv0_lq_instr_i0_s1_p),
	      .rv0_lq_instr_i0_s1_t(rv0_lq_instr_i0_s1_t),
	      .rv0_lq_instr_i0_s2_v(rv0_lq_instr_i0_s2_v),
	      .rv0_lq_instr_i0_s2_p(rv0_lq_instr_i0_s2_p),
	      .rv0_lq_instr_i0_s2_t(rv0_lq_instr_i0_s2_t),
	      .rv0_lq_instr_i0_isLoad(rv0_lq_instr_i0_isLoad),
	      .rv0_lq_instr_i0_spare(rv0_lq_instr_i0_spare),
	      .rv0_lq_instr_i0_is_brick(rv0_lq_instr_i0_is_brick),
	      .rv0_lq_instr_i0_brick(rv0_lq_instr_i0_brick),
	      .rv0_lq_instr_i1_vld(rv0_lq_instr_i1_vld),
	      .rv0_lq_instr_i1_rte_lq(rv0_lq_instr_i1_rte_lq),
	      .rv0_lq_instr_i1_instr(rv0_lq_instr_i1_instr),
	      .rv0_lq_instr_i1_ucode(rv0_lq_instr_i1_ucode),
	      .rv0_lq_instr_i1_ucode_cnt(rv0_lq_instr_i1_ucode_cnt),
	      .rv0_lq_instr_i1_itag(rv0_lq_instr_i1_itag),
	      .rv0_lq_instr_i1_ord(rv0_lq_instr_i1_ord),
	      .rv0_lq_instr_i1_cord(rv0_lq_instr_i1_cord),
	      .rv0_lq_instr_i1_spec(rv0_lq_instr_i1_spec),
	      .rv0_lq_instr_i1_t1_v(rv0_lq_instr_i1_t1_v),
	      .rv0_lq_instr_i1_t1_p(rv0_lq_instr_i1_t1_p),
	      .rv0_lq_instr_i1_t2_v(rv0_lq_instr_i1_t2_v),
	      .rv0_lq_instr_i1_t2_p(rv0_lq_instr_i1_t2_p),
	      .rv0_lq_instr_i1_t2_t(rv0_lq_instr_i1_t2_t),
	      .rv0_lq_instr_i1_t3_v(rv0_lq_instr_i1_t3_v),
	      .rv0_lq_instr_i1_t3_p(rv0_lq_instr_i1_t3_p),
	      .rv0_lq_instr_i1_t3_t(rv0_lq_instr_i1_t3_t),
	      .rv0_lq_instr_i1_s1_v(rv0_lq_instr_i1_s1_v),
	      .rv0_lq_instr_i1_s1_p(rv0_lq_instr_i1_s1_p),
	      .rv0_lq_instr_i1_s1_t(rv0_lq_instr_i1_s1_t),
	      .rv0_lq_instr_i1_s2_v(rv0_lq_instr_i1_s2_v),
	      .rv0_lq_instr_i1_s2_p(rv0_lq_instr_i1_s2_p),
	      .rv0_lq_instr_i1_s2_t(rv0_lq_instr_i1_s2_t),
	      .rv0_lq_instr_i1_isLoad(rv0_lq_instr_i1_isLoad),
	      .rv0_lq_instr_i1_spare(rv0_lq_instr_i1_spare),
	      .rv0_lq_instr_i1_is_brick(rv0_lq_instr_i1_is_brick),
	      .rv0_lq_instr_i1_brick(rv0_lq_instr_i1_brick),
	      .rv0_lq_instr_i0_s1_dep_hit(rv0_lq_instr_i0_s1_dep_hit),
	      .rv0_lq_instr_i0_s1_itag(rv0_lq_instr_i0_s1_itag),
	      .rv0_lq_instr_i0_s2_dep_hit(rv0_lq_instr_i0_s2_dep_hit),
	      .rv0_lq_instr_i0_s2_itag(rv0_lq_instr_i0_s2_itag),
	      .rv0_lq_instr_i1_s1_dep_hit(rv0_lq_instr_i1_s1_dep_hit),
	      .rv0_lq_instr_i1_s1_itag(rv0_lq_instr_i1_s1_itag),
	      .rv0_lq_instr_i1_s2_dep_hit(rv0_lq_instr_i1_s2_dep_hit),
	      .rv0_lq_instr_i1_s2_itag(rv0_lq_instr_i1_s2_itag),
	      .rv0_axu0_instr_i0_vld(rv0_axu0_instr_i0_vld),
	      .rv0_axu0_instr_i0_rte_axu0(rv0_axu0_instr_i0_rte_axu0),
	      .rv0_axu0_instr_i0_instr(rv0_axu0_instr_i0_instr),
	      .rv0_axu0_instr_i0_ucode(rv0_axu0_instr_i0_ucode),
	      .rv0_axu0_instr_i0_itag(rv0_axu0_instr_i0_itag),
	      .rv0_axu0_instr_i0_ord(rv0_axu0_instr_i0_ord),
	      .rv0_axu0_instr_i0_cord(rv0_axu0_instr_i0_cord),
	      .rv0_axu0_instr_i0_t1_v(rv0_axu0_instr_i0_t1_v),
	      .rv0_axu0_instr_i0_t1_p(rv0_axu0_instr_i0_t1_p),
	      .rv0_axu0_instr_i0_t2_p(rv0_axu0_instr_i0_t2_p),
	      .rv0_axu0_instr_i0_t3_p(rv0_axu0_instr_i0_t3_p),
	      .rv0_axu0_instr_i0_s1_v(rv0_axu0_instr_i0_s1_v),
	      .rv0_axu0_instr_i0_s1_p(rv0_axu0_instr_i0_s1_p),
	      .rv0_axu0_instr_i0_s2_v(rv0_axu0_instr_i0_s2_v),
	      .rv0_axu0_instr_i0_s2_p(rv0_axu0_instr_i0_s2_p),
	      .rv0_axu0_instr_i0_s3_v(rv0_axu0_instr_i0_s3_v),
	      .rv0_axu0_instr_i0_s3_p(rv0_axu0_instr_i0_s3_p),
	      .rv0_axu0_instr_i0_isStore(rv0_axu0_instr_i0_isStore),
	      .rv0_axu0_instr_i0_spare(rv0_axu0_instr_i0_spare),
	      .rv0_axu0_instr_i1_vld(rv0_axu0_instr_i1_vld),
	      .rv0_axu0_instr_i1_rte_axu0(rv0_axu0_instr_i1_rte_axu0),
	      .rv0_axu0_instr_i1_instr(rv0_axu0_instr_i1_instr),
	      .rv0_axu0_instr_i1_ucode(rv0_axu0_instr_i1_ucode),
	      .rv0_axu0_instr_i1_itag(rv0_axu0_instr_i1_itag),
	      .rv0_axu0_instr_i1_ord(rv0_axu0_instr_i1_ord),
	      .rv0_axu0_instr_i1_cord(rv0_axu0_instr_i1_cord),
	      .rv0_axu0_instr_i1_t1_v(rv0_axu0_instr_i1_t1_v),
	      .rv0_axu0_instr_i1_t1_p(rv0_axu0_instr_i1_t1_p),
	      .rv0_axu0_instr_i1_t2_p(rv0_axu0_instr_i1_t2_p),
	      .rv0_axu0_instr_i1_t3_p(rv0_axu0_instr_i1_t3_p),
	      .rv0_axu0_instr_i1_s1_v(rv0_axu0_instr_i1_s1_v),
	      .rv0_axu0_instr_i1_s1_p(rv0_axu0_instr_i1_s1_p),
	      .rv0_axu0_instr_i1_s2_v(rv0_axu0_instr_i1_s2_v),
	      .rv0_axu0_instr_i1_s2_p(rv0_axu0_instr_i1_s2_p),
	      .rv0_axu0_instr_i1_s3_v(rv0_axu0_instr_i1_s3_v),
	      .rv0_axu0_instr_i1_s3_p(rv0_axu0_instr_i1_s3_p),
	      .rv0_axu0_instr_i1_isStore(rv0_axu0_instr_i1_isStore),
	      .rv0_axu0_instr_i1_spare(rv0_axu0_instr_i1_spare),
	      .rv0_axu0_instr_i0_s1_dep_hit(rv0_axu0_instr_i0_s1_dep_hit),
	      .rv0_axu0_instr_i0_s1_itag(rv0_axu0_instr_i0_s1_itag),
	      .rv0_axu0_instr_i0_s2_dep_hit(rv0_axu0_instr_i0_s2_dep_hit),
	      .rv0_axu0_instr_i0_s2_itag(rv0_axu0_instr_i0_s2_itag),
	      .rv0_axu0_instr_i0_s3_dep_hit(rv0_axu0_instr_i0_s3_dep_hit),
	      .rv0_axu0_instr_i0_s3_itag(rv0_axu0_instr_i0_s3_itag),
	      .rv0_axu0_instr_i1_s1_dep_hit(rv0_axu0_instr_i1_s1_dep_hit),
	      .rv0_axu0_instr_i1_s1_itag(rv0_axu0_instr_i1_s1_itag),
	      .rv0_axu0_instr_i1_s2_dep_hit(rv0_axu0_instr_i1_s2_dep_hit),
	      .rv0_axu0_instr_i1_s2_itag(rv0_axu0_instr_i1_s2_itag),
	      .rv0_axu0_instr_i1_s3_dep_hit(rv0_axu0_instr_i1_s3_dep_hit),
	      .rv0_axu0_instr_i1_s3_itag(rv0_axu0_instr_i1_s3_itag),

	      .rv_lq_rv1_i0_vld(rv_lq_rv1_i0_vld),
	      .rv_lq_rv1_i0_ucode_preissue(rv_lq_rv1_i0_ucode_preissue),
	      .rv_lq_rv1_i0_2ucode(rv_lq_rv1_i0_2ucode),
	      .rv_lq_rv1_i0_ucode_cnt(rv_lq_rv1_i0_ucode_cnt),
	      .rv_lq_rv1_i0_s3_t(rv_lq_rv1_i0_s3_t),
	      .rv_lq_rv1_i0_isLoad(rv_lq_rv1_i0_isLoad),
	      .rv_lq_rv1_i0_isStore(rv_lq_rv1_i0_isStore),
	      .rv_lq_rv1_i0_itag(rv_lq_rv1_i0_itag),
	      .rv_lq_rv1_i0_rte_lq(rv_lq_rv1_i0_rte_lq),
	      .rv_lq_rv1_i0_rte_sq(rv_lq_rv1_i0_rte_sq),
	      .rv_lq_rv1_i0_ifar(rv_lq_rv1_i0_ifar),

	      .rv_lq_rv1_i1_vld(rv_lq_rv1_i1_vld),
	      .rv_lq_rv1_i1_ucode_preissue(rv_lq_rv1_i1_ucode_preissue),
	      .rv_lq_rv1_i1_2ucode(rv_lq_rv1_i1_2ucode),
	      .rv_lq_rv1_i1_ucode_cnt(rv_lq_rv1_i1_ucode_cnt),
	      .rv_lq_rv1_i1_s3_t(rv_lq_rv1_i1_s3_t),
	      .rv_lq_rv1_i1_isLoad(rv_lq_rv1_i1_isLoad),
	      .rv_lq_rv1_i1_isStore(rv_lq_rv1_i1_isStore),
	      .rv_lq_rv1_i1_itag(rv_lq_rv1_i1_itag),
	      .rv_lq_rv1_i1_rte_lq(rv_lq_rv1_i1_rte_lq),
	      .rv_lq_rv1_i1_rte_sq(rv_lq_rv1_i1_rte_sq),
	      .rv_lq_rv1_i1_ifar(rv_lq_rv1_i1_ifar),


	      .vdd(vdd),
	      .gnd(gnd),
	      .nclk(nclk),
	      .func_sl_thold_1(func_sl_thold_1),
	      .sg_1(sg_1),
	      .clkoff_b(clkoff_dc_b),
	      .act_dis(act_dis),
	      .ccflush_dc(rp_rv_ccflush_dc),
	      .d_mode(d_mode),
	      .delay_lclkr(delay_lclkr_dc[0]),
	      .mpw1_b(mpw1_dc_b[0]),
	      .mpw2_b(mpw2_dc_b),
	      .scan_in(siv[rv_deps_offset]),
	      .scan_out(sov[rv_deps_offset])
	      );

   // Outputs

   //------------------------------------------------------------------------------------------------------------
   // Reservation Stations
   //------------------------------------------------------------------------------------------------------------

   //------------------------------------------------------------------------------------------------------------
   // fx0 reservation station
   //------------------------------------------------------------------------------------------------------------


   rv_fx0_rvs
     fx0_rvs(
	     .rv0_instr_i0_vld(rv0_fx0_instr_i0_vld),
	     .rv0_instr_i0_rte_fx0(rv0_fx0_instr_i0_rte_fx0),
	     .rv0_instr_i1_vld(rv0_fx0_instr_i1_vld),
	     .rv0_instr_i1_rte_fx0(rv0_fx0_instr_i1_rte_fx0),
	     .rv0_instr_i0_instr(rv0_fx0_instr_i0_instr),
	     .rv0_instr_i0_ifar(rv0_fx0_instr_i0_ifar),
	     .rv0_instr_i0_ucode(rv0_fx0_instr_i0_ucode),
	     .rv0_instr_i0_ucode_cnt(rv0_fx0_instr_i0_ucode_cnt),
	     .rv0_instr_i0_itag(rv0_fx0_instr_i0_itag),
	     .rv0_instr_i0_ord(rv0_fx0_instr_i0_ord),
	     .rv0_instr_i0_cord(rv0_fx0_instr_i0_cord),
	     .rv0_instr_i0_t1_v(rv0_fx0_instr_i0_t1_v),
	     .rv0_instr_i0_t1_p(rv0_fx0_instr_i0_t1_p),
	     .rv0_instr_i0_t1_t(rv0_fx0_instr_i0_t1_t),
	     .rv0_instr_i0_t2_v(rv0_fx0_instr_i0_t2_v),
	     .rv0_instr_i0_t2_p(rv0_fx0_instr_i0_t2_p),
	     .rv0_instr_i0_t2_t(rv0_fx0_instr_i0_t2_t),
	     .rv0_instr_i0_t3_v(rv0_fx0_instr_i0_t3_v),
	     .rv0_instr_i0_t3_p(rv0_fx0_instr_i0_t3_p),
	     .rv0_instr_i0_t3_t(rv0_fx0_instr_i0_t3_t),
	     .rv0_instr_i0_s1_v(rv0_fx0_instr_i0_s1_v),
	     .rv0_instr_i0_s1_p(rv0_fx0_instr_i0_s1_p),
	     .rv0_instr_i0_s1_t(rv0_fx0_instr_i0_s1_t),
	     .rv0_instr_i0_s2_v(rv0_fx0_instr_i0_s2_v),
	     .rv0_instr_i0_s2_p(rv0_fx0_instr_i0_s2_p),
	     .rv0_instr_i0_s2_t(rv0_fx0_instr_i0_s2_t),
	     .rv0_instr_i0_s3_v(rv0_fx0_instr_i0_s3_v),
	     .rv0_instr_i0_s3_p(rv0_fx0_instr_i0_s3_p),
	     .rv0_instr_i0_s3_t(rv0_fx0_instr_i0_s3_t),
	     .rv0_instr_i0_ilat(rv0_fx0_instr_i0_ilat),
	     .rv0_instr_i0_spare(rv0_fx0_instr_i0_spare),
	     .rv0_instr_i0_is_brick(rv0_fx0_instr_i0_is_brick),
	     .rv0_instr_i0_brick(rv0_fx0_instr_i0_brick),
	     .rv0_instr_i0_branch(rv0_fx0_instr_i0_branch),
	     .rv0_instr_i1_instr(rv0_fx0_instr_i1_instr),
	     .rv0_instr_i1_ifar(rv0_fx0_instr_i1_ifar),
	     .rv0_instr_i1_ucode(rv0_fx0_instr_i1_ucode),
	     .rv0_instr_i1_ucode_cnt(rv0_fx0_instr_i1_ucode_cnt),
	     .rv0_instr_i1_itag(rv0_fx0_instr_i1_itag),
	     .rv0_instr_i1_ord(rv0_fx0_instr_i1_ord),
	     .rv0_instr_i1_cord(rv0_fx0_instr_i1_cord),
	     .rv0_instr_i1_t1_v(rv0_fx0_instr_i1_t1_v),
	     .rv0_instr_i1_t1_p(rv0_fx0_instr_i1_t1_p),
	     .rv0_instr_i1_t1_t(rv0_fx0_instr_i1_t1_t),
	     .rv0_instr_i1_t2_v(rv0_fx0_instr_i1_t2_v),
	     .rv0_instr_i1_t2_p(rv0_fx0_instr_i1_t2_p),
	     .rv0_instr_i1_t2_t(rv0_fx0_instr_i1_t2_t),
	     .rv0_instr_i1_t3_v(rv0_fx0_instr_i1_t3_v),
	     .rv0_instr_i1_t3_p(rv0_fx0_instr_i1_t3_p),
	     .rv0_instr_i1_t3_t(rv0_fx0_instr_i1_t3_t),
	     .rv0_instr_i1_s1_v(rv0_fx0_instr_i1_s1_v),
	     .rv0_instr_i1_s1_p(rv0_fx0_instr_i1_s1_p),
	     .rv0_instr_i1_s1_t(rv0_fx0_instr_i1_s1_t),
	     .rv0_instr_i1_s2_v(rv0_fx0_instr_i1_s2_v),
	     .rv0_instr_i1_s2_p(rv0_fx0_instr_i1_s2_p),
	     .rv0_instr_i1_s2_t(rv0_fx0_instr_i1_s2_t),
	     .rv0_instr_i1_s3_v(rv0_fx0_instr_i1_s3_v),
	     .rv0_instr_i1_s3_p(rv0_fx0_instr_i1_s3_p),
	     .rv0_instr_i1_s3_t(rv0_fx0_instr_i1_s3_t),
	     .rv0_instr_i1_ilat(rv0_fx0_instr_i1_ilat),
	     .rv0_instr_i1_spare(rv0_fx0_instr_i1_spare),
	     .rv0_instr_i1_is_brick(rv0_fx0_instr_i1_is_brick),
	     .rv0_instr_i1_brick(rv0_fx0_instr_i1_brick),
	     .rv0_instr_i1_branch(rv0_fx0_instr_i1_branch),
	     .rv0_instr_i0_s1_dep_hit(rv0_fx0_instr_i0_s1_dep_hit),
	     .rv0_instr_i0_s1_itag(rv0_fx0_instr_i0_s1_itag),
	     .rv0_instr_i0_s2_dep_hit(rv0_fx0_instr_i0_s2_dep_hit),
	     .rv0_instr_i0_s2_itag(rv0_fx0_instr_i0_s2_itag),
	     .rv0_instr_i0_s3_dep_hit(rv0_fx0_instr_i0_s3_dep_hit),
	     .rv0_instr_i0_s3_itag(rv0_fx0_instr_i0_s3_itag),
	     .rv0_instr_i1_s1_dep_hit(rv0_fx0_instr_i1_s1_dep_hit),
	     .rv0_instr_i1_s1_itag(rv0_fx0_instr_i1_s1_itag),
	     .rv0_instr_i1_s2_dep_hit(rv0_fx0_instr_i1_s2_dep_hit),
	     .rv0_instr_i1_s2_itag(rv0_fx0_instr_i1_s2_itag),
	     .rv0_instr_i1_s3_dep_hit(rv0_fx0_instr_i1_s3_dep_hit),
	     .rv0_instr_i1_s3_itag(rv0_fx0_instr_i1_s3_itag),
	     .rv_iu_fx0_credit_free(rv_iu_fx0_credit_free),
	     .cp_flush(cp_flush),
	     .cp_next_itag(cp_next_itag),

	     .rv_byp_fx0_vld(rv_byp_fx0_vld),
	     .rv_byp_fx0_itag(rv_byp_fx0_itag),
	     .rv_byp_fx0_ord(rv_byp_fx0_ord),
	     .rv_byp_fx0_t1_v(rv_byp_fx0_t1_v),
	     .rv_byp_fx0_t1_t(rv_byp_fx0_t1_t),
	     .rv_byp_fx0_t2_v(rv_byp_fx0_t2_v),
	     .rv_byp_fx0_t2_t(rv_byp_fx0_t2_t),
	     .rv_byp_fx0_t3_v(rv_byp_fx0_t3_v),
	     .rv_byp_fx0_t3_t(rv_byp_fx0_t3_t),
	     .rv_byp_fx0_s1_t(rv_byp_fx0_s1_t),
	     .rv_byp_fx0_s2_t(rv_byp_fx0_s2_t),
	     .rv_byp_fx0_s3_t(rv_byp_fx0_s3_t),
	     .rv_byp_fx0_ilat(rv_byp_fx0_ilat),
	     .rv_byp_fx0_ex0_is_brick(rv_byp_fx0_ex0_is_brick),

	     .rv_fx0_vld(rv_fx0_vld),
	     .rv_fx0_s1_v(rv_fx0_s1_v),
	     .rv_fx0_s1_p(rv_fx0_s1_p),
	     .rv_fx0_s2_v(rv_fx0_s2_v),
	     .rv_fx0_s2_p(rv_fx0_s2_p),
	     .rv_fx0_s3_v(rv_fx0_s3_v),
	     .rv_fx0_s3_p(rv_fx0_s3_p),

	     .rv_fx0_ex0_itag(rv_fx0_ex0_itag),
	     .rv_fx0_ex0_ifar(rv_fx0_ex0_ifar),
	     .rv_fx0_ex0_instr(rv_fx0_ex0_instr),
	     .rv_fx0_ex0_ucode(rv_fx0_ex0_ucode),
	     .rv_fx0_ex0_ucode_cnt(rv_fx0_ex0_ucode_cnt),
	     .rv_fx0_ex0_ord(rv_fx0_ex0_ord),
	     .rv_fx0_ex0_t1_v(rv_fx0_ex0_t1_v),
	     .rv_fx0_ex0_t1_p(rv_fx0_ex0_t1_p),
	     .rv_fx0_ex0_t1_t(rv_fx0_ex0_t1_t),
	     .rv_fx0_ex0_t2_v(rv_fx0_ex0_t2_v),
	     .rv_fx0_ex0_t2_p(rv_fx0_ex0_t2_p),
	     .rv_fx0_ex0_t2_t(rv_fx0_ex0_t2_t),
	     .rv_fx0_ex0_t3_v(rv_fx0_ex0_t3_v),
	     .rv_fx0_ex0_t3_p(rv_fx0_ex0_t3_p),
	     .rv_fx0_ex0_t3_t(rv_fx0_ex0_t3_t),
	     .rv_fx0_ex0_s1_v(rv_fx0_ex0_s1_v),
	     .rv_fx0_ex0_s2_v(rv_fx0_ex0_s2_v),
	     .rv_fx0_ex0_s2_t(rv_fx0_ex0_s2_t),
	     .rv_fx0_ex0_s3_v(rv_fx0_ex0_s3_v),
	     .rv_fx0_ex0_s3_t(rv_fx0_ex0_s3_t),
	     .rv_fx0_ex0_branch(rv_fx0_ex0_branch),

	     .rv_byp_fx0_s1_itag(rv_byp_fx0_s1_itag),
	     .rv_byp_fx0_s2_itag(rv_byp_fx0_s2_itag),
	     .rv_byp_fx0_s3_itag(rv_byp_fx0_s3_itag),

	     .fx0_rv_itag_vld(fx0_rv_itag_vld),
	     .fx0_rv_itag(fx0_rv_itag),
	     .fx1_rv_itag_vld(fx1_rv_itag_vld),
	     .fx1_rv_itag(fx1_rv_itag),
	     .axu0_rv_ext_itag_vld(axu0_rv_ext_itag_vld),
	     .axu0_rv_ext_itag(axu0_rv_ext_itag),
	     .axu1_rv_ext_itag_vld(axu1_rv_ext_itag_vld),
	     .axu1_rv_ext_itag(axu1_rv_ext_itag),
	     .lq_rv_ext_itag0_vld(lq_rv_ext_itag0_vld),
	     .lq_rv_ext_itag0(lq_rv_ext_itag0),
	     .lq_rv_ext_itag1_vld(lq_rv_ext_itag1_vld),
	     .lq_rv_ext_itag1(lq_rv_ext_itag1),
	     .lq_rv_ext_itag2_vld(lq_rv_ext_itag2_vld),
	     .lq_rv_ext_itag2(lq_rv_ext_itag2),

	     .lq_rv_itag1_vld(lq_rv_itag1_vld),
	     .lq_rv_itag1(lq_rv_itag1),
	     .lq_rv_itag1_restart(lq_rv_itag1_restart),
	     .lq_rv_itag1_hold(lq_rv_itag1_hold),
	     .lq_rv_clr_hold(lq_rv_clr_hold),

	     .fx0_rv_ex2_s1_abort(fx0_rv_ex2_s1_abort),
	     .fx0_rv_ex2_s2_abort(fx0_rv_ex2_s2_abort),
	     .fx0_rv_ex2_s3_abort(fx0_rv_ex2_s3_abort),

	     .fx0_rv_itag_abort(fx0_rv_itag_abort),
	     .fx1_rv_itag_abort(fx1_rv_itag_abort),
	     .lq_rv_ext_itag0_abort(lq_rv_ext_itag0_abort),
	     .lq_rv_ext_itag1_abort(lq_rv_ext_itag1_abort),
	     .axu0_rv_ext_itag_abort(axu0_rv_ext_itag_abort),
	     .axu1_rv_ext_itag_abort(axu1_rv_ext_itag_abort),

	     .fx0_rv_ord_complete(fx0_release_ord_hold),
	     .fx0_rv_ord_tid(fx0_rv_ord_tid),
	     .fx0_rv_hold_all(fx0_rv_hold_all),
	     .rv_byp_fx0_ilat0_vld(rv_byp_fx0_ilat0_vld),
	     .rv_byp_fx0_ilat1_vld(rv_byp_fx0_ilat1_vld),
	     .rv1_fx0_ilat0_vld(rv1_fx0_ilat0_vld),
	     .rv1_fx0_ilat0_itag(rv1_fx0_ilat0_itag),
	     .rv1_fx1_ilat0_vld(rv1_fx1_ilat0_vld),
	     .rv1_fx1_ilat0_itag(rv1_fx1_ilat0_itag),
	     .fx0_rvs_perf_bus(fx0_rvs_perf_bus),
	     .fx0_rvs_dbg_bus(fx0_rvs_dbg_bus),
	     .vdd(vdd),
	     .gnd(gnd),
	     .nclk(nclk),
	     .func_sl_thold_1(func_sl_thold_1),
	     .sg_1(sg_1),
	     .clkoff_b(clkoff_dc_b),
	     .act_dis(act_dis),
	     .ccflush_dc(rp_rv_ccflush_dc),
	     .d_mode(d_mode),
	     .delay_lclkr(delay_lclkr_dc[0]),
	     .mpw1_b(mpw1_dc_b[0]),
	     .mpw2_b(mpw2_dc_b),
	     .scan_in(siv[rv_fx0_rvs_offset]),
	     .scan_out(sov[rv_fx0_rvs_offset])
	     );

   //------------------------------------------------------------------------------------------------------------
   // fx1 reservation station
   //------------------------------------------------------------------------------------------------------------


   rv_fx1_rvs
     fx1_rvs(
	     .rv0_instr_i0_vld(rv0_fx1_instr_i0_vld),
	     .rv0_instr_i0_rte_fx1(rv0_fx1_instr_i0_rte_fx1),
	     .rv0_instr_i1_vld(rv0_fx1_instr_i1_vld),
	     .rv0_instr_i1_rte_fx1(rv0_fx1_instr_i1_rte_fx1),
	     .rv0_instr_i0_instr(rv0_fx1_instr_i0_instr),
	     .rv0_instr_i0_ucode(rv0_fx1_instr_i0_ucode),
	     .rv0_instr_i0_itag(rv0_fx1_instr_i0_itag),
	     .rv0_instr_i0_t1_v(rv0_fx1_instr_i0_t1_v),
	     .rv0_instr_i0_t1_p(rv0_fx1_instr_i0_t1_p),
	     .rv0_instr_i0_t2_v(rv0_fx1_instr_i0_t2_v),
	     .rv0_instr_i0_t2_p(rv0_fx1_instr_i0_t2_p),
	     .rv0_instr_i0_t3_v(rv0_fx1_instr_i0_t3_v),
	     .rv0_instr_i0_t3_p(rv0_fx1_instr_i0_t3_p),
	     .rv0_instr_i0_s1_v(rv0_fx1_instr_i0_s1_v),
	     .rv0_instr_i0_s1_p(rv0_fx1_instr_i0_s1_p),
	     .rv0_instr_i0_s1_t(rv0_fx1_instr_i0_s1_t),
	     .rv0_instr_i0_s2_v(rv0_fx1_instr_i0_s2_v),
	     .rv0_instr_i0_s2_p(rv0_fx1_instr_i0_s2_p),
	     .rv0_instr_i0_s2_t(rv0_fx1_instr_i0_s2_t),
	     .rv0_instr_i0_s3_v(rv0_fx1_instr_i0_s3_v),
	     .rv0_instr_i0_s3_p(rv0_fx1_instr_i0_s3_p),
	     .rv0_instr_i0_s3_t(rv0_fx1_instr_i0_s3_t),
	     .rv0_instr_i0_ilat(rv0_fx1_instr_i0_ilat),
	     .rv0_instr_i0_isStore(rv0_fx1_instr_i0_isStore),
	     .rv0_instr_i0_spare(rv0_fx1_instr_i0_spare),
	     .rv0_instr_i0_is_brick(rv0_fx1_instr_i0_is_brick),
	     .rv0_instr_i0_brick(rv0_fx1_instr_i0_brick),
	     .rv0_instr_i1_instr(rv0_fx1_instr_i1_instr),
	     .rv0_instr_i1_ucode(rv0_fx1_instr_i1_ucode),
	     .rv0_instr_i1_itag(rv0_fx1_instr_i1_itag),
	     .rv0_instr_i1_t1_v(rv0_fx1_instr_i1_t1_v),
	     .rv0_instr_i1_t1_p(rv0_fx1_instr_i1_t1_p),
	     .rv0_instr_i1_t2_v(rv0_fx1_instr_i1_t2_v),
	     .rv0_instr_i1_t2_p(rv0_fx1_instr_i1_t2_p),
	     .rv0_instr_i1_t3_v(rv0_fx1_instr_i1_t3_v),
	     .rv0_instr_i1_t3_p(rv0_fx1_instr_i1_t3_p),
	     .rv0_instr_i1_s1_v(rv0_fx1_instr_i1_s1_v),
	     .rv0_instr_i1_s1_p(rv0_fx1_instr_i1_s1_p),
	     .rv0_instr_i1_s1_t(rv0_fx1_instr_i1_s1_t),
	     .rv0_instr_i1_s2_v(rv0_fx1_instr_i1_s2_v),
	     .rv0_instr_i1_s2_p(rv0_fx1_instr_i1_s2_p),
	     .rv0_instr_i1_s2_t(rv0_fx1_instr_i1_s2_t),
	     .rv0_instr_i1_s3_v(rv0_fx1_instr_i1_s3_v),
	     .rv0_instr_i1_s3_p(rv0_fx1_instr_i1_s3_p),
	     .rv0_instr_i1_s3_t(rv0_fx1_instr_i1_s3_t),
	     .rv0_instr_i1_ilat(rv0_fx1_instr_i1_ilat),
	     .rv0_instr_i1_isStore(rv0_fx1_instr_i1_isStore),
	     .rv0_instr_i1_spare(rv0_fx1_instr_i1_spare),
	     .rv0_instr_i1_is_brick(rv0_fx1_instr_i1_is_brick),
	     .rv0_instr_i1_brick(rv0_fx1_instr_i1_brick),
	     .rv0_instr_i0_s1_dep_hit(rv0_fx1_instr_i0_s1_dep_hit),
	     .rv0_instr_i0_s1_itag(rv0_fx1_instr_i0_s1_itag),
	     .rv0_instr_i0_s2_dep_hit(rv0_fx1_instr_i0_s2_dep_hit),
	     .rv0_instr_i0_s2_itag(rv0_fx1_instr_i0_s2_itag),
	     .rv0_instr_i0_s3_dep_hit(rv0_fx1_instr_i0_s3_dep_hit),
	     .rv0_instr_i0_s3_itag(rv0_fx1_instr_i0_s3_itag),
	     .rv0_instr_i1_s1_dep_hit(rv0_fx1_instr_i1_s1_dep_hit),
	     .rv0_instr_i1_s1_itag(rv0_fx1_instr_i1_s1_itag),
	     .rv0_instr_i1_s2_dep_hit(rv0_fx1_instr_i1_s2_dep_hit),
	     .rv0_instr_i1_s2_itag(rv0_fx1_instr_i1_s2_itag),
	     .rv0_instr_i1_s3_dep_hit(rv0_fx1_instr_i1_s3_dep_hit),
	     .rv0_instr_i1_s3_itag(rv0_fx1_instr_i1_s3_itag),
	     .rv_iu_fx1_credit_free(rv_iu_fx1_credit_free),
	     .cp_flush(cp_flush),

	     .rv_byp_fx1_vld(rv_byp_fx1_vld),
	     .rv_byp_fx1_itag(rv_byp_fx1_itag),
	     .rv_byp_fx1_t1_v(rv_byp_fx1_t1_v),
	     .rv_byp_fx1_t2_v(rv_byp_fx1_t2_v),
	     .rv_byp_fx1_t3_v(rv_byp_fx1_t3_v),
	     .rv_byp_fx1_s1_t(rv_byp_fx1_s1_t),
	     .rv_byp_fx1_s2_t(rv_byp_fx1_s2_t),
	     .rv_byp_fx1_s3_t(rv_byp_fx1_s3_t),
	     .rv_byp_fx1_ilat(rv_byp_fx1_ilat),
	     .rv_byp_fx1_ex0_isStore(rv_byp_fx1_ex0_isStore),

	     .rv_fx1_vld(rv_fx1_vld),
	     .rv_fx1_s1_v(rv_fx1_s1_v),
	     .rv_fx1_s1_p(rv_fx1_s1_p),
	     .rv_fx1_s2_v(rv_fx1_s2_v),
	     .rv_fx1_s2_p(rv_fx1_s2_p),
	     .rv_fx1_s3_v(rv_fx1_s3_v),
	     .rv_fx1_s3_p(rv_fx1_s3_p),

	     .rv_fx1_ex0_itag(rv_fx1_ex0_itag),
	     .rv_fx1_ex0_instr(rv_fx1_ex0_instr),
	     .rv_fx1_ex0_ucode(rv_fx1_ex0_ucode),
	     .rv_fx1_ex0_t1_v(rv_fx1_ex0_t1_v),
	     .rv_fx1_ex0_t1_p(rv_fx1_ex0_t1_p),
	     .rv_fx1_ex0_t2_v(rv_fx1_ex0_t2_v),
	     .rv_fx1_ex0_t2_p(rv_fx1_ex0_t2_p),
	     .rv_fx1_ex0_t3_v(rv_fx1_ex0_t3_v),
	     .rv_fx1_ex0_t3_p(rv_fx1_ex0_t3_p),
	     .rv_fx1_ex0_s1_v(rv_fx1_ex0_s1_v),
	     .rv_fx1_ex0_s3_t(rv_fx1_ex0_s3_t),
	     .rv_fx1_ex0_isStore(rv_fx1_ex0_isStore),

	     .rv_byp_fx1_s1_itag(rv_byp_fx1_s1_itag),
	     .rv_byp_fx1_s2_itag(rv_byp_fx1_s2_itag),
	     .rv_byp_fx1_s3_itag(rv_byp_fx1_s3_itag),

	     .fx1_rv_ex2_s1_abort(fx1_rv_ex2_s1_abort),
	     .fx1_rv_ex2_s2_abort(fx1_rv_ex2_s2_abort),
	     .fx1_rv_ex2_s3_abort(fx1_rv_ex2_s3_abort),

	     .fx0_rv_itag_vld(fx0_rv_itag_vld),
	     .fx0_rv_itag(fx0_rv_itag),
	     .fx1_rv_itag_vld(fx1_rv_itag_vld),
	     .fx1_rv_itag(fx1_rv_itag),
	     .axu0_rv_ext_itag_vld(axu0_rv_ext_itag_vld),
	     .axu0_rv_ext_itag(axu0_rv_ext_itag),
	     .axu1_rv_ext_itag_vld(axu1_rv_ext_itag_vld),
	     .axu1_rv_ext_itag(axu1_rv_ext_itag),
	     .lq_rv_ext_itag0_vld(lq_rv_ext_itag0_vld),
	     .lq_rv_ext_itag0(lq_rv_ext_itag0),
	     .lq_rv_ext_itag1_vld(lq_rv_ext_itag1_vld),
	     .lq_rv_ext_itag1(lq_rv_ext_itag1),
	     .lq_rv_ext_itag2_vld(lq_rv_ext_itag2_vld),
	     .lq_rv_ext_itag2(lq_rv_ext_itag2),

	     .lq_rv_itag1_vld(lq_rv_itag1_vld),
	     .lq_rv_itag1(lq_rv_itag1),
	     .lq_rv_itag1_restart(lq_rv_itag1_restart),
	     .lq_rv_itag1_hold(lq_rv_itag1_hold),
	     .lq_rv_clr_hold(lq_rv_clr_hold),

	     .fx0_rv_itag_abort(fx0_rv_itag_abort),
	     .fx1_rv_itag_abort(fx1_rv_itag_abort),
	     .lq_rv_ext_itag0_abort(lq_rv_ext_itag0_abort),
	     .lq_rv_ext_itag1_abort(lq_rv_ext_itag1_abort),
	     .axu0_rv_ext_itag_abort(axu0_rv_ext_itag_abort),
	     .axu1_rv_ext_itag_abort(axu1_rv_ext_itag_abort),

	     .fx1_rv_hold_all(fx1_rv_hold_all),
	     .rv_byp_fx1_ilat0_vld(rv_byp_fx1_ilat0_vld),
	     .rv_byp_fx1_ilat1_vld(rv_byp_fx1_ilat1_vld),
	     .rv1_fx0_ilat0_vld(rv1_fx0_ilat0_vld),
	     .rv1_fx0_ilat0_itag(rv1_fx0_ilat0_itag),
	     .rv1_fx1_ilat0_vld(rv1_fx1_ilat0_vld),
	     .rv1_fx1_ilat0_itag(rv1_fx1_ilat0_itag),
	     .fx1_rvs_perf_bus(fx1_rvs_perf_bus),
	     .fx1_rvs_dbg_bus(fx1_rvs_dbg_bus),
	     .vdd(vdd),
	     .gnd(gnd),
	     .nclk(nclk),
	     .func_sl_thold_1(func_sl_thold_1),
	     .sg_1(sg_1),
	     .clkoff_b(clkoff_dc_b),
	     .act_dis(act_dis),
	     .ccflush_dc(rp_rv_ccflush_dc),
	     .d_mode(d_mode),
	     .delay_lclkr(delay_lclkr_dc[0]),
	     .mpw1_b(mpw1_dc_b[0]),
	     .mpw2_b(mpw2_dc_b),
	     .scan_in(siv[rv_fx1_rvs_offset]),
	     .scan_out(sov[rv_fx1_rvs_offset])
	     );

   //------------------------------------------------------------------------------------------------------------
   // lq reservation station
   //------------------------------------------------------------------------------------------------------------


   rv_lq_rvs
     lq0_rvs(
	     .rv0_instr_i0_vld(rv0_lq_instr_i0_vld),
	     .rv0_instr_i0_rte(rv0_lq_instr_i0_rte_lq),
	     .rv0_instr_i1_vld(rv0_lq_instr_i1_vld),
	     .rv0_instr_i1_rte(rv0_lq_instr_i1_rte_lq),
	     .rv0_instr_i0_instr(rv0_lq_instr_i0_instr),
	     .rv0_instr_i0_ucode(rv0_lq_instr_i0_ucode),
	     .rv0_instr_i0_ucode_cnt(rv0_lq_instr_i0_ucode_cnt),
	     .rv0_instr_i0_itag(rv0_lq_instr_i0_itag),
	     .rv0_instr_i0_ord(rv0_lq_instr_i0_ord),
	     .rv0_instr_i0_cord(rv0_lq_instr_i0_cord),
	     .rv0_instr_i0_spec(rv0_lq_instr_i0_spec),
	     .rv0_instr_i0_t1_v(rv0_lq_instr_i0_t1_v),
	     .rv0_instr_i0_t1_p(rv0_lq_instr_i0_t1_p),
	     .rv0_instr_i0_t2_v(rv0_lq_instr_i0_t2_v),
	     .rv0_instr_i0_t2_p(rv0_lq_instr_i0_t2_p),
	     .rv0_instr_i0_t2_t(rv0_lq_instr_i0_t2_t),
	     .rv0_instr_i0_t3_v(rv0_lq_instr_i0_t3_v),
	     .rv0_instr_i0_t3_p(rv0_lq_instr_i0_t3_p),
	     .rv0_instr_i0_t3_t(rv0_lq_instr_i0_t3_t),
	     .rv0_instr_i0_s1_v(rv0_lq_instr_i0_s1_v),
	     .rv0_instr_i0_s1_p(rv0_lq_instr_i0_s1_p),
	     .rv0_instr_i0_s1_t(rv0_lq_instr_i0_s1_t),
	     .rv0_instr_i0_s2_v(rv0_lq_instr_i0_s2_v),
	     .rv0_instr_i0_s2_p(rv0_lq_instr_i0_s2_p),
	     .rv0_instr_i0_s2_t(rv0_lq_instr_i0_s2_t),
	     .rv0_instr_i0_isLoad(rv0_lq_instr_i0_isLoad),
	     .rv0_instr_i0_spare(rv0_lq_instr_i0_spare),
	     .rv0_instr_i0_is_brick(rv0_lq_instr_i0_is_brick),
	     .rv0_instr_i0_brick(rv0_lq_instr_i0_brick),
	     .rv0_instr_i1_instr(rv0_lq_instr_i1_instr),
	     .rv0_instr_i1_ucode(rv0_lq_instr_i1_ucode),
	     .rv0_instr_i1_ucode_cnt(rv0_lq_instr_i1_ucode_cnt),
	     .rv0_instr_i1_itag(rv0_lq_instr_i1_itag),
	     .rv0_instr_i1_ord(rv0_lq_instr_i1_ord),
	     .rv0_instr_i1_cord(rv0_lq_instr_i1_cord),
	     .rv0_instr_i1_spec(rv0_lq_instr_i1_spec),
	     .rv0_instr_i1_t1_v(rv0_lq_instr_i1_t1_v),
	     .rv0_instr_i1_t1_p(rv0_lq_instr_i1_t1_p),
	     .rv0_instr_i1_t2_v(rv0_lq_instr_i1_t2_v),
	     .rv0_instr_i1_t2_p(rv0_lq_instr_i1_t2_p),
	     .rv0_instr_i1_t2_t(rv0_lq_instr_i1_t2_t),
	     .rv0_instr_i1_t3_v(rv0_lq_instr_i1_t3_v),
	     .rv0_instr_i1_t3_p(rv0_lq_instr_i1_t3_p),
	     .rv0_instr_i1_t3_t(rv0_lq_instr_i1_t3_t),
	     .rv0_instr_i1_s1_v(rv0_lq_instr_i1_s1_v),
	     .rv0_instr_i1_s1_p(rv0_lq_instr_i1_s1_p),
	     .rv0_instr_i1_s1_t(rv0_lq_instr_i1_s1_t),
	     .rv0_instr_i1_s2_v(rv0_lq_instr_i1_s2_v),
	     .rv0_instr_i1_s2_p(rv0_lq_instr_i1_s2_p),
	     .rv0_instr_i1_s2_t(rv0_lq_instr_i1_s2_t),
	     .rv0_instr_i1_isLoad(rv0_lq_instr_i1_isLoad),
	     .rv0_instr_i1_spare(rv0_lq_instr_i1_spare),
	     .rv0_instr_i1_is_brick(rv0_lq_instr_i1_is_brick),
	     .rv0_instr_i1_brick(rv0_lq_instr_i1_brick),
	     .rv0_instr_i0_s1_dep_hit(rv0_lq_instr_i0_s1_dep_hit),
	     .rv0_instr_i0_s1_itag(rv0_lq_instr_i0_s1_itag),
	     .rv0_instr_i0_s2_dep_hit(rv0_lq_instr_i0_s2_dep_hit),
	     .rv0_instr_i0_s2_itag(rv0_lq_instr_i0_s2_itag),
	     .rv0_instr_i1_s1_dep_hit(rv0_lq_instr_i1_s1_dep_hit),
	     .rv0_instr_i1_s1_itag(rv0_lq_instr_i1_s1_itag),
	     .rv0_instr_i1_s2_dep_hit(rv0_lq_instr_i1_s2_dep_hit),
	     .rv0_instr_i1_s2_itag(rv0_lq_instr_i1_s2_itag),
	     .rv_iu_lq_credit_free(rv_iu_lq_credit_free),

	     .cp_flush(cp_flush),
	     .cp_next_itag(cp_next_itag),

	     .rv_lq_vld(rv_byp_lq_vld),
	     .rv_lq_itag(rv_byp_lq_itag),
	     .rv_lq_t1_v(rv_byp_lq_t1_v),
	     .rv_lq_t3_v(rv_byp_lq_t3_v),
	     .rv_lq_t3_t(rv_byp_lq_t3_t),
	     .rv_lq_s1_v(rv_byp_lq_s1_v),
	     .rv_lq_s1_t(rv_byp_lq_s1_t),
	     .rv_lq_s1_p(rv_byp_lq_s1_p),
	     .rv_lq_s2_v(rv_byp_lq_s2_v),
	     .rv_lq_s2_t(rv_byp_lq_s2_t),
	     .rv_lq_s2_p(rv_byp_lq_s2_p),
	     .rv_lq_isLoad(rv_lq_isLoad),
	     .rv_lq_ex0_s1_itag(rv_byp_lq_ex0_s1_itag),
	     .rv_lq_ex0_s2_itag(rv_byp_lq_ex0_s2_itag),

	     .rv_lq_ex0_itag(rv_lq_ex0_itag),
	     .rv_lq_ex0_instr(rv_lq_ex0_instr),
	     .rv_lq_ex0_ucode(rv_lq_ex0_ucode),
	     .rv_lq_ex0_ucode_cnt(rv_lq_ex0_ucode_cnt),
	     .rv_lq_ex0_spec(rv_lq_ex0_spec),
	     .rv_lq_ex0_t1_v(rv_lq_ex0_t1_v),
	     .rv_lq_ex0_t1_p(rv_lq_ex0_t1_p),
	     .rv_lq_ex0_t3_p(rv_lq_ex0_t3_p),
	     .rv_lq_ex0_s1_v(rv_lq_ex0_s1_v),
	     .rv_lq_ex0_s2_v(rv_lq_ex0_s2_v),
	     .rv_lq_ex0_s2_t(rv_lq_ex0_s2_t),
	     .rv_lq_rvs_empty(rv_lq_rvs_empty),

	     .lq_rv_ex2_s1_abort(lq_rv_ex2_s1_abort),
	     .lq_rv_ex2_s2_abort(lq_rv_ex2_s2_abort),

	     .fx0_rv_ext_itag_vld(fx0_rv_ext_itag_vld),
	     .fx0_rv_ext_itag(fx0_rv_ext_itag),
	     .fx1_rv_ext_itag_vld(fx1_rv_ext_itag_vld),
	     .fx1_rv_ext_itag(fx1_rv_ext_itag),
	     .axu0_rv_ext_itag_vld(axu0_rv_ext_itag_vld),
	     .axu0_rv_ext_itag(axu0_rv_ext_itag),
	     .axu1_rv_ext_itag_vld(axu1_rv_ext_itag_vld),
	     .axu1_rv_ext_itag(axu1_rv_ext_itag),

	     .lq_rv_itag0_vld(lq_rv_itag0_vld),
	     .lq_rv_itag0(lq_rv_itag0),
	     .lq_rv_itag1_vld(lq_rv_itag1_vld),
	     .lq_rv_itag1(lq_rv_itag1),
	     .lq_rv_itag1_restart(lq_rv_itag1_restart),
	     .lq_rv_itag1_hold(lq_rv_itag1_hold),
	     .lq_rv_itag1_cord(lq_rv_itag1_cord),
	     .lq_rv_itag2_vld(lq_rv_itag2_vld),
	     .lq_rv_itag2(lq_rv_itag2),
	     .lq_rv_clr_hold(lq_rv_clr_hold),
	     .lq_rv_ord_complete(lq_rv_ord_complete),
	     .lq_rv_hold_all(lq_rv_hold_all),

	     .fx0_rv_ext_itag_abort(fx0_rv_ext_itag_abort),
	     .fx1_rv_ext_itag_abort(fx1_rv_ext_itag_abort),
	     .lq_rv_itag0_abort(lq_rv_itag0_abort),
	     .lq_rv_itag1_abort(lq_rv_itag1_abort),
	     .axu0_rv_ext_itag_abort(axu0_rv_ext_itag_abort),
	     .axu1_rv_ext_itag_abort(axu1_rv_ext_itag_abort),

	     .lq_rv_ext_itag0_vld(lq_rv_ext_itag0_vld),
	     .lq_rv_ext_itag0_abort(lq_rv_ext_itag0_abort),
	     .lq_rv_ext_itag0(lq_rv_ext_itag0),
	     .lq_rv_ext_itag1_vld(lq_rv_ext_itag1_vld),
	     .lq_rv_ext_itag1_abort(lq_rv_ext_itag1_abort),
	     .lq_rv_ext_itag1(lq_rv_ext_itag1),
	     .lq_rv_ext_itag2_vld(lq_rv_ext_itag2_vld),
	     .lq_rv_ext_itag2(lq_rv_ext_itag2),
	     .lq_rvs_perf_bus(lq_rvs_perf_bus),
	     .lq_rvs_dbg_bus(lq_rvs_dbg_bus),

	     .vdd(vdd),
	     .gnd(gnd),
	     .nclk(nclk),
	     .func_sl_thold_1(func_sl_thold_1),
	     .sg_1(sg_1),
	     .clkoff_b(clkoff_dc_b),
	     .act_dis(act_dis),
	     .ccflush_dc(rp_rv_ccflush_dc),
	     .d_mode(d_mode),
	     .delay_lclkr(delay_lclkr_dc[0]),
	     .mpw1_b(mpw1_dc_b[0]),
	     .mpw2_b(mpw2_dc_b),
	     .scan_in(siv[rv_lq_rvs_offset]),
	     .scan_out(sov[rv_lq_rvs_offset])
	     );

   // Bypass
   assign rv_lq_vld = rv_byp_lq_vld;

   //------------------------------------------------------------------------------------------------------------
   // sq reservation station
   //------------------------------------------------------------------------------------------------------------

   //------------------------------------------------------------------------------------------------------------
   // br reservation station
   //------------------------------------------------------------------------------------------------------------

   //------------------------------------------------------------------------------------------------------------
   // axu0 reservation station
   //------------------------------------------------------------------------------------------------------------


   rv_axu0_rvs
     axu0_rvs(
	      .rv0_instr_i0_vld(rv0_axu0_instr_i0_vld),
	      .rv0_instr_i0_rte_axu0(rv0_axu0_instr_i0_rte_axu0),
	      .rv0_instr_i1_vld(rv0_axu0_instr_i1_vld),
	      .rv0_instr_i1_rte_axu0(rv0_axu0_instr_i1_rte_axu0),
	      .rv0_instr_i0_instr(rv0_axu0_instr_i0_instr),
	      .rv0_instr_i0_ucode(rv0_axu0_instr_i0_ucode),
	      .rv0_instr_i0_itag(rv0_axu0_instr_i0_itag),
	      .rv0_instr_i0_ord(rv0_axu0_instr_i0_ord),
	      .rv0_instr_i0_cord(rv0_axu0_instr_i0_cord),
	      .rv0_instr_i0_t1_v(rv0_axu0_instr_i0_t1_v),
	      .rv0_instr_i0_t1_p(rv0_axu0_instr_i0_t1_p),
	      .rv0_instr_i0_t2_p(rv0_axu0_instr_i0_t2_p),
	      .rv0_instr_i0_t3_p(rv0_axu0_instr_i0_t3_p),
	      .rv0_instr_i0_s1_v(rv0_axu0_instr_i0_s1_v),
	      .rv0_instr_i0_s1_p(rv0_axu0_instr_i0_s1_p),
	      .rv0_instr_i0_s2_v(rv0_axu0_instr_i0_s2_v),
	      .rv0_instr_i0_s2_p(rv0_axu0_instr_i0_s2_p),
	      .rv0_instr_i0_s3_v(rv0_axu0_instr_i0_s3_v),
	      .rv0_instr_i0_s3_p(rv0_axu0_instr_i0_s3_p),
	      .rv0_instr_i0_spare(rv0_axu0_instr_i0_spare),
	      .rv0_instr_i0_isStore(rv0_axu0_instr_i0_isStore),
	      .rv0_instr_i1_instr(rv0_axu0_instr_i1_instr),
	      .rv0_instr_i1_ucode(rv0_axu0_instr_i1_ucode),
	      .rv0_instr_i1_itag(rv0_axu0_instr_i1_itag),
	      .rv0_instr_i1_ord(rv0_axu0_instr_i1_ord),
	      .rv0_instr_i1_cord(rv0_axu0_instr_i1_cord),
	      .rv0_instr_i1_t1_v(rv0_axu0_instr_i1_t1_v),
	      .rv0_instr_i1_t1_p(rv0_axu0_instr_i1_t1_p),
	      .rv0_instr_i1_t2_p(rv0_axu0_instr_i1_t2_p),
	      .rv0_instr_i1_t3_p(rv0_axu0_instr_i1_t3_p),
	      .rv0_instr_i1_s1_v(rv0_axu0_instr_i1_s1_v),
	      .rv0_instr_i1_s1_p(rv0_axu0_instr_i1_s1_p),
	      .rv0_instr_i1_s2_v(rv0_axu0_instr_i1_s2_v),
	      .rv0_instr_i1_s2_p(rv0_axu0_instr_i1_s2_p),
	      .rv0_instr_i1_s3_v(rv0_axu0_instr_i1_s3_v),
	      .rv0_instr_i1_s3_p(rv0_axu0_instr_i1_s3_p),
	      .rv0_instr_i1_isStore(rv0_axu0_instr_i1_isStore),
	      .rv0_instr_i1_spare(rv0_axu0_instr_i1_spare),
	      .rv0_instr_i0_s1_dep_hit(rv0_axu0_instr_i0_s1_dep_hit),
	      .rv0_instr_i0_s1_itag(rv0_axu0_instr_i0_s1_itag),
	      .rv0_instr_i0_s2_dep_hit(rv0_axu0_instr_i0_s2_dep_hit),
	      .rv0_instr_i0_s2_itag(rv0_axu0_instr_i0_s2_itag),
	      .rv0_instr_i0_s3_dep_hit(rv0_axu0_instr_i0_s3_dep_hit),
	      .rv0_instr_i0_s3_itag(rv0_axu0_instr_i0_s3_itag),
	      .rv0_instr_i1_s1_dep_hit(rv0_axu0_instr_i1_s1_dep_hit),
	      .rv0_instr_i1_s1_itag(rv0_axu0_instr_i1_s1_itag),
	      .rv0_instr_i1_s2_dep_hit(rv0_axu0_instr_i1_s2_dep_hit),
	      .rv0_instr_i1_s2_itag(rv0_axu0_instr_i1_s2_itag),
	      .rv0_instr_i1_s3_dep_hit(rv0_axu0_instr_i1_s3_dep_hit),
	      .rv0_instr_i1_s3_itag(rv0_axu0_instr_i1_s3_itag),
	      .rv_iu_axu0_credit_free(rv_iu_axu0_credit_free),
	      .axu0_rv_ord_complete(axu0_rv_ord_complete),
              .axu0_rv_hold_all(axu0_rv_hold_all),
	      .cp_flush(cp_flush),
	      .cp_next_itag(cp_next_itag),
	      .rv_axu0_vld(rv_axu0_vld),
	      .rv_axu0_s1_v(rv_axu0_s1_v),
	      .rv_axu0_s1_p(rv_axu0_s1_p),
	      .rv_axu0_s2_v(rv_axu0_s2_v),
	      .rv_axu0_s2_p(rv_axu0_s2_p),
	      .rv_axu0_s3_v(rv_axu0_s3_v),
	      .rv_axu0_s3_p(rv_axu0_s3_p),

	      .rv_axu0_ex0_itag(rv_axu0_ex0_itag),
	      .rv_axu0_ex0_instr(rv_axu0_ex0_instr),
	      .rv_axu0_ex0_ucode(rv_axu0_ex0_ucode),
	      .rv_axu0_ex0_t1_v(rv_axu0_ex0_t1_v),
	      .rv_axu0_ex0_t1_p(rv_axu0_ex0_t1_p),
	      .rv_axu0_ex0_t2_p(rv_axu0_ex0_t2_p),
	      .rv_axu0_ex0_t3_p(rv_axu0_ex0_t3_p),

	      .fx0_rv_ext_itag_vld(fx0_rv_ext_itag_vld),
	      .fx0_rv_ext_itag(fx0_rv_ext_itag),
	      .fx1_rv_ext_itag_vld(fx1_rv_ext_itag_vld),
	      .fx1_rv_ext_itag(fx1_rv_ext_itag),
	      .axu0_rv_itag_vld(axu0_rv_itag_vld),
	      .axu0_rv_itag(axu0_rv_itag),
	      .axu1_rv_itag_vld(axu1_rv_itag_vld),
	      .axu1_rv_itag(axu1_rv_itag),
	      .lq_rv_ext_itag0_vld(lq_rv_ext_itag0_vld),
	      .lq_rv_ext_itag0(lq_rv_ext_itag0),

	      .lq_rv_itag1_vld(lq_rv_itag1_vld),
	      .lq_rv_itag1(lq_rv_itag1),
	      .lq_rv_itag1_restart(lq_rv_itag1_restart),
	      .lq_rv_itag1_hold(lq_rv_itag1_hold),
	      .lq_rv_ext_itag1_vld(lq_rv_ext_itag1_vld),
	      .lq_rv_ext_itag1(lq_rv_ext_itag1),
	      .lq_rv_ext_itag2_vld(lq_rv_ext_itag2_vld),
	      .lq_rv_ext_itag2(lq_rv_ext_itag2),
	      .lq_rv_clr_hold(lq_rv_clr_hold),

	      .axu0_rv_ex2_s1_abort(axu0_rv_ex2_s1_abort),
	      .axu0_rv_ex2_s2_abort(axu0_rv_ex2_s2_abort),
	      .axu0_rv_ex2_s3_abort(axu0_rv_ex2_s3_abort),

	      .fx0_rv_ext_itag_abort(fx0_rv_ext_itag_abort),
	      .fx1_rv_ext_itag_abort(fx1_rv_ext_itag_abort),
	      .lq_rv_ext_itag0_abort(lq_rv_ext_itag0_abort),
	      .lq_rv_ext_itag1_abort(lq_rv_ext_itag1_abort),
	      .axu0_rv_itag_abort(axu0_rv_itag_abort),
	      .axu1_rv_itag_abort(axu1_rv_itag_abort),

	      .axu0_rv_ext_itag_vld(axu0_rv_ext_itag_vld),
	      .axu0_rv_ext_itag(axu0_rv_ext_itag),
	      .axu0_rv_ext_itag_abort(axu0_rv_ext_itag_abort),
	      .axu0_rvs_perf_bus(axu0_rvs_perf_bus),
	      .axu0_rvs_dbg_bus(axu0_rvs_dbg_bus),

	      .vdd(vdd),
	      .gnd(gnd),
	      .nclk(nclk),
	      .func_sl_thold_1(func_sl_thold_1),
	      .sg_1(sg_1),
	      .clkoff_b(clkoff_dc_b),
	      .act_dis(act_dis),
	      .ccflush_dc(rp_rv_ccflush_dc),
	      .d_mode(d_mode),
	      .delay_lclkr(delay_lclkr_dc[0]),
	      .mpw1_b(mpw1_dc_b[0]),
	      .mpw2_b(mpw2_dc_b),
	      .scan_in(siv[rv_axu0_rvs_offset]),
	      .scan_out(sov[rv_axu0_rvs_offset])
	      );

   //------------------------------------------------------------------------------------------------------------
   // axu1 reservation station
   //------------------------------------------------------------------------------------------------------------
   // reserved
   assign rv_iu_axu1_credit_free = {`THREADS{1'b0}};

   assign axu1_rv_ext_itag_vld   = axu1_rv_itag_vld;
   assign axu1_rv_ext_itag       = axu1_rv_itag;
   assign axu1_rv_ext_itag_abort = axu1_rv_itag_abort;

   //------------------------------------------------------------------------------------------------------------
   // LQ Regfile
   //------------------------------------------------------------------------------------------------------------
   assign w_data_in_1 = {xu0_gpr_ex6_wd[64 - `GPR_WIDTH:63 + (`GPR_WIDTH/8)], 6'b000000};
   assign w_data_in_2 = {lq_rv_gpr_ex6_wd[64 - `GPR_WIDTH:63 + (`GPR_WIDTH/8)], 6'b000000};
   assign w_data_in_3 = {lq_rv_gpr_rel_wd[64 - `GPR_WIDTH:63 + (`GPR_WIDTH/8)], 6'b000000};
   assign w_data_in_4 = {xu1_gpr_ex3_wd[64 - `GPR_WIDTH:63 + (`GPR_WIDTH/8)], 6'b000000};

   assign rv_lq_gpr_ex1_r0d = r_data_out_1[64 - `GPR_WIDTH:63 + (`GPR_WIDTH/8)];
   assign rv_lq_gpr_ex1_r1d = r_data_out_2[64 - `GPR_WIDTH:63 + (`GPR_WIDTH/8)];

   generate
      if (`THREADS == 2)
        begin : tp2
           assign rv_lq_gpr_s1_p = {rv_byp_lq_s1_p, rv_byp_lq_vld[1]};
           assign rv_lq_gpr_s2_p = {rv_byp_lq_s2_p, rv_byp_lq_vld[1]};
        end
   endgenerate

   generate
      if (`THREADS == 1)
        begin : tp1
           assign rv_lq_gpr_s1_p = rv_byp_lq_s1_p;
           assign rv_lq_gpr_s2_p = rv_byp_lq_s2_p;
        end
   endgenerate

   tri_144x78_2r4w
     lqrf(
          .nclk(nclk),
          .vdd(vdd),
          .gnd(gnd),
          .delay_lclkr_dc(delay_lclkr_dc[0]),
          .mpw1_dc_b(mpw1_dc_b[0]),
          .mpw2_dc_b(mpw2_dc_b),
          .func_sl_force(force_t),
          .func_sl_thold_0_b(chip_b_sl_2_thold_0_b),
          .func_slp_sl_force(force_t),
          .func_slp_sl_thold_0_b(chip_b_sl_2_thold_0_b),
          .sg_0(sg_1),
          .scan_in(lqrf_si),
          .scan_out(lqrf_so),
          .r_late_en_1(rv_byp_lq_s1_v),
          .r_addr_in_1(rv_lq_gpr_s1_p),
          .r_data_out_1(r_data_out_1),
          .r_late_en_2(rv_byp_lq_s2_v),
          .r_addr_in_2(rv_lq_gpr_s2_p),
          .r_data_out_2(r_data_out_2),
          .w_late_en_1(xu0_gpr_ex6_we),
          .w_addr_in_1(xu0_gpr_ex6_wa),
          .w_data_in_1(w_data_in_1),
          .w_late_en_2(lq_rv_gpr_ex6_we),
          .w_addr_in_2(lq_rv_gpr_ex6_wa),
          .w_data_in_2(w_data_in_2),
          .w_late_en_3(lq_rv_gpr_rel_we),
          .w_addr_in_3(lq_rv_gpr_rel_wa),
          .w_data_in_3(w_data_in_3),
          .w_late_en_4(xu1_gpr_ex3_we),
          .w_addr_in_4(xu1_gpr_ex3_wa),
          .w_data_in_4(w_data_in_4)
          );

   //------------------------------------------------------------------------------------------------------------
   // RF GPR Bypass Control
   //------------------------------------------------------------------------------------------------------------

   rv_rf_byp
     rf_byp(
	    .cp_flush(cp_flush),
	    .rv_byp_fx0_vld(rv_byp_fx0_vld),
	    .rv_byp_fx0_itag(rv_byp_fx0_itag),
	    .rv_byp_fx0_ilat(rv_byp_fx0_ilat),
	    .rv_byp_fx0_ord(rv_byp_fx0_ord),
	    .rv_byp_fx0_t1_v(rv_byp_fx0_t1_v),
	    .rv_byp_fx0_t1_t(rv_byp_fx0_t1_t),
	    .rv_byp_fx0_t2_v(rv_byp_fx0_t2_v),
	    .rv_byp_fx0_t2_t(rv_byp_fx0_t2_t),
	    .rv_byp_fx0_t3_v(rv_byp_fx0_t3_v),
	    .rv_byp_fx0_t3_t(rv_byp_fx0_t3_t),
	    .rv_byp_fx0_s1_t(rv_byp_fx0_s1_t),
	    .rv_byp_fx0_s2_t(rv_byp_fx0_s2_t),
	    .rv_byp_fx0_s3_t(rv_byp_fx0_s3_t),
	    .rv_byp_fx0_ex0_is_brick(rv_byp_fx0_ex0_is_brick),
	    .rv_byp_lq_vld(rv_byp_lq_vld),
	    .rv_byp_lq_t1_v(rv_byp_lq_t1_v),
	    .rv_byp_lq_t3_v(rv_byp_lq_t3_v),
	    .rv_byp_lq_t3_t(rv_byp_lq_t3_t),
	    .rv_byp_lq_s1_t(rv_byp_lq_s1_t),
	    .rv_byp_lq_s2_t(rv_byp_lq_s2_t),
	    .rv_byp_lq_ex0_s1_itag(rv_byp_lq_ex0_s1_itag),
	    .rv_byp_lq_ex0_s2_itag(rv_byp_lq_ex0_s2_itag),
	    .rv_byp_fx1_vld(rv_byp_fx1_vld),
	    .rv_byp_fx1_itag(rv_byp_fx1_itag),
	    .rv_byp_fx1_ilat(rv_byp_fx1_ilat),
	    .rv_byp_fx1_t1_v(rv_byp_fx1_t1_v),
	    .rv_byp_fx1_t2_v(rv_byp_fx1_t2_v),
	    .rv_byp_fx1_t3_v(rv_byp_fx1_t3_v),
	    .rv_byp_fx1_s1_t(rv_byp_fx1_s1_t),
	    .rv_byp_fx1_s2_t(rv_byp_fx1_s2_t),
	    .rv_byp_fx1_s3_t(rv_byp_fx1_s3_t),
	    .rv_byp_fx1_ex0_isStore(rv_byp_fx1_ex0_isStore),
	    .rv_fx0_ex0_s1_fx0_sel(rv_fx0_ex0_s1_fx0_sel),
	    .rv_fx0_ex0_s2_fx0_sel(rv_fx0_ex0_s2_fx0_sel),
	    .rv_fx0_ex0_s3_fx0_sel(rv_fx0_ex0_s3_fx0_sel),
	    .rv_fx0_ex0_s1_lq_sel(rv_fx0_ex0_s1_lq_sel),
	    .rv_fx0_ex0_s2_lq_sel(rv_fx0_ex0_s2_lq_sel),
	    .rv_fx0_ex0_s3_lq_sel(rv_fx0_ex0_s3_lq_sel),
	    .rv_fx0_ex0_s1_fx1_sel(rv_fx0_ex0_s1_fx1_sel),
	    .rv_fx0_ex0_s2_fx1_sel(rv_fx0_ex0_s2_fx1_sel),
	    .rv_fx0_ex0_s3_fx1_sel(rv_fx0_ex0_s3_fx1_sel),
	    .rv_lq_ex0_s1_fx0_sel(rv_lq_ex0_s1_fx0_sel),
	    .rv_lq_ex0_s2_fx0_sel(rv_lq_ex0_s2_fx0_sel),
	    .rv_lq_ex0_s1_lq_sel(rv_lq_ex0_s1_lq_sel),
	    .rv_lq_ex0_s2_lq_sel(rv_lq_ex0_s2_lq_sel),
	    .rv_lq_ex0_s1_fx1_sel(rv_lq_ex0_s1_fx1_sel),
	    .rv_lq_ex0_s2_fx1_sel(rv_lq_ex0_s2_fx1_sel),
	    .rv_fx1_ex0_s1_fx0_sel(rv_fx1_ex0_s1_fx0_sel),
	    .rv_fx1_ex0_s2_fx0_sel(rv_fx1_ex0_s2_fx0_sel),
	    .rv_fx1_ex0_s3_fx0_sel(rv_fx1_ex0_s3_fx0_sel),
	    .rv_fx1_ex0_s1_lq_sel(rv_fx1_ex0_s1_lq_sel),
	    .rv_fx1_ex0_s2_lq_sel(rv_fx1_ex0_s2_lq_sel),
	    .rv_fx1_ex0_s3_lq_sel(rv_fx1_ex0_s3_lq_sel),
	    .rv_fx1_ex0_s1_fx1_sel(rv_fx1_ex0_s1_fx1_sel),
	    .rv_fx1_ex0_s2_fx1_sel(rv_fx1_ex0_s2_fx1_sel),
	    .rv_fx1_ex0_s3_fx1_sel(rv_fx1_ex0_s3_fx1_sel),

	    .rv_fx0_ex0_s1_rel_sel(rv_fx0_ex0_s1_rel_sel),
	    .rv_fx0_ex0_s2_rel_sel(rv_fx0_ex0_s2_rel_sel),
	    .rv_fx0_ex0_s3_rel_sel(rv_fx0_ex0_s3_rel_sel),
	    .rv_lq_ex0_s1_rel_sel(rv_lq_ex0_s1_rel_sel),
	    .rv_lq_ex0_s2_rel_sel(rv_lq_ex0_s2_rel_sel),
	    .rv_fx1_ex0_s1_rel_sel(rv_fx1_ex0_s1_rel_sel),
	    .rv_fx1_ex0_s2_rel_sel(rv_fx1_ex0_s2_rel_sel),
	    .rv_fx1_ex0_s3_rel_sel(rv_fx1_ex0_s3_rel_sel),

	    //-------------------------------------------------------------------
	    // FX0 RV Release
	    //-------------------------------------------------------------------
	    .fx0_rv_itag_vld(fx0_rv_itag_vld),
	    .fx0_rv_itag_abort(fx0_rv_itag_abort),
	    .fx0_rv_itag(fx0_rv_itag),
	    .fx0_rv_ext_itag_vld(fx0_rv_ext_itag_vld),
	    .fx0_rv_ext_itag_abort(fx0_rv_ext_itag_abort),
	    .fx0_rv_ext_itag(fx0_rv_ext_itag),

	    .fx0_rv_ord_complete(fx0_rv_ord_complete),
	    .fx0_rv_ord_itag(fx0_rv_ord_itag),

	    .rv_fx0_s1_itag(rv_byp_fx0_s1_itag),
	    .rv_fx0_s2_itag(rv_byp_fx0_s2_itag),
	    .rv_fx0_s3_itag(rv_byp_fx0_s3_itag),

	    .rv_byp_fx0_ilat0_vld(rv_byp_fx0_ilat0_vld),
	    .rv_byp_fx1_ilat0_vld(rv_byp_fx1_ilat0_vld),
	    .rv_byp_fx0_ilat1_vld(rv_byp_fx0_ilat1_vld),
	    .rv_byp_fx1_ilat1_vld(rv_byp_fx1_ilat1_vld),
	    .fx0_release_ord_hold(fx0_release_ord_hold),
	    .fx0_rv_ord_tid(fx0_rv_ord_tid),

	    .fx0_rv_ex2_s1_abort(fx0_rv_ex2_s1_abort),
	    .fx0_rv_ex2_s2_abort(fx0_rv_ex2_s2_abort),
	    .fx0_rv_ex2_s3_abort(fx0_rv_ex2_s3_abort),

	    //-------------------------------------------------------------------
	    // FX1 RV Release
	    //-------------------------------------------------------------------
	    .fx1_rv_itag_vld(fx1_rv_itag_vld),
	    .fx1_rv_itag_abort(fx1_rv_itag_abort),
	    .fx1_rv_itag(fx1_rv_itag),
	    .fx1_rv_ext_itag_vld(fx1_rv_ext_itag_vld),
	    .fx1_rv_ext_itag_abort(fx1_rv_ext_itag_abort),
	    .fx1_rv_ext_itag(fx1_rv_ext_itag),

	    .rv_fx1_s1_itag(rv_byp_fx1_s1_itag),
	    .rv_fx1_s2_itag(rv_byp_fx1_s2_itag),
	    .rv_fx1_s3_itag(rv_byp_fx1_s3_itag),

	    .fx1_rv_ex2_s1_abort(fx1_rv_ex2_s1_abort),
	    .fx1_rv_ex2_s2_abort(fx1_rv_ex2_s2_abort),
	    .fx1_rv_ex2_s3_abort(fx1_rv_ex2_s3_abort),

	    //-------------------------------------------------------------------
	    // LQ RV Release
	    //-------------------------------------------------------------------
	    .rv_byp_lq_itag(rv_byp_lq_itag),

	    //-------------------------------------------------------------------
	    // LQ RV REL Release
	    //-------------------------------------------------------------------
	    .lq_rv_itag2_vld(lq_rv_itag2_vld),
	    .lq_rv_itag2(lq_rv_itag2),

	    //-------------------------------------------------------------------
	    // Pervasive
	    //-------------------------------------------------------------------
	    .nclk(nclk),
	    .vdd(vdd),
	    .gnd(gnd),

	    .func_sl_thold_1(func_sl_thold_1),
	    .sg_1(sg_1),
	    .clkoff_b(clkoff_dc_b),
	    .act_dis(act_dis),
	    .ccflush_dc(rp_rv_ccflush_dc),
	    .delay_lclkr(delay_lclkr_dc[0]),
	    .mpw1_b(mpw1_dc_b[0]),
	    .mpw2_b(mpw2_dc_b),

	    .scan_in(siv[rv_rf_byp_offset]),
	    .scan_out(sov[rv_rf_byp_offset])
	    );

   //------------------------------------------------------------------------------------------------------------
   // RV Pervasive
   //------------------------------------------------------------------------------------------------------------

   rv_perv
     prv(
         .nclk(nclk),
         .vdd(vdd),
         .gnd(gnd),
         .rp_rv_ccflush_dc(rp_rv_ccflush_dc),
         .rp_rv_func_sl_thold_3(rp_rv_func_sl_thold_3),
         .rp_rv_gptr_sl_thold_3(rp_rv_gptr_sl_thold_3),
         .rp_rv_sg_3(rp_rv_sg_3),
         .rp_rv_fce_3(rp_rv_fce_3),
         .an_ac_scan_diag_dc(an_ac_scan_diag_dc),
         .an_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
         .func_sl_thold_1(func_sl_thold_1),
         .fce_1(fce_1),
         .sg_1(sg_1),
         .clkoff_dc_b(clkoff_dc_b),
         .act_dis(act_dis),
         .d_mode(d_mode),
         .delay_lclkr_dc(delay_lclkr_dc),
         .mpw1_dc_b(mpw1_dc_b),
         .mpw2_dc_b(mpw2_dc_b),
         .gptr_scan_in(gptr_scan_in),
         .gptr_scan_out(gptr_scan_out),
         .scan_in(siv[perv_func_offset]),
         .scan_out(sov[perv_func_offset]),

	 .fx0_rvs_perf_bus(fx0_rvs_perf_bus),
	 .fx0_rvs_dbg_bus(fx0_rvs_dbg_bus),
	 .fx1_rvs_perf_bus(fx1_rvs_perf_bus),
	 .fx1_rvs_dbg_bus(fx1_rvs_dbg_bus),
	 .lq_rvs_perf_bus(lq_rvs_perf_bus),
	 .lq_rvs_dbg_bus(lq_rvs_dbg_bus),
	 .axu0_rvs_perf_bus(axu0_rvs_perf_bus),
	 .axu0_rvs_dbg_bus(axu0_rvs_dbg_bus),
	 .pc_rv_trace_bus_enable(pc_rv_trace_bus_enable),
	 .pc_rv_debug_mux_ctrls(pc_rv_debug_mux_ctrls),
	 .pc_rv_event_bus_enable(pc_rv_event_bus_enable),
	 .pc_rv_event_count_mode(pc_rv_event_count_mode),
	 .pc_rv_event_mux_ctrls(pc_rv_event_mux_ctrls),
	 .rv_event_bus_in(rv_event_bus_in),
	 .rv_event_bus_out(rv_event_bus_out),
         .spr_msr_gs(spr_msr_gs),
         .spr_msr_pr(spr_msr_pr),
	 .debug_bus_out(debug_bus_out),
	 .coretrace_ctrls_out(coretrace_ctrls_out),
	 .debug_bus_in(debug_bus_in),
	 .coretrace_ctrls_in(coretrace_ctrls_in)

         );

   //todo
   assign lqrf_si = 1'b0;
   assign gptr_scan_in = 1'b0;

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];

endmodule // rv
