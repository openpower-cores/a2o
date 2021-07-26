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

// 11111111111111000000 111111000000101 0
// 11111000000110111001 111101000110110 1
// 11110000011110000001 111011010010000 2
// 11101001000011110001 111001100010010 3
// 11100001110111011111 110111110111100 4
// 11011010111000100001 110110010001100 5
// 11010100000110010101 110100101111100 6
// 11001101100000010111 110011010001110 7
// 11000111000110000111 110001111000000 8
// 11000000110111000111 110000100001100 9
// 10111010110010111001 101111001110110 10
// 10110100111001000001 101101111111010 11
// 10101111001001000111 101100110010110 12
// 10101001100010101111 101011101001010 13
// 10100100000101100101 101010100010100 14
// 10011110110001001111 101001011110100 15
// 10011001100101011001 101000011101000 16
// 10010100100001110001 100111011101110 17
// 10001111100110000001 100110100001000 18
// 10001010110001111001 100101100110010 19
// 10000110000101000111 100100101101110 20
// 10000001011111011001 100011110111000 21
// 01111101000000011111 100011000010010 22
// 01111000101000001101 100010001111010 23
// 01110100010110010001 100001011110000 24
// 01110000001010100001 100000101110100 25
// 01101100000100101101 100000000000100 26
// 01101000000100101001 011111010011110 27
// 01100100001010001001 011110101000110 28
// 01100000010101000001 011101111111000 29
// 01011100100101001001 011101010110100 30
// 01011000111010010011 011100101111100 31
// 01010101010100010101 011100001001100 32
// 01010001110011000111 011011100100110 33
// 01001110010110100001 011011000001010 34
// 01001010111110010111 011010011110100 35
// 01000111101010100001 011001111101000 36
// 01000100011010111001 011001011100100 37
// 01000001001111010101 011000111100110 38
// 00111110000111101101 011000011110000 39
// 00111011000011111011 011000000000010 40
// 00111000000011111001 010111100011010 41
// 00110101000111011101 010111000111000 42
// 00110010001110100011 010110101011110 43
// 00101111011001000101 010110010001000 44
// 00101100100110111011 010101110111010 45
// 00101001111000000001 010101011110000 46
// 00100111001100010001 010101000101100 47
// 00100100100011100101 010100101101100 48
// 00100001111101110111 010100010110010 49
// 00011111011011000101 010011111111100 50
// 00011100111011000111 010011101001100 51
// 00011010011101111001 010011010100000 52
// 00011000000011011001 010010111111000 53
// 00010101101011011111 010010101010110 54
// 00010011010110001001 010010010110110 55
// 00010001000011010001 010010000011010 56
// 00001110110010110101 010001110000100 57
// 00001100100100110001 010001011110000 58
// 00001010011001000001 010001001100000 59
// 00001000001111100001 010000111010010 60
// 00000110001000001101 010000101001000 61
// 00000100000011000101 010000011000010 62
// 00000010000000000001 010000001000000 63

