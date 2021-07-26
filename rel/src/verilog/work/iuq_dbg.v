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

//********************************************************************
//*
//* TITLE: Instruction Unit Debug
//*
//* NAME: iuq_dbg.v
//*
//*********************************************************************

`include "tri_a2o.vh"

module iuq_dbg(
   inout                            vdd,
   inout                            gnd,

    (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]          nclk,
   input                            thold_2,   // Connect to slp if unit uses slp
   input                            pc_iu_sg_2,
   input                            clkoff_b,
   input                            act_dis,
   input                            tc_ac_ccflush_dc,
   input                            d_mode,
   input                            delay_lclkr,
   input                            mpw1_b,
   input                            mpw2_b,
    (* pin_data ="PIN_FUNCTION=/SCAN_IN/" *)
   input                            func_scan_in,
    (* pin_data ="PIN_FUNCTION=/SCAN_OUT/" *)
   output                           func_scan_out,

   input [0:31]                     unit_dbg_data0,
   input [0:31]                     unit_dbg_data1,
   input [0:31]                     unit_dbg_data2,
   input [0:31]                     unit_dbg_data3,
   input [0:31]                     unit_dbg_data4,
   input [0:31]                     unit_dbg_data5,
   input [0:31]                     unit_dbg_data6,
   input [0:31]                     unit_dbg_data7,
   input [0:31]                     unit_dbg_data8,
   input [0:31]                     unit_dbg_data9,
   input [0:31]                     unit_dbg_data10,
   input [0:31]                     unit_dbg_data11,
   input [0:31]                     unit_dbg_data12,
   input [0:31]                     unit_dbg_data13,
   input [0:31]                     unit_dbg_data14,
   input [0:31]                     unit_dbg_data15,

   input                            pc_iu_trace_bus_enable,
   input [0:10]                     pc_iu_debug_mux_ctrls,

   input  [0:31]                    debug_bus_in,
   output [0:31]                    debug_bus_out,
   input  [0:3]                     coretrace_ctrls_in,
   output [0:3]                     coretrace_ctrls_out
);

   localparam                       trace_bus_enable_offset = 0;
   localparam                       debug_mux_ctrls_offset = trace_bus_enable_offset + 1;
   localparam                       trace_data_out_offset = debug_mux_ctrls_offset + 11;
   localparam                       coretrace_ctrls_out_offset = trace_data_out_offset + 32;
   localparam                       scan_right = coretrace_ctrls_out_offset + 4 - 1;

   wire                             trace_bus_enable_d;
   wire                             trace_bus_enable_q;

   wire [0:10]                      debug_mux_ctrls_d;
   wire [0:10]                      debug_mux_ctrls_q;

   wire [0:31]                      trace_data_out_d;
   wire [0:31]                      trace_data_out_q;

   wire [0:3]                       coretrace_ctrls_out_d;
   wire [0:3]                       coretrace_ctrls_out_q;

   wire [0:scan_right]              siv;
   wire [0:scan_right]              sov;

   wire                             thold_1;
   wire                             thold_0;
   wire                             thold_0_b;
   wire                             pc_iu_sg_1;
   wire                             pc_iu_sg_0;
   wire                             force_t;

   wire                             tiup;

   //BEGIN

   assign  tiup = 1'b1;

   tri_debug_mux16  dbg_mux0(
       //.vd(vdd),
       //.gd(gnd),
       .select_bits(debug_mux_ctrls_q),
       .trace_data_in(debug_bus_in),
       .dbg_group0(unit_dbg_data0),
       .dbg_group1(unit_dbg_data1),
       .dbg_group2(unit_dbg_data2),
       .dbg_group3(unit_dbg_data3),
       .dbg_group4(unit_dbg_data4),
       .dbg_group5(unit_dbg_data5),
       .dbg_group6(unit_dbg_data6),
       .dbg_group7(unit_dbg_data7),
       .dbg_group8(unit_dbg_data8),
       .dbg_group9(unit_dbg_data9),
       .dbg_group10(unit_dbg_data10),
       .dbg_group11(unit_dbg_data11),
       .dbg_group12(unit_dbg_data12),
       .dbg_group13(unit_dbg_data13),
       .dbg_group14(unit_dbg_data14),
       .dbg_group15(unit_dbg_data15),
       .trace_data_out(trace_data_out_d),
       .coretrace_ctrls_in(coretrace_ctrls_in),
       .coretrace_ctrls_out(coretrace_ctrls_out_d)
   );

   assign debug_bus_out = trace_data_out_q;
   assign coretrace_ctrls_out = coretrace_ctrls_out_q;

   //---------------------------------------------------------------------
   // Latches
   //---------------------------------------------------------------------
   assign trace_bus_enable_d = pc_iu_trace_bus_enable;
   assign debug_mux_ctrls_d  = pc_iu_debug_mux_ctrls;

   tri_rlmlatch_p #(.INIT(0)) trace_bus_enable_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[trace_bus_enable_offset]),
      .scout(sov[trace_bus_enable_offset]),
      .din(trace_bus_enable_d),
      .dout(trace_bus_enable_q)
   );

   tri_rlmreg_p #(.WIDTH(11), .INIT(0)) debug_mux_ctrls_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(trace_bus_enable_q),
      .thold_b(thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[debug_mux_ctrls_offset:debug_mux_ctrls_offset + 10]),
      .scout(sov[debug_mux_ctrls_offset:debug_mux_ctrls_offset + 10]),
      .din(debug_mux_ctrls_d),
      .dout(debug_mux_ctrls_q)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0)) trace_data_out_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(trace_bus_enable_q),
      .thold_b(thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[trace_data_out_offset:trace_data_out_offset + 31]),
      .scout(sov[trace_data_out_offset:trace_data_out_offset + 31]),
      .din(trace_data_out_d),
      .dout(trace_data_out_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) coretrace_ctrls_out_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(trace_bus_enable_q),
      .thold_b(thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[coretrace_ctrls_out_offset:coretrace_ctrls_out_offset + 3]),
      .scout(sov[coretrace_ctrls_out_offset:coretrace_ctrls_out_offset + 3]),
      .din(coretrace_ctrls_out_d),
      .dout(coretrace_ctrls_out_q)
   );

   //---------------------------------------------------------------------
   // pervasive thold/sg latches
   //---------------------------------------------------------------------
   tri_plat #(.WIDTH(2)) perv_2to1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({thold_2, pc_iu_sg_2}),
      .q(  {thold_1, pc_iu_sg_1})
   );

   tri_plat #(.WIDTH(2)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({thold_1, pc_iu_sg_1}),
      .q(  {thold_0, pc_iu_sg_0})
   );

   tri_lcbor  perv_lcbor(
      .clkoff_b(clkoff_b),
      .thold(thold_0),
      .sg(pc_iu_sg_0),
      .act_dis(act_dis),
      .force_t(force_t),
      .thold_b(thold_0_b)
   );

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv[0:scan_right] = {sov[1:scan_right], func_scan_in};
   assign func_scan_out = sov[0];

endmodule
