

function [srr_ims,MALHA,ImT]=EIT_SRR(imgn_lr,Nx,Ny)
% ---------------------------------------------------------------------------
% Performs super-resolution reconstruction (SRR) of electrical impedance
% tomography (EIT) images. 
% 
% Reference:
%     Borsoi, R. A., Aya, J. C. C., Costa, G. H., and Bermudez, J. C. M. 
%     "Super-resolution reconstruction of electrical impedance tomography images."
%     Computers & Electrical Engineering, 69, pp. 1-13, 2018.
% 
% INPUTS:
%         imgn_lr : structure containing the LR images in EIDORS format, 
%                   with fields:
%                   - fwd_model.elems: array containing the elements
%                   - imgn_lr.fwd_model.nodes: array with the nodes
%                   - imgn_lr.elem_data(:,t): electrodes * T array with voltage
%                                             measurements for each time instant
%         Nx, Ny  : width/height of the IHR/HR image in pixels
% 
% OUTPUTS:
%         srr_ims : cell array containing the super-resolved images, in an uniform grid 
%         MALHA   : structure containing data used for plotting the images
%         ImT     : structure containing the low-resolution images
% ---------------------------------------------------------------------------


% add registration algorithm to path
addpath(genpath('hs'));


% ---------------------------------------------------------------------------
% convert to new format

% number of frames
% T = size(imgn_lr.elem_data,2);
[~,T] = size(imgn_lr.elem_data);

% Load HR images   
for t=1:T
    imagens_reais(t).faces      = [];
    imagens_reais(t).vertices   = [];
    imagens_reais(t).cdata      = [];
    imagens_reais(t).faceColor  = [];
    imagens_reais(t).HR_uniform = [];
end

% Convert  LR images
for t=1:T
    imagens_eit(t).faces     = imgn_lr.fwd_model.elems;
    imagens_eit(t).vertices  = imgn_lr.fwd_model.nodes;
    imagens_eit(t).cdata_LR  = imgn_lr.elem_data(:,t);
    imagens_eit(t).faceColor = 'flat';
end

% Remove color from the elements face in order to plot only the mesh grid
for t=1:length(imagens_eit)
    imagens_eit(t).faceColor = 'none';
end

% Images are NOT registered beforehand:
UV = []; 
imagensRegistradas = false;





% ---------------------------------------------------------------------------
% Apply pre-processing

%==========================================================================
%                                                                         %
%============================== OPTIONS ===================================
%                                                                         %

% Normalize the LR images to the [0,255] range?
normalizarImagens = 0; % 1 --> yes  | 0 --> no


%==========================================================================
%                                                                         %
%========================= CONVERT THE IMAGES =============================
%                                                                         %
% originail data:
% im.cdata   : conductivity value in the elements corresponding to the vector indexes
% im.faces   : each line contains 3 indexes of the vertices that compose a given element
% im.vertices: coordinates of all existing vertices in the mesh

% Converts the LR images to the format:   element #; x1,2,3; x1,2,3; value 
[imagens_reais,ImT] = converteCordenadas(imagens_reais,imagens_eit);

%==========================================================================
%                                                                         %
%======== CREATES AUXILIARY MATRICES WITH PIXEL POSITIONS =================
%                                                                         %
% Creates auxiliary matrices with the (x,y) positions corresponding to the
% pixels in the uniform grid

[ImAux] = criaMatrizesAux_comPosicao_dosPixels(ImT(1).coord, Nx, Ny);


%==========================================================================
%                                                                         %
%================= CRIA IMAGENS EM GRADE UNIFORME (IHR) ===================
%                                                                         %
% Returns the EIT images resampled to the uniform (IHR) grid
[ImT,imagens_reais,MascaraTemp] = reamostraTIE_uniforme(ImT,imagens_reais,normalizarImagens,Nx,Ny,ImAux);


% throw all images into a single cell array:
for t=1:length(ImT)
    ImT(t).imagem{1} = ImT(t).imagem_LR;
end




%
%==========================================================================
%                                                                         %
%============= PERFORMS SUPER RESOLUTION WITH LMS-SRR-EIT =================
%                                                                         %

% LMS-SRR parameters
K  = 100;
mu = 0.01;
kernel = fspecial('gaussian',60,20);
utilizarPonderacao = 0; % do not weight the error according to the domain


estimate_motion = 1;
alg_index = 1;
[erro,X_rec] = LMS_EIT_naoMatricial6(ImT,K,mu,Nx,Ny,kernel,ImAux,MascaraTemp,...
                                    utilizarPonderacao,imagens_reais,UV,estimate_motion,alg_index);

% attribute reconstructed image
srr_ims = X_rec;





% compute a structure used for ploting the FEM over the images

[num_measurents,~] = size(ImT(1).coord.x);

% instantiate mesh
clear MALHA
MALHA.coord.x = ImT(1).coord.x;
MALHA.coord.y = ImT(1).coord.y;
MALHA.cdata   = zeros(num_measurents,1);
% Soma valor para deslocar o centro da malha do zero, deixando-a no primeiro quadrante
MALHA.coord.x = MALHA.coord.x + max(MALHA.coord.x(:)) + (2/Nx); %+ max(max(MALHA.coord.x))*ones(length(MALHA.coord.x),3) + (1/Nx);
MALHA.coord.y = MALHA.coord.y + max(MALHA.coord.y(:)) + (2/Ny);
% Muda a escala da malha para ficar do mesmo tamanho do que a imagem
MALHA.coord.x = MALHA.coord.x*(Nx-(1))/max(MALHA.coord.x(:));
MALHA.coord.y = MALHA.coord.y*(Ny-(1))/max(MALHA.coord.y(:));





