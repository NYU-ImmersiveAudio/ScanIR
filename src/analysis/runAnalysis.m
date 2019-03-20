function [handles] = runAnalysis(handles)
% Run analysis on input IR

idx = handles.app.currID;
IR = handles.data(idx).IR;
fs = handles.specs.sampleRate;

% Ratios
handles.data(idx).DRR = calcDRR(IR,fs);
handles.data(idx).C80 = calcCI(IR,fs, 0.08);
handles.data(idx).C50 = calcCI(IR,fs, 0.05);
handles.data(idx).D50 = calcD50(IR,fs);
% Schroeder energy decay curve
IR_decay = getSchroeder(IR);
handles.data(idx).EDC = IR_decay;
% Decay times
handles.data(idx).RT60 = calcRTX(IR_decay,0,-60,fs,false);
handles.data(idx).RT30 = calcRTX(IR_decay,-5,-35,fs,true);
handles.data(idx).RT20 = calcRTX(IR_decay,-5,-25,fs,true);
handles.data(idx).EDT = calcRTX(IR_decay,0,-10,fs,true);
% Center Time
handles.data(idx).TS = calcTs(IR,fs);

% --- Advanced Metrics. Require DSP toolbox ---
% Initial Time Delay Gap
if handles.enhanced_analysis
    handles.data(idx).ITDG = calcITDG(IR,fs);
else
    handles.data(idx).ITDG = [];
end

% HRIR Metrics
if handles.app.inMode == 2
    handles = runAnalysisHRIR(handles);
end

% Display
handles = displayFields(handles);

end

