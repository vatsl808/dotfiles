cmake_minimum_required(VERSION 3.10)
project(dotfiles-installer)

add_custom_target(install ALL
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/install
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Running dotfiles installer script"
)

