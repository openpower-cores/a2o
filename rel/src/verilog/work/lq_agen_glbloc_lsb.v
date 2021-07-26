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

module lq_agen_glbloc_lsb(
   x_b,
   y_b,
   g08
);
input [0:7]     x_b;
input [0:7]     y_b;

output          g08;

wire [0:7]      g01;

wire [0:6]      t01;

wire [0:3]      g02_b;

wire [0:2]      t02_b;

wire [0:1]      g04;

wire [0:0]      t04;

wire            g08_b;

//assign g01[0] = (~(x_b[0] | y_b[0]));
tri_nor2 #(.WIDTH(8)) g01_0 (.y(g01[0:7]), .a(x_b[0:7]), .b(y_b[0:7]));

//assign t01[0] = (~(x_b[0] & y_b[0]));
tri_nand2 #(.WIDTH(7)) t01_0 (.y(t01[0:6]), .a(x_b[0:6]), .b(y_b[0:6]));

//assign g02_b[0] = (~(g01[0] | (t01[0] & g01[1])));
tri_aoi21 g02_b_0 (.y(g02_b[0]), .a0(t01[0]), .a1(g01[1]), .b0(g01[0]));

//assign g02_b[1] = (~(g01[2] | (t01[2] & g01[3])));
tri_aoi21 g02_b_1 (.y(g02_b[1]), .a0(t01[2]), .a1(g01[3]), .b0(g01[2]));

//assign g02_b[2] = (~(g01[4] | (t01[4] & g01[5])));
tri_aoi21 g02_b_2 (.y(g02_b[2]), .a0(t01[4]), .a1(g01[5]), .b0(g01[4]));

//assign g02_b[3] = (~(g01[6] | (t01[6] & g01[7])));
tri_aoi21 g02_b_3 (.y(g02_b[3]), .a0(t01[6]), .a1(g01[7]), .b0(g01[6]));

//assign t02_b[0] = (~(t01[0] & t01[1]));
tri_nand2 t02_b_0 (.y(t02_b[0]), .a(t01[0]), .b(t01[1]));

//assign t02_b[1] = (~(t01[2] & t01[3]));
tri_nand2 t02_b_1 (.y(t02_b[1]), .a(t01[2]), .b(t01[3]));

//assign t02_b[2] = (~(t01[4] & t01[5]));
tri_nand2 t02_b_2 (.y(t02_b[2]), .a(t01[4]), .b(t01[5]));

//assign g04[0] = (~(g02_b[0] & (t02_b[0] | g02_b[1])));
tri_oai21 g04_0 (.y(g04[0]), .a0(t02_b[0]), .a1(g02_b[1]), .b0(g02_b[0]));

//assign g04[1] = (~(g02_b[2] & (t02_b[2] | g02_b[3])));
tri_oai21 g04_1 (.y(g04[1]), .a0(t02_b[2]), .a1(g02_b[3]), .b0(g02_b[2]));

//assign t04[0] = (~(t02_b[0] | t02_b[1]));
tri_nor2 t04_0 (.y(t04[0]), .a(t02_b[0]), .b(t02_b[1]));

//assign g08_b = (~(g04[0] | (t04[0] & g04[1])));
tri_aoi21 g08_b_0 (.y(g08_b), .a0(t04[0]), .a1(g04[1]), .b0(g04[0]));

//assign g08 = (~(g08_b));		// output
tri_inv g08_0 (.y(g08), .a(g08_b));

endmodule
