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
* Module: Logistics
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    trco(r)             'biomass transportation costs'  # [US$/GJ/km]

    mx(c,cn)            'distance between grid cells'  # [km]

    mxairhbr(c,cn)      'distance between grid cells, connection to demand (airports/harbours)'  # [km]

    #mxair(c,cn)        'distance between grid cells to airport' # [km]
    #mxharbor(c,cn)     'distance between grid cells to harbor' # [km]
    
    tal(c)              'tortuosity factor'  # [factor]
    
    beta(r,j)           'ratio of consumption (inputs) or production (outputs)'

;

* Set biomass and biofuels transportation costs trco(r)

Parameter trco(r) / agrires          0.0020,
                    foresres         0.0020,
                    grass            0.0011,
                    wood             0.0032,
                    biojet           0.0040,
                    biomethanol      0.0050 /;
;

* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepaht 'C:\Users\vicke\Desktop\model\BLOEM\BLOEM-GitHub\input\gdx\'


* Import distance between grid cells mx(c,cn):
# columns: c, cn, value
# 300 km radius currently applied

$gdxin '%gdxinfilepath%mxdis.gdx'

$load mx=mxdis

$gdxin


* Import distance between grid cells, connection to demand (airports/harbours) mxairhbr(c,cn):

$gdxin '%gdxinfilepath%mxairhbrdis.gdx'

$load mxairhbr=mxairhbrdis

$gdxin


* Import tortalsity factor(c):
# columns: c, value

$gdxin '%gdxinfilepath%tortuosity.gdx'

$load tal=tortuosity

$gdxin

;

* ---------------------------------------------------------------------------------------------------------
* Declare variables
* ---------------------------------------------------------------------------------------------------------

Variables

    IBT(t)          'impact of biomass transportation in time t' #[US$]
    IET(t)          'impact of bioenergy transportation in time t' #[US$]

    HB(r,c,t)       'local biomass consumption for crop r in grid cell c in time t'
    HE(r,c,t)       'local bioenergy consumption for product r in grid cell c in time t'

    Bn(r,c,cn,t)    'biomass flow for crop r between grid cells c and cn in time t'
    En(r,c,cn,t)    'bioenergy flow for product r between grid cells c and cn in time t'

    Bin(r,c,t)      'crop r into grid cell c in time t'
    Bout(r,c,t)     'crop r out of grid cell c in time t'

    Ein(r,c,t)      'biofuel r into grid cell c'
    Eout(r,c,t)     'biofuel r out of grid cell c'

    B(r,l,c,t)      'biomass production for crop r in grid cell c in time t' # [GJ]
    E(r,c,t)        'bioenergy production for product r in grid cell c in time t' # [GJ] [kw]

    CP(j,c,t)       'rate of operation of technology j in grid cell c in time t'
;

Positive variables IBT, IET, HE, Bn, En, Bin, Bout, Ein, Eout, E, CP;

* Variable bounds:
HB.up(r,c,t)=0;

# Biochar can only be consumed in the grid cell where it is produced
En.fx("biochar",c,cn,t)=0;

* ---------------------------------------------------------------------------------------------------------
* Equations
* ---------------------------------------------------------------------------------------------------------

Equations

    impactbiotransport(t)                   'impact of transporting biomass among grid cells'

    resourcebalance(r,c,t)                  'resource balance in each grid cell'
    biomassintocell(r,c,t)                  'biomass into grid cell'
    biomassoutocell(r,c,t)                  'biomass out of grid cell'
    maxbiomassoutocell(r,c,t)               'max biomassout of grid cell'

    localdemandforcrops(r,c,t)              'local demand for crops due to technology operation' # is this based on biojet and biomethanol?

    impactbioendtransport(t)                'impact of transporting bioenergy from production to demand grid cells'

    bioenergybalance(r,c,t)                 'bioenergy balance in grid cell cin decade d'
    bioenergyintogridcell(r,c,t)            'bioenergy into grid cell'
    bioenergyoutogridcell(r,c,t)            'bioenergy out of grid cell'
    maxbioenergytransp(r,c,t)               'max bioenergy out of grid cell'

    biocharingridcell(r,c,t)                'the production of biochar in the grid cell can only be consumed locally'

;

impactbiotransport(t) ..                            IBT(t) =e= dfa(t)*sum((r,c,cn),trco(r)$(rsou(r))*Bn(r,c,cn,t)$(rsou(r))*mx(c,cn)*tal(c)) ;


resourcebalance(r,c,t)$(rsou(r)) ..                 sum((l),B(r,l,c,t)$(rsou(r)))+Bin(r,c,t)$(rsou(r))-Bout(r,c,t)$(rsou(r))+HB(r,c,t)$(rsou(r)) =e= 0 ;

biomassintocell(r,c,t)$(rsou(r)) ..                 Bin(r,c,t)$(rsou(r)) =e= sum((cn),Bn(r,cn,c,t)$(rsou(r))) ;

biomassoutocell(r,c,t)$(rsou(r)) ..                 Bout(r,c,t)$(rsou(r)) =e= sum((cn),Bn(r,c,cn,t)$(rsou(r))) ;

maxbiomassoutocell(r,c,t)$(rsou(r)) ..              Bout(r,c,t)$(rsou(r)) =l= sum((l),B(r,l,c,t)$(rsou(r))) ;

# HB means local biomass consumption of crop c in grid cell c
localdemandforcrops(r,c,t)$(rsou(r)) ..             HB(r,c,t)$(rsou(r)) =e= sum((j),CP(j,c,t)*beta(r,j)$(rsou(r))*uf) ;


impactbioendtransport(t) ..                         IET(t) =e= dfa(t)*sum((r,c,cn),trco(r)$(rliq(r))*En(r,c,cn,t)$(rliq(r))*mxairhbr(c,cn)*tal(c)) ;

# HE means local bioenergy consumption in grid cell c;
bioenergybalance(r,c,t)$(rliq(r)) ..                E(r,c,t)$(rliq(r))+Ein(r,c,t)$(rliq(r))-Eout(r,c,t)$(rliq(r)) =e= HE(r,c,t)$(rliq(r)) ;

bioenergyintogridcell(r,c,t)$(rliq(r)) ..           Ein(r,c,t)$(rliq(r)) =e= sum((cn),En(r,cn,c,t)$(rliq(r))) ;

bioenergyoutogridcell(r,c,t)$(rliq(r)) ..           Eout(r,c,t)$(rliq(r)) =e= sum((cn),En(r,c,cn,t)$(rliq(r))) ;

maxbioenergytransp(r,c,t)$(rliq(r)) ..              Eout(r,c,t)$(rliq(r)) =l= E(r,c,t)$(rliq(r)) ;

biocharingridcell(r,c,t)$(rchr(r)) ..               E(r,c,t)$(rchr(r)) =e= HE(r,c,t)$(rchr(r)) ;
