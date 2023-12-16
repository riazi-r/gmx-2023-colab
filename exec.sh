echo 0 | gmx trjconv -s npt.tpr -f npt.xtc -o npt.gro -sep -skip 3

for i in {0..16}
do
gmx grompp -f smd.mdp -c npt$i.gro -p topol.top -r npt$i.gro -n awh.ndx -o smd$i.tpr

echo $i

gmx mdrun -deffnm smd$i -pf pullf$i.xvg -px pullx$i.xvg -cpi smd$i.cpt -update gpu
 done 

 