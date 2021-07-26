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

//  Description:  XU LSU Load Data Rotator
//
//*****************************************************************************

// ##########################################################################################
// Contents
// 1) 16 bit Unaligned Rotate to the Right Rotator
// 2) Little/Big Endian Support
// ##########################################################################################

`include "tri_a2o.vh"


module tri_lq_rmw(
   ex2_stq4_rd_stg_act,
   ex2_stq4_rd_addr,
   stq6_rd_data_wa,
   stq6_rd_data_wb,
   stq6_rd_data_wc,
   stq6_rd_data_wd,
   stq6_rd_data_we,
   stq6_rd_data_wf,
   stq6_rd_data_wg,
   stq6_rd_data_wh,
   stq5_stg_act,
   stq5_arr_wren,
   stq5_arr_wr_way,
   stq5_arr_wr_addr,
   stq5_arr_wr_bytew,
   stq5_arr_wr_data,
   stq7_byp_val_wabcd,
   stq7_byp_val_wefgh,
   stq7_byp_data_wabcd,
   stq7_byp_data_wefgh,
   stq8_byp_data_wabcd,
   stq8_byp_data_wefgh,
   stq_byp_val_wabcd,
   stq_byp_val_wefgh,
   dcarr_rd_stg_act,
   dcarr_wr_stg_act,
   dcarr_wr_way,
   dcarr_wr_addr,
   dcarr_wr_data_wabcd,
   dcarr_wr_data_wefgh,
   nclk,
   vdd,
   gnd,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   func_sl_force,
   func_sl_thold_0_b,
   sg_0,
   scan_in,
   scan_out
);

// EX2/STQ4 Read Operation
input               ex2_stq4_rd_stg_act;
input [52:59]       ex2_stq4_rd_addr;

// Read data for Read-Modify-Write
input [0:143]       stq6_rd_data_wa;
input [0:143]       stq6_rd_data_wb;
input [0:143]       stq6_rd_data_wc;
input [0:143]       stq6_rd_data_wd;
input [0:143]       stq6_rd_data_we;
input [0:143]       stq6_rd_data_wf;
input [0:143]       stq6_rd_data_wg;
input [0:143]       stq6_rd_data_wh;

// Write Data for Read-Modify-Write
input               stq5_stg_act;
input               stq5_arr_wren;
input [0:7]         stq5_arr_wr_way;
input [52:59]       stq5_arr_wr_addr;
input [0:15]        stq5_arr_wr_bytew;
input [0:143]       stq5_arr_wr_data;

// EX4 Load Bypass Data for Read/Write Collision detected in EX2
output [0:3]        stq7_byp_val_wabcd;
output [0:3]        stq7_byp_val_wefgh;
output [0:143]      stq7_byp_data_wabcd;
output [0:143]      stq7_byp_data_wefgh;
output [0:143]      stq8_byp_data_wabcd;
output [0:143]      stq8_byp_data_wefgh;
output [0:3]        stq_byp_val_wabcd;
output [0:3]        stq_byp_val_wefgh;

// Data Cache Array Write
output [0:7]        dcarr_rd_stg_act;
output [0:7]        dcarr_wr_stg_act;
output [0:7]        dcarr_wr_way;
output [52:59]      dcarr_wr_addr;
output [0:143]      dcarr_wr_data_wabcd;
output [0:143]      dcarr_wr_data_wefgh;

(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)
input [0:`NCLK_WIDTH-1] nclk;
inout               vdd;
inout               gnd;
input               d_mode_dc;
input               delay_lclkr_dc;
input               mpw1_dc_b;
input               mpw2_dc_b;
input               func_sl_force;
input               func_sl_thold_0_b;
input               sg_0;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input               scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output              scan_out;

