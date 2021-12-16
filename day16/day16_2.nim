import moves


proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  let translation = {
    "0": [0, 0, 0, 0],
    "1": [0, 0, 0, 1],
    "2": [0, 0, 1, 0],
    "3": [0, 0, 1, 1],
    "4": [0, 1, 0, 0],
    "5": [0, 1, 0, 1],
    "6": [0, 1, 1, 0],
    "7": [0, 1, 1, 1],
    "8": [1, 0, 0, 0],
    "9": [1, 0, 0, 1],
    "A": [1, 0, 1, 0],
    "B": [1, 0, 1, 1],
    "C": [1, 1, 0, 0],
    "D": [1, 1, 0, 1],
    "E": [1, 1, 1, 0],
    "F": [1, 1, 1, 1],
  }.toTable
  let ss = rawInput.split("")
  var input: seq[int]
  for c in ss:  
    for xs in translation[c]: 
      input.add xs 

  # input = "110100101111111000101000".split("").map(parseInt)
  # input = "00111000000000000110111101000101001010010001001000000000".split("").map(parseInt)
  # echo input
  var ans1 = 0
  proc parse(i: var int): int =
    # echo fmt"parse({i})"
    let ver = input[i..i+2].reversed.fromDigits(2)
    let id = input[i+3..i+5].reversed.fromDigits(2)
    # echo "ver=", ver
    # echo "id=", id
    ans1 += ver
    i += 6
    if id == 4:
      var vals: seq[int]
      while input[i] == 1:  
        vals.add input[i+1]
        vals.add input[i+2]
        vals.add input[i+3]
        vals.add input[i+4]
        i += 5
      vals.add input[i+1]
      vals.add input[i+2]
      vals.add input[i+3]
      vals.add input[i+4]
      i += 5
      # echo "val=", vals.reversed.fromDigits(2)
      let v = vals.reversed.fromDigits(2)
      echo fmt"value={v}"
      return v
    else:
      if id == 0: echo "sum"
      elif id == 1: echo "prod"
      elif id == 2: echo "min"
      elif id == 3: echo "max"
      elif id == 5: echo ">"
      elif id == 6: echo "<"
      elif id == 7: echo "=="

      var vs: seq[int]
      echo fmt"ltype={input[i]}"
      if input[i] == 0:
        i += 1
        let l = input[i..i+14].reversed.fromDigits(2)
        # echo input[i..i+14]
        # echo fmt"nbits={l} i={i}"
        # parse(input[i+15..i+15+l-1], i)
        var j = i+15
        while j < i+15+l:
          vs.add parse(j)
          
        i = j
      else:
        i += 1
        let l = input[i..i+10].reversed.fromDigits(2)
        # echo fmt"nsubpack={l}"
        var j = i+11
        for _ in 1 .. l:
          vs.add parse(j)
        i = j
      if id == 0: return vs.sum
      elif id == 1: return vs.prod
      elif id == 2: return vs.min
      elif id == 3: return vs.max
      elif id == 5: return if vs[0] > vs[1]: 1 else: 0
      elif id == 6: return if vs[0] < vs[1]: 1 else: 0
      elif id == 7: return if vs[0] == vs[1]: 1 else: 0
      else: abort(fmt"id={id}")

  var i = 0;
  # echo parse(i)
  while i < input.len:
    try:
      echo parse(i)
    except:
      break

  # echo ans1
  echo "-----------------------------"
    

when isMainModule:
  # main("day16_sample_5.txt")
  # main("day16_sample_6.txt")
  # main("day16_sample_7.txt")
  # main("day16_sample_8.txt")
  # main("day16_sample_9.txt")
  # main("day16_sample_10.txt")
  # main("day16_sample_11.txt")
  # main("day16_sample_12.txt")
  main("day16_input.txt")  
  