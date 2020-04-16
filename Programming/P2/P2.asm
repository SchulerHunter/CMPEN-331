   .data
N: .word 3
A: .word 1, 2, 3, 4, 5, 6, 7, 8, 9 # {{1,2,3}{4,5,6}{7,8,9}}
B: .word 1, 1, 1, 1, 1, 1, 1, 1, 1 # {{1,1,1}{1,1,1}{1,1,1}}
C: .word 0, 0, 0, 0, 0, 0, 0, 0, 0 # Should be {{6,6,6}{15,15,15}{24,24,24}}
# Graph
N0: .word 0, 0, 0, 2, N1, N2
N1: .word 1, 0, 0, 3, N0, N3, N4
N2: .word 2, 0, 0, 1, N0
N3: .word 3, 0, 0, 2, N1, N4
N4: .word 4, 0, 0, 2, N1, N3
Queue: .space 20

  .text
# Store A, B, C, and N in $a registers
 lw $a0, N
 la $a1, A
 la $a2, B
 la $a3, C
 jal matMul

la $a0, N4
la $a1, Queue
li $a2, 0
li $a3, 0
jal BFS
syscall

matMul:
  # Register usage:
  # N is $a0, A is $a1, B is $a2, C is $a3
  # row is $s0, column is $s1, i is $s2, sum is $s3
  # word size in $t0

  # Create space on stack
  sw $fp, -4($sp)
  la $fp, -4($sp)
  sw $ra, -4($fp)
  sw $s0, -8($fp) # Space to store current row
  sw $s1, -12($fp) # Space to store current col
  sw $s2, -16($fp) # Space to store iterator
  sw $s3, -20($fp) # Space to store sum
  addi $sp, $sp, -24

  li $s0, 0 # row = 0
  li $t0, 4 # sizeof(Int)

row_loop:
  bge $s0, $a0, mul_end # if r >= n, branch
  li $s1, 0 # col = 0

col_loop:
  bge $s1, $a0, col_end # if col >= n, branch
  li $s2, 0 # i = 0
  li $s3, 0 # int sum = 0;

iter_loop:
  bge $s2, $a0, store # if i >= n, branch

  # A[r][i]
  # Calculate offset for A matrix
  mul $t1, $s0, $a0 # t1 = row * n
  mul $t1, $t1, $t0 # t1 = t1 * 4
  mul $t2, $s2, $t0 # t2 = i * 4
  add $t1, $t1, $t2 # t1 = (row * n * 4) + (i * 4) = Offset
  add $t1, $a1, $t1 # t1 = Address = A + offset
  lw $t1, ($t1) # load value of A($t1) in to t1

  # B[i][c]
  # Calculate offset for B matrix
  mul $t2, $s2, $s0 # t2 = i * n
  mul $t2, $t2, $t0 # t2 = t2 * 4
  mul $t3, $s1, $t0 # t3 = 4 * col
  add $t2, $t3, $t2 # t2 = (i * n * 4) + (col * 4) = Offset
  add $t2, $a2, $t2 # Address = A + offset
  lw $t2, ($t2) # load value of B($t2) in to $t2

  mul $t2, $t1, $t2 # Multiply the values in to $t2
  add $s3, $s3, $t2 # Add the values to the running sum

  addi $s2, $s2, 1 # i++
  j iter_loop

store:
  # Calculate offset to store sum in to C matrix
  mul $t1, $s0, $a0 # t1 = r * n
  mul $t1, $t1, $t0 # t1 = t1 * 4
  mul $t2, $s1, $t0 # t2 = c * 4
  add $t1, $t1, $t2 # t1 = t1 * t2 = (r * p * 4) + (c * 4)
  add $t1, $a3, $t1 # Address = C + offset
  sw $s3, ($t1) # Set sum to value stored at address
  
  addi $s1, $s1, 1 # c++
  j col_loop

col_end:
  addi $s0, $s0, 1 # r++
  j row_loop

