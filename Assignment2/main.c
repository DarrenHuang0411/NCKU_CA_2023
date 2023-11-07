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
