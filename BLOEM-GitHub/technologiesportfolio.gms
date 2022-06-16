$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Author: Isabela Schmidt Tagomori
* Last update: 12.05.2021
* Version: 1.0
* Coupled IAM: BLUES
* Region: Brazil 
* Time frame: 2020-2050
* Module: Biomass Conversion
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

$ontext
---------------------------------------------------------------
Portfolio of technologies:
---------------------------------------------------------------
SGC = Sugarcane Crushing
COG = Bagasse Cogeneration
E1G = Ethanol 1st Generation
E2G = Ethanol 2nd Generation
BJT = Biojet Fuel FT
DFT = Green Diesel FT
BDS = Biodiesel
E1GC = Ethanol 1st Generation with Carbon Capture
BJTC = Biojet Fuel FT with Carbon Capture
DFTC = Green Diesel FT with Carbon Capture
SUG = Sugar Production
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

                2020        2030        2040        2050        
    SGC         1           1           1           1           
    E1G         647         647         647         647         
    E2G         1400        1400        1400        1400        
    BJT         5528        5528        5528        5528        
    DFT         5350        5350        5350        5350        
    BDS         21          21          21          21          
    COG         1304        1304        1304        1304        
    E1GC        650         650         650         650               
    BJTC        5600        5600        5600        5600        
    DFTC        5420        5420        5420        5420
    SUG         0           0           0           0        
;

* Set technologies fixed o&m costs

Table fom(j,t) 'fixed O&M costs for technology j in grid cell c in decade d'  # [US$/kW/y]

                2020        2030        2040        2050        
    SGC         0           0           0           0           
    E1G         10          10          10          10          
    E2G         110         110         110         110         
    BJT         223         223         223         223         
    DFT         217         217         217         217         
    BDS         8           8           8           8           
    COG         24          24          24          24          
    E1GC        11          11          11          11          
    BJTC        227         227         227         227         
    DFTC        220         220         220         220  
    SUG         0           0           0           0       
;

* Set technologies variable o&m costs

Table vom(j,t) 'variable O&M costs for technology j in grid cell c in decade d'  # [US$/kWy]

                2020        2030        2040        2050        
    SGC         1           1           1           1           
    E1G         0           0           0           0           
    E2G         50          50          50          50          
    BJT         0           0           0           0           
    DFT         0           0           0           0           
    BDS         78          78          78          78          
    COG         0           0           0           0           
    E1GC        0           0           0           0           
    BJTC        0           0           0           0           
    DFTC        0           0           0           0
    SUG         0           0           0           0           
;

* Set technology discount factor w(j)

Parameter w(j)   / SGC    0.9807549,
                   E1G    0.9807549,
                   E2G    0.9807549,
                   BJT    0.9141061,
                   DFT    0.9141061,
                   BDS    0.8153025,
                   COG    0.9807549,
                   E1GC   0.9807549,
                   BJTC   0.9141061
                   DFTC   0.9141061,
                   SUG    0.0000000 /;
;

* Set technologies retirement factors for added capacities

Table rf(j,tn,t) 'retirement factor of capacity added in time tn'

                2020        2030        2040        2050        
    SGC. 2020   0           0           0           1           
    SGC. 2030   0           0           0           0           
    SGC. 2040   0           0           0           0           
    SGC. 2050   0           0           0           0           
    
    E1G. 2020   0           0           0           1           
    E1G. 2030   0           0           0           0           
    E1G. 2040   0           0           0           0           
    E1G. 2050   0           0           0           0           
    
    E2G. 2020   0           0           0           1           
    E2G. 2030   0           0           0           0           
    E2G. 2040   0           0           0           0           
    E2G. 2050   0           0           0           0           
    
    BJT. 2020   0           0           0.5         0.5         
    BJT. 2030   0           0           0           0.5         
    BJT. 2040   0           0           0           0           
    BJT. 2050   0           0           0           0           
    
    DFT. 2020   0           0           0.5         0.5         
    DFT. 2030   0           0           0           0.5         
    DFT. 2040   0           0           0           0           
    DFT. 2050   0           0           0           0           
    
    BDS. 2020   0           0           1           0           
    BDS. 2030   0           0           0           1           
    BDS. 2040   0           0           0           0           
    BDS. 2050   0           0           0           0           
    
    COG. 2020   0           0           0           1           
    COG. 2030   0           0           0           0           
    COG. 2040   0           0           0           0           
    COG. 2050   0           0           0           0           
    
    E1GC. 2020  0           0           0           1           
    E1GC. 2030  0           0           0           0           
    E1GC. 2040  0           0           0           0           
    E1GC. 2050  0           0           0           0           
    
    BJTC. 2020  0           0           0.5         0.5         
    BJTC. 2030  0           0           0           0.5         
    BJTC. 2040  0           0           0           0           
    BJTC. 2050  0           0           0           0           
    
    DFTC. 2020  0           0           0.5         0.5         
    DFTC. 2030  0           0           0           0.5         
    DFTC. 2040  0           0           0           0           
    DFTC. 2050  0           0           0           0

    SUG. 2020   0           0           0           0           
    SUG. 2030   0           0           0           0           
    SUG. 2040   0           0           0           0           
    SUG. 2050   0           0           0           0           
    
