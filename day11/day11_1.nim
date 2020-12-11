import ../common

const inputFilename = "day11_input.txt"
# const inputFilename = "day11_sample1.txt"
# const inputFilename = "day11_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc next(m: seq[seq[char]]): seq[seq[char]] =
  for i in 0 .. m.high:
    var row = newSeq[char](m[0].len)
    for j in 0 .. m[0].high:
      let c = m[i][j]

      var n = 0
      for k in -1..1:
        for l in -1..1:
          if k == 0 and l == 0: continue
          let i2 = i+k
          let j2 = j+l
          if i2 < 0 or i2 > m.high: continue
          if j2 < 0 or j2 > m[0].high: continue
          if m[i2][j2] == '#':
            n += 1

      if c == 'L' and n == 0:
        row[j] = '#'
      elif c == '#' and n >= 4:
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
  forProd i, j in m.slice, m[0].slice:
    
    var n = 0
    forProd k, l in i-1..i+1, j-1..j+1:
      if k == i and l == j: continue
      if k notin m.slice: continue
      if l notin m[0].slice: continue
      if m[k][l] == '#':
        n += 1

    let c = m[i][j]
    result[i][j] = 
      if c == 'L' and n == 0: '#'
      elif c == '#' and n >= 4: 'L'
      else: c

proc main2() =
  var input = readFile(inputFilePath).strip.split("\n").map(line => line.toSeq())
  var v = input
  while true:
    let v2 = next2(v)
    if v == v2:
      break
    v = v2 

  echo v.map(r => r.count('#')).sum()

when isMainModule:
  main()
  main2()