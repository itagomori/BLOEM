$ontext
* -----------------------
* BLOEM-China
* -----------------------
$offtext

* -----------------------
* Define parameters
* -----------------------

Parameters
    ldav(c,l,t)         'fraction of land available for bioenergy' # [fraction, 0-1]

    cobp(r,c,t)         'biomass production costs' # [US$/GJ]

    ga(c,t)              'grid cell area' # [km2]

    y(r,c,t)            'biomass yield' # [GJ/km2]

    ef(r,l)             'emission factors for direct land use change' # [tCO2/GJ] primary energy

;

* Set aggregate emission factors for land use change

*Table ef(r,l) 'emission factors for direct land use change' # [tCO2/GJ] primary energy,

#                   forest        other        pasture
#sugarcane           0.044         0.030        0.000
#oilcrops            0.235         0.257        0.000   
#wood                0.052         0.051        0.000
#;

# these parameters needs some supports
Table ef(r,l) 'emission factors for direct land use change' # [tCO2/GJ] primary energy,

                    cropland        forest        pasture       othernatualland
agriRes             0.000           0.000         0.000         0.000
foresRes            0.000           0.000         0.000         0.000  
egrass              0.235           0.235         0.235         0.235
ewood               0.052           0.052         0.052         0.052
;


* ---------------------
* import data
* ---------------------
* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Users\vicke\Desktop\BLOEM-China\input\gdx\'

* Import land availability:
# c, l, t, value 
$gdxin '%gdxinfilepath%landavailablebioen_bopf.gdx'

$load ldav = landavailablebioen_bopf

$gdxin

# Import costs of biomass production:

$gdxin '%gdxinfilepath%bprcosts.gdx'
# r, c, t, value
$load cobp = bprcosts

$gdxin

# Import grid cell area
$gdxin '%gdxinfilepath%gcarea.gdx'
# c, t, value
$load ga = gcarea

$gdxin

# Import crop yields:
$gdxin '%gdxinfilepath%bpryields.gdx'
# r, c, t, value
$load y = bpryields

$gdxin

;
* ---------------------------------------------
* Declare variables
* ---------------------------------------------

Variables

    IBP(t)              'impact of biomass production in time t'    # [US$]

    A(r,l,c,t)       'area allocated to biomass production for crop r in land type l in grid cell c in time t' # [fraction]
    B(r,c,t)          'biomass production for crop r in grid cell c in time t' #[GJ]

    LdAlc(l, r, t)      'total land allocated per land type per crop per decade' # [km2]
;

Positive variables IBP, A, B;

* Variables bounds
A.up(r,l,c,t)=0.75;
A.lo(r,l,c,t)=0;

* Land availability, types of land
*A.fix(r, "cropland", c, t) = 0;
*A.fix(r, "forest", c, t) = 0;
*A.fix(r, "builtup", c, t) = 0;

# except cropland, other land cannot produce agricultural residues
A.fx("agriRes", "othernatualland", c, t) =0;
A.fx('agriRes', 'forest', c, t) =0;
A.fx('agriRes', 'pasture', c, t) =0;
# except forest, other land cannot produce forestry residues
A.fx('foresRes', 'othernatualland', c, t) =0;
A.fx('foresRes', 'cropland', c, t) =0;
A.fx('foresRes', 'pasture', c, t) =0;
# cropland and forest land cannot be used to produce energy crops
A.fx('ewood', 'cropland', c, t) =0;
A.fx('egrass', 'cropland', c, t) =0;
A.fx('ewood', 'forest', c, t) =0;
A.fx('egrass', 'forest', c, t) =0;


* -------------------------------
* Define Equations
* -------------------------------


*Equations

*    impactbioproduction(t)          'impact of producing biomass'

*    production(r, l, c, t)          'production of crop r constrained by area allocation and yield'
*    landavailability(l, c, t)       'area allocation constrained by total land availability in each grid cell'
*    totallandallocation(l, r, t)    'total land allocated per land type per crop per decade' # give target for each land use type?
*;

# Q: nee to think about how to add agricultural and forestry residues in these equations?
*impactbioproduction(t) ..           IBP(t) =e= dfa(t)*sum((r,l,c), B(r,l,c,t)$rsou(r) * (cobp(r,c,t)$(rsou(r)) + k(t)*ef(r,l)$rsou(r)));

*production(r,l,c,t)$(recr(r))..     B(r,l,c,t)$(recr(r)) =l= A(r,l,c,t)$(recr(r)) * ga(c,t) * y(r,c,t)$(recr(r));

*landavailability(l,c,t) ..          ldav(l,c,t) =g= sum((r), A(r,l,c,t)$(recr(r)));

*totallandallocation(l,r,t) ..       LdAlc(l,r,t)$(recr(r)) =e= sum((c), A(r,l,c,t)$(recr(r))*ga(c));



* ============ new version ========================
Equations
    impactbioproduction(t)          'impact of producing biomass'
    limitecropland(c,t)         'energy crop can only be grown on pasture and othernaturalland'
    limitagriresamount(c,t)        'agricultural residues can only sourced from cropland'
    limitforesresamount(c,t)       'forestry residues can only be collected from forestland'
    totallandallocation(l,r,t)      'total land allocated for eahc land type in each decade'
    biomassproductionincell(r,c,t)  'biomass production in each grid cell per decade'
;


# impactbiomassproduction = yield * supply cost curve + land use emision price
impactbioproduction(t)  ..          IBP(t) =e= dfa(t) * (sum((r,c), B(r,c,t)$(rsou(r)) * (cobp(r,c,t)$(rsou(r))))  + sum((r,l), k(t) * sum((c), A(r,l, c, t)$(recr(r))) * ef(r,l)));


# the land that are used to produce energy crops in each grid cell should not larger than the total share of pasture and othernatural land
limitecropland(c,t) ..              sum((r, l)$(lother(l)), A(r, l, c, t)$(recr(r))) =l= sum((l), ldav(c, l, t)$(lother(l)));

# the land allocated to produce agricultural/forest residues should be lower than total cropland/forestland
limitagriresamount(c,t) ..          A('agriRes', 'cropland', c, t) =l= ldav(c, 'cropland', t);
limitforesresamount(c,t)  ..        A('foresRes', 'forest', c, t) =l= ldav(c, 'forest', t);


# used as output variable
# for energy crop r, how many landuse l are allocatd for resource productoin (only include energy crops)
totallandallocation(l,r,t)  .. LdAlc(l, r, t) =e= sum((c), A(r, l, c, t)$recr(r));   

# the production of biomass resource r in grid cell c in decade t
biomassproductionincell(r,c,t) .. B(r, c, t)$rsou(r) =e= sum((l), A(r, l, c, t)$rsou(r)) * y(r, c, t)$rsou(r)  * ga(c, t);