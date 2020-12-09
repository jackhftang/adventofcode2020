import ../common

const inputFilename = "day9_input.txt"
# const inputFilename = "day9_sample1.txt"
# const inputFilename = "day9_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc main() =
  let input = readFile(inputFilePath).strip.split("\n").map(parseInt)
  for i in 25..input.high:
    block check:  
      for j in i-25..i-1:
        for k in j+1..i-1:
          if input[i] == input[j] + input[k]:
            break check
      echo i, " ", input[i]

when isMainModule:
  main()