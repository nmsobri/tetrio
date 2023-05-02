package state

StateInterface :: struct {
  update:  proc(),
  render:  proc(),
  input:   proc() -> bool,
  stateID: proc() -> string,
  onEnter: proc() -> bool,
  onExit:  proc() -> bool,
}
