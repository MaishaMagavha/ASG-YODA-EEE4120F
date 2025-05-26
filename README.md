# Arithmetic Series Generator (ASG) 🚀

This project implements an Arithmetic Series Generator (ASG) in Verilog for deployment on an FPGA (Artix-7). The design generates arithmetic sequences using user-defined start value, step size, and number of terms. It features a lightweight architecture, UART output interface, and performance benchmarking against MATLAB implementations.

## 🔧 Features

- Configurable arithmetic series: start (`a`), step (`d`), and terms (`n`)
- 32-bit IEEE-754 floating-point arithmetic
- Support for positive and negative step sizes
- UART communication for result transmission
- MATLAB-verified testbench
- Resource-light and FPGA-ready (Vivado-compatible)

## 📁 Project Structure

ASG_Core/
│
├── src/ # Verilog modules (ASG core, UART, controller)
├── testbench/ # Verilog testbenches and simulation files
├── matlab/ # MATLAB scripts for verification
├── docs/ # Lab report, diagrams, figures
├── vivado/ # Vivado project files and constraints
└── README.md


## 🧪 Functional Verification

Eight benchmark test cases were used to verify the correctness of the ASG. These tested various conditions including:

- Positive and negative steps
- Large values
- Fine-grained precision
- Boundary testing (255 terms)

All tests passed when compared with MATLAB ground truth values. Test case outputs, timing results, and pass/fail status are documented in the lab report.

## ⚡ Performance Benchmarking

- Executed on Artix-7 at 100 MHz
- Compared against MATLAB using `tic`/`toc`
- Achieved up to **16× speedup** for short sequences
- MATLAB was faster for very long sequences due to vectorization

## 📊 Resource Utilization (Artix-7)

- LUTs used: 46 / 63,400 (0.07%)
- Flip-Flops: 44 / 126,800 (0.03%)
- BRAM: 1 / 270 (0.37%)
- DSPs: 0
- I/O: 60 / 210 (28.57%) — mainly UART and control signals

## 🔋 Power Analysis

- Total Power: 8.52 W
- Dynamic Power: 8.36 W (98%)
- Static Power: 0.16 W
- Dominant I/O Power: 93% of dynamic power from UART
- Safe junction temperature: 63.9 °C (well below thermal limit)

## 🖥️ Target Platform

- **FPGA**: Xilinx Artix-7 (e.g., Basys3)
- **Tools**: Xilinx Vivado 2020.2+ for synthesis & implementation
- **Languages**: Verilog HDL, MATLAB (for comparison)


