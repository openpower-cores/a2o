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

`include "tri_a2o.vh"
module xu1_byp(
   //-------------------------------------------------------------------
   // Clocks & Power
   //-------------------------------------------------------------------
   input [0:`NCLK_WIDTH-1]                nclk,
   inout                                  vdd,
   inout                                  gnd,

   //-------------------------------------------------------------------
   // Pervasive
   //-------------------------------------------------------------------
   input                                  d_mode_dc,
   input [0:0]                            delay_lclkr_dc,
   input [0:0]                            mpw1_dc_b,
   input                                  mpw2_dc_b,
   input                                  func_sl_force,
   input                                  func_sl_thold_0_b,
   input                                  sg_0,
   input                                  scan_in,
   output                                 scan_out,

   //-------------------------------------------------------------------
   // Decode Interface
   //-------------------------------------------------------------------
   input                                  dec_byp_ex0_act,
   input                                  xu0_xu1_ex3_act,
   input                                  lq_xu_ex5_act,

   input [64-`GPR_WIDTH:63]               dec_byp_ex1_imm,

   input [0:`THREADS-1]                   dec_byp_ex2_tid,
   input [(64-`GPR_WIDTH)/8:7]            dec_byp_ex2_dvc_mask,
   input [24:25]                          dec_byp_ex1_instr,

   input                                  dec_byp_ex0_rs2_sel_imm,
   input                                  dec_byp_ex0_rs1_sel_zero,

   //-------------------------------------------------------------------
   // RV
   //-------------------------------------------------------------------
   input                                  rv_xu1_s1_v,
   input                                  rv_xu1_s2_v,
   input                                  rv_xu1_s3_v,

   //-------------------------------------------------------------------
   // Interface with Bypass Controller
   //-------------------------------------------------------------------
   input [1:11]                           rv_xu1_s1_fxu0_sel,
   input [1:11]                           rv_xu1_s2_fxu0_sel,
   input [2:11]                           rv_xu1_s3_fxu0_sel,
   input [1:6]                            rv_xu1_s1_fxu1_sel,
   input [1:6]                            rv_xu1_s2_fxu1_sel,
   input [2:6]                            rv_xu1_s3_fxu1_sel,
   input [4:8]                            rv_xu1_s1_lq_sel,
   input [4:8]                            rv_xu1_s2_lq_sel,
   input [4:8]                            rv_xu1_s3_lq_sel,
   input [2:3]                            rv_xu1_s1_rel_sel,
   input [2:3]                            rv_xu1_s2_rel_sel,

   //-------------------------------------------------------------------
   // Bypass Inputs
   //-------------------------------------------------------------------
   // Regfile Data
   input [64-`GPR_WIDTH:63]               gpr_xu1_ex1_r1d,
   input [64-`GPR_WIDTH:63]               gpr_xu1_ex1_r2d,
   input [0:9]                            xer_xu1_ex1_r3d,
   input [0:3]                            cr_xu1_ex1_r3d,

   // External Bypass
   input                                  xu0_xu1_ex2_abort,
   input                                  xu0_xu1_ex6_abort,
   input [64-`GPR_WIDTH:63]               xu0_xu1_ex2_rt,
   input [64-`GPR_WIDTH:63]               xu0_xu1_ex3_rt,
   input [64-`GPR_WIDTH:63]               xu0_xu1_ex4_rt,
   input [64-`GPR_WIDTH:63]               xu0_xu1_ex5_rt,
   input [64-`GPR_WIDTH:63]               xu0_xu1_ex6_rt,
   input [64-`GPR_WIDTH:63]               xu0_xu1_ex7_rt,
   input [64-`GPR_WIDTH:63]               xu0_xu1_ex8_rt,
   input [64-`GPR_WIDTH:63]               xu0_xu1_ex6_lq_rt,
   input [64-`GPR_WIDTH:63]               xu0_xu1_ex7_lq_rt,
   input [64-`GPR_WIDTH:63]               xu0_xu1_ex8_lq_rt,

   input                                  lq_xu_ex5_abort,
   input [64-`GPR_WIDTH:63]               lq_xu_ex5_rt,
   input [64-`GPR_WIDTH:63]               lq_xu_rel_rt,
   input                                  lq_xu_rel_act,

   // CR
   input [0:3]                            lq_xu_ex5_cr,
   input [0:3]                            xu0_xu1_ex3_cr,
   input [0:3]                            xu0_xu1_ex4_cr,
   input [0:3]                            xu0_xu1_ex6_cr,
   // XER
   input [0:9]                            xu0_xu1_ex3_xer,
   input [0:9]                            xu0_xu1_ex4_xer,
   input [0:9]                            xu0_xu1_ex6_xer,

   // Internal Bypass
   input [64-`GPR_WIDTH:63]               alu_byp_ex2_add_rt,
   input [64-`GPR_WIDTH:63]               alu_byp_ex3_rt,
   // CR
   input [0:3]                            alu_byp_ex3_cr,
   // XER
   input [0:9]                            alu_byp_ex3_xer,

   //-------------------------------------------------------------------
   // Bypass Outputs
   //-------------------------------------------------------------------
   output                                 xu1_xu0_ex2_abort,
   output                                 xu1_lq_ex3_abort,
   output [64-`GPR_WIDTH:63]              xu1_xu0_ex2_rt,
   output [64-`GPR_WIDTH:63]              xu1_xu0_ex3_rt,
   output [64-`GPR_WIDTH:63]              xu1_xu0_ex4_rt,
   output [64-`GPR_WIDTH:63]              xu1_xu0_ex5_rt,
   output [64-`GPR_WIDTH:63]              xu1_lq_ex3_rt,
   output [64-`GPR_WIDTH:63]              xu1_pc_ram_data,

   // CR
   output [0:3]                           xu1_xu0_ex3_cr,

   // XER
   output [0:9]                           xu1_xu0_ex3_xer,

   //-------------------------------------------------------------------
   // Source Outputs
   //-------------------------------------------------------------------
   output [64-`GPR_WIDTH:63]              byp_alu_ex2_rs1,		// Source Data
   output [64-`GPR_WIDTH:63]              byp_alu_ex2_rs2,

   output                                 byp_alu_ex2_cr_bit,		// CR bit for isel
   output [0:9]                           byp_alu_ex2_xer,
   output [3:9]                           byp_dec_ex2_xer,

   output [3:9]                           xu_iu_ucode_xer,

   output                                 xu1_rv_ex2_s1_abort,
   output                                 xu1_rv_ex2_s2_abort,
   output                                 xu1_rv_ex2_s3_abort,
   output                                 byp_dec_ex2_abort,

   //-------------------------------------------------------------------
   // Target Outputs
   //-------------------------------------------------------------------
   output [64-`GPR_WIDTH:65+`GPR_WIDTH/8] xu1_gpr_ex3_wd,
   output [0:9]                           xu1_xer_ex3_w0d,
   output [0:3]                           xu1_cr_ex3_w0d,

   output [(64-`GPR_WIDTH)/8:7]           xu1_lq_ex2_stq_dvc1_cmp,
   output [(64-`GPR_WIDTH)/8:7]           xu1_lq_ex2_stq_dvc2_cmp,
   //-------------------------------------------------------------------
   // SPR
   //-------------------------------------------------------------------
   `ifndef THREADS1
   input [64-`GPR_WIDTH:63]               spr_dvc1_t1,
   input [64-`GPR_WIDTH:63]               spr_dvc2_t1,
   `endif
   input [64-`GPR_WIDTH:63]               spr_dvc1_t0,
   input [64-`GPR_WIDTH:63]               spr_dvc2_t0
);

   localparam                    DEX0 = 0;
   localparam                    DEX1 = 0;
   localparam                    DEX2 = 0;
   localparam                    DEX3 = 0;
   localparam                    DEX4 = 0;
   localparam                    DEX5 = 0;
   localparam                    DEX6 = 0;
   localparam                    DWR = 0;
   localparam                    DX = 0;
   // Latches
	wire [4:7]                    exx_xu0_act_q,             exx_xu0_act_d               ; //  input=>exx_xu0_act_d                   ,act=>1'b1
	wire [1:6]                    exx_xu1_act_q,             exx_xu1_act_d               ; //  input=>exx_xu1_act_d                   ,act=>1'b1
	wire [6:8]                    exx_lq_act_q,              exx_lq_act_d                ; //  input=>exx_lq_act_d                    ,act=>1'b1
   wire                          ex0_s1_v_q                                             ; //  input=>rv_xu1_s1_v                     ,act=>1'b1
   wire                          ex0_s2_v_q                                             ; //  input=>rv_xu1_s2_v                     ,act=>1'b1
   wire                          ex0_s3_v_q                                             ; //  input=>rv_xu1_s3_v                     ,act=>1'b1
   wire                          ex1_s1_v_q                                             ; //  input=>ex0_s1_v_q                      ,act=>1'b1
   wire                          ex1_s2_v_q                                             ; //  input=>ex0_s2_v_q                      ,act=>1'b1
   wire                          ex1_s3_v_q                                             ; //  input=>ex0_s3_v_q                      ,act=>1'b1
	wire [0:7]                    ex1_gpr_s1_xu0_sel_q[2:8]                              ; //  input=>{8{ex0_gpr_s1_xu0_sel[i-1]}}    ,act=>exx_xu1_act[0]
	wire [0:7]                    ex1_gpr_s2_xu0_sel_q[2:8]                              ; //  input=>{8{ex0_gpr_s2_xu0_sel[i-1]}}    ,act=>exx_xu1_act[0]
	wire [0:7]                    ex1_gpr_s1_xu1_sel_q[2:5]                              ; //  input=>{8{ex0_gpr_s1_xu1_sel[i-1]}}    ,act=>exx_xu1_act[0]
	wire [0:7]                    ex1_gpr_s2_xu1_sel_q[2:5]                              ; //  input=>{8{ex0_gpr_s2_xu1_sel[i-1]}}    ,act=>exx_xu1_act[0]
	wire [0:7]                    ex1_gpr_s1_lq_sel_q[5:8]                               ; //  input=>{8{ex0_gpr_s1_lq_sel[i-1]}}     ,act=>exx_xu1_act[0]
	wire [0:7]                    ex1_gpr_s2_lq_sel_q[5:8]                               ; //  input=>{8{ex0_gpr_s2_lq_sel[i-1]}}     ,act=>exx_xu1_act[0]
	wire [0:7]                    ex1_gpr_s2_imm_sel_q                                   ; //  input=>{8{dec_byp_ex0_rs2_sel_imm}}    ,act=>exx_xu1_act[0]
	wire [0:0]                    ex1_spr_s3_xu0_sel_q[3:8]                              ; //  input=>rv_xu1_s3_fxu0_sel[i-1]         ,act=>exx_xu1_act[0]
	wire [0:0]                    ex1_spr_s3_xu1_sel_q[3:5]                              ; //  input=>rv_xu1_s3_fxu1_sel[i-1]         ,act=>exx_xu1_act[0]
	wire [0:0]                    ex1_spr_s3_lq_sel_q[5:6]                               ; //  input=>rv_xu1_s3_lq_sel[i-1]           ,act=>exx_xu1_act[0]
	wire [0:7]                    ex1_gpr_s1_rel_sel_q[3:4]                              ; //  input=>{8{ex0_gpr_s1_rel_sel[i-1]}}    ,act=>exx_xu1_act[0]
	wire [0:7]                    ex1_gpr_s2_rel_sel_q[3:4]                              ; //  input=>{8{ex0_gpr_s2_rel_sel[i-1]}}    ,act=>exx_xu1_act[0]
	wire [0:7]                    ex1_gpr_s1_reg_sel_q                                   ; //  input=>{8{ex0_gpr_s1_reg_sel}}         ,act=>exx_xu1_act[0]
	wire [0:7]                    ex1_gpr_s2_reg_sel_q                                   ; //  input=>{8{ex0_gpr_s2_reg_sel}}         ,act=>exx_xu1_act[0]
	wire [0:1]                    ex1_spr_s3_reg_sel_q                                   ; //  input=>{2{ex0_spr_s3_reg_sel}}         ,act=>exx_xu1_act[0]
   wire [9:9]                    ex1_abt_s1_lq_sel_q                                    ; //  input=>ex0_gpr_s1_lq_sel[8]            ,act=>exx_xu1_act[0]
   wire [9:9]                    ex1_abt_s2_lq_sel_q                                    ; //  input=>ex0_gpr_s2_lq_sel[8]            ,act=>exx_xu1_act[0]
   wire [7:9]                    ex1_abt_s3_lq_sel_q                                    ; //  input=>rv_xu1_s3_lq_sel[6:8]           ,act=>exx_xu1_act[0]
	wire [6:7]                    ex1_abt_s1_xu1_sel_q                                   ; //  input=>ex0_gpr_s1_xu1_sel[5:6]         ,act=>exx_xu1_act[0]
	wire [6:7]                    ex1_abt_s2_xu1_sel_q                                   ; //  input=>ex0_gpr_s2_xu1_sel[5:6]         ,act=>exx_xu1_act[0]
	wire [6:7]                    ex1_abt_s3_xu1_sel_q                                   ; //  input=>rv_xu1_s3_fxu1_sel[5:6]         ,act=>exx_xu1_act[0]
	wire [9:12]                   ex1_abt_s1_xu0_sel_q                                   ; //  input=>ex0_gpr_s1_xu0_sel[8:11]        ,act=>exx_xu1_act[0]
	wire [9:12]                   ex1_abt_s2_xu0_sel_q                                   ; //  input=>ex0_gpr_s2_xu0_sel[8:11]        ,act=>exx_xu1_act[0]
	wire [9:12]                   ex1_abt_s3_xu0_sel_q                                   ; //  input=>rv_xu1_s3_fxu0_sel[8:11]        ,act=>exx_xu1_act[0]
	wire [64-`GPR_WIDTH:63]       ex4_xu1_rt_q                                           ; //  input=>alu_byp_ex3_rt                  ,act=>exx_xu1_act[3]
	wire [64-`GPR_WIDTH:63]       ex5_xu1_rt_q                                           ; //  input=>ex4_xu1_rt_q                    ,act=>exx_xu1_act[4]
	wire [0:3]                    ex5_xu0_cr_q                                           ; //  input=>xu0_xu1_ex4_cr                  ,act=>exx_xu0_act[4]
//	wire [0:3]                    ex6_xu0_cr_q                                           ; //  input=>ex5_xu0_cr_q                    ,act=>exx_xu0_act[5]
	wire [0:3]                    ex6_lq_cr_q                                            ; //  input=>lq_xu_ex5_cr                    ,act=>exx_lq_act[5]
	wire [0:9]                    ex5_xu0_xer_q                                          ; //  input=>xu0_xu1_ex4_xer                 ,act=>exx_xu0_act[4]
//	wire [0:9]                    ex6_xu0_xer_q                                          ; //  input=>ex5_xu0_xer_q                   ,act=>exx_xu0_act[5]
	wire [64-`GPR_WIDTH:63]       ex2_rs1_q,                 ex1_rs1                     ; //  input=>ex1_rs1                         ,act=>exx_xu1_act[1]
	wire [64-`GPR_WIDTH:63]       ex2_rs2_q,                 ex1_rs2                     ; //  input=>ex1_rs2                         ,act=>exx_xu1_act[1]
	wire                          ex2_cr_bit_q,              ex1_cr_bit                  ; //  input=>ex1_cr_bit                      ,act=>exx_xu1_act[1]
	wire [0:9]                    ex2_xer3_q,                ex1_xer3                    ; //  input=>ex1_xer3                        ,act=>exx_xu1_act[1]
   wire [3:12]                   exx_xu0_abort_q,           exx_xu0_abort_d             ; //  input=>exx_xu0_abort_d                 ,act=>1'b1
   wire [2:7]                    exx_xu1_abort_q,           exx_xu1_abort_d             ; //  input=>exx_xu1_abort_d                 ,act=>1'b1
   wire [6:9]                    exx_lq_abort_q,            exx_lq_abort_d              ; //  input=>exx_lq_abort_d                  ,act=>1'b1
   wire                          ex2_rs1_abort_q                                        ; //  input=>ex1_rs1_abort                   ,act=>1'b1
   wire                          ex2_rs2_abort_q                                        ; //  input=>ex1_rs2_abort                   ,act=>1'b1
   wire                          ex2_rs3_abort_q                                        ; //  input=>ex1_rs3_abort                   ,act=>1'b1
   wire                          exx_rel3_act_q                                        ; //  input=>lq_xu_rel_act                   ,act=>1'b1
   wire [64-`GPR_WIDTH:63]       exx_rel3_rt_q                                         ; //  input=>lq_xu_rel_rt                    ,act=>lq_xu_rel_act
   wire [64-`GPR_WIDTH:63]       exx_rel4_rt_q                                         ; //  input=>exx_rel3_rt_q                   ,act=>exx_rel3_act_q
	localparam exx_xu0_act_offset                         = 0;
	localparam exx_xu1_act_offset                         = exx_xu0_act_offset             + 4;
	localparam exx_lq_act_offset                          = exx_xu1_act_offset             + 6;
	localparam ex0_s1_v_offset                            = exx_lq_act_offset              + 3;
	localparam ex0_s2_v_offset                            = ex0_s1_v_offset                + 1;
	localparam ex0_s3_v_offset                            = ex0_s2_v_offset                + 1;
	localparam ex1_s1_v_offset                            = ex0_s3_v_offset                + 1;
	localparam ex1_s2_v_offset                            = ex1_s1_v_offset                + 1;
	localparam ex1_s3_v_offset                            = ex1_s2_v_offset                + 1;
	localparam ex1_gpr_s1_xu0_sel_offset                  = ex1_s3_v_offset                + 1;
	localparam ex1_gpr_s2_xu0_sel_offset                  = ex1_gpr_s1_xu0_sel_offset      + 8*7;
	localparam ex1_gpr_s1_xu1_sel_offset                  = ex1_gpr_s2_xu0_sel_offset      + 8*7;
	localparam ex1_gpr_s2_xu1_sel_offset                  = ex1_gpr_s1_xu1_sel_offset      + 8*4;
	localparam ex1_gpr_s1_lq_sel_offset                   = ex1_gpr_s2_xu1_sel_offset      + 8*4;
	localparam ex1_gpr_s2_lq_sel_offset                   = ex1_gpr_s1_lq_sel_offset       + 8*4;
	localparam ex1_gpr_s2_imm_sel_offset                  = ex1_gpr_s2_lq_sel_offset       + 8*4;
	localparam ex1_spr_s3_xu0_sel_offset                  = ex1_gpr_s2_imm_sel_offset      + 8;
	localparam ex1_spr_s3_xu1_sel_offset                  = ex1_spr_s3_xu0_sel_offset      + 1*6;
	localparam ex1_spr_s3_lq_sel_offset                   = ex1_spr_s3_xu1_sel_offset      + 1*3;
	localparam ex1_gpr_s1_rel_sel_offset                  = ex1_spr_s3_lq_sel_offset       + 1*2;
	localparam ex1_gpr_s2_rel_sel_offset                  = ex1_gpr_s1_rel_sel_offset      + 8*2;
	localparam ex1_gpr_s1_reg_sel_offset                  = ex1_gpr_s2_rel_sel_offset      + 8*2;
	localparam ex1_gpr_s2_reg_sel_offset                  = ex1_gpr_s1_reg_sel_offset      + 8;
	localparam ex1_spr_s3_reg_sel_offset                  = ex1_gpr_s2_reg_sel_offset      + 8;
	localparam ex1_abt_s1_lq_sel_offset                   = ex1_spr_s3_reg_sel_offset      + 2;
	localparam ex1_abt_s2_lq_sel_offset                   = ex1_abt_s1_lq_sel_offset       + 1;
	localparam ex1_abt_s3_lq_sel_offset                   = ex1_abt_s2_lq_sel_offset       + 1;
	localparam ex1_abt_s1_xu1_sel_offset                  = ex1_abt_s3_lq_sel_offset       + 3;
	localparam ex1_abt_s2_xu1_sel_offset                  = ex1_abt_s1_xu1_sel_offset      + 2;
	localparam ex1_abt_s3_xu1_sel_offset                  = ex1_abt_s2_xu1_sel_offset      + 2;
	localparam ex1_abt_s1_xu0_sel_offset                  = ex1_abt_s3_xu1_sel_offset      + 2;
	localparam ex1_abt_s2_xu0_sel_offset                  = ex1_abt_s1_xu0_sel_offset      + 4;
	localparam ex1_abt_s3_xu0_sel_offset                  = ex1_abt_s2_xu0_sel_offset      + 4;
	localparam ex4_xu1_rt_offset                          = ex1_abt_s3_xu0_sel_offset      + 4;
	localparam ex5_xu1_rt_offset                          = ex4_xu1_rt_offset              + `GPR_WIDTH;
	localparam ex5_xu0_cr_offset                          = ex5_xu1_rt_offset              + `GPR_WIDTH;
	localparam ex6_lq_cr_offset                           = ex5_xu0_cr_offset              + 4;
	localparam ex5_xu0_xer_offset                         = ex6_lq_cr_offset               + 4;
	localparam ex2_rs1_offset                             = ex5_xu0_xer_offset             + 10;
	localparam ex2_rs2_offset                             = ex2_rs1_offset                 + `GPR_WIDTH;
	localparam ex2_cr_bit_offset                          = ex2_rs2_offset                 + `GPR_WIDTH;
	localparam ex2_xer3_offset                            = ex2_cr_bit_offset              + 1;
	localparam exx_xu0_abort_offset                       = ex2_xer3_offset                + 10;
	localparam exx_xu1_abort_offset                       = exx_xu0_abort_offset           + 10;
	localparam exx_lq_abort_offset                        = exx_xu1_abort_offset           + 6;
	localparam ex2_rs1_abort_offset                       = exx_lq_abort_offset            + 4;
	localparam ex2_rs2_abort_offset                       = ex2_rs1_abort_offset           + 1;
	localparam ex2_rs3_abort_offset                       = ex2_rs2_abort_offset           + 1;
	localparam exx_rel3_act_offset                        = ex2_rs3_abort_offset           + 1;
	localparam exx_rel3_rt_offset                         = exx_rel3_act_offset            + 1;
	localparam exx_rel4_rt_offset                         = exx_rel3_rt_offset             + `GPR_WIDTH;
   localparam scan_right                                 = exx_rel4_rt_offset             + `GPR_WIDTH;
   wire [0:scan_right-1]                   siv;
   wire [0:scan_right-1]                   sov;
   // Signals
   wire [0:6]                             exx_xu1_act;
   wire [3:7]                             exx_xu0_act;
   wire [5:8]                             exx_lq_act;
   wire [1:11]                            ex0_gpr_s1_xu0_sel;
   wire [1:11]                            ex0_gpr_s2_xu0_sel;
   wire [1:6]                             ex0_gpr_s1_xu1_sel;
   wire [1:6]                             ex0_gpr_s2_xu1_sel;
   wire [4:8]                             ex0_gpr_s1_lq_sel;
   wire [4:8]                             ex0_gpr_s2_lq_sel;
   wire [2:3]                             ex0_gpr_s1_rel_sel;
   wire [2:3]                             ex0_gpr_s2_rel_sel;
   wire                                   ex0_gpr_rs2_sel_imm_b;
   wire                                   ex0_gpr_rs1_sel_zero_b;
   wire                                   ex0_gpr_s1_reg_sel;
   wire                                   ex0_gpr_s2_reg_sel;
   wire                                   ex0_spr_s3_reg_sel;
   wire [0:3]                             ex1_cr3;
   wire [64-`GPR_WIDTH:63]                ex1_rs2_noimm;
   wire [8-`GPR_WIDTH/8:7]                ex3_parity;
   wire [8-`GPR_WIDTH/8:7]                ex2_stq_dvc1_t0_cmpr;
   wire [8-`GPR_WIDTH/8:7]                ex2_stq_dvc2_t0_cmpr;
   wire [8-`GPR_WIDTH/8:7]                ex2_stq_dvc1_t1_cmpr;
   wire [8-`GPR_WIDTH/8:7]                ex2_stq_dvc2_t1_cmpr;
   wire                                   ex1_abort;
   wire                                   ex1_rs1_abort, ex1_rs2_noimm_abort;
   wire                                   ex1_rs2_abort;
   wire                                   ex1_rs3_abort;

   (* analysis_not_referenced="<8:63>true" *)
   wire [0:63]                            tidn = 64'b0;

   //------------------------------------------------------------------------------------------
   // Zero/Immediate Logic for GPRs
   //------------------------------------------------------------------------------------------
   assign ex0_gpr_s1_xu0_sel = ex0_gpr_rs1_sel_zero_b==1'b1 ? rv_xu1_s1_fxu0_sel : tidn[1:11];
   assign ex0_gpr_s1_xu1_sel = ex0_gpr_rs1_sel_zero_b==1'b1 ? rv_xu1_s1_fxu1_sel : tidn[1:6];
   assign ex0_gpr_s1_lq_sel  = ex0_gpr_rs1_sel_zero_b==1'b1 ? rv_xu1_s1_lq_sel   : tidn[4:8];
   assign ex0_gpr_s1_rel_sel = ex0_gpr_rs1_sel_zero_b==1'b1 ? rv_xu1_s1_rel_sel  : tidn[2:3];

   assign ex0_gpr_s2_xu0_sel = rv_xu1_s2_fxu0_sel;
   assign ex0_gpr_s2_xu1_sel = rv_xu1_s2_fxu1_sel;
   assign ex0_gpr_s2_lq_sel  = rv_xu1_s2_lq_sel  ;
   assign ex0_gpr_s2_rel_sel = rv_xu1_s2_rel_sel ;

   // TEMP Hopefully fold this into rf_byp
   assign ex0_gpr_s1_reg_sel = ~|rv_xu1_s1_fxu0_sel[1:7] & ~|rv_xu1_s1_fxu1_sel[1:4] & ~|rv_xu1_s1_lq_sel[4:7] & ~|rv_xu1_s1_rel_sel & ex0_gpr_rs1_sel_zero_b;
   assign ex0_gpr_s2_reg_sel = ~|rv_xu1_s2_fxu0_sel[1:7] & ~|rv_xu1_s2_fxu1_sel[1:4] & ~|rv_xu1_s2_lq_sel[4:7] & ~|rv_xu1_s2_rel_sel;
   assign ex0_spr_s3_reg_sel = ~|rv_xu1_s3_fxu0_sel[2:5] & ~|rv_xu1_s3_fxu1_sel[2:2] & ~|rv_xu1_s3_lq_sel[4:5];

   assign ex0_gpr_rs2_sel_imm_b  = ~dec_byp_ex0_rs2_sel_imm;
   assign ex0_gpr_rs1_sel_zero_b = ~dec_byp_ex0_rs1_sel_zero;

   //------------------------------------------------------------------------------------------
   // GPR Bypass
   //------------------------------------------------------------------------------------------
   assign ex1_rs1 =  (alu_byp_ex2_add_rt     & fanout(ex1_gpr_s1_xu1_sel_q[2], `GPR_WIDTH)) |
                     (alu_byp_ex3_rt         & fanout(ex1_gpr_s1_xu1_sel_q[3], `GPR_WIDTH)) |
                     (ex4_xu1_rt_q           & fanout(ex1_gpr_s1_xu1_sel_q[4], `GPR_WIDTH)) |
                     (ex5_xu1_rt_q           & fanout(ex1_gpr_s1_xu1_sel_q[5], `GPR_WIDTH)) |
                     (xu0_xu1_ex2_rt         & fanout(ex1_gpr_s1_xu0_sel_q[2], `GPR_WIDTH)) |
                     (xu0_xu1_ex3_rt         & fanout(ex1_gpr_s1_xu0_sel_q[3], `GPR_WIDTH)) |
                     (xu0_xu1_ex4_rt         & fanout(ex1_gpr_s1_xu0_sel_q[4], `GPR_WIDTH)) |
                     (xu0_xu1_ex5_rt         & fanout(ex1_gpr_s1_xu0_sel_q[5], `GPR_WIDTH)) |
                     (xu0_xu1_ex6_rt         & fanout(ex1_gpr_s1_xu0_sel_q[6], `GPR_WIDTH)) |
                     (xu0_xu1_ex7_rt         & fanout(ex1_gpr_s1_xu0_sel_q[7], `GPR_WIDTH)) |
                     (xu0_xu1_ex8_rt         & fanout(ex1_gpr_s1_xu0_sel_q[8], `GPR_WIDTH)) |
                     (lq_xu_ex5_rt           & fanout(ex1_gpr_s1_lq_sel_q[5], `GPR_WIDTH)) |
                     (xu0_xu1_ex6_lq_rt      & fanout(ex1_gpr_s1_lq_sel_q[6], `GPR_WIDTH)) |
                     (xu0_xu1_ex7_lq_rt      & fanout(ex1_gpr_s1_lq_sel_q[7], `GPR_WIDTH)) |
                     (xu0_xu1_ex8_lq_rt      & fanout(ex1_gpr_s1_lq_sel_q[8], `GPR_WIDTH)) |
                     (exx_rel3_rt_q          & fanout(ex1_gpr_s1_rel_sel_q[3], `GPR_WIDTH)) |
                     (exx_rel4_rt_q          & fanout(ex1_gpr_s1_rel_sel_q[4], `GPR_WIDTH)) |
                     (gpr_xu1_ex1_r1d        & fanout(ex1_gpr_s1_reg_sel_q, `GPR_WIDTH));


   assign ex1_rs2 =  (dec_byp_ex1_imm        &   fanout(ex1_gpr_s2_imm_sel_q, `GPR_WIDTH)) |
                     (ex1_rs2_noimm          & (~fanout(ex1_gpr_s2_imm_sel_q, `GPR_WIDTH)));

   assign ex1_rs2_noimm =
                     (alu_byp_ex2_add_rt     & fanout(ex1_gpr_s2_xu1_sel_q[2], `GPR_WIDTH)) |
                     (alu_byp_ex3_rt         & fanout(ex1_gpr_s2_xu1_sel_q[3], `GPR_WIDTH)) |
                     (ex4_xu1_rt_q           & fanout(ex1_gpr_s2_xu1_sel_q[4], `GPR_WIDTH)) |
                     (ex5_xu1_rt_q           & fanout(ex1_gpr_s2_xu1_sel_q[5], `GPR_WIDTH)) |
                     (xu0_xu1_ex2_rt         & fanout(ex1_gpr_s2_xu0_sel_q[2], `GPR_WIDTH)) |
                     (xu0_xu1_ex3_rt         & fanout(ex1_gpr_s2_xu0_sel_q[3], `GPR_WIDTH)) |
                     (xu0_xu1_ex4_rt         & fanout(ex1_gpr_s2_xu0_sel_q[4], `GPR_WIDTH)) |
                     (xu0_xu1_ex5_rt         & fanout(ex1_gpr_s2_xu0_sel_q[5], `GPR_WIDTH)) |
                     (xu0_xu1_ex6_rt         & fanout(ex1_gpr_s2_xu0_sel_q[6], `GPR_WIDTH)) |
                     (xu0_xu1_ex7_rt         & fanout(ex1_gpr_s2_xu0_sel_q[7], `GPR_WIDTH)) |
                     (xu0_xu1_ex8_rt         & fanout(ex1_gpr_s2_xu0_sel_q[8], `GPR_WIDTH)) |
                     (lq_xu_ex5_rt           & fanout(ex1_gpr_s2_lq_sel_q[5], `GPR_WIDTH)) |
                     (xu0_xu1_ex6_lq_rt      & fanout(ex1_gpr_s2_lq_sel_q[6], `GPR_WIDTH)) |
                     (xu0_xu1_ex7_lq_rt      & fanout(ex1_gpr_s2_lq_sel_q[7], `GPR_WIDTH)) |
                     (xu0_xu1_ex8_lq_rt      & fanout(ex1_gpr_s2_lq_sel_q[8], `GPR_WIDTH)) |
                     (exx_rel3_rt_q          & fanout(ex1_gpr_s2_rel_sel_q[3], `GPR_WIDTH)) |
                     (exx_rel4_rt_q          & fanout(ex1_gpr_s2_rel_sel_q[4], `GPR_WIDTH)) |
                     (gpr_xu1_ex1_r2d        & fanout(ex1_gpr_s2_reg_sel_q, `GPR_WIDTH));



   //------------------------------------------------------------------------------------------
   // Abort Bypass
   //------------------------------------------------------------------------------------------
   assign exx_xu0_abort_d[3:6]  = {xu0_xu1_ex2_abort, exx_xu0_abort_q[3:5]};
   assign exx_xu0_abort_d[7]    = xu0_xu1_ex6_abort;
   assign exx_xu0_abort_d[8:12] = exx_xu0_abort_q[7:11];

   assign exx_xu1_abort_d = {ex1_abort, exx_xu1_abort_q[2:6]};
   assign exx_lq_abort_d  = {lq_xu_ex5_abort, exx_lq_abort_q[6:8]};

   assign ex1_abort = ex1_rs1_abort | ex1_rs2_abort | ex1_rs3_abort;

   assign ex1_rs1_abort = exx_xu1_act[1] & ex1_s1_v_q &
                    ((exx_xu1_abort_q[2]      & ex1_gpr_s1_xu1_sel_q[2][0]) |
                     (exx_xu1_abort_q[3]     & ex1_gpr_s1_xu1_sel_q[3][0]) |
                     (exx_xu1_abort_q[4]     & ex1_gpr_s1_xu1_sel_q[4][0]) |
                     (exx_xu1_abort_q[5]     & ex1_gpr_s1_xu1_sel_q[5][0]) |
                     (exx_xu1_abort_q[6]     & ex1_abt_s1_xu1_sel_q[6]) |
                     (exx_xu1_abort_q[7]     & ex1_abt_s1_xu1_sel_q[7]) |
                     (xu0_xu1_ex2_abort      & ex1_gpr_s1_xu0_sel_q[2][0]) |
                     (exx_xu0_abort_q[3]     & ex1_gpr_s1_xu0_sel_q[3][0]) |
                     (exx_xu0_abort_q[4]     & ex1_gpr_s1_xu0_sel_q[4][0]) |
                     (exx_xu0_abort_q[5]     & ex1_gpr_s1_xu0_sel_q[5][0]) |
                     (xu0_xu1_ex6_abort      & ex1_gpr_s1_xu0_sel_q[6][0]) | //mul abort
                     (exx_xu0_abort_q[7]     & ex1_gpr_s1_xu0_sel_q[7][0]) |
                     (exx_xu0_abort_q[8]     & ex1_gpr_s1_xu0_sel_q[8][0]) |
                     (exx_xu0_abort_q[9]     & ex1_abt_s1_xu0_sel_q[9]   ) |
                     (exx_xu0_abort_q[10]    & ex1_abt_s1_xu0_sel_q[10]  ) |
                     (exx_xu0_abort_q[11]    & ex1_abt_s1_xu0_sel_q[11]  ) |
                     (exx_xu0_abort_q[12]    & ex1_abt_s1_xu0_sel_q[12]  ) |
                     (lq_xu_ex5_abort        & ex1_gpr_s1_lq_sel_q[5][0]) |
                     (exx_lq_abort_q[6]      & ex1_gpr_s1_lq_sel_q[6][0]) |
                     (exx_lq_abort_q[7]      & ex1_gpr_s1_lq_sel_q[7][0]) |
                     (exx_lq_abort_q[8]      & ex1_gpr_s1_lq_sel_q[8][0]) |
                     (exx_lq_abort_q[9]      & ex1_abt_s1_lq_sel_q[9]   ));

   assign ex1_rs2_abort = exx_xu1_act[1] & ex1_s2_v_q &
                     (ex1_rs2_noimm_abort);

   assign ex1_rs2_noimm_abort =
                     (exx_xu1_abort_q[2]     &  ex1_gpr_s2_xu1_sel_q[2][0]) |
                     (exx_xu1_abort_q[3]     &  ex1_gpr_s2_xu1_sel_q[3][0]) |
                     (exx_xu1_abort_q[4]     &  ex1_gpr_s2_xu1_sel_q[4][0]) |
                     (exx_xu1_abort_q[5]     &  ex1_gpr_s2_xu1_sel_q[5][0]) |
                     (exx_xu1_abort_q[6]     &  ex1_abt_s2_xu1_sel_q[6]) |
                     (exx_xu1_abort_q[7]     &  ex1_abt_s2_xu1_sel_q[7]) |
                     (xu0_xu1_ex2_abort      &  ex1_gpr_s2_xu0_sel_q[2][0]) |
                     (exx_xu0_abort_q[3]     &  ex1_gpr_s2_xu0_sel_q[3][0]) |
                     (exx_xu0_abort_q[4]     &  ex1_gpr_s2_xu0_sel_q[4][0]) |
                     (exx_xu0_abort_q[5]     &  ex1_gpr_s2_xu0_sel_q[5][0]) |
                     (xu0_xu1_ex6_abort      &  ex1_gpr_s2_xu0_sel_q[6][0]) |
                     (exx_xu0_abort_q[7]     &  ex1_gpr_s2_xu0_sel_q[7][0]) |
                     (exx_xu0_abort_q[8]     &  ex1_gpr_s2_xu0_sel_q[8][0]) |
                     (exx_xu0_abort_q[9]     &  ex1_abt_s2_xu0_sel_q[9]   ) |
                     (exx_xu0_abort_q[10]    &  ex1_abt_s2_xu0_sel_q[10]  ) |
                     (exx_xu0_abort_q[11]    &  ex1_abt_s2_xu0_sel_q[11]  ) |
                     (exx_xu0_abort_q[12]    &  ex1_abt_s2_xu0_sel_q[12]  ) |
                     (lq_xu_ex5_abort        &  ex1_gpr_s2_lq_sel_q[5][0]) |
                     (exx_lq_abort_q[6]      &  ex1_gpr_s2_lq_sel_q[6][0]) |
                     (exx_lq_abort_q[7]      &  ex1_gpr_s2_lq_sel_q[7][0]) |
                     (exx_lq_abort_q[8]      &  ex1_gpr_s2_lq_sel_q[8][0]) |
                     (exx_lq_abort_q[9]      &  ex1_abt_s2_lq_sel_q[9]   );


   assign ex1_rs3_abort = exx_xu1_act[1] & ex1_s3_v_q &
                    ((exx_xu1_abort_q[3]     & ex1_spr_s3_xu1_sel_q[3])  |
                     (exx_xu1_abort_q[4]     & ex1_spr_s3_xu1_sel_q[4])  |
                     (exx_xu1_abort_q[5]     & ex1_spr_s3_xu1_sel_q[5])  |
                     (exx_xu1_abort_q[6]     & ex1_abt_s3_xu1_sel_q[6]) |
                     (exx_xu1_abort_q[7]     & ex1_abt_s3_xu1_sel_q[7]) |
                     (exx_xu0_abort_q[3]     & ex1_spr_s3_xu0_sel_q[3])  |
                     (exx_xu0_abort_q[4]     & ex1_spr_s3_xu0_sel_q[4])  |
                     (exx_xu0_abort_q[5]     & ex1_spr_s3_xu0_sel_q[5])  |
                     (xu0_xu1_ex6_abort      & ex1_spr_s3_xu0_sel_q[6])  |
                     (exx_xu0_abort_q[7]     & ex1_spr_s3_xu0_sel_q[7])  |
                     (exx_xu0_abort_q[8]     & ex1_spr_s3_xu0_sel_q[8])  |
                     (exx_xu0_abort_q[9]     & ex1_abt_s3_xu0_sel_q[9]   ) |
                     (exx_xu0_abort_q[10]    & ex1_abt_s3_xu0_sel_q[10]  ) |
                     (exx_xu0_abort_q[11]    & ex1_abt_s3_xu0_sel_q[11]  ) |
                     (exx_xu0_abort_q[12]    & ex1_abt_s3_xu0_sel_q[12]  ) |
                     (lq_xu_ex5_abort        & ex1_spr_s3_lq_sel_q[5])   |
                     (exx_lq_abort_q[6]      & ex1_spr_s3_lq_sel_q[6])   |
                     (exx_lq_abort_q[7]      & ex1_abt_s3_lq_sel_q[7])   |
                     (exx_lq_abort_q[8]      & ex1_abt_s3_lq_sel_q[8])   |
                     (exx_lq_abort_q[9]      & ex1_abt_s3_lq_sel_q[9])   );

   //------------------------------------------------------------------------------------------
   // CR  Bypass
   //------------------------------------------------------------------------------------------
   assign ex1_cr3 =  (alu_byp_ex3_cr         & {4{ex1_spr_s3_xu1_sel_q[3]}})  |
                     (xu0_xu1_ex3_cr         & {4{ex1_spr_s3_xu0_sel_q[3]}})  |
                     (xu0_xu1_ex4_cr         & {4{ex1_spr_s3_xu0_sel_q[4]}})  |
                     (ex5_xu0_cr_q           & {4{ex1_spr_s3_xu0_sel_q[5]}})  |
                     (xu0_xu1_ex6_cr         & {4{ex1_spr_s3_xu0_sel_q[6]}})  |
                     (lq_xu_ex5_cr           & {4{ex1_spr_s3_lq_sel_q[5]}})   |
                     (ex6_lq_cr_q            & {4{ex1_spr_s3_lq_sel_q[6]}})   |
                     (cr_xu1_ex1_r3d         & {4{ex1_spr_s3_reg_sel_q[0]}});

   //------------------------------------------------------------------------------------------
   // XER  Bypass
   //------------------------------------------------------------------------------------------
   assign ex1_cr_bit = (dec_byp_ex1_instr[24:25] == 2'b11) ? ex1_cr3[3] :
                       (dec_byp_ex1_instr[24:25] == 2'b10) ? ex1_cr3[2] :
                       (dec_byp_ex1_instr[24:25] == 2'b01) ? ex1_cr3[1] :
                       ex1_cr3[0];

   assign ex1_xer3 =
                     (alu_byp_ex3_xer        & {10{ex1_spr_s3_xu1_sel_q[3]}}) |
                     (xu0_xu1_ex3_xer        & {10{ex1_spr_s3_xu0_sel_q[3]}}) |
                     (xu0_xu1_ex4_xer        & {10{ex1_spr_s3_xu0_sel_q[4]}}) |
                     (ex5_xu0_xer_q          & {10{ex1_spr_s3_xu0_sel_q[5]}}) |
                     (xu0_xu1_ex6_xer        & {10{ex1_spr_s3_xu0_sel_q[6]}}) |
                     (xer_xu1_ex1_r3d        & {10{ex1_spr_s3_reg_sel_q[1]}});

   //------------------------------------------------------------------------------------------
   // Parity Gen
   //------------------------------------------------------------------------------------------
   generate begin : ex3ParGen
      genvar i;
         for (i=8-`GPR_WIDTH/8;i<=7;i=i+1) begin : ex3ParGen
            assign ex3_parity[i] = ^(alu_byp_ex3_rt[8*i:8*i+7]);
         end
      end
   endgenerate

   //------------------------------------------------------------------------------------------
   // DVC Compare
   //------------------------------------------------------------------------------------------
`ifdef THREADS1

   generate begin : dvc_1t
         genvar b;
         for (b=(64-`GPR_WIDTH)/8;b<=7;b=b+1) begin : dvc_byte
            assign ex2_stq_dvc1_t0_cmpr[b]    = (spr_dvc1_t0[8*b:8*b+7] == ex2_rs1_q[8*b:8*b+7]);
            assign ex2_stq_dvc2_t0_cmpr[b]    = (spr_dvc2_t0[8*b:8*b+7] == ex2_rs1_q[8*b:8*b+7]);

            assign xu1_lq_ex2_stq_dvc1_cmp[b] = ex2_stq_dvc1_t0_cmpr[b] & dec_byp_ex2_dvc_mask[b] & dec_byp_ex2_tid[0];
            assign xu1_lq_ex2_stq_dvc2_cmp[b] = ex2_stq_dvc2_t0_cmpr[b] & dec_byp_ex2_dvc_mask[b] & dec_byp_ex2_tid[0];
         end
      end
   endgenerate
 `endif


`ifndef THREADS1
generate begin : dvc_2t

         genvar                                  b;
         for (b=(64-`GPR_WIDTH)/8;b<=7;b=b+1) begin : dvc_byte
            assign ex2_stq_dvc1_t0_cmpr[b]    = (spr_dvc1_t0[8*b:8*b+7] == ex2_rs1_q[8*b:8*b+7]);
            assign ex2_stq_dvc2_t0_cmpr[b]    = (spr_dvc2_t0[8*b:8*b+7] == ex2_rs1_q[8*b:8*b+7]);
            assign ex2_stq_dvc1_t1_cmpr[b]    = (spr_dvc1_t1[8*b:8*b+7] == ex2_rs1_q[8*b:8*b+7]);
            assign ex2_stq_dvc2_t1_cmpr[b]    = (spr_dvc2_t1[8*b:8*b+7] == ex2_rs1_q[8*b:8*b+7]);

            assign xu1_lq_ex2_stq_dvc1_cmp[b] = ((ex2_stq_dvc1_t0_cmpr[b] & dec_byp_ex2_tid[0]) |
                                                 (ex2_stq_dvc1_t1_cmpr[b] & dec_byp_ex2_tid[1])) & dec_byp_ex2_dvc_mask[b];
            assign xu1_lq_ex2_stq_dvc2_cmp[b] = ((ex2_stq_dvc2_t0_cmpr[b] & dec_byp_ex2_tid[0]) |
                                                 (ex2_stq_dvc2_t1_cmpr[b] & dec_byp_ex2_tid[1])) & dec_byp_ex2_dvc_mask[b];
         end
      end
   endgenerate
`endif
//------------------------------------------------------------------------------------------
   // IO / Buffering
   //------------------------------------------------------------------------------------------
   // GPR
   assign byp_alu_ex2_rs1 = ex2_rs1_q;
   assign byp_alu_ex2_rs2 = ex2_rs2_q;
   assign xu1_gpr_ex3_wd = {alu_byp_ex3_rt, ex3_parity, 2'b01};

   assign xu1_xu0_ex2_abort = exx_xu1_abort_q[2];
   assign xu1_lq_ex3_abort = exx_xu1_abort_q[3];
   assign xu1_xu0_ex2_rt = alu_byp_ex2_add_rt;
   assign xu1_xu0_ex3_rt = alu_byp_ex3_rt;
   assign xu1_xu0_ex4_rt = ex4_xu1_rt_q;
   assign xu1_xu0_ex5_rt = ex5_xu1_rt_q;
   assign xu1_lq_ex3_rt = alu_byp_ex3_rt;
   assign xu1_pc_ram_data = alu_byp_ex3_rt;

   // CR
   assign byp_alu_ex2_cr_bit = ex2_cr_bit_q;
   assign xu1_cr_ex3_w0d = alu_byp_ex3_cr;
   assign xu1_xu0_ex3_cr = alu_byp_ex3_cr;

   // XER
   assign xu_iu_ucode_xer = ex2_xer3_q[3:9];
   assign byp_alu_ex2_xer = ex2_xer3_q;
   assign byp_dec_ex2_xer = ex2_xer3_q[3:9];
   assign xu1_xer_ex3_w0d = alu_byp_ex3_xer;
   assign xu1_xu0_ex3_xer = alu_byp_ex3_xer;

   // Abort
   assign xu1_rv_ex2_s1_abort = ex2_rs1_abort_q;
   assign xu1_rv_ex2_s2_abort = ex2_rs2_abort_q;
   assign xu1_rv_ex2_s3_abort = ex2_rs3_abort_q;
   assign byp_dec_ex2_abort   = ex2_rs1_abort_q | ex2_rs2_abort_q | ex2_rs3_abort_q;

   //------------------------------------------------------------------------------------------
   // Clock Gating
   //------------------------------------------------------------------------------------------
   assign exx_xu1_act = {dec_byp_ex0_act, exx_xu1_act_q[1:6]};
   assign exx_xu0_act = {xu0_xu1_ex3_act, exx_xu0_act_q[4:7]};
   assign exx_lq_act  = {lq_xu_ex5_act, exx_lq_act_q[6:8]};

   assign exx_xu1_act_d[1:6] = exx_xu1_act[0:5];
   assign exx_xu0_act_d[4:7] = exx_xu0_act[3:6];
   assign exx_lq_act_d[6:8]  = exx_lq_act[5:7];

   //------------------------------------------------------------------------------------------
   // Latches
   //------------------------------------------------------------------------------------------
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(4),.INIT(0), .NEEDS_SRESET(1)) exx_xu0_act_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_xu0_act_offset : exx_xu0_act_offset + 4-1]),
      .scout(sov[exx_xu0_act_offset : exx_xu0_act_offset + 4-1]),
      .din(exx_xu0_act_d),
      .dout(exx_xu0_act_q)
   );
   tri_rlmreg_p #(.WIDTH(6), .OFFSET(1),.INIT(0), .NEEDS_SRESET(1)) exx_xu1_act_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_xu1_act_offset : exx_xu1_act_offset + 6-1]),
      .scout(sov[exx_xu1_act_offset : exx_xu1_act_offset + 6-1]),
      .din(exx_xu1_act_d),
      .dout(exx_xu1_act_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(6),.INIT(0), .NEEDS_SRESET(1)) exx_lq_act_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_lq_act_offset : exx_lq_act_offset + 3-1]),
      .scout(sov[exx_lq_act_offset : exx_lq_act_offset + 3-1]),
      .din(exx_lq_act_d),
      .dout(exx_lq_act_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_s1_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX0]),
      .mpw1_b(mpw1_dc_b[DEX0]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex0_s1_v_offset]),
      .scout(sov[ex0_s1_v_offset]),
      .din(rv_xu1_s1_v),
      .dout(ex0_s1_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_s2_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX0]),
      .mpw1_b(mpw1_dc_b[DEX0]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex0_s2_v_offset]),
      .scout(sov[ex0_s2_v_offset]),
      .din(rv_xu1_s2_v),
      .dout(ex0_s2_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_s3_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX0]),
      .mpw1_b(mpw1_dc_b[DEX0]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex0_s3_v_offset]),
      .scout(sov[ex0_s3_v_offset]),
      .din(rv_xu1_s3_v),
      .dout(ex0_s3_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_s1_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex1_s1_v_offset]),
      .scout(sov[ex1_s1_v_offset]),
      .din(ex0_s1_v_q),
      .dout(ex1_s1_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_s2_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex1_s2_v_offset]),
      .scout(sov[ex1_s2_v_offset]),
      .din(ex0_s2_v_q),
      .dout(ex1_s2_v_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_s3_v_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex1_s3_v_offset]),
      .scout(sov[ex1_s3_v_offset]),
      .din(ex0_s3_v_q),
      .dout(ex1_s3_v_q)
   );
