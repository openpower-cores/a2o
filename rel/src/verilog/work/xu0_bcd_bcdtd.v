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
//  Description:  XU BCD to DPD Conversion
//
//*****************************************************************************

module xu0_bcd_bcdtd(
   input [0:11] a,
   output [0:9] y
);

   assign y[0] = (a[5] & a[0] & a[8] & (~a[4])) | (a[9] & a[0] & (~a[8])) | (a[1] & (~a[0]));
   assign y[1] = (a[6] & a[0] & a[8] & (~a[4])) | (a[10] & a[0] & (~a[8])) | (a[2] & (~a[0]));
   assign y[2] = a[3];
   assign y[3] = (a[9] &  (~a[0]) & a[4] & (~a[8])) | (a[5] & (~a[8]) & (~a[4])) | (a[5] & (~a[0]) & (~a[4])) | (a[4] & a[8]);
   assign y[4] = (a[10] & (~a[0]) & a[4] & (~a[8])) | (a[6] & (~a[8]) & (~a[4])) | (a[6] & (~a[0]) & (~a[4])) | (a[0] & a[8]);
   assign y[5] = a[7];
   assign y[6] = a[0] | a[4] | a[8];
   assign y[7] = ((~a[4]) & a[9] &  (~a[8])) | (a[4] & a[8]) | a[0];
   assign y[8] = ((~a[0]) & a[10] & (~a[8])) | (a[0] & a[8]) | a[4];
   assign y[9] = a[11];

endmodule
