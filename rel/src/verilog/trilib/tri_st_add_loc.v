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

//  Description:  Adder Component
//
//*****************************************************************************

// input phase is importent
// (change X (B) by switching xor/xnor )

module tri_st_add_loc(
   g01_b,
   t01_b,
   sum_0,
   sum_1
);
   input [0:7]  g01_b;		// after xor
   input [0:7]  t01_b;
   output [0:7] sum_0;
   output [0:7] sum_1;

   wire [0:7]   g01_t;
   wire [0:7]   g01_not;
   wire [0:7]   z01_b;
   wire [0:7]   p01;
   wire [0:7]   p01_b;
   wire [0:7]   g02;
   wire [0:7]   t02;
   wire [0:7]   g04_b;
   wire [0:7]   t04_b;
   wire [0:7]   g08;
   wire [0:7]   t08;
   (* ANALYSIS_NOT_REFERENCED="<0>TRUE" *)
   wire [0:7]   g08_b;
   (* ANALYSIS_NOT_REFERENCED="<0>TRUE" *)
   wire [0:7]   t08_b;

   //####################################################################
   //# funny way to make xor
   //####################################################################

   assign g01_t[0:7] = (~g01_b[0:7]);		//small (buffer off)
   assign g01_not[0:7] = (~g01_t[0:7]);		//small (buffer off)
   assign z01_b[0:7] = (~t01_b[0:7]);
   assign p01_b[0:7] = (~(g01_not[0:7] & z01_b[0:7]));
   assign p01[0:7] = (~(p01_b[0:7]));

   //####################################################################
   //# conditional sums  // may need to make NON-xor implementation
   //####################################################################

   //xx u_sum_0: sum_0(0 to 7) <= not( p01_b(0 to 7) xor g08(0 to 7) ); --output--
   //xx u_sum_1: sum_1(0 to 7) <= not( p01_b(0 to 7) xor t08(0 to 7) ); --output--

   assign g08_b[0] = (~g08[0]);
   assign g08_b[1] = (~g08[1]);
   assign g08_b[2] = (~g08[2]);
   assign g08_b[3] = (~g08[3]);
   assign g08_b[4] = (~g08[4]);
   assign g08_b[5] = (~g08[5]);
   assign g08_b[6] = (~g08[6]);
   assign g08_b[7] = (~g08[7]);

   assign t08_b[0] = (~t08[0]);
   assign t08_b[1] = (~t08[1]);
   assign t08_b[2] = (~t08[2]);
   assign t08_b[3] = (~t08[3]);
   assign t08_b[4] = (~t08[4]);
   assign t08_b[5] = (~t08[5]);
   assign t08_b[6] = (~t08[6]);
   assign t08_b[7] = (~t08[7]);

   assign sum_0[0] = (~((p01[0] & g08[1]) | (p01_b[0] & g08_b[1])));		//output--
   assign sum_0[1] = (~((p01[1] & g08[2]) | (p01_b[1] & g08_b[2])));		//output--
   assign sum_0[2] = (~((p01[2] & g08[3]) | (p01_b[2] & g08_b[3])));		//output--
   assign sum_0[3] = (~((p01[3] & g08[4]) | (p01_b[3] & g08_b[4])));		//output--
   assign sum_0[4] = (~((p01[4] & g08[5]) | (p01_b[4] & g08_b[5])));		//output--
   assign sum_0[5] = (~((p01[5] & g08[6]) | (p01_b[5] & g08_b[6])));		//output--
   assign sum_0[6] = (~((p01[6] & g08[7]) | (p01_b[6] & g08_b[7])));		//output--
   assign sum_0[7] = (~(p01_b[7]));		//output--

   assign sum_1[0] = (~((p01[0] & t08[1]) | (p01_b[0] & t08_b[1])));		//output--
   assign sum_1[1] = (~((p01[1] & t08[2]) | (p01_b[1] & t08_b[2])));		//output--
   assign sum_1[2] = (~((p01[2] & t08[3]) | (p01_b[2] & t08_b[3])));		//output--
   assign sum_1[3] = (~((p01[3] & t08[4]) | (p01_b[3] & t08_b[4])));		//output--
   assign sum_1[4] = (~((p01[4] & t08[5]) | (p01_b[4] & t08_b[5])));		//output--
   assign sum_1[5] = (~((p01[5] & t08[6]) | (p01_b[5] & t08_b[6])));		//output--
   assign sum_1[6] = (~((p01[6] & t08[7]) | (p01_b[6] & t08_b[7])));		//output--
   assign sum_1[7] = (~(p01[7]));		//output--

   //####################################################################
   //# local carry
   //####################################################################

   assign g02[0] = (~(g01_b[0] & (t01_b[0] | g01_b[1])));
   assign g02[1] = (~(g01_b[1] & (t01_b[1] | g01_b[2])));
   assign g02[2] = (~(g01_b[2] & (t01_b[2] | g01_b[3])));
   assign g02[3] = (~(g01_b[3] & (t01_b[3] | g01_b[4])));
   assign g02[4] = (~(g01_b[4] & (t01_b[4] | g01_b[5])));
   assign g02[5] = (~(g01_b[5] & (t01_b[5] | g01_b[6])));
   assign g02[6] = (~(g01_b[6] & (t01_b[6] | g01_b[7])));		//final--
   assign g02[7] = (~(g01_b[7]));

   assign t02[0] = (~(t01_b[0] | t01_b[1]));
   assign t02[1] = (~(t01_b[1] | t01_b[2]));
   assign t02[2] = (~(t01_b[2] | t01_b[3]));
   assign t02[3] = (~(t01_b[3] | t01_b[4]));
   assign t02[4] = (~(t01_b[4] | t01_b[5]));
   assign t02[5] = (~(t01_b[5] | t01_b[6]));
   assign t02[6] = (~(g01_b[6] & (t01_b[6] | t01_b[7])));		//final--
   assign t02[7] = (~(t01_b[7]));

   assign g04_b[0] = (~(g02[0] | (t02[0] & g02[2])));
   assign g04_b[1] = (~(g02[1] | (t02[1] & g02[3])));
   assign g04_b[2] = (~(g02[2] | (t02[2] & g02[4])));
   assign g04_b[3] = (~(g02[3] | (t02[3] & g02[5])));
   assign g04_b[4] = (~(g02[4] | (t02[4] & g02[6])));		//final--
   assign g04_b[5] = (~(g02[5] | (t02[5] & g02[7])));		//final--
   assign g04_b[6] = (~(g02[6]));
   assign g04_b[7] = (~(g02[7]));

   assign t04_b[0] = (~(t02[0] & t02[2]));
   assign t04_b[1] = (~(t02[1] & t02[3]));
   assign t04_b[2] = (~(t02[2] & t02[4]));
   assign t04_b[3] = (~(t02[3] & t02[5]));
   assign t04_b[4] = (~(g02[4] | (t02[4] & t02[6])));		//final--
   assign t04_b[5] = (~(g02[5] | (t02[5] & t02[7])));		//final--
   assign t04_b[6] = (~(t02[6]));
   assign t04_b[7] = (~(t02[7]));

   assign g08[0] = (~(g04_b[0] & (t04_b[0] | g04_b[4])));		//final--
   assign g08[1] = (~(g04_b[1] & (t04_b[1] | g04_b[5])));		//final--
   assign g08[2] = (~(g04_b[2] & (t04_b[2] | g04_b[6])));		//final--
   assign g08[3] = (~(g04_b[3] & (t04_b[3] | g04_b[7])));		//final--
   assign g08[4] = (~(g04_b[4]));
   assign g08[5] = (~(g04_b[5]));
   assign g08[6] = (~(g04_b[6]));
   assign g08[7] = (~(g04_b[7]));

   assign t08[0] = (~(g04_b[0] & (t04_b[0] | t04_b[4])));		//final--
   assign t08[1] = (~(g04_b[1] & (t04_b[1] | t04_b[5])));		//final--
   assign t08[2] = (~(g04_b[2] & (t04_b[2] | t04_b[6])));		//final--
   assign t08[3] = (~(g04_b[3] & (t04_b[3] | t04_b[7])));		//final--
   assign t08[4] = (~(t04_b[4]));
   assign t08[5] = (~(t04_b[5]));
   assign t08[6] = (~(t04_b[6]));
   assign t08[7] = (~(t04_b[7]));

endmodule
