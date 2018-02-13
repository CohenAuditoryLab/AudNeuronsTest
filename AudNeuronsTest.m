function neuronSpikesSummary = AudNeuronsTest()
    projectFolder = pwd;
    % handle slashes
    if(ispc)
        sslash = '\';
    else
        sslash = '/';
    end
    % load spikesData
    if exist('spikesData', 'var') == 0
        spikesData = load([projectFolder sslash 'sampleData' sslash 'spikes' sslash 'jan14_18_AL.mat']);
        spikesData = spikesData.standard_output;
    else 
        spikesData = load(spikesData);
    end
    % load taskData
    if exist('taskData', 'var') == 0
        taskData = load([projectFolder sslash 'sampleData' sslash 'tasks' sslash 'jan14_18.mat']);
        taskData = taskData.meta;
    else 
        taskData = load(taskData);
    end
    % get sounds
    sounds = taskData.sound;
    % add library paths
    addpath(genpath('services'));
    addpath(genpath('libraries'));
    % get unique neurons
    uniqueNeurons = unique(spikesData(:,1));
    neuronSpikesSummary = [];
     % loop through neurons
     N = numel(uniqueNeurons);
     upd = textprogressbar(N);
     for i=1:N
        upd(i);
        % loop through trials
        spikesTrial = zeros([size(sounds,1),1]);
        spikesBefore = zeros([size(sounds,1),1]);
        for t=1:size(sounds,1)
            % get trial spikes
            startTime = sounds(t,1); endTime = sounds(t,2);
            spikesTrial(t) = numel(spikesData(spikesData(:,2)>startTime & spikesData(:,2)< endTime & spikesData(:,1) == uniqueNeurons(i),2));
            % get before trial spikes
            spikesBefore(t) = numel(spikesData((spikesData(:,2)<startTime & spikesData(:,2)> (startTime-(endTime-startTime)) & spikesData(:,1) == uniqueNeurons(i)),:));
        end
        newSummary = [];
        newSummary.trialMean = mean(spikesTrial);
        newSummary.trialVariance = var(spikesTrial);
        newSummary.preTrialMean = mean(spikesBefore);
        newSummary.preTrialVariance = var(spikesBefore);
        [~,newSummary.tTestP] = ttest(spikesTrial, spikesBefore);
        if (newSummary.tTestP < .05)
            newSummary.isAudNeuron = 1;
        else
            newSummary.isAudNeuron = 0;
        end
        if (newSummary.trialMean > newSummary.preTrialMean)
            newSummary.excited = 1;
        else
            newSummary.excited = 0;
        end
        neuronSpikesSummary = [neuronSpikesSummary; newSummary];
     end
        
end