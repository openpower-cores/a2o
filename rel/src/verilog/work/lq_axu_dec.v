// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.


`include "tri_a2o.vh"



module lq_axu_dec(
   lq_au_ex0_instr,
   lq_au_ex1_vld,
   lq_au_ex1_tid,
   lq_au_ex1_instr,
   lq_au_ex1_t3_p,
   au_lq_ex0_extload,
   au_lq_ex0_extstore,
   au_lq_ex0_mftgpr,
   au_lq_ex1_ldst_v,
   au_lq_ex1_st_v,
   au_lq_ex1_ldst_size,
   au_lq_ex1_ldst_update,
   au_lq_ex1_mftgpr,
   au_lq_ex1_mffgpr,
   au_lq_ex1_movedp,
   au_lq_ex1_ldst_tag,
   au_lq_ex1_ldst_dimm,
   au_lq_ex1_ldst_indexed,
   au_lq_ex1_ldst_forcealign,
   au_lq_ex1_ldst_forceexcept,
   au_lq_ex1_ldst_priv,
   au_lq_ex1_instr_type
);


input [0:31]                                                lq_au_ex0_instr;
input                                                       lq_au_ex1_vld;
input [0:`THREADS-1]                                        lq_au_ex1_tid;
input [0:31]                                                lq_au_ex1_instr;
input [0:`GPR_POOL_ENC-1]                                   lq_au_ex1_t3_p;

output                                                      au_lq_ex0_extload;
output                                                      au_lq_ex0_extstore;
output                                                      au_lq_ex0_mftgpr;
output                                                      au_lq_ex1_ldst_v;
output                                                      au_lq_ex1_st_v;
output [0:5]                                                au_lq_ex1_ldst_size;
output                                                      au_lq_ex1_ldst_update;
output                                                      au_lq_ex1_mftgpr;
output                                                      au_lq_ex1_mffgpr;
output                                                      au_lq_ex1_movedp;
output [0:`GPR_POOL_ENC+`THREADS_POOL_ENC+`AXU_SPARE_ENC-1] au_lq_ex1_ldst_tag;
output [0:15]                                               au_lq_ex1_ldst_dimm;
output                                                      au_lq_ex1_ldst_indexed;
output                                                      au_lq_ex1_ldst_forcealign;
output                                                      au_lq_ex1_ldst_forceexcept;
output                                                      au_lq_ex1_ldst_priv;
output [0:2]                                                au_lq_ex1_instr_type;

wire                                                        tiup;
wire                                                        tidn;
wire [0:5]                                                  pri_ex1;
wire [20:31]                                                sec_ex1;
wire                                                        isfu_dec_ex1;
wire                                                        tv;
wire                                                        av;
wire                                                        bv;
wire                                                        cv;
wire                                                        bubble3;
wire                                                        prebubble1;
wire                                                        ld_st_ex1;
wire                                                        st_ex1;
wire                                                        indexed;
wire                                                        update_form;
wire                                                        forcealign;
wire                                                        single_precision_ldst;
wire                                                        int_word_ldst;
wire                                                        sign_ext_ldst;
wire                                                        ldst_extpid;
wire                                                        io_port;
wire                                                        io_port_ext;
wire [0:5]                                                  size;
wire                                                        cr_writer;
wire                                                        mffgpr;
wire                                                        mftgpr;
wire                                                        fdiv_ex1;
wire                                                        fsqrt_ex1;
wire                                                        only_from_ucode;
wire                                                        final_fmul_uc;
wire                                                        only_graphics_mode;
wire                                                        ex0_movedp_instr;
wire                                                        ex0_mftgpr_instr;
                                                            
