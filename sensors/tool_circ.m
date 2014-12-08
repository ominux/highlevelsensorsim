function z = tool_circ(x, y, D)
%%% from the book by Jason Schmidt.
    r = sqrt(x.^2+y.^2);
    z = double(r<D/2);
    z(r==D/2) = 0.5;