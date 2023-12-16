
function mdp_add_energy_groups () 

{ 

    input_mdp_file_="$1";

    output_mdp_file_="$2";

    energy_groups_="$3";

    cp -r "${input_mdp_file_}" "${output_mdp_file_}";

    echo "" >> "${output_mdp_file_}";

    echo "; ENERGY GROUPS " >> "${output_mdp_file_}";

    echo "energygrps          = ${energy_groups_}" >> "${output_mdp_file_}";

    echo "----- mdp_add_energy_groups -----";

    echo "--> Created ${output_mdp_file_} from ${input_mdp_file_}";

    echo "--> Added energy groups: ${energy_groups_}"
}

mdp_add_energy_groups "smd.mdp" "smd-groups.mdp" "left right"	


for i in {0..16}	
do
gmx grompp -f smd-groups.mdp npt$i.gro -p topol.top -r npt$i.gro -n awh.ndx -o smd$i-groups.tpr
echo $i
gmx mdrun -v -nt 1 -s smd$i-groups.tpr -rerun smd$i.xtc -e smd$i-groups.edr
done


for i in {0..16}	
do
echo $i
gmx energy -f smd$i-groups.edr -s smd$i-groups.tpr -o energy$i_groups.xvg
done
