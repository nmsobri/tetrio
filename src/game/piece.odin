package game

import "../config"
import "core:math/rand"
import sdl "vendor:sdl2"
import "vendor:sdl2/mixer"
import "core:fmt"

Entity :: union {
  ^Board,
  ^Piece,
}


View :: enum {
  PlayViewport,
  TetrominoViewport,
}


Vacant :: [3]u8{255, 255, 255}

FrameCount := 0
SomeRowFull := false
NextPiece: Maybe(^Piece) = nil

Piece :: struct {
  hardDrop:        proc(self: ^Piece, board: ^Board, elements: ^map[string]Entity, drop: ^mixer.Chunk, clear: ^mixer.Chunk) -> bool,
  moveDown:        proc(self: ^Piece, board: ^Board, elements: ^map[string]Entity, drop: ^mixer.Chunk, clear: ^mixer.Chunk) -> bool,
  moveRight:       proc(self: ^Piece, board: ^Board),
  moveLeft:        proc(self: ^Piece, board: ^Board),
  rotate:          proc(self: ^Piece, board: ^Board),
  lock:            proc(self: ^Piece, board: ^Board, clear: ^mixer.Chunk) -> bool,
  remove:          proc(self: ^Piece, board: ^Board, clear: ^mixer.Chunk),
  collision:       proc(self: ^Piece, board: ^Board, x: i32, y: i32, layout: Layout) -> bool,
  using mixin:     DrawMixin,
  using interface: DrawInterface,
  x:               i32,
  y:               i32,
  renderer:        ^sdl.Renderer,
  tetromino:       Tetromino,
  tetromino_index: u32,
  layout:          Layout,
  score:           ^u32,
  internal_score:  ^u32,
  cap_score:       ^u32,
  line:            ^u32,
  cooldown_timer:  ^u32,
  level:           ^u32,
  pre_left:        bool,
  pre_right:       bool,
}

Piece_init :: proc(renderer: ^sdl.Renderer, x: i32, y: i32, tetromino: Tetromino, score: ^u32, internal_score: ^u32, cap_score: ^u32, level: ^u32, line: ^u32, cooldown_timer: ^u32) -> ^Piece {
  piece := new(Piece)

  piece.x = x
  piece.y = y
  piece.tetromino_index = 0
  piece.renderer = renderer
  piece.tetromino = tetromino
  piece.layout = tetromino.layout[0]
  piece.score = score
  piece.line = line
  piece.pre_left = false
  piece.pre_right = false
  piece.internal_score = internal_score
  piece.cap_score = cap_score
  piece.level = level
  piece.cooldown_timer = cooldown_timer

  piece.mixin = {
    _draw              = _draw,
    draw_mixin_variant = piece,
  }

  piece.interface = {
    draw                   = piece_draw,
    draw_interface_variant = piece,
  }

  piece.hardDrop = _hardDrop
  piece.moveDown = _moveDown
  piece.moveRight = _moveRight
  piece.moveLeft = _moveLeft
  piece.rotate = _rotate
  piece.lock = _lock
  piece.remove = _remove
  piece.collision = _collision

  return piece
}

randomNumber :: proc() -> u32 {
  random_number := cast(u32)rand.uint64() % len(Tetrominoes)
  return random_number
}


randomPiece :: proc(renderer: ^sdl.Renderer, score: ^u32, internal_score: ^u32, cap_score: ^u32, level: ^u32, line: ^u32, cooldown_timer: ^u32) -> ^Piece {
  NextPiece = Piece_init(renderer, 0, 0, randomTetromino(), score, internal_score, cap_score, level, line, cooldown_timer)
  return Piece_init(renderer, 3, -3, randomTetromino(), score, internal_score, cap_score, level, line, cooldown_timer)
}


