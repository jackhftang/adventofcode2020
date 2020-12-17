import ../common

const inputFilename = "day17_input.txt"
# const inputFilename = "day17_sample1.txt"
# const inputFilename = "day17_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

type
  Space = seq[seq[seq[char]]]

var neis: seq[seq[int]]

proc `[]`(n: Space, p: seq[int]): char =
  n[p[0]][p[1]][p[2]]
  
proc `[]=`(n: var Space, p: seq[int], c: char) =
  n[p[0]][p[1]][p[2]] = c

proc next(n: Space): Space =
  result = newSeqWith(n.len+2, newSeqWith(n[0].len+2, newSeqWith(n[0][0].len + 2, '.')))

  proc isValid(n: Space, p: seq[int]): bool =
    p[0] in n.slice and p[1] in n[0].slice and p[2] in n[0][0].slice

  forProd i, j, k in result.slice, result[0].slice, result[0][0].slice:
    let p = @[i,j,k]
    let p0 = p - [1,1,1]

    var cnt = 0
    for nei in neis:
      let p2 = p0 + nei
      if n.isValid(p2) and n[p2] == '#':
        cnt.inc
    # echo "cnt=", cnt

    if n.isValid(p0) and n[p0] == '#':
      if cnt in [2,3]:
        result[p] = '#'
      else:
        result[p] = '.'
    else:
      if cnt == 3:
        result[p] = '#'
      else:
        result[p] = '.'
    
proc main() =
  var input = readFile(inputFilePath).strip.split("\n").map(s => s.toSeq)
  # echo input
  var s = @[input]
  for i in 1..6:
    # echo s
    s = next(s)
  # echo s
  echo s.map(s => s.map(x => x.count('#') ).sum ).sum

when isMainModule:
  forProd i, j, k in [-1,0,1], [-1,0,1], [-1,0,1]:
    if (i,j,k) == (0,0,0): continue
    neis.add @[i,j,k]
  main()