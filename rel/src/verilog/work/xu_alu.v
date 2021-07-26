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

//  Description:  XU_FX ALU Top
//
//*****************************************************************************
`include "tri_a2o.vh"
module xu_alu(
   //-------------------------------------------------------------------
   // Clocks & Power
   //-------------------------------------------------------------------
   input [0:`NCLK_WIDTH-1]  nclk,
   inout                    vdd,
   inout                    gnd,

   //-------------------------------------------------------------------
   // Pervasive
   //-------------------------------------------------------------------
   input                    d_mode_dc,
   input                    delay_lclkr_dc,
   input                    mpw1_dc_b,
   input                    mpw2_dc_b,
   input                    func_sl_force,
   input                    func_sl_thold_0_b,
   input                    sg_0,
   input                    scan_in,
   output                   scan_out,

   //-------------------------------------------------------------------
   // Decode Interface
   //-------------------------------------------------------------------
   input                    dec_alu_ex1_act,
   input [0:31]             dec_alu_ex1_instr,
   input                    dec_alu_ex1_sel_isel,		// Critical!
   input [0:`GPR_WIDTH/8-1]  dec_alu_ex1_add_rs1_inv,
   input [0:1]              dec_alu_ex2_add_ci_sel,
   input                    dec_alu_ex1_sel_trap,
   input                    dec_alu_ex1_sel_cmpl,
   input                    dec_alu_ex1_sel_cmp,
   input                    dec_alu_ex1_msb_64b_sel,
   input                    dec_alu_ex1_xer_ov_en,
   input                    dec_alu_ex1_xer_ca_en,

   //-------------------------------------------------------------------
   // Bypass Inputs
   //-------------------------------------------------------------------
   input [64-`GPR_WIDTH:63]  byp_alu_ex2_rs1,		// Source Data
   input [64-`GPR_WIDTH:63]  byp_alu_ex2_rs2,
   input                    byp_alu_ex2_cr_bit,		// CR bit for isel
   input [0:9]              byp_alu_ex2_xer,

   //-------------------------------------------------------------------
   // Bypass Outputs
   //-------------------------------------------------------------------
   output [64-`GPR_WIDTH:63] alu_byp_ex2_add_rt,
   output [64-`GPR_WIDTH:63] alu_byp_ex3_rt,
   output [0:3]             alu_byp_ex3_cr,
   output [0:9]             alu_byp_ex3_xer,

   output                   alu_dec_ex3_trap_val
);

   localparam               msb = 64 - `GPR_WIDTH;
   // Latches
   wire                     ex2_act_q;		// input=>dec_alu_ex1_act                 ,act=>1'b1
   wire                     ex2_sel_isel_q;		// input=>dec_alu_ex1_sel_isel            ,act=>dec_alu_ex1_act
   wire                     ex2_msb_64b_sel_q;		// input=>dec_alu_ex1_msb_64b_sel         ,act=>dec_alu_ex1_act
   wire                     ex2_sel_trap_q;		// input=>dec_alu_ex1_sel_trap            ,act=>dec_alu_ex1_act
   wire                     ex2_sel_cmpl_q;		// input=>dec_alu_ex1_sel_cmpl            ,act=>dec_alu_ex1_act
   wire                     ex2_sel_cmp_q;		// input=>dec_alu_ex1_sel_cmp             ,act=>dec_alu_ex1_act
   wire [6:10]              ex2_instr_6to10_q;		// input=>dec_alu_ex1_instr(6 to 10)      ,act=>dec_alu_ex1_act
   wire                     ex2_xer_ov_en_q;		// input=>dec_alu_ex1_xer_ov_en           ,act=>dec_alu_ex1_act
   wire                     ex2_xer_ca_en_q;		// input=>dec_alu_ex1_xer_ca_en           ,act=>dec_alu_ex1_act
   wire                     ex3_add_ca_q;		// input=>ex2_add_ca                      ,act=>ex2_act_q
   wire                     ex2_add_ca;
   wire                     ex3_add_ovf_q;		// input=>ex2_add_ovf                     ,act=>ex2_act_q
   wire                     ex2_add_ovf;
   wire                     ex3_sel_rot_log_q;		// input=>ex2_sel_rot_log                 ,act=>ex2_act_q
   wire                     ex2_sel_rot_log;
   wire [0:9]               ex3_xer_q;		// input=>byp_alu_ex2_xer(0 to 9)         ,act=>ex2_act_q
   wire                     ex3_xer_ov_en_q;		// input=>ex2_xer_ov_en_q                 ,act=>ex2_act_q
   wire                     ex3_xer_ca_en_q;		// input=>ex2_xer_ca_en_q                 ,act=>ex2_act_q
   // Scanchains
   localparam               ex2_act_offset = 3;
   localparam               ex2_sel_isel_offset = ex2_act_offset + 1;
   localparam               ex2_msb_64b_sel_offset = ex2_sel_isel_offset + 1;
   localparam               ex2_sel_trap_offset = ex2_msb_64b_sel_offset + 1;
   localparam               ex2_sel_cmpl_offset = ex2_sel_trap_offset + 1;
   localparam               ex2_sel_cmp_offset = ex2_sel_cmpl_offset + 1;
   localparam               ex2_instr_6to10_offset = ex2_sel_cmp_offset + 1;
   localparam               ex2_xer_ov_en_offset = ex2_instr_6to10_offset + 5;
   localparam               ex2_xer_ca_en_offset = ex2_xer_ov_en_offset + 1;
   localparam               ex3_add_ca_offset = ex2_xer_ca_en_offset + 1;
   localparam               ex3_add_ovf_offset = ex3_add_ca_offset + 1;
   localparam               ex3_sel_rot_log_offset = ex3_add_ovf_offset + 1;
   localparam               ex3_xer_offset = ex3_sel_rot_log_offset + 1;
   localparam               ex3_xer_ov_en_offset = ex3_xer_offset + 10;
   localparam               ex3_xer_ca_en_offset = ex3_xer_ov_en_offset + 1;
   localparam               scan_right = ex3_xer_ca_en_offset + 1;
   wire [0:scan_right-1]    siv;
   wire [0:scan_right-1]    sov;

   //!! bugspray include: xu_alu.bil;


   // Signals
   wire [msb:63]            ex2_add_rs1;
   wire [msb:63]            ex2_add_rs2;
   wire [msb:63]            ex2_rot_rs0_b;
   wire [msb:63]            ex2_rot_rs1_b;
   wire [msb:63]            ex2_add_rt;
   wire [msb:63]            ex3_alu_rt;
   wire                     ex3_rot_ca;
   wire                     ex3_alu_ca;
   wire                     ex2_add_ci;
   wire [0:3]               ex2_isel_fcn;
   wire [0:3]               ex2_isel_type;
   wire                     ex3_alu_so;

   //---------------------------------------------------------------
   // Source Buffering
   //---------------------------------------------------------------
   assign ex2_add_rs1 = byp_alu_ex2_rs1;
   assign ex2_add_rs2 = byp_alu_ex2_rs2;

   assign ex2_rot_rs0_b = (~byp_alu_ex2_rs1);
   assign ex2_rot_rs1_b = (~byp_alu_ex2_rs2);

   //---------------------------------------------------------------
   // Target Muxing/Buffering
   //---------------------------------------------------------------
   assign alu_byp_ex3_rt = ex3_alu_rt;

   assign ex3_alu_ca = (ex3_sel_rot_log_q == 1'b1) ? ex3_rot_ca :
                       ex3_add_ca_q;
   assign alu_byp_ex3_cr[3] = ex3_alu_so;
   assign alu_byp_ex3_xer[0] = ex3_alu_so;

   assign ex3_alu_so = (ex3_xer_ov_en_q == 1'b1) ? ex3_add_ovf_q | ex3_xer_q[0] :
                       ex3_xer_q[0];

   assign alu_byp_ex3_xer[1] = (ex3_xer_ov_en_q == 1'b1) ? ex3_add_ovf_q :
                               ex3_xer_q[1];

   assign alu_byp_ex3_xer[2] = (ex3_xer_ca_en_q == 1'b1) ? ex3_alu_ca :
                               ex3_xer_q[2];
   assign alu_byp_ex3_xer[3:9] = ex3_xer_q[3:9];

   assign alu_byp_ex2_add_rt = ex2_add_rt;

   //---------------------------------------------------------------
   // Add
   //---------------------------------------------------------------

   xu_alu_add add(
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[0]),
      .scan_out(sov[0]),
      .ex1_act(dec_alu_ex1_act),
      .ex2_msb_64b_sel(ex2_msb_64b_sel_q),
      .dec_alu_ex1_add_rs1_inv(dec_alu_ex1_add_rs1_inv),
      .dec_alu_ex2_add_ci(ex2_add_ci),
      .ex2_rs1(ex2_add_rs1),
      .ex2_rs2(ex2_add_rs2),
      .ex2_add_rt(ex2_add_rt),
      .ex2_add_ovf(ex2_add_ovf),
      .ex2_add_ca(ex2_add_ca)
   );

   //---------------------------------------------------------------
   // Rotate / Logical
   //---------------------------------------------------------------
   assign ex2_add_ci = (dec_alu_ex2_add_ci_sel == 2'b10) ? byp_alu_ex2_xer[2] :
                       (dec_alu_ex2_add_ci_sel == 2'b01) ? 1'b1 :
                                                           1'b0;

   tri_st_rot rot(
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
      .ex1_act(dec_alu_ex1_act),
      .ex1_instr(dec_alu_ex1_instr),
      .ex2_isel_fcn(ex2_isel_fcn),
      .ex2_sel_rot_log(ex2_sel_rot_log),
      // Source Inputs
      .ex2_rs0_b(ex2_rot_rs0_b),
      .ex2_rs1_b(ex2_rot_rs1_b),
      // Other ALU Inputs for muxing
      .ex2_alu_rt(ex2_add_rt),
      // EX3 Bypass Tap
      .ex3_rt(ex3_alu_rt),
      .ex2_log_rt(),
      // EX2 Bypass Tap (logicals only)
      .ex3_xer_ca(ex3_rot_ca),
      .ex3_cr_eq()
   );

   assign ex2_isel_type = {1'b0, (~(byp_alu_ex2_cr_bit)), byp_alu_ex2_cr_bit, 1'b1};
   assign ex2_isel_fcn = ex2_sel_isel_q==1'b1 ? ex2_isel_type : 4'b0;

   //---------------------------------------------------------------
   // Compare / Trap
   //---------------------------------------------------------------

   xu_alu_cmp cmp(
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
      .ex2_act(ex2_act_q),
      .ex1_msb_64b_sel(dec_alu_ex1_msb_64b_sel),
      .ex2_instr(ex2_instr_6to10_q),
      .ex2_sel_trap(ex2_sel_trap_q),
      .ex2_sel_cmpl(ex2_sel_cmpl_q),
      .ex2_sel_cmp(ex2_sel_cmp_q),
      .ex2_rs1_00(ex2_add_rs1[msb]),
      .ex2_rs1_32(ex2_add_rs1[32]),
      .ex2_rs2_00(ex2_add_rs2[msb]),
      .ex2_rs2_32(ex2_add_rs2[32]),
      .ex3_alu_rt(ex3_alu_rt),
      .ex3_add_ca(ex3_add_ca_q),
      .ex3_alu_cr(alu_byp_ex3_cr[0:2]),
      .ex3_trap_val(alu_dec_ex3_trap_val)
   );

   //---------------------------------------------------------------
   // Latches
   //---------------------------------------------------------------

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_act_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(1'b1),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_act_offset]),
      .scout(sov[ex2_act_offset]),
      .din(dec_alu_ex1_act),
      .dout(ex2_act_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sel_isel_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_alu_ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_sel_isel_offset]),
      .scout(sov[ex2_sel_isel_offset]),
      .din(dec_alu_ex1_sel_isel),
      .dout(ex2_sel_isel_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_msb_64b_sel_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_alu_ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_msb_64b_sel_offset]),
      .scout(sov[ex2_msb_64b_sel_offset]),
      .din(dec_alu_ex1_msb_64b_sel),
      .dout(ex2_msb_64b_sel_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sel_trap_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_alu_ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_sel_trap_offset]),
      .scout(sov[ex2_sel_trap_offset]),
      .din(dec_alu_ex1_sel_trap),
      .dout(ex2_sel_trap_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sel_cmpl_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_alu_ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_sel_cmpl_offset]),
      .scout(sov[ex2_sel_cmpl_offset]),
      .din(dec_alu_ex1_sel_cmpl),
      .dout(ex2_sel_cmpl_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sel_cmp_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_alu_ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_sel_cmp_offset]),
      .scout(sov[ex2_sel_cmp_offset]),
      .din(dec_alu_ex1_sel_cmp),
      .dout(ex2_sel_cmp_q)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) ex2_instr_6to10_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_alu_ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_instr_6to10_offset:ex2_instr_6to10_offset + 5 - 1]),
      .scout(sov[ex2_instr_6to10_offset:ex2_instr_6to10_offset + 5 - 1]),
      .din(dec_alu_ex1_instr[6:10]),
      .dout(ex2_instr_6to10_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_xer_ov_en_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_alu_ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_xer_ov_en_offset]),
      .scout(sov[ex2_xer_ov_en_offset]),
      .din(dec_alu_ex1_xer_ov_en),
      .dout(ex2_xer_ov_en_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_xer_ca_en_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_alu_ex1_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_xer_ca_en_offset]),
      .scout(sov[ex2_xer_ca_en_offset]),
      .din(dec_alu_ex1_xer_ca_en),
      .dout(ex2_xer_ca_en_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_add_ca_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_add_ca_offset]),
      .scout(sov[ex3_add_ca_offset]),
      .din(ex2_add_ca),
      .dout(ex3_add_ca_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_add_ovf_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_add_ovf_offset]),
      .scout(sov[ex3_add_ovf_offset]),
      .din(ex2_add_ovf),
      .dout(ex3_add_ovf_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_sel_rot_log_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_sel_rot_log_offset]),
      .scout(sov[ex3_sel_rot_log_offset]),
      .din(ex2_sel_rot_log),
      .dout(ex3_sel_rot_log_q)
   );

   tri_rlmreg_p #(.WIDTH(10), .INIT(0), .NEEDS_SRESET(1)) ex3_xer_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_xer_offset:ex3_xer_offset + 10 - 1]),
      .scout(sov[ex3_xer_offset:ex3_xer_offset + 10 - 1]),
      .din(byp_alu_ex2_xer[0:9]),
      .dout(ex3_xer_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_xer_ov_en_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_xer_ov_en_offset]),
      .scout(sov[ex3_xer_ov_en_offset]),
      .din(ex2_xer_ov_en_q),
      .dout(ex3_xer_ov_en_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_xer_ca_en_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_xer_ca_en_offset]),
      .scout(sov[ex3_xer_ca_en_offset]),
      .din(ex2_xer_ca_en_q),
      .dout(ex3_xer_ca_en_q)
   );

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];

endmodule
