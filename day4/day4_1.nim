import moves

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines
  let xs = input[0].split(",").map(s => parseInt(s))
  var ys: seq[seq[seq[int]]]
  for ws in input[1..^1].chunked(6):
    ys.add ws[1..^1].map(it => it.strip.split(" ").filter(it => it.len != 0).map(parseInt))

  let n = ys.len
  var marks = zeros(int, n, 5, 5)
  for x in xs:
    # echo "x=", x
    forProd i, j, k in 0 ..< n, 0..4, 0..4:
      if ys[i][j][k] == x:
        marks[i][j][k] = 1
    forProd i, j in 0 ..< n, 0..4:
      let b1 = arange(5).map(it => marks[i][j][it]).sum == 5 
      let b2 = arange(5).map(it => marks[i][it][j]).sum == 5
      if b1 or b2:
        var s = 0
        forProd j, k in 0..4, 0..4:
          if marks[i][j][k] == 0:
            s += ys[i][j][k]
        echo x * s
        return

when isMainModule:
  main("day4_sample1.txt")
  main("day4_input.txt")