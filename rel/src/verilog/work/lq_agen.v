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

`include "tri_a2o.vh"


module lq_agen(
   x,
   y,
   mode64,
   dir_ig_57_b,
   sum_non_erat,
   sum,
   sum_arr_dir01,
   sum_arr_dir23,
   sum_arr_dir45,
   sum_arr_dir67,
   way,
   rel4_dir_wr_val,
   ary_write_act_01,
   ary_write_act_23,
   ary_write_act_45,
   ary_write_act_67
);

//-------------------------------------------------------------------
// Generics
//-------------------------------------------------------------------
//parameter      expand_type = 2;		// 2 - ibm tech, 1 - other

input [0:63]        x;
input [0:63]        y;
input               mode64;		        // 1 per byte [0:31]
input               dir_ig_57_b;		// when this is low , bit 57 becomes "1" .

output [0:63]       sum_non_erat;		// for compares and uses other than array address
output [0:51]       sum;		        // 0:51 for erat

output [52:57]      sum_arr_dir01;

output [52:57]      sum_arr_dir23;

output [52:57]      sum_arr_dir45;

output [52:57]      sum_arr_dir67;

input [0:7]         way;		        // 8 bit vector use to be in array model
input               rel4_dir_wr_val;
output              ary_write_act_01;
output              ary_write_act_23;
output              ary_write_act_45;
output              ary_write_act_67;

parameter           tiup = 1'b1;
parameter           tidn = 1'b0;

wire [0:51]         sum_int;
wire [0:51]         sum_non_erat_b;
wire [0:51]         sum_erat;
wire [0:51]         sum_erat_b;
wire [0:51]         sum_0;
wire [0:51]         sum_1;
wire [1:7]          g08;
wire [1:6]          t08;
wire [1:7]          c64_b;
wire                addr_sel_64;

wire [0:63]         x_b;

wire [0:63]         y_b;

wire [52:57]        sum_arr;

wire [52:57]        sum_arr_lv1_0_b;

wire [52:57]        sum_arr_lv1_1_b;

assign addr_sel_64 = mode64;

// assume pins come in the top
// start global carry along the top .
// byte groups (0 near top) stretch out along the macro.

//assign x_b[0:63] = (~(x[0:63]));		// receiving inverter near pin
tri_inv #(.WIDTH(64)) x_b_0 (.y(x_b[0:63]), .a(x[0:63]));

//assign y_b[0:63] = (~(y[0:63]));		// receiving inverter near pin
tri_inv #(.WIDTH(64)) y_b_0 (.y(y_b[0:63]), .a(y[0:63]));

//##################################################
//## local part of byte group
//##################################################

lq_agen_loca loc_0(
   .x_b(x_b[0:7]),		    //i--
   .y_b(y_b[0:7]),		    //i--
   .sum_0(sum_0[0:7]),		//o--
   .sum_1(sum_1[0:7])		//o--
);

lq_agen_loca loc_1(
   .x_b(x_b[8:15]),		    //i--
   .y_b(y_b[8:15]),		    //i--
   .sum_0(sum_0[8:15]),		//o--
   .sum_1(sum_1[8:15])		//o--
);

lq_agen_loca loc_2(
   .x_b(x_b[16:23]),		//i--
   .y_b(y_b[16:23]),		//i--
   .sum_0(sum_0[16:23]),	//o--
   .sum_1(sum_1[16:23])		//o--
);

lq_agen_loca loc_3(
   .x_b(x_b[24:31]),		//i--
   .y_b(y_b[24:31]),		//i--
   .sum_0(sum_0[24:31]),	//o--
   .sum_1(sum_1[24:31])		//o--
);

lq_agen_loca loc_4(
   .x_b(x_b[32:39]),		//i--
   .y_b(y_b[32:39]),		//i--
   .sum_0(sum_0[32:39]),	//o--
   .sum_1(sum_1[32:39])		//o--
);

lq_agen_loca loc_5(
   .x_b(x_b[40:47]),		//i--
   .y_b(y_b[40:47]),		//i--
   .sum_0(sum_0[40:47]),	//o--
   .sum_1(sum_1[40:47])		//o--
);

lq_agen_locae loc_6(
   .x_b(x_b[48:55]),		//i--
   .y_b(y_b[48:55]),		//i--
   .sum_0(sum_0[48:51]),	//o--
   .sum_1(sum_1[48:51])		//o--
);

//##################################################
//## local part of global carry
//##################################################

lq_agen_glbloc gclc_1(
   .x_b(x_b[8:15]),		    //i--
   .y_b(y_b[8:15]),		    //i--
   .g08(g08[1]),		    //o--
   .t08(t08[1])		        //o--
);

lq_agen_glbloc gclc_2(
   .x_b(x_b[16:23]),		//i--
   .y_b(y_b[16:23]),		//i--
   .g08(g08[2]),		    //o--
   .t08(t08[2])		        //o--
);

lq_agen_glbloc gclc_3(
   .x_b(x_b[24:31]),		//i--
   .y_b(y_b[24:31]),		//i--
   .g08(g08[3]),		    //o--
   .t08(t08[3])		        //o--
);

lq_agen_glbloc gclc_4(
   .x_b(x_b[32:39]),		//i--
   .y_b(y_b[32:39]),		//i--
   .g08(g08[4]),		    //o--
   .t08(t08[4])		        //o--
);

lq_agen_glbloc gclc_5(
   .x_b(x_b[40:47]),		//i--
   .y_b(y_b[40:47]),		//i--
   .g08(g08[5]),		    //o--
   .t08(t08[5])		        //o--
);

lq_agen_glbloc gclc_6(
   .x_b(x_b[48:55]),		//i--
   .y_b(y_b[48:55]),		//i--
   .g08(g08[6]),		    //o--
   .t08(t08[6])		        //o--
);

lq_agen_glbloc_lsb gclc_7(
   .x_b(x_b[56:63]),		//i--
   .y_b(y_b[56:63]),		//i--
   .g08(g08[7])		        //o--
);

//##################################################
//## global part of global carry  {replicate ending of global carry vertical)
//##################################################

lq_agen_glbglb gc(
   .g08(g08[1:7]),		    //i--
   .t08(t08[1:6]),		    //i--
   .c64_b(c64_b[1:7])		//o--
);

//##################################################
//## final mux  (vertical)
//##################################################

lq_agen_csmux fm_0(
   .ci_b(c64_b[1]),		    //i--
   .sum_0(sum_0[0:7]),		//i--
   .sum_1(sum_1[0:7]),		//i--
   .sum(sum_int[0:7])		//o--
);

lq_agen_csmux fm_1(
   .ci_b(c64_b[2]),		    //i--
   .sum_0(sum_0[8:15]),		//i--
   .sum_1(sum_1[8:15]),		//i--
   .sum(sum_int[8:15])		//o--
);

lq_agen_csmux fm_2(
   .ci_b(c64_b[3]),		        //i--
   .sum_0(sum_0[16:23]),		//i--
   .sum_1(sum_1[16:23]),		//i--
   .sum(sum_int[16:23])		    //o--
);

lq_agen_csmux fm_3(
   .ci_b(c64_b[4]),		        //i--
   .sum_0(sum_0[24:31]),		//i--
   .sum_1(sum_1[24:31]),		//i--
   .sum(sum_int[24:31])		    //o--
);

lq_agen_csmux fm_4(
   .ci_b(c64_b[5]),		        //i--
   .sum_0(sum_0[32:39]),		//i--
   .sum_1(sum_1[32:39]),		//i--
   .sum(sum_int[32:39])		    //o--
);

lq_agen_csmux fm_5(
   .ci_b(c64_b[6]),		        //i--
   .sum_0(sum_0[40:47]),		//i--
   .sum_1(sum_1[40:47]),		//i--
   .sum(sum_int[40:47])		    //o--
);
		// just the 4 msb of the byte go to erat
lq_agen_csmuxe fm_6(
   .ci_b(c64_b[7]),		        //i--
   .sum_0(sum_0[48:51]),		//i--
   .sum_1(sum_1[48:51]),		//i--
   .sum(sum_int[48:51])		    //o--
);

		// 12 lsbs are for the DIRECTORY
lq_agen_lo kog(
   .dir_ig_57_b(dir_ig_57_b),	//i--lq_agen_lo(kog) force dir addr 57 to "1"
   .x_b(x_b[52:63]),		    //i--lq_agen_lo(kog)
   .y_b(y_b[52:63]),		    //i--lq_agen_lo(kog)
   .sum(sum_non_erat[52:63]),	//o--lq_agen_lo(kog) for the compares etc
   .sum_arr(sum_arr[52:57])		//o--lq_agen_lo(kog) for the array address
);

//assign sum_non_erat_b[0:51] = (~(sum_int[0:51]));
tri_inv #(.WIDTH(52)) sum_non_erat_b_0 (.y(sum_non_erat_b[0:51]), .a(sum_int[0:51]));

//assign sum_non_erat[0:51] = (~(sum_non_erat_b[0:51]));
tri_inv #(.WIDTH(52)) sum_non_erat_0 (.y(sum_non_erat[0:51]), .a(sum_non_erat_b[0:51]));

//assign sum_erat_b[0:31] = (~(sum_int[0:31] & {32{addr_sel_64}}));
tri_nand2 #(.WIDTH(32)) sum_erat_b_0 (.y(sum_erat_b[0:31]), .a(sum_int[0:31]), .b({32{addr_sel_64}}));

//assign sum_erat_b[32:51] = (~(sum_int[32:51]));
tri_inv #(.WIDTH(20)) sum_erat_b_32 (.y(sum_erat_b[32:51]), .a(sum_int[32:51]));

//assign sum_erat = (~(sum_erat_b));
tri_inv #(.WIDTH(52)) sum_erat_0 (.y(sum_erat[0:51]), .a(sum_erat_b[0:51]));

assign sum = sum_erat;		//rename-- to ERAT only

// ###################################
// # repower network for directoru
// ###################################

//assign sum_arr_lv1_1_b[52:57] = (~(sum_arr[52:57]));		    // 4x
tri_inv #(.WIDTH(6)) sum_arr_lv1_1_b_52 (.y(sum_arr_lv1_1_b[52:57]), .a(sum_arr[52:57]));

//assign sum_arr_dir01[52:57] = (~(sum_arr_lv1_1_b[52:57]));		// 4x --output--
tri_inv #(.WIDTH(6)) sum_arr_dir01_52 (.y(sum_arr_dir01[52:57]), .a(sum_arr_lv1_1_b[52:57]));

//assign sum_arr_dir45[52:57] = (~(sum_arr_lv1_1_b[52:57]));		// 4x --output--
tri_inv #(.WIDTH(6)) sum_arr_dir45_52 (.y(sum_arr_dir45[52:57]), .a(sum_arr_lv1_1_b[52:57]));

//assign sum_arr_lv1_0_b[52:57] = (~(sum_arr[52:57]));		    // 6x
tri_inv #(.WIDTH(6)) sum_arr_lv1_0_b_52 (.y(sum_arr_lv1_0_b[52:57]), .a(sum_arr[52:57]));

//assign sum_arr_dir23[52:57] = (~(sum_arr_lv1_0_b[52:57]));		// 4x --output--
tri_inv #(.WIDTH(6)) sum_arr_dir23_52 (.y(sum_arr_dir23[52:57]), .a(sum_arr_lv1_0_b[52:57]));

//assign sum_arr_dir67[52:57] = (~(sum_arr_lv1_0_b[52:57]));		// 4x --output--
tri_inv #(.WIDTH(6)) sum_arr_dir67_52 (.y(sum_arr_dir67[52:57]), .a(sum_arr_lv1_0_b[52:57]));

// ######################################################################
// ## this experimental piece is for directory read/write collisions
// ######################################################################

assign ary_write_act_01 = rel4_dir_wr_val & (way[0] | way[1]);
assign ary_write_act_23 = rel4_dir_wr_val & (way[2] | way[3]);
assign ary_write_act_45 = rel4_dir_wr_val & (way[4] | way[5]);
assign ary_write_act_67 = rel4_dir_wr_val & (way[6] | way[7]);

endmodule
