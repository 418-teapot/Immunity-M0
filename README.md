# Immunity

## 指令格式

MIPS32架构中的所有指令都是32位，有三种指令格式。如图所示。其中op是指令码、func是功能码。

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

1. R类型：具体操作由op、func结合指定，rs和rt是源寄存器的编号，rd是目的寄存器的编号。sa只有在移位指令中使用，用来指定移位位数。
2. I类型：具体操作由op指定，指令的低16位是立即数，运算时要将其扩展至32位，然后作为其中一个源操作数参与运算。
3. J类型：具体操作由op指定，一般是跳转指令，低26位是字地址，用于产生跳转的目标地址。
