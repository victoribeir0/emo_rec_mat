% Determina os coeficientes LPC (linear predictive coding)
% x = Sinal de entrada.
% P = Ordem do modelo.
% coefs = Coeficientes LPC.

% Baseado no algoritmo de Levinson–Durbin.

function coefs = get_lpcc(x,P,Fs)

r = zeros(1,P+1); % Autocorrelação
r(1) = sum(x.^2); % Energia do sinal

for k = 1:P % Autocorrelação para cada P.
    r(k+1) = auto_lpc(x,k);
end

e = zeros(1,P+1); % Erro
k = zeros(1,P+1); % Coeficientes LPC na i-ésima iteração
a = zeros(P+1,P+1); % Coeficientes LPC finais

e(1) = r(1);
soma = 0;

% Algoritmo de Levinson–Durbin.
for p = 2:P+1
    
    for j = 1:p-2
        soma = (a(p-1,j+1) * r(p-j)) + soma;
    end
    
    k(p) = (r(p) - soma)/e(p-1);
    soma = 0;
    
    a(p,p) = k(p);
    
    if p > 2
        for j = 1:p-2
            a(p,j+1) = a(p-1,j+1) - (k(p)*a(p-1,p-j));
        end
    end
    
    e(p) = (1-(k(p)^2))*e(p-1);
end

coefs = [1 -a(end,2:end)]; % Obtenção dos coeficientes.

% Tranformada de Fourier do sinal.
fft_x = fft2(x,Fs);

escalahz = Fs*(0:length(x)/2)/length(x); % Escala em Hz.

% Resposta em frequência dos coeficientes.
[H,F] = freqz(1,coefs,length(fft_x),16000);

subplot(211); % Plota o sinal de entrada.
plot(x,'r'); grid on; title('x');

subplot(212); % Plota o espectro do sinal de entrada e o espectro LPC.
plot(escalahz,log(fft_x)-mean(log(fft_x)),'r'); hold on; plot(F,log(abs(H)),'b'); grid on; title('FFT x e LPC x');

end

function r = auto_lpc(x,k)
% Calcula a autocorrelação.
% x = Sinal de entrada.
% k = Atraso.

r = sum(x(1:end-k).*x(k+1:end));

end

function y = run_lpc(x,coefs)
% Reconstroe o sinal.

soma = 0;

for n = length(coefs)+1:length(x)
    
    for k = 1:length(coefs)
        soma = (coefs(k)*x(n-k)) + soma;
    end
    y(n-length(coefs)) = soma;
    soma = 0;
    
end

end
