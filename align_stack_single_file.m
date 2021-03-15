function  align_stack_single_file(files_to_align,pixel_size,varargin)

p = mbparse.ExtendedInput();
p.addParamValue('min_tilt',-60);     
p.addParamValue('max_tilt',60);    
p.addParamValue('tilt_axis',85);
q = p.getParsedResults(varargin{:});

%#########################################################################
%
%  Align tomograms using AreTomo 
%
%#########################################################################

%Software for fiducialess alignment 
aretomo = '/frost/hotbox/melo/programs/AreTomo/AreTomo-05-07-2020/AreTomo-05-07-2020-Cuda92';

       disp(['Performing alignment for stacks.']);
       
%Input files
            input_file=([files_to_align]);
            [~, f,ext] = fileparts(files_to_align);
            output_file=strcat(f,'_aligned',ext);
            output_tilt_file=strcat(f,'_aligned.tlt');

%Check if input and output files exist
            disp(['Using AreTomo to align tiltseries ' files_to_align ' !!!' ])

%Run AreTOMO
            system([aretomo ' -InMRC ' input_file ' -OutMrc ' output_file ' -PixSize ' num2str(pixel_size) ' -VolZ 0 -TiltRange 'num2str(q.min_tilt) num2str(q.max_tilt) ' -TiltAxis 'num2str(q.tilt_axis) >> ' files_to_align '.log']);

%Generate .tlt file from .aln file
            
            filename = strcat(f,'.aln');
            startRow = 3;
            fileID = fopen(filename,'r');
            formatSpec = '%5f%11f%11f%11f%11f%9f%9f%9f%9f%f%[^\n\r]';
            dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
            fclose(fileID);
            aln_parameters = table(dataArray{1:end-1}, 'VariableNames', {'SEC','ROT','GMAG','TX','TY','SMEAN','SFIT','SCALE','BASE','TILT'});
            clearvars filename startRow formatSpec fileID dataArray ans;
            tilt_file=aln_parameters.TILT;
            filename_tilt= output_tilt_file;
            fileID = fopen(filename_tilt,'w');
            formatSpec = '%4.2f\n';
            fprintf(fileID,formatSpec,tilt_file);
            fclose(fileID);
            clearvars formatSpec fileID;    

disp(['Aligned files exist. Continue to tomogram reconstruction']);
