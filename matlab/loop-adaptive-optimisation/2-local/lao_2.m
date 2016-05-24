function [solution, J_global, gs_energy] = lao_2(num_spins, num_loops, num_steps)

    % Add path for Hardness function
    addpath('../../MonteCarlo/HardnessMeasures')
    
    % ** Algorithm **
    % Generate (random) solution
    % Place M random loops on graph, each respecting the planted solution
    % Calculate GS energy
    % for step = 1 to NSTEP do
        % Remove random loop from current instance
        % Pick new random loop and add, respecting planted solution
        % Get new TTS
        % if TTS increases then
            % Accept Change, update GS energy
        % else
            % Accept with probability e^??|?TTS|
            % 13: Update GS energy if accepted
        % 14: end if
    % end for
    
    % Generate random solution, of size N
    solution = (round(rand(1,num_spins))*2)-1;
    
    % Define adjacency matrix - allowed couplings
    %    e.g. All-to-all
    adj = ones(num_spins) - eye(num_spins);
    
    % Initialise empty loop array
    loops = zeros(num_loops, num_spins+1);
    
    % Fill loop array with M loops
    disp('Generating initial loops...');
    tic;
    for i = 1:num_loops
        % Generate random walk loop
        loop = random_walk_loop_2( adj );
        % Pad with zeros
        loop = [loop, zeros(1, (num_spins+1)-length(loop))];
        % Add to loop array
        loops(i,:) = loop; 
        
        % Progress timer
        if toc > 1
            disp(strcat(num2str(i),':',num2str(num_loops)));
            tic;
        end
    end
    
    % Calculate planted couplings and energies
    [J_global, gs_energy] = planted_hamiltonian_2(solution, loops);
    
    % Start Optimisation stage
    % Calculate hardness of original Ising problem
    %   Hardness function parameters
    epsilon  = 5;
    beta_h   = 10^4;
    timeOut  = 1;
    num_runs = 10;
    %   Set up H params
    hParams = {0, J_global, 0, 0, 0};
    %   Calculate hardness
    old_hardness = Hardness(hParams, gs_energy, epsilon, beta_h, timeOut, num_runs);
    
    % Loop for for each step in num_steps
    disp('Starting optimisation step...');
    start_tic = tic;
    for step = 1:num_steps
        % Make copy of loops array
        new_loops = loops;
        % Generate new loop
        new_loop = random_walk_loop_2( adj );
        % Pad with zeros
        new_loop = [loop, zeros(1, (num_spins+1)-length(loop))];
        % Replace random loop from new loops array with new loop
        new_loops(randi(num_loops),:) = new_loop;
        
        % Calculate planted couplings and energies
        [new_J_global, new_gs_energy] = planted_hamiltonian_2(solution, new_loops);
        
        % Calculate new Ising problem hardness
        new_hParams = {0, new_J_global, 0, 0, 0};
        new_hardness = Hardness(new_hParams, new_gs_energy, epsilon, beta_h, timeOut, num_runs);
        
        % Decision tree
        %   If TTS, then time decides
        %   If TIMEOUT, then energy deficit decides
        %   TIMEOUT trumps TTS
        if strcmp( old_hardness{3}, 'TTS' )
            if strcmp( new_hardness{3}, 'TTS' )
                new_TTS = new_hardness{1};
                old_TTS = old_hardness{1};
                if new_TTS > old_TTS
                    accept_change = true;
                else
                    accept_change = false;
                    delta_hardness = (old_TTS - new_TTS)/new_TTS;
                end
            elseif strcmp( new_hardness{3}, 'TIMEOUT' )
                accept_change = true;
            end
        elseif strcmp( old_hardness{3}, 'TIMEOUT' )
            if strcmp( new_hardness{3}, 'TTS' )
                accept_change = false;
                delta_hardness = realmax; % block change
            elseif strcmp( new_hardness{3}, 'TIMEOUT' )
                new_deficit = new_hardness{2};
                old_deficit = old_hardness{2};
                if new_deficit > old_deficit
                    accept_change = true;
                else
                    accept_change = false;
                    delta_hardness = (old_deficit - new_deficit)/new_deficit;
                end
            end
        end
           
        % If new problem harder, then accept
        % Temperature for state swap
        beta_opt = 10;
        if accept_change
            gs_energy = new_gs_energy;
            J_global = new_J_global;
            loops = new_loops;
            old_hardness = new_hardness;
        else % Else accept with Boltzmann dist
            if rand() > exp(-beta_opt*abs(delta_hardness))
                % Accept
                gs_energy = new_gs_energy;
                J_global = new_J_global;
                loops = new_loops;
                old_hardness = new_hardness;
            end
        end

        % Progress timer
        if toc(start_tic) > 2
            disp(strcat(num2str(step),':',num2str(num_steps)));
            start_tic = tic;
        end 
    end   
end

