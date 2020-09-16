// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

module lq_agen_glbloc(
   x_b,
   y_b,
   g08,
   t08
);

input [0:7]     x_b;
input [0:7]     y_b;

output          g08;

output          t08;

wire [0:7]      g01;

wire [0:7]      t01;

wire [0:3]      g02_b;

wire [0:3]      t02_b;

wire [0:1]      g04;

wire [0:1]      t04;

wire            g08_b;

wire            t08_b;

//assign g01[0] = (~(x_b[0] | y_b[0]));
tri_nor2 #(.WIDTH(8)) g01_0 (.y(g01[0:7]), .a(x_b[0:7]), .b(y_b[0:7]));

//assign t01[0] = (~(x_b[0] & y_b[0]));
tri_nand2 #(.WIDTH(8)) t01_0 (.y(t01[0:7]), .a(x_b[0:7]), .b(y_b[0:7]));

//assign g02_b[0] = (~(g01[0] | (t01[0] & g01[1])));
tri_aoi21 g02_b_0 (.y(g02_b[0]), .a0(t01[0]), .a1(g01[1]), .b0(g01[0]));

//assign g02_b[1] = (~(g01[2] | (t01[2] & g01[3])));
tri_aoi21 g02_b_1 (.y(g02_b[1]), .a0(t01[2]), .a1(g01[3]), .b0(g01[2]));

//assign g02_b[2] = (~(g01[4] | (t01[4] & g01[5])));
tri_aoi21 g02_b_2 (.y(g02_b[2]), .a0(t01[4]), .a1(g01[5]), .b0(g01[4]));

//assign g02_b[3] = (~(g01[6] | (t01[6] & g01[7])));
tri_aoi21 g02_b_3 (.y(g02_b[3]), .a0(t01[6]), .a1(g01[7]), .b0(g01[6]));

//assign t02_b[0] = (~(t01[0] & t01[1]));
tri_nand2 t02_b_0 (.y(t02_b[0]), .a(t01[0]), .b(t01[1]));

//assign t02_b[1] = (~(t01[2] & t01[3]));
tri_nand2 t02_b_1 (.y(t02_b[1]), .a(t01[2]), .b(t01[3]));

//assign t02_b[2] = (~(t01[4] & t01[5]));
tri_nand2 t02_b_2 (.y(t02_b[2]), .a(t01[4]), .b(t01[5]));

//assign t02_b[3] = (~(t01[6] & t01[7]));
tri_nand2 t02_b_3 (.y(t02_b[3]), .a(t01[6]), .b(t01[7]));

//assign g04[0] = (~(g02_b[0] & (t02_b[0] | g02_b[1])));
tri_oai21 g04_0 (.y(g04[0]), .a0(t02_b[0]), .a1(g02_b[1]), .b0(g02_b[0]));

//assign g04[1] = (~(g02_b[2] & (t02_b[2] | g02_b[3])));
tri_oai21 g04_1 (.y(g04[1]), .a0(t02_b[2]), .a1(g02_b[3]), .b0(g02_b[2]));

//assign t04[0] = (~(t02_b[0] | t02_b[1]));
tri_nor2 t04_0 (.y(t04[0]), .a(t02_b[0]), .b(t02_b[1]));

//assign t04[1] = (~(t02_b[2] | t02_b[3]));
tri_nor2 t04_1 (.y(t04[1]), .a(t02_b[2]), .b(t02_b[3]));

//assign g08_b = (~(g04[0] | (t04[0] & g04[1])));
tri_aoi21 g08_b_0 (.y(g08_b), .a0(t04[0]), .a1(g04[1]), .b0(g04[0]));

//assign t08_b = (~((t04[0] & t04[1])));
tri_nand2 t08_b_0 (.y(t08_b), .a(t04[0]), .b(t04[1]));

//assign g08 = (~(g08_b));		// output
tri_inv g08_0 (.y(g08), .a(g08_b));

//assign t08 = (~(t08_b));		// output
tri_inv t08_0 (.y(t08), .a(t08_b));

endmodule
