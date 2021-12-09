import moves

const nei4 = [[0,1], [0,-1], [1,0], [-1,0]]

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.map(s => s.split("").map(parseInt)).toMatrix

  var cs: seq[int]
  for p, v in input:
    let b = nei4.map(d => p+d).
      filter(p => input.haskey(p)).
      map(p => input[p] > v).
      fold((a,b) => a and b)
    if b:
      var cnt = 0
      var visited = initMatrix[bool](input.shape)
      bfsearch(p) do (p: MatrixKey) -> seq[MatrixKey]:
        if visited[p]:
          return 
        visited[p] = true
        cnt += 1
        return nei4.map(d => p+d).filter(p => input.hasKey(p) and not visited[p] and input[p] < 9)
      cs.add cnt
  cs.sort()
  echo cs.last(3).prod

when isMainModule:
  main("day9_sample_1.txt")
  main("day9_input.txt")
  