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


// 01101010000001011111 010110010111010 0
// 01100111001110100011 010101110110100 1
// 01100100011111101101 010101010111010 2
// 01100001110100110011 010100111001000 3
// 01011111001101101011 010100011011110 4
// 01011100101010001011 010011111111100 5
// 01011010001010001101 010011100100100 6
// 01010111101101101001 010011001010010 7
// 01010101010100010101 010010110001000 8
// 01010010111110001101 010010011000100 9
// 01010000101011000111 010010000001000 10
// 01001110011010111101 010001101010010 11
// 01001100001101101011 010001010100000 12
// 01001010000011001011 010000111110110 13
// 01000111111011010101 010000101010000 14
// 01000101110110000011 010000010110000 15
// 01000011110011010011 010000000010100 16
// 01000001110010111111 001111101111110 17
// 00111111110101000001 001111011101010 18
// 00111101111001010101 001111001011110 19
// 00111011111111110111 001110111010100 20
// 00111010001000100001 001110101001110 21
// 00111000010011010011 001110011001100 22
// 00110110100000000101 001110001001110 23
// 00110100101110110111 001101111010100 24
// 00110010111111100001 001101101011100 25
// 00110001010010000011 001101011101000 26
// 00101111100110011001 001101001111000 27
// 00101101111100100001 001101000001010 28
// 00101100010100010101 001100110100000 29
// 00101010101101110101 001100100111000 30
// 00101001001000111011 001100011010010 31
// 00100111100101100111 001100001110000 32
// 00100110000011110101 001100000010000 33
// 00100100100011100101 001011110110010 34
// 00100011000100110001 001011101011000 35
// 00100001100111011001 001011011111110 36
// 00100000001011011001 001011010101000 37
// 00011110110000110001 001011001010100 38
// 00011101010111011101 001011000000000 39
// 00011011111111011011 001010110110000 40
// 00011010101000101001 001010101100000 41
// 00011001010011000111 001010100010100 42
// 00010111111110110011 001010011001000 43
// 00010110101011101001 001010010000000 44
// 00010101011001101001 001010000111000 45
// 00010100001000101111 001001111110010 46
// 00010010111000111101 001001110101110 47
// 00010001101010001111 001001101101010 48
// 00010000011100100011 001001100101000 49
// 00001111001111111011 001001011101000 50
// 00001110000100010001 001001010101010 51
// 00001100111001100111 001001001101100 52
// 00001011101111111001 001001000110000 53
// 00001010100111000111 001000111110110 54
// 00001001011111010001 001000110111100 55
// 00001000011000010101 001000110000100 56
// 00000111010010010001 001000101001100 57
// 00000110001101000011 001000100010110 58
// 00000101001000101101 001000011100000 59
// 00000100000101001011 001000010101100 60
// 00000011000010011101 001000001111010 61
// 00000010000000100001 001000001001000 62
// 00000000111111011001 001000000011000 63

   `include "tri_a2o.vh"

module fu_tblsqe(
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
   wire          combo3_0000_0111;
   wire          combo3_0000_1001;
   wire          combo3_0000_1010;
   wire          combo3_0000_1011;
   wire          combo3_0000_1101;
   wire          combo3_0000_1111;
   wire          combo3_0001_0001;
   wire          combo3_0001_0010;
   wire          combo3_0001_0100;
   wire          combo3_0001_0101;
   wire          combo3_0001_0111;
   wire          combo3_0001_1000;
   wire          combo3_0001_1100;
   wire          combo3_0001_1101;
   wire          combo3_0001_1110;
   wire          combo3_0001_1111;
   wire          combo3_0010_0001;
   wire          combo3_0010_0011;
   wire          combo3_0010_0100;
   wire          combo3_0010_0101;
   wire          combo3_0010_1000;
   wire          combo3_0010_1001;
   wire          combo3_0010_1010;
   wire          combo3_0010_1100;
   wire          combo3_0010_1101;
   wire          combo3_0010_1110;
   wire          combo3_0010_1111;
   wire          combo3_0011_0000;
   wire          combo3_0011_0001;
   wire          combo3_0011_0011;
   wire          combo3_0011_0101;
   wire          combo3_0011_0110;
   wire          combo3_0011_1000;
   wire          combo3_0011_1001;
   wire          combo3_0011_1110;
   wire          combo3_0011_1111;
   wire          combo3_0100_0000;
   wire          combo3_0100_0010;
   wire          combo3_0100_0100;
   wire          combo3_0100_0101;
   wire          combo3_0100_1001;
   wire          combo3_0100_1100;
   wire          combo3_0100_1110;
   wire          combo3_0100_1111;
   wire          combo3_0101_0010;
   wire          combo3_0101_0100;
   wire          combo3_0101_0110;
   wire          combo3_0101_1001;
   wire          combo3_0101_1100;
   wire          combo3_0101_1111;
   wire          combo3_0110_0000;
   wire          combo3_0110_0011;
   wire          combo3_0110_0110;
   wire          combo3_0110_0111;
   wire          combo3_0110_1100;
   wire          combo3_0110_1101;
   wire          combo3_0110_1111;
   wire          combo3_0111_0000;
   wire          combo3_0111_0101;
   wire          combo3_0111_0111;
   wire          combo3_0111_1000;
   wire          combo3_0111_1001;
   wire          combo3_0111_1010;
   wire          combo3_0111_1111;
   wire          combo3_1000_0000;
   wire          combo3_1000_0011;
   wire          combo3_1000_0110;
   wire          combo3_1000_0111;
   wire          combo3_1000_1010;
   wire          combo3_1000_1110;
   wire          combo3_1001_0000;
   wire          combo3_1001_0001;
   wire          combo3_1001_0010;
   wire          combo3_1001_0100;
   wire          combo3_1001_0110;
   wire          combo3_1001_0111;
   wire          combo3_1001_1000;
   wire          combo3_1001_1001;
   wire          combo3_1001_1010;
   wire          combo3_1001_1011;
   wire          combo3_1001_1100;
   wire          combo3_1010_0000;
   wire          combo3_1010_0001;
   wire          combo3_1010_0010;
   wire          combo3_1010_0100;
   wire          combo3_1010_0101;
   wire          combo3_1010_0110;
   wire          combo3_1010_0111;
   wire          combo3_1010_1001;
   wire          combo3_1010_1010;
   wire          combo3_1010_1100;
   wire          combo3_1010_1101;
   wire          combo3_1010_1111;
   wire          combo3_1011_0001;
   wire          combo3_1011_0010;
   wire          combo3_1011_0100;
   wire          combo3_1011_0101;
   wire          combo3_1011_1000;
   wire          combo3_1011_1010;
   wire          combo3_1011_1100;
   wire          combo3_1100_0000;
   wire          combo3_1100_0001;
   wire          combo3_1100_0011;
   wire          combo3_1100_0101;
   wire          combo3_1100_0110;
   wire          combo3_1100_0111;
   wire          combo3_1100_1001;
   wire          combo3_1100_1010;
   wire          combo3_1100_1011;
   wire          combo3_1100_1101;
   wire          combo3_1100_1111;
   wire          combo3_1101_0010;
   wire          combo3_1101_0011;
   wire          combo3_1101_1000;
   wire          combo3_1101_1001;
   wire          combo3_1101_1010;
   wire          combo3_1101_1100;
   wire          combo3_1101_1110;
   wire          combo3_1101_1111;
   wire          combo3_1110_0000;
   wire          combo3_1110_0001;
   wire          combo3_1110_0011;
   wire          combo3_1110_0110;
   wire          combo3_1110_1000;
   wire          combo3_1110_1010;
   wire          combo3_1110_1101;
   wire          combo3_1111_0000;
   wire          combo3_1111_0001;
   wire          combo3_1111_0010;
   wire          combo3_1111_1000;
   wire          combo3_1111_1001;
   wire          combo3_1111_1010;
   wire          combo3_1111_1100;
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
   assign combo3_0000_0011 = (~(combo2_xxxx_0011_b));		//i=3, 5 2
   assign combo3_0000_0100 = (~(combo2_xxxx_0100_b));		//i=4, 1 3
   assign combo3_0000_0111 = (~(combo2_xxxx_0111_b));		//i=7, 1 4
   assign combo3_0000_1001 = (~(combo2_xxxx_1001_b));		//i=9, 1 5
   assign combo3_0000_1010 = (~(combo2_xxxx_1010_b));		//i=10, 1 6
   assign combo3_0000_1011 = (~(combo2_xxxx_1011_b));		//i=11, 1 7
   assign combo3_0000_1101 = (~(combo2_xxxx_1101_b));		//i=13, 2 8
   assign combo3_0000_1111 = (~((~f[4])));		//i=15, 1 9
   assign combo3_0001_0001 = (~((~combo2_0001)));		//i=17, 1 10*
   assign combo3_0001_0010 = (~(combo2_0001_xxxx_b & combo2_xxxx_0010_b));		//i=18, 1 11
   assign combo3_0001_0100 = (~(combo2_0001_xxxx_b & combo2_xxxx_0100_b));		//i=20, 1 12
   assign combo3_0001_0101 = (~(combo2_0001_xxxx_b & combo2_xxxx_0101_b));		//i=21, 2 13
   assign combo3_0001_0111 = (~(combo2_0001_xxxx_b & combo2_xxxx_0111_b));		//i=23, 1 14
   assign combo3_0001_1000 = (~(combo2_0001_xxxx_b & combo2_xxxx_1000_b));		//i=24, 2 15
   assign combo3_0001_1100 = (~(combo2_0001_xxxx_b & combo2_xxxx_1100_b));		//i=28, 4 16
   assign combo3_0001_1101 = (~(combo2_0001_xxxx_b & combo2_xxxx_1101_b));		//i=29, 2 17
   assign combo3_0001_1110 = (~(combo2_0001_xxxx_b & combo2_xxxx_1110_b));		//i=30, 1 18
   assign combo3_0001_1111 = (~(combo2_0001_xxxx_b & (~f[4])));		//i=31, 1 19
   assign combo3_0010_0001 = (~(combo2_0010_xxxx_b & combo2_xxxx_0001_b));		//i=33, 1 20
   assign combo3_0010_0011 = (~(combo2_0010_xxxx_b & combo2_xxxx_0011_b));		//i=35, 1 21
   assign combo3_0010_0100 = (~(combo2_0010_xxxx_b & combo2_xxxx_0100_b));		//i=36, 1 22
   assign combo3_0010_0101 = (~(combo2_0010_xxxx_b & combo2_xxxx_0101_b));		//i=37, 1 23
   assign combo3_0010_1000 = (~(combo2_0010_xxxx_b & combo2_xxxx_1000_b));		//i=40, 3 24
   assign combo3_0010_1001 = (~(combo2_0010_xxxx_b & combo2_xxxx_1001_b));		//i=41, 2 25
   assign combo3_0010_1010 = (~(combo2_0010_xxxx_b & combo2_xxxx_1010_b));		//i=42, 1 26
   assign combo3_0010_1100 = (~(combo2_0010_xxxx_b & combo2_xxxx_1100_b));		//i=44, 1 27
   assign combo3_0010_1101 = (~(combo2_0010_xxxx_b & combo2_xxxx_1101_b));		//i=45, 1 28
   assign combo3_0010_1110 = (~(combo2_0010_xxxx_b & combo2_xxxx_1110_b));		//i=46, 1 29
   assign combo3_0010_1111 = (~(combo2_0010_xxxx_b & (~f[4])));		//i=47, 1 30
   assign combo3_0011_0000 = (~(combo2_0011_xxxx_b));		//i=48, 2 31
   assign combo3_0011_0001 = (~(combo2_0011_xxxx_b & combo2_xxxx_0001_b));		//i=49, 1 32
   assign combo3_0011_0011 = (~((~combo2_0011)));		//i=51, 1 33*
   assign combo3_0011_0101 = (~(combo2_0011_xxxx_b & combo2_xxxx_0101_b));		//i=53, 1 34
   assign combo3_0011_0110 = (~(combo2_0011_xxxx_b & combo2_xxxx_0110_b));		//i=54, 2 35
   assign combo3_0011_1000 = (~(combo2_0011_xxxx_b & combo2_xxxx_1000_b));		//i=56, 1 36
   assign combo3_0011_1001 = (~(combo2_0011_xxxx_b & combo2_xxxx_1001_b));		//i=57, 1 37
   assign combo3_0011_1110 = (~(combo2_0011_xxxx_b & combo2_xxxx_1110_b));		//i=62, 1 38
   assign combo3_0011_1111 = (~(combo2_0011_xxxx_b & (~f[4])));		//i=63, 5 39
   assign combo3_0100_0000 = (~(combo2_0100_xxxx_b));		//i=64, 1 40
   assign combo3_0100_0010 = (~(combo2_0100_xxxx_b & combo2_xxxx_0010_b));		//i=66, 1 41
   assign combo3_0100_0100 = (~((~combo2_0100)));		//i=68, 1 42*
   assign combo3_0100_0101 = (~(combo2_0100_xxxx_b & combo2_xxxx_0101_b));		//i=69, 1 43
   assign combo3_0100_1001 = (~(combo2_0100_xxxx_b & combo2_xxxx_1001_b));		//i=73, 1 44
   assign combo3_0100_1100 = (~(combo2_0100_xxxx_b & combo2_xxxx_1100_b));		//i=76, 2 45
   assign combo3_0100_1110 = (~(combo2_0100_xxxx_b & combo2_xxxx_1110_b));		//i=78, 1 46
   assign combo3_0100_1111 = (~(combo2_0100_xxxx_b & (~f[4])));		//i=79, 1 47
   assign combo3_0101_0010 = (~(combo2_0101_xxxx_b & combo2_xxxx_0010_b));		//i=82, 2 48
   assign combo3_0101_0100 = (~(combo2_0101_xxxx_b & combo2_xxxx_0100_b));		//i=84, 1 49
   assign combo3_0101_0110 = (~(combo2_0101_xxxx_b & combo2_xxxx_0110_b));		//i=86, 4 50
   assign combo3_0101_1001 = (~(combo2_0101_xxxx_b & combo2_xxxx_1001_b));		//i=89, 2 51
   assign combo3_0101_1100 = (~(combo2_0101_xxxx_b & combo2_xxxx_1100_b));		//i=92, 1 52
   assign combo3_0101_1111 = (~(combo2_0101_xxxx_b & (~f[4])));		//i=95, 2 53
   assign combo3_0110_0000 = (~(combo2_0110_xxxx_b));		//i=96, 1 54
   assign combo3_0110_0011 = (~(combo2_0110_xxxx_b & combo2_xxxx_0011_b));		//i=99, 1 55
   assign combo3_0110_0110 = (~((~combo2_0110)));		//i=102, 2 56*
   assign combo3_0110_0111 = (~(combo2_0110_xxxx_b & combo2_xxxx_0111_b));		//i=103, 1 57
   assign combo3_0110_1100 = (~(combo2_0110_xxxx_b & combo2_xxxx_1100_b));		//i=108, 2 58
   assign combo3_0110_1101 = (~(combo2_0110_xxxx_b & combo2_xxxx_1101_b));		//i=109, 2 59
   assign combo3_0110_1111 = (~(combo2_0110_xxxx_b & (~f[4])));		//i=111, 1 60
   assign combo3_0111_0000 = (~(combo2_0111_xxxx_b));		//i=112, 1 61
   assign combo3_0111_0101 = (~(combo2_0111_xxxx_b & combo2_xxxx_0101_b));		//i=117, 1 62
   assign combo3_0111_0111 = (~((~combo2_0111)));		//i=119, 3 63*
   assign combo3_0111_1000 = (~(combo2_0111_xxxx_b & combo2_xxxx_1000_b));		//i=120, 1 64
   assign combo3_0111_1001 = (~(combo2_0111_xxxx_b & combo2_xxxx_1001_b));		//i=121, 2 65
   assign combo3_0111_1010 = (~(combo2_0111_xxxx_b & combo2_xxxx_1010_b));		//i=122, 2 66
   assign combo3_0111_1111 = (~(combo2_0111_xxxx_b & (~f[4])));		//i=127, 4 67
   assign combo3_1000_0000 = (~(combo2_1000_xxxx_b));		//i=128, 3 68
   assign combo3_1000_0011 = (~(combo2_1000_xxxx_b & combo2_xxxx_0011_b));		//i=131, 1 69
   assign combo3_1000_0110 = (~(combo2_1000_xxxx_b & combo2_xxxx_0110_b));		//i=134, 1 70
   assign combo3_1000_0111 = (~(combo2_1000_xxxx_b & combo2_xxxx_0111_b));		//i=135, 1 71
   assign combo3_1000_1010 = (~(combo2_1000_xxxx_b & combo2_xxxx_1010_b));		//i=138, 1 72
   assign combo3_1000_1110 = (~(combo2_1000_xxxx_b & combo2_xxxx_1110_b));		//i=142, 2 73
   assign combo3_1001_0000 = (~(combo2_1001_xxxx_b));		//i=144, 2 74
   assign combo3_1001_0001 = (~(combo2_1001_xxxx_b & combo2_xxxx_0001_b));		//i=145, 1 75
   assign combo3_1001_0010 = (~(combo2_1001_xxxx_b & combo2_xxxx_0010_b));		//i=146, 2 76
   assign combo3_1001_0100 = (~(combo2_1001_xxxx_b & combo2_xxxx_0100_b));		//i=148, 1 77
   assign combo3_1001_0110 = (~(combo2_1001_xxxx_b & combo2_xxxx_0110_b));		//i=150, 1 78
   assign combo3_1001_0111 = (~(combo2_1001_xxxx_b & combo2_xxxx_0111_b));		//i=151, 1 79
   assign combo3_1001_1000 = (~(combo2_1001_xxxx_b & combo2_xxxx_1000_b));		//i=152, 1 80
   assign combo3_1001_1001 = (~((~combo2_1001)));		//i=153, 2 81*
   assign combo3_1001_1010 = (~(combo2_1001_xxxx_b & combo2_xxxx_1010_b));		//i=154, 1 82
   assign combo3_1001_1011 = (~(combo2_1001_xxxx_b & combo2_xxxx_1011_b));		//i=155, 2 83
   assign combo3_1001_1100 = (~(combo2_1001_xxxx_b & combo2_xxxx_1100_b));		//i=156, 1 84
   assign combo3_1010_0000 = (~(combo2_1010_xxxx_b));		//i=160, 1 85
   assign combo3_1010_0001 = (~(combo2_1010_xxxx_b & combo2_xxxx_0001_b));		//i=161, 1 86
   assign combo3_1010_0010 = (~(combo2_1010_xxxx_b & combo2_xxxx_0010_b));		//i=162, 1 87
   assign combo3_1010_0100 = (~(combo2_1010_xxxx_b & combo2_xxxx_0100_b));		//i=164, 1 88
   assign combo3_1010_0101 = (~(combo2_1010_xxxx_b & combo2_xxxx_0101_b));		//i=165, 2 89
   assign combo3_1010_0110 = (~(combo2_1010_xxxx_b & combo2_xxxx_0110_b));		//i=166, 1 90
   assign combo3_1010_0111 = (~(combo2_1010_xxxx_b & combo2_xxxx_0111_b));		//i=167, 1 91
   assign combo3_1010_1001 = (~(combo2_1010_xxxx_b & combo2_xxxx_1001_b));		//i=169, 2 92
   assign combo3_1010_1010 = (~((~combo2_1010)));		//i=170, 2 93*
   assign combo3_1010_1100 = (~(combo2_1010_xxxx_b & combo2_xxxx_1100_b));		//i=172, 2 94
   assign combo3_1010_1101 = (~(combo2_1010_xxxx_b & combo2_xxxx_1101_b));		//i=173, 1 95
   assign combo3_1010_1111 = (~(combo2_1010_xxxx_b & (~f[4])));		//i=175, 1 96
   assign combo3_1011_0001 = (~(combo2_1011_xxxx_b & combo2_xxxx_0001_b));		//i=177, 1 97
   assign combo3_1011_0010 = (~(combo2_1011_xxxx_b & combo2_xxxx_0010_b));		//i=178, 1 98
   assign combo3_1011_0100 = (~(combo2_1011_xxxx_b & combo2_xxxx_0100_b));		//i=180, 1 99
   assign combo3_1011_0101 = (~(combo2_1011_xxxx_b & combo2_xxxx_0101_b));		//i=181, 1 100
   assign combo3_1011_1000 = (~(combo2_1011_xxxx_b & combo2_xxxx_1000_b));		//i=184, 1 101
   assign combo3_1011_1010 = (~(combo2_1011_xxxx_b & combo2_xxxx_1010_b));		//i=186, 1 102
   assign combo3_1011_1100 = (~(combo2_1011_xxxx_b & combo2_xxxx_1100_b));		//i=188, 1 103
   assign combo3_1100_0000 = (~(combo2_1100_xxxx_b));		//i=192, 4 104
   assign combo3_1100_0001 = (~(combo2_1100_xxxx_b & combo2_xxxx_0001_b));		//i=193, 1 105
   assign combo3_1100_0011 = (~(combo2_1100_xxxx_b & combo2_xxxx_0011_b));		//i=195, 1 106
   assign combo3_1100_0101 = (~(combo2_1100_xxxx_b & combo2_xxxx_0101_b));		//i=197, 1 107
   assign combo3_1100_0110 = (~(combo2_1100_xxxx_b & combo2_xxxx_0110_b));		//i=198, 1 108
   assign combo3_1100_0111 = (~(combo2_1100_xxxx_b & combo2_xxxx_0111_b));		//i=199, 1 109
   assign combo3_1100_1001 = (~(combo2_1100_xxxx_b & combo2_xxxx_1001_b));		//i=201, 1 110
   assign combo3_1100_1010 = (~(combo2_1100_xxxx_b & combo2_xxxx_1010_b));		//i=202, 2 111
   assign combo3_1100_1011 = (~(combo2_1100_xxxx_b & combo2_xxxx_1011_b));		//i=203, 3 112
   assign combo3_1100_1101 = (~(combo2_1100_xxxx_b & combo2_xxxx_1101_b));		//i=205, 1 113
   assign combo3_1100_1111 = (~(combo2_1100_xxxx_b & (~f[4])));		//i=207, 1 114
   assign combo3_1101_0010 = (~(combo2_1101_xxxx_b & combo2_xxxx_0010_b));		//i=210, 1 115
   assign combo3_1101_0011 = (~(combo2_1101_xxxx_b & combo2_xxxx_0011_b));		//i=211, 2 116
   assign combo3_1101_1000 = (~(combo2_1101_xxxx_b & combo2_xxxx_1000_b));		//i=216, 1 117
   assign combo3_1101_1001 = (~(combo2_1101_xxxx_b & combo2_xxxx_1001_b));		//i=217, 2 118
   assign combo3_1101_1010 = (~(combo2_1101_xxxx_b & combo2_xxxx_1010_b));		//i=218, 2 119
   assign combo3_1101_1100 = (~(combo2_1101_xxxx_b & combo2_xxxx_1100_b));		//i=220, 1 120
   assign combo3_1101_1110 = (~(combo2_1101_xxxx_b & combo2_xxxx_1110_b));		//i=222, 1 121
   assign combo3_1101_1111 = (~(combo2_1101_xxxx_b & (~f[4])));		//i=223, 2 122
   assign combo3_1110_0000 = (~(combo2_1110_xxxx_b));		//i=224, 5 123
   assign combo3_1110_0001 = (~(combo2_1110_xxxx_b & combo2_xxxx_0001_b));		//i=225, 1 124
   assign combo3_1110_0011 = (~(combo2_1110_xxxx_b & combo2_xxxx_0011_b));		//i=227, 2 125
   assign combo3_1110_0110 = (~(combo2_1110_xxxx_b & combo2_xxxx_0110_b));		//i=230, 1 126
   assign combo3_1110_1000 = (~(combo2_1110_xxxx_b & combo2_xxxx_1000_b));		//i=232, 1 127
   assign combo3_1110_1010 = (~(combo2_1110_xxxx_b & combo2_xxxx_1010_b));		//i=234, 1 128
   assign combo3_1110_1101 = (~(combo2_1110_xxxx_b & combo2_xxxx_1101_b));		//i=237, 3 129
   assign combo3_1111_0000 = (~(f[4]));		//i=240, 2 130
   assign combo3_1111_0001 = (~(f[4] & combo2_xxxx_0001_b));		//i=241, 1 131
   assign combo3_1111_0010 = (~(f[4] & combo2_xxxx_0010_b));		//i=242, 2 132
   assign combo3_1111_1000 = (~(f[4] & combo2_xxxx_1000_b));		//i=248, 3 133
   assign combo3_1111_1001 = (~(f[4] & combo2_xxxx_1001_b));		//i=249, 2 134
   assign combo3_1111_1010 = (~(f[4] & combo2_xxxx_1010_b));		//i=250, 2 135
   assign combo3_1111_1100 = (~(f[4] & combo2_xxxx_1100_b));		//i=252, 4 136

   ////#######################################
   ////## ESTIMATE VECTORs
   ////#######################################

   assign e_00_b[0] = (~(dcd_000 & tidn));
   assign e_00_b[1] = (~(dcd_001 & tidn));
   assign e_00_b[2] = (~(dcd_010 & tidn));
   assign e_00_b[3] = (~(dcd_011 & tidn));
   assign e_00_b[4] = (~(dcd_100 & tidn));
   assign e_00_b[5] = (~(dcd_101 & tidn));
   assign e_00_b[6] = (~(dcd_110 & tidn));
   assign e_00_b[7] = (~(dcd_111 & tidn));

   assign e[0] = (~(e_00_b[0] & e_00_b[1] & e_00_b[2] & e_00_b[3] & e_00_b[4] & e_00_b[5] & e_00_b[6] & e_00_b[7]));

   assign e_01_b[0] = (~(dcd_000 & tiup));
   assign e_01_b[1] = (~(dcd_001 & tiup));
   assign e_01_b[2] = (~(dcd_010 & combo3_1100_0000));
   assign e_01_b[3] = (~(dcd_011 & tidn));
   assign e_01_b[4] = (~(dcd_100 & tidn));
   assign e_01_b[5] = (~(dcd_101 & tidn));
   assign e_01_b[6] = (~(dcd_110 & tidn));
   assign e_01_b[7] = (~(dcd_111 & tidn));

   assign e[1] = (~(e_01_b[0] & e_01_b[1] & e_01_b[2] & e_01_b[3] & e_01_b[4] & e_01_b[5] & e_01_b[6] & e_01_b[7]));

   assign e_02_b[0] = (~(dcd_000 & combo3_1111_0000));
   assign e_02_b[1] = (~(dcd_001 & tidn));
   assign e_02_b[2] = (~(dcd_010 & combo3_0011_1111));
   assign e_02_b[3] = (~(dcd_011 & tiup));
   assign e_02_b[4] = (~(dcd_100 & combo3_1111_1100));
   assign e_02_b[5] = (~(dcd_101 & tidn));
   assign e_02_b[6] = (~(dcd_110 & tidn));
   assign e_02_b[7] = (~(dcd_111 & tidn));

   assign e[2] = (~(e_02_b[0] & e_02_b[1] & e_02_b[2] & e_02_b[3] & e_02_b[4] & e_02_b[5] & e_02_b[6] & e_02_b[7]));

   assign e_03_b[0] = (~(dcd_000 & combo3_0000_1111));
   assign e_03_b[1] = (~(dcd_001 & combo3_1110_0000));
   assign e_03_b[2] = (~(dcd_010 & combo3_0011_1111));
   assign e_03_b[3] = (~(dcd_011 & combo3_1110_0000));
   assign e_03_b[4] = (~(dcd_100 & combo3_0000_0011));
   assign e_03_b[5] = (~(dcd_101 & tiup));
   assign e_03_b[6] = (~(dcd_110 & combo3_1100_0000));
   assign e_03_b[7] = (~(dcd_111 & tidn));

   assign e[3] = (~(e_03_b[0] & e_03_b[1] & e_03_b[2] & e_03_b[3] & e_03_b[4] & e_03_b[5] & e_03_b[6] & e_03_b[7]));

   assign e_04_b[0] = (~(dcd_000 & combo3_1000_1110));
   assign e_04_b[1] = (~(dcd_001 & combo3_0001_1100));
   assign e_04_b[2] = (~(dcd_010 & combo3_0011_1110));
   assign e_04_b[3] = (~(dcd_011 & combo3_0001_1111));
   assign e_04_b[4] = (~(dcd_100 & combo3_0000_0011));
   assign e_04_b[5] = (~(dcd_101 & combo3_1110_0000));
   assign e_04_b[6] = (~(dcd_110 & combo3_0011_1111));
   assign e_04_b[7] = (~(dcd_111 & combo3_1000_0000));

   assign e[4] = (~(e_04_b[0] & e_04_b[1] & e_04_b[2] & e_04_b[3] & e_04_b[4] & e_04_b[5] & e_04_b[6] & e_04_b[7]));

   assign e_05_b[0] = (~(dcd_000 & combo3_0110_1101));
   assign e_05_b[1] = (~(dcd_001 & combo3_1001_1011));
   assign e_05_b[2] = (~(dcd_010 & combo3_0011_0001));
   assign e_05_b[3] = (~(dcd_011 & combo3_1001_1100));
   assign e_05_b[4] = (~(dcd_100 & combo3_1110_0011));
   assign e_05_b[5] = (~(dcd_101 & combo3_0001_1110));
   assign e_05_b[6] = (~(dcd_110 & combo3_0011_1000));
   assign e_05_b[7] = (~(dcd_111 & combo3_0111_1000));

   assign e[5] = (~(e_05_b[0] & e_05_b[1] & e_05_b[2] & e_05_b[3] & e_05_b[4] & e_05_b[5] & e_05_b[6] & e_05_b[7]));

   assign e_06_b[0] = (~(dcd_000 & combo3_1100_1011));
   assign e_06_b[1] = (~(dcd_001 & combo3_0101_0110));
   assign e_06_b[2] = (~(dcd_010 & combo3_1010_1101));
   assign e_06_b[3] = (~(dcd_011 & combo3_0101_0010));
   assign e_06_b[4] = (~(dcd_100 & combo3_1101_0010));
   assign e_06_b[5] = (~(dcd_101 & combo3_1101_1001));
   assign e_06_b[6] = (~(dcd_110 & combo3_0011_0110));
   assign e_06_b[7] = (~(dcd_111 & combo3_0110_0110));

   assign e[6] = (~(e_06_b[0] & e_06_b[1] & e_06_b[2] & e_06_b[3] & e_06_b[4] & e_06_b[5] & e_06_b[6] & e_06_b[7]));

   assign e_07_b[0] = (~(dcd_000 & combo3_0101_1001));
   assign e_07_b[1] = (~(dcd_001 & combo3_1000_0011));
   assign e_07_b[2] = (~(dcd_010 & combo3_1111_1000));
   assign e_07_b[3] = (~(dcd_011 & combo3_0011_1001));
   assign e_07_b[4] = (~(dcd_100 & combo3_1001_1001));
   assign e_07_b[5] = (~(dcd_101 & combo3_1011_0100));
   assign e_07_b[6] = (~(dcd_110 & combo3_1010_0101));
   assign e_07_b[7] = (~(dcd_111 & combo3_0101_0100));

   assign e[7] = (~(e_07_b[0] & e_07_b[1] & e_07_b[2] & e_07_b[3] & e_07_b[4] & e_07_b[5] & e_07_b[6] & e_07_b[7]));

   assign e_08_b[0] = (~(dcd_000 & combo3_0001_0101));
   assign e_08_b[1] = (~(dcd_001 & combo3_0110_0011));
   assign e_08_b[2] = (~(dcd_010 & combo3_1111_1001));
   assign e_08_b[3] = (~(dcd_011 & combo3_1101_1010));
   assign e_08_b[4] = (~(dcd_100 & combo3_1010_1010));
   assign e_08_b[5] = (~(dcd_101 & combo3_1101_1001));
   assign e_08_b[6] = (~(dcd_110 & combo3_1000_1110));
   assign e_08_b[7] = (~(dcd_111 & combo3_0000_0001));

   assign e[8] = (~(e_08_b[0] & e_08_b[1] & e_08_b[2] & e_08_b[3] & e_08_b[4] & e_08_b[5] & e_08_b[6] & e_08_b[7]));

   assign e_09_b[0] = (~(dcd_000 & combo3_0011_0000));
   assign e_09_b[1] = (~(dcd_001 & combo3_1101_0011));
   assign e_09_b[2] = (~(dcd_010 & combo3_1111_1010));
   assign e_09_b[3] = (~(dcd_011 & combo3_0110_1100));
   assign e_09_b[4] = (~(dcd_100 & combo3_0000_0011));
   assign e_09_b[5] = (~(dcd_101 & combo3_1011_0101));
   assign e_09_b[6] = (~(dcd_110 & combo3_0100_1001));
   assign e_09_b[7] = (~(dcd_111 & combo3_1100_0001));

   assign e[9] = (~(e_09_b[0] & e_09_b[1] & e_09_b[2] & e_09_b[3] & e_09_b[4] & e_09_b[5] & e_09_b[6] & e_09_b[7]));

   assign e_10_b[0] = (~(dcd_000 & combo3_0110_1111));
   assign e_10_b[1] = (~(dcd_001 & combo3_0111_1010));
   assign e_10_b[2] = (~(dcd_010 & combo3_0001_1100));
   assign e_10_b[3] = (~(dcd_011 & combo3_1100_1011));
   assign e_10_b[4] = (~(dcd_100 & combo3_0000_0100));
   assign e_10_b[5] = (~(dcd_101 & combo3_1101_1111));
   assign e_10_b[6] = (~(dcd_110 & combo3_1110_1101));
   assign e_10_b[7] = (~(dcd_111 & combo3_1011_0001));

   assign e[10] = (~(e_10_b[0] & e_10_b[1] & e_10_b[2] & e_10_b[3] & e_10_b[4] & e_10_b[5] & e_10_b[6] & e_10_b[7]));

   assign e_11_b[0] = (~(dcd_000 & combo3_0111_1001));
   assign e_11_b[1] = (~(dcd_001 & combo3_1100_1001));
   assign e_11_b[2] = (~(dcd_010 & combo3_0010_1000));
   assign e_11_b[3] = (~(dcd_011 & combo3_1101_1110));
   assign e_11_b[4] = (~(dcd_100 & combo3_1001_1001));
   assign e_11_b[5] = (~(dcd_101 & combo3_1001_0000));
   assign e_11_b[6] = (~(dcd_110 & combo3_0111_0111));
   assign e_11_b[7] = (~(dcd_111 & combo3_0010_1001));

   assign e[11] = (~(e_11_b[0] & e_11_b[1] & e_11_b[2] & e_11_b[3] & e_11_b[4] & e_11_b[5] & e_11_b[6] & e_11_b[7]));

   assign e_12_b[0] = (~(dcd_000 & combo3_0110_0110));
   assign e_12_b[1] = (~(dcd_001 & combo3_0111_0111));
   assign e_12_b[2] = (~(dcd_010 & combo3_1100_1010));
   assign e_12_b[3] = (~(dcd_011 & combo3_1111_0000));
   assign e_12_b[4] = (~(dcd_100 & combo3_0110_1101));
   assign e_12_b[5] = (~(dcd_101 & combo3_1011_1000));
   assign e_12_b[6] = (~(dcd_110 & combo3_1010_0111));
   assign e_12_b[7] = (~(dcd_111 & combo3_0100_0101));

   assign e[12] = (~(e_12_b[0] & e_12_b[1] & e_12_b[2] & e_12_b[3] & e_12_b[4] & e_12_b[5] & e_12_b[6] & e_12_b[7]));

   assign e_13_b[0] = (~(dcd_000 & combo3_1010_1001));
   assign e_13_b[1] = (~(dcd_001 & combo3_0010_1110));
   assign e_13_b[2] = (~(dcd_010 & combo3_1011_1010));
   assign e_13_b[3] = (~(dcd_011 & combo3_0100_0010));
   assign e_13_b[4] = (~(dcd_100 & combo3_1110_1101));
   assign e_13_b[5] = (~(dcd_101 & combo3_1010_1100));
   assign e_13_b[6] = (~(dcd_110 & combo3_0010_1111));
   assign e_13_b[7] = (~(dcd_111 & combo3_0010_1001));

   assign e[13] = (~(e_13_b[0] & e_13_b[1] & e_13_b[2] & e_13_b[3] & e_13_b[4] & e_13_b[5] & e_13_b[6] & e_13_b[7]));

   assign e_14_b[0] = (~(dcd_000 & combo3_0111_1001));
   assign e_14_b[1] = (~(dcd_001 & combo3_0001_1000));
   assign e_14_b[2] = (~(dcd_010 & combo3_0100_1100));
   assign e_14_b[3] = (~(dcd_011 & combo3_1100_1011));
   assign e_14_b[4] = (~(dcd_100 & combo3_1111_0010));
   assign e_14_b[5] = (~(dcd_101 & combo3_0101_1111));
   assign e_14_b[6] = (~(dcd_110 & combo3_0110_1100));
   assign e_14_b[7] = (~(dcd_111 & combo3_0001_0010));

   assign e[14] = (~(e_14_b[0] & e_14_b[1] & e_14_b[2] & e_14_b[3] & e_14_b[4] & e_14_b[5] & e_14_b[6] & e_14_b[7]));

   assign e_15_b[0] = (~(dcd_000 & combo3_1001_0000));
   assign e_15_b[1] = (~(dcd_001 & combo3_1001_0010));
   assign e_15_b[2] = (~(dcd_010 & combo3_1101_1010));
   assign e_15_b[3] = (~(dcd_011 & combo3_1001_0111));
   assign e_15_b[4] = (~(dcd_100 & combo3_0101_1111));
   assign e_15_b[5] = (~(dcd_101 & combo3_1001_0001));
   assign e_15_b[6] = (~(dcd_110 & combo3_0011_0101));
   assign e_15_b[7] = (~(dcd_111 & combo3_1100_0101));

   assign e[15] = (~(e_15_b[0] & e_15_b[1] & e_15_b[2] & e_15_b[3] & e_15_b[4] & e_15_b[5] & e_15_b[6] & e_15_b[7]));

   assign e_16_b[0] = (~(dcd_000 & combo3_1010_1111));
   assign e_16_b[1] = (~(dcd_001 & combo3_0101_1100));
   assign e_16_b[2] = (~(dcd_010 & combo3_0100_0000));
   assign e_16_b[3] = (~(dcd_011 & combo3_0001_0001));
   assign e_16_b[4] = (~(dcd_100 & combo3_0000_1101));
   assign e_16_b[5] = (~(dcd_101 & combo3_1100_1111));
   assign e_16_b[6] = (~(dcd_110 & combo3_1010_0100));
   assign e_16_b[7] = (~(dcd_111 & combo3_0001_1101));

   assign e[16] = (~(e_16_b[0] & e_16_b[1] & e_16_b[2] & e_16_b[3] & e_16_b[4] & e_16_b[5] & e_16_b[6] & e_16_b[7]));

   assign e_17_b[0] = (~(dcd_000 & combo3_1010_0010));
   assign e_17_b[1] = (~(dcd_001 & combo3_1111_0010));
   assign e_17_b[2] = (~(dcd_010 & combo3_0101_1001));
   assign e_17_b[3] = (~(dcd_011 & combo3_1000_0110));
   assign e_17_b[4] = (~(dcd_100 & combo3_1110_0001));
   assign e_17_b[5] = (~(dcd_101 & combo3_0010_0011));
   assign e_17_b[6] = (~(dcd_110 & combo3_1000_1010));
   assign e_17_b[7] = (~(dcd_111 & combo3_1001_0100));

   assign e[17] = (~(e_17_b[0] & e_17_b[1] & e_17_b[2] & e_17_b[3] & e_17_b[4] & e_17_b[5] & e_17_b[6] & e_17_b[7]));

   assign e_18_b[0] = (~(dcd_000 & combo3_1101_1100));
   assign e_18_b[1] = (~(dcd_001 & combo3_0010_1101));
   assign e_18_b[2] = (~(dcd_010 & combo3_1100_1010));
   assign e_18_b[3] = (~(dcd_011 & combo3_1010_0001));
   assign e_18_b[4] = (~(dcd_100 & combo3_1000_0000));
   assign e_18_b[5] = (~(dcd_101 & combo3_1011_0010));
   assign e_18_b[6] = (~(dcd_110 & combo3_1110_1010));
   assign e_18_b[7] = (~(dcd_111 & combo3_0010_1000));

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
   assign r_01_b[2] = (~(dcd_010 & combo3_1000_0000));
   assign r_01_b[3] = (~(dcd_011 & tidn));
   assign r_01_b[4] = (~(dcd_100 & tidn));
   assign r_01_b[5] = (~(dcd_101 & tidn));
   assign r_01_b[6] = (~(dcd_110 & tidn));
   assign r_01_b[7] = (~(dcd_111 & tidn));

   assign r[1] = (~(r_01_b[0] & r_01_b[1] & r_01_b[2] & r_01_b[3] & r_01_b[4] & r_01_b[5] & r_01_b[6] & r_01_b[7]));

   assign r_02_b[0] = (~(dcd_000 & tidn));
   assign r_02_b[1] = (~(dcd_001 & tidn));
   assign r_02_b[2] = (~(dcd_010 & combo3_0111_1111));
   assign r_02_b[3] = (~(dcd_011 & tiup));
   assign r_02_b[4] = (~(dcd_100 & tiup));
   assign r_02_b[5] = (~(dcd_101 & tiup));
   assign r_02_b[6] = (~(dcd_110 & tiup));
   assign r_02_b[7] = (~(dcd_111 & tiup));

   assign r[2] = (~(r_02_b[0] & r_02_b[1] & r_02_b[2] & r_02_b[3] & r_02_b[4] & r_02_b[5] & r_02_b[6] & r_02_b[7]));

   assign r_03_b[0] = (~(dcd_000 & combo3_1111_1000));
   assign r_03_b[1] = (~(dcd_001 & tidn));
   assign r_03_b[2] = (~(dcd_010 & combo3_0111_1111));
   assign r_03_b[3] = (~(dcd_011 & tiup));
   assign r_03_b[4] = (~(dcd_100 & combo3_1100_0000));
   assign r_03_b[5] = (~(dcd_101 & tidn));
   assign r_03_b[6] = (~(dcd_110 & tidn));
   assign r_03_b[7] = (~(dcd_111 & tidn));

   assign r[3] = (~(r_03_b[0] & r_03_b[1] & r_03_b[2] & r_03_b[3] & r_03_b[4] & r_03_b[5] & r_03_b[6] & r_03_b[7]));

   assign r_04_b[0] = (~(dcd_000 & combo3_1000_0111));
   assign r_04_b[1] = (~(dcd_001 & combo3_1110_0000));
   assign r_04_b[2] = (~(dcd_010 & combo3_0111_1111));
   assign r_04_b[3] = (~(dcd_011 & tidn));
   assign r_04_b[4] = (~(dcd_100 & combo3_0011_1111));
   assign r_04_b[5] = (~(dcd_101 & combo3_1111_1100));
   assign r_04_b[6] = (~(dcd_110 & tidn));
   assign r_04_b[7] = (~(dcd_111 & tidn));

   assign r[4] = (~(r_04_b[0] & r_04_b[1] & r_04_b[2] & r_04_b[3] & r_04_b[4] & r_04_b[5] & r_04_b[6] & r_04_b[7]));

   assign r_05_b[0] = (~(dcd_000 & combo3_0110_0111));
   assign r_05_b[1] = (~(dcd_001 & combo3_0001_1000));
   assign r_05_b[2] = (~(dcd_010 & combo3_0111_0000));
   assign r_05_b[3] = (~(dcd_011 & combo3_1111_1000));
   assign r_05_b[4] = (~(dcd_100 & combo3_0011_1111));
   assign r_05_b[5] = (~(dcd_101 & combo3_0000_0011));
   assign r_05_b[6] = (~(dcd_110 & combo3_1111_1100));
   assign r_05_b[7] = (~(dcd_111 & tidn));

   assign r[5] = (~(r_05_b[0] & r_05_b[1] & r_05_b[2] & r_05_b[3] & r_05_b[4] & r_05_b[5] & r_05_b[6] & r_05_b[7]));

   assign r_06_b[0] = (~(dcd_000 & combo3_0101_0110));
   assign r_06_b[1] = (~(dcd_001 & combo3_1001_0110));
   assign r_06_b[2] = (~(dcd_010 & combo3_0100_1100));
   assign r_06_b[3] = (~(dcd_011 & combo3_1100_0110));
   assign r_06_b[4] = (~(dcd_100 & combo3_0011_0000));
   assign r_06_b[5] = (~(dcd_101 & combo3_1110_0011));
   assign r_06_b[6] = (~(dcd_110 & combo3_1100_0011));
   assign r_06_b[7] = (~(dcd_111 & combo3_1110_0000));

   assign r[6] = (~(r_06_b[0] & r_06_b[1] & r_06_b[2] & r_06_b[3] & r_06_b[4] & r_06_b[5] & r_06_b[6] & r_06_b[7]));

   assign r_07_b[0] = (~(dcd_000 & combo3_1111_1100));
   assign r_07_b[1] = (~(dcd_001 & combo3_1100_1101));
   assign r_07_b[2] = (~(dcd_010 & combo3_0010_1010));
   assign r_07_b[3] = (~(dcd_011 & combo3_1010_0101));
   assign r_07_b[4] = (~(dcd_100 & combo3_0010_1100));
   assign r_07_b[5] = (~(dcd_101 & combo3_1001_1011));
   assign r_07_b[6] = (~(dcd_110 & combo3_0011_0011));
   assign r_07_b[7] = (~(dcd_111 & combo3_1001_1000));

   assign r[7] = (~(r_07_b[0] & r_07_b[1] & r_07_b[2] & r_07_b[3] & r_07_b[4] & r_07_b[5] & r_07_b[6] & r_07_b[7]));

   assign r_08_b[0] = (~(dcd_000 & combo3_0001_1101));
   assign r_08_b[1] = (~(dcd_001 & combo3_0101_0110));
   assign r_08_b[2] = (~(dcd_010 & combo3_0111_1111));
   assign r_08_b[3] = (~(dcd_011 & combo3_1111_0001));
   assign r_08_b[4] = (~(dcd_100 & combo3_1001_1010));
   assign r_08_b[5] = (~(dcd_101 & combo3_0101_0010));
   assign r_08_b[6] = (~(dcd_110 & combo3_1010_1010));
   assign r_08_b[7] = (~(dcd_111 & combo3_0101_0110));

   assign r[8] = (~(r_08_b[0] & r_08_b[1] & r_08_b[2] & r_08_b[3] & r_08_b[4] & r_08_b[5] & r_08_b[6] & r_08_b[7]));

   assign r_09_b[0] = (~(dcd_000 & combo3_1110_0110));
   assign r_09_b[1] = (~(dcd_001 & combo3_0000_1101));
   assign r_09_b[2] = (~(dcd_010 & combo3_0110_0000));
   assign r_09_b[3] = (~(dcd_011 & combo3_0011_0110));
   assign r_09_b[4] = (~(dcd_100 & combo3_1010_1100));
   assign r_09_b[5] = (~(dcd_101 & combo3_1100_0111));
   assign r_09_b[6] = (~(dcd_110 & tiup));
   assign r_09_b[7] = (~(dcd_111 & combo3_0001_1100));

   assign r[9] = (~(r_09_b[0] & r_09_b[1] & r_09_b[2] & r_09_b[3] & r_09_b[4] & r_09_b[5] & r_09_b[6] & r_09_b[7]));

   assign r_10_b[0] = (~(dcd_000 & combo3_1110_1101));
   assign r_10_b[1] = (~(dcd_001 & combo3_0001_0111));
   assign r_10_b[2] = (~(dcd_010 & combo3_1101_1000));
   assign r_10_b[3] = (~(dcd_011 & combo3_1101_0011));
   assign r_10_b[4] = (~(dcd_100 & combo3_1111_1010));
   assign r_10_b[5] = (~(dcd_101 & combo3_1010_0110));
   assign r_10_b[6] = (~(dcd_110 & combo3_0000_0111));
   assign r_10_b[7] = (~(dcd_111 & combo3_0010_0101));

   assign r[10] = (~(r_10_b[0] & r_10_b[1] & r_10_b[2] & r_10_b[3] & r_10_b[4] & r_10_b[5] & r_10_b[6] & r_10_b[7]));

   assign r_11_b[0] = (~(dcd_000 & combo3_1011_1100));
   assign r_11_b[1] = (~(dcd_001 & combo3_1010_0000));
   assign r_11_b[2] = (~(dcd_010 & combo3_0111_0111));
   assign r_11_b[3] = (~(dcd_011 & combo3_0111_1010));
   assign r_11_b[4] = (~(dcd_100 & combo3_0001_1100));
   assign r_11_b[5] = (~(dcd_101 & combo3_0001_0101));
   assign r_11_b[6] = (~(dcd_110 & combo3_1111_1001));
   assign r_11_b[7] = (~(dcd_111 & combo3_0100_1111));

   assign r[11] = (~(r_11_b[0] & r_11_b[1] & r_11_b[2] & r_11_b[3] & r_11_b[4] & r_11_b[5] & r_11_b[6] & r_11_b[7]));

   assign r_12_b[0] = (~(dcd_000 & combo3_0100_1110));
   assign r_12_b[1] = (~(dcd_001 & combo3_0100_0100));
   assign r_12_b[2] = (~(dcd_010 & combo3_1101_1111));
   assign r_12_b[3] = (~(dcd_011 & combo3_1100_0000));
   assign r_12_b[4] = (~(dcd_100 & combo3_0000_1010));
   assign r_12_b[5] = (~(dcd_101 & combo3_0010_0001));
   assign r_12_b[6] = (~(dcd_110 & combo3_0000_1011));
   assign r_12_b[7] = (~(dcd_111 & combo3_1110_1000));

   assign r[12] = (~(r_12_b[0] & r_12_b[1] & r_12_b[2] & r_12_b[3] & r_12_b[4] & r_12_b[5] & r_12_b[6] & r_12_b[7]));

   assign r_13_b[0] = (~(dcd_000 & combo3_1010_1001));
   assign r_13_b[1] = (~(dcd_001 & combo3_0001_0100));
   assign r_13_b[2] = (~(dcd_010 & combo3_0111_0101));
   assign r_13_b[3] = (~(dcd_011 & combo3_0000_1001));
   assign r_13_b[4] = (~(dcd_100 & combo3_0010_1000));
   assign r_13_b[5] = (~(dcd_101 & combo3_0000_0011));
   assign r_13_b[6] = (~(dcd_110 & combo3_1001_0010));
   assign r_13_b[7] = (~(dcd_111 & combo3_0010_0100));

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
