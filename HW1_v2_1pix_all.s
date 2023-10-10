.data
    test1: .word  0x3d37ed42, #orig 
    #0x3dfa0dfe, 0x3ea9fb61
    
    data_img: .word 0x41f00000
    #0x42820000, 0x430a0000
    
    result_str:  .string "Filter image: \n"
    endline:     .string "\n"
.text

main:
    la    a0, result_str
    li    a7, 4
    ecall
    
    call  fp32_to_bf16
  
    call  fmul16
    li    a7, 10
    ecall   

fp32_to_bf16:

    lw    a0, test1
    lw    a3, data_img
    
    li    t1, 0x7F800000
    and   s2, a0, t1    #exp
    li    t2, 0x007FFFFF
    and   s3, a0, t2    #man
    
    beq   a0, zero, return_x #zero
    beq   s2, t1,return_x    #inf or nan
    
    ###### Normalize
    mv    s4, a0  #r=s4
    li    t3, 0xFF800000
    and   t4, t3, t4  #t4 = *pr
    
    srli  s4, s4, 8
    li    t4, 0x8000
    
    add   s5, s4, a0 
    or    s6, s5, s2  #s6=y(32)
    
    li    t5, 0xFFFF0000  
    and   t5, a0, t5     #a0=y(16)
    sw    t5, 0(a1)
ret

fmul16:
    lw    s2, 0(a1)  #a1 is filter bf16
    lw    s3, 0(a3)  #a3 is img bf16
    
    srli  s2, s2, 16
    srli  s3, s3, 16
    #sign
    srli  s4, s2, 15
    srli  s5, s3, 15    
    #man
    li    t1, 0x7F
    li    t2, 0x80
    and   s6, t1, s2
    and   s7, t1, s2
    #exp
    srli  s8, s2, 7
    srli  s9, s3, 7
    andi  s8, s8, 0xFF 
    andi  s9, s9, 0xFF 
    #mr
    call  imul     
    li    t4, 24
    call  get_bit
    srl   t3, t3, t0 #t0 now is mshift
    mv    s6, t3
    #er
    mv    t4, s6     #t4 now is ertmp 
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
        slli  s4, s4, 15
        or    s10, s10, s4  #s10=result
        #result er
        andi  s8, s8, 0xFF
        slli  s8, s8, 7
        or    s10, s10, s8
        #result mr
        and   s6, s6, t1
        or    s10, s10, s6
    ret    
    
imul: 
    lw    t4, 0(s6)    #t4 = a
    lw    t5, 0(s7)    #t5 = b
    add   t6,t6, zero     #t6 = r 
    
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
        ret    

get_bit:
    srl   t6, t6, t4  #mr = mrtmp >> mshift;  
    andi  t0, t6, 1   #t0 use to getbit--> now is mshift
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
        xori a5, a5, 0xFFFFFFFF   #a5=(~mask)
        and  t4, t4, a5           #t4= (x & ~mask)
        or   t4, t4, t6
        mv   a6, t4
        
        j    mshift_done

mask_zero:
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
    mv   a5, t6
    
    ret
        
return_x:
    jr   ra
  

    