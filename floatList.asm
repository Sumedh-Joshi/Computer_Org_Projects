.data
	intro: .asciiz "This is the list sorting program (My program takes 15 inputs).\n"
	size: .asciiz "Enter number of elements: "
	input: .asciiz "Enter element: "
	options: .asciiz "Please select an option:\n1. Sort\n2. Calculate average of all values.\n3. Find the lowest element.\n4. Find greatest element.\n5. Find sum of all elements.\n6. Print specific element.\n7. Print the list content.\n8. Exit\n"
	sorted: .asciiz "List sorted!\n"
	invalid: .asciiz "Invalid choice!\n"
	goodbye: .asciiz "Goodbye!\n"
	
	min_print: .asciiz "The lowest element is: \n"
	max_print: .asciiz "The largest element is: \n"
	sum_print: .asciiz "The sum of all elements is: \n"
	
	.align 2
	array:    .space 400        # (stores up to 100 floats) I will be usnig space only for 15 inputs considering all floats 
	count:    .word 0	
.text
.globl main
main:
	# Printing into statement
	li $v0,4
	la $a0, intro
	syscall
	
# Print extra line
	 li $v0,11
	 li $a0, 10
	 syscall
	 
	 
	la $t1,array	# address of first inputed element in the array 
	li $t2,0	# count 
	
	# Taking 15 float input (Works for both int and float)
input_loop:
	beq $t2,15,storeCount	# stop inputs after getting 15 inputs

	# Printing to get inputs
	li $v0,4
	la $a0, input
	syscall
	
	li $v0,6	# For imputting floats 
	syscall
	
	swc1 $f0,0($t1)	# storing word in array 
	addi $t1,$t1,4	# incrementing array by 4 for floats
	addi $t2,$t2,1	# incrementing count by 1
	
	j input_loop

storeCount:
	sw $t2, count    #  save number of elements entered
	j menu_          #  now jump to menu

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
    #	beq $t3,6,printIndex
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
	lw $t1, count		# $t1  size of array
	li $t2, 0		# counter
	
	li $f20,0.0	# Load 0 into $f20, will be adding all elements to f20  ####====
	
avg_loop:
	bge  $t2, $t1, end_avg_loop	# while (i < size)
	
	l.s  $f2, 0($t0)	 # Load the current element
	
	add.s $f20, $f20, $f2	# sum = sum + current
	
	addi $t2, $t2, 1	# increment counter
	addi $t0, $t0, 4	# increment pointer
	
	j    avg_loop
	
end_sum_loop:
# problem count is int addition is float how to / ??
	
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
	
	li $f20,0	# Load 0 into $f20, will be adding all elements to f20   ####====
	
sum_loop:
	bge  $t2, $t1, end_sum_loop	# while (i < size)
	
	l.s  $f2, 0($t0)	 # Load the current element
	
	add.s $f20, $f20, $f2	# sum = sum + current
	
	addi $t2, $t2, 1	# increment counter
	addi $t0, $t0, 4	# increment pointer
	
	j    sum_loop

end_sum_loop:		  ####====
	li $v0, 4
	la $a0, sum_print
	syscall              # Print actual statement
	
	mov.s $f12, $f20   
	li   $v0, 2
	syscall              # Print sum value
	
	j    menu_
#================================================================= 1_INDEX

#================================================================= EXIT
exit:
	li $v0, 4
	la $a0, goodbye
	syscall

	li $v0, 10
	syscall
	
 
