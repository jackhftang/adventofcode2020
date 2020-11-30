import ../common

# const inputFilename = "test.txt"
const inputFilename = "input.txt"
const input = staticRead(inputFilename).strip().split("\n").mapIt(parseInt(it))

# ----

proc main() =
  let a = input
  

while isMainModule:
  main()