wire [0:2]                                                  iu_au_ex1_ucode_ext;
wire [0:4]                                                  ldst_tag_addr;
wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC+`AXU_SPARE_ENC-1]   ldst_tag;


(* analysis_not_referenced="true" *)
  
wire                                                        unused;

assign tiup = 1'b1;
assign tidn = 1'b0;

assign au_lq_ex0_extload  = (lq_au_ex0_instr[0:5] == 6'b011111) & (lq_au_ex0_instr[21:30] == 10'b1001011111);
assign au_lq_ex0_extstore = (lq_au_ex0_instr[0:5] == 6'b011111) & (lq_au_ex0_instr[21:30] == 10'b1011011111);

assign ex0_movedp_instr = lq_au_ex0_instr[20] & (lq_au_ex0_instr[21:24] == 4'b0001) & (lq_au_ex0_instr[26:30] == 5'b00011);
assign ex0_mftgpr_instr = (lq_au_ex0_instr[21:29] == 9'b101111111) | (lq_au_ex0_instr[21:30] == 10'b1011011101);
assign au_lq_ex0_mftgpr = (lq_au_ex0_instr[0:5] == 6'b011111) & (ex0_movedp_instr | ex0_mftgpr_instr);

assign pri_ex1[0:5]   = lq_au_ex1_instr[0:5];
assign sec_ex1[20:31] = lq_au_ex1_instr[20:31];























assign isfu_dec_ex1 = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & 
                        pri_ex1[4] & pri_ex1[5] & sec_ex1[20] & (~sec_ex1[21]) & 
                        (~sec_ex1[22]) & (~sec_ex1[23]) & (~sec_ex1[26]) & (~sec_ex1[27]) & 
                        (~sec_ex1[28]) & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & 
                        pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & 
                        sec_ex1[21] & (~sec_ex1[22]) & (~sec_ex1[23]) & sec_ex1[24] & sec_ex1[25] & 
                        sec_ex1[26] & sec_ex1[27] & sec_ex1[28]) | ((~pri_ex1[0]) & pri_ex1[1] & 
                        pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & 
                        sec_ex1[23] & sec_ex1[24] & (~sec_ex1[25]) & sec_ex1[26] & sec_ex1[27] & 
                        sec_ex1[28] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & 
                        pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & 
                        sec_ex1[24] & sec_ex1[25] & sec_ex1[26] & sec_ex1[27] & sec_ex1[28] & sec_ex1[29]) | 
                        ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & 
                        sec_ex1[21] & sec_ex1[24] & (~sec_ex1[25]) & sec_ex1[26] & (~sec_ex1[27]) & sec_ex1[28] & 
                        sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & 
                        pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & sec_ex1[26] & (~sec_ex1[27]) & 
                        sec_ex1[28] & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & 
                        pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[23]) & sec_ex1[24] & 
                        sec_ex1[26] & (~sec_ex1[27]) & sec_ex1[28] & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & 
                        pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & 
                        sec_ex1[24] & sec_ex1[26] & sec_ex1[28] & sec_ex1[29] & sec_ex1[30]) | (pri_ex1[0] & pri_ex1[1] & (~pri_ex1[2]));

assign tv = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & 
              sec_ex1[22] & (~sec_ex1[23]) & sec_ex1[24] & sec_ex1[26] & (~sec_ex1[27]) & sec_ex1[28] & 
              sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & 
              pri_ex1[5] & sec_ex1[20] & (~sec_ex1[23]) & (~sec_ex1[24]) & (~sec_ex1[26]) & (~sec_ex1[27]) & 
              (~sec_ex1[28]) & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & 
              pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & (~sec_ex1[23]) & sec_ex1[28]) | 
              (pri_ex1[0] & (~pri_ex1[2]) & (~pri_ex1[3]));

assign av = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[20] & 
             (~sec_ex1[22]) & (~sec_ex1[23]) & sec_ex1[24] & (~sec_ex1[26]) & (~sec_ex1[27]) & (~sec_ex1[28]) &
             sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & 
             pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & sec_ex1[23] & sec_ex1[24] & (~sec_ex1[25]) & sec_ex1[29]) | 
             ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & 
             (~sec_ex1[22]) & sec_ex1[23] & (~sec_ex1[27])) | (pri_ex1[0] & (~pri_ex1[2]) & pri_ex1[3]);

assign bv = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & 
             (~sec_ex1[25]) & (~sec_ex1[29])) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & 
             pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & sec_ex1[23] & sec_ex1[25] & sec_ex1[27] & sec_ex1[28] & sec_ex1[29]);

assign cv = 1'b0;

assign bubble3 = 1'b0;

assign prebubble1 = 1'b0;

assign ld_st_ex1 = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[20] & 
                    (~sec_ex1[21]) & (~sec_ex1[22]) & (~sec_ex1[23]) & (~sec_ex1[26]) & (~sec_ex1[27]) & 
                    (~sec_ex1[28]) & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & 
                    pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & (~sec_ex1[23]) & 
                    sec_ex1[24] & sec_ex1[25] & sec_ex1[26] & sec_ex1[27] & sec_ex1[28]) | ((~pri_ex1[0]) & 
                    pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & 
                    (~sec_ex1[22]) & sec_ex1[23] & sec_ex1[24] & (~sec_ex1[25]) & sec_ex1[26] & sec_ex1[27] & 
                    sec_ex1[28] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & 
                    pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & sec_ex1[24] & sec_ex1[25] & sec_ex1[26] & 
                    sec_ex1[27] & sec_ex1[28] & sec_ex1[29]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & 
                    pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & sec_ex1[24] & (~sec_ex1[25]) & sec_ex1[26] & (~sec_ex1[27]) & 
                    sec_ex1[28] & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & 
                    pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & sec_ex1[26] & (~sec_ex1[27]) & sec_ex1[28] & 
                    sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & 
                    pri_ex1[5] & sec_ex1[21] & (~sec_ex1[23]) & sec_ex1[24] & sec_ex1[26] & (~sec_ex1[27]) & sec_ex1[28] & 
                    sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & 
                    pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & sec_ex1[24] & sec_ex1[26] & sec_ex1[28] & sec_ex1[29] & 
                    sec_ex1[30]) | (pri_ex1[0] & pri_ex1[1] & (~pri_ex1[2]));

assign st_ex1 = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[20] & 
                 (~sec_ex1[21]) & (~sec_ex1[22]) & (~sec_ex1[23]) & sec_ex1[24] & (~sec_ex1[26]) & (~sec_ex1[27]) & 
                 (~sec_ex1[28]) & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & 
                 pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & sec_ex1[23] & sec_ex1[24] & sec_ex1[25] & 
                 sec_ex1[26] & sec_ex1[27] & sec_ex1[28] & sec_ex1[29]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & 
                 pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & sec_ex1[23] & sec_ex1[24] & 
                 (~sec_ex1[25]) & sec_ex1[26] & sec_ex1[27] & sec_ex1[28] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & 
                 pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & sec_ex1[23] & sec_ex1[24] & 
                 (~sec_ex1[25]) & sec_ex1[26] & (~sec_ex1[27]) & sec_ex1[28] & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & 
                 pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & 
                 sec_ex1[23] & sec_ex1[26] & (~sec_ex1[27]) & sec_ex1[28] & sec_ex1[29] & sec_ex1[30]) | (pri_ex1[0] & 
                 pri_ex1[1] & (~pri_ex1[2]) & pri_ex1[3]);

assign indexed = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & 
                  (~sec_ex1[25]) & sec_ex1[27] & sec_ex1[29]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & 
                  pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & (~sec_ex1[27])) | ((~pri_ex1[0]) & pri_ex1[1] & 
                  pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & sec_ex1[24] & sec_ex1[26] & 
                  (~sec_ex1[27]) & sec_ex1[28] & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & 
                  pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[20] & (~sec_ex1[23]) & (~sec_ex1[25]) & (~sec_ex1[26]) & 
                  (~sec_ex1[27]) & (~sec_ex1[28]) & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & 
                  pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & (~sec_ex1[23]) & sec_ex1[28] & (~sec_ex1[29]));

assign update_form = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & 
                      (~sec_ex1[22]) & sec_ex1[25] & sec_ex1[26] & (~sec_ex1[27]) & sec_ex1[28] & sec_ex1[29] & 
                      sec_ex1[30]) | (pri_ex1[0] & pri_ex1[1] & (~pri_ex1[2]) & pri_ex1[5]);

assign forcealign = 1'b0;

assign single_precision_ldst = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & 
                                (~sec_ex1[22]) & sec_ex1[28] & sec_ex1[29] & (~sec_ex1[30])) | ((~pri_ex1[0]) & pri_ex1[1] & 
                                pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & 
                                (~sec_ex1[24])) | (pri_ex1[0] & (~pri_ex1[2]) & (~pri_ex1[4]));

assign int_word_ldst = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[20] & 
                        (~sec_ex1[22]) & (~sec_ex1[23]) & (~sec_ex1[26]) & (~sec_ex1[27]) & (~sec_ex1[28]) & sec_ex1[29] & 
                        sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & 
                        sec_ex1[22] & sec_ex1[24] & sec_ex1[26] & (~sec_ex1[27]) & sec_ex1[28] & sec_ex1[29] & sec_ex1[30]) | 
                        ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & 
                        (~sec_ex1[22]) & (~sec_ex1[23]) & sec_ex1[28] & (~sec_ex1[29])) | ((~pri_ex1[0]) & pri_ex1[1] & 
                        pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[25]) & (~sec_ex1[29]));

assign sign_ext_ldst = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & 
                        (~sec_ex1[22]) & (~sec_ex1[23]) & sec_ex1[28] & (~sec_ex1[29]) & (~sec_ex1[30])) | 
                        ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[22] & 
                        (~sec_ex1[23]) & sec_ex1[24] & (~sec_ex1[25]));

assign ldst_extpid = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & 
                      (~sec_ex1[22]) & sec_ex1[24] & (~sec_ex1[25]) & sec_ex1[26] & sec_ex1[27] & sec_ex1[28] & 
                      sec_ex1[29] & sec_ex1[30]);

assign io_port = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[20] & 
                  (~sec_ex1[21]) & (~sec_ex1[22]) & (~sec_ex1[23]) & (~sec_ex1[26]) & (~sec_ex1[27]) & 
                  (~sec_ex1[28]) & sec_ex1[29] & sec_ex1[30]);

assign io_port_ext = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[20] & 
                      (~sec_ex1[21]) & (~sec_ex1[22]) & (~sec_ex1[23]) & (~sec_ex1[25]) & (~sec_ex1[26]) & 
                      (~sec_ex1[27]) & (~sec_ex1[28]) & sec_ex1[29] & sec_ex1[30]);

assign size[0] = 1'b0;

assign size[1] = 1'b0;

assign size[2] = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & 
                  (~sec_ex1[25]) & sec_ex1[27] & sec_ex1[29]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & 
                  pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & sec_ex1[24] & (~sec_ex1[27])) | 
                  (pri_ex1[0] & (~pri_ex1[2]) & pri_ex1[4]);

assign size[3] = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[22] & 
                  sec_ex1[24] & sec_ex1[26] & (~sec_ex1[27]) & sec_ex1[28] & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & 
                  pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & 
                  (~sec_ex1[24])) | (pri_ex1[0] & (~pri_ex1[2]) & (~pri_ex1[4]));

assign size[4] = 1'b0;

assign size[5] = 1'b0;

assign cr_writer = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[20] & 
                    (~sec_ex1[22]) & (~sec_ex1[23]) & (~sec_ex1[26]) & (~sec_ex1[27]) & (~sec_ex1[28]) & sec_ex1[29] & 
                    sec_ex1[30] & sec_ex1[31]);

assign mffgpr = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[20] & (~sec_ex1[21]) & 
                 (~sec_ex1[22]) & (~sec_ex1[23]) & (~sec_ex1[24]) & (~sec_ex1[26]) & (~sec_ex1[27]) & (~sec_ex1[28]) & 
                 sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & 
                 pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & (~sec_ex1[23]) & sec_ex1[24] & sec_ex1[25] & sec_ex1[26] & 
                 sec_ex1[27] & sec_ex1[28]);

assign mftgpr = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & 
                 (~sec_ex1[22]) & sec_ex1[23] & sec_ex1[24] & (~sec_ex1[25]) & sec_ex1[26] & sec_ex1[27] & sec_ex1[28] & 
                 (~sec_ex1[29]) & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & 
                 pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & sec_ex1[23] & sec_ex1[24] & sec_ex1[25] & sec_ex1[26] & 
                 sec_ex1[27] & sec_ex1[28] & sec_ex1[29]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & 
                 pri_ex1[4] & pri_ex1[5] & sec_ex1[20] & (~sec_ex1[21]) & (~sec_ex1[22]) & (~sec_ex1[23]) & sec_ex1[24] & 
                 (~sec_ex1[26]) & (~sec_ex1[27]) & (~sec_ex1[28]) & sec_ex1[29] & sec_ex1[30]);

assign fdiv_ex1 = 1'b0;

assign fsqrt_ex1 = 1'b0;

assign only_from_ucode = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & 
                          (~sec_ex1[22]) & sec_ex1[23] & sec_ex1[24] & (~sec_ex1[25]) & sec_ex1[26] & sec_ex1[27] & sec_ex1[28] & 
                          (~sec_ex1[29]) & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & 
                          pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & (~sec_ex1[23]) & sec_ex1[24] & sec_ex1[25] & sec_ex1[26] & 
                          sec_ex1[27] & sec_ex1[28]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & 
                          sec_ex1[21] & (~sec_ex1[22]) & sec_ex1[24] & sec_ex1[25] & sec_ex1[26] & sec_ex1[27] & sec_ex1[28] & sec_ex1[29]);

assign final_fmul_uc = 1'b0;

assign only_graphics_mode = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & 
                             (~sec_ex1[22]) & sec_ex1[23] & sec_ex1[24] & (~sec_ex1[25]) & sec_ex1[26] & sec_ex1[27] & sec_ex1[28] & 
                             (~sec_ex1[29]) & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & 
                             pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & (~sec_ex1[23]) & sec_ex1[24] & sec_ex1[25] & sec_ex1[26] & 
                             sec_ex1[27] & sec_ex1[28]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & 
                             sec_ex1[21] & (~sec_ex1[22]) & sec_ex1[24] & sec_ex1[25] & sec_ex1[26] & sec_ex1[27] & sec_ex1[28] & sec_ex1[29]);


generate
   if (`THREADS_POOL_ENC == 0) begin : tid1
      wire [0:`THREADS_POOL_ENC]                                   tid_enc;

      assign tid_enc = tidn;
      assign ldst_tag = {single_precision_ldst, int_word_ldst, sign_ext_ldst, lq_au_ex1_t3_p};		
      assign unused = tiup | |lq_au_ex0_instr[6:19] | lq_au_ex0_instr[31] | |lq_au_ex1_instr[11:15] | isfu_dec_ex1 |
                      tv | av | bv | cv | bubble3 | prebubble1 | io_port_ext | cr_writer | fdiv_ex1 | fsqrt_ex1 |
                      only_from_ucode | final_fmul_uc | only_graphics_mode | |iu_au_ex1_ucode_ext | |ldst_tag_addr |
                      |tid_enc | |lq_au_ex1_tid;
   end
endgenerate

generate
   if (`THREADS_POOL_ENC > 0) begin : tidMulti
      reg [0:`THREADS_POOL_ENC]                                   tid_enc;
      always @(*) begin: tidEnc
         reg [0:`THREADS_POOL_ENC-1]        enc;
         
         (* analysis_not_referenced="true" *)
         
         reg [0:31]                         tidVar;
         enc                                          = {`THREADS_POOL_ENC{1'b0}};
         tid_enc[`THREADS_POOL_ENC:`THREADS_POOL_ENC] = tidn;
         for (tidVar=0; tidVar<`THREADS; tidVar=tidVar+1) begin
            enc = (tidVar[32-`THREADS_POOL_ENC:31] & {`THREADS_POOL_ENC{lq_au_ex1_tid[tidVar]}}) | enc;
         end
         tid_enc[0:`THREADS_POOL_ENC-1] <= enc;
      end
      assign ldst_tag = {single_precision_ldst, int_word_ldst, sign_ext_ldst, lq_au_ex1_t3_p, tid_enc[0:`THREADS_POOL_ENC - 1]};		
      assign unused = tiup | |lq_au_ex0_instr[6:19] | lq_au_ex0_instr[31] | |lq_au_ex1_instr[11:15] | isfu_dec_ex1 |
                      tv | av | bv | cv | bubble3 | prebubble1 | io_port_ext | cr_writer | fdiv_ex1 | fsqrt_ex1 |
                      only_from_ucode | final_fmul_uc | only_graphics_mode | |iu_au_ex1_ucode_ext | |ldst_tag_addr |
                      tid_enc[`THREADS_POOL_ENC:`THREADS_POOL_ENC] | lq_au_ex1_tid[0];
   end
endgenerate

assign iu_au_ex1_ucode_ext[0:2] = {3{1'b0}};

assign ldst_tag_addr = ~mftgpr ? lq_au_ex1_instr[06:10] : lq_au_ex1_instr[16:20];

assign au_lq_ex1_ldst_v = ld_st_ex1 & lq_au_ex1_vld;
assign au_lq_ex1_st_v   = st_ex1;

assign au_lq_ex1_instr_type = 3'b001;		

assign au_lq_ex1_mffgpr = mffgpr;		
assign au_lq_ex1_mftgpr = mftgpr;		

assign au_lq_ex1_movedp = io_port & ld_st_ex1;

assign au_lq_ex1_ldst_size = size[0:5];
assign au_lq_ex1_ldst_tag  = ldst_tag;
assign au_lq_ex1_ldst_dimm        = lq_au_ex1_instr[16:31];
assign au_lq_ex1_ldst_indexed     = indexed;
assign au_lq_ex1_ldst_update      = update_form;		
assign au_lq_ex1_ldst_forcealign  = forcealign;
assign au_lq_ex1_ldst_forceexcept = 1'b0;

assign au_lq_ex1_ldst_priv = ldst_extpid;
   
endmodule

