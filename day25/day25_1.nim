import ../common

const modulo = 20201227

proc findLoopSize(n: int): int =
  var m = 1
  while m != n:
    if result mod 10000 == 0:
      echo result
    m = 7 * m mod modulo
    result += 1
  echo fmt"findLoopSize({n})=", result

proc main(inputFilename: string) =
  let input = readFile(currentSourcePath.parentDir / inputFilename).strip.splitLines.map(parseInt)
  echo input
  let sizes = input.mapIt(findLoopSize(it))
  echo modpow(7, sizes.prod, modulo)

when isMainModule:
  main("day25_input.txt")
  # main("day25_sample1.txt")