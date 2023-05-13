package game

import "core:c"
import "../config"
import sdl "vendor:sdl2"

Board :: struct {
  using mixin:     DrawMixin,
  board:           [config.ROW][config.COL]Maybe([4]u8),
  full_rows:       [config.ROW]bool,
  animation_frame: u8,
  renderer:        ^sdl.Renderer,
  draw:            proc(_: ^Board, _: View),
}

Board_init :: proc(renderer: ^sdl.Renderer) -> ^Board {
  self := new(Board)

  self.mixin = {
    _draw   = _draw,
    variant = self,
  }

  self.animation_frame = 0
  self.renderer = renderer
  self.draw = draw


  return self
}


draw :: proc(self: ^Board, view: View) {
  row: i32 = 0
  for row < config.ROW {

    col: i32 = 0
    for col < config.COL {
      if self.board[row][col] != nil {
        color := self.board[row][col].?
        self->_draw(col * config.BLOCK, row * config.BLOCK, color[0], color[1], color[2], color[3])
      } else {
        self->_draw(col * config.BLOCK, row * config.BLOCK, 255, 255, 255, 255)
      }
      col += 1
    }
    row += 1
  }

}
