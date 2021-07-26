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

//  Description:  LQ SFX Decode
//*****************************************************************************

`include "tri_a2o.vh"



module lq_dec(
   nclk,
   vdd,
   gnd,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   func_sl_force,
   func_sl_thold_0_b,
   func_slp_sl_force,
   func_slp_sl_thold_0_b,
   sg_0,
   scan_in,
   scan_out,
   xu_lq_spr_msr_gs,
   xu_lq_spr_msr_pr,
   xu_lq_spr_msr_ucle,
   xu_lq_spr_msrp_uclep,
   xu_lq_spr_ccr2_en_pc,
   xu_lq_spr_ccr2_en_ditc,
   xu_lq_spr_ccr2_en_icswx,
   iu_lq_cp_flush,
   rv_lq_vld,
   rv_lq_ex0_itag,
   rv_lq_ex0_instr,
   rv_lq_ex0_ucode,
   rv_lq_ex0_ucode_cnt,
   rv_lq_ex0_t1_v,
   rv_lq_ex0_t1_p,
   rv_lq_ex0_t3_p,
   rv_lq_ex0_s1_v,
   rv_lq_ex0_s2_v,
   dcc_dec_hold_all,
   xu_lq_hold_req,
   mm_lq_hold_req,
   mm_lq_hold_done,
   lq_rv_itag0_vld,
   lq_rv_itag0,
   lq_rv_itag0_abort,
   lq_rv_hold_all,
   lq_rv_gpr_ex6_we,
   lq_xu_gpr_ex5_we,
   lq_xu_ex5_act,
   dec_byp_ex1_s1_vld,
   dec_byp_ex1_s2_vld,
   dec_byp_ex1_use_imm,
   dec_byp_ex1_imm,
   dec_byp_ex1_rs1_zero,
   dec_byp_ex0_stg_act,
   dec_byp_ex1_stg_act,
   dec_byp_ex5_stg_act,
   dec_byp_ex6_stg_act,
   dec_byp_ex7_stg_act,
   byp_dec_ex2_req_aborted,
   byp_dec_ex1_s1_abort,
   byp_dec_ex1_s2_abort,
   pf_dec_req_addr,
   pf_dec_req_thrd,
   pf_dec_req_val,
   dec_pf_ack,
   lsq_ctl_sync_in_stq,
   lsq_ctl_stq_release_itag_vld,
   lsq_ctl_stq_release_itag,
   lsq_ctl_stq_release_tid,
   lsq_ctl_rv0_back_inv,
   lsq_ctl_rv1_back_inv_addr,
   dcc_dec_arr_rd_rv1_val,
   dcc_dec_arr_rd_congr_cl,
   dir_dec_rel3_dir_wr_val,
   dir_dec_rel3_dir_wr_addr,
   dcc_dec_stq3_mftgpr_val,
   dcc_dec_stq5_mftgpr_val,
   derat_rv1_snoop_val,
   derat_dec_rv1_snoop_addr,
   derat_dec_hole_all,
   dec_dcc_ex1_cmd_act,
   ctl_dat_ex1_data_act,
   dec_derat_ex1_derat_act,
   dec_dir_ex2_dir_rd_act,
   dec_derat_ex1_pfetch_val,
   dec_spr_ex1_valid,
   dec_dcc_ex1_expt_det,
   dec_dcc_ex1_priv_prog,
   dec_dcc_ex1_hypv_prog,
   dec_dcc_ex1_illeg_prog,
   dec_dcc_ex1_dlock_excp,
   dec_dcc_ex1_ilock_excp,
   dec_dcc_ex1_ehpriv_excp,
   dec_dcc_ex1_ucode_val,
   dec_dcc_ex1_ucode_cnt,
   dec_dcc_ex1_ucode_op,
   dec_dcc_ex1_sfx_val,
   dec_dcc_ex1_cache_acc,
   dec_dcc_ex1_thrd_id,
   dec_dcc_ex1_instr,
   dec_dcc_ex1_optype1,
   dec_dcc_ex1_optype2,
   dec_dcc_ex1_optype4,
   dec_dcc_ex1_optype8,
   dec_dcc_ex1_optype16,
   dec_dcc_ex1_optype32,
   dec_dcc_ex1_target_gpr,
   dec_dcc_ex1_load_instr,
   dec_dcc_ex1_store_instr,
   dec_dcc_ex1_dcbf_instr,
   dec_dcc_ex1_sync_instr,
   dec_dcc_ex1_mbar_instr,
   dec_dcc_ex1_makeitso_instr,
   dec_dcc_ex1_l_fld,
   dec_dcc_ex1_dcbi_instr,
   dec_dcc_ex1_dcbz_instr,
   dec_dcc_ex1_dcbt_instr,
   dec_dcc_ex1_pfetch_val,
   dec_dcc_ex1_dcbtst_instr,
   dec_dcc_ex1_th_fld,
   dec_dcc_ex1_dcbtls_instr,
   dec_dcc_ex1_dcbtstls_instr,
   dec_dcc_ex1_dcblc_instr,
   dec_dcc_ex1_dci_instr,
   dec_dcc_ex1_dcbst_instr,
   dec_dcc_ex1_icbi_instr,
   dec_dcc_ex1_ici_instr,
   dec_dcc_ex1_icblc_instr,
   dec_dcc_ex1_icbt_instr,
   dec_dcc_ex1_icbtls_instr,
   dec_dcc_ex1_tlbsync_instr,
   dec_dcc_ex1_resv_instr,
   dec_dcc_ex1_cr_fld,
   dec_dcc_ex1_mutex_hint,
   dec_dcc_ex1_axu_op_val,
   dec_dcc_ex1_axu_falign,
   dec_dcc_ex1_axu_fexcpt,
   dec_dcc_ex1_axu_instr_type,
   dec_dcc_ex1_upd_form,
   dec_dcc_ex1_algebraic,
   dec_dcc_ex1_strg_index,
   dec_dcc_ex1_src_gpr,
   dec_dcc_ex1_src_axu,
   dec_dcc_ex1_src_dp,
   dec_dcc_ex1_targ_gpr,
   dec_dcc_ex1_targ_axu,
   dec_dcc_ex1_targ_dp,
   dec_derat_ex1_is_load,
   dec_derat_ex1_is_store,
   dec_derat_ex0_val,
   dec_derat_ex0_is_extload,
   dec_derat_ex0_is_extstore,
   dec_derat_ex1_ra_eq_ea,
   dec_derat_ex1_byte_rev,
   dec_derat_ex1_is_touch,
   dec_dcc_ex1_is_msgsnd,
   dec_dcc_ex1_mtspr_trace,
   dec_dcc_ex1_mword_instr,
   dec_dcc_ex1_icswx_instr,
   dec_dcc_ex1_icswxdot_instr,
   dec_dcc_ex1_icswx_epid,
   dec_dcc_ex1_ldawx_instr,
   dec_dcc_ex1_wclr_instr,
   dec_dcc_ex1_wchk_instr,
   dec_dcc_ex1_itag,
   dec_dcc_ex2_rotsel_ovrd,
   dec_dcc_ex3_mtdp_val,
   dec_dcc_ex3_mfdp_val,
   dec_dcc_ex3_ipc_ba,
   dec_dcc_ex3_ipc_sz,
   dec_ex2_is_any_load_dac,
   dec_ex2_is_any_store_dac,
   dec_dcc_ex5_req_abort_rpt,
   dec_dcc_ex5_axu_abort_rpt,
   ctl_lsq_ex_pipe_full,
   dcc_dec_ex5_wren
);

//-------------------------------------------------------------------
// Generics
//-------------------------------------------------------------------
//parameter                                               EXPAND_TYPE = 2;
//parameter                                               `GPR_WIDTH_ENC = 6;
//parameter                                               `XER_POOL_ENC = 4;
//parameter                                               `CR_POOL_ENC = 5;
//parameter                                               `GPR_POOL_ENC = 6;
//parameter                                               `AXU_SPARE_ENC = 3;
//parameter                                               `CL_SIZE = 6;
//parameter                                               `REAL_IFAR_WIDTH = 42;
//parameter                                               `UCODE_ENTRIES_ENC = 3;
//parameter                                               `THREADS = 2;
//parameter                                               `THREADS_POOL_ENC = 1;
//parameter                                               `ITAG_SIZE_ENC = 7;



inout                                                       vdd;


inout                                                       gnd;

