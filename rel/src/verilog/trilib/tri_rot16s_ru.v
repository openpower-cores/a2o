// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns



`include "tri_a2o.vh"



module tri_rot16s_ru(
   opsize,
   le,
   le_rotate_sel,
   be_rotate_sel,
   algebraic,
   le_algebraic_sel,
   be_algebraic_sel,
   arr_data,
   stq7_byp_val,
   stq_byp_val,
   stq7_rmw_data,
   stq8_rmw_data,
   data_latched,
   data_rot,
   algebraic_bit,
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

input [0:4]         opsize;		    
input               le;
input [0:3]         le_rotate_sel;
input [0:3]         be_rotate_sel;
input               algebraic;
input [0:3]         le_algebraic_sel;
input [0:3]         be_algebraic_sel;

input [0:15]        arr_data;		
input               stq7_byp_val;
input               stq_byp_val;
input [0:15]        stq7_rmw_data;
input [0:15]        stq8_rmw_data;
output [0:15]       data_latched;	

output [0:15]       data_rot;	    

output [0:5]        algebraic_bit;

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


wire                my_d1clk;
wire                my_d2clk;
wire [0:`NCLK_WIDTH-1]  my_lclk;

wire [0:15]         data_latched_b;

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

wire [0:3]          be_shx04_sgn0_q_b;

wire [0:3]          be_shx04_sgn0_q;
wire [0:3]          be_shx04_sgn0_din;

wire [0:3]          le_shx04_sgn0_q_b;

wire [0:3]          le_shx04_sgn0_q;
wire [0:3]          le_shx04_sgn0_din;

wire [0:3]          be_shx01_sgn0_q_b;

wire [0:3]          be_shx01_sgn0_q;
wire [0:3]          be_shx01_sgn0_din;

wire [0:3]          le_shx01_sgn0_q_b;

wire [0:3]          le_shx01_sgn0_q;
wire [0:3]          le_shx01_sgn0_din;

wire [0:15]         mxbele_b;

wire [0:15]         mxbele;

wire [0:15]         mx1_0_b;

wire [0:15]         mx1_1_b;

wire [0:15]         mx1;

wire [0:15]         mx2_0_b;

wire [0:15]         mx2_1_b;

wire [0:15]         mx2;

wire [0:7]          sx1_0_b;

wire [0:7]          sx1_1_b;

wire [0:7]          sx1;

wire [0:5]          sx2_0_b;

wire [0:5]          sx2_1_b;

wire [0:5]          sx2;

wire [0:15]         do_b;

wire [0:5]          sign_copy_b;
wire [0:15]         mxbele_d0;
wire [0:15]         mxbele_d1;
wire [0:15]         bele_s0;
wire [0:15]         bele_s1;
wire [0:3]          shx04_gp0_sel_b;
wire [0:3]          shx04_gp0_sel;
wire [0:3]          shx04_sgn0_sel_b;
wire [0:3]          shx04_sgn0_sel;
wire [0:3]          shx01_gp0_sel_b;
wire [0:3]          shx01_gp0_sel;
wire [0:3]          shx01_sgn0_sel_b;
wire [0:3]          shx01_sgn0_sel;
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
wire [0:7]          sx1_d0;
wire [0:7]          sx1_d1;
wire [0:7]          sx1_d2;
wire [0:7]          sx1_d3;
wire [0:5]          sx2_d0;
wire [0:5]          sx2_d1;
wire [0:5]          sx2_d2;
wire [0:5]          sx2_d3;
wire [0:7]          sx1_s0;
wire [0:7]          sx1_s1;
wire [0:7]          sx1_s2;
wire [0:7]          sx1_s3;
wire [0:5]          sx2_s0;
wire [0:5]          sx2_s1;
wire [0:5]          sx2_s2;
wire [0:5]          sx2_s3;
wire [0:15]         mask_en;
wire [0:3]          be_shx04_sel;
wire [0:3]          be_shx01_sel;
wire [0:3]          le_shx04_sel;
wire [0:3]          le_shx01_sel;
wire [0:3]          be_shx04_sgn;
wire [0:3]          be_shx01_sgn;
wire [0:3]          le_shx04_sgn;
wire [0:3]          le_shx01_sgn;
wire [0:15]         stq_byp_data;
wire [0:15]         rotate_data;