;

* Set technologies capacity factors

Table cf(j,t) 'capacity factors'  # [factor 0-1]

                2020        2030        2040        2050        
    SGC         1           1           1           1           
    E1G         1           1           1           1         
    E2G         1           1           1           1        
    BJT         1           1           1           1        
    DFT         1           1           1           1        
    BDS         1           1           1           1          
    COG         1           1           1           1        
    E1GC        1           1           1           1               
    BJTC        1           1           1           1        
    DFTC        1           1           1           1    
    SUG         1           1           1           1    
;

* Set technologies rate of consumption or production of resource 'r'

Table beta(r,j) 'ratio of consumption or production of resource r by technology j'  # [GJ/GJ]

                        SGC         E1G         E2G         BJT         DFT         BDS         COG         E1GC        BJTC        DFTC        SUG 
    sugarcane           -1          0           0           0           0           0           0           0           0           0           0
    oilcrops            0           0           0           0           0           -2.44       0           0           0           0           0
    wood                0           0           0           -2.13       -2.38       0           0           0           -2.13       -2.38       0
    bagasse             0.56        0           -2.70       0           0           0           -1.15       0           0           0           0    
    sgcnjuice           0.18        -0.45       0           0           0           0           0           -0.45       0           0           -1
    ethanol1g           0           1           0           0           0           0           0           1           0           0           0
    ethanol2g           0           0           1           0           0           0           0           0           0           0           0
    biojet              0           0           0           1           0           0           0           0           1           0           0
    dieselbiofuel       0           0           0           0           1           0           0           0           0           1           0
    biodiesel           0           0           0           0           0           1           0           0           0           0           0
    bioelectricity      0           0           0           0           0           0           1           0           0           0           0
    bionaphta           0           0           0           0.36        0.40        0           0           0           0.36        0.40        0
    biolpg              0           0           0           0.36        0.35        0           0           0           0.36        0.35        0
    sugarjuice          0           0           0           0           0           0           0           0           0           0           1
;

* Set technologies mode of operation: for bagasse options

Table avj(r,j,t) 'operation mode for technologies with intermediates'  # [fraction] 0-1

                        2020    2030    2040    2050             
    bagasse. SGC        1       1       1       1              
    bagasse. E2G        1       1       1       1              
    bagasse. COG        1       1       1       1              

    sgcnjuice. SGC      1       1       1       1              
    sgcnjuice. E1G      1       1       1       1       
    sgcnjuice. E1GC     0       1       1       1     
    sgcnjuice. SUG      0       0       0       0                
;


* Set production of biofuels with CCS

Table mincp(j,t) 'biofuel production with ccs'

                2020        2030        2040        2050        
    E1GC        0           0.01e8      0.40e8      0.63e8               
    BJTC        0           0           0           0        
    DFTC        0           0           0.36e8      3.76e8    
;

* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'X:\user\tagomorii\BLOEM\GDXinput\Main\'


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
CJ.up("E1G",c,t)=10e6;
CJ.up("E2G",c,t)=10e6;
CJ.up("BDS",c,t)=10e6;
CJ.up("BJT",c,t)=100e6;
CJ.up("DFT",c,t)=100e6;
CJ.up("E1GC",c,t)=10e6;
CJ.up("BJTC",c,t)=100e6;
CJ.up("DFTC",c,t)=100e6;
CA.fx(j,c,"2020")=0;


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


bioenergyconversion(r,c,t)$(rp(r)) ..           E(r,c,t)$(rp(r)) =e= sum((j),CP(j,c,t)*beta(r,j)*uf) ;

bioelectricityconversion(r,c,t)$(re(r)) ..      E(r,c,t)$(re(r)) =e= sum((j),CP(j,c,t)*beta(r,j)) ;

intermediateconversion(r,c,t)$(ri(r)) ..        I(r,c,t)$(ri(r)) =e= sum((j),CP(j,c,t)*beta(r,j)*uf*avj(r,j,t)) ;

coproductsconversion(r,c,t)$(rs(r)) ..          S(r,c,t)$(rs(r)) =e= sum((j),CP(j,c,t)*beta(r,j)*uf) ;


intermediatebalance(r,c,t)$(ri(r)) ..           I(r,c,t)$(ri(r)) =e= 0 ;


totalbioenergy(r,t) ..                          EE(r,t)$(rp(r)) =e= sum((c),E(r,c,t)$(rp(r)));

totalbioelectricity(r,t) ..                     EE(r,t)$(re(r)) =e= sum((c),E(r,c,t)$(re(r)));

totalcapadd(j,t) ..                             TCA(j,t) =e= sum((c),CA(j,c,t)) ;

biofuelswithccs(j,t)$(jc(j)) ..                 sum((r,c),CP(j,c,t)$(jc(j))*beta(r,j)$(rp(r))*uf) =e= mincp(j,t)$(jc(j)) ;
