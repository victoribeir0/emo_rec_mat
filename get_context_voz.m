function [dx,C] = get_com_voz(arquivo,filtro)

% Leitura do arquivo e determinação dos caracteres.
fileID = fopen(arquivo);
format = '%c';
texto = fscanf(fileID,format);
car = regexp(texto, '\S', 'match'); % Determina os caracteres.
car = cell2mat(car);                % Transforma em um vetor.
C = unique(car);                    % Obtém os caracteres únicos.
N = length(C);                      % Tamanho do conjunto de caracteres.
P = ones(N,N);                      % Inicia a matriz de co-ocorrências.

if filtro == 1
    C(regexp(C,'[!,'',",(,),*,-,.,/,_,«,»,À,Á,É,Ó,à,á,â,ã,ç,é,ê,í,ó,ô,õ,ú,ü,–,-,-,:,;,?,`,’,“,”]')) = [];
    car(regexp(car,'[!,'',",(,),*,-,.,/,_,«,»,À,Á,É,Ó,à,á,â,ã,ç,é,ê,í,ó,ô,õ,ú,ü,–,-,-,:,;,?,`,’,“,”]')) = [];
end

for n = 2:length(car)-1       % Varre todos os caracteres de 2 até o penultimo.
    posi = find(car(n) == C); % Obtém o índice do caractere n.
    
    for m = [-1 1]            % Varre os caracteres vizinhos ao caractere n (n+1 e n-1).
        posj = find(car(n-m) == C);      % Obtém o índice do caractere vizinho.
        P(posi,posj) = P(posi,posj) + 1; % Incrementa o contador de ocorrências.
    end
end

P = P/sum(P(:)); % Normaliza a matriz de probabilidades.
% dx = -log(P);    % Caucula o log.
dx = -P;
x = normalizar(dx);
                                         % Digonal principal igual a 0.
x_vet = reshape(x,1,size(x,1)^2);        % ---
x_vet(1:size(x,1)+1:length(x_vet)) = 0;  % ---
dx = reshape(x_vet,26,26);               % Retorna ao formato de matriz.
imagesc(dx);                             % Mostra a imagem.

end

% Função para normalizar a matriz x. 
function x = normalizar(x) 
% x = -x;
x = x-min(x(:));
x = floor(255*x/max(x(:)))+1;

end