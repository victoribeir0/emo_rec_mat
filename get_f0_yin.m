%{
    Calcula a autocorrelação e o F0 (estimado) do sinal x.
    x = Sinal de entrada.
    Tjan = Tempo de cada janela em ms.
    inds = Janelas a serem utilizados.
    Fs = Freq. de amostragem.

    F0 = vetor F0 estimado.
    Obs: O vetor de F0 é reduzido pela mediana, valores distantes são removidos.
%}

function [F0, usaveis] = get_f0_yin(x, Tjan, inds, Fs, range_med)

Njan = round((Tjan/1000)*Fs); % Num. de amostras em cada janela.
NAv = round((10/1000)*Fs);    % Num. de amostras para o avanço (sobreposição).

                     % Começo e fim do laço de comparação. 
ini = round(Fs/500); % Isso permite que os f0 obtidos sejam < 500 Hz.
fim = round(Fs/75);  % Isso permite que os f0 obtidos sejam > 75 Hz.
R = zeros(length(inds),length(1:fim)); % Inicialização da matriz de autocorrelaçao.
D = zeros(length(inds),length(1:fim));
b = zeros(length(1:fim),Njan);         % Inicialização da matriz de dados.
r_0 = zeros(1,length(inds));
% janelaHamming = 0.54 - 0.46*cos(2*pi*(0:Njan-1)/Njan); 
% h = fir1(200,4000/(Fs/2));
% x2 = conv(x,h);
% x2 = x2(101:end-100);
mat_x = buffer(x, Njan, Njan-NAv, 'nodelay');

for i = 1:length(inds)-1 % Laço for para cada janela específica.
        
    aux = inds(i); % Define a janela específica.
    ap = ((aux-1)*NAv)+1;
    a = mat_x(:,aux);       
    a = a-mean(a); % Remove o nível DC subtraindo pela média.
    %a = a.*janelaHamming';
    
    r_0(i) = sum(a.*a);
    mat_b = buffer(x(ap:ap+Njan-1+fim-1),Njan,Njan-1, 'nodelay')';
    mat_b(1:ini-1,:) = zeros(ini-1,640);
    med_b = ones(size(mat_b,2),1)*mean(mat_b,2)';
    mat_b = mat_b - med_b';
    
    D(i,:) = sum((repmat(a',size(b,1),1) - mat_b).^2,2);
    R(i,:) = mat_b*a; % Vetor de autocorrelação, para cada janela i.    
end

[~, max_pos] = max(R(:,:),[],2); % Obtém as posições dos valores máximos.
[~, min_pos] = min(D(:,:),[],2); % Obtém as posições dos valores máximos.
F0 = Fs./max_pos;                % Obtém o F0, Fs/max_pos.

% Obtém mediana de k0.
if ~mod(length(F0),2) % Caso seja par.
    [~,pos_rem] = max(abs(F0-mean(F0)));
    F0(pos_rem) = [];
end

mdn = median(F0);

% Valor em que a mediana pode variar (para mais ou para menos): range_med = 15;
% Obtém os índices em que k0 que não estão distantes da mediana.
idx_n = find(F0 <= mdn+range_med & F0 >= mdn-range_med);

% Atualiza os k0 (descarta os que estão distantes de mediana).
F0 = F0(idx_n);
usaveis = inds(idx_n);

end