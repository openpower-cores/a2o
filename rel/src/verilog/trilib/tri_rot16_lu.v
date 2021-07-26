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

//  Description:  Unaligned Data Rotate to the Left
//
//*****************************************************************************

// ##########################################################################################
// Contents
// 1) 16 bit Unaligned Rotate to the Left Rotator
// 2) Little/Big Endian Support
// ##########################################################################################

module tri_rot16_lu(
   rot_sel1,
   rot_sel2,
   rot_sel3,
   rot_data,
   data_rot,
   vdd,
   gnd
);

// Rotator Controls and Data
input [0:7]   rot_sel1;
input [0:7]   rot_sel2;
input [0:7]   rot_sel3;
input [0:15]  rot_data;

// Rotated Data
output [0:15] data_rot;

// Pervasive
inout         vdd;
inout         gnd;

// tri_rot16_lu

wire [0:15]   mxbele_d0;
wire [0:15]   mxbele_d1;
wire [0:15]   bele_s0;
wire [0:15]   bele_s1;
wire [0:15]   mxbele_b;
wire [0:15]   mxbele;
wire [0:15]   mx1_d0;
wire [0:15]   mx1_d1;
wire [0:15]   mx1_d2;
wire [0:15]   mx1_d3;
wire [0:15]   mx2_d0;
wire [0:15]   mx2_d1;
wire [0:15]   mx2_d2;
wire [0:15]   mx2_d3;
wire [0:15]   mx1_s0;
wire [0:15]   mx1_s1;
wire [0:15]   mx1_s2;
wire [0:15]   mx1_s3;
wire [0:15]   mx2_s0;
wire [0:15]   mx2_s1;
wire [0:15]   mx2_s2;
wire [0:15]   mx2_s3;

wire [0:15]   mx1_0_b;
wire [0:15]   mx1_1_b;
wire [0:15]   mx1;
wire [0:15]   mx2_0_b;
wire [0:15]   mx2_1_b;
wire [0:15]   mx2;

(* analysis_not_referenced="true" *)
wire          unused;

assign unused = vdd | gnd;

// #############################################################################################
// 16 Byte Rotator
// B0 => data(0:7)      B8  => data(64:71)
// B1 => data(8:15)     B9  => data(72:79)
// B2 => data(16:23)    B10 => data(80:87)
// B3 => data(24:31)    B11 => data(88:95)
// B4 => data(32:39)    B12 => data(96:103)
// B5 => data(40:47)    B13 => data(104:111)
// B6 => data(48:55)    B14 => data(112:119)
// B7 => data(56:63)    B15 => data(120:127)
// #############################################################################################

//-- 0,1,2,3 byte rotation
//with rot_sel(2 to 3) select
//    rot3210 <= rot_data(24 to 127) & rot_data(0 to 23) when "11",
//               rot_data(16 to 127) & rot_data(0 to 15) when "10",
//               rot_data(8 to 127)  & rot_data(0 to 7)  when "01",
//                                    rot_data(0 to 127) when others;
//
//-- 0-3,4,8,12 byte rotation
//with rot_sel(0 to 1) select
//    rotC840 <= rot3210(96 to 127) & rot3210(0 to 95) when "11",
//               rot3210(64 to 127) & rot3210(0 to 63) when "10",
//               rot3210(32 to 127) & rot3210(0 to 31) when "01",
//                                   rot3210(0 to 127) when others;

// ----------------------------------------------------------------------------------------
// Little/Big Endian Muxing
// ----------------------------------------------------------------------------------------

assign bele_s0[0:3]   = {4{rot_sel1[0]}};
assign bele_s0[4:7]   = {4{rot_sel1[2]}};
assign bele_s0[8:11]  = {4{rot_sel1[4]}};
assign bele_s0[12:15] = {4{rot_sel1[6]}};
assign bele_s1[0:3]   = {4{rot_sel1[1]}};
assign bele_s1[4:7]   = {4{rot_sel1[3]}};
assign bele_s1[8:11]  = {4{rot_sel1[5]}};
assign bele_s1[12:15] = {4{rot_sel1[7]}};

