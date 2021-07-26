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

//*****************************************************************************
//  Description:  XU Determine Leftmost Zero Byte
//
//*****************************************************************************

module xu0_dlmzb(
   // Inputs
   input [32:63]  byp_dlm_ex2_rs1,
   input [32:63]  byp_dlm_ex2_rs2,
   input [0:2]    byp_dlm_ex2_xer,

   // Outputs
   output [0:9]   dlm_byp_ex2_xer,
   output [0:3]   dlm_byp_ex2_cr,
   output [60:63] dlm_byp_ex2_rt
);


   wire [0:7]     a;
   wire [0:7]     a0;
   wire [0:7]     a1;
   wire [0:7]     a2;
   wire [0:3]     y;

   // Null == 0
   assign a[0] = |(byp_dlm_ex2_rs1[32:39]);
   assign a[1] = |(byp_dlm_ex2_rs1[40:47]);
   assign a[2] = |(byp_dlm_ex2_rs1[48:55]);
   assign a[3] = |(byp_dlm_ex2_rs1[56:63]);
   assign a[4] = |(byp_dlm_ex2_rs2[32:39]);
   assign a[5] = |(byp_dlm_ex2_rs2[40:47]);
   assign a[6] = |(byp_dlm_ex2_rs2[48:55]);
   assign a[7] = |(byp_dlm_ex2_rs2[56:63]);

   assign a0[1:7] = a[0:6] & a[1:7];
   assign a1[2:7] = a0[0:5] & a0[2:7];
   assign a2[4:7] = a1[0:3] & a1[4:7];

   assign a0[0:0] = a[0:0];
   assign a1[0:1] = a0[0:1];
   assign a2[0:3] = a1[0:3];

   assign y = (a2[0:7] == 8'b00000000) ? 4'b0001 : 		// Null in last  4B
              (a2[0:7] == 8'b10000000) ? 4'b0010 :
              (a2[0:7] == 8'b11000000) ? 4'b0011 :
              (a2[0:7] == 8'b11100000) ? 4'b0100 :
              (a2[0:7] == 8'b11110000) ? 4'b0101 :
              (a2[0:7] == 8'b11111000) ? 4'b0110 :
              (a2[0:7] == 8'b11111100) ? 4'b0111 :
              4'b1000;

   assign dlm_byp_ex2_cr[0] = (~a2[7]) & a2[3];
   assign dlm_byp_ex2_cr[1] = (~a2[7]) & (~a2[3]);		   // Null in first 4B
   assign dlm_byp_ex2_cr[2] = a2[7];		               // Null not found
   assign dlm_byp_ex2_cr[3] = byp_dlm_ex2_xer[0];		   // SO Copy

   assign dlm_byp_ex2_xer = {byp_dlm_ex2_xer[0:2], 3'b000, y[0:3]};

   assign dlm_byp_ex2_rt = y;

endmodule