wire [52:59]        ex3_stq5_rd_addr_d;
wire [52:59]        ex3_stq5_rd_addr_q;
wire                stq6_stg_act_d;
wire                stq6_stg_act_q;
wire                stq7_stg_act_d;
wire                stq7_stg_act_q;
wire                stq6_wren_d;
wire                stq6_wren_q;
wire                stq7_wren_d;
wire                stq7_wren_q;
wire [0:7]          stq6_way_en_d;
wire [0:7]          stq6_way_en_q;
wire [0:7]          stq7_way_en_d;
wire [0:7]          stq7_way_en_q;
wire [0:7]          stq6_wr_way;
wire [52:59]        stq6_addr_d;
wire [52:59]        stq6_addr_q;
wire [52:59]        stq7_addr_d;
wire [52:59]        stq7_addr_q;
wire [0:143]        stq6_gate_rd_data_wa;
wire [0:143]        stq6_gate_rd_data_wb;
wire [0:143]        stq6_gate_rd_data_wc;
wire [0:143]        stq6_gate_rd_data_wd;
wire [0:143]        stq6_gate_rd_data_we;
wire [0:143]        stq6_gate_rd_data_wf;
wire [0:143]        stq6_gate_rd_data_wg;
wire [0:143]        stq6_gate_rd_data_wh;
wire [0:143]        stq6_rd_data_wabcd;
wire [0:143]        stq6_wr_data_wabcd;
wire [0:143]        stq7_wr_data_wabcd_d;
wire [0:143]        stq7_wr_data_wabcd_q;
wire [0:143]        stq8_wr_data_wabcd_d;
wire [0:143]        stq8_wr_data_wabcd_q;
wire [0:143]        stq6_rd_data_wefgh;
wire [0:143]        stq6_wr_data_wefgh;
wire [0:143]        stq7_wr_data_wefgh_d;
wire [0:143]        stq7_wr_data_wefgh_q;
wire [0:143]        stq8_wr_data_wefgh_d;
wire [0:143]        stq8_wr_data_wefgh_q;
wire                ex2_stq4_addr_coll;
wire [0:7]          ex2_stq4_way_coll;
wire                stq6_rd_byp_val;
wire                stq7_rd_byp_val;
wire                stq6_wr_byp_val;
wire                stq7_wr_byp_val;
wire                stq5_byp_val;
wire [0:143]        stq5_wr_bit;
wire [0:143]        stq5_msk_bit;
wire [0:15]         stq5_byte_en;
wire [0:15]         stq6_byte_en_wabcd_d;
wire [0:15]         stq6_byte_en_wabcd_q;
wire [0:143]        stq6_wr_bit_wabcd;
wire [0:143]        stq6_msk_bit_wabcd;
wire [0:15]         stq6_byte_en_wefgh_d;
wire [0:15]         stq6_byte_en_wefgh_q;
wire [0:143]        stq6_wr_bit_wefgh;
wire [0:143]        stq6_msk_bit_wefgh;
wire [0:143]        stq6_stq7_byp_data_wabcd;
wire [0:143]        stq5_byp_wr_data_wabcd;
wire [0:143]        stq6_byp_wr_data_wabcd_d;
wire [0:143]        stq6_byp_wr_data_wabcd_q;
wire [0:143]        stq6_stq7_byp_data_wefgh;
wire [0:143]        stq5_byp_wr_data_wefgh;
wire [0:143]        stq6_byp_wr_data_wefgh_d;
wire [0:143]        stq6_byp_wr_data_wefgh_q;
wire [0:3]          stq7_byp_val_wabcd_d;
wire [0:3]          stq7_byp_val_wabcd_q;
wire [0:3]          stq7_byp_val_wefgh_d;
wire [0:3]          stq7_byp_val_wefgh_q;
wire [0:3]          stq_byp_val_wabcd_d;
wire [0:3]          stq_byp_val_wabcd_q;
wire [0:3]          stq_byp_val_wefgh_d;
wire [0:3]          stq_byp_val_wefgh_q;

