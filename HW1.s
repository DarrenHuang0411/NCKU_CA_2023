

    #argu.
    #  $a0  float x

    #local var.
    #   x0  float y
    #   x1  int *p
    #   x2  uint exp
    #   x3  uint man
    #   x4  float r
    #   x5  int *pr

    ############################################
    lw      x0, 0(a0) # load arg. 

    mv      x1, x0     # x0 =x1(*p) 

    lw      x2, 
    andi    x2, x2, 0x7F800000 #extract exp

    lw      x3,
    andi    x3, x3, 0x007FFFFF #extract man

    beqz    x2, Zero_Back
    beqz    x3, Zero_Back

    li      t0, 0x7F800000  # t0 = 0x7F800000
    beq     x2, t0, Infinity_or_NaN  # if x2 ==0t1target

    #############################################
    lw      x4, x0 # 

    mv      x5, x4 # x4 =x5(*p)

    lw      t1, 0(x5) # 
    andi    t1, t1, 0xFF800000
    sw      t1, 0(x5) # 

    lw      t0, 0(x4)
    srli    t0, t0, 0x100

    add     x0, x0, x4 # x0 = x0 + x4

    lw      t2, 0(x1) # 
    andi    t2, t2, 0xFFFF0000
    sw      t2, 0(x1) # 

    jr ra   # jump to ra

#############################################
Infinity_or_NaN:
    jr ra   # jump to ra
    
Zero_Back:
    jr  ra   # jump to ra
    
and
