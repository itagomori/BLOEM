$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Author: Isabela Schmidt Tagomori
* Last update: 12.05.2021
* Version: 1.0
* Coupled IAM: BLUES
* Region: Brazil 
* Time frame: 2020-2050
* Module: Emissions
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

Parameter fp(r)    / sugarcane   0.293534,
                     oilcrops    7.283893,
                     wood        0.056621 /;
;


* Set fuel emissions factor, diesel fuel fd:

Scalar fd     /0.0027/ ;


* Set conversion factor for emissions from fertilizer use nf:

Scalar nf     /298/ ; 


* Set emission factor for biomass transportation eft(r):

Parameter eft(r)   / sugarcane   0.003226,
                     oilcrops    0.002985,
                     wood        0.002956 /;
;


* Set emission factor for biofuel transportation efw(r):

Parameter efw(r)   / ethanol1g          0.003534,
                     ethanol2g          0.003893,
                     biojet             0.006622,
                     dieselbiofuel      0.006621,
                     biodiesel          0.006621,
                     bioelectricity     0.006621 /;
;


* Set emission factor for biomass conversion efc(r):

Parameter efc(r)   / ethanol1g          0.000000,
                     ethanol2g          0.760498,
                     biojet             0.000000,
                     dieselbiofuel      0.000000,
                     biodiesel          0.013104,
                     bioelectricity     0.000000 /;
;


* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'X:\user\tagomorii\BLOEM\GDXinput\Main\'


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


totalemissions(t) ..                            GG(t) =e= Gbp(t)+Gfr(t)+Gbt(t)+Gbc(t)+Get(t)-sum((c),Vseq(c,t)$(cs(c))) ;

# note on total emissions: without emissions from luc, which are added post optmization

emissionsbioprod(t) ..                          Gbp(t) =e= sum((r,l,c),fp(r)$(rc(r))*B(r,l,c,t)$(rc(r))*fd) ;

emissionsfertilz(t) ..                          Gfr(t) =e= sum((r,l,c),eff(r,c)$(rc(r))*A(r,l,c,t)$(rc(r))*ga(c)*nf/1000) ;

emissionsbiotransp(t) ..                        Gbt(t) =e= sum((r,c,cn),eft(r)$(rc(r))*mx(c,cn)*tal(c)*Bn(r,c,cn,t)$(rc(r))/1000) ;

emissionsbioconv(t) ..                          Gbc(t) =e= sum((r,j,c),efc(r)$(rp(r))*CP(j,c,t)*beta(r,j)$(rp(r))/1000) ;

emissionsbioentransp(t) ..                      Get(t) =e= sum((r,c,cn),efw(r)$(rp(r))*mxe(c,cn)*tal(c)*En(r,c,cn,t)$(rp(r))/1000) ;
