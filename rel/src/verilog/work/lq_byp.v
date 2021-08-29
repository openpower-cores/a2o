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

//  Description:  LQ SFX Bypass Unit
//
//*****************************************************************************

`include "tri_a2o.vh"



module lq_byp(
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
   xu0_lq_ex3_act,
   xu0_lq_ex3_abort,
   xu0_lq_ex3_rt,
   xu0_lq_ex4_rt,
   xu0_lq_ex6_act,
   xu0_lq_ex6_rt,
   xu1_lq_ex3_act,
   xu1_lq_ex3_abort,
   xu1_lq_ex3_rt,
   lq_xu_ex5_rt,
   dec_byp_ex0_stg_act,
   dec_byp_ex1_stg_act,
   dec_byp_ex5_stg_act,
   dec_byp_ex6_stg_act,
   dec_byp_ex7_stg_act,
   dec_byp_ex1_s1_vld,
   dec_byp_ex1_s2_vld,
   dec_byp_ex1_use_imm,
   dec_byp_ex1_imm,
   dec_byp_ex1_rs1_zero,
   byp_ex2_req_aborted,
   byp_dec_ex1_s1_abort,
   byp_dec_ex1_s2_abort,
   ctl_lsq_ex4_xu1_data,
   ctl_lsq_ex6_ldh_dacrw,
   lsq_ctl_ex5_fwd_val,
   lsq_ctl_ex5_fwd_data,
   lsq_ctl_rel2_data,
   dcc_byp_rel2_stg_act,
   dcc_byp_rel3_stg_act,
   dcc_byp_ram_act,
   dcc_byp_ex4_moveOp_val,
   dcc_byp_stq6_moveOp_val,
   dcc_byp_ex4_move_data,
   dcc_byp_ex5_lq_req_abort,
   dcc_byp_ex5_byte_mask,
   dcc_byp_ex6_thrd_id,
   dcc_byp_ex6_dvc1_en,
   dcc_byp_ex6_dvc2_en,
   dcc_byp_ex6_dacr_cmpr,
   dat_ctl_ex5_load_data,
   dat_ctl_stq6_axu_data,
   dcc_byp_ram_sel,
   byp_dir_ex2_rs1,
   byp_dir_ex2_rs2,
   spr_byp_spr_dvc1_dbg,
   spr_byp_spr_dvc2_dbg,
   spr_byp_spr_dbcr2_dvc1m,
   spr_byp_spr_dbcr2_dvc1be,
   spr_byp_spr_dbcr2_dvc2m,
   spr_byp_spr_dbcr2_dvc2be,
   rv_lq_ex0_s1_xu0_sel,
   rv_lq_ex0_s2_xu0_sel,
   rv_lq_ex0_s1_xu1_sel,
   rv_lq_ex0_s2_xu1_sel,
   rv_lq_ex0_s1_lq_sel,
   rv_lq_ex0_s2_lq_sel,
   rv_lq_ex0_s1_rel_sel,
   rv_lq_ex0_s2_rel_sel,
   lq_pc_ram_data,
   rv_lq_gpr_ex1_r0d,
   rv_lq_gpr_ex1_r1d,
   lq_rv_gpr_ex6_wd,
   lq_rv_gpr_rel_wd,
   lq_xu_gpr_rel_wd,
   lq_rv_ex2_s1_abort,
   lq_rv_ex2_s2_abort
);

//-------------------------------------------------------------------
// Generics
//-------------------------------------------------------------------
//parameter                                                   EXPAND_TYPE = 2;
//parameter                                                   THREADS = 2;
//parameter                                                   `GPR_WIDTH_ENC = 6;
//parameter                                                   `STQ_DATA_SIZE = 64;		// 64 or 128 Bit store data sizes supported
//parameter                                                   `LQ_LOAD_PIPE_START = 4;
//parameter                                                   `LQ_LOAD_PIPE_END = 8;
//parameter                                                   `LQ_REL_PIPE_START = 2;
//parameter                                                   `LQ_REL_PIPE_END = 4;
//parameter                                                   XU0_PIPE_START = 2;
//parameter                                                   XU0_PIPE_END   = 12;
//parameter                                                   XU1_PIPE_START = 2;
//parameter                                                   XU1_PIPE_END   = 7;

//-------------------------------------------------------------------
// Clocks & Power
//-------------------------------------------------------------------


inout                                                       vdd;


inout                                                       gnd;

(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

input [0:`NCLK_WIDTH-1]                                     nclk;

//-------------------------------------------------------------------
// Pervasive
//-------------------------------------------------------------------
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

//-------------------------------------------------------------------
// Interface with XU
//-------------------------------------------------------------------
input                                                       xu0_lq_ex3_act;
input                                                       xu0_lq_ex3_abort;
input [64-(2**`GPR_WIDTH_ENC):63]                           xu0_lq_ex3_rt;
input [64-(2**`GPR_WIDTH_ENC):63]                           xu0_lq_ex4_rt;
input                                                       xu0_lq_ex6_act;
input [64-(2**`GPR_WIDTH_ENC):63]                           xu0_lq_ex6_rt;
input                                                       xu1_lq_ex3_act;
input                                                       xu1_lq_ex3_abort;
input [64-(2**`GPR_WIDTH_ENC):63]                           xu1_lq_ex3_rt;
output [(128-`STQ_DATA_SIZE):127]                           lq_xu_ex5_rt;

