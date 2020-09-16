// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

//*****************************************************************************
//  Description:  XU Bit Permute
//
//*****************************************************************************
module xu0_bprm(
   a,
   s,
   y
);
// IOs
input [0:63] a;
input [0:7]  s;
output       y;
// Signals
wire [0:7]   mh;
wire [0:7]   ml;
wire [0:63]  a1;
wire [0:63]  a2;

assign mh[0:7] = (s[0:4] == 5'b00000) ? 8'b10000000 :
                 (s[0:4] == 5'b00001) ? 8'b01000000 :
                 (s[0:4] == 5'b00010) ? 8'b00100000 :
                 (s[0:4] == 5'b00011) ? 8'b00010000 :
                 (s[0:4] == 5'b00100) ? 8'b00001000 :
                 (s[0:4] == 5'b00101) ? 8'b00000100 :
                 (s[0:4] == 5'b00110) ? 8'b00000010 :
                 (s[0:4] == 5'b00111) ? 8'b00000001 :
                                        8'b00000000 ;

assign ml[0:7] = (s[5:7] == 3'b000) ? 8'b10000000 :
                 (s[5:7] == 3'b001) ? 8'b01000000 :
                 (s[5:7] == 3'b010) ? 8'b00100000 :
                 (s[5:7] == 3'b011) ? 8'b00010000 :
                 (s[5:7] == 3'b100) ? 8'b00001000 :
                 (s[5:7] == 3'b101) ? 8'b00000100 :
                 (s[5:7] == 3'b110) ? 8'b00000010 :
                                      8'b00000001;

genvar i;
generate for (i=0; i<=7; i=i+1)
   begin : msk
      assign a1[8*i:8*i+7] =  a[8*i:8*i+7] & ml[0:7];
      assign a2[8*i:8*i+7] = a1[8*i:8*i+7] & {8{mh[i]}};
   end
endgenerate

assign y = |a2;

endmodule