parameter           bele_gp0_din_offset = 0;
parameter           be_shx04_gp0_din_offset = bele_gp0_din_offset + 1;
parameter           le_shx04_gp0_din_offset = be_shx04_gp0_din_offset + 4;
parameter           be_shx01_gp0_din_offset = le_shx04_gp0_din_offset + 4;
parameter           le_shx01_gp0_din_offset = be_shx01_gp0_din_offset + 4;
parameter           mask_din_offset = le_shx01_gp0_din_offset + 4;
parameter           be_shx04_sgn0_din_offset = mask_din_offset + 5;
parameter           be_shx01_sgn0_din_offset = be_shx04_sgn0_din_offset + 4;
parameter           le_shx04_sgn0_din_offset = be_shx01_sgn0_din_offset + 4;
parameter           le_shx01_sgn0_din_offset = le_shx04_sgn0_din_offset + 4;
parameter           scan_right = le_shx01_sgn0_din_offset + 4 - 1;

wire [0:scan_right] siv;
wire [0:scan_right] sov;





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


assign be_shx04_sgn[0] = (~be_algebraic_sel[0]) & (~be_algebraic_sel[1]);
assign be_shx04_sgn[1] = (~be_algebraic_sel[0]) &   be_algebraic_sel[1];
assign be_shx04_sgn[2] =   be_algebraic_sel[0]  & (~be_algebraic_sel[1]);
assign be_shx04_sgn[3] =   be_algebraic_sel[0]  &   be_algebraic_sel[1];
assign le_shx04_sgn[0] = (~le_algebraic_sel[0]) & (~le_algebraic_sel[1]);
assign le_shx04_sgn[1] = (~le_algebraic_sel[0]) &   le_algebraic_sel[1];
assign le_shx04_sgn[2] =   le_algebraic_sel[0]  & (~le_algebraic_sel[1]);
assign le_shx04_sgn[3] =   le_algebraic_sel[0]  &   le_algebraic_sel[1];

assign be_shx01_sgn[0] = (~be_algebraic_sel[2]) & (~be_algebraic_sel[3]) & algebraic;
assign be_shx01_sgn[1] = (~be_algebraic_sel[2]) &   be_algebraic_sel[3]  & algebraic;
assign be_shx01_sgn[2] =   be_algebraic_sel[2]  & (~be_algebraic_sel[3]) & algebraic;
assign be_shx01_sgn[3] =   be_algebraic_sel[2]  &   be_algebraic_sel[3]  & algebraic;
assign le_shx01_sgn[0] = (~le_algebraic_sel[2]) & (~le_algebraic_sel[3]) & algebraic;
assign le_shx01_sgn[1] = (~le_algebraic_sel[2]) &   le_algebraic_sel[3]  & algebraic;
assign le_shx01_sgn[2] =   le_algebraic_sel[2]  & (~le_algebraic_sel[3]) & algebraic;
assign le_shx01_sgn[3] =   le_algebraic_sel[2]  &   le_algebraic_sel[3]  & algebraic;

assign mask_din[0] = opsize[0];		
assign mask_din[1] = opsize[0] | opsize[1];		
assign mask_din[2] = opsize[0] | opsize[1] | opsize[2];		
assign mask_din[3] = opsize[0] | opsize[1] | opsize[2] | opsize[3];		
assign mask_din[4] = opsize[0] | opsize[1] | opsize[2] | opsize[3] | opsize[4];	

assign bele_gp0_din[0] = le;
assign be_shx04_gp0_din[0:3] = be_shx04_sel[0:3];
assign le_shx04_gp0_din[0:3] = le_shx04_sel[0:3];
assign be_shx01_gp0_din[0:3] = be_shx01_sel[0:3];
assign le_shx01_gp0_din[0:3] = le_shx01_sel[0:3];
assign be_shx04_sgn0_din[0:3] = be_shx04_sgn[0:3];
assign be_shx01_sgn0_din[0:3] = be_shx01_sgn[0:3];
assign le_shx04_sgn0_din[0:3] = le_shx04_sgn[0:3];
assign le_shx01_sgn0_din[0:3] = le_shx01_sgn[0:3];




