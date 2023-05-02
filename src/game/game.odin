package game

import "core:os"
import "core:fmt"
import "./../state"
import sdl "vendor:sdl2"

Errno :: distinct i32
ERROR_NONE: Errno : 0
ERROR_INIT: Errno : 1

Game :: struct {
  close:         proc(_: ^Game),
  loop:          proc(_: ^Game),
  window:        Maybe(^sdl.Window),
  renderer:      Maybe(^sdl.Renderer),
  timer:         ^Timer,
  state_machine: ^StateMachine,
}

game_init :: proc() -> (^Game, Errno) {
  if status := sdl.Init(sdl.INIT_VIDEO | sdl.INIT_AUDIO); status < 0 {
    fmt.eprintf("ERROR: %s\n", sdl.GetErrorString())
    return nil, ERROR_INIT
  }

  self := new(Game)
  self.close = _close
  self.loop = _loop
  self.window = sdl.CreateWindow(GAME_NAME, WINDOW_X, WINDOW_Y, WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_FLAGS)
  self.renderer = sdl.CreateRenderer(self.window.?, -1, {.ACCELERATED})
  self.timer = timer_init()
  self.state_machine = state_machine_init()

  start_state := state.init_start_state()
  self.state_machine->changeState(start_state)
  return self, ERROR_NONE
}

_close :: proc(self: ^Game) {
  sdl.DestroyWindow(self.window.?)
  sdl.DestroyRenderer(self.renderer.?)
  sdl.Quit()
}

_loop :: proc(self: ^Game) {
  ever := true

  for ever {
    self.timer->startTimer()

    if ok := self.state_machine->input(); !ok do ever = false
    self.state_machine->update()
    self.state_machine->render()

    time_taken := cast(f64)self.timer->getTicks()

    if (time_taken < TICKS_PER_FRAME) {
      delay := cast(u32)(TICKS_PER_FRAME - time_taken)
      sdl.Delay(delay)
    }
  }
}
