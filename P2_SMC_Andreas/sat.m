function y = sat(x)
    if abs(x) <= 1
        y = x;
    else
        y = sign(x);
    end
end