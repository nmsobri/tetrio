package main

import "core:os"
import "core:fmt"
import "core:bytes"
import "core:image/png"

import "util"
import "state"
import cfg "config"

import sdl "vendor:sdl2"
import "vendor:sdl2/mixer"

Errno :: distinct i32
ERROR_NONE: Errno : 0
ERROR_INIT: Errno : 1

ICON :: #load("../res/logo.png")

Game :: struct {
  close:         proc(_: ^Game),
  loop:          proc(_: ^Game),
  window:        ^sdl.Window,
  renderer:      ^sdl.Renderer,
  timer:         ^util.Timer,
  state_machine: ^state.StateMachine,
}


Game_init :: proc() -> (^Game, Errno) {
  if status := sdl.Init(sdl.INIT_VIDEO | sdl.INIT_AUDIO); status < 0 {
    fmt.eprintf("ERROR: %s\n", sdl.GetError())
    return nil, ERROR_INIT
  }

  // Initialize SDL_mixer
  if mixer.OpenAudio(44100, mixer.DEFAULT_FORMAT, 2, 2048) < 0 {
    fmt.eprintf("SDL_mixer could not initialize! SDL_mixer Error: %s\n", sdl.GetError())
    return nil, ERROR_INIT
  }

  self := new(Game)

  self.close = close
  self.loop = loop

  self.window = sdl.CreateWindow(cfg.GAME_NAME, cfg.WINDOW_X, cfg.WINDOW_Y, cfg.WINDOW_WIDTH, cfg.WINDOW_HEIGHT, cfg.WINDOW_FLAGS)
  self.renderer = sdl.CreateRenderer(self.window, -1, {.ACCELERATED})
  self.timer = util.Timer_init()
  self.state_machine = state.StateMachine_init()

  setWindowIcon(self.window)

  start_state := state.StartState_init(self.window, self.renderer, self.state_machine)
  self.state_machine->changeState(start_state)
  return self, ERROR_NONE
}


@(private = "file")
close :: proc(self: ^Game) {
  free(self.timer)
  free(self.state_machine)

  sdl.DestroyWindow(self.window)
  sdl.DestroyRenderer(self.renderer)
  sdl.Quit()
}


@(private = "file")
loop :: proc(self: ^Game) {
  ever := true

  for ever {
    self.timer->startTimer()

    if ok := self.state_machine->input(); !ok do ever = false
    self.state_machine->update()
    self.state_machine->render()

    time_taken := cast(f64)self.timer->getTicks()

    if (time_taken < cfg.TICKS_PER_FRAME) {
      delay := cast(u32)(cfg.TICKS_PER_FRAME - time_taken)
      sdl.Delay(delay)
    }
  }

}


setWindowIcon :: proc(window: ^sdl.Window) {
  icon_image, err := png.load(ICON)
  defer png.destroy(icon_image)

  rmask, gmask, bmask, amask: u32
  when ODIN_ENDIAN == .Big {
    rmask = 0xFF000000
    gmask = 0x00FF0000
    bmask = 0x0000FF00
    amask = 0x000000FF
  } else when ODIN_ENDIAN == .Little {
    rmask = 0x000000FF
    gmask = 0x0000FF00
    bmask = 0x00FF0000
    amask = 0xFF000000
  }

  icon_surface := sdl.CreateRGBSurfaceFrom(raw_data(bytes.buffer_to_bytes(&icon_image.pixels)), 64, 64, 32, 256, rmask, gmask, bmask, amask)
  defer sdl.FreeSurface(icon_surface)

  sdl.SetWindowIcon(window, icon_surface)
}
