data = importdata('ekg_raw_16272.dat');
data(:,3)=[];

[index peaks] = RPeakDetection(data(:,2));
t=1;
list=[]
rowlength=[]
count=0
for i= 1:1:1802
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

ans = weight_vector_svm*59+bias_svm