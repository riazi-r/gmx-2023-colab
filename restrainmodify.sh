destination=`pwd`
define_left=$(awk '/set left/ {print $0}'  centerfinder.tcl)
  leftproteins=$(echo $define_left | grep -o -P '(?<=segid).*?(?=serial)'|tr -d 'to','or')
  leftchain_No=$(echo $leftproteins | awk '{print NF}')  
  for (( chain=1; chain<=$leftchain_No; chain+=1 ))
  do
   segid=$(echo $leftproteins | awk '{print $chain}')
   cp $destination/toppar/${segid}.itp $destination/toppar/${segid}_original.itp
   sed -i 's/ifdef POSRES/ifdef POSRES_left/' $destination/toppar/${segid}.itp
   posres=$(awk '/ifdef POSRES_left/{print NR}' $destination/toppar/${segid}.itp)
   first=$(($posres+2))
   last=$(awk '$0~"POSRES_FC"{n=NR}END{print n}' $destination/toppar/${segid}.itp)
   i=0
   j=1
	mv $destination/toppar/${segid}.itp  $destination/toppar/${segid}_${i}.itp
    for (( line=$first; line<=$last; line+=1 ))
    do
     atom=$(awk -v "a=$line" 'NR==a {print $1}' $destination/toppar/${segid}_${i}.itp)
     k=$(awk -v "a=$line" 'NR==a {print $3}' $destination/toppar/${segid}_${i}.itp)
	 awk -v "a=$line" 'NR==a { print "'$atom'     2    1    1    '$k'" ; next } 1' $destination/toppar/${segid}_${i}.itp > $destination/toppar/${segid}_${j}.itp
	 rm  $destination/toppar/${segid}_${i}.itp
	 ((i++))
	 ((j++))
     
     #sed -i ''$line'i '$atom'     2    1    1    '$k'' $destination/toppar/${segid}.itp
     #next=$(($line+1))
     #sed -i ''$next'd' $destination/toppar/${segid}.itp
    done
  done	 
  
