// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns


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

      generate		
         if (REGSIZE == 64)
         begin : ecc64
            wire [0:7]                syn;
            wire [0:71]               DcdD;		
            wire                      synzero;
            wire                      sbe_int;
            wire [0:3]                A0to1;
            wire [0:3]                A2to3;
            wire [0:3]                A4to5;
            wire [0:2]                A6to7;


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

            assign DcdD[0]  = (~(A0to1[3] | A2to3[2] | A4to5[0] | A6to7[0]));		
            assign DcdD[1]  = (~(A0to1[3] | A2to3[1] | A4to5[0] | A6to7[0]));		
            assign DcdD[2]  = (~(A0to1[2] | A2to3[3] | A4to5[0] | A6to7[0]));		
            assign DcdD[3]  = (~(A0to1[1] | A2to3[3] | A4to5[0] | A6to7[0]));		
            assign DcdD[4]  = (~(A0to1[3] | A2to3[0] | A4to5[2] | A6to7[0]));		
            assign DcdD[5]  = (~(A0to1[2] | A2to3[2] | A4to5[2] | A6to7[0]));		
            assign DcdD[6]  = (~(A0to1[1] | A2to3[2] | A4to5[2] | A6to7[0]));		
            assign DcdD[7]  = (~(A0to1[2] | A2to3[1] | A4to5[2] | A6to7[0]));		
            assign DcdD[8]  = (~(A0to1[1] | A2to3[1] | A4to5[2] | A6to7[0]));		
            assign DcdD[9]  = (~(A0to1[0] | A2to3[3] | A4to5[2] | A6to7[0]));		
            assign DcdD[10] = (~(A0to1[3] | A2to3[3] | A4to5[2] | A6to7[0]));		
            assign DcdD[11] = (~(A0to1[3] | A2to3[0] | A4to5[1] | A6to7[0]));		
            assign DcdD[12] = (~(A0to1[2] | A2to3[2] | A4to5[1] | A6to7[0]));		
            assign DcdD[13] = (~(A0to1[1] | A2to3[2] | A4to5[1] | A6to7[0]));		
            assign DcdD[14] = (~(A0to1[2] | A2to3[1] | A4to5[1] | A6to7[0]));		
            assign DcdD[15] = (~(A0to1[1] | A2to3[1] | A4to5[1] | A6to7[0]));		
            assign DcdD[16] = (~(A0to1[0] | A2to3[3] | A4to5[1] | A6to7[0]));		
            assign DcdD[17] = (~(A0to1[3] | A2to3[3] | A4to5[1] | A6to7[0]));		
            assign DcdD[18] = (~(A0to1[2] | A2to3[0] | A4to5[3] | A6to7[0]));		
            assign DcdD[19] = (~(A0to1[1] | A2to3[0] | A4to5[3] | A6to7[0]));		
            assign DcdD[20] = (~(A0to1[0] | A2to3[2] | A4to5[3] | A6to7[0]));		
            assign DcdD[21] = (~(A0to1[3] | A2to3[2] | A4to5[3] | A6to7[0]));		
            assign DcdD[22] = (~(A0to1[0] | A2to3[1] | A4to5[3] | A6to7[0]));		
            assign DcdD[23] = (~(A0to1[3] | A2to3[1] | A4to5[3] | A6to7[0]));		
            assign DcdD[24] = (~(A0to1[2] | A2to3[3] | A4to5[3] | A6to7[0]));		
            assign DcdD[25] = (~(A0to1[1] | A2to3[3] | A4to5[3] | A6to7[0]));		
            assign DcdD[26] = (~(A0to1[3] | A2to3[0] | A4to5[0] | A6to7[2]));		
            assign DcdD[27] = (~(A0to1[2] | A2to3[2] | A4to5[0] | A6to7[2]));		
            assign DcdD[28] = (~(A0to1[1] | A2to3[2] | A4to5[0] | A6to7[2]));		
            assign DcdD[29] = (~(A0to1[2] | A2to3[1] | A4to5[0] | A6to7[2]));		
            assign DcdD[30] = (~(A0to1[1] | A2to3[1] | A4to5[0] | A6to7[2]));		
            assign DcdD[31] = (~(A0to1[0] | A2to3[3] | A4to5[0] | A6to7[2]));		
            assign DcdD[32] = (~(A0to1[3] | A2to3[3] | A4to5[0] | A6to7[2]));		
            assign DcdD[33] = (~(A0to1[2] | A2to3[0] | A4to5[2] | A6to7[2]));		
            assign DcdD[34] = (~(A0to1[1] | A2to3[0] | A4to5[2] | A6to7[2]));		
            assign DcdD[35] = (~(A0to1[0] | A2to3[2] | A4to5[2] | A6to7[2]));		
            assign DcdD[36] = (~(A0to1[3] | A2to3[2] | A4to5[2] | A6to7[2]));		
            assign DcdD[37] = (~(A0to1[0] | A2to3[1] | A4to5[2] | A6to7[2]));		
            assign DcdD[38] = (~(A0to1[3] | A2to3[1] | A4to5[2] | A6to7[2]));		
            assign DcdD[39] = (~(A0to1[2] | A2to3[3] | A4to5[2] | A6to7[2]));		
            assign DcdD[40] = (~(A0to1[1] | A2to3[3] | A4to5[2] | A6to7[2]));		
            assign DcdD[41] = (~(A0to1[2] | A2to3[0] | A4to5[1] | A6to7[2]));		
            assign DcdD[42] = (~(A0to1[1] | A2to3[0] | A4to5[1] | A6to7[2]));		
            assign DcdD[43] = (~(A0to1[0] | A2to3[2] | A4to5[1] | A6to7[2]));		
            assign DcdD[44] = (~(A0to1[3] | A2to3[2] | A4to5[1] | A6to7[2]));		
            assign DcdD[45] = (~(A0to1[0] | A2to3[1] | A4to5[1] | A6to7[2]));		
            assign DcdD[46] = (~(A0to1[3] | A2to3[1] | A4to5[1] | A6to7[2]));		
            assign DcdD[47] = (~(A0to1[2] | A2to3[3] | A4to5[1] | A6to7[2]));		
            assign DcdD[48] = (~(A0to1[1] | A2to3[3] | A4to5[1] | A6to7[2]));		
            assign DcdD[49] = (~(A0to1[0] | A2to3[0] | A4to5[3] | A6to7[2]));		
            assign DcdD[50] = (~(A0to1[3] | A2to3[0] | A4to5[3] | A6to7[2]));		
            assign DcdD[51] = (~(A0to1[2] | A2to3[2] | A4to5[3] | A6to7[2]));		
            assign DcdD[52] = (~(A0to1[1] | A2to3[2] | A4to5[3] | A6to7[2]));		
            assign DcdD[53] = (~(A0to1[2] | A2to3[1] | A4to5[3] | A6to7[2]));		
            assign DcdD[54] = (~(A0to1[1] | A2to3[1] | A4to5[3] | A6to7[2]));		
            assign DcdD[55] = (~(A0to1[0] | A2to3[3] | A4to5[3] | A6to7[2]));		
            assign DcdD[56] = (~(A0to1[3] | A2to3[3] | A4to5[3] | A6to7[2]));		
            assign DcdD[57] = (~(A0to1[3] | A2to3[0] | A4to5[0] | A6to7[1]));		
            assign DcdD[58] = (~(A0to1[2] | A2to3[2] | A4to5[0] | A6to7[1]));		
            assign DcdD[59] = (~(A0to1[1] | A2to3[2] | A4to5[0] | A6to7[1]));		
            assign DcdD[60] = (~(A0to1[2] | A2to3[1] | A4to5[0] | A6to7[1]));		
            assign DcdD[61] = (~(A0to1[1] | A2to3[1] | A4to5[0] | A6to7[1]));		
            assign DcdD[62] = (~(A0to1[0] | A2to3[3] | A4to5[0] | A6to7[1]));		
            assign DcdD[63] = (~(A0to1[3] | A2to3[3] | A4to5[0] | A6to7[1]));		
            assign DcdD[64] = (~(A0to1[2] | A2to3[0] | A4to5[0] | A6to7[0]));		
            assign DcdD[65] = (~(A0to1[1] | A2to3[0] | A4to5[0] | A6to7[0]));		
            assign DcdD[66] = (~(A0to1[0] | A2to3[2] | A4to5[0] | A6to7[0]));		
            assign DcdD[67] = (~(A0to1[0] | A2to3[1] | A4to5[0] | A6to7[0]));		
            assign DcdD[68] = (~(A0to1[0] | A2to3[0] | A4to5[2] | A6to7[0]));		
            assign DcdD[69] = (~(A0to1[0] | A2to3[0] | A4to5[1] | A6to7[0]));		
            assign DcdD[70] = (~(A0to1[0] | A2to3[0] | A4to5[0] | A6to7[2]));		
            assign DcdD[71] = (~(A0to1[0] | A2to3[0] | A4to5[0] | A6to7[1]));		
            assign synzero  = (~(A0to1[0] | A2to3[0] | A4to5[0] | A6to7[0]));		

            assign corrd[0:63] = din[0:63] ^ DcdD[0:63];

            assign sbe_int = (DcdD[0:71] != {72{1'b0}}) ? 1'b1 :
                             1'b0;
            assign sbe = sbe_int;
            assign ue = (~sbe_int) & (~synzero) & encorr;
         end
      endgenerate

      generate		
         if (REGSIZE == 32)
         begin : ecc32
            wire [0:6]                syn;
            wire [0:38]               DcdD;		
            wire                      synzero;
            wire                      sbe_int;
            wire [0:3]                A0to1;
            wire [0:3]                A2to3;
            wire [0:7]                A4to6;


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

            assign DcdD[0]  = (~(A0to1[3] | A2to3[2] | A4to6[0]));		
            assign DcdD[1]  = (~(A0to1[3] | A2to3[1] | A4to6[0]));		
            assign DcdD[2]  = (~(A0to1[2] | A2to3[3] | A4to6[0]));		
            assign DcdD[3]  = (~(A0to1[1] | A2to3[3] | A4to6[0]));		
            assign DcdD[4]  = (~(A0to1[3] | A2to3[0] | A4to6[4]));		
            assign DcdD[5]  = (~(A0to1[2] | A2to3[2] | A4to6[4]));		
            assign DcdD[6]  = (~(A0to1[1] | A2to3[2] | A4to6[4]));		
            assign DcdD[7]  = (~(A0to1[2] | A2to3[1] | A4to6[4]));		
            assign DcdD[8]  = (~(A0to1[1] | A2to3[1] | A4to6[4]));		
            assign DcdD[9]  = (~(A0to1[0] | A2to3[3] | A4to6[4]));		
            assign DcdD[10] = (~(A0to1[3] | A2to3[3] | A4to6[4]));		
            assign DcdD[11] = (~(A0to1[3] | A2to3[0] | A4to6[2]));		
            assign DcdD[12] = (~(A0to1[2] | A2to3[2] | A4to6[2]));		
            assign DcdD[13] = (~(A0to1[1] | A2to3[2] | A4to6[2]));		
            assign DcdD[14] = (~(A0to1[2] | A2to3[1] | A4to6[2]));		
            assign DcdD[15] = (~(A0to1[1] | A2to3[1] | A4to6[2]));		
            assign DcdD[16] = (~(A0to1[0] | A2to3[3] | A4to6[2]));		
            assign DcdD[17] = (~(A0to1[3] | A2to3[3] | A4to6[2]));		
            assign DcdD[18] = (~(A0to1[2] | A2to3[0] | A4to6[6]));		
            assign DcdD[19] = (~(A0to1[1] | A2to3[0] | A4to6[6]));		
            assign DcdD[20] = (~(A0to1[0] | A2to3[2] | A4to6[6]));		
            assign DcdD[21] = (~(A0to1[3] | A2to3[2] | A4to6[6]));		
            assign DcdD[22] = (~(A0to1[0] | A2to3[1] | A4to6[6]));		
            assign DcdD[23] = (~(A0to1[3] | A2to3[1] | A4to6[6]));		
            assign DcdD[24] = (~(A0to1[2] | A2to3[3] | A4to6[6]));		
            assign DcdD[25] = (~(A0to1[1] | A2to3[3] | A4to6[6]));		
            assign DcdD[26] = (~(A0to1[3] | A2to3[0] | A4to6[1]));		
            assign DcdD[27] = (~(A0to1[2] | A2to3[2] | A4to6[1]));		
            assign DcdD[28] = (~(A0to1[1] | A2to3[2] | A4to6[1]));		
            assign DcdD[29] = (~(A0to1[2] | A2to3[1] | A4to6[1]));		
            assign DcdD[30] = (~(A0to1[1] | A2to3[1] | A4to6[1]));		
            assign DcdD[31] = (~(A0to1[0] | A2to3[3] | A4to6[1]));		
            assign DcdD[32] = (~(A0to1[2] | A2to3[0] | A4to6[0]));		
            assign DcdD[33] = (~(A0to1[1] | A2to3[0] | A4to6[0]));		
            assign DcdD[34] = (~(A0to1[0] | A2to3[2] | A4to6[0]));		
            assign DcdD[35] = (~(A0to1[0] | A2to3[1] | A4to6[0]));		
            assign DcdD[36] = (~(A0to1[0] | A2to3[0] | A4to6[4]));		
            assign DcdD[37] = (~(A0to1[0] | A2to3[0] | A4to6[2]));		
            assign DcdD[38] = (~(A0to1[0] | A2to3[0] | A4to6[1]));		
            assign synzero  = (~(A0to1[0] | A2to3[0] | A4to6[0]));		

            assign corrd[0:31] = din[0:31] ^ DcdD[0:31];

            assign sbe_int = (DcdD[0:38] != {39{1'b0}}) ? 1'b1 :
                             1'b0;
            assign sbe = sbe_int;
            assign ue = (~sbe_int) & (~synzero) & encorr;

         end
      endgenerate
endmodule


