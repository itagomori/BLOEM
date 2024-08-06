$ontext
* BLOEM_China
$offtext

* -----------------------------------
* Define parameters
* -----------------------------------

Parameters

    tci(j,t)            'total capital investments' # [US$/kW]
    fom(j,t)            'fixed o&m costs' # [US$/kw]
    vom(j,t)            'variable o&m costs' # [US$/kw]
    w(j)                'technology discount factor'
    cjo(j,c,t)          'existing capacities in time t' # [GJ/y] [kw/y]
    rf(j, tn, t)        'retire factor' # [factor, 0-1]
    cf(j,t)             'capacity factor' # [factor, 0-1]
    beta(r,j)           'ratio of consumption (inputs) or production (outputs)'
    #avj(r,j,t)          'operation mode for technologies with intermediates' # [binary, 0/1]
    mincp(j,t)          'biofuel production with CCS' # [GJ/yr]
;

* Set technologies total capital investment

Table tci(j,t) 'total capital investment for technology j in grid cell c in decade d' # [US$/kw]
                2020
    ACG         2058
    GCG         2058
    WCG         2058
    AFT         3026
    GFT         3036
    WFT         3026
    AGA         3490.8
    GGA         3490.8
    WGA         3490.8
    APY         5.78
    GPY         5.78
    WPY         5.78
    ACG+        3617.75
    GCG+        3617.75
    WCG+        3617.75
    AFT+        4585.5
    GFT+        4585.5
    WFT+        4585.5
    AGA+        5050.55
    GGA+        5050.55
    WGA+        5050.55
;

* Set technologies fix om costs
Table fom(j, t) 'fixed om costs for technology j in grid cell c in decade d' # [US$/y]

                2020
    ACG         205.8
    GCG         205.8
    WCG         205.8
    AFT         298.9
    GFT         298.9
    WFT         298.9
    AGA         57.8
    GGA         57.8
    WGA         57.8
    APY         27.1
    GPY         27.1
    WPY         27.1
    ACG+        361.7
    GCG+        361.7
    WCG+        361.7
    AFT+        298.9
    GFT+        298.9
    WFT+        298.9
    AGA+        57.8
    GGA+        57.8
    WGA+        57.8
;

* Set technologies variable o&m costs

Table vom(j, t) 'variable om costs for technology j in grid cell c in decade d' # [US$/y]

                2020
    ACG         367
    GCG         367
    WCG         367
    AFT         64
    GFT         64
    WFT         64
    AGA         195.87
    GGA         195.87
    WGA         195.87
    APY         0
    GPY         0
    WPY         0
    ACG+        367.8
    GCG+        367.8
    WCG+        367.8
    AFT+        64.12
    GFT+        64.12
    WFT+        64.12
    AGA+        196.43
    GGA+        196.43
    WGA+        196.43
;

* Set technology discount factor w(j)

Parameter w(j)  / 
    ACG         0.9807549,
    GCG         0.9807549,
    WCG         0.9807549,
    AFT         0.9141061,
    GFT         0.9141061,
    WFT         0.9141061,
    AGA         0.8153025,
    GGA         0.8153025,
    WGA         0.8153025,
    APY         0.9807549,
    GPY         0.9807549,
    WPY         0.9807549,
    ACG+        0.9807549,
    GCG+        0.9807549,
    WCG+        0.9807549,
    AFT+        0.9141061,
    GFT+        0.9141061,
    WFT+        0.9141061,
    AGA+        0.8153025,
    GGA+        0.8153025,
    WGA+        0.8153025
                                /;
;

* Set technologies retirement factors for added capacities
Table rf(j,tn, t) 'retirement factor of capacity added in time tn'
                
                2020
    ACG         0
    GCG         0
    WCG         0
    AFT         0
    GFT         0
    WFT         0
    AGA         0
    GGA         0
    WGA         0
    APY         0
    GPY         0
    WPY         0
    ACG+        0
    GCG+        0
    WCG+        0
    AFT+        0
    GFT+        0
    WFT+        0
    AGA+        0
    GGA+        0
    WGA+        0
;

* Set technologies capacity factors
Table cf(j,t) 'capacity factor' # [factor 0-1]
                2020
    ACG         1
    GCG         1
    WCG         1
    AFT         1
    GFT         1
    WFT         1
    AGA         1
    GGA         1
    WGA         1
    APY         1
    GPY         1
    WPY         1
    ACG+        1
    GCG+        1
    WCG+        1
    AFT+        1
    GFT+        1
    WFT+        1
    AGA+        1
    GGA+        1
    WGA+        1
