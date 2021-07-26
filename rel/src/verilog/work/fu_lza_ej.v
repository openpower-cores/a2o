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

   `include "tri_a2o.vh"


module fu_lza_ej(
   effsub,
   sum,
   car,
   lzo_b,
   edge_t
);
   input          effsub;
   input [0:162]  sum;
   input [53:162] car;
   input [0:162]  lzo_b;
   output [0:162] edge_t;

   //  generic 3 bit edge ::
   //  P G !Z
   //  P Z !G
   // !P G !G
   // !P Z !Z


   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;

   wire [0:52]    x0;
   wire [0:52]    x1;
   wire [0:52]    x2;
   wire [0:52]    x1_b;
   wire [0:52]    ej_b;
   wire [53:162]  g_b;
   wire [53:162]  z;
   wire [53:162]  p;
   wire [53:162]  g;
   wire [53:162]  z_b;
   wire [53:162]  p_b;
   wire           sum_52_b;
   wire           lzo_54;
   wire [55:162]  gz;
   wire [55:162]  zg;
   wire [55:162]  gg;
   wire [55:162]  zz;
   wire [53:162]  e0_b;
   wire [53:162]  e1_b;
   wire [54:54]   e2_b;
   wire           unused;

   // these are different heights for different bits ... place them as seperate columns
   // for 0 :52
   // for 53
   // for 54
   // for 55
   // for 56:162

   assign unused = g[54] | z_b[53] | z_b[162] | p_b[161] | p_b[162];

   //-------------------------------------------
   // (0:52) only one data input
   //-------------------------------------------

   assign x0[0:52] = {tidn, effsub, sum[0:50]};		// just a rename
   assign x1[0:52] = {effsub, sum[0:51]};		// just a rename
   assign x2[0:52] = sum[0:52];		// just a rename

   assign x1_b[0:52] = (~x1[0:52]);
   assign ej_b[0:52] = (~(x1_b[0:52] & (x0[0:52] | x2[0:52])));
   assign edge_t[0:52] = (~(ej_b[0:52] & lzo_b[0:52]));

   //-----------------------------------------------------------------
   // (53) psuedo bit
   //-----------------------------------------------------------------

   assign g_b[53] = (~(sum[53] & car[53]));
   assign z[53] = (~(sum[53] | car[53]));
   assign p[53] = (sum[53] ^ car[53]);

   assign g[53] = (~(g_b[53]));
   assign z_b[53] = (~(z[53]));		//UNUSED
   assign p_b[53] = (~(p[53]));
   assign sum_52_b = (~(sum[52]));

   assign e0_b[53] = (~(sum[51] & sum_52_b));
   assign e1_b[53] = (~(sum_52_b & g[53]));
   assign edge_t[53] = (~(lzo_b[53] & e0_b[53] & e1_b[53]));		//output

   //-----------------------------------------------------------------
   // (54) pseudo bit + 1
   //-----------------------------------------------------------------

   assign g_b[54] = (~(sum[54] & car[54]));
   assign z[54] = (~(sum[54] | car[54]));
   assign p[54] = (sum[54] ^ car[54]);

   assign g[54] = (~(g_b[54]));		//UNUSED
   assign z_b[54] = (~(z[54]));
   assign p_b[54] = (~(p[54]));

   assign lzo_54 = (~lzo_b[54]);

   assign e0_b[54] = (~(sum_52_b & p[53] & z_b[54]));		//really is p54 (demotes to z54)
   assign e1_b[54] = (~(sum[52] & p[53] & g_b[54]));		//really is p54 (demotes to z54)
   assign e2_b[54] = (~((sum[52] & z[53]) | lzo_54));
   assign edge_t[54] = (~(e0_b[54] & e1_b[54] & e2_b[54]));		//output

   //-----------------------------------------------------------------
   // (55) pseudo bit + 2
   //-----------------------------------------------------------------

   assign g_b[55] = (~(sum[55] & car[55]));
   assign z[55] = (~(sum[55] | car[55]));
   assign p[55] = (sum[55] ^ car[55]);

   assign g[55] = (~(g_b[55]));
   assign z_b[55] = (~(z[55]));
   assign p_b[55] = (~(p[55]));

   assign gz[55] = (~(g_b[54] | z[55]));
   assign zg[55] = (~(z_b[54] | g[55]));
   assign gg[55] = (~(g_b[54] | g[55]));
   assign zz[55] = (~(z_b[54] | z[55]));

   assign e1_b[55] = (~(p_b[53] & (gz[55] | zg[55])));		// P is flipped for psuedo bit
   assign e0_b[55] = (~(p[53] & (gg[55] | zz[55])));		// P is flipped for psuedo bit
   assign edge_t[55] = (~(e0_b[55] & e1_b[55] & lzo_b[55]));		//output

   //-----------------------------------------------------------------
   // (56:162) normal 2 input edge_t
   //-----------------------------------------------------------------

   assign g_b[56:162] = (~(sum[56:162] & car[56:162]));
   assign z[56:162] = (~(sum[56:162] | car[56:162]));
   assign p[56:162] = (sum[56:162] ^ car[56:162]);

   assign g[56:162] = (~(g_b[56:162]));
   assign z_b[56:162] = (~(z[56:162]));		//162 unused
   assign p_b[56:162] = (~(p[56:162]));		//161,162 unused

   assign gz[56:162] = (~(g_b[55:161] | z[56:162]));
   assign zg[56:162] = (~(z_b[55:161] | g[56:162]));
   assign gg[56:162] = (~(g_b[55:161] | g[56:162]));
   assign zz[56:162] = (~(z_b[55:161] | z[56:162]));

   assign e1_b[56:162] = (~(p[54:160] & (gz[56:162] | zg[56:162])));
   assign e0_b[56:162] = (~(p_b[54:160] & (gg[56:162] | zz[56:162])));
   assign edge_t[56:162] = (~(e0_b[56:162] & e1_b[56:162] & lzo_b[56:162]));		//output

endmodule
