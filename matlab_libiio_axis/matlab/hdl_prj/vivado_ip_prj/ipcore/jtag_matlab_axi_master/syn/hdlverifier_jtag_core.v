`timescale 1 ns / 1 ns
module hdlverifier_jtag_core
#(parameter JTAG_ID=2)
(
// Clock
    output tck,
// Reset
    output reg reset,    
// Memory mapped register interface
    output reg [4:0]  reg_addr,
    output reg [31:0] reg_wdata,
    output reg        reg_write,
    input      [31:0] reg_rdata,
// Interface for receiving captured data
    output reg shift_out_state,
    output reg shift_out_en,
    input  shift_out_data,
// Interface for writing large amount of data
    output reg shift_in_state,
    output reg shift_in_en,
    output reg shift_in_data    
);
  
localparam      STATE_IDLE      = 4'd0,
                STATE_HEADER    = 4'd1,
                STATE_CMD       = 4'd2,
                STATE_WRITE_REG = 4'd3,
                STATE_READ_REG  = 4'd4,
                STATE_WAIT_PAD  = 4'd5,
                STATE_WR_TRANSIT= 4'd6, // Transition state between write and read
                STATE_READ_DATA = 4'd7, // Transmit data from FPGA to host
                STATE_WRITE_DATA= 4'd8; // Transmit data from host to FPGA

localparam      CMD_REG_WRITE = 3'b001;
localparam      CMD_REG_READ  = 3'b010;
localparam      CMD_DATA_READ = 3'b100;
localparam      CMD_DATA_WRITE= 3'b101;
 
localparam CMD_WIDTH = 8;

localparam  WR = 1'b1,
            RD = 1'b0;

//=======================================================
//  REG declarations
//=======================================================   
reg [3:0]               state_reg;     // sate fo VJTAG TX/RX

reg  [31:0] tdi_shift_reg;
reg [31:0] tdi_shift_reg_next;

reg [7:0] counter;

reg [CMD_WIDTH - 1 :0] command_reg;
reg [2:0]  pad_len;
reg [31:0] read_reg;

//=======================================================
//  WIRE declarations 
//=======================================================   
// Connection with JTAG IP
reg tdo;
wire tdi;
wire capture_dr;
wire shift_dr;
wire update_dr;
wire jtag_reset;

always@(*) begin
    tdo <= (command_reg[7:5] == CMD_DATA_READ) ? shift_out_data : read_reg[0];
    reset <= jtag_reset;
    shift_out_state <= (command_reg[7:5] == CMD_DATA_READ);
    shift_in_state  <= (command_reg[7:5] == CMD_DATA_WRITE);
    tdi_shift_reg_next <= {tdi, tdi_shift_reg[31:1]};
end
            
always@(posedge tck) 
begin
    if(jtag_reset || capture_dr)
        tdi_shift_reg <= 32'b0;
    else if(shift_dr)
        tdi_shift_reg <= tdi_shift_reg_next;        
end            

//================================================
always@(posedge tck) begin
        if(jtag_reset) begin
            state_reg <= STATE_IDLE;
            command_reg <= 0;
            counter <= 0;
            pad_len <= 0;
            reg_write <= 0;
            shift_out_en <= 0;
            shift_in_en <= 0;
        end
        else begin
            case(state_reg)
                STATE_IDLE:  begin
                    counter <= 0;
                    shift_out_en <= 0;
                    command_reg     <= 0;
                    pad_len <= 0;
                    reg_write <= 0;                    
                    if(capture_dr)  begin
                        state_reg <= STATE_HEADER;
                    end
                end
                STATE_HEADER: begin
                    if(shift_dr) begin                      
                        if(tdi_shift_reg_next[28:24] == 5'b10101) begin
                            state_reg <= STATE_CMD;                               
                            pad_len   <= tdi_shift_reg_next[31:29];
                        end
                    end         
                end                     
                STATE_CMD: begin // shift in command register
                    if(shift_dr) begin
                        counter <= counter + 1'b1;
                        if(counter == (CMD_WIDTH -1)) begin  // need modify
                            command_reg <= tdi_shift_reg_next[31:24];
                            state_reg <= STATE_IDLE;
                            counter <= 0;
                            if( tdi_shift_reg_next[31:29] == CMD_REG_WRITE ) begin// Write reg
                                state_reg <= STATE_WRITE_REG;                                   
                                reg_addr <= tdi_shift_reg_next[28:24];                         
                            end
                            else if( tdi_shift_reg_next[31:29] == CMD_REG_READ ) begin
                                state_reg <= STATE_WR_TRANSIT;
                                reg_addr <= tdi_shift_reg_next[28:24];
                            end
                            else if( tdi_shift_reg_next[31:29] == CMD_DATA_READ ) begin
                                state_reg <= STATE_WR_TRANSIT;
                            end
                            else if( tdi_shift_reg_next[31:29] == CMD_DATA_WRITE ) begin
                                state_reg <= STATE_WRITE_DATA;
                            end
                        end         
                    end
                end             
                STATE_WRITE_REG: begin
                    if(shift_dr) begin
                        counter <= counter + 1'b1;
                        if(counter == 8'd31) begin
                            reg_wdata <= tdi_shift_reg_next;
                            reg_write <= 1;
                            state_reg <= STATE_IDLE;
                        end
                    end
                end
                STATE_READ_REG: begin
                    if(shift_dr) begin
                        counter <= counter + 1'b1;
                        read_reg <= {1'b0, read_reg[31:1]};
                        if(counter == 8'd31) begin
                            state_reg <= STATE_IDLE;
                        end
                    end
                end
                STATE_WR_TRANSIT: begin
                    if (capture_dr) begin                        
                        read_reg  <= reg_rdata;
                        state_reg <= STATE_WAIT_PAD;
                    end
                end
                STATE_WAIT_PAD: begin
                    if (shift_dr) begin
                        counter <= counter + 1'b1;                        
                        if(counter == {5'b0,pad_len}) begin
                            counter   <= 0;                           
                            state_reg <= (command_reg[7:5] == CMD_DATA_READ) ? STATE_READ_DATA: STATE_READ_REG;
                        end
                    end                
                end
                STATE_READ_DATA: begin
                    if(update_dr) begin
                        state_reg <= STATE_IDLE; // Finished reading                        
                    end
                    if(shift_dr) begin
                        if(counter == 8'd5) 
                            shift_out_en <= 1'b1;
                        else
                            counter <= counter + 1'b1;
                        end
                    else begin
                        shift_out_en <= 1'b0;
                    end                    
                end
                STATE_WRITE_DATA: begin
                    if(update_dr) begin
                        state_reg <= STATE_IDLE;
                        shift_in_en <= 1'b0;
                    end
                    if(shift_dr) begin
                        shift_in_en <= 1'b1;
                        shift_in_data <= tdi;
                    end
                    else begin
                        shift_in_en <= 1'b0;
                    end
                end
                default:
                    state_reg <= STATE_IDLE;
            endcase
        end
end
    
// Instantiation of vendor JTAG IP
hdlverifier_jtag_vendor_ip1 #(.JTAG_ID(JTAG_ID)) u_jtag
(
    .tdi(tdi) , 
    .tdo(tdo) , 
    .tck(tck) , 
    .jtag_reset(jtag_reset) ,
    .capture_dr(capture_dr) ,
    .shift_dr(shift_dr),
    .update_dr(update_dr)
);

endmodule
    
    