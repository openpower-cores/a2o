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

// input phase is importent
// (change X (B) by switching xor/xnor )

module lq_agen_glbglb(
   g08,
   t08,
   c64_b
);
input [1:7]     g08;
input [1:6]     t08;

output [1:7]    c64_b;

wire [0:3]   b1_g16_b;

wire [0:2]   b1_t16_b;

wire [0:1]   b1_g32;

wire [0:0]   b1_t32;

wire [0:3]   b2_g16_b;

wire [0:2]   b2_t16_b;

wire [0:1]   b2_g32;

wire [0:0]   b2_t32;

wire [0:3]   b3_g16_b;

wire [0:2]   b3_t16_b;

wire [0:1]   b3_g32;

wire [0:0]   b3_t32;

wire [0:3]   b4_g16_b;

wire [0:2]   b4_t16_b;

wire [0:1]   b4_g32;

wire [0:0]   b4_t32;

wire [0:2]   b5_g16_b;

wire [0:1]   b5_t16_b;

wire [0:1]   b5_g32;

wire [0:0]   b5_t32;

wire [0:1]   b6_g16_b;

wire [0:0]   b6_t16_b;

wire [0:0]   b6_g32;

wire [0:0]   b7_g16_b;

wire [0:0]   b7_g32;

////#############################
////## byte 1
////#############################

//assign b1_g16_b[0] = (~(g08[1] | (t08[1] & g08[2])));
tri_aoi21 b1_g16_b_0 (.y(b1_g16_b[0]), .a0(t08[1]), .a1(g08[2]), .b0(g08[1]));

//assign b1_g16_b[1] = (~(g08[3] | (t08[3] & g08[4])));
tri_aoi21 b1_g16_b_1 (.y(b1_g16_b[1]), .a0(t08[3]), .a1(g08[4]), .b0(g08[3]));

//assign b1_g16_b[2] = (~(g08[5] | (t08[5] & g08[6])));
tri_aoi21 b1_g16_b_2 (.y(b1_g16_b[2]), .a0(t08[5]), .a1(g08[6]), .b0(g08[5]));

//assign b1_g16_b[3] = (~(g08[7]));
tri_inv b1_g16_b_3 (.y(b1_g16_b[3]), .a(g08[7]));

//assign b1_t16_b[0] = (~(t08[1] & t08[2]));
tri_nand2 b1_t16_b_0 (.y(b1_t16_b[0]), .a(t08[1]), .b(t08[2]));

//assign b1_t16_b[1] = (~(t08[3] & t08[4]));
tri_nand2 b1_t16_b_1 (.y(b1_t16_b[1]), .a(t08[3]), .b(t08[4]));

//assign b1_t16_b[2] = (~(t08[5] & t08[6]));
tri_nand2 b1_t16_b_2 (.y(b1_t16_b[2]), .a(t08[5]), .b(t08[6]));

//assign b1_g32[0] = (~(b1_g16_b[0] & (b1_t16_b[0] | b1_g16_b[1])));
tri_oai21 b1_g32_0 (.y(b1_g32[0]), .a0(b1_t16_b[0]), .a1(b1_g16_b[1]), .b0(b1_g16_b[0]));

//assign b1_g32[1] = (~(b1_g16_b[2] & (b1_t16_b[2] | b1_g16_b[3])));
tri_oai21 b1_g32_1 (.y(b1_g32[1]), .a0(b1_t16_b[2]), .a1(b1_g16_b[3]), .b0(b1_g16_b[2]));

//assign b1_t32[0] = (~(b1_t16_b[0] | b1_t16_b[1]));
tri_nor2 b1_t32_0 (.y(b1_t32[0]), .a(b1_t16_b[0]), .b(b1_t16_b[1]));

//assign c64_b[1] = (~(b1_g32[0] | (b1_t32[0] & b1_g32[1])));		//output--
tri_aoi21 c64_b_1 (.y(c64_b[1]), .a0(b1_t32[0]), .a1(b1_g32[1]), .b0(b1_g32[0]));

////#############################
////## byte 2
////#############################

//assign b2_g16_b[0] = (~(g08[2] | (t08[2] & g08[3])));
tri_aoi21 b2_g16_b_0 (.y(b2_g16_b[0]), .a0(t08[2]), .a1(g08[3]), .b0(g08[2]));

