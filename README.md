# FPGA-Digital-Piano-De1-SOC-ECE241
A keyboard-controlled digital piano on the DE1-SoC FPGA board.
Input via PS/2 keyboard, on-screen feedback via VGA (640×480), and audio output to external speakers through the board’s line-out jack.

# Features

88-note range with octave shift

Record & playback (BRAM buffer)

Debounced key scan, smooth UI on VGA

Modular RTL: input → control → synth → audio → VGA

# Tech Stack

(System)Verilog · Quartus Prime · ModelSim/Questa · PS/2 scan decoder · wavetable/ADSR synth · audio FIFO · VGA timing

## Build & Run

1. Open `quartus/*.qpf` in Quartus; set **Top-Level Entity** = `vga_demo`.
2. Compile → program the generated `output_files/*.sof` to DE1-SoC.
3. Connect PS/2 keyboard, VGA monitor (640×480@60), and external speakers to line-out.
4. Power on and play; use octave controls as needed.