assign mxbele_d0[0] = rot_data[0];   assign mxbele_d1[0] = rot_data[15];
assign mxbele_d0[1] = rot_data[1];   assign mxbele_d1[1] = rot_data[14];
assign mxbele_d0[2] = rot_data[2];   assign mxbele_d1[2] = rot_data[13];
assign mxbele_d0[3] = rot_data[3];   assign mxbele_d1[3] = rot_data[12];
assign mxbele_d0[4] = rot_data[4];   assign mxbele_d1[4] = rot_data[11];
assign mxbele_d0[5] = rot_data[5];   assign mxbele_d1[5] = rot_data[10];
assign mxbele_d0[6] = rot_data[6];   assign mxbele_d1[6] = rot_data[9];
assign mxbele_d0[7] = rot_data[7];   assign mxbele_d1[7] = rot_data[8];
assign mxbele_d0[8] = rot_data[8];   assign mxbele_d1[8] = rot_data[7];
assign mxbele_d0[9] = rot_data[9];   assign mxbele_d1[9] = rot_data[6];
assign mxbele_d0[10] = rot_data[10]; assign mxbele_d1[10] = rot_data[5];
assign mxbele_d0[11] = rot_data[11]; assign mxbele_d1[11] = rot_data[4];
assign mxbele_d0[12] = rot_data[12]; assign mxbele_d1[12] = rot_data[3];
assign mxbele_d0[13] = rot_data[13]; assign mxbele_d1[13] = rot_data[2];
assign mxbele_d0[14] = rot_data[14]; assign mxbele_d1[14] = rot_data[1];
assign mxbele_d0[15] = rot_data[15]; assign mxbele_d1[15] = rot_data[0];

tri_aoi22 #(.WIDTH(16)) mxbele_b_0 (.y(mxbele_b[0:15]), .a0(mxbele_d0[0:15]), .a1(bele_s0[0:15]), .b0(mxbele_d1[0:15]), .b1(bele_s1[0:15]));

tri_inv #(.WIDTH(16)) mxbele_0 (.y(mxbele[0:15]), .a(mxbele_b[0:15]));

// ----------------------------------------------------------------------------------------
// First level of muxing <0,4,8,12 bytes>
// ----------------------------------------------------------------------------------------

assign mx1_s0[0:7]  = {8{rot_sel2[0]}};
assign mx1_s1[0:7]  = {8{rot_sel2[1]}};
assign mx1_s2[0:7]  = {8{rot_sel2[2]}};
assign mx1_s3[0:7]  = {8{rot_sel2[3]}};
assign mx1_s0[8:15] = {8{rot_sel2[4]}};
assign mx1_s1[8:15] = {8{rot_sel2[5]}};
assign mx1_s2[8:15] = {8{rot_sel2[6]}};
assign mx1_s3[8:15] = {8{rot_sel2[7]}};

