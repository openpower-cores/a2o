// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

module tri_bthmx(x, sneg, sx, sx2, right, left, q, vd, gd);

input          x;
input          sneg;
input          sx;
input          sx2;
input          right;
output         left;
output         q;
(* ANALYSIS_NOT_ASSIGNED="TRUE" *)
(* ANALYSIS_NOT_REFERENCED="TRUE" *)
inout          vd;
(* ANALYSIS_NOT_ASSIGNED="TRUE" *)
(* ANALYSIS_NOT_REFERENCED="TRUE" *)
inout          gd;



wire center, xn, spos;

assign xn      = ~x;
assign spos    = ~sneg;

assign center  = ~(( xn & spos ) |
                   ( x  & sneg ));

assign left    = center; 


assign q       = ( center &  sx  ) | 
                 ( right  &  sx2 ) ;

endmodule





