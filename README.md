# Virtual Cell Generator v1.0 
This is a basic implementation of a generative model for virtual neuron-like cells described in more details in Palombo M. et al. PNAS 2016 (https://doi-org.cardiff.idm.oclc.org/10.1073/pnas.1504327113) and Palombo M. et al. Neuorimage 2019 (https://doi.org/10.1016/j.neuroimage.2018.12.025). If you use this code, please cite our related works (see Citation section below). <img align="right" src="https://github.com/palombom/Virtual-Cell-Generator-v1.0/blob/main/VirtualCellGenerator.png"> 

For queries or suggestions on how to improve this repository, please email: palombom@cardiff.ac.uk 

## Dependencies
To use the Cell Generator you will need a MATLAB distribution. Additionally, you will also need some external repositories:
* MISST Toolbox from http://mig.cs.ucl.ac.uk/index.php?n=Tutorial.MISST (included in this repository)
* TREES Toolbox from https://www.treestoolbox.org/ (included in this repository)
* A modified version of Camino, included in this repository and modified from the original one at: http://camino.cs.ucl.ac.uk/ (included in this repository).
* The LIBIGL library from https://libigl.github.io/ (not included in this repository). 

## Download 
To get the Virtual Cell Generator clone this repository. The tools include all the necessary dependencies and should be ready for you to run.

If you use Linux or MacOS:

1. Open a terminal;
2. Navigate to your destination folder;
3. Clone Virtual Cell Generator:
```
$ git clone https://github.com/palombom/Virtual-Cell-Generator-v1.0.git 
```
4. Unzip the "src.zip" file inside the "Virtual-Cell-Generator-v1.0" folder.
5. Add the "Virtual-Cell-Generator-v1.0" folder and subfolders to your Matlab path list.
6. You should now be able to use the code. 

## Usage
The function "**CreateCellSubstrate**" represents the core of the toolbox. It generates virtual substrates (3D surface meshes and corresponding SWC file) of neuron-like structure with pre-defined morphological characteristics. The inputs are: 

- substrate_folder: folder where the generated cellular digital substrate will be stored;
- filename_substrate: the filename of the cellular digital substrate;
- Ls: mean length of cellular projections in microns;
- SD_Ls: standard deviation of length of cellular projections in microns;
- Rseg: radius of cellular projections in microns;
- Rsoma: radius of soma in microns;
- Nseg: mean number of primary projections radiating from the soma (integer number);
- SD_Nseg: standard deviation of primary projections radiating from the soma (integer number);
- Nbranch: mean number of consecutive embranchments of cellular projections (integer number);
- SD_Nbranch: standard deviation of number of consecutive embranchments of cellular projections (integer number);
- sphericity: the sphericity factor of the soma: a fractional number between 0.01 and 0.99, where 0.99 is a perfect sphere while 0.01 is a deformed surface wrapping around the pcellular projections radiating from the soma.
- Nspin: number of spins to initialize inside the substrate; useful for follow up Monte Carlo simulations.
- method: can be 'random' or 'uniform', and defines the way the main cellular projections radiating from the soma are oriented in the space. 'random' randomly samples Nseg directions from the unitary sphere; while 'uniform' defines directions using the uniform point ditribution on the unitary sphere using electrostatic repulsion. 

The function "**main_simulations**" shows an example of how to use "CreateCellSubstrate" to generate a virtual substrate and perform diffusion MRI simulations using single diffusion encoding (SDE) and double diffusion encoding (DDE) schemes via Monte Carlo simulations using Camino. You can find an example of the "**parameters_simulations.txt**" in this repository, which defines the initialization parameters for the simulation. 
However, you can use the generated substrates also with other Monte Carlo simulators of diffusion MRI signals, such as Disimpy (https://disimpy.readthedocs.io/en/latest/tutorial.html) or MCDC (https://github.com/jonhrafe/MCDC_Simulator_public). 

**NOTE**: the 3D surface meshes generated are simplified meshes, using the minimum number of triangles per cell feature so to keep the computational cost of the Monte Carlo simulation the lowest possible. However, for more accurate 3D meshes, we recommend to use Blender (available at https://www.blender.org/download/releases/) and the SWC_mesher add-ons (available at https://github.com/kdrsimsek for both Blender version 3.X and 4.X).

## Citation
If you use this Virtual Cell Generator, please remember to cite our main works:

1. Palombo Marco, Clémence Ligneul, Chloé Najac, Juliette Le Douce, Julien Flament, Carole Escartin, Philippe Hantraye, Emmanuel Brouillet, Gilles Bonvento, and Julien Valette. "New paradigm to assess brain cell morphology by diffusion-weighted MR spectroscopy in vivo." Proceedings of the National Academy of Sciences 113, no 24 (2016): 6671-6676.

2. Palombo Marco, Daniel C. Alexander, and Hui Zhang. "A generative model of realistic brain cells with application to numerical simulation of the diffusion-weighted MR signal." NeuroImage 188 (2019): 391-402.

## License
Virtual Cell Generator v1.0 is distributed under the BSD 2-Clause License (https://github.com/palombom/Virtual-Cell-Generator-v1.0/blob/main/LICENSE), Copyright (c) 2019 Cardiff University and University College London. All rights reserved.

**The use of the Virtual Cell Generator v1.0 MUST also comply with the individual licenses of all of its dependencies.**

## Acknowledgements
The development of the Virtual Cell Generator was supported by EPSRC (EP/G007748, EP/I027084/01, EP/L022680/1, EP/M020533/1, EP/N018702/1, EP/M507970/1) and European Research Council (ERC) under the European Union’s Horizon 2020 research and innovation programme (Starting Grant, agreement No. 679058). Dr. Marco Palombo is currently supported by the UKRI Future Leaders Fellowship MR/T020296/2.
