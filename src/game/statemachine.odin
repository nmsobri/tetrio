package game
import "./../state"
import "core:fmt"

StateMachine :: struct {
  states:      [dynamic]^state.StateInterface,
  pushState:   proc(_: ^StateMachine, _: ^state.StateInterface),
  changeState: proc(_: ^StateMachine, _: ^state.StateInterface),
  popState:    proc(_: ^StateMachine),
  input:       proc(_: ^StateMachine) -> bool,
  update:      proc(_: ^StateMachine),
  render:      proc(_: ^StateMachine),
}

state_machine_init :: proc() -> ^StateMachine {
  sm := new(StateMachine)
  sm.pushState = _pushState
  sm.changeState = _changeState
  sm.popState = _popState
  sm.input = _input
  sm.update = _update
  sm.render = _render

  return sm
}

_pushState :: proc(self: ^StateMachine, state: ^state.StateInterface) {
  if len(self.states) != 0 {
    if self.states[len(self.states) - 1].stateID() == state.stateID() do return

    self.states[len(self.states) - 1].onExit()
  }

  append(&self.states, state)
  self.states[len(self.states) - 1].onEnter()
}

_changeState :: proc(self: ^StateMachine, state: ^state.StateInterface) {
  if len(self.states) != 0 {
    if self.states[len(self.states) - 1].stateID() == state.stateID() do return

    if self.states[len(self.states) - 1].onExit() do pop(&self.states)
  }

  append(&self.states, state)
  self.states[len(self.states) - 1].onEnter()
}

_popState :: proc(self: ^StateMachine) {
  if len(self.states) != 0 {
    self.states[len(self.states) - 1].onExit()
    pop(&self.states)
  }

  if len(self.states) != 0 do self.states[len(self.states) - 1].onEnter()
}

_input :: proc(self: ^StateMachine) -> bool {
  if len(self.states) != 0 do return self.states[len(self.states) - 1].input()
  return false
}

_update :: proc(self: ^StateMachine) {
  if len(self.states) != 0 do self.states[len(self.states) - 1].update()
}

_render :: proc(self: ^StateMachine) {
  if len(self.states) != 0 do self.states[len(self.states) - 1].render()
}
