#Updated to Nios V by Jonathan Schneider
/* List of registers utilized:
s0: address of LEDs                   s4: number of elements in array
s1: pointer to array                  s5: temporary register
s2: value displayed                   s6: counter in delay loop
s3: counter                                        */

.text
.global _start
_start:
  .equ RED_LEDS, 0xFF200000
  la s0,RED_LEDS  /* Get location of LED device */
  la s1,array     /* Get location of array: char *p = array; */
  li s2, 0
  li s4,5          /* set length of the array */
  
intermediate_start:
  la s1,array
  li s3,0          /* initialize counter */
            
LOOP:
  bge s3,s4,intermediate_start    /* test for end of array */
                
  lb s5,0(s1)       /* load digit from array: r7 = *p; */
  or s2,s2,s5        /* insert character in string of digits */
  sw s2,0(s0)     /* write to the red LEDs */
  addi s1,s1,1       /* increment address: p++ */
  slli s2,s2,2       /* shift string to the left */
                
  addi s3,s3,1 # counter
  
  li s6,4000000 /* set starting point for delay counter */
                
DELAY:
  addi s6,s6, -1       # subtract 1 from delay
  bne s6,zero, DELAY   # continue subtracting if delay has not elapsed
  j LOOP            # delay elapsed, redo the LOOP
                    # Make sure there is always a newline at the end of the file.
            
.data
array:
  .byte 1
  .byte 2
  .byte 3
  .byte 2
  .byte 1
