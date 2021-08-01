%{
    Calcula o jitter s shimmer do sinal x.
    x = Sinal de entrada                |    Tjan = Tempo de cada janela em ms.
    inds = Janelas a serem utilizados.  |    Fs = Freq. de amostragem.
    mean_F0 = M�dia do F0, usado nos crit�rios de sele��o.

    jit_abs = Jitter absoluto           |    jit_rel = Jitter relativo.
    jit_sinal = Jitter do sinal.
    shim_abs = Shimmer absoluto         |    shim_rel = Shimmer relativo.
    amp_std = Desv. pad. das amplitudes dos per�odos em uma janela.
    amp_x = Amplitudes dos per�odos para todo o sinal.
%}

function [jit_abs, jit_rel, jit_sinal, shim_abs, shim_rel, amp_std, mean_dif_picos, idx_nan] = get_quali_contx(x, Tjan, inds, Fs, mean_F0)

Njan = round((Tjan/1000)*Fs);      % Num. de amostras em cada janela.
NAv  = round((10/1000)*Fs);        % Num. de amostras para o avan�o (sobreposi��o).
                       
jit_abs  = zeros(1,length(inds)); jit_rel  = zeros(1,length(inds));  
shim_abs = zeros(1,length(inds)); shim_rel = zeros(1,length(inds)); 
amp_std  = zeros(1,length(inds)); mean_dif_picos = zeros(1,length(inds));
amp_x    = [];
T0       = [];   

for i = 1:length(inds)  % La�o for para cada janela espec�fica.
    
    aux = inds(i);  % Define a janela espec�fica.
    ap = ((aux-1)*NAv)+1;
    a = x(ap:ap+Njan-1);
    a = a-mean(a);  % Remove o n�vel DC subtraindo pela m�dia.
    
    % Filtro FIR passa-baixas, fc = 500 Hz, ordem = 200.
    h = fir1(200,(500*2)/Fs);  % Coeficientes
    filt = conv(a,h);          % Sinal filtrado.
    h = fir1(200, (100*2)/Fs, 'high');
    filt = conv(filt,h);
    mn = min(filt)*0.5; mx = max(filt)*0.5;  % Limites para detec��o dos picos.   
    
    [jit_abs(i), jit_rel(i), T0_prev, amp_max, idx_T0, loc_max] = get_jitter(filt, mx, Fs, mean_F0);
    % [jit_abs(i), jit_rel(i), T0_prev, amp_max, idx_T0, loc_max] = get_jitter(filt, mx, Fs, mean_F0);
    T0 = [T0 T0_prev]; % Guarda todos os per�odos do sinal x.
        
    [shim_abs(i), shim_rel(i), amp_x_prev, amp_std(i), mean_dif_picos(i)] = get_shimmer(filt, idx_T0, loc_max, amp_max, mean_F0, Fs);
    amp_x = [amp_x amp_x_prev];        % Guarda as amp. pico a pico da janela.        
        
end

% idx_nan_1 = ~isnan(jit_abs);     % Remove os NaN, caso haja.
% idx_nan_2 = ~isnan(jit_rel);     % Remove os NaN, caso haja.
% idx_nan_3 = ~isnan(shim_rel);    % Remove os NaN, caso haja.
% idx_nan_4 = ~isnan(shim_abs);    % Remove os NaN, caso haja.
% idx_nan_5 = ~isnan(amp_std);     % Remove os NaN, caso haja.
% idx_nan_6 = ~isnan(amp_x);       % Remove os NaN, caso haja.
% idx_nan_7 = ~isnan(mean_dif_picos);       % Remove os NaN, caso haja.

idx_nan = find(~isnan(jit_abs) == 1 & ~isnan(jit_rel) == 1 & ~isnan(shim_rel) == 1 & ~isnan(shim_abs) == 1 & ...
               ~isnan(amp_std) == 1 & ~isnan(mean_dif_picos) == 1);

jit_abs = jit_abs(idx_nan);
jit_rel = jit_rel(idx_nan);
shim_rel = shim_rel(idx_nan);
shim_abs = shim_abs(idx_nan);
amp_std = amp_std(idx_nan);
% amp_x = amp_x(idx_nan);
mean_dif_picos = mean_dif_picos(idx_nan);

% Calula o jitter para todos os T0 do sinal.
jit_sinal = sum(abs(diff(T0)))/length(T0);

end

