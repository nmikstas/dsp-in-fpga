function w = bkharris(n)
%BKHARRIS BKHARRIS(N) returns the N-point Blackman-harris
%	  4 term (-92 db) window.

w = (.35875 - .48829*cos(2*pi*(0:n-1)/(n)) + .14128*cos(4*pi*(0:n-1)/(n))-.01168*cos(6*pi*(0:n-1)/(n)))';