mul_end:
  # Close all memory
  lw $ra, -4($fp)
  lw $s0, -8($fp)
  lw $s1, -12($fp)
  lw $s2, -16($fp)
  lw $s3, -20($fp)
  la $sp, 4($fp)
  lw $fp, ($fp)
  jr $ra
  
BFS:
  # Register usage:
  # Starting node in $a0, Queue space in $a1
  # size in $s0, address in $s1
  # word size in $t0
  
  # Create space on stack
  sw $fp, -4($sp)
  la $fp, -4($sp)
  sw $ra, -4($fp)
  sw $s0, -8($fp) # Space for size
  sw $s1, -12($fp) # Address of next node
  addi $sp, $sp, -16
  
  # Store root node
  li $s0, 1 # size = 1
  sw $a0, ($a1) # store the address at the root of the queue
  
  li $t0, 4 # sizeof(Int)

BFS_loop:
  blez $s0, BFS_end # size <= 0, branch
  
  # Pop the queue
  lw $s1, ($a1) # Store newset node address in $s1
  subi $s0, $s0, 1 # Decrement size by 1
  li $t1, 0 # Iterator
  # Queue pop loop
  bgtz $s0, pop_queue 

pop_return:
  # Store depth + 1 in $t1
  addi $t1, $s1, 4 # Calculate address
  lw $t1, ($t1) # Load depth
  addi $t1, $t1, 1 # Calculate depth + 1

  # Mark as visited
  addi $t2, $s1, 8 # Store address for visited
  li $t3, 1 # Store value for true
  sw $t3, ($t2) # Store a true in visited
  
  # Check the neighbors
  addi $t2, $t2, 4 # Memory address for neighbors
  lw $t2, ($t2) # Store number of neighbors
  li $t3, 0 # Iterator
  j check_neighbors # Check all neighbors

check_return:
  j BFS_loop # Jump back up loop

pop_queue:
  addi $t1, $t1, 1 # i++
  mul $t2, $t1, $t0 # Get offset for address to store in $t1 - 1
  add $t2, $t2, $a1 # Calculate memory address to retrieve word
  lw $t3, ($t2) # Pull the memory address of the next node
  sw $zero, ($t2) # Wipe the old spot
  subi $t2, $t2, 4 # Calculate memory address to store word
  sw $t3, ($t2) # Store word
  
  blt $t1, $s0, pop_queue # Continue loop
  j pop_return # Finish popping

check_neighbors:
  bge $t3, $t2, check_return # Branch if all neighbors have been checked
  
  # Load neighbor (address = $s1 + 16 + 4*i)
  addi $t5, $s1, 16 # Calculate initial offset
  mul $t4, $t3, $t0 # Multiply by additional offset
  add $t4, $t4, $t5 # Calculate neighbor offset
  lw $t4, ($t4) # Load neighbor address
  addi $t3, $t3, 1 # i++
  
  # Check if visited
  addi $t5, $t4, 8 # Calculate neighbor visited address
  lw $t5, ($t5) # Load neighbor visited
  bgtz $t5, check_neighbors # If visited, check next neighbor
  
  # If not visited, update depth and push to queue
  addi $t5, $t4, 4 # Calculate neighbor depth address
  sw $t1, ($t5) # Store depth+1 in node
  
  # Push to queue and increase size
  mul $t5, $t0, $s0 # Calculate queue offset
  add $t5, $t5, $a1 # Calculate address in queue
  sw $t4, ($t5) # Store neightbor address in queue
  addi $s0, $s0, 1 # Increment queue size
  
  j check_neighbors # Check next neighbor or return

BFS_end:
  sw $zero, ($a1) # Remove last value in queue
  # Close all memory
  lw $ra, -4($fp)
  lw $s0, -8($fp)
  lw $s1, -12($fp)
  la $sp, 4($fp)
  lw $fp, ($fp)
  jr $ra
