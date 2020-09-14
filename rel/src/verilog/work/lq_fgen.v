// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns



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


input [0:`THREADS-1]                         ex0_i0_vld;
input                                        ex0_i0_ucode_preissue;
input                                        ex0_i0_2ucode;
input [0:`UCODE_ENTRIES_ENC-1]               ex0_i0_ucode_cnt;
input [0:`THREADS-1]                         ex0_i1_vld;
input                                        ex0_i1_ucode_preissue;
input                                        ex0_i1_2ucode;
input [0:`UCODE_ENTRIES_ENC-1]               ex0_i1_ucode_cnt;

input                                        dec_dcc_ex1_expt_det;
input                                        dec_dcc_ex1_priv_prog;
input                                        dec_dcc_ex1_hypv_prog;
input                                        dec_dcc_ex1_illeg_prog;
input                                        dec_dcc_ex1_dlock_excp;
input                                        dec_dcc_ex1_ilock_excp;
input                                        dec_dcc_ex1_ehpriv_excp;
input                                        byp_dcc_ex2_req_aborted;

input                                        ex3_stg_act;
input                                        ex4_stg_act;
input [0:`THREADS-1]                         ex1_thrd_id;
input [0:`THREADS-1]                         ex2_thrd_id;
input [0:`THREADS-1]                         ex3_thrd_id;
input [0:`THREADS-1]                         ex4_thrd_id;
input [0:`THREADS-1]                         ex5_thrd_id;
input                                        ex3_cache_acc;			         
input                                        ex3_ucode_val;			         
input [0:`UCODE_ENTRIES_ENC-1]               ex3_ucode_cnt;			         
input                                        ex4_ucode_op;			         
input [0:8]                                  ex4_mem_attr;                 
input                                        ex4_blkable_touch;            
input                                        ex3_ldst_fexcpt;			      
input                                        ex3_axu_op_val;			      
input [0:2]                                  ex3_axu_instr_type;           
input                                        ex3_optype16;			         
input                                        ex3_optype8;			         
input                                        ex3_optype4;			         
input                                        ex3_optype2;			         
input [57:63]                                ex3_eff_addr;                 
input                                        ex3_icswx_type;               
input                                        ex3_dcbz_instr;			      
input                                        ex3_resv_instr;			      
input                                        ex3_mword_instr;			      
input                                        ex3_ldawx_instr;			      
input                                        ex3_illeg_lswx;			      
input                                        ex4_icswx_dsi;			         
input                                        ex4_wclr_all_val;			      
input                                        ex4_wNComp_rcvd;			      
input                                        ex4_dac_int_det;			      
input                                        ex4_strg_gate;			         
input                                        ex4_restart_val;			      
input                                        ex5_restart_val;			      
                                                                           
input                                        spr_ccr2_ucode_dis;		      
input                                        spr_ccr2_notlb;			      
input                                        spr_xucr0_mddp;			      
input                                        spr_xucr0_mdcp;			      
input                                        spr_xucr4_mmu_mchk;		      
input                                        spr_xucr4_mddmh;			      

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

input                                        dir_dcc_ex5_dir_perr_det;		
input                                        dir_dcc_ex5_dc_perr_det;		
input                                        dir_dcc_ex5_dir_perr_flush;	
input                                        dir_dcc_ex5_dc_perr_flush;		
input                                        dir_dcc_ex5_multihit_det;		
input                                        dir_dcc_ex5_multihit_flush;	
input                                        dir_dcc_stq4_dir_perr_det;		
input                                        dir_dcc_stq4_multihit_det;		
input                                        dir_dcc_ex5_stp_flush;        

input                                        spr_xucr0_aflsta;
input                                        spr_xucr0_flsta;
input                                        spr_ccr2_ap;
input                                        spr_msr_fp;
input                                        spr_msr_spv;

