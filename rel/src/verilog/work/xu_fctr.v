// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

//  Description:  XU CPL - Configurable Flush Delay Counter
//
//*****************************************************************************
`include "tri_a2o.vh"

module xu_fctr
#(
   parameter               CLOCKGATE = 1,
   parameter               PASSTHRU = 1,
   parameter               DELAY_WIDTH = 4,
   parameter               WIDTH = 2
)
(
   input [0:`NCLK_WIDTH-1] nclk,

   input                   force_t,
   input                   thold_b,
   input                   sg,
   input                   d_mode,
   input                   delay_lclkr,
   input                   mpw1_b,
   input                   mpw2_b,

   input                   scin,
   output                  scout,

   input [0:WIDTH-1]       din,
   output [0:WIDTH-1]      dout,
   input [0:DELAY_WIDTH-1] delay,

   inout                   vdd,
   inout                   gnd
);


   // Latches
   wire [0:DELAY_WIDTH-1]  delay_q[0:WIDTH-1];
   wire [0:DELAY_WIDTH-1]  delay_d[0:WIDTH-1];
   // Scanchains
   localparam              delay_offset = 0;
   localparam              scan_right = delay_offset + DELAY_WIDTH*WIDTH;
   wire [0:scan_right-1]   siv;
   wire [0:scan_right-1]   sov;
   // Signals
   wire [0:WIDTH-1]     set;
   wire [0:WIDTH-1]     zero_b;
   wire [0:WIDTH-1]     act;

   generate
      genvar                  t;
      for (t=0;t<=WIDTH-1;t=t+1)
      begin : threads_gen
         wire [0:DELAY_WIDTH-1]   delay_m1;

         assign set[t] = din[t];
         assign zero_b[t] = |(delay_q[t]);
         assign delay_m1 = delay_q[t] - {{DELAY_WIDTH-1{1'b0}},1'b1};

         if (CLOCKGATE == 0) begin : clockgate_0
            assign act[t] = set[t] | zero_b[t];

            assign delay_d[t] = ({set[t], zero_b[t]} == 2'b11) ? delay :
                                ({set[t], zero_b[t]} == 2'b10) ? delay :
                                ({set[t], zero_b[t]} == 2'b01) ? delay_m1 :
                                delay_q[t];
         end
         if (CLOCKGATE == 1) begin : clockgate_1
            assign act[t] = set[t] | zero_b[t];

            assign delay_d[t] = (set[t] == 1'b1) ? delay :
                                delay_m1;
         end

         if (PASSTHRU == 1)begin : PASSTHRU_gen_1
            assign dout[t] = zero_b[t] | din[t];
         end
         if (PASSTHRU == 0) begin : PASSTHRU_gen_0
            assign dout[t] = zero_b[t];
         end


         tri_rlmreg_p #(.WIDTH(DELAY_WIDTH), .INIT(0), .NEEDS_SRESET(1)) delay_latch(
            .nclk(nclk),
            .vd(vdd),
            .gd(gnd),
            .act(act[t]),
            .force_t(force_t),
            .d_mode(d_mode),
            .delay_lclkr(delay_lclkr),
            .mpw1_b(mpw1_b),
            .mpw2_b(mpw2_b),
            .thold_b(thold_b),
            .sg(sg),
            .scin(siv[delay_offset+DELAY_WIDTH*t:delay_offset+DELAY_WIDTH*(t+1)-1]),
            .scout(sov[delay_offset+DELAY_WIDTH*t:delay_offset+DELAY_WIDTH*(t+1)-1]),
            .din(delay_d[t]),
            .dout(delay_q[t])
         );
      end
   endgenerate

assign siv[0:scan_right - 1] = {sov[1:scan_right - 1], scin};
assign scout = sov[0];

endmodule
