import ../common

proc main(inputFilename: string) =
  let input = readFile(currentSourcePath.parentDir / inputFilename).strip.toSeq.mapit(parseInt($it))
  
  var lookup: Table[int, SinglyLinkedNode[int]]
  var head = newSinglyLinkedNode[int](input[0])
  head.next = head
  lookup[input[0]] = head

  let highest = 1_000_000

  var cur = head
  forSum x in input[1..^1], 10..highest:
    let n = newSinglyLinkedNode[int](x)
    lookup[x] = n
    cur.next = n
    n.next = head
    cur = n  

  cur = head
  for i in 1..10_000_000:
    # next 3 values
    var buf: seq[int]
    var d = cur
    for j in 1..3:
      d = d.next
      buf.add d.value
    
    # find next dest
    var t = cur.value - 1
    if t == 0: t = highest
    while t in buf: 
      t = t - 1
      if t == 0: t = highest

    # next 
    var e = lookup[t]
    let h = d.next
    d.next = e.next
    e.next = cur.next
    cur.next = h

    cur = cur.next
  
  while cur.value != 1:
    cur = cur.next
  
  echo cur.next.value * cur.next.next.value

  
when isMainModule:
  main("day23_input.txt")
  # main("day23_sample1.txt")