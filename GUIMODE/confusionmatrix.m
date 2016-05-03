%%  CONFUSIONMATRIX.M
%%
%%  This file is part of the supplementary material to 'Jansen-MIDAS: a
%% multi-level photomicrograph segmentation software based on isotropic
%% undecimated wavelets'.
%%
%%  Jansen-MIDAS is a software developed to provide Multi-Level Starlet
%% Segmentation (MLSS) and Multi-Level Starlet Optimal Segmentation
%% (MLSOS) techniques. These methods are based on the starlet transform,
%% an isotropic undecimated wavelet, in order to determine the location
%% of objects in photomicrographs. Using Jansen-MIDAS, a scientist can
%% obtain a multi-level threshold segmentation of his/hers
%% photomicrographs.
%%
%%  Author:
%% Alexandre Fioravante de Siqueira, siqueiraaf@gmail.com
%%
%%  Description: CONFUSIONMATRIX uses the binary image BIN and the ground
%% truth IMGGT to generate the confusion matrix CFPixel and the
%% color-pixel comparison between BIN and IMGGT, COMP.
%%
%%  Input: BIN, a binary image.
%%         IMGGT, the ground truth corresponding to IMG.
%%
%%  Output: CFPixel, quantities of TP, TN, FP, and FN.
%%          COMP, a color comparison between BIN and IMGGT.
%%
%%  Other files required: jansenmidas.m, binarize.m, mattewscc.m, mlsos.m,
%% mlss.m, mlssorigaux.m, mlssvaraux.m, starlet.m, twodimfilt.m
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

function [CFPixel,COMP] = confusionmatrix(BIN,IMGGT)

%%% PRELIMINAR VARS AND PIXEL QUANTITY %%%
[M,N] = size(IMGGT);
%% FP, TP, FN, TN: 1st, 2nd, 3rd, 4th.
CFMatrix = zeros(M,N,4); CFPixel = zeros(1,4);
COMP = zeros(M,N,3);

for i = 1:M
    for j = 1:N
        if ((IMGGT(i,j) == 0) && (BIN(i,j) ~= 0)) %% False Positive pixel
            CFMatrix(i,j,1) = 255;
            CFPixel(1) = CFPixel(1) +1;
        elseif ((IMGGT(i,j) ~= 0) && (BIN(i,j) ~= 0)) %% True Positive pixel
            CFMatrix(i,j,2) = 255;
            CFPixel(2) = CFPixel(2) +1;
        elseif ((IMGGT(i,j) ~= 0) && (BIN(i,j) == 0)) %% False Negative pixel
            CFMatrix(i,j,3) = 255;
            CFPixel(3) = CFPixel(3) +1;
        else %% True Negative pixel
            CFMatrix(i,j,4) = 255;
            CFPixel(4) = CFPixel(4) +1;
        end
    end
end

%%% GENERATING COLOR COMPARISON IMAGE %%%
for i = 1:3 %% red = FP; green = TP; blue = FN
    COMP(:,:,i) = CFMatrix(:,:,i);
end
