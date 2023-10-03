The file **A1_ComputeSDOForMassRange.m** is the main script, and all other files are supporting functions. More details of how the pipeline 
works can be found in the associated .m files. However, broadly, this script runs 15 trials of the SDP computation for the range of predator, prey,
and competitor masses reported in the manuscript, and saves outputs for each trial. Note that this script requires the parallel computing toolbox, 
and that the number of cores in the parallel pool should be explicitly initialised before executing the script (in lieu of doing this, MATLAB will
simply open the default number of cores, which I believe is usually 8, and this will considerably increase the total computational time. I 
recommend having one core for each competitor mass, i.e., a total of 35 cores, for the 15 trials to be done within roughly 3-4 days). 
