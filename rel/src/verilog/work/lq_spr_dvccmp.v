// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns

//  Description:  XU SPR - DVC compare component
//
//*****************************************************************************

`include "tri_a2o.vh"

module lq_spr_dvccmp(
   en,
   en00,
   cmp,
   dvcm,
   dvcbe,
   dvc_cmpr
);

//-------------------------------------------------------------------
// Generics
//-------------------------------------------------------------------
parameter			    REGSIZE = 64;

input			        en;
input			        en00;
input [8-(REGSIZE/8):7]	cmp;
input [0:1]			    dvcm;
input [8-(REGSIZE/8):7]	dvcbe;
output			        dvc_cmpr;

// Signals
wire [8-(REGSIZE/8):7]	cmp_mask_or;
wire [8-(REGSIZE/8):7]	cmp_mask_and;
wire				    cmp_and;
wire				    cmp_or;
wire				    cmp_andor;

assign cmp_mask_or = (cmp | (~dvcbe)) & {(REGSIZE/8){|(dvcbe)}};
assign cmp_mask_and = (cmp & dvcbe);

assign cmp_and = &(cmp_mask_or);

assign cmp_or = |(cmp_mask_and);

generate
  if (REGSIZE == 32) begin : cmp_andor_gen32
 	 assign cmp_andor = (&(cmp_mask_or[4:5]) & |(dvcbe[4:5])) |
 	                    (&(cmp_mask_or[6:7]) & |(dvcbe[6:7]));
  end
endgenerate

generate
  if (REGSIZE == 64) begin : cmp_andor_gen64
 	 assign cmp_andor = (&(cmp_mask_or[0:1]) & |(dvcbe[0:1])) |
 	                    (&(cmp_mask_or[2:3]) & |(dvcbe[2:3])) |
 	                    (&(cmp_mask_or[4:5]) & |(dvcbe[4:5])) |
 	                    (&(cmp_mask_or[6:7]) & |(dvcbe[6:7]));
  end
endgenerate

assign dvc_cmpr = (dvcm[0:1] == 2'b00) ?  en00          :
                  (dvcm[0:1] == 2'b01) ? (en & cmp_and) :
                  (dvcm[0:1] == 2'b10) ? (en & cmp_or)  :
                                         (en & cmp_andor);

endmodule
