function [ metric ] = Hardness(Hparams, gs_energy, epsilon, beta, timeOut, num_runs)
%HARDNESS Calculates hardness metric of some problem H.
% Metric is either:
%       - time to epsilon with flag
%       - epsilon at timeout with flag
% Generated by running Metropolis until some specified epsilon

%% TEST

solved_energy = realmax;
time_elapsed = 0;
        
% Run n times, recording best solution and time taken
for run = 1: num_runs
    
    % GENERATE RANDOM SPIN CONFIGURATION
    n_qubits = max([length(Hparams{1}),length(Hparams{2}), ...
        length(Hparams{3}),length(Hparams{4}),length(Hparams{5})]);
    spinConfig = generate_spins(n_qubits, round(n_qubits/2));
       
    solution = infiniteMetropolis(spinConfig, Hparams, beta, gs_energy, epsilon, timeOut);
    solution_energy = solution{1};
    time_elapsed = solution{3};
    
    if solution_energy < solved_energy
        solved_energy = solution_energy; 
    end

end       

% Check if Timeout
deficit = (solved_energy - gs_energy);

if strcmp(solution{4}, 'TIMEOUT')
    
    metric = {time_elapsed, deficit, 'TIMEOUT'};
    
else    

    metric = {time_elapsed, deficit, 'TTS'};
    
end

end

    


