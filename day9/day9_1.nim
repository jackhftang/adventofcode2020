import moves

const nei4 = [[0,1], [0,-1], [1,0], [-1,0]]

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.map(s => s.split("").map(parseInt)).toMatrix

  var s = 0
  for p, v in input:
    let b = nei4.
      map(d => p+d).
      filter(p => input.hasKey(p)).
      map(p => input[p] > v).
      fold((a,b) => a and b)
    if b:
      s += v+1
  echo s

when isMainModule:
  main("day9_sample_1.txt")
  main("day9_input.txt")  
  