import moves
import tables

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines
  var lis = input[0].split("").map(s => s[0]).toList
  var rules: Table[(char, char), char]
  
  for line in input[2..^1]:
    let ss = line.strip.split(" -> ")
    let xs = ss[0].strip.split("")
    rules[(xs[0][0], xs[1][0])] = ss[1][0]
  #echo rules

  10.times:
    var z = lis.head.next
    while z.hasNext and z.next.hasNext:
      # echo lis.toSeq
      let a = z.value
      let b = z.next.value
      if rules.contains (a,b):
        z.addNext(rules[(a,b)])
        z = z.next.next
      else:
        z = z.next
        
  # echo lis.toSeq
  let c = lis.toSeq.toCountTable
  echo c.largest[1] - c.smallest[1]

when isMainModule:
  main("day14_sample_1.txt")
  main("day14_input.txt")  
  