function ChiBar=pChiBar(X,NepVct,nBS);
%function ChiBar=pChiBar(X,NepVct,nBS);
%
%PhJ 20210811
%
%Estimate chibar(u) statistic from a bivariate sample
%
% X      n x 2 bivariate sample
% NepVct p x 1 vector of marginal non-exceedance probabilities at which to evaluate ChiBar(u)
% nBS    1 x 1 number of bootstrap resamples (first is always the original sample)
%
% ChiBar nBS x p values of ChiBar for nBS bootstrap resamples and p thresholds
%
%The calculation is as follows
% 1. Estimate ChiBar(u) directly from its definition
%    ChiBar(u) = [2 log(Pr(U>u)) / log(Pr(U>u, V>u))] - 1
%    where U and V are uniform-scale versions of X and Y
%    ie U = F_X(X) and V=F_Y(Y) with F_X and F_Y estimated empirically from ranks
%
%Basics
% If ChiBar(inf)=1 => Asymptotic Dependence
% Then use Chi to describe AD further
% 
% If Chi(inf)=0 => Asymptotic Independence
% Then use ChiBar(inf) to describe AI further
%
% See http://www.lancs.ac.uk/~jonathan/EKJ11.pdf for basics
% See http://www.lancs.ac.uk/~jonathan/OcnEng10.pdf Section 4 for discussion on asymptotic properties
% of asymmetric logistic and Normal

if nargin==0;
    X=randn(1000,2);
    NepVct=(0.7:0.01:0.99)';
    nBS=50;
end;

n=size(X,1);
p=size(NepVct,1);

% Estimate Eta(u)
ChiBar=nan(nBS,p);
for iB=1:nBS;
    
    % Create bootstrap resample
    if iB==1;
        tX=X;
    else;
        I=(1:n)';
        tI=randsample(I,n,1);
        tX=X(tI,:);
    end;
    
    % Estimate empirical quantiles
    tR=pRnk(tX);
    tU=(tR+0.5)/(n+1);
    
    % Define threshold (this is just NEP because we're on uniform scale)
    Thr=NepVct;
    
    % Loop over thresholds
    for j=1:p;
        
        % Direct calculation of ChiBar
        u=Thr(j); % threshold
        tDnm=log(sum(tU(:,1)>u & tU(:,2)>u)/n); % log(Pr(U>u, V>u))
        ChiBar(iB,j)=(2*log(1-u)/tDnm)-1; 
        
    end;
    
end;

if nargin==0;
    clf;hold on;
    plot(NepVct,ChiBar(1,:)','ko-')
    plot(NepVct,quantile(ChiBar,0.025),'k:')
    plot(NepVct,quantile(ChiBar,0.975),'k:')
end;

return;