classdef VoiceProcess
    properties
        Emo % Emo��o
        Ext % Extrator
    end
    
    methods
        %{
        Extrai informa��es dos sinais de voz.
        emo = Emo��o a ser procurada.
        rnn = VAD com rede neural (0 ou 1).
        ext = Tipo de extrator a ser usado ('mfcc', 'f0', 'lpcc', etc.).

        base = Caracter�sticas coletadas de todos os sinais de uma determinada emo��o.
        %}
        
        function base = get_emo_feats(obj,pasta)
            % Localiza��o dos arquivos de �udio.
            emo = obj.Emo;
            ext = obj.Ext;
            rnn = 0;
            folder = ['C:\Users\victo\Documents\Dataset _ EmoDB2\wav\emos\' pasta];
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
                    folder = ['C:\Users\victo\Documents\Dataset _ EmoDB2\wav\emos\' pasta];
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
        
        % Obt�m o modelo GMM para cada emo��o.
        % K = N�mero de centros (gaussianas) para o GMM.
        % ext = Tipo de extrator a ser usado ('mfcc', 'f0', etc.).
        % rnn = VAD com rede neural (0 ou 1).
        % [p0,c,S,L] = Par�metros do GMM (para cada emo��o).
        
        function [p0,C,cov,L,dims] = get_emo_gmm(K,ext)
            
            folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2\dados\dados_75_25';
            cd(folder);
            
            load('emo_lfpc_treino.mat');
            load('emo_pro_jan_treino.mat');
            load('centros_pro_jan_64.mat');
            %load('mds_pro_16432');
            %load('mds_pro_16433');
            %load('mds_pro_16452');
            load('mds_pro_16453');
            dims = [];
            
            % load('emo_f0_aud_treino.mat');
            
            % Inicaliza��o dos par�metros do GMM (para cada emo��o).
            C = []; cov = []; p0 = []; L = [];
            
            % Emo��es a serem procuradas.
            emos = ['F','A','N','T','E','L','W'];
            
            % La�o for para cada emo��o.
            for k = 1:length(emos)
                
                % Extrai as caracter�sticas para cada emo��o.
                % emo��o, vad-rnn (1 ou 0), extrator ('mfcc', 'f0', ...).
                % y = get_emo_feats(emos(k),rnn,ext,'treino');
                if strcmp(ext, 'pro_jan')
                    y = emo_pro_jan_treino{k};
                    seq = get_clusters(y,centros);
                    dims = get_otm_dims(emo_pro_jan_treino, centros, y_3);
                    y = [y; y_3(seq,dims)'];
                    
                elseif strcmp(ext, 'f0_3')
                    y = emo_f0_3_treino{k};
                    y = y(:,1:784);
                    seq = get_clusters(y,centros);
                    % y = centros(4,seq);
                    y = [y; y_3(seq,[5 7])'];
                    
                elseif strcmp(ext, 'mfcc')
                    y = emo_mfcc_treino{k};
                    
                elseif strcmp(ext, 'lfpc-coef')
                    y = emo_lfpc_treino{k};
                    
                elseif strcmp(ext, 'lfpc-env')
                    y = emo_lfpc_env_treino{k};
                    inds = randperm(size(y,2),3965); % Seleciona amostras aleat�rias.
                    y = y(:,inds);
                    
                elseif strcmp(ext, 'lpcc-coef')
                    y = emo_lpcc_treino{k};
                    inds = randperm(size(y,2),3965); % Seleciona amostras aleat�rias.
                    y = y(:,inds);
                    
                elseif strcmp(ext, 'linfpc')
                    y = emo_linfpc_12_treino{k};
                    inds = randperm(size(y,2),7307); % Seleciona amostras aleat�rias.
                    y = y(:,inds);
                    
                elseif strcmp(ext, 'form')
                    y = emo_5form_treino{k};
                    inds = randperm(size(y,2),3965); % Seleciona amostras aleat�rias.
                    y = y(:,inds);
                end
                
                % Determina os par�metros do GMM para uma emo��o.
                [p0n,cn,Sn,Ln] = gmm_em_2(y', K, 15, 0);
                
                % Agrupa os par�metros do GMM, cada emo��o em uma dimens�o diferente.
                p0 = cat(1,p0,p0n');
                L = cat(1,L,Ln);
                C = cat(3,C,cn);
                cov = cat(3,cov,Sn);
            end
        end
    end
end