.globl _repl_4c0890

_repl_4c0890:
    flds 0x70e67a8; // The size of the operand no longer depends on the assembler default
                    // confirmed that 0x70e67a8 adress is a 32bit float 
    jmpl *(ret_4c0890);    

ret_4c0890: .long 0x4c08a6