tri_inv bele_gp0_q_0 (.y(bele_gp0_q), .a(bele_gp0_q_b));

tri_inv #(.WIDTH(4)) be_shx04_gp0_q_0 (.y(be_shx04_gp0_q[0:3]), .a(be_shx04_gp0_q_b[0:3]));

tri_inv #(.WIDTH(4)) le_shx04_gp0_q_0 (.y(le_shx04_gp0_q[0:3]), .a(le_shx04_gp0_q_b[0:3]));

tri_inv #(.WIDTH(4)) be_shx01_gp0_q_0 (.y(be_shx01_gp0_q[0:3]), .a(be_shx01_gp0_q_b[0:3]));

tri_inv #(.WIDTH(4)) le_shx01_gp0_q_0 (.y(le_shx01_gp0_q[0:3]), .a(le_shx01_gp0_q_b[0:3]));

tri_inv #(.WIDTH(4)) be_shx04_sgn0_q_0 (.y(be_shx04_sgn0_q[0:3]), .a(be_shx04_sgn0_q_b[0:3]));

tri_inv #(.WIDTH(4)) le_shx04_sgn0_q_0 (.y(le_shx04_sgn0_q[0:3]), .a(le_shx04_sgn0_q_b[0:3]));

tri_inv #(.WIDTH(4)) be_shx01_sgn0_q_0 (.y(be_shx01_sgn0_q[0:3]), .a(be_shx01_sgn0_q_b[0:3]));

tri_inv #(.WIDTH(4)) le_shx01_sgn0_q_0 (.y(le_shx01_sgn0_q[0:3]), .a(le_shx01_sgn0_q_b[0:3]));

assign mask_q[0:4] = (~mask_q_b[0:4]);

assign stq_byp_data = ({16{stq7_byp_val}} & stq7_rmw_data) | ({16{~stq7_byp_val}} & stq8_rmw_data);
assign rotate_data  = ({16{stq_byp_val}}  & stq_byp_data)  | ({16{~stq_byp_val}}  & arr_data);

assign bele_s0[0:15] = {16{~bele_gp0_q[0]}};
assign bele_s1[0:15] = {16{ bele_gp0_q[0]}};

tri_aoi22 #(.WIDTH(4)) shx04_gp0_sel_b_0 (.y(shx04_gp0_sel_b[0:3]), .a0(be_shx04_gp0_q[0:3]), .a1(bele_s0[0:3]), .b0(le_shx04_gp0_q[0:3]), .b1(bele_s1[0:3]));

tri_aoi22 #(.WIDTH(4)) shx01_gp0_sel_b_0 (.y(shx01_gp0_sel_b[0:3]), .a0(be_shx01_gp0_q[0:3]), .a1(bele_s0[4:7]), .b0(le_shx01_gp0_q[0:3]), .b1(bele_s1[4:7]));

tri_aoi22 #(.WIDTH(4)) shx04_sgn0_sel_b_0 (.y(shx04_sgn0_sel_b[0:3]), .a0(be_shx04_sgn0_q[0:3]), .a1(bele_s0[8:11]), .b0(le_shx04_sgn0_q[0:3]), .b1(bele_s1[8:11]));

tri_aoi22 #(.WIDTH(4)) shx01_sgn0_sel_b_0 (.y(shx01_sgn0_sel_b[0:3]), .a0(be_shx01_sgn0_q[0:3]), .a1(bele_s0[12:15]), .b0(le_shx01_sgn0_q[0:3]), .b1(bele_s1[12:15]));

assign shx04_gp0_sel = (~shx04_gp0_sel_b);
assign shx01_gp0_sel = (~shx01_gp0_sel_b);
assign shx04_sgn0_sel = (~shx04_sgn0_sel_b);
assign shx01_sgn0_sel = (~shx01_sgn0_sel_b);

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

assign sx1_s0[0:7] = {8{shx04_sgn0_sel[0]}};
assign sx1_s1[0:7] = {8{shx04_sgn0_sel[1]}};
assign sx1_s2[0:7] = {8{shx04_sgn0_sel[2]}};
assign sx1_s3[0:7] = {8{shx04_sgn0_sel[3]}};

