gmx make_ndx -f poly_solv_prod.tpr -o energy_group_index.ndx << INPUTS
#keep 0
a 1-100 | 200-300 |400-500
group 27 left

a 101-199 | 301-399 |501-600
group 28 rightt
q

INPUTS