input [0:`THREADS-1]                         iu_lq_cp_flush;

output                                       ex4_ucode_restart;			   
output                                       ex4_sfx_excpt_det;			   
output                                       ex4_excp_det;			         
output                                       ex4_wNComp_excp;			      
output                                       ex4_wNComp_excp_restart;	   
output                                       ex5_flush_req;			         
output                                       ex5_blk_tlb_req;			      
output                                       ex5_flush_pfetch;             
output                                       fgen_ex4_cp_flush;			   
output                                       fgen_ex5_cp_flush;			   
output                                       fgen_ex1_stg_flush;		      
output                                       fgen_ex2_stg_flush;		      
output                                       fgen_ex3_stg_flush;		      
output                                       fgen_ex4_stg_flush;		      
output                                       fgen_ex5_stg_flush;		      
                                                                           
output                                       ex5_flush2ucode;			      
output                                       ex5_n_flush;			         
output                                       ex5_np1_flush;			         
output                                       ex5_exception_val;		      
output [0:5]                                 ex5_exception;			         
output [0:`THREADS-1]                        ex5_dear_val;			         

output                                       ex5_misalign_flush;

output                                       lq_pc_err_derat_parity;
output                                       lq_pc_err_dir_ldp_parity;
output                                       lq_pc_err_dir_stp_parity;
output                                       lq_pc_err_dcache_parity;
output                                       lq_pc_err_derat_multihit;
output                                       lq_pc_err_dir_ldp_multihit;
output                                       lq_pc_err_dir_stp_multihit;


                       
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


