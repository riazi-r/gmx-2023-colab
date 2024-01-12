cd toppar
cp PROM.itp PROM_ORIGINAL.itp
restrain=$(awk '/ifdef POSRES_left/{print NR}' PROM.itp)
first=$(($restrain+2))
last=$(awk '$0~"POSRES_FC_BB"{n=NR}END{print n}' PROM.itp)
#$(awk 'END /POSRES_FC_BB/{print NR}' PROM.itp)
#test=$(($first+6))
for (( l=$first; l<=$last; l+=1 ))
do
atom=$(awk -v "l=$l" 'NR==l {print $1}' PROM.itp)
k=$(awk -v "l=$l" 'NR==l {print $3}' PROM.itp)
sed -i ''$l'i '$atom'     2    1    1    '$k'' PROM.itp
next=$(($l+1))
sed -i ''$next'd' PROM.itp
done
