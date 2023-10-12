.data

    ############################################## Test Filter ######################################################
    #test: .word  0x3d37ed42, 0x3dfa0dfe,0x3d37ed42,0x3dfa0dfe,0x3ea9fb61,0x3dfa0dfe,0x3d37ed42, 0x3dfa0dfe,0x3d37ed42 #orig 
    #test: .word  0x3dbde269, 0x3df3d641, 0x3dbde269,0x3df3d641,0x3e1c8eac,0x3df3d641,0x3dbde269, 0x3df3d641, 0x3dbde269
    test:  .word  0x3dd2b7fe, 0x3deb7d41, 0x3dd2b7fe, 0x3deb7d41, 0x3e039607, 0x3deb7d41, 0x3dd2b7fe, 0x3deb7d41 , 0x3dd2b7fe
    
    ##################################################################################################################
    data_img: .word 0x41f00000,0x42820000,0x430a0000, 0x42540000, 0x43660000, 0x43700000, 0x426c0000, 0x42ae0000, 0x41600000
    
    origin_img:  .string "Origin: \n"
    result_str:  .string "(Filter Para.__Image Pix.__ Answer): \n"
    changeline:     .string "\n"
.text

start:
    j    main

main:
    #alloc
    addi    sp, sp, -4
    sw      ra,0(sp)
    #system call
    la      a0, result_str
    li      a7, 4
    ecall
    #Gaussian Filter
    call    GF
    #system call
    li    a7, 10
    ecall   

GF:
    #alloc
    addi  sp, sp, -20
    sw    ra, 0(sp)
    sw    s0, 4(sp)
    sw    s1, 8(sp)
    sw    s2, 12(sp)
    sw    s3, 16(sp)
    addi  a1, a1, -8
    #addi  a3, a3, -4
    #address initial
    li    s0, 0                            #i  
    li    s1, 0                            #j  
    li    s2, 3
    li    s3, 0                            #result_12*i+j 

Loop_o:
    bge   s0, s2, Loop_o_d             # if s0 >= s2 then target
    li    s1, 0                        #  j=0     
Loop_i:
    bge   s1, s2, Loop_i_d  
    #addr.offset cal
    slli  t0, s0, 3
    slli  t1, s0, 2
    add   t2, t0, t1                   #t2 = 12*i
    slli  t3, s1, 2        
    add   s3, t2 ,t3                  #s10 = addr.= 12*i + 4*j
    #addr.offset cal
    la    a0, test   
    add   a0, a0, s3
    call  fp32_to_bf16
    sw    t5, 0(a1)
    mv    a0, t5
    li    a7, 2
    ecall  
    li    a0, 32
    li    a7, 11
    ecall 
    
    la    a0, data_img   
    add   a0, a0, s3
    call  fp32_to_bf16
    sw    t5, 4(a1)
    mv    a0, t5
    li    a7, 2
    ecall  
    li    a0, 32
    li    a7, 11
    ecall 
    
    call  fmul32

    mv    a0, a4
    li    a7, 2
    ecall  
    li    a0, 32
    li    a7, 11
    ecall 
    
    
    addi   s1, s1, 1
    j      Loop_i

Loop_i_d:
    la  a0, changeline 
    li  a7, 4 
    ecall
    addi    s0, s0, 1  
    j Loop_o  # jump to Loop_o
    
Loop_o_d:
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    lw      s3, 16(sp)
    addi    sp, sp, 20
    addi  a1, a1, 8 
    #addi  a3, a3,  4
    ret
    
fp32_to_bf16:
    #alloc
    addi  sp, sp, -24
    sw    ra, 0(sp)
    sw    s2, 4(sp)
    sw    s3, 8(sp)
    sw    s4, 12(sp)
    sw    s5, 16(sp)
    sw    s6, 20(sp)    
    
    lw    t6, 0(a0)
    li    t1, 0x7F800000
    and   s2, t6, t1    #exp
    li    t2, 0x007FFFFF
    and   s3, t6, t2    #man
    
    beq   a0, zero, return_x #zero
    beq   s2, t1,return_x    #inf or nan
    
    ###### Normalize
    mv    s4, t6  #r=s4
    li    t3, 0xFF800000
    and   t4, t3, t4  #t4 = *pr
    
    srli  s4, s4, 8
    li    t4, 0x8000
    
    add   s5, s4, t6 
    or    s6, s5, s2  #s6=y(32)
    
    li    t5, 0xFFFF0000  
    and   t5, t6, t5     #a0=y(16)

    lw    ra, 0(sp)
    lw    s2, 4(sp)
    lw    s3, 8(sp)
    lw    s4, 12(sp)
    lw    s5, 16(sp)
    lw    s6, 20(sp)   
    addi  sp, sp, 24
