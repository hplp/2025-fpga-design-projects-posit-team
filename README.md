# Project_Template

## Team Name: 
Posit Team

## Team Members:
- Melika Morsali (qfc2zn)
- Hasantha Ekanayake (uyq6nu)

## Project Title:
(Posit - Index-based computation of real-number multiplication)

## Project Description:
We propose to develop a custom intellectual property (IP) core for performing Multiply-
Accumulate (MAC) operations where the activation inputs are in 16-bit IEEE floating-
point format (FP16), and the weights are in 4-bit posit (Posit4) format. This IP will be
developed on the PYNQ-Z1 FPGA board, either using Verilog RTL or High-Level Synthesis
(HLS). The goal is to combine the advantages of industry-standard FP16 activations with
the low-precision posit representation for weights, thereby reducing resource usage while
maintaining reasonable accuracy for real-number MAC operations. This IP aims to support
computational tasks common in machine learning and high-performance computing.

## Key Objectives:
- Objective 1
- Objective 2
- Objective 3

## Technology Stack:
- PYNQ-Z1 FPGA board
- Vivado and Vitis toolchains
- Verilog RTL and/or High-Level Synthesis (HLS)

## Expected Outcomes:
(Describe what you expect to deliver at the end of the project)

## Tasks:
(Describe the tasks that need to be completed. Assign students to tasks)
- FP-Posit Multiplication Module (Melika)
- FP-Posit Accumulator (Melika)
- FP-Posit MAC (Melika)
-  FP-Int Multiplication Module as baseline (Hasantha)
- FP-Int Accumulator as baseline (Hasantha)
- FP-Int as baseline MAC (Hasantha)
- Custom IP Creation with Zynq for both FP-Posit MAC and FP-Int MAC (Meliak and Hasantha)
- Benchmark and Compareing (Meliak and Hasantha)
  
## Timeline:
- Phase-I: Starting the Project
-- • GitHub Repository Setup: Create a repo for the project, provide a clear README,
and outline roles for each teammate.
-- • Initial Module Placeholders: Prepare skeletal Verilog/HLS code for the FP16-
Posit4 multiplier and accumulator.
-- • Resource Listing: Identify required hardware (PYNQ-Z1) and software tools (Vi-
vado, HLS, simulators).
- Phase-II: First Iteration and Progress Report
-- • Module Implementation & Test: Complete and simulate FP16-Posit4 multiplier/
accumulator modules, verifying correctness with testbenches.
-- • Preliminary MAC Integration: Combine the multiplier and accumulator into a
MAC pipeline; check resource usage and timing in simulations.
-- • Documentation: Update the GitHub repo with progress logs, issue tracking, and
test results.
- Phase-III: Finalization & Presentation
-- • Custom IP Generation: Wrap the MAC design as a Zynq-compatible IP with AXI
interfaces; synthesize and implement on the PYNQ board.
-- • Benchmark & Compare: Evaluate LUT/FF/DSP usage, power, and accuracy
against a baseline FP16 design.
-- • Demo & Report: Present the final functioning IP core with a concise demo and
submit the complete GitHub repo and documentation.