parameter           stq6_stg_act_offset = 0;
parameter           stq7_stg_act_offset = stq6_stg_act_offset + 1;
parameter           ex3_stq5_rd_addr_offset = stq7_stg_act_offset + 1;
parameter           stq6_wren_offset = ex3_stq5_rd_addr_offset + 8;
parameter           stq7_wren_offset = stq6_wren_offset + 1;
parameter           stq6_way_en_offset = stq7_wren_offset + 1;
parameter           stq7_way_en_offset = stq6_way_en_offset + 8;
parameter           stq6_addr_offset = stq7_way_en_offset + 8;
parameter           stq7_addr_offset = stq6_addr_offset + 8;
parameter           stq7_wr_data_wabcd_offset = stq7_addr_offset + 8;
parameter           stq7_wr_data_wefgh_offset = stq7_wr_data_wabcd_offset + 144;
parameter           stq8_wr_data_wabcd_offset = stq7_wr_data_wefgh_offset + 144;
parameter           stq8_wr_data_wefgh_offset = stq8_wr_data_wabcd_offset + 144;
parameter           stq6_byte_en_wabcd_offset = stq8_wr_data_wefgh_offset + 144;
parameter           stq6_byte_en_wefgh_offset = stq6_byte_en_wabcd_offset + 16;
parameter           stq6_byp_wr_data_wabcd_offset = stq6_byte_en_wefgh_offset + 16;
parameter           stq6_byp_wr_data_wefgh_offset = stq6_byp_wr_data_wabcd_offset + 144;
parameter           stq7_byp_val_wabcd_offset = stq6_byp_wr_data_wefgh_offset + 144;
parameter           stq7_byp_val_wefgh_offset = stq7_byp_val_wabcd_offset + 4;
parameter           stq_byp_val_wabcd_offset = stq7_byp_val_wefgh_offset + 4;
parameter           stq_byp_val_wefgh_offset = stq_byp_val_wabcd_offset + 4;
parameter           scan_right = stq_byp_val_wefgh_offset + 4 - 1;

wire                tiup;
wire [0:scan_right] siv;
wire [0:scan_right] sov;

assign tiup = 1'b1;
assign ex3_stq5_rd_addr_d = ex2_stq4_rd_addr;
assign stq6_stg_act_d     = stq5_stg_act;
assign stq7_stg_act_d     = stq6_stg_act_q;
assign stq6_wren_d        = stq5_arr_wren;
assign stq7_wren_d        = stq6_wren_q;
assign stq6_way_en_d      = stq5_arr_wr_way;
assign stq7_way_en_d      = stq6_way_en_q;
assign stq6_wr_way        = {8{stq6_wren_q}} & stq6_way_en_q;
assign stq6_addr_d        = stq5_arr_wr_addr;
assign stq7_addr_d        = stq6_addr_q;

// #############################################################################################
// Data Cache Read/Write Merge
// #############################################################################################
// Gate Way that is being updated
assign stq6_gate_rd_data_wa = {144{stq6_way_en_q[0]}} & stq6_rd_data_wa;
assign stq6_gate_rd_data_wb = {144{stq6_way_en_q[1]}} & stq6_rd_data_wb;
assign stq6_gate_rd_data_wc = {144{stq6_way_en_q[2]}} & stq6_rd_data_wc;
assign stq6_gate_rd_data_wd = {144{stq6_way_en_q[3]}} & stq6_rd_data_wd;
assign stq6_gate_rd_data_we = {144{stq6_way_en_q[4]}} & stq6_rd_data_we;
assign stq6_gate_rd_data_wf = {144{stq6_way_en_q[5]}} & stq6_rd_data_wf;
assign stq6_gate_rd_data_wg = {144{stq6_way_en_q[6]}} & stq6_rd_data_wg;
assign stq6_gate_rd_data_wh = {144{stq6_way_en_q[7]}} & stq6_rd_data_wh;

// Merge Data Way A,B,C,D
assign stq6_rd_data_wabcd   = stq6_gate_rd_data_wa | stq6_gate_rd_data_wb |
                              stq6_gate_rd_data_wc | stq6_gate_rd_data_wd;
assign stq6_wr_data_wabcd   = (stq6_wr_bit_wabcd & stq6_byp_wr_data_wabcd_q) | (stq6_msk_bit_wabcd & stq6_rd_data_wabcd);
assign stq7_wr_data_wabcd_d = stq6_wr_data_wabcd;
assign stq8_wr_data_wabcd_d = stq7_wr_data_wabcd_q;

// Merge Data Way E,F,G,H
assign stq6_rd_data_wefgh   = stq6_gate_rd_data_we | stq6_gate_rd_data_wf |
                              stq6_gate_rd_data_wg | stq6_gate_rd_data_wh;
assign stq6_wr_data_wefgh   = (stq6_wr_bit_wefgh & stq6_byp_wr_data_wefgh_q) | (stq6_msk_bit_wefgh & stq6_rd_data_wefgh);
assign stq7_wr_data_wefgh_d = stq6_wr_data_wefgh;
assign stq8_wr_data_wefgh_d = stq7_wr_data_wefgh_q;

