% Gradiente descendente, learn_rate = Taxa de importância para o gradiente.
% n_iter = Núm. iterações.
% delta = Intervalo para diferença finita central.

function [w,b,mat_D] = grad_desc_mod(learn_rate, n_iter, delta, Dim, N)
w = [3.2 5.4 1.2; 1.2 2.4 3.2];
b = [1.5 2.2];
mat_D = [2 1; 1 1.3];

diff = zeros(Dim*2+2,n_iter); % Inicialização do vetor de derivadas.
X_n = zeros(1,Dim*2+2);

for i = 1:n_iter
    for m = 1:N
        X1 = [w(m,:) b(m)]';
        
        for n = 1:N
            X2 = [w(n,:) b(n)]';
            X = [X1;X2];
            
            for k = 1:Dim*2+2
                P = zeros(1,Dim*2+2)';
                P(k) = 1;
                diff(k,i) = -learn_rate*gradiente(X-P*delta,X+P*delta,delta,Dim,mat_D(m,n)); % Calcula a derivada no ponto X.
                diff_mat(k,n) = -learn_rate*gradiente(X-P*delta,X+P*delta,delta,Dim,mat_D(m,n));                
                X_n(k) = X_n(k) + diff(k,i); % Atualiza o ponto X.
            end            
            r(n) = custo(X, Dim, mat_D(m,n));
            
        end        
        grad = diff_mat*r';
    end
    
    w(n,:) = w(n,:) + grad(Dim+1+1:Dim+1+Dim)';
    b(n) = b(n) + grad(end)';
    w(m,:) = w(m,:) + grad(1:Dim)';
    b(m) = b(m) + grad(Dim+1)';
    X_n = zeros(1,Dim*2+2);
        
    J_temp = 0;
    for m = 1:N
        X1 = [w(m,:) b(m)]';
        
        for n = 1:N
            X2 = [w(n,:) b(n)]';
            X = [X1;X2];
            J_temp = J_temp + custo(X, Dim, mat_D(m,n));
        end
    end
    J(i) = J_temp;    
end
plot(J/max(J),'b'); grid on; xlabel('Iterações');
end

% Função de custo, X = Observação com n dimensões.
function res = custo(X, Dim, mD)
w1 = X(1:Dim);
b1 = X(Dim+1);
w2 = X(Dim+1+1:Dim+1+Dim);
b2 = X(end);
res = (w1'*w2 + b1+b2 - mD)^2;
end

% Gradiente, X1, X2 = Observações com n dimensões. delta = Intervalo para diferença finita.
function res = gradiente(X1, X2, delta, Dim, mD)
res = (custo(X2,Dim,mD) - custo(X1,Dim, mD))/(2*delta);
end