% =========================================================================
% 
% Performs super-resolution reconstruction (SRR) of electrical impedance
% tomography (EIT) images. 
% 
% It implements the method described in the following paper:
% 
% Reference:
%     Borsoi, R. A., Aya, J. C. C., Costa, G. H., and Bermudez, J. C. M. 
%     "Super-resolution reconstruction of electrical impedance tomography images."
%     Computers & Electrical Engineering, 69, pp. 1-13, 2018.
% 
% 
% The input just needs to contain the low resolution EIT images in EIDORS
% format (more details are contained in the "EIT_SRR" function help)
% 
% 
% =========================================================================

clear all
close all
warning off;
clc


% begining of the filenames of printed figures
scs_name = 'test';


% load Montreal data (available with EIDORS) and three reconstructions: NOSER, total variation and temproal solver
load('EIT_real_lung_images.mat')


% Choose the output of one algorithm ------------------
imgn_lr = real_lung_img_LR_NOSER;
% imgn_lr = real_lung_img_LR_TS;
% imgn_lr = real_lung_img_LR_TV;



% size of the HR images:
Nx = 200;
Ny = 200;

% perform the super-resolution
[srr_ims,MALHA,ImT] = EIT_SRR(imgn_lr,Nx,Ny);





%%
% Plot some images


% select the frames to print
imgs_to_print = [10 20];

mkdir('figures/')

for im_idx = imgs_to_print
    clear imagem_lr_show
    
   
    % Plot generated LR image ---------------------------------------------
    imagem_lr_show.coord.x  = ImT(im_idx).coord.x;
    imagem_lr_show.coord.y  = ImT(im_idx).coord.y;
    imagem_lr_show.cdata    = ImT(im_idx).coord.value_LR;

    figure, set(gca,'color','none'), set(gca,'visible','off')
    patch(imagem_lr_show.coord.x',imagem_lr_show.coord.y',...
         [imagem_lr_show.cdata  imagem_lr_show.cdata  imagem_lr_show.cdata]')
    axis equal % square, 
%     caxis([minval_tmp maxval_tmp])
    print(['figures/' scs_name '_LR_t',num2str(im_idx)], '-dpdf')
    
    
    
    % plot reconstruction  ------------------------------------------------
    figure, %set(gca,'color','none'), set(gca,'visible','off')
    imagesc(flipud(srr_ims{im_idx}))
    set(gca,'color','none'), set(gca,'visible','off')
    h = patch(MALHA.coord.x',MALHA.coord.y',...
         [MALHA.cdata  MALHA.cdata  MALHA.cdata]','FaceColor','none');
    rotate(h,[0,0,1],180)
%     axis equal % square
%     caxis([minval_tmp maxval_tmp])
    print(['figures/' scs_name '_SRR_t',num2str(im_idx)], '-dpdf')    
 
end










