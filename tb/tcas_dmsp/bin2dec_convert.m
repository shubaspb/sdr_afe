function data_out = bin2dec_convert(data_in, w)

for k=1:length(data_in)
    B = data_in(k);

    cnt = 0;
    for i=w:-1:1
        X = B - 10^(i-1);
        if X >= 0
            cnt = cnt + 2^(i-1);
            B = B - 10^(i-1);
        end
    end
    if cnt>=2^(w-1)
        cnt = -1*(2^w-cnt);
    end
    
    data_out(k) = cnt; 
end

end

