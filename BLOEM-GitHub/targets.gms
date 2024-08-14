$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Branch: BLOEM-Master
* Author: Isabela Schmidt Tagomori
* Last update: 14.08.2022
* Version: 2.0
* Module: Targets for Bioenergy Production
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    pb(r,c,t)           'bioenergy production target' # [GJ/y] [kW/y]

    ex(r,c,t)           'bioenergy exportation target' # [GJ/y] [kW/y]

;

* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Path\'  # set your path for inputs


* Set bioenergy production targets

$gdxin '%gdxinfilepath%bioenergytargets_scenario.gdx'

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
    bioelectarget(r,c,t)             'meet demand for bioelectricity in each decade'

;

bioenergytarget(r,c,t)$(rliq(r)) ..             pb(r,c,t)$(rliq(r))+ex(r,c,t)$(rliq(r)) =e= HE(r,c,t)$(rliq(r)) ;

bioelectarget(r,c,t)$(re(r)) ..                 pb(r,c,t)$(re(r)) =l= E(r,c,t)$(re(r)) ;
