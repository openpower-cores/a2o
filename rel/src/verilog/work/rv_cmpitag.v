// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns


module rv_cmpitag(
		  vld,
		  itag,
		  vld_ary,
		  itag_ary,
		  abort,
		  hit_clear,
		  hit_abort
		  );
`include "tri_a2o.vh"
   parameter                     q_itag_busses_g = 7;
   input [0:`THREADS-1]           vld;
   input [0:`ITAG_SIZE_ENC-1] 	  itag;
   input [0:(q_itag_busses_g*`THREADS)-1] vld_ary;
   input [0:(q_itag_busses_g*`ITAG_SIZE_ENC)-1] itag_ary;
   input [0:q_itag_busses_g-1] 			abort;
   output 					hit_clear;
   output 					hit_abort;
   
   
   wire [0:7] 					valid;
   wire [0:7] 					itag_xor[0:7];
   wire [0:3] 					itag_andl10_b;
   wire [0:3] 					itag_andl11_b;
   wire [0:3] 					itag_andl12_b;
   wire [0:3] 					itag_andl13_b;
   wire [0:3] 					itag_andl14_b;
   wire [0:3] 					itag_andl15_b;
   wire [0:3] 					itag_andl16_b;
   wire [0:3] 					itag_andl17_b;
   
   wire [0:1] 					itag_andl20;
   wire [0:1] 					itag_andl21;
   wire [0:1] 					itag_andl22;
   wire [0:1] 					itag_andl23;
   wire [0:1] 					itag_andl24;
   wire [0:1] 					itag_andl25;
   wire [0:1] 					itag_andl26;
   wire [0:1] 					itag_andl27;
   
   wire [0:7] 					itagc_andl3_b;
   wire [0:3] 					itagc_orl4;
   wire [0:1] 					itagc_orl5_b;
   wire 					itagc_orl6;
   
   wire [0:7] 					itaga_andl3_b;
   wire [0:3] 					itaga_orl4;
   wire [0:1] 					itaga_orl5_b;
   wire 					itaga_orl6;

   wire [0:7] 					itag_abort;
   wire [0:7] 					itag_abort_b;
   
 (* analysis_not_referenced="true" *)
   wire                                         unused;

   
   generate
      begin : xhdl0
         genvar                        n;
         for (n = 0; n <= 5; n = n + 1)
           begin : q_valid_gen
              assign valid[n] = |(vld_ary[n*`THREADS:n*`THREADS+`THREADS-1] & vld);

	      assign itag_xor[n] = {~(itag ^ itag_ary[n*`ITAG_SIZE_ENC:n*`ITAG_SIZE_ENC+`ITAG_SIZE_ENC-1]), valid[n]};
           end
      end
   endgenerate
   

   assign itag_abort[0:5] = abort[0:5];
   
   generate
      if (q_itag_busses_g == 6)
        begin : l1xor_gen6
           assign itag_xor[6] = {8{1'b0}};
           assign itag_xor[7] = {8{1'b0}};
           assign valid[6] = 1'b0;
           assign valid[7] = 1'b0;
           assign itag_abort[6] = 1'b0;
           assign itag_abort[7] = 1'b0;
        end
   endgenerate
   generate
      if (q_itag_busses_g == 7)
        begin : l1xor_gen7
	   assign itag_xor[6] = {~(itag ^ itag_ary[6*`ITAG_SIZE_ENC:6*`ITAG_SIZE_ENC+`ITAG_SIZE_ENC-1]), valid[6]};
           assign itag_xor[7] = {8{1'b0}};
           assign valid[6] = |(vld_ary[6*`THREADS:6*`THREADS+`THREADS-1] & vld);	   
           assign valid[7] = 1'b0;
	   assign itag_abort[6] = abort[6];
           assign itag_abort[7] = 1'b0;

           assign unused = valid[7] ;
        end
   endgenerate
   generate
      if (q_itag_busses_g == 8)
        begin : l1xor_gen8
	   assign itag_xor[6] = {~(itag ^ itag_ary[6*`ITAG_SIZE_ENC:6*`ITAG_SIZE_ENC+`ITAG_SIZE_ENC-1]), valid[6]};
	   assign itag_xor[7] = {~(itag ^ itag_ary[7*`ITAG_SIZE_ENC:7*`ITAG_SIZE_ENC+`ITAG_SIZE_ENC-1]), valid[7]};
           
	   assign valid[6] = |(vld_ary[6*`THREADS:6*`THREADS+`THREADS-1] & vld);
	   assign valid[7] = |(vld_ary[7*`THREADS:7*`THREADS+`THREADS-1] & vld);

	   assign itag_abort[6] = abort[6];
           assign itag_abort[7] = abort[7];
	   
        end
   endgenerate

   assign itag_abort_b = ~itag_abort;
   
   
   assign itag_andl10_b[0] = ~(itag_xor[0][0] & itag_xor[0][1]);
   assign itag_andl10_b[1] = ~(itag_xor[0][2] & itag_xor[0][3]);
   assign itag_andl10_b[2] = ~(itag_xor[0][4] & itag_xor[0][5]);
   assign itag_andl10_b[3] = ~(itag_xor[0][6] & itag_xor[0][7]);
   
   assign itag_andl11_b[0] = ~(itag_xor[1][0] & itag_xor[1][1]);
   assign itag_andl11_b[1] = ~(itag_xor[1][2] & itag_xor[1][3]);
   assign itag_andl11_b[2] = ~(itag_xor[1][4] & itag_xor[1][5]);
   assign itag_andl11_b[3] = ~(itag_xor[1][6] & itag_xor[1][7]);
   
   assign itag_andl12_b[0] = ~(itag_xor[2][0] & itag_xor[2][1]);
   assign itag_andl12_b[1] = ~(itag_xor[2][2] & itag_xor[2][3]);
   assign itag_andl12_b[2] = ~(itag_xor[2][4] & itag_xor[2][5]);
   assign itag_andl12_b[3] = ~(itag_xor[2][6] & itag_xor[2][7]);
   
   assign itag_andl13_b[0] = ~(itag_xor[3][0] & itag_xor[3][1]);
   assign itag_andl13_b[1] = ~(itag_xor[3][2] & itag_xor[3][3]);
   assign itag_andl13_b[2] = ~(itag_xor[3][4] & itag_xor[3][5]);
   assign itag_andl13_b[3] = ~(itag_xor[3][6] & itag_xor[3][7]);
   
   assign itag_andl14_b[0] = ~(itag_xor[4][0] & itag_xor[4][1]);
   assign itag_andl14_b[1] = ~(itag_xor[4][2] & itag_xor[4][3]);
   assign itag_andl14_b[2] = ~(itag_xor[4][4] & itag_xor[4][5]);
   assign itag_andl14_b[3] = ~(itag_xor[4][6] & itag_xor[4][7]);
   
   assign itag_andl15_b[0] = ~(itag_xor[5][0] & itag_xor[5][1]);
   assign itag_andl15_b[1] = ~(itag_xor[5][2] & itag_xor[5][3]);
   assign itag_andl15_b[2] = ~(itag_xor[5][4] & itag_xor[5][5]);
   assign itag_andl15_b[3] = ~(itag_xor[5][6] & itag_xor[5][7]);
   
   assign itag_andl16_b[0] = ~(itag_xor[6][0] & itag_xor[6][1]);
   assign itag_andl16_b[1] = ~(itag_xor[6][2] & itag_xor[6][3]);
   assign itag_andl16_b[2] = ~(itag_xor[6][4] & itag_xor[6][5]);
   assign itag_andl16_b[3] = ~(itag_xor[6][6] & itag_xor[6][7]);
   
   assign itag_andl17_b[0] = ~(itag_xor[7][0] & itag_xor[7][1]);
   assign itag_andl17_b[1] = ~(itag_xor[7][2] & itag_xor[7][3]);
   assign itag_andl17_b[2] = ~(itag_xor[7][4] & itag_xor[7][5]);
   assign itag_andl17_b[3] = ~(itag_xor[7][6] & itag_xor[7][7]);
   
   assign itag_andl20[0] = ~(itag_andl10_b[0] | itag_andl10_b[1]);
   assign itag_andl20[1] = ~(itag_andl10_b[2] | itag_andl10_b[3]);
   
   assign itag_andl21[0] = ~(itag_andl11_b[0] | itag_andl11_b[1]);
   assign itag_andl21[1] = ~(itag_andl11_b[2] | itag_andl11_b[3]);
   
   assign itag_andl22[0] = ~(itag_andl12_b[0] | itag_andl12_b[1]);
   assign itag_andl22[1] = ~(itag_andl12_b[2] | itag_andl12_b[3]);
   
   assign itag_andl23[0] = ~(itag_andl13_b[0] | itag_andl13_b[1]);
   assign itag_andl23[1] = ~(itag_andl13_b[2] | itag_andl13_b[3]);
   
   assign itag_andl24[0] = ~(itag_andl14_b[0] | itag_andl14_b[1]);
   assign itag_andl24[1] = ~(itag_andl14_b[2] | itag_andl14_b[3]);
   
   assign itag_andl25[0] = ~(itag_andl15_b[0] | itag_andl15_b[1]);
   assign itag_andl25[1] = ~(itag_andl15_b[2] | itag_andl15_b[3]);
   
   assign itag_andl26[0] = ~(itag_andl16_b[0] | itag_andl16_b[1]);
   assign itag_andl26[1] = ~(itag_andl16_b[2] | itag_andl16_b[3]);
   
   assign itag_andl27[0] = ~(itag_andl17_b[0] | itag_andl17_b[1]);
   assign itag_andl27[1] = ~(itag_andl17_b[2] | itag_andl17_b[3]);
   
   assign itagc_andl3_b[0] = ~(itag_andl20[0] & itag_andl20[1] & itag_abort_b[0]);
   assign itagc_andl3_b[1] = ~(itag_andl21[0] & itag_andl21[1] & itag_abort_b[1]);
   assign itagc_andl3_b[2] = ~(itag_andl22[0] & itag_andl22[1] & itag_abort_b[2]);
   assign itagc_andl3_b[3] = ~(itag_andl23[0] & itag_andl23[1] & itag_abort_b[3]);
   assign itagc_andl3_b[4] = ~(itag_andl24[0] & itag_andl24[1] & itag_abort_b[4]);
   assign itagc_andl3_b[5] = ~(itag_andl25[0] & itag_andl25[1] & itag_abort_b[5]);
   assign itagc_andl3_b[6] = ~(itag_andl26[0] & itag_andl26[1] & itag_abort_b[6]);
   assign itagc_andl3_b[7] = ~(itag_andl27[0] & itag_andl27[1] & itag_abort_b[7]);
   
   assign itaga_andl3_b[0] = ~(itag_andl20[0] & itag_andl20[1] & itag_abort[0]);
   assign itaga_andl3_b[1] = ~(itag_andl21[0] & itag_andl21[1] & itag_abort[1]);
   assign itaga_andl3_b[2] = ~(itag_andl22[0] & itag_andl22[1] & itag_abort[2]);
   assign itaga_andl3_b[3] = ~(itag_andl23[0] & itag_andl23[1] & itag_abort[3]);
   assign itaga_andl3_b[4] = ~(itag_andl24[0] & itag_andl24[1] & itag_abort[4]);
   assign itaga_andl3_b[5] = ~(itag_andl25[0] & itag_andl25[1] & itag_abort[5]);
   assign itaga_andl3_b[6] = ~(itag_andl26[0] & itag_andl26[1] & itag_abort[6]);
   assign itaga_andl3_b[7] = ~(itag_andl27[0] & itag_andl27[1] & itag_abort[7]);
   
   assign itagc_orl4[0] = ~(itagc_andl3_b[0] & itagc_andl3_b[1]);
   assign itagc_orl4[1] = ~(itagc_andl3_b[2] & itagc_andl3_b[3]);
   assign itagc_orl4[2] = ~(itagc_andl3_b[4] & itagc_andl3_b[5]);
   assign itagc_orl4[3] = ~(itagc_andl3_b[6] & itagc_andl3_b[7]);
   
   assign itagc_orl5_b[0] = ~(itagc_orl4[0] | itagc_orl4[1]);
   assign itagc_orl5_b[1] = ~(itagc_orl4[2] | itagc_orl4[3]);
   
   assign itagc_orl6 = ~(itagc_orl5_b[0] & itagc_orl5_b[1]);
   
   assign hit_clear = itagc_orl6;

   assign itaga_orl4[0] = ~(itaga_andl3_b[0] & itaga_andl3_b[1]);
   assign itaga_orl4[1] = ~(itaga_andl3_b[2] & itaga_andl3_b[3]);
   assign itaga_orl4[2] = ~(itaga_andl3_b[4] & itaga_andl3_b[5]);
   assign itaga_orl4[3] = ~(itaga_andl3_b[6] & itaga_andl3_b[7]);
   
   assign itaga_orl5_b[0] = ~(itaga_orl4[0] | itaga_orl4[1]);
   assign itaga_orl5_b[1] = ~(itaga_orl4[2] | itaga_orl4[3]);
   
   assign itaga_orl6 = ~(itaga_orl5_b[0] & itaga_orl5_b[1]);
   
   assign hit_abort = itaga_orl6;

endmodule 


