# Immunity-M0

**Immunity-M0** 处理器遵循 **MIPS32 Release 1** 架构，设计类似于 **MIPS32 M14K™** 内核，采用了经典的五级流水结构。

## MIPS32指令集架构简介

如无必要，全文所指MIPS32指令集架构均指MIPS32 Release 1。

### 数据类型

指令的主要任务就是对操作数进行运算，操作数有不同的类型和长度，MIPS32提供的基本数据类型如下。

* 位（b）：长度是 **1bit**。
* 字节（Byte）：长度是 **8bit**。
* 半字（Half Word）：长度是 **16bit**。
* 字（Word）：长度是 **32bit**。
* 双字（Double Word）：长度是 **64bit**。

此外，还有32位单精度浮点数、64位双精度浮点数。

### 寄存器

MIPS32的指令中除加载/存储指令外，都是使用寄存器或立即数作为操作数的。MIPS32中的寄存器分为两类：通用寄存器（General Purpose Register，GPR）、特殊寄存器。

1. **通用寄存器**

    * MIPS32架构定义了32个通用寄存器，使用`$0`、`$1`···`$31`表示，都是32位。其中`$0`一般用作常量0。在硬件上没有强制指定寄存器的使用规则，但是在实际使用中，这些寄存器的用法都遵循一系列约定，例如：寄存器`$31`一般存放子程序的返回地址。MIPS32中通用寄存器的约定如表所示。

    * MIPS32中通用寄存器的约定用法

    |寄存器名|约定命名|用途|
    |:-----:|:------:|:--|
    |`$0`|`zero`|总是为0|
    |`$1`|`at`|留作汇编器生成一些指令|
    |`$2`、`$3`|`v0`、`v1`|用来存放子程序返回值|
    |`$4`~`$7`|`a0`~`a3`|调用子程序时，使用这4个寄存器传输前4个非浮点参数|
    |`$8`~`$15`|`t0`~`t7`|临时寄存器，子程序使用时可以不用存储和恢复|
    |`$16`~`$23`|`s0`~`s7`|子程序寄存器变量，改变这些寄存器值得子程序必须存储旧的值并在退出前恢复，对调用程序来说值不变|
    |`$24`、`$25`|`t8`、`t9`|临时寄存器，子程序使用时可以不用存储和恢复|
    |`$26`、`$27`|`$k0`、`$k1`|由异常处理程序使用|
    |`$28`或`$gp`|`gp`|全局指针|
    |`$29`或`$sp`|`sp`|堆栈指针|
    |`$30`或`$fp`|`s8`/`fp`|子程序可以用来作堆栈帧指针|
    |`$31`|`ra`|存放子程序返回地址|

2. **特殊寄存器**

    * MIPS32架构中定义得特殊寄存器有三个：`PC`（Program Counter程序计数器）、`HI`（乘除结果高位寄存器）、`LO`（乘除结果低位寄存器）。进行乘法运算时，`HI`和`LO`保存乘法运算的结果，其中`HI`存储高32位，`LO`存储低32位；进行除法运算时，`HI`和`LO`保存除法运算的结果，其中`HI`存储余数，`LO`存储商。

### 字节次序

数据在存储器中是按照字节存放的，处理器也是按照字节访问存储器中的指令或数据，但是如果需要读出1个字，也就是4个字节，比如读出的是`mem[n]`、`mem[n+1]`、`mem[n+2]`、`mem[n+3]`这4个字节，那么最终交给处理器的有两种结果。

* `{mem[n], mem[n+1], mem[n+2], mem[n+3]}`
* `{mem[n+3], mem[n+2], mem[n+1], mem[n]}`

前者称为大端模式（Big-Endian），也称为MSB（Most Significant Byte），后者称为小端模式（Little-Endian），也称为LSB（Least Significant Byte）。在大端模式下，数据的高位保存在存储器的低地址中，而数据的低位保存在存储器的高地址中。Immunity-M0处理器采用的是大端模式（Big-Endian）。

