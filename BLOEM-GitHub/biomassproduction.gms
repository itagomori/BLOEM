$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Branch: BLOEM-Master
* Author: Isabela Schmidt Tagomori
* Last update: 14.08.2022
* Version: 2.0
* Module: Land Allocation and Biomass Production
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters
    
    ldav(l,c,t)         'fraction of land available for bioenergy' # [fraction, 0-1]

    cobp(r,c,t)         'biomass production costs' # [US$/GJ]

    ga(c)               'grid cell area' # [km2]

    y(r,c,t)            'biomass yields' # [GJ/km2]

    ef(r,l)             'emission factors for direct land use change' # [tCO2/GJ] primary energy

;

* Set aggregate emission factors for land use change

Table ef(r,l) 'emission factors for direct land use change' # [tCO2/GJ] primary energy, from Daioglou et al. (2017)

                    landtype1     landtypeX     # substitute biomass, landtype and ef accordingly, for examples see regional branches
biomass             ef1           efX        
;


* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Path\'  # set your path for inputs


* Import land availability:

$gdxin '%gdxinfilepath%landavailable.gdx'

$load ldav=ldavbase

$gdxin


* Importing costs of biomass production:

$gdxin '%gdxinfilepath%bprcosts.gdx'

$load cobp=bprcosts

$gdxin


* Importing grid cell area:

$gdxin '%gdxinfilepath%gcarea.gdx'

$load ga=gcarea

$gdxin


* Import crop yields:

$gdxin '%gdxinfilepath%bpryields.gdx'

$load y=bpryields

$gdxin

;

* ---------------------------------------------------------------------------------------------------------
* Declare variables
* ---------------------------------------------------------------------------------------------------------

Variables

    IBP(t)          'impact of biomass production in time t'  # [US$]

    A(r,l,c,t)      'area allocated to biomass production for crop r in land type l in grid cell c in time t'  # [fraction]
    B(r,l,c,t)      'biomass production for crop r in land type l in grid cell c in time t'  # [GJ]

    LdAlc(l,r,t)    'total land allocated per land type per crop per decade' # [km2]

;

Positive variables IBP, A, B;

* Variable bounds
A.up(r,l,c,t)=0.75;
A.lo(r,l,c,t)=0;

* Land availability, types of land

# except for cropland, other types of land cannot produce agricultural residues
A.fx('agrires','landtypeX',c,t)=0;  # example: 'agrires' = agricultural residues; 'landtypeX' = 'forest', 'pasture', etc.

# except for forests, other types of land cannot produce forestry residues
A.fx('foresres','landtypeX',c,t)=0;  # example: 'foresres' = forestry residues; 'landtypeX' = 'cropland', 'pasture', etc.

* ---------------------------------------------------------------------------------------------------------
* Define Equations
* ---------------------------------------------------------------------------------------------------------

Equations

    impactbioproduction(t)           'impact of producing biomass'

    production(r,l,c,t)              'production of crop r constrained by area allocation and yields'
    landavailability(l,c,t)          'area allocation constrained by total land availability in each grid cell'
    totallandallocation(l,r,t)       'total land allocated per land type per crop per decade'

;

impactbioproduction(t) ..               IBP(t) =e= dfa(t)*sum((r,l,c),B(r,l,c,t)$(rsou(r))*(cobp(r,c,t)$(rsou(r))+k(t)*ef(r,l)$(rsou(r)))) ;


production(r,l,c,t)$(rsou(r)) ..        B(r,l,c,t)$(rsou(r)) =e= A(r,l,c,t)$(rsou(r))*ga(c)*y(r,c,t)$(rsou(r)) ;

landavailability(l,c,t) ..              ldav(l,c,t) =g= sum((r),A(r,l,c,t)$(rsou(r))) ;

totallandallocation(l,r,t) ..           LdAlc(l,r,t)$(rsou(r)) =e= sum((c),A(r,l,c,t)$(rsou(r))*ga(c)) ;