piece_draw :: proc(self: ^DrawInterface, v: View) {
  self, ok := self.draw_interface_variant.(^Piece)
  color := self.tetromino.color

  for row: i32 = 0; row < len(self.layout); row += 1 {

    for col: i32 = 0; col < len(self.layout[0]); col += 1 {

      if self.layout[row][col] {

        if v == .PlayViewport {
          self->_draw((self.x + col) * config.BLOCK, (self.y + row) * config.BLOCK, color[0], color[1], color[2], 255)
        } else {
          x: i32 = cast(i32)((config.VIEWPORT_INFO_WIDTH - self.tetromino.width) / 2)
          y: i32 = cast(i32)((config.TetrominoViewport.h - cast(i32)self.tetromino.height) / 2)
          self->_draw(x + (col * config.BLOCK), (y - cast(i32)(self.tetromino.yoffset * config.BLOCK)) + (row * config.BLOCK), color[0], color[1], color[2], 255)
        }

      }
    }
  }
}


drawRandomPiece :: proc(renderer: ^sdl.Renderer, view: View) {
  if NextPiece == nil {
    dummy: u32 = 0
    NextPiece = Piece_init(renderer, 0, 0, randomTetromino(), &dummy, &dummy, &dummy, &dummy, &dummy, &dummy)
  }

  NextPiece.?->draw(view)
}


_hardDrop :: proc(self: ^Piece, board: ^Board, elements: ^map[string]Entity, drop: ^mixer.Chunk, clear: ^mixer.Chunk) -> bool {
  for self->collision(board, 0, 1, self.layout) == false {
    self.y += 1
  }

  mixer.PlayChannel(-1, drop, 0)

  if self->lock(board, clear) == false {
    return false
  }

  // Reset piece position for play viewport
  NextPiece.?.x = 3
  NextPiece.?.y = -3

  elements^["piece"] = NextPiece.?
  NextPiece = Piece_init(self.renderer, 0, 0, randomTetromino(), self.score, self.internal_score, self.cap_score, self.level, self.line, self.cooldown_timer)
  return true
}


_moveDown :: proc(self: ^Piece, board: ^Board, elements: ^map[string]Entity, drop: ^mixer.Chunk, clear: ^mixer.Chunk) -> bool {
  is_next_collide := false

  if self->collision(board, 0, 2, self.layout) {
    is_next_collide = true
  }

  if !self->collision(board, 0, 1, self.layout) {
    self.y += 1

    if self.pre_left {
      self->moveLeft(board)
      self.pre_left = false
    }

    if self.pre_right {
      self->moveRight(board)
      self.pre_right = false
    }

    if is_next_collide {
      // Play sound effect
      mixer.PlayChannel(-1, drop, 0)
      // _ = c.Mix_PlayChannel(-1, clear, 0);
    }
  }

  if is_next_collide {
    // We lock the piece and generate a new one
    if self->lock(board, clear) == false {
      return false
    }

    // Reset piece position for play viewport
    NextPiece.?.x = 3
    NextPiece.?.y = -3

    elements^["piece"] = NextPiece.?
    NextPiece = Piece_init(self.renderer, 0, 0, randomTetromino(), self.score, self.internal_score, self.cap_score, self.level, self.line, self.cooldown_timer)
  }

  return true
}


_moveRight :: proc(self: ^Piece, board: ^Board) {
  if !self->collision(board, 1, 0, self.layout) {
    self.x += 1
    self->draw(View.PlayViewport)
  } else {
    self.pre_right = true
  }
}


_moveLeft :: proc(self: ^Piece, board: ^Board) {
  if !self->collision(board, -1, 0, self.layout) {
    self.x -= 1
    self->draw(View.PlayViewport)
  } else {
    self.pre_left = true
  }
}


_rotate :: proc(self: ^Piece, board: ^Board) {
  next_layout := self.tetromino.layout[(self.tetromino_index + 1) % len(self.tetromino.layout)]
  kick: i32 = 0

  // Check if rotation at current position cause blocking, if yes, then kick it one block to left/right based on its x position
  if self->collision(board, 0, 0, next_layout) {
    if self.x > config.COL / 2 {
      // It's the right wall
      kick = -1 // We need to move the piece to the left
    } else {
      // It's the left wall
      kick = 1 // We need to move the piece to the right
    }
  }

  if !self->collision(board, kick, 0, next_layout) {
    self.x += kick
    self.tetromino_index = (self.tetromino_index + 1) % len(self.tetromino.layout) // (0+1)%4 => 1
    self.layout = self.tetromino.layout[self.tetromino_index]
    self->draw(View.PlayViewport)
  }
}


