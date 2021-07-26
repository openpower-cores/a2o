// © IBM Corp. 2020
// Licensed under the Apache License, Version 2.0 (the "License"), as modified by
// the terms below; you may not use the files in this repository except in
// compliance with the License as modified.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Modified Terms:
//
//    1) For the purpose of the patent license granted to you in Section 3 of the
//    License, the "Work" hereby includes implementations of the work of authorship
//    in physical form.
//
//    2) Notwithstanding any terms to the contrary in the License, any licenses
//    necessary for implementation of the Work that are available from OpenPOWER
//    via the Power ISA End User License Agreement (EULA) are explicitly excluded
//    hereunder, and may be obtained from OpenPOWER under the terms and conditions
//    of the EULA.  
//
// Unless required by applicable law or agreed to in writing, the reference design
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
// for the specific language governing permissions and limitations under the License.
// 
// Additional rights, including the ability to physically implement a softcore that
// is compliant with the required sections of the Power ISA Specification, are
// available at no cost under the terms of the OpenPOWER Power ISA EULA, which can be
// obtained (along with the Power ISA) here: https://openpowerfoundation.org. 

//  Description:  LQ AXU Decode
//
//*****************************************************************************

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

//-------------------------------------------------------------------
// Generics
//-------------------------------------------------------------------
//parameter                                               `GPR_POOL_ENC = 6;
//parameter                                               `THREADS = 2;
//parameter                                               `THREADS_POOL_ENC = 1;
//parameter                                               `AXU_SPARE_ENC = 3;

//-------------------------------------------------------------------
// Input Instruction
//-------------------------------------------------------------------
input [0:31]                                                lq_au_ex0_instr;
input                                                       lq_au_ex1_vld;
input [0:`THREADS-1]                                        lq_au_ex1_tid;
input [0:31]                                                lq_au_ex1_instr;
input [0:`GPR_POOL_ENC-1]                                   lq_au_ex1_t3_p;

//-------------------------------------------------------------------
// Output
//-------------------------------------------------------------------
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

// EX0
// External PID instructions need to be decoded in EX0
// 011111 - 1001011111 -     1      1   0   0   0    0 0    1 0 1 0 0 0 0 0 1 00    001000     0   00 00    0 0 0 # lfdepx
// 011111 - 1011011111 -     1      0   1   0   0    0 0    1 1 1 0 0 0 0 0 1 00    001000     0   00 00    0 0 0 # stfdepx
assign au_lq_ex0_extload  = (lq_au_ex0_instr[0:5] == 6'b011111) & (lq_au_ex0_instr[21:30] == 10'b1001011111);
assign au_lq_ex0_extstore = (lq_au_ex0_instr[0:5] == 6'b011111) & (lq_au_ex0_instr[21:30] == 10'b1011011111);

