import ../common

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines
  let xs = input[0].split(",").mapIt(parseInt(it))

  var ys: seq[seq[seq[int]]]
  for ws in input[1..^1].chunked(6):
    #echo ws
    var m = newSeqWith(5, newSeq[int](5))
    for i in 1..5:
      m[i-1] = ws[i].strip.replace("  ", " ").split(" ").mapIt(parseInt(it))
      assert m[i-1].len == 5
    ys.add m

  let n = ys.len
  var marks = zeros(int, n, 5, 5)
  var wins = initHashSet[int]()
  for x in xs:
    forProd i, j, k in 0 ..< n, 0..4, 0..4:
      if ys[i][j][k] == x:
        marks[i][j][k] = 1
    forProd i, j in 0 ..< n, 0..4:
      let b1 = arange(5).mapIt(marks[i][j][it]).sum == 5 
      let b2 = arange(5).mapIt(marks[i][it][j]).sum == 5
      if b1 or b2:
        wins.incl i
        if wins.len == n:
          var s = 0
          forProd j, k in 0..4, 0..4:
            if marks[i][j][k] == 0:
              s += ys[i][j][k]
          echo x * s
          return

when isMainModule:
  main("day4_sample1.txt")
  main("day4_input.txt")