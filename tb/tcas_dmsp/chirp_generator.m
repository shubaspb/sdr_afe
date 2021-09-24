function S = chirp_generator(n , Fs , dF , F_chirp, F_ch_0 )
% n = 1000000;
% Fs = 100e6;
% dF = 1e6;
% F_chirp = 10;
% F_ch_0 = 1e6;


% n_rom = 1000;
% Coef_sin=sin(2*pi*[0:n_rom*2]/n_rom/2);
% sin_rom=Coef_sin(2:2:n_rom);


Nf = Fs/F_chirp;
f_ch = [];
f_ch(1) = F_ch_0;
d_ch = dF/Nf*2;
df = 1;
for i=2:n
    f_ch(i) = f_ch(i-1) + df*d_ch;
    if (mod(i,round(Nf/2))==0)
       df = -1*df;
    end
end

S = cos(2*pi*f_ch/Fs.*(0:n-1)) + 1i*sin(2*pi*f_ch/Fs.*(0:n-1));

figure(67); plot(f_ch); grid on

end

