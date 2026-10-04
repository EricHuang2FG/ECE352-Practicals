#Updated to Nios V by Jonathan Schneider
.equ RED_LEDS, 0xFF200000 	   # (From DESL website > NIOS II > devices)


.data                              # "data" section for input and output lists


IN_LIST:                  	   # List of 10 signed halfwords starting at address IN_LIST
    .hword 1
    .hword -1
    .hword -2
    .hword 2
    .hword 0    # neither positive nor negative
    .hword -3
    .hword 100
    .hword 0xff9c
    .hword 0b1111
LAST:			 	    # These 2 bytes are the last halfword in IN_LIST
    .byte  0x01		  	    # address LAST
    .byte  0x02		  	    # address LAST+1
    
IN_LINKED_LIST:                     # Used only in Part 3
    A: .word 1
       .word B
    B: .word -1
       .word C
    C: .word -2
       .word E + 8
    D: .word 2
       .word C
    E: .word 0
       .word K
    F: .word -3
       .word G
    G: .word 100
       .word J
    H: .word 0xffffff9c
       .word E
    I: .word 0xff9c
       .word H
    J: .word 0b1111
       .word IN_LINKED_LIST + 0x40
    K: .byte 0x01		    # address K
       .byte 0x02		    # address K+1
       .byte 0x03		    # address K+2
       .byte 0x04		    # address K+3
       .word 0
    
OUT_NEGATIVE:
    .skip 40                         # Reserve space for 10 output words
    
OUT_POSITIVE:
    .skip 40                         # Reserve space for 10 output words

#-----------------------------------------

.text                  # "text" section for code

    # Register allocation:
    #   "zero register" is zero
    #   s0  ==> length of OUT_NEGATIVE
    #   s2  ==> length of OUT_POSITIVE
    #   s4  ==> pointer to head of OUT_NEGATIVE
    #   s6  ==> pointer to head of OUT_POSITIVE
    #   s1  ==> pointer to the head of IN_LIST
    #   s3  ==> number of elements in IN_LIST yet to be traversed

.global _start
_start:
    
    la s4, OUT_NEGATIVE
    la s6, OUT_POSITIVE

    li s0, 0
    li s2, 0

    la s1, IN_LIST
    li s3, 10
    
    # Begin loop to process each number

    loop_process_in_list:
        # load current element in IN_LIST to be processed
        lh t2, 0(s1)

        # if (t2 == 0) goto endif;
        beq t2, zero, endif

        # if (t2 < 0) goto process_num_negative
        blt t2, zero, process_num_negative
            # process positives
            sw t2, 0(s6)
            addi s2, s2, 1
            addi s6, s6, 4
            j endif

        process_num_negative:
            # process negatives
            sw t2, 0(s4)
            addi s0, s0, 1
            addi s4, s4, 4

        endif:
            addi s1, s1, 2
            addi s3, s3, -1

        # (You'll learn more about I/O in Lab 4.)
        la  t0, RED_LEDS          # t0 and t1 are temporary values
        lw  t1, 0(t0)
        addi   t1, t1, 1
        sw  t1, 0(t0)
        # Finished output to LEDs.
        bnez s3, loop_process_in_list


LOOP_FOREVER:
    j LOOP_FOREVER                   # Loop forever
