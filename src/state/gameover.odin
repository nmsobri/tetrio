package state

import "../game"
import "../util"
import "core:os"
import "core:fmt"
import sdl "vendor:sdl2"
import "vendor:sdl2/mixer"


GameoverState :: struct {
  using vtable:  StateInterface,
  window:        ^sdl.Window,
  renderer:      ^sdl.Renderer,
  state_machine: ^StateMachine,
}


GameoverState_init :: proc(w: ^sdl.Window, r: ^sdl.Renderer, sm: ^StateMachine) -> ^StateInterface {
  return nil
}


@(private = "file")
update :: proc(self: ^StateInterface) {
}


@(private = "file")
render :: proc(self: ^StateInterface) {
}


@(private = "file")
input :: proc(self: ^StateInterface) -> bool {
  return true
}

@(private = "file")
stateID :: proc(self: ^StateInterface) -> string {
  return "GameOver"
}


@(private = "file")
onEnter :: proc(self: ^StateInterface) -> bool {
  return true
}


@(private = "file")
onExit :: proc(self: ^StateInterface) -> bool {
  return true
}


@(private = "file")
close :: proc(self: ^PlayState) {
}
