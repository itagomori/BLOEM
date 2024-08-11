$ontext
* BLOEM-China
$offtext

* --------------------------------
* Define parameters
* --------------------------------

Parameters

    gama(j, t)      'level of carbon capture' # [tCO2/GJ]

    ccscap(c)       'maximum storage capacity of a storage site' # [tCO2]

;

* Set technologies carbon capture levels gama(j,t)

Table gama(j, t) 'rate of carbon capture by technology j' # [tCO2/GJ]

                2020
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

* Set transportation costs between c and cn
Scalar

    co2transc   'carbon transportation costs'   /0.1195/ # $/(tCO2/km)
;

* ------------------------------------------
* import data
* -----------------------------------------

* Setting gdx input filepath
$setglobal gdxinfilepath 'C:\Users\vicke\Desktop\BLOEM-China\input\gdx\'

* Import maximum storage capacity for storage sites maxst(c)
$gdxin '%gdxinfilepath%ccscap.gdx'

$load ccscap = ccscap

$gdxin



* --------------------------------------------
* Declare variables
* --------------------------------------------
Variables

    ICC(t)          'impact of carbon transportation and storage in time t' # [US$]
    Vcap(c, t)      'carbon captured in gridcell c in decade d' # [tCO2]
    Vseq(c, t)      'carbon stored in storage site related to grid cell c in decade d' # [tCO2]
    Vn(c, cn, t)    'carbon flow between grid cells c and cn in time t' # [tCO2]

    Vin(c, t)       'carbon into grid cell c'
    Vout(c, t)      'carbon out of grid cell c'
;

Positive variables ICC, Vcap, Vseq, Vn, Vin, Vout;

* -------------------------
* Equations
* ---------------------------

Equations

    impactcarbontransport(t)        'impact of carbon transportation and storage'
    
    carboncaptured(c,t)             'carbon captured in grid cell c in decade d'
    carbonbalance(c,t)              'carbon balance in grid cell c in decade d'
    carbonintogridcell(c,t)         'carbon into grid cell c'
    carbonoutogridcell(c,t)         'carbon out of grid cell c'
    maxcapstorage(c)                'maximum storage capacity of storage site in grid cell c'
;

# Q: carbon capture and storage cost should be written at here or technologies?
impactcarbontransport(t)..          ICC(t) =e= dfa(t)* sum((c,cn), co2transc*Vn(c,cn,t)); 

carboncaptured(c,t)..               Vcap(c,t) =e= sum((j), CP(j,c,t)*gama(j,t)*uf);  # CP represent capacity factor in logistics.gms

carbonbalance(c,t)..                Vseq(c,t)$(cccs(c)) =e= Vcap(c,t)+Vin(c,t)-Vout(c,t) ; # Q: I have 40 cs(c), how to import?

carbonintogridcell(c,t) ..          Vin(c,t) =e= sum((cn),Vn(cn,c,t)*mx(cn,c)) ;

carbonoutogridcell(c,t) ..          Vout(c,t) =e= sum((cn),Vn(c,cn,t)*mx(c,cn)) ; 

maxcapstorage(c)..                  sum((t), Vseq(c,t)$(cccs(c)))*10 =l= ccscap(c);  # 10 years