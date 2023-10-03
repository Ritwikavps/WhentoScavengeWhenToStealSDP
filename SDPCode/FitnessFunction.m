function f = FitnessFunction(x,Type)

%function to compute terminal fitness function; Type is a string input that
%determines the functional form of the fitness function. The switch ...
%case expression determines which functoonal form would be used based on
%the Type input

    switch Type
        case 'exponential'
            %terminal fitness fn for SDP; saturatiing with input, x (predator energetic
            %content)
            f = 1-exp(-x);
        case 'linear'
            %linear fitness functiobn
            f = x;
        otherwise
            error('Terminal fitness function type not recognised')
    end 
end
