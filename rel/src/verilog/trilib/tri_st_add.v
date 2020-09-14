// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.


module tri_st_add(
   x_b,
   y_b,
   ci,
   sum,
   cout_32,
   cout_0
);
   input [0:63]  x_b;		
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


   assign ci_cp1_lv1_b = (~ci);		
   assign ci_cp1_lv2 = (~ci_cp1_lv1_b);		
   assign ci_cp1_lv3_b = (~ci_cp1_lv2);		
   assign ci_cp1_lv4 = (~ci_cp1_lv3_b);		

   assign ci_cp2_lv2 = (~ci_cp1_lv1_b);		
   assign ci_cp2_lv3_b = (~ci_cp2_lv2);		


   assign g01[0:63] = (~(x_b[0:63] | y_b[0:63]));
   assign t01[0:63] = (~(x_b[0:63] & y_b[0:63]));
   assign g01_b[0:63] = (~g01[0:63]);		
   assign t01_b[0:63] = (~t01[0:63]);		



   tri_st_add_loc loc_0(
      .g01_b(g01_b[0:7]),		
      .t01_b(t01_b[0:7]),		
      .sum_0(sum_0[0:7]),		
      .sum_1(sum_1[0:7])		
   );


   tri_st_add_loc loc_1(
      .g01_b(g01_b[8:15]),		
      .t01_b(t01_b[8:15]),		
      .sum_0(sum_0[8:15]),		
      .sum_1(sum_1[8:15])		
   );


   tri_st_add_loc loc_2(
      .g01_b(g01_b[16:23]),		
      .t01_b(t01_b[16:23]),		
      .sum_0(sum_0[16:23]),		
      .sum_1(sum_1[16:23])		
   );


   tri_st_add_loc loc_3(
      .g01_b(g01_b[24:31]),		
      .t01_b(t01_b[24:31]),		
      .sum_0(sum_0[24:31]),		
      .sum_1(sum_1[24:31])		
   );


   tri_st_add_loc loc_4(
      .g01_b(g01_b[32:39]),		
      .t01_b(t01_b[32:39]),		
      .sum_0(sum_0[32:39]),		
      .sum_1(sum_1[32:39])		
   );


   tri_st_add_loc loc_5(
      .g01_b(g01_b[40:47]),		
      .t01_b(t01_b[40:47]),		
      .sum_0(sum_0[40:47]),		
      .sum_1(sum_1[40:47])		
   );


   tri_st_add_loc loc_6(
      .g01_b(g01_b[48:55]),		
      .t01_b(t01_b[48:55]),		
      .sum_0(sum_0[48:55]),		
      .sum_1(sum_1[48:55])		
   );


   tri_st_add_loc loc_7(
      .g01_b(g01_b[56:63]),		
      .t01_b(t01_b[56:63]),		
      .sum_0(sum_0[56:63]),		
      .sum_1(sum_1[56:63])		
   );



   tri_st_add_glbloc gclc_0(
      .g01(g01[0:7]),		
      .t01(t01[0:7]),		
      .g08(g08[0]),		
      .t08(t08[0])		
   );


   tri_st_add_glbloc gclc_1(
      .g01(g01[8:15]),		
      .t01(t01[8:15]),		
      .g08(g08[1]),		
      .t08(t08[1])		
   );


   tri_st_add_glbloc gclc_2(
      .g01(g01[16:23]),		
      .t01(t01[16:23]),		
      .g08(g08[2]),		
      .t08(t08[2])		
   );


   tri_st_add_glbloc gclc_3(
      .g01(g01[24:31]),		
      .t01(t01[24:31]),		
      .g08(g08[3]),		
      .t08(t08[3])		
   );


   tri_st_add_glbloc gclc_4(
      .g01(g01[32:39]),		
      .t01(t01[32:39]),		
      .g08(g08[4]),		
      .t08(t08[4])		
   );


   tri_st_add_glbloc gclc_5(
      .g01(g01[40:47]),		
      .t01(t01[40:47]),		
      .g08(g08[5]),		
      .t08(t08[5])		
   );


   tri_st_add_glbloc gclc_6(
      .g01(g01[48:55]),		
      .t01(t01[48:55]),		
      .g08(g08[6]),		
      .t08(t08[6])		
   );


   tri_st_add_glbloc gclc_7(
      .g01(g01[56:63]),		
      .t01(t01[56:63]),		
      .g08(g08[7]),		
      .t08(t08[7])		
   );



   tri_st_add_glbglbci gc(
      .g08(g08[0:7]),		
      .t08(t08[0:7]),		
      .ci(ci_cp1_lv4),		
      .c64_b(c64_b[0:7])		
   );

   assign cout_32x = (~c64_b[4]);		
   assign cout_32y_b = (~cout_32x);
   assign cout_32 = (~cout_32y_b);		

   assign cout_0 = (~c64_b[0]);		



   tri_st_add_csmux fm_0(
      .ci_b(c64_b[1]),		
      .sum_0(sum_0[0:7]),		
      .sum_1(sum_1[0:7]),		
      .sum(sum[0:7])		
   );


   tri_st_add_csmux fm_1(
      .ci_b(c64_b[2]),		
      .sum_0(sum_0[8:15]),		
      .sum_1(sum_1[8:15]),		
      .sum(sum[8:15])		
   );


   tri_st_add_csmux fm_2(
      .ci_b(c64_b[3]),		
      .sum_0(sum_0[16:23]),		
      .sum_1(sum_1[16:23]),		
      .sum(sum[16:23])		
   );


   tri_st_add_csmux fm_3(
      .ci_b(c64_b[4]),		
      .sum_0(sum_0[24:31]),		
      .sum_1(sum_1[24:31]),		
      .sum(sum[24:31])		
   );


   tri_st_add_csmux fm_4(
      .ci_b(c64_b[5]),		
      .sum_0(sum_0[32:39]),		
      .sum_1(sum_1[32:39]),		
      .sum(sum[32:39])		
   );


   tri_st_add_csmux fm_5(
      .ci_b(c64_b[6]),		
      .sum_0(sum_0[40:47]),		
      .sum_1(sum_1[40:47]),		
      .sum(sum[40:47])		
   );


   tri_st_add_csmux fm_6(
      .ci_b(c64_b[7]),		
      .sum_0(sum_0[48:55]),		
      .sum_1(sum_1[48:55]),		
      .sum(sum[48:55])		
   );


   tri_st_add_csmux fm_7(
      .ci_b(ci_cp2_lv3_b),		
      .sum_0(sum_0[56:63]),		
      .sum_1(sum_1[56:63]),		
      .sum(sum[56:63])		
   );


endmodule