(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

input [0:`NCLK_WIDTH-1]                                     nclk;

input                                                       d_mode_dc;
input                                                       delay_lclkr_dc;
input                                                       mpw1_dc_b;
input                                                       mpw2_dc_b;
input                                                       func_sl_force;
input                                                       func_sl_thold_0_b;
input                                                       func_slp_sl_force;
input                                                       func_slp_sl_thold_0_b;
input                                                       sg_0;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input                                                       scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output                                                      scan_out;

input [0:`THREADS-1]                                        xu_lq_spr_msr_gs;
input [0:`THREADS-1]                                        xu_lq_spr_msr_pr;
input [0:`THREADS-1]                                        xu_lq_spr_msr_ucle;
input [0:`THREADS-1]                                        xu_lq_spr_msrp_uclep;
input                                                       xu_lq_spr_ccr2_en_pc;
input                                                       xu_lq_spr_ccr2_en_ditc;
input                                                       xu_lq_spr_ccr2_en_icswx;

input [0:`THREADS-1]                                        iu_lq_cp_flush;

input [0:`THREADS-1]                                        rv_lq_vld;
input [0:`ITAG_SIZE_ENC-1]                                  rv_lq_ex0_itag;
input [0:31]                                                rv_lq_ex0_instr;
input [0:1]                                                 rv_lq_ex0_ucode;
input [0:`UCODE_ENTRIES_ENC-1]                              rv_lq_ex0_ucode_cnt;
input                                                       rv_lq_ex0_t1_v;
input [0:`GPR_POOL_ENC-1]                                   rv_lq_ex0_t1_p;
input [0:`GPR_POOL_ENC-1]                                   rv_lq_ex0_t3_p;
input                                                       rv_lq_ex0_s1_v;
input                                                       rv_lq_ex0_s2_v;

input                                                       dcc_dec_hold_all;

input                                                       xu_lq_hold_req;
input                                                       mm_lq_hold_req;
input                                                       mm_lq_hold_done;

output [0:`THREADS-1]                                       lq_rv_itag0_vld;
output [0:`ITAG_SIZE_ENC-1]                                 lq_rv_itag0;
output                                                      lq_rv_itag0_abort;
output                                                      lq_rv_hold_all;

output                                                      lq_rv_gpr_ex6_we;
output                                                      lq_xu_gpr_ex5_we;

output                                                      lq_xu_ex5_act;
output                                                      dec_byp_ex1_s1_vld;
output                                                      dec_byp_ex1_s2_vld;
output                                                      dec_byp_ex1_use_imm;
output [64-(2**`GPR_WIDTH_ENC):63]                          dec_byp_ex1_imm;
output                                                      dec_byp_ex1_rs1_zero;
output                                                      dec_byp_ex0_stg_act;
output                                                      dec_byp_ex1_stg_act;
output                                                      dec_byp_ex5_stg_act;
output                                                      dec_byp_ex6_stg_act;
output                                                      dec_byp_ex7_stg_act;
input                                                       byp_dec_ex2_req_aborted;
input                                                       byp_dec_ex1_s1_abort;
input                                                       byp_dec_ex1_s2_abort;
input [64-(2**`GPR_WIDTH_ENC):63-`CL_SIZE]                  pf_dec_req_addr;
input [0:`THREADS-1]                                        pf_dec_req_thrd;
input                                                       pf_dec_req_val;
output                                                      dec_pf_ack;

input                                                       lsq_ctl_sync_in_stq;

input                                                       lsq_ctl_stq_release_itag_vld;
input [0:`ITAG_SIZE_ENC-1]                                  lsq_ctl_stq_release_itag;
input [0:`THREADS-1]                                        lsq_ctl_stq_release_tid;

input                                                       lsq_ctl_rv0_back_inv;
input [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                     lsq_ctl_rv1_back_inv_addr;

input                                                       dcc_dec_arr_rd_rv1_val;
input [0:5]                                                 dcc_dec_arr_rd_congr_cl;
input                                                       dir_dec_rel3_dir_wr_val;     // Reload Directory Write Stage is valid
input [64-(`DC_SIZE-3):63-`CL_SIZE]                         dir_dec_rel3_dir_wr_addr;   // Reload Directory Write Address
input                                                       dcc_dec_stq3_mftgpr_val;
input                                                       dcc_dec_stq5_mftgpr_val;

input                                                       derat_rv1_snoop_val;
input [0:51]                                                derat_dec_rv1_snoop_addr;
input                                                       derat_dec_hole_all;

output                                                      dec_dcc_ex1_cmd_act;
output                                                      ctl_dat_ex1_data_act;
output                                                      dec_derat_ex1_derat_act;
output                                                      dec_dir_ex2_dir_rd_act;
output [0:`THREADS-1]                                       dec_derat_ex1_pfetch_val;
output [0:`THREADS-1]                                       dec_spr_ex1_valid;
output                                                      dec_dcc_ex1_expt_det;
output                                                      dec_dcc_ex1_priv_prog;
output                                                      dec_dcc_ex1_hypv_prog;
output                                                      dec_dcc_ex1_illeg_prog;
output                                                      dec_dcc_ex1_dlock_excp;
output                                                      dec_dcc_ex1_ilock_excp;
output                                                      dec_dcc_ex1_ehpriv_excp;
output                                                      dec_dcc_ex1_ucode_val;
output [0:`UCODE_ENTRIES_ENC-1]                             dec_dcc_ex1_ucode_cnt;
output                                                      dec_dcc_ex1_ucode_op;
output                                                      dec_dcc_ex1_sfx_val;
output                                                      dec_dcc_ex1_cache_acc;
output [0:`THREADS-1]                                       dec_dcc_ex1_thrd_id;
output [0:31]                                               dec_dcc_ex1_instr;
output                                                      dec_dcc_ex1_optype1;
output                                                      dec_dcc_ex1_optype2;
output                                                      dec_dcc_ex1_optype4;
output                                                      dec_dcc_ex1_optype8;
output                                                      dec_dcc_ex1_optype16;
output                                                      dec_dcc_ex1_optype32;
output [0:`GPR_POOL_ENC+`THREADS_POOL_ENC+`AXU_SPARE_ENC-1] dec_dcc_ex1_target_gpr;
output                                                      dec_dcc_ex1_load_instr;
output                                                      dec_dcc_ex1_store_instr;
output                                                      dec_dcc_ex1_dcbf_instr;
output                                                      dec_dcc_ex1_sync_instr;
output                                                      dec_dcc_ex1_mbar_instr;
output                                                      dec_dcc_ex1_makeitso_instr;
output [0:1]                                                dec_dcc_ex1_l_fld;
output                                                      dec_dcc_ex1_dcbi_instr;
output                                                      dec_dcc_ex1_dcbz_instr;
output                                                      dec_dcc_ex1_dcbt_instr;
output                                                      dec_dcc_ex1_pfetch_val;
output                                                      dec_dcc_ex1_dcbtst_instr;
output [0:4]                                                dec_dcc_ex1_th_fld;
output                                                      dec_dcc_ex1_dcbtls_instr;
output                                                      dec_dcc_ex1_dcbtstls_instr;
output                                                      dec_dcc_ex1_dcblc_instr;
output                                                      dec_dcc_ex1_dci_instr;
output                                                      dec_dcc_ex1_dcbst_instr;
output                                                      dec_dcc_ex1_icbi_instr;
output                                                      dec_dcc_ex1_ici_instr;
output                                                      dec_dcc_ex1_icblc_instr;
output                                                      dec_dcc_ex1_icbt_instr;
output                                                      dec_dcc_ex1_icbtls_instr;
output                                                      dec_dcc_ex1_tlbsync_instr;
output                                                      dec_dcc_ex1_resv_instr;
output [0:`CR_POOL_ENC-1]                                   dec_dcc_ex1_cr_fld;
output                                                      dec_dcc_ex1_mutex_hint;
output                                                      dec_dcc_ex1_axu_op_val;
output                                                      dec_dcc_ex1_axu_falign;
output                                                      dec_dcc_ex1_axu_fexcpt;
output [0:2]                                                dec_dcc_ex1_axu_instr_type;
output                                                      dec_dcc_ex1_upd_form;
output                                                      dec_dcc_ex1_algebraic;
output                                                      dec_dcc_ex1_strg_index;
output                                                      dec_dcc_ex1_src_gpr;
output                                                      dec_dcc_ex1_src_axu;
output                                                      dec_dcc_ex1_src_dp;
output                                                      dec_dcc_ex1_targ_gpr;
output                                                      dec_dcc_ex1_targ_axu;
output                                                      dec_dcc_ex1_targ_dp;
output                                                      dec_derat_ex1_is_load;
output                                                      dec_derat_ex1_is_store;
output [0:`THREADS-1]                                       dec_derat_ex0_val;
output                                                      dec_derat_ex0_is_extload;
output                                                      dec_derat_ex0_is_extstore;
output                                                      dec_derat_ex1_ra_eq_ea;
output                                                      dec_derat_ex1_byte_rev;
output                                                      dec_derat_ex1_is_touch;
output                                                      dec_dcc_ex1_is_msgsnd;
output                                                      dec_dcc_ex1_mtspr_trace;
output                                                      dec_dcc_ex1_mword_instr;
output                                                      dec_dcc_ex1_icswx_instr;
output                                                      dec_dcc_ex1_icswxdot_instr;
output                                                      dec_dcc_ex1_icswx_epid;
output                                                      dec_dcc_ex1_ldawx_instr;
output                                                      dec_dcc_ex1_wclr_instr;
output                                                      dec_dcc_ex1_wchk_instr;
output [0:`ITAG_SIZE_ENC-1]                                 dec_dcc_ex1_itag;
output [0:4]                                                dec_dcc_ex2_rotsel_ovrd;
output                                                      dec_dcc_ex3_mtdp_val;
output                                                      dec_dcc_ex3_mfdp_val;
output [0:4]                                                dec_dcc_ex3_ipc_ba;
output [0:1]                                                dec_dcc_ex3_ipc_sz;
output                                                      dec_ex2_is_any_load_dac;
output                                                      dec_ex2_is_any_store_dac;
output                                                      dec_dcc_ex5_req_abort_rpt;
output                                                      dec_dcc_ex5_axu_abort_rpt;
output                                                      ctl_lsq_ex_pipe_full;

input                                                       dcc_dec_ex5_wren;
//@@  Signal Declarations
wire [1:79]                                                 TBL_LD_ST_DEC_PT;
wire [1:50]                                                 TBL_VAL_STG_GATE_PT;
wire                                                        tiup;
wire                                                        tidn;
parameter                                                   AXU_TARGET_ENC = `GPR_POOL_ENC + `THREADS_POOL_ENC + `AXU_SPARE_ENC;
//-------------------------------------------------------------------
// Immediate Logic
//-------------------------------------------------------------------
wire                                                        ex1_zero_imm;
wire                                                        ex1_use_imm;
wire                                                        ex1_imm_size;
wire                                                        ex1_imm_signext;
wire [0:15]                                                 ex1_16b_imm;
wire [0:63]                                                 ex1_64b_imm;
wire [0:63]                                                 ex1_imm_sign_ext;
wire                                                        ex1_pfetch_rel_collision;
wire                                                        ex1_use_pfetch;
//-------------------------------------------------------------------
// Instruction Decode
//-------------------------------------------------------------------
wire                                                        ex1_opcode_is_62;
wire                                                        ex1_opcode_is_58;
wire                                                        ex1_opcode_is_31;
wire                                                        ex1_is_dcbf;
wire                                                        ex1_is_dcbi;
wire                                                        ex1_is_dcbst;
wire                                                        ex1_is_dcblc;
wire                                                        ex1_is_dcbt;
wire                                                        ex1_is_dcbtls;
wire                                                        ex1_is_dcbtst;
wire                                                        ex1_is_dcbtstls;
wire                                                        ex1_is_dcbz;
wire                                                        ex1_is_dci;
wire                                                        ex1_is_ici;
wire                                                        ex1_is_icbi;
wire                                                        ex1_is_icblc;
wire                                                        ex1_is_icbt;
wire                                                        ex1_is_icbtls;
wire                                                        ex1_is_lbz;
wire                                                        ex1_is_lbzu;
wire                                                        ex1_is_lbzux;
wire                                                        ex1_is_ld;
wire                                                        ex1_is_ldbrx;
wire                                                        ex1_is_ldu;
wire                                                        ex1_is_ldux;
wire                                                        ex1_is_lha;
wire                                                        ex1_is_lhau;
wire                                                        ex1_is_lhaux;
wire                                                        ex1_is_lhbrx;
wire                                                        ex1_is_lhzux;
wire                                                        ex1_is_lhz;
wire                                                        ex1_is_lhzu;
wire                                                        ex1_is_lmw;
wire                                                        ex1_is_lswi;
wire                                                        ex1_is_lwa;
wire                                                        ex1_is_lwaux;
wire                                                        ex1_is_lwz;
wire                                                        ex1_is_lwzu;
wire                                                        ex1_is_lwzux;
wire                                                        ex1_is_lwbrx;
wire                                                        ex1_derat_is_load;
wire                                                        ex1_derat_is_store;
wire                                                        ex1_is_ditc;
wire                                                        ex1_is_mfdp;
wire                                                        ex1_is_mfdpx;
wire                                                        ex1_is_mtdp;
wire                                                        ex1_is_mtdpx;
wire                                                        ex1_is_stb;
wire                                                        ex1_is_stbu;
wire                                                        ex1_is_stbux;
wire                                                        ex1_is_std;
wire                                                        ex1_is_stdbrx;
wire                                                        ex1_is_stdu;
wire                                                        ex1_is_stdux;
wire                                                        ex1_is_sth;
wire                                                        ex1_is_sthu;
wire                                                        ex1_is_sthux;
wire                                                        ex1_is_sthbrx;
wire                                                        ex1_is_stmw;
wire                                                        ex1_is_stswi;
wire                                                        ex1_is_stw;
wire                                                        ex1_is_stwbrx;
wire                                                        ex1_is_stwu;
wire                                                        ex1_is_stwux;
wire                                                        ex1_is_tlbsync;
wire                                                        ex1_is_lbepx;
wire                                                        ex1_is_lhepx;
wire                                                        ex1_is_lwepx;
wire                                                        ex1_is_ldepx;
wire                                                        ex1_is_stbepx;
wire                                                        ex1_is_sthepx;
wire                                                        ex1_is_stwepx;
wire                                                        ex1_is_stdepx;
wire                                                        ex1_is_dcbstep;
wire                                                        ex1_is_dcbtep;
wire                                                        ex1_is_dcbfep;
wire                                                        ex1_is_dcbtstep;
wire                                                        ex1_is_icbiep;
wire                                                        ex1_is_dcbzep;
wire                                                        ex1_is_msgsnd;
wire                                                        ex1_is_icswx;
wire                                                        ex1_is_icswepx;
wire                                                        ex1_is_wclr;
wire                                                        ex1_mtspr_trace;
wire                                                        ex0_is_lbepx;
wire                                                        ex0_is_lhepx;
wire                                                        ex0_is_lwepx;
wire                                                        ex0_is_ldepx;
wire                                                        ex0_is_dcbfep;
wire                                                        ex0_is_dcbtep;
wire                                                        ex0_is_dcbtstep;
wire                                                        ex0_is_dcbstep;
wire                                                        ex0_is_icbiep;
wire                                                        ex0_is_dcbzep;
wire                                                        ex0_is_stbepx;
wire                                                        ex0_is_sthepx;
wire                                                        ex0_is_stwepx;
wire                                                        ex0_is_stdepx;
wire                                                        ex0_is_icswepx;
wire                                                        ex0_is_larx;
wire                                                        ex0_is_stcx;
wire                                                        ex0_is_ldawx;
wire                                                        ex0_is_icswxdot;
wire                                                        ex0_cpNext_instr;
wire                                                        ex1_fxu_ld_update;
wire                                                        ex1_axu_ld_update;
wire                                                        ex1_ld_w_update;
wire                                                        ex1_fxu_st_update;
wire                                                        ex1_axu_st_update;
wire                                                        ex1_st_w_update;
wire                                                        ex1_gpr0_zero;
wire                                                        ex1_gpr0_zero_reg_op;
wire                                                        ex1_gpr0_zero_axu_op;
wire                                                        ex1_gpr0_zero_other;
wire                                                        ex5_t1_we;
wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]                  ex1_t1_wa;
wire                                                        ex1_needs_release;
wire                                                        ex1_stq3_needs_release;
wire                                                        ex1_stq3_sched_release;
wire                                                        ex0_release_vld;
wire                                                        ex0_needs_release;
wire                                                        stq2_needs_release;
wire                                                        ex1_cache_acc;
wire                                                        ex1_wclr_one_val;
wire                                                        ex1_cmd_act;
wire                                                        ex1_derat_act;
wire                                                        ex1_dir_rd_act;
wire                                                        ex1_dcm_instr;
wire                                                        ex1_is_any_load_dac;
wire                                                        ex1_is_any_store_dac;
wire                                                        ex1_resv_instr;
wire                                                        ex1_load_instr;
wire                                                        ex0_derat_is_extload;
wire                                                        ex0_derat_is_extstore;
wire                                                        ex1_th_fld_b6;
wire                                                        ex1_th_fld_c;
wire                                                        ex1_th_fld_l2;
wire [0:`ITAG_SIZE_ENC-1]                                   ex0_iss_stq2_itag;
wire [0:`THREADS-1]                                         ex0_iss_stq2_tid;
wire                                                        ex1_instr_priv;
wire                                                        ex1_instr_hypv;
wire                                                        ex1_dlk_dstor_cond0;
wire                                                        ex1_dlk_dstor_cond1;
wire                                                        ex1_dlk_dstor_cond2;
wire                                                        ex1_dlock_dstor;
wire                                                        ex1_ilock_dstor;
wire                                                        ex1_instr_ehpriv;
wire                                                        ex1_illeg_msgsnd;
wire                                                        ex1_illeg_ditc;
wire                                                        ex1_illeg_icswx;
wire                                                        ex1_illeg_instr;
wire                                                        ex1_illeg_lswi;
wire                                                        ex1_illeg_lmw;
wire                                                        ex1_priv_prog_excp;
wire                                                        ex1_hypv_prog_excp;
wire                                                        ex1_ra_eq_zero;
wire                                                        ex1_ra_eq_rt;
wire                                                        ex1_illeg_upd_form;
wire [0:7]                                                  ex1_num_bytes;
wire [0:7]                                                  ex1_num_bytes_plus3;
wire [0:5]                                                  ex1_num_regs;
wire [0:5]                                                  ex1_lower_bnd;
wire [0:5]                                                  ex1_upper_bnd;
wire [0:5]                                                  ex1_upper_bnd_wrap;
wire                                                        ex1_range_wrap;
wire                                                        ex1_ra_in_rng_lmw;
wire                                                        ex1_ra_in_rng_nowrap;
wire                                                        ex1_ra_in_rng_wrap;
wire                                                        ex1_ra_in_rng;
wire                                                        ex1_illeg_prog_excp;
wire                                                        ex1_dlock_dstor_excp;
wire                                                        ex1_ilock_dstor_excp;
wire                                                        ex1_ehpriv_excp;
wire                                                        ex1_axu_sel_target;
wire                                                        au_lq_ex0_extload;
wire                                                        au_lq_ex0_extstore;
wire                                                        au_lq_ex0_mftgpr;
wire                                                        au_lq_ex1_ldst_v;
wire                                                        au_lq_ex1_st_v;
wire [0:5]                                                  au_lq_ex1_ldst_size;
wire                                                        au_lq_ex1_ldst_update;
wire                                                        au_lq_ex1_mftgpr;
wire                                                        au_lq_ex1_mffgpr;
wire                                                        au_lq_ex1_movedp;
wire [0:AXU_TARGET_ENC-1]                                   au_lq_ex1_ldst_tag;
wire [0:15]                                                 au_lq_ex1_ldst_dimm;
wire                                                        au_lq_ex1_ldst_indexed;
wire                                                        au_lq_ex1_ldst_forcealign;
wire                                                        au_lq_ex1_ldst_forceexcept;
wire                                                        au_lq_ex1_ldst_priv;
wire [0:2]                                                  au_lq_ex1_instr_type;
wire                                                        rv1_vld;
wire                                                        rv0_hold_taken;
wire                                                        ex2_abort_sel_val;
wire                                                        lq_rel_itag0_val;
wire                                                        lq_rel_itag0_abort;
wire [0:`ITAG_SIZE_ENC-1]                                   lq_rel_itag0_itag;
wire [0:`THREADS-1]                                         lq_rel_itag0_tid;
//-------------------------------------------------------------------
// Latches
//-------------------------------------------------------------------
wire                                                        ex0_vld_q;
wire                                                        ex0_vld_d;
wire                                                        ex1_vld_q;
wire                                                        ex1_vld_d;
wire                                                        ex2_vld_q;
wire                                                        ex2_vld_d;
wire                                                        ex3_vld_q;
wire                                                        ex3_vld_d;
wire                                                        ex4_vld_q;
wire                                                        ex4_vld_d;
wire                                                        ex5_vld_q;
wire                                                        ex5_vld_d;
wire                                                        ex0_stg_act_d;
wire                                                        ex0_stg_act_q;
wire                                                        ex1_stg_act_d;
wire                                                        ex1_stg_act_q;
wire                                                        ex2_stg_act_d;
wire                                                        ex2_stg_act_q;
wire                                                        ex3_stg_act_d;
wire                                                        ex3_stg_act_q;
wire                                                        ex4_stg_act_d;
wire                                                        ex4_stg_act_q;
wire                                                        ex5_stg_act_d;
wire                                                        ex5_stg_act_q;
wire                                                        ex6_stg_act_d;
wire                                                        ex6_stg_act_q;
wire                                                        ex7_stg_act_d;
wire                                                        ex7_stg_act_q;
wire                                                        ex5_stg_act;
wire                                                        ex0_stq2_stg_act;
wire                                                        ex1_stq3_stg_act;
wire [0:31]                                                 ex1_instr_d;
wire [0:31]                                                 ex1_instr_q;
wire                                                        ex2_is_any_load_dac_d;
wire                                                        ex2_is_any_load_dac_q;
wire                                                        ex2_is_any_store_dac_d;
wire                                                        ex2_is_any_store_dac_q;
wire                                                        ex2_dir_rd_act_d;
wire                                                        ex2_dir_rd_act_q;
wire [0:`THREADS-1]                                         ex0_tid_q;
wire [0:`THREADS-1]                                         ex1_tid_q;
wire [0:`THREADS-1]                                         ex1_tid;
wire [0:`THREADS-1]                                         ex2_tid_q;
wire [0:`THREADS-1]                                         ex3_tid_q;
wire [0:`THREADS-1]                                         ex4_tid_q;
wire                                                        ex1_s1_vld_q;
wire                                                        ex1_s2_vld_q;
wire                                                        ex1_t1_we_q;
wire                                                        ex1_t1_we_d;
wire                                                        ex2_t1_we_q;
wire                                                        ex2_t1_we_d;
wire                                                        ex3_t1_we_q;
wire                                                        ex3_t1_we_d;
wire                                                        ex4_t1_we_q;
wire                                                        ex4_t1_we_d;
wire                                                        ex5_t1_we_q;
wire                                                        ex5_t1_we_d;
wire                                                        ex6_t1_we_q;
wire                                                        ex6_t1_we_d;
wire                                                        lq_xu_ex5_act_q;
wire                                                        lq_xu_ex5_act_d;
wire [0:`GPR_POOL_ENC-1]                                    ex1_t1_wa_q;
wire [0:`GPR_POOL_ENC-1]                                    ex1_t3_wa_q;
wire [0:`ITAG_SIZE_ENC-1]                                   ex1_itag_q;
wire [0:`ITAG_SIZE_ENC-1]                                   ex1_itag;
wire [0:`ITAG_SIZE_ENC-1]                                   ex2_itag_q;
wire [0:`ITAG_SIZE_ENC-1]                                   release_itag_q;
wire [0:`ITAG_SIZE_ENC-1]                                   release_itag_d;
wire                                                        release_itag_vld_q;
wire                                                        release_itag_vld_d;
wire [0:`THREADS-1]                                         release_tid_q;
wire [0:`THREADS-1]                                         release_tid_d;
wire                                                        ex0_needs_release_q;
wire                                                        ex0_needs_release_d;
wire                                                        ex1_needs_release_q;
wire                                                        ex1_needs_release_d;
wire                                                        ex2_needs_release_q;
wire                                                        ex2_needs_release_d;
wire                                                        ex2_needs_release;
wire                                                        ex1_release_attmp;
wire                                                        ex1_release_attmp_q;
wire                                                        ex1_release_attmp_d;
wire                                                        stq3_release_attmp_q;
wire                                                        stq3_release_attmp_d;
wire                                                        stq3_needs_release_q;
wire                                                        stq3_needs_release_d;
wire                                                        ex2_physical_upd_d;
wire                                                        ex2_physical_upd_q;
wire                                                        ex2_req_abort_rpt;
wire                                                        ex3_req_abort_rpt_d;
wire                                                        ex3_req_abort_rpt_q;
wire                                                        ex4_req_abort_rpt_d;
wire                                                        ex4_req_abort_rpt_q;
wire                                                        ex5_req_abort_rpt_d;
wire                                                        ex5_req_abort_rpt_q;
wire                                                        ex2_axu_physical_upd_d;
wire                                                        ex2_axu_physical_upd_q;
wire                                                        ex2_axu_abort_rpt;
wire                                                        ex3_axu_abort_rpt_d;
wire                                                        ex3_axu_abort_rpt_q;
wire                                                        ex4_axu_abort_rpt_d;
wire                                                        ex4_axu_abort_rpt_q;
wire                                                        ex5_axu_abort_rpt_d;
wire                                                        ex5_axu_abort_rpt_q;
wire [0:1]                                                  ex1_ucode_d;
wire [0:1]                                                  ex1_ucode_q;
wire [0:`UCODE_ENTRIES_ENC-1]                               ex1_ucode_cnt_d;
wire [0:`UCODE_ENTRIES_ENC-1]                               ex1_ucode_cnt_q;
wire                                                        stq1_release_vld;
wire                                                        stq2_release_vld_d;
wire                                                        stq2_release_vld_q;
wire                                                        stq3_release_vld_d;
wire                                                        stq3_release_vld_q;
wire                                                        stq4_release_vld_d;
wire                                                        stq4_release_vld_q;
wire                                                        stq5_release_vld_d;
wire                                                        stq5_release_vld_q;
wire                                                        stq6_release_vld_d;
wire                                                        stq6_release_vld_q;
wire                                                        stq7_release_vld_d;
wire                                                        stq7_release_vld_q;
wire                                                        spr_msr_gs;
wire [0:`THREADS-1]                                         spr_msr_gs_d;
wire [0:`THREADS-1]                                         spr_msr_gs_q;
wire                                                        spr_msr_pr;
wire [0:`THREADS-1]                                         spr_msr_pr_d;
wire [0:`THREADS-1]                                         spr_msr_pr_q;
wire                                                        spr_msr_ucle;
wire [0:`THREADS-1]                                         spr_msr_ucle_d;
wire [0:`THREADS-1]                                         spr_msr_ucle_q;
wire                                                        spr_msrp_uclep;
wire [0:`THREADS-1]                                         spr_msrp_uclep_d;
wire [0:`THREADS-1]                                         spr_msrp_uclep_q;
wire                                                        spr_ccr2_en_pc_d;
wire                                                        spr_ccr2_en_pc_q;
wire                                                        mm_hold_req_d;
wire                                                        mm_hold_req_q;
wire                                                        mm_hold_done_d;
wire                                                        mm_hold_done_q;
wire                                                        spr_ccr2_en_ditc_d;
wire                                                        spr_ccr2_en_ditc_q;
wire                                                        spr_ccr2_en_icswx_d;
wire                                                        spr_ccr2_en_icswx_q;
wire                                                        xu_lq_hold_req_d;
wire                                                        xu_lq_hold_req_q;
wire                                                        rv1_hold_taken_d;
wire                                                        rv1_hold_taken_q;
wire                                                        ex0_hold_taken_d;
wire                                                        ex0_hold_taken_q;
wire                                                        ex1_hold_taken_d;
wire                                                        ex1_hold_taken_q;
wire                                                        rv1_back_inv_d;
wire                                                        rv1_back_inv_q;
wire                                                        ex0_back_inv_d;
wire                                                        ex0_back_inv_q;
wire [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                      ex0_back_inv_addr_d;
wire [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                      ex0_back_inv_addr_q;
wire                                                        ex0_arr_rd_val_d;
wire                                                        ex0_arr_rd_val_q;
wire [0:5]                                                  ex0_arr_rd_congr_cl_d;
wire [0:5]                                                  ex0_arr_rd_congr_cl_q;
wire                                                        ex0_derat_snoop_val_d;
wire                                                        ex0_derat_snoop_val_q;
wire [0:51]                                                 ex0_derat_snoop_addr_d;
wire [0:51]                                                 ex0_derat_snoop_addr_q;
wire [0:63-`CL_SIZE]                                        ex0_non_back_inv_addr;
wire                                                        ex0_selimm_addr_val;
wire                                                        ex1_selimm_addr_val_d;
wire                                                        ex1_selimm_addr_val_q;
wire [0:63-`CL_SIZE]                                        ex1_selimm_addr_d;
wire [0:63-`CL_SIZE]                                        ex1_selimm_addr_q;
wire [0:`THREADS-1]                                         iu_lq_cp_flush_d;
wire [0:`THREADS-1]                                         iu_lq_cp_flush_q;
wire                                                        stq6_mftgpr_val_d;
wire                                                        stq6_mftgpr_val_q;
wire                                                        stq7_mftgpr_val_d;
wire                                                        stq7_mftgpr_val_q;
wire [0:`ITAG_SIZE_ENC-1]                                   stq2_release_itag_d;
wire [0:`ITAG_SIZE_ENC-1]                                   stq2_release_itag_q;
wire [0:`THREADS-1]                                         stq2_release_tid_d;
wire [0:`THREADS-1]                                         stq2_release_tid_q;
wire                                                        rv1_stg_flush;
wire                                                        ex0_stg_flush;
wire                                                        ex1_stg_flush;
wire                                                        ex2_stg_flush;
wire                                                        ex3_stg_flush;
wire                                                        ex4_stg_flush;
//-------------------------------------------------------------------
// Scan Chain
//-------------------------------------------------------------------
parameter                                                   spr_msr_gs_offset = 0;
parameter                                                   spr_msr_pr_offset = spr_msr_gs_offset + `THREADS;
parameter                                                   spr_msr_ucle_offset = spr_msr_pr_offset + `THREADS;
parameter                                                   spr_msrp_uclep_offset = spr_msr_ucle_offset + `THREADS;
parameter                                                   spr_ccr2_en_pc_offset = spr_msrp_uclep_offset + `THREADS;
parameter                                                   spr_ccr2_en_ditc_offset = spr_ccr2_en_pc_offset + 1;
parameter                                                   spr_ccr2_en_icswx_offset = spr_ccr2_en_ditc_offset + 1;
parameter                                                   ex0_vld_offset = spr_ccr2_en_icswx_offset + 1;
parameter                                                   ex1_vld_offset = ex0_vld_offset + 1;
parameter                                                   ex2_vld_offset = ex1_vld_offset + 1;
parameter                                                   ex3_vld_offset = ex2_vld_offset + 1;
parameter                                                   ex4_vld_offset = ex3_vld_offset + 1;
parameter                                                   ex5_vld_offset = ex4_vld_offset + 1;
parameter                                                   ex0_stg_act_offset = ex5_vld_offset + 1;
parameter                                                   ex1_stg_act_offset = ex0_stg_act_offset + 1;
parameter                                                   ex2_stg_act_offset = ex1_stg_act_offset + 1;
parameter                                                   ex3_stg_act_offset = ex2_stg_act_offset + 1;
parameter                                                   ex4_stg_act_offset = ex3_stg_act_offset + 1;
parameter                                                   ex5_stg_act_offset = ex4_stg_act_offset + 1;
parameter                                                   ex6_stg_act_offset = ex5_stg_act_offset + 1;
parameter                                                   ex7_stg_act_offset = ex6_stg_act_offset + 1;
parameter                                                   ex1_ucode_offset = ex7_stg_act_offset + 1;
parameter                                                   ex1_ucode_cnt_offset = ex1_ucode_offset + 2;
parameter                                                   ex1_instr_offset = ex1_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
parameter                                                   ex2_is_any_load_dac_offset = ex1_instr_offset + 32;
parameter                                                   ex2_is_any_store_dac_offset = ex2_is_any_load_dac_offset + 1;
parameter                                                   ex2_dir_rd_act_offset = ex2_is_any_store_dac_offset + 1;
parameter                                                   ex0_tid_offset = ex2_dir_rd_act_offset + 1;
parameter                                                   ex1_tid_offset = ex0_tid_offset + `THREADS;
parameter                                                   ex2_tid_offset = ex1_tid_offset + `THREADS;
parameter                                                   ex3_tid_offset = ex2_tid_offset + `THREADS;
parameter                                                   ex4_tid_offset = ex3_tid_offset + `THREADS;
parameter                                                   ex1_s1_vld_offset = ex4_tid_offset + `THREADS;
parameter                                                   ex1_s2_vld_offset = ex1_s1_vld_offset + 1;
parameter                                                   ex1_t1_we_offset = ex1_s2_vld_offset + 1;
parameter                                                   ex2_t1_we_offset = ex1_t1_we_offset + 1;
parameter                                                   ex3_t1_we_offset = ex2_t1_we_offset + 1;
parameter                                                   ex4_t1_we_offset = ex3_t1_we_offset + 1;
parameter                                                   ex5_t1_we_offset = ex4_t1_we_offset + 1;
parameter                                                   ex6_t1_we_offset = ex5_t1_we_offset + 1;
parameter                                                   lq_xu_ex5_act_offset = ex6_t1_we_offset + 1;
parameter                                                   ex1_t1_wa_offset = lq_xu_ex5_act_offset + 1;
parameter                                                   ex1_t3_wa_offset = ex1_t1_wa_offset + `GPR_POOL_ENC;
parameter                                                   ex1_itag_offset = ex1_t3_wa_offset + `GPR_POOL_ENC;
parameter                                                   ex2_itag_offset = ex1_itag_offset + `ITAG_SIZE_ENC;
parameter                                                   release_itag_offset = ex2_itag_offset + `ITAG_SIZE_ENC;
parameter                                                   release_tid_offset = release_itag_offset + `ITAG_SIZE_ENC;
parameter                                                   release_itag_vld_offset = release_tid_offset + `THREADS;
parameter                                                   ex0_needs_release_offset = release_itag_vld_offset + 1;
parameter                                                   ex1_needs_release_offset = ex0_needs_release_offset + 1;
parameter                                                   ex2_needs_release_offset = ex1_needs_release_offset + 1;
parameter                                                   ex2_physical_upd_offset = ex2_needs_release_offset + 1;
parameter                                                   ex3_req_abort_rpt_offset = ex2_physical_upd_offset + 1;
parameter                                                   ex4_req_abort_rpt_offset = ex3_req_abort_rpt_offset + 1;
parameter                                                   ex5_req_abort_rpt_offset = ex4_req_abort_rpt_offset + 1;
parameter                                                   ex2_axu_physical_upd_offset = ex5_req_abort_rpt_offset + 1;
parameter                                                   ex3_axu_abort_rpt_offset = ex2_axu_physical_upd_offset + 1;
parameter                                                   ex4_axu_abort_rpt_offset = ex3_axu_abort_rpt_offset + 1;
parameter                                                   ex5_axu_abort_rpt_offset = ex4_axu_abort_rpt_offset + 1;
parameter                                                   ex1_release_attmp_offset = ex5_axu_abort_rpt_offset + 1;
parameter                                                   stq3_release_attmp_offset = ex1_release_attmp_offset + 1;
parameter                                                   stq3_needs_release_offset = stq3_release_attmp_offset + 1;
parameter                                                   stq2_release_vld_offset = stq3_needs_release_offset + 1;
parameter                                                   stq3_release_vld_offset = stq2_release_vld_offset + 1;
parameter                                                   stq4_release_vld_offset = stq3_release_vld_offset + 1;
parameter                                                   stq5_release_vld_offset = stq4_release_vld_offset + 1;
parameter                                                   stq6_release_vld_offset = stq5_release_vld_offset + 1;
parameter                                                   stq7_release_vld_offset = stq6_release_vld_offset + 1;
parameter                                                   xu_lq_hold_req_offset = stq7_release_vld_offset + 1;
parameter                                                   mm_hold_req_offset = xu_lq_hold_req_offset + 1;
parameter                                                   mm_hold_done_offset = mm_hold_req_offset + 1;
parameter                                                   rv1_hold_taken_offset = mm_hold_done_offset + 1;
parameter                                                   ex0_hold_taken_offset = rv1_hold_taken_offset + 1;
parameter                                                   ex1_hold_taken_offset = ex0_hold_taken_offset + 1;
parameter                                                   rv1_back_inv_offset = ex1_hold_taken_offset + 1;
parameter                                                   ex0_back_inv_offset = rv1_back_inv_offset + 1;
parameter                                                   ex0_back_inv_addr_offset = ex0_back_inv_offset + 1;
parameter                                                   ex1_selimm_addr_val_offset = ex0_back_inv_addr_offset + (`REAL_IFAR_WIDTH-`CL_SIZE);
parameter                                                   ex1_selimm_addr_offset = ex1_selimm_addr_val_offset + 1;
parameter                                                   ex0_arr_rd_val_offset = ex1_selimm_addr_offset + (64-`CL_SIZE);
parameter                                                   ex0_arr_rd_congr_cl_offset = ex0_arr_rd_val_offset + 1;
parameter                                                   ex0_derat_snoop_val_offset = ex0_arr_rd_congr_cl_offset + 6;
parameter                                                   ex0_derat_snoop_addr_offset = ex0_derat_snoop_val_offset + 1;
parameter                                                   iu_lq_cp_flush_offset = ex0_derat_snoop_addr_offset + 52;
parameter                                                   stq6_mftgpr_val_offset = iu_lq_cp_flush_offset + `THREADS;
parameter                                                   stq7_mftgpr_val_offset = stq6_mftgpr_val_offset + 1;
parameter                                                   stq2_release_itag_offset = stq7_mftgpr_val_offset + 1;
parameter                                                   stq2_release_tid_offset = stq2_release_itag_offset + `ITAG_SIZE_ENC;
parameter                                                   scan_right = stq2_release_tid_offset + `THREADS;

wire [0:scan_right-1]                                       siv;
wire [0:scan_right-1]                                       sov;


(* analysis_not_referenced="true" *)
wire                                                        unused;

assign tiup = 1'b1;
assign tidn = 1'b0;

assign spr_msr_gs_d     = xu_lq_spr_msr_gs;
assign spr_msr_gs       = |(spr_msr_gs_q & ex1_tid_q);
assign spr_msr_pr_d     = xu_lq_spr_msr_pr;
assign spr_msr_pr       = |(spr_msr_pr_q & ex1_tid_q);
assign spr_msr_ucle_d   = xu_lq_spr_msr_ucle;
assign spr_msr_ucle     = |(spr_msr_ucle_q & ex1_tid_q);
assign spr_msrp_uclep_d = xu_lq_spr_msrp_uclep;
assign spr_msrp_uclep   = |(spr_msrp_uclep_q & ex1_tid_q);
assign spr_ccr2_en_pc_d = xu_lq_spr_ccr2_en_pc;
assign spr_ccr2_en_ditc_d = xu_lq_spr_ccr2_en_ditc;
assign spr_ccr2_en_icswx_d = xu_lq_spr_ccr2_en_icswx;
assign stq6_mftgpr_val_d = dcc_dec_stq5_mftgpr_val;
assign stq7_mftgpr_val_d = stq6_mftgpr_val_q;

// Added logic for Erat invalidates
assign xu_lq_hold_req_d       = xu_lq_hold_req;
assign mm_hold_req_d          = mm_lq_hold_req | (mm_hold_req_q & (~(mm_hold_done_q)));
assign mm_hold_done_d         = mm_lq_hold_done;
assign rv0_hold_taken         = dcc_dec_hold_all | derat_dec_hole_all | xu_lq_hold_req_q;
assign rv1_hold_taken_d       = rv0_hold_taken;
assign lq_rv_hold_all         = rv0_hold_taken;
assign ex0_hold_taken_d       = rv1_hold_taken_q;
assign ex1_hold_taken_d       = ex0_hold_taken_q;
assign rv1_back_inv_d         = lsq_ctl_rv0_back_inv;
assign ex0_back_inv_d         = rv1_back_inv_q;
assign ex0_back_inv_addr_d    = lsq_ctl_rv1_back_inv_addr;
assign ex0_arr_rd_val_d       = dcc_dec_arr_rd_rv1_val;
assign ex0_arr_rd_congr_cl_d  = dcc_dec_arr_rd_congr_cl;
assign ex0_derat_snoop_val_d  = derat_rv1_snoop_val;
assign ex0_derat_snoop_addr_d = derat_dec_rv1_snoop_addr;
assign ex0_non_back_inv_addr  = {ex0_derat_snoop_addr_q, ex0_arr_rd_congr_cl_q};
assign ex0_selimm_addr_val    = ex0_back_inv_q | ex0_arr_rd_val_q | ex0_derat_snoop_val_q;
assign ex1_selimm_addr_val_d  = ex0_selimm_addr_val;
assign ex1_selimm_addr_d[64-`REAL_IFAR_WIDTH:63-`CL_SIZE] = ex0_back_inv_q ? ex0_back_inv_addr_q : ex0_non_back_inv_addr[64-`REAL_IFAR_WIDTH:63-`CL_SIZE];
assign ex1_selimm_addr_d[0:64-`REAL_IFAR_WIDTH-1]         = ex0_non_back_inv_addr[0:64-`REAL_IFAR_WIDTH-1];
//----------------------------------------------------------------------------------------------------------------------------------------
// CP Flush of the Pipeline
//----------------------------------------------------------------------------------------------------------------------------------------
assign iu_lq_cp_flush_d = iu_lq_cp_flush;
assign rv1_stg_flush    = |(rv_lq_vld & iu_lq_cp_flush_q);
assign ex0_stg_flush    = |(ex0_tid_q & iu_lq_cp_flush_q);
assign ex1_stg_flush    = |(ex1_tid_q & iu_lq_cp_flush_q);
assign ex2_stg_flush    = |(ex2_tid_q & iu_lq_cp_flush_q) | byp_dec_ex2_req_aborted;
assign ex3_stg_flush    = |(ex3_tid_q & iu_lq_cp_flush_q);
assign ex4_stg_flush    = |(ex4_tid_q & iu_lq_cp_flush_q);
//----------------------------------------------------------------------------------------------------------------------------------------
// Valid/ACT Pipeline
//----------------------------------------------------------------------------------------------------------------------------------------
assign rv1_vld                  = |(rv_lq_vld);
assign ex0_vld_d                = rv1_vld   & ~rv1_stg_flush;
assign ex1_vld_d                = ex0_vld_q & ~ex0_stg_flush;
assign ex2_vld_d                = ex1_vld_q & ~ex1_stg_flush;
assign ex3_vld_d                = ex2_vld_q & ~ex2_stg_flush;
assign ex4_vld_d                = ex3_vld_q & ~ex3_stg_flush;
assign ex5_vld_d                = ex4_vld_q & ~ex4_stg_flush;
assign ctl_lsq_ex_pipe_full     = ex0_vld_q & ex1_vld_q & ex2_vld_q & ex3_vld_q & ex4_vld_q;

// Execution Pipe ACT Generation
assign ex0_stg_act_d       = rv1_vld;
assign ex1_stg_act_d       = ex0_stg_act_q;
assign ex2_stg_act_d       = ex1_stg_act_q | ex1_use_pfetch;
assign ex3_stg_act_d       = ex2_stg_act_q;
assign ex4_stg_act_d       = ex3_stg_act_q;
assign ex5_stg_act_d       = ex4_stg_act_q;
assign ex5_stg_act         = ex5_stg_act_q | stq7_mftgpr_val_q;
assign ex6_stg_act_d       = ex5_stg_act;
assign ex7_stg_act_d       = ex6_stg_act_q;
assign dec_byp_ex0_stg_act = ex0_stg_act_q;
assign dec_byp_ex1_stg_act = ex1_stg_act_q | ex1_selimm_addr_val_q | ex1_use_pfetch;
assign dec_byp_ex5_stg_act = ex5_stg_act;
assign dec_byp_ex6_stg_act = ex6_stg_act_q;
assign dec_byp_ex7_stg_act = ex7_stg_act_q;

// Execution Pipe and LSQ Pipe ACT Generation
assign ex0_stq2_stg_act = ex0_stg_act_q | stq2_release_vld_q;
assign ex1_stq3_stg_act = ex1_stg_act_q | stq3_release_vld_q | ex1_use_pfetch;
//----------------------------------------------------------------------------------------------------------------------------------------
// uCode Pipeline
//----------------------------------------------------------------------------------------------------------------------------------------
assign ex1_ucode_d = rv_lq_ex0_ucode;
assign ex1_ucode_cnt_d = rv_lq_ex0_ucode_cnt;
//----------------------------------------------------------------------------------------------------------------------------------------
// Target we/wa controls
//----------------------------------------------------------------------------------------------------------------------------------------
// Target 1 write enable pipe
assign ex1_t1_we_d = rv_lq_ex0_t1_v & ex1_vld_d;
assign ex2_t1_we_d = ex1_t1_we_q & ex2_vld_d & (au_lq_ex1_ldst_update | (~(ex1_load_instr | ex1_dcm_instr | ex1_is_ditc)));
assign ex3_t1_we_d = ex2_t1_we_q & ex3_vld_d;
assign ex4_t1_we_d = ex3_t1_we_q & ex4_vld_d;
assign ex5_t1_we_d = ex4_t1_we_q & ex5_vld_d;
assign ex5_t1_we   = ((ex5_t1_we_q | dcc_dec_ex5_wren) & ex5_vld_q) | stq7_mftgpr_val_q;
assign ex6_t1_we_d = ex5_t1_we;

// Target 1 controls
generate
   if (`THREADS_POOL_ENC == 0) begin : tid1
      assign ex1_t1_wa   = ex1_t1_wa_q;
      assign unused = |ex1_num_bytes_plus3[6:7] | |au_lq_ex1_ldst_dimm | byp_dec_ex1_s1_abort | byp_dec_ex1_s2_abort;
   end
