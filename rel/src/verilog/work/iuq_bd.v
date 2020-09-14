// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns





module iuq_bd(
   instruction,
   instruction_next,
   branch_decode,
   bp_bc_en,
   bp_bclr_en,
   bp_bcctr_en,
   bp_sw_en
);
`include "tri_a2o.vh"

  	(* analysis_not_referenced="<12:20>true" *)
   input [0:31] instruction;
  	(* analysis_not_referenced="<6:7>,<9:10>,<14:20>,<31>true" *)
   input [0:31] instruction_next;
   output [0:3] branch_decode;

   input        bp_bc_en;
   input        bp_bclr_en;
   input        bp_bcctr_en;
   input        bp_sw_en;

      wire [1:12]  MICROCODE_PT;
      wire         core64;
      wire         to_uc;
      wire         b;
      wire         bc;
      wire         bclr;
      wire         bcctr;
      wire         bctar;
      wire         br_val;
      wire [0:4]   bo;
      wire         hint;
      wire         hint_val;
      wire         cmpi;
      wire         cmpli;
      wire         cmp;
      wire         cmpl;
      wire [0:2]   bf;
      wire         next_bc;
      wire         next_bclr;
      wire         next_bcctr;
      wire         next_bctar;
      wire [0:2]   next_bi;
      wire         next_ctr;
      wire         fuse_val;

      assign b = instruction[0:5] == 6'b010010;
      assign bc = bp_bc_en & instruction[0:5] == 6'b010000;
      assign bclr = bp_bclr_en & instruction[0:5] == 6'b010011 & instruction[21:30] == 10'b0000010000;
      assign bcctr = bp_bcctr_en & instruction[0:5] == 6'b010011 & instruction[21:30] == 10'b1000010000;
      assign bctar = bp_bcctr_en & instruction[0:5] == 6'b010011 & instruction[21:30] == 10'b1000110000;
      assign br_val = b | bc | bclr | bcctr | bctar;
      assign bo[0:4] = instruction[6:10];
      assign hint_val = (bo[0] & bo[2]) | (bp_sw_en & ((bo[0] == 1'b0 & bo[2] == 1'b1 & bo[3] == 1'b1) | (bo[0] == 1'b1 & bo[2] == 1'b0 & bo[1] == 1'b1)));
      assign hint = (bo[0] & bo[2]) | bo[4];
      assign branch_decode[0:3] = {br_val, (b | to_uc), ((br_val & hint_val) | fuse_val), hint};
      assign cmpi = instruction[0:5] == 6'b001011;
      assign cmpli = instruction[0:5] == 6'b001010;
      assign cmp = instruction[0:5] == 6'b011111 & instruction[21:30] == 10'b0000000000;
      assign cmpl = instruction[0:5] == 6'b011111 & instruction[21:30] == 10'b0000100000;
      assign bf[0:2] = instruction[6:8];
      assign next_bc = instruction_next[0:5] == 6'b010000;
      assign next_bclr = instruction_next[0:5] == 6'b010011 & instruction_next[21:30] == 10'b0000010000;
      assign next_bcctr = instruction_next[0:5] == 6'b010011 & instruction_next[21:30] == 10'b1000010000;
      assign next_bctar = instruction_next[0:5] == 6'b010011 & instruction_next[21:30] == 10'b1000110000;
      assign next_bi[0:2] = instruction_next[11:13];
      assign next_ctr = instruction_next[8] == 1'b0;
      assign fuse_val = (bf[0:2] == next_bi[0:2]) & (((cmpi | cmpli) & (next_bc | next_bcctr | ((next_bclr | next_bctar) & (~next_ctr)))) | ((cmp | cmpl) & (((next_bc) & (~next_ctr)))));
      generate
         if (`GPR_WIDTH == 64)
         begin : c64
            assign core64 = 1'b1;
         end
      endgenerate
      generate
         if (`GPR_WIDTH == 32)
         begin : c32
            assign core64 = 1'b0;
         end
      endgenerate

/*
?TABLE microcode LISTING(final) OPTIMIZE PARMS(ON-SET,DC-SET);
*INPUTS*=====================*OUTPUTS*==*
|                            |          |
| core64                     |          |
| |                          |          |
| | instruction              | to_uc    |
| | |      instruction       | |        |
| | |      | instruction     | |        |
| | |      | |               | |        |
| | |      1 22222222233     | |        |
| | 012345 1 12345678901     | |        |
*TYPE*=======================+==========+
| S PPPPPP P PPPPPPPPPPP     | S        |
*TERMS*======================+==========+
| . 100011 . ...........     | 1        | lbzu 
| . 011111 . 0001110111.     | 1        | lbzux 
| 1 111010 . .........01     | 1        | ldu 
| 1 011111 . 0000110101.     | 1        | ldux 
| . 101011 . ...........     | 1        | lhau 
| . 011111 . 0101110111.     | 1        | lhaux 
| . 101001 . ...........     | 1        | lhzu 
| . 011111 . 0100110111.     | 1        | lhzux 
| . 101110 . ...........     | 1        | lmw 
| . 011111 . 1001010101.     | 1        | lswi 
| . 011111 . 1000010101.     | 1        | lswx 
| 1 011111 . 0101110101.     | 1        | lwaux 
| . 100001 . ...........     | 1        | lwzu 
| . 011111 . 0000110111.     | 1        | lwzux
| . 110001 . ...........     | 1        | lfsu
| . 011111 . 1000110111.     | 1        | lfsux
| . 110011 . ...........     | 1        | lfdu
| . 011111 . 1001110111.     | 1        | lfdux
| . 011111 . 1000000000.     | 1        | mcrxr 
| . 011111 0 0000010011.     | 1        | mfcr 
| . 011111 0 0010010000.     | 1        | mtcrf 
| . 101111 . ...........     | 1        | stmw 
| . 011111 . 1011010101.     | 1        | stswi 
| . 011111 . 1010010101.     | 1        | stswx
*END*========================+==========+
?TABLE END microcode ;
*/

      assign MICROCODE_PT[1] = (({instruction[0], instruction[1], instruction[2], instruction[3], instruction[4], instruction[5], instruction[11], instruction[21], instruction[22], instruction[23], instruction[24], instruction[25], instruction[26], instruction[27], instruction[28], instruction[29], instruction[30]}) === 17'b01111100010010000);
      assign MICROCODE_PT[2] = (({instruction[0], instruction[1], instruction[2], instruction[3], instruction[4], instruction[5], instruction[21], instruction[22], instruction[23], instruction[24], instruction[25], instruction[26], instruction[27], instruction[28], instruction[29], instruction[30]}) === 16'b0111111000000000);
      assign MICROCODE_PT[3] = (({core64, instruction[0], instruction[1], instruction[2], instruction[3], instruction[4], instruction[5], instruction[21], instruction[22], instruction[23], instruction[24], instruction[25], instruction[26], instruction[27], instruction[28], instruction[30]}) === 16'b1011111010111011);
      assign MICROCODE_PT[4] = (({instruction[0], instruction[1], instruction[2], instruction[3], instruction[4], instruction[5], instruction[11], instruction[21], instruction[22], instruction[23], instruction[24], instruction[25], instruction[26], instruction[27], instruction[28], instruction[29], instruction[30]}) === 17'b01111100000010011);
      assign MICROCODE_PT[5] = (({core64, instruction[0], instruction[1], instruction[2], instruction[3], instruction[4], instruction[5], instruction[21], instruction[22], instruction[23], instruction[24], instruction[25], instruction[26], instruction[27], instruction[28], instruction[30]}) === 16'b1011111000011011);
      assign MICROCODE_PT[6] = (({instruction[0], instruction[1], instruction[2], instruction[3], instruction[4], instruction[5], instruction[21], instruction[22], instruction[25], instruction[26], instruction[27], instruction[28], instruction[29], instruction[30]}) === 14'b01111110010101);
      assign MICROCODE_PT[7] = (({instruction[0], instruction[1], instruction[2], instruction[3], instruction[4], instruction[5], instruction[21], instruction[23], instruction[25], instruction[26], instruction[27], instruction[28], instruction[29], instruction[30]}) === 14'b01111100110111);
      assign MICROCODE_PT[8] = (({instruction[0], instruction[1], instruction[2], instruction[3], instruction[4], instruction[5], instruction[22], instruction[23], instruction[25], instruction[26], instruction[27], instruction[28], instruction[29], instruction[30]}) === 14'b01111100110111);
      assign MICROCODE_PT[9] = (({core64, instruction[0], instruction[1], instruction[2], instruction[3], instruction[4], instruction[5], instruction[30], instruction[31]}) === 9'b111101001);
      assign MICROCODE_PT[10] = (({instruction[0], instruction[2], instruction[3], instruction[5]}) === 4'b1001);
      assign MICROCODE_PT[11] = (({instruction[0], instruction[1], instruction[3], instruction[5]}) === 4'b1001);
      assign MICROCODE_PT[12] = (({instruction[0], instruction[1], instruction[2], instruction[3], instruction[4]}) === 5'b10111);
      assign to_uc = (MICROCODE_PT[1] | MICROCODE_PT[2] | MICROCODE_PT[3] | MICROCODE_PT[4] | MICROCODE_PT[5] | MICROCODE_PT[6] | MICROCODE_PT[7] | MICROCODE_PT[8] | MICROCODE_PT[9] | MICROCODE_PT[10] | MICROCODE_PT[11] | MICROCODE_PT[12]);

endmodule

