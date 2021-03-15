# tomogram_preprocessing

Download proper software, packages and scripts
1.Motion correction - Do it in Relion, Scipion or any other software. Do not use DW. 

2.Creating  stacks from motioncor2 files,  *ali.mrc

      This script will run inside the folder containing motion corrected  "*ali.mrc" micrographs from scipion, relion or any other software. In order to correctly use  this script, files should be labeled as follow:
               
             Prefix_TSNumber_MicNumber_TiltAngle_Suffix
       
       	Example: amelo_20200819_19_0012_33.0_aligned_mic.mrc
       			where Prefix = amelo_20200819_
             		TSNumber = 19
             		MicNumber = 0012
             		TiltAngle = 33.0
             		Suffix = _aligned_mic.mrc
       
      With this script it won't matter how many micrographs are in the folder. For better organization, I would recommend to create a softlink of ".mrc" files and then work in that folder.  

      %This script will separate the micrographs according to the TSNumber, count how many micrograph each tiltseries has, organize the micrographs from lowest angle to the highest angle, e.g. from -60 to +60, and output the file list for creating the stack using %IMOD's newstack. It will also output if your stacks are incomplete, complete or have more micrographs than they should have. 

      % function create_tiltseriesWrapper(prefix,suffix,min_angle,max_angle,increment);
      % Example:
      create_tiltseriesWrapper('amelo_20200819_','_aligned_mic.mrc',-60,60,3);

3.Perform dose-weighting

4.Align tilt series using AreTomo. You can also use eTomo or EMAN, however the workflow will be different

      %Add the script align_stack_single_file.m to your matlab path using the following command. 
          addpath('<matlab_scripts_path>')
          aretomo='<aretomo_path>';

      %Then run:
      % align_stack_single_file(files_to_align,pixel_size)
      % Example:
      align_stack_single_file('ts_01_DW.mrc','2.34');


5.Reconstruct Dose Weighted-Aligned tilt-series

      reconstruct_single_file_v1('<aligned_file>','reconstruct','bin_factor','thickness');
      Example: 
      reconstruct_single_file('ts_01_DW_aligned.mrc','reconstruct',1,'bin_factor',2,'thickness',300);
