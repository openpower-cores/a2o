// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns


module tri_addrcmp(
   enable_lsb,
   d0,
   d1,
   eq
);

   input        enable_lsb;		
   input [0:35] d0;
   input [0:35] d1;
   output       eq;


      parameter    tiup = 1'b1;
      parameter    tidn = 1'b0;

      wire [0:35]  eq01_b;
      wire [0:18]  eq02;
      wire [0:9]   eq04_b;
      wire [0:4]   eq08;
      wire [0:1]   eq24_b;

      assign eq01_b[0:35] = (d0[0:35] ^ d1[0:35]);

      assign eq02[0] = (~(eq01_b[0] | eq01_b[1]));
      assign eq02[1] = (~(eq01_b[2] | eq01_b[3]));
      assign eq02[2] = (~(eq01_b[4] | eq01_b[5]));
      assign eq02[3] = (~(eq01_b[6] | eq01_b[7]));
      assign eq02[4] = (~(eq01_b[8] | eq01_b[9]));
      assign eq02[5] = (~(eq01_b[10] | eq01_b[11]));
      assign eq02[6] = (~(eq01_b[12] | eq01_b[13]));
      assign eq02[7] = (~(eq01_b[14] | eq01_b[15]));
      assign eq02[8] = (~(eq01_b[16] | eq01_b[17]));
      assign eq02[9] = (~(eq01_b[18] | eq01_b[19]));
      assign eq02[10] = (~(eq01_b[20] | eq01_b[21]));
      assign eq02[11] = (~(eq01_b[22] | eq01_b[23]));
      assign eq02[12] = (~(eq01_b[24] | eq01_b[25]));
      assign eq02[13] = (~(eq01_b[26] | eq01_b[27]));
      assign eq02[14] = (~(eq01_b[28] | eq01_b[29]));
      assign eq02[15] = (~(eq01_b[30] | eq01_b[31]));
      assign eq02[16] = (~(eq01_b[32] | eq01_b[33]));
      assign eq02[17] = (~(eq01_b[34]));
      assign eq02[18] = (~(eq01_b[35] & enable_lsb));

      assign eq04_b[0] = (~(eq02[0] & eq02[1]));
      assign eq04_b[1] = (~(eq02[2] & eq02[3]));
      assign eq04_b[2] = (~(eq02[4] & eq02[5]));
      assign eq04_b[3] = (~(eq02[6] & eq02[7]));
      assign eq04_b[4] = (~(eq02[8] & eq02[9]));
      assign eq04_b[5] = (~(eq02[10] & eq02[11]));
      assign eq04_b[6] = (~(eq02[12] & eq02[13]));
      assign eq04_b[7] = (~(eq02[14] & eq02[15]));
      assign eq04_b[8] = (~(eq02[16] & eq02[17]));
      assign eq04_b[9] = (~(eq02[18]));

      assign eq08[0] = (~(eq04_b[0] | eq04_b[1]));
      assign eq08[1] = (~(eq04_b[2] | eq04_b[3]));
      assign eq08[2] = (~(eq04_b[4] | eq04_b[5]));
      assign eq08[3] = (~(eq04_b[6] | eq04_b[7]));
      assign eq08[4] = (~(eq04_b[8] | eq04_b[9]));

      assign eq24_b[0] = (~(eq08[0] & eq08[1] & eq08[2]));
      assign eq24_b[1] = (~(eq08[3] & eq08[4]));

      assign eq = (~(eq24_b[0] | eq24_b[1]));		
endmodule


