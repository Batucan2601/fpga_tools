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

module UART( input logic clk , reset , RX, output logic TX  );
    logic [7:0]data;
    UART_RECV recv(clk , reset , RX , data );
    UART_TRANS trans( clk , reset , data , TX );
    
endmodule 
module UART_RECV( input logic clk , reset ,RX ,  output logic [7:0]byte_data
    );
    logic[7:0] temp_byte_data;
    typedef enum logic[0:3] {S_start,S_1,S_2,S_3,S_4,S_5,S_6,S_7,S_8 , S_parity ,S_stop    } statetype; // S_1 through S_8 are the data collection states 
    statetype[1:0] state, nextstate;
    
    always_ff@(posedge clk)
    begin
        if (reset)
        begin
            state <= S_start;
            byte_data <= 8'b00000000;
        end
        else 
        begin
            state <= nextstate;
        end
    end
    
    always_comb
        begin
            if( state == S_start  )
            begin
             if( RX ) // start bit byte_data
                begin
                    nextstate = S_1; 
                end
              else
                begin
                   byte_data = 8'b00000000;
                   nextstate = S_start; 
                end
            end
            // multiple data catch start 
            else if( state == S_1  )
            begin
                temp_byte_data[7] = RX;
                nextstate = S_2; 
            end
            else if( state == S_2  )
            begin
                temp_byte_data[6] = RX;
                nextstate = S_3; 
            end
            else if( state == S_3  )
            begin
                temp_byte_data[5] = RX;
                nextstate = S_4; 
            end
            else if( state == S_4  )
            begin
                temp_byte_data[4] = RX;
                nextstate = S_5; 
            end
            else if( state == S_5  )
            begin
                temp_byte_data[3] = RX;
                nextstate = S_6; 
            end
            else if( state == S_6  )
            begin
                temp_byte_data[2] = RX;
                nextstate = S_7; 
            end
            else if( state == S_7  )
            begin
                temp_byte_data[1] = RX;
                nextstate = S_8; 
            end
            else if( state == S_8  )
            begin
                temp_byte_data[0] = RX;
                nextstate = S_parity; 
            end
            // multiple data catch end 
            else if( state == S_parity  )
            begin
                // data check
                if(temp_byte_data[0] ^ temp_byte_data[1] ^temp_byte_data[2] ^temp_byte_data[3] ^temp_byte_data[4] ^ temp_byte_data[5] ^temp_byte_data[6] ^temp_byte_data[7] == RX )
                begin
                    nextstate = S_stop; 
                end
                else
                begin
                    nextstate = S_start;
                end
                
            end
            else if( state == S_stop)
            begin
                if( RX )
                begin
                   byte_data = temp_byte_data;
                   nextstate = S_start; 
                end
            end
        end
endmodule

module UART_TRANS(input logic clk , reset, [7:0]byte_data , output logic TX );
    typedef enum logic[0:3] { S_start , S_0,S_1,S_2, S_3, S_4 , S_5 , S_6 , S_7  , S_parity , S_stop } statetype;
    statetype state, nextstate;

    always_ff@(posedge clk)
    begin
        if (reset) 
        begin 
            state <= S_start;
        end
        else
        begin
            state <= nextstate;
        end 
    end
    always_comb
        begin
            case(state)
                S_start:
                    begin
                        TX = 1'b1; // start bit
                        nextstate = S_0;
                    end
                 // data send 
                 S_0:
                    begin
                        TX = byte_data[0];
                        nextstate = S_1;
                    end
                 S_1:
                    begin
                        TX = byte_data[1];
                        nextstate = S_2;
                    end
                 S_2:
                    begin
                        TX = byte_data[2];
                        nextstate = S_3;
                    end
                 S_3:
                    begin
                        TX = byte_data[3];
                        nextstate = S_4;
                    end 
                 S_4:
                    begin
                        TX = byte_data[4];
                        nextstate = S_5;
                    end
                 S_5:
                    begin
                        TX = byte_data[5];
                        nextstate = S_6;
                    end
                S_6:
                    begin
                        TX = byte_data[6];
                        nextstate = S_7;
                    end
                S_7:
                    begin
                        TX = byte_data[7];
                        nextstate = S_parity;
                    end
                // end of data send
                S_parity:
                    begin
                        if( byte_data[0] ^ byte_data[1] ^byte_data[2] ^byte_data[3] ^byte_data[4] ^byte_data[5] ^byte_data[6] ^byte_data[7] == 1  )
                        begin
                            TX = 1'b1; 
                        end 
                        else
                        begin
                            TX = 1'b0;
                        end
                        nextstate = S_stop;
                    end 
                 S_stop:
                    begin
                        TX = 1'b1; 
                        nextstate = S_start;
                    end 
            endcase
        end 
endmodule 
