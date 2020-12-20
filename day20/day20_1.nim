import ../common

const inputFilename = "day20_input.txt"
# const inputFilename = "day20_sample1.txt"
# const inputFilename = "day20_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

type
  Tile = object
    id: int
    map: seq[seq[char]]

  Op = object
    rotate: int
    hflip, vflip: bool

proc parse(s: string): Tile =
  let ss = s.strip.splitLines
  let n = parseInt(ss[0][5..^2])
  let m = ss[1..^1].mapIt(it.toSeq)
  result.id = n
  result.map = m

proc `$`(t: Tile): string = 
  echo t.map.map(s => s.join("")).join("\n")

proc col(t: Tile, n: int): string =
  for i in t.map.slice:
    result.add t.map[i][n]

proc row(t: Tile, n: int): string =
  result = t.map[n].join("") 

proc col1(t: Tile): string = t.col(0)
proc col2(t: Tile): string = t.col(t.map[0].len-1)

proc row1(t: Tile): string = t.row(0)
proc row2(t: Tile): string = t.row(t.map.len-1)
  
proc rotate(t: Tile, n: int): Tile =
  let h = t.map.len
  let w = t.map[0].len
  case n mod 4:
  of 0: return t
  of 1: 
    result.id = t.id
    result.map = newSeqWith(w, newSeqWith(h, '?'))
    for i in 0 ..< w:
      for j in 0 ..< h:
        result.map[i][j] = t.map[j][w-i-1]
  else:
    return t.rotate( (n+3) mod 4 ).rotate(1)

proc hflip(t: Tile): Tile =
  let h = t.map.len
  let w = t.map[0].len
  result.id = t.id
  result.map = newSeqWith(h, newSeqWith(w, '?'))
  for i in 0 ..< h:
    for j in 0 ..< w: 
      result.map[i][j] = t.map[i][w-1-j]

proc vflip(t: Tile): Tile =
  let h = t.map.len
  let w = t.map[0].len
  result.id = t.id
  result.map = newSeqWith(h, newSeqWith(w, '?'))
  for i in 0 ..< h:
    for j in 0 ..< w: 
      result.map[i][j] = t.map[h-i-1][j]

proc apply(t: Tile, op: Op): Tile =
  result = t
  if op.hflip: result = result.hflip()
  if op.vflip: result = result.vflip()
  result = result.rotate(op.rotate)

proc main2() =
  let input = readFile(inputFilePath).strip.split("\n\n").map(parse)
  
  var row1Table = initTable[string, seq[(int, Op)]]()
  var row2Table = initTable[string, seq[(int, Op)]]()
  var col1Table = initTable[string, seq[(int, Op)]]()
  var col2Table = initTable[string, seq[(int, Op)]]()
  for tile in input:
    forProd r, hf, vf in 0..1, [false, true], [false, true]:
      let op = Op(rotate: r, hflip: hf, vflip: vf)
      let t = tile.apply(op)
      row1Table.mgetOrPut(t.row1(), @[]).add (t.id, op)
      row2Table.mgetOrPut(t.row2(), @[]).add (t.id, op)
      col1Table.mgetOrPut(t.col1(), @[]).add (t.id, op)
      col2Table.mgetOrPut(t.col2(), @[]).add (t.id, op)
      
  # the input has a special structure that make it easier
  var ans = 1
  for tile in input:
    var n = -4 
    n += row1Table[tile.row1()].len 
    n += row2Table[tile.row2()].len 
    n += col1Table[tile.col1()].len 
    n += col2Table[tile.col2()].len
    if n == 2:
      ans *= tile.id

  echo ans

when isMainModule:
  main2()