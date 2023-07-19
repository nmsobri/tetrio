package game
import "../config"

T :: true
F :: false

Layout :: [4][4]bool
Colors: [7][3]u8 = {{49, 199, 239}, {247, 211, 8}, {173, 77, 156}, {90, 101, 173}, {239, 121, 33}, {66, 182, 66}, {239, 32, 41}}

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
    color = Colors[0],
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
    color = Colors[0],
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
    color = Colors[0],
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
    color = Colors[0],
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
    color = Colors[0],
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
    color = Colors[0],
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
    color = Colors[0],
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

randomTetromino :: proc() -> Tetromino {
  tetromino := Tetrominoes[randomNumber()]
  tetromino.color = Colors[randomNumber()]
  return tetromino
}
