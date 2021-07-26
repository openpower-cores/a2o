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

//  Description:  Adder
//
//*****************************************************************************

module tri_st_add(
   x_b,
   y_b,
   ci,
   sum,
   cout_32,
   cout_0
);
   input [0:63]  x_b;		// after xor
   input [0:63]  y_b;
   input         ci;

   output [0:63] sum;
   output        cout_32;
   output        cout_0;

   wire [0:63]   g01;
   wire [0:63]   g01_b;
   wire [0:63]   t01;
   wire [0:63]   t01_b;
   wire [0:63]   sum_0;
   wire [0:63]   sum_1;
   wire [0:7]    g08;
   wire [0:7]    t08;
   wire [0:7]    c64_b;
   wire          cout_32x;
   wire          cout_32y_b;
   wire          ci_cp1_lv1_b;
   wire          ci_cp1_lv2;
   wire          ci_cp1_lv3_b;
   wire          ci_cp1_lv4;
   wire          ci_cp2_lv2;
   wire          ci_cp2_lv3_b;


   assign ci_cp1_lv1_b = (~ci);		// x2
   assign ci_cp1_lv2 = (~ci_cp1_lv1_b);		// x2
   assign ci_cp1_lv3_b = (~ci_cp1_lv2);		// x3
   assign ci_cp1_lv4 = (~ci_cp1_lv3_b);		// x4

   assign ci_cp2_lv2 = (~ci_cp1_lv1_b);		// x2
   assign ci_cp2_lv3_b = (~ci_cp2_lv2);		// x3

   ////##################################################
   ////## pgt
   ////##################################################
   // extra logic on [63] is performance penalty to agen (dont need ci ).
   // ci*x + ci*y + xy
   // x(ci + y) + (ci * y )

   assign g01[0:63] = (~(x_b[0:63] | y_b[0:63]));
   assign t01[0:63] = (~(x_b[0:63] & y_b[0:63]));
   assign g01_b[0:63] = (~g01[0:63]);		// small,  buffer off
   assign t01_b[0:63] = (~t01[0:63]);		// small,  buffer off

   ////##################################################
   ////## local part of byte group
   ////##################################################


   tri_st_add_loc loc_0(
      .g01_b(g01_b[0:7]),		//i--
      .t01_b(t01_b[0:7]),		//i--
      .sum_0(sum_0[0:7]),		//o--
      .sum_1(sum_1[0:7])		//o--
   );


   tri_st_add_loc loc_1(
      .g01_b(g01_b[8:15]),		//i--
      .t01_b(t01_b[8:15]),		//i--
      .sum_0(sum_0[8:15]),		//o--
      .sum_1(sum_1[8:15])		//o--
   );


   tri_st_add_loc loc_2(
      .g01_b(g01_b[16:23]),		//i--
      .t01_b(t01_b[16:23]),		//i--
      .sum_0(sum_0[16:23]),		//o--
      .sum_1(sum_1[16:23])		//o--
   );


   tri_st_add_loc loc_3(
      .g01_b(g01_b[24:31]),		//i--
      .t01_b(t01_b[24:31]),		//i--
      .sum_0(sum_0[24:31]),		//o--
      .sum_1(sum_1[24:31])		//o--
   );


   tri_st_add_loc loc_4(
      .g01_b(g01_b[32:39]),		//i--
      .t01_b(t01_b[32:39]),		//i--
      .sum_0(sum_0[32:39]),		//o--
      .sum_1(sum_1[32:39])		//o--
   );


   tri_st_add_loc loc_5(
      .g01_b(g01_b[40:47]),		//i--
      .t01_b(t01_b[40:47]),		//i--
      .sum_0(sum_0[40:47]),		//o--
      .sum_1(sum_1[40:47])		//o--
   );


   tri_st_add_loc loc_6(
      .g01_b(g01_b[48:55]),		//i--
      .t01_b(t01_b[48:55]),		//i--
      .sum_0(sum_0[48:55]),		//o--
      .sum_1(sum_1[48:55])		//o--
   );


   tri_st_add_loc loc_7(
      .g01_b(g01_b[56:63]),		//i--
      .t01_b(t01_b[56:63]),		//i--
      .sum_0(sum_0[56:63]),		//o--
      .sum_1(sum_1[56:63])		//o--
   );

   ////##################################################
   ////## local part of global carry
   ////##################################################


   tri_st_add_glbloc gclc_0(
      .g01(g01[0:7]),		//i--
      .t01(t01[0:7]),		//i--
      .g08(g08[0]),		//o--
      .t08(t08[0])		//o--
   );


   tri_st_add_glbloc gclc_1(
      .g01(g01[8:15]),		//i--
      .t01(t01[8:15]),		//i--
      .g08(g08[1]),		//o--
      .t08(t08[1])		//o--
   );


   tri_st_add_glbloc gclc_2(
      .g01(g01[16:23]),		//i--
      .t01(t01[16:23]),		//i--
      .g08(g08[2]),		//o--
      .t08(t08[2])		//o--
   );


   tri_st_add_glbloc gclc_3(
      .g01(g01[24:31]),		//i--
      .t01(t01[24:31]),		//i--
      .g08(g08[3]),		//o--
      .t08(t08[3])		//o--
   );


   tri_st_add_glbloc gclc_4(
      .g01(g01[32:39]),		//i--
      .t01(t01[32:39]),		//i--
      .g08(g08[4]),		//o--
      .t08(t08[4])		//o--
   );


   tri_st_add_glbloc gclc_5(
      .g01(g01[40:47]),		//i--
      .t01(t01[40:47]),		//i--
      .g08(g08[5]),		//o--
      .t08(t08[5])		//o--
   );


   tri_st_add_glbloc gclc_6(
      .g01(g01[48:55]),		//i--
      .t01(t01[48:55]),		//i--
      .g08(g08[6]),		//o--
      .t08(t08[6])		//o--
   );


   tri_st_add_glbloc gclc_7(
      .g01(g01[56:63]),		//i--
      .t01(t01[56:63]),		//i--
      .g08(g08[7]),		//o--
      .t08(t08[7])		//o--
   );

   ////##################################################
   ////## global part of global carry
   ////##################################################


   tri_st_add_glbglbci gc(
      .g08(g08[0:7]),		//i--
      .t08(t08[0:7]),		//i--
      .ci(ci_cp1_lv4),		//i--
      .c64_b(c64_b[0:7])		//o--
   );

   assign cout_32x = (~c64_b[4]);		//(small)
   assign cout_32y_b = (~cout_32x);
   assign cout_32 = (~cout_32y_b);		//output--

   assign cout_0 = (~c64_b[0]);		//output-- --rename--

   ////##################################################
   ////## final mux
   ////##################################################


   tri_st_add_csmux fm_0(
      .ci_b(c64_b[1]),		//i--
      .sum_0(sum_0[0:7]),		//i--
      .sum_1(sum_1[0:7]),		//i--
      .sum(sum[0:7])		//o--
   );


   tri_st_add_csmux fm_1(
      .ci_b(c64_b[2]),		//i--
      .sum_0(sum_0[8:15]),		//i--
      .sum_1(sum_1[8:15]),		//i--
      .sum(sum[8:15])		//o--
   );


   tri_st_add_csmux fm_2(
      .ci_b(c64_b[3]),		//i--
      .sum_0(sum_0[16:23]),		//i--
      .sum_1(sum_1[16:23]),		//i--
      .sum(sum[16:23])		//o--
   );


   tri_st_add_csmux fm_3(
      .ci_b(c64_b[4]),		//i--
      .sum_0(sum_0[24:31]),		//i--
      .sum_1(sum_1[24:31]),		//i--
      .sum(sum[24:31])		//o--
   );


   tri_st_add_csmux fm_4(
      .ci_b(c64_b[5]),		//i--
      .sum_0(sum_0[32:39]),		//i--
      .sum_1(sum_1[32:39]),		//i--
      .sum(sum[32:39])		//o--
   );


   tri_st_add_csmux fm_5(
      .ci_b(c64_b[6]),		//i--
      .sum_0(sum_0[40:47]),		//i--
      .sum_1(sum_1[40:47]),		//i--
      .sum(sum[40:47])		//o--
   );


   tri_st_add_csmux fm_6(
      .ci_b(c64_b[7]),		//i--
      .sum_0(sum_0[48:55]),		//i--
      .sum_1(sum_1[48:55]),		//i--
      .sum(sum[48:55])		//o--
   );


   tri_st_add_csmux fm_7(
      .ci_b(ci_cp2_lv3_b),		//i--
      .sum_0(sum_0[56:63]),		//i--
      .sum_1(sum_1[56:63]),		//i--
      .sum(sum[56:63])		//o--
   );


endmodule
