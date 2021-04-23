%{
    Extrai informações dos sinais de voz.
    emo = Emoção a ser procurada.
    rnn = VAD com rede neural (0 ou 1).
    ext = Tipo de extrator a ser usado ('mfcc', 'f0', 'lpcc', etc.).
    
    base = Características coletadas de todos os sinais de uma determinada emoção.
%}

function base = get_emo_feats(emo,rnn,ext)

% Localização dos arquivos de áudio.
folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2\wav\treino';
cd(folder);
as = dir('*.wav');
N = numel(as);

% Inicialização para cada tipo de extrator ('mfcc', 'f0', etc.).
if strcmp(ext, 'mfcc')
    base = zeros(36,1);
    
elseif strcmp(ext, 'f0')
    base = zeros(8,1);
    
elseif strcmp(ext, 'lpcc')
    base = zeros(15,1);
end

% Laço para cada sinal.
for n = 1:N
    str = as(n).name; % Define o nome do arquivo.
    em = str(6);      % Define a emoção do arquivo.
    
    % Caso a emoção seja a mesma que esta sendo pesquisada.
    if emo == em
        
        % Localização dos arquivos de áudio.
        folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2\wav\treino';
        cd(folder);
        dados = importdata(str); % Abre o arquivo de áudio.
        
        % Obtém a matriz do espectrograma.
        % Caso rnn = 1, seleção das janelas baseada na rede neural.
        % Caso rnn = 0, seleção das janelas baseada na energia do mfcc.
        [S, L] = get_spec(dados.data, dados.fs, 40, 10, 0, rnn);
        
        % Obtém o MFCC.
        MFCC = get_mfcc(S, L, dados.fs);
        
        % Caso rnn não seja solicitado.
        % Seleção das janelas baseada na energia do mfcc.
        if rnn == 0
            lim = mean(MFCC(1,:));
            idx = find(MFCC(1,:) > lim);
            MFCC = MFCC(2:end,idx);
            
        % Caso rnn  seja solicitado.
        % Seleção das janelas baseada na rede neural.
        else
            MFCC = MFCC(2:end,:);
            idx = 1:size(MFCC,2); % Nesse caso, todos os índices sao úteis.
        end
        
        % Caso o extrator seja mfcc:
        if strcmp(ext, 'mfcc')
            dMFCC = dmfcc(MFCC,3);
            MFCC = [MFCC; dMFCC];
            
            y = MFCC;
        end
        
        % Caso o extrator seja f0:
        if strcmp(ext, 'f0')
            [~, m_f0, nrg, jit_abs, ~, jit_x, shi_abs, shi_rel, amp_std, amp_x, mean_dif_picos] = get_global(dados.data,idx,dados.fs);            
            [int_voz, ~] = get_times(nrg,1);
            
            y = [sum(int_voz); mean(int_voz); m_f0; mean(jit_abs); jit_x; mean(shi_abs); mean(mean_dif_picos); mean(amp_x)];
        end
        
        if strcmp(ext, 'lpcc')
            % Mat. LPCC e mat. da resp. em freq para cada janela analisada.
            [mat_lpcc, mat_H] = get_lpcc_mat(dados.data, dados.fs, 40, 10, rnn, 12);
            
            % Matrizes somente com as janelas com voz (idx).
            mat_H = log(abs(mat_H(:,idx)));
            mat_lpcc = mat_lpcc(:,idx);
            
            % Bandas do espectro (0-1000, 1000-2000, 2000-3000).
            y1 = round(re_scale(1000,(0:8000),(1:size(mat_H,1))));
            y2 = round(re_scale(2000,(0:8000),(1:size(mat_H,1))));
            y3 = round(re_scale(3000,(0:8000),(1:size(mat_H,1))));
            
            % Energias para cada banda do espectro.
            c1 = sum(mat_H(1:y1,:).^2);
            c2 = sum(mat_H(y1:y2,:).^2);
            c3 = sum(mat_H(y2:y3,:).^2);
            
            % Energia logarítmica para cada banda.
            en_log = log([c1;c2;c3]); 
            
            % mean_mat_H = mean(mat_H(:,:),2);  
                        
            y = [mat_lpcc; en_log]; % Vetor de características lpcc.
        end
        
        % Incrementa a base com as informações de cada sinal.
        base = [base y];
        
    end
end

% Remove a primeira coluna (que é vazia).
base = base(:,2:end);
end
