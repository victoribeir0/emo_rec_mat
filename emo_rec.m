function varargout = emo_rec(varargin)
% EMO_REC MATLAB code for emo_rec.fig
%      EMO_REC, by itself, creates a new EMO_REC or raises the existing
%      singleton*.
%
%      H = EMO_REC returns the handle to a new EMO_REC or the handle to
%      the existing singleton*.
%
%      EMO_REC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMO_REC.M with the given input arguments.
%
%      EMO_REC('Property','Value',...) creates a new EMO_REC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before emo_rec_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to emo_rec_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help emo_rec

% Last Modified by GUIDE v2.5 22-Oct-2021 17:00:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @emo_rec_OpeningFcn, ...
    'gui_OutputFcn',  @emo_rec_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

cd('C:\Users\victo\Documents\Dataset _ EmoDB2\wav\emos\Treino');

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before emo_rec is made visible.
function emo_rec_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to emo_rec (see VARARGIN)

% Choose default command line output for emo_rec
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes emo_rec wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = emo_rec_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function Abrir__Callback(hObject, eventdata, handles)
% hObject    handle to Abrir_ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

switch hObject.Value
    case 1
        ext = 'pro_jan';
    case 2
        ext = 'pro_aud';
    case 3
        ext = 'lfpc-coef';
    case 4
        ext = 'mfcc';
end

set(handles.popupmenu1, 'UserData', ext);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Abrir_treino.
function Abrir_treino_Callback(hObject, eventdata, handles)


path1 = uigetdir;
set(handles.Abrir_treino, 'UserData', path1);

% --- Executes on button press in Abrir_teste.
function Abrir_teste_Callback(hObject, eventdata, handles)
path2 = uigetdir;
set(handles.Abrir_teste, 'UserData', path2);

% --- Executes on button press in Iniciar.
function Iniciar_Callback(hObject, eventdata, handles)

ext = get(handles.popupmenu1, 'UserData');
path_treino = get(handles.Abrir_treino, 'UserData');
num_gaussianas = str2double(get(handles.num_gauss_text, 'String'));
semantic = get(handles.semantic_sel, 'UserData');
num_rep = str2double(get(handles.rep_text, 'String'));

tic;
fprintf('Carregando (0/%d)', num_rep);
fprintf('\n');

for k = 1:num_rep
    [p0,C,cov,L,dims] = get_emo_gmm(num_gaussianas,ext,semantic);
    res = res_emo(C,p0,cov,ext,semantic,dims);
    erro(k) = 100*emo_teste(res);  
    
    fprintf('Carregando (%d/%d)',k,num_rep); 
    fprintf('\n')
end
disp(mean(erro));
disp(std(erro));
toc;

texto = [num2str(mean(erro)) ' %'];
set(handles.erro_res, 'String', texto);

texto = [num2str(std(erro)) ' %'];
set(handles.desv_pad, 'String', texto);

cla(handles.verosim_plot,'reset');
axes(handles.verosim_plot);
for i = 1:size(L,1)
    plot(L(i,:)); hold on
end
grid on;
title('Verossimilhança (Treino)');
xlabel('Iteração');
ylabel('Verossimilhança');

cla(handles.res_plot,'reset');
axes(handles.res_plot);
imagesc(res);
title('Matriz de resultados (Teste)');
xlabel('Emoção');
ylabel('Arquivo de voz');

function num_gauss_text_Callback(hObject, eventdata, handles)
% hObject    handle to num_gauss_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_gauss_text as text
%        str2double(get(hObject,'String')) returns contents of num_gauss_text as a double

% --- Executes during object creation, after setting all properties.
function num_gauss_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_gauss_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%{
        Extrai informações dos sinais de voz.
        emo = Emoção a ser procurada.
        rnn = VAD com rede neural (0 ou 1).
        ext = Tipo de extrator a ser usado ('mfcc', 'f0', 'lpcc', etc.).

        base = Características coletadas de todos os sinais de uma determinada emoção.
%}

function base = get_emo_feats(emo,ext,folder)
% Localização dos arquivos de áudio.

