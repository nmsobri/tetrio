package game
import "../config"

T :: true
F :: false

Layout :: [4][4]bool

Tetromino :: struct {
  name:    u8,
  color:   [3]u8,
  width:   u8,
  height:  u8,
  yoffset: u8,
  layout:  [4]Layout,
}

Tetrominoes := [?]Tetromino{
  Tetromino{
    name = 'I',
    color = {49, 199, 239},
    width = config.BLOCK * 4,
    height = config.BLOCK * 1,
    yoffset = 2,
    layout = [4]Layout{
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, F, F}, [?]bool{T, T, T, T}, [?]bool{F, F, F, F}},
      Layout{[?]bool{F, T, F, F}, [?]bool{F, T, F, F}, [?]bool{F, T, F, F}, [?]bool{F, T, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, F, F}, [?]bool{T, T, T, T}, [?]bool{F, F, F, F}},
      Layout{[?]bool{F, T, F, F}, [?]bool{F, T, F, F}, [?]bool{F, T, F, F}, [?]bool{F, T, F, F}},
    },
  },
  Tetromino{
    name = 'O',
    color = {247, 211, 8},
    width = config.BLOCK * 2,
    height = config.BLOCK * 2,
    yoffset = 2,
    layout = [4]Layout{
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, F, F}, [?]bool{T, T, F, F}, [?]bool{T, T, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, F, F}, [?]bool{T, T, F, F}, [?]bool{T, T, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, F, F}, [?]bool{T, T, F, F}, [?]bool{T, T, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, F, F}, [?]bool{T, T, F, F}, [?]bool{T, T, F, F}},
    },
  },
  Tetromino{
    name = 'T',
    color = {173, 77, 156},
    width = config.BLOCK * 3,
    height = config.BLOCK * 2,
    yoffset = 2,
    layout = [4]Layout{
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, F, F}, [?]bool{T, T, T, F}, [?]bool{F, T, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, T, F, F}, [?]bool{T, T, F, F}, [?]bool{F, T, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, T, F, F}, [?]bool{T, T, T, F}, [?]bool{F, F, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, T, F, F}, [?]bool{F, T, T, F}, [?]bool{F, T, F, F}},
    },
  },
  Tetromino{
    name = 'J',
    color = {90, 101, 173},
    width = config.BLOCK * 2,
    height = config.BLOCK * 3,
    yoffset = 1,
    layout = [4]Layout{
      Layout{[?]bool{F, F, F, F}, [?]bool{F, T, F, F}, [?]bool{F, T, F, F}, [?]bool{T, T, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{T, F, F, F}, [?]bool{T, T, T, F}, [?]bool{F, F, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, T, T, F}, [?]bool{F, T, F, F}, [?]bool{F, T, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, F, F}, [?]bool{T, T, T, F}, [?]bool{F, F, T, F}},
    },
  },
  Tetromino{
    name = 'L',
    color = {239, 121, 33},
    width = config.BLOCK * 2,
    height = config.BLOCK * 3,
    yoffset = 1,
    layout = [4]Layout{
      Layout{[?]bool{F, F, F, F}, [?]bool{T, F, F, F}, [?]bool{T, F, F, F}, [?]bool{T, T, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, F, F}, [?]bool{T, T, T, F}, [?]bool{T, F, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{T, T, F, F}, [?]bool{F, T, F, F}, [?]bool{F, T, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, T, F}, [?]bool{T, T, T, F}, [?]bool{F, F, F, F}},
    },
  },
  Tetromino{
    name = 'S',
    color = {66, 182, 66},
    width = config.BLOCK * 3,
    height = config.BLOCK * 2,
    yoffset = 2,
    layout = [4]Layout{
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, F, F}, [?]bool{F, T, T, F}, [?]bool{T, T, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{T, F, F, F}, [?]bool{T, T, F, F}, [?]bool{F, T, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, F, F}, [?]bool{F, T, T, F}, [?]bool{T, T, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{T, F, F, F}, [?]bool{T, T, F, F}, [?]bool{F, T, F, F}},
    },
  },
  Tetromino{
    name = 'Z',
    color = {239, 32, 41},
    width = config.BLOCK * 3,
    height = config.BLOCK * 2,
    yoffset = 2,
    layout = [4]Layout{
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, F, F}, [?]bool{T, T, F, F}, [?]bool{F, T, T, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, T, F}, [?]bool{F, T, T, F}, [?]bool{F, T, F, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, F, F}, [?]bool{T, T, F, F}, [?]bool{F, T, T, F}},
      Layout{[?]bool{F, F, F, F}, [?]bool{F, F, T, F}, [?]bool{F, T, T, F}, [?]bool{F, T, F, F}},
    },
  },
}
