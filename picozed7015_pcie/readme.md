![image](doc/logo.png)
# picozed7015 PCIe

## Description
In this project the board Avnet Picozed 7015 is conencted to PC through PCIe port

## Files
- **script/picozed7015_pcie.tcl.** Script to generate the Vivado project.
- **python/basic_pcie.py** basic python driver.

## Creating the project.
To create the project, we have to open the corresponding Vivado version folder inside script folder, and then execute the next line on command window.

```
vivado -mode tcl -source ./picozed7015_pcie.tcl
```
