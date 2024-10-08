# 32-Bit-5-Stage-Pipelined-RISC-V-Processor
Implemented a 32-bit 5-stage RISC-V processor with branch predictor using Verilog. Optimized the Fibonacci algorithm in Assembly Language and demonstrated its performance on FPGA (Libertron FPGA Starter Kit 3)

![image](https://github.com/JMHYU/32-Bit-5-Stage-Pipelined-RISC-V-Processor-/assets/165994759/a68d0767-f77c-4507-9b67-c5909f8e840d)
[Patterson, D. A., & Hennessy, J. L. (n.d.). Computer Organization and Design RISC-V Edition. Morgan Kaufmann.]
<br/>
- I also added a 2-bit branch predictor to this datapath (BTB.v).
<br/>

## Performance (Fibonacci number calculation task)
- Baseline version (without any improvement, basic 5-stage pipelined RISC-V processor)

![original](https://github.com/JMHYU/32-Bit-5-Stage-Pipelined-RISC-V-Processor-/assets/165994759/1115090c-3452-4a19-af99-70b4be8fadca)

> Calculation Result: F(25) = 0x12511 = 75025 (correct!) <br/>
> Number of cycles: 0x48ad76 = 4762998 cycles <br/>

- After Alogorithm optimization (avoiding recursive algorithm, directly compute fibonacci number using dynamic programming method)

![optim](https://github.com/JMHYU/32-Bit-5-Stage-Pipelined-RISC-V-Processor-/assets/165994759/7bc87a76-48a1-45bb-8eb2-1353beb01b86)

> Calculation Result: F(25) = 0x12511 = 75025 (correct!) <br/>
> Number of cycles: 0xbf = 191 cycles <br/>

- 2-bit Branch Predictor + Optimized Algorithm

![predictor](https://github.com/JMHYU/32-Bit-5-Stage-Pipelined-RISC-V-Processor-/assets/165994759/f716d703-0516-4688-9706-00024208d5b9)

> Calculation Result: F(25) = 0x12511 = 75025 (correct!) <br/>
> Number of cycles: 0xaa = 170 cycles <br/>
> Since the Fibonacci algorithm runs in a loop, the branch predictor worked efficiently by predicting the loop's branch outcomes, thereby optimizing the execution flow. <br/>



## Algorithm (in Assembly language)

### Basic Fibonacci Algorithm (Recursive Fibonacci)

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

### Optimized Algorithm (Dynamic Programming Bottom-Up)

This algorithm is exactly how we (human) compute fibonacci numbers (we don't normally compute recursively). The code is in src/darksocv.rom.mem in binary code <br/>
F(n) = ? <br/>
Repeat F(k) = F(k-1) + F(k-2) <br/>

- Key register profile <br/>
> x10: F(k) return value <br/>
> x11: k <br/>
> x6: F(k-1) <br/>
> x5: F(k-2) <br/>
> x7: n <br/>

```assembly
       lw x10, 0(x9)               // load the value n (from src/darksocv.ram.mem) to x10
       addi x28, x0, 2 		// keep the value 2 to compare if n < 2
       addi x5, x0, 0		// the initial value of x5 is F(0) = 0
       addi x6, x0, 1		// the initial value of x6 is F(1) = 1
       addi x11, x0, 1		// k = 1 -> Fibonacci 수열의 인덱싱을 위한 k값
       addi x7, x10, 0		// save the value n at x7 -> will compare this with k to escape the loop
       blt x10, x28, exit1	       // if n < 2 , then exit

fib:   addi x11, x11, 1		// k += 1 -> return F(k) while increasing k
       add x10, x5, x6		// F(k) = F(k-1) + F(k-2)
       addi x5, x6, 0		// F(k-2) <= F(k-1)
       addi x6, x10, 0		// F(k-1) <= F(k)
       bne x11, x7, fib		// if k = n, then exit / otherwise, fib loop

exit1: addi x30, x0, 8
       sw x10, 0(x30)
       addi x31, x0, 400
       mv x30, x31
       
exit0: j exit3
exit3: j exit0
```

> Computational Complexity: O(n), Memory requirement: O(1)
> 

