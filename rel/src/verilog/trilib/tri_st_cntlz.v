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
//  Description:  XU 64 bit Count Leading Zeros Macro
//
//*****************************************************************************

module tri_st_cntlz(
   dword,
   a,
   y
);
   input        dword;
   input [0:63] a;
   output [0:6] y;

   wire [0:23]  ys;
   wire [0:7]   z;
   wire [0:7]   zh;
   wire [0:2]   yh;
   wire [0:2]   yh_sel;
   wire         zero_b;

   assign y[0] = (dword == 1'b1) ? (~zero_b) :
                 1'b0;

   assign y[1] = (dword == 1'b1) ? yh[0] :
                 (~zero_b);
   assign y[2:3] = yh[1:2];

   // Force the select to the lower half for word ops
   assign yh_sel[0] = yh[0] | (~dword);
   assign yh_sel[1:2] = yh[1:2];

   // Force the select to be in the lower half for word
   assign y[4:6] = (yh_sel[0:2] == 3'b000) ? ys[0:2] :
                   (yh_sel[0:2] == 3'b001) ? ys[3:5] :
                   (yh_sel[0:2] == 3'b010) ? ys[6:8] :
                   (yh_sel[0:2] == 3'b011) ? ys[9:11] :
                   (yh_sel[0:2] == 3'b100) ? ys[12:14] :
                   (yh_sel[0:2] == 3'b101) ? ys[15:17] :
                   (yh_sel[0:2] == 3'b110) ? ys[18:20] :
                   ys[21:23];
   assign zh[0:3] = z[0:3] & {4{dword}};
   assign zh[4:7] = z[4:7];


   tri_st_cntlz_8b clz_h(
      .a(zh[0:7]),
      .y(yh[0:2]),
      .z_b(zero_b)
   );


   tri_st_cntlz_8b clz_l0(
      .a(a[0:7]),
      .y(ys[0:2]),
      .z_b(z[0])
   );


   tri_st_cntlz_8b clz_l1(
      .a(a[8:15]),
      .y(ys[3:5]),
      .z_b(z[1])
   );


   tri_st_cntlz_8b clz_l2(
      .a(a[16:23]),
      .y(ys[6:8]),
      .z_b(z[2])
   );


   tri_st_cntlz_8b clz_l3(
      .a(a[24:31]),
      .y(ys[9:11]),
      .z_b(z[3])
   );


   tri_st_cntlz_8b clz_l4(
      .a(a[32:39]),
      .y(ys[12:14]),
      .z_b(z[4])
   );


   tri_st_cntlz_8b clz_l5(
      .a(a[40:47]),
      .y(ys[15:17]),
      .z_b(z[5])
   );


   tri_st_cntlz_8b clz_l6(
      .a(a[48:55]),
      .y(ys[18:20]),
      .z_b(z[6])
   );


   tri_st_cntlz_8b clz_l7(
      .a(a[56:63]),
      .y(ys[21:23]),
      .z_b(z[7])
   );

endmodule
