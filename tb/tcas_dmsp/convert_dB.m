function Y = convert_dB(X)

Y = 20*log10(X/max(X));

end

