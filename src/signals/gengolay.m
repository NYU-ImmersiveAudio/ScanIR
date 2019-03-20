function y = gengolay(golayloglength)
%function y = gengolay(golayloglength)
%
%Generates Golay code pair of length 2^golayloglength
% Input:
%   golayloglength: order number of sequence
%
% Output:
%   y: two column array with Golay code pair of length 2^golayloglength
%
% Typical use:
%   y = gengolay(12);
%
% Written by:
%   Frederick S. Scott, August 2007
%   Copyright Music Technology, New York University

if (round(golayloglength) ~= golayloglength) || (golayloglength <= 0)
    error('golayloglength must be an integer > 0')
end

y = zeros(2^golayloglength, 2);

y(1:2,1) = [1; 1];
y(1:2,2) = [1; -1];

i = 1;
while golayloglength > i
    n = 2^i;
    nn = 2^(i+1);
    y(n+1:nn,1) = y(1:n,2);
    y(1:nn,2) = [y(1:n,1); -y(1:n,2)];
    i = i+1;
end

    
