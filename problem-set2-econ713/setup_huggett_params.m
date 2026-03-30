function params = setup_huggett_params(beta, sigma, phi)
% setup_huggett_params.m
% Build a parameter struct used by parts (d)-(j).

params.beta = beta;
params.sigma = sigma;
params.phi = phi;

params.y = [0.1; 1.0];
params.Pi = [0.5,   0.5;
             0.075, 0.925];

% Asset grid
params.a_min = -phi;
params.a_max = 40;
params.N_a = 400;
params.A = linspace(params.a_min, params.a_max, params.N_a)';

% VFI settings
params.vfi_tol = 1e-6;
params.vfi_max_iter = 2000;
params.vfi_print_every = 25;

% Stationary-distribution settings
params.dist_tol = 1e-12;
params.dist_max_iter = 20000;
params.dist_print_every = 500;

end
