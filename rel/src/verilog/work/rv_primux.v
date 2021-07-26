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

module rv_primux(
		 cond,
		 din,
		 dout
		 );

   parameter                   q_num_entries_g = 16;
   parameter                   q_dat_width_g = 7;
   input [0:q_num_entries_g-1] cond;
   input [0:q_dat_width_g*q_num_entries_g-1] din;
   output [0:q_dat_width_g-1] 		     dout;



   wire [0:q_dat_width_g-1]    q_dat_l1[0:7];
   wire [0:q_dat_width_g-1]    q_dat_l1a[0:7];
   wire [0:q_dat_width_g-1]    q_dat_l1b[0:7];
   wire [0:q_dat_width_g-1]    q_dat_l2[0:3];
   wire [0:q_dat_width_g-1]    q_dat_l2a[0:3];
   wire [0:q_dat_width_g-1]    q_dat_l2b[0:3];
   wire [0:q_dat_width_g-1]    q_dat_l4[0:1];
   wire [0:q_dat_width_g-1]    q_dat_l4a[0:1];
   wire [0:q_dat_width_g-1]    q_dat_l4b[0:1];
   wire [0:q_dat_width_g-1]    q_dat_l8a;
   wire [0:q_dat_width_g-1]    q_dat_l8b;
   wire [0:q_dat_width_g-1]    q_dat_l8;

   wire [1:7] 		       selval1_b;
   wire [0:7] 		       selpri1;
   wire [0:7] 		       selpri1_b;
   wire [1:3] 		       selval2;
   wire [0:3] 		       selpri2;
   wire [0:3] 		       selpri2_b;
   wire [1:1] 		       selval4_b;
   wire [0:1] 		       selpri4;
   wire [0:1] 		       selpri4_b;
   wire                        selpri8;
   wire                        selpri8_b;

   (* analysis_not_referenced="true" *)
   wire                        selpri1_unused;
   (* analysis_not_referenced="true" *)
   wire                        selpri1_b_unused;
   (* analysis_not_referenced="true" *)
   wire [0:q_dat_width_g-1]    q_dat_l1_unused;
   (* analysis_not_referenced="true" *)
   wire                        cond_unused;

   genvar                      n;

   parameter aryoff = q_dat_width_g;

   assign cond_unused =  cond[0];
   tri_nor2 selval1_b1(selval1_b[1], cond[2], cond[3]);
   tri_nor2 selval1_b2(selval1_b[2], cond[4], cond[5]);
   tri_nor2 selval1_b3(selval1_b[3], cond[6], cond[7]);

   generate
      if (q_num_entries_g == 8)
        begin : selval1_gen08
	   assign selval1_b[4] = 1'b1;
	   assign selval1_b[5] = 1'b1;
           assign selval1_b[6] = 1'b1;
           assign selval1_b[7] = 1'b1;
        end
   endgenerate
   generate
      if (q_num_entries_g == 12)
        begin : selval1_gen0
	   tri_nor2 selval1_b4(selval1_b[4], cond[8], cond[9]);
	   tri_nor2 selval1_b5(selval1_b[5], cond[10], cond[11]);
           assign selval1_b[6] = 1'b1;
           assign selval1_b[7] = 1'b1;
        end
   endgenerate
   generate
      if (q_num_entries_g == 16)
        begin : selval1_gen1
	   tri_nor2 selval1_b4(selval1_b[4], cond[8], cond[9]);
	   tri_nor2 selval1_b5(selval1_b[5], cond[10], cond[11]);
           tri_nor2 selval1_b6(selval1_b[6], cond[12], cond[13]);
           tri_nor2 selval1_b7(selval1_b[7], cond[14], cond[15]);
        end
   endgenerate

   tri_inv selpri1_b0( selpri1_b[0], cond[1]);
   tri_inv selpri1_b1( selpri1_b[1], cond[3]);
   tri_inv selpri1_b2( selpri1_b[2], cond[5]);
   tri_inv selpri1_b3( selpri1_b[3], cond[7]);
   generate
      if (q_num_entries_g == 8)
        begin : selpri1_gen08
	   assign selpri1_b[4] = 1'b1;
	   assign selpri1_b[5] = 1'b1;
           assign selpri1_b[6] = 1'b1;
           assign selpri1_b[7] = 1'b1;
           assign selpri1_b_unused = selpri1_b[4] | selpri1_b[5] | selpri1_b[6] | selpri1_b[7] ;
        end
   endgenerate
   generate
      if (q_num_entries_g == 12)
        begin : selpri1_gen0
	   tri_inv selpri1_b4( selpri1_b[4], cond[9]);
	   tri_inv selpri1_b5( selpri1_b[5], cond[11]);
           assign selpri1_b[6] = 1'b1;
           assign selpri1_b[7] = 1'b1;
           assign selpri1_b_unused = selpri1_b[6] | selpri1_b[7] ;
        end
   endgenerate
   generate
      if (q_num_entries_g == 16)
        begin : selpri1_gen1
	   tri_inv selpri1_b4( selpri1_b[4], cond[9]);
	   tri_inv selpri1_b5( selpri1_b[5], cond[11]);
           tri_inv selpri1_b6( selpri1_b[6], cond[13]);
           tri_inv selpri1_b7( selpri1_b[7], cond[15]);
           assign selpri1_b_unused =1'b0;
        end
   endgenerate

   tri_inv selpri1_0( selpri1[0], selpri1_b[0]);
   tri_inv selpri1_1( selpri1[1], selpri1_b[1]);
   tri_inv selpri1_2( selpri1[2], selpri1_b[2]);
   tri_inv selpri1_3( selpri1[3], selpri1_b[3]);
   generate
      if (q_num_entries_g == 8)
        begin : selpri1_gen0b8
	   assign selpri1[4] = 1'b0;
	   assign selpri1[5] = 1'b0;
           assign selpri1[6] = 1'b0;
           assign selpri1[7] = 1'b0;
           assign selpri1_unused = selpri1[4] | selpri1[5] | selpri1[6] | selpri1[7] ;
        end
   endgenerate
   generate
      if (q_num_entries_g == 12)
        begin : selpri1_gen0b
	   tri_inv selpri1_4( selpri1[4], selpri1_b[4]);
	   tri_inv selpri1_5( selpri1[5], selpri1_b[5]);
           assign selpri1[6] = 1'b0;
           assign selpri1[7] = 1'b0;
           assign selpri1_unused = selpri1[6] | selpri1[7];
        end
   endgenerate
   generate
      if (q_num_entries_g == 16)
        begin : selpri1_gen1b
	   tri_inv selpri1_4( selpri1[4], selpri1_b[4]);
	   tri_inv selpri1_5( selpri1[5], selpri1_b[5]);
	   tri_inv selpri1_6( selpri1[6], selpri1_b[6]);
	   tri_inv selpri1_7( selpri1[7], selpri1_b[7]);

           assign selpri1_unused=1'b0;

        end
   endgenerate

   tri_nand2 selval21(selval2[1], selval1_b[2], selval1_b[3]);
   tri_nand2 selval22(selval2[2], selval1_b[4], selval1_b[5]);
   tri_nand2 selval23(selval2[3], selval1_b[6], selval1_b[7]);

   assign selpri2[0] = (~selval1_b[1]);
   assign selpri2[1] = (~selval1_b[3]);
   assign selpri2[2] = (~selval1_b[5]);
   assign selpri2[3] = (~selval1_b[7]);
   assign selpri2_b[0] = selval1_b[1];
   assign selpri2_b[1] = selval1_b[3];
   assign selpri2_b[2] = selval1_b[5];
   assign selpri2_b[3] = selval1_b[7];

   tri_nor2 selval4_b1(selval4_b[1], selval2[2], selval2[3]);

   assign selpri4_b[0] = (~selval2[1]);
   assign selpri4_b[1] = (~selval2[3]);
   assign selpri4[0] = selval2[1];
   assign selpri4[1] = selval2[3];

   assign selpri8 = (~selval4_b[1]);
   assign selpri8_b = selval4_b[1];

   //-------------------------------------------------------------------------------------------------------
   // Instruction Muxing
   //-------------------------------------------------------------------------------------------------------
   generate
      begin : xhdl
         for (n = 0; n <= (q_dat_width_g - 1); n = n + 1)
           begin : gendat

   // Level 1
   // 01 23 45 67 89 1011 1213 1415
   tri_nand2 q_dat_l1a0(q_dat_l1a[0][n], din[0*aryoff+n], selpri1_b[0]);
   tri_nand2 q_dat_l1b0(q_dat_l1b[0][n], din[1*aryoff+n], selpri1[0]);
   tri_nand2 #(.BTR("NAND2_X3M_A9TH")) q_dat_l10(q_dat_l1[0][n], q_dat_l1a[0][n], q_dat_l1b[0][n]);

   tri_nand2 q_dat_l1a1(q_dat_l1a[1][n], din[2*aryoff+n], selpri1_b[1]);
   tri_nand2 q_dat_l1b1(q_dat_l1b[1][n], din[3*aryoff+n], selpri1[1]);
   tri_nand2 #(.BTR("NAND2_X3M_A9TH")) q_dat_l11(q_dat_l1[1][n], q_dat_l1a[1][n], q_dat_l1b[1][n]);

   tri_nand2 q_dat_l1a2(q_dat_l1a[2][n], din[4*aryoff+n], selpri1_b[2]);
   tri_nand2 q_dat_l1b2(q_dat_l1b[2][n], din[5*aryoff+n], selpri1[2]);
   tri_nand2 #(.BTR("NAND2_X3M_A9TH")) q_dat_l12(q_dat_l1[2][n], q_dat_l1a[2][n], q_dat_l1b[2][n]);

   tri_nand2 q_dat_l1a3(q_dat_l1a[3][n], din[6*aryoff+n], selpri1_b[3]);
   tri_nand2 q_dat_l1b3(q_dat_l1b[3][n], din[7*aryoff+n], selpri1[3]);
   tri_nand2 #(.BTR("NAND2_X3M_A9TH")) q_dat_l13(q_dat_l1[3][n], q_dat_l1a[3][n], q_dat_l1b[3][n]);


   //generate
      if (q_num_entries_g == 8)
        begin : l1_gen8
           assign q_dat_l1a[4][n] = 1'b0;
           assign q_dat_l1b[4][n] = 1'b0;
           assign q_dat_l1[4][n] = 1'b0;

           assign q_dat_l1a[5][n] = 1'b0;
           assign q_dat_l1b[5][n] = 1'b0;
           assign q_dat_l1[5][n] = 1'b0;

           assign q_dat_l1a[6][n] = 1'b0;
           assign q_dat_l1b[6][n] = 1'b0;
           assign q_dat_l1[6][n] = 1'b0;

           assign q_dat_l1a[7][n] = 1'b0;
           assign q_dat_l1b[7][n] = 1'b0;
           assign q_dat_l1[7][n] = 1'b0;

           assign q_dat_l1_unused[n] = (|q_dat_l1a[4][n]) | (|q_dat_l1a[5][n]) | (|q_dat_l1a[6][n]) | (|q_dat_l1a[7][n]) |
                                       (|q_dat_l1b[4][n]) | (|q_dat_l1b[5][n]) | (|q_dat_l1b[6][n]) | (|q_dat_l1b[7][n]) |
                                       (|q_dat_l1[4][n]) | (|q_dat_l1[5][n]) | (|q_dat_l1[6][n]) | (|q_dat_l1[7][n]) ;
        end
   //endgenerate
   //generate
      if (q_num_entries_g == 12)
        begin : l1_gen12
	   tri_nand2 q_dat_l1a4(q_dat_l1a[4][n], din[8*aryoff+n], selpri1_b[4]);
	   tri_nand2 q_dat_l1b4(q_dat_l1b[4][n], din[9*aryoff+n], selpri1[4]);
	   tri_nand2 #(.BTR("NAND2_X3M_A9TH")) q_dat_l14(q_dat_l1[4][n], q_dat_l1a[4][n], q_dat_l1b[4][n]);

	   tri_nand2 q_dat_l1a5(q_dat_l1a[5][n], din[10*aryoff+n], selpri1_b[5]);
	   tri_nand2 q_dat_l1b5(q_dat_l1b[5][n], din[11*aryoff+n], selpri1[5]);
	   tri_nand2 #(.BTR("NAND2_X3M_A9TH")) q_dat_l15(q_dat_l1[5][n], q_dat_l1a[5][n], q_dat_l1b[5][n]);

           assign q_dat_l1a[6][n] = 1'b0;
           assign q_dat_l1b[6][n] = 1'b0;
           assign q_dat_l1[6][n] = 1'b0;

           assign q_dat_l1a[7][n] = 1'b0;
           assign q_dat_l1b[7][n] = 1'b0;
           assign q_dat_l1[7][n] = 1'b0;

           assign q_dat_l1_unused[n] = (|q_dat_l1a[6][n]) | (|q_dat_l1a[7][n]) |
                                       (|q_dat_l1b[6][n]) | (|q_dat_l1b[7][n]) |
                                       (|q_dat_l1[6][n]) | (|q_dat_l1[7][n]) ;
        end
   //endgenerate
   //generate
      if (q_num_entries_g == 16)
        begin : l1_gen16

	   tri_nand2 q_dat_l1a4(q_dat_l1a[4][n], din[8*aryoff+n], selpri1_b[4]);
	   tri_nand2 q_dat_l1b4(q_dat_l1b[4][n], din[9*aryoff+n], selpri1[4]);
	   tri_nand2 q_dat_l14(q_dat_l1[4][n], q_dat_l1a[4][n], q_dat_l1b[4][n]);

	   tri_nand2 q_dat_l1a5(q_dat_l1a[5][n], din[10*aryoff+n], selpri1_b[5]);
	   tri_nand2 q_dat_l1b5(q_dat_l1b[5][n], din[11*aryoff+n], selpri1[5]);
	   tri_nand2 #(.BTR("NAND2_X3M_A9TH")) q_dat_l15(q_dat_l1[5][n], q_dat_l1a[5][n], q_dat_l1b[5][n]);

	   tri_nand2 q_dat_l1a6(q_dat_l1a[6][n], din[12*aryoff+n], selpri1_b[6]);
           tri_nand2 q_dat_l1b6(q_dat_l1b[6][n], din[13*aryoff+n], selpri1[6]);
           tri_nand2 #(.BTR("NAND2_X3M_A9TH")) q_dat_l16(q_dat_l1[6][n], q_dat_l1a[6][n], q_dat_l1b[6][n]);

           tri_nand2 q_dat_l1a7(q_dat_l1a[7][n], din[14*aryoff+n], selpri1_b[7]);
           tri_nand2 q_dat_l1b7(q_dat_l1b[7][n], din[15*aryoff+n], selpri1[7]);
           tri_nand2 #(.BTR("NAND2_X3M_A9TH")) q_dat_l17(q_dat_l1[7][n], q_dat_l1a[7][n], q_dat_l1b[7][n]);

           assign q_dat_l1_unused[n]=1'b0;
        end
   //endgenerate
           end
      end
   endgenerate


   // Level 2
   // 0123 4567 891011 12131415
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l2a0(q_dat_l2a[0], q_dat_l1[0], {q_dat_width_g{selpri2_b[0]}});
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l2b0(q_dat_l2b[0], q_dat_l1[1], {q_dat_width_g{selpri2[0]}});
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l20(q_dat_l2[0], q_dat_l2a[0], q_dat_l2b[0]);

   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l2a1(q_dat_l2a[1], q_dat_l1[2], {q_dat_width_g{selpri2_b[1]}});
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l2b1(q_dat_l2b[1], q_dat_l1[3], {q_dat_width_g{selpri2[1]}});
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l21(q_dat_l2[1], q_dat_l2a[1], q_dat_l2b[1]);

   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l2a2(q_dat_l2a[2], q_dat_l1[4], {q_dat_width_g{selpri2_b[2]}});
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l2b2(q_dat_l2b[2], q_dat_l1[5], {q_dat_width_g{selpri2[2]}});
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l22(q_dat_l2[2], q_dat_l2a[2], q_dat_l2b[2]);

   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l2a3(q_dat_l2a[3], q_dat_l1[6], {q_dat_width_g{selpri2_b[3]}});
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l2b3(q_dat_l2b[3], q_dat_l1[7], {q_dat_width_g{selpri2[3]}});
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l23(q_dat_l2[3], q_dat_l2a[3], q_dat_l2b[3]);

   // Level 4
   // 01234567 89101112131415
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l4a0(q_dat_l4a[0], q_dat_l2[0], {q_dat_width_g{selpri4_b[0]}});
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l4b0(q_dat_l4b[0], q_dat_l2[1], {q_dat_width_g{selpri4[0]}});
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X4M_A9TH")) q_dat_l40(q_dat_l4[0], q_dat_l4a[0], q_dat_l4b[0]);

   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l4a1(q_dat_l4a[1], q_dat_l2[2], {q_dat_width_g{selpri4_b[1]}});
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X3M_A9TH")) q_dat_l4b1(q_dat_l4b[1], q_dat_l2[3], {q_dat_width_g{selpri4[1]}});
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X4M_A9TH")) q_dat_l41(q_dat_l4[1], q_dat_l4a[1], q_dat_l4b[1]);

   // Level 8
   // 0123456789101112131415
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X6M_A9TH")) q_dat_l8a0(q_dat_l8a, q_dat_l4[0], {q_dat_width_g{selpri8_b}});
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X6M_A9TH")) q_dat_l8b0(q_dat_l8b, q_dat_l4[1], {q_dat_width_g{selpri8}});
   tri_nand2 #(.WIDTH(q_dat_width_g), .BTR("NAND2_X8M_A9TH")) q_dat_180( q_dat_l8, q_dat_l8a, q_dat_l8b);

   assign dout = q_dat_l8;

endmodule // rv_primux
