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
//  Description:  XU LSU Store Data Mux
//*****************************************************************************


module lq_stq_rot(
   rot_sel,
   mask,
   se_b,
   rot_data,
   data_rot
);
   input [0:3]  rot_sel;
   input [0:3]  mask;
   input        se_b;
   input [0:7]  rot_data;


   output [0:7] data_rot;

   wire [0:5]   se1;
   wire [0:7]   mx1_d0;
   wire [0:7]   mx1_d1;
   wire [0:7]   mx1_d2;
   wire [0:7]   mx1_d3;
   wire [0:7]   mx1_s0;
   wire [0:7]   mx1_s1;
   wire [0:7]   mx1_s2;
   wire [0:7]   mx1_s3;
   wire [0:7]   mx1_0_b;
   wire [0:7]   mx1_1_b;
   wire [0:7]   mx1;
   wire [0:7]   mask_exp;

   //--------------------------------------------------------------------------------------
   // Muxing <0,2,4,6 bytes>
   //--------------------------------------------------------------------------------------
   assign mx1_s0[0:7] = {8{rot_sel[0]}};
   assign mx1_s1[0:7] = {8{rot_sel[1]}};
   assign mx1_s2[0:7] = {8{rot_sel[2]}};
   assign mx1_s3[0:7] = {8{rot_sel[3]}};

   // Generate a Mask that is dependent on the size of the operation
   assign mask_exp[0] = mask[0];		                        // 8B
   assign mask_exp[1] = mask[0];		                        // 8B
   assign mask_exp[2] = mask[0];		                        // 8B
   assign mask_exp[3] = mask[0];		                        // 8B
   assign mask_exp[4] = mask[0] | mask[1];		                // 8B/4B
   assign mask_exp[5] = mask[0] | mask[1];		                // 8B/4B
   assign mask_exp[6] = mask[0] | mask[1] | mask[2];		    // 8B/4B/2B
   assign mask_exp[7] = mask[0] | mask[1] | mask[2] | mask[3];  // 8B/4B/2B/1B

   assign se1[0:3] = {4{((~se_b))}};
   assign se1[4:5] = {2{(((~se_b)) & mask[2])}};

   assign mx1_d0 = (rot_data[0:7]) & mask_exp;
   assign mx1_d1 = ({2'b0, rot_data[0:5]}) & mask_exp;
   assign mx1_d2 = ({4'b0, rot_data[0:3]}) & mask_exp;
   assign mx1_d3 = ({6'b0, rot_data[0:1]}) & mask_exp;


   //assign mx1_0_b[0:7] = (~((mx1_s0[0:7] & mx1_d0[0:7]) | (mx1_s1[0:7] & mx1_d1[0:7])));
   tri_aoi22 #(.WIDTH(8)) mx1_0_b_0 (.y(mx1_0_b[0:7]), .a0(mx1_s0[0:7]), .a1(mx1_d0[0:7]), .b0(mx1_s1[0:7]), .b1(mx1_d1[0:7]));

   //assign mx1_1_b[0:7] = (~((mx1_s2[0:7] & mx1_d2[0:7]) | (mx1_s3[0:7] & mx1_d3[0:7])));
   tri_aoi22 #(.WIDTH(8)) mx1_1_b_0 (.y(mx1_1_b[0:7]), .a0(mx1_s2[0:7]), .a1(mx1_d2[0:7]), .b0(mx1_s3[0:7]), .b1(mx1_d3[0:7]));

   //assign mx1[0:7] = (~(mx1_0_b[0:7] & mx1_1_b[0:7]));
   tri_nand2 #(.WIDTH(8)) mx1_0 (.y(mx1[0:7]), .a(mx1_0_b[0:7]), .b(mx1_1_b[0:7]));

   assign data_rot = {(mx1[0:5] | se1[0:5]), mx1[6:7]};

endmodule
