#============================================================================
	# Sumedh Joshi
	# Crawford Barnett
#============================================================================
.data
	intro:      .asciiz "This is the list sorting program.\n"
	input:      .asciiz "Please enter a list to process: "
	options:    .asciiz "\nPlease select an option:\n1. Sort\n2. Calculate average of all values.\n3. Find the lowest element.\n4. Find greatest element.\n5. Find sum of all elements.\n6. Print specific element.\n7. Print the list content.\n8. Exit\n"
	sorted:     .asciiz "List sorted!\n"
	invalid:    .asciiz "Invalid choice!\n"
	goodbye:    .asciiz "Goodbye!\n"

	min_print:  .asciiz "The lowest element is: \n"
	max_print:  .asciiz "The largest element is: \n"
	sum_print:  .asciiz "The sum of all elements is: \n"
	avg_print:  .asciiz "The average value is: \n"
	ask_index:  .asciiz "Enter index: "
	index_print:.asciiz "Element at index "
	index_print2:.asciiz " is: \n"

	.align 2
	array:      .space 400000
	count:      .word 0

	input_buffer: .space 10000
	temp_str:     .space 10000

# float constants
	float_zero: .float 0.0
	float_point1: .float 0.1
	float_ten: .float 10.0

#==================================================================
.text
.globl main
main:
    # Print intro
    li $v0, 4
    la $a0, intro
    syscall

    # Ask for input
    li $v0, 4
    la $a0, input
    syscall

    # Read list as string
    li $v0, 8
    la $a0, input_buffer
    li $a1, 10000
    syscall

    # Process list to extract floats
    jal process_list


#================================================================= INPUT PROCESS
process_list:

    la   $t0, input_buffer	# load address of input string buffer 
    la   $t1, array		# array to $t1
    li   $t2, 0			# counter =0
    jal  find_start		# jump to find_start 
    beqz $v0, start_not_found	# jump to not found if input does not have [
    move $t0, $v0		
    jal  extract_data		# jump to extract data
    j    done_extract_final	# get final data after extraction

find_start:
    la   $t3, input_buffer	# load address of input string buffer
    
find_start_loop:
    lb   $t4, 0($t3)		# load first char 
    beqz $t4, end_not_found	# checking for end 
    li   $t5, 91		 # load ASCII value of '[' (91)
    beq  $t4, $t5, found_start_bracket		# if current char == '[', jump to found
    addi $t3, $t3, 1		# next char 
    j    find_start_loop

found_start_bracket:
    addi $t3, $t3, 1		# move pointer ahed of [
    move $v0, $t3		# store the start where number start after [
    jr   $ra

start_not_found:		# if [ not found, print message and exit
    li $v0, 4		
    la $a0, invalid
    syscall
    j exit

end_not_found:			# if ] not found, print message and exit
    li $v0, 4
    la $a0, invalid
    syscall
    j exit

extract_data:
    l.s $f0, float_zero        # loads 0.0
    li   $t7, 0                # found_period flag = 0 ,if 0 means false
    li   $t8, 0                # found_minus flag = 0  ,if 0 means false
    l.s $f2, float_point1      # 0.1 for ftaction part
    l.s $f20, float_ten        # 10.0 for int part

    
extract_data_loop:
    lb   $t3, 0($t0)           # load current char
    beqz $t3, done_extract_final   	
    li   $t4, 93               # ASCII for ']'
    beq  $t3, $t4, handle_closing_bracket # if ']', process the final number
    li   $t4, 44               # ASCII for ','
    beq  $t3, $t4, found_comma 		# if ',', store current number
    li   $t4, 32               	# ASCII for space ' '
    beq  $t3, $t4, skip_char   		# ignore spaces
    li   $t4, 9                # ASCII for tab
    beq  $t3, $t4, skip_char   		# ignore tabs
    li   $t4, 46               # ASCII for '.' (decimal point)
    beq  $t3, $t4, found_period		# handle fractional part flag
    li   $t4, 45               # ASCII for '-' (negative)
    beq  $t3, $t4, found_minus 		# handle negative sign
    blt  $t3, 48, skip_char    		# if char < '0', skip
    bgt  $t3, 57, skip_char    		# if char > '9', skip
    jal  handle_digit          		#  handle digit
    j    extract_data_loop
    
    
skip_char:		# skip one char
    addi $t0, $t0, 1
    j extract_data_loop

found_period:		# check for . with a flag as 1
    li $t7, 1
    addi $t0, $t0, 1
    j extract_data_loop

found_minus:		# check for - with a flag as 1
    li $t8, 1
    addi $t0, $t0, 1
    j extract_data_loop

handle_digit:
    addi $t3, $t3, -48         # convert ASCII '0'-'9' ? numeric 0–9
    mtc1 $t3, $f4              # move integer to float register
    cvt.s.w $f4, $f4           # convert integer to float

    beqz $t7, handle_int_digit # if not in fraction part, handle as integer digit
    j handle_frac_digit        # else fraction part
    
    