// #############################################################################################
// Data Cache Write Data Bypass
// #############################################################################################
// Read/Write Address Match
assign ex2_stq4_addr_coll = (ex2_stq4_rd_addr == stq6_addr_q);
assign ex2_stq4_way_coll  = {8{ex2_stq4_addr_coll}} & stq6_wr_way;

// Bypass Select Control
assign stq6_rd_byp_val = (ex3_stq5_rd_addr_q == stq6_addr_q) & stq6_wren_q;
assign stq7_rd_byp_val = (ex3_stq5_rd_addr_q == stq7_addr_q) & stq7_wren_q;
assign stq6_wr_byp_val = stq6_rd_byp_val & |(stq5_arr_wr_way & stq6_way_en_q);
assign stq7_wr_byp_val = stq7_rd_byp_val & |(stq5_arr_wr_way & stq7_way_en_q);
assign stq5_byp_val    = stq6_wr_byp_val | stq7_wr_byp_val;

// Byte Enable and Byte Mask generation
assign stq5_wr_bit          = {9{ stq5_arr_wr_bytew}};
assign stq5_msk_bit         = {9{~stq5_arr_wr_bytew}};
assign stq5_byte_en         = stq5_arr_wr_bytew | {16{stq5_byp_val}};
assign stq6_byte_en_wabcd_d = stq5_byte_en;
assign stq6_wr_bit_wabcd    = {9{ stq6_byte_en_wabcd_q}};
assign stq6_msk_bit_wabcd   = {9{~stq6_byte_en_wabcd_q}};
assign stq6_byte_en_wefgh_d = stq5_byte_en;
assign stq6_wr_bit_wefgh    = {9{ stq6_byte_en_wefgh_q}};
assign stq6_msk_bit_wefgh   = {9{~stq6_byte_en_wefgh_q}};

// Need to add bypass logic with merged data from stq6 and stq7 for Way A,B,C,D groups
assign stq6_stq7_byp_data_wabcd = ({144{~stq6_wr_byp_val}} & stq7_wr_data_wabcd_q) | ({144{stq6_wr_byp_val}} & stq6_wr_data_wabcd);
assign stq5_byp_wr_data_wabcd   = (stq5_wr_bit & stq5_arr_wr_data) | (stq5_msk_bit & stq6_stq7_byp_data_wabcd);
assign stq6_byp_wr_data_wabcd_d = stq5_byp_wr_data_wabcd;

// Need to add bypass logic with merged data from stq6 and stq7 for Way E,F,G,H groups
assign stq6_stq7_byp_data_wefgh = ({144{~stq6_wr_byp_val}} & stq7_wr_data_wefgh_q) | ({144{stq6_wr_byp_val}} & stq6_wr_data_wefgh);
assign stq5_byp_wr_data_wefgh   = (stq5_wr_bit & stq5_arr_wr_data) | (stq5_msk_bit & stq6_stq7_byp_data_wefgh);
assign stq6_byp_wr_data_wefgh_d = stq5_byp_wr_data_wefgh;

// Data that needs to be bypassed between EX2 Load Pipe Read collision detected with STQ6 Store Pipe Write
assign stq7_byp_val_wabcd_d = {4{stq6_rd_byp_val}} & stq6_way_en_q[0:3];
assign stq7_byp_val_wefgh_d = {4{stq6_rd_byp_val}} & stq6_way_en_q[4:7];
//assign stq7_byp_data_wefgh = stq7_wr_data_wefgh_q;
assign stq_byp_val_wabcd_d  = ({4{stq7_rd_byp_val}} & stq7_way_en_q[0:3]) | ({4{stq6_rd_byp_val}} & stq6_way_en_q[0:3]);
assign stq_byp_val_wefgh_d  = ({4{stq7_rd_byp_val}} & stq7_way_en_q[4:7]) | ({4{stq6_rd_byp_val}} & stq6_way_en_q[4:7]);

// #############################################################################################
// Outputs
// #############################################################################################
// Data Cache Array Read ACT
assign dcarr_rd_stg_act    = {8{ex2_stq4_rd_stg_act}} & ~ex2_stq4_way_coll;

// Data Cache Array Update
assign dcarr_wr_stg_act    = stq6_wr_way;
assign dcarr_wr_way        = stq6_wr_way;
assign dcarr_wr_addr       = stq6_addr_q;
assign dcarr_wr_data_wabcd = stq6_wr_data_wabcd;
assign dcarr_wr_data_wefgh = stq6_wr_data_wefgh;