endgenerate

generate
   if (`THREADS_POOL_ENC > 0) begin : tidMulti
      reg [0:`THREADS_POOL_ENC]     ex1_enc_tid;
      always @(*) begin: tidEnc
         reg [0:`THREADS_POOL_ENC-1]            encEx1;

         (* analysis_not_referenced="true" *)

         reg [0:31]                             tid;
         encEx1                                           = {`THREADS_POOL_ENC{1'b0}};
         ex1_enc_tid[`THREADS_POOL_ENC:`THREADS_POOL_ENC] = 1'b0;
         for (tid=0; tid<`THREADS; tid=tid+1) begin
            encEx1 = (tid[32-`THREADS_POOL_ENC:31] & {`THREADS_POOL_ENC{ex1_tid_q[tid]}}) | encEx1;
         end
         ex1_enc_tid[0:`THREADS_POOL_ENC - 1] <= encEx1;
      end
      assign ex1_t1_wa = {ex1_t1_wa_q, ex1_enc_tid[0:`THREADS_POOL_ENC - 1]};
      assign unused = ex1_enc_tid[`THREADS_POOL_ENC:`THREADS_POOL_ENC] | |ex1_num_bytes_plus3[6:7] | |au_lq_ex1_ldst_dimm |
                      byp_dec_ex1_s1_abort | byp_dec_ex1_s2_abort;
   end
endgenerate
assign lq_xu_ex5_act_d  = ex4_vld_q | stq6_mftgpr_val_q;
assign lq_xu_ex5_act    = lq_xu_ex5_act_q;
assign lq_xu_gpr_ex5_we = ex5_t1_we;
assign lq_rv_gpr_ex6_we = ex6_t1_we_q;

//----------------------------------------------------------------------------------------------------------------------------------------
// Dependent op release
//----------------------------------------------------------------------------------------------------------------------------------------
// LSQ Release ITAG Staging
assign stq1_release_vld   = lsq_ctl_stq_release_itag_vld;
assign stq2_release_vld_d = stq1_release_vld;
assign stq3_release_vld_d = stq2_release_vld_q;
assign stq4_release_vld_d = stq3_release_vld_q;
assign stq5_release_vld_d = stq4_release_vld_q;
assign stq6_release_vld_d = stq5_release_vld_q;
assign stq7_release_vld_d = stq6_release_vld_q;

// Mux in between LSQ Complete and EX0 Instruction,
// There shouldnt be an instruction in EX0 since HOLD_REQ
// was requested by LSQ
assign stq2_release_itag_d = lsq_ctl_stq_release_itag;
assign stq2_release_tid_d  = lsq_ctl_stq_release_tid;
assign ex0_iss_stq2_itag   = (rv_lq_ex0_itag & {`ITAG_SIZE_ENC{~stq2_release_vld_q}}) | (stq2_release_itag_q & {`ITAG_SIZE_ENC{stq2_release_vld_q}});
assign ex0_iss_stq2_tid    = (ex0_tid_q      &       {`THREADS{~stq2_release_vld_q}}) | (stq2_release_tid_q  &       {`THREADS{stq2_release_vld_q}});

// Intructions are in correct pipeline stage to allow dependent op release, and they have not been released yet
// adding ex2_needs_release to handle the case where an ABORT was reported instead of instruction in EX1_STQ3
assign ex1_stq3_sched_release  = ex1_needs_release | stq3_needs_release_q | ex1_stq3_needs_release;

// Pipeline to keep track of instructions that have not been released yet
assign ex0_cpNext_instr       = ex0_is_ldawx | ex0_is_larx | ex0_is_stcx | ex0_is_icswxdot | au_lq_ex0_mftgpr;
assign ex0_needs_release_d    = rv1_vld & ~rv1_stg_flush;
assign ex0_release_vld        = ex0_needs_release_q & ~(ex0_stg_flush | ex0_cpNext_instr);
assign ex0_needs_release      = ex0_needs_release_q & ~(ex0_stg_flush | ex0_cpNext_instr) & ex1_stq3_sched_release;
assign ex1_release_attmp_d    = ex0_release_vld & ~ex1_stq3_sched_release;
assign ex1_release_attmp      = ex1_release_attmp_q & ~ex1_stg_flush;
assign ex1_needs_release_d    = ex0_needs_release;
assign ex1_needs_release      = ex1_needs_release_q & ~ex1_stg_flush;
assign ex2_needs_release_d    = ex1_needs_release;
assign ex2_needs_release      = ex2_abort_sel_val & ~(|(ex2_tid_q & iu_lq_cp_flush_q));
assign stq2_needs_release     = stq2_release_vld_q &  ex1_stq3_sched_release;
assign stq3_release_attmp_d   = stq2_release_vld_q & ~ex1_stq3_sched_release;
assign stq3_needs_release_d   = stq2_needs_release;
assign ex1_stq3_needs_release = (stq3_release_attmp_q | ex1_needs_release | ex1_release_attmp) & ex2_needs_release;

// Use prioritized schedule to determine which stage to release itag/vld out of (Will be latched)
assign release_itag_d     = (ex0_iss_stq2_itag & {`ITAG_SIZE_ENC{~ex1_stq3_sched_release}}) | (ex1_itag_q & {`ITAG_SIZE_ENC{ex1_stq3_sched_release}});
assign release_itag_vld_d = ((ex0_release_vld | stq2_release_vld_q) & (~ex1_stq3_sched_release)) | ex1_stq3_sched_release;
assign release_tid_d      = (ex0_iss_stq2_tid  & {`THREADS{~ex1_stq3_sched_release}}) | (ex1_tid_q & {`THREADS{ex1_stq3_sched_release}});

// Abort Pipeline Request that updates a physical speculatively,
// Needs to have a separate ex2_stg_flush to remove the ex2_req_abort from the flush gen
// LARX is removed from the equation because it doesnt release
// a dependent instruction speculativevly
assign ex2_physical_upd_d     = (ex1_load_instr & ~ex1_resv_instr) | (au_lq_ex1_mffgpr & ~au_lq_ex1_movedp) | ex1_st_w_update;
assign ex2_req_abort_rpt      = byp_dec_ex2_req_aborted & ex2_vld_q & ex2_physical_upd_q;
assign ex3_req_abort_rpt_d    = ex2_req_abort_rpt   & ~(|(ex2_tid_q & iu_lq_cp_flush_q));
assign ex4_req_abort_rpt_d    = ex3_req_abort_rpt_q & ~ex3_stg_flush;
assign ex5_req_abort_rpt_d    = ex4_req_abort_rpt_q & ~ex4_stg_flush;

// Abort AXU Pipeline Request that updates an AXU physical speculatively,
// Needs to have a separate ex2_stg_flush to remove the ex2_req_abort from the flush gen
// Dont want to set if the instruction is a preIssue of an AXU instruction
assign ex2_axu_physical_upd_d = ((au_lq_ex1_ldst_v & ex1_load_instr) | (au_lq_ex1_mffgpr & ~au_lq_ex1_movedp)) & ~ex1_ucode_q[1];
assign ex2_axu_abort_rpt      = ex2_vld_q & ex2_axu_physical_upd_q;
assign ex3_axu_abort_rpt_d    = ex2_axu_abort_rpt   & ~(|(ex2_tid_q & iu_lq_cp_flush_q));
assign ex4_axu_abort_rpt_d    = ex3_axu_abort_rpt_q & ~ex3_stg_flush;
assign ex5_axu_abort_rpt_d    = ex4_axu_abort_rpt_q & ~ex4_stg_flush;

//----------------------------------------------------------------------------------------------------------------------------------------
// RV Completion
//----------------------------------------------------------------------------------------------------------------------------------------
assign ex2_abort_sel_val  = byp_dec_ex2_req_aborted & ex2_vld_q & ~ex2_needs_release_q;
assign lq_rel_itag0_val   = release_itag_vld_q |  ex2_abort_sel_val;
assign lq_rel_itag0_itag  = (release_itag_q & {`ITAG_SIZE_ENC{~ex2_abort_sel_val}}) | (ex2_itag_q & {`ITAG_SIZE_ENC{ex2_abort_sel_val}});
assign lq_rel_itag0_tid   = (release_tid_q  & {      `THREADS{~ex2_abort_sel_val}}) | (ex2_tid_q  & {      `THREADS{ex2_abort_sel_val}});
assign lq_rel_itag0_abort = byp_dec_ex2_req_aborted & ex2_vld_q;
assign lq_rv_itag0_vld    = lq_rel_itag0_tid & {`THREADS{lq_rel_itag0_val}};
assign lq_rv_itag0        = lq_rel_itag0_itag;
assign lq_rv_itag0_abort  = lq_rel_itag0_abort;

//----------------------------------------------------------------------------------------------------------------------------------------
// IU Completion
//----------------------------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------------------------
// GPR Source 0
//----------------------------------------------------------------------------------------------------------------------------------------
// Regular XU ops
assign ex1_gpr0_zero_reg_op = (~ex1_s1_vld_q);

// AXU and Not Indexed Op
assign ex1_gpr0_zero_axu_op = au_lq_ex1_ldst_v & (~(ex1_s1_vld_q | au_lq_ex1_mftgpr | au_lq_ex1_mffgpr));

// Other ops that need this zeroed
assign ex1_gpr0_zero_other  = ex1_is_msgsnd;
assign ex1_gpr0_zero        = ex1_gpr0_zero_reg_op | ex1_gpr0_zero_axu_op | ex1_gpr0_zero_other | ex1_selimm_addr_val_q | ex1_use_pfetch;
assign dec_byp_ex1_rs1_zero = ex1_gpr0_zero;

//----------------------------------------------------------------------------------------------------------------------------------------
// Immediate Logic
//----------------------------------------------------------------------------------------------------------------------------------------
// Determine what ops use immediate:
// Branches, Arith/Logical/Other Immediate forms, Loads/Stores, SPR Instructions
assign ex1_use_imm = ex1_is_lbz      | ex1_is_ld   | ex1_is_lha  | ex1_is_lhz  | ex1_is_lwa   | ex1_is_lwz  |
                     ex1_is_lhzu     | ex1_is_lhau | ex1_is_lwzu | ex1_is_lbzu | ex1_is_lmw   |
                     ex1_is_stb      | ex1_is_std  | ex1_is_sth  | ex1_is_stw  | ex1_is_stbu  | ex1_is_sthu |
                     ex1_is_stwu     | ex1_is_stdu | ex1_is_stmw | ex1_is_ldu  | ex1_is_stswi | ex1_is_lswi |
                     ex1_mtspr_trace |
                     (au_lq_ex1_ldst_v & (~(au_lq_ex1_ldst_indexed | au_lq_ex1_mftgpr | au_lq_ex1_mffgpr)));

// Determine ops that use 15 bit immediate
assign ex1_imm_size = ex1_is_lbz  | ex1_is_lbzu | ex1_is_lhz  | ex1_is_lhzu | ex1_is_lha  | ex1_is_lhau |
                      ex1_is_lwz  | ex1_is_lwzu | ex1_is_lwa  | ex1_is_ld   | ex1_is_ldu  | ex1_is_lmw  |
                      ex1_is_stb  | ex1_is_sth  | ex1_is_stw  | ex1_is_stbu | ex1_is_sthu | ex1_is_stwu |
                      ex1_is_stdu | ex1_is_std  | ex1_is_stmw |
                      (au_lq_ex1_ldst_v & (~au_lq_ex1_ldst_indexed));

// Determine ops that use sign-extended immediate
assign ex1_imm_signext = ex1_is_lbz  | ex1_is_lbzu | ex1_is_lhz  | ex1_is_lhzu | ex1_is_lha  | ex1_is_lhau |
                         ex1_is_lwz  | ex1_is_lwzu | ex1_is_lwa  | ex1_is_ld   | ex1_is_ldu  | ex1_is_lmw  |
                         ex1_is_stb  | ex1_is_sth  | ex1_is_stw  | ex1_is_stbu | ex1_is_sthu | ex1_is_stwu |
                         ex1_is_stdu | ex1_is_std  | ex1_is_stmw |
                         (au_lq_ex1_ldst_v & (~au_lq_ex1_ldst_indexed));

// Immediate should be zeroed
assign ex1_zero_imm = ex1_is_stswi | ex1_is_lswi | ex1_mtspr_trace;

// Some ops need lower two bits of immediate tied down
assign ex1_16b_imm      = ~(ex1_is_std | ex1_is_stdu | ex1_is_lwa | ex1_is_ld | ex1_is_ldu) ? ex1_instr_q[16:31] : {ex1_instr_q[16:29], {2{tidn}}};
assign ex1_64b_imm      = ex1_selimm_addr_val_q ? {ex1_selimm_addr_q, {`CL_SIZE{1'b0}}} : {{38{1'b0}}, ex1_instr_q[6:31]};
assign ex1_imm_sign_ext = ({(ex1_imm_size & (~ex1_selimm_addr_val_q)), ex1_imm_signext} == 2'b11) ? {{48{ex1_16b_imm[0]}}, ex1_16b_imm} :
                          ({(ex1_imm_size & (~ex1_selimm_addr_val_q)), ex1_imm_signext} == 2'b10) ? {{48{          1'b0}}, ex1_16b_imm} :
                          ex1_64b_imm;
// prefetch
// removed mm_hold_req_q because it would lead to a deadlock
// the pfetch will not be quiesced because we block all pfetches
// while the mmu requests a hold, but the mmu waits for quiesce
// before executing
assign ex1_pfetch_rel_collision = dir_dec_rel3_dir_wr_val & (dir_dec_rel3_dir_wr_addr == pf_dec_req_addr[64-(`DC_SIZE-3):63-`CL_SIZE]);
assign ex1_use_pfetch  = pf_dec_req_val & ~ex1_vld_q & ~ex1_selimm_addr_val_q & ~lsq_ctl_sync_in_stq & ~ex1_hold_taken_q & ~ex1_pfetch_rel_collision & ~dcc_dec_stq3_mftgpr_val;
assign dec_pf_ack      = ex1_use_pfetch;

assign dec_byp_ex1_imm     = ~ex1_use_pfetch ? (ex1_imm_sign_ext[64-(2**`GPR_WIDTH_ENC):63] & {2**`GPR_WIDTH_ENC{~ex1_zero_imm}}) :
                             {pf_dec_req_addr, {`CL_SIZE{1'b0}}};
assign dec_byp_ex1_use_imm = ex1_use_imm | ex1_selimm_addr_val_q | ex1_use_pfetch;
assign dec_byp_ex1_s1_vld  = ex1_s1_vld_q & ex1_vld_q;
assign dec_byp_ex1_s2_vld  = ex1_s2_vld_q & ex1_vld_q;
assign ex1_tid             = ~ex1_use_pfetch ? ex1_tid_q : pf_dec_req_thrd;
//-------------------------------------------------------------------
// DITC Control Logic
//-------------------------------------------------------------------
//-------------------------------------------------------------------
// LSU Control Logic
//-------------------------------------------------------------------
assign ex1_priv_prog_excp       = ex1_instr_priv & ex1_vld_q & spr_msr_pr;
assign ex1_hypv_prog_excp       = ex1_instr_hypv & ex1_vld_q & (spr_msr_pr | spr_msr_gs);
assign ex1_illeg_prog_excp      = ex1_vld_q & ex1_illeg_instr;
assign ex1_dlock_dstor_excp     = ex1_vld_q & ex1_dlock_dstor;
assign ex1_ilock_dstor_excp     = ex1_vld_q & ex1_ilock_dstor;
assign ex1_ehpriv_excp          = ex1_vld_q & ex1_instr_ehpriv;
assign dec_spr_ex1_valid        = ex1_tid_q & {`THREADS{ex1_vld_q}};
assign dec_dcc_ex1_expt_det     = ex1_priv_prog_excp | ex1_hypv_prog_excp | ex1_illeg_prog_excp | ex1_dlock_dstor_excp | ex1_ilock_dstor_excp | ex1_ehpriv_excp;
assign dec_dcc_ex1_priv_prog    = ex1_priv_prog_excp;
assign dec_dcc_ex1_hypv_prog    = ex1_hypv_prog_excp;
assign dec_dcc_ex1_illeg_prog   = ex1_illeg_prog_excp;
assign dec_dcc_ex1_dlock_excp   = ex1_dlock_dstor_excp;
assign dec_dcc_ex1_ilock_excp   = ex1_ilock_dstor_excp;
assign dec_dcc_ex1_ehpriv_excp  = ex1_ehpriv_excp;
assign dec_dcc_ex1_ucode_val    = ex1_vld_q & ex1_ucode_q[1];
assign dec_dcc_ex1_ucode_cnt    = ex1_ucode_cnt_q;
assign dec_dcc_ex1_ucode_op     = ex1_ucode_q[0];
assign dec_dcc_ex1_sfx_val      = ex1_vld_q & (~(ex1_cache_acc | ex1_ucode_q[1]));
assign dec_dcc_ex1_cache_acc    = ex1_cache_acc & (~(ex1_ucode_q[1] | ex1_illeg_icswx));
assign dec_dcc_ex1_thrd_id      = ex1_tid;
assign dec_dcc_ex1_instr        = ex1_instr_q;

assign ex1_axu_sel_target       = (au_lq_ex1_ldst_v | au_lq_ex1_mffgpr) & (~(au_lq_ex1_mftgpr | ex1_axu_st_update));
assign dec_dcc_ex1_target_gpr[AXU_TARGET_ENC-(`GPR_POOL_ENC+`THREADS_POOL_ENC):AXU_TARGET_ENC-1] = ex1_axu_sel_target ? au_lq_ex1_ldst_tag[AXU_TARGET_ENC-(`GPR_POOL_ENC+`THREADS_POOL_ENC):AXU_TARGET_ENC-1] : ex1_t1_wa;

generate
   if (`AXU_SPARE_ENC > 0) begin : axuSpare
      assign dec_dcc_ex1_target_gpr[0:AXU_TARGET_ENC-(`GPR_POOL_ENC+`THREADS_POOL_ENC)-1] = au_lq_ex1_ldst_tag[0:AXU_TARGET_ENC-(`GPR_POOL_ENC+`THREADS_POOL_ENC)-1];
   end
endgenerate

assign dec_dcc_ex1_cmd_act          = ex1_cmd_act | (ex1_vld_q & ex1_ucode_q[1]) | ex1_use_pfetch | ex1_selimm_addr_val_q;
assign dec_dcc_ex1_upd_form         = (au_lq_ex1_ldst_v & au_lq_ex1_ldst_update) | ((~au_lq_ex1_ldst_v) & ex1_fxu_st_update);
assign dec_dcc_ex1_mtspr_trace      = ex1_mtspr_trace;
assign dec_dcc_ex1_is_msgsnd        = ex1_is_msgsnd & spr_ccr2_en_pc_q;
assign dec_dcc_ex1_load_instr       = ex1_load_instr;
assign dec_dcc_ex1_dcbf_instr       = (ex1_is_dcbf | ex1_is_dcbfep);
assign dec_dcc_ex1_l_fld            = ex1_instr_q[9:10];
assign dec_dcc_ex1_dcbi_instr       = ex1_is_dcbi;
assign dec_dcc_ex1_dcbz_instr       = (ex1_is_dcbz | ex1_is_dcbzep);
assign dec_dcc_ex1_dcbt_instr       = (ex1_is_dcbt | ex1_is_dcbtep);
assign dec_dcc_ex1_pfetch_val       = ex1_use_pfetch;
assign dec_dcc_ex1_dcbtst_instr     = (ex1_is_dcbtst | ex1_is_dcbtstep);
assign dec_dcc_ex1_th_fld           = ~ex1_use_pfetch ? {ex1_th_fld_b6, ex1_instr_q[7:10]} : 5'b00000;
assign dec_dcc_ex1_dcbtls_instr     = ex1_is_dcbtls;
assign dec_dcc_ex1_dcbtstls_instr   = ex1_is_dcbtstls;
assign dec_dcc_ex1_dcblc_instr      = ex1_is_dcblc;
assign dec_dcc_ex1_dci_instr        = ex1_is_dci & ex1_vld_q;
assign dec_dcc_ex1_dcbst_instr      = (ex1_is_dcbst | ex1_is_dcbstep);
assign dec_dcc_ex1_icbi_instr       = (ex1_is_icbi | ex1_is_icbiep);
assign dec_dcc_ex1_ici_instr        = ex1_is_ici & ex1_vld_q;
assign dec_dcc_ex1_icblc_instr      = ex1_is_icblc;
assign dec_dcc_ex1_icbt_instr       = ex1_is_icbt;
assign dec_dcc_ex1_icbtls_instr     = ex1_is_icbtls;
assign dec_dcc_ex1_resv_instr       = ex1_resv_instr;
assign dec_dcc_ex1_cr_fld           = ex1_t3_wa_q[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1];
assign dec_dcc_ex1_mutex_hint       = ex1_instr_q[31];
assign dec_dcc_ex1_axu_op_val       = au_lq_ex1_ldst_v;
assign dec_dcc_ex1_axu_falign       = au_lq_ex1_ldst_forcealign;
assign dec_dcc_ex1_axu_fexcpt       = au_lq_ex1_ldst_forceexcept;
assign dec_dcc_ex1_axu_instr_type   = au_lq_ex1_instr_type;
assign dec_derat_ex1_byte_rev       = ex1_is_lhbrx | ex1_is_lwbrx | ex1_is_ldbrx | ex1_is_sthbrx | ex1_is_stwbrx | ex1_is_stdbrx;
assign dec_derat_ex1_ra_eq_ea       = ex1_selimm_addr_val_q | ex1_is_msgsnd | ex1_mtspr_trace;
assign dec_derat_ex1_derat_act      = ex1_derat_act | (ex1_vld_q & ex1_ucode_q[1]) | ex1_wclr_one_val | ex1_use_pfetch;
assign dec_derat_ex1_pfetch_val     = ex1_tid & {`THREADS{ex1_use_pfetch}};
assign dec_dcc_ex5_req_abort_rpt    = ex5_req_abort_rpt_q;
assign dec_dcc_ex5_axu_abort_rpt    = ex5_axu_abort_rpt_q;

assign dec_dir_ex2_dir_rd_act       = ex2_dir_rd_act_q;
assign ex0_derat_is_extload         = ex0_is_lbepx | ex0_is_lhepx | ex0_is_lwepx | ex0_is_ldepx | ex0_is_dcbfep | ex0_is_dcbtep | ex0_is_dcbstep | ex0_is_icbiep | au_lq_ex0_extload;
assign dec_derat_ex0_is_extload     = ex0_derat_is_extload;
assign dec_derat_ex0_val            = ex0_tid_q & {`THREADS{ex0_vld_q}};
assign ex0_derat_is_extstore        = ex0_is_dcbzep | ex0_is_stbepx | ex0_is_sthepx | ex0_is_stwepx | ex0_is_stdepx | ex0_is_dcbtstep | ex0_is_icswepx | au_lq_ex0_extstore;
assign dec_derat_ex0_is_extstore    = ex0_derat_is_extstore;

assign ex1_th_fld_b6                = ex1_instr_q[6] & (ex1_is_dcbt | ex1_is_dcbtep | ex1_is_dcbtst | ex1_is_dcbtstep);
assign ex1_th_fld_c                 = ~ex1_th_fld_b6 & (ex1_instr_q[7:10] == 4'b0000);
assign ex1_th_fld_l2                = ~ex1_th_fld_b6 & (ex1_instr_q[7:10] == 4'b0010);
assign dec_derat_ex1_is_touch       = ex1_is_dcbt | ex1_is_dcbtep | ex1_is_dcbtst | ex1_is_dcbtstep | ex1_is_icbt |
                                      ((ex1_is_dcbtls | ex1_is_dcbtstls | ex1_is_dcblc) & (~(ex1_th_fld_c | ex1_th_fld_l2))) |
                                      ((ex1_is_icbtls | ex1_is_icblc)                   & (~(ex1_th_fld_c | ex1_th_fld_l2)));

assign dec_dcc_ex1_mword_instr      = ex1_is_lmw | ex1_is_stmw;
assign dec_dcc_ex1_icswx_instr      = ex1_is_icswx | ex1_is_icswepx;
assign dec_dcc_ex1_icswxdot_instr   = (ex1_is_icswx | ex1_is_icswepx) & ex1_instr_q[31];
assign dec_dcc_ex1_icswx_epid       = ex1_is_icswepx;
assign dec_dcc_ex1_itag             = ex1_itag;
assign dec_dcc_ex2_rotsel_ovrd      = au_lq_ex1_ldst_size[1:5];
assign dec_dcc_ex3_mtdp_val         = tidn;
assign dec_dcc_ex3_mfdp_val         = tidn;
assign dec_dcc_ex3_ipc_ba           = {5{1'b0}};
assign dec_dcc_ex3_ipc_sz           = {2{1'b0}};

assign ex1_itag = ex1_use_pfetch ? 7'b0111111 : ex1_itag_q;

assign ex2_is_any_load_dac_d    = ex1_is_any_load_dac;
assign ex2_is_any_store_dac_d   = ex1_is_any_store_dac;
assign dec_ex2_is_any_load_dac  = ex2_is_any_load_dac_q;
assign dec_ex2_is_any_store_dac = ex2_is_any_store_dac_q;
assign ex2_dir_rd_act_d         = ex1_dir_rd_act | ex1_use_pfetch | ex1_selimm_addr_val_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Instruction Decode
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign ex1_instr_d = ex1_vld_d ? rv_lq_ex0_instr : 32'h7C00022C;

//----------------------------------------------------------------------------------------------------------------------------------------
// AXU Load/Store Instruction Decode
//----------------------------------------------------------------------------------------------------------------------------------------

lq_axu_dec axu(
   .lq_au_ex0_instr(rv_lq_ex0_instr),
   .lq_au_ex1_vld(ex1_vld_q),
   .lq_au_ex1_tid(ex1_tid_q),
   .lq_au_ex1_instr(ex1_instr_q),
   .lq_au_ex1_t3_p(ex1_t3_wa_q),
   .au_lq_ex0_extload(au_lq_ex0_extload),
   .au_lq_ex0_extstore(au_lq_ex0_extstore),
   .au_lq_ex0_mftgpr(au_lq_ex0_mftgpr),
   .au_lq_ex1_ldst_v(au_lq_ex1_ldst_v),
   .au_lq_ex1_st_v(au_lq_ex1_st_v),
   .au_lq_ex1_ldst_size(au_lq_ex1_ldst_size),
   .au_lq_ex1_ldst_update(au_lq_ex1_ldst_update),
   .au_lq_ex1_mftgpr(au_lq_ex1_mftgpr),
   .au_lq_ex1_mffgpr(au_lq_ex1_mffgpr),
   .au_lq_ex1_movedp(au_lq_ex1_movedp),
   .au_lq_ex1_ldst_tag(au_lq_ex1_ldst_tag),
   .au_lq_ex1_ldst_dimm(au_lq_ex1_ldst_dimm),
   .au_lq_ex1_ldst_indexed(au_lq_ex1_ldst_indexed),
   .au_lq_ex1_ldst_forcealign(au_lq_ex1_ldst_forcealign),
   .au_lq_ex1_ldst_forceexcept(au_lq_ex1_ldst_forceexcept),
   .au_lq_ex1_ldst_priv(au_lq_ex1_ldst_priv),
   .au_lq_ex1_instr_type(au_lq_ex1_instr_type)
);

//----------------------------------------------------------------------------------------------------------------------------------------
// Illegal ops
//----------------------------------------------------------------------------------------------------------------------------------------
assign ex1_instr_priv       = ex1_is_dcbfep | ex1_is_dcbi    | ex1_is_dcbstep | ex1_is_dcbtep | ex1_is_dcbtstep | ex1_is_dcbzep | ex1_is_dci    | ex1_is_icbiep  |
                              ex1_is_ici    | ex1_is_icswepx | ex1_is_lbepx   | ex1_is_ldepx  | ex1_is_lhepx    | ex1_is_lwepx  | ex1_is_mfdp   | ex1_is_mfdpx   |
                              ex1_is_msgsnd | ex1_is_mtdp    | ex1_is_mtdpx   | ex1_is_stbepx | ex1_is_stdepx   | ex1_is_sthepx | ex1_is_stwepx | ex1_is_tlbsync | au_lq_ex1_ldst_priv;
assign ex1_instr_hypv       = ex1_is_msgsnd | ex1_is_tlbsync;
assign ex1_dlk_dstor_cond0  = spr_msrp_uclep & spr_msr_gs & spr_msr_pr;
assign ex1_dlk_dstor_cond1  = (~spr_msr_ucle) & (~spr_msrp_uclep) & spr_msr_pr;
assign ex1_dlk_dstor_cond2  = (~spr_msr_ucle) & (~spr_msr_gs) & spr_msr_pr;
assign ex1_dlock_dstor      = (ex1_is_dcbtls | ex1_is_dcbtstls | ex1_is_dcblc) & (ex1_dlk_dstor_cond0 | ex1_dlk_dstor_cond1 | ex1_dlk_dstor_cond2);
assign ex1_ilock_dstor      = (ex1_is_icbtls | ex1_is_icblc)                   & (ex1_dlk_dstor_cond0 | ex1_dlk_dstor_cond1 | ex1_dlk_dstor_cond2);
assign ex1_instr_ehpriv     = (ex1_is_dcbtls | ex1_is_dcbtstls | ex1_is_dcblc | ex1_is_icbtls | ex1_is_icblc) & spr_msrp_uclep & spr_msr_gs & (~spr_msr_pr);
assign ex1_illeg_msgsnd     = ex1_is_msgsnd & (~spr_ccr2_en_pc_q);
assign ex1_illeg_ditc       = ex1_is_ditc & (~spr_ccr2_en_ditc_q);
assign ex1_illeg_icswx      = (ex1_is_icswx | ex1_is_icswepx) & (~spr_ccr2_en_icswx_q);
assign ex1_illeg_instr      = ex1_illeg_msgsnd | ex1_illeg_ditc | ex1_illeg_icswx | ex1_illeg_lswi | ex1_illeg_lmw | ex1_illeg_upd_form;

// Load/Store Update Form Instruction Decode
// Load with Update Valid
assign ex1_fxu_ld_update = ex1_is_lbzu | ex1_is_lbzux | ex1_is_ldu | ex1_is_ldux | ex1_is_lhau | ex1_is_lhaux |
                           ex1_is_lhzu | ex1_is_lhzux | ex1_is_lwaux | ex1_is_lwzu | ex1_is_lwzux;
assign ex1_axu_ld_update = (~au_lq_ex1_st_v) & au_lq_ex1_ldst_update;
assign ex1_ld_w_update   = au_lq_ex1_ldst_v ? ex1_axu_ld_update : ex1_fxu_ld_update;

// Store with Update Valid
assign ex1_fxu_st_update  = ex1_is_stbu | ex1_is_stbux | ex1_is_stdu | ex1_is_stdux | ex1_is_sthu | ex1_is_sthux |
                            ex1_is_stwu | ex1_is_stwux;
assign ex1_axu_st_update  = au_lq_ex1_st_v & au_lq_ex1_ldst_update;
assign ex1_st_w_update    = au_lq_ex1_ldst_v ? ex1_axu_st_update : ex1_fxu_st_update;
assign ex1_ra_eq_zero     = (ex1_instr_q[11:15] == 5'b00000);
assign ex1_ra_eq_rt       = (ex1_instr_q[11:15] == ex1_instr_q[6:10]) & (~au_lq_ex1_ldst_v);
assign ex1_illeg_upd_form = (ex1_ld_w_update & (ex1_ra_eq_zero | ex1_ra_eq_rt)) | (ex1_st_w_update & ex1_ra_eq_zero);

// Illegal forms of LSWI and LMW
assign ex1_num_bytes        = {2'b00, (~(|ex1_instr_q[16:20])), ex1_instr_q[16:20]};
assign ex1_num_bytes_plus3  = ex1_num_bytes + 8'b00000011;
assign ex1_num_regs         = ex1_num_bytes_plus3[0:5];
assign ex1_lower_bnd        = {1'b0, ex1_instr_q[6:10]};
assign ex1_upper_bnd        = ex1_lower_bnd + ex1_num_regs;
assign ex1_upper_bnd_wrap   = {1'b0, ex1_upper_bnd[1:5]};
assign ex1_range_wrap       = ex1_upper_bnd[0];
assign ex1_ra_in_rng_lmw    = ({1'b0, ex1_instr_q[11:15]}) >= ex1_lower_bnd;

// RA in range
assign ex1_ra_in_rng_nowrap = (({1'b0, ex1_instr_q[11:15]}) >= ex1_lower_bnd) &
                              (({1'b0, ex1_instr_q[11:15]}) <  ex1_upper_bnd);
assign ex1_ra_in_rng_wrap   = (({1'b0, ex1_instr_q[11:15]}) <  ex1_upper_bnd_wrap);
assign ex1_ra_in_rng        = (ex1_ra_in_rng_nowrap) | (ex1_ra_in_rng_wrap & ex1_range_wrap);
assign ex1_illeg_lswi       = ex1_is_lswi & ex1_ra_in_rng;
assign ex1_illeg_lmw        = ex1_is_lmw & ex1_ra_in_rng_lmw;

//----------------------------------------------------------------------------------------------------------------------------------------
// FXU Instruction Decode
//----------------------------------------------------------------------------------------------------------------------------------------
//
// Final Table Listing
//      *INPUTS*==================================================*OUTPUTS*============================================*
//      |                                                         |                                                    |
//      | ex1_instr_q                                             | ex1_cache_acc                                      |
//      | |      ex1_instr_q                                      | | ex1_is_msgsnd                                    |
//      | |      |          ex1_instr_q                           | | | dec_dcc_ex1_mbar_instr                         |
//      | |      |          |          ex1_instr_q                | | | | dec_dcc_ex1_sync_instr                       |
//      | |      |          |          |  au_lq_ex1_ldst_v        | | | | | dec_dcc_ex1_makeitso_instr                 |
//      | |      |          |          |  | au_lq_ex1_mftgpr      | | | | | | dec_dcc_ex1_tlbsync_instr                |
//      | |      |          |          |  | | au_lq_ex1_mffgpr    | | | | | | | dec_dcc_ex1_wclr_instr                 |
//      | |      |          |          |  | | | au_lq_ex1_movedp  | | | | | | | | dec_dcc_ex1_wchk_instr               |
//      | |      |          |          |  | | | | ex1_vld_q       | | | | | | | | | dec_dcc_ex1_src_gpr                |
//      | |      |          |          |  | | | | |               | | | | | | | | | | dec_dcc_ex1_src_axu              |
//      | |      |          |          |  | | | | |               | | | | | | | | | | | dec_dcc_ex1_src_dp             |
//      | |      |          |          |  | | | | |               | | | | | | | | | | | | dec_dcc_ex1_targ_gpr         |
//      | |      |          |          |  | | | | |               | | | | | | | | | | | | | dec_dcc_ex1_targ_axu       |
//      | |      |          |          |  | | | | |               | | | | | | | | | | | | | | dec_dcc_ex1_targ_dp      |
//      | |      |          |          |  | | | | |               | | | | | | | | | | | | | | | ex1_cmd_act            |
//      | |      |          |          |  | | | | |               | | | | | | | | | | | | | | | | ctl_dat_ex1_data_act |
//      | |      |          |          |  | | | | |               | | | | | | | | | | | | | | | | | ex1_mtspr_trace    |
//      | |      |          |          |  | | | | |               | | | | | | | | | | | | | | | | | | ex1_derat_act    |
//      | |      |          |          |  | | | | |               | | | | | | | | | | | | | | | | | | | ex1_dir_rd_act |
//      | |      |          |          |  | | | | |               | | | | | | | | | | | | | | | | | | | |              |
//      | |      |          |          |  | | | | |               | | | | | | | | | | | | | | | | | | | |              |
//      | 000000 1111111112 2222222223 33 | | | | |               | | | | | | | | | | | | | | | | | | | |              |
//      | 012345 1234567890 1234567890 01 | | | | |               | | | | | | | | | | | | | | | | | | | |              |
//      *TYPE*====================================================+====================================================+
//      | PPPPPP PPPPPPPPPP PPPPPPPPPP PP P P P P P               | P P P P P P P P P P P P P P P P P P P              |
//      *POLARITY*----------------------------------------------->| + + + + + + + + + + + + + + + + + + +              |
//      *PHASE*-------------------------------------------------->| T T T T T T T T T T T T T T T T T T T              |
//      *TERMS*===================================================+====================================================+
//    1 | 011111 0111011111 0111010011 -- - - - - 1               | . . . . . . . . . . . . . . 1 . 1 . .              |
//    2 | 011111 ---------- 0000-00011 -- - - - 0 1               | . . . . . . . . . . . 1 . . . . . . .              |
//    3 | 011111 ---------- 1110000110 -- - - - - 1               | . . . . . . . 1 . . . . . . . . . . .              |
//    4 | 011111 ---------- 0011111111 -- - - - - 1               | . . . . . . . . . . . . . . . . . . 1              |
//    5 | 011111 ---------- 0011001110 -- - - - - 1               | . 1 . . . . . . . . . . . . 1 . . . .              |
//    6 | 011111 ---------- 0000110010 -- - - - - 1               | . . . . 1 . . . . . . . . . 1 . . . .              |
//    7 | 011111 ---------- 1101010110 -- - - - - 1               | . . 1 . . . . . . . . . . . 1 . . . .              |
//    8 | 011111 ---------- 1110100110 -- - - - - 1               | 1 . . . . . 1 . . . . . . . 1 . . . .              |
//    9 | 011111 ---------- 1000110110 -- - - - - 1               | . . . . . 1 . . . . . . . . 1 . . . .              |
//   10 | 011111 ---------- 1001010110 -- - - - - 1               | . . . 1 . . . . . . . . . . 1 . . . .              |
//   11 | 011111 ---------- 0001-00011 -- - - - - 1               | . . . . . . . . 1 . . . . 1 1 1 . . .              |
//   12 | 011111 ---------- 0000-00011 -- - - - - 1               | . . . . . . . . . . 1 . . . 1 1 . . .              |
//   13 | 011111 ---------- 10000101-0 -- - - - - 1               | . . . . . . . . . . . . . . . 1 . . 1              |
//   14 | 011111 ---------- 0-0001-111 -- - - - - 1               | . . . . . . . . . . . . . . . 1 . . .              |
//   15 | 011111 ---------- 000001-1-1 -- - - - - 1               | . . . . . . . . . . . . . . . 1 . . 1              |
//   16 | 011111 ---------- 1111-11111 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   17 | 011111 ---------- 000-01-111 -- - - - - 1               | . . . . . . . . . . . . . . . 1 . . 1              |
//   18 | 011111 ---------- 0-11100110 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   19 | 011111 ---------- 0011110110 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 1              |
//   20 | 011111 ---------- -11-0-0110 -- - - - - 1               | . . . . . . . . . . . . . . 1 . . . .              |
//   21 | 011111 ---------- 0-100-0110 -- - - - - 1               | 1 . . . . . . . . . . . . . . . . 1 .              |
//   22 | 011111 ---------- 0100-11111 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 1              |
//   23 | 011111 ---------- 0010-00110 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 1              |
//   24 | 011111 ---------- 00-1010100 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 1 . 1 1              |
//   25 | 011111 ---------- 01010101-1 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 1 . 1 1              |
//   26 | 011111 ---------- 111--10110 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   27 | 011111 ---------- 000--11111 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   28 | 011111 ---------- 010001011- -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 1              |
//   29 | 011111 ---------- 10-00101-0 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   30 | 011111 ---------- 0011-1-111 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   31 | 011111 ---------- 1-00010110 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 1 . 1 1              |
//   32 | 011111 ---------- 1-10-10110 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   33 | 011111 ---------- 0010-101-1 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   34 | 011111 ---------- 0000-101-0 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   35 | 011111 ---------- 0-10-10111 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   36 | 011111 ---------- 000--10100 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 1 . 1 1              |
//   37 | 011111 ---------- 00-001-1-1 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   38 | 011111 ---------- 0--001-111 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   39 | 011111 ---------- --1-010110 -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   40 | 011111 ---------- 00--01011- -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   41 | 1-1010 ---------- ---------- -0 - - - - 1               | 1 . . . . . . . . . . . . . 1 1 . 1 1              |
//   42 | 111110 ---------- ---------- 0- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   43 | ------ ---------- ---------- -- 1 0 0 0 1               | 1 . . . . . . . . . . . . . 1 1 . 1 1              |
//   44 | 10-0-0 ---------- ---------- -- - - - - 1               | 1 . . . . . . . . . . . . . 1 1 . 1 1              |
//   45 | ------ ---------- ---------- -- - - 1 1 1               | . . . . . . . . . . 1 . 1 . 1 . . . .              |
//   46 | ------ ---------- ---------- -- - 1 - 1 1               | . . . . . . . . . 1 . . . 1 1 . . . .              |
//   47 | ------ ---------- ---------- -- - 1 - 0 1               | . . . . . . . . . 1 . 1 . . 1 . . . .              |
//   48 | ------ ---------- ---------- -- - - 1 0 1               | . . . . . . . . 1 . . . 1 . 1 . . . .              |
//   49 | 10-10- ---------- ---------- -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//   50 | 1001-- ---------- ---------- -- - - - - 1               | 1 . . . . . . . . . . . . . 1 . . 1 .              |
//      *==============================================================================================================*
//
// Table TBL_VAL_STG_GATE Signal Assignments for Product Terms
assign TBL_VAL_STG_GATE_PT[1]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[11],
                                   ex1_instr_q[12], ex1_instr_q[13], ex1_instr_q[14], ex1_instr_q[15], ex1_instr_q[16], ex1_instr_q[17], ex1_instr_q[18],
                                   ex1_instr_q[19], ex1_instr_q[20], ex1_instr_q[21], ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25],
                                   ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29], ex1_instr_q[30], ex1_vld_q}) == 27'b011111011101111101110100111;
assign TBL_VAL_STG_GATE_PT[2]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                   ex1_instr_q[30], au_lq_ex1_movedp, ex1_vld_q}) == 17'b01111100000001101;
assign TBL_VAL_STG_GATE_PT[3]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                   ex1_instr_q[29], ex1_instr_q[30], ex1_vld_q}) == 17'b01111111100001101;
assign TBL_VAL_STG_GATE_PT[4]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                   ex1_instr_q[29], ex1_instr_q[30], ex1_vld_q}) == 17'b01111100111111111;
assign TBL_VAL_STG_GATE_PT[5]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                   ex1_instr_q[29], ex1_instr_q[30], ex1_vld_q}) == 17'b01111100110011101;
assign TBL_VAL_STG_GATE_PT[6]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                   ex1_instr_q[29], ex1_instr_q[30], ex1_vld_q}) == 17'b01111100001100101;
assign TBL_VAL_STG_GATE_PT[7]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                   ex1_instr_q[29], ex1_instr_q[30], ex1_vld_q}) == 17'b01111111010101101;
assign TBL_VAL_STG_GATE_PT[8]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                   ex1_instr_q[29], ex1_instr_q[30], ex1_vld_q}) == 17'b01111111101001101;
assign TBL_VAL_STG_GATE_PT[9]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                   ex1_instr_q[29], ex1_instr_q[30], ex1_vld_q}) == 17'b01111110001101101;
assign TBL_VAL_STG_GATE_PT[10] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                   ex1_instr_q[29], ex1_instr_q[30], ex1_vld_q}) == 17'b01111110010101101;
assign TBL_VAL_STG_GATE_PT[11] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                   ex1_instr_q[30], ex1_vld_q}) == 16'b0111110001000111;
assign TBL_VAL_STG_GATE_PT[12] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                   ex1_instr_q[30], ex1_vld_q}) == 16'b0111110000000111;
assign TBL_VAL_STG_GATE_PT[13] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                   ex1_instr_q[30], ex1_vld_q}) == 16'b0111111000010101;
assign TBL_VAL_STG_GATE_PT[14] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[28], ex1_instr_q[29], ex1_instr_q[30],
                                   ex1_vld_q}) == 15'b011111000011111;
