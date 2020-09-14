// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns





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
   
   
   assign mx1_s0[0:7] = {8{rot_sel[0]}};
   assign mx1_s1[0:7] = {8{rot_sel[1]}};
   assign mx1_s2[0:7] = {8{rot_sel[2]}};
   assign mx1_s3[0:7] = {8{rot_sel[3]}};
   
   assign mask_exp[0] = mask[0];		                        
   assign mask_exp[1] = mask[0];		                        
   assign mask_exp[2] = mask[0];		                        
   assign mask_exp[3] = mask[0];		                        
   assign mask_exp[4] = mask[0] | mask[1];		                
   assign mask_exp[5] = mask[0] | mask[1];		                
   assign mask_exp[6] = mask[0] | mask[1] | mask[2];		    
   assign mask_exp[7] = mask[0] | mask[1] | mask[2] | mask[3];  
   
   assign se1[0:3] = {4{((~se_b))}};
   assign se1[4:5] = {2{(((~se_b)) & mask[2])}};
   
   assign mx1_d0 = (rot_data[0:7]) & mask_exp;
   assign mx1_d1 = ({2'b0, rot_data[0:5]}) & mask_exp;
   assign mx1_d2 = ({4'b0, rot_data[0:3]}) & mask_exp;
   assign mx1_d3 = ({6'b0, rot_data[0:1]}) & mask_exp;
   
   
   tri_aoi22 #(.WIDTH(8)) mx1_0_b_0 (.y(mx1_0_b[0:7]), .a0(mx1_s0[0:7]), .a1(mx1_d0[0:7]), .b0(mx1_s1[0:7]), .b1(mx1_d1[0:7]));   
   
   tri_aoi22 #(.WIDTH(8)) mx1_1_b_0 (.y(mx1_1_b[0:7]), .a0(mx1_s2[0:7]), .a1(mx1_d2[0:7]), .b0(mx1_s3[0:7]), .b1(mx1_d3[0:7]));
   
   tri_nand2 #(.WIDTH(8)) mx1_0 (.y(mx1[0:7]), .a(mx1_0_b[0:7]), .b(mx1_1_b[0:7]));
   
   assign data_rot = {(mx1[0:5] | se1[0:5]), mx1[6:7]};
      
endmodule

