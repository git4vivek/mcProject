warning off;
files = dir('*.dat');
names_acc={'Patient 1','Patient 2','Patient 3','Patient 4'};

TruthTablewithPerformance = [];
Bradycardia_table = [];
global SVMModel
global weight_vector_svm 
global bias_svm
global Centroids
global CKNN_model
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
    three_min_avg=[];
    for i= 1:1:size(bpm_array,1)-2
        three_min_avg=[three_min_avg; round((bpm_array(i)+ bpm_array(i+1)+ bpm_array(i+2))/3)];
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
    bradicardia=[];
    count_brady = 0;
    fp = 0; tp = 0; fn = 0; tn = 0;
    for i= 1:1:size(bpm_array,1)-2
        if ((three_min_avg(i)<60) && (bpm_array(i)>= 60))
            fp = fp + 1;
            bradicardia=[bradicardia,0];
        elseif ((three_min_avg(i)<60) && (bpm_array(i)<60))
            tp = tp + 1;
            count_brady = count_brady + 1;
            bradicardia=[bradicardia,1];
        elseif ((three_min_avg(i)>= 60) && (bpm_array(i)<60))
            fn = fn + 1;
            bradicardia=[bradicardia,0];
        else
            tn = tn + 1;
            bradicardia=[bradicardia,0];
        end
    end
    
    x = size(bpm_array,1)-2;
    if( bradicardia(x) == 1)
        bradicardia(x+1) =1;
        bradicardia(x+2) =1;
    else
        bradicardia(x+1) =0;
        bradicardia(x+2) =0;
    end
    Precision = tp / (tp + fp );
    Recall = tp / ( tp + fn );
    F1 = 2*tp/(2*tp+fp+fn);
    Accuracy = (tp+tn)/(tp+tn+fp+fn);
    
    TruthTablewithPerformance = [TruthTablewithPerformance; [tn,fp,fn,tp,Accuracy]];
    if(count_brady > 0)
        X = sprintf('Bradycardia detected for %s',names_acc{fileitr});
    else
        X = sprintf('Bradycardia NOT detected for %s',names_acc{fileitr});
    end
    disp(X);
    X = sprintf('Detection for %s with Performance Metrics: tn %d, fp %d, fn %d, tp %d, Accuracy %d',names_acc{fileitr},tn,fp,fn,tp,Accuracy);
    disp(X);
    
    
%     bradicardia=[];
%     
%     for i=1:1:29
%         if bpm_array(i,1)<60
%             bradicardia=[bradicardia,1];
%         else
%             bradicardia=[bradicardia,0];
%         end
%     end 
    bradicardia = bradicardia';
    
    %disp(bradicardia);
    if files(fileitr).name == "ekg_raw_16272.dat"
        csvwrite("Labels_272_2.csv",bradicardia);
    elseif files(fileitr).name == "ekg_raw_16273.dat"
        csvwrite("Labels_273_2.csv",bradicardia);
    elseif files(fileitr).name == "ekg_raw_16420.dat"
        csvwrite("Labels_420_2.csv",bradicardia);
    else
        csvwrite("Labels_483_2.csv",bradicardia);
    end
    trainingset = bpm_array(1:20);
    
    testset = bpm_array(21:size(bpm_array,1));
    
    
    CLR_model = glmfit(trainingset,bradicardia(1:20),'binomial','link','logit');
    
    
    z = CLR_model(1) + (testset * CLR_model(2));
    %z = 1 ./(1 + exp(-z));
    z_calculate = 1 ./(1 + exp(-z));
    
    CLR_fit_data =[];
    for i=1:1:size(z_calculate,1)
        if(z_calculate(i)<0.9)
            CLR_fit_data = [CLR_fit_data;0];
        else
            CLR_fit_data = [CLR_fit_data;1];
            
        end
    end
    
    %Training the models
    if files(fileitr).name == "ekg_raw_16272.dat"
        [idx,Centroids]=kmeans(bpm_array(1:20),2);
        sprintf('Centroids: %s',Centroids);        
        SVMModel = fitcsvm(trainingset,bradicardia(1:20));    
        weight_vector_svm = SVMModel.Beta;    
        bias_svm = SVMModel.Bias;    
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
    
    disp(X);
    
    [~,idx_test] = pdist2(Centroids,testset,'euclidean','Smallest',1);
    %disp(idx_test);
    if size(find(idx_test' == 1),1)>0
        X = sprintf('Prediction by K-Means for %s if BradyCardia? %s',names_acc{fileitr},'Yes');
        brady=[brady,'Y'];
    else
        X = sprintf('Prediction by K-Means for %s if BradyCardia? %s',names_acc{fileitr},'No');
        brady=[brady,'N'];
    end
    disp(X);

    CKNN_fit_data = predict(CKNN_model,testset);
    if size(find(CKNN_fit_data),1)>0
        X = sprintf('Prediction by KNN for %s if BradyCardia? %s',names_acc{fileitr},'Yes');
        brady=[brady,'Y'];
    else
        X = sprintf('Prediction by KNN for %s if BradyCardia? %s',names_acc{fileitr},'No');
        brady=[brady,'N'];
    end
    disp(X);

    if size(find(CLR_fit_data),1)>0
        X = sprintf('Prediction by Logistic Regression for %s if BradyCardia? %s',names_acc{fileitr},'Yes');
        brady=[brady,'Y'];
    else
        X = sprintf('Prediction by Logistic Regression for %s if BradyCardia? %s',names_acc{fileitr},'No');
        brady=[brady,'N'];
    end
    disp(X);
    disp(' ');
    Bradycardia_table = [Bradycardia_table;brady];
    
end
xlswrite("Bradycardia_results",Bradycardia_table);
