%%  STARLET.M
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
%%  Authors:
%% Alexandre Fioravante de Siqueira, siqueiraaf@gmail.com
%% Aylton Pagamisse, aylton@fct.unesp.br
%%
%%  Description: STARLET applies the starlet wavelet on the input image
%% IMG, with L decomposition levels, returning the approximation levels
%% S and the wavelet detail coefficients D.
%%
%%  Input: IMG, a gray input image.
%%         L, last desired decomposition level.
%%
%%  Output: S, starlet approximation levels.
%%          D, starlet detail levels.
%%
%%  Other files required: jansenmidas.m, binarize.m, confusionmatrix.m, 
%% mattewscc.m, mlsos.m, mlss.m, mlssorigaux.m, mlssvaraux.m, twodimfilt.m
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

function [S,D] = starlet(IMG,L)

%%% PRELIMINAR VARS %%%
h = [1 4 6 4 1]; % 1D-h filter
IMG = double(IMG);
[M,N] = size(IMG); % image info
% resulting vectors: approximation and details
S = zeros(M,N,L); D = zeros(M,N,L);

%%% MIRRORING CRITERIA: LOWER PIXEL NUMBER %%%
if M < N
    T = M;
else
    T = N;
end

auxS = padarray(IMG,[T T],'symmetric'); % mirroring

%%% STARLET APLICATION %%%
for i = 1:L
    prevIMG = auxS; % previous level image
    h2 = twodimfilt(h,i-1); % building 2D-h filter

    %%% WAVELET COEFFICIENTS %%%
    auxS = conv2(prevIMG,h2,'same'); % approximation coefficients
    auxD = prevIMG - auxS; % detail coefficients

    S(:,:,i) = auxS(T+1:M+T,T+1:N+T); % mirroring correction
    D(:,:,i) = auxD(T+1:M+T,T+1:N+T);
end