parameter                                    UCODEDEPTH = (2**`UCODE_ENTRIES_ENC)*`THREADS;

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

assign force_align_int_a =  ex3_axu_op_val & (spr_xucr0_aflsta | ex3_ldst_fexcpt);
assign force_align_int_x = ~ex3_axu_op_val & spr_xucr0_flsta;
assign force_align_int = force_align_int_x | force_align_int_a | ex3_resv_instr | ex3_ldawx_instr | ex3_mword_instr;
   
   
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
         assign ex0_i0_ucode_cnt_entry[ucodeEntry] = (ucodeEntryDummy == ex0_i0_tid_ucode_cnt);
         assign ex0_i0_ucode_cnt_start[ucodeEntry] = ex0_i0_ucode_cnt_entry[ucodeEntry] & |(ex0_i0_vld) & ex0_i0_ucode_preissue;
         assign ex0_i1_ucode_cnt_entry[ucodeEntry] = (ucodeEntryDummy == ex0_i1_tid_ucode_cnt);
         assign ex0_i1_ucode_cnt_start[ucodeEntry] = ex0_i1_ucode_cnt_entry[ucodeEntry] & |(ex0_i1_vld) & ex0_i1_ucode_preissue;
         
         assign ex0_ucode_cnt_rst[ucodeEntry] = ex0_i0_ucode_cnt_start[ucodeEntry] | ex0_i1_ucode_cnt_start[ucodeEntry];
         
         assign ex3_ucode_cnt_entry[ucodeEntry] = (ucodeEntryDummy == ex3_tid_ucode_cnt);
         assign ex4_ucode_cnt_entry[ucodeEntry] = (ucodeEntryDummy == ex4_tid_ucode_cnt);
         assign ex4_ucode_cnt_set[ucodeEntry] = ex4_ucode_cnt_entry[ucodeEntry] & ex4_ucode_val_q & ~(ucode_cnt_val_q[ucodeEntry] | derat_dcc_ex4_restart | derat_dcc_ex4_miss | ex4_strg_gate);
         
         assign ucode_cnt_ctrl[ucodeEntry] = {ex0_ucode_cnt_rst[ucodeEntry], ex4_ucode_cnt_set[ucodeEntry]};
         
         assign ucode_cnt_val_d[ucodeEntry] = (ucode_cnt_ctrl[ucodeEntry] == 2'b00) ? ucode_cnt_val_q[ucodeEntry] : 
                                              (ucode_cnt_ctrl[ucodeEntry] == 2'b01) ? 1'b1 : 
                                              1'b0;

         assign ucode_cnt_2ucode_ctrl[ucodeEntry] = {ex0_i0_ucode_cnt_start[ucodeEntry], ex0_i1_ucode_cnt_start[ucodeEntry]};
         
         assign ucode_cnt_2ucode_d[ucodeEntry] = (ucode_cnt_2ucode_ctrl[ucodeEntry] == 2'b10) ? ex0_i0_2ucode : 
                                                 (ucode_cnt_2ucode_ctrl[ucodeEntry] == 2'b01) ? ex0_i1_2ucode : 
                                                 ucode_cnt_2ucode_q[ucodeEntry];

         assign ex3_2ucode_cnt_set[ucodeEntry] = ucode_cnt_2ucode_q[ucodeEntry] & ex3_ucode_cnt_entry[ucodeEntry];
         
         assign ucode_cnt_memAttr_d[ucodeEntry] = ex4_mem_attr;
         
         assign ex4_ucode_align_int[ucodeEntry] = (ucode_cnt_memAttr_q[ucodeEntry] != ex4_mem_attr) & ucode_cnt_val_q[ucodeEntry] & ex4_ucode_cnt_entry[ucodeEntry] & ex4_ucode_op & ex4_cache_acc_q;
         
         assign ex4_ucode_cnt_restart[ucodeEntry] = ex4_ucode_cnt_entry[ucodeEntry] & ex4_ucode_op & ex4_cache_acc_q & ~ucode_cnt_val_q[ucodeEntry];
      end
   end
endgenerate
      
assign ex4_ucode_align_val = |(ex4_ucode_align_int);
assign ex4_ucode_restart = |(ex4_ucode_cnt_restart);
assign ex3_2ucode_set = |(ex3_2ucode_cnt_set);


assign ex4_axu_ap_unavail_d = (ex3_cache_acc | ex3_ucode_val) & ex3_axu_op_val & ex3_axu_instr_type[0] & ~(spr_ccr2_ap | ex3_cp_flush_val);
assign ex4_axu_spv_unavail_d = (ex3_cache_acc | ex3_ucode_val) & ex3_axu_op_val & ex3_axu_instr_type[1] & ~(spr_msr_spv | ex3_cp_flush_val);
assign ex4_axu_fp_unavail_d = (ex3_cache_acc | ex3_ucode_val) & ex3_axu_op_val & ex3_axu_instr_type[2] & ~(spr_msr_fp | ex3_cp_flush_val);

assign ex4_wt_ci_trans = derat_dcc_ex4_wimge_w | derat_dcc_ex4_wimge_i;


assign ex3_op16_unal = ex3_optype16 & (ex3_eff_addr[60] | ex3_eff_addr[61] | ex3_eff_addr[62] | ex3_eff_addr[63]);
assign ex3_op8_unal = ex3_optype8 & (ex3_eff_addr[61] | ex3_eff_addr[62] | ex3_eff_addr[63]);
assign ex3_op4_unal = ex3_optype4 & (ex3_eff_addr[62] | ex3_eff_addr[63]);
assign ex3_op2_unal = ex3_optype2 & ex3_eff_addr[63];
assign ex3_unal_op = ex3_op16_unal | ex3_op8_unal | ex3_op4_unal | ex3_op2_unal;

assign ex3_icswx_unal = ex3_icswx_type & |(ex3_eff_addr);

assign ex3_16Bop16_unal = ex3_optype16 & (ex3_eff_addr[60] | ex3_eff_addr[61] | ex3_eff_addr[62] | ex3_eff_addr[63]);
assign ex3_16Bop8_unal = ex3_optype8 & ex3_eff_addr[60] & (ex3_eff_addr[61] | ex3_eff_addr[62] | ex3_eff_addr[63]);
assign ex3_16Bop4_unal = ex3_optype4 & ex3_eff_addr[60] & ex3_eff_addr[61] & (ex3_eff_addr[62] | ex3_eff_addr[63]);
assign ex3_16Bop2_unal = ex3_optype2 & ex3_eff_addr[60] & ex3_eff_addr[61] & ex3_eff_addr[62] & ex3_eff_addr[63];
assign ex3_16Bunal_op = ex3_16Bop16_unal | ex3_16Bop8_unal | ex3_16Bop4_unal | ex3_16Bop2_unal;

assign ex3_flush_2ucode_chk = ex3_cache_acc | (ex3_ucode_val & ~ex3_2ucode_set);
assign ex3_flush_2ucode = (~(ex3_resv_instr | ex3_ldawx_instr | ex3_mword_instr | ex3_icswx_type)) & ex3_16Bunal_op & ex3_flush_2ucode_chk & ~ex3_cp_flush_val;
assign ex4_flush_2ucode_d = ex3_flush_2ucode & ~spr_ccr2_ucode_dis;
assign ex4_ucode_dis_prog_d = ex3_flush_2ucode & spr_ccr2_ucode_dis & ~ex3_cp_flush_val;
assign ex5_flush_2ucode_d = ex4_flush_2ucode_q & ~(ex4_cp_flush_val | ex4_cp_next_excp_rpt | ex4_non_cp_next_excp | ex4_restart_val);

assign ex4_prealign_int_d = (ex3_icswx_unal | (force_align_int & (ex3_unal_op | ex3_16Bunal_op))) & (ex3_cache_acc | ex3_ucode_val) & ~ex3_cp_flush_val;

assign ex4_dcbz_err = ex4_is_dcbz_q & ex4_wt_ci_trans;
assign ex4_align_int = ex4_prealign_int_q | ((ex4_dcbz_err | ex4_ucode_align_val) & ~derat_dcc_ex4_miss);

assign ex5_misalign_flush_d = (ex4_flush_2ucode_q & ~ex4_restart_val) | ex4_prealign_int_q;


assign ex3_valid_resv = ex3_resv_instr & ex3_cache_acc & ~ex3_cp_flush_val;

assign ex4_valid_resv_d = ex3_valid_resv;
assign ex4_dsi_int = ex4_valid_resv_q & ex4_wt_ci_trans & ~derat_dcc_ex4_miss;


assign ex1_cp_flush_val = |(ex1_thrd_id & iu_lq_cp_flush);

assign ex2_cp_flush_val = |(ex2_thrd_id & iu_lq_cp_flush) | byp_dcc_ex2_req_aborted;

assign ex3_cp_flush_val = |(ex3_thrd_id & iu_lq_cp_flush);

assign ex4_cp_flush_val = |(ex4_thrd_id & iu_lq_cp_flush);

assign ex5_cp_flush_val = |(ex5_thrd_id & iu_lq_cp_flush);

assign fgen_ex1_stg_flush = ex1_cp_flush_val;

assign fgen_ex2_stg_flush = ex2_cp_flush_val;

assign fgen_ex3_stg_flush = ex3_cp_flush_val;

assign ex4_tlb_flush_req = ex4_tlb_perr_flush | ex4_tlb_lru_perr_flush | ex4_tlb_multihit_flush;
assign ex5_tlb_flush_req_d = ex4_tlb_flush_req;
assign ex5_tlb_mchk_req_d = |(ex4_excp_pri[12:14]);
assign ex4_n_flush_req = (ex4_flush_2ucode_q | ex4_dac_int_det | ex4_tlb_flush_req) & ~ex4_restart_val;
assign ex5_flush_req_mchk = |(ex5_excp_pri);
assign ex5_flush_req_int = ex5_derat_perr_flush | ex5_dir_perr_flush | ex5_dc_perr_flush | ex5_derat_multihit_flush | ex5_dir_multihit_flush | dir_dcc_ex5_stp_flush;
assign ex4_local_flush = (ex4_n_flush_req & ~ex4_cp_next_excp_det) | ex4_cp_next_excp_rpt | ex4_non_cp_next_excp;

assign ex4_excp_det = ex4_local_flush;
assign ex5_local_flush_d = ex4_local_flush;
assign ex5_local_flush = ex5_local_flush_q | ex5_flush_req_int;
assign ex5_dac_int_det_d = ex4_dac_int_det;



assign ex4_excp_pri = {ex4_illeg_prog_q,                       
                       ex4_priv_prog_q,                        
                       ex4_axu_fp_unavail_q,                   
                       ex4_axu_ap_unavail_q,                   
                       ex4_axu_spv_unavail_q,                  
                       ex4_ucode_dis_prog_q,                   
                       ex4_hypv_prog_q,                        
                       1'b0,                                   
                       1'b0,                                   
                       1'b0,                                   
                       1'b0,                                   
                       1'b0,			                           
                       ex4_tlb_perr_mchk,                      
                       ex4_tlb_lru_perr_mchk,                  
                       ex4_tlb_multihit_mchk,                  
                       derat_dcc_ex4_tlb_err,                  
                       derat_dcc_ex4_pt_fault,                 
                       derat_dcc_ex4_tlb_inelig,               
                       ex4_dlock_excp_q,                       
                       ex4_ilock_excp_q,                       
                       ex4_derat_vf_int,                       
                       derat_dcc_ex4_dsi,                      
                       ex4_dsi_int,                            
                       ex4_icswx_dsi,                          
                       ex4_align_int,                          
                       derat_dcc_ex4_lrat_miss};               

assign ex4_tlb_perr_mchk = derat_dcc_ex4_tlb_par_err & spr_xucr4_mmu_mchk;
assign ex4_tlb_lru_perr_mchk = derat_dcc_ex4_lru_par_err & spr_xucr4_mmu_mchk;
assign ex4_tlb_multihit_mchk = derat_dcc_ex4_tlb_multihit & spr_xucr4_mmu_mchk;
assign ex5_derat_perr_mchk = ex5_derat_perr_flush_q & (spr_xucr4_mmu_mchk | spr_ccr2_notlb);
assign ex5_dir_perr_mchk = dir_dcc_ex5_dir_perr_flush & spr_xucr0_mddp;
assign ex5_dc_perr_mchk = dir_dcc_ex5_dc_perr_flush & spr_xucr0_mdcp;
assign ex5_derat_multihit_mchk = ex5_derat_multihit_flush_q & (spr_xucr4_mmu_mchk | spr_ccr2_notlb);
assign ex5_dir_multihit_mchk = dir_dcc_ex5_multihit_flush & spr_xucr4_mddmh;
      
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

assign ex5_excp_pri = {ex5_derat_perr_mchk,           
                       ex5_dir_perr_mchk,             
                       ex5_dc_perr_mchk,              
                       ex5_derat_multihit_mchk,       
                       ex5_dir_multihit_mchk};		  

      
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
      
assign ex5_flush_req = ex5_flush_req_int | ex5_high_pri_excp_q;
assign ex5_exception_d = ex4_exception;
      
assign ex5_wNComp_rcvd_d = ex4_wNComp_rcvd;
assign ex5_wNComp_excp = (ex5_wNComp_rcvd_q & ex5_local_flush) | dir_dcc_ex5_dir_perr_det | dir_dcc_ex5_dc_perr_det | 
                         dir_dcc_ex5_multihit_det              | ex5_derat_multihit_det_q | ex5_derat_perr_det_q    |
                         dir_dcc_stq4_dir_perr_det             | dir_dcc_stq4_multihit_det;
assign ex6_wNComp_excp_d = ex5_wNComp_excp;
assign ex4_wNComp_excp_restart = ex5_wNComp_excp | ex6_wNComp_excp_q;
      
      
assign ex5_exception_int = ~ex5_sel_mid_pri_excp ? ex5_exception_q : ex5_mid_pri_excp;
assign ex5_dear_val_d    = ex4_thrd_id & {`THREADS{ex4_cp_next_excp_rpt}};
assign ex5_flush2ucode   = ex5_flush_2ucode_q & ~(ex5_flush_req_int | ex5_high_pri_excp_q);
assign ex5_n_flush       = ex5_local_flush_q | ex5_flush_req_int;
assign ex5_np1_flush     = 1'b0; 
      
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
      
assign ex5_misalign_flush = ex5_misalign_flush_q;
      
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


