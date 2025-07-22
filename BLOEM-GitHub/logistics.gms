$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Author: Isabela Schmidt Tagomori & Aline Carvalho
* Last update: 10.08.2024
* Version: 1.0
* Coupled IAM: COFFEE
* Region: Europe
* Time frame: 2025
* Module: Logistics
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    trco(r)             'biomass transportation costs' # [US$/GJ/km]

    fixMtrco(r)         'fixed maritime biomass transportation costs' # [US$/GJ]

    varMtrco(r)         'variable maritime biomass transportation costs' # [US$/GJ/km]

    mx(c,cn)            'distance between grid cells' # [km]

    mxe(c,cn)           'distance between grid cells - connection to demand' # [km] used in place of mx(c,cn) to reduce computational effort

    mmx(c,cn)           'distance between grid cells for maritime routes' # [km]
    
    maxx                'maximum distance between grid cells for biomass logistics' # [km]

    tal(c)              'tortuosity factor' # [factor]

    flagmx(c,cn)        'flag to determine logistc road interconnections for biomass' # [binary, 0:1]

    flagmmx(c,cn)       'flag to determine logistic maritime interconnections for biomass' # [binary, 0:1]

    flagmxe(c,cn)       'flag to determine logistic interconnections for biofuels to consumer centers' # [binary, 0:1]

    flagmxein(cn,c)     'flag to determine logistic interconnections for biofuels to consumer centers' # [binary, 0:1]

    beta(r,j)           'ratio of consumption (inputs) or production (outputs)'

;


* Set biomass and biofuels transportation variable costs trco(r)

Parameter trco(r) / foresres               0.006 /;
;

* Set biomass and biofuels transportation fixed costs fixMtrco(r)

Parameter fixMtrco(r) / foresres               0.75 /;

* Set maritime biomass transportation variable costs varMtrco(r)

Parameter varMtrco(r) / foresres               0.0004 /;
;

* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\BLOEM\github\input\'


* Import distance between grid cells mx(c,cn):

$gdxin '%gdxinfilepath%mxdistmax.gdx'

$load mx=mxdistmax

$gdxin


* Import distance between grid cells mmx(c,cn):

$gdxin '%gdxinfilepath%mmxdist.gdx'

$load mmx=mmxdist

$gdxin


* Import distance between grid cells | connect to demand mwe(c,cn):

#$gdxin '%gdxinfilepath%mxedistpopden.gdx'

#$load mxe=mxedistmax

#$gdxin


* Import tortuosity factors tal(c):

$gdxin '%gdxinfilepath%tortuosityfactor.gdx'

$load tal=totfactor

$gdxin


* Import flag to logistics interconnections flagmx(c,cn):

$gdxin '%gdxinfilepath%flagmx.gdx'

$load flagmx=flagmx

$gdxin

* Import flag to logistics interconnections flagmmx (c,cn):

$gdxin '%gdxinfilepath%flagmmx.gdx'

$load flagmmx=flagmmx

$gdxin


* Import grid cell connection to demand flagmxe(c,cn):

#$gdxin '%gdxinfilepath%flagmxe.gdx'

#$load flagmxe=flagmxe

#$gdxin


* Import grid cell connection to demand flagmxe(c,cn):

#$gdxin '%gdxinfilepath%flagmxein.gdx'

#$load flagmxein=flagmxein

#$gdxin

;

* ---------------------------------------------------------------------------------------------------------
* Declare variables
* ---------------------------------------------------------------------------------------------------------

