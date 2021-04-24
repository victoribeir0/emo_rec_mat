%{
    Determina a matriz de resultados (NxM), n locuções e m emoções.
    C,p0,cov = Parâmetros do GMM (para cada emoção).
    rnn = VAD com rede neural (0 ou 1).
    ext = Tipo de extrator a ser usado ('mfcc', 'f0', etc.).

    res = Matriz de resultados.
%}

function res = res_emo(C,p0,cov,rnn,ext)

% Localização dos arquivos de áudio.
cd('C:\Users\victo\Documents\Dataset _ EmoDB2\wav\teste');
as = dir('*.wav');
N  = numel(as);

% Define o n° de emoções e o n° de locuções.
N_Emo = size(p0,1);
N_Loc = N;
res   = zeros(N_Loc,N_Emo); % Inicia a matriz de resultados.

ni = 1;
Sf = [];
a_coef = [];

% Emoções a serem procuradas.
% emos = ['W';'L';'A';'F';'T';'N'];
emos = ['W';'T'];

% Laço for para cada emoção.
for emo = 1:length(emos)
    
    % Localização dos arquivos de áudio.
    folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2\wav\teste';
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
            dados = importdata(str);
            [MFCC,idx] = process(dados,rnn);
            
            % Caso o extrator seja mfcc:
            if strcmp(ext, 'mfcc')
                dMFCC = dmfcc(MFCC,3);
                MFCC = [MFCC; dMFCC];
                
                y = MFCC; % Vetor de características mfcc.
            end
            
            % Caso o extrator seja f0:
            if strcmp(ext, 'f0')
                [~, m_f0, nrg, jit_abs, ~, jit_x, shi_abs, shi_rel, amp_std, amp_x, mean_dif_picos] = get_global(dados.data,idx,dados.fs);
                [int_voz, ~] = get_times(nrg,1);
                
                % Vetor de características temporais.
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
            
            % Laço para cada modelo GMM de emoção.
            % Para cada modelo, é calculada a verossimilhança 'a'.
            for mod = 1:N_Emo
                [a,~] = gmm_t2(y',C(:,:,mod),p0(mod,:),cov(:,:,mod));
                res(ni,mod) = a;
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
