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



module fu_hc16pp(
   x,
   y,
   ci0,
   ci0_b,
   ci1,
   ci1_b,
   s0,
   s1,
   g16,
   t16
);
   input [0:15]  x;
   input [0:15]  y;
   input         ci0;
   input         ci0_b;
   input         ci1;
   input         ci1_b;
   output [0:15] s0;
   output [0:15] s1;
   output        g16;
   output        t16;

   wire [0:15]   g01_b;
   wire [0:15]   t01_b;
   wire [0:15]   p01_b;
   wire [0:15]   p01;
   wire [0:7]    g01od;
   wire [0:7]    t01od;
   wire [0:7]    g02ev;
   wire [0:7]    t02ev;
   wire [1:7]    g02ev_b;
   wire [1:7]    t02ev_b;
   wire [1:7]    g04ev;
   wire [1:7]    t04ev;
   wire [1:7]    g08ev_b;
   wire [1:7]    t08ev_b;
   wire [1:7]    g16ev;
   wire [1:7]    t16ev;
   wire [1:15]   c0_b;
   wire [1:15]   c1_b;
   wire [0:15]   s0_raw;
   wire [0:15]   s1_raw;
   wire [0:15]   s0_x_b;
   wire [0:15]   s0_y_b;
   wire [0:15]   s1_x_b;
   wire [0:15]   s1_y_b;

   wire          glb_g04_e01_b;		//new // rep glb
   wire          glb_g04_e23_b;
   wire          glb_g04_e45_b;
   wire          glb_g04_e67_b;
   wire          glb_t04_e01_b;		//new // rep glb
   wire          glb_t04_e23_b;
   wire          glb_t04_e45_b;
   wire          glb_t04_e67_b;
   wire          glb_g08_e03;		//new // rep glb
   wire          glb_g08_e47;
   wire          glb_t08_e03;
   wire          glb_t08_e47;
   wire          glb_g16_e07_b;		//new // rep glb
   wire          glb_t16_e07_b;



   ////#####################################
   ////## group 1
   ////#####################################
   // g01_b(0 to 15) <= not( x(0 to 15) and  y(0 to 15) ); -- critical
   // t01_b(0 to 15) <= not( x(0 to 15) or   y(0 to 15) ); -- critical
   // p01_b(0 to 15) <= not( x(0 to 15) xor  y(0 to 15) ); -- not critical

   assign g01_b[0] = (~(x[0] & y[0]));		//critical
   assign g01_b[1] = (~(x[1] & y[1]));		//critical
   assign g01_b[2] = (~(x[2] & y[2]));		//critical
   assign g01_b[3] = (~(x[3] & y[3]));		//critical
   assign g01_b[4] = (~(x[4] & y[4]));		//critical
   assign g01_b[5] = (~(x[5] & y[5]));		//critical
   assign g01_b[6] = (~(x[6] & y[6]));		//critical
   assign g01_b[7] = (~(x[7] & y[7]));		//critical
   assign g01_b[8] = (~(x[8] & y[8]));		//critical
   assign g01_b[9] = (~(x[9] & y[9]));		//critical
   assign g01_b[10] = (~(x[10] & y[10]));		//critical
   assign g01_b[11] = (~(x[11] & y[11]));		//critical
   assign g01_b[12] = (~(x[12] & y[12]));		//critical
   assign g01_b[13] = (~(x[13] & y[13]));		//critical
   assign g01_b[14] = (~(x[14] & y[14]));		//critical
   assign g01_b[15] = (~(x[15] & y[15]));		//critical

   assign t01_b[0] = (~(x[0] | y[0]));		//critical
   assign t01_b[1] = (~(x[1] | y[1]));		//critical
   assign t01_b[2] = (~(x[2] | y[2]));		//critical
   assign t01_b[3] = (~(x[3] | y[3]));		//critical
   assign t01_b[4] = (~(x[4] | y[4]));		//critical
   assign t01_b[5] = (~(x[5] | y[5]));		//critical
   assign t01_b[6] = (~(x[6] | y[6]));		//critical
   assign t01_b[7] = (~(x[7] | y[7]));		//critical
   assign t01_b[8] = (~(x[8] | y[8]));		//critical
   assign t01_b[9] = (~(x[9] | y[9]));		//critical
   assign t01_b[10] = (~(x[10] | y[10]));		//critical
   assign t01_b[11] = (~(x[11] | y[11]));		//critical
   assign t01_b[12] = (~(x[12] | y[12]));		//critical
   assign t01_b[13] = (~(x[13] | y[13]));		//critical
   assign t01_b[14] = (~(x[14] | y[14]));		//critical
   assign t01_b[15] = (~(x[15] | y[15]));		//critical

   assign p01[0] = (x[0] ^ y[0]);		//not critical
   assign p01[1] = (x[1] ^ y[1]);		//not critical
   assign p01[2] = (x[2] ^ y[2]);		//not critical
   assign p01[3] = (x[3] ^ y[3]);		//not critical
   assign p01[4] = (x[4] ^ y[4]);		//not critical
   assign p01[5] = (x[5] ^ y[5]);		//not critical
   assign p01[6] = (x[6] ^ y[6]);		//not critical
   assign p01[7] = (x[7] ^ y[7]);		//not critical
   assign p01[8] = (x[8] ^ y[8]);		//not critical
   assign p01[9] = (x[9] ^ y[9]);		//not critical
   assign p01[10] = (x[10] ^ y[10]);		//not critical
   assign p01[11] = (x[11] ^ y[11]);		//not critical
   assign p01[12] = (x[12] ^ y[12]);		//not critical
   assign p01[13] = (x[13] ^ y[13]);		//not critical
   assign p01[14] = (x[14] ^ y[14]);		//not critical
   assign p01[15] = (x[15] ^ y[15]);		//not critical

   assign p01_b[0] = (~(p01[0]));		//not critical
   assign p01_b[1] = (~(p01[1]));		//not critical
   assign p01_b[2] = (~(p01[2]));		//not critical
   assign p01_b[3] = (~(p01[3]));		//not critical
   assign p01_b[4] = (~(p01[4]));		//not critical
   assign p01_b[5] = (~(p01[5]));		//not critical
   assign p01_b[6] = (~(p01[6]));		//not critical
   assign p01_b[7] = (~(p01[7]));		//not critical
   assign p01_b[8] = (~(p01[8]));		//not critical
   assign p01_b[9] = (~(p01[9]));		//not critical
   assign p01_b[10] = (~(p01[10]));		//not critical
   assign p01_b[11] = (~(p01[11]));		//not critical
   assign p01_b[12] = (~(p01[12]));		//not critical
   assign p01_b[13] = (~(p01[13]));		//not critical
   assign p01_b[14] = (~(p01[14]));		//not critical
   assign p01_b[15] = (~(p01[15]));		//not critical

   assign g01od[0] = (~g01_b[1]);
   assign g01od[1] = (~g01_b[3]);
   assign g01od[2] = (~g01_b[5]);
   assign g01od[3] = (~g01_b[7]);
   assign g01od[4] = (~g01_b[9]);
   assign g01od[5] = (~g01_b[11]);
   assign g01od[6] = (~g01_b[13]);
   assign g01od[7] = (~g01_b[15]);

   assign t01od[0] = (~t01_b[1]);
   assign t01od[1] = (~t01_b[3]);
   assign t01od[2] = (~t01_b[5]);
   assign t01od[3] = (~t01_b[7]);
   assign t01od[4] = (~t01_b[9]);
   assign t01od[5] = (~t01_b[11]);
   assign t01od[6] = (~t01_b[13]);
   assign t01od[7] = (~t01_b[15]);

   ////#####################################
   ////## group 2   // local and global (shared)
   ////#####################################

   assign g02ev[7] = (~((t01_b[14] | g01_b[15]) & g01_b[14]));		//final
   assign g02ev[6] = (~((t01_b[12] | g01_b[13]) & g01_b[12]));
   assign g02ev[5] = (~((t01_b[10] | g01_b[11]) & g01_b[10]));
   assign g02ev[4] = (~((t01_b[8] | g01_b[9]) & g01_b[8]));
   assign g02ev[3] = (~((t01_b[6] | g01_b[7]) & g01_b[6]));
   assign g02ev[2] = (~((t01_b[4] | g01_b[5]) & g01_b[4]));
   assign g02ev[1] = (~((t01_b[2] | g01_b[3]) & g01_b[2]));
   assign g02ev[0] = (~((t01_b[0] | g01_b[1]) & g01_b[0]));

   assign t02ev[7] = (~((t01_b[14] | t01_b[15]) & g01_b[14]));		//final
   assign t02ev[6] = (~(t01_b[12] | t01_b[13]));
   assign t02ev[5] = (~(t01_b[10] | t01_b[11]));
   assign t02ev[4] = (~(t01_b[8] | t01_b[9]));
   assign t02ev[3] = (~(t01_b[6] | t01_b[7]));
   assign t02ev[2] = (~(t01_b[4] | t01_b[5]));
   assign t02ev[1] = (~(t01_b[2] | t01_b[3]));
   assign t02ev[0] = (~(t01_b[0] | t01_b[1]));

   assign g02ev_b[7] = (~(g02ev[7]));		//new
   assign g02ev_b[6] = (~(g02ev[6]));		//new
   assign g02ev_b[5] = (~(g02ev[5]));		//new
   assign g02ev_b[4] = (~(g02ev[4]));		//new
   assign g02ev_b[3] = (~(g02ev[3]));		//new
   assign g02ev_b[2] = (~(g02ev[2]));		//new
   assign g02ev_b[1] = (~(g02ev[1]));		//new

   assign t02ev_b[7] = (~(t02ev[7]));		//new
   assign t02ev_b[6] = (~(t02ev[6]));		//new
   assign t02ev_b[5] = (~(t02ev[5]));		//new
   assign t02ev_b[4] = (~(t02ev[4]));		//new
   assign t02ev_b[3] = (~(t02ev[3]));		//new
   assign t02ev_b[2] = (~(t02ev[2]));		//new
   assign t02ev_b[1] = (~(t02ev[1]));		//new

   ////#####################################
   ////## replicating for global chain
   ////#####################################

   assign glb_g04_e01_b = (~(g02ev[0] | (t02ev[0] & g02ev[1])));
   assign glb_g04_e23_b = (~(g02ev[2] | (t02ev[2] & g02ev[3])));
   assign glb_g04_e45_b = (~(g02ev[4] | (t02ev[4] & g02ev[5])));
   assign glb_g04_e67_b = (~(g02ev[6] | (t02ev[6] & g02ev[7])));
   assign glb_t04_e01_b = (~(t02ev[0] & t02ev[1]));
   assign glb_t04_e23_b = (~(t02ev[2] & t02ev[3]));
   assign glb_t04_e45_b = (~(t02ev[4] & t02ev[5]));
   assign glb_t04_e67_b = (~(g02ev[6] | (t02ev[6] & t02ev[7])));

   assign glb_g08_e03 = (~(glb_g04_e01_b & (glb_t04_e01_b | glb_g04_e23_b)));
   assign glb_g08_e47 = (~(glb_g04_e45_b & (glb_t04_e45_b | glb_g04_e67_b)));
   assign glb_t08_e03 = (~(glb_t04_e01_b | glb_t04_e23_b));
   assign glb_t08_e47 = (~(glb_g04_e45_b & (glb_t04_e45_b | glb_t04_e67_b)));

   assign glb_g16_e07_b = (~(glb_g08_e03 | (glb_t08_e03 & glb_g08_e47)));
   assign glb_t16_e07_b = (~(glb_g08_e03 | (glb_t08_e03 & glb_t08_e47)));

   assign g16 = (~(glb_g16_e07_b));		//output
   assign t16 = (~(glb_t16_e07_b));		//output

   ////#####################################
   ////## group 4 // delayed for local chain ... reverse phase
   ////#####################################

   assign g04ev[7] = (~(g02ev_b[7]));
   assign g04ev[6] = (~(g02ev_b[6] & (t02ev_b[6] | g02ev_b[7])));		//final
   assign g04ev[5] = (~(g02ev_b[5] & (t02ev_b[5] | g02ev_b[6])));
   assign g04ev[4] = (~(g02ev_b[4] & (t02ev_b[4] | g02ev_b[5])));
   assign g04ev[3] = (~(g02ev_b[3] & (t02ev_b[3] | g02ev_b[4])));
   assign g04ev[2] = (~(g02ev_b[2] & (t02ev_b[2] | g02ev_b[3])));
   assign g04ev[1] = (~(g02ev_b[1] & (t02ev_b[1] | g02ev_b[2])));

   assign t04ev[7] = (~(t02ev_b[7]));
   assign t04ev[6] = (~(g02ev_b[6] & (t02ev_b[6] | t02ev_b[7])));		//final
   assign t04ev[5] = (~(t02ev_b[5] | t02ev_b[6]));
   assign t04ev[4] = (~(t02ev_b[4] | t02ev_b[5]));
   assign t04ev[3] = (~(t02ev_b[3] | t02ev_b[4]));
   assign t04ev[2] = (~(t02ev_b[2] | t02ev_b[3]));
   assign t04ev[1] = (~(t02ev_b[1] | t02ev_b[2]));

   ////#####################################
   ////## group 8
   ////#####################################

   assign g08ev_b[7] = (~(g04ev[7]));
   assign g08ev_b[6] = (~(g04ev[6]));
   assign g08ev_b[5] = (~(g04ev[5] | (t04ev[5] & g04ev[7])));		//final
   assign g08ev_b[4] = (~(g04ev[4] | (t04ev[4] & g04ev[6])));		//final
   assign g08ev_b[3] = (~(g04ev[3] | (t04ev[3] & g04ev[5])));
   assign g08ev_b[2] = (~(g04ev[2] | (t04ev[2] & g04ev[4])));
   assign g08ev_b[1] = (~(g04ev[1] | (t04ev[1] & g04ev[3])));

   assign t08ev_b[7] = (~(t04ev[7]));
   assign t08ev_b[6] = (~(t04ev[6]));
   assign t08ev_b[5] = (~(g04ev[5] | (t04ev[5] & t04ev[7])));		//final
   assign t08ev_b[4] = (~(g04ev[4] | (t04ev[4] & t04ev[6])));		//final
   assign t08ev_b[3] = (~(t04ev[3] & t04ev[5]));
   assign t08ev_b[2] = (~(t04ev[2] & t04ev[4]));
   assign t08ev_b[1] = (~(t04ev[1] & t04ev[3]));

   ////#####################################
   ////## group 16
   ////#####################################

   assign g16ev[7] = (~(g08ev_b[7]));
   assign g16ev[6] = (~(g08ev_b[6]));
   assign g16ev[5] = (~(g08ev_b[5]));
   assign g16ev[4] = (~(g08ev_b[4]));
   assign g16ev[3] = (~(g08ev_b[3] & (t08ev_b[3] | g08ev_b[7])));		//final
   assign g16ev[2] = (~(g08ev_b[2] & (t08ev_b[2] | g08ev_b[6])));		//final
   assign g16ev[1] = (~(g08ev_b[1] & (t08ev_b[1] | g08ev_b[5])));		//final

   assign t16ev[7] = (~(t08ev_b[7]));
   assign t16ev[6] = (~(t08ev_b[6]));
   assign t16ev[5] = (~(t08ev_b[5]));
   assign t16ev[4] = (~(t08ev_b[4]));
   assign t16ev[3] = (~(g08ev_b[3] & (t08ev_b[3] | t08ev_b[7])));		//final
   assign t16ev[2] = (~(g08ev_b[2] & (t08ev_b[2] | t08ev_b[6])));		//final
   assign t16ev[1] = (~(g08ev_b[1] & (t08ev_b[1] | t08ev_b[5])));		//final

   ////#####################################
   ////## group 16 delayed
   ////#####################################

   assign c0_b[14] = (~(g16ev[7]));
   assign c0_b[12] = (~(g16ev[6]));
   assign c0_b[10] = (~(g16ev[5]));
   assign c0_b[8] = (~(g16ev[4]));
   assign c0_b[6] = (~(g16ev[3]));
   assign c0_b[4] = (~(g16ev[2]));
   assign c0_b[2] = (~(g16ev[1]));

   assign c1_b[14] = (~(t16ev[7]));
   assign c1_b[12] = (~(t16ev[6]));
   assign c1_b[10] = (~(t16ev[5]));
   assign c1_b[8] = (~(t16ev[4]));
   assign c1_b[6] = (~(t16ev[3]));
   assign c1_b[4] = (~(t16ev[2]));
   assign c1_b[2] = (~(t16ev[1]));

   assign c0_b[15] = (~(g01od[7]));
   assign c0_b[13] = (~((t01od[6] & g16ev[7]) | g01od[6]));
   assign c0_b[11] = (~((t01od[5] & g16ev[6]) | g01od[5]));
   assign c0_b[9] = (~((t01od[4] & g16ev[5]) | g01od[4]));
   assign c0_b[7] = (~((t01od[3] & g16ev[4]) | g01od[3]));
   assign c0_b[5] = (~((t01od[2] & g16ev[3]) | g01od[2]));
   assign c0_b[3] = (~((t01od[1] & g16ev[2]) | g01od[1]));
   assign c0_b[1] = (~((t01od[0] & g16ev[1]) | g01od[0]));

   assign c1_b[15] = (~(t01od[7]));
   assign c1_b[13] = (~((t01od[6] & t16ev[7]) | g01od[6]));
   assign c1_b[11] = (~((t01od[5] & t16ev[6]) | g01od[5]));
   assign c1_b[9] = (~((t01od[4] & t16ev[5]) | g01od[4]));
   assign c1_b[7] = (~((t01od[3] & t16ev[4]) | g01od[3]));
   assign c1_b[5] = (~((t01od[2] & t16ev[3]) | g01od[2]));
   assign c1_b[3] = (~((t01od[1] & t16ev[2]) | g01od[1]));
   assign c1_b[1] = (~((t01od[0] & t16ev[1]) | g01od[0]));

   ////#####################################
   ////## sum before select
   ////#####################################

   assign s0_raw[0] = (p01_b[0] ^ c0_b[1]);
   assign s0_raw[1] = (p01_b[1] ^ c0_b[2]);
   assign s0_raw[2] = (p01_b[2] ^ c0_b[3]);
   assign s0_raw[3] = (p01_b[3] ^ c0_b[4]);
   assign s0_raw[4] = (p01_b[4] ^ c0_b[5]);
   assign s0_raw[5] = (p01_b[5] ^ c0_b[6]);
   assign s0_raw[6] = (p01_b[6] ^ c0_b[7]);
   assign s0_raw[7] = (p01_b[7] ^ c0_b[8]);
   assign s0_raw[8] = (p01_b[8] ^ c0_b[9]);
   assign s0_raw[9] = (p01_b[9] ^ c0_b[10]);
   assign s0_raw[10] = (p01_b[10] ^ c0_b[11]);
   assign s0_raw[11] = (p01_b[11] ^ c0_b[12]);
   assign s0_raw[12] = (p01_b[12] ^ c0_b[13]);
   assign s0_raw[13] = (p01_b[13] ^ c0_b[14]);
   assign s0_raw[14] = (p01_b[14] ^ c0_b[15]);
   assign s0_raw[15] = (~p01_b[15]);

   assign s1_raw[0] = (p01_b[0] ^ c1_b[1]);
   assign s1_raw[1] = (p01_b[1] ^ c1_b[2]);
   assign s1_raw[2] = (p01_b[2] ^ c1_b[3]);
   assign s1_raw[3] = (p01_b[3] ^ c1_b[4]);
   assign s1_raw[4] = (p01_b[4] ^ c1_b[5]);
   assign s1_raw[5] = (p01_b[5] ^ c1_b[6]);
   assign s1_raw[6] = (p01_b[6] ^ c1_b[7]);
   assign s1_raw[7] = (p01_b[7] ^ c1_b[8]);
   assign s1_raw[8] = (p01_b[8] ^ c1_b[9]);
   assign s1_raw[9] = (p01_b[9] ^ c1_b[10]);
   assign s1_raw[10] = (p01_b[10] ^ c1_b[11]);
   assign s1_raw[11] = (p01_b[11] ^ c1_b[12]);
   assign s1_raw[12] = (p01_b[12] ^ c1_b[13]);
   assign s1_raw[13] = (p01_b[13] ^ c1_b[14]);
   assign s1_raw[14] = (p01_b[14] ^ c1_b[15]);
   assign s1_raw[15] = (~s0_raw[15]);

   ////#####################################
   ////## sum after select
   ////#####################################

   assign s0_x_b[0] = (~(s0_raw[0] & ci0_b));
   assign s0_y_b[0] = (~(s1_raw[0] & ci0));
   assign s1_x_b[0] = (~(s0_raw[0] & ci1_b));
   assign s1_y_b[0] = (~(s1_raw[0] & ci1));
   assign s0[0] = (~(s0_x_b[0] & s0_y_b[0]));
   assign s1[0] = (~(s1_x_b[0] & s1_y_b[0]));

   assign s0_x_b[1] = (~(s0_raw[1] & ci0_b));
   assign s0_y_b[1] = (~(s1_raw[1] & ci0));
   assign s1_x_b[1] = (~(s0_raw[1] & ci1_b));
   assign s1_y_b[1] = (~(s1_raw[1] & ci1));
   assign s0[1] = (~(s0_x_b[1] & s0_y_b[1]));
   assign s1[1] = (~(s1_x_b[1] & s1_y_b[1]));

   assign s0_x_b[2] = (~(s0_raw[2] & ci0_b));
   assign s0_y_b[2] = (~(s1_raw[2] & ci0));
   assign s1_x_b[2] = (~(s0_raw[2] & ci1_b));
   assign s1_y_b[2] = (~(s1_raw[2] & ci1));
   assign s0[2] = (~(s0_x_b[2] & s0_y_b[2]));
   assign s1[2] = (~(s1_x_b[2] & s1_y_b[2]));

   assign s0_x_b[3] = (~(s0_raw[3] & ci0_b));
   assign s0_y_b[3] = (~(s1_raw[3] & ci0));
   assign s1_x_b[3] = (~(s0_raw[3] & ci1_b));
   assign s1_y_b[3] = (~(s1_raw[3] & ci1));
   assign s0[3] = (~(s0_x_b[3] & s0_y_b[3]));
   assign s1[3] = (~(s1_x_b[3] & s1_y_b[3]));

   assign s0_x_b[4] = (~(s0_raw[4] & ci0_b));
   assign s0_y_b[4] = (~(s1_raw[4] & ci0));
   assign s1_x_b[4] = (~(s0_raw[4] & ci1_b));
   assign s1_y_b[4] = (~(s1_raw[4] & ci1));
   assign s0[4] = (~(s0_x_b[4] & s0_y_b[4]));
   assign s1[4] = (~(s1_x_b[4] & s1_y_b[4]));

   assign s0_x_b[5] = (~(s0_raw[5] & ci0_b));
   assign s0_y_b[5] = (~(s1_raw[5] & ci0));
   assign s1_x_b[5] = (~(s0_raw[5] & ci1_b));
   assign s1_y_b[5] = (~(s1_raw[5] & ci1));
   assign s0[5] = (~(s0_x_b[5] & s0_y_b[5]));
   assign s1[5] = (~(s1_x_b[5] & s1_y_b[5]));

   assign s0_x_b[6] = (~(s0_raw[6] & ci0_b));
   assign s0_y_b[6] = (~(s1_raw[6] & ci0));
   assign s1_x_b[6] = (~(s0_raw[6] & ci1_b));
   assign s1_y_b[6] = (~(s1_raw[6] & ci1));
   assign s0[6] = (~(s0_x_b[6] & s0_y_b[6]));
   assign s1[6] = (~(s1_x_b[6] & s1_y_b[6]));

   assign s0_x_b[7] = (~(s0_raw[7] & ci0_b));
   assign s0_y_b[7] = (~(s1_raw[7] & ci0));
   assign s1_x_b[7] = (~(s0_raw[7] & ci1_b));
   assign s1_y_b[7] = (~(s1_raw[7] & ci1));
   assign s0[7] = (~(s0_x_b[7] & s0_y_b[7]));
   assign s1[7] = (~(s1_x_b[7] & s1_y_b[7]));

   assign s0_x_b[8] = (~(s0_raw[8] & ci0_b));
   assign s0_y_b[8] = (~(s1_raw[8] & ci0));
   assign s1_x_b[8] = (~(s0_raw[8] & ci1_b));
   assign s1_y_b[8] = (~(s1_raw[8] & ci1));
   assign s0[8] = (~(s0_x_b[8] & s0_y_b[8]));
   assign s1[8] = (~(s1_x_b[8] & s1_y_b[8]));

   assign s0_x_b[9] = (~(s0_raw[9] & ci0_b));
   assign s0_y_b[9] = (~(s1_raw[9] & ci0));
   assign s1_x_b[9] = (~(s0_raw[9] & ci1_b));
   assign s1_y_b[9] = (~(s1_raw[9] & ci1));
   assign s0[9] = (~(s0_x_b[9] & s0_y_b[9]));
   assign s1[9] = (~(s1_x_b[9] & s1_y_b[9]));

   assign s0_x_b[10] = (~(s0_raw[10] & ci0_b));
   assign s0_y_b[10] = (~(s1_raw[10] & ci0));
   assign s1_x_b[10] = (~(s0_raw[10] & ci1_b));
   assign s1_y_b[10] = (~(s1_raw[10] & ci1));
   assign s0[10] = (~(s0_x_b[10] & s0_y_b[10]));
   assign s1[10] = (~(s1_x_b[10] & s1_y_b[10]));

   assign s0_x_b[11] = (~(s0_raw[11] & ci0_b));
   assign s0_y_b[11] = (~(s1_raw[11] & ci0));
   assign s1_x_b[11] = (~(s0_raw[11] & ci1_b));
   assign s1_y_b[11] = (~(s1_raw[11] & ci1));
   assign s0[11] = (~(s0_x_b[11] & s0_y_b[11]));
   assign s1[11] = (~(s1_x_b[11] & s1_y_b[11]));

   assign s0_x_b[12] = (~(s0_raw[12] & ci0_b));
   assign s0_y_b[12] = (~(s1_raw[12] & ci0));
   assign s1_x_b[12] = (~(s0_raw[12] & ci1_b));
   assign s1_y_b[12] = (~(s1_raw[12] & ci1));
   assign s0[12] = (~(s0_x_b[12] & s0_y_b[12]));
   assign s1[12] = (~(s1_x_b[12] & s1_y_b[12]));

   assign s0_x_b[13] = (~(s0_raw[13] & ci0_b));
   assign s0_y_b[13] = (~(s1_raw[13] & ci0));
   assign s1_x_b[13] = (~(s0_raw[13] & ci1_b));
   assign s1_y_b[13] = (~(s1_raw[13] & ci1));
   assign s0[13] = (~(s0_x_b[13] & s0_y_b[13]));
   assign s1[13] = (~(s1_x_b[13] & s1_y_b[13]));

   assign s0_x_b[14] = (~(s0_raw[14] & ci0_b));
   assign s0_y_b[14] = (~(s1_raw[14] & ci0));
   assign s1_x_b[14] = (~(s0_raw[14] & ci1_b));
   assign s1_y_b[14] = (~(s1_raw[14] & ci1));
   assign s0[14] = (~(s0_x_b[14] & s0_y_b[14]));
   assign s1[14] = (~(s1_x_b[14] & s1_y_b[14]));

   assign s0_x_b[15] = (~(s0_raw[15] & ci0_b));
   assign s0_y_b[15] = (~(s1_raw[15] & ci0));
   assign s1_x_b[15] = (~(s0_raw[15] & ci1_b));
   assign s1_y_b[15] = (~(s1_raw[15] & ci1));
   assign s0[15] = (~(s0_x_b[15] & s0_y_b[15]));
   assign s1[15] = (~(s1_x_b[15] & s1_y_b[15]));

endmodule
