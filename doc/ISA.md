
---
### __BEQ__ `Branch on Equal` p68
|    31-26    | 25-21 | 20-16 |  15-0  |
| :---------: | :---: | :---: | :----: |
| BEQ(000100) |  rs   |  rt   | offset |
|      6      |   5   |   5   |   16   |
#### Format:
>BEQ rs, rt, offset<br>
#### Purpose:
To compare GPR[rs] and GPR[rt] then do a PC-relative conditional branch<br>
#### Description:
*if GPR[rs] = GPR[rt] then branch*<br><br>
An 18-bit signed offset(the 16-bit offset field shifted left 2 bits) is added to the address of the instruction following the branch(not the branch itself), in the branch delay slot, to form a PC-relative effective target address. If the 2 GPRs are equal then branch to the effective target address after the instruction in the delay slot is executed<br>

<div STYLE="page-break-after: always;"></div>

---
### __BEQL__ `Branch on Equal Likely` p69
|    31-26     | 25-21 | 20-16 |  15-0  |
| :----------: | :---: | :---: | :----: |
| BEQL(010100) |  rs   |  rt   | offset |
|      6       |   5   |   5   |   16   |
#### Format:
>BEQL rs, rt, offset<br>
#### Purpose:
To compare GPR[rs] and GPR[rt] then do a PC-relative conditional branch; execute the delay slot only if the branch is taken<br>
#### Description:
*if GPR[rs] == GPR[rt] then branch likely*<br><br>
An 18-bit signed offset(the 16-bit offset field shifted left 2 bits) is added to the address of the instruction following the branch(not the branch itself), in the branch delay slot, to form a PC-relative effective target address. IF the branch is not taken, the instruction in the delay slot is not executed<br>

<div STYLE="page-break-after: always;"></div>

---
### __BGEZ__ `Branch on Greater Than or Equal to Zero` p70
|     31-26      | 25-21 |    20-16    |  15-0  |
| :------------: | :---: | :---------: | :----: |
| REGIMM(000001) |  rs   | BGEZ(00001) | offset |
|       6        |   5   |      5      |   16   |
#### Format:
>BGEZ rs, offset<br>
#### Purpose:
To test a GPR then do a PC-relative conditional branch<br>
#### Description:
*if GPR[rs] >= 0 then branch*<br><br>
An 18-bit signed offset(the 16-bit offset field shifted left 2 bits) is added to the address of the instruction following the branch(not the branch itself), in the branch delay slot, to form a PC-relative effective target address. If the 2 GPRs are greater than or equal to zero, then branch to the effective target address after the instruction in the delay slot is executed<br>

<div STYLE="page-break-after: always;"></div>

---
### __BGEZAL__ `Branch on Greater Than or Equal to Zero and Link` p71
|     31-26      | 25-21 |     20-16     |  15-0  |
| :------------: | :---: | :-----------: | :----: |
| REGIMM(000001) |  rs   | BGEZAL(10001) | offset |
|       6        |   5   |       5       |   16   |
#### Format:
>BGEZAL rs, offset<br>
#### Purpose:
To test a GPR then do a PC-relative conditional procedure call<br>
#### Description:
*if GPR[rs] >= 0 then procedure_call*<br><br>
Place the return address link in GPR[31]. The return link is the address of the second instruction following the branch, where execution continues after a procedure call<br>

<div STYLE="page-break-after: always;"></div>

---
### __BGTZ__ `Branch on Greater Than Zero` p75
|    31-26     | 25-21 |  20-16   |  15-0  |
| :----------: | :---: | :------: | :----: |
| BGTZ(000111) |  rs   | 0(00000) | offset |
|      6       |   5   |    5     |   16   |
#### Format:
>BGTZ rs, offset<br>
#### Purpose:
To test a GPR then do a PC-relative conditional branch<br>
#### Description:
*if GPR[rs] > 0 then branch*<br><br>
An 18-bit signed offset(the 16-bit offset field shifted left 2 bits) is added to the address of the instruction following the branch(not the branch itself), in the branch delay slot, to form a PC-relative effective target address. If the 2 GPRs are greater than zero, then branch to the effective target address after the instruction in the delay slot is executed<br>

