$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Author: Isabela Schmidt Tagomori
* Last update: 12.05.2021
* Version: 1.0
* Coupled IAM: BLUES
* Region: Brazil 
* Time frame: 2020-2050
* Module: Logistics
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    trco(r)             'biomass transportation costs' # [US$/GJ/km]

    mx(c,cn)            'distance between grid cells' # [km]

    mxe(c,cn)           'distance between grid cells - connection to demand' # [km] used in place of mx(c,cn) to reduce computational effort

    maxx                'maximum distance between grid cells for biomass logistics' # [km]

    tal(c)              'tortuosity factor' # [factor]

    flagbt(c,cn)        'flag to determine logistic interconnections for biomass' # [binary, 0:1]

    flagmxe(c,cn)       'flag to determine logistic interconnections for biofuels to consumer centers' # [binary, 0:1]

    flagmxein(cn,c)     'flag to determine logistic interconnections for biofuels to consumer centers' # [binary, 0:1]

    beta(r,j)           'ratio of consumption (inputs) or production (outputs)'

;


* Set biomass and biofuels transportation costs trco(r)

Parameter trco(r) / sugarcane          0.0020,
                    oilcrops           0.0011,
                    wood               0.0032,
                    ethanol1g          0.0040,
                    ethanol2g          0.0040,
                    biojet             0.0050,
                    dieselbiofuel      0.0050,
                    biodiesel          0.0040 /;
;


* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'X:\user\tagomorii\BLOEM\GDXinput\Main\'


* Import distance between grid cells mx(c,cn):

$gdxin '%gdxinfilepath%mxdistmax.gdx'

$load mx=mxdistmax

$gdxin


* Import distance between grid cells | connect to demand mwe(c,cn):

$gdxin '%gdxinfilepath%mxedistpopden.gdx'

$load mxe=mxedistmax

$gdxin


* Import tortuosity factors tal(c):

$gdxin '%gdxinfilepath%tortuosityfactor.gdx'

$load tal=totfactor

$gdxin


* Import flag to logistics interconnections flagbt(c,cn):

$gdxin '%gdxinfilepath%flagmx.gdx'

$load flagbt=flagmx

$gdxin


* Import grid cell connection to demand flagmxe(c,cn):

$gdxin '%gdxinfilepath%flagmxe.gdx'

$load flagmxe=flagmxe

$gdxin


* Import grid cell connection to demand flagmxe(c,cn):

$gdxin '%gdxinfilepath%flagmxein.gdx'

$load flagmxein=flagmxein

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

impactbiotransport(t) ..                        IBT(t) =e= dfa(t)*sum((r,c,cn),trco(r)$(rc(r))*Bn(r,c,cn,t)$(rc(r))*mx(c,cn)*tal(c)) ;


resourcebalance(r,c,t)$(rc(r)) ..               sum((l),B(r,l,c,t)$(rc(r)))+Bin(r,c,t)$(rc(r))-Bout(r,c,t)$(rc(r))+HB(r,c,t)$(rc(r)) =e= 0 ;

biomassintocell(r,c,t)$(rc(r)) ..               Bin(r,c,t)$(rc(r)) =e= sum((cn),Bn(r,cn,c,t)$(rc(r))*flagbt(cn,c)) ;

biomassoutocell(r,c,t)$(rc(r)) ..               Bout(r,c,t)$(rc(r)) =e= sum((cn),Bn(r,c,cn,t)$(rc(r))*flagbt(c,cn)) ;

maxbiomassoutocell(r,c,t)$(rc(r)) ..            Bout(r,c,t)$(rc(r)) =l= sum((l),B(r,l,c,t)$(rc(r))) ;


localdemandforcrops(r,c,t)$(rc(r)) ..           HB(r,c,t)$(rc(r)) =e= sum((j),CP(j,c,t)*beta(r,j)$(rc(r))*uf) ;


impactbioendtransport(t) ..                     IET(t) =e= dfa(t)*sum((r,c,cn),trco(r)$(rp(r))*En(r,c,cn,t)$(rp(r))*mxe(c,cn)*tal(c)) ;


bioenergybalance(r,c,t)$(rp(r)) ..              E(r,c,t)$(rp(r))+Ein(r,c,t)$(rp(r))-Eout(r,c,t)$(rp(r)) =e= HE(r,c,t)$(rp(r)) ;

bioenergyintogridcell(r,c,t)$(rp(r)) ..         Ein(r,c,t)$(rp(r)) =e= sum((cn),En(r,cn,c,t)$(rp(r))*flagmxein(cn,c)) ;

bioenergyoutogridcell(r,c,t)$(rp(r)) ..         Eout(r,c,t)$(rp(r)) =e= sum((cn),En(r,c,cn,t)$(rp(r))*flagmxe(c,cn)) ;

maxbioenergytransp(r,c,t)$(rp(r)) ..            Eout(r,c,t)$(rp(r)) =l= E(r,c,t)$(rp(r)) ;

