// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.


   

module tri_debug_mux16(
   select_bits,
   dbg_group0,
   dbg_group1,
   dbg_group2,
   dbg_group3,
   dbg_group4,
   dbg_group5,
   dbg_group6,
   dbg_group7,
   dbg_group8,
   dbg_group9,
   dbg_group10,
   dbg_group11,
   dbg_group12,
   dbg_group13,
   dbg_group14,
   dbg_group15,
   trace_data_in,
   trace_data_out,
   coretrace_ctrls_in,
   coretrace_ctrls_out
);

   parameter              DBG_WIDTH = 32;	


   
   input [0:10]           select_bits;
   input [0:DBG_WIDTH-1]  dbg_group0;
   input [0:DBG_WIDTH-1]  dbg_group1;
   input [0:DBG_WIDTH-1]  dbg_group2;
   input [0:DBG_WIDTH-1]  dbg_group3;
   input [0:DBG_WIDTH-1]  dbg_group4;
   input [0:DBG_WIDTH-1]  dbg_group5;
   input [0:DBG_WIDTH-1]  dbg_group6;
   input [0:DBG_WIDTH-1]  dbg_group7;
   input [0:DBG_WIDTH-1]  dbg_group8;
   input [0:DBG_WIDTH-1]  dbg_group9;
   input [0:DBG_WIDTH-1]  dbg_group10;
   input [0:DBG_WIDTH-1]  dbg_group11;
   input [0:DBG_WIDTH-1]  dbg_group12;
   input [0:DBG_WIDTH-1]  dbg_group13;
   input [0:DBG_WIDTH-1]  dbg_group14;
   input [0:DBG_WIDTH-1]  dbg_group15;
   input [0:DBG_WIDTH-1]  trace_data_in;
   output [0:DBG_WIDTH-1] trace_data_out;
 
   input  [0:3]           coretrace_ctrls_in;  
   output [0:3]           coretrace_ctrls_out;

   parameter              DBG_1FOURTH = DBG_WIDTH/4;
   parameter              DBG_2FOURTH = DBG_WIDTH/2;
   parameter              DBG_3FOURTH = 3 * DBG_WIDTH/4;
   
   wire [0:DBG_WIDTH-1]   debug_grp_selected;
   wire [0:DBG_WIDTH-1]   debug_grp_rotated;
    

(* analysis_not_referenced="true" *)  
   wire                   unused;
   assign unused = select_bits[4];
   
   assign coretrace_ctrls_out =  coretrace_ctrls_in ;      

   assign debug_grp_selected = (select_bits[0:3] == 4'b0000) ? dbg_group0 : 
                               (select_bits[0:3] == 4'b0001) ? dbg_group1 : 
                               (select_bits[0:3] == 4'b0010) ? dbg_group2 : 
                               (select_bits[0:3] == 4'b0011) ? dbg_group3 : 
                               (select_bits[0:3] == 4'b0100) ? dbg_group4 : 
                               (select_bits[0:3] == 4'b0101) ? dbg_group5 : 
                               (select_bits[0:3] == 4'b0110) ? dbg_group6 : 
                               (select_bits[0:3] == 4'b0111) ? dbg_group7 : 
                               (select_bits[0:3] == 4'b1000) ? dbg_group8 : 
                               (select_bits[0:3] == 4'b1001) ? dbg_group9 : 
                               (select_bits[0:3] == 4'b1010) ? dbg_group10 : 
                               (select_bits[0:3] == 4'b1011) ? dbg_group11 : 
                               (select_bits[0:3] == 4'b1100) ? dbg_group12 : 
                               (select_bits[0:3] == 4'b1101) ? dbg_group13 : 
                               (select_bits[0:3] == 4'b1110) ? dbg_group14 : 
                               dbg_group15;
   
   assign debug_grp_rotated  = (select_bits[5:6] == 2'b11) ? {debug_grp_selected[DBG_1FOURTH:DBG_WIDTH - 1], debug_grp_selected[0:DBG_1FOURTH - 1]} : 
                               (select_bits[5:6] == 2'b10) ? {debug_grp_selected[DBG_2FOURTH:DBG_WIDTH - 1], debug_grp_selected[0:DBG_2FOURTH - 1]} : 
                               (select_bits[5:6] == 2'b01) ? {debug_grp_selected[DBG_3FOURTH:DBG_WIDTH - 1], debug_grp_selected[0:DBG_3FOURTH - 1]} : 
                               debug_grp_selected[0:DBG_WIDTH - 1];

   
   assign trace_data_out[0:DBG_1FOURTH - 1]           = (select_bits[7] == 1'b0) ? trace_data_in[0:DBG_1FOURTH - 1] : 
                                                        debug_grp_rotated[0:DBG_1FOURTH - 1];
   
   assign trace_data_out[DBG_1FOURTH:DBG_2FOURTH - 1] = (select_bits[8] == 1'b0) ? trace_data_in[DBG_1FOURTH:DBG_2FOURTH - 1] : 
                                                        debug_grp_rotated[DBG_1FOURTH:DBG_2FOURTH - 1];
   
   assign trace_data_out[DBG_2FOURTH:DBG_3FOURTH - 1] = (select_bits[9] == 1'b0) ? trace_data_in[DBG_2FOURTH:DBG_3FOURTH - 1] : 
                                                        debug_grp_rotated[DBG_2FOURTH:DBG_3FOURTH - 1];
   
   assign trace_data_out[DBG_3FOURTH:DBG_WIDTH - 1]   = (select_bits[10] == 1'b0) ? trace_data_in[DBG_3FOURTH:DBG_WIDTH - 1] : 
                                                        debug_grp_rotated[DBG_3FOURTH:DBG_WIDTH - 1];
   
endmodule
   
