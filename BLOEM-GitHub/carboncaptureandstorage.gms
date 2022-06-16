$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Author: Isabela Schmidt Tagomori
* Last update: 12.05.2021
* Version: 1.0
* Coupled IAM: BLUES
* Region: Brazil 
* Time frame: 2020-2050
* Module: Carbon Capture and Storage
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Parameters

    gama(j,t)           'level of carbon capture' # [tCO2/GJ]

    onco(c,cn)          'onshore costs of carbon transportation' # [US$/tCO2]

    ofco(c)             'offshore costs of carbon transportation' # [US$/tCO2]

    maxst(c)            'maximum storaga capacity of a storage site' # [tCO2]

    flagvc(c,cn)        'flag to determine logistic interconnections from carbon source to carbon sink' # [binary, 0/1]

    flagvcin(cn,c)      'flag to determine logistic interconnections from carbon source to carbon sink' # [binary, 0/1]

;


# Storage sites:
# Onshore:   Água Grande = 1835
# Offshore:  Campos = 2597
#            Angra = 2650
#            Rio de Janeiro = 2652
#            Santos I = 2698
#            Santos II = 2716 
#            Paranaguá = 2744


* Set technologies carbon capture levels gama(j,t):

Table gama(j,t) 'rate of carbon capture by technology j'  # [tCO2/GJ]

                2020        2030        2040        2050        
    E1GC        0.02896     0.02896     0.02896     0.02896       
    BJTC        0.30769     0.30769     0.30769     0.30769     
    DFTC        0.30769     0.30769     0.30769     0.30769     
;


* Set maximum storage capacity for storage sites maxst(c):

Parameter maxst(c)  / 1835      53.0e6,
                      2597      169.7e6,
                      2650      21.7e6,
                      2652      23.0e6,
                      2698      19.8e6,
                      2716      26.0e9,
                      2744      17.3e6 /;
;


* Set offshore carbon transportation costs from port gridcell (c) to storage site ofco(c):

Parameter ofco(c)   / 1835      0.00,
                      2597      4.00,
                      2650      13.3,
                      2652      9.20,
                      2698      19.5,
                      2716      38.8,
                      2744      28.8 /;
;


* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'X:\user\tagomorii\BLOEM\GDXinput\Main\'


* Import onshore carbon transportation costs onco(c,cn):

$gdxin '%gdxinfilepath%carbontranspcosts.gdx'

$load onco=carbontranspcosts

$gdxin


* Import grid cell connection to carbon sequestration sites (flagvc):

$gdxin '%gdxinfilepath%flagvc.gdx'

$load flagvc=flagvc

$gdxin


* Import grid cell connection to carbon sequestration sites (flagvc):

$gdxin '%gdxinfilepath%flagvcin.gdx'

$load flagvcin=flagvcin

$gdxin

;


* ---------------------------------------------------------------------------------------------------------
* Declare variables
* ---------------------------------------------------------------------------------------------------------

Variables

    ICC(t)          'impact of carbon transportation and storage in time t'  # [US$]

    Vcap(c,t)       'carbon captured in gridcell c in decade d'  # [tCO2]
    Vseq(c,t)       'carbon stored in storage site related to grid cell c in decade d'  # [tCO2]
    Vn(c,cn,t)      'carbon flow between grid cells c and cn in time t'  # [tCO2]
    
    Vin(c,t)        'carbon into grid cell c'
    Vout(c,t)       'carbon out of grid cell c'

;

Positive variables ICC, Vcap, Vseq, Vn, Vin, Vout;


* ---------------------------------------------------------------------------------------------------------
* Equations
* ---------------------------------------------------------------------------------------------------------

Equations

    impactcarbontransport(t)         'impact of carbon transportation and storage'

    carboncaptured(c,t)              'carbon captured in grid cell c in decade d'
    carbonbalance(c,t)               'carbon balance in grid cell c in decade d'
    carbonintogridcell(c,t)          'carbon into grid cell c'
    carbonoutogridcell(c,t)          'carbon out of grid cell c'
    maxcapstorage(c)                 'maximum storage capacity of storage site in grid cell c'

;

impactcarbontransport(t) ..                     ICC(t) =e= dfa(t)*(sum((c,cn),onco(c,cn)*Vn(c,cn,t))+sum((c),ofco(c)*Vseq(c,t)$(cs(c)))) ;


carboncaptured(c,t) ..                          Vcap(c,t) =e= sum((j),CP(j,c,t)*gama(j,t)*uf) ;

carbonbalance(c,t) ..                           Vcap(c,t)+Vin(c,t)-Vout(c,t) =e= Vseq(c,t)$(cs(c)) ;

carbonintogridcell(c,t) ..                      Vin(c,t) =e= sum((cn),Vn(cn,c,t)*flagvcin(cn,c)) ;

carbonoutogridcell(c,t) ..                      Vout(c,t) =e= sum((cn),Vn(c,cn,t)*flagvc(c,cn)) ; 

maxcapstorage(c) ..                             sum((t),Vseq(c,t)$(cs(c)))*10 =l= maxst(c)$(cs(c)) ;
