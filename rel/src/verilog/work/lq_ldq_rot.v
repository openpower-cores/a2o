// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns



`include "tri_a2o.vh"



module lq_ldq_rot(
   ldq_rel1_stg_act,
   ldq_rel1_rot_sel1,
   ldq_rel1_rot_sel2,
   ldq_rel1_rot_sel3,
   ldq_rel1_data,
   ldq_rel1_opsize,
   ldq_rel1_byte_swap,
   ldq_rel1_algebraic,
   ldq_rel1_algebraic_sel,
   ldq_rel1_gpr_val,
   ldq_rel1_dvc1_en,
   ldq_rel1_dvc2_en,
   ldq_rel2_thrd_id,
   ctl_lsq_spr_dvc1_dbg,
   ctl_lsq_spr_dvc2_dbg,
   ctl_lsq_spr_dbcr2_dvc1be,
   ctl_lsq_spr_dbcr2_dvc1m,
   ctl_lsq_spr_dbcr2_dvc2be,
   ctl_lsq_spr_dbcr2_dvc2m,
   ldq_rel2_rot_data,
   ldq_rel2_dvc,
   vdd,
   gnd,
   nclk,
   sg_0,
   func_sl_thold_0_b,
   func_sl_force,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   scan_in,
   scan_out
);


input                               ldq_rel1_stg_act;
                                    
input [0:7]                         ldq_rel1_rot_sel1;
input [0:7]                         ldq_rel1_rot_sel2;
input [0:7]                         ldq_rel1_rot_sel3;
input [0:127]                       ldq_rel1_data;
                                    
input [0:2]                         ldq_rel1_opsize;
input                               ldq_rel1_byte_swap;
input                               ldq_rel1_algebraic;
input [0:3]                         ldq_rel1_algebraic_sel;
input                               ldq_rel1_gpr_val;
input                               ldq_rel1_dvc1_en;
input                               ldq_rel1_dvc2_en;
input [0:`THREADS-1]                ldq_rel2_thrd_id;

input [64-(2**`GPR_WIDTH_ENC):63]   ctl_lsq_spr_dvc1_dbg;
input [64-(2**`GPR_WIDTH_ENC):63]   ctl_lsq_spr_dvc2_dbg;
input [0:8*`THREADS-1]              ctl_lsq_spr_dbcr2_dvc1be;
input [0:2*`THREADS-1]              ctl_lsq_spr_dbcr2_dvc1m;
input [0:8*`THREADS-1]              ctl_lsq_spr_dbcr2_dvc2be;
input [0:2*`THREADS-1]              ctl_lsq_spr_dbcr2_dvc2m;

output [0:127]                      ldq_rel2_rot_data;
output [0:1]                        ldq_rel2_dvc;
                                    

                       
inout                               vdd;


inout                               gnd;

