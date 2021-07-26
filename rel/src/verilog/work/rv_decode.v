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
// job was run on Tue Mar 29 10:19:33 2011

//***************************************************************************************************
//*
//* TITLE:
//*
//* NAME: rv_decode.vhdl
//*
//***************************************************************************************************
module rv_decode(
   instr,
   is_brick,
   brick_cycles
);
   input [0:31] instr;

   output       is_brick;
   output [0:2] brick_cycles;
   //@@  Signal Declarations
   wire [1:8]   RV_INSTRUCTION_DECODER_PT;
   wire [0:5]   instr_0_5;
   wire [0:10]  instr_21_31;
   (* analysis_not_referenced="true" *)
   wire 	unused;

   assign unused = |instr[6:20] | instr_21_31[10];

   //@@ START OF EXECUTABLE CODE FOR RTL

   assign instr_0_5 = instr[0:5];
   assign instr_21_31 = instr[21:31];

//table_start
//?TABLE rv_instruction_decoder LISTING(final) OPTIMIZE PARMS(ON-SET);
//*INPUTS*===============*OUTPUTS*==========*
//|                      |                  |
//| instr_0_5            | is_brick         |
//| |      instr_21_31   | | brick_cycles   |
//| |      |             | | |              |
//| |      |             | | |              |
//| |      |             | | |              |
//| |      |             | | |              |
//| |      |             | | |              |
//| |      |             | | |              |
//| |      |             | | |              |
//| |      |             | | |              |
//| |      |             | | |              |
//| |      |             | | |              |
//| |      |             | | |              |
//| |      |             | | |              |
//| |      |         1   | | |              |
//| 012345 01234567890   | | 012            |
//*TYPE*=================+==================+
//| SSSSSS SSSSSSSSSSS   | P PPP            | INSTR
//*TERMS*=*=*============+==================+
//| 000111 ...........   | 1 000            | mulli   2
//| 011111 0011101001.   | 1 001            | mulld   3
//| 011111 1011101001.   | 1 010            | mulldo  4
//| 011111 .001001001.   | 1 010            | mulhd   4
//| 011111 .000001001.   | 1 010            | mulhdu  4
//| 011111 1100110011.   | 1 000            | erativax 2
//| 011111 0011010100.   | 1 000            | ldawx
//| 011111 0010100110.   | 1 000            | dcbtls
//| 011111 0010000110.   | 1 000            | dcbtstls
//| 011111 0000110100.   | 1 000            | lbarx
//| 011111 0001010100.   | 1 000            | ldarx
//| 011111 0001110100.   | 1 000            | lharx
//| 011111 0000010100.   | 1 000            | lwarx
//*END*==================+==================+
//?TABLE END rv_instruction_decoder ;
//table_end


//assign_start

   assign RV_INSTRUCTION_DECODER_PT[1] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5], instr_21_31[0], instr_21_31[1], instr_21_31[2], instr_21_31[3], instr_21_31[4], instr_21_31[5], instr_21_31[6], instr_21_31[7], instr_21_31[8], instr_21_31[9]}) == 16'b0111111100110011);
   assign RV_INSTRUCTION_DECODER_PT[2] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5], instr_21_31[0], instr_21_31[1], instr_21_31[2], instr_21_31[3], instr_21_31[5], instr_21_31[6], instr_21_31[7], instr_21_31[8], instr_21_31[9]}) == 15'b011111001000110);
   assign RV_INSTRUCTION_DECODER_PT[3] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5], instr_21_31[0], instr_21_31[1], instr_21_31[2], instr_21_31[3], instr_21_31[4], instr_21_31[5], instr_21_31[6], instr_21_31[7], instr_21_31[8], instr_21_31[9]}) == 16'b0111111011101001);
   assign RV_INSTRUCTION_DECODER_PT[4] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5], instr_21_31[0], instr_21_31[1], instr_21_31[2], instr_21_31[3], instr_21_31[4], instr_21_31[5], instr_21_31[6], instr_21_31[7], instr_21_31[8], instr_21_31[9]}) == 16'b0111110011101001);
   assign RV_INSTRUCTION_DECODER_PT[5] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5], instr_21_31[0], instr_21_31[1], instr_21_31[2], instr_21_31[5], instr_21_31[6], instr_21_31[7], instr_21_31[8], instr_21_31[9]}) == 14'b01111100010100);
   assign RV_INSTRUCTION_DECODER_PT[6] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5], instr_21_31[0], instr_21_31[1], instr_21_31[3], instr_21_31[4], instr_21_31[5], instr_21_31[6], instr_21_31[7], instr_21_31[8], instr_21_31[9]}) == 15'b011111001010100);
   assign RV_INSTRUCTION_DECODER_PT[7] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5], instr_21_31[1], instr_21_31[2], instr_21_31[4], instr_21_31[5], instr_21_31[6], instr_21_31[7], instr_21_31[8], instr_21_31[9]}) == 14'b01111100001001);
   assign RV_INSTRUCTION_DECODER_PT[8] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5]}) == 6'b000111);
   // Table RV_INSTRUCTION_DECODER Signal Assignments for Outputs
   assign is_brick = (RV_INSTRUCTION_DECODER_PT[1] | RV_INSTRUCTION_DECODER_PT[2] | RV_INSTRUCTION_DECODER_PT[3] | RV_INSTRUCTION_DECODER_PT[4] | RV_INSTRUCTION_DECODER_PT[5] | RV_INSTRUCTION_DECODER_PT[6] | RV_INSTRUCTION_DECODER_PT[7] | RV_INSTRUCTION_DECODER_PT[8]);
   assign brick_cycles[0] = (1'b0);
   assign brick_cycles[1] = (RV_INSTRUCTION_DECODER_PT[3] | RV_INSTRUCTION_DECODER_PT[7]);
   assign brick_cycles[2] = (RV_INSTRUCTION_DECODER_PT[4]);

//assign_end

endmodule

