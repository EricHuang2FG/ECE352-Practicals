#Updated to Nios V by Jonathan Schneider
.equ RED_LEDS, 0xFF200000 	   # (From DESL website > NIOS II > devices)


.data                              # "data" section for input and output lists


IN_LIST:                  	   # List of 10 signed halfwords starting at address IN_LIST
    .hword 1
    .hword -1
    .hword -2
    .hword 2
    .hword 0
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

.align 2 	 
OUT_NEGATIVE:
    .skip 40                       # Reserve space for 10 output words
    
OUT_POSITIVE:
    .skip 40                         # Reserve space for 10 output words

#-----------------------------------------

.text                  # "text" section for code

    # Register allocation:
    #   "zero register" is zero
    #   s0  Holds the number of negative numbers in the list
    #   s2  Holds the number osf positive numbers in the list
    #   s1  A pointer to first address
    #   s3  loop counter for the loop (0 to 10)
    #   t0, t1 Short-lived temporary values.
    #   etc...
	# goal of program
	# Process a number here:
        #    if (number is negative) { 
        #        insert number in OUT_NEGATIVE list
        #        increment count of negative values (r2)
        #    } else if (numbers is positive) { 
        #        insert number in OUT_POSITIVE list
        #        increment count of positive values (r3)
        #    }
        # Done processing.

.global _start
_start:
    li s0, 0 # 0 neg nums initially
	li s2, 0 # 0 pos nums initially
   
	la s1, IN_LIST
	li s3, 0
	li s4, 10 # list length
	li s6, 0x80000000
	
	la s7, OUT_NEGATIVE
	la s8, OUT_POSITIVE
	
    # Begin loop to process each number
	LOOP:
		beq s3, s4, DONE
		
		lh s5, 0(s1) # store half into s5
		beq s5, x0, LOOP_STUFF # if the number is 0, just jump to end
	
		and t1, s6, s5 # see if it's negative
		beq t1, s6, NEG_NUM
		
	POS_NUM:
		slli t0, s2, 2 # increment s2 address by t0
		add t0, t0, s8 #t0 stores the actual address now
		sw s5, 0(t0) # store s5 into the correct address
		addi s2, s2, 1
		
		j LOOP_STUFF
	NEG_NUM:
		slli t0, s0, 2 # increment s0 address by t0
		add t0, t0, s7 #t0 stores the actual address now
		sw s5, 0(t0) # store s5 into the correct address
		addi s0, s0, 1	

	LOOP_STUFF:
		addi s1, s1, 2
		addi s3, s3, 1
		j LOOP
		
	DONE:
		li   t0, RED_LEDS
		sw   s2, 0(t0)            # e.g. show positive count on LEDs
        # Finished output to LEDs.
    # End loop


LOOP_FOREVER:
    j LOOP_FOREVER                   # Loop forever