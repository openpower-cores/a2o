// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.





module lq_agen_loca(
   x_b,
   y_b,
   sum_0,
   sum_1
);
input [0:7]  x_b;		
input [0:7]  y_b;

output [0:7]    sum_0;

output [0:7]    sum_1;

wire [0:7]      h01;

wire [0:7]      h01_b;

wire [0:7]      x;

wire [0:7]      y;

wire [1:7]      g01_b;

wire [1:7]      t01_b;

wire [0:7]      p01;

wire [0:7]      p01_b;

wire [1:7]      g08_b;

wire [1:7]      g08;

wire [1:7]      g04_b;

wire [1:7]      g02;

wire [1:7]      t02;

wire [1:7]      t04_b;

wire [1:7]      t08;

wire [1:7]      t08_b;


tri_inv #(.WIDTH(8)) x_0 (.y(x[0:7]), .a(x_b[0:7]));

tri_inv #(.WIDTH(8)) y_0 (.y(y[0:7]), .a(y_b[0:7]));


tri_nand2 #(.WIDTH(7)) g01_b_1 (.y(g01_b[1:7]), .a(x[1:7]), .b(y[1:7]));

tri_nor2 #(.WIDTH(7)) t01_b_1 (.y(t01_b[1:7]), .a(x[1:7]), .b(y[1:7]));

tri_xnor2 #(.WIDTH(8)) p01_b_0 (.y(p01_b[0:7]), .a(x[0:7]), .b(y[0:7]));

tri_inv #(.WIDTH(8)) p01_0 (.y(p01[0:7]), .a(p01_b[0:7]));

tri_inv #(.WIDTH(8)) h01_0 (.y(h01[0:7]), .a(p01_b[0:7]));

tri_inv #(.WIDTH(8)) h01_b_0 (.y(h01_b[0:7]), .a(p01[0:7]));


tri_oai21 #(.WIDTH(6)) g02_1 (.y(g02[1:6]), .a0(t01_b[1:6]), .a1(g01_b[2:7]), .b0(g01_b[1:6]));






tri_inv g02_7 (.y(g02[7]), .a(g01_b[7]));

tri_nor2 #(.WIDTH(5)) t02_1 (.y(t02[1:5]), .a(t01_b[1:5]), .b(t01_b[2:6]));





tri_oai21 t02_6 (.y(t02[6]), .a0(t01_b[6]), .a1(t01_b[7]), .b0(g01_b[6]));

tri_inv t02_7 (.y(t02[7]), .a(t01_b[7]));

tri_aoi21 #(.WIDTH(5)) g04_b_1 (.y(g04_b[1:5]), .a0(t02[1:5]), .a1(g02[3:7]), .b0(g02[1:5]));





tri_inv #(.WIDTH(2)) g04_b_6 (.y(g04_b[6:7]), .a(g02[6:7]));


tri_nand2 #(.WIDTH(3)) t04_b_1 (.y(t04_b[1:3]), .a(t02[1:3]), .b(t02[3:5]));



tri_aoi21 #(.WIDTH(2)) t04_b_4 (.y(t04_b[4:5]), .a0(t02[4:5]), .a1(t02[6:7]), .b0(g02[4:5]));


tri_inv #(.WIDTH(2)) t04_b_6 (.y(t04_b[6:7]), .a(t02[6:7]));


tri_oai21 #(.WIDTH(3)) g08_1 (.y(g08[1:3]), .a0(t04_b[1:3]), .a1(g04_b[5:7]), .b0(g04_b[1:3]));



tri_inv #(.WIDTH(4)) g08_4 (.y(g08[4:7]), .a(g04_b[4:7]));




tri_oai21 #(.WIDTH(3)) t08_1 (.y(t08[1:3]), .a0(t04_b[1:3]), .a1(t04_b[5:7]), .b0(g04_b[1:3]));



tri_inv #(.WIDTH(4)) t08_4 (.y(t08[4:7]), .a(t04_b[4:7]));





tri_inv #(.WIDTH(7)) g08_b_1 (.y(g08_b[1:7]), .a(g08[1:7]));







tri_inv #(.WIDTH(7)) t08_b_1 (.y(t08_b[1:7]), .a(t08[1:7]));







tri_aoi22 #(.WIDTH(7)) sum_0_0 (.y(sum_0[0:6]), .a0(h01[0:6]), .a1(g08[1:7]), .b0(h01_b[0:6]), .b1(g08_b[1:7]));







tri_inv sum_0_7 (.y(sum_0[7]), .a(h01_b[7]));

tri_aoi22 #(.WIDTH(7)) sum_1_0 (.y(sum_1[0:6]), .a0(h01[0:6]), .a1(t08[1:7]), .b0(h01_b[0:6]), .b1(t08_b[1:7]));







tri_inv sum_1_7 (.y(sum_1[7]), .a(h01[7]));
   
endmodule

