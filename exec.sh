gmx grompp -f min.mdp -c boxedsoln.gro -p topol.top -r boxedsoln.gro -o em.tpr &&
gmx mdrun -deffnm em &&

gmx grompp -f nvt.mdp -c em.gro -p topol.top -r em.gro -o nvt.tpr &&
gmx mdrun -deffnm nvt -update gpu -nb gpu -pme gpu -bonded gpu && sleep 2 &&

gmx grompp -f npt.mdp -c nvt.gro -p topol.top -r nvt.gro -t nvt.cpt -o npt.tpr &&
gmx mdrun -deffnm npt -update gpu -nb gpu -pme gpu -bonded gpu && sleep 3 &&

gmx grompp -f awh.mdp -c npt.gro -p topol.top -r npt.gro -n awh.ndx -t npt.cpt -o awh.tpr &&

for N in {0..10}

do
echo $N
gmx mdrun -deffnm awh -update gpu -nb gpu -pme gpu -pf pullf.xvg -px pullx.xvg -cpi awh.cpt || sleep 6
gmx mdrun -s awh-ext.tpr -deffnm awh -cpi awh.cpt -px pullx.xvg -pf pullf.xvg || sleep 6
done 
  
#gmx grompp -f md_pull.mdp -c npt.gro -p topol.top -r npt.gro -n index.ndx -t npt.cpt -o pull.tpr
#gmx mdrun -deffnm pull -pf pullf.xvg -px pullx.xvg
