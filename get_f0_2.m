%{
    Calcula a autocorrelação e o F0 (estimado) do sinal x.
    x = Sinal de entrada.
    Tjan = Tempo de cada janela em ms.
    inds = Janelas a serem utilizados.
    Fs = Freq. de amostragem.

    F0 = vetor F0 estimado.
    Obs: O vetor de F0 é reduzido pela mediana, valores distantes são removidos.
%}

function [F0, usaveis, hnr] = get_f0_2(x, Tjan, inds, Fs)

Njan = round((Tjan/1000)*Fs); % Num. de amostras em cada janela.
NAv = round((10/1000)*Fs);    % Num. de amostras para o avanço (sobreposição).

                     % Começo e fim do laço de comparação. 
ini = round(Fs/500); % Isso permite que os f0 obtidos sejam < 500 Hz.
fim = round(Fs/75);  % Isso permite que os f0 obtidos sejam > 75 Hz.
R = zeros(length(inds),length(1:fim)); % Inicialização da matriz de autocorrelaçao.
b = zeros(length(1:fim),Njan);         % Inicialização da matriz de dados.
r_0 = zeros(1,length(inds));
janelaHamming = 0.54 - 0.46*cos(2*pi*(0:Njan-1)/Njan); 

for i = 1:length(inds) % Laço for para cada janela específica.
    
    aux = inds(i); % Define a janela específica.
    ap = ((aux-1)*NAv)+1;
    a = x(ap:ap+Njan-1);
    a = a-mean(a); % Remove o nível DC subtraindo pela média.
    a = a.*janelaHamming';
    
    r_0(i) = sum(a.*a);
    
    % Constroi a matriz b, com os dados de x atrasos em m amostras.
    for m = ini:fim
        if (ap+Njan-1)+m-1 <= length(x)
            b(m,:) = x((ap:ap+Njan-1)+m-1)-mean(x((ap:ap+Njan-1)+m-1));
        end
    end
    
    R(i,:) = b*a; % Vetor de autocorrelação, para cada janela i.
    
end

[max_val, max_pos] = max(R(:,:),[],2); % Obtém as posições dos valores máximos.
F0 = Fs./max_pos;                      % Obtém o F0, Fs/max_pos.

Njan_F0 = 15;
Numjan_F0 = floor(length(F0)/Njan_F0);
F0_y = zeros(Numjan_F0,Njan_F0);

F0 = F0(F0 <= 500); % Mantém somente os menos que 500 Hz.
F0_fim = [];

for s = 1:Numjan_F0
    apon = ((s-1)*Njan_F0)+1;
    F0_s = F0(apon:apon+Njan_F0-1);
    mdn = median(F0_s);
    idx_s = find(F0_s > mdn + 15 | F0_s < mdn - 15);
    
    for d = 1:length(idx_s)
        if idx_s(d) - 2 >= 1 & idx_s(d) + 2 <= length(F0_s)
            F0_s(idx_s(d)) = mean([mean(F0_s(idx_s(d) - 2: idx_s(d) - 1)) mean(F0_s(idx_s(d) + 1: idx_s(d) + 2))]);
        end
    end
    
    F0_fim = [F0_fim; F0_s];
end

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

hnr = (max_val(idx_n)./r_0(idx_n)');
hnr = hnr(hnr < 1);
hnr = 10*log10(hnr./(1-hnr));
hnr = mean(hnr);

% Atualiza os k0 (descarta os que estão distantes de mediana).
F0 = F0(idx_n);
usaveis = inds(idx_n);

end