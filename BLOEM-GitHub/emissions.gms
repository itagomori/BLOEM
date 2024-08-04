$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* BLOEM-China
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    fp(r)               'fuel consumption for biomass production' # [l/GJ]

    fd                  'fuel emission factor' # [tCO2/l]

    eff(r,c)            'emission factor for fertilizer use' # [tN2O/km2]

    nf                  'conversion factor for emissions from fertilizer use' # [tCO2:tN2O]

    eft(r)              'emission factor for biomass transportation' # [kgCO2/GJ/km]

    efw(r)              'emission factor for bioenergy (biofuel) transportation' # [kgCO2/GJ/km]

    efc(r)              'emission factor for biomass conversion' # [kgCO2/GJ]

;


* Set fuel consumption for biomass production fp(r):
# need calibrate
Parameter fp(r)    / agriRes   0.293534, 
                     foresRes  0.3, 
                     egrass    0.6,
                     ewood     0.5 /;
;


* Set fuel emissions factor, diesel fuel fd:

Scalar fd     /0.0027/ ;


* Set conversion factor for emissions from fertilizer use nf:

Scalar nf     /298/ ; 


* Set emission factor for biomass transportation eft(r):
# need calibrate
Parameter eft(r)   / agriRes   0.003226,
                     foresRes    0.002985,
                     egrass        0.002956,
                     ewood         0.002956 /;
;


* Set emission factor for biofuel transportation efw(r):
# need calibrate
Parameter efw(r)   / biojet             0.006622,
                     biomethanol      0.006621,
                     bioelectricity     0.006621,
                     biochar          0.006621 /;
;


* Set emission factor for biomass conversion efc(r):
# need calibrate
Parameter efc(r)   / biojet          0.600000,
                     biomethanol     0.760498,
                     bioelectricity   0.000000,
                     biochar      0.000000 /;
;


* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Users\vicke\Desktop\model\BLOEM\BLOEM-GitHub\input\gdx\'


* Import emission factors for fertilizer use:
# columns: crop(agriRes, foresRes, egrass, ewood), gridcell, value(6.48~599.32)
# ? why there is no oil crops

$gdxin '%gdxinfilepath%efertilizers.gdx'

$load eff=efertilizers

$gdxin

;


* ---------------------------------------------------------------------------------------------------------
* Declare variables
* ---------------------------------------------------------------------------------------------------------

Variables

    ITG(t)          'impact of carbon emissions in time t'  # [US$]

    GG(t)           'total GHG emissions in time t'  # [tCO2eq]
    Gbp(t)          'GHG emissions from biomass production'  # [tCO2eq]
    Gfr(t)          'GHG emissions from fertilizer use in biomass production'  # [tCO2eq]
    Gbt(t)          'GHG emissions from biomass transportation'  # [tCO2eq]
    Gbc(t)          'GHG emissions from biomass conversion'  # [tCO2eq]
    Get(t)          'GHG emissions from bioenergy, biofuels, transportation'  # [tCO2eq]

;

Positive variables Gbp, Gfr, Gbt, Gbc, Get;


* ---------------------------------------------------------------------------------------------------------
* Equations
* ---------------------------------------------------------------------------------------------------------

Equations

    impactemissions(t)               'impact of land use change emissions'

    totalemissions(t)                'total gross emissions'
    emissionsbioprod(t)              'emissions from biomass production'
    emissionsfertilz(t)              'emissions from fertilizer use in biomass production'
    emissionsbiotransp(t)            'emissions from biomass transportation'
    emissionsbioconv(t)              'emissions from biomass conversion'
    emissionsbioentransp(t)          'emissions from biofuel transportation'

;

impactemissions(t) ..       ITG(t) =e= dfa(t)*k(t)*GG(t) ;


totalemissions(t) ..        GG(t) =e= Gbp(t)+Gfr(t)+Gbt(t)+Gbc(t)+Get(t)-sum((c),Vseq(c,t)$(cccs(c))) ;

# note on total emissions: without emissions from luc, which are added post optmization

emissionsbioprod(t) ..      Gbp(t) =e= sum((r,l,c),fp(r)$(rren(r))*B(r,l,c,t)$(rren(r))*fd) + sum((r,l,c),fp(r)$(rres(r))*B(r,l,c,t)$(rres(r))*fd) ;

# Q: only energy crops need fertilizer
emissionsfertilz(t) ..      Gfr(t) =e= sum((r,l,c),eff(r,c)$(rren(r))*A(r,l,c,t)$(rren(r))*ga(c)*nf/1000) ;

# Q: whether limit the bioass transportation distance? replace mx with antother distance matrix
# here include both residues and energy crops
emissionsbiotransp(t) ..    Gbt(t) =e= sum((r,c,cn),eft(r)$(rren(r))*mx(c,cn)*tal(c)*Bn(r,c,cn,t)$(rren(r))/1000) + sum((r,c,cn),eft(r)$(rres(r))*mx(c,cn)*tal(c)*Bn(r,c,cn,t)$(rres(r))/1000) ;

emissionsbioconv(t) ..      Gbc(t) =e= sum((r,j,c),efc(r)$(rpli(r))*CP(j,c,t)*beta(r,j)$(rpli(r))/1000) ;

emissionsbioentransp(t) ..  Get(t) =e= sum((r,c,cn),efw(r)$(rpli(r))*mx(c,cn)*tal(c)*En(r,c,cn,t)$(rpli(r))/1000) ;
