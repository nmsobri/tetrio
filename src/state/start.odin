package state

import "core:os"
import "core:fmt"
import sdl "vendor:sdl2"

StartState :: struct {
  using vtable:  StateInterface,
  window:        ^sdl.Window,
  renderer:      ^sdl.Renderer,
  state_machine: ^StateMachine,
}


init_start_state :: proc(w: ^sdl.Window, r: ^sdl.Renderer, sm: ^StateMachine) -> ^StateInterface {
  ss := new(StartState)

  ss.window = w
  ss.renderer = r
  ss.state_machine = sm

  ss.vtable = {
    update  = update,
    render  = render,
    input   = input,
    stateID = stateID,
    onEnter = onEnter,
    onExit  = onExit,
    variant = ss,
  }

  return ss
}


@(private = "file")
update :: proc(self: ^StateInterface) {

}


@(private = "file")
render :: proc(self: ^StateInterface) {

}


@(private = "file")
input :: proc(self: ^StateInterface) -> bool {
  self, ok := self.variant.(^StartState)

  if !ok {
    fmt.eprintln("Not ^StartState")
    os.exit(1)
  }

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
        fmt.println("start::enter press")
        play_state := init_play_state(self.window, self.renderer, self.state_machine)
        self.state_machine->changeState(play_state)
      }
    }
  }

  return true
}


@(private = "file")
stateID :: proc(self: ^StateInterface) -> string {
  return "Start"
}


@(private = "file")
onEnter :: proc(self: ^StateInterface) -> bool {
  return true
}


@(private = "file")
onExit :: proc(self: ^StateInterface) -> bool {
  return true
}
