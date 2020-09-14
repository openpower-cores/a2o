// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns


module tri_direct_err_rpt(
   vd,
   gd,
   err_in,
   err_out
);
   parameter          WIDTH = 1;		
   inout              vd;
   inout              gd;

   input [0:WIDTH-1]  err_in;
   output [0:WIDTH-1] err_out;


    (* analysis_not_referenced="true" *)
   wire               unused;

   assign unused = vd | gd;

   assign err_out = err_in;
endmodule


