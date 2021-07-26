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

// *********************************************************************
//
// This is the ENTITY for fu_perv
//
// *********************************************************************

`include "tri_a2o.vh"

module fu_perv(
   vdd,
   gnd,
   nclk,
   pc_fu_sg_3,
   pc_fu_abst_sl_thold_3,
   pc_fu_func_sl_thold_3,
   pc_fu_func_slp_sl_thold_3,
   pc_fu_gptr_sl_thold_3,
   pc_fu_time_sl_thold_3,
   pc_fu_ary_nsl_thold_3,
   pc_fu_cfg_sl_thold_3,
   pc_fu_repr_sl_thold_3,
   pc_fu_fce_3,
   tc_ac_ccflush_dc,
   tc_ac_scan_diag_dc,
   abst_sl_thold_1,
   func_sl_thold_1,
   time_sl_thold_1,
   ary_nsl_thold_1,
   cfg_sl_thold_1,
   gptr_sl_thold_0,
   func_slp_sl_thold_1,
   fce_1,
   sg_1,
   clkoff_dc_b,
   act_dis,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   repr_scan_in,
   repr_scan_out,
   gptr_scan_in,
   gptr_scan_out
);
   inout        vdd;
   inout        gnd;

   input [0:`NCLK_WIDTH-1]        nclk;
   input [0:1]  pc_fu_sg_3;
   input        pc_fu_abst_sl_thold_3;
   input [0:1]  pc_fu_func_sl_thold_3;
   input [0:1]  pc_fu_func_slp_sl_thold_3;
   input        pc_fu_gptr_sl_thold_3;
   input        pc_fu_time_sl_thold_3;
   input        pc_fu_ary_nsl_thold_3;
   input        pc_fu_cfg_sl_thold_3;
   input        pc_fu_repr_sl_thold_3;
   input        pc_fu_fce_3;
   input        tc_ac_ccflush_dc;
   input        tc_ac_scan_diag_dc;
   output       abst_sl_thold_1;
   output [0:1] func_sl_thold_1;
   output       time_sl_thold_1;
   output       ary_nsl_thold_1;
   output       cfg_sl_thold_1;
   output 	gptr_sl_thold_0;
   output 	func_slp_sl_thold_1;

   output       fce_1;
   output [0:1] sg_1;
   output       clkoff_dc_b;
   output       act_dis;
   output [0:9] delay_lclkr_dc;
   output [0:9] mpw1_dc_b;
   output [0:1] mpw2_dc_b;
   input        repr_scan_in;		//tc_ac_repr_scan_in(2)
   output       repr_scan_out;		//tc_ac_repr_scan_in(2)
   input        gptr_scan_in;
   output       gptr_scan_out;

   //--

   wire         abst_sl_thold_2;
   wire         time_sl_thold_2;
   wire [0:1]   func_sl_thold_2;
   wire         func_slp_sl_thold_2;

   wire         gptr_sl_thold_0_int;



   wire         gptr_sl_thold_2;
   wire         ary_nsl_thold_2;
   wire         cfg_sl_thold_2;
   wire         repr_sl_thold_2;

   wire [0:1]   sg_2;
   wire         fce_2;

   wire         gptr_sl_thold_1;
   wire         repr_sl_thold_1;
   wire [0:1]   sg_1_int;


   wire         repr_sl_thold_0;
   wire         repr_sl_force;
   wire         repr_sl_thold_0_b;
   wire         repr_in;
   wire         repr_UNUSED;

   (* analysis_not_assigned="true" *)
   (* analysis_not_referenced="true" *)
   wire         spare_unused;

   wire         sg_0;
   wire         gptr_sio;
   wire [0:9]   prv_delay_lclkr_dc;
   wire [0:9]   prv_mpw1_dc_b;
   wire [0:1]   prv_mpw2_dc_b;
   wire         prv_act_dis;
   wire         prv_clkoff_dc_b;
   wire         tihi;
   wire         tiup;

   assign tihi = 1'b1;
   assign tiup = 1'b1;


   tri_plat #(.WIDTH(12)) perv_3to2_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),

      .din({
             pc_fu_func_sl_thold_3[0:1],
             pc_fu_gptr_sl_thold_3,
             pc_fu_abst_sl_thold_3,
	     pc_fu_sg_3[0:1],
             pc_fu_time_sl_thold_3,
             pc_fu_fce_3,
             pc_fu_ary_nsl_thold_3,
             pc_fu_cfg_sl_thold_3,
             pc_fu_repr_sl_thold_3,
             pc_fu_func_slp_sl_thold_3[0]}),

      .q({
             func_sl_thold_2[0:1],
             gptr_sl_thold_2,
             abst_sl_thold_2,
	     sg_2[0:1],
             time_sl_thold_2,
             fce_2,
             ary_nsl_thold_2,
             cfg_sl_thold_2,
             repr_sl_thold_2,
             func_slp_sl_thold_2})
   );


   tri_plat #(.WIDTH(12)) perv_2to1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),

      .din({
             func_sl_thold_2[0:1],
             gptr_sl_thold_2,
             abst_sl_thold_2,
	     sg_2[0:1],
             time_sl_thold_2,
             fce_2,
             ary_nsl_thold_2,
             cfg_sl_thold_2,
             repr_sl_thold_2,
             func_slp_sl_thold_2}),

      .q({
             func_sl_thold_1[0:1],
             gptr_sl_thold_1,
             abst_sl_thold_1,
	     sg_1_int[0:1],
             time_sl_thold_1,
             fce_1,
             ary_nsl_thold_1,
             cfg_sl_thold_1,
             repr_sl_thold_1,
             func_slp_sl_thold_1})
   );

   assign sg_1[0:1] = sg_1_int[0:1];


   tri_plat #(.WIDTH(3)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({ gptr_sl_thold_1,
             sg_1_int[0],
             repr_sl_thold_1}),

      .q({   gptr_sl_thold_0_int,
             sg_0,
             repr_sl_thold_0})
   );

  assign gptr_sl_thold_0 = gptr_sl_thold_0_int;