ret    

fmul32:

    addi    sp, sp, -48
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    sw      s3, 16(sp)
    sw      s4, 20(sp)
    sw      s5, 24(sp)
    sw      s6, 28(sp)
    sw      s7, 32(sp)
    sw      s8, 36(sp)
    sw      s9, 40(sp)
    sw      s10, 44(sp)
    
    lw    s2, 0(a1)  #s2 is filter bf16
    lw    s3, 4(a1)  #s3 is img bf16
    
    #srli  s2, s2, 16 
    #srli  s3, s3, 16
    #sign
    srli  s4, s2 , 31
    srli  s5, s3, 31    
    #man
    li    t1, 0x7FFFFF
    li    t2, 0x800000
    and   s6, t1, s2
    or    s6, t2, s6
    and   s7, t1, s3
    or    s7, t2, s7
    #exp
    srli  s8, s2, 23
    srli  s9, s3, 23
    andi  s8, s8, 0xFF 
    andi  s9, s9, 0xFF 
    #mr
    call  imul     
    li    t4, 24
    call  get_bit
    srl   t3, t3, t0 #t0 now is mshift
    mv    s6, t3
    #er
    mv    t4, s8     #t4 now is ertmp 
    add   t4, t4, s9
    addi  t4, t4, -127

    #check mshift
    bne   t0, zero, inc   
    mv    s8, t4
    mshift_done:           
        #Overflow  check
        #sr
        xor   s4, s4, s5
        #result sr
        slli  s4, s4, 31
        or    s10, s10, s4  #s10=result
        #result er
        andi  s8, s8, 0xFF
        slli  s8, s8, 23
        or    s10, s10, s8
        #result mr
        li    t1, 0x7FFFFF
        and   s6, s6, t1
        or    s10, s10, s6
        #slli  s10, s10, 16
        mv    a4, s10
  
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    lw      s3, 16(sp)
    lw      s4, 20(sp)
    lw      s5, 24(sp)
    lw      s6, 28(sp)
    lw      s7, 32(sp)
    lw      s8, 36(sp)
    lw      s9, 40(sp)
    lw      s10, 44(sp)
    addi    sp, sp, 48
    ret    

imul:
    addi    sp, sp, -4
    sw      ra, 0(sp)
     
    mv    t4, s6    #t4 = a
    mv    t5, s7    #t5 = b
    li    t6, 0     #t6 = r 
    
    loop_imul:
        beq   t5, zero, imul_done     
        andi  t0, t5, 1     #getbit
        beq   t0, zero, imul_ans0 
        add   t6, t6, t4
    imul_ans0:
        srli  t5, t5, 1
        srli  t6, t6, 1
    j     loop_imul
    imul_done:
        slli  t3, t6, 1    #imul_result back t3
    
    lw      ra, 0(sp)
    addi    sp, sp, 4
    ret    

get_bit:
    addi    sp, sp, -4
    sw      ra, 0(sp)

    srl   t6, t3, t4  #mr = mrtmp >> mshift;  
    andi  t0, t6, 1   #t0 use to getbit--> now is mshift
    
    lw      ra, 0(sp)
    addi    sp, sp, 4
    ret
    
inc:

    li   t2, 0xFF
    mv   a6, t4
    bne  a6, t2, inc_start 
    mv   a6, zero    
    j    mshift_done
    inc_start:
        call mask_zero
        slli t6, t6, 1   #t6 now is the sec. mask
        ori  t6, t6, 0x1
        xor  t6, a5, t6 #t6 now is z1
        #return value
        mv   t5, t4
        li   t2, 0xFFFFFFFF
        xor  a5, a5, t2  #a5=(~mask)
        and  t4, t4, a5           #t4= (x & ~mask)
        or   t4, t4, t6
        mv   s8, t4
        
        j    mshift_done

mask_zero:
    addi    sp, sp, -4
    sw      ra, 0(sp)

    mv   t5, t4 # t5=mask (ertmp)    
    #m1
    slli t6, t5, 1
    ori  t6, t6, 0x1
    and  t5, t5, t6
    #m2
    slli t6, t5, 2
    ori  t6, t6, 0x3
    and  t5, t5, t6    
    #m3
    slli t6, t5, 4
    ori  t6, t6, 0xF
    and  t5, t5, t6    
    #m4
    slli t6, t5, 8
    ori  t6, t6, 0xFF
    and  t5, t5, t6   
    #m5
    slli t6, t5, 16
    li   t2, 0xFFFF
    or   t6, t6, t2
    and  t5, t5, t6   
    mv   a5, t5
    mv   t6, t5
    
    lw      ra, 0(sp)
    addi    sp, sp,  4
    ret
    
return_x:
    jr   ra
  
      