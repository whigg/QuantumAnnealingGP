function [ H ] = generate_random_3local_hamiltonian( n_qubits, conn_density, h_range, J_range )
%GENERATE_RANDOM_HAMILTONIAN Generates a random Hamiltonian

%% Generate random Hamiltonian
% Array of h coef for local fields


h = random_coef([n_qubits], h_range(1), h_range(2), conn_density );

Jzzz  = random_coef( [n_qubits,n_qubits,n_qubits], J_range(1), J_range(2), conn_density );
Jxx  = 0; % Couplings turned off
Jzz = 0; % Couplings turned off
Jxxx = 0; % Couplings turned off

H = ising_hamiltonian(h, Jzz, Jxx, Jzzz, Jxxx);

end
