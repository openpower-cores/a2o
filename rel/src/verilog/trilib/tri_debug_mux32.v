// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.




module tri_debug_mux32(
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
   dbg_group16,
   dbg_group17,
   dbg_group18,
   dbg_group19,
   dbg_group20,
   dbg_group21,
   dbg_group22,
   dbg_group23,
   dbg_group24,
   dbg_group25,
   dbg_group26,
   dbg_group27,
   dbg_group28,
   dbg_group29,
   dbg_group30,
   dbg_group31,
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
   input [0:DBG_WIDTH-1]  dbg_group16;
   input [0:DBG_WIDTH-1]  dbg_group17;
   input [0:DBG_WIDTH-1]  dbg_group18;
   input [0:DBG_WIDTH-1]  dbg_group19;
   input [0:DBG_WIDTH-1]  dbg_group20;
   input [0:DBG_WIDTH-1]  dbg_group21;
   input [0:DBG_WIDTH-1]  dbg_group22;
   input [0:DBG_WIDTH-1]  dbg_group23;
   input [0:DBG_WIDTH-1]  dbg_group24;
   input [0:DBG_WIDTH-1]  dbg_group25;
   input [0:DBG_WIDTH-1]  dbg_group26;
   input [0:DBG_WIDTH-1]  dbg_group27;
   input [0:DBG_WIDTH-1]  dbg_group28;
   input [0:DBG_WIDTH-1]  dbg_group29;
   input [0:DBG_WIDTH-1]  dbg_group30;
   input [0:DBG_WIDTH-1]  dbg_group31;
   input [0:DBG_WIDTH-1]  trace_data_in;
   output [0:DBG_WIDTH-1] trace_data_out;

   input  [0:3]           coretrace_ctrls_in;  
   output [0:3]           coretrace_ctrls_out;

   parameter              DBG_1FOURTH = DBG_WIDTH/4;
   parameter              DBG_2FOURTH = DBG_WIDTH/2;
   parameter              DBG_3FOURTH = 3 * DBG_WIDTH/4;
   
   wire [0:DBG_WIDTH-1]   debug_grp_selected;
   wire [0:DBG_WIDTH-1]   debug_grp_rotated;
     

   
   assign coretrace_ctrls_out =  coretrace_ctrls_in ;      

   assign debug_grp_selected = (select_bits[0:4] == 5'b00000) ? dbg_group0 : 
                               (select_bits[0:4] == 5'b00001) ? dbg_group1 : 
                               (select_bits[0:4] == 5'b00010) ? dbg_group2 : 
                               (select_bits[0:4] == 5'b00011) ? dbg_group3 : 
                               (select_bits[0:4] == 5'b00100) ? dbg_group4 : 
                               (select_bits[0:4] == 5'b00101) ? dbg_group5 : 
                               (select_bits[0:4] == 5'b00110) ? dbg_group6 : 
                               (select_bits[0:4] == 5'b00111) ? dbg_group7 : 
                               (select_bits[0:4] == 5'b01000) ? dbg_group8 : 
                               (select_bits[0:4] == 5'b01001) ? dbg_group9 : 
                               (select_bits[0:4] == 5'b01010) ? dbg_group10 : 
                               (select_bits[0:4] == 5'b01011) ? dbg_group11 : 
                               (select_bits[0:4] == 5'b01100) ? dbg_group12 : 
                               (select_bits[0:4] == 5'b01101) ? dbg_group13 : 
                               (select_bits[0:4] == 5'b01110) ? dbg_group14 : 
                               (select_bits[0:4] == 5'b01111) ? dbg_group15 : 
                               (select_bits[0:4] == 5'b10000) ? dbg_group16 : 
                               (select_bits[0:4] == 5'b10001) ? dbg_group17 : 
                               (select_bits[0:4] == 5'b10010) ? dbg_group18 : 
                               (select_bits[0:4] == 5'b10011) ? dbg_group19 : 
                               (select_bits[0:4] == 5'b10100) ? dbg_group20 : 
                               (select_bits[0:4] == 5'b10101) ? dbg_group21 : 
                               (select_bits[0:4] == 5'b10110) ? dbg_group22 : 
                               (select_bits[0:4] == 5'b10111) ? dbg_group23 : 
                               (select_bits[0:4] == 5'b11000) ? dbg_group24 : 
                               (select_bits[0:4] == 5'b11001) ? dbg_group25 : 
                               (select_bits[0:4] == 5'b11010) ? dbg_group26 : 
                               (select_bits[0:4] == 5'b11011) ? dbg_group27 : 
                               (select_bits[0:4] == 5'b11100) ? dbg_group28 : 
                               (select_bits[0:4] == 5'b11101) ? dbg_group29 : 
                               (select_bits[0:4] == 5'b11110) ? dbg_group30 : 
                               dbg_group31;
   
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
      
