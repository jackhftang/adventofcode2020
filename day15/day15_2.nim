import moves

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var x = rawInput.splitLines.map(s => s.split("").map(parseInt)).toMatrix

  var input = initMatrix[int](x.shape * 5)
  forProd i, j in x.bounds[0], x.bounds[1]:
    forProd n, m in 0..4, 0..4:
      input[n*x.shape[0] + i, m*x.shape[1] + j] = 1 + (x[i, j] + n + m + 8) mod 9

  var visited = initMatrix[int](input.shape)
  pqSearch( (0, [0,0]) ) do (pair: (int, MatrixKey)) -> seq[(int, MatrixKey)]:
    let cost = pair[0]
    let p = pair[1]
    if p == input.shape - [1,1]:
      echo cost
      return 
    for dp in [[0,1],[0,-1],[1,0],[-1,0]]:
      let p2 = dp+p
      if input.haskey(p2) and visited[p2] == 0:
        result.add (cost + input[p2], p2)
        visited[p2] = 1

when isMainModule:
  main("day15_sample_1.txt")
  main("day15_input.txt")  
  