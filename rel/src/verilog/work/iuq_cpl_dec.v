// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns


module iuq_cpl_dec(
   input [0:31] cp2_instr,
   output       cp2_ld,
   output       cp2_st,
   output       cp2_epid);

   wire [1:7]   TBL_EPID_DEC_PT;
   wire [1:41]  TBL_LD_ST_PT;
   assign TBL_EPID_DEC_PT[1] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 16'b0111111110110110);
   assign TBL_EPID_DEC_PT[2] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[23], cp2_instr[24], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 15'b011111111111111);
   assign TBL_EPID_DEC_PT[3] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[30]}) === 14'b01111100001111);
   assign TBL_EPID_DEC_PT[4] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[23], cp2_instr[24], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 14'b01111100011111);
   assign TBL_EPID_DEC_PT[5] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[22], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 14'b01111101011111);
   assign TBL_EPID_DEC_PT[6] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[22], cp2_instr[24], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 14'b01111100111111);
   assign TBL_EPID_DEC_PT[7] = (({cp2_instr[00], cp2_instr[01], cp2_instr[02], cp2_instr[03], cp2_instr[04], cp2_instr[05], cp2_instr[21], cp2_instr[24], cp2_instr[25], cp2_instr[26], cp2_instr[27], cp2_instr[28], cp2_instr[29], cp2_instr[30]}) === 14'b01111100011111);

   assign cp2_epid = (TBL_EPID_DEC_PT[1] | TBL_EPID_DEC_PT[2] | TBL_EPID_DEC_PT[3] | TBL_EPID_DEC_PT[4] | TBL_EPID_DEC_PT[5] | TBL_EPID_DEC_PT[6] | TBL_EPID_DEC_PT[7]);
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
   assign cp2_ld = (TBL_LD_ST_PT[2] | TBL_LD_ST_PT[5] | TBL_LD_ST_PT[7] | TBL_LD_ST_PT[9] | TBL_LD_ST_PT[10] | TBL_LD_ST_PT[12] | TBL_LD_ST_PT[13] | TBL_LD_ST_PT[14] | TBL_LD_ST_PT[17] | TBL_LD_ST_PT[19] | TBL_LD_ST_PT[20] | TBL_LD_ST_PT[23] | TBL_LD_ST_PT[25] | TBL_LD_ST_PT[28] | TBL_LD_ST_PT[29] | TBL_LD_ST_PT[32] | TBL_LD_ST_PT[33] | TBL_LD_ST_PT[34] | TBL_LD_ST_PT[35] | TBL_LD_ST_PT[36] | TBL_LD_ST_PT[40]);
   assign cp2_st = (TBL_LD_ST_PT[1] | TBL_LD_ST_PT[3] | TBL_LD_ST_PT[4] | TBL_LD_ST_PT[6] | TBL_LD_ST_PT[8] | TBL_LD_ST_PT[11] | TBL_LD_ST_PT[15] | TBL_LD_ST_PT[16] | TBL_LD_ST_PT[18] | TBL_LD_ST_PT[21] | TBL_LD_ST_PT[22] | TBL_LD_ST_PT[24] | TBL_LD_ST_PT[26] | TBL_LD_ST_PT[27] | TBL_LD_ST_PT[30] | TBL_LD_ST_PT[31] | TBL_LD_ST_PT[37] | TBL_LD_ST_PT[38] | TBL_LD_ST_PT[39] | TBL_LD_ST_PT[41]);
      
endmodule
