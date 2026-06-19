`timescale 100ps / 100ps

module RF(
    input [1:0] addr1,
    input [1:0] addr2,
    input [1:0] addr3,
    input [15:0] data3,
    input write,
    input clk,
    input reset,
    output reg [15:0] data1,
    output reg [15:0] data2
    );
    
    // FILLME

    reg[15:0] reg1,reg2,reg3,reg4;
    parameter[1:0]  R1 = 2'b00,
                    R2 = 2'b01,
                    R3 = 2'b10,
                    R4 = 2'b11;
    
    reg en1,en2,en3,en4;

    // register decoder
    always @(*) begin
        en1 = 1'b0; en2 = 1'b0; en3 = 1'b0; en4 = 1'b0;
        if(write == 1) begin 
            case(addr3)
                R1: en1 = 1'b1;
                R2: en2 = 1'b1;
                R3: en3 = 1'b1;
                default: en4 = 1'b1;
            endcase
        end
    end


    //registers
    always @(posedge clk)
    begin
        if(reset == 1) reg1 <= 16'b0;
        else if(en1 == 1) reg1 <= data3;
    end

    always @(posedge clk)
    begin
        if(reset == 1) reg2 <= 16'b0;
        else if(en2 == 1) reg2 <= data3;
    end

    always @(posedge clk)
    begin
        if(reset == 1) reg3 <= 16'b0;
        else if(en3 == 1) reg3 <= data3;
    end

    always @(posedge clk)
    begin
        if(reset == 1) reg4 <= 16'b0;
        else if(en4 == 1) reg4 <= data3;
    end

    //MUX FOR DATA1
    always @(*) begin
        case(addr1)
            R1: data1 = reg1;
            R2: data1 = reg2;
            R3: data1 = reg3;
            R4: data1 = reg4;
            default: data1 = 16'b0;
        endcase
    end

    // mux for data2
    always @(*) begin
        case(addr2)
            R1: data2 = reg1;
            R2: data2 = reg2;
            R3: data2 = reg3;
            R4: data2 = reg4;
            default: data2 = 16'b0;
        endcase
    end

    
endmodule