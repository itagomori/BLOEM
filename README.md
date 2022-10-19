# Bioenergy and Land Optimization spatially Explicit Model (BLOEM)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![DOI](https://zenodo.org/badge/504185615.svg)](https://zenodo.org/badge/latestdoi/504185615)

_Author: Isabela Schmidt Tagomori_\
_Contact: Isabela Schmidt Tagomori - isabela.tagomori@pbl.nl | [@IsabelaTagomori](https://twitter.com/isabelatagomori)_

## Description
The Bioenergy and Land Optimization Spatially Explicit Model (BLOEM) is a perfect foresight, spatially explicit, least-cost optimization model. The model is formulated as a linear programming model, accounting for both total system’s costs and GHG emissions, aiming at complying with a given bioenergy production target at minimum cost.

BLOEM is a model developed to evaluate pathways for bioenergy deployment. Therefore, BLOEM is structured to, given a bioenergy production target and subject to a set of constraints (e.g., costs of production and conversion of biomass, transportation of feedstocks and products, biomass yields, land availability, technologies available for the conversion of biomass into bioenergy vectors):

- Identifying and quantifying main costs of bioenergy pathways.
- Identifying which feedstocks to grow and where to grow them.
- Identifying the optimal location for biomass conversion units.
- Identifying logistics constraints and system expansion projections, taking into account the existing bioenergy value chain.
- Identifying opportunities and constraints for the deployment of carbon capture, transportation and storage from biogenic sources.
- Determining the emission implications of bioenergy pathway (e.g., direct land use change emissions, biomass production emissions).
- Providing contributions to long-term climate policy design, given the opportunity of competitive advantages in low carbon scenarios.

## Spatial Resolution
The model formulation here presented is applied to the Brazilian spatial configuration, but it can be applied to different regions, spatial resolutions and time frames, according to the availability of required data and computational effort. The model can be used for standalone runs, but it can also be coupled with different levels (global, regional, national) of integrated assessment models (IAMs), through soft-link.

## Folder Structure and Scripts
This repository is organized as follows:

#### [BLOEM-GitHub](BLOEM-GitHub)
The source-code of BLOEM is located here. It comprehends the following scripts:
- **[BLOEM_Main_1_1.gms](BLOEM-GitHub/BLOEM_Main_1_1.gms)**: Main script of BLOEM, containing the objective function.
- **[biomassproduction.gms](BLOEM-GitHub/biomassproduction.gms)**: Module of feedstock production.
- **[carboncaptureandstorage.gms](BLOEM-GitHub/carboncaptureandstorage.gms)**: Module of carbon capture, transportation and storage.
- **[emissions.gms](BLOEM-GitHub/emissions.gms)**: Module of GHG emissions.
- **[logistics.gms](BLOEM-GitHub/logistics.gms)**: Module of logistics of feedstocks and biofuels.
- **[targets.gms](BLOEM-GitHub/targets.gms)**: Module of local bioenergy targets and export targets.
- **[technologiesportfolio.gms](BLOEM-GitHub/technologiesportfolio)**: Module of technologies portfolio, including costs and efficiencies.

_Note: The model code and inputs are applied for the case study about the Brazilian bioenergy pathways in a low carbon scenario, under different land availability constraints. The code can be adapted to other regions and/or other case study inputs (e.g., changes in the technologies portfolio, feedstocks available, update of costs and factors)._

## Language
The model was developed in the General Algebraic Modeling System (GAMS) modeling platform and is solved using the CPLEX Optimizer.

For GAMS documentation, please visit: [https://www.gams.com/latest/docs](https://www.gams.com/latest/docs)

## References
***BLOEM documentation***\
Tagomori, I. (2022). [Bioenergy and Carbon Capture and Storage Spatially Explicit Modelling in Brazil](http://www.ppe.ufrj.br/images/Tese_Isabela_Tagomori.pdf). *Methods*. Graduate School of Engineering (COPPE), Universidade Federal do Rio de Janeiro (UFRJ).
