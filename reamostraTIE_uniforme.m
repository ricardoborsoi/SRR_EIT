function [ImT,imagens_reais,MascaraTemp] = reamostraTIE_uniforme(ImT,imagens_reais,normalizarImagens,Nx,Ny,ImAux)
%==========================================================================
% Resample the EIT images to a spatially uniform grid (IHR images)
%
% IN: ImT        : low-resolution EIT images structure with converted mesh coordinates
%     imagem_real: ground truth EIT image (if available, otherwise set to "[]") 
%     Nx,Ny      : uniform HR/IHR image dimensions
%     ImAux      : auxiliary images containing the (x,y) positions corresponding 
%                  to the image pixels
%
% OUT: ImT        : low-resolution EIT images structure containing an additional 
%                   field with the IHR/uniform images
%      imagem_real: ground truth image containing the additional field with
%                   the uniform image (if available)
%      MascaraTemp: binary mask image containign "1" in the EIT domain and 
%                   "0" outside
%
%==========================================================================

% Cria um campo para a imagem em grade uniforme uniforme em ImT
for i=1:length(ImT)
    ImT(i).imagem_LR = zeros(Ny,Nx);
end

% Cria o mesmo campo para a imagem real
if sum(size( imagens_reais(1) )) ~= 0 % imagem_real ~= []
    imagem_real(length(imagens_reais)).imagem = zeros(Ny, Nx);
end





% Realiza a reamostragem para LR
for j=1:length(ImT)
    for i=1:length(ImT(j).coord.x)
        % Encontra as posi��es que est�o dentro do elemento i
        temp = inpolygon(ImAux.X,ImAux.Y,ImT(j).coord.x(i,:),ImT(j).coord.y(i,:));
        % Atribui o valor da resistividade �s posi��es do elemento (m�scara E)
        temp = temp*ImT(j).coord.value_LR(i);
        % We must be careful not ot doubly assign any pixel
        % If a pixel has already been assigned a value, eliminate it from the 'temp' mask
        temp = (ImT(j).imagem_LR == 0) .* temp;
        % Mascara OU
        ImT(j).imagem_LR = ImT(j).imagem_LR + temp;
    end

    % Diminuir o valor minimo que seja diferente de zero para zero (normalizar
    % apenas os elementos v�lidos, desconsiderar os zeros)
    [linhas, colunas] = find(ImT(j).imagem_LR); % indices dos elementos iguais a zero
    temp = sparse(linhas,colunas,ones(length(linhas),1),Nx,Ny);
    temp = full(temp); % Converte para uma matriz normal/cheia
    
    % Armazena a m�scara para uso posterior
    MascaraTemp = temp;
    
%     pcolor(temp) % Mostra a mascara gerada
    if normalizarImagens == 1
        ValMin = min(nonzeros(ImT(j).imagem_LR)); % Minimo valor de Im que seja diferente de zero
        ValMax = max(nonzeros(ImT(j).imagem_LR));
        temp = temp*ValMin;
        ImT(j).imagem_LR = ImT(j).imagem_LR - temp;
        ImT(j).imagem_LR = ImT(j).imagem_LR*floor(255/(ValMax-ValMin));
    end
    
end








% % =========================================================================
% % Initialize field for real image
% for i=1:length(imagens_reais)
%     imagens_reais(i).imagem = zeros(Ny,Nx);
% end
% 
% % Repeat for the HR images
% for j=1:length(imagens_reais)
%     for i=1:length(imagens_reais(j).coord.x)
%         % Encontra as posi��es que est�o dentro do elemento i
%         temp = inpolygon(ImAux.X,ImAux.Y,imagens_reais(j).coord.x(i,:),imagens_reais(j).coord.y(i,:));
%         % Atribui o valor da resistividade �s posi��es do elemento (m�scara E)
%         temp = temp*imagens_reais(j).coord.value(i);
%         % Mascara OU
%         imagens_reais(j).imagem = imagens_reais(j).imagem + temp;
%     end
% 
%     % Diminuir o valor minimo que seja diferente de zero para zero (normalizar
%     % apenas os elementos v�lidos, desconsiderar os zeros)
%     % [linhas colunas] = find(ImT(j).imagem == 0); % indices dos elementos diferentes de zero
%     [linhas, colunas] = find(imagens_reais(j).imagem); % indices dos elementos iguais a zero
%     temp = sparse(linhas,colunas,ones(length(linhas),1),Nx,Ny);
%     temp = full(temp); % Converte para uma matriz normal/cheia
%     
%     % Armazena a m�scara para uso posterior
%     MascaraTemp = temp;
%     
%     
%     ValMin = min(nonzeros(imagens_reais(j).imagem)); % Minimo valor de Im que seja diferente de zero
%     ValMax = max(nonzeros(imagens_reais(j).imagem));
% 
% %     pcolor(temp) % Mostra a mascara gerada
%     if normalizarImagens == 1
%         temp = temp*ValMin;
%         imagens_reais(j).imagem = imagens_reais(j).imagem - temp;
% 
% %         imagens_reais(j).imagem = imagens_reais(j).imagem*floor(255/ValMax);
%         imagens_reais(j).imagem = imagens_reais(j).imagem*floor(255/(ValMax-ValMin));
%     end
%     
% end













