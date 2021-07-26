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