assign sx1_d0[0] = rotate_data[0];   assign sx1_d1[0] = rotate_data[4];   assign sx1_d2[0] = rotate_data[8];   assign sx1_d3[0] = rotate_data[12];
assign sx1_d0[1] = rotate_data[1];   assign sx1_d1[1] = rotate_data[5];   assign sx1_d2[1] = rotate_data[9];   assign sx1_d3[1] = rotate_data[13];
assign sx1_d0[2] = rotate_data[2];   assign sx1_d1[2] = rotate_data[6];   assign sx1_d2[2] = rotate_data[10];  assign sx1_d3[2] = rotate_data[14];
assign sx1_d0[3] = rotate_data[3];   assign sx1_d1[3] = rotate_data[7];   assign sx1_d2[3] = rotate_data[11];  assign sx1_d3[3] = rotate_data[15];
assign sx1_d0[4] = rotate_data[0];   assign sx1_d1[4] = rotate_data[4];   assign sx1_d2[4] = rotate_data[8];   assign sx1_d3[4] = rotate_data[12];
assign sx1_d0[5] = rotate_data[1];   assign sx1_d1[5] = rotate_data[5];   assign sx1_d2[5] = rotate_data[9];   assign sx1_d3[5] = rotate_data[13];
assign sx1_d0[6] = rotate_data[2];   assign sx1_d1[6] = rotate_data[6];   assign sx1_d2[6] = rotate_data[10];  assign sx1_d3[6] = rotate_data[14];
assign sx1_d0[7] = rotate_data[3];   assign sx1_d1[7] = rotate_data[7];   assign sx1_d2[7] = rotate_data[11];  assign sx1_d3[7] = rotate_data[15];

tri_aoi22 #(.WIDTH(8)) sx1_0_b_0 (.y(sx1_0_b[0:7]), .a0(sx1_s0[0:7]), .a1(sx1_d0[0:7]), .b0(sx1_s1[0:7]), .b1(sx1_d1[0:7]));

tri_aoi22 #(.WIDTH(8)) sx1_1_b_0 (.y(sx1_1_b[0:7]), .a0(sx1_s2[0:7]), .a1(sx1_d2[0:7]), .b0(sx1_s3[0:7]), .b1(sx1_d3[0:7]));

tri_nand2 #(.WIDTH(8)) sx1_0 (.y(sx1[0:7]), .a(sx1_0_b[0:7]), .b(sx1_1_b[0:7]));


assign mask_en[0:7]   = {8{mask_q[0]}};	
assign mask_en[8:11]  = {4{mask_q[1]}};	
assign mask_en[12:13] = {2{mask_q[2]}};	
assign mask_en[14]    = mask_q[3];		
assign mask_en[15]    = mask_q[4];		

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

assign sx2_s0[0:3] = {4{shx01_sgn0_sel[0]}};
assign sx2_s1[0:3] = {4{shx01_sgn0_sel[1]}};
assign sx2_s2[0:3] = {4{shx01_sgn0_sel[2]}};
assign sx2_s3[0:3] = {4{shx01_sgn0_sel[3]}};

assign sx2_s0[4:5] = {2{shx01_sgn0_sel[0] & (~mask_q[2])}};
assign sx2_s1[4:5] = {2{shx01_sgn0_sel[1] & (~mask_q[2])}};
assign sx2_s2[4:5] = {2{shx01_sgn0_sel[2] & (~mask_q[2])}};
assign sx2_s3[4:5] = {2{shx01_sgn0_sel[3] & (~mask_q[2])}};

assign sx2_d0[0] = sx1[0];   assign sx2_d1[0] = sx1[1];   assign sx2_d2[0] = sx1[2];   assign sx2_d3[0] = sx1[3];
assign sx2_d0[1] = sx1[0];   assign sx2_d1[1] = sx1[1];   assign sx2_d2[1] = sx1[2];   assign sx2_d3[1] = sx1[3];
assign sx2_d0[2] = sx1[0];   assign sx2_d1[2] = sx1[1];   assign sx2_d2[2] = sx1[2];   assign sx2_d3[2] = sx1[3];
assign sx2_d0[3] = sx1[4];   assign sx2_d1[3] = sx1[5];   assign sx2_d2[3] = sx1[6];   assign sx2_d3[3] = sx1[7];
assign sx2_d0[4] = sx1[4];   assign sx2_d1[4] = sx1[5];   assign sx2_d2[4] = sx1[6];   assign sx2_d3[4] = sx1[7];
assign sx2_d0[5] = sx1[4];   assign sx2_d1[5] = sx1[5];   assign sx2_d2[5] = sx1[6];   assign sx2_d3[5] = sx1[7];

