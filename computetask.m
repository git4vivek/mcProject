        files = dir('*.dat');
        for fileitr = 1:length(files)
            f1 = strcat(files(fileitr).folder,'\',files(fileitr).name);
            disp(f1)
            mydata = importdata(f1);
            
            mydata(:,3)=[];
            
            [index peaks] = RPeakDetection(mydata(:,2));
            t=1;
            list=[];
            rowlength=[];
            count=0;
            for i= 1:1:size(peaks,1)
                if(index(1,i)<=t*128*60)
                    list=[list,index(1,i)];
                    count=count+1;
                else
                    t=t+1;
                    rowlength=[rowlength;count];
                    list=[];
                    list=[list,index(1,i)];
                    count=1;
                end
            end
            
            bradicardia=[];
            
            for i=1:1:29
                if rowlength(i,1)<60
                    bradicardia=[bradicardia,1];
                else
                    bradicardia=[bradicardia,0];
                end
            end
            bradicardia = bradicardia';
            
            trainingset = rowlength(1:20);
            
            testset = rowlength(21:size(rowlength,1));
            
            SVMModel = fitcsvm(trainingset,bradicardia(1:20));
            
            weight_vector_svm = SVMModel.Beta;
            
            bias_svm = SVMModel.Bias;
             b = glmfit(trainingset,bradicardia(1:20),'binomial','link','logit');
             z = b(1) + (testset * b(2));
            %ans = weight_vector_svm*59+bias_svm
            
            svm_fit_data = predict(SVMModel,testset);
 
            
            
        end