import moves

const nei4 = [[0,1], [0,-1], [1,0], [-1,0]]

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.map(s => s.split("").map(parseInt))

  var visited = zeros(bool, input.len, input[0].len)
  proc basin(i,j: int): int =
    if visited[i][j]: return 0
    visited[i][j] = true

    result = 1
    for d in nei4:
      let p = [i,j] 
      let p2 = p+d
      if p2[0] in input.bound and p2[1] in input[0].bound and not visited[p+d] and input[p2] < 9:
        result += basin(p2[0], p2[1])

  var basins: seq[int]
  forProd i, j in input.bound, input[0].bound:
    var nei: seq[int]
    for d in nei4:
      let p = [i,j] + d

      if p[0] in input.bound and p[1] in input[0].bound:
        nei.add input[p]

    let v = input[i][j]
    if nei.all(x => x > v):
      basins.add basin(i,j)
  basins.sort(Descending)
  
  echo basins[0..2].prod

when isMainModule:
  main("day9_sample_1.txt")
  main("day9_input.txt")  
  