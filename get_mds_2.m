% Gradiente descendente, learn_rate = Taxa de import�ncia para o gradiente.
% n_iter = N�m. itera��es.
% delta = Intervalo para diferen�a finita central.

function X = get_mds_2(learn_rate, n_iter, delta, Dim, dx)
N = size(dx,1);
X = rand(N,Dim);          % Inicializa��o aleat�ria da observa��o inicial.
diff = zeros(1,Dim); % Inicializa��o do vetor de derivadas.
X_n = zeros(1,Dim);
J_sum = 0;

for ite = 1:n_iter
    for k = 1:N
        for j = 1:N
            for d = 1:Dim
                P = zeros(1,Dim);
                P(d) = 1;
                diff(d) = -learn_rate*gradiente(X(k,:)-P*delta, X(k,:)+P*delta, X(j,:), delta, dx(k,j)); % Calcula a derivada no ponto X.
                X_n(d) = X_n(d)+diff(d); % Soma das derivadas.
            end            
        end 
        X(k,:) = X(k,:) + X_n(:)'/sum((dx(:).^2));
        X_n = zeros(1,Dim);
    end
            
    for k = 1:N
        for j = 1:N
           J_sum = J_sum + custo(X(k,:),X(j,:),dx(k,j)); 
        end
    end   
    J(ite) = J_sum;
    J_sum = 0;
    
    if ite > 1
        if J(ite) == J(ite-1)
            break;
        end
    end
    
end

% Plota a curva da derivada, normalizada entre 0 e 1.
plot(J/max(J),'b'); grid on;
end

% Fun��o de custo, X = Observa��o com n dimens�es.
function res = custo(X,Y,dx)
res = (sqrt(sum((X-Y).^2)) - dx)^2;
end

% Gradiente, X1, X2 = Observa��es com n dimens�es. delta = Intervalo para diferen�a finita.
function res = gradiente(X1, X2, Y, delta, dx)
res = (custo(X2,Y,dx) - custo(X1,Y,dx))/(2*delta);
end