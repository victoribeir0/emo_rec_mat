function [m_nrg, F0, nrg, jit_abs, jit_rel, jit_x, shi_abs, shi_rel, amp_std, mean_dif_picos, hnr] = get_global_contx(x,jans,fs,viz)

[~,~,nrg,~,~] = vad_mix(x,40,10);

[F0, u, hnr] = get_f0_2(x,40,jans,fs,15);

if length(F0)-viz < viz+1
    [F0, u, hnr] = get_f0_2(x,40,jans,fs,30);
end

[jit_abs, jit_rel, jit_x, shi_abs, shi_rel, amp_std, mean_dif_picos] = get_quali_contx(x, 40, u, fs, F0);

m_nrg = mean(nrg);

end

function res = get_ang(y)
x = 1:length(y);

m = [ones(length(x),1) x'];
a = inv(m'*m)*m'*y';
res = a(2);
end