//-------------------------------------------------------------------
// Interface with DEC
//-------------------------------------------------------------------
input                                                       dec_byp_ex0_stg_act;
input                                                       dec_byp_ex1_stg_act;
input                                                       dec_byp_ex5_stg_act;
input                                                       dec_byp_ex6_stg_act;
input                                                       dec_byp_ex7_stg_act;
input                                                       dec_byp_ex1_s1_vld;
input                                                       dec_byp_ex1_s2_vld;
input                                                       dec_byp_ex1_use_imm;
input [64-(2**`GPR_WIDTH_ENC):63]                           dec_byp_ex1_imm;
input                                                       dec_byp_ex1_rs1_zero;
output                                                      byp_ex2_req_aborted;
output                                                      byp_dec_ex1_s1_abort;
output                                                      byp_dec_ex1_s2_abort;

//-------------------------------------------------------------------
// Interface with LQ Pipe
//-------------------------------------------------------------------
// Load Pipe
output [64-(2**`GPR_WIDTH_ENC):63]                          ctl_lsq_ex4_xu1_data;
output [0:3]                                                ctl_lsq_ex6_ldh_dacrw;
input                                                       lsq_ctl_ex5_fwd_val;
input [(128-`STQ_DATA_SIZE):127]                            lsq_ctl_ex5_fwd_data;
input [0:127]                                               lsq_ctl_rel2_data;
input                                                       dcc_byp_rel2_stg_act;
input                                                       dcc_byp_rel3_stg_act;
input                                                       dcc_byp_ram_act;
input                                                       dcc_byp_ex4_moveOp_val;
input                                                       dcc_byp_stq6_moveOp_val;
input [64-(2**`GPR_WIDTH_ENC):63]                           dcc_byp_ex4_move_data;
input                                                       dcc_byp_ex5_lq_req_abort;
input [0:((2**`GPR_WIDTH_ENC)/8)-1]                         dcc_byp_ex5_byte_mask;
input [0:`THREADS-1]                                        dcc_byp_ex6_thrd_id;
input                                                       dcc_byp_ex6_dvc1_en;
input                                                       dcc_byp_ex6_dvc2_en;
input [0:3]                                                 dcc_byp_ex6_dacr_cmpr;
input [(128-`STQ_DATA_SIZE):127]                            dat_ctl_ex5_load_data;
input [(128-`STQ_DATA_SIZE):127]                            dat_ctl_stq6_axu_data;
input                                                       dcc_byp_ram_sel;

output [64-(2**`GPR_WIDTH_ENC):63]                          byp_dir_ex2_rs1;
output [64-(2**`GPR_WIDTH_ENC):63]                          byp_dir_ex2_rs2;

//-------------------------------------------------------------------
// Interface with SPR's
//-------------------------------------------------------------------
input [64-(2**`GPR_WIDTH_ENC):63]                           spr_byp_spr_dvc1_dbg;
input [64-(2**`GPR_WIDTH_ENC):63]                           spr_byp_spr_dvc2_dbg;
input [0:(`THREADS*2)-1]					                spr_byp_spr_dbcr2_dvc1m;
input [0:(`THREADS*8)-1]					                spr_byp_spr_dbcr2_dvc1be;
input [0:(`THREADS*2)-1]					                spr_byp_spr_dbcr2_dvc2m;
input [0:(`THREADS*8)-1]					                spr_byp_spr_dbcr2_dvc2be;

//-------------------------------------------------------------------
// Interface with Bypass Controller
//-------------------------------------------------------------------
input [2:12]                                                rv_lq_ex0_s1_xu0_sel;
input [2:12]                                                rv_lq_ex0_s2_xu0_sel;
input [2:7]                                                 rv_lq_ex0_s1_xu1_sel;
input [2:7]                                                 rv_lq_ex0_s2_xu1_sel;
input [4:8]                                                 rv_lq_ex0_s1_lq_sel;
input [4:8]                                                 rv_lq_ex0_s2_lq_sel;
input [2:3]                                                 rv_lq_ex0_s1_rel_sel;
input [2:3]                                                 rv_lq_ex0_s2_rel_sel;

//-------------------------------------------------------------------
// Interface with PERVASIVE
//-------------------------------------------------------------------
output [64-(2**`GPR_WIDTH_ENC):63]                          lq_pc_ram_data;

//-------------------------------------------------------------------
// Interface with GPR
//-------------------------------------------------------------------
input [64-(2**`GPR_WIDTH_ENC):63]                           rv_lq_gpr_ex1_r0d;
input [64-(2**`GPR_WIDTH_ENC):63]                           rv_lq_gpr_ex1_r1d;
output [64-(2**`GPR_WIDTH_ENC):64+(((2**`GPR_WIDTH_ENC)-1)/8)] lq_rv_gpr_ex6_wd;
output [64-(2**`GPR_WIDTH_ENC):64+(((2**`GPR_WIDTH_ENC)-1)/8)] lq_rv_gpr_rel_wd;
output [(128-`STQ_DATA_SIZE):128+((`STQ_DATA_SIZE-1)/8)]    lq_xu_gpr_rel_wd;

//-------------------------------------------------------------------
// Interface with RV
//-------------------------------------------------------------------
output                                                      lq_rv_ex2_s1_abort;
output                                                      lq_rv_ex2_s2_abort;

//-------------------------------------------------------------------
// Signals
//-------------------------------------------------------------------
wire								                        tiup;
wire								                        tidn;
wire [0:4]                                                  ex1_rs1_byp_sel;
wire [1:3]                                                  ex1_rs1_abort_byp_sel;
wire [0:4]                                                  ex1_rs2_byp_sel;
wire [1:3]                                                  ex1_rs2_abort_byp_sel;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex3_xu0_rt;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex4_xu0_rt;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex5_xu0_rt;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex6_xu0_rt;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex7_xu0_rt;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex8_xu0_rt;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex3_xu1_rt;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex4_xu1_rt;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex5_xu1_rt;
wire [64-(2**`GPR_WIDTH_ENC):63]                            rel2_rel_rt;
wire                                                        ex1_s1_load_byp_val;
wire                                                        ex1_s1_load_abort_byp_val;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex1_s1_load_data;
wire                                                        ex1_s2_load_byp_val;
wire                                                        ex1_s2_load_abort_byp_val;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex1_s2_load_data;
wire                                                        ex1_s1_reload_byp_val;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex1_s1_reload_data;
wire                                                        ex1_s2_reload_byp_val;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex1_s2_reload_data;
wire                                                        ex1_s1_xu0_byp_val;
wire                                                        ex1_s1_xu0_abort_byp_val;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex1_s1_xu0_data;
wire                                                        ex1_s2_xu0_byp_val;
wire                                                        ex1_s2_xu0_abort_byp_val;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex1_s2_xu0_data;
wire                                                        ex1_s1_xu1_byp_val;
wire                                                        ex1_s1_xu1_abort_byp_val;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex1_s1_xu1_data;
wire                                                        ex1_s2_xu1_byp_val;
wire                                                        ex1_s2_xu1_abort_byp_val;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex1_s2_xu1_data;
wire                                                        ex3_xu0_stg_act;
wire                                                        ex3_xu1_stg_act;
wire                                                        ex4_move_data_sel;
wire [(128-`STQ_DATA_SIZE):127]                             ex5_load_move_data;
wire [(128-`STQ_DATA_SIZE):127]                             ex5_load_data;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex5_fx_ld_data;
wire [0:((2**`GPR_WIDTH_ENC)-1)/8]                          ex5_fx_ld_data_par;
reg  [0:1]                                                  spr_dbcr2_dvc1m;
reg  [0:1]                                                  spr_dbcr2_dvc2m;
reg  [8-(2**`GPR_WIDTH_ENC)/8:7]                            spr_dbcr2_dvc1be;
reg  [8-(2**`GPR_WIDTH_ENC)/8:7]                            spr_dbcr2_dvc2be;
wire [0:((2**`GPR_WIDTH_ENC)/8)-1]                          ex6_dvc1_cmp_d;
wire [0:((2**`GPR_WIDTH_ENC)/8)-1]                          ex6_dvc1_cmp_q;
wire [0:((2**`GPR_WIDTH_ENC)/8)-1]                          ex6_dvc2_cmp_d;
wire [0:((2**`GPR_WIDTH_ENC)/8)-1]                          ex6_dvc2_cmp_q;
wire                                                        ex6_dvc1r_cmpr;
wire                                                        ex6_dvc2r_cmpr;
wire [0:3]                                                  ex6_dacrw;
wire [0:(`STQ_DATA_SIZE-1)/8]                               rel2_data_par;
wire [64-(2**`GPR_WIDTH_ENC):64+(((2**`GPR_WIDTH_ENC)-1)/8)] rel2_rv_rel_data;
wire [(128-`STQ_DATA_SIZE):128+((`STQ_DATA_SIZE-1)/8)]      rel2_xu_rel_data;
wire [0:1]							                        spr_dbcr2_dvc1m_tid[0:`THREADS-1];
wire [0:7]							                        spr_dbcr2_dvc1be_tid[0:`THREADS-1];
wire [0:1]							                        spr_dbcr2_dvc2m_tid[0:`THREADS-1];
wire [0:7]							                        spr_dbcr2_dvc2be_tid[0:`THREADS-1];
wire                                                        ex5_lq_req_abort;
wire                                                        ex3_xu0_req_abort;
wire                                                        ex3_xu1_req_abort;
wire                                                        ex1_s1_load_abort;
wire                                                        ex1_s2_load_abort;
wire                                                        ex1_s1_xu0_abort;
wire                                                        ex1_s2_xu0_abort;
wire                                                        ex1_s1_xu1_abort;
wire                                                        ex1_s2_xu1_abort;
wire                                                        ex2_req_aborted;

//-------------------------------------------------------------------
// Latches
//-------------------------------------------------------------------
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex2_rs1_d;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex2_rs1_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex2_rs2_d;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex2_rs2_q;
wire                                                        ex1_s1_abort;
wire                                                        ex2_s1_abort_d;
wire                                                        ex2_s1_abort_q;
wire                                                        ex1_s2_abort;
wire                                                        ex2_s2_abort_d;
wire                                                        ex2_s2_abort_q;
wire [2:12]                                                 ex1_s1_xu0_sel_q;
wire [2:12]                                                 ex1_s2_xu0_sel_q;
wire [2:7]                                                  ex1_s1_xu1_sel_q;
wire [2:7]                                                  ex1_s2_xu1_sel_q;
wire [4:8]                                                  ex1_s1_lq_sel_q;
wire [4:8]                                                  ex1_s2_lq_sel_q;
wire [2:3]                                                  ex1_s1_rel_sel_q;
wire [2:3]                                                  ex1_s2_rel_sel_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex5_xu0_rt_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex6_xu0_rt_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex7_xu0_rt_d;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex7_xu0_rt_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex8_xu0_rt_q;
wire                                                        ex4_xu0_req_abort_d;
wire                                                        ex4_xu0_req_abort_q;
wire                                                        ex5_xu0_req_abort_d;
wire                                                        ex5_xu0_req_abort_q;
wire                                                        ex6_xu0_req_abort_d;
wire                                                        ex6_xu0_req_abort_q;
wire                                                        ex7_xu0_req_abort_d;
wire                                                        ex7_xu0_req_abort_q;
wire                                                        ex8_xu0_req_abort_d;
wire                                                        ex8_xu0_req_abort_q;
wire                                                        ex9_xu0_req_abort_d;
wire                                                        ex9_xu0_req_abort_q;
wire                                                        ex10_xu0_req_abort_d;
wire                                                        ex10_xu0_req_abort_q;
wire                                                        ex11_xu0_req_abort_d;
wire                                                        ex11_xu0_req_abort_q;
wire                                                        ex12_xu0_req_abort_d;
wire                                                        ex12_xu0_req_abort_q;
wire                                                        ex13_xu0_req_abort_d;
wire                                                        ex13_xu0_req_abort_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex4_xu1_rt_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex5_xu1_rt_q;
wire                                                        ex4_xu1_req_abort_d;
wire                                                        ex4_xu1_req_abort_q;
wire                                                        ex5_xu1_req_abort_d;
wire                                                        ex5_xu1_req_abort_q;
wire                                                        ex6_xu1_req_abort_d;
wire                                                        ex6_xu1_req_abort_q;
wire                                                        ex7_xu1_req_abort_d;
wire                                                        ex7_xu1_req_abort_q;
wire                                                        ex8_xu1_req_abort_d;
wire                                                        ex8_xu1_req_abort_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                            rel3_rel_rt_d;
wire [64-(2**`GPR_WIDTH_ENC):63]                            rel3_rel_rt_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                            rel4_rel_rt_d;
wire [64-(2**`GPR_WIDTH_ENC):63]                            rel4_rel_rt_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex6_fx_ld_data_d;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex6_fx_ld_data_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex7_fx_ld_data_d;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex7_fx_ld_data_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex8_fx_ld_data_d;
wire [64-(2**`GPR_WIDTH_ENC):63]                            ex8_fx_ld_data_q;
wire                                                        ex3_req_aborted_d;
wire                                                        ex3_req_aborted_q;
wire                                                        ex4_req_aborted_d;
wire                                                        ex4_req_aborted_q;
wire                                                        ex5_req_aborted_d;
wire                                                        ex5_req_aborted_q;
wire                                                        ex6_lq_req_abort_d;
wire                                                        ex6_lq_req_abort_q;
wire                                                        ex7_lq_req_abort_d;
wire                                                        ex7_lq_req_abort_q;
wire                                                        ex8_lq_req_abort_d;
wire                                                        ex8_lq_req_abort_q;
wire                                                        ex9_lq_req_abort_d;
wire                                                        ex9_lq_req_abort_q;
wire                                                        ex4_xu0_stg_act_d;
wire                                                        ex4_xu0_stg_act_q;
wire                                                        ex5_xu0_stg_act_d;
wire                                                        ex5_xu0_stg_act_q;
wire                                                        ex6_xu0_stg_act;
wire                                                        ex6_xu0_stg_act_d;
wire                                                        ex6_xu0_stg_act_q;
wire                                                        ex7_xu0_stg_act_d;
wire                                                        ex7_xu0_stg_act_q;
wire                                                        ex4_xu1_stg_act_d;
wire                                                        ex4_xu1_stg_act_q;
wire [64-(2**`GPR_WIDTH_ENC):64+(((2**`GPR_WIDTH_ENC)-1)/8)] ex6_gpr_wd0_d;
wire [64-(2**`GPR_WIDTH_ENC):64+(((2**`GPR_WIDTH_ENC)-1)/8)] ex6_gpr_wd0_q;
wire                                                        ex5_move_data_sel_d;
wire                                                        ex5_move_data_sel_q;
wire [(128-`STQ_DATA_SIZE):127]                             ex5_mv_rel_data_d;
wire [(128-`STQ_DATA_SIZE):127]                             ex5_mv_rel_data_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                            lq_pc_ram_data_d;
wire [64-(2**`GPR_WIDTH_ENC):63]                            lq_pc_ram_data_q;

//-------------------------------------------------------------------
// Scanchain
//-------------------------------------------------------------------
parameter                                                   ex2_rs1_offset = 0;
parameter                                                   ex2_rs2_offset = ex2_rs1_offset + 2**`GPR_WIDTH_ENC;
parameter                                                   ex2_s1_abort_offset = ex2_rs2_offset + 2**`GPR_WIDTH_ENC;
parameter                                                   ex2_s2_abort_offset = ex2_s1_abort_offset + 1;
parameter                                                   ex1_s1_xu0_sel_offset = ex2_s2_abort_offset + 1;
parameter                                                   ex1_s2_xu0_sel_offset = ex1_s1_xu0_sel_offset + 11;
parameter                                                   ex1_s1_xu1_sel_offset = ex1_s2_xu0_sel_offset + 11;
parameter                                                   ex1_s2_xu1_sel_offset = ex1_s1_xu1_sel_offset + 6;
parameter                                                   ex1_s1_lq_sel_offset = ex1_s2_xu1_sel_offset + 6;
parameter                                                   ex1_s2_lq_sel_offset = ex1_s1_lq_sel_offset + 5;
parameter                                                   ex1_s1_rel_sel_offset = ex1_s2_lq_sel_offset + 5;
parameter                                                   ex1_s2_rel_sel_offset = ex1_s1_rel_sel_offset + 2;
parameter                                                   ex5_xu0_rt_offset = ex1_s2_rel_sel_offset + 2;
parameter                                                   ex6_xu0_rt_offset = ex5_xu0_rt_offset + 2**`GPR_WIDTH_ENC;
parameter                                                   ex7_xu0_rt_offset = ex6_xu0_rt_offset + 2**`GPR_WIDTH_ENC;
parameter                                                   ex8_xu0_rt_offset = ex7_xu0_rt_offset + 2**`GPR_WIDTH_ENC;
parameter                                                   ex4_xu0_req_abort_offset = ex8_xu0_rt_offset + 2**`GPR_WIDTH_ENC;
parameter                                                   ex5_xu0_req_abort_offset = ex4_xu0_req_abort_offset + 1;
parameter                                                   ex6_xu0_req_abort_offset = ex5_xu0_req_abort_offset + 1;
parameter                                                   ex7_xu0_req_abort_offset = ex6_xu0_req_abort_offset + 1;
parameter                                                   ex8_xu0_req_abort_offset = ex7_xu0_req_abort_offset + 1;
parameter                                                   ex9_xu0_req_abort_offset = ex8_xu0_req_abort_offset + 1;
parameter                                                   ex10_xu0_req_abort_offset = ex9_xu0_req_abort_offset + 1;
parameter                                                   ex11_xu0_req_abort_offset = ex10_xu0_req_abort_offset + 1;
parameter                                                   ex12_xu0_req_abort_offset = ex11_xu0_req_abort_offset + 1;
parameter                                                   ex13_xu0_req_abort_offset = ex12_xu0_req_abort_offset + 1;
parameter                                                   ex4_xu1_rt_offset = ex13_xu0_req_abort_offset + 1;
parameter                                                   ex5_xu1_rt_offset = ex4_xu1_rt_offset + 2**`GPR_WIDTH_ENC;
parameter                                                   ex4_xu1_req_abort_offset = ex5_xu1_rt_offset + 2**`GPR_WIDTH_ENC;
parameter                                                   ex5_xu1_req_abort_offset = ex4_xu1_req_abort_offset + 1;
parameter                                                   ex6_xu1_req_abort_offset = ex5_xu1_req_abort_offset + 1;
parameter                                                   ex7_xu1_req_abort_offset = ex6_xu1_req_abort_offset + 1;
parameter                                                   ex8_xu1_req_abort_offset = ex7_xu1_req_abort_offset + 1;
parameter                                                   rel3_rel_rt_offset = ex8_xu1_req_abort_offset + 1;
parameter                                                   rel4_rel_rt_offset = rel3_rel_rt_offset + 2**`GPR_WIDTH_ENC;
parameter                                                   ex6_fx_ld_data_offset = rel4_rel_rt_offset + 2**`GPR_WIDTH_ENC;
parameter                                                   ex7_fx_ld_data_offset = ex6_fx_ld_data_offset + 2**`GPR_WIDTH_ENC;
parameter                                                   ex8_fx_ld_data_offset = ex7_fx_ld_data_offset + 2**`GPR_WIDTH_ENC;
parameter                                                   ex3_req_aborted_offset = ex8_fx_ld_data_offset + 2**`GPR_WIDTH_ENC;
parameter                                                   ex4_req_aborted_offset = ex3_req_aborted_offset + 1;
parameter                                                   ex5_req_aborted_offset = ex4_req_aborted_offset + 1;
parameter                                                   ex6_lq_req_abort_offset = ex5_req_aborted_offset + 1;
parameter                                                   ex7_lq_req_abort_offset = ex6_lq_req_abort_offset + 1;
parameter                                                   ex8_lq_req_abort_offset = ex7_lq_req_abort_offset + 1;
parameter                                                   ex9_lq_req_abort_offset = ex8_lq_req_abort_offset + 1;
parameter                                                   ex6_gpr_wd0_offset = ex9_lq_req_abort_offset + 1;
parameter                                                   ex5_move_data_sel_offset = ex6_gpr_wd0_offset + 2**`GPR_WIDTH_ENC + (2**`GPR_WIDTH_ENC)/8;
parameter                                                   ex5_mv_rel_data_offset = ex5_move_data_sel_offset + 1;
parameter                                                   ex6_dvc1_cmp_offset = ex5_mv_rel_data_offset + `STQ_DATA_SIZE;
parameter                                                   ex6_dvc2_cmp_offset = ex6_dvc1_cmp_offset + (2**`GPR_WIDTH_ENC)/8;
parameter                                                   lq_pc_ram_data_offset = ex6_dvc2_cmp_offset + (2**`GPR_WIDTH_ENC)/8;
parameter                                                   ex4_xu0_stg_act_offset = lq_pc_ram_data_offset + 2**`GPR_WIDTH_ENC;
parameter                                                   ex5_xu0_stg_act_offset = ex4_xu0_stg_act_offset + 1;
parameter                                                   ex6_xu0_stg_act_offset = ex5_xu0_stg_act_offset + 1;
parameter                                                   ex7_xu0_stg_act_offset = ex6_xu0_stg_act_offset + 1;
parameter                                                   ex4_xu1_stg_act_offset = ex7_xu0_stg_act_offset + 1;
parameter                                                   scan_right = ex4_xu1_stg_act_offset + 1;
wire [0:scan_right-1]                                       siv;
wire [0:scan_right-1]                                       sov;

(* analysis_not_referenced="true" *)

wire                                                        unused;

//----------------------------------------------------------------------------------------------------------------------------------------
// Misc Assignments
//----------------------------------------------------------------------------------------------------------------------------------------
assign tiup = 1'b1;
assign tidn = 1'b0;
assign ex3_xu0_rt   = xu0_lq_ex3_rt;
assign ex4_xu0_rt   = xu0_lq_ex4_rt;
assign ex5_xu0_rt   = ex5_xu0_rt_q;
assign ex6_xu0_rt   = ex6_xu0_rt_q;
assign ex7_xu0_rt_d = xu0_lq_ex6_rt;
assign ex7_xu0_rt   = ex7_xu0_rt_q;
assign ex8_xu0_rt   = ex8_xu0_rt_q;
assign ex3_xu0_req_abort    = xu0_lq_ex3_abort;
assign ex4_xu0_req_abort_d  = ex3_xu0_req_abort;
assign ex5_xu0_req_abort_d  = ex4_xu0_req_abort_q;
assign ex6_xu0_req_abort_d  = ex5_xu0_req_abort_q;
assign ex7_xu0_req_abort_d  = ex6_xu0_req_abort_q;
assign ex8_xu0_req_abort_d  = ex7_xu0_req_abort_q;
assign ex9_xu0_req_abort_d  = ex8_xu0_req_abort_q;
assign ex10_xu0_req_abort_d = ex9_xu0_req_abort_q;
assign ex11_xu0_req_abort_d = ex10_xu0_req_abort_q;
assign ex12_xu0_req_abort_d = ex11_xu0_req_abort_q;
assign ex13_xu0_req_abort_d = ex12_xu0_req_abort_q;

assign ex3_xu1_rt = xu1_lq_ex3_rt;
assign ex4_xu1_rt = ex4_xu1_rt_q;
assign ex5_xu1_rt = ex5_xu1_rt_q;
assign ex3_xu1_req_abort   = xu1_lq_ex3_abort;
assign ex4_xu1_req_abort_d = ex3_xu1_req_abort;
assign ex5_xu1_req_abort_d = ex4_xu1_req_abort_q;
assign ex6_xu1_req_abort_d = ex5_xu1_req_abort_q;
assign ex7_xu1_req_abort_d = ex6_xu1_req_abort_q;
assign ex8_xu1_req_abort_d = ex7_xu1_req_abort_q;

assign rel2_rel_rt   = lsq_ctl_rel2_data[128-(2**`GPR_WIDTH_ENC):127];
assign rel3_rel_rt_d = rel2_rel_rt;
assign rel4_rel_rt_d = rel3_rel_rt_q;

assign ex3_xu0_stg_act   = xu0_lq_ex3_act;
assign ex4_xu0_stg_act_d = ex3_xu0_stg_act;
assign ex5_xu0_stg_act_d = ex4_xu0_stg_act_q;
assign ex6_xu0_stg_act_d = ex5_xu0_stg_act_q;
assign ex6_xu0_stg_act   = xu0_lq_ex6_act | ex6_xu0_stg_act_q;
assign ex7_xu0_stg_act_d = ex6_xu0_stg_act;

assign ex3_xu1_stg_act   = xu1_lq_ex3_act;
assign ex4_xu1_stg_act_d = ex3_xu1_stg_act;

//----------------------------------------------------------------------------------------------------------------------------------------
// Load Data Muxing Update
//----------------------------------------------------------------------------------------------------------------------------------------
// Move Data contains mffgpr,mftgpr,ditc and store_updates_forms
// dcc_byp_ex4_moveOp_val is valid for the following instructions coming down the LQ Pipeline mffgpr or store_update_forms
// dcc_byp_stq6_moveOp_val is valid for the following instructions coming down the COMMIT Pipeline mftgpr, mfdpf, or mfdpa
generate
  if (`STQ_DATA_SIZE == 128) begin : stqDat128
    assign ex5_mv_rel_data_d[(128-`STQ_DATA_SIZE):127-(2**`GPR_WIDTH_ENC)] = dat_ctl_stq6_axu_data[(128-`STQ_DATA_SIZE):127-(2**`GPR_WIDTH_ENC)];
    assign ex5_mv_rel_data_d[128-(2**`GPR_WIDTH_ENC):127] = (dat_ctl_stq6_axu_data[128-(2**`GPR_WIDTH_ENC):127] & {(2**`GPR_WIDTH_ENC){dcc_byp_stq6_moveOp_val}}) |
                                                            (                             dcc_byp_ex4_move_data & {(2**`GPR_WIDTH_ENC){dcc_byp_ex4_moveOp_val}});
    assign unused = tidn;
  end
endgenerate

generate
  if (`STQ_DATA_SIZE == 64) begin : stqDat64
      if ((2 ** `GPR_WIDTH_ENC) == 64) begin : gpr64
          assign ex5_mv_rel_data_d[128 - (2 ** `GPR_WIDTH_ENC):127] = (dat_ctl_stq6_axu_data[128-(2**`GPR_WIDTH_ENC):127] & {(2**`GPR_WIDTH_ENC){dcc_byp_stq6_moveOp_val}}) |
                                                                      (                             dcc_byp_ex4_move_data & {(2**`GPR_WIDTH_ENC){dcc_byp_ex4_moveOp_val}});
      end

      if ((2 ** `GPR_WIDTH_ENC) == 32) begin : gpr32
          assign ex5_mv_rel_data_d[(128-`STQ_DATA_SIZE):127-(2**`GPR_WIDTH_ENC)] = dat_ctl_stq6_axu_data[(128-`STQ_DATA_SIZE):127-(2**`GPR_WIDTH_ENC)];
          assign ex5_mv_rel_data_d[128-(2**`GPR_WIDTH_ENC):127] = (dat_ctl_stq6_axu_data[128-(2**`GPR_WIDTH_ENC):127] & {(2**`GPR_WIDTH_ENC){dcc_byp_stq6_moveOp_val}}) |
                                                                  (                             dcc_byp_ex4_move_data & {(2**`GPR_WIDTH_ENC){dcc_byp_ex4_moveOp_val}});
      end
      assign unused = tidn | |lsq_ctl_rel2_data[0:`STQ_DATA_SIZE-1];
    end
endgenerate

assign ex4_move_data_sel = dcc_byp_ex4_moveOp_val | dcc_byp_stq6_moveOp_val;
assign ex5_move_data_sel_d = ex4_move_data_sel;

// FX Load Hit Data
// Mux Between load hit and Move Data
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Mux Between move data and load hit
assign ex5_load_move_data = (ex5_mv_rel_data_q     & {(`STQ_DATA_SIZE){ ex5_move_data_sel_q}}) |
                            (dat_ctl_ex5_load_data & {(`STQ_DATA_SIZE){~ex5_move_data_sel_q}});
// Mux Between load hit/Move Data and Data Forward
assign ex5_load_data = (lsq_ctl_ex5_fwd_data & {(`STQ_DATA_SIZE){ lsq_ctl_ex5_fwd_val}}) |
                       (ex5_load_move_data   & {(`STQ_DATA_SIZE){~lsq_ctl_ex5_fwd_val}});

// Fixed Point Data For bypass
assign lq_xu_ex5_rt       = ex5_load_data;
assign ex5_fx_ld_data     = ex5_load_data[128 - (2 ** `GPR_WIDTH_ENC):127];
assign ex6_fx_ld_data_d   = ex5_fx_ld_data;
assign ex7_fx_ld_data_d   = ex6_fx_ld_data_q;
assign ex8_fx_ld_data_d   = ex7_fx_ld_data_q;
assign ex5_lq_req_abort   = dcc_byp_ex5_lq_req_abort | ex5_req_aborted_q;
assign ex6_lq_req_abort_d = ex5_lq_req_abort;
assign ex7_lq_req_abort_d = ex6_lq_req_abort_q;
assign ex8_lq_req_abort_d = ex7_lq_req_abort_q;
assign ex9_lq_req_abort_d = ex8_lq_req_abort_q;
assign ex2_req_aborted    = ex2_s1_abort_q | ex2_s2_abort_q;
assign ex3_req_aborted_d  = ex2_req_aborted;
assign ex4_req_aborted_d  = ex3_req_aborted_q;
assign ex5_req_aborted_d  = ex4_req_aborted_q;

generate begin : ex5ParGen
    genvar b;
    for (b=0; b<=((2**`GPR_WIDTH_ENC)-1)/8; b=b+1) begin : ex5ParGen
        assign ex5_fx_ld_data_par[b] = ^(ex5_fx_ld_data[(64-(2**`GPR_WIDTH_ENC))+(b*8):(64-(2**`GPR_WIDTH_ENC))+(b*8)+7]);
    end
  end
endgenerate

assign ex6_gpr_wd0_d = {ex5_fx_ld_data, ex5_fx_ld_data_par};

//----------------------------------------------------------------------------------------------------------------------------------------
// Internal Load LQ Muxing
//----------------------------------------------------------------------------------------------------------------------------------------
// Source 1 Bypass Control
assign ex1_s1_load_byp_val = |(ex1_s1_lq_sel_q[4:7]);

assign ex1_s1_load_data = (ex5_fx_ld_data   & {(2**`GPR_WIDTH_ENC){ex1_s1_lq_sel_q[4]}}) |
                          (ex6_fx_ld_data_q & {(2**`GPR_WIDTH_ENC){ex1_s1_lq_sel_q[5]}}) |
                          (ex7_fx_ld_data_q & {(2**`GPR_WIDTH_ENC){ex1_s1_lq_sel_q[6]}}) |
                          (ex8_fx_ld_data_q & {(2**`GPR_WIDTH_ENC){ex1_s1_lq_sel_q[7]}});

assign ex1_s1_load_abort_byp_val = |(ex1_s1_lq_sel_q);

assign ex1_s1_load_abort = (ex5_lq_req_abort   & ex1_s1_lq_sel_q[4]) |
                           (ex6_lq_req_abort_q & ex1_s1_lq_sel_q[5]) |
                           (ex7_lq_req_abort_q & ex1_s1_lq_sel_q[6]) |
                           (ex8_lq_req_abort_q & ex1_s1_lq_sel_q[7]) |
                           (ex9_lq_req_abort_q & ex1_s1_lq_sel_q[8]);

// Source 2 Bypass Control
assign ex1_s2_load_byp_val = |(ex1_s2_lq_sel_q[4:7]);

assign ex1_s2_load_data = (ex5_fx_ld_data   & {(2**`GPR_WIDTH_ENC){ex1_s2_lq_sel_q[4]}}) |
                          (ex6_fx_ld_data_q & {(2**`GPR_WIDTH_ENC){ex1_s2_lq_sel_q[5]}}) |
                          (ex7_fx_ld_data_q & {(2**`GPR_WIDTH_ENC){ex1_s2_lq_sel_q[6]}}) |
                          (ex8_fx_ld_data_q & {(2**`GPR_WIDTH_ENC){ex1_s2_lq_sel_q[7]}});

assign ex1_s2_load_abort_byp_val = |(ex1_s2_lq_sel_q);

assign ex1_s2_load_abort = (ex5_lq_req_abort   & ex1_s2_lq_sel_q[4]) |
                           (ex6_lq_req_abort_q & ex1_s2_lq_sel_q[5]) |
                           (ex7_lq_req_abort_q & ex1_s2_lq_sel_q[6]) |
                           (ex8_lq_req_abort_q & ex1_s2_lq_sel_q[7]) |
                           (ex9_lq_req_abort_q & ex1_s2_lq_sel_q[8]);

//----------------------------------------------------------------------------------------------------------------------------------------
// Internal Reload LQ Muxing
//----------------------------------------------------------------------------------------------------------------------------------------
// Source 1 Bypass Control
assign ex1_s1_reload_byp_val = |(ex1_s1_rel_sel_q);

assign ex1_s1_reload_data = (rel3_rel_rt_q & {(2**`GPR_WIDTH_ENC){ex1_s1_rel_sel_q[2]}}) |
                            (rel4_rel_rt_q & {(2**`GPR_WIDTH_ENC){ex1_s1_rel_sel_q[3]}});

// Source 2 Bypass Control
assign ex1_s2_reload_byp_val = |(ex1_s2_rel_sel_q);

assign ex1_s2_reload_data = (rel3_rel_rt_q & {(2**`GPR_WIDTH_ENC){ex1_s2_rel_sel_q[2]}}) |
                            (rel4_rel_rt_q & {(2**`GPR_WIDTH_ENC){ex1_s2_rel_sel_q[3]}});

//----------------------------------------------------------------------------------------------------------------------------------------
// xu0 Muxing
//----------------------------------------------------------------------------------------------------------------------------------------
// Source 1 Bypass Control
assign ex1_s1_xu0_byp_val = |(ex1_s1_xu0_sel_q[2:7]);

assign ex1_s1_xu0_data = (ex3_xu0_rt & {(2**`GPR_WIDTH_ENC){ex1_s1_xu0_sel_q[2]}}) |
                         (ex4_xu0_rt & {(2**`GPR_WIDTH_ENC){ex1_s1_xu0_sel_q[3]}}) |
                         (ex5_xu0_rt & {(2**`GPR_WIDTH_ENC){ex1_s1_xu0_sel_q[4]}}) |
                         (ex6_xu0_rt & {(2**`GPR_WIDTH_ENC){ex1_s1_xu0_sel_q[5]}}) |
                         (ex7_xu0_rt & {(2**`GPR_WIDTH_ENC){ex1_s1_xu0_sel_q[6]}}) |
                         (ex8_xu0_rt & {(2**`GPR_WIDTH_ENC){ex1_s1_xu0_sel_q[7]}});

assign ex1_s1_xu0_abort_byp_val = |(ex1_s1_xu0_sel_q);

assign ex1_s1_xu0_abort = (ex3_xu0_req_abort    & ex1_s1_xu0_sel_q[2])  |
                          (ex4_xu0_req_abort_q  & ex1_s1_xu0_sel_q[3])  |
                          (ex5_xu0_req_abort_q  & ex1_s1_xu0_sel_q[4])  |
                          (ex6_xu0_req_abort_q  & ex1_s1_xu0_sel_q[5])  |
                          (ex7_xu0_req_abort_q  & ex1_s1_xu0_sel_q[6])  |
                          (ex8_xu0_req_abort_q  & ex1_s1_xu0_sel_q[7])  |
                          (ex9_xu0_req_abort_q  & ex1_s1_xu0_sel_q[8])  |
                          (ex10_xu0_req_abort_q & ex1_s1_xu0_sel_q[9])  |
                          (ex11_xu0_req_abort_q & ex1_s1_xu0_sel_q[10]) |
                          (ex12_xu0_req_abort_q & ex1_s1_xu0_sel_q[11]) |
                          (ex13_xu0_req_abort_q & ex1_s1_xu0_sel_q[12]);

// Source 2 Bypass Control
assign ex1_s2_xu0_byp_val = |(ex1_s2_xu0_sel_q[2:7]);

assign ex1_s2_xu0_data = (ex3_xu0_rt & {(2**`GPR_WIDTH_ENC){ex1_s2_xu0_sel_q[2]}}) |
                         (ex4_xu0_rt & {(2**`GPR_WIDTH_ENC){ex1_s2_xu0_sel_q[3]}}) |
                         (ex5_xu0_rt & {(2**`GPR_WIDTH_ENC){ex1_s2_xu0_sel_q[4]}}) |
                         (ex6_xu0_rt & {(2**`GPR_WIDTH_ENC){ex1_s2_xu0_sel_q[5]}}) |
                         (ex7_xu0_rt & {(2**`GPR_WIDTH_ENC){ex1_s2_xu0_sel_q[6]}}) |
                         (ex8_xu0_rt & {(2**`GPR_WIDTH_ENC){ex1_s2_xu0_sel_q[7]}});

assign ex1_s2_xu0_abort_byp_val = |(ex1_s2_xu0_sel_q);

assign ex1_s2_xu0_abort = (ex3_xu0_req_abort    & ex1_s2_xu0_sel_q[2])  |
                          (ex4_xu0_req_abort_q  & ex1_s2_xu0_sel_q[3])  |
                          (ex5_xu0_req_abort_q  & ex1_s2_xu0_sel_q[4])  |
                          (ex6_xu0_req_abort_q  & ex1_s2_xu0_sel_q[5])  |
                          (ex7_xu0_req_abort_q  & ex1_s2_xu0_sel_q[6])  |
                          (ex8_xu0_req_abort_q  & ex1_s2_xu0_sel_q[7])  |
                          (ex9_xu0_req_abort_q  & ex1_s2_xu0_sel_q[8])  |
                          (ex10_xu0_req_abort_q & ex1_s2_xu0_sel_q[9])  |
                          (ex11_xu0_req_abort_q & ex1_s2_xu0_sel_q[10]) |
                          (ex12_xu0_req_abort_q & ex1_s2_xu0_sel_q[11]) |
                          (ex13_xu0_req_abort_q & ex1_s2_xu0_sel_q[12]);

//----------------------------------------------------------------------------------------------------------------------------------------
// xu1 Muxing
//----------------------------------------------------------------------------------------------------------------------------------------
// Source 1 Bypass Control
assign ex1_s1_xu1_byp_val = |(ex1_s1_xu1_sel_q[2:4]);

assign ex1_s1_xu1_data = (ex3_xu1_rt & {(2**`GPR_WIDTH_ENC){ex1_s1_xu1_sel_q[2]}}) |
                         (ex4_xu1_rt & {(2**`GPR_WIDTH_ENC){ex1_s1_xu1_sel_q[3]}}) |
                         (ex5_xu1_rt & {(2**`GPR_WIDTH_ENC){ex1_s1_xu1_sel_q[4]}});

assign ex1_s1_xu1_abort_byp_val = |(ex1_s1_xu1_sel_q);

assign ex1_s1_xu1_abort = (ex3_xu1_req_abort   & ex1_s1_xu1_sel_q[2]) |
                          (ex4_xu1_req_abort_q & ex1_s1_xu1_sel_q[3]) |
                          (ex5_xu1_req_abort_q & ex1_s1_xu1_sel_q[4]) |
                          (ex6_xu1_req_abort_q & ex1_s1_xu1_sel_q[5]) |
                          (ex7_xu1_req_abort_q & ex1_s1_xu1_sel_q[6]) |
                          (ex8_xu1_req_abort_q & ex1_s1_xu1_sel_q[7]);

// Source 2 Bypass Control
assign ex1_s2_xu1_byp_val = |(ex1_s2_xu1_sel_q[2:4]);

assign ex1_s2_xu1_data = (ex3_xu1_rt & {(2**`GPR_WIDTH_ENC){ex1_s2_xu1_sel_q[2]}}) |
                         (ex4_xu1_rt & {(2**`GPR_WIDTH_ENC){ex1_s2_xu1_sel_q[3]}}) |
                         (ex5_xu1_rt & {(2**`GPR_WIDTH_ENC){ex1_s2_xu1_sel_q[4]}});

assign ex1_s2_xu1_abort_byp_val = |(ex1_s2_xu1_sel_q);

assign ex1_s2_xu1_abort = (ex3_xu1_req_abort   & ex1_s2_xu1_sel_q[2]) |
                          (ex4_xu1_req_abort_q & ex1_s2_xu1_sel_q[3]) |
                          (ex5_xu1_req_abort_q & ex1_s2_xu1_sel_q[4]) |
                          (ex6_xu1_req_abort_q & ex1_s2_xu1_sel_q[5]) |
                          (ex7_xu1_req_abort_q & ex1_s2_xu1_sel_q[6]) |
                          (ex8_xu1_req_abort_q & ex1_s2_xu1_sel_q[7]);

//----------------------------------------------------------------------------------------------------------------------------------------
// Source 1 Mux Selects
//----------------------------------------------------------------------------------------------------------------------------------------
// GPR Source 1
assign ex1_rs1_byp_sel[0] = (~(|{ex1_s1_xu0_byp_val, ex1_s1_xu1_byp_val, ex1_s1_load_byp_val, ex1_s1_reload_byp_val})) & (~dec_byp_ex1_rs1_zero);		// Use Array or use ZERO
assign ex1_rs1_byp_sel[1] = ex1_s1_xu0_byp_val    & (~dec_byp_ex1_rs1_zero);		// Use xu0 or use ZERO
assign ex1_rs1_byp_sel[2] = ex1_s1_xu1_byp_val    & (~dec_byp_ex1_rs1_zero);		// Use xu1 or use ZERO
assign ex1_rs1_byp_sel[3] = ex1_s1_load_byp_val   & (~dec_byp_ex1_rs1_zero);		// Use LQ LOAD or use ZERO
assign ex1_rs1_byp_sel[4] = ex1_s1_reload_byp_val & (~dec_byp_ex1_rs1_zero);		// Use LQ RELOAD or use ZERO

assign ex2_rs1_d = (rv_lq_gpr_ex1_r0d  & {(2**`GPR_WIDTH_ENC){ex1_rs1_byp_sel[0]}}) |
                   (ex1_s1_xu0_data    & {(2**`GPR_WIDTH_ENC){ex1_rs1_byp_sel[1]}}) |
                   (ex1_s1_xu1_data    & {(2**`GPR_WIDTH_ENC){ex1_rs1_byp_sel[2]}}) |
                   (ex1_s1_load_data   & {(2**`GPR_WIDTH_ENC){ex1_rs1_byp_sel[3]}}) |
                   (ex1_s1_reload_data & {(2**`GPR_WIDTH_ENC){ex1_rs1_byp_sel[4]}});

// Abort Bypass for Source 1
assign ex1_rs1_abort_byp_sel[1] = ex1_s1_xu0_abort_byp_val  & (~dec_byp_ex1_rs1_zero);	    // Use xu0 or use ZERO
assign ex1_rs1_abort_byp_sel[2] = ex1_s1_xu1_abort_byp_val  & (~dec_byp_ex1_rs1_zero);		// Use xu1 or use ZERO
assign ex1_rs1_abort_byp_sel[3] = ex1_s1_load_abort_byp_val & (~dec_byp_ex1_rs1_zero);		// Use LQ LOAD or use ZERO

assign ex1_s1_abort = ((ex1_s1_xu0_abort  & ex1_rs1_abort_byp_sel[1]) |
                       (ex1_s1_xu1_abort  & ex1_rs1_abort_byp_sel[2]) |
                       (ex1_s1_load_abort & ex1_rs1_abort_byp_sel[3])) & dec_byp_ex1_s1_vld;

assign ex2_s1_abort_d = ex1_s1_abort;

//----------------------------------------------------------------------------------------------------------------------------------------
// Source 2 Mux Selects
//----------------------------------------------------------------------------------------------------------------------------------------
// GPR Source 2
assign ex1_rs2_byp_sel[0] = (~(|{ex1_s2_xu0_byp_val, ex1_s2_xu1_byp_val, ex1_s2_load_byp_val, ex1_s2_reload_byp_val})) & (~dec_byp_ex1_use_imm);		// Use Array or use IMMEDIATE
assign ex1_rs2_byp_sel[1] = ex1_s2_xu0_byp_val    & (~dec_byp_ex1_use_imm);		// Use xu0 or use IMMEDIATE
assign ex1_rs2_byp_sel[2] = ex1_s2_xu1_byp_val    & (~dec_byp_ex1_use_imm);		// Use xu1 or use IMMEDIATE
assign ex1_rs2_byp_sel[3] = ex1_s2_load_byp_val   & (~dec_byp_ex1_use_imm);		// Use LQ LOAD or use IMMEDIATE
assign ex1_rs2_byp_sel[4] = ex1_s2_reload_byp_val & (~dec_byp_ex1_use_imm);		// Use LQ RELOAD or use IMMEDIATE

assign ex2_rs2_d = (rv_lq_gpr_ex1_r1d  & {(2**`GPR_WIDTH_ENC){ex1_rs2_byp_sel[0]}}) |
                   (ex1_s2_xu0_data    & {(2**`GPR_WIDTH_ENC){ex1_rs2_byp_sel[1]}}) |
                   (ex1_s2_xu1_data    & {(2**`GPR_WIDTH_ENC){ex1_rs2_byp_sel[2]}}) |
                   (ex1_s2_load_data   & {(2**`GPR_WIDTH_ENC){ex1_rs2_byp_sel[3]}}) |
                   (ex1_s2_reload_data & {(2**`GPR_WIDTH_ENC){ex1_rs2_byp_sel[4]}}) |
                   (dec_byp_ex1_imm    & {(2**`GPR_WIDTH_ENC){dec_byp_ex1_use_imm}});

// Abort Bypass for Source 2
assign ex1_rs2_abort_byp_sel[1] = ex1_s2_xu0_abort_byp_val  & (~dec_byp_ex1_use_imm);		// Use xu0 or use IMMEDIATE
assign ex1_rs2_abort_byp_sel[2] = ex1_s2_xu1_abort_byp_val  & (~dec_byp_ex1_use_imm);		// Use xu1 or use IMMEDIATE
assign ex1_rs2_abort_byp_sel[3] = ex1_s2_load_abort_byp_val & (~dec_byp_ex1_use_imm);		// Use LQ LOAD or use IMMEDIATE

assign ex1_s2_abort = ((ex1_s2_xu0_abort  & ex1_rs2_abort_byp_sel[1]) |
                       (ex1_s2_xu1_abort  & ex1_rs2_abort_byp_sel[2]) |
                       (ex1_s2_load_abort & ex1_rs2_abort_byp_sel[3])) & dec_byp_ex1_s2_vld;

assign ex2_s2_abort_d = ex1_s2_abort;

//----------------------------------------------------------------------------------------------------------------------------------------
// Load Hit Debug Data Compare
//----------------------------------------------------------------------------------------------------------------------------------------

// Load Hit Data Compare
generate begin : dvcCmpLH
  genvar t;
  for (t = 0; t <= ((2 ** `GPR_WIDTH_ENC)/8) - 1; t = t + 1) begin : dvcCmpLH
    assign ex6_dvc1_cmp_d[t] = (      ex5_fx_ld_data[(64-(2**`GPR_WIDTH_ENC))+t*8:(64-(2**`GPR_WIDTH_ENC))+((t*8)+7)] ==
 			                    spr_byp_spr_dvc1_dbg[(64-(2**`GPR_WIDTH_ENC))+t*8:(64-(2**`GPR_WIDTH_ENC))+((t*8)+7)]) & dcc_byp_ex5_byte_mask[t];
    assign ex6_dvc2_cmp_d[t] = (      ex5_fx_ld_data[(64-(2**`GPR_WIDTH_ENC))+t*8:(64-(2**`GPR_WIDTH_ENC))+((t*8)+7)] ==
 			                    spr_byp_spr_dvc2_dbg[(64-(2**`GPR_WIDTH_ENC))+t*8:(64-(2**`GPR_WIDTH_ENC))+((t*8)+7)]) & dcc_byp_ex5_byte_mask[t];
  end
end
endgenerate

// Thread Select
generate begin : sprTid
  genvar tid;
  for (tid=0; tid<`THREADS; tid=tid+1) begin : sprTid
    assign spr_dbcr2_dvc1m_tid[tid]  = spr_byp_spr_dbcr2_dvc1m[(tid*2):((tid*2)+1)];
    assign spr_dbcr2_dvc1be_tid[tid] = spr_byp_spr_dbcr2_dvc1be[tid*8:(tid*8)+7];
    assign spr_dbcr2_dvc2m_tid[tid]  = spr_byp_spr_dbcr2_dvc2m[tid*2:(tid*2)+1];
    assign spr_dbcr2_dvc2be_tid[tid] = spr_byp_spr_dbcr2_dvc2be[tid*8:(tid*8)+7];
  end
end
endgenerate

always @(*) begin: ldhTid
    reg [0:1]                                                    dvc1m;
    reg [0:1]                                                    dvc2m;
    reg [8-(2**`GPR_WIDTH_ENC)/8:7]                              dvc1be;
    reg [8-(2**`GPR_WIDTH_ENC)/8:7]                              dvc2be;

    (* analysis_not_referenced="true" *)

    integer                                                      tid;
    dvc1m = {2{1'b0}};
    dvc2m = {2{1'b0}};
    dvc1be = {((2**`GPR_WIDTH_ENC)/8){1'b0}};
    dvc2be = {((2**`GPR_WIDTH_ENC)/8){1'b0}};
    for (tid=0; tid<`THREADS; tid=tid+1) begin
      dvc1m  = (spr_dbcr2_dvc1m_tid[tid]				 & {2{dcc_byp_ex6_thrd_id[tid]}})		       | dvc1m;
      dvc2m  = (spr_dbcr2_dvc2m_tid[tid]				 & {2{dcc_byp_ex6_thrd_id[tid]}})		       | dvc2m;
      dvc1be = (spr_dbcr2_dvc1be_tid[tid][8-((2**`GPR_WIDTH_ENC)/8):7] & {((2**`GPR_WIDTH_ENC)/8){dcc_byp_ex6_thrd_id[tid]}}) | dvc1be;
      dvc2be = (spr_dbcr2_dvc2be_tid[tid][8-((2**`GPR_WIDTH_ENC)/8):7] & {((2**`GPR_WIDTH_ENC)/8){dcc_byp_ex6_thrd_id[tid]}}) | dvc2be;
    end
    spr_dbcr2_dvc1m  <= dvc1m;
    spr_dbcr2_dvc2m  <= dvc2m;
    spr_dbcr2_dvc1be <= dvc1be;
    spr_dbcr2_dvc2be <= dvc2be;
end

lq_spr_dvccmp #(.REGSIZE(2**`GPR_WIDTH_ENC)) dvc1Ldh(
  .en(dcc_byp_ex6_dvc1_en),
  .en00(dcc_byp_ex6_dacr_cmpr[0]),
  .cmp(ex6_dvc1_cmp_q),
  .dvcm(spr_dbcr2_dvc1m),
  .dvcbe(spr_dbcr2_dvc1be),
  .dvc_cmpr(ex6_dvc1r_cmpr));

lq_spr_dvccmp #(.REGSIZE(2**`GPR_WIDTH_ENC)) dvc2Ldh(
  .en(dcc_byp_ex6_dvc2_en),
  .en00(dcc_byp_ex6_dacr_cmpr[1]),
  .cmp(ex6_dvc2_cmp_q),
  .dvcm(spr_dbcr2_dvc2m),
  .dvcbe(spr_dbcr2_dvc2be),
  .dvc_cmpr(ex6_dvc2r_cmpr));

assign ex6_dacrw = {ex6_dvc1r_cmpr, ex6_dvc2r_cmpr, dcc_byp_ex6_dacr_cmpr[2:3]};

//----------------------------------------------------------------------------------------------------------------------------------------
// RAM Data Muxing
//----------------------------------------------------------------------------------------------------------------------------------------
// RAM Data Update

assign lq_pc_ram_data_d = dcc_byp_ram_sel ? lsq_ctl_rel2_data[128-(2**`GPR_WIDTH_ENC):127] : ex6_gpr_wd0_q[64-(2**`GPR_WIDTH_ENC):63];
assign lq_pc_ram_data = lq_pc_ram_data_q;

//----------------------------------------------------------------------------------------------------------------------------------------
// Reload Data Parity Generation
//----------------------------------------------------------------------------------------------------------------------------------------
generate begin : relParGen
  genvar b;
  for (b = 0; b <= (`STQ_DATA_SIZE- 1)/8; b=b+1) begin : relParGen
    assign rel2_data_par[b] = ^(lsq_ctl_rel2_data[(128-`STQ_DATA_SIZE) + b*8:((128-`STQ_DATA_SIZE))+(b*8)+7]);
  end
end
endgenerate

assign rel2_rv_rel_data = {lsq_ctl_rel2_data[128-(2**`GPR_WIDTH_ENC):127],
                           rel2_data_par[((`STQ_DATA_SIZE-1)/8)-(((2**`GPR_WIDTH_ENC)-1)/8):(`STQ_DATA_SIZE-1)/8]};
assign rel2_xu_rel_data = {lsq_ctl_rel2_data[(128-`STQ_DATA_SIZE):127], rel2_data_par};

//----------------------------------------------------------------------------------------------------------------------------------------
// Assign targets
//----------------------------------------------------------------------------------------------------------------------------------------
assign byp_dir_ex2_rs1 = ex2_rs1_q;
assign byp_dir_ex2_rs2 = ex2_rs2_q;
assign byp_ex2_req_aborted = ex2_req_aborted;
assign lq_rv_gpr_ex6_wd = ex6_gpr_wd0_q;
assign lq_rv_gpr_rel_wd = rel2_rv_rel_data;
assign lq_xu_gpr_rel_wd = rel2_xu_rel_data;
assign ctl_lsq_ex4_xu1_data = ex4_xu1_rt_q;
assign ctl_lsq_ex6_ldh_dacrw = ex6_dacrw;
assign lq_rv_ex2_s1_abort = ex2_s1_abort_q;
assign lq_rv_ex2_s2_abort = ex2_s2_abort_q;
assign byp_dec_ex1_s1_abort = ex1_s1_abort;
assign byp_dec_ex1_s2_abort = ex1_s2_abort;

//----------------------------------------------------------------------------------------------------------------------------------------
// Latches
//----------------------------------------------------------------------------------------------------------------------------------------

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) ex2_rs1_latch(
  .nclk(nclk),
  .vd(vdd),
  .gd(gnd),
  .act(dec_byp_ex1_stg_act),
  .force_t(func_slp_sl_force),
  .d_mode(d_mode_dc),
  .delay_lclkr(delay_lclkr_dc),
  .mpw1_b(mpw1_dc_b),
  .mpw2_b(mpw2_dc_b),
  .thold_b(func_slp_sl_thold_0_b),
  .sg(sg_0),
  .scin(siv[ex2_rs1_offset:ex2_rs1_offset + 2**`GPR_WIDTH_ENC - 1]),
  .scout(sov[ex2_rs1_offset:ex2_rs1_offset + 2**`GPR_WIDTH_ENC - 1]),
  .din(ex2_rs1_d),
  .dout(ex2_rs1_q));

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) ex2_rs2_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex1_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_rs2_offset:ex2_rs2_offset + 2**`GPR_WIDTH_ENC - 1]),
   .scout(sov[ex2_rs2_offset:ex2_rs2_offset + 2**`GPR_WIDTH_ENC - 1]),
   .din(ex2_rs2_d),
   .dout(ex2_rs2_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_s1_abort_latch(
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
   .scin(siv[ex2_s1_abort_offset]),
   .scout(sov[ex2_s1_abort_offset]),
   .din(ex2_s1_abort_d),
   .dout(ex2_s1_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_s2_abort_latch(
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
   .scin(siv[ex2_s2_abort_offset]),
   .scout(sov[ex2_s2_abort_offset]),
   .din(ex2_s2_abort_d),
   .dout(ex2_s2_abort_q));

tri_rlmreg_p #(.WIDTH(11), .INIT(0), .NEEDS_SRESET(1)) ex1_s1_xu0_sel_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_s1_xu0_sel_offset:ex1_s1_xu0_sel_offset + (11) - 1]),
   .scout(sov[ex1_s1_xu0_sel_offset:ex1_s1_xu0_sel_offset + (11) - 1]),
   .din(rv_lq_ex0_s1_xu0_sel),
   .dout(ex1_s1_xu0_sel_q));

tri_rlmreg_p #(.WIDTH(11), .INIT(0), .NEEDS_SRESET(1)) ex1_s2_xu0_sel_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_s2_xu0_sel_offset:ex1_s2_xu0_sel_offset + (11) - 1]),
   .scout(sov[ex1_s2_xu0_sel_offset:ex1_s2_xu0_sel_offset + (11) - 1]),
   .din(rv_lq_ex0_s2_xu0_sel),
   .dout(ex1_s2_xu0_sel_q));

tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) ex1_s1_xu1_sel_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_s1_xu1_sel_offset:ex1_s1_xu1_sel_offset + (6) - 1]),
   .scout(sov[ex1_s1_xu1_sel_offset:ex1_s1_xu1_sel_offset + (6) - 1]),
   .din(rv_lq_ex0_s1_xu1_sel),
   .dout(ex1_s1_xu1_sel_q));

tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) ex1_s2_xu1_sel_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_s2_xu1_sel_offset:ex1_s2_xu1_sel_offset + (6) - 1]),
   .scout(sov[ex1_s2_xu1_sel_offset:ex1_s2_xu1_sel_offset + (6) - 1]),
   .din(rv_lq_ex0_s2_xu1_sel),
   .dout(ex1_s2_xu1_sel_q));

tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) ex1_s1_lq_sel_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_s1_lq_sel_offset:ex1_s1_lq_sel_offset + (5) - 1]),
   .scout(sov[ex1_s1_lq_sel_offset:ex1_s1_lq_sel_offset + (5) - 1]),
   .din(rv_lq_ex0_s1_lq_sel),
   .dout(ex1_s1_lq_sel_q));

tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) ex1_s2_lq_sel_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_s2_lq_sel_offset:ex1_s2_lq_sel_offset + (5) - 1]),
   .scout(sov[ex1_s2_lq_sel_offset:ex1_s2_lq_sel_offset + (5) - 1]),
   .din(rv_lq_ex0_s2_lq_sel),
   .dout(ex1_s2_lq_sel_q));

tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex1_s1_rel_sel_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_s1_rel_sel_offset:ex1_s1_rel_sel_offset + (2) - 1]),
   .scout(sov[ex1_s1_rel_sel_offset:ex1_s1_rel_sel_offset + (2) - 1]),
   .din(rv_lq_ex0_s1_rel_sel),
   .dout(ex1_s1_rel_sel_q));

tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex1_s2_rel_sel_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_s2_rel_sel_offset:ex1_s2_rel_sel_offset + (2) - 1]),
   .scout(sov[ex1_s2_rel_sel_offset:ex1_s2_rel_sel_offset + (2) - 1]),
   .din(rv_lq_ex0_s2_rel_sel),
   .dout(ex1_s2_rel_sel_q));

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) ex5_xu0_rt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex4_xu0_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_xu0_rt_offset:ex5_xu0_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .scout(sov[ex5_xu0_rt_offset:ex5_xu0_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .din(ex4_xu0_rt),
   .dout(ex5_xu0_rt_q));

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) ex6_xu0_rt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex5_xu0_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_xu0_rt_offset:ex6_xu0_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .scout(sov[ex6_xu0_rt_offset:ex6_xu0_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .din(ex5_xu0_rt_q),
   .dout(ex6_xu0_rt_q));

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) ex7_xu0_rt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex6_xu0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex7_xu0_rt_offset:ex7_xu0_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .scout(sov[ex7_xu0_rt_offset:ex7_xu0_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .din(ex7_xu0_rt_d),
   .dout(ex7_xu0_rt_q));

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) ex8_xu0_rt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex7_xu0_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex8_xu0_rt_offset:ex8_xu0_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .scout(sov[ex8_xu0_rt_offset:ex8_xu0_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .din(ex7_xu0_rt_q),
   .dout(ex8_xu0_rt_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_xu0_req_abort_latch(
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
   .scin(siv[ex4_xu0_req_abort_offset]),
   .scout(sov[ex4_xu0_req_abort_offset]),
   .din(ex4_xu0_req_abort_d),
   .dout(ex4_xu0_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_xu0_req_abort_latch(
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
   .scin(siv[ex5_xu0_req_abort_offset]),
   .scout(sov[ex5_xu0_req_abort_offset]),
   .din(ex5_xu0_req_abort_d),
   .dout(ex5_xu0_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_xu0_req_abort_latch(
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
   .scin(siv[ex6_xu0_req_abort_offset]),
   .scout(sov[ex6_xu0_req_abort_offset]),
   .din(ex6_xu0_req_abort_d),
   .dout(ex6_xu0_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex7_xu0_req_abort_latch(
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
   .scin(siv[ex7_xu0_req_abort_offset]),
   .scout(sov[ex7_xu0_req_abort_offset]),
   .din(ex7_xu0_req_abort_d),
   .dout(ex7_xu0_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex8_xu0_req_abort_latch(
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
   .scin(siv[ex8_xu0_req_abort_offset]),
   .scout(sov[ex8_xu0_req_abort_offset]),
   .din(ex8_xu0_req_abort_d),
   .dout(ex8_xu0_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex9_xu0_req_abort_latch(
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
   .scin(siv[ex9_xu0_req_abort_offset]),
   .scout(sov[ex9_xu0_req_abort_offset]),
   .din(ex9_xu0_req_abort_d),
   .dout(ex9_xu0_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex10_xu0_req_abort_latch(
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
   .scin(siv[ex10_xu0_req_abort_offset]),
   .scout(sov[ex10_xu0_req_abort_offset]),
   .din(ex10_xu0_req_abort_d),
   .dout(ex10_xu0_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex11_xu0_req_abort_latch(
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
   .scin(siv[ex11_xu0_req_abort_offset]),
   .scout(sov[ex11_xu0_req_abort_offset]),
   .din(ex11_xu0_req_abort_d),
   .dout(ex11_xu0_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex12_xu0_req_abort_latch(
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
   .scin(siv[ex12_xu0_req_abort_offset]),
   .scout(sov[ex12_xu0_req_abort_offset]),
   .din(ex12_xu0_req_abort_d),
   .dout(ex12_xu0_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex13_xu0_req_abort_latch(
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
   .scin(siv[ex13_xu0_req_abort_offset]),
   .scout(sov[ex13_xu0_req_abort_offset]),
   .din(ex13_xu0_req_abort_d),
   .dout(ex13_xu0_req_abort_q));

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) ex4_xu1_rt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex3_xu1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_xu1_rt_offset:ex4_xu1_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .scout(sov[ex4_xu1_rt_offset:ex4_xu1_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .din(xu1_lq_ex3_rt),
   .dout(ex4_xu1_rt_q));

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) ex5_xu1_rt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex4_xu1_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_xu1_rt_offset:ex5_xu1_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .scout(sov[ex5_xu1_rt_offset:ex5_xu1_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .din(ex4_xu1_rt_q),
   .dout(ex5_xu1_rt_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_xu1_req_abort_latch(
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
   .scin(siv[ex4_xu1_req_abort_offset]),
   .scout(sov[ex4_xu1_req_abort_offset]),
   .din(ex4_xu1_req_abort_d),
   .dout(ex4_xu1_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_xu1_req_abort_latch(
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
   .scin(siv[ex5_xu1_req_abort_offset]),
   .scout(sov[ex5_xu1_req_abort_offset]),
   .din(ex5_xu1_req_abort_d),
   .dout(ex5_xu1_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_xu1_req_abort_latch(
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
   .scin(siv[ex6_xu1_req_abort_offset]),
   .scout(sov[ex6_xu1_req_abort_offset]),
   .din(ex6_xu1_req_abort_d),
   .dout(ex6_xu1_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex7_xu1_req_abort_latch(
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
   .scin(siv[ex7_xu1_req_abort_offset]),
   .scout(sov[ex7_xu1_req_abort_offset]),
   .din(ex7_xu1_req_abort_d),
   .dout(ex7_xu1_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex8_xu1_req_abort_latch(
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
   .scin(siv[ex8_xu1_req_abort_offset]),
   .scout(sov[ex8_xu1_req_abort_offset]),
   .din(ex8_xu1_req_abort_d),
   .dout(ex8_xu1_req_abort_q));

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) rel3_rel_rt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dcc_byp_rel2_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel3_rel_rt_offset:rel3_rel_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .scout(sov[rel3_rel_rt_offset:rel3_rel_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .din(rel3_rel_rt_d),
   .dout(rel3_rel_rt_q));

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) rel4_rel_rt_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dcc_byp_rel3_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel4_rel_rt_offset:rel4_rel_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .scout(sov[rel4_rel_rt_offset:rel4_rel_rt_offset + 2**`GPR_WIDTH_ENC - 1]),
   .din(rel4_rel_rt_d),
   .dout(rel4_rel_rt_q));

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) ex6_fx_ld_data_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex5_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_fx_ld_data_offset:ex6_fx_ld_data_offset + 2**`GPR_WIDTH_ENC - 1]),
   .scout(sov[ex6_fx_ld_data_offset:ex6_fx_ld_data_offset + 2**`GPR_WIDTH_ENC - 1]),
   .din(ex6_fx_ld_data_d),
   .dout(ex6_fx_ld_data_q));

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) ex7_fx_ld_data_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex6_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex7_fx_ld_data_offset:ex7_fx_ld_data_offset + 2**`GPR_WIDTH_ENC - 1]),
   .scout(sov[ex7_fx_ld_data_offset:ex7_fx_ld_data_offset + 2**`GPR_WIDTH_ENC - 1]),
   .din(ex7_fx_ld_data_d),
   .dout(ex7_fx_ld_data_q));

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) ex8_fx_ld_data_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex7_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex8_fx_ld_data_offset:ex8_fx_ld_data_offset + 2**`GPR_WIDTH_ENC - 1]),
   .scout(sov[ex8_fx_ld_data_offset:ex8_fx_ld_data_offset + 2**`GPR_WIDTH_ENC - 1]),
   .din(ex8_fx_ld_data_d),
   .dout(ex8_fx_ld_data_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_req_aborted_latch(
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
   .scin(siv[ex3_req_aborted_offset]),
   .scout(sov[ex3_req_aborted_offset]),
   .din(ex3_req_aborted_d),
   .dout(ex3_req_aborted_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_req_aborted_latch(
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
   .scin(siv[ex4_req_aborted_offset]),
   .scout(sov[ex4_req_aborted_offset]),
   .din(ex4_req_aborted_d),
   .dout(ex4_req_aborted_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_req_aborted_latch(
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
   .scin(siv[ex5_req_aborted_offset]),
   .scout(sov[ex5_req_aborted_offset]),
   .din(ex5_req_aborted_d),
   .dout(ex5_req_aborted_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_lq_req_abort_latch(
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
   .scin(siv[ex6_lq_req_abort_offset]),
   .scout(sov[ex6_lq_req_abort_offset]),
   .din(ex6_lq_req_abort_d),
   .dout(ex6_lq_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex7_lq_req_abort_latch(
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
   .scin(siv[ex7_lq_req_abort_offset]),
   .scout(sov[ex7_lq_req_abort_offset]),
   .din(ex7_lq_req_abort_d),
   .dout(ex7_lq_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex8_lq_req_abort_latch(
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
   .scin(siv[ex8_lq_req_abort_offset]),
   .scout(sov[ex8_lq_req_abort_offset]),
   .din(ex8_lq_req_abort_d),
   .dout(ex8_lq_req_abort_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex9_lq_req_abort_latch(
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
   .scin(siv[ex9_lq_req_abort_offset]),
   .scout(sov[ex9_lq_req_abort_offset]),
   .din(ex9_lq_req_abort_d),
   .dout(ex9_lq_req_abort_q));

tri_rlmreg_p #(.WIDTH((2**`GPR_WIDTH_ENC)+(2**`GPR_WIDTH_ENC)/8), .INIT(0), .NEEDS_SRESET(1)) ex6_gpr_wd0_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex5_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_gpr_wd0_offset:ex6_gpr_wd0_offset + (2**`GPR_WIDTH_ENC)+(2**`GPR_WIDTH_ENC)/8 - 1]),
   .scout(sov[ex6_gpr_wd0_offset:ex6_gpr_wd0_offset + (2**`GPR_WIDTH_ENC)+(2**`GPR_WIDTH_ENC)/8 - 1]),
   .din(ex6_gpr_wd0_d),
   .dout(ex6_gpr_wd0_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_move_data_sel_latch(
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
   .scin(siv[ex5_move_data_sel_offset]),
   .scout(sov[ex5_move_data_sel_offset]),
   .din(ex5_move_data_sel_d),
   .dout(ex5_move_data_sel_q));

tri_rlmreg_p #(.WIDTH(`STQ_DATA_SIZE), .INIT(0), .NEEDS_SRESET(1)) ex5_mv_rel_data_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(ex4_move_data_sel),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_mv_rel_data_offset:ex5_mv_rel_data_offset + `STQ_DATA_SIZE - 1]),
   .scout(sov[ex5_mv_rel_data_offset:ex5_mv_rel_data_offset + `STQ_DATA_SIZE - 1]),
   .din(ex5_mv_rel_data_d),
   .dout(ex5_mv_rel_data_q));

tri_rlmreg_p #(.WIDTH((2**`GPR_WIDTH_ENC)/8), .INIT(0), .NEEDS_SRESET(1)) ex6_dvc1_cmp_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex5_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_dvc1_cmp_offset:ex6_dvc1_cmp_offset + (2**`GPR_WIDTH_ENC)/8 - 1]),
   .scout(sov[ex6_dvc1_cmp_offset:ex6_dvc1_cmp_offset + (2**`GPR_WIDTH_ENC)/8 - 1]),
   .din(ex6_dvc1_cmp_d),
   .dout(ex6_dvc1_cmp_q));

tri_rlmreg_p #(.WIDTH((2**`GPR_WIDTH_ENC)/8), .INIT(0), .NEEDS_SRESET(1)) ex6_dvc2_cmp_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dec_byp_ex5_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_dvc2_cmp_offset:ex6_dvc2_cmp_offset + (2**`GPR_WIDTH_ENC)/8 - 1]),
   .scout(sov[ex6_dvc2_cmp_offset:ex6_dvc2_cmp_offset + (2**`GPR_WIDTH_ENC)/8 - 1]),
   .din(ex6_dvc2_cmp_d),
   .dout(ex6_dvc2_cmp_q));

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) lq_pc_ram_data_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(dcc_byp_ram_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq_pc_ram_data_offset:lq_pc_ram_data_offset + 2**`GPR_WIDTH_ENC - 1]),
   .scout(sov[lq_pc_ram_data_offset:lq_pc_ram_data_offset + 2**`GPR_WIDTH_ENC - 1]),
   .din(lq_pc_ram_data_d),
   .dout(lq_pc_ram_data_q));

//------------------------------------
//              ACTs
//------------------------------------

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_xu0_stg_act_latch(
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
   .scin(siv[ex4_xu0_stg_act_offset]),
   .scout(sov[ex4_xu0_stg_act_offset]),
   .din(ex4_xu0_stg_act_d),
   .dout(ex4_xu0_stg_act_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_xu0_stg_act_latch(
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
   .scin(siv[ex5_xu0_stg_act_offset]),
   .scout(sov[ex5_xu0_stg_act_offset]),
   .din(ex5_xu0_stg_act_d),
   .dout(ex5_xu0_stg_act_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_xu0_stg_act_latch(
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
   .scin(siv[ex6_xu0_stg_act_offset]),
   .scout(sov[ex6_xu0_stg_act_offset]),
   .din(ex6_xu0_stg_act_d),
   .dout(ex6_xu0_stg_act_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex7_xu0_stg_act_latch(
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
   .scin(siv[ex7_xu0_stg_act_offset]),
   .scout(sov[ex7_xu0_stg_act_offset]),
   .din(ex7_xu0_stg_act_d),
   .dout(ex7_xu0_stg_act_q));

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_xu1_stg_act_latch(
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
   .scin(siv[ex4_xu1_stg_act_offset]),
   .scout(sov[ex4_xu1_stg_act_offset]),
   .din(ex4_xu1_stg_act_d),
   .dout(ex4_xu1_stg_act_q));

assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
assign scan_out = sov[0];

endmodule