(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

input [0:`NCLK_WIDTH-1]             nclk;
input                               sg_0;
input                               func_sl_thold_0_b;
input                               func_sl_force;
input                               d_mode_dc;
input                               delay_lclkr_dc;
input                               mpw1_dc_b;
input                               mpw2_dc_b;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input                               scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output                              scan_out;



wire [0:127]                        rel1_data_swzl;
wire [0:127]                        rel1_rot_data;
wire [0:15]                         be_byte_bit0;
wire [0:15]                         le_byte_bit0;
wire [0:15]                         rel1_alg_byte;
wire                                rel1_alg_bit;
wire [0:4]                          rel1_1hot_opsize;
wire [0:7]                          rel1_byte_mask;
wire [0:((2**`GPR_WIDTH_ENC)-1)/8]  rel2_byte_mask_d;
wire [0:((2**`GPR_WIDTH_ENC)-1)/8]  rel2_byte_mask_q;
wire [0:15]                         rel1_bittype_mask;
wire [0:127]                        rel1_optype_mask;
wire [0:127]                        rel1_msk_data;
wire                                lh_algebraic;
wire                                lw_algebraic;
wire [0:47]                         lh_algebraic_msk;
wire [0:47]                         lw_algebraic_msk;
wire [0:47]                         rel1_algebraic_msk;
wire [0:127]                        rel1_algebraic_msk_data;
wire [0:127]                        rel1_swzl_data;
wire [0:127]                        rel2_rot_data_d;
wire [0:127]                        rel2_rot_data_q;
wire                                rel2_dvc1_val_d;
wire                                rel2_dvc1_val_q;
wire                                rel2_dvc2_val_d;
wire                                rel2_dvc2_val_q;
wire [0:((2**`GPR_WIDTH_ENC)/8)-1]  rel2_dvc1_cmp;
wire [0:((2**`GPR_WIDTH_ENC)/8)-1]  rel2_dvc2_cmp;
wire                                rel2_dvc1r_cmpr;
wire                                rel2_dvc2r_cmpr;
reg [0:1]                           spr_dbcr2_dvc1m;
reg [0:1]                           spr_dbcr2_dvc2m;
reg [8-(2**`GPR_WIDTH_ENC)/8:7]     spr_dbcr2_dvc1be;
reg [8-(2**`GPR_WIDTH_ENC)/8:7]     spr_dbcr2_dvc2be;
wire [0:7]                          ctl_lsq_spr_dbcr2_dvc1be_int[0:`THREADS-1];
wire [0:1]                          ctl_lsq_spr_dbcr2_dvc1m_int[0:`THREADS-1];
wire [0:7]                          ctl_lsq_spr_dbcr2_dvc2be_int[0:`THREADS-1];
wire [0:1]                          ctl_lsq_spr_dbcr2_dvc2m_int[0:`THREADS-1];

parameter                           rel2_byte_mask_offset = 0;
parameter                           rel2_rot_data_offset = rel2_byte_mask_offset + (((2**`GPR_WIDTH_ENC)-1)/8-0+1);
parameter                           rel2_dvc1_val_offset = rel2_rot_data_offset + 128;
parameter                           rel2_dvc2_val_offset = rel2_dvc1_val_offset + 1;
parameter                           scan_right = rel2_dvc2_val_offset + 1 - 1;

wire                                tiup;
wire [0:scan_right]                 siv;
wire [0:scan_right]                 sov;

assign tiup = 1'b1;


