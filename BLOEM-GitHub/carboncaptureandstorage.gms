$ontext
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Bioenergy Allocation Spatially Explicit Model - BLOEM
* Branch: BLOEM-Master
* Author: Isabela Schmidt Tagomori
* Last update: 14.08.2022
* Version: 2.0
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

    ccscap(c)           'maximum storaga capacity of a storage site' # [tCO2]

;

* Set technologies carbon capture levels gama(j,t):

Table gama(j,t) 'rate of carbon capture by technology j'  # [tCO2/GJ]

                t1          tX        # substitute TEC+, t and gama, accordingly (for examples, see regional branches)        
    TEC1+       gama1       gama2       
    TECX+       gama3       gamaX          
;

* Set offshore carbon transportation costs from port grid cell (c) to storage site grid cell, ofco(c):

Parameter ofco(c)   / X1        ofco1,        # substitute X and ofco, accordingly (for examples, see regional branches)
                      XX        ofcoX /;
;

* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Path\'  # set your path for inputs


* Import maximum storage capacity for storage sites

$gdxin '%gdxinfilepath%ccscap.gdx'

$load ccscap=ccscap

$gdxin


* Import onshore carbon transportation costs onco(c,cn):

$gdxin '%gdxinfilepath%carbontranspcosts.gdx'

$load onco=carbontranspcosts

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

impactcarbontransport(t) ..                     ICC(t) =e= dfa(t)*(sum((c,cn),onco(c,cn)*Vn(c,cn,t))+sum((c),ofco(c)*Vseq(c,t)$(cccs(c)))) ;


carboncaptured(c,t) ..                          Vcap(c,t) =e= sum((j),CP(j,c,t)*gama(j,t)*uf) ;

carbonbalance(c,t) ..                           Vcap(c,t)+Vin(c,t)-Vout(c,t) =e= Vseq(c,t)$(cccs(c)) ;

carbonintogridcell(c,t) ..                      Vin(c,t) =e= sum((cn),Vn(cn,c,t)) ;

carbonoutogridcell(c,t) ..                      Vout(c,t) =e= sum((cn),Vn(c,cn,t)) ; 

maxcapstorage(c) ..                             sum((t),Vseq(c,t)$(cs(c)))*10 =l= ccscap(c)$(cccs(c)) ;
