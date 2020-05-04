.text
.globl NMM
 # for i = 0; i < N; i++
 #   for j = 0; j < N; j++
 #     c[i][j]=0
 #     for k = 0; k < N; k++
 #       c[i][j] = c[i][j] + a[i][k]*b[k][j] 
NMM:
sll $v0, $a3, 2 # bytes in 1 row = 4 * N ; no return value, use Vs as temps
add $t0, $0, $0 # i = 0
  iLOOP:
    add $t1, $0, $0 # j = 0
    jLOOP:
      add $t2, $0, $0 # k = 0
      # set c[i][j]=0
      multu $v0, $t0 # compute i rows, in bytes
      mflo $t3 # retrieve ; $t3 = i rows in bytes
      sll $t4, $t1, 2 # 4 * j ; $t4 = j columns in bytes -- all of $t3, $t4 and $t5 will be reused in the innermost loop
      add $t5, $t4, $t3 # sum row offset + column offset
      add $t5, $t5, $a2 # add offset to base
      sw $0, 0($t5) # set c[i][j] to zero ; address of C[i][j] will be reused in the loop
      kLOOP:
      	sll $t6, $t2, 2 # compute k columns in bytes
      	multu $v0, $t2 # compute k rows in bytes
      	mflo $t7       # $t7 = k rows in bytes 
      	lw $t8, 0($t5) # load the current value of C[i][j] -- in a more optimized execution, we'd register-allocate this and only load/store at the beginning/end
     	add $t9, $t3, $t6 # offset [i][k]
      	add $t9, $t9, $a0 # & A[i][k]
      	lw $v1, 0($t9) # out of T registers, using v1 as temp
      	add $t9, $t7, $t4 # offset [k][j]
      	add $t9, $t9, $a1 # & B[k][j]
      	lw $t9, 0($t9) # B[k][j]
      	multu $v1, $t9 # A[i][k] * B[k][j]
      	mflo $v1 # retreive
      	add $t8, $t8, $v1 # accumulate
      	sw $t8, 0($t5) # C[i][j]+=...
        ###
        #       c[i][j] = c[i][j] + a[i][k]*b[k][j]
        ## 
        addi $t2, $t2, 1 # k++
      bne $t2, $a3, kLOOP
      addi $t1, $t1, 1 # j++
    bne $t1, $a3, jLOOP
    addi $t0, $t0, 1 # i++
  bne $t0, $a3, iLOOP
jr $ra 
