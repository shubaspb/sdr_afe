function [Sp_dB, f_axe] = Spectr2(X, fd, num_graph)

n = length(X);
win=blackman(1,n);
%X = X - mean(X);


Sp_X = abs(fft(X.*win));
Z = sqrt(var(Sp_X)); %Sp_X(1);
%Sp_dB = 20*log10(Sp_X/sqrt(var(Sp_X)));
Sp_dB = 20*log10(Sp_X);
Sp_dB (Sp_dB<=-100) = -100;
f_axe = (0:n-1)/n*fd;


if (num_graph==0)
    
else
figure(num_graph); 
plot(f_axe(1:round(n)), Sp_dB(1:round(n))); 
grid on
xlabel('F, Ãö')
ylabel('dB')
end


end

