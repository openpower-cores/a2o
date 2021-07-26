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

//
//  Description:  XU LSU Flush Generation
//
//*****************************************************************************

// ##########################################################################################
// VHDL Contents
// 1) Reload Flush generation
// 2) Back-Invalidate Flush generation
// 4) Instruction Flush Handling
// ##########################################################################################

`include "tri_a2o.vh"

module lq_fgen(
   ex0_i0_vld,
   ex0_i0_ucode_preissue,
   ex0_i0_2ucode,
   ex0_i0_ucode_cnt,
   ex0_i1_vld,
   ex0_i1_ucode_preissue,
   ex0_i1_2ucode,
   ex0_i1_ucode_cnt,
   dec_dcc_ex1_expt_det,
   dec_dcc_ex1_priv_prog,
   dec_dcc_ex1_hypv_prog,
   dec_dcc_ex1_illeg_prog,
   dec_dcc_ex1_dlock_excp,
   dec_dcc_ex1_ilock_excp,
   dec_dcc_ex1_ehpriv_excp,
   byp_dcc_ex2_req_aborted,
   ex3_stg_act,
   ex4_stg_act,
   ex1_thrd_id,
   ex2_thrd_id,
   ex3_thrd_id,
   ex4_thrd_id,
   ex5_thrd_id,
   ex3_cache_acc,
   ex3_ucode_val,
   ex3_ucode_cnt,
   ex4_ucode_op,
   ex4_mem_attr,
   ex4_blkable_touch,
   ex3_ldst_fexcpt,
   ex3_axu_op_val,
   ex3_axu_instr_type,
   ex3_optype16,
   ex3_optype8,
   ex3_optype4,
   ex3_optype2,
   ex3_eff_addr,
   ex3_icswx_type,
   ex3_dcbz_instr,
   ex3_resv_instr,
   ex3_mword_instr,
   ex3_ldawx_instr,
   ex3_illeg_lswx,
   ex4_icswx_dsi,
   ex4_wclr_all_val,
   ex4_wNComp_rcvd,
   ex4_dac_int_det,
   ex4_strg_gate,
   ex4_restart_val,
   ex5_restart_val,
   spr_ccr2_ucode_dis,
   spr_ccr2_notlb,
   spr_xucr0_mddp,
   spr_xucr0_mdcp,
   spr_xucr4_mmu_mchk,
   spr_xucr4_mddmh,
   derat_dcc_ex4_restart,
   derat_dcc_ex4_wimge_w,
   derat_dcc_ex4_wimge_i,
   derat_dcc_ex4_miss,
   derat_dcc_ex4_tlb_err,
   derat_dcc_ex4_dsi,
   derat_dcc_ex4_vf,
   derat_dcc_ex4_multihit_err_det,
   derat_dcc_ex4_multihit_err_flush,
   derat_dcc_ex4_tlb_inelig,
   derat_dcc_ex4_pt_fault,
   derat_dcc_ex4_lrat_miss,
   derat_dcc_ex4_tlb_multihit,
   derat_dcc_ex4_tlb_par_err,
   derat_dcc_ex4_lru_par_err,
   derat_dcc_ex4_par_err_det,
   derat_dcc_ex4_par_err_flush,
   derat_fir_par_err,
   derat_fir_multihit,
   dir_dcc_ex5_dir_perr_det,
   dir_dcc_ex5_dc_perr_det,
   dir_dcc_ex5_dir_perr_flush,
   dir_dcc_ex5_dc_perr_flush,
   dir_dcc_ex5_multihit_det,
   dir_dcc_ex5_multihit_flush,
   dir_dcc_stq4_dir_perr_det,
   dir_dcc_stq4_multihit_det,
   dir_dcc_ex5_stp_flush,
   spr_xucr0_aflsta,
   spr_xucr0_flsta,
   spr_ccr2_ap,
   spr_msr_fp,
   spr_msr_spv,
   iu_lq_cp_flush,
   ex4_ucode_restart,
   ex4_sfx_excpt_det,
   ex4_excp_det,
   ex4_wNComp_excp,
   ex4_wNComp_excp_restart,
   ex5_flush_req,
   ex5_blk_tlb_req,
   ex5_flush_pfetch,
   fgen_ex4_cp_flush,
   fgen_ex5_cp_flush,
   fgen_ex1_stg_flush,
   fgen_ex2_stg_flush,
   fgen_ex3_stg_flush,
   fgen_ex4_stg_flush,
   fgen_ex5_stg_flush,
   ex5_flush2ucode,
   ex5_n_flush,
   ex5_np1_flush,
   ex5_exception_val,
   ex5_exception,
   ex5_dear_val,
   ex5_misalign_flush,
   lq_pc_err_derat_parity,
   lq_pc_err_dir_ldp_parity,
   lq_pc_err_dir_stp_parity,
   lq_pc_err_dcache_parity,
   lq_pc_err_derat_multihit,
   lq_pc_err_dir_ldp_multihit,
   lq_pc_err_dir_stp_multihit,
   vdd,
   gnd,
   nclk,
   sg_0,
   func_sl_thold_0_b,
   func_sl_force,
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
//parameter                                    EXPAND_TYPE = 2;
//parameter                                    THREADS = 2;
//parameter                                    UCODE_ENTRIES_ENC = 3;
//parameter                                    THREADS_POOL_ENC = 1;
//parameter                                    ITAG_SIZE_ENC = 7;

// IU Dispatch to RV0
input [0:`THREADS-1]                         ex0_i0_vld;
input                                        ex0_i0_ucode_preissue;
input                                        ex0_i0_2ucode;
input [0:`UCODE_ENTRIES_ENC-1]               ex0_i0_ucode_cnt;
input [0:`THREADS-1]                         ex0_i1_vld;
input                                        ex0_i1_ucode_preissue;
input                                        ex0_i1_2ucode;
input [0:`UCODE_ENTRIES_ENC-1]               ex0_i1_ucode_cnt;

// Execution Pipe
input                                        dec_dcc_ex1_expt_det;
input                                        dec_dcc_ex1_priv_prog;
input                                        dec_dcc_ex1_hypv_prog;
input                                        dec_dcc_ex1_illeg_prog;
input                                        dec_dcc_ex1_dlock_excp;
input                                        dec_dcc_ex1_ilock_excp;
input                                        dec_dcc_ex1_ehpriv_excp;
input                                        byp_dcc_ex2_req_aborted;

// Control
input                                        ex3_stg_act;
input                                        ex4_stg_act;
input [0:`THREADS-1]                         ex1_thrd_id;
input [0:`THREADS-1]                         ex2_thrd_id;
input [0:`THREADS-1]                         ex3_thrd_id;
input [0:`THREADS-1]                         ex4_thrd_id;
input [0:`THREADS-1]                         ex5_thrd_id;
input                                        ex3_cache_acc;			         // Cache Access is Valid in ex3
input                                        ex3_ucode_val;			         // Ucode Preissue is Valid in ex3
input [0:`UCODE_ENTRIES_ENC-1]               ex3_ucode_cnt;			         // Ucode Count in ex3
input                                        ex4_ucode_op;			         // Op is from Ucode in ex4
input [0:8]                                  ex4_mem_attr;
input                                        ex4_blkable_touch;
input                                        ex3_ldst_fexcpt;			      // Force Exception on misaligned AXU access
input                                        ex3_axu_op_val;			      // ex3 AXU operation is valid
input [0:2]                                  ex3_axu_instr_type;
input                                        ex3_optype16;			         // Operation is 16 Byte Access
input                                        ex3_optype8;			         // Operation is 8 Byte Access
input                                        ex3_optype4;			         // Operation is 4 Byte Access
input                                        ex3_optype2;			         // Operation is 2 Byte Access
input [57:63]                                ex3_eff_addr;
input                                        ex3_icswx_type;
input                                        ex3_dcbz_instr;			      // DCBZ instruction is valid in ex3
input                                        ex3_resv_instr;			      // lwarx, ldarx, stwcx, and stdcx operations
input                                        ex3_mword_instr;			      // Load/Store Multiple Word preissue
input                                        ex3_ldawx_instr;			      // ldawx operation
input                                        ex3_illeg_lswx;			      // STQ detected illegal form of LSWX
input                                        ex4_icswx_dsi;			         // Unavailable Coprocessor DSI Interrupt
input                                        ex4_wclr_all_val;			      // wclr All instruction is valid
input                                        ex4_wNComp_rcvd;			      // Request is CP_NEXT with recirc valid
input                                        ex4_dac_int_det;			      // Debug Address Compare Interrupt Detected
input                                        ex4_strg_gate;			         // LSWX/STSWX NOOP indicator, gate mem attribute update
input                                        ex4_restart_val;			      // Instruction is getting restarted in EX4
input                                        ex5_restart_val;			      // Instruction is getting restarted in EX5

// SPR Bits
input                                        spr_ccr2_ucode_dis;		      // CCR2[UCODE_DIS]
input                                        spr_ccr2_notlb;			      // CCR2[NOTLB]
input                                        spr_xucr0_mddp;			      // XUCR0[MDDP]
input                                        spr_xucr0_mdcp;			      // XUCR0[MDCP]
input                                        spr_xucr4_mmu_mchk;		      // XUCR4[MMU_MCHK]
input                                        spr_xucr4_mddmh;			      // XUCR4[MDDMH]

// ERAT Interface
input                                        derat_dcc_ex4_restart;
input                                        derat_dcc_ex4_wimge_w;
input                                        derat_dcc_ex4_wimge_i;
input                                        derat_dcc_ex4_miss;
input                                        derat_dcc_ex4_tlb_err;
input                                        derat_dcc_ex4_dsi;
input                                        derat_dcc_ex4_vf;
input                                        derat_dcc_ex4_multihit_err_det;
input                                        derat_dcc_ex4_multihit_err_flush;
input                                        derat_dcc_ex4_tlb_inelig;
input                                        derat_dcc_ex4_pt_fault;
input                                        derat_dcc_ex4_lrat_miss;
input                                        derat_dcc_ex4_tlb_multihit;
input                                        derat_dcc_ex4_tlb_par_err;
input                                        derat_dcc_ex4_lru_par_err;
input                                        derat_dcc_ex4_par_err_det;
input                                        derat_dcc_ex4_par_err_flush;
input					     derat_fir_par_err;
input					     derat_fir_multihit;

// D$ Parity Error Detected
input                                        dir_dcc_ex5_dir_perr_det;		// Data Directory Parity Error Detected
input                                        dir_dcc_ex5_dc_perr_det;		// Data Cache Parity Error Detected
input                                        dir_dcc_ex5_dir_perr_flush;	// Data Directory Parity Error Flush
input                                        dir_dcc_ex5_dc_perr_flush;		// Data Cache Parity Error Flush
input                                        dir_dcc_ex5_multihit_det;		// Directory Multihit Detected
input                                        dir_dcc_ex5_multihit_flush;	// Directory Multihit Flush
input                                        dir_dcc_stq4_dir_perr_det;		// Data Cache Parity Error Detected on the STQ Commit Pipeline
input                                        dir_dcc_stq4_multihit_det;		// Directory Multihit Detected on the STQ Commit Pipeline
input                                        dir_dcc_ex5_stp_flush;        // Directory Error detected on the STQ Commit Pipeline with EX5 LDP valid

// SPR's
input                                        spr_xucr0_aflsta;
input                                        spr_xucr0_flsta;
input                                        spr_ccr2_ap;
input                                        spr_msr_fp;
input                                        spr_msr_spv;

// Instruction Flush
input [0:`THREADS-1]                         iu_lq_cp_flush;

