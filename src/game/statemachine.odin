package game

StateInterface :: struct {
  updateFn:  proc(),
  renderFn:  proc(),
  onEnterFn: proc() -> bool,
  onExitFn:  proc() -> bool,
  inputFn:   proc(),
  stateIDFn: proc() -> string,
}

StateMachine :: struct {
  states:      [dynamic]^StateInterface,
  pushState:   proc(_: ^StateMachine, _: ^StateInterface),
  changeState: proc(_: ^StateMachine, _: ^StateInterface),
  popState:    proc(_: ^StateMachine),
  input:       proc(_: ^StateMachine),
  update:      proc(_: ^StateMachine),
  render:      proc(_: ^StateMachine),
}

state_machine_init :: proc() -> ^StateMachine {
  sm := new(StateMachine)
  sm.pushState = pushState
  sm.changeState = changeState
  sm.popState = popState
  sm.input = input
  sm.update = update
  sm.render = render

  return sm
}


pushState :: proc(self: ^StateMachine, state: ^StateInterface) {
  if len(self.states) != 0 {
    if self.states[len(self.states) - 1].stateID() == state.stateID() {
      return
    }

    self.states[len(self.states) - 1].onExit()
  }

  append(&self.states, state)
  self.states[len(self.states) - 1].onEnter()
}


changeState :: proc(self: ^StateMachine, state: ^StateInterface) {
  if len(self.states) != 0 {
    if self.states[len(self.states) - 1].stateID() == state.stateID() {
      return
    }

    if self.states[len(self.states) - 1].onExit() {
      pop(&self.states)
    }

    append(&self.states, state)
    self.states[len(self.states) - 1].onEnter()
  }

}


popState :: proc(self: ^StateMachine) {
  if len(self.states) != 0 {
    state := pop(&self.states)
    state.onExit()
  }

  if len(self.states) != 0 {
    state := pop(&self.states)
    state.onEnter()
  }
}

input :: proc(self: ^StateMachine) {
  if len(self.states) != 0 {
    state := pop(&self.states)
    state.input()
  }
}


update :: proc(self: ^StateMachine) {
  if len(self.states) != 0 {
    state := pop(&self.states)
    state.update()
  }
}

render :: proc(self: ^StateMachine) {
  if len(self.states) != 0 {
    state := pop(&self.states)
    state.render()
  }
}
