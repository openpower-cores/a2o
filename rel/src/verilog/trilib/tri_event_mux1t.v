// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

//********************************************************************
//*
//* TITLE: Performance Event Mux Component - 1 Thread; 4 bits
//*
//* NAME:  tri_event_mux1t.v
//*
//********************************************************************

module tri_event_mux1t(
   vd,
   gd,
   select_bits,
   unit_events_in,
   event_bus_in,
   event_bus_out
);
   parameter                             	EVENTS_IN = 32; // Valid Settings: 16; 32; 64
   parameter                                 	EVENTS_OUT = 4;	// Valid Settings: 4 outputs per event mux
   // Select bit size depends on total events: 16 events=16, 32 events=20; 64 events=24
   input  [0:((EVENTS_IN/32+4)*EVENTS_OUT)-1] 	select_bits;

   input  [1:EVENTS_IN-1]                   	unit_events_in;

   input  [0:EVENTS_OUT-1]                   	event_bus_in;

   output [0:EVENTS_OUT-1]                   	event_bus_out;

   inout                  			vd;

   inout                  			gd;


//=====================================================================
// Signal and Function Declarations
//=====================================================================
// Constants used to split up select_bits for the decoder
//                                                                       Mux Size:  16 32 64
   parameter                                 	INCR = EVENTS_IN/32 + 4;  // INCR:   4  5  6

   // For each output bit decode select bits to select an input mux to use.
   wire [0:EVENTS_OUT*EVENTS_IN-1]         	inMuxDec;
   wire [0:EVENTS_OUT*EVENTS_IN-1]         	inMuxOut;

// Paramaterized decoder function - decode mux value based on input select_bits
// Input size based on EVENTS_IN parameter: 	16=4, 32=5, 64=6
   function [0:EVENTS_IN-1] decode_a;
  	input [0:INCR-1] decode_input;
  	(* analysis_not_referenced="true" *)
  	integer i;

	for(i=0; i<EVENTS_IN; i=i+1)
  	begin
  	   if({{32-INCR{1'b0}},decode_input} == i)
  		decode_a[i] = 1'b1;
  	   else
  		decode_a[i] = 1'b0;
      	end
   endfunction


//=====================================================================
// Start of event mux
//=====================================================================
   // For each output bit, decode its select_bits to select the input mux it's using
   generate
      begin : xhdl0
	 genvar      X;
	 for (X = 0; X <= EVENTS_OUT - 1; X = X + 1)
	 begin : decode
	    if (EVENTS_IN == 16)
	    begin : Mux16		// 4to16 decode; select_bits(0:3,  4:7,  8:11, 12:15 ) per output bit
	       assign inMuxDec[X * EVENTS_IN:X * EVENTS_IN + 15] = decode_a(select_bits[X * INCR:X * INCR + 3]);
	    end

	    if (EVENTS_IN == 32)
	    begin : Mux32		// 5to32 decode; select_bits(0:4,  5:9, 10:14, 15:19 ) per output bit
	       assign inMuxDec[X * EVENTS_IN:X * EVENTS_IN + 31] = decode_a(select_bits[X * INCR:X * INCR + 4]);
	    end

            if (EVENTS_IN == 64)
            begin : Mux64		// 6to64 decode; select_bits(0:5, 6:11, 12:17, 18:23 ) per output bit
	       assign inMuxDec[X * EVENTS_IN:X * EVENTS_IN + 63] = decode_a(select_bits[X * INCR:X * INCR + 5]);
            end
         end
      end
   endgenerate

   // For each output bit, inMux decodes gate the selected unit event input; or event_bus_in when decode=0
   generate
      begin : xhdl2
         genvar      X;
         for (X = 0; X <= EVENTS_OUT - 1; X = X + 1)
         begin : inpMux

                  assign inMuxOut[X * EVENTS_IN + 0] = (inMuxDec[X * EVENTS_IN + 0] & event_bus_in[X]) ;

            begin : xhdl1
               genvar      I;
               for (I = 1; I <= EVENTS_IN - 1; I = I + 1)
               begin : eventSel

                  assign inMuxOut[X * EVENTS_IN + I] = (inMuxDec[X * EVENTS_IN + I] & unit_events_in[I]) ;

               end
            end
         end
      end
   endgenerate


   // ORing the input mux outputs to drive each event output bit.
   // Only one selected at a time by each output bit's inMux decode value.
   generate
      begin : xhdl5
         genvar      X;
         for (X = 0; X <= EVENTS_OUT - 1; X = X + 1)
         begin : bitOutHi
            if (EVENTS_IN == 16)
            begin : Mux16
               assign event_bus_out[X] = (|inMuxOut[X * EVENTS_IN:X * EVENTS_IN + 15]);
            end

            if (EVENTS_IN == 32)
            begin : Mux32
               assign event_bus_out[X] = (|inMuxOut[X * EVENTS_IN:X * EVENTS_IN + 31]);
            end

            if (EVENTS_IN == 64)
            begin : Mux64
               assign event_bus_out[X] = (|inMuxOut[X * EVENTS_IN:X * EVENTS_IN + 63]);
            end
         end
      end
   endgenerate

endmodule
