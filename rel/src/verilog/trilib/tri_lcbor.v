// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns


module tri_lcbor(clkoff_b, thold, sg, act_dis, force_t, thold_b);
   input      clkoff_b;
   input      thold;
   input      sg;
   input      act_dis;
   output     force_t;
   output     thold_b;

   (* analysis_not_referenced="true" *)
   wire       unused;

   assign unused = clkoff_b | sg | act_dis;

   assign force_t = 1'b0;
   assign thold_b = (~thold);
endmodule

