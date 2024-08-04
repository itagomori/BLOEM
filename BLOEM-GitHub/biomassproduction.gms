$ontext
* -----------------------
* BLOEM-China
* -----------------------
$offtext

* -----------------------
* Define parameters
* -----------------------

Parameters
    ldav(l,c,t)         'fraction of land available for bioenergy' # [fraction, 0-1]

    cobp(r,c,t)         'biomass production costs' # [US$/GJ]

    ga(c)               'grid cell area' # [km2]

    y(r,c,t)            'biomass yield' # [GJ/km2]

    ef(r,t)             'emission factors for direct land use change' # [tCO2/GJ] primary energy

;

* ---------------------
* import data
* ---------------------
* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Users\vicke\Desktop\model\BLOEM\BLOEM-GitHub\input\gdx\'

* Import land availability:

$gdxin '%gdxinfilepath%landavailabelbioen_bopf.gdx'

$load ldav = landavailabelbioen_bopf

$gdxin

# Import costs of biomass production:

$gdxin '%gdxinfilepath%bprcosts.gdx'

$load cobp = bprcosts

$gdxin

# Import grid cell area
$gdxin '%gdxinfilepath%gcarea.gdx'

$load ga = gcarea

$gdxin

# Import crop yields:
$gdxin '%gdxinfilepath%bpryields.gdx'

$load y = bpryields

$gdxin

;
* ---------------------------------------------
* Declare variables
* ---------------------------------------------

Variables

    IBP(t)              'impact of biomass production in time t'    # [US$]

    A(r, l, c, t)       'area allocated to biomass production for crop r in land type l in grid cell c in time t' # [fraction]
    B(r, l, c, t)       'biomass production for crop r in land type l in grid cell c in time t' #[GJ]

    LdAlc(l, r, t)      'total land allocated per land type per crop per decade' # [km2]
;

Positive variables IBP, A, B;

* Variables bounds
A.up(r, l, c, t) = 0.75;
A.lo(r, l, c, t) = 0;

* Land availability, types of land
A.fix(r, "cropland", c, t) = 0;
A.fix(r, "forest", c, t) = 0;
A.fix(r, "builtup", c, t) = 0;
* -------------------------------
* Define Equations
* -------------------------------

Equations

    impactbioproduction(t)          'impact of producing biomass'

    production(r, l, c, t)          'production of crop r constrained by area allocation and yield'
    landavailability(l, c, t)       'area allocation constrained by total land availability in each grid cell'
    totallandallocation(l, r, t)    'total land allocated per land type per crop per decade' # give target for each land use type?
;

# Q: nee to think about how to add agricultural and forestry residues in these equations?
impactbioproduction(t) ..           IBP(t) =e= dfa(t)*sum((r,l,c), B(r,l,c,t)$rren(r)*(cobp(r,c,t)$(rren(r)) + k(t)*ef(r,l)$rren(r)));

production(r,l,c,t)$(rren(r))..     B(r,l,c,t)$(rren(r)) =l= A(r,l,c,t)$(rren(r))*ga(c)*y(r,c,t)$(rren(r));

landavailability(l,c,t) ..          ldav(l,c,t) =g= sum((r), A(r,l,c,t)$(rren(r)));

totallandallocation(l,r,t) ..       LdAlc(l,r,t)$(rren(r)) =e= sum((c), A(r,l,c,t)$(rren(r))*ga(c));


