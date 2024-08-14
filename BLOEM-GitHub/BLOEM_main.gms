$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Branch: BLOEM-Master
* Author: Isabela Schmidt Tagomori
* Last update: 14.08.2022
* Version: 2.0
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

$eolcom #

* ---------------------------------------------------------------------------------------------------------
* Set Indexes
* ---------------------------------------------------------------------------------------------------------

Sets
    r 'resources'     / biomass, residues, intermediate, product, bioelectricity, biochar, coproduct /  # substitute accordingly, for examples see regional branches
    c 'grid cell'     / 1*X /  # X = number of grid cells
    t 'time'          / t1, tX /  # X = year, decade, etc.
    j 'technology'    / TEC1, TECX /  # substitute accordingly, for examples see regional branches
    l 'landcover'     / landtype1, landtypeX /  # substitute accordingly, for examples see regional branches

    rcrp(r) 'energy crops'        / biomass /  # energy crops, substitute accordingly, for examples see regional branches
    rres(r) 'residues'            / residues /  # residues, substitute accordingly, for examples see regional branches
    rsou(r) 'biomass resources'   / biomass, residues /  # all biomass resources, including residues, substitute accordingly, for examples see regional branches

    rint(r) 'intermediates'       / intermediate /  # intermediates, substitute accordingly, for examples see regional branches

    rliq(r) 'liquid biofuels'     / product /  # liquid biofuels, substitute accordingly, for examples see regional branches
    rele(r) 'bioelectricity'      / bioelectricity /
    rchr(r) 'biochar'             / biochar / 
    rmap(r) 'main products'       / product, bioelectricity, biochar /  # main products, substitute accordingly, for examples see regional branches
    
    rcop(r) 'co-products'         / coproduct /  # co-products, substitute accordingly, for examples see regional branches
    rpro(r) 'all products'        / product, bioelectricity, biochar, coproduct /  # all products, substitute accordingly, for examples see regional branches

    jccs(j) 'ccs technologies'    / TEC1+, TECX+ /  # '+' indicates technology with carbon capture, substitute accordingly, for examples see regional branches

    lp(l) 'protected areas'       / lantypeX /  # protected areas per land type, substitute accordingly, for examples see regional branches
    lb(l) 'bioland base'          / bioland /   # in case of area already dedicated to bioenergy, for examples see regional branches

;

* Sets subsets (gdx-based)

$setglobal gdxinfilepath 'C:\Path\'  # set your path for inputs

Sets
cccs(c) 'ccs storage sites'  # grid cell numbers for ccs storage sites
$gdxIn '%gdxinfilepath%ccscap.gdx'
$load cccs = c
;

Alias(r,crop,resource);
Alias(c,cn,gridcell);
Alias(t,tn,time);
Alias(j,technology);
Alias(l,landuse,landcover);

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Scalar
    
    uf       'unit coversion factor kW to GJ'           /31.536/  # [factor]

    q        'years in time step'                      / X /  # for example, 10 if time steps are decades

;

Parameters
    
    dfa(t)              'discount factor back to base year, including annual discounting'

    dfb(t)              'discount factor back to base year'

    k(t)                'carbon price profile'  # [US$/tCO2]

;

* Set discount factors, see documentation for equations

* Set dfa(t)

Parameter dfa(t)  / t1     dfa(t1),  # substitute t and dfa, for examples see regional branches
                    tX     dfa(tX) /;
;

* Set dfb(t)

Parameter dfb(t)  / t1     dfb(t1),  # substitute t and dfb, for examples see regional branches
                    tX     dfb(tX) /;
;

$offlisting

* ----------------------------------------------------------------------------------------------------------
* Set carbon tax scenario
* ----------------------------------------------------------------------------------------------------------

Parameter k(t)   / t1     k(t1),  # substitute t and k, for examples see regional branches
                   tX     k(tX) /;
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

$setglobal modulespath 'C:\Path\'  # set your path for modules

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

cost ..        Z =e= sum((t),IBP(t)+IBT(t)+IBC(t)+IET(t)+ICC(t)+ITG(t));


Model BLOEM_Master /all/ ;  # name your model, BLOEM_Name (Name/Region, example: BLOEM_Brazil)

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
BLOEM_Master.OptFile = 1;


Solve BLOEM_Master using lp minimizing Z ;

Display Z.l ;  # choose variables to display

* ---------------------------------------------------------------------------------------------------------
* Export results
* ---------------------------------------------------------------------------------------------------------

* Set gdx output filepath

$setglobal gdxoutfilepath 'C:\Path\'  # set your path for outputs

# Unload:

execute_unload '%gdxoutfilepath%scenario_a.gdx'

A     # land allocation

B     # biomass production

;

execute_unload '%gdxoutfilepath%scenario_b.gdx'

CA    # added capacity

TCA   # total capacity added

CJ    # installed capacity

CR    # retired capacity

;

execute_unload '%gdxoutfilepath%scenario_c.gdx'

E     # bioenergy production per grid cell

EE    # total bioenergy production

S     # co-products production

Vcap  # carbon captured

Vseq  # carbon stored

;

execute_unload '%gdxoutfilepath%scenario_d.gdx'

GG    # emissions without emissions from land use change

Gbp   # emissions from biomass production

Gfr   # emissions from fertilizers

Gbt   # emissions from biomass transport

Gbc   # emissions from biomass conversion

Get   # emissions from biofuel transportation

;

execute_unload '%gdxoutfilepath%scenario_e.gdx'

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
