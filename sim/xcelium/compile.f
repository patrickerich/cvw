# Compilation options for Xcelium
-timescale 1ns/1ps
-access +rwc
-sv
+define+XCELIUM
+incdir+$WALLY/config/shared
+incdir+$WALLY/config/$WALLYCONF
+incdir+$WALLY/testbench
+incdir+$WALLY/testbench/common

# First compile the package
$WALLY/src/cvw.sv

# Then compile the rest of the files
$WALLY/testbench/testbench.sv
$WALLY/testbench/common/*.sv
$WALLY/src/*/*.sv
$WALLY/src/*/*/*.sv
$WALLY/addins/verilog-ethernet/*/*.sv
$WALLY/addins/verilog-ethernet/*/*/*/*.sv
