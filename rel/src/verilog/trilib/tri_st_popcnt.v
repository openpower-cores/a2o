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

//*****************************************************************************
//  Description:  XU Population Count
//
//*****************************************************************************

`include "tri_a2o.vh"

module tri_st_popcnt(
   nclk,
   vdd,
   gnd,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   d_mode_dc,
   func_sl_force,
   func_sl_thold_0_b,
   sg_0,
   scan_in,
   scan_out,
   ex1_act,
   ex1_instr,
   ex2_popcnt_rs1,
   ex4_popcnt_rt
);
   //-------------------------------------------------------------------
   // Clocks & Power
   //-------------------------------------------------------------------
   input [0:`NCLK_WIDTH-1] nclk;
   inout                 vdd;
   inout                 gnd;

   //-------------------------------------------------------------------
   // Pervasive
   //-------------------------------------------------------------------
   input                 delay_lclkr_dc;
   input                 mpw1_dc_b;
   input                 mpw2_dc_b;
   input                 d_mode_dc;
   input                 func_sl_force;
   input                 func_sl_thold_0_b;
   input                 sg_0;
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *) // scan_in
   input                 scan_in;
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) // scan_out
   output                scan_out;

   input                 ex1_act;
   input [22:23]         ex1_instr;
   input [0:63]          ex2_popcnt_rs1;
   output [0:63]         ex4_popcnt_rt;

   // Latches
   wire [2:3]            exx_act_q;		// input=>exx_act_d        ,act=>1
   wire [2:3]            exx_act_d;
   wire [22:23]          ex2_instr_q;		// input=>ex1_instr        ,act=>exx_act(1)
   wire [0:2]            ex3_popcnt_sel_q;		// input=>ex2_popcnt_sel   ,act=>exx_act(2)
   wire [0:2]            ex2_popcnt_sel;
   wire [0:7]            ex3_b3_q;		// input=>ex2_b3           ,act=>exx_act(2)
   wire [0:7]            ex2_b3;
   wire [0:7]            ex3_b2_q;		// input=>ex2_b2           ,act=>exx_act(2)
   wire [0:7]            ex2_b2;
   wire [0:7]            ex3_b1_q;		// input=>ex2_b1           ,act=>exx_act(2)
   wire [0:7]            ex2_b1;
   wire [0:7]            ex3_b0_q;		// input=>ex2_b0           ,act=>exx_act(2)
   wire [0:7]            ex2_b0;
   wire [0:7]            ex4_b3_q;		// input=>ex3_b3_q         ,act=>exx_act(3)
   wire [0:7]            ex4_b2_q;		// input=>ex3_b2_q         ,act=>exx_act(3)
   wire [0:7]            ex4_b1_q;		// input=>ex3_b1_q         ,act=>exx_act(3)
   wire [0:7]            ex4_b0_q;		// input=>ex3_b0_q         ,act=>exx_act(3)
   wire [0:5]            ex4_word0_q;		// input=>ex3_word0        ,act=>exx_act(3)
   wire [0:5]            ex3_word0;
   wire [0:5]            ex4_word1_q;		// input=>ex3_word1        ,act=>exx_act(3)
   wire [0:5]            ex3_word1;
   wire [0:2]            ex4_popcnt_sel_q;		// input=>ex3_popcnt_sel_q ,act=>exx_act(3)
   // Scanchain
   parameter             exx_act_offset = 0;
   parameter             ex2_instr_offset = exx_act_offset + 2;
   parameter             ex3_popcnt_sel_offset = ex2_instr_offset + 2;
   parameter             ex3_b3_offset = ex3_popcnt_sel_offset + 3;
   parameter             ex3_b2_offset = ex3_b3_offset + 8;
   parameter             ex3_b1_offset = ex3_b2_offset + 8;
   parameter             ex3_b0_offset = ex3_b1_offset + 8;
   parameter             ex4_b3_offset = ex3_b0_offset + 8;
   parameter             ex4_b2_offset = ex4_b3_offset + 8;
   parameter             ex4_b1_offset = ex4_b2_offset + 8;
   parameter             ex4_b0_offset = ex4_b1_offset + 8;
   parameter             ex4_word0_offset = ex4_b0_offset + 8;
   parameter             ex4_word1_offset = ex4_word0_offset + 6;
   parameter             ex4_popcnt_sel_offset = ex4_word1_offset + 6;
   parameter             scan_right = ex4_popcnt_sel_offset + 3;
   wire [0:scan_right-1] siv;
   wire [0:scan_right-1] sov;
   // Signals
   wire [0:63]           ex4_popcnt_byte;
   wire [0:63]           ex4_popcnt_word;
   wire [0:63]           ex4_popcnt_dword;
   wire [1:3]            exx_act;

   assign exx_act_d[2:3] = exx_act[1:2];
   assign exx_act[1:3] = {ex1_act, exx_act_q[2:3]};

   generate
      genvar                i;
      for (i = 0; i <= 7; i = i + 1)
      begin : byte_gen

         tri_st_popcnt_byte byte(
            .b0(ex2_popcnt_rs1[8*i:8*i+7]),
            .y({ex2_b3[i],ex2_b2[i],ex2_b1[i],ex2_b0[i]}),
            .vdd(vdd),
            .gnd(gnd)
         );

         assign ex4_popcnt_byte[8*i+0:8*i+3] = 0;
         assign ex4_popcnt_byte[8*i+4] = ex4_b3_q[i];
         assign ex4_popcnt_byte[8*i+5] = ex4_b2_q[i];
         assign ex4_popcnt_byte[8*i+6] = ex4_b1_q[i];
         assign ex4_popcnt_byte[8*i+7] = ex4_b0_q[i];
      end
   endgenerate


   tri_st_popcnt_word word0(
      .b0(ex3_b0_q[0:3]),
      .b1(ex3_b1_q[0:3]),
      .b2(ex3_b2_q[0:3]),
      .b3(ex3_b3_q[0:3]),
      .y(ex3_word0),
      .vdd(vdd),
      .gnd(gnd)
   );


   tri_st_popcnt_word word1(
      .b0(ex3_b0_q[4:7]),
      .b1(ex3_b1_q[4:7]),
      .b2(ex3_b2_q[4:7]),
      .b3(ex3_b3_q[4:7]),
      .y(ex3_word1),
      .vdd(vdd),
      .gnd(gnd)
   );

   assign ex4_popcnt_word[00:25] = {26{1'b0}};
   assign ex4_popcnt_word[26:31] = ex4_word0_q;
   assign ex4_popcnt_word[32:57] = {26{1'b0}};
   assign ex4_popcnt_word[58:63] = ex4_word1_q;

   assign ex4_popcnt_dword[00:56] = {57{1'b0}};
   assign ex4_popcnt_dword[57:63] = {1'b0, ex4_word0_q} + {1'b0, ex4_word1_q};

   assign ex2_popcnt_sel[0] = (ex2_instr_q == 2'b00) ? 1'b1 : 1'b0;
   assign ex2_popcnt_sel[1] = (ex2_instr_q == 2'b10) ? 1'b1 : 1'b0;
   assign ex2_popcnt_sel[2] = (ex2_instr_q == 2'b11) ? 1'b1 : 1'b0;

   assign ex4_popcnt_rt = (ex4_popcnt_byte  & {64{ex4_popcnt_sel_q[0]}}) |
                          (ex4_popcnt_word  & {64{ex4_popcnt_sel_q[1]}}) |
                          (ex4_popcnt_dword & {64{ex4_popcnt_sel_q[2]}});

   //-------------------------------------------------------------------
   // Latch instances
   //-------------------------------------------------------------------

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) exx_act_latch(
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
      .scin(siv[exx_act_offset:exx_act_offset + 2 - 1]),
      .scout(sov[exx_act_offset:exx_act_offset + 2 - 1]),
      .din(exx_act_d),
      .dout(exx_act_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex2_instr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(exx_act[1]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_instr_offset:ex2_instr_offset + 2 - 1]),
      .scout(sov[ex2_instr_offset:ex2_instr_offset + 2 - 1]),
      .din(ex1_instr),
      .dout(ex2_instr_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex3_popcnt_sel_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_popcnt_sel_offset:ex3_popcnt_sel_offset + 3 - 1]),
      .scout(sov[ex3_popcnt_sel_offset:ex3_popcnt_sel_offset + 3 - 1]),
      .din(ex2_popcnt_sel),
      .dout(ex3_popcnt_sel_q)
   );

   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex3_b3_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_b3_offset:ex3_b3_offset + 8 - 1]),
      .scout(sov[ex3_b3_offset:ex3_b3_offset + 8 - 1]),
      .din(ex2_b3),
      .dout(ex3_b3_q)
   );

   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex3_b2_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_b2_offset:ex3_b2_offset + 8 - 1]),
      .scout(sov[ex3_b2_offset:ex3_b2_offset + 8 - 1]),
      .din(ex2_b2),
      .dout(ex3_b2_q)
   );

   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex3_b1_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_b1_offset:ex3_b1_offset + 8 - 1]),
      .scout(sov[ex3_b1_offset:ex3_b1_offset + 8 - 1]),
      .din(ex2_b1),
      .dout(ex3_b1_q)
   );

   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex3_b0_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(exx_act[2]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_b0_offset:ex3_b0_offset + 8 - 1]),
      .scout(sov[ex3_b0_offset:ex3_b0_offset + 8 - 1]),
      .din(ex2_b0),
      .dout(ex3_b0_q)
   );

   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex4_b3_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_b3_offset:ex4_b3_offset + 8 - 1]),
      .scout(sov[ex4_b3_offset:ex4_b3_offset + 8 - 1]),
      .din(ex3_b3_q),
      .dout(ex4_b3_q)
   );

   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex4_b2_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_b2_offset:ex4_b2_offset + 8 - 1]),
      .scout(sov[ex4_b2_offset:ex4_b2_offset + 8 - 1]),
      .din(ex3_b2_q),
      .dout(ex4_b2_q)
   );

   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex4_b1_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_b1_offset:ex4_b1_offset + 8 - 1]),
      .scout(sov[ex4_b1_offset:ex4_b1_offset + 8 - 1]),
      .din(ex3_b1_q),
      .dout(ex4_b1_q)
   );

   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex4_b0_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_b0_offset:ex4_b0_offset + 8 - 1]),
      .scout(sov[ex4_b0_offset:ex4_b0_offset + 8 - 1]),
      .din(ex3_b0_q),
      .dout(ex4_b0_q)
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) ex4_word0_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_word0_offset:ex4_word0_offset + 6 - 1]),
      .scout(sov[ex4_word0_offset:ex4_word0_offset + 6 - 1]),
      .din(ex3_word0),
      .dout(ex4_word0_q)
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) ex4_word1_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_word1_offset:ex4_word1_offset + 6 - 1]),
      .scout(sov[ex4_word1_offset:ex4_word1_offset + 6 - 1]),
      .din(ex3_word1),
      .dout(ex4_word1_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex4_popcnt_sel_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(exx_act[3]),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex4_popcnt_sel_offset:ex4_popcnt_sel_offset + 3 - 1]),
      .scout(sov[ex4_popcnt_sel_offset:ex4_popcnt_sel_offset + 3 - 1]),
      .din(ex3_popcnt_sel_q),
      .dout(ex4_popcnt_sel_q)
   );

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];


endmodule
