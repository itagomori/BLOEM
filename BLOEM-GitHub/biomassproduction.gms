$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Branch: BLOEM-China
* Authors: Rui Wang & Isabela Schmidt Tagomori
* Last update: 12.08.2024
* Version: 1.0
* Coupled IAM: IMAGE
* Region: China
* Time frame: 2020-2060
* Module: Land Allocation and Biomass Production
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    ldav(c,l,t)         'fraction of land available for bioenergy' # [fraction, 0-1]

    cobp(r,c,t)         'biomass production costs' # [US$/GJ]

    ga(c)               'grid cell area' # [km2]

    y(r,c,t)            'biomass yields' # [GJ/km2]

    ef(r,l)             'emission factors for direct land use change' # [tCO2/GJ] primary energy

;

* Set aggregate emission factors for land use change

Table ef(r,l) 'emission factors for direct land use change' # [tCO2/GJ] primary energy, from Daioglou et al. (2017)

                    cropland        forest        pasture       other
grass               0.235           0.235         0.000         0.235   # calculate for grass
wood                0.052           0.052         0.000         0.051   # calculate for cropland/wood
;

* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Users\vicke\Desktop\BLOEM\BLOEM-GitHub\input\gdx\'


* Import land availability:

$gdxin '%gdxinfilepath%landavailablebioen.gdx'

$load ldav = landavailablebioen

$gdxin


* Import costs of biomass production:

$gdxin '%gdxinfilepath%bprcosts.gdx'

$load cobp = bprcosts

$gdxin


* Import grid cell area

$gdxin '%gdxinfilepath%gcarea.gdx'

$load ga = gcarea

$gdxin


* Import crop yields:

$gdxin '%gdxinfilepath%bpryields.gdx'

$load y = bpryields

$gdxin

;

* ---------------------------------------------------------------------------------------------------------
* Declare variables
* ---------------------------------------------------------------------------------------------------------

Variables

    IBP(t)          'impact of biomass production in time t'    # [US$]

    A(r,l,c,t)      'area allocated to biomass production for crop r in land type l in grid cell c in time t' # [fraction]
    B(r,l,c,t)      'biomass production for crop r in grid cell c in time t' #[GJ]

    LdAlc(l,r,t)    'total land allocated per land type per crop per decade' # [km2]
;

Positive variables IBP, A, B;

* Variables bounds
A.up(r,l,c,t)=0.75;
A.lo(r,l,c,t)=0;

* Land availability, types of land

# except for cropland, other types of land cannot produce agricultural residues
A.fx("agrires","other",c,t)=0;
A.fx('agrires','forest',c,t)=0;
A.fx('agrires','pasture',c,t)=0;

# except for forests, other types of land cannot produce forestry residues
A.fx('foresres','other',c,t)=0;
A.fx('foresres','cropland',c,t)=0;
A.fx('foresres','pasture',c,t)=0;

# cropland and forests cannot be used to produce energy crops (degraded pasture can be added later)
A.fx(r,'cropland',c,t)$(rcrp(r))=0;
A.fx(r,'forest',c,t)$(rcrp(r))=0;
A.fx(r,'pasture',c,t)$(rcrp(r))=0;

* ---------------------------------------------------------------------------------------------------------
* Define Equations
* ---------------------------------------------------------------------------------------------------------

Equations

    impactbioproduction(t)          'impact of producing biomass'

    biomassproduction(r,l,c,t)      'biomass production in each grid cell per decade'
    landavailability(l,c,t)         'area allocation constrained by total land availability in each grid cell'
    totallandallocation(l,r,t)      'total land allocated for eahc land type in each decade'

;

# impactbiomassproduction = yield * supply cost curve + land use emision price
impactbioproduction(t)  ..          IBP(t) =e= dfa(t)*(sum((r,l,c),B(r,l,c,t)$(rsou(r))*(cobp(r,c,t)$(rsou(r)))+k(t)*ef(r,l)$(rsou(r)))) ;

# the production of biomass resource r in grid cell c in decade t
biomassproduction(r,l,c,t)$(rsou(r)) ..       B(r,l,c,t)$(rsou(r)) =e= A(r,l,c,t)$(rsou(r))*ga(c)*y(r,c,t)$(rsou(r)) ;

landavailability(l,c,t) ..          ldav(c,l,t) =g= sum((r),A(r,l,c,t)$rsou(r)) ;

# the land that are used to produce energy crops in each grid cell should not larger than the total share of pasture and othernatural land
# no need to consider agriRes and foresRes, because the above has already set A('agriRes', 'lotherland', c, t) =e= 0
#limitecropland(c,t) ..              sum((r, l)$(lother(l)), A(r, l, c, t)$(lother(l))) =l= sum((l), ldav(c, l, t)$(lother(l)));

# the land allocated to produce agricultural/forest residues should be lower than total cropland/forestland
#limitagriresamount(c,t) ..          A('agriRes', 'cropland', c, t) =l= ldav(c, 'cropland', t);
#limitforesresamount(c,t)  ..        A('foresRes', 'forest', c, t) =l= ldav(c, 'forest', t);

# used as output variable
# for energy crop r, how many landuse l are allocatd for resource productoin (only include energy crops)
totallandallocation(l,r,t)$(rsou(r)) ..       LdAlc(l,r,t)$(rsou(r)) =e= sum((c),A(r,l,c,t)$(rsou(r))*ga(c)) ;
