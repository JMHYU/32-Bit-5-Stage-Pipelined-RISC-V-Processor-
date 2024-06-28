# 32-Bit-5-Stage-Pipelined-RISC-V-Processor
Implemented a 32-bit 5-stage RISC-V processor with branch predictor using Verilog. Optimized the Fibonacci algorithm in Assembly Language and demonstrated its performance on FPGA

## Algorithm (in Assembly language)
- Basic Fibonacci Algorithm (Recursive Fibonacci)
```asm
       lw x10, 0(x9)
       addi x2, x0, 1024
       slli x2, x2, 2
       addi x8, x0, 240
       addi x1, x0, 240
################################################
fib:   beq x10, x0, done
       addi x6, x0, 1
       beq x10, x6, done
       addi x2, x2, -8
       sw x1, 0(x2)
       sw x10, 4(x2)
       addi x10, x10, -1
       jal x1, fib
       lw x5, 4(x2)
       sw x10, 4(x2)
       addi x10, x5, -2
       jal x1, fib
       nop
       lw x5, 4(x2)
       add x10, x10, x5
       lw x1, 0(x2)
       addi x2, x2, 8
done:  beq x1, x8, exit1
       jalr x0, x1, 0
################################################

exit1: addi x30, x0, 8
       sw x10, 0(x30)
       addi x31, x0, 400
       mv x30, x31       
exit3: j exit0
exit0: j exit3
```
> Computational Complexity: O(2^n), Memory requirement: O(n) <br/>
> Recursive, unnecessary memory access(stack) instead of using registers (Idle registers)

<br/>

- Optimized Algorithm (Dynamic Programming Bottom-Up)

```assembly
       lw x10, 0(x9)
       addi x28, x0, 2 		// n < 2 인 경우 비교를 위한 2
       addi x5, x0, 0		// x5 의 초기값은 F(0) = 0으로 지정
       addi x6, x0, 1		// x6 의 초기값은 F(1) = 1로 지정
       addi x11, x0, 1		// k = 1 -> Fibonacci 수열의 인덱싱을 위한 k값
       addi x7, x10, 0		// x7에 n값 저장해 둠. -> k값과 비교해서 루프 탈출.
       blt x10, x28, exit1	// n < 2 인 경우 종료

fib:   addi x11, x11, 1		// k += 1 -> k를 증가시켜가며 F(k) 값 구하기
       add x10, x5, x6		// F(k) = F(k-1) + F(k-2)
       addi x5, x6, 0		// F(k-2) <= F(k-1)
       addi x6, x10, 0		// F(k-1) <= F(k)
       bne x11, x7, fib		// k = n 이면 루프 탈출

exit1: addi x30, x0, 8
       sw x10, 0(x30)
       addi x31, x0, 400
       mv x30, x31
       
exit0: j exit3
exit3: j exit0
```

> Computational Complexity: O(n), Memory requirement: O(1)
> 

