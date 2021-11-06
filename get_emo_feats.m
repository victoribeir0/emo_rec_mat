%{
    Extrai informa��es dos sinais de voz.
    emo = Emo��o a ser procurada.
    rnn = VAD com rede neural (0 ou 1).
    ext = Tipo de extrator a ser usado ('mfcc', 'f0', 'lpcc', etc.).
    
    base = Caracter�sticas coletadas de todos os sinais de uma determinada emo��o.
%}

function base = get_emo_feats(emo,rnn,ext)
% Localiza��o dos arquivos de �udio.
folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2\wav\emos\Treino';
cd(folder);
as = dir('*.wav');
N = numel(as);

% Inicializa��o para cada tipo de extrator ('mfcc', 'f0', etc.).
base = [];
warning('off','signal:findpeaks:largeMinPeakHeight'); % Desativa avisos.

% La�o para cada sinal.
for n = 1:N
    str = as(n).name; % Define o nome do arquivo.
    em = str(6);      % Define a emo��o do arquivo.
    
    % Caso a emo��o seja a mesma que esta sendo pesquisada.
    if emo == em
        
        % Localiza��o dos arquivos de �udio.
        folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2\wav\emos\Treino';
        cd(folder);
        dados = importdata(str); % Abre o arquivo de �udio.
        
        % Obt�m a matriz do espectrograma.
        % Caso rnn = 1, sele��o das janelas baseada na rede neural.
        % Caso rnn = 0, sele��o das janelas baseada na energia do mfcc.
        [S, L] = get_spec(dados.data, dados.fs, 40, 10, 0, rnn);
        
        % Obt�m o MFCC.
        MFCC = get_mfcc(S, L, dados.fs);
        
        % Caso rnn n�o seja solicitado.
        % Sele��o das janelas baseada na energia do mfcc.
        if rnn == 0
            lim = mean(MFCC(1,:));
            idx = find(MFCC(1,:) > lim);
            MFCC = MFCC(2:end,idx);
            
            % Caso rnn  seja solicitado.
            % Sele��o das janelas baseada na rede neural.
        else
            MFCC = MFCC(2:end,:);
            idx = 1:size(MFCC,2); % Nesse caso, todos os �ndices sao �teis.
        end
        
        % Caso o extrator seja mfcc:
        if strcmp(ext, 'mfcc') || strcmp(ext, 'todos')
            dMFCC1 = dmfcc(MFCC,3);
            dMFCC2 = dmfcc(dMFCC1,3);
            y = [MFCC; dMFCC1; dMFCC2];                        
        end
        
        % Caso o extrator seja f0:
        if (strcmp(ext, 'pro_aud') || strcmp(ext, 'pro_jan')) || strcmp(ext, 'all')
            y = ext_prosodia(dados, idx, ext);                  
        end
        
        if strcmp(ext, 'lfpc-env') || strcmp(ext, 'lpcc-coef') || strcmp(ext, 'formantes') || strcmp(ext, 'todos')
            y = ext_lpcc(dados, idx, ext, rnn);                                  
        end
        
        if strcmp(ext, 'lfpc')
            LFPC = get_lfpc(S, L, dados.fs, 12);
            dLFPC = dmfcc(LFPC,3);
            y = [LFPC; dLFPC];
        end
        
        if strcmp(ext, 'linfpc')
            LFPC = get_linfpc(S, 12);
            dLFPC = dmfcc(LFPC,3);
            y = [LFPC; dLFPC];
        end
        
        % Incrementa a base com as informa��es de cada sinal.
        base = [base y];        
    end
end
end

function y = ext_prosodia(dados, idx, ext)
[~, f0, nrg, lognrg, jit_abs, ~, ~, shi_abs, ~, ~, mean_dif_picos] = get_global_contx(dados.data,idx,dados.fs,3);
[int_voz, ~] = get_times(nrg,1);            
y1 = [f0'; jit_abs; shi_abs; mean_dif_picos; lognrg];

if strcmp(ext, 'pro_aud')     % Caracter�sticas por �udios.
    % [vet, ~] = get_com_feat(y1,3);
    y = [sum(int_voz); mean(f0); mean(jit_abs); mean(shi_abs); mean(mean_dif_picos)];

elseif strcmp(ext, 'pro_jan') % Caracter�sticas por janelas. 
    y = y1;
    
elseif strcmp(ext, 'all') % Caracter�sticas por janelas.     
    dy1 = dmfcc(y1,3);    % Primeira a segunda derivada.
    dy2 = dmfcc(dy1,3);    
    y = [y1; dy1; dy2];    
end  
end

function y = ext_lpcc(dados, idx, ext, rnn)

% Mat. LPCC e mat. da resp. em freq para cada janela analisada.
[mat_lpcc, mat_H, formantes] = get_lpcc_mat(dados.data, dados.fs, 40, 10, rnn, 12);
mat_H = abs(mat_H);

if strcmp(ext, 'lfpc-env')
    % Matrizes somente com as janelas com voz (idx).
    mat_H = log(mat_H(:,:));
    lpcc_lfpc = get_lfpc(mat_H, size(mat_H,1)*2, dados.fs, 12);
    dlpcc_lfpc = dmfcc(lpcc_lfpc,3);
    y = [lpcc_lfpc; dlpcc_lfpc]; % Vetor de caracter�sticas lpcc.
    
elseif strcmp(ext, 'lpcc-coef')
    mat_lpcc = mat_lpcc(:,idx);
    y = mat_lpcc; % Vetor de caracter�sticas lpcc.
    
elseif strcmp(ext, 'formantes')
    y_temp = formantes(idx); % Vetor de caracter�sticas lpcc.
    tam = length(y_temp{1});
    y_temp = cell2mat(y_temp);
    y = reshape(y_temp,length(idx),tam); % 5 N�m. de formantes.
    y = y(:,1:5)';
end

end