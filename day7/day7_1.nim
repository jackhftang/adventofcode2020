import ../common

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.split(",").map(parseInt)
  # O(n^2)
  echo arange(0, max(input)).map(y => input.map(x => abs(x-y)).sum).min

proc main2(inputFilename: string) = 
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.split(",").map(parseInt)
  # O(n*log(n))
  let m = input.sorted()[input.len div 2]
  # O(n)
  echo input.map(x => abs(x-m)).sum

when isMainModule:
  # main("day7_sample1.txt")
  main("day7_input.txt")  
  main2("day7_input.txt")  
