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

    mxccs(c,cn)          'distance between ccs cites c and grid cell cn' # [km]

    flagccsout(c,cn)       'flag to determine logistic interconnections from carbon source to carbon sink' # [binary, 0/1]

    flagccsin(cn,c)       'flag to determine logistic interconnections from carbon source to carbon sink' # [binary, 0/1]

;


* ----------------------------------------------------------------------------------------------------------
* Import data
* ----------------------------------------------------------------------------------------------------------

* Setting gdx input filepath

$setglobal gdxinfilepath 'C:\Users\vicke\Desktop\BLOEM\BLOEM-GitHub\input\gdx\'


* Import carbon capture rate of technology j in year t

$gdxin '%gdxinfilepath%ccsrate.gdx'

$load gama = ccsrate

$gdxin


* Import maximum storage capacity for storage sites

$gdxin '%gdxinfilepath%ccscap.gdx'

$load ccscap=ccscap

$gdxin


* Import ccs matrix

$gdxin '%gdxinfilepath%mxccs_3000km.gdx'

$load mxccs=mxccs_3000km

$gdxin


* Import grid cell connection to carbon sequestration sites (flagvc):

$gdxin '%gdxinfilepath%flagccsout_3000km.gdx'

$load flagccsout=flagccsout_3000km

$gdxin


* Import grid cell connection to carbon sequestration sites (flagvc):

$gdxin '%gdxinfilepath%flagccsin_3000km.gdx'

$load flagccsin=flagccsin_3000km

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

impactcarbontransport(t)..          ICC(t) =e= dfa(t)*sum((c,cn),co2transc*Vn(c,cn,t)*mxccs(c,cn)) ;


carboncaptured(c,t)..               Vcap(c,t) =e= sum((j),CP(j,c,t)*gama(j,t)*uf) ;

carbonbalance(c,t)..                Vseq(c,t)$(cccs(c)) =e= Vcap(c,t)+Vin(c,t)-Vout(c,t) ;

carbonintogridcell(c,t) ..          Vin(c,t) =e= sum((cn),Vn(cn,c,t)*flagccsin(cn,c)) ;

carbonoutogridcell(c,t) ..          Vout(c,t) =e= sum((cn),Vn(c,cn,t)*flagccsout(c,cn)) ;


maxcapstorage(c)..                  sum((t),Vseq(c,t)$(cccs(c)))*10 =l= ccscap(c);  # 10 years
