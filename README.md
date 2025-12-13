# INT8 Systolic Array AI Accelerator on Kintex-7 FPGA

## Overview
This project implements a **4x4 Systolic Array Matrix Multiplier** on a Xilinx Kintex-7 FPGA, designed to accelerate Deep Learning inference workloads. The architecture utilizes a **Weight-Stationary** dataflow, similar to the Google TPU, to maximize data reuse and energy efficiency.

The design performs **INT8 (8-bit Integer)** matrix-vector multiplication, the industry standard for low power Edge AI inference. It features a custom **Data Skewing Unit** to manage systolic wavefront propagation.

## Performance Metrics (Post-Synthesis)
Synthesized on **Xilinx Kintex-7 (XC7K70T)** using Vivado 2022.2.
* **Max Frequency:** 205 MHz (WNS: +5.137ns)
* **Power Consumption:** 123 mW (Total On-Chip Power)
* **Resource Utilization:** ~1,500 LUTs (Low-area footprint)
* **Throughput:** 16 OPS/cycle (Operations Per Second)

## Repository Structure
* **src/** – Verilog source files (`pe.v`, `systolic_array.v`, `matrix_accelerator.v`, `skew_buffer.v`).
* **tb/** – Testbench modules (`tb_matrix_accelerator.v`, `tb_pe.v`).
* **constraints/** – XDC file for timing constraints (100MHz target).
* **snapshots/** – Utilization report, power report, and timing summaries.
* **doc/** – Design documentation.

## Hardware Architecture
1.  **Processing Element (PE):**
    * Implements `Psum = Psum + (Input * Weight)`.
    * Uses **INT8** for inputs/weights and **24-bit** accumulation to prevent overflow.
    * Supports 2's complement signed arithmetic.
2.  **Systolic Mesh (4x4):**
    * Homogeneous grid with local interconnects (North-to-South for Inputs, West-to-East for Partial Sums).
3.  **Skew Buffer:**
    * Aligns parallel input data into a diagonal wavefront (Delay T = Col_Index).

## How to Use
1.  **Vivado Setup:**
    * Create a new project targeting **Kintex-7 (XC7K70T)**.
    * Add all files from the `src` directory.
    * Add `timing.xdc` from `constraints`.
2.  **Simulation:**
    * Set `tb_matrix_accelerator.v` as the Top Module.
    * Run Behavioral Simulation.
    * Observe `result_out` after splitting into 4 blocks of 24-bit results.
3.  **Synthesis:**
    * Run Synthesis to generate the netlist.
    * Check "Report Utilization" and "Report Timing" for PPA metrics.
---
**Status:** Completed December 2025
