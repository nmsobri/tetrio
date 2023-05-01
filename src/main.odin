package main

import "core:fmt"
import sdl "vendor:sdl2"

WINDOW_WIDTH :: 640
WINDOW_HEIGHT :: 480
WINDOW_FLAGS :: sdl.WindowFlags{.SHOWN}

main :: proc() {
  if status := sdl.Init(sdl.INIT_VIDEO | sdl.INIT_AUDIO); status != 0 {
    fmt.eprintf("ERROR: %s\n", sdl.GetErrorString())
    return
  }

  window := sdl.CreateWindow("Hello World", 0, 0, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_FLAGS)
  renderer := sdl.CreateRenderer(window, -1, {.ACCELERATED})

  sdl.CreateWindowAndRenderer(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_FLAGS, &window, &renderer)
  defer sdl.DestroyRenderer(renderer)
  defer sdl.DestroyWindow(window)

  for {
    sdl.RenderClear(renderer)
    sdl.RenderPresent(renderer)
  }

}
