
function [X2] = AplicaBlurDTri(X,ImT,t,ImAux)
% =========================================================================
% Applies nonuniform blurring to the images, based on ImT(t).coord
% 
% INPUTS:
% X    : input image that will be nonuniformly blurred
% ImT  : low resolution EIT image structures
% t    : time index of the low resolution images
% ImAux: auxiliary matrix containing the position x,y of the indexes of the uniform image pixels
%
% OUT:
% X2   : nonuniformly blurred image
% =========================================================================


X2 = X;

for i=1:length(ImT(t).coord.x)
    % Encontra as posições que estão dentro do elemento i
    temp = inpolygon(ImAux.X,ImAux.Y,ImT(t).coord.x(i,:),ImT(t).coord.y(i,:));
    % Adquire os indices dos pixels pertencentes aos elementos
    [rowi coli] = find(temp); % temos quais os pixels que compoem o elemento i (diferentes de 0)

    % Inicializa o valor médio sob o triângulo
    valorMedio = 0;
    % Calcula o valor médio dos pixels do elemento (diferentes de zero em temp)
    for k=1:length(rowi)
        valorMedio = valorMedio + X(rowi(k),coli(k))/length(rowi);
    end

    % Atribui o valor médio aos pixels do elemento (encontrados anteriormente)
    for k=1:length(rowi)
        X2(rowi(k),coli(k)) = valorMedio;
    end


end
    
    
    