% folder = ['C:\Users\victo\Documents\Dataset _ EmoDB2\wav\emos\' pasta];
cd(folder);
as = dir('*.wav');
N = numel(as);

% Inicialização para cada tipo de extrator ('mfcc', 'f0', etc.).
base = [];
warning('off','signal:findpeaks:largeMinPeakHeight'); % Desativa avisos.

% Laço para cada sinal.
for n = 1:N
    str = as(n).name; % Define o nome do arquivo.
    em = str(6);      % Define a emoção do arquivo.
    
    % Caso a emoção seja a mesma que esta sendo pesquisada.
    if emo == em
        
        % Localização dos arquivos de áudio.
        % folder = ['C:\Users\victo\Documents\Dataset _ EmoDB2\wav\emos\' pasta];
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
        
        % Incrementa a base com as informações de cada sinal.
        base = [base y];
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

function y = ext_lpcc(dados, idx, ext, rnn)

% Mat. LPCC e mat. da resp. em freq para cada janela analisada.
[mat_lpcc, mat_H, formantes] = get_lpcc_mat(dados.data, dados.fs, 40, 10, rnn, 12);
mat_H = abs(mat_H);

if strcmp(ext, 'lfpc-env')
    % Matrizes somente com as janelas com voz (idx).
    mat_H = log(mat_H(:,:));
    lpcc_lfpc = get_lfpc(mat_H, size(mat_H,1)*2, dados.fs, 12);
    dlpcc_lfpc = dmfcc(lpcc_lfpc,3);
    y = [lpcc_lfpc; dlpcc_lfpc]; % Vetor de características lpcc.
    
elseif strcmp(ext, 'lpcc-coef')
    mat_lpcc = mat_lpcc(:,idx);
    y = mat_lpcc; % Vetor de características lpcc.
    
elseif strcmp(ext, 'formantes')
    y_temp = formantes(idx); % Vetor de características lpcc.
    tam = length(y_temp{1});
    y_temp = cell2mat(y_temp);
    y = reshape(y_temp,length(idx),tam); % 5 Núm. de formantes.
    y = y(:,1:5)';
end

% Obtém o modelo GMM para cada emoção.
% K = Número de centros (gaussianas) para o GMM.
% ext = Tipo de extrator a ser usado ('mfcc', 'f0', etc.).
% rnn = VAD com rede neural (0 ou 1).
% [p0,c,S,L] = Parâmetros do GMM (para cada emoção).

function [p0,C,cov,L,dims] = get_emo_gmm(K,ext,semantic)

folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2\dados\dados_75_25';
cd(folder);

load('emo_lfpc_treino.mat');
load('emo_pro_jan_treino.mat');
load('centros_pro_jan_64.mat');
if ~strcmp(semantic, 'Nenhum');
    load(semantic);
end

dims = [];

% load('emo_f0_aud_treino.mat');

% Inicalização dos parâmetros do GMM (para cada emoção).
C = []; cov = []; p0 = []; L = [];

% Emoções a serem procuradas.
emos = ['F','A','N','T','E','L','W'];

% Laço for para cada emoção.
for k = 1:length(emos)
    
    % Extrai as características para cada emoção.
    % emoção, vad-rnn (1 ou 0), extrator ('mfcc', 'f0', ...).
    % y = get_emo_feats(emos(k),rnn,ext,'treino');
    if strcmp(ext, 'pro_jan')
        y = emo_pro_jan_treino{k};
        seq = get_clusters(y,centros);
        
        if ~strcmp(semantic, 'Nenhum');
            dims = get_otm_dims(emo_pro_jan_treino, centros, y_3);                        
            y = [y; y_3(seq,dims)'];
        end
        
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
        inds = randperm(size(y,2),3965); % Seleciona amostras aleatórias.
        y = y(:,inds);
        
    elseif strcmp(ext, 'lpcc-coef')
        y = emo_lpcc_treino{k};
        inds = randperm(size(y,2),3965); % Seleciona amostras aleatórias.
        y = y(:,inds);
        
    elseif strcmp(ext, 'linfpc')
        y = emo_linfpc_12_treino{k};
        inds = randperm(size(y,2),7307); % Seleciona amostras aleatórias.
        y = y(:,inds);
        
    elseif strcmp(ext, 'form')
        y = emo_5form_treino{k};
        inds = randperm(size(y,2),3965); % Seleciona amostras aleatórias.
        y = y(:,inds);
    end
    
    % Determina os parâmetros do GMM para uma emoção.
    [p0n,cn,Sn,Ln] = gmm_em(y', K, 10, 0);
    
    % Agrupa os parâmetros do GMM, cada emoção em uma dimensão diferente.
    p0 = cat(1,p0,p0n');
    L = cat(1,L,Ln);
    C = cat(3,C,cn);
    cov = cat(3,cov,Sn);
end


% --- Executes on button press in iniciar_teste.
function iniciar_teste_Callback(hObject, eventdata, handles)
% hObject    handle to iniciar_teste (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%{
    Determina a matriz de resultados (NxM), n locuções e m emoções.
    C,p0,cov = Parâmetros do GMM (para cada emoção).
    rnn = VAD com rede neural (0 ou 1).
    ext = Tipo de extrator a ser usado ('mfcc', 'f0', etc.).

    res = Matriz de resultados.
%}

function res = res_emo(C,p0,cov,ext,semantic,dims)

rnn = 0;
folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2\dados\dados_75_25';
cd(folder);

if strcmp(ext, 'pro_jan')
    load('emo_pro_jan_teste');
    load('centros_pro_jan_64.mat');
    if ~strcmp(semantic, 'Nenhum');
        load(semantic);
    end

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
                
                if ~strcmp(semantic, 'Nenhum');
                    y = [y; y_3(seq,dims)'];
                end
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

function erro = emo_teste(res)

% Número de vozes para cada emoção.
rot = [18 17 20 15 11 20 20];

% Inicializa variáveis.
ind = 1;
rot_vet = [];

% Cria o vetor de rótulos.
for n = 1:length(rot)
    rot_vet = [rot_vet ind*ones(1,rot(n))];
    ind = ind+1;
end

tam = min(res(:)):1:max(res(:));
fp = zeros(1,size(res,1));
fn = zeros(1,size(res,1));
idx = 1;

for lim = tam
    for lin = 1:size(res,1)
        
        ind = find(res(lin,:) >= lim);
        
        if any(ind ~= rot_vet(lin))
            % Soma todas as falsas aceitações.
            fp(lin) = sum(ind ~= rot_vet(lin)); % Falso positivo (falsa aceitação).            
        end
        
        ind = find(res(lin,:) <= lim);
        
        if any(ind == rot_vet(lin))
            fn(lin) = 1; % Falso negativo (falsa rejeição).
        end          
    end
    
    fpr(idx) = sum(fp/(size(res,2)-1))/size(res,1);
    fnr(idx) = sum(fn)/size(res,1);
    fp = zeros(1,size(res,1));
    fn = zeros(1,size(res,1));
    idx = idx+1;
    
end

% plot(tam,fpr,'r'); hold on; plot(tam,fnr,'b'); grid on; xlabel('Limite'); ylabel('Erro (%)');
    
[~, pos] = min(abs(fpr-fnr));
erro = mean([fpr(pos) fnr(pos)]);


% --- Executes on selection change in semantic_sel.
function semantic_sel_Callback(hObject, eventdata, handles)

switch hObject.Value
    case 1
        sel = 'mds_pro_16453';
    case 2
        sel = 'glo_pro_16432';
    case 3
        sel = 'glo_pro_16432';
    case 4 
        sel = 'Nenhum';
end

set(handles.semantic_sel, 'UserData', sel);

% --- Executes during object creation, after setting all properties.
function semantic_sel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to semantic_sel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%{
    Determina o modelo do GMM para um conjunto de dados X.
    X = Dados. (N° observações x N° de carac.)
    K = N° de centros (gaussianas).
    Ite = N° de iterações. 
    
    P0 = Vetor de probabilidade de cada gaussiana.
    C = Posição dos centros.
    S = Diagonais das matrizes de covariância.
    L = Verossimilhança. 
%}

function [P0,C,S,L] = gmm_em(X, K, Ite, plotimg)

% Inicialização de parâmetros:
[N,Dim] = size(X); % N = num. dados, Dim = Dimensão.

% Inicializa os centros aleatoriamente (C).
idx = randperm(N,K);
C = X(idx,:);

% Inicializa a matriz de covariância (S).
S_ini = X-(ones(N,1)*mean(X,1)); % Subtrai X das médias de cada coluna da mat. X.
S_ini = (S_ini'*S_ini)/(N-1);    % Obtém a mini covariância.
S_ini = diag(S_ini)';            % Obtém a diagonal da mat. de cov.

% S = zeros(size(Dim)); 
% P0 = zeros(1,K);
valMin = min(abs((S_ini(abs(S_ini)>0)))); % Encontra o menor valor absoluto.
S_ini(S_ini==0) = valMin; % Caso haja um zero no vetor S_ini, esse zero é substituído por valMin
invRini = S_ini.^(-1);    % Inverso do vetor S_ini (diag. da mat. de cov.).

S = ones(K,1)*S_ini;  % Inicializa mat. de cov;
P0 = (1/K)*ones(K,1); % Inicializa o vetor de pesos das gaussianas.

% Laço EM:
for i=1:Ite % Troquei uma condicão de parada por Niter iterações
    P = zeros(K,N); % Inicializa a matriz de probabilidades P.
    
    % Para acelerar o processamento no Matlab, o duplo laço deve ser substituído
    % pelas operações matriciais seguintes:
    A = X';
    for k = 1:K
        B = C(k,:)';
        pos = find(S(k,:) == 0);
        S(k,pos) = valMin;   % Casa haja um zero no vetor R, esse zero é substituído por valMin
        invR = S(k,:).^(-1); % Calcula a inversa da diagonal da mat. cov.
        meioR = invR.^(1/2); % Calcula a meia inversa da diagonal da mat. cov.
        
        % Obs: O det. da mat. cov. é calculado usando o vetor da diagonal.
        % log(a*b*c*...*n) = log(a) + log(b) + log(c) + ... + log(n)
        % (a*b*c*...*n) = exp(log(a*b*c*...*n))
        % O real é devido a: log de num. < 0 retorna complexo.
        detR = real(exp(sum(log(S(k,:))))); % Calcula o determinante da mat. cov.
          
        % Calculo da dist. de Mahalanobis:  
        % Aqui é usada a meia cov., esta deforma o espaço dos dados para calcular a dist.
        A2 = sum(((meioR'*ones(1,N)).*A).^2,1); % Dados X.
        B2 = sum((meioR'.*B).^2,1);             % Centros C.
        
        pAB = (A'.*(ones(N,1)*invR))*B;
        dm2 = (A2'*ones(1,size(B,2)) + ones(size(A,2),1)*B2 - 2*pAB);
        dm2 = dm2'; % Converte em vetor linha de distâncias.
        denominador = (2*pi)^(Dim/2)*detR^(1/2);
        
        % Calcula as probabilidades de cada observação(n) pertencer a um centro(k).
        if denominador > 0 % Atenção: outra gambiarra!
            P(k,:) = P0(k)*(1/denominador)*exp(-0.5*dm2);
        end
    end
    
    % Como vamos usar Log, devemos testar os argumentos para que sejam sempre positivos:
    somaColunasP = sum(P,1);
    pos = find(somaColunasP>0);
    L(i) = sum(log(somaColunasP(pos)))/length(pos);    
    
    P = P./(ones(K,1)*sum(P,1));
    
    % Atualizando os aprioris:
    P0 = sum(P,2);
    
    % Outra gambiarra:
    pos = find(P0==0);
    P0(pos) = 0.00000001;
    P0=P0/sum(P0);
    
    % Versão acelerada (no Scilab) do laço for acima:
    pos=find(P==0);
    P(pos)=10^(-9); % Gambiarra para evitar nulos por truncamento numérico na matriz P
    Pesos=P./(sum(P,2)*ones(1,N));
    C=Pesos*X;
    
    % Atualizando as matrizes de covariância:
    R_velho=S; % Guarda uma cópia de matrizes supostamente bem condicionadas, para o caso de problemas de condicionamento após atualização
    for k=1:K
        
        % Outra gambiarra:
        sumLinhaP = sum(P(k,:));
        if sumLinhaP == 0
            sumLinhaP = 0.00000001;
        end
        
        Pesos = P(k,:)/sumLinhaP;
        B = X-ones(N,1)*C(k,:);
        A = (B').*(ones(Dim,1)*Pesos);
        Raux = A*B;
        Raux=diag(Raux);
                        
        if min(abs(Raux)) < 0.00000001
            S(k,:) = R_velho(k,:);
        else
            S(k,:) = Raux';
        end        
    end    
end

if plotimg
    subplot(211);
    plot(L); title('Verossimilhança'); grid on;
    
    subplot(212);
    plot(X(:,1),X(:,2),'k*'); hold on;
    plot(C(:,1),C(:,2),'bo'); grid on;
    
    for k = 1:K
        ss = repmat(S(k,:),2,1);
        ss = ss.*eye(2);
        plot_iso(C(k,:),ss)
    end
    
end

function plot_iso(cen,S)
a = 0:0.1:(2*pi)+0.1;
%S = repmat(S,length(S),1).*eye(length(S));
x = (S.^(1/2))*[cos(a); sin(a)];
cen = cen(:);
x = x+(cen*ones(1,length(a)));
plot(x(1,:),x(2,:),'r');



function rep_text_Callback(hObject, eventdata, handles)
% hObject    handle to rep_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rep_text as text
%        str2double(get(hObject,'String')) returns contents of rep_text as a double


% --- Executes during object creation, after setting all properties.
function rep_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rep_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