module fu_tblres(
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

   assign combo3_0000_0001 = (~(combo2_xxxx_0001_b));		//i=1, 2 1
   assign combo3_0000_0010 = (~(combo2_xxxx_0010_b));		//i=2, 1 2
   assign combo3_0000_0011 = (~(combo2_xxxx_0011_b));		//i=3, 3 3
   assign combo3_0000_0100 = (~(combo2_xxxx_0100_b));		//i=4, 1 4
   assign combo3_0000_0101 = (~(combo2_xxxx_0101_b));		//i=5, 2 5
   assign combo3_0000_0110 = (~(combo2_xxxx_0110_b));		//i=6, 2 6
   assign combo3_0000_1001 = (~(combo2_xxxx_1001_b));		//i=9, 1 7
   assign combo3_0000_1010 = (~(combo2_xxxx_1010_b));		//i=10, 2 8
   assign combo3_0000_1011 = (~(combo2_xxxx_1011_b));		//i=11, 2 9
   assign combo3_0000_1110 = (~(combo2_xxxx_1110_b));		//i=14, 1 10
   assign combo3_0000_1111 = (~((~f[4])));		//i=15, 2 11
   assign combo3_0001_0001 = (~((~combo2_0001)));		//i=17, 2 12*
   assign combo3_0001_0010 = (~(combo2_0001_xxxx_b & combo2_xxxx_0010_b));		//i=18, 1 13
   assign combo3_0001_0100 = (~(combo2_0001_xxxx_b & combo2_xxxx_0100_b));		//i=20, 1 14
   assign combo3_0001_0101 = (~(combo2_0001_xxxx_b & combo2_xxxx_0101_b));		//i=21, 1 15
   assign combo3_0001_0111 = (~(combo2_0001_xxxx_b & combo2_xxxx_0111_b));		//i=23, 1 16
   assign combo3_0001_1000 = (~(combo2_0001_xxxx_b & combo2_xxxx_1000_b));		//i=24, 3 17
   assign combo3_0001_1010 = (~(combo2_0001_xxxx_b & combo2_xxxx_1010_b));		//i=26, 1 18
   assign combo3_0001_1011 = (~(combo2_0001_xxxx_b & combo2_xxxx_1011_b));		//i=27, 1 19
   assign combo3_0001_1100 = (~(combo2_0001_xxxx_b & combo2_xxxx_1100_b));		//i=28, 1 20
   assign combo3_0001_1110 = (~(combo2_0001_xxxx_b & combo2_xxxx_1110_b));		//i=30, 1 21
   assign combo3_0001_1111 = (~(combo2_0001_xxxx_b & (~f[4])));		//i=31, 4 22
   assign combo3_0010_0000 = (~(combo2_0010_xxxx_b));		//i=32, 2 23
   assign combo3_0010_0100 = (~(combo2_0010_xxxx_b & combo2_xxxx_0100_b));		//i=36, 1 24
   assign combo3_0010_0101 = (~(combo2_0010_xxxx_b & combo2_xxxx_0101_b));		//i=37, 1 25
   assign combo3_0010_0110 = (~(combo2_0010_xxxx_b & combo2_xxxx_0110_b));		//i=38, 2 26
   assign combo3_0010_0111 = (~(combo2_0010_xxxx_b & combo2_xxxx_0111_b));		//i=39, 1 27
   assign combo3_0010_1000 = (~(combo2_0010_xxxx_b & combo2_xxxx_1000_b));		//i=40, 2 28
   assign combo3_0010_1001 = (~(combo2_0010_xxxx_b & combo2_xxxx_1001_b));		//i=41, 1 29
   assign combo3_0010_1101 = (~(combo2_0010_xxxx_b & combo2_xxxx_1101_b));		//i=45, 4 30
   assign combo3_0011_0000 = (~(combo2_0011_xxxx_b));		//i=48, 1 31
   assign combo3_0011_0001 = (~(combo2_0011_xxxx_b & combo2_xxxx_0001_b));		//i=49, 3 32
   assign combo3_0011_0011 = (~((~combo2_0011)));		//i=51, 1 33*
   assign combo3_0011_0101 = (~(combo2_0011_xxxx_b & combo2_xxxx_0101_b));		//i=53, 1 34
   assign combo3_0011_1000 = (~(combo2_0011_xxxx_b & combo2_xxxx_1000_b));		//i=56, 3 35
   assign combo3_0011_1001 = (~(combo2_0011_xxxx_b & combo2_xxxx_1001_b));		//i=57, 1 36
   assign combo3_0011_1010 = (~(combo2_0011_xxxx_b & combo2_xxxx_1010_b));		//i=58, 1 37
   assign combo3_0011_1011 = (~(combo2_0011_xxxx_b & combo2_xxxx_1011_b));		//i=59, 1 38
   assign combo3_0011_1100 = (~(combo2_0011_xxxx_b & combo2_xxxx_1100_b));		//i=60, 3 39
   assign combo3_0011_1110 = (~(combo2_0011_xxxx_b & combo2_xxxx_1110_b));		//i=62, 1 40
   assign combo3_0011_1111 = (~(combo2_0011_xxxx_b & (~f[4])));		//i=63, 4 41
   assign combo3_0100_0000 = (~(combo2_0100_xxxx_b));		//i=64, 1 42
   assign combo3_0100_0011 = (~(combo2_0100_xxxx_b & combo2_xxxx_0011_b));		//i=67, 2 43
   assign combo3_0100_0110 = (~(combo2_0100_xxxx_b & combo2_xxxx_0110_b));		//i=70, 1 44
   assign combo3_0100_1000 = (~(combo2_0100_xxxx_b & combo2_xxxx_1000_b));		//i=72, 2 45
   assign combo3_0100_1001 = (~(combo2_0100_xxxx_b & combo2_xxxx_1001_b));		//i=73, 2 46
   assign combo3_0100_1010 = (~(combo2_0100_xxxx_b & combo2_xxxx_1010_b));		//i=74, 2 47
   assign combo3_0100_1100 = (~(combo2_0100_xxxx_b & combo2_xxxx_1100_b));		//i=76, 1 48
   assign combo3_0100_1101 = (~(combo2_0100_xxxx_b & combo2_xxxx_1101_b));		//i=77, 1 49
   assign combo3_0100_1110 = (~(combo2_0100_xxxx_b & combo2_xxxx_1110_b));		//i=78, 1 50
   assign combo3_0101_0000 = (~(combo2_0101_xxxx_b));		//i=80, 3 51
   assign combo3_0101_0001 = (~(combo2_0101_xxxx_b & combo2_xxxx_0001_b));		//i=81, 1 52
   assign combo3_0101_0010 = (~(combo2_0101_xxxx_b & combo2_xxxx_0010_b));		//i=82, 1 53
   assign combo3_0101_0100 = (~(combo2_0101_xxxx_b & combo2_xxxx_0100_b));		//i=84, 3 54
   assign combo3_0101_0101 = (~((~combo2_0101)));		//i=85, 1 55*
   assign combo3_0101_0110 = (~(combo2_0101_xxxx_b & combo2_xxxx_0110_b));		//i=86, 1 56
   assign combo3_0101_1000 = (~(combo2_0101_xxxx_b & combo2_xxxx_1000_b));		//i=88, 1 57
   assign combo3_0101_1011 = (~(combo2_0101_xxxx_b & combo2_xxxx_1011_b));		//i=91, 3 58
   assign combo3_0101_1111 = (~(combo2_0101_xxxx_b & (~f[4])));		//i=95, 1 59
   assign combo3_0110_0000 = (~(combo2_0110_xxxx_b));		//i=96, 1 60
   assign combo3_0110_0010 = (~(combo2_0110_xxxx_b & combo2_xxxx_0010_b));		//i=98, 1 61
   assign combo3_0110_0011 = (~(combo2_0110_xxxx_b & combo2_xxxx_0011_b));		//i=99, 1 62
   assign combo3_0110_0110 = (~((~combo2_0110)));		//i=102, 1 63*
   assign combo3_0110_0111 = (~(combo2_0110_xxxx_b & combo2_xxxx_0111_b));		//i=103, 3 64
   assign combo3_0110_1000 = (~(combo2_0110_xxxx_b & combo2_xxxx_1000_b));		//i=104, 1 65
   assign combo3_0110_1010 = (~(combo2_0110_xxxx_b & combo2_xxxx_1010_b));		//i=106, 2 66
   assign combo3_0110_1011 = (~(combo2_0110_xxxx_b & combo2_xxxx_1011_b));		//i=107, 1 67
   assign combo3_0110_1100 = (~(combo2_0110_xxxx_b & combo2_xxxx_1100_b));		//i=108, 1 68
   assign combo3_0110_1101 = (~(combo2_0110_xxxx_b & combo2_xxxx_1101_b));		//i=109, 1 69
   assign combo3_0111_0000 = (~(combo2_0111_xxxx_b));		//i=112, 3 70
   assign combo3_0111_0001 = (~(combo2_0111_xxxx_b & combo2_xxxx_0001_b));		//i=113, 1 71
   assign combo3_0111_0101 = (~(combo2_0111_xxxx_b & combo2_xxxx_0101_b));		//i=117, 1 72
   assign combo3_0111_0110 = (~(combo2_0111_xxxx_b & combo2_xxxx_0110_b));		//i=118, 1 73
   assign combo3_0111_1000 = (~(combo2_0111_xxxx_b & combo2_xxxx_1000_b));		//i=120, 3 74
   assign combo3_0111_1001 = (~(combo2_0111_xxxx_b & combo2_xxxx_1001_b));		//i=121, 1 75
   assign combo3_0111_1010 = (~(combo2_0111_xxxx_b & combo2_xxxx_1010_b));		//i=122, 2 76
   assign combo3_0111_1011 = (~(combo2_0111_xxxx_b & combo2_xxxx_1011_b));		//i=123, 1 77
   assign combo3_0111_1101 = (~(combo2_0111_xxxx_b & combo2_xxxx_1101_b));		//i=125, 1 78
   assign combo3_0111_1111 = (~(combo2_0111_xxxx_b & (~f[4])));		//i=127, 3 79
   assign combo3_1000_0000 = (~(combo2_1000_xxxx_b));		//i=128, 7 80
   assign combo3_1000_0001 = (~(combo2_1000_xxxx_b & combo2_xxxx_0001_b));		//i=129, 1 81
   assign combo3_1000_0011 = (~(combo2_1000_xxxx_b & combo2_xxxx_0011_b));		//i=131, 1 82
   assign combo3_1000_0100 = (~(combo2_1000_xxxx_b & combo2_xxxx_0100_b));		//i=132, 2 83
   assign combo3_1000_0101 = (~(combo2_1000_xxxx_b & combo2_xxxx_0101_b));		//i=133, 1 84
   assign combo3_1000_1010 = (~(combo2_1000_xxxx_b & combo2_xxxx_1010_b));		//i=138, 1 85
   assign combo3_1000_1100 = (~(combo2_1000_xxxx_b & combo2_xxxx_1100_b));		//i=140, 1 86
   assign combo3_1000_1101 = (~(combo2_1000_xxxx_b & combo2_xxxx_1101_b));		//i=141, 1 87
   assign combo3_1001_0100 = (~(combo2_1001_xxxx_b & combo2_xxxx_0100_b));		//i=148, 1 88
   assign combo3_1001_0110 = (~(combo2_1001_xxxx_b & combo2_xxxx_0110_b));		//i=150, 3 89
   assign combo3_1001_0111 = (~(combo2_1001_xxxx_b & combo2_xxxx_0111_b));		//i=151, 1 90
   assign combo3_1001_1000 = (~(combo2_1001_xxxx_b & combo2_xxxx_1000_b));		//i=152, 1 91
   assign combo3_1001_1001 = (~((~combo2_1001)));		//i=153, 3 92*
   assign combo3_1001_1010 = (~(combo2_1001_xxxx_b & combo2_xxxx_1010_b));		//i=154, 1 93
   assign combo3_1001_1011 = (~(combo2_1001_xxxx_b & combo2_xxxx_1011_b));		//i=155, 1 94
   assign combo3_1001_1111 = (~(combo2_1001_xxxx_b & (~f[4])));		//i=159, 1 95
   assign combo3_1010_0100 = (~(combo2_1010_xxxx_b & combo2_xxxx_0100_b));		//i=164, 1 96
   assign combo3_1010_0110 = (~(combo2_1010_xxxx_b & combo2_xxxx_0110_b));		//i=166, 1 97
   assign combo3_1010_1000 = (~(combo2_1010_xxxx_b & combo2_xxxx_1000_b));		//i=168, 2 98
   assign combo3_1010_1001 = (~(combo2_1010_xxxx_b & combo2_xxxx_1001_b));		//i=169, 1 99
   assign combo3_1010_1010 = (~((~combo2_1010)));		//i=170, 1 100*
   assign combo3_1010_1011 = (~(combo2_1010_xxxx_b & combo2_xxxx_1011_b));		//i=171, 1 101
   assign combo3_1010_1100 = (~(combo2_1010_xxxx_b & combo2_xxxx_1100_b));		//i=172, 2 102
   assign combo3_1010_1101 = (~(combo2_1010_xxxx_b & combo2_xxxx_1101_b));		//i=173, 2 103
   assign combo3_1011_0010 = (~(combo2_1011_xxxx_b & combo2_xxxx_0010_b));		//i=178, 1 104
   assign combo3_1011_0011 = (~(combo2_1011_xxxx_b & combo2_xxxx_0011_b));		//i=179, 3 105
   assign combo3_1011_0100 = (~(combo2_1011_xxxx_b & combo2_xxxx_0100_b));		//i=180, 1 106
   assign combo3_1011_0101 = (~(combo2_1011_xxxx_b & combo2_xxxx_0101_b));		//i=181, 2 107
   assign combo3_1011_0110 = (~(combo2_1011_xxxx_b & combo2_xxxx_0110_b));		//i=182, 3 108
   assign combo3_1011_0111 = (~(combo2_1011_xxxx_b & combo2_xxxx_0111_b));		//i=183, 1 109
   assign combo3_1100_0000 = (~(combo2_1100_xxxx_b));		//i=192, 4 110
   assign combo3_1100_0001 = (~(combo2_1100_xxxx_b & combo2_xxxx_0001_b));		//i=193, 1 111
   assign combo3_1100_0010 = (~(combo2_1100_xxxx_b & combo2_xxxx_0010_b));		//i=194, 1 112
   assign combo3_1100_0011 = (~(combo2_1100_xxxx_b & combo2_xxxx_0011_b));		//i=195, 2 113
   assign combo3_1100_0100 = (~(combo2_1100_xxxx_b & combo2_xxxx_0100_b));		//i=196, 1 114
   assign combo3_1100_0111 = (~(combo2_1100_xxxx_b & combo2_xxxx_0111_b));		//i=199, 1 115
   assign combo3_1100_1000 = (~(combo2_1100_xxxx_b & combo2_xxxx_1000_b));		//i=200, 1 116
   assign combo3_1100_1001 = (~(combo2_1100_xxxx_b & combo2_xxxx_1001_b));		//i=201, 2 117
   assign combo3_1100_1010 = (~(combo2_1100_xxxx_b & combo2_xxxx_1010_b));		//i=202, 2 118
   assign combo3_1100_1101 = (~(combo2_1100_xxxx_b & combo2_xxxx_1101_b));		//i=205, 2 119
   assign combo3_1100_1110 = (~(combo2_1100_xxxx_b & combo2_xxxx_1110_b));		//i=206, 2 120
   assign combo3_1100_1111 = (~(combo2_1100_xxxx_b & (~f[4])));		//i=207, 2 121
   assign combo3_1101_0010 = (~(combo2_1101_xxxx_b & combo2_xxxx_0010_b));		//i=210, 1 122
   assign combo3_1101_0011 = (~(combo2_1101_xxxx_b & combo2_xxxx_0011_b));		//i=211, 1 123
   assign combo3_1101_0100 = (~(combo2_1101_xxxx_b & combo2_xxxx_0100_b));		//i=212, 2 124
   assign combo3_1101_0101 = (~(combo2_1101_xxxx_b & combo2_xxxx_0101_b));		//i=213, 1 125
   assign combo3_1101_0110 = (~(combo2_1101_xxxx_b & combo2_xxxx_0110_b));		//i=214, 2 126
   assign combo3_1101_0111 = (~(combo2_1101_xxxx_b & combo2_xxxx_0111_b));		//i=215, 1 127
   assign combo3_1101_1100 = (~(combo2_1101_xxxx_b & combo2_xxxx_1100_b));		//i=220, 1 128
   assign combo3_1101_1101 = (~((~combo2_1101)));		//i=221, 1 129*
   assign combo3_1101_1110 = (~(combo2_1101_xxxx_b & combo2_xxxx_1110_b));		//i=222, 1 130
   assign combo3_1110_0000 = (~(combo2_1110_xxxx_b));		//i=224, 2 131
   assign combo3_1110_0100 = (~(combo2_1110_xxxx_b & combo2_xxxx_0100_b));		//i=228, 2 132
   assign combo3_1110_0101 = (~(combo2_1110_xxxx_b & combo2_xxxx_0101_b));		//i=229, 1 133
   assign combo3_1110_0110 = (~(combo2_1110_xxxx_b & combo2_xxxx_0110_b));		//i=230, 1 134
   assign combo3_1110_1000 = (~(combo2_1110_xxxx_b & combo2_xxxx_1000_b));		//i=232, 1 135
   assign combo3_1110_1010 = (~(combo2_1110_xxxx_b & combo2_xxxx_1010_b));		//i=234, 1 136
   assign combo3_1110_1101 = (~(combo2_1110_xxxx_b & combo2_xxxx_1101_b));		//i=237, 2 137
   assign combo3_1111_0000 = (~(f[4]));		//i=240, 2 138
   assign combo3_1111_0001 = (~(f[4] & combo2_xxxx_0001_b));		//i=241, 1 139
   assign combo3_1111_0010 = (~(f[4] & combo2_xxxx_0010_b));		//i=242, 1 140
   assign combo3_1111_0100 = (~(f[4] & combo2_xxxx_0100_b));		//i=244, 2 141
   assign combo3_1111_1000 = (~(f[4] & combo2_xxxx_1000_b));		//i=248, 1 142
   assign combo3_1111_1001 = (~(f[4] & combo2_xxxx_1001_b));		//i=249, 1 143
   assign combo3_1111_1010 = (~(f[4] & combo2_xxxx_1010_b));		//i=250, 1 144
   assign combo3_1111_1100 = (~(f[4] & combo2_xxxx_1100_b));		//i=252, 2 145
   assign combo3_1111_1110 = (~(f[4] & combo2_xxxx_1110_b));		//i=254, 2 146

   ////#######################################
   ////## ESTIMATE VECTORs
   ////#######################################

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

   ////#######################################
   ////## RANGE VECTORs
   ////#######################################

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

   ////#######################################
   ////## RENUMBERING OUTPUTS
   ////#######################################

   assign est[1:20] = e[0:19];		// renumbering
   assign rng[6:20] = r[0:14];		// renumbering

endmodule
