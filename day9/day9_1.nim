import moves

const nei4 = [[0,1], [0,-1], [1,0], [-1,0]]

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.map(s => s.split("").map(parseInt))

  var s = 0
  forProd i, j in input.bound, input[0].bound:
    let p = [i,j]
    let v = input[p]
    let nei = nei4.map(d => p+d).filter(p => (p[0] in input.bound and p[1] in input[0].bound)).map(p => input[p])
    if nei.all(x => x > v):
      s += v+1
  echo s

when isMainModule:
  main("day9_sample_1.txt")
  main("day9_input.txt")  
  