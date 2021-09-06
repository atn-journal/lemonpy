seq = input("Ingrese la secuencia a mutar: ")
seq = seq.upper()

seqs = {}

while True:
    pos = input("Ingrese la posición a mutar (o ENTER para terminar): ")

    if pos.isnumeric() and int(pos) in range(1, len(seq)+1):
        pos = int(pos)
        pass
    elif pos == "":
        break
    else:
        print("Hay un error, revise.")
        continue

    newAA = input("Ingrese el nuevo aa: ")
    newAA = newAA.upper()

    nameSeq = "%s%s%s" % (seq[pos-1], pos, newAA)

    seqMut = "%s%s%s" % (seq[0:pos-1], newAA, seq[pos:len(seq)])

    seqs[nameSeq] = seqMut

for i in seqs:
    print(">%s\n%s" % (i, seqs[i]))
