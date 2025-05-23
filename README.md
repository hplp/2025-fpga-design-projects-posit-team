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
This project is to develop a custom intellectual property (IP) core for performing Multiply operations where the activation inputs are in 16-bit IEEE floating-
point format (FP16), and the weights are in 4-bit posit (Posit4) format. This IP will be
developed on the PYNQ-Z1 FPGA board using Verilog RTL. The goal is to combine the advantages of industry-standard FP16 activations with
the low-precision posit representation for weights, thereby reducing resource usage while
maintaining reasonable accuracy for real-number Multiply operations. This IP aims to support
computational tasks common in machine learning and high-performance computing.

## 2. Objectives:
- ### Objective 1 - Design a Custom Multiply Unit Using Mixed formats:
  
	•	Develop a Multiply IP core that accepts 16-bit IEEE floating-point (FP16) activations and 4-bit posit (Posit4) weights.

	•	This mixed-format design aims to combine FP16’s compatibility with the memory efficiency of Posit4.

- ### Objective 2 - Implement and Integrate on FPGA:
	•	Build the design using Verilog and implement it on a PYNQ-Z1 FPGA.

	•	Integrate the Multiply unit as a custom IP with AXI interfaces for real-world deployment.

- ### Objective 3 - 	Benchmark and Compare Performance:

  	•	Integrate our multiply module with a simple accumulator to perform the MAC operation.
  
	•	Evaluate the MAC unit against a baseline FP16-Int4 MAC in terms of:
		Resource usage (LUTs, FFs).
  

## 3. Technology Stack:
- PYNQ-Z1 FPGA board
- Vivado and Vitis toolchains
- Verilog RTL

## 4. Expected Outcomes:
1.	A functional custom Multiply IP core that uses FP16-Posit4 computation, synthesized and deployed on the PYNQ-Z1 FPGA board.
2.	Improved hardware resource over traditional FP16-Int4 MAC units, due to the use of compact 4-bit Posit weights.
3.	Verified simulation and hardware testing results showing correctness, resource utilization, and accuracy trade-offs—potentially suitable for edge AI applications.

## 5. Methods:

- Implement FP-Posit Multiplication Module 
- Integrate the multiplier and accumulator modules
- FP-Int as baseline MAC 
- Custom IP Creation for FP-Posit Multiplication Module with PYNQ-Z1 FPGA board
- Benchmarking and Comparing 

## 6. Posit Format

Posit is a **type-3 universal number (unum)** format introduced as a potential replacement for the IEEE-754 floating-point standard. It provides better accuracy, dynamic range, and efficiency — especially at low bit widths — by using a compact and flexible representation of real numbers.

### Key Features of Posit:
- **Single NaR (Not a Real)** value instead of separate NaN/±∞.
- **Tapered precision**: higher precision near 1.0, less near extremes.
- **Encoding components**: sign bit, variable-length *regime*, optional exponent, and fraction.
- **Efficient at low bit-widths**, making it ideal for deep learning inference at the edge.

### Posit Encoding Details

A generic **posit number** consists of the following fields:

- **Sign (1 bit)**: `0` for positive, `1` for negative.
- **Regime**: A run-length encoded sequence of `0`s or `1`s, terminated by a flip (`r̄`).
- **Exponent (optional)**: `es` bits, unsigned, no bias.
- **Fraction (optional)**: Remaining bits, with a hidden leading 1 (no denormals).

