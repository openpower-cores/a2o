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

// this is used in the agen  ... for this byte (half the bits go to ERAT through this macro, others go to DIR from different macro


module lq_agen_locae(
   x_b,
   y_b,
   sum_0,
   sum_1
);

input [0:7]         x_b;		// after xor
input [0:7]         y_b;

output [0:3]        sum_0;

output [0:3]        sum_1;

wire [0:7]          x;

wire [0:7]          y;

wire [1:7]          g01_b;

wire [1:7]          t01_b;

wire [0:3]          p01;

wire [0:3]          p01_b;

wire [1:4]          g08_b;

wire [1:4]          g08;

wire [1:7]          g04_b;

wire [1:7]          g02;

wire [1:7]          t02;

wire [1:7]          t04_b;

wire [1:4]          t08;

wire [1:4]          t08_b;

wire [0:3]          h01;

wire [0:3]          h01_b;

//####################################################################
//# inverter at top to drive to bit location
//####################################################################

//assign x[0:7] = (~x_b[0:7]);		// maybe should be fat wire
tri_inv #(.WIDTH(8)) x_0 (.y(x[0:7]), .a(x_b[0:7]));

//assign y[0:7] = (~y_b[0:7]);		// maybe should be fat wire
tri_inv #(.WIDTH(8)) y_0 (.y(y[0:7]), .a(y_b[0:7]));

//####################################################################
//# pgt
//####################################################################

//assign g01_b[1:7] = (~(x[1:7] & y[1:7]));
tri_nand2 #(.WIDTH(7)) g01_b_1 (.y(g01_b[1:7]), .a(x[1:7]), .b(y[1:7]));

//assign t01_b[1:7] = (~(x[1:7] | y[1:7]));
tri_nor2 #(.WIDTH(7)) t01_b_1 (.y(t01_b[1:7]), .a(x[1:7]), .b(y[1:7]));

//assign p01_b[0:3] = (~(x[0:3] ^ y[0:3]));
tri_xnor2 #(.WIDTH(4)) p01_b_0 (.y(p01_b[0:3]), .a(x[0:3]), .b(y[0:3]));

//assign p01[0:3] = (~(p01_b[0:3]));
tri_inv #(.WIDTH(4)) p01_0 (.y(p01[0:3]), .a(p01_b[0:3]));

//####################################################################
//# local carry
//####################################################################

//assign g02[1] = (~(g01_b[1] & (t01_b[1] | g01_b[2])));
tri_oai21 #(.WIDTH(6)) g02_1 (.y(g02[1:6]), .a0(t01_b[1:6]), .a1(g01_b[2:7]), .b0(g01_b[1:6]));

//assign g02[7] = (~(g01_b[7]));
tri_inv g02_7 (.y(g02[7]), .a(g01_b[7]));

//assign t02[1] = (~(t01_b[1] | t01_b[2]));
tri_nor2 #(.WIDTH(5)) t02_1 (.y(t02[1:5]), .a(t01_b[1:5]), .b(t01_b[2:6]));

//assign t02[6] = (~(g01_b[6] & (t01_b[6] | t01_b[7])));		//final--
tri_oai21 t02_6 (.y(t02[6]), .a0(t01_b[6]), .a1(t01_b[7]), .b0(g01_b[6]));

//assign t02[7] = (~(t01_b[7]));
tri_inv t02_7 (.y(t02[7]), .a(t01_b[7]));

//assign g04_b[1] = (~(g02[1] | (t02[1] & g02[3])));
tri_aoi21 #(.WIDTH(5)) g04_b_1 (.y(g04_b[1:5]), .a0(t02[1:5]), .a1(g02[3:7]), .b0(g02[1:5]));

//assign g04_b[6] = (~(g02[6]));
tri_inv #(.WIDTH(2)) g04_b_6 (.y(g04_b[6:7]), .a(g02[6:7]));

//assign t04_b[1] = (~(t02[1] & t02[3]));
tri_nand2 #(.WIDTH(3)) t04_b_1 (.y(t04_b[1:3]), .a(t02[1:3]), .b(t02[3:5]));

//assign t04_b[4] = (~(g02[4] | (t02[4] & t02[6])));		//final--
tri_aoi21 #(.WIDTH(2)) t04_b_4 (.y(t04_b[4:5]), .a0(t02[4:5]), .a1(t02[6:7]), .b0(g02[4:5]));

//assign t04_b[6] = (~(t02[6]));
tri_inv #(.WIDTH(2)) t04_b_6 (.y(t04_b[6:7]), .a(t02[6:7]));

//assign g08[1] = (~(g04_b[1] & (t04_b[1] | g04_b[5])));		//final--
tri_oai21 #(.WIDTH(3)) g08_1 (.y(g08[1:3]), .a0(t04_b[1:3]), .a1(g04_b[5:7]), .b0(g04_b[1:3]));

//assign g08[4] = (~(g04_b[4]));
tri_inv g08_4 (.y(g08[4]), .a(g04_b[4]));

//assign t08[1] = (~(g04_b[1] & (t04_b[1] | t04_b[5])));		//final--
tri_oai21 #(.WIDTH(3)) t08_1 (.y(t08[1:3]), .a0(t04_b[1:3]), .a1(t04_b[5:7]), .b0(g04_b[1:3]));

//assign t08[4] = (~(t04_b[4]));
tri_inv t08_4 (.y(t08[4]), .a(t04_b[4]));

//####################################################################
//# conditional sums  // may need to make NON-xor implementation
//####################################################################

//assign g08_b[1] = (~g08[1]);
tri_inv #(.WIDTH(4)) g08_b_1 (.y(g08_b[1:4]), .a(g08[1:4]));

//assign t08_b[1] = (~t08[1]);
tri_inv #(.WIDTH(4)) t08_b_1 (.y(t08_b[1:4]), .a(t08[1:4]));

//assign h01[0:3] = (~p01_b[0:3]);
tri_inv #(.WIDTH(4)) h01_0 (.y(h01[0:3]), .a(p01_b[0:3]));

//assign h01_b[0:3] = (~p01[0:3]);
tri_inv #(.WIDTH(4)) h01_b_0 (.y(h01_b[0:3]), .a(p01[0:3]));

//assign sum_0[0] = (~((h01[0] & g08[1]) | (h01_b[0] & g08_b[1])));		//output--
tri_aoi22 #(.WIDTH(4)) sum0 (.y(sum_0[0:3]), .a0(h01[0:3]), .a1(g08[1:4]), .b0(h01_b[0:3]), .b1(g08_b[1:4]));

//assign sum_1[0] = (~((h01[0] & t08[1]) | (h01_b[0] & t08_b[1])));		//output--
tri_aoi22 #(.WIDTH(4)) sum1 (.y(sum_1[0:3]), .a0(h01[0:3]), .a1(t08[1:4]), .b0(h01_b[0:3]), .b1(t08_b[1:4]));

endmodule
