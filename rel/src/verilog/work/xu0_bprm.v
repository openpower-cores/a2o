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
//  Description:  XU Bit Permute
//
//*****************************************************************************
module xu0_bprm(
   a,
   s,
   y
);
// IOs
input [0:63] a;
input [0:7]  s;
output       y;
// Signals
wire [0:7]   mh;
wire [0:7]   ml;
wire [0:63]  a1;
wire [0:63]  a2;

assign mh[0:7] = (s[0:4] == 5'b00000) ? 8'b10000000 :
                 (s[0:4] == 5'b00001) ? 8'b01000000 :
                 (s[0:4] == 5'b00010) ? 8'b00100000 :
                 (s[0:4] == 5'b00011) ? 8'b00010000 :
                 (s[0:4] == 5'b00100) ? 8'b00001000 :
                 (s[0:4] == 5'b00101) ? 8'b00000100 :
                 (s[0:4] == 5'b00110) ? 8'b00000010 :
                 (s[0:4] == 5'b00111) ? 8'b00000001 :
                                        8'b00000000 ;

assign ml[0:7] = (s[5:7] == 3'b000) ? 8'b10000000 :
                 (s[5:7] == 3'b001) ? 8'b01000000 :
                 (s[5:7] == 3'b010) ? 8'b00100000 :
                 (s[5:7] == 3'b011) ? 8'b00010000 :
                 (s[5:7] == 3'b100) ? 8'b00001000 :
                 (s[5:7] == 3'b101) ? 8'b00000100 :
                 (s[5:7] == 3'b110) ? 8'b00000010 :
                                      8'b00000001;

genvar i;
generate for (i=0; i<=7; i=i+1)
   begin : msk
      assign a1[8*i:8*i+7] =  a[8*i:8*i+7] & ml[0:7];
      assign a2[8*i:8*i+7] = a1[8*i:8*i+7] & {8{mh[i]}};
   end
endgenerate

assign y = |a2;

endmodule
