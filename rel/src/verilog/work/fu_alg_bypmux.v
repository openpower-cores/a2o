// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

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