//assign b2_g16_b[1] = (~(g08[4] | (t08[4] & g08[5])));
tri_aoi21 b2_g16_b_1 (.y(b2_g16_b[1]), .a0(t08[4]), .a1(g08[5]), .b0(g08[4]));

//assign b2_g16_b[2] = (~(g08[6]));
tri_inv #(.WIDTH(2)) b2_g16_b_2 (.y(b2_g16_b[2:3]), .a(g08[6:7]));

//assign b2_t16_b[0] = (~(t08[2] & t08[3]));
tri_nand2 b2_t16_b_0 (.y(b2_t16_b[0]), .a(t08[2]), .b(t08[3]));

//assign b2_t16_b[1] = (~(t08[4] & t08[5]));
tri_nand2 b2_t16_b_1 (.y(b2_t16_b[1]), .a(t08[4]), .b(t08[5]));

//assign b2_t16_b[2] = (~(t08[6]));
tri_inv b2_t16_b_2 (.y(b2_t16_b[2]), .a(t08[6]));

//assign b2_g32[0] = (~(b2_g16_b[0] & (b2_t16_b[0] | b2_g16_b[1])));
tri_oai21 b2_g32_0 (.y(b2_g32[0]), .a0(b2_t16_b[0]), .a1(b2_g16_b[1]), .b0(b2_g16_b[0]));

//assign b2_g32[1] = (~(b2_g16_b[2] & (b2_t16_b[2] | b2_g16_b[3])));
tri_oai21 b2_g32_1 (.y(b2_g32[1]), .a0(b2_t16_b[2]), .a1(b2_g16_b[3]), .b0(b2_g16_b[2]));

//assign b2_t32[0] = (~(b2_t16_b[0] | b2_t16_b[1]));
tri_nor2 b2_t32_0 (.y(b2_t32[0]), .a(b2_t16_b[0]), .b(b2_t16_b[1]));

//assign c64_b[2] = (~(b2_g32[0] | (b2_t32[0] & b2_g32[1])));		//output--
tri_aoi21 c64_b_2 (.y(c64_b[2]), .a0(b2_t32[0]), .a1(b2_g32[1]), .b0(b2_g32[0]));

////#############################
////## byte 3
////#############################

//assign b3_g16_b[0] = (~(g08[3] | (t08[3] & g08[4])));
tri_aoi21 b3_g16_b_0 (.y(b3_g16_b[0]), .a0(t08[3]), .a1(g08[4]), .b0(g08[3]));

//assign b3_g16_b[1] = (~(g08[5]));
tri_inv #(.WIDTH(3)) b3_g16_b_3 (.y(b3_g16_b[1:3]), .a(g08[5:7]));

//assign b3_t16_b[0] = (~(t08[3] & t08[4]));
tri_nand2 b3_t16_b_0 (.y(b3_t16_b[0]), .a(t08[3]), .b(t08[4]));

//assign b3_t16_b[1] = (~(t08[5]));
tri_inv #(.WIDTH(2)) b3_t16_b_1 (.y(b3_t16_b[1:2]), .a(t08[5:6]));

//assign b3_g32[0] = (~(b3_g16_b[0] & (b3_t16_b[0] | b3_g16_b[1])));
tri_oai21 b3_g32_0 (.y(b3_g32[0]), .a0(b3_t16_b[0]), .a1(b3_g16_b[1]), .b0(b3_g16_b[0]));

//assign b3_g32[1] = (~(b3_g16_b[2] & (b3_t16_b[2] | b3_g16_b[3])));
tri_oai21 b3_g32_1 (.y(b3_g32[1]), .a0(b3_t16_b[2]), .a1(b3_g16_b[3]), .b0(b3_g16_b[2]));

//assign b3_t32[0] = (~(b3_t16_b[0] | b3_t16_b[1]));
tri_nor2 b3_t32_0 (.y(b3_t32[0]), .a(b3_t16_b[0]), .b(b3_t16_b[1]));

//assign c64_b[3] = (~(b3_g32[0] | (b3_t32[0] & b3_g32[1])));		//output--
tri_aoi21 c64_b_3 (.y(c64_b[3]), .a0(b3_t32[0]), .a1(b3_g32[1]), .b0(b3_g32[0]));

////#############################
////## byte 4
////#############################