// EX4 Load Data Bypass
assign stq7_byp_val_wabcd  = stq7_byp_val_wabcd_q;
assign stq7_byp_val_wefgh  = stq7_byp_val_wefgh_q;
assign stq7_byp_data_wabcd = stq7_wr_data_wabcd_q;
assign stq7_byp_data_wefgh = stq7_wr_data_wefgh_q;
assign stq8_byp_data_wabcd = stq8_wr_data_wabcd_q;
assign stq8_byp_data_wefgh = stq8_wr_data_wefgh_q;
assign stq_byp_val_wabcd   = stq_byp_val_wabcd_q;
assign stq_byp_val_wefgh   = stq_byp_val_wefgh_q;

// #############################################################################################
// Registers
// #############################################################################################
tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq6_stg_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_stg_act_offset]),
   .scout(sov[stq6_stg_act_offset]),
   .din(stq6_stg_act_d),
   .dout(stq6_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq7_stg_act_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq7_stg_act_offset]),
   .scout(sov[stq7_stg_act_offset]),
   .din(stq7_stg_act_d),
   .dout(stq7_stg_act_q)
);

tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ex3_stq5_rd_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_stq5_rd_addr_offset:ex3_stq5_rd_addr_offset + 8 - 1]),
   .scout(sov[ex3_stq5_rd_addr_offset:ex3_stq5_rd_addr_offset + 8 - 1]),
   .din(ex3_stq5_rd_addr_d),
   .dout(ex3_stq5_rd_addr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq6_arr_wren_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_wren_offset]),
   .scout(sov[stq6_wren_offset]),
   .din(stq6_wren_d),
   .dout(stq6_wren_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq7_arr_wren_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq7_wren_offset]),
   .scout(sov[stq7_wren_offset]),
   .din(stq7_wren_d),
   .dout(stq7_wren_q)
);

tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) stq6_way_en_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq5_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_way_en_offset:stq6_way_en_offset + 8 - 1]),
   .scout(sov[stq6_way_en_offset:stq6_way_en_offset + 8 - 1]),
   .din(stq6_way_en_d),
   .dout(stq6_way_en_q)
);

tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) stq7_way_en_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq6_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq7_way_en_offset:stq7_way_en_offset + 8 - 1]),
   .scout(sov[stq7_way_en_offset:stq7_way_en_offset + 8 - 1]),
   .din(stq7_way_en_d),
   .dout(stq7_way_en_q)
);

tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) stq6_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq5_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_addr_offset:stq6_addr_offset + 8 - 1]),
   .scout(sov[stq6_addr_offset:stq6_addr_offset + 8 - 1]),
   .din(stq6_addr_d),
   .dout(stq6_addr_q)
);

tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) stq7_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq6_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq7_addr_offset:stq7_addr_offset + 8 - 1]),
   .scout(sov[stq7_addr_offset:stq7_addr_offset + 8 - 1]),
   .din(stq7_addr_d),
   .dout(stq7_addr_q)
);

tri_rlmreg_p #(.WIDTH(144), .INIT(0), .NEEDS_SRESET(1)) stq7_wr_data_wabcd_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq6_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq7_wr_data_wabcd_offset:stq7_wr_data_wabcd_offset + 144 - 1]),
   .scout(sov[stq7_wr_data_wabcd_offset:stq7_wr_data_wabcd_offset + 144 - 1]),
   .din(stq7_wr_data_wabcd_d),
   .dout(stq7_wr_data_wabcd_q)
);

tri_rlmreg_p #(.WIDTH(144), .INIT(0), .NEEDS_SRESET(1)) stq7_wr_data_wefgh_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq6_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq7_wr_data_wefgh_offset:stq7_wr_data_wefgh_offset + 144 - 1]),
   .scout(sov[stq7_wr_data_wefgh_offset:stq7_wr_data_wefgh_offset + 144 - 1]),
   .din(stq7_wr_data_wefgh_d),
   .dout(stq7_wr_data_wefgh_q)
);

