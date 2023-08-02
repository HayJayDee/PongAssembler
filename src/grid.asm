.align 4
.global grid_create
.global grid_render

// Grid:
// x uint32_t
// y uint32_t
// width (in cells)
// height (in cells)
// cell_size (in pixels)
// sizeof(grid) = 4+4+4+4+4 = 20

// grid* grid_create(x, y, width, height, cell_size)
grid_create:
    stp x29, x30, [sp, #-0x10]! // Sub sp 0x10 and save x29, x30 on stack
    mov x29, sp // Save this stack frame
    sub sp, sp, 0x20

    stp w0, w1, [sp]
    stp w2, w3, [sp, 8]
    str w4, [sp, 16]

    mov x0, 20
    bl _malloc

    // x0 is pointer to grid
    ldp w1, w2, [sp]
    ldp w3, w4, [sp, 8]
    ldr w5, [sp, 16]

    stp w1, w2, [x0]
    stp w3, w4, [x0, 8]
    str w5, [x0, 16]

    add sp, sp, 0x20
    ldp x29, x30, [sp], #0x10
    ret

// x0=renderer, x1=grid
grid_render:
    stp x29, x30, [sp, #-0x10]! // Sub sp 0x10 and save x29, x30 on stack
    mov x29, sp // Save this stack frame
    sub sp, sp, 0x20
    str x19, [sp] // Save x19 (Bc I use it and it is callee-saved)

    str x0, [sp, #8]
    mov x19, x1 // x19 = grid*

    // Set Color
    mov w1, 255
    mov w2, 255
    mov w3, 255
    mov w4, 255
    bl _SDL_SetRenderDrawColor

    // Draw horizontal
    mov w8, wzr
    Ldraw_hor:
        ldr w9, [x19, #12] // w9=height
        cmp w8, w9
        bgt Ldraw_hor_end // counter > height ==> end

        // Store Counter
        str w8, [sp, #16]

        // Calc y_draw = y + w8*cell_size
        ldr w10, [x19, #16] // w10 = cell_size
        mul w10, w10, w8 // w10 *= w8
        ldr w9, [x19, #4] // w9 = y
        add w2, w10, w9
        mov w4, w2

        // end_x = x + cell_size*width
        ldr w10, [x19, #16] // w10=cell_size
        ldr w9, [x19, #8] // w10=width
        mul w10, w10, w9
        ldr w9, [x19] // w9 = x
        add w3, w10, w9


        ldr w1, [x19] // Start x
        ldr x0, [sp, #8]
        bl _SDL_RenderDrawLine

        // Reload counter
        ldr w8, [sp, #16]

        add w8, w8, 1 // add counter 1

        b Ldraw_hor
    Ldraw_hor_end:

    // Draw Vertical Lines
    mov w8, wzr // counter=0
    Ldraw_vert:
        ldr w9, [x19, #8] // w9=width
        cmp w8, w9
        bgt Ldraw_vert_end // counter > width ==> end

        str w8, [sp, #16] // Save counter

        // end_y = y + cell_size*height
        ldr w10, [x19, #16] // w10=cell_size
        ldr w9, [x19, #12] // w10=height
        mul w10, w10, w9
        ldr w9, [x19, #4] // w9 = y
        add w4, w10, w9

        // start/end_x = x + cell_size*counter
        ldr w10, [x19, #16] // w10=cell_size
        mul w10, w10, w8
        ldr w8, [x19] // x
        add w1, w10, w8
        mov w3, w1




        ldr w2, [x19, #4] // start_y
        ldr x0, [sp, #8]
        bl _SDL_RenderDrawLine

        ldr w8, [sp, #16] // Reload counter
        add w8, w8, #1 // Add counter 1
        b Ldraw_vert
    Ldraw_vert_end:

    ldr x19, [sp]
    add sp, sp, 0x20
    ldp x29, x30, [sp], #0x10
    ret
