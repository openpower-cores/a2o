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
   


module fu_tblres(
   f,
   est,
   rng
);
   input [1:6]   f;
   output [1:20] est;
   output [6:20] rng;
   
   
   
   
   
   
   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;
   
   wire          dcd_00x;
   wire          dcd_01x;
   wire          dcd_10x;
   wire          dcd_11x;
   wire          dcd_000;
   wire          dcd_001;
   wire          dcd_010;
   wire          dcd_011;
   wire          dcd_100;
   wire          dcd_101;
   wire          dcd_110;
   wire          dcd_111;
   wire          combo2_1000;
   wire          combo2_0100;
   wire          combo2_1100;
   wire          combo2_0010;
   wire          combo2_1010;
   wire          combo2_0110;
   wire          combo2_1110;
   wire          combo2_0001;
   wire          combo2_1001;
   wire          combo2_0101;
   wire          combo2_1101;
   wire          combo2_0011;
   wire          combo2_1011;
   wire          combo2_0111;
   wire          combo2_1000_xxxx_b;
   wire          combo2_0100_xxxx_b;
   wire          combo2_1100_xxxx_b;
   wire          combo2_0010_xxxx_b;
   wire          combo2_1010_xxxx_b;
   wire          combo2_0110_xxxx_b;
   wire          combo2_1110_xxxx_b;
   wire          combo2_0001_xxxx_b;
   wire          combo2_1001_xxxx_b;
   wire          combo2_0101_xxxx_b;
   wire          combo2_1101_xxxx_b;
   wire          combo2_0011_xxxx_b;
   wire          combo2_1011_xxxx_b;
   wire          combo2_0111_xxxx_b;
   wire          combo2_xxxx_1000_b;
   wire          combo2_xxxx_0100_b;
   wire          combo2_xxxx_1100_b;
   wire          combo2_xxxx_0010_b;
   wire          combo2_xxxx_1010_b;
   wire          combo2_xxxx_0110_b;
   wire          combo2_xxxx_1110_b;
   wire          combo2_xxxx_0001_b;
   wire          combo2_xxxx_1001_b;
   wire          combo2_xxxx_0101_b;
   wire          combo2_xxxx_1101_b;
   wire          combo2_xxxx_0011_b;
   wire          combo2_xxxx_1011_b;
   wire          combo2_xxxx_0111_b;
   wire          combo3_0000_0001;
   wire          combo3_0000_0010;
   wire          combo3_0000_0011;
   wire          combo3_0000_0100;
   wire          combo3_0000_0101;
   wire          combo3_0000_0110;
   wire          combo3_0000_1001;
   wire          combo3_0000_1010;
   wire          combo3_0000_1011;
   wire          combo3_0000_1110;
   wire          combo3_0000_1111;
   wire          combo3_0001_0001;
   wire          combo3_0001_0010;
   wire          combo3_0001_0100;
   wire          combo3_0001_0101;
   wire          combo3_0001_0111;
   wire          combo3_0001_1000;
   wire          combo3_0001_1010;
   wire          combo3_0001_1011;
   wire          combo3_0001_1100;
   wire          combo3_0001_1110;
   wire          combo3_0001_1111;
   wire          combo3_0010_0000;
   wire          combo3_0010_0100;
   wire          combo3_0010_0101;
   wire          combo3_0010_0110;
   wire          combo3_0010_0111;
   wire          combo3_0010_1000;
   wire          combo3_0010_1001;
   wire          combo3_0010_1101;
   wire          combo3_0011_0000;
   wire          combo3_0011_0001;
   wire          combo3_0011_0011;
   wire          combo3_0011_0101;
   wire          combo3_0011_1000;
   wire          combo3_0011_1001;
   wire          combo3_0011_1010;
   wire          combo3_0011_1011;
   wire          combo3_0011_1100;
   wire          combo3_0011_1110;
   wire          combo3_0011_1111;
   wire          combo3_0100_0000;
   wire          combo3_0100_0011;
   wire          combo3_0100_0110;
   wire          combo3_0100_1000;
   wire          combo3_0100_1001;
   wire          combo3_0100_1010;
   wire          combo3_0100_1100;
   wire          combo3_0100_1101;
   wire          combo3_0100_1110;
   wire          combo3_0101_0000;
   wire          combo3_0101_0001;
   wire          combo3_0101_0010;
   wire          combo3_0101_0100;
   wire          combo3_0101_0101;
   wire          combo3_0101_0110;
   wire          combo3_0101_1000;
   wire          combo3_0101_1011;
   wire          combo3_0101_1111;
   wire          combo3_0110_0000;
   wire          combo3_0110_0010;
   wire          combo3_0110_0011;
   wire          combo3_0110_0110;
   wire          combo3_0110_0111;
   wire          combo3_0110_1000;
   wire          combo3_0110_1010;
   wire          combo3_0110_1011;
   wire          combo3_0110_1100;
   wire          combo3_0110_1101;
   wire          combo3_0111_0000;
   wire          combo3_0111_0001;
   wire          combo3_0111_0101;
   wire          combo3_0111_0110;
   wire          combo3_0111_1000;
   wire          combo3_0111_1001;
   wire          combo3_0111_1010;
   wire          combo3_0111_1011;
   wire          combo3_0111_1101;
   wire          combo3_0111_1111;
   wire          combo3_1000_0000;
   wire          combo3_1000_0001;
   wire          combo3_1000_0011;
   wire          combo3_1000_0100;
   wire          combo3_1000_0101;
   wire          combo3_1000_1010;
   wire          combo3_1000_1100;
   wire          combo3_1000_1101;
   wire          combo3_1001_0100;
   wire          combo3_1001_0110;
   wire          combo3_1001_0111;
   wire          combo3_1001_1000;
   wire          combo3_1001_1001;
   wire          combo3_1001_1010;
   wire          combo3_1001_1011;
   wire          combo3_1001_1111;
   wire          combo3_1010_0100;
   wire          combo3_1010_0110;
   wire          combo3_1010_1000;
   wire          combo3_1010_1001;
   wire          combo3_1010_1010;
   wire          combo3_1010_1011;
   wire          combo3_1010_1100;
   wire          combo3_1010_1101;
   wire          combo3_1011_0010;
   wire          combo3_1011_0011;
   wire          combo3_1011_0100;
   wire          combo3_1011_0101;
   wire          combo3_1011_0110;
   wire          combo3_1011_0111;
   wire          combo3_1100_0000;
   wire          combo3_1100_0001;
   wire          combo3_1100_0010;
   wire          combo3_1100_0011;
   wire          combo3_1100_0100;
   wire          combo3_1100_0111;
   wire          combo3_1100_1000;
   wire          combo3_1100_1001;
   wire          combo3_1100_1010;
   wire          combo3_1100_1101;
   wire          combo3_1100_1110;
   wire          combo3_1100_1111;
   wire          combo3_1101_0010;
   wire          combo3_1101_0011;
   wire          combo3_1101_0100;
   wire          combo3_1101_0101;
   wire          combo3_1101_0110;
   wire          combo3_1101_0111;
   wire          combo3_1101_1100;
   wire          combo3_1101_1101;
   wire          combo3_1101_1110;
   wire          combo3_1110_0000;
   wire          combo3_1110_0100;
   wire          combo3_1110_0101;
   wire          combo3_1110_0110;
   wire          combo3_1110_1000;
   wire          combo3_1110_1010;
   wire          combo3_1110_1101;
   wire          combo3_1111_0000;
   wire          combo3_1111_0001;
   wire          combo3_1111_0010;
   wire          combo3_1111_0100;
   wire          combo3_1111_1000;
   wire          combo3_1111_1001;
   wire          combo3_1111_1010;
   wire          combo3_1111_1100;
   wire          combo3_1111_1110;
   wire [0:7]    e_00_b;
   wire [0:7]    e_01_b;
   wire [0:7]    e_02_b;
   wire [0:7]    e_03_b;
   wire [0:7]    e_04_b;
   wire [0:7]    e_05_b;
   wire [0:7]    e_06_b;
   wire [0:7]    e_07_b;
   wire [0:7]    e_08_b;
   wire [0:7]    e_09_b;
   wire [0:7]    e_10_b;
   wire [0:7]    e_11_b;
   wire [0:7]    e_12_b;
   wire [0:7]    e_13_b;
   wire [0:7]    e_14_b;
   wire [0:7]    e_15_b;
   wire [0:7]    e_16_b;
   wire [0:7]    e_17_b;
   wire [0:7]    e_18_b;
   wire [0:7]    e_19_b;
   wire [0:19]   e;
   wire [0:7]    r_00_b;
   wire [0:7]    r_01_b;
   wire [0:7]    r_02_b;
   wire [0:7]    r_03_b;
   wire [0:7]    r_04_b;
   wire [0:7]    r_05_b;
   wire [0:7]    r_06_b;
   wire [0:7]    r_07_b;
   wire [0:7]    r_08_b;
   wire [0:7]    r_09_b;
   wire [0:7]    r_10_b;
   wire [0:7]    r_11_b;
   wire [0:7]    r_12_b;
   wire [0:7]    r_13_b;
   wire [0:7]    r_14_b;
   wire [0:14]   r;
   
   
   assign dcd_00x = (~f[1]) & (~f[2]);
   assign dcd_01x = (~f[1]) & f[2];
   assign dcd_10x = f[1] & (~f[2]);
   assign dcd_11x = f[1] & f[2];
   
   assign dcd_000 = (~f[3]) & dcd_00x;
   assign dcd_001 = f[3] & dcd_00x;
   assign dcd_010 = (~f[3]) & dcd_01x;
   assign dcd_011 = f[3] & dcd_01x;
   assign dcd_100 = (~f[3]) & dcd_10x;
   assign dcd_101 = f[3] & dcd_10x;
   assign dcd_110 = (~f[3]) & dcd_11x;
   assign dcd_111 = f[3] & dcd_11x;
   
   
   assign combo2_1000 = (~f[5]) & (~f[6]);		
   assign combo2_0100 = (~f[5]) & f[6];		
   assign combo2_1100 = (~f[5]);		
   assign combo2_0010 = f[5] & (~f[6]);		
   assign combo2_1010 = (~f[6]);		
   assign combo2_0110 = f[5] ^ f[6];		
   assign combo2_1110 = (~(f[5] & f[6]));		
   assign combo2_0001 = f[5] & f[6];		
   assign combo2_1001 = (~(f[5] ^ f[6]));		
   assign combo2_0101 = f[6];		
   assign combo2_1101 = (~(f[5] & (~f[6])));		
   assign combo2_0011 = f[5];		
   assign combo2_1011 = (~((~f[5]) & f[6]));		
   assign combo2_0111 = (~((~f[5]) & (~f[6])));		
   
   
   assign combo2_1000_xxxx_b = (~((~f[4]) & combo2_1000));
   assign combo2_0100_xxxx_b = (~((~f[4]) & combo2_0100));
   assign combo2_1100_xxxx_b = (~((~f[4]) & combo2_1100));
   assign combo2_0010_xxxx_b = (~((~f[4]) & combo2_0010));
   assign combo2_1010_xxxx_b = (~((~f[4]) & combo2_1010));
   assign combo2_0110_xxxx_b = (~((~f[4]) & combo2_0110));
   assign combo2_1110_xxxx_b = (~((~f[4]) & combo2_1110));
   assign combo2_0001_xxxx_b = (~((~f[4]) & combo2_0001));
   assign combo2_1001_xxxx_b = (~((~f[4]) & combo2_1001));
   assign combo2_0101_xxxx_b = (~((~f[4]) & combo2_0101));
   assign combo2_1101_xxxx_b = (~((~f[4]) & combo2_1101));
   assign combo2_0011_xxxx_b = (~((~f[4]) & combo2_0011));
   assign combo2_1011_xxxx_b = (~((~f[4]) & combo2_1011));
   assign combo2_0111_xxxx_b = (~((~f[4]) & combo2_0111));
   
   assign combo2_xxxx_1000_b = (~(f[4] & combo2_1000));
   assign combo2_xxxx_0100_b = (~(f[4] & combo2_0100));
   assign combo2_xxxx_1100_b = (~(f[4] & combo2_1100));
   assign combo2_xxxx_0010_b = (~(f[4] & combo2_0010));
   assign combo2_xxxx_1010_b = (~(f[4] & combo2_1010));
   assign combo2_xxxx_0110_b = (~(f[4] & combo2_0110));
   assign combo2_xxxx_1110_b = (~(f[4] & combo2_1110));
   assign combo2_xxxx_0001_b = (~(f[4] & combo2_0001));
   assign combo2_xxxx_1001_b = (~(f[4] & combo2_1001));
   assign combo2_xxxx_0101_b = (~(f[4] & combo2_0101));
   assign combo2_xxxx_1101_b = (~(f[4] & combo2_1101));
   assign combo2_xxxx_0011_b = (~(f[4] & combo2_0011));
   assign combo2_xxxx_1011_b = (~(f[4] & combo2_1011));
   assign combo2_xxxx_0111_b = (~(f[4] & combo2_0111));
   
   assign combo3_0000_0001 = (~(combo2_xxxx_0001_b));		
   assign combo3_0000_0010 = (~(combo2_xxxx_0010_b));		
   assign combo3_0000_0011 = (~(combo2_xxxx_0011_b));		
   assign combo3_0000_0100 = (~(combo2_xxxx_0100_b));		
   assign combo3_0000_0101 = (~(combo2_xxxx_0101_b));		
   assign combo3_0000_0110 = (~(combo2_xxxx_0110_b));		
   assign combo3_0000_1001 = (~(combo2_xxxx_1001_b));		
   assign combo3_0000_1010 = (~(combo2_xxxx_1010_b));		
   assign combo3_0000_1011 = (~(combo2_xxxx_1011_b));		
   assign combo3_0000_1110 = (~(combo2_xxxx_1110_b));		
   assign combo3_0000_1111 = (~((~f[4])));		
   assign combo3_0001_0001 = (~((~combo2_0001)));		
   assign combo3_0001_0010 = (~(combo2_0001_xxxx_b & combo2_xxxx_0010_b));		
   assign combo3_0001_0100 = (~(combo2_0001_xxxx_b & combo2_xxxx_0100_b));		
   assign combo3_0001_0101 = (~(combo2_0001_xxxx_b & combo2_xxxx_0101_b));		
   assign combo3_0001_0111 = (~(combo2_0001_xxxx_b & combo2_xxxx_0111_b));		
   assign combo3_0001_1000 = (~(combo2_0001_xxxx_b & combo2_xxxx_1000_b));		
   assign combo3_0001_1010 = (~(combo2_0001_xxxx_b & combo2_xxxx_1010_b));		
   assign combo3_0001_1011 = (~(combo2_0001_xxxx_b & combo2_xxxx_1011_b));		
   assign combo3_0001_1100 = (~(combo2_0001_xxxx_b & combo2_xxxx_1100_b));		
   assign combo3_0001_1110 = (~(combo2_0001_xxxx_b & combo2_xxxx_1110_b));		
   assign combo3_0001_1111 = (~(combo2_0001_xxxx_b & (~f[4])));		
   assign combo3_0010_0000 = (~(combo2_0010_xxxx_b));		
   assign combo3_0010_0100 = (~(combo2_0010_xxxx_b & combo2_xxxx_0100_b));		
   assign combo3_0010_0101 = (~(combo2_0010_xxxx_b & combo2_xxxx_0101_b));		
   assign combo3_0010_0110 = (~(combo2_0010_xxxx_b & combo2_xxxx_0110_b));		
   assign combo3_0010_0111 = (~(combo2_0010_xxxx_b & combo2_xxxx_0111_b));		
   assign combo3_0010_1000 = (~(combo2_0010_xxxx_b & combo2_xxxx_1000_b));		
   assign combo3_0010_1001 = (~(combo2_0010_xxxx_b & combo2_xxxx_1001_b));		
   assign combo3_0010_1101 = (~(combo2_0010_xxxx_b & combo2_xxxx_1101_b));		
   assign combo3_0011_0000 = (~(combo2_0011_xxxx_b));		
   assign combo3_0011_0001 = (~(combo2_0011_xxxx_b & combo2_xxxx_0001_b));		
   assign combo3_0011_0011 = (~((~combo2_0011)));		
   assign combo3_0011_0101 = (~(combo2_0011_xxxx_b & combo2_xxxx_0101_b));		
   assign combo3_0011_1000 = (~(combo2_0011_xxxx_b & combo2_xxxx_1000_b));		
   assign combo3_0011_1001 = (~(combo2_0011_xxxx_b & combo2_xxxx_1001_b));		
   assign combo3_0011_1010 = (~(combo2_0011_xxxx_b & combo2_xxxx_1010_b));		
   assign combo3_0011_1011 = (~(combo2_0011_xxxx_b & combo2_xxxx_1011_b));		
   assign combo3_0011_1100 = (~(combo2_0011_xxxx_b & combo2_xxxx_1100_b));		
   assign combo3_0011_1110 = (~(combo2_0011_xxxx_b & combo2_xxxx_1110_b));		
   assign combo3_0011_1111 = (~(combo2_0011_xxxx_b & (~f[4])));		
   assign combo3_0100_0000 = (~(combo2_0100_xxxx_b));		
   assign combo3_0100_0011 = (~(combo2_0100_xxxx_b & combo2_xxxx_0011_b));		
   assign combo3_0100_0110 = (~(combo2_0100_xxxx_b & combo2_xxxx_0110_b));		
   assign combo3_0100_1000 = (~(combo2_0100_xxxx_b & combo2_xxxx_1000_b));		
   assign combo3_0100_1001 = (~(combo2_0100_xxxx_b & combo2_xxxx_1001_b));		
   assign combo3_0100_1010 = (~(combo2_0100_xxxx_b & combo2_xxxx_1010_b));		
   assign combo3_0100_1100 = (~(combo2_0100_xxxx_b & combo2_xxxx_1100_b));		
   assign combo3_0100_1101 = (~(combo2_0100_xxxx_b & combo2_xxxx_1101_b));		
   assign combo3_0100_1110 = (~(combo2_0100_xxxx_b & combo2_xxxx_1110_b));		
   assign combo3_0101_0000 = (~(combo2_0101_xxxx_b));		
   assign combo3_0101_0001 = (~(combo2_0101_xxxx_b & combo2_xxxx_0001_b));		
   assign combo3_0101_0010 = (~(combo2_0101_xxxx_b & combo2_xxxx_0010_b));		
   assign combo3_0101_0100 = (~(combo2_0101_xxxx_b & combo2_xxxx_0100_b));		
   assign combo3_0101_0101 = (~((~combo2_0101)));		
   assign combo3_0101_0110 = (~(combo2_0101_xxxx_b & combo2_xxxx_0110_b));		
   assign combo3_0101_1000 = (~(combo2_0101_xxxx_b & combo2_xxxx_1000_b));		
   assign combo3_0101_1011 = (~(combo2_0101_xxxx_b & combo2_xxxx_1011_b));		
   assign combo3_0101_1111 = (~(combo2_0101_xxxx_b & (~f[4])));		
   assign combo3_0110_0000 = (~(combo2_0110_xxxx_b));		
   assign combo3_0110_0010 = (~(combo2_0110_xxxx_b & combo2_xxxx_0010_b));		
   assign combo3_0110_0011 = (~(combo2_0110_xxxx_b & combo2_xxxx_0011_b));		
   assign combo3_0110_0110 = (~((~combo2_0110)));		
   assign combo3_0110_0111 = (~(combo2_0110_xxxx_b & combo2_xxxx_0111_b));		
   assign combo3_0110_1000 = (~(combo2_0110_xxxx_b & combo2_xxxx_1000_b));		
   assign combo3_0110_1010 = (~(combo2_0110_xxxx_b & combo2_xxxx_1010_b));		
   assign combo3_0110_1011 = (~(combo2_0110_xxxx_b & combo2_xxxx_1011_b));		
   assign combo3_0110_1100 = (~(combo2_0110_xxxx_b & combo2_xxxx_1100_b));		
   assign combo3_0110_1101 = (~(combo2_0110_xxxx_b & combo2_xxxx_1101_b));		
   assign combo3_0111_0000 = (~(combo2_0111_xxxx_b));		
   assign combo3_0111_0001 = (~(combo2_0111_xxxx_b & combo2_xxxx_0001_b));		
   assign combo3_0111_0101 = (~(combo2_0111_xxxx_b & combo2_xxxx_0101_b));		
   assign combo3_0111_0110 = (~(combo2_0111_xxxx_b & combo2_xxxx_0110_b));		
   assign combo3_0111_1000 = (~(combo2_0111_xxxx_b & combo2_xxxx_1000_b));		
   assign combo3_0111_1001 = (~(combo2_0111_xxxx_b & combo2_xxxx_1001_b));		
   assign combo3_0111_1010 = (~(combo2_0111_xxxx_b & combo2_xxxx_1010_b));		
   assign combo3_0111_1011 = (~(combo2_0111_xxxx_b & combo2_xxxx_1011_b));		
   assign combo3_0111_1101 = (~(combo2_0111_xxxx_b & combo2_xxxx_1101_b));		
   assign combo3_0111_1111 = (~(combo2_0111_xxxx_b & (~f[4])));		
   assign combo3_1000_0000 = (~(combo2_1000_xxxx_b));		
   assign combo3_1000_0001 = (~(combo2_1000_xxxx_b & combo2_xxxx_0001_b));		
   assign combo3_1000_0011 = (~(combo2_1000_xxxx_b & combo2_xxxx_0011_b));		
   assign combo3_1000_0100 = (~(combo2_1000_xxxx_b & combo2_xxxx_0100_b));		
   assign combo3_1000_0101 = (~(combo2_1000_xxxx_b & combo2_xxxx_0101_b));		
   assign combo3_1000_1010 = (~(combo2_1000_xxxx_b & combo2_xxxx_1010_b));		
   assign combo3_1000_1100 = (~(combo2_1000_xxxx_b & combo2_xxxx_1100_b));		
   assign combo3_1000_1101 = (~(combo2_1000_xxxx_b & combo2_xxxx_1101_b));		
   assign combo3_1001_0100 = (~(combo2_1001_xxxx_b & combo2_xxxx_0100_b));		
   assign combo3_1001_0110 = (~(combo2_1001_xxxx_b & combo2_xxxx_0110_b));		
   assign combo3_1001_0111 = (~(combo2_1001_xxxx_b & combo2_xxxx_0111_b));		
   assign combo3_1001_1000 = (~(combo2_1001_xxxx_b & combo2_xxxx_1000_b));		
   assign combo3_1001_1001 = (~((~combo2_1001)));		
   assign combo3_1001_1010 = (~(combo2_1001_xxxx_b & combo2_xxxx_1010_b));		
   assign combo3_1001_1011 = (~(combo2_1001_xxxx_b & combo2_xxxx_1011_b));		
   assign combo3_1001_1111 = (~(combo2_1001_xxxx_b & (~f[4])));		
   assign combo3_1010_0100 = (~(combo2_1010_xxxx_b & combo2_xxxx_0100_b));		
   assign combo3_1010_0110 = (~(combo2_1010_xxxx_b & combo2_xxxx_0110_b));		
   assign combo3_1010_1000 = (~(combo2_1010_xxxx_b & combo2_xxxx_1000_b));		
   assign combo3_1010_1001 = (~(combo2_1010_xxxx_b & combo2_xxxx_1001_b));		
   assign combo3_1010_1010 = (~((~combo2_1010)));		
   assign combo3_1010_1011 = (~(combo2_1010_xxxx_b & combo2_xxxx_1011_b));		
   assign combo3_1010_1100 = (~(combo2_1010_xxxx_b & combo2_xxxx_1100_b));		
   assign combo3_1010_1101 = (~(combo2_1010_xxxx_b & combo2_xxxx_1101_b));		
   assign combo3_1011_0010 = (~(combo2_1011_xxxx_b & combo2_xxxx_0010_b));		
   assign combo3_1011_0011 = (~(combo2_1011_xxxx_b & combo2_xxxx_0011_b));		
   assign combo3_1011_0100 = (~(combo2_1011_xxxx_b & combo2_xxxx_0100_b));		
   assign combo3_1011_0101 = (~(combo2_1011_xxxx_b & combo2_xxxx_0101_b));		
   assign combo3_1011_0110 = (~(combo2_1011_xxxx_b & combo2_xxxx_0110_b));		
   assign combo3_1011_0111 = (~(combo2_1011_xxxx_b & combo2_xxxx_0111_b));		
   assign combo3_1100_0000 = (~(combo2_1100_xxxx_b));		
   assign combo3_1100_0001 = (~(combo2_1100_xxxx_b & combo2_xxxx_0001_b));		
   assign combo3_1100_0010 = (~(combo2_1100_xxxx_b & combo2_xxxx_0010_b));		
   assign combo3_1100_0011 = (~(combo2_1100_xxxx_b & combo2_xxxx_0011_b));		
   assign combo3_1100_0100 = (~(combo2_1100_xxxx_b & combo2_xxxx_0100_b));		
   assign combo3_1100_0111 = (~(combo2_1100_xxxx_b & combo2_xxxx_0111_b));		
   assign combo3_1100_1000 = (~(combo2_1100_xxxx_b & combo2_xxxx_1000_b));		
   assign combo3_1100_1001 = (~(combo2_1100_xxxx_b & combo2_xxxx_1001_b));		
   assign combo3_1100_1010 = (~(combo2_1100_xxxx_b & combo2_xxxx_1010_b));		
   assign combo3_1100_1101 = (~(combo2_1100_xxxx_b & combo2_xxxx_1101_b));		
   assign combo3_1100_1110 = (~(combo2_1100_xxxx_b & combo2_xxxx_1110_b));		
   assign combo3_1100_1111 = (~(combo2_1100_xxxx_b & (~f[4])));		
   assign combo3_1101_0010 = (~(combo2_1101_xxxx_b & combo2_xxxx_0010_b));		
   assign combo3_1101_0011 = (~(combo2_1101_xxxx_b & combo2_xxxx_0011_b));		
   assign combo3_1101_0100 = (~(combo2_1101_xxxx_b & combo2_xxxx_0100_b));		
   assign combo3_1101_0101 = (~(combo2_1101_xxxx_b & combo2_xxxx_0101_b));		
   assign combo3_1101_0110 = (~(combo2_1101_xxxx_b & combo2_xxxx_0110_b));		
   assign combo3_1101_0111 = (~(combo2_1101_xxxx_b & combo2_xxxx_0111_b));		
   assign combo3_1101_1100 = (~(combo2_1101_xxxx_b & combo2_xxxx_1100_b));		
   assign combo3_1101_1101 = (~((~combo2_1101)));		
   assign combo3_1101_1110 = (~(combo2_1101_xxxx_b & combo2_xxxx_1110_b));		
   assign combo3_1110_0000 = (~(combo2_1110_xxxx_b));		
   assign combo3_1110_0100 = (~(combo2_1110_xxxx_b & combo2_xxxx_0100_b));		
   assign combo3_1110_0101 = (~(combo2_1110_xxxx_b & combo2_xxxx_0101_b));		
   assign combo3_1110_0110 = (~(combo2_1110_xxxx_b & combo2_xxxx_0110_b));		
   assign combo3_1110_1000 = (~(combo2_1110_xxxx_b & combo2_xxxx_1000_b));		
   assign combo3_1110_1010 = (~(combo2_1110_xxxx_b & combo2_xxxx_1010_b));		
   assign combo3_1110_1101 = (~(combo2_1110_xxxx_b & combo2_xxxx_1101_b));		
   assign combo3_1111_0000 = (~(f[4]));		
   assign combo3_1111_0001 = (~(f[4] & combo2_xxxx_0001_b));		
   assign combo3_1111_0010 = (~(f[4] & combo2_xxxx_0010_b));		
   assign combo3_1111_0100 = (~(f[4] & combo2_xxxx_0100_b));		
   assign combo3_1111_1000 = (~(f[4] & combo2_xxxx_1000_b));		
   assign combo3_1111_1001 = (~(f[4] & combo2_xxxx_1001_b));		
   assign combo3_1111_1010 = (~(f[4] & combo2_xxxx_1010_b));		
   assign combo3_1111_1100 = (~(f[4] & combo2_xxxx_1100_b));		
   assign combo3_1111_1110 = (~(f[4] & combo2_xxxx_1110_b));		
   
   
   assign e_00_b[0] = (~(dcd_000 & tiup));
   assign e_00_b[1] = (~(dcd_001 & tiup));
   assign e_00_b[2] = (~(dcd_010 & combo3_1111_1100));
   assign e_00_b[3] = (~(dcd_011 & tidn));
   assign e_00_b[4] = (~(dcd_100 & tidn));
   assign e_00_b[5] = (~(dcd_101 & tidn));
   assign e_00_b[6] = (~(dcd_110 & tidn));
   assign e_00_b[7] = (~(dcd_111 & tidn));
   
   assign e[0] = (~(e_00_b[0] & e_00_b[1] & e_00_b[2] & e_00_b[3] & e_00_b[4] & e_00_b[5] & e_00_b[6] & e_00_b[7]));
   
   assign e_01_b[0] = (~(dcd_000 & tiup));
   assign e_01_b[1] = (~(dcd_001 & combo3_1100_0000));
   assign e_01_b[2] = (~(dcd_010 & combo3_0000_0011));
   assign e_01_b[3] = (~(dcd_011 & tiup));
   assign e_01_b[4] = (~(dcd_100 & combo3_1111_1110));
   assign e_01_b[5] = (~(dcd_101 & tidn));
   assign e_01_b[6] = (~(dcd_110 & tidn));
   assign e_01_b[7] = (~(dcd_111 & tidn));
   
   assign e[1] = (~(e_01_b[0] & e_01_b[1] & e_01_b[2] & e_01_b[3] & e_01_b[4] & e_01_b[5] & e_01_b[6] & e_01_b[7]));
   
   assign e_02_b[0] = (~(dcd_000 & combo3_1111_1000));
   assign e_02_b[1] = (~(dcd_001 & combo3_0011_1110));
   assign e_02_b[2] = (~(dcd_010 & combo3_0000_0011));
   assign e_02_b[3] = (~(dcd_011 & combo3_1111_1100));
   assign e_02_b[4] = (~(dcd_100 & combo3_0000_0001));
   assign e_02_b[5] = (~(dcd_101 & tiup));
   assign e_02_b[6] = (~(dcd_110 & combo3_1100_0000));
   assign e_02_b[7] = (~(dcd_111 & tidn));
   
   assign e[2] = (~(e_02_b[0] & e_02_b[1] & e_02_b[2] & e_02_b[3] & e_02_b[4] & e_02_b[5] & e_02_b[6] & e_02_b[7]));
   
   assign e_03_b[0] = (~(dcd_000 & combo3_1110_0110));
   assign e_03_b[1] = (~(dcd_001 & combo3_0011_0001));
   assign e_03_b[2] = (~(dcd_010 & combo3_1100_0011));
   assign e_03_b[3] = (~(dcd_011 & combo3_1100_0011));
   assign e_03_b[4] = (~(dcd_100 & combo3_1100_0001));
   assign e_03_b[5] = (~(dcd_101 & combo3_1111_0000));
   assign e_03_b[6] = (~(dcd_110 & combo3_0011_1111));
   assign e_03_b[7] = (~(dcd_111 & combo3_1000_0000));
   
   assign e[3] = (~(e_03_b[0] & e_03_b[1] & e_03_b[2] & e_03_b[3] & e_03_b[4] & e_03_b[5] & e_03_b[6] & e_03_b[7]));
   
   assign e_04_b[0] = (~(dcd_000 & combo3_1101_0101));
   assign e_04_b[1] = (~(dcd_001 & combo3_0010_1101));
   assign e_04_b[2] = (~(dcd_010 & combo3_1011_0011));
   assign e_04_b[3] = (~(dcd_011 & combo3_0011_0011));
   assign e_04_b[4] = (~(dcd_100 & combo3_0011_0001));
   assign e_04_b[5] = (~(dcd_101 & combo3_1100_1110));
   assign e_04_b[6] = (~(dcd_110 & combo3_0011_1100));
   assign e_04_b[7] = (~(dcd_111 & combo3_0111_1000));
   
   assign e[4] = (~(e_04_b[0] & e_04_b[1] & e_04_b[2] & e_04_b[3] & e_04_b[4] & e_04_b[5] & e_04_b[6] & e_04_b[7]));
   
   assign e_05_b[0] = (~(dcd_000 & combo3_1000_0011));
   assign e_05_b[1] = (~(dcd_001 & combo3_1001_1011));
   assign e_05_b[2] = (~(dcd_010 & combo3_0110_1010));
   assign e_05_b[3] = (~(dcd_011 & combo3_1010_1010));
   assign e_05_b[4] = (~(dcd_100 & combo3_1010_1101));
   assign e_05_b[5] = (~(dcd_101 & combo3_0010_1101));
   assign e_05_b[6] = (~(dcd_110 & combo3_1011_0010));
   assign e_05_b[7] = (~(dcd_111 & combo3_0110_0110));
   
   assign e[5] = (~(e_05_b[0] & e_05_b[1] & e_05_b[2] & e_05_b[3] & e_05_b[4] & e_05_b[5] & e_05_b[6] & e_05_b[7]));
   
   assign e_06_b[0] = (~(dcd_000 & combo3_1000_0100));
   assign e_06_b[1] = (~(dcd_001 & combo3_1010_1001));
   assign e_06_b[2] = (~(dcd_010 & combo3_0011_1000));
   assign e_06_b[3] = (~(dcd_011 & tidn));
   assign e_06_b[4] = (~(dcd_100 & combo3_0011_1001));
   assign e_06_b[5] = (~(dcd_101 & combo3_1001_1001));
   assign e_06_b[6] = (~(dcd_110 & combo3_0010_1001));
   assign e_06_b[7] = (~(dcd_111 & combo3_0101_0101));
   
   assign e[6] = (~(e_06_b[0] & e_06_b[1] & e_06_b[2] & e_06_b[3] & e_06_b[4] & e_06_b[5] & e_06_b[6] & e_06_b[7]));
   
   assign e_07_b[0] = (~(dcd_000 & combo3_1001_1001));
   assign e_07_b[1] = (~(dcd_001 & combo3_1000_1100));
   assign e_07_b[2] = (~(dcd_010 & combo3_1010_0110));
   assign e_07_b[3] = (~(dcd_011 & tidn));
   assign e_07_b[4] = (~(dcd_100 & combo3_1100_1010));
   assign e_07_b[5] = (~(dcd_101 & combo3_1010_1011));
   assign e_07_b[6] = (~(dcd_110 & combo3_0110_0011));
   assign e_07_b[7] = (~(dcd_111 & combo3_1000_0000));
   
   assign e[7] = (~(e_07_b[0] & e_07_b[1] & e_07_b[2] & e_07_b[3] & e_07_b[4] & e_07_b[5] & e_07_b[6] & e_07_b[7]));
   
   assign e_08_b[0] = (~(dcd_000 & combo3_1000_1101));
   assign e_08_b[1] = (~(dcd_001 & combo3_0111_0101));
   assign e_08_b[2] = (~(dcd_010 & combo3_1111_0001));
   assign e_08_b[3] = (~(dcd_011 & combo3_0000_0011));
   assign e_08_b[4] = (~(dcd_100 & combo3_0101_1000));
   assign e_08_b[5] = (~(dcd_101 & combo3_0000_0110));
   assign e_08_b[6] = (~(dcd_110 & combo3_1101_0010));
   assign e_08_b[7] = (~(dcd_111 & combo3_0110_0000));
   
   assign e[8] = (~(e_08_b[0] & e_08_b[1] & e_08_b[2] & e_08_b[3] & e_08_b[4] & e_08_b[5] & e_08_b[6] & e_08_b[7]));
   
   assign e_09_b[0] = (~(dcd_000 & combo3_1010_1100));
   assign e_09_b[1] = (~(dcd_001 & combo3_0111_0001));
   assign e_09_b[2] = (~(dcd_010 & combo3_0001_0100));
   assign e_09_b[3] = (~(dcd_011 & combo3_1000_0101));
   assign e_09_b[4] = (~(dcd_100 & combo3_1111_0100));
   assign e_09_b[5] = (~(dcd_101 & combo3_0000_1010));
   assign e_09_b[6] = (~(dcd_110 & combo3_0111_1001));
   assign e_09_b[7] = (~(dcd_111 & combo3_0101_0000));
   
   assign e[9] = (~(e_09_b[0] & e_09_b[1] & e_09_b[2] & e_09_b[3] & e_09_b[4] & e_09_b[5] & e_09_b[6] & e_09_b[7]));
   
   assign e_10_b[0] = (~(dcd_000 & combo3_1010_0100));
   assign e_10_b[1] = (~(dcd_001 & combo3_0001_1000));
   assign e_10_b[2] = (~(dcd_010 & combo3_0000_0101));
   assign e_10_b[3] = (~(dcd_011 & combo3_0100_1001));
   assign e_10_b[4] = (~(dcd_100 & combo3_0001_1110));
   assign e_10_b[5] = (~(dcd_101 & combo3_0001_1011));
   assign e_10_b[6] = (~(dcd_110 & combo3_0111_1010));
   assign e_10_b[7] = (~(dcd_111 & combo3_0001_1100));
   
   assign e[10] = (~(e_10_b[0] & e_10_b[1] & e_10_b[2] & e_10_b[3] & e_10_b[4] & e_10_b[5] & e_10_b[6] & e_10_b[7]));
   
   assign e_11_b[0] = (~(dcd_000 & combo3_1110_1010));
   assign e_11_b[1] = (~(dcd_001 & combo3_1100_0010));
   assign e_11_b[2] = (~(dcd_010 & combo3_1010_1100));
   assign e_11_b[3] = (~(dcd_011 & combo3_1011_0110));
   assign e_11_b[4] = (~(dcd_100 & combo3_1011_0011));
   assign e_11_b[5] = (~(dcd_101 & combo3_0011_0101));
   assign e_11_b[6] = (~(dcd_110 & combo3_0100_1001));
   assign e_11_b[7] = (~(dcd_111 & combo3_0010_1000));
   
   assign e[11] = (~(e_11_b[0] & e_11_b[1] & e_11_b[2] & e_11_b[3] & e_11_b[4] & e_11_b[5] & e_11_b[6] & e_11_b[7]));
   
   assign e_12_b[0] = (~(dcd_000 & combo3_1111_1010));
   assign e_12_b[1] = (~(dcd_001 & combo3_1110_0100));
   assign e_12_b[2] = (~(dcd_010 & combo3_0010_0100));
   assign e_12_b[3] = (~(dcd_011 & combo3_1100_1001));
   assign e_12_b[4] = (~(dcd_100 & combo3_0111_1111));
   assign e_12_b[5] = (~(dcd_101 & combo3_1111_0100));
   assign e_12_b[6] = (~(dcd_110 & combo3_1011_0111));
   assign e_12_b[7] = (~(dcd_111 & combo3_1100_1010));
   
   assign e[12] = (~(e_12_b[0] & e_12_b[1] & e_12_b[2] & e_12_b[3] & e_12_b[4] & e_12_b[5] & e_12_b[6] & e_12_b[7]));
   
   assign e_13_b[0] = (~(dcd_000 & combo3_1001_1000));
   assign e_13_b[1] = (~(dcd_001 & combo3_0101_1011));
   assign e_13_b[2] = (~(dcd_010 & combo3_1101_1100));
   assign e_13_b[3] = (~(dcd_011 & combo3_0000_0110));
   assign e_13_b[4] = (~(dcd_100 & combo3_0100_0011));
   assign e_13_b[5] = (~(dcd_101 & combo3_1110_1000));
   assign e_13_b[6] = (~(dcd_110 & combo3_1111_1110));
   assign e_13_b[7] = (~(dcd_111 & combo3_1001_1010));
   
   assign e[13] = (~(e_13_b[0] & e_13_b[1] & e_13_b[2] & e_13_b[3] & e_13_b[4] & e_13_b[5] & e_13_b[6] & e_13_b[7]));
   
   assign e_14_b[0] = (~(dcd_000 & combo3_0101_0100));
   assign e_14_b[1] = (~(dcd_001 & combo3_0010_0110));
   assign e_14_b[2] = (~(dcd_010 & combo3_0101_0000));
   assign e_14_b[3] = (~(dcd_011 & combo3_0111_0000));
   assign e_14_b[4] = (~(dcd_100 & combo3_0010_1101));
   assign e_14_b[5] = (~(dcd_101 & combo3_1101_0100));
   assign e_14_b[6] = (~(dcd_110 & combo3_1100_1000));
   assign e_14_b[7] = (~(dcd_111 & combo3_0110_1000));
   
   assign e[14] = (~(e_14_b[0] & e_14_b[1] & e_14_b[2] & e_14_b[3] & e_14_b[4] & e_14_b[5] & e_14_b[6] & e_14_b[7]));
   
   assign e_15_b[0] = (~(dcd_000 & combo3_0101_1011));
   assign e_15_b[1] = (~(dcd_001 & combo3_0010_0000));
   assign e_15_b[2] = (~(dcd_010 & combo3_1101_0110));
   assign e_15_b[3] = (~(dcd_011 & combo3_1000_0001));
   assign e_15_b[4] = (~(dcd_100 & combo3_1001_0110));
   assign e_15_b[5] = (~(dcd_101 & combo3_1110_0101));
   assign e_15_b[6] = (~(dcd_110 & combo3_0100_1110));
   assign e_15_b[7] = (~(dcd_111 & combo3_1110_0000));
   
   assign e[15] = (~(e_15_b[0] & e_15_b[1] & e_15_b[2] & e_15_b[3] & e_15_b[4] & e_15_b[5] & e_15_b[6] & e_15_b[7]));
   
   assign e_16_b[0] = (~(dcd_000 & combo3_0100_1000));
   assign e_16_b[1] = (~(dcd_001 & combo3_0010_0101));
   assign e_16_b[2] = (~(dcd_010 & combo3_1001_0111));
   assign e_16_b[3] = (~(dcd_011 & combo3_0011_1010));
   assign e_16_b[4] = (~(dcd_100 & combo3_0000_0101));
   assign e_16_b[5] = (~(dcd_101 & combo3_1110_0100));
   assign e_16_b[6] = (~(dcd_110 & combo3_0000_1111));
   assign e_16_b[7] = (~(dcd_111 & combo3_0000_0100));
   
   assign e[16] = (~(e_16_b[0] & e_16_b[1] & e_16_b[2] & e_16_b[3] & e_16_b[4] & e_16_b[5] & e_16_b[6] & e_16_b[7]));
   
   assign e_17_b[0] = (~(dcd_000 & combo3_0000_1011));
   assign e_17_b[1] = (~(dcd_001 & combo3_1100_1111));
   assign e_17_b[2] = (~(dcd_010 & combo3_0000_1011));
   assign e_17_b[3] = (~(dcd_011 & combo3_0010_0000));
   assign e_17_b[4] = (~(dcd_100 & combo3_1101_0011));
   assign e_17_b[5] = (~(dcd_101 & combo3_0010_1000));
   assign e_17_b[6] = (~(dcd_110 & combo3_1111_0010));
   assign e_17_b[7] = (~(dcd_111 & combo3_0100_0110));
   
   assign e[17] = (~(e_17_b[0] & e_17_b[1] & e_17_b[2] & e_17_b[3] & e_17_b[4] & e_17_b[5] & e_17_b[6] & e_17_b[7]));
   
   assign e_18_b[0] = (~(dcd_000 & combo3_0000_1001));
   assign e_18_b[1] = (~(dcd_001 & combo3_1100_1101));
   assign e_18_b[2] = (~(dcd_010 & combo3_0000_1010));
   assign e_18_b[3] = (~(dcd_011 & combo3_0000_0001));
   assign e_18_b[4] = (~(dcd_100 & combo3_0101_0000));
   assign e_18_b[5] = (~(dcd_101 & combo3_1001_0100));
   assign e_18_b[6] = (~(dcd_110 & combo3_0101_0010));
   assign e_18_b[7] = (~(dcd_111 & tidn));
   
   assign e[18] = (~(e_18_b[0] & e_18_b[1] & e_18_b[2] & e_18_b[3] & e_18_b[4] & e_18_b[5] & e_18_b[6] & e_18_b[7]));
   
   assign e_19_b[0] = (~(dcd_000 & combo3_0111_1111));
   assign e_19_b[1] = (~(dcd_001 & tiup));
   assign e_19_b[2] = (~(dcd_010 & tiup));
   assign e_19_b[3] = (~(dcd_011 & tiup));
   assign e_19_b[4] = (~(dcd_100 & tiup));
   assign e_19_b[5] = (~(dcd_101 & tiup));
   assign e_19_b[6] = (~(dcd_110 & tiup));
   assign e_19_b[7] = (~(dcd_111 & tiup));
   
   assign e[19] = (~(e_19_b[0] & e_19_b[1] & e_19_b[2] & e_19_b[3] & e_19_b[4] & e_19_b[5] & e_19_b[6] & e_19_b[7]));
   
   
   assign r_00_b[0] = (~(dcd_000 & tiup));
   assign r_00_b[1] = (~(dcd_001 & tiup));
   assign r_00_b[2] = (~(dcd_010 & tiup));
   assign r_00_b[3] = (~(dcd_011 & combo3_1110_0000));
   assign r_00_b[4] = (~(dcd_100 & tidn));
   assign r_00_b[5] = (~(dcd_101 & tidn));
   assign r_00_b[6] = (~(dcd_110 & tidn));
   assign r_00_b[7] = (~(dcd_111 & tidn));
   
   assign r[0] = (~(r_00_b[0] & r_00_b[1] & r_00_b[2] & r_00_b[3] & r_00_b[4] & r_00_b[5] & r_00_b[6] & r_00_b[7]));
   
   assign r_01_b[0] = (~(dcd_000 & tiup));
   assign r_01_b[1] = (~(dcd_001 & combo3_1100_0000));
   assign r_01_b[2] = (~(dcd_010 & tidn));
   assign r_01_b[3] = (~(dcd_011 & combo3_0001_1111));
   assign r_01_b[4] = (~(dcd_100 & tiup));
   assign r_01_b[5] = (~(dcd_101 & tiup));
   assign r_01_b[6] = (~(dcd_110 & tiup));
   assign r_01_b[7] = (~(dcd_111 & tiup));
   
   assign r[1] = (~(r_01_b[0] & r_01_b[1] & r_01_b[2] & r_01_b[3] & r_01_b[4] & r_01_b[5] & r_01_b[6] & r_01_b[7]));
   
   assign r_02_b[0] = (~(dcd_000 & combo3_1111_0000));
   assign r_02_b[1] = (~(dcd_001 & combo3_0011_1111));
   assign r_02_b[2] = (~(dcd_010 & combo3_1000_0000));
   assign r_02_b[3] = (~(dcd_011 & combo3_0001_1111));
   assign r_02_b[4] = (~(dcd_100 & tiup));
   assign r_02_b[5] = (~(dcd_101 & combo3_1000_0000));
   assign r_02_b[6] = (~(dcd_110 & tidn));
   assign r_02_b[7] = (~(dcd_111 & tidn));
   
   assign r[2] = (~(r_02_b[0] & r_02_b[1] & r_02_b[2] & r_02_b[3] & r_02_b[4] & r_02_b[5] & r_02_b[6] & r_02_b[7]));
   
   assign r_03_b[0] = (~(dcd_000 & combo3_1100_1110));
   assign r_03_b[1] = (~(dcd_001 & combo3_0011_1000));
   assign r_03_b[2] = (~(dcd_010 & combo3_0111_1000));
   assign r_03_b[3] = (~(dcd_011 & combo3_0001_1111));
   assign r_03_b[4] = (~(dcd_100 & combo3_1000_0000));
   assign r_03_b[5] = (~(dcd_101 & combo3_0111_1111));
   assign r_03_b[6] = (~(dcd_110 & combo3_1100_0000));
   assign r_03_b[7] = (~(dcd_111 & tidn));
   
   assign r[3] = (~(r_03_b[0] & r_03_b[1] & r_03_b[2] & r_03_b[3] & r_03_b[4] & r_03_b[5] & r_03_b[6] & r_03_b[7]));
   
   assign r_04_b[0] = (~(dcd_000 & combo3_1010_1101));
   assign r_04_b[1] = (~(dcd_001 & combo3_0010_0110));
   assign r_04_b[2] = (~(dcd_010 & combo3_0110_0111));
   assign r_04_b[3] = (~(dcd_011 & combo3_0001_1000));
   assign r_04_b[4] = (~(dcd_100 & combo3_0111_0000));
   assign r_04_b[5] = (~(dcd_101 & combo3_0111_1000));
   assign r_04_b[6] = (~(dcd_110 & combo3_0011_1111));
   assign r_04_b[7] = (~(dcd_111 & combo3_1000_0000));
   
   assign r[4] = (~(r_04_b[0] & r_04_b[1] & r_04_b[2] & r_04_b[3] & r_04_b[4] & r_04_b[5] & r_04_b[6] & r_04_b[7]));
   
   assign r_05_b[0] = (~(dcd_000 & combo3_1111_1001));
   assign r_05_b[1] = (~(dcd_001 & combo3_1011_0101));
   assign r_05_b[2] = (~(dcd_010 & combo3_0101_0110));
   assign r_05_b[3] = (~(dcd_011 & combo3_1001_0110));
   assign r_05_b[4] = (~(dcd_100 & combo3_0110_1100));
   assign r_05_b[5] = (~(dcd_101 & combo3_0110_0111));
   assign r_05_b[6] = (~(dcd_110 & combo3_0011_1000));
   assign r_05_b[7] = (~(dcd_111 & combo3_0111_0000));
   
   assign r[5] = (~(r_05_b[0] & r_05_b[1] & r_05_b[2] & r_05_b[3] & r_05_b[4] & r_05_b[5] & r_05_b[6] & r_05_b[7]));
   
   assign r_06_b[0] = (~(dcd_000 & combo3_0001_1010));
   assign r_06_b[1] = (~(dcd_001 & combo3_1101_1110));
   assign r_06_b[2] = (~(dcd_010 & combo3_0011_1100));
   assign r_06_b[3] = (~(dcd_011 & combo3_0100_1101));
   assign r_06_b[4] = (~(dcd_100 & combo3_0100_1010));
   assign r_06_b[5] = (~(dcd_101 & combo3_0101_0100));
   assign r_06_b[6] = (~(dcd_110 & combo3_1011_0110));
   assign r_06_b[7] = (~(dcd_111 & combo3_0100_1100));
   
   assign r[6] = (~(r_06_b[0] & r_06_b[1] & r_06_b[2] & r_06_b[3] & r_06_b[4] & r_06_b[5] & r_06_b[6] & r_06_b[7]));
   
   assign r_07_b[0] = (~(dcd_000 & combo3_0010_1101));
   assign r_07_b[1] = (~(dcd_001 & combo3_1001_1001));
   assign r_07_b[2] = (~(dcd_010 & combo3_1100_0100));
   assign r_07_b[3] = (~(dcd_011 & combo3_1001_0110));
   assign r_07_b[4] = (~(dcd_100 & combo3_0001_1111));
   assign r_07_b[5] = (~(dcd_101 & combo3_0000_1110));
   assign r_07_b[6] = (~(dcd_110 & combo3_0110_1101));
   assign r_07_b[7] = (~(dcd_111 & combo3_0110_1010));
   
   assign r[7] = (~(r_07_b[0] & r_07_b[1] & r_07_b[2] & r_07_b[3] & r_07_b[4] & r_07_b[5] & r_07_b[6] & r_07_b[7]));
   
   assign r_08_b[0] = (~(dcd_000 & combo3_0000_0010));
   assign r_08_b[1] = (~(dcd_001 & combo3_1011_0101));
   assign r_08_b[2] = (~(dcd_010 & combo3_1100_1001));
   assign r_08_b[3] = (~(dcd_011 & combo3_1100_1101));
   assign r_08_b[4] = (~(dcd_100 & combo3_1001_1111));
   assign r_08_b[5] = (~(dcd_101 & combo3_0001_0010));
   assign r_08_b[6] = (~(dcd_110 & combo3_1011_0110));
   assign r_08_b[7] = (~(dcd_111 & combo3_0011_1111));
   
   assign r[8] = (~(r_08_b[0] & r_08_b[1] & r_08_b[2] & r_08_b[3] & r_08_b[4] & r_08_b[5] & r_08_b[6] & r_08_b[7]));
   
   assign r_09_b[0] = (~(dcd_000 & combo3_0100_1010));
   assign r_09_b[1] = (~(dcd_001 & combo3_0011_0001));
   assign r_09_b[2] = (~(dcd_010 & combo3_1101_1101));
   assign r_09_b[3] = (~(dcd_011 & combo3_1100_0111));
   assign r_09_b[4] = (~(dcd_100 & combo3_0101_1111));
   assign r_09_b[5] = (~(dcd_101 & combo3_0010_0111));
   assign r_09_b[6] = (~(dcd_110 & combo3_1110_1101));
   assign r_09_b[7] = (~(dcd_111 & combo3_0011_0000));
   
   assign r[9] = (~(r_09_b[0] & r_09_b[1] & r_09_b[2] & r_09_b[3] & r_09_b[4] & r_09_b[5] & r_09_b[6] & r_09_b[7]));
   
   assign r_10_b[0] = (~(dcd_000 & combo3_0111_1010));
   assign r_10_b[1] = (~(dcd_001 & combo3_0011_1011));
   assign r_10_b[2] = (~(dcd_010 & combo3_0001_0111));
   assign r_10_b[3] = (~(dcd_011 & combo3_1101_0111));
   assign r_10_b[4] = (~(dcd_100 & combo3_0001_0001));
   assign r_10_b[5] = (~(dcd_101 & combo3_0111_0110));
   assign r_10_b[6] = (~(dcd_110 & combo3_0110_0111));
   assign r_10_b[7] = (~(dcd_111 & combo3_1010_1000));
   
   assign r[10] = (~(r_10_b[0] & r_10_b[1] & r_10_b[2] & r_10_b[3] & r_10_b[4] & r_10_b[5] & r_10_b[6] & r_10_b[7]));
   
   assign r_11_b[0] = (~(dcd_000 & combo3_0000_1111));
   assign r_11_b[1] = (~(dcd_001 & combo3_0101_0100));
   assign r_11_b[2] = (~(dcd_010 & combo3_1110_1101));
   assign r_11_b[3] = (~(dcd_011 & combo3_0001_0101));
   assign r_11_b[4] = (~(dcd_100 & combo3_1010_1000));
   assign r_11_b[5] = (~(dcd_101 & combo3_0111_1101));
   assign r_11_b[6] = (~(dcd_110 & combo3_1011_0100));
   assign r_11_b[7] = (~(dcd_111 & combo3_1000_0100));
   
   assign r[11] = (~(r_11_b[0] & r_11_b[1] & r_11_b[2] & r_11_b[3] & r_11_b[4] & r_11_b[5] & r_11_b[6] & r_11_b[7]));
   
   assign r_12_b[0] = (~(dcd_000 & combo3_1100_1111));
   assign r_12_b[1] = (~(dcd_001 & combo3_0110_1011));
   assign r_12_b[2] = (~(dcd_010 & combo3_0100_1000));
   assign r_12_b[3] = (~(dcd_011 & combo3_0111_1011));
   assign r_12_b[4] = (~(dcd_100 & combo3_1101_0110));
   assign r_12_b[5] = (~(dcd_101 & combo3_0001_0001));
   assign r_12_b[6] = (~(dcd_110 & combo3_1011_0011));
   assign r_12_b[7] = (~(dcd_111 & combo3_0100_0000));
   
   assign r[12] = (~(r_12_b[0] & r_12_b[1] & r_12_b[2] & r_12_b[3] & r_12_b[4] & r_12_b[5] & r_12_b[6] & r_12_b[7]));
   
   assign r_13_b[0] = (~(dcd_000 & combo3_0101_0001));
   assign r_13_b[1] = (~(dcd_001 & combo3_0011_1100));
   assign r_13_b[2] = (~(dcd_010 & combo3_0101_1011));
   assign r_13_b[3] = (~(dcd_011 & combo3_0001_1000));
   assign r_13_b[4] = (~(dcd_100 & combo3_0110_0010));
   assign r_13_b[5] = (~(dcd_101 & combo3_1101_0100));
   assign r_13_b[6] = (~(dcd_110 & combo3_0100_0011));
   assign r_13_b[7] = (~(dcd_111 & combo3_1000_1010));
   
   assign r[13] = (~(r_13_b[0] & r_13_b[1] & r_13_b[2] & r_13_b[3] & r_13_b[4] & r_13_b[5] & r_13_b[6] & r_13_b[7]));
   
   assign r_14_b[0] = (~(dcd_000 & combo3_1000_0000));
   assign r_14_b[1] = (~(dcd_001 & tidn));
   assign r_14_b[2] = (~(dcd_010 & tidn));
   assign r_14_b[3] = (~(dcd_011 & tidn));
   assign r_14_b[4] = (~(dcd_100 & tidn));
   assign r_14_b[5] = (~(dcd_101 & tidn));
   assign r_14_b[6] = (~(dcd_110 & tidn));
   assign r_14_b[7] = (~(dcd_111 & tidn));
   
   assign r[14] = (~(r_14_b[0] & r_14_b[1] & r_14_b[2] & r_14_b[3] & r_14_b[4] & r_14_b[5] & r_14_b[6] & r_14_b[7]));
   
   
   assign est[1:20] = e[0:19];		
   assign rng[6:20] = r[0:14];		
   
endmodule
