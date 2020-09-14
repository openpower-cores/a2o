// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.




module tri_event_mux1t(	
   vd,
   gd,
   select_bits,
   unit_events_in,
   event_bus_in,
   event_bus_out
);
   parameter                             	EVENTS_IN = 32; 
   parameter                                 	EVENTS_OUT = 4;	
   input  [0:((EVENTS_IN/32+4)*EVENTS_OUT)-1] 	select_bits;
   
   input  [1:EVENTS_IN-1]                   	unit_events_in;
   
   input  [0:EVENTS_OUT-1]                   	event_bus_in;
   
   output [0:EVENTS_OUT-1]                   	event_bus_out;
  
   inout                  			vd;

   inout                  			gd;


   parameter                                 	INCR = EVENTS_IN/32 + 4;  
      
   wire [0:EVENTS_OUT*EVENTS_IN-1]         	inMuxDec;
   wire [0:EVENTS_OUT*EVENTS_IN-1]         	inMuxOut;




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


   generate
      begin : xhdl0
	 genvar      X;
	 for (X = 0; X <= EVENTS_OUT - 1; X = X + 1)
	 begin : decode
	    if (EVENTS_IN == 16)
	    begin : Mux16		
	       assign inMuxDec[X * EVENTS_IN:X * EVENTS_IN + 15] = decode_a(select_bits[X * INCR:X * INCR + 3]);
	    end
	 
	    if (EVENTS_IN == 32)
	    begin : Mux32		
	       assign inMuxDec[X * EVENTS_IN:X * EVENTS_IN + 31] = decode_a(select_bits[X * INCR:X * INCR + 4]);
	    end
      
            if (EVENTS_IN == 64)
            begin : Mux64		
	       assign inMuxDec[X * EVENTS_IN:X * EVENTS_IN + 63] = decode_a(select_bits[X * INCR:X * INCR + 5]);
            end
         end
      end
   endgenerate

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
