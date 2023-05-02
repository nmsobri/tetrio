package state

import "core:fmt"
import sdl "vendor:sdl2"

StartState :: struct {
  using interface: StateInterface,
}

init_start_state :: proc() -> ^StateInterface {
  ss := new(StartState)

  ss.update = _update
  ss.render = _render
  ss.input = _input
  ss.stateID = _stateID
  ss.onEnter = _onEnter
  ss.onExit = _onExit

  return ss
}

_update :: proc() {

}

_render :: proc() {

}

_input :: proc() -> bool {
  evt: sdl.Event

  for sdl.PollEvent(&evt) {
    #partial switch (evt.type) {
    case .QUIT:
      return false
    case .KEYDOWN:
      #partial switch (evt.key.keysym.sym) {
      case .ESCAPE:
      // play_state := state.init_play_state()
      // self.state_machine.changeState(play_state)
      case .KP_ENTER:
        fmt.println("enter press")
        return false
      }
    }
  }

  return true
}

_stateID :: proc() -> string {
  return "Start"
}

_onEnter :: proc() -> bool {
  return true
}

_onExit :: proc() -> bool {
  return true
}
