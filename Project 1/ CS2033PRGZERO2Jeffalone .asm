
Main:
    addi $s2, $zero, 45 # Minus Sign 
    addi $s1, $zero, 10 # New Line Terminator
    addi $s0, $zero, 0x10010000 # string head

    addi $v0, $zero, 8 # io call
    addi $a0, $zero, 0x10010000 # pass address
    addi $a1, $zero, 9 # pass max length
    syscall

    addi $a0, $zero, 0x10010000 
    jal ParseInt
    j Exit
    
    
# Procedure (non leaf) to deterine string value.
#Parameters: $a0 -> Addr of string head 
#Return: $v0 -> Decimal representation of number in binary. 
ParseInt: 
    sw $ra, 0($sp) # store return address on stack 
    jal ValidateFindEnd
    lw $ra, 0($sp) # restore return address 

    addi $t1, $zero, 1 # initialize power of ten
    addi $t0, $v0, 0 # initialize current byte counter
    add $t2, $zero, $zero # initialize accumlator 
Loop:
    lb $t3, 0($t0)
    beq $t3, $s1, ReturnVal # checks if first byte is end character otherwise is redundant since validateFindEnd removes the end character. 
    beq $t3, $s2, Negate # Checks if needs to negate. Loop is done if negate. 

    sub $t3, $t3, 48 # converts ascii value to integer value
    mul $t3, $t3, $t1 # multiplies by current place value
    mul $t1, $t1, 10 # increase place value
    add $t2, $t2, $t3 # add to accumulator
    beq $a0, $t0, ReturnVal
    addi $t0, $t0, -1
    j Loop
Negate:
    mul $t2, $t2, -1
ReturnVal:
    addi $v0, $t2, 0 # return final sum
    jr $ra


#Procedure (leaf) to find end of string and verify input string is a valid integer string. Includes input validation and graceful handling of empty string. 
#Parameters: $a0 -> addr of string head. 
#Return: $v0 -> address of last digit, $v1 -> 0 if positive 1 if negative (was going to be used but was phased out)
ValidateFindEnd: 
    add $t1, $a0, $zero # intialize first byte. 
    add $v1, $zero, $zero # assume positive. 

    lb $t2, 0($t1)# loads first byte to check if it is negative
    beq $t2, $s1, Empty # checks if first byte is end character 
    beq $t2, $s2, Pass # Passes validation if first char is a negative sign 
ByteLoop:
    lb $t2, 0($t1)# load the byte to be evaluated 

    beq $t2, $s1, Return # check end of string
    beq $t2, 0x00, Return #check for null terminator just in case autograder does not insert new line after input

    slti $t3, $t2, 48 # bounds checking for ascii digits
    beq $t3, 1, Exit
    slti $t3, $t2, 58 
    bne $t3, 1, Exit
    addi $t1, $t1, 1 # increment byte. 
    j ByteLoop
Pass:
    addi $t1, $t1, 1 # increment byte. 
    addi $v1, $zero, 1 # set negative value. 
    j ByteLoop
Return:
    addi $t1, $t1, -1 #excludes end character and sets address to address of last ascii character 
    add $v0, $t1, $zero
    jr $ra
Empty:
    add $v0, $t1, $zero # does not subtract one if first character is end character
    jr $ra
Exit:
