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


module tri_csa42(
   a,
   b,
   c,
   d,
   ki,
   ko,
   car,
   sum,
   vd,
   gd
);
   input   a;
   input   b;
   input   c;
   input   d;
   input   ki;
   output  ko;
   output  car;
   output  sum;
   (* ANALYSIS_NOT_ASSIGNED="TRUE" *)
   (* ANALYSIS_NOT_REFERENCED="TRUE" *)
   inout   vd;
   (* ANALYSIS_NOT_ASSIGNED="TRUE" *)
   (* ANALYSIS_NOT_REFERENCED="TRUE" *)
   inout   gd;

   wire    s1;

   wire    carn1;
   wire    carn2;
   wire    carn3;
   wire    kon1;
   wire    kon2;
   wire    kon3;

//   assign  s1 = b ^ c ^ d;
   tri_xor3 CSA42_XOR3_1(s1,b,c,d);

//   assign sum = s1 ^ a ^ ki;
   tri_xor3 CSA42_XOR3_2(sum,s1,a,ki);

//   assign car = (s1 & a) | (s1 & ki) | (a & ki);
   tri_nand2 CSA42_NAND2_1(carn1,s1,a);
   tri_nand2 CSA42_NAND2_2(carn2,s1,ki);
   tri_nand2 CSA42_NAND2_3(carn3,a,ki);
   tri_nand3 CSA42_NAND3_4(car,carn1,carn2,carn3);

//   assign ko = (b & c) | (b & d) | (c & d);
   tri_nand2 CSA42_NAND2_5(kon1,b,c);
   tri_nand2 CSA42_NAND2_6(kon2,b,d);
   tri_nand2 CSA42_NAND2_7(kon3,c,d);
   tri_nand3 CSA42_NAND3_8(ko,kon1,kon2,kon3);


endmodule
