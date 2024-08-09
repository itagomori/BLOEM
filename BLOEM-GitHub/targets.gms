$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* BLOEM-China
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    pb(r,c,t)           'bioenergy production target' # [GJ/y] [kW/y]

    ex(r,c,t)           'bioenergy exportation target' # [GJ/y] [kW/y]

    im(r,c,t)           'bioenergy import target' # [GJ/y] [kW/y]

;

* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Users\vicke\Desktop\BLOEM-China\input\gdx\'


* Set bioenergy production targets
# columns: r(biodiesel, biojet), c(airport_id, harbor_id), d(2020, 2030, 2040, 2050), value
$gdxin '%gdxinfilepath%tarbp.gdx'

$load pb=tarbp

$gdxin


# Set bioenergy export targets
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
*    bioelectarget(r,c,t)             'meet demand for bioelectricity in each decade'
*    biochartarget(r,c,t)             'meet demand for biochar in each dacade'

;

bioenergytarget(r,c,t)$(rliq(r)) ..   pb(r,c,t)$(rliq(r))+ex(r,c,t)$(rliq(r)) =e= HE(r,c,t)$(rliq(r)) + im(r,c,t)$(rliq(r)) ;

# Q: confuse about this electricity target. Can we use the total amount of electricity demand as constraints?
#bioelectarget(r,c,t)$(re(r)) ..                 pb(r,c,t)$(re(r)) =l= E(r,c,t)$(re(r)) ;
