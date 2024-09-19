$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Author: Isabela Schmidt Tagomori & Aline Carvalho
* Last update: 10.08.2024
* Version: 1.0
* Coupled IAM: COFFEE
* Region: Europe 
* Time frame: 2025
* Module: Biomass Conversion
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

$ontext
---------------------------------------------------------------
Portfolio of technologies:
---------------------------------------------------------------
POFCC = Pyrolysis Oil in FCC
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

    v                   'discount rate' # used only for pre-processing (calculating the discount factor)

    p                   'period in lifetime of a technology facility' # used only for pre-processing (calculating the discount factor)

    lf(j)               'lifetime of a technology facility' # [y] used only for pre-processing (calculating the discount factor)

    cjo(j,c,t)          'existing capacities in time t1' # [GJ/y] [kW/y]

    cre(j,c,t)          'retirement of existing capacities' # [GJ/y] [kW/y]

    rf(j,tn,t)          'retirement factor' # [factor,0-1]

    cf(j,t)             'capacity factor' # [factor,0-1]

    beta(r,j)           'ratio of consumption (inputs) or production (outputs)'

    avj(r,j,t)          'operation mode for technologies with intermediates' # [binary, 0/1]

    mincp(j,t)          'biofuel production with ccs' # [GJ/y]

;

* Set technologies total capital investments

Table tci(j,t) 'total capital investment for technology j in grid cell c in decade d'  # [US$/kW]

                2025        #2030        2040        2050        
    PO          5528       
    POFCC       5528        #5528        5528        5528        
  ;

* Set technologies fixed o&m costs

Table fom(j,t) 'fixed O&M costs for technology j in grid cell c in decade d'  # [US$/kW/y]

                2025        #2030        2040        2050         
    PO          223
    POFCC       223         #223         223         223         
;

* Set technologies variable o&m costs

Table vom(j,t) 'variable O&M costs for technology j in grid cell c in decade d'  # [US$/kWy]

                2025        #2030        2040        2050         
    PO          0
    POFCC       0           #0           0           0           

;

* Set technology discount factor w(j)

Parameter w(j)   / PO       0.9807549, 
                   POFCC    0.9807549/;
;

* Set technologies retirement factors for added capacities

Table rf(j,tn,t) 'retirement factor of capacity added in time tn'

                2025        #2030        2040        2050        
    PO. 2025      0 
    POFCC. 2025   0          # 0           0           1           
    #SGC. 2030   0           0           0           0           
    #SGC. 2040   0           0           0           0           
    #SGC. 2050   0           0           0           0                
;

* Set technologies capacity factors

Table cf(j,t) 'capacity factors'  # [factor 0-1]

                2025        #2030        2040        2050        
    PO            1
    POFCC         1           #1           1           1           

;

* Set technologies rate of consumption or production of resource 'r'

Table beta(r,j) 'ratio of consumption or production of resource r by technology j'  # [GJ/GJ]

                          PO      POFCC 
    foresres             -1        0 
    pyrolysisoil          1        -1
    biogasoil             0        1  
    greendiesel           0        1
    bionaphta             0        1
;

* Set technologies mode of operation: for bagasse options

Table avj(r,j,t) 'operation mode for technologies with intermediates'  # [fraction] 0-1

                           2025    #2030    2040    2050             
    pyrolysisoil. PO        1       #1       1       1              
    pyrolysisoil. POFCC     1 


* Set production of biofuels with CCS

#Table mincp(j,t) 'biofuel production with ccs'

#                2025        #2030        2040        2050        
#    PO           0    
#    POFCC        0                   
#;

* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\BLOEM\BLOEMEurope_GAMS\gdx_files\output\'


* Import existing capacity (cjo):

$gdxin '%gdxinfilepath%cjoexist.gdx'

$load cjo=cjoexist

$gdxin


* Import retirement of existing capacity (crmin):

$gdxin '%gdxinfilepath%crminretire.gdx'

$load cre=crminretire

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
CJ.up("POFCC",c,t)=10e6;

#CA.fx(j,c,"2025")=0;


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


bioenergyconversion(r,c,t)$(rliq(r)) ..           E(r,c,t)$(rliq(r)) =e= sum((j),CP(j,c,t)*beta(r,j)*uf) ;

#bioelectricityconversion(r,c,t)$(re(r)) ..      E(r,c,t)$(re(r)) =e= sum((j),CP(j,c,t)*beta(r,j)) ;

intermediateconversion(r,c,t)$(rint(r)) ..        I(r,c,t)$(rint(r)) =e= sum((j),CP(j,c,t)*beta(r,j)*uf*avj(r,j,t)) ;

coproductsconversion(r,c,t)$(rcop(r)) ..          S(r,c,t)$(rcop(r)) =e= sum((j),CP(j,c,t)*beta(r,j)*uf) ;


intermediatebalance(r,c,t)$(rint(r)) ..           I(r,c,t)$(rint(r)) =e= 0 ;


totalbioenergy(r,t) ..                          EE(r,t)$(rliq(r)) =e= sum((c),E(r,c,t)$(rliq(r)));

#totalbioelectricity(r,t) ..                     EE(r,t)$(re(r)) =e= sum((c),E(r,c,t)$(re(r)));

totalcapadd(j,t) ..                             TCA(j,t) =e= sum((c),CA(j,c,t)) ;

#biofuelswithccs(j,t)$(jc(j)) ..                 sum((r,c),CP(j,c,t)$(jc(j))*beta(r,j)$(rp(r))*uf) =e= mincp(j,t)$(jc(j)) ;
