import std/[sequtils, sets, deques, heapqueue, strformat, strutils, strscans,
    math, options, sugar, algorithm, random, lists, complex]
export sequtils, sets, deques, heapqueue, strformat, strscans,
    math, options, sugar, algorithm, random, lists, complex

export strutils except split

import tables except indexBy
export tables except indexBy

from os import `/`, parentDir
export `/`, parentDir

import macros

# -------------------------------------------------------------
# misc

#[
  segment7[i][j] = configuration of digits i 
     0
    1 2
     3
    4 5
     6
]#
let segment7* = [
  [1, 1, 1, 0, 1, 1, 1],
  [0, 0, 1, 0, 0, 1, 0],
  [1, 0, 1, 1, 1, 0, 1],
  [1, 0, 1, 1, 0, 1, 1],
  [0, 1, 1, 1, 0, 1, 0],
  [1, 1, 0, 1, 0, 1, 1],
  [1, 1, 0, 1, 1, 1, 1],
  [1, 0, 1, 0, 0, 1, 0],
  [1, 1, 1, 1, 1, 1, 1],
  [1, 1, 1, 1, 0, 1, 1],
]

proc `[]`*[T](m: openArray[seq[T]], p: seq[int]): T =
  assert p.len == 2
  m[p[0]][p[1]]

template foldlSeq*(xs, init, body: untyped): untyped =
  # template version of fold
  runnableExamples:
    import algorithm
    let xs = [1, 2, 3, 4]
    assert xs.cumsummed == xs.foldlList(a+b)
  type T = typeof(init)
  var result = newSeq[T](xs.len+1)
  if xs.len > 0:
    result[0] = init
    for i in 0..xs.high:
      let a {.inject.} = result[i]
      let b {.inject.} = xs[i]
      result[i+1] = body
  result

template foldlSeq*(xs, body: untyped): untyped =
  # template version of fold
  runnableExamples:
    import algorithm
    let xs = [1, 2, 3, 4]
    assert xs.cumsummed == xs.foldlList(a+b)
  type T = typeof(xs[0])
  var result = newSeq[T](xs.len)
  if xs.len > 0:
    result[0] = xs[0]
    for i in 1..xs.high:
      let a {.inject.} = result[i-1]
      let b {.inject.} = xs[i]
      result[i] = body
  result

# -------------------------------------------------------------
# geometry

const nei4* = [
  # positive toward right and bottom
  # [y, x]
  # in anti-clockwise order
  @[0, 1], # E
  @[-1, 0], # N
  @[0, -1], # W
  @[1, 0], # S
]

const nei6* = [
  # Axial Coordinates
  # positive toward right and bottom
  # [y, x]
  # in anti-clockwise order
  #    (-1,-1)  (-1, 0)
  # ( 0,-1) ( 0, 0) ( 0, 1)
  #     ( 1, 0) ( 1, 1)  
  @[0,1],
  @[-1,0],
  @[-1,-1],
  @[0,-1],
  @[1,0],
  @[1,1],
]

# product([arange(-1,2), arange(-1,2)]).filter(xs => xs.any(x => x != 0))
const nei8* = [
  # positive toward right and bottom
  # [y, x]
  # in anti-clockwise order
  @[0, 1],
  @[-1, 1],
  @[-1, 0],
  @[-1, -1],
  @[0, -1],
  @[1, -1],
  @[1, 0],
  @[1, 1],
]

