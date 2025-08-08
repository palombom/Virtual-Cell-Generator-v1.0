clear all
close all
clc

addpath(genpath('src'))

%% Load simulation parameters
tic
[Ls, SD_Ls, Rseg, Rsoma, Nseg, SD_Nseg, Nbranch, SD_Nbranch, D, sphericity, Nspin, MCsteps]=readvars('parameters_simulations.txt');
D = D * 1e-9;

disp('1 - Reading Initialization Parameters')
fprintf(['  * Parameters used for simulation: \n' ...
'    Cellular projections'' length, Ls (s.d.) = ' num2str(Ls) ' (' num2str(SD_Ls) ') um\n' ...
'    Number of main cellular projections radiating from soma, Nseg (s.d.) = ' num2str(Nseg) ' (' num2str(SD_Nseg) ') \n' ...
'    Number of consecutive embranchments, Nbranch (s.d.) = ' num2str(Nbranch) ' (' num2str(SD_Nbranch) ') \n' ...
'    Radius of cellular projections, Rseg = ' num2str(Rseg) ' um\n' ...
'    Radius of soma, Rsoma = ' num2str(Rsoma) ' um\n' ...
'    Diffusivity, D = ' num2str(D*1e9) ' um2/ms\n' ...
'    Number of particles to simulate, Nspin = ' num2str(Nspin) '\n'...
'    Number of time steps for the Monte Carlo simulation, MCsteps = ' num2str(MCsteps) '\n']);
tt = toc;
disp(['[DONE] - ' num2str(round(tt)) ' sec.'])

%% Create repositories for saving the results

name_repo = 'simulations_results';
main_out_dir = fullfile(pwd, name_repo);
scheme_folder = fullfile(main_out_dir, 'schemefiles');
mkdir(scheme_folder);
substrate_folder = fullfile(main_out_dir, 'substrates');
mkdir(substrate_folder);
output_folder = fullfile(main_out_dir, 'signals');
mkdir(output_folder);

%% Create substrate

disp('2 - Creating Cellular Substrate')
tic
filename_substrate = ['cellmodel_Nseg_' num2str(Nseg) '_Ls_' num2str(Ls) '_Nbranch_' num2str(Nbranch) '_Rseg_' num2str(Rseg) '_Rsoma_' num2str(Rsoma)];

method = [];

CreateCellSubstrate(substrate_folder, filename_substrate, Ls, SD_Ls, Rseg, Rsoma, Nseg, SD_Nseg, Nbranch, SD_Nbranch, sphericity, Nspin, method);

ply_filename = fullfile(substrate_folder, [filename_substrate '_IS.ply']);
init_filename = fullfile(substrate_folder, [filename_substrate '_InitFile_IS.dat']);
tt = toc;
disp(['[DONE] - ' num2str(round(tt)) ' sec.'])

%% Create schemefiles for Camino Monte Carlo simulator

disp('3 - Creating Schemefiles for Camino Simulations')
tic
scheme_filename = 'schemefile';

% DDE acquisition parameters
B_DDE = [1000, 7500, 10000]; % B value of each single block in sec/mm2 - Note the total b value will be double
smalldel_DDE = 0.0045; % sec
delta_DDE = 0.030; % sec
TM = 0.0295; % sec
Npoints = 19;

% PGSE acquisition parameters
B_PGSE = [0.02, 0.5, 1.5, 3.02, 6.0, 10.0, 15.0, 20.0]; % ms/um2
smalldel_PGSE = 3.1 * 1E-3; % sec
delta_PGSE = 54.2 * 1E-3; % sec

Ndirections = 32; % Number of directions per b-shell

CreateCaminoSchemefile_DDE(scheme_folder, [scheme_filename '_DDE'], ...
    B_DDE, smalldel_DDE, delta_DDE, TM, Npoints, Ndirections);

CreateCaminoSchemefile_PGSE(scheme_folder, [scheme_filename '_PGSE'], ...
    B_PGSE, smalldel_PGSE, delta_PGSE, Ndirections);

schemefile_DDE = fullfile(scheme_folder, [scheme_filename '_DDE.scheme']);
schemefile_PGSE = fullfile(scheme_folder, [scheme_filename '_PGSE.scheme']);
tt = toc;
disp(['[DONE] - ' num2str(round(tt)) ' sec.'])

%% Run Camino Monte Carlo simulations

filename = 'cellmodel';
output_filename_DDE = fullfile(output_folder, [filename '_DDE.Bfloat']);
output_filename_PGSE = fullfile(output_folder, [filename '_PGSE.Bfloat']);
seed = 12345;

disp(['4 - Running camino simulations in cellmodel ' ply_filename ' with initialization file ' init_filename]);
tic
datasynth_path = 'src/camino_v2/bin/datasynth';
command_DDE = [datasynth_path ' -seed ' num2str(seed) ' -walkers ' num2str(Nspin) ' -tmax ' num2str(MCsteps) ' -p 0.0 -voxels 1 -voxelsizefrac 1.0 -initial file -initfile ' init_filename ' -diffusivity ' num2str(D) ' -substrate ply -plyfile ' ply_filename ' -schemefile  ' schemefile_DDE ' > ' output_filename_DDE];
system(command_DDE);
command_PGSE = [datasynth_path ' -seed ' num2str(seed) ' -walkers ' num2str(Nspin) ' -tmax ' num2str(MCsteps) ' -p 0.0 -voxels 1 -voxelsizefrac 1.0 -initial file -initfile ' init_filename ' -diffusivity ' num2str(D) ' -substrate ply -plyfile ' ply_filename ' -schemefile  ' schemefile_PGSE ' > ' output_filename_PGSE];
system(command_PGSE);
tt = toc;
disp(['[DONE] - ' num2str(round(tt)) ' sec.'])

%% Read signal

disp('5 - Reading and Plotting Simulated Signals');

tic
fid_DDE = fopen(output_filename_DDE, 'r', 'b');
tmp_DDE = fread(fid_DDE, 'float');
SS_DDE = reshape(tmp_DDE(1:end-1), [Npoints, Ndirections, length(B_DDE)])./Nspin; % The last measurement is a b=0 for normalizartion
Y_DDE = squeeze(mean(SS_DDE,2));
phi = linspace(0,pi,Npoints); % rad
X_DDE = phi(:).*180./pi; % degree

fid_PGSE = fopen(output_filename_PGSE, 'r', 'b');
tmp_PGSE = fread(fid_PGSE, 'float');
SS_PGSE = reshape(tmp_PGSE, [length(B_PGSE), Ndirections])./Nspin;
Y_PGSE = mean(SS_PGSE,2);

figure;
ax=gca;
subplot(2, 1, 1);
for i=1:length(B_DDE)
    plot(X_DDE, Y_DDE(:,i), '-', 'linewidth', 2.0, 'DisplayName', ['b-value = ' num2str(B_DDE(i))]);
    hold on;
end
axis([0 180 0 0.3]);
xlabel('Angle (deg)');
ylabel('DDE signal');
grid on;
legend;

subplot(2, 1, 2);
plot(B_PGSE, Y_PGSE, '-', 'linewidth', 2.0);
axis([0.02 20 0 1]);
xlabel('b-value (ms/um2)');
ylabel('PGSE signal');
grid on;

savefig([name_repo '/signals.fig']);

tt = toc;
disp(['[DONE] - ' num2str(round(tt)) ' sec.'])