assign TBL_VAL_STG_GATE_PT[15] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[28], ex1_instr_q[30],
                                   ex1_vld_q}) == 15'b011111000001111;
assign TBL_VAL_STG_GATE_PT[16] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                   ex1_instr_q[30], ex1_vld_q}) == 16'b0111111111111111;
assign TBL_VAL_STG_GATE_PT[17] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[28], ex1_instr_q[29], ex1_instr_q[30],
                                   ex1_vld_q}) == 15'b011111000011111;
assign TBL_VAL_STG_GATE_PT[18] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                   ex1_instr_q[30], ex1_vld_q}) == 16'b0111110111001101;
assign TBL_VAL_STG_GATE_PT[19] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                   ex1_instr_q[29], ex1_instr_q[30], ex1_vld_q}) == 17'b01111100111101101;
assign TBL_VAL_STG_GATE_PT[20] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[22],
                                   ex1_instr_q[23], ex1_instr_q[25], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29], ex1_instr_q[30],
                                   ex1_vld_q}) == 14'b01111111001101;
assign TBL_VAL_STG_GATE_PT[21] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29], ex1_instr_q[30],
                                   ex1_vld_q}) == 15'b011111010001101;
assign TBL_VAL_STG_GATE_PT[22] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                   ex1_instr_q[30], ex1_vld_q}) == 16'b0111110100111111;
assign TBL_VAL_STG_GATE_PT[23] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                   ex1_instr_q[30], ex1_vld_q}) == 16'b0111110010001101;
assign TBL_VAL_STG_GATE_PT[24] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                   ex1_instr_q[30], ex1_vld_q}) == 16'b0111110010101001;
assign TBL_VAL_STG_GATE_PT[25] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                   ex1_instr_q[30], ex1_vld_q}) == 16'b0111110101010111;
assign TBL_VAL_STG_GATE_PT[26] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29], ex1_instr_q[30],
                                   ex1_vld_q}) == 15'b011111111101101;