generate begin : sprTid
      genvar   tid;
      for (tid=0; tid<`THREADS; tid=tid+1) begin : sprTid
         assign ctl_lsq_spr_dbcr2_dvc1be_int[tid] = ctl_lsq_spr_dbcr2_dvc1be[8*tid:8*(tid+1)-1];
         assign ctl_lsq_spr_dbcr2_dvc1m_int[tid]  = ctl_lsq_spr_dbcr2_dvc1m[2*tid:2*(tid+1)-1];
         assign ctl_lsq_spr_dbcr2_dvc2be_int[tid] = ctl_lsq_spr_dbcr2_dvc2be[8*tid:8*(tid+1)-1];
         assign ctl_lsq_spr_dbcr2_dvc2m_int[tid]  = ctl_lsq_spr_dbcr2_dvc2m[2*tid:2*(tid+1)-1];
      end
   end
endgenerate

generate begin : swzlRelData
      genvar                            t;
      for (t=0; t<8; t=t+1) begin : swzlRelData
         assign rel1_data_swzl[t*16:(t*16)+15] = {ldq_rel1_data[t+0],  ldq_rel1_data[t+8],   ldq_rel1_data[t+16],  ldq_rel1_data[t+24], 
                                                  ldq_rel1_data[t+32], ldq_rel1_data[t+40],  ldq_rel1_data[t+48],  ldq_rel1_data[t+56], 
                                                  ldq_rel1_data[t+64], ldq_rel1_data[t+72],  ldq_rel1_data[t+80],  ldq_rel1_data[t+88], 
                                                  ldq_rel1_data[t+96], ldq_rel1_data[t+104], ldq_rel1_data[t+112], ldq_rel1_data[t+120]};
      end
   end
endgenerate

generate begin : rrotl
      genvar   bit;
      for (bit=0; bit<8; bit=bit+1) begin : rrotl
         tri_rot16_lu drotl(
            
            .rot_sel1(ldq_rel1_rot_sel1),
            .rot_sel2(ldq_rel1_rot_sel2),
            .rot_sel3(ldq_rel1_rot_sel3),
            .rot_data(rel1_data_swzl[bit*16:(bit*16)+15]),
            
            .data_rot(rel1_rot_data[bit*16:(bit*16)+15]),
            
            .vdd(vdd),
            .gnd(gnd)
         );
      end
   end
endgenerate


assign be_byte_bit0 = {ldq_rel1_data[0],  ldq_rel1_data[8],   ldq_rel1_data[16],  ldq_rel1_data[24], 
                       ldq_rel1_data[32], ldq_rel1_data[40],  ldq_rel1_data[48],  ldq_rel1_data[56], 
                       ldq_rel1_data[64], ldq_rel1_data[72],  ldq_rel1_data[80],  ldq_rel1_data[88], 
                       ldq_rel1_data[96], ldq_rel1_data[104], ldq_rel1_data[112], ldq_rel1_data[120]};

assign le_byte_bit0 = {ldq_rel1_data[120], ldq_rel1_data[112], ldq_rel1_data[104], ldq_rel1_data[96], 
                       ldq_rel1_data[88],  ldq_rel1_data[80],  ldq_rel1_data[72],  ldq_rel1_data[64], 
                       ldq_rel1_data[56],  ldq_rel1_data[48],  ldq_rel1_data[40],  ldq_rel1_data[32], 
                       ldq_rel1_data[24],  ldq_rel1_data[16],  ldq_rel1_data[8],   ldq_rel1_data[0]};

assign rel1_alg_byte = ldq_rel1_byte_swap ? le_byte_bit0 : be_byte_bit0;

assign rel1_alg_bit = (ldq_rel1_algebraic_sel == 4'b0000) ? rel1_alg_byte[0] : 
                      (ldq_rel1_algebraic_sel == 4'b0001) ? rel1_alg_byte[1] : 
                      (ldq_rel1_algebraic_sel == 4'b0010) ? rel1_alg_byte[2] : 
                      (ldq_rel1_algebraic_sel == 4'b0011) ? rel1_alg_byte[3] : 
                      (ldq_rel1_algebraic_sel == 4'b0100) ? rel1_alg_byte[4] : 
                      (ldq_rel1_algebraic_sel == 4'b0101) ? rel1_alg_byte[5] : 
                      (ldq_rel1_algebraic_sel == 4'b0110) ? rel1_alg_byte[6] : 
                      (ldq_rel1_algebraic_sel == 4'b0111) ? rel1_alg_byte[7] : 
                      (ldq_rel1_algebraic_sel == 4'b1000) ? rel1_alg_byte[8] : 
                      (ldq_rel1_algebraic_sel == 4'b1001) ? rel1_alg_byte[9] : 
                      (ldq_rel1_algebraic_sel == 4'b1010) ? rel1_alg_byte[10] : 
                      (ldq_rel1_algebraic_sel == 4'b1011) ? rel1_alg_byte[11] : 
                      (ldq_rel1_algebraic_sel == 4'b1100) ? rel1_alg_byte[12] : 
                      (ldq_rel1_algebraic_sel == 4'b1101) ? rel1_alg_byte[13] : 
                      (ldq_rel1_algebraic_sel == 4'b1110) ? rel1_alg_byte[14] : 
                      rel1_alg_byte[15];


assign rel1_1hot_opsize = (ldq_rel1_opsize == 3'b110) ? 5'b10000 : 		
                          (ldq_rel1_opsize == 3'b101) ? 5'b01000 : 		
                          (ldq_rel1_opsize == 3'b100) ? 5'b00100 : 		
                          (ldq_rel1_opsize == 3'b010) ? 5'b00010 : 		
                          (ldq_rel1_opsize == 3'b001) ? 5'b00001 : 		
                          5'b00000;

assign rel1_byte_mask = (8'h01 & {8{rel1_1hot_opsize[4]}}) | (8'h03 & {8{rel1_1hot_opsize[3]}}) | 
                        (8'h0F & {8{rel1_1hot_opsize[2]}}) | (8'hFF & {8{rel1_1hot_opsize[1]}});

assign rel2_byte_mask_d = rel1_byte_mask[(8 - ((2 ** `GPR_WIDTH_ENC)/8)):7];

