// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns


module rv_pri(
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
   wire [0:s] 	     or_l5;
   (* analysis_not_referenced="true" *)
   wire              or_cond;

   
   
   assign or_l1[0] = (~cond[0]);
   assign or_l1[1:s] = ~(cond[0:s - 1] | cond[1:s]);
   
   generate
      if (s >= 2)
        begin : or_l2_gen0
           assign or_l2[0:1] = (~or_l1[0:1]);
           assign or_l2[2:s] = ~(or_l1[2:s] & or_l1[0:s - 2]);
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
           assign or_l3[0:3] = (~or_l2[0:3]);
           assign or_l3[4:s] = ~(or_l2[4:s] | or_l2[0:s - 4]);
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
           assign or_l4[0:7] = (~or_l3[0:7]);
           assign or_l4[8:s] = ~(or_l3[8:s] & or_l3[0:s - 8]);
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
           assign or_l5[0:15] = (~or_l4[0:15]);
           assign or_l5[16:s] = ~(or_l4[16:s] | or_l4[0:s - 16]);
        end
   endgenerate
   generate
      if (s < 16)
        begin : or_l5_gen1
           assign or_l5 = (~or_l4);
        end
   endgenerate
   
   
   assign pri[0] = cond[0];
   assign pri[1:s] = cond[1:s] & or_l5[0:s - 1];
   assign or_cond = (~or_l5[s]);
   
endmodule 


