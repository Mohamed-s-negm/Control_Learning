function [A_era, B_era, C_era, D_era] = ERA(YY,nin,nout,m,n,r)
    
    % Obtain D matrix and separating it from the system
    for i=1:nout
         for j=1:nin
             D_era(i,j) = YY(i,j,1);
             Y(i,j,:) = YY(i,j,2:end);
         end
     end
    
    assert(length(Y(:,1,1))==nout);
    assert(length(Y(1,:,1))==nin);
    assert(length(Y(1,1,:))>=m+n);
    
    % Making the Hankel matrices
    for i=1:m
        for j=1:n
            for Q=1:nout
                for P=1:nin
                    H0(nout*i-nout+Q,nin*j-nin+P) = Y(Q,P,i+j-1);
                    H1(nout*i-nout+Q,nin*j-nin+P) = Y(Q,P,i+j);
                end
            end
        end
    end

    % SVD
    [U,S,V] = svd(H0,'econ');

    % Plot
    figure
    semilogy(diag(S),'o-')
    grid on
    xlabel('Index')
    ylabel('Singular Value')
    title('ERA Singular Values')
    grid off
    
    % Truncation
    Ur = U(:,1:r);
    Sr = S(1:r,1:r);
    Vr = V(:,1:r);

    % CTRB & OBSV
    Or = Ur*sqrtm(Sr);
    Cr = sqrtm(Sr)*Vr';
    
    % Obtain the A, B, C matrices
    A_era = Sr^(-0.5)*Ur'*H1*Vr*Sr^(-0.5);
    
    B_era = Cr(:, 1:nin);         % First m columns
    C_era = Or(1:nout, :);         % First p rows

end

