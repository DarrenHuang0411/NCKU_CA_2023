.data
    test: .word  0x3d37ed42, 0x3dfa0dfe,0x3d37ed42,0x3dfa0dfe,0x3ea9fb61,0x3dfa0dfe,0x3d37ed42, 0x3dfa0dfe,0x3d37ed42 #orig 
    
    data_img: .word 0x41f00000,0x42820000,0x430a0000, 0x42540000, 0x43660000, 0x43700000, 0x426c0000, 0x42ae0000, 0x41600000
    
    origin_img:  .string "Origin: \n"
    result_str:  .string "Filter: \n"
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
    mv    a0, t5
    #mv
    #la     a0, data_img  

    #call        fmul16    # a0=return value 
    #mv      s4, a0  #s4 = R*0.299
    #mv      a5, t5

    li  a7, 2
    ecall
    
    li    a0 , 32
    li    a7 , 11
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
    
return_x:
    jr   ra
  
      