// MFTGPR instructions need to be decoded in EX0
// 011111 1 0001000011 0     1      0   1   0   0    0 0    1 1 1 0 0 0 1 0 0 11    000000     0   01 00    0 0 0 # mtdpx   (DITC from FPR)
// 011111 1 0001000011 1     1      0   1   0   0    0 0    1 1 1 0 0 0 1 0 0 11    000000     1   01 00    0 0 0 # mtdpx.  (DITC from FPR)
// 011111 1 0001100011 0     1      0   1   0   0    0 0    1 1 0 0 0 0 1 0 0 10    000000     0   01 00    0 0 0 # mtdp    (DITC from FPR)
// 011111 1 0001100011 1     1      0   1   0   0    0 0    1 1 0 0 0 0 1 0 0 10    000000     1   01 00    0 0 0 # mtdp.   (DITC from FPR)
// 011111 - 1011011101 -     1      0   0   1   0    0 0    1 1 0 0 0 0 1 0 0 00    000000     0   01 00    1 0 1 # mfitgpr (mftgpr for stfiwx integer word)
// 011111 - 1011111110 -     1      0   0   1   0    0 0    1 1 0 0 0 1 0 0 0 00    000000     0   01 00    1 0 1 # mfstgpr (mftgpr single)
// 011111 - 1011111111 -     1      0   0   1   0    0 0    1 1 0 0 0 0 0 0 0 00    000000     0   01 00    1 0 1 # mftgpr (mftgpr double)
assign ex0_movedp_instr = lq_au_ex0_instr[20] & (lq_au_ex0_instr[21:24] == 4'b0001) & (lq_au_ex0_instr[26:30] == 5'b00011);
assign ex0_mftgpr_instr = (lq_au_ex0_instr[21:29] == 9'b101111111) | (lq_au_ex0_instr[21:30] == 10'b1011011101);
assign au_lq_ex0_mftgpr = (lq_au_ex0_instr[0:5] == 6'b011111) & (ex0_movedp_instr | ex0_mftgpr_instr);

// EX1
assign pri_ex1[0:5]   = lq_au_ex1_instr[0:5];
assign sec_ex1[20:31] = lq_au_ex1_instr[20:31];

// update # of inputs and outputs   .i xx   .o xx
// run "espvhdlexpand iuq_axu_fu_dec.vhdl > iuq_axu_fu_dec_new.vhdl" to regenerate logic below table
//

//@@ ESPRESSO TABLE START @@
// ##################################################################################################
// .i 18
// .o 32
// .ilb pri_ex1(0) pri_ex1(1) pri_ex1(2) pri_ex1(3) pri_ex1(4) pri_ex1(5)
//      sec_ex1(20) sec_ex1(21) sec_ex1(22) sec_ex1(23) sec_ex1(24) sec_ex1(25) sec_ex1(26) sec_ex1(27) sec_ex1(28) sec_ex1(29) sec_ex1(30) sec_ex1(31)
// .ob  isfu_dec_ex1 tv av bv cv
//      bubble3 prebubble1
//      ld_st_ex1 st_ex1 indexed update_form forcealign single_precision_ldst int_word_ldst sign_ext_ldst ldst_extpid io_port io_port_ext
//      size(0) size(1) size(2) size(3) size(4) size(5)
//      cr_writer mffgpr mftgpr fdiv_ex1
//      fsqrt_ex1   only_from_ucode final_fmul_uc only_graphics_mode
// .type fd
//#
//#
// ###################################################################################################################
//#                                                                   s
//#                                                                   i
//#                                                                   n
//#                                                                   g                                         o
//#                                                                   l                                         n
//#                                                                   e                                         l
//#                                                                   |                                     o   y
//#                                                                   p                                     n   |
//#                                                                   r i s                                 l f g
//#                                                                   e n i                                 y i r
//#                                                               u   c t g l  i                            | n a
//#                                                    p          p f i | n d  o                            f a p
//#                                                    r          d o s w | s  |               c            r l h
//#                                                    e    l     a r i o e t  p     LD/ST     r            o | i
//#                                                  b b    d   i t c o r x | io     size                   m f c
//#                                                  u u        n e e n d t e or     in        w   mm       | m s
//#                                                  b b    o s d   a | | | x |t     bytes     r   ff  f    u u |
//#pri_ex1    sec_ex1        i                       b b    r t e f l l l l t p|     1to16     i   ft fs    c l m
//#                          s                       l l      o x o i d d d p oe     pwrs      t   gg dq    o | o
//#000000 2 2222222223 3     F      T   A   B   C    e e    s r e r g s s s i rx     oftwo     e   pp ir    d u d
//#012345 0 1234567890 1     U      V   V   V   V    3 1    t e d m n t t t d tt    012345     r   rr vt    e c e
// ######### ###############################################################################################################

// 011111 1 0000000011 0     1      1   0   0   0    0 0    1 0 1 0 0 0 1 0 0 11    000000     0   10 00    0 0 0 # mfdpx   (DITC to FPR)
// 011111 1 0000000011 1     1      1   0   0   0    0 0    1 0 1 0 0 0 1 0 0 11    000000     1   10 00    0 0 0 # mfdpx.  (DITC to FPR)

// 011111 1 0000100011 0     1      1   0   0   0    0 0    1 0 0 0 0 0 1 0 0 10    000000     0   10 00    0 0 0 # mfdp    (DITC to FPR)
// 011111 1 0000100011 1     1      1   0   0   0    0 0    1 0 0 0 0 0 1 0 0 10    000000     1   10 00    0 0 0 # mfdp.   (DITC to FPR)

// 011111 1 0001000011 0     1      0   1   0   0    0 0    1 1 1 0 0 0 1 0 0 11    000000     0   01 00    0 0 0 # mtdpx   (DITC from FPR)
// 011111 1 0001000011 1     1      0   1   0   0    0 0    1 1 1 0 0 0 1 0 0 11    000000     1   01 00    0 0 0 # mtdpx.  (DITC from FPR)

// 011111 1 0001100011 0     1      0   1   0   0    0 0    1 1 0 0 0 0 1 0 0 10    000000     0   01 00    0 0 0 # mtdp    (DITC from FPR)
// 011111 1 0001100011 1     1      0   1   0   0    0 0    1 1 0 0 0 0 1 0 0 10    000000     1   01 00    0 0 0 # mtdp.   (DITC from FPR)

// 011111 - 01-------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 100000---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 10000100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 100001010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1000010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1000010111 -     1      1   0   0   0    0 0    1 0 1 0 0 1 0 0 0 00    000100     0   00 00    0 0 0 # lfsx
// 011111 - 1000011--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
//
// 011111 - 100010---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 10001100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 100011010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1000110110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1000110111 -     1      1   0   0   0    0 0    1 0 1 1 0 1 0 0 0 00    000100     0   00 00    0 0 0 # lfsux
// 011111 - 1000111--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 100100---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 10010100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 100101010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1001010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1001010111 -     1      1   0   0   0    0 0    1 0 1 0 0 0 0 0 0 00    001000     0   00 00    0 0 0 # lfdx

// 011111 - 10010110-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 100101110- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1001011110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1001011111 -     1      1   0   0   0    0 0    1 0 1 0 0 0 0 0 1 00    001000     0   00 00    0 0 0 # lfdepx
// 011111 - 100110---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 10011100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 100111010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1001110110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1001110111 -     1      1   0   0   0    0 0    1 0 1 1 0 0 0 0 0 00    001000     0   00 00    0 0 0 # lfdux

// 011111 - 1001111100 -     1      1   0   0   0    0 0    1 0 1 0 0 0 1 1 0 00    000000     0   10 00    1 0 1 # mfifgpr (mffgpr for lfiwax)
// 011111 - 1001111101 -     1      1   0   0   0    0 0    1 0 1 0 0 0 1 0 0 00    000000     0   10 00    1 0 1 # mfixfgpr (mffgpr for lfiwzx)

// 011111 - 1001111110 -     1      1   0   0   0    0 0    1 0 0 0 0 1 0 0 0 00    000000     0   10 00    1 0 1 # mfsfgpr (mffgpr for lfs, lfsu single)
// 011111 - 1001111111 -     1      1   0   0   0    0 0    1 0 0 0 0 0 0 0 0 00    000000     0   10 00    1 0 1 # mffgpr (mffgpr for lfd, lfdu double)

// 011111 - 101000---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 10100100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 101001010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1010010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1010010111 -     1      0   1   0   0    0 0    1 1 1 0 0 1 0 0 0 00    000100     0   00 00    0 0 0 # stfsx
// 011111 - 1010011--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
//
// 011111 - 101010---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 10101100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 101011010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1010110110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1010110111 -     1      0   1   0   0    0 0    1 1 1 1 0 1 0 0 0 00    000100     0   00 00    0 0 0 # stfsux
// 011111 - 1010111--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
//
// 011111 - 101100---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 10110100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 101101010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1011010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1011010111 -     1      0   1   0   0    0 0    1 1 1 0 0 0 0 0 0 00    001000     0   00 00    0 0 0 # stfdx
// 011111 - 10110110-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1011011100 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1011011101 -     1      0   0   1   0    0 0    1 1 0 0 0 0 1 0 0 00    000000     0   01 00    1 0 1 # mfitgpr (mftgpr for stfiwx integer word)
// 011111 - 1011011110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1011011111 -     1      0   1   0   0    0 0    1 1 1 0 0 0 0 0 1 00    001000     0   00 00    0 0 0 # stfdepx

// 011111 - 101110---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 10111100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 101111010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1011110110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1011110111 -     1      0   1   0   0    0 0    1 1 1 1 0 0 0 0 0 00    001000     0   00 00    0 0 0 # stfdux

// 011111 - 1011111110 -     1      0   0   1   0    0 0    1 1 0 0 0 1 0 0 0 00    000000     0   01 00    1 0 1 # mfstgpr (mftgpr single)
// 011111 - 1011111111 -     1      0   0   1   0    0 0    1 1 0 0 0 0 0 0 0 00    000000     0   01 00    1 0 1 # mftgpr (mftgpr double)

// 011111 - 110000---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 11000100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 110001010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1100010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
//#011111 - 1100010111 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0 # lfdpx  (ucoded)
// 011111 - 1100011--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 11001----- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0

// 011111 - 110100---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 11010100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 110101010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1101010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1101010111 -     1      1   0   0   0    0 0    1 0 1 0 0 0 1 1 0 00    000100     0   00 00    0 0 0 # lfiwax
// 011111 - 1101011--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1101110111 -     1      1   0   0   0    0 0    1 0 1 0 0 0 1 0 0 00    000100     0   00 00    0 0 0 # lfiwzx

// 011111 - 111000---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 11100100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 111001010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1110010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
//#011111 - 1110010111 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0 # stfdpx   (ucoded)
// 011111 - 1110011--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 11101----- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 111100---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 11110100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 111101010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1111010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 1111010111 -     1      0   1   0   0    0 0    1 1 1 0 0 0 1 0 0 00    000100     0   00 00    0 0 0 # stfiwx
// 011111 - 1111011--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
// 011111 - 11111----- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0

// 10---- - ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0

// 110000 - ---------- -     1      1   0   0   0    0 0    1 0 0 0 0 1 0 0 0 00    000100     0   00 00    0 0 0 # lfs

// 110001 - ---------- -     1      1   0   0   0    0 0    1 0 0 1 0 1 0 0 0 00    000100     0   00 00    0 0 0 # lfsu

// 110010 - ---------- -     1      1   0   0   0    0 0    1 0 0 0 0 0 0 0 0 00    001000     0   00 00    0 0 0 # lfd
// 110011 - ---------- -     1      1   0   0   0    0 0    1 0 0 1 0 0 0 0 0 00    001000     0   00 00    0 0 0 # lfdu
// 110100 - ---------- -     1      0   1   0   0    0 0    1 1 0 0 0 1 0 0 0 00    000100     0   00 00    0 0 0 # stfs

// 110101 - ---------- -     1      0   1   0   0    0 0    1 1 0 1 0 1 0 0 0 00    000100     0   00 00    0 0 0 # stfsu
//
// 110110 - ---------- -     1      0   1   0   0    0 0    1 1 0 0 0 0 0 0 0 00    001000     0   00 00    0 0 0 # stfd
//
// 110111 - ---------- -     1      0   1   0   0    0 0    1 1 0 1 0 0 0 0 0 00    001000     0   00 00    0 0 0 # stfdu
//
// 111000 - ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0

// #######################################################################
// .e
//@@ ESPRESSO TABLE END @@

//@@ ESPRESSO LOGIC START @@
// logic generated on: Mon Mar 16 09:28:21 2009
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

//@@ ESPRESSO LOGIC END @@

generate
   if (`THREADS_POOL_ENC == 0) begin : tid1
      wire [0:`THREADS_POOL_ENC]                                   tid_enc;

      assign tid_enc = tidn;
      assign ldst_tag = {single_precision_ldst, int_word_ldst, sign_ext_ldst, lq_au_ex1_t3_p};		// for lfiwax
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
      assign ldst_tag = {single_precision_ldst, int_word_ldst, sign_ext_ldst, lq_au_ex1_t3_p, tid_enc[0:`THREADS_POOL_ENC - 1]};		// for lfiwax
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

assign au_lq_ex1_instr_type = 3'b001;		// 0=AP,1=Vec,2=FP

assign au_lq_ex1_mffgpr = mffgpr;		// and ld_st_ex1;      -- This is for LVSL, and also misaligned loads
assign au_lq_ex1_mftgpr = mftgpr;		// and ld_st_ex1;      -- This is for misaligned stores

assign au_lq_ex1_movedp = io_port & ld_st_ex1;

assign au_lq_ex1_ldst_size = size[0:5];
assign au_lq_ex1_ldst_tag  = ldst_tag;
assign au_lq_ex1_ldst_dimm        = lq_au_ex1_instr[16:31];
assign au_lq_ex1_ldst_indexed     = indexed;
assign au_lq_ex1_ldst_update      = update_form;		// and ld_st_ex1;
assign au_lq_ex1_ldst_forcealign  = forcealign;
assign au_lq_ex1_ldst_forceexcept = 1'b0;

assign au_lq_ex1_ldst_priv = ldst_extpid;

endmodule
