package state

import "core:fmt"
import sdl "vendor:sdl2"

PlayState :: struct {
  using vtable:  StateInterface,
  window:        ^sdl.Window,
  renderer:      ^sdl.Renderer,
  state_machine: ^StateMachine,
}


init_play_state :: proc(w: ^sdl.Window, r: ^sdl.Renderer, sm: ^StateMachine) -> ^StateInterface {
  ps := new(PlayState)

  ps.window = w
  ps.renderer = r
  ps.state_machine = sm

  ps.vtable = {
    update  = update,
    render  = render,
    input   = input,
    stateID = stateID,
    onEnter = onEnter,
    onExit  = onExit,
    variant = ps,
  }

  return ps
}


@(private = "file")
update :: proc(self: ^StateInterface) {

}


@(private = "file")
render :: proc(self: ^StateInterface) {

}


@(private = "file")
input :: proc(self: ^StateInterface) -> bool {
  evt: sdl.Event

  for sdl.PollEvent(&evt) {
    #partial switch (evt.type) {
    case .QUIT:
      return false
    case .KEYDOWN:
      #partial switch (evt.key.keysym.sym) {
      case .ESCAPE:
        return false
      case .RETURN:
        fmt.println("play::enter press")
      }
    }
  }

  return true
}


@(private = "file")
stateID :: proc(self: ^StateInterface) -> string {
  return "Play"
}


@(private = "file")
onEnter :: proc(self: ^StateInterface) -> bool {
  return true
}


@(private = "file")
onExit :: proc(self: ^StateInterface) -> bool {
  return true
}
