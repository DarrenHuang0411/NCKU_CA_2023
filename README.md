# **GNU Toolchain**
contributed by [黃于睿 DarrenHuang0411](https://github.com/DarrenHuang0411/NCKU_CA_2023/tree/Assignment-2)

## **1. Introduction/Motivation**

>The code I chose to implement is contributed by
><[陳燦仁-Shell sort with FP32 in BF16 format](https://hackmd.io/@TRChen/S1CVeW3gp)>

==**Shell sort**== is well-suited for datasets of moderate size. Although it may not be as efficient as certain other sorting algorithms, such as quicksort or mergesort, when dealing with large datasets, it still delivers good performance when applied to ==**small and medium-sized**== datasets.

## **2. Environment**
The environment I tested is using 
>**oracle virtual box machines**
>version : ==7.0==

The OS I tested is using 
>**Linux Ubuntu System**
>version : ==22.04==

## **3. Original C code**

>The code I chose to implement is contributed by
><[陳燦仁-Shell sort with FP32 in BF16 format](https://hackmd.io/@TRChen/S1CVeW3gp)>

:::spoiler **Original C code**
```c=1
#include <stdio.h>
#include <stdbool.h>

#define array_size 6
unsigned int fp32_to_bf16(float x)                 
{
    float y = x;
    int *p = (int *) &y;
    unsigned int exp = *p & 0x7F800000;
    unsigned int man = *p & 0x007FFFFF;
    if (exp == 0 && man == 0) /* zero */
        return *p;
    if (exp == 0x7F800000) /* infinity or NaN */
        return *p;

    float r = x;
    int *pr = (int *) &r;
    *pr &= 0xFF800000;  /* r has the same exp as x */
    r /= 0x100;
    y = x + r;

    *p &= 0xFFFF0000;
    return *p;
}

bool BOS(float fp32_1, float fp32_2){
    unsigned int bf16_1, bf16_2, sig1, sig2, exp1, exp2, man1, man2;
    /* normalize fp32 to bf16 */
    bf16_1 = fp32_to_bf16(fp32_1);
    bf16_2 = fp32_to_bf16(fp32_2);
    sig1 = bf16_1 & 0x80000000;/* To get temp and array[j-interval]'s sig, exp, man'*/
    sig2 = bf16_2 & 0x80000000;
    exp1 = bf16_1 & 0x7F800000;
    exp2 = bf16_2 & 0x7F800000;
    man1 = bf16_1 & 0x007F0000;
    man2 = bf16_2 & 0x007F0000;
    if (sig1 < sig2) return 1; /* Different sign */
    else if (sig1 == 0 && sig1 == sig2 && exp1 > exp2)
        return 1;              /* positive sign but different exp*/
    else if (sig1 != 0 && sig1 == sig2 && exp1 < exp2)
        return 1;              /* negative sign but different exp*/
    else if (sig1 == 0 && sig1 == sig2 && exp1 == exp2 && man1 > man2)
        return 1;              /* posetive sign same exp but different man*/
    else if (sig1 != 0 && sig1 == sig2 && exp1 == exp2 && man1 < man2)
        return 1;              /* negative sign same exp but different man*/
    else return 0;
}

void ShellSort(float array[array_size]){
    int interval = array_size / 2; /* gap /= 2 */
    while (interval >0){
        for(int i = interval;i<array_size;i++){
            int j = i;
            float temp = array[i];
            /* Flag ? temp < array[j-interval]*/
            int Flag = BOS(array[j-interval], temp);
            while (j>= interval && Flag == 1){
                array[j] = array[j-interval];
                j = j-interval;
                Flag = BOS(array[j-interval], temp);
            }
            array[j] = temp;
        }
        interval = interval / 2;
    }
}

void main()
{
    float array[array_size] = {1.6,-1.5,1.4,-1.3,1.2,-1.1};
    ShellSort(array);
    for (int i = 0;i<array_size;i++){
        printf("%f\n",array[i]);
    }
    return 0;
}
```
:::

## **4. Implementation**

### **Rewrite main.c in Ubuntu Terminal**

To optimize and conduct cycle analysis on the original program, it is essential to position the execution of the main program inside the area between `uint64_t oldcount = get_cycles();`(line 90) and `uint64_t cyclecount = get_cycles() - oldcount;`(line 96) in main.c code.

:::spoiler **main.c**
``` c=
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

extern uint64_t get_cycles();
extern uint64_t get_instret();

/*
 * Taken from the Sparkle-suite which is a collection of lightweight symmetric
 * cryptographic algorithms currently in the final round of the NIST
 * standardization effort.
 * See https://sparkle-lwc.github.io/
 */
//extern void sparkle_asm(unsigned int *state, unsigned int ns);

//#define WORDS 12
//#define ROUNDS 7

#define array_size 6
unsigned int fp32_to_bf16(float x)                 
{
    float y = x;
    int *p = (int *) &y;
    unsigned int exp = *p & 0x7F800000;
    unsigned int man = *p & 0x007FFFFF;
    if (exp == 0 && man == 0) /* zero */
        return *p;
    if (exp == 0x7F800000) /* infinity or NaN */
        return *p;

    float r = x;
    int *pr = (int *) &r;
    *pr &= 0xFF800000;  /* r has the same exp as x */
    r /= 0x100;
    y = x + r;

    *p &= 0xFFFF0000;
    return *p;
}

bool BOS(float fp32_1, float fp32_2){
    unsigned int bf16_1, bf16_2, sig1, sig2, exp1, exp2, man1, man2;
    /* normalize fp32 to bf16 */
    bf16_1 = fp32_to_bf16(fp32_1);
    bf16_2 = fp32_to_bf16(fp32_2);
    sig1 = bf16_1 & 0x80000000;/* To get temp and array[j-interval]'s sig, exp, man'*/
    sig2 = bf16_2 & 0x80000000;
    exp1 = bf16_1 & 0x7F800000;
    exp2 = bf16_2 & 0x7F800000;
    man1 = bf16_1 & 0x007F0000;
    man2 = bf16_2 & 0x007F0000;
    if (sig1 < sig2) return 1; /* Different sign */
    else if (sig1 == 0 && sig1 == sig2 && exp1 > exp2)
        return 1;              /* positive sign but different exp*/
    else if (sig1 != 0 && sig1 == sig2 && exp1 < exp2)
        return 1;              /* negative sign but different exp*/
    else if (sig1 == 0 && sig1 == sig2 && exp1 == exp2 && man1 > man2)
        return 1;              /* posetive sign same exp but different man*/
    else if (sig1 != 0 && sig1 == sig2 && exp1 == exp2 && man1 < man2)
        return 1;              /* negative sign same exp but different man*/
    else return 0;
}

void ShellSort(float array[array_size]){
    int interval = array_size / 2; /* gap /= 2 */
    while (interval >0){
        for(int i = interval;i<array_size;i++){
            int j = i;
            float temp = array[i];
            /* Flag ? temp < array[j-interval]*/
            int Flag = BOS(array[j-interval], temp);
            while (j>= interval && Flag == 1){
                array[j] = array[j-interval];
                j = j-interval;
                Flag = BOS(array[j-interval], temp);
            }
            array[j] = temp;
        }
        interval = interval / 2;
    }
}

int main(void)
{
    //unsigned int state[WORDS] = {0};

    /* measure cycles */
    uint64_t instret = get_instret();
    uint64_t oldcount = get_cycles();
    //sparkle_asm(state, ROUNDS);
	
    float array[array_size] = {1.6,-1.5,1.4,-1.3,1.2,-1.1};
    ShellSort(array);

    uint64_t cyclecount = get_cycles() - oldcount;
    
    //for (int i = 0;i<array_size;i++){
    //    printf("%f\n",array[i]);
    //}   

    printf("cycle count: %u\n", (unsigned int) cyclecount);
    printf("instret: %x\n", (unsigned) (instret & 0xffffffff));

    //memset(state, 0, WORDS * sizeof(uint32_t));

    //sparkle_asm(state, ROUNDS);

    //printf("Sparkle state:\n");
    //for (int i = 0; i < WORDS; i += 2)
        //printf("%X %X\n", state[i], state[i + 1]);

    return 0;
}
```
:::

<s>
![](https://hackmd.io/_uploads/Bk-MJaMMa.png)
</s>

:::warning
Don't put the screenshots which contain plain text only.
:notes: jserv
:::

The other functions are put outside the ==main==.

### **Choose the exection to different type**

In the "Makefile," we ought to adjust the gcc options(-O1,O2,O3,Os,Ofast) for optimization and subsequently analyze the variances.
![](https://hackmd.io/_uploads/ry61ck4z6.png)



## **5. Result**

### **-O1 Type**

#### **objdump**
![](https://hackmd.io/_uploads/By-ceEpMa.png)

#### **size**
![](https://hackmd.io/_uploads/rJkRHNRGT.png)

::: spoiler **main**
``` javascript=546
00010864 <main>:
   10864:	fd010113          	add	sp,sp,-48
   10868:	02112623          	sw	ra,44(sp)
   1086c:	8f1ff0ef          	jal	1015c <get_instret>
   10870:	8d9ff0ef          	jal	10148 <get_cycles>
   10874:	000127b7          	lui	a5,0x12
   10878:	5e078793          	add	a5,a5,1504 # 125e0 <__errno+0x8>
   1087c:	0007a503          	lw	a0,0(a5)
   10880:	0047a583          	lw	a1,4(a5)
   10884:	0087a603          	lw	a2,8(a5)
   10888:	00c7a683          	lw	a3,12(a5)
   1088c:	0107a703          	lw	a4,16(a5)
   10890:	0147a783          	lw	a5,20(a5)
   10894:	00a12423          	sw	a0,8(sp)
   10898:	00b12623          	sw	a1,12(sp)
   1089c:	00c12823          	sw	a2,16(sp)
   108a0:	00d12a23          	sw	a3,20(sp)
   108a4:	00e12c23          	sw	a4,24(sp)
   108a8:	00f12e23          	sw	a5,28(sp)
   108ac:	00810513          	add	a0,sp,8
   108b0:	e79ff0ef          	jal	10728 <ShellSort>
   108b4:	895ff0ef          	jal	10148 <get_cycles>
   108b8:	00000513          	li	a0,0
   108bc:	02c12083          	lw	ra,44(sp)
   108c0:	03010113          	add	sp,sp,48
   108c4:	00008067          	ret
```
:::

:::spoiler **BOS**
```javascript=420
0001067c <BOS>:
   1067c:	ff010113          	add	sp,sp,-16
   10680:	00112623          	sw	ra,12(sp)
   10684:	00812423          	sw	s0,8(sp)
   10688:	00912223          	sw	s1,4(sp)
   1068c:	00058493          	mv	s1,a1
   10690:	f99ff0ef          	jal	10628 <fp32_to_bf16>
   10694:	00050413          	mv	s0,a0
   10698:	00048513          	mv	a0,s1
   1069c:	f8dff0ef          	jal	10628 <fp32_to_bf16>
   106a0:	80000737          	lui	a4,0x80000
   106a4:	00e476b3          	and	a3,s0,a4
   106a8:	00e57733          	and	a4,a0,a4
   106ac:	06e6e263          	bltu	a3,a4,10710 <BOS+0x94>
   106b0:	00050793          	mv	a5,a0
   106b4:	7f800737          	lui	a4,0x7f800
   106b8:	00e47633          	and	a2,s0,a4
   106bc:	00e57733          	and	a4,a0,a4
   106c0:	007f06b7          	lui	a3,0x7f0
   106c4:	00d475b3          	and	a1,s0,a3
   106c8:	00d576b3          	and	a3,a0,a3
   106cc:	02044263          	bltz	s0,106f0 <BOS+0x74>
   106d0:	00000513          	li	a0,0
   106d4:	0407c063          	bltz	a5,10714 <BOS+0x98>
   106d8:	00100513          	li	a0,1
   106dc:	02c76c63          	bltu	a4,a2,10714 <BOS+0x98>
   106e0:	00000513          	li	a0,0
   106e4:	02e61863          	bne	a2,a4,10714 <BOS+0x98>
   106e8:	00b6b533          	sltu	a0,a3,a1
   106ec:	0280006f          	j	10714 <BOS+0x98>
   106f0:	00000513          	li	a0,0
   106f4:	0207d063          	bgez	a5,10714 <BOS+0x98>
   106f8:	00100513          	li	a0,1
   106fc:	00e66c63          	bltu	a2,a4,10714 <BOS+0x98>
   10700:	00000513          	li	a0,0
   10704:	00e61863          	bne	a2,a4,10714 <BOS+0x98>
   10708:	00d5b533          	sltu	a0,a1,a3
   1070c:	0080006f          	j	10714 <BOS+0x98>
   10710:	00100513          	li	a0,1
   10714:	00c12083          	lw	ra,12(sp)
   10718:	00812403          	lw	s0,8(sp)
   1071c:	00412483          	lw	s1,4(sp)
   10720:	01010113          	add	sp,sp,16
   10724:	00008067          	ret
```
:::


::: spoiler **fp32_to_bf16**
``` javascript=465
00010628 <fp32_to_bf16>:
   10628:	ff010113          	add	sp,sp,-16
   1062c:	00112623          	sw	ra,12(sp)
   10630:	00812423          	sw	s0,8(sp)
   10634:	00050413          	mv	s0,a0
   10638:	00151793          	sll	a5,a0,0x1
   1063c:	02078863          	beqz	a5,1066c <fp32_to_bf16+0x44>
   10640:	7f8007b7          	lui	a5,0x7f800
   10644:	00a7f733          	and	a4,a5,a0
   10648:	02f70263          	beq	a4,a5,1066c <fp32_to_bf16+0x44>
   1064c:	d681a583          	lw	a1,-664(gp) # 13c70 <__SDATA_BEGIN__>
   10650:	ff800537          	lui	a0,0xff800
   10654:	00857533          	and	a0,a0,s0
   10658:	61c000ef          	jal	10c74 <__mulsf3>
   1065c:	00040593          	mv	a1,s0
   10660:	268000ef          	jal	108c8 <__addsf3>
   10664:	ffff0437          	lui	s0,0xffff0
   10668:	00a47533          	and	a0,s0,a0
   1066c:	00c12083          	lw	ra,12(sp)
   10670:	00812403          	lw	s0,8(sp)
   10674:	01010113          	add	sp,sp,16
   10678:	00008067          	ret
```
:::

::: spoiler **ShellSort**
``` javascript=39
00010728 <ShellSort>:
   10728:	fd010113          	add	sp,sp,-48
   1072c:	02112623          	sw	ra,44(sp)
   10730:	02812423          	sw	s0,40(sp)
   10734:	02912223          	sw	s1,36(sp)
   10738:	03212023          	sw	s2,32(sp)
   1073c:	01312e23          	sw	s3,28(sp)
   10740:	01412c23          	sw	s4,24(sp)
   10744:	01512a23          	sw	s5,20(sp)
   10748:	01612823          	sw	s6,16(sp)
   1074c:	01712623          	sw	s7,12(sp)
   10750:	01812423          	sw	s8,8(sp)
   10754:	01912223          	sw	s9,4(sp)
   10758:	01a12023          	sw	s10,0(sp)
   1075c:	00050c13          	mv	s8,a0
   10760:	00200d13          	li	s10,2
   10764:	00300913          	li	s2,3
   10768:	00600c93          	li	s9,6
   1076c:	0880006f          	j	107f4 <ShellSort+0xcc>
   10770:	000b8493          	mv	s1,s7
   10774:	00249493          	sll	s1,s1,0x2
   10778:	009c04b3          	add	s1,s8,s1
   1077c:	0144a023          	sw	s4,0(s1)
   10780:	001b8b93          	add	s7,s7,1
   10784:	004b0b13          	add	s6,s6,4
   10788:	059b8c63          	beq	s7,s9,107e0 <ShellSort+0xb8>
   1078c:	000b2a03          	lw	s4,0(s6)
   10790:	013b07b3          	add	a5,s6,s3
   10794:	000a0593          	mv	a1,s4
   10798:	0007a503         	lw	a0,0(a5) # 7f800000 <__BSS_END__+0x7f7ec030>
   1079c:	ee1ff0ef          	jal	1067c <BOS>
   107a0:	072bca63          	blt	s7,s2,10814 <ShellSort+0xec>
   107a4:	fc0506e3          	beqz	a0,10770 <ShellSort+0x48>
   107a8:	000b0413          	mv	s0,s6
   107ac:	000b8493          	mv	s1,s7
   107b0:	412484b3          	sub	s1,s1,s2
   107b4:	013407b3          	add	a5,s0,s3
   107b8:	0007a783          	lw	a5,0(a5)
   107bc:	00f42023         	sw	a5,0(s0) # ffff0000 <__BSS_END__+0xfffdc030>
   107c0:	015407b3          	add	a5,s0,s5
   107c4:	000a0593          	mv	a1,s4
   107c8:	0007a503          	lw	a0,0(a5)
   107cc:	eb1ff0ef          	jal	1067c <BOS>
   107d0:	fb24c2e3          	blt	s1,s2,10774 <ShellSort+0x4c>
   107d4:	01340433          	add	s0,s0,s3
   107d8:	fc051ce3          	bnez	a0,107b0 <ShellSort+0x88>
   107dc:	f99ff06f          	j	10774 <ShellSort+0x4c>
   107e0:	01f95793          	srl	a5,s2,0x1f
   107e4:	012787b3          	add	a5,a5,s2
   107e8:	4017d913          	sra	s2,a5,0x1
   107ec:	fffd0d13          	add	s10,s10,-1
   107f0:	020d0e63          	beqz	s10,1082c <ShellSort+0x104>
   107f4:	00291b13          	sll	s6,s2,0x2
   107f8:	016c0b33          	add	s6,s8,s6
   107fc:	412009b3          	neg	s3,s2
   10800:	00299993          	sll	s3,s3,0x2
   10804:	41200ab3          	neg	s5,s2
   10808:	003a9a93          	sll	s5,s5,0x3
   1080c:	00090b93          	mv	s7,s2
   10810:	f7dff06f          	j	1078c <ShellSort+0x64>
   10814:	002b9793          	sll	a5,s7,0x2
   10818:	00fc07b3          	add	a5,s8,a5
   1081c:	0147a023          	sw	s4,0(a5)
   10820:	001b8b93          	add	s7,s7,1
   10824:	004b0b13          	add	s6,s6,4
   10828:	f65ff06f          	j	1078c <ShellSort+0x64>
   1082c:	02c12083          	lw	ra,44(sp)
   10830:	02812403          	lw	s0,40(sp)
   10834:	02412483          	lw	s1,36(sp)
   10838:	02012903          	lw	s2,32(sp)
   1083c:	01c12983          	lw	s3,28(sp)
   10840:	01812a03          	lw	s4,24(sp)
   10844:	01412a83          	lw	s5,20(sp)
   10848:	01012b03          	lw	s6,16(sp)
   1084c:	00c12b83          	lw	s7,12(sp)
   10850:	00812c03          	lw	s8,8(sp)
   10854:	00412c83          	lw	s9,4(sp)
   10858:	00012d03          	lw	s10,0(sp)
   1085c:	03010113          	add	sp,sp,48
   10860:	00008067          	ret
```
:::

### **-O2 Type**
#### **objdump**
![](https://hackmd.io/_uploads/rkl_IjWzp.png)
#### **size**	
![](https://hackmd.io/_uploads/H1mAjSRMT.png)


:::spoiler **main**
``` c=20
000100b0 <main>:
   100b0:	fd010113          	add	sp,sp,-48
   100b4:	02112623          	sw	ra,44(sp)
   100b8:	108000ef          	jal	101c0 <get_instret>
   100bc:	0f0000ef          	jal	101ac <get_cycles>
   100c0:	000127b7          	lui	a5,0x12
   100c4:	67078793          	add	a5,a5,1648 # 12670 <__errno+0x8>
   100c8:	0007a803          	lw	a6,0(a5)
   100cc:	0047a583          	lw	a1,4(a5)
   100d0:	0087a603          	lw	a2,8(a5)
   100d4:	00c7a683          	lw	a3,12(a5)
   100d8:	0107a703          	lw	a4,16(a5)
   100dc:	0147a783          	lw	a5,20(a5)
   100e0:	00810513          	add	a0,sp,8
   100e4:	01012423          	sw	a6,8(sp)
   100e8:	00b12623          	sw	a1,12(sp)
   100ec:	00c12823          	sw	a2,16(sp)
   100f0:	00d12a23          	sw	a3,20(sp)
   100f4:	00e12c23          	sw	a4,24(sp)
   100f8:	00f12e23          	sw	a5,28(sp)
   100fc:	728000ef          	jal	10824 <ShellSort>
   10100:	0ac000ef          	jal	101ac <get_cycles>
   10104:	02c12083          	lw	ra,44(sp)
   10108:	00000513          	li	a0,0
   1010c:	03010113          	add	sp,sp,48
   10110:	00008067          	ret
```
:::

:::spoiler **BOS**
``` c=420
000106f4 <BOS>:
   106f4:	fe010113          	add	sp,sp,-32
   106f8:	00812c23          	sw	s0,24(sp)
   106fc:	00912a23          	sw	s1,20(sp)
   10700:	01212823          	sw	s2,16(sp)
   10704:	00112e23          	sw	ra,28(sp)
   10708:	01312623          	sw	s3,12(sp)
   1070c:	00151793          	sll	a5,a0,0x1
   10710:	00050493          	mv	s1,a0
   10714:	00058413          	mv	s0,a1
   10718:	00050913          	mv	s2,a0
   1071c:	02078c63          	beqz	a5,10754 <BOS+0x60>
   10720:	7f8007b7          	lui	a5,0x7f800
   10724:	00a7f733          	and	a4,a5,a0
   10728:	800009b7          	lui	s3,0x80000
   1072c:	0ef70863          	beq	a4,a5,1081c <BOS+0x128>
   10730:	d681a583          	lw	a1,-664(gp) # 13578 <__SDATA_BEGIN__>
   10734:	ff800537          	lui	a0,0xff800
   10738:	00957533          	and	a0,a0,s1
   1073c:	5c8000ef          	jal	10d04 <__mulsf3>
   10740:	00048593          	mv	a1,s1
   10744:	214000ef          	jal	10958 <__addsf3>
   10748:	ffff0937          	lui	s2,0xffff0
   1074c:	00a97933          	and	s2,s2,a0
   10750:	00a9f4b3          	and	s1,s3,a0
   10754:	00141793          	sll	a5,s0,0x1
   10758:	800009b7          	lui	s3,0x80000
   1075c:	0a078663          	beqz	a5,10808 <BOS+0x114>
   10760:	7f8007b7          	lui	a5,0x7f800
   10764:	0087f733          	and	a4,a5,s0
   10768:	0af70463          	beq	a4,a5,10810 <BOS+0x11c>
   1076c:	d681a583          	lw	a1,-664(gp) # 13578 <__SDATA_BEGIN__>
   10770:	ff800537          	lui	a0,0xff800
   10774:	00857533          	and	a0,a0,s0
   10778:	58c000ef          	jal	10d04 <__mulsf3>
   1077c:	00040593          	mv	a1,s0
   10780:	1d8000ef          	jal	10958 <__addsf3>
   10784:	ffff07b7          	lui	a5,0xffff0
   10788:	00a7f7b3          	and	a5,a5,a0
   1078c:	00a9f433          	and	s0,s3,a0
   10790:	00100513          	li	a0,1
   10794:	0284ee63          	bltu	s1,s0,107d0 <BOS+0xdc>
   10798:	7f800737          	lui	a4,0x7f800
   1079c:	007f06b7          	lui	a3,0x7f0
   107a0:	00e97633          	and	a2,s2,a4
   107a4:	00d975b3          	and	a1,s2,a3
   107a8:	00e7f733          	and	a4,a5,a4
   107ac:	00d7f6b3          	and	a3,a5,a3
   107b0:	00000513          	li	a0,0
   107b4:	02094c63          	bltz	s2,107ec <BOS+0xf8>
   107b8:	0007cc63          	bltz	a5,107d0 <BOS+0xdc>
   107bc:	00100513          	li	a0,1
   107c0:	00c76863          	bltu	a4,a2,107d0 <BOS+0xdc>
   107c4:	00000513          	li	a0,0
   107c8:	00e61463          	bne	a2,a4,107d0 <BOS+0xdc>
   107cc:	00b6b533          	sltu	a0,a3,a1
   107d0:	01c12083          	lw	ra,28(sp)
   107d4:	01812403          	lw	s0,24(sp)
   107d8:	01412483          	lw	s1,20(sp)
   107dc:	01012903          	lw	s2,16(sp)
   107e0:	00c12983          	lw	s3,12(sp)
   107e4:	02010113          	add	sp,sp,32
   107e8:	00008067          	ret
   107ec:	fe07d2e3          	bgez	a5,107d0 <BOS+0xdc>
   107f0:	00100513          	li	a0,1
   107f4:	fce66ee3          	bltu	a2,a4,107d0 <BOS+0xdc>
   107f8:	00000513          	li	a0,0
   107fc:	fce61ae3          	bne	a2,a4,107d0 <BOS+0xdc>
   10800:	00d5b533          	sltu	a0,a1,a3
   10804:	fcdff06f          	j	107d0 <BOS+0xdc>
   10808:	00040793          	mv	a5,s0
   1080c:	f85ff06f          	j	10790 <BOS+0x9c>
   10810:	00040793          	mv	a5,s0
   10814:	0089f433          	and	s0,s3,s0
   10818:	f79ff06f          	j	10790 <BOS+0x9c>
   1081c:	00a9f4b3          	and	s1,s3,a0
   10820:	f35ff06f          	j	10754 <BOS+0x60>
```
:::


::: spoiler **fp32_to_bf16**
``` javascript=465
00010628 <fp32_to_bf16>:
   10628:	ff010113          	add	sp,sp,-16
   1062c:	00112623          	sw	ra,12(sp)
   10630:	00812423          	sw	s0,8(sp)
   10634:	00050413          	mv	s0,a0
   10638:	00151793          	sll	a5,a0,0x1
   1063c:	02078863          	beqz	a5,1066c <fp32_to_bf16+0x44>
   10640:	7f8007b7          	lui	a5,0x7f800
   10644:	00a7f733          	and	a4,a5,a0
   10648:	02f70263          	beq	a4,a5,1066c <fp32_to_bf16+0x44>
   1064c:	d681a583          	lw	a1,-664(gp) # 13c70 <__SDATA_BEGIN__>
   10650:	ff800537          	lui	a0,0xff800
   10654:	00857533          	and	a0,a0,s0
   10658:	61c000ef          	jal	10c74 <__mulsf3>
   1065c:	00040593          	mv	a1,s0
   10660:	268000ef          	jal	108c8 <__addsf3>
   10664:	ffff0437          	lui	s0,0xffff0
   10668:	00a47533          	and	a0,s0,a0
   1066c:	00c12083          	lw	ra,12(sp)
   10670:	00812403          	lw	s0,8(sp)
   10674:	01010113          	add	sp,sp,16
   10678:	00008067          	ret
```
:::

::: spoiler **ShellSort**
``` javascript=530
00010824 <ShellSort>:
   10824:	fb010113          	add	sp,sp,-80
   10828:	00200793          	li	a5,2
   1082c:	04812423          	sw	s0,72(sp)
   10830:	03812423          	sw	s8,40(sp)
   10834:	03912223          	sw	s9,36(sp)
   10838:	04112623          	sw	ra,76(sp)
   1083c:	04912223          	sw	s1,68(sp)
   10840:	05212023          	sw	s2,64(sp)
   10844:	03312e23          	sw	s3,60(sp)
   10848:	03412c23          	sw	s4,56(sp)
   1084c:	03512a23          	sw	s5,52(sp)
   10850:	03612823          	sw	s6,48(sp)
   10854:	03712623          	sw	s7,44(sp)
   10858:	03a12023          	sw	s10,32(sp)
   1085c:	01b12e23          	sw	s11,28(sp)
   10860:	00050c93          	mv	s9,a0
   10864:	00f12623          	sw	a5,12(sp)
   10868:	00300413          	li	s0,3
   1086c:	00600c13          	li	s8,6
   10870:	00241493          	sll	s1,s0,0x2
   10874:	009c8b33          	add	s6,s9,s1
   10878:	000c8b93          	mv	s7,s9
   1087c:	40900a33          	neg	s4,s1
   10880:	00040a93          	mv	s5,s0
   10884:	000b2903          	lw	s2,0(s6)
   10888:	000ba503          	lw	a0,0(s7)
   1088c:	000b0993          	mv	s3,s6
   10890:	00090593          	mv	a1,s2
   10894:	e61ff0ef          	jal	106f4 <BOS>
   10898:	0a8ac863          	blt	s5,s0,10948 <ShellSort+0x124>
   1089c:	04050063          	beqz	a0,108dc <ShellSort+0xb8>
   108a0:	000b8d13          	mv	s10,s7
   108a4:	000a8d93          	mv	s11,s5
   108a8:	00c0006f          	j	108b4 <ShellSort+0x90>
   108ac:	409d0d33          	sub	s10,s10,s1
   108b0:	02050663          	beqz	a0,108dc <ShellSort+0xb8>
   108b4:	000d2583          	lw	a1,0(s10)
   108b8:	009d06b3          	add	a3,s10,s1
   108bc:	014d0733          	add	a4,s10,s4
   108c0:	00b6a023         	sw	a1,0(a3) # 7f0000 <__BSS_END__+0x7dc728>
   108c4:	00072503         	lw	a0,0(a4) # 7f800000 <__BSS_END__+0x7f7ec728>
   108c8:	408d8db3          	sub	s11,s11,s0
   108cc:	00090593          	mv	a1,s2
   108d0:	000d0993          	mv	s3,s10
   108d4:	e21ff0ef          	jal	106f4 <BOS>
   108d8:	fc8ddae3          	bge	s11,s0,108ac <ShellSort+0x88>
   108dc:	0129a023         	sw	s2,0(s3) # 80000000 <__BSS_END__+0x7ffec728>
   108e0:	001a8a93          	add	s5,s5,1
   108e4:	004b0b13          	add	s6,s6,4
   108e8:	004b8b93          	add	s7,s7,4
   108ec:	f98a9ce3          	bne	s5,s8,10884 <ShellSort+0x60>
   108f0:	00c12783          	lw	a5,12(sp)
   108f4:	00100713          	li	a4,1
   108f8:	00100413          	li	s0,1
   108fc:	00e78863          	beq	a5,a4,1090c <ShellSort+0xe8>
   10900:	00100793          	li	a5,1
   10904:	00f12623          	sw	a5,12(sp)
   10908:	f69ff06f          	j	10870 <ShellSort+0x4c>
   1090c:	04c12083          	lw	ra,76(sp)
   10910:	04812403          	lw	s0,72(sp)
   10914:	04412483          	lw	s1,68(sp)
   10918:	04012903          	lw	s2,64(sp)
   1091c:	03c12983          	lw	s3,60(sp)
   10920:	03812a03          	lw	s4,56(sp)
   10924:	03412a83          	lw	s5,52(sp)
   10928:	03012b03          	lw	s6,48(sp)
   1092c:	02c12b83          	lw	s7,44(sp)
   10930:	02812c03          	lw	s8,40(sp)
   10934:	02412c83          	lw	s9,36(sp)
   10938:	02012d03          	lw	s10,32(sp)
   1093c:	01c12d83          	lw	s11,28(sp)
   10940:	05010113          	add	sp,sp,80
   10944:	00008067          	ret
   10948:	001a8a93          	add	s5,s5,1
   1094c:	004b0b13          	add	s6,s6,4
   10950:	004b8b93          	add	s7,s7,4
   10954:	f31ff06f          	j	10884 <ShellSort+0x60>
```
:::
	
### **-O3 Type**
#### **objdump**
![](https://hackmd.io/_uploads/SyqJwj-fa.png)
#### **size**
![](https://hackmd.io/_uploads/rJFHpSCfa.png)

:::spoiler **main**
``` c=20
000100b0 <main>:
   100b0:	fd010113          	add	sp,sp,-48
   100b4:	02112623          	sw	ra,44(sp)
   100b8:	02812423          	sw	s0,40(sp)
   100bc:	02912223          	sw	s1,36(sp)
   100c0:	138000ef          	jal	101f8 <get_instret>
   100c4:	00050413          	mv	s0,a0
   100c8:	11c000ef          	jal	101e4 <get_cycles>
   100cc:	0001d7b7          	lui	a5,0x1d
   100d0:	da878793          	add	a5,a5,-600 # 1cda8 <__trunctfdf2+0x5aa>
   100d4:	0007a803          	lw	a6,0(a5)
   100d8:	0087a603          	lw	a2,8(a5)
   100dc:	00c7a683          	lw	a3,12(a5)
   100e0:	0107a703          	lw	a4,16(a5)
   100e4:	0047a583          	lw	a1,4(a5)
   100e8:	0147a783          	lw	a5,20(a5)
   100ec:	00050493          	mv	s1,a0
   100f0:	00810513          	add	a0,sp,8
   100f4:	01012423          	sw	a6,8(sp)
   100f8:	00c12823          	sw	a2,16(sp)
   100fc:	00d12a23          	sw	a3,20(sp)
   10100:	00e12c23          	sw	a4,24(sp)
   10104:	00f12e23          	sw	a5,28(sp)
   10108:	00b12623          	sw	a1,12(sp)
   1010c:	754000ef          	jal	10860 <ShellSort>
   10110:	0d4000ef          	jal	101e4 <get_cycles>
   10114:	409505b3          	sub	a1,a0,s1
   10118:	0001d537          	lui	a0,0x1d
   1011c:	aa850513          	add	a0,a0,-1368 # 1caa8 <__trunctfdf2+0x2aa>
   10120:	546010ef          	jal	11666 <printf>
   10124:	0001d537          	lui	a0,0x1d
   10128:	00040593          	mv	a1,s0
   1012c:	abc50513          	add	a0,a0,-1348 # 1cabc <__trunctfdf2+0x2be>
   10130:	536010ef          	jal	11666 <printf>
   10134:	02c12083          	lw	ra,44(sp)
   10138:	02812403          	lw	s0,40(sp)
   1013c:	02412483          	lw	s1,36(sp)
   10140:	00000513          	li	a0,0
   10144:	03010113          	add	sp,sp,48
   10148:	00008067          	ret

```
:::

:::spoiler **BOS**

``` c=466
0001072c <BOS>:
   1072c:	fe010113          	add	sp,sp,-32
   10730:	00812c23          	sw	s0,24(sp)
   10734:	00912a23          	sw	s1,20(sp)
   10738:	01212823          	sw	s2,16(sp)
   1073c:	00112e23          	sw	ra,28(sp)
   10740:	01312623          	sw	s3,12(sp)
   10744:	00151793          	sll	a5,a0,0x1
   10748:	00050493          	mv	s1,a0
   1074c:	00058413          	mv	s0,a1
   10750:	00050913          	mv	s2,a0
   10754:	02078c63          	beqz	a5,1078c <BOS+0x60>
   10758:	7f8007b7          	lui	a5,0x7f800
   1075c:	00a7f733          	and	a4,a5,a0
   10760:	800009b7          	lui	s3,0x80000
   10764:	0ef70463          	beq	a4,a5,1084c <BOS+0x120>
   10768:	f601a583         	lw	a1,-160(gp) # 1e770 <__SDATA_BEGIN__+0x68>
   1076c:	ff800537          	lui	a0,0xff800
   10770:	00957533          	and	a0,a0,s1
   10774:	7d4000ef          	jal	10f48 <__mulsf3>
   10778:	00048593          	mv	a1,s1
   1077c:	420000ef          	jal	10b9c <__addsf3>
   10780:	ffff0937          	lui	s2,0xffff0
   10784:	00a97933          	and	s2,s2,a0
   10788:	00a9f4b3          	and	s1,s3,a0
   1078c:	00141713          	sll	a4,s0,0x1
   10790:	00040793          	mv	a5,s0
   10794:	800009b7          	lui	s3,0x80000
   10798:	00040693          	mv	a3,s0
   1079c:	02070c63          	beqz	a4,107d4 <BOS+0xa8>
   107a0:	7f800737          	lui	a4,0x7f800
   107a4:	008776b3          	and	a3,a4,s0
   107a8:	0ae68663          	beq	a3,a4,10854 <BOS+0x128>
   107ac:	f601a583         	lw	a1,-160(gp) # 1e770 <__SDATA_BEGIN__+0x68>
   107b0:	ff800537          	lui	a0,0xff800
   107b4:	00857533          	and	a0,a0,s0
   107b8:	790000ef          	jal	10f48 <__mulsf3>
   107bc:	00040593          	mv	a1,s0
   107c0:	3dc000ef          	jal	10b9c <__addsf3>
   107c4:	ffff07b7          	lui	a5,0xffff0
   107c8:	00a7f7b3          	and	a5,a5,a0
   107cc:	00078693          	mv	a3,a5
   107d0:	00a9f433          	and	s0,s3,a0
   107d4:	00100513          	li	a0,1
   107d8:	0284ee63          	bltu	s1,s0,10814 <BOS+0xe8>
   107dc:	7f800737          	lui	a4,0x7f800
   107e0:	007f0637          	lui	a2,0x7f0
   107e4:	00e975b3          	and	a1,s2,a4
   107e8:	00c97833          	and	a6,s2,a2
   107ec:	00e6f733          	and	a4,a3,a4
   107f0:	00000513          	li	a0,0
   107f4:	00c6f6b3          	and	a3,a3,a2
   107f8:	02094c63          	bltz	s2,10830 <BOS+0x104>
   107fc:	0007cc63          	bltz	a5,10814 <BOS+0xe8>
   10800:	00100513          	li	a0,1
   10804:	00b76863          	bltu	a4,a1,10814 <BOS+0xe8>
   10808:	00000513          	li	a0,0
   1080c:	00e59463          	bne	a1,a4,10814 <BOS+0xe8>
   10810:	0106b533          	sltu	a0,a3,a6
   10814:	01c12083          	lw	ra,28(sp)
   10818:	01812403          	lw	s0,24(sp)
   1081c:	01412483          	lw	s1,20(sp)
   10820:	01012903          	lw	s2,16(sp)
   10824:	00c12983          	lw	s3,12(sp)
   10828:	02010113          	add	sp,sp,32
   1082c:	00008067          	ret
   10830:	fe07d2e3          	bgez	a5,10814 <BOS+0xe8>
   10834:	00100513          	li	a0,1
   10838:	fce5eee3          	bltu	a1,a4,10814 <BOS+0xe8>
   1083c:	00000513          	li	a0,0
   10840:	fce59ae3          	bne	a1,a4,10814 <BOS+0xe8>
   10844:	00d83533          	sltu	a0,a6,a3
   10848:	fcdff06f          	j	10814 <BOS+0xe8>
   1084c:	00a9f4b3          	and	s1,s3,a0
   10850:	f3dff06f          	j	1078c <BOS+0x60>
   10854:	00040693          	mv	a3,s0
   10858:	0089f433          	and	s0,s3,s0
   1085c:	f79ff06f          	j	107d4 <BOS+0xa8>
```
:::

:::spoiler **fp32_to_bf16**
```c=438
000106c4 <fp32_to_bf16>:
   106c4:	ff010113          	add	sp,sp,-16
   106c8:	00812423          	sw	s0,8(sp)
   106cc:	00112623          	sw	ra,12(sp)
   106d0:	00151793          	sll	a5,a0,0x1
   106d4:	00050413          	mv	s0,a0
   106d8:	04078063          	beqz	a5,10718 <fp32_to_bf16+0x54>
   106dc:	7f8007b7          	lui	a5,0x7f800
   106e0:	00a7f733          	and	a4,a5,a0
   106e4:	02f70a63          	beq	a4,a5,10718 <fp32_to_bf16+0x54>
   106e8:	f601a583          	lw	a1,-160(gp) # 1e770 <__SDATA_BEGIN__+0x68>
   106ec:	ff800537          	lui	a0,0xff800
   106f0:	00857533          	and	a0,a0,s0
   106f4:	055000ef          	jal	10f48 <__mulsf3>
   106f8:	00040593          	mv	a1,s0
   106fc:	4a0000ef          	jal	10b9c <__addsf3>
   10700:	ffff0437          	lui	s0,0xffff0
   10704:	00c12083          	lw	ra,12(sp)
   10708:	00a47533          	and	a0,s0,a0
   1070c:	00812403          	lw	s0,8(sp)
   10710:	01010113          	add	sp,sp,16
   10714:	00008067          	ret
   10718:	00c12083          	lw	ra,12(sp)
   1071c:	00040513          	mv	a0,s0
   10720:	00812403          	lw	s0,8(sp)
   10724:	01010113          	add	sp,sp,16
   10728:	00008067          	ret
```
:::

:::spoiler **ShellSort**
``` c=545
00010860 <ShellSort>:
   10860:	f601a783          	lw	a5,-160(gp) # 1e770 <__SDATA_BEGIN__+0x68>
   10864:	f9010113          	add	sp,sp,-112
   10868:	05412c23          	sw	s4,88(sp)
   1086c:	05912223          	sw	s9,68(sp)
   10870:	80000a37          	lui	s4,0x80000
   10874:	00200c93          	li	s9,2
   10878:	06812423          	sw	s0,104(sp)
   1087c:	05612823          	sw	s6,80(sp)
   10880:	05712623          	sw	s7,76(sp)
   10884:	05812423          	sw	s8,72(sp)
   10888:	03b12e23          	sw	s11,60(sp)
   1088c:	06112623          	sw	ra,108(sp)
   10890:	06912223          	sw	s1,100(sp)
   10894:	07212023          	sw	s2,96(sp)
   10898:	05312e23          	sw	s3,92(sp)
   1089c:	05512a23          	sw	s5,84(sp)
   108a0:	05a12023          	sw	s10,64(sp)
   108a4:	00f12223          	sw	a5,4(sp)
   108a8:	00300413          	li	s0,3
   108ac:	fffa0b93          	add	s7,s4,-1 # 7fffffff <__BSS_END__+0x7ffe127b>
   108b0:	7f800b37          	lui	s6,0x7f800
   108b4:	ffff0c37          	lui	s8,0xffff0
   108b8:	007f0db7          	lui	s11,0x7f0
   108bc:	03912423          	sw	s9,40(sp)
   108c0:	02a12623          	sw	a0,44(sp)
   108c4:	02c12783          	lw	a5,44(sp)
   108c8:	00241493          	sll	s1,s0,0x2
   108cc:	409009b3          	neg	s3,s1
   108d0:	00978733          	add	a4,a5,s1
   108d4:	00e12e23          	sw	a4,28(sp)
   108d8:	00f12a23          	sw	a5,20(sp)
   108dc:	00812823          	sw	s0,16(sp)
   108e0:	01c12903          	lw	s2,28(sp)
   108e4:	01412c83          	lw	s9,20(sp)
   108e8:	00092783          	lw	a5,0(s2) # ffff0000 <__BSS_END__+0xfffd127c>
   108ec:	000ca503          	lw	a0,0(s9)
   108f0:	00078593          	mv	a1,a5
   108f4:	00078a93          	mv	s5,a5
   108f8:	00f12623          	sw	a5,12(sp)
   108fc:	e31ff0ef          	jal	1072c <BOS>
   10900:	01012d03          	lw	s10,16(sp)
   10904:	268d4a63          	blt	s10,s0,10b78 <ShellSort+0x318>
   10908:	10050063          	beqz	a0,10a08 <ShellSort+0x1a8>
   1090c:	015bf7b3          	and	a5,s7,s5
   10910:	16078e63          	beqz	a5,10a8c <ShellSort+0x22c>
   10914:	015b77b3          	and	a5,s6,s5
   10918:	00f12423          	sw	a5,8(sp)
   1091c:	014af7b3          	and	a5,s5,s4
   10920:	02f12023          	sw	a5,32(sp)
   10924:	ff8007b7          	lui	a5,0xff800
   10928:	00faf7b3          	and	a5,s5,a5
   1092c:	00f12c23          	sw	a5,24(sp)
   10930:	000d0793          	mv	a5,s10
   10934:	03512223          	sw	s5,36(sp)
   10938:	00040d13          	mv	s10,s0
   1093c:	00048913          	mv	s2,s1
   10940:	000c8413          	mv	s0,s9
   10944:	00098c93          	mv	s9,s3
   10948:	00078993          	mv	s3,a5
   1094c:	00042583          	lw	a1,0(s0) # ffff0000 <__BSS_END__+0xfffd127c>
   10950:	01240733          	add	a4,s0,s2
   10954:	019407b3          	add	a5,s0,s9
   10958:	00b72023          	sw	a1,0(a4) # 7f800000 <__BSS_END__+0x7f7e127c>
   1095c:	0007aa83          	lw	s5,0(a5) # ff800000 <__BSS_END__+0xff7e127c>
   10960:	00812023          	sw	s0,0(sp)
   10964:	41a989b3          	sub	s3,s3,s10
   10968:	015bf7b3          	and	a5,s7,s5
   1096c:	000a8493          	mv	s1,s5
   10970:	02078663          	beqz	a5,1099c <ShellSort+0x13c>
   10974:	015b77b3          	and	a5,s6,s5
   10978:	11678663          	beq	a5,s6,10a84 <ShellSort+0x224>
   1097c:	00412583          	lw	a1,4(sp)
   10980:	ff8007b7          	lui	a5,0xff800
   10984:	0157f533          	and	a0,a5,s5
   10988:	5c0000ef          	jal	10f48 <__mulsf3>
   1098c:	000a8593          	mv	a1,s5
   10990:	20c000ef          	jal	10b9c <__addsf3>
   10994:	00ac74b3          	and	s1,s8,a0
   10998:	00aa7ab3          	and	s5,s4,a0
   1099c:	00812783          	lw	a5,8(sp)
   109a0:	0d678a63          	beq	a5,s6,10a74 <ShellSort+0x214>
   109a4:	00412583          	lw	a1,4(sp)
   109a8:	01812503          	lw	a0,24(sp)
   109ac:	59c000ef          	jal	10f48 <__mulsf3>
   109b0:	00c12583          	lw	a1,12(sp)
   109b4:	1e8000ef          	jal	10b9c <__addsf3>
   109b8:	00ac7733          	and	a4,s8,a0
   109bc:	00070793          	mv	a5,a4
   109c0:	00aa7533          	and	a0,s4,a0
   109c4:	08aae863          	bltu	s5,a0,10a54 <ShellSort+0x1f4>
   109c8:	0167f5b3          	and	a1,a5,s6
   109cc:	0164f533          	and	a0,s1,s6
   109d0:	01b4f8b3          	and	a7,s1,s11
   109d4:	01b7f7b3          	and	a5,a5,s11
   109d8:	0804c463          	bltz	s1,10a60 <ShellSort+0x200>
   109dc:	00074e63          	bltz	a4,109f8 <ShellSort+0x198>
   109e0:	06a5ea63          	bltu	a1,a0,10a54 <ShellSort+0x1f4>
   109e4:	00b51a63          	bne	a0,a1,109f8 <ShellSort+0x198>
   109e8:	0117b8b3          	sltu	a7,a5,a7
   109ec:	01a9c663          	blt	s3,s10,109f8 <ShellSort+0x198>
   109f0:	41240433          	sub	s0,s0,s2
   109f4:	f4089ce3          	bnez	a7,1094c <ShellSort+0xec>
   109f8:	00090493          	mv	s1,s2
   109fc:	00012903          	lw	s2,0(sp)
   10a00:	000c8993          	mv	s3,s9
   10a04:	000d0413          	mv	s0,s10
   10a08:	01c12703          	lw	a4,28(sp)
   10a0c:	00c12783          	lw	a5,12(sp)
   10a10:	00470713          	add	a4,a4,4
   10a14:	00f92023          	sw	a5,0(s2)
   10a18:	00e12e23          	sw	a4,28(sp)
   10a1c:	01012783          	lw	a5,16(sp)
   10a20:	01412703          	lw	a4,20(sp)
   10a24:	00178793          	add	a5,a5,1 # ff800001 <__BSS_END__+0xff7e127d>
   10a28:	00470713          	add	a4,a4,4
   10a2c:	00e12a23          	sw	a4,20(sp)
   10a30:	00f12823          	sw	a5,16(sp)
   10a34:	00600713          	li	a4,6
   10a38:	eae794e3          	bne	a5,a4,108e0 <ShellSort+0x80>
   10a3c:	02812783          	lw	a5,40(sp)
   10a40:	00100413          	li	s0,1
   10a44:	0e878c63          	beq	a5,s0,10b3c <ShellSort+0x2dc>
   10a48:	00100793          	li	a5,1
   10a4c:	02f12423          	sw	a5,40(sp)
   10a50:	e75ff06f          	j	108c4 <ShellSort+0x64>
   10a54:	fba9c2e3          	blt	s3,s10,109f8 <ShellSort+0x198>
   10a58:	41240433          	sub	s0,s0,s2
   10a5c:	ef1ff06f          	j	1094c <ShellSort+0xec>
   10a60:	f8075ce3          	bgez	a4,109f8 <ShellSort+0x198>
   10a64:	feb568e3          	bltu	a0,a1,10a54 <ShellSort+0x1f4>
   10a68:	f8b518e3          	bne	a0,a1,109f8 <ShellSort+0x198>
   10a6c:	00f8b8b3          	sltu	a7,a7,a5
   10a70:	f7dff06f          	j	109ec <ShellSort+0x18c>
   10a74:	02412703          	lw	a4,36(sp)
   10a78:	02012503          	lw	a0,32(sp)
   10a7c:	00070793          	mv	a5,a4
   10a80:	f45ff06f          	j	109c4 <ShellSort+0x164>
   10a84:	015a7ab3          	and	s5,s4,s5
   10a88:	f15ff06f          	j	1099c <ShellSort+0x13c>
   10a8c:	01012603          	lw	a2,16(sp)
   10a90:	000c8d13          	mv	s10,s9
   10a94:	00060913          	mv	s2,a2
   10a98:	000d2683          	lw	a3,0(s10)
   10a9c:	009d0733          	add	a4,s10,s1
   10aa0:	013d07b3          	add	a5,s10,s3
   10aa4:	00d72023          	sw	a3,0(a4)
   10aa8:	0007ac83          	lw	s9,0(a5)
   10aac:	40890933          	sub	s2,s2,s0
   10ab0:	000d0713          	mv	a4,s10
   10ab4:	019bf7b3          	and	a5,s7,s9
   10ab8:	06078863          	beqz	a5,10b28 <ShellSort+0x2c8>
   10abc:	019b77b3          	and	a5,s6,s9
   10ac0:	07678863          	beq	a5,s6,10b30 <ShellSort+0x2d0>
   10ac4:	00412583          	lw	a1,4(sp)
   10ac8:	ff8007b7          	lui	a5,0xff800
   10acc:	0197f533          	and	a0,a5,s9
   10ad0:	01a12023          	sw	s10,0(sp)
   10ad4:	474000ef          	jal	10f48 <__mulsf3>
   10ad8:	000c8593          	mv	a1,s9
   10adc:	0c0000ef          	jal	10b9c <__addsf3>
   10ae0:	00012703          	lw	a4,0(sp)
   10ae4:	00ac77b3          	and	a5,s8,a0
   10ae8:	00aa7cb3          	and	s9,s4,a0
   10aec:	035ce863          	bltu	s9,s5,10b1c <ShellSort+0x2bc>
   10af0:	0167f6b3          	and	a3,a5,s6
   10af4:	0207c063          	bltz	a5,10b14 <ShellSort+0x2b4>
   10af8:	000a9e63          	bnez	s5,10b14 <ShellSort+0x2b4>
   10afc:	02069063          	bnez	a3,10b1c <ShellSort+0x2bc>
   10b00:	00894a63          	blt	s2,s0,10b14 <ShellSort+0x2b4>
   10b04:	0107d693          	srl	a3,a5,0x10
   10b08:	07f6f693          	and	a3,a3,127
   10b0c:	409d0d33          	sub	s10,s10,s1
   10b10:	f80694e3          	bnez	a3,10a98 <ShellSort+0x238>
   10b14:	00070913          	mv	s2,a4
   10b18:	ef1ff06f          	j	10a08 <ShellSort+0x1a8>
   10b1c:	fe894ce3          	blt	s2,s0,10b14 <ShellSort+0x2b4>
   10b20:	409d0d33          	sub	s10,s10,s1
   10b24:	f75ff06f          	j	10a98 <ShellSort+0x238>
   10b28:	000c8793          	mv	a5,s9
   10b2c:	fc1ff06f          	j	10aec <ShellSort+0x28c>
   10b30:	000c8793          	mv	a5,s9
   10b34:	019a7cb3          	and	s9,s4,s9
   10b38:	fb5ff06f          	j	10aec <ShellSort+0x28c>
   10b3c:	06c12083          	lw	ra,108(sp)
   10b40:	06812403          	lw	s0,104(sp)
   10b44:	06412483          	lw	s1,100(sp)
   10b48:	06012903          	lw	s2,96(sp)
   10b4c:	05c12983          	lw	s3,92(sp)
   10b50:	05812a03          	lw	s4,88(sp)
   10b54:	05412a83          	lw	s5,84(sp)
   10b58:	05012b03          	lw	s6,80(sp)
   10b5c:	04c12b83          	lw	s7,76(sp)
   10b60:	04812c03          	lw	s8,72(sp)
   10b64:	04412c83          	lw	s9,68(sp)
   10b68:	04012d03          	lw	s10,64(sp)
   10b6c:	03c12d83          	lw	s11,60(sp)
   10b70:	07010113          	add	sp,sp,112
   10b74:	00008067          	ret
   10b78:	001d0793          	add	a5,s10,1
   10b7c:	00f12823          	sw	a5,16(sp)
   10b80:	01c12783          	lw	a5,28(sp)
   10b84:	00478793          	add	a5,a5,4 # ff800004 <__BSS_END__+0xff7e1280>
   10b88:	00f12e23          	sw	a5,28(sp)
   10b8c:	01412783          	lw	a5,20(sp)
   10b90:	00478793          	add	a5,a5,4
   10b94:	00f12a23          	sw	a5,20(sp)
   10b98:	d49ff06f          	j	108e0 <ShellSort+0x80>
```
:::

### **-Os Type**
#### **objdump**
![](https://hackmd.io/_uploads/Bk-LrHCMT.png)
#### **size**
![](https://hackmd.io/_uploads/ByYcHrCG6.png)


:::spoiler **main**
``` c=20
000100b0 <main>:
   100b0:	fd010113          	add	sp,sp,-48
   100b4:	02112623          	sw	ra,44(sp)
   100b8:	02812423          	sw	s0,40(sp)
   100bc:	02912223          	sw	s1,36(sp)
   100c0:	138000ef          	jal	101f8 <get_instret>
   100c4:	00050413          	mv	s0,a0
   100c8:	11c000ef          	jal	101e4 <get_cycles>
   100cc:	0001d7b7          	lui	a5,0x1d
   100d0:	de078793          	add	a5,a5,-544 # 1cde0 <__trunctfdf2+0x5aa>
   100d4:	0007a803          	lw	a6,0(a5)
   100d8:	0087a603          	lw	a2,8(a5)
   100dc:	00c7a683          	lw	a3,12(a5)
   100e0:	0107a703          	lw	a4,16(a5)
   100e4:	0047a583          	lw	a1,4(a5)
   100e8:	0147a783          	lw	a5,20(a5)
   100ec:	00050493          	mv	s1,a0
   100f0:	00810513          	add	a0,sp,8
   100f4:	01012423          	sw	a6,8(sp)
   100f8:	00c12823          	sw	a2,16(sp)
   100fc:	00d12a23          	sw	a3,20(sp)
   10100:	00e12c23          	sw	a4,24(sp)
   10104:	00f12e23          	sw	a5,28(sp)
   10108:	00b12623          	sw	a1,12(sp)
   1010c:	754000ef          	jal	10860 <ShellSort>
   10110:	0d4000ef          	jal	101e4 <get_cycles>
   10114:	409505b3          	sub	a1,a0,s1
   10118:	0001d537          	lui	a0,0x1d
   1011c:	ae050513          	add	a0,a0,-1312 # 1cae0 <__trunctfdf2+0x2aa>
   10120:	57e010ef          	jal	1169e <printf>
   10124:	0001d537          	lui	a0,0x1d
   10128:	00040593          	mv	a1,s0
   1012c:	af450513          	add	a0,a0,-1292 # 1caf4 <__trunctfdf2+0x2be>
   10130:	56e010ef          	jal	1169e <printf>
   10134:	02c12083          	lw	ra,44(sp)
   10138:	02812403          	lw	s0,40(sp)
   1013c:	02412483          	lw	s1,36(sp)
   10140:	00000513          	li	a0,0
   10144:	03010113          	add	sp,sp,48
   10148:	00008067          	ret
```
:::

:::spoiler **BOS**
``` c=466
0001072c <BOS>:
   1072c:	fe010113          	add	sp,sp,-32
   10730:	00812c23          	sw	s0,24(sp)
   10734:	00912a23          	sw	s1,20(sp)
   10738:	01212823          	sw	s2,16(sp)
   1073c:	00112e23          	sw	ra,28(sp)
   10740:	01312623          	sw	s3,12(sp)
   10744:	00151793          	sll	a5,a0,0x1
   10748:	00050493          	mv	s1,a0
   1074c:	00058413          	mv	s0,a1
   10750:	00050913          	mv	s2,a0
   10754:	02078c63          	beqz	a5,1078c <BOS+0x60>
   10758:	7f8007b7          	lui	a5,0x7f800
   1075c:	00a7f733          	and	a4,a5,a0
   10760:	800009b7          	lui	s3,0x80000
   10764:	0ef70463          	beq	a4,a5,1084c <BOS+0x120>
   10768:	f601a583          	lw	a1,-160(gp) # 1e770 <__SDATA_BEGIN__+0x68>
   1076c:	ff800537          	lui	a0,0xff800
   10770:	00957533          	and	a0,a0,s1
   10774:	00d000ef          	jal	10f80 <__mulsf3>
   10778:	00048593          	mv	a1,s1
   1077c:	458000ef          	jal	10bd4 <__addsf3>
   10780:	ffff0937          	lui	s2,0xffff0
   10784:	00a97933          	and	s2,s2,a0
   10788:	00a9f4b3          	and	s1,s3,a0
   1078c:	00141713          	sll	a4,s0,0x1
   10790:	00040793          	mv	a5,s0
   10794:	800009b7          	lui	s3,0x80000
   10798:	00040693          	mv	a3,s0
   1079c:	02070c63          	beqz	a4,107d4 <BOS+0xa8>
   107a0:	7f800737          	lui	a4,0x7f800
   107a4:	008776b3          	and	a3,a4,s0
   107a8:	0ae68663          	beq	a3,a4,10854 <BOS+0x128>
   107ac:	f601a583          	lw	a1,-160(gp) # 1e770 <__SDATA_BEGIN__+0x68>
   107b0:	ff800537          	lui	a0,0xff800
   107b4:	00857533          	and	a0,a0,s0
   107b8:	7c8000ef          	jal	10f80 <__mulsf3>
   107bc:	00040593          	mv	a1,s0
   107c0:	414000ef          	jal	10bd4 <__addsf3>
   107c4:	ffff07b7          	lui	a5,0xffff0
   107c8:	00a7f7b3          	and	a5,a5,a0
   107cc:	00078693          	mv	a3,a5
   107d0:	00a9f433          	and	s0,s3,a0
   107d4:	00100513          	li	a0,1
   107d8:	0284ee63          	bltu	s1,s0,10814 <BOS+0xe8>
   107dc:	7f800737          	lui	a4,0x7f800
   107e0:	007f0637          	lui	a2,0x7f0
   107e4:	00e975b3          	and	a1,s2,a4
   107e8:	00c97833          	and	a6,s2,a2
   107ec:	00e6f733          	and	a4,a3,a4
   107f0:	00000513          	li	a0,0
   107f4:	00c6f6b3          	and	a3,a3,a2
   107f8:	02094c63          	bltz	s2,10830 <BOS+0x104>
   107fc:	0007cc63          	bltz	a5,10814 <BOS+0xe8>
   10800:	00100513          	li	a0,1
   10804:	00b76863          	bltu	a4,a1,10814 <BOS+0xe8>
   10808:	00000513          	li	a0,0
   1080c:	00e59463          	bne	a1,a4,10814 <BOS+0xe8>
   10810:	0106b533          	sltu	a0,a3,a6
   10814:	01c12083          	lw	ra,28(sp)
   10818:	01812403          	lw	s0,24(sp)
   1081c:	01412483          	lw	s1,20(sp)
   10820:	01012903          	lw	s2,16(sp)
   10824:	00c12983          	lw	s3,12(sp)
   10828:	02010113          	add	sp,sp,32
   1082c:	00008067          	ret
   10830:	fe07d2e3          	bgez	a5,10814 <BOS+0xe8>
   10834:	00100513          	li	a0,1
   10838:	fce5eee3          	bltu	a1,a4,10814 <BOS+0xe8>
   1083c:	00000513          	li	a0,0
   10840:	fce59ae3          	bne	a1,a4,10814 <BOS+0xe8>
   10844:	00d83533          	sltu	a0,a6,a3
   10848:	fcdff06f          	j	10814 <BOS+0xe8>
   1084c:	00a9f4b3          	and	s1,s3,a0
   10850:	f3dff06f          	j	1078c <BOS+0x60>
   10854:	00040693          	mv	a3,s0
   10858:	0089f433          	and	s0,s3,s0
   1085c:	f79ff06f          	j	107d4 <BOS+0xa8>
```
:::

:::spoiler **fp32_to_bf16**
``` c=438
000106a0 <fp32_to_bf16>:
   106a0:	ff010113          	add	sp,sp,-16
   106a4:	7f8007b7          	lui	a5,0x7f800
   106a8:	00812423          	sw	s0,8(sp)
   106ac:	00112623          	sw	ra,12(sp)
   106b0:	00a7f733          	and	a4,a5,a0
   106b4:	00050413          	mv	s0,a0
   106b8:	02071063          	bnez	a4,106d8 <fp32_to_bf16+0x38>
   106bc:	00951793          	sll	a5,a0,0x9
   106c0:	00079e63          	bnez	a5,106dc <fp32_to_bf16+0x3c>
   106c4:	00040513          	mv	a0,s0
   106c8:	00c12083          	lw	ra,12(sp)
   106cc:	00812403          	lw	s0,8(sp)
   106d0:	01010113          	add	sp,sp,16
   106d4:	00008067          	ret
   106d8:	fef706e3          	beq	a4,a5,106c4 <fp32_to_bf16+0x24>
   106dc:	f601a583          	lw	a1,-160(gp) # 1e770 <__SDATA_BEGIN__+0x68>
   106e0:	ff800537          	lui	a0,0xff800
   106e4:	00857533          	and	a0,a0,s0
   106e8:	570000ef          	jal	10c58 <__mulsf3>
   106ec:	00040593          	mv	a1,s0
   106f0:	1bc000ef          	jal	108ac <__addsf3>
   106f4:	ffff0437          	lui	s0,0xffff0
   106f8:	00a47533          	and	a0,s0,a0
   106fc:	fcdff06f          	j	106c8 <fp32_to_bf16+0x28>
```
:::

:::spoiler **ShellSort**
``` c=545
00010860 <ShellSort>:
   10860:	f601a783          	lw	a5,-160(gp) # 1e770 <__SDATA_BEGIN__+0x68>
   10864:	f9010113          	add	sp,sp,-112
   10868:	05312e23          	sw	s3,92(sp)
   1086c:	05812423          	sw	s8,72(sp)
   10870:	05912223          	sw	s9,68(sp)
   10874:	80000c37          	lui	s8,0x80000
   10878:	00200993          	li	s3,2
   1087c:	00300c93          	li	s9,3
   10880:	06912223          	sw	s1,100(sp)
   10884:	05712623          	sw	s7,76(sp)
   10888:	05a12023          	sw	s10,64(sp)
   1088c:	03b12e23          	sw	s11,60(sp)
   10890:	06112623          	sw	ra,108(sp)
   10894:	06812423          	sw	s0,104(sp)
   10898:	07212023          	sw	s2,96(sp)
   1089c:	05412c23          	sw	s4,88(sp)
   108a0:	05512a23          	sw	s5,84(sp)
   108a4:	05612823          	sw	s6,80(sp)
   108a8:	00f12623          	sw	a5,12(sp)
   108ac:	fffc0493          	add	s1,s8,-1 # 7fffffff <__BSS_END__+0x7ffe127b>
   108b0:	7f800bb7          	lui	s7,0x7f800
   108b4:	007f0db7          	lui	s11,0x7f0
   108b8:	000c8d13          	mv	s10,s9
   108bc:	03312423          	sw	s3,40(sp)
   108c0:	02a12623          	sw	a0,44(sp)
   108c4:	02c12783          	lw	a5,44(sp)
   108c8:	002d1a93          	sll	s5,s10,0x2
   108cc:	41500933          	neg	s2,s5
   108d0:	01578733          	add	a4,a5,s5
   108d4:	00e12c23          	sw	a4,24(sp)
   108d8:	00f12823          	sw	a5,16(sp)
   108dc:	000d0413          	mv	s0,s10
   108e0:	000a8c93          	mv	s9,s5
   108e4:	01812983          	lw	s3,24(sp)
   108e8:	01012a03          	lw	s4,16(sp)
   108ec:	0009a783          	lw	a5,0(s3) # 80000000 <__BSS_END__+0x7ffe127c>
   108f0:	000a2503          	lw	a0,0(s4)
   108f4:	00078593          	mv	a1,a5
   108f8:	00078a93          	mv	s5,a5
   108fc:	00f12e23          	sw	a5,28(sp)
   10900:	e2dff0ef          	jal	1072c <BOS>
   10904:	2a8d4a63          	blt	s10,s0,10bb8 <ShellSort+0x358>
   10908:	12050463          	beqz	a0,10a30 <ShellSort+0x1d0>
   1090c:	0154f7b3          	and	a5,s1,s5
   10910:	000a8713          	mv	a4,s5
   10914:	000a8993          	mv	s3,s5
   10918:	000a8b13          	mv	s6,s5
   1091c:	1a078063          	beqz	a5,10abc <ShellSort+0x25c>
   10920:	00c12583          	lw	a1,12(sp)
   10924:	ff800737          	lui	a4,0xff800
   10928:	01577533          	and	a0,a4,s5
   1092c:	654000ef          	jal	10f80 <__mulsf3>
   10930:	00098593          	mv	a1,s3
   10934:	2a0000ef          	jal	10bd4 <__addsf3>
   10938:	ffff07b7          	lui	a5,0xffff0
   1093c:	00a7f8b3          	and	a7,a5,a0
   10940:	0189f7b3          	and	a5,s3,s8
   10944:	000a0713          	mv	a4,s4
   10948:	000d0813          	mv	a6,s10
   1094c:	015bfab3          	and	s5,s7,s5
   10950:	02f12023          	sw	a5,32(sp)
   10954:	00ac77b3          	and	a5,s8,a0
   10958:	000d0993          	mv	s3,s10
   1095c:	03612223          	sw	s6,36(sp)
   10960:	00090d13          	mv	s10,s2
   10964:	00f12a23          	sw	a5,20(sp)
   10968:	00040913          	mv	s2,s0
   1096c:	000a8693          	mv	a3,s5
   10970:	00088a13          	mv	s4,a7
   10974:	00080413          	mv	s0,a6
   10978:	00070b13          	mv	s6,a4
   1097c:	000b2583          	lw	a1,0(s6)
   10980:	019b0733          	add	a4,s6,s9
   10984:	01ab07b3          	add	a5,s6,s10
   10988:	00b72023          	sw	a1,0(a4) # ff800000 <__BSS_END__+0xff7e127c>
   1098c:	0007aa83          	lw	s5,0(a5) # ffff0000 <__BSS_END__+0xfffd127c>
   10990:	41240433          	sub	s0,s0,s2
   10994:	000b0893          	mv	a7,s6
   10998:	0154f7b3          	and	a5,s1,s5
   1099c:	0e078263          	beqz	a5,10a80 <ShellSort+0x220>
   109a0:	015bf7b3          	and	a5,s7,s5
   109a4:	11778663          	beq	a5,s7,10ab0 <ShellSort+0x250>
   109a8:	00c12583          	lw	a1,12(sp)
   109ac:	ff8007b7          	lui	a5,0xff800
   109b0:	0157f533          	and	a0,a5,s5
   109b4:	00d12223          	sw	a3,4(sp)
   109b8:	01612423          	sw	s6,8(sp)
   109bc:	5c4000ef          	jal	10f80 <__mulsf3>
   109c0:	000a8593          	mv	a1,s5
   109c4:	210000ef          	jal	10bd4 <__addsf3>
   109c8:	00412683          	lw	a3,4(sp)
   109cc:	ffff07b7          	lui	a5,0xffff0
   109d0:	00a7f7b3          	and	a5,a5,a0
   109d4:	000b0893          	mv	a7,s6
   109d8:	00ac7533          	and	a0,s8,a0
   109dc:	0b768863          	beq	a3,s7,10a8c <ShellSort+0x22c>
   109e0:	01412583          	lw	a1,20(sp)
   109e4:	000a0313          	mv	t1,s4
   109e8:	000a0713          	mv	a4,s4
   109ec:	08b56463          	bltu	a0,a1,10a74 <ShellSort+0x214>
   109f0:	017775b3          	and	a1,a4,s7
   109f4:	0177f533          	and	a0,a5,s7
   109f8:	01b7fe33          	and	t3,a5,s11
   109fc:	01b77733          	and	a4,a4,s11
   10a00:	0807ce63          	bltz	a5,10a9c <ShellSort+0x23c>
   10a04:	00034e63          	bltz	t1,10a20 <ShellSort+0x1c0>
   10a08:	06a5e663          	bltu	a1,a0,10a74 <ShellSort+0x214>
   10a0c:	00b51a63          	bne	a0,a1,10a20 <ShellSort+0x1c0>
   10a10:	01c73e33          	sltu	t3,a4,t3
   10a14:	01244663          	blt	s0,s2,10a20 <ShellSort+0x1c0>
   10a18:	419b0b33          	sub	s6,s6,s9
   10a1c:	f60e10e3          	bnez	t3,1097c <ShellSort+0x11c>
   10a20:	00090413          	mv	s0,s2
   10a24:	000d0913          	mv	s2,s10
   10a28:	00098d13          	mv	s10,s3
   10a2c:	00088993          	mv	s3,a7
   10a30:	01c12783          	lw	a5,28(sp)
   10a34:	001d0d13          	add	s10,s10,1
   10a38:	00f9a023          	sw	a5,0(s3)
   10a3c:	01812783          	lw	a5,24(sp)
   10a40:	00478793          	add	a5,a5,4 # ffff0004 <__BSS_END__+0xfffd1280>
   10a44:	00f12c23          	sw	a5,24(sp)
   10a48:	01012783          	lw	a5,16(sp)
   10a4c:	00478793          	add	a5,a5,4
   10a50:	00f12823          	sw	a5,16(sp)
   10a54:	00600793          	li	a5,6
   10a58:	e8fd16e3          	bne	s10,a5,108e4 <ShellSort+0x84>
   10a5c:	02812783          	lw	a5,40(sp)
   10a60:	00100d13          	li	s10,1
   10a64:	11a78c63          	beq	a5,s10,10b7c <ShellSort+0x31c>
   10a68:	00100793          	li	a5,1
   10a6c:	02f12423          	sw	a5,40(sp)
   10a70:	e55ff06f          	j	108c4 <ShellSort+0x64>
   10a74:	fb2446e3          	blt	s0,s2,10a20 <ShellSort+0x1c0>
   10a78:	419b0b33          	sub	s6,s6,s9
   10a7c:	f01ff06f          	j	1097c <ShellSort+0x11c>
   10a80:	000a8793          	mv	a5,s5
   10a84:	000a8513          	mv	a0,s5
   10a88:	f5769ce3          	bne	a3,s7,109e0 <ShellSort+0x180>
   10a8c:	02412303          	lw	t1,36(sp)
   10a90:	02012583          	lw	a1,32(sp)
   10a94:	00030713          	mv	a4,t1
   10a98:	f55ff06f          	j	109ec <ShellSort+0x18c>
   10a9c:	f80352e3          	bgez	t1,10a20 <ShellSort+0x1c0>
   10aa0:	fcb56ae3          	bltu	a0,a1,10a74 <ShellSort+0x214>
   10aa4:	f6b51ee3          	bne	a0,a1,10a20 <ShellSort+0x1c0>
   10aa8:	00ee3e33          	sltu	t3,t3,a4
   10aac:	f69ff06f          	j	10a14 <ShellSort+0x1b4>
   10ab0:	000a8793          	mv	a5,s5
   10ab4:	015c7533          	and	a0,s8,s5
   10ab8:	f25ff06f          	j	109dc <ShellSort+0x17c>
   10abc:	000a0a93          	mv	s5,s4
   10ac0:	01a12223          	sw	s10,4(sp)
   10ac4:	00090a13          	mv	s4,s2
   10ac8:	000d0b13          	mv	s6,s10
   10acc:	00070913          	mv	s2,a4
   10ad0:	000aa683          	lw	a3,0(s5)
   10ad4:	019a8733          	add	a4,s5,s9
   10ad8:	014a87b3          	add	a5,s5,s4
   10adc:	00d72023          	sw	a3,0(a4)
   10ae0:	0007a983          	lw	s3,0(a5)
   10ae4:	408b0b33          	sub	s6,s6,s0
   10ae8:	000a8d13          	mv	s10,s5
   10aec:	0134f7b3          	and	a5,s1,s3
   10af0:	06078a63          	beqz	a5,10b64 <ShellSort+0x304>
   10af4:	013bf7b3          	and	a5,s7,s3
   10af8:	07778c63          	beq	a5,s7,10b70 <ShellSort+0x310>
   10afc:	00c12583          	lw	a1,12(sp)
   10b00:	ff8007b7          	lui	a5,0xff800
   10b04:	0137f533          	and	a0,a5,s3
   10b08:	478000ef          	jal	10f80 <__mulsf3>
   10b0c:	00098593          	mv	a1,s3
   10b10:	0c4000ef          	jal	10bd4 <__addsf3>
   10b14:	ffff07b7          	lui	a5,0xffff0
   10b18:	00a7f7b3          	and	a5,a5,a0
   10b1c:	00ac7533          	and	a0,s8,a0
   10b20:	03256c63          	bltu	a0,s2,10b58 <ShellSort+0x2f8>
   10b24:	0177f6b3          	and	a3,a5,s7
   10b28:	0207c063          	bltz	a5,10b48 <ShellSort+0x2e8>
   10b2c:	00091e63          	bnez	s2,10b48 <ShellSort+0x2e8>
   10b30:	02069463          	bnez	a3,10b58 <ShellSort+0x2f8>
   10b34:	008b4a63          	blt	s6,s0,10b48 <ShellSort+0x2e8>
   10b38:	0107d693          	srl	a3,a5,0x10
   10b3c:	07f6f693          	and	a3,a3,127
   10b40:	419a8ab3          	sub	s5,s5,s9
   10b44:	f80696e3          	bnez	a3,10ad0 <ShellSort+0x270>
   10b48:	000d0993          	mv	s3,s10
   10b4c:	000a0913          	mv	s2,s4
   10b50:	00412d03          	lw	s10,4(sp)
   10b54:	eddff06f          	j	10a30 <ShellSort+0x1d0>
   10b58:	fe8b48e3          	blt	s6,s0,10b48 <ShellSort+0x2e8>
   10b5c:	419a8ab3          	sub	s5,s5,s9
   10b60:	f71ff06f          	j	10ad0 <ShellSort+0x270>
   10b64:	00098793          	mv	a5,s3
   10b68:	00098513          	mv	a0,s3
   10b6c:	fb5ff06f          	j	10b20 <ShellSort+0x2c0>
   10b70:	00098793          	mv	a5,s3
   10b74:	013c7533          	and	a0,s8,s3
   10b78:	fa9ff06f          	j	10b20 <ShellSort+0x2c0>
   10b7c:	06c12083          	lw	ra,108(sp)
   10b80:	06812403          	lw	s0,104(sp)
   10b84:	06412483          	lw	s1,100(sp)
   10b88:	06012903          	lw	s2,96(sp)
   10b8c:	05c12983          	lw	s3,92(sp)
   10b90:	05812a03          	lw	s4,88(sp)
   10b94:	05412a83          	lw	s5,84(sp)
   10b98:	05012b03          	lw	s6,80(sp)
   10b9c:	04c12b83          	lw	s7,76(sp)
   10ba0:	04812c03          	lw	s8,72(sp)
   10ba4:	04412c83          	lw	s9,68(sp)
   10ba8:	04012d03          	lw	s10,64(sp)
   10bac:	03c12d83          	lw	s11,60(sp)
   10bb0:	07010113          	add	sp,sp,112
   10bb4:	00008067          	ret
   10bb8:	00498793          	add	a5,s3,4
   10bbc:	00f12c23          	sw	a5,24(sp)
   10bc0:	01012783          	lw	a5,16(sp)
   10bc4:	001d0d13          	add	s10,s10,1
   10bc8:	00478793          	add	a5,a5,4 # ffff0004 <__BSS_END__+0xfffd1280>
   10bcc:	00f12823          	sw	a5,16(sp)
   10bd0:	d15ff06f          	j	108e4 <ShellSort+0x84>
```
:::
	
### **-Ofast Type**	
#### **objdump**
![](https://hackmd.io/_uploads/SyxlfRSCfp.png)
#### **size**
![](https://hackmd.io/_uploads/Bk5QRrCMT.png)
	
:::spoiler **main**
``` c=20
000100b0 <main>:
   100b0:	fd010113          	add	sp,sp,-48
   100b4:	02112623          	sw	ra,44(sp)
   100b8:	02812423          	sw	s0,40(sp)
   100bc:	02912223          	sw	s1,36(sp)
   100c0:	138000ef          	jal	101f8 <get_instret>
   100c4:	00050413          	mv	s0,a0
   100c8:	11c000ef          	jal	101e4 <get_cycles>
   100cc:	0001d7b7          	lui	a5,0x1d
   100d0:	de078793          	add	a5,a5,-544 # 1cde0 <__trunctfdf2+0x5aa>
   100d4:	0007a803          	lw	a6,0(a5)
   100d8:	0087a603          	lw	a2,8(a5)
   100dc:	00c7a683          	lw	a3,12(a5)
   100e0:	0107a703          	lw	a4,16(a5)
   100e4:	0047a583          	lw	a1,4(a5)
   100e8:	0147a783          	lw	a5,20(a5)
   100ec:	00050493          	mv	s1,a0
   100f0:	00810513          	add	a0,sp,8
   100f4:	01012423          	sw	a6,8(sp)
   100f8:	00c12823          	sw	a2,16(sp)
   100fc:	00d12a23          	sw	a3,20(sp)
   10100:	00e12c23          	sw	a4,24(sp)
   10104:	00f12e23          	sw	a5,28(sp)
   10108:	00b12623          	sw	a1,12(sp)
   1010c:	754000ef          	jal	10860 <ShellSort>
   10110:	0d4000ef          	jal	101e4 <get_cycles>
   10114:	409505b3          	sub	a1,a0,s1
   10118:	0001d537          	lui	a0,0x1d
   1011c:	ae050513          	add	a0,a0,-1312 # 1cae0 <__trunctfdf2+0x2aa>
   10120:	57e010ef          	jal	1169e <printf>
   10124:	0001d537          	lui	a0,0x1d
   10128:	00040593          	mv	a1,s0
   1012c:	af450513          	add	a0,a0,-1292 # 1caf4 <__trunctfdf2+0x2be>
   10130:	56e010ef          	jal	1169e <printf>
   10134:	02c12083          	lw	ra,44(sp)
   10138:	02812403          	lw	s0,40(sp)
   1013c:	02412483          	lw	s1,36(sp)
   10140:	00000513          	li	a0,0
   10144:	03010113          	add	sp,sp,48
   10148:	00008067          	ret
```
:::

:::spoiler **BOS**
``` c= 466
0001072c <BOS>:
   1072c:	fe010113          	add	sp,sp,-32
   10730:	00812c23          	sw	s0,24(sp)
   10734:	00912a23          	sw	s1,20(sp)
   10738:	01212823          	sw	s2,16(sp)
   1073c:	00112e23          	sw	ra,28(sp)
   10740:	01312623          	sw	s3,12(sp)
   10744:	00151793          	sll	a5,a0,0x1
   10748:	00050493          	mv	s1,a0
   1074c:	00058413          	mv	s0,a1
   10750:	00050913          	mv	s2,a0
   10754:	02078c63          	beqz	a5,1078c <BOS+0x60>
   10758:	7f8007b7          	lui	a5,0x7f800
   1075c:	00a7f733          	and	a4,a5,a0
   10760:	800009b7          	lui	s3,0x80000
   10764:	0ef70463          	beq	a4,a5,1084c <BOS+0x120>
   10768:	f601a583          	lw	a1,-160(gp) # 1e770 <__SDATA_BEGIN__+0x68>
   1076c:	ff800537          	lui	a0,0xff800
   10770:	00957533          	and	a0,a0,s1
   10774:	00d000ef          	jal	10f80 <__mulsf3>
   10778:	00048593          	mv	a1,s1
   1077c:	458000ef          	jal	10bd4 <__addsf3>
   10780:	ffff0937          	lui	s2,0xffff0
   10784:	00a97933          	and	s2,s2,a0
   10788:	00a9f4b3          	and	s1,s3,a0
   1078c:	00141713          	sll	a4,s0,0x1
   10790:	00040793          	mv	a5,s0
   10794:	800009b7          	lui	s3,0x80000
   10798:	00040693          	mv	a3,s0
   1079c:	02070c63          	beqz	a4,107d4 <BOS+0xa8>
   107a0:	7f800737          	lui	a4,0x7f800
   107a4:	008776b3          	and	a3,a4,s0
   107a8:	0ae68663          	beq	a3,a4,10854 <BOS+0x128>
   107ac:	f601a583          	lw	a1,-160(gp) # 1e770 <__SDATA_BEGIN__+0x68>
   107b0:	ff800537          	lui	a0,0xff800
   107b4:	00857533          	and	a0,a0,s0
   107b8:	7c8000ef          	jal	10f80 <__mulsf3>
   107bc:	00040593          	mv	a1,s0
   107c0:	414000ef          	jal	10bd4 <__addsf3>
   107c4:	ffff07b7          	lui	a5,0xffff0
   107c8:	00a7f7b3          	and	a5,a5,a0
   107cc:	00078693          	mv	a3,a5
   107d0:	00a9f433          	and	s0,s3,a0
   107d4:	00100513          	li	a0,1
   107d8:	0284ee63          	bltu	s1,s0,10814 <BOS+0xe8>
   107dc:	7f800737          	lui	a4,0x7f800
   107e0:	007f0637          	lui	a2,0x7f0
   107e4:	00e975b3          	and	a1,s2,a4
   107e8:	00c97833          	and	a6,s2,a2
   107ec:	00e6f733          	and	a4,a3,a4
   107f0:	00000513          	li	a0,0
   107f4:	00c6f6b3          	and	a3,a3,a2
   107f8:	02094c63          	bltz	s2,10830 <BOS+0x104>
   107fc:	0007cc63          	bltz	a5,10814 <BOS+0xe8>
   10800:	00100513          	li	a0,1
   10804:	00b76863          	bltu	a4,a1,10814 <BOS+0xe8>
   10808:	00000513          	li	a0,0
   1080c:	00e59463          	bne	a1,a4,10814 <BOS+0xe8>
   10810:	0106b533          	sltu	a0,a3,a6
   10814:	01c12083          	lw	ra,28(sp)
   10818:	01812403          	lw	s0,24(sp)
   1081c:	01412483          	lw	s1,20(sp)
   10820:	01012903          	lw	s2,16(sp)
   10824:	00c12983          	lw	s3,12(sp)
   10828:	02010113          	add	sp,sp,32
   1082c:	00008067          	ret
   10830:	fe07d2e3          	bgez	a5,10814 <BOS+0xe8>
   10834:	00100513          	li	a0,1
   10838:	fce5eee3          	bltu	a1,a4,10814 <BOS+0xe8>
   1083c:	00000513          	li	a0,0
   10840:	fce59ae3          	bne	a1,a4,10814 <BOS+0xe8>
   10844:	00d83533          	sltu	a0,a6,a3
   10848:	fcdff06f          	j	10814 <BOS+0xe8>
   1084c:	00a9f4b3          	and	s1,s3,a0
   10850:	f3dff06f          	j	1078c <BOS+0x60>
   10854:	00040693          	mv	a3,s0
   10858:	0089f433          	and	s0,s3,s0
   1085c:	f79ff06f          	j	107d4 <BOS+0xa8>
```
:::

:::spoiler **fp32_to_bf16**
``` c=438
000106c4 <fp32_to_bf16>:
   106c4:	ff010113          	add	sp,sp,-16
   106c8:	00812423          	sw	s0,8(sp)
   106cc:	00112623          	sw	ra,12(sp)
   106d0:	00151793          	sll	a5,a0,0x1
   106d4:	00050413          	mv	s0,a0
   106d8:	04078063          	beqz	a5,10718 <fp32_to_bf16+0x54>
   106dc:	7f8007b7          	lui	a5,0x7f800
   106e0:	00a7f733          	and	a4,a5,a0
   106e4:	02f70a63          	beq	a4,a5,10718 <fp32_to_bf16+0x54>
   106e8:	f601a583          	lw	a1,-160(gp) # 1e770 <__SDATA_BEGIN__+0x68>
   106ec:	ff800537          	lui	a0,0xff800
   106f0:	00857533          	and	a0,a0,s0
   106f4:	08d000ef          	jal	10f80 <__mulsf3>
   106f8:	00040593          	mv	a1,s0
   106fc:	4d8000ef          	jal	10bd4 <__addsf3>
   10700:	ffff0437          	lui	s0,0xffff0
   10704:	00c12083          	lw	ra,12(sp)
   10708:	00a47533          	and	a0,s0,a0
   1070c:	00812403          	lw	s0,8(sp)
   10710:	01010113          	add	sp,sp,16
   10714:	00008067          	ret
   10718:	00c12083          	lw	ra,12(sp)
   1071c:	00040513          	mv	a0,s0
   10720:	00812403          	lw	s0,8(sp)
   10724:	01010113          	add	sp,sp,16
   10728:	00008067          	ret
```
:::

:::spoiler **ShellSort**
``` c=545
00010860 <ShellSort>:
   10860:	f601a783          	lw	a5,-160(gp) # 1e770 <__SDATA_BEGIN__+0x68>
   10864:	f9010113          	add	sp,sp,-112
   10868:	05312e23          	sw	s3,92(sp)
   1086c:	05812423          	sw	s8,72(sp)
   10870:	05912223          	sw	s9,68(sp)
   10874:	80000c37          	lui	s8,0x80000
   10878:	00200993          	li	s3,2
   1087c:	00300c93          	li	s9,3
   10880:	06912223          	sw	s1,100(sp)
   10884:	05712623          	sw	s7,76(sp)
   10888:	05a12023          	sw	s10,64(sp)
   1088c:	03b12e23          	sw	s11,60(sp)
   10890:	06112623          	sw	ra,108(sp)
   10894:	06812423          	sw	s0,104(sp)
   10898:	07212023          	sw	s2,96(sp)
   1089c:	05412c23          	sw	s4,88(sp)
   108a0:	05512a23          	sw	s5,84(sp)
   108a4:	05612823          	sw	s6,80(sp)
   108a8:	00f12623          	sw	a5,12(sp)
   108ac:	fffc0493          	add	s1,s8,-1 # 7fffffff <__BSS_END__+0x7ffe127b>
   108b0:	7f800bb7          	lui	s7,0x7f800
   108b4:	007f0db7          	lui	s11,0x7f0
   108b8:	000c8d13          	mv	s10,s9
   108bc:	03312423          	sw	s3,40(sp)
   108c0:	02a12623          	sw	a0,44(sp)
   108c4:	02c12783          	lw	a5,44(sp)
   108c8:	002d1a93          	sll	s5,s10,0x2
   108cc:	41500933          	neg	s2,s5
   108d0:	01578733          	add	a4,a5,s5
   108d4:	00e12c23          	sw	a4,24(sp)
   108d8:	00f12823          	sw	a5,16(sp)
   108dc:	000d0413          	mv	s0,s10
   108e0:	000a8c93          	mv	s9,s5
   108e4:	01812983          	lw	s3,24(sp)
   108e8:	01012a03          	lw	s4,16(sp)
   108ec:	0009a783          	lw	a5,0(s3) # 80000000 <__BSS_END__+0x7ffe127c>
   108f0:	000a2503          	lw	a0,0(s4)
   108f4:	00078593          	mv	a1,a5
   108f8:	00078a93          	mv	s5,a5
   108fc:	00f12e23          	sw	a5,28(sp)
   10900:	e2dff0ef          	jal	1072c <BOS>
   10904:	2a8d4a63          	blt	s10,s0,10bb8 <ShellSort+0x358>
   10908:	12050463          	beqz	a0,10a30 <ShellSort+0x1d0>
   1090c:	0154f7b3          	and	a5,s1,s5
   10910:	000a8713          	mv	a4,s5
   10914:	000a8993          	mv	s3,s5
   10918:	000a8b13          	mv	s6,s5
   1091c:	1a078063          	beqz	a5,10abc <ShellSort+0x25c>
   10920:	00c12583          	lw	a1,12(sp)
   10924:	ff800737          	lui	a4,0xff800
   10928:	01577533          	and	a0,a4,s5
   1092c:	654000ef          	jal	10f80 <__mulsf3>
   10930:	00098593          	mv	a1,s3
   10934:	2a0000ef          	jal	10bd4 <__addsf3>
   10938:	ffff07b7          	lui	a5,0xffff0
   1093c:	00a7f8b3          	and	a7,a5,a0
   10940:	0189f7b3          	and	a5,s3,s8
   10944:	000a0713          	mv	a4,s4
   10948:	000d0813          	mv	a6,s10
   1094c:	015bfab3          	and	s5,s7,s5
   10950:	02f12023          	sw	a5,32(sp)
   10954:	00ac77b3          	and	a5,s8,a0
   10958:	000d0993          	mv	s3,s10
   1095c:	03612223          	sw	s6,36(sp)
   10960:	00090d13          	mv	s10,s2
   10964:	00f12a23          	sw	a5,20(sp)
   10968:	00040913          	mv	s2,s0
   1096c:	000a8693          	mv	a3,s5
   10970:	00088a13          	mv	s4,a7
   10974:	00080413          	mv	s0,a6
   10978:	00070b13          	mv	s6,a4
   1097c:	000b2583          	lw	a1,0(s6)
   10980:	019b0733          	add	a4,s6,s9
   10984:	01ab07b3          	add	a5,s6,s10
   10988:	00b72023          	sw	a1,0(a4) # ff800000 <__BSS_END__+0xff7e127c>
   1098c:	0007aa83          	lw	s5,0(a5) # ffff0000 <__BSS_END__+0xfffd127c>
   10990:	41240433          	sub	s0,s0,s2
   10994:	000b0893          	mv	a7,s6
   10998:	0154f7b3          	and	a5,s1,s5
   1099c:	0e078263          	beqz	a5,10a80 <ShellSort+0x220>
   109a0:	015bf7b3          	and	a5,s7,s5
   109a4:	11778663          	beq	a5,s7,10ab0 <ShellSort+0x250>
   109a8:	00c12583          	lw	a1,12(sp)
   109ac:	ff8007b7          	lui	a5,0xff800
   109b0:	0157f533          	and	a0,a5,s5
   109b4:	00d12223          	sw	a3,4(sp)
   109b8:	01612423          	sw	s6,8(sp)
   109bc:	5c4000ef          	jal	10f80 <__mulsf3>
   109c0:	000a8593          	mv	a1,s5
   109c4:	210000ef          	jal	10bd4 <__addsf3>
   109c8:	00412683          	lw	a3,4(sp)
   109cc:	ffff07b7          	lui	a5,0xffff0
   109d0:	00a7f7b3          	and	a5,a5,a0
   109d4:	000b0893          	mv	a7,s6
   109d8:	00ac7533          	and	a0,s8,a0
   109dc:	0b768863          	beq	a3,s7,10a8c <ShellSort+0x22c>
   109e0:	01412583          	lw	a1,20(sp)
   109e4:	000a0313          	mv	t1,s4
   109e8:	000a0713          	mv	a4,s4
   109ec:	08b56463          	bltu	a0,a1,10a74 <ShellSort+0x214>
   109f0:	017775b3          	and	a1,a4,s7
   109f4:	0177f533          	and	a0,a5,s7
   109f8:	01b7fe33          	and	t3,a5,s11
   109fc:	01b77733          	and	a4,a4,s11
   10a00:	0807ce63          	bltz	a5,10a9c <ShellSort+0x23c>
   10a04:	00034e63          	bltz	t1,10a20 <ShellSort+0x1c0>
   10a08:	06a5e663          	bltu	a1,a0,10a74 <ShellSort+0x214>
   10a0c:	00b51a63          	bne	a0,a1,10a20 <ShellSort+0x1c0>
   10a10:	01c73e33          	sltu	t3,a4,t3
   10a14:	01244663          	blt	s0,s2,10a20 <ShellSort+0x1c0>
   10a18:	419b0b33          	sub	s6,s6,s9
   10a1c:	f60e10e3          	bnez	t3,1097c <ShellSort+0x11c>
   10a20:	00090413          	mv	s0,s2
   10a24:	000d0913          	mv	s2,s10
   10a28:	00098d13          	mv	s10,s3
   10a2c:	00088993          	mv	s3,a7
   10a30:	01c12783          	lw	a5,28(sp)
   10a34:	001d0d13          	add	s10,s10,1
   10a38:	00f9a023          	sw	a5,0(s3)
   10a3c:	01812783          	lw	a5,24(sp)
   10a40:	00478793          	add	a5,a5,4 # ffff0004 <__BSS_END__+0xfffd1280>
   10a44:	00f12c23          	sw	a5,24(sp)
   10a48:	01012783          	lw	a5,16(sp)
   10a4c:	00478793          	add	a5,a5,4
   10a50:	00f12823          	sw	a5,16(sp)
   10a54:	00600793          	li	a5,6
   10a58:	e8fd16e3          	bne	s10,a5,108e4 <ShellSort+0x84>
   10a5c:	02812783          	lw	a5,40(sp)
   10a60:	00100d13          	li	s10,1
   10a64:	11a78c63          	beq	a5,s10,10b7c <ShellSort+0x31c>
   10a68:	00100793          	li	a5,1
   10a6c:	02f12423          	sw	a5,40(sp)
   10a70:	e55ff06f          	j	108c4 <ShellSort+0x64>
   10a74:	fb2446e3          	blt	s0,s2,10a20 <ShellSort+0x1c0>
   10a78:	419b0b33          	sub	s6,s6,s9
   10a7c:	f01ff06f          	j	1097c <ShellSort+0x11c>
   10a80:	000a8793          	mv	a5,s5
   10a84:	000a8513          	mv	a0,s5
   10a88:	f5769ce3          	bne	a3,s7,109e0 <ShellSort+0x180>
   10a8c:	02412303          	lw	t1,36(sp)
   10a90:	02012583          	lw	a1,32(sp)
   10a94:	00030713          	mv	a4,t1
   10a98:	f55ff06f          	j	109ec <ShellSort+0x18c>
   10a9c:	f80352e3          	bgez	t1,10a20 <ShellSort+0x1c0>
   10aa0:	fcb56ae3          	bltu	a0,a1,10a74 <ShellSort+0x214>
   10aa4:	f6b51ee3          	bne	a0,a1,10a20 <ShellSort+0x1c0>
   10aa8:	00ee3e33          	sltu	t3,t3,a4
   10aac:	f69ff06f          	j	10a14 <ShellSort+0x1b4>
   10ab0:	000a8793          	mv	a5,s5
   10ab4:	015c7533          	and	a0,s8,s5
   10ab8:	f25ff06f          	j	109dc <ShellSort+0x17c>
   10abc:	000a0a93          	mv	s5,s4
   10ac0:	01a12223          	sw	s10,4(sp)
   10ac4:	00090a13          	mv	s4,s2
   10ac8:	000d0b13          	mv	s6,s10
   10acc:	00070913          	mv	s2,a4
   10ad0:	000aa683          	lw	a3,0(s5)
   10ad4:	019a8733          	add	a4,s5,s9
   10ad8:	014a87b3          	add	a5,s5,s4
   10adc:	00d72023          	sw	a3,0(a4)
   10ae0:	0007a983          	lw	s3,0(a5)
   10ae4:	408b0b33          	sub	s6,s6,s0
   10ae8:	000a8d13          	mv	s10,s5
   10aec:	0134f7b3          	and	a5,s1,s3
   10af0:	06078a63          	beqz	a5,10b64 <ShellSort+0x304>
   10af4:	013bf7b3          	and	a5,s7,s3
   10af8:	07778c63          	beq	a5,s7,10b70 <ShellSort+0x310>
   10afc:	00c12583          	lw	a1,12(sp)
   10b00:	ff8007b7          	lui	a5,0xff800
   10b04:	0137f533          	and	a0,a5,s3
   10b08:	478000ef          	jal	10f80 <__mulsf3>
   10b0c:	00098593          	mv	a1,s3
   10b10:	0c4000ef          	jal	10bd4 <__addsf3>
   10b14:	ffff07b7          	lui	a5,0xffff0
   10b18:	00a7f7b3          	and	a5,a5,a0
   10b1c:	00ac7533          	and	a0,s8,a0
   10b20:	03256c63          	bltu	a0,s2,10b58 <ShellSort+0x2f8>
   10b24:	0177f6b3          	and	a3,a5,s7
   10b28:	0207c063          	bltz	a5,10b48 <ShellSort+0x2e8>
   10b2c:	00091e63          	bnez	s2,10b48 <ShellSort+0x2e8>
   10b30:	02069463          	bnez	a3,10b58 <ShellSort+0x2f8>
   10b34:	008b4a63          	blt	s6,s0,10b48 <ShellSort+0x2e8>
   10b38:	0107d693          	srl	a3,a5,0x10
   10b3c:	07f6f693          	and	a3,a3,127
   10b40:	419a8ab3          	sub	s5,s5,s9
   10b44:	f80696e3          	bnez	a3,10ad0 <ShellSort+0x270>
   10b48:	000d0993          	mv	s3,s10
   10b4c:	000a0913          	mv	s2,s4
   10b50:	00412d03          	lw	s10,4(sp)
   10b54:	eddff06f          	j	10a30 <ShellSort+0x1d0>
   10b58:	fe8b48e3          	blt	s6,s0,10b48 <ShellSort+0x2e8>
   10b5c:	419a8ab3          	sub	s5,s5,s9
   10b60:	f71ff06f          	j	10ad0 <ShellSort+0x270>
   10b64:	00098793          	mv	a5,s3
   10b68:	00098513          	mv	a0,s3
   10b6c:	fb5ff06f          	j	10b20 <ShellSort+0x2c0>
   10b70:	00098793          	mv	a5,s3
   10b74:	013c7533          	and	a0,s8,s3
   10b78:	fa9ff06f          	j	10b20 <ShellSort+0x2c0>
   10b7c:	06c12083          	lw	ra,108(sp)
   10b80:	06812403          	lw	s0,104(sp)
   10b84:	06412483          	lw	s1,100(sp)
   10b88:	06012903          	lw	s2,96(sp)
   10b8c:	05c12983          	lw	s3,92(sp)
   10b90:	05812a03          	lw	s4,88(sp)
   10b94:	05412a83          	lw	s5,84(sp)
   10b98:	05012b03          	lw	s6,80(sp)
   10b9c:	04c12b83          	lw	s7,76(sp)
   10ba0:	04812c03          	lw	s8,72(sp)
   10ba4:	04412c83          	lw	s9,68(sp)
   10ba8:	04012d03          	lw	s10,64(sp)
   10bac:	03c12d83          	lw	s11,60(sp)
   10bb0:	07010113          	add	sp,sp,112
   10bb4:	00008067          	ret
   10bb8:	00498793          	add	a5,s3,4
   10bbc:	00f12c23          	sw	a5,24(sp)
   10bc0:	01012783          	lw	a5,16(sp)
   10bc4:	001d0d13          	add	s10,s10,1
   10bc8:	00478793          	add	a5,a5,4 # ffff0004 <__BSS_END__+0xfffd1280>
   10bcc:	00f12823          	sw	a5,16(sp)
   10bd0:	d15ff06f          	j	108e4 <ShellSort+0x84>
```
:::
	

## 6. Analysis
**-O1** 
The objective is to minimize code size and optimize executable code runtime as much as possible using optimization algorithms, all while preserving compilation speed.
**-O2**
This optimization option will sacrifice some compilation speed. In addition to all the optimizations performed by ==-O1==, it will also employ almost all of the target-specific optimization algorithms supported to ==improve the runtime performance== of the target code.
**-O3**
In addition to implementing all the optimization options of ==-O2==, this option typically utilizes various vectorization algorithms to improve the parallel execution of the code, taking advantage of modern CPU features such as pipelines and caches.
This option will ==expand the size of the executable code==; however, it will naturally lead to a reduction in the execution time of the target code.
**-Os**
This optimization flag shares some similarities with -O3, but they have distinct objectives. -O3 prioritizes increasing the size of the target code to ==maximize runtime speed==. In contrast, this option, based on -O2, seeks to ==minimize the size of the target code== as much as possible, which is especially important for devices with limited storage capacity.


| Compare  | Result            |
| -------- | ----------------- |
| 1. cycle | O1>O2=Os>O3>Ofast |
| 2. size  | O1<O2=Os<O3<Ofast |
