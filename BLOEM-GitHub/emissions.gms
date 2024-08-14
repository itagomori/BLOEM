$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Branch: BLOEM-Master
* Author: Isabela Schmidt Tagomori
* Last update: 14.08.2022
* Version: 2.0
* Module: GHG Emissions
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    fp(r)               'fuel consumption for biomass production'  # [l/GJ]

    fd                  'fuel emission factor'  # [tCO2/l]

    eff(r,c)            'emission factor for fertilizer use'  # [tN2O/km2]

    nf                  'conversion factor for emissions from fertilizer use'  # [tCO2:tN2O]

    eft(r)              'emission factor for biomass transportation'  # [kgCO2/GJ/km]

    efw(r)              'emission factor for bioenergy (biofuel) transportation'  # [kgCO2/GJ/km]

    efc(r)              'emission factor for biomass conversion'  # [kgCO2/GJ]

;


* Set fuel emissions factor, diesel fuel (fd):

Scalar

    fd     'emission factor for fuel consumption in biomass production'     /0.0027/ 

;

* Set conversion factor for emissions from fertilizer use nf:

Scalar

    nf     'conversion factor for emissions from fertilizer use'     /298/ 

;

* Set fuel consumption for biomass production fp(r):

Parameter fp(r)    / biomass1    fp,        # substitute biomass and fp, accordingly (for examples, see regional branches)
                     biomassX    fp /;
;

* Set emission factor for biomass transportation eft(r):

Parameter eft(r)   / biomass1    eft,        # substitute biomass and eft, accordingly (for examples, see regional branches)
                     biomassX    eft /;
;


* Set emission factor for biofuel transportation efw(r):

Parameter efw(r)   / product1    efw,        # substitute product and efw, accordingly (for examples, see regional branches)
                     productX    efw /;
;


* Set emission factor for biomass conversion efc(r):

Parameter efc(r)   / product1    efc,        # substitute product and efc, accordingly (for examples, see regional branches)
                     productX    efc /;
;

* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Path\'  # set your path for inputs


* Import emission factors for fertilizer use:

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

impactemissions(t) ..                           ITG(t) =e= dfa(t)*k(t)*GG(t) ;


totalemissions(t) ..                            GG(t) =e= Gbp(t)+Gfr(t)+Gbt(t)+Gbc(t)+Get(t)-sum((c),Vseq(c,t)$(cccs(c))) ;

# note on total emissions: without emissions from luc, which are added post optmization

emissionsbioprod(t) ..                          Gbp(t) =e= sum((r,l,c),fp(r)$(rsou(r))*B(r,l,c,t)$(rsou(r))*fd) ;

emissionsfertilz(t) ..                          Gfr(t) =e= sum((r,l,c),eff(r,c)$(rsou(r))*A(r,l,c,t)$(rsou(r))*ga(c)*nf/1000) ;

emissionsbiotransp(t) ..                        Gbt(t) =e= sum((r,c,cn),eft(r)$(rsou(r))*mx(c,cn)*tal(c)*Bn(r,c,cn,t)$(rsou(r))/1000) ;

emissionsbioconv(t) ..                          Gbc(t) =e= sum((r,j,c),efc(r)$(rmap(r))*CP(j,c,t)*beta(r,j)$(rmap(r))/1000) ;

emissionsbioentransp(t) ..                      Get(t) =e= sum((r,c,cn),efw(r)$(rliq(r))*mxdem(c,cn)*tal(c)*En(r,c,cn,t)$(rliq(r))/1000) ;
