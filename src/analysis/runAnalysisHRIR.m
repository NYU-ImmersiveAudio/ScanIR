function [handles] = runAnalysisHRIR(handles)
% Compute binaural audio metrics such as ITD and ILD

idx = handles.app.currID;
IR = handles.data(idx).IR;
fs = handles.specs.sampleRate;
if size(IR,2)~=2
    disp('Can`t run binaural metrics on non-stereo data');
    handles.data(idx).ITD = [];
    handles.data(idx).ILD = [];
    handles.data(idx).IACC = [];
    return;
end

handles.data(idx).ITD = getITD(IR,fs);
handles.data(idx).ILD = getILD(IR,fs);
handles.data(idx).IACC = calcIACC(IR,fs);

end

