function [lp]=gaussmixp(y,m,v,w)
% y = cat(1, testSamples(1).mfcc{:});
% m = gmm.M;
% v = gmm.V;
% w = gmm.W;

%GAUSSMIXP calculate probability densities from a Gaussian mixture model
%
% Inputs: n data values, k mixtures, p parameters, q data vector size
%
%   Y(n,q) = input data
%   M(k,p) = mixture means for x(p)
%   V(k,p) or V(p,p,k) variances (diagonal or full)
%   W(k,1) = weights
%   A(q,p), B(q) = transformation: y=x*a'+b' (where y and x are row vectors)
%            if A is omitted, it is assumed to be the first q rows of the
%            identity matrix. B defaults to zero.
%   Note that most commonly, q=p and A and B are omitted entirely.
%
% Outputs
%
%  LP(n,1) = log probability of each data point
%  RP(n,k) = relative probability of each mixture
%  KH(n,1) = highest probability mixture
%  KP(n,1) = relative probability of highest probability mixture

%      Copyright (C) Mike Brookes 2000-2009
%      Version: $Id: gaussmixp.m,v 1.3 2009/04/08 07:51:21 dmb Exp $
%
%   VOICEBOX is a MATLAB toolbox for speech processing.
%   Home page: http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You can obtain a copy of the GNU General Public License from
%   http://www.gnu.org/copyleft/gpl.html or by writing to
%   Free Software Foundation, Inc.,675 Mass Ave, Cambridge, MA 02139, USA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[n,q]=size(y);
[k,p]=size(m);
memsize=voicebox('memsize');    % set memory size to use

lp=zeros(n,1);
wk=ones(k,1);

vi=-0.5*v.^(-1);                % data-independent scale factor in exponent
lvm=log(w)-0.5*sum(log(v),2);   % log of external scale factor (excluding -0.5*q*log(2pi) term)
ii=1:n;
wnj=ones(1,n);
kk=repmat(ii,k,1);
km=repmat(1:k,1,n);
py=reshape(sum((y(kk(:),:)-m(km(:),:)).^2.*vi(km(:),:),2),k,n)+lvm(:,wnj);
mx=max(py,[],1);                % find normalizing factor for each data point to prevent underflow when using exp()
px=exp(py-mx(wk,:));            % find normalized probability of each mixture for each datapoint
ps=sum(px,1);                   % total normalized likelihood of each data point
lp(ii)=log(ps)+mx;
lp=lp-0.5*q*log(2*pi);