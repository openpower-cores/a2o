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


//  Description:  XU ALU Compare
//
//*****************************************************************************
`include "tri_a2o.vh"
module xu_alu_cmp(
   // Clocks
   input [0:`NCLK_WIDTH-1] nclk,

   // Power
   inout                   vdd,
   inout                   gnd,

   // Pervasive
   input                   d_mode_dc,
   input                   delay_lclkr_dc,
   input                   mpw1_dc_b,
   input                   mpw2_dc_b,
   input                   func_sl_force,
   input                   func_sl_thold_0_b,
   input                   sg_0,
   input                   scan_in,
   output                  scan_out,

   input                   ex2_act,

   input                   ex1_msb_64b_sel,

   input [6:10]            ex2_instr,
   input                   ex2_sel_trap,
   input                   ex2_sel_cmpl,
   input                   ex2_sel_cmp,

   input                   ex2_rs1_00,
   input                   ex2_rs1_32,

   input                   ex2_rs2_00,
   input                   ex2_rs2_32,

   input [64-`GPR_WIDTH:63] ex3_alu_rt,
   input                   ex3_add_ca,

   output [0:2]            ex3_alu_cr,

   output                  ex3_trap_val
);
   localparam              msb = 64 - `GPR_WIDTH;
   // Latches
   wire                    ex2_msb_64b_sel_q;		// input=>ex1_msb_64b_sel           ,act=>1'b1
   wire                    ex3_msb_64b_sel_q;		// input=>ex2_msb_64b_sel_q         ,act=>ex2_act
   wire                    ex3_diff_sign_q;		// input=>ex2_diff_sign             ,act=>ex2_act
   wire                    ex2_diff_sign;
   wire                    ex3_rs1_trm1_q;		// input=>ex2_rs1_trm1              ,act=>ex2_act
   wire                    ex2_rs1_trm1;
   wire                    ex3_rs2_trm1_q;		// input=>ex2_rs2_trm1              ,act=>ex2_act
   wire                    ex2_rs2_trm1;
   wire [6:10]             ex3_instr_q;		// input=>ex2_instr                 ,act=>ex2_act
   wire                    ex3_sel_trap_q;		// input=>ex2_sel_trap              ,act=>ex2_act
   wire                    ex3_sel_cmpl_q;		// input=>ex2_sel_cmpl              ,act=>ex2_act
   wire                    ex3_sel_cmp_q;		// input=>ex2_sel_cmp               ,act=>ex2_act
   // Scanchains
   localparam              ex2_msb_64b_sel_offset = 0;
   localparam              ex3_msb_64b_sel_offset = ex2_msb_64b_sel_offset + 1;
   localparam              ex3_diff_sign_offset = ex3_msb_64b_sel_offset + 1;
   localparam              ex3_rs1_trm1_offset = ex3_diff_sign_offset + 1;
   localparam              ex3_rs2_trm1_offset = ex3_rs1_trm1_offset + 1;
   localparam              ex3_instr_offset = ex3_rs2_trm1_offset + 1;
   localparam              ex3_sel_trap_offset = ex3_instr_offset + 5;
   localparam              ex3_sel_cmpl_offset = ex3_sel_trap_offset + 1;
   localparam              ex3_sel_cmp_offset = ex3_sel_cmpl_offset + 1;
   localparam              scan_right = ex3_sel_cmp_offset + 1;
   wire [0:scan_right-1]   siv;
   wire [0:scan_right-1]   sov;
   // Signals
   wire                    ex3_cmp0_hi;
   wire                    ex3_cmp0_lo;
   wire                    ex3_cmp0_eq;
   wire                    ex2_rs1_msb;
   wire                    ex2_rs2_msb;
   wire                    ex3_rt_msb;
   wire                    ex3_rslt_gt_s;
   wire                    ex3_rslt_lt_s;
   wire                    ex3_rslt_gt_u;
   wire                    ex3_rslt_lt_u;
   wire                    ex3_cmp_eq;
   wire                    ex3_cmp_gt;
   wire                    ex3_cmp_lt;
   wire                    ex3_sign_cmp;


   tri_st_or3232 or3232(
      .d(ex3_alu_rt),
      .or_hi_b(ex3_cmp0_hi),
      .or_lo_b(ex3_cmp0_lo)
   );

   assign ex2_rs1_msb = (ex2_msb_64b_sel_q == 1'b1) ? ex2_rs1_00 : ex2_rs1_32;

   assign ex2_rs2_msb = (ex2_msb_64b_sel_q == 1'b1) ? ex2_rs2_00 : ex2_rs2_32;

   assign ex3_rt_msb  = (ex3_msb_64b_sel_q == 1'b1) ? ex3_alu_rt[msb] : ex3_alu_rt[32];

   // If the signs are different, then we immediately know if one is bigger than the other.
   //   but only look at this in case of compare instructions
   assign ex3_cmp0_eq = (ex3_msb_64b_sel_q == 1'b1) ? (ex3_cmp0_lo & ex3_cmp0_hi) : ex3_cmp0_lo;

   assign ex2_diff_sign = (ex2_rs1_msb ^ ex2_rs2_msb) & (ex2_sel_cmpl | ex2_sel_cmp | ex2_sel_trap);

   // In case the sigs are not different, we need some more logic
   // Look at adder carry out for compares (need to be able to check over flow case)
   // Look at sign bit for record forms (overflow is ignored, ie two positives equal a negative.)

   assign ex3_sign_cmp = ((ex3_sel_cmpl_q | ex3_sel_cmp_q | ex3_sel_trap_q) == 1'b1) ? ex3_add_ca : ex3_rt_msb;
   assign ex2_rs1_trm1 = ex2_rs1_msb & ex2_diff_sign;
   assign ex2_rs2_trm1 = ex2_rs2_msb & ex2_diff_sign;

   // Signed compare
   assign ex3_rslt_gt_s = (ex3_rs2_trm1_q | (~ex3_sign_cmp & ~ex3_diff_sign_q));		// RS2 < RS1
   assign ex3_rslt_lt_s = (ex3_rs1_trm1_q | ( ex3_sign_cmp & ~ex3_diff_sign_q));		// RS2 > RS1
   // Unsigned compare
   assign ex3_rslt_gt_u = (ex3_rs1_trm1_q | (~ex3_sign_cmp & ~ex3_diff_sign_q));		// RS2 < RS1
   assign ex3_rslt_lt_u = (ex3_rs2_trm1_q | ( ex3_sign_cmp & ~ex3_diff_sign_q));		// RS2 > RS1

   assign ex3_cmp_eq = ex3_cmp0_eq;
   assign ex3_cmp_gt = ((~ex3_sel_cmpl_q & ex3_rslt_gt_s) | (ex3_sel_cmpl_q & ex3_rslt_gt_u)) & (~ex3_cmp0_eq);
   assign ex3_cmp_lt = ((~ex3_sel_cmpl_q & ex3_rslt_lt_s) | (ex3_sel_cmpl_q & ex3_rslt_lt_u)) & (~ex3_cmp0_eq);

   // CR Field for Add, Logical, Rotate
   assign ex3_alu_cr = {ex3_cmp_lt, ex3_cmp_gt, ex3_cmp_eq};

   // Trap logic
   assign ex3_trap_val = ex3_sel_trap_q &
                        ((ex3_instr_q[6]  & (~ex3_cmp_eq) & ex3_rslt_lt_s) |
                         (ex3_instr_q[7]  & (~ex3_cmp_eq) & ex3_rslt_gt_s) |
                         (ex3_instr_q[8]  &   ex3_cmp_eq) |
                         (ex3_instr_q[9]  & (~ex3_cmp_eq) & ex3_rslt_lt_u) |
                         (ex3_instr_q[10] & (~ex3_cmp_eq) & ex3_rslt_gt_u));

   // Latch Instances
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_msb_64b_sel_latch(
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
      .scin(siv[ex2_msb_64b_sel_offset]),
      .scout(sov[ex2_msb_64b_sel_offset]),
      .din(ex1_msb_64b_sel),
      .dout(ex2_msb_64b_sel_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_msb_64b_sel_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_msb_64b_sel_offset]),
      .scout(sov[ex3_msb_64b_sel_offset]),
      .din(ex2_msb_64b_sel_q),
      .dout(ex3_msb_64b_sel_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_diff_sign_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_diff_sign_offset]),
      .scout(sov[ex3_diff_sign_offset]),
      .din(ex2_diff_sign),
      .dout(ex3_diff_sign_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_rs1_trm1_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_rs1_trm1_offset]),
      .scout(sov[ex3_rs1_trm1_offset]),
      .din(ex2_rs1_trm1),
      .dout(ex3_rs1_trm1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_rs2_trm1_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_rs2_trm1_offset]),
      .scout(sov[ex3_rs2_trm1_offset]),
      .din(ex2_rs2_trm1),
      .dout(ex3_rs2_trm1_q)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) ex3_instr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_instr_offset:ex3_instr_offset + 5 - 1]),
      .scout(sov[ex3_instr_offset:ex3_instr_offset + 5 - 1]),
      .din(ex2_instr),
      .dout(ex3_instr_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_sel_trap_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_sel_trap_offset]),
      .scout(sov[ex3_sel_trap_offset]),
      .din(ex2_sel_trap),
      .dout(ex3_sel_trap_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_sel_cmpl_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_sel_cmpl_offset]),
      .scout(sov[ex3_sel_cmpl_offset]),
      .din(ex2_sel_cmpl),
      .dout(ex3_sel_cmpl_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_sel_cmp_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_act),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_sel_cmp_offset]),
      .scout(sov[ex3_sel_cmp_offset]),
      .din(ex2_sel_cmp),
      .dout(ex3_sel_cmp_q)
   );

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];

endmodule
