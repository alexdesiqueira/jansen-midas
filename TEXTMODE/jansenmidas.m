%%  JANSENMIDAS.M
%%
%%  This file is part of the supplementary material to 'Jansen-MIDAS: a
%% multi-level photomicrograph segmentation software based on isotropic
%% undecimated wavelets'.
%%
%%  Author:
%% Alexandre Fioravante de Siqueira, siqueiraaf@gmail.com
%%
%%  Description: Jansen-MIDAS is a software developed to provide
%% Multi-Level Starlet Segmentation (MLSS) and Multi-Level Starlet
%% Optimal Segmentation (MLSOS) techniques. These methods are based on
%% the starlet transform, an isotropic undecimated wavelet, in order to
%% determine the location of objects in photomicrographs.
%% Using Jansen-MIDAS, a scientist can obtain a multi-level threshold
%% segmentation of his/hers photomicrographs.
%%
%%  Input: none (all input is asked during runtime).
%%
%%  Output: D, starlet detail levels.
%%          R, the MLSS segmentation levels.
%%          COMP, a color comparison between IMG and IMGGT.
%%          MCC, the Matthews correlation coefficient.
%%
%%  Other files required: binarize.m, confusionmatrix.m, mattewscc.m,
%% mlsos.m, mlss.m, mlssorigaux.m, mlssvaraux.m, starlet.m, twodimfilt.m
%%
%%  Version: april 2016.
%%
%%  Please cite:
%%
%% [1] de Siqueira, A.F. et al. Jansen-MIDAS: a multi-level photomicrograph
%% segmentation software based on isotropic undecimated wavelets, 2016.
%% [2] de Siqueira, A.F. et al. Estimating the concentration of gold
%% nanoparticles incorporated on Natural Rubber membranes using Multi-Level
%% Starlet Optimal Segmentation. Journal of Nanoparticle Research, 2014,
%% 16; 2809. doi: 10.1007/s11051-014-2809-0.
%% [3] de Siqueira, A.F. et al. An automatic method for segmentation
%% of fission tracks in epidote crystal photomicrographs. Computers and
%% Geosciences, 2014, 69; 55-61. doi: 10.1016/j.cageo.2014.04.008.
%% [4] de Siqueira, A.F. et al. Segmentation of scanning electron
%% microscopy images from natural rubber samples with gold nanoparticles
%% using starlet wavelets. Microscopy Research and Technique, 2014, 77(1);
%% 71-78. doi: 10.1002/jemt.22314.
%%
%% Jansen-MIDAS is free software: you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%

function [D,R,COMP,MCC] = jansenmidas()

%%% INTRODUCTION %%%
disp('');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('%%%%%%%%%%%%%%% Welcome to Jansen-MIDAS %%%%%%%%%%%%%%%%');
disp('%%%%%%%%%% Microscopic Data Analysis Software %%%%%%%%%%');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('');

%%% CHOOSING INITIAL AND LAST DETAIL LEVELS %%%
initL = input('Initial detail level to consider in segmentation: ');
if (isempty(initL) || ~isnumeric(initL))
    disp('Assuming default value, initial level equals 1. Continue...'); fflush(stdout);
    initL = 1;
end

L = input('Last detail level to consider in segmentation: ');
if (isempty(L) || ~isnumeric(L))
    disp('Assuming default value, last level equals 5. Continue...'); fflush(stdout);
    L = 5;
end

%%% OBTAINING ORIGINAL IMAGE %%%
IMGname = input('Please type the original image name: ','s'); 
IMG = imread(IMGname);

%%% CONVERTING RGB IMAGE TO GRAY %%%
if (length(size(IMG)) == 3)
    IMG = rgb2gray(IMG);
end

%%% APPLYING MLSS %%%
printf('Applying MLSS...\n'); fflush(stdout);
[D,R] = mlss(IMG,initL,L);

%%% APPLY MLSOS? %%%
GTapply = input('Do you want to apply MLSOS (uses GT image)? ','s'); 

if ((GTapply == 'Y') || (GTapply == 'y'))
    %%% OBTAINING GT AND ORIGINAL IMAGES %%%
    GTname = input('Please type a GT image name: ','s');
    GT = imread(GTname);

    %%% CONVERTING RGB IMAGE TO GRAY %%%
    if (length(size(GT)) == 3)
        IMG = rgb2gray(GT);
    end

    %%% APPLYING MLSOS %%%
    [COMP,MCC] = mlsos(R,GT,initL,L);
end

%%% SAVING OR SHOWING IMAGES %%%
SAV = input('Type Y to save images or any to show them: ','s');

if ((SAV == 'Y') || (SAV == 'y'))
    %%% SAVING D IMAGES %%%
    for i = 1:L
        printf('Saving detail image... Level: %d\n', i); fflush(stdout);
        imshow(D(:,:,i));
        print('-dtiff','-r300',strcat(IMGname,'-D',num2str(i),'.tif'));
    end

    %%% SAVING R IMAGES %%%
    for i = initL:L
        printf('Saving segmentation image... Level: %d\n', i); fflush(stdout);
        imshow(R(:,:,i));
        print('-dtiff','-r300',strcat(IMGname,'-R',num2str(i),'.tif'));
    end

    %%% SAVING COMP IMAGES %%%
    if ((GTapply == 'Y') || (GTapply == 'y'))
        for i = initL:L
            printf('Saving comparison image... Level: %d\n', i); fflush(stdout);
            imshow(COMP(:,:,:,i));
            print('-dtiff','-r300',strcat(IMGname,'-COMP',num2str(i),'.tif'));
        end
    end
else
    %%% SHOWING D IMAGES %%%
    for i = 1:L
        printf('Showing detail image... Level: %d\n', i); fflush(stdout);
        figure; imshow(D(:,:,i));
        title(strcat(IMGname,'-D',num2str(i)));
    end

    %%% SHOWING R IMAGES %%%
    for i = initL:L
        printf('Showing segmentation image... Level: %d\n', i); fflush(stdout);
        figure; imshow(R(:,:,i));
        title(strcat(IMGname,'-R',num2str(i)));
    end

    %%% SHOWING COMP IMAGES %%%
    if ((GTapply == 'Y') || (GTapply == 'y'))
        for i = initL:L
            printf('Showing comparison image... Level: %d\n', i); fflush(stdout);
            figure; imshow(COMP(:,:,:,i));
            title(strcat(IMGname,'-COMP',num2str(i)));
        end
    end
end

disp('End of processing. Thanks!');