assign rel1_bittype_mask = (16'h0001 & {16{rel1_1hot_opsize[4]}}) | (16'h0003 & {16{rel1_1hot_opsize[3]}}) | 
                           (16'h000F & {16{rel1_1hot_opsize[2]}}) | (16'h00FF & {16{rel1_1hot_opsize[1]}}) | 
                           (16'hFFFF & {16{rel1_1hot_opsize[0]}});

generate begin : maskGen
      genvar   bit;
      for (bit=0; bit <8; bit=bit+1) begin : maskGen
         assign rel1_optype_mask[bit*16:(bit*16)+15] = rel1_bittype_mask;
      end
   end
endgenerate

assign rel1_msk_data = rel1_rot_data & rel1_optype_mask;

assign lh_algebraic     = rel1_1hot_opsize[3] & ldq_rel1_algebraic;
assign lw_algebraic     = rel1_1hot_opsize[2] & ldq_rel1_algebraic;
assign lh_algebraic_msk =  {48{rel1_alg_bit}};
assign lw_algebraic_msk = {{32{rel1_alg_bit}}, 16'h0000};

assign rel1_algebraic_msk = (lh_algebraic_msk & {48{lh_algebraic}}) | (lw_algebraic_msk & {48{lw_algebraic}});

generate begin : swzlData
      genvar                            t;
      for (t=0; t<16; t=t+1) begin : swzlData
         assign rel1_swzl_data[t*8:(t*8)+7] = {rel1_msk_data[t],    rel1_msk_data[t+16], rel1_msk_data[t+32], rel1_msk_data[t+48], 
                                               rel1_msk_data[t+64], rel1_msk_data[t+80], rel1_msk_data[t+96], rel1_msk_data[t+112]};
      end
   end
endgenerate

assign rel1_algebraic_msk_data = {rel1_swzl_data[0:63], (rel1_swzl_data[64:111] | rel1_algebraic_msk), rel1_swzl_data[112:127]};
assign rel2_rot_data_d         = rel1_algebraic_msk_data;


assign rel2_dvc1_val_d = ldq_rel1_gpr_val & ldq_rel1_dvc1_en;
assign rel2_dvc2_val_d = ldq_rel1_gpr_val & ldq_rel1_dvc2_en;

generate begin : dvcCmpRl
      genvar                            t;
      for (t = 0; t <= ((2 ** `GPR_WIDTH_ENC)/8) - 1; t = t + 1) begin : dvcCmpRl
         assign rel2_dvc1_cmp[t] =    (rel2_rot_data_q[(128 - (2 ** `GPR_WIDTH_ENC)) + t * 8:(128 - (2 ** `GPR_WIDTH_ENC)) + ((t * 8) + 7)] == 
                                   ctl_lsq_spr_dvc1_dbg[(64 - (2 ** `GPR_WIDTH_ENC)) + t * 8:(64 - (2 ** `GPR_WIDTH_ENC)) + ((t * 8) + 7)]) & rel2_byte_mask_q[t];
         assign rel2_dvc2_cmp[t] =    (rel2_rot_data_q[(128 - (2 ** `GPR_WIDTH_ENC)) + t * 8:(128 - (2 ** `GPR_WIDTH_ENC)) + ((t * 8) + 7)] == 
                                   ctl_lsq_spr_dvc2_dbg[(64 - (2 ** `GPR_WIDTH_ENC)) + t * 8:(64 - (2 ** `GPR_WIDTH_ENC)) + ((t * 8) + 7)]) & rel2_byte_mask_q[t];
      end
   end
endgenerate


always @(*) begin: relTid
   reg [0:1]                         dvc1m;
   reg [0:1]                         dvc2m;
   reg [8-(2**`GPR_WIDTH_ENC)/8:7]   dvc1be;
   reg [8-(2**`GPR_WIDTH_ENC)/8:7]   dvc2be;
   
   (* analysis_not_referenced="true" *)
   
   integer                           tid;
   dvc1m = {2{1'b0}};
   dvc2m = {2{1'b0}};
   dvc1be = {(2**`GPR_WIDTH_ENC)/8{1'b0}};
   dvc2be = {(2**`GPR_WIDTH_ENC)/8{1'b0}};
   for (tid=0; tid<`THREADS; tid=tid+1) begin
      dvc1m  = (ctl_lsq_spr_dbcr2_dvc1m_int[tid]                             & {                    2{ldq_rel2_thrd_id[tid]}}) | dvc1m;
      dvc2m  = (ctl_lsq_spr_dbcr2_dvc2m_int[tid]                             & {                    2{ldq_rel2_thrd_id[tid]}}) | dvc2m;
      dvc1be = (ctl_lsq_spr_dbcr2_dvc1be_int[tid][8-(2**`GPR_WIDTH_ENC)/8:7] & {(2**`GPR_WIDTH_ENC)/8{ldq_rel2_thrd_id[tid]}}) | dvc1be;
      dvc2be = (ctl_lsq_spr_dbcr2_dvc2be_int[tid][8-(2**`GPR_WIDTH_ENC)/8:7] & {(2**`GPR_WIDTH_ENC)/8{ldq_rel2_thrd_id[tid]}}) | dvc2be;
   end
   spr_dbcr2_dvc1m  <= dvc1m;
   spr_dbcr2_dvc2m  <= dvc2m;
   spr_dbcr2_dvc1be <= dvc1be;
   spr_dbcr2_dvc2be <= dvc2be;
end


lq_spr_dvccmp #(.REGSIZE(2**`GPR_WIDTH_ENC)) dvc1Rel(
   .en(rel2_dvc1_val_q),
   .en00(1'b0),
   .cmp(rel2_dvc1_cmp),
   .dvcm(spr_dbcr2_dvc1m),
   .dvcbe(spr_dbcr2_dvc1be),
   .dvc_cmpr(rel2_dvc1r_cmpr)
);


lq_spr_dvccmp #(.REGSIZE(2**`GPR_WIDTH_ENC)) dvc2Rel(
   .en(rel2_dvc2_val_q),
   .en00(1'b0),
   .cmp(rel2_dvc2_cmp),
   .dvcm(spr_dbcr2_dvc2m),
   .dvcbe(spr_dbcr2_dvc2be),
   .dvc_cmpr(rel2_dvc2r_cmpr)
);


assign ldq_rel2_rot_data = rel2_rot_data_q;
assign ldq_rel2_dvc = {rel2_dvc1r_cmpr, rel2_dvc2r_cmpr};



tri_rlmreg_p #(.WIDTH((2**`GPR_WIDTH_ENC)/8), .INIT(0), .NEEDS_SRESET(1)) rel2_byte_mask_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ldq_rel1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel2_byte_mask_offset:rel2_byte_mask_offset + ((2**`GPR_WIDTH_ENC)/8) - 1]),
   .scout(sov[rel2_byte_mask_offset:rel2_byte_mask_offset + ((2**`GPR_WIDTH_ENC)/8) - 1]),
   .din(rel2_byte_mask_d),
   .dout(rel2_byte_mask_q)
);


tri_rlmreg_p #(.WIDTH(128), .INIT(0), .NEEDS_SRESET(1)) rel2_rot_data_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ldq_rel1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel2_rot_data_offset:rel2_rot_data_offset + 128 - 1]),
   .scout(sov[rel2_rot_data_offset:rel2_rot_data_offset + 128 - 1]),
   .din(rel2_rot_data_d),
   .dout(rel2_rot_data_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel2_dvc1_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel2_dvc1_val_offset]),
   .scout(sov[rel2_dvc1_val_offset]),
   .din(rel2_dvc1_val_d),
   .dout(rel2_dvc1_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel2_dvc2_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel2_dvc2_val_offset]),
   .scout(sov[rel2_dvc2_val_offset]),
   .din(rel2_dvc2_val_d),
   .dout(rel2_dvc2_val_q)
);

assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
assign scan_out = sov[0];
   
endmodule


