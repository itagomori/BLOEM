$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Author: Isabela Schmidt Tagomori
* Last update: 30.09.2024
* Version: 1.0
* Coupled IAM: BLUES
* Region: Brazil 
* Time frame: 2020-2050
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

    #ef(r,l)             'emission factors for direct land use change' # [tCO2/GJ] primary energy

    efi(r,l)            'emission factors for instantaneous land use change' # [tCO2/km2] used only for post-processing

    efg(r,l,q)          'emission factors for gradual land use change' # [tCO2/km2] used only for post-processing

;


* Set aggregate emission factors for land use change

#Table ef(r,l) 'emission factors for direct land use change' # [tCO2/GJ] primary energy,

#                    forest        other        pasture
#sugarcane           0.044         0.030        0.000
#oilcrops            0.235         0.257        0.000   
#wood                0.052         0.051        0.000
#;


* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Users\diego\OneDrive\Desktop\PPE_MESTRADO\Calculos e rodadaas\BLOEM_OUTUBRO\biomassproductionInputs\'


* Import land availability:

$gdxin '%gdxinfilepath%landavailable_pastures_FIXbiocane_biosoy_2020a50.gdx'

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
    LdCane(l,r,t)   'total sugarcane land allocated for ethanol' #[km2]
    LdSoy(l,r,t)    'total soy land allocated for biodiesel' #[km2]

    DLUC(r,l,c,t)            'total dLUC emission' # [tCO2]
;

Positive variables IBP, A, B;

* Variable bounds
A.up(r,l,c,t)=0.75;
A.lo(r,l,c,t)=0;

* Land availability, types of land
#A.fx(r,"agriculture",c,t)=0;
#A.fx(r,"forest",c,t)=0;
#A.fx(r,"other",c,t)=0;
#A.fx(r,"pasture",c,t)=0;
A.fx("sugarcane","biolandsoja",c,t)=0;
A.fx("oilcrops","biolandcane",c,t)=0;
A.fx(r,"pasturelow",c,"2020")=0;
A.fx(r,"pasturemed",c,"2020")=0;
A.fx(r,"pasturehigh",c,"2020")=0;
A.fx("wood","biolandsoja",c,t)=0;
A.fx("wood","biolandcane",c,t)=0;
#A.fx(r,"biolandsoja",c,tf(t))=0;
#A.fx(r,"biolandcane",c,tf(t))=0;


* ---------------------------------------------------------------------------------------------------------
* Define Equations
* ---------------------------------------------------------------------------------------------------------

Equations

    impactbioproduction(t)           'impact of producing biomass'

    production(r,l,c,t)              'production of crop r constrained by area allocation and yields'
    landavailability(l,c,t)          'area allocation constrained by total land availability in each grid cell'
    totallandallocation(l,r,t)       'total land allocated per land type per crop per decade'

    sugarcanearea(l,r,t)             'Area for sugarcane'
    totalsugarcane(l,r,t)            'total bioland allocated for sugarcane ethanol'

    soyarea(l,r,t)                   'Area for soy'
    totalsoy(l,r,t)                  'total bioland allocated for soy biodiesel'

    #dlucemissions                    'Total emissions from dLUC'
;

impactbioproduction(t) ..                       IBP(t) =e= dfa(t)*sum((r,l,c),B(r,l,c,t)$(rc(r))*(cobp(r,c,t)$(rc(r))));#+k(t)*ef(r,l)$(rc(r)))) ;


#dlucemissions(r,l,c,t) ..                       DLUC(r,l,c,t) =e= B(r,l,c,t)$rc(r)*ef(r,l)$(rc(r));

production(r,l,c,t)$(rc(r)) ..                  B(r,l,c,t)$(rc(r)) =l= A(r,l,c,t)$(rc(r))*ga(c)*y(r,c,t)$(rc(r)) ;

landavailability(l,c,t) ..                      ldav(l,c,t) =g= sum((r),A(r,l,c,t)$(rc(r))) ;

totallandallocation(l,r,t) ..                   LdAlc(l,r,t)$(rc(r)) =e= sum((c),A(r,l,c,t)$(rc(r))*ga(c)) ;

soyarea(l,r,t) ..                               LdSoy(l,r,t) =e= sum((c),A(r,l,c,"2020")$lbs(l)) ;

totalsoy(l,r,t) ..                              LdSoy(l,r,t) =l= sum((c),ldav(l,c,t)$lbs(l)) ;

sugarcanearea(l,r,t) ..                         LdCane(l,r,t) =e= sum((c),A(r,l,c,"2020")$lbc(l)) ;

totalsugarcane(l,r,t) ..                        LdCane(l,r,t) =l= sum((c),ldav(l,c,t)$lbc(l)) ;