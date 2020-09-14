// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.


`include "tri_a2o.vh"



module lq_agen(
   x,
   y,
   mode64,
   dir_ig_57_b,
   sum_non_erat,
   sum,
   sum_arr_dir01,
   sum_arr_dir23,
   sum_arr_dir45,
   sum_arr_dir67,
   way,
   rel4_dir_wr_val,
   ary_write_act_01,
   ary_write_act_23,
   ary_write_act_45,
   ary_write_act_67
);


input [0:63]        x;
input [0:63]        y;
input               mode64;		        
input               dir_ig_57_b;		
                    
output [0:63]       sum_non_erat;		
output [0:51]       sum;		        

output [52:57]      sum_arr_dir01;

output [52:57]      sum_arr_dir23;

output [52:57]      sum_arr_dir45;

output [52:57]      sum_arr_dir67;
                    
input [0:7]         way;		        
input               rel4_dir_wr_val;		
output              ary_write_act_01;	
output              ary_write_act_23;	
output              ary_write_act_45;	
output              ary_write_act_67;	


parameter           tiup = 1'b1;
parameter           tidn = 1'b0;
                    
wire [0:51]         sum_int;
wire [0:51]         sum_non_erat_b;
wire [0:51]         sum_erat;
wire [0:51]         sum_erat_b;
wire [0:51]         sum_0;
wire [0:51]         sum_1;
wire [1:7]          g08;
wire [1:6]          t08;
wire [1:7]          c64_b;
wire                addr_sel_64;

wire [0:63]         x_b;

wire [0:63]         y_b;

wire [52:57]        sum_arr;

wire [52:57]        sum_arr_lv1_0_b;

wire [52:57]        sum_arr_lv1_1_b;

assign addr_sel_64 = mode64;


tri_inv #(.WIDTH(64)) x_b_0 (.y(x_b[0:63]), .a(x[0:63]));

tri_inv #(.WIDTH(64)) y_b_0 (.y(y_b[0:63]), .a(y[0:63]));



lq_agen_loca loc_0(
   .x_b(x_b[0:7]),		    
   .y_b(y_b[0:7]),		    
   .sum_0(sum_0[0:7]),		
   .sum_1(sum_1[0:7])		
);

lq_agen_loca loc_1(
   .x_b(x_b[8:15]),		    
   .y_b(y_b[8:15]),		    
   .sum_0(sum_0[8:15]),		
   .sum_1(sum_1[8:15])		
);

lq_agen_loca loc_2(
   .x_b(x_b[16:23]),		
   .y_b(y_b[16:23]),		
   .sum_0(sum_0[16:23]),	
   .sum_1(sum_1[16:23])		
);

lq_agen_loca loc_3(
   .x_b(x_b[24:31]),		
   .y_b(y_b[24:31]),		
   .sum_0(sum_0[24:31]),	
   .sum_1(sum_1[24:31])		
);

lq_agen_loca loc_4(
   .x_b(x_b[32:39]),		
   .y_b(y_b[32:39]),		
   .sum_0(sum_0[32:39]),	
   .sum_1(sum_1[32:39])		
);

lq_agen_loca loc_5(
   .x_b(x_b[40:47]),		
   .y_b(y_b[40:47]),		
   .sum_0(sum_0[40:47]),	
   .sum_1(sum_1[40:47])		
);

lq_agen_locae loc_6(
   .x_b(x_b[48:55]),		
   .y_b(y_b[48:55]),		
   .sum_0(sum_0[48:51]),	
   .sum_1(sum_1[48:51])		
);


lq_agen_glbloc gclc_1(
   .x_b(x_b[8:15]),		    
   .y_b(y_b[8:15]),		    
   .g08(g08[1]),		    
   .t08(t08[1])		        
);

lq_agen_glbloc gclc_2(
   .x_b(x_b[16:23]),		
   .y_b(y_b[16:23]),		
   .g08(g08[2]),		    
   .t08(t08[2])		        
);

lq_agen_glbloc gclc_3(
   .x_b(x_b[24:31]),		
   .y_b(y_b[24:31]),		
   .g08(g08[3]),		    
   .t08(t08[3])		        
);

lq_agen_glbloc gclc_4(
   .x_b(x_b[32:39]),		
   .y_b(y_b[32:39]),		
   .g08(g08[4]),		    
   .t08(t08[4])		        
);

lq_agen_glbloc gclc_5(
   .x_b(x_b[40:47]),		
   .y_b(y_b[40:47]),		
   .g08(g08[5]),		    
   .t08(t08[5])		        
);

lq_agen_glbloc gclc_6(
   .x_b(x_b[48:55]),		
   .y_b(y_b[48:55]),		
   .g08(g08[6]),		    
   .t08(t08[6])		        
);

lq_agen_glbloc_lsb gclc_7(
   .x_b(x_b[56:63]),		
   .y_b(y_b[56:63]),		
   .g08(g08[7])		        
);


lq_agen_glbglb gc(
   .g08(g08[1:7]),		    
   .t08(t08[1:6]),		    
   .c64_b(c64_b[1:7])		
);


lq_agen_csmux fm_0(
   .ci_b(c64_b[1]),		    
   .sum_0(sum_0[0:7]),		
   .sum_1(sum_1[0:7]),		
   .sum(sum_int[0:7])		
);

lq_agen_csmux fm_1(
   .ci_b(c64_b[2]),		    
   .sum_0(sum_0[8:15]),		
   .sum_1(sum_1[8:15]),		
   .sum(sum_int[8:15])		
);

lq_agen_csmux fm_2(
   .ci_b(c64_b[3]),		        
   .sum_0(sum_0[16:23]),		
   .sum_1(sum_1[16:23]),		
   .sum(sum_int[16:23])		    
);

lq_agen_csmux fm_3(
   .ci_b(c64_b[4]),		        
   .sum_0(sum_0[24:31]),		
   .sum_1(sum_1[24:31]),		
   .sum(sum_int[24:31])		    
);

lq_agen_csmux fm_4(
   .ci_b(c64_b[5]),		        
   .sum_0(sum_0[32:39]),		
   .sum_1(sum_1[32:39]),		
   .sum(sum_int[32:39])		    
);

lq_agen_csmux fm_5(
   .ci_b(c64_b[6]),		        
   .sum_0(sum_0[40:47]),		
   .sum_1(sum_1[40:47]),		
   .sum(sum_int[40:47])		    
);
lq_agen_csmuxe fm_6(
   .ci_b(c64_b[7]),		        
   .sum_0(sum_0[48:51]),		
   .sum_1(sum_1[48:51]),		
   .sum(sum_int[48:51])		    
);

lq_agen_lo kog(
   .dir_ig_57_b(dir_ig_57_b),	
   .x_b(x_b[52:63]),		    
   .y_b(y_b[52:63]),		    
   .sum(sum_non_erat[52:63]),	
   .sum_arr(sum_arr[52:57])		
);

tri_inv #(.WIDTH(52)) sum_non_erat_b_0 (.y(sum_non_erat_b[0:51]), .a(sum_int[0:51]));

tri_inv #(.WIDTH(52)) sum_non_erat_0 (.y(sum_non_erat[0:51]), .a(sum_non_erat_b[0:51]));

tri_nand2 #(.WIDTH(32)) sum_erat_b_0 (.y(sum_erat_b[0:31]), .a(sum_int[0:31]), .b({32{addr_sel_64}}));

tri_inv #(.WIDTH(20)) sum_erat_b_32 (.y(sum_erat_b[32:51]), .a(sum_int[32:51]));

tri_inv #(.WIDTH(52)) sum_erat_0 (.y(sum_erat[0:51]), .a(sum_erat_b[0:51]));

assign sum = sum_erat;		


tri_inv #(.WIDTH(6)) sum_arr_lv1_1_b_52 (.y(sum_arr_lv1_1_b[52:57]), .a(sum_arr[52:57]));

tri_inv #(.WIDTH(6)) sum_arr_dir01_52 (.y(sum_arr_dir01[52:57]), .a(sum_arr_lv1_1_b[52:57]));

tri_inv #(.WIDTH(6)) sum_arr_dir45_52 (.y(sum_arr_dir45[52:57]), .a(sum_arr_lv1_1_b[52:57]));

tri_inv #(.WIDTH(6)) sum_arr_lv1_0_b_52 (.y(sum_arr_lv1_0_b[52:57]), .a(sum_arr[52:57]));

tri_inv #(.WIDTH(6)) sum_arr_dir23_52 (.y(sum_arr_dir23[52:57]), .a(sum_arr_lv1_0_b[52:57]));

tri_inv #(.WIDTH(6)) sum_arr_dir67_52 (.y(sum_arr_dir67[52:57]), .a(sum_arr_lv1_0_b[52:57]));


assign ary_write_act_01 = rel4_dir_wr_val & (way[0] | way[1]);
assign ary_write_act_23 = rel4_dir_wr_val & (way[2] | way[3]);
assign ary_write_act_45 = rel4_dir_wr_val & (way[4] | way[5]);
assign ary_write_act_67 = rel4_dir_wr_val & (way[6] | way[7]);

   
endmodule

