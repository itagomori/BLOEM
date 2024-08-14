$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Branch: BLOEM-Master
* Author: Isabela Schmidt Tagomori
* Last update: 14.08.2022
* Version: 2.0
* Module: Biomass Conversion and Technologies Portfolio
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

$ontext
---------------------------------------------------------------
Portfolio of technologies:                                           # list the technologies and acronyms here, see regional branches for examples
---------------------------------------------------------------
TEC = Technology
---------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    tci(j,t)            'total capital investments' # [US$/GJ] [US$/kW]

    fom(j,t)            'fixed o&m costs' # [US$/GJ] [US$/kW]

    vom(j,t)            'variable o&m costs' # [US$/GJ/y] [US$/kW/y]

    w(j)                'technology discount factor'

    cjo(j,c,t)          'existing capacities in time t1' # [GJ/y] [kW/y]

    cre(j,c,t)          'retirement of existing capacities' # [GJ/y] [kW/y]

    rf(j,tn,t)          'retirement factor' # [factor,0-1]

    cf(j,t)             'capacity factor' # [factor,0-1]

    beta(r,j)           'ratio of consumption (inputs) or production (outputs)'

    avj(r,j,t)          'operation mode for technologies with intermediates' # [binary, 0/1]

    minccs(j,t)         'minimum biofuel production with ccs' # [GJ/y]

;

* Set technology discount factor w(j)

Parameter w(j)   / TEC1    w1,         # substitute TEC and w, accordingly (for examples, see regional branches)         
                   TECX    wX /;
;

* Set technologies rate of consumption or production of resource 'r'

Table beta(r,j) 'ratio of consumption or production of resource r by technology j'  # [GJ/GJ]

                        TEC1        TECX        # substitute biomass/residue/etc., TEC and beta, accordingly (for examples, see regional branches)        
    biomass             beta1       beta2           
    residue             beta3       beta4           
    intermediate        beta5       beta6       
    product             beta7       beta8           
    coproduct           beta9       betaX       
;

* Set technologies mode of operation: for bagasse options

Table avj(r,j,t) 'operation mode for technologies with intermediates'  # [fraction] 0-1

                            t1      tX                 
    intermediate. TEC       avj     avj                   # substitute intermediate, TEC, t and avj, accordingly (for examples, see regional branches)                 
;

* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Path\'  # set your path for inputs


* Set technologies total capital investment (tci):

$gdxin '%gdxinfilepath%totalcapitalinvest.gdx'

$load tci = totalcapitalinvest

$gdxin


* Set operation and maintenance costs (fom/vom):

$gdxin '%gdxinfilepath%fixedom.gdx'

$load fom = fixedom

$gdxin


$gdxin '%gdxinfilepath%variableom.gdx'

$load vom = variableom

$gdxin


* Import existing capacity (cjo):

$gdxin '%gdxinfilepath%cjoexist.gdx'

$load cjo = cjoexist

$gdxin


* Import retirement of existing capacity (cre):

$gdxin '%gdxinfilepath%crminretire.gdx'

$load cre = crminretire

$gdxin


* Set technologies retirement factors for added capacities:

$gdxin '%gdxinfilepath%retirementfactor.gdx'

$load rf = retirementfactor

$gdxin


* Set technologies capacity factors

$gdxin '%gdxinfilepath%capacityfactor.gdx'

$load cf = capacityfactor

$gdxin


* Set minimum target for carbon capture

$gdxin '%gdxinfilepath%minbiofuelwithccs.gdx'

$load minccs = minbiofuelwithccs

$gdxin

;

* ---------------------------------------------------------------------------------------------------------
* Declare variables
* ---------------------------------------------------------------------------------------------------------

Variables

    IBC(t)          'impact of biomass conversion in time t'  # [US$]
    ITCI(t)         'impact of capital investment in technologies in time t'  # [US$]
    ITOM(t)         'impact of O&M of technologies in time t'  # [US$]

    CJ(j,c,t)       'installed capacity of technology j in grid cell c in time t'  # [GJ] [kW]
    CA(j,c,t)       'added capacity of technology j in grid cell c in time t'  # [GJ] [kW]
    CR(j,c,t)       'retired capacity of technology j in grid cell c in time t'  # [GJ] [kW]

    CP(j,c,t)       'rate of operation of technology j in grid cell c in time t'

    E(r,c,t)        'bioenergy production for product r in grid cell c in time t'  # [GJ] [kW]
    I(r,c,t)        'intermediates production for intermediate r in grid cell c in time t'  # [GJ] [kW]
    S(r,c,t)        'co-products production for co-product r in grid cell c in time t'  # [GJ] [kW]
    
    EE(r,t)         'total bioenergy production per product per decade' # [GJ]

    TCA(j,t)        'total capacity added per decade'  # [kW]

