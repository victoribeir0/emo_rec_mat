% Fun��o de custo, X = Observa��o com n dimens�es.
function res = custo(X)
    res = (X.^2) + 10;
end
        
% Gradiente, X1, X2 = Observa��es com n dimens�es. delta = Intervalo para diferen�a finita.
function res = gradiente(X1, X2, delta)    
    res = (custo(X2) - custo(X1))/(2*delta);
end

% Gradiente descendente, learn_rate = Taxa de import�ncia para o gradiente. 
% n_iter = N�m. itera��es. 
% delta = Intervalo para diferen�a finita central.
function grad_desc(learn_rate, n_iter, delta, N)
    X = rand(1,N);             % Inicializa��o aleat�ria da observa��o inicial.
    diff = zeros(N,n_iter); % Inicializa��o do vetor de derivadas.

    for i = 1:n_iter        
        diff(:,i) = -learn_rate*gradiente(X-delta, X+delta, delta); % Calcula a derivada no ponto X.        
        X = + diff(:,i); % Atualiza o ponto X.

%         if i ~= 1:   % Caso a diferen�a entre as derivadas seja muito pequena, para o la�o for.
%             if all((diff(:,i) - diff9:,i-1)) < 1e-10):                
%                 break;

    % Plota a curva da derivada, normalizada entre 0 e 1.            
    plot(-diff(0,:)/max(-diff(0,:)),'b');
    end
end