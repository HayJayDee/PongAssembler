.align 4
.global snake_part_create
.global snake_part_render

// snake_part:
// x uint32
// y uint32
// nect: snake_part*
// sizeof(snake_part) = 4+4+8 = 16

// snake_part_create(x,y, nect)
snake_part_create:
    stp x29, x30, [sp, #-0x10]! // Sub sp 0x10 and save x29, x30 on stack
    mov x29, sp // Save this stack frame
    sub sp, sp, 0x10

    stp w0, w1, [sp]
    str x2, [sp, #8]

    mov x0, 16
    bl _malloc

    ldp w1, w2, [sp]
    ldr x3, [sp, #8]

    stp w1, w2, [x0]
    str x3, [x0, #8]

    add sp, sp, 0x10
    ldp x29, x30, [sp], #0x10
    ret

// snake_part_render(renderer, snake_part, head, grid)
snake_part_render:
    stp x29, x30, [sp, #-0x10]! // Sub sp 0x10 and save x29, x30 on stack
    mov x29, sp // Save this stack frame
    sub sp, sp, 0x100
    stp x19, x20, [sp]
    str x0, [sp, #16] // Save renderer
    mov x19, x1 // Save Snakepart
    mov x20, x3 // Save grid

    cmp w2, 0 // Is head!=0
    bne Lset_head_color
        mov w1, 255
        mov w2, 255
        mov w3, 255
        b Lend_set_color
    Lset_head_color:
        mov w1, 0
        mov w2, 255
        mov w3, 0
    Lend_set_color:
        mov w4, 255
    bl _SDL_SetRenderDrawColor
    
    // Draw this part
    // x = grid_x + x*cell_size
    ldr w8, [x20, #16] // Cell_size
    ldr w9, [x19] // x
    mul w9, w9, w8
    ldr w8, [x20] // grid_x
    add w8, w8, w9
    str w8, [sp, #24] // Start of rect
    
    // y = grid_y + y * cell_size
    ldr w8, [x20, #16] // Cell_size
    ldr w9, [x19, #4] // x
    mul w9, w9, w8
    ldr w8, [x20, #4] // grid_y
    add w8, w8, w9
    str w8, [sp, #28] // y of rect

    ldr w8, [x20, #16]
    str w8, [sp, #32] // width of rect
    str w8, [sp, #36] // Height of rect

    ldr x0, [sp, #16] // Renderer
    add x1, sp, 24
    bl _SDL_RenderFillRect

    // Draw next part
    ldr x1, [x19, #8] // Next part
    cmp x1, 0
    beq Lend_render
        ldr x0, [sp, #16] // Renderer
        mov w2, 0 // Not a head anymore
        mov x3, x20
        bl snake_part_render
    Lend_render:

    ldp x19, x20, [sp]
    add sp, sp, 0x100
    ldp x29, x30, [sp], #0x10
    ret
