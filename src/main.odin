package main

import g "game"
import "core:fmt"
import sdl "vendor:sdl2"

main :: proc() {
  game, ok := g.game_init()

  if ok != g.ERROR_NONE {
    fmt.eprintf("Cannot init SDL")
    return
  }

  defer free(game)
  defer game->close()
  game->loop()
}
