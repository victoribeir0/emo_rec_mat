% Calcula a autocorrelação e o F0 (estimado) do sinal x.
% x = Sinal de entrada.
% Njan = Núm. de amostras em cada janela.

function [k_0, usaveis] = get_f0(x, Tjan, inds, fs)

Njan = round((Tjan/1000)*fs); % Num. de amostras em cada janela.
NAv = round((10/1000)*fs); % Num. de amostras para o avanço (sobreposição).
Tam = round((length(x)-Njan)/NAv); % Num. total de janelas.
R = zeros(Tam,round(Njan/3)); % Inicialização da matriz de autocorrelaçao.

% Laço for para cada janela.
for i = 1:NAv  
    ap = ((i-1)*NAv)+1;
       
    for m = 1:round(Njan/3)  % Laço for para cada varrer dentro da janela.
        
        % Caso esteja na última janela, o alg. não pode mais calcular a autoco.
        if (ap+Njan-1)+m-1 <= length(x)
                        
            a = x(ap:ap+Njan-1); % Seleciona o segmento do sinal.
            b = x((ap:ap+Njan-1)+m-1);
            a = a-mean(a); % Remove o nível DC subtraindo pela média.
            b = b-mean(b);
            
            % Calcula a autocorrelação:
            R(i,m) = mean(a.*b);            
        end        
    end
end

ind_skip = 20; % Variável onde começa a valer para encontrar o máx.
[~, k_0] = max(R(inds,ind_skip:end),[],2);

% Devido o calculo do máximo (passo anterior) ser feito a partir do índice
% 15, os valores de max_pos devem ser somados a ind_skip-1, para voltar para
% os valores de origem.
k_0 = k_0 + (ind_skip-1);

% Para obter a freq. em Hz divide Fs/max_pos.
k_0 = fs./k_0;

k_0 = k_0(k_0 <= 500); % Mantém somente os menos que 500 Hz.

% Obtém mediana de k0.
if ~mod(length(k_0),2) % Caso seja par.
    [~,pos_rem] = max(abs(k_0-mean(k_0)));
    k_0(pos_rem) = [];
end

mdn = median(k_0);

% Valor em que a mediana pode variar (para mais ou para menos).
range_med = 15;

% Obtém os índices em que k0 que não estão distantes da mediana.
idx_n = find(k_0 <= mdn+range_med & k_0 >= mdn-range_med);
% idx = idx(idx_n);

% Atualiza os k0 (descarta os que estão distantes de mediana).
k_0 = k_0(idx_n);
usaveis = inds(idx_n);

end
