# FPGA Project - Phase 2

## Implementation and Verification -  FP-Posit MAC
- FP-Posit Multiplication Testbench Result:
  <p align="center">
  <img src="Images/posit_mul.png" alt="fp_posit_mul" width="80%">
</p>


- FP-Posit Accumulator Testbench Result:

  <p align="center">
  <img src="Images/posit_acc.png" alt="fp_posit_acc" width="80%">
</p>


- FP-Posit MAC Testbench Result:

    <p align="center">
  <img src="Images/posit_mac.png" alt="fp_posit_mac" width="80%">
</p>

## Implementation and Verification - FP-Int MAC
- FP-Int Multiplication Module as baseline Testbench Result:

<p align="center">
  <img src="Images/fp_int_mul 1.PNG" alt="fp_int_mul" width="80%">
</p>


- FP-Int Accumulator as baseline Testbench Result: 

<p align="center">
  <img src="Images/fp_int_acc 1.PNG" alt="fp_int_acc" width="80%">
</p>

- FP-Int as baseline MAC Testbench Result:

<p align="center">
  <img src="Images/fp_int_mac 1.PNG" alt="fp_int_mac" width="80%">
</p>


  
## Custom IP Creation with Zynq for both FP-Posit MAC and FP-Int MAC 

#### - FP-Posit MAC
Netlist Diagram
![image](https://github.com/user-attachments/assets/f66cd21f-7a9e-408a-a8ff-c40abb060eed)

Resource Utilization

| LUT | FF |
| -------- | -------- |
| 460 | 695 |
#### - FP-Int MAC

Netlist Diagram
<!-- scale to 50% of container width -->
<p align="center">
  <img src="Images/fp_int_mac_circuit.png" alt="fp_int" width="50%">
</p>

Resource Utilization

| LUT | FF |
| -------- | -------- |
| 658 | 792 |

As it is shown above and expected, FP-Posite Mac utilizes less hardware than FP-Int.

## Chalneges
We are currently facing challenges testing our IP using Vitis with C code. Since the Posit input is sent serially with each clock cycle, we've realized that we need to create a custom IP with AXI Stream instead of AXI Lite. However, the issue is that AXI Stream has only four registers, while our code requires eight registers. We are now working on modifying the code to send the Posit input in parallel or exploring how to use AXI Stream with this code.
