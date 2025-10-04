// This code uses the VGA demo provided by the teaching team: "object.zip" at https://q.utoronto.ca/courses/363319/pages/vga-adapter
// This code uses the audio demo provided by the teaching team: "Audio_Demo.zip" at https://www.eecg.utoronto.ca/~pc/courses/241/DE1_SoC_cores/audio/audio.html
// This code uses the PS/2 demo provided by the teaching team: "PS/2_Demo.zip" at https://www.eecg.utoronto.ca/~pc/courses/241/DE1_SoC_cores/ps2/ps2.html
module vga_demo(
    // Inputs
	CLOCK_50,
	KEY,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,
	PS2_CLK,
	PS2_DAT,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	SW,
	
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7,
	
	VGA_R, VGA_G, VGA_B,
   VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
);

    input				CLOCK_50;
	input		[3:0]	KEY;
	input		[9:0]	SW;

	input				AUD_ADCDAT;

	// Bidirectionals
	inout				AUD_BCLK;
	inout				AUD_ADCLRCK;
	inout				AUD_DACLRCK;

	inout				FPGA_I2C_SDAT;
	inout				PS2_CLK;
	inout				PS2_DAT;

	// Outputs
	output				AUD_XCK;
	output				AUD_DACDAT;

	output				FPGA_I2C_SCLK;
	// HEX

	output		[6:0]	HEX0;
	output		[6:0]	HEX1;
	output		[6:0]	HEX2;
	output		[6:0]	HEX3;
	output		[6:0]	HEX4;
	output		[6:0]	HEX5;
	output		[6:0]	HEX6;
	output		[6:0]	HEX7;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;


	// Internal Wires
	wire				audio_in_available;
	wire		[31:0]	left_channel_audio_in;
	wire		[31:0]	right_channel_audio_in;
	wire				read_audio_in;

	wire				audio_out_allowed;
	wire		[31:0]	left_channel_audio_out;
	wire		[31:0]	right_channel_audio_out;
	wire				write_audio_out;

	// Internal Registers

	reg [19:0] delay_cnt;
	reg [19:0] delay;

	reg snd;

	reg [31:0] count;
	reg [25:0] fastcount;
	wire enable;
	wire [6:0] octave;
	reg [3:0] pedal;
	
    parameter SCREEN_WIDTH = 160;
    parameter SCREEN_HEIGHT = 120;
	 wire [2:0] VGA_COLOR;

    // VGA signals
    reg [7:0] x_counter;
    reg [6:0] y_counter;
    reg plot;


    wire [14:0] game_address;
    wire [2:0] game_color;

    wire [14:0] menu_address;
    wire [2:0] menu_color;
	 
	 wire [14:0] do_address;
    wire [2:0] do_color;
	 
	 wire [14:0] re_address;
    wire [2:0] re_color;
	 
	 wire [14:0] mi_address;
    wire [2:0] mi_color;
	 
	 wire [14:0] fa_address;
    wire [2:0] fa_color;
	 
	 wire [14:0] so_address;
    wire [2:0] so_color;
	 
	 wire [14:0] la_address;
    wire [2:0] la_color;
	 
	 wire [14:0] si_address;
    wire [2:0] si_color;
	 
	 wire [14:0] do1_address;
    wire [2:0] do1_color;
	 
	 wire [14:0] dosharp_address;
    wire [2:0] dosharp_color;
	 
	 wire [14:0] resharp_address;
    wire [2:0] resharp_color;
	 
	 wire [14:0] fasharp_address;
    wire [2:0] fasharp_color;
	 
	 wire [14:0] sosharp_address;
    wire [2:0] sosharp_color;
	 
	 wire [14:0] lasharp_address;
    wire [2:0] lasharp_color;

    // Reset signal
    wire resetn;
    assign resetn = KEY[0];
    // FSM states
    // 状态定义
	parameter MENU = 2'b00, GAME = 2'b01;

	// 状态变量
	reg [1:0] current_state, next_state;

    // FSM
    always @(posedge CLOCK_50) begin
        if (!resetn)
            current_state <= MENU; 
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            MENU: begin
                if (code == 8'h5A)
                    next_state = GAME;
                else
                    next_state = MENU;
            end
            GAME: begin
                if (code == 8'h76)
                    next_state = MENU; 
                else
                    next_state = GAME; 
            end
//            default: next_state = MENU;
        endcase
    end

    // VGA scanning counters
    always @(posedge CLOCK_50) begin
        if (!resetn) begin
            x_counter <= 0;
            y_counter <= 0;
            plot <= 0;
        end else begin
            plot <= 1;

            if (x_counter < SCREEN_WIDTH - 1)
                x_counter <= x_counter + 1;
            else begin
                x_counter <= 0;
                if (y_counter < SCREEN_HEIGHT - 1)
                    y_counter <= y_counter + 1;
                else
                    y_counter <= 0;
            end
        end
    end

    // Generate VGA_X and VGA_Y signals
    wire [7:0] VGA_X = x_counter;
    wire [6:0] VGA_Y = y_counter;

    // Address calculations for menu and background memory
    assign menu_address = (y_counter * SCREEN_WIDTH) + x_counter;
    assign game_address = (y_counter * SCREEN_WIDTH) + x_counter;
	 assign do_address =  (y_counter * SCREEN_WIDTH) + x_counter;
	 assign re_address =  (y_counter * SCREEN_WIDTH) + x_counter;
	 assign mi_address =  (y_counter * SCREEN_WIDTH) + x_counter;
	 assign fa_address =  (y_counter * SCREEN_WIDTH) + x_counter;
	 assign so_address =  (y_counter * SCREEN_WIDTH) + x_counter;
	 assign la_address =  (y_counter * SCREEN_WIDTH) + x_counter;
	 assign si_address =  (y_counter * SCREEN_WIDTH) + x_counter;
	 assign do1_address =  (y_counter * SCREEN_WIDTH) + x_counter;
	 assign dosharp_address =  (y_counter * SCREEN_WIDTH) + x_counter;
	 assign resharp_address =  (y_counter * SCREEN_WIDTH) + x_counter;
	 assign fasharp_address =  (y_counter * SCREEN_WIDTH) + x_counter;
	 assign sosharp_address =  (y_counter * SCREEN_WIDTH) + x_counter;
	 assign lasharp_address =  (y_counter * SCREEN_WIDTH) + x_counter;
	 
    // Instantiate menu background memory
    menu menu_inst (
        .address(menu_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(menu_color)
    );
    
    // Instantiate game background memory
    Game game_inst (
        .address(game_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(game_color)
    );
	 
	 Do do_inst (
        .address(do_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(do_color)
    );
	 
	 Re re_inst (
        .address(re_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(re_color)
    );
	 
	 Mi mi_inst (
        .address(mi_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(mi_color)
    );
	 
	 Fa fa_inst (
        .address(fa_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(fa_color)
    );
	 
	 So so_inst (
        .address(so_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(so_color)
    );
	 
	 La la_inst (
        .address(la_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(la_color)
    );
	 
	 Si si_inst (
        .address(si_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(si_color)
    );
	 
	 Do1 do1_inst (
        .address(do1_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(do1_color)
    );
	 
	 Dosharp dosharp_inst (
        .address(dosharp_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(dosharp_color)
    );
	 Resharp resharp_inst (
        .address(resharp_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(resharp_color)
    );
	 Fasharp fasharp_inst (
        .address(fasharp_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(fasharp_color)
    );
	 Sosharp sosharp_inst (
        .address(sosharp_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(sosharp_color)
    );
	 
	 Lasharp lasharp_inst (
        .address(lasharp_address),
        .clock(CLOCK_50),
        .data(3'b000),   // Not used, ROM
        .wren(1'b0),     // Write enable is low for ROM
        .q(lasharp_color)
    );
	 
//	 wire enable_05;
//	 reg keep;
//	 reg [25:0] fastcount2;
//		
//	always@(posedge CLOCK_50) begin
//		// When break code send
//		if(code == 8'hF0) begin
//			code <= 8'h99;
//			fastcount2 <= 26'd10000000;
//			keep <= 1;
//		end
//		// initial condition
//		else if(code == 8'h00) begin
//			keep <= 0;
//		end
//		// count for 0.05 sec
//		else if(fastcount2 != 26'd0) begin
//			fastcount2 <= fastcount2 - 1'b1;
//		end
//		else if(fastcount2 == 26'd0) begin
//			keep <= 0;
//		end
//		
//		if(keep <= 0) begin
//			code <= code1;
//		end
//			
//		end
		

    // Determine VGA color
    reg [2:0] color;
    always @(posedge CLOCK_50) begin
        if (!resetn)
            color <= menu_color; // Show menu background after reset
        else begin
            case (current_state)
                MENU: color <= menu_color; // Menu background
                GAME: 
					 if (isPlay == 1 && code == 8'h1C) begin
					 color <= do_color;
					 end
					 else if (isPlay == 1 &&code == 8'h1B) begin
					 color <= re_color;
					 end
					 else if (isPlay == 1 &&code == 8'h23) begin
					 color <= mi_color;
					 end
					 else if (isPlay == 1 &&code == 8'h2B) begin
					 color <= fa_color;
					 end
					 else if (isPlay == 1 &&code == 8'h34) begin
					 color <= so_color;
					 end
					 else if (isPlay == 1 &&code == 8'h33) begin
					 color <= la_color;
					 end
					 else if (isPlay == 1 &&code == 8'h3B) begin
					 color <= si_color;
					 end
					 else if (isPlay == 1 &&code == 8'h42) begin
					 color <= do1_color;
					 end
					 else if (isPlay == 1 &&code == 8'h1D) begin
					 color <= dosharp_color;
					 end
					 else if (isPlay == 1 &&code == 8'h24) begin
					 color <= resharp_color;
					 end
					 else if (isPlay == 1 &&code == 8'h2C) begin
					 color <= fasharp_color;
					 end
					 else if (isPlay == 1 &&code == 8'h35) begin
					 color <= sosharp_color;
					 end
					 else if (isPlay == 1 &&code == 8'h3C) begin
					 color <= lasharp_color;
					 end
					 else begin
					 color <= game_color;
					 end
                default: color <= menu_color;
            endcase
        end
    end

    assign VGA_COLOR = color;
	 
	 
	 always @(posedge CLOCK_50)
	if(delay_cnt == delay) begin
		delay_cnt <= 0;
		snd <= !snd;
	end else delay_cnt <= delay_cnt + 1;

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
	assign octave = SW[7:1];
	 
	always @ (*) begin
		if (SW[0] == 1)
			pedal = 4'd9;
		else
			pedal = 4'd5;
	end
 
 always @ (*) begin // added key selection and octave selection
	if(current_state == GAME) begin
			if (octave == 7'b0000001) begin // 1st octave
			case(code)
				8'h1C: delay = 20'b10111000111101001000; // C
				8'h1D: delay = 20'b10101110011000101110; // C sharp
				8'h1B: delay = 20'b10100100111101011100; // D
				8'h24: delay = 20'b10011100100000000010; // D sharp
				8'h23: delay = 20'b10010100110111011100; // E
				8'h2B: delay = 20'b10001010101101110110; // F
				8'h2C: delay = 20'b10000100101011110110; // F sharp
				8'h34: delay = 20'b01111100100011111100; // G
				8'h35: delay = 20'b01110101011000000001; // G sharp
				8'h33: delay = 20'b01101110111110010001; // A
				8'h3C: delay = 20'b01101001001110111010; // A sharp
				8'h3B: delay = 20'b01100010011100011010; // B
				8'h42: delay = 20'b01011101111001100111; // C
				default: delay = 20'b00000000000000000000;
				endcase
				end
			else if (octave == 7'b0000010) begin // 2nd octave
			case(code)
				8'h1C: delay = 20'b01011101111001100111; // Cw
				8'h1D: delay = 20'b01011000011101001111; // C sharp
				8'h1B: delay = 20'b01010011100111000010; // D
				8'h24: delay = 20'b01001110010000000001; // D sharp
				8'h23: delay = 20'b01001010011011101110; // E
				8'h2B: delay = 20'b01000110001001111100; // F
				8'h2C: delay = 20'b01000010010101111011; // F sharp
				8'h34: delay = 20'b00111110010001111110; // G
				8'h35: delay = 20'b00111010101100000001; // G sharp
				8'h33: delay = 20'b00110111011111001001; // A
				8'h3C: delay = 20'b00110100001010101011; // A sharp
				8'h3B: delay = 20'b00110001100111110100; // B
				8'h42: delay = 20'b00101110100101111000; // C
				default: delay = 20'b00000000000000000000;
				endcase
				end
			else if (octave == 7'b0000100) begin // 3rd octave
			case(code)
				8'h1C: delay = 20'b00101110100101111000; // C
				8'h1D: delay = 20'b00101011111010010000; // C sharp
				8'h1B: delay = 20'b00101001100001010100; // D
				8'h24: delay = 20'b00100111001000000000; // D sharp
				8'h23: delay = 20'b00100100111111011011; // E
				8'h2B: delay = 20'b00100010111000001001; // F
				8'h2C: delay = 20'b00100000111111011111; // F sharp
				8'h34: delay = 20'b00011111001000111111; // G
				8'h35: delay = 20'b00011101010110000000; // G sharp
				8'h33: delay = 20'b00011011101111100100; // A
				8'h3C: delay = 20'b00011010001100100000; // A sharp
				8'h3B: delay = 20'b00011000101101011111; // B
				8'h42: delay = 20'b00010111010010111100; // C
				default: delay = 20'b00000000000000000000;
				endcase
				end
				
			else if (octave == 7'b0001000) begin // 4th octave
				case(code)
				8'h1C: delay = 20'b00010111010010111100; // C
				8'h1D: delay = 20'b00010110000010001101; // C sharp
				8'h1B: delay = 20'b00010100110000101010; // D
				8'h24: delay = 20'b00010011101000000010; // D sharp
				8'h23: delay = 20'b00010010011111101110; // E
				8'h2B: delay = 20'b00010001011111010001; // F
				8'h2C: delay = 20'b00010000011111110000; // F sharp
				8'h34: delay = 20'b00001111100100100000; // G
				8'h35: delay = 20'b00001110101101010001; // G sharp
				8'h33: delay = 20'b00001101110111110010; // A
				8'h3C: delay = 20'b00001101000110010000; // A sharp
				8'h3B: delay = 20'b00001100010110101111; // B
				8'h42: delay = 20'b00001011101010111001; // C
				default: delay = 20'b00000000000000000000;
				endcase
				end
			
			else if (octave == 7'b0010000) begin // 5th octave
			case(code)
				8'h1C: delay = 20'b00001011101010111001; // C
				8'h1D: delay = 20'b00001011000001000110; // C sharp
				8'h1B: delay = 20'b00001010011001011101; // D
				8'h24: delay = 20'b00001001110100000001; // D sharp
				8'h23: delay = 20'b00001001010000110000; // E
				8'h2B: delay = 20'b00001000101111101001; // F
				8'h2C: delay = 20'b00001000001111111000; // F sharp
				8'h34: delay = 20'b00000111110010010000; // G
				8'h35: delay = 20'b00000111010110000100; // G sharp
				8'h33: delay = 20'b00000110111011111001; // A
				8'h3C: delay = 20'b00000110100011001000; // A sharp
				8'h3B: delay = 20'b00000110001011011000; // B
				8'h42: delay = 20'b00000101110101000110; // C
				default: delay = 20'b00000000000000000000;
				endcase
				end
				
			else if (octave == 7'b0100000) begin // 6th octave
			case(code)
				8'h1C: delay = 20'b00000101110101000110; // C
				8'h1D: delay = 20'b00000101100000001111; // C sharp
				8'h1B: delay = 20'b00000101001100011101; // D
				8'h24: delay = 20'b00000100111001110000; // D sharp
				8'h23: delay = 20'b00000100101000001010; // E
				8'h2B: delay = 20'b00000100010111100111; // F
				8'h2C: delay = 20'b00000100000111111100; // F sharp
				8'h34: delay = 20'b00000011111001001000; // G
				8'h35: delay = 20'b00000011101011001011; // G sharp
				8'h33: delay = 20'b00000011011101111101; // A
				8'h3C: delay = 20'b00000011010001011101; // A sharp
				8'h3B: delay = 20'b00000011000101101100; // B
				8'h42: delay = 20'b00000010111010101001; // C
				default: delay = 20'b00000000000000000000;
				endcase
				end
				
			else if (octave == 7'b1000000) begin // 7th octave
			case(code)
				8'h1C: delay = 20'b00000010111010101001; // C
				8'h1D: delay = 20'b00000010110000001100; // C sharp
				8'h1B: delay = 20'b00000010100110010011; // D
				8'h24: delay = 20'b00000010011100111100; // D sharp
				8'h23: delay = 20'b00000010010100001000; // E
				8'h2B: delay = 20'b00000010001011110100; // F
				8'h2C: delay = 20'b00000010000011111110; // F sharp
				8'h34: delay = 20'b00000001111100100100; // G
				8'h35: delay = 20'b00000001110101100110; // G sharp
				8'h33: delay = 20'b00000001101110111110; // A
				8'h3C: delay = 20'b00000001101000110000; // A sharp
				8'h3B: delay = 20'b00000001100010111000; // B
				8'h42: delay = 20'b00000001011101010100; // C
				default: delay = 20'b00000000000000000000;
				endcase
				end
			end
		end

		assign enable = (fastcount == 26'd0) ? 1 : 0; // added a half-second counter

		always@(posedge CLOCK_50)
		begin	
			if (enable)
				fastcount <= 26'd50000000;
			else 
				fastcount <= fastcount - 1'b1;
		end


		always@(posedge CLOCK_50) // gradually decreases sound amplitude
			begin
				if (code == 8'h00 | code == 8'hF0)
					 count <= 32'd10000000;
				else if (enable == 1)
					count <= count * pedal / 4'd10;
				else if (isPlay == 0)
					count <=32'd0;
			end

		wire isPlay = (count > 5000000) ? 1 : 0;
		wire [31:0] sound = (code == 8'hF0) ? 0 : snd ? count : -count;

		assign read_audio_in	= audio_in_available & audio_out_allowed;
		assign left_channel_audio_out	= left_channel_audio_in+sound;
		assign right_channel_audio_out = right_channel_audio_in+sound;
		assign write_audio_out			= audio_in_available & audio_out_allowed;

    // VGA Adapter instantiation
    vga_adapter VGA (
        .resetn(resetn),
        .clock(CLOCK_50),
        .colour(VGA_COLOR),
        .x(VGA_X),
        .y(VGA_Y),
        .plot(plot),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );
    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "Piano.mif"; // Use a solid black background
	 wire [7:0] code;
	 wire key_pressed;

	//ps2 keyboard
	ps2 ps2_init (
		// Inputs
		.CLOCK_50(CLOCK_50),
		.KEY(KEY),

		// Bidirectionals
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		
		// Outputs
		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX2(HEX2),
		.HEX3(HEX3),
		.HEX4(HEX4),
		.HEX5(HEX5),
		.HEX6(HEX6),
		.HEX7(HEX7),
		.code(code),
		.key_pressed(key_pressed)
		
	);
	
	// audio controller
	Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY[0]),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

	);

	avconf #(.USE_MIC_INPUT(1)) avc (
		.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
		.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
		.CLOCK_50					(CLOCK_50),
		.reset						(~KEY[0])
	);
endmodule
