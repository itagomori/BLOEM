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
* Module: Biomass Conversion and Technologies Portfolio
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

$ontext
---------------------------------------------------------------
Portfolio of technologies:
---------------------------------------------------------------
ACG = agricultural residues cogeneration
FCG = forestry residues cogeneration
GCG = grass biomass cogeneration
WCG = wood biomass cogeneration

AFT = agricultural residues biojet fuel FT
FFT = forestry residues biojet fuel FT
GFT = grass biomass biojet fuel FT
WFT = wood biomass biojet fuel FT (forestry residues or woody energy crops)

AME = agricultural residues methanol generation
FWE = forestry residues methanol generation
GWE = grass biomass methanol generation
WME = wood biomass methanol generation (forestry residues or woody energy crops)

APY = agricultural residues pyrolysis for biochar
FPY = forestry residues pyrolysis for biochar
GPY = grass biomass pyrolysis for biochar
WPY = wood biomass pyrolysis for biochar (forestry residues or woody energy crops)

ACG+ = agricultural residues cogeneration with carbon capture
FCG+ = forestry residues cogeneration with carbon capture
GCG+ = grass biomass cogeneration with carbon capture
WCG+ = wood biomass cogeneration (forestry residues or woody energy crops) with carbon capture

AFT+ = agricultural residues biojet fuel FT with carbon capture
FFT+ = forestry residues biojet fuel FT with carbon capture
GFT+ = grass biomass biojet fuel FT with carbon capture
WFT+ = wood biomass biojet fuel FT (forestry residues or woody energy crops) with carbon capture

AME+ = agricultural residues methanol generation with carbon capture
FME+ = forestry residues methanol generation with carbon capture
GME+ = grass biomass methanol generation with carbon capture
WME+ = wood biomass methanol generation (forestry residues or woody energy crops) with carbon capture
---------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    tci(j,t)            'total capital investments' # [US$/kW]

    fom(j,t)            'fixed o&m costs' # [US$/kw]

    vom(j,t)            'variable o&m costs' # [US$/kw]

    w(j)                'technology discount factor'

    cjo(j,c,t)          'existing capacities in time t' # [GJ/y] [kw/y]

    cre(j,c,t)          'retirement of existing capacities' # [GJ/y] [kW/y]

    rf(j, tn, t)        'retire factor' # [factor, 0-1]

    cf(j,t)             'capacity factor' # [factor, 0-1]

    beta(r,j)           'ratio of consumption (inputs) or production (outputs)'

    mincp(j,t)          'biofuel production with CCS' # [GJ/yr]

;

* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Users\vicke\Desktop\model\BLOEM\BLOEM-GitHub\input\gdx\'

* Set technology discount factor w(j)
$gdxin '%gdxinfilepath%discfactorwj.gdx'

$load w = discfactorwj

$gdxin


* Set technology rate of consumptions or production of resource 'r'

$gdxin '%gdxinfilepath%techeffibeta.gdx'

$load beta = techeffibeta

$gdxin

* Set technologies total capital investment:

$gdxin '%gdxinfilepath%totalcapitalinvest.gdx'

$load tci = totalcapitalinvest

$gdxin


* Set operation and maintenance costs:

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


* ---------------------------------------------------------------------------------------------------------
* Declare variables
* ---------------------------------------------------------------------------------------------------------

Variables

    IBT(t)          'impact of biomass conversion in time t'  # [US$]
    ITCI(t)         'impact of capital investment in technologies in time t'  # [US$]
    ITOM(t)         'impact of OM of technologies in time t'  # [US$]

    CJ(j,c,t)       'installed capacity of technology j in grid cell c in time t'  # [kW] [GJ]
    CA(j,c,t)       'added capacity of technolog j in grid cell c in time t'  # [kW]
    CR(j,c,t)       'retired capacity of technology j in grid cell c in time t'  # [kW]

    CP(j,c,t)       'rate of operation of technology j in grid cell c in time t'

    E(r,c,t)        'bioenergy production for product r in grid cell c in time t'  # [kW] [GJ]

    EE(r,t)         'total bioenergy production per product per decade'  # [GJ]

    TCA(j,t)        'total capacity added per decade'  # [kW]

;

Positive variables IBC, ITCI, ITOM, CJ, CA, CR, CP, E, S, TCA ;

