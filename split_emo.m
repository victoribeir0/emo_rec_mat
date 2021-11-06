cd('C:\Users\victo\Documents\Dataset _ EmoDB2\wav\emos');

as = dir('*.wav');
N = numel(as);
%emos = ['F','A','N','T','E','L','W'];
emos = 'W';
cc = zeros(1,length(emos));
inds = [];

for n = 1:N
    str = as(n).name;
    for emo = 1:length(emos)
        if str(6) == emos(emo)
            cc(emo) = cc(emo)+1;
            inds = [inds n];
            %copyfile('03a01Fa.wav', dest)
        end
    end
end

ind_rand = randperm(length(inds),20);
dest = 'C:\Users\victo\Documents\Dataset _ EmoDB2\wav\emos\Teste';

for n = 1:length(ind_rand)
    str = as(inds(ind_rand(n))).name;
    movefile(str, dest)
    disp(str);
end