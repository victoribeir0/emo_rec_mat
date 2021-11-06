% Função de custo, X = Observação com n dimensões.
function res = custo(X)
    res = (X.^2) + 10;
end
        
% Gradiente, X1, X2 = Observações com n dimensões. delta = Intervalo para diferença finita.
function res = gradiente(X1, X2, delta)    
    res = (custo(X2) - custo(X1))/(2*delta);
end

% Gradiente descendente, learn_rate = Taxa de importância para o gradiente. 
% n_iter = Núm. iterações. 
% delta = Intervalo para diferença finita central.
function grad_desc(learn_rate, n_iter, delta, N)
    X = rand(1,N);             % Inicialização aleatória da observação inicial.
    diff = zeros(N,n_iter); % Inicialização do vetor de derivadas.

    for i = 1:n_iter        
        diff(:,i) = -learn_rate*gradiente(X-delta, X+delta, delta); % Calcula a derivada no ponto X.        
        X = + diff(:,i); % Atualiza o ponto X.

%         if i ~= 1:   % Caso a diferença entre as derivadas seja muito pequena, para o laço for.
%             if all((diff(:,i) - diff9:,i-1)) < 1e-10):                
%                 break;

    % Plota a curva da derivada, normalizada entre 0 e 1.            
    plot(-diff(0,:)/max(-diff(0,:)),'b');
    end
end