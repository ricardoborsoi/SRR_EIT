function [erro, X_out] = LMS_EIT_naoMatricial6(ImT,K,mu,Nx,Ny,kernel,ImAux,MascaraTemp,...
                                    utilizarPonderacao,imagens_reais,UV,estimate_motion,alg_index)
%==========================================================================
% Implements the LMS-SRR algoritm for EIT image super resolution
%
%
% IN: ImT   : Low-resolution tomographic images
%     K     : number of iterations for the R-LMS algorithm for each time instant
%     mu    : LMS algorithm step size
%     Nx,Ny : spatial dimensins of the LR/IHR images (in pixels)
%     kernel: blurring kernel (used for deconvolution)
%     ImAux : auxiliary image used to perform the non-uniform up/down-sampling
%     MascaraTemp        : indicator function containing values of '1' in the EIT domain
%     utilizarPonderacao : flag, set to '1' to give zero weights to the error 
%                          outside the EIT image domain
%     imagens_reais      : real images (used to compute the error)
%     UV                 : optical flow fields, set to "[]" to use a registration algorithm
%     imagensRegistradas : flag, set to '1' if the IHR images are registered
%                          beforehand, and '0' otherwise
%
% OUT: X    : cell array with the reconstructed image sequence 
%      erro : array containing the mean-squared error evolution per iteration
%             (only computed when the real image is available)
%==========================================================================

% Initializes the mean squared error vector
erro = zeros(1,length(ImT)*K);
l=0;


if alg_index ~= 1   &&   alg_index ~= 2   &&   alg_index ~= 3
    error('Wrong algorithm index!!')
end
% Inicializa a imagem com zeros
X = zeros(Ny, Nx);





fprintf('\n\n')
for t=1:length(ImT)
    fprintf('Processing frame %d \n',t)
    for k=1:K
        % Initialize image
        xt1 = X;
        
        % Applies uniform and nonuniform ("triangular") blurring
        % H_d H_b
        xt1 = imfilter(xt1,kernel,'symmetric','same');
%         xt1 = imfilter(xt1,kernel,'same');
        xt1 = AplicaBlurDTri(xt1,ImT,t,ImAux);
        
        % Apply mask if necessary
        if utilizarPonderacao == 1
            xt1 = MascaraTemp.*xt1;
        end
        
        
        % ( y_d(t) - xt1(t) )
        xt1 = ImT(t).imagem{alg_index} - xt1;
        
        
        % Apply mask if necessary
        if utilizarPonderacao == 1
            xt1 = MascaraTemp.*xt1; % W_o*(LR - D*H*x)
        end
        
        
        % Applies transposed uniform and nonuniform ("triangular") blurring
        % H_b' H_d'
        xt1 = AplicaBlurDTri(xt1,ImT,t,ImAux);
        xt1 = imfilter(xt1,kernel,'symmetric','same');
%         xt1 = imfilter(xt1,kernel,'same');
        
        
        


        %------------------------------------------------------------------
        % Apply Tikhonov regularization (currently not being used)
        %------------------------------------------------------------------
%         H_reg             = [1];
        H_reg             = fspecial('laplacian');
        alpha_lms_reg     = 0; % use unregularized LMS
        flag_imfilter_reg = 'circular';
        regul_lms_kf_tknv = 0;
        
        % S'S
        regul_lms_kf_tknv = imfilter(X, H_reg, flag_imfilter_reg, 'same');
        regul_lms_kf_tknv = imfilter(regul_lms_kf_tknv(end:-1:1, end:-1:1), H_reg, flag_imfilter_reg, 'same');
        regul_lms_kf_tknv = regul_lms_kf_tknv(end:-1:1, end:-1:1);
        

        
               
        %------------------------------------------------------------------
        % Computes mean squared error if the HR images are available
        %------------------------------------------------------------------
        l = l+1;
        if sum(size( imagens_reais(t).HR_uniform )) ~= 0 
            erro(l) = sum(sum( ( MascaraTemp.*X - MascaraTemp.*imagens_reais(t).imagem   ).^2 )) ;
        else
            erro(l) = 0;
        end
%         disp(l);
 
        %------------------------------------------------------------------
        % update the reconstructed image
        X = X + mu * xt1   -   mu * alpha_lms_reg * regul_lms_kf_tknv;
        
    end
    
    % Store output image
    X_out{t} = X;
    
    
    
    % Realiza o registro da imagem antes do proximo instante de tempo
    % Necess�rio aplicas a transforma��o que leva do instante t (atual) pro
    % instante t+1, onde ser� comparada � imagem LR de t+1 (reg(I2,I1))
    
    % Registro da imagem HR com matriz G, x(t+1) = G(t+1)x(t)
    if t < length(ImT)
        % Known motion
        if estimate_motion == 0 && sum(size(UV)) ~= 0
%             vx = imresize(UV(t+1).vx,size(X),'bilinear');
%             vy = imresize(UV(t+1).vy,size(X),'bilinear');
            vx = UV(t+1).vx;
            vy = UV(t+1).vy;
        
        else % Estimate motion
            
%             uv = estimate_flow_hs(ImT(t+1).imagem, ImT(t).imagem,'pyramid_levels',4,'lambda',100);
            uv = estimate_flow_hs(ImT(t+1).imagem{alg_index}, ImT(t).imagem{alg_index},'pyramid_levels',4,'lambda',1e6); % 1e5 -- 1e15
%             uv = estimate_flow_hs(imagens_reais(t+1).imagem{alg_index}, imagens_reais(t).imagem{alg_index},'pyramid_levels',3,'lambda',1e5);

            vx = uv(:,:,1);
            vy = uv(:,:,2);
            
            % use the following to force global translational motion
%             vx = ones(size(uv(:,:,1))) * mean(mean( uv(:,:,1) ));
%             vy = ones(size(uv(:,:,2))) * mean(mean( uv(:,:,2) ));

        end
            
        % Warp estimated image
        X = warp_image(X, vx, vy, 2);
    end

    
end








