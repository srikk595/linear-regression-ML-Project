function[lambda, Sigma1, w1, mu1, train_erms, valid_erms] = trainBatch(M)
    load 'proj2.mat'
    
    % compute variance
    var_data = var(training_data);
    var_matrix = diag(var_data)*0.115+eye(46);
    
    % compute desing matrix for traning set
    designMat = ones(length(training_data),1);
    mu = ones(M, 46);
    for i=2:M
        random_rows = randperm(length(training_data),100);
        mu(i,:) = mean(training_data(random_rows,:));
        phi = zeros(length(training_data),1);
        for j=1:length(training_data)
           X = training_data(j,1:46) - mu(i,:);
           c = -1/2*(X/var_matrix*transpose(X));
           phi(j) = exp(c);
        end
        designMat(:,i) = phi;
    end
    
 % compute design matrix for validation set
    designValidMat = ones(length(validation_data),1);
    for i=2:M
        phi = zeros(length(validation_data),1);
        for j=1:length(validation_data)
           X = validation_data(j,1:46) - mu(i,:);
           c = -1/2*(X/var_matrix*transpose(X));
           phi(j) = exp(c);
        end
        designValidMat(:,i) = phi;
    end
    
    valid_erms = 10000;
    for l=0.01:0.1:1:3:10    
        % compute weight vectors
        lMatrix = l*eye(M);
        w = inv(lMatrix + transpose(designMat)*designMat)*transpose(designMat)*target_train_data;
        trainErr = target_train_data - designMat*w;
        trainE =((trainErr'*trainErr)/2);
        t_erms=sqrt((2*trainE)/length(training_data));

        % compute weight vectors
        lMatrix = l*eye(M);
        validErr = target_validate_data - designValidMat*w;
        validE =((validErr'*validErr)/2);
        v_erms=sqrt((2*validE)/length(validation_data));
        if valid_erms > v_erms
            mu1 = mu;
            w1 = w;
            lambda = l;
            valid_erms = v_erms;
            train_erms = t_erms;
        end            
    end
    
     % construc sigma matrix
    Sigma1 = zeros(46,46,M);
    for i=1:M
        Sigma1(:,:,i) = var_matrix;
    end
end