function [m_nrg, m_f0, nrg, jit_abs, jit_rel, jit_x, shi_abs, shi_rel, amp_std, amp_x, mean_dif_picos, hnr] = get_global(x,jans,fs)

[~,~,nrg,~,~] = vad_mix(x,40,10);

[F0, u, hnr] = get_f0_2(x,40,jans,fs);
[jit_abs, jit_rel, jit_x, shi_abs, shi_rel, amp_std, amp_x, mean_dif_picos] = get_quali(x, 40, u, fs, mean(F0));

m_nrg = mean(nrg);
m_f0 = mean(F0);

end

function res = get_ang(y)
x = 1:length(y);

m = [ones(length(x),1) x'];
a = inv(m'*m)*m'*y';
res = a(2);
end