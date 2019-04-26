data = importdata('ekg_raw_16272.dat');
data(:,3)=[];

[index peaks] = RPeakDetection(data(:,2));
t=1;
list=[]
rowlength=[]
count=0
for i= 1:1:size(peaks,1)
    if(index(1,i)<=t*128*60)
        list=[list,index(1,i)]
        count=count+1
    else
        t=t+1;
        rowlength=[rowlength;count]
        list=[]
        list=[list,index(1,i)]
        count=1
    end
end

bradicardia=[]

for i=1:1:29
    if rowlength(i,1)<60
        bradicardia=[bradicardia,1]
    else
        bradicardia=[bradicardia,0]
    end
end
bradicardia = bradicardia'

trainingset= rowlength(1:20)

testset=rowlength(21:29)

SVMModel = fitcsvm(trainingset,bradicardia(1:20))

weight_vector_svm=SVMModel.Beta

bias_svm=SVMModel.Bias

%ans = weight_vector_svm*59+bias_svm
svm_fit_data = predict(SVMModel,testset);

tree_model = fitctree(trainingset,bradicardia(1:20));
tree_fit_data = predict(tree_model,testset);

CNB_model = fitcnb(trainingset,bradicardia(1:20));
CNB_fit_data = predict(CNB_model,testset);

CKNN_model = fitcknn(trainingset,bradicardia(1:20));
CKNN_fit_data = predict(CKNN_model,testset);