generate begin : ex1_gpr_s1_xu0_sel_gen
   genvar i;
   for (i=2;i<=8;i=i+1) begin : ex1_gpr_s1_xu0_sel_entry
	   tri_rlmreg_p #(.WIDTH(8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_gpr_s1_xu0_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu1_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_gpr_s1_xu0_sel_offset + (i-2)*8 : ex1_gpr_s1_xu0_sel_offset + (i-2+1)*8-1]),
	      .scout(sov[ex1_gpr_s1_xu0_sel_offset + (i-2)*8 : ex1_gpr_s1_xu0_sel_offset + (i-2+1)*8-1]),
	      .din({8{ex0_gpr_s1_xu0_sel[i-1]}}),
	      .dout(ex1_gpr_s1_xu0_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_gpr_s2_xu0_sel_gen
   genvar i;
   for (i=2;i<=8;i=i+1) begin : ex1_gpr_s2_xu0_sel_entry
	   tri_rlmreg_p #(.WIDTH(8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_gpr_s2_xu0_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu1_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_gpr_s2_xu0_sel_offset + (i-2)*8 : ex1_gpr_s2_xu0_sel_offset + (i-2+1)*8-1]),
	      .scout(sov[ex1_gpr_s2_xu0_sel_offset + (i-2)*8 : ex1_gpr_s2_xu0_sel_offset + (i-2+1)*8-1]),
	      .din({8{ex0_gpr_s2_xu0_sel[i-1]}}),
	      .dout(ex1_gpr_s2_xu0_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_gpr_s1_xu1_sel_gen
   genvar i;
   for (i=2;i<=5;i=i+1) begin : ex1_gpr_s1_xu1_sel_entry
	   tri_rlmreg_p #(.WIDTH(8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_gpr_s1_xu1_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu1_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_gpr_s1_xu1_sel_offset + (i-2)*8 : ex1_gpr_s1_xu1_sel_offset + (i-2+1)*8-1]),
	      .scout(sov[ex1_gpr_s1_xu1_sel_offset + (i-2)*8 : ex1_gpr_s1_xu1_sel_offset + (i-2+1)*8-1]),
	      .din({8{ex0_gpr_s1_xu1_sel[i-1]}}),
	      .dout(ex1_gpr_s1_xu1_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_gpr_s2_xu1_sel_gen
   genvar i;
   for (i=2;i<=5;i=i+1) begin : ex1_gpr_s2_xu1_sel_entry
	   tri_rlmreg_p #(.WIDTH(8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_gpr_s2_xu1_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu1_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_gpr_s2_xu1_sel_offset + (i-2)*8 : ex1_gpr_s2_xu1_sel_offset + (i-2+1)*8-1]),
	      .scout(sov[ex1_gpr_s2_xu1_sel_offset + (i-2)*8 : ex1_gpr_s2_xu1_sel_offset + (i-2+1)*8-1]),
	      .din({8{ex0_gpr_s2_xu1_sel[i-1]}}),
	      .dout(ex1_gpr_s2_xu1_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_gpr_s1_lq_sel_gen
   genvar i;
   for (i=5;i<=8;i=i+1) begin : ex1_gpr_s1_lq_sel_entry
	   tri_rlmreg_p #(.WIDTH(8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_gpr_s1_lq_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu1_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_gpr_s1_lq_sel_offset + (i-5)*8 : ex1_gpr_s1_lq_sel_offset + (i-5+1)*8-1]),
	      .scout(sov[ex1_gpr_s1_lq_sel_offset + (i-5)*8 : ex1_gpr_s1_lq_sel_offset + (i-5+1)*8-1]),
	      .din({8{ex0_gpr_s1_lq_sel[i-1]}}),
	      .dout(ex1_gpr_s1_lq_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_gpr_s2_lq_sel_gen
   genvar i;
   for (i=5;i<=8;i=i+1) begin : ex1_gpr_s2_lq_sel_entry
	   tri_rlmreg_p #(.WIDTH(8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_gpr_s2_lq_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu1_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_gpr_s2_lq_sel_offset + (i-5)*8 : ex1_gpr_s2_lq_sel_offset + (i-5+1)*8-1]),
	      .scout(sov[ex1_gpr_s2_lq_sel_offset + (i-5)*8 : ex1_gpr_s2_lq_sel_offset + (i-5+1)*8-1]),
	      .din({8{ex0_gpr_s2_lq_sel[i-1]}}),
	      .dout(ex1_gpr_s2_lq_sel_q[i])
	   );
   end
end
endgenerate
   tri_rlmreg_p #(.WIDTH(8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_gpr_s2_imm_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_gpr_s2_imm_sel_offset : ex1_gpr_s2_imm_sel_offset + 8-1]),
      .scout(sov[ex1_gpr_s2_imm_sel_offset : ex1_gpr_s2_imm_sel_offset + 8-1]),
      .din({8{dec_byp_ex0_rs2_sel_imm}}),
      .dout(ex1_gpr_s2_imm_sel_q)
   );
generate begin : ex1_spr_s3_xu0_sel_gen
   genvar i;
   for (i=3;i<=8;i=i+1) begin : ex1_spr_s3_xu0_sel_entry
	   tri_rlmreg_p #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s3_xu0_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu1_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_spr_s3_xu0_sel_offset + (i-3)*1 : ex1_spr_s3_xu0_sel_offset + (i-3+1)*1-1]),
	      .scout(sov[ex1_spr_s3_xu0_sel_offset + (i-3)*1 : ex1_spr_s3_xu0_sel_offset + (i-3+1)*1-1]),
	      .din(rv_xu1_s3_fxu0_sel[i-1]),
	      .dout(ex1_spr_s3_xu0_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_spr_s3_xu1_sel_gen
   genvar i;
   for (i=3;i<=5;i=i+1) begin : ex1_spr_s3_xu1_sel_entry
	   tri_rlmreg_p #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s3_xu1_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu1_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_spr_s3_xu1_sel_offset + (i-3)*1 : ex1_spr_s3_xu1_sel_offset + (i-3+1)*1-1]),
	      .scout(sov[ex1_spr_s3_xu1_sel_offset + (i-3)*1 : ex1_spr_s3_xu1_sel_offset + (i-3+1)*1-1]),
	      .din(rv_xu1_s3_fxu1_sel[i-1]),
	      .dout(ex1_spr_s3_xu1_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_spr_s3_lq_sel_gen
   genvar i;
   for (i=5;i<=6;i=i+1) begin : ex1_spr_s3_lq_sel_entry
	   tri_rlmreg_p #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s3_lq_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu1_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_spr_s3_lq_sel_offset + (i-5)*1 : ex1_spr_s3_lq_sel_offset + (i-5+1)*1-1]),
	      .scout(sov[ex1_spr_s3_lq_sel_offset + (i-5)*1 : ex1_spr_s3_lq_sel_offset + (i-5+1)*1-1]),
	      .din(rv_xu1_s3_lq_sel[i-1]),
	      .dout(ex1_spr_s3_lq_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_gpr_s1_rel_sel_gen
   genvar i;
   for (i=3;i<=4;i=i+1) begin : ex1_gpr_s1_rel_sel_entry
	   tri_rlmreg_p #(.WIDTH(8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_gpr_s1_rel_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu1_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_gpr_s1_rel_sel_offset + (i-3)*8 : ex1_gpr_s1_rel_sel_offset + (i-3+1)*8-1]),
	      .scout(sov[ex1_gpr_s1_rel_sel_offset + (i-3)*8 : ex1_gpr_s1_rel_sel_offset + (i-3+1)*8-1]),
	      .din({8{ex0_gpr_s1_rel_sel[i-1]}}),
	      .dout(ex1_gpr_s1_rel_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_gpr_s2_rel_sel_gen
   genvar i;
   for (i=3;i<=4;i=i+1) begin : ex1_gpr_s2_rel_sel_entry
	   tri_rlmreg_p #(.WIDTH(8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_gpr_s2_rel_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu1_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_gpr_s2_rel_sel_offset + (i-3)*8 : ex1_gpr_s2_rel_sel_offset + (i-3+1)*8-1]),
	      .scout(sov[ex1_gpr_s2_rel_sel_offset + (i-3)*8 : ex1_gpr_s2_rel_sel_offset + (i-3+1)*8-1]),
	      .din({8{ex0_gpr_s2_rel_sel[i-1]}}),
	      .dout(ex1_gpr_s2_rel_sel_q[i])
	   );
   end
end
endgenerate
   tri_rlmreg_p #(.WIDTH(8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_gpr_s1_reg_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_gpr_s1_reg_sel_offset : ex1_gpr_s1_reg_sel_offset + 8-1]),
      .scout(sov[ex1_gpr_s1_reg_sel_offset : ex1_gpr_s1_reg_sel_offset + 8-1]),
      .din({8{ex0_gpr_s1_reg_sel}}),
      .dout(ex1_gpr_s1_reg_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_gpr_s2_reg_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_gpr_s2_reg_sel_offset : ex1_gpr_s2_reg_sel_offset + 8-1]),
      .scout(sov[ex1_gpr_s2_reg_sel_offset : ex1_gpr_s2_reg_sel_offset + 8-1]),
      .din({8{ex0_gpr_s2_reg_sel}}),
      .dout(ex1_gpr_s2_reg_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s3_reg_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_spr_s3_reg_sel_offset : ex1_spr_s3_reg_sel_offset + 2-1]),
      .scout(sov[ex1_spr_s3_reg_sel_offset : ex1_spr_s3_reg_sel_offset + 2-1]),
      .din({2{ex0_spr_s3_reg_sel}}),
      .dout(ex1_spr_s3_reg_sel_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_abt_s1_lq_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex1_abt_s1_lq_sel_offset]),
      .scout(sov[ex1_abt_s1_lq_sel_offset]),
      .din(ex0_gpr_s1_lq_sel[8]),
      .dout(ex1_abt_s1_lq_sel_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_abt_s2_lq_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex1_abt_s2_lq_sel_offset]),
      .scout(sov[ex1_abt_s2_lq_sel_offset]),
      .din(ex0_gpr_s2_lq_sel[8]),
      .dout(ex1_abt_s2_lq_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(7),.INIT(0), .NEEDS_SRESET(1)) ex1_abt_s3_lq_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_abt_s3_lq_sel_offset : ex1_abt_s3_lq_sel_offset + 3-1]),
      .scout(sov[ex1_abt_s3_lq_sel_offset : ex1_abt_s3_lq_sel_offset + 3-1]),
      .din(rv_xu1_s3_lq_sel[6:8]),
      .dout(ex1_abt_s3_lq_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(6),.INIT(0), .NEEDS_SRESET(1)) ex1_abt_s1_xu1_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_abt_s1_xu1_sel_offset : ex1_abt_s1_xu1_sel_offset + 2-1]),
      .scout(sov[ex1_abt_s1_xu1_sel_offset : ex1_abt_s1_xu1_sel_offset + 2-1]),
      .din(ex0_gpr_s1_xu1_sel[5:6]),
      .dout(ex1_abt_s1_xu1_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(6),.INIT(0), .NEEDS_SRESET(1)) ex1_abt_s2_xu1_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_abt_s2_xu1_sel_offset : ex1_abt_s2_xu1_sel_offset + 2-1]),
      .scout(sov[ex1_abt_s2_xu1_sel_offset : ex1_abt_s2_xu1_sel_offset + 2-1]),
      .din(ex0_gpr_s2_xu1_sel[5:6]),
      .dout(ex1_abt_s2_xu1_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(6),.INIT(0), .NEEDS_SRESET(1)) ex1_abt_s3_xu1_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_abt_s3_xu1_sel_offset : ex1_abt_s3_xu1_sel_offset + 2-1]),
      .scout(sov[ex1_abt_s3_xu1_sel_offset : ex1_abt_s3_xu1_sel_offset + 2-1]),
      .din(rv_xu1_s3_fxu1_sel[5:6]),
      .dout(ex1_abt_s3_xu1_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(9),.INIT(0), .NEEDS_SRESET(1)) ex1_abt_s1_xu0_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_abt_s1_xu0_sel_offset : ex1_abt_s1_xu0_sel_offset + 4-1]),
      .scout(sov[ex1_abt_s1_xu0_sel_offset : ex1_abt_s1_xu0_sel_offset + 4-1]),
      .din(ex0_gpr_s1_xu0_sel[8:11]),
      .dout(ex1_abt_s1_xu0_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(9),.INIT(0), .NEEDS_SRESET(1)) ex1_abt_s2_xu0_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_abt_s2_xu0_sel_offset : ex1_abt_s2_xu0_sel_offset + 4-1]),
      .scout(sov[ex1_abt_s2_xu0_sel_offset : ex1_abt_s2_xu0_sel_offset + 4-1]),
      .din(ex0_gpr_s2_xu0_sel[8:11]),
      .dout(ex1_abt_s2_xu0_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(9),.INIT(0), .NEEDS_SRESET(1)) ex1_abt_s3_xu0_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_abt_s3_xu0_sel_offset : ex1_abt_s3_xu0_sel_offset + 4-1]),
      .scout(sov[ex1_abt_s3_xu0_sel_offset : ex1_abt_s3_xu0_sel_offset + 4-1]),
      .din(rv_xu1_s3_fxu0_sel[8:11]),
      .dout(ex1_abt_s3_xu0_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex4_xu1_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_xu1_rt_offset : ex4_xu1_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[ex4_xu1_rt_offset : ex4_xu1_rt_offset + `GPR_WIDTH-1]),
      .din(alu_byp_ex3_rt),
      .dout(ex4_xu1_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex5_xu1_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[4]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_xu1_rt_offset : ex5_xu1_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[ex5_xu1_rt_offset : ex5_xu1_rt_offset + `GPR_WIDTH-1]),
      .din(ex4_xu1_rt_q),
      .dout(ex5_xu1_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex5_xu0_cr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[4]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_xu0_cr_offset : ex5_xu0_cr_offset + 4-1]),
      .scout(sov[ex5_xu0_cr_offset : ex5_xu0_cr_offset + 4-1]),
      .din(xu0_xu1_ex4_cr),
      .dout(ex5_xu0_cr_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex6_lq_cr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_lq_act[5]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex6_lq_cr_offset : ex6_lq_cr_offset + 4-1]),
      .scout(sov[ex6_lq_cr_offset : ex6_lq_cr_offset + 4-1]),
      .din(lq_xu_ex5_cr),
      .dout(ex6_lq_cr_q)
   );
   tri_rlmreg_p #(.WIDTH(10), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex5_xu0_xer_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[4]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_xu0_xer_offset : ex5_xu0_xer_offset + 10-1]),
      .scout(sov[ex5_xu0_xer_offset : ex5_xu0_xer_offset + 10-1]),
      .din(xu0_xu1_ex4_xer),
      .dout(ex5_xu0_xer_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex2_rs1_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_rs1_offset : ex2_rs1_offset + `GPR_WIDTH-1]),
      .scout(sov[ex2_rs1_offset : ex2_rs1_offset + `GPR_WIDTH-1]),
      .din(ex1_rs1),
      .dout(ex2_rs1_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex2_rs2_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_rs2_offset : ex2_rs2_offset + `GPR_WIDTH-1]),
      .scout(sov[ex2_rs2_offset : ex2_rs2_offset + `GPR_WIDTH-1]),
      .din(ex1_rs2),
      .dout(ex2_rs2_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_cr_bit_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_cr_bit_offset]),
      .scout(sov[ex2_cr_bit_offset]),
      .din(ex1_cr_bit),
      .dout(ex2_cr_bit_q)
   );
   tri_rlmreg_p #(.WIDTH(10), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_xer3_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu1_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_xer3_offset : ex2_xer3_offset + 10-1]),
      .scout(sov[ex2_xer3_offset : ex2_xer3_offset + 10-1]),
      .din(ex1_xer3),
      .dout(ex2_xer3_q)
   );
   tri_rlmreg_p #(.WIDTH(10), .OFFSET(3),.INIT(0), .NEEDS_SRESET(1)) exx_xu0_abort_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_xu0_abort_offset : exx_xu0_abort_offset + 10-1]),
      .scout(sov[exx_xu0_abort_offset : exx_xu0_abort_offset + 10-1]),
      .din(exx_xu0_abort_d),
      .dout(exx_xu0_abort_q)
   );
   tri_rlmreg_p #(.WIDTH(6), .OFFSET(2),.INIT(0), .NEEDS_SRESET(1)) exx_xu1_abort_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_xu1_abort_offset : exx_xu1_abort_offset + 6-1]),
      .scout(sov[exx_xu1_abort_offset : exx_xu1_abort_offset + 6-1]),
      .din(exx_xu1_abort_d),
      .dout(exx_xu1_abort_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(6),.INIT(0), .NEEDS_SRESET(1)) exx_lq_abort_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_lq_abort_offset : exx_lq_abort_offset + 4-1]),
      .scout(sov[exx_lq_abort_offset : exx_lq_abort_offset + 4-1]),
      .din(exx_lq_abort_d),
      .dout(exx_lq_abort_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_rs1_abort_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_rs1_abort_offset]),
      .scout(sov[ex2_rs1_abort_offset]),
      .din(ex1_rs1_abort),
      .dout(ex2_rs1_abort_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_rs2_abort_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_rs2_abort_offset]),
      .scout(sov[ex2_rs2_abort_offset]),
      .din(ex1_rs2_abort),
      .dout(ex2_rs2_abort_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_rs3_abort_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_rs3_abort_offset]),
      .scout(sov[ex2_rs3_abort_offset]),
      .din(ex1_rs3_abort),
      .dout(ex2_rs3_abort_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) exx_rel3_act_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_rel3_act_offset]),
      .scout(sov[exx_rel3_act_offset]),
      .din(lq_xu_rel_act),
      .dout(exx_rel3_act_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) exx_rel3_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(lq_xu_rel_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_rel3_rt_offset : exx_rel3_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[exx_rel3_rt_offset : exx_rel3_rt_offset + `GPR_WIDTH-1]),
      .din(lq_xu_rel_rt),
      .dout(exx_rel3_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) exx_rel4_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_rel3_act_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_rel4_rt_offset : exx_rel4_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[exx_rel4_rt_offset : exx_rel4_rt_offset + `GPR_WIDTH-1]),
      .din(exx_rel3_rt_q),
      .dout(exx_rel4_rt_q)
   );

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];


   function  [0:`GPR_WIDTH-1] fanout;
      input [0:7] a;
      input integer s;
      integer t;
   begin
      for (t=0;t<`GPR_WIDTH;t=t+1)
      begin : loop
         fanout[t] = a[t % 8];
      end
   end
   endfunction

endmodule
