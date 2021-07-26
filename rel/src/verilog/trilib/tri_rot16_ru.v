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

//
//  Description:  XU LSU Load Data Rotator
//*****************************************************************************

// ##########################################################################################
// Contents
// 1) 16 bit Unaligned Rotate to the Right Rotator
// 2) Little/Big Endian Support
// ##########################################################################################

`include "tri_a2o.vh"

module tri_rot16_ru(
   opsize,
   le,
   le_rotate_sel,
   be_rotate_sel,
   arr_data,
   stq7_byp_val,
   stq_byp_val,
   stq7_rmw_data,
   stq8_rmw_data,
   data_latched,
   data_rot,
   nclk,
   vdd,
   gnd,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   func_sl_force,
   func_sl_thold_0_b,
   sg_0,
   act,
   scan_in,
   scan_out
);

input [0:4]         opsize;		    // (0)16B (1)8B (2)4B (3)2B (4)1B
input               le;
input [0:3]         le_rotate_sel;
input [0:3]         be_rotate_sel;

input [0:15]        arr_data;	    // data to rotate
input               stq7_byp_val;
input               stq_byp_val;
input [0:15]        stq7_rmw_data;
input [0:15]        stq8_rmw_data;
output [0:15]       data_latched;	// latched data, not rotated

output [0:15]       data_rot;	    // rotated data out

(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)
input  [0:`NCLK_WIDTH-1] nclk;

inout               vdd;
inout               gnd;
input               delay_lclkr_dc;
input               mpw1_dc_b;
input               mpw2_dc_b;
input               func_sl_force;
input               func_sl_thold_0_b;
input               sg_0;
input               act;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input               scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output              scan_out;

// tri_rot16_ru

