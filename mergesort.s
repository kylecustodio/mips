.data

promptSize:  .asciiz "Size: "
promptList:  .asciiz "Element: "
separator:   .asciiz " "
size:        .word  0
list:        .space 100000
left:        .space 100000
right:       .space 100000


.text

main:
#==================== CREATE INITIAL ARRAY ====================

    li		$v0, 4		    # system call #4 - print string
    la		$a0, promptSize # load address of promptSize
    syscall				
    
#   ---------- GET SIZE ----------   
    li		$v0, 5		    # $v0 = 5 | input integer from console
    syscall                 # $v0 = number of elements of list

    sw		$v0, size		# store size

#   ---------- FILL ----------

    addi	$t1, $v0, 0		# $t0 = $v0 + 0
    sll     $t1, $t1, 2     #
    addi	$t0, $zero, 0	# $t0 = $zero + 0 | counter
fillLoop:
    bge		$t0, $t1, mergeSort	# if $t0 >= $t1 then mergeSort
    
    li		$v0, 4		        # system call #4 - print string
    la		$a0, promptList
    syscall				        # execute

    li		$v0, 5		        # $v0 = 5
    syscall

    sw		$v0, list($t0)		# list[$t0] = input
    addi	$t0, $t0, 4			# $t0 = $t0 + 4 | increment $t0 by size of word
    j		fillLoop				# jump to fillLoop

#==================== MERGE SORT ====================
mergeSort:
    lw		$t0, size		# 
    sub		$t0, $t0, 1		# $t0 = $t0 - 1 | high = size - 1
    addi	$t1, $zero, 1	# $t1 = $zero + 1 | curSize = 1
loop1: 
    addi	$t2, $zero, 0			# $t2 = $zero + 0 | left = 0
loop2:
    add		$t3, $t1, $t2		# $t3 = $t1 + $t2
    sub		$t3, $t3, 1		    # $t3 = $t3 - 1 | mid = curSize + left - 1
    
    sll     $t4, $t1, 1         # 2*curSize
    add		$t4, $t4, $t2		# $t4 = $t4 + $t2
    sub		$t4, $t4, 1		    # $t4 = $t4 - 1 | right = 2*curSize + left - 1

#   ---------- Math.min($t4, $t0) ----------
    blt		$t4, $t0, min	    # if $t4 < $t0 then min
    move 	$t4, $t0		    # $t4 = $t0 | right = high
min:
    jal		merge				# jump to merge and save position to $ra
    
    sll     $t5, $t1, 1         # 
    add		$t2, $t2, $t5		# $t2 = $t2 + $t5 | += 2*cursize
    blt		$t2, $t0, loop2	    # if $t2 < $t0 then loop2
    
    sll     $t1, $t1, 1         # double curSize
    ble		$t1, $t0, loop1	    # if $t1 <= $t0 then loop1

#==================== PRINT ARRAY ====================
    addi	$t0, $zero, 0   # $t0 = $zero + 0
    lw		$t1, size		# 
printLoop:
    bge		$t0, $t1, end	# if $t0 >= $t1 then end
    sll     $t2, $t0, 2
    lw		$a0, list($t2)	# 
    li		$v0, 1		    # $v0 = 1
    syscall

    li		$v0, 4		# system call #4 - print string
    la		$a0, separator
    syscall				# execute

    addi	$t0, $t0, 1			# $t0 = $t0 + 1
    j		printLoop				# jump to printLoop
end:
    li		$v0, 10		    # $v0 = 10  | exit program
    syscall                 # execute



#==================== MERGE ====================
merge:
    sub		$sp, $sp, 12	    # $sp = $sp - 12
	sw      $t0, 0($sp)         # store size
	sw      $t1, 4($sp)         # store curSize
	sw      $t2, 8($sp)         # store left
    
    addi	$s2, $t2, 0			# $s2 = $t2 + 0 | left
    addi	$s3, $t3, 0			# $s3 = $t3 + 0 | mid
    addi	$s4, $t4, 0			# $s4 = $t4 + 0 | right
    
    addi	$t0, $t3, 1			# $t0 = $t3 + 1
    sub		$t0, $t0, $t2		# $t0 = $t0 - $t2 | size of leftArr
    sub		$t1, $t4, $t3		# $t1 = $t4 - $t3 | size of rightArr
    
    addi	$t3, $zero, 0		# $t3 = $zero + 0 | counter
