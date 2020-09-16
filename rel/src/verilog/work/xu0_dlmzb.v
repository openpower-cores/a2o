// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

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
