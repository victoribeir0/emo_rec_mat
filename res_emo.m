%{
    Determina a matriz de resultados (NxM), n locuções e m emoções.
    C,p0,cov = Parâmetros do GMM (para cada emoção).
    rnn = VAD com rede neural (0 ou 1).
    ext = Tipo de extrator a ser usado ('mfcc', 'f0', etc.).

    res = Matriz de resultados.
%}

function res = res_emo(C,p0,cov,rnn,ext,dims)

folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2\dados\dados_75_25';
cd(folder);

if strcmp(ext, 'pro_jan')
    load('emo_pro_jan_teste');
    load('centros_pro_jan_64.mat');
    %load('mds_pro_16432');
    %load('mds_pro_16433');
    %load('mds_pro_16452');
    load('mds_pro_16453');

elseif strcmp(ext, 'mfcc')
    load('emo_mfcc_teste');
    
elseif strcmp(ext, 'lfpc-coef')
    load('emo_lfpc_teste');       
end

% Localização dos arquivos de áudio.
cd('C:\Users\victo\Documents\Dataset _ EmoDB2\wav\emos\Teste');
as = dir('*.wav');
N  = numel(as);

% Define o n° de emoções e o n° de locuções.
N_Emo = size(p0,1);
N_Loc = N;
res   = zeros(N_Loc,N_Emo); % Inicia a matriz de resultados.

ni = 1;
Sf = [];
a_coef = [];

warning('off','signal:findpeaks:largeMinPeakHeight'); % Desativa avisos.

% Emoções a serem procuradas.
emos = ['F','A','N','T','E','L','W'];

% Laço for para cada emoção.
for emo = 1:length(emos)
    
    % Localização dos arquivos de áudio.
    folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2\wav\emos\Teste';
    cd(folder);
    as = dir('*.wav');
    N = numel(as);
    
    % Laço para cada sinal.
    for n = 1:N
        
        str = as(n).name; % Define o nome do arquivo.
        em = str(6);      % Define a emoção do arquivo.
        
        % Caso a emoção seja a mesma que esta sendo pesquisada.
        if emos(emo) == em
            
            % Abre o arquivo de áudio e processa o áudio.
            folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2\wav\emos\Teste';
            cd(folder);
            dados = importdata(str);
            [MFCC,idx] = process(dados,rnn);
            
            % Caso o extrator seja mfcc:
            if strcmp(ext, 'mfcc')
                %dMFCC = dmfcc(MFCC,3);
                %MFCC = [MFCC; dMFCC];
                
                % y = MFCC; % Vetor de características mfcc.
                y = emo_mfcc_teste{emo,n};
            end
            
            % Caso o extrator seja f0:
            if (strcmp(ext, 'pro_jan') || strcmp(ext, 'pro_aud'))
                %y = ext_prosodia(dados, idx, ext);
                %emo_pro_jan_teste{emo,n} = y;
                y = emo_pro_jan_teste{emo,n};
                seq = get_clusters(y,centros);               
                y = [y; y_3(seq,dims)'];
            end
            
            if strcmp(ext, 'lfpc-env') || strcmp(ext, 'lpcc-coef')
                % Mat. LPCC e mat. da resp. em freq para cada janela analisada.
                formantes = get_formantes(dados.data,12,dados.fs);
                [mat_lpcc, mat_H] = get_lpcc_mat(dados.data, dados.fs, 40, 10, rnn, 12);
                mat_H = abs(mat_H);
                
                if strcmp(ext, 'lfpc-env')
%                     mat_H = log(mat_H(:,:));
%                     lpcc_lfpc = get_lfpc(mat_H, size(mat_H,1)*2, dados.fs, 12);
%                     dlpcc_lfpc = dmfcc(lpcc_lfpc,3);
%                     y = [lpcc_lfpc; dlpcc_lfpc]; % Vetor de características lpcc.
                    y = emo_lfpc_env_teste{emo,n};
                    
                elseif strcmp(ext, 'lpcc-coef')
                    %y = mat_lpcc; % Vetor de características lpcc.
                    y = emo_lpcc_teste{emo,n};
                end                

            end
            
            if strcmp(ext, 'lfpc-coef')
                %[S, L] = get_spec(dados.data, dados.fs, 40, 10, 0, 0);
                %LFPC = get_lfpc(S, L, dados.fs,12);
                %dLFPC = dmfcc(LFPC,3);
                %y = [LFPC; dLFPC];
                y = emo_lfpc_teste{emo,n};

            end
            
            if strcmp(ext, 'linfpc')
                %[S, L] = get_spec(dados.data, dados.fs, 40, 10, 0, 0);
                %LFPC = get_linfpc(S, 12);
                %dLFPC = dmfcc(LFPC,3);
                %y = [LFPC; dLFPC];
                y = emo_linfpc_12_teste{emo,n};
            end
            
            if ~isempty(y)
                
                % Laço para cada modelo GMM de emoção.
                % Para cada modelo, é calculada a verossimilhança 'a'.
                for mod = 1:N_Emo
                    [a,~] = gmm_t2(y',C(:,:,mod),p0(mod,:),cov(:,:,mod));
                    res(ni,mod) = a;
                end
                
            else
                res(ni,:) = [];
            end
            
            ni = ni+1; % Incrementa a locução.
        end
        
    end
    
end

res = res(1:ni-1,:);
[l,c] = find(res == -Inf);
res(l,c) = -500;
pos = isnan(res);
res(pos) = -500;

% [far,frr] = teste_loc(res,0.1);
end

%{
    Processa o sinal de voz para obter as janeças com voz.
    MFCC = Matriz MFCC.
    idx  = Janelas com voz.

    dados = Sinal de voz.
    rnn = VAD com rede neural (0 ou 1).
%}

function [MFCC,idx] = process(dados,rnn)

% Obtém a matriz do espectrograma.
[Spc, L] = get_spec(dados.data, dados.fs, 40, 10, 0, rnn);

% Obtém o MFCC.
MFCC = get_mfcc(Spc, L, dados.fs);

if rnn == 0 % Caso rnn não seja solicitado.
    lim = mean(MFCC(1,:));
    idx = find(MFCC(1,:) > lim);
    MFCC = MFCC(2:end,idx);
    
else % Caso rnn  seja solicitado.
    MFCC = MFCC(2:end,:);
    idx = 1:size(MFCC,2); % Nesse caso, todos os índices sao uteis.
end

end

function y = ext_prosodia(dados, idx, ext)
[~, f0, nrg, lognrg, jit_abs, ~, ~, shi_abs, ~, ~, mean_dif_picos] = get_global_contx(dados.data,idx,dados.fs,3);
[int_voz, ~] = get_times(nrg,1);            
y1 = [f0'; jit_abs; shi_abs; mean_dif_picos; lognrg];

if strcmp(ext, 'pro_aud')     % Características por áudios.
    % [vet, ~] = get_com_feat(y1,3);
    y = [sum(int_voz); mean(f0); mean(jit_abs); mean(shi_abs); mean(mean_dif_picos)];

elseif strcmp(ext, 'pro_jan') % Características por janelas. 
    y = y1;
    
elseif strcmp(ext, 'all') % Características por janelas.     
    dy1 = dmfcc(y1,3);    % Primeira a segunda derivada.
    dy2 = dmfcc(dy1,3);    
    y = [y1; dy1; dy2];    
end  
end