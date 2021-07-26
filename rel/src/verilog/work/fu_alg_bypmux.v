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

module fu_alg_bypmux(
   ex3_byp_sel_byp_neg,
   ex3_byp_sel_byp_pos,
   ex3_byp_sel_neg,
   ex3_byp_sel_pos,
   ex3_prd_sel_neg_hi,
   ex3_prd_sel_neg_lo,
   ex3_prd_sel_neg_lohi,
   ex3_prd_sel_pos_hi,
   ex3_prd_sel_pos_lo,
   ex3_prd_sel_pos_lohi,
   ex3_sh_lvl3,
   f_fmt_ex3_pass_frac,
   f_alg_ex3_res
);
   //--------- BYPASS CONTROLS -----------------
   input          ex3_byp_sel_byp_neg;
   input          ex3_byp_sel_byp_pos;
   input          ex3_byp_sel_neg;
   input          ex3_byp_sel_pos;
   input          ex3_prd_sel_neg_hi;
   input          ex3_prd_sel_neg_lo;
   input          ex3_prd_sel_neg_lohi;
   input          ex3_prd_sel_pos_hi;
   input          ex3_prd_sel_pos_lo;
   input          ex3_prd_sel_pos_lohi;

   //--------- BYPASS DATA -----------------
   input [0:162]  ex3_sh_lvl3;
   input [0:52]   f_fmt_ex3_pass_frac;

   //-------- BYPASS OUTPUT ---------------
   output [0:162] f_alg_ex3_res;

   // ENTITY


   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;

   wire [0:162]   m0_b;
   wire [0:162]   m1_b;
   wire [0:162]   ex3_sh_lvl3_b;
   wire [0:52]    f_fmt_ex3_pass_frac_b;


   //#-------------------------------------------------
   //# bypass mux & operand flip
   //#-------------------------------------------------
   //# integer operation positions
   //#         32          32
   //#       99:130    131:162

   assign ex3_sh_lvl3_b[0:162] = (~(ex3_sh_lvl3[0:162]));
   assign f_fmt_ex3_pass_frac_b[0:52] = (~(f_fmt_ex3_pass_frac[0:52]));

   //--------------------------------------------------------------

   assign m0_b[0:52] = (~(({53{ex3_byp_sel_pos}} & ex3_sh_lvl3[0:52]) |
                          ({53{ex3_byp_sel_neg}} & ex3_sh_lvl3_b[0:52])));

   assign m1_b[0:52] = (~(({53{ex3_byp_sel_byp_pos}} & f_fmt_ex3_pass_frac[0:52]) |
                          ({53{ex3_byp_sel_byp_neg}} & f_fmt_ex3_pass_frac_b[0:52])));
   //---------------------------------------------------------------
   //---------------------------------------------------------------

   assign m0_b[53:98] = (~({46{ex3_prd_sel_pos_hi}} & ex3_sh_lvl3[53:98]));

   assign m1_b[53:98] = (~({46{ex3_prd_sel_neg_hi}} & ex3_sh_lvl3_b[53:98]));

   //---------------------------------------------------------------

   assign m0_b[99:130] = (~({32{ex3_prd_sel_pos_lohi}} & ex3_sh_lvl3[99:130]));

   assign m1_b[99:130] = (~({32{ex3_prd_sel_neg_lohi}} & ex3_sh_lvl3_b[99:130]));

   //---------------------------------------------------------------

   assign m0_b[131:162] = (~({32{ex3_prd_sel_pos_lo}} & ex3_sh_lvl3[131:162]));

   assign m1_b[131:162] = (~({32{ex3_prd_sel_neg_lo}} & ex3_sh_lvl3_b[131:162]));

   //---------------------------------------------------------------

   assign f_alg_ex3_res[0:162] = (~(m0_b[0:162] & m1_b[0:162]));


endmodule
