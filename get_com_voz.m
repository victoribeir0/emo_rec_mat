% viz = Vizinhos (2,3,4,5... etc)

function [dx,dxn,C] = get_com_voz(seq,viz,plot_img,n_quant)

% C = unique(x);    % Obtém os caracteres únicos.
C = 1:n_quant;
N = length(C);    % Tamanho do conjunto de caracteres.
P = ones(N,N);    % Inicia a matriz de co-ocorrências.

for n = viz+1:length(seq)-viz       % Varre todos os caracteres de 2 até o penultimo.
    posi = find(seq(n) == C); % Obtém o índice do caractere n.
    
    for m = [-viz viz]            % Varre os caracteres vizinhos ao caractere n (n+1 e n-1).
        posj = find(seq(n-m) == C);      % Obtém o índice do caractere vizinho.
        P(posi,posj) = P(posi,posj) + 1; % Incrementa o contador de ocorrências.
    end
end

P = P/sum(P(:)); % Normaliza a matriz de probabilidades.
% P = P./repmat(sum(P,2),1,32);

dx = -log(P);    % Caucula o log.
% dx = -P;
mat_x = normalizar(dx);
% Digonal principal igual a 0.
x_vet = reshape(mat_x,1,size(mat_x,1)^2);    % ---
x_vet(1:size(mat_x,1)+1:length(x_vet)) = 0;  % ---
dx = reshape(x_vet,N,N);                     % Retorna ao formato de matriz.
dxn = dx;
dxn(dxn >= 128) = 255;

if plot_img
    imagesc(dx); figure, imagesc(dxn);      % Mostra a imagem.
end

end

% Função para normalizar a matriz x.
function x = normalizar(x)
% x = -x;
x = x-min(x(:));
x = floor(255*x/max(x(:))); % +1

end