copyLeft:
    add		$s5, $s2, $t3		# $s5 = $s2 + $t3 | left + $t3
    sll     $s5, $s5, 2
    lw		$t5, list($s5)		# take value from list
    sll     $s6, $t3, 2
    sw		$t5, left($s6)		# store into left
    
    add		$t3, $t3, 1		    # $t3 = $t3 + 1
    blt		$t3, $t0, copyLeft	# if $t3 < $t0 then copyLeft

    addi	$t4, $zero, 0		# $t4 = $zero + 0 | counter
copyRight:
    add		$s5, $s3, $t4		# $s5 = $s3 + $t4
    addi	$s5, $s5, 1			# $s5 = $s5 + 1
    sll     $s5, $s5, 2
    lw		$t5, list($s5)		# 
    sll     $s6, $t4, 2
    sw		$t5, right($s6)		# 
    
    addi	$t4, $t4, 1			# $t4 = $t4 + 1
    blt		$t4, $t1, copyRight	# if $t4 < $t0 then copyRight
    
    addi	$t3, $zero, 0			# $t3 = $zero + 0
    addi	$t4, $zero, 0			# $t4 = $zero + 0
    addi	$s0, $s2, 0			# $s0 = $s2 + 0
mLoop:
    slt     $a2, $t3, $t0       #
    slt     $a3, $t4, $t1       #   while($t3 < $t0 && $t4 < $t1)
    and     $v1, $a2, $a3       #   $t3 < # elem in left
    beqz    $v1, mLoop2         #   $t4 < # elem in right

    sll     $s2, $t3, 2
    lw		$t5, left($s2)		# left[$t3]
    sll     $s3, $t4, 2
    lw		$t6, right($s3)		# right[$t4]

    sll     $s4, $s0, 2         # get index of list

    bgt		$t5, $t6, mElse	    # if $t5 > $t6 then mElse
    sw		$t5, list($s4)		# list[$s4] = left[$t3]
    addi	$t3, $t3, 1			# $t3 = $t3 + 1
    addi	$s0, $s0, 1			# $s0 = $s0 + 1
    j		mLoop				# jump to mLoop
mElse:
    sw		$t6, list($s4)		# list[$s4] = right[$t4]
    addi	$t4, $t4, 1			# $t4 = $t4 + 1
    addi	$s0, $s0, 1			# $s0 = $s0 + 1
    j		mLoop				# jump to mLoop
mLoop2:
    bge		$t3, $t0, mLoop3	# if $t3 >= $t0 then mLoop3
    sll     $s2, $t3, 2
    lw		$t5, left($s2)		# left[$t3]
    sll     $s4, $s0, 2         # get index of list
    sw		$t5, list($s4)		# list[$s4] = left[$t3] 
    addi	$t3, $t3, 1			# $t3 = $t3 + 1
    addi	$s0, $s0, 1			# $s0 = $s0 + 1
    j		mLoop2				# jump to mLoop2
mLoop3:
    bge		$t4, $t1, mEnd	# if $t4 >= $t1 then mEnd
    sll     $s3, $t4, 2
    lw		$t6, right($s3)		# right[$t4]
    sll     $s4, $s0, 2         # get index of list
    sw		$t6, list($s4)		# list[$s4] = right[$t4] 
    addi	$t4, $t4, 1			# $t4 = $t4 + 1
    addi	$s0, $s0, 1			# $s0 = $s0 + 1
    j		mLoop3				# jump to mLoop3
mEnd:
    lw		$t0, 0($sp)		    # restore size
    lw		$t1, 4($sp)		    # restore curSize
    lw		$t2, 8($sp)		    # restore left
    addi	$sp, $sp, 12		# $sp = $sp + 12 | restore stack
    jr		$ra					# jump to $ra