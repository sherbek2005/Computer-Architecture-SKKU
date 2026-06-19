///////////////////////////////////////////////////////////////////////////
// MODULE: CPU for TSC microcomputer: cpu.v
// Author: 
// Description: 

// DEFINITIONS
`define WORD_SIZE 16    // data and address word size
`define ADD 6'b000000
`define WWD 6'b011100
`define LHI 6'b000010

// MODULE DECLARATION
module cpu (
    output readM,                       // read from memory
    output [`WORD_SIZE-1:0] address,    // current address for data
    inout [`WORD_SIZE-1:0] data,        // data being input or output
    input inputReady,                   // indicates that data is ready from the input port
    input reset_n,                      // active-low RESET signal
    input clk,                          // clock signal
  
    // for debuging/testing purpose
    output [`WORD_SIZE-1:0] num_inst,   // number of instruction during execution
    output [`WORD_SIZE-1:0] output_port // this will be used for a "WWD" instruction
);
  
    wire [15:0] PC;
    reg [15:0] instruction;

    wire [1:0] DR,SA,SB;
    wire [7:0] Imm;
    wire [5:0] func;
    wire MB,LD,J;

    assign readM = 1'b1;
    assign address = PC;
    
    always @(*) begin
        if(!reset_n)
            instruction = 16'h0000;
        else if(inputReady)
            instruction = data;
    end


    CU ControlUnit(
        instruction,
        DR,
        SA,
        SB,
        Imm,
        MB,
        func,
        LD,
        J
    );
    DP DataPath(
        clk,
        reset_n,
        instruction,
        DR,
        SA,
        SB,
        Imm,
        MB,
        func,
        LD,
        J,
        PC,
        output_port,
        num_inst
    );

    
endmodule


module CU(
    input wire[15:0] instruction,
    output reg [1:0] DR,
    output reg [1:0] SA,
    output reg [1:0] SB,
    output reg [7:0] Imm,
    output reg  MB,
    output reg [5:0] func,
    output reg LD,
    output reg J
);

    always @(*) begin
        DR = 2'b00;
        SA = 2'b00;
        SB = 2'b00;
        Imm = instruction[7:0];
        MB = 1'b0;
        func = `ADD;
        LD = 1'b0;
        J = 1'b0;
        case(instruction[15:12])
            4'b1111:begin
                case(instruction[5:0])
                `ADD: begin
                    SA = instruction[11:10];
                    SB = instruction[9:8];
                    DR = instruction[7:6];
                    LD = 1'b1;
                end
                `WWD:begin
                    func = `WWD;
                    SA = instruction[11:10];
                    LD = 1'b0;
                end
                default: ;
                endcase
            end

            //ADI
            4'b0100: begin
                SA = instruction[11:10];
                DR = instruction[9:8];
                MB = 1'b1;
                LD = 1'b1;
            end

            // LHI
            4'b0110: begin
                DR   = instruction[9:8];
                func = `LHI;
                MB   = 1'b1;
                LD   = 1'b1;
            end

            4'b1001: J = 1'b1;
            default: ;
        endcase
    end
endmodule


module DP(
    input wire clk,
    input wire reset_n,
    input wire [15:0] instruction,
    input wire [1:0]  DR,
    input wire [1:0]  SA,
    input wire [1:0]  SB,
    input wire [7:0]  Imm,
    input wire  MB,
    input wire [5:0] func,
    input wire  LD,
    input wire  J,

    output reg  [15:0] PC,
    output wire [15:0] output_port,
    output reg [15:0] num_inst
);
 
    reg [15:0] regs[0:3];

    wire [15:0] data_A = regs[SA];

    wire [15:0] SE = {{8{Imm[7]}}, Imm};
    
    wire [15:0]  data_B = MB ? SE: regs[SB];
    reg [15:0] res;

    //ALU
    always @(*) begin
        case(func)
            `ADD: res = data_A + data_B;
            `LHI: res = {Imm,8'h00};
            `WWD: res = data_A;
            default: res = 16'h0000;
        endcase
    end

    assign output_port = (func == `WWD) ? data_A: 16'h0000;
    
    // register write
    integer i;
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            for(i = 0; i < 4; i = i + 1)
                regs[i] <= 16'h0000;
        end
        else if(LD) begin
            regs[DR] <= res;
        end
    end

    wire[15:0] next_PC = J ? {PC[15:12],instruction[11:0]}:(PC + 16'h0001);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            PC       <= 16'h0000;
            num_inst <= 16'h0001;
        end else begin
            PC       <= next_PC;
            num_inst <= num_inst + 16'h0001;
        end
    end

endmodule

