function warpedim = warp_image( im1, Dx, Dy, flag_boundary )
% The Software is provided "as is", without warranty of any kind.
%
%==========================================================================
% Adapta��o, registro de imagens monocrom�ticas (1 channel)
% IN: im1 - imagem de entrada, a ser registrada
%     Dx,Dy - campos vetoriais que ditar�o a transforma��o da imagem
%
% OUT: warpedim - imagem transformada pelos vetores
%
% Borsoi, 24/02/2015
%==========================================================================
% Flag: boundary conditions - (0) zero padding (1) symmetric; (2) circular; (3) replicated

[h, w] = size(im1) ;

[uc, vc] = meshgrid( 1:w, 1:h ) ;

uc1 = uc + Dx ;
vc1 = vc + Dy ;

warpedim = zeros( size(im1) ) ;
tmp = zeros(h, w) ;


interp_method = 'linear';      % 'nearest' - nearest neighbor interpolation
                              % 'linear'  - bilinear interpolation ('bilinear')
                              % 'spline'  - spline interpolation
                              % 'cubic'   - bicubic interpolation as long as the data is
                              %            uniformly spaced, otherwise the same as 'spline'

switch flag_boundary
    case 0
        % Zero padding
        tmp = interp2(uc, vc, im1, uc1, vc1, interp_method, 0);
    case 1
        % Mirrors the input image
        im2 = [rot90(im1,2) flipud(im1) rot90(im1,2);...
               fliplr(im1)  im1         fliplr(im1);...
               rot90(im1,2) flipud(im1) rot90(im1,2)];
        % Indexes position of mirrored area
        [uc2, vc2] = meshgrid( -(w-1):2*w, -(h-1):2*h );
        % Interpolates
        tmp = interp2(uc2, vc2, im2, uc1, vc1, interp_method );
    case 2
        % Circular replication of input image
        im2 = [im1 im1 im1;...
               im1 im1 im1;...
               im1 im1 im1];
        % Indexes position of mirrored area
        [uc2, vc2] = meshgrid( -(w-1):2*w, -(h-1):2*h );
        % Interpolates
        tmp = interp2(uc2, vc2, im2, uc1, vc1, interp_method );
    case 3
        % Replicate the input image
        im2 = [im1(1,1)*ones(size(im1))    meshgrid(im1(1,:))   im1(1,end)*ones(size(im1));...
               meshgrid(im1(:,1))'         im1                  meshgrid(im1(:,end))';...
               im1(end,1)*ones(size(im1))  meshgrid(im1(end,:)) im1(end,end)*ones(size(im1))];
        % Indexes position of mirrored area
        [uc2, vc2] = meshgrid( -(w-1):2*w, -(h-1):2*h );
        % Interpolates
        tmp = interp2(uc2, vc2, im2, uc1, vc1, interp_method );
    otherwise
        disp('warp_image - Error: Invalid boundary flag selected! switching to zero padding')
end


% tmp(:) = interp2(uc, vc, im1, uc1(:), vc1(:), 'bilinear') ;
% if flag_boundary == 0
%     tmp = interp2(uc, vc, im1, uc1, vc1, 'bilinear', 0);
% else
%     tmp = interp2(uc, vc, im1, uc1, vc1, 'bilinear');%%%%%
% end

warpedim(:, :) = tmp ;
warpedim(isnan(warpedim))=0;%zero padding



