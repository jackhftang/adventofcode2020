import ../common

proc main(inputFilename: string) =
  let input = readFile(currentSourcePath.parentDir / inputFilename).strip.toSeq.mapit(parseInt($it))
  var lis: SinglyLinkedRing[int]
  for x in input: lis.append x
  echo lis

  var cur = lis.head
  for i in 1..100:
    var buf: seq[int]
    var d = cur
    for j in 1..3:
      let next = d.next
      d.next = nil
      d = next
      buf.add d.value
    cur.next = d.next
    # echo "buf=", buf
    # echo "next=", d.next.value

    var t = cur.value - 1
    if t == 0: t = 9
    while t in buf: 
      t = t - 1
      if t == 0: t = 9

    d = cur
    while d.value != t:
      d = d.next

    for i in 0..2:
      var n = newSinglyLinkedNode[int](buf[2-i])
      n.next = d.next
      d.next = n

    cur = cur.next
  
  while cur.value != 1:
    cur = cur.next
  cur = cur.next

  var ans = ""
  for i in 1..8:
    ans.add $cur.value
    cur = cur.next
  echo ans

  
when isMainModule:
  main("day23_input.txt")
  # main("day23_sample1.txt")