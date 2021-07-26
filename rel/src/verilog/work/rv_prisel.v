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

module rv_prisel(
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

   wire [0:7] 		       selval1_b;
   wire [0:7] 		       selpri1;
   wire [0:7] 		       selpri1_b;
   wire [0:3] 		       selval2;
   wire [0:3] 		       selpri2;
   wire [0:3] 		       selpri2_b;
   wire [0:1] 		       selval4_b;
   wire [0:1] 		       selpri4;
   wire [0:1] 		       selpri4_b;
   wire                        selval8;
   wire                        selpri8;
   wire                        selpri8_b;

   (* analysis_not_referenced="true" *)
   wire                        selpri1_unused;
   (* analysis_not_referenced="true" *)
   wire                        selpri1_b_unused;
   (* analysis_not_referenced="true" *)
   wire                        q_dat_l1_unused;


   parameter aryoff = q_dat_width_g;


   assign selval1_b[0] = ~(cond[0] | cond[1]);
   assign selval1_b[1] = ~(cond[2] | cond[3]);
   assign selval1_b[2] = ~(cond[4] | cond[5]);
   assign selval1_b[3] = ~(cond[6] | cond[7]);
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
	   assign selval1_b[4] = ~(cond[8] | cond[9]);
	   assign selval1_b[5] = ~(cond[10] | cond[11]);
           assign selval1_b[6] = 1'b1;
           assign selval1_b[7] = 1'b1;
        end
   endgenerate
   generate
      if (q_num_entries_g == 16)
        begin : selval1_gen1
	   assign selval1_b[4] = ~(cond[8] | cond[9]);
	   assign selval1_b[5] = ~(cond[10] | cond[11]);
           assign selval1_b[6] = ~(cond[12] | cond[13]);
           assign selval1_b[7] = ~(cond[14] | cond[15]);
        end
   endgenerate

   assign selpri1_b[0] = (~cond[1]);
   assign selpri1_b[1] = (~cond[3]);
   assign selpri1_b[2] = (~cond[5]);
   assign selpri1_b[3] = (~cond[7]);
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
	   assign selpri1_b[4] = (~cond[9]);
	   assign selpri1_b[5] = (~cond[11]);
           assign selpri1_b[6] = 1'b1;
           assign selpri1_b[7] = 1'b1;
           assign selpri1_b_unused = selpri1_b[6] | selpri1_b[7] ;
        end
   endgenerate
   generate
      if (q_num_entries_g == 16)
        begin : selpri1_gen1
	   assign selpri1_b[4] = (~cond[9]);
	   assign selpri1_b[5] = (~cond[11]);
           assign selpri1_b[6] = (~cond[13]);
           assign selpri1_b[7] = (~cond[15]);
           assign selpri1_b_unused =1'b0;
        end
   endgenerate

   assign selpri1[0] = cond[1];
   assign selpri1[1] = cond[3];
   assign selpri1[2] = cond[5];
   assign selpri1[3] = cond[7];
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
	   assign selpri1[4] = cond[9];
	   assign selpri1[5] = cond[11];
           assign selpri1[6] = 1'b0;
           assign selpri1[7] = 1'b0;
           assign selpri1_unused = selpri1[6] | selpri1[7];
        end
   endgenerate
   generate
      if (q_num_entries_g == 16)
        begin : selpri1_gen1b
	   assign selpri1[4] = cond[9];
	   assign selpri1[5] = cond[11];
           assign selpri1[6] = cond[13];
           assign selpri1[7] = cond[15];

           assign selpri1_unused=1'b0;

        end
   endgenerate

   assign selval2[0] = ~(selval1_b[0] & selval1_b[1]);
   assign selval2[1] = ~(selval1_b[2] & selval1_b[3]);
   assign selval2[2] = ~(selval1_b[4] & selval1_b[5]);
   assign selval2[3] = ~(selval1_b[6] & selval1_b[7]);

   assign selpri2[0] = (~selval1_b[1]);
   assign selpri2[1] = (~selval1_b[3]);
   assign selpri2[2] = (~selval1_b[5]);
   assign selpri2[3] = (~selval1_b[7]);
   assign selpri2_b[0] = selval1_b[1];
   assign selpri2_b[1] = selval1_b[3];
   assign selpri2_b[2] = selval1_b[5];
   assign selpri2_b[3] = selval1_b[7];

   assign selval4_b[0] = ~(selval2[0] | selval2[1]);
   assign selval4_b[1] = ~(selval2[2] | selval2[3]);
   assign selpri4_b[0] = (~selval2[1]);
   assign selpri4_b[1] = (~selval2[3]);
   assign selpri4[0] = selval2[1];
   assign selpri4[1] = selval2[3];

   assign selval8 = ~(selval4_b[0] & selval4_b[1]);
   assign selpri8 = (~selval4_b[1]);
   assign selpri8_b = selval4_b[1];

   //-------------------------------------------------------------------------------------------------------
   // Instruction Muxing
   //-------------------------------------------------------------------------------------------------------

   // Level 1
   // 01 23 45 67 89 1011 1213 1415
   assign q_dat_l1a[0] = ~(din[0*aryoff:0*aryoff+aryoff-1] & {q_dat_width_g{selpri1_b[0]}});
   assign q_dat_l1b[0] = ~(din[1*aryoff:1*aryoff+aryoff-1] & {q_dat_width_g{selpri1[0]}});
   assign q_dat_l1[0] = ~(q_dat_l1a[0] & q_dat_l1b[0]);

   assign q_dat_l1a[1] = ~(din[2*aryoff:2*aryoff+aryoff-1] & {q_dat_width_g{selpri1_b[1]}});
   assign q_dat_l1b[1] = ~(din[3*aryoff:3*aryoff+aryoff-1] & {q_dat_width_g{selpri1[1]}});
   assign q_dat_l1[1] = ~(q_dat_l1a[1] & q_dat_l1b[1]);

   assign q_dat_l1a[2] = ~(din[4*aryoff:4*aryoff+aryoff-1] & {q_dat_width_g{selpri1_b[2]}});
   assign q_dat_l1b[2] = ~(din[5*aryoff:5*aryoff+aryoff-1] & {q_dat_width_g{selpri1[2]}});
   assign q_dat_l1[2] = ~(q_dat_l1a[2] & q_dat_l1b[2]);

   assign q_dat_l1a[3] = ~(din[6*aryoff:6*aryoff+aryoff-1] & {q_dat_width_g{selpri1_b[3]}});
   assign q_dat_l1b[3] = ~(din[7*aryoff:7*aryoff+aryoff-1] & {q_dat_width_g{selpri1[3]}});
   assign q_dat_l1[3] = ~(q_dat_l1a[3] & q_dat_l1b[3]);


   generate
      if (q_num_entries_g == 8)
        begin : l1_gen8
           assign q_dat_l1a[4] = {q_dat_width_g{1'b0}};
           assign q_dat_l1b[4] = {q_dat_width_g{1'b0}};
           assign q_dat_l1[4] = {q_dat_width_g{1'b0}};

           assign q_dat_l1a[5] = {q_dat_width_g{1'b0}};
           assign q_dat_l1b[5] = {q_dat_width_g{1'b0}};
           assign q_dat_l1[5] = {q_dat_width_g{1'b0}};

           assign q_dat_l1a[6] = {q_dat_width_g{1'b0}};
           assign q_dat_l1b[6] = {q_dat_width_g{1'b0}};
           assign q_dat_l1[6] = {q_dat_width_g{1'b0}};

           assign q_dat_l1a[7] = {q_dat_width_g{1'b0}};
           assign q_dat_l1b[7] = {q_dat_width_g{1'b0}};
           assign q_dat_l1[7] = {q_dat_width_g{1'b0}};

           assign q_dat_l1_unused = (|q_dat_l1a[4]) | (|q_dat_l1a[5]) | (|q_dat_l1a[6]) | (|q_dat_l1a[7]) |
                                    (|q_dat_l1b[4]) | (|q_dat_l1b[5]) | (|q_dat_l1b[6]) | (|q_dat_l1b[7]) |
                                    (|q_dat_l1[4]) | (|q_dat_l1[5]) | (|q_dat_l1[6]) | (|q_dat_l1[7]) ;

        end
   endgenerate
   generate
      if (q_num_entries_g == 12)
        begin : l1_gen12
	   assign q_dat_l1a[4] = ~(din[8*aryoff:8*aryoff+aryoff-1] & {q_dat_width_g{selpri1_b[4]}});
	   assign q_dat_l1b[4] = ~(din[9*aryoff:9*aryoff+aryoff-1] & {q_dat_width_g{selpri1[4]}});
	   assign q_dat_l1[4] = ~(q_dat_l1a[4] & q_dat_l1b[4]);

	   assign q_dat_l1a[5] = ~(din[10*aryoff:10*aryoff+aryoff-1] & {q_dat_width_g{selpri1_b[5]}});
	   assign q_dat_l1b[5] = ~(din[11*aryoff:11*aryoff+aryoff-1] & {q_dat_width_g{selpri1[5]}});
	   assign q_dat_l1[5] = ~(q_dat_l1a[5] & q_dat_l1b[5]);

           assign q_dat_l1a[6] = {q_dat_width_g{1'b0}};
           assign q_dat_l1b[6] = {q_dat_width_g{1'b0}};
           assign q_dat_l1[6] = {q_dat_width_g{1'b0}};

           assign q_dat_l1a[7] = {q_dat_width_g{1'b0}};
           assign q_dat_l1b[7] = {q_dat_width_g{1'b0}};
           assign q_dat_l1[7] = {q_dat_width_g{1'b0}};

           assign q_dat_l1_unused = (|q_dat_l1a[6]) | (|q_dat_l1a[7]) |
                                    (|q_dat_l1b[6]) | (|q_dat_l1b[7]) |
                                    (|q_dat_l1[6]) | (|q_dat_l1[7]) ;
        end
   endgenerate
   generate
      if (q_num_entries_g == 16)
        begin : l1_gen16

	   assign q_dat_l1a[4] = ~(din[8*aryoff:8*aryoff+aryoff-1] & {q_dat_width_g{selpri1_b[4]}});
	   assign q_dat_l1b[4] = ~(din[9*aryoff:9*aryoff+aryoff-1] & {q_dat_width_g{selpri1[4]}});
	   assign q_dat_l1[4] = ~(q_dat_l1a[4] & q_dat_l1b[4]);

	   assign q_dat_l1a[5] = ~(din[10*aryoff:10*aryoff+aryoff-1] & {q_dat_width_g{selpri1_b[5]}});
	   assign q_dat_l1b[5] = ~(din[11*aryoff:11*aryoff+aryoff-1] & {q_dat_width_g{selpri1[5]}});
	   assign q_dat_l1[5] = ~(q_dat_l1a[5] & q_dat_l1b[5]);

	   assign q_dat_l1a[6] = ~(din[12*aryoff:12*aryoff+aryoff-1] & {q_dat_width_g{selpri1_b[6]}});
           assign q_dat_l1b[6] = ~(din[13*aryoff:13*aryoff+aryoff-1] & {q_dat_width_g{selpri1[6]}});
           assign q_dat_l1[6] = ~(q_dat_l1a[6] & q_dat_l1b[6]);

           assign q_dat_l1a[7] = ~(din[14*aryoff:14*aryoff+aryoff-1] & {q_dat_width_g{selpri1_b[7]}});
           assign q_dat_l1b[7] = ~(din[15*aryoff:15*aryoff+aryoff-1] & {q_dat_width_g{selpri1[7]}});
           assign q_dat_l1[7] = ~(q_dat_l1a[7] & q_dat_l1b[7]);

           assign q_dat_l1_unused = 1'b0;

        end
   endgenerate

   // Level 2
   // 0123 4567 891011 12131415
   assign q_dat_l2a[0] = ~(q_dat_l1[0] & {q_dat_width_g{selpri2_b[0]}});
   assign q_dat_l2b[0] = ~(q_dat_l1[1] & {q_dat_width_g{selpri2[0]}});
   assign q_dat_l2[0] = ~(q_dat_l2a[0] & q_dat_l2b[0]);

   assign q_dat_l2a[1] = ~(q_dat_l1[2] & {q_dat_width_g{selpri2_b[1]}});
   assign q_dat_l2b[1] = ~(q_dat_l1[3] & {q_dat_width_g{selpri2[1]}});
   assign q_dat_l2[1] = ~(q_dat_l2a[1] & q_dat_l2b[1]);

   assign q_dat_l2a[2] = ~(q_dat_l1[4] & {q_dat_width_g{selpri2_b[2]}});
   assign q_dat_l2b[2] = ~(q_dat_l1[5] & {q_dat_width_g{selpri2[2]}});
   assign q_dat_l2[2] = ~(q_dat_l2a[2] & q_dat_l2b[2]);

   assign q_dat_l2a[3] = ~(q_dat_l1[6] & {q_dat_width_g{selpri2_b[3]}});
   assign q_dat_l2b[3] = ~(q_dat_l1[7] & {q_dat_width_g{selpri2[3]}});
   assign q_dat_l2[3] = ~(q_dat_l2a[3] & q_dat_l2b[3]);

   // Level 4
   // 01234567 89101112131415
   assign q_dat_l4a[0] = ~(q_dat_l2[0] & {q_dat_width_g{selpri4_b[0]}});
   assign q_dat_l4b[0] = ~(q_dat_l2[1] & {q_dat_width_g{selpri4[0]}});
   assign q_dat_l4[0] = ~(q_dat_l4a[0] & q_dat_l4b[0]);

   assign q_dat_l4a[1] = ~(q_dat_l2[2] & {q_dat_width_g{selpri4_b[1]}});
   assign q_dat_l4b[1] = ~(q_dat_l2[3] & {q_dat_width_g{selpri4[1]}});
   assign q_dat_l4[1] = ~(q_dat_l4a[1] & q_dat_l4b[1]);

   // Level 8
   // 0123456789101112131415
   assign q_dat_l8a = ~(q_dat_l4[0] & {q_dat_width_g{selpri8_b}});
   assign q_dat_l8b = ~(q_dat_l4[1] & {q_dat_width_g{selpri8}});
   assign q_dat_l8 = ~(q_dat_l8a & q_dat_l8b);

   assign dout = q_dat_l8 & {q_dat_width_g{selval8}};

endmodule // rv_prisel
