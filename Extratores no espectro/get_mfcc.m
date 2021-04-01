% Calcula os coeficientes Mel-Cepstrais.
% S = Matriz do espectrograma.
% L = Comprimento de cada janela (am amostras).
% MFCC = Coeficientes Mel-Cepstrais.

function MFCC = get_mfcc(S, L, Fs)

fmin = 133.333; % Freq. mín.
fmax = Fs/2;    % Freq. máx.
NFiltLin = 13;  % N de filtros lineares.
deltaLin = (1000-fmin)/(NFiltLin-1); % Intervalos lineares.

NFiltLog = 27;  % N de filtros log.
deltaLog = (log(fmax)-log(1000))/(NFiltLog-1); % Intervalos log.

NFiltTotal = NFiltLin + NFiltLog; % N° de filtros no total.

escala = ((0:round(L/2)-1)*Fs)/L;

escalaMel = zeros(1,NFiltTotal);
escalaMel(1:NFiltLin) = fmin + (0:NFiltLin-1)*deltaLin;

razaoPG = exp(deltaLog);
escalaMel(NFiltLin+1:NFiltTotal+2) = escalaMel(NFiltLin)*razaoPG.^(1:NFiltLog+2);

freq_i = escalaMel(1:NFiltTotal);   % Freq. do início das bandas críticas
freq_c = escalaMel(2:NFiltTotal+1); % Freq. do centro das bandas críticas
freq_f = escalaMel(3:NFiltTotal+2); % Freq. do final das bandas críticas

F = zeros(NFiltTotal,round(L/2));

for n = 1:NFiltTotal
    [~, ind_i] = min(abs(escala-freq_i(n)));
    [~, ind_c] = min(abs(escala-freq_c(n)));
    [~, ind_f] = min(abs(escala-freq_f(n)));
    
    % Filtros retangulares:
        for col = ind_i:ind_f
            F(n,col) = 1;
        end
           
%     if ind_c ~= ind_i
%         for col=ind_i:ind_c-1,
%              F(n,col)=(col-ind_i)/(ind_c-ind_i); % Interpolação linear de subida
%         end
%     end
%     if ind_f~=ind_c
%         for col=ind_c:ind_f,
%             F(n,col)=1-(col-ind_c)/(ind_f-ind_c); % Interpolação linear de descida
%         end
%     end        
    
    % Para que cada filtro deixe passar a mesma quantidade de energia, a área dos triângulos deve ser normalizada:
    F(n,:)=F(n,:)*(1/(freq_f(n)-freq_i(n)));
    
    % Normalização (para que todas as bandas tenham a mesma energia).
    % Quanto maior a banda, menor a amplitude (mesma área para todas as bandas).
    % F(n,:) = F(n,:)*(1/(freq_f(n)-freq_i(n)));
end

% Transformada do Coseno (DCT).
numCoefCep = 19;
matDCT = zeros(numCoefCep,NFiltTotal);
peso = 1/sqrt(numCoefCep/2);

for linha = 1:numCoefCep
    aux = 1:NFiltTotal;
    matDCT(linha,:) = peso * cos(pi*(linha-1) * (aux-0.5)/NFiltTotal);
end
matDCT(1,:) = matDCT(1,:)*sqrt(2)/2;

% Obtém as energias logaritmicas.
EspectroLog = log10(F*S+(10^-6));
MFCC = matDCT*EspectroLog;

end