Variables

    IBT(t)          'impact of biomass transportation in time t'  # [US$]
    IRBT(t)         'impact of biomass road transportation in time t'  # [US$]
    IMBT(t)         'impact of biomass maritime transportation in time t'  # [US$]
    #IET(t)          'impact of bioenergy transportation in time t'  # [US$]

    HB(r,c,t)       'local biomass consumption for crop r in grid cell c in time t'
    HE(r,c,t)       'local bioenergy consumption for product r in grid cell c in time t'

    Bn(r,c,cn,t)    'biomass flow for crop r between grid cells c and cn in time t'
    #En(r,c,cn,t)    'bioenergy flow for product r between grid cells c and cn in time t'

    Bin(r,c,t)      'crop r into grid cell c in time t'
    Bout(r,c,t)     'crop r out of grid cell c in time t'

    Bmar(r,l,c,t)   'total biomass to be transported in maritime through port c per crop r in time t' # [GJ]
    Bmarn(r,c,cn,t) 'biomass flow for crop r between port cells c and cn in time t' # [GJ]

    Bmarin(r,c,t)   'crop r into port cell c in time t'
    Bmarout(r,c,t)  'crop r out of port cell c in time t'

    Ein(r,c,t)      'biofuel r into grid cell c'
    Eout(r,c,t)     'biofuel r out of grid cell c'

    B(r,l,c,t)      'biomass production for crop r in land type l in grid cell c in time t'  # [GJ]
    E(r,c,t)        'bioenergy production for product r in grid cell c in time t'  # [GJ] [kW]

    CP(j,c,t)       'rate of operation of technology j in grid cell c in time t'

;

Positive variables IBT, IET, HE, Bn, Bin, Bout, B, Bmarin, Bmarn, Bmarout, E, CP; #Ein, Eout, En, Bmar, 

* Variable bounds:
HB.up(r,c,t)=0;
#Bmarin.up(r,c,t)=0;
#Bmarout.fx(r,c,t)=0;

* Flows of biofuels not allowed:
Ein.fx(r,c,t)=0;
Eout.fx(r,c,t)=0;


* ---------------------------------------------------------------------------------------------------------
* Equations
* ---------------------------------------------------------------------------------------------------------

Equations

    impactbiotransport(t)            'impact of transporting biomass among grid cells'
    impactroadbiotransport(t)        'impact of road transporting biomass among grid cells'
    impactmaritimebiotransport(t)    'impact of maritime transporting biomass among grid cells'

    resourcebalance(r,c,t)           'resource balance in each grid cell'
    biomassintocell(r,c,t)           'biomass into grid cell'
    biomassoutocell(r,c,t)           'biomass out of grid cell'
    maxbiomassoutocell(r,c,t)        'max biomass out of grid cell'

    resourcemaritimebalance(r,c,t)    'resource balance in the maritime port grid cell'
    biomassmaritimeintocell(r,c,t)    'biomass into maritime port grid cell'
    biomassmaritimeoutocell(r,c,t)    'biomass out of maritime port grid cell'
    #maxbiomassmaritimeoutocell(r,c,t)  'max biomass transported in maritime grid cell'


    #totalbiomasstransported(r,c,t)  'total biomass transported through maritime'

    localdemandforcrops(r,c,t)       'local demand for crops due to technology operation'

    #impactbioendtransport(t)         'impact of transporting bioenergy from production to demand grid cells'

    bioenergybalance(r,c,t)          'bioenergy balance in grid cell c in decade d'
    #bioenergyintogridcell(r,c,t)     'bioenergy into grid cell'
    #bioenergyoutogridcell(r,c,t)     'bioenergy out of grid cell'
    #maxbioenergytransp(r,c,t)        'max bioenergy out of grid cell'

;

#impactbiotransport(t) ..                          IBT(t) =e= dfa(t)*(sum((r,c,cn),(Bn(r,c,cn,t)$(rres(r))*(trco(r)$(rres(r))*mx(c,cn)*tal(c))))) ;

impactbiotransport(t) ..                          IBT(t) =e= IRBT(t)+IMBT(t) ;

impactroadbiotransport(t) ..                      IRBT(t) =e= dfa(t)*(sum((r,c,cn),(Bn(r,c,cn,t)$(rres(r))*(trco(r)$(rres(r))*mx(c,cn)*tal(c))))) ;

impactmaritimebiotransport(t) ..                  IMBT(t) =e= dfa(t)*(sum((r,c,cn),(Bmarn(r,c,cn,t)$(ps(c))*mmx(c,cn)*varMtrco(r)$(rres(r))))+sum((r,c),(Bmarout(r,c,t)$(ps(c))*fixMtrco(r)$(rres(r))))) ;


