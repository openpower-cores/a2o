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

//  Description:  Simple Execution Unit
//
//*****************************************************************************
`include "tri_a2o.vh"
module xu1(
   //-------------------------------------------------------------------
   // Clocks & Power
   //-------------------------------------------------------------------
   input [0:`NCLK_WIDTH-1]                   nclk,
   inout                                     vdd,
   inout                                     gnd,

   //-------------------------------------------------------------------
   // Pervasive
   //-------------------------------------------------------------------
   input                                     d_mode_dc,
   input                                     delay_lclkr_dc,
   input                                     mpw1_dc_b,
   input                                     mpw2_dc_b,
   input                                     func_sl_force,
   input                                     func_sl_thold_0_b,
   input                                     sg_0,
   input                                     scan_in,
   output                                    scan_out,

   output                                    xu1_pc_ram_done,
   output [64-`GPR_WIDTH:63]                 xu1_pc_ram_data,

   input                                     xu0_xu1_ex3_act,
   input                                     lq_xu_ex5_act,

   //-------------------------------------------------------------------
   // Interface with SPR
   //-------------------------------------------------------------------
   input [0:`THREADS-1]                      spr_msr_cm,		// 0: 32 bit mode, 1: 64 bit mode

   //-------------------------------------------------------------------
   // Interface with CP
   //-------------------------------------------------------------------
   input [0:`THREADS-1]                      cp_flush,

   //-------------------------------------------------------------------
   // Interface with RV
   //-------------------------------------------------------------------
   input [0:`THREADS-1]                      rv_xu1_vld,
   input                                     rv_xu1_s1_v,
   input                                     rv_xu1_s2_v,
   input                                     rv_xu1_s3_v,
   input [0:31]                              rv_xu1_ex0_instr,
   input [0:`ITAG_SIZE_ENC-1]                rv_xu1_ex0_itag,
   input                                     rv_xu1_ex0_isstore,
   input [1:1]                               rv_xu1_ex0_ucode,
   input                                     rv_xu1_ex0_t1_v,
   input [0:`GPR_POOL_ENC-1]                 rv_xu1_ex0_t1_p,
   input                                     rv_xu1_ex0_t2_v,
   input [0:`GPR_POOL_ENC-1]                 rv_xu1_ex0_t2_p,
   input                                     rv_xu1_ex0_t3_v,
   input [0:`GPR_POOL_ENC-1]                 rv_xu1_ex0_t3_p,
   input                                     rv_xu1_ex0_s1_v,
   input [0:2]                               rv_xu1_ex0_s3_t,
   input [0:`THREADS-1]                      rv_xu1_ex0_spec_flush,
   input [0:`THREADS-1]                      rv_xu1_ex1_spec_flush,
   input [0:`THREADS-1]                      rv_xu1_ex2_spec_flush,

   //-------------------------------------------------------------------
   // Interface with Bypass Controller
   //-------------------------------------------------------------------
   input [1:11]                              rv_xu1_s1_fxu0_sel,
   input [1:11]                              rv_xu1_s2_fxu0_sel,
   input [2:11]                              rv_xu1_s3_fxu0_sel,
   input [1:6]                               rv_xu1_s1_fxu1_sel,
   input [1:6]                               rv_xu1_s2_fxu1_sel,
   input [2:6]                               rv_xu1_s3_fxu1_sel,
   input [4:8]                               rv_xu1_s1_lq_sel,
   input [4:8]                               rv_xu1_s2_lq_sel,
   input [4:8]                               rv_xu1_s3_lq_sel,
   input [2:3]                               rv_xu1_s1_rel_sel,
   input [2:3]                               rv_xu1_s2_rel_sel,

   //-------------------------------------------------------------------
   // Interface with LQ
   //-------------------------------------------------------------------
   output [0:`THREADS-1]                     xu1_lq_ex2_stq_val,
   output [0:`ITAG_SIZE_ENC-1]               xu1_lq_ex2_stq_itag,
   output [1:4]                              xu1_lq_ex2_stq_size,
   output                                    xu1_lq_ex3_illeg_lswx,
   output                                    xu1_lq_ex3_strg_noop,
   output [(64-`GPR_WIDTH)/8:7]              xu1_lq_ex2_stq_dvc1_cmp,
   output [(64-`GPR_WIDTH)/8:7]              xu1_lq_ex2_stq_dvc2_cmp,

   //-------------------------------------------------------------------
   // Interface with IU
   //-------------------------------------------------------------------
   output [0:`THREADS-1]                     xu1_iu_execute_vld,
   output [0:`ITAG_SIZE_ENC-1]               xu1_iu_itag,

   output [0:`THREADS-1]                     xu_iu_ucode_xer_val,
   output [3:9]                              xu_iu_ucode_xer,

   output                                    xu1_rv_ex2_s1_abort,
   output                                    xu1_rv_ex2_s2_abort,
   output                                    xu1_rv_ex2_s3_abort,
   //-------------------------------------------------------------------
   // Bypass Inputs
   //-------------------------------------------------------------------
   // Regfile Data
   input [64-`GPR_WIDTH:63]                  gpr_xu1_ex1_r1d,
   input [64-`GPR_WIDTH:63]                  gpr_xu1_ex1_r2d,
   input [0:9]                               xer_xu1_ex1_r3d,
   input [0:3]                               cr_xu1_ex1_r3d,
   // External Bypass
   input                                     xu0_xu1_ex2_abort,
   input                                     xu0_xu1_ex6_abort,
   input                                     lq_xu_ex5_abort,
   input [64-`GPR_WIDTH:63]                  xu0_xu1_ex2_rt,
   input [64-`GPR_WIDTH:63]                  xu0_xu1_ex3_rt,
   input [64-`GPR_WIDTH:63]                  xu0_xu1_ex4_rt,
   input [64-`GPR_WIDTH:63]                  xu0_xu1_ex5_rt,
   input [64-`GPR_WIDTH:63]                  xu0_xu1_ex6_rt,
   input [64-`GPR_WIDTH:63]                  xu0_xu1_ex7_rt,
   input [64-`GPR_WIDTH:63]                  xu0_xu1_ex8_rt,
   input [64-`GPR_WIDTH:63]                  xu0_xu1_ex6_lq_rt,
   input [64-`GPR_WIDTH:63]                  xu0_xu1_ex7_lq_rt,
   input [64-`GPR_WIDTH:63]                  xu0_xu1_ex8_lq_rt,
   input [64-`GPR_WIDTH:63]                  lq_xu_ex5_rt,
   input [64-`GPR_WIDTH:63]                  lq_xu_rel_rt,
   input                                     lq_xu_rel_act,
   // CR
   input [0:3]                               lq_xu_ex5_cr,
   input [0:3]                               xu0_xu1_ex3_cr,
   input [0:3]                               xu0_xu1_ex4_cr,
   input [0:3]                               xu0_xu1_ex6_cr,
   // XER
   input [0:9]                               xu0_xu1_ex3_xer,
   input [0:9]                               xu0_xu1_ex4_xer,
   input [0:9]                               xu0_xu1_ex6_xer,
   //-------------------------------------------------------------------
   // Bypass Outputs
   //-------------------------------------------------------------------
   output                                    xu1_xu0_ex3_act,
   output                                    xu1_xu0_ex2_abort,
   output                                    xu1_lq_ex3_abort,
   output [64-`GPR_WIDTH:63]                 xu1_xu0_ex2_rt,
   output [64-`GPR_WIDTH:63]                 xu1_xu0_ex3_rt,
   output [64-`GPR_WIDTH:63]                 xu1_xu0_ex4_rt,
   output [64-`GPR_WIDTH:63]                 xu1_xu0_ex5_rt,
   output [64-`GPR_WIDTH:63]                 xu1_lq_ex3_rt,
   // CR
   output [0:3]                              xu1_xu0_ex3_cr,
   // XER
   output [0:9]                              xu1_xu0_ex3_xer,

   //-------------------------------------------------------------------
   // Interface with Regfiles
   //-------------------------------------------------------------------
   output                                    xu1_gpr_ex3_we,
   output [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1] xu1_gpr_ex3_wa,
   output [64-`GPR_WIDTH:65+`GPR_WIDTH/8]    xu1_gpr_ex3_wd,

   output                                    xu1_xer_ex3_we,
   output [0:`XER_POOL_ENC+`THREADS_POOL_ENC-1] xu1_xer_ex3_wa,
   output [0:9]                              xu1_xer_ex3_w0d,

   output                                    xu1_cr_ex3_we,
   output [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]  xu1_cr_ex3_wa,
   output [0:3]                              xu1_cr_ex3_w0d,

   input [0:`THREADS-1]                      pc_xu_ram_active,
   `ifndef THREADS1
   input [64-`GPR_WIDTH:63]                  spr_dvc1_t1,
   input [64-`GPR_WIDTH:63]                  spr_dvc2_t1,
   `endif
   input [64-`GPR_WIDTH:63]                  spr_dvc1_t0,
   input [64-`GPR_WIDTH:63]                  spr_dvc2_t0,

   // Debug
   input  [0:10] 							         pc_xu_debug_mux_ctrls,
   input  [0:31] 							         xu1_debug_bus_in,
   output [0:31] 							         xu1_debug_bus_out,
   input  [0:3] 							         xu1_coretrace_ctrls_in,
   output [0:3] 							         xu1_coretrace_ctrls_out
);
   //!! Bugspray Include: xu1_byp;

   localparam                                scan_right = 3;
   wire [0:scan_right-1]                     siv;
   wire [0:scan_right-1]                     sov;
   // Signals
   wire                                      byp_dec_ex2_abort;
   wire                                      dec_byp_ex0_act;
   wire [64-`GPR_WIDTH:63]                   dec_byp_ex1_imm;
   wire [24:25]                              dec_byp_ex1_instr;
   wire                                      dec_byp_ex0_rs2_sel_imm;
   wire                                      dec_byp_ex0_rs1_sel_zero;
   wire [0:`THREADS-1]                       dec_byp_ex2_tid;
   wire [(64-`GPR_WIDTH)/8:7]                dec_byp_ex2_dvc_mask;

   wire                                      dec_alu_ex1_act;
   wire [0:31]                               dec_alu_ex1_instr;
   wire                                      dec_alu_ex1_sel_isel;
   wire [0:`GPR_WIDTH/8-1]                   dec_alu_ex1_add_rs1_inv;
   wire [0:1]                                dec_alu_ex2_add_ci_sel;
   wire                                      dec_alu_ex1_sel_trap;
   wire                                      dec_alu_ex1_sel_cmpl;
   wire                                      dec_alu_ex1_sel_cmp;
   wire                                      dec_alu_ex1_msb_64b_sel;
   wire                                      dec_alu_ex1_xer_ov_en;
   wire                                      dec_alu_ex1_xer_ca_en;

   wire [64-`GPR_WIDTH:63]                   alu_byp_ex2_add_rt;
   wire [64-`GPR_WIDTH:63]                   alu_byp_ex3_rt;
   wire [0:3]                                alu_byp_ex3_cr;
   wire [0:9]                                alu_byp_ex3_xer;
   wire [64-`GPR_WIDTH:63]                   byp_alu_ex2_rs1;
   wire [64-`GPR_WIDTH:63]                   byp_alu_ex2_rs2;
   wire                                      byp_alu_ex2_cr_bit;
   wire [0:9]                                byp_alu_ex2_xer;
   wire [3:9]                                byp_dec_ex2_xer;

   assign xu1_debug_bus_out            = xu1_debug_bus_in;
   assign xu1_coretrace_ctrls_out      = xu1_coretrace_ctrls_in;


   xu_alu alu(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[0]),
      .scan_out(sov[0]),
      .dec_alu_ex1_act(dec_alu_ex1_act),
      .dec_alu_ex1_instr(dec_alu_ex1_instr),
      .dec_alu_ex1_sel_isel(dec_alu_ex1_sel_isel),
      .dec_alu_ex1_add_rs1_inv(dec_alu_ex1_add_rs1_inv),
      .dec_alu_ex2_add_ci_sel(dec_alu_ex2_add_ci_sel),
      .dec_alu_ex1_sel_trap(dec_alu_ex1_sel_trap),
      .dec_alu_ex1_sel_cmpl(dec_alu_ex1_sel_cmpl),
      .dec_alu_ex1_sel_cmp(dec_alu_ex1_sel_cmp),
      .dec_alu_ex1_msb_64b_sel(dec_alu_ex1_msb_64b_sel),
      .dec_alu_ex1_xer_ov_en(dec_alu_ex1_xer_ov_en),
      .dec_alu_ex1_xer_ca_en(dec_alu_ex1_xer_ca_en),
      .byp_alu_ex2_rs1(byp_alu_ex2_rs1),
      .byp_alu_ex2_rs2(byp_alu_ex2_rs2),
      .byp_alu_ex2_cr_bit(byp_alu_ex2_cr_bit),
      .byp_alu_ex2_xer(byp_alu_ex2_xer),
      .alu_byp_ex2_add_rt(alu_byp_ex2_add_rt),
      .alu_byp_ex3_rt(alu_byp_ex3_rt),
      .alu_byp_ex3_cr(alu_byp_ex3_cr),
      .alu_byp_ex3_xer(alu_byp_ex3_xer),
      .alu_dec_ex3_trap_val()
   );


   xu1_byp byp(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[1]),
      .scan_out(sov[1]),
      .dec_byp_ex0_act(dec_byp_ex0_act),
      .byp_dec_ex2_abort(byp_dec_ex2_abort),
      .xu0_xu1_ex3_act(xu0_xu1_ex3_act),
      .lq_xu_ex5_act(lq_xu_ex5_act),
      .dec_byp_ex1_imm(dec_byp_ex1_imm),
      .dec_byp_ex1_instr(dec_byp_ex1_instr),
      .dec_byp_ex0_rs2_sel_imm(dec_byp_ex0_rs2_sel_imm),
      .dec_byp_ex0_rs1_sel_zero(dec_byp_ex0_rs1_sel_zero),
      .dec_byp_ex2_tid(dec_byp_ex2_tid),
      .dec_byp_ex2_dvc_mask(dec_byp_ex2_dvc_mask),
      .rv_xu1_s1_v(rv_xu1_s1_v),
      .rv_xu1_s2_v(rv_xu1_s2_v),
      .rv_xu1_s3_v(rv_xu1_s3_v),
      .rv_xu1_s1_fxu0_sel(rv_xu1_s1_fxu0_sel),
      .rv_xu1_s2_fxu0_sel(rv_xu1_s2_fxu0_sel),
      .rv_xu1_s3_fxu0_sel(rv_xu1_s3_fxu0_sel),
      .rv_xu1_s1_fxu1_sel(rv_xu1_s1_fxu1_sel),
      .rv_xu1_s2_fxu1_sel(rv_xu1_s2_fxu1_sel),
      .rv_xu1_s3_fxu1_sel(rv_xu1_s3_fxu1_sel),
      .rv_xu1_s1_lq_sel(rv_xu1_s1_lq_sel),
      .rv_xu1_s2_lq_sel(rv_xu1_s2_lq_sel),
      .rv_xu1_s3_lq_sel(rv_xu1_s3_lq_sel),
      .rv_xu1_s1_rel_sel(rv_xu1_s1_rel_sel),
      .rv_xu1_s2_rel_sel(rv_xu1_s2_rel_sel),
      .gpr_xu1_ex1_r1d(gpr_xu1_ex1_r1d),
      .gpr_xu1_ex1_r2d(gpr_xu1_ex1_r2d),
      .xer_xu1_ex1_r3d(xer_xu1_ex1_r3d),
      .cr_xu1_ex1_r3d(cr_xu1_ex1_r3d),
      .xu0_xu1_ex2_abort(xu0_xu1_ex2_abort),
      .xu0_xu1_ex6_abort(xu0_xu1_ex6_abort),
      .xu0_xu1_ex2_rt(xu0_xu1_ex2_rt),
      .xu0_xu1_ex3_rt(xu0_xu1_ex3_rt),
      .xu0_xu1_ex4_rt(xu0_xu1_ex4_rt),
      .xu0_xu1_ex5_rt(xu0_xu1_ex5_rt),
      .xu0_xu1_ex6_rt(xu0_xu1_ex6_rt),
      .xu0_xu1_ex7_rt(xu0_xu1_ex7_rt),
      .xu0_xu1_ex8_rt(xu0_xu1_ex8_rt),
      .xu0_xu1_ex6_lq_rt(xu0_xu1_ex6_lq_rt),
      .xu0_xu1_ex7_lq_rt(xu0_xu1_ex7_lq_rt),
      .xu0_xu1_ex8_lq_rt(xu0_xu1_ex8_lq_rt),
      .lq_xu_ex5_abort(lq_xu_ex5_abort),
      .lq_xu_ex5_rt(lq_xu_ex5_rt),
      .lq_xu_rel_act(lq_xu_rel_act),
      .lq_xu_rel_rt(lq_xu_rel_rt),
      .lq_xu_ex5_cr(lq_xu_ex5_cr),
      .xu0_xu1_ex3_cr(xu0_xu1_ex3_cr),
      .xu0_xu1_ex4_cr(xu0_xu1_ex4_cr),
      .xu0_xu1_ex6_cr(xu0_xu1_ex6_cr),
      .xu0_xu1_ex3_xer(xu0_xu1_ex3_xer),
      .xu0_xu1_ex4_xer(xu0_xu1_ex4_xer),
      .xu0_xu1_ex6_xer(xu0_xu1_ex6_xer),
      .alu_byp_ex2_add_rt(alu_byp_ex2_add_rt),
      .alu_byp_ex3_rt(alu_byp_ex3_rt),
      .alu_byp_ex3_cr(alu_byp_ex3_cr),
      .alu_byp_ex3_xer(alu_byp_ex3_xer),
      .xu1_xu0_ex2_abort(xu1_xu0_ex2_abort),
      .xu1_lq_ex3_abort(xu1_lq_ex3_abort),
      .xu1_xu0_ex2_rt(xu1_xu0_ex2_rt),
      .xu1_xu0_ex3_rt(xu1_xu0_ex3_rt),
      .xu1_xu0_ex4_rt(xu1_xu0_ex4_rt),
      .xu1_xu0_ex5_rt(xu1_xu0_ex5_rt),
      .xu1_lq_ex3_rt(xu1_lq_ex3_rt),
      .xu1_pc_ram_data(xu1_pc_ram_data),
      .xu1_xu0_ex3_cr(xu1_xu0_ex3_cr),
      .xu1_xu0_ex3_xer(xu1_xu0_ex3_xer),
      .byp_alu_ex2_rs1(byp_alu_ex2_rs1),
      .byp_alu_ex2_rs2(byp_alu_ex2_rs2),
      .byp_alu_ex2_cr_bit(byp_alu_ex2_cr_bit),
      .byp_alu_ex2_xer(byp_alu_ex2_xer),
      .byp_dec_ex2_xer(byp_dec_ex2_xer),
      .xu_iu_ucode_xer(xu_iu_ucode_xer),
      .xu1_rv_ex2_s1_abort(xu1_rv_ex2_s1_abort),
      .xu1_rv_ex2_s2_abort(xu1_rv_ex2_s2_abort),
      .xu1_rv_ex2_s3_abort(xu1_rv_ex2_s3_abort),
      .xu1_gpr_ex3_wd(xu1_gpr_ex3_wd),
      .xu1_xer_ex3_w0d(xu1_xer_ex3_w0d),
      .xu1_cr_ex3_w0d(xu1_cr_ex3_w0d),
      .xu1_lq_ex2_stq_dvc1_cmp(xu1_lq_ex2_stq_dvc1_cmp),
      .xu1_lq_ex2_stq_dvc2_cmp(xu1_lq_ex2_stq_dvc2_cmp),
      `ifndef THREADS1
      .spr_dvc1_t1(spr_dvc1_t1),
      .spr_dvc2_t1(spr_dvc2_t1),
      `endif
      .spr_dvc1_t0(spr_dvc1_t0),
      .spr_dvc2_t0(spr_dvc2_t0)
   );


   xu1_dec dec(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[2]),
      .scan_out(sov[2]),
      .spr_msr_cm(spr_msr_cm),		// 0=> 0,
      .cp_flush(cp_flush),
      .rv_xu1_vld(rv_xu1_vld),
      .rv_xu1_ex0_instr(rv_xu1_ex0_instr),
      .rv_xu1_ex0_itag(rv_xu1_ex0_itag),
      .rv_xu1_ex0_isstore(rv_xu1_ex0_isstore),
      .rv_xu1_ex0_ucode(rv_xu1_ex0_ucode),
      .rv_xu1_ex0_t1_v(rv_xu1_ex0_t1_v),
      .rv_xu1_ex0_t1_p(rv_xu1_ex0_t1_p),
      .rv_xu1_ex0_t2_v(rv_xu1_ex0_t2_v),
      .rv_xu1_ex0_t2_p(rv_xu1_ex0_t2_p),
      .rv_xu1_ex0_t3_v(rv_xu1_ex0_t3_v),
      .rv_xu1_ex0_t3_p(rv_xu1_ex0_t3_p),
      .rv_xu1_ex0_s1_v(rv_xu1_ex0_s1_v),
      .rv_xu1_ex0_s3_t(rv_xu1_ex0_s3_t),
      .rv_xu1_ex0_spec_flush(rv_xu1_ex0_spec_flush),
      .rv_xu1_ex1_spec_flush(rv_xu1_ex1_spec_flush),
      .rv_xu1_ex2_spec_flush(rv_xu1_ex2_spec_flush),
      .xu1_lq_ex2_stq_val(xu1_lq_ex2_stq_val),
      .xu1_lq_ex2_stq_itag(xu1_lq_ex2_stq_itag),
      .xu1_lq_ex2_stq_size(xu1_lq_ex2_stq_size),
      .xu1_lq_ex3_illeg_lswx(xu1_lq_ex3_illeg_lswx),
      .xu1_lq_ex3_strg_noop(xu1_lq_ex3_strg_noop),
      .xu1_iu_execute_vld(xu1_iu_execute_vld),
      .xu1_iu_itag(xu1_iu_itag),
      .xu_iu_ucode_xer_val(xu_iu_ucode_xer_val),
      .xu1_pc_ram_done(xu1_pc_ram_done),
      .dec_alu_ex1_act(dec_alu_ex1_act),
      .dec_alu_ex1_instr(dec_alu_ex1_instr),
      .dec_alu_ex1_sel_isel(dec_alu_ex1_sel_isel),
      .dec_alu_ex1_add_rs1_inv(dec_alu_ex1_add_rs1_inv),
      .dec_alu_ex2_add_ci_sel(dec_alu_ex2_add_ci_sel),
      .dec_alu_ex1_sel_trap(dec_alu_ex1_sel_trap),
      .dec_alu_ex1_sel_cmpl(dec_alu_ex1_sel_cmpl),
      .dec_alu_ex1_sel_cmp(dec_alu_ex1_sel_cmp),
      .dec_alu_ex1_msb_64b_sel(dec_alu_ex1_msb_64b_sel),
      .dec_alu_ex1_xer_ov_en(dec_alu_ex1_xer_ov_en),
      .dec_alu_ex1_xer_ca_en(dec_alu_ex1_xer_ca_en),
      .xu1_xu0_ex3_act(xu1_xu0_ex3_act),
      .dec_byp_ex0_act(dec_byp_ex0_act),
      .byp_dec_ex2_abort(byp_dec_ex2_abort),
      .dec_byp_ex1_imm(dec_byp_ex1_imm),
      .dec_byp_ex1_instr(dec_byp_ex1_instr),
      .dec_byp_ex0_rs2_sel_imm(dec_byp_ex0_rs2_sel_imm),
      .dec_byp_ex0_rs1_sel_zero(dec_byp_ex0_rs1_sel_zero),
      .dec_byp_ex2_tid(dec_byp_ex2_tid),
      .dec_byp_ex2_dvc_mask(dec_byp_ex2_dvc_mask),
      .byp_dec_ex2_xer(byp_dec_ex2_xer),
      .xu1_gpr_ex3_we(xu1_gpr_ex3_we),
      .xu1_gpr_ex3_wa(xu1_gpr_ex3_wa),
      .xu1_xer_ex3_we(xu1_xer_ex3_we),
      .xu1_xer_ex3_wa(xu1_xer_ex3_wa),
      .xu1_cr_ex3_we(xu1_cr_ex3_we),
      .xu1_cr_ex3_wa(xu1_cr_ex3_wa),
      .pc_xu_ram_active(pc_xu_ram_active)
   );

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];

endmodule
