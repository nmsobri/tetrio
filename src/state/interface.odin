package state

StateInterface :: struct {
  update:  proc(_: ^StateInterface),
  render:  proc(_: ^StateInterface),
  input:   proc(_: ^StateInterface) -> bool,
  stateID: proc(_: ^StateInterface) -> string,
  onEnter: proc(_: ^StateInterface) -> bool,
  onExit:  proc(_: ^StateInterface) -> bool,
  variant: union {
    ^StartState,
    ^PlayState,
    ^PauseState,
  },
}

StateMachineMethod :: struct {
  pushState:   proc(_: ^StateMachine, _: ^StateInterface),
  changeState: proc(_: ^StateMachine, _: ^StateInterface),
  popState:    proc(_: ^StateMachine),
  input:       proc(_: ^StateMachine) -> bool,
  update:      proc(_: ^StateMachine),
  render:      proc(_: ^StateMachine),
}
