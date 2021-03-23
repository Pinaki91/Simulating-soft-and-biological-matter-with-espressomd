#To convert amino acid sequence to espresso type readble in tcl
inputfile='fuslcd_seq_wt.dat'
f=open(inputfile,"r")
seq=f.read()
seq=seq.replace("\n","")
seq=seq.replace(" ","")
li=list(seq.strip())
n=len(li)
key=list(range(n))
for i in range(n):
    if(li[i])=="A":
        key[i]=0
    if(li[i])=="R":
        key[i]=1
    if(li[i])=="N":
        key[i]=2
    if(li[i])=="D":
        key[i]=3
    if(li[i])=="C":
        key[i]=4
    if(li[i])=="Q":
        key[i]=5
    if(li[i])=="E":
        key[i]=6
    if(li[i])=="G":
        key[i]=7
    if(li[i])=="H":
        key[i]=8
    if(li[i])=="I":
        key[i]=9
    if(li[i])=="L":
        key[i]=10
    if(li[i])=="K":
        key[i]=11
    if(li[i])=="M":
        key[i]=12
    if(li[i])=="F":
        key[i]=13
    if(li[i])=="P":
        key[i]=14
    if(li[i])=="S":
        key[i]=15
    if(li[i])=="T":
        key[i]=16
    if(li[i])=="W":
        key[i]=17
    if(li[i])=="Y":
        key[i]=18
    if(li[i])=="V":
        key[i]=19
f = open("fuslcd_type_wt.dat", "w")
for i in range(n):
    f.write("{\t%s\t%d\t}\n"%(li[i],key[i]))
f.close()
