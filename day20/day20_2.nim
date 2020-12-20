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
  t.map.map(s => s.join("")).join("\n")

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

proc findUpperLeftTile(tiles: seq[Tile], t1,t2,t3,t4: Table[string, seq[(int, Op)]]): Tile =
  for tile in tiles:
    if t1[tile.row1()].len == 1 and
        t2[tile.row2()].len == 2 and
        t3[tile.col1()].len == 1 and
        t4[tile.col2()].len == 2: 
      return tile

proc findBigTile(tiles: seq[Tile], t1,t2,t3,t4: Table[string, seq[(int, Op)]]): seq[seq[Tile]] =
  let tileById = tiles.indexBy(x => x.id)

  var h = sqrt(tiles.len)
  var w = h
  result = newSeqWith(h, newSeqWith(w, Tile()))
  result[0][0] = findUpperLeftTile(tiles, t1, t2, t3, t4)
  for i in 0 ..< h:
    for j in 0 ..< w:
      if i == 0 and j == 0: continue
      if j == 0:
        let upperTile = result[i-1][j]
        let cands = t1[upperTile.row2()].filter(x => x[0] != upperTile.id)
        assert cands.len == 1
        let (id, op) = cands[0]
        result[i][j] = tileById[id].apply(op)
      else:
        let leftTile = result[i][j-1]
        let cands = t3[leftTile.col2()].filter(x => x[0] != leftTile.id)
        assert cands.len == 1
        let (id, op) = cands[0]
        result[i][j] = tileById[id].apply(op)

proc trim(m: seq[seq[Tile]]): Tile =
  var map: seq[seq[char]]
  for row in m:
    for i in 1 ..< row[0].map.len-1:
      var line: seq[char]
      for t in row:
        for j in 1 ..< row[0].map[0].len-1:
          line.add t.map[i][j]
      map.add line
  result = Tile(id: -1, map: map)
        
proc main2() =
  let input = readFile(inputFilePath).strip.split("\n\n").map(parse)
  let pattern = [
    "                  # ",
    "#    ##    ##    ###",
    " #  #  #  #  #  #   "
  ].map(line => line.toSeq)

  # pattern -> tileId + Op
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

  let bigTile = findBigTile(input, row1Table, row2Table, col1Table, col2Table).trim()

  # find sea monsters
  let sharps = pattern.map(x => x.count('#')).sum
  var ans = bigTile.map.map(row => row.count('#')).sum
  forProd r, hf, vf in 0..1, [false, true], [false, true]:
    let op = Op(rotate: r, hflip: hf, vflip: vf)
    let t = bigTile.apply(op)
    let m = t.map

    forProd i, j in m.slice, m[0].slice:
      block match:
        forProd k, l in pattern.slice, pattern[0].slice:
          let y = i + k
          let x = j + l
          if y notin m.slice or x notin m[0].slice:
            break match
          if pattern[k][l] == '#' and m[y][x] != '#':
            break match
        # found
        ans -= sharps

  echo ans


when isMainModule:
  main2()