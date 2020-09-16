// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns

//  Description:  Prioritizer
//
//*****************************************************************************

module rv_rpri(
	       cond,
	       pri
	       );
   parameter         size = 32;
   input [0:size-1]  cond;
   output [0:size-1] pri;

   parameter         s = size - 1;
   wire [0:s] 	     or_l1;
   wire [0:s] 	     or_l2;
   wire [0:s] 	     or_l3;
   wire [0:s] 	     or_l4;
 (* analysis_not_referenced="<0>true" *)
   wire [0:s] 	     or_l5;

   // Odd Numbered Levels are inverted

   assign or_l1[s] = (~cond[s]);
   assign or_l1[0:s - 1] = ~(cond[0:s - 1] | cond[1:s]);

   generate
      if (s >= 2)
        begin : or_l2_gen0
           assign or_l2[s - 1:s] = (~or_l1[s - 1:s]);
           assign or_l2[0:s - 2] = ~(or_l1[2:s] & or_l1[0:s - 2]);
        end
   endgenerate
   generate
      if (s < 2)
        begin : or_l2_gen1
           assign or_l2 = (~or_l1);
        end
   endgenerate

   generate
      if (s >= 4)
        begin : or_l3_gen0
           assign or_l3[s - 3:s] = (~or_l2[s - 3:s]);
           assign or_l3[0:s - 4] = ~(or_l2[4:s] | or_l2[0:s - 4]);
        end
   endgenerate
   generate
      if (s < 4)
        begin : or_l3_gen1
           assign or_l3 = (~or_l2);
        end
   endgenerate

   generate
      if (s >= 8)
        begin : or_l4_gen0
           assign or_l4[s - 7:s] = (~or_l3[s - 7:s]);
           assign or_l4[0:s - 8] = ~(or_l3[8:s] & or_l3[0:s - 8]);
        end
   endgenerate
   generate
      if (s < 8)
        begin : or_l4_gen1
           assign or_l4 = (~or_l3);
        end
   endgenerate

   generate
      if (s >= 16)
        begin : or_l5_gen0
           assign or_l5[s - 15:s] = (~or_l4[s - 15:s]);
           assign or_l5[0:s - 16] = ~{or_l4[16:s] | or_l4[0:s - 16]};
        end
   endgenerate
   generate
      if (s < 16)
        begin : or_l5_gen1
           assign or_l5 = (~or_l4);
        end
   endgenerate

   //assert size > 32 report "Maximum Size of 32 Exceeded!" severity error;

   assign pri[s] = cond[s];
   assign pri[0:s - 1] = cond[0:s - 1] & or_l5[1:s];

endmodule
