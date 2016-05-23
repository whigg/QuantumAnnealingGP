clc
clearvars


n_qubits = 9;
conn_density = 0.5;
h_range = [-1, 1];
J_range = [-1, 1];
disorder = round(n_qubits / 2);
beta = 10000;

%Hparams = generate_random_3local_hamiltonian(n_qubits, conn_density, h_range, J_range);
Hparams = {0, NN_couplings(n_qubits, 1), 0, 0, 0};

gs_energy = -8;
epsilon =1;

timeOut = 0.1;
num_runs = 5;

%solutionMet = Solver(spinConfig, Hparams, 'Metropolis');
%solutionHB = Solver(spinConfig, Hparams, 'HeatBath');
%solutionSA = Solver(spinConfig, Hparams, 'SimulatedAnnealing');
tic
hardnessSA = Hardness(Hparams, gs_energy, epsilon, 'SimulatedAnnealing', timeOut, num_runs);
%solutionPIQMC = Solver(spinConfig, Hparams, 'PIQMC');

%disp(solutionMet{1});
%disp(solutionHB{1});
%disp(solutionSA{1});
disp(hardnessSA{1});
disp(hardnessSA{2});
%disp(solutionPIQMC{1});
toc