handle_int_digit:
    mul.s $f0, $f0, $f20       # Multiply current number by 10
    add.s $f0, $f0, $f4        # Add new digit
    j end_handle_digit
    
    
handle_frac_digit:
    mul.s $f4, $f4, $f2        # multiply current fractional value
    add.s $f0, $f0, $f4        # add to current total
    l.s $f6, float_point1      # load 0.1 again
    mul.s $f2, $f2, $f6        # update fraction multiplier *= 0.1
    j end_handle_digit
    
    
end_handle_digit:
    addi $t0, $t0, 1           # move input pointer to next character
    jr   $ra               

found_comma:
    beqz $t8, store_number	# if $t8 is not 0 store number (- flag)
    neg.s $f0, $f0
    
    
store_number:
    swc1 $f0, 0($t1)           # store number into array
    addi $t1, $t1, 4           # increment counter
    addi $t2, $t2, 1           # increment count

    l.s $f0, float_zero        # start next number storing
    li   $t7, 0                # reset found_period flag
    li   $t8, 0                # reset negative flag
    l.s $f2, float_point1      # reset fractional multiplier = 0.1
    addi $t0, $t0, 1           # move to next char
    j skip_spaces_after_comma  # skip spaces/tabs after comma

skip_spaces_after_comma:
skip_space_iter:
    lb $t3, 0($t0)             	# Load next character
    beqz $t3, extract_data_loop		# If null terminator, done
    li $t4, 32                 	# ASCII for ' '
    beq $t3, $t4, skip_empty_comma
    li $t4, 9                  # ASCII for tab
    beq $t3, $t4, skip_empty_comma
    j extract_data_loop        #back to main parse

skip_empty_comma:
    addi $t0, $t0, 1           # Skip over space or tab
    j skip_space_iter          
    
    
handle_closing_bracket:
    beqz $t8, store_last_num		# if not negative, skip negation (- flag)
    neg.s $f0, $f0
    
    
store_last_num:
    swc1 $f0, 0($t1)           # store last number
    addi $t2, $t2, 1           # increment count
    sw $t2, count              # save count to memory
    j done_extract_final       # jump to done

done_extract_final:
    sw $t2, count	# save total count
    j menu_

#================================================================= MENU
# Printing the menu
menu_:

# Print extra line
	 li $v0,11
	 li $a0, 10
	 syscall
	 
# Printing the menu
	li $v0, 4
	la $a0,options
	syscall
	
	# Accepting user input 
	li $v0, 5         # read integer input
	syscall
	move $t3, $v0     # store user choice in $t3
	
# Arranging according to menu

	beq $t3, 1, sort	 
    	beq $t3,2,avg
    	beq $t3,3,Min
    	beq $t3,4,Max
    	beq $t3,5,sum
    	beq $t3,6,printIndex
    	beq $t3, 7, print
	beq $t3, 8, exit
    	
	# if invalid choice
	li $v0, 4
	la $a0, invalid
	syscall
	j menu_

#================================================================= PRINT
print:
	la $t0, array
	lw $t2, count
	li $t3, 0

print_loop:
	beq $t3, $t2,menu_	

	lwc1 $f12, 0($t0)
	li $v0, 2              # print float
	syscall

	# print newline after each float
	li $v0, 11
	li $a0, 10
	syscall

	addi $t0, $t0, 4
	addi $t3, $t3, 1
	j print_loop
#================================================================= SORT
# same sort used which was given by prof just for floats
sort:
	la $t0, count			
	lw $s0, 0($t0)		#s0, stores the size of the array
	li $t9, 0			#t9 is our counter for i index
	
	add $s1, $s0, -1	#stores our n - 1 value
	
mainLoop:
	li $t8, 0			#resets j counter
	sub $s2, $s1, $t9	#we use this to get the new n - i - 1
	addi $s2, $s2, -1	#we store that n - i - 1, s2 holds the (n - i - 1)
	
	beq $t9, $s1, sortDone

secondLoop:
	la $t0, array		#t5 holds the array location
	sll $t1, $t8, 2		#word increments (4 bytes per float)
	add $t2, $t0, $t1	#find specific address for index
	lwc1 $f0, 0($t2)	#loads the value we need
	lwc1 $f1, 4($t2)	#loading second value j + 1 into f1
	c.lt.s $f1, $f0		#compare if arr[j+1] < arr[j]
	bc1t swap

endSwap:			
	addi $t8, $t8, 1	#increases the j counter
endSecondLoop:
	ble  $t8, $s2, secondLoop
endFirstLoop:
	addi $t9, $t9, 1	#for main loop
	ble  $t9, $s1, mainLoop	

swap:
	swc1 $f1, 0($t2)
	swc1 $f0, 4($t2)
	j endSwap

sortDone:
	li $v0, 4
	la $a0, sorted
	syscall

	j print
	
