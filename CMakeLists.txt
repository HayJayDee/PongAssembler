cmake_minimum_required(VERSION 3.13)
project(snake ASM)

find_package(SDL2 REQUIRED)

add_executable(snake src/main.asm src/grid.asm src/snake.asm)
target_link_libraries(snake ${SDL2_LIBRARIES})