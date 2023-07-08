package game

DrawInterface :: struct {
  draw:                   proc(self: ^DrawInterface, view: View),
  draw_interface_variant: union {
    ^Board,
    ^Piece,
  },
}