assign mx1_d0[0] = mxbele[0];   assign mx1_d1[0] = mxbele[4];   assign mx1_d2[0] = mxbele[8];   assign mx1_d3[0] = mxbele[12];
assign mx1_d0[1] = mxbele[1];   assign mx1_d1[1] = mxbele[5];   assign mx1_d2[1] = mxbele[9];   assign mx1_d3[1] = mxbele[13];
assign mx1_d0[2] = mxbele[2];   assign mx1_d1[2] = mxbele[6];   assign mx1_d2[2] = mxbele[10];  assign mx1_d3[2] = mxbele[14];
assign mx1_d0[3] = mxbele[3];   assign mx1_d1[3] = mxbele[7];   assign mx1_d2[3] = mxbele[11];  assign mx1_d3[3] = mxbele[15];
assign mx1_d0[4] = mxbele[4];   assign mx1_d1[4] = mxbele[8];   assign mx1_d2[4] = mxbele[12];  assign mx1_d3[4] = mxbele[0];
assign mx1_d0[5] = mxbele[5];   assign mx1_d1[5] = mxbele[9];   assign mx1_d2[5] = mxbele[13];  assign mx1_d3[5] = mxbele[1];
assign mx1_d0[6] = mxbele[6];   assign mx1_d1[6] = mxbele[10];  assign mx1_d2[6] = mxbele[14];  assign mx1_d3[6] = mxbele[2];
assign mx1_d0[7] = mxbele[7];   assign mx1_d1[7] = mxbele[11];  assign mx1_d2[7] = mxbele[15];  assign mx1_d3[7] = mxbele[3];
assign mx1_d0[8] = mxbele[8];   assign mx1_d1[8] = mxbele[12];  assign mx1_d2[8] = mxbele[0];   assign mx1_d3[8] = mxbele[4];
assign mx1_d0[9] = mxbele[9];   assign mx1_d1[9] = mxbele[13];  assign mx1_d2[9] = mxbele[1];   assign mx1_d3[9] = mxbele[5];
assign mx1_d0[10] = mxbele[10]; assign mx1_d1[10] = mxbele[14]; assign mx1_d2[10] = mxbele[2];  assign mx1_d3[10] = mxbele[6];
assign mx1_d0[11] = mxbele[11]; assign mx1_d1[11] = mxbele[15]; assign mx1_d2[11] = mxbele[3];  assign mx1_d3[11] = mxbele[7];
assign mx1_d0[12] = mxbele[12]; assign mx1_d1[12] = mxbele[0];  assign mx1_d2[12] = mxbele[4];  assign mx1_d3[12] = mxbele[8];
assign mx1_d0[13] = mxbele[13]; assign mx1_d1[13] = mxbele[1];  assign mx1_d2[13] = mxbele[5];  assign mx1_d3[13] = mxbele[9];
assign mx1_d0[14] = mxbele[14]; assign mx1_d1[14] = mxbele[2];  assign mx1_d2[14] = mxbele[6];  assign mx1_d3[14] = mxbele[10];
assign mx1_d0[15] = mxbele[15]; assign mx1_d1[15] = mxbele[3];  assign mx1_d2[15] = mxbele[7];  assign mx1_d3[15] = mxbele[11];

tri_aoi22 #(.WIDTH(16)) mx1_0_b_0 (.y(mx1_0_b[0:15]), .a0(mx1_s0[0:15]), .a1(mx1_d0[0:15]), .b0(mx1_s1[0:15]), .b1(mx1_d1[0:15]));

tri_aoi22 #(.WIDTH(16)) mx1_1_b_0 (.y(mx1_1_b[0:15]), .a0(mx1_s2[0:15]), .a1(mx1_d2[0:15]), .b0(mx1_s3[0:15]), .b1(mx1_d3[0:15]));

tri_nand2 #(.WIDTH(16)) mx1_0 (.y(mx1[0:15]), .a(mx1_0_b[0:15]), .b(mx1_1_b[0:15]));

// ----------------------------------------------------------------------------------------
// third level of muxing <0,1,2,3 bytes>
// ----------------------------------------------------------------------------------------

assign mx2_s0[0:7]  = {8{rot_sel3[0]}};
assign mx2_s1[0:7]  = {8{rot_sel3[1]}};
assign mx2_s2[0:7]  = {8{rot_sel3[2]}};
assign mx2_s3[0:7]  = {8{rot_sel3[3]}};
assign mx2_s0[8:15] = {8{rot_sel3[4]}};
assign mx2_s1[8:15] = {8{rot_sel3[5]}};
assign mx2_s2[8:15] = {8{rot_sel3[6]}};
assign mx2_s3[8:15] = {8{rot_sel3[7]}};

