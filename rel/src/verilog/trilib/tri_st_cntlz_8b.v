// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

//*****************************************************************************
//  Description:  XU 8 bit Count Leading Zeros Macro
//
//*****************************************************************************

module tri_st_cntlz_8b(
   a,
   y,
   z_b
);
   input [0:7]  a;
   output [0:2] y;
   output       z_b;

   wire [0:7]   a0;
   wire [0:7]   a1;
   wire [0:7]   a2;
   wire [0:6]   ax;

   assign a0[1:7] = ~( a[0:6] | a[1:7]);
   assign a1[2:7] = ~(a0[0:5] & a0[2:7]);
   assign a2[4:7] = ~(a1[0:3] | a1[4:7]);

   assign a0[0:0] = (~a[0:0]);
   assign a1[0:1] = (~a0[0:1]);
   assign a2[0:3] = (~a1[0:3]);

   assign ax[0:6] = ~(a2[0:6] & a[1:7]);

   assign z_b = (~a2[7]);

   assign y[0] = ~(ax[3] & ax[4]) | ~(ax[5] & ax[6]);
   assign y[1] = ~(ax[1] & ax[2]) | ~(ax[5] & ax[6]);
   assign y[2] = ~(ax[0] & ax[2]) | ~(ax[4] & ax[6]);

endmodule
