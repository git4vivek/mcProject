warning off;
files = dir('*.dat');
names_acc={'Person_1','Person_2','Person_3','Person_4'};

TruthTablewithPerformance = [];
Bradycardia_table = [];
for fileitr = 1:length(files)
    f1 = strcat(files(fileitr).folder,'\',files(fileitr).name);
    %     disp(f1)
    mydata = importdata(f1);
    
    mydata(:,3)=[];
    
    [index peaks] = RPeakDetection(mydata(:,2));
    t=1;
    list=[];
    bpm_array=[];
    count=0;
    for i= 1:1:size(peaks,1)
        if(index(1,i)<=t*128*60)
            list=[list,index(1,i)];
            count=count+1;
        else
            t=t+1;
            bpm_array=[bpm_array;count];
            list=[];
            list=[list,index(1,i)];
            count=1;
        end
    end
    sampledata=[];
    for i= 1:1:size(bpm_array,1)-2
        sampledata=[sampledata; round((bpm_array(i)+ bpm_array(i+1)+ bpm_array(i+2))/3)];
    end
    
    % Plots Begin
    figure('Name',names_acc{fileitr},'NumberTitle','off');
    plot(bpm_array);
    hold on;
    xlabel('Time in mins')
    ylabel('Heart beat level')
    
    hline = refline([0 60]);
    
    hline.Color = 'r';
    legend('BPM', 'threshold')
    
    % Plots End
    fp = 0; tp = 0; fn = 0; tn = 0;
    for i= 1:1:size(bpm_array,1)-2
        if ((sampledata(i)<60) && (bpm_array(i)>= 60))
            fp = fp + 1;
        elseif ((sampledata(i)<60) && (bpm_array(i)<60))
            tp = tp + 1;
        elseif ((sampledata(i)>= 60) && (bpm_array(i)<60))
            fn = fn + 1;
        else
            tn = tn + 1;
        end
    end
    
    Precision = tp / (tp + fp );
    Recall = tp / ( tp + fn );
    F1 = 2*tp/(2*tp+fp+fn);
    Accuracy = (tp+tn)/(tp+tn+fp+fn);
    
    TruthTablewithPerformance = [TruthTablewithPerformance; [tn,fp,fn,tp,Precision,Recall,F1,Accuracy]];
    X = sprintf('Detection for %s with Performance Metrics: tn %d, fp %d, fn %d, tp %d, Precision %d, Recall %d, F1 %d, Accuracy %d',names_acc{fileitr},tn,fp,fn,tp,Precision,Recall,F1,Accuracy);
    disp(X)
    
    bradicardia=[];
    
    for i=1:1:29
        if bpm_array(i,1)<60
            bradicardia=[bradicardia,1];
        else
            bradicardia=[bradicardia,0];
        end
    end
    bradicardia = bradicardia';
    
    trainingset = bpm_array(1:20);
    
    testset = bpm_array(21:size(bpm_array,1));
    
    
    CLR_model = glmfit(trainingset,bradicardia(1:20),'binomial','link','logit');
    
    
    z = CLR_model(1) + (testset * CLR_model(2));
    z = 1 ./(1 + exp(-z));
    
    if files(fileitr).name == "ekg_raw_16272.dat"
        [idx,C]=kmeans(bpm_array(1:20),2)
        sprintf('Centroids: %s',C);
        
        SVMModel = fitcsvm(trainingset,bradicardia(1:20));
    
    weight_vector_svm = SVMModel.Beta;
    
    bias_svm = SVMModel.Bias;
    
    %ans = weight_vector_svm*59+bias_svm
    %tree_model = fitctree(trainingset,bradicardia(1:20));
    CKNN_model = fitcknn(trainingset,bradicardia(1:20));
    end
    
    brady = [];
    svm_fit_data = predict(SVMModel,testset);
    if size(find(svm_fit_data),1)>0
        X = sprintf('Prediction by SVM for %s if BradyCardia? %s',names_acc{fileitr},'Yes');
        brady=[brady,'Y'];
    else
        X = sprintf('Prediction by SVM for %s if BradyCardia? %s',names_acc{fileitr},'No');
        brady=[brady,'N'];
    end
    
    disp(X)
    
    %{
    tree_fit_data = predict(tree_model,testset);
    if size(find(tree_fit_data),1)>0
        X = sprintf('Prediction by Decision Tree for %s if BradyCardia? %s',names_acc{fileitr},'Yes');
        brady=[brady,'Y'];
    else
        X = sprintf('Prediction by Decision Tree for %s if BradyCardia? %s',names_acc{fileitr},'No');
        brady=[brady,'N'];
    end
    disp(X)
    %}
    CKNN_fit_data = predict(CKNN_model,testset);
    if size(find(CKNN_fit_data),1)>0
        X = sprintf('Prediction by KNN for %s if BradyCardia? %s',names_acc{fileitr},'Yes');
        brady=[brady,'Y'];
    else
        X = sprintf('Prediction by KNN for %s if BradyCardia? %s',names_acc{fileitr},'No');
        brady=[brady,'N'];
    end
    
%     CLR_fit_data = predict(CLR_model,testset);
%     if size(find(CLR_fit_data),1)>0
%         X = sprintf('Prediction by Logistic Regression for %s if BradyCardia? %s',names_acc{fileitr},'Yes');
%         brady=[brady,'Y'];
%     else
%         X = sprintf('Prediction by Logistic Regression for %s if BradyCardia? %s',names_acc{fileitr},'No');
%         brady=[brady,'N'];
%     end
%     disp(X)
%     disp(' ')
    Bradycardia_table = [Bradycardia_table;brady];
end
xlswrite("Bradycardia_results",Bradycardia_table);
