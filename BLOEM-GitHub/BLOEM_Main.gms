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
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

$offtext

$eolcom #

* ---------------------------------------------------------------------------------------------------------
* Set Indexes
* ---------------------------------------------------------------------------------------------------------

Sets

    r 'resources'     / agrires, foresres, grass, wood, bioelectricity, biojet, biomethanol, biochar, bioheat, biogasoline, biosyngas /
    c 'gridcell'      / 1*3669 /
    t 'decade'        / 2020 / # 2030, 2040, 2050, 2060 /
    j 'technology'    / ACG, GCG, FCG, WCG, AFT, GFT, FFT, WFT, AME, GME, FME, WME, APY, GPY, FPY, WPY, ACG+, GCG+, FCG+, WCG+, AFT+, GFT+, FFT+, WFT+, AME+, GME+, FME+, WME+ /
    l 'landcover'     / forest, cropland, pasture, other /

    rcrp(r) 'energy crops'         / grass, wood /
    rres(r) 'residues'             / agrires, foresres/
    rsou(r) 'biomass resource'     / agrires, foresres, grass, wood /

    rliq(r) 'liquid biofuels'      / biojet, biomethanol /
    rele(r) 'bioelectricity'       / bioelectricity /
    rchr(r) 'biochar'              / biochar /
    rmap(r) 'main products'        / biojet, biomethanol, bioelectricity, biochar /
    rpro(r) 'all products'         / biojet, biomethanol, biochar, bioheat, biogasoline, biosyngas /
    rcop(r) 'co-products'          / bioheat, biogasoline, biosyngas /

    lp(l) 'protected areas'        / forest, other / # other = other land, including savannahs, scrubblands, etc.

    jccs(j) 'ccs technologies'              / ACG+, GCG+, FCG+, WCG+, AFT+, GFT+, FFT+, WFT+, AME+, GME+, FME+, WME+ /
    jliq(j) 'bioliquid technologies'        / AFT, GFT, FFT, WFT, AME, GME, FME, WME, AFT+, GFT+, FFT+, WFT+, AME+, GME+, FME+, WME+ /
    jele(j) 'bioelectricity technolgies'    / ACG, GCG, FCG, WCG, ACG+, GCG+, FCG+, WCG+ /
    jchr(j) 'biochar technologies'          / APY, GPY, FPY, WPY /
;

* Sets subsets (gdx-based)

$setglobal gdxinfilepath 'C:\Users\vicke\Desktop\BLOEM\BLOEM-GitHub\input\gdx\'

Sets
cccs(c) 'ccs site'
$gdxIn '%gdxinfilepath%ccscap.gdx'
$load cccs = c

carp(c) 'airport sites'
$gdxIn '%gdxinfilepath%airport_proxy.gdx'
$load carp = c

chbr(c) 'harbor sites'
$gdxIn '%gdxinfilepath%harbor_proxy.gdx'
$load chbr = c
;

Alias(r,crop,resources);
Alias(c,cn,gridcell);
Alias(t,tn,decade);
Alias(j,technology);
Alias(l,landuse,landcover);

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

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
                    #2050   0.387350
                    #2060    /;
;

* Set dfb(t)

Parameter dfb(t)  / 2020   1.0000000000 /;
                    #2030   0.3855432894,
                    #2040   0.1486436280,
                    #2050   0.0573085533
                    #2060   0.0220949282/;
;

$offlisting

* ----------------------------------------------------------------------------------------------------------
* Set carbon tax scenario
* ----------------------------------------------------------------------------------------------------------

Parameter k(t)   / 2020   0 /;
                   #2030   0,
                   #2040   0,
                   #2050   0,
                   #2060   0 /;
;

* ---------------------------------------------------------------------------------------------------------
* Declare variables
* ---------------------------------------------------------------------------------------------------------

Variables

    Z               'total system cost'  # [US$]

    IBP(t)          'impact of biomass production in time t' # [US$]
    IBT(t)          'impact of biomass transportation in time t' # [US$]
    IBC(t)          'impact of biomass conversion in time t' # [US$]
    IET(t)          'impact of bioenergy transportation in time t' # [US$]
    ICC(t)          'impact of carbon transportation and storage in time' # [US$]
    ITG(t)          'impact of carbon emissions in time t' # [US#]

;

Positive variables IBP, IBT, IBC, IET, ICC ;

Free variables Z ;

* ---------------------------------------------------------------------------------------------------------
* Modules
* ---------------------------------------------------------------------------------------------------------

$setglobal modulespath 'C:\Users\vicke\Desktop\BLOEM\BLOEM-GitHub\'

$include %modulespath%biomassproduction.gms
$include %modulespath%logistics.gms
$include %modulespath%technologiesportfolio.gms
$include %modulespath%carboncaptureandstorage.gms
$include %modulespath%emissions.gms
$include %modulespath%targets.gms

* ---------------------------------------------------------------------------------------------------------
* Equations
* ---------------------------------------------------------------------------------------------------------

Equations

    cost         'objective function'

;

cost ..         Z =e= sum((t),IBP(t)+IBT(t)+IBC(t)+IET(t)+ICC(t)+ITG(t));


Model BLOEM_China /all/;

option reslim = 1000000;
option lp = cplex;
option sysout = on;
option solprint = on;
option profile = 3;
option solvelink = 0;

$onecho > cplex.opt
names no
memoryemphasis 1
threads 1
$offecho
BLOEM_China.OptFile = 1;


Solve BLOEM_China using lp minimizing Z ;

Display Z.l ;

Display EE.l ;

Display LdAlc.l ;

Display GG.l, Gbp.l, Gfr.l, Gbt.l, Gbc.l, Get.l ;

Display IBP.l, IBT.l, IBC.l, IET.l, ICC.l, ITG.l ;

Display TCA.l ;

Display Vseq.l ;

* ---------------------------------------------------------------------------------------------------------
* Export results
* ---------------------------------------------------------------------------------------------------------

* Set gdx output filepath;

$setglobal gdxoutfilepath 'C:\Users\vicke\Desktop\BLOEM\BLOEM-GitHub\output\gdx\'

# Unload:

execute_unload '%gdxoutfilepath%scen_a.gdx'

#B     # biomass production

A     # land allocation

#Bn    # crop trade matrix

;

execute_unload '%gdxoutfilepath%scen_b.gdx'

CA    # added capacity

TCA   # total capacity added

CJ    # installed capacity

CR    # retired capacity

CP    # rate of operation

;

execute_unload '%gdxoutfilepath%scen_c.gdx'

E     # bioenergy production

EE    # total bioenergy production

*S     # co-products production
HE    # local bioenergy consumption for product r in grid cell c in time t

Ein   # bioenergy into grid cell

Eout  # bioenergy out of grid cell

EE    # total bioenergy production per product per decade

En    # bioenergy flow for product r between grid cells c and cn in time t

Bin   # biomass resource into grid cell

Bout  # biomass resource out of grid cell

Bn    # biomass flow for crop r between grid cells c and cn in time t

Vcap  # carbon captured

Vseq  # carbon stored

;

execute_unload '%gdxoutfilepath%scen_d.gdx'

GG    # emissions without emissions from land use change

Gbp   # emissions from biomass production

Gfr   # emissions from fertilizers

Gbt   # emissions from biomass transport

Gbc   # emissions from biomass conversion

Get   # emissions from biofuel transportation

;

execute_unload '%gdxoutfilepath%scen_e.gdx'

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