tri_aoi22 #(.WIDTH(6)) sx2_0_b_0 (.y(sx2_0_b[0:5]), .a0(sx2_s0[0:5]), .a1(sx2_d0[0:5]), .b0(sx2_s1[0:5]), .b1(sx2_d1[0:5]));

tri_aoi22 #(.WIDTH(6)) sx2_1_b_0 (.y(sx2_1_b[0:5]), .a0(sx2_s2[0:5]), .a1(sx2_d2[0:5]), .b0(sx2_s3[0:5]), .b1(sx2_d3[0:5]));

tri_nand2 #(.WIDTH(6)) sx2_0 (.y(sx2[0:5]), .a(sx2_0_b[0:5]), .b(sx2_1_b[0:5]));

tri_inv #(.WIDTH(6)) sign_copy_b_0 (.y(sign_copy_b[0:5]), .a(sx2[0:5]));

tri_inv #(.WIDTH(6)) algebraic_bit_0 (.y(algebraic_bit[0:5]), .a(sign_copy_b[0:5]));


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

tri_inv_nlats #(.WIDTH(4), .INIT(4'h0), .BTR("NLI0001_X2_A12TH"), .NEEDS_SRESET(0)) be_shx04_sgn0_lat(
   .vd(vdd),
   .gd(gnd),
   .lclk(my_lclk),
   .d1clk(my_d1clk),
   .d2clk(my_d2clk),
   .scanin(siv[be_shx04_sgn0_din_offset:be_shx04_sgn0_din_offset + 4 - 1]),
   .scanout(sov[be_shx04_sgn0_din_offset:be_shx04_sgn0_din_offset + 4 - 1]),
   .d(be_shx04_sgn0_din),
   .qb(be_shx04_sgn0_q_b)
);

tri_inv_nlats #(.WIDTH(4), .INIT(4'h0), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) be_shx01_sgn0_lat(
   .vd(vdd),
   .gd(gnd),
   .lclk(my_lclk),
   .d1clk(my_d1clk),
   .d2clk(my_d2clk),
   .scanin(siv[be_shx01_sgn0_din_offset:be_shx01_sgn0_din_offset + 4 - 1]),
   .scanout(sov[be_shx01_sgn0_din_offset:be_shx01_sgn0_din_offset + 4 - 1]),
   .d(be_shx01_sgn0_din),
   .qb(be_shx01_sgn0_q_b)
);

tri_inv_nlats #(.WIDTH(4), .INIT(4'h0), .BTR("NLI0001_X2_A12TH"), .NEEDS_SRESET(0)) le_shx04_sgn0_lat(
   .vd(vdd),
   .gd(gnd),
   .lclk(my_lclk),
   .d1clk(my_d1clk),
   .d2clk(my_d2clk),
   .scanin(siv[le_shx04_sgn0_din_offset:le_shx04_sgn0_din_offset + 4 - 1]),
   .scanout(sov[le_shx04_sgn0_din_offset:le_shx04_sgn0_din_offset + 4 - 1]),
   .d(le_shx04_sgn0_din),
   .qb(le_shx04_sgn0_q_b)
);

tri_inv_nlats #(.WIDTH(4), .INIT(4'h0), .BTR("NLI0001_X1_A12TH"), .NEEDS_SRESET(0)) le_shx01_sgn0_lat(
   .vd(vdd),
   .gd(gnd),
   .lclk(my_lclk),
   .d1clk(my_d1clk),
   .d2clk(my_d2clk),
   .scanin(siv[le_shx01_sgn0_din_offset:le_shx01_sgn0_din_offset + 4 - 1]),
   .scanout(sov[le_shx01_sgn0_din_offset:le_shx01_sgn0_din_offset + 4 - 1]),
   .d(le_shx01_sgn0_din),
   .qb(le_shx01_sgn0_q_b)
);

assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
assign scan_out = sov[0];

endmodule

