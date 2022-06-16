$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Author: Isabela Schmidt Tagomori
* Last update: 12.05.2021
* Version: 1.0
* Coupled IAM: BLUES
* Region: Brazil 
* Time frame: 2020-2050
* Module: Bioenergy Targets
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    pb(r,c,t)           'bioenergy production target' # [GJ/y] [kW/y]

    ex(r,c,t)           'bioenergy exportation target' # [GJ/y] [kW/y]

;


* Set exportation targets

# Ports:
# Suape = 1315
# Santos = 2698
# Paranaguá = 2744

Table ex(r,c,t) 'exportation of biofuels'  # [GJ]

                                2020    2030    2040    2050             
    ethanol1g.        1315      0       0       0       0              
    ethanol1g.        2698      0       0       0       0              
    ethanol1g.        2744      0       0       0       0              

    ethanol2g.        1315      0       0       0       0              
    ethanol2g.        2698      0       0       0       0              
    ethanol2g.        2744      0       0       0       0              

    biojet.           1315      0       0       0       0              
    biojet.           2698      0       0       0       0              
    biojet.           2744      0       0       0       0              

    dieselbiofuel.    1315      0       0       0       0              
    dieselbiofuel.    2698      0       0       0       0              
    dieselbiofuel.    2744      0       0       0       0              

    biodiesel.        1315      0       0       0       0              
    biodiesel.        2698      0       0       0       0              
    biodiesel.        2744      0       0       0       0              

;


* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'X:\user\tagomorii\BLOEM\GDXinput\Main\'


* Set bioenergy production targets

$gdxin '%gdxinfilepath%bioenergytargetsbr_ndcnovabr.gdx'

$load pb=bioenergytargetsbr

$gdxin

;


* ---------------------------------------------------------------------------------------------------------
* Declare variables
* ---------------------------------------------------------------------------------------------------------

Variables

    HE(r,c,t)       'local bioenergy consumption for product r in grid cell c in time t'

;

Positive variables HE;


* ---------------------------------------------------------------------------------------------------------
* Equations
* ---------------------------------------------------------------------------------------------------------

Equations

    bioenergytarget(r,c,t)           'meet demand for bioenergy in each decade'
    bioelectarget(r,c,t)             'meet demand for bioelectricity in each decade'

;

bioenergytarget(r,c,t)$(rp(r)) ..               pb(r,c,t)$(rp(r))+ex(r,c,t)$(rp(r)) =e= HE(r,c,t)$(rp(r)) ;

bioelectarget(r,c,t)$(re(r)) ..                 pb(r,c,t)$(re(r)) =l= E(r,c,t)$(re(r)) ;