<div STYLE="page-break-after: always;"></div>

---
### __BLEZ__ `Branch on Less Than or Equal to Zero` p77
|    31-26     | 25-21 |  20-16   |  15-0  |
| :----------: | :---: | :------: | :----: |
| BLEZ(000110) |  rs   | 0(00000) | offset |
|      6       |   5   |    5     |   16   |
#### Format:
>BLEZ rs, offset<br>
#### Purpose:
To test a GPR then do a PC-relative conditional branch<br>
#### Description:
*if GPR[rs] <= 0 then branch*<br><br>
An 18-bit signed offset(the 16-bit offset field shifted left 2 bits) is added to the address of the instruction following the branch(not the branch itself), in the branch delay slot, to form a PC-relative effective target address. If the contents of GPR rs are less than or equal to zero, then branch to the effective target address after the instruction in the delay slot is executed<br>

<div STYLE="page-break-after: always;"></div>

---
### __BLTZ__ `Branch on Less Than Zero` p79
|     31-26      | 25-21 |    20-16    |  15-0  |
| :------------: | :---: | :---------: | :----: |
| REGIMM(000001) |  rs   | BLTZ(00000) | offset |
|       6        |   5   |      5      |   16   |
#### Format:
>BLTZ rs, offset<br>
#### Purpose:
To test a GPR then do a PC-relative conditional branch<br>
#### Description:
*if GPR[rs] < 0 then branch*<br><br>
An 18-bit signed offset(the 16-bit offset field shifted left 2 bits) is added to the address of the instruction following the branch(not the branch itself), in the branch delay slot, to form a PC-relative effective target address. If the contents of GPR rs are less than zero, then branch to the effective target address after the instruction in the delay slot is executed<br>

<div STYLE="page-break-after: always;"></div>

---
### __BLTZAL__ `Branch on Less Than Zero and Link` p80
|     31-26      | 25-21 |     20-16     |  15-0  |
| :------------: | :---: | :-----------: | :----: |
| REGIMM(000001) |  rs   | BLTZAL(10000) | offset |
|       6        |   5   |       5       |   16   |
#### Format:
>BLTZAL rs, offset<br>
#### Purpose:
To test GPR[rs] then do a PC-relative conditional branch<br>
#### Description:
*if GPR[rs] < 0 then procedure_call*<br><br>
Place the return address link in GPR[31]. The return link is the address of the second instruction following the branch, where execution continues after a procedure call<br>

<div STYLE="page-break-after: always;"></div>

---
### __BNE__ `Branch on Not Equal` p84
|    31-26    | 25-21 | 20-16 |  15-0  |
| :---------: | :---: | :---: | :----: |
| BNE(000101) |  rs   |  rt   | offset |
|      6      |   5   |   5   |   16   |
#### Format:
>BNE rs, rt, offset<br>
#### Purpose:
To compare GPRs then do a PC-relative conditional branch<br>
#### Description:
*if GPR[rs] != GPR[rt] then branch*<br><br>
An 18-bit signed offset(the 16-bit offset field shifted left 2 bits) is added to the address of the instruction following the branch(not the branch itself), in the branch delay slot, to form a PC-relative effective target address. If the contents of GPR rs and GPR rt are not equal, then branch to the effective target address after the instruction in the delay slot is executed<br>

<div STYLE="page-break-after: always;"></div>

---
### __J__ `Jump` p129
|   31-26   |    25-0     |
| :-------: | :---------: |
| J(000010) | instr_index |
|     6     |     26      |
#### Format:
>J target<br>
#### Purpose:
To branch within the current 256MB-aligned region<br>
#### Description:
This is a PC-region branch(not PC-relative); the effective target address is in the "current" 256MB-aligned region. The low 28 bits of the target address is the instr_index field shifted left 2 bits. The remaining upper bits are the corresponding bits of the address of the instruction in the delay slot(not the branch itself)<br>

<div STYLE="page-break-after: always;"></div>

