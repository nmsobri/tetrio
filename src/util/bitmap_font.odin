package util

import "core:c"
import "core:mem"
import "core:fmt"
import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

NUM_GLYPHS :: 127

BitmapFontInterface :: struct {
  initFontPath:       proc(self: ^BitmapFont, path: string, size: i32) -> bool,
  initFontRW:         proc(self: ^BitmapFont, font_data: []byte, size: i32) -> bool,
  calculateTextWidth: proc(self: ^BitmapFont, text: string) -> u32,
  renderText:         proc(self: ^BitmapFont, _x: c.int, _y: c.int, text: string, r: u8, g: u8, b: u8) -> bool,
  getGlyphs:          proc(self: ^BitmapFont) -> [NUM_GLYPHS]sdl.Rect,
  getGlyphHeight:     proc(self: ^BitmapFont) -> u32,
  total_font_size:    proc(self: ^BitmapFont) -> (c.int, c.int),
  close:              proc(self: ^BitmapFont),
}

BitmapFont :: struct {
  using vtable: BitmapFontInterface,
  font:         ^ttf.Font,
  texture:      ^sdl.Texture,
  renderer:     ^sdl.Renderer,
  glyphs:       [NUM_GLYPHS]sdl.Rect,
}


// Overloading this function so it doesnt matter how you
// init the Font either from memory or from file
BitmapFont_init :: proc {
  BitmapFontInitRw,
  BitmapFontInitPath,
}


BitmapFontInitPath :: proc(renderer: ^sdl.Renderer, path: string, size: i32) -> (^BitmapFont, bool) {
  if ttf.Init() < 0 {
    fmt.eprintf("SDL_ttf could not initialize! SDL_ttf Error: %s\n", ttf.GetError())
    return nil, false
  }

  bf := new(BitmapFont)
  bf.renderer = renderer

  bf.vtable = {
    initFontRW         = initFontRW,
    initFontPath       = initFontPath,
    calculateTextWidth = calculateTextWidth,
    renderText         = renderText,
    getGlyphs          = getGlyphs,
    getGlyphHeight     = getGlyphHeight,
    total_font_size    = total_font_size,
    close              = close,
  }

  bf->initFontPath(path, size)
  return bf, true
}


BitmapFontInitRw :: proc(renderer: ^sdl.Renderer, font_data: []byte, size: i32) -> (^BitmapFont, bool) {
  if ttf.Init() < 0 {
    fmt.eprintf("SDL_ttf could not initialize! SDL_ttf Error: %s\n", ttf.GetError())
    return nil, false
  }

  bf := new(BitmapFont)
  bf.renderer = renderer

  bf.vtable = {
    initFontRW         = initFontRW,
    initFontPath       = initFontPath,
    calculateTextWidth = calculateTextWidth,
    renderText         = renderText,
    getGlyphs          = getGlyphs,
    getGlyphHeight     = getGlyphHeight,
    total_font_size    = total_font_size,
    close              = close,
  }

  bf->initFontRW(font_data, size)
  return bf, true
}


@(private = "file")
initFontPath :: proc(self: ^BitmapFont, path: string, size: i32) -> bool {
  mem.set(&self.glyphs, 0, size_of(sdl.Rect) * NUM_GLYPHS)

  self.font = ttf.OpenFont(fmt.caprintf("%s", path), size)

  if self.font == nil {
    fmt.eprintf("Failed to load font! Sdl_ttf Error: %s\n", ttf.GetError())
    return false
  }

  atlas_width, atlas_height := self->total_font_size()
  atlas_surface: ^sdl.Surface

  when ODIN_ENDIAN == .Big {
    atlas_surface = sdl.CreateRGBSurface(0, atlas_width, atlas_height, 32, 0xFF000000, 0x00FF0000, 0x0000FF00, 0x000000FF)
  } else {
    atlas_surface = sdl.CreateRGBSurface(0, atlas_width, atlas_height, 32, 0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000)
  }

  defer sdl.FreeSurface(atlas_surface)

  // Set transparent surface background 
  if sdl.SetColorKey(atlas_surface, 1, sdl.MapRGBA(atlas_surface.format, 0, 0, 0, 0)) != 0 {
    fmt.eprintf("Failed to set color key for font! SDL Error: %s\n", sdl.GetError())
    return false
  }

  dest: sdl.Rect = {
    x = 0,
    y = 0,
    w = 0,
    h = 0,
  }

  i: u8 = ' '

  for i <= '~' {
    ch := cstring(raw_data([]u8{i, 0}))
    text_surface := ttf.RenderUTF8_Blended(self.font, ch, {r = 255, g = 255, b = 255, a = 255})
    defer sdl.FreeSurface(text_surface)

    if ttf.SizeUTF8(self.font, ch, &dest.w, &dest.h) != 0 {
      fmt.eprintf("Failed to get font text size! SDL_ttf Error: %s\n", ttf.GetError())
      return false
    }

    if dest.x + dest.w > atlas_width {
      dest.x = 0
      dest.y += dest.h + 1

      if dest.y + dest.h >= atlas_height {
        fmt.eprintf("Out of glyph space in %dx%d font atlas texture map.\n", atlas_width, atlas_height)
        return false
      }
    }

    if sdl.BlitSurface(text_surface, nil, atlas_surface, &dest) != 0 {
      fmt.eprintf("Failed to blit font to the surface! SDL Error: %s\n", sdl.GetError())
      return false
    }

    self.glyphs[i] = {
      x = dest.x,
      y = dest.y,
      w = dest.w,
      h = dest.h,
    }

    dest.x += dest.w // Advance the glyph position
    i += 1
  }

  self.texture = sdl.CreateTextureFromSurface(self.renderer, atlas_surface)
  return true
}


