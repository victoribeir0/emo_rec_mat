% viz = Vizinhos (2,3,4,5... etc)

function [dx,P] = get_dist_text(seq,viz,plot_img,vizinhanca, dist)

C = unique(seq);
N = length(C);    % Tamanho do conjunto de caracteres.
P = ones(N,N);    % Inicia a matriz de co-ocorr�ncias.

if vizinhanca == 1                % Calcula um �nico vizinho especificado.
    for n = viz+1:length(seq)-viz % Varre todos os caracteres de 2 at� o penultimo.
        posi = find(seq(n) == C); % Obt�m o �ndice do caractere n.
        
        for m = [-viz viz]            % Varre os caracteres vizinhos ao caractere n (n+1 e n-1).
            posj = find(seq(n-m) == C);      % Obt�m o �ndice do caractere vizinho.
            P(posi,posj) = P(posi,posj) + 1; % Incrementa o contador de ocorr�ncias.
        end
    end
    
elseif vizinhanca == 2            % Calcula v�rios vizinhos dentro de range especificado.
    m = nonzeros(-viz:viz)';
    for n = viz+1:length(seq)-viz % Varre todos os caracteres de 2 at� o penultimo.
        posi = find(seq(n) == C); % Obt�m o �ndice do caractere n.
        
        for k = 1:length(m)                  % Varre os caracteres vizinhos ao caractere n (n+1 e n-1).
            posj = find(seq(n-m(k)) == C);   % Obt�m o �ndice do caractere vizinho.
            P(posi,posj) = P(posi,posj) + 1; % Incrementa o contador de ocorr�ncias.
        end
    end
    
else % Calcula vizinhos dentro de um range, 3 vizinhos consectivos a partir de viz (para frente e para tr�s).
    for n = viz*2+1:length(seq)-viz*2 % Varre todos os caracteres de 2 at� o penultimo.
        posi = find(seq(n) == C);     % Obt�m o �ndice do caractere n.
        
        sub = viz-4+1;
        
        for m = [-viz*2:-viz-sub viz+sub:viz*2]  % Varre os caracteres vizinhos ao caractere n (n+1 e n-1).
            posj = find(seq(n-m) == C);      % Obt�m o �ndice do caractere vizinho.
            P(posi,posj) = P(posi,posj) + 1; % Incrementa o contador de ocorr�ncias.
        end
    end
end

P = P/sum(P(:)); % Normaliza a matriz de probabilidades.
% P = P./repmat(sum(P,2),1,32);

if dist == 1
    dx = -log(P);    % Caucula o log.
else
    dx = P;
end

%dx = -P;
mat_x = normalizar(dx);
% Digonal principal igual a 0.
x_vet = reshape(mat_x,1,size(mat_x,1)^2);    % ---
x_vet(1:size(mat_x,1)+1:length(x_vet)) = 0;  % ---
dx = reshape(x_vet,N,N);                     % Retorna ao formato de matriz.
dxn = dx;
dxn(dxn >= 128) = 255;

if plot_img
    imagesc(dx); % figure, imagesc(dxn); % Mostra a imagem.
end

end

% Fun��o para normalizar a matriz x.
function x = normalizar(x)
% x = -x;
x = x-min(x(:));
x = floor(255*x/max(x(:))); % +1

end