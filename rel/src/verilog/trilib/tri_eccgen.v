// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns


module tri_eccgen(
   din,
   syn
);
   parameter                        REGSIZE = 64;
   input [0:REGSIZE+8-(64/REGSIZE)] din;
   output [0:8-(64/REGSIZE)]        syn;

      generate		
         if (REGSIZE == 64)
         begin : ecc64
            wire [0:71]                       e;
            wire [0:22]                       l1term;


            assign e[0:71] = din[0:71];

            assign l1term[0]  = e[0] ^ e[10] ^ e[17] ^ e[21] ^ e[32] ^ e[36] ^ e[44] ^ e[56];
            assign l1term[1]  = e[22] ^ e[23] ^ e[24] ^ e[25] ^ e[53] ^ e[54] ^ e[55] ^ e[56];
            assign l1term[2]  = e[1] ^ e[4] ^ e[11] ^ e[23] ^ e[26] ^ e[38] ^ e[46] ^ e[50];
            assign l1term[3]  = e[2] ^ e[5] ^ e[12] ^ e[24] ^ e[27] ^ e[39] ^ e[47] ^ e[51];
            assign l1term[4]  = e[3] ^ e[6] ^ e[13] ^ e[25] ^ e[28] ^ e[40] ^ e[48] ^ e[52];
            assign l1term[5]  = e[7] ^ e[8] ^ e[9] ^ e[10] ^ e[37] ^ e[38] ^ e[39] ^ e[40];
            assign l1term[6]  = e[14] ^ e[15] ^ e[16] ^ e[17] ^ e[45] ^ e[46] ^ e[47] ^ e[48];
            assign l1term[7]  = e[18] ^ e[19] ^ e[20] ^ e[21] ^ e[49] ^ e[50] ^ e[51] ^ e[52];
            assign l1term[8]  = e[7] ^ e[14] ^ e[18] ^ e[29] ^ e[33] ^ e[41] ^ e[53] ^ e[57];
            assign l1term[9]  = e[58] ^ e[60] ^ e[63] ^ e[64];
            assign l1term[10] = e[8] ^ e[15] ^ e[19] ^ e[30] ^ e[34] ^ e[42] ^ e[54] ^ e[57];
            assign l1term[11] = e[59] ^ e[61] ^ e[63] ^ e[65];
            assign l1term[12] = e[9] ^ e[16] ^ e[20] ^ e[31] ^ e[35] ^ e[43] ^ e[55] ^ e[58];
            assign l1term[13] = e[59] ^ e[62] ^ e[63] ^ e[66];
            assign l1term[14] = e[1] ^ e[2] ^ e[3] ^ e[29] ^ e[30] ^ e[31] ^ e[32] ^ e[60];
            assign l1term[15] = e[61] ^ e[62] ^ e[63] ^ e[67];
            assign l1term[16] = e[4] ^ e[5] ^ e[6] ^ e[33] ^ e[34] ^ e[35] ^ e[36] ^ e[68];
            assign l1term[17] = e[11] ^ e[12] ^ e[13] ^ e[41] ^ e[42] ^ e[43] ^ e[44] ^ e[69];
            assign l1term[18] = e[26] ^ e[27] ^ e[28] ^ e[29] ^ e[30] ^ e[31] ^ e[32] ^ e[33];
            assign l1term[19] = e[34] ^ e[35] ^ e[36] ^ e[37] ^ e[38] ^ e[39] ^ e[40] ^ e[41];
            assign l1term[20] = e[42] ^ e[43] ^ e[44] ^ e[45] ^ e[46] ^ e[47] ^ e[48] ^ e[49];
            assign l1term[21] = e[50] ^ e[51] ^ e[52] ^ e[53] ^ e[54] ^ e[55] ^ e[56] ^ e[70];
            assign l1term[22] = e[57] ^ e[58] ^ e[59] ^ e[60] ^ e[61] ^ e[62] ^ e[63] ^ e[71];
            assign syn[0] = l1term[0] ^ l1term[2] ^ l1term[3] ^ l1term[8] ^ l1term[9];
            assign syn[1] = l1term[0] ^ l1term[2] ^ l1term[4] ^ l1term[10] ^ l1term[11];
            assign syn[2] = l1term[0] ^ l1term[3] ^ l1term[4] ^ l1term[12] ^ l1term[13];
            assign syn[3] = l1term[1] ^ l1term[5] ^ l1term[6] ^ l1term[14] ^ l1term[15];
            assign syn[4] = l1term[1] ^ l1term[5] ^ l1term[7] ^ l1term[16];
            assign syn[5] = l1term[1] ^ l1term[6] ^ l1term[7] ^ l1term[17];
            assign syn[6] = l1term[18] ^ l1term[19] ^ l1term[20] ^ l1term[21];
            assign syn[7] = l1term[22];
         end
      endgenerate

      generate		
         if (REGSIZE == 32)
         begin : ecc32
            wire [0:38]                       e;
            wire [0:13]                       l1term;


            assign e[0:38] = din[0:38];

            assign l1term[0]  = e[0] ^ e[1] ^ e[4] ^ e[10] ^ e[11] ^ e[17] ^ e[21] ^ e[23];
            assign l1term[1]  = e[2] ^ e[3] ^ e[9] ^ e[10] ^ e[16] ^ e[17] ^ e[24] ^ e[25];
            assign l1term[2]  = e[18] ^ e[19] ^ e[20] ^ e[21] ^ e[22] ^ e[23] ^ e[24] ^ e[25];
            assign l1term[3]  = e[2] ^ e[5] ^ e[7] ^ e[12] ^ e[14] ^ e[18] ^ e[24] ^ e[26];
            assign l1term[4]  = e[27] ^ e[29] ^ e[32];
            assign l1term[5]  = e[3] ^ e[6] ^ e[8] ^ e[13] ^ e[15] ^ e[19] ^ e[25] ^ e[26];
            assign l1term[6]  = e[28] ^ e[30] ^ e[33];
            assign l1term[7]  = e[0] ^ e[5] ^ e[6] ^ e[12] ^ e[13] ^ e[20] ^ e[21] ^ e[27];
            assign l1term[8]  = e[28] ^ e[31] ^ e[34];
            assign l1term[9]  = e[1] ^ e[7] ^ e[8] ^ e[14] ^ e[15] ^ e[22] ^ e[23] ^ e[29];
            assign l1term[10] = e[30] ^ e[31] ^ e[35];
            assign l1term[11] = e[4] ^ e[5] ^ e[6] ^ e[7] ^ e[8] ^ e[9] ^ e[10] ^ e[36];
            assign l1term[12] = e[11] ^ e[12] ^ e[13] ^ e[14] ^ e[15] ^ e[16] ^ e[17] ^ e[37];
            assign l1term[13] = e[26] ^ e[27] ^ e[28] ^ e[29] ^ e[30] ^ e[31] ^ e[38];
            assign syn[0] = l1term[0] ^ l1term[3] ^ l1term[4];
            assign syn[1] = l1term[0] ^ l1term[5] ^ l1term[6];
            assign syn[2] = l1term[1] ^ l1term[7] ^ l1term[8];
            assign syn[3] = l1term[1] ^ l1term[9] ^ l1term[10];
            assign syn[4] = l1term[2] ^ l1term[11];
            assign syn[5] = l1term[2] ^ l1term[12];
            assign syn[6] = l1term[13];
         end
      endgenerate
endmodule


