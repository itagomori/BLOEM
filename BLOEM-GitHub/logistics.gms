$ontext
* BLOEM_China
$offtext

* -----------------------------------------------
* Define parameters
* -----------------------------------------------

Parameters

    trco(r)         'biomass transportation costs' # [US$/GJ/km]
    mx(c,cn)        'distance between grid cells' # [km]
    #mxair(c,cn)     'distance between grid cells to airport' # [km]
    #mxharbor(c,cn)     'distance between grid cells to harbor' # [km]
    #maxx            'maximum distance between grid cells for biomass logistics' # [km]
    tal(c)          'tortuosity factor' # [factor]
    beta(r,j)       'ratio of consumption (inputs) or production (outputs)'
;

* Set biomass and biofuels transportation costs trco(r)
Parameter trco(r) / agriRes         0.0020,
                    foresRes        0.0020,
                    egrass          0.0011,
                    ewood           0.0032,
                    biojet          0.0040,
                    biomethanol     0.0050/;
;

* --------------------------------
* Import data
* --------------------------------

* Setting gdx input filepath
$setglobal gdxinfilepaht 'C:\Users\vicke\Desktop\model\BLOEM\BLOEM-GitHub\input\gdx\'

* Import distance between grid cells mx(c, cn)
# columns: c, cn, value
$gdxin '%gdxinfilepath%mxdistmax.gdx'

$load mx=mxdistmax

$gdxin
;

* -------------------------------------------------
* Declare variables
* -------------------------------------------------
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

    B(r,l,c,t)      'biomass production for crop r in land type l in grid cell c in time t' # [GJ]
    E(r,c,t)        'bioenergy production for product r in grid cell c in time t' # [GJ] [kw]

    CP(j,c,t)       'rate of operation of technology j in grid cell c in time t'
;

Positive variables IBT, IET, HE, Bn, En, Bin, Bout, Ein, Eout, B, E, CP;

* Variable bounds:
HB.up(r,c,t)=0;

* ----------------------------------
* Equations
* ----------------------------------
Equations

    impactbiotransport(t)           'impact of transporting biomass among grid cells'

    resourcebalance(r,c,t)          'resource balance in each grid cell'
    biomassintocell(r,c,t)          'biomass into grid cell'
    biomassoutocell(r,c,t)          'biomass out of grid cell'
    maxbiomassoutocell(r,c,t)       'max biomassout of grid cell'

    localdemandforcrops(r,c,t)      'local demand for crops due to technology operation' # is this based on biojet and biomethanol?

    impactbioendtransport(t)        'impact of transporting bioenergy from production to demand grid cells'

    bioenergybalance(r,c,t)         'bioenergy balance in grid cell cin decade d'
    bioenergyintogridcell(r,c,t)    'bioenergy into grid cell'
    bioenergyoutogridcell(r,c,t)    'bioenergy out of grid cell'
    maxbioenergytransp(r,c,t)       'max bioenergy out of grid cell'
;

impactbiotransport(t) ..                            IBT(t) =e=  dfa(t)*sum((r,c,cn), trco(r)$(rres(c))*Bn(r,c,cn,t)$(rres(r))*mx(c,cn)*tal(c)) + dfa(t)*sum((r,c,cn), trco(r)$(rren(c))*Bn(r,c,cn,t)$(rren(r))*mx(c,cn)*tal(c));

resourcebalance(r,c,t)$(rres(r) or rren(r)) ..      sum((l), B(r,l,c,t)$(rres(r) or rren(r))) + Bin(r,c,t)$(rres(r) or rren(r)) - Bout(r,c,t)$(rres(r) or rren(r)) + HB(r,c,t)$(rres(r) or rren(r)) =e= 0

# currently, 300km range distance matrix is applied
biomassintocell(r,c,t)$(rres(r) or rren(r)) ..      Bin(r,c,t)$(rres(r) or rren(r)) =e= sum((cn), Bn(r,cn,c,t)$(rres(r) or rren(r))*mx(cn,c)); 

biomassoutocell(r,c,t)$(rres(r) or rren(r)) ..      Bout(r,c,t)$(rres(r) or rren(r)) =e= sum((cn), Bn(r,c,cn,t)$(rres(r)*mx(c,cn) or rren(r)*mx(c,cn)));

maxbiomassoutocell(r,c,t)$(rres(r) or rren(r)) ..   Bout(r,c,t)$(rres(r) or rren(r)) =l= sum((l), B(r,l,c,t)$(rres(r) or rren(r)));

# HB means local biomass consumption of crop c in grid cell c
localdemandforcrops(r,c,t)$(rres(r) or rren(r)) ..  HB(r,c,t)$(rres(r) or rren(r)) =e= sum((j), CP(j,c,t)*beta(r,j)$(rres(r) or rren(r))*uf);

impactbioendtransport(t) ..                         IET(t) =e= dfa(t) * sum((r,c,cn), trco(r)$(rpli(r))*En(r,c,cn,t)$(rpli(r))*mx(c,cn)*tal(c));

# Q: What about other rproduct? they don't have constraints or equations?
# HE means local bioenergy consumption in grid cell c;
bioenergybalance(r,c,t)$(rpli(r)) ..                E(r,c,t)$(rpli(r)) + Ein(r,c,t)$(rpli(r)) - Eout(r,c,t)$(rpli(r)) =e= HE(r,c,t)$(rpli(r));

bioenergyintogridcell(r,c,t)$(rpli(r)) ..           Ein(r,c,t)$(rpli(r)) =e= sum((cn), En(r,cn,c,t)$(rpli(r)));

bioenergyoutogridcell(r,c,t)$(rpli(r)) ..           Eout(r,c,t)$(rpli(r)) =e= sum((cn), En(r,c,cn,t)$(rpli(r)));

maxbioenergytransp(r,c,t)$(rpli(r)) ..              Eout(r,c,t)$(rpli(r)) =l= E(r,c,t)$(rpli(r));


