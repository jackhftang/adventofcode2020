import ../common

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.map(s => s.split(" | ").map(ss => ss.strip.split(" ")))

  var cnt = 0
  for xs in input:
    for x in xs[1]:
      if x.len in [2, 4, 3, 7]:
        cnt += 1
  echo cnt  

when isMainModule:
  main("day8_sample1.txt")
  main("day8_input.txt")  
