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

// VHDL 1076 Macro Expander C version 07/11/00
// job was run on Tue Feb  1 10:11:27 2011

//********************************************************************
//*
//* TITLE:
//*
//* NAME: iuq_cpl_dec.v
//*
//*********************************************************************
module iuq_cpl_dec(
   input [0:31] cp2_instr,
   output       cp2_ld,
   output       cp2_st,
   output       cp2_epid);

   wire [1:7]   TBL_EPID_DEC_PT;
   wire [1:41]  TBL_LD_ST_PT;
   //@@ START OF EXECUTABLE CODE FOR IUQ_CPL_DEC
   //
   // Final Table Listing
   //      *INPUTS*=============*OUTPUTS*=====*
   //      |                    |             |
   //      | cp2_instr          | cp2_epid    |
   //      | |      cp2_instr   | |           |
   //      | |      |           | |           |
   //      | 000000 2222222223  | |           |
   //      | 012345 1234567890  | |           |
   //      *TYPE*===============+=============+
   //      | PPPPPP PPPPPPPPPP  | P           |
   //      *POLARITY*---------->| +           |
   //      *PHASE*------------->| T           |
   //      *TERMS*==============+=============+
   //    1 | 011111 1110110110  | 1           |
   //    2 | 011111 1111-11111  | 1           |
   //    3 | 011111 00-00111-1  | 1           |
   //    4 | 011111 0-00-11111  | 1           |
   //    5 | 011111 -0-1011111  | 1           |
   //    6 | 011111 00-1-11111  | 1           |
   //    7 | 011111 0--0011111  | 1           |
   //      *==================================*
   //
   // Table TBL_EPID_DEC Signal Assignments for Product Terms
   assign TBL_EPID_DEC_PT[1] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 16'b0111111110110110);
   assign TBL_EPID_DEC_PT[2] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 15'b011111111111111);
   assign TBL_EPID_DEC_PT[3] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[30]}) === 14'b01111100001111);
   assign TBL_EPID_DEC_PT[4] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[23], cp2_instr[24], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 14'b01111100011111);
   assign TBL_EPID_DEC_PT[5] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[22], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 14'b01111101011111);
   assign TBL_EPID_DEC_PT[6] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[24], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 14'b01111100111111);
   assign TBL_EPID_DEC_PT[7] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 14'b01111100011111);

   // Table TBL_EPID_DEC Signal Assignments for Outputs
   assign cp2_epid = (TBL_EPID_DEC_PT[1] | TBL_EPID_DEC_PT[2] | TBL_EPID_DEC_PT[3] | TBL_EPID_DEC_PT[4] | TBL_EPID_DEC_PT[5] | TBL_EPID_DEC_PT[6] | TBL_EPID_DEC_PT[7]);
   //
   // Final Table Listing
   //      *INPUTS*===========================*OUTPUTS*============*
   //      |                                  |                    |
   //      | cp2_instr                        |                    |
   //      | |      cp2_instr                 |                    |
   //      | |      | cp2_instr               |                    |
   //      | |      | |          cp2_instr    |                    |
   //      | |      | |          |            | cp2_ld             |
   //      | |      | |          |            | | cp2_st           |
   //      | 000000 0 2222222223 33           | | |                |
   //      | 012345 9 1234567890 01           | | |                |
   //      *TYPE*=============================+====================+
   //      | PPPPPP P PPPPPPPPPP PP           | P P                |
   //      *POLARITY*------------------------>| + +                |
   //      *PHASE*--------------------------->| T T                |
   //      *TERMS*============================+====================+
   //    1 | 011111 - 1-10-10110 0-           | . 1                |
   //    2 | 011111 - 000-01011- --           | 1 .                |
   //    3 | 011111 - 0-1001011- 0-           | . 1                |
   //    4 | 011111 - 101001010- --           | . 1                |
   //    5 | 011111 - -00001010- --           | 1 .                |
   //    6 | 011111 - 1111111111 --           | . 1                |
   //    7 | 011111 - 0-11100110 --           | 1 .                |
   //    8 | 011111 - 1111110110 --           | . 1                |
   //    9 | 011111 - 1111011111 --           | 1 .                |
   //   10 | 011111 - 0101-101-1 --           | 1 .                |
   //   11 | 011111 - 101-010101 --           | . 1                |
   //   12 | 011111 - 0110000110 --           | 1 .                |
   //   13 | 011111 - 001-100110 --           | 1 .                |
   //   14 | 011111 - 0-00-1-111 --           | 1 .                |
   //   15 | 011111 - 001001-1-1 --           | . 1                |
   //   16 | 011111 - 0011-1-111 --           | . 1                |
   //   17 | 011111 - 100-010101 --           | 1 .                |
   //   18 | 011111 - 00100-0110 --           | . 1                |
   //   19 | 011111 - 000001-1-1 --           | 1 .                |
   //   20 | 011111 - 000--1-111 --           | 1 .                |
   //   21 | 011111 - 1-10010110 --           | . 1                |
   //   22 | 011111 - 1010-10110 --           | . 1                |
   //   23 | 011111 - 1111010110 --           | 1 .                |
   //   24 | 011111 - 0-1001-111 --           | . 1                |
   //   25 | 011111 - --00010110 --           | 1 .                |
   //   26 | 011111 - -01-010110 --           | . 1                |
   //   27 | 011111 - 0010-101-1 --           | . 1                |
   //   28 | 011111 - 00-1010100 --           | 1 .                |
   //   29 | 011111 - 0000-101-1 --           | 1 .                |
   //   30 | 011111 - 0-11010110 --           | . 1                |
   //   31 | 011111 - 0-10-10111 --           | . 1                |
   //   32 | 011111 - 00111-0110 --           | 1 .                |
   //   33 | 011111 - 0000-1011- --           | 1 .                |
   //   34 | 10-0-- - ---------- --           | 1 .                |
   //   35 | 1-1010 - ---------- -0           | 1 .                |
   //   36 | 1-1010 - ---------- 0-           | 1 .                |
   //   37 | 10-10- - ---------- --           | . 1                |
   //   38 | 111110 - ---------- 0-           | . 1                |
   //   39 | 1001-- - ---------- --           | . 1                |
   //   40 | 101-10 - ---------- --           | 1 .                |
   //   41 | 10-1-1 - ---------- --           | . 1                |
   //      *=======================================================*
   //
   // Table TBL_LD_ST Signal Assignments for Product Terms
   assign TBL_LD_ST_PT[1] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[23], cp2_instr[24], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30], cp2_instr[30]}) === 15'b011111110101100);
   assign TBL_LD_ST_PT[2] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29]}) === 14'b01111100001011);
   assign TBL_LD_ST_PT[3] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 15'b011111010010110);
   assign TBL_LD_ST_PT[4] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29]}) === 15'b011111101001010);
   assign TBL_LD_ST_PT[5] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29]}) === 14'b01111100001010);
   assign TBL_LD_ST_PT[6] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 16'b0111111111111111);
   assign TBL_LD_ST_PT[7] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 15'b011111011100110);
   assign TBL_LD_ST_PT[8] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 16'b0111111111110110);
   assign TBL_LD_ST_PT[9] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 16'b0111111111011111);
   assign TBL_LD_ST_PT[10] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[30]}) === 14'b01111101011011);
   assign TBL_LD_ST_PT[11] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 15'b011111101010101);
   assign TBL_LD_ST_PT[12] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 16'b0111110110000110);
   assign TBL_LD_ST_PT[13] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 15'b011111001100110);
   assign TBL_LD_ST_PT[14] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[23], cp2_instr[24], cp2_instr[26], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 13'b0111110001111);
   assign TBL_LD_ST_PT[15] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[28], cp2_instr[30]}) === 14'b01111100100111);
   assign TBL_LD_ST_PT[16] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[26], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 14'b01111100111111);
   assign TBL_LD_ST_PT[17] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 15'b011111100010101);
   assign TBL_LD_ST_PT[18] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 15'b011111001000110);
   assign TBL_LD_ST_PT[19] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[28], cp2_instr[30]}) === 14'b01111100000111);
   assign TBL_LD_ST_PT[20] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[26], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 13'b0111110001111);
   assign TBL_LD_ST_PT[21] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 15'b011111110010110);
   assign TBL_LD_ST_PT[22] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 15'b011111101010110);
   assign TBL_LD_ST_PT[23] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 16'b0111111111010110);
   assign TBL_LD_ST_PT[24] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 14'b01111101001111);
   assign TBL_LD_ST_PT[25] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 14'b01111100010110);
   assign TBL_LD_ST_PT[26] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[22], cp2_instr[23], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 14'b01111101010110);
   assign TBL_LD_ST_PT[27] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[30]}) === 14'b01111100101011);
   assign TBL_LD_ST_PT[28] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 15'b011111001010100);
   assign TBL_LD_ST_PT[29] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[30]}) === 14'b01111100001011);
   assign TBL_LD_ST_PT[30] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 15'b011111011010110);
   assign TBL_LD_ST_PT[31] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[23], cp2_instr[24], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 14'b01111101010111);
   assign TBL_LD_ST_PT[32] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 15'b011111001110110);
   assign TBL_LD_ST_PT[33] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29]}) === 14'b01111100001011);
   assign TBL_LD_ST_PT[34] = (({cp2_instr[00], cp2_instr[01], cp2_instr[03]}) === 3'b100);
   assign TBL_LD_ST_PT[35] = (({cp2_instr[00], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[31]}) === 6'b110100);
   assign TBL_LD_ST_PT[36] = (({cp2_instr[00], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[30]}) === 6'b110100);
   assign TBL_LD_ST_PT[37] = (({cp2_instr[00], cp2_instr[01], cp2_instr[03], cp2_instr[04]}) === 4'b1010);
   assign TBL_LD_ST_PT[38] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[30]}) === 7'b1111100);
   assign TBL_LD_ST_PT[39] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03]}) === 4'b1001);
   assign TBL_LD_ST_PT[40] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[04], cp2_instr[05]}) === 5'b10110);
   assign TBL_LD_ST_PT[41] = (({cp2_instr[00], cp2_instr[01], cp2_instr[03], cp2_instr[05]}) === 4'b1011);
   // Table TBL_LD_ST Signal Assignments for Outputs
   assign cp2_ld = (TBL_LD_ST_PT[2] | TBL_LD_ST_PT[5] | TBL_LD_ST_PT[7] | TBL_LD_ST_PT[9] | TBL_LD_ST_PT[10] | TBL_LD_ST_PT[12] | TBL_LD_ST_PT[13] | TBL_LD_ST_PT[14] | TBL_LD_ST_PT[17] | TBL_LD_ST_PT[19] | TBL_LD_ST_PT[20] | TBL_LD_ST_PT[23] | TBL_LD_ST_PT[25] | TBL_LD_ST_PT[28] | TBL_LD_ST_PT[29] | TBL_LD_ST_PT[32] | TBL_LD_ST_PT[33] | TBL_LD_ST_PT[34] | TBL_LD_ST_PT[35] | TBL_LD_ST_PT[36] | TBL_LD_ST_PT[40]);
   assign cp2_st = (TBL_LD_ST_PT[1] | TBL_LD_ST_PT[3] | TBL_LD_ST_PT[4] | TBL_LD_ST_PT[6] | TBL_LD_ST_PT[8] | TBL_LD_ST_PT[11] | TBL_LD_ST_PT[15] | TBL_LD_ST_PT[16] | TBL_LD_ST_PT[18] | TBL_LD_ST_PT[21] | TBL_LD_ST_PT[22] | TBL_LD_ST_PT[24] | TBL_LD_ST_PT[26] | TBL_LD_ST_PT[27] | TBL_LD_ST_PT[30] | TBL_LD_ST_PT[31] | TBL_LD_ST_PT[37] | TBL_LD_ST_PT[38] | TBL_LD_ST_PT[39] | TBL_LD_ST_PT[41]);

endmodule
