import moves

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.split(",").map(parseInt)
  
  var m = input
  for i in 1..80:
    let n = m.len
    for i in 0 ..< n:
      if m[i] == 0:
        m[i] = 6
        m.add 8
      else:
        m[i] -= 1
  # echo m
  echo m.len

when isMainModule:
  # main("day6_sample1.txt")
  main("day6_input.txt")  