assign TBL_VAL_STG_GATE_PT[27] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29], ex1_instr_q[30],
                                   ex1_vld_q}) == 15'b011111000111111;
assign TBL_VAL_STG_GATE_PT[28] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                   ex1_instr_q[29], ex1_vld_q}) == 16'b0111110100010111;
assign TBL_VAL_STG_GATE_PT[29] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[30],
                                   ex1_vld_q}) == 15'b011111100010101;
assign TBL_VAL_STG_GATE_PT[30] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[28], ex1_instr_q[29], ex1_instr_q[30],
                                   ex1_vld_q}) == 15'b011111001111111;
assign TBL_VAL_STG_GATE_PT[31] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                   ex1_instr_q[30], ex1_vld_q}) == 16'b0111111000101101;
assign TBL_VAL_STG_GATE_PT[32] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29], ex1_instr_q[30],
                                   ex1_vld_q}) == 15'b011111110101101;
assign TBL_VAL_STG_GATE_PT[33] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[30],
                                   ex1_vld_q}) == 15'b011111001010111;
assign TBL_VAL_STG_GATE_PT[34] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[30],
                                   ex1_vld_q}) == 15'b011111000010101;
assign TBL_VAL_STG_GATE_PT[35] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29], ex1_instr_q[30],
                                   ex1_vld_q}) == 15'b011111010101111;
assign TBL_VAL_STG_GATE_PT[36] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29], ex1_instr_q[30],
                                   ex1_vld_q}) == 15'b011111000101001;
assign TBL_VAL_STG_GATE_PT[37] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                   ex1_instr_q[22], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[28], ex1_instr_q[30],
                                   ex1_vld_q}) == 14'b01111100001111;
assign TBL_VAL_STG_GATE_PT[38] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05],
                                   ex1_instr_q[21], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[28], ex1_instr_q[29],
                                   ex1_instr_q[30], ex1_vld_q}) == 14'b01111100011111;
assign TBL_VAL_STG_GATE_PT[39] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05],
                                   ex1_instr_q[23], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                   ex1_instr_q[30], ex1_vld_q}) == 14'b01111110101101;
assign TBL_VAL_STG_GATE_PT[40] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05],
                                   ex1_instr_q[21], ex1_instr_q[22], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                   ex1_instr_q[29], ex1_vld_q}) == 14'b01111100010111;
assign TBL_VAL_STG_GATE_PT[41] = ({ex1_instr_q[00], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[31],
                                   ex1_vld_q}) == 7'b1101001;
assign TBL_VAL_STG_GATE_PT[42] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05],
                                   ex1_instr_q[30], ex1_vld_q}) == 8'b11111001;
assign TBL_VAL_STG_GATE_PT[43] = ({au_lq_ex1_ldst_v, au_lq_ex1_mftgpr, au_lq_ex1_mffgpr, au_lq_ex1_movedp, ex1_vld_q}) == 5'b10001;
assign TBL_VAL_STG_GATE_PT[44] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[03], ex1_instr_q[05], ex1_vld_q}) == 5'b10001;
assign TBL_VAL_STG_GATE_PT[45] = ({au_lq_ex1_mffgpr, au_lq_ex1_movedp, ex1_vld_q}) == 3'b111;
assign TBL_VAL_STG_GATE_PT[46] = ({au_lq_ex1_mftgpr, au_lq_ex1_movedp, ex1_vld_q}) == 3'b111;
assign TBL_VAL_STG_GATE_PT[47] = ({au_lq_ex1_mftgpr, au_lq_ex1_movedp, ex1_vld_q}) == 3'b101;
assign TBL_VAL_STG_GATE_PT[48] = ({au_lq_ex1_mffgpr, au_lq_ex1_movedp, ex1_vld_q}) == 3'b101;
assign TBL_VAL_STG_GATE_PT[49] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[03], ex1_instr_q[04], ex1_vld_q}) == 5'b10101;
assign TBL_VAL_STG_GATE_PT[50] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_vld_q}) == 5'b10011;
// Table TBL_VAL_STG_GATE Signal Assignments for Outputs
assign ex1_cache_acc           = (TBL_VAL_STG_GATE_PT[8]  | TBL_VAL_STG_GATE_PT[16] | TBL_VAL_STG_GATE_PT[18] | TBL_VAL_STG_GATE_PT[19] |
                                  TBL_VAL_STG_GATE_PT[21] | TBL_VAL_STG_GATE_PT[22] | TBL_VAL_STG_GATE_PT[23] | TBL_VAL_STG_GATE_PT[24] |
                                  TBL_VAL_STG_GATE_PT[25] | TBL_VAL_STG_GATE_PT[26] | TBL_VAL_STG_GATE_PT[27] | TBL_VAL_STG_GATE_PT[28] |
                                  TBL_VAL_STG_GATE_PT[29] | TBL_VAL_STG_GATE_PT[30] | TBL_VAL_STG_GATE_PT[31] | TBL_VAL_STG_GATE_PT[32] |
                                  TBL_VAL_STG_GATE_PT[33] | TBL_VAL_STG_GATE_PT[34] | TBL_VAL_STG_GATE_PT[35] | TBL_VAL_STG_GATE_PT[36] |
                                  TBL_VAL_STG_GATE_PT[37] | TBL_VAL_STG_GATE_PT[38] | TBL_VAL_STG_GATE_PT[39] | TBL_VAL_STG_GATE_PT[40] |
                                  TBL_VAL_STG_GATE_PT[41] | TBL_VAL_STG_GATE_PT[42] | TBL_VAL_STG_GATE_PT[43] | TBL_VAL_STG_GATE_PT[44] |
                                  TBL_VAL_STG_GATE_PT[49] | TBL_VAL_STG_GATE_PT[50]);
assign ex1_is_msgsnd           = (TBL_VAL_STG_GATE_PT[5]);
assign dec_dcc_ex1_mbar_instr  = (TBL_VAL_STG_GATE_PT[7]);
assign dec_dcc_ex1_sync_instr  = (TBL_VAL_STG_GATE_PT[10]);
assign dec_dcc_ex1_makeitso_instr = (TBL_VAL_STG_GATE_PT[6]);
assign dec_dcc_ex1_tlbsync_instr = (TBL_VAL_STG_GATE_PT[9]);
assign dec_dcc_ex1_wclr_instr  = (TBL_VAL_STG_GATE_PT[8]);
assign dec_dcc_ex1_wchk_instr  = (TBL_VAL_STG_GATE_PT[3]);
assign dec_dcc_ex1_src_gpr     = (TBL_VAL_STG_GATE_PT[11] | TBL_VAL_STG_GATE_PT[48]);
assign dec_dcc_ex1_src_axu     = (TBL_VAL_STG_GATE_PT[46] | TBL_VAL_STG_GATE_PT[47]);
assign dec_dcc_ex1_src_dp      = (TBL_VAL_STG_GATE_PT[12] | TBL_VAL_STG_GATE_PT[45]);
assign dec_dcc_ex1_targ_gpr    = (TBL_VAL_STG_GATE_PT[2]  | TBL_VAL_STG_GATE_PT[47]);
assign dec_dcc_ex1_targ_axu    = (TBL_VAL_STG_GATE_PT[45] | TBL_VAL_STG_GATE_PT[48]);
assign dec_dcc_ex1_targ_dp     = (TBL_VAL_STG_GATE_PT[11] | TBL_VAL_STG_GATE_PT[46]);

