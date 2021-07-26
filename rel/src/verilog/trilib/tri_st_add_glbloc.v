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

// input phase is important
// (change X (B) by switching xor/xnor )

module tri_st_add_glbloc(
   g01,
   t01,
   g08,
   t08
);
   input [0:7] g01;		// after xor
   input [0:7] t01;
   output      g08;
   output      t08;

   wire [0:3]  g02_b;
   wire [0:3]  t02_b;
   wire [0:1]  g04;
   wire [0:1]  t04;
   wire        g08_b;
   wire        t08_b;

   assign g02_b[0] = (~(g01[0] | (t01[0] & g01[1])));
   assign g02_b[1] = (~(g01[2] | (t01[2] & g01[3])));
   assign g02_b[2] = (~(g01[4] | (t01[4] & g01[5])));
   assign g02_b[3] = (~(g01[6] | (t01[6] & g01[7])));

   assign t02_b[0] = (~(t01[0] & t01[1]));
   assign t02_b[1] = (~(t01[2] & t01[3]));
   assign t02_b[2] = (~(t01[4] & t01[5]));
   assign t02_b[3] = (~(t01[6] & t01[7]));

   assign g04[0] = (~(g02_b[0] & (t02_b[0] | g02_b[1])));
   assign g04[1] = (~(g02_b[2] & (t02_b[2] | g02_b[3])));

   assign t04[0] = (~(t02_b[0] | t02_b[1]));
   assign t04[1] = (~(t02_b[2] | t02_b[3]));

   assign g08_b = (~(g04[0] | (t04[0] & g04[1])));

   assign t08_b = (~((t04[0] & t04[1])));

   assign g08 = (~(g08_b));		// output

   assign t08 = (~(t08_b));		// output


endmodule
