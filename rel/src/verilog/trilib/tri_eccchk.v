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

//  Description:  XU ECC Check Macro
//
//*****************************************************************************

module tri_eccchk(
   din,
   encorr,
   nsyn,
   corrd,
   sbe,
   ue
);

   parameter                REGSIZE = 64;

   input [0:REGSIZE-1]      din;
   input                    encorr;
   input [0:8-(64/REGSIZE)] nsyn;
   output [0:REGSIZE-1]     corrd;
   output                   sbe;
   output                   ue;

      generate		// syndrome bits inverted
         if (REGSIZE == 64)
         begin : ecc64
            wire [0:7]                syn;
            wire [0:71]               DcdD;		// decode data bits
            wire                      synzero;
            wire                      sbe_int;
            wire [0:3]                A0to1;
            wire [0:3]                A2to3;
            wire [0:3]                A4to5;
            wire [0:2]                A6to7;

            // ====================================================================
            // 64 Data Bits, 8 Check bits
            // Single bit error correction, Double bit error detection
            // ====================================================================
            //                        ECC Matrix Description
            // ====================================================================
            // Syn 0   111011010011101001100101101101001100101101001011001101001110100110000000
            // Syn 1   110110101011010101010101011010101010101010101010101010101101010101000000
            // Syn 2   101101100110110011001100110110011001100110011001100110011011001100100000
            // Syn 3   011100011110001111000011110001111000011110000111100001111000111100010000
            // Syn 4   000011111110000000111111110000000111111110000000011111111000000000001000
            // Syn 5   000000000001111111111111110000000000000001111111111111111000000000000100
            // Syn 6   000000000000000000000000001111111111111111111111111111111000000000000010
            // Syn 7   000000000000000000000000000000000000000000000000000000000111111100000001

            assign syn = (~nsyn[0:7]);

            assign A0to1[0] = (~(nsyn[0] & nsyn[1] & encorr));
            assign A0to1[1] = (~(nsyn[0] &  syn[1] & encorr));
            assign A0to1[2] = (~( syn[0] & nsyn[1] & encorr));
            assign A0to1[3] = (~( syn[0] &  syn[1] & encorr));

            assign A2to3[0] = (~(nsyn[2] & nsyn[3]));
            assign A2to3[1] = (~(nsyn[2] &  syn[3]));
            assign A2to3[2] = (~( syn[2] & nsyn[3]));
            assign A2to3[3] = (~( syn[2] &  syn[3]));

            assign A4to5[0] = (~(nsyn[4] & nsyn[5]));
            assign A4to5[1] = (~(nsyn[4] &  syn[5]));
            assign A4to5[2] = (~( syn[4] & nsyn[5]));
            assign A4to5[3] = (~( syn[4] &  syn[5]));

            assign A6to7[0] = (~(nsyn[6] & nsyn[7]));
            assign A6to7[1] = (~(nsyn[6] &  syn[7]));
            assign A6to7[2] = (~( syn[6] & nsyn[7]));
            //assign A6to7[3] = (~( syn[6] &  syn[7]));

            assign DcdD[0]  = (~(A0to1[3] | A2to3[2] | A4to5[0] | A6to7[0]));		// 11 10 00 00
            assign DcdD[1]  = (~(A0to1[3] | A2to3[1] | A4to5[0] | A6to7[0]));		// 11 01 00 00
            assign DcdD[2]  = (~(A0to1[2] | A2to3[3] | A4to5[0] | A6to7[0]));		// 10 11 00 00
            assign DcdD[3]  = (~(A0to1[1] | A2to3[3] | A4to5[0] | A6to7[0]));		// 01 11 00 00
            assign DcdD[4]  = (~(A0to1[3] | A2to3[0] | A4to5[2] | A6to7[0]));		// 11 00 10 00
            assign DcdD[5]  = (~(A0to1[2] | A2to3[2] | A4to5[2] | A6to7[0]));		// 10 10 10 00
            assign DcdD[6]  = (~(A0to1[1] | A2to3[2] | A4to5[2] | A6to7[0]));		// 01 10 10 00
            assign DcdD[7]  = (~(A0to1[2] | A2to3[1] | A4to5[2] | A6to7[0]));		// 10 01 10 00
            assign DcdD[8]  = (~(A0to1[1] | A2to3[1] | A4to5[2] | A6to7[0]));		// 01 01 10 00
            assign DcdD[9]  = (~(A0to1[0] | A2to3[3] | A4to5[2] | A6to7[0]));		// 00 11 10 00
            assign DcdD[10] = (~(A0to1[3] | A2to3[3] | A4to5[2] | A6to7[0]));		// 11 11 10 00
            assign DcdD[11] = (~(A0to1[3] | A2to3[0] | A4to5[1] | A6to7[0]));		// 11 00 01 00
            assign DcdD[12] = (~(A0to1[2] | A2to3[2] | A4to5[1] | A6to7[0]));		// 10 10 01 00
            assign DcdD[13] = (~(A0to1[1] | A2to3[2] | A4to5[1] | A6to7[0]));		// 01 10 01 00
            assign DcdD[14] = (~(A0to1[2] | A2to3[1] | A4to5[1] | A6to7[0]));		// 10 01 01 00
            assign DcdD[15] = (~(A0to1[1] | A2to3[1] | A4to5[1] | A6to7[0]));		// 01 01 01 00
            assign DcdD[16] = (~(A0to1[0] | A2to3[3] | A4to5[1] | A6to7[0]));		// 00 11 01 00
            assign DcdD[17] = (~(A0to1[3] | A2to3[3] | A4to5[1] | A6to7[0]));		// 11 11 01 00
            assign DcdD[18] = (~(A0to1[2] | A2to3[0] | A4to5[3] | A6to7[0]));		// 10 00 11 00
            assign DcdD[19] = (~(A0to1[1] | A2to3[0] | A4to5[3] | A6to7[0]));		// 01 00 11 00
            assign DcdD[20] = (~(A0to1[0] | A2to3[2] | A4to5[3] | A6to7[0]));		// 00 10 11 00
            assign DcdD[21] = (~(A0to1[3] | A2to3[2] | A4to5[3] | A6to7[0]));		// 11 10 11 00
            assign DcdD[22] = (~(A0to1[0] | A2to3[1] | A4to5[3] | A6to7[0]));		// 00 01 11 00
            assign DcdD[23] = (~(A0to1[3] | A2to3[1] | A4to5[3] | A6to7[0]));		// 11 01 11 00
            assign DcdD[24] = (~(A0to1[2] | A2to3[3] | A4to5[3] | A6to7[0]));		// 10 11 11 00
            assign DcdD[25] = (~(A0to1[1] | A2to3[3] | A4to5[3] | A6to7[0]));		// 01 11 11 00
            assign DcdD[26] = (~(A0to1[3] | A2to3[0] | A4to5[0] | A6to7[2]));		// 11 00 00 10
            assign DcdD[27] = (~(A0to1[2] | A2to3[2] | A4to5[0] | A6to7[2]));		// 10 10 00 10
            assign DcdD[28] = (~(A0to1[1] | A2to3[2] | A4to5[0] | A6to7[2]));		// 01 10 00 10
            assign DcdD[29] = (~(A0to1[2] | A2to3[1] | A4to5[0] | A6to7[2]));		// 10 01 00 10
            assign DcdD[30] = (~(A0to1[1] | A2to3[1] | A4to5[0] | A6to7[2]));		// 01 01 00 10
            assign DcdD[31] = (~(A0to1[0] | A2to3[3] | A4to5[0] | A6to7[2]));		// 00 11 00 10
            assign DcdD[32] = (~(A0to1[3] | A2to3[3] | A4to5[0] | A6to7[2]));		// 11 11 00 10
            assign DcdD[33] = (~(A0to1[2] | A2to3[0] | A4to5[2] | A6to7[2]));		// 10 00 10 10
            assign DcdD[34] = (~(A0to1[1] | A2to3[0] | A4to5[2] | A6to7[2]));		// 01 00 10 10
            assign DcdD[35] = (~(A0to1[0] | A2to3[2] | A4to5[2] | A6to7[2]));		// 00 10 10 10
            assign DcdD[36] = (~(A0to1[3] | A2to3[2] | A4to5[2] | A6to7[2]));		// 11 10 10 10
            assign DcdD[37] = (~(A0to1[0] | A2to3[1] | A4to5[2] | A6to7[2]));		// 00 01 10 10
            assign DcdD[38] = (~(A0to1[3] | A2to3[1] | A4to5[2] | A6to7[2]));		// 11 01 10 10
            assign DcdD[39] = (~(A0to1[2] | A2to3[3] | A4to5[2] | A6to7[2]));		// 10 11 10 10
            assign DcdD[40] = (~(A0to1[1] | A2to3[3] | A4to5[2] | A6to7[2]));		// 01 11 10 10
            assign DcdD[41] = (~(A0to1[2] | A2to3[0] | A4to5[1] | A6to7[2]));		// 10 00 01 10
            assign DcdD[42] = (~(A0to1[1] | A2to3[0] | A4to5[1] | A6to7[2]));		// 01 00 01 10
            assign DcdD[43] = (~(A0to1[0] | A2to3[2] | A4to5[1] | A6to7[2]));		// 00 10 01 10
            assign DcdD[44] = (~(A0to1[3] | A2to3[2] | A4to5[1] | A6to7[2]));		// 11 10 01 10
            assign DcdD[45] = (~(A0to1[0] | A2to3[1] | A4to5[1] | A6to7[2]));		// 00 01 01 10
            assign DcdD[46] = (~(A0to1[3] | A2to3[1] | A4to5[1] | A6to7[2]));		// 11 01 01 10
            assign DcdD[47] = (~(A0to1[2] | A2to3[3] | A4to5[1] | A6to7[2]));		// 10 11 01 10
            assign DcdD[48] = (~(A0to1[1] | A2to3[3] | A4to5[1] | A6to7[2]));		// 01 11 01 10
            assign DcdD[49] = (~(A0to1[0] | A2to3[0] | A4to5[3] | A6to7[2]));		// 00 00 11 10
            assign DcdD[50] = (~(A0to1[3] | A2to3[0] | A4to5[3] | A6to7[2]));		// 11 00 11 10
            assign DcdD[51] = (~(A0to1[2] | A2to3[2] | A4to5[3] | A6to7[2]));		// 10 10 11 10
            assign DcdD[52] = (~(A0to1[1] | A2to3[2] | A4to5[3] | A6to7[2]));		// 01 10 11 10
            assign DcdD[53] = (~(A0to1[2] | A2to3[1] | A4to5[3] | A6to7[2]));		// 10 01 11 10
            assign DcdD[54] = (~(A0to1[1] | A2to3[1] | A4to5[3] | A6to7[2]));		// 01 01 11 10
            assign DcdD[55] = (~(A0to1[0] | A2to3[3] | A4to5[3] | A6to7[2]));		// 00 11 11 10
            assign DcdD[56] = (~(A0to1[3] | A2to3[3] | A4to5[3] | A6to7[2]));		// 11 11 11 10
            assign DcdD[57] = (~(A0to1[3] | A2to3[0] | A4to5[0] | A6to7[1]));		// 11 00 00 01
            assign DcdD[58] = (~(A0to1[2] | A2to3[2] | A4to5[0] | A6to7[1]));		// 10 10 00 01
            assign DcdD[59] = (~(A0to1[1] | A2to3[2] | A4to5[0] | A6to7[1]));		// 01 10 00 01
            assign DcdD[60] = (~(A0to1[2] | A2to3[1] | A4to5[0] | A6to7[1]));		// 10 01 00 01
            assign DcdD[61] = (~(A0to1[1] | A2to3[1] | A4to5[0] | A6to7[1]));		// 01 01 00 01
            assign DcdD[62] = (~(A0to1[0] | A2to3[3] | A4to5[0] | A6to7[1]));		// 00 11 00 01
            assign DcdD[63] = (~(A0to1[3] | A2to3[3] | A4to5[0] | A6to7[1]));		// 11 11 00 01
            assign DcdD[64] = (~(A0to1[2] | A2to3[0] | A4to5[0] | A6to7[0]));		// 10 00 00 00
            assign DcdD[65] = (~(A0to1[1] | A2to3[0] | A4to5[0] | A6to7[0]));		// 01 00 00 00
            assign DcdD[66] = (~(A0to1[0] | A2to3[2] | A4to5[0] | A6to7[0]));		// 00 10 00 00
            assign DcdD[67] = (~(A0to1[0] | A2to3[1] | A4to5[0] | A6to7[0]));		// 00 01 00 00
            assign DcdD[68] = (~(A0to1[0] | A2to3[0] | A4to5[2] | A6to7[0]));		// 00 00 10 00
            assign DcdD[69] = (~(A0to1[0] | A2to3[0] | A4to5[1] | A6to7[0]));		// 00 00 01 00
            assign DcdD[70] = (~(A0to1[0] | A2to3[0] | A4to5[0] | A6to7[2]));		// 00 00 00 10
            assign DcdD[71] = (~(A0to1[0] | A2to3[0] | A4to5[0] | A6to7[1]));		// 00 00 00 01
            assign synzero  = (~(A0to1[0] | A2to3[0] | A4to5[0] | A6to7[0]));		// 00 00 00 00

            assign corrd[0:63] = din[0:63] ^ DcdD[0:63];

            assign sbe_int = (DcdD[0:71] != {72{1'b0}}) ? 1'b1 :
                             1'b0;
            assign sbe = sbe_int;
            assign ue = (~sbe_int) & (~synzero) & encorr;
         end
      endgenerate

      generate		// syndrome bits inverted
         if (REGSIZE == 32)
         begin : ecc32
            wire [0:6]                syn;
            wire [0:38]               DcdD;		// decode data bits
            wire                      synzero;
            wire                      sbe_int;
            wire [0:3]                A0to1;
            wire [0:3]                A2to3;
            wire [0:7]                A4to6;

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

            assign syn = (~nsyn[0:6]);

            assign A0to1[0] = (~(nsyn[0] & nsyn[1] & encorr));
            assign A0to1[1] = (~(nsyn[0] &  syn[1] & encorr));
            assign A0to1[2] = (~( syn[0] & nsyn[1] & encorr));
            assign A0to1[3] = (~( syn[0] &  syn[1] & encorr));

            assign A2to3[0] = (~(nsyn[2] & nsyn[3]));
            assign A2to3[1] = (~(nsyn[2] &  syn[3]));
            assign A2to3[2] = (~( syn[2] & nsyn[3]));
            assign A2to3[3] = (~( syn[2] &  syn[3]));

            assign A4to6[0] = (~(nsyn[4] & nsyn[5] & nsyn[6]));
            assign A4to6[1] = (~(nsyn[4] & nsyn[5] &  syn[6]));
            assign A4to6[2] = (~(nsyn[4] &  syn[5] & nsyn[6]));
            assign A4to6[3] = (~(nsyn[4] &  syn[5] &  syn[6]));
            assign A4to6[4] = (~( syn[4] & nsyn[5] & nsyn[6]));
            assign A4to6[5] = (~( syn[4] & nsyn[5] &  syn[6]));
            assign A4to6[6] = (~( syn[4] &  syn[5] & nsyn[6]));
            assign A4to6[7] = (~( syn[4] &  syn[5] &  syn[6]));

            assign DcdD[0]  = (~(A0to1[3] | A2to3[2] | A4to6[0]));		// 11 10 000
            assign DcdD[1]  = (~(A0to1[3] | A2to3[1] | A4to6[0]));		// 11 01 000
            assign DcdD[2]  = (~(A0to1[2] | A2to3[3] | A4to6[0]));		// 10 11 000
            assign DcdD[3]  = (~(A0to1[1] | A2to3[3] | A4to6[0]));		// 01 11 000
            assign DcdD[4]  = (~(A0to1[3] | A2to3[0] | A4to6[4]));		// 11 00 100
            assign DcdD[5]  = (~(A0to1[2] | A2to3[2] | A4to6[4]));		// 10 10 100
            assign DcdD[6]  = (~(A0to1[1] | A2to3[2] | A4to6[4]));		// 01 10 100
            assign DcdD[7]  = (~(A0to1[2] | A2to3[1] | A4to6[4]));		// 10 01 100
            assign DcdD[8]  = (~(A0to1[1] | A2to3[1] | A4to6[4]));		// 01 01 100
            assign DcdD[9]  = (~(A0to1[0] | A2to3[3] | A4to6[4]));		// 00 11 100
            assign DcdD[10] = (~(A0to1[3] | A2to3[3] | A4to6[4]));		// 11 11 100
            assign DcdD[11] = (~(A0to1[3] | A2to3[0] | A4to6[2]));		// 11 00 010
            assign DcdD[12] = (~(A0to1[2] | A2to3[2] | A4to6[2]));		// 10 10 010
            assign DcdD[13] = (~(A0to1[1] | A2to3[2] | A4to6[2]));		// 01 10 010
            assign DcdD[14] = (~(A0to1[2] | A2to3[1] | A4to6[2]));		// 10 01 010
            assign DcdD[15] = (~(A0to1[1] | A2to3[1] | A4to6[2]));		// 01 01 010
            assign DcdD[16] = (~(A0to1[0] | A2to3[3] | A4to6[2]));		// 00 11 010
            assign DcdD[17] = (~(A0to1[3] | A2to3[3] | A4to6[2]));		// 11 11 010
            assign DcdD[18] = (~(A0to1[2] | A2to3[0] | A4to6[6]));		// 10 00 110
            assign DcdD[19] = (~(A0to1[1] | A2to3[0] | A4to6[6]));		// 01 00 110
            assign DcdD[20] = (~(A0to1[0] | A2to3[2] | A4to6[6]));		// 00 10 110
            assign DcdD[21] = (~(A0to1[3] | A2to3[2] | A4to6[6]));		// 11 10 110
            assign DcdD[22] = (~(A0to1[0] | A2to3[1] | A4to6[6]));		// 00 01 110
            assign DcdD[23] = (~(A0to1[3] | A2to3[1] | A4to6[6]));		// 11 01 110
            assign DcdD[24] = (~(A0to1[2] | A2to3[3] | A4to6[6]));		// 10 11 110
            assign DcdD[25] = (~(A0to1[1] | A2to3[3] | A4to6[6]));		// 01 11 110
            assign DcdD[26] = (~(A0to1[3] | A2to3[0] | A4to6[1]));		// 11 00 001
            assign DcdD[27] = (~(A0to1[2] | A2to3[2] | A4to6[1]));		// 10 10 001
            assign DcdD[28] = (~(A0to1[1] | A2to3[2] | A4to6[1]));		// 01 10 001
            assign DcdD[29] = (~(A0to1[2] | A2to3[1] | A4to6[1]));		// 10 01 001
            assign DcdD[30] = (~(A0to1[1] | A2to3[1] | A4to6[1]));		// 01 01 001
            assign DcdD[31] = (~(A0to1[0] | A2to3[3] | A4to6[1]));		// 00 11 001
            assign DcdD[32] = (~(A0to1[2] | A2to3[0] | A4to6[0]));		// 10 00 000
            assign DcdD[33] = (~(A0to1[1] | A2to3[0] | A4to6[0]));		// 01 00 000
            assign DcdD[34] = (~(A0to1[0] | A2to3[2] | A4to6[0]));		// 00 10 000
            assign DcdD[35] = (~(A0to1[0] | A2to3[1] | A4to6[0]));		// 00 01 000
            assign DcdD[36] = (~(A0to1[0] | A2to3[0] | A4to6[4]));		// 00 00 100
            assign DcdD[37] = (~(A0to1[0] | A2to3[0] | A4to6[2]));		// 00 00 010
            assign DcdD[38] = (~(A0to1[0] | A2to3[0] | A4to6[1]));		// 00 00 001
            assign synzero  = (~(A0to1[0] | A2to3[0] | A4to6[0]));		// 00 00 000

            assign corrd[0:31] = din[0:31] ^ DcdD[0:31];

            assign sbe_int = (DcdD[0:38] != {39{1'b0}}) ? 1'b1 :
                             1'b0;
            assign sbe = sbe_int;
            assign ue = (~sbe_int) & (~synzero) & encorr;

            //mark_unused(A4to6(3));
            //mark_unused(A4to6(5));
            //mark_unused(A4to6(7));
         end
      endgenerate
endmodule
