using(DataFrames)
using(CSV)
using(RCall)
using(LinearAlgebra)
using(Distributions)
using(Arpack)
using(Optim)
using(Distributed)

#Link likelihood function
function lfunc(x,A,massvec_prey,massvec_pred)
    #Calculate Likelihood of proposed alpha, beta, gamma
    alpha = x[1];
    beta = x[2];
    gamma = x[3];
    
    numprey = size(A)[1];
    numpred = size(A)[2];
    # massvec_pred = massvec;
    # massvec_prey = massvec;
    
    L = Array{Float64}(undef,1);
    
    let cumLij = 0.0
        for i=1:numpred
            for j=1:numprey
  
                aij = copy(A[j,i]);
                mj = massvec_prey[j]; 
                mi = massvec_pred[i];
                
                Lij = 0.0;
                
                # Ratio is prey mass / pred mass
                pij = exp(alpha + beta*log(mj/mi) + gamma*log(mj/mi)^2)/(1+exp(alpha + beta*log(mj/mi) + gamma*log(mj/mi)^2));
                
                if aij == 1 
                    Lij = copy(pij);
                else
                    Lij = copy(1 - pij);
                end
                
                cumLij += log(Lij);
                
            end
        end
        L[1] = -cumLij
    end
    return L[1]
end

#Enter file location of hayward data
haywardfulldata = CSV.read("$(homedir())/.../data_hayward_all.csv",header=true,DataFrame);


#Caculcate mean preferred mass per predator
preds = ["Panthera leo","Crocuta crocuta"];

preymassvec = 10 .^(collect(1:0.01:4));
prob_scavenging = Array{Float64}(undef,length(preymassvec),length(preds));

#What percent represents a significant reliance?
sigpercent = 5

#Loop over lions and hyenas
for i=1:length(preds)
    predi = findall(x->x==preds[i],haywardfulldata[!,:Predator])
    percentkillsi = haywardfulldata[predi,:PercentOfKills];
    preyi = haywardfulldata[predi,:Prey];
    preyweight = haywardfulldata[predi,:Preybodymasskg34adultfemalemass];
    sigkills = findall(x->x>sigpercent,percentkillsi);

    #Build an interaction vector the length of prey
    predintv = zeros(Int64,length(preyi),1);
    predintv[sigkills,1] .+= 1;

    massvec_prey = copy(preyweight);
    massvec_pred = mean(haywardfulldata[predi,:Predbodymasskg]);

    #Adjustments - remove giraffes and buffalo for hyenas - these largely represent juvenile kills
    if i == 2
        rmpos = Array{Int64}(undef,0);
        removeprey = ["Giraffe Giraffa camelopardalis","Buffalo Syncerus caffer"];
        for k=1:length(removeprey)
            push!(rmpos,findall(x->x==removeprey[k],preyi)[1]);
        end
        predintv[rmpos,1] .= 0;
    end

    #Fit Logit to preyweight and predintv
    x0 = [0.0,0.0,0.0];
    results_ser = optimize(x->lfunc(x,predintv,massvec_prey,massvec_pred),x0,NelderMead());
    results_ser.minimizer
    xmax = results_ser.minimizer;

    plij = Array{Float64}(undef,length(preymassvec));
    for j=1:length(preymassvec)
        mi = massvec_pred[1];
        plij[j] = exp(xmax[1] + xmax[2]*log(preymassvec[j]/mi) + xmax[3]*log(preymassvec[j]/mi)^2)/(1+exp(xmax[1] + xmax[2]*log(preymassvec[j]/mi) + xmax[3]*log(preymassvec[j]/mi)^2));
    end


    #SCAVENGING LINKS
    # These are HUNTING AND SCAVENGING INTERACTIONS
    # Lions and hyenas have observed scavenging interactions with all included herbivores > 225 Kg 
    # See individual references in paper
    predscav = copy(predintv);
    megafauna = findall(x->x>225,preyweight)
    predscav[megafauna] .= 1;

    x0 = [0.0,0.0,0.0];
    results_scav = optimize(x->lfunc(x,predscav,massvec_prey,massvec_pred),x0,NelderMead());
    results_scav.minimizer
    xmax_scav = results_scav.minimizer;

    plij_scav = Array{Float64}(undef,length(preymassvec));
    for j=1:length(preymassvec)
        mi = massvec_pred[1];
        plij_scav[j] = exp(xmax_scav[1] + xmax_scav[2]*log(preymassvec[j]/mi) + xmax_scav[3]*log(preymassvec[j]/mi)^2)/(1+exp(xmax_scav[1] + xmax_scav[2]*log(preymassvec[j]/mi) + xmax_scav[3]*log(preymassvec[j]/mi)^2));
    end
    
    # probability of exclusively scavening is equal to probability of hunting and scavenging * probability of not hunting
    prob_scavenging[:,i] = plij_scav .* (1 .- plij)
    
    # R"""
    # plot($preymassvec,$prob_scavenging,log='x')
    # """

end

#Enter file location to save figure
namespace = "$(homedir())/.../fig_probscavenging.pdf"
R"""
pdf($namespace, width=5,height=4)
plot($preymassvec,$(prob_scavenging[:,1]),type='l',log='x',col='red',xlab='Prey weight (Kg)',ylab='Pr. exclusive scavenging)',lwd=2,ylim=c(0,1))
lines($preymassvec,$(prob_scavenging[:,2]),col='darkgreen',lwd=2)
dev.off()
"""

#Save probability distribution for plotting
output_table = DataFrame([preymassvec prob_scavenging[:,1] prob_scavenging[:,2]],:auto);
rename!(output_table,[:preymass,:lionprob,:hyenaprob]);
#Enter file location to save probability distributions
CSV.write("$(homedir())/.../exclusivescavengingprobabilities.csv",output_table; header=true);
