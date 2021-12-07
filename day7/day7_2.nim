import ../common

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.split(",").map(parseInt)
  # O(n^2)
  echo arange(0, max(input)).map(y => input.map(x => abs(x-y)*(abs(x-y)+1) div 2).sum).min
  
proc main2(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.split(",").map(parseInt)

  let m = input.sum / input.len
  # O(2*n)
  let x = input.map(x => (abs(x.float-m), x)).min()[1]
  # O(2*n)
  echo input.map(y => abs(x-y)*(abs(x-y)+1) div 2).sum

when isMainModule:
  # main("day7_sample1.txt")
  main("day7_input.txt")  
  main2("day7_input.txt")  
