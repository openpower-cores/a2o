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

//  Description:  XU ECC Generation Macro
//
//*****************************************************************************

module tri_eccgen(
   din,
   syn
);
   parameter                        REGSIZE = 64;
   input [0:REGSIZE+8-(64/REGSIZE)] din;
   output [0:8-(64/REGSIZE)]        syn;

      generate		// syndrome bits inverted
         if (REGSIZE == 64)
         begin : ecc64
            wire [0:71]                       e;
            wire [0:22]                       l1term;

            // ====================================================================
            // 64 data bits, 8 check bits
            // single bit error correction, double bit error detection
            // ====================================================================
            //                        ecc matrix description
            // ====================================================================
            // syn 0   111011010011101001100101101101001100101101001011001101001110100110000000
            // syn 1   110110101011010101010101011010101010101010101010101010101101010101000000
            // syn 2   101101100110110011001100110110011001100110011001100110011011001100100000
            // syn 3   011100011110001111000011110001111000011110000111100001111000111100010000
            // syn 4   000011111110000000111111110000000111111110000000011111111000000000001000
            // syn 5   000000000001111111111111110000000000000001111111111111111000000000000100
            // syn 6   000000000000000000000000001111111111111111111111111111111000000000000010
            // syn 7   000000000000000000000000000000000000000000000000000000000111111100000001

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

      generate		// syndrome bits inverted
         if (REGSIZE == 32)
         begin : ecc32
            wire [0:38]                       e;
            wire [0:13]                       l1term;

            // ====================================================================
            // 32 Data Bits, 7 Check bits
            // Single bit error correction, Double bit error detection
            // ====================================================================
            //                        ECC Matrix Description
            // ====================================================================
            // Syn 0   111011010011101001100101101101001000000
            // Syn 1   110110101011010101010101011010100100000
            // Syn 2   101101100110110011001100110110010010000
            // Syn 3   011100011110001111000011110001110001000
            // Syn 4   000011111110000000111111110000000000100
            // Syn 5   000000000001111111111111110000000000010
            // Syn 6   000000000000000000000000001111110000001

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
