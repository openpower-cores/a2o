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
