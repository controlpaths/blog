![image](doc/logo.png)
# picozed7015 PCIe

## Description
In this project the board Avnet Picozed 7015 is conencted to PC through PCIe port

## Files
- **script/dual_mb.tcl.** Script to generate the Vivado project.
- **c/hello_world_X.c** C file to implement the project.

## Creating the project.
To create the project, we have to open the corresponding Vivado version folder inside script folder, and then execute the next line on command window.

```
vivado -mode tcl -source ./dual_mb.tcl
```
Board file can be download from https://github.com/Digilent/vivado-boards
