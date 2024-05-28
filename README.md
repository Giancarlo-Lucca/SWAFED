# Sliding Window based Adaptative Fuzzy measure for Edge Detection (SWAFED)

This repository contains all the code and and supplementary materials for the paper entitled "Sliding window based adaptative fuzzy measure for edge detection". The original work was submitted to the Journal Expert Systems.

authored by

Cedric Marco-Detchart, Giancarlo Lucca, Miquéias Amorim Santos Silva, Jaime A. Rincon, Vicente Julian, and Graçaliz Dimuro

Corresponding author: Cedric Marco-Detchart (cedmarde@upv.es)

--------------------------------------------------------------------------------


## Source code

**Prerequisites**: The KITT (Kermit Image Toolkit) collection is needed for this project to work. The folders needed are loaded in **"setup.m"** file, where paths can be configured. Please download the files from [KITT repository](https://github.com/giaracvi/KITT).

To execute the experiment, run the file **"superLauncher.m"** where the OS (win, mac, linux) must be chosen in order to build the correct path syntax.

The parameters configuration is located in the file **"infoMaker.m"**. The source and data paths must also be configured according to your folders location.

Each one of the phases of the experiment is located in one file, as follows:

- **"smMaker.m"** contains the procedure to apply a smoothing technique to an image, taking all the parameters from configuration file.

- **"ftMaker.m"** is responsible for extracting the feature images based on given parameters.

- **"bdryMaker.m"** takes a feature image and extracts boundary image so that they can be compared to ground truth.

- **"cpMaker.m"** computes the comparison of a boundary image with its ground truth giving statistical results (Prec, Rec and F_0.5 measure).

- **"cpCollecter.m"** takes individual statistical results and collects them all in order to have a global result of the dataset

- **"aioMaker.m"** contains all of the instructions of the previous files in one script.

- **"README.md"** this file.


## Citation

If you use this code and/or article in your research, please cite as:

