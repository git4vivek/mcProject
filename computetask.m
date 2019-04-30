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
            disp(testset)
            SVMModel = fitcsvm(trainingset,bradicardia(1:20));
            
            weight_vector_svm = SVMModel.Beta;
            
            bias_svm = SVMModel.Bias;
            
            %ans = weight_vector_svm*59+bias_svm
            tree_model = fitctree(trainingset,bradicardia(1:20));
            CNB_model = fitcnb(trainingset,bradicardia(1:20));
            CKNN_model = fitcknn(trainingset,bradicardia(1:20));
            
            svm_fit_data = predict(SVMModel,testset);
            tree_fit_data = predict(tree_model,testset);
            CNB_fit_data = predict(CNB_model,testset);
            CKNN_fit_data = predict(CKNN_model,testset);
            
            
        end