tri_rlmreg_p #(.WIDTH(144), .INIT(0), .NEEDS_SRESET(1)) stq8_wr_data_wabcd_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq7_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq8_wr_data_wabcd_offset:stq8_wr_data_wabcd_offset + 144 - 1]),
   .scout(sov[stq8_wr_data_wabcd_offset:stq8_wr_data_wabcd_offset + 144 - 1]),
   .din(stq8_wr_data_wabcd_d),
   .dout(stq8_wr_data_wabcd_q)
);

tri_rlmreg_p #(.WIDTH(144), .INIT(0), .NEEDS_SRESET(1)) stq8_wr_data_wefgh_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq7_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq8_wr_data_wefgh_offset:stq8_wr_data_wefgh_offset + 144 - 1]),
   .scout(sov[stq8_wr_data_wefgh_offset:stq8_wr_data_wefgh_offset + 144 - 1]),
   .din(stq8_wr_data_wefgh_d),
   .dout(stq8_wr_data_wefgh_q)
);

tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) stq6_byte_en_wabcd_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq5_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_byte_en_wabcd_offset:stq6_byte_en_wabcd_offset + 16 - 1]),
   .scout(sov[stq6_byte_en_wabcd_offset:stq6_byte_en_wabcd_offset + 16 - 1]),
   .din(stq6_byte_en_wabcd_d),
   .dout(stq6_byte_en_wabcd_q)
);

tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) stq6_byte_en_wefgh_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq5_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_byte_en_wefgh_offset:stq6_byte_en_wefgh_offset + 16 - 1]),
   .scout(sov[stq6_byte_en_wefgh_offset:stq6_byte_en_wefgh_offset + 16 - 1]),
   .din(stq6_byte_en_wefgh_d),
   .dout(stq6_byte_en_wefgh_q)
);

tri_rlmreg_p #(.WIDTH(144), .INIT(0), .NEEDS_SRESET(1)) stq6_byp_wr_data_wabcd_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq5_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_byp_wr_data_wabcd_offset:stq6_byp_wr_data_wabcd_offset + 144 - 1]),
   .scout(sov[stq6_byp_wr_data_wabcd_offset:stq6_byp_wr_data_wabcd_offset + 144 - 1]),
   .din(stq6_byp_wr_data_wabcd_d),
   .dout(stq6_byp_wr_data_wabcd_q)
);

tri_rlmreg_p #(.WIDTH(144), .INIT(0), .NEEDS_SRESET(1)) stq6_byp_wr_data_wefgh_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq5_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_byp_wr_data_wefgh_offset:stq6_byp_wr_data_wefgh_offset + 144 - 1]),
   .scout(sov[stq6_byp_wr_data_wefgh_offset:stq6_byp_wr_data_wefgh_offset + 144 - 1]),
   .din(stq6_byp_wr_data_wefgh_d),
   .dout(stq6_byp_wr_data_wefgh_q)
);

tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) stq7_byp_val_wabcd_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq7_byp_val_wabcd_offset:stq7_byp_val_wabcd_offset + 4 - 1]),
   .scout(sov[stq7_byp_val_wabcd_offset:stq7_byp_val_wabcd_offset + 4 - 1]),
   .din(stq7_byp_val_wabcd_d),
   .dout(stq7_byp_val_wabcd_q)
);

tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) stq7_byp_val_wefgh_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq7_byp_val_wefgh_offset:stq7_byp_val_wefgh_offset + 4 - 1]),
   .scout(sov[stq7_byp_val_wefgh_offset:stq7_byp_val_wefgh_offset + 4 - 1]),
   .din(stq7_byp_val_wefgh_d),
   .dout(stq7_byp_val_wefgh_q)
);

tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) stq_byp_val_wabcd_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq_byp_val_wabcd_offset:stq_byp_val_wabcd_offset + 4 - 1]),
   .scout(sov[stq_byp_val_wabcd_offset:stq_byp_val_wabcd_offset + 4 - 1]),
   .din(stq_byp_val_wabcd_d),
   .dout(stq_byp_val_wabcd_q)
);

tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) stq_byp_val_wefgh_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq_byp_val_wefgh_offset:stq_byp_val_wefgh_offset + 4 - 1]),
   .scout(sov[stq_byp_val_wefgh_offset:stq_byp_val_wefgh_offset + 4 - 1]),
   .din(stq_byp_val_wefgh_d),
   .dout(stq_byp_val_wefgh_q)
);

assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
assign scan_out = sov[0];

endmodule
