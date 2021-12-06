import ../common

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.split(",").map(parseInt).toCountTable
  
  var m = input
  for i in 1..256:
    let copy = m
    m.clear()
    for k, v in copy:
      var v = copy[k]
      if k == 0:
        m.inc(6, v)
        m.inc(8, v)
      else:
        m.inc(k-1, v)
  echo m.toseq.sum

when isMainModule:
  # main("day6_sample1.txt")
  main("day6_input.txt")  