assign mx2_d0[0] = mx1[0];   assign mx2_d1[0] = mx1[1];   assign mx2_d2[0] = mx1[2];   assign mx2_d3[0] = mx1[3];
assign mx2_d0[1] = mx1[1];   assign mx2_d1[1] = mx1[2];   assign mx2_d2[1] = mx1[3];   assign mx2_d3[1] = mx1[4];
assign mx2_d0[2] = mx1[2];   assign mx2_d1[2] = mx1[3];   assign mx2_d2[2] = mx1[4];   assign mx2_d3[2] = mx1[5];
assign mx2_d0[3] = mx1[3];   assign mx2_d1[3] = mx1[4];   assign mx2_d2[3] = mx1[5];   assign mx2_d3[3] = mx1[6];
assign mx2_d0[4] = mx1[4];   assign mx2_d1[4] = mx1[5];   assign mx2_d2[4] = mx1[6];   assign mx2_d3[4] = mx1[7];
assign mx2_d0[5] = mx1[5];   assign mx2_d1[5] = mx1[6];   assign mx2_d2[5] = mx1[7];   assign mx2_d3[5] = mx1[8];
assign mx2_d0[6] = mx1[6];   assign mx2_d1[6] = mx1[7];   assign mx2_d2[6] = mx1[8];   assign mx2_d3[6] = mx1[9];
assign mx2_d0[7] = mx1[7];   assign mx2_d1[7] = mx1[8];   assign mx2_d2[7] = mx1[9];   assign mx2_d3[7] = mx1[10];
assign mx2_d0[8] = mx1[8];   assign mx2_d1[8] = mx1[9];   assign mx2_d2[8] = mx1[10];  assign mx2_d3[8] = mx1[11];
assign mx2_d0[9] = mx1[9];   assign mx2_d1[9] = mx1[10];  assign mx2_d2[9] = mx1[11];  assign mx2_d3[9] = mx1[12];
assign mx2_d0[10] = mx1[10]; assign mx2_d1[10] = mx1[11]; assign mx2_d2[10] = mx1[12]; assign mx2_d3[10] = mx1[13];
assign mx2_d0[11] = mx1[11]; assign mx2_d1[11] = mx1[12]; assign mx2_d2[11] = mx1[13]; assign mx2_d3[11] = mx1[14];
assign mx2_d0[12] = mx1[12]; assign mx2_d1[12] = mx1[13]; assign mx2_d2[12] = mx1[14]; assign mx2_d3[12] = mx1[15];
assign mx2_d0[13] = mx1[13]; assign mx2_d1[13] = mx1[14]; assign mx2_d2[13] = mx1[15]; assign mx2_d3[13] = mx1[0];
assign mx2_d0[14] = mx1[14]; assign mx2_d1[14] = mx1[15]; assign mx2_d2[14] = mx1[0];  assign mx2_d3[14] = mx1[1];
assign mx2_d0[15] = mx1[15]; assign mx2_d1[15] = mx1[0];  assign mx2_d2[15] = mx1[1];  assign mx2_d3[15] = mx1[2];

tri_aoi22 #(.WIDTH(16)) mx2_0_b_0 (.y(mx2_0_b[0:15]), .a0(mx2_s0[0:15]), .a1(mx2_d0[0:15]), .b0(mx2_s1[0:15]), .b1(mx2_d1[0:15]));

tri_aoi22 #(.WIDTH(16)) mx2_1_b_0 (.y(mx2_1_b[0:15]), .a0(mx2_s2[0:15]), .a1(mx2_d2[0:15]), .b0(mx2_s3[0:15]), .b1(mx2_d3[0:15]));

tri_nand2 #(.WIDTH(16)) mx2_0 (.y(mx2[0:15]), .a(mx2_0_b[0:15]), .b(mx2_1_b[0:15]));

// #############################################################################################

// #############################################################################################
// Outputs
// #############################################################################################

assign data_rot = mx2;

// #############################################################################################

endmodule
