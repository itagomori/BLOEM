$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Branch: BLOEM-Master
* Author: Isabela Schmidt Tagomori
* Last update: 14.08.2022
* Version: 2.0
* Module: Logistics
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    trco(r)             'biomass transportation costs'  # [US$/GJ/km]

    mx(c,cn)            'distance between grid cells'  # [km]

    mxdem(c,cn)         'distance between grid cells - connection to demand'  # [km] used in place of mx(c,cn) to reduce computational effort

    tal(c)              'tortuosity factor'  # [factor]

    beta(r,j)           'ratio of consumption (inputs) or production (outputs)'

;

* Set biomass and biofuels transportation costs trco(r)

Parameter trco(r) / biomass     trco1,        # substitute biomass/product and trco, accordingly (for examples, see regional branches) 
                    product     trcoX /;
;

* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Path\'  # set your path for inputs


* Import distance between grid cells, mx(c,cn):

$gdxin '%gdxinfilepath%mxdistance.gdx'

$load mx=mxdistance

$gdxin


* Import distance between grid cells, connection to demand, mxdem(c,cn):

$gdxin '%gdxinfilepath%mxdistancedem.gdx'

$load mxdem=mxedistancedem

$gdxin


* Import tortuosity factors tal(c):

$gdxin '%gdxinfilepath%tortuosityfactor.gdx'

$load tal=totfactor

$gdxin

;

* ---------------------------------------------------------------------------------------------------------
* Declare variables
* ---------------------------------------------------------------------------------------------------------

Variables

    IBT(t)          'impact of biomass transportation in time t'  # [US$]
    IET(t)          'impact of bioenergy transportation in time t'  # [US$]

    HB(r,c,t)       'local biomass consumption for crop r in grid cell c in time t' 
    HE(r,c,t)       'local bioenergy consumption for product r in grid cell c in time t'

    Bn(r,c,cn,t)    'biomass flow for crop r between grid cells c and cn in time t'
    En(r,c,cn,t)    'bioenergy flow for product r between grid cells c and cn in time t'

    Bin(r,c,t)      'crop r into grid cell c in time t'
    Bout(r,c,t)     'crop r out of grid cell c in time t'

    Ein(r,c,t)      'biofuel r into grid cell c'
    Eout(r,c,t)     'biofuel r out of grid cell c'

    B(r,l,c,t)      'biomass production for crop r in land type l in grid cell c in time t'  # [GJ]
    E(r,c,t)        'bioenergy production for product r in grid cell c in time t'  # [GJ] [kW]

    CP(j,c,t)       'rate of operation of technology j in grid cell c in time t'

;

Positive variables IBT, IET, HE, Bn, En, Bin, Bout, Ein, Eout, B, E, CP;

* Variable bounds:
HB.up(r,c,t)=0;

# biochar can only be consumed in the grid cell where it is produced
En.fx("biochar",c,cn,t)=0;

* ---------------------------------------------------------------------------------------------------------
* Equations
* ---------------------------------------------------------------------------------------------------------

Equations 

    impactbiotransport(t)            'impact of transporting biomass among grid cells'

    resourcebalance(r,c,t)           'resource balance in each grid cell'
    biomassintocell(r,c,t)           'biomass into grid cell'
    biomassoutocell(r,c,t)           'biomass out of grid cell'
    maxbiomassoutocell(r,c,t)        'max biomass out of grid cell'

    localdemandforcrops(r,c,t)       'local demand for crops due to technology operation'

    impactbioendtransport(t)         'impact of transporting bioenergy from production to demand grid cells'

    bioenergybalance(r,c,t)          'bioenergy balance in grid cell c in decade d'
    bioenergyintogridcell(r,c,t)     'bioenergy into grid cell'
    bioenergyoutogridcell(r,c,t)     'bioenergy out of grid cell'
    maxbioenergytransp(r,c,t)        'max bioenergy out of grid cell'

;

impactbiotransport(t) ..                          IBT(t) =e= dfa(t)*sum((r,c,cn),trco(r)$(rsou(r))*Bn(r,c,cn,t)$(rsou(r))*mx(c,cn)*tal(c)) ;


resourcebalance(r,c,t)$(rsou(r)) ..               sum((l),B(r,l,c,t)$(rsou(r)))+Bin(r,c,t)$(rsou(r))-Bout(r,c,t)$(rsou(r))+HB(r,c,t)$(rsou(r)) =e= 0 ;

biomassintocell(r,c,t)$(rsou(r)) ..               Bin(r,c,t)$(rsou(r)) =e= sum((cn),Bn(r,cn,c,t)$(rsou(r))) ;

biomassoutocell(r,c,t)$(rsou(r)) ..               Bout(r,c,t)$(rsou(r)) =e= sum((cn),Bn(r,c,cn,t)$(rsou(r))) ;

maxbiomassoutocell(r,c,t)$(rsou(r)) ..            Bout(r,c,t)$(rsou(r)) =l= sum((l),B(r,l,c,t)$(rsou(r))) ;


localdemandforcrops(r,c,t)$(rsou(r)) ..           HB(r,c,t)$(rsou(r)) =e= sum((j),CP(j,c,t)*beta(r,j)$(rsou(r))*uf) ;


impactbioendtransport(t) ..                       IET(t) =e= dfa(t)*sum((r,c,cn),trco(r)$(rliq(r))*En(r,c,cn,t)$(rliq(r))*mxdem(c,cn)*tal(c)) ;


bioenergybalance(r,c,t)$(rliq(r)) ..              E(r,c,t)$(rliq(r))+Ein(r,c,t)$(rliq(r))-Eout(r,c,t)$(rliq(r)) =e= HE(r,c,t)$(rliq(r)) ;

bioenergyintogridcell(r,c,t)$(rliq(r)) ..         Ein(r,c,t)$(rliq(r)) =e= sum((cn),En(r,cn,c,t)$(rliq(r))) ;

bioenergyoutogridcell(r,c,t)$(rliq(r)) ..         Eout(r,c,t)$(rliq(r)) =e= sum((cn),En(r,c,cn,t)$(rliq(r))) ;

maxbioenergytransp(r,c,t)$(rliq(r)) ..            Eout(r,c,t)$(rliq(r)) =l= E(r,c,t)$(rliq(r)) ;

biocharingridcell(r,c,t)$(rchr(r)) ..             E(r,c,t)$(rchr(r)) =e= HE(r,c,t)$(rchr(r)) ;