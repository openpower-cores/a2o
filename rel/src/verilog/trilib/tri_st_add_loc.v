// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.



module tri_st_add_loc(
   g01_b,
   t01_b,
   sum_0,
   sum_1
);
   input [0:7]  g01_b;		
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


   assign g01_t[0:7] = (~g01_b[0:7]);		
   assign g01_not[0:7] = (~g01_t[0:7]);		
   assign z01_b[0:7] = (~t01_b[0:7]);
   assign p01_b[0:7] = (~(g01_not[0:7] & z01_b[0:7]));
   assign p01[0:7] = (~(p01_b[0:7]));



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

   assign sum_0[0] = (~((p01[0] & g08[1]) | (p01_b[0] & g08_b[1])));		
   assign sum_0[1] = (~((p01[1] & g08[2]) | (p01_b[1] & g08_b[2])));		
   assign sum_0[2] = (~((p01[2] & g08[3]) | (p01_b[2] & g08_b[3])));		
   assign sum_0[3] = (~((p01[3] & g08[4]) | (p01_b[3] & g08_b[4])));		
   assign sum_0[4] = (~((p01[4] & g08[5]) | (p01_b[4] & g08_b[5])));		
   assign sum_0[5] = (~((p01[5] & g08[6]) | (p01_b[5] & g08_b[6])));		
   assign sum_0[6] = (~((p01[6] & g08[7]) | (p01_b[6] & g08_b[7])));		
   assign sum_0[7] = (~(p01_b[7]));		

   assign sum_1[0] = (~((p01[0] & t08[1]) | (p01_b[0] & t08_b[1])));		
   assign sum_1[1] = (~((p01[1] & t08[2]) | (p01_b[1] & t08_b[2])));		
   assign sum_1[2] = (~((p01[2] & t08[3]) | (p01_b[2] & t08_b[3])));		
   assign sum_1[3] = (~((p01[3] & t08[4]) | (p01_b[3] & t08_b[4])));		
   assign sum_1[4] = (~((p01[4] & t08[5]) | (p01_b[4] & t08_b[5])));		
   assign sum_1[5] = (~((p01[5] & t08[6]) | (p01_b[5] & t08_b[6])));		
   assign sum_1[6] = (~((p01[6] & t08[7]) | (p01_b[6] & t08_b[7])));		
   assign sum_1[7] = (~(p01[7]));		


   assign g02[0] = (~(g01_b[0] & (t01_b[0] | g01_b[1])));
   assign g02[1] = (~(g01_b[1] & (t01_b[1] | g01_b[2])));
   assign g02[2] = (~(g01_b[2] & (t01_b[2] | g01_b[3])));
   assign g02[3] = (~(g01_b[3] & (t01_b[3] | g01_b[4])));
   assign g02[4] = (~(g01_b[4] & (t01_b[4] | g01_b[5])));
   assign g02[5] = (~(g01_b[5] & (t01_b[5] | g01_b[6])));
   assign g02[6] = (~(g01_b[6] & (t01_b[6] | g01_b[7])));		
   assign g02[7] = (~(g01_b[7]));

   assign t02[0] = (~(t01_b[0] | t01_b[1]));
   assign t02[1] = (~(t01_b[1] | t01_b[2]));
   assign t02[2] = (~(t01_b[2] | t01_b[3]));
   assign t02[3] = (~(t01_b[3] | t01_b[4]));
   assign t02[4] = (~(t01_b[4] | t01_b[5]));
   assign t02[5] = (~(t01_b[5] | t01_b[6]));
   assign t02[6] = (~(g01_b[6] & (t01_b[6] | t01_b[7])));		
   assign t02[7] = (~(t01_b[7]));

   assign g04_b[0] = (~(g02[0] | (t02[0] & g02[2])));
   assign g04_b[1] = (~(g02[1] | (t02[1] & g02[3])));
   assign g04_b[2] = (~(g02[2] | (t02[2] & g02[4])));
   assign g04_b[3] = (~(g02[3] | (t02[3] & g02[5])));
   assign g04_b[4] = (~(g02[4] | (t02[4] & g02[6])));		
   assign g04_b[5] = (~(g02[5] | (t02[5] & g02[7])));		
   assign g04_b[6] = (~(g02[6]));
   assign g04_b[7] = (~(g02[7]));

   assign t04_b[0] = (~(t02[0] & t02[2]));
   assign t04_b[1] = (~(t02[1] & t02[3]));
   assign t04_b[2] = (~(t02[2] & t02[4]));
   assign t04_b[3] = (~(t02[3] & t02[5]));
   assign t04_b[4] = (~(g02[4] | (t02[4] & t02[6])));		
   assign t04_b[5] = (~(g02[5] | (t02[5] & t02[7])));		
   assign t04_b[6] = (~(t02[6]));
   assign t04_b[7] = (~(t02[7]));

   assign g08[0] = (~(g04_b[0] & (t04_b[0] | g04_b[4])));		
   assign g08[1] = (~(g04_b[1] & (t04_b[1] | g04_b[5])));		
   assign g08[2] = (~(g04_b[2] & (t04_b[2] | g04_b[6])));		
   assign g08[3] = (~(g04_b[3] & (t04_b[3] | g04_b[7])));		
   assign g08[4] = (~(g04_b[4]));
   assign g08[5] = (~(g04_b[5]));
   assign g08[6] = (~(g04_b[6]));
   assign g08[7] = (~(g04_b[7]));

   assign t08[0] = (~(g04_b[0] & (t04_b[0] | t04_b[4])));		
   assign t08[1] = (~(g04_b[1] & (t04_b[1] | t04_b[5])));		
   assign t08[2] = (~(g04_b[2] & (t04_b[2] | t04_b[6])));		
   assign t08[3] = (~(g04_b[3] & (t04_b[3] | t04_b[7])));		
   assign t08[4] = (~(t04_b[4]));
   assign t08[5] = (~(t04_b[5]));
   assign t08[6] = (~(t04_b[6]));
   assign t08[7] = (~(t04_b[7]));
      
endmodule

