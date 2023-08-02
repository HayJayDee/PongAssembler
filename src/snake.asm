.align 4

// snake_part:
// x uint32
// y uint32
// next: snake_part*
// sizeof(snake_part) = 4+4+8 = 16

// snake_part_create(snake_part* parent)
snake_part_create:
    stp x29, x30, [sp, #-0x10]! // Sub sp 0x10 and save x29, x30 on stack
    mov x29, sp // Save this stack frame
    sub sp, sp, 0x100

    mov x0, 16
    bl _malloc

    add sp, sp, 0x100
    ldp x29, x30, [sp], #0x10
    ret
