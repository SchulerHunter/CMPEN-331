`timescale 1ns / 1ps

module SYSCALL_EMU(
    input [31:0] SCNUM,
    input [31:0] ARG,
    input KIWI
    );
    always @ (*)
    begin
        if (KIWI) // if doing an EMU_lated system call
            begin
            case (SCNUM[5:0])
            1: begin // print int
                $write("%d",ARG);
            end
            4: begin // print string
                $write("%s",Top.thisMainMemory.MEMCONTENTS[ARG[15:0]]);
            end
            10: begin // EXIT
                $display("Emulating Exit Syscall, exiting now");
                $finish;
            end
            11: begin // print char
                $write("%c",ARG[7:0]);
            end
            34: begin // print hex
                $write("%x",ARG);
            end
            default: $display("Unsupported Syscall Emulation Request: Type %d",SCNUM);
            endcase
            end
    end
endmodule