_collision :: proc(self: ^Piece, board: ^Board, x: i32, y: i32, layout: Layout) -> bool {
  for row: i32 = 0; row < len(layout); row += 1 {

    for col: i32 = 0; col < len(layout[0]); col += 1 {
      // If the square is empty, we skip it
      if !layout[row][col] {
        continue
      }

      // Coordinates of the tetromino after movement
      new_x := self.x + col + x
      new_y := self.y + row + y

      // Conditions, collided with the viewport
      if new_x < 0 || new_x >= config.COL || new_y >= config.ROW {
        return true
      }

      // Skip newY < 0; board[-1] will crush our game
      if new_y < 0 {
        continue
      }

      // check if there is a locked tetromino alrady in place
      if board.board[new_y][new_x] != nil {
        return true
      }
    }
  }

  return false
}


_lock :: proc(self: ^Piece, board: ^Board, clear: ^mixer.Chunk) -> bool {
  should_return := false

  outer: for row: i32 = 0; row < len(self.layout); row += 1 {

    for col: i32 = 0; col < len(self.layout[0]); col += 1 {
      // We skip the vacant squares
      if !self.layout[row][col] {
        continue
      }

      // Pieces to lock on top = game over
      if self.y + row < 0 {
        // Game over
        // dont immediately return, it will cause row 0, always vacant,
        // eventhough there is piece lock on that row
        should_return = true
        continue outer
      }

      // We lock the piece
      board.board[self.y + row][self.x + col] = [4]u8{self.tetromino.color[0], self.tetromino.color[1], self.tetromino.color[2], 255}
    }
  }

  if should_return do return false

  // Check if there is full row, if its, remove full row
  self->remove(board, clear)
  return true
}


_remove :: proc(self: ^Piece, board: ^Board, clear: ^mixer.Chunk) {
  line: u32 = 0

  // Remove full rows
  for row: u8 = 0; row < config.ROW; row += 1 {
    is_row_full := true

    for col := 0; col < config.COL; col += 1 {
      if board.board[row][col] == nil {
        is_row_full = false
        break
      }
    }

    if is_row_full {
      mixer.PlayChannel(-1, clear, 0)

      SomeRowFull = true
      // If the row is full, we move down all the rows above it
      line += 1

      // Change color of rows that need to be remove
      for _col := 0; _col < config.COL; _col += 1 {
        board.board[row][_col] = [4]u8{100, 100, 100, 255}
      }

      // Mark the rows as full thus for removal
      board.full_rows[row] = true
    }
  }

  if SomeRowFull {
    self.score^ += line * 10 + ((line - 1) * 5)
    self.internal_score^ += line * 10 + ((line - 1) * 5)
    self.line^ += line

    if self.internal_score^ >= self.cap_score^ {
      self.level^ += 1
      self.internal_score^ -= self.cap_score^

      // cap cool down to 200ms
      if !((self.cooldown_timer^ - 200) < 200) {
        self.cooldown_timer^ -= 200
      }
    }

  }

}


Piece_eraseLine :: proc(board: ^Board) {
  if SomeRowFull {
    FrameCount += 1
  }

  if FrameCount >= 10 {
    board.animation_frame += 1

    if board.animation_frame <= 4 {
      for row, i in board.full_rows {
        if row {
          // Animate color of rows that need to be remove

          for col: u8 = 0; col < config.COL; col += 1 {
            if board.animation_frame % 2 == 0 {
              board.board[i][col] = [4]u8{100, 100, 100, 255}
            } else {
              board.board[i][col] = [4]u8{150, 150, 150, 255}
            }
          }
        }
      }
    } else {
      // Remove row
      for row, i in board.full_rows {
        if row {
          top_row := i
          for top_row >= 1 {

            for col: u8 = 0; col < config.COL; col += 1 {
              board.board[top_row][col] = board.board[top_row - 1][col]
            }
            top_row -= 1
          }


          // this is the very first row, so there is no more row above it, so just vacant the entire row

          for col: u8 = 0; col < config.COL; col += 1 {
            board.board[top_row][col] = nil
          }

          board.full_rows[i] = false // Mark as not full
        }
      }

      SomeRowFull = false
      board.animation_frame = 0
    }

    FrameCount = 0
  }
}