### 指令格式

MIPS32架构中的所有指令都是32位，有三种指令格式。如图所示。其中`op`是指令码、`func`是功能码。

<table class="tg">
  <tr>
    <th class="tg-c3ow">类型</th>
    <th class="tg-c3ow" colspan="6">指令</th>
  </tr>
  <tr>
    <td class="tg-c3ow" rowspan="2"><br>R类型</td>
    <td class="tg-c3ow">op</td>
    <td class="tg-c3ow">rs</td>
    <td class="tg-c3ow">rt</td>
    <td class="tg-c3ow">rd</td>
    <td class="tg-c3ow">sa</td>
    <td class="tg-c3ow">func</td>
  </tr>
  <tr>
    <td class="tg-c3ow">6位</td>
    <td class="tg-c3ow">5位</td>
    <td class="tg-c3ow">5位</td>
    <td class="tg-c3ow">5位</td>
    <td class="tg-c3ow">5位</td>
    <td class="tg-c3ow">6位</td>
  </tr>
  <tr>
    <td class="tg-c3ow" rowspan="2"><br>I类型</td>
    <td class="tg-c3ow">op</td>
    <td class="tg-c3ow">rs</td>
    <td class="tg-c3ow">rt</td>
    <td class="tg-c3ow" colspan="3">immediate</td>
  </tr>
  <tr>
    <td class="tg-c3ow">6位</td>
    <td class="tg-c3ow">5位</td>
    <td class="tg-c3ow">5位</td>
    <td class="tg-c3ow" colspan="3">16位</td>
  </tr>
  <tr>
    <td class="tg-c3ow" rowspan="2"><br>J类型</td>
    <td class="tg-c3ow">op</td>
    <td class="tg-c3ow" colspan="5">address</td>
  </tr>
  <tr>
    <td class="tg-c3ow">6位</td>
    <td class="tg-c3ow" colspan="5">26位</td>
  </tr>
</table>

1. R类型：具体操作由`op`、`func`结合指定，`rs`和`rt`是源寄存器的编号，`rd`是目的寄存器的编号。`sa`只有在移位指令中使用，用来指定移位位数。
2. I类型：具体操作由`op`指定，指令的低16位是立即数，运算时要将其扩展至32位，然后作为其中一个源操作数参与运算。
3. J类型：具体操作由`op`指定，一般是跳转指令，低26位是字地址，用于产生跳转的目标地址。

### 指令集

MIPS32架构中定义的指令可以分为以下几类。**注意**：其中不包含浮点指令，因为Immunity-M0处理器不包含浮点处理单元，也就没有实现浮点指令，所以此处不介绍浮点指令。

1. 逻辑操作指令
    * 有8条指令：`and`、`andi`、`or`、`ori`、`xor`、`xori`、`nor`、`lui`，实现逻辑与、或、异或、或非等运算。
2. 移位操作指令
    * 有6条指令：`sll`、`sllv`、`sra`、`srav`、`srl`、`srlv`，实现逻辑左移、右移、算术右移等运算。
3. 移动操作指令
    * 有6条指令：`movn`、`movz`、`mfhi`、`mthi`、`mflo`、`mtlo`，用于通用寄存器之间的数据移动，以及通用寄存器与`HI`、`LO`寄存器之间的数据移动。
4. 算术操作指令
    * 有21条指令：`add`、`addi`、`addiu`、`addu`、`sub`、`subu`、`clo`、`clz`、`slt`、`slti`、`sltiu`、`sltu`、`mul`、`mult`、`multu`、`madd`、`maddu`、`msub`、`msubu`、`div`、`divu`，实现了加法、减法、比较、乘法、乘累加、除法等运算。
5. 转移指令
    * 有14条指令：`jr`、`jalr`、`j`、`jal`、`b`、`bal`、`beq`、`bgez`、`bgezal`、`bgtz`、`blez`、`bltz`、`bltzal`、`bne`，其中既有无条件转移，也有条件转移，用于程序转移到另一个地方执行。
