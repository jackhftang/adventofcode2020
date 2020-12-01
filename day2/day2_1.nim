import ../common

# const inputFilename = "sample.txt"
const inputFilename = "input.txt"
const input = staticRead(inputFilename).strip().split("\n").mapIt(parseInt(it))

# ----

proc main() =
  let a = input
  

when isMainModule:
  main()