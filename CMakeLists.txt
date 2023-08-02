cmake_minimum_required(VERSION 3.13)
project(pong ASM)

find_package(SDL2 REQUIRED)

add_executable(pong src/main.asm)
target_link_libraries(pong ${SDL2_LIBRARIES})