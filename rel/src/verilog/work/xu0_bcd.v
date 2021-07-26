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
//  Description:  XU BCD Assist Instructions
//
//*****************************************************************************
`include "tri_a2o.vh"

module xu0_bcd(
   // Clocks
   input [0:`NCLK_WIDTH-1] nclk,

   // Power
   inout                    vdd,
   inout                    gnd,

   // Pervasive
   input                    d_mode_dc,
   input                    delay_lclkr_dc,
   input                    mpw1_dc_b,
   input                    mpw2_dc_b,
   input                    func_sl_force,
   input                    func_sl_thold_0_b,
   input                    sg_0,
   input                    scan_in,
   output                   scan_out,

   // Decode Inputs
   input                    dec_bcd_ex1_val,
   input                    dec_bcd_ex1_is_addg6s,
   input                    dec_bcd_ex1_is_cdtbcd,

   // Source Data
   input [64-`GPR_WIDTH:63]  byp_bcd_ex2_rs1,
   input [64-`GPR_WIDTH:63]  byp_bcd_ex2_rs2,

   // Target Data
   output [64-`GPR_WIDTH:63] bcd_byp_ex3_rt,
   output                   bcd_byp_ex3_done
);

   // Latches
   wire                     ex2_val_q;		// input=>dec_bcd_ex1_val              ,act=>1'b1
   wire                     ex2_is_addg6s_q;		// input=>dec_bcd_ex1_is_addg6s        ,act=>dec_bcd_ex1_val
   wire                     ex2_is_cdtbcd_q;		// input=>dec_bcd_ex1_is_cdtbcd        ,act=>dec_bcd_ex1_val
   wire [64-`GPR_WIDTH:63]  ex3_bcd_rt_q;      // input=>ex2_bcd_rt                   ,act=>ex2_val_q
   wire [64-`GPR_WIDTH:63]  ex2_bcd_rt;
   wire                     ex3_val_q;		// input=>ex2_val_q                    ,act=>1'b1
   // Scanchains
   localparam               ex2_val_offset = 0;
   localparam               ex2_is_addg6s_offset = ex2_val_offset + 1;
   localparam               ex2_is_cdtbcd_offset = ex2_is_addg6s_offset + 1;
   localparam               ex3_bcd_rt_offset = ex2_is_cdtbcd_offset + 1;
   localparam               ex3_val_offset = ex3_bcd_rt_offset + `GPR_WIDTH;
   localparam               scan_right = ex3_val_offset + 1;
   wire [0:scan_right-1]    siv;
   wire [0:scan_right-1]    sov;
   wire [0:63]              g0;
   wire [0:63]              g1;
   wire [0:63]              g2;
   wire [0:63]              g3;
   wire [0:63]              g4;
   wire [0:63]              g5;
   wire [0:63]              g6;
   wire [0:62]              p0;
   wire [0:61]              p1;
   wire [0:59]              p2;
   wire [0:55]              p3;
   wire [0:47]              p4;
   wire [0:31]              p5;
   wire [0:63]              ex2_bcdtd_rt;
   wire [0:63]              ex2_dtbcd_rt;
   wire [0:63]              ex2_sixes_rt;

    // synopsys translate_off
    (* analysis_not_referenced="true" *)
    // synopsys translate_on
   wire unused;

   // BCD to DPD

   xu0_bcd_bcdtd bcdtd00(
      .a(byp_bcd_ex2_rs1[8:19]),
      .y(ex2_bcdtd_rt[12:21])
   );

   xu0_bcd_bcdtd bcdtd01(
      .a(byp_bcd_ex2_rs1[20:31]),
      .y(ex2_bcdtd_rt[22:31])
   );

   xu0_bcd_bcdtd bcdtd10(
      .a(byp_bcd_ex2_rs1[40:51]),
      .y(ex2_bcdtd_rt[44:53])
   );

   xu0_bcd_bcdtd bcdtd11(
      .a(byp_bcd_ex2_rs1[52:63]),
      .y(ex2_bcdtd_rt[54:63])
   );
   assign ex2_bcdtd_rt[0:11]  = {12{1'b0}};
   assign ex2_bcdtd_rt[32:43] = {12{1'b0}};

   // DPD to BCD

   xu0_bcd_dtbcd dtbcd00(
      .a(byp_bcd_ex2_rs1[12:21]),
      .y(ex2_dtbcd_rt[8:19])
   );

   xu0_bcd_dtbcd dtbcd01(
      .a(byp_bcd_ex2_rs1[22:31]),
      .y(ex2_dtbcd_rt[20:31])
   );

   xu0_bcd_dtbcd dtbcd10(
      .a(byp_bcd_ex2_rs1[44:53]),
      .y(ex2_dtbcd_rt[40:51])
   );

   xu0_bcd_dtbcd dtbcd11(
      .a(byp_bcd_ex2_rs1[54:63]),
      .y(ex2_dtbcd_rt[52:63])
   );
   assign ex2_dtbcd_rt[0:7]   = {8{1'b0}};
   assign ex2_dtbcd_rt[32:39] = {8{1'b0}};

   // ADDG6S
   assign p0[00:62] = byp_bcd_ex2_rs1[00:62] ^ byp_bcd_ex2_rs2[00:62];
   assign g0[00:63] = byp_bcd_ex2_rs1[00:63] & byp_bcd_ex2_rs2[00:63];
   // L1 (1)
   assign g1[00:62] = (p0[00:62] & g0[01:63]) | g0[00:62];
   assign g1[63:63] = g0[63:63];
   assign p1[00:61] = p0[00:61] & p0[01:62];
   // L2 (2)
   assign g2[00:61] = (p1[00:61] & g1[02:63]) | g1[00:61];
   assign g2[62:63] = g1[62:63];
   assign p2[00:59] = p1[00:59] & p1[02:61];
   // L3 (4)
   assign g3[00:59] = (p2[00:59] & g2[04:63]) | g2[00:59];
   assign g3[60:63] = g2[60:63];
   assign p3[00:55] = p2[00:55] & p2[04:59];
   // L4 (8)
   assign g4[00:55] = (p3[00:55] & g3[08:63]) | g3[00:55];
   assign g4[56:63] = g3[56:63];
   assign p4[00:47] = p3[00:47] & p3[08:55];
   // L5 (16)
   assign g5[00:47] = (p4[00:47] & g4[16:63]) | g4[00:47];
   assign g5[48:63] = g4[48:63];
   assign p5[00:31] = p4[00:31] & p4[16:47];
   // L6 (32)
   assign g6[00:31] = (p5[00:31] & g5[32:63]) | g5[00:31];
   assign g6[32:63] = g5[32:63];

   generate
      genvar                   b;
      for (b = 0; b <= 15; b = b + 1)
      begin : nibble
         assign ex2_sixes_rt[4 * b:4 * b + 3] = (g6[b * 4] == 1'b0) ? 4'b0110 :
                                                4'b0000;
      end
   endgenerate
   //!! bugspray include: tri_a2o.bil
   //!! %for(i=0;i<16;++i)
   //!!     [count; scenarios.addg6s_n%(i)_0  ; bugclk] : (pri2) <= ex2_val_q and ex2_is_addg6s_q and not g6(%(i*4));
   //!!     [count; scenarios.addg6s_n%(i)_1  ; bugclk] : (pri2) <= ex2_val_q and ex2_is_addg6s_q and     g6(%(i*4));
   //!! %end

   assign ex2_bcd_rt = ({ex2_is_addg6s_q, ex2_is_cdtbcd_q} == 2'b10) ? ex2_sixes_rt :
                       ({ex2_is_addg6s_q, ex2_is_cdtbcd_q} == 2'b01) ? ex2_dtbcd_rt :
                       ex2_bcdtd_rt;
   assign bcd_byp_ex3_rt = ex3_bcd_rt_q;
   assign bcd_byp_ex3_done = ex3_val_q;


   // Latches
   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_val_latch(
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
      .scin(siv[ex2_val_offset]),
      .scout(sov[ex2_val_offset]),
      .din(dec_bcd_ex1_val),
      .dout(ex2_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_addg6s_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_bcd_ex1_val),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_addg6s_offset]),
      .scout(sov[ex2_is_addg6s_offset]),
      .din(dec_bcd_ex1_is_addg6s),
      .dout(ex2_is_addg6s_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_is_cdtbcd_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(dec_bcd_ex1_val),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex2_is_cdtbcd_offset]),
      .scout(sov[ex2_is_cdtbcd_offset]),
      .din(dec_bcd_ex1_is_cdtbcd),
      .dout(ex2_is_cdtbcd_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex3_bcd_rt_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(ex2_val_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[ex3_bcd_rt_offset:ex3_bcd_rt_offset + `GPR_WIDTH - 1]),
      .scout(sov[ex3_bcd_rt_offset:ex3_bcd_rt_offset + `GPR_WIDTH - 1]),
      .din(ex2_bcd_rt),
      .dout(ex3_bcd_rt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_val_latch(
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
      .scin(siv[ex3_val_offset]),
      .scout(sov[ex3_val_offset]),
      .din(ex2_val_q),
      .dout(ex3_val_q)
   );

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];

   assign unused =  (|g6[1:3]) | (|g6[5:7]) | (|g6[9:11]) | (|g6[13:15]) | (|g6[17:19]) | (|g6[21:23]) | (|g6[25:27]) |
                    (|g6[29:31]) | (|g6[33:35]) | (|g6[37:39]) | (|g6[41:43]) | (|g6[45:47]) | (|g6[49:51]) | (|g6[53:55]) |
                    (|g6[57:59]) | (|g6[61:63]);


endmodule
