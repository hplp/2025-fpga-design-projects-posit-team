# Posit - Index-based computation of real-number multiplication

## Team Name: 
Posit Team

## Team Members:
- Melika Morsali (qfc2zn)
- Hasantha Ekanayake (uyq6nu)

## 1. Project Overveiw:


#### Project Title: Posit - Index-based computation of real-number multiplication
#### Repository URL: [GitHub Repository Link](https://github.com/hplp/2025-fpga-design-projects-posit-team)

## Project Description:
This project is to develop a custom intellectual property (IP) core for performing Multiply-
Accumulate (MAC) operations where the activation inputs are in 16-bit IEEE floating-
point format (FP16), and the weights are in 4-bit posit (Posit4) format. This IP will be
developed on the PYNQ-Z1 FPGA board, either using Verilog RTL or High-Level Synthesis
(HLS). The goal is to combine the advantages of industry-standard FP16 activations with
the low-precision posit representation for weights, thereby reducing resource usage while
maintaining reasonable accuracy for real-number MAC operations. This IP aims to support
computational tasks common in machine learning and high-performance computing.

## 2. Objectives:
- ### Objective 1 - Design a Custom MAC Unit Using Mixed Precision:
  
	•	Develop a Multiply-Accumulate (MAC) IP core that accepts 16-bit IEEE floating-point (FP16) activations and 4-bit posit (Posit4) weights.

	•	This mixed-precision design aims to combine FP16’s compatibility with the memory efficiency of Posit4.

- ### Objective 2 - Implement and Integrate on FPGA:
	•	Build the design using Verilog or HLS and implement it on a PYNQ-Z1 FPGA.

	•	Integrate the MAC unit as a custom IP with AXI interfaces for real-world deployment.

- ### Objective 3 - 	Benchmark and Compare Performance:
  
	•	Evaluate the custom MAC unit against a baseline FP16-only MAC in terms of:
		Resource usage (LUTs, DSPs, FFs),Power efficiency,Numerical accuracy.
  

## 3. Technology Stack:
- PYNQ-Z1 FPGA board
- Vivado and Vitis toolchains
- Verilog RTL and/or High-Level Synthesis (HLS)

## 4. Expected Outcomes:
1.	A functional custom MAC IP core that uses FP16-Posit4 computation, synthesized and deployed on the PYNQ-Z1 FPGA board.
2.	Improved memory and power efficiency over traditional FP16-only MAC units, due to the use of compact 4-bit Posit weights.
3.	Verified simulation and hardware testing results showing correctness, resource utilization, and accuracy trade-offs—potentially suitable for edge AI and low-power applications.

## 5. Tasks:

- FP-Posit Multiplication Module 
- FP-Posit Accumulator
- FP-Posit MAC 
-  FP-Int Multiplication Module as baseline
- FP-Int Accumulator as baseline 
- FP-Int as baseline MAC 
- Custom IP Creation with Zynq for both FP-Posit MAC and FP-Int MAC 
- Benchmarking and Comparing 
  
## 6. Results:

### 6.1 Implementation and Verification -  FP-Posit MAC
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

### 6.2 Implementation and Verification - FP-Int MAC
- FP-Int Multiplication Module as baseline Testbench Result:

<p align="center">
  <img src="Images/fp_int_mul.png" alt="fp_int_mul" width="80%">
</p>


- FP-Int Accumulator as baseline Testbench Result: 

<p align="center">
  <img src="Images/fp_int_acc.png" alt="fp_int_acc" width="80%">
</p>

- FP-Int as baseline MAC Testbench Result:

<p align="center">
  <img src="Images/fp_int_mac.png" alt="fp_int_mac" width="80%">
</p>


  
## 7. Custom IP Creation with Zynq for both FP-Posit MAC and FP-Int MAC 

### 7.1 FP-Posit MAC
Netlist Diagram

<p align="center">
  <img src="Images/FP-Posit-Mac-device.png"" alt="fp_int" width="50%">
</p>

Resource Utilization

| LUT | FF |
| -------- | -------- |
| 460 | 695 |

### 7.2 FP-Int MAC

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

## 8. Key Takeaways

## 9. Chalneges
We are currently facing challenges testing our IP using Vitis with C code. Since the Posit input is sent serially with each clock cycle, we've realized that we need to create a custom IP with AXI Stream instead of AXI Lite. However, the issue is that AXI Stream has only four registers, while our code requires eight registers. We are now working on modifying the code to send the Posit input in parallel or exploring how to use AXI Stream with this code.

## 10. Conclusion


## References