@(private = "file")
initFontRW :: proc(self: ^BitmapFont, font_data: []byte, size: i32) -> bool {
  mem.set(&self.glyphs, 0, size_of(sdl.Rect) * NUM_GLYPHS)

  rwops := sdl.RWFromMem(raw_data(font_data), cast(i32)len(font_data))
  self.font = ttf.OpenFontRW(rwops, true, size)

  if self.font == nil {
    fmt.eprintf("Failed to load font! Sdl_ttf Error: %s\n", ttf.GetError())
    return false
  }

  atlas_width, atlas_height := self->total_font_size()
  atlas_surface: ^sdl.Surface

  when ODIN_ENDIAN == .Big {
    atlas_surface = sdl.CreateRGBSurface(0, atlas_width, atlas_height, 32, 0xFF000000, 0x00FF0000, 0x0000FF00, 0x000000FF)
  } else {
    atlas_surface = sdl.CreateRGBSurface(0, atlas_width, atlas_height, 32, 0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000)
  }

  defer sdl.FreeSurface(atlas_surface)

  // Set transparent surface background 
  if sdl.SetColorKey(atlas_surface, 1, sdl.MapRGBA(atlas_surface.format, 0, 0, 0, 0)) != 0 {
    fmt.eprintf("Failed to set color key for font! SDL Error: %s\n", sdl.GetError())
    return false
  }

  dest: sdl.Rect = {
    x = 0,
    y = 0,
    w = 0,
    h = 0,
  }

  i: u8 = ' '

  for i <= '~' {
    ch := cstring(raw_data([]u8{i, 0}))
    text_surface := ttf.RenderUTF8_Blended(self.font, ch, {r = 255, g = 255, b = 255, a = 255})
    defer sdl.FreeSurface(text_surface)

    if ttf.SizeUTF8(self.font, ch, &dest.w, &dest.h) != 0 {
      fmt.eprintf("Failed to get font text size! SDL_ttf Error: %s\n", ttf.GetError())
      return false
    }

    if dest.x + dest.w > atlas_width {
      dest.x = 0
      dest.y += dest.h + 1

      if dest.y + dest.h >= atlas_height {
        fmt.eprintf("Out of glyph space in %dx%d font atlas texture map.\n", atlas_width, atlas_height)
        return false
      }
    }

    if sdl.BlitSurface(text_surface, nil, atlas_surface, &dest) != 0 {
      fmt.eprintf("Failed to blit font to the surface! SDL Error: %s\n", sdl.GetError())
      return false
    }

    self.glyphs[i] = {
      x = dest.x,
      y = dest.y,
      w = dest.w,
      h = dest.h,
    }

    dest.x += dest.w // Advance the glyph position
    i += 1
  }

  self.texture = sdl.CreateTextureFromSurface(self.renderer, atlas_surface)
  return true
}


@(private = "file")
total_font_size :: proc(self: ^BitmapFont) -> (c.int, c.int) {
  i: u8 = ' '
  font_width: c.int = 0
  font_height: c.int = 0

  total_font_width: c.int = 0
  total_font_height: c.int = 0

  for i <= '~' {
    ch := cstring(raw_data([]u8{i, 0}))

    if ttf.SizeUTF8(self.font, ch, &font_width, &font_height) != 0 {
      fmt.eprintf("Failed to get font text size! SDL_ttf Error: %s\n", ttf.GetError())
      return 0, 0
    }

    total_font_width += font_width
    total_font_height = font_height
    i += 1
  }

  return total_font_width, total_font_height
}


@(private = "file")
calculateTextWidth :: proc(self: ^BitmapFont, text: string) -> u32 {
  width: u32 = 0
  i := 0

  for i < len(text) {
    if text[i] != '\n' {
      ascii := text[i]
      width += cast(u32)self.glyphs[ascii].w
    }

    i += 1
  }

  return width
}


@(private = "file")
renderText :: proc(self: ^BitmapFont, _x: c.int, _y: c.int, text: string, r: u8, g: u8, b: u8) -> bool {
  // If the font has not been built
  if self.texture == nil do return false

  x: u32 = cast(u32)_x
  y: u32 = cast(u32)_y

  if sdl.SetTextureColorMod(self.texture, r, g, b) != 0 {
    fmt.eprintf("Failed to set texture font color! SDL Error: %s\n", sdl.GetError())
    return false
  }

  i := 0
  for i < len(text) {
    if (text[i] == '\n') {
      x = cast(u32)_x
      y += self->getGlyphHeight()
      continue
    }

    ascii := text[i]
    glyph := &self.glyphs[ascii]
    dest: sdl.Rect = {
      x = cast(c.int)x,
      y = cast(c.int)y,
      w = glyph.w,
      h = glyph.h,
    }

    if sdl.RenderCopy(self.renderer, self.texture, glyph, &dest) != 0 {
      fmt.eprintf("Failed to render texture! SDL Error: %s\n", sdl.GetError())
      return false
    }

    x += cast(u32)glyph.w
    i += 1
  }

  return true
}


@(private = "file")
getGlyphs :: proc(self: ^BitmapFont) -> [NUM_GLYPHS]sdl.Rect {
  return self.glyphs
}


@(private = "file")
getGlyphHeight :: proc(self: ^BitmapFont) -> u32 {
  // Use `A` glyph height as out baseline for all of the glyph
  return cast(u32)self.glyphs[65].h
}

@(private = "file")
close :: proc(self: ^BitmapFont) {
  ttf.Quit()
}