// Pipeline mapping of mpw1_b and delay_lclkr, mpw2_b
// RF0  8       1
// RF1  0       0
// EX1  1       0
// EX2  2       0
// EX3  3       0
// EX4  4       0
// EX5  5       1
// EX6  6       1
// EX7  7       1
// Ctrl 9       1

   tri_lcbcntl_mac  perv_lcbctrl0(
      .vdd(vdd),
      .gnd(gnd),
      .sg(sg_0),
      .nclk(nclk),
      .scan_in(gptr_scan_in),
      .scan_diag_dc(tc_ac_scan_diag_dc),
      .thold(gptr_sl_thold_0_int),
      .clkoff_dc_b(prv_clkoff_dc_b),
      .delay_lclkr_dc(prv_delay_lclkr_dc[0:4]),
      .act_dis_dc(),
      .mpw1_dc_b(prv_mpw1_dc_b[0:4]),
      .mpw2_dc_b(prv_mpw2_dc_b[0]),
      .scan_out(gptr_sio)
   );


   tri_lcbcntl_mac  perv_lcbctrl1(
      .vdd(vdd),
      .gnd(gnd),
      .sg(sg_0),
      .nclk(nclk),
      .scan_in(gptr_sio),
      .scan_diag_dc(tc_ac_scan_diag_dc),
      .thold(gptr_sl_thold_0_int),
      .clkoff_dc_b(),
      .delay_lclkr_dc(prv_delay_lclkr_dc[5:9]),
      .act_dis_dc(),
      .mpw1_dc_b(prv_mpw1_dc_b[5:9]),
      .mpw2_dc_b(prv_mpw2_dc_b[1]),
      .scan_out(gptr_scan_out)
   );

   //Outputs
   assign delay_lclkr_dc[0:9] = prv_delay_lclkr_dc[0:9];
   assign mpw1_dc_b[0:9] = prv_mpw1_dc_b[0:9];
   assign mpw2_dc_b[0:1] = prv_mpw2_dc_b[0:1];

   //never disable act pins, they are used functionally
   assign prv_act_dis = 1'b0;
   assign act_dis = prv_act_dis;
   assign clkoff_dc_b = prv_clkoff_dc_b;

   // Repower latch for repr scan ins/outs

   tri_lcbor  repr_sl_lcbor_0(
      .clkoff_b(prv_clkoff_dc_b),
      .thold(repr_sl_thold_0),
      .sg(sg_0),
      .act_dis(prv_act_dis),
      .force_t(repr_sl_force),
      .thold_b(repr_sl_thold_0_b)
   );

   assign repr_in = 1'b0;

   tri_rlmreg_p #(.INIT(0),  .WIDTH(1)) repr_rpwr_lat(
      .nclk(nclk),
      .act(tihi),
      .force_t(repr_sl_force),
      .d_mode(tiup),
      .delay_lclkr(prv_delay_lclkr_dc[9]),
      .mpw1_b(prv_mpw1_dc_b[9]),
      .mpw2_b(prv_mpw2_dc_b[1]),
      .thold_b(repr_sl_thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(repr_scan_in),
      .scout(repr_scan_out),
      //-------------------------------------------
      .din(repr_in),
      //-------------------------------------------
      .dout(repr_UNUSED)
   );

// Unused logic
   assign spare_unused = pc_fu_func_slp_sl_thold_3[1];


endmodule
