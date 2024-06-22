module SPI_ref(rx_data,SS_n,rst_n,MOSI,clk,rx_valid,tx_valid,MISO,tx_data);
	input tx_valid;
	input SS_n,rst_n,MOSI,clk;
	input [7:0] tx_data;
	output reg rx_valid;
	output reg [9:0] rx_data;
	output reg MISO;

	parameter IDLE     =3'b000;
	parameter CHK_CMD  =3'b001;
	parameter WRITE    =3'b010;
	parameter READ_ADD =3'b011;
	parameter READ_DATA=3'b100;

	reg  addr_data_sel=0;
	reg [9:0] rx_data_serial;
	(* fsm_encoding = "gray" *)  //high setup slack after implementation.
	reg [2:0] cs,ns;

	bit sending_flag;

	integer i=0;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) 
			cs <= IDLE;
		else 
			cs <= ns;
	end


	always @(cs or SS_n or MOSI) begin
		case(cs) 
			IDLE:
				if(SS_n)
					ns = IDLE;
				else 
					ns = CHK_CMD;
			CHK_CMD:
				if (SS_n) 
					ns = IDLE;
				else if(!MOSI)
					ns = WRITE;
				else if (!addr_data_sel) 
						ns = READ_ADD;
					else 
						ns = READ_DATA;					
			WRITE:
				if (SS_n) 
					ns = IDLE;
				else 
					ns = WRITE;
			READ_DATA:begin
				if (SS_n) 
					ns = IDLE;
				else begin
					ns = READ_DATA;
					//addr_data_sel=0;
				end		
			end		
			READ_ADD:
				if (SS_n) 
					ns = IDLE;
				else begin
					ns = READ_ADD;	
					//addr_data_sel=1;	
				end 	
		
			default: ns = IDLE;
		endcase
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			MISO <= 0;
			addr_data_sel <= 0;
			i <= 0;
			rx_valid <= 0;
			sending_flag <= 0;
			rx_data_serial <= 0;
			rx_data <= 0;
		end 
		else 
			case (cs) 
				READ_ADD:begin
					if (i <10) begin
						rx_data_serial[9-i] <= MOSI;
						rx_valid <= 0;
						i        <= i+1;
					end
					else begin
						rx_valid <=1;
						rx_data  <= rx_data_serial;
						
						addr_data_sel <= 1'b1;
					end
				end
				WRITE:begin
					if (i <10) begin
						rx_data_serial[9-i] <= MOSI;
						rx_valid            <= 0;
						i                   <=i+1;
					end
					else begin
						rx_valid <=1;
						rx_data <= rx_data_serial;
					end
				end
				READ_DATA:begin
					if (i <10) begin
						rx_data_serial[9-i] <= MOSI;
						i <=i+1;
					end
					else if (i==10) begin
					    i <=i+1;
						rx_data  <= rx_data_serial;
						rx_valid <= 1'b1;
					end
					else if (i<20) begin
						rx_valid <= 1'b0;
						 if(tx_valid) 
						 	sending_flag = 1'b1;

						 if (sending_flag)
							MISO <= tx_data[19-i];
						 	
						i <=i+1;
					end
					else  begin
						MISO <= 0;
						
						addr_data_sel <= 1'b0;
					end
				end
				default: begin
					MISO           <= 0;	
					i              <= 0;
					rx_valid       <= 0;
					sending_flag   <= 0;
					rx_data_serial <= 0;
					rx_data 	   <= 0;
				end
			endcase
	end
endmodule