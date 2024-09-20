$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Author: Isabela Schmidt Tagomori & Aline Carvalho
* Last update: 10.08.2024
* Version: 1.0
* Coupled IAM: COFFEE
* Region: Europe 
* Time frame: 2025
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

    efi(r,l)            'emission factors for instantaneous land use change' # [tCO2/km2] used only for post-processing

    efg(r,l,q)          'emission factors for gradual land use change' # [tCO2/km2] used only for post-processing

;


* Set aggregate emission factors for land use change

Table ef(r,l) 'emission factors for direct land use change' # [tCO2/GJ] primary energy,

                    forest        other        pasture
foresres            0.000         0.000        0.000
;

* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\BLOEM\EuropeRegion\input\'


* Import land availability:

$gdxin '%gdxinfilepath%landavailablebioen_bopf.gdx'

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
A.fx(r,"agriculture",c,t)=0;
#A.fx(r,"forest",c,t)=0;
A.fx(r,"pasture",c,t)=0;

# except for forests, other types of land cannot produce forestry residues
A.fx('foresres','other',c,t)=0;
A.fx('foresres','agriculture',c,t)=0;
A.fx('foresres','pasture',c,t)=0;


* ---------------------------------------------------------------------------------------------------------
* Define Equations
* ---------------------------------------------------------------------------------------------------------

Equations

    impactbioproduction(t)           'impact of producing biomass'

    production(r,l,c,t)              'production of crop r constrained by area allocation and yields'
    landavailability(l,c,t)          'area allocation constrained by total land availability in each grid cell'
    totallandallocation(l,r,t)       'total land allocated per land type per crop per decade'

;

impactbioproduction(t) ..                       IBP(t) =e= dfa(t)*sum((r,l,c),B(r,l,c,t)$(rres(r))*(cobp(r,c,t)$(rres(r))+k(t)*ef(r,l)$(rres(r)))) ;


production(r,l,c,t)$(rres(r)) ..                  B(r,l,c,t)$(rres(r)) =l= A(r,l,c,t)$(rres(r))*ga(c)*y(r,c,t)$(rres(r)) ;

landavailability(l,c,t) ..                      ldav(l,c,t) =g= sum((r),A(r,l,c,t)$(rres(r))) ;

totallandallocation(l,r,t) ..                   LdAlc(l,r,t)$(rres(r)) =e= sum((c),A(r,l,c,t)$(rres(r))*ga(c)) ;
