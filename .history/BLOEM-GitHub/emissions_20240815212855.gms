$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Branch: BLOEM-China
* Authors: Rui Wang & Isabela Schmidt Tagomori
* Last update: 12.08.2024
* Version: 1.0
* Coupled IAM: IMAGE
* Region: China
* Time frame: 2020-2060
* Module: GHG Emissions
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    fp(r)               'fuel consumption for biomass production' # [l/GJ]

    fd                  'fuel emission factor' # [tCO2/l]

    eff(r)              'emission factor for fertilizer use' # [tN2O/km2]

    nf                  'conversion factor for emissions from fertilizer use' # [tCO2:tN2O]

    eft(r)              'emission factor for biomass transportation' # [kgCO2/GJ/km]

    efw(r)              'emission factor for bioenergy (biofuel) transportation' # [kgCO2/GJ/km]

    efc(r)              'emission factor for biomass conversion' # [kgCO2/GJ]

;

* Set fuel emissions factor, diesel fuel (fd):

Scalar 
    
    fd     'emission factor for fuel consumption in biomass production '     / 0.0027 / 
    
;


* Set conversion factor for emissions from fertilizer use (nf):

Scalar 
    
    nf     'conversion factor for emissions from fertilizer use'     / 298 / 

; 

* Set fuel consumption for biomass production fp(r):
# need calibrate

Parameter fp(r)    / agrires    0.293534, 
                     foresres   0.300000, 
                     grass      0.600000,
                     wood       0.500000 /;

* Set emission factor for biomass transportation eft(r):
# need calibrate

Parameter eft(r)   / agrires    0.003226,
                     foresres   0.002985,
                     grass      0.002956,
                     wood       0.002956 /;

* Set emission factor for biofuel transportation efw(r):
# need calibrate

Parameter efw(r)   / biojet           0.006622,
                     biomethanol      0.006621 /;


* Set emission factor for biomass conversion efc(r):
# need calibrate

Parameter efc(r)   / biojet           0.600000,
                     biomethanol      0.760498,
                     bioelectricity   0.000000,
                     biochar          0.000000 /;

* Set emission factor for fertilizer use eff(r):

Parameter eff(r)    / agrires    0,
                      foresres   0,
                      grass      550,
                      wood       10 /;

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

# Q: only energy crops need fertilizer
emissionsfertilz(t) ..                          Gfr(t) =e= sum((r,l,c),eff(r)$(rsou(r))*A(r,l,c,t)$(rsou(r))*ga(c)*nf/1000) ;

# Q: whether limit the bioass transportation distance? replace mx with antother distance matrix
# here include both residues and energy crops
emissionsbiotransp(t) ..                        Gbt(t) =e= sum((r,c,cn),eft(r)$(rsou(r))*mxbiomass(c,cn)*tal(c)*Bn(r,c,cn,t)$(rsou(r))/1000) ;

emissionsbioconv(t) ..                          Gbc(t) =e= sum((r,j,c),efc(r)$(rmap(r))*CP(j,c,t)*beta(r,j)$(rmap(r))/1000) ;

emissionsbioentransp(t) ..                      Get(t) =e= sum((r,c,cn),efw(r)$(rliq(r))*mxairhbr(c,cn)*tal(c)*En(r,c,cn,t)$(rliq(r))/1000) ;
