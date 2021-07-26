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

   `include "tri_a2o.vh"

// 11111111111111000001 011111101000010 0
// 11111100000001111101 011110111010000 1
// 11111000001010101101 011110001101100 2
// 11110100011000111111 011101100010110 3
// 11110000101100101001 011100111001100 4
// 11101101000101011011 011100010001110 5
// 11101001100011001101 011011101011010 6
// 11100110000101110001 011011000110010 7
// 11100010101100111101 011010100010100 8
// 11011111011000101001 011010000000000 9
// 11011100001000100111 011001011110100 10
// 11011000111100110011 011000111110010 11
// 11010101110100111111 011000011111000 12
// 11010010110001000101 011000000000110 13
// 11001111110000111101 010111100011100 14
// 11001100110100100001 010111000111010 15
// 11001001111011100101 010110101011110 16
// 11000111000110000111 010110010001000 17
// 11000100010011111101 010101110111010 18
// 11000001100101000011 010101011110010 19
// 10111110111001010001 010101000101110 20
// 10111100010000100001 010100101110010 21
// 10111001101010101101 010100010111010 22
// 10110111000111110011 010100000001000 23
// 10110100100111101001 010011101011010 24
// 10110010001010001101 010011010110010 25
// 10101111101111011001 010011000001110 26
// 10101101010111001011 010010101110000 27
// 10101011000001011001 010010011010100 28
// 10101000101110000101 010010000111110 29
// 10100110011101000101 010001110101010 30
// 10100100001110011011 010001100011100 31
// 10100010000001111101 010001010010000 32
// 10011111110111101101 010001000001000 33
// 10011101101111100011 010000110000100 34
// 10011011101001011101 010000100000100 35
// 10011001100101011001 010000010000110 36
// 10010111100011010011 010000000001010 37
// 10010101100011000111 001111110010010 38
// 10010011100100110101 001111100011110 39
// 10010001101000010101 001111010101100 40
// 10001111101101101001 001111000111100 41
// 10001101110100101011 001110111010000 42
// 10001011111101011011 001110101100110 43
// 10001010000111110101 001110011111110 44
// 10001000010011110101 001110010011000 45
// 10000110100001011101 001110000110100 46
// 10000100110000100111 001101111010100 47
// 10000011000001010001 001101101110110 48
// 10000001010011011011 001101100011000 49
// 01111111100111000011 001101010111110 50
// 01111101111100000011 001101001100110 51
// 01111100010010011101 001101000001110 52
// 01111010101010001111 001100110111010 53
// 01111001000011010011 001100101100110 54
// 01110111011101101101 001100100010100 55
// 01110101111001010111 001100011000100 56
// 01110100010110010001 001100001110110 57
// 01110010110100011001 001100000101010 58
// 01110001010011101111 001011111100000 59
// 01101111110100001111 001011110010110 60
// 01101110010101110111 001011101001110 61
// 01101100111000101001 001011100001000 62
// 01101011011100100001 001011011000010 63

module fu_tblsqo(
   f,
   est,
   rng
);
   input [1:6]   f;
   output [1:20] est;
   output [6:20] rng;

   // end ports

   // ENTITY


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
   wire          combo3_0000_0011;
   wire          combo3_0000_0100;
   wire          combo3_0000_1011;
   wire          combo3_0000_1100;
   wire          combo3_0000_1101;
   wire          combo3_0000_1111;
   wire          combo3_0001_0001;
   wire          combo3_0001_0010;
   wire          combo3_0001_0100;
   wire          combo3_0001_0101;
   wire          combo3_0001_0111;
   wire          combo3_0001_1000;
   wire          combo3_0001_1110;
   wire          combo3_0001_1111;
   wire          combo3_0010_0001;
   wire          combo3_0010_0010;
   wire          combo3_0010_0011;
   wire          combo3_0010_0100;
   wire          combo3_0010_0110;
   wire          combo3_0010_1001;
   wire          combo3_0010_1101;
   wire          combo3_0010_1110;
   wire          combo3_0011_0000;
   wire          combo3_0011_0001;
   wire          combo3_0011_0011;
   wire          combo3_0011_0100;
   wire          combo3_0011_0101;
   wire          combo3_0011_1000;
   wire          combo3_0011_1001;
   wire          combo3_0011_1010;
   wire          combo3_0011_1100;
   wire          combo3_0011_1110;
   wire          combo3_0011_1111;
   wire          combo3_0100_0000;
   wire          combo3_0100_0101;
   wire          combo3_0100_0110;
   wire          combo3_0100_1000;
   wire          combo3_0100_1001;
   wire          combo3_0100_1010;
   wire          combo3_0100_1100;
   wire          combo3_0100_1101;
   wire          combo3_0101_0000;
   wire          combo3_0101_0001;
   wire          combo3_0101_0011;
   wire          combo3_0101_0101;
   wire          combo3_0101_0110;
   wire          combo3_0101_1001;
   wire          combo3_0101_1010;
   wire          combo3_0101_1110;
   wire          combo3_0101_1111;
   wire          combo3_0110_0011;
   wire          combo3_0110_0110;
   wire          combo3_0110_0111;
   wire          combo3_0110_1001;
   wire          combo3_0110_1010;
   wire          combo3_0110_1011;
   wire          combo3_0110_1100;
   wire          combo3_0110_1101;
   wire          combo3_0110_1110;
   wire          combo3_0110_1111;
   wire          combo3_0111_0000;
   wire          combo3_0111_0010;
   wire          combo3_0111_0011;
   wire          combo3_0111_0110;
   wire          combo3_0111_1000;
   wire          combo3_0111_1001;
   wire          combo3_0111_1100;
   wire          combo3_0111_1110;
   wire          combo3_0111_1111;
   wire          combo3_1000_0000;
   wire          combo3_1000_0001;
   wire          combo3_1000_0011;
   wire          combo3_1000_0110;
   wire          combo3_1000_1000;
   wire          combo3_1000_1010;
   wire          combo3_1000_1101;
   wire          combo3_1000_1110;
   wire          combo3_1000_1111;
   wire          combo3_1001_0000;
   wire          combo3_1001_0010;
   wire          combo3_1001_0011;
   wire          combo3_1001_0100;
   wire          combo3_1001_0111;
   wire          combo3_1001_1000;
   wire          combo3_1001_1001;
   wire          combo3_1001_1010;
   wire          combo3_1001_1100;
   wire          combo3_1001_1101;
   wire          combo3_1001_1110;
   wire          combo3_1001_1111;
   wire          combo3_1010_0010;
   wire          combo3_1010_0100;
   wire          combo3_1010_0101;
   wire          combo3_1010_0110;
   wire          combo3_1010_0111;
   wire          combo3_1010_1010;
   wire          combo3_1010_1100;
   wire          combo3_1010_1101;
   wire          combo3_1010_1110;
   wire          combo3_1011_0011;
   wire          combo3_1011_0110;
   wire          combo3_1011_0111;
   wire          combo3_1011_1000;
   wire          combo3_1011_1001;
   wire          combo3_1011_1010;
   wire          combo3_1011_1011;
   wire          combo3_1011_1110;
   wire          combo3_1100_0000;
   wire          combo3_1100_0001;
   wire          combo3_1100_0011;
   wire          combo3_1100_0110;
   wire          combo3_1100_0111;
   wire          combo3_1100_1010;
   wire          combo3_1100_1100;
   wire          combo3_1100_1110;
   wire          combo3_1101_0000;
   wire          combo3_1101_0011;
   wire          combo3_1101_0101;
   wire          combo3_1101_1000;
   wire          combo3_1101_1010;
   wire          combo3_1101_1011;
   wire          combo3_1101_1101;
   wire          combo3_1110_0000;
   wire          combo3_1110_0001;
   wire          combo3_1110_0010;
   wire          combo3_1110_0011;
   wire          combo3_1110_0100;
   wire          combo3_1110_0101;
   wire          combo3_1110_0110;
   wire          combo3_1110_1010;
   wire          combo3_1110_1011;
   wire          combo3_1111_0000;
   wire          combo3_1111_0011;
   wire          combo3_1111_0101;
   wire          combo3_1111_1000;
   wire          combo3_1111_1001;
   wire          combo3_1111_1011;
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

   ////#######################################
   ////## decode the upper 3 index bits
   ////#######################################

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

   ////#######################################
   ////## combos based on lower 2 index bits
   ////#######################################

   assign combo2_1000 = (~f[5]) & (~f[6]);		// [0]
   assign combo2_0100 = (~f[5]) & f[6];		// [1]
   assign combo2_1100 = (~f[5]);		// [0,1]
   assign combo2_0010 = f[5] & (~f[6]);		// [2]
   assign combo2_1010 = (~f[6]);		// [0,2]
   assign combo2_0110 = f[5] ^ f[6];		// [1,2]
   assign combo2_1110 = (~(f[5] & f[6]));		// [0,1,2]
   assign combo2_0001 = f[5] & f[6];		// [3]
   assign combo2_1001 = (~(f[5] ^ f[6]));		// [0,3]
   assign combo2_0101 = f[6];		// [1,3]
   assign combo2_1101 = (~(f[5] & (~f[6])));		// [1,2,3]
   assign combo2_0011 = f[5];		// [2,3]
   assign combo2_1011 = (~((~f[5]) & f[6]));		// [0,2,3]
   assign combo2_0111 = (~((~f[5]) & (~f[6])));		// [1,2,3]

   ////#######################################
   ////## combos based on lower 3 index bits
   ////#######################################

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

   assign combo3_0000_0001 = (~(combo2_xxxx_0001_b));		//i=1, 1 1
   assign combo3_0000_0011 = (~(combo2_xxxx_0011_b));		//i=3, 4 2
   assign combo3_0000_0100 = (~(combo2_xxxx_0100_b));		//i=4, 1 3
   assign combo3_0000_1011 = (~(combo2_xxxx_1011_b));		//i=11, 1 4
   assign combo3_0000_1100 = (~(combo2_xxxx_1100_b));		//i=12, 1 5
   assign combo3_0000_1101 = (~(combo2_xxxx_1101_b));		//i=13, 1 6
   assign combo3_0000_1111 = (~((~f[4])));		//i=15, 4 7
   assign combo3_0001_0001 = (~((~combo2_0001)));		//i=17, 1 8*
   assign combo3_0001_0010 = (~(combo2_0001_xxxx_b & combo2_xxxx_0010_b));		//i=18, 1 9
   assign combo3_0001_0100 = (~(combo2_0001_xxxx_b & combo2_xxxx_0100_b));		//i=20, 1 10
   assign combo3_0001_0101 = (~(combo2_0001_xxxx_b & combo2_xxxx_0101_b));		//i=21, 2 11
   assign combo3_0001_0111 = (~(combo2_0001_xxxx_b & combo2_xxxx_0111_b));		//i=23, 1 12
   assign combo3_0001_1000 = (~(combo2_0001_xxxx_b & combo2_xxxx_1000_b));		//i=24, 1 13
   assign combo3_0001_1110 = (~(combo2_0001_xxxx_b & combo2_xxxx_1110_b));		//i=30, 1 14
   assign combo3_0001_1111 = (~(combo2_0001_xxxx_b & (~f[4])));		//i=31, 2 15
   assign combo3_0010_0001 = (~(combo2_0010_xxxx_b & combo2_xxxx_0001_b));		//i=33, 1 16
   assign combo3_0010_0010 = (~((~combo2_0010)));		//i=34, 1 17*
   assign combo3_0010_0011 = (~(combo2_0010_xxxx_b & combo2_xxxx_0011_b));		//i=35, 1 18
   assign combo3_0010_0100 = (~(combo2_0010_xxxx_b & combo2_xxxx_0100_b));		//i=36, 1 19
   assign combo3_0010_0110 = (~(combo2_0010_xxxx_b & combo2_xxxx_0110_b));		//i=38, 2 20
   assign combo3_0010_1001 = (~(combo2_0010_xxxx_b & combo2_xxxx_1001_b));		//i=41, 2 21
   assign combo3_0010_1101 = (~(combo2_0010_xxxx_b & combo2_xxxx_1101_b));		//i=45, 2 22
   assign combo3_0010_1110 = (~(combo2_0010_xxxx_b & combo2_xxxx_1110_b));		//i=46, 1 23
   assign combo3_0011_0000 = (~(combo2_0011_xxxx_b));		//i=48, 1 24
   assign combo3_0011_0001 = (~(combo2_0011_xxxx_b & combo2_xxxx_0001_b));		//i=49, 3 25
   assign combo3_0011_0011 = (~((~combo2_0011)));		//i=51, 1 26*
   assign combo3_0011_0100 = (~(combo2_0011_xxxx_b & combo2_xxxx_0100_b));		//i=52, 1 27
   assign combo3_0011_0101 = (~(combo2_0011_xxxx_b & combo2_xxxx_0101_b));		//i=53, 1 28
   assign combo3_0011_1000 = (~(combo2_0011_xxxx_b & combo2_xxxx_1000_b));		//i=56, 5 29
   assign combo3_0011_1001 = (~(combo2_0011_xxxx_b & combo2_xxxx_1001_b));		//i=57, 4 30
   assign combo3_0011_1010 = (~(combo2_0011_xxxx_b & combo2_xxxx_1010_b));		//i=58, 1 31
   assign combo3_0011_1100 = (~(combo2_0011_xxxx_b & combo2_xxxx_1100_b));		//i=60, 2 32
   assign combo3_0011_1110 = (~(combo2_0011_xxxx_b & combo2_xxxx_1110_b));		//i=62, 2 33
   assign combo3_0011_1111 = (~(combo2_0011_xxxx_b & (~f[4])));		//i=63, 3 34
   assign combo3_0100_0000 = (~(combo2_0100_xxxx_b));		//i=64, 1 35
   assign combo3_0100_0101 = (~(combo2_0100_xxxx_b & combo2_xxxx_0101_b));		//i=69, 1 36
   assign combo3_0100_0110 = (~(combo2_0100_xxxx_b & combo2_xxxx_0110_b));		//i=70, 1 37
   assign combo3_0100_1000 = (~(combo2_0100_xxxx_b & combo2_xxxx_1000_b));		//i=72, 1 38
   assign combo3_0100_1001 = (~(combo2_0100_xxxx_b & combo2_xxxx_1001_b));		//i=73, 1 39
   assign combo3_0100_1010 = (~(combo2_0100_xxxx_b & combo2_xxxx_1010_b));		//i=74, 2 40
   assign combo3_0100_1100 = (~(combo2_0100_xxxx_b & combo2_xxxx_1100_b));		//i=76, 1 41
   assign combo3_0100_1101 = (~(combo2_0100_xxxx_b & combo2_xxxx_1101_b));		//i=77, 1 42
   assign combo3_0101_0000 = (~(combo2_0101_xxxx_b));		//i=80, 1 43
   assign combo3_0101_0001 = (~(combo2_0101_xxxx_b & combo2_xxxx_0001_b));		//i=81, 2 44
   assign combo3_0101_0011 = (~(combo2_0101_xxxx_b & combo2_xxxx_0011_b));		//i=83, 1 45
   assign combo3_0101_0101 = (~((~combo2_0101)));		//i=85, 1 46*
   assign combo3_0101_0110 = (~(combo2_0101_xxxx_b & combo2_xxxx_0110_b));		//i=86, 1 47
   assign combo3_0101_1001 = (~(combo2_0101_xxxx_b & combo2_xxxx_1001_b));		//i=89, 1 48
   assign combo3_0101_1010 = (~(combo2_0101_xxxx_b & combo2_xxxx_1010_b));		//i=90, 1 49
   assign combo3_0101_1110 = (~(combo2_0101_xxxx_b & combo2_xxxx_1110_b));		//i=94, 1 50
   assign combo3_0101_1111 = (~(combo2_0101_xxxx_b & (~f[4])));		//i=95, 1 51
   assign combo3_0110_0011 = (~(combo2_0110_xxxx_b & combo2_xxxx_0011_b));		//i=99, 1 52
   assign combo3_0110_0110 = (~((~combo2_0110)));		//i=102, 2 53*
   assign combo3_0110_0111 = (~(combo2_0110_xxxx_b & combo2_xxxx_0111_b));		//i=103, 1 54
   assign combo3_0110_1001 = (~(combo2_0110_xxxx_b & combo2_xxxx_1001_b));		//i=105, 1 55
   assign combo3_0110_1010 = (~(combo2_0110_xxxx_b & combo2_xxxx_1010_b));		//i=106, 1 56
   assign combo3_0110_1011 = (~(combo2_0110_xxxx_b & combo2_xxxx_1011_b));		//i=107, 1 57
   assign combo3_0110_1100 = (~(combo2_0110_xxxx_b & combo2_xxxx_1100_b));		//i=108, 1 58
   assign combo3_0110_1101 = (~(combo2_0110_xxxx_b & combo2_xxxx_1101_b));		//i=109, 4 59
   assign combo3_0110_1110 = (~(combo2_0110_xxxx_b & combo2_xxxx_1110_b));		//i=110, 1 60
   assign combo3_0110_1111 = (~(combo2_0110_xxxx_b & (~f[4])));		//i=111, 1 61
   assign combo3_0111_0000 = (~(combo2_0111_xxxx_b));		//i=112, 1 62
   assign combo3_0111_0010 = (~(combo2_0111_xxxx_b & combo2_xxxx_0010_b));		//i=114, 3 63
   assign combo3_0111_0011 = (~(combo2_0111_xxxx_b & combo2_xxxx_0011_b));		//i=115, 1 64
   assign combo3_0111_0110 = (~(combo2_0111_xxxx_b & combo2_xxxx_0110_b));		//i=118, 1 65
   assign combo3_0111_1000 = (~(combo2_0111_xxxx_b & combo2_xxxx_1000_b));		//i=120, 2 66
   assign combo3_0111_1001 = (~(combo2_0111_xxxx_b & combo2_xxxx_1001_b));		//i=121, 1 67
   assign combo3_0111_1100 = (~(combo2_0111_xxxx_b & combo2_xxxx_1100_b));		//i=124, 2 68
   assign combo3_0111_1110 = (~(combo2_0111_xxxx_b & combo2_xxxx_1110_b));		//i=126, 1 69
   assign combo3_0111_1111 = (~(combo2_0111_xxxx_b & (~f[4])));		//i=127, 3 70
   assign combo3_1000_0000 = (~(combo2_1000_xxxx_b));		//i=128, 4 71
   assign combo3_1000_0001 = (~(combo2_1000_xxxx_b & combo2_xxxx_0001_b));		//i=129, 1 72
   assign combo3_1000_0011 = (~(combo2_1000_xxxx_b & combo2_xxxx_0011_b));		//i=131, 2 73
   assign combo3_1000_0110 = (~(combo2_1000_xxxx_b & combo2_xxxx_0110_b));		//i=134, 1 74
   assign combo3_1000_1000 = (~((~combo2_1000)));		//i=136, 1 75*
   assign combo3_1000_1010 = (~(combo2_1000_xxxx_b & combo2_xxxx_1010_b));		//i=138, 2 76
   assign combo3_1000_1101 = (~(combo2_1000_xxxx_b & combo2_xxxx_1101_b));		//i=141, 1 77
   assign combo3_1000_1110 = (~(combo2_1000_xxxx_b & combo2_xxxx_1110_b));		//i=142, 1 78
   assign combo3_1000_1111 = (~(combo2_1000_xxxx_b & (~f[4])));		//i=143, 1 79
   assign combo3_1001_0000 = (~(combo2_1001_xxxx_b));		//i=144, 1 80
   assign combo3_1001_0010 = (~(combo2_1001_xxxx_b & combo2_xxxx_0010_b));		//i=146, 2 81
   assign combo3_1001_0011 = (~(combo2_1001_xxxx_b & combo2_xxxx_0011_b));		//i=147, 2 82
   assign combo3_1001_0100 = (~(combo2_1001_xxxx_b & combo2_xxxx_0100_b));		//i=148, 2 83
   assign combo3_1001_0111 = (~(combo2_1001_xxxx_b & combo2_xxxx_0111_b));		//i=151, 1 84
   assign combo3_1001_1000 = (~(combo2_1001_xxxx_b & combo2_xxxx_1000_b));		//i=152, 1 85
   assign combo3_1001_1001 = (~((~combo2_1001)));		//i=153, 3 86*
   assign combo3_1001_1010 = (~(combo2_1001_xxxx_b & combo2_xxxx_1010_b));		//i=154, 2 87
   assign combo3_1001_1100 = (~(combo2_1001_xxxx_b & combo2_xxxx_1100_b));		//i=156, 2 88
   assign combo3_1001_1101 = (~(combo2_1001_xxxx_b & combo2_xxxx_1101_b));		//i=157, 1 89
   assign combo3_1001_1110 = (~(combo2_1001_xxxx_b & combo2_xxxx_1110_b));		//i=158, 1 90
   assign combo3_1001_1111 = (~(combo2_1001_xxxx_b & (~f[4])));		//i=159, 1 91
   assign combo3_1010_0010 = (~(combo2_1010_xxxx_b & combo2_xxxx_0010_b));		//i=162, 1 92
   assign combo3_1010_0100 = (~(combo2_1010_xxxx_b & combo2_xxxx_0100_b));		//i=164, 2 93
   assign combo3_1010_0101 = (~(combo2_1010_xxxx_b & combo2_xxxx_0101_b));		//i=165, 1 94
   assign combo3_1010_0110 = (~(combo2_1010_xxxx_b & combo2_xxxx_0110_b));		//i=166, 1 95
   assign combo3_1010_0111 = (~(combo2_1010_xxxx_b & combo2_xxxx_0111_b));		//i=167, 2 96
   assign combo3_1010_1010 = (~((~combo2_1010)));		//i=170, 2 97*
   assign combo3_1010_1100 = (~(combo2_1010_xxxx_b & combo2_xxxx_1100_b));		//i=172, 1 98
   assign combo3_1010_1101 = (~(combo2_1010_xxxx_b & combo2_xxxx_1101_b));		//i=173, 1 99
   assign combo3_1010_1110 = (~(combo2_1010_xxxx_b & combo2_xxxx_1110_b));		//i=174, 1 100
   assign combo3_1011_0011 = (~(combo2_1011_xxxx_b & combo2_xxxx_0011_b));		//i=179, 1 101
   assign combo3_1011_0110 = (~(combo2_1011_xxxx_b & combo2_xxxx_0110_b));		//i=182, 2 102
   assign combo3_1011_0111 = (~(combo2_1011_xxxx_b & combo2_xxxx_0111_b));		//i=183, 1 103
   assign combo3_1011_1000 = (~(combo2_1011_xxxx_b & combo2_xxxx_1000_b));		//i=184, 1 104
   assign combo3_1011_1001 = (~(combo2_1011_xxxx_b & combo2_xxxx_1001_b));		//i=185, 1 105
   assign combo3_1011_1010 = (~(combo2_1011_xxxx_b & combo2_xxxx_1010_b));		//i=186, 1 106
   assign combo3_1011_1011 = (~((~combo2_1011)));		//i=187, 2 107*
   assign combo3_1011_1110 = (~(combo2_1011_xxxx_b & combo2_xxxx_1110_b));		//i=190, 2 108
   assign combo3_1100_0000 = (~(combo2_1100_xxxx_b));		//i=192, 3 109
   assign combo3_1100_0001 = (~(combo2_1100_xxxx_b & combo2_xxxx_0001_b));		//i=193, 1 110
   assign combo3_1100_0011 = (~(combo2_1100_xxxx_b & combo2_xxxx_0011_b));		//i=195, 2 111
   assign combo3_1100_0110 = (~(combo2_1100_xxxx_b & combo2_xxxx_0110_b));		//i=198, 1 112
   assign combo3_1100_0111 = (~(combo2_1100_xxxx_b & combo2_xxxx_0111_b));		//i=199, 2 113
   assign combo3_1100_1010 = (~(combo2_1100_xxxx_b & combo2_xxxx_1010_b));		//i=202, 2 114
   assign combo3_1100_1100 = (~((~combo2_1100)));		//i=204, 2 115*
   assign combo3_1100_1110 = (~(combo2_1100_xxxx_b & combo2_xxxx_1110_b));		//i=206, 1 116
   assign combo3_1101_0000 = (~(combo2_1101_xxxx_b));		//i=208, 1 117
   assign combo3_1101_0011 = (~(combo2_1101_xxxx_b & combo2_xxxx_0011_b));		//i=211, 2 118
   assign combo3_1101_0101 = (~(combo2_1101_xxxx_b & combo2_xxxx_0101_b));		//i=213, 3 119
   assign combo3_1101_1000 = (~(combo2_1101_xxxx_b & combo2_xxxx_1000_b));		//i=216, 1 120
   assign combo3_1101_1010 = (~(combo2_1101_xxxx_b & combo2_xxxx_1010_b));		//i=218, 2 121
   assign combo3_1101_1011 = (~(combo2_1101_xxxx_b & combo2_xxxx_1011_b));		//i=219, 1 122
   assign combo3_1101_1101 = (~((~combo2_1101)));		//i=221, 1 123*
   assign combo3_1110_0000 = (~(combo2_1110_xxxx_b));		//i=224, 1 124
   assign combo3_1110_0001 = (~(combo2_1110_xxxx_b & combo2_xxxx_0001_b));		//i=225, 1 125
   assign combo3_1110_0010 = (~(combo2_1110_xxxx_b & combo2_xxxx_0010_b));		//i=226, 1 126
   assign combo3_1110_0011 = (~(combo2_1110_xxxx_b & combo2_xxxx_0011_b));		//i=227, 4 127
   assign combo3_1110_0100 = (~(combo2_1110_xxxx_b & combo2_xxxx_0100_b));		//i=228, 1 128
   assign combo3_1110_0101 = (~(combo2_1110_xxxx_b & combo2_xxxx_0101_b));		//i=229, 1 129
   assign combo3_1110_0110 = (~(combo2_1110_xxxx_b & combo2_xxxx_0110_b));		//i=230, 2 130
   assign combo3_1110_1010 = (~(combo2_1110_xxxx_b & combo2_xxxx_1010_b));		//i=234, 1 131
   assign combo3_1110_1011 = (~(combo2_1110_xxxx_b & combo2_xxxx_1011_b));		//i=235, 1 132
   assign combo3_1111_0000 = (~(f[4]));		//i=240, 4 133
   assign combo3_1111_0011 = (~(f[4] & combo2_xxxx_0011_b));		//i=243, 2 134
   assign combo3_1111_0101 = (~(f[4] & combo2_xxxx_0101_b));		//i=245, 1 135
   assign combo3_1111_1000 = (~(f[4] & combo2_xxxx_1000_b));		//i=248, 2 136
   assign combo3_1111_1001 = (~(f[4] & combo2_xxxx_1001_b));		//i=249, 1 137
   assign combo3_1111_1011 = (~(f[4] & combo2_xxxx_1011_b));		//i=251, 1 138
   assign combo3_1111_1100 = (~(f[4] & combo2_xxxx_1100_b));		//i=252, 4 139
   assign combo3_1111_1110 = (~(f[4] & combo2_xxxx_1110_b));		//i=254, 2 140

   ////#######################################
   ////## ESTIMATE VECTORs
   ////#######################################

   assign e_00_b[0] = (~(dcd_000 & tiup));
   assign e_00_b[1] = (~(dcd_001 & tiup));
   assign e_00_b[2] = (~(dcd_010 & tiup));
   assign e_00_b[3] = (~(dcd_011 & tiup));
   assign e_00_b[4] = (~(dcd_100 & tiup));
   assign e_00_b[5] = (~(dcd_101 & tiup));
   assign e_00_b[6] = (~(dcd_110 & combo3_1100_0000));
   assign e_00_b[7] = (~(dcd_111 & tidn));

   assign e[0] = (~(e_00_b[0] & e_00_b[1] & e_00_b[2] & e_00_b[3] & e_00_b[4] & e_00_b[5] & e_00_b[6] & e_00_b[7]));

   assign e_01_b[0] = (~(dcd_000 & tiup));
   assign e_01_b[1] = (~(dcd_001 & tiup));
   assign e_01_b[2] = (~(dcd_010 & combo3_1111_0000));
   assign e_01_b[3] = (~(dcd_011 & tidn));
   assign e_01_b[4] = (~(dcd_100 & tidn));
   assign e_01_b[5] = (~(dcd_101 & tidn));
   assign e_01_b[6] = (~(dcd_110 & combo3_0011_1111));
   assign e_01_b[7] = (~(dcd_111 & tiup));

   assign e[1] = (~(e_01_b[0] & e_01_b[1] & e_01_b[2] & e_01_b[3] & e_01_b[4] & e_01_b[5] & e_01_b[6] & e_01_b[7]));

   assign e_02_b[0] = (~(dcd_000 & tiup));
   assign e_02_b[1] = (~(dcd_001 & combo3_1000_0000));
   assign e_02_b[2] = (~(dcd_010 & combo3_0000_1111));
   assign e_02_b[3] = (~(dcd_011 & tiup));
   assign e_02_b[4] = (~(dcd_100 & combo3_1000_0000));
   assign e_02_b[5] = (~(dcd_101 & tidn));
   assign e_02_b[6] = (~(dcd_110 & combo3_0011_1111));
   assign e_02_b[7] = (~(dcd_111 & tiup));

   assign e[2] = (~(e_02_b[0] & e_02_b[1] & e_02_b[2] & e_02_b[3] & e_02_b[4] & e_02_b[5] & e_02_b[6] & e_02_b[7]));

   assign e_03_b[0] = (~(dcd_000 & combo3_1111_1000));
   assign e_03_b[1] = (~(dcd_001 & combo3_0111_1100));
   assign e_03_b[2] = (~(dcd_010 & combo3_0000_1111));
   assign e_03_b[3] = (~(dcd_011 & combo3_1100_0000));
   assign e_03_b[4] = (~(dcd_100 & combo3_0111_1111));
   assign e_03_b[5] = (~(dcd_101 & combo3_1000_0000));
   assign e_03_b[6] = (~(dcd_110 & combo3_0011_1111));
   assign e_03_b[7] = (~(dcd_111 & combo3_1111_0000));

   assign e[3] = (~(e_03_b[0] & e_03_b[1] & e_03_b[2] & e_03_b[3] & e_03_b[4] & e_03_b[5] & e_03_b[6] & e_03_b[7]));

   assign e_04_b[0] = (~(dcd_000 & combo3_1110_0110));
   assign e_04_b[1] = (~(dcd_001 & combo3_0111_0011));
   assign e_04_b[2] = (~(dcd_010 & combo3_1000_1110));
   assign e_04_b[3] = (~(dcd_011 & combo3_0011_1100));
   assign e_04_b[4] = (~(dcd_100 & combo3_0111_1000));
   assign e_04_b[5] = (~(dcd_101 & combo3_0111_1100));
   assign e_04_b[6] = (~(dcd_110 & combo3_0011_1110));
   assign e_04_b[7] = (~(dcd_111 & combo3_0000_1111));

   assign e[4] = (~(e_04_b[0] & e_04_b[1] & e_04_b[2] & e_04_b[3] & e_04_b[4] & e_04_b[5] & e_04_b[6] & e_04_b[7]));

   assign e_05_b[0] = (~(dcd_000 & combo3_1101_0101));
   assign e_05_b[1] = (~(dcd_001 & combo3_0110_1011));
   assign e_05_b[2] = (~(dcd_010 & combo3_0110_1101));
   assign e_05_b[3] = (~(dcd_011 & combo3_1011_0011));
   assign e_05_b[4] = (~(dcd_100 & combo3_0110_0110));
   assign e_05_b[5] = (~(dcd_101 & combo3_0110_0011));
   assign e_05_b[6] = (~(dcd_110 & combo3_0011_1001));
   assign e_05_b[7] = (~(dcd_111 & combo3_1100_1110));

   assign e[5] = (~(e_05_b[0] & e_05_b[1] & e_05_b[2] & e_05_b[3] & e_05_b[4] & e_05_b[5] & e_05_b[6] & e_05_b[7]));

   assign e_06_b[0] = (~(dcd_000 & combo3_1000_0001));
   assign e_06_b[1] = (~(dcd_001 & combo3_1100_0110));
   assign e_06_b[2] = (~(dcd_010 & combo3_0100_1001));
   assign e_06_b[3] = (~(dcd_011 & combo3_0110_1010));
   assign e_06_b[4] = (~(dcd_100 & combo3_1101_0101));
   assign e_06_b[5] = (~(dcd_101 & combo3_0101_1010));
   assign e_06_b[6] = (~(dcd_110 & combo3_1010_0101));
   assign e_06_b[7] = (~(dcd_111 & combo3_0010_1101));

   assign e[6] = (~(e_06_b[0] & e_06_b[1] & e_06_b[2] & e_06_b[3] & e_06_b[4] & e_06_b[5] & e_06_b[6] & e_06_b[7]));

   assign e_07_b[0] = (~(dcd_000 & combo3_1000_0110));
   assign e_07_b[1] = (~(dcd_001 & combo3_0100_1010));
   assign e_07_b[2] = (~(dcd_010 & combo3_1101_0011));
   assign e_07_b[3] = (~(dcd_011 & combo3_0011_1000));
   assign e_07_b[4] = (~(dcd_100 & combo3_0111_1111));
   assign e_07_b[5] = (~(dcd_101 & combo3_1111_0000));
   assign e_07_b[6] = (~(dcd_110 & combo3_1111_0011));
   assign e_07_b[7] = (~(dcd_111 & combo3_1001_1001));

   assign e[7] = (~(e_07_b[0] & e_07_b[1] & e_07_b[2] & e_07_b[3] & e_07_b[4] & e_07_b[5] & e_07_b[6] & e_07_b[7]));

   assign e_08_b[0] = (~(dcd_000 & combo3_1000_1010));
   assign e_08_b[1] = (~(dcd_001 & combo3_1001_1111));
   assign e_08_b[2] = (~(dcd_010 & combo3_1001_1010));
   assign e_08_b[3] = (~(dcd_011 & combo3_1010_0100));
   assign e_08_b[4] = (~(dcd_100 & combo3_0111_1111));
   assign e_08_b[5] = (~(dcd_101 & combo3_1111_0011));
   assign e_08_b[6] = (~(dcd_110 & combo3_0011_0100));
   assign e_08_b[7] = (~(dcd_111 & combo3_1010_1010));

   assign e[8] = (~(e_08_b[0] & e_08_b[1] & e_08_b[2] & e_08_b[3] & e_08_b[4] & e_08_b[5] & e_08_b[6] & e_08_b[7]));

   assign e_09_b[0] = (~(dcd_000 & combo3_1001_0000));
   assign e_09_b[1] = (~(dcd_001 & combo3_0101_1111));
   assign e_09_b[2] = (~(dcd_010 & combo3_1010_1100));
   assign e_09_b[3] = (~(dcd_011 & combo3_0001_0010));
   assign e_09_b[4] = (~(dcd_100 & combo3_0100_0000));
   assign e_09_b[5] = (~(dcd_101 & combo3_0011_0101));
   assign e_09_b[6] = (~(dcd_110 & combo3_0101_1001));
   assign e_09_b[7] = (~(dcd_111 & tiup));

   assign e[9] = (~(e_09_b[0] & e_09_b[1] & e_09_b[2] & e_09_b[3] & e_09_b[4] & e_09_b[5] & e_09_b[6] & e_09_b[7]));

   assign e_10_b[0] = (~(dcd_000 & combo3_1011_1000));
   assign e_10_b[1] = (~(dcd_001 & combo3_1111_0000));
   assign e_10_b[2] = (~(dcd_010 & combo3_1000_1010));
   assign e_10_b[3] = (~(dcd_011 & combo3_0110_0111));
   assign e_10_b[4] = (~(dcd_100 & combo3_0011_0000));
   assign e_10_b[5] = (~(dcd_101 & combo3_1101_0000));
   assign e_10_b[6] = (~(dcd_110 & combo3_0001_0101));
   assign e_10_b[7] = (~(dcd_111 & combo3_1000_0011));

   assign e[10] = (~(e_10_b[0] & e_10_b[1] & e_10_b[2] & e_10_b[3] & e_10_b[4] & e_10_b[5] & e_10_b[6] & e_10_b[7]));

   assign e_11_b[0] = (~(dcd_000 & combo3_1000_1101));
   assign e_11_b[1] = (~(dcd_001 & combo3_1001_1001));
   assign e_11_b[2] = (~(dcd_010 & combo3_0101_0001));
   assign e_11_b[3] = (~(dcd_011 & combo3_1011_0111));
   assign e_11_b[4] = (~(dcd_100 & combo3_0110_1001));
   assign e_11_b[5] = (~(dcd_101 & combo3_0111_1000));
   assign e_11_b[6] = (~(dcd_110 & combo3_0011_0001));
   assign e_11_b[7] = (~(dcd_111 & combo3_0110_1101));

   assign e[11] = (~(e_11_b[0] & e_11_b[1] & e_11_b[2] & e_11_b[3] & e_11_b[4] & e_11_b[5] & e_11_b[6] & e_11_b[7]));

   assign e_12_b[0] = (~(dcd_000 & combo3_1010_0010));
   assign e_12_b[1] = (~(dcd_001 & tidn));
   assign e_12_b[2] = (~(dcd_010 & combo3_1110_0011));
   assign e_12_b[3] = (~(dcd_011 & combo3_1111_0101));
   assign e_12_b[4] = (~(dcd_100 & combo3_0110_0110));
   assign e_12_b[5] = (~(dcd_101 & combo3_0000_1100));
   assign e_12_b[6] = (~(dcd_110 & combo3_0110_1110));
   assign e_12_b[7] = (~(dcd_111 & combo3_0101_0000));

   assign e[12] = (~(e_12_b[0] & e_12_b[1] & e_12_b[2] & e_12_b[3] & e_12_b[4] & e_12_b[5] & e_12_b[6] & e_12_b[7]));

   assign e_13_b[0] = (~(dcd_000 & combo3_1100_0111));
   assign e_13_b[1] = (~(dcd_001 & combo3_0000_0100));
   assign e_13_b[2] = (~(dcd_010 & combo3_1011_1001));
   assign e_13_b[3] = (~(dcd_011 & combo3_1011_1010));
   assign e_13_b[4] = (~(dcd_100 & combo3_1111_1110));
   assign e_13_b[5] = (~(dcd_101 & combo3_0101_1110));
   assign e_13_b[6] = (~(dcd_110 & combo3_1110_0011));
   assign e_13_b[7] = (~(dcd_111 & combo3_1001_0100));

   assign e[13] = (~(e_13_b[0] & e_13_b[1] & e_13_b[2] & e_13_b[3] & e_13_b[4] & e_13_b[5] & e_13_b[6] & e_13_b[7]));

   assign e_14_b[0] = (~(dcd_000 & combo3_0111_1001));
   assign e_14_b[1] = (~(dcd_001 & combo3_1111_1011));
   assign e_14_b[2] = (~(dcd_010 & combo3_1010_0111));
   assign e_14_b[3] = (~(dcd_011 & combo3_1000_0000));
   assign e_14_b[4] = (~(dcd_100 & combo3_1110_0001));
   assign e_14_b[5] = (~(dcd_101 & combo3_0110_1101));
   assign e_14_b[6] = (~(dcd_110 & combo3_0000_0001));
   assign e_14_b[7] = (~(dcd_111 & combo3_0001_0111));

   assign e[14] = (~(e_14_b[0] & e_14_b[1] & e_14_b[2] & e_14_b[3] & e_14_b[4] & e_14_b[5] & e_14_b[6] & e_14_b[7]));

   assign e_15_b[0] = (~(dcd_000 & combo3_0101_0101));
   assign e_15_b[1] = (~(dcd_001 & combo3_1001_1010));
   assign e_15_b[2] = (~(dcd_010 & combo3_0010_1001));
   assign e_15_b[3] = (~(dcd_011 & combo3_0010_1001));
   assign e_15_b[4] = (~(dcd_100 & combo3_1001_1101));
   assign e_15_b[5] = (~(dcd_101 & combo3_1001_1110));
   assign e_15_b[6] = (~(dcd_110 & combo3_1100_1010));
   assign e_15_b[7] = (~(dcd_111 & combo3_1110_0100));

   assign e[15] = (~(e_15_b[0] & e_15_b[1] & e_15_b[2] & e_15_b[3] & e_15_b[4] & e_15_b[5] & e_15_b[6] & e_15_b[7]));

   assign e_16_b[0] = (~(dcd_000 & combo3_0111_1110));
   assign e_16_b[1] = (~(dcd_001 & combo3_1100_1010));
   assign e_16_b[2] = (~(dcd_010 & combo3_0010_0010));
   assign e_16_b[3] = (~(dcd_011 & combo3_1111_1001));
   assign e_16_b[4] = (~(dcd_100 & combo3_1101_1000));
   assign e_16_b[5] = (~(dcd_101 & combo3_0111_0010));
   assign e_16_b[6] = (~(dcd_110 & combo3_0100_1101));
   assign e_16_b[7] = (~(dcd_111 & combo3_0011_1010));

   assign e[16] = (~(e_16_b[0] & e_16_b[1] & e_16_b[2] & e_16_b[3] & e_16_b[4] & e_16_b[5] & e_16_b[6] & e_16_b[7]));

   assign e_17_b[0] = (~(dcd_000 & combo3_0111_0010));
   assign e_17_b[1] = (~(dcd_001 & combo3_1010_1110));
   assign e_17_b[2] = (~(dcd_010 & combo3_1110_0010));
   assign e_17_b[3] = (~(dcd_011 & combo3_0100_0110));
   assign e_17_b[4] = (~(dcd_100 & combo3_1101_0011));
   assign e_17_b[5] = (~(dcd_101 & combo3_1000_1111));
   assign e_17_b[6] = (~(dcd_110 & combo3_0000_1101));
   assign e_17_b[7] = (~(dcd_111 & combo3_1001_1100));

   assign e[17] = (~(e_17_b[0] & e_17_b[1] & e_17_b[2] & e_17_b[3] & e_17_b[4] & e_17_b[5] & e_17_b[6] & e_17_b[7]));

   assign e_18_b[0] = (~(dcd_000 & combo3_0001_0100));
   assign e_18_b[1] = (~(dcd_001 & combo3_0011_1000));
   assign e_18_b[2] = (~(dcd_010 & combo3_0101_0001));
   assign e_18_b[3] = (~(dcd_011 & combo3_0001_0001));
   assign e_18_b[4] = (~(dcd_100 & combo3_0010_0110));
   assign e_18_b[5] = (~(dcd_101 & combo3_0011_0001));
   assign e_18_b[6] = (~(dcd_110 & combo3_0111_0110));
   assign e_18_b[7] = (~(dcd_111 & combo3_1001_1100));

   assign e[18] = (~(e_18_b[0] & e_18_b[1] & e_18_b[2] & e_18_b[3] & e_18_b[4] & e_18_b[5] & e_18_b[6] & e_18_b[7]));

   assign e_19_b[0] = (~(dcd_000 & tiup));
   assign e_19_b[1] = (~(dcd_001 & tiup));
   assign e_19_b[2] = (~(dcd_010 & tiup));
   assign e_19_b[3] = (~(dcd_011 & tiup));
   assign e_19_b[4] = (~(dcd_100 & tiup));
   assign e_19_b[5] = (~(dcd_101 & tiup));
   assign e_19_b[6] = (~(dcd_110 & tiup));
   assign e_19_b[7] = (~(dcd_111 & tiup));

   assign e[19] = (~(e_19_b[0] & e_19_b[1] & e_19_b[2] & e_19_b[3] & e_19_b[4] & e_19_b[5] & e_19_b[6] & e_19_b[7]));

   ////#######################################
   ////## RANGE VECTORs
   ////#######################################

   assign r_00_b[0] = (~(dcd_000 & tidn));
   assign r_00_b[1] = (~(dcd_001 & tidn));
   assign r_00_b[2] = (~(dcd_010 & tidn));
   assign r_00_b[3] = (~(dcd_011 & tidn));
   assign r_00_b[4] = (~(dcd_100 & tidn));
   assign r_00_b[5] = (~(dcd_101 & tidn));
   assign r_00_b[6] = (~(dcd_110 & tidn));
   assign r_00_b[7] = (~(dcd_111 & tidn));

   assign r[0] = (~(r_00_b[0] & r_00_b[1] & r_00_b[2] & r_00_b[3] & r_00_b[4] & r_00_b[5] & r_00_b[6] & r_00_b[7]));

   assign r_01_b[0] = (~(dcd_000 & tiup));
   assign r_01_b[1] = (~(dcd_001 & tiup));
   assign r_01_b[2] = (~(dcd_010 & tiup));
   assign r_01_b[3] = (~(dcd_011 & tiup));
   assign r_01_b[4] = (~(dcd_100 & combo3_1111_1100));
   assign r_01_b[5] = (~(dcd_101 & tidn));
   assign r_01_b[6] = (~(dcd_110 & tidn));
   assign r_01_b[7] = (~(dcd_111 & tidn));

   assign r[1] = (~(r_01_b[0] & r_01_b[1] & r_01_b[2] & r_01_b[3] & r_01_b[4] & r_01_b[5] & r_01_b[6] & r_01_b[7]));

   assign r_02_b[0] = (~(dcd_000 & tiup));
   assign r_02_b[1] = (~(dcd_001 & combo3_1111_1100));
   assign r_02_b[2] = (~(dcd_010 & tidn));
   assign r_02_b[3] = (~(dcd_011 & tidn));
   assign r_02_b[4] = (~(dcd_100 & combo3_0000_0011));
   assign r_02_b[5] = (~(dcd_101 & tiup));
   assign r_02_b[6] = (~(dcd_110 & tiup));
   assign r_02_b[7] = (~(dcd_111 & tiup));

   assign r[2] = (~(r_02_b[0] & r_02_b[1] & r_02_b[2] & r_02_b[3] & r_02_b[4] & r_02_b[5] & r_02_b[6] & r_02_b[7]));

   assign r_03_b[0] = (~(dcd_000 & combo3_1111_1100));
   assign r_03_b[1] = (~(dcd_001 & combo3_0000_0011));
   assign r_03_b[2] = (~(dcd_010 & tiup));
   assign r_03_b[3] = (~(dcd_011 & tidn));
   assign r_03_b[4] = (~(dcd_100 & combo3_0000_0011));
   assign r_03_b[5] = (~(dcd_101 & tiup));
   assign r_03_b[6] = (~(dcd_110 & tiup));
   assign r_03_b[7] = (~(dcd_111 & combo3_1110_0000));

   assign r[3] = (~(r_03_b[0] & r_03_b[1] & r_03_b[2] & r_03_b[3] & r_03_b[4] & r_03_b[5] & r_03_b[6] & r_03_b[7]));

   assign r_04_b[0] = (~(dcd_000 & combo3_1110_0011));
   assign r_04_b[1] = (~(dcd_001 & combo3_1100_0011));
   assign r_04_b[2] = (~(dcd_010 & combo3_1100_0000));
   assign r_04_b[3] = (~(dcd_011 & combo3_1111_1100));
   assign r_04_b[4] = (~(dcd_100 & combo3_0000_0011));
   assign r_04_b[5] = (~(dcd_101 & combo3_1111_1110));
   assign r_04_b[6] = (~(dcd_110 & tidn));
   assign r_04_b[7] = (~(dcd_111 & combo3_0001_1111));

   assign r[4] = (~(r_04_b[0] & r_04_b[1] & r_04_b[2] & r_04_b[3] & r_04_b[4] & r_04_b[5] & r_04_b[6] & r_04_b[7]));

   assign r_05_b[0] = (~(dcd_000 & combo3_1001_0011));
   assign r_05_b[1] = (~(dcd_001 & combo3_0010_0011));
   assign r_05_b[2] = (~(dcd_010 & combo3_0011_1000));
   assign r_05_b[3] = (~(dcd_011 & combo3_1110_0011));
   assign r_05_b[4] = (~(dcd_100 & combo3_1100_0011));
   assign r_05_b[5] = (~(dcd_101 & combo3_1100_0001));
   assign r_05_b[6] = (~(dcd_110 & combo3_1111_1000));
   assign r_05_b[7] = (~(dcd_111 & combo3_0001_1111));

   assign r[5] = (~(r_05_b[0] & r_05_b[1] & r_05_b[2] & r_05_b[3] & r_05_b[4] & r_05_b[5] & r_05_b[6] & r_05_b[7]));

   assign r_06_b[0] = (~(dcd_000 & combo3_1101_1010));
   assign r_06_b[1] = (~(dcd_001 & combo3_1001_0010));
   assign r_06_b[2] = (~(dcd_010 & combo3_1010_0100));
   assign r_06_b[3] = (~(dcd_011 & combo3_1001_0011));
   assign r_06_b[4] = (~(dcd_100 & combo3_0011_0011));
   assign r_06_b[5] = (~(dcd_101 & combo3_0011_0001));
   assign r_06_b[6] = (~(dcd_110 & combo3_1100_0111));
   assign r_06_b[7] = (~(dcd_111 & combo3_0001_1110));

   assign r[6] = (~(r_06_b[0] & r_06_b[1] & r_06_b[2] & r_06_b[3] & r_06_b[4] & r_06_b[5] & r_06_b[6] & r_06_b[7]));

   assign r_07_b[0] = (~(dcd_000 & combo3_0100_1100));
   assign r_07_b[1] = (~(dcd_001 & combo3_0011_1000));
   assign r_07_b[2] = (~(dcd_010 & combo3_0111_0010));
   assign r_07_b[3] = (~(dcd_011 & combo3_0100_1010));
   assign r_07_b[4] = (~(dcd_100 & combo3_1010_1010));
   assign r_07_b[5] = (~(dcd_101 & combo3_1010_1101));
   assign r_07_b[6] = (~(dcd_110 & combo3_0010_0100));
   assign r_07_b[7] = (~(dcd_111 & combo3_1001_1001));

   assign r[7] = (~(r_07_b[0] & r_07_b[1] & r_07_b[2] & r_07_b[3] & r_07_b[4] & r_07_b[5] & r_07_b[6] & r_07_b[7]));

   assign r_08_b[0] = (~(dcd_000 & combo3_1110_1010));
   assign r_08_b[1] = (~(dcd_001 & combo3_0011_1000));
   assign r_08_b[2] = (~(dcd_010 & combo3_1001_0100));
   assign r_08_b[3] = (~(dcd_011 & combo3_1001_1000));
   assign r_08_b[4] = (~(dcd_100 & tidn));
   assign r_08_b[5] = (~(dcd_101 & combo3_0011_1001));
   assign r_08_b[6] = (~(dcd_110 & combo3_1001_0010));
   assign r_08_b[7] = (~(dcd_111 & combo3_1101_0101));

   assign r[8] = (~(r_08_b[0] & r_08_b[1] & r_08_b[2] & r_08_b[3] & r_08_b[4] & r_08_b[5] & r_08_b[6] & r_08_b[7]));

   assign r_09_b[0] = (~(dcd_000 & combo3_0010_0001));
   assign r_09_b[1] = (~(dcd_001 & combo3_0011_1001));
   assign r_09_b[2] = (~(dcd_010 & combo3_0011_1110));
   assign r_09_b[3] = (~(dcd_011 & combo3_0101_0110));
   assign r_09_b[4] = (~(dcd_100 & tidn));
   assign r_09_b[5] = (~(dcd_101 & combo3_1101_1010));
   assign r_09_b[6] = (~(dcd_110 & combo3_1011_0110));
   assign r_09_b[7] = (~(dcd_111 & combo3_0111_0000));

   assign r[9] = (~(r_09_b[0] & r_09_b[1] & r_09_b[2] & r_09_b[3] & r_09_b[4] & r_09_b[5] & r_09_b[6] & r_09_b[7]));

   assign r_10_b[0] = (~(dcd_000 & combo3_0101_0011));
   assign r_10_b[1] = (~(dcd_001 & combo3_1011_1011));
   assign r_10_b[2] = (~(dcd_010 & combo3_1011_0110));
   assign r_10_b[3] = (~(dcd_011 & combo3_1101_1101));
   assign r_10_b[4] = (~(dcd_100 & combo3_1000_0011));
   assign r_10_b[5] = (~(dcd_101 & combo3_0110_1111));
   assign r_10_b[6] = (~(dcd_110 & combo3_1110_0101));
   assign r_10_b[7] = (~(dcd_111 & combo3_0100_1000));

   assign r[10] = (~(r_10_b[0] & r_10_b[1] & r_10_b[2] & r_10_b[3] & r_10_b[4] & r_10_b[5] & r_10_b[6] & r_10_b[7]));

   assign r_11_b[0] = (~(dcd_000 & combo3_0010_1110));
   assign r_11_b[1] = (~(dcd_001 & combo3_0000_1011));
   assign r_11_b[2] = (~(dcd_010 & combo3_1110_1011));
   assign r_11_b[3] = (~(dcd_011 & combo3_1010_0111));
   assign r_11_b[4] = (~(dcd_100 & combo3_0100_0101));
   assign r_11_b[5] = (~(dcd_101 & combo3_1100_1100));
   assign r_11_b[6] = (~(dcd_110 & combo3_0110_1100));
   assign r_11_b[7] = (~(dcd_111 & combo3_0010_0110));

   assign r[11] = (~(r_11_b[0] & r_11_b[1] & r_11_b[2] & r_11_b[3] & r_11_b[4] & r_11_b[5] & r_11_b[6] & r_11_b[7]));

   assign r_12_b[0] = (~(dcd_000 & combo3_0011_1100));
   assign r_12_b[1] = (~(dcd_001 & combo3_1010_0110));
   assign r_12_b[2] = (~(dcd_010 & combo3_1000_1000));
   assign r_12_b[3] = (~(dcd_011 & combo3_0010_1101));
   assign r_12_b[4] = (~(dcd_100 & combo3_0011_1001));
   assign r_12_b[5] = (~(dcd_101 & combo3_1101_1011));
   assign r_12_b[6] = (~(dcd_110 & combo3_1011_1011));
   assign r_12_b[7] = (~(dcd_111 & combo3_1100_1100));

   assign r[12] = (~(r_12_b[0] & r_12_b[1] & r_12_b[2] & r_12_b[3] & r_12_b[4] & r_12_b[5] & r_12_b[6] & r_12_b[7]));

   assign r_13_b[0] = (~(dcd_000 & combo3_1001_0111));
   assign r_13_b[1] = (~(dcd_001 & combo3_0001_0101));
   assign r_13_b[2] = (~(dcd_010 & combo3_1011_1110));
   assign r_13_b[3] = (~(dcd_011 & combo3_1110_0110));
   assign r_13_b[4] = (~(dcd_100 & combo3_0000_1111));
   assign r_13_b[5] = (~(dcd_101 & combo3_0001_1000));
   assign r_13_b[6] = (~(dcd_110 & combo3_1011_1110));
   assign r_13_b[7] = (~(dcd_111 & combo3_0110_1101));

   assign r[13] = (~(r_13_b[0] & r_13_b[1] & r_13_b[2] & r_13_b[3] & r_13_b[4] & r_13_b[5] & r_13_b[6] & r_13_b[7]));

   assign r_14_b[0] = (~(dcd_000 & tidn));
   assign r_14_b[1] = (~(dcd_001 & tidn));
   assign r_14_b[2] = (~(dcd_010 & tidn));
   assign r_14_b[3] = (~(dcd_011 & tidn));
   assign r_14_b[4] = (~(dcd_100 & tidn));
   assign r_14_b[5] = (~(dcd_101 & tidn));
   assign r_14_b[6] = (~(dcd_110 & tidn));
   assign r_14_b[7] = (~(dcd_111 & tidn));

   assign r[14] = (~(r_14_b[0] & r_14_b[1] & r_14_b[2] & r_14_b[3] & r_14_b[4] & r_14_b[5] & r_14_b[6] & r_14_b[7]));

   ////#######################################
   ////## RENUMBERING OUTPUTS
   ////#######################################

   assign est[1:20] = e[0:19];		// renumbering
   assign rng[6:20] = r[0:14];		// renumbering

endmodule
