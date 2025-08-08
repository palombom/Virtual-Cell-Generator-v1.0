function CreateCellSubstrate(substrate_folder, substrate_filename, Ls, SD_Ls, Rseg, Rsoma, Nseg, SD_Nseg, Nbranch, SD_Nbranch, sphericity, Nspin, method)

    Ncells = 1;
    volumes = cell(Ncells,1);
    
    if isempty(method), method = 'uniform'; end % By default, the cellular projections are arranged uniformely over the sphere for Nseg>=10 using the electrostatic repulsion. For less, they are arranged randomly because it is impossible to distribute uniformely on 9 points on the sphere using the electrostatic repulsion. 

    if Nseg <= 9
        method = 'random';
    else
        method = 'uniform';
    end
    
    Lseff = round(Ls + Rsoma);
    random_seed = 123;
    filename = fullfile(substrate_folder, substrate_filename);
    volumes{1} = substrate_generator(filename, Nspin, method, Nseg, SD_Nseg, Lseff, SD_Ls, Nbranch, SD_Nbranch, Rsoma, Rseg, random_seed, sphericity);
    
    save(fullfile(substrate_folder, [substrate_filename '_volumes.mat']), 'volumes');

    %disp(fullfile(substrate_folder, [substrate_filename '_substrates_characteristics.dat']))

    fid = fopen(fullfile(substrate_folder, [substrate_filename '_substrates_characteristics.dat']), 'w');
    fprintf(fid,'Nseg\t Lseg\t Nbranch\t Rseg_th\t min_Rseg\t max_Rseg\t Rsoma_th\t min_Rsoma\t max_Rsoma\t fsoma_th\t fsoma_eff\t Vsoma_eff\t Vtot_cell\n');

    Vs = 4 / 3 * pi * (Rsoma)^3;
    Vb = (Nseg+1) * (2^Nbranch-1) * Ls * pi * Rseg^2;
    fs = Vs/(Vs + Vb);
    total_volume = (volumes{1}.soma_volume + volumes{1}.tot_branch_volume + volumes{1}.tot_Y_junction_volume);
    fs_eff = volumes{1}.soma_volume ./ total_volume;

    [rmin_soma, rmax_soma, rmin_seg, rmax_seg] = explore_cellmodel_sizes(filename);        
    disp(['    Mean Nseg = ' num2str(Nseg)])
    disp(['    Mean Ls = ' num2str(Ls)])
    disp(['    Mean Nbranch = ' num2str(Nbranch)])
    disp(['    Nominal Rseg = ' num2str(Rseg)])
    disp(['    Effective minimum Rseg = ' num2str(rmin_seg)])
    disp(['    Effective maximum Rseg = ' num2str(rmax_seg)])
    disp(['    Nominal Rsoma = ' num2str(Rsoma)])
    disp(['    Effective minimum Rsoma = ' num2str(rmin_soma)])
    disp(['    Effective maximum Rsoma = ' num2str(rmax_soma)])
    disp(['    Nominal fsoma = ' num2str(fs)])
    disp(['    Effective fsoma = ' num2str(fs_eff)])
    disp(['    Soma Volume = ' num2str(volumes{1}.soma_volume)])
    disp(['    Total Cell Volume = ' num2str(total_volume)])

    fprintf(fid,'%d\t %d\t %d\t %2.3g\t %2.3g\t %2.3g\t %2.3g\t %2.3g\t %2.3g\t %2.2g\t %2.2g\t %2.3g\t %2.3g\n', Nseg, Ls, Nbranch, Rseg, rmin_seg, rmax_seg, Rsoma, rmin_soma, rmax_soma, fs, fs_eff, volumes{1}.soma_volume, total_volume);

    fclose(fid);

end

function singlecell_volumes = substrate_generator(filename, Nspin, method, Nseg, SD_Nseg, Ls, SD_Ls, Nbranch, SD_Nbranch, Rsoma, Rseg, random_seed, sphericity)

    singlecell_volumes = struct;

    [~,~,~, singlecell_volumes.soma_volume, singlecell_volumes.tot_branch_volume, singlecell_volumes.tot_Y_junction_volume] = test_meshing_graph_ComplexGeometries6(filename, method, Nseg, SD_Nseg, Ls, SD_Ls, Nbranch, SD_Nbranch, 60, Rsoma*2, 0, 1, Rseg*2, 1, random_seed, sphericity);
    volume_fraction = singlecell_volumes.soma_volume ./ (singlecell_volumes.soma_volume + singlecell_volumes.tot_branch_volume + singlecell_volumes.tot_Y_junction_volume);
    
    initializeSpins_INSIDE_Volume_from_SWCPLY(filename, [filename '.ply'], Nspin, volume_fraction, Rsoma, 0.9);
end