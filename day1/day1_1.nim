import ../common

# const inputFilename = "sample.txt"
const inputFilename = "input.txt"
const input = staticRead(inputFilename).strip().split("\n").mapIt(parseInt(it))

# ----

proc main() =
  for i in 0 ..< input.len:
    for j in i+1 ..< input.len:
      if input[i] + input[j] == 2020:
        echo input[i] * input[j]
  
when isMainModule:
  main()