;

* Set technologies rate of consumption or production of resrouce 'r'

Table beta(r, j) 'ratio of consumption or production of resource r by technology j' #[GJ/GJ]
                ACG	    GCG	    WCG	    AFT	    GFT	    WFT	    AGA	    GGA	    WGA	    APY	    GPY	    WPY	    ACG+	GCG+	WCG+	AFT+	GFT+	WFT+	AGA+	GGA+	WGA+
    agriRes	    -5.02	0	    0	    -2	    0	    0	    -3.62	0	    0	    -2.23	0	    0	    -5.02	0	    0	    -2	    0	    0	    -3.62	0	    0
    foresRes    0	    0	    -4.518	0	    0	    -1.8	0	    0	    -3.258	0	    0	    -2.007	0	    0	    -4.518	0	    0	    -1.8	0	    0	    -3.258
    egrass	    0	    -4.769	0	    0	    -1.9	0	    0	    -3.439	0	    0	    -2.1185	0	    0	    -4.769	0	    0	    -1.9	0	    0	    -3.439	0
    ewood	    0	    0	    -4.518	0	    0	    -1.8	0	    0	    -3.258	0	    0	    -2.007	0	    0	    -4.518	0	    0	    -1.8	0	    0	    -3.258
    bioelec	    1	    1	    1	    0	    0	    0	    0	    0	    0	    0	    0	    0	    1	    1	    1	    0	    0	    0	    0	    0	    0
    biojet	    0	    0	    0	    1	    1	    1	    0	    0	    0	    0	    0	    0	    0	    0	    0	    1	    1	    1	    0	    0	    0
    biomethanol	0	    0	    0	    0	    0	    0	    1	    1	    1	    0	    0	    0	    0	    0	    0	    0	    0	    0	    1	    1	    1
    biochar	    0	    0	    0	    0	    0	    0	    0	    0	    0	    1	    1	    1	    0	    0	    0	    0	    0	    0	    0	    0	    0
    heat	    0.63	0.63	0.63	0	    0	    0	    0	    0	    0	    0	    0	    0	    0.63	0.63	0.63	0	    0	    0	    0	    0	    0
    gasoline	0	    0	    0	    0.32	0.32	0.32	0	    0	    0	    0	    0	    0	    0	    0	    0	    0.32	0.32	0.32	0	    0	    0
    syngas	    0	    0	    0	    0  	    0	    0	    0	    0	    0	    0.64	0.64	0.64	0	    0	    0	    0	    0	    0	    0	    0	    0
;

* Set production of biofuels with CCS
Table mincp(j,t) 'biofuel production with ccs'

                2020
    ACG+        1e4
    GCG+        1e4
    WCG+        1e4
    AFT+        1e4
    GFT+        1e4
    WFT+        1e4
    AGA+        1e4
    GGA+        1e4
    WGA+        1e4

* ---------------------------------------
* Import data
* ---------------------------------------
* Setting gdx input filepath
$setglobal gdxinfilepath 'C:\Users\vicke\Desktop\model\BLOEM\BLOEM-GitHub\input\gdx\'

* Import existing capacity (cjo):
$gdxin '%gdxinfilepath%cjoexist.gdx'

$load cjo = cjoexist

$gdxin


* --------------------------------------
* Declare variables
* -------------------------------------
Variables

    IBT(t)          'impact of biomass conversion in time t' #[US$]
    ITCI(t)         'impact of capital investment in technologies in time t' #[US$]
    ITOM(t)         'impact of OM of technologies in time t' #[US$]

    CJ(j,c,t)       'installed capacity of technology j in grid cell c in time t' # [kw]
    CA(j,c,t)       'added capacity of technolog j in grid cell c in time t' # [kw]
    CR(j,c,t)       'retired capacity of technology j in grid cell c in time t' # [kw]

    CP(j,c,t)       'rate of operation of technology j in grid cell c in time t'

    E(r,c,t)        'bioenergy production for product r in grid cell c in time t' # [kw]
    S(r,c,t)        'co-products production for co-product r in grid cell c in time t' #[kw]

    EE(r,t)         'total bioenergy production per product per decade' # [GJ]

    TCA(j,t)        'total capacity added per decade' # [kw]
;

Positive variables IBC, ITCI, ITOM, CJ, CA, CR, CP, E, S, TCA;