* Variable bounds
#CJ.up('ACG',c,t)=10e12;
#CJ.up('GCG',c,t)=10e12;
#CJ.up('FCG',c,t)=10e12;
#CJ.up('WCG',c,t)=10e12;
#CJ.up('AFT',c,t)=10e12;
#CJ.up('GFT',c,t)=10e12;
#CJ.up('FFT',c,t)=10e12;
#CJ.up('WFT',c,t)=10e12;
#CJ.up('AME',c,t)=10e12;
#CJ.up('GME',c,t)=10e12;
#CJ.up('FME',c,t)=10e12;
#CJ.up('WME',c,t)=10e12;
#CJ.up('APY',c,t)=10e12;
#CJ.up('GPY',c,t)=10e12;
#CJ.up('FPY',c,t)=10e12;
#CJ.up('WPY',c,t)=10e12;
#CJ.up('ACG+',c,t)=10e12;
#CJ.up('GCG+',c,t)=10e12;
#CJ.up('FCG+',c,t)=10e12;
#CJ.up('WCG+',c,t)=10e12;
#CJ.up('AFT+',c,t)=10e12;
#CJ.up('GFT+',c,t)=10e12;
#CJ.up('FFT+',c,t)=10e12;
#CJ.up('WFT+',c,t)=10e12;
#CJ.up('AME+',c,t)=10e12;
#CJ.up('GME+',c,t)=10e12;
#CJ.up('FME+',c,t)=10e12;
#CJ.up('WME+',c,t)=10e12;

* ---------------------------------------------------------------------------------------------------------
* Equations
* ---------------------------------------------------------------------------------------------------------

Equations

    impactbioconversion(t)          'impact of converting biomass into bioenergy'
    impactcapitalinvest(t)          'impact of total capital investment'
    impactoem(t)                    'impact of o&m costs'

    rateofoperation(j,c,t)          'rate of operation of technology j'

    capacitybalance(j,c,t)          'capacity balance of technology j'
    retiredcapacity(j,c,t)          'retired capacity of technology j'

    bioenergyconversion(r,c,t)      'production of bioenergy products'
    bioelectricityconversion(r,c,t) 'production of bioelectricity'
    
    totalbioenergy(r,t)             'total production per product per decade'
    totalbioelectricity(r,t)        'total production of bioelectricity per decade'
    totalcapadd(j,t)                'total capacity added per decade'
    biofuelswithccs(j,t)            'biofuels production with ccs per decade'
;

impactbioconversion(t) ..                       IBC(t) =e= ITCI(t)+ITOM(t) ;

impactcapitalinvest(t) ..                       ITCI(t) =e= dfb(t)*sum((j,c),w(j)*tci(j,t)*CA(j,c,t)) ;

impactoem(t) ..                                 ITOM(t) =e= dfa(t)*sum((j,c),(fom(j,t)*CJ(j,c,t)+vom(j,t)*CP(j,c,t))) ;


rateofoperation(j,c,t) ..                       CP(j,c,t) =l= CJ(j,c,t)*cf(j,t) ; # rate of operation = installed capacity * capacity factor


capacitybalance(j,c,t) ..                       CJ(j,c,t) =e= cjo(j,c,t)+CJ(j,c,t-1)+CA(j,c,t)-CR(j,c,t) ; # cjo=existing capacity in time t;

retiredcapacity(j,c,t) ..                       CR(j,c,t) =e= cre(j,c,t)+sum((tn),CA(j,c,tn)*rf(j,tn,t)) ;


bioenergyconversion(r,c,t)$(rpro(r)) ..         E(r,c,t)$(rpro(r)) =e= sum((j),CP(j,c,t)*beta(r,j)*uf) ;

bioelectricityconversion(r,c,t)$(rele(r)) ..    E(r,c,t)$(rele(r)) =e= sum((j),CP(j,c,t)*beta(r,j)) ;


totalbioenergy(r,t)$(rpro(r)) ..                EE(r,t)$(rpro(r)) =e= sum((c),E(r,c,t)$(rpro(r))) ;

totalbioelectricity(r,t)$(rele(r)) ..           EE(r,t)$(rele(r)) =e= sum((c),E(r,c,t)$(rele(r))) ;


totalcapadd(j,t) ..                             TCA(j,t) =e= sum((c),CA(j,c,t)) ;


biofuelswithccs(j,t)$(jccs(j)) ..               sum((r,c),CP(j,c,t)$(jccs(j))*beta(r,j)$(rpro(r))*uf) =g= mincp(j,t)$(jccs(j)); # constraints
