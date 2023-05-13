package game

import "core:c"
import "../config"
import sdl "vendor:sdl2"

import "core:fmt"


DrawMixin :: struct {
  _draw:   proc(self: ^DrawMixin, x: c.int, y: c.int, r: u8, g: u8, b: u8, a: u8),
  variant: union {
    ^Board,
  },
}


_draw :: proc(self: ^DrawMixin, x: c.int, y: c.int, r: u8, g: u8, b: u8, a: u8) {
  self, ok := self.variant.(^Board)

  if !ok {
    fmt.eprintln("Not a valid ^DrawinMixin type")
    return
  }

  sdl.SetRenderDrawColor(self.renderer, r, g, b, a)
  sdl.RenderFillRect(self.renderer, &{x = x, y = y, w = config.BLOCK, h = config.BLOCK})
  sdl.SetRenderDrawColor(self.renderer, 0x00, 0x00, 0x00, 0xFF)
  sdl.RenderDrawRect(self.renderer, &{x = x, y = y, w = config.BLOCK, h = config.BLOCK})
}