%{ 
    Fun��o para determinar o Jitter. 
    x = Janela de voz;                        |  mean_F0 = M�dia do F0;
    mx = Limite m�nimo para o pico;           |  Fs = Freq. Amostragem;  
    
    jit_abs = Shim. absoluto;                 |  jit_rel = Shim. relativo.
    T0 = Per�odos obtidos na janela;          |  amp_max = Amp. dos picos; 
    idx_T0 = �ndices l�gicos para o per�odos  |  loc_max = Loc. dos picos.
    
%}
function [jit_abs, jit_rel, T0, amp_max, idx_T0, loc_max] = get_jitter(x, mx, Fs, mean_F0)
    
    T0 = [];
    [amp_max, loc_max] = findpeaks(x,'MinPeakHeight',mx);   % Obt�m as posi��es dos picos.
    T0_prev = diff(loc_max);                                % Obt�m as diferen�as, per�odo previsto.
    
    % Crit�rio para sele��o baseado na m�dia do F0 obtido.
    idx_T0 = (T0_prev<(Fs/mean_F0)+30 & T0_prev>(Fs/mean_F0)-30);
    T0_prev = T0_prev(idx_T0);           
    
    F0_prev = Fs./T0_prev;
    
    % Crit�rio para sele��o baseado na m�dia do F0 obtido.
    idx_F0 = (F0_prev<mean_F0+30 & F0_prev>mean_F0-30);
    T0_prev = T0_prev(idx_F0);
    
    jit_abs = sum(abs(diff(T0_prev)))/length(T0_prev); % Jitter absoluto.
    jit_rel = 100*(jit_abs/mean(T0_prev));             % Jitter relativo.
    
    T0 = [T0 T0_prev']; % Guarda todos os per�odos do sinal x.
end

%{ 
    Fun��o para determinar o Shimmer. 
    idx = Vator l�gico dos per�odos;     |    loc_max = Loc. dos valores m�ximos.
    amp_max = Amp. dos valores m�ximos;  |    mean_F0 = M�dia do F0;
    Fs = Freq. Amostragem;               |    filt = Sinal fitrado.
    
    shim_abs = Shim. absoluto;           |    shim_rel = Shim. relativo.
    amp_x = Amp. dos per�odos de todas as janelas; 
    amp_std = Desv. pad. dos per�odos dentro de uma janela.    
%}
function [shim_abs, shim_rel, amp_prev, amp_std, mean_dif_picos] = get_shimmer(x, idx, loc_max, amp_max, mean_F0, Fs)

if ~isempty(idx)
    
    % Avalia os picos, remove picos fora do comum baseado do idx.
    idxn = [idx(1); idx];        % Vetor l�gico dos per�odos, com o 1� termo repetido.
    loc = zeros(1,length(idxn)); % Vetor l�gico de localiza��o dos picos.
    
    for n = 1:length(idxn)
        
        % Se n = 1 ou �ltimo, mantem o mesmo valor l�gico de idxn.
        if n == 1 || n == length(idxn)
            loc(n) = idxn(n);
        else
            
        % Caso n ~= de 1, testa se h� valor l�gico 1 no idxn(n) ou no idxn(n+1)
            if idxn(n) == 1 || idxn(n+1) == 1
                loc(n) = 1;
            end
        end
    end
        
    loc_max = loc_max(logical(loc')); % Atualiza as loc. dos m�ximos.
    amp_max = amp_max(logical(loc')); % Atualiza as amp. dos m�ximos.
    
    T0_med = round(Fs/mean_F0);       % Per�odo m�dio, baseado no F0 m�dio.
    
    T = round(T0_med/2);
    % sinal_cut = zeros(1,(round(T0_med/2)*2)+1);
    loc_min = zeros(1,length(loc_max));
    amp_min = zeros(1,length(loc_max));
    
    for n = 1:length(loc_max)
        ini = loc_max(n)-T; fim = loc_max(n)+T;
        sinal_cut = [x(ini:loc_max(n)-1)' x(loc_max(n):fim)'];
        mx_rel = max(-sinal_cut)*0.5;
        [amp_min_prev, loc_min_prev] = findpeaks(-sinal_cut,'MinPeakHeight',mx_rel);
        
        if isempty(amp_min_prev)
            amp_min(n) = 0;
            loc_min(n) = 0;
        else
            amp_min(n) = max(amp_min_prev);
            loc_min(n) = max(loc_min_prev);
        end
        
        % loc_min_prev = max(loc_min_prev);
        loc_min(n) = re_scale(loc_min(n),(1:size(sinal_cut,2)),(ini:fim));
    end
    
    amp_prev = amp_max'+amp_min; % Amplitde pico a pico, max(x)-min(x).
    mdn = median(amp_prev);      % Mediana para o crit�rio de sele��o.
    amp_prev = amp_prev(amp_prev<mdn+mdn/3 & amp_prev>mdn-mdn/3); % Crit�rio de sele��o.
    amp_std  = std(amp_prev);    % Desvio pad. das amp. pico a pico da janela.    
    
    shim_abs = sum(abs(diff(amp_prev)))/length(amp_prev); % Shim. absoluto.
    shim_rel = 100*(shim_abs/mean(amp_prev));             % Shim. relativo
    
    dif_picos = abs(loc_max-loc_min');
    mdn = median(dif_picos);
    dif_picos = dif_picos(dif_picos<mdn+mdn/2 & dif_picos>mdn-mdn/2);
    mean_dif_picos = mean(dif_picos);
    
else
    shim_abs = NaN;
    shim_rel = NaN;
    amp_prev = NaN;
    amp_std  = NaN;
    mean_dif_picos = NaN;
end

end