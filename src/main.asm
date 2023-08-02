.global _main
.align 4

_main:
sub sp, sp, #0x60
str x19, [sp, #0x40]
stp x29, x30, [sp, #0x50]
add x29, sp, #0x50

// Draw Init Message
adr x0, init_sdl_msg
bl _printf
mov w0, #0

// Init SDL
mov w0, SDL_VIDEO_INIT // SDL_VIDEO_INIT
bl _SDL_Init

// Create Window
adr x0, sdl_title
mov w5, SHOW_WINDOW // Show Window
mov w4, WINDOW_HEIGHT
mov w3, WINDOW_WIDTH
mov w2, #0x2FFF0000
mov w1, #0x2FFF0000
bl _SDL_CreateWindow
str x0, [sp]
mov w1, -1
mov w2, 2
bl _SDL_CreateRenderer
str x0, [sp, #8]


mov w0, 0
str w0, [sp, #16] // Should Quit Variable
Lgame_loop:
    ldr w0, [sp, #16]
    cmp w0, 1
    beq Lend_game_loop // End if we quitted

    ldr x0, [sp, #8]
    mov w1, 255
    mov w2, 255
    mov w3, 255
    mov w4, 255
    bl _SDL_SetRenderDrawColor
    ldr x0, [sp, #8]
    bl _SDL_RenderClear

    // Process Events
    sub sp, sp, 0x40 // Make Space for Event e and align to 16 bytes
    Levent_loop:
        mov x0, sp       // Event e
        bl _SDL_PollEvent
        cmp w0, #0
        beq Lend_event_loop // While PollEvent is not 0 we run the gameloop
        // Check Events
        // Load Type
        ldr w0, [sp] // e.type
        cmp w0, #256 // Quit Event
        bne Lend_event_check
        mov w1, 1
        str w1, [sp, (0x40+16)] // 0x40[Event]+8[should_quit]
        b Lend_event_loop
        Lend_event_check:
        b Levent_loop
    Lend_event_loop:
    add sp, sp, 0x40 // Clean up (Event e)

    ldr x0, [sp, #8]
    bl _SDL_RenderPresent

    b Lgame_loop

Lend_game_loop:

ldr x0, [sp, #8]
bl _SDL_DestroyRenderer

ldr x0, [sp]
bl _SDL_DestroyWindow

ldp x29, x30, [sp, #0x50]
ldr x19, [sp, #0x40]
add sp, sp, #0x60
mov w0, #0
ret

.align 4
init_sdl_msg:       .ascii  "Initializing SDL2\n"
.align 4
sdl_title:          .ascii "PongAsm"

.equ SDL_VIDEO_INIT, 0x00000020
.equ SHOW_WINDOW, 0x00000004
.equ WINDOW_WIDTH, 800
.equ WINDOW_HEIGHT, 600