* Variable bounds
CJ.up('ACG', c, t) = 10e6;
CJ.up('GCG', c, t) = 10e6;
CJ.up('WCG', c, t) = 10e6;
CJ.up('AFT', c, t) = 100e6;
CJ.up('GFT', c, t) = 100e6;
CJ.up('WFT', c, t) = 100e6;
CJ.up('AFA', c, t) = 100e6;
CJ.up('GCA', c, t) = 100e6;
CJ.up('WGA', c, t) = 100e6;
CJ.up('APY', c, t) = 100e6;
CJ.up('GPY', c, t) = 100e6;
CJ.up('WPY', c, t) = 100e6;
CJ.up('ACG+', c, t) = 100e6;
CJ.up('GCG+', c, t) = 100e6;
CJ.up('WCG+', c, t) = 100e6;
CJ.up('AFT+', c, t) = 100e6;
CJ.up('CFT+', c, t) = 100e6;
CJ.up('WGT+', c, t) = 100e6;
CJ.up('AGA+', c, t) = 100e6;
CJ.up('CGA+', c, t) = 100e6;
CJ.up('WGA+', c, t) = 100e6;

* ----------------------------------
* Equations
* ----------------------------------
Equations

    impactbioconversion(t)          'impact of converting biomass into bioenergy'
    impactcapitalinvest(t)          'impact of total capital investment'
    impactoem(t)                    'impact of o&m costs'

    rateofoperation(j,c,t)          'rate of operation of technology j'

    capacitybalance(j,c,t)          'capacity balance of technology j'
    retiredcapacity(j,c,t)          'retired capacity of technology j'

    bioenergyconversion(r,c,t)      'production of bioenergy products'
    bioelectricityconversion(r,c,t) 'production of bioelectricity'
    biocharconversion(r,c,t)        'production of biochar'   # added
    coproductconversion(r,c,t)      'production of co-products'

    totalbioenergy(r,t)             'total production per product per decade'
    totalbioelectricity(r,t)        'total production of bioelectricity per decade'
    totalbiochar(r,t)               'total production of biochar per decade' # added
    totalcapadd(j,t)                'total capacity added per decade'
    biofuelswithccs(j,t)            'biofuels production with ccs per decade'
;

impactbioconversion(t) ..                   IBC(t) =e= ITCI(t) + ITOM(t)
impactcapitalinvest(t) ..                   ITCI(t) =e= dfb(t)*sum((j,c), w(j)*tci(j,t)*CA(j,c,t));
impactoem(t) ..                             ITOM(t) =e= dfa(t)*sum((j,c), (fom(j,t)*CJ(j,c,t)+vom(j,t)*CP(j,c,t)));
rateofoperation(j,c,t) ..                   CP(j,c,t) =l= CJ(j,c,t)*cf(j,t); # rate of operation = installed capacity * capacity factor
capacitybalance(j,c,t) ..                   CJ(j,c,t) =e= cjo(j,c,t) + CJ(j,c,t-1) + CA(j,c,t) - CR(j,c,t); # cjo=existing capacity in time t;
bioenergyconversion(r,c,t)$(rpli(r)) ..       E(r,c,t)$(rpli(r)) =e= sum((j), CP(j,c,t)$(rpli(r))*beta(r,j)*uf); 
bioelectricityconverion(r,c,t)$(rpel(r)) ..   E(r,c,t)$(rpel(r)) =e= sum((j), CP(j,c,t)$(rpel(r))*beta(r,j));
biocharconversion(r,c,t)$(rpch(r)) ..       E(r,c,t)$(rpch(r)) =e= sum((j), CP(j,c,t)$(rpch(r))*beta(r,j)) 
coproductsconversion(r,c,t)$(rcop(r)) ..    S(r,c,t)$(rcop(r)) =e= sum((j), CP(j,c,t)$(rcop(r))*beta(r,j)*uf);
totalbioenergy(r,t) ..                      EE(r,t)$(rpli(r))  =e= sum((c), E(r,c,t)$(rpli(r)));
totalbioelectricity(r,t) ..                 EE(r,t)$(rpel(r))  =e= sum((c), E(r,c,t)$(rpel(r)));
totalbiochar(r,t) ..                        EE(r,t)$(rpch(r))  =e= sum((c), E(r,c,t)$(rpch(r)));
totalcapadd(j,t) ..                         TCA(j,t) =e= sum((c), CA(j,c,t));
biofuelswithccs(j,t)$(jc(j)) ..             sum((r,c), CP(j,c,t)$(jc(j))*beta(r,j)$(rpli(r))*uf) =e= mincp(j,t)$(jc(j));



