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

//  Description:  XU Rotate - Rotate Component
//
//*****************************************************************************

module tri_st_rot_rol64(
   word,
   right,
   amt,
   data_i,
   res_rot
);
   input [0:1]   word;		// PPC word mode rotate <2 copies>
   input [0:2]   right;		// emulate a shift right with a rotate left <2 copies>
   input [0:5]   amt;		// shift amout [0:63]
   input [0:63]  data_i;		// data to be shifted
   output [0:63] res_rot;		// mask shows which rotator bits to keep in the result.

   wire [0:2]    right_b;
   wire [0:5]    amt_b;
   wire [0:1]    word_b;
   wire [0:31]   word_bus;
   wire [0:31]   word_bus_b;
   wire [0:31]   data_i0_adj_b;
   wire [0:63]   data_i_adj;
   wire [0:63]   data_i1_adj_b;

   wire [0:63]   rolx16_0;
   wire [0:63]   rolx16_1;
   wire [0:63]   rolx16_2;
   wire [0:63]   rolx16_3;
   wire [0:63]   rolx04_0;
   wire [0:63]   rolx04_1;
   wire [0:63]   rolx04_2;
   wire [0:63]   rolx04_3;
   wire [0:63]   rolx01_0;
   wire [0:63]   rolx01_1;
   wire [0:63]   rolx01_2;
   wire [0:63]   rolx01_3;
   wire [0:63]   rolx01_4;
   wire [0:63]   shd16;
   wire [0:63]   shd16_0_b;
   wire [0:63]   shd16_1_b;
   wire [0:63]   shd04;
   wire [0:63]   shd04_0_b;
   wire [0:63]   shd04_1_b;
   wire [0:63]   shd01_0_b;
   wire [0:63]   shd01_1_b;
   wire [0:63]   shd01_2_b;
   wire [0:3]    x16_lft_b;
   wire [0:3]    x16_rgt_b;
   wire [0:3]    lftx16;
   wire [0:3]    x04_lft_b;
   wire [0:3]    x04_rgt_b;
   wire [0:3]    lftx04;
   wire [0:3]    x01_lft_b;
   wire [0:3]    x01_rgt_b;
   wire [0:4]    lftx01;

   wire [0:4]    lftx01_inv;
   wire [0:4]    lftx01_buf0;
   wire [0:4]    lftx01_buf1;
   wire [0:3]    lftx04_inv;
   wire [0:3]    lftx04_buf0;
   wire [0:3]    lftx04_buf1;
   wire [0:3]    lftx16_inv;
   wire [0:3]    lftx16_buf0;
   wire [0:3]    lftx16_buf1;
   wire [0:63]   lftx16_0_bus;
   wire [0:63]   lftx16_1_bus;
   wire [0:63]   lftx16_2_bus;
   wire [0:63]   lftx16_3_bus;
   wire [0:63]   lftx04_0_bus;
   wire [0:63]   lftx04_1_bus;
   wire [0:63]   lftx04_2_bus;
   wire [0:63]   lftx04_3_bus;
   wire [0:63]   lftx01_0_bus;
   wire [0:63]   lftx01_1_bus;
   wire [0:63]   lftx01_2_bus;
   wire [0:63]   lftx01_3_bus;
   wire [0:63]   lftx01_4_bus;
   // -------------------------------------------------------------
   // how the ppc emulates a rot32 using rot64 hardware.
   // this makes the wrapping corect for the low order 32 bits.
   // upper 32 result bits a garbage
   //--------------------------------------------------------------

   assign word_b[0:1] = (~word[0:1]);

   assign word_bus_b[0:15]  = {16{word_b[0]}};
   assign word_bus_b[16:31] = {16{word_b[1]}};
   assign word_bus[0:15]    = {16{word[0]}};
   assign word_bus[16:31]   = {16{word[1]}};

   assign data_i0_adj_b[0:31] = (~(data_i[0:31] & word_bus_b[0:31]));
   assign data_i1_adj_b[0:31] = (~(data_i[32:63] & word_bus[0:31]));
   assign data_i_adj[0:31] = (~(data_i0_adj_b[0:31] & data_i1_adj_b[0:31]));

   assign data_i1_adj_b[32:63] = (~(data_i[32:63]));
   assign data_i_adj[32:63] = (~(data_i1_adj_b[32:63]));

   //---------------------------------------------------------------
   // decoder without the adder
   //---------------------------------------------------------------
   //rotate right by [n] == rotate_left by width -[n] == !n + 1

   assign right_b[0:2] = (~right[0:2]);
   assign amt_b[0:5] = (~amt[0:5]);

   assign x16_lft_b[0] = (~(right_b[0] & amt_b[0] & amt_b[1]));
   assign x16_lft_b[1] = (~(right_b[0] & amt_b[0] & amt[1]));
   assign x16_lft_b[2] = (~(right_b[0] & amt[0] & amt_b[1]));
   assign x16_lft_b[3] = (~(right_b[0] & amt[0] & amt[1]));

   assign x16_rgt_b[0] = (~(right[0] & amt_b[0] & amt_b[1]));
   assign x16_rgt_b[1] = (~(right[0] & amt_b[0] & amt[1]));
   assign x16_rgt_b[2] = (~(right[0] & amt[0] & amt_b[1]));
   assign x16_rgt_b[3] = (~(right[0] & amt[0] & amt[1]));

   assign lftx16[0] = (~(x16_lft_b[0] & x16_rgt_b[3]));
   assign lftx16[1] = (~(x16_lft_b[1] & x16_rgt_b[2]));
   assign lftx16[2] = (~(x16_lft_b[2] & x16_rgt_b[1]));
   assign lftx16[3] = (~(x16_lft_b[3] & x16_rgt_b[0]));

   assign x04_lft_b[0] = (~(right_b[1] & amt_b[2] & amt_b[3]));
   assign x04_lft_b[1] = (~(right_b[1] & amt_b[2] & amt[3]));
   assign x04_lft_b[2] = (~(right_b[1] & amt[2] & amt_b[3]));
   assign x04_lft_b[3] = (~(right_b[1] & amt[2] & amt[3]));

   assign x04_rgt_b[0] = (~(right[1] & amt_b[2] & amt_b[3]));
   assign x04_rgt_b[1] = (~(right[1] & amt_b[2] & amt[3]));
   assign x04_rgt_b[2] = (~(right[1] & amt[2] & amt_b[3]));
   assign x04_rgt_b[3] = (~(right[1] & amt[2] & amt[3]));

   assign lftx04[0] = (~(x04_lft_b[0] & x04_rgt_b[3]));
   assign lftx04[1] = (~(x04_lft_b[1] & x04_rgt_b[2]));
   assign lftx04[2] = (~(x04_lft_b[2] & x04_rgt_b[1]));
   assign lftx04[3] = (~(x04_lft_b[3] & x04_rgt_b[0]));

   assign x01_lft_b[0] = (~(right_b[2] & amt_b[4] & amt_b[5]));
   assign x01_lft_b[1] = (~(right_b[2] & amt_b[4] & amt[5]));
   assign x01_lft_b[2] = (~(right_b[2] & amt[4] & amt_b[5]));
   assign x01_lft_b[3] = (~(right_b[2] & amt[4] & amt[5]));

   assign x01_rgt_b[0] = (~(right[2] & amt_b[4] & amt_b[5]));
   assign x01_rgt_b[1] = (~(right[2] & amt_b[4] & amt[5]));
   assign x01_rgt_b[2] = (~(right[2] & amt[4] & amt_b[5]));
   assign x01_rgt_b[3] = (~(right[2] & amt[4] & amt[5]));

   assign lftx01[0] = (~(x01_lft_b[0]));		// the shift is like the +1
   assign lftx01[1] = (~(x01_lft_b[1] & x01_rgt_b[3]));
   assign lftx01[2] = (~(x01_lft_b[2] & x01_rgt_b[2]));
   assign lftx01[3] = (~(x01_lft_b[3] & x01_rgt_b[1]));
   assign lftx01[4] = (~(x01_rgt_b[0]));

   assign lftx16_inv[0:3] = (~(lftx16[0:3]));
   assign lftx16_buf0[0:3] = (~(lftx16_inv[0:3]));
   assign lftx16_buf1[0:3] = (~(lftx16_inv[0:3]));

   assign lftx04_inv[0:3] = (~(lftx04[0:3]));
   assign lftx04_buf0[0:3] = (~(lftx04_inv[0:3]));
   assign lftx04_buf1[0:3] = (~(lftx04_inv[0:3]));

   assign lftx01_inv[0:4] = (~(lftx01[0:4]));
   assign lftx01_buf0[0:4] = (~(lftx01_inv[0:4]));
   assign lftx01_buf1[0:4] = (~(lftx01_inv[0:4]));

   assign lftx16_0_bus[0:31]  = {32{lftx16_buf0[0]}};
   assign lftx16_0_bus[32:63] = {32{lftx16_buf1[0]}};
   assign lftx16_1_bus[0:31]  = {32{lftx16_buf0[1]}};
   assign lftx16_1_bus[32:63] = {32{lftx16_buf1[1]}};
   assign lftx16_2_bus[0:31]  = {32{lftx16_buf0[2]}};
   assign lftx16_2_bus[32:63] = {32{lftx16_buf1[2]}};
   assign lftx16_3_bus[0:31]  = {32{lftx16_buf0[3]}};
   assign lftx16_3_bus[32:63] = {32{lftx16_buf1[3]}};

   assign lftx04_0_bus[0:31]  = {32{lftx04_buf0[0]}};
   assign lftx04_0_bus[32:63] = {32{lftx04_buf1[0]}};
   assign lftx04_1_bus[0:31]  = {32{lftx04_buf0[1]}};
   assign lftx04_1_bus[32:63] = {32{lftx04_buf1[1]}};
   assign lftx04_2_bus[0:31]  = {32{lftx04_buf0[2]}};
   assign lftx04_2_bus[32:63] = {32{lftx04_buf1[2]}};
   assign lftx04_3_bus[0:31]  = {32{lftx04_buf0[3]}};
   assign lftx04_3_bus[32:63] = {32{lftx04_buf1[3]}};

   assign lftx01_0_bus[0:31]  = {32{lftx01_buf0[0]}};
   assign lftx01_0_bus[32:63] = {32{lftx01_buf1[0]}};
   assign lftx01_1_bus[0:31]  = {32{lftx01_buf0[1]}};
   assign lftx01_1_bus[32:63] = {32{lftx01_buf1[1]}};
   assign lftx01_2_bus[0:31]  = {32{lftx01_buf0[2]}};
   assign lftx01_2_bus[32:63] = {32{lftx01_buf1[2]}};
   assign lftx01_3_bus[0:31]  = {32{lftx01_buf0[3]}};
   assign lftx01_3_bus[32:63] = {32{lftx01_buf1[3]}};
   assign lftx01_4_bus[0:31]  = {32{lftx01_buf0[4]}};
   assign lftx01_4_bus[32:63] = {32{lftx01_buf1[4]}};

   //---------------------------------------------------------------
   // the shifter
   //---------------------------------------------------------------

   assign rolx16_0[0:63] = data_i_adj[0:63];
   assign rolx16_1[0:63] = {data_i_adj[16:63], data_i_adj[0:15]};
   assign rolx16_2[0:63] = {data_i_adj[32:63], data_i_adj[0:31]};
   assign rolx16_3[0:63] = {data_i_adj[48:63], data_i_adj[0:47]};

   assign shd16_0_b[0:63] = (~((lftx16_0_bus[0:63] & rolx16_0[0:63]) | (lftx16_1_bus[0:63] & rolx16_1[0:63])));
   assign shd16_1_b[0:63] = (~((lftx16_2_bus[0:63] & rolx16_2[0:63]) | (lftx16_3_bus[0:63] & rolx16_3[0:63])));
   assign shd16[0:63] = (~(shd16_0_b[0:63] & shd16_1_b[0:63]));

   assign rolx04_0[0:63] = shd16[0:63];
   assign rolx04_1[0:63] = {shd16[4:63], shd16[0:3]};
   assign rolx04_2[0:63] = {shd16[8:63], shd16[0:7]};
   assign rolx04_3[0:63] = {shd16[12:63], shd16[0:11]};

   assign shd04_0_b[0:63] = (~((lftx04_0_bus[0:63] & rolx04_0[0:63]) | (lftx04_1_bus[0:63] & rolx04_1[0:63])));
   assign shd04_1_b[0:63] = (~((lftx04_2_bus[0:63] & rolx04_2[0:63]) | (lftx04_3_bus[0:63] & rolx04_3[0:63])));
   assign shd04[0:63] = (~(shd04_0_b[0:63] & shd04_1_b[0:63]));

   assign rolx01_0[0:63] = shd04[0:63];
   assign rolx01_1[0:63] = {shd04[1:63], shd04[0]};
   assign rolx01_2[0:63] = {shd04[2:63], shd04[0:1]};
   assign rolx01_3[0:63] = {shd04[3:63], shd04[0:2]};
   assign rolx01_4[0:63] = {shd04[4:63], shd04[0:3]};

   assign shd01_0_b[0:63] = (~((lftx01_0_bus[0:63] & rolx01_0[0:63]) | (lftx01_1_bus[0:63] & rolx01_1[0:63])));
   assign shd01_1_b[0:63] = (~((lftx01_2_bus[0:63] & rolx01_2[0:63]) | (lftx01_3_bus[0:63] & rolx01_3[0:63])));
   assign shd01_2_b[0:63] = (~(lftx01_4_bus[0:63] & rolx01_4[0:63]));
   assign res_rot[0:63] = (~(shd01_0_b[0:63] & shd01_1_b[0:63] & shd01_2_b[0:63]));

endmodule
