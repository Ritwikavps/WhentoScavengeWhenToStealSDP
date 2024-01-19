# WhentoScavengeWhenToStealSDP
This repository contains code written by RVPS and JY for the simulations (RVPS), data analysis (RVPS, JY) and figures (RVPS) presented in the manuscript 'Beyond the kill: The allometry of predation behaviours among large carnivores' by Ritwika VPS (UC Merced, UCLA), Ajay Gopinathan (UC Merced), and Justin Yeakel (UC Merced). 

The directory **SDPCode** contains the main simulation code; **CodeForFigs** contains the code written to analyse simulation resuls and generate figs in the main text (in the directory *AnalysisOfResultsAndMainFigs), as well as figs in the supplementary material (in the directory *SuppInfoFigs*); and **SensitivityAnalyses** contains code used to run sensitivity analyses and plot the results of these analyses, as reported in the supplementary material.

Finally, **ObsData** contains all observational data presented in the manuscript. This is relevant to Figs. 3, 4, and 5 in the main text. 

All code was written in MATLAB, and each directory contains its own README with relevant details. 

## Additional notes associated with manuscript revisions (Jan 2024)

1. The functions required to generate Figs. 2 and 3 in the main text have been revised to utilise viridis-inspired colormaps so as to be more accesible to readers who are colour-blind. As such, you will need to have the suite of functions linked here (https://www.mathworks.com/matlabcentral/fileexchange/51986-perceptually-uniform-colormaps?s_tid=mwa_osa_a) downloaded and in the MATLAB path. We have chosen not to provide these functions in this repository since they were written and licensed by other author(s). We also note that we utilised version  1.3.2 of this suite of functions.
2. Please note that all references in the code and comments to fitness (eg. fitness function, fitness maximisation, etc.) point to the survival-maximisation procedure mentioned in the manuscript.
We revised the terminology and changed all references to fitness and fitness-maximisation to probability of survival and survival-maximisation, respectively, per Reviewer and Editor suggestions, so as to be more precise and accurate about the methods used in the study. Essentially, because we have not included reproductive output in our stochastic dynamic program, the use of the term ‘fitness-maximization’ is inaccurate. What we do asses in the model are behaviors that maximize survival and as such, it is the probability of survival is what is being maximized and used to compare between alternative predatory tactics. However, all code was written well before these changes were made, and we have opted to orient the reader to these changes rather than changing all references to fitness and associated terms in the code. 



