import ../common

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.mapIt(it.split(" "))

  var x, y: int
  for cs in input:
    let n = parseInt cs[1]
    case cs[0]:
    of "forward": x += n
    of "down": y += n
    of "up": y -= n
    echo x, " ", y
  echo x * y
  

when isMainModule:
  main("day2_input.txt")
  # main("day2_sample1.txt")