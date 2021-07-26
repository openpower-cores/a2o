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
module xu0_byp(
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

   input                                  ex4_spr_msr_cm,

   //-------------------------------------------------------------------
   // Decode Interface
   //-------------------------------------------------------------------
   input                                  dec_byp_ex0_act,
   input                                  xu1_xu0_ex3_act,
   input                                  lq_xu_ex5_act,

   input [64-`GPR_WIDTH:63]               dec_byp_ex1_imm,

   input [24:25]                          dec_byp_ex1_instr,

   input                                  dec_byp_ex1_is_mflr,
   input                                  dec_byp_ex1_is_mfxer,
   input                                  dec_byp_ex1_is_mtxer,
   input                                  dec_byp_ex1_is_mfcr_sel,
   input [0:7]                            dec_byp_ex1_is_mfcr,
   input [0:7]                            dec_byp_ex1_is_mtcr,
   input                                  dec_byp_ex1_is_mfctr,
   input                                  dec_byp_ex3_is_mtspr,

   input [2:3]                            dec_byp_ex1_cr_sel,
   input [2:3]                            dec_byp_ex1_xer_sel,

   input                                  dec_byp_ex1_rs_capt,
   input                                  dec_byp_ex1_ra_capt,

   input                                  dec_byp_ex0_rs2_sel_imm,
   input                                  dec_byp_ex0_rs1_sel_zero,

   input                                  dec_byp_ex3_mtiar,
   input                                  dec_byp_ex5_ord_sel,

   //-------------------------------------------------------------------
   // RV
   //-------------------------------------------------------------------
   input                                  rv_xu0_ex0_s1_v,
   input                                  rv_xu0_ex0_s2_v,
   input                                  rv_xu0_ex0_s3_v,

   //-------------------------------------------------------------------
   // Interface with Bypass Controller
   //-------------------------------------------------------------------
   input [1:11]                           rv_xu0_s1_fxu0_sel,
   input [1:11]                           rv_xu0_s2_fxu0_sel,
   input [2:11]                           rv_xu0_s3_fxu0_sel,
   input [1:6]                            rv_xu0_s1_fxu1_sel,
   input [1:6]                            rv_xu0_s2_fxu1_sel,
   input [2:6]                            rv_xu0_s3_fxu1_sel,
   input [4:8]                            rv_xu0_s1_lq_sel,
   input [4:8]                            rv_xu0_s2_lq_sel,
   input [4:8]                            rv_xu0_s3_lq_sel,
   input [2:3]                            rv_xu0_s1_rel_sel,
   input [2:3]                            rv_xu0_s2_rel_sel,

   //-------------------------------------------------------------------
   // Bypass Inputs
   //-------------------------------------------------------------------
   // Regfile Data
   input [64-`GPR_WIDTH:63]               gpr_xu0_ex1_r1d,
   input [64-`GPR_WIDTH:63]               gpr_xu0_ex1_r2d,
   input [0:9]                            xer_xu0_ex1_r2d,
   input [0:9]                            xer_xu0_ex1_r3d,
   input [0:3]                            cr_xu0_ex1_r1d,
   input [0:3]                            cr_xu0_ex1_r2d,
   input [0:3]                            cr_xu0_ex1_r3d,
   input [64-`GPR_WIDTH:63]               lr_xu0_ex1_r1d,
   input [64-`GPR_WIDTH:63]               lr_xu0_ex1_r2d,
   input [64-`GPR_WIDTH:63]               ctr_xu0_ex1_r2d,

   // External Bypass
   input                                  xu1_xu0_ex2_abort,
   input [64-`GPR_WIDTH:63]               xu1_xu0_ex2_rt,
   input [64-`GPR_WIDTH:63]               xu1_xu0_ex3_rt,
   input [64-`GPR_WIDTH:63]               xu1_xu0_ex4_rt,
   input [64-`GPR_WIDTH:63]               xu1_xu0_ex5_rt,
   input                                  lq_xu_ex5_abort,
   input [64-`GPR_WIDTH:63]               lq_xu_ex5_data,
   input [64-`GPR_WIDTH:63]               lq_xu_ex5_rt,
   input [64-`GPR_WIDTH:63]               lq_xu_rel_rt,
   input                                  lq_xu_rel_act,

   // CR
   input [0:3]                            lq_xu_ex5_cr,
   input [0:3]                            xu1_xu0_ex3_cr,
   // XER
   input [0:9]                            xu1_xu0_ex3_xer,

   // Internal Bypass
   input [64-`GPR_WIDTH:63]               alu_byp_ex2_add_rt,
   input [64-`GPR_WIDTH:63]               alu_byp_ex3_rt,
   // CR
   input [0:3]                            alu_byp_ex3_cr,
   // XER
   input [0:9]                            alu_byp_ex3_xer,

   // BR
   input                                  br_byp_ex3_lr_we,
   input [64-`GPR_WIDTH:63]               br_byp_ex3_lr_wd,
   input                                  br_byp_ex3_ctr_we,
   input [64-`GPR_WIDTH:63]               br_byp_ex3_ctr_wd,
   input                                  br_byp_ex3_cr_we,
   input [0:3]                            br_byp_ex3_cr_wd,

   //-------------------------------------------------------------------
   // SPR Interface <ordered>
   //-------------------------------------------------------------------
   input                                  spr_xu_ord_write_done,
   input [64-`GPR_WIDTH:63]               spr_xu_ex4_rd_data,
   output [64-`GPR_WIDTH:63]              xu_spr_ex2_rs1,

   input                                  xu_slowspr_val_in,
   input                                  xu_slowspr_rw_in,
   input [64-`GPR_WIDTH:63]               xu_slowspr_data_in,
   input                                  xu_slowspr_done_in,

   //-------------------------------------------------------------------
   // Div Interfaces <ordered>
   //-------------------------------------------------------------------
   input                                  div_byp_ex4_done,
   input [64-`GPR_WIDTH:63]               div_byp_ex4_rt,
   input [0:9]                            div_byp_ex4_xer,
   input [0:3]                            div_byp_ex4_cr,

   //-------------------------------------------------------------------
   // Mul Interfaces <some ordered>
   //-------------------------------------------------------------------
   input                                  mul_byp_ex5_ord_done,
   input                                  mul_byp_ex5_done,
   input                                  mul_byp_ex5_abort,
   input [64-`GPR_WIDTH:63]               mul_byp_ex6_rt,
   input [0:9]                            mul_byp_ex6_xer,
   input [0:3]                            mul_byp_ex6_cr,

   //-------------------------------------------------------------------
   // ERAT Interfaces <ordered>
   //-------------------------------------------------------------------
   input                                  iu_xu_ord_write_done,
   input [64-`GPR_WIDTH:63]               iu_xu_ex5_data,
   input                                  lq_xu_ord_write_done,

   //-------------------------------------------------------------------
   // popcnt / cntlz / dlmzb / bcd
   //-------------------------------------------------------------------
   input                                  dec_byp_ex4_hpriv,
   input [0:31]                           dec_byp_ex4_instr,
   input                                  dec_byp_ex4_pop_done,
   input                                  dec_byp_ex3_cnt_done,
   input                                  dec_byp_ex3_prm_done,
   input                                  dec_byp_ex3_dlm_done,
   input                                  bcd_byp_ex3_done,

   input [64-`GPR_WIDTH:63]               pop_byp_ex4_rt,
   input [57:63]                          cnt_byp_ex2_rt,
   input [56:63]                          prm_byp_ex2_rt,
   input [60:63]                          dlm_byp_ex2_rt,
   input [0:9]                            dlm_byp_ex2_xer,
   input [0:3]                            dlm_byp_ex2_cr,
   input [64-`GPR_WIDTH:63]               bcd_byp_ex3_rt,

   //-------------------------------------------------------------------
   // MMU Interfaces
   //-------------------------------------------------------------------
   input                                  mm_xu_cr0_eq,    // for record forms
   input                                  mm_xu_cr0_eq_valid,    // for record forms

   output [0:8]                           xu_iu_rs_is,
   output [0:3]                           xu_iu_ra_entry,
   output [64-`GPR_WIDTH:51]              xu_iu_rb,
   output [64-`GPR_WIDTH:63]              xu_iu_rs_data,

   output [0:8]                           xu_lq_rs_is,
   output [0:4]                           xu_lq_ra_entry,
   output [64-`GPR_WIDTH:51]              xu_lq_rb,
   output [64-`GPR_WIDTH:63]              xu_lq_rs_data,

   output [0:11]                          xu_mm_ra_entry,
   output [64-`GPR_WIDTH:63]              xu_mm_rb,

   //-------------------------------------------------------------------
   // Bypass Outputs
   //-------------------------------------------------------------------
   output                                 xu0_xu1_ex2_abort,
   output                                 xu0_xu1_ex6_abort,
   output                                 xu0_lq_ex3_abort,

   output [64-`GPR_WIDTH:63]              xu0_xu1_ex2_rt,
   output [64-`GPR_WIDTH:63]              xu0_xu1_ex3_rt,
   output [64-`GPR_WIDTH:63]              xu0_xu1_ex4_rt,
   output [64-`GPR_WIDTH:63]              xu0_xu1_ex5_rt,
   output [64-`GPR_WIDTH:63]              xu0_xu1_ex6_rt,
   output [64-`GPR_WIDTH:63]              xu0_xu1_ex7_rt,
   output [64-`GPR_WIDTH:63]              xu0_xu1_ex8_rt,
   output [64-`GPR_WIDTH:63]              xu0_xu1_ex6_lq_rt,
   output [64-`GPR_WIDTH:63]              xu0_xu1_ex7_lq_rt,
   output [64-`GPR_WIDTH:63]              xu0_xu1_ex8_lq_rt,

   output [64-`GPR_WIDTH:63]              xu0_lq_ex3_rt,
   output [64-`GPR_WIDTH:63]              xu0_lq_ex4_rt,
   output                                 xu0_lq_ex6_act,
   output [64-`GPR_WIDTH:63]              xu0_lq_ex6_rt,
   output [64-`GPR_WIDTH:63]              xu0_pc_ram_data,

   // CR
   output [0:3]                           xu0_xu1_ex3_cr,
   output [0:3]                           xu0_xu1_ex4_cr,
   output [0:3]                           xu0_xu1_ex6_cr,

   // XER
   output [0:9]                           xu0_xu1_ex3_xer,
   output [0:9]                           xu0_xu1_ex4_xer,
   output [0:9]                           xu0_xu1_ex6_xer,

   //-------------------------------------------------------------------
   // Source Outputs
   //-------------------------------------------------------------------
   output [64-`GPR_WIDTH:63]              byp_alu_ex2_rs1,    // Source Data
   output [64-`GPR_WIDTH:63]              byp_alu_ex2_rs2,
   output                                 byp_alu_ex2_cr_bit,    // CR bit for isel
   output [0:9]                           byp_alu_ex2_xer,

   output [64-`GPR_WIDTH:63]              byp_pop_ex2_rs1,
   output [64-`GPR_WIDTH:63]              byp_cnt_ex2_rs1,

   output [64-`GPR_WIDTH:63]              byp_div_ex2_rs1,
   output [64-`GPR_WIDTH:63]              byp_div_ex2_rs2,
   output [0:9]                           byp_div_ex2_xer,

   output [0:`GPR_WIDTH-1]                byp_mul_ex2_rs1,
   output [0:`GPR_WIDTH-1]                byp_mul_ex2_rs2,
   output                                 byp_mul_ex2_abort,
   output [0:9]                           byp_mul_ex2_xer,

   output [32:63]                         byp_dlm_ex2_rs1,
   output [32:63]                         byp_dlm_ex2_rs2,
   output [0:2]                           byp_dlm_ex2_xer,

   output [64-`GPR_WIDTH:63]              byp_bcd_ex2_rs1,
   output [64-`GPR_WIDTH:63]              byp_bcd_ex2_rs2,

   output [0:3]                           byp_br_ex3_cr,
   output [0:3]                           byp_br_ex2_cr1,
   output [0:3]                           byp_br_ex2_cr2,
   output [0:3]                           byp_br_ex2_cr3,

   output [64-`GPR_WIDTH:63]              byp_br_ex2_lr1,
   output [64-`GPR_WIDTH:63]              byp_br_ex2_lr2,

   output [64-`GPR_WIDTH:63]              byp_br_ex2_ctr,

   output                                 xu0_rv_ex2_s1_abort,
   output                                 xu0_rv_ex2_s2_abort,
   output                                 xu0_rv_ex2_s3_abort,
   output                                 byp_dec_ex2_abort,

   //-------------------------------------------------------------------
   // Target Outputs
   //-------------------------------------------------------------------
   output [62-`EFF_IFAR_ARCH:61]          xu0_iu_bta,
   output [64-`GPR_WIDTH:65+`GPR_WIDTH/8] xu0_gpr_ex6_wd,
   output [0:9]                           xu0_xer_ex6_w0d,
   output [0:3]                           xu0_cr_ex6_w0d,
   output [64-`GPR_WIDTH:63]              xu0_ctr_ex4_w0d,
   output [64-`GPR_WIDTH:63]              xu0_lr_ex4_w0d
);

   localparam                    DEX0 = 0;
   localparam                    DEX1 = 0;
   localparam                    DEX2 = 0;
   localparam                    DEX3 = 0;
   localparam                    DEX4 = 0;
   localparam                    DEX5 = 0;
   localparam                    DEX6 = 0;
   localparam                    DEX7 = 0;
   localparam                    DEX8 = 0;
   localparam                    DX = 0;
   // Latches
	wire [1:7]                    exx_xu0_act_q,             exx_xu0_act_d              ; //  input=>exx_xu0_act_d                   ,act=>1'b1
	wire [6:8]                    exx_lq_act_q,              exx_lq_act_d               ; //  input=>exx_lq_act_d                    ,act=>1'b1
   wire                          ex1_s1_v_q                                            ; //  input=>rv_xu0_ex0_s1_v                 ,act=>1'b1
   wire                          ex1_s2_v_q                                            ; //  input=>rv_xu0_ex0_s2_v                      ,act=>1'b1
   wire                          ex1_s3_v_q                                            ; //  input=>rv_xu0_ex0_s3_v                      ,act=>1'b1
	wire [0:7]                    ex1_gpr_s1_xu0_sel_q[2:8]                             ; //  input=>{8{ex0_gpr_s1_xu0_sel[i-1]}}    ,act=>exx_xu0_act[0]
	wire [0:7]                    ex1_gpr_s2_xu0_sel_q[2:8]                             ; //  input=>{8{ex0_gpr_s2_xu0_sel[i-1]}}    ,act=>exx_xu0_act[0]
	wire [0:7]                    ex1_gpr_s1_xu1_sel_q[2:5]                             ; //  input=>{8{ex0_gpr_s1_xu1_sel[i-1]}}    ,act=>exx_xu0_act[0]
	wire [0:7]                    ex1_gpr_s2_xu1_sel_q[2:5]                             ; //  input=>{8{ex0_gpr_s2_xu1_sel[i-1]}}    ,act=>exx_xu0_act[0]
	wire [0:7]                    ex1_gpr_s1_lq_sel_q[5:8]                              ; //  input=>{8{ex0_gpr_s1_lq_sel[i-1]}}     ,act=>exx_xu0_act[0]
	wire [0:7]                    ex1_gpr_s2_lq_sel_q[5:8]                              ; //  input=>{8{ex0_gpr_s2_lq_sel[i-1]}}     ,act=>exx_xu0_act[0]
	wire [0:7]                    ex1_gpr_s2_imm_sel_q                                  ; //  input=>{8{dec_byp_ex0_rs2_sel_imm}}    ,act=>exx_xu0_act[0]
	wire [0:2]                    ex1_spr_s1_xu0_sel_q[3:6]                             ; //  input=>{3{rv_xu0_s1_fxu0_sel[i-1]}}    ,act=>exx_xu0_act[0]
	wire [0:0]                    ex1_spr_s1_xu1_sel_q[3:3]                             ; //  input=>{1{rv_xu0_s1_fxu1_sel[i-1]}}    ,act=>exx_xu0_act[0]
	wire [0:0]                    ex1_spr_s1_lq_sel_q[5:6]                              ; //  input=>{1{rv_xu0_s1_lq_sel[i-1]}}      ,act=>exx_xu0_act[0]
	wire [0:5]                    ex1_spr_s2_xu0_sel_q[3:6]                             ; //  input=>{6{rv_xu0_s2_fxu0_sel[i-1]}}    ,act=>exx_xu0_act[0]
	wire [0:1]                    ex1_spr_s2_xu1_sel_q[3:3]                             ; //  input=>{2{rv_xu0_s2_fxu1_sel[i-1]}}    ,act=>exx_xu0_act[0]
	wire [0:0]                    ex1_spr_s2_lq_sel_q[5:6]                              ; //  input=>{1{rv_xu0_s2_lq_sel[i-1]}}      ,act=>exx_xu0_act[0]
	wire [0:1]                    ex1_spr_s3_xu0_sel_q[3:8]                             ; //  input=>{2{rv_xu0_s3_fxu0_sel[i-1]}}    ,act=>exx_xu0_act[0]
	wire [0:1]                    ex1_spr_s3_xu1_sel_q[3:5]                             ; //  input=>{2{rv_xu0_s3_fxu1_sel[i-1]}}    ,act=>exx_xu0_act[0]
	wire [0:0]                    ex1_spr_s3_lq_sel_q[5:6]                              ; //  input=>{1{rv_xu0_s3_lq_sel[i-1]}}      ,act=>exx_xu0_act[0]
	wire [0:7]                    ex1_gpr_s1_rel_sel_q[3:4]                             ; //  input=>{8{ex0_gpr_s1_rel_sel[i-1]}}    ,act=>exx_xu0_act[0]
	wire [0:7]                    ex1_gpr_s2_rel_sel_q[3:4]                             ; //  input=>{8{ex0_gpr_s2_rel_sel[i-1]}}    ,act=>exx_xu0_act[0]
	wire [0:7]                    ex1_gpr_s1_reg_sel_q                                  ; //  input=>{8{ex0_gpr_s1_reg_sel}}         ,act=>ex0_xu0_ivax_act
	wire [0:7]                    ex1_gpr_s2_reg_sel_q                                  ; //  input=>{8{ex0_gpr_s2_reg_sel}}         ,act=>exx_xu0_act[0]
	wire [0:2]                    ex1_spr_s1_reg_sel_q                                  ; //  input=>{3{ex0_spr_s1_reg_sel}}         ,act=>exx_xu0_act[0]
	wire [0:5]                    ex1_spr_s2_reg_sel_q                                  ; //  input=>{6{ex0_spr_s2_reg_sel}}         ,act=>exx_xu0_act[0]
	wire [0:1]                    ex1_spr_s3_reg_sel_q                                  ; //  input=>{2{ex0_spr_s3_reg_sel}}         ,act=>exx_xu0_act[0]
   wire [9:9]                    ex1_abt_s1_lq_sel_q                                   ; //  input=>ex0_gpr_s1_lq_sel[8]            ,act=>exx_xu0_act[0]
   wire [9:9]                    ex1_abt_s2_lq_sel_q                                   ; //  input=>ex0_gpr_s2_lq_sel[8]            ,act=>exx_xu0_act[0]
   wire [7:9]                    ex1_abt_s3_lq_sel_q                                   ; //  input=>rv_xu0_s3_lq_sel[6:8]           ,act=>exx_xu0_act[0]
	wire [6:7]                    ex1_abt_s1_xu1_sel_q                                  ; //  input=>ex0_gpr_s1_xu1_sel[5:6]         ,act=>exx_xu0_act[0]
	wire [6:7]                    ex1_abt_s2_xu1_sel_q                                  ; //  input=>ex0_gpr_s2_xu1_sel[5:6]         ,act=>exx_xu0_act[0]
	wire [6:7]                    ex1_abt_s3_xu1_sel_q                                  ; //  input=>rv_xu0_s3_fxu1_sel[5:6]         ,act=>exx_xu0_act[0]
	wire [9:12]                   ex1_abt_s1_xu0_sel_q                                  ; //  input=>ex0_gpr_s1_xu0_sel[8:11]        ,act=>exx_xu0_act[0]
	wire [9:12]                   ex1_abt_s2_xu0_sel_q                                  ; //  input=>ex0_gpr_s2_xu0_sel[8:11]        ,act=>exx_xu0_act[0]
	wire [9:12]                   ex1_abt_s3_xu0_sel_q                                  ; //  input=>rv_xu0_s3_fxu0_sel[8:11]        ,act=>exx_xu0_act[0]
	wire                          ex2_is_mflr_q                                         ; //  input=>dec_byp_ex1_is_mflr             ,act=>exx_xu0_act[1]
	wire                          ex2_is_mfxer_q                                        ; //  input=>dec_byp_ex1_is_mfxer            ,act=>exx_xu0_act[1]
	wire                          ex2_is_mtxer_q                                        ; //  input=>dec_byp_ex1_is_mtxer            ,act=>exx_xu0_act[1]
	wire                          ex2_is_mfcr_sel_q                                     ; //  input=>dec_byp_ex1_is_mfcr_sel         ,act=>exx_xu0_act[1]
	wire [0:7]                    ex2_is_mfcr_q                                         ; //  input=>dec_byp_ex1_is_mfcr             ,act=>exx_xu0_act[1]
	wire [0:7]                    ex2_is_mtcr_q                                         ; //  input=>dec_byp_ex1_is_mtcr             ,act=>exx_xu0_act[1]
	wire                          ex2_is_mfctr_q                                        ; //  input=>dec_byp_ex1_is_mfctr            ,act=>exx_xu0_act[1]
	wire                          ex3_is_mtxer_q                                        ; //  input=>ex2_is_mtxer_q                  ,act=>exx_xu0_act[2]
	wire [64-`GPR_WIDTH:63]       ex4_xu0_rt_q,              ex3_xu0_rt_nobyp           ; //  input=>ex3_xu0_rt_nobyp                ,act=>exx_xu0_act[3]
	wire [64-`GPR_WIDTH:63]       ex5_xu0_rt_q,              ex4_xu0_rt_nobyp           ; //  input=>ex4_xu0_rt_nobyp                ,act=>exx_xu0_act[4]
	wire [64-`GPR_WIDTH:63]       ex6_xu0_rt_q,              ex5_xu0_rt                 ; //  input=>ex5_xu0_rt                      ,act=>exx_xu0_act[5]
	wire [64-`GPR_WIDTH:63]       ex7_xu0_rt_q,              ex6_xu0_rt                 ; //  input=>ex6_xu0_rt                      ,act=>exx_xu0_act[6]
	wire [64-`GPR_WIDTH:63]       ex8_xu0_rt_q                                          ; //  input=>ex7_xu0_rt_q                    ,act=>exx_xu0_act[7]
	wire [64-`GPR_WIDTH:63]       ex6_lq_rt_q                                           ; //  input=>lq_xu_ex5_rt                    ,act=>exx_lq_act[5]
	wire [64-`GPR_WIDTH:63]       ex7_lq_rt_q                                           ; //  input=>ex6_lq_rt_q                     ,act=>exx_lq_act[6]
	wire [64-`GPR_WIDTH:63]       ex8_lq_rt_q                                           ; //  input=>ex7_lq_rt_q                     ,act=>exx_lq_act[7]
	wire [0:3]                    ex4_xu0_cr_q,              ex3_xu0_cr                 ; //  input=>ex3_xu0_cr                      ,act=>exx_xu0_act[3]
	wire [0:3]                    ex5_xu0_cr_q                                          ; //  input=>ex4_xu0_cr_q                    ,act=>exx_xu0_act[4]
	wire [0:3]                    ex6_xu0_cr_q,              ex5_xu0_cr                 ; //  input=>ex5_xu0_cr                      ,act=>exx_xu0_act[5]
	wire [0:3]                    ex6_lq_cr_q                                           ; //  input=>lq_xu_ex5_cr                    ,act=>exx_lq_act[5]
	wire [0:9]                    ex4_xu0_xer_q,             ex3_xu0_xer2               ; //  input=>ex3_xu0_xer2                    ,act=>exx_xu0_act[3]
	wire [0:9]                    ex5_xu0_xer_q                                         ; //  input=>ex4_xu0_xer_q                   ,act=>exx_xu0_act[4]
	wire [0:9]                    ex6_xu0_xer_q,             ex5_xu0_xer                ; //  input=>ex5_xu0_xer                     ,act=>exx_xu0_act[5]
	wire [64-`GPR_WIDTH:63]       ex4_xu0_ctr_q,             ex3_xu0_ctr                ; //  input=>ex3_xu0_ctr                     ,act=>ex3_xu0_ctr_act
	wire [64-`GPR_WIDTH:63]       ex4_xu0_lr_q,              ex3_xu0_lr                 ; //  input=>ex3_xu0_lr                      ,act=>ex3_xu0_lr_act
	wire [64-`GPR_WIDTH:63]       ex2_rs1_q,                 ex1_rs1                    ; //  input=>ex1_rs1                         ,act=>ex1_xu0_ivax_act
	wire [64-`GPR_WIDTH:63]       ex2_rs2_q,                 ex1_rs2                    ; //  input=>ex1_rs2                         ,act=>exx_xu0_act[1]
	wire [0:3]                    ex2_cr1_q,                 ex1_cr1                    ; //  input=>ex1_cr1                         ,act=>exx_xu0_act[1]
	wire [0:3]                    ex2_cr2_q,                 ex1_cr2                    ; //  input=>ex1_cr2                         ,act=>exx_xu0_act[1]
	wire [0:3]                    ex2_cr3_q,                 ex1_cr3                    ; //  input=>ex1_cr3                         ,act=>exx_xu0_act[1]
	wire                          ex2_cr_bit_q,              ex1_cr_bit                 ; //  input=>ex1_cr_bit                      ,act=>exx_xu0_act[1]
	wire [0:9]                    ex2_xer2_q,                ex1_xer2                   ; //  input=>ex1_xer2                        ,act=>exx_xu0_act[1]
	wire [0:9]                    ex2_xer3_q,                ex1_xer3                   ; //  input=>ex1_xer3                        ,act=>exx_xu0_act[1]
	wire [0:0]                    ex3_xer3_q                                            ; //  input=>ex2_xer3_q[0:0]                 ,act=>exx_xu0_act[2]
	wire [64-`GPR_WIDTH:63]       ex2_lr1_q,                 ex1_lr1                    ; //  input=>ex1_lr1                         ,act=>exx_xu0_act[1]
	wire [64-`GPR_WIDTH:63]       ex2_lr2_q,                 ex1_lr2                    ; //  input=>ex1_lr2                         ,act=>exx_xu0_act[1]
	wire [64-`GPR_WIDTH:63]       ex2_ctr2_q,                ex1_ctr2                   ; //  input=>ex1_ctr2                        ,act=>exx_xu0_act[1]
	wire [2:3]                    ex2_cr_sel_q                                          ; //  input=>dec_byp_ex1_cr_sel              ,act=>exx_xu0_act[1]
	wire [2:3]                    ex2_xer_sel_q                                         ; //  input=>dec_byp_ex1_xer_sel             ,act=>exx_xu0_act[1]
	wire [64-`GPR_WIDTH:63]       ex3_rs1_q                                             ; //  input=>ex2_rs1_q                       ,act=>exx_xu0_act[2]
	wire                          ex3_mfspr_sel_q,           ex2_mfspr_sel              ; //  input=>ex2_mfspr_sel                   ,act=>exx_xu0_act[2]
	wire [64-`GPR_WIDTH:63]       ex3_mfspr_rt_q,            ex2_mfspr_rt               ; //  input=>ex2_mfspr_rt                    ,act=>ex2_mfspr_act
	wire [64-`GPR_WIDTH:63]       ord_rt_data_q,             ord_rt_data_d              ; //  input=>ord_rt_data_d                   ,act=>ord_data_act
	wire [0:3]                    ord_cr_data_q,             ord_cr_data_d              ; //  input=>ord_cr_data_d                   ,act=>ord_data_act
	wire [0:9]                    ord_xer_data_q,            ord_xer_data_d             ; //  input=>ord_xer_data_d                  ,act=>ord_data_act
	wire                          ex2_rs_capt_q                                         ; //  input=>dec_byp_ex1_rs_capt             ,act=>1'b1
	wire                          ex2_ra_capt_q                                         ; //  input=>dec_byp_ex1_ra_capt             ,act=>1'b1
	wire                          ex3_ra_capt_q                                         ; //  input=>ex2_ra_capt_q                   ,act=>1'b1
	wire                          ex4_ra_capt_q                                         ; //  input=>ex3_ra_capt_q                   ,act=>1'b1
	wire [52:63]                  ex2_rs2_noimm_q                                       ; //  input=>ex1_rs2_noimm[52:63]            ,act=>exx_xu0_act[1]
	wire [0:3]                    ex3_mtcr_q,                ex2_mtcr                   ; //  input=>ex2_mtcr                        ,act=>exx_xu0_act[2]
	wire                          ex3_mtcr_sel_q,            ex2_mtcr_sel               ; //  input=>ex2_mtcr_sel                    ,act=>exx_xu0_act[2]
	wire [0:8]                    mm_rs_is_q,                mm_rs_is_d                 ; //  input=>mm_rs_is_d                      ,act=>ex2_rs_capt_q
	wire [0:11]                   mm_ra_entry_q,             mm_ra_entry_d              ; //  input=>mm_ra_entry_d                   ,act=>ex2_ra_capt_q
	wire [64-`GPR_WIDTH:63]       mm_data_q,                 mm_data_d                  ; //  input=>mm_data_d                       ,act=>ex4_ra_capt_q
	wire [57:63]                  ex3_cnt_rt_q                                          ; //  input=>cnt_byp_ex2_rt                  ,act=>exx_xu0_act[2]
	wire [56:63]                  ex3_prm_rt_q                                          ; //  input=>prm_byp_ex2_rt                  ,act=>exx_xu0_act[2]
	wire [60:63]                  ex3_dlm_rt_q                                          ; //  input=>dlm_byp_ex2_rt                  ,act=>exx_xu0_act[2]
	wire [0:9]                    ex3_dlm_xer_q                                         ; //  input=>dlm_byp_ex2_xer                 ,act=>exx_xu0_act[2]
	wire [0:3]                    ex3_dlm_cr_q                                          ; //  input=>dlm_byp_ex2_cr                  ,act=>exx_xu0_act[2]
	wire [0:0]                    ex6_mul_ord_done_q                                    ; //  input=>{1{mul_byp_ex5_ord_done}}       ,act=>1'b1
        wire                          ex6_mul_abort_q                                       ; //  input=>mul_byp_ex5_abort               ,act=>1'b1
	wire [0:8]                    ex6_mul_done_q                                        ; //  input=>{9{mul_byp_ex5_done}}           ,act=>1'b1
   wire [2:12]                   exx_xu0_abort_q,           exx_xu0_abort_d            ; //  input=>exx_xu0_abort_d                 ,act=>1'b1
   wire [3:7]                    exx_xu1_abort_q,           exx_xu1_abort_d            ; //  input=>exx_xu1_abort_d                 ,act=>1'b1
   wire [6:9]                    exx_lq_abort_q,            exx_lq_abort_d             ; //  input=>exx_lq_abort_d                  ,act=>1'b1
   wire                          ex2_rs1_abort_q                                       ; //  input=>ex1_rs1_abort                   ,act=>1'b1
   wire                          ex2_rs2_abort_q                                       ; //  input=>ex1_rs2_abort                   ,act=>1'b1
   wire                          ex2_rs3_abort_q                                       ; //  input=>ex1_rs3_abort                   ,act=>1'b1
   wire                          exx_rel3_act_q                                        ; //  input=>lq_xu_rel_act                   ,act=>1'b1
   wire [64-`GPR_WIDTH:63]       exx_rel3_rt_q                                         ; //  input=>lq_xu_rel_rt                    ,act=>lq_xu_rel_act
   wire [64-`GPR_WIDTH:63]       exx_rel4_rt_q                                         ; //  input=>exx_rel3_rt_q                   ,act=>exx_rel3_act_q
   // Scanchain
	localparam exx_xu0_act_offset                         = 0;
	localparam exx_lq_act_offset                          = exx_xu0_act_offset             + 7;
	localparam ex1_s1_v_offset                            = exx_lq_act_offset              + 3;
	localparam ex1_s2_v_offset                            = ex1_s1_v_offset                + 1;
	localparam ex1_s3_v_offset                            = ex1_s2_v_offset                + 1;
	localparam ex1_gpr_s1_xu0_sel_offset                  = ex1_s3_v_offset                + 1;
	localparam ex1_gpr_s2_xu0_sel_offset                  = ex1_gpr_s1_xu0_sel_offset      + 8*7;
	localparam ex1_gpr_s1_xu1_sel_offset                  = ex1_gpr_s2_xu0_sel_offset      + 8*7;
	localparam ex1_gpr_s2_xu1_sel_offset                  = ex1_gpr_s1_xu1_sel_offset      + 8*4;
	localparam ex1_gpr_s1_lq_sel_offset                   = ex1_gpr_s2_xu1_sel_offset      + 8*4;
	localparam ex1_gpr_s2_lq_sel_offset                   = ex1_gpr_s1_lq_sel_offset       + 8*4;
	localparam ex1_gpr_s2_imm_sel_offset                  = ex1_gpr_s2_lq_sel_offset       + 8*4;
	localparam ex1_spr_s1_xu0_sel_offset                  = ex1_gpr_s2_imm_sel_offset      + 8;
	localparam ex1_spr_s1_xu1_sel_offset                  = ex1_spr_s1_xu0_sel_offset      + 3*4;
	localparam ex1_spr_s1_lq_sel_offset                   = ex1_spr_s1_xu1_sel_offset      + 1*1;
	localparam ex1_spr_s2_xu0_sel_offset                  = ex1_spr_s1_lq_sel_offset       + 1*2;
	localparam ex1_spr_s2_xu1_sel_offset                  = ex1_spr_s2_xu0_sel_offset      + 6*4;
	localparam ex1_spr_s2_lq_sel_offset                   = ex1_spr_s2_xu1_sel_offset      + 2*1;
	localparam ex1_spr_s3_xu0_sel_offset                  = ex1_spr_s2_lq_sel_offset       + 1*2;
	localparam ex1_spr_s3_xu1_sel_offset                  = ex1_spr_s3_xu0_sel_offset      + 2*6;
	localparam ex1_spr_s3_lq_sel_offset                   = ex1_spr_s3_xu1_sel_offset      + 2*3;
	localparam ex1_gpr_s1_rel_sel_offset                  = ex1_spr_s3_lq_sel_offset       + 1*2;
	localparam ex1_gpr_s2_rel_sel_offset                  = ex1_gpr_s1_rel_sel_offset      + 8*2;
	localparam ex1_gpr_s1_reg_sel_offset                  = ex1_gpr_s2_rel_sel_offset      + 8*2;
	localparam ex1_gpr_s2_reg_sel_offset                  = ex1_gpr_s1_reg_sel_offset      + 8;
	localparam ex1_spr_s1_reg_sel_offset                  = ex1_gpr_s2_reg_sel_offset      + 8;
	localparam ex1_spr_s2_reg_sel_offset                  = ex1_spr_s1_reg_sel_offset      + 3;
	localparam ex1_spr_s3_reg_sel_offset                  = ex1_spr_s2_reg_sel_offset      + 6;
	localparam ex1_abt_s1_lq_sel_offset                   = ex1_spr_s3_reg_sel_offset      + 2;
	localparam ex1_abt_s2_lq_sel_offset                   = ex1_abt_s1_lq_sel_offset       + 1;
	localparam ex1_abt_s3_lq_sel_offset                   = ex1_abt_s2_lq_sel_offset       + 1;
	localparam ex1_abt_s1_xu1_sel_offset                  = ex1_abt_s3_lq_sel_offset       + 3;
	localparam ex1_abt_s2_xu1_sel_offset                  = ex1_abt_s1_xu1_sel_offset      + 2;
	localparam ex1_abt_s3_xu1_sel_offset                  = ex1_abt_s2_xu1_sel_offset      + 2;
	localparam ex1_abt_s1_xu0_sel_offset                  = ex1_abt_s3_xu1_sel_offset      + 2;
	localparam ex1_abt_s2_xu0_sel_offset                  = ex1_abt_s1_xu0_sel_offset      + 4;
	localparam ex1_abt_s3_xu0_sel_offset                  = ex1_abt_s2_xu0_sel_offset      + 4;
	localparam ex2_is_mflr_offset                         = ex1_abt_s3_xu0_sel_offset      + 4;
	localparam ex2_is_mfxer_offset                        = ex2_is_mflr_offset             + 1;
	localparam ex2_is_mtxer_offset                        = ex2_is_mfxer_offset            + 1;
	localparam ex2_is_mfcr_sel_offset                     = ex2_is_mtxer_offset            + 1;
	localparam ex2_is_mfcr_offset                         = ex2_is_mfcr_sel_offset         + 1;
	localparam ex2_is_mtcr_offset                         = ex2_is_mfcr_offset             + 8;
	localparam ex2_is_mfctr_offset                        = ex2_is_mtcr_offset             + 8;
	localparam ex3_is_mtxer_offset                        = ex2_is_mfctr_offset            + 1;
	localparam ex4_xu0_rt_offset                          = ex3_is_mtxer_offset            + 1;
	localparam ex5_xu0_rt_offset                          = ex4_xu0_rt_offset              + `GPR_WIDTH;
	localparam ex6_xu0_rt_offset                          = ex5_xu0_rt_offset              + `GPR_WIDTH;
	localparam ex7_xu0_rt_offset                          = ex6_xu0_rt_offset              + `GPR_WIDTH;
	localparam ex8_xu0_rt_offset                          = ex7_xu0_rt_offset              + `GPR_WIDTH;
	localparam ex6_lq_rt_offset                           = ex8_xu0_rt_offset              + `GPR_WIDTH;
	localparam ex7_lq_rt_offset                           = ex6_lq_rt_offset               + `GPR_WIDTH;
	localparam ex8_lq_rt_offset                           = ex7_lq_rt_offset               + `GPR_WIDTH;
	localparam ex4_xu0_cr_offset                          = ex8_lq_rt_offset               + `GPR_WIDTH;
	localparam ex5_xu0_cr_offset                          = ex4_xu0_cr_offset              + 4;
	localparam ex6_xu0_cr_offset                          = ex5_xu0_cr_offset              + 4;
	localparam ex6_lq_cr_offset                           = ex6_xu0_cr_offset              + 4;
	localparam ex4_xu0_xer_offset                         = ex6_lq_cr_offset               + 4;
	localparam ex5_xu0_xer_offset                         = ex4_xu0_xer_offset             + 10;
	localparam ex6_xu0_xer_offset                         = ex5_xu0_xer_offset             + 10;
	localparam ex4_xu0_ctr_offset                         = ex6_xu0_xer_offset             + 10;
	localparam ex4_xu0_lr_offset                          = ex4_xu0_ctr_offset             + `GPR_WIDTH;
	localparam ex2_rs1_offset                             = ex4_xu0_lr_offset              + `GPR_WIDTH;
	localparam ex2_rs2_offset                             = ex2_rs1_offset                 + `GPR_WIDTH;
	localparam ex2_cr1_offset                             = ex2_rs2_offset                 + `GPR_WIDTH;
	localparam ex2_cr2_offset                             = ex2_cr1_offset                 + 4;
	localparam ex2_cr3_offset                             = ex2_cr2_offset                 + 4;
	localparam ex2_cr_bit_offset                          = ex2_cr3_offset                 + 4;
	localparam ex2_xer2_offset                            = ex2_cr_bit_offset              + 1;
	localparam ex2_xer3_offset                            = ex2_xer2_offset                + 10;
	localparam ex3_xer3_offset                            = ex2_xer3_offset                + 10;
	localparam ex2_lr1_offset                             = ex3_xer3_offset                + 1;
	localparam ex2_lr2_offset                             = ex2_lr1_offset                 + `GPR_WIDTH;
	localparam ex2_ctr2_offset                            = ex2_lr2_offset                 + `GPR_WIDTH;
	localparam ex2_cr_sel_offset                          = ex2_ctr2_offset                + `GPR_WIDTH;
	localparam ex2_xer_sel_offset                         = ex2_cr_sel_offset              + 2;
	localparam ex3_rs1_offset                             = ex2_xer_sel_offset             + 2;
	localparam ex3_mfspr_sel_offset                       = ex3_rs1_offset                 + `GPR_WIDTH;
	localparam ex3_mfspr_rt_offset                        = ex3_mfspr_sel_offset           + 1;
	localparam ord_rt_data_offset                         = ex3_mfspr_rt_offset            + `GPR_WIDTH;
	localparam ord_cr_data_offset                         = ord_rt_data_offset             + `GPR_WIDTH;
	localparam ord_xer_data_offset                        = ord_cr_data_offset             + 4;
	localparam ex2_rs_capt_offset                         = ord_xer_data_offset            + 10;
	localparam ex2_ra_capt_offset                         = ex2_rs_capt_offset             + 1;
	localparam ex3_ra_capt_offset                         = ex2_ra_capt_offset             + 1;
	localparam ex4_ra_capt_offset                         = ex3_ra_capt_offset             + 1;
	localparam ex2_rs2_noimm_offset                       = ex4_ra_capt_offset             + 1;
	localparam ex3_mtcr_offset                            = ex2_rs2_noimm_offset           + 12;
	localparam ex3_mtcr_sel_offset                        = ex3_mtcr_offset                + 4;
	localparam mm_rs_is_offset                            = ex3_mtcr_sel_offset            + 1;
	localparam mm_ra_entry_offset                         = mm_rs_is_offset                + 9;
	localparam mm_data_offset                             = mm_ra_entry_offset             + 12;
	localparam ex3_cnt_rt_offset                          = mm_data_offset                 + `GPR_WIDTH;
	localparam ex3_prm_rt_offset                          = ex3_cnt_rt_offset              + 7;
	localparam ex3_dlm_rt_offset                          = ex3_prm_rt_offset              + 8;
	localparam ex3_dlm_xer_offset                         = ex3_dlm_rt_offset              + 4;
	localparam ex3_dlm_cr_offset                          = ex3_dlm_xer_offset             + 10;
	localparam ex6_mul_ord_done_offset                    = ex3_dlm_cr_offset              + 4;
        localparam ex6_mul_abort_offset                       = ex6_mul_ord_done_offset        + 1;
	localparam ex6_mul_done_offset                        = ex6_mul_abort_offset           + 1;
	localparam exx_xu0_abort_offset                       = ex6_mul_done_offset            + 9;
	localparam exx_xu1_abort_offset                       = exx_xu0_abort_offset           + 11;
	localparam exx_lq_abort_offset                        = exx_xu1_abort_offset           + 5;
	localparam ex2_rs1_abort_offset                       = exx_lq_abort_offset            + 4;
	localparam ex2_rs2_abort_offset                       = ex2_rs1_abort_offset           + 1;
	localparam ex2_rs3_abort_offset                       = ex2_rs2_abort_offset           + 1;
	localparam exx_rel3_act_offset                        = ex2_rs3_abort_offset           + 1;
	localparam exx_rel3_rt_offset                         = exx_rel3_act_offset            + 1;
	localparam exx_rel4_rt_offset                         = exx_rel3_rt_offset             + `GPR_WIDTH;
   localparam scan_right                                 = exx_rel4_rt_offset             + `GPR_WIDTH;
   wire [0:scan_right-1]                  siv;
   wire [0:scan_right-1]                  sov;
   (* analysis_not_referenced="<8:63>true" *)
   wire [0:63]                            tidn = 64'b0;
   // Signals
   wire [0:8-1]                           exx_xu0_act;
   wire [5:9-1]                           exx_lq_act;
   wire                                   ex0_gpr_s1_reg_sel;
   wire                                   ex0_spr_s1_reg_sel;
   wire                                   ex0_gpr_s2_reg_sel;
   wire                                   ex0_spr_s2_reg_sel;
   wire                                   ex0_spr_s3_reg_sel;
   wire [1:11]                            ex0_gpr_s1_xu0_sel;
   wire [1:11]                            ex0_gpr_s2_xu0_sel;
   wire [1:6]                             ex0_gpr_s1_xu1_sel;
   wire [1:6]                             ex0_gpr_s2_xu1_sel;
   wire [4:8]                             ex0_gpr_s1_lq_sel;
   wire [4:8]                             ex0_gpr_s2_lq_sel;
   wire [2:3]                             ex0_gpr_s1_rel_sel;
   wire [2:3]                             ex0_gpr_s2_rel_sel;
   wire                                   ex0_gpr_rs1_sel_zero_b;
   wire                                   ord_sel_slowspr;
   wire                                   ord_sel_ones;
   wire                                   ord_data_act;
   wire [0:3]                             iu_ord_cr;
   wire [0:3]                             lq_ord_cr;
   wire [0:3]                             mm_ord_cr;
   wire [0:3]                             ex2_cr;
   wire [0:9]                             ex2_xer;
   wire [64-`GPR_WIDTH:63]                ex2_mfcr_rt;
   wire [64-`GPR_WIDTH:63]                ex2_mfxer_rt;
   wire [0:3]                             ex3_alu2_cr;
   wire [64-`GPR_WIDTH:63]                ex1_rs2_noimm;
   wire [8-`GPR_WIDTH/8:7]                ex6_parity;
   wire [0:9]                             ex3_mtxer;
   wire [0:3]                             ex6_xu0_cr;
   wire [0:9]                             ex6_xu0_xer;
   wire [64-`GPR_WIDTH:63]                ex3_cnt_rt;
   wire [64-`GPR_WIDTH:63]                ex3_prm_rt;
   wire [64-`GPR_WIDTH:63]                ex3_dlm_rt;
   wire [0:3]                             ex3_xu0_cr2, ex3_xu0_cr3;
   wire [0:3]                             ex3_cnt_cr;
   wire                                   ex3_cnt_zero;
   wire [64-`GPR_WIDTH:63]                ex3_xu0_rt_nobyp2;
   wire [64-`GPR_WIDTH:63]                ex3_xu0_rt_nobyp3;
   wire [64-`GPR_WIDTH:63]                ex3_xu0_rt_nobyp4;
   wire [64-`GPR_WIDTH:63]                ex3_xu0_rt_nobyp5;
   wire [0:9]                             ex3_xu0_xer;
   wire                                   ex2_mfspr_act;
   wire                                   ex3_xu0_lr_act;
   wire                                   ex3_xu0_ctr_act;
   wire                                   ex0_xu0_ivax_act;
   wire                                   ex1_xu0_ivax_act;
   wire [0:31]                            xu0_iu_bta_int;
   wire                                   ex1_abort;
   wire                                   ex1_rs1_abort, ex1_rs2_noimm_abort;
   wire                                   ex1_rs2_abort;
   wire                                   ex1_rs3_abort;
   wire                                   ex6_xu0_abort;

   //<<TODO>>  Check XU0 vs XU1 everywhere (incl. clock gates,  esp.  muxes)

   //------------------------------------------------------------------------------------------
   // Zero/Immediate Logic for GPRs
   //------------------------------------------------------------------------------------------
   assign ex0_gpr_s1_xu0_sel     = ex0_gpr_rs1_sel_zero_b==1'b1 ? rv_xu0_s1_fxu0_sel   : tidn[1:11];
   assign ex0_gpr_s1_xu1_sel     = ex0_gpr_rs1_sel_zero_b==1'b1 ? rv_xu0_s1_fxu1_sel   : tidn[1:6];
   assign ex0_gpr_s1_lq_sel      = ex0_gpr_rs1_sel_zero_b==1'b1 ? rv_xu0_s1_lq_sel     : tidn[4:8];
   assign ex0_gpr_s1_rel_sel     = ex0_gpr_rs1_sel_zero_b==1'b1 ? rv_xu0_s1_rel_sel    : tidn[2:3];

   assign ex0_gpr_s2_xu0_sel     = rv_xu0_s2_fxu0_sel;
   assign ex0_gpr_s2_xu1_sel     = rv_xu0_s2_fxu1_sel;
   assign ex0_gpr_s2_lq_sel      = rv_xu0_s2_lq_sel;
   assign ex0_gpr_s2_rel_sel     = rv_xu0_s2_rel_sel;

   // TEMP Hopefully fold this into rf_byp
   assign ex0_gpr_s1_reg_sel = ~|rv_xu0_s1_fxu0_sel[1:7] & ~|rv_xu0_s1_fxu1_sel[1:4] & ~|rv_xu0_s1_lq_sel[4:7] & ~|rv_xu0_s1_rel_sel & ex0_gpr_rs1_sel_zero_b;
   assign ex0_gpr_s2_reg_sel = ~|rv_xu0_s2_fxu0_sel[1:7] & ~|rv_xu0_s2_fxu1_sel[1:4] & ~|rv_xu0_s2_lq_sel[4:7] & ~|rv_xu0_s2_rel_sel;
   assign ex0_spr_s1_reg_sel = ~|rv_xu0_s1_fxu0_sel[2:5] & ~|rv_xu0_s1_fxu1_sel[2:2] & ~|rv_xu0_s1_lq_sel[4:5];
   assign ex0_spr_s2_reg_sel = ~|rv_xu0_s2_fxu0_sel[2:5] & ~|rv_xu0_s2_fxu1_sel[2:2] & ~|rv_xu0_s2_lq_sel[4:5];
   assign ex0_spr_s3_reg_sel = ~|rv_xu0_s3_fxu0_sel[2:5] & ~|rv_xu0_s3_fxu1_sel[2:2] & ~|rv_xu0_s3_lq_sel[4:5];

   assign ex0_gpr_rs1_sel_zero_b = ~dec_byp_ex0_rs1_sel_zero;

   //------------------------------------------------------------------------------------------
   // GPR Bypass
   //------------------------------------------------------------------------------------------
   assign ex1_rs1 =   (alu_byp_ex2_add_rt       & fanout(ex1_gpr_s1_xu0_sel_q[2], `GPR_WIDTH)) |
                      (ex3_xu0_rt_nobyp         & fanout(ex1_gpr_s1_xu0_sel_q[3], `GPR_WIDTH)) |
                      (ex4_xu0_rt_q             & fanout(ex1_gpr_s1_xu0_sel_q[4], `GPR_WIDTH)) |
                      (ex5_xu0_rt_q             & fanout(ex1_gpr_s1_xu0_sel_q[5], `GPR_WIDTH)) |
                      (ex6_xu0_rt               & fanout(ex1_gpr_s1_xu0_sel_q[6], `GPR_WIDTH)) |
                      (ex7_xu0_rt_q             & fanout(ex1_gpr_s1_xu0_sel_q[7], `GPR_WIDTH)) |
                      (ex8_xu0_rt_q             & fanout(ex1_gpr_s1_xu0_sel_q[8], `GPR_WIDTH)) |
                      (xu1_xu0_ex2_rt           & fanout(ex1_gpr_s1_xu1_sel_q[2], `GPR_WIDTH)) |
                      (xu1_xu0_ex3_rt           & fanout(ex1_gpr_s1_xu1_sel_q[3], `GPR_WIDTH)) |
                      (xu1_xu0_ex4_rt           & fanout(ex1_gpr_s1_xu1_sel_q[4], `GPR_WIDTH)) |
                      (xu1_xu0_ex5_rt           & fanout(ex1_gpr_s1_xu1_sel_q[5], `GPR_WIDTH)) |
                      (lq_xu_ex5_rt             & fanout(ex1_gpr_s1_lq_sel_q[5], `GPR_WIDTH)) |
                      (ex6_lq_rt_q              & fanout(ex1_gpr_s1_lq_sel_q[6], `GPR_WIDTH)) |
                      (ex7_lq_rt_q              & fanout(ex1_gpr_s1_lq_sel_q[7], `GPR_WIDTH)) |
                      (ex8_lq_rt_q              & fanout(ex1_gpr_s1_lq_sel_q[8], `GPR_WIDTH)) |
                      (exx_rel3_rt_q            & fanout(ex1_gpr_s1_rel_sel_q[3], `GPR_WIDTH)) |
                      (exx_rel4_rt_q            & fanout(ex1_gpr_s1_rel_sel_q[4], `GPR_WIDTH)) |
                      (gpr_xu0_ex1_r1d          & fanout(ex1_gpr_s1_reg_sel_q[0:7], `GPR_WIDTH));

   assign ex1_rs2 =  (dec_byp_ex1_imm           &  fanout(ex1_gpr_s2_imm_sel_q, `GPR_WIDTH)) |
                     (ex1_rs2_noimm             & ~fanout(ex1_gpr_s2_imm_sel_q, `GPR_WIDTH));

   assign ex1_rs2_noimm =
                     (alu_byp_ex2_add_rt        & fanout(ex1_gpr_s2_xu0_sel_q[2], `GPR_WIDTH)) |
                     (ex3_xu0_rt_nobyp          & fanout(ex1_gpr_s2_xu0_sel_q[3], `GPR_WIDTH)) |
                     (ex4_xu0_rt_q              & fanout(ex1_gpr_s2_xu0_sel_q[4], `GPR_WIDTH)) |
                     (ex5_xu0_rt_q              & fanout(ex1_gpr_s2_xu0_sel_q[5], `GPR_WIDTH)) |
                     (ex6_xu0_rt                & fanout(ex1_gpr_s2_xu0_sel_q[6], `GPR_WIDTH)) |
                     (ex7_xu0_rt_q              & fanout(ex1_gpr_s2_xu0_sel_q[7], `GPR_WIDTH)) |
                     (ex8_xu0_rt_q              & fanout(ex1_gpr_s2_xu0_sel_q[8], `GPR_WIDTH)) |
                     (xu1_xu0_ex2_rt            & fanout(ex1_gpr_s2_xu1_sel_q[2], `GPR_WIDTH)) |
                     (xu1_xu0_ex3_rt            & fanout(ex1_gpr_s2_xu1_sel_q[3], `GPR_WIDTH)) |
                     (xu1_xu0_ex4_rt            & fanout(ex1_gpr_s2_xu1_sel_q[4], `GPR_WIDTH)) |
                     (xu1_xu0_ex5_rt            & fanout(ex1_gpr_s2_xu1_sel_q[5], `GPR_WIDTH)) |
                     (lq_xu_ex5_rt              & fanout(ex1_gpr_s2_lq_sel_q[5], `GPR_WIDTH)) |
                     (ex6_lq_rt_q               & fanout(ex1_gpr_s2_lq_sel_q[6], `GPR_WIDTH)) |
                     (ex7_lq_rt_q               & fanout(ex1_gpr_s2_lq_sel_q[7], `GPR_WIDTH)) |
                     (ex8_lq_rt_q               & fanout(ex1_gpr_s2_lq_sel_q[8], `GPR_WIDTH)) |
                     (exx_rel3_rt_q             & fanout(ex1_gpr_s2_rel_sel_q[3], `GPR_WIDTH)) |
                     (exx_rel4_rt_q             & fanout(ex1_gpr_s2_rel_sel_q[4], `GPR_WIDTH)) |
                     (gpr_xu0_ex1_r2d           & fanout(ex1_gpr_s2_reg_sel_q[0:7], `GPR_WIDTH));

   //------------------------------------------------------------------------------------------
   // Abort Bypass
   //------------------------------------------------------------------------------------------
   assign ex6_xu0_abort         = (exx_xu0_abort_q[6] & ~ex6_mul_done_q[8]) |
                                  (ex6_mul_abort_q    &  ex6_mul_done_q[8]) ;

   assign exx_xu0_abort_d[2:6]  = {ex1_abort, exx_xu0_abort_q[2:5]};
   assign exx_xu0_abort_d[7]    = ex6_xu0_abort;
   assign exx_xu0_abort_d[8:12] = exx_xu0_abort_q[7:11];

   assign exx_xu1_abort_d = {xu1_xu0_ex2_abort, exx_xu1_abort_q[3:6]};
   assign exx_lq_abort_d  = {lq_xu_ex5_abort, exx_lq_abort_q[6:8]};

   assign ex1_abort = ex1_rs1_abort | ex1_rs2_abort | ex1_rs3_abort;

   assign ex1_rs1_abort = exx_xu0_act[1] & ex1_s1_v_q &
                    ((exx_xu0_abort_q[2]     & ex1_gpr_s1_xu0_sel_q[2][0]) |
                     (exx_xu0_abort_q[3]     & ex1_gpr_s1_xu0_sel_q[3][0]) |
                     (exx_xu0_abort_q[4]     & ex1_gpr_s1_xu0_sel_q[4][0]) |
                     (exx_xu0_abort_q[5]     & ex1_gpr_s1_xu0_sel_q[5][0]) |
                     (ex6_xu0_abort          & ex1_gpr_s1_xu0_sel_q[6][0]) | //mul abort
                     (exx_xu0_abort_q[7]     & ex1_gpr_s1_xu0_sel_q[7][0]) |
                     (exx_xu0_abort_q[8]     & ex1_gpr_s1_xu0_sel_q[8][0]) |
                     (exx_xu0_abort_q[9]     & ex1_abt_s1_xu0_sel_q[9]   ) |
                     (exx_xu0_abort_q[10]    & ex1_abt_s1_xu0_sel_q[10]  ) |
                     (exx_xu0_abort_q[11]    & ex1_abt_s1_xu0_sel_q[11]  ) |
                     (exx_xu0_abort_q[12]    & ex1_abt_s1_xu0_sel_q[12]  ) |
                     (xu1_xu0_ex2_abort      & ex1_gpr_s1_xu1_sel_q[2][0]) |
                     (exx_xu1_abort_q[3]     & ex1_gpr_s1_xu1_sel_q[3][0]) |
                     (exx_xu1_abort_q[4]     & ex1_gpr_s1_xu1_sel_q[4][0]) |
                     (exx_xu1_abort_q[5]     & ex1_gpr_s1_xu1_sel_q[5][0]) |
                     (exx_xu1_abort_q[6]     & ex1_abt_s1_xu1_sel_q[6]) |
                     (exx_xu1_abort_q[7]     & ex1_abt_s1_xu1_sel_q[7]) |
                     (lq_xu_ex5_abort        & ex1_gpr_s1_lq_sel_q[5][0]) |
                     (exx_lq_abort_q[6]      & ex1_gpr_s1_lq_sel_q[6][0]) |
                     (exx_lq_abort_q[7]      & ex1_gpr_s1_lq_sel_q[7][0]) |
                     (exx_lq_abort_q[8]      & ex1_gpr_s1_lq_sel_q[8][0]) |
                     (exx_lq_abort_q[9]      & ex1_abt_s1_lq_sel_q[9]) |
                     (1'b0                   & ex1_gpr_s1_reg_sel_q[0]));

   assign ex1_rs2_abort = exx_xu0_act[1] & ex1_s2_v_q &
                     (ex1_rs2_noimm_abort );

   assign ex1_rs2_noimm_abort =
                    ((exx_xu0_abort_q[2]     & ex1_gpr_s2_xu0_sel_q[2][0]) |
                     (exx_xu0_abort_q[3]     & ex1_gpr_s2_xu0_sel_q[3][0]) |
                     (exx_xu0_abort_q[4]     & ex1_gpr_s2_xu0_sel_q[4][0]) |
                     (exx_xu0_abort_q[5]     & ex1_gpr_s2_xu0_sel_q[5][0]) |
                     (ex6_xu0_abort          & ex1_gpr_s2_xu0_sel_q[6][0]) |
                     (exx_xu0_abort_q[7]     & ex1_gpr_s2_xu0_sel_q[7][0]) |
                     (exx_xu0_abort_q[8]     & ex1_gpr_s2_xu0_sel_q[8][0]) |
                     (exx_xu0_abort_q[9]     & ex1_abt_s2_xu0_sel_q[9]   ) |
                     (exx_xu0_abort_q[10]    & ex1_abt_s2_xu0_sel_q[10]  ) |
                     (exx_xu0_abort_q[11]    & ex1_abt_s2_xu0_sel_q[11]  ) |
                     (exx_xu0_abort_q[12]    & ex1_abt_s2_xu0_sel_q[12]  ) |
                     (xu1_xu0_ex2_abort      & ex1_gpr_s2_xu1_sel_q[2][0]) |
                     (exx_xu1_abort_q[3]     & ex1_gpr_s2_xu1_sel_q[3][0]) |
                     (exx_xu1_abort_q[4]     & ex1_gpr_s2_xu1_sel_q[4][0]) |
                     (exx_xu1_abort_q[5]     & ex1_gpr_s2_xu1_sel_q[5][0]) |
                     (exx_xu1_abort_q[6]     & ex1_abt_s2_xu1_sel_q[6]) |
                     (exx_xu1_abort_q[7]     & ex1_abt_s2_xu1_sel_q[7]) |
                     (lq_xu_ex5_abort        & ex1_gpr_s2_lq_sel_q[5][0]) |
                     (exx_lq_abort_q[6]      & ex1_gpr_s2_lq_sel_q[6][0]) |
                     (exx_lq_abort_q[7]      & ex1_gpr_s2_lq_sel_q[7][0]) |
                     (exx_lq_abort_q[8]      & ex1_gpr_s2_lq_sel_q[8][0]) |
                     (exx_lq_abort_q[9]      & ex1_abt_s2_lq_sel_q[9]));


   assign ex1_rs3_abort = exx_xu0_act[1] & ex1_s3_v_q &
                    ((exx_xu0_abort_q[3]     & ex1_spr_s3_xu0_sel_q[3][0])  |
                     (exx_xu0_abort_q[4]     & ex1_spr_s3_xu0_sel_q[4][0])  |
                     (exx_xu0_abort_q[5]     & ex1_spr_s3_xu0_sel_q[5][0])  |
                     (ex6_xu0_abort          & ex1_spr_s3_xu0_sel_q[6][0])  |
                     (exx_xu0_abort_q[7]     & ex1_spr_s3_xu0_sel_q[7][0])  |
                     (exx_xu0_abort_q[8]     & ex1_spr_s3_xu0_sel_q[8][0])  |
                     (exx_xu0_abort_q[9]     & ex1_abt_s3_xu0_sel_q[9]   ) |
                     (exx_xu0_abort_q[10]    & ex1_abt_s3_xu0_sel_q[10]  ) |
                     (exx_xu0_abort_q[11]    & ex1_abt_s3_xu0_sel_q[11]  ) |
                     (exx_xu0_abort_q[12]    & ex1_abt_s3_xu0_sel_q[12]  ) |
                     (exx_xu1_abort_q[3]     & ex1_spr_s3_xu1_sel_q[3][0])  |
                     (exx_xu1_abort_q[4]     & ex1_spr_s3_xu1_sel_q[4][0])  |
                     (exx_xu1_abort_q[5]     & ex1_spr_s3_xu1_sel_q[5][0])  |
                     (exx_xu1_abort_q[6]     & ex1_abt_s3_xu1_sel_q[6])  |
                     (exx_xu1_abort_q[7]     & ex1_abt_s3_xu1_sel_q[7])  |
                     (lq_xu_ex5_abort        & ex1_spr_s3_lq_sel_q[5][0])   |
                     (exx_lq_abort_q[6]      & ex1_spr_s3_lq_sel_q[6][0]) |
                     (exx_lq_abort_q[7]      & ex1_abt_s3_lq_sel_q[7]) |
                     (exx_lq_abort_q[8]      & ex1_abt_s3_lq_sel_q[8]) |
                     (exx_lq_abort_q[9]      & ex1_abt_s3_lq_sel_q[9]));

   //------------------------------------------------------------------------------------------
   // CR  Bypass
   //------------------------------------------------------------------------------------------
   assign ex1_cr1 =
                     (ex3_xu0_cr                & {4{ex1_spr_s1_xu0_sel_q[3][0]}}) |
                     (ex4_xu0_cr_q              & {4{ex1_spr_s1_xu0_sel_q[4][0]}}) |
                     (ex5_xu0_cr_q              & {4{ex1_spr_s1_xu0_sel_q[5][0]}}) |
                     (ex6_xu0_cr                & {4{ex1_spr_s1_xu0_sel_q[6][0]}}) |
                     (xu1_xu0_ex3_cr            & {4{ex1_spr_s1_xu1_sel_q[3][0]}}) |
                     (lq_xu_ex5_cr              & {4{ex1_spr_s1_lq_sel_q[5][0]}}) |
                     (ex6_lq_cr_q               & {4{ex1_spr_s1_lq_sel_q[6][0]}}) |
                     (cr_xu0_ex1_r1d            & {4{ex1_spr_s1_reg_sel_q[0]}});

   assign ex1_cr2 =
                     (ex3_xu0_cr                & {4{ex1_spr_s2_xu0_sel_q[3][0]}}) |
                     (ex4_xu0_cr_q              & {4{ex1_spr_s2_xu0_sel_q[4][0]}}) |
                     (ex5_xu0_cr_q              & {4{ex1_spr_s2_xu0_sel_q[5][0]}}) |
                     (ex6_xu0_cr                & {4{ex1_spr_s2_xu0_sel_q[6][0]}}) |
                     (xu1_xu0_ex3_cr            & {4{ex1_spr_s2_xu1_sel_q[3][0]}}) |
                     (lq_xu_ex5_cr              & {4{ex1_spr_s2_lq_sel_q[5][0]}}) |
                     (ex6_lq_cr_q               & {4{ex1_spr_s2_lq_sel_q[6][0]}}) |
                     (cr_xu0_ex1_r2d            & {4{ex1_spr_s2_reg_sel_q[0]}});

   assign ex1_cr3 =
                     (ex3_xu0_cr                & {4{ex1_spr_s3_xu0_sel_q[3][0]}}) |
                     (ex4_xu0_cr_q              & {4{ex1_spr_s3_xu0_sel_q[4][0]}}) |
                     (ex5_xu0_cr_q              & {4{ex1_spr_s3_xu0_sel_q[5][0]}}) |
                     (ex6_xu0_cr                & {4{ex1_spr_s3_xu0_sel_q[6][0]}}) |
                     (xu1_xu0_ex3_cr            & {4{ex1_spr_s3_xu1_sel_q[3][0]}}) |
                     (lq_xu_ex5_cr              & {4{ex1_spr_s3_lq_sel_q[5][0]}}) |
                     (ex6_lq_cr_q               & {4{ex1_spr_s3_lq_sel_q[6][0]}}) |
                     (cr_xu0_ex1_r3d            & {4{ex1_spr_s3_reg_sel_q[0]}});

   assign ex1_cr_bit = (dec_byp_ex1_instr[24:25] == 2'b11) ? ex1_cr3[3] :
                       (dec_byp_ex1_instr[24:25] == 2'b10) ? ex1_cr3[2] :
                       (dec_byp_ex1_instr[24:25] == 2'b01) ? ex1_cr3[1] :
                       ex1_cr3[0];

   assign ex2_cr =
                     (ex2_cr2_q                 & {4{ex2_cr_sel_q[2]}}) |
                     (ex2_cr3_q                 & {4{ex2_cr_sel_q[3]}});

   //------------------------------------------------------------------------------------------
   // XER  Bypass
   //------------------------------------------------------------------------------------------
   assign ex1_xer2 =
                     (ex3_xu0_xer2              & {10{ex1_spr_s2_xu0_sel_q[3][1]}}) |
                     (ex4_xu0_xer_q             & {10{ex1_spr_s2_xu0_sel_q[4][1]}}) |
                     (ex5_xu0_xer_q             & {10{ex1_spr_s2_xu0_sel_q[5][1]}}) |
                     (ex6_xu0_xer               & {10{ex1_spr_s2_xu0_sel_q[6][1]}}) |
                     (xu1_xu0_ex3_xer           & {10{ex1_spr_s2_xu1_sel_q[3][1]}}) |
                     (xer_xu0_ex1_r2d           & {10{ex1_spr_s2_reg_sel_q[1]}});

   assign ex1_xer3 =
                     (ex3_xu0_xer2              & {10{ex1_spr_s3_xu0_sel_q[3][1]}}) |
                     (ex4_xu0_xer_q             & {10{ex1_spr_s3_xu0_sel_q[4][1]}}) |
                     (ex5_xu0_xer_q             & {10{ex1_spr_s3_xu0_sel_q[5][1]}}) |
                     (ex6_xu0_xer               & {10{ex1_spr_s3_xu0_sel_q[6][1]}}) |
                     (xu1_xu0_ex3_xer           & {10{ex1_spr_s3_xu1_sel_q[3][1]}}) |
                     (xer_xu0_ex1_r3d           & {10{ex1_spr_s3_reg_sel_q[1]}});

   assign ex2_xer =
                     (ex2_xer2_q                & {10{ex2_xer_sel_q[2]}}) |
                     (ex2_xer3_q                & {10{ex2_xer_sel_q[3]}});

   //------------------------------------------------------------------------------------------
   // LR  Bypass
   //------------------------------------------------------------------------------------------
   assign ex1_lr1 =
                     (ex3_xu0_lr                & fanout2(ex1_spr_s1_xu0_sel_q[3][1:2], `GPR_WIDTH)) |
                     (ex4_xu0_lr_q              & fanout2(ex1_spr_s1_xu0_sel_q[4][1:2], `GPR_WIDTH)) |
                     (lr_xu0_ex1_r1d            & fanout2(ex1_spr_s1_xu0_sel_q[5][1:2], `GPR_WIDTH)) |
                     (lr_xu0_ex1_r1d            & fanout2(ex1_spr_s1_xu0_sel_q[6][1:2], `GPR_WIDTH)) |
                     (lr_xu0_ex1_r1d            & fanout2(ex1_spr_s1_reg_sel_q[1:2], `GPR_WIDTH));

   assign ex1_lr2 =
                     (ex3_xu0_lr                & fanout2(ex1_spr_s2_xu0_sel_q[3][2:3], `GPR_WIDTH)) |
                     (ex4_xu0_lr_q              & fanout2(ex1_spr_s2_xu0_sel_q[4][2:3], `GPR_WIDTH)) |
                     (lr_xu0_ex1_r2d            & fanout2(ex1_spr_s2_xu0_sel_q[5][2:3], `GPR_WIDTH)) |
                     (lr_xu0_ex1_r2d            & fanout2(ex1_spr_s2_xu0_sel_q[6][2:3], `GPR_WIDTH)) |
                     (lr_xu0_ex1_r2d            & fanout2(ex1_spr_s2_reg_sel_q[2:3], `GPR_WIDTH));

   //------------------------------------------------------------------------------------------
   // CTR Bypass
   //------------------------------------------------------------------------------------------
   assign ex1_ctr2 =
                     (ex3_xu0_ctr               & fanout2(ex1_spr_s2_xu0_sel_q[3][4:5], `GPR_WIDTH)) |
                     (ex4_xu0_ctr_q             & fanout2(ex1_spr_s2_xu0_sel_q[4][4:5], `GPR_WIDTH)) |
                     (ctr_xu0_ex1_r2d           & fanout2(ex1_spr_s2_xu0_sel_q[5][4:5], `GPR_WIDTH)) |
                     (ctr_xu0_ex1_r2d           & fanout2(ex1_spr_s2_xu0_sel_q[6][4:5], `GPR_WIDTH)) |
                     (ctr_xu0_ex1_r2d           & fanout2(ex1_spr_s2_reg_sel_q[4:5], `GPR_WIDTH));

   //------------------------------------------------------------------------------------------
   // Ordered Data
   //------------------------------------------------------------------------------------------
   assign ord_sel_slowspr = xu_slowspr_val_in & xu_slowspr_rw_in &  xu_slowspr_done_in;
   assign ord_sel_ones    = xu_slowspr_val_in & xu_slowspr_rw_in & ~xu_slowspr_done_in;

   assign iu_ord_cr = {2'b0, iu_xu_ex5_data[51], 1'b0};
   assign lq_ord_cr = {2'b0, lq_xu_ex5_data[51], 1'b0};
   assign mm_ord_cr = {2'b0, mm_xu_cr0_eq,       1'b0};

   assign ord_data_act =   ord_sel_ones |
                           ord_sel_slowspr |
                           spr_xu_ord_write_done |
                           iu_xu_ord_write_done |
                           lq_xu_ord_write_done |
                           div_byp_ex4_done |
                           ex6_mul_ord_done_q[0] |
                           dec_byp_ex3_mtiar |
                           mm_xu_cr0_eq_valid;

   assign ord_rt_data_d =                         {`GPR_WIDTH{ord_sel_ones}} |
                     (xu_slowspr_data_in        & {`GPR_WIDTH{ord_sel_slowspr}}) |
                     (spr_xu_ex4_rd_data        & {`GPR_WIDTH{spr_xu_ord_write_done}}) |
                     (iu_xu_ex5_data            & {`GPR_WIDTH{iu_xu_ord_write_done}}) |
                     (lq_xu_ex5_data            & {`GPR_WIDTH{lq_xu_ord_write_done}}) |
                     (div_byp_ex4_rt            & {`GPR_WIDTH{div_byp_ex4_done}}) |
                     (mul_byp_ex6_rt            & {`GPR_WIDTH{ex6_mul_ord_done_q[0]}}) |
                     (alu_byp_ex3_rt            & {`GPR_WIDTH{dec_byp_ex3_mtiar}});

   assign ord_cr_data_d =
                     (div_byp_ex4_cr            & {4{div_byp_ex4_done}}) |
                     (mul_byp_ex6_cr            & {4{ex6_mul_ord_done_q[0]}}) |
                     (iu_ord_cr                 & {4{iu_xu_ord_write_done}}) |
                     (lq_ord_cr                 & {4{lq_xu_ord_write_done}}) |
                     (mm_ord_cr                 & {4{mm_xu_cr0_eq_valid}});

   assign ord_xer_data_d =
                     (div_byp_ex4_xer           & {10{div_byp_ex4_done}}) |
                     (mul_byp_ex6_xer           & {10{ex6_mul_ord_done_q[0]}});

   //------------------------------------------------------------------------------------------
   // EX2 Pipeline Muxing
   //------------------------------------------------------------------------------------------
   generate
      if (`GPR_WIDTH > 32)
      begin : pad64
         assign ex2_mfcr_rt[64-`GPR_WIDTH:31]  = {32{1'b0}};
         assign ex2_mfxer_rt[64-`GPR_WIDTH:31] = {32{1'b0}};
      end
   endgenerate

   assign ex2_mfcr_rt[32:63] = { (ex2_cr        & {4{ex2_is_mfcr_q[0]}}),
                                 (ex2_cr        & {4{ex2_is_mfcr_q[1]}}),
                                 (ex2_cr        & {4{ex2_is_mfcr_q[2]}}),
                                 (ex2_cr        & {4{ex2_is_mfcr_q[3]}}),
                                 (ex2_cr        & {4{ex2_is_mfcr_q[4]}}),
                                 (ex2_cr        & {4{ex2_is_mfcr_q[5]}}),
                                 (ex2_cr        & {4{ex2_is_mfcr_q[6]}}),
                                 (ex2_cr        & {4{ex2_is_mfcr_q[7]}})};

   assign ex2_mfxer_rt[32:63] = {ex2_xer[0:2], 20'h00000, 2'b00, ex2_xer[3:9]};

   assign ex2_mfspr_rt =          ex2_mfcr_rt |
                                 (ex2_mfxer_rt  & {`GPR_WIDTH{ex2_is_mfxer_q}}) |
                                 (ex2_lr1_q     & {`GPR_WIDTH{ex2_is_mflr_q}}) |
                                 (ex2_ctr2_q    & {`GPR_WIDTH{ex2_is_mfctr_q}});

   assign ex2_mfspr_sel = ex2_is_mfcr_sel_q | ex2_is_mfxer_q | ex2_is_mflr_q | ex2_is_mfctr_q;
   assign ex2_mfspr_act = exx_xu0_act[2] & ex2_mfspr_sel;

   //------------------------------------------------------------------------------------------
   // EX3 Pipeline Muxing
   //------------------------------------------------------------------------------------------
   assign ex3_cnt_zero  = ~|ex3_cnt_rt_q;

   assign ex3_cnt_cr    = {1'b0, ~ex3_cnt_zero, ex3_cnt_zero, ex3_xer3_q[0]};

   assign ex3_cnt_rt    = {57'b0, ex3_cnt_rt_q};
   assign ex3_prm_rt    = {56'b0, ex3_prm_rt_q};
   assign ex3_dlm_rt    = {60'b0, ex3_dlm_rt_q};

   assign ex2_mtcr_sel  = |ex2_is_mtcr_q;

   assign ex3_mtxer     = {ex3_rs1_q[32:34], ex3_rs1_q[57:63]};

   assign ex2_mtcr      =
                     (ex2_rs1_q[32:35]          & {4{ex2_is_mtcr_q[0]}}) |
                     (ex2_rs1_q[36:39]          & {4{ex2_is_mtcr_q[1]}}) |
                     (ex2_rs1_q[40:43]          & {4{ex2_is_mtcr_q[2]}}) |
                     (ex2_rs1_q[44:47]          & {4{ex2_is_mtcr_q[3]}}) |
                     (ex2_rs1_q[48:51]          & {4{ex2_is_mtcr_q[4]}}) |
                     (ex2_rs1_q[52:55]          & {4{ex2_is_mtcr_q[5]}}) |
                     (ex2_rs1_q[56:59]          & {4{ex2_is_mtcr_q[6]}}) |
                     (ex2_rs1_q[60:63]          & {4{ex2_is_mtcr_q[7]}});

   assign ex3_xu0_rt_nobyp5 =
                     (alu_byp_ex3_rt            & ~{`GPR_WIDTH{ex3_mfspr_sel_q}}) |
                     (ex3_mfspr_rt_q            &  {`GPR_WIDTH{ex3_mfspr_sel_q}});

   assign ex3_xu0_rt_nobyp4 =
                     (ex3_xu0_rt_nobyp5         & ~{`GPR_WIDTH{dec_byp_ex3_dlm_done}}) |
                     (ex3_dlm_rt                &  {`GPR_WIDTH{dec_byp_ex3_dlm_done}});

   assign ex3_xu0_rt_nobyp3 =
                     (ex3_xu0_rt_nobyp4         & ~{`GPR_WIDTH{dec_byp_ex3_cnt_done}}) |
                     (ex3_cnt_rt                &  {`GPR_WIDTH{dec_byp_ex3_cnt_done}});

   assign ex3_xu0_rt_nobyp2 =
                     (ex3_xu0_rt_nobyp3         & ~{`GPR_WIDTH{bcd_byp_ex3_done}}) |
                     (bcd_byp_ex3_rt            &  {`GPR_WIDTH{bcd_byp_ex3_done}});

   assign ex3_xu0_rt_nobyp =
                     (ex3_xu0_rt_nobyp2         & ~{`GPR_WIDTH{dec_byp_ex3_prm_done}}) |
                     (ex3_prm_rt                &  {`GPR_WIDTH{dec_byp_ex3_prm_done}});

   assign ex3_xu0_lr =
                     (br_byp_ex3_lr_wd          &  {`GPR_WIDTH{br_byp_ex3_lr_we}}) |
                     (ex3_rs1_q                 & ~{`GPR_WIDTH{br_byp_ex3_lr_we}});

   assign ex3_xu0_ctr =
                     (br_byp_ex3_ctr_wd         &  {`GPR_WIDTH{br_byp_ex3_ctr_we}}) |
                     (ex3_rs1_q                 & ~{`GPR_WIDTH{br_byp_ex3_ctr_we}});

   assign ex3_xu0_lr_act   = exx_xu0_act[3] & (br_byp_ex3_lr_we  | dec_byp_ex3_is_mtspr);
   assign ex3_xu0_ctr_act  = exx_xu0_act[3] & (br_byp_ex3_ctr_we | dec_byp_ex3_is_mtspr);

   assign ex3_alu2_cr      = ex3_mtcr_sel_q == 1'b1         ? ex3_mtcr_q            : alu_byp_ex3_cr;
   assign ex3_xu0_xer      = ex3_is_mtxer_q == 1'b1         ? ex3_mtxer             : alu_byp_ex3_xer;
   assign ex3_xu0_xer2     = dec_byp_ex3_dlm_done == 1'b1   ? ex3_dlm_xer_q         : ex3_xu0_xer;

   assign ex3_xu0_cr3      = br_byp_ex3_cr_we == 1'b1       ? br_byp_ex3_cr_wd      : ex3_alu2_cr;
   assign ex3_xu0_cr2      = dec_byp_ex3_dlm_done == 1'b1   ? ex3_dlm_cr_q          : ex3_xu0_cr3;
   assign ex3_xu0_cr       = dec_byp_ex3_cnt_done == 1'b1   ? ex3_cnt_cr            : ex3_xu0_cr2;

   //------------------------------------------------------------------------------------------
   // EX4 Pipeline Muxing
   //------------------------------------------------------------------------------------------

   assign ex4_xu0_rt_nobyp =
                     (ex4_xu0_rt_q              & ~{`GPR_WIDTH{dec_byp_ex4_pop_done}}) |
                     (pop_byp_ex4_rt            &  {`GPR_WIDTH{dec_byp_ex4_pop_done}});

   //------------------------------------------------------------------------------------------
   // EX5 Pipeline Muxing
   //------------------------------------------------------------------------------------------
   assign ex5_xu0_rt =
                     (ex5_xu0_rt_q              & ~{`GPR_WIDTH{dec_byp_ex5_ord_sel}}) |
                     (ord_rt_data_q             &  {`GPR_WIDTH{dec_byp_ex5_ord_sel}});

   assign ex5_xu0_cr =
                     (ex5_xu0_cr_q              & ~{4{dec_byp_ex5_ord_sel}}) |
                     (ord_cr_data_q             &  {4{dec_byp_ex5_ord_sel}});

   assign ex5_xu0_xer =
                     (ex5_xu0_xer_q             & ~{10{dec_byp_ex5_ord_sel}}) |
                     (ord_xer_data_q            &  {10{dec_byp_ex5_ord_sel}});

   //------------------------------------------------------------------------------------------
   // EX6 Pipeline Muxing
   //------------------------------------------------------------------------------------------
   assign ex6_xu0_rt =
                     (ex6_xu0_rt_q              & ~fanout(ex6_mul_done_q[0:7],`GPR_WIDTH)) |
                     (mul_byp_ex6_rt            &  fanout(ex6_mul_done_q[0:7],`GPR_WIDTH));

   assign ex6_xu0_cr =
                     (ex6_xu0_cr_q              & ~{4{ex6_mul_done_q[8]}}) |
                     (mul_byp_ex6_cr            &  {4{ex6_mul_done_q[8]}});

   assign ex6_xu0_xer =
                     (ex6_xu0_xer_q             & ~{10{ex6_mul_done_q[8]}}) |
                     (mul_byp_ex6_xer           &  {10{ex6_mul_done_q[8]}});

   //------------------------------------------------------------------------------------------
   // MMU/Erat Interface Data Capture
   //------------------------------------------------------------------------------------------
   // Special clock gates for erativax
   assign ex0_xu0_ivax_act = exx_xu0_act[0] | dec_byp_ex1_rs_capt;
   assign ex1_xu0_ivax_act = exx_xu0_act[1] | dec_byp_ex1_rs_capt;

   assign mm_rs_is_d       = ex2_rs1_q[55:63];

   assign mm_ra_entry_d    = ex2_rs2_noimm_q[52:63];

   generate
      if (`GPR_WIDTH > 32)
      begin : mm_cm_mask
         assign mm_data_d[64 - `GPR_WIDTH:31] = ex4_xu0_rt_q[64-`GPR_WIDTH:31] & {32{ ex4_spr_msr_cm}};
      end
   endgenerate
   assign mm_data_d[32:63]    = ex4_xu0_rt_q[32:63];

   assign xu_iu_rs_is         = mm_rs_is_q;
   assign xu_iu_ra_entry      = mm_ra_entry_q[8:11];
   assign xu_iu_rb            = mm_data_q[64-`GPR_WIDTH:51];
   assign xu_iu_rs_data       = mm_data_q;

   assign xu_lq_rs_is         = mm_rs_is_q;
   assign xu_lq_ra_entry      = mm_ra_entry_q[7:11];
   assign xu_lq_rb            = mm_data_q[64-`GPR_WIDTH:51];
   assign xu_lq_rs_data       = mm_data_q;

   assign xu_mm_ra_entry      = mm_ra_entry_q;
   assign xu_mm_rb            = mm_data_q;

   //------------------------------------------------------------------------------------------
   // Parity Gen
   //------------------------------------------------------------------------------------------
   generate begin : parity_gen
      genvar i;
      for (i = 8-`GPR_WIDTH/8; i <= 7; i = i + 1)
      begin : parity_loop
         assign ex6_parity[i] = ^(ex6_xu0_rt[8 * i:8 * i + 7]);
      end
   end
   endgenerate

   //------------------------------------------------------------------------------------------
   // IO / Buffering
   //------------------------------------------------------------------------------------------
   // GPR
   assign byp_alu_ex2_rs1     = ex2_rs1_q;
   assign byp_alu_ex2_rs2     = ex2_rs2_q;
   assign byp_pop_ex2_rs1     = ex2_rs1_q;
   assign byp_cnt_ex2_rs1     = ex2_rs1_q;
   assign byp_div_ex2_rs1     = ex2_rs1_q;
   assign byp_div_ex2_rs2     = ex2_rs2_q;
   assign byp_mul_ex2_rs1     = ex2_rs1_q;
   assign byp_mul_ex2_rs2     = ex2_rs2_q;
   assign byp_mul_ex2_abort   = exx_xu0_abort_q[2];
   assign byp_dlm_ex2_rs1     = ex2_rs1_q[32:63];
   assign byp_dlm_ex2_rs2     = ex2_rs2_q[32:63];
   assign byp_bcd_ex2_rs1     = ex2_rs1_q;
   assign byp_bcd_ex2_rs2     = ex2_rs2_q;
   assign xu0_gpr_ex6_wd      = {ex6_xu0_rt, ex6_parity, 2'b00};

   assign xu0_xu1_ex2_rt      = alu_byp_ex2_add_rt;
   assign xu0_xu1_ex3_rt      = ex3_xu0_rt_nobyp;
   assign xu0_xu1_ex4_rt      = ex4_xu0_rt_q;
   assign xu0_xu1_ex5_rt      = ex5_xu0_rt_q;
   assign xu0_xu1_ex6_rt      = ex6_xu0_rt;

   assign xu0_xu1_ex7_rt      = ex7_xu0_rt_q;
   assign xu0_xu1_ex8_rt      = ex8_xu0_rt_q;
   assign xu0_xu1_ex6_lq_rt   = ex6_lq_rt_q;
   assign xu0_xu1_ex7_lq_rt   = ex7_lq_rt_q;
   assign xu0_xu1_ex8_lq_rt   = ex8_lq_rt_q;

   assign xu0_lq_ex3_rt       = alu_byp_ex3_rt;
   assign xu0_lq_ex4_rt       = ex4_xu0_rt_q;
   assign xu0_lq_ex6_act      = exx_xu0_act[6];
   assign xu0_lq_ex6_rt       = ex6_xu0_rt;
   assign xu0_pc_ram_data     = ex6_xu0_rt;
   assign xu_spr_ex2_rs1      = ex2_rs1_q;

   assign xu0_xu1_ex2_abort   = exx_xu0_abort_q[2];
   assign xu0_xu1_ex6_abort   = ex6_xu0_abort;
   assign xu0_lq_ex3_abort    = exx_xu0_abort_q[3];

   assign xu0_iu_bta_int      = dec_byp_ex4_hpriv == 1'b1 ? dec_byp_ex4_instr : ord_rt_data_q[30:61];
   assign xu0_iu_bta          = {ord_rt_data_q[62-`EFF_IFAR_ARCH:29], xu0_iu_bta_int};

   // CR
   assign byp_alu_ex2_cr_bit  = ex2_cr_bit_q;
   assign xu0_cr_ex6_w0d      = ex6_xu0_cr;
   assign xu0_xu1_ex3_cr      = ex3_xu0_cr;
   assign xu0_xu1_ex4_cr      = ex4_xu0_cr_q;
   assign xu0_xu1_ex6_cr      = ex6_xu0_cr;
   assign byp_br_ex3_cr       = ex3_alu2_cr;
   assign byp_br_ex2_cr1      = ex2_cr1_q;
   assign byp_br_ex2_cr2      = ex2_cr2_q;
   assign byp_br_ex2_cr3      = ex2_cr3_q;

   // XER
   assign byp_alu_ex2_xer     = ex2_xer3_q;
   assign byp_div_ex2_xer     = ex2_xer3_q;
   assign byp_mul_ex2_xer     = ex2_xer3_q;
   assign byp_dlm_ex2_xer     = ex2_xer3_q[0:2];
   assign xu0_xer_ex6_w0d     = ex6_xu0_xer;
   assign xu0_xu1_ex3_xer     = ex3_xu0_xer2;
   assign xu0_xu1_ex4_xer     = ex4_xu0_xer_q;
   assign xu0_xu1_ex6_xer     = ex6_xu0_xer;

   // LR
   assign byp_br_ex2_lr1      = ex2_lr1_q;
   assign byp_br_ex2_lr2      = ex2_lr2_q;
   assign xu0_lr_ex4_w0d      = ex4_xu0_lr_q;

   // CTR
   assign byp_br_ex2_ctr      = ex2_ctr2_q;
   assign xu0_ctr_ex4_w0d     = ex4_xu0_ctr_q;

   // Abort
   assign xu0_rv_ex2_s1_abort = ex2_rs1_abort_q;
   assign xu0_rv_ex2_s2_abort = ex2_rs2_abort_q;
   assign xu0_rv_ex2_s3_abort = ex2_rs3_abort_q;
   assign byp_dec_ex2_abort   = ex2_rs1_abort_q | ex2_rs2_abort_q | ex2_rs3_abort_q;

   //------------------------------------------------------------------------------------------
   // Clock Gating
   //------------------------------------------------------------------------------------------
   assign exx_xu0_act         = {dec_byp_ex0_act, exx_xu0_act_q[1:4], (exx_xu0_act_q[5] | dec_byp_ex5_ord_sel), (exx_xu0_act_q[6] | ex6_mul_done_q[8]), exx_xu0_act_q[7]};
   assign exx_lq_act          = {lq_xu_ex5_act, exx_lq_act_q[6:8]};

   assign exx_xu0_act_d[1:7]  = exx_xu0_act[0:6];
   assign exx_lq_act_d[6:8]   = exx_lq_act[5:7];


   //------------------------------------------------------------------------------------------
   // Latches
   //------------------------------------------------------------------------------------------
   tri_rlmreg_p #(.WIDTH(7), .OFFSET(1),.INIT(0), .NEEDS_SRESET(1)) exx_xu0_act_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_xu0_act_offset : exx_xu0_act_offset + 7-1]),
      .scout(sov[exx_xu0_act_offset : exx_xu0_act_offset + 7-1]),
      .din(exx_xu0_act_d),
      .dout(exx_xu0_act_q)
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
      .din(rv_xu0_ex0_s1_v),
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
      .din(rv_xu0_ex0_s2_v),
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
      .din(rv_xu0_ex0_s3_v),
      .dout(ex1_s3_v_q)
   );
generate begin : ex1_gpr_s1_xu0_sel_gen
   genvar i;
   for (i=2;i<=8;i=i+1) begin : ex1_gpr_s1_xu0_sel_entry
	   tri_rlmreg_p #(.WIDTH(8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_gpr_s1_xu0_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu0_act[0]),
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
	      .act(exx_xu0_act[0]),
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
	      .act(exx_xu0_act[0]),
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
	      .act(exx_xu0_act[0]),
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
	      .act(exx_xu0_act[0]),
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
	      .act(exx_xu0_act[0]),
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
      .act(exx_xu0_act[0]),
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
generate begin : ex1_spr_s1_xu0_sel_gen
   genvar i;
   for (i=3;i<=6;i=i+1) begin : ex1_spr_s1_xu0_sel_entry
	   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s1_xu0_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu0_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_spr_s1_xu0_sel_offset + (i-3)*3 : ex1_spr_s1_xu0_sel_offset + (i-3+1)*3-1]),
	      .scout(sov[ex1_spr_s1_xu0_sel_offset + (i-3)*3 : ex1_spr_s1_xu0_sel_offset + (i-3+1)*3-1]),
	      .din({3{rv_xu0_s1_fxu0_sel[i-1]}}),
	      .dout(ex1_spr_s1_xu0_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_spr_s1_xu1_sel_gen
   genvar i;
   for (i=3;i<=3;i=i+1) begin : ex1_spr_s1_xu1_sel_entry
	   tri_rlmreg_p #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s1_xu1_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu0_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_spr_s1_xu1_sel_offset + (i-3)*1 : ex1_spr_s1_xu1_sel_offset + (i-3+1)*1-1]),
	      .scout(sov[ex1_spr_s1_xu1_sel_offset + (i-3)*1 : ex1_spr_s1_xu1_sel_offset + (i-3+1)*1-1]),
	      .din({1{rv_xu0_s1_fxu1_sel[i-1]}}),
	      .dout(ex1_spr_s1_xu1_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_spr_s1_lq_sel_gen
   genvar i;
   for (i=5;i<=6;i=i+1) begin : ex1_spr_s1_lq_sel_entry
	   tri_rlmreg_p #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s1_lq_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu0_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_spr_s1_lq_sel_offset + (i-5)*1 : ex1_spr_s1_lq_sel_offset + (i-5+1)*1-1]),
	      .scout(sov[ex1_spr_s1_lq_sel_offset + (i-5)*1 : ex1_spr_s1_lq_sel_offset + (i-5+1)*1-1]),
	      .din({1{rv_xu0_s1_lq_sel[i-1]}}),
	      .dout(ex1_spr_s1_lq_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_spr_s2_xu0_sel_gen
   genvar i;
   for (i=3;i<=6;i=i+1) begin : ex1_spr_s2_xu0_sel_entry
	   tri_rlmreg_p #(.WIDTH(6), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s2_xu0_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu0_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_spr_s2_xu0_sel_offset + (i-3)*6 : ex1_spr_s2_xu0_sel_offset + (i-3+1)*6-1]),
	      .scout(sov[ex1_spr_s2_xu0_sel_offset + (i-3)*6 : ex1_spr_s2_xu0_sel_offset + (i-3+1)*6-1]),
	      .din({6{rv_xu0_s2_fxu0_sel[i-1]}}),
	      .dout(ex1_spr_s2_xu0_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_spr_s2_xu1_sel_gen
   genvar i;
   for (i=3;i<=3;i=i+1) begin : ex1_spr_s2_xu1_sel_entry
	   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s2_xu1_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu0_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_spr_s2_xu1_sel_offset + (i-3)*2 : ex1_spr_s2_xu1_sel_offset + (i-3+1)*2-1]),
	      .scout(sov[ex1_spr_s2_xu1_sel_offset + (i-3)*2 : ex1_spr_s2_xu1_sel_offset + (i-3+1)*2-1]),
	      .din({2{rv_xu0_s2_fxu1_sel[i-1]}}),
	      .dout(ex1_spr_s2_xu1_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_spr_s2_lq_sel_gen
   genvar i;
   for (i=5;i<=6;i=i+1) begin : ex1_spr_s2_lq_sel_entry
	   tri_rlmreg_p #(.WIDTH(1), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s2_lq_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu0_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_spr_s2_lq_sel_offset + (i-5)*1 : ex1_spr_s2_lq_sel_offset + (i-5+1)*1-1]),
	      .scout(sov[ex1_spr_s2_lq_sel_offset + (i-5)*1 : ex1_spr_s2_lq_sel_offset + (i-5+1)*1-1]),
	      .din({1{rv_xu0_s2_lq_sel[i-1]}}),
	      .dout(ex1_spr_s2_lq_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_spr_s3_xu0_sel_gen
   genvar i;
   for (i=3;i<=8;i=i+1) begin : ex1_spr_s3_xu0_sel_entry
	   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s3_xu0_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu0_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_spr_s3_xu0_sel_offset + (i-3)*2 : ex1_spr_s3_xu0_sel_offset + (i-3+1)*2-1]),
	      .scout(sov[ex1_spr_s3_xu0_sel_offset + (i-3)*2 : ex1_spr_s3_xu0_sel_offset + (i-3+1)*2-1]),
	      .din({2{rv_xu0_s3_fxu0_sel[i-1]}}),
	      .dout(ex1_spr_s3_xu0_sel_q[i])
	   );
   end
end
endgenerate
generate begin : ex1_spr_s3_xu1_sel_gen
   genvar i;
   for (i=3;i<=5;i=i+1) begin : ex1_spr_s3_xu1_sel_entry
	   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s3_xu1_sel_latch(
	      .nclk(nclk), .vd(vdd), .gd(gnd),
	      .act(exx_xu0_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_spr_s3_xu1_sel_offset + (i-3)*2 : ex1_spr_s3_xu1_sel_offset + (i-3+1)*2-1]),
	      .scout(sov[ex1_spr_s3_xu1_sel_offset + (i-3)*2 : ex1_spr_s3_xu1_sel_offset + (i-3+1)*2-1]),
	      .din({2{rv_xu0_s3_fxu1_sel[i-1]}}),
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
	      .act(exx_xu0_act[0]),
	      .force_t(func_sl_force),
	      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
	      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
	      .thold_b(func_sl_thold_0_b),
	      .sg(sg_0),
	      .scin (siv[ex1_spr_s3_lq_sel_offset + (i-5)*1 : ex1_spr_s3_lq_sel_offset + (i-5+1)*1-1]),
	      .scout(sov[ex1_spr_s3_lq_sel_offset + (i-5)*1 : ex1_spr_s3_lq_sel_offset + (i-5+1)*1-1]),
	      .din({1{rv_xu0_s3_lq_sel[i-1]}}),
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
	      .act(exx_xu0_act[0]),
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
	      .act(exx_xu0_act[0]),
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
      .act(ex0_xu0_ivax_act),
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
      .act(exx_xu0_act[0]),
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
   tri_rlmreg_p #(.WIDTH(3), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s1_reg_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_spr_s1_reg_sel_offset : ex1_spr_s1_reg_sel_offset + 3-1]),
      .scout(sov[ex1_spr_s1_reg_sel_offset : ex1_spr_s1_reg_sel_offset + 3-1]),
      .din({3{ex0_spr_s1_reg_sel}}),
      .dout(ex1_spr_s1_reg_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(6), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s2_reg_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_spr_s2_reg_sel_offset : ex1_spr_s2_reg_sel_offset + 6-1]),
      .scout(sov[ex1_spr_s2_reg_sel_offset : ex1_spr_s2_reg_sel_offset + 6-1]),
      .din({6{ex0_spr_s2_reg_sel}}),
      .dout(ex1_spr_s2_reg_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex1_spr_s3_reg_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[0]),
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
      .act(exx_xu0_act[0]),
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
      .act(exx_xu0_act[0]),
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
      .act(exx_xu0_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_abt_s3_lq_sel_offset : ex1_abt_s3_lq_sel_offset + 3-1]),
      .scout(sov[ex1_abt_s3_lq_sel_offset : ex1_abt_s3_lq_sel_offset + 3-1]),
      .din(rv_xu0_s3_lq_sel[6:8]),
      .dout(ex1_abt_s3_lq_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(6),.INIT(0), .NEEDS_SRESET(1)) ex1_abt_s1_xu1_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[0]),
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
      .act(exx_xu0_act[0]),
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
      .act(exx_xu0_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_abt_s3_xu1_sel_offset : ex1_abt_s3_xu1_sel_offset + 2-1]),
      .scout(sov[ex1_abt_s3_xu1_sel_offset : ex1_abt_s3_xu1_sel_offset + 2-1]),
      .din(rv_xu0_s3_fxu1_sel[5:6]),
      .dout(ex1_abt_s3_xu1_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(9),.INIT(0), .NEEDS_SRESET(1)) ex1_abt_s1_xu0_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[0]),
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
      .act(exx_xu0_act[0]),
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
      .act(exx_xu0_act[0]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX1]),
      .mpw1_b(mpw1_dc_b[DEX1]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex1_abt_s3_xu0_sel_offset : ex1_abt_s3_xu0_sel_offset + 4-1]),
      .scout(sov[ex1_abt_s3_xu0_sel_offset : ex1_abt_s3_xu0_sel_offset + 4-1]),
      .din(rv_xu0_s3_fxu0_sel[8:11]),
      .dout(ex1_abt_s3_xu0_sel_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_mflr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_mflr_offset]),
      .scout(sov[ex2_is_mflr_offset]),
      .din(dec_byp_ex1_is_mflr),
      .dout(ex2_is_mflr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_mfxer_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_mfxer_offset]),
      .scout(sov[ex2_is_mfxer_offset]),
      .din(dec_byp_ex1_is_mfxer),
      .dout(ex2_is_mfxer_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_mtxer_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_mtxer_offset]),
      .scout(sov[ex2_is_mtxer_offset]),
      .din(dec_byp_ex1_is_mtxer),
      .dout(ex2_is_mtxer_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_mfcr_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_mfcr_sel_offset]),
      .scout(sov[ex2_is_mfcr_sel_offset]),
      .din(dec_byp_ex1_is_mfcr_sel),
      .dout(ex2_is_mfcr_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_is_mfcr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_is_mfcr_offset : ex2_is_mfcr_offset + 8-1]),
      .scout(sov[ex2_is_mfcr_offset : ex2_is_mfcr_offset + 8-1]),
      .din(dec_byp_ex1_is_mfcr),
      .dout(ex2_is_mfcr_q)
   );
   tri_rlmreg_p #(.WIDTH(8), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_is_mtcr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_is_mtcr_offset : ex2_is_mtcr_offset + 8-1]),
      .scout(sov[ex2_is_mtcr_offset : ex2_is_mtcr_offset + 8-1]),
      .din(dec_byp_ex1_is_mtcr),
      .dout(ex2_is_mtcr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_mfctr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_mfctr_offset]),
      .scout(sov[ex2_is_mfctr_offset]),
      .din(dec_byp_ex1_is_mfctr),
      .dout(ex2_is_mfctr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_is_mtxer_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_is_mtxer_offset]),
      .scout(sov[ex3_is_mtxer_offset]),
      .din(ex2_is_mtxer_q),
      .dout(ex3_is_mtxer_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex4_xu0_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_xu0_rt_offset : ex4_xu0_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[ex4_xu0_rt_offset : ex4_xu0_rt_offset + `GPR_WIDTH-1]),
      .din(ex3_xu0_rt_nobyp),
      .dout(ex4_xu0_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex5_xu0_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[4]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX5]),
      .mpw1_b(mpw1_dc_b[DEX5]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex5_xu0_rt_offset : ex5_xu0_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[ex5_xu0_rt_offset : ex5_xu0_rt_offset + `GPR_WIDTH-1]),
      .din(ex4_xu0_rt_nobyp),
      .dout(ex5_xu0_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex6_xu0_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[5]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex6_xu0_rt_offset : ex6_xu0_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[ex6_xu0_rt_offset : ex6_xu0_rt_offset + `GPR_WIDTH-1]),
      .din(ex5_xu0_rt),
      .dout(ex6_xu0_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex7_xu0_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[6]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX7]),
      .mpw1_b(mpw1_dc_b[DEX7]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex7_xu0_rt_offset : ex7_xu0_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[ex7_xu0_rt_offset : ex7_xu0_rt_offset + `GPR_WIDTH-1]),
      .din(ex6_xu0_rt),
      .dout(ex7_xu0_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex8_xu0_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[7]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX8]),
      .mpw1_b(mpw1_dc_b[DEX8]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex8_xu0_rt_offset : ex8_xu0_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[ex8_xu0_rt_offset : ex8_xu0_rt_offset + `GPR_WIDTH-1]),
      .din(ex7_xu0_rt_q),
      .dout(ex8_xu0_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex6_lq_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_lq_act[5]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex6_lq_rt_offset : ex6_lq_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[ex6_lq_rt_offset : ex6_lq_rt_offset + `GPR_WIDTH-1]),
      .din(lq_xu_ex5_rt),
      .dout(ex6_lq_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex7_lq_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_lq_act[6]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX7]),
      .mpw1_b(mpw1_dc_b[DEX7]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex7_lq_rt_offset : ex7_lq_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[ex7_lq_rt_offset : ex7_lq_rt_offset + `GPR_WIDTH-1]),
      .din(ex6_lq_rt_q),
      .dout(ex7_lq_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex8_lq_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_lq_act[7]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX8]),
      .mpw1_b(mpw1_dc_b[DEX8]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex8_lq_rt_offset : ex8_lq_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[ex8_lq_rt_offset : ex8_lq_rt_offset + `GPR_WIDTH-1]),
      .din(ex7_lq_rt_q),
      .dout(ex8_lq_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_xu0_cr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_xu0_cr_offset : ex4_xu0_cr_offset + 4-1]),
      .scout(sov[ex4_xu0_cr_offset : ex4_xu0_cr_offset + 4-1]),
      .din(ex3_xu0_cr),
      .dout(ex4_xu0_cr_q)
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
      .din(ex4_xu0_cr_q),
      .dout(ex5_xu0_cr_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex6_xu0_cr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[5]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex6_xu0_cr_offset : ex6_xu0_cr_offset + 4-1]),
      .scout(sov[ex6_xu0_cr_offset : ex6_xu0_cr_offset + 4-1]),
      .din(ex5_xu0_cr),
      .dout(ex6_xu0_cr_q)
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
   tri_rlmreg_p #(.WIDTH(10), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex4_xu0_xer_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_xu0_xer_offset : ex4_xu0_xer_offset + 10-1]),
      .scout(sov[ex4_xu0_xer_offset : ex4_xu0_xer_offset + 10-1]),
      .din(ex3_xu0_xer2),
      .dout(ex4_xu0_xer_q)
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
      .din(ex4_xu0_xer_q),
      .dout(ex5_xu0_xer_q)
   );
   tri_rlmreg_p #(.WIDTH(10), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex6_xu0_xer_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[5]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex6_xu0_xer_offset : ex6_xu0_xer_offset + 10-1]),
      .scout(sov[ex6_xu0_xer_offset : ex6_xu0_xer_offset + 10-1]),
      .din(ex5_xu0_xer),
      .dout(ex6_xu0_xer_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex4_xu0_ctr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex3_xu0_ctr_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_xu0_ctr_offset : ex4_xu0_ctr_offset + `GPR_WIDTH-1]),
      .scout(sov[ex4_xu0_ctr_offset : ex4_xu0_ctr_offset + `GPR_WIDTH-1]),
      .din(ex3_xu0_ctr),
      .dout(ex4_xu0_ctr_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex4_xu0_lr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex3_xu0_lr_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex4_xu0_lr_offset : ex4_xu0_lr_offset + `GPR_WIDTH-1]),
      .scout(sov[ex4_xu0_lr_offset : ex4_xu0_lr_offset + `GPR_WIDTH-1]),
      .din(ex3_xu0_lr),
      .dout(ex4_xu0_lr_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex2_rs1_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex1_xu0_ivax_act),
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
      .act(exx_xu0_act[1]),
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
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_cr1_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_cr1_offset : ex2_cr1_offset + 4-1]),
      .scout(sov[ex2_cr1_offset : ex2_cr1_offset + 4-1]),
      .din(ex1_cr1),
      .dout(ex2_cr1_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_cr2_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_cr2_offset : ex2_cr2_offset + 4-1]),
      .scout(sov[ex2_cr2_offset : ex2_cr2_offset + 4-1]),
      .din(ex1_cr2),
      .dout(ex2_cr2_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_cr3_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_cr3_offset : ex2_cr3_offset + 4-1]),
      .scout(sov[ex2_cr3_offset : ex2_cr3_offset + 4-1]),
      .din(ex1_cr3),
      .dout(ex2_cr3_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_cr_bit_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
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
   tri_rlmreg_p #(.WIDTH(10), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_xer2_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_xer2_offset : ex2_xer2_offset + 10-1]),
      .scout(sov[ex2_xer2_offset : ex2_xer2_offset + 10-1]),
      .din(ex1_xer2),
      .dout(ex2_xer2_q)
   );
   tri_rlmreg_p #(.WIDTH(10), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex2_xer3_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
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
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_xer3_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_xer3_offset]),
      .scout(sov[ex3_xer3_offset]),
      .din(ex2_xer3_q[0:0]),
      .dout(ex3_xer3_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex2_lr1_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_lr1_offset : ex2_lr1_offset + `GPR_WIDTH-1]),
      .scout(sov[ex2_lr1_offset : ex2_lr1_offset + `GPR_WIDTH-1]),
      .din(ex1_lr1),
      .dout(ex2_lr1_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex2_lr2_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_lr2_offset : ex2_lr2_offset + `GPR_WIDTH-1]),
      .scout(sov[ex2_lr2_offset : ex2_lr2_offset + `GPR_WIDTH-1]),
      .din(ex1_lr2),
      .dout(ex2_lr2_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex2_ctr2_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_ctr2_offset : ex2_ctr2_offset + `GPR_WIDTH-1]),
      .scout(sov[ex2_ctr2_offset : ex2_ctr2_offset + `GPR_WIDTH-1]),
      .din(ex1_ctr2),
      .dout(ex2_ctr2_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(2),.INIT(0), .NEEDS_SRESET(1)) ex2_cr_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_cr_sel_offset : ex2_cr_sel_offset + 2-1]),
      .scout(sov[ex2_cr_sel_offset : ex2_cr_sel_offset + 2-1]),
      .din(dec_byp_ex1_cr_sel),
      .dout(ex2_cr_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(2), .OFFSET(2),.INIT(0), .NEEDS_SRESET(1)) ex2_xer_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_xer_sel_offset : ex2_xer_sel_offset + 2-1]),
      .scout(sov[ex2_xer_sel_offset : ex2_xer_sel_offset + 2-1]),
      .din(dec_byp_ex1_xer_sel),
      .dout(ex2_xer_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex3_rs1_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_rs1_offset : ex3_rs1_offset + `GPR_WIDTH-1]),
      .scout(sov[ex3_rs1_offset : ex3_rs1_offset + `GPR_WIDTH-1]),
      .din(ex2_rs1_q),
      .dout(ex3_rs1_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_mfspr_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_mfspr_sel_offset]),
      .scout(sov[ex3_mfspr_sel_offset]),
      .din(ex2_mfspr_sel),
      .dout(ex3_mfspr_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ex3_mfspr_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex2_mfspr_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_mfspr_rt_offset : ex3_mfspr_rt_offset + `GPR_WIDTH-1]),
      .scout(sov[ex3_mfspr_rt_offset : ex3_mfspr_rt_offset + `GPR_WIDTH-1]),
      .din(ex2_mfspr_rt),
      .dout(ex3_mfspr_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) ord_rt_data_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_data_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ord_rt_data_offset : ord_rt_data_offset + `GPR_WIDTH-1]),
      .scout(sov[ord_rt_data_offset : ord_rt_data_offset + `GPR_WIDTH-1]),
      .din(ord_rt_data_d),
      .dout(ord_rt_data_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ord_cr_data_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_data_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ord_cr_data_offset : ord_cr_data_offset + 4-1]),
      .scout(sov[ord_cr_data_offset : ord_cr_data_offset + 4-1]),
      .din(ord_cr_data_d),
      .dout(ord_cr_data_q)
   );
   tri_rlmreg_p #(.WIDTH(10), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ord_xer_data_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ord_data_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ord_xer_data_offset : ord_xer_data_offset + 10-1]),
      .scout(sov[ord_xer_data_offset : ord_xer_data_offset + 10-1]),
      .din(ord_xer_data_d),
      .dout(ord_xer_data_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_rs_capt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_rs_capt_offset]),
      .scout(sov[ex2_rs_capt_offset]),
      .din(dec_byp_ex1_rs_capt),
      .dout(ex2_rs_capt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ra_capt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_ra_capt_offset]),
      .scout(sov[ex2_ra_capt_offset]),
      .din(dec_byp_ex1_ra_capt),
      .dout(ex2_ra_capt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_ra_capt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_ra_capt_offset]),
      .scout(sov[ex3_ra_capt_offset]),
      .din(ex2_ra_capt_q),
      .dout(ex3_ra_capt_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_ra_capt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX4]),
      .mpw1_b(mpw1_dc_b[DEX4]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_ra_capt_offset]),
      .scout(sov[ex4_ra_capt_offset]),
      .din(ex3_ra_capt_q),
      .dout(ex4_ra_capt_q)
   );
   tri_rlmreg_p #(.WIDTH(12), .OFFSET(52),.INIT(0), .NEEDS_SRESET(1)) ex2_rs2_noimm_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX2]),
      .mpw1_b(mpw1_dc_b[DEX2]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex2_rs2_noimm_offset : ex2_rs2_noimm_offset + 12-1]),
      .scout(sov[ex2_rs2_noimm_offset : ex2_rs2_noimm_offset + 12-1]),
      .din(ex1_rs2_noimm[52:63]),
      .dout(ex2_rs2_noimm_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_mtcr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_mtcr_offset : ex3_mtcr_offset + 4-1]),
      .scout(sov[ex3_mtcr_offset : ex3_mtcr_offset + 4-1]),
      .din(ex2_mtcr),
      .dout(ex3_mtcr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_mtcr_sel_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_mtcr_sel_offset]),
      .scout(sov[ex3_mtcr_sel_offset]),
      .din(ex2_mtcr_sel),
      .dout(ex3_mtcr_sel_q)
   );
   tri_rlmreg_p #(.WIDTH(9), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) mm_rs_is_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex2_rs_capt_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[mm_rs_is_offset : mm_rs_is_offset + 9-1]),
      .scout(sov[mm_rs_is_offset : mm_rs_is_offset + 9-1]),
      .din(mm_rs_is_d),
      .dout(mm_rs_is_q)
   );
   tri_rlmreg_p #(.WIDTH(12), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) mm_ra_entry_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex2_ra_capt_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[mm_ra_entry_offset : mm_ra_entry_offset + 12-1]),
      .scout(sov[mm_ra_entry_offset : mm_ra_entry_offset + 12-1]),
      .din(mm_ra_entry_d),
      .dout(mm_ra_entry_q)
   );
   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .OFFSET(64-`GPR_WIDTH),.INIT(0), .NEEDS_SRESET(1)) mm_data_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(ex4_ra_capt_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[mm_data_offset : mm_data_offset + `GPR_WIDTH-1]),
      .scout(sov[mm_data_offset : mm_data_offset + `GPR_WIDTH-1]),
      .din(mm_data_d),
      .dout(mm_data_q)
   );
   tri_rlmreg_p #(.WIDTH(7), .OFFSET(57),.INIT(0), .NEEDS_SRESET(1)) ex3_cnt_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_cnt_rt_offset : ex3_cnt_rt_offset + 7-1]),
      .scout(sov[ex3_cnt_rt_offset : ex3_cnt_rt_offset + 7-1]),
      .din(cnt_byp_ex2_rt),
      .dout(ex3_cnt_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(8), .OFFSET(56),.INIT(0), .NEEDS_SRESET(1)) ex3_prm_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_prm_rt_offset : ex3_prm_rt_offset + 8-1]),
      .scout(sov[ex3_prm_rt_offset : ex3_prm_rt_offset + 8-1]),
      .din(prm_byp_ex2_rt),
      .dout(ex3_prm_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(60),.INIT(0), .NEEDS_SRESET(1)) ex3_dlm_rt_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_dlm_rt_offset : ex3_dlm_rt_offset + 4-1]),
      .scout(sov[ex3_dlm_rt_offset : ex3_dlm_rt_offset + 4-1]),
      .din(dlm_byp_ex2_rt),
      .dout(ex3_dlm_rt_q)
   );
   tri_rlmreg_p #(.WIDTH(10), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_dlm_xer_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_dlm_xer_offset : ex3_dlm_xer_offset + 10-1]),
      .scout(sov[ex3_dlm_xer_offset : ex3_dlm_xer_offset + 10-1]),
      .din(dlm_byp_ex2_xer),
      .dout(ex3_dlm_xer_q)
   );
   tri_rlmreg_p #(.WIDTH(4), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex3_dlm_cr_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(exx_xu0_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX3]),
      .mpw1_b(mpw1_dc_b[DEX3]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex3_dlm_cr_offset : ex3_dlm_cr_offset + 4-1]),
      .scout(sov[ex3_dlm_cr_offset : ex3_dlm_cr_offset + 4-1]),
      .din(dlm_byp_ex2_cr),
      .dout(ex3_dlm_cr_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_mul_ord_done_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex6_mul_ord_done_offset]),
      .scout(sov[ex6_mul_ord_done_offset]),
      .din({1{mul_byp_ex5_ord_done}}),
      .dout(ex6_mul_ord_done_q)
   );
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_mul_abort_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex6_mul_abort_offset]),
      .scout(sov[ex6_mul_abort_offset]),
      .din(mul_byp_ex5_abort),
      .dout(ex6_mul_abort_q)
   );
   tri_rlmreg_p #(.WIDTH(9), .OFFSET(0),.INIT(0), .NEEDS_SRESET(1)) ex6_mul_done_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DEX6]),
      .mpw1_b(mpw1_dc_b[DEX6]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[ex6_mul_done_offset : ex6_mul_done_offset + 9-1]),
      .scout(sov[ex6_mul_done_offset : ex6_mul_done_offset + 9-1]),
      .din({9{mul_byp_ex5_done}}),
      .dout(ex6_mul_done_q)
   );
   tri_rlmreg_p #(.WIDTH(11), .OFFSET(2),.INIT(0), .NEEDS_SRESET(1)) exx_xu0_abort_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_xu0_abort_offset : exx_xu0_abort_offset + 11-1]),
      .scout(sov[exx_xu0_abort_offset : exx_xu0_abort_offset + 11-1]),
      .din(exx_xu0_abort_d),
      .dout(exx_xu0_abort_q)
   );
   tri_rlmreg_p #(.WIDTH(5), .OFFSET(3),.INIT(0), .NEEDS_SRESET(1)) exx_xu1_abort_latch(
      .nclk(nclk), .vd(vdd), .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc), .delay_lclkr(delay_lclkr_dc[DX]),
      .mpw1_b(mpw1_dc_b[DX]), .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin (siv[exx_xu1_abort_offset : exx_xu1_abort_offset + 5-1]),
      .scout(sov[exx_xu1_abort_offset : exx_xu1_abort_offset + 5-1]),
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

   function  [0:`GPR_WIDTH-1] fanout2;
      input [0:1] a;
      input integer s;
      integer t;
   begin
      for (t=0;t<`GPR_WIDTH;t=t+1)
      begin : loop
         fanout2[t] = a[t % 2];
      end
   end
   endfunction

endmodule
