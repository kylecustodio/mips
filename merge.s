.data

list1:  .word   1, 3
list2:  .word   2, 4
list2E: .word   0
merged: .word   0
separator:  .asciiz " "

.text

main:
    la		$s1, list1		        # load address of list1
    la		$s2, list2		        # load address of list2
    la      $s3, list2E             # load address of list2E | marks end of list2
    la		$s0, merged	            # load address of merged

    sub		$t0, $s2, $s1	        # $t0 = $s2 - $s1 | get size of memory of list1 | difference of address of list1 and next mem. address (list2) is size of list1
    sub		$t1, $s3, $s2	        # $t1 = $s0 - $s2 | get size of memory of list2 | difference of address of list2 and next mem. address (list2E) is size of list2
    add		$a0, $t0, $t1	        # $t0 = $t0 + $t1 | get total size of memory of both lists
    srl     $s4, $a0, 2             # $s4 = # of elements in merged | used for indexing in print

    li		$v0, 9		            # $v0 = 9 | allocate memory for merged
    syscall                         # execute | address of allocated memory is in $v0
    move 	$s0, $v0		        # $s0 = $v0 | merge is a new empty array of size $a0
    move 	$s5, $s0		        # $s5 = $s0 | store the beginning of $s0 (used to restore $s0 after sr calls)
    
    jal		merge			        # jump to merge and save position to $ra
    jal		print	                # jump to printList and save position to $ra

    li		$v0, 10		            # $v0 = 10  | exit program
    syscall                         # execute



merge:
    move 	$t2, $s2		        # $t4 = $s2 | store beginning of $s2
mergeWhile:
    lw		$t0, 0($s1)		        # load value of list1
    lw		$t1, 0($s2)		        # load value of list2
    beq		$s1, $t2, mergeElse	    # if $s1 == $t2 then mergeIfElse | reached end of list1
    beq		$s2, $s3, mergeIf	    # if $s2 == $s5 then mergeIf | reached end of list2
    blt		$t0, $t1, mergeIf	    # if $t0 < $t1 then mergeIf | if val of list1 < list2
    j		mergeElse			    # jump to mergeElse | val of list1 > list2
mergeIf:
    sw		$t0, 0($s0)		        # store value of list1
    addi	$s1, $s1, 4			    # $s1 = $s1 + 4 | move to next element of list1
    beq		$s2, $s3, mergeEndWhile	# if $s2 == $s5 then mergeEndWhile | reached end of both lists => end condition
    j		mergeEndIf			    # jump to mergeEndIf
mergeElse:
    sw		$t1, 0($s0)		        # store value of list2
    addi	$s2, $s2, 4			    # $s2 = $s2 + 4 | move to next element of list2
    beq		$s1, $t2, mergeEndWhile	# if $s2 == $t2 then mergeEndWhile | end of both lists => end condition
mergeEndIf:
    addi	$s0, $s0, 4			    # $s0 = $s0 + 4 | shift to next space in merged
    j		mergeWhile				# jump to merge
mergeEndWhile:
    move 	$s0, $s5		        # $s0 = $s5 | restore $s0 to beginning
    jr		$ra					    # jump to $ra



print:
    addi	$t1, $zero, 0			# $t1 = $zero + 0 | initialize counter to 0
printLoop:
    beq		$t1, $s4, printEndLoop	# if $t2 == $s4 then printListEndLoop | counter = size of merged => end condition
    lw		$t0, 0($s0)		        # load value of merged

    li		$v0, 1		            # system call #1 - print int
    move 	$a0, $t0		        # load $t0 into arg | $t0 = element of merged
    syscall				            # execute | print $t0

    li		$v0, 4		            # system call #4 - print string
    la		$a0, separator          # load separator into arg
    syscall			                # execute | print separator (" ")

    addi	$s0, $s0, 4             # $s0 = $s0 + 4 | move to next element of merged
    addi	$t1, $t1, 1		        # $t1 = $t1 + 4 | increment counter
    j		printLoop	            # jump to printListLoop
printEndLoop:
    move 	$s0, $s5		        # $s0 = $s5 | restore $s0 to beginning
    jr		$ra					    # jump to $ra