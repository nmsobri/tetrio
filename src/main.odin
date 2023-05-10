package main

import "core:fmt"
import sdl "vendor:sdl2"

main :: proc() {
  game, ok := Game_init()

  if ok != ERROR_NONE {
    fmt.eprintf("Cannot init SDL")
    return
  }

  defer free(game)
  defer game->close()
  game->loop()
}
