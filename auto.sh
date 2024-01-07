pairs=`pwd`
method=smd
for i in 1-1 
#1-2 1-3 1-4 2-2 2-3 2-4 3-3 3-4 4-4
do
 
 modification=no
 if [[ "$modification" == "yes" ]]
 then
 
  cd $pairs/$i
  mv charmm-gui* charmm-gui
  cd $pairs/$i/charmm-gui
  vmd -e crdgenerator.tcl
  vmd -e xplorpsf.tcl
  line=$(head -1 solute.psf | awk '{print $NF}')
   if [[ line="CMAP" ]]
   then
    sed -i '1 s/PSF EXT CMAP/PSF EXT CMAP XPLOR/' solute.psf 
   fi
   
  fi 
 
 #After submitting the prepared psf & crd files to Charmm-Gui FF convertor and downloading the topology & structure files:
 cd $pairs/$i/Run
 mkdir $method.auto
 
  destination=$pairs/$i/Run/$method.auto
  source1=$pairs/$i/Run/charmm-gui/gromacs
  source2=$pairs/$i/Run
  source3=$pairs/source  
  
  cp $source1/{step3_input.gro,step3_input.pdb,step3_input.psf} $destination
  mv $destination/step3_input.psf $destination/solute.psf 
  mv $destination/step3_input.pdb $destination/solute.pdb
  mv $destination/step3_input.gro $destination/solute.gro
  cp -r $source1/toppar $destination
  cp $source1/topol.top $destination
  cp $source2/centerfinder.tcl $destination
  cp $source3/{min.mdp,nvt.mdp,npt.mdp,$method.mdp,ions.mdp} $destination
 
 cd $destination
 
 vmd -e centerfinder.tcl
 dos2unix solute.info
  if [ $(grep -c "box dimension without padding" solute.info) -gt 0 ]
  then
     #n=$(grep -n "box dimension without padding" solute.info)
	 dos2unix solute.info
	 x=$(awk '/box dimension without padding/ {print $6}' solute.info)
	 y=$(awk '/box dimension without padding/ {print $8}' solute.info)
	 z=$(awk '/box dimension without padding/ {print $10}' solute.info)
	 marginx=0.11
	 marginy=0.14
	 marginz=0.15
     xbox=$(printf %.1f $(echo "$marginx*$x" | bc -l));
	 ybox=$(printf %.1f $(echo "$marginy*$y" | bc -l));
	 zbox=$(printf %.1f $(echo "$marginz*$z" | bc -l));
  fi 
  
  gmx editconf -f solute-rotate.gro -o boxed.gro -box ${xbox} ${ybox} ${zbox}
  
  gmx solvate -cp boxed.gro -cs spc216.gro -o boxedsol.gro -p topol.top
 
  sed -i 's/Title/'$i'/' $destination/topol.top 
  l=$(awk '/system/{print NR}' topol.top)
  line=$((l-1))
  sed -i ''$line'i #include "toppar/tip3p.itp"' topol.top
  cp $source3/toppar/tip3p.itp $destination/toppar
  
  l=$(awk '/nonbond_params/{print NR}' $destination/toppar/forcefield.itp)
  line=$((l-1))
  sed -i ''$line'i\      HT     1     1.0080      0.417     A    4.00013524445e-02    1.924640e-01' $destination/toppar/forcefield.itp
  sed -i ''$l'i\      OT     8    15.9994     -0.834     A    3.15057422683e-01    6.363864e-01'  $destination/toppar/forcefield.itp
    
  gmx grompp -f ions.mdp -c boxedsol.gro -p topol.top -o ions.tpr
  echo SOL | gmx genion -s ions.tpr -o boxedsoln.gro -p topol.top -pname NA -nname CL -neutral -conc 0.15
  
  l=$(awk '/system/{print NR}' topol.top)
  line=$((l-1))
  sed -i ''$line'i #include "toppar/NA.itp"' topol.top 
  sed -i ''$line'i #include "toppar/CL.itp"' topol.top
  cp $source3/toppar/{CL.itp,NA.itp} $destination/toppar
  
  echo '#include "charmm36-CL.itp"' >> $destination/toppar/forcefield.itp
  echo '#include "charmm36-NA.itp"' >> $destination/toppar/forcefield.itp
  
  cp $source3/toppar/{charmm36-NA.itp,charmm36-CL.itp} $destination/toppar
   
  leftinit=$(awk '/set left/ {print $(NF-3)}' centerfinder.tcl)
  leftend=$(awk '/set left/ {print $(NF-1)}' centerfinder.tcl)
  rightinit=$(awk '/set right/ {print $(NF-3)}' centerfinder.tcl)
  rightend=$(awk '/set right/ {print $(NF-1)}' centerfinder.tcl)
  echo "a ${leftinit}-${leftend}" >> list.txt
  echo "a ${rightinit}-${rightend}" >> list.txt
  echo "q">>list.txt
  
  dos2unix list.txt
  cat list.txt | gmx make_ndx -f boxedsoln.gro -o index
  n=$(tr -cd '[' < index.ndx | wc -c)
  l=$(($n-2))
  r=$(($n-1))
  sed -i '2i name '$l' left' list.txt
  sed -i '4i name '$r' right' list.txt
  cat list.txt | gmx make_ndx -f boxedsoln.gro -o ${method}
  
  # echo $l | gmx genrestr -f boxedsoln.gro -n index.ndx -o leftrest.itp
  
  sed -i 's/ifdef POSRES/ifdef POSRES_left/' $destination/toppar/PROG.itp
  sed -i 's/ifdef POSRES/ifdef POSRES_right/' $destination/toppar/PROM.itp
  
  dos2unix solute.info
  dirx=$(awk '/direction vector/ {print $4}' solute.info)
  diry=$(awk '/direction vector/ {print $5}' solute.info)
  dirz=$(awk '/direction vector/ {print $6}' solute.info)
  
  sed -i 's/pull-coord1-vec          =/pull-coord1-vec          ='$dirx' '$diry' '$dirz'  ;/' $destination/$method.mdp
  
  
  dos2unix solute.info
  atomindex1=$(awk '/centeratom_left/ {print $NF}' solute.info)
  atomindex2=$(awk '/centeratom_right/ {print $NF}' solute.info)
  sed -i 's/pull-group1-pbcatom     =/pull-group1-pbcatom     = '$atomindex1';/' $destination/$method.mdp
  sed -i 's/pull-group2-pbcatom     =/pull-group2-pbcatom     = '$atomindex2';/' $destination/$method.mdp
  
  
    #fwd and back smd mdp settings (for smd only):
	
  if [[ "$method" == "smd" ]]
  then 
    cp $destination/$method.mdp $destination/${method}_back.mdp
    mv $destination/$method.mdp $destination/${method}_fwd.mdp
    dos2unix $destination/${method}_back.mdp
    dos2unix $destination/${method}_forward.mdp
    dt=$(awk '/dt/ {print $3}' ${method}_back.mdp)
    rate=$(awk '/pull_coord1_rate/ {print $3}' ${method}_back.mdp)
    initialdistance=$(awk '/COM distance:/ {print $3}' solute.info)
    nearestdistance=20
    traverse=$(printf %.1f $(echo "($initialdistance-$nearestdistance)/10" | bc -l))
    steps=$(printf %.0f $(echo "($traverse/$rate)/$dt" | bc -l))
    sed -i 's/nsteps      =/nsteps      = '$steps';/' $destination/${method}_back.mdp
    rate_back=$(printf %.4f $(echo "$rate*-1" | bc -l))
    sed -i 's/pull_coord1_rate        =/pull_coord1_rate        = '$rate_back';/' $destination/${method}_back.mdp
	
	gmx grompp -f min.mdp -c boxedsoln.gro -p topol.top -r boxedsoln.gro -o min.tpr &&
    gmx mdrun -deffnm min -update gpu &&
    
    #gmx grompp -f nvt.mdp -c min.gro -p topol2.top -r min.gro -o nvt.tpr &&
    #gmx mdrun -deffnm nvt -update gpu -nb gpu -pme gpu && sleep 2 &&
    
    gmx grompp -f npt.mdp -c min.gro -p topol.top -r min.gro -o npt.tpr && #-t nvt.cpt
    gmx mdrun -deffnm npt -update gpu -nb gpu -pme gpu -cpi npt.cpt && sleep 6 &&
    
    echo 0 | gmx trjconv -s npt.tpr -f npt.xtc -o npt.gro -sep -skip 5
    
    for i in {0..3}
    do
     
	 gmx grompp -f ${method}_fwd.mdp -c npt$i.gro -p topol.top -r npt$i.gro -n ${method}.ndx -o ${method}_fwd$i.tpr
     echo "$i forward"  
     gmx mdrun -deffnm ${method}_fwd$i -pf pullf_fwd$i.xvg -px pullx_fwd$i.xvg -cpi ${method}_fwd$i.cpt -update gpu
	 
	 gmx grompp -f ${method}_back.mdp -c npt$i.gro -p topol.top -r npt$i.gro -n ${method}.ndx -o ${method}_back$i.tpr
     echo "$i backward"  
     gmx mdrun -deffnm ${method}_back$i -pf pullf_back$i.xvg -px pullx_back$i.xvg -cpi ${method}_back$i.cpt -update gpu
	 
	done 
	 
  fi
  
  #for AWH,ABF,FEP,etc.
  
  if [[ "$method" != "smd" ]]
  then
  
    gmx grompp -f min.mdp -c boxedsoln.gro -p topol.top -r boxedsoln.gro -o min.tpr &&
    gmx mdrun -deffnm min &&
    
    #gmx grompp -f nvt.mdp -c min.gro -p topol2.top -r min.gro -o nvt.tpr &&
    #gmx mdrun -deffnm nvt -update gpu -nb gpu -pme gpu && sleep 2 &&
    
    gmx grompp -f npt.mdp -c min.gro -p topol.top -r min.gro -o npt.tpr && #-t nvt.cpt
    gmx mdrun -deffnm npt -update gpu -nb gpu -pme gpu -cpi npt.cpt && sleep 6 &&
    
    echo 0 | gmx trjconv -s npt.tpr -f npt.xtc -o npt.gro -sep -skip 5
    
    for i in {0..3}
    do
	
     gmx grompp -f ${method}.mdp -c npt$i.gro -p topol.top -r npt$i.gro -n ${method}.ndx -o ${method}$i.tpr
     echo $i    
     gmx mdrun -deffnm ${method}$i -pf pullf$i.xvg -px pullx$i.xvg -cpi ${method}$i.cpt -update gpu
    
	done 
    
  fi
  
done
 
 
exit;
 
