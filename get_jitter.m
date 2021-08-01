%{
    Calcula o jitter s shimmer do sinal x.
    x = Sinal de entrada.
    Tjan = Tempo de cada janela em ms.
    inds = Janelas a serem utilizados.
    Fs = Freq. de amostragem.
    mean_F0 = M�dia do F0, usado nos crit�rios de sele��o.

    jit_abs = Jitter absoluto;    jit_rel = Jitter relativo.
    jit_sinal = Jitter do sinal.
    shim_abs = Shimmer absoluto;  shim_rel = Shimmer relativo.
    amp_std = Desv. pad. das amplitudes dos per�odos em uma janela.
    amp_x = Amplitudes dos per�odos para todo o sinal.
%}

function [jit_abs, jit_rel, jit_sinal, shim_abs, shim_rel, amp_std, amp_x] = get_jitter(x, Tjan, inds, Fs, mean_F0)

Njan = round((Tjan/1000)*Fs); % Num. de amostras em cada janela.
NAv = round((10/1000)*Fs);    % Num. de amostras para o avan�o (sobreposi��o).

T0 = [];                          % Inicializa��o T0 (vetor de per�odos).
jit_abs = zeros(1,length(inds));  % Inicializa��o vetor de jit. abs.
jit_rel = zeros(1,length(inds));  % Inicializa��o vetor de jit. rel.
shim_abs = zeros(1,length(inds)); % Inicializa��o vetor de shi. abs.
shim_rel = zeros(1,length(inds)); % Inicializa��o vetor de shi. rel.
amp_x = [];
amp_std = [];

for i = 1:length(inds) % La�o for para cada janela espec�fica.
    
    aux = inds(i); % Define a janela espec�fica.
    ap = ((aux-1)*NAv)+1;
    a = x(ap:ap+Njan-1);
    a = a-mean(a); % Remove o n�vel DC subtraindo pela m�dia.
    
    % Filtro FIR passa-baixas, fc = 500 Hz, ordem = 200.
    h = fir1(200,(500*2)/Fs); % Coeficientes
    filt = conv(a,h);         % Sinal filtrado.
    mn = min(filt)*0.5; mx = max(filt)*0.5; % Limites para detec��o dos picos.   
    
    [amp_max,loc_max] = findpeaks(filt,'MinPeakHeight',mx); % Obt�m as posi��es dos picos.
    T0_prev = diff(loc_max);                                % Obt�m as diferen�as, per�odo previsto.
    
    % Crit�rio para sele��o baseado na m�dia do F0 obtido.
    idx = (T0_prev<(Fs/mean_F0)+30 & T0_prev>(Fs/mean_F0)-30);
    T0_prev = T0_prev(idx);
    
    [shim_abs(i), shim_rel(i), amp_x_prev, amp_std_prev] = get_shimmer(filt, idx, loc_max, amp_max, mean_F0, Fs);
    amp_std = [amp_std amp_std_prev];  % Desvio pad. das amp. pico a pico da janela.
    amp_x = [amp_x amp_x_prev];        % Guarda as amp. pico a pico da janela.        
    
    F0_prev = Fs./T0_prev;
    
    % Crit�rio para sele��o baseado na m�dia do F0 obtido.
    idx = (F0_prev<mean_F0+30 & F0_prev>mean_F0-30);
    T0_prev = T0_prev(idx);
    
    jit_abs(i) = sum(abs(diff(T0_prev)))/length(T0_prev); % Jitter absoluto.
    jit_rel(i) = 100*(jit_abs(i)/mean(T0_prev));          % Jitter relativo.
    
    T0 = [T0 T0_prev']; % Guarda todos os per�odos do sinal x.
    
end

idx_nan = ~isnan(jit_abs);     % Remove os NaN, caso haja.
jit_abs = jit_abs(idx_nan);

idx_nan = ~isnan(jit_rel);     % Remove os NaN, caso haja.
jit_rel = jit_rel(idx_nan);

idx_nan = ~isnan(shim_rel);    % Remove os NaN, caso haja.
shim_rel = shim_rel(idx_nan);

idx_nan = ~isnan(shim_abs);    % Remove os NaN, caso haja.
shim_abs = shim_abs(idx_nan);

idx_nan = ~isnan(amp_std);     % Remove os NaN, caso haja.
amp_std = amp_std(idx_nan);

idx_nan = ~isnan(amp_x);       % Remove os NaN, caso haja.
amp_x = amp_x(idx_nan);

% Calula o jitter para todos os T0 do sinal.
jit_sinal = sum(abs(diff(T0)))/length(T0);

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
function [shim_abs, shim_rel, amp_x, amp_std] = get_shimmer(x, idx, loc_max, amp_max, mean_F0, Fs)

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
    sinal_cut = zeros(length(loc_max),(round(T0_med/2)*2)+1);
    % loc_min = zeros(1,length(loc_max));
    amp_min = zeros(1,length(loc_max));
    
    for n = 1:length(loc_max)
        ini = loc_max(n)-T; fim = loc_max(n)+T;
        sinal_cut(n,:) = [x(ini:loc_max(n)-1)' x(loc_max(n):fim)'];
        mx_rel = max(-sinal_cut(n,:))*0.5;
        [amp_min_prev, ~] = findpeaks(-sinal_cut(n,:),'MinPeakHeight',mx_rel);
        
        if isempty(amp_min_prev)
            amp_min(n) = 0;
        else
            amp_min(n) = max(amp_min_prev);
        end
        
        %loc_min(n) = max(loc_min_prev);
        %y(n) = re_scale(loc_min(n),(1:size(sinal_cut,2)),(ini:fim));
    end
    
    amp_prev = amp_max'+amp_min;
    mdn = median(amp_prev);
    amp_prev = amp_prev(amp_prev<mdn+mdn/3 & amp_prev>mdn-mdn/3);
    amp_std = std(amp_prev);   % Desvio pad. das amp. pico a pico da janela.
    amp_x = amp_prev;          % Guarda as amp. pico a pico de todo o sinal.
    
    shim_abs = sum(abs(diff(amp_prev)))/length(amp_prev);
    shim_rel = 100*(shim_abs/mean(amp_prev));
    
else
    shim_abs = NaN;
    shim_rel = NaN;
    amp_x    = NaN;
    amp_std  = NaN;
end

end