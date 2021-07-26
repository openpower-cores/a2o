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

// *!****************************************************************
// *! FILENAME    : tri_plat.v
// *! DESCRIPTION : Non-scannable pipeline latch
// *!****************************************************************

`include "tri_a2o.vh"

module tri_plat(vd, gd, nclk, flush, din, q);
   parameter                      WIDTH = 1;
   parameter                      OFFSET = 0;
   parameter                      INIT = 0;		// will be converted to the least signficant 31 bits of init_v
   parameter                      SYNTHCLONEDLATCH = "";

   inout                          vd;
   inout                          gd;
   input  [0:`NCLK_WIDTH-1]       nclk;
   input                          flush;
   input  [OFFSET:OFFSET+WIDTH-1] din;
   output [OFFSET:OFFSET+WIDTH-1] q;

   // tri_plat
   reg  [OFFSET:OFFSET+WIDTH-1]  int_dout;

   (* analysis_not_referenced="true" *)
   wire                          unused;
   assign unused = | {vd, gd, nclk[1:`NCLK_WIDTH-1]};


   always @ (posedge nclk[0])
     begin
 	int_dout <= din;
     end

   assign q = (flush == 1'b1) ? din : int_dout ;

endmodule