---
### __JAL__ `Jump and Link` p130
|    31-26    |    25-0     |
| :---------: | :---------: |
| JAL(000011) | instr_index |
|      6      |     26      |
#### Format:
>JAL target<br>
#### Purpose:
To execute a procedure call within the current 256MB-aligned region<br>
#### Description:
Place the return address link in GPR[31]. The return link is the address of the second instruction following the branch at which location execution continues after a procedure call<br>

<div STYLE="page-break-after: always;"></div>

---
### __JALR__ `Jump and Link Register` p131
|      31-26      | 25-21 |  20-16   | 15-11 | 10-6  |     5-0      |
| :-------------: | :---: | :------: | :---: | :---: | :----------: |
| SPECIAL(000000) |  rs   | 0(00000) |  rd   | hint  | JALR(001001) |
|        6        |   5   |    5     |   5   |   5   |      6       |
#### Format:
>JALR rs (rd = 31 implied)<br>
>JALR rd, rs<br>
#### Purpose:
To execute a procedure call to an instruction address in a register<br>
#### Description:
*GPR[rd] ¡û return_addr, PC ¡û GPR[rs]*<br><br>
Place the return address link in GPR[rd]. The return link is the address of the second instruction following the branch, where execution continues after a procedure call.<br>

<div STYLE="page-break-after: always;"></div>

---
### __JR__ `Jump Register` p138
|      31-26      | 25-21 |     20-11     | 10-6  |     5-0      |
| :-------------: | :---: | :-----------: | :---: | :----------: |
| SPECIAL(000000) |  rs   | 0(0000000000) | hint  | JALR(001001) |
|        6        |   5   |      10       |   5   |      6       |
#### Format:
>JR rs<br>
#### Purpose:
To execute a branch to an instruction address in a register<br>
#### Description:
*PC ¡û GPR[rs]*<br><br>
Jump to the effective target address in GPR[rs]. Execute the instruction following the jump, in the branch delay slot, before jumping<br>

<div STYLE="page-break-after: always;"></div>

---
### __LWL__  `Load Word Left` p155
|     31-26      | 25-21 |     20-16     |  15-0  |
| :------------: | :---: | :-----------: | :----: |
| REGIMM(000001) |  rs   | BGEZAL(10001) | offset |
|       6        |   5   |       5       |   16   |
#### Format:
>LWL rt, offset(base)<br>
#### Purpose:
To load the most-significant part of a word(GPR[rt]) as a signed value from an unaligned memory address<br>
#### Description:
*Different from MIPS Official Document, this description is aiming at the hardware implemention level*<br>
1. EffAddr = SignedExtended(offset) + GPR[base]<br>
The address where CPU intended to load from<br>
2. AliAddr = EffAddr - EffAddr[1:0]<br>
Because the CPU must load a word through an aligned address, so CPU need to find out the aligned address of this word<br>
3. Save the lower (4 - EffAddr[1:0]) bytes to the left of the GPR[rt]

<div STYLE="page-break-after: always;"></div>

---
### __LL__ `` p149
|   31-26    | 25-21 | 20-16 |  15-0  |
| :--------: | :---: | :---: | :----: |
| LL(110000) | base  |  rt   | offset |
|     6      |   5   |   5   |   16   |
#### Format:
>LL rt, offset(base)<br>
#### Purpose:
To load a word from memory for a atomic read-modify-write<br>
#### Description:
*GPR[rt] ¡û memory[GPR[base] + offset]*<br><br>
The LL and SC instructions provide the primitives to implement atomic read-modify-write(RMW) operations for synchronizable memory locations.<br>

<div STYLE="page-break-after: always;"></div>

---
### ____ `` p71
| 31-26 | 25-21 | 20-16 |  15-0  |
| :---: | :---: | :---: | :----: |
|       |  rs   |       | offset |
|   6   |   5   |   5   |   16   |
#### Format:
><br>
#### Purpose:
<br>
#### Description:
**<br><br>

<div STYLE="page-break-after: always;"></div>

---
### ____ `` p71
| 31-26 | 25-21 | 20-16 |  15-0  |
| :---: | :---: | :---: | :----: |
|       |  rs   |       | offset |
|   6   |   5   |   5   |   16   |
#### Format:
><br>
#### Purpose:
<br>
#### Description:
**<br><br>
