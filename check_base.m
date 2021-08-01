function emoc = check_base()

folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2\wav\dados';
dest = 'C:\Users\victo\Documents\Dataset _ EmoDB2\wav\teste';
cd(dest);
as = dir('*.wav');
N = numel(as);
emoc = zeros(1,N);

emo = ['W';'L';'A';'F';'T';'N'];
% emo = ['W';'T'];

% count = zeros(length(emo),length(loc));
count = zeros(1,length(emo));

%for k = 1:length(loc)

for n = 1:N
    
    str = as(n).name;
    
    % locu = str(1:2);
    em = str(6);
    emoc(n) = em;
    
    for e = 1:length(emo)
        if emo(e) == em && count(e) <= 30
            count(e) = count(e) + 1;            
            % movefile(str,dest);
        end
    end
    
end

end