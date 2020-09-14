// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.


module xu0_bcd_bcdtd(
   input [0:11] a,
   output [0:9] y
);
   
   assign y[0] = (a[5] & a[0] & a[8] & (~a[4])) | (a[9] & a[0] & (~a[8])) | (a[1] & (~a[0]));
   assign y[1] = (a[6] & a[0] & a[8] & (~a[4])) | (a[10] & a[0] & (~a[8])) | (a[2] & (~a[0]));
   assign y[2] = a[3];
   assign y[3] = (a[9] &  (~a[0]) & a[4] & (~a[8])) | (a[5] & (~a[8]) & (~a[4])) | (a[5] & (~a[0]) & (~a[4])) | (a[4] & a[8]);
   assign y[4] = (a[10] & (~a[0]) & a[4] & (~a[8])) | (a[6] & (~a[8]) & (~a[4])) | (a[6] & (~a[0]) & (~a[4])) | (a[0] & a[8]);
   assign y[5] = a[7];
   assign y[6] = a[0] | a[4] | a[8];
   assign y[7] = ((~a[4]) & a[9] &  (~a[8])) | (a[4] & a[8]) | a[0];
   assign y[8] = ((~a[0]) & a[10] & (~a[8])) | (a[0] & a[8]) | a[4];
   assign y[9] = a[11];
      
endmodule
