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
* Module: Carbon Capture and Storage
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$offtext

* ----------------------------------------------------------------------------------------------------------
* Define parameters
* ----------------------------------------------------------------------------------------------------------

Scalar

    co2transc            'carbon transportation costs (onshore)'  / 0.1195 /  # $/(tCO2/km)

;

Parameters

    gama(j,t)            'level of carbon capture'  # [tCO2/GJ]

    ccscap(c)            'maximum storage capacity of a storage site'  # [tCO2]

;

* Set technologies carbon capture levels gama(j,t):

Table gama(j,t) 'rate of carbon capture by technology j'  # [tCO2/GJ]

                2020        #2030       #2040       #2050       #2060
    ACG+        0.39
    GCG+        0.39
    WCG+        0.39
    AFT+        0.064
    GFT+        0.064
    WFT+        0.064
    AME+        0.031
    GME+        0.031
    WME+        0.031
;

* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Users\vicke\Desktop\model\BLOEM\BLOEM-GitHub\input\gdx\'


* Import maximum storage capacity for storage sites

$gdxin '%gdxinfilepath%ccscap.gdx'

$load ccscap=ccscap

$gdxin

;

* ---------------------------------------------------------------------------------------------------------
* Declare variables
* ---------------------------------------------------------------------------------------------------------

Variables

    ICC(t)          'impact of carbon transportation and storage in time t'  # [US$]
    
    Vcap(c,t)       'carbon captured in gridcell c in time t'  # [tCO2]
    Vseq(c,t)       'carbon stored in storage site related to grid cell c in time t'  # [tCO2]
    Vn(c,cn,t)      'carbon flow between grid cells c and cn in time t'  # [tCO2]

    Vin(c,t)        'carbon into grid cell c'
    Vout(c,t)       'carbon out of grid cell c'

;

Positive variables ICC, Vcap, Vseq, Vn, Vin, Vout ;

* ---------------------------------------------------------------------------------------------------------
* Equations
* ---------------------------------------------------------------------------------------------------------

Equations

    impactcarbontransport(t)        'impact of carbon transportation and storage'
    
    carboncaptured(c,t)             'carbon captured in grid cell c in decade d'
    carbonbalance(c,t)              'carbon balance in grid cell c in decade d'
    carbonintogridcell(c,t)         'carbon into grid cell c'
    carbonoutogridcell(c,t)         'carbon out of grid cell c'
    maxcapstorage(c)                'maximum storage capacity of storage site in grid cell c'
;

impactcarbontransport(t)..          ICC(t) =e= dfa(t)*sum((c,cn),co2transc*Vn(c,cn,t)*mx(c,cn)) ; 


carboncaptured(c,t)..               Vcap(c,t) =e= sum((j),CP(j,c,t)*gama(j,t)*uf) ;

carbonbalance(c,t)..                Vcap(c,t)+Vin(c,t)-Vout(c,t) =e= Vseq(c,t)$(cccs(c)) ; 

carbonintogridcell(c,t) ..          Vin(c,t) =e= sum((cn),Vn(cn,c,t)) ;

carbonoutogridcell(c,t) ..          Vout(c,t) =e= sum((cn),Vn(c,cn,t)) ; 


maxcapstorage(c)..                  sum((t),Vseq(c,t)$(cccs(c)))*10 =l= ccscap(c);  # 10 years