wire                my_d1clk;
wire                my_d2clk;
wire [0:`NCLK_WIDTH-1]  my_lclk;


wire [0:15]         data_latched_b;

//signal bele_gp0_q_b, bele_gp0_q, bele_gp0_din      :std_ulogic_vector(0 to 1);
wire [0:0]          bele_gp0_q_b;

wire [0:0]          bele_gp0_q;
wire [0:0]          bele_gp0_din;

wire [0:3]          be_shx04_gp0_q_b;

wire [0:3]          be_shx04_gp0_q;
wire [0:3]          be_shx04_gp0_din;

wire [0:3]          le_shx04_gp0_q_b;

wire [0:3]          le_shx04_gp0_q;
wire [0:3]          le_shx04_gp0_din;

wire [0:3]          be_shx01_gp0_q_b;

wire [0:3]          be_shx01_gp0_q;
wire [0:3]          be_shx01_gp0_din;

wire [0:3]          le_shx01_gp0_q_b;

wire [0:3]          le_shx01_gp0_q;
wire [0:3]          le_shx01_gp0_din;
wire [0:4]          mask_q_b;
wire [0:4]          mask_q;
wire [0:4]          mask_din;

wire [0:15]         mxbele_b;

wire [0:15]         mxbele;

wire [0:15]         mx1_0_b;

wire [0:15]         mx1_1_b;

wire [0:15]         mx1;

wire [0:15]         mx2_0_b;

wire [0:15]         mx2_1_b;

wire [0:15]         mx2;

wire [0:15]         do_b;
wire [0:15]         mxbele_d0;
wire [0:15]         mxbele_d1;
wire [0:15]         bele_s0;
wire [0:15]         bele_s1;
wire [0:3]          shx04_gp0_sel_b;
wire [0:3]          shx04_gp0_sel;
wire [0:3]          shx01_gp0_sel_b;
wire [0:3]          shx01_gp0_sel;
wire [0:15]         mx1_d0;
wire [0:15]         mx1_d1;
wire [0:15]         mx1_d2;
wire [0:15]         mx1_d3;
wire [0:15]         mx2_d0;
wire [0:15]         mx2_d1;
wire [0:15]         mx2_d2;
wire [0:15]         mx2_d3;
wire [0:15]         mx1_s0;
wire [0:15]         mx1_s1;
wire [0:15]         mx1_s2;
wire [0:15]         mx1_s3;
wire [0:15]         mx2_s0;
wire [0:15]         mx2_s1;
wire [0:15]         mx2_s2;
wire [0:15]         mx2_s3;
wire [0:15]         mask_en;
wire [0:3]          be_shx04_sel;
wire [0:3]          be_shx01_sel;
wire [0:3]          le_shx04_sel;
wire [0:3]          le_shx01_sel;
wire [0:15]         stq_byp_data;
wire [0:15]         rotate_data;

//--------------------------
// constants
//--------------------------

parameter           bele_gp0_din_offset = 0;
parameter           be_shx04_gp0_din_offset = bele_gp0_din_offset + 1;
parameter           le_shx04_gp0_din_offset = be_shx04_gp0_din_offset + 4;
parameter           be_shx01_gp0_din_offset = le_shx04_gp0_din_offset + 4;
parameter           le_shx01_gp0_din_offset = be_shx01_gp0_din_offset + 4;
parameter           mask_din_offset = le_shx01_gp0_din_offset + 4;
parameter           scan_right = mask_din_offset + 5 - 1;

wire [0:scan_right] siv;
wire [0:scan_right] sov;


// #############################################################################################
// Little Endian Rotate Support
//         Optype2                      Optype4                       Optype8
//                                                              B31 => rot_data(248:255)
//                                                              B30 => rot_data(240:247)
//                                                              B29 => rot_data(232:239)
//                                                              B28 => rot_data(224:231)
//                              B31    => rot_data(248:255)     B27 => rot_data(216:223)
//                              B30    => rot_data(240:247)     B26 => rot_data(208:215)
// B15    => rot_data(248:255)  B29    => rot_data(232:239)     B25 => rot_data(200:207)
// B14    => rot_data(240:247)  B28    => rot_data(224:231)     B24 => rot_data(192:199)
//
//                        Optype16
// B31 => rot_data(248:255)     B23 => rot_data(184:191)
// B30 => rot_data(240:247)     B22 => rot_data(176:183)
// B29 => rot_data(232:239)     B21 => rot_data(168:175)
// B28 => rot_data(224:231)     B20 => rot_data(160:167)
// B27 => rot_data(216:223)     B19 => rot_data(152:159)
// B26 => rot_data(208:215)     B18 => rot_data(144:151)
// B25 => rot_data(200:207)     B17 => rot_data(136:143)
// B24 => rot_data(192:199)     B16 => rot_data(128:135)
//
// #############################################################################################

//-- 0,1,2,3 byte rotation
//with rot_sel(2 to 3) select
//    rot3210 <= rot_data(104 to 127) & rot_data(0 to 103) when "11",
//               rot_data(112 to 127) & rot_data(0 to 111) when "10",
//               rot_data(120 to 127) & rot_data(0 to 119) when "01",
//                                      rot_data(0 to 127) when others;
//
//-- 0-3,4,8,12 byte rotation
//with rot_sel(0 to 1) select
//    rotC840 <= rot3210(32 to 127) & rot3210(0 to 31) when "11",
//               rot3210(64 to 127) & rot3210(0 to 63) when "10",
//               rot3210(96 to 127) & rot3210(0 to 95) when "01",
//                                   rot3210(0 to 127) when others;

// ######################################################################
// ## BEFORE ROTATE CYCLE
// ######################################################################

// Rotate Control
// ----------------------------------

assign be_shx04_sel[0] = (~be_rotate_sel[0]) & (~be_rotate_sel[1]);
assign be_shx04_sel[1] = (~be_rotate_sel[0]) &   be_rotate_sel[1];
assign be_shx04_sel[2] =   be_rotate_sel[0]  & (~be_rotate_sel[1]);
assign be_shx04_sel[3] =   be_rotate_sel[0]  &   be_rotate_sel[1];

assign be_shx01_sel[0] = (~be_rotate_sel[2]) & (~be_rotate_sel[3]);
assign be_shx01_sel[1] = (~be_rotate_sel[2]) &   be_rotate_sel[3];
assign be_shx01_sel[2] =   be_rotate_sel[2]  & (~be_rotate_sel[3]);
assign be_shx01_sel[3] =   be_rotate_sel[2]  &   be_rotate_sel[3];

assign le_shx04_sel[0] = (~le_rotate_sel[0]) & (~le_rotate_sel[1]);
assign le_shx04_sel[1] = (~le_rotate_sel[0]) &   le_rotate_sel[1];
assign le_shx04_sel[2] =   le_rotate_sel[0]  & (~le_rotate_sel[1]);
assign le_shx04_sel[3] =   le_rotate_sel[0]  &   le_rotate_sel[1];

assign le_shx01_sel[0] = (~le_rotate_sel[2]) & (~le_rotate_sel[3]);
assign le_shx01_sel[1] = (~le_rotate_sel[2]) &   le_rotate_sel[3];
assign le_shx01_sel[2] =   le_rotate_sel[2]  & (~le_rotate_sel[3]);
assign le_shx01_sel[3] =   le_rotate_sel[2]  &   le_rotate_sel[3];

// Opsize Mask Generation
// ----------------------------------
assign mask_din[0] = opsize[0];		// for 16:23
assign mask_din[1] = opsize[0] | opsize[1];		// for 24:27
assign mask_din[2] = opsize[0] | opsize[1] | opsize[2];		// for 28:29
assign mask_din[3] = opsize[0] | opsize[1] | opsize[2] | opsize[3];		// for 30
assign mask_din[4] = opsize[0] | opsize[1] | opsize[2] | opsize[3] | opsize[4];	// for 31

// Latch Inputs
// ----------------------------------
assign bele_gp0_din[0] = le;
assign be_shx04_gp0_din[0:3] = be_shx04_sel[0:3];
assign le_shx04_gp0_din[0:3] = le_shx04_sel[0:3];
assign be_shx01_gp0_din[0:3] = be_shx01_sel[0:3];
assign le_shx01_gp0_din[0:3] = le_shx01_sel[0:3];

// ######################################################################
// ## BIG-ENDIAN ROTATE CYCLE
// ######################################################################

// -------------------------------------------------------------------
// local latch inputs
// -------------------------------------------------------------------

tri_inv bele_gp0_q_0 (.y(bele_gp0_q), .a(bele_gp0_q_b));

tri_inv #(.WIDTH(4)) be_shx04_gp0_q_0 (.y(be_shx04_gp0_q[0:3]), .a(be_shx04_gp0_q_b[0:3]));

tri_inv #(.WIDTH(4)) le_shx04_gp0_q_0 (.y(le_shx04_gp0_q[0:3]), .a(le_shx04_gp0_q_b[0:3]));

tri_inv #(.WIDTH(4)) be_shx01_gp0_q_0 (.y(be_shx01_gp0_q[0:3]), .a(be_shx01_gp0_q_b[0:3]));

tri_inv #(.WIDTH(4)) le_shx01_gp0_q_0 (.y(le_shx01_gp0_q[0:3]), .a(le_shx01_gp0_q_b[0:3]));

assign mask_q[0:4] = (~mask_q_b[0:4]);

// ----------------------------------------------------------------------------------------
// Read-Modify-Write Bypass Data Muxing
// ----------------------------------------------------------------------------------------
assign stq_byp_data = ({16{stq7_byp_val}} & stq7_rmw_data) | ({16{~stq7_byp_val}} & stq8_rmw_data);
assign rotate_data  = ({16{stq_byp_val}}  & stq_byp_data)  | ({16{~stq_byp_val}}  & arr_data);

// ----------------------------------------------------------------------------------------
// Little/Big Endian Muxing
// ----------------------------------------------------------------------------------------
assign bele_s0[0:15] = {16{~bele_gp0_q[0]}};
assign bele_s1[0:15] = {16{ bele_gp0_q[0]}};

tri_aoi22 #(.WIDTH(4)) shx04_gp0_sel_b_0 (.y(shx04_gp0_sel_b[0:3]), .a0(be_shx04_gp0_q[0:3]), .a1(bele_s0[0:3]), .b0(le_shx04_gp0_q[0:3]), .b1(bele_s1[0:3]));
tri_aoi22 #(.WIDTH(4)) shx01_gp0_sel_b_0 (.y(shx01_gp0_sel_b[0:3]), .a0(be_shx01_gp0_q[0:3]), .a1(bele_s0[4:7]), .b0(le_shx01_gp0_q[0:3]), .b1(bele_s1[4:7]));

assign shx04_gp0_sel = (~shx04_gp0_sel_b);
assign shx01_gp0_sel = (~shx01_gp0_sel_b);

assign mxbele_d0[0] = rotate_data[0];   assign mxbele_d1[0] = rotate_data[15];
assign mxbele_d0[1] = rotate_data[1];   assign mxbele_d1[1] = rotate_data[14];
assign mxbele_d0[2] = rotate_data[2];   assign mxbele_d1[2] = rotate_data[13];
assign mxbele_d0[3] = rotate_data[3];   assign mxbele_d1[3] = rotate_data[12];
assign mxbele_d0[4] = rotate_data[4];   assign mxbele_d1[4] = rotate_data[11];
assign mxbele_d0[5] = rotate_data[5];   assign mxbele_d1[5] = rotate_data[10];
assign mxbele_d0[6] = rotate_data[6];   assign mxbele_d1[6] = rotate_data[9];
assign mxbele_d0[7] = rotate_data[7];   assign mxbele_d1[7] = rotate_data[8];
assign mxbele_d0[8] = rotate_data[8];   assign mxbele_d1[8] = rotate_data[7];
assign mxbele_d0[9] = rotate_data[9];   assign mxbele_d1[9] = rotate_data[6];
assign mxbele_d0[10] = rotate_data[10]; assign mxbele_d1[10] = rotate_data[5];
assign mxbele_d0[11] = rotate_data[11]; assign mxbele_d1[11] = rotate_data[4];
assign mxbele_d0[12] = rotate_data[12]; assign mxbele_d1[12] = rotate_data[3];
assign mxbele_d0[13] = rotate_data[13]; assign mxbele_d1[13] = rotate_data[2];
assign mxbele_d0[14] = rotate_data[14]; assign mxbele_d1[14] = rotate_data[1];
assign mxbele_d0[15] = rotate_data[15]; assign mxbele_d1[15] = rotate_data[0];

tri_aoi22 #(.WIDTH(16)) mxbele_b_0 (.y(mxbele_b[0:15]), .a0(mxbele_d0[0:15]), .a1(bele_s0[0:15]), .b0(mxbele_d1[0:15]), .b1(bele_s1[0:15]));

tri_inv #(.WIDTH(16)) mxbele_0 (.y(mxbele[0:15]), .a(mxbele_b[0:15]));

// ----------------------------------------------------------------------------------------
// First level of muxing <0,4,8,12 bytes>
// ----------------------------------------------------------------------------------------

assign mx1_s0[0:15] = {16{shx04_gp0_sel[0]}};
assign mx1_s1[0:15] = {16{shx04_gp0_sel[1]}};
assign mx1_s2[0:15] = {16{shx04_gp0_sel[2]}};
assign mx1_s3[0:15] = {16{shx04_gp0_sel[3]}};

assign mx1_d0[0] = mxbele[0];   assign mx1_d1[0] = mxbele[12];  assign mx1_d2[0] = mxbele[8];   assign mx1_d3[0] = mxbele[4];
assign mx1_d0[1] = mxbele[1];   assign mx1_d1[1] = mxbele[13];  assign mx1_d2[1] = mxbele[9];   assign mx1_d3[1] = mxbele[5];
assign mx1_d0[2] = mxbele[2];   assign mx1_d1[2] = mxbele[14];  assign mx1_d2[2] = mxbele[10];  assign mx1_d3[2] = mxbele[6];
assign mx1_d0[3] = mxbele[3];   assign mx1_d1[3] = mxbele[15];  assign mx1_d2[3] = mxbele[11];  assign mx1_d3[3] = mxbele[7];
assign mx1_d0[4] = mxbele[4];   assign mx1_d1[4] = mxbele[0];   assign mx1_d2[4] = mxbele[12];  assign mx1_d3[4] = mxbele[8];
assign mx1_d0[5] = mxbele[5];   assign mx1_d1[5] = mxbele[1];   assign mx1_d2[5] = mxbele[13];  assign mx1_d3[5] = mxbele[9];
assign mx1_d0[6] = mxbele[6];   assign mx1_d1[6] = mxbele[2];   assign mx1_d2[6] = mxbele[14];  assign mx1_d3[6] = mxbele[10];
assign mx1_d0[7] = mxbele[7];   assign mx1_d1[7] = mxbele[3];   assign mx1_d2[7] = mxbele[15];  assign mx1_d3[7] = mxbele[11];
assign mx1_d0[8] = mxbele[8];   assign mx1_d1[8] = mxbele[4];   assign mx1_d2[8] = mxbele[0];   assign mx1_d3[8] = mxbele[12];
assign mx1_d0[9] = mxbele[9];   assign mx1_d1[9] = mxbele[5];   assign mx1_d2[9] = mxbele[1];   assign mx1_d3[9] = mxbele[13];
assign mx1_d0[10] = mxbele[10]; assign mx1_d1[10] = mxbele[6];  assign mx1_d2[10] = mxbele[2];  assign mx1_d3[10] = mxbele[14];
assign mx1_d0[11] = mxbele[11]; assign mx1_d1[11] = mxbele[7];  assign mx1_d2[11] = mxbele[3];  assign mx1_d3[11] = mxbele[15];
assign mx1_d0[12] = mxbele[12]; assign mx1_d1[12] = mxbele[8];  assign mx1_d2[12] = mxbele[4];  assign mx1_d3[12] = mxbele[0];
assign mx1_d0[13] = mxbele[13]; assign mx1_d1[13] = mxbele[9];  assign mx1_d2[13] = mxbele[5];  assign mx1_d3[13] = mxbele[1];
assign mx1_d0[14] = mxbele[14]; assign mx1_d1[14] = mxbele[10]; assign mx1_d2[14] = mxbele[6];  assign mx1_d3[14] = mxbele[2];
assign mx1_d0[15] = mxbele[15]; assign mx1_d1[15] = mxbele[11]; assign mx1_d2[15] = mxbele[7];  assign mx1_d3[15] = mxbele[3];

tri_aoi22 #(.WIDTH(16)) mx1_0_b_0 (.y(mx1_0_b[0:15]), .a0(mx1_s0[0:15]), .a1(mx1_d0[0:15]), .b0(mx1_s1[0:15]), .b1(mx1_d1[0:15]));

tri_aoi22 #(.WIDTH(16)) mx1_1_b_0 (.y(mx1_1_b[0:15]), .a0(mx1_s2[0:15]), .a1(mx1_d2[0:15]), .b0(mx1_s3[0:15]), .b1(mx1_d3[0:15]));

tri_nand2 #(.WIDTH(16)) mx1_0 (.y(mx1[0:15]), .a(mx1_0_b[0:15]), .b(mx1_1_b[0:15]));

// ----------------------------------------------------------------------------------------
// third level of muxing <0,1,2,3 bytes> , include mask on selects
// ----------------------------------------------------------------------------------------

assign mask_en[0:7]   = {8{mask_q[0]}};	// 128
assign mask_en[8:11]  = {4{mask_q[1]}};	// 128,64
assign mask_en[12:13] = {2{mask_q[2]}};	// 128,64,32
assign mask_en[14]    = mask_q[3];           // 128,64,32,16
assign mask_en[15]    = mask_q[4];           // 128,64,32,16,8 <not sure you really need this one>

assign mx2_s0[0:7]  = {8{shx01_gp0_sel[0]}} & mask_en[0:7];
assign mx2_s1[0:7]  = {8{shx01_gp0_sel[1]}} & mask_en[0:7];
assign mx2_s2[0:7]  = {8{shx01_gp0_sel[2]}} & mask_en[0:7];
assign mx2_s3[0:7]  = {8{shx01_gp0_sel[3]}} & mask_en[0:7];
assign mx2_s0[8:15] = {8{shx01_gp0_sel[0]}} & mask_en[8:15];
assign mx2_s1[8:15] = {8{shx01_gp0_sel[1]}} & mask_en[8:15];
assign mx2_s2[8:15] = {8{shx01_gp0_sel[2]}} & mask_en[8:15];
assign mx2_s3[8:15] = {8{shx01_gp0_sel[3]}} & mask_en[8:15];

assign mx2_d0[0] = mx1[0];   assign mx2_d1[0] = mx1[15];  assign mx2_d2[0] = mx1[14];  assign mx2_d3[0] = mx1[13];
assign mx2_d0[1] = mx1[1];   assign mx2_d1[1] = mx1[0];   assign mx2_d2[1] = mx1[15];  assign mx2_d3[1] = mx1[14];
assign mx2_d0[2] = mx1[2];   assign mx2_d1[2] = mx1[1];   assign mx2_d2[2] = mx1[0];   assign mx2_d3[2] = mx1[15];
assign mx2_d0[3] = mx1[3];   assign mx2_d1[3] = mx1[2];   assign mx2_d2[3] = mx1[1];   assign mx2_d3[3] = mx1[0];
assign mx2_d0[4] = mx1[4];   assign mx2_d1[4] = mx1[3];   assign mx2_d2[4] = mx1[2];   assign mx2_d3[4] = mx1[1];
assign mx2_d0[5] = mx1[5];   assign mx2_d1[5] = mx1[4];   assign mx2_d2[5] = mx1[3];   assign mx2_d3[5] = mx1[2];
assign mx2_d0[6] = mx1[6];   assign mx2_d1[6] = mx1[5];   assign mx2_d2[6] = mx1[4];   assign mx2_d3[6] = mx1[3];
assign mx2_d0[7] = mx1[7];   assign mx2_d1[7] = mx1[6];   assign mx2_d2[7] = mx1[5];   assign mx2_d3[7] = mx1[4];
assign mx2_d0[8] = mx1[8];   assign mx2_d1[8] = mx1[7];   assign mx2_d2[8] = mx1[6];   assign mx2_d3[8] = mx1[5];
assign mx2_d0[9] = mx1[9];   assign mx2_d1[9] = mx1[8];   assign mx2_d2[9] = mx1[7];   assign mx2_d3[9] = mx1[6];
assign mx2_d0[10] = mx1[10]; assign mx2_d1[10] = mx1[9];  assign mx2_d2[10] = mx1[8];  assign mx2_d3[10] = mx1[7];
assign mx2_d0[11] = mx1[11]; assign mx2_d1[11] = mx1[10]; assign mx2_d2[11] = mx1[9];  assign mx2_d3[11] = mx1[8];
assign mx2_d0[12] = mx1[12]; assign mx2_d1[12] = mx1[11]; assign mx2_d2[12] = mx1[10]; assign mx2_d3[12] = mx1[9];
assign mx2_d0[13] = mx1[13]; assign mx2_d1[13] = mx1[12]; assign mx2_d2[13] = mx1[11]; assign mx2_d3[13] = mx1[10];
assign mx2_d0[14] = mx1[14]; assign mx2_d1[14] = mx1[13]; assign mx2_d2[14] = mx1[12]; assign mx2_d3[14] = mx1[11];
assign mx2_d0[15] = mx1[15]; assign mx2_d1[15] = mx1[14]; assign mx2_d2[15] = mx1[13]; assign mx2_d3[15] = mx1[12];

tri_aoi22 #(.WIDTH(16)) mx2_0_b_0 (.y(mx2_0_b[0:15]), .a0(mx2_s0[0:15]), .a1(mx2_d0[0:15]), .b0(mx2_s1[0:15]), .b1(mx2_d1[0:15]));

tri_aoi22 #(.WIDTH(16)) mx2_1_b_0 (.y(mx2_1_b[0:15]), .a0(mx2_s2[0:15]), .a1(mx2_d2[0:15]), .b0(mx2_s3[0:15]), .b1(mx2_d3[0:15]));

tri_nand2 #(.WIDTH(16)) mx2_0 (.y(mx2[0:15]), .a(mx2_0_b[0:15]), .b(mx2_1_b[0:15]));

tri_inv #(.WIDTH(16)) do_b_0 (.y(do_b[0:15]), .a(mx2[0:15]));

tri_inv #(.WIDTH(16)) data_rot_0 (.y(data_rot[0:15]), .a(do_b[0:15]));

tri_inv #(.WIDTH(16)) data_latched_b_0 (.y(data_latched_b), .a(arr_data));

tri_inv #(.WIDTH(16)) data_latched_0 (.y(data_latched), .a(data_latched_b));

// top   funny physical placement to minimize wrap wires ... also nice for LE adjust
//---------
//  0  31
//  1  30
//  2  29
//  3  28
//  4  27
//  5  26
//  6  25
//  7  24
//---------
//  8  23
//  9  22
// 10  21
// 11  20
// 12  19
// 13  18
// 14  17
// 15  16
//---------
// bot

// ###############################################################
// ## LCBs
// ###############################################################
tri_lcbnd  my_lcb(
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .force_t(func_sl_force),
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(act),
   .sg(sg_0),
   .thold_b(func_sl_thold_0_b),
   .d1clk(my_d1clk),
   .d2clk(my_d2clk),
   .lclk(my_lclk)
);

// ###############################################################
// ## Latches
// ###############################################################
tri_inv_nlats #(.WIDTH(1), .INIT(1'b0), .BTR("NLI0001_X2_A12TH"), .NEEDS_SRESET(0)) bele_gp0_lat(
   .vd(vdd),
   .gd(gnd),
   .lclk(my_lclk),
   .d1clk(my_d1clk),
   .d2clk(my_d2clk),
   .scanin(siv[bele_gp0_din_offset:bele_gp0_din_offset + 1 - 1]),
   .scanout(sov[bele_gp0_din_offset:bele_gp0_din_offset + 1 - 1]),
   .d(bele_gp0_din),
   .qb(bele_gp0_q_b)
);

tri_inv_nlats #(.WIDTH(4), .INIT(4'h0), .BTR("NLI0001_X2_A12TH"), .NEEDS_SRESET(0)) be_shx04_gp0_lat(
   .vd(vdd),
   .gd(gnd),
   .lclk(my_lclk),
   .d1clk(my_d1clk),
   .d2clk(my_d2clk),
   .scanin(siv[be_shx04_gp0_din_offset:be_shx04_gp0_din_offset + 4 - 1]),
   .scanout(sov[be_shx04_gp0_din_offset:be_shx04_gp0_din_offset + 4 - 1]),
   .d(be_shx04_gp0_din),
   .qb(be_shx04_gp0_q_b[0:3])
);

tri_inv_nlats #(.WIDTH(4), .INIT(4'h0), .BTR("NLI0001_X2_A12TH"), .NEEDS_SRESET(0)) le_shx04_gp0_lat(
   .vd(vdd),
   .gd(gnd),
   .lclk(my_lclk),
   .d1clk(my_d1clk),
   .d2clk(my_d2clk),
   .scanin(siv[le_shx04_gp0_din_offset:le_shx04_gp0_din_offset + 4 - 1]),
   .scanout(sov[le_shx04_gp0_din_offset:le_shx04_gp0_din_offset + 4 - 1]),
   .d(le_shx04_gp0_din),
   .qb(le_shx04_gp0_q_b[0:3])
);

tri_inv_nlats #(.WIDTH(4), .INIT(4'h0), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) be_shx01_gp0_lat(
   .vd(vdd),
   .gd(gnd),
   .lclk(my_lclk),
   .d1clk(my_d1clk),
   .d2clk(my_d2clk),
   .scanin(siv[be_shx01_gp0_din_offset:be_shx01_gp0_din_offset + 4 - 1]),
   .scanout(sov[be_shx01_gp0_din_offset:be_shx01_gp0_din_offset + 4 - 1]),
   .d(be_shx01_gp0_din),
   .qb(be_shx01_gp0_q_b[0:3])
);

tri_inv_nlats #(.WIDTH(4), .INIT(4'h0), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) le_shx01_gp0_lat(
   .vd(vdd),
   .gd(gnd),
   .lclk(my_lclk),
   .d1clk(my_d1clk),
   .d2clk(my_d2clk),
   .scanin(siv[le_shx01_gp0_din_offset:le_shx01_gp0_din_offset + 4 - 1]),
   .scanout(sov[le_shx01_gp0_din_offset:le_shx01_gp0_din_offset + 4 - 1]),
   .d(le_shx01_gp0_din),
   .qb(le_shx01_gp0_q_b[0:3])
);

tri_inv_nlats #(.WIDTH(5), .INIT(5'b0), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) mask_lat(
   .vd(vdd),
   .gd(gnd),
   .lclk(my_lclk),
   .d1clk(my_d1clk),
   .d2clk(my_d2clk),
   .scanin(siv[mask_din_offset:mask_din_offset + 5 - 1]),
   .scanout(sov[mask_din_offset:mask_din_offset + 5 - 1]),
   .d(mask_din),
   .qb(mask_q_b[0:4])
);

assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
assign scan_out = sov[0];

endmodule
