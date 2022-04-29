function f = FitnessFunction(x)
    %terminal fitness fn for SDP; saturatiing with input, x (predator energetic
    %content)
    f = 1-exp(-x);
end

