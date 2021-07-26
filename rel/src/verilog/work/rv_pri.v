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

//  Description:  Prioritizer
//
//*****************************************************************************

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


   // Odd Numbered Levels are inverted

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

   //assert size > 32 report "Maximum Size of 32 Exceeded!" severity error;

   assign pri[0] = cond[0];
   assign pri[1:s] = cond[1:s] & or_l5[0:s - 1];
   assign or_cond = (~or_l5[s]);

endmodule // rv_pri
