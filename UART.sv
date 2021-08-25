`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/25/2021 12:38:57 PM
// Design Name: 
// Module Name: UART
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//the data is sent with the least significant bit first.
// data length 8 
// 1 byte start bit =>  8 byte data => 1 byte parity => 1 byte stop bit  
// 1 byte start_get 1 byte start_send

module UART( input logic clk , reset , [0:10]RX, output logic [0:10] TX  );
    logic [7:0]data;
    UART_RECV recv(clk , reset , RX , data );
    UART_TRANS trans( clk , reset , data , TX );
    
endmodule 
module UART_RECV( input logic clk , reset , [0:10]RX ,  output logic [7:0] byte_data
    );
    
    typedef enum logic[1:0] {S0,S1,S2} statetype;
    statetype[1:0] state, nextstate;
    
    always_ff@(posedge clk)
    begin
        if (reset) state <= S0;
        else state <= nextstate;
    end
    
    always_comb
        begin
            case(state)
            S0:
                begin
                    if( RX[0] ) // parity bit check 
                        begin
                            nextstate = S1;
                        end
                    else
                        begin
                            nextstate = S0; 
                        end 
                     
                end
            S1:
                begin // xor the data 
                    if( RX[1] ^ RX[2] ^ RX[3] ^ RX[4] ^ RX[5] ^ RX[6] ^RX[7] ^ RX[8]  == RX[9] ) // if parity check is a success 
                        begin
                            byte_data[7:0] = RX[1:8];
                        end
                    nextstate = S0;
                end 
            endcase
        end
endmodule

module UART_TRANS(input logic clk , reset, [7:0]byte_data , output logic[0:10]TX );
    typedef enum logic[1:0] {S0,S1,S2} statetype;
    statetype[1:0] state, nextstate;

    always_ff@(posedge clk)
    begin
        if (reset) state <= S0;
        else state <= nextstate;
    end
    
    always_comb
        begin
            case(state)
                S0:
                    begin
                        TX[1:8] = byte_data; // data set in 1 thruogh 8 
                        TX[0] = 1'b1; //start bit 
                        TX[10] = 1'b1; //stop bit
                        TX[9] = byte_data[0]^ byte_data[1]^ byte_data[2]^ byte_data[3]^ byte_data[4]^ byte_data[5]^ byte_data[6]^ byte_data[7];//parity bit 
                        nextstate = S0; 
                    end

            endcase
        end 
endmodule 
