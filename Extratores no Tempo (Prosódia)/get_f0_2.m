%{
    Calcula a autocorrelação e o F0 (estimado) do sinal x.
    x = Sinal de entrada.
    Tjan = Tempo de cada janela em ms.
    inds = Janelas a serem utilizados.
    Fs = Freq. de amostragem.

    F0 = vetor F0 estimado.
    Obs: O vetor de F0 é reduzido pela mediana, valores distantes são removidos.
%}

function [F0, usaveis] = get_f0_2(x, Tjan, inds, Fs)

Njan = round((Tjan/1000)*Fs); % Num. de amostras em cada janela.
NAv = round((10/1000)*Fs);    % Num. de amostras para o avanço (sobreposição).

                     % Começo e fim do laço de comparação. 
ini = round(Fs/500); % Isso permite que os f0 obtidos sejam < 500 Hz.
fim = round(Fs/75);  % Isso permite que os f0 obtidos sejam > 75 Hz.
R = zeros(length(inds),length(1:fim)); % Inicialização da matriz de autocorrelaçao.
b = zeros(length(1:fim),Njan);         % Inicialização da matriz de dados.

for i = 1:length(inds) % Laço for para cada janela específica.
    
    aux = inds(i); % Define a janela específica.
    ap = ((aux-1)*NAv)+1;
    a = x(ap:ap+Njan-1);
    a = a-mean(a); % Remove o nível DC subtraindo pela média.    
    
    % Constroi a matriz b, com os dados de x atrasos em m amostras.
    for m = ini:fim           
        b(m,:) = x((ap:ap+Njan-1)+m-1)-mean(x((ap:ap+Njan-1)+m-1));
    end
    
    R(i,:) = b*a; % Vetor de autocorrelação, para cada janela i.
    
end

[~, max_pos] = max(R(:,:),[],2); % Obtém as posições dos valores máximos.
F0 = Fs./max_pos;                % Obtém o F0, Fs/max_pos.

F0 = F0(F0 <= 500); % Mantém somente os menos que 500 Hz.

% Obtém mediana de k0.
if ~mod(length(F0),2) % Caso seja par.
    [~,pos_rem] = max(abs(F0-mean(F0)));
    F0(pos_rem) = [];
end

mdn = median(F0);

% Valor em que a mediana pode variar (para mais ou para menos).
range_med = 15;

% Obtém os índices em que k0 que não estão distantes da mediana.
idx_n = find(F0 <= mdn+range_med & F0 >= mdn-range_med);

% Atualiza os k0 (descarta os que estão distantes de mediana).
F0 = F0(idx_n);
usaveis = inds(idx_n);

end
