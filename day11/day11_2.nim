import ../common

const inputFilename = "day11_input.txt"
# const inputFilename = "day11_sample1.txt"
# const inputFilename = "day11_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

const directions = [
  [-1,-1],
  [-1,0],
  [-1,1],
  [0,-1],
  [0,1],
  [1,-1],
  [1,0],
  [1,1],
]

proc next(m: seq[seq[char]]): seq[seq[char]] =
  let isValid = proc(xs: seq[int]): bool =
    if xs[0] < 0 or xs[0] > m.high: return false
    if xs[1] < 0 or xs[1] > m[0].high: return false
    return true

  for i in 0 .. m.high:
    var row = newSeq[char](m[0].len)
    for j in 0 .. m[0].high:
      let c = m[i][j]

      var n = 0
      for dir in directions:
        var pos = [i,j] + dir
        while isValid(pos):
          let c = m[pos[0]][pos[1]]
          if c == '#':
            n += 1
            break
          if c == 'L':
            break
          pos = pos + dir
        
      if c == 'L' and n == 0:
        row[j] = '#'
      elif c == '#' and n >= 5:
        row[j] = 'L'
      else:
        row[j] = c

    result.add row

proc main() =
  var input = readFile(inputFilePath).strip.split("\n").map(line => line.toSeq())

  var v = input
  while true:
    let v2 = next(v)
    echo v2.map(x => x.join("")).join("\n")
    echo " "
    if v == v2:
      break
    v = v2

  var cnt = 0
  for row in v:
    for c in row:
      if c == '#':
        cnt += 1
  echo cnt

# ----

proc next2(m: seq[seq[char]]): seq[seq[char]] =
  result = newSeqWith(m.len, newSeq[char](m[0].len))
  
  forProd i,j in m.slice, m[0].slice:
    let p = [i,j]

    var n = 0
    for dp in nei8:
      var p2 = p + dp
      while m.hasKey(p2):
        let c = m[p2]
        if c == '#':
          n += 1
          break
        if c == 'L':
          break
        p2 = p2 + dp

    let c = m[p]
    result[p] =
      if c == 'L' and n == 0: '#'
      elif c == '#' and n >= 5: 'L'
      else: c

proc main2() =
  var input = readFile(inputFilePath).strip.split("\n").map(line => line.toSeq())

  var v = input
  while true:
    let v2 = next2(v)
    if v == v2: break
    v = v2

  echo v.map(x => x.count('#')).sum

when isMainModule:
  # main()
  main2()