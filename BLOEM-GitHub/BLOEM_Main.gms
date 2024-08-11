$ontext
* ------------------
BLOEM-China
* ------------------

$offtext

$eolcom #

* --------------------
* Set Indexes
* --------------------
$setglobal gdxinfilepath 'C:\Users\vicke\Desktop\BLOEM-China\input\gdx\'

Sets

    r 'resources' /agriRes, foresRes, egrass, ewood, bioelectricity, biojet, biomethanol, biochar, heat, gasoline, syngas/
    c 'gridcell' / 1*3669 /
    t 'decade'    / 2020 /
    j 'technology' / ACG, GCG, WCG, AFT, GFT, WFT, AME, GME, WME, APY, GPY, WPY, ACG+, GCG+, WCG+, AFT+, GFT+, WFT+, AME+, GME+, WME+ /
    l 'landcover' / cropland, pasture, forest, othernatualland /

    rsou(r) 'biomass resource' / agriRes, foresRes, egrass, ewood /
    rres(r) 'agricultural and forestry residues' /agriRes, foresRes/
    recr(r) 'ecrops' / egrass, ewood /

    rliq(r) 'liquid biofuel' / biojet, biomethanol /
    rele(r) 'bioelectricity' / bioelectricity /
    rchar(r) 'biochar' / biochar /
    rcoprod(r) 'co-products' / heat, gasoline, syngas /

    lcrop(l) 'cropland' /cropland/
    lfores(l) 'forest land' /forest/
    lother(l) 'pasture and other natural land' /pasture, othernatualland/

    jccs(j) 'ccs technologies' / ACG+, GCG+, WCG+, AFT+, GFT+, WFT+, AME+, GME+, WME+ / 
    jliq(j) 'bioliquid technologies' / AFT, GFT, WFT, AME, GME, WME, AFT+, GFT+, WFT+, AME+, GME+, WME+ /
    jele(j) 'bioelectricity technolgies' / ACG, GCG, WCG, ACG+, GCG+, WCG+ /
    jchar(j) 'biochar technologies' / APY, GPY, WPY /
;

Sets
cccs(c) 'ccs site'
$gdxIn '%gdxinfilepath%ccscap.gdx'
$load cccs=c

cair(c) 'airport sites'
$gdxIn '%gdxinfilepath%airport_proxy.gdx'
$load cair=c

char(c) 'harbor sites'
$gdxIn '%gdxinfilepath%harbor_proxy.gdx'
$load char=c

*display char, cair, cccs

    # one to many mapping
    #rj(r,j) /
    #        agriRes.ACG,
    #        agriRes.ACG+,
    #        agriRes.AFT,
    #        agriRes.AFT+,
    #        agriRes.AME,
    #        agriRes.AME+,
    #        agriRes.APY,
    #        (foresRes, ewood).WCG,
    #        (foresRes, ewood).WCG+,
    #        (foresRes, ewood).WFT,
    #        (foresRes, ewood).WFT+,
    #        (foresRes, ewood).FME,
    #        (foresRes, ewood).FME+,
    #        (foresRes, ewood).FPY,
    #        egrass.GCG,
    #        egrass.GCG+,
    #        egrass.GFT,
    #        egrass.GFT+,
    #        egrass.GME,
    #        egrass.GME+,
    #        egrass.GPY  /
;

Alias(r, crop, resources);

Alias(c, cn, gridcell);
Alias(t, tn, decade);
Alias(j, technology);
Alias(l, landuse, landcover);

* ------------------------------------
* Define parameters
* -------------------------------------

Scalar

    uf          'unit conversion factor kW to GJ'    /31.536/ # [factor]
;

Parameters
    dfa(t)      'discount factor back to base year, including annual discounting'

    dfb(t)      'discount factor back to base year'

    k(t)        'carbon price profile' # [US$/tCO2]
;

* Set discount factors

* Set dfa(t)

Parameter dfa(t)  / 2020   6.759024 /;
                    #2030   2.605896,
                    #2040   1.004686,
                    #2050   0.387350 /;