// Flush Pipe Outputs
output                                       ex4_ucode_restart;			   // Memory Attributes are not known, need to restart
output                                       ex4_sfx_excpt_det;			   // Priveleged and illegal instructions
output                                       ex4_excp_det;			         // Any Exception was detected
output                                       ex4_wNComp_excp;			      // Exception with RECIRC_VAL detected
output                                       ex4_wNComp_excp_restart;	   // CP_NEXT instruction got an exception, restart the 2 younger instructions
output                                       ex5_flush_req;			         // Non-CP_NEXT Flush Request Detected
output                                       ex5_blk_tlb_req;			      // Block ERAT Miss from going to the MMU
output                                       ex5_flush_pfetch;             // Flush Prefetch in ex5
output                                       fgen_ex4_cp_flush;			   // Completion Flush Request in ex4
output                                       fgen_ex5_cp_flush;			   // Completion Flush Request in ex5
output                                       fgen_ex1_stg_flush;		      // Flush Instructions in ex1
output                                       fgen_ex2_stg_flush;		      // Flush Instructions in ex2
output                                       fgen_ex3_stg_flush;		      // Flush Instructions in ex3
output                                       fgen_ex4_stg_flush;		      // Flush Instructions in ex4
output                                       fgen_ex5_stg_flush;		      // Flush Instructions in ex5

// Completion Indicators
output                                       ex5_flush2ucode;			      // EX5 Flush to Ucode indicator
output                                       ex5_n_flush;			         // EX5 N Flush Indicator
output                                       ex5_np1_flush;			         // EX5 NP1 Flush Indicator
output                                       ex5_exception_val;		      // EX5 Exception Valid Indicator
output [0:5]                                 ex5_exception;			         // EX5 Exception Encode
output [0:`THREADS-1]                        ex5_dear_val;			         // EX5 Dear Valid Indicator

// Performance Events
output                                       ex5_misalign_flush;

// Error Reporting
output                                       lq_pc_err_derat_parity;
output                                       lq_pc_err_dir_ldp_parity;
output                                       lq_pc_err_dir_stp_parity;
output                                       lq_pc_err_dcache_parity;
output                                       lq_pc_err_derat_multihit;
output                                       lq_pc_err_dir_ldp_multihit;
output                                       lq_pc_err_dir_stp_multihit;

//pervasive


inout                                        vdd;


inout                                        gnd;

(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

input [0:`NCLK_WIDTH-1]                      nclk;
input                                        sg_0;
input                                        func_sl_thold_0_b;
input                                        func_sl_force;
input                                        d_mode_dc;
input                                        delay_lclkr_dc;
input                                        mpw1_dc_b;
input                                        mpw2_dc_b;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input                                        scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output                                       scan_out;

//--------------------------
// components
//--------------------------