#resourcemaritimebalance(r,c,t)$(rres(r)) ..       sum((l),Bmar(r,l,c,t)$(rres(r)))+Bmarin(r,c,t)$(rres(r))-Bmarout(r,c,t)$(rres(r))+HB(r,c,t)$(rres(r)) =e= 0 ;
resourcemaritimebalance(r,c,t)$(rres(r)) ..       Bmarin(r,c,t)$(rres(r))+HB(r,c,t)$(rres(r)) =e= 0 ; #-Bmarout(r,c,t)$(rres(r))

biomassmaritimeintocell(r,c,t)$(rres(r)) ..       Bmarin(r,c,t)$(rres(r)) =e= sum((cn),Bmarn(r,cn,c,t)$(rres(r))*flagmmx(cn,c)) ;

biomassmaritimeoutocell(r,c,t)$(rres(r)) ..       Bmarout(r,c,t)$(rres(r)) =e= sum((cn),Bmarn(r,c,cn,t)$(rres(r))*flagmmx(c,cn)) ;

#maxbiomassmaritimeoutocell(r,c,t)$(rres(r)) ..    Bmarout(r,c,t)$(rres(r)) =l= sum((l),Bmar(r,l,c,t)$(rres(r))) ;


#totalbiomasstransported(r,c,t)$(ps(c)) ..         Bmarin(r,c,t)$(ps(c))+sum((cn),Bn(r,cn,c,t)$(ps(c))*flagmx(cn,c))+sum((l),B(r,l,c,t)$(ps(c))) =e= 0 ;
#totalbiomasstransported(r,c,t)$(ps(c)) ..         Bmar(r,c,t)$(ps(c)) =e= sum((c),HB(r,c,t)$(rres(r))) ;


resourcebalance(r,c,t)$(rres(r)) ..               sum((l),B(r,l,c,t)$(rres(r)))+Bin(r,c,t)$(rres(r))-Bout(r,c,t)$(rres(r))-Bmarout(r,c,t)$(rres(r)) =e= 0 ;

biomassintocell(r,c,t)$(rres(r)) ..               Bin(r,c,t)$(rres(r)) =e= sum((cn),Bn(r,cn,c,t)$(rres(r))*flagmx(cn,c)) ;

biomassoutocell(r,c,t)$(rres(r)) ..               Bout(r,c,t)$(rres(r)) =e= sum((cn),Bn(r,c,cn,t)$(rres(r))*flagmx(c,cn)) ;

maxbiomassoutocell(r,c,t)$(rres(r)) ..            Bout(r,c,t)$(rres(r)) =l= sum((l),B(r,l,c,t)$(rres(r))) ;


localdemandforcrops(r,c,t)$(rres(r)) ..           HB(r,c,t)$(rres(r)) =e= sum((j),CP(j,c,t)*beta(r,j)$(rres(r))*uf) ;


#impactbioendtransport(t) ..                      IET(t) =e= dfa(t)*sum((r,c,cn),trco(r)$(rliq(r))*En(r,c,cn,t)$(rliq(r))*mxe(c,cn)*tal(c)) ;


bioenergybalance(r,c,t)$(rliq(r)) ..              E(r,c,t)$(rliq(r))+Ein(r,c,t)$(rliq(r))-Eout(r,c,t)$(rliq(r)) =e= HE(r,c,t)$(rliq(r)) ;

#bioenergyintogridcell(r,c,t)$(rliq(r)) ..        Ein(r,c,t)$(rliq(r)) =e= sum((cn),En(r,cn,c,t)$(rliq(r))*flagmxein(cn,c)) ;

#bioenergyoutogridcell(r,c,t)$(rliq(r)) ..        Eout(r,c,t)$(rliq(r)) =e= sum((cn),En(r,c,cn,t)$(rliq(r))*flagmxe(c,cn)) ;

#maxbioenergytransp(r,c,t)$(rliq(r)) ..           Eout(r,c,t)$(rliq(r)) =l= E(r,c,t)$(rliq(r)) ;