assign ex1_cmd_act          = (TBL_VAL_STG_GATE_PT[1]  | TBL_VAL_STG_GATE_PT[5]  | TBL_VAL_STG_GATE_PT[6]  | TBL_VAL_STG_GATE_PT[7]  |
                               TBL_VAL_STG_GATE_PT[8]  | TBL_VAL_STG_GATE_PT[9]  | TBL_VAL_STG_GATE_PT[10] | TBL_VAL_STG_GATE_PT[11] |
                               TBL_VAL_STG_GATE_PT[12] | TBL_VAL_STG_GATE_PT[16] | TBL_VAL_STG_GATE_PT[18] | TBL_VAL_STG_GATE_PT[19] |
                               TBL_VAL_STG_GATE_PT[20] | TBL_VAL_STG_GATE_PT[22] | TBL_VAL_STG_GATE_PT[23] | TBL_VAL_STG_GATE_PT[24] |
                               TBL_VAL_STG_GATE_PT[25] | TBL_VAL_STG_GATE_PT[26] | TBL_VAL_STG_GATE_PT[27] | TBL_VAL_STG_GATE_PT[28] |
                               TBL_VAL_STG_GATE_PT[29] | TBL_VAL_STG_GATE_PT[30] | TBL_VAL_STG_GATE_PT[31] | TBL_VAL_STG_GATE_PT[32] |
                               TBL_VAL_STG_GATE_PT[33] | TBL_VAL_STG_GATE_PT[34] | TBL_VAL_STG_GATE_PT[35] | TBL_VAL_STG_GATE_PT[36] |
                               TBL_VAL_STG_GATE_PT[37] | TBL_VAL_STG_GATE_PT[38] | TBL_VAL_STG_GATE_PT[39] | TBL_VAL_STG_GATE_PT[40] |
                               TBL_VAL_STG_GATE_PT[41] | TBL_VAL_STG_GATE_PT[42] | TBL_VAL_STG_GATE_PT[43] | TBL_VAL_STG_GATE_PT[44] |
                               TBL_VAL_STG_GATE_PT[45] | TBL_VAL_STG_GATE_PT[46] | TBL_VAL_STG_GATE_PT[47] | TBL_VAL_STG_GATE_PT[48] |
                               TBL_VAL_STG_GATE_PT[49] | TBL_VAL_STG_GATE_PT[50]);
assign ctl_dat_ex1_data_act = (TBL_VAL_STG_GATE_PT[11] | TBL_VAL_STG_GATE_PT[12] | TBL_VAL_STG_GATE_PT[13] | TBL_VAL_STG_GATE_PT[14] |
                               TBL_VAL_STG_GATE_PT[15] | TBL_VAL_STG_GATE_PT[17] | TBL_VAL_STG_GATE_PT[24] | TBL_VAL_STG_GATE_PT[25] |
                               TBL_VAL_STG_GATE_PT[31] | TBL_VAL_STG_GATE_PT[36] | TBL_VAL_STG_GATE_PT[41] | TBL_VAL_STG_GATE_PT[43] |
                               TBL_VAL_STG_GATE_PT[44]);
assign ex1_mtspr_trace      = (TBL_VAL_STG_GATE_PT[1]);
assign ex1_derat_act        = (TBL_VAL_STG_GATE_PT[16] | TBL_VAL_STG_GATE_PT[18] | TBL_VAL_STG_GATE_PT[19] | TBL_VAL_STG_GATE_PT[21] |
                               TBL_VAL_STG_GATE_PT[22] | TBL_VAL_STG_GATE_PT[23] | TBL_VAL_STG_GATE_PT[24] | TBL_VAL_STG_GATE_PT[25] |
                               TBL_VAL_STG_GATE_PT[26] | TBL_VAL_STG_GATE_PT[27] | TBL_VAL_STG_GATE_PT[28] | TBL_VAL_STG_GATE_PT[29] |
                               TBL_VAL_STG_GATE_PT[30] | TBL_VAL_STG_GATE_PT[31] | TBL_VAL_STG_GATE_PT[32] | TBL_VAL_STG_GATE_PT[33] |
                               TBL_VAL_STG_GATE_PT[34] | TBL_VAL_STG_GATE_PT[35] | TBL_VAL_STG_GATE_PT[36] | TBL_VAL_STG_GATE_PT[37] |
                               TBL_VAL_STG_GATE_PT[38] | TBL_VAL_STG_GATE_PT[39] | TBL_VAL_STG_GATE_PT[40] | TBL_VAL_STG_GATE_PT[41] |
                               TBL_VAL_STG_GATE_PT[42] | TBL_VAL_STG_GATE_PT[43] | TBL_VAL_STG_GATE_PT[44] | TBL_VAL_STG_GATE_PT[49] |
                               TBL_VAL_STG_GATE_PT[50]);
assign ex1_dir_rd_act       = (TBL_VAL_STG_GATE_PT[4] |  TBL_VAL_STG_GATE_PT[13] | TBL_VAL_STG_GATE_PT[15] | TBL_VAL_STG_GATE_PT[17] |
                               TBL_VAL_STG_GATE_PT[19] | TBL_VAL_STG_GATE_PT[22] | TBL_VAL_STG_GATE_PT[23] | TBL_VAL_STG_GATE_PT[24] |
                               TBL_VAL_STG_GATE_PT[25] | TBL_VAL_STG_GATE_PT[28] | TBL_VAL_STG_GATE_PT[31] | TBL_VAL_STG_GATE_PT[36] |
                               TBL_VAL_STG_GATE_PT[41] | TBL_VAL_STG_GATE_PT[43] | TBL_VAL_STG_GATE_PT[44]);

//
// Final Table Listing
//      *INPUTS*===================================================*OUTPUTS*============================================*
//      |                                                          |                                                    |
//      | ex1_instr_q                                              |                                                    |
//      | |      ex1_instr_q                                       |                                                    |
//      | |      | ex1_instr_q                                     | ex1_derat_is_load                                  |
//      | |      | |          ex1_instr_q                          | | ex1_derat_is_store                               |
//      | |      | |          |  au_lq_ex1_ldst_v                  | | | ex1_load_instr                                 |
//      | |      | |          |  | au_lq_ex1_ldst_size             | | | | dec_dcc_ex1_store_instr                      |
//      | |      | |          |  | |      au_lq_ex1_mftgpr         | | | | | dec_dcc_ex1_algebraic                      |
//      | |      | |          |  | |      | au_lq_ex1_mffgpr       | | | | | | dec_dcc_ex1_ldawx_instr                  |
//      | |      | |          |  | |      | | au_lq_ex1_movedp     | | | | | | | dec_dcc_ex1_optype1                    |
//      | |      | |          |  | |      | | | au_lq_ex1_st_v     | | | | | | | | dec_dcc_ex1_optype16                 |
//      | |      | |          |  | |      | | | |                  | | | | | | | | | dec_dcc_ex1_optype2                |
//      | |      | |          |  | |      | | | |                  | | | | | | | | | | dec_dcc_ex1_optype32             |
//      | |      | |          |  | |      | | | |                  | | | | | | | | | | | dec_dcc_ex1_optype4            |
//      | |      | |          |  | |      | | | |                  | | | | | | | | | | | | dec_dcc_ex1_optype8          |
//      | |      | |          |  | |      | | | |                  | | | | | | | | | | | | | ex1_dcm_instr              |
//      | |      | |          |  | |      | | | |                  | | | | | | | | | | | | | | dec_dcc_ex1_strg_index   |
//      | |      | |          |  | |      | | | |                  | | | | | | | | | | | | | | | ex1_is_any_load_dac    |
//      | |      | |          |  | |      | | | |                  | | | | | | | | | | | | | | | | ex1_is_any_store_dac |
//      | |      | |          |  | |      | | | |                  | | | | | | | | | | | | | | | | | ex1_resv_instr     |
//      | |      | |          |  | |      | | | |                  | | | | | | | | | | | | | | | | | |                  |
//      | 000000 0 2222222223 33 | 000000 | | | |                  | | | | | | | | | | | | | | | | | |                  |
//      | 012345 9 1234567890 01 | 012345 | | | |                  | | | | | | | | | | | | | | | | | |                  |
//      *TYPE*=====================================================+====================================================+
//      | PPPPPP P PPPPPPPPPP PP P PPPPPP P P P P                  | P P P P P P P P P P P P P P P P P                  |
//      *POLARITY*------------------------------------------------>| + + + + + + + + + + + + + + + + +                  |
//      *PHASE*--------------------------------------------------->| T T T T T T T T T T T T T T T T T                  |
//      *TERMS*====================================================+====================================================+
//    1 | 011111 1 1110100110 -- - ------ - - - -                  | 1 . . . . . . . . . . . . . 1 . .                  |
//    2 | 011111 - 1110100110 -- - ------ - - - -                  | . . . . . . . . . . . . 1 . . . .                  |
//    3 | 011111 - 1111111111 -- - ------ - - - -                  | . 1 . . . . . . . . . . 1 . . 1 .                  |
//    4 | 011111 - 1110110110 -- - ------ - - - -                  | . 1 . . . . . . . . 1 . . . . . .                  |
//    5 | 011111 - 1111011111 -- - ------ - - - -                  | 1 . . . . . . . . . . . 1 . 1 . .                  |
//    6 | 011111 - 0100111111 -- - ------ - - - -                  | 1 . . . . . . . . . . . 1 . 1 . .                  |
//    7 | 011111 - 10-0010101 -- - ------ - - - -                  | . . . . . . . . . . . . . 1 . . .                  |
//    8 | 011111 - 0011111111 -- - ------ - - - -                  | . 1 . . . . . . . . . . 1 . . 1 .                  |
//    9 | 011111 - 1111110110 -- - ------ - - - -                  | . 1 . . . . . . . . . . 1 . . 1 .                  |
//   10 | 011111 - 01010101-1 -- - ------ - - - -                  | . . 1 . 1 . . . . . . . . . . . .                  |
//   11 | 011111 - 0110000110 -- - ------ - - - -                  | 1 . . . . . . . . . . . 1 . 1 . .                  |
//   12 | 011111 - 1000010100 -- - ------ - - - -                  | 1 . . . . . . . . . . 1 . . 1 . .                  |
//   13 | 011111 - 0010000110 -- - ------ - - - -                  | . 1 . . . . . . . . . . 1 . . 1 .                  |
//   14 | 011111 - 1111010110 -- - ------ - - - -                  | 1 . . . . . . . . . . . 1 . 1 . .                  |
//   15 | 011111 - 0001110100 -- - ------ - - - -                  | 1 . 1 . . . . . 1 . . . . . 1 . 1                  |
//   16 | 011111 - 1010010100 -- - ------ - - - -                  | . 1 . 1 . . . . . . . 1 . . . 1 .                  |
//   17 | 011111 - 0111010110 -- - ------ - - - -                  | . 1 . . . . . . . . . . 1 . . 1 .                  |
//   18 | 011111 - 0011110110 -- - ------ - - - -                  | . 1 . . . . . . . . . . 1 . . 1 .                  |
//   19 | 011111 - 1100010110 -- - ------ - - - -                  | 1 . 1 . . . . . 1 . . . . . 1 . .                  |
//   20 | 011111 - 1110010110 -- - ------ - - - -                  | . 1 . 1 . . . . 1 . . . . . . 1 .                  |
//   21 | 011111 - 0000110100 -- - ------ - - - -                  | 1 . 1 . . . 1 . . . . . . . 1 . 1                  |
//   22 | 011111 - 1010110110 -- - ------ - - - -                  | . 1 . 1 . . 1 . . . . . . . . 1 1                  |
//   23 | 011111 - 0-11100110 -- - ------ - - - -                  | 1 . . . . . . . . . . . 1 . 1 . .                  |
//   24 | 011111 - 0000110110 -- - ------ - - - -                  | 1 . . . . . . . . . . . 1 . . 1 .                  |
//   25 | 011111 - 001-010110 -- - ------ - - - -                  | . . . . . . . . . . . . . . . . 1                  |
//   26 | 011111 - 101-010101 -- - ------ - - - -                  | . 1 . . . . . . . . . . . . . 1 .                  |
//   27 | 011111 - 0000010100 -- - ------ - - - -                  | 1 . . . . . . . . . 1 . . . 1 . 1                  |
//   28 | 011111 - 0001010100 -- - ------ - - - -                  | 1 . 1 . . . . . . . . 1 . . 1 . 1                  |
//   29 | 011111 - 100-010101 -- - ------ - - - -                  | 1 . . . . . . . . . . . . . 1 . .                  |
//   30 | 011111 - 0011010100 -- - ------ - - - -                  | 1 . 1 . . 1 . . . . . 1 . . 1 . .                  |
//   31 | 011111 - 000-111111 -- - ------ - - - -                  | 1 . . . . . . . . . . . 1 . . 1 .                  |
//   32 | 011111 - 1011010110 -- - ------ - - - -                  | . 1 . 1 . . . . 1 . . . . . . 1 1                  |
//   33 | 011111 - 0001010110 -- - ------ - - - -                  | 1 . . . . . . . . . . . 1 . . 1 .                  |
//   34 | 011111 - 0101-10101 -- - ------ - - - -                  | 1 . . . . . . . . . 1 . . . 1 . .                  |
//   35 | 011111 - 1000010110 -- - ------ - - - -                  | 1 . 1 . . . . . . . 1 . . . 1 . .                  |
//   36 | 011111 - 001-100110 -- - ------ - - - -                  | 1 . . . . . . . . . . . 1 . 1 . .                  |
//   37 | 011111 - -00001010- -- - ------ - - - -                  | . . 1 . . . . . . . . . . . . . .                  |
//   38 | 011111 - 0011010110 -- - ------ - - - -                  | . 1 . 1 . . . . . . . 1 . . . 1 .                  |
//   39 | 011111 - 00-0-10101 -- - ------ - - - -                  | . . . . . . . . . . . 1 . . . . .                  |
//   40 | 011111 - 0-10010110 -- - ------ - - - -                  | . 1 . . . . . . . . 1 . . . . . .                  |
//   41 | 011111 - 000001-101 -- - ------ - - - -                  | 1 . 1 . . . . . . . . 1 . . 1 . .                  |
//   42 | 011111 - 001001-101 -- - ------ - - - -                  | . 1 . 1 . . . . . . . 1 . . . 1 .                  |
//   43 | 011111 - 010001-111 -- - ------ - - - -                  | 1 . 1 . . . . . 1 . . . . . 1 . .                  |
//   44 | 011111 - 0001-10111 -- - ------ - - - -                  | 1 . . . . . 1 . . . . . . . 1 . .                  |
//   45 | 011111 - 011001-111 -- - ------ - - - -                  | . 1 . 1 . . . . 1 . . . . . . 1 .                  |
//   46 | 011111 - 000101-111 -- - ------ - - - -                  | 1 . 1 . . . 1 . . . . . . . 1 . .                  |
//   47 | 011111 - 001101-111 -- - ------ - - - -                  | . 1 . 1 . . 1 . . . . . . . . 1 .                  |
//   48 | 011111 - 00-0-10111 -- - ------ - - - -                  | . . . . . . . . . . 1 . . . . . .                  |
//   49 | 011111 - 0110-10111 -- - ------ - - - -                  | . 1 . 1 . . . . 1 . . . . . . 1 .                  |
//   50 | 011111 - 0011-10111 -- - ------ - - - -                  | . 1 . 1 . . 1 . . . . . . . . 1 .                  |
//   51 | 011111 - 0-00010110 -- - ------ - - - -                  | 1 . . . . . . . . . . . 1 . 1 . .                  |
//   52 | 011111 - 000001-111 -- - ------ - - - -                  | 1 . 1 . . . . . . . 1 . . . 1 . .                  |
//   53 | 011111 - 001001-111 -- - ------ - - - -                  | . 1 . 1 . . . . . . 1 . . . . 1 .                  |
//   54 | 011111 - -010010110 -- - ------ - - - -                  | . 1 . 1 . . . . . . 1 . . . . 1 .                  |
//   55 | 011111 - 0000-101-1 -- - ------ - - - -                  | 1 . . . . . . . . . . . . . 1 . .                  |
//   56 | 011111 - 010--10111 -- - ------ - - - -                  | 1 . . . . . . . 1 . . . . . 1 . .                  |
//   57 | 011111 - 0010-101-1 -- - ------ - - - -                  | . 1 . 1 . . . . . . . . . . . 1 .                  |
//   58 | 111010 - ---------- 10 - ------ - - - -                  | 1 . . . 1 . . . . . 1 . . . 1 . .                  |
//   59 | ------ - ---------- -- 1 ------ 0 0 0 1                  | . 1 . 1 . . . . . . . . . . . 1 .                  |
//   60 | 101010 - ---------- -- - ------ - - - -                  | . . . . 1 . . . . . . . . . . . .                  |
//   61 | ------ - ---------- -- 1 ------ 0 0 0 0                  | 1 . 1 . . . . . . . . . . . 1 . .                  |
//   62 | 1-1010 - ---------- -0 - ------ - - - -                  | . . 1 . . . . . . . . . . . . . .                  |
//   63 | 10000- - ---------- -- - ------ - - - -                  | 1 . . . . . . . . . 1 . . . 1 . .                  |
//   64 | 10-0-0 - ---------- -- - ------ - - - -                  | . . 1 . . . . . . . . . . . . . .                  |
//   65 | 111010 - ---------- 0- - ------ - - - -                  | 1 . . . . . . . . . . 1 . . 1 . .                  |
//   66 | 10001- - ---------- -- - ------ - - - -                  | 1 . . . . . 1 . . . . . . . 1 . .                  |
//   67 | 10010- - ---------- -- - ------ - - - -                  | . 1 . 1 . . . . . . 1 . . . . 1 .                  |
//   68 | 111110 - ---------- 0- - ------ - - - -                  | . 1 . 1 . . . . . . . 1 . . . 1 .                  |
//   69 | 101110 - ---------- -- - ------ - - - -                  | 1 . . . . . . . . . 1 . . . 1 . .                  |
//   70 | 10011- - ---------- -- - ------ - - - -                  | . 1 . 1 . . 1 . . . . . . . . 1 .                  |
//   71 | 10110- - ---------- -- - ------ - - - -                  | . 1 . 1 . . . . 1 . . . . . . 1 .                  |
//   72 | ------ - ---------- -- 1 -1---- - - - -                  | . . . . . . . 1 . . . . . . . . .                  |
//   73 | ------ - ---------- -- 1 1----- - - - -                  | . . . . . . . . . 1 . . . . . . .                  |
//   74 | ------ - ---------- -- 1 -----1 - - - -                  | . . . . . . 1 . . . . . . . . . .                  |
//   75 | 1010-- - ---------- -- - ------ - - - -                  | 1 . . . . . . . 1 . . . . . 1 . .                  |
//   76 | ------ - ---------- -- 1 ----1- - - - -                  | . . . . . . . . 1 . . . . . . . .                  |
//   77 | ------ - ---------- -- 1 --1--- - - - -                  | . . . . . . . . . . . 1 . . . . .                  |
//   78 | ------ - ---------- -- 1 ---1-- - - - -                  | . . . . . . . . . . 1 . . . . . .                  |
//   79 | 101111 - ---------- -- - ------ - - - -                  | . 1 . . . . . . . . 1 . . . . 1 .                  |
//      *===============================================================================================================*
//
// Table TBL_LD_ST_DEC Signal Assignments for Product Terms
assign TBL_LD_ST_DEC_PT[1]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[09],
                                ex1_instr_q[21], ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27],
                                ex1_instr_q[28], ex1_instr_q[29], ex1_instr_q[30]}) == 17'b01111111110100110;
assign TBL_LD_ST_DEC_PT[2]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111111110100110;
assign TBL_LD_ST_DEC_PT[3]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111111111111111;
assign TBL_LD_ST_DEC_PT[4]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111111110110110;
assign TBL_LD_ST_DEC_PT[5]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111111111011111;
assign TBL_LD_ST_DEC_PT[6]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111110100111111;
assign TBL_LD_ST_DEC_PT[7]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111100010101;
assign TBL_LD_ST_DEC_PT[8]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111110011111111;
assign TBL_LD_ST_DEC_PT[9]  = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111111111110110;
assign TBL_LD_ST_DEC_PT[10] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[30]}) == 15'b011111010101011;
assign TBL_LD_ST_DEC_PT[11] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111110110000110;
assign TBL_LD_ST_DEC_PT[12] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111111000010100;
assign TBL_LD_ST_DEC_PT[13] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111110010000110;
assign TBL_LD_ST_DEC_PT[14] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111111111010110;
assign TBL_LD_ST_DEC_PT[15] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111110001110100;
assign TBL_LD_ST_DEC_PT[16] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111111010010100;
assign TBL_LD_ST_DEC_PT[17] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111110111010110;
assign TBL_LD_ST_DEC_PT[18] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111110011110110;
assign TBL_LD_ST_DEC_PT[19] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111111100010110;
assign TBL_LD_ST_DEC_PT[20] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111111110010110;
assign TBL_LD_ST_DEC_PT[21] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111110000110100;
assign TBL_LD_ST_DEC_PT[22] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111111010110110;
assign TBL_LD_ST_DEC_PT[23] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111011100110;
assign TBL_LD_ST_DEC_PT[24] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111110000110110;
assign TBL_LD_ST_DEC_PT[25] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111001010110;
assign TBL_LD_ST_DEC_PT[26] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111101010101;
assign TBL_LD_ST_DEC_PT[27] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111110000010100;
assign TBL_LD_ST_DEC_PT[28] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111110001010100;
assign TBL_LD_ST_DEC_PT[29] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111100010101;
assign TBL_LD_ST_DEC_PT[30] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111110011010100;
assign TBL_LD_ST_DEC_PT[31] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111000111111;
assign TBL_LD_ST_DEC_PT[32] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111111011010110;
assign TBL_LD_ST_DEC_PT[33] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111110001010110;
assign TBL_LD_ST_DEC_PT[34] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111010110101;
assign TBL_LD_ST_DEC_PT[35] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111111000010110;
assign TBL_LD_ST_DEC_PT[36] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111001100110;
assign TBL_LD_ST_DEC_PT[37] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[22],
                                ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29]}) == 14'b01111100001010;
assign TBL_LD_ST_DEC_PT[38] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[29], ex1_instr_q[30]}) == 16'b0111110011010110;
assign TBL_LD_ST_DEC_PT[39] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 14'b01111100010101;
assign TBL_LD_ST_DEC_PT[40] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111010010110;
assign TBL_LD_ST_DEC_PT[41] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111000001101;
assign TBL_LD_ST_DEC_PT[42] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111001001101;
assign TBL_LD_ST_DEC_PT[43] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111010001111;
assign TBL_LD_ST_DEC_PT[44] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111000110111;
assign TBL_LD_ST_DEC_PT[45] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111011001111;
assign TBL_LD_ST_DEC_PT[46] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111000101111;
assign TBL_LD_ST_DEC_PT[47] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111001101111;
assign TBL_LD_ST_DEC_PT[48] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 14'b01111100010111;
assign TBL_LD_ST_DEC_PT[49] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111011010111;
assign TBL_LD_ST_DEC_PT[50] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111001110111;
assign TBL_LD_ST_DEC_PT[51] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111000010110;
assign TBL_LD_ST_DEC_PT[52] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111000001111;
assign TBL_LD_ST_DEC_PT[53] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111001001111;
assign TBL_LD_ST_DEC_PT[54] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[22],
                                ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[25], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 15'b011111010010110;
