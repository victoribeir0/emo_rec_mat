% Gradiente descendente, learn_rate = Taxa de import�ncia para o gradiente. 
% n_iter = N�m. itera��es. 
% delta = Intervalo para diferen�a finita central.

function X = grad_desc(learn_rate, n_iter, delta, Dim)    
    X = 2*rand(1,Dim);        % Inicializa��o aleat�ria da observa��o inicial.
    diff = zeros(Dim,n_iter); % Inicializa��o do vetor de derivadas.

    for i = 1:n_iter
        for k = 1:Dim
            P = zeros(1,Dim);
            P(k) = 1;
            diff(k,i) = -learn_rate*gradiente(X-P*delta, X+P*delta, delta); % Calcula a derivada no ponto X.
            X(1,k) = X(1,k)+diff(k,i); % Atualiza o ponto X.
        end
        J(i) = custo(X);
    end
    
    % Plota a curva da derivada, normalizada entre 0 e 1.    
    plot(J,'b'); grid on;
end

% Fun��o de custo, X = Observa��o com n dimens�es.
function res = custo(X)
    res = (X(1).^2) + (X(2).^3) - 10;
end
        
% Gradiente, X1, X2 = Observa��es com n dimens�es. delta = Intervalo para diferen�a finita.
function res = gradiente(X1, X2, delta)    
    res = (custo(X2) - custo(X1))/(2*delta);
end