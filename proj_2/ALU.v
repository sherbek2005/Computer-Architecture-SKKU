`timescale 100ps / 100ps

module ALU(
    input [15:0] A,
    input [15:0] B,
    input Cin,
    input [3:0] OP,
    output reg Cout,
    output reg [15:0] C
    );
    
    // FILLME
    reg [15:0] ADD_out,L_out, S_out;
    reg [16:0] B_in;
    reg[1:0] BSEL,OSEL;
    reg[2:0] LOP,SOP;

    parameter[3:0] OP_ADD  = 4'b0000,
              OP_SUB  = 4'b0001,
              OP_ID   = 4'b0010,
              OP_NAND = 4'b0011,
              OP_NOR  = 4'b0100,
              OP_XNOR = 4'b0101,
              OP_NOT  = 4'b0110,
              OP_AND  = 4'b0111,
              OP_OR   = 4'b1000,
              OP_XOR  = 4'b1001,
              OP_LRS  = 4'b1010,
              OP_ARS  = 4'b1011,
              OP_RR   = 4'b1100,
              OP_LLS  = 4'b1101,
              OP_ALS  = 4'b1110,
              OP_RL   = 4'b1111;

    // LOGICAL OPERATIONS
    parameter [2:0] L_DNC = 3'b000, // Do Not Care / Default
                AND   = 3'b001,
                NAND  = 3'b010,
                OR    = 3'b011,
                NOR   = 3'b100,
                XOR   = 3'b101,
                XNOR  = 3'b110,
                NOT   = 3'b111;

    //SHIFT OPERATIONS
    parameter[2:0]  S_ARS = 3'b000,
                    S_LRS = 3'b001,
                    S_RR = 3'b010,
                    S_LLS = 3'b011,
                    S_ALS = 3'b100,
                    S_RL = 3'b101,
                    S_DNC = 3'b110;
                

    // control logic
    always @(*) begin
        case (OP)
            OP_ADD:  begin BSEL = 2'b00; OSEL = 2'b00; LOP = AND;   SOP = S_DNC; end
            OP_SUB:  begin BSEL = 2'b01; OSEL = 2'b00; LOP = AND;   SOP = S_DNC; end
            OP_ID:   begin BSEL = 2'b10; OSEL = 2'b01; LOP = OR;    SOP = S_DNC; end
            OP_NAND: begin BSEL = 2'b10; OSEL = 2'b01; LOP = NAND;  SOP = S_DNC; end
            OP_NOR:  begin BSEL = 2'b10; OSEL = 2'b01; LOP = NOR;   SOP = S_DNC; end
            OP_XNOR: begin BSEL = 2'b10; OSEL = 2'b01; LOP = XNOR;  SOP = S_DNC; end
            OP_NOT:  begin BSEL = 2'b10; OSEL = 2'b01; LOP = NOT;   SOP = S_DNC; end
            OP_AND:  begin BSEL = 2'b10; OSEL = 2'b01; LOP = AND;   SOP = S_DNC; end
            OP_OR:   begin BSEL = 2'b10; OSEL = 2'b01; LOP = OR;    SOP = S_DNC; end
            OP_XOR:  begin BSEL = 2'b10; OSEL = 2'b01; LOP = XOR;   SOP = S_DNC; end
            OP_ARS:  begin BSEL = 2'b10; OSEL = 2'b10; LOP = L_DNC; SOP = S_ARS; end
            OP_LRS:  begin BSEL = 2'b10; OSEL = 2'b10; LOP = L_DNC; SOP = S_LRS; end
            OP_RR:   begin BSEL = 2'b10; OSEL = 2'b10; LOP = L_DNC; SOP = S_RR;  end
            OP_LLS:  begin BSEL = 2'b10; OSEL = 2'b10; LOP = L_DNC; SOP = S_LLS; end
            OP_ALS:  begin BSEL = 2'b10; OSEL = 2'b10; LOP = L_DNC; SOP = S_ALS; end
            OP_RL:   begin BSEL = 2'b10; OSEL = 2'b10; LOP = L_DNC; SOP = S_RL;  end
            default: begin BSEL = 2'b10; OSEL = 2'b00; LOP = L_DNC; SOP = S_DNC; end
        endcase
    end

    // MUX for BSEL
    always @(*) begin
        case(BSEL)
            2'b00: B_in = B + Cin;
            2'b01: B_in = ~(B + Cin) + 1;
            default: B_in = 17'b0;
        endcase
    end

    //ADDER
    reg Cout_add;
    always @(A,B_in) begin
        {Cout_add,ADD_out} = A + B_in;
    end

    //LOGICAL
    always @(*)
    begin
        case(LOP)
            AND:  L_out = A & B;
            OR:   L_out = A | B;
            NOT:  L_out = ~A;
            NAND: L_out = ~(A & B);
            NOR:  L_out = ~(A | B);
            XOR: L_out = A ^ B;
            XNOR: L_out = A ~^ B;
            default: L_out = A;
        endcase
    end

    // shifter
    always @(*) begin
        case(SOP)
            S_LLS: S_out = A << 1;
            S_LRS: S_out = A >> 1;
            S_ALS: S_out = A <<< 1;
            S_ARS: S_out = $signed(A) >>> 1;
            S_RR : S_out = {A[0],A[15:1]};
            S_RL:  S_out = {A[14:0],A[15]};
            default: S_out = 16'b0;
        endcase
    end

    // MUX for output
    always @(*) begin
        case (OSEL)
            2'b00: begin C = ADD_out; Cout = Cout_add;end
            2'b01: begin C = L_out; Cout = 1'b0;  end
            default: begin C = S_out; Cout = 1'b0; end
        endcase
    end
endmodule