#================================================================= AVG
avg:
	la $t0, array		# $t0 base address of array
	lw $t1, count		# $t1 size of array
	li $t2, 0		# counter
	
	mtc1 $zero, $f20
	cvt.s.w $f20, $f20	# f20 = 0.0
	
avg_loop:
	bge  $t2, $t1, end_avg_loop	# while (i < size)
	
	l.s  $f2, 0($t0)	 # Load the current element
	
	add.s $f20, $f20, $f2	# sum = sum + current
	
	addi $t2, $t2, 1	# increment counter
	addi $t0, $t0, 4	# increment pointer
	
	j    avg_loop
	
end_avg_loop:
	# f20 = sum, t1 = count
	mtc1 $t1, $f4
	cvt.s.w $f4, $f4    # converts to float from word
	div.s $f12, $f20, $f4
	
	li   $v0, 4
	la   $a0, avg_print
	syscall
	li   $v0, 2
	syscall
	
	j    menu_
#================================================================= MIN
Min:
	la $t0, array		# $t0  base address of array
	lw $t1, count		# $t1  size of array
	
	l.s  $f20, 0($t0)	# Load the first element as the first min value to compare with
	
	li   $t2, 1		# i  counter
	addi $t0, $t0, 4	# $t0 + 4 is pointing to 2nd element

min_loop:
	bge  $t2, $t1, end_min_loop	# while (i < size), if (i >= size), exit 
	
	l.s  $f2, 0($t0)	# Load the current element
	
	c.le.s $f20, $f2	# Compare if current >= min	
	
	bc1t   dont_update_min	# If the comparison was true (min <= current), dont update min value
	
	mov.s $f20, $f2		# min = current only if min > current (i.e bclt fails)
	
dont_update_min:
	addi $t2, $t2, 1	# increment counter (i)
	addi $t0, $t0, 4	# increment pointer 
	
	j    min_loop

end_min_loop:
	li   $v0, 4
	la   $a0, min_print
	syscall              # Print actual statement
	
	mov.s $f12, $f20     # Move in f12 to print
	li   $v0, 2
	syscall           
	
	j    menu_
#================================================================= MAX
Max:
	la $t0, array		# $t0  base address of array
	lw $t1, count		# $t1  size of array
	
	
	l.s  $f20, 0($t0)	# Load the first element as the first max to compare with 
	
	li   $t2, 1		# i counter
	addi $t0, $t0, 4	# $t0 + 4 is pointing to 2nd element

max_loop:
	bge  $t2, $t1, end_max_loop	# while (i < size), if (i >= size), exit 
	
	l.s  $f2, 0($t0)	# Load the current element
	
	c.le.s $f2, $f20	# Compare if current <= max
	
	bc1t   dont_update_max		# If the comparison was true (current <= max), odnt update max value
	
	mov.s $f20, $f2		# max = current only if current > max (i.e bclt fails)
	
dont_update_max:
	addi $t2, $t2, 1	# increment counter (i)
	addi $t0, $t0, 4	# increment pointer
	
	j    max_loop

end_max_loop:
	# Print the result
	li   $v0, 4
	la   $a0, max_print
	syscall              # Print actual statement
	
	mov.s $f12, $f20     # Move in f12 to print
	li   $v0, 2
	syscall
	
	j    menu_
#================================================================= SUM
sum:
	la $t0, array		# $t0 base address of array
	lw $t1, count		# $t1  size of array
	li $t2, 0		# counter
	
	mtc1 $zero, $f20
	cvt.s.w $f20, $f20	# f20 = 0.0
	
sum_loop:
	bge  $t2, $t1, end_sum_loop	# while (i < size)
	
	l.s  $f2, 0($t0)	 # Load the current element
	
	add.s $f20, $f20, $f2	# sum = sum + current
	
	addi $t2, $t2, 1	# increment counter
	addi $t0, $t0, 4	# increment pointer
	
	j    sum_loop

end_sum_loop:		  ###
	li $v0, 4
	la $a0, sum_print
	syscall              # Print actual statement
	
	mov.s $f12, $f20   
	li   $v0, 2
	syscall              # Print sum value
	
	j    menu_
#================================================================= PRINT INDEX
printIndex:
	li $v0, 4
	la $a0, ask_index   # get index from user
	syscall
	
	# read index 
	li $v0, 5
	syscall
	move $t4, $v0		# $t4 stores the index
	
	# calculate the address of element at index
	la $t0, array		# $t0 is the base address of array
	sll $t5, $t4, 2		# offset
	addu $t0, $t0, $t5	# $t0 is base + offset
	
	li $v0, 4
	la $a0, index_print  # print message1
	syscall
	
	li $v0, 1
	move $a0, $t4         #  print index number
	syscall
	
	li $v0, 4
	la $a0, index_print2  # print message2 
	syscall
	
	lwc1 $f12, 0($t0)
	li $v0, 2            # print the value at index
	syscall
	
	j menu_
	

#================================================================= EXIT
exit:
	li $v0, 4
	la $a0, goodbye
	syscall

	li $v0, 10
	syscall
	
 
