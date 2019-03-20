function y = genmls(order)
%function y = genmls(order)
%
%Generates Maximum Length Sequence of length 2^order-1
% Input:
%   order: order of sequence where 2 <= order <= 32
%
% Output:
%   y: MLS of length 2^order-1
%
% Typical use:
%   y = genmls(15);
%
% Written by:
%   Frederick S. Scott, August 2007
%   Copyright Music Technology, New York University

if nargin < 1, order = 15; end;

switch order
    case 2, taps=2; tap1=1; tap2=2;
    case 3, taps=2; tap1=3; tap2=1;
    case 4, taps=2; tap1=4; tap2=1;
    case 5, taps=2; tap1=4; tap2=1;
    case 6, taps=2; tap1=6; tap2=1;
    case 7, taps=2; tap1=7; tap2=1;
    case 8, taps=4; tap1=7; tap2=6; tap3=5; tap4=1;
    case 9, taps=2; tap1=6; tap2=1;
    case 10,taps=2; tap1=8; tap2=1;
    case 11,taps=2; tap1=10; tap2=1;
    case 12,taps=4; tap1=12; tap2=9; tap3=7; tap4=1;
    case 13,taps=4; tap1=13; tap2=11; tap3=10; tap4=1;
    case 14,taps=4; tap1=14; tap2=12; tap3=10; tap4=1;
    case 15,taps=2; tap1=15; tap2=1;
    case 16,taps=4; tap1=15; tap2=14; tap3=12; tap4=1;
    case 17,taps=2; tap1=15; tap2=1;
    case 18,taps=2; tap1=12; tap2=1;
    case 19,taps=4; tap1=19; tap2=18; tap3=15; tap4=1;
    case 20,taps=2; tap1=18; tap2=1;
    case 21,taps=2; tap1=20; tap2=1;
    case 22,taps=2; tap1=22; tap2=1;
    case 23,taps=2; tap1=19; tap2=1;
    case 24,taps=4; tap1=24; tap2=22; tap3=20; tap4=1;
    case 25,taps=2; tap1=23; tap2=1;
    case 26,taps=4; tap1=26; tap2=20; tap3=19; tap4=1;
    case 27,taps=4; tap1=27; tap2=21; tap3=20; tap4=1;
    case 28,taps=2; tap1=26; tap2=1;
    case 29,taps=2; tap1=28; tap2=1;
    case 30,taps=4; tap1=30; tap2=16; tap3=15; tap4=1;
    case 31,taps=2; tap1=29; tap2=1;
    case 32,taps=4; tap1=32; tap2=6; tap3=5; tap4=1;
    otherwise, error('order must be a integer between 2 and 32');
end

ordernum = 2^order-1;
fatchance = 1;

while fatchance == 1
    registers = rand(1,order);                  %random seeds for registers
    if max(abs(registers)) ~= 0                 %just incase rand returns all zeros
        fatchance = 0;
    end
end

for p = 1:(order)                               %sets registers to 0's and 1's
    if registers(p)>=.5
        registers(p)=1;
    else
        registers(p)=0;
    end
end

out = zeros(1, ordernum);
temp = 0;

for i = 1:(ordernum)
    temp = xor(registers(tap1),registers(tap2));
    if taps ==4
        temp = xor(temp, xor(registers(tap3),registers(tap4)));
    end
    for j = 1:(order-1)
        registers(j)=registers(j+1);
    end
    registers(order)=temp;
    out(i) = registers(order);
end

out = out.*2-1;                                 %turns 0's and 1's to -1's and 1's
y = out;