package game

import "core:c"
import "../config"
import sdl "vendor:sdl2"

Board :: struct {
  using mixin:     DrawMixin,
  using interface: DrawInterface,
  board:           [config.ROW][config.COL]Maybe([4]u8),
  full_rows:       [config.ROW]bool,
  animation_frame: u8,
  renderer:        ^sdl.Renderer,
}

Board_init :: proc(renderer: ^sdl.Renderer) -> ^Board {
  board := new(Board)

  board.mixin = {
    _draw              = _draw,
    draw_mixin_variant = board,
  }

  board.interface = {
    draw                   = board_draw,
    draw_interface_variant = board,
  }

  board.animation_frame = 0
  board.renderer = renderer

  return board
}


board_draw :: proc(self: ^DrawInterface, view: View) {
  self, ok := self.draw_interface_variant.(^Board)

  for row: i32 = 0; row < config.ROW; row += 1 {
    for col: i32 = 0; col < config.COL; col += 1 {
      if self.board[row][col] != nil {
        color := self.board[row][col].?
        self->_draw(col * config.BLOCK, row * config.BLOCK, color[0], color[1], color[2], color[3])
      } else {
        self->_draw(col * config.BLOCK, row * config.BLOCK, 255, 255, 255, 255)
      }
    }
  }
}
