.global _main
.align 4

_main:
sub sp, sp, #0x60
str x19, [sp, #0x40]
stp x29, x30, [sp, #0x50]
add x29, sp, #0x50
;stp x29, x30, [sp, #-0x10]! // Sub 0x10 from sp and then store x29 (fp) and x30 (lr) at *sp and *(sp+0x8)
;sub sp, sp, #0x60 // sp -= 0x10

// Draw Init Message
adr x0, init_sdl_msg
bl _printf
mov w0, #0

// Init SDL
mov w0, #0x00000020 // SDL_VIDEO_INIT
bl _SDL_Init

// Create Window
adr x0, sdl_title
mov w5, #0x00000004 // Show Window
mov w4, #800
mov w3, #600
mov w2, #0x2FFF0000
mov w1, #0x2FFF0000
bl _SDL_CreateWindow
str x0, [sp]
bl _SDL_GetWindowSurface
ldr x0, [sp]
bl _SDL_UpdateWindowSurface


mov w0, 0
str w0, [sp, #8] // Should Quit Variable
Lgame_loop:
    ldr w0, [sp, #8]
    cmp w0, 1
    beq Lend_game_loop // End if we quitted

    // Process Events
    sub sp, sp, 0x40 // Make Space for Event e and align to 16 bytes
    Levent_loop:
        mov x0, sp       ; Event e
        bl _SDL_PollEvent
        cmp w0, #0
        beq Lend_event_loop // While PollEvent is not 0 we run the gameloop
        // Check Events
        // Load Type
        ldr w0, [sp] // e.type
        cmp w0, #256 // Quit Event
        bne Lend_event_check
        mov w1, 1
        str w1, [sp, #72] ; 0x40[Event]+8[should_quit]
        b Lend_event_loop
        Lend_event_check:
        b Levent_loop
    Lend_event_loop:
    add sp, sp, 0x40 // Clean up (Event e;)

    b Lgame_loop

Lend_game_loop:

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
sdl_title:          .ascii "Ich habe keine Hobbys"
