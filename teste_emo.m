%{
    Determina a taxa de falsa rejeição (FAR) e de falsa aceitação (FAR).
    res = Mat. de resultados (MxN), M = Núm. de locuções. N = Núm. de emoções;
    
    frr, far = taxa de falsa rejeição (FAR) e de falsa aceitação (FRR).
%}

function [frr, far, min_erro] = teste_emo(res)

intervalo = 0.1;
emo_col = ['W';'T';'F';'N']; % Determina as emoções a serem buscadas. ['W';'L';'A';'F';'T';'N'];

% Determina os valores mín. e max. para serem utilizados no cálculo do erro.
ini = min(res(:)); fim = max(res(:));

% Inicializa os vetores de FRR e FAR.
frr = zeros(1, length(ini:intervalo:fim));
far = zeros(1, length(ini:intervalo:fim));

j = 1;
% Laço for para obter os erros para cada valor da verossimilhança.
for i = ini:intervalo:fim
    [far(j), frr(j)] = teste_loc_lim(res,i);
    j = j+1;
end

% Plot dos FAR e FRR para cada valor de verossimilhança.
t = ini:intervalo:fim;

vet = far == frr;
idx = find(vet == 1);

if ~isempty(idx)
    idx = idx(1);
    idx_rescale = round(re_scale(idx,(1:length(far)),t));
    min_erro = far(idx);
    
    subplot(211);
    plot(t,far,'b'); hold on; plot(t,frr,'r'); hold on; plot(idx_rescale,far(idx),'ro'); legend('FAR','FRR'); xlabel('Limiar'); ylabel('Erro (%)'); grid on; title('Variação do erro')
    
    subplot(212);
    plot(far,frr,'b'); xlabel('FAR'); ylabel('FRR'); hold on; plot([0 1],[0 1],'r--'); grid on;
    
else
    subplot(211);
    plot(t,far,'b'); hold on; plot(t,frr,'r'); hold on; legend('FAR','FRR'); xlabel('Limiar'); ylabel('Erro (%)'); grid on; title('Variação do erro')
    
    subplot(212);
    plot(far,frr,'b'); xlabel('FAR'); ylabel('FRR'); hold on; plot([0 1],[0 1],'r--'); grid on;
    min_erro = NaN;
    
end

end

%{
    Determina a taxa de falsa rejeição (FAR) e de falsa aceitação (FAR).
    Para cada valor de verossimilhança.
    res = Mat. de resultados (MxN), M = Núm. de locuções. N = Núm. de emoções;
    lim = Verossimilhança mínina para ser considerado dentro da classe.
    
    frr, far = taxa de falsa rejeição (FAR) e de falsa aceitação (FRR).
%}

function [far,frr] = teste_loc_lim(res,lim)
far = 0;
frr = 0;
NLoc = size(res,1);
NEmo = size(res,2);

for col = 1:NEmo
    rang1 = 1:31:size(res,1);
    rang2 = rang1(col):rang1(col)+30;
    
    for lin = 1:size(res,1)
        
        % Caso seja maior que o lim e esteja fora da categoria.
        % Falsa aceitação.
        if (res(lin,col) >= lim) && isempty(find(rang2 == lin))
            far = far+1;
        end
        
        % Caso seja menor que o lim e esteja dentro da categoria.
        % Falsa rejeição.
        if (res(lin,col) <= lim) && ~isempty(find(rang2 == lin))
            frr = frr+1;
        end
    end
end

% Determinação dos erros.
far = far/(NLoc*(NEmo-1));
frr = frr/NLoc;

end