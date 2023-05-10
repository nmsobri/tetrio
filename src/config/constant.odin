package config

import sdl "vendor:sdl2"

ROW :: 20
COL :: 10
BLOCK :: 30
GAME_NAME :: "Tetrio"

WINDOW_WIDTH :: BLOCK * 18
WINDOW_HEIGHT :: BLOCK * 22

WINDOW_X :: sdl.WINDOWPOS_CENTERED
WINDOW_Y :: sdl.WINDOWPOS_CENTERED
WINDOW_FLAGS :: sdl.WindowFlags{.SHOWN}

VIEWPORT_INFO_WIDTH :: BLOCK * 5
VIEWPORT_INFO_HEIGHT :: BLOCK * 4

FPS :: 60
TICKS_PER_FRAME: f64 = 1000.0 / cast(f64)FPS

LeftViewport: sdl.Rect = {
  x = 0,
  y = 0,
  w = BLOCK * 12,
  h = WINDOW_HEIGHT,
}

PlayViewport: sdl.Rect = {
  x = BLOCK,
  y = BLOCK,
  w = BLOCK * 10,
  h = BLOCK * ROW,
}

RightViewport: sdl.Rect = {
  x = BLOCK * 12,
  y = 0,
  w = BLOCK * 7,
  h = WINDOW_HEIGHT,
}

LevelViewport: sdl.Rect = {
  x = BLOCK * 12,
  y = BLOCK,
  w = VIEWPORT_INFO_WIDTH,
  h = VIEWPORT_INFO_HEIGHT,
}

ScoreViewport: sdl.Rect = {
  x = BLOCK * 12,
  y = BLOCK * 6,
  w = VIEWPORT_INFO_WIDTH,
  h = VIEWPORT_INFO_HEIGHT,
}

LineViewport: sdl.Rect = {
  x = BLOCK * 12,
  y = BLOCK * 11,
  w = VIEWPORT_INFO_WIDTH,
  h = VIEWPORT_INFO_HEIGHT,
}

TetrominoViewport: sdl.Rect = {
  x = BLOCK * 12,
  y = BLOCK * 16,
  w = VIEWPORT_INFO_WIDTH,
  h = BLOCK * 5,
}
