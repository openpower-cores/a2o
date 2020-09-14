// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.





module lq_agen_lo(
   x_b,
   y_b,
   sum,
   sum_arr,
   dir_ig_57_b
);

input [0:11]    x_b;		
input [0:11]    y_b;
input           dir_ig_57_b;		

output [0:11]   sum;

output [0:5]    sum_arr;

wire [0:11]     p01_b;

wire [0:11]     p01;

wire [1:11]     g01;

wire [1:10]     t01;

wire [0:11]     sum_x;

wire [0:11]     sum_b;

wire            sum_x_11_b;

wire [1:11]     g12_x_b;

wire [1:11]     g02_b;

wire [1:11]     g04;

wire [1:11]     c;

wire [1:7]      g12_y_b;

wire [1:3]      g12_z_b;

wire [1:9]      t02_b;

wire [1:7]      t04;


tri_nor2 #(.WIDTH(11)) g01_1 (.y(g01[1:11]), .a(x_b[1:11]), .b(y_b[1:11]));

tri_nand2 #(.WIDTH(10)) t01_1 (.y(t01[1:10]), .a(x_b[1:10]), .b(y_b[1:10]));

tri_xnor2 #(.WIDTH(12)) p01_b_1 (.y(p01_b[0:11]), .a(x_b[0:11]), .b(y_b[0:11]));

tri_inv #(.WIDTH(12)) p01_0 (.y(p01[0:11]), .a(p01_b[0:11]));


tri_xor2 #(.WIDTH(11)) sum_x_0 (.y(sum_x[0:10]), .a(p01[0:10]), .b(c[1:11]));

tri_inv sum_x_11_b_11 (.y(sum_x_11_b), .a(p01[11]));

tri_inv sum_x_11 (.y(sum_x[11]), .a(sum_x_11_b));


tri_inv #(.WIDTH(12)) sum_b_0 (.y(sum_b[0:11]), .a(sum_x[0:11]));

tri_inv #(.WIDTH(12)) sum_0 (.y(sum[0:11]), .a(sum_b[0:11]));

tri_inv #(.WIDTH(5)) sum_arr_0 (.y(sum_arr[0:4]), .a(sum_b[0:4]));





tri_nand2 sum_arr_5 (.y(sum_arr[5]), .a(sum_b[5]), .b(dir_ig_57_b));


tri_aoi21 #(.WIDTH(10)) g02_b_1 (.y(g02_b[1:10]), .a0(t01[1:10]), .a1(g01[2:11]), .b0(g01[1:10]));










tri_inv g02_b_11 (.y(g02_b[11]), .a(g01[11]));

tri_nand2 #(.WIDTH(9)) t02_b_1 (.y(t02_b[1:9]), .a(t01[1:9]), .b(t01[2:10]));









tri_oai21 #(.WIDTH(9)) g04_1 (.y(g04[1:9]), .a0(t02_b[1:9]), .a1(g02_b[3:11]), .b0(g02_b[1:9]));









tri_inv #(.WIDTH(2)) g04_10 (.y(g04[10:11]), .a(g02_b[10:11]));


tri_nor2 #(.WIDTH(7)) t04_1 (.y(t04[1:7]), .a(t02_b[1:7]), .b(t02_b[3:9]));







tri_inv g12_x_b_1 (.y(g12_x_b[1]), .a(g04[1]));

tri_nand2 g12_y_b_1 (.y(g12_y_b[1]), .a(t04[1]), .b(g04[5]));

tri_nand3 g12_z_b_1 (.y(g12_z_b[1]), .a(t04[1]), .b(t04[5]), .c(g04[9]));

tri_nand3 c_1 (.y(c[1]), .a(g12_x_b[1]), .b(g12_y_b[1]), .c(g12_z_b[1]));

tri_inv g12_x_b_2 (.y(g12_x_b[2]), .a(g04[2]));

tri_nand2 g12_y_b_2 (.y(g12_y_b[2]), .a(t04[2]), .b(g04[6]));

tri_nand3 g12_z_b_2 (.y(g12_z_b[2]), .a(t04[2]), .b(t04[6]), .c(g04[10]));

tri_nand3 c_2 (.y(c[2]), .a(g12_x_b[2]), .b(g12_y_b[2]), .c(g12_z_b[2]));

tri_inv g12_x_b_3 (.y(g12_x_b[3]), .a(g04[3]));

tri_nand2 g12_y_b_3 (.y(g12_y_b[3]), .a(t04[3]), .b(g04[7]));

tri_nand3 g12_z_b_3 (.y(g12_z_b[3]), .a(t04[3]), .b(t04[7]), .c(g04[11]));

tri_nand3 c_3 (.y(c[3]), .a(g12_x_b[3]), .b(g12_y_b[3]), .c(g12_z_b[3]));

tri_inv g12_x_b_4 (.y(g12_x_b[4]), .a(g04[4]));

tri_nand2 g12_y_b_4 (.y(g12_y_b[4]), .a(t04[4]), .b(g04[8]));

tri_nand2 c_4 (.y(c[4]), .a(g12_x_b[4]), .b(g12_y_b[4]));

tri_inv g12_x_b_5 (.y(g12_x_b[5]), .a(g04[5]));

tri_nand2 g12_y_b_5 (.y(g12_y_b[5]), .a(t04[5]), .b(g04[9]));

tri_nand2 c_5 (.y(c[5]), .a(g12_x_b[5]), .b(g12_y_b[5]));

tri_inv g12_x_b_6 (.y(g12_x_b[6]), .a(g04[6]));

tri_nand2 g12_y_b_6 (.y(g12_y_b[6]), .a(t04[6]), .b(g04[10]));

tri_nand2 c_6 (.y(c[6]), .a(g12_x_b[6]), .b(g12_y_b[6]));

tri_inv g12_x_b_7 (.y(g12_x_b[7]), .a(g04[7]));

tri_nand2 g12_y_b_7 (.y(g12_y_b[7]), .a(t04[7]), .b(g04[11]));

tri_nand2 c_7 (.y(c[7]), .a(g12_x_b[7]), .b(g12_y_b[7]));

tri_inv g12_x_b_8 (.y(g12_x_b[8]), .a(g04[8]));

tri_inv c_8 (.y(c[8]), .a(g12_x_b[8]));

tri_inv g12_x_b_9 (.y(g12_x_b[9]), .a(g04[9]));

tri_inv c_9 (.y(c[9]), .a(g12_x_b[9]));

tri_inv g12_x_b_10 (.y(g12_x_b[10]), .a(g04[10]));

tri_inv c_10 (.y(c[10]), .a(g12_x_b[10]));

tri_inv g12_x_b_11 (.y(g12_x_b[11]), .a(g04[11]));

tri_inv c_11 (.y(c[11]), .a(g12_x_b[11]));
   
endmodule

