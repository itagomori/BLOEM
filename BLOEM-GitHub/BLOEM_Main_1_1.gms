$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Author: Isabela Schmidt Tagomori
* Last update: 19.05.2022
* Version: 1.1
* Coupled IAM: BLUES
* Region: Brazil 
* Time frame: 2020-2050
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

$eolcom #

* ---------------------------------------------------------------------------------------------------------
* Set Indexes
* ---------------------------------------------------------------------------------------------------------

Sets
    r 'resources'     / sugarcane, oilcrops, wood, bagasse, sgcnjuice, ethanol1g, ethanol2g, biojet, dieselbiofuel, biodiesel, bioelectricity, bionaphta, biolpg, sugarjuice /
    c 'grid cell'     / 1*2912 /  # Brazilian grid cells
    t 'decade'        / 2020, 2030, 2040, 2050 /
    j 'technology'    / SGC, E1G, E2G, BJT, DFT, BDS, COG, E1GC, BJTC, DFTC, SUG /
    l 'landcover'     / forest, agriculture, pasture, other, bioland /
    q 'period g-luc'  / 1*3 / 

    rc(r) 'crops'               / sugarcane, oilcrops, wood /
    ri(r) 'intermediates'       / bagasse, sgcnjuice /
    rp(r) 'liquid biofuels'     / ethanol1g, ethanol2g, biojet, dieselbiofuel, biodiesel / # ethanol1gccs, biojetccs, dieselbiofuelccs moved towards techs
    re(r) 'bioelectricity'      / bioelectricity /
    rs(r) 'co-products'         / bionaphta, biolpg, sugarjuice /

    jc(j) 'ccs technologies'    / E1GC, BJTC, DFTC /

    cs(c) 'storage sites'       / 1835, 2597, 2650, 2652, 2698, 2716, 2744 /

    lp(l) 'protected areas'     / forest, other / # other = other land, including savannahs, scrubblands, etc.
    lb(l) 'bioland base'        / bioland /

    lr(l,r)  'land vs crops'    / forest  .sugarcane
                                  forest  .oilcrops
                                  forest  .wood      
                                  other   .sugarcane
                                  other   .oilcrops
                                  other   .wood       /;
;


Alias(r,crop,resource);
Alias(c,cn,gridcell);
Alias(t,tn,decade);
Alias(j,technology);
Alias(l,landuse,landcover);


* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Scalar
    
    uf       'unit coversion factor kW to GJ'           /31.536/  # [factor]

;

Parameters
    
    dfa(t)              'discount factor back to base year, including annual discounting'

    dfb(t)              'discount factor back to base year'

    k(t)                'carbon price profile' # [US$/tCO2]

;

* Set discount factors

* Set dfa(t)

Parameter dfa(t)  / 2020   6.759024,
                    2030   2.605896,
                    2040   1.004686,
                    2050   0.387350 /;
;

* Set dfb(t)

Parameter dfb(t)  / 2020   1.0000000000,
                    2030   0.3855432894,
                    2040   0.1486436280,
                    2050   0.0573085533 /;
;

$offlisting


* ----------------------------------------------------------------------------------------------------------
* Set carbon tax scenario
* ----------------------------------------------------------------------------------------------------------

Parameter k(t)   / 2020   0,
                   2030   0,
                   2040   0,
                   2050   0 /;
;


* ---------------------------------------------------------------------------------------------------------
* Declare variables
* ---------------------------------------------------------------------------------------------------------

Variables
    
    Z               'total system cost'  # [US$]

    IBP(t)          'impact of biomass production in time t'  # [US$]
    IBT(t)          'impact of biomass transportation in time t'  # [US$]
    IBC(t)          'impact of biomass conversion in time t'  # [US$]
    IET(t)          'impact of bioenergy transportation in time t'  # [US$]
    ICC(t)          'impact of carbon transportation and storage in time t'  # [US$]
    ITG(t)          'impact of carbon emissions in time t'  # [US$]
          
;

Positive variables  IBP, IBT, IBC, IET, ICC;

Free variables  Z ;


* ---------------------------------------------------------------------------------------------------------
* Modules
* ---------------------------------------------------------------------------------------------------------

$setglobal modulespath 'X:\user\tagomorii\BLOEM\ModelVersions\Modules\Main_11\'

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

cost ..                                         Z =e= sum((t),IBP(t)+IBT(t)+IBC(t)+IET(t)+ICC(t)+ITG(t));


Model BLOEM_BLUES_1_1 /all/ ;

option reslim = 1000000 ;
option lp = cplex ;
option sysout = on ;
option solprint = on ;
option profile = 3 ;
option solvelink = 0;

$onecho > cplex.opt
names no
memoryemphasis 1
threads 1
$offecho
BLOEM_BLUES_1_1.OptFile = 1;


Solve BLOEM_BLUES_1_1 using lp minimizing Z ;

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

* Set gdx output filepath

$setglobal gdxoutfilepath 'X:\user\tagomorii\BLOEM\GDXoutput\B-NDC\'

# Unload:

execute_unload '%gdxoutfilepath%wgv_a.gdx'

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

S     # co-products production

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
