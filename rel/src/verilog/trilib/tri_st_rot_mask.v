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

//  Description:  XU Rotate - Mask Component
//
//*****************************************************************************

module tri_st_rot_mask(
   mb,
   me_b,
   zm,
   mb_gt_me,
   mask
);
   input [0:5]   mb;		// where the mask begins
   input [0:5]   me_b;		// where the mask ends
   input         zm;		// set mask to all zeroes. ... not a rot/sh op ... all bits are shifted out
   input         mb_gt_me;
   output [0:63] mask;		// mask shows which rotator bits to keep in the result.

   wire          mask_en_and;
   wire          mask_en_mb;
   wire          mask_en_me;
   wire [0:63]   mask0_b;
   wire [0:63]   mask1_b;
   wire [0:63]   mask2_b;
   wire [0:63]   mb_mask;
   wire [0:63]   me_mask;

   wire [0:2]    mb_msk45;
   wire [0:2]    mb_msk45_b;
   wire [0:2]    mb_msk23;
   wire [0:2]    mb_msk23_b;
   wire [0:2]    mb_msk01;
   wire [0:2]    mb_msk01_b;
   wire [0:14]   mb_msk25;
   wire [0:14]   mb_msk25_b;
   wire [0:2]    mb_msk01bb;
   wire [0:2]    mb_msk01bbb;
   wire [1:3]    me_msk01;
   wire [1:3]    me_msk01_b;
   wire [1:3]    me_msk23;
   wire [1:3]    me_msk23_b;
   wire [1:3]    me_msk45;
   wire [1:3]    me_msk45_b;
   wire [1:15]   me_msk25;
   wire [1:15]   me_msk25_b;
   wire [1:3]    me_msk01bbb;
   wire [1:3]    me_msk01bb;

   // -----------------------------------------------------------------------------------------
   // generate the MB mask
   // -----------------------------------------------------------------------------------------
   //        0123
   //       ------
   //  00 => 1111  (ge)
   //  01 => 0111
   //  10 => 0011
   //  11 => 0001

   // level 1 (4 bit results) ------------ <3 loads on input>

   assign mb_msk45[0] = (~(mb[4] | mb[5]));
   assign mb_msk45[1] = (~(mb[4]));
   assign mb_msk45[2] = (~(mb[4] & mb[5]));
   assign mb_msk23[0] = (~(mb[2] | mb[3]));
   assign mb_msk23[1] = (~(mb[2]));
   assign mb_msk23[2] = (~(mb[2] & mb[3]));
   assign mb_msk01[0] = (~(mb[0] | mb[1]));
   assign mb_msk01[1] = (~(mb[0]));
   assign mb_msk01[2] = (~(mb[0] & mb[1]));

   assign mb_msk45_b[0] = (~(mb_msk45[0]));
   assign mb_msk45_b[1] = (~(mb_msk45[1]));
   assign mb_msk45_b[2] = (~(mb_msk45[2]));
   assign mb_msk23_b[0] = (~(mb_msk23[0]));		// 7 loads on output
   assign mb_msk23_b[1] = (~(mb_msk23[1]));
   assign mb_msk23_b[2] = (~(mb_msk23[2]));
   assign mb_msk01_b[0] = (~(mb_msk01[0]));
   assign mb_msk01_b[1] = (~(mb_msk01[1]));
   assign mb_msk01_b[2] = (~(mb_msk01[2]));

   // level 2 (16 bit results) -------------

   assign mb_msk25[0] = (~(mb_msk23_b[0] | mb_msk45_b[0]));
   assign mb_msk25[1] = (~(mb_msk23_b[0] | mb_msk45_b[1]));
   assign mb_msk25[2] = (~(mb_msk23_b[0] | mb_msk45_b[2]));
   assign mb_msk25[3] = (~(mb_msk23_b[0]));
   assign mb_msk25[4] = (~(mb_msk23_b[0] & (mb_msk23_b[1] | mb_msk45_b[0])));
   assign mb_msk25[5] = (~(mb_msk23_b[0] & (mb_msk23_b[1] | mb_msk45_b[1])));
   assign mb_msk25[6] = (~(mb_msk23_b[0] & (mb_msk23_b[1] | mb_msk45_b[2])));
   assign mb_msk25[7] = (~(mb_msk23_b[1]));
   assign mb_msk25[8] = (~(mb_msk23_b[1] & (mb_msk23_b[2] | mb_msk45_b[0])));
   assign mb_msk25[9] = (~(mb_msk23_b[1] & (mb_msk23_b[2] | mb_msk45_b[1])));
   assign mb_msk25[10] = (~(mb_msk23_b[1] & (mb_msk23_b[2] | mb_msk45_b[2])));
   assign mb_msk25[11] = (~(mb_msk23_b[2]));
   assign mb_msk25[12] = (~(mb_msk23_b[2] & mb_msk45_b[0]));
   assign mb_msk25[13] = (~(mb_msk23_b[2] & mb_msk45_b[1]));
   assign mb_msk25[14] = (~(mb_msk23_b[2] & mb_msk45_b[2]));

   assign mb_msk01bb[0] = (~(mb_msk01_b[0]));
   assign mb_msk01bb[1] = (~(mb_msk01_b[1]));
   assign mb_msk01bb[2] = (~(mb_msk01_b[2]));

   assign mb_msk25_b[0] = (~(mb_msk25[0]));
   assign mb_msk25_b[1] = (~(mb_msk25[1]));
   assign mb_msk25_b[2] = (~(mb_msk25[2]));
   assign mb_msk25_b[3] = (~(mb_msk25[3]));
   assign mb_msk25_b[4] = (~(mb_msk25[4]));
   assign mb_msk25_b[5] = (~(mb_msk25[5]));
   assign mb_msk25_b[6] = (~(mb_msk25[6]));
   assign mb_msk25_b[7] = (~(mb_msk25[7]));
   assign mb_msk25_b[8] = (~(mb_msk25[8]));
   assign mb_msk25_b[9] = (~(mb_msk25[9]));
   assign mb_msk25_b[10] = (~(mb_msk25[10]));
   assign mb_msk25_b[11] = (~(mb_msk25[11]));
   assign mb_msk25_b[12] = (~(mb_msk25[12]));
   assign mb_msk25_b[13] = (~(mb_msk25[13]));
   assign mb_msk25_b[14] = (~(mb_msk25[14]));

   assign mb_msk01bbb[0] = (~(mb_msk01bb[0]));
   assign mb_msk01bbb[1] = (~(mb_msk01bb[1]));
   assign mb_msk01bbb[2] = (~(mb_msk01bb[2]));

   // level 3 -------------------------------------------------------
   assign mb_mask[0] = (~(mb_msk01bbb[0] | mb_msk25_b[0]));
   assign mb_mask[1] = (~(mb_msk01bbb[0] | mb_msk25_b[1]));
   assign mb_mask[2] = (~(mb_msk01bbb[0] | mb_msk25_b[2]));
   assign mb_mask[3] = (~(mb_msk01bbb[0] | mb_msk25_b[3]));
   assign mb_mask[4] = (~(mb_msk01bbb[0] | mb_msk25_b[4]));
   assign mb_mask[5] = (~(mb_msk01bbb[0] | mb_msk25_b[5]));
   assign mb_mask[6] = (~(mb_msk01bbb[0] | mb_msk25_b[6]));
   assign mb_mask[7] = (~(mb_msk01bbb[0] | mb_msk25_b[7]));
   assign mb_mask[8] = (~(mb_msk01bbb[0] | mb_msk25_b[8]));
   assign mb_mask[9] = (~(mb_msk01bbb[0] | mb_msk25_b[9]));
   assign mb_mask[10] = (~(mb_msk01bbb[0] | mb_msk25_b[10]));
   assign mb_mask[11] = (~(mb_msk01bbb[0] | mb_msk25_b[11]));
   assign mb_mask[12] = (~(mb_msk01bbb[0] | mb_msk25_b[12]));
   assign mb_mask[13] = (~(mb_msk01bbb[0] | mb_msk25_b[13]));
   assign mb_mask[14] = (~(mb_msk01bbb[0] | mb_msk25_b[14]));
   assign mb_mask[15] = (~(mb_msk01bbb[0]));
   assign mb_mask[16] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[0])));
   assign mb_mask[17] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[1])));
   assign mb_mask[18] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[2])));
   assign mb_mask[19] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[3])));
   assign mb_mask[20] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[4])));
   assign mb_mask[21] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[5])));
   assign mb_mask[22] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[6])));
   assign mb_mask[23] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[7])));
   assign mb_mask[24] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[8])));
   assign mb_mask[25] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[9])));
   assign mb_mask[26] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[10])));
   assign mb_mask[27] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[11])));
   assign mb_mask[28] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[12])));
   assign mb_mask[29] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[13])));
   assign mb_mask[30] = (~(mb_msk01bbb[0] & (mb_msk01bbb[1] | mb_msk25_b[14])));
   assign mb_mask[31] = (~(mb_msk01bbb[1]));
   assign mb_mask[32] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[0])));
   assign mb_mask[33] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[1])));
   assign mb_mask[34] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[2])));
   assign mb_mask[35] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[3])));
   assign mb_mask[36] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[4])));
   assign mb_mask[37] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[5])));
   assign mb_mask[38] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[6])));
   assign mb_mask[39] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[7])));
   assign mb_mask[40] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[8])));
   assign mb_mask[41] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[9])));
   assign mb_mask[42] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[10])));
   assign mb_mask[43] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[11])));
   assign mb_mask[44] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[12])));
   assign mb_mask[45] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[13])));
   assign mb_mask[46] = (~(mb_msk01bbb[1] & (mb_msk01bbb[2] | mb_msk25_b[14])));
   assign mb_mask[47] = (~(mb_msk01bbb[2]));
   assign mb_mask[48] = (~(mb_msk01bbb[2] & mb_msk25_b[0]));
   assign mb_mask[49] = (~(mb_msk01bbb[2] & mb_msk25_b[1]));
   assign mb_mask[50] = (~(mb_msk01bbb[2] & mb_msk25_b[2]));
   assign mb_mask[51] = (~(mb_msk01bbb[2] & mb_msk25_b[3]));
   assign mb_mask[52] = (~(mb_msk01bbb[2] & mb_msk25_b[4]));
   assign mb_mask[53] = (~(mb_msk01bbb[2] & mb_msk25_b[5]));
   assign mb_mask[54] = (~(mb_msk01bbb[2] & mb_msk25_b[6]));
   assign mb_mask[55] = (~(mb_msk01bbb[2] & mb_msk25_b[7]));
   assign mb_mask[56] = (~(mb_msk01bbb[2] & mb_msk25_b[8]));
   assign mb_mask[57] = (~(mb_msk01bbb[2] & mb_msk25_b[9]));
   assign mb_mask[58] = (~(mb_msk01bbb[2] & mb_msk25_b[10]));
   assign mb_mask[59] = (~(mb_msk01bbb[2] & mb_msk25_b[11]));
   assign mb_mask[60] = (~(mb_msk01bbb[2] & mb_msk25_b[12]));
   assign mb_mask[61] = (~(mb_msk01bbb[2] & mb_msk25_b[13]));
   assign mb_mask[62] = (~(mb_msk01bbb[2] & mb_msk25_b[14]));
   assign mb_mask[63] = 1;

   // -----------------------------------------------------------------------------------------
   // generate the ME mask
   // -----------------------------------------------------------------------------------------

   // level 1 (4 bit results) ------------ <3 loads on input>

   assign me_msk45[1] = (~(me_b[4] & me_b[5]));
   assign me_msk45[2] = (~(me_b[4]));
   assign me_msk45[3] = (~(me_b[4] | me_b[5]));

   assign me_msk23[1] = (~(me_b[2] & me_b[3]));
   assign me_msk23[2] = (~(me_b[2]));
   assign me_msk23[3] = (~(me_b[2] | me_b[3]));

   assign me_msk01[1] = (~(me_b[0] & me_b[1]));
   assign me_msk01[2] = (~(me_b[0]));
   assign me_msk01[3] = (~(me_b[0] | me_b[1]));

   assign me_msk45_b[1] = (~(me_msk45[1]));
   assign me_msk45_b[2] = (~(me_msk45[2]));
   assign me_msk45_b[3] = (~(me_msk45[3]));
   assign me_msk23_b[1] = (~(me_msk23[1]));		// 7 loads on output
   assign me_msk23_b[2] = (~(me_msk23[2]));
   assign me_msk23_b[3] = (~(me_msk23[3]));
   assign me_msk01_b[1] = (~(me_msk01[1]));
   assign me_msk01_b[2] = (~(me_msk01[2]));
   assign me_msk01_b[3] = (~(me_msk01[3]));

   // level 2 (16 bit results) -------------

   assign me_msk25[1] = (~(me_msk23_b[1] & me_msk45_b[1]));		// amt >=  1    4:15 + 1:3
   assign me_msk25[2] = (~(me_msk23_b[1] & me_msk45_b[2]));		// amt >=  2    4:15 + 2:3
   assign me_msk25[3] = (~(me_msk23_b[1] & me_msk45_b[3]));		// amt >=  3    4:15 + 3:3
   assign me_msk25[4] = (~(me_msk23_b[1]));		// amt >=  4    4:15
   assign me_msk25[5] = (~(me_msk23_b[2] & (me_msk23_b[1] | me_msk45_b[1])));		// amt >=  5    8:15 + (4:15 * 1:3)
   assign me_msk25[6] = (~(me_msk23_b[2] & (me_msk23_b[1] | me_msk45_b[2])));		// amt >=  6    8:15 + (4:15 * 2:3)
   assign me_msk25[7] = (~(me_msk23_b[2] & (me_msk23_b[1] | me_msk45_b[3])));		// amt >=  7    8:15 + (4:15 * 3:3)
   assign me_msk25[8] = (~(me_msk23_b[2]));		// amt >=  8    8:15
   assign me_msk25[9] = (~(me_msk23_b[3] & (me_msk23_b[2] | me_msk45_b[1])));		// amt >=  9   12:15 + (8:15 * 1:3)
   assign me_msk25[10] = (~(me_msk23_b[3] & (me_msk23_b[2] | me_msk45_b[2])));		// amt >= 10   12:15 + (8:15 * 2:3)
   assign me_msk25[11] = (~(me_msk23_b[3] & (me_msk23_b[2] | me_msk45_b[3])));		// amt >= 11   12:15 + (8:15 * 3:3)
   assign me_msk25[12] = (~(me_msk23_b[3]));		// amt >= 12   12:15
   assign me_msk25[13] = (~(me_msk23_b[3] | me_msk45_b[1]));		// amt >= 13   12:15 & 1:3
   assign me_msk25[14] = (~(me_msk23_b[3] | me_msk45_b[2]));		// amt >= 14   12:15 & 2:3
   assign me_msk25[15] = (~(me_msk23_b[3] | me_msk45_b[3]));		// amt >= 15   12:15 & 3:3

   assign me_msk01bb[1] = (~(me_msk01_b[1]));
   assign me_msk01bb[2] = (~(me_msk01_b[2]));
   assign me_msk01bb[3] = (~(me_msk01_b[3]));

   assign me_msk25_b[1] = (~(me_msk25[1]));
   assign me_msk25_b[2] = (~(me_msk25[2]));
   assign me_msk25_b[3] = (~(me_msk25[3]));
   assign me_msk25_b[4] = (~(me_msk25[4]));
   assign me_msk25_b[5] = (~(me_msk25[5]));
   assign me_msk25_b[6] = (~(me_msk25[6]));
   assign me_msk25_b[7] = (~(me_msk25[7]));
   assign me_msk25_b[8] = (~(me_msk25[8]));
   assign me_msk25_b[9] = (~(me_msk25[9]));
   assign me_msk25_b[10] = (~(me_msk25[10]));
   assign me_msk25_b[11] = (~(me_msk25[11]));
   assign me_msk25_b[12] = (~(me_msk25[12]));
   assign me_msk25_b[13] = (~(me_msk25[13]));
   assign me_msk25_b[14] = (~(me_msk25[14]));
   assign me_msk25_b[15] = (~(me_msk25[15]));

   assign me_msk01bbb[1] = (~(me_msk01bb[1]));
   assign me_msk01bbb[2] = (~(me_msk01bb[2]));
   assign me_msk01bbb[3] = (~(me_msk01bb[3]));

   // level 3 (16 bit results) -------------

   assign me_mask[0] = 1;
   assign me_mask[1] = (~(me_msk01bbb[1] & me_msk25_b[1]));
   assign me_mask[2] = (~(me_msk01bbb[1] & me_msk25_b[2]));
   assign me_mask[3] = (~(me_msk01bbb[1] & me_msk25_b[3]));
   assign me_mask[4] = (~(me_msk01bbb[1] & me_msk25_b[4]));
   assign me_mask[5] = (~(me_msk01bbb[1] & me_msk25_b[5]));
   assign me_mask[6] = (~(me_msk01bbb[1] & me_msk25_b[6]));
   assign me_mask[7] = (~(me_msk01bbb[1] & me_msk25_b[7]));
   assign me_mask[8] = (~(me_msk01bbb[1] & me_msk25_b[8]));
   assign me_mask[9] = (~(me_msk01bbb[1] & me_msk25_b[9]));
   assign me_mask[10] = (~(me_msk01bbb[1] & me_msk25_b[10]));
   assign me_mask[11] = (~(me_msk01bbb[1] & me_msk25_b[11]));
   assign me_mask[12] = (~(me_msk01bbb[1] & me_msk25_b[12]));
   assign me_mask[13] = (~(me_msk01bbb[1] & me_msk25_b[13]));
   assign me_mask[14] = (~(me_msk01bbb[1] & me_msk25_b[14]));
   assign me_mask[15] = (~(me_msk01bbb[1] & me_msk25_b[15]));
   assign me_mask[16] = (~(me_msk01bbb[1]));
   assign me_mask[17] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[1])));
   assign me_mask[18] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[2])));
   assign me_mask[19] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[3])));
   assign me_mask[20] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[4])));
   assign me_mask[21] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[5])));
   assign me_mask[22] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[6])));
   assign me_mask[23] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[7])));
   assign me_mask[24] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[8])));
   assign me_mask[25] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[9])));
   assign me_mask[26] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[10])));
   assign me_mask[27] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[11])));
   assign me_mask[28] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[12])));
   assign me_mask[29] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[13])));
   assign me_mask[30] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[14])));
   assign me_mask[31] = (~(me_msk01bbb[2] & (me_msk01bbb[1] | me_msk25_b[15])));
   assign me_mask[32] = (~(me_msk01bbb[2]));
   assign me_mask[33] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[1])));
   assign me_mask[34] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[2])));
   assign me_mask[35] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[3])));
   assign me_mask[36] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[4])));
   assign me_mask[37] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[5])));
   assign me_mask[38] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[6])));
   assign me_mask[39] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[7])));
   assign me_mask[40] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[8])));
   assign me_mask[41] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[9])));
   assign me_mask[42] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[10])));
   assign me_mask[43] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[11])));
   assign me_mask[44] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[12])));
   assign me_mask[45] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[13])));
   assign me_mask[46] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[14])));
   assign me_mask[47] = (~(me_msk01bbb[3] & (me_msk01bbb[2] | me_msk25_b[15])));
   assign me_mask[48] = (~(me_msk01bbb[3]));
   assign me_mask[49] = (~(me_msk01bbb[3] | me_msk25_b[1]));
   assign me_mask[50] = (~(me_msk01bbb[3] | me_msk25_b[2]));
   assign me_mask[51] = (~(me_msk01bbb[3] | me_msk25_b[3]));
   assign me_mask[52] = (~(me_msk01bbb[3] | me_msk25_b[4]));
   assign me_mask[53] = (~(me_msk01bbb[3] | me_msk25_b[5]));
   assign me_mask[54] = (~(me_msk01bbb[3] | me_msk25_b[6]));
   assign me_mask[55] = (~(me_msk01bbb[3] | me_msk25_b[7]));
   assign me_mask[56] = (~(me_msk01bbb[3] | me_msk25_b[8]));
   assign me_mask[57] = (~(me_msk01bbb[3] | me_msk25_b[9]));
   assign me_mask[58] = (~(me_msk01bbb[3] | me_msk25_b[10]));
   assign me_mask[59] = (~(me_msk01bbb[3] | me_msk25_b[11]));
   assign me_mask[60] = (~(me_msk01bbb[3] | me_msk25_b[12]));
   assign me_mask[61] = (~(me_msk01bbb[3] | me_msk25_b[13]));
   assign me_mask[62] = (~(me_msk01bbb[3] | me_msk25_b[14]));
   assign me_mask[63] = (~(me_msk01bbb[3] | me_msk25_b[15]));

   // ------------------------------------------------------------------------------------------
   // Generally the mask starts at bit MB[] and ends at bit ME[] ... (MB[] and ME[])
   // For non-rotate/shift operations the mask is forced to zero by the ZM control.
   // There are 3 rotate-word operations where MB could be greater than ME.
   // in that case the mask is speced to be  (MB[] or ME[]).
   // For those cases, the mask always comes from the instruction bits, is always word mode,
   // and the MB>ME compare can be done during the instruction decode cycle.
   // -------------------------------------------------------------------------------------------

   assign mask_en_and = (~mb_gt_me) & (~zm);		// could restrict this to only rotates if shifts included below
   assign mask_en_mb = mb_gt_me & (~zm);		// could alternatively include shift right
   assign mask_en_me = mb_gt_me & (~zm);		// could alternatively include shift left

   assign mask0_b[0:63] = (~(mb_mask[0:63] & me_mask[0:63] & {64{mask_en_and}}));
   assign mask1_b[0:63] = (~(mb_mask[0:63] & {64{mask_en_mb}}));
   assign mask2_b[0:63] = (~(me_mask[0:63] & {64{mask_en_me}}));

   assign mask[0:63] = (~(mask0_b[0:63] & mask1_b[0:63] & mask2_b[0:63]));


endmodule
