function [ImAux] = criaMatrizesAux_comPosicao_dosPixels(coord, Nx, Ny)
%==========================================================================
% Cria as matrizes auxiliares com as posi��es espaciais correspondentes
% aos pixels na nova malha uniforme
%
% IN: coord: structure containing the coordinates of the finite elements in the mesh
%     Nx,Ny: number of pixels in the x and y axis
% 
% OUT: ImAux: matrices containing the positions (x,y) referent to each pixel
% 
%==========================================================================


% ImAux = zeros(Ny,Nx);
% Coordenadas dos pontos em x,y na grade uniforme de min a max com Nx pts
ImAuxx = min(coord.x):((max(coord.x)-min(coord.x))/(Nx-1)):max(coord.x);
ImAuxy = min(coord.y):((max(coord.y)-min(coord.y))/(Nx-1)):max(coord.y);

% Inicializa as matrizes das coordenadas e atribui os valores
ImAux.Y = zeros(Ny,Nx);
ImAux.X = zeros(Ny,Nx);
for i=1:Nx
    ImAux.X(i,:) = ImAuxx;
end
for i=1:Ny
    ImAux.Y(:,i) = ImAuxy';
end



