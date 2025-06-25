$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Author: Isabela Schmidt Tagomori & Aline Carvalho
* Last update: 10.08.2024
* Version: 1.0
* Coupled IAM: COFFEE
* Region: Europe 
* Time frame: 2025
* Module: Bioenergy Targets
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    pb(r,c,t)           'bioenergy production target of main product in kW/y' # [GJ/y] [kW/y]

    ex(r,c,t)           'bioenergy exportation target' # [GJ/y] [kW/y]

;


* Set exportation targets

# Ports:
# Rotterdam = 1744
# Antwerp = 1799


Table ex(r,c,t) 'exportation of biofuels'  # [GJ]

                                2025    #2030    2040    2050             
    greendiesel.        1233      0       #0       0       0              
    #greendiesel.        1744      0       #0       0       0              

;


* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\BLOEM\github\input\'


* Set bioenergy production targets

$gdxin '%gdxinfilepath%bioenergytargets.gdx'

$load pb=bioenergytargets

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
    #bioelectarget(r,c,t)             'meet demand for bioelectricity in each decade'

;

bioenergytarget(r,c,t)$(rliq(r)) ..               pb(r,c,t)$(rliq(r))+ex(r,c,t)$(rliq(r)) =e= HE(r,c,t)$(rliq(r)) ;

#bioelectarget(r,c,t)$(re(r)) ..                 pb(r,c,t)$(re(r)) =l= E(r,c,t)$(re(r)) ;
