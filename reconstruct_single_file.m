function  reconstruct_single_file(file_to_reconstruct,varargin)

p = mbparse.ExtendedInput();
p.addParamValue('reconstruct',1);     
p.addParamValue('bin_factor',3);    
p.addParamValue('thickness',600);
p.addParamValue('SIRTite',10);
q = p.getParsedResults(varargin{:});


%#########################################################################
%
% Reconstruct tomograms using IMOD tilt 
%
%#########################################################################

%IMOD scripts path
tilt = '/programs/x86_64-linux/system/sbgrid_bin/tilt'; %For tomo reconstruction
binvol='/programs/x86_64-linux/system/sbgrid_bin/binvol'; %For binning the aligned stack
clip='/programs/x86_64-linux/system/sbgrid_bin/clip'; %For rotating tomo along X

%try
%    getTS_num(prefix,suffix);
%catch
%    disp('Input error for reconstruction.');
%    return
%end



%Input files
[folder,filename,ext]=fileparts(file_to_reconstruct);
tiltseries=filename;
%tilt_file=strcat(filename,'.tlt');

if q.reconstruct == 1
    
    %aligned_ts=dir([tiltseries '_aligned.mrc']);
    
    if isempty(tiltseries)
        disp(['File ' tiltseries ' does not exist.']);
    else
            if q.bin_factor > 1 
                                          
                input_file=(file_to_reconstruct);
                binned_file=([tiltseries '_bin' num2str(q.bin_factor) '.mrc']);
                output_file=([tiltseries '_reconstruction_bin' num2str(q.bin_factor) '_not_flipped.mrc']);
                flipped_file=([tiltseries '_reconstruction_bin' num2str(q.bin_factor) '.mrc']);

                %if ~exist(binned_file,"file")

                %Create binned version of stacks
                disp(['Creating binned version by a factor of ' num2str(q.bin_factor) '!!!']); 
                system([binvol ' -x ' num2str(q.bin_factor) ' -y ' num2str(q.bin_factor) ' -z 1  ' input_file ' ' binned_file]);

                %end

                    disp(['###  ' output_file ' exist. Doing tomogram reconstruction with ' output_file '. ###']);

                    tilt_file=([tiltseries '.tlt']);

                    disp(['Using tilt to reconstruct aligned tiltseries ' input_file ' !!!' ])

                    system([tilt ' -tiltfile ' tilt_file ' -FalloffIsTrueSigma 1 -XAXISTILT 0 -AdjustOrigin 1 -SUBSETSTART 0,0 -THICKNESS ' num2str(q.thickness) ...
                    ' -SCALE 0,0.034 -FakeSIRTiterations ' num2str(q.SIRTite) ' -UseGPU 0 -RADIAL 0.35,0.035 -input ' binned_file ' -output ' output_file ' >> ' tiltseries '.log']);
                    
                    system([clip ' rotx ' output_file ' ' flipped_file]); %Flipping file
                    
                    delete(output_file); 
            
            else
                input_file=file_to_reconstruct;
                tilt_file=([tiltseries '.tlt']);
                output_file=([tiltseries '_reconstruction_unbinned_not_flipped.mrc']);
                flipped_file=([tiltseries '_reconstruction_unbinned.mrc']);

                disp(['Using tilt to reconstruct aligned tiltseries ' input_file ' !!!' ])
                system([tilt ' -tiltfile ' tilt_file ' -FalloffIsTrueSigma 1 -XAXISTILT 0 -AdjustOrigin 1 -SUBSETSTART 0,0 -THICKNESS ' num2str(q.thickness) ' -SCALE 0,0.034 -FakeSIRTiterations ' num2str(q.SIRTite) ' -UseGPU 1 -RADIAL 0.35,0.035 -input ' input_file ' -output ' output_file ]);
                system([clip ' rotx ' output_file ' ' flipped_file]); %Flipping file
                delete(output_file);
            end
    end
end
