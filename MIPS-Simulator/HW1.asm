.data
.text
main:
 	addi $s0,$s0,25	# n = 25
 
	addi $sp,$sp,-4
	sw $s0,0($sp)	# store n on the stack
	jal fib 		# call fib(n)

	lw $t0,4($sp) 	# load the ans to $t0
	addi $sp,$sp,4

	addi $v0,$v0,10	# exit
	syscall
fib:
	lw $t1,0($sp)	# load n to $t1
	beq $t1,0,fib_0	# if n == 0 , return 0
	beq $t1,1,fib_1	# if n == 1 , return 1
 
	# compute fib(n-1)
	addi $t1,$t1,-1	# n-1
	addi $sp,$sp,-12
	sw $t1,0($sp)	# store n-1 on the stack
	sw $ra,8($sp)	# store return address on the stack
	jal fib		# call fib(n-1)
	lw $t1,0($sp)	# load n-1 to $t1
	lw $t2,4($sp)	# load return value of fib(n-1) to $t2
	lw $ra,8($sp)	# load return address to $ra
	addi $sp,$sp,12
	
	addi $sp,$sp,-4
	sw $t2,0($sp)	# store return value of fib(n-1) on the stack
 
	# compute fib(n-2)
	addi $t1,$t1,-1	# n-2
	addi $sp,$sp,-12
	sw $t1,0($sp)	# store n-2 on the stack
	sw $ra,8($sp)	# store return address on the stack
	jal fib		# call fib(n-2)
	lw $t3,4($sp)	# load return value of fib(n-2) to $t3
	lw $ra,8($sp)	# load return address to $ra
	addi $sp,$sp,12
	
	lw $t2,0($sp)	# load return value of fib(n-1) to $t2
	addi $sp,$sp,4

	add $t4,$t2,$t3	# $t4 = fib(n-1) + fib(n-2)
	sw $t4,4($sp)	# store return value of fib(n) on the stack
	jr $ra 
 
	fib_0:
		sw $zero,4($sp)# store return value 0 on the stack
		jr $ra  
 
	fib_1:
		addi $t0,$zero,1# store return value 1 on the stack
		sw $t0,4($sp)
		jr $ra
