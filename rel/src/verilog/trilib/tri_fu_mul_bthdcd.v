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
// *! FILE NAME    :  tri_fu_mul_bthdcd.vhdl
// *! DESCRIPTION  :  Booth Decode
// *!****************************************************************

   `include "tri_a2o.vh"

module tri_fu_mul_bthdcd(
   i0,
   i1,
   i2,
   s_neg,
   s_x,
   s_x2
);
   input   i0;
   input   i1;
   input   i2;
   output  s_neg;
   output  s_x;
   output  s_x2;

   //  ATTRIBUTE btr_name   OF tri_fu_mul_bthdcd          : ENTITY IS "tri_fu_mul_bthdcd";

   wire    s_add;
   wire    sx1_a0_b;
   wire    sx1_a1_b;
   wire    sx1_t;
   wire    sx1_i;
   wire    sx2_a0_b;
   wire    sx2_a1_b;
   wire    sx2_t;
   wire    sx2_i;
   wire    i0_b;
   wire    i1_b;
   wire    i2_b;

   // i0:2      booth recode table
   //--------------------------------
   // 000  add  sh1=0 sh2=0  sub_adj=0
   // 001  add  sh1=1 sh2=0  sub_adj=0
   // 010  add  sh1=1 sh2=0  sub_adj=0
   // 011  add  sh1=0 sh2=1  sub_adj=0
   // 100  sub  sh1=0 sh2=1  sub_adj=1
   // 101  sub  sh1=1 sh2=0  sub_adj=1
   // 110  sub  sh1=1 sh2=0  sub_adj=1
   // 111  sub  sh1=0 sh2=0  sub_adj=0

   // logically correct
   //----------------------------------
   //  s_neg <= (i0);
   //  s_x   <= (       not i1 and     i2) or (           i1 and not i2);
   //  s_x2  <= (i0 and not i1 and not i2) or (not i0 and i1 and     i2);

   assign i0_b = (~(i0));
   assign i1_b = (~(i1));
   assign i2_b = (~(i2));

   assign s_add = (~(i0));
   assign s_neg = (~(s_add));

   assign sx1_a0_b = (~(i1_b & i2));
   assign sx1_a1_b = (~(i1 & i2_b));
   assign sx1_t = (~(sx1_a0_b & sx1_a1_b));
   assign sx1_i = (~(sx1_t));
   assign s_x = (~(sx1_i));

   assign sx2_a0_b = (~(i0 & i1_b & i2_b));
   assign sx2_a1_b = (~(i0_b & i1 & i2));
   assign sx2_t = (~(sx2_a0_b & sx2_a1_b));
   assign sx2_i = (~(sx2_t));
   assign s_x2 = (~(sx2_i));

endmodule
