import ../common

const inputFilename = "day8_input.txt"
# const inputFilename = "day8_sample.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc main() =
  let input = readFile(inputFilePath).strip.split("\n").map(s => s.split(" "))
  var t = initHashSet[int]()
  var i = 0
  var acc = 0
  while true:
    echo i, ' ', acc
    if i == input.len:
      break
    let inst = input[i]
    if i in t: break
    t.incl i
    case inst[0]:
    of "acc":
      acc += parseInt(inst[1])
      i += 1
    of "jmp":
      i += parseInt(inst[1])
    of "nop": 
      i += 1
    else: abort(input)
  
  echo acc

when isMainModule:
  main()