;

Positive variables IBC, ITCI, ITOM, CJ, CA, CR, CP, E, S, TCA;

* Variable bounds
CJ.up("TEC",c,t)=X;  # substitute TEC, use to limit installed capacity in a grid cell
CA.fx(j,c,"t")=0;  # substitute t, use to restrict adding capacity in a specific year (e.g. for techs that will develop in the future)

* ---------------------------------------------------------------------------------------------------------
* Equations
* ---------------------------------------------------------------------------------------------------------

Equations

    impactbioconversion(t)           'impact of converting biomass into bioenergy'
    impactcapitalinvest(t)           'impact of total capital investment'
    impactoem(t)                     'impact of o&m costs'

    rateofoperation(j,c,t)           'rate of operation of technology j'
    
    capacitybalance(j,c,t)           'capacity balance of technology j'
    retiredcapacity(j,c,t)           'retired capacity of technology j'

    bioenergyconversion(r,c,t)       'production of bioenergy products'
    bioelectricityconversion(r,c,t)  'production of bioelectricity'
    intermediateconversion(r,c,t)    'production of intermediates'
    coproductsconversion(r,c,t)      'production of co-products'

    intermediatebalance(r,c,t)       'intermediates balance in grid cell c in decade d'

    totalbioenergy(r,t)              'total production per product per decade'

    totalbioelectricity(r,t)         'total production of bioelectricity per decade'

    totalcapadd(j,t)                 'total capacity added per decade'

    biofuelswithccs(j,t)             'biofuels production with ccs per decade'

;

impactbioconversion(t) ..                       IBC(t) =e= ITCI(t)+ITOM(t) ;

impactcapitalinvest(t) ..                       ITCI(t) =e= dfb(t)*sum((j,c),w(j)*tci(j,t)*CA(j,c,t)) ;

impactoem(t) ..                                 ITOM(t) =e= dfa(t)*sum((j,c),(fom(j,t)*CJ(j,c,t)+vom(j,t)*CP(j,c,t))) ;


rateofoperation(j,c,t) ..                       CP(j,c,t) =l= CJ(j,c,t)*cf(j,t) ;


capacitybalance(j,c,t) ..                       CJ(j,c,t) =e= cjo(j,c,t)+CJ(j,c,t-1)+CA(j,c,t)-CR(j,c,t) ;

retiredcapacity(j,c,t) ..                       CR(j,c,t) =e= cre(j,c,t)+sum((tn),CA(j,c,tn)*rf(j,tn,t)) ;


bioenergyconversion(r,c,t)$(rliq(r) and rchr(r)) ..           E(r,c,t)$(rliq(r) and rchr(r)) =e= sum((j),CP(j,c,t)*beta(r,j)*uf) ;

bioelectricityconversion(r,c,t)$(rele(r)) ..                  E(r,c,t)$(rele(r)) =e= sum((j),CP(j,c,t)*beta(r,j)) ;

intermediateconversion(r,c,t)$(rint(r)) ..                    I(r,c,t)$(rint(r)) =e= sum((j),CP(j,c,t)*beta(r,j)*uf*avj(r,j,t)) ;

coproductsconversion(r,c,t)$(rcop(r)) ..                      S(r,c,t)$(rcop(r)) =e= sum((j),CP(j,c,t)*beta(r,j)*uf) ;


intermediatebalance(r,c,t)$(rint(r)) ..                       I(r,c,t)$(rint(r)) =e= 0 ;


totalbioenergy(r,t)$(rpro(r)) ..                              EE(r,t)$(rpro(r)) =e= sum((c),E(r,c,t)$(rpro(r)));

totalbioelectricity(r,t)$(rele(r)) ..                         EE(r,t)$(rele(r)) =e= sum((c),E(r,c,t)$(rele(r)));


totalcapadd(j,t) ..                                           TCA(j,t) =e= sum((c),CA(j,c,t)) ;


biofuelswithccs(j,t)$(jccs(j)) ..                             sum((r,c),CP(j,c,t)$(jccs(j))*beta(r,j)$(rpro(r))*uf) =e= mincp(j,t)$(jccs(j)) ;
