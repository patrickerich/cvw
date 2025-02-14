# Compilation options for Xcelium
-timescale 1ns/1ps
-access +rwc
-sv
+define+XCELIUM
+incdir+$WALLY/config/shared
+incdir+$WALLY/config/$WALLYCONF
+incdir+$WALLY/config/deriv/$WALLYCONF
# Source files
$WALLY/src/cvw.sv
$WALLY/testbench/testbench.sv
$WALLY/testbench/common/*.sv
$WALLY/src/*/*.sv
$WALLY/src/*/*/*.sv
$WALLY/addins/verilog-ethernet/*/*.sv
$WALLY/addins/verilog-ethernet/*/*/*/*.sv