assign TBL_LD_ST_DEC_PT[55] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[30]}) == 14'b01111100001011;
assign TBL_LD_ST_DEC_PT[56] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28], ex1_instr_q[29],
                                ex1_instr_q[30]}) == 14'b01111101010111;
assign TBL_LD_ST_DEC_PT[57] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[21],
                                ex1_instr_q[22], ex1_instr_q[23], ex1_instr_q[24], ex1_instr_q[26], ex1_instr_q[27], ex1_instr_q[28],
                                ex1_instr_q[30]}) == 14'b01111100101011;
assign TBL_LD_ST_DEC_PT[58] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[30],
                                ex1_instr_q[31]}) == 8'b11101010;
assign TBL_LD_ST_DEC_PT[59] = ({au_lq_ex1_ldst_v, au_lq_ex1_mftgpr, au_lq_ex1_mffgpr, au_lq_ex1_movedp, au_lq_ex1_st_v}) == 5'b10001;
assign TBL_LD_ST_DEC_PT[60] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05]}) == 6'b101010;
assign TBL_LD_ST_DEC_PT[61] = ({au_lq_ex1_ldst_v, au_lq_ex1_mftgpr, au_lq_ex1_mffgpr, au_lq_ex1_movedp, au_lq_ex1_st_v}) == 5'b10000;
assign TBL_LD_ST_DEC_PT[62] = ({ex1_instr_q[00], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[31]}) == 6'b110100;
assign TBL_LD_ST_DEC_PT[63] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04]}) == 5'b10000;
assign TBL_LD_ST_DEC_PT[64] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[03], ex1_instr_q[05]}) == 4'b1000;
assign TBL_LD_ST_DEC_PT[65] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[30]}) == 7'b1110100;
assign TBL_LD_ST_DEC_PT[66] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04]}) == 5'b10001;
assign TBL_LD_ST_DEC_PT[67] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04]}) == 5'b10010;
assign TBL_LD_ST_DEC_PT[68] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05], ex1_instr_q[30]}) == 7'b1111100;
assign TBL_LD_ST_DEC_PT[69] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05]}) == 6'b101110;
assign TBL_LD_ST_DEC_PT[70] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04]}) == 5'b10011;
assign TBL_LD_ST_DEC_PT[71] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04]}) == 5'b10110;
assign TBL_LD_ST_DEC_PT[72] = ({au_lq_ex1_ldst_v, au_lq_ex1_ldst_size[01]}) == 2'b11;
assign TBL_LD_ST_DEC_PT[73] = ({au_lq_ex1_ldst_v, au_lq_ex1_ldst_size[00]}) == 2'b11;
assign TBL_LD_ST_DEC_PT[74] = ({au_lq_ex1_ldst_v, au_lq_ex1_ldst_size[05]}) == 2'b11;
assign TBL_LD_ST_DEC_PT[75] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03]}) == 4'b1010;
assign TBL_LD_ST_DEC_PT[76] = ({au_lq_ex1_ldst_v, au_lq_ex1_ldst_size[04]}) == 2'b11;
assign TBL_LD_ST_DEC_PT[77] = ({au_lq_ex1_ldst_v, au_lq_ex1_ldst_size[02]}) == 2'b11;
assign TBL_LD_ST_DEC_PT[78] = ({au_lq_ex1_ldst_v, au_lq_ex1_ldst_size[03]}) == 2'b11;
assign TBL_LD_ST_DEC_PT[79] = ({ex1_instr_q[00], ex1_instr_q[01], ex1_instr_q[02], ex1_instr_q[03], ex1_instr_q[04], ex1_instr_q[05]}) == 6'b101111;

// Table TBL_LD_ST_DEC Signal Assignments for Outputs
assign ex1_derat_is_load        = (TBL_LD_ST_DEC_PT[1]  | TBL_LD_ST_DEC_PT[5]  | TBL_LD_ST_DEC_PT[6]  | TBL_LD_ST_DEC_PT[11] |
                                   TBL_LD_ST_DEC_PT[12] | TBL_LD_ST_DEC_PT[14] | TBL_LD_ST_DEC_PT[15] | TBL_LD_ST_DEC_PT[19] |
                                   TBL_LD_ST_DEC_PT[21] | TBL_LD_ST_DEC_PT[23] | TBL_LD_ST_DEC_PT[24] | TBL_LD_ST_DEC_PT[27] |
                                   TBL_LD_ST_DEC_PT[28] | TBL_LD_ST_DEC_PT[29] | TBL_LD_ST_DEC_PT[30] | TBL_LD_ST_DEC_PT[31] |
                                   TBL_LD_ST_DEC_PT[33] | TBL_LD_ST_DEC_PT[34] | TBL_LD_ST_DEC_PT[35] | TBL_LD_ST_DEC_PT[36] |
                                   TBL_LD_ST_DEC_PT[41] | TBL_LD_ST_DEC_PT[43] | TBL_LD_ST_DEC_PT[44] | TBL_LD_ST_DEC_PT[46] |
                                   TBL_LD_ST_DEC_PT[51] | TBL_LD_ST_DEC_PT[52] | TBL_LD_ST_DEC_PT[55] | TBL_LD_ST_DEC_PT[56] |
                                   TBL_LD_ST_DEC_PT[58] | TBL_LD_ST_DEC_PT[61] | TBL_LD_ST_DEC_PT[63] | TBL_LD_ST_DEC_PT[65] |
                                   TBL_LD_ST_DEC_PT[66] | TBL_LD_ST_DEC_PT[69] | TBL_LD_ST_DEC_PT[75]);
assign ex1_derat_is_store       = (TBL_LD_ST_DEC_PT[3]  | TBL_LD_ST_DEC_PT[4]  | TBL_LD_ST_DEC_PT[8]  | TBL_LD_ST_DEC_PT[9]  |
                                   TBL_LD_ST_DEC_PT[13] | TBL_LD_ST_DEC_PT[16] | TBL_LD_ST_DEC_PT[17] | TBL_LD_ST_DEC_PT[18] |
                                   TBL_LD_ST_DEC_PT[20] | TBL_LD_ST_DEC_PT[22] | TBL_LD_ST_DEC_PT[26] | TBL_LD_ST_DEC_PT[32] |
                                   TBL_LD_ST_DEC_PT[38] | TBL_LD_ST_DEC_PT[40] | TBL_LD_ST_DEC_PT[42] | TBL_LD_ST_DEC_PT[45] |
                                   TBL_LD_ST_DEC_PT[47] | TBL_LD_ST_DEC_PT[49] | TBL_LD_ST_DEC_PT[50] | TBL_LD_ST_DEC_PT[53] |
                                   TBL_LD_ST_DEC_PT[54] | TBL_LD_ST_DEC_PT[57] | TBL_LD_ST_DEC_PT[59] | TBL_LD_ST_DEC_PT[67] |
                                   TBL_LD_ST_DEC_PT[68] | TBL_LD_ST_DEC_PT[70] | TBL_LD_ST_DEC_PT[71] | TBL_LD_ST_DEC_PT[79]);
assign ex1_load_instr           = (TBL_LD_ST_DEC_PT[10] | TBL_LD_ST_DEC_PT[15] | TBL_LD_ST_DEC_PT[19] | TBL_LD_ST_DEC_PT[21] |
                                   TBL_LD_ST_DEC_PT[28] | TBL_LD_ST_DEC_PT[30] | TBL_LD_ST_DEC_PT[35] | TBL_LD_ST_DEC_PT[37] |
                                   TBL_LD_ST_DEC_PT[41] | TBL_LD_ST_DEC_PT[43] | TBL_LD_ST_DEC_PT[46] | TBL_LD_ST_DEC_PT[52] |
                                   TBL_LD_ST_DEC_PT[61] | TBL_LD_ST_DEC_PT[62] | TBL_LD_ST_DEC_PT[64]);
assign dec_dcc_ex1_store_instr  = (TBL_LD_ST_DEC_PT[16] | TBL_LD_ST_DEC_PT[20] | TBL_LD_ST_DEC_PT[22] | TBL_LD_ST_DEC_PT[32] |
                                   TBL_LD_ST_DEC_PT[38] | TBL_LD_ST_DEC_PT[42] | TBL_LD_ST_DEC_PT[45] | TBL_LD_ST_DEC_PT[47] |
                                   TBL_LD_ST_DEC_PT[49] | TBL_LD_ST_DEC_PT[50] | TBL_LD_ST_DEC_PT[53] | TBL_LD_ST_DEC_PT[54] |
                                   TBL_LD_ST_DEC_PT[57] | TBL_LD_ST_DEC_PT[59] | TBL_LD_ST_DEC_PT[67] | TBL_LD_ST_DEC_PT[68] |
                                   TBL_LD_ST_DEC_PT[70] | TBL_LD_ST_DEC_PT[71]);
assign dec_dcc_ex1_algebraic    = (TBL_LD_ST_DEC_PT[10] | TBL_LD_ST_DEC_PT[58] | TBL_LD_ST_DEC_PT[60]);
assign dec_dcc_ex1_ldawx_instr  = (TBL_LD_ST_DEC_PT[30]);
assign dec_dcc_ex1_optype1      = (TBL_LD_ST_DEC_PT[21] | TBL_LD_ST_DEC_PT[22] | TBL_LD_ST_DEC_PT[44] | TBL_LD_ST_DEC_PT[46] |
                                   TBL_LD_ST_DEC_PT[47] | TBL_LD_ST_DEC_PT[50] | TBL_LD_ST_DEC_PT[66] | TBL_LD_ST_DEC_PT[70] |
                                   TBL_LD_ST_DEC_PT[74]);
assign dec_dcc_ex1_optype16     = (TBL_LD_ST_DEC_PT[72]);
assign dec_dcc_ex1_optype2      = (TBL_LD_ST_DEC_PT[15] | TBL_LD_ST_DEC_PT[19] | TBL_LD_ST_DEC_PT[20] | TBL_LD_ST_DEC_PT[32] |
                                   TBL_LD_ST_DEC_PT[43] | TBL_LD_ST_DEC_PT[45] | TBL_LD_ST_DEC_PT[49] | TBL_LD_ST_DEC_PT[56] |
                                   TBL_LD_ST_DEC_PT[71] | TBL_LD_ST_DEC_PT[75] | TBL_LD_ST_DEC_PT[76]);
assign dec_dcc_ex1_optype32     = (TBL_LD_ST_DEC_PT[73]);
assign dec_dcc_ex1_optype4      = (TBL_LD_ST_DEC_PT[4]  | TBL_LD_ST_DEC_PT[27] | TBL_LD_ST_DEC_PT[34] | TBL_LD_ST_DEC_PT[35] |
                                   TBL_LD_ST_DEC_PT[40] | TBL_LD_ST_DEC_PT[48] | TBL_LD_ST_DEC_PT[52] | TBL_LD_ST_DEC_PT[53] |
                                   TBL_LD_ST_DEC_PT[54] | TBL_LD_ST_DEC_PT[58] | TBL_LD_ST_DEC_PT[63] | TBL_LD_ST_DEC_PT[67] |
                                   TBL_LD_ST_DEC_PT[69] | TBL_LD_ST_DEC_PT[78] | TBL_LD_ST_DEC_PT[79]);
assign dec_dcc_ex1_optype8      = (TBL_LD_ST_DEC_PT[12] | TBL_LD_ST_DEC_PT[16] | TBL_LD_ST_DEC_PT[28] | TBL_LD_ST_DEC_PT[30] |
                                   TBL_LD_ST_DEC_PT[38] | TBL_LD_ST_DEC_PT[39] | TBL_LD_ST_DEC_PT[41] | TBL_LD_ST_DEC_PT[42] |
                                   TBL_LD_ST_DEC_PT[65] | TBL_LD_ST_DEC_PT[68] | TBL_LD_ST_DEC_PT[77]);
assign ex1_dcm_instr            = (TBL_LD_ST_DEC_PT[2]  | TBL_LD_ST_DEC_PT[3]  | TBL_LD_ST_DEC_PT[5]  | TBL_LD_ST_DEC_PT[6]  |
                                   TBL_LD_ST_DEC_PT[8]  | TBL_LD_ST_DEC_PT[9]  | TBL_LD_ST_DEC_PT[11] | TBL_LD_ST_DEC_PT[13] |
                                   TBL_LD_ST_DEC_PT[14] | TBL_LD_ST_DEC_PT[17] | TBL_LD_ST_DEC_PT[18] | TBL_LD_ST_DEC_PT[23] |
                                   TBL_LD_ST_DEC_PT[24] | TBL_LD_ST_DEC_PT[31] | TBL_LD_ST_DEC_PT[33] | TBL_LD_ST_DEC_PT[36] |
                                   TBL_LD_ST_DEC_PT[51]);
assign dec_dcc_ex1_strg_index   = (TBL_LD_ST_DEC_PT[7]);
assign ex1_is_any_load_dac      = (TBL_LD_ST_DEC_PT[1]  | TBL_LD_ST_DEC_PT[5]  | TBL_LD_ST_DEC_PT[6]  | TBL_LD_ST_DEC_PT[11] |
                                   TBL_LD_ST_DEC_PT[12] | TBL_LD_ST_DEC_PT[14] | TBL_LD_ST_DEC_PT[15] | TBL_LD_ST_DEC_PT[19] |
                                   TBL_LD_ST_DEC_PT[21] | TBL_LD_ST_DEC_PT[23] | TBL_LD_ST_DEC_PT[27] | TBL_LD_ST_DEC_PT[28] |
                                   TBL_LD_ST_DEC_PT[29] | TBL_LD_ST_DEC_PT[30] | TBL_LD_ST_DEC_PT[34] | TBL_LD_ST_DEC_PT[35] |
                                   TBL_LD_ST_DEC_PT[36] | TBL_LD_ST_DEC_PT[41] | TBL_LD_ST_DEC_PT[43] | TBL_LD_ST_DEC_PT[44] |
                                   TBL_LD_ST_DEC_PT[46] | TBL_LD_ST_DEC_PT[51] | TBL_LD_ST_DEC_PT[52] | TBL_LD_ST_DEC_PT[55] |
                                   TBL_LD_ST_DEC_PT[56] | TBL_LD_ST_DEC_PT[58] | TBL_LD_ST_DEC_PT[61] | TBL_LD_ST_DEC_PT[63] |
                                   TBL_LD_ST_DEC_PT[65] | TBL_LD_ST_DEC_PT[66] | TBL_LD_ST_DEC_PT[69] | TBL_LD_ST_DEC_PT[75]);
assign ex1_is_any_store_dac     = (TBL_LD_ST_DEC_PT[3]  | TBL_LD_ST_DEC_PT[8]  | TBL_LD_ST_DEC_PT[9]  | TBL_LD_ST_DEC_PT[13] |
                                   TBL_LD_ST_DEC_PT[16] | TBL_LD_ST_DEC_PT[17] | TBL_LD_ST_DEC_PT[18] | TBL_LD_ST_DEC_PT[20] |
                                   TBL_LD_ST_DEC_PT[22] | TBL_LD_ST_DEC_PT[24] | TBL_LD_ST_DEC_PT[26] | TBL_LD_ST_DEC_PT[31] |
                                   TBL_LD_ST_DEC_PT[32] | TBL_LD_ST_DEC_PT[33] | TBL_LD_ST_DEC_PT[38] | TBL_LD_ST_DEC_PT[42] |
                                   TBL_LD_ST_DEC_PT[45] | TBL_LD_ST_DEC_PT[47] | TBL_LD_ST_DEC_PT[49] | TBL_LD_ST_DEC_PT[50] |
                                   TBL_LD_ST_DEC_PT[53] | TBL_LD_ST_DEC_PT[54] | TBL_LD_ST_DEC_PT[57] | TBL_LD_ST_DEC_PT[59] |
                                   TBL_LD_ST_DEC_PT[67] | TBL_LD_ST_DEC_PT[68] | TBL_LD_ST_DEC_PT[70] | TBL_LD_ST_DEC_PT[71] |
                                   TBL_LD_ST_DEC_PT[79]);
assign ex1_resv_instr           = (TBL_LD_ST_DEC_PT[15] | TBL_LD_ST_DEC_PT[21] | TBL_LD_ST_DEC_PT[22] | TBL_LD_ST_DEC_PT[25] |
                                   TBL_LD_ST_DEC_PT[27] | TBL_LD_ST_DEC_PT[28] | TBL_LD_ST_DEC_PT[32]);

assign dec_derat_ex1_is_load    = ex1_derat_is_load;
assign dec_derat_ex1_is_store   = ex1_derat_is_store;
assign ex1_is_ditc              = ex1_is_mtdpx | ex1_is_mtdp | ex1_is_mfdpx | ex1_is_mfdp;