//--------------------------
// constants
//--------------------------
parameter                                    UCODEDEPTH = (2**`UCODE_ENTRIES_ENC)*`THREADS;

//--------------------------
// signals
//--------------------------
wire                                         ex3_16Bop16_unal;
wire                                         ex3_16Bop8_unal;
wire                                         ex3_16Bop4_unal;
wire                                         ex3_16Bop2_unal;
wire                                         ex3_16Bunal_op;
wire                                         ex4_wt_ci_trans;
wire                                         ex3_valid_resv;
wire                                         ex1_cp_flush_val;
wire                                         ex2_cp_flush_val;
wire                                         ex3_cp_flush_val;
wire                                         ex4_cp_flush_val;
wire                                         ex5_cp_flush_val;
wire                                         ex4_local_flush;
wire                                         ex4_valid_resv_d;
wire                                         ex4_valid_resv_q;
wire                                         ex4_prealign_int_d;
wire                                         ex4_prealign_int_q;
wire                                         force_align_int_a;
wire                                         force_align_int_x;
wire                                         force_align_int;
wire                                         ex3_flush_2ucode_chk;
wire                                         ex3_flush_2ucode;
wire                                         ex4_flush_2ucode_d;
wire                                         ex4_flush_2ucode_q;
wire                                         ex5_flush_2ucode_d;
wire                                         ex5_flush_2ucode_q;
wire                                         ex4_ucode_dis_prog_d;
wire                                         ex4_ucode_dis_prog_q;
wire                                         ex3_op16_unal;
wire                                         ex3_op8_unal;
wire                                         ex3_op4_unal;
wire                                         ex3_op2_unal;
wire                                         ex3_unal_op;
wire                                         ex5_misalign_flush_d;
wire                                         ex5_misalign_flush_q;
wire                                         ex4_n_flush_req;
wire                                         ex4_tlb_flush_req;
wire                                         ex5_tlb_flush_req_d;
wire                                         ex5_tlb_flush_req_q;
wire                                         ex5_tlb_mchk_req_d;
wire                                         ex5_tlb_mchk_req_q;
wire                                         ex5_flush_req_mchk;
wire                                         ex5_flush_req_int;
wire                                         ex3_icswx_unal;
wire                                         ex4_is_dcbz_d;
wire                                         ex4_is_dcbz_q;
wire                                         ex4_dsi_int;
wire                                         ex4_align_int;
wire                                         ex4_dcbz_err;
wire                                         ex4_axu_ap_unavail_d;
wire                                         ex4_axu_ap_unavail_q;
wire                                         ex4_axu_fp_unavail_d;
wire                                         ex4_axu_fp_unavail_q;
wire                                         ex4_axu_spv_unavail_d;
wire                                         ex4_axu_spv_unavail_q;
wire                                         ex5_local_flush;
wire                                         ex5_local_flush_d;
wire                                         ex5_local_flush_q;
wire [0:25]                                  ex4_excp_pri;
wire [7:11]                                  ex5_excp_pri;
wire                                         ex4_tlb_perr_mchk;
wire                                         ex4_tlb_lru_perr_mchk;
wire                                         ex4_tlb_multihit_mchk;
wire                                         ex5_derat_perr_mchk;
wire                                         ex5_dir_perr_mchk;
wire                                         ex5_dc_perr_mchk;
wire                                         ex5_derat_multihit_mchk;
wire                                         ex5_dir_multihit_mchk;
wire                                         ex4_tlb_perr_flush;
wire                                         ex4_tlb_lru_perr_flush;
wire                                         ex4_tlb_multihit_flush;
wire                                         ex5_derat_perr_flush;
wire                                         ex5_dir_perr_flush;
wire                                         ex5_dc_perr_flush;
wire                                         ex5_derat_multihit_flush;
wire                                         ex5_dir_multihit_flush;
wire                                         ex4_non_cp_next_excp;
wire                                         ex5_high_pri_excp_d;
wire                                         ex5_high_pri_excp_q;
wire                                         ex4_cp_next_excp;
wire                                         ex4_cp_next_excp_det;
wire                                         ex4_cp_next_excp_rpt;
wire                                         ex5_low_pri_excp_d;
wire                                         ex5_low_pri_excp_q;
wire [0:5]                                   ex4_exception;
wire                                         ex5_sel_mid_pri_excp;
wire [0:5]                                   ex5_mid_pri_excp;
wire [0:5]                                   ex5_exception_d;
wire [0:5]                                   ex5_exception_q;
wire [0:5]                                   ex5_exception_int;
wire [0:`THREADS-1]                          ex5_dear_val_d;
wire [0:`THREADS-1]                          ex5_dear_val_q;
wire                                         ex5_derat_multihit_flush_d;
wire                                         ex5_derat_multihit_flush_q;
wire                                         ex5_derat_multihit_det_d;
wire                                         ex5_derat_multihit_det_q;
wire                                         ex5_derat_perr_flush_d;
wire                                         ex5_derat_perr_flush_q;
wire                                         ex5_derat_perr_det_d;
wire                                         ex5_derat_perr_det_q;
wire                                         ex2_sfx_excpt_det_d;
wire                                         ex2_sfx_excpt_det_q;
wire                                         ex3_sfx_excpt_det_d;
wire                                         ex3_sfx_excpt_det_q;
wire                                         ex4_sfx_excpt_det_d;
wire                                         ex4_sfx_excpt_det_q;
wire                                         ex2_priv_prog_d;
wire                                         ex2_priv_prog_q;
wire                                         ex3_priv_prog_d;
wire                                         ex3_priv_prog_q;
wire                                         ex4_priv_prog_d;
wire                                         ex4_priv_prog_q;
wire                                         ex2_hypv_prog_d;
wire                                         ex2_hypv_prog_q;
wire                                         ex3_hypv_prog_d;
wire                                         ex3_hypv_prog_q;
wire                                         ex4_hypv_prog_d;
wire                                         ex4_hypv_prog_q;
wire                                         ex2_illeg_prog_d;
wire                                         ex2_illeg_prog_q;
wire                                         ex3_illeg_prog_d;
wire                                         ex3_illeg_prog_q;
wire                                         ex4_illeg_prog_d;
wire                                         ex4_illeg_prog_q;
wire                                         ex2_dlock_excp_d;
wire                                         ex2_dlock_excp_q;
wire                                         ex3_dlock_excp_d;
wire                                         ex3_dlock_excp_q;
wire                                         ex4_dlock_excp_d;
wire                                         ex4_dlock_excp_q;
wire                                         ex2_ilock_excp_d;
wire                                         ex2_ilock_excp_q;
wire                                         ex3_ilock_excp_d;
wire                                         ex3_ilock_excp_q;
wire                                         ex4_ilock_excp_d;
wire                                         ex4_ilock_excp_q;
wire                                         ex2_ehpriv_excp_d;
wire                                         ex2_ehpriv_excp_q;
wire                                         ex3_ehpriv_excp_d;
wire                                         ex3_ehpriv_excp_q;
wire                                         ex4_ucode_val_d;
wire                                         ex4_ucode_val_q;
wire [0:`UCODE_ENTRIES_ENC-1]                ex4_ucode_cnt_d;
wire [0:`UCODE_ENTRIES_ENC-1]                ex4_ucode_cnt_q;
wire [0:`UCODE_ENTRIES_ENC+`THREADS_POOL_ENC-1] ex0_i0_tid_ucode_cnt;
wire [0:`UCODE_ENTRIES_ENC+`THREADS_POOL_ENC-1] ex0_i1_tid_ucode_cnt;
wire [0:`UCODE_ENTRIES_ENC+`THREADS_POOL_ENC-1] ex3_tid_ucode_cnt;
wire [0:`UCODE_ENTRIES_ENC+`THREADS_POOL_ENC-1] ex4_tid_ucode_cnt;
wire [0:UCODEDEPTH-1]                        ex0_i0_ucode_cnt_entry;
wire [0:UCODEDEPTH-1]                        ex0_i0_ucode_cnt_start;
wire [0:UCODEDEPTH-1]                        ex0_i1_ucode_cnt_entry;
wire [0:UCODEDEPTH-1]                        ex0_i1_ucode_cnt_start;
wire [0:UCODEDEPTH-1]                        ex0_ucode_cnt_rst;
wire [0:UCODEDEPTH-1]                        ex3_ucode_cnt_entry;
wire [0:UCODEDEPTH-1]                        ex4_ucode_cnt_entry;
wire [0:UCODEDEPTH-1]                        ex4_ucode_cnt_set;
wire [0:1]                                   ucode_cnt_ctrl[0:UCODEDEPTH-1];
wire [0:1]                                   ucode_cnt_2ucode_ctrl[0:UCODEDEPTH-1];
wire [0:UCODEDEPTH-1]                        ucode_cnt_val_d;
wire [0:UCODEDEPTH-1]                        ucode_cnt_val_q;
wire [0:UCODEDEPTH-1]                        ucode_cnt_2ucode_d;
wire [0:UCODEDEPTH-1]                        ucode_cnt_2ucode_q;
wire [0:8]                                   ucode_cnt_memAttr_d[0:UCODEDEPTH-1];
wire [0:8]                                   ucode_cnt_memAttr_q[0:UCODEDEPTH-1];
wire                                         ex4_cache_acc_d;
wire                                         ex4_cache_acc_q;
wire [0:UCODEDEPTH-1]                        ex3_2ucode_cnt_set;
wire                                         ex3_2ucode_set;
wire [0:UCODEDEPTH-1]                        ex4_ucode_align_int;
wire                                         ex4_ucode_align_val;
wire [0:UCODEDEPTH-1]                        ex4_ucode_cnt_restart;
wire                                         ex4_derat_vf_int;
wire                                         ex5_wNComp_rcvd_d;
wire                                         ex5_wNComp_rcvd_q;
wire                                         ex5_wNComp_excp;
wire                                         ex6_wNComp_excp_d;
wire                                         ex6_wNComp_excp_q;
wire                                         ex5_dac_int_det_d;
wire                                         ex5_dac_int_det_q;
wire [0:6]                                   perv_fir_rpt;
wire [0:6]                                   perv_fir_rpt_d;
wire [0:6]                                   perv_fir_rpt_q;

parameter                                    ex4_valid_resv_offset = 0;
parameter                                    ex4_prealign_int_offset = ex4_valid_resv_offset + 1;
parameter                                    ex4_flush_2ucode_offset = ex4_prealign_int_offset + 1;
parameter                                    ex5_flush_2ucode_offset = ex4_flush_2ucode_offset + 1;
parameter                                    ex4_ucode_dis_prog_offset = ex5_flush_2ucode_offset + 1;
parameter                                    ex4_is_dcbz_offset = ex4_ucode_dis_prog_offset + 1;
parameter                                    ex5_misalign_flush_offset = ex4_is_dcbz_offset + 1;
parameter                                    ex4_axu_ap_unavail_offset = ex5_misalign_flush_offset + 1;
parameter                                    ex4_axu_fp_unavail_offset = ex4_axu_ap_unavail_offset + 1;
parameter                                    ex4_axu_spv_unavail_offset = ex4_axu_fp_unavail_offset + 1;
parameter                                    ex5_local_flush_offset = ex4_axu_spv_unavail_offset + 1;
parameter                                    ex5_tlb_flush_req_offset = ex5_local_flush_offset + 1;
parameter                                    ex5_tlb_mchk_req_offset = ex5_tlb_flush_req_offset + 1;
parameter                                    ex5_low_pri_excp_offset = ex5_tlb_mchk_req_offset + 1;
parameter                                    ex5_high_pri_excp_offset = ex5_low_pri_excp_offset + 1;
parameter                                    ex5_exception_offset = ex5_high_pri_excp_offset + 1;
parameter                                    ex5_dear_val_offset = ex5_exception_offset + 6;
parameter                                    ex5_derat_multihit_flush_offset = ex5_dear_val_offset + `THREADS;
parameter                                    ex5_derat_multihit_det_offset = ex5_derat_multihit_flush_offset + 1;
parameter                                    ex5_derat_perr_flush_offset = ex5_derat_multihit_det_offset + 1;
parameter                                    ex5_derat_perr_det_offset = ex5_derat_perr_flush_offset + 1;
parameter                                    ex2_sfx_excpt_det_offset = ex5_derat_perr_det_offset + 1;
parameter                                    ex3_sfx_excpt_det_offset = ex2_sfx_excpt_det_offset + 1;
parameter                                    ex4_sfx_excpt_det_offset = ex3_sfx_excpt_det_offset + 1;
parameter                                    ex2_priv_prog_offset = ex4_sfx_excpt_det_offset + 1;
parameter                                    ex3_priv_prog_offset = ex2_priv_prog_offset + 1;
parameter                                    ex4_priv_prog_offset = ex3_priv_prog_offset + 1;
parameter                                    ex2_hypv_prog_offset = ex4_priv_prog_offset + 1;
parameter                                    ex3_hypv_prog_offset = ex2_hypv_prog_offset + 1;
parameter                                    ex4_hypv_prog_offset = ex3_hypv_prog_offset + 1;
parameter                                    ex2_illeg_prog_offset = ex4_hypv_prog_offset + 1;
parameter                                    ex3_illeg_prog_offset = ex2_illeg_prog_offset + 1;
parameter                                    ex4_illeg_prog_offset = ex3_illeg_prog_offset + 1;
parameter                                    ex2_dlock_excp_offset = ex4_illeg_prog_offset + 1;
parameter                                    ex3_dlock_excp_offset = ex2_dlock_excp_offset + 1;
parameter                                    ex4_dlock_excp_offset = ex3_dlock_excp_offset + 1;
parameter                                    ex2_ilock_excp_offset = ex4_dlock_excp_offset + 1;
parameter                                    ex3_ilock_excp_offset = ex2_ilock_excp_offset + 1;
parameter                                    ex4_ilock_excp_offset = ex3_ilock_excp_offset + 1;
parameter                                    ex2_ehpriv_excp_offset = ex4_ilock_excp_offset + 1;
parameter                                    ex3_ehpriv_excp_offset = ex2_ehpriv_excp_offset + 1;
parameter                                    ex4_cache_acc_offset = ex3_ehpriv_excp_offset + 1;
parameter                                    ex4_ucode_val_offset = ex4_cache_acc_offset + 1;
parameter                                    ex4_ucode_cnt_offset = ex4_ucode_val_offset + 1;
parameter                                    ex5_wNComp_rcvd_offset = ex4_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
parameter                                    ex6_wNComp_excp_offset = ex5_wNComp_rcvd_offset + 1;
parameter                                    ex5_dac_int_det_offset = ex6_wNComp_excp_offset + 1;
parameter                                    perv_fir_rpt_offset = ex5_dac_int_det_offset + 1;
parameter                                    ucode_cnt_val_offset = perv_fir_rpt_offset + 7;
parameter                                    ucode_cnt_2ucode_offset = ucode_cnt_val_offset + UCODEDEPTH;
parameter                                    ucode_cnt_memAttr_offset = ucode_cnt_2ucode_offset + UCODEDEPTH;
parameter                                    scan_right = ucode_cnt_memAttr_offset + 9*UCODEDEPTH - 1;

wire                                         tiup;
wire                                         tidn;
wire [0:scan_right]                          siv;
wire [0:scan_right]                          sov;


(* analysis_not_referenced="true" *)

wire                                         unused;

//--!! Bugspray Include: lq_fgen

// #############################################
// Inputs
// #############################################
assign tiup = 1'b1;
assign tidn = 1'b0;
assign ex4_derat_vf_int = ((ex4_cache_acc_q | ex4_ucode_val_q) & derat_dcc_ex4_vf) & ~(ex4_blkable_touch | ex4_strg_gate | ex4_wclr_all_val);
assign ex5_derat_multihit_flush_d = derat_dcc_ex4_multihit_err_flush & ~ex4_cp_flush_val;
assign ex5_derat_multihit_det_d   = derat_dcc_ex4_multihit_err_det;
assign ex5_derat_perr_flush_d = derat_dcc_ex4_par_err_flush & ~ex4_cp_flush_val;
assign ex5_derat_perr_det_d   = derat_dcc_ex4_par_err_det;
assign ex2_sfx_excpt_det_d = dec_dcc_ex1_expt_det & ~ex1_cp_flush_val;
assign ex3_sfx_excpt_det_d = ex2_sfx_excpt_det_q & ~ex2_cp_flush_val;
assign ex4_sfx_excpt_det_d = ex3_sfx_excpt_det_q & ~ex3_cp_flush_val;
assign ex2_priv_prog_d = dec_dcc_ex1_priv_prog;
assign ex3_priv_prog_d = ex2_priv_prog_q;
assign ex4_priv_prog_d = ex3_priv_prog_q & ex3_sfx_excpt_det_q & ~ex3_cp_flush_val;
assign ex2_hypv_prog_d = dec_dcc_ex1_hypv_prog;
assign ex3_hypv_prog_d = ex2_hypv_prog_q;
assign ex4_hypv_prog_d = (ex3_hypv_prog_q | ex3_ehpriv_excp_q) & ex3_sfx_excpt_det_q & ~ex3_cp_flush_val;
assign ex2_illeg_prog_d = dec_dcc_ex1_illeg_prog;
assign ex3_illeg_prog_d = ex2_illeg_prog_q;
assign ex4_illeg_prog_d = ((ex3_illeg_prog_q & ex3_sfx_excpt_det_q) | ex3_illeg_lswx) & ~ex3_cp_flush_val;
assign ex2_dlock_excp_d = dec_dcc_ex1_dlock_excp;
assign ex3_dlock_excp_d = ex2_dlock_excp_q;
assign ex4_dlock_excp_d = ex3_dlock_excp_q & ex3_sfx_excpt_det_q & ~ex3_cp_flush_val;
assign ex2_ilock_excp_d = dec_dcc_ex1_ilock_excp;
assign ex3_ilock_excp_d = ex2_ilock_excp_q;
assign ex4_ilock_excp_d = ex3_ilock_excp_q & ex3_sfx_excpt_det_q & ~ex3_cp_flush_val;
assign ex2_ehpriv_excp_d = dec_dcc_ex1_ehpriv_excp;
assign ex3_ehpriv_excp_d = ex2_ehpriv_excp_q;
assign ex4_ucode_val_d = ex3_ucode_val & ~ex3_cp_flush_val;
assign ex4_ucode_cnt_d = ex3_ucode_cnt;
assign ex4_is_dcbz_d = ex3_dcbz_instr & ex3_cache_acc & ~ex3_cp_flush_val;
assign ex4_cache_acc_d = ex3_cache_acc & ~ex3_cp_flush_val;

// XUCR[FLSTA] = '0' =>  Flush to ucode
// XUCR[FLSTA] = '1' =>  Flush to Alignment Interrupt
// XUCR[AFLSTA] = '0' =>  Flush to ucode (AXUop)
// XUCR[AFLSTA] = '1' =>  Flush to Alignment Interrupt (AXUop)
assign force_align_int_a =  ex3_axu_op_val & (spr_xucr0_aflsta | ex3_ldst_fexcpt);
assign force_align_int_x = ~ex3_axu_op_val & spr_xucr0_flsta;
assign force_align_int = force_align_int_x | force_align_int_a | ex3_resv_instr | ex3_ldawx_instr | ex3_mword_instr;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// UCODE Memory Attributes Array
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

generate
   if (`THREADS_POOL_ENC == 0) begin : tid1
      wire [0:`THREADS_POOL_ENC]                   ex0_i0_enc_tid;
      wire [0:`THREADS_POOL_ENC]                   ex0_i1_enc_tid;
      wire [0:`THREADS_POOL_ENC]                   ex3_enc_tid;
      wire [0:`THREADS_POOL_ENC]                   ex4_enc_tid;

      assign ex0_i0_tid_ucode_cnt = ex0_i0_ucode_cnt;
      assign ex0_i1_tid_ucode_cnt = ex0_i1_ucode_cnt;
      assign ex3_tid_ucode_cnt = ex3_ucode_cnt;
      assign ex4_tid_ucode_cnt = ex4_ucode_cnt_q;
      assign ex0_i0_enc_tid[`THREADS_POOL_ENC:`THREADS_POOL_ENC] = tidn;
      assign ex0_i1_enc_tid[`THREADS_POOL_ENC:`THREADS_POOL_ENC] = tidn;
      assign ex3_enc_tid[`THREADS_POOL_ENC:`THREADS_POOL_ENC]    = tidn;
      assign ex4_enc_tid[`THREADS_POOL_ENC:`THREADS_POOL_ENC]    = tidn;

      assign unused = ex0_i0_enc_tid[`THREADS_POOL_ENC] | ex0_i1_enc_tid[`THREADS_POOL_ENC] | ex3_enc_tid[`THREADS_POOL_ENC] | ex4_enc_tid[`THREADS_POOL_ENC];
   end
