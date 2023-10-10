.data
    test: .word  0x3d37ed42, 0x3dfa0dfe,0x3d37ed42,0x3dfa0dfe,0x3ea9fb61,0x3dfa0dfe,0x3d37ed42, 0x3dfa0dfe,0x3d37ed42 #orig 
    #0x3dfa0dfe, 0x3ea9fb61
    
    data_img: .word 0x41f00000,0x42820000,0x430a0000
    
    result_str:  .string "Filter: \n"
    changeline:     .string "\n"
.text

start:
    j    main


Loop_o:
    bge 	s0, s11, Loop_o_d  # if t0 >= t1 then target
    li 		s1, 0 #  j=0     
Loop_i:
    bge 	s1, s11, Loop_i_d  
    slli    t0, s0, 3
    slli    t1, s0, 2
    add     t2, t0, t1   #t2 = 12*i        
    add     s10, t2 ,s1  #s10 = addr.= 12*i + j

    la      a0, test    
    add     a0, a0, s3
    call	fp32_to_bf16
    mv  a5, t5
    li  a7, 2
    ecall
    li    a0 , 32
    li    a7 , 11
    ecall 
    addi   s1, s1, 1
    j      Loop_i
    #la          a2, data_img  
    #call        fmul16    # a0=return value 
    #mv      s4, a0  #s4 = R*0.299
Loop_i_d:
    la  a0, changeline 
    li  a7, 4 
    ecall
    addi    s0, s0, 1  
    j Loop_o  # jump to Loop_o
Loop_o_d:
    ret

fp32_to_bf16:
    
    lw   t6, 0(a0)
    #lw    t7, 0(a0) 
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
    sw    t5, 0(a1)
ret


main:
    la    a0, result_str
    li    a7, 4
    ecall
    li s0, 0
    li s1, 0
    li s11, 3
    call  Loop_o 
  
    li    a7, 10
    ecall   

return_x:
    jr   ra
  
      