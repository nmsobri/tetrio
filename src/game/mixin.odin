package game

import "core:c"
import "../config"
import sdl "vendor:sdl2"

import "core:fmt"

DrawMixin :: struct {
  _draw:              proc(self: ^DrawMixin, x: c.int, y: c.int, r: u8, g: u8, b: u8, a: u8),
  draw_mixin_variant: union {
    ^Board,
    ^Piece,
  },
}


_draw :: proc(d: ^DrawMixin, x: c.int, y: c.int, r: u8, g: u8, b: u8, a: u8) {
  switch entity in d.draw_mixin_variant {
  case ^Board:
    self := d.draw_mixin_variant.(^Board)
    sdl.SetRenderDrawColor(self.renderer, r, g, b, a)
    sdl.RenderFillRect(self.renderer, &{x = x, y = y, w = config.BLOCK, h = config.BLOCK})
    sdl.SetRenderDrawColor(self.renderer, 0x00, 0x00, 0x00, 0xFF)
    sdl.RenderDrawRect(self.renderer, &{x = x, y = y, w = config.BLOCK, h = config.BLOCK})

  case ^Piece:
    self := d.draw_mixin_variant.(^Piece)
    sdl.SetRenderDrawColor(self.renderer, r, g, b, a)
    sdl.RenderFillRect(self.renderer, &{x = x, y = y, w = config.BLOCK, h = config.BLOCK})
    sdl.SetRenderDrawColor(self.renderer, 0x00, 0x00, 0x00, 0xFF)
    sdl.RenderDrawRect(self.renderer, &{x = x, y = y, w = config.BLOCK, h = config.BLOCK})

  case:
    fmt.eprintln("Unknow DrawMixin variant")
  }

}