//assign b4_g16_b[0] = (~(g08[4]));
tri_inv #(.WIDTH(4)) b4_g16_b_0 (.y(b4_g16_b[0:3]), .a(g08[4:7]));

//assign b4_t16_b[0] = (~(t08[4]));
tri_inv #(.WIDTH(3)) b4_t16_b_0 (.y(b4_t16_b[0:2]), .a(t08[4:6]));

//assign b4_g32[0] = (~(b4_g16_b[0] & (b4_t16_b[0] | b4_g16_b[1])));
tri_oai21 b4_g32_0 (.y(b4_g32[0]), .a0(b4_t16_b[0]), .a1(b4_g16_b[1]), .b0(b4_g16_b[0]));

//assign b4_g32[1] = (~(b4_g16_b[2] & (b4_t16_b[2] | b4_g16_b[3])));
tri_oai21 b4_g32_1 (.y(b4_g32[1]), .a0(b4_t16_b[2]), .a1(b4_g16_b[3]), .b0(b4_g16_b[2]));

//assign b4_t32[0] = (~(b4_t16_b[0] | b4_t16_b[1]));
tri_nor2 b4_t32_0 (.y(b4_t32[0]), .a(b4_t16_b[0]), .b(b4_t16_b[1]));

//assign c64_b[4] = (~(b4_g32[0] | (b4_t32[0] & b4_g32[1])));		//output--
tri_aoi21 c64_b_4 (.y(c64_b[4]), .a0(b4_t32[0]), .a1(b4_g32[1]), .b0(b4_g32[0]));

////#############################
////## byte 5
////#############################

//assign b5_g16_b[0] = (~(g08[5]));
tri_inv #(.WIDTH(3)) b5_g16_b_0 (.y(b5_g16_b[0:2]), .a(g08[5:7]));

//assign b5_t16_b[0] = (~(t08[5]));
tri_inv #(.WIDTH(2)) b5_t16_b_0 (.y(b5_t16_b[0:1]), .a(t08[5:6]));

//assign b5_g32[0] = (~(b5_g16_b[0] & (b5_t16_b[0] | b5_g16_b[1])));
tri_oai21 b5_g32_0 (.y(b5_g32[0]), .a0(b5_t16_b[0]), .a1(b5_g16_b[1]), .b0(b5_g16_b[0]));

//assign b5_g32[1] = (~(b5_g16_b[2]));
tri_inv b5_g32_1 (.y(b5_g32[1]), .a(b5_g16_b[2]));

//assign b5_t32[0] = (~(b5_t16_b[0] | b5_t16_b[1]));
tri_nor2 b5_t32_0 (.y(b5_t32[0]), .a(b5_t16_b[0]), .b(b5_t16_b[1]));

//assign c64_b[5] = (~(b5_g32[0] | (b5_t32[0] & b5_g32[1])));		//output--
tri_aoi21 c64_b_5 (.y(c64_b[5]), .a0(b5_t32[0]), .a1(b5_g32[1]), .b0(b5_g32[0]));

////#############################
////## byte 6
////#############################

//assign b6_g16_b[0] = (~(g08[6]));
tri_inv #(.WIDTH(2)) b6_g16_b_0 (.y(b6_g16_b[0:1]), .a(g08[6:7]));

//assign b6_t16_b[0] = (~(t08[6]));
tri_inv b6_t16_b_0 (.y(b6_t16_b[0]), .a(t08[6]));

//assign b6_g32[0] = (~(b6_g16_b[0] & (b6_t16_b[0] | b6_g16_b[1])));
tri_oai21 b6_g32_0 (.y(b6_g32[0]), .a0(b6_t16_b[0]), .a1(b6_g16_b[1]), .b0(b6_g16_b[0]));

//assign c64_b[6] = (~(b6_g32[0]));		//output--
tri_inv c64_b_6 (.y(c64_b[6]), .a(b6_g32[0]));

////#############################
////## byte 7
////#############################

//assign b7_g16_b[0] = (~(g08[7]));
tri_inv b7_g16_b_0 (.y(b7_g16_b[0]), .a(g08[7]));

//assign b7_g32[0] = (~(b7_g16_b[0]));
tri_inv b7_g32_0 (.y(b7_g32[0]), .a(b7_g16_b[0]));

//assign c64_b[7] = (~(b7_g32[0]));		//output--
tri_inv c64_b_7 (.y(c64_b[7]), .a(b7_g32[0]));

endmodule
