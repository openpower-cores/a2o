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
module xu_gpr(
   //-------------------------------------------------------------------
   // Clocks & Power
   //-------------------------------------------------------------------
   input [0:`NCLK_WIDTH-1] nclk,
   inout                               vdd,
   inout                               gnd,

   //-------------------------------------------------------------------
   // Pervasive
   //-------------------------------------------------------------------
   input                               pc_xu_ccflush_dc,
   input                               d_mode_dc,
   input                               delay_lclkr_dc,
   input                               mpw1_dc_b,
   input                               mpw2_dc_b,
   input                               func_sl_force,
   input                               func_sl_thold_0_b,
   input                               sg_0,
   input                               scan_in,
   output                              scan_out,

   //-------------------------------------------------------------------
   // Read Ports
   //-------------------------------------------------------------------
   input                               r0e,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]            r0a,
   output [64-`GPR_WIDTH:63]            r0d,
   input                               r1e,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]            r1a,
   output [64-`GPR_WIDTH:63]            r1d,
   input                               r2e,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]            r2a,
   output [64-`GPR_WIDTH:63]            r2d,
   input                               r3e,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]            r3a,
   output [64-`GPR_WIDTH:63]            r3d,

   // Special Port for 3src instructions- erativax
   input                               r4e,
   input [0:2]                         r4t_q,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]            r4a,

   output                              r0_pe,
   output                              r1_pe,
   output                              r2_pe,
   output                              r3_pe,
   //-------------------------------------------------------------------
   // Write ports
   //-------------------------------------------------------------------
   input                               w0e,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]            w0a,
   input [64-`GPR_WIDTH:65+`GPR_WIDTH/8] w0d,
   input                               w1e,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]            w1a,
   input [64-`GPR_WIDTH:65+`GPR_WIDTH/8] w1d,
   input                               w2e,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]            w2a,
   input [64-`GPR_WIDTH:65+`GPR_WIDTH/8] w2d,
   input                               w3e,
   input [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]            w3a,
   input [64-`GPR_WIDTH:65+`GPR_WIDTH/8] w3d
);

   // Latches
   wire                                r4e_q;		// input=>r4e           ,act=>1'b1
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]             r4a_q;		// input=>r4a           ,act=>1'b1
   // Scanchain
   localparam                          r4e_offset = 2;
   localparam                          r4a_offset = r4e_offset + 1;
   localparam                          scan_right = r4a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC;
   wire [0:scan_right-1]               siv;
   wire [0:scan_right-1]               sov;
   // Signals
   wire [64-`GPR_WIDTH:77]              w0d_int;
   wire [64-`GPR_WIDTH:77]              w1d_int;
   wire [64-`GPR_WIDTH:77]              w2d_int;
   wire [64-`GPR_WIDTH:77]              w3d_int;
   wire [64-`GPR_WIDTH:77]              r0d_int;
   wire [64-`GPR_WIDTH:77]              r1d_int;
   wire [64-`GPR_WIDTH:77]              r2d_int;
   wire [64-`GPR_WIDTH:77]              r3d_int;
   wire [0:`GPR_WIDTH/8-1]              r0d_par;
   wire [0:`GPR_WIDTH/8-1]              r1d_par;
   wire [0:`GPR_WIDTH/8-1]              r2d_par;
   wire [0:`GPR_WIDTH/8-1]              r3d_par;
   wire                                r0e_int;
   wire                                r4e_sel;
   wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]             r0a_int;

   assign r4e_sel = r4e_q & ~|r4t_q;

   assign r0e_int = r4e_sel | r0e;

   assign r0a_int = (r4e_sel == 1'b1) ? r4a_q : r0a;

   assign r0d = r0d_int[64 - `GPR_WIDTH:63];
   assign r1d = r1d_int[64 - `GPR_WIDTH:63];
   assign r2d = r2d_int[64 - `GPR_WIDTH:63];
   assign r3d = r3d_int[64 - `GPR_WIDTH:63];

   assign w0d_int[64 - `GPR_WIDTH:65 + `GPR_WIDTH/8] = w0d;
   assign w0d_int[66 + `GPR_WIDTH/8:77] = {4{1'b0}};
   assign w1d_int[64 - `GPR_WIDTH:65 + `GPR_WIDTH/8] = w1d;
   assign w1d_int[66 + `GPR_WIDTH/8:77] = {4{1'b0}};
   assign w2d_int[64 - `GPR_WIDTH:65 + `GPR_WIDTH/8] = w2d;
   assign w2d_int[66 + `GPR_WIDTH/8:77] = {4{1'b0}};
   assign w3d_int[64 - `GPR_WIDTH:65 + `GPR_WIDTH/8] = w3d;
   assign w3d_int[66 + `GPR_WIDTH/8:77] = {4{1'b0}};

   generate
   genvar                              i;
   for (i = 0; i <= `GPR_WIDTH/8 - 1; i = i + 1)
      begin : parity
         assign r0d_par[i] = ^(r0d_int[8 * i:8 * i + 7]);
         assign r1d_par[i] = ^(r1d_int[8 * i:8 * i + 7]);
         assign r2d_par[i] = ^(r2d_int[8 * i:8 * i + 7]);
         assign r3d_par[i] = ^(r3d_int[8 * i:8 * i + 7]);
      end
   endgenerate

   assign r0_pe = r0e & (r0d_par != r0d_int[64:63 + `GPR_WIDTH/8]);
   assign r1_pe = r1e & (r1d_par != r1d_int[64:63 + `GPR_WIDTH/8]);
   assign r2_pe = r2e & (r2d_par != r2d_int[64:63 + `GPR_WIDTH/8]);
   assign r3_pe = r3e & (r3d_par != r3d_int[64:63 + `GPR_WIDTH/8]);


   tri_144x78_2r4w gpr0(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .func_slp_sl_force(func_sl_force),
      .func_slp_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[0]),
      .scan_out(sov[0]),
      .r_late_en_1(r0e_int),
      .r_addr_in_1(r0a_int),
      .r_data_out_1(r0d_int),
      .r_late_en_2(r1e),
      .r_addr_in_2(r1a),
      .r_data_out_2(r1d_int),
      .w_late_en_1(w0e),
      .w_addr_in_1(w0a),
      .w_data_in_1(w0d_int),
      .w_late_en_2(w1e),
      .w_addr_in_2(w1a),
      .w_data_in_2(w1d_int),
      .w_late_en_3(w2e),
      .w_addr_in_3(w2a),
      .w_data_in_3(w2d_int),
      .w_late_en_4(w3e),
      .w_addr_in_4(w3a),
      .w_data_in_4(w3d_int)
   );


   tri_144x78_2r4w gpr1(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .func_sl_force(func_sl_force),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .func_slp_sl_force(func_sl_force),
      .func_slp_sl_thold_0_b(func_sl_thold_0_b),
      .sg_0(sg_0),
      .scan_in(siv[1]),
      .scan_out(sov[1]),
      .r_late_en_1(r2e),
      .r_addr_in_1(r2a),
      .r_data_out_1(r2d_int),
      .r_late_en_2(r3e),
      .r_addr_in_2(r3a),
      .r_data_out_2(r3d_int),
      .w_late_en_1(w0e),
      .w_addr_in_1(w0a),
      .w_data_in_1(w0d_int),
      .w_late_en_2(w1e),
      .w_addr_in_2(w1a),
      .w_data_in_2(w1d_int),
      .w_late_en_3(w2e),
      .w_addr_in_3(w2a),
      .w_data_in_3(w2d_int),
      .w_late_en_4(w3e),
      .w_addr_in_4(w3a),
      .w_data_in_4(w3d_int)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) r4e_latch(
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
      .scin(siv[r4e_offset]),
      .scout(sov[r4e_offset]),
      .din(r4e),
      .dout(r4e_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC+`THREADS_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) r4a_latch(
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
      .scin(siv[r4a_offset:r4a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC - 1]),
      .scout(sov[r4a_offset:r4a_offset + `GPR_POOL_ENC+`THREADS_POOL_ENC - 1]),
      .din(r4a),
      .dout(r4a_q)
   );

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];

endmodule