endgenerate

generate
      if (`THREADS_POOL_ENC > 0) begin : tidMulti
         reg  [0:`THREADS_POOL_ENC]                   ex0_i0_enc_tid;
         reg  [0:`THREADS_POOL_ENC]                   ex0_i1_enc_tid;
         reg  [0:`THREADS_POOL_ENC]                   ex3_enc_tid;
         reg  [0:`THREADS_POOL_ENC]                   ex4_enc_tid;
         always @(*) begin: tidEnc
            reg [0:`THREADS_POOL_ENC-1]                  i0Tid;
            reg [0:`THREADS_POOL_ENC-1]                  i1Tid;
            reg [0:`THREADS_POOL_ENC-1]                  ex3Tid;
            reg [0:`THREADS_POOL_ENC-1]                  ex4Tid;

            (* analysis_not_referenced="true" *)

            reg [0:31]				                        tid;
            i0Tid     = {`THREADS_POOL_ENC{1'b0}};
            i1Tid     = {`THREADS_POOL_ENC{1'b0}};
            ex3Tid    = {`THREADS_POOL_ENC{1'b0}};
            ex4Tid    = {`THREADS_POOL_ENC{1'b0}};
            ex0_i0_enc_tid[`THREADS_POOL_ENC:`THREADS_POOL_ENC] <= tidn;
	         ex0_i1_enc_tid[`THREADS_POOL_ENC:`THREADS_POOL_ENC] <= tidn;
	         ex3_enc_tid[`THREADS_POOL_ENC:`THREADS_POOL_ENC]    <= tidn;
	         ex4_enc_tid[`THREADS_POOL_ENC:`THREADS_POOL_ENC]    <= tidn;
            for (tid=0; tid<`THREADS; tid=tid+1) begin
	            i0Tid    = (tid[32-`THREADS_POOL_ENC:31] & {`THREADS_POOL_ENC{ex0_i0_vld[tid]}})  | i0Tid;
	            i1Tid    = (tid[32-`THREADS_POOL_ENC:31] & {`THREADS_POOL_ENC{ex0_i1_vld[tid]}})  | i1Tid;
	            ex3Tid   = (tid[32-`THREADS_POOL_ENC:31] & {`THREADS_POOL_ENC{ex3_thrd_id[tid]}}) | ex3Tid;
	            ex4Tid   = (tid[32-`THREADS_POOL_ENC:31] & {`THREADS_POOL_ENC{ex4_thrd_id[tid]}}) | ex4Tid;
            end
	         ex0_i0_enc_tid[0:`THREADS_POOL_ENC-1] <= i0Tid;
	         ex0_i1_enc_tid[0:`THREADS_POOL_ENC-1] <= i1Tid;
	         ex3_enc_tid[0:`THREADS_POOL_ENC-1]    <= ex3Tid;
	         ex4_enc_tid[0:`THREADS_POOL_ENC-1]    <= ex4Tid;
         end
         assign ex0_i0_tid_ucode_cnt = {ex0_i0_enc_tid[0:`THREADS_POOL_ENC-1], ex0_i0_ucode_cnt};
         assign ex0_i1_tid_ucode_cnt = {ex0_i1_enc_tid[0:`THREADS_POOL_ENC-1], ex0_i1_ucode_cnt};
         assign ex3_tid_ucode_cnt    = {ex3_enc_tid[0:`THREADS_POOL_ENC-1], ex3_ucode_cnt};
         assign ex4_tid_ucode_cnt    = {ex4_enc_tid[0:`THREADS_POOL_ENC-1], ex4_ucode_cnt_q};

         assign unused = ex0_i0_enc_tid[`THREADS_POOL_ENC] | ex0_i1_enc_tid[`THREADS_POOL_ENC] | ex3_enc_tid[`THREADS_POOL_ENC] | ex4_enc_tid[`THREADS_POOL_ENC];
      end
endgenerate

generate begin : memAttrQ
      genvar			ucodeEntry;
      for (ucodeEntry=0; ucodeEntry<UCODEDEPTH; ucodeEntry=ucodeEntry+1) begin : memAttrQ
         wire [0:`UCODE_ENTRIES_ENC+`THREADS_POOL_ENC-1]     ucodeEntryDummy = ucodeEntry;
         // Detect PreIssue of ucode for a given ucode engine entry
         assign ex0_i0_ucode_cnt_entry[ucodeEntry] = (ucodeEntryDummy == ex0_i0_tid_ucode_cnt);
         assign ex0_i0_ucode_cnt_start[ucodeEntry] = ex0_i0_ucode_cnt_entry[ucodeEntry] & |(ex0_i0_vld) & ex0_i0_ucode_preissue;
         assign ex0_i1_ucode_cnt_entry[ucodeEntry] = (ucodeEntryDummy == ex0_i1_tid_ucode_cnt);
         assign ex0_i1_ucode_cnt_start[ucodeEntry] = ex0_i1_ucode_cnt_entry[ucodeEntry] & |(ex0_i1_vld) & ex0_i1_ucode_preissue;

         // Want to reset the ucode engine entry Valid on a PreIssue from Dispatch
         assign ex0_ucode_cnt_rst[ucodeEntry] = ex0_i0_ucode_cnt_start[ucodeEntry] | ex0_i1_ucode_cnt_start[ucodeEntry];

         // Want to Set the ucode engine entry Valid on either the PreIssue or the first ucode instruction from Issue
         // Dont want to set valid if we got an ERAT Miss or a Restart from the ERAT
         assign ex3_ucode_cnt_entry[ucodeEntry] = (ucodeEntryDummy == ex3_tid_ucode_cnt);
         assign ex4_ucode_cnt_entry[ucodeEntry] = (ucodeEntryDummy == ex4_tid_ucode_cnt);
         assign ex4_ucode_cnt_set[ucodeEntry] = ex4_ucode_cnt_entry[ucodeEntry] & ex4_ucode_val_q & ~(ucode_cnt_val_q[ucodeEntry] | derat_dcc_ex4_restart | derat_dcc_ex4_miss | ex4_strg_gate);

         // Control for ucode engine entry Valid
         // We should never see cnt_rst and cnt_set at the same time
         assign ucode_cnt_ctrl[ucodeEntry] = {ex0_ucode_cnt_rst[ucodeEntry], ex4_ucode_cnt_set[ucodeEntry]};

         assign ucode_cnt_val_d[ucodeEntry] = (ucode_cnt_ctrl[ucodeEntry] == 2'b00) ? ucode_cnt_val_q[ucodeEntry] :
                                              (ucode_cnt_ctrl[ucodeEntry] == 2'b01) ? 1'b1 :
                                              1'b0;

         // Control for 2ucode, should only be set on the PreIssue of the ucode instruction
         // We should never set i0_cnt_start and i1_cnt_start for the same ucodeEntry
         assign ucode_cnt_2ucode_ctrl[ucodeEntry] = {ex0_i0_ucode_cnt_start[ucodeEntry], ex0_i1_ucode_cnt_start[ucodeEntry]};

         assign ucode_cnt_2ucode_d[ucodeEntry] = (ucode_cnt_2ucode_ctrl[ucodeEntry] == 2'b10) ? ex0_i0_2ucode :
                                                 (ucode_cnt_2ucode_ctrl[ucodeEntry] == 2'b01) ? ex0_i1_2ucode :
                                                 ucode_cnt_2ucode_q[ucodeEntry];

         // 2ucode Mux Select, want to gate misalignment flush2ucode check on a ucode preIssue
         // that was already flushed2ucode due to misalignment
         assign ex3_2ucode_cnt_set[ucodeEntry] = ucode_cnt_2ucode_q[ucodeEntry] & ex3_ucode_cnt_entry[ucodeEntry];

         // Want to update the memory attribute bits when the Valid is set
         assign ucode_cnt_memAttr_d[ucodeEntry] = ex4_mem_attr;

         // ucode Alignment Interrupt detect
         assign ex4_ucode_align_int[ucodeEntry] = (ucode_cnt_memAttr_q[ucodeEntry] != ex4_mem_attr) & ucode_cnt_val_q[ucodeEntry] & ex4_ucode_cnt_entry[ucodeEntry] & ex4_ucode_op & ex4_cache_acc_q;

         // ucode Restart detected
         // need to wait for preIssue to update the memory attribute bits
         // was hitting a case where
         // 1) second page loads updated memory attribute bits
         // 2) first page and second page memory attributes bits differ
         // 3) second page should be causing a DSI and test expects a DSI
         // 4) first page access was causing an alignment interrupt because memory attributes differed,
         //    should have caused a DSI instead
         assign ex4_ucode_cnt_restart[ucodeEntry] = ex4_ucode_cnt_entry[ucodeEntry] & ex4_ucode_op & ex4_cache_acc_q & ~ucode_cnt_val_q[ucodeEntry];
      end
   end
endgenerate

assign ex4_ucode_align_val = |(ex4_ucode_align_int);
assign ex4_ucode_restart = |(ex4_ucode_cnt_restart);
assign ex3_2ucode_set = |(ex3_2ucode_cnt_set);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Exception Calculations
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// FP, VEC, AP not available
assign ex4_axu_ap_unavail_d = (ex3_cache_acc | ex3_ucode_val) & ex3_axu_op_val & ex3_axu_instr_type[0] & ~(spr_ccr2_ap | ex3_cp_flush_val);
assign ex4_axu_spv_unavail_d = (ex3_cache_acc | ex3_ucode_val) & ex3_axu_op_val & ex3_axu_instr_type[1] & ~(spr_msr_spv | ex3_cp_flush_val);
assign ex4_axu_fp_unavail_d = (ex3_cache_acc | ex3_ucode_val) & ex3_axu_op_val & ex3_axu_instr_type[2] & ~(spr_msr_fp | ex3_cp_flush_val);

// Operation translated to either Write-Through or Cache-Inhibited
assign ex4_wt_ci_trans = derat_dcc_ex4_wimge_w | derat_dcc_ex4_wimge_i;

// ################################################################################################################
// Alignment Interrupt
// 1) Load/Store is not aligned and FLSTA/AFLSTA bit is set
// 2) Unaligned lwarx,ldarx,stwcx, or stdcx
// 3) Unaligned ldawx
// 4) Unaligned AXU operation and fexcpt is set
// 5) dcbz translates to write through required or cache-inhibit
// ################################################################################################################

// ########################
// Unaligned Operation crossing the operand's size
// ########################
// Crossing the Operand Size boundary, only used to determine alignment interrupt if FLSTA = 1 or is_lock_instruction
assign ex3_op16_unal = ex3_optype16 & (ex3_eff_addr[60] | ex3_eff_addr[61] | ex3_eff_addr[62] | ex3_eff_addr[63]);
assign ex3_op8_unal = ex3_optype8 & (ex3_eff_addr[61] | ex3_eff_addr[62] | ex3_eff_addr[63]);
assign ex3_op4_unal = ex3_optype4 & (ex3_eff_addr[62] | ex3_eff_addr[63]);
assign ex3_op2_unal = ex3_optype2 & ex3_eff_addr[63];
assign ex3_unal_op = ex3_op16_unal | ex3_op8_unal | ex3_op4_unal | ex3_op2_unal;
// ########################

// ########################
// Unaligned ICSWX crossing the 64Byte boundary
// ########################
// icswx crossing the 128 byte boundary
assign ex3_icswx_unal = ex3_icswx_type & |(ex3_eff_addr);

// ########################
// Unaligned Operation crossing a 16 Byte boundary
// ########################
assign ex3_16Bop16_unal = ex3_optype16 & (ex3_eff_addr[60] | ex3_eff_addr[61] | ex3_eff_addr[62] | ex3_eff_addr[63]);
assign ex3_16Bop8_unal = ex3_optype8 & ex3_eff_addr[60] & (ex3_eff_addr[61] | ex3_eff_addr[62] | ex3_eff_addr[63]);
assign ex3_16Bop4_unal = ex3_optype4 & ex3_eff_addr[60] & ex3_eff_addr[61] & (ex3_eff_addr[62] | ex3_eff_addr[63]);
assign ex3_16Bop2_unal = ex3_optype2 & ex3_eff_addr[60] & ex3_eff_addr[61] & ex3_eff_addr[62] & ex3_eff_addr[63];
assign ex3_16Bunal_op = ex3_16Bop16_unal | ex3_16Bop8_unal | ex3_16Bop4_unal | ex3_16Bop2_unal;

// Flush to uCode if ucode supports unalignment
assign ex3_flush_2ucode_chk = ex3_cache_acc | (ex3_ucode_val & ~ex3_2ucode_set);
assign ex3_flush_2ucode = (~(ex3_resv_instr | ex3_ldawx_instr | ex3_mword_instr | ex3_icswx_type)) & ex3_16Bunal_op & ex3_flush_2ucode_chk & ~ex3_cp_flush_val;
assign ex4_flush_2ucode_d = ex3_flush_2ucode & ~spr_ccr2_ucode_dis;
assign ex4_ucode_dis_prog_d = ex3_flush_2ucode & spr_ccr2_ucode_dis & ~ex3_cp_flush_val;
assign ex5_flush_2ucode_d = ex4_flush_2ucode_q & ~(ex4_cp_flush_val | ex4_cp_next_excp_rpt | ex4_non_cp_next_excp | ex4_restart_val);

// Alignment Interrupt Collected
assign ex4_prealign_int_d = (ex3_icswx_unal | (force_align_int & (ex3_unal_op | ex3_16Bunal_op))) & (ex3_cache_acc | ex3_ucode_val) & ~ex3_cp_flush_val;

// DCBZ translated to Write-Through or Cache-Inhibited.
assign ex4_dcbz_err = ex4_is_dcbz_q & ex4_wt_ci_trans;
assign ex4_align_int = ex4_prealign_int_q | ((ex4_dcbz_err | ex4_ucode_align_val) & ~derat_dcc_ex4_miss);
// ########################

assign ex5_misalign_flush_d = (ex4_flush_2ucode_q & ~ex4_restart_val) | ex4_prealign_int_q;
// ################################################################################################################

// ################################################################################################################
// Data Storage Interrupt
// 1) lwarx,ldarx,stwcx, or stdcx translate to write through required or cache-inhibit
// ################################################################################################################

// lwarx,ldarx,stwcx,stdcx translate to write-through or cache-inhibit
assign ex3_valid_resv = ex3_resv_instr & ex3_cache_acc & ~ex3_cp_flush_val;

assign ex4_valid_resv_d = ex3_valid_resv;
assign ex4_dsi_int = ex4_valid_resv_q & ex4_wt_ci_trans & ~derat_dcc_ex4_miss;
// ################################################################################################################

// #############################################
// FLUSH CONDITIONS
// #############################################

// ex1 Instruction Flush
assign ex1_cp_flush_val = |(ex1_thrd_id & iu_lq_cp_flush);

// ex2 Instruction Flush and ex2 Speculative Flush
assign ex2_cp_flush_val = |(ex2_thrd_id & iu_lq_cp_flush) | byp_dcc_ex2_req_aborted;

// ex3 Instruction Flush
assign ex3_cp_flush_val = |(ex3_thrd_id & iu_lq_cp_flush);

// ex4 Instruction Flush
// CP_FLUSH should be the only thing coming into this
// this is getting used by the slowspr partition
// If something else needs to go in here, need to create
// a special one for the slowspr partition
assign ex4_cp_flush_val = |(ex4_thrd_id & iu_lq_cp_flush);

// ex5 Instruction Flush
assign ex5_cp_flush_val = |(ex5_thrd_id & iu_lq_cp_flush);

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// ex1 Flush Stage
// 1) Instruction Flush from Completion
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
assign fgen_ex1_stg_flush = ex1_cp_flush_val;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// ex2 Flush Stage
// 1) Instruction Flush from Completion
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
assign fgen_ex2_stg_flush = ex2_cp_flush_val;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// ex3 Flush Stage
// 1) Instruction Flush from Completion
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
assign fgen_ex3_stg_flush = ex3_cp_flush_val;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// ex4 Flush Stage takes into account the following
// 1) Directory Parity Error
// 2) Cache Parity Error
// 3) Directory Multiple ways hit
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
assign ex4_tlb_flush_req = ex4_tlb_perr_flush | ex4_tlb_lru_perr_flush | ex4_tlb_multihit_flush;
assign ex5_tlb_flush_req_d = ex4_tlb_flush_req;
assign ex5_tlb_mchk_req_d = |(ex4_excp_pri[12:14]);
assign ex4_n_flush_req = (ex4_flush_2ucode_q | ex4_dac_int_det | ex4_tlb_flush_req) & ~ex4_restart_val;
assign ex5_flush_req_mchk = |(ex5_excp_pri);
assign ex5_flush_req_int = ex5_derat_perr_flush | ex5_dir_perr_flush | ex5_dc_perr_flush | ex5_derat_multihit_flush | ex5_dir_multihit_flush | dir_dcc_ex5_stp_flush;
assign ex4_local_flush = (ex4_n_flush_req & ~ex4_cp_next_excp_det) | ex4_cp_next_excp_rpt | ex4_non_cp_next_excp;

// Currently a placeholder in case the STQ ever needs to report an exception
assign ex4_excp_det = ex4_local_flush;
assign ex5_local_flush_d = ex4_local_flush;
assign ex5_local_flush = ex5_local_flush_q | ex5_flush_req_int;
assign ex5_dac_int_det_d = ex4_dac_int_det;

// Exception Priority
// POWERPC ARCHITECTURE EXCEPTION PRIORITY
//ex4_excp_pri  <=
//ex4_illeg_prog_q                &       --  0 illegal instr type                        Non CP_NEXT
//ex4_priv_prog_q                 &       --  1 Privilege                                 Non CP_NEXT
//ex4_axu_fp_unavail_q            &       --  2 FP Unavailable                            Non CP_NEXT
//ex4_axu_ap_unavail_q            &       --  3 AP Unavailable                            Non CP_NEXT
//ex4_axu_spv_unavail_q           &       --  4 Vector Unavailable                        Non CP_NEXT
//ex4_ucode_dis_prog_q            &       --  5 Ucode Disabled Program Interrupt          Non CP_NEXT
//ex4_hypv_prog_q                 &       --  6 Hypervisor Privilege                      Non CP_NEXT
//'0'                             &       --  7 DERAT Parity                              Non CP_NEXT
//'0'                             &       --  8 Data Dir Parity Error                     Non CP_NEXT
//'0'                             &       --  9 Data Cache Parity Error                   Non CP_NEXT
//'0'                             &       -- 10 DERAT Multihit                            Non CP_NEXT
//'0'                             &       -- 11 Data Dir Multihit                         Non CP_NEXT
//derat_dcc_ex4_tlb_par_err       &       -- 12 TLB Parity Error                          CP_NEXT
//derat_dcc_ex4_lru_par_err       &       -- 13 TLB LRU Parity Error                      CP_NEXT
//derat_dcc_ex4_tlb_multihit      &       -- 14 TLB Multihit Error                        CP_NEXT
//derat_dcc_ex4_tlb_err           &       -- 15 TLB/DERAT Miss                            CP_NEXT
//ex4_dlock_excp_q                &       -- 16 DSI DLOCK Instruction                     CP_NEXT
//ex4_ilock_excp_q                &       -- 17 DSI ILOCK Instruction                     CP_NEXT
//derat_dcc_ex4_pt_fault          &       -- 18 DSI Page Table Fault                      CP_NEXT
//ex4_derat_vf_int                &       -- 19 DSI Virtualization Fault                  CP_NEXT
//derat_dcc_ex4_tlb_inelig        &       -- 20 TLB Ineligible                            CP_NEXT
//derat_dcc_ex4_dsi               &       -- 21 DSI R/W Access Violation                  CP_NEXT
//ex4_dsi_int                     &       -- 22 LARX/STCX DSI                             CP_NEXT
//ex4_icswx_dsi                   &       -- 23 Unavailable Coprocessor                   CP_NEXT
//ex4_align_int                   &       -- 24 load/store Alignment                      CP_NEXT
//derat_dcc_ex4_lrat_miss;                -- 25 Data Side LRAT Miss                       CP_NEXT

// A2I/A2O ARCHITECTURE EXCEPTION PRIORITY
assign ex4_excp_pri = {ex4_illeg_prog_q,                       //  0 illegal instr type                        Non CP_NEXT
                       ex4_priv_prog_q,                        //  1 Privilege                                 Non CP_NEXT
                       ex4_axu_fp_unavail_q,                   //  2 FP Unavailable                            Non CP_NEXT
                       ex4_axu_ap_unavail_q,                   //  3 AP Unavailable                            Non CP_NEXT
                       ex4_axu_spv_unavail_q,                  //  4 Vector Unavailable                        Non CP_NEXT
                       ex4_ucode_dis_prog_q,                   //  5 Ucode Disabled Program Interrupt          Non CP_NEXT
                       ex4_hypv_prog_q,                        //  6 Hypervisor Privilege                      Non CP_NEXT
                       1'b0,                                   //  7 DERAT Parity                              Non CP_NEXT
                       1'b0,                                   //  8 Data Dir Parity Error                     Non CP_NEXT
                       1'b0,                                   //  9 Data Cache Parity Error                   Non CP_NEXT
                       1'b0,                                   // 10 DERAT Multihit                            Non CP_NEXT
                       1'b0,			                           // 11 Data Dir Multihit                         Non CP_NEXT
                       ex4_tlb_perr_mchk,                      // 12 TLB Parity Error                          CP_NEXT
                       ex4_tlb_lru_perr_mchk,                  // 13 TLB LRU Parity Error                      CP_NEXT
                       ex4_tlb_multihit_mchk,                  // 14 TLB Multihit Error                        CP_NEXT
                       derat_dcc_ex4_tlb_err,                  // 15 TLB/DERAT Miss                            CP_NEXT
                       derat_dcc_ex4_pt_fault,                 // 16 DSI Page Table Fault                      CP_NEXT
                       derat_dcc_ex4_tlb_inelig,               // 17 TLB Ineligible                            CP_NEXT
                       ex4_dlock_excp_q,                       // 18 DSI DLOCK Instruction                     CP_NEXT
                       ex4_ilock_excp_q,                       // 19 DSI ILOCK Instruction                     CP_NEXT
                       ex4_derat_vf_int,                       // 20 DSI Virtualization Fault                  CP_NEXT
                       derat_dcc_ex4_dsi,                      // 21 DSI R/W Access Violation                  CP_NEXT
                       ex4_dsi_int,                            // 22 LARX/STCX DSI                             CP_NEXT
                       ex4_icswx_dsi,                          // 23 Unavailable Coprocessor                   CP_NEXT
                       ex4_align_int,                          // 24 load/store Alignment                      CP_NEXT
                       derat_dcc_ex4_lrat_miss};               // 25 Data Side LRAT Miss                       CP_NEXT
                                                               // 26 L2 Reload ECC_UE Machine Check            Non CP_NEXT    Detected by Loadmiss Queue on reload

// Machine Check Enabled Interrupts
assign ex4_tlb_perr_mchk = derat_dcc_ex4_tlb_par_err & spr_xucr4_mmu_mchk;
assign ex4_tlb_lru_perr_mchk = derat_dcc_ex4_lru_par_err & spr_xucr4_mmu_mchk;
assign ex4_tlb_multihit_mchk = derat_dcc_ex4_tlb_multihit & spr_xucr4_mmu_mchk;
assign ex5_derat_perr_mchk = ex5_derat_perr_flush_q & (spr_xucr4_mmu_mchk | spr_ccr2_notlb);
assign ex5_dir_perr_mchk = dir_dcc_ex5_dir_perr_flush & spr_xucr0_mddp;
assign ex5_dc_perr_mchk = dir_dcc_ex5_dc_perr_flush & spr_xucr0_mdcp;
assign ex5_derat_multihit_mchk = ex5_derat_multihit_flush_q & (spr_xucr4_mmu_mchk | spr_ccr2_notlb);
assign ex5_dir_multihit_mchk = dir_dcc_ex5_multihit_flush & spr_xucr4_mddmh;

// N-Flush Generated Scenarios
assign ex4_tlb_perr_flush = derat_dcc_ex4_tlb_par_err;
assign ex4_tlb_lru_perr_flush = derat_dcc_ex4_lru_par_err;
assign ex4_tlb_multihit_flush = derat_dcc_ex4_tlb_multihit;
assign ex5_derat_perr_flush = ex5_derat_perr_flush_q;
assign ex5_dir_perr_flush = dir_dcc_ex5_dir_perr_flush;
assign ex5_dc_perr_flush = dir_dcc_ex5_dc_perr_flush;
assign ex5_derat_multihit_flush = ex5_derat_multihit_flush_q;
assign ex5_dir_multihit_flush = dir_dcc_ex5_multihit_flush;

assign ex4_exception = (ex4_excp_pri[0] == 1'b1)  ? 6'b000000 :
                       (ex4_excp_pri[1] == 1'b1)  ? 6'b000001 :
                       (ex4_excp_pri[2] == 1'b1)  ? 6'b000010 :
                       (ex4_excp_pri[3] == 1'b1)  ? 6'b000011 :
                       (ex4_excp_pri[4] == 1'b1)  ? 6'b000100 :
                       (ex4_excp_pri[5] == 1'b1)  ? 6'b000101 :
                       (ex4_excp_pri[6] == 1'b1)  ? 6'b000110 :
                       (ex4_excp_pri[7] == 1'b1)  ? 6'b000111 :
                       (ex4_excp_pri[8] == 1'b1)  ? 6'b001000 :
                       (ex4_excp_pri[9] == 1'b1)  ? 6'b001001 :
                       (ex4_excp_pri[10] == 1'b1) ? 6'b001010 :
                       (ex4_excp_pri[11] == 1'b1) ? 6'b001011 :
                       (ex4_excp_pri[12] == 1'b1) ? 6'b001100 :
                       (ex4_excp_pri[13] == 1'b1) ? 6'b001101 :
                       (ex4_excp_pri[14] == 1'b1) ? 6'b001110 :
                       (ex4_excp_pri[15] == 1'b1) ? 6'b001111 :
                       (ex4_excp_pri[16] == 1'b1) ? 6'b010000 :
                       (ex4_excp_pri[17] == 1'b1) ? 6'b010001 :
                       (ex4_excp_pri[18] == 1'b1) ? 6'b010010 :
                       (ex4_excp_pri[19] == 1'b1) ? 6'b010011 :
                       (ex4_excp_pri[20] == 1'b1) ? 6'b010100 :
                       (ex4_excp_pri[21] == 1'b1) ? 6'b010101 :
                       (ex4_excp_pri[22] == 1'b1) ? 6'b010110 :
                       (ex4_excp_pri[23] == 1'b1) ? 6'b010111 :
                       (ex4_excp_pri[24] == 1'b1) ? 6'b011000 :
                                                    6'b011001;

assign ex5_excp_pri = {ex5_derat_perr_mchk,           // 7  DERAT Parity
                       ex5_dir_perr_mchk,             // 8  Data Dir Parity Error
                       ex5_dc_perr_mchk,              // 9  Data Cache Parity Error
                       ex5_derat_multihit_mchk,       // 10 DERAT Multihit
                       ex5_dir_multihit_mchk};		  // 11 Data Dir Multihit


assign ex5_mid_pri_excp = (ex5_excp_pri[7] == 1'b1)  ? 6'b000111 :
                          (ex5_excp_pri[8] == 1'b1)  ? 6'b001000 :
                          (ex5_excp_pri[9] == 1'b1)  ? 6'b001001 :
                          (ex5_excp_pri[10] == 1'b1) ? 6'b001010 :
                                                       6'b001011;

assign ex5_sel_mid_pri_excp = ex5_flush_req_int & ~ex5_high_pri_excp_q;
assign ex4_non_cp_next_excp = |(ex4_excp_pri[0:11]);
assign ex5_high_pri_excp_d = ex4_non_cp_next_excp & ~ex4_cp_flush_val;
assign ex5_low_pri_excp_d = ex4_cp_next_excp & ~ex4_cp_flush_val;
assign ex4_cp_next_excp = |(ex4_excp_pri[12:25]) & ex4_wNComp_rcvd & ~ex4_restart_val;
assign ex4_cp_next_excp_det = |(ex4_excp_pri[12:25]) & ~ex4_restart_val;
assign ex4_cp_next_excp_rpt = ex4_cp_next_excp;
assign ex4_wNComp_excp = ex4_cp_next_excp_det & ~(ex4_cp_flush_val | ex4_non_cp_next_excp);
assign ex4_sfx_excpt_det = ex4_sfx_excpt_det_q;

// Want to blow away everything when there is a Non-CP_NEXT exception detected
assign ex5_flush_req = ex5_flush_req_int | ex5_high_pri_excp_q;
assign ex5_exception_d = ex4_exception;

// CP_NEXT instruction got a Flush
// need to restart instructions behind it so that the directory
// does not get corrupted, this handles the case where a dcbtls
// got an exception and a lq pipeline instruction behind it bypassed
// the wrong directory results, also needed in case there is a parity
// error in either directory, dataCache, or erats
assign ex5_wNComp_rcvd_d = ex4_wNComp_rcvd;
assign ex5_wNComp_excp = (ex5_wNComp_rcvd_q & ex5_local_flush) | dir_dcc_ex5_dir_perr_det | dir_dcc_ex5_dc_perr_det |
                         dir_dcc_ex5_multihit_det              | ex5_derat_multihit_det_q | ex5_derat_perr_det_q    |
                         dir_dcc_stq4_dir_perr_det             | dir_dcc_stq4_multihit_det;
assign ex6_wNComp_excp_d = ex5_wNComp_excp;
assign ex4_wNComp_excp_restart = ex5_wNComp_excp | ex6_wNComp_excp_q;

// Select between EX4 and EX5 Exceptions

assign ex5_exception_int = ~ex5_sel_mid_pri_excp ? ex5_exception_q : ex5_mid_pri_excp;
assign ex5_dear_val_d    = ex4_thrd_id & {`THREADS{ex4_cp_next_excp_rpt}};
assign ex5_flush2ucode   = ex5_flush_2ucode_q & ~(ex5_flush_req_int | ex5_high_pri_excp_q);
assign ex5_n_flush       = ex5_local_flush_q | ex5_flush_req_int;
assign ex5_np1_flush     = 1'b0; //'

// Want to take an interrupt if
// 1) high priority interrupt ex4_excp_pri(0:6)         => program interrupts, these interrupts ignore any bad machine path errors detected by
//                                                         data cache, directory, and erat
// 2) mid priority interrupt ex4_excp_pri(7:11)         => machine check enabled and bad machine path error detected by
//                                                         data cache, directory, or erat
// 3) mid priority interrupt ex4_excp_pri(12:14)        => machine check enabled and bad machine path error detected by the MMU, these exceptions
//                                                         are gated if error detected by data cache, directory, or erat and machine check disabled for error
// 4) low priority interrupt ex4_excp_pri(15:25)        => translation type interrupts, these exceptions are gated if error detected by
//                                                         data cache, directory, mmu, or erat and machine check disabled for error
assign ex5_exception_val = ex5_high_pri_excp_q | ex5_flush_req_mchk | (ex5_tlb_mchk_req_q & ~ex5_flush_req_int) | (ex5_low_pri_excp_q & ~(ex5_flush_req_int | ex5_tlb_flush_req_q));
assign ex5_exception = ex5_exception_int;
assign ex5_dear_val = ex5_dear_val_q;
assign ex5_blk_tlb_req = ex5_high_pri_excp_q | ex5_flush_req_int;
assign fgen_ex4_stg_flush = ex4_cp_flush_val | ex4_n_flush_req | ex4_non_cp_next_excp | ex4_cp_next_excp_det;
assign fgen_ex5_stg_flush = ex5_cp_flush_val | ex5_local_flush | ex5_restart_val | ex5_dac_int_det_q;
assign ex5_flush_pfetch  = dir_dcc_ex5_dir_perr_det | dir_dcc_ex5_dc_perr_det | dir_dcc_ex5_multihit_det  |
                           ex5_derat_multihit_det_q | ex5_derat_perr_det_q    | dir_dcc_stq4_dir_perr_det |
                           dir_dcc_stq4_multihit_det;
assign fgen_ex4_cp_flush = ex4_cp_flush_val;
assign fgen_ex5_cp_flush = ex5_cp_flush_val;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// FIR Error Reporting
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign perv_fir_rpt_d = {derat_fir_par_err, dir_dcc_ex5_dir_perr_det, dir_dcc_ex5_dc_perr_det, derat_fir_multihit, dir_dcc_ex5_multihit_det, dir_dcc_stq4_dir_perr_det, dir_dcc_stq4_multihit_det};

tri_direct_err_rpt #(.WIDTH(7)) pervFir(
   .vd(vdd),
   .gd(gnd),
   .err_in(perv_fir_rpt_q),
   .err_out(perv_fir_rpt)
);

assign lq_pc_err_derat_parity = perv_fir_rpt[0];
assign lq_pc_err_dir_ldp_parity = perv_fir_rpt[1];
assign lq_pc_err_dcache_parity = perv_fir_rpt[2];
assign lq_pc_err_derat_multihit = perv_fir_rpt[3];
assign lq_pc_err_dir_ldp_multihit = perv_fir_rpt[4];
assign lq_pc_err_dir_stp_parity = perv_fir_rpt[5];
assign lq_pc_err_dir_stp_multihit = perv_fir_rpt[6];

// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// Performance Events
// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
assign ex5_misalign_flush = ex5_misalign_flush_q;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
// Registers
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_valid_resv_reg(
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
   .scin(siv[ex4_valid_resv_offset]),
   .scout(sov[ex4_valid_resv_offset]),
   .din(ex4_valid_resv_d),
   .dout(ex4_valid_resv_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_prealign_int_reg(
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
   .scin(siv[ex4_prealign_int_offset]),
   .scout(sov[ex4_prealign_int_offset]),
   .din(ex4_prealign_int_d),
   .dout(ex4_prealign_int_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_flush_2ucode_reg(
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
   .scin(siv[ex4_flush_2ucode_offset]),
   .scout(sov[ex4_flush_2ucode_offset]),
   .din(ex4_flush_2ucode_d),
   .dout(ex4_flush_2ucode_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_flush_2ucode_reg(
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
   .scin(siv[ex5_flush_2ucode_offset]),
   .scout(sov[ex5_flush_2ucode_offset]),
   .din(ex5_flush_2ucode_d),
   .dout(ex5_flush_2ucode_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_ucode_dis_prog_reg(
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
   .scin(siv[ex4_ucode_dis_prog_offset]),
   .scout(sov[ex4_ucode_dis_prog_offset]),
   .din(ex4_ucode_dis_prog_d),
   .dout(ex4_ucode_dis_prog_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_is_dcbz_reg(
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
   .scin(siv[ex4_is_dcbz_offset]),
   .scout(sov[ex4_is_dcbz_offset]),
   .din(ex4_is_dcbz_d),
   .dout(ex4_is_dcbz_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_misalign_flush_reg(
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
   .scin(siv[ex5_misalign_flush_offset]),
   .scout(sov[ex5_misalign_flush_offset]),
   .din(ex5_misalign_flush_d),
   .dout(ex5_misalign_flush_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_axu_ap_unavail_reg(
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
   .scin(siv[ex4_axu_ap_unavail_offset]),
   .scout(sov[ex4_axu_ap_unavail_offset]),
   .din(ex4_axu_ap_unavail_d),
   .dout(ex4_axu_ap_unavail_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_axu_fp_unavail_reg(
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
   .scin(siv[ex4_axu_fp_unavail_offset]),
   .scout(sov[ex4_axu_fp_unavail_offset]),
   .din(ex4_axu_fp_unavail_d),
   .dout(ex4_axu_fp_unavail_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_axu_spv_unavail_reg(
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
   .scin(siv[ex4_axu_spv_unavail_offset]),
   .scout(sov[ex4_axu_spv_unavail_offset]),
   .din(ex4_axu_spv_unavail_d),
   .dout(ex4_axu_spv_unavail_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_local_flush_reg(
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
   .scin(siv[ex5_local_flush_offset]),
   .scout(sov[ex5_local_flush_offset]),
   .din(ex5_local_flush_d),
   .dout(ex5_local_flush_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_tlb_flush_req_reg(
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
   .scin(siv[ex5_tlb_flush_req_offset]),
   .scout(sov[ex5_tlb_flush_req_offset]),
   .din(ex5_tlb_flush_req_d),
   .dout(ex5_tlb_flush_req_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_tlb_mchk_req_reg(
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
   .scin(siv[ex5_tlb_mchk_req_offset]),
   .scout(sov[ex5_tlb_mchk_req_offset]),
   .din(ex5_tlb_mchk_req_d),
   .dout(ex5_tlb_mchk_req_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_low_pri_excp_reg(
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
   .scin(siv[ex5_low_pri_excp_offset]),
   .scout(sov[ex5_low_pri_excp_offset]),
   .din(ex5_low_pri_excp_d),
   .dout(ex5_low_pri_excp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_high_pri_excp_reg(
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
   .scin(siv[ex5_high_pri_excp_offset]),
   .scout(sov[ex5_high_pri_excp_offset]),
   .din(ex5_high_pri_excp_d),
   .dout(ex5_high_pri_excp_q)
);

tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) ex5_exception_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_exception_offset:ex5_exception_offset + 6 - 1]),
   .scout(sov[ex5_exception_offset:ex5_exception_offset + 6 - 1]),
   .din(ex5_exception_d),
   .dout(ex5_exception_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_dear_val_reg(
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
   .scin(siv[ex5_dear_val_offset:ex5_dear_val_offset + `THREADS - 1]),
   .scout(sov[ex5_dear_val_offset:ex5_dear_val_offset + `THREADS - 1]),
   .din(ex5_dear_val_d),
   .dout(ex5_dear_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_derat_multihit_flush_reg(
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
   .scin(siv[ex5_derat_multihit_flush_offset]),
   .scout(sov[ex5_derat_multihit_flush_offset]),
   .din(ex5_derat_multihit_flush_d),
   .dout(ex5_derat_multihit_flush_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_derat_multihit_det_reg(
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
   .scin(siv[ex5_derat_multihit_det_offset]),
   .scout(sov[ex5_derat_multihit_det_offset]),
   .din(ex5_derat_multihit_det_d),
   .dout(ex5_derat_multihit_det_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_derat_perr_flush_reg(
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
   .scin(siv[ex5_derat_perr_flush_offset]),
   .scout(sov[ex5_derat_perr_flush_offset]),
   .din(ex5_derat_perr_flush_d),
   .dout(ex5_derat_perr_flush_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_derat_perr_det_reg(
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
   .scin(siv[ex5_derat_perr_det_offset]),
   .scout(sov[ex5_derat_perr_det_offset]),
   .din(ex5_derat_perr_det_d),
   .dout(ex5_derat_perr_det_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sfx_excpt_det_reg(
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
   .scin(siv[ex2_sfx_excpt_det_offset]),
   .scout(sov[ex2_sfx_excpt_det_offset]),
   .din(ex2_sfx_excpt_det_d),
   .dout(ex2_sfx_excpt_det_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_sfx_excpt_det_reg(
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
   .scin(siv[ex3_sfx_excpt_det_offset]),
   .scout(sov[ex3_sfx_excpt_det_offset]),
   .din(ex3_sfx_excpt_det_d),
   .dout(ex3_sfx_excpt_det_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_sfx_excpt_det_reg(
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
   .scin(siv[ex4_sfx_excpt_det_offset]),
   .scout(sov[ex4_sfx_excpt_det_offset]),
   .din(ex4_sfx_excpt_det_d),
   .dout(ex4_sfx_excpt_det_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_priv_prog_reg(
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
   .scin(siv[ex2_priv_prog_offset]),
   .scout(sov[ex2_priv_prog_offset]),
   .din(ex2_priv_prog_d),
   .dout(ex2_priv_prog_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_priv_prog_reg(
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
   .scin(siv[ex3_priv_prog_offset]),
   .scout(sov[ex3_priv_prog_offset]),
   .din(ex3_priv_prog_d),
   .dout(ex3_priv_prog_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_priv_prog_reg(
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
   .scin(siv[ex4_priv_prog_offset]),
   .scout(sov[ex4_priv_prog_offset]),
   .din(ex4_priv_prog_d),
   .dout(ex4_priv_prog_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_hypv_prog_reg(
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
   .scin(siv[ex2_hypv_prog_offset]),
   .scout(sov[ex2_hypv_prog_offset]),
   .din(ex2_hypv_prog_d),
   .dout(ex2_hypv_prog_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_hypv_prog_reg(
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
   .scin(siv[ex3_hypv_prog_offset]),
   .scout(sov[ex3_hypv_prog_offset]),
   .din(ex3_hypv_prog_d),
   .dout(ex3_hypv_prog_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_hypv_prog_reg(
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
   .scin(siv[ex4_hypv_prog_offset]),
   .scout(sov[ex4_hypv_prog_offset]),
   .din(ex4_hypv_prog_d),
   .dout(ex4_hypv_prog_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_illeg_prog_reg(
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
   .scin(siv[ex2_illeg_prog_offset]),
   .scout(sov[ex2_illeg_prog_offset]),
   .din(ex2_illeg_prog_d),
   .dout(ex2_illeg_prog_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_illeg_prog_reg(
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
   .scin(siv[ex3_illeg_prog_offset]),
   .scout(sov[ex3_illeg_prog_offset]),
   .din(ex3_illeg_prog_d),
   .dout(ex3_illeg_prog_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_illeg_prog_reg(
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
   .scin(siv[ex4_illeg_prog_offset]),
   .scout(sov[ex4_illeg_prog_offset]),
   .din(ex4_illeg_prog_d),
   .dout(ex4_illeg_prog_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_dlock_excp_reg(
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
   .scin(siv[ex2_dlock_excp_offset]),
   .scout(sov[ex2_dlock_excp_offset]),
   .din(ex2_dlock_excp_d),
   .dout(ex2_dlock_excp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_dlock_excp_reg(
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
   .scin(siv[ex3_dlock_excp_offset]),
   .scout(sov[ex3_dlock_excp_offset]),
   .din(ex3_dlock_excp_d),
   .dout(ex3_dlock_excp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_dlock_excp_reg(
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
   .scin(siv[ex4_dlock_excp_offset]),
   .scout(sov[ex4_dlock_excp_offset]),
   .din(ex4_dlock_excp_d),
   .dout(ex4_dlock_excp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ilock_excp_reg(
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
   .scin(siv[ex2_ilock_excp_offset]),
   .scout(sov[ex2_ilock_excp_offset]),
   .din(ex2_ilock_excp_d),
   .dout(ex2_ilock_excp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_ilock_excp_reg(
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
   .scin(siv[ex3_ilock_excp_offset]),
   .scout(sov[ex3_ilock_excp_offset]),
   .din(ex3_ilock_excp_d),
   .dout(ex3_ilock_excp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_ilock_excp_reg(
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
   .scin(siv[ex4_ilock_excp_offset]),
   .scout(sov[ex4_ilock_excp_offset]),
   .din(ex4_ilock_excp_d),
   .dout(ex4_ilock_excp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ehpriv_excp_reg(
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
   .scin(siv[ex2_ehpriv_excp_offset]),
   .scout(sov[ex2_ehpriv_excp_offset]),
   .din(ex2_ehpriv_excp_d),
   .dout(ex2_ehpriv_excp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_ehpriv_excp_reg(
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
   .scin(siv[ex3_ehpriv_excp_offset]),
   .scout(sov[ex3_ehpriv_excp_offset]),
   .din(ex3_ehpriv_excp_d),
   .dout(ex3_ehpriv_excp_q)
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

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_ucode_val_reg(
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
   .scin(siv[ex4_ucode_val_offset]),
   .scout(sov[ex4_ucode_val_offset]),
   .din(ex4_ucode_val_d),
   .dout(ex4_ucode_val_q)
);

tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0), .NEEDS_SRESET(1)) ex4_ucode_cnt_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_ucode_cnt_offset:ex4_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
   .scout(sov[ex4_ucode_cnt_offset:ex4_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
   .din(ex4_ucode_cnt_d),
   .dout(ex4_ucode_cnt_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_wNComp_rcvd_reg(
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
   .scin(siv[ex5_wNComp_rcvd_offset]),
   .scout(sov[ex5_wNComp_rcvd_offset]),
   .din(ex5_wNComp_rcvd_d),
   .dout(ex5_wNComp_rcvd_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_wNComp_excp_reg(
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
   .scin(siv[ex6_wNComp_excp_offset]),
   .scout(sov[ex6_wNComp_excp_offset]),
   .din(ex6_wNComp_excp_d),
   .dout(ex6_wNComp_excp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_dac_int_det_reg(
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
   .scin(siv[ex5_dac_int_det_offset]),
   .scout(sov[ex5_dac_int_det_offset]),
   .din(ex5_dac_int_det_d),
   .dout(ex5_dac_int_det_q)
);

tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) perv_fir_rpt_reg(
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
   .scin(siv[perv_fir_rpt_offset:perv_fir_rpt_offset + 7 - 1]),
   .scout(sov[perv_fir_rpt_offset:perv_fir_rpt_offset + 7 - 1]),
   .din(perv_fir_rpt_d),
   .dout(perv_fir_rpt_q)
);

tri_rlmreg_p #(.WIDTH(UCODEDEPTH), .INIT(0), .NEEDS_SRESET(1)) ucode_cnt_val_reg(
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
   .scin(siv[ucode_cnt_val_offset:ucode_cnt_val_offset + UCODEDEPTH - 1]),
   .scout(sov[ucode_cnt_val_offset:ucode_cnt_val_offset + UCODEDEPTH - 1]),
   .din(ucode_cnt_val_d),
   .dout(ucode_cnt_val_q)
);

tri_rlmreg_p #(.WIDTH(UCODEDEPTH), .INIT(0), .NEEDS_SRESET(1)) ucode_cnt_2ucode_reg(
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
   .scin(siv[ucode_cnt_2ucode_offset:ucode_cnt_2ucode_offset + UCODEDEPTH - 1]),
   .scout(sov[ucode_cnt_2ucode_offset:ucode_cnt_2ucode_offset + UCODEDEPTH - 1]),
   .din(ucode_cnt_2ucode_d),
   .dout(ucode_cnt_2ucode_q)
);

generate begin : ucode_cnt_memAttr
  genvar ucodeEntry;
  for (ucodeEntry=0; ucodeEntry<UCODEDEPTH; ucodeEntry=ucodeEntry+1) begin : ucode_cnt_memAttr
    tri_rlmreg_p #(.WIDTH(9), .INIT(1), .NEEDS_SRESET(1)) ucode_cnt_memAttr_reg(
       .vd(vdd),
       .gd(gnd),
       .nclk(nclk),
       .act(ex4_ucode_cnt_set[ucodeEntry]),
       .force_t(func_sl_force),
       .d_mode(d_mode_dc),
       .delay_lclkr(delay_lclkr_dc),
       .mpw1_b(mpw1_dc_b),
       .mpw2_b(mpw2_dc_b),
       .thold_b(func_sl_thold_0_b),
       .sg(sg_0),
       .scin(siv[ucode_cnt_memAttr_offset + 9*ucodeEntry:ucode_cnt_memAttr_offset + 9*(ucodeEntry+1)-1]),
       .scout(sov[ucode_cnt_memAttr_offset + 9*ucodeEntry:ucode_cnt_memAttr_offset + 9*(ucodeEntry+1)-1]),
       .din(ucode_cnt_memAttr_d[ucodeEntry]),
       .dout(ucode_cnt_memAttr_q[ucodeEntry])
    );
  end
end
endgenerate

assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
assign scan_out = sov[0];

endmodule
