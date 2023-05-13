package main

import "core:os"
import "core:fmt"

import "util"
import "state"
import cfg "config"

import sdl "vendor:sdl2"

Errno :: distinct i32
ERROR_NONE: Errno : 0
ERROR_INIT: Errno : 1

GameInterface :: struct {
  close: proc(_: ^Game),
  loop:  proc(_: ^Game),
}

Game :: struct {
  using vtable:  GameInterface,
  window:        ^sdl.Window,
  renderer:      ^sdl.Renderer,
  timer:         ^util.Timer,
  state_machine: ^state.StateMachine,
}


Game_init :: proc() -> (^Game, Errno) {
  if status := sdl.Init(sdl.INIT_VIDEO | sdl.INIT_AUDIO); status < 0 {
    fmt.eprintf("ERROR: %s\n", sdl.GetErrorString())
    return nil, ERROR_INIT
  }

  self := new(Game)

  self.vtable = {
    close = close,
    loop  = loop,
  }

  self.window = sdl.CreateWindow(cfg.GAME_NAME, cfg.WINDOW_X, cfg.WINDOW_Y, cfg.WINDOW_WIDTH, cfg.WINDOW_HEIGHT, cfg.WINDOW_FLAGS)
  self.renderer = sdl.CreateRenderer(self.window, -1, {.ACCELERATED})
  self.timer = util.Timer_init()
  self.state_machine = state.StateMachine_init()

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
