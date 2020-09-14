// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns



module rv_decode(
   instr,
   is_brick,
   brick_cycles
);
   input [0:31] instr;
   
   output       is_brick;
   output [0:2] brick_cycles;
   wire [1:8]   RV_INSTRUCTION_DECODER_PT;
   wire [0:5]   instr_0_5;
   wire [0:10]  instr_21_31;
   (* analysis_not_referenced="true" *)
   wire 	unused;

   assign unused = |instr[6:20] | instr_21_31[10];
   
   
   assign instr_0_5 = instr[0:5];
   assign instr_21_31 = instr[21:31];




   assign RV_INSTRUCTION_DECODER_PT[1] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5], instr_21_31[0], instr_21_31[1], instr_21_31[2], instr_21_31[3], instr_21_31[4], instr_21_31[5], instr_21_31[6], instr_21_31[7], instr_21_31[8], instr_21_31[9]}) == 16'b0111111100110011);
   assign RV_INSTRUCTION_DECODER_PT[2] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5], instr_21_31[0], instr_21_31[1], instr_21_31[2], instr_21_31[3], instr_21_31[5], instr_21_31[6], instr_21_31[7], instr_21_31[8], instr_21_31[9]}) == 15'b011111001000110);
   assign RV_INSTRUCTION_DECODER_PT[3] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5], instr_21_31[0], instr_21_31[1], instr_21_31[2], instr_21_31[3], instr_21_31[4], instr_21_31[5], instr_21_31[6], instr_21_31[7], instr_21_31[8], instr_21_31[9]}) == 16'b0111111011101001);
   assign RV_INSTRUCTION_DECODER_PT[4] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5], instr_21_31[0], instr_21_31[1], instr_21_31[2], instr_21_31[3], instr_21_31[4], instr_21_31[5], instr_21_31[6], instr_21_31[7], instr_21_31[8], instr_21_31[9]}) == 16'b0111110011101001);
   assign RV_INSTRUCTION_DECODER_PT[5] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5], instr_21_31[0], instr_21_31[1], instr_21_31[2], instr_21_31[5], instr_21_31[6], instr_21_31[7], instr_21_31[8], instr_21_31[9]}) == 14'b01111100010100);
   assign RV_INSTRUCTION_DECODER_PT[6] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5], instr_21_31[0], instr_21_31[1], instr_21_31[3], instr_21_31[4], instr_21_31[5], instr_21_31[6], instr_21_31[7], instr_21_31[8], instr_21_31[9]}) == 15'b011111001010100);
   assign RV_INSTRUCTION_DECODER_PT[7] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5], instr_21_31[1], instr_21_31[2], instr_21_31[4], instr_21_31[5], instr_21_31[6], instr_21_31[7], instr_21_31[8], instr_21_31[9]}) == 14'b01111100001001);
   assign RV_INSTRUCTION_DECODER_PT[8] = (({instr_0_5[0], instr_0_5[1], instr_0_5[2], instr_0_5[3], instr_0_5[4], instr_0_5[5]}) == 6'b000111);
   assign is_brick = (RV_INSTRUCTION_DECODER_PT[1] | RV_INSTRUCTION_DECODER_PT[2] | RV_INSTRUCTION_DECODER_PT[3] | RV_INSTRUCTION_DECODER_PT[4] | RV_INSTRUCTION_DECODER_PT[5] | RV_INSTRUCTION_DECODER_PT[6] | RV_INSTRUCTION_DECODER_PT[7] | RV_INSTRUCTION_DECODER_PT[8]);
   assign brick_cycles[0] = (1'b0);
   assign brick_cycles[1] = (RV_INSTRUCTION_DECODER_PT[3] | RV_INSTRUCTION_DECODER_PT[7]);
   assign brick_cycles[2] = (RV_INSTRUCTION_DECODER_PT[4]);


endmodule

