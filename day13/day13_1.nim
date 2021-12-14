import moves

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.split("\n\n")
  
  var ps: seq[(int, int)]
  for p in input[0].splitLines:
    let xs = p.split(",").map(parseInt)
    ps.add (xs[0], xs[1])

  for op in input[1].splitLines():
    let xs = op.split("=")
    let n = parseInt(xs[1])
    let copy = ps
    ps.setLen(0)
    if xs[0][^1] == 'y':
      for p in copy:
        ps.add (p[0], n - abs(p[1]-n))
    elif xs[0][^1] == 'x':
      for p in copy:
        ps.add (n - abs(p[0]-n), p[1])
    else:
      abort(xs[0])
    ps = ps.deduplicate()

  echo ps.sorted()
  echo ps.len

  var mat = zeros(char, ps.unzip[0].max+1, ps.unzip[1].max+1)
  forProd i, j in mat.bound, mat[0].bound:
    mat[i][j] = ' '
  for p in ps:
    mat[p[0]][p[1]] = '#' 
  echo mat.toMatrix.tr().rowseq.map(x => x.join()).join("\n")

when isMainModule:
  main("day13_sample_1.txt")
  main("day13_input.txt")  
  