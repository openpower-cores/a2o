# -------------------------------------------------------------

<b>
This repo has been archived and relocated.
<br><br>
The new home is:
https://git.openpower.foundation/cores/a2o

It is mirrored at:
https://github.com/OpenPOWERFoundation/a2o
</b>

# --------------------------------------------------------------

# A2O

## The Project
This is the release of the A2O POWER processor core RTL and associated FPGA implementation (using ADM-PCIE-9V3 FPGA).

See [Project Info](rel/readme.md) for details.

## The Core
The [A2O core](rel/doc/A2O_UM.pdf) was created to optimize single-thread performance, and targeted 3+ GHz in 45nm technology.

It is a 27 FO4 implementation, with an out-of-order pipeline supporting 1 or 2 threads.  It fully supports Power ISA 2.07 using Book III-E.
The core was also designed to support pluggable implementations of MMU and AXU logic macros.
This includes elimination of the MMU and using ERAT-only mode for translation/protection.

## The History

The A2O design was a follow-on to A2I, written in Verilog, and supported a lower thread count than A2I, but higher performance per thread, using out-of-order execution
(register renaming, reservation stations, completion buffer) and a store queue. 

The A2L2 external interface is largely the same for the two cores.

## FPGA Implementation Notes

1. There are lots of knobs available for tweaking generation parameters.  Very little experimentation was done to test whether they work, or the effects on area, etc.
2. Only single-thread generation has been done so far.  The FPGA in use has very high utilization with one thread.
3. A2I used clk_1x and clk_2x (for some of the special arrays), but A2O also uses clk_4x.  This (and possibly along with the area congestion) led to changing the clk_1x to 50MHz to lessen timing pressure
(both setup and hold misses).

### Technology Scaling

A comparison of the design in original technology and scaled to 7nm (SMT2, fixed-point, no MMU):

|      |Freq     |Pwr    |Freq Sort|Pwr Sort|Area     |Vdd    |
|-----:|---------|-------|---------|--------|---------|-------|
|45nm  |2.30 GHz |1.49 W |         |        |4.90 mm<sup>2</sup> |0.97 V |
| 7nm  |3.90 GHz |0.79 W |4.17 GHz |0.85 W  |0.31 mm<sup>2</sup> |1.1  V |
| 7nm  |3.75 GHz |0.63 W |4.03 GHz |0.67 W  |0.31 mm<sup>2</sup> |1.0  V |
| 7nm  |3.55 GHz |0.49 W |3.87 GHz |0.52 W  |0.31 mm<sup>2</sup> |0.9  V |
| 7nm  |3.07 GHz |0.32 W |3.60 GHz |0.38 W  |0.31 mm<sup>2</sup> |0.8  V |
| 7nm  |2.40 GHz |0.20 W |3.00 GHz |0.25 W  |0.31 mm<sup>2</sup> |0.7  V |

These estimates are based on a semicustom design in representative foundry processes (IBM 45nm/Samsung 7nm).

### Compliancy

The A2O core is compliant to Power ISA 2.07 and will need updates to be compliant with either version 3.0c or 3.1.
Power ISA 3.0c and 3.1 are the two Power ISA versions contributed to OpenPOWER Foundation by IBM.  Changes will include:

* radix translation
* op updates, to eliminate noncompliant ones and add missing ones required for a given compliancy level
* various 'mode' and other changes to meet the open specification targeted compliancy level (III-E needs to be changed to III)

## Miscellaneous

1. A2O was not released as a product; the documentation was derived from A2I but is *much* less complete than the A2I version.
The documentation has been edited and updated where possible, but undoubtedly, there
remain errors vis a vis the RTL (especially likely in implementation-specific SPRs).

      Please use 'issues' to report errors. 

## Errata

1. There is a problem that is being circumvented by setting LSUCR0.DFWD=1, AND limiting the store queue size (currently at 4).  While it appears 
to be directly related to forwarding (L1 DC hit returns 0's instead of data), the store queue size also had to be limited.

      Not debugged at this time; could be related to:
      1. bad generation parm
      2. bad edit for source updates related to compiling for Vivado
      3. ???
      
