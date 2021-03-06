% clear workspace and close plot windows
clear;
close all;
% prepare the data set
load mnist_big_matlab.mat
% choose parameters
train_size = 60000;
test_size = size(testLabels,2);
X_train{1} = reshape(trainData(1:14,1:14,:),[],train_size);
X_train{2} = reshape(trainData(15:28,1:14,:),[],train_size);
X_train{3} = reshape(trainData(15:28,15:28,:),[],train_size);
X_train{4} = reshape(trainData(1:14,15:28,:),[],train_size);
X_train{5} = zeros(0,train_size);
X_train{6} = zeros(0,train_size);
X_train{7} = zeros(0,train_size);
X_train{8} = zeros(0,train_size);
X_test{1} = reshape(testData(1:14,1:14,:),[],test_size);
X_test{2} = reshape(testData(15:28,1:14,:),[],test_size);
X_test{3} = reshape(testData(15:28,15:28,:),[],test_size);
X_test{4} = reshape(testData(1:14,15:28,:),[],test_size);
X_test{5} = zeros(0,test_size);
X_test{6} = zeros(0,test_size);
X_test{7} = zeros(0,test_size);
X_test{8} = zeros(0,test_size);
% define network architecture
layer_size = [196 32;196 32; 196 32;196 32; 0 64;0 64;0 64;0 10];
L = 8;
v=(11/9);
gamma1=gamma(2-v);
lambda=0.00002;
gamma2=gamma(3-v);
J=[];
Acc=[];
DW=[];
W=[];
EL2=[];
testacc=zeros(1,300);
trainacc=zeros(1,5);
for number=1:1
% initialize weights
for l = 1:L-1
    w{l} = randn(layer_size(l+1,2), sum(layer_size(l,:)));
end
% train
tic;
alpha = 3;
max_iter = 300;
mini_batch = 100;
for iter = 1:max_iter
    a{1} = ones(layer_size(1,2),mini_batch);
    for st = 1:mini_batch:train_size - mini_batch + 1
        for l = 1:L
            x{l} = X_train{l}(:,st:st+mini_batch-1);
        end
        y = double(trainLabels(:,st:st+mini_batch-1));
        %forward computation
        for l = 1:L-1
            [a{l+1}, z{l+1}] = fc(w{l},a{l},x{l});
        end
        delta{L} = (a{L} - y) .* a{L} .* (1-a{L});
        %backward computation
        for l = L-1:-1:2
            delta{l} = bc(w{l},z{l},delta{l+1}); 
        end
        for l = 1:L-1
           gw = (delta{l+1} * [x{l};a{l}]')/mini_batch;
           gw=gw.*(1./nthroot(abs(w{l}.^2),9)/gamma1);
           %gw=gw.*(nthroot(abs(w{l}.^1),9)/gamma);
           gw=gw+lambda.*(nthroot(abs(w{l}.^7),9)/gamma2).*sign(w{l});
           gw = gw + lambda.*w{l};
           w{l} = w{l} - alpha * gw;
        end

        J = [J 1/2/mini_batch*sum((a{L}(:) - y(:)) .^ 2)];
        [~,ind_train] = max(y);
        [~,ind_pred] = max(a{L});
        Acc = [Acc sum(ind_train == ind_pred) / mini_batch];
        W=[W w{5}(20,20)];
    end
    fprintf('iter = %d  ',iter);
    cost = 1/2 * sum(a{L}(:) - y(:)) ^ 2;
    fprintf('cost = %f\n',cost);
    EL2 = [EL2 cost];
%     a{1} = ones(layer_size(1,2),test_size);
% for l = 1:L-1
%     a{l+1} = fc(w{l},a{l},X_test{l});
% end
% [~,ind_test] = max(testLabels);
% [~,ind_pred] = max(a{L});
% test_acc = sum(ind_test == ind_pred) / test_size;
% fprintf('Accuracy on test dataset is %f%%\n',test_acc*100);
% testacc(1,iter)=test_acc;
end
toc;
%figure
%plot(testacc);
%figure
plot(J);
saveas(gcf,'J.jpg')
%figure
%plot(Acc);
%saveas(gcf,'Acc.jpg')
% save model
% figure
% plot(DW,'o');
%figure
%plot(W);
%save model.mat w layer_size
% test
a{1} = ones(layer_size(1,2),train_size);
for l = 1:L-1
    a{l+1} = fc(w{l},a{l},X_train{l});
end
[~,ind_test] = max(trainLabels);
[~,ind_pred] = max(a{L});
train_acc = sum(ind_test == ind_pred) / train_size ;
fprintf('Accuracy on training dataset is %f%%\n',train_acc*100);
trainacc(1,number)=train_acc*100;
a{1} = ones(layer_size(1,2),test_size);
for l = 1:L-1
    a{l+1} = fc(w{l},a{l},X_test{l});
end
[~,ind_test] = max(testLabels);
[~,ind_pred] = max(a{L});
test_acc = sum(ind_test == ind_pred) / test_size;
fprintf('Accuracy on test dataset is %f%%\n',test_acc*100);
testacc(1,number)=test_acc*100;
end
fprintf('Finally accuracy on training dataset is %f%%\n',mean(trainacc(:)));
fprintf('Finally accuracy on test dataset is %f%%\n',mean(testacc(:)));