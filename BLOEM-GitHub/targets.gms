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

    im(r,c,t)           'bioenergy imports' # [GJ/y] [kW/y]

    bioelec(t)          'bioelectricity production target' # [kW/y]

    biochar(t)          'biochar production target' # [GJ/y]

;

* Set bioelectricity target

Parameter bioelec(t) /  t1        bioelec1,          # substitute t and bioelec accordingly, for examples see regional branches
                        tX        bioelecX /;
;

* Set biochar target

Parameter biochar(t) /  t1        biochar1,          # substitute t and biochar accordingly, for examples see regional branches
                        tX        biocharX /;
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


* Set bioenergy export targets

$gdxin '%gdxinfilepath%tarex.gdx'

$load ex=tarex

$gdxin


# Set bioenergy import targets

$gdxin '%gdxinfilepath%tarim.gdx'

$load im=tarim

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

bioelectarget(t) ..                             sum((r,c),E(r,c,t)$(rele(r))) =e= bioelec(t) ;

biochartarget(t) ..                             sum((r,c),E(r,c,t)$(rchr(r))) =e= biochar(t) ;
