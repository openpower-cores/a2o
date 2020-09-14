// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.



module tri_st_add_glbloc(
   g01,
   t01,
   g08,
   t08
);
   input [0:7] g01;		
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

   assign g08 = (~(g08_b));		

   assign t08 = (~(t08_b));		
      

endmodule

