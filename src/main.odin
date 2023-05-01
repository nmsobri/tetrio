package main

import "core:fmt"
import sdl "vendor:sdl2"

WINDOW_WIDTH :: 640
WINDOW_HEIGHT :: 480
WINDOW_TITLE :: "Tetrio"
WINDOW_X :: sdl.WINDOWPOS_CENTERED
WINDOW_Y :: sdl.WINDOWPOS_CENTERED
WINDOW_FLAGS :: sdl.WindowFlags{.SHOWN}

main :: proc() {
  if status := sdl.Init(sdl.INIT_VIDEO | sdl.INIT_AUDIO); status != 0 {
    fmt.eprintf("ERROR: %s\n", sdl.GetErrorString())
    return
  }

  window := sdl.CreateWindow(WINDOW_TITLE, WINDOW_X, WINDOW_Y, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_FLAGS)
  renderer := sdl.CreateRenderer(window, -1, {.ACCELERATED})

  defer sdl.DestroyRenderer(renderer)
  defer sdl.DestroyWindow(window)

  running := true

  for running {
    evt: sdl.Event

    for sdl.PollEvent(&evt) {
      #partial switch (evt.type) {
      case .QUIT:
        running = false
      case .KEYDOWN:
        #partial switch (evt.key.keysym.sym) {
        case .ESCAPE:
          running = false
        }
      }

    }
    sdl.RenderClear(renderer)
    sdl.RenderPresent(renderer)
  }

  sdl.Quit()

}