;

* Set dfb(t)

Parameter dfb(t)  / 2020   1.0000000000 /;
                    #2030   0.3855432894,
                    #2040   0.1486436280,
                    #2050   0.0573085533 /;
;

$offlisting

* -----------------------------------
* Set carbon tax scenario
* -----------------------------------
Parameter k(t)   / 2020   0 /;
                   #2030   0,
                   #2040   0,
                   #2050   0 /;
;

* -----------------------------------
* Declare variables
* -----------------------------------

Variables

    Z               'total system cost'  # [US$]

    IBP(t)          'impact of biomass production in time t' # [US$]
    IBT(t)          'impact of biomass transportation in time t' # [US$]
    IBC(t)          'impact of biomass conversion in time t' # [US$]
    IET(t)          'impact of bioenergy transportation in time t' # [US$]
    ICC(t)          'impact of carbon transportation and storage in time' # [US$]
    ITG(t)          'impact of carbon emissions in time t' # [US#]
;

Positive variables IBP, IBT, IBC, IET, ICC;

Free variables Z;

* -----------------------------------
* Modules
* -----------------------------------

$setglobal modulespath 'C:\Users\vicke\Desktop\BLOEM-China\'

$include %modulespath%biomassproduction.gms
$include %modulespath%logistics.gms
$include %modulespath%technologiesportfolio.gms
$include %modulespath%carboncaptureandstorage.gms
$include %modulespath%emissions.gms
$include %modulespath%targets.gms

* -----------------------------------
* Equations
* -----------------------------------

Equations

    cost         'objective function'

;

cost ..     Z =e= sum((t),IBP(t)+IBT(t)+IBC(t)+IET(t)+ICC(t)+ITG(t));

Model BLOEM_China /all/;

option reslim = 1000000;
option lp = cplex;
option sysout = on;
option solprint = on;
option profile = 3;
option solvelink = 0;

$onecho > cplex.opt
name no
memoryemphasis 1
threads 1
$offecho
BLOEM_China.OptFile = 1;

Solve BLOEM_China using lp minimizing Z;

Display Z.l;

Display EE.l;

Display LdAlc.l;

Display GG.l, Gbp.l, Gfr.l, Gbt.l, Gbc.l, Get.l ;

Display IBP.l, IBT.l, IBC.l, IET.l, ICC.l, ITG.l ;

Display TCA.l ;

Display Vseq.l ;

* -------------------------------
* Export results
* -------------------------------

* Set gdx output filepath;

$setglobal gdxoutfilepath 'C:\Users\vicke\Desktop\BLOEM-China\output\gdx\'

# Unload:

execute_unload '%gdxoutfilepath%wdgv_a.gdx'

#B     # biomass production

A     # land allocation

#Bn    # crop trade matrix

;

execute_unload '%gdxoutfilepath%wgv_b.gdx'

CA    # added capacity

TCA   # total capacity added

CJ    # installed capacity

CR    # retired capacity

CP    # rate of operation

;

execute_unload '%gdxoutfilepath%wgv_c.gdx'

E     # bioenergy production

EE    # total bioenergy production

*S     # co-products production

Vcap  # carbon captured

Vseq  # carbon stored

;

execute_unload '%gdxoutfilepath%wgv_d.gdx'

GG    # emissions without emissions from land use change

Gbp   # emissions from biomass production

Gfr   # emissions from fertilizers

Gbt   # emissions from biomass transport

Gbc   # emissions from biomass conversion

Get   # emissions from biofuel transportation

;

execute_unload '%gdxoutfilepath%wgv_e.gdx'

Z     # total system cost

IBP   # impact of biomass production

IBT   # impact of biomass transportation

IBC   # impact of biomass conversion

ITCI  # impact of capital investment

ITOM  # impact of o&m

IET   # impact of bioenergy transportation

ICC   # impact of carbon transportation and storage

ITG   # impact of emissions [carbon tax scenarios]

;