// Need to decode these ops in ex0
assign ex1_opcode_is_62 = ex1_instr_q[0:5] == 6'b111110;
assign ex1_opcode_is_58 = ex1_instr_q[0:5] == 6'b111010;
assign ex1_opcode_is_31 = ex1_instr_q[0:5] == 6'b011111;
assign ex1_is_dcbf      = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0001010110);
assign ex1_is_dcbi      = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0111010110);
assign ex1_is_dcbst     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0000110110);
assign ex1_is_dcblc     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0110000110);
assign ex1_is_dcbt      = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0100010110);
assign ex1_is_dcbtls    = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0010100110);
assign ex1_is_dcbtst    = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0011110110);
assign ex1_is_dcbtstls  = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0010000110);
assign ex1_is_dcbz      = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1111110110);
assign ex1_is_dci       = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0111000110);
assign ex1_is_ici       = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1111000110);
assign ex1_is_icbi      = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1111010110);
assign ex1_is_icblc     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0011100110);
assign ex1_is_icbt      = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0000010110);
assign ex1_is_icbtls    = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0111100110);
assign ex1_is_lbz       = (ex1_instr_q[0:5] == 6'b100010);
assign ex1_is_lbzu      = (ex1_instr_q[0:5] == 6'b100011);
assign ex1_is_lbzux     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0001110111);
assign ex1_is_ld        = (ex1_opcode_is_58 & ex1_instr_q[30:31] == 2'b00);
assign ex1_is_ldbrx     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1000010100);
assign ex1_is_ldu       = (ex1_opcode_is_58 & ex1_instr_q[30:31] == 2'b01);
assign ex1_is_ldux      = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0000110101);
assign ex1_is_lha       = (ex1_instr_q[0:5] == 6'b101010);
assign ex1_is_lhau      = (ex1_instr_q[0:5] == 6'b101011);
assign ex1_is_lhaux     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0101110111);
assign ex1_is_lhbrx     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1100010110);
assign ex1_is_lhzux     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0100110111);
assign ex1_is_lhz       = (ex1_instr_q[0:5] == 6'b101000);
assign ex1_is_lhzu      = (ex1_instr_q[0:5] == 6'b101001);
assign ex1_is_lmw       = (ex1_instr_q[0:5] == 6'b101110);
assign ex1_is_lswi      = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1001010101);
assign ex1_is_lwa       = (ex1_opcode_is_58 & ex1_instr_q[30:31] == 2'b10);
assign ex1_is_lwaux     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0101110101);
assign ex1_is_lwz       = (ex1_instr_q[0:5] == 6'b100000);
assign ex1_is_lwzu      = (ex1_instr_q[0:5] == 6'b100001);
assign ex1_is_lwzux     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0000110111);
assign ex1_is_lwbrx     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1000010110);
assign ex1_is_mfdp      = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0000100011);
assign ex1_is_mfdpx     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0000000011);
assign ex1_is_mtdp      = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0001100011);
assign ex1_is_mtdpx     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0001000011);
assign ex1_is_stb       = (ex1_instr_q[0:5] == 6'b100110);
assign ex1_is_stbu      = (ex1_instr_q[0:5] == 6'b100111);
assign ex1_is_stbux     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0011110111);
assign ex1_is_std       = (ex1_opcode_is_62 & ex1_instr_q[30:31] == 2'b00);
assign ex1_is_stdbrx    = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1010010100);
assign ex1_is_stdu      = (ex1_opcode_is_62 & ex1_instr_q[30:31] == 2'b01);
assign ex1_is_stdux     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0010110101);
assign ex1_is_sth       = (ex1_instr_q[0:5] == 6'b101100);
assign ex1_is_sthu      = (ex1_instr_q[0:5] == 6'b101101);
assign ex1_is_sthux     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0110110111);
assign ex1_is_sthbrx    = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1110010110);
assign ex1_is_stmw      = (ex1_instr_q[0:5] == 6'b101111);
assign ex1_is_stswi     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1011010101);
assign ex1_is_stw       = (ex1_instr_q[0:5] == 6'b100100);
assign ex1_is_stwu      = (ex1_instr_q[0:5] == 6'b100101);
assign ex1_is_stwux     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0010110111);
assign ex1_is_stwbrx    = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1010010110);
assign ex1_is_tlbsync   = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1000110110);
assign ex1_is_dcbstep   = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0000111111);
assign ex1_is_dcbtep    = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0100111111);
assign ex1_is_dcbfep    = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0001111111);
assign ex1_is_dcbtstep  = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0011111111);
assign ex1_is_icbiep    = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1111011111);
assign ex1_is_dcbzep    = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1111111111);
assign ex1_is_icswx     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0110010110);
assign ex1_is_icswepx   = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1110110110);
assign ex1_is_wclr      = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b1110100110);
assign ex1_wclr_one_val = ex1_vld_q & ex1_is_wclr & ex1_instr_q[9];
assign ex1_is_lbepx     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0001011111);
assign ex1_is_ldepx     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0000011101);
assign ex1_is_lhepx     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0100011111);
assign ex1_is_lwepx     = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0000011111);
assign ex1_is_stbepx    = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0011011111);
assign ex1_is_stdepx    = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0010011101);
assign ex1_is_sthepx    = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0110011111);
assign ex1_is_stwepx    = (ex1_opcode_is_31 & ex1_instr_q[21:30] == 10'b0010011111);
assign ex0_is_lbepx     = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b0001011111);
assign ex0_is_lhepx     = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b0100011111);
assign ex0_is_lwepx     = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b0000011111);
assign ex0_is_ldepx     = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b0000011101);
assign ex0_is_dcbfep    = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b0001111111);
assign ex0_is_dcbtep    = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b0100111111);
assign ex0_is_dcbtstep  = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b0011111111);
assign ex0_is_dcbstep   = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b0000111111);
assign ex0_is_icbiep    = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b1111011111);
assign ex0_is_dcbzep    = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b1111111111);
assign ex0_is_stbepx    = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b0011011111);
assign ex0_is_sthepx    = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b0110011111);
assign ex0_is_stwepx    = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b0010011111);
assign ex0_is_stdepx    = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b0010011101);
assign ex0_is_icswepx   = (rv_lq_ex0_instr[0:5] == 6'b011111 & rv_lq_ex0_instr[21:30] == 10'b1110110110);
assign ex0_is_larx      = (rv_lq_ex0_instr[0:5] == 6'b011111) & (rv_lq_ex0_instr[21:23] == 3'b000) & (rv_lq_ex0_instr[26:30] == 5'b10100);
assign ex0_is_stcx      = (rv_lq_ex0_instr[0:5] == 6'b011111) & (rv_lq_ex0_instr[26:30] == 5'b10110) &
                          ((rv_lq_ex0_instr[21:25] == 5'b10101) | (rv_lq_ex0_instr[21:25] == 5'b10110) |
                           (rv_lq_ex0_instr[21:25] == 5'b00100) | (rv_lq_ex0_instr[21:25] == 5'b00110)) ;
assign ex0_is_ldawx     = (rv_lq_ex0_instr[0:5] == 6'b011111) & (rv_lq_ex0_instr[21:30] == 10'b0011010100);
assign ex0_is_icswxdot  = (rv_lq_ex0_instr[0:5] == 6'b011111) & (rv_lq_ex0_instr[22:24] == 3'b110) & (rv_lq_ex0_instr[26:31] == 6'b101101);

//----------------------------------------------------------------------------------------------------------------------------------------
// Latch Instances
//----------------------------------------------------------------------------------------------------------------------------------------

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_gs_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[spr_msr_gs_offset:spr_msr_gs_offset + `THREADS - 1]),
   .scout(sov[spr_msr_gs_offset:spr_msr_gs_offset + `THREADS - 1]),
   .din(spr_msr_gs_d),
   .dout(spr_msr_gs_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_pr_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[spr_msr_pr_offset:spr_msr_pr_offset + `THREADS - 1]),
   .scout(sov[spr_msr_pr_offset:spr_msr_pr_offset + `THREADS - 1]),
   .din(spr_msr_pr_d),
   .dout(spr_msr_pr_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_ucle_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[spr_msr_ucle_offset:spr_msr_ucle_offset + `THREADS - 1]),
   .scout(sov[spr_msr_ucle_offset:spr_msr_ucle_offset + `THREADS - 1]),
   .din(spr_msr_ucle_d),
   .dout(spr_msr_ucle_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msrp_uclep_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[spr_msrp_uclep_offset:spr_msrp_uclep_offset + `THREADS - 1]),
   .scout(sov[spr_msrp_uclep_offset:spr_msrp_uclep_offset + `THREADS - 1]),
   .din(spr_msrp_uclep_d),
   .dout(spr_msrp_uclep_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_ccr2_en_pc_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[spr_ccr2_en_pc_offset]),
   .scout(sov[spr_ccr2_en_pc_offset]),
   .din(spr_ccr2_en_pc_d),
   .dout(spr_ccr2_en_pc_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_ccr2_en_ditc_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[spr_ccr2_en_ditc_offset]),
   .scout(sov[spr_ccr2_en_ditc_offset]),
   .din(spr_ccr2_en_ditc_d),
   .dout(spr_ccr2_en_ditc_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_ccr2_en_icswx_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[spr_ccr2_en_icswx_offset]),
   .scout(sov[spr_ccr2_en_icswx_offset]),
   .din(spr_ccr2_en_icswx_d),
   .dout(spr_ccr2_en_icswx_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_vld_offset]),
   .scout(sov[ex0_vld_offset]),
   .din(ex0_vld_d),
   .dout(ex0_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_vld_offset]),
   .scout(sov[ex1_vld_offset]),
   .din(ex1_vld_d),
   .dout(ex1_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_vld_offset]),
   .scout(sov[ex2_vld_offset]),
   .din(ex2_vld_d),
   .dout(ex2_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_vld_offset]),
   .scout(sov[ex3_vld_offset]),
   .din(ex3_vld_d),
   .dout(ex3_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_vld_offset]),
   .scout(sov[ex4_vld_offset]),
   .din(ex4_vld_d),
   .dout(ex4_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_vld_offset]),
   .scout(sov[ex5_vld_offset]),
   .din(ex5_vld_d),
   .dout(ex5_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_stg_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_stg_act_offset]),
   .scout(sov[ex0_stg_act_offset]),
   .din(ex0_stg_act_d),
   .dout(ex0_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_stg_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_stg_act_offset]),
   .scout(sov[ex1_stg_act_offset]),
   .din(ex1_stg_act_d),
   .dout(ex1_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_stg_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_stg_act_offset]),
   .scout(sov[ex2_stg_act_offset]),
   .din(ex2_stg_act_d),
   .dout(ex2_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_stg_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_stg_act_offset]),
   .scout(sov[ex3_stg_act_offset]),
   .din(ex3_stg_act_d),
   .dout(ex3_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_stg_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_stg_act_offset]),
   .scout(sov[ex4_stg_act_offset]),
   .din(ex4_stg_act_d),
   .dout(ex4_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_stg_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_stg_act_offset]),
   .scout(sov[ex5_stg_act_offset]),
   .din(ex5_stg_act_d),
   .dout(ex5_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_stg_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_stg_act_offset]),
   .scout(sov[ex6_stg_act_offset]),
   .din(ex6_stg_act_d),
   .dout(ex6_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex7_stg_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex7_stg_act_offset]),
   .scout(sov[ex7_stg_act_offset]),
   .din(ex7_stg_act_d),
   .dout(ex7_stg_act_q)
);

tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex1_ucode_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex0_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_ucode_offset:ex1_ucode_offset + 2 - 1]),
   .scout(sov[ex1_ucode_offset:ex1_ucode_offset + 2 - 1]),
   .din(ex1_ucode_d),
   .dout(ex1_ucode_q)
);

tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0), .NEEDS_SRESET(1)) ex1_ucode_cnt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex0_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_ucode_cnt_offset:ex1_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
   .scout(sov[ex1_ucode_cnt_offset:ex1_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
   .din(ex1_ucode_cnt_d),
   .dout(ex1_ucode_cnt_q)
);

tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) ex1_instr_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_instr_offset:ex1_instr_offset + 32 - 1]),
   .scout(sov[ex1_instr_offset:ex1_instr_offset + 32 - 1]),
   .din(ex1_instr_d),
   .dout(ex1_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_any_load_dac_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex1_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_is_any_load_dac_offset]),
   .scout(sov[ex2_is_any_load_dac_offset]),
   .din(ex2_is_any_load_dac_d),
   .dout(ex2_is_any_load_dac_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_any_store_dac_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex1_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_is_any_store_dac_offset]),
   .scout(sov[ex2_is_any_store_dac_offset]),
   .din(ex2_is_any_store_dac_d),
   .dout(ex2_is_any_store_dac_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_dir_rd_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_dir_rd_act_offset]),
   .scout(sov[ex2_dir_rd_act_offset]),
   .din(ex2_dir_rd_act_d),
   .dout(ex2_dir_rd_act_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex0_tid_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_tid_offset:ex0_tid_offset + `THREADS - 1]),
   .scout(sov[ex0_tid_offset:ex0_tid_offset + `THREADS - 1]),
   .din(rv_lq_vld),
   .dout(ex0_tid_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex1_tid_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex0_stq2_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_tid_offset:ex1_tid_offset + `THREADS - 1]),
   .scout(sov[ex1_tid_offset:ex1_tid_offset + `THREADS - 1]),
   .din(ex0_iss_stq2_tid),
   .dout(ex1_tid_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex2_tid_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex2_stg_act_d),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_tid_offset:ex2_tid_offset + `THREADS - 1]),
   .scout(sov[ex2_tid_offset:ex2_tid_offset + `THREADS - 1]),
   .din(ex1_tid),
   .dout(ex2_tid_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_tid_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex2_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_tid_offset:ex3_tid_offset + `THREADS - 1]),
   .scout(sov[ex3_tid_offset:ex3_tid_offset + `THREADS - 1]),
   .din(ex2_tid_q),
   .dout(ex3_tid_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_tid_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_tid_offset:ex4_tid_offset + `THREADS - 1]),
   .scout(sov[ex4_tid_offset:ex4_tid_offset + `THREADS - 1]),
   .din(ex3_tid_q),
   .dout(ex4_tid_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_s1_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex0_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_s1_vld_offset]),
   .scout(sov[ex1_s1_vld_offset]),
   .din(rv_lq_ex0_s1_v),
   .dout(ex1_s1_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_s2_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex0_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_s2_vld_offset]),
   .scout(sov[ex1_s2_vld_offset]),
   .din(rv_lq_ex0_s2_v),
   .dout(ex1_s2_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_t1_we_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_t1_we_offset]),
   .scout(sov[ex1_t1_we_offset]),
   .din(ex1_t1_we_d),
   .dout(ex1_t1_we_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_t1_we_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_t1_we_offset]),
   .scout(sov[ex2_t1_we_offset]),
   .din(ex2_t1_we_d),
   .dout(ex2_t1_we_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_t1_we_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_t1_we_offset]),
   .scout(sov[ex3_t1_we_offset]),
   .din(ex3_t1_we_d),
   .dout(ex3_t1_we_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_t1_we_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_t1_we_offset]),
   .scout(sov[ex4_t1_we_offset]),
   .din(ex4_t1_we_d),
   .dout(ex4_t1_we_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_t1_we_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_t1_we_offset]),
   .scout(sov[ex5_t1_we_offset]),
   .din(ex5_t1_we_d),
   .dout(ex5_t1_we_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_t1_we_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_t1_we_offset]),
   .scout(sov[ex6_t1_we_offset]),
   .din(ex6_t1_we_d),
   .dout(ex6_t1_we_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq_xu_ex5_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq_xu_ex5_act_offset]),
   .scout(sov[lq_xu_ex5_act_offset]),
   .din(lq_xu_ex5_act_d),
   .dout(lq_xu_ex5_act_q)
);

tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) ex1_t1_wa_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex0_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_t1_wa_offset:ex1_t1_wa_offset + `GPR_POOL_ENC - 1]),
   .scout(sov[ex1_t1_wa_offset:ex1_t1_wa_offset + `GPR_POOL_ENC - 1]),
   .din(rv_lq_ex0_t1_p),
   .dout(ex1_t1_wa_q)
);

tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) ex1_t3_wa_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex0_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_t3_wa_offset:ex1_t3_wa_offset + `GPR_POOL_ENC - 1]),
   .scout(sov[ex1_t3_wa_offset:ex1_t3_wa_offset + `GPR_POOL_ENC - 1]),
   .din(rv_lq_ex0_t3_p),
   .dout(ex1_t3_wa_q)
);

tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex1_itag_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex0_stq2_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_itag_offset:ex1_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[ex1_itag_offset:ex1_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(ex0_iss_stq2_itag),
   .dout(ex1_itag_q)
);

tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex2_itag_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex1_stq3_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_itag_offset:ex2_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[ex2_itag_offset:ex2_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(ex1_itag),
   .dout(ex2_itag_q)
);

tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) release_itag_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[release_itag_offset:release_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[release_itag_offset:release_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(release_itag_d),
   .dout(release_itag_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) release_tid_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[release_tid_offset:release_tid_offset + `THREADS - 1]),
   .scout(sov[release_tid_offset:release_tid_offset + `THREADS - 1]),
   .din(release_tid_d),
   .dout(release_tid_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) release_itag_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[release_itag_vld_offset]),
   .scout(sov[release_itag_vld_offset]),
   .din(release_itag_vld_d),
   .dout(release_itag_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_needs_release_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_needs_release_offset]),
   .scout(sov[ex0_needs_release_offset]),
   .din(ex0_needs_release_d),
   .dout(ex0_needs_release_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_needs_release_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_needs_release_offset]),
   .scout(sov[ex1_needs_release_offset]),
   .din(ex1_needs_release_d),
   .dout(ex1_needs_release_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_needs_release_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_needs_release_offset]),
   .scout(sov[ex2_needs_release_offset]),
   .din(ex2_needs_release_d),
   .dout(ex2_needs_release_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_physical_upd_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_physical_upd_offset]),
   .scout(sov[ex2_physical_upd_offset]),
   .din(ex2_physical_upd_d),
   .dout(ex2_physical_upd_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_req_abort_rpt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_req_abort_rpt_offset]),
   .scout(sov[ex3_req_abort_rpt_offset]),
   .din(ex3_req_abort_rpt_d),
   .dout(ex3_req_abort_rpt_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_req_abort_rpt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_req_abort_rpt_offset]),
   .scout(sov[ex4_req_abort_rpt_offset]),
   .din(ex4_req_abort_rpt_d),
   .dout(ex4_req_abort_rpt_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_req_abort_rpt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_req_abort_rpt_offset]),
   .scout(sov[ex5_req_abort_rpt_offset]),
   .din(ex5_req_abort_rpt_d),
   .dout(ex5_req_abort_rpt_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_axu_physical_upd_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_axu_physical_upd_offset]),
   .scout(sov[ex2_axu_physical_upd_offset]),
   .din(ex2_axu_physical_upd_d),
   .dout(ex2_axu_physical_upd_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_axu_abort_rpt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_axu_abort_rpt_offset]),
   .scout(sov[ex3_axu_abort_rpt_offset]),
   .din(ex3_axu_abort_rpt_d),
   .dout(ex3_axu_abort_rpt_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_axu_abort_rpt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_axu_abort_rpt_offset]),
   .scout(sov[ex4_axu_abort_rpt_offset]),
   .din(ex4_axu_abort_rpt_d),
   .dout(ex4_axu_abort_rpt_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_axu_abort_rpt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_axu_abort_rpt_offset]),
   .scout(sov[ex5_axu_abort_rpt_offset]),
   .din(ex5_axu_abort_rpt_d),
   .dout(ex5_axu_abort_rpt_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_release_attmp_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_release_attmp_offset]),
   .scout(sov[ex1_release_attmp_offset]),
   .din(ex1_release_attmp_d),
   .dout(ex1_release_attmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq3_release_attmp_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_release_attmp_offset]),
   .scout(sov[stq3_release_attmp_offset]),
   .din(stq3_release_attmp_d),
   .dout(stq3_release_attmp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq3_needs_release_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_needs_release_offset]),
   .scout(sov[stq3_needs_release_offset]),
   .din(stq3_needs_release_d),
   .dout(stq3_needs_release_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_release_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_release_vld_offset]),
   .scout(sov[stq2_release_vld_offset]),
   .din(stq2_release_vld_d),
   .dout(stq2_release_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq3_release_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_release_vld_offset]),
   .scout(sov[stq3_release_vld_offset]),
   .din(stq3_release_vld_d),
   .dout(stq3_release_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_release_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_release_vld_offset]),
   .scout(sov[stq4_release_vld_offset]),
   .din(stq4_release_vld_d),
   .dout(stq4_release_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq5_release_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq5_release_vld_offset]),
   .scout(sov[stq5_release_vld_offset]),
   .din(stq5_release_vld_d),
   .dout(stq5_release_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq6_release_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_release_vld_offset]),
   .scout(sov[stq6_release_vld_offset]),
   .din(stq6_release_vld_d),
   .dout(stq6_release_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq7_release_vld_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq7_release_vld_offset]),
   .scout(sov[stq7_release_vld_offset]),
   .din(stq7_release_vld_d),
   .dout(stq7_release_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_lq_hold_req_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[xu_lq_hold_req_offset]),
   .scout(sov[xu_lq_hold_req_offset]),
   .din(xu_lq_hold_req_d),
   .dout(xu_lq_hold_req_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mm_hold_req_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[mm_hold_req_offset]),
   .scout(sov[mm_hold_req_offset]),
   .din(mm_hold_req_d),
   .dout(mm_hold_req_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mm_hold_done_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[mm_hold_done_offset]),
   .scout(sov[mm_hold_done_offset]),
   .din(mm_hold_done_d),
   .dout(mm_hold_done_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rv1_hold_taken_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rv1_hold_taken_offset]),
   .scout(sov[rv1_hold_taken_offset]),
   .din(rv1_hold_taken_d),
   .dout(rv1_hold_taken_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_hold_taken_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_hold_taken_offset]),
   .scout(sov[ex0_hold_taken_offset]),
   .din(ex0_hold_taken_d),
   .dout(ex0_hold_taken_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_hold_taken_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_hold_taken_offset]),
   .scout(sov[ex1_hold_taken_offset]),
   .din(ex1_hold_taken_d),
   .dout(ex1_hold_taken_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rv1_back_inv_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rv1_back_inv_offset]),
   .scout(sov[rv1_back_inv_offset]),
   .din(rv1_back_inv_d),
   .dout(rv1_back_inv_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_back_inv_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_back_inv_offset]),
   .scout(sov[ex0_back_inv_offset]),
   .din(ex0_back_inv_d),
   .dout(ex0_back_inv_q)
);

tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH-`CL_SIZE), .INIT(0), .NEEDS_SRESET(1)) ex0_back_inv_addr_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(rv1_back_inv_q),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_back_inv_addr_offset:ex0_back_inv_addr_offset + (`REAL_IFAR_WIDTH-`CL_SIZE) - 1]),
   .scout(sov[ex0_back_inv_addr_offset:ex0_back_inv_addr_offset + (`REAL_IFAR_WIDTH-`CL_SIZE) - 1]),
   .din(ex0_back_inv_addr_d),
   .dout(ex0_back_inv_addr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_selimm_addr_val_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_selimm_addr_val_offset]),
   .scout(sov[ex1_selimm_addr_val_offset]),
   .din(ex1_selimm_addr_val_d),
   .dout(ex1_selimm_addr_val_q)
);

tri_rlmreg_p #(.WIDTH((64-`CL_SIZE)), .INIT(0), .NEEDS_SRESET(1)) ex1_selimm_addr_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex0_selimm_addr_val),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_selimm_addr_offset:ex1_selimm_addr_offset + (64-`CL_SIZE) - 1]),
   .scout(sov[ex1_selimm_addr_offset:ex1_selimm_addr_offset + (64-`CL_SIZE) - 1]),
   .din(ex1_selimm_addr_d),
   .dout(ex1_selimm_addr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_arr_rd_val_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_arr_rd_val_offset]),
   .scout(sov[ex0_arr_rd_val_offset]),
   .din(ex0_arr_rd_val_d),
   .dout(ex0_arr_rd_val_q)
);

tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) ex0_arr_rd_congr_cl_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_arr_rd_congr_cl_offset:ex0_arr_rd_congr_cl_offset + 6 - 1]),
   .scout(sov[ex0_arr_rd_congr_cl_offset:ex0_arr_rd_congr_cl_offset + 6 - 1]),
   .din(ex0_arr_rd_congr_cl_d),
   .dout(ex0_arr_rd_congr_cl_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_derat_snoop_val_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_derat_snoop_val_offset]),
   .scout(sov[ex0_derat_snoop_val_offset]),
   .din(ex0_derat_snoop_val_d),
   .dout(ex0_derat_snoop_val_q)
);

tri_rlmreg_p #(.WIDTH(52), .INIT(0), .NEEDS_SRESET(1)) ex0_derat_snoop_addr_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(derat_rv1_snoop_val),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex0_derat_snoop_addr_offset:ex0_derat_snoop_addr_offset + 52 - 1]),
   .scout(sov[ex0_derat_snoop_addr_offset:ex0_derat_snoop_addr_offset + 52 - 1]),
   .din(ex0_derat_snoop_addr_d),
   .dout(ex0_derat_snoop_addr_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) iu_lq_cp_flush_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[iu_lq_cp_flush_offset:iu_lq_cp_flush_offset + `THREADS - 1]),
   .scout(sov[iu_lq_cp_flush_offset:iu_lq_cp_flush_offset + `THREADS - 1]),
   .din(iu_lq_cp_flush_d),
   .dout(iu_lq_cp_flush_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq6_mftgpr_val_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_mftgpr_val_offset]),
   .scout(sov[stq6_mftgpr_val_offset]),
   .din(stq6_mftgpr_val_d),
   .dout(stq6_mftgpr_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq7_mftgpr_val_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq7_mftgpr_val_offset]),
   .scout(sov[stq7_mftgpr_val_offset]),
   .din(stq7_mftgpr_val_d),
   .dout(stq7_mftgpr_val_q)
);

tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) stq2_release_itag_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_release_itag_offset:stq2_release_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[stq2_release_itag_offset:stq2_release_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(stq2_release_itag_d),
   .dout(stq2_release_itag_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stq2_release_tid_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_release_tid_offset:stq2_release_tid_offset + `THREADS - 1]),
   .scout(sov[stq2_release_tid_offset:stq2_release_tid_offset + `THREADS - 1]),
   .din(stq2_release_tid_d),
   .dout(stq2_release_tid_q)
);

assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
assign scan_out = sov[0];

endmodule
