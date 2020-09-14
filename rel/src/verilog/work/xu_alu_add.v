// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.


`include "tri_a2o.vh"
module xu_alu_add
(
   input [0:`NCLK_WIDTH-1]  nclk,
   inout                    vdd,
   inout                    gnd,
   
   input                    delay_lclkr_dc,
   input                    mpw1_dc_b,
   input                    mpw2_dc_b,
   input                    func_sl_force,
   input                    func_sl_thold_0_b,
   input                    sg_0,
   input                    scan_in,
   output                   scan_out,
   
   input                    ex1_act,
   input                    ex2_msb_64b_sel,
   input [0:`GPR_WIDTH/8-1]  dec_alu_ex1_add_rs1_inv,
   input                    dec_alu_ex2_add_ci,
   
   input [64-`GPR_WIDTH:63]  ex2_rs1,
   input [64-`GPR_WIDTH:63]  ex2_rs2,
   
   (* NO_MODIFICATION="TRUE" *)     
   output [64-`GPR_WIDTH:63] ex2_add_rt,		
   (* NO_MODIFICATION="TRUE" *)     
   output                   ex2_add_ovf,		
   output                   ex2_add_ca
);


   localparam                msb = 64-`GPR_WIDTH;
   wire [64-`GPR_WIDTH:63]   ex2_rs1_inv_b_q;		
   wire [64-`GPR_WIDTH:63]   ex1_rs1_inv;
   localparam               ex2_rs1_inv_b_offset = 0;
   localparam               scan_right = ex2_rs1_inv_b_offset + `GPR_WIDTH;
   wire [0:scan_right-1]    siv;
   wire [0:scan_right-1]    sov;
   wire [0:`NCLK_WIDTH-1]   ex1_rs0_inv_lclk;
   wire                     ex1_rs0_inv_d1clk;
   wire                     ex1_rs0_inv_d2clk;
   wire [64-`GPR_WIDTH:63]   ex2_rs1_b;
   wire [64-`GPR_WIDTH:63]   ex2_rs2_b;
   wire [64-`GPR_WIDTH:63]   ex2_x_b;
   wire [64-`GPR_WIDTH:63]   ex2_y;
   wire [64-`GPR_WIDTH:63]   ex2_y_b;
   wire                     ex2_aop_00;
   wire                     ex2_aop_32;
   wire                     ex2_bop_00;
   wire                     ex2_bop_32;
   (* NO_MODIFICATION="TRUE" *) 
   wire                     ex2_sgn00_32;
   wire                     ex2_sgn11_32;
   (* NO_MODIFICATION="TRUE" *) 
   wire                     ex2_sgn00_64;
   wire                     ex2_sgn11_64;
   wire                     ex2_cout_32;
   wire                     ex2_cout_00;
   (* NO_MODIFICATION="TRUE" *) 
   wire                     ex2_ovf32_00_b;
   wire                     ex2_ovf32_11_b;
   (* NO_MODIFICATION="TRUE" *) 
   wire                     ex2_ovf64_00_b;
   wire                     ex2_ovf64_11_b;
   wire [64-`GPR_WIDTH:63]   ex2_add_rslt;
   wire [64-`GPR_WIDTH:63]   ex2_rs1_inv_q;

   generate 
   genvar i;
      for (i=0; i<`GPR_WIDTH; i=i+1) begin : ex1_rs1_inv_gen
         assign ex1_rs1_inv[i] = dec_alu_ex1_add_rs1_inv[i % (`GPR_WIDTH/8)];
      end
   endgenerate

   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/REPOWER_MODE=/NONE/CUE_BTR=/INV_X3M_A12TH/   " *)
   assign ex2_rs1_inv_q = (~ex2_rs1_inv_b_q);

   assign ex2_rs1_b = (~ex2_rs1);
   assign ex2_rs2_b = (~ex2_rs2);

   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/REPOWER_MODE=/NONE/CUE_BTR=/XOR2_X3M_A12TH/  " *)
   assign ex2_x_b = ex2_rs1_b ^ ex2_rs1_inv_q;		

   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/REPOWER_MODE=/NONE/CUE_BTR=/INV_X1M_A12TH/   " *)
   assign ex2_y = (~ex2_rs2_b);		
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/REPOWER_MODE=/NONE/CUE_BTR=/INV_X3M_A12TH/   " *)
   assign ex2_y_b = (~ex2_y);		

   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/CUE_BTR=/INV_X0P5M_A12TH/   " *)
   assign ex2_aop_00 = (~ex2_x_b[msb]);
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/CUE_BTR=/INV_X0P5M_A12TH/   " *)
   assign ex2_aop_32 = (~ex2_x_b[32]);
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/CUE_BTR=/INV_X0P5M_A12TH/   " *)
   assign ex2_bop_00 = (~ex2_y_b[msb]);
   (* BLOCK_DATA="LOGIC_STYLE=/DIRECT/CUE_BTR=/INV_X0P5M_A12TH/   " *)
   assign ex2_bop_32 = (~ex2_y_b[32]);


   tri_st_add csa(
      .x_b(ex2_x_b),
      .y_b(ex2_y_b),
      .ci(dec_alu_ex2_add_ci),
      .sum(ex2_add_rslt),
      .cout_32(ex2_cout_32),
      .cout_0(ex2_cout_00)
   );

   assign ex2_add_rt = ex2_add_rslt;

   assign ex2_sgn00_32 = (~ex2_msb_64b_sel) & (~ex2_aop_32) & (~ex2_bop_32);
   assign ex2_sgn11_32 = (~ex2_msb_64b_sel) &   ex2_aop_32  &   ex2_bop_32;
   assign ex2_sgn00_64 =   ex2_msb_64b_sel  & (~ex2_aop_00) & (~ex2_bop_00);
   assign ex2_sgn11_64 =   ex2_msb_64b_sel  &   ex2_aop_00  &   ex2_bop_00;

   assign ex2_ovf32_00_b = (~(ex2_add_rslt[32] & ex2_sgn00_32));
   assign ex2_ovf32_11_b = (~((~ex2_add_rslt[32]) & ex2_sgn11_32));
   assign ex2_ovf64_00_b = (~(ex2_add_rslt[msb] & ex2_sgn00_64));
   assign ex2_ovf64_11_b = (~((~ex2_add_rslt[msb]) & ex2_sgn11_64));

   assign ex2_add_ovf = (~(ex2_ovf64_00_b & ex2_ovf64_11_b & ex2_ovf32_00_b & ex2_ovf32_11_b));


   assign ex2_add_ca = (ex2_msb_64b_sel == 1'b1) ? ex2_cout_00 : ex2_cout_32;

   tri_lcbnd ex1_rs0_inv_lcb(
      .vd(vdd),
      .gd(gnd),
      .act(ex1_act),
      .nclk(nclk),
      .force_t(func_sl_force),
      .thold_b(func_sl_thold_0_b),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .sg(sg_0),
      .lclk(ex1_rs0_inv_lclk),
      .d1clk(ex1_rs0_inv_d1clk),
      .d2clk(ex1_rs0_inv_d2clk)
   );

   tri_inv_nlats #(.WIDTH(`GPR_WIDTH), .BTR("NLI0001_X1_A12TH"), .INIT(0)) ex1_rs0_inv_b_latch(
      .vd(vdd),
      .gd(gnd),
      .lclk(ex1_rs0_inv_lclk),
      .d1clk(ex1_rs0_inv_d1clk),
      .d2clk(ex1_rs0_inv_d2clk),
      .scanin(siv[ex2_rs1_inv_b_offset:ex2_rs1_inv_b_offset + `GPR_WIDTH - 1]),
      .scanout(sov[ex2_rs1_inv_b_offset:ex2_rs1_inv_b_offset + `GPR_WIDTH - 1]),
      .d(ex1_rs1_inv),
      .qb(ex2_rs1_inv_b_q)
   );

   assign siv[0:scan_right-1] = {sov[1:scan_right-1], scan_in};
   assign scan_out = sov[0];
   

endmodule