![image](https://github.com/user-attachments/assets/83fb3d47-7e0c-4947-a48e-cccfb5d2f540)

> *Figure: Generic posit format layout showing dynamic regime, optional exponent (es bits), and fraction fields.*

---

### Regime Bit Interpretation

Let `m` be the number of repeated bits in the regime field:
- If regime starts with `0`, value k = **–m**
- If regime starts with `1`, value k = **m – 1**

The regime contributes a scale of `useed^k`, where `useed = 2^(2^es)` and `k` is the regime value.

![image](https://github.com/user-attachments/assets/3f82aa2e-a3d5-42e6-9d99-321327d0934b)


> *Figure: Examples of how regime bits map to positive and negative powers of useed.*

Overall, an n-bit posit number (p) can represent the following numbers.
![image](https://github.com/user-attachments/assets/17e83c3d-62a1-4045-a0cf-a0e2eeaa260b)


---

### Example

With `es = 3`, the following posit (n=16 bits) represents ` 477/134217728 ≈ 3.55393 × 10^-6 `.

![image](https://github.com/user-attachments/assets/52e275ef-aa8a-405d-9ec6-d4c100c1d5a0)




---

### ⚙️ Posit(4,0) Format Breakdown:
In our implementation, we consider es=0 all the time, and for testing, we consider 4 bits posit. Therefore, our format is posit(4,0).

- Total width: 4 bits
- **Bit 0**: Sign
- **Regime**: Unary-encoded scale (dominant bits after sign)
- **Exponent**: None in Posit(4,0) (es = 0)
- **Fraction**: Remaining bits (if any)

> Posit(4,0) supports 16 unique values with higher density near ±1.
### Posit(4,0) Value Table

| Posit(4,0) | Value   |
|------------|---------|
| 0000       | 0       |
| 0001       | 0.125   |
| 0010       | 0.25    |
| 0011       | 0.5     |
| 0100       | 1.0     |
| 0101       | 1.5     |
| 0110       | 3.0     |
| 0111       | 6.0     |
| 1000       | NaR     |
| 1001       | -6.0    |
| 1010       | -3.0    |
| 1011       | -1.5    |
| 1100       | -1.0    |
| 1101       | -0.5    |
| 1110       | -0.25   |
| 1111       | -0.125  |



---

### Comparison: Posit vs IEEE-754 (Low Bit Widths)

Unlike IEEE-754 floats, Posit offers:
- No subnormal or reserved bit patterns
- Balanced value distribution
- Better coverage around commonly used values





For more details, refer to the original article:  
[SIGARCH: Posit - A Potential Replacement for IEEE-754](https://www.sigarch.org/posit-a-potential-replacement-for-ieee-754/)


## 7. Implementation
### FP16-POSIT4 multiplication 
#### Inputs

- `act[15:0]`: IEEE-754 FP16 activation  
  → 1-bit sign | 5-bit exponent | 10-bit mantissa  
- `w[3:0]`: Posit(4,0) weight (MSB first)
- Handshake/control:
  - `valid`: Enable processing of the next weight bit
  - `set`: Latch user-defined precision
  - `precision[3:0]`: Width of posit input (1–8 bits)
  - `clk`, `rst`: Clock and asynchronous reset


#### Outputs

- `sign_out`: Sign of the final product
- `exp_out[4:0]`: Final exponent result
- `mantissa_out[13:0]`: Accumulated fixed-point mantissa result
- `zero_out`: Asserted if decoded weight = 0
- `NaR_out`: Asserted if decoded weight = NaR
- `done`: High for 1 cycle when multiply is complete

#### Internal Architecture

##### Precision & Bit Scanner

- Latches user-specified precision on `set=1`
- A cycle counter walks through each bit of the weight while `valid=1`


##### Three-State FSM

#### 1. `SIGN` (First Cycle)
- Computes product sign: `sign_out = act_sign ⊕ w[MSB]`
- Seeds exponent with FP16 exponent
- Detects and flags `Zero` or `NaR`

#### 2. `REGIME` (Following Cycles)
- Counts identical regime bits to compute `k`
- Updates exponent: `exp_out += ±k`
- Captures FP16 mantissa for multiplication

#### 3. `MANTISSA` (Remaining Cycles)
- For each weight bit = 1:
  - Left-shifts mantissa (`align`)
  - May decrement exponent (to adjust hidden-one)
- For each weight bit = 0:
  - Mantissa contributes 0
  - Exponent remains unchanged


##### Mantissa Pipeline & Accumulation

- Two 14-bit registers: `mantissa_reg`, `mantissa_temp`
- A fixed-point adder adds the shifted FP16 mantissa every cycle:

##### Final Output and Completion

- The final result is presented on `mantissa_out` during the same cycle that `done` is asserted.
- This indicates the completion of the multiply operation.

---

##### Special Value Handling

- `zero_out` or `NaR_out` is asserted in the same cycle as `done` if:
  - Weight = `0000` → interpreted as **Zero**
  - Weight = `1000` → interpreted as **NaR (Not a Real)**
- All flags and internal state are cleared on `rst = 0`.

---

##### Timing Summary

- **Latency**: Equal to the selected `precision` in cycles  
  → e.g., **4 cycles** for `Posit(4,0)`
- Fully synchronous to `clk`
- Single-issue pipeline: can be re-triggered as soon as `done` de-asserts

---
### Creating the Custom IP and testing on board
We created a new IP for the FP16-POSIT4 multiplication module using the AXI4 peripheral Lite version. The modification of the code inside the AXI IP block is shown below:
### AXI-Lite Integration:
- instantiates the FP16-POSIT4 multiplication module inside the AXI Lite IP block:
```verilog
// ---------------- User-logic signals (STEP-1) ---------------- 
wire [13:0] mine_mantissa;
wire        mine_sign;
wire [4:0]  mine_exp;
wire        mine_done;
wire        mine_zero;
wire        mine_nar;

wire [31:0] mine_out_bus;  // Packed 32-bit read-back word
// -------------------------------------------------------------

// ===================== mine core instance (STEP-2) =====================
mine #(
    .ACT_WIDTH (16),
    .EXP_WIDTH (5),
    .MAN_WIDTH (10)
) u_mine (
    .clk          (S_AXI_ACLK),
    .rst          (S_AXI_ARESETN),        // mine uses active-high reset
    // ---------- inputs driven from slave register-0 ----------
    .act          (slv_reg0[15:0]),       // 16-bit activation input
    .w            (slv_reg0[19:16]),      // 4-bit Posit weight
    .valid        (slv_reg0[20]),         // 1-bit valid signal
    .set          (slv_reg0[21]),         // 1-bit precision set signal
    .precision    (slv_reg0[25:22]),      // 4-bit precision selector
    // ---------- outputs --------------------------------------
    .sign_out     (mine_sign),
    .exp_out      (mine_exp),
    .mantissa_out (mine_mantissa),
    .done         (mine_done),
    .zero_out     (mine_zero),
    .NaR_out      (mine_nar)
);

// ========== Output Packing (STEP-3) ==========
assign mine_out_bus = {
    mine_sign,         // [31]
    mine_done,         // [30]
    mine_zero,         // [29]
    mine_nar,          // [28]
    mine_exp,          // [27:23]
    mine_mantissa,     // [22:9]
    9'b0               // [8:0] - Unused
};
// =======================================================================
```
- Set the output inside the AXI Lite IP block:
```verilog
// AXI readback register address mapping
case (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
    2'h0   : reg_data_out <= slv_reg0;
    2'h1   : reg_data_out <= mine_out_bus;  // Output result
    2'h2   : reg_data_out <= slv_reg2;
    2'h3   : reg_data_out <= slv_reg3;
    default: reg_data_out <= 32'b0;
endcase
```


The following figure shows the block design.
> ![image](https://github.com/user-attachments/assets/96e9b9bb-d956-4eb8-88b5-5fbc1c016d49)
> *Figure: Block design diagram.*

Then we export this hardware and test it on board via the Vitis tool. This demo is represented in the following figure and demo video. 
![image](https://github.com/user-attachments/assets/60b72d71-219f-46fe-b511-31fec72f3e8b)
> *Figure: Demo of the FP16-POSIT4 Mul Custom IP(Write 0x01351234 on Register 0, Read 0x020C6800 from Register.)*

### FP16-POSIT4 MAC 

This module performs a **Multiply-Accumulate (MAC)** operation where:
- The activation input is in **FP16 format**
- The weight is in **Posit(4,0)** format

#### Internal Architecture

The MAC unit connects two modules in sequence:

1. **Multiplier**  
   - Multiplies `act × w`
   - Produces:
     - `mantissa_out`: 14-bit fixed-point product
     - `exp_out`: unbiased exponent
     - `sign_out`, `zero`, `NaR`
   - Triggers `done` as `start_acc` for the accumulator

2. **Accumulator**  
   - Aligns and adds/subtracts mantissa fragments into a 32-bit accumulator
   - Adjusts mantissa based on exponent difference (`exp_in - exp_set`)
   - Applies sign correction
   - Outputs:
     - Final `fixed_point_out` and `exp_out`
     - Asserts `done` and `NaR_out` accordingly

##### Key Features

- Fully pipelined and clock-synchronous
- Handles Zero and NaR detection
- Parameterizable width for the accumulator and activation input
- Aligns mantissa dynamically using the exponent delta
  


## 8. Results:

### 8.1 Implementation and Verification -  FP-Posit MAC
- FP-Posit Multiplication Testbench Result:
  <p align="center">
  <img src="Images/posit_mul.png" alt="fp_posit_mul" width="80%">
</p>

Example: FP16 × Posit(4,0) Multiplication

- **Input Activation (`act`)**: `0x1234`  
  → FP16 = **1.55078125 × 2⁻¹¹**

- **Input Weight (`w`)**: `0b0101`  
  → Posit(4,0) = **1.5**
  
Expected Result = 1.55078125 × 2⁻¹¹ × 1.5 ≈ 0.0011358261

Simulation Output

- `mantissa_out = 0x129C` → Decimal = **4.65234375**
- `exp_out = 0x3` → Exponent = **3**

**Scaled Output (Final Result)**:  

4.65234375 × 2^{-12} = 0.0011358261

- FP-Posit Accumulator Testbench Result:

  <p align="center">
  <img src="Images/posit_acc.png" alt="fp_posit_acc" width="80%">
</p>


- FP-Posit MAC Testbench Result:

    <p align="center">
  <img src="Images/image.png" alt="fp_posit_mac" width="80%">
</p>
MAC Operation Example

- **Accumulator Input (`acc`)**: `0x0000001e`  
  → Decimal = **0.029296875**  
  → Scaled value:  0.029296875 × 2^{-12} = 0.0000071526
- **Previous Multiply Output:**
0.0011358261 + 0.0000071526 = 0.0011429787

Simulation Output
- **Output (`fixed_point_out`)**: `0x000012ba`  
→ Decimal = **4.681640625**  
→ Scaled value: 4.681640625 × 2⁻¹² = 0.0011429787


### 8.2 Implementation and Verification - FP-Int MAC
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


  
## 8. Comparing FP-Posit MAC and FP-Int MAC 

### 8.1 FP-Posit MAC
Netlist Diagram

<p align="center">
  <img src="Images/FP-Posit-Mac-device.png"" alt="fp_int" width="50%">
</p>

Resource Utilization

| LUT | FF |
| -------- | -------- |
| 460 | 695 |

### 8.2 FP-Int MAC

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

- **Mixed-format arithmetic** using FP16 activations and Posit(4,0) weights successfully reduces hardware complexity while maintaining reasonable numerical precision.
- **Posit representation** provides higher dynamic precision than Int4 and is more efficient at representing real-world values near 1.0, making it suitable for AI inference.
- The custom Multiply module is fully pipelined, tested on PYNQ-Z1, and integrated with AXI-Lite, demonstrating complete functionality.
- Compared to FP16-Int4 baseline:
  - **FP16-Posit4 MAC** achieved ~30% lower LUT usage.
  - Simulation results confirmed accurate scaled computation and accumulation.

## 9. Conclusion

In this project, we developed a custom IP core that combines FP16 activations with 4-bit Posit weights to perform real-number multiplication. By leveraging the tapered precision and compact encoding of the Posit format, we achieved reduced resource utilization on the FPGA compared to a traditional FP16-Int4 MAC baseline. Our implementation—synthesized, integrated with AXI-Lite, and verified on hardware—demonstrates that Posit arithmetic is advantageous for hardware-efficient neural computations. This work highlights the potential of hybrid-precision designs for low-power AI accelerators.

## References
- Gustafson, J. (2017). Posit: A potential replacement for IEEE-754. Retrieved from https://www.sigarch.org/posit-a-potential-replacement-for-ieee-754/
- Gao, Y. (2023). FP-INT-MAC: A Baseline Integer MAC Core with FP16 Activations. GitHub repository: https://github.com/YiminGao0113/FP-INT-MAC


