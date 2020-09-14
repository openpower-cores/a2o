// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns




module fu_gst_add11(
   a_b,
   b_b,
   s0
);
   `include "tri_a2o.vh"
 
   
   input [0:10]  a_b;		
   input [0:10]  b_b;		
   output [0:10] s0;
   
   (* NO_MODIFICATION="TRUE" *) 
   wire [0:10]   p1;
   (* NO_MODIFICATION="TRUE" *) 
   wire [1:10]   g1;
   (* NO_MODIFICATION="TRUE" *) 
   wire [1:9]    t1;
   (* NO_MODIFICATION="TRUE" *) 
   wire [1:10]   g2_b;
   (* NO_MODIFICATION="TRUE" *) 
   wire [1:10]   g4;
   (* NO_MODIFICATION="TRUE" *) 
   wire [1:10]   g8_b;
   (* NO_MODIFICATION="TRUE" *) 
   wire [1:10]   c16;
   (* NO_MODIFICATION="TRUE" *) 
   wire [1:8]    t2_b;
   (* NO_MODIFICATION="TRUE" *) 
   wire [1:6]    t4;
   (* NO_MODIFICATION="TRUE" *) 
   wire [1:2]    t8_b;


   assign p1[0:10] = (a_b[0:10] ^ b_b[0:10]);
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g1[1:10] = (~(a_b[1:10] | b_b[1:10]));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t1[1:9] = (~(a_b[1:9] & b_b[1:9]));
   
   
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g2_b[1] = (~(g1[1] | (t1[1] & g1[2])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g2_b[2] = (~(g1[2] | (t1[2] & g1[3])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g2_b[3] = (~(g1[3] | (t1[3] & g1[4])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g2_b[4] = (~(g1[4] | (t1[4] & g1[5])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g2_b[5] = (~(g1[5] | (t1[5] & g1[6])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g2_b[6] = (~(g1[6] | (t1[6] & g1[7])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g2_b[7] = (~(g1[7] | (t1[7] & g1[8])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g2_b[8] = (~(g1[8] | (t1[8] & g1[9])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g2_b[9] = (~(g1[9] | (t1[9] & g1[10])));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g2_b[10] = (~(g1[10]));		
   
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t2_b[1] = (~(t1[1] & t1[2]));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t2_b[2] = (~(t1[2] & t1[3]));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t2_b[3] = (~(t1[3] & t1[4]));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t2_b[4] = (~(t1[4] & t1[5]));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t2_b[5] = (~(t1[5] & t1[6]));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t2_b[6] = (~(t1[6] & t1[7]));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t2_b[7] = (~(t1[7] & t1[8]));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t2_b[8] = (~(t1[8] & t1[9]));
   
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g4[1] = (~(g2_b[1] & (t2_b[1] | g2_b[3])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g4[2] = (~(g2_b[2] & (t2_b[2] | g2_b[4])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g4[3] = (~(g2_b[3] & (t2_b[3] | g2_b[5])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g4[4] = (~(g2_b[4] & (t2_b[4] | g2_b[6])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g4[5] = (~(g2_b[5] & (t2_b[5] | g2_b[7])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g4[6] = (~(g2_b[6] & (t2_b[6] | g2_b[8])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g4[7] = (~(g2_b[7] & (t2_b[7] | g2_b[9])));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g4[8] = (~(g2_b[8] & (t2_b[8] | g2_b[10])));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g4[9] = (~(g2_b[9]));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g4[10] = (~(g2_b[10]));		
   
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t4[1] = (~(t2_b[1] | t2_b[3]));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t4[2] = (~(t2_b[2] | t2_b[4]));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t4[3] = (~(t2_b[3] | t2_b[5]));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t4[4] = (~(t2_b[4] | t2_b[6]));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t4[5] = (~(t2_b[5] | t2_b[7]));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t4[6] = (~(t2_b[6] | t2_b[8]));
   
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g8_b[1] = (~(g4[1] | (t4[1] & g4[5])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g8_b[2] = (~(g4[2] | (t4[2] & g4[6])));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g8_b[3] = (~(g4[3] | (t4[3] & g4[7])));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g8_b[4] = (~(g4[4] | (t4[4] & g4[8])));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g8_b[5] = (~(g4[5] | (t4[5] & g4[9])));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g8_b[6] = (~(g4[6] | (t4[6] & g4[10])));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g8_b[7] = (~(g4[7]));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g8_b[8] = (~(g4[8]));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g8_b[9] = (~(g4[9]));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign g8_b[10] = (~(g4[10]));		
   
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t8_b[1] = (~(t4[1] & t4[5]));
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign t8_b[2] = (~(t4[2] & t4[6]));
   
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign c16[1] = (~(g8_b[1] & (t8_b[1] | g8_b[9])));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign c16[2] = (~(g8_b[2] & (t8_b[2] | g8_b[10])));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign c16[3] = (~(g8_b[3]));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign c16[4] = (~(g8_b[4]));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign c16[5] = (~(g8_b[5]));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign c16[6] = (~(g8_b[6]));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign c16[7] = (~(g8_b[7]));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign c16[8] = (~(g8_b[8]));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign c16[9] = (~(g8_b[9]));		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/" *)
   assign c16[10] = (~(g8_b[10]));		
   
   
   assign s0[0:9] = p1[0:9] ^ c16[1:10];
   assign s0[10] = p1[10];
   